# ISO-Integration 0.3.0

Der Adapter übernimmt ein lokal vorhandenes, vorher überprüftes archiso-kompatibles CachyOS-Profil. Er kopiert das Profil in ein editionsspezifisches Build-Verzeichnis, ergänzt Paketwünsche und Overlay und ruft `mkarchiso` nur bei `--execute` auf.

## Vor einem echten Build

1. Offizielle CachyOS-Quellen/Lizenzen und Commit-ID dokumentieren.
2. Tatsächliche Profilstruktur, Paketquellen und Paketnamen (insbesondere `heroic-games-launcher`) prüfen.
3. Calamares-Integration prüfen: Branding und Desktop-Defaults müssen auch im installierten System landen.
4. Bootkonfiguration, Signaturen, Paketkeys und rechtliche Hinweise prüfen.
5. QEMU/UEFI- und reale Hardwaretests durchführen.

Das Skript baut nicht aus einem unbestätigten Git-Repository und modifiziert keine Systemdateien des Hosts.
