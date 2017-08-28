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
-- BP
INSERT INTO "BP_Basisobjekte"."BP_Rechtscharakter" ("Code", "Bezeichner") VALUES (2000, 'NachrichtlicheUebernahme');
INSERT INTO "BP_Basisobjekte"."BP_Rechtscharakter" ("Code", "Bezeichner") VALUES (9998, 'Unbekannt');
UPDATE "BP_Basisobjekte"."BP_TextAbschnitt" SET "rechtscharakter" = 9998 WHERE "rechtscharakter" IS NULL;
ALTER TABLE "BP_Basisobjekte"."BP_TextAbschnitt" ALTER COLUMN "rechtscharakter" SET DEFAULT 9998;
ALTER TABLE "BP_Basisobjekte"."BP_TextAbschnitt" ALTER COLUMN "rechtscharakter" SET NOT NULL;
UPDATE "BP_Basisobjekte"."BP_Objekt" SET "rechtscharakter" = 9998 WHERE "rechtscharakter" IS NULL;
ALTER TABLE "BP_Basisobjekte"."BP_Objekt" ALTER COLUMN "rechtscharakter" SET DEFAULT 9998;
ALTER TABLE "BP_Basisobjekte"."BP_Objekt" ALTER COLUMN "rechtscharakter" SET NOT NULL;
-- FP
INSERT INTO "FP_Basisobjekte"."FP_Rechtscharakter" ("Code", "Bezeichner") VALUES (2000, 'NachrichtlicheUebernahme');
INSERT INTO "FP_Basisobjekte"."FP_Rechtscharakter" ("Code", "Bezeichner") VALUES (9998, 'Unbekannt');
ALTER TABLE "FP_Basisobjekte"."FP_TextAbschnitt" ALTER COLUMN "rechtscharakter" SET DEFAULT 9998;
UPDATE "FP_Basisobjekte"."FP_Objekt" SET "rechtscharakter" = 9998 WHERE "rechtscharakter" IS NULL;
ALTER TABLE "FP_Basisobjekte"."FP_Objekt" ALTER COLUMN "rechtscharakter" SET DEFAULT 9998;
ALTER TABLE "FP_Basisobjekte"."FP_Objekt" ALTER COLUMN "rechtscharakter" SET NOT NULL;
UPDATE "FP_Basisobjekte"."FP_Plan" SET "planArt" = 1000 WHERE "planArt" IS NULL;
ALTER TABLE "FP_Basisobjekte"."FP_Plan" ALTER COLUMN "planArt" SET DEFAULT 1000;
ALTER TABLE "FP_Basisobjekte"."FP_Plan" ALTER COLUMN "planArt" SET NOT NULL;
-- LP
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
-- SO
INSERT INTO "SO_Basisobjekte"."SO_Rechtscharakter" ("Code", "Bezeichner") VALUES (1000, 'FestsetzungBPlan');
INSERT INTO "SO_Basisobjekte"."SO_Rechtscharakter" ("Code", "Bezeichner") VALUES (1500, 'DarstellungFPlan');
INSERT INTO "SO_Basisobjekte"."SO_Rechtscharakter" ("Code", "Bezeichner") VALUES (1800, 'InhaltLPlan');
INSERT INTO "SO_Basisobjekte"."SO_Rechtscharakter" ("Code", "Bezeichner") VALUES (2000, 'NachrichtlicheUebernahme');
INSERT INTO "SO_Basisobjekte"."SO_Rechtscharakter" ("Code", "Bezeichner") VALUES (9998, 'Unbekannt');
ALTER TABLE "SO_Basisobjekte"."SO_TextAbschnitt" ALTER COLUMN "rechtscharakter" SET DEFAULT 9998;
UPDATE "SO_Basisobjekte"."SO_Objekt" SET "rechtscharakter" = 9998 WHERE "rechtscharakter" IS NULL;
ALTER TABLE "SO_Basisobjekte"."SO_Objekt" ALTER COLUMN "rechtscharakter" SET DEFAULT 9998;
ALTER TABLE "SO_Basisobjekte"."SO_Objekt" ALTER COLUMN "rechtscharakter" SET NOT NULL;
ALTER TABLE "SO_Basisobjekte"."SO_PlanTyp" RENAME TO "SO_PlanArt"
INSERT INTO "SO_Basisobjekte"."SO_PlanArt" ("Code", "Bezeichner") VALUES (9999, 'Sonstiges');
ALTER TABLE "SO_Basisobjekte"."SO_Plan" RENAME "planTyp" TO "planArt"
COMMENT ON COLUMN "SO_Basisobjekte"."SO_Plan"."planArt" IS 'Über eine Codeliste definierter Typ des Plans';
UPDATE "SO_Basisobjekte"."SO_Plan" SET "planArt" = 9999 WHERE "planArt" IS NULL;
ALTER TABLE "SO_Basisobjekte"."SO_Plan" ALTER COLUMN "planArt" SET DEFAULT 9999;
ALTER TABLE "SO_Basisobjekte"."SO_Plan" ALTER COLUMN "planArt" SET NOT NULL;
-- RP
INSERT INTO "RP_Basisobjekte"."RP_Rechtscharakter" ("Code", "Bezeichner") VALUES (6000, 'NurInformationsgehalt');
INSERT INTO "RP_Basisobjekte"."RP_Rechtscharakter" ("Code", "Bezeichner") VALUES (7000, 'TextlichesZiel');
INSERT INTO "RP_Basisobjekte"."RP_Rechtscharakter" ("Code", "Bezeichner") VALUES (8000, 'ZielundGrundsatz');
INSERT INTO "RP_Basisobjekte"."RP_Rechtscharakter" ("Code", "Bezeichner") VALUES (9000, 'Vorschlag');
INSERT INTO "RP_Basisobjekte"."RP_Rechtscharakter" ("Code", "Bezeichner") VALUES (9998, 'Unbekannt');
UPDATE "RP_Basisobjekte"."RP_Objekt" SET "rechtscharakter" = 9998 WHERE "rechtscharakter" IS NULL;
ALTER TABLE "RP_Basisobjekte"."RP_Objekt" ALTER COLUMN "rechtscharakter" SET DEFAULT 9998;
ALTER TABLE "RP_Basisobjekte"."RP_Objekt" ALTER COLUMN "rechtscharakter" SET NOT NULL;
UPDATE "RP_Basisobjekte"."RP_Plan" SET "planArt" = 1000 WHERE "planArt" IS NULL;
ALTER TABLE "RP_Basisobjekte"."RP_Plan" ALTER COLUMN "planArt" SET DEFAULT 1000;
ALTER TABLE "RP_Basisobjekte"."RP_Plan" ALTER COLUMN "planArt" SET NOT NULL;
UPDATE "RP_Basisobjekte"."RP_PlanArt" SET "Bezeichner" = 'SachlicherTeilplanRegionalebene' WHERE "Code" = 2000;
INSERT INTO "RP_Basisobjekte"."RP_PlanArt" ("Code", "Bezeichner") VALUES (2001, 'SachlicherTeilplanLandesebene');
INSERT INTO "RP_Basisobjekte"."RP_PlanArt" ("Code", "Bezeichner") VALUES (6000, 'RaeumlicherTeilplan');

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

-- Änderung CR-025, sowie CR-031 für VerEntsorgung
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungVerEntsorgung" ("Code", "Bezeichner")
SELECT "Code", "Bezeichner" FROM TABLE  "XP_Enumerationen"."XP_BesondereZweckbestimmungVerEntsorgung";
-- BP
INSERT INTO "BP_Ver_und_Entsorgung"."BP_VerEntsorgung_zweckbestimmung" ("BP_VerEntsorgung_gid","zweckbestimmung")
SELECT "BP_VerEntsorgung_gid", "besondereZweckbestimmung" FROM "BP_Ver_und_Entsorgung"."BP_VerEntsorgung_besondereZweckbestimmung";
COMMENT ON TABLE  "BP_Ver_und_Entsorgung"."BP_VerEntsorgung_zweckbestimmung" IS 'Zweckbestimmung der Fläche';
-- -----------------------------------------------------
-- View "BP_Ver_und_Entsorgung"."BP_VerEntsorgung_qv"
-- -----------------------------------------------------
DROP VIEW "BP_Ver_und_Entsorgung"."BP_VerEntsorgung_qv" CASCADE;
CREATE OR REPLACE VIEW "BP_Ver_und_Entsorgung"."BP_VerEntsorgung_qv" AS
 SELECT g.gid, xpo.ebene, z1 as zweckbestimmung1,z2 as zweckbestimmung2,z3 as zweckbestimmung3,z4 as zweckbestimmung4,
 coalesce(z1 / z1, 0) + coalesce(z2 / z2, 0) + coalesce(z3 / z3, 0) + coalesce(z4 / z4, 0) as anz_zweckbestimmung,
