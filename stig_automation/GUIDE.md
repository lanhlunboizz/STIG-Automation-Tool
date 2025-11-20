# STIG Automation Tool - Hướng dẫn sử dụng chi tiết

## Giới thiệu

Công cụ tự động kiểm tra và sửa lỗi bảo mật theo chuẩn STIG (Security Technical Implementation Guide) cho Ubuntu 24.04 LTS.

## Cài đặt

### Yêu cầu hệ thống

-   Python 3.8 trở lên
-   Ubuntu 24.04 LTS (target system)
-   Quyền sudo (cho remediation)

### Cài đặt nhanh

```bash
cd stig_automation
bash quick_start.sh
```

### Cài đặt thủ công

```bash
# 1. Cài đặt dependencies
apt install python3-venv -y
python3 -m venv venv
source venv/bin/activate
pip3 install -r requirements.txt

# 2. Cấp quyền thực thi cho scripts
bash setup_permissions.sh

# 3. Tạo thư mục
mkdir -p reports logs
```

## Sử dụng

### Chế độ Local

#### Chỉ kiểm tra (không sửa)

```bash
python3 main.py --mode local --check-only
```

#### Kiểm tra và tự động sửa

```bash
sudo python3 main.py --mode local --auto-remediate
```

### Chế độ SSH

#### Kết nối bằng SSH key

```bash
python3 main.py --mode ssh \
    --host 192.168.1.100 \
    --user ubuntu \
    --key ~/.ssh/id_rsa \
    --check-only
```

#### Kết nối bằng password

```bash
python3 main.py --mode ssh \
    --host 192.168.1.100 \
    --user ubuntu \
    --password yourpassword \
    --auto-remediate
```

### Kiểm tra rules cụ thể

```bash
python3 main.py --mode local \
    --rules UBTU-24-010001,UBTU-24-010006,UBTU-24-010008 \
    --check-only
```

### Tùy chọn nâng cao

#### Thay đổi log level

```bash
python3 main.py --mode local --log-level DEBUG --check-only
```

#### Không backup khi remediate

```bash
sudo python3 main.py --mode local --auto-remediate --no-backup
```

## Cấu trúc Rules

File `config/stig_rules.json` chứa định nghĩa tất cả các rules:

```json
{
    "rules": [
        {
            "rule_id": "UBTU-24-010001",
            "severity": "high",
            "title": "Mô tả rule",
            "description": "Chi tiết yêu cầu",
            "check_script": "check_xxx.sh",
            "remediation_script": "fix_xxx.sh",
            "category": "danh_mục"
        }
    ]
}
```

## Thêm Rules mới

### Bước 1: Thêm định nghĩa vào stig_rules.json

```json
{
    "rule_id": "UBTU-24-010999",
    "severity": "high",
    "title": "Custom security rule",
    "description": "Description here",
    "check_script": "check_custom.sh",
    "remediation_script": "fix_custom.sh",
    "category": "custom"
}
```

### Bước 2: Tạo check script

File: `scripts/checks/check_custom.sh`

```bash
#!/bin/bash
# Check script phải return 0 nếu PASS, 1 nếu FAIL

# Logic kiểm tra
if [ condition ]; then
    echo "PASS: Description"
    exit 0
else
    echo "FAIL: Description"
    exit 1
fi
```

### Bước 3: Tạo remediation script

File: `scripts/remediation/fix_custom.sh`

```bash
#!/bin/bash
# Remediation script phải return 0 nếu thành công

echo "Applying fix..."

# Backup
cp /etc/config /etc/config.bak

# Apply fix
sed -i 's/old/new/' /etc/config

# Verify
if [ verification ]; then
    echo "Fix applied successfully"
    exit 0
else
    echo "Fix failed"
    exit 1
fi
```

### Bước 4: Cấp quyền thực thi

```bash
chmod +x scripts/checks/check_custom.sh
chmod +x scripts/remediation/fix_custom.sh
```

## Quy trình hoạt động

```
1. KHỞI CHẠY PIPELINE
   ↓
2. KIỂM TRA BAN ĐẦU (Pre-Check)
   - Chạy tất cả check scripts
   - Xác định PASS/FAIL
   ↓
3. BÁO CÁO PRE-REMEDIATION
   - Lưu trạng thái ban đầu
   ↓
4. TỰ ĐỘNG REMEDIATION (nếu enabled)
   - Chạy fix scripts cho các rule FAIL
   - Retry nếu thất bại
   ↓
5. KIỂM TRA LẠI (Re-Validation)
   - Chạy lại check scripts
   - Xác định cải thiện
   ↓
6. BÁO CÁO POST-REMEDIATION
   - So sánh trước/sau
   - Tính compliance rate
```

## Báo cáo

### HTML Report

-   Vị trí: `reports/stig_report_YYYYMMDD_HHMMSS.html`
-   Hiển thị dashboard với:
    -   Summary statistics
    -   Pre/Post comparison
    -   Detailed results table
    -   Visual indicators

### JSON Report

-   Vị trí: `reports/stig_report_YYYYMMDD_HHMMSS.json`
-   Dữ liệu structured để parse
-   Có thể tích hợp với CI/CD

### Logs

-   Vị trí: `logs/stig_YYYYMMDD.log`
-   Chi tiết từng bước thực thi
-   Debug information

## Troubleshooting

### Script không thực thi được

```bash
# Cấp quyền execute
chmod +x scripts/checks/*.sh
chmod +x scripts/remediation/*.sh
```

### SSH connection failed

```bash
# Kiểm tra key permissions
chmod 600 ~/.ssh/id_rsa

# Test SSH manually
ssh -i ~/.ssh/id_rsa user@host
```

### Permission denied khi remediate

```bash
# Chạy với sudo
sudo python3 main.py --mode local --auto-remediate
```

### Module not found

```bash
# Cài đặt lại dependencies
pip3 install -r requirements.txt
```

## Best Practices

1. **Luôn backup trước khi remediate**

    - Mặc định tool đã backup
    - Có thể disable với `--no-backup`

2. **Test trên môi trường non-production trước**

    - Remediation có thể ảnh hưởng hệ thống
    - Kiểm tra kỹ trước khi áp dụng production

3. **Review báo cáo sau mỗi lần chạy**

    - Kiểm tra các rule FAIL
    - Xác định lý do remediation thất bại

4. **Chạy định kỳ để maintain compliance**

    - Cài đặt cron job
    - Monitor compliance rate

5. **Customize rules theo nhu cầu**
    - Thêm/bớt rules trong stig_rules.json
    - Tạo custom check/fix scripts

## Tích hợp CI/CD

### GitLab CI Example

```yaml
stig_check:
    stage: test
    script:
        - python3 main.py --mode local --check-only
        - python3 -c "import json; r=json.load(open('reports/latest.json')); exit(0 if r['post_check']['summary']['compliance_rate'] >= 80 else 1)"
```

### Jenkins Pipeline Example

```groovy
stage('STIG Compliance') {
    steps {
        sh 'python3 main.py --mode local --check-only'
        archiveArtifacts artifacts: 'reports/*.html'
    }
}
```

## Liên hệ & Support

-   Issues: Tạo issue trên repository
-   Documentation: Xem README.md
-   Examples: Xem examples.sh
