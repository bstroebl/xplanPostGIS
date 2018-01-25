# Einführung

Dieses Projekt implementiert den Standard XPlanung in PostgreSQL/PostGIS.

# Installation

Zuerst muß XP_Basisschema.sql ausgeführt werden, danach können die Fachschemata angelegt werden. Es wird empfohlen, alle, also auch die voraussichtlich nicht gebrauchten, Fachschemata anzulegen.
Soll mit dem xplanplugin für QGIS gearbeitet werden, sind alle *QGIS.sql - Dateien auszuführen.

# Version

Dieses Projekt implementiert den Standard XPlanung 5.0. Der Vorgängerstandard ist in der Branch
[xplan_4_1](https://github.com/bstroebl/xplanPostGIS/tree/xplan_4_1) abgelegt. Eine Umstellung einer vorhandenen XPlanung 4.1-Datenbank auf XPlanung 5.0 erfolgt mit dem Script 4zu5.sql.
Dabei sollte das Script nicht als ganzes, sondern jeder CR (ChangeRequest) einzeln ausgeführt werden. Vor der Ausführung sind bisher noch nicht angelegte Fachschematas anzulegen, da sonst einzelne Teile des Skripts, die sich mit diesen Schematas beschäftigen, auskommentiert werden müssten.
