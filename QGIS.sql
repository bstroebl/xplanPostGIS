/* *************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 ************************************************************************* */

CREATE schema "QGIS";
COMMENT ON SCHEMA "QGIS" IS 'Hilfstabellen zur Nutzung von XPlan in QGIS';

GRANT USAGE ON SCHEMA "QGIS" TO xp_gast;

-- *****************************************************
-- tabblefunc enthält crosstab für Views
-- *****************************************************
CREATE EXTENSION tablefunc
  SCHEMA public
  VERSION "1.0";

-- *****************************************************
-- CREATE Sequences
-- *****************************************************

CREATE SEQUENCE "QGIS"."layer_id_seq"
   MINVALUE 1;
GRANT ALL ON TABLE "QGIS"."layer_id_seq" TO GROUP xp_user;

-- *****************************************************
-- CREATE TRIGGER FUNCTIONs
-- *****************************************************

CREATE OR REPLACE FUNCTION "QGIS"."XP_Bereich_Sperre"()
RETURNS trigger AS
$BODY$
 BEGIN
    INSERT INTO "QGIS"."XP_Bereich_gesperrt"("XP_Bereich_gid") VALUES (new.gid);
    RETURN new;
 END; $BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
GRANT EXECUTE ON FUNCTION "QGIS"."XP_Bereich_Sperre"() TO xp_user;

-- Funktion, die Änderungen in gesperrten Bereichen verhindert
-- Funktion noch nicht getestet, muß evtl noch angepasst, v.a. aber auf
-- die entsprechenden Tabellen angewendet werden!!

CREATE OR REPLACE FUNCTION "QGIS"."pruefe_Sperre"()
RETURNS trigger AS
$BODY$
DECLARE
  gesperrt integer;
  bereich_gid_fld varchar;
  objekt_gid_fld varchar;
BEGIN
    IF TG_TABLE_NAME = 'XP_Objekt_gehoertNachrichtlichZuBereich' THEN
        bereich_gid_fld := 'gehoertNachrichtlichZuBereich';
        objekt_gid_fld := 'XP_Objekt_gid';
    ELSIF TG_TABLE_NAME = 'FP_Objekt_gehoertZuFP_Bereich' THEN
        bereich_gid_fld := 'gehoertZuFP_Bereich';
        objekt_gid_fld := 'FP_Objekt_gid';
    ELSIF TG_TABLE_NAME = 'BP_Objekt_gehoertZuBP_Bereich' THEN
        bereich_gid_fld := 'gehoertZuBP_Bereich';
        objekt_gid_fld := 'BP_Objekt_gid';
    ELSIF TG_TABLE_NAME = 'LP_Objekt_gehoertZuLP_Bereich' THEN
        bereich_gid_fld := 'gehoertZuLP_Bereich';
        objekt_gid_fld := 'LP_Objekt_gid';
    ELSIF TG_TABLE_NAME = 'RP_Objekt_gehoertZuRP_Bereich' THEN
        bereich_gid_fld := 'gehoertZuRP_Bereich';
        objekt_gid_fld := 'RP_Objekt_gid';
    ELSIF TG_TABLE_NAME = 'SO_Objekt_gehoertZuSO_Bereich' THEN
        bereich_gid_fld := 'gehoertZuSO_Bereich';
        objekt_gid_fld := 'SO_Objekt_gid';
    END IF;

    --prüfen, ob das Objekt in einem gesperrten Bereich liegt
    IF (TG_OP = 'UPDATE') OR (TG_OP = 'INSERT') THEN
        EXECUTE 'SELECT COALESCE(CAST(g.gesperrt as integer), 0) as gesp FROM "QGIS"."XP_Bereich_gesperrt"
        WHERE "XP_Bereich_gid" = new.' || quote_ident(bereich_gid_fld) || ' LIMIT 1' INTO gesperrt;
    ELSIF (TG_OP = 'DELETE') THEN
        EXECUTE 'SELECT COALESCE(CAST(g.gesperrt as integer), 0) as gesp FROM "QGIS"."XP_Bereich_gesperrt"
        WHERE "XP_Bereich_gid" = old.' || quote_ident(bereich_gid_fld) || ' LIMIT 1' INTO gesperrt;
    END IF;

    IF gesperrt = 1 THEN
      RETURN NULL; -- Befehl wird nicht ausgeführt
    ELSE
      IF (TG_OP = 'UPDATE') OR (TG_OP = 'INSERT') THEN
        RETURN new;
      ELSIF (TG_OP = 'DELETE') THEN
        RETURN old;
      END IF;
    END IF;
END; $BODY$
LANGUAGE 'plpgsql' VOLATILE
COST 100;
GRANT EXECUTE ON FUNCTION "QGIS"."pruefe_Sperre"() TO xp_user;

-- *****************************************************
-- CREATE FUNCTION
-- *****************************************************

CREATE OR REPLACE FUNCTION "QGIS"."ObjektKopieren"(
    quellschema varchar,
    quelltabelle varchar,
    gid bigint,
    zielschema varchar,
    zieltabelle varchar)
RETURNS integer -- 1 = Erfolg, 0 = Fehler
AS
$BODY$
    DECLARE
        parent_nspname varchar;
        parent_relname varchar;
        rec record;
    BEGIN
        EXECUTE 'INSERT INTO ' || quote_ident(zielschema) || '.' || quote_ident(zieltabelle) ||
                'SELECT position FROM ' || quote_ident(zielschema) || '.' || quote_ident(zieltabelle) ||
                ' WHERE gid = ' || gid::varchar || ';';

    END;
$BODY$
LANGUAGE 'plpgsql' VOLATILE
COST 100;
GRANT EXECUTE ON FUNCTION "QGIS"."ObjektKopieren"(varchar, varchar ,bigint, varchar, varchar) TO xp_user;

CREATE OR REPLACE FUNCTION "QGIS"."imp_create_xp_gid"(nspname character varying, relname character varying)
  RETURNS integer AS
$BODY$
BEGIN
    EXECUTE 'ALTER TABLE ' ||
        quote_ident(nspname) || '.' || quote_ident(relname) ||
        ' ADD COLUMN xp_gid bigint;';
    RETURN 1;
END;
$BODY$
LANGUAGE plpgsql VOLATILE STRICT
COST 100;
GRANT EXECUTE ON FUNCTION "QGIS"."imp_create_xp_gid"(character varying, character varying) TO xp_user;
COMMENT ON FUNCTION "QGIS"."imp_create_xp_gid"(character varying, character varying) IS 'Legt in der übergebenen Tabelle ein bigint-Feld xp_gid an; Funktion ist nötig, da der ALTER TABLE-Befehl aus QGIS selbst über QtSql nicht geht :-(';

CREATE OR REPLACE FUNCTION "QGIS".imp_create_schema(
    nspname character varying)
    RETURNS integer AS
$BODY$
BEGIN
    EXECUTE 'DROP SCHEMA IF EXISTS ' ||
        quote_ident(nspname) || ' CASCADE;';
    EXECUTE 'CREATE SCHEMA ' ||
        quote_ident(nspname) || ' ;';
    RETURN 1;
END;
$BODY$
LANGUAGE 'plpgsql' VOLATILE
COST 100;
GRANT EXECUTE ON FUNCTION "QGIS".imp_create_schema(character varying) TO xp_user;
COMMENT ON FUNCTION "QGIS".imp_create_schema(character varying)
    IS 'Legt übergebenes Schema neu an; Funktion ist nötig, da der CREATE-Befehl aus QGIS selbst über QtSql nicht geht :-(';

-- *****************************************************
-- CREATE TABLEs
-- *****************************************************

