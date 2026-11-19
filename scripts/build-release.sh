#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
[[ $# -eq 1 && ( "$1" == gaming || "$1" == allround ) ]] || { echo 'Aufruf: sudo ./scripts/build-release.sh gaming|allround' >&2; exit 2; }
EDITION="$1"
source "$ROOT/config/release.env"
[[ $(id -u) == 0 ]] || { echo 'Nur auf einem CachyOS-Buildhost als root ausführen.' >&2; exit 2; }
for tool in git pacman mkarchiso mksquashfs sha256sum python3; do command -v "$tool" >/dev/null || { echo "Fehlendes Werkzeug: $tool" >&2; exit 3; }; done
[[ -n "${HGOS_UPSTREAM_REF:-}" && "$HGOS_UPSTREAM_REF" =~ ^[a-fA-F0-9]{40}$ ]] || { echo 'HGOS_UPSTREAM_REF muss ein zuvor geprüfter 40-stelliger CachyOS-Git-Commit sein.' >&2; exit 3; }
[[ "${HGOS_ACK_EXPERIMENTAL:-0}" == 1 && "${HGOS_ACK_TARGET_UNVERIFIED:-0}" == 1 ]] || { echo 'Experimentellen Build und unbestätigte Zielinstallation ausdrücklich mit HGOS_ACK_EXPERIMENTAL=1 und HGOS_ACK_TARGET_UNVERIFIED=1 bestätigen.' >&2; exit 3; }
mkdir -p "$ROOT/dist/iso" "$ROOT/dist/logs"
LOG="$ROOT/dist/logs/build-${EDITION}-$HGOS_VERSION.log"
exec > >(tee "$LOG") 2>&1
"$ROOT/scripts/build-cachyos.sh" "$EDITION" --execute --ref "$HGOS_UPSTREAM_REF"
STAGE="$ROOT/build/cachyos-$EDITION"
mapfile -d '' ISOS < <(find "$STAGE/out" -type f -name '*.iso' -newer "$STAGE/.hgos-build-start" -print0)
[[ ${#ISOS[@]} -eq 1 ]] || { echo "Erwartet genau eine ISO, gefunden: ${#ISOS[@]}" >&2; exit 7; }
TARGET="$ROOT/dist/iso/Hard-Gaming-OS-${EDITION}-$HGOS_VERSION-x86_64.iso"
cp -- "${ISOS[0]}" "$TARGET"
(cd "$(dirname "$TARGET")" && sha256sum "$(basename "$TARGET")") > "$TARGET.sha256"
cat "$TARGET.sha256"
echo "ISO erzeugt: $TARGET"
echo "Nächster Schritt: VM-Test nach docs/DIAGNOSE-2.1.4.md (Live-Start, Installation, Neustart ohne ISO)."
