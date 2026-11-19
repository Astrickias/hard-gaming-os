# Family-Testplan
- Unberechtigtes Elternkonto kann weder Geräte noch Regeln fremder Familien lesen/ändern.
- Kopplungscode ist einmalig, kurzlebig, rate-limitiert und an das Zielgerät gebunden.
- Widerruf sperrt weitere Synchronisierung des Geräts.
- Regelrevision verhindert verlorene Updates bei parallelen Änderungen.
- Offline-Zeitlimit und Ruhezeiten gelten nach Neustart weiter.
- Desktopwechsel und direkte Launcherstarts umgehen die Einschränkungen nicht.
- Nach Zeitablauf werden Spiele sicher beendet oder gesperrt, ohne Datenverlust durch abruptes Abschalten.
- Uhrzeit-/Zeitzonenwechsel und Suspend/Resume werden getestet.
- Auditlog enthält keine unnötigen personenbezogenen Inhalte.
