# Hard Gaming Family – Architekturentwurf 0.1

## Grenzen
- Verwaltet ausschließlich Hard Gaming OS Computer; Smartphones und Browser sind ausschließlich Zugänge zum Elternportal.
- Eltern registrieren sich im Hard Gaming CMS. Das öffentliche CMS-Modul zeigt das Dashboard, verwendet vorhandene CMS-Sitzungen und ruft den privaten Family-Server ausschließlich serverseitig auf.
- Family-Server auf dem vServer hält Familien-/Gerätezuordnungen, Richtlinienrevisionen, Anfragen und Auditprotokolle.
- Lokaler Family Service auf dem PC setzt signierte bzw. authentifiziert bezogene Regeln durch, auch bei Netzunterbrechung.
- GameHub ist UI-Client, niemals alleinige Durchsetzungsinstanz.

## Kopplung
1. Ein Elternteil meldet sich im CMS an und legt ein Kinderprofil an.
2. Der Family Service erzeugt einen kurzlebigen Einmalcode, serverseitig an eine Geräteschlüsselidentität gebunden.
3. Eltern geben den Code im CMS ein; CMS prüft Familienmitgliedschaft und sendet Kopplungsanfrage an den Server.
4. Server gibt ein gerätegebundenes, widerrufbares Credential aus; Code wird verbraucht.
5. Gerät bestätigt die Zuordnung und holt Richtlinien mit Revision ab.

## Sicherheit / Datenschutz
- Browser erhält niemals Family-Server-Service-Token oder Geräte-Token.
- Autorisierung pro Familie und Gerät auf **jeder** API-Operation; keine bloße Prüfung der Geräte-ID.
- Elternkonten mit 2FA-Option, CSRF-Schutz im CMS, API-Rate-Limits, Auditlog und Gerätewiderruf.
- Regeln werden atomar und versionsgebunden gespeichert; Konflikte liefern HTTP 409.
- Kein Remote-Shell-Zugriff, keine beliebigen Befehle, keine Überwachung von Chat-Inhalten.
- Offline: zuletzt bestätigte Einschränkungen weiter anwenden; sichere Zeit-/Uhrmanipulationsbehandlung erforderlich.
- Linux-Privilegien trennen: unprivilegierte Oberfläche, minimal privilegierter Dienst; Kinder ohne Adminrechte.
- Durchsetzung gegen direkte Programmstarts, Desktop-Wechsel und andere Launcher muss gesondert getestet werden.

## Noch zu implementieren
Dies ist ein **API- und Architekturpaket**, keine produktive Family-Server-Implementierung, kein installierbares CMS-Modul und kein laufender Linux-Dienst.
Der OpenAPI-Entwurf dokumentiert zunächst CMS-zu-Server-Endpunkte; Geräteprotokoll, Datenbankschema, Fehlerformate und Identitätsfluss werden im nächsten Implementierungsschritt konkretisiert.
