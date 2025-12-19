# Changelog - STIG Automation Tool

## Total Rules: 26 (reduced from 36)

## Removed Rules (Security Safety & User Choice)

### Authentication/Password Related Rules (8 rules removed):

1. **UBTU-24-100600** - libpam-pwquality (password complexity)
2. **UBTU-24-200060** - Session timeout after 10 minutes
3. **UBTU-24-200250** - Expire temporary accounts (72 hours)
4. **UBTU-24-200260** - Lock inactive accounts (30 days)
5. **UBTU-24-200000** - Limit concurrent sessions (10 max)
6. **UBTU-24-200610** - Account lockout (3 failed attempts)
7. **UBTU-24-300017** - Login delay (4 seconds)
8. **UBTU-24-400340** - PAM cached authentication (1 day)

**Reason**: User has VM snapshots for recovery, prefers to avoid any authentication-related issues

## Removed Rules (Security Safety)

### UBTU-24-100650 - SSSD Package Installation

**Reason**: Removed to prevent authentication lockout

-   Installing `libpam-sss` automatically configures PAM to use SSSD
-   If SSSD service not properly configured, all authentication fails
-   Users cannot login even with correct password

### UBTU-24-100660 - SSSD Service Enable/Start

**Reason**: Removed to prevent authentication lockout

-   Starting SSSD without proper domain configuration breaks authentication
-   Must be manually configured by system administrator

## Total Rules: 34 (was 36)

## Why 2 Remediation Runs Needed?

### Dependency Chain:

1. **First Run** (11 → 21 PASS):

    - Install base packages (openssh-server, chrony, etc.)
    - Packages install successfully but services need restart
    - Configuration rules fail because services not yet ready

2. **Second Run** (21 → 30+ PASS):
    - Services are now running from first run
    - Configuration rules can now modify sshd_config
    - SSH restart applies new configurations

### Improvements Made for Single-Run:

-   Added `sleep 2` after openssh-server check
-   Added explicit dependency checks in SSH config rules
-   Added wait-for-service logic in remediation scripts
-   Should now achieve 90%+ in single run

## SSH Configuration Dependencies:

-   Rule 22 (UBTU-24-100800): Install openssh-server ← **Must run first**
-   Rule 23 (UBTU-24-100810): Enable/start SSH service ← Depends on 22
-   Rule 24 (UBTU-24-100820): Configure Ciphers ← Depends on 22+23
-   Rule 25 (UBTU-24-100830): Configure MACs ← Depends on 22+23
-   Rule 26 (UBTU-24-100840): Configure KexAlgorithms ← Depends on 22+23

## Performance Optimizations:

-   Reduced apt-get output with `2>&1 | tail -5`
-   Added `-qq` flag to apt-get update
-   Added `DEBIAN_FRONTEND=noninteractive` for non-interactive installs
-   Reduced verbose logging to prevent layout issues

## Current Status:

-   34 rules total
-   No authentication lockout risk
-   Should achieve 90%+ compliance in single run
-   Remaining failures expected: GRUB password (requires manual setup)
