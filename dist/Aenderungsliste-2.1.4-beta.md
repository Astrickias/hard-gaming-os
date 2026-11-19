# 2.1.4 Beta

- Neuer Eintrag im Startmenü: „Diagnose: seriell, ohne Splash“ für den normalen und den LTS-Kernel. Damit lässt sich ein Startproblem genau nachvollziehen, statt nur einen dunklen Bildschirm zu sehen.
- Die Anmeldung im Live-System wird fest mit dem Plasma Login Manager verbunden. Fehlt er, bricht der Build ab, statt ein Image zu liefern, das nach dem Startmenü hängen bleibt.
- Eigene Startanpassungen von CachyOS werden nicht mehr überschrieben. Hard Gaming OS hängt seine Schritte nur noch an.
- Fehlt die Anmeldekonfiguration der Basis, bricht der Build mit einer klaren Meldung ab.
- Neues Testwerkzeug `scripts/vm-test.sh`: startet ISO oder installierte Platte in QEMU (UEFI und BIOS), zeichnet das serielle Startprotokoll auf und erstellt echte VM-Screenshots.
- Die automatische Prüfung testet jetzt auch die Startmenü-Einträge und beide Links in Hello.
- Versionsangaben auf 2.1.4 Beta angehoben.

Hinweis: Diese Version wurde noch nicht als ISO gebaut und gebootet.
