# Wiesenzeit

Ein kleiner deutscher Farm-Idle-Prototyp für Godot **4.6.3**, mit Maus- und Touch-Bedienung. Keine externen Pakete oder Assets erforderlich.

## Spielen

`project.godot` in Godot importieren und F6/F5 (gesamtes Projekt: F5) drücken. Alternativ im Projektordner `godot --path .` ausführen.

Saat auswählen und ein freies Feld antippen. Nach der Wachstumszeit erneut tippen: Die Ernte wird sofort verkauft. Saat ist kostenlos. Neue Felder kosten zunehmend mehr; die Erntehilfe kostet 100 Münzen und pflanzt und erntet danach automatisch auf allen Feldern. Die ausgewählte Saat gilt für die nächste Pflanzung, bestehende Pflanzen wachsen zu Ende.

Drei Pflanzen: Karotte (8 s / 5 Münzen), Tomate (20 s / 15 Münzen), Kürbis (45 s / 40 Münzen). Maximal zwölf Felder. Das ist ein erster spielbarer Prototyp; Grafik, Ton und langfristige Spielbalance sind noch ausbaufähig.

## Spielstand

Automatisches Speichern alle fünf Sekunden und nach Aktionen nach `user://farm.json`. Beim Neustart werden bis zu acht Stunden vergangene Zeit berechnet. Ohne Erntehilfe reifen Pflanzen lediglich, mit Erntehilfe entstehen auch Münzen. Im Browser ist der Spielstand an Browser und Website gebunden; das Löschen der Website-Daten entfernt ihn. Keine Cloud-Synchronisierung.

## Tests

```sh
godot --headless --path . --editor --import --quit
godot --headless --path . --script tests/test_farm.gd
godot --headless --path . --script tests/test_ui.gd
```

Die Tests verwenden einen getrennten Spielstand; sie prüfen Wirtschaft, Wachstum, Automatisierung, Offline-Limit und die Bedienung der Oberfläche. Auf Maschinen mit schreibgeschütztem Benutzerverzeichnis XDG_CONFIG_HOME, XDG_CACHE_HOME und XDG_DATA_HOME auf beschreibbare Verzeichnisse setzen.

## Browser und Handy

Das Web-Exportprofil ist enthalten und verwendet den Compatibility-Renderer ohne Threads. In Godot die **zur Version passenden Exportvorlagen** installieren, `build/web` anlegen und über Projekt → Exportieren → Web exportieren. Den Export über HTTP(S) ausliefern, nicht als lokale HTML-Datei öffnen. Der Webexport kann auch auf dem Handy gespielt werden. Echte Browser- und Touch-Prüfungen stehen noch aus.

Native Android-/iOS-Pakete sind noch nicht konfiguriert. Android benötigt Exportvorlagen, Android SDK und einen eigenen Signierschlüssel; iOS benötigt zusätzlich macOS/Xcode. Keine Store-Veröffentlichung oder Monetarisierung eingerichtet.

## Struktur

- `scripts/farm.gd`: Wirtschaft, Zeitberechnung und Speicherung
- `scripts/main.gd`: skalierende Hochformat-Oberfläche
- `tests/`: ausführbare Headless-Tests

Im vorhandenen Checkout arbeiten; kein zusätzlicher Git-Worktree erforderlich.
