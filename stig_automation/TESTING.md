# Testing Strategy - STIG Automation Tool

## 📋 Tổng quan

Tài liệu này hướng dẫn cách kiểm tra đầy đủ chức năng của công cụ STIG Automation trên cả môi trường **local** và **remote (SSH)**.

---

## 🔍 1. Testing trên Local (Ubuntu 24.04)

### 1.1. Kiểm tra cơ bản (Check-only mode)

```bash
# Activate virtual environment
source venv/bin/activate

# Test check-only mode
./run_with_sudo.sh --mode local

# Verify:
# ✅ All scripts executable (auto chmod +x)
# ✅ Check results displayed for all 31 rules
# ✅ Compliance rate calculated
# ✅ HTML report generated in reports/
# ✅ JSON report generated in reports/
# ✅ File:// links displayed at the end
# ✅ Reports are readable without sudo
```

**Expected Output:**

```
Setting execute permissions for scripts...
Execute permissions set for all scripts
...
Check completed: X PASS, Y FAIL, 0 ERROR
Compliance Rate: XX.X%
...
View Reports:
  HTML: file:///home/user/stig_automation/reports/stig_report_YYYYMMDD_HHMMSS.html
  JSON: file:///home/user/stig_automation/reports/stig_report_YYYYMMDD_HHMMSS.json
```

### 1.2. Kiểm tra chức năng Remediation

```bash
# Test với auto-remediation
./run_with_sudo.sh --mode local --auto-remediate

# Verify:
# ✅ Failed rules are remediated
# ✅ Remediation output visible (echo messages)
# ✅ Re-validation performed
# ✅ Compliance rate improves
# ✅ Both pre and post reports generated
# ✅ Reports readable by user (not just root)
```

**Expected Phases:**

1. Pre-remediation check
2. Auto remediation (with visible echo output)
3. Re-validation check
4. Reports generation
5. Summary with improvement metrics

### 1.3. Test specific rules

```bash
# Test specific rule subset
sudo python3 main.py --mode local --rules "UBTU-24-100010,UBTU-24-100800"

# Test with retry
sudo python3 main.py --mode local --auto-remediate --max-retry 3
```

---

## 🌐 2. Testing trên Remote (SSH)

### 2.1. Chuẩn bị môi trường SSH

**Trên remote server:**

```bash
# Install SSH server if needed
sudo apt install openssh-server

# Enable SSH
sudo systemctl enable ssh
sudo systemctl start ssh

# Create test user
sudo useradd -m -s /bin/bash testuser
sudo usermod -aG sudo testuser

# Setup SSH key (recommended)
ssh-keygen -t rsa -b 4096 -f ~/.ssh/stig_test_key
ssh-copy-id -i ~/.ssh/stig_test_key.pub testuser@remote-ip
```

### 2.2. Test SSH connectivity

```bash
# Test SSH connection
ssh -i ~/.ssh/stig_test_key testuser@remote-ip "echo 'SSH OK'"

# Test sudo access
ssh -i ~/.ssh/stig_test_key testuser@remote-ip "sudo whoami"
```

### 2.3. Run remote checks

```bash
# Check-only via SSH (with key)
python3 main.py \
  --mode ssh \
  --host 192.168.1.100 \
  --user testuser \
  --key ~/.ssh/stig_test_key

# Check-only via SSH (with password)
python3 main.py \
  --mode ssh \
  --host 192.168.1.100 \
  --user testuser \
  --password "yourpassword"

# Verify:
# ✅ SSH connection successful
# ✅ Commands execute on remote
# ✅ Check results returned
# ✅ Reports generated locally
```

### 2.4. Run remote remediation

```bash
# Remediation via SSH
python3 main.py \
  --mode ssh \
  --host 192.168.1.100 \
  --user testuser \
  --key ~/.ssh/stig_test_key \
  --auto-remediate

# Verify:
# ✅ Remediation scripts execute on remote
# ✅ Echo output visible from remote
# ✅ Changes applied on remote server
# ✅ Re-validation confirms fixes
```

---

## 🧪 3. Testing Matrix

| Test Case          | Local | SSH (Key) | SSH (Password) | Expected Result     |
| ------------------ | ----- | --------- | -------------- | ------------------- |
| Check-only         | ✅    | ✅        | ✅             | Reports generated   |
| Auto-remediate     | ✅    | ✅        | ✅             | Fixes applied       |
| Specific rules     | ✅    | ✅        | ✅             | Subset checked      |
| Script permissions | ✅    | ⚠️        | ⚠️             | Auto chmod on local |
| Report ownership   | ✅    | ✅        | ✅             | User can read       |
| Echo visibility    | ✅    | ✅        | ✅             | Output logged       |
| File:// links      | ✅    | ✅        | ✅             | Clickable URLs      |

---

## 🔬 4. Chi tiết kiểm tra từng loại rule

### 4.1. Package Installation Rules

```bash
# Test package checks (100010, 100800, 100900, etc.)
sudo python3 main.py --mode local --rules "UBTU-24-100010,UBTU-24-100800"

# Verify:
# - dpkg checks work correctly
# - Installation proceeds if missing
# - Post-check confirms installation
```

### 4.2. Service Configuration Rules

```bash
# Test service checks (100660, 100810, etc.)
sudo python3 main.py --mode local --rules "UBTU-24-100660,UBTU-24-100810"

# Verify:
# - systemctl commands work
# - Service enablement succeeds
# - Status verification accurate
```

### 4.3. Configuration File Rules

