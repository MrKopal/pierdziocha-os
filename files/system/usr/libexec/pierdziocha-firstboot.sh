#!/usr/bin/bash
set -euo pipefail

# Runs as root on tty1 during normal systemd boot, before LightDM.
# No username/password is ever baked into the container image.

exec </dev/tty1 >/dev/tty1 2>&1
printf '\n\n===========================================\n'
printf ' Pierdziocha OS - pierwsza konfiguracja\n'
printf '===========================================\n\n'

if [[ ! -f /usr/share/xsessions/cinnamon.desktop ]]; then
    echo 'BRAK cinnamon.desktop. Przerwano konfiguracje.'
    exit 1
fi

# A correctly booted system must have a writable /var, unlike rd.break.
install -d -m 0755 /var/home
install -d -m 0755 /var/lib/pierdziocha

mapfile -t users < <(getent passwd | awk -F: '
    $3 >= 1000 && $3 < 60000 && $6 ~ /^\/(home|var\/home)\// { print $1 }
')

if (( ${#users[@]} > 1 )); then
    echo 'Wykryto kilka kont. Autologin nie zostanie ustawiony.'
    echo 'Wybierz konto recznie w LightDM.'
    touch /var/lib/pierdziocha/firstboot-complete
    exit 0
fi

if (( ${#users[@]} == 1 )); then
    username=${users[0]}
    printf 'Wykryto istniejace konto: %s\n' "$username"
else
    while true; do
        read -r -p 'Nazwa uzytkownika (male litery, bez spacji): ' username
        if [[ $username =~ ^[a-z_][a-z0-9_-]{0,31}$ ]] && ! getent passwd "$username" >/dev/null; then
            break
        fi
        echo 'Nieprawidlowa lub zajeta nazwa. Sprobuj ponownie.'
    done
    # The -m home creation must happen with normal systemd mounts active.
    useradd -m -d "/var/home/$username" -G wheel -s /bin/bash "$username"
fi

# If interrupted after useradd, the next boot finds the account and
# asks for a password rather than silently allowing autologin.
while [[ $(passwd -S "$username" 2>/dev/null | awk '{print $2}') != P ]]; do
    printf '\nUstaw haslo do konta %s (wpisz dwa razy).\n' "$username"
    passwd "$username" || echo 'Haslo nie zostalo zapisane. Sprobuj ponownie.'
done

install -d -m 0700 -o "$username" -g "$username" "/var/home/$username"
if command -v restorecon >/dev/null 2>&1; then
    restorecon -RF "/var/home/$username"
fi

# The autologin group is only required by some LightDM PAM policies.
if getent group autologin >/dev/null 2>&1; then
    usermod -aG autologin "$username"
fi

install -d -m 0755 /etc/lightdm/lightdm.conf.d
cat > /etc/lightdm/lightdm.conf.d/90-pierdziocha-autologin.conf <<EOF
[Seat:*]
user-session=cinnamon
autologin-user=$username
autologin-user-timeout=0
autologin-session=cinnamon
EOF

touch /var/lib/pierdziocha/firstboot-complete
printf '\nKonto gotowe. Start Cinnamon...\n'
