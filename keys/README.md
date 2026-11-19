# Signaturschlüssel

Hier liegt nur der **öffentliche** Schlüssel von Hard Gaming OS. Der private Schlüssel gehört ausschließlich auf den Rechner von Hard Gaming Labs und als Secret `HGOS_GPG_PRIVATE_KEY` in GitHub Actions – niemals in dieses Repository.

| Datei | Inhalt |
|---|---|
| `hardgaming.gpg` | öffentlicher Schlüssel (ASCII-armored) |
| `hardgaming-trusted` | Fingerabdruck mit Vertrauensstufe, Format `FINGERPRINT:4:` |
| `hardgaming-revoked` | widerrufene Fingerabdrücke (eine Zeile je Schlüssel, sonst leer) |

Anleitung: [docs/PAKET-REPO.md](../docs/PAKET-REPO.md)
