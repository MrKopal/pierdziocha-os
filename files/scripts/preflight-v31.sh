#!/usr/bin/env bash
set -euo pipefail

echo '=== Pierdziocha OS v3.1 - image assertions ==='
rpm -q cinnamon cinnamon-session cinnamon-desktop lightdm slick-greeter shadow-utils
[[ -f /usr/share/xsessions/cinnamon.desktop ]] || { echo 'ERROR: missing Cinnamon session'; exit 1; }
[[ -x /usr/bin/cinnamon-session ]] || { echo 'ERROR: missing cinnamon-session executable'; exit 1; }
[[ -f /usr/lib/systemd/system/pierdziocha-firstboot.service ]] || { echo 'ERROR: missing firstboot service'; exit 1; }
[[ -f /usr/lib/systemd/system/pierdziocha-flatpak-update.timer ]] || { echo 'ERROR: missing flatpak timer'; exit 1; }
[[ -f /usr/lib/tmpfiles.d/pierdziocha-lightdm.conf ]] || { echo 'ERROR: missing LightDM tmpfiles config'; exit 1; }
command -v passwd >/dev/null || { echo "ERROR: passwd missing"; exit 1; }
bash -n /usr/libexec/pierdziocha-firstboot.sh
[[ -f /usr/lib/systemd/system.conf.d/90-pierdziocha-console.conf ]] || { echo 'ERROR: missing boot console config'; exit 1; }
[[ -f /usr/share/lightdm/lightdm.conf.d/60-pierdziocha-greeter.conf ]] || { echo 'ERROR: missing greeter config'; exit 1; }
systemctl is-enabled --quiet pierdziocha-firstboot.service || {
    echo "ERROR: firstboot service is not enabled"
    exit 1
}
printf 'Preflight: OK - Cinnamon session + firstboot files present
'
