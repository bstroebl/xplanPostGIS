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

-- Änderung CR-016
-- name und geltungsbereich sind bereits NOT NULL
INSERT INTO "BP_Basisobjekte"."BP_Rechtscharakter" ("Code", "Bezeichner") VALUES (2000, 'NachrichtlicheUebernahme');
INSERT INTO "BP_Basisobjekte"."BP_Rechtscharakter" ("Code", "Bezeichner") VALUES (9998, 'Unbekannt');
UPDATE "BP_Basisobjekte"."BP_TextAbschnitt" SET "rechtscharakter" = 9998 WHERE "rechtscharakter" IS NULL;
ALTER TABLE "BP_Basisobjekte"."BP_TextAbschnitt" ALTER COLUMN "rechtscharakter" SET DEFAULT 9998;
ALTER TABLE "BP_Basisobjekte"."BP_TextAbschnitt" ALTER COLUMN "rechtscharakter" SET NOT NULL;
UPDATE "BP_Basisobjekte"."BP_Objekt" SET "rechtscharakter" = 9998 WHERE "rechtscharakter" IS NULL;
ALTER TABLE "BP_Basisobjekte"."BP_Objekt" ALTER COLUMN "rechtscharakter" SET DEFAULT 9998;
ALTER TABLE "BP_Basisobjekte"."BP_Objekt" ALTER COLUMN "rechtscharakter" SET NOT NULL;

INSERT INTO "FP_Basisobjekte"."FP_Rechtscharakter" ("Code", "Bezeichner") VALUES (2000, 'NachrichtlicheUebernahme');
INSERT INTO "FP_Basisobjekte"."FP_Rechtscharakter" ("Code", "Bezeichner") VALUES (9998, 'Unbekannt');
ALTER TABLE "FP_Basisobjekte"."FP_TextAbschnitt" ALTER COLUMN "rechtscharakter" SET DEFAULT 9998;
UPDATE "FP_Basisobjekte"."FP_Objekt" SET "rechtscharakter" = 9998 WHERE "rechtscharakter" IS NULL;
ALTER TABLE "FP_Basisobjekte"."FP_Objekt" ALTER COLUMN "rechtscharakter" SET DEFAULT 9998;
ALTER TABLE "FP_Basisobjekte"."FP_Objekt" ALTER COLUMN "rechtscharakter" SET NOT NULL;

ALTER TABLE "LP_Basisobjekte"."LP_Status" RENAME TO "LP_Rechtscharakter";
INSERT INTO "LP_Basisobjekte"."LP_Rechtscharakter" ("Code", "Bezeichner") VALUES (9998, 'Unbekannt');
ALTER "LP_Basisobjekte"."LP_TextAbschnitt" RENAME "status" TO "rechtscharakter";
UPDATE "LP_Basisobjekte"."LP_TextAbschnitt" SET "rechtscharakter" = 9998 WHERE "rechtscharakter" IS NULL;
ALTER TABLE "LP_Basisobjekte"."LP_TextAbschnitt" ALTER COLUMN "rechtscharakter" SET DEFAULT 9998;
ALTER TABLE "LP_Basisobjekte"."LP_TextAbschnitt" ALTER COLUMN "rechtscharakter" SET NOT NULL;
ALTER "LP_Basisobjekte"."LP_Objekt" RENAME "status" TO "rechtscharakter";
UPDATE "LP_Basisobjekte"."LP_Objekt" SET "rechtscharakter" = 9998 WHERE "rechtscharakter" IS NULL;
ALTER TABLE "LP_Basisobjekte"."LP_Objekt" ALTER COLUMN "rechtscharakter" SET DEFAULT 9998;
ALTER TABLE "LP_Basisobjekte"."LP_Objekt" ALTER COLUMN "rechtscharakter" SET NOT NULL;

INSERT INTO "SO_Basisobjekte"."SO_Rechtscharakter" ("Code", "Bezeichner") VALUES (1000, 'FestsetzungBPlan');
INSERT INTO "SO_Basisobjekte"."SO_Rechtscharakter" ("Code", "Bezeichner") VALUES (1500, 'DarstellungFPlan');
INSERT INTO "SO_Basisobjekte"."SO_Rechtscharakter" ("Code", "Bezeichner") VALUES (1800, 'InhaltLPlan');
INSERT INTO "SO_Basisobjekte"."SO_Rechtscharakter" ("Code", "Bezeichner") VALUES (2000, 'NachrichtlicheUebernahme');
INSERT INTO "SO_Basisobjekte"."SO_Rechtscharakter" ("Code", "Bezeichner") VALUES (9998, 'Unbekannt');
ALTER TABLE "SO_Basisobjekte"."SO_TextAbschnitt" ALTER COLUMN "rechtscharakter" SET DEFAULT 9998;
UPDATE "SO_Basisobjekte"."SO_Objekt" SET "rechtscharakter" = 9998 WHERE "rechtscharakter" IS NULL;
ALTER TABLE "SO_Basisobjekte"."SO_Objekt" ALTER COLUMN "rechtscharakter" SET DEFAULT 9998;
ALTER TABLE "SO_Basisobjekte"."SO_Objekt" ALTER COLUMN "rechtscharakter" SET NOT NULL;

