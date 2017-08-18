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
