CREATE schema "QGIS";
COMMENT ON SCHEMA "QGIS" IS 'Hilfstabellen zur Nutzung von XPlan in QGIS';

GRANT USAGE ON SCHEMA "QGIS" TO xp_gast;

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
