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
Eine Umstellung einer vorhandenen XPlanung 5.1-Datenbank auf XPlanung 5.2 erfolgt mit dem Konvertierungsskript `51zu52.sql`; ältere Datenbanken müssen Version für Version umgestellt werden. Vor der Ausführung von `51zu52.sql` sollten Sie - falls noch nicht geschehen - das Skript `fix_51.sql` ausführen, damit Ihre 5.1-Datenbank den vom Konvertierungsskript erwarteten Stand hat.
Das Konvertierungsskript sollte möglichst nicht als ganzes, sondern jeder CR (ChangeRequest) einzeln ausgeführt werden, so dass leichter auf mögliche Fehler reagiert werden kann. Die Skripte sind zwar getestet aber in einer bestehenden Datenbank könnten Datensätze vorhanden sein, die andere Attribute belegen, als es die Testdatensätze des Authors tun.
Das Arbeiten in einer Kopie der eigenen Datenbank bzw. das Erzeugen eines aktuellen Dumps ist natürlich auch immer eine gute Idee....

## Bugfixes
Im Laufe der Zeit fallen verschiedene Fehler in der DB auf. Die Installationsskripte enthalten immer den Stand zum Releasezeitpunkt. Hat ein Installationsskript Syntaxfehler, werden sie nach Bekanntwerden darin gefixt. Alle anderen Bugfixes (inhaltlicher Art) sind in der Datei `fix_52.sql` enthalten. Wenn Sie keine Probleme mit den dort behobenen Bugs haben (z.B. weil Sie fehlende Enumerationswerte nicht brauchen), sollten Sie die Bugfixes erst gesammelt vor dem Wechsel auf die nächste Version der DB machen. Benötigen Sie einen Bufix, führen Sie `fix_52.sql` zum aktuellen Zeitpunkt aus. Vor einem Wechsel auf die nächste Version müssen Sie dann zunächst alle noch ausstehenden Bugfixes ausführen.

# Importfunktion des QGIS-Plugins
Um mit dem XPlanung-Plugin für QGIS Pläne importieren zu können, müssen auf der Datenbank die beiden Funktionen `imp_create_schema()`) und `imp_create_xp_gid()` aus QGIS.sql vorhanden sein.
