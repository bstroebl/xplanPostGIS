/* *************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 ************************************************************************* */

-- *****************************************************
-- CREATE Views für XP
-- *****************************************************

-- -----------------------------------------------------
-- View "XP_Praesentationsobjekte"."XP_TPO_qv"
-- -----------------------------------------------------

CREATE OR REPLACE VIEW "XP_Praesentationsobjekte"."XP_TPO_qv" AS
SELECT p.gid, s."Bezeichner" as "stylesheet", b."schriftinhalt", b."fontSperrung",
	b."skalierung", b."horizontaleAusrichtung", b."vertikaleAusrichtung"
FROM "XP_Praesentationsobjekte"."XP_TPO" b
    JOIN "XP_Praesentationsobjekte"."XP_AbstraktesPraesentationsobjekt" p ON b.gid = p.gid
    LEFT JOIN "XP_Praesentationsobjekte"."XP_StylesheetListe" s ON p."stylesheetId" = s."Code";

GRANT SELECT ON TABLE "XP_Praesentationsobjekte"."XP_TPO_qv" TO xp_gast;

-- -----------------------------------------------------
-- View "XP_Praesentationsobjekte"."XP_Nutzungsschablone_qv"
-- -----------------------------------------------------

CREATE OR REPLACE VIEW "XP_Praesentationsobjekte"."XP_Nutzungsschablone_qv" AS
SELECT p.*, b.position::geometry(Multipoint, 25832), b."drehwinkel", b."spaltenAnz", b."zeilenAnz"
FROM "XP_Praesentationsobjekte"."XP_Nutzungsschablone" b
    JOIN "XP_Praesentationsobjekte"."XP_TPO_qv" p ON b.gid = p.gid;

GRANT SELECT ON TABLE "XP_Praesentationsobjekte"."XP_Nutzungsschablone_qv" TO xp_gast;

-- -----------------------------------------------------
-- View "XP_Praesentationsobjekte"."XP_PTO_qv"
-- -----------------------------------------------------

CREATE OR REPLACE VIEW "XP_Praesentationsobjekte"."XP_PTO_qv" AS
SELECT p.*, b.position::geometry(Multipoint, 25832), b."drehwinkel"
FROM "XP_Praesentationsobjekte"."XP_PTO" b
    JOIN "XP_Praesentationsobjekte"."XP_TPO_qv" p ON b.gid = p.gid;

GRANT SELECT ON TABLE "XP_Praesentationsobjekte"."XP_PTO_qv" TO xp_gast;