"""
Command Executor - Hỗ trợ thực thi lệnh trên local hoặc SSH
"""

import subprocess
import logging
from typing import Tuple, Optional
import paramiko
from paramiko.ssh_exception import SSHException, AuthenticationException


class CommandExecutor:
    """Thực thi lệnh trên local hoặc remote qua SSH"""
    
    def __init__(self, mode: str = 'local', ssh_config: dict = None):
        """
        Args:
            mode: 'local' hoặc 'ssh'
            ssh_config: Dictionary chứa thông tin SSH (host, username, key_file, etc.)
        """
        self.mode = mode
        self.ssh_config = ssh_config or {}
        self.ssh_client = None
        self.logger = logging.getLogger(__name__)
        
        if self.mode == 'ssh':
            self._setup_ssh()
    
    def _setup_ssh(self):
        """Thiết lập kết nối SSH"""
        try:
            self.ssh_client = paramiko.SSHClient()
            self.ssh_client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
            
            host = self.ssh_config.get('host')
            port = self.ssh_config.get('port', 22)
            username = self.ssh_config.get('username')
            key_file = self.ssh_config.get('key_file')
            password = self.ssh_config.get('password')
            
            if not host or not username:
                raise ValueError("SSH host and username are required")
            
            connect_kwargs = {
                'hostname': host,
                'port': port,
                'username': username,
                'timeout': self.ssh_config.get('timeout', 30)
            }
            
            if key_file:
                connect_kwargs['key_filename'] = key_file
            elif password:
                connect_kwargs['password'] = password
            else:
                raise ValueError("Either key_file or password must be provided for SSH")
            
            self.ssh_client.connect(**connect_kwargs)
            self.logger.info(f"SSH connection established to {host}")
            
        except (SSHException, AuthenticationException) as e:
            self.logger.error(f"SSH connection failed: {e}")
            raise
    
    def execute(self, command: str, timeout: int = 60, check: bool = False) -> Tuple[int, str, str]:
        """
        Thực thi lệnh
        
        Args:
            command: Lệnh cần thực thi
            timeout: Timeout in seconds
            check: Raise exception nếu return code != 0
            
        Returns:
            Tuple of (return_code, stdout, stderr)
        """
        if self.mode == 'local':
            return self._execute_local(command, timeout, check)
        elif self.mode == 'ssh':
            return self._execute_ssh(command, timeout, check)
        else:
            raise ValueError(f"Invalid mode: {self.mode}")
    
    def _execute_local(self, command: str, timeout: int, check: bool) -> Tuple[int, str, str]:
        """Thực thi lệnh trên local"""
        try:
            self.logger.debug(f"Executing local: {command}")
            result = subprocess.run(
                command,
                shell=True,
                capture_output=True,
                text=True,
                timeout=timeout,
                check=check
            )
            return result.returncode, result.stdout, result.stderr
        except subprocess.TimeoutExpired:
            self.logger.error(f"Command timed out: {command}")
            return -1, "", "Command timed out"
        except subprocess.CalledProcessError as e:
            self.logger.error(f"Command failed: {e}")
            return e.returncode, e.stdout or "", e.stderr or ""
        except Exception as e:
            self.logger.error(f"Execution error: {e}")
            return -1, "", str(e)
    
    def _execute_ssh(self, command: str, timeout: int, check: bool) -> Tuple[int, str, str]:
        """Thực thi lệnh qua SSH"""
        if not self.ssh_client:
            raise RuntimeError("SSH client not initialized")
        
        try:
            self.logger.debug(f"Executing SSH: {command}")
            stdin, stdout, stderr = self.ssh_client.exec_command(command, timeout=timeout)
            
            exit_code = stdout.channel.recv_exit_status()
            stdout_text = stdout.read().decode('utf-8')
            stderr_text = stderr.read().decode('utf-8')
            
            if check and exit_code != 0:
                raise RuntimeError(f"SSH command failed with exit code {exit_code}: {stderr_text}")
            
            return exit_code, stdout_text, stderr_text
            
        except Exception as e:
            self.logger.error(f"SSH execution error: {e}")
            return -1, "", str(e)
    
    def execute_script(self, script_path: str, timeout: int = 60) -> Tuple[int, str, str]:
        """
        Thực thi shell script
        
        Args:
            script_path: Đường dẫn đến script
            timeout: Timeout in seconds
            
        Returns:
            Tuple of (return_code, stdout, stderr)
        """
        if self.mode == 'local':
            command = f"bash {script_path}"
        else:
            # Upload script to remote and execute
            command = f"bash {script_path}"
        
        return self.execute(command, timeout=timeout)
    
    def file_exists(self, path: str) -> bool:
        """Kiểm tra file có tồn tại không"""
        command = f"test -f {path} && echo 'exists' || echo 'not_found'"
        returncode, stdout, _ = self.execute(command)
        return returncode == 0 and 'exists' in stdout
    
    def read_file(self, path: str) -> Optional[str]:
        """Đọc nội dung file"""
        command = f"cat {path}"
        returncode, stdout, _ = self.execute(command)
        return stdout if returncode == 0 else None
    
    def write_file(self, path: str, content: str, backup: bool = True) -> bool:
        """
        Ghi nội dung vào file
        
        Args:
            path: Đường dẫn file
            content: Nội dung cần ghi
            backup: Backup file gốc trước khi ghi
            
        Returns:
            True nếu thành công
        """
        try:
            if backup and self.file_exists(path):
                backup_cmd = f"cp {path} {path}.bak.$(date +%Y%m%d_%H%M%S)"
                self.execute(backup_cmd)
            
            # Escape content for shell
            escaped_content = content.replace("'", "'\\''")
            write_cmd = f"echo '{escaped_content}' > {path}"
            returncode, _, _ = self.execute(write_cmd)
            
            return returncode == 0
        except Exception as e:
            self.logger.error(f"Failed to write file {path}: {e}")
            return False
    
    def close(self):
        """Đóng kết nối SSH nếu có"""
        if self.ssh_client:
            self.ssh_client.close()
            self.logger.info("SSH connection closed")
    
    def __enter__(self):
        return self
    
    def __exit__(self, exc_type, exc_val, exc_tb):
        self.close()
