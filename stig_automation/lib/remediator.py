"""
STIG Remediator - Engine tự động sửa lỗi STIG
"""

import os
import json
import logging
from typing import Dict, List, Optional
from datetime import datetime
from .executor import CommandExecutor


class STIGRemediator:
    """Engine tự động remediation cho STIG rules"""
    
    def __init__(self, executor: CommandExecutor, rules_file: str, 
                 remediation_scripts_dir: str, backup: bool = True):
        """
        Args:
            executor: CommandExecutor instance
            rules_file: Path to STIG rules JSON file
            remediation_scripts_dir: Directory containing remediation scripts
            backup: Backup files before modification
        """
        self.executor = executor
        self.rules_file = rules_file
        self.remediation_scripts_dir = remediation_scripts_dir
        self.backup = backup
        self.logger = logging.getLogger(__name__)
        self.rules = []
        self.remediation_results = []
        
        self._load_rules()
    
    def _load_rules(self):
        """Load STIG rules from JSON file"""
        try:
            with open(self.rules_file, 'r', encoding='utf-8') as f:
                data = json.load(f)
                self.rules = data.get('rules', [])
            self.logger.info(f"Loaded {len(self.rules)} STIG rules for remediation")
        except Exception as e:
            self.logger.error(f"Failed to load rules: {e}")
            raise
    
    def _get_rule_by_id(self, rule_id: str) -> Optional[Dict]:
        """Tìm rule theo ID"""
        for rule in self.rules:
            if rule.get('rule_id') == rule_id:
                return rule
        return None
    
    def remediate_rule(self, rule_id: str, force: bool = False) -> Dict:
        """
        Thực hiện remediation cho một rule
        
        Args:
            rule_id: Rule ID cần fix
            force: Force remediation ngay cả khi có lỗi
            
        Returns:
            Dictionary chứa kết quả remediation
        """
        rule = self._get_rule_by_id(rule_id)
        
        if not rule:
            return {
                'rule_id': rule_id,
                'status': 'ERROR',
                'message': f'Rule {rule_id} not found',
                'timestamp': datetime.now().isoformat()
            }
        
        remediation_script = rule.get('remediation_script')
        
        self.logger.info(f"Remediating rule: {rule_id}")
        
        result = {
            'rule_id': rule_id,
            'title': rule.get('title'),
            'severity': rule.get('severity'),
            'status': 'UNKNOWN',
            'message': '',
            'details': '',
            'timestamp': datetime.now().isoformat()
        }
        
        if not remediation_script:
            result['status'] = 'ERROR'
            result['message'] = 'No remediation script defined'
            return result
        
        script_path = os.path.join(self.remediation_scripts_dir, remediation_script)
        
        if not os.path.exists(script_path):
            result['status'] = 'ERROR'
            result['message'] = f'Remediation script not found: {script_path}'
            self.logger.error(result['message'])
            return result
        
        try:
            # Thực thi remediation script
            self.logger.info(f"Executing remediation: {script_path}")
            returncode, stdout, stderr = self.executor.execute_script(script_path, timeout=120)
            
            # Log script output for visibility
            if stdout:
                for line in stdout.strip().split('\n'):
                    if line.strip():
                        self.logger.info(f"  {rule_id}: {line}")
            if stderr:
                for line in stderr.strip().split('\n'):
                    if line.strip():
                        self.logger.warning(f"  {rule_id} stderr: {line}")
            
            result['details'] = stdout.strip() if stdout else stderr.strip()
            
            if returncode == 0:
                result['status'] = 'SUCCESS'
                result['message'] = 'Remediation applied successfully'
                self.logger.info(f"Rule {rule_id}: Remediation SUCCESS")
            else:
                result['status'] = 'FAILED' if not force else 'PARTIAL'
                result['message'] = f'Remediation failed with exit code {returncode}'
                self.logger.warning(f"Rule {rule_id}: Remediation FAILED (exit code {returncode})")
            
        except Exception as e:
            result['status'] = 'ERROR'
            result['message'] = f'Remediation error: {str(e)}'
            self.logger.error(f"Rule {rule_id} remediation error: {e}")
        
        return result
    
    def remediate_failed_rules(self, failed_results: List[Dict], 
                               max_retry: int = 3) -> List[Dict]:
        """
        Tự động remediate tất cả các rules FAIL
        
        Args:
            failed_results: List of failed check results
            max_retry: Maximum retry attempts
            
        Returns:
            List of remediation results
        """
        self.remediation_results = []
        
        if not failed_results:
            self.logger.info("No failed rules to remediate")
            return self.remediation_results
        
        self.logger.info(f"Starting remediation for {len(failed_results)} failed rules")
        
        for failed_rule in failed_results:
            rule_id = failed_rule.get('rule_id')
            
            # Retry mechanism
            for attempt in range(1, max_retry + 1):
                self.logger.info(f"Remediation attempt {attempt}/{max_retry} for {rule_id}")
                
                result = self.remediate_rule(rule_id)
                
                if result['status'] == 'SUCCESS':
                    self.remediation_results.append(result)
                    break
                elif attempt == max_retry:
                    # Last attempt failed
                    result['message'] += f' (Failed after {max_retry} attempts)'
                    self.remediation_results.append(result)
        
        # Summary
        success = sum(1 for r in self.remediation_results if r['status'] == 'SUCCESS')
        failed = sum(1 for r in self.remediation_results if r['status'] in ['FAILED', 'ERROR'])
        
        self.logger.info(f"Remediation completed: {success} SUCCESS, {failed} FAILED")
        
        return self.remediation_results
    
    def get_summary(self) -> Dict:
        """Lấy tổng kết kết quả remediation"""
        if not self.remediation_results:
            return {
                'total': 0,
                'success': 0,
                'failed': 0,
                'errors': 0,
                'success_rate': 0.0
            }
        
        total = len(self.remediation_results)
        success = sum(1 for r in self.remediation_results if r['status'] == 'SUCCESS')
        failed = sum(1 for r in self.remediation_results if r['status'] == 'FAILED')
        errors = sum(1 for r in self.remediation_results if r['status'] == 'ERROR')
        
        success_rate = (success / total * 100) if total > 0 else 0.0
        
        return {
            'total': total,
            'success': success,
            'failed': failed,
            'errors': errors,
            'success_rate': round(success_rate, 2)
        }
    
    def export_results(self, output_file: str):
        """Export remediation results to JSON"""
        try:
            output_data = {
                'timestamp': datetime.now().isoformat(),
                'summary': self.get_summary(),
                'results': self.remediation_results
            }
            
            with open(output_file, 'w', encoding='utf-8') as f:
                json.dump(output_data, f, indent=2, ensure_ascii=False)
            
            self.logger.info(f"Remediation results exported to {output_file}")
        except Exception as e:
            self.logger.error(f"Failed to export remediation results: {e}")
