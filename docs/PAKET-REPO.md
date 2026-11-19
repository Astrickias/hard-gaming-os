# Paket-Repo [hardgaming]

Hard Gaming OS bezieht seine eigenen Pakete (`hgos-keyring`, `hgos-branding`, `hgos-update-center`, `hgos-umstieg`, später `hgos-konsole`) aus dem signierten pacman-Repo `[hardgaming]`. Updates kommen damit über `pacman -Syu` bzw. das Update Center.

- Adresse: `https://astrickias.github.io/hard-gaming-os/$arch` (in `config/release.env`, später z. B. `repo.hardgaming.net`)
- Gebaut und signiert von `.github/workflows/pakete.yml` bei jedem Versions-Tag `v*`
- `hgos-keyring` bringt den öffentlichen Schlüssel mit und trägt `[hardgaming]` in `/etc/pacman.conf` ein; beim Entfernen wird der Eintrag wieder gelöscht.

## Einmalige Einrichtung (Hard Gaming Labs)

### 1. Signaturschlüssel erzeugen (auf dem eigenen PC)

```bash
gpg --quick-gen-key "Hard Gaming OS Pakete <Astrickias@users.noreply.github.com>" ed25519 sign 3y
```

Bei der Passphrase-Abfrage **leer lassen** (zweimal Enter): Der Schlüssel liegt später als GitHub-Secret, das nur der Workflow lesen kann. Fingerabdruck anzeigen:

```bash
gpg --list-secret-keys --with-colons "Hard Gaming OS Pakete" | awk -F: '/^fpr/ {print $10; exit}'
```

### 2. Öffentlichen Teil ins Repo

```bash
FPR=<Fingerabdruck>
gpg --armor --export "$FPR" > keys/hardgaming.gpg
echo "$FPR:4:" > keys/hardgaming-trusted
git add keys && git commit -m "Signaturschlüssel für das Paket-Repo" && git push
```

Zusätzlich auf einem Schlüsselserver veröffentlichen, damit neue Nutzer ihn finden:

```bash
gpg --keyserver keyserver.ubuntu.com --send-keys "$FPR"
```

### 3. Privaten Teil als GitHub-Secret

```bash
gpg --armor --export-secret-keys "$FPR" | gh secret set HGOS_GPG_PRIVATE_KEY --repo Astrickias/hard-gaming-os
```

Den privaten Schlüssel zusätzlich offline sichern (USB-Stick, Passwortmanager). **Nie** ins Repo, in Chats oder Mails.

### 4. GitHub Pages einschalten

Repo → **Settings → Pages → Source: GitHub Actions**.

### 5. Erster Lauf

Nach dem Merge der Version einen Tag setzen und pushen. Unter **Actions → Pakete** läuft dann der Build. Danach ist das Repo erreichbar: `https://astrickias.github.io/hard-gaming-os/x86_64/hardgaming.db`.

## Umstieg über das Repo (für Nutzer)

```bash
sudo pacman-key --recv-keys <Fingerabdruck> --keyserver keyserver.ubuntu.com
sudo pacman-key --lsign-key <Fingerabdruck>
sudo pacman -U https://astrickias.github.io/hard-gaming-os/x86_64/hgos-keyring-<Version>-1-any.pkg.tar.zst
sudo pacman -Sy hgos-umstieg
```

Ab dann kommen alle Hard-Gaming-Pakete mit normalen Updates.

## Schlüssel wechseln oder widerrufen

Neuen Schlüssel erzeugen, `keys/hardgaming.gpg` und `keys/hardgaming-trusted` ersetzen, alten Fingerabdruck in `keys/hardgaming-revoked` eintragen, Secret aktualisieren, neue Version taggen. `hgos-keyring` verteilt den Wechsel an alle Systeme.
