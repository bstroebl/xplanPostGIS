-- Änderung CR-001
-- lässt sich in der DB nicht abbilden

-- Änderung CR-002
COMMENT ON COLUMN "XP_Praesentationsobjekte"."XP_APObjekt_dientZurDarstellungVon"."art" IS '"Art" gibt den Namen des Attributs an, das mit dem Präsentationsobjekt dargestellt werden soll.
Die Attributart "Art" darf im Regelfall nur bei "Freien Präsentationsobjekten" (dientZurDarstellungVon = NULL) nicht belegt sein.';

-- Änderung CR-003
ALTER "XP_Raster"."XP_RasterplanAenderung" RENAME besonderheiten TO besonderheit;
COMMENT ON COLUMN  "XP_Raster"."XP_RasterplanAenderung"."besonderheit" IS 'Besonderheit der Änderung';

-- Änderung CR-004
-- war bereits implementiert

-- Änderung CR-006
ALTER TABLE "XP_Basisobjekte"."XP_Plan" DROP COLUMN "xPlanGMLVersion";

-- Änderung CR-007
ALTER TABLE "XP_Basisobjekte"."XP_Objekt_gehoertNachrichtlichZuBereich" RENAME TO "XP_Basisobjekte"."XP_Objekt_gehoertZuBereich";
ALTER TABLE "XP_Basisobjekte"."XP_Objekt_gehoertZuBereich" RENAME "gehoertNachrichtlichZuBereich" TO "gehoertZuBereich";
ALTER TABLE "XP_Basisobjekte"."XP_Objekt_gehoertZuBereich" RENAME CONSTRAINT "gehoertNachrichtlichZuBereich_pkey" TO "gehoertZuBereich_pkey";
COMMENT ON TABLE "XP_Basisobjekte"."XP_Objekt_gehoertZuBereich" IS 'Verweis auf den Bereich, zu dem der Planinhalt gehört.';
-- für weitere Änderungen warten auf Antwort Dr. Brenner

-- Änderung CR-008
ALTER TABLE "BP_Basisobjekte"."BP_Bereich" ADD COLUMN "versionBauNVODatum" DATE;
ALTER "BP_Basisobjekte"."BP_Bereich" RENAME "versionBauGB" TO "versionBauGBDatum";
COMMENT ON COLUMN "BP_Basisobjekte"."BP_Bereich"."versionBauNVODatum" IS 'Datum der zugrundeliegenden Version der BauNVO';
COMMENT ON COLUMN "BP_Basisobjekte"."BP_Bereich"."versionBauNVOText" IS 'Zugrundeliegende Version der BauNVO';
UPDATE "BP_Basisobjekte"."BP_Bereich" SET "versionBauNVODatum" = '1962-06-26'::date WHERE "versionBauNVO" = 1000;
UPDATE "BP_Basisobjekte"."BP_Bereich" SET "versionBauNVODatum" = '1968-11-26'::date WHERE "versionBauNVO" = 2000;
UPDATE "BP_Basisobjekte"."BP_Bereich" SET "versionBauNVODatum" = '1977-09-15'::date WHERE "versionBauNVO" = 3000;
UPDATE "BP_Basisobjekte"."BP_Bereich" SET "versionBauNVODatum" = '1990-01-23'::date WHERE "versionBauNVO" = 4000;
UPDATE "BP_Basisobjekte"."BP_Bereich" SET "versionBauNVOText" = 'AndereGesetzlicheBestimmung - ' || COALESCE("versionBauNVOText",'') WHERE "versionBauNVO" = 9999;
ALTER TABLE "BP_Basisobjekte"."BP_Bereich" DROP COLUMN "versionBauNVO";
ALTER TABLE "FP_Basisobjekte"."FP_Bereich" ADD COLUMN "versionBauNVODatum" DATE;
ALTER "FP_Basisobjekte"."FP_Bereich" RENAME "versionBauGB" TO "versionBauGBDatum";
COMMENT ON COLUMN "FP_Basisobjekte"."FP_Bereich"."versionBauNVODatum" IS 'Datum der zugrundeliegenden Version der BauNVO';
COMMENT ON COLUMN "FP_Basisobjekte"."FP_Bereich"."versionBauNVOText" IS 'Zugrundeliegende Version der BauNVO';
UPDATE "FP_Basisobjekte"."FP_Bereich" SET "versionBauNVODatum" = '1962-06-26'::date WHERE "versionBauNVO" = 1000;
UPDATE "FP_Basisobjekte"."FP_Bereich" SET "versionBauNVODatum" = '1968-11-26'::date WHERE "versionBauNVO" = 2000;
UPDATE "FP_Basisobjekte"."FP_Bereich" SET "versionBauNVODatum" = '1977-09-15'::date WHERE "versionBauNVO" = 3000;
UPDATE "FP_Basisobjekte"."FP_Bereich" SET "versionBauNVODatum" = '1990-01-23'::date WHERE "versionBauNVO" = 4000;
UPDATE "FP_Basisobjekte"."FP_Bereich" SET "versionBauNVOText" = 'AndereGesetzlicheBestimmung - ' || COALESCE("versionBauNVOText",'') WHERE "versionBauNVO" = 9999;
ALTER TABLE "FP_Basisobjekte"."FP_Bereich" DROP COLUMN "versionBauNVO";
DROP TABLE "XP_Enumerationen"."XP_VersionBauNVO" CASCADE;

