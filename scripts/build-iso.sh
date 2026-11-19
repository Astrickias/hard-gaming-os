#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
usage() { echo "Aufruf: $0 gaming --profile /pfad/zum/geprueften/cachyos-archiso-profil [--execute]" >&2; exit 2; }
[[ $# -ge 3 ]] || usage
EDITION="$1"; shift
[[ "$EDITION" == gaming ]] || usage
[[ "$1" == --profile && -n "${2:-}" ]] || usage
PROFILE="$2"; shift 2
EXECUTE=0
if [[ $# -gt 0 ]]; then [[ $# -eq 1 && "$1" == --execute ]] || usage; EXECUTE=1; fi
[[ -d "$PROFILE" ]] || { echo "Profil fehlt: $PROFILE" >&2; exit 2; }
PROFILE="$(cd "$PROFILE" && pwd -P)"
for item in profiledef.sh packages.x86_64 airootfs; do
  [[ -e "$PROFILE/$item" ]] || { echo "Profil unvollstaendig: $item" >&2; exit 2; }
done
[[ -f "$PROFILE/packages.x86_64" && -d "$PROFILE/airootfs" ]] || exit 2
[[ "$PROFILE" != "$ROOT"* ]] || { echo 'Upstream-Profil muss ausserhalb des Projektverzeichnisses liegen.' >&2; exit 2; }
"$ROOT/scripts/prepare-edition.sh" "$EDITION"
DEST="$ROOT/build/iso-profile-$EDITION"
[[ "$DEST" == "$ROOT/build/iso-profile-$EDITION" ]] || exit 3
rm -rf -- "$DEST"
mkdir -p "$DEST"
cp -a "$PROFILE/." "$DEST/"
# Nur Dateien hinzufuegen: vorhandene Upstream-Dateien niemals still ueberschreiben.
while IFS= read -r -d '' file; do
  rel="${file#"$ROOT/build/$EDITION/overlay/"}"
  target="$DEST/airootfs/$rel"
  [[ ! -e "$target" && ! -L "$target" ]] || { echo "Overlay-Konflikt: $rel" >&2; exit 4; }
  mkdir -p "$(dirname "$target")"
  cp -a "$file" "$target"
done < <(find "$ROOT/build/$EDITION/overlay" -type f -print0)
cat "$ROOT/build/$EDITION/packages.txt" >> "$DEST/packages.x86_64"
# Preserve upstream package lines; remove exact duplicates only, without reordering.
awk '!seen[$0]++' "$DEST/packages.x86_64" > "$DEST/packages.tmp"
mv "$DEST/packages.tmp" "$DEST/packages.x86_64"
printf 'Staging-Profil: %s\n' "$DEST"
printf 'Paketverfuegbarkeit, Calamares-Zielsystem und Upstream-Lizenz vor Release pruefen.\n'
if [[ "$EXECUTE" -eq 0 ]]; then
  echo 'Dry-run: Kein ISO gebaut. Fuer echten Build --execute angeben.'
  exit 0
fi
[[ "${HGOS_ALLOW_EXPERIMENTAL_MKARCHISO:-0}" == 1 ]] || { echo 'Build blockiert: CachyOS verlangt den Upstream-buildiso.sh-Weg. Nur mit HGOS_ALLOW_EXPERIMENTAL_MKARCHISO=1 experimentell freigeben.' >&2; exit 5; }
[[ "$(id -u)" -eq 0 ]] || { echo 'Echter ISO-Build benoetigt root.' >&2; exit 5; }
command -v mkarchiso >/dev/null || { echo 'mkarchiso fehlt (archiso installieren).' >&2; exit 5; }
mkdir -p "$ROOT/dist/iso/$EDITION" "$ROOT/build/work-$EDITION"
mkarchiso -v -w "$ROOT/build/work-$EDITION" -o "$ROOT/dist/iso/$EDITION" "$DEST"
