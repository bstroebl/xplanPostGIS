CREATE schema "QGIS";
COMMENT ON SCHEMA "QGIS" IS 'Hilfstabellen zur Nutzung von XPlan in QGIS';

GRANT USAGE ON SCHEMA "QGIS" TO xp_gast;

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

-- *****************************************************
-- CREATE TABLEs
-- *****************************************************

-- -----------------------------------------------------
-- Table "QGIS"."layer"
-- -----------------------------------------------------
CREATE  TABLE  "QGIS"."layer" (
  "id" INTEGER NOT NULL ,
  "schemaname" VARCHAR(45) NOT NULL ,
  "layername" VARCHAR(45) NOT NULL ,
  "style" TEXT NOT NULL ,
  "XP_Bereich_gid" INTEGER NULL ,
  "loadorder" INTEGER NULL,
  PRIMARY KEY ("id") ,
  CONSTRAINT "fk_layer_XP_Bereich1"
    FOREIGN KEY ("XP_Bereich_gid" )
    REFERENCES "XP_Basisobjekte"."XP_Bereich" ("gid" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "onlyOneStyle" UNIQUE (schemaname , layername , "XP_Bereich_gid");
  -- NULL in XP_Bereich_gid kann mehrfach vorkommen!

CREATE INDEX "idx_fk_layer_XP_Bereich1_idx" ON "QGIS"."layer" ("XP_Bereich_gid") ;
-- eventuell ist ein Index auf (schemaname , layername , "XP_Bereich_gid") performanter
-- CREATE INDEX "onlyOneStyle_idx" ON "QGIS"."layer" (schemaname , layername , "XP_Bereich_gid") ;
GRANT SELECT ON TABLE "QGIS"."layer" TO xp_gast;
GRANT ALL ON TABLE "QGIS"."layer" TO xp_user;
COMMENT ON TABLE  "QGIS"."layer" IS 'Layersteuerung für QGIS; für einzelne Layer kann ein Stil (qml-xml) definiert werden, der angewendet wird, wenn diser Layer in diesen Bereich geladen wird. Die loadorder legt optional fest, in welcher Reihenfolge die Layer geladen werden sollen (wichtig bei sich überlagernden Polygonlayern). Unabhängig von den hier getroffenen Einstellungen wird ein Layer nur in einen Bereich geladen, wenn er dafür Objekte hat.'
SELECT "XP_Basisobjekte".ensure_sequence('QGIS', 'layer', 'id');


-- -----------------------------------------------------
-- Table "QGIS"."XP_Bereich_gesperrt"
-- -----------------------------------------------------
CREATE  TABLE  "QGIS"."XP_Bereich_gesperrt" (
  "XP_Bereich_gid" INTEGER NOT NULL ,
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
  "Wert" VARCHAR(64) NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Wert") ,
  CONSTRAINT "fk_HorizontaleAusrichtung1"
    FOREIGN KEY ("Wert" )
    REFERENCES "XP_Praesentationsobjekte"."XP_HorizontaleAusrichtung" ("Wert" )
    ON DELETE CASCADE
    ON UPDATE CASCADE);

CREATE INDEX "idx_fk_HorizontaleAusrichtung1" ON "QGIS"."HorizontaleAusrichtung" ("Wert") ;
GRANT SELECT ON TABLE "QGIS"."HorizontaleAusrichtung" TO xp_gast;

-- -----------------------------------------------------
-- Table "QGIS"."VertikaleAusrichtung"
-- -----------------------------------------------------
CREATE  TABLE  "QGIS"."VertikaleAusrichtung" (
  "Wert" VARCHAR(64) NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Wert") ,
  CONSTRAINT "fk_VertikaleAusrichtung1"
    FOREIGN KEY ("Wert" )
    REFERENCES "XP_Praesentationsobjekte"."XP_VertikaleAusrichtung" ("Wert" )
    ON DELETE CASCADE
    ON UPDATE CASCADE);

CREATE INDEX "idx_fk_VertikaleAusrichtung1" ON "QGIS"."VertikaleAusrichtung" ("Wert") ;
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
) b ON xb.gid = b.gid
JOIN "XP_Basisobjekte"."XP_Plaene" xp ON b."gehoertZuPlan" = xp.gid;
GRANT SELECT ON TABLE "QGIS"."XP_Bereiche" TO xp_gast;
COMMENT ON VIEW "QGIS"."XP_Bereiche" IS 'Zusammenstellung der Pläne mit ihren Bereichen, wenn einzelne
Fachschemas nicht installiert sind, ist der View anzupassen!';

-- -----------------------------------------------------
-- Data for table "QGIS"."HorizontaleAusrichtung"
-- -----------------------------------------------------
INSERT INTO "QGIS"."HorizontaleAusrichtung" ("Wert", "Bezeichner") VALUES ('linksbündig', 'Left');
INSERT INTO "QGIS"."HorizontaleAusrichtung" ("Wert", "Bezeichner") VALUES ('rechtsbündig', 'Right');
INSERT INTO "QGIS"."HorizontaleAusrichtung" ("Wert", "Bezeichner") VALUES ('zentrisch', 'Center');

-- -----------------------------------------------------
-- Data for table "QGIS"."VertikaleAusrichtung"
-- -----------------------------------------------------
INSERT INTO "QGIS"."VertikaleAusrichtung" ("Wert", "Bezeichner") VALUES ('Basis', 'Base');
INSERT INTO "QGIS"."VertikaleAusrichtung" ("Wert", "Bezeichner") VALUES ('Mitte', 'Half');
INSERT INTO "QGIS"."VertikaleAusrichtung" ("Wert", "Bezeichner") VALUES ('Oben', 'Top');

