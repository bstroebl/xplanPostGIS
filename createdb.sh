#!/bin/bash
createdb <neue_db>
psql <neue_db> -c "create extension postgis"
psql <neue_db> -a -f <pfad_zu_skripten>/XP_Basisschema.sql > XP_Basisschema.log 2>&1
psql <neue_db> -a -f <pfad_zu_skripten>/BP_Fachschema_BPlan.sql > BP_Fachschema_BPlan.log 2>&1
psql <neue_db> -a -f <pfad_zu_skripten>/FP_Fachschema_FPlan.sql > FP_Fachschema_FPlan.log 2>&1
psql <neue_db> -a -f <pfad_zu_skripten>/LP_Fachschema_LPlan.sql > LP_Fachschema_LPlan.log 2>&1
psql <neue_db> -a -f <pfad_zu_skripten>/RP_Fachschema_Regionalplan.sql > RP_Fachschema_Regionalplan.log 2>&1
psql <neue_db> -a -f <pfad_zu_skripten>/SO_Fachschema_SonstigePlaene.sql > SO_Fachschema_SonstigePlaene.log 2>&1
psql <neue_db> -a -f <pfad_zu_skripten>/QGIS.sql > QGIS.log 2>&1
psql <neue_db> -a -f <pfad_zu_skripten>/XP_QGIS.sql > XP_QGIS.log 2>&1
psql <neue_db> -a -f <pfad_zu_skripten>/BP_QGIS.sql > BP_QGIS.log 2>&1
psql <neue_db> -a -f <pfad_zu_skripten>/FP_QGIS.sql > FP_QGIS.log 2>&1
psql <neue_db> -a -f <pfad_zu_skripten>/LP_QGIS.sql > LP_QGIS.log 2>&1
psql <neue_db> -a -f <pfad_zu_skripten>/SO_QGIS.sql > SO_QGIS.log 2>&1
psql <neue_db> -a -f <pfad_zu_skripten>/layer_styles_QGIS.sql > layer_styles_QGIS.log 2>&1
