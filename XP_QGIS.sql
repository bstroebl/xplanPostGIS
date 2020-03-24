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
-- Table "QGIS"."XP_StylesheetParameter"
-- -----------------------------------------------------
CREATE  TABLE  "QGIS"."XP_StylesheetParameter" (
  "Code" INTEGER NOT NULL ,
  "strichfarbe" VARCHAR(16),
  "strichbreite" REAL,
  "fuellfarbe" VARCHAR(16),
  "textstil" VARCHAR(32),
  "SVG_Symbol" VARCHAR(256),
  "darstellungsprioritaet" INTEGER,
  PRIMARY KEY ("Code"),
CONSTRAINT "fk_XP_stylesheetliste"
    FOREIGN KEY ("Code" )
    REFERENCES "XP_Praesentationsobjekte"."XP_StylesheetListe" ("Code" )
    ON DELETE CASCADE
    ON UPDATE CASCADE  );
    
COMMENT ON COLUMN "QGIS"."XP_StylesheetParameter"."strichfarbe" IS 'Farbe der (Rand-)Line oder des Textes, Eingabe als Hashcode';
COMMENT ON COLUMN "QGIS"."XP_StylesheetParameter"."strichbreite" IS 'Dicke der (Rand-)Linie';
COMMENT ON COLUMN "QGIS"."XP_StylesheetParameter"."fuellfarbe" IS 'Farbe der Flächenfüllung, Eingabe als Hashcode';
COMMENT ON COLUMN "QGIS"."XP_StylesheetParameter"."textstil" IS 'Schriftart, englisch: Normal, Bold, Bold Italic oder Italic';
COMMENT ON COLUMN "QGIS"."XP_StylesheetParameter"."SVG_Symbol" IS 'Dateiname der SVG-Datei; die Datei muß in einem der SVG_Suchpfade liegen';
COMMENT ON COLUMN "QGIS"."XP_StylesheetParameter"."darstellungsprioritaet" IS 'Darstellungsprioritaet';

GRANT SELECT ON TABLE "QGIS"."XP_StylesheetParameter" TO xp_gast;
GRANT ALL ON TABLE "QGIS"."XP_StylesheetParameter" TO xp_user;

-- -----------------------------------------------------
-- View "XP_Praesentationsobjekte"."XP_AbstraktesPraesentationsobjekt_qv"
-- -----------------------------------------------------

CREATE OR REPLACE VIEW "XP_Praesentationsobjekte"."XP_AbstraktesPraesentationsobjekt_qv" AS
SELECT p.gid, s."Bezeichner" as "stylesheet", sp.*
FROM "XP_Praesentationsobjekte"."XP_AbstraktesPraesentationsobjekt" p
    LEFT JOIN "XP_Praesentationsobjekte"."XP_StylesheetListe" s ON p."stylesheetId" = s."Code"
    LEFT JOIN "QGIS"."XP_StylesheetParameter" sp ON p."stylesheetId" = sp."Code";

GRANT SELECT ON TABLE "XP_Praesentationsobjekte"."XP_AbstraktesPraesentationsobjekt_qv" TO xp_gast;

-- -----------------------------------------------------
-- View "XP_Praesentationsobjekte"."XP_TPO_qv"
-- -----------------------------------------------------

CREATE OR REPLACE VIEW "XP_Praesentationsobjekte"."XP_TPO_qv" AS
SELECT p.*, b."schriftinhalt", b."fontSperrung",
	b."skalierung", COALESCE(ha."Bezeichner",'left')::varchar(64) as "horizontaleAusrichtung", COALESCE(va."Bezeichner",'Half')::varchar(64) as "vertikaleAusrichtung"
FROM "XP_Praesentationsobjekte"."XP_TPO" b
    JOIN "QGIS"."HorizontaleAusrichtung" ha ON b."horizontaleAusrichtung" = ha."Code"
    LEFT JOIN "QGIS"."VertikaleAusrichtung" va ON b."vertikaleAusrichtung" = va."Code"
    LEFT JOIN "XP_Praesentationsobjekte"."XP_AbstraktesPraesentationsobjekt_qv" p ON b.gid = p.gid;
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

-- -----------------------------------------------------
-- View "XP_Praesentationsobjekte"."XP_LTO_qv"
-- -----------------------------------------------------

CREATE OR REPLACE VIEW "XP_Praesentationsobjekte"."XP_LTO_qv" AS
SELECT p.*, b.position::geometry(MultiLinestring, 25832)
FROM "XP_Praesentationsobjekte"."XP_LTO" b
    JOIN "XP_Praesentationsobjekte"."XP_TPO_qv" p ON b.gid = p.gid;

GRANT SELECT ON TABLE "XP_Praesentationsobjekte"."XP_LTO_qv" TO xp_gast;

-- -----------------------------------------------------
-- View "XP_Praesentationsobjekte"."XP_FPO_qv"
-- -----------------------------------------------------

CREATE OR REPLACE VIEW "XP_Praesentationsobjekte"."XP_FPO_qv" AS
SELECT p.*, b.position::geometry(MultiPolygon, 25832)
FROM "XP_Praesentationsobjekte"."XP_FPO" b
    JOIN "XP_Praesentationsobjekte"."XP_AbstraktesPraesentationsobjekt_qv" p ON b.gid = p.gid;

GRANT SELECT ON TABLE "XP_Praesentationsobjekte"."XP_FPO_qv" TO xp_gast;

-- -----------------------------------------------------
-- View "XP_Praesentationsobjekte"."XP_LPO_qv"
-- -----------------------------------------------------

CREATE OR REPLACE VIEW "XP_Praesentationsobjekte"."XP_LPO_qv" AS
SELECT p.*, b.position::geometry(MultiLinestring, 25832)
FROM "XP_Praesentationsobjekte"."XP_LPO" b
    JOIN "XP_Praesentationsobjekte"."XP_AbstraktesPraesentationsobjekt_qv" p ON b.gid = p.gid;

GRANT SELECT ON TABLE "XP_Praesentationsobjekte"."XP_LPO_qv" TO xp_gast;

-- -----------------------------------------------------
-- View "XP_Praesentationsobjekte"."XP_PPO_qv"
-- -----------------------------------------------------

CREATE OR REPLACE VIEW "XP_Praesentationsobjekte"."XP_PPO_qv" AS
SELECT p.*, b.position::geometry(MultiPoint, 25832)
FROM "XP_Praesentationsobjekte"."XP_PPO" b
    JOIN "XP_Praesentationsobjekte"."XP_AbstraktesPraesentationsobjekt_qv" p ON b.gid = p.gid;

GRANT SELECT ON TABLE "XP_Praesentationsobjekte"."XP_PPO_qv" TO xp_gast;
