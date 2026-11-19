#!/usr/bin/env bash
# Hard Gaming OS – Live-Anpassung im airootfs (läuft im mkarchiso-chroot).
# Wird von build-cachyos.sh als /root/hgos-customize-airootfs.sh abgelegt und aus
# customize_airootfs.sh aufgerufen. Eine vorhandene Upstream-Datei bleibt erhalten.
set -euo pipefail
log() { printf 'HGOS customize: %s\n' "$*"; }

# 1) Grafischer Login: Die frühere Build-VM brauchte eine explizite Verknüpfung
#    des Plasma Login Managers. Ohne display-manager.service endet der Live-Start
#    ohne Greeter/Autologin. Fehlt die Unit, bricht der Build ab statt ein ISO
#    mit dunklem Bildschirm zu liefern.
unit=/usr/lib/systemd/system/plasmalogin.service
[[ -f "$unit" ]] || { echo "HGOS: $unit fehlt (plasma-login-manager nicht installiert?)" >&2; exit 1; }
current="$(readlink -f /etc/systemd/system/display-manager.service 2>/dev/null || true)"
if [[ -n "$current" && "$current" != "$unit" ]]; then
  log "display-manager.service zeigte auf $current – wird auf plasmalogin umgestellt"
fi
systemctl enable --force plasmalogin.service
systemctl set-default graphical.target
[[ "$(readlink -f /etc/systemd/system/display-manager.service)" == "$unit" ]] \
  || { echo 'HGOS: display-manager.service nicht auf plasmalogin verknüpft' >&2; exit 1; }
log "Login-Manager: plasmalogin.service, Standardziel: graphical.target"

# 2) Branding-Paket (Plymouth, GRUB-Theme, Wallpaper, Plasma-Design, Farbschema,
#    fastfetch) ins Live-System. Ersetzt kollidierende CachyOS-Grafikpakete.
mapfile -t pkgs < <(find /usr/share/hard-gaming-os/packages -maxdepth 1 -name 'hgos-branding-*.pkg.tar.*' ! -name '*.sig')
[[ ${#pkgs[@]} -eq 1 ]] || { echo "HGOS: Branding-Paket nicht eindeutig (${#pkgs[@]})" >&2; exit 1; }
pacman -U --noconfirm --ask=4 "${pkgs[0]}"
/usr/lib/hard-gaming-os/apply-branding
log "Branding-Paket: ${pkgs[0]##*/}"

# 3) Plymouth-Theme muss vollständig vorhanden sein, bevor es in die initramfs geht.
theme=/usr/share/plymouth/themes/hard-gaming-os
for file in hard-gaming-os.plymouth hard-gaming-os.script logo.png; do
  [[ -s "$theme/$file" ]] || { echo "HGOS: Plymouth-Datei fehlt: $theme/$file" >&2; exit 1; }
done
[[ -d /usr/lib/plymouth ]] || { echo 'HGOS: plymouth nicht installiert' >&2; exit 1; }

# 4) Live-initramfs für beide Menü-Kernel neu erzeugen und Paarung protokollieren.
for package in linux-cachyos linux-cachyos-lts; do
  found=0
  for marker in /usr/lib/modules/*/pkgbase; do
    [[ $(cat "$marker") == "$package" ]] || continue
    kernel_dir="${marker%/pkgbase}"
    install -m644 "$kernel_dir/vmlinuz" "/boot/vmlinuz-$package"
    mkinitcpio -k "${kernel_dir##*/}" -c /etc/mkinitcpio.conf.d/archiso.conf -g "/boot/initramfs-$package.img"
    log "$package: Kernel ${kernel_dir##*/} -> /boot/vmlinuz-$package + /boot/initramfs-$package.img"
    found=1
    break
  done
  (( found )) || { echo "HGOS: Kernel $package nicht im airootfs" >&2; exit 1; }
  test -s "/boot/initramfs-$package.img"
done
install -d /usr/share/hard-gaming-os
date -u +%Y-%m-%dT%H:%M:%SZ > /usr/share/hard-gaming-os/customize-ran
log "abgeschlossen"