CASE WHEN 2000 IN(z1,z2,z3,z4) THEN 'Regenwasser'
ELSE
    NULL
END as label1,
CASE WHEN 2600 IN (z1,z2,z3,z4) THEN 'Telekomm.'
ELSE NULL
END as label2,
CASE WHEN 10000 IN (z1,z2,z3,z4) THEN 'Hochspannungsleitung'
ELSE NULL
END as label3
  FROM
 "BP_Ver_und_Entsorgung"."BP_VerEntsorgung" g
 JOIN "XP_Basisobjekte"."XP_Objekt" xpo ON g.gid = xpo.gid
 LEFT JOIN
 crosstab('SELECT "BP_VerEntsorgung_gid", "BP_VerEntsorgung_gid", zweckbestimmung FROM "BP_Ver_und_Entsorgung"."BP_VerEntsorgung_zweckbestimmung" ORDER BY 1,3') zt
 (zgid bigint, z1 integer,z2 integer,z3 integer,z4 integer)
 ON g.gid=zt.zgid;
GRANT SELECT ON TABLE "BP_Ver_und_Entsorgung"."BP_VerEntsorgung_qv" TO xp_gast;
-- -----------------------------------------------------
-- View "BP_Ver_und_Entsorgung"."BP_VerEntsorgungFlaeche_qv"
-- -----------------------------------------------------
CREATE OR REPLACE VIEW "BP_Ver_und_Entsorgung"."BP_VerEntsorgungFlaeche_qv" AS
SELECT g.position, p.*
  FROM "BP_Ver_und_Entsorgung"."BP_VerEntsorgungFlaeche" g
 JOIN "BP_Ver_und_Entsorgung"."BP_VerEntsorgung_qv" p ON g.gid = p.gid;
GRANT SELECT ON TABLE "BP_Ver_und_Entsorgung"."BP_VerEntsorgungFlaeche_qv" TO xp_gast;
-- -----------------------------------------------------
-- View "BP_Ver_und_Entsorgung"."BP_VerEntsorgungLinie_qv"
-- -----------------------------------------------------
CREATE OR REPLACE VIEW "BP_Ver_und_Entsorgung"."BP_VerEntsorgungLinie_qv" AS
SELECT g.position, p.*
  FROM "BP_Ver_und_Entsorgung"."BP_VerEntsorgungLinie" g
 JOIN "BP_Ver_und_Entsorgung"."BP_VerEntsorgung_qv" p ON g.gid = p.gid;
GRANT SELECT ON TABLE "BP_Ver_und_Entsorgung"."BP_VerEntsorgungLinie_qv" TO xp_gast;
-- -----------------------------------------------------
-- View "BP_Ver_und_Entsorgung"."BP_VerEntsorgungPunkt_qv"
-- -----------------------------------------------------
CREATE OR REPLACE VIEW "BP_Ver_und_Entsorgung"."BP_VerEntsorgungPunkt_qv" AS
SELECT g.position, p.*
  FROM "BP_Ver_und_Entsorgung"."BP_VerEntsorgungPunkt" g
 JOIN "BP_Ver_und_Entsorgung"."BP_VerEntsorgung_qv" p ON g.gid = p.gid;
GRANT SELECT ON TABLE "BP_Ver_und_Entsorgung"."BP_VerEntsorgungPunkt_qv" TO xp_gast;
DROP TABLE "BP_Ver_und_Entsorgung"."BP_VerEntsorgung_besondereZweckbestimmung";

-- FP
INSERT INTO "FP_Ver_und_Entsorgung"."FP_VerEntsorgung_zweckbestimmung" ("FP_VerEntsorgung_gid","zweckbestimmung")
SELECT "FP_VerEntsorgung_gid", "besondereZweckbestimmung" FROM "FP_Ver_und_Entsorgung"."FP_VerEntsorgung_besondereZweckbestimmung";
COMMENT ON TABLE  "FP_Ver_und_Entsorgung"."FP_VerEntsorgung_zweckbestimmung" IS 'Zweckbestimmung der Fläche';
-- -----------------------------------------------------
-- View "FP_Ver_und_Entsorgung"."FP_VerEntsorgung_qv"
-- -----------------------------------------------------
DROP VIEW "FP_Ver_und_Entsorgung"."FP_VerEntsorgung_qv" CASCADE;
CREATE OR REPLACE VIEW "FP_Ver_und_Entsorgung"."FP_VerEntsorgung_qv" AS
 SELECT g.gid, xpo.ebene, z1 as zweckbestimmung1,z2 as zweckbestimmung2,z3 as zweckbestimmung3,z4 as zweckbestimmung4,
 coalesce(z1 / z1, 0) + coalesce(z2 / z2, 0) + coalesce(z3 / z3, 0) + coalesce(z4 / z4, 0) as anz_zweckbestimmung,
 CASE WHEN 2000 IN(z1,z2,z3,z4) THEN 'Regenwasser'
    WHEN 2600 IN (z1,z2,z3,z4) THEN 'Telekom.'
 ELSE
    zl1."Bezeichner"
 END as label1,
 zl2."Bezeichner" as label2,
 zl3."Bezeichner" as label3,
 zl4."Bezeichner" as label4
  FROM
 "FP_Ver_und_Entsorgung"."FP_VerEntsorgung" g
 JOIN "XP_Basisobjekte"."XP_Objekt" xpo ON g.gid = xpo.gid
 LEFT JOIN
 crosstab('SELECT "FP_VerEntsorgung_gid", "FP_VerEntsorgung_gid", zweckbestimmung FROM "FP_Ver_und_Entsorgung"."FP_VerEntsorgung_zweckbestimmung" ORDER BY 1,3') zt
 (zgid bigint, z1 integer,z2 integer,z3 integer,z4 integer)
 ON g.gid=zt.zgid
  LEFT JOIN "XP_Enumerationen"."XP_ZweckbestimmungVerEntsorgung" zl1 ON zt.z1 = zl1."Code"
  LEFT JOIN "XP_Enumerationen"."XP_ZweckbestimmungVerEntsorgung" zl2 ON zt.z2 = zl2."Code"
  LEFT JOIN "XP_Enumerationen"."XP_ZweckbestimmungVerEntsorgung" zl3 ON zt.z3 = zl3."Code"
  LEFT JOIN "XP_Enumerationen"."XP_ZweckbestimmungVerEntsorgung" zl4 ON zt.z4 = zl4."Code";
GRANT SELECT ON TABLE "FP_Ver_und_Entsorgung"."FP_VerEntsorgung_qv" TO xp_gast;
-- -----------------------------------------------------
-- View "FP_Ver_und_Entsorgung"."FP_VerEntsorgungFlaeche_qv"
-- -----------------------------------------------------
CREATE OR REPLACE VIEW "FP_Ver_und_Entsorgung"."FP_VerEntsorgungFlaeche_qv" AS
SELECT g.position, p.*
  FROM "FP_Ver_und_Entsorgung"."FP_VerEntsorgungFlaeche" g
 JOIN "FP_Ver_und_Entsorgung"."FP_VerEntsorgung_qv" p ON g.gid = p.gid;
GRANT SELECT ON TABLE "FP_Ver_und_Entsorgung"."FP_VerEntsorgungFlaeche_qv" TO xp_gast;
-- -----------------------------------------------------
-- View "FP_Ver_und_Entsorgung"."FP_VerEntsorgungLinie_qv"
-- -----------------------------------------------------
CREATE OR REPLACE VIEW "FP_Ver_und_Entsorgung"."FP_VerEntsorgungLinie_qv" AS
SELECT g.position, p.*
  FROM "FP_Ver_und_Entsorgung"."FP_VerEntsorgungLinie" g
 JOIN "FP_Ver_und_Entsorgung"."FP_VerEntsorgung_qv" p ON g.gid = p.gid;
GRANT SELECT ON TABLE "FP_Ver_und_Entsorgung"."FP_VerEntsorgungLinie_qv" TO xp_gast;
-- -----------------------------------------------------
-- View "FP_Ver_und_Entsorgung"."FP_VerEntsorgungPunkt_qv"
-- -----------------------------------------------------
CREATE OR REPLACE VIEW "FP_Ver_und_Entsorgung"."FP_VerEntsorgungPunkt_qv" AS
SELECT g.position, p.*
  FROM "FP_Ver_und_Entsorgung"."FP_VerEntsorgungPunkt" g
 JOIN "FP_Ver_und_Entsorgung"."FP_VerEntsorgung_qv" p ON g.gid = p.gid;
