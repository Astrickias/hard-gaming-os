#!/usr/bin/env bash
# Hard Gaming OS – prüft vor dem Start, ob Calamares alle Bibliotheken findet.
# Hintergrund (19.11.2026): cachyos-calamares-next 3.4.2-13 war gegen Boost 1.91
# gebaut, das Repo lieferte bereits Boost 1.92. Fehlt nur eine Boost-Version,
# wird genau diese boost-libs-Version aus dem Arch-Archiv ins LIVE-System geholt.
# Das installierte Zielsystem bezieht seine Pakete unabhängig davon aus den Repos.
set -euo pipefail
BIN=/usr/bin/calamares
ARCHIVE=https://archive.archlinux.org/packages/b/boost-libs
missing() { ldd "$BIN" 2>/dev/null | awk '/not found/ {print $1}' | sort -u; }

list="$(missing)"
[[ -z "$list" ]] && { echo 'HGOS: Calamares-Bibliotheken vollständig'; exit 0; }
printf 'HGOS: Calamares vermisst:\n%s\n' "$list"
if grep -qv '^libboost_' <<<"$list"; then
  echo 'HGOS: Es fehlen Bibliotheken außerhalb von Boost. Installer kann nicht starten.' >&2
  exit 1
fi
mapfile -t versions < <(sed -nE 's/^libboost_[A-Za-z0-9_]+\.so\.([0-9]+\.[0-9]+\.[0-9]+)$/\1/p' <<<"$list" | sort -u)
[[ ${#versions[@]} -eq 1 ]] || { echo 'HGOS: Boost-Version nicht eindeutig erkennbar' >&2; exit 1; }
version="${versions[0]}"
index="$(curl -fsSL --retry 3 "$ARCHIVE/")" || { echo 'HGOS: Arch-Archiv nicht erreichbar' >&2; exit 1; }
package="$(grep -oE "boost-libs-${version//./\\.}-[0-9]+-x86_64\.pkg\.tar\.zst" <<<"$index" | sort -uV | tail -n1)"
[[ -n "$package" ]] || { echo "HGOS: boost-libs $version nicht im Archiv gefunden" >&2; exit 1; }
echo "HGOS: Installiere $package nur im Live-System"
pacman -U --noconfirm "$ARCHIVE/$package"
list="$(missing)"
[[ -z "$list" ]] || { printf 'HGOS: Weiterhin fehlend:\n%s\n' "$list" >&2; exit 1; }
echo 'HGOS: Calamares-Bibliotheken jetzt vollständig'