-- -----------------------------------------------------
-- Table "QGIS"."layer"
-- -----------------------------------------------------
CREATE  TABLE  "QGIS"."layer" (
  "id" INTEGER NOT NULL ,
  "schemaname" VARCHAR(45) NOT NULL ,
  "tablename" VARCHAR(45) NOT NULL ,
  "style" TEXT NOT NULL ,
  "XP_Bereich_gid" BIGINT NULL ,
  "loadorder" INTEGER NULL,
  "default_color" character varying(16),
  PRIMARY KEY ("id") ,
  CONSTRAINT "fk_layer_XP_Bereich1"
    FOREIGN KEY ("XP_Bereich_gid" )
    REFERENCES "XP_Basisobjekte"."XP_Bereich" ("gid" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "onlyOneStyle" UNIQUE (schemaname , tablename , "XP_Bereich_gid"));
  -- NULL in XP_Bereich_gid kann mehrfach vorkommen!

CREATE INDEX "idx_fk_layer_XP_Bereich1_idx" ON "QGIS"."layer" ("XP_Bereich_gid") ;
-- UNIQUE Indices, um den UNIQUE-Constraint auch bei XP_Bereich_gid = NULL sicherzustellen
-- siehe http://stackoverflow.com/questions/8289100/create-unique-constraint-with-null-columns
CREATE UNIQUE INDEX layer_3col_uni_idx ON "QGIS".layer (schemaname, tablename, "XP_Bereich_gid")
    WHERE "XP_Bereich_gid" IS NOT NULL;
CREATE UNIQUE INDEX layer_2col_uni_idx ON "QGIS".layer (schemaname, tablename)
    WHERE "XP_Bereich_gid" IS NULL;
GRANT SELECT ON TABLE "QGIS"."layer" TO xp_gast;
GRANT ALL ON TABLE "QGIS"."layer" TO xp_user;
COMMENT ON TABLE  "QGIS"."layer" IS 'Layersteuerung für QGIS; für einzelne Layer kann ein Stil (qml-xml) definiert werden, der angewendet wird, wenn dieser Layer in diesen Bereich geladen wird. Die loadorder legt optional fest, in welcher Reihenfolge die Layer geladen werden sollen (wichtig bei sich überlagernden Polygonlayern). Unabhängig von den hier getroffenen Einstellungen wird ein Layer nur in einen Bereich geladen, wenn er dafür Objekte hat.';
SELECT "XP_Basisobjekte".ensure_sequence('QGIS', 'layer', 'id');


-- -----------------------------------------------------
-- Table "QGIS"."XP_Bereich_gesperrt"
-- -----------------------------------------------------
CREATE  TABLE  "QGIS"."XP_Bereich_gesperrt" (
  "XP_Bereich_gid" BIGINT NOT NULL ,
  "gesperrt" BOOLEAN  NOT NULL DEFAULT false ,
  PRIMARY KEY ("XP_Bereich_gid") ,
  CONSTRAINT "fk_XP_Bereich_gesperrt_XP_Bereich1"
    FOREIGN KEY ("XP_Bereich_gid" )
    REFERENCES "XP_Basisobjekte"."XP_Bereich" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE);
CREATE INDEX "idx_fk_XP_Bereich_gesperrt_XP_Bereich1" ON "QGIS"."XP_Bereich_gesperrt" ("XP_Bereich_gid") ;
GRANT SELECT ON TABLE "QGIS"."XP_Bereich_gesperrt" TO xp_gast;
GRANT ALL ON TABLE "QGIS"."XP_Bereich_gesperrt" TO xp_user;

-- -----------------------------------------------------
-- Table "QGIS"."HorizontaleAusrichtung"
-- -----------------------------------------------------
CREATE  TABLE  "QGIS"."HorizontaleAusrichtung" (
  "Code" VARCHAR(64) NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Code") ,
  CONSTRAINT "fk_HorizontaleAusrichtung1"
    FOREIGN KEY ("Code" )
    REFERENCES "XP_Praesentationsobjekte"."XP_HorizontaleAusrichtung" ("Code" )
    ON DELETE CASCADE
    ON UPDATE CASCADE);

CREATE INDEX "idx_fk_HorizontaleAusrichtung1" ON "QGIS"."HorizontaleAusrichtung" ("Code") ;
GRANT SELECT ON TABLE "QGIS"."HorizontaleAusrichtung" TO xp_gast;

-- -----------------------------------------------------
-- Table "QGIS"."VertikaleAusrichtung"
-- -----------------------------------------------------
CREATE  TABLE  "QGIS"."VertikaleAusrichtung" (
  "Code" VARCHAR(64) NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Code") ,
  CONSTRAINT "fk_VertikaleAusrichtung1"
    FOREIGN KEY ("Code" )
    REFERENCES "XP_Praesentationsobjekte"."XP_VertikaleAusrichtung" ("Code" )
    ON DELETE CASCADE
    ON UPDATE CASCADE);

CREATE INDEX "idx_fk_VertikaleAusrichtung1" ON "QGIS"."VertikaleAusrichtung" ("Code") ;
GRANT SELECT ON TABLE "QGIS"."VertikaleAusrichtung" TO xp_gast;

-- *****************************************************
-- Amend Tables
-- *****************************************************
CREATE TRIGGER "XP_Bereich_hasInsert" AFTER INSERT ON "XP_Basisobjekte"."XP_Bereich" FOR EACH ROW EXECUTE PROCEDURE "QGIS"."XP_Bereich_Sperre"();

-- *****************************************************
-- CREATE Views
-- *****************************************************

-- -----------------------------------------------------
-- View "QGIS"."XP_Bereiche"
-- -----------------------------------------------------
CREATE  OR REPLACE VIEW "QGIS"."XP_Bereiche" AS
SELECT xb.gid, xb.name as bereichsname, xp.gid as plangid, xp.name as planname, xp."Objektart" as planart,
xp.beschreibung, xp."technHerstellDatum", xp."untergangsDatum"
FROM "XP_Basisobjekte"."XP_Bereich" xb
JOIN (
SELECT gid, "gehoertZuPlan" FROM "FP_Basisobjekte"."FP_Bereich"
UNION SELECT gid, "gehoertZuPlan" FROM "BP_Basisobjekte"."BP_Bereich"
UNION SELECT gid, "gehoertZuPlan" FROM "LP_Basisobjekte"."LP_Bereich"
UNION SELECT gid, "gehoertZuPlan" FROM "SO_Basisobjekte"."SO_Bereich"
) b ON xb.gid = b.gid
JOIN "XP_Basisobjekte"."XP_Plaene" xp ON b."gehoertZuPlan" = xp.gid;
GRANT SELECT ON TABLE "QGIS"."XP_Bereiche" TO xp_gast;
COMMENT ON VIEW "QGIS"."XP_Bereiche" IS 'Zusammenstellung der Pläne mit ihren Bereichen, wenn einzelne
Fachschemas nicht installiert sind, ist der View anzupassen!';

-- -----------------------------------------------------
-- Data for table "QGIS"."HorizontaleAusrichtung"
-- -----------------------------------------------------
INSERT INTO "QGIS"."HorizontaleAusrichtung" ("Code", "Bezeichner") VALUES ('linksbündig', 'Left');
INSERT INTO "QGIS"."HorizontaleAusrichtung" ("Code", "Bezeichner") VALUES ('rechtsbündig', 'Right');
INSERT INTO "QGIS"."HorizontaleAusrichtung" ("Code", "Bezeichner") VALUES ('zentrisch', 'Center');

-- -----------------------------------------------------
-- Data for table "QGIS"."VertikaleAusrichtung"
-- -----------------------------------------------------
INSERT INTO "QGIS"."VertikaleAusrichtung" ("Code", "Bezeichner") VALUES ('Basis', 'Base');
INSERT INTO "QGIS"."VertikaleAusrichtung" ("Code", "Bezeichner") VALUES ('Mitte', 'Half');
INSERT INTO "QGIS"."VertikaleAusrichtung" ("Code", "Bezeichner") VALUES ('Oben', 'Top');