GRANT SELECT ON TABLE "FP_Ver_und_Entsorgung"."FP_VerEntsorgungPunkt_qv" TO xp_gast;
DROP TABLE "FP_Ver_und_Entsorgung"."FP_VerEntsorgung_besondereZweckbestimmung";

DROP TABLE "XP_Enumerationen"."XP_BesondereZweckbestimmungVerEntsorgung";

-- Änderung CR-026
ALTER TABLE  "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_AnpflanzungBindungErhaltung" ADD COLUMN "baumArt" VARCHAR(64);
COMMENT ON COLUMN  "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_AnpflanzungBindungErhaltung"."baumArt" IS 'Textliche Spezifikation einer Baumart.';

-- Änderung CR-027
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungWasserwirtschaft" ("Code", "Bezeichner") VALUES ('1400', 'Deich');

-- Änderung CR-028
ALTER TABLE  "FP_Ver_und_Entsorgung"."FP_VerEntsorgung" ADD COLUMN "zugunstenVon" VARCHAR(64);
COMMENT ON COLUMN  "FP_Ver_und_Entsorgung"."FP_VerEntsorgung"."zugunstenVon" IS 'Angabe des Begünstigen einer Ausweisung.';

-- Änderung CR-029
ALTER TABLE "BP_Bebauung"."BP_UeberbaubareGrundstuecksFlaeche" DROP CONSTRAINT "fk_BP_UeberbaubareGrundstuecksFlaeche_parent";
ALTER TABLE "BP_Bebauung"."BP_GestaltungBaugebiet" DISABLE TRIGGER "change_to_BP_GestaltungBaugebiet";
INSERT INTO "BP_Bebauung"."BP_GestaltungBaugebiet" (gid) SELECT gid FROM "BP_Bebauung"."BP_UeberbaubareGrundstuecksFlaeche";
ALTER TABLE "BP_Bebauung"."BP_GestaltungBaugebiet" ENABLE TRIGGER "change_to_BP_GestaltungBaugebiet";
ALTER TABLE "BP_Bebauung"."BP_UeberbaubareGrundstuecksFlaeche" ADD CONSTRAINT "fk_BP_UeberbaubareGrundstuecksFlaeche_parent"
    FOREIGN KEY ("gid")
    REFERENCES "BP_Bebauung"."BP_GestaltungBaugebiet" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE;

-- Änderung CR-030
-- nicht relevant

-- Änderung CR-031
-- 0) besondereZweckbestimmungVerEntsorgung: siehe CR-025
-- 1) besondere ZweckbestimmungGemeinbedarf
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungGemeinbedarf" ("Code", "Bezeichner")
SELECT "Code", "Bezeichner" FROM "XP_Enumerationen"."XP_BesondereZweckbestGemeinbedarf";
-- BP
INSERT INTO "BP_Gemeinbedarf_Spiel_und_Sportanlagen"."BP_GemeinbedarfsFlaeche_zweckbestimmung" ("BP_GemeinbedarfsFlaeche_gid" ,"zweckbestimmung")
SELECT "BP_GemeinbedarfsFlaeche_gid" ,"besondereZweckbestimmung" FROM "BP_Gemeinbedarf_Spiel_und_Sportanlagen"."BP_GemeinbedarfsFlaeche_besondereZweckbestimmung";
-- -----------------------------------------------------
-- View "BP_Gemeinbedarf_Spiel_und_Sportanlagen"."BP_GemeinbedarfsFlaeche_qv"
-- -----------------------------------------------------
DROP VIEW "BP_Gemeinbedarf_Spiel_und_Sportanlagen"."BP_GemeinbedarfsFlaeche_qv";
CREATE OR REPLACE VIEW "BP_Gemeinbedarf_Spiel_und_Sportanlagen"."BP_GemeinbedarfsFlaeche_qv" AS
SELECT g.gid,g.position,z1 as zweckbestimmung1,z2 as zweckbestimmung2,z3 as zweckbestimmung3,z4 as zweckbestimmung4,
 coalesce(z1 / z1, 0) + coalesce(z2 / z2, 0) + coalesce(z3 / z3, 0) + coalesce(z4 / z4, 0) as anz_zweckbestimmung,
 CASE WHEN z1 > 9999 or z2 > 9999 or z3 > 9999 or z4 > 9999 THEN
    CASE WHEN 2400 IN(z1,z2,z3,z4) THEN 'SicherheitOrdnung'
    WHEN 2600 IN (z1,z2,z3,z4) THEN 'Infrastruktur'
    END
 ELSE
    zl1."Bezeichner"
 END as label1,
zl2."Bezeichner" as label2,
zl3."Bezeichner" as label3,
zl4."Bezeichner" as label4
  FROM
 "BP_Gemeinbedarf_Spiel_und_Sportanlagen"."BP_GemeinbedarfsFlaeche" g
 LEFT JOIN
 crosstab('SELECT "BP_GemeinbedarfsFlaeche_gid", "BP_GemeinbedarfsFlaeche_gid", zweckbestimmung FROM "BP_Gemeinbedarf_Spiel_und_Sportanlagen"."BP_GemeinbedarfsFlaeche_zweckbestimmung" ORDER BY 1,3') zt
 (zgid bigint, z1 integer,z2 integer,z3 integer,z4 integer)
 ON g.gid=zt.zgid
  LEFT JOIN "XP_Enumerationen"."XP_ZweckbestimmungGemeinbedarf" zl1 ON zt.z1 = zl1."Code"
  LEFT JOIN "XP_Enumerationen"."XP_ZweckbestimmungGemeinbedarf" zl2 ON zt.z2 = zl2."Code"
  LEFT JOIN "XP_Enumerationen"."XP_ZweckbestimmungGemeinbedarf" zl3 ON zt.z3 = zl3."Code"
  LEFT JOIN "XP_Enumerationen"."XP_ZweckbestimmungGemeinbedarf" zl4 ON zt.z4 = zl4."Code";
GRANT SELECT ON TABLE "BP_Gemeinbedarf_Spiel_und_Sportanlagen"."BP_GemeinbedarfsFlaeche_qv" TO xp_gast;
DROP TABLE "BP_Gemeinbedarf_Spiel_und_Sportanlagen"."BP_GemeinbedarfsFlaeche_besondereZweckbestimmung";
-- FP
INSERT INTO "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_Gemeinbedarf_zweckbestimmung" ("FP_Gemeinbedarf_gid" ,"zweckbestimmung")
SELECT "FP_Gemeinbedarf_gid" ,"besondereZweckbestimmung" FROM "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_Gemeinbedarf_besondereZweckbestimmung";
-- -----------------------------------------------------
-- View "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_Gemeinbedarf_qv"
-- -----------------------------------------------------
DROP View "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_Gemeinbedarf_qv" CASCADE;
CREATE OR REPLACE VIEW "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_Gemeinbedarf_qv" AS
SELECT g.gid,z1 as zweckbestimmung1,z2 as zweckbestimmung2,z3 as zweckbestimmung3,z4 as zweckbestimmung4,
 coalesce(z1 / z1, 0) + coalesce(z2 / z2, 0) + coalesce(z3 / z3, 0) + coalesce(z4 / z4, 0) as anz_zweckbestimmung,
 CASE WHEN z1 <= 9999  THEN
    CASE WHEN 2400 IN(z1,z2,z3,z4) THEN 'SicherheitOrdnung'
    WHEN 2600 IN (z1,z2,z3,z4) THEN 'Infrastruktur'
    END
 ELSE
    zl1."Bezeichner"
END as label1,
zl2."Bezeichner" as label2,
zl3."Bezeichner" as label3,
zl4."Bezeichner" as label4
  FROM
 "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_Gemeinbedarf" g
 LEFT JOIN
 crosstab('SELECT "FP_Gemeinbedarf_gid", "FP_Gemeinbedarf_gid", zweckbestimmung FROM "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_Gemeinbedarf_zweckbestimmung" ORDER BY 1,3') zt
 (zgid bigint, z1 integer,z2 integer,z3 integer,z4 integer)
 ON g.gid=zt.zgid
  LEFT JOIN "XP_Enumerationen"."XP_ZweckbestimmungGemeinbedarf" zl1 ON zt.z1 = zl1."Code"
  LEFT JOIN "XP_Enumerationen"."XP_ZweckbestimmungGemeinbedarf" zl2 ON zt.z2 = zl2."Code"
  LEFT JOIN "XP_Enumerationen"."XP_ZweckbestimmungGemeinbedarf" zl3 ON zt.z3 = zl3."Code"
  LEFT JOIN "XP_Enumerationen"."XP_ZweckbestimmungGemeinbedarf" zl4 ON zt.z4 = zl4."Code";
