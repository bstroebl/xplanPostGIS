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

Dieses Projekt implementiert den Standard XPlanung 5.1. Die Vorgängerstandards 5.0.1 und 4.1 sind in eigenen Branches abgelegt.
Eine Umstellung einer vorhandenen XPlanung 4.1-Datenbank auf XPlanung 5.1 erfolgt mit den Konvertierungsskripten 4zu5.sql und 50zu51.sql; für eine Umstellung von 5.0.1 auf 5.1 ist nur 50zu51.sql auszuführen.
Dabei sollten die Skripte möglichst nicht als ganzes, sondern jeder CR (ChangeRequest) einzeln ausgeführt werden, so dass leichter auf mögliche Fehler reagiert werden kann. Die Skripte sind zwar getestet aber in einer bestehenden Datenbank könnten Datensätze vorhanden sein, die andere Attribute belegen, als es die Testdatensätze des Authors tun.
Vor der Ausführung der Konvertierungsskripte sind bisher noch nicht angelegte Fachschematas anzulegen, da sonst einzelne Teile des Skripts, die sich mit diesen Schematas beschäftigen, auskommentiert werden müssten.

## Bugfixes
Im Laufe der Zeit fallen verschiedene Fehler in der DB auf. Die Installationsskripte enthalten immer den aktuellen Stand mit Bugfixes. Alle Bugfixes sind auch im nächsten Updateskript enthalten, für eine 5.1-Datenbank also z.B. das Updateskript auf 5.2. Für die Funktion u.U. kritische Bugfixes sind in der Datei `fix_51.sql` enthalten. Wenn Sie keine Probleme mit den behobenen Bugs haben (z.B. weil Sie fehlende Enumerationswerte nicht brauchen), sollten Sie die Bugfixes mit dem Wechsel auf die nächste Version der DB machen. Wenn Sie die DB mit den aktuellen Skripten anlegen und dann auf die nächste Version updaten, können beim Update Fehler auftreten (z.B. weil Ihre DB die fehlenden Enumerationswerte bereits enthält).
Dieses Vorgehen wird zukünftig geändert.

# Importfunktion des QGIS-Plugins
Um mit dem XPlanung-Plugin für QGIS Pläne importieren zu können, müssen auf der Datenbank die beiden Funktionen `imp_create_schema()`) und `imp_create_xp_gid()` aus QGIS.sql vorhanden sein.
