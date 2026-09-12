#!/usr/bin/env bash
set -Eeuo pipefail

username="${1:-}"

if [[ -z "$username" ]]; then
    echo "Usage: $0 <username>" >&2
    exit 1
fi

# Samba users must also exist as Linux users
if ! id "$username" &>/dev/null; then
    echo "Creating Linux user: $username"
    useradd -M -s /sbin/nologin "$username"
fi

echo "Adding Samba user: $username"
smbpasswd -a "$username"

echo "Enabling Samba user: $username"
smbpasswd -e "$username"

echo "Samba user '$username' added and enabled."

