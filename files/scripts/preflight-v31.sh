#!/usr/bin/env bash
set -euo pipefail

echo '=== Pierdziocha OS v3.3 - image assertions ==='
rpm -q cinnamon cinnamon-session cinnamon-desktop lightdm lightdm-gtk shadow-utils
if rpm -q slick-greeter >/dev/null 2>&1 || rpm -q slick-greeter-cinnamon >/dev/null 2>&1; then
    echo 'ERROR: old Slick package is still installed'
    exit 1
fi
[[ -f /usr/share/xgreeters/lightdm-gtk-greeter.desktop ]] || { echo 'ERROR: GTK greeter .desktop missing'; exit 1; }
[[ -f /usr/share/xsessions/cinnamon.desktop ]] || { echo 'ERROR: missing Cinnamon session'; exit 1; }
[[ -x /usr/bin/cinnamon-session ]] || { echo 'ERROR: missing cinnamon-session executable'; exit 1; }
[[ -f /usr/lib/systemd/system/pierdziocha-firstboot.service ]] || { echo 'ERROR: missing firstboot service'; exit 1; }
[[ -f /usr/lib/systemd/system/pierdziocha-flatpak-update.timer ]] || { echo 'ERROR: missing flatpak timer'; exit 1; }
[[ -f /usr/lib/tmpfiles.d/pierdziocha-lightdm.conf ]] || { echo 'ERROR: missing LightDM tmpfiles config'; exit 1; }
command -v passwd >/dev/null || { echo "ERROR: passwd missing"; exit 1; }
bash -n /usr/libexec/pierdziocha-firstboot.sh
[[ -f /usr/lib/systemd/system.conf.d/90-pierdziocha-console.conf ]] || { echo 'ERROR: missing boot console config'; exit 1; }
systemctl is-enabled --quiet pierdziocha-firstboot.service || {
    echo "ERROR: firstboot service is not enabled"
    exit 1
}
printf 'Preflight: OK - Cinnamon session + firstboot files present
'
