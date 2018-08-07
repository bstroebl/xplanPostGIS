# Einführung

Dieses Projekt implementiert den Standard XPlanung in PostgreSQL/PostGIS.

# Installation

## Vorbereitung
Die Geometriefelder werden in der Projektion ETRS89, UTM32 (EPSG:25832) angelegt. Soll eine andere Projektion benutzt werden, ist in den Skripten _XP_Basisschema.sql, BP_Fachschema_BPlan.sql, FP_Fachschema_FPlan.sql, LP_Fachschema_LPlan.sql, RP_Fachschema_Raumordnungsplan.sql_ und _SO_Fachschema_SonstigePlaene.sql_ der EPSG-Code 25832 bei der Definition der Geometriefelder durch den gewünschen EPSG-Code zu ersetzen.
Auf jedem Server müssen einmalig die Gruppenrollen angelegt werden. Dafür ist das Skript _DB_User.sql_ auszuführen.

## Durchführung
Nun muss zuerst _XP_Basisschema.sql_ ausgeführt werden, danach können die einzelnen Fachschemata angelegt werden. Es wird empfohlen, alle (also auch die voraussichtlich nicht gebrauchten) Fachschemata anzulegen.
Soll mit dem xplanplugin für QGIS gearbeitet werden, sind alle *QGIS.sql - Dateien auszuführen.
Die komplette Anlage einer neuen Datenbank (ohne Gruppenrollen) kann auch über das Shellskript _createdb.sh_ vorgenommen werden. Im Shellskript ist `<neue_db>` durch den Namen der anzulegenden Datenbank und `<pfad_zu_skripten>` durch den entsprechenden Pfad zu ersetzen.

# Version

Dieses Projekt implementiert den Standard XPlanung 5.0.1. Der Vorgängerstandard ist in der Branch
[xplan_4_1](https://github.com/bstroebl/xplanPostGIS/tree/xplan_4_1) abgelegt. Eine Umstellung einer vorhandenen XPlanung 4.1-Datenbank auf XPlanung 5.0 erfolgt mit dem Script 4zu5.sql.
Dabei sollte das Script nicht als ganzes, sondern jeder CR (ChangeRequest) einzeln ausgeführt werden. Vor der Ausführung sind bisher noch nicht angelegte Fachschematas anzulegen, da sonst einzelne Teile des Skripts, die sich mit diesen Schematas beschäftigen, auskommentiert werden müssten.