GRANT SELECT ON TABLE "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_Gemeinbedarf_qv" TO xp_gast;

-- -----------------------------------------------------
-- View "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_GemeinbedarfFlaeche_qv"
-- -----------------------------------------------------
CREATE OR REPLACE VIEW "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_GemeinbedarfFlaeche_qv" AS
SELECT g.position, p.*
FROM "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_GemeinbedarfFlaeche" g
JOIN "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_Gemeinbedarf_qv" p ON g.gid = p.gid;
GRANT SELECT ON TABLE "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_GemeinbedarfFlaeche_qv" TO xp_gast;

-- -----------------------------------------------------
-- View "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_GemeinbedarfPunkt_qv"
-- -----------------------------------------------------
CREATE OR REPLACE VIEW "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_GemeinbedarfPunkt_qv" AS
SELECT g.position, p.*
FROM "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_GemeinbedarfPunkt" g
JOIN "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_Gemeinbedarf_qv" p ON g.gid = p.gid;
GRANT SELECT ON TABLE "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_GemeinbedarfPunkt_qv" TO xp_gast;
DROP TABLE "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_Gemeinbedarf_besondereZweckbestimmung";
DROP TABLE "XP_Enumerationen"."XP_BesondereZweckbestGemeinbedarf";

-- 2) besondereZweckbestimmungGruen
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungGruen" ("Code", "Bezeichner")
SELECT "Code", "Bezeichner" FROM "XP_Enumerationen"."XP_BesondereZweckbestimmungGruen";
-- BP
INSERT INTO "BP_Landwirtschaft_Wald_und_Gruen"."BP_GruenFlaeche_zweckbestimmung" ("BP_GruenFlaeche_gid","zweckbestimmung")
SELECT "BP_GruenFlaeche_gid","besondereZweckbestimmung" FROM "BP_Landwirtschaft_Wald_und_Gruen"."BP_GruenFlaeche_besondereZweckbestimmung";
DROP VIEW "BP_Landwirtschaft_Wald_und_Gruen"."BP_GruenFlaeche_qv";
CREATE OR REPLACE VIEW "BP_Landwirtschaft_Wald_und_Gruen"."BP_GruenFlaeche_qv" AS
SELECT g.gid,g.position,z1 as zweckbestimmung1,z2 as zweckbestimmung2,z3 as zweckbestimmung3,z4 as zweckbestimmung4,
 coalesce(z1 / z1, 0) + coalesce(z2 / z2, 0) + coalesce(z3 / z3, 0) + coalesce(z4 / z4, 0) as anz_zweckbestimmung,
 CASE WHEN z1 <= 9999 THEN
    CASE WHEN 2200 IN(z1,z2,z3,z4) THEN 'FreizeitErholung'
    END
ELSE
    CASE WHEN z1 IN (12000,14004,16000,22000,24000,24001) THEN
        NULL
    ELSE
        zl1."Bezeichner"
    END
END as label1,
CASE WHEN z1 <= 9999 THEN
    CASE WHEN 2400 IN (z1,z2,z3,z4) THEN 'Spez. Gruenflaeche'
    END
ELSE
    CASE WHEN z2 IN (12000,14004,16000,22000,24000,24001) THEN
        NULL
    ELSE
        zl2."Bezeichner"
    END
END as label2,
CASE WHEN z3 IN (12000,14004,16000,22000,24000,24001) THEN
    NULL
ELSE
    zl3."Bezeichner"
END as label3,
CASE WHEN z4 IN (12000,14004,16000,22000,24000,24001) THEN
    NULL
ELSE
    zl4."Bezeichner"
END as label4
FROM "BP_Landwirtschaft_Wald_und_Gruen"."BP_GruenFlaeche" g
    LEFT JOIN crosstab('SELECT "BP_GruenFlaeche_gid", "BP_GruenFlaeche_gid", zweckbestimmung FROM "BP_Landwirtschaft_Wald_und_Gruen"."BP_GruenFlaeche_zweckbestimmung" ORDER BY 1,3') zt
        (zgid bigint, z1 integer,z2 integer,z3 integer,z4 integer)
    ON g.gid=zt.zgid
    LEFT JOIN "XP_Enumerationen"."XP_ZweckbestimmungGruen" zl1 ON zt.z1 = zl1."Code"
    LEFT JOIN "XP_Enumerationen"."XP_ZweckbestimmungGruen" zl2 ON zt.z2 = zl2."Code"
    LEFT JOIN "XP_Enumerationen"."XP_ZweckbestimmungGruen" zl3 ON zt.z3 = zl3."Code"
    LEFT JOIN "XP_Enumerationen"."XP_ZweckbestimmungGruen" zl4 ON zt.z4 = zl4."Code";
GRANT SELECT ON TABLE "BP_Landwirtschaft_Wald_und_Gruen"."BP_GruenFlaeche_qv" TO xp_gast;
DROP TABLE  "BP_Landwirtschaft_Wald_und_Gruen"."BP_GruenFlaeche_besondereZweckbestimmung";
-- FP
INSERT INTO "FP_Landwirtschaft_Wald_und_Gruen"."FP_Gruen_zweckbestimmung" ("FP_Gruen_gid","zweckbestimmung")
SELECT "FP_Gruen_gid","besondereZweckbestimmung" FROM "FP_Landwirtschaft_Wald_und_Gruen"."FP_Gruen_besondereZweckbestimmung";
-- -----------------------------------------------------
-- View "FP_Landwirtschaft_Wald_und_Gruen"."FP_Gruen_qv"
-- -----------------------------------------------------
DROP VIEW "FP_Landwirtschaft_Wald_und_Gruen"."FP_Gruen_qv" CASCADE;
CREATE OR REPLACE VIEW "FP_Landwirtschaft_Wald_und_Gruen"."FP_Gruen_qv" AS
SELECT g.gid,z1 as zweckbestimmung1,z2 as zweckbestimmung2,z3 as zweckbestimmung3,z4 as zweckbestimmung4,
 coalesce(z1 / z1, 0) + coalesce(z2 / z2, 0) + coalesce(z3 / z3, 0) + coalesce(z4 / z4, 0) as anz_zweckbestimmung,
 CASE WHEN z1 <= 9999 THEN
    CASE WHEN 2200 IN(z1,z2,z3,z4) THEN 'FreizeitErholung'
    END
ELSE
    CASE WHEN z1 IN (12000,14004,16000,22000,24000,24001) THEN
        NULL
    ELSE
        zl1."Bezeichner"
    END
END as label1,
CASE WHEN z1 <= 9999 THEN
    CASE WHEN 2400 IN (z1,z2,z3,z4) THEN 'Spez. Gruenflaeche'
    END
ELSE
    CASE WHEN z2 IN (12000,14004,16000,22000,24000,24001) THEN
        NULL
    ELSE
        zl2."Bezeichner"
    END
END as label2,
CASE WHEN z3 IN (12000,14004,16000,22000,24000,24001) THEN
    NULL
ELSE
    zl3."Bezeichner"
END as label3,
CASE WHEN z4 IN (12000,14004,16000,22000,24000,24001) THEN
    NULL
ELSE
    zl4."Bezeichner"
END as label4
FROM "FP_Landwirtschaft_Wald_und_Gruen"."FP_Gruen" g
    LEFT JOIN crosstab('SELECT "FP_Gruen_gid", "FP_Gruen_gid", zweckbestimmung FROM "FP_Landwirtschaft_Wald_und_Gruen"."FP_Gruen_zweckbestimmung" ORDER BY 1,3') zt
        (zgid bigint, z1 integer,z2 integer,z3 integer,z4 integer)
    ON g.gid=zt.zgid
    LEFT JOIN "XP_Enumerationen"."XP_ZweckbestimmungGruen" zl1 ON zt.z1 = zl1."Code"
    LEFT JOIN "XP_Enumerationen"."XP_ZweckbestimmungGruen" zl2 ON zt.z2 = zl2."Code"
    LEFT JOIN "XP_Enumerationen"."XP_ZweckbestimmungGruen" zl3 ON zt.z3 = zl3."Code"
    LEFT JOIN "XP_Enumerationen"."XP_ZweckbestimmungGruen" zl4 ON zt.z4 = zl4."Code";
