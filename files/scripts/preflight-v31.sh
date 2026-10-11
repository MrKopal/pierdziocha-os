#!/usr/bin/env bash
set -euo pipefail

echo '=== Pierdziocha OS v3.1 - image assertions ==='
rpm -q cinnamon cinnamon-session cinnamon-desktop lightdm slick-greeter shadow-utils passwd
[[ -f /usr/share/xsessions/cinnamon.desktop ]] || { echo 'ERROR: missing Cinnamon session'; exit 1; }
[[ -x /usr/bin/cinnamon-session ]] || { echo 'ERROR: missing cinnamon-session executable'; exit 1; }
[[ -f /usr/lib/systemd/system/pierdziocha-firstboot.service ]] || { echo 'ERROR: missing firstboot service'; exit 1; }
[[ -f /usr/lib/systemd/system/pierdziocha-flatpak-update.timer ]] || { echo 'ERROR: missing flatpak timer'; exit 1; }
[[ -f /usr/lib/tmpfiles.d/pierdziocha-lightdm.conf ]] || { echo 'ERROR: missing LightDM tmpfiles config'; exit 1; }
command -v passwd >/dev/null || { echo "ERROR: passwd missing"; exit 1; }
bash -n /usr/libexec/pierdziocha-firstboot.sh
printf 'Preflight: OK - Cinnamon session + firstboot files present
'