```bash
# Test config modifications (100820, 100830, 100840)
sudo python3 main.py --mode local --rules "UBTU-24-100820,UBTU-24-100830"

# Verify:
# - Backup files created
# - Config updated correctly
# - Service restart successful
# - Changes persist after reboot
```

### 4.4. Account Management Rules

```bash
# Test account policies (200060, 200260)
sudo python3 main.py --mode local --rules "UBTU-24-200060,UBTU-24-200260"

# Verify:
# - /etc/profile.d/ files created
# - /etc/default/useradd updated
# - Settings applied to existing users
```

### 4.5. Manual Intervention Rules

```bash
# Test manual rules (102000, 200250)
sudo python3 main.py --mode local --rules "UBTU-24-102000,UBTU-24-200250"

# Verify:
# - Clear instructions displayed
# - Exit code indicates manual action needed
# - Templates/examples provided
```

---

## 📊 5. Validation Checklist

### After Check-Only Run:

-   [ ] All 31 rules checked
-   [ ] PASS/FAIL/ERROR counts correct
-   [ ] Compliance rate calculated
-   [ ] HTML report opens in browser
-   [ ] JSON report valid format
-   [ ] Reports readable by user (not root-only)
-   [ ] File:// links work when clicked

### After Remediation Run:

-   [ ] Failed rules attempted remediation
-   [ ] Echo output visible for each script
-   [ ] Retry mechanism works (max 3 attempts)
-   [ ] Re-validation performed
-   [ ] Compliance rate improved
-   [ ] Pre/post reports show differences
-   [ ] Changes persist after reboot

### SSH-Specific Checks:

-   [ ] Connection establishes successfully
-   [ ] Commands execute on remote
-   [ ] File transfers work (if needed)
-   [ ] SSH session closed properly
-   [ ] No hanging connections

---

## 🐛 6. Common Issues & Troubleshooting

### Issue: Reports are read-only

**Solution:** Fixed in latest version - reports now have ownership changed to $SUDO_USER

### Issue: Echo messages not visible

**Solution:** Fixed - stdout/stderr now logged in remediator.py

### Issue: Permission denied on scripts

**Solution:** Fixed - auto chmod +x on startup

### Issue: SSH connection timeout

**Check:**

```bash
# Verify SSH service
sudo systemctl status ssh

# Check firewall
sudo ufw status
sudo ufw allow 22/tcp

# Test connection
ssh -vvv user@host
```

### Issue: Remediation fails repeatedly

**Debug:**

```bash
# Run single rule with verbose logging
sudo python3 main.py --mode local --rules "UBTU-24-XXXXX" --log-level DEBUG

# Check script manually
sudo bash -x scripts/remediation/UBTU-24-XXXXX.sh
```

---

## 🎯 7. Recommended Testing Workflow

### Initial Development Testing:

1. Test on fresh Ubuntu 24.04 VM (local)
2. Run check-only to get baseline
3. Run remediation on failing rules
4. Verify improvements in re-check
5. Reboot and re-test persistence

### Pre-Deployment Testing:

1. Test all 31 rules on local
2. Test SSH connection with key
3. Test SSH remediation
4. Test specific rule subsets
5. Test retry mechanism
6. Verify report generation

### Production Testing:

1. Test on staging environment first
2. Run check-only to assess impact
3. Review remediation scripts for critical rules
4. Apply remediations in batches
5. Monitor system stability
6. Document any manual interventions needed

---

## 📝 8. Test Data Collection

### Collect these metrics:

```bash
# Before remediation
BEFORE_PASS=$(grep -c "PASS" pre_check.json)
BEFORE_FAIL=$(grep -c "FAIL" pre_check.json)

# After remediation
AFTER_PASS=$(grep -c "PASS" post_check.json)
AFTER_FAIL=$(grep -c "FAIL" post_check.json)

# Calculate improvement
IMPROVEMENT=$((AFTER_PASS - BEFORE_PASS))
echo "Improvement: $IMPROVEMENT rules fixed"
```

### Generate test report:

-   Initial compliance rate
-   Post-remediation compliance rate
-   Number of rules fixed
-   Rules requiring manual intervention
-   Execution time
-   Any errors encountered

---

## 🔐 9. Security Testing

### Test privilege escalation:

```bash
# Run as regular user (should work for check-only)
python3 main.py --mode local

# Run remediation without sudo (should fail gracefully)
python3 main.py --mode local --auto-remediate

# Run with sudo (should work)
sudo python3 main.py --mode local --auto-remediate
```

### Test report permissions:

```bash
# Generate report
sudo python3 main.py --mode local

# Try to open as regular user
REPORT=$(ls -t reports/stig_report_*.html | head -1)
firefox "$REPORT"  # Should open successfully

# Check ownership
ls -la reports/stig_report_*.html
# Should show: rw-rw-rw- user:user (not root:root)
```

---

## ✅ 10. Final Verification

Before considering tool production-ready:

-   [ ] All 31 rules tested individually
-   [ ] Full suite passes on fresh Ubuntu 24.04
-   [ ] SSH mode works with both key and password
-   [ ] Reports accessible without sudo
-   [ ] File:// links clickable in terminal
-   [ ] Echo output visible during remediation
-   [ ] Ownership fix works ($SUDO_USER)
-   [ ] Scripts auto-chmod on startup
-   [ ] Retry mechanism effective
-   [ ] Manual rules provide clear instructions
-   [ ] Documentation complete (README, GUIDE, TESTING)
-   [ ] Git repository organized with clear commits

---

**Best Practice:** Always test on a non-production system first!
