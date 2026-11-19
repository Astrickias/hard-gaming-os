#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
usage() { echo "Aufruf: $0 gaming|allround [--execute] [--ref COMMIT_ODER_TAG]" >&2; exit 2; }
[[ $# -gt 0 ]] || usage
EDITION="$1"; shift
[[ "$EDITION" == gaming || "$EDITION" == allround ]] || usage
EXECUTE=0; REF="${HGOS_UPSTREAM_REF:-3215497d2e8c5fea90e185affcf973dfa2cf790b}"
while (($#)); do
 case "$1" in
 --execute) EXECUTE=1; shift;;
 --ref) [[ $# -ge 2 ]] || usage; REF="$2"; shift 2;;
 *) usage;;
 esac
done
command -v git >/dev/null || { echo 'git fehlt' >&2; exit 3; }
UPSTREAM="$ROOT/build/upstream/cachyos-live-iso"
mkdir -p "$(dirname "$UPSTREAM")"
if [[ ! -d "$UPSTREAM/.git" ]]; then
 git clone https://github.com/CachyOS/CachyOS-Live-ISO.git "$UPSTREAM"
fi
# Fetch only when a specific revision is requested; do not modify upstream working tree.
if [[ "$REF" == master ]]; then SHA="$(git -C "$UPSTREAM" rev-parse HEAD)";
else
 git -C "$UPSTREAM" fetch origin "$REF"
 SHA="$(git -C "$UPSTREAM" rev-parse FETCH_HEAD)"
fi
STAGE="$ROOT/build/cachyos-$EDITION"
rm -rf -- "$STAGE"
mkdir -p "$STAGE"
git -C "$UPSTREAM" archive "$SHA" | tar -x -C "$STAGE"
PROFILE="$STAGE/archiso"
[[ -f "$STAGE/buildiso.sh" && -f "$PROFILE/profiledef.sh" && -f "$PROFILE/packages_desktop.x86_64" && -d "$PROFILE/airootfs" ]] || { echo 'Unbekannte Upstream-Struktur – Abbruch' >&2; exit 4; }
"$ROOT/scripts/prepare-edition.sh" "$EDITION"
OVERLAY="$ROOT/build/$EDITION/overlay"
"$ROOT/scripts/install-hg-welcome.sh" "$OVERLAY"
# Refuse to replace upstream files: manual review is required on collisions.
while IFS= read -r -d '' file; do
 rel="${file#"$OVERLAY/"}"
 target="$PROFILE/airootfs/$rel"
 [[ ! -e "$target" && ! -L "$target" ]] || { echo "Overlay-Konflikt: $rel" >&2; exit 4; }
 mkdir -p "$(dirname "$target")"
 cp -a "$file" "$target"
done < <(find "$OVERLAY" -type f -print0)
# CachyOS prepare_profile überschreibt packages.x86_64 aus packages_desktop.x86_64.
PACKAGE_LIST="$PROFILE/packages_desktop.x86_64"
[[ -f "$PACKAGE_LIST" ]] || { echo 'Upstream-Paketliste fehlt' >&2; exit 4; }
printf '\npython\nfirefox\n' >> "$PACKAGE_LIST"
cat "$ROOT/build/$EDITION/packages.txt" >> "$PACKAGE_LIST"
# Preserve a reviewable list of edition-specific packages for installed-system audits.
install -Dm644 "$ROOT/config/editions/$EDITION.packages" "$PROFILE/airootfs/usr/share/hard-gaming-os/edition-packages.txt"
awk '!seen[$0]++ && $0 !~ /^(cachyos-hello|cachyos-kde-settings|cachyos-cli-installer-new)$/'  "$PACKAGE_LIST" > "$PROFILE/packages.hgos.tmp"
mv "$PROFILE/packages.hgos.tmp" "$PACKAGE_LIST"
if [[ "$EDITION" == gaming ]]; then
  printf '%s\n' lib32-nvidia-utils lib32-vulkan-intel lib32-vulkan-radeon >> "$PACKAGE_LIST"
fi
python3 "$ROOT/scripts/stage-live-branding.py" "$STAGE" "$EDITION"
install -m644 "$OVERLAY/usr/share/hard-gaming-os/os-release" "$PROFILE/airootfs/etc/os-release"
install -Dm644 "$OVERLAY/usr/share/hard-gaming-os/issue" "$PROFILE/airootfs/etc/issue"
printf '%s\n' "hardgamingos-live" > "$PROFILE/airootfs/etc/hostname"
sed -i 's/\bCachyOS\b/hardgamingos-live/gI' "$PROFILE/airootfs/etc/hosts"
sed -i '/^SigLevel = Optional TrustAll$/d' "$PROFILE/airootfs/etc/pacman.conf"
install -d "$PROFILE/airootfs/etc/plymouth"
printf '[Daemon]\nTheme=hard-gaming-os\n' > "$PROFILE/airootfs/etc/plymouth/plymouthd.conf"
sed -i '/^file_permissions=(/a\  ["/usr/local/libexec/hgos-plasma-wallpaper"]="0:0:755"' "$PROFILE/profiledef.sh"
# HGOS Calamares integration must land in the airootfs used by buildiso.
# Upstream may install/overwrite Calamares config via packages at runtime:
# this is an integration candidate and requires a live ISO verification.
CAL_ROOT="$PROFILE/airootfs"
# Runtime Calamares package is installed by CachyOS when installer starts.
# Integrate after that refresh, using the official launch script as a guarded anchor.
LAUNCHER="$CAL_ROOT/usr/local/bin/calamares-online.sh"
if [[ -f "$LAUNCHER" ]]; then
  mkdir -p "$CAL_ROOT/usr/local/libexec" "$CAL_ROOT/etc/calamares/modules" "$CAL_ROOT/usr/share/calamares/branding" "$CAL_ROOT/usr/share/hard-gaming-os/target-payload/$EDITION"
  python3 "$ROOT/scripts/install-runtime-wrapper.py" "$LAUNCHER"
  install -m 0755 "$ROOT/scripts/hgos-calamares-runtime.py" "$CAL_ROOT/usr/local/libexec/hgos-calamares-runtime"
  install -m 0755 "$ROOT/installer/hgos-target-hook.sh" "$CAL_ROOT/usr/local/libexec/hgos-target-hook"
  cp -a "$ROOT/installer/calamares/branding/hardgamingos" "$CAL_ROOT/usr/share/calamares/branding/"
  install -Dm755 "$ROOT/scripts/audit-target-packages.py" "$CAL_ROOT/usr/local/libexec/hgos-audit-target-packages"
  install -Dm644 "$ROOT/config/editions/$EDITION.packages" "$CAL_ROOT/usr/share/hard-gaming-os/manifests/$EDITION.packages"
  {
    printf '%s\n' 'operations:' '  - install:'
    { cat "$ROOT/build/$EDITION/packages.txt"; echo firefox; } | sort -u | sed 's/^/      - /'
  } > "$CAL_ROOT/usr/share/hard-gaming-os/packages-hgos-operations.conf"
  for executable in hgos-calamares-runtime hgos-target-hook hgos-audit-target-packages; do
    sed -i "/^file_permissions=(/a\  [\"/usr/local/libexec/$executable\"]=\"0:0:755\"" "$PROFILE/profiledef.sh"
  done
  cp -a "$OVERLAY/." "$CAL_ROOT/usr/share/hard-gaming-os/target-payload/$EDITION/"
  cat > "$CAL_ROOT/etc/calamares/modules/shellprocess_hgos.conf" <<EOF
---
dontChroot: true
timeout: 120
script:
  - '/usr/local/libexec/hgos-target-hook $EDITION "\${ROOT}"'
EOF
  cat > "$CAL_ROOT/etc/calamares/modules/shellprocess_hgos_plymouth.conf" <<EOF
---
dontChroot: true
timeout: 120
script:
  - 'install -d "\${ROOT}/usr/share/plymouth/themes"'
  - 'cp -a /usr/share/plymouth/themes/hard-gaming-os "\${ROOT}/usr/share/plymouth/themes/"'
EOF
  cat > "$CAL_ROOT/etc/calamares/modules/plymouthcfg_hgos.conf" <<'EOF'
---
plymouth_theme: hard-gaming-os
plymouth_simpledrm: true
EOF
  cat > "$CAL_ROOT/usr/share/applications/hgos-install.desktop" <<'EOF'
[Desktop Entry]
Type=Application
Name=Hard Gaming OS installieren
Exec=/usr/local/bin/calamares-online.sh
Icon=/usr/share/hard-gaming-os/hg-os-logo.png
Terminal=false
Categories=System;
EOF
  echo 'Runtime-Calamares-Integration vorbereitet (nach Paketaktualisierung aktiviert).'
else
  echo 'Calamares Online-Launcher fehlt; Buildfreigabe gesperrt.' >&2
  touch "$STAGE/HGOS-CALAMARES-UNVERIFIED"
fi
# Statische Login-Manager-Verknüpfung wie im früheren VM-Build. Sie greift auch,
# falls das verwendete archiso customize_airootfs.sh nicht mehr ausführt.
DM_LINK="$PROFILE/airootfs/etc/systemd/system/display-manager.service"
if [[ -e "$DM_LINK" || -L "$DM_LINK" ]]; then
  echo "Upstream-display-manager.service: $(readlink "$DM_LINK" || echo Datei) -> plasmalogin.service"
  rm -f -- "$DM_LINK"
fi
install -d "$(dirname "$DM_LINK")"
ln -s /usr/lib/systemd/system/plasmalogin.service "$DM_LINK"
ln -sfn /usr/lib/systemd/system/graphical.target "$PROFILE/airootfs/etc/systemd/system/default.target"
# Live-Anpassung (Login-Manager, Plymouth-Prüfung, initramfs beider Kernel).
# 2.1.3 überschrieb hier eine eventuell vorhandene Upstream-customize_airootfs.sh
# still. Jetzt wird die HG-Datei separat abgelegt und nur angehängt.
install -Dm755 "$ROOT/scripts/customize-airootfs.sh" "$PROFILE/airootfs/root/hgos-customize-airootfs.sh"
sed -i '/^file_permissions=(/a\  ["/root/hgos-customize-airootfs.sh"]="0:0:755"' "$PROFILE/profiledef.sh"
CUSTOMIZE="$PROFILE/airootfs/root/customize_airootfs.sh"
if [[ -e "$CUSTOMIZE" ]]; then
  ! grep -qE '^[[:space:]]*exit([[:space:]]|$)' "$CUSTOMIZE" || { echo 'Upstream-customize_airootfs.sh endet mit exit: HG-Schritt manuell einbinden' >&2; exit 4; }
  echo 'Upstream-customize_airootfs.sh gefunden: HG-Schritt wird angehängt.'
  printf '\n# Hard Gaming OS\n/root/hgos-customize-airootfs.sh\n' >> "$CUSTOMIZE"
else
  printf '#!/usr/bin/env bash\nset -euo pipefail\n/root/hgos-customize-airootfs.sh\n' > "$CUSTOMIZE"
  chmod 755 "$CUSTOMIZE"
fi
grep -q '"/root/customize_airootfs.sh"' "$PROFILE/profiledef.sh" || \
  sed -i '/^file_permissions=(/a\  ["/root/customize_airootfs.sh"]="0:0:755"' "$PROFILE/profiledef.sh"
printf '%s\n' "$SHA" > "$STAGE/HGOS-UPSTREAM-COMMIT"
printf '%s\n' "$EDITION" > "$STAGE/HGOS-EDITION"
printf 'Staging: %s\nUpstream: %s\n' "$STAGE" "$SHA"
if (( ! EXECUTE )); then
 echo 'Dry-run abgeschlossen: kein ISO erzeugt.'
 exit 0
fi
[[ ! -f "$STAGE/HGOS-CALAMARES-UNVERIFIED" ]] || { echo 'Calamares integration missing: refusing to label build HGOS.' >&2; exit 6; }
[[ "${HGOS_ACK_TARGET_UNVERIFIED:-0}" == 1 ]] || { echo 'Zielsystem-Pakete und Calamares noch ungetestet: HGOS_ACK_TARGET_UNVERIFIED=1 für ausdrücklich experimentellen Build erforderlich.' >&2; exit 6; }
[[ "$(id -u)" -eq 0 ]] || { echo 'Build benötigt root.' >&2; exit 5; }
[[ "${HGOS_ACK_EXPERIMENTAL:-0}" == 1 ]] || { echo 'Experimenteller Build: HGOS_ACK_EXPERIMENTAL=1 erforderlich.' >&2; exit 5; }
for binary in pacman mkarchiso mksquashfs grub-mkrescue; do
 command -v "$binary" >/dev/null || { echo "Abhängigkeit fehlt: $binary" >&2; exit 5; }
done
# Execute CachyOS native build pipeline from isolated staged upstream checkout.
cd "$STAGE"
./buildiso.sh -p desktop -w
printf 'Upstream-ISO-Ausgabe: %s/out\n' "$STAGE"