INSERT INTO "RP_Basisobjekte"."RP_Rechtscharakter" ("Code", "Bezeichner") VALUES (6000, 'NurInformationsgehalt');
INSERT INTO "RP_Basisobjekte"."RP_Rechtscharakter" ("Code", "Bezeichner") VALUES (7000, 'TextlichesZiel');
INSERT INTO "RP_Basisobjekte"."RP_Rechtscharakter" ("Code", "Bezeichner") VALUES (8000, 'ZielundGrundsatz');
INSERT INTO "RP_Basisobjekte"."RP_Rechtscharakter" ("Code", "Bezeichner") VALUES (9000, 'Vorschlag');
INSERT INTO "RP_Basisobjekte"."RP_Rechtscharakter" ("Code", "Bezeichner") VALUES (9998, 'Unbekannt');
UPDATE "RP_Basisobjekte"."RP_Objekt" SET "rechtscharakter" = 9998 WHERE "rechtscharakter" IS NULL;
ALTER TABLE "RP_Basisobjekte"."RP_Objekt" ALTER COLUMN "rechtscharakter" SET DEFAULT 9998;
ALTER TABLE "RP_Basisobjekte"."RP_Objekt" ALTER COLUMN "rechtscharakter" SET NOT NULL;

-- Änderung CR-017
-- ACHTUNG: Evtl. in BP_Baugebiet gespeicherte Objekte werden ohne Datenübernahme gelöscht!
-- Grund: Es wird nicht angenommen, dass diese Klasse tatsächlich genutzt wurde.
DROP Table "BP_Bebauung"."BP_Baugebiet_abweichungText";
DROP Table "BP_Bebauung"."BP_Baugebiet_flaechenteil";
DROP TABLE "BP_Bebauung"."BP_Baugebiet";

-- Änderung CR-018
-- nicht relevant

-- Änderung CR-019
UPDATE "XP_Basisobjekte"."XP_Bereich" set "bedeutung" = 9999 WHERE "bedeutung" NOT IN (1600,1800) AND "bedeutung" IS NOT NULL;
UPDATE "XP_Basisobjekte"."XP_BedeutungenBereich" SET "Bezeichner" = 'Kompensationsbereich' WHERE "Code" = 1800;
DELETE FROM "XP_Basisobjekte"."XP_BedeutungenBereich" WHERE "Code" NOT IN (1600,1800,9999);

-- Änderung CR-020
ALTER TABLE "XP_Praesentationsobjekte"."XP_PPO" ADD column "hat" INTEGER;
COMMENT ON COLUMN "XP_Praesentationsobjekte"."XP_PPO"."hat" IS 'Die Relation ermöglicht es, einem punktförmigen Präsentationsobjekt ein linienförmiges Präsentationsobjekt zuzuweisen. Einziger bekannter Anwendungsfall ist der Zuordnungspfeil eines Symbols oder einer Nutzungsschablone.';

ALTER TABLE "XP_Praesentationsobjekte"."XP_PPO" ADD CONSTRAINT "fk_XP_PPO_XP_LPO1"
    FOREIGN KEY ("hat" )
    REFERENCES "XP_Praesentationsobjekte"."XP_LPO" ("gid" )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;
CREATE INDEX "idx_fk_XP_PPO_XP_LPO1" ON "XP_Praesentationsobjekte"."XP_PPO" ("hat") ;

-- Änderung CR 024
-- -----------------------------------------------------
-- Table "BP_Verkehr"."BP_EinfahrtTypen"
-- -----------------------------------------------------
CREATE  TABLE  "BP_Verkehr"."BP_EinfahrtTypen" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Code") );
GRANT SELECT ON "BP_Verkehr"."BP_EinfahrtTypen" TO xp_gast;

ALTER TABLE  "BP_Verkehr"."BP_EinfahrtPunkt" ADD COLUMN "typ" INTEGER;
ALTER TABLE  "BP_Verkehr"."BP_EinfahrtPunkt" Add CONSTRAINT "fk_BP_EinfahrtPunkt_typ"
    FOREIGN KEY ("typ" )
    REFERENCES "BP_Verkehr"."BP_EinfahrtTypen" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE;

INSERT INTO "BP_Verkehr"."BP_EinfahrtTypen" ("Code", "Bezeichner") VALUES (1000, 'Einfahrt');
INSERT INTO "BP_Verkehr"."BP_EinfahrtTypen" ("Code", "Bezeichner") VALUES (2000, 'Ausfahrt');
INSERT INTO "BP_Verkehr"."BP_EinfahrtTypen" ("Code", "Bezeichner") VALUES (3000, 'EinAusfahrt');