-- Änderung CR-009
-- war bereits umgesetzt

-- Änderung CR-010

-- -----------------------------------------------------
-- Table "LP_Sonstiges"."LP_ZweckbestimmungGenerischeObjekte"
-- -----------------------------------------------------
CREATE TABLE "LP_Sonstiges"."LP_ZweckbestimmungGenerischeObjekte" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Code") );
GRANT SELECT ON TABLE "LP_Sonstiges"."LP_ZweckbestimmungGenerischeObjekte" TO xp_gast;
GRANT ALL ON TABLE "LP_Sonstiges"."LP_ZweckbestimmungGenerischeObjekte" TO lp_user;

-- -----------------------------------------------------
-- Table "LP_Sonstiges"."LP_GenerischesObjekt_zweckbestimmung"
-- -----------------------------------------------------
CREATE  TABLE  "LP_Sonstiges"."LP_GenerischesObjekt_zweckbestimmung" (
  "LP_GenerischesObjekt_gid" BIGINT NOT NULL ,
  "zweckbestimmung" INTEGER NULL ,
  PRIMARY KEY ("LP_GenerischesObjekt_gid", "zweckbestimmung"),
  CONSTRAINT "fk_LP_GenerischesObjekt_zweckbestimmung1"
    FOREIGN KEY ("LP_GenerischesObjekt_gid" )
    REFERENCES "LP_Sonstiges"."LP_GenerischesObjekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_LP_GenerischesObjekt_zweckbestimmung2"
    FOREIGN KEY ("zweckbestimmung" )
    REFERENCES "LP_Sonstiges"."LP_ZweckbestimmungGenerischeObjekte" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
GRANT SELECT ON TABLE "LP_Sonstiges"."LP_GenerischesObjekt_zweckbestimmung" TO xp_gast;
GRANT ALL ON TABLE "LP_Sonstiges"."LP_GenerischesObjekt_zweckbestimmung" TO LP_user;
COMMENT ON TABLE  "LP_Sonstiges"."LP_GenerischesObjekt_zweckbestimmung" IS 'Über eine CodeList definierte Zweckbestimmungen des Generischen Objekts.';

CREATE TEMP SEQUENCE "LP_Zweckbest_seq";
INSERT INTO "LP_Sonstiges"."LP_ZweckbestimmungGenerischeObjekte"("Code","Bezeichner")
SELECT nextval('"LP_Zweckbest_seq"'), v.* FROM (SELECT DISTINCT trim("zweckbestimmung")::VARCHAR(64) FROM "LP_Sonstiges"."LP_GenerischesObjekt") v;
INSERT INTO "LP_Sonstiges"."LP_GenerischesObjekt_zweckbestimmung"("LP_GenerischesObjekt_gid","zweckbestimmung")
SELECT gid,"Code"
FROM "LP_Sonstiges"."LP_GenerischesObjekt" o
JOIN "LP_Sonstiges"."LP_ZweckbestimmungGenerischeObjekte" z ON trim(o."zweckbestimmung") = z."Bezeichner";
DROP SEQUENCE "LP_Zweckbest_seq";
ALTER TABLE "LP_Sonstiges"."LP_GenerischesObjekt" DROP COLUMN "zweckbestimmung";

-- Änderung CR-013
UPDATE "XP_Enumerationen"."XP_ZweckbestimmungGemeinbedarf" set "Bezeichner" = 'OeffentlicheVerwaltung' WHERE "Code" = 1000;
COMMENT ON COLUMN  "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_SchutzPflegeEntwicklungsFlaeche"."istAusgleich" IS 'Gibt an, ob die Maßnahme zum Ausgleich eines Eingriffs benutzt wird.';
COMMENT ON TABLE  "XP_Basisobjekte"."XP_Plan_aendert" IS 'Bezeichnung eines anderen Planes, der durch den vorliegenden Plan geändert wird.';
COMMENT ON COLUMN "XP_Basisobjekte"."XP_ExterneReferenz"."georefURL" IS 'Referenz auf eine Georeferenzierungs-Datei. Das Attribut ist nur relevant bei Verweisen auf georeferenzierte Rasterbilder.';
COMMENT ON COLUMN "XP_Basisobjekte"."XP_Objekt"."gesetzlicheGrundlage" IS 'Angabe der Gesetzlichen Grundlage des Planinhalts.';
