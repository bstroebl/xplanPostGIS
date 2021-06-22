# Einführung

Dieses Projekt implementiert den Standard XPlanung in PostgreSQL/PostGIS.

# Installation

## Vorbereitung
Die Geometriefelder werden in der Projektion ETRS89, UTM32 (EPSG:25832) angelegt. Soll eine andere Projektion benutzt werden, ist in den Skripten _XP_Basisschema.sql, BP_Fachschema_BPlan.sql, FP_Fachschema_FPlan.sql, LP_Fachschema_LPlan.sql, RP_Fachschema_Raumordnungsplan.sql_ und _SO_Fachschema_SonstigePlaene.sql_ der EPSG-Code 25832 bei der Definition der Geometriefelder durch den gewünschen EPSG-Code zu ersetzen. Dies kann z.B. mit `find ./*.sql -type f -exec sed -i 's/25832/25833/g' {} \;` erfolgen.
Auf jedem Server müssen einmalig die Gruppenrollen angelegt werden. Dafür ist das Skript _DB_User.sql_ auszuführen.

## Durchführung
Nun muss zuerst _XP_Basisschema.sql_ ausgeführt werden, danach können die einzelnen Fachschemata angelegt werden. Es wird empfohlen, alle (also auch die voraussichtlich nicht gebrauchten) Fachschemata anzulegen.
Soll mit dem xplanplugin für QGIS gearbeitet werden, sind alle *QGIS.sql - Dateien auszuführen.
Die komplette Anlage einer neuen Datenbank (ohne Gruppenrollen) kann auch über das Shellskript _createdb.sh_ vorgenommen werden. Im Shellskript ist `<neue_db>` durch den Namen der anzulegenden Datenbank und `<pfad_zu_skripten>` durch den entsprechenden Pfad zu ersetzen.

# Version

Dieses Projekt implementiert den Standard XPlanung 5.2. Die Vorgängerstandards sind in eigenen Branches abgelegt.

## Bugfixes und Verbesserungen
Die Branch `master` enthält immer den aktuellen Stand des Projekts, eine Installation mit den darin enthaltenen Skripten erzeugt also eine Datenbank mit allen Verbesserungen und Bugfixes, die zu diesem Zeitpunkt vorhanden sind. Im Unterschied dazu sind in einer Versionsbranch die Installationsskripte zum Releasezeitpunkt enthalten (dies gilt leider erst seit Version 5.2!). Hat ein Installationsskript Syntaxfehler, werden sie nach Bekanntwerden darin gefixt. Alle anderen Bugfixes (inhaltlicher Art) und Verbesserungen sind in der Datei `fix_<version>.sql` enthalten. Wenn Sie keine Probleme mit den dort behobenen Bugs haben (z.B. weil Sie fehlende Enumerationswerte nicht benötigen) oder die Verbesserungen nicht brauchen, können Sie das Skript erst vor dem Wechsel auf die nächste Version der DB machen. Benötigen Sie einen Bufix, führen Sie `fix_<version>.sql` zum aktuellen Zeitpunkt aus. Vor einem Wechsel auf die nächste Version müssen Sie dann zunächst alle noch ausstehenden Bugfixes ausführen.

## Upgrade auf neuere Version
Eine Umstellung einer vorhandenen XPlanung 5.1-Datenbank auf XPlanung 5.2 erfolgt mit dem Konvertierungsskript `51zu52.sql`; ältere Datenbanken müssen Version für Version umgestellt werden. Vor der Ausführung von `51zu52.sql` sollten Sie - falls noch nicht geschehen - das Skript `fix_51.sql` ausführen, damit Ihre 5.1-Datenbank den vom Konvertierungsskript erwarteten Stand hat. Je nach Zeitpunkt Ihrer 5.1-Installation sind aber bereits einige der in `fix_51.sql` enthaltenen Bugfixes und Verbesserungen in Ihrer Datenbank bereits vorhanden. Gehen Sie deshalb einzeln vor und entfernen Sie alle Änderungen, die entsprechende Fehler werfen.
Das Konvertierungsskript `51zu52.sql` sollte ebenfalls möglichst nicht als ganzes, sondern jeder CR (ChangeRequest) einzeln ausgeführt werden, so dass leichter auf mögliche Fehler reagiert werden kann. Die Skripte sind zwar getestet aber in einer bestehenden Datenbank könnten Datensätze vorhanden sein, die andere Attribute belegen, als es die Testdatensätze des Authors tun.
Das Arbeiten in einer Kopie der eigenen Datenbank bzw. das Erzeugen eines aktuellen Dumps ist natürlich auch immer eine gute Idee....

# Importfunktion des QGIS-Plugins
Ein Import funktioniert nur in eine Datenbank Version 5.1 oder neuer.
Um mit dem XPlanung-Plugin für QGIS Pläne importieren zu können, müssen auf der Datenbank die beiden Funktionen `imp_create_schema()`) und `imp_create_xp_gid()` aus QGIS.sql vorhanden sein. Sind in den Plänen CodeList-Einträge vorhanden, muß das entsprechende Feature aus `fix_52.sql` in der Datenbank implementiert sein.