GRANT SELECT ON TABLE "FP_Landwirtschaft_Wald_und_Gruen"."FP_Gruen_qv" TO xp_gast;
-- -----------------------------------------------------
-- View "FP_Landwirtschaft_Wald_und_Gruen"."FP_GruenFlaeche_qv"
-- -----------------------------------------------------
CREATE OR REPLACE VIEW "FP_Landwirtschaft_Wald_und_Gruen"."FP_GruenFlaeche_qv" AS
SELECT g.position, p.*
  FROM "FP_Landwirtschaft_Wald_und_Gruen"."FP_GruenFlaeche" g
 JOIN "FP_Landwirtschaft_Wald_und_Gruen"."FP_Gruen_qv" p ON g.gid = p.gid;
GRANT SELECT ON TABLE "FP_Landwirtschaft_Wald_und_Gruen"."FP_GruenFlaeche_qv" TO xp_gast;
-- -----------------------------------------------------
-- View "FP_Landwirtschaft_Wald_und_Gruen"."FP_GruenPunkt_qv"
-- -----------------------------------------------------
CREATE OR REPLACE VIEW "FP_Landwirtschaft_Wald_und_Gruen"."FP_GruenPunkt_qv" AS
SELECT g.position, p.*
  FROM "FP_Landwirtschaft_Wald_und_Gruen"."FP_GruenPunkt" g
 JOIN "FP_Landwirtschaft_Wald_und_Gruen"."FP_Gruen_qv" p ON g.gid = p.gid;
GRANT SELECT ON TABLE "FP_Landwirtschaft_Wald_und_Gruen"."FP_GruenPunkt_qv" TO xp_gast;
DROP TABLE "FP_Landwirtschaft_Wald_und_Gruen"."FP_Gruen_besondereZweckbestimmung";

DROP TABLE "XP_Enumerationen"."XP_BesondereZweckbestimmungGruen";

-- 3) besondereZweckbestimmungPrivilegiertes Vorhaben
-- FP
INSERT INTO "FP_Sonstiges"."FP_ZweckbestimmungPrivilegiertesVorhaben" ("Code", "Bezeichner")
SELECT "Code", "Bezeichner" FROM "FP_Sonstiges"."FP_BesondZweckbestPrivilegiertesVorhaben";
INSERT INTO "FP_Sonstiges"."FP_PrivilegiertesVorhaben_zweckbestimmung" ("FP_PrivilegiertesVorhaben_gid","zweckbestimmung")
SELECT "FP_PrivilegiertesVorhaben_gid","besondereZweckbestimmung" FROM "FP_Sonstiges"."FP_PrivilegiertesVorhaben_besondereZweckbestimmung";
-- -----------------------------------------------------
-- View "FP_Sonstiges"."FP_PrivilegiertesVorhaben_qv"
-- -----------------------------------------------------
DROP VIEW "FP_Sonstiges"."FP_PrivilegiertesVorhaben_qv" CASCADE;
CREATE OR REPLACE VIEW "FP_Sonstiges"."FP_PrivilegiertesVorhaben_qv" AS
 SELECT g.gid, z1 as zweckbestimmung1,z2 as zweckbestimmung2,z3 as zweckbestimmung3,z4 as zweckbestimmung4,
 coalesce(z1 / z1, 0) + coalesce(z2 / z2, 0) + coalesce(z3 / z3, 0) + coalesce(z4 / z4, 0) as anz_zweckbestimmung,
CASE WHEN z1 <= 9999 THEN
    zl1."Bezeichner"
END as label1,
CASE WHEN z1 <= 9999 THEN
    zl2."Bezeichner"
END as label2,
CASE WHEN z1 <= 9999 THEN
    zl3."Bezeichner"
END as label3,
CASE WHEN z1 <= 9999 THEN
    zl4."Bezeichner"
END as label4
  FROM
 "FP_Sonstiges"."FP_PrivilegiertesVorhaben" g
 LEFT JOIN
 crosstab('SELECT "FP_PrivilegiertesVorhaben_gid", "FP_PrivilegiertesVorhaben_gid", zweckbestimmung FROM "FP_Sonstiges"."FP_PrivilegiertesVorhaben_zweckbestimmung" ORDER BY 1,3') zt
 (zgid bigint, z1 integer,z2 integer,z3 integer,z4 integer)
 ON g.gid=zt.zgid
  LEFT JOIN "FP_Sonstiges"."FP_ZweckbestimmungPrivilegiertesVorhaben" zl1 ON zt.z1 = zl1."Code"
  LEFT JOIN "FP_Sonstiges"."FP_ZweckbestimmungPrivilegiertesVorhaben" zl2 ON zt.z2 = zl2."Code"
  LEFT JOIN "FP_Sonstiges"."FP_ZweckbestimmungPrivilegiertesVorhaben" zl3 ON zt.z3 = zl3."Code"
  LEFT JOIN "FP_Sonstiges"."FP_ZweckbestimmungPrivilegiertesVorhaben" zl4 ON zt.z4 = zl4."Code";
GRANT SELECT ON TABLE "FP_Sonstiges"."FP_PrivilegiertesVorhaben_qv" TO xp_gast;
-- -----------------------------------------------------
-- View "FP_Sonstiges"."FP_PrivilegiertesVorhabenFlaeche_qv"
-- -----------------------------------------------------
CREATE OR REPLACE VIEW "FP_Sonstiges"."FP_PrivilegiertesVorhabenFlaeche_qv" AS
SELECT g.position, p.*
  FROM "FP_Sonstiges"."FP_PrivilegiertesVorhabenFlaeche" g
 JOIN "FP_Sonstiges"."FP_PrivilegiertesVorhaben_qv" p ON g.gid = p.gid;
GRANT SELECT ON TABLE "FP_Sonstiges"."FP_PrivilegiertesVorhabenFlaeche_qv" TO xp_gast;
-- -----------------------------------------------------
-- View "FP_Sonstiges"."FP_PrivilegiertesVorhabenLinie_qv"
-- -----------------------------------------------------
CREATE OR REPLACE VIEW "FP_Sonstiges"."FP_PrivilegiertesVorhabenLinie_qv" AS
SELECT g.position, p.*
  FROM "FP_Sonstiges"."FP_PrivilegiertesVorhabenLinie" g
 JOIN "FP_Sonstiges"."FP_PrivilegiertesVorhaben_qv" p ON g.gid = p.gid;
GRANT SELECT ON TABLE "FP_Sonstiges"."FP_PrivilegiertesVorhabenLinie_qv" TO xp_gast;
-- -----------------------------------------------------
-- View "FP_Sonstiges"."FP_PrivilegiertesVorhabenPunkt_qv"
-- -----------------------------------------------------
CREATE OR REPLACE VIEW "FP_Sonstiges"."FP_PrivilegiertesVorhabenPunkt_qv" AS
SELECT g.position, p.*
  FROM "FP_Sonstiges"."FP_PrivilegiertesVorhabenPunkt" g
 JOIN "FP_Sonstiges"."FP_PrivilegiertesVorhaben_qv" p ON g.gid = p.gid;
GRANT SELECT ON TABLE "FP_Sonstiges"."FP_PrivilegiertesVorhabenPunkt_qv" TO xp_gast;

DROP TABLE "FP_Sonstiges"."FP_PrivilegiertesVorhaben_besondereZweckbestimmung";
DROP TABLE "FP_Sonstiges"."FP_BesondZweckbestPrivilegiertesVorhaben";

-- 4) besondereZweckbestimmungStrassenverkehr
-- FP
INSERT INTO "FP_Verkehr"."FP_ZweckbestimmungStrassenverkehr" ("Code", "Bezeichner")
SELECT "Code", "Bezeichner" FROM "FP_Verkehr"."FP_BesondereZweckbestimmungStrassenverkehr";
UPDATE "FP_Verkehr"."FP_Strassenverkehr" SET "zweckbestimmung" = "besondereZweckbestimmung" WHERE "besondereZweckbestimmung" IS NOT NULL;
ALTER TABLE "FP_Verkehr"."FP_Strassenverkehr" DROP COLUMN "besondereZweckbestimmung";

DROP TABLE "FP_Verkehr"."FP_BesondereZweckbestimmungStrassenverkehr";

