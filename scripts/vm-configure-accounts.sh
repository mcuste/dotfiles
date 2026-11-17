#!/bin/bash
set -euo pipefail

if [[ "$(uname -s)" != Darwin || "$EUID" -ne 0 ]]; then
    echo 'Account provisioning requires root inside the macOS guest.' >&2
    exit 1
fi

: "${AGENT_PASSWORD_BASE64:?Missing agent password}"
: "${BASE_PASSWORD_BASE64:?Missing current password}"
base_password="$(printf '%s' "$BASE_PASSWORD_BASE64" | /usr/bin/base64 -D)"
agent_password="$(printf '%s' "$AGENT_PASSWORD_BASE64" | /usr/bin/base64 -D)"
unset AGENT_PASSWORD_BASE64 BASE_PASSWORD_BASE64

if [[ -z "$agent_password" ]]; then
    echo 'The agent password must not be empty.' >&2
    exit 1
fi
/usr/bin/dscl . -passwd /Users/admin "$base_password" "$agent_password"
unset base_password agent_password
/bin/chmod 700 /Users/admin

printf '%s\n' /opt/homebrew/bin /opt/homebrew/sbin >/etc/paths.d/homebrew
/bin/chmod 644 /etc/paths.d/homebrew
/usr/bin/sudo -H -u admin /bin/zsh -lc '
    set -e
    cd /
    command -v brew
    brew --version
'

if /usr/bin/defaults read /Library/Preferences/com.apple.loginwindow autoLoginUser >/dev/null 2>&1; then
    /usr/bin/defaults delete /Library/Preferences/com.apple.loginwindow autoLoginUser
fi
/bin/rm -f /etc/kcpassword
/bin/rm -f /etc/sudoers.d/admin-nopasswd
/usr/sbin/visudo -c

if ! /usr/bin/sudo -l -U admin >/dev/null 2>&1; then
    echo 'The admin account must have password-protected sudo access.' >&2
    exit 1
fi
if /usr/bin/sudo -u admin /usr/bin/sudo -k -n /usr/bin/true; then
    echo 'The admin account must require a password for sudo.' >&2
    exit 1
fi

printf '%s\n' 'Configured admin with password-protected sudo; automatic login is off.'

# Shut down as root because the builder still holds the base-image password.
/bin/rm -f "$0"
/sbin/shutdown -h now
/bin/sleep 60
echo 'The guest did not shut down within 60 seconds.' >&2
exit 1
