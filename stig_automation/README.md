# Ubuntu 24.04 LTS STIG Automation Tool

Công cụ kiểm tra và tự động sửa lỗi bảo mật theo chuẩn STIG cho Ubuntu 24.04 LTS.

## Tính năng

-   ✅ Kiểm tra tự động các STIG rules
-   🔧 Tự động remediation cho các lỗi phát hiện
-   📊 Tạo báo cáo trước và sau khi sửa lỗi
-   🔌 Hỗ trợ cả local và SSH remote
-   📝 Logging chi tiết

## Cấu trúc thư mục

```
stig_automation/
├── config/
│   ├── settings.yaml          # Cấu hình chung
│   └── stig_rules.json        # Định nghĩa STIG rules
├── scripts/
│   ├── checks/                # Scripts kiểm tra
│   └── remediation/           # Scripts sửa lỗi
├── lib/
│   ├── executor.py            # Thực thi lệnh local/SSH
│   ├── checker.py             # Engine kiểm tra
│   ├── remediator.py          # Engine remediation
│   └── reporter.py            # Tạo báo cáo
├── reports/                   # Thư mục chứa báo cáo
├── logs/                      # Thư mục log
├── requirements.txt
└── main.py                    # Entry point
```

## Cài đặt

```bash
pip install -r requirements.txt
```

## Sử dụng

### Chạy trên local:

```bash
python3 main.py --mode local
```

### Chạy qua SSH:

```bash
python3 main.py --mode ssh --host 192.168.1.100 --user ubuntu --key /path/to/key
```

### Chỉ kiểm tra (không remediation):

```bash
python3 main.py --mode local --check-only
```

### Kiểm tra và tự động sửa:

```bash
python3 main.py --mode local --auto-remediate
```

## Quy trình hoạt động

1. **Khởi chạy pipeline** - Đọc STIG rules và khởi tạo
2. **Kiểm tra ban đầu** - Xác định trạng thái PASS/FAIL
3. **Báo cáo Pre-remediation** - Lưu trạng thái ban đầu
4. **Auto Remediation** - Tự động sửa các lỗi FAIL
5. **Re-validation** - Kiểm tra lại sau khi sửa
6. **Báo cáo Post-remediation** - Lưu kết quả cuối cùng

## Output

-   Reports: `reports/stig_report_YYYYMMDD_HHMMSS.html`
-   Logs: `logs/stig_YYYYMMDD.log`