-- 5) BesondereKlassifizNachSchienenverkehrsrecht
-- SO
INSERT INTO "SO_NachrichtlicheUebernahmen"."SO_KlassifizNachSchienenverkehrsrecht" ("Code", "Bezeichner")
SELECT "Code", "Bezeichner" FROM "SO_NachrichtlicheUebernahmen"."SO_BesondereKlassifizNachSchienenverkehrsrecht";
UPDATE "SO_NachrichtlicheUebernahmen"."SO_Schienenverkehrsrecht" SET "artDerFestlegung" = "besondereArtDerFestlegung" WHERE "besondereArtDerFestlegung" IS NOT NULL;
ALTER TABLE "SO_NachrichtlicheUebernahmen"."SO_Schienenverkehrsrecht" DROP COLUMN "besondereArtDerFestlegung";
DROP TABLE "SO_NachrichtlicheUebernahmen"."SO_BesondereKlassifizNachSchienenverkehrsrecht";

-- Änderung CR-032
COMMENT ON SCHEMA "RP_Basisobjekte" IS 'Dies Paket enthält die Basisobjekte des Raumordnungsplanschemas.';
COMMENT ON TABLE "RP_Basisobjekte"."RP_Plan" IS 'Die Klasse RP_Plan modelliert einen Raumordnungsplan.';
COMMENT ON COLUMN "RP_Basisobjekte"."RP_Plan"."planArt" IS 'Art des Raumordnungsplans.';
COMMENT ON TABLE "RP_Basisobjekte"."RP_Bereich" IS 'Die Klasse RP_Bereich modelliert einen Bereich eines Raumordnungsplans. Bereiche strukturieren Pläne räumlich und inhaltlich.';
COMMENT ON TABLE "RP_Basisobjekte"."RP_Objekt" IS 'RP_Objekt ist die Basisklasse für alle spezifischen Festlegungen eines Raumordnungsplans. Sie selbst ist abstrakt, d.h. sie wird selbst nicht als eigenes Objekt verwendet, sondern vererbt nur ihre Attribute an spezielle Klassen.';
COMMENT ON TABLE  "RP_KernmodellFreiraumstruktur"."RP_GruenzugGruenzaesur" IS 'Grünzüge und kleinräumigere Grünzäsuren sind Ordnungsinstrumente zur Freiraumsicherung. Teilweise werden Grünzüge auch Trenngrün genannt.';
COMMENT ON TABLE  "RP_KernmodellSonstiges"."RP_GenerischesObjekt" IS 'Klasse zur Modellierung aller Inhalte des Raumordnungsplans, die durch keine andere Klasse des RPlan-Fachschemas dargestellt werden können.';

-- Änderung CR-033
-- BP_TiefeProzentualBezugTypen nicht gefunden

-- Änderung CR-034
-- keine Relevanz

-- Änderung CR-035, CR-036, CR-037
-- XP_RasterplanAenderungsobjekte werden in CR-055 eliminiert und deshalb hier nicht bearbeitet
-- Triggerfunktion
DROP FUNCTION "XP_Basisobjekte"."change_to_XP_ExterneReferenz" CASCADE;
CREATE OR REPLACE FUNCTION "XP_Basisobjekte"."child_of_XP_ExterneReferenz"()
RETURNS trigger AS
$BODY$
 BEGIN
    If (TG_OP = 'INSERT') THEN
        IF pg_trigger_depth() = 1 THEN
            new.id := nextval('"XP_Basisobjekte"."XP_ExterneReferenz_id_seq"');
        END IF;

        IF new."referenzName" IS NULL THEN
            new."referenzName" := 'Externe Referenz ' || CAST(new.id as varchar);
        END IF;

        INSERT INTO "XP_Basisobjekte"."XP_ExterneReferenz"(id, "referenzName") VALUES(new.id, new."referenzName");
        RETURN new;
    ELSIf (TG_OP = 'UPDATE') THEN
        new.id := old.id;
        RETURN new;
    ELSIF (TG_OP = 'DELETE') THEN
        DELETE FROM "XP_Basisobjekte"."XP_ExterneReferenz" WHERE id = old.id;
        RETURN old;
    END IF;
 END; $BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
