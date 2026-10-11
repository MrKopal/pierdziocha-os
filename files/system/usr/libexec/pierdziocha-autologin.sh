#!/usr/bin/bash
set -euo pipefail

# Nie konfiguruj autologinu, dopóki kreator
# pierwszego uruchomienia jest włączony lub aktywny.
if systemctl is-enabled --quiet initial-setup.service ||
   systemctl is-active --quiet initial-setup.service; then
    exit 0
fi

# Znajdź zwykłe lokalne konta użytkowników.
mapfile -t users < <(
    getent passwd | awk -F: '
        $3 >= 1000 && $3 < 60000 &&
        $6 ~ /^\/(home|var\/home)\// {
            print $1
        }
    '
)

# Nie zgaduj, jeśli konto nie istnieje
# albo zwykłych użytkowników jest więcej niż jeden.
if [ "${#users[@]}" -ne 1 ]; then
    exit 0
fi

config_dir=/etc/lightdm/lightdm.conf.d
config_file="$config_dir/90-pierdziocha-autologin.conf"

# Nie nadpisuj istniejącej konfiguracji.
if [ -e "$config_file" ]; then
    exit 0
fi

mkdir -p "$config_dir"

cat > "$config_file" <<EOF
[Seat:*]
autologin-user=${users[0]}
autologin-user-timeout=0
autologin-session=cinnamon
EOF