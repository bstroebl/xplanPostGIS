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
  "style" VARCHAR(1024) NOT NULL ,
  "XP_Bereich_gid" INTEGER NULL ,
  "loadorder" INTEGER NULL,
  PRIMARY KEY ("id") ,
  CONSTRAINT "fk_layer_XP_Bereich1"
    FOREIGN KEY ("XP_Bereich_gid" )
    REFERENCES "XP_Basisobjekte"."XP_Bereich" ("gid" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE);

CREATE INDEX "idx_fk_layer_XP_Bereich1_idx" ON "QGIS"."layer" ("XP_Bereich_gid") ;
GRANT SELECT ON TABLE "QGIS"."layer" TO xp_gast;
GRANT ALL ON TABLE "QGIS"."layer" TO xp_user;

SELECT "XP_Basisobjekte".ensure_sequence('QGIS', 'layer', 'id');


-- -----------------------------------------------------
-- Table "QGIS"."XP_Bereich_gesperrt"
-- -----------------------------------------------------
CREATE  TABLE  "QGIS"."XP_Bereich_gesperrt" (
  "XP_Bereich_gid" INTEGER NOT NULL ,
  "gesperrt" BOOLEAN  NOT NULL DEFAULT f ,
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
  CONSTRAINT "fk_HorizontaleAusrichtung_XP_HorizontaleAusrichtung1"
    FOREIGN KEY ("Wert" )
    REFERENCES "QGIS"."XP_HorizontaleAusrichtung" ("Wert" )
    ON DELETE CASCADE
    ON UPDATE CASCADE);

CREATE INDEX "idx_fk_HorizontaleAusrichtung_XP_HorizontaleAusrichtung1" ON "QGIS"."HorizontaleAusrichtung" ("Wert") ;
GRANT SELECT ON TABLE "QGIS"."HorizontaleAusrichtung" TO xp_gast;

-- -----------------------------------------------------
-- Table "QGIS"."VertikaleAusrichtung"
-- -----------------------------------------------------
CREATE  TABLE  "QGIS"."VertikaleAusrichtung" (
  "Wert" VARCHAR(64) NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Wert") ,
  CONSTRAINT "fk_VertikaleAusrichtung_XP_VertikaleAusrichtung1"
    FOREIGN KEY ("Wert" )
    REFERENCES "QGIS"."XP_VertikaleAusrichtung" ("Wert" )
    ON DELETE CASCADE
    ON UPDATE CASCADE);

CREATE INDEX "idx_fk_VertikaleAusrichtung_XP_VertikaleAusrichtung1" ON "QGIS"."VertikaleAusrichtung" ("Wert") ;
GRANT SELECT ON TABLE "QGIS"."VertikaleAusrichtung" TO xp_gast;

-- *****************************************************
-- Amend Tables
-- *****************************************************
CREATE TRIGGER "XP_Bereich_hasInsert" AFTER INSERT ON "XP_Basisobjekte"."XP_Bereich" FOR EACH ROW EXECUTE PROCEDURE "QGIS"."XP_Bereich_Sperre"();


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
