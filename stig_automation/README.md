# Ubuntu 24.04 LTS STIG Automation Tool

Công cụ tự động kiểm tra và sửa lỗi bảo mật theo chuẩn DISA STIG cho Ubuntu 24.04 LTS.

## Tính năng

-   ✅ Kiểm tra tự động các STIG rules (CAT I, II, III)
-   🔧 Auto-remediation cho các lỗi phát hiện
-   📊 Báo cáo HTML/JSON trước và sau khi sửa
-   🌐 Hỗ trợ local và SSH remote
-   📝 Logging chi tiết với rotation

## Cài đặt nhanh

```bash
# Clone project
git clone <repository-url>  #https://github.com/lanhlunboizz/STIG-Automation-Tool.git
cd stig_automation

# Chạy quick start (tự động cài đặt dependencies)
chmox +x ./quick_start.sh #cấp quyền
./quick_start.sh
```

## Sử dụng cơ bản

```bash
# Kích hoạt virtual environment
source venv/bin/activate

# 1. Chỉ kiểm tra (không sửa)
./run_with_sudo.sh main.py --mode local --check-only

# 2. Kiểm tra và tự động sửa (cần sudo)
./run_with_sudo.sh --mode local --auto-remediate

# 3. Kiểm tra qua SSH
python3 main.py --mode ssh --host 192.168.1.100 --user ubuntu --key ~/.ssh/id_rsa

# 4. Xem thêm options
python3 main.py --help
```

## Cấu trúc thư mục

```
stig_automation/
├── config/
│   ├── settings.yaml          # Cấu hình logging, paths
│   └── stig_rules.json        # STIG rules definitions
├── scripts/
│   ├── checks/                # 31 check scripts
│   └── remediation/           # 31 remediation scripts
├── lib/
│   ├── executor.py            # Command execution (local/SSH)
│   ├── checker.py             # Kiểm tra STIG rules
│   ├── remediator.py          # Auto-fix vulnerabilities
│   └── reporter.py            # Generate HTML/JSON reports
├── reports/                   # Output reports
├── logs/                      # Rotating logs
└── main.py                    # Entry point
```

## Quy trình hoạt động

```
1. Load STIG Rules → 2. Pre-Check → 3. Pre-Report
                                          ↓
4. Auto-Remediation → 5. Post-Check → 6. Post-Report
```

## STIG Rules được hỗ trợ

| Category        | Count | Examples                      |
| --------------- | ----- | ----------------------------- |
| CAT I (High)    | 8     | Password policy, SSH config   |
| CAT II (Medium) | 20    | File permissions, audit rules |
| CAT III (Low)   | 3     | System banners, timeouts      |

Chi tiết: `config/stig_rules.json`

## Output Files

-   **Reports**: `reports/stig_report_YYYYMMDD_HHMMSS.html` (và `.json`)
-   **Logs**: `logs/stig_YYYYMMDD.log` (max 10MB, 5 backups)

## Xử lý lỗi thường gặp

**1. ModuleNotFoundError: paramiko**

```bash
pip3 install -r requirements.txt
```

**2. Permission denied khi remediation**

```bash
# Dùng wrapper script thay vì sudo python3 trực tiếp
./run_with_sudo.sh --mode local --auto-remediate
```

**3. TabError: inconsistent use of tabs**

```bash
python3 fix_indentation.py
```

**4. Report files owned by root**

-   Đã fix tự động với `os.chmod(filepath, 0o664)` trong `reporter.py`

## Development

```bash
# Set permissions cho scripts
./setup_permissions.sh

# Run tests
pytest tests/

# Format code
black lib/ main.py
```

## Yêu cầu hệ thống

-   Ubuntu 24.04 LTS
-   Python 3.8+
-   Sudo privileges (cho auto-remediation)

## License

MIT License - see LICENSE file

## Support

Issues: [GitHub Issues](your-repo-issues-url)