GRANT EXECUTE ON FUNCTION "XP_Basisobjekte"."child_of_XP_ExterneReferenz"() TO xp_user;
-- -----------------------------------------------------
-- Table "XP_Basisobjekte"."XP_ExterneReferenzTyp"
-- -----------------------------------------------------
CREATE  TABLE  "XP_Basisobjekte"."XP_ExterneReferenzTyp" (
  "Code" VARCHAR(64) NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Code") );
GRANT SELECT ON TABLE "XP_Basisobjekte"."XP_ExterneReferenzTyp" TO xp_gast;
-- -----------------------------------------------------
-- Table "XP_Basisobjekte"."XP_SpezExterneReferenz"
-- -----------------------------------------------------
CREATE  TABLE  "XP_Basisobjekte"."XP_SpezExterneReferenz" (
  "id" INTEGER NOT NULL,
  "typ" INTEGER NOT NULL DEFAULT 9999,
  PRIMARY KEY ("id") ,
  CONSTRAINT "fk_xp_externereferenz_xp_referenz_typen"
    FOREIGN KEY ("typ" )
    REFERENCES "XP_Basisobjekte"."XP_ExterneReferenzTyp" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE
);
COMMENT ON TABLE "XP_Basisobjekte"."XP_SpezExterneReferenz" IS 'Verweis auf ein extern gespeichertes Dokument, einen extern gespeicherten, georeferenzierten Plan oder einen Datenbank-Eintrag. Einer der beiden Attribute "referenzName" bzw. "referenzURL" muss belegt sein.';
COMMENT ON COLUMN "XP_Basisobjekte"."XP_SpezExterneReferenz"."id" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN "XP_Basisobjekte"."XP_SpezExterneReferenz"."typ" IS 'Typ / Inhalt des referierten Dokuments oder Rasterplans.';
CREATE INDEX "idx_fk_xp_externereferenz_xp_referenz_typen" ON "XP_Basisobjekte"."XP_SpezExterneReferenz" ("typ");
GRANT SELECT ON TABLE "XP_Basisobjekte"."XP_SpezExterneReferenz" TO xp_gast;
GRANT ALL ON TABLE "XP_Basisobjekte"."XP_SpezExterneReferenz" TO xp_user;
-- -----------------------------------------------------
-- Data for table "XP_Basisobjekte"."XP_ExterneReferenzTyp"
-- -----------------------------------------------------
INSERT INTO "XP_Basisobjekte"."XP_ExterneReferenzTyp" ("Code", "Bezeichner") VALUES ('1000', 'Beschreibung');
INSERT INTO "XP_Basisobjekte"."XP_ExterneReferenzTyp" ("Code", "Bezeichner") VALUES ('1010', 'Begruendung');
INSERT INTO "XP_Basisobjekte"."XP_ExterneReferenzTyp" ("Code", "Bezeichner") VALUES ('1020', 'Legende');
INSERT INTO "XP_Basisobjekte"."XP_ExterneReferenzTyp" ("Code", "Bezeichner") VALUES ('1030', 'Rechtsplan');
INSERT INTO "XP_Basisobjekte"."XP_ExterneReferenzTyp" ("Code", "Bezeichner") VALUES ('1040', 'Plangrundlage');
INSERT INTO "XP_Basisobjekte"."XP_ExterneReferenzTyp" ("Code", "Bezeichner") VALUES ('1050', 'Umweltbericht');
INSERT INTO "XP_Basisobjekte"."XP_ExterneReferenzTyp" ("Code", "Bezeichner") VALUES ('1060', 'Satzung');
INSERT INTO "XP_Basisobjekte"."XP_ExterneReferenzTyp" ("Code", "Bezeichner") VALUES ('1070', 'Karte');
INSERT INTO "XP_Basisobjekte"."XP_ExterneReferenzTyp" ("Code", "Bezeichner") VALUES ('1080', 'Erlaeuterung');
INSERT INTO "XP_Basisobjekte"."XP_ExterneReferenzTyp" ("Code", "Bezeichner") VALUES ('1090', 'ZusammenfassendeErklaerung');
INSERT INTO "XP_Basisobjekte"."XP_ExterneReferenzTyp" ("Code", "Bezeichner") VALUES ('2000', 'Koordinatenliste');
INSERT INTO "XP_Basisobjekte"."XP_ExterneReferenzTyp" ("Code", "Bezeichner") VALUES ('2100', 'Grundstuecksverzeichnis');
INSERT INTO "XP_Basisobjekte"."XP_ExterneReferenzTyp" ("Code", "Bezeichner") VALUES ('2200', 'Pflanzliste');
INSERT INTO "XP_Basisobjekte"."XP_ExterneReferenzTyp" ("Code", "Bezeichner") VALUES ('2300', 'Gruenordnungsplan');
INSERT INTO "XP_Basisobjekte"."XP_ExterneReferenzTyp" ("Code", "Bezeichner") VALUES ('2400', 'Erschliessungsvertrag');
INSERT INTO "XP_Basisobjekte"."XP_ExterneReferenzTyp" ("Code", "Bezeichner") VALUES ('2500', 'Durchfuehrungsvertrag');
INSERT INTO "XP_Basisobjekte"."XP_ExterneReferenzTyp" ("Code", "Bezeichner") VALUES ('9998', 'Rechtsverbindlich');
INSERT INTO "XP_Basisobjekte"."XP_ExterneReferenzTyp" ("Code", "Bezeichner") VALUES ('9999', 'Informell');
-- -----------------------------------------------------
-- Table "XP_Basisobjekte"."XP_Plan_externeReferenz"
-- -----------------------------------------------------
CREATE  TABLE  "XP_Basisobjekte"."XP_Plan_externeReferenz" (
  "XP_Plan_gid" BIGINT NOT NULL ,
  "externeReferenz" INTEGER NOT NULL ,
  PRIMARY KEY ("XP_Plan_gid", "externeReferenz") ,
  CONSTRAINT "fk_XP_Plan_externeReferenz_XP_Plan"
    FOREIGN KEY ("XP_Plan_gid" )
    REFERENCES "XP_Basisobjekte"."XP_Plan" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_XP_Plan_externeReferenz_XP_ExterneReferenz"
    FOREIGN KEY ("externeReferenz" )
    REFERENCES "XP_Basisobjekte"."XP_SpezExterneReferenz" ("id" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
COMMENT ON TABLE "XP_Basisobjekte"."XP_Plan_externeReferenz" IS 'Referenz auf ein Dokument oder einen georeferenzierten Rasterplan.';
CREATE INDEX "idx_fk_XP_Plan_externeReferenz_XP_Plan" ON "XP_Basisobjekte"."XP_Plan_externeReferenz" ("XP_Plan_gid") ;
CREATE INDEX "idx_fk_XP_Plan_externeReferenz_XP_ExterneReferenz" ON "XP_Basisobjekte"."XP_Plan_externeReferenz" ("externeReferenz");
--rechtsverbindlich
INSERT INTO "XP_Basisobjekte"."XP_SpezExterneReferenz" (id,typ) SELECT "rechtsverbindlich",9998 FROM "XP_Basisobjekte"."XP_Plan_rechtsverbindlich";
INSERT INTO "XP_Basisobjekte"."XP_Plan_externeReferenz" ("XP_Plan_gid", "externeReferenz")
SELECT "XP_Plan_gid", "rechtsverbindlich" FROM "XP_Basisobjekte"."XP_Plan_rechtsverbindlich";
DROP TABLE "XP_Basisobjekte"."XP_Plan_rechtsverbindlich";
--informell
INSERT INTO "XP_Basisobjekte"."XP_SpezExterneReferenz" (id,typ) SELECT "informell",9999 FROM "XP_Basisobjekte"."XP_Plan_informell";
INSERT INTO "XP_Basisobjekte"."XP_Plan_externeReferenz" ("XP_Plan_gid", "externeReferenz")
SELECT "XP_Plan_gid", "informell" FROM "XP_Basisobjekte"."XP_Plan_informell";
DROP TABLE "XP_Basisobjekte"."XP_Plan_informell";
--Beschreibung
INSERT INTO "XP_Basisobjekte"."XP_SpezExterneReferenz" (id,typ) SELECT "refBeschreibung",1000 FROM "XP_Basisobjekte"."XP_Plan_refBeschreibung";
INSERT INTO "XP_Basisobjekte"."XP_Plan_externeReferenz" ("XP_Plan_gid", "externeReferenz")
SELECT "XP_Plan_gid", "refBeschreibung" FROM "XP_Basisobjekte"."XP_Plan_refBeschreibung";
DROP TABLE "XP_Basisobjekte"."XP_Plan_refBeschreibung";
--Begründung
INSERT INTO "XP_Basisobjekte"."XP_SpezExterneReferenz" (id,typ) SELECT "refBegruendung",1010 FROM "XP_Basisobjekte"."XP_Plan_refBegruendung";
INSERT INTO "XP_Basisobjekte"."XP_Plan_externeReferenz" ("XP_Plan_gid", "externeReferenz")
SELECT "XP_Plan_gid", "refBegruendung" FROM "XP_Basisobjekte"."XP_Plan_refBegruendung";
DROP TABLE "XP_Basisobjekte"."XP_Plan_refBegruendung";
--Legende
INSERT INTO "XP_Basisobjekte"."XP_SpezExterneReferenz" (id,typ) SELECT "refLegende",1020 FROM "XP_Basisobjekte"."XP_Plan_refLegende";
INSERT INTO "XP_Basisobjekte"."XP_Plan_externeReferenz" ("XP_Plan_gid", "externeReferenz")
SELECT "XP_Plan_gid", "refLegende" FROM "XP_Basisobjekte"."XP_Plan_refLegende";
DROP TABLE "XP_Basisobjekte"."XP_Plan_refLegende";
--Rechtsplan
INSERT INTO "XP_Basisobjekte"."XP_SpezExterneReferenz" (id,typ) SELECT "refRechtsplan",1030 FROM "XP_Basisobjekte"."XP_Plan_refRechtsplan";
INSERT INTO "XP_Basisobjekte"."XP_Plan_externeReferenz" ("XP_Plan_gid", "externeReferenz")
SELECT "XP_Plan_gid", "refRechtsplan" FROM "XP_Basisobjekte"."XP_Plan_refRechtsplan";
DROP TABLE "XP_Basisobjekte"."XP_Plan_refRechtsplan";
--Plangrundlage
INSERT INTO "XP_Basisobjekte"."XP_SpezExterneReferenz" (id,typ) SELECT "refPlangrundlage",1040 FROM "XP_Basisobjekte"."XP_Plan_refPlangrundlage";
INSERT INTO "XP_Basisobjekte"."XP_Plan_externeReferenz" ("XP_Plan_gid", "externeReferenz")
SELECT "XP_Plan_gid", "refPlangrundlage" FROM "XP_Basisobjekte"."XP_Plan_refPlangrundlage";
DROP TABLE "XP_Basisobjekte"."XP_Plan_refPlangrundlage";
-- -----------------------------------------------------
-- Table "XP_Basisobjekte"."XP_Objekt_externeReferenz"
-- -----------------------------------------------------
CREATE  TABLE  "XP_Basisobjekte"."XP_Objekt_externeReferenz" (
  "XP_Objekt_gid" BIGINT NOT NULL ,
  "externeReferenz" INTEGER NOT NULL ,
  PRIMARY KEY ("XP_Objekt_gid", "externeReferenz") ,
  CONSTRAINT "fk_XP_Objekt_externeReferenz_XP_Objekt"
    FOREIGN KEY ("XP_Objekt_gid" )
    REFERENCES "XP_Basisobjekte"."XP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_XP_Objekt_externeReferenz_XP_ExterneReferenz"
    FOREIGN KEY ("externeReferenz" )
    REFERENCES "XP_Basisobjekte"."XP_SpezExterneReferenz" ("id" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
COMMENT ON TABLE "XP_Basisobjekte"."XP_Objekt_externeReferenz" IS 'Referenz auf ein Dokument oder einen georeferenzierten Rasterplan.';
CREATE INDEX "idx_fk_XP_Objekt_externeReferenz_XP_Objekt" ON "XP_Basisobjekte"."XP_Objekt_externeReferenz" ("XP_Objekt_gid") ;
CREATE INDEX "idx_fk_XP_Objekt_externeReferenz_XP_ExterneReferenz" ON "XP_Basisobjekte"."XP_Objekt_externeReferenz" ("externeReferenz");
GRANT SELECT ON TABLE "XP_Basisobjekte"."XP_Objekt_externeReferenz" TO xp_gast;
GRANT ALL ON TABLE "XP_Basisobjekte"."XP_Objekt_externeReferenz" TO xp_user;
--rechtsverbindlich
INSERT INTO "XP_Basisobjekte"."XP_SpezExterneReferenz" (id,typ) SELECT "rechtsverbindlich",9998 FROM "XP_Basisobjekte"."XP_Objekt_rechtsverbindlich";
INSERT INTO "XP_Basisobjekte"."XP_Objekt_externeReferenz" ("XP_Objekt_gid", "externeReferenz")
SELECT "XP_Objekt_gid", "rechtsverbindlich" FROM "XP_Basisobjekte"."XP_Objekt_rechtsverbindlich";
DROP TABLE "XP_Basisobjekte"."XP_Objekt_rechtsverbindlich";
--informell
INSERT INTO "XP_Basisobjekte"."XP_SpezExterneReferenz" (id,typ) SELECT "informell",9999 FROM "XP_Basisobjekte"."XP_Objekt_informell";
INSERT INTO "XP_Basisobjekte"."XP_Objekt_externeReferenz" ("XP_Objekt_gid", "externeReferenz")
SELECT "XP_Objekt_gid", "informell" FROM "XP_Basisobjekte"."XP_Objekt_informell";
DROP TABLE "XP_Basisobjekte"."XP_Objekt_informell";
-- erst jetzt den Trigger anlegen
CREATE TRIGGER "change_to_XP_SpezExterneReferenz" BEFORE INSERT OR UPDATE ON "XP_Basisobjekte"."XP_SpezExterneReferenz" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_ExterneReferenz"();
CREATE TRIGGER "delete_XP_SpezExterneReferenz" AFTER DELETE ON "XP_Basisobjekte"."XP_SpezExterneReferenz" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_ExterneReferenz"();

-- Änderung CR-038
INSERT INTO "XP_Enumerationen"."XP_BesondereArtDerBaulNutzung" ("Code", "Bezeichner") VALUES ('1550', 'UrbanesGebiet');

-- -----------------------------------------------------
-- Table "BP_Umwelt"."BP_ZweckbestimmungenTMF"
-- -----------------------------------------------------
CREATE TABLE "BP_Umwelt"."BP_ZweckbestimmungenTMF" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Code") );
GRANT SELECT ON "BP_Umwelt"."BP_ZweckbestimmungenTMF" TO xp_gast;
-- -----------------------------------------------------
-- Table "BP_Umwelt"."BP_TechnischeMassnahmenFlaeche"
-- -----------------------------------------------------
CREATE  TABLE  "BP_Umwelt"."BP_TechnischeMassnahmenFlaeche" (
  "gid" BIGINT NOT NULL ,
  "zweckbestimmung" INTEGER NOT NULL DEFAULT 1000,
  "technischeMassnahme" CHARACTER VARYING(256),
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_BP_TechnischeMassnahmenFlaeche_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "BP_Basisobjekte"."BP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_BP_TechnischeMassnahmenFlaeche_zweckbestimmung"
    FOREIGN KEY ("zweckbestimmung" )
    REFERENCES "BP_Umwelt"."BP_ZweckbestimmungenTMF" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE))
INHERITS ("BP_Basisobjekte"."BP_Flaechenobjekt");

GRANT SELECT ON TABLE "BP_Umwelt"."BP_TechnischeMassnahmenFlaeche" TO xp_gast;
GRANT ALL ON TABLE "BP_Umwelt"."BP_TechnischeMassnahmenFlaeche" TO bp_user;
CREATE INDEX "BP_TechnischeMassnahmenFlaeche_gidx" ON "BP_Umwelt"."BP_TechnischeMassnahmenFlaeche" using gist ("position");
COMMENT ON TABLE "BP_Umwelt"."BP_TechnischeMassnahmenFlaeche" IS 'Fläche für technische oder bauliche Maßnahmen nach § 9, Abs. 1, Nr. 23 BauGB.';
COMMENT ON COLUMN  "BP_Umwelt"."BP_TechnischeMassnahmenFlaeche"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN  "BP_Umwelt"."BP_TechnischeMassnahmenFlaeche"."zweckbestimmung" IS 'Klassifikation der durchzuführenden Maßnahmen nach §9, Abs. 1, Nr. 23a BauGB.';
COMMENT ON COLUMN  "BP_Umwelt"."BP_TechnischeMassnahmenFlaeche"."technischeMassnahme" IS 'Beschreibung der Maßnahme.';
CREATE TRIGGER "change_to_BP_TechnischeMassnahmenFlaeche" BEFORE INSERT OR UPDATE ON "BP_Umwelt"."BP_TechnischeMassnahmenFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_BP_TechnischeMassnahmenFlaeche" AFTER DELETE ON "BP_Umwelt"."BP_TechnischeMassnahmenFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "ueberlagerung_BP_TechnischeMassnahmenFlaeche" BEFORE INSERT OR UPDATE ON "BP_Umwelt"."BP_TechnischeMassnahmenFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isUeberlagerungsobjekt"();
-- -----------------------------------------------------
-- Data for table "BP_Umwelt"."BP_ZweckbestimmungenTMF"
-- -----------------------------------------------------
INSERT INTO "BP_Umwelt"."BP_ZweckbestimmungenTMF" ("Code", "Bezeichner") VALUES (1000, 'Luftreinhaltung');
INSERT INTO "BP_Umwelt"."BP_ZweckbestimmungenTMF" ("Code", "Bezeichner") VALUES (2000, 'NutzungErneurerbarerEnergien');
INSERT INTO "BP_Umwelt"."BP_ZweckbestimmungenTMF" ("Code", "Bezeichner") VALUES (3000, 'MinderungStoerfallfolgen');

-- Änderung CR-041
ALTER TABLE "XP_Sonstiges"."XP_Hoehenangabe" ADD COLUMN "abweichenderBezugspunkt" VARCHAR(255);
COMMENT ON TABLE  "XP_Sonstiges"."XP_Hoehenangabe" IS 'Spezifikation einer Angabe zur vertikalen Höhe oder zu einem Bereich vertikaler Höhen. Es ist möglich, spezifische Höhenangaben (z.B. die First- oder Traufhöhe eines Gebäudes) vorzugeben oder einzuschränken, oder den Gültigkeitsbereich eines Planinhalts auf eine bestimmte Höhe (hZwingend) bzw. einen Höhenbereich (hMin - hMax) zu beschränken, was vor allem bei der höhenabhängigen Festsetzung einer überbaubaren Grundstücksfläche (BP_UeberbaubareGrundstuecksflaeche), einer Baulinie (BP_Baulinie) oder einer Baugrenze (BP_Baugrenze) relevant ist. In diesem Fall bleiben die Attribute bezugspunkt und abweichenderBezugspunkt unbelegt.';
COMMENT ON COLUMN "XP_Sonstiges"."XP_Hoehenangabe"."bezugspunkt" IS 'BBestimmung des Bezugspunktes der Höhenangaben. Wenn weder dies Attribut noch das Attribut "abweichenderBezugspunkt" belegt sind, soll die Höhenangabe als vertikale Einschränkung des zugeordneten Planinhalts interpretiert werden.';
COMMENT ON COLUMN "XP_Sonstiges"."XP_Hoehenangabe"."abweichenderBezugspunkt" IS 'Textuelle Spezifikation eines Höhenbezugspunktes wenn das Attribut "bezugspunkt" nicht belegt ist.';

-- Änderung CR-042
ALTER TABLE "BP_Basisobjekte"."BP_Linienobjekt" ADD COLUMN "flussrichtung" BOOLEAN;
ALTER TABLE "FP_Basisobjekte"."FP_Linienobjekt" ADD COLUMN "flussrichtung" BOOLEAN;
ALTER TABLE "LP_Basisobjekte"."LP_Linienobjekt" ADD COLUMN "flussrichtung" BOOLEAN;
ALTER TABLE "RP_Basisobjekte"."RP_Linienobjekt" ADD COLUMN "flussrichtung" BOOLEAN;
ALTER TABLE "SO_Basisobjekte"."SO_Linienobjekt" ADD COLUMN "flussrichtung" BOOLEAN;

-- Änderung CR-044
-- nicht relevant, da nur Ergänzung in der Dokumentation von Enumerationen

-- Änderung CR-046
-- nicht relevant, da variabler Raumbezug hier immer durch drei "Kind"-Tabellen abgebildet wird

-- Änderung CR-047
INSERT INTO "XP_Enumerationen"."XP_AnpflanzungBindungErhaltungsGegenstand" ("Code", "Bezeichner") VALUES ('2050', 'BaeumeUndStraeucher');

-- Änderung CR-048
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungKennzeichnung" ("Code", "Bezeichner") VALUES ('8000', 'Vorhabensgebiet');
