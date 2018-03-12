-- Am günstigsten ist es, jedes CR einzeln für sich durchzuführen, um eventuellen Fehlern leichter
-- auf die Spur zu kommen

-- Änderung CR-001
-- lässt sich in der DB nicht abbilden

-- Änderung CR-002
COMMENT ON COLUMN "XP_Praesentationsobjekte"."XP_APObjekt_dientZurDarstellungVon"."art" IS '"Art" gibt den Namen des Attributs an, das mit dem Präsentationsobjekt dargestellt werden soll.
Die Attributart "Art" darf im Regelfall nur bei "Freien Präsentationsobjekten" (dientZurDarstellungVon = NULL) nicht belegt sein.';

-- Änderung CR-003
ALTER TABLE "XP_Raster"."XP_RasterplanAenderung" RENAME besonderheiten TO besonderheit;
COMMENT ON COLUMN  "XP_Raster"."XP_RasterplanAenderung"."besonderheit" IS 'Besonderheit der Änderung';

-- Änderung CR-004
-- war bereits implementiert

-- Änderung CR-006
ALTER TABLE "XP_Basisobjekte"."XP_Plan" DROP COLUMN "xPlanGMLVersion" CASCADE;
-- gelöschte Views wiederherstellen:
CREATE OR REPLACE VIEW "BP_Basisobjekte"."BP_Plan_qv" AS
SELECT x.gid, b."raeumlicherGeltungsbereich", x.name, x.nummer, x."internalId", x.beschreibung, x.kommentar,
    x."technHerstellDatum", x."genehmigungsDatum", x."untergangsDatum", x."erstellungsMassstab",
    x.bezugshoehe, b."sonstPlanArt", b.verfahren, b.rechtsstand, b.status, b.hoehenbezug, b."aenderungenBisDatum",
    b."aufstellungsbeschlussDatum", b."veraenderungssperreDatum", b."satzungsbeschlussDatum", b."rechtsverordnungsDatum",
    b."inkrafttretensDatum", b."ausfertigungsDatum", b.veraenderungssperre, b."staedtebaulicherVertrag",
    b."erschliessungsVertrag",  b."durchfuehrungsVertrag", b.gruenordnungsplan
FROM "BP_Basisobjekte"."BP_Plan" b
    JOIN "XP_Basisobjekte"."XP_Plan" x ON b.gid = x.gid;
GRANT SELECT ON TABLE "BP_Basisobjekte"."BP_Plan_qv" TO xp_gast;

CREATE OR REPLACE VIEW "XP_Basisobjekte"."XP_Plaene" AS
SELECT g.gid, g."raeumlicherGeltungsbereich", name, nummer, "internalId", beschreibung, kommentar,
  "technHerstellDatum", "untergangsDatum", "erstellungsMassstab" ,
  bezugshoehe, CAST(c.relname as varchar) as "Objektart"
FROM "XP_Basisobjekte"."XP_RaeumlicherGeltungsbereich" g
JOIN pg_class c ON g.tableoid = c.oid
JOIN "XP_Basisobjekte"."XP_Plan" p ON g.gid = p.gid;
GRANT SELECT ON TABLE "XP_Basisobjekte"."XP_Plaene" TO xp_gast;
GRANT ALL ON TABLE "XP_Basisobjekte"."XP_Plaene" TO xp_user;
CREATE OR REPLACE RULE _update AS
    ON UPDATE TO "XP_Basisobjekte"."XP_Plaene" DO INSTEAD  UPDATE "XP_Basisobjekte"."XP_RaeumlicherGeltungsbereich" SET "raeumlicherGeltungsbereich" = new."raeumlicherGeltungsbereich"
  WHERE gid = old.gid;
CREATE OR REPLACE RULE _delete AS
    ON DELETE TO "XP_Basisobjekte"."XP_Plaene" DO INSTEAD  DELETE FROM "XP_Basisobjekte"."XP_RaeumlicherGeltungsbereich"
  WHERE gid = old.gid;

CREATE OR REPLACE VIEW "QGIS"."XP_Bereiche" AS
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

CREATE  OR REPLACE VIEW "XP_Basisobjekte"."XP_Bereiche" AS
SELECT g.gid, COALESCE(g.geltungsbereich, p."raeumlicherGeltungsbereich") as geltungsbereich, b.name, CAST(c.relname as varchar) as "Objektart", p.gid as "planGid", p.name as "planName", p."Objektart" as "planArt"
   FROM "XP_Basisobjekte"."XP_Geltungsbereich" g
   JOIN pg_class c ON g.tableoid = c.oid
   JOIN pg_namespace n ON c.relnamespace = n.oid
   JOIN "XP_Basisobjekte"."XP_Bereich" b ON g.gid = b.gid
   JOIN "XP_Basisobjekte"."XP_Plaene" p ON "XP_Basisobjekte"."gehoertZuPlan"(CAST(n.nspname as varchar), CAST(c.relname as varchar), g.gid) = p.gid;
GRANT SELECT ON TABLE "XP_Basisobjekte"."XP_Bereiche" TO xp_gast;
GRANT ALL ON TABLE "XP_Basisobjekte"."XP_Bereiche" TO xp_user;
CREATE OR REPLACE RULE _update AS
    ON UPDATE TO "XP_Basisobjekte"."XP_Bereiche" DO INSTEAD  UPDATE "XP_Basisobjekte"."XP_Geltungsbereich" SET "geltungsbereich" = new."geltungsbereich"
  WHERE gid = old.gid;
CREATE OR REPLACE RULE _delete AS
    ON DELETE TO "XP_Basisobjekte"."XP_Bereiche" DO INSTEAD  DELETE FROM "XP_Basisobjekte"."XP_Geltungsbereich"
  WHERE gid = old.gid;

-- Änderung CR-007
-- In der Datenbank bleibt weiterhin eine Zuordnung eines Fachobjekts zu mehreren Bereichen möglich
-- XP
ALTER TABLE "XP_Basisobjekte"."XP_Objekt_gehoertNachrichtlichZuBereich" RENAME "gehoertNachrichtlichZuBereich" TO "gehoertZuBereich";
ALTER TABLE "XP_Basisobjekte"."XP_Objekt_gehoertNachrichtlichZuBereich" RENAME TO "XP_Objekt_gehoertZuBereich";
-- BP
DROP VIEW "BP_Basisobjekte"."BP_Objekte";
CREATE OR REPLACE VIEW "BP_Basisobjekte"."BP_Objekte" AS
 SELECT bp_o.gid,
    n."gehoertZuBereich" AS "XP_Bereich_gid",
    bp_o."Objektart",
    bp_o."Objektartengruppe",
    bp_o.typ,
    bp_o.flaechenschluss
   FROM ( SELECT o.gid,
            c.relname::character varying AS "Objektart",
            n_1.nspname::character varying AS "Objektartengruppe",
            o.typ,
            o.flaechenschluss
           FROM ( SELECT p.gid,
                    p.tableoid,
                    'Punkt' as typ,
                    NULL::boolean AS flaechenschluss
                   FROM "BP_Basisobjekte"."BP_Punktobjekt" p
                UNION
                 SELECT "BP_Linienobjekt".gid,
                    "BP_Linienobjekt".tableoid,
                    'Linie' as typ,
                    NULL::boolean AS flaechenschluss
                   FROM "BP_Basisobjekte"."BP_Linienobjekt"
                UNION
                 SELECT "BP_Flaechenobjekt".gid,
                    "BP_Flaechenobjekt".tableoid,
                    'Flaeche' as typ,
                    "BP_Flaechenobjekt".flaechenschluss
                   FROM "BP_Basisobjekte"."BP_Flaechenobjekt") o
             JOIN pg_class c ON o.tableoid = c.oid
             JOIN pg_namespace n_1 ON c.relnamespace = n_1.oid) bp_o
     LEFT JOIN "XP_Basisobjekte"."XP_Objekt_gehoertZuBereich" n ON bp_o.gid = n."XP_Objekt_gid";
GRANT SELECT ON TABLE "BP_Basisobjekte"."BP_Objekte" TO xp_gast;
INSERT INTO "XP_Basisobjekte"."XP_Objekt_gehoertZuBereich"("gehoertZuBereich","XP_Objekt_gid")
    SELECT "gehoertZuBP_Bereich","BP_Objekt_gid" FROM "BP_Basisobjekte"."BP_Objekt_gehoertZuBP_Bereich" b
    LEFT JOIN "XP_Basisobjekte"."XP_Objekt_gehoertZuBereich" x ON b."gehoertZuBP_Bereich" = x."gehoertZuBereich" AND b."BP_Objekt_gid" = x."XP_Objekt_gid"
    WHERE x."XP_Objekt_gid" IS NULL;
DROP TABLE "BP_Basisobjekte"."BP_Objekt_gehoertZuBP_Bereich";

-- FP
DROP VIEW "FP_Basisobjekte"."FP_Objekte";
CREATE OR REPLACE VIEW "FP_Basisobjekte"."FP_Objekte" AS
 SELECT fp_o.gid,
    n."gehoertZuBereich" AS "XP_Bereich_gid",
    fp_o."Objektart",
    fp_o."Objektartengruppe",
    fp_o.typ,
    fp_o.flaechenschluss
   FROM ( SELECT o.gid,
            c.relname::character varying AS "Objektart",
            n.nspname::character varying AS "Objektartengruppe",
            o.typ,
            o.flaechenschluss
           FROM ( SELECT p.gid,
                    p.tableoid,
                    'Punkt' as typ,
                    NULL::boolean AS flaechenschluss
                   FROM "FP_Basisobjekte"."FP_Punktobjekt" p
                UNION
                 SELECT "FP_Linienobjekt".gid,
                    "FP_Linienobjekt".tableoid,
                    'Linie' as typ,
                    NULL::boolean AS flaechenschluss
                   FROM "FP_Basisobjekte"."FP_Linienobjekt"
                UNION
                 SELECT "FP_Flaechenobjekt".gid,
                    "FP_Flaechenobjekt".tableoid,
                    'Flaeche' as typ,
                    "FP_Flaechenobjekt".flaechenschluss
                   FROM "FP_Basisobjekte"."FP_Flaechenobjekt") o
             JOIN pg_class c ON o.tableoid = c.oid
             JOIN pg_namespace n ON c.relnamespace = n.oid) fp_o
     LEFT JOIN "XP_Basisobjekte"."XP_Objekt_gehoertZuBereich" n ON fp_o.gid = n."XP_Objekt_gid";
GRANT SELECT ON TABLE "FP_Basisobjekte"."FP_Objekte" TO xp_gast;
INSERT INTO "XP_Basisobjekte"."XP_Objekt_gehoertZuBereich"("gehoertZuBereich","XP_Objekt_gid")
    SELECT "gehoertZuFP_Bereich","FP_Objekt_gid" FROM "FP_Basisobjekte"."FP_Objekt_gehoertZuFP_Bereich" b
    LEFT JOIN "XP_Basisobjekte"."XP_Objekt_gehoertZuBereich" x ON b."gehoertZuFP_Bereich" = x."gehoertZuBereich" AND b."FP_Objekt_gid" = x."XP_Objekt_gid"
    WHERE x."XP_Objekt_gid" IS NULL;
DROP TABLE "FP_Basisobjekte"."FP_Objekt_gehoertZuFP_Bereich";

-- LP
DROP VIEW "LP_Basisobjekte"."LP_Objekte";
CREATE OR REPLACE VIEW "LP_Basisobjekte"."LP_Objekte" AS
 SELECT fp_o.gid,
    n."gehoertZuBereich" AS "XP_Bereich_gid",
    fp_o."Objektart",
    fp_o."Objektartengruppe",
    fp_o.typ,
    fp_o.flaechenschluss
   FROM ( SELECT o.gid,
            c.relname::character varying AS "Objektart",
            n.nspname::character varying AS "Objektartengruppe",
            o.typ,
            o.flaechenschluss
           FROM ( SELECT p.gid,
                    p.tableoid,
                    'Punkt' as typ,
                    NULL::boolean AS flaechenschluss
                   FROM "LP_Basisobjekte"."LP_Punktobjekt" p
                UNION
                 SELECT "LP_Linienobjekt".gid,
                    "LP_Linienobjekt".tableoid,
                    'Linie' as typ,
                    NULL::boolean AS flaechenschluss
                   FROM "LP_Basisobjekte"."LP_Linienobjekt"
                UNION
                 SELECT "LP_Flaechenobjekt".gid,
                    "LP_Flaechenobjekt".tableoid,
                    'Flaeche' as typ,
                    false as flaechenschluss
                   FROM "LP_Basisobjekte"."LP_Flaechenobjekt") o
             JOIN pg_class c ON o.tableoid = c.oid
             JOIN pg_namespace n ON c.relnamespace = n.oid) fp_o
     LEFT JOIN "XP_Basisobjekte"."XP_Objekt_gehoertZuBereich" n ON fp_o.gid = n."XP_Objekt_gid";
GRANT SELECT ON TABLE "LP_Basisobjekte"."LP_Objekte" TO xp_gast;
INSERT INTO "XP_Basisobjekte"."XP_Objekt_gehoertZuBereich"("gehoertZuBereich","XP_Objekt_gid")
    SELECT "gehoertZuLP_Bereich","LP_Objekt_gid" FROM "LP_Basisobjekte"."LP_Objekt_gehoertZuLP_Bereich" b
    LEFT JOIN "XP_Basisobjekte"."XP_Objekt_gehoertZuBereich" x ON b."gehoertZuLP_Bereich" = x."gehoertZuBereich" AND b."LP_Objekt_gid" = x."XP_Objekt_gid"
    WHERE x."XP_Objekt_gid" IS NULL;
DROP TABLE "LP_Basisobjekte"."LP_Objekt_gehoertZuLP_Bereich";

-- RP
DROP VIEW "RP_Basisobjekte"."RP_Objekte";
CREATE OR REPLACE VIEW "RP_Basisobjekte"."RP_Objekte" AS
 SELECT fp_o.gid,
    n."gehoertZuBereich" AS "XP_Bereich_gid",
    fp_o."Objektart",
    fp_o."Objektartengruppe",
    fp_o.typ,
    fp_o.flaechenschluss
   FROM ( SELECT o.gid,
            c.relname::character varying AS "Objektart",
            n.nspname::character varying AS "Objektartengruppe",
            o.typ,
            o.flaechenschluss
           FROM ( SELECT p.gid,
                    p.tableoid,
                    'Punkt' as typ,
                    NULL::boolean AS flaechenschluss
                   FROM "RP_Basisobjekte"."RP_Punktobjekt" p
                UNION
                 SELECT "RP_Linienobjekt".gid,
                    "RP_Linienobjekt".tableoid,
                    'Linie' as typ,
                    NULL::boolean AS flaechenschluss
                   FROM "RP_Basisobjekte"."RP_Linienobjekt"
                UNION
                 SELECT "RP_Flaechenobjekt".gid,
                    "RP_Flaechenobjekt".tableoid,
                    'Flaeche' as typ,
                    false as flaechenschluss
                   FROM "RP_Basisobjekte"."RP_Flaechenobjekt") o
             JOIN pg_class c ON o.tableoid = c.oid
             JOIN pg_namespace n ON c.relnamespace = n.oid) fp_o
     LEFT JOIN "XP_Basisobjekte"."XP_Objekt_gehoertZuBereich" n ON fp_o.gid = n."XP_Objekt_gid";
GRANT SELECT ON TABLE "RP_Basisobjekte"."RP_Objekte" TO xp_gast;
INSERT INTO "XP_Basisobjekte"."XP_Objekt_gehoertZuBereich"("gehoertZuBereich","XP_Objekt_gid")
    SELECT "gehoertZuRP_Bereich","RP_Objekt_gid" FROM "RP_Basisobjekte"."RP_Objekt_gehoertZuRP_Bereich" b
    LEFT JOIN "XP_Basisobjekte"."XP_Objekt_gehoertZuBereich" x ON b."gehoertZuRP_Bereich" = x."gehoertZuBereich" AND b."RP_Objekt_gid" = x."XP_Objekt_gid"
    WHERE x."XP_Objekt_gid" IS NULL;
DROP TABLE "RP_Basisobjekte"."RP_Objekt_gehoertZuRP_Bereich";

-- SO
DROP VIEW "SO_Basisobjekte"."SO_Objekte";
CREATE OR REPLACE VIEW "SO_Basisobjekte"."SO_Objekte" AS
 SELECT fp_o.gid,
    n."gehoertZuBereich" AS "XP_Bereich_gid",
    fp_o."Objektart",
    fp_o."Objektartengruppe",
    fp_o.typ,
    fp_o.flaechenschluss
   FROM ( SELECT o.gid,
            c.relname::character varying AS "Objektart",
            n.nspname::character varying AS "Objektartengruppe",
            o.typ,
            o.flaechenschluss
           FROM ( SELECT p.gid,
                    p.tableoid,
                    'Punkt' as typ,
                    NULL::boolean AS flaechenschluss
                   FROM "SO_Basisobjekte"."SO_Punktobjekt" p
                UNION
                 SELECT "SO_Linienobjekt".gid,
                    "SO_Linienobjekt".tableoid,
                    'Linie' as typ,
                    NULL::boolean AS flaechenschluss
                   FROM "SO_Basisobjekte"."SO_Linienobjekt"
                UNION
                 SELECT "SO_Flaechenobjekt".gid,
                    "SO_Flaechenobjekt".tableoid,
                    'Flaeche' as typ,
                    "SO_Flaechenobjekt".flaechenschluss
                   FROM "SO_Basisobjekte"."SO_Flaechenobjekt") o
             JOIN pg_class c ON o.tableoid = c.oid
             JOIN pg_namespace n ON c.relnamespace = n.oid) fp_o
     LEFT JOIN "XP_Basisobjekte"."XP_Objekt_gehoertZuBereich" n ON fp_o.gid = n."XP_Objekt_gid";
GRANT SELECT ON TABLE "SO_Basisobjekte"."SO_Objekte" TO xp_gast;
INSERT INTO "XP_Basisobjekte"."XP_Objekt_gehoertZuBereich"("gehoertZuBereich","XP_Objekt_gid")
    SELECT "gehoertZuSO_Bereich","SO_Objekt_gid" FROM "SO_Basisobjekte"."SO_Objekt_gehoertZuSO_Bereich" b
    LEFT JOIN "XP_Basisobjekte"."XP_Objekt_gehoertZuBereich" x ON b."gehoertZuSO_Bereich" = x."gehoertZuBereich" AND b."SO_Objekt_gid" = x."XP_Objekt_gid"
    WHERE x."XP_Objekt_gid" IS NULL;
DROP TABLE "SO_Basisobjekte"."SO_Objekt_gehoertZuSO_Bereich";

-- Änderung CR-008
ALTER TABLE "BP_Basisobjekte"."BP_Bereich" ADD COLUMN "versionBauNVODatum" DATE;
ALTER TABLE "BP_Basisobjekte"."BP_Bereich" RENAME "versionBauGB" TO "versionBauGBDatum";
COMMENT ON COLUMN "BP_Basisobjekte"."BP_Bereich"."versionBauNVODatum" IS 'Datum der zugrundeliegenden Version der BauNVO';
COMMENT ON COLUMN "BP_Basisobjekte"."BP_Bereich"."versionBauNVOText" IS 'Zugrundeliegende Version der BauNVO';
UPDATE "BP_Basisobjekte"."BP_Bereich" SET "versionBauNVODatum" = '1962-06-26'::date WHERE "versionBauNVO" = 1000;
UPDATE "BP_Basisobjekte"."BP_Bereich" SET "versionBauNVODatum" = '1968-11-26'::date WHERE "versionBauNVO" = 2000;
UPDATE "BP_Basisobjekte"."BP_Bereich" SET "versionBauNVODatum" = '1977-09-15'::date WHERE "versionBauNVO" = 3000;
UPDATE "BP_Basisobjekte"."BP_Bereich" SET "versionBauNVODatum" = '1990-01-23'::date WHERE "versionBauNVO" = 4000;
UPDATE "BP_Basisobjekte"."BP_Bereich" SET "versionBauNVOText" = 'AndereGesetzlicheBestimmung - ' || COALESCE("versionBauNVOText",'') WHERE "versionBauNVO" = 9999;
ALTER TABLE "BP_Basisobjekte"."BP_Bereich" DROP COLUMN "versionBauNVO";
ALTER TABLE "FP_Basisobjekte"."FP_Bereich" ADD COLUMN "versionBauNVODatum" DATE;
ALTER TABLE "FP_Basisobjekte"."FP_Bereich" RENAME "versionBauGB" TO "versionBauGBDatum";
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

-- Änderung CR-016 und CR-071 und CR-074 und CR-080
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
UPDATE "LP_Basisobjekte"."LP_Rechtscharakter" SET "Bezeichner" = 'NachrichtlicheUebernahme' WHERE "Code" = 3000;
ALTER TABLE "LP_Basisobjekte"."LP_TextAbschnitt" RENAME "status" TO "rechtscharakter";
UPDATE "LP_Basisobjekte"."LP_TextAbschnitt" SET "rechtscharakter" = 9998 WHERE "rechtscharakter" IS NULL;
ALTER TABLE "LP_Basisobjekte"."LP_TextAbschnitt" ALTER COLUMN "rechtscharakter" SET DEFAULT 9998;
ALTER TABLE "LP_Basisobjekte"."LP_TextAbschnitt" ALTER COLUMN "rechtscharakter" SET NOT NULL;
ALTER TABLE "LP_Basisobjekte"."LP_Objekt" RENAME "status" TO "rechtscharakter";
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
ALTER TABLE "SO_Basisobjekte"."SO_PlanTyp" RENAME TO "SO_PlanArt";
INSERT INTO "SO_Basisobjekte"."SO_PlanArt" ("Code", "Bezeichner") VALUES (9999, 'Sonstiges');
ALTER TABLE "SO_Basisobjekte"."SO_Plan" RENAME "planTyp" TO "planArt";
COMMENT ON COLUMN "SO_Basisobjekte"."SO_Plan"."planArt" IS 'Über eine Codeliste definierter Typ des Plans';
UPDATE "SO_Basisobjekte"."SO_Plan" SET "planArt" = 9999 WHERE "planArt" IS NULL;
ALTER TABLE "SO_Basisobjekte"."SO_Plan" ALTER COLUMN "planArt" SET DEFAULT 9999;
ALTER TABLE "SO_Basisobjekte"."SO_Plan" ALTER COLUMN "planArt" SET NOT NULL;
-- CR-074
UPDATE "SO_Basisobjekte"."SO_Objekt" SET "rechtscharakter" = 1500 WHERE "sonstRechtscharakter" = 'DarstellungFPlan';
UPDATE "SO_Basisobjekte"."SO_Objekt" SET "rechtscharakter" = 1000 WHERE "sonstRechtscharakter" = 'FestsetzungBPlan';
UPDATE "SO_Basisobjekte"."SO_Objekt" SET "sonstRechtscharakter" = NULL WHERE "sonstRechtscharakter" IN ('FestsetzungBPlan', 'DarstellungFPlan');
DELETE FROM "SO_Basisobjekte"."SO_SonstRechtscharakter" WHERE "Code" IN ('FestsetzungBPlan', 'DarstellungFPlan');
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
UPDATE "RP_Basisobjekte"."RP_PlanArt" SET "Code" = 5001 WHERE "Code" = 5000;
UPDATE "RP_Basisobjekte"."RP_PlanArt" SET "Code" = 5000 WHERE "Code" = 5100;

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
SELECT "Code", "Bezeichner" FROM "XP_Enumerationen"."XP_BesondereZweckbestimmungVerEntsorgung";
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
-- siehe CR-065

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
DROP FUNCTION "XP_Basisobjekte"."change_to_XP_ExterneReferenz"() CASCADE;
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
  "Code" INTEGER NOT NULL ,
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
    REFERENCES "XP_Basisobjekte"."XP_ExterneReferenzTyp" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_XP_SpezExterneReferenz_parent"
    FOREIGN KEY ("id" )
    REFERENCES "XP_Basisobjekte"."XP_ExterneReferenz" ("id")
    ON DELETE CASCADE
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
INSERT INTO "XP_Basisobjekte"."XP_ExterneReferenzTyp" ("Code", "Bezeichner") VALUES (1000, 'Beschreibung');
INSERT INTO "XP_Basisobjekte"."XP_ExterneReferenzTyp" ("Code", "Bezeichner") VALUES (1010, 'Begruendung');
INSERT INTO "XP_Basisobjekte"."XP_ExterneReferenzTyp" ("Code", "Bezeichner") VALUES (1020, 'Legende');
INSERT INTO "XP_Basisobjekte"."XP_ExterneReferenzTyp" ("Code", "Bezeichner") VALUES (1030, 'Rechtsplan');
INSERT INTO "XP_Basisobjekte"."XP_ExterneReferenzTyp" ("Code", "Bezeichner") VALUES (1040, 'Plangrundlage');
INSERT INTO "XP_Basisobjekte"."XP_ExterneReferenzTyp" ("Code", "Bezeichner") VALUES (1050, 'Umweltbericht');
INSERT INTO "XP_Basisobjekte"."XP_ExterneReferenzTyp" ("Code", "Bezeichner") VALUES (1060, 'Satzung');
INSERT INTO "XP_Basisobjekte"."XP_ExterneReferenzTyp" ("Code", "Bezeichner") VALUES (1070, 'Karte');
INSERT INTO "XP_Basisobjekte"."XP_ExterneReferenzTyp" ("Code", "Bezeichner") VALUES (1080, 'Erlaeuterung');
INSERT INTO "XP_Basisobjekte"."XP_ExterneReferenzTyp" ("Code", "Bezeichner") VALUES (1090, 'ZusammenfassendeErklaerung');
INSERT INTO "XP_Basisobjekte"."XP_ExterneReferenzTyp" ("Code", "Bezeichner") VALUES (2000, 'Koordinatenliste');
INSERT INTO "XP_Basisobjekte"."XP_ExterneReferenzTyp" ("Code", "Bezeichner") VALUES (2100, 'Grundstuecksverzeichnis');
INSERT INTO "XP_Basisobjekte"."XP_ExterneReferenzTyp" ("Code", "Bezeichner") VALUES (2200, 'Pflanzliste');
INSERT INTO "XP_Basisobjekte"."XP_ExterneReferenzTyp" ("Code", "Bezeichner") VALUES (2300, 'Gruenordnungsplan');
INSERT INTO "XP_Basisobjekte"."XP_ExterneReferenzTyp" ("Code", "Bezeichner") VALUES (2400, 'Erschliessungsvertrag');
INSERT INTO "XP_Basisobjekte"."XP_ExterneReferenzTyp" ("Code", "Bezeichner") VALUES (2500, 'Durchfuehrungsvertrag');
INSERT INTO "XP_Basisobjekte"."XP_ExterneReferenzTyp" ("Code", "Bezeichner") VALUES (9998, 'Rechtsverbindlich');
INSERT INTO "XP_Basisobjekte"."XP_ExterneReferenzTyp" ("Code", "Bezeichner") VALUES (9999, 'Informell');
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
--Beschreibung
INSERT INTO "XP_Basisobjekte"."XP_SpezExterneReferenz" (id,typ) SELECT "refBeschreibung",1000 FROM "XP_Basisobjekte"."XP_Plan_refBeschreibung";
INSERT INTO "XP_Basisobjekte"."XP_Plan_externeReferenz" ("XP_Plan_gid", "externeReferenz")
SELECT "XP_Plan_gid", "refBeschreibung" FROM "XP_Basisobjekte"."XP_Plan_refBeschreibung";
DROP TABLE "XP_Basisobjekte"."XP_Plan_refBeschreibung";
--rechtsverbindlich
INSERT INTO "XP_Basisobjekte"."XP_SpezExterneReferenz" (id,typ) SELECT "rechtsverbindlich",9998 FROM "XP_Basisobjekte"."XP_Plan_rechtsverbindlich"
WHERE "rechtsverbindlich" NOT IN (SELECT id FROM "XP_Basisobjekte"."XP_SpezExterneReferenz");
INSERT INTO "XP_Basisobjekte"."XP_Plan_externeReferenz" ("XP_Plan_gid", "externeReferenz")
SELECT "XP_Plan_gid", "rechtsverbindlich" FROM "XP_Basisobjekte"."XP_Plan_rechtsverbindlich"
WHERE "XP_Plan_gid"::varchar || '_' || "rechtsverbindlich"::varchar NOT IN (SELECT "XP_Plan_gid"::varchar || '_' || "externeReferenz"::varchar FROM "XP_Basisobjekte"."XP_Plan_externeReferenz");
DROP TABLE "XP_Basisobjekte"."XP_Plan_rechtsverbindlich";
--informell
INSERT INTO "XP_Basisobjekte"."XP_SpezExterneReferenz" (id,typ) SELECT "informell",9999 FROM "XP_Basisobjekte"."XP_Plan_informell"
WHERE "informell" NOT IN (SELECT id FROM "XP_Basisobjekte"."XP_SpezExterneReferenz");
INSERT INTO "XP_Basisobjekte"."XP_Plan_externeReferenz" ("XP_Plan_gid", "externeReferenz")
SELECT "XP_Plan_gid", "informell" FROM "XP_Basisobjekte"."XP_Plan_informell"
WHERE "XP_Plan_gid"::varchar || '_' || "informell"::varchar NOT IN (SELECT "XP_Plan_gid"::varchar || '_' || "externeReferenz"::varchar FROM "XP_Basisobjekte"."XP_Plan_externeReferenz");
DROP TABLE "XP_Basisobjekte"."XP_Plan_informell";
--Begründung
INSERT INTO "XP_Basisobjekte"."XP_SpezExterneReferenz" (id,typ) SELECT "refBegruendung",1010 FROM "XP_Basisobjekte"."XP_Plan_refBegruendung"
WHERE "refBegruendung" NOT IN (SELECT id FROM "XP_Basisobjekte"."XP_SpezExterneReferenz");
INSERT INTO "XP_Basisobjekte"."XP_Plan_externeReferenz" ("XP_Plan_gid", "externeReferenz")
SELECT "XP_Plan_gid", "refBegruendung" FROM "XP_Basisobjekte"."XP_Plan_refBegruendung"
WHERE "XP_Plan_gid"::varchar || '_' || "refBegruendung"::varchar NOT IN (SELECT "XP_Plan_gid"::varchar || '_' || "externeReferenz"::varchar FROM "XP_Basisobjekte"."XP_Plan_externeReferenz");
DROP TABLE "XP_Basisobjekte"."XP_Plan_refBegruendung";
--Legende
INSERT INTO "XP_Basisobjekte"."XP_SpezExterneReferenz" (id,typ) SELECT "refLegende",1020 FROM "XP_Basisobjekte"."XP_Plan_refLegende"
WHERE "refLegende" NOT IN (SELECT id FROM "XP_Basisobjekte"."XP_SpezExterneReferenz");
INSERT INTO "XP_Basisobjekte"."XP_Plan_externeReferenz" ("XP_Plan_gid", "externeReferenz")
SELECT "XP_Plan_gid", "refLegende" FROM "XP_Basisobjekte"."XP_Plan_refLegende"
WHERE "XP_Plan_gid"::varchar || '_' || "refLegende"::varchar NOT IN (SELECT "XP_Plan_gid"::varchar || '_' || "externeReferenz"::varchar FROM "XP_Basisobjekte"."XP_Plan_externeReferenz");
DROP TABLE "XP_Basisobjekte"."XP_Plan_refLegende";
--Rechtsplan
INSERT INTO "XP_Basisobjekte"."XP_SpezExterneReferenz" (id,typ) SELECT "refRechtsplan",1030 FROM "XP_Basisobjekte"."XP_Plan_refRechtsplan"
WHERE "refRechtsplan" NOT IN (SELECT id FROM "XP_Basisobjekte"."XP_SpezExterneReferenz");
INSERT INTO "XP_Basisobjekte"."XP_Plan_externeReferenz" ("XP_Plan_gid", "externeReferenz")
SELECT "XP_Plan_gid", "refRechtsplan" FROM "XP_Basisobjekte"."XP_Plan_refRechtsplan"
WHERE "XP_Plan_gid"::varchar || '_' || "refRechtsplan"::varchar NOT IN (SELECT "XP_Plan_gid"::varchar || '_' || "externeReferenz"::varchar FROM "XP_Basisobjekte"."XP_Plan_externeReferenz");
DROP TABLE "XP_Basisobjekte"."XP_Plan_refRechtsplan";
--Plangrundlage
INSERT INTO "XP_Basisobjekte"."XP_SpezExterneReferenz" (id,typ) SELECT "refPlangrundlage",1040 FROM "XP_Basisobjekte"."XP_Plan_refPlangrundlage"
WHERE "refPlangrundlage" NOT IN (SELECT id FROM "XP_Basisobjekte"."XP_SpezExterneReferenz");
INSERT INTO "XP_Basisobjekte"."XP_Plan_externeReferenz" ("XP_Plan_gid", "externeReferenz")
SELECT "XP_Plan_gid", "refPlangrundlage" FROM "XP_Basisobjekte"."XP_Plan_refPlangrundlage"
WHERE "XP_Plan_gid"::varchar || '_' || "refPlangrundlage"::varchar NOT IN (SELECT "XP_Plan_gid"::varchar || '_' || "externeReferenz"::varchar FROM "XP_Basisobjekte"."XP_Plan_externeReferenz");
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
    ON UPDATE CASCADE)
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
COMMENT ON TABLE "BP_Bebauung"."BP_BauGrenze" IS 'Festsetzung einer Baulinie (§9 Abs. 1 Nr. 2 BauGB, §22 und 23 BauNVO). Über die Attribute geschossMin und geschossMax kann die Festsetzung auf einen Bereich von Geschossen beschränkt werden. Wenn eine Einschränkung der Festsetzung durch expliziter Höhenangaben erfolgen soll, ist dazu die Oberklassen-Relation hoehenangabe auf den komplexen Datentyp XP_Hoehenangabe zu verwenden. Durch die Digitalisierungsreihenfolge der Linienstützpunkte muss sichergestellt sein, dass die überbaute Fläche (BP_UeberbaubareGrundstuecksFlaeche) relativ zur Laufrichtung auf der linken Seite liegt.';
COMMENT ON TABLE "BP_Bebauung"."BP_BauLinie" IS 'Festsetzung einer Baulinie (§9 Abs. 1 Nr. 2 BauGB, §22 und 23 BauNVO). Über die Attribute geschossMin und geschossMax kann die Festsetzung auf einen Bereich von Geschossen beschränkt werden. Wenn eine Einschränkung der Festsetzung durch expliziter Höhenangaben erfolgen soll, ist dazu die Oberklassen-Relation hoehenangabe auf den komplexen Datentyp XP_Hoehenangabe zu verwenden. Durch die Digitalisierungsreihenfolge der Linienstützpunkte muss sichergestellt sein, dass die überbaute Fläche (BP_UeberbaubareGrundstuecksFlaeche) relativ zur Laufrichtung auf der linken Seite liegt.';
COMMENT ON TABLE "BP_Verkehr"."BP_BereichOhneEinAusfahrtLinie" IS 'Bereich ohne Ein- und Ausfahrt (§9 Abs. 1 Nr. 11 und Abs. 6 BauGB). Durch die Digitalisierungsreihenfolge der Linienstützpunkte muss sichergestellt sein, dass der angrenzende Bereich ohne Ein- und Ausfahrt relativ zur Laufrichtung auf der linken Seite liegt.';
COMMENT ON TABLE "BP_Verkehr"."BP_EinfahrtsbereichLinie" IS 'Einfahrtsbereich (§9 Abs. 1 Nr. 11 und Abs. 6 BauGB). Durch die Digitalisierungsreihenfolge der Linienstützpunkte muss sichergestellt sein, dass die angrenzende Einfahrt relativ zur Laufrichtung auf der linken Seite liegt.';
COMMENT ON TABLE "BP_Verkehr"."BP_StrassenbegrenzungsLinie" IS 'Straßenbegrenzungslinie (§9 Abs. 1 Nr. 11 und Abs. 6 BauGB). Durch die Digitalisierungsreihenfolge der Linienstützpunkte muss sichergestellt sein, dass die abzugrenzende Straßenfläche relativ zur Laufrichtung auf der linken Seite liegt.';

-- Änderung CR-044
-- nicht relevant, da nur Ergänzung in der Dokumentation von Enumerationen

-- Änderung CR-046
-- nicht relevant, da variabler Raumbezug hier immer durch drei "Kind"-Tabellen abgebildet wird

-- Änderung CR-047
INSERT INTO "XP_Enumerationen"."XP_AnpflanzungBindungErhaltungsGegenstand" ("Code", "Bezeichner") VALUES ('2050', 'BaeumeUndStraeucher');

-- Änderung CR-048
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungKennzeichnung" ("Code", "Bezeichner") VALUES ('8000', 'Vorhabensgebiet');

-- Änderung CR-049
UPDATE "XP_Enumerationen"."XP_ZweckbestimmungVerEntsorgung" SET "Bezeichner" = 'Wasser' WHERE "Code" = 1600;

-- Änderung CR-050
-- keine Relevanz

-- Änderung CR-051
-- -----------------------------------------------------
-- Table "BP_Bebauung"."BP_BaugebietBauweise"
-- -----------------------------------------------------
CREATE TABLE  "BP_Bebauung"."BP_BaugebietBauweise" (
  "gid" BIGINT NOT NULL,
  "bauweise" INTEGER,
  "abweichendeBauweise" INTEGER,
  "vertikaleDifferenzierung" BOOLEAN,
  "bebauungsArt" INTEGER,
  "bebauungVordereGrenze" INTEGER,
  "bebauungRueckwaertigeGrenze" INTEGER,
  "bebauungSeitlicheGrenze" INTEGER,
  PRIMARY KEY ("gid"),
  CONSTRAINT "fk_BP_BaugebietBauweise_parent"
    FOREIGN KEY ("gid")
    REFERENCES "BP_Bebauung"."BP_GestaltungBaugebiet" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_BP_BaugebietBauweise_BP_Bauweise1"
    FOREIGN KEY ("bauweise")
    REFERENCES "BP_Bebauung"."BP_Bauweise" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_BP_BaugebietBauweise_BP_AbweichendeBauweise1"
    FOREIGN KEY ("abweichendeBauweise")
    REFERENCES "BP_Bebauung"."BP_AbweichendeBauweise" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_BP_BaugebietBauweise_BP_BebauungsArt1"
    FOREIGN KEY ("bebauungsArt")
    REFERENCES "BP_Bebauung"."BP_BebauungsArt" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_BP_BaugebietBauweise_BP_GrenzBebauung1"
    FOREIGN KEY ("bebauungVordereGrenze")
    REFERENCES "BP_Bebauung"."BP_GrenzBebauung" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_BP_BaugebietBauweise_BP_GrenzBebauung2"
    FOREIGN KEY ("bebauungRueckwaertigeGrenze")
    REFERENCES "BP_Bebauung"."BP_GrenzBebauung" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_BP_BaugebietBauweise_BP_GrenzBebauung3"
    FOREIGN KEY ("bebauungSeitlicheGrenze")
    REFERENCES "BP_Bebauung"."BP_GrenzBebauung" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
CREATE INDEX "idx_fk_BP_BaugebietBauweise_BP_Bauweise1_idx" ON "BP_Bebauung"."BP_BaugebietBauweise" ("bauweise");
CREATE INDEX "idx_fk_BP_BaugebietBauweise_BP_AbweichendeBauweise1_idx" ON "BP_Bebauung"."BP_BaugebietBauweise" ("abweichendeBauweise");
CREATE INDEX "idx_fk_BP_BaugebietBauweise_BP_BebauungsArt1_idx" ON "BP_Bebauung"."BP_BaugebietBauweise" ("bebauungsArt");
CREATE INDEX "idx_fk_BP_BaugebietBauweise_BP_GrenzBebauung1_idx" ON "BP_Bebauung"."BP_BaugebietBauweise" ("bebauungVordereGrenze");
CREATE INDEX "idx_fk_BP_BaugebietBauweise_BP_GrenzBebauung2_idx" ON "BP_Bebauung"."BP_BaugebietBauweise" ("bebauungRueckwaertigeGrenze");
CREATE INDEX "idx_fk_BP_BaugebietBauweise_BP_GrenzBebauung3_idx" ON "BP_Bebauung"."BP_BaugebietBauweise" ("bebauungSeitlicheGrenze");
GRANT SELECT ON TABLE "BP_Bebauung"."BP_BaugebietBauweise" TO xp_gast;
GRANT ALL ON TABLE "BP_Bebauung"."BP_BaugebietBauweise" TO bp_user;
COMMENT ON TABLE  "BP_Bebauung"."BP_BaugebietBauweise" IS '';
COMMENT ON COLUMN  "BP_Bebauung"."BP_BaugebietBauweise"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN  "BP_Bebauung"."BP_BaugebietBauweise"."bauweise" IS 'Festsetzung der Bauweise (§9, Abs. 1, Nr. 2 BauGB).';
COMMENT ON COLUMN  "BP_Bebauung"."BP_BaugebietBauweise"."abweichendeBauweise" IS 'Nähere Bezeichnung einer "Abweichenden Bauweise".';
COMMENT ON COLUMN  "BP_Bebauung"."BP_BaugebietBauweise"."vertikaleDifferenzierung" IS 'Gibt an, ob eine vertikale Differenzierung des Gebäudes vorgeschrieben ist.';
COMMENT ON COLUMN  "BP_Bebauung"."BP_BaugebietBauweise"."bebauungsArt" IS 'Detaillierte Festsetzung der Bauweise (§9, Abs. 1, Nr. 2 BauGB).';
COMMENT ON COLUMN  "BP_Bebauung"."BP_BaugebietBauweise"."bebauungVordereGrenze" IS 'Festsetzung der Bebauung der vorderen Grundstücksgrenze (§9, Abs. 1, Nr. 2 BauGB).';
COMMENT ON COLUMN  "BP_Bebauung"."BP_BaugebietBauweise"."bebauungRueckwaertigeGrenze" IS 'Festsetzung der Bebauung der rückwärtigen Grundstücksgrenze (§9, Abs. 1, Nr. 2 BauGB).';
COMMENT ON COLUMN  "BP_Bebauung"."BP_BaugebietBauweise"."bebauungSeitlicheGrenze" IS 'Festsetzung der Bebauung der seitlichen Grundstücksgrenze (§9, Abs. 1, Nr. 2 BauGB).';
INSERT INTO "BP_Bebauung"."BP_BaugebietBauweise" (gid,"bauweise","abweichendeBauweise","vertikaleDifferenzierung","bebauungsArt","bebauungVordereGrenze","bebauungRueckwaertigeGrenze","bebauungSeitlicheGrenze")
    SELECT gid,"bauweise","abweichendeBauweise","vertikaleDifferenzierung","bebauungsArt","bebauungVordereGrenze","bebauungRueckwaertigeGrenze","bebauungSeitlicheGrenze" FROM "BP_Bebauung"."BP_BaugebietObjekt";
INSERT INTO "BP_Bebauung"."BP_BaugebietBauweise" (gid) SELECT gid FROM "BP_Bebauung"."BP_UeberbaubareGrundstuecksFlaeche";
CREATE TRIGGER "change_to_BP_BaugebietBauweise" BEFORE INSERT OR UPDATE ON "BP_Bebauung"."BP_BaugebietBauweise" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_BP_BaugebietBauweise" AFTER DELETE ON "BP_Bebauung"."BP_BaugebietBauweise" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
ALTER TABLE "BP_Bebauung"."BP_BaugebietObjekt" DROP COLUMN "bauweise" CASCADE;
ALTER TABLE "BP_Bebauung"."BP_BaugebietObjekt" DROP COLUMN "abweichendeBauweise";
ALTER TABLE "BP_Bebauung"."BP_BaugebietObjekt" DROP COLUMN "vertikaleDifferenzierung";
ALTER TABLE "BP_Bebauung"."BP_BaugebietObjekt" DROP COLUMN "bebauungsArt";
ALTER TABLE "BP_Bebauung"."BP_BaugebietObjekt" DROP COLUMN "bebauungVordereGrenze";
ALTER TABLE "BP_Bebauung"."BP_BaugebietObjekt" DROP COLUMN "bebauungRueckwaertigeGrenze";
ALTER TABLE "BP_Bebauung"."BP_BaugebietObjekt" DROP COLUMN "bebauungSeitlicheGrenze";
ALTER TABLE "BP_Bebauung"."BP_BaugebietObjekt" DROP CONSTRAINT "fk_BP_Baugebiet_parent";
ALTER TABLE "BP_Bebauung"."BP_BaugebietObjekt" ADD CONSTRAINT "fk_BP_Baugebiet_parent" FOREIGN KEY ("gid")
    REFERENCES "BP_Bebauung"."BP_BaugebietBauweise" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE;
ALTER TABLE "BP_Bebauung"."BP_BaugebietObjekt_refGebauedequerschnitt" RENAME TO "BP_BaugebietBauweise_refGebauedequerschnitt";
ALTER TABLE "BP_Bebauung"."BP_BaugebietBauweise_refGebauedequerschnitt" RENAME "BP_BaugebietObjekt_gid" TO "BP_BaugebietBauweise_gid";
ALTER TABLE "BP_Bebauung"."BP_BaugebietBauweise_refGebauedequerschnitt" DROP CONSTRAINT "fk_BP_Baugebiet_refGebauedequerschnitt1";
ALTER TABLE "BP_Bebauung"."BP_BaugebietBauweise_refGebauedequerschnitt"
    ADD CONSTRAINT "fk_BP_Baugebiet_refGebauedequerschnitt1" FOREIGN KEY ("BP_BaugebietBauweise_gid")
    REFERENCES "BP_Bebauung"."BP_BaugebietBauweise" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE;

-- Änderung CR-052
-- Umbenennen des Feldes der bereits vorhandenen Referenz
ALTER Table "XP_Basisobjekte"."XP_VerbundenerPlan" rename gid TO "verbundenerPlan";
COMMENT ON COLUMN "XP_Basisobjekte"."XP_VerbundenerPlan"."verbundenerPlan" IS 'Referenz auf einen anderen Plan, der den aktuellen Plan ändert oder von ihm geändert wird.';
CREATE OR REPLACE FUNCTION "XP_Basisobjekte"."change_to_XP_Plan"()
RETURNS trigger AS
$BODY$
 BEGIN
    IF (TG_OP = 'INSERT') THEN
        INSERT INTO "XP_Basisobjekte"."XP_VerbundenerPlan"("verbundenerPlan", "planName") VALUES(new.gid, COALESCE(new.name, 'XP_Plan ' || CAST(new.gid as varchar)));
        RETURN new;
    ELSIF (TG_OP = 'UPDATE') THEN
        new.gid := old.gid; --no change in gid allowed
        UPDATE "XP_Basisobjekte"."XP_VerbundenerPlan" SET "planName" = new.name WHERE "verbundenerPlan" = old.gid;
        RETURN new;
    ELSIF (TG_OP = 'DELETE') THEN
        DELETE FROM "XP_Basisobjekte"."XP_VerbundenerPlan" WHERE "verbundenerPlan" = old.gid;
        RETURN old;
    END IF;
 END; $BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
GRANT EXECUTE ON FUNCTION "XP_Basisobjekte"."change_to_XP_Plan"() TO xp_user;

-- Änderung CR-053
-- ACHTUNG: Daten, die in textSchluessel und textSchluesselBegruendung eingeben werden, werden gelöscht!
-- Feststellen mit:
-- SELECT * from "XP_Basisobjekte"."XP_Objekt" WHERE "textSchluessel" IS NOT NULL OR "textSchluesselBegruendung" IS NOT NULL;
ALTER TABLE "XP_Basisobjekte"."XP_Objekt" DROP COLUMN "textSchluessel";
ALTER TABLE "XP_Basisobjekte"."XP_Objekt" DROP COLUMN "textSchluesselBegruendung";

-- Änderung CR-054
-- wird nicht implementiert (siehe CR-007), um Fachobjekte _nicht_ redundant erfassen zu müssen
-- Beim Export muß dann entsprechend darauf geachtet werden, die Redundanz herzustellen

-- Änderung CR-055
-- ACHTUNG: XP_RasterplanAenderung und seine Kindklassen werden hier einfach gelöscht, da nicht erwartet wird, dass XP_RasterplanAenderung überhaupt benutzt wurde!
-- Feststellen mit: SELECT count(*) from "XP_Raster"."XP_RasterplanAenderung";
--
/* Übernahme vorhandener RasterplanAenderungsobjekte am Beispiel BP_RasterplanAenderung, muß analog auch für die anderen Kindklassen durchgeführt werden:
ALTER TABLE "XP_Basisobjekte"."XP_Plan" ADD COLUMN rastergid BIGINT;
ALTER TABLE "BP_Basisobjekte"."BP_Plan" ADD COLUMN rastergid BIGINT;
INSERT INTO "BP_Basisobjekte"."BP_Plan" ("aufstellungsbeschlussDatum" ,"veraenderungssperreDatum" ,"auslegungsStartDatum","auslegungsEndDatum","traegerbeteiligungsStartDatum","traegerbeteiligungsEndDatum","satzungsbeschlussDatum","rechtsverordnungsDatum","inkrafttretensDatum","räumlicherGeltungsbereich","ausfertigungsDatum",rastergid)
SELECT "aufstellungsbeschlussDatum"  ,"veraenderungssperreDatum","auslegungsStartDatum","auslegungsEndDatum","traegerbeteiligungsStartDatum","traegerbeteiligungsEndDatum","satzungsbeschlussDatum","rechtsverordnungsDatum","inkrafttretensDatum","geltungsbereichAenderung",gid
FROM "BP_Raster"."BP_RasterplanAenderung";
UPDATE "XP_Basisobjekte"."XP_Plan" x SET rastergid = (SELECT rastergrid FROM "BP_Basisobjekte"."BP_Plan" b WHERE x.gid = b.gid) WHERE x.gid IN (SELECT gid FROM "BP_Basisobjekte"."BP_Plan");
UPDATE "XP_Basisobjekte"."XP_Plan" x SET name = (SELECT COALESCE("nameAenderung",'Rasterplan ' || gid::VARCHAR) FROM "XP_Raster"."XP_RasterplanAenderung" r WHERE r.gid = x.rastergid) WHERE x.gid IN (SELECT gid FROM "BP_Basisobjekte"."BP_Plan");
UPDATE "XP_Basisobjekte"."XP_Plan" x SET nummer = (SELECT "nummerAenderung" FROM "XP_Raster"."XP_RasterplanAenderung" r WHERE r.gid = x.rastergid) WHERE x.gid IN (SELECT gid FROM "BP_Basisobjekte"."BP_Plan");
UPDATE "XP_Basisobjekte"."XP_Plan" x SET beschreibung = (SELECT "beschreibung" FROM "XP_Raster"."XP_RasterplanAenderung" r WHERE r.gid = x.rastergid) WHERE x.gid IN (SELECT gid FROM "BP_Basisobjekte"."BP_Plan");
UPDATE "XP_Basisobjekte"."XP_Plan" x SET kommentar = (SELECT "besonderheit" FROM "XP_Raster"."XP_RasterplanAenderung" r WHERE r.gid = x.rastergid) WHERE x.gid IN (SELECT gid FROM "BP_Basisobjekte"."BP_Plan");
ALTER TABLE "BP_Basisobjekte"."BP_Plan" DROP COLUMN rastergid;
INSERT INTO "XP_Basisobjekte"."XP_SpezExterneReferenz" (id,typ) SELECT "refBeschreibung",1000 FROM "XP_Raster"."XP_RasterplanAenderung";
INSERT INTO "XP_Basisobjekte"."XP_Plan_externeReferenz" ("XP_Plan_gid", "externeReferenz")
SELECT x."gid", r."refBeschreibung" FROM "XP_Basisobjekte"."XP_Plan_refBeschreibung" x JOIN "XP_Raster"."XP_RasterplanAenderung" ON x.rastergid = r.gid WHERE r."refBeschreibung" IS NOT NULL;
INSERT INTO "XP_Basisobjekte"."XP_SpezExterneReferenz" (id,typ) SELECT "refBegruendung",1010 FROM "XP_Raster"."XP_RasterplanAenderung";
INSERT INTO "XP_Basisobjekte"."XP_Plan_externeReferenz" ("XP_Plan_gid", "externeReferenz")
SELECT x."gid", r."refBegruendung" FROM "XP_Basisobjekte"."XP_Plan_refBeschreibung" x JOIN "XP_Raster"."XP_RasterplanAenderung" ON x.rastergid = r.gid WHERE r."refBegruendung" IS NOT NULL;
INSERT INTO "XP_Basisobjekte"."XP_SpezExterneReferenz" (id,typ) SELECT "refText",9998 FROM "XP_Raster"."XP_RasterplanAenderung";
INSERT INTO "XP_Basisobjekte"."XP_Plan_externeReferenz" ("XP_Plan_gid", "externeReferenz")
SELECT x."gid", r."refText" FROM "XP_Basisobjekte"."XP_Plan_refBeschreibung" x JOIN "XP_Raster"."XP_RasterplanAenderung" ON x.rastergid = r.gid WHERE r."refText" IS NOT NULL;
ALTER TABLE "XP_Basisobjekte"."XP_Plan" DROP COLUMN rastergid; */

DROP SCHEMA "BP_Raster" CASCADE;
DROP SCHEMA "FP_Raster" CASCADE;
DROP TABLE "FP_Basisobjekte"."FP_Bereich_rasterAenderung";
DROP SCHEMA "LP_Raster" CASCADE;
DROP TABLE "LP_Basisobjekte"."LP_Bereich_rasterAenderung";
DROP SCHEMA "RP_Raster" CASCADE;
DROP TABLE "RP_Basisobjekte"."RP_Bereich_rasterAenderung";
DROP SCHEMA "SO_Raster" CASCADE;
DROP TABLE "XP_Raster"."XP_RasterplanAenderung" CASCADE;
DROP TABLE "XP_Raster"."XP_GeltungsbereichAenderung";
DROP SEQUENCE "XP_Raster"."XP_RasterplanAenderung_gid_seq";
DROP FUNCTION "XP_Raster"."child_of_XP_RasterplanAenderung"();
ALTER SEQUENCE "XP_Raster"."XP_RasterplanBasis_id_seq" RENAME TO "XP_Rasterdarstellung_id_seq";
ALTER TABLE "XP_Raster"."XP_RasterplanBasis" RENAME TO "XP_Rasterdarstellung";
ALTER TABLE "XP_Raster"."XP_Rasterdarstellung" RENAME CONSTRAINT "XP_RasterplanBasis_pkey" TO "XP_Rasterdarstellung_pkey";
ALTER TABLE "XP_Raster"."XP_Rasterdarstellung" RENAME CONSTRAINT "fk_XP_RasterplanBasis_XP_ExterneReferenz1" TO "fk_XP_Rasterdarstellung_XP_ExterneReferenz1";
COMMENT ON TABLE "XP_Raster"."XP_Rasterdarstellung" IS 'Georeferenzierte Rasterdarstellung eines Plans. Das über refScan referierte Rasterbild zeigt den Basisplan, dessen Geltungsbereich durch den Geltungsbereich des Gesamtplans (Attribut geltungsbereich von XP_Bereich) repräsentiert ist.
Im Standard sind nur georeferenzierte Rasterpläne zugelassen. Die über refScan referierte externe Referenz muss deshalb entweder vom Typ "PlanMitGeoreferenz" sein oder einen WMS-Request enthalten.';
ALTER TABLE "XP_Raster"."XP_RasterplanBasis_refScan" RENAME TO "XP_Rasterdarstellung_refScan";
ALTER TABLE "XP_Raster"."XP_Rasterdarstellung_refScan" RENAME "XP_RasterplanBasis_id" TO "XP_Rasterdarstellung_id";
ALTER TABLE "XP_Raster"."XP_Rasterdarstellung_refScan" RENAME CONSTRAINT "fk_XP_RasterplanBasis_refScan1" TO "fk_XP_Rasterdarstellung_refScan1";
ALTER TABLE "XP_Raster"."XP_Rasterdarstellung_refScan" RENAME CONSTRAINT "fk_XP_RasterplanBasis_refScan2" TO "fk_XP_Rasterdarstellung_refScan2";
ALTER TABLE "XP_Raster"."XP_RasterplanBasis_refLegende" RENAME TO "XP_Rasterdarstellung_refLegende";
ALTER TABLE "XP_Raster"."XP_Rasterdarstellung_refLegende" RENAME "XP_RasterplanBasis_id" TO "XP_Rasterdarstellung_id";
ALTER TABLE "XP_Raster"."XP_Rasterdarstellung_refLegende" RENAME CONSTRAINT "fk_XP_RasterplanBasis_refLegende1" TO "fk_XP_Rasterdarstellung_refLegende1";
ALTER TABLE "XP_Raster"."XP_Rasterdarstellung_refLegende" RENAME CONSTRAINT "fk_XP_RasterplanBasis_refLegende2" TO "fk_XP_Rasterdarstellung_refLegende2";

-- Änderung CR-057
UPDATE "XP_Enumerationen"."XP_ZweckbestimmungVerEntsorgung" SET "Code" = 100010 WHERE "Code" = 10010;
UPDATE "BP_Ver_und_Entsorgung"."BP_VerEntsorgung_zweckbestimmung" set "zweckbestimmung" = 10003 WHERE "zweckbestimmung" = 28000;
UPDATE "BP_Ver_und_Entsorgung"."BP_VerEntsorgung_zweckbestimmung" set "zweckbestimmung" = 10002 WHERE "zweckbestimmung" = 28001;
UPDATE "BP_Ver_und_Entsorgung"."BP_VerEntsorgung_zweckbestimmung" set "zweckbestimmung" = 10007 WHERE "zweckbestimmung" = 28002;
UPDATE "BP_Ver_und_Entsorgung"."BP_VerEntsorgung_zweckbestimmung" set "zweckbestimmung" = 10004 WHERE "zweckbestimmung" = 28003;
UPDATE "BP_Ver_und_Entsorgung"."BP_VerEntsorgung_zweckbestimmung" set "zweckbestimmung" = 2800 WHERE "zweckbestimmung" = 28004 AND "BP_VerEntsorgung_gid" NOT IN (SELECT "BP_VerEntsorgung_gid" FROM "BP_Ver_und_Entsorgung"."BP_VerEntsorgung_zweckbestimmung" WHERE "zweckbestimmung" = 2800);
UPDATE "FP_Ver_und_Entsorgung"."FP_VerEntsorgung_zweckbestimmung" set "zweckbestimmung" = 10003 WHERE "zweckbestimmung" = 28000;
UPDATE "FP_Ver_und_Entsorgung"."FP_VerEntsorgung_zweckbestimmung" set "zweckbestimmung" = 10002 WHERE "zweckbestimmung" = 28001;
UPDATE "FP_Ver_und_Entsorgung"."FP_VerEntsorgung_zweckbestimmung" set "zweckbestimmung" = 10007 WHERE "zweckbestimmung" = 28002;
UPDATE "FP_Ver_und_Entsorgung"."FP_VerEntsorgung_zweckbestimmung" set "zweckbestimmung" = 10004 WHERE "zweckbestimmung" = 28003;
UPDATE "FP_Ver_und_Entsorgung"."FP_VerEntsorgung_zweckbestimmung" set "zweckbestimmung" = 2800 WHERE "zweckbestimmung" = 28004 AND "FP_VerEntsorgung_gid" NOT IN (SELECT "FP_VerEntsorgung_gid" FROM "FP_Ver_und_Entsorgung"."FP_VerEntsorgung_zweckbestimmung" WHERE "zweckbestimmung" = 2800);

-- Änderung CR-058
COMMENT ON TABLE "BP_Sonstiges"."BP_TextlicheFestsetzungsFlaeche" IS 'Bereich in dem bestimmte Textliche Festsetzungen gültig sind, die über die Relation "refTextInhalt" (Basisklasse BP_Objekt) spezifiziert werden.';
COMMENT ON TABLE "LP_Sonstiges"."LP_TextlicheFestsetzungsFlaeche" IS 'Bereich in dem bestimmte textliche Festsetzungen gültig sind, die über die Relation "refTextInhalt" (Basisklasse LP_Objekt) spezifiziert werden.';
COMMENT ON TABLE "FP_Sonstiges"."FP_TextlicheDarstellungsFlaeche" IS 'Bereich in dem bestimmte Textliche Darstellungen gültig sind, die über die Relation "refTextInhalt" (Basisklasse FP_Objekt) spezifiziert werden.';
-- refTextInhalt war bisher nicht implementiert
-- -----------------------------------------------------
-- Table "BP_Basisobjekte"."BP_Objekt_refTextInhalt"
-- -----------------------------------------------------
CREATE TABLE "BP_Basisobjekte"."BP_Objekt_refTextInhalt" (
  "BP_Objekt_gid" BIGINT NOT NULL ,
  "refTextInhalt" INTEGER NOT NULL ,
  PRIMARY KEY ("BP_Objekt_gid", "refTextInhalt") ,
  CONSTRAINT "fk_refTextInhalt_BP_Objekt1"
    FOREIGN KEY ("BP_Objekt_gid" )
    REFERENCES "BP_Basisobjekte"."BP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_refTextInhalt_BP_TextAbschnitt1"
    FOREIGN KEY ("refTextInhalt" )
    REFERENCES "BP_Basisobjekte"."BP_TextAbschnitt" ("id" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
GRANT SELECT ON "BP_Basisobjekte"."BP_Objekt_refTextInhalt" TO xp_gast;
GRANT ALL ON "BP_Basisobjekte"."BP_Objekt_refTextInhalt" TO bp_user;
COMMENT ON TABLE "BP_Basisobjekte"."BP_Objekt_refTextInhalt" IS 'Referenz eines raumbezogenen Fachobjektes auf textuell formulierte Planinhalte, insbesondere textliche Festsetzungen.';
CREATE INDEX "idx_fk_refTextInhalt_BP_Objekt1" ON "BP_Basisobjekte"."BP_Objekt_refTextInhalt" ("BP_Objekt_gid");
CREATE INDEX "idx_fk_refTextInhalt_BP_TextAbschnitt1" ON "BP_Basisobjekte"."BP_Objekt_refTextInhalt" ("refTextInhalt");
-- Vorhandene Referenzen für BP_NebenanlagenAusschlussFlaeche_abweichungText werden im folgenden nicht mitgenommen:
ALTER TABLE "BP_Bebauung"."BP_NebenanlagenAusschlussFlaeche_abweichungText" DROP CONSTRAINT "fk_BP_NebenanlagenAusschlussFlaeche_abweichungText2";
ALTER TABLE "BP_Bebauung"."BP_NebenanlagenAusschlussFlaeche_abweichungText" ADD CONSTRAINT "fk_BP_NebenanlagenAusschlussFlaeche_abweichungText2"
    FOREIGN KEY ("abweichungText")
    REFERENCES "BP_Basisobjekte"."BP_TextAbschnitt" ("id")
    ON DELETE NO ACTION
    ON UPDATE CASCADE;
-- -----------------------------------------------------
-- Table "FP_Basisobjekte"."FP_Objekt_refTextInhalt"
-- -----------------------------------------------------
CREATE TABLE "FP_Basisobjekte"."FP_Objekt_refTextInhalt" (
  "FP_Objekt_gid" BIGINT NOT NULL ,
  "refTextInhalt" INTEGER NOT NULL ,
  PRIMARY KEY ("FP_Objekt_gid", "refTextInhalt") ,
  CONSTRAINT "fk_refTextInhalt_FP_Objekt1"
    FOREIGN KEY ("FP_Objekt_gid" )
    REFERENCES "FP_Basisobjekte"."FP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_refTextInhalt_FP_TextAbschnitt1"
    FOREIGN KEY ("refTextInhalt" )
    REFERENCES "FP_Basisobjekte"."FP_TextAbschnitt" ("id" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
GRANT SELECT ON "FP_Basisobjekte"."FP_Objekt_refTextInhalt" TO xp_gast;
GRANT ALL ON "FP_Basisobjekte"."FP_Objekt_refTextInhalt" TO bp_user;
COMMENT ON TABLE "FP_Basisobjekte"."FP_Objekt_refTextInhalt" IS 'Referenz eines raumbezogenen Fachobjektes auf textuell formulierte Planinhalte, insbesondere textliche Festsetzungen.';
CREATE INDEX "idx_fk_refTextInhalt_FP_Objekt1" ON "FP_Basisobjekte"."FP_Objekt_refTextInhalt" ("FP_Objekt_gid");
CREATE INDEX "idx_fk_refTextInhalt_FP_TextAbschnitt1" ON "FP_Basisobjekte"."FP_Objekt_refTextInhalt" ("refTextInhalt");
-- -----------------------------------------------------
-- Table "LP_Basisobjekte"."LP_Objekt_refTextInhalt"
-- -----------------------------------------------------
CREATE TABLE "LP_Basisobjekte"."LP_Objekt_refTextInhalt" (
  "LP_Objekt_gid" BIGINT NOT NULL ,
  "refTextInhalt" INTEGER NOT NULL ,
  PRIMARY KEY ("LP_Objekt_gid", "refTextInhalt") ,
  CONSTRAINT "fk_refTextInhalt_LP_Objekt1"
    FOREIGN KEY ("LP_Objekt_gid" )
    REFERENCES "LP_Basisobjekte"."LP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_refTextInhalt_LP_TextAbschnitt1"
    FOREIGN KEY ("refTextInhalt" )
    REFERENCES "LP_Basisobjekte"."LP_TextAbschnitt" ("id" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
GRANT SELECT ON "LP_Basisobjekte"."LP_Objekt_refTextInhalt" TO xp_gast;
GRANT ALL ON "LP_Basisobjekte"."LP_Objekt_refTextInhalt" TO bp_user;
COMMENT ON TABLE "LP_Basisobjekte"."LP_Objekt_refTextInhalt" IS 'Referenz eines raumbezogenen Fachobjektes auf textuell formulierte Planinhalte, insbesondere textliche Festsetzungen.';
CREATE INDEX "idx_fk_refTextInhalt_LP_Objekt1" ON "LP_Basisobjekte"."LP_Objekt_refTextInhalt" ("LP_Objekt_gid");
CREATE INDEX "idx_fk_refTextInhalt_LP_TextAbschnitt1" ON "LP_Basisobjekte"."LP_Objekt_refTextInhalt" ("refTextInhalt");
-- -----------------------------------------------------
-- Table "RP_Basisobjekte"."RP_TextAbschnitt"
-- -----------------------------------------------------
CREATE TABLE "RP_Basisobjekte"."RP_TextAbschnitt" (
  "id" BIGINT NOT NULL ,
  "rechtscharakter" INTEGER NOT NULL DEFAULT 9998,
  PRIMARY KEY ("id") ,
  CONSTRAINT "fk_RP_TextAbschnitt_rechtscharakter"
    FOREIGN KEY ("rechtscharakter")
    REFERENCES "RP_Basisobjekte"."RP_Rechtscharakter" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_RP_TextAbschnitt_parent"
    FOREIGN KEY ("id" )
    REFERENCES "XP_Basisobjekte"."XP_TextAbschnitt" ("id")
    ON DELETE CASCADE
    ON UPDATE CASCADE);
GRANT SELECT ON "RP_Basisobjekte"."RP_TextAbschnitt" TO xp_gast;
GRANT ALL ON "RP_Basisobjekte"."RP_TextAbschnitt" TO bp_user;
COMMENT ON TABLE  "RP_Basisobjekte"."RP_TextAbschnitt" IS 'Texlich formulierter Inhalt eines Raumordnungsplans, der einen anderen Rechtscharakter als das zugrunde liegende Fachobjekt hat (Attribut rechtscharakter des Fachobjektes), oder dem Plan als Ganzes zugeordnet ist.';
COMMENT ON COLUMN  "RP_Basisobjekte"."RP_TextAbschnitt"."id" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN  "RP_Basisobjekte"."RP_TextAbschnitt"."rechtscharakter" IS 'Rechtscharakter des textlich formulierten Planinhalts.';
CREATE INDEX "idx_fk_RP_TextAbschnitt_rechtscharakter" ON "RP_Basisobjekte"."RP_TextAbschnitt" ("rechtscharakter") ;
CREATE TRIGGER "change_to_RP_TextAbschnitt" BEFORE INSERT OR UPDATE ON "RP_Basisobjekte"."RP_TextAbschnitt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_TextAbschnitt"();
CREATE TRIGGER "delete_RP_TextAbschnitt" AFTER DELETE ON "RP_Basisobjekte"."RP_TextAbschnitt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_TextAbschnitt"();
-- -----------------------------------------------------
-- Table "RP_Basisobjekte"."RP_Objekt_refTextInhalt"
-- -----------------------------------------------------
CREATE TABLE "RP_Basisobjekte"."RP_Objekt_refTextInhalt" (
  "RP_Objekt_gid" BIGINT NOT NULL ,
  "refTextInhalt" INTEGER NOT NULL ,
  PRIMARY KEY ("RP_Objekt_gid", "refTextInhalt") ,
  CONSTRAINT "fk_refTextInhalt_RP_Objekt1"
    FOREIGN KEY ("RP_Objekt_gid" )
    REFERENCES "RP_Basisobjekte"."RP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_refTextInhalt_RP_TextAbschnitt1"
    FOREIGN KEY ("refTextInhalt" )
    REFERENCES "RP_Basisobjekte"."RP_TextAbschnitt" ("id" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
GRANT SELECT ON "RP_Basisobjekte"."RP_Objekt_refTextInhalt" TO xp_gast;
GRANT ALL ON "RP_Basisobjekte"."RP_Objekt_refTextInhalt" TO bp_user;
COMMENT ON TABLE "RP_Basisobjekte"."RP_Objekt_refTextInhalt" IS 'Referenz eines raumbezogenen Fachobjektes auf textuell formulierte Planinhalte, insbesondere textliche Festsetzungen.';
CREATE INDEX "idx_fk_refTextInhalt_RP_Objekt1" ON "RP_Basisobjekte"."RP_Objekt_refTextInhalt" ("RP_Objekt_gid");
CREATE INDEX "idx_fk_refTextInhalt_RP_TextAbschnitt1" ON "RP_Basisobjekte"."RP_Objekt_refTextInhalt" ("refTextInhalt");
-- -----------------------------------------------------
-- Table "SO_Basisobjekte"."SO_Objekt_refTextInhalt"
-- -----------------------------------------------------
CREATE TABLE "SO_Basisobjekte"."SO_Objekt_refTextInhalt" (
  "SO_Objekt_gid" BIGINT NOT NULL ,
  "refTextInhalt" INTEGER NOT NULL ,
  PRIMARY KEY ("SO_Objekt_gid", "refTextInhalt") ,
  CONSTRAINT "fk_refTextInhalt_SO_Objekt1"
    FOREIGN KEY ("SO_Objekt_gid" )
    REFERENCES "SO_Basisobjekte"."SO_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_refTextInhalt_SO_TextAbschnitt1"
    FOREIGN KEY ("refTextInhalt" )
    REFERENCES "SO_Basisobjekte"."SO_TextAbschnitt" ("id" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
GRANT SELECT ON "SO_Basisobjekte"."SO_Objekt_refTextInhalt" TO xp_gast;
GRANT ALL ON "SO_Basisobjekte"."SO_Objekt_refTextInhalt" TO bp_user;
COMMENT ON TABLE "SO_Basisobjekte"."SO_Objekt_refTextInhalt" IS 'Referenz eines raumbezogenen Fachobjektes auf textuell formulierte Planinhalte, insbesondere textliche Festsetzungen.';
CREATE INDEX "idx_fk_refTextInhalt_SO_Objekt1" ON "SO_Basisobjekte"."SO_Objekt_refTextInhalt" ("SO_Objekt_gid");
CREATE INDEX "idx_fk_refTextInhalt_SO_TextAbschnitt1" ON "SO_Basisobjekte"."SO_Objekt_refTextInhalt" ("refTextInhalt");

-- Änderung CR-059
-- keine Relevanz

-- Änderung CR-061
ALTER TABLE "BP_Basisobjekte"."BP_Bereich" ADD COLUMN "versionSonstRechtsgrundlageDatum" DATE;
ALTER TABLE "BP_Basisobjekte"."BP_Bereich" ADD COLUMN "versionSonstRechtsgrundlageText" VARCHAR(255);
COMMENT ON COLUMN "BP_Basisobjekte"."BP_Bereich"."versionSonstRechtsgrundlageDatum" IS 'Datum einer zugrunde liegenden anderen Rechtsgrundlage als BauGB / BauNVO.';
COMMENT ON COLUMN "BP_Basisobjekte"."BP_Bereich"."versionSonstRechtsgrundlageText" IS 'Textliche Spezifikation einer zugrunde liegenden anderen Rechtsgrundlage als BauGB / BauNVO.';
ALTER TABLE "FP_Basisobjekte"."FP_Bereich" ADD COLUMN "versionSonstRechtsgrundlageDatum" DATE;
ALTER TABLE "FP_Basisobjekte"."FP_Bereich" ADD COLUMN "versionSonstRechtsgrundlageText" VARCHAR(255);
COMMENT ON COLUMN "FP_Basisobjekte"."FP_Bereich"."versionSonstRechtsgrundlageDatum" IS 'Datum einer zugrunde liegenden anderen Rechtsgrundlage als BauGB / BauNVO.';
COMMENT ON COLUMN "FP_Basisobjekte"."FP_Bereich"."versionSonstRechtsgrundlageText" IS 'Textliche Spezifikation einer zugrunde liegenden anderen Rechtsgrundlage als BauGB / BauNVO.';

-- Änderung CR-062
-- keine Relevanz, da Attribut nicht implementiert war

-- Änderung CR-063
ALTER TABLE "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_SchutzPflegeEntwicklungsFlaeche" ADD COLUMN "sonstZiel" VARCHAR(255);
COMMENT ON COLUMN "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_SchutzPflegeEntwicklungsFlaeche"."sonstZiel" IS 'Textlich formuliertes Ziel, wenn das Attribut ziel den Wert 9999 (Sonstiges) hat.';
ALTER TABLE "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_SchutzPflegeEntwicklungsMassnahme" ADD COLUMN "sonstZiel" VARCHAR(255);
COMMENT ON COLUMN "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_SchutzPflegeEntwicklungsMassnahme"."sonstZiel" IS 'Textlich formuliertes Ziel, wenn das Attribut ziel den Wert 9999 (Sonstiges) hat.';
ALTER TABLE "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_AusgleichsFlaeche" ADD COLUMN "sonstZiel" VARCHAR(255);
COMMENT ON COLUMN "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_AusgleichsFlaeche"."sonstZiel" IS 'Textlich formuliertes Ziel, wenn das Attribut ziel den Wert 9999 (Sonstiges) hat.';
ALTER TABLE "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_AusgleichsMassnahme" ADD COLUMN "sonstZiel" VARCHAR(255);
COMMENT ON COLUMN "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_AusgleichsMassnahme"."sonstZiel" IS 'Textlich formuliertes Ziel, wenn das Attribut ziel den Wert 9999 (Sonstiges) hat.';
ALTER TABLE "FP_Naturschutz"."FP_SchutzPflegeEntwicklung" ADD COLUMN "sonstZiel" VARCHAR(255);
COMMENT ON COLUMN "FP_Naturschutz"."FP_SchutzPflegeEntwicklung"."sonstZiel" IS 'Textlich formuliertes Ziel, wenn das Attribut ziel den Wert 9999 (Sonstiges) hat.';

-- Änderung CR-065 und CR-026
-- -----------------------------------------------------
-- Table "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_VegetationsobjektTypen"
-- -----------------------------------------------------
CREATE TABLE "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_VegetationsobjektTypen" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Code") );
GRANT SELECT ON "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_VegetationsobjektTypen" TO xp_gast;
ALTER TABLE "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_AnpflanzungBindungErhaltung" ADD COLUMN "baumArt" INTEGER;
COMMENT ON COLUMN "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_AnpflanzungBindungErhaltung"."baumArt" IS 'Spezifikation einer Baumart.';
ALTER TABLE "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_AnpflanzungBindungErhaltung" ADD CONSTRAINT "fk_LP_AnpflanzungBindungErhaltung_baumArt"
    FOREIGN KEY ("baumArt") REFERENCES "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_VegetationsobjektTypen" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE;

-- Änderung CR-066
ALTER TABLE "BP_Verkehr"."BP_EinfahrtsbereichLinie" ADD COLUMN "typ" INTEGER;
ALTER TABLE "BP_Verkehr"."BP_EinfahrtsbereichLinie" ADD CONSTRAINT "fk_BP_EinfahrtsbereichLinie_typ"
    FOREIGN KEY ("typ" )
    REFERENCES "BP_Verkehr"."BP_EinfahrtTypen" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE;
COMMENT ON COLUMN "BP_Verkehr"."BP_EinfahrtsbereichLinie"."typ" IS 'Typ der Einfahrt';

-- Änderung CR-068
-- -----------------------------------------------------
-- Table "BP_Bebauung"."BP_GestaltungBaugebiet_detaillierteDachform"
-- -----------------------------------------------------
CREATE TABLE "BP_Bebauung"."BP_GestaltungBaugebiet_detaillierteDachform" (
  "BP_GestaltungBaugebiet_gid" BIGINT NOT NULL ,
  "detaillierteDachform" INTEGER NOT NULL ,
  PRIMARY KEY ("BP_GestaltungBaugebiet_gid", "detaillierteDachform"),
  CONSTRAINT "fk_BP_GestaltungBaugebiet_detaillierteDachform1"
    FOREIGN KEY ("BP_GestaltungBaugebiet_gid")
    REFERENCES "BP_Bebauung"."BP_GestaltungBaugebiet" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_BP_GestaltungBaugebiet_detaillierteDachform2"
    FOREIGN KEY ("detaillierteDachform")
    REFERENCES "BP_Bebauung"."BP_DetailDachform" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
GRANT SELECT ON TABLE "BP_Bebauung"."BP_GestaltungBaugebiet_detaillierteDachform" TO xp_gast;
GRANT ALL ON TABLE "BP_Bebauung"."BP_GestaltungBaugebiet_detaillierteDachform" TO bp_user;
COMMENT ON TABLE "BP_Bebauung"."BP_GestaltungBaugebiet_detaillierteDachform" IS 'Über eine Codeliste definiertere detailliertere Dachform.
Der an einer bestimmten Listenposition aufgeführte Wert von "detaillierteDachform" bezieht sich auf den an gleicher Position stehenden Attributwert von dachform.';
INSERT INTO "BP_Bebauung"."BP_GestaltungBaugebiet_detaillierteDachform" ("BP_GestaltungBaugebiet_gid","detaillierteDachform")
SELECT gid,"detaillierteDachform" FROM "BP_Bebauung"."BP_GestaltungBaugebiet" WHERE "detaillierteDachform" IS NOT NULL;
ALTER TABLE "BP_Bebauung"."BP_GestaltungBaugebiet" DROP COLUMN "detaillierteDachform";

-- Änderung CR-069
ALTER TABLE "BP_Bebauung"."BP_FestsetzungenBaugebiet" DROP COLUMN "BMmin";
ALTER TABLE "BP_Bebauung"."BP_FestsetzungenBaugebiet" DROP COLUMN "BMmax";
ALTER TABLE "BP_Bebauung"."BP_FestsetzungenBaugebiet" DROP COLUMN "BMZmin";
ALTER TABLE "BP_Bebauung"."BP_FestsetzungenBaugebiet" DROP COLUMN "BMZmax";

-- Änderung CR-073
-- war bereits implementiert

-- Änderung CR-074
-- s.o.

-- Änderung CR-076

CREATE TABLE  "BP_Bebauung"."BP_Zulaessigkeit" (
  "Code" INTEGER NOT NULL,
  "Bezeichner" VARCHAR(64) NOT NULL,
  PRIMARY KEY ("Code"));
GRANT SELECT ON "BP_Bebauung"."BP_Zulaessigkeit" TO xp_gast;

INSERT INTO "BP_Bebauung"."BP_Zulaessigkeit" ("Code", "Bezeichner") VALUES (1000, 'Zulaessig');
INSERT INTO "BP_Bebauung"."BP_Zulaessigkeit" ("Code", "Bezeichner") VALUES (2000, 'NichtZulaessig');
INSERT INTO "BP_Bebauung"."BP_Zulaessigkeit" ("Code", "Bezeichner") VALUES (3000, 'AusnahmsweiseZulaessig');

ALTER TABLE "BP_Bebauung"."BP_BaugebietsTeilFlaeche" ADD COLUMN "wohnnutzungEGStrasse" INTEGER;
ALTER TABLE "BP_Bebauung"."BP_BaugebietsTeilFlaeche" ADD CONSTRAINT "fk_BP_BaugebietsTeilFlaeche_BP_Zulaessigkeit"
    FOREIGN KEY ("wohnnutzungEGStrasse")
    REFERENCES "BP_Bebauung"."BP_Zulaessigkeit" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE;
ALTER TABLE "BP_Bebauung"."BP_BaugebietsTeilFlaeche" ADD COLUMN "ZWohn" INTEGER;
ALTER TABLE "BP_Bebauung"."BP_BaugebietsTeilFlaeche" ADD COLUMN "GFAntWohnen" INTEGER;
ALTER TABLE "BP_Bebauung"."BP_BaugebietsTeilFlaeche" ADD COLUMN "GFWohnen" INTEGER;
ALTER TABLE "BP_Bebauung"."BP_BaugebietsTeilFlaeche" ADD COLUMN "GFAntGewerbe" INTEGER;
ALTER TABLE "BP_Bebauung"."BP_BaugebietsTeilFlaeche" ADD COLUMN "GFGewerbe" INTEGER;
COMMENT ON COLUMN "BP_Bebauung"."BP_BaugebietsTeilFlaeche"."wohnnutzungEGStrasse" IS 'Festsetzung nach §6a Abs. (4) Nr. 1 BauNVO: Für urbane Gebiete oder Teile solcher Gebiete kann festgesetzt werden, dass in Gebäuden im Erdgeschoss an der Straßenseite eine Wohnnutzung nicht oder nur ausnahmsweise zulässig ist.';
COMMENT ON COLUMN "BP_Bebauung"."BP_BaugebietsTeilFlaeche"."ZWohn" IS 'Festsetzung nach §4a Abs. (4) Nr. 1 bzw. nach §6a Abs. (4) Nr. 2 BauNVO: Für besondere Wohngebiete und urbane Gebiete oder Teile solcher Gebiete kann festgesetzt werden, dass in Gebäuden oberhalb eines im Bebauungsplan bestimmten Geschosses nur Wohnungen zulässig sind.';
COMMENT ON COLUMN "BP_Bebauung"."BP_BaugebietsTeilFlaeche"."GFAntWohnen" IS 'Festsetzung nach §4a Abs. (4) Nr. 2 bzw. §6a Abs. (4) Nr. 3 BauNVO: Für besondere Wohngebiete und urbane Gebiete oder Teile solcher Gebiete kann festgesetzt werden, dass in Gebäuden ein im Bebauungsplan bestimmter Anteil der zulässigen Geschossfläche für Wohnungen zu verwenden ist.';
COMMENT ON COLUMN "BP_Bebauung"."BP_BaugebietsTeilFlaeche"."GFWohnen" IS 'Festsetzung nach §4a Abs. (4) Nr. 2 bzw. §6a Abs. (4) Nr. 3 BauNVO: Für besondere Wohngebiete und urbane Gebiete oder Teile solcher Gebiete kann festgesetzt werden, dass in Gebäuden eine im Bebauungsplan bestimmte Größe der Geschossfläche für Wohnungen zu verwenden ist.';
COMMENT ON COLUMN "BP_Bebauung"."BP_BaugebietsTeilFlaeche"."GFAntGewerbe" IS 'Festsetzung nach §6a Abs. (4) Nr. 4 BauNVO: Für urbane Gebiete oder Teile solcher Gebiete kann festgesetzt werden, dass in Gebäuden ein im Bebauungsplan bestimmter Anteil der zulässigen Geschossfläche für gewerbliche Nutzungen zu verwenden ist.';
COMMENT ON COLUMN "BP_Bebauung"."BP_BaugebietsTeilFlaeche"."GFGewerbe" IS 'Festsetzung nach §6a Abs. (4) Nr. 4 BauNVO: Für urbane Gebiete oder Teile solcher Gebiete kann festgesetzt werden, dass in Gebäuden eine im Bebauungsplan bestimmte Größe der Geschossfläche für gewerbliche Nutzungen zu verwenden ist.';
ALTER TABLE "BP_Bebauung"."BP_UeberbaubareGrundstuecksFlaeche" ADD COLUMN "wohnnutzungEGStrasse" INTEGER;
ALTER TABLE "BP_Bebauung"."BP_UeberbaubareGrundstuecksFlaeche" ADD CONSTRAINT "fk_BP_UeberbaubareGrundstuecksFlaeche_BP_Zulaessigkeit"
    FOREIGN KEY ("wohnnutzungEGStrasse")
    REFERENCES "BP_Bebauung"."BP_Zulaessigkeit" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE;
ALTER TABLE "BP_Bebauung"."BP_UeberbaubareGrundstuecksFlaeche" ADD COLUMN "ZWohn" INTEGER;
ALTER TABLE "BP_Bebauung"."BP_UeberbaubareGrundstuecksFlaeche" ADD COLUMN "GFAntWohnen" INTEGER;
ALTER TABLE "BP_Bebauung"."BP_UeberbaubareGrundstuecksFlaeche" ADD COLUMN "GFWohnen" INTEGER;
ALTER TABLE "BP_Bebauung"."BP_UeberbaubareGrundstuecksFlaeche" ADD COLUMN "GFAntGewerbe" INTEGER;
ALTER TABLE "BP_Bebauung"."BP_UeberbaubareGrundstuecksFlaeche" ADD COLUMN "GFGewerbe" INTEGER;
COMMENT ON COLUMN "BP_Bebauung"."BP_UeberbaubareGrundstuecksFlaeche"."wohnnutzungEGStrasse" IS 'Festsetzung nach §6a Abs. (4) Nr. 1 BauNVO: Für urbane Gebiete oder Teile solcher Gebiete kann festgesetzt werden, dass in Gebäuden im Erdgeschoss an der Straßenseite eine Wohnnutzung nicht oder nur ausnahmsweise zulässig ist.';
COMMENT ON COLUMN "BP_Bebauung"."BP_UeberbaubareGrundstuecksFlaeche"."ZWohn" IS 'Festsetzung nach §4a Abs. (4) Nr. 1 bzw. nach §6a Abs. (4) Nr. 2 BauNVO: Für besondere Wohngebiete und urbane Gebiete oder Teile solcher Gebiete kann festgesetzt werden, dass in Gebäuden oberhalb eines im Bebauungsplan bestimmten Geschosses nur Wohnungen zulässig sind.';
COMMENT ON COLUMN "BP_Bebauung"."BP_UeberbaubareGrundstuecksFlaeche"."GFAntWohnen" IS 'Festsetzung nach §4a Abs. (4) Nr. 2 bzw. §6a Abs. (4) Nr. 3 BauNVO: Für besondere Wohngebiete und urbane Gebiete oder Teile solcher Gebiete kann festgesetzt werden, dass in Gebäuden ein im Bebauungsplan bestimmter Anteil der zulässigen Geschossfläche für Wohnungen zu verwenden ist.';
COMMENT ON COLUMN "BP_Bebauung"."BP_UeberbaubareGrundstuecksFlaeche"."GFWohnen" IS 'Festsetzung nach §4a Abs. (4) Nr. 2 bzw. §6a Abs. (4) Nr. 3 BauNVO: Für besondere Wohngebiete und urbane Gebiete oder Teile solcher Gebiete kann festgesetzt werden, dass in Gebäuden eine im Bebauungsplan bestimmte Größe der Geschossfläche für Wohnungen zu verwenden ist.';
COMMENT ON COLUMN "BP_Bebauung"."BP_UeberbaubareGrundstuecksFlaeche"."GFAntGewerbe" IS 'Festsetzung nach §6a Abs. (4) Nr. 4 BauNVO: Für urbane Gebiete oder Teile solcher Gebiete kann festgesetzt werden, dass in Gebäuden ein im Bebauungsplan bestimmter Anteil der zulässigen Geschossfläche für gewerbliche Nutzungen zu verwenden ist.';
COMMENT ON COLUMN "BP_Bebauung"."BP_UeberbaubareGrundstuecksFlaeche"."GFGewerbe" IS 'Festsetzung nach §6a Abs. (4) Nr. 4 BauNVO: Für urbane Gebiete oder Teile solcher Gebiete kann festgesetzt werden, dass in Gebäuden eine im Bebauungsplan bestimmte Größe der Geschossfläche für gewerbliche Nutzungen zu verwenden ist.';

-- Änderung CR-077
-- FP
ALTER TABLE "FP_Basisobjekte"."FP_Plan" ADD COLUMN "auslegungsStartDatumNew" DATE[];
ALTER TABLE "FP_Basisobjekte"."FP_Plan" ADD COLUMN "auslegungsEndDatumNew" DATE[];
ALTER TABLE "FP_Basisobjekte"."FP_Plan" ADD COLUMN "traegerbeteiligungsStartDatumNew" DATE[];
ALTER TABLE "FP_Basisobjekte"."FP_Plan" ADD COLUMN "traegerbeteiligungsEndDatumNew" DATE[];
UPDATE "FP_Basisobjekte"."FP_Plan" SET "auslegungsStartDatumNew" = ARRAY["auslegungsStartDatum"] WHERE "auslegungsStartDatum" IS NOT NULL;
UPDATE "FP_Basisobjekte"."FP_Plan" SET "auslegungsEndDatumNew" = ARRAY["auslegungsEndDatum"] WHERE "auslegungsEndDatum" IS NOT NULL;
UPDATE "FP_Basisobjekte"."FP_Plan" SET "traegerbeteiligungsStartDatumNew" = ARRAY["traegerbeteiligungsStartDatum"] WHERE "traegerbeteiligungsStartDatum" IS NOT NULL;
UPDATE "FP_Basisobjekte"."FP_Plan" SET "traegerbeteiligungsEndDatumNew" = ARRAY["traegerbeteiligungsEndDatum"] WHERE "traegerbeteiligungsEndDatum" IS NOT NULL;
ALTER TABLE "FP_Basisobjekte"."FP_Plan" DROP COLUMN "auslegungsStartDatum";
ALTER TABLE "FP_Basisobjekte"."FP_Plan" DROP COLUMN "auslegungsEndDatum";
ALTER TABLE "FP_Basisobjekte"."FP_Plan" DROP COLUMN "traegerbeteiligungsStartDatum";
ALTER TABLE "FP_Basisobjekte"."FP_Plan" DROP COLUMN "traegerbeteiligungsEndDatum";
ALTER TABLE "FP_Basisobjekte"."FP_Plan" RENAME "auslegungsStartDatumNew" TO "auslegungsStartDatum";
ALTER TABLE "FP_Basisobjekte"."FP_Plan" RENAME "auslegungsEndDatumNew" TO "auslegungsEndDatum";
ALTER TABLE "FP_Basisobjekte"."FP_Plan" RENAME "traegerbeteiligungsStartDatumNew" TO "traegerbeteiligungsStartDatum";
ALTER TABLE "FP_Basisobjekte"."FP_Plan" RENAME "traegerbeteiligungsEndDatumNew" TO "traegerbeteiligungsEndDatum";
COMMENT ON COLUMN "FP_Basisobjekte"."FP_Plan"."auslegungsStartDatum" IS 'Start-Datum der öffentlichen Auslegung. Bei mehrfacher öffentlicher Auslegung können mehrere Datumsangaben spezifiziert werden.';
COMMENT ON COLUMN "FP_Basisobjekte"."FP_Plan"."auslegungsEndDatum" IS 'End-Datum der öffentlichen Auslegung. Bei mehrfacher öffentlicher Auslegung können mehrere Datumsangaben spezifiziert werden.';
COMMENT ON COLUMN "FP_Basisobjekte"."FP_Plan"."traegerbeteiligungsStartDatum" IS 'Start-Datum der Trägerbeteiligung. Bei mehrfacher Trägerbeteiligung können mehrere Datumsangaben spezifiziert werden.';
COMMENT ON COLUMN "FP_Basisobjekte"."FP_Plan"."traegerbeteiligungsEndDatum" IS 'End-Datum der Trägerbeteiligung. Bei mehrfacher Trägerbeteiligung können mehrere Datumsangaben spezifiziert werden.';
-- RP
ALTER TABLE "RP_Basisobjekte"."RP_Plan" ADD COLUMN "auslegungsStartDatumNew" DATE[];
ALTER TABLE "RP_Basisobjekte"."RP_Plan" ADD COLUMN "auslegungsEndDatumNew" DATE[];
ALTER TABLE "RP_Basisobjekte"."RP_Plan" ADD COLUMN "traegerbeteiligungsStartDatumNew" DATE[];
ALTER TABLE "RP_Basisobjekte"."RP_Plan" ADD COLUMN "traegerbeteiligungsEndDatumNew" DATE[];
UPDATE "RP_Basisobjekte"."RP_Plan" SET "auslegungsStartDatumNew" = ARRAY["auslegungsStartDatum"] WHERE "auslegungsStartDatum" IS NOT NULL;
UPDATE "RP_Basisobjekte"."RP_Plan" SET "auslegungsEndDatumNew" = ARRAY["auslegungsEndDatum"] WHERE "auslegungsEndDatum" IS NOT NULL;
UPDATE "RP_Basisobjekte"."RP_Plan" SET "traegerbeteiligungsStartDatumNew" = ARRAY["traegerbeteiligungsStartDatum"] WHERE "traegerbeteiligungsStartDatum" IS NOT NULL;
UPDATE "RP_Basisobjekte"."RP_Plan" SET "traegerbeteiligungsEndDatumNew" = ARRAY["traegerbeteiligungsEndDatum"] WHERE "traegerbeteiligungsEndDatum" IS NOT NULL;
ALTER TABLE "RP_Basisobjekte"."RP_Plan" DROP COLUMN "auslegungsStartDatum";
ALTER TABLE "RP_Basisobjekte"."RP_Plan" DROP COLUMN "auslegungsEndDatum";
ALTER TABLE "RP_Basisobjekte"."RP_Plan" DROP COLUMN "traegerbeteiligungsStartDatum";
ALTER TABLE "RP_Basisobjekte"."RP_Plan" DROP COLUMN "traegerbeteiligungsEndDatum";
ALTER TABLE "RP_Basisobjekte"."RP_Plan" RENAME "auslegungsStartDatumNew" TO "auslegungsStartDatum";
ALTER TABLE "RP_Basisobjekte"."RP_Plan" RENAME "auslegungsEndDatumNew" TO "auslegungsEndDatum";
ALTER TABLE "RP_Basisobjekte"."RP_Plan" RENAME "traegerbeteiligungsStartDatumNew" TO "traegerbeteiligungsStartDatum";
ALTER TABLE "RP_Basisobjekte"."RP_Plan" RENAME "traegerbeteiligungsEndDatumNew" TO "traegerbeteiligungsEndDatum";
COMMENT ON COLUMN "RP_Basisobjekte"."RP_Plan"."auslegungsStartDatum" IS 'Start-Datum der öffentlichen Auslegung. Bei mehrfacher öffentlicher Auslegung können mehrere Datumsangaben spezifiziert werden.';
COMMENT ON COLUMN "RP_Basisobjekte"."RP_Plan"."auslegungsEndDatum" IS 'End-Datum der öffentlichen Auslegung. Bei mehrfacher öffentlicher Auslegung können mehrere Datumsangaben spezifiziert werden.';
COMMENT ON COLUMN "RP_Basisobjekte"."RP_Plan"."traegerbeteiligungsStartDatum" IS 'Start-Datum der Trägerbeteiligung. Bei mehrfacher Trägerbeteiligung können mehrere Datumsangaben spezifiziert werden.';
COMMENT ON COLUMN "RP_Basisobjekte"."RP_Plan"."traegerbeteiligungsEndDatum" IS 'End-Datum der Trägerbeteiligung. Bei mehrfacher Trägerbeteiligung können mehrere Datumsangaben spezifiziert werden.';
-- LP
ALTER TABLE "LP_Basisobjekte"."LP_Plan" ADD COLUMN "auslegungsDatumNew" DATE[];
ALTER TABLE "LP_Basisobjekte"."LP_Plan" ADD COLUMN "tOeBbeteiligungsDatumNew" DATE[];
ALTER TABLE "LP_Basisobjekte"."LP_Plan" ADD COLUMN "oeffentlichkeitsbeteiligungDatumNew" DATE[];
UPDATE "LP_Basisobjekte"."LP_Plan" SET "auslegungsDatumNew" = ARRAY["auslegungsDatum"] WHERE "auslegungsDatum" IS NOT NULL;
UPDATE "LP_Basisobjekte"."LP_Plan" SET "tOeBbeteiligungsDatumNew" = ARRAY["tOeBbeteiligungsDatum"] WHERE "tOeBbeteiligungsDatum" IS NOT NULL;
UPDATE "LP_Basisobjekte"."LP_Plan" SET "oeffentlichkeitsbeteiligungDatumNew" = ARRAY["oeffentlichkeitsbeteiligungDatum"] WHERE "oeffentlichkeitsbeteiligungDatum" IS NOT NULL;
ALTER TABLE "LP_Basisobjekte"."LP_Plan" DROP COLUMN "auslegungsDatum";
ALTER TABLE "LP_Basisobjekte"."LP_Plan" DROP COLUMN "tOeBbeteiligungsDatum";
ALTER TABLE "LP_Basisobjekte"."LP_Plan" DROP COLUMN "oeffentlichkeitsbeteiligungDatum";
ALTER TABLE "LP_Basisobjekte"."LP_Plan" RENAME "auslegungsDatumNew" TO "auslegungsDatum";
ALTER TABLE "LP_Basisobjekte"."LP_Plan" RENAME "tOeBbeteiligungsDatumNew" TO "tOeBbeteiligungsDatum";
ALTER TABLE "LP_Basisobjekte"."LP_Plan" RENAME "oeffentlichkeitsbeteiligungDatumNew" TO "oeffentlichkeitsbeteiligungDatum";
COMMENT ON COLUMN "LP_Basisobjekte"."LP_Plan"."auslegungsDatum" IS 'Datum der öffentlichen Auslegung.';
COMMENT ON COLUMN "LP_Basisobjekte"."LP_Plan"."tOeBbeteiligungsDatum" IS 'Datum der Beteiligung der Träger öffentlicher Belange.';
COMMENT ON COLUMN "LP_Basisobjekte"."LP_Plan"."oeffentlichkeitsbeteiligungDatum" IS 'Datum der Öffentlichkeits-Beteiligung.';

-- Änderung CR-079
-- BP
ALTER TABLE "BP_Basisobjekte"."BP_Punktobjekt" ADD COLUMN "nordwinkel" INTEGER;
COMMENT ON COLUMN "BP_Basisobjekte"."BP_Punktobjekt"."nordwinkel" IS 'Orientierung des Punktobjektes als Winkel gegen die Nordrichtung. Zählweise im geographischen Sinn (von Nord über Ost nach Süd und West).';
UPDATE "BP_Verkehr"."BP_EinfahrtPunkt" SET "nordwinkel" = "richtung" WHERE "richtung" != 0;
ALTER TABLE "BP_Verkehr"."BP_EinfahrtPunkt" DROP COLUMN "richtung";
ALTER TABLE "FP_Basisobjekte"."FP_Punktobjekt" ADD COLUMN "nordwinkel" INTEGER;
COMMENT ON COLUMN "FP_Basisobjekte"."FP_Punktobjekt"."nordwinkel" IS 'Orientierung des Punktobjektes als Winkel gegen die Nordrichtung. Zählweise im geographischen Sinn (von Nord über Ost nach Süd und West).';
ALTER TABLE "SO_Basisobjekte"."SO_Punktobjekt" ADD COLUMN "nordwinkel" INTEGER;
COMMENT ON COLUMN "SO_Basisobjekte"."SO_Punktobjekt"."nordwinkel" IS 'Orientierung des Punktobjektes als Winkel gegen die Nordrichtung. Zählweise im geographischen Sinn (von Nord über Ost nach Süd und West).';
ALTER TABLE "LP_Basisobjekte"."LP_Punktobjekt" ADD COLUMN "nordwinkel" INTEGER;
COMMENT ON COLUMN "LP_Basisobjekte"."LP_Punktobjekt"."nordwinkel" IS 'Orientierung des Punktobjektes als Winkel gegen die Nordrichtung. Zählweise im geographischen Sinn (von Nord über Ost nach Süd und West).';

-- Änderung CR-080
-- s.o.

-- Änderung CR-081
-- Vorbereitung; der Plan ist es, das zugehöriges XP_Objekt zu übernehmen, damit bleibt auch die Bereichszuordnung bestehen
ALTER TABLE "SO_Basisobjekte"."SO_Objekt" DISABLE TRIGGER "change_to_SO_Objekt"; -- damit wird bei INSERT kein XP_Objekt angelegt
-- BP, refTextInhalt wird nicht übernommen!
ALTER TABLE "BP_Basisobjekte"."BP_Objekt" DISABLE TRIGGER "delete_BP_Objekt"; -- damit wird bei DELETE das XP_Objekt nicht gelöscht
INSERT INTO "SO_NachrichtlicheUebernahmen"."SO_DenkmalschutzrechtFlaeche" (gid, position, flaechenschluss) SELECT gid, position, flaechenschluss FROM "BP_Erhaltungssatzung_und_Denkmalschutz"."BP_DenkmalschutzEinzelanlageFlaeche";
INSERT INTO "SO_NachrichtlicheUebernahmen"."SO_DenkmalschutzrechtLinie" (gid, position) SELECT gid, position FROM "BP_Erhaltungssatzung_und_Denkmalschutz"."BP_DenkmalschutzEinzelanlageLinie";
INSERT INTO "SO_NachrichtlicheUebernahmen"."SO_DenkmalschutzrechtPunkt" (gid, position) SELECT gid, position FROM "BP_Erhaltungssatzung_und_Denkmalschutz"."BP_DenkmalschutzEinzelanlagePunkt";
UPDATE "SO_NachrichtlicheUebernahmen"."SO_Denkmalschutzrecht" so SET "name" = (SELECT "denkmal" FROM "BP_Erhaltungssatzung_und_Denkmalschutz"."BP_DenkmalschutzEinzelanlage" bp WHERE bp.gid = so.gid) WHERE gid in (SELECT gid from "BP_Erhaltungssatzung_und_Denkmalschutz"."BP_DenkmalschutzEinzelanlage" WHERE "name" IS NOT NULL);
UPDATE "SO_Basisobjekte"."SO_Objekt" so SET "rechtscharakter" = (SELECT "rechtscharakter" FROM "BP_Basisobjekte"."BP_Objekt" bp WHERE bp.gid = so.gid) WHERE gid in (SELECT gid from "BP_Erhaltungssatzung_und_Denkmalschutz"."BP_DenkmalschutzEinzelanlage");
INSERT INTO "SO_NachrichtlicheUebernahmen"."SO_DenkmalschutzrechtFlaeche" (gid, position, flaechenschluss) SELECT gid, position, flaechenschluss FROM"BP_Erhaltungssatzung_und_Denkmalschutz"."BP_DenkmalschutzEnsembleFlaeche";
UPDATE "SO_NachrichtlicheUebernahmen"."SO_Denkmalschutzrecht" so SET "name" = (SELECT "denkmal" FROM "BP_Erhaltungssatzung_und_Denkmalschutz"."BP_DenkmalschutzEnsembleFlaeche" bp WHERE bp.gid = so.gid) WHERE gid in (SELECT gid from "BP_Erhaltungssatzung_und_Denkmalschutz"."BP_DenkmalschutzEnsembleFlaeche" WHERE "name" IS NOT NULL);
UPDATE "SO_Basisobjekte"."SO_Objekt" so SET "rechtscharakter" = (SELECT "rechtscharakter" FROM "BP_Basisobjekte"."BP_Objekt" bp WHERE bp.gid = so.gid) WHERE gid in (SELECT gid from "BP_Erhaltungssatzung_und_Denkmalschutz"."BP_DenkmalschutzEnsembleFlaeche");
DELETE FROM "BP_Erhaltungssatzung_und_Denkmalschutz"."BP_DenkmalschutzEinzelanlage";
DROP TABLE "BP_Erhaltungssatzung_und_Denkmalschutz"."BP_DenkmalschutzEinzelanlageFlaeche" CASCADE;
DROP TABLE "BP_Erhaltungssatzung_und_Denkmalschutz"."BP_DenkmalschutzEinzelanlageLinie" CASCADE;
DROP TABLE "BP_Erhaltungssatzung_und_Denkmalschutz"."BP_DenkmalschutzEinzelanlagePunkt" CASCADE;
DROP TABLE "BP_Erhaltungssatzung_und_Denkmalschutz"."BP_DenkmalschutzEinzelanlage" CASCADE;
DELETE FROM "BP_Erhaltungssatzung_und_Denkmalschutz"."BP_DenkmalschutzEnsembleFlaeche";
DROP TABLE "BP_Erhaltungssatzung_und_Denkmalschutz"."BP_DenkmalschutzEnsembleFlaeche" CASCADE;
ALTER TABLE "BP_Basisobjekte"."BP_Objekt" ENABLE TRIGGER "delete_BP_Objekt";
-- LP
ALTER TABLE "LP_Basisobjekte"."LP_Objekt" DISABLE TRIGGER "delete_LP_Objekt"; -- damit wird bei DELETE das XP_Objekt nicht gelöscht
INSERT INTO "SO_NachrichtlicheUebernahmen"."SO_DetailKlassifizNachDenkmalschutzrecht" ("Code", "Bezeichner") SELECT "Code", "Bezeichner" FROM "LP_SchutzgebieteObjekte"."LP_DenkmalschutzrechtDetailTypen";
INSERT INTO "SO_NachrichtlicheUebernahmen"."SO_DenkmalschutzrechtFlaeche" (gid, position) SELECT gid, position FROM "LP_SchutzgebieteObjekte"."LP_DenkmalschutzrechtFlaeche";
INSERT INTO "SO_NachrichtlicheUebernahmen"."SO_DenkmalschutzrechtLinie" (gid, position) SELECT gid, position FROM "LP_SchutzgebieteObjekte"."LP_DenkmalschutzrechtLinie";
INSERT INTO "SO_NachrichtlicheUebernahmen"."SO_DenkmalschutzrechtPunkt" (gid, position) SELECT gid, position FROM "LP_SchutzgebieteObjekte"."LP_DenkmalschutzrechtPunkt";
UPDATE "SO_Basisobjekte"."SO_Objekt" so SET "rechtscharakter" = (SELECT "rechtscharakter" FROM "LP_Basisobjekte"."LP_Objekt" lp WHERE lp.gid = so.gid) WHERE gid in (SELECT gid from "LP_SchutzgebieteObjekte"."LP_Denkmalschutzrecht");
UPDATE "SO_NachrichtlicheUebernahmen"."SO_Denkmalschutzrecht" so SET "detailArtDerFestlegung" = (SELECT "detailTyp" FROM "LP_SchutzgebieteObjekte"."LP_Denkmalschutzrecht" lp WHERE lp.gid = so.gid) WHERE gid in (SELECT gid from "LP_SchutzgebieteObjekte"."LP_Denkmalschutzrecht" WHERE "detailTyp" IS NOT NULL);
DELETE FROM "LP_SchutzgebieteObjekte"."LP_Denkmalschutzrecht";
DROP TABLE "LP_SchutzgebieteObjekte"."LP_DenkmalschutzrechtFlaeche" CASCADE;
DROP TABLE "LP_SchutzgebieteObjekte"."LP_DenkmalschutzrechtLinie" CASCADE;
DROP TABLE "LP_SchutzgebieteObjekte"."LP_DenkmalschutzrechtPunkt" CASCADE;
DROP TABLE "LP_SchutzgebieteObjekte"."LP_Denkmalschutzrecht" CASCADE;
DROP TABLE "LP_SchutzgebieteObjekte"."LP_DenkmalschutzrechtDetailTypen";
ALTER TABLE "LP_Basisobjekte"."LP_Objekt" ENABLE TRIGGER "delete_LP_Objekt";
ALTER TABLE "SO_Basisobjekte"."SO_Objekt" ENABLE TRIGGER "change_to_SO_Objekt";

-- Änderung CR-082
-- Vorbereitung; Plan: wie CR-081
ALTER TABLE "SO_Basisobjekte"."SO_Objekt" DISABLE TRIGGER "change_to_SO_Objekt"; -- damit wird bei INSERT kein XP_Objekt angelegt
-- linienhafte Zieltabelle, gab es bisher nicht (warum?)
CREATE TABLE  "SO_Schutzgebiete"."SO_SchutzgebietNaturschutzrechtLinie" (
  "gid" BIGINT NOT NULL,
  PRIMARY KEY ("gid"),
  CONSTRAINT "fk_SO_SO_SchutzgebietNaturschutzrechtLinie_parent"
    FOREIGN KEY ("gid")
    REFERENCES "SO_Schutzgebiete"."SO_SchutzgebietNaturschutzrecht" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("SO_Basisobjekte"."SO_Linienobjekt");
GRANT SELECT ON TABLE "SO_Schutzgebiete"."SO_SchutzgebietNaturschutzrechtLinie" TO xp_gast;
GRANT ALL ON TABLE "SO_Schutzgebiete"."SO_SchutzgebietNaturschutzrechtLinie" TO so_user;
COMMENT ON COLUMN "SO_Schutzgebiete"."SO_SchutzgebietNaturschutzrechtLinie"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_SO_SchutzgebietNaturschutzrechtLinie" BEFORE INSERT OR UPDATE ON "SO_Schutzgebiete"."SO_SchutzgebietNaturschutzrechtLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_SO_SchutzgebietNaturschutzrechtLinie" AFTER DELETE ON "SO_Schutzgebiete"."SO_SchutzgebietNaturschutzrechtLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
-- BP, refTextInhalt wird nicht übernommen!
ALTER TABLE "BP_Basisobjekte"."BP_Objekt" DISABLE TRIGGER "delete_BP_Objekt"; -- damit wird bei DELETE das XP_Objekt nicht gelöscht
INSERT INTO "SO_Schutzgebiete"."SO_SchutzgebietNaturschutzrechtFlaeche" (gid, position, flaechenschluss) SELECT gid, position, flaechenschluss FROM "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_SchutzgebietFlaeche";
INSERT INTO "SO_Schutzgebiete"."SO_SchutzgebietNaturschutzrechtLinie" (gid, position) SELECT gid, position FROM "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_SchutzgebietLinie";
INSERT INTO "SO_Schutzgebiete"."SO_SchutzgebietNaturschutzrechtPunkt" (gid, position) SELECT gid, position FROM "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_SchutzgebietPunkt";
UPDATE "SO_Schutzgebiete"."SO_SchutzgebietNaturschutzrecht" so SET "artDerFestlegung" = (SELECT "zweckbestimmung" FROM "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_Schutzgebiet" bp WHERE bp.gid = so.gid) WHERE gid in (SELECT gid from "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_Schutzgebiet" WHERE "zweckbestimmung" IS NOT NULL);
UPDATE "SO_Basisobjekte"."SO_Objekt" so SET "rechtscharakter" = (SELECT "rechtscharakter" FROM "BP_Basisobjekte"."BP_Objekt" bp WHERE bp.gid = so.gid) WHERE gid in (SELECT gid from "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_Schutzgebiet");
INSERT INTO "SO_Schutzgebiete"."SO_DetailKlassifizSchutzgebietNaturschutzrecht" ("Code", "Bezeichner") SELECT "Code", "Bezeichner" FROM "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_DetailZweckbestNaturschutzgebiet";
UPDATE "SO_Schutzgebiete"."SO_SchutzgebietNaturschutzrecht" so SET "detailArtDerFestlegung" = (SELECT "detaillierteZweckbestimmung" FROM "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_Schutzgebiet" bp WHERE bp.gid = so.gid) WHERE gid in (SELECT gid from "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_Schutzgebiet" WHERE "detaillierteZweckbestimmung" IS NOT NULL);
DELETE FROM "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_Schutzgebiet";
DROP TABLE "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_SchutzgebietFlaeche" CASCADE;
DROP TABLE "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_SchutzgebietLinie" CASCADE;
DROP TABLE "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_SchutzgebietPunkt" CASCADE;
DROP TABLE "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_Schutzgebiet" CASCADE;
DROP TABLE "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_DetailZweckbestNaturschutzgebiet";
ALTER TABLE "BP_Basisobjekte"."BP_Objekt" ENABLE TRIGGER "delete_BP_Objekt";
-- LP
ALTER TABLE "LP_Basisobjekte"."LP_Objekt" DISABLE TRIGGER "delete_LP_Objekt"; -- damit wird bei DELETE das XP_Objekt nicht gelöscht
INSERT INTO "SO_Schutzgebiete"."SO_SchutzgebietNaturschutzrechtFlaeche" (gid, position) SELECT gid, position FROM "LP_SchutzgebieteObjekte"."LP_SchutzobjektBundesrechtFlaeche";
INSERT INTO "SO_Schutzgebiete"."SO_SchutzgebietNaturschutzrechtLinie" (gid, position) SELECT gid, position FROM "LP_SchutzgebieteObjekte"."LP_SchutzobjektBundesrechtLinie";
INSERT INTO "SO_Schutzgebiete"."SO_SchutzgebietNaturschutzrechtPunkt" (gid, position) SELECT gid, position FROM "LP_SchutzgebieteObjekte"."LP_SchutzobjektBundesrechtPunkt";
UPDATE "SO_Schutzgebiete"."SO_SchutzgebietNaturschutzrecht" so SET "artDerFestlegung" = 18000 WHERE gid in (SELECT gid from "LP_SchutzgebieteObjekte"."LP_SchutzobjektBundesrecht" WHERE "typ" = 1800);
UPDATE "SO_Schutzgebiete"."SO_SchutzgebietNaturschutzrecht" so SET "artDerFestlegung" = 18001 WHERE gid in (SELECT gid from "LP_SchutzgebieteObjekte"."LP_SchutzobjektBundesrecht" WHERE "typ" = 1900);
UPDATE "SO_Schutzgebiete"."SO_SchutzgebietNaturschutzrecht" so SET "artDerFestlegung" = (SELECT "typ" FROM "LP_SchutzgebieteObjekte"."LP_SchutzobjektBundesrecht" bp WHERE bp.gid = so.gid) WHERE gid in (SELECT gid from "LP_SchutzgebieteObjekte"."LP_SchutzobjektBundesrecht" WHERE "typ" IS NOT NULL) and "artDerFestlegung" IS NULL;
UPDATE "SO_Schutzgebiete"."SO_SchutzgebietNaturschutzrecht" so SET "name" = (SELECT "eigenname" FROM "LP_SchutzgebieteObjekte"."LP_SchutzobjektBundesrecht" bp WHERE bp.gid = so.gid) WHERE gid in (SELECT gid from "LP_SchutzgebieteObjekte"."LP_SchutzobjektBundesrecht" WHERE "eigenname" IS NOT NULL);
UPDATE "SO_Basisobjekte"."SO_Objekt" so SET "rechtscharakter" = (SELECT "rechtscharakter" FROM "LP_Basisobjekte"."LP_Objekt" bp WHERE bp.gid = so.gid) WHERE gid in (SELECT gid from "LP_SchutzgebieteObjekte"."LP_SchutzobjektBundesrecht");
DELETE FROM "LP_SchutzgebieteObjekte"."LP_SchutzobjektBundesrecht";
DROP TABLE "LP_SchutzgebieteObjekte"."LP_SchutzobjektBundesrechtFlaeche" CASCADE;
DROP TABLE "LP_SchutzgebieteObjekte"."LP_SchutzobjektBundesrechtLinie" CASCADE;
DROP TABLE "LP_SchutzgebieteObjekte"."LP_SchutzobjektBundesrechtPunkt" CASCADE;
DROP TABLE "LP_SchutzgebieteObjekte"."LP_SchutzobjektBundesrecht" CASCADE;
ALTER TABLE "LP_Basisobjekte"."LP_Objekt" ENABLE TRIGGER "delete_LP_Objekt";
ALTER TABLE "SO_Basisobjekte"."SO_Objekt" ENABLE TRIGGER "change_to_SO_Objekt";

-- Änderung CR-083
ALTER TABLE "BP_Basisobjekte"."BP_WirksamkeitBedingung" SET SCHEMA "XP_Basisobjekte";
ALTER TABLE "XP_Basisobjekte"."BP_WirksamkeitBedingung" RENAME TO "XP_WirksamkeitBedingung";
REVOKE ALL ON TABLE "XP_Basisobjekte"."XP_WirksamkeitBedingung" FROM bp_user;
GRANT ALL ON "XP_Basisobjekte"."XP_WirksamkeitBedingung" TO xp_user;
ALTER SEQUENCE "BP_Basisobjekte"."BP_WirksamkeitBedingung_id_seq" SET SCHEMA "XP_Basisobjekte";
ALTER SEQUENCE "XP_Basisobjekte"."BP_WirksamkeitBedingung_id_seq" RENAME TO "XP_WirksamkeitBedingung_id_seq";
REVOKE ALL ON TABLE "XP_Basisobjekte"."XP_WirksamkeitBedingung_id_seq" FROM bp_user;
GRANT ALL ON "XP_Basisobjekte"."XP_WirksamkeitBedingung_id_seq" TO xp_user;
ALTER TABLE "XP_Basisobjekte"."XP_Objekt" ADD COLUMN "startBedingung" INTEGER;
ALTER TABLE "XP_Basisobjekte"."XP_Objekt" ADD COLUMN "endeBedingung" INTEGER;
COMMENT ON COLUMN "XP_Basisobjekte"."XP_Objekt"."startBedingung" IS 'Notwendige Bedingung für die Wirksamkeit eines Planinhalts.';
COMMENT ON COLUMN "XP_Basisobjekte"."XP_Objekt"."endeBedingung" IS 'Notwendige Bedingung für das Ende der Wirksamkeit eines Planinhalts.';
ALTER TABLE "XP_Basisobjekte"."XP_Objekt" ADD CONSTRAINT "fk_XP_Objekt_XP_WirksamkeitBedingung1"
    FOREIGN KEY ("startBedingung" )
    REFERENCES "XP_Basisobjekte"."XP_WirksamkeitBedingung" ("id" )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;
ALTER TABLE "XP_Basisobjekte"."XP_Objekt" ADD CONSTRAINT "fk_XP_Objekt_XP_WirksamkeitBedingung2"
    FOREIGN KEY ("endeBedingung" )
    REFERENCES "XP_Basisobjekte"."XP_WirksamkeitBedingung" ("id" )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;
UPDATE "XP_Basisobjekte"."XP_Objekt" x SET "startBedingung" = (SELECT "startBedingung" FROM "BP_Basisobjekte"."BP_Objekt" b WHERE b.gid = x.gid) WHERE gid IN (SELECT gid FROM "BP_Basisobjekte"."BP_Objekt" WHERE "startBedingung" IS NOT NULL);
UPDATE "XP_Basisobjekte"."XP_Objekt" x SET "endeBedingung" = (SELECT "endeBedingung" FROM "BP_Basisobjekte"."BP_Objekt" b WHERE b.gid = x.gid) WHERE gid IN (SELECT gid FROM "BP_Basisobjekte"."BP_Objekt" WHERE "endeBedingung" IS NOT NULL);
ALTER TABLE "BP_Basisobjekte"."BP_Objekt" DROP COLUMN "startBedingung";
ALTER TABLE "BP_Basisobjekte"."BP_Objekt" DROP COLUMN "endeBedingung";

-- Änderung CR-084
CREATE  TABLE  "BP_Basisobjekte"."BP_Laermpegelbereich" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Code") );
GRANT SELECT ON "BP_Basisobjekte"."BP_Laermpegelbereich" TO xp_gast;
ALTER TABLE "BP_Umwelt"."BP_Immissionsschutz" ADD COLUMN "laermpegelbereich" INTEGER;
COMMENT ON COLUMN "BP_Umwelt"."BP_Immissionsschutz"."laermpegelbereich" IS 'Festlegung der erforderlichen Luftschalldämmung von Außenbauteilen nach DIN 4109.';
ALTER TABLE "BP_Umwelt"."BP_Immissionsschutz" ADD CONSTRAINT "fk_BP_Immissionsschutz_BP_Laermpegelbereich1"
    FOREIGN KEY ("laermpegelbereich")
    REFERENCES "BP_Basisobjekte"."BP_Laermpegelbereich" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE;
INSERT INTO "BP_Basisobjekte"."BP_Laermpegelbereich" ("Code", "Bezeichner") VALUES (1000, 'I');
INSERT INTO "BP_Basisobjekte"."BP_Laermpegelbereich" ("Code", "Bezeichner") VALUES (1100, 'II');
INSERT INTO "BP_Basisobjekte"."BP_Laermpegelbereich" ("Code", "Bezeichner") VALUES (1200, 'III');
INSERT INTO "BP_Basisobjekte"."BP_Laermpegelbereich" ("Code", "Bezeichner") VALUES (1300, 'IV');
INSERT INTO "BP_Basisobjekte"."BP_Laermpegelbereich" ("Code", "Bezeichner") VALUES (1400, 'V');
INSERT INTO "BP_Basisobjekte"."BP_Laermpegelbereich" ("Code", "Bezeichner") VALUES (1500, 'VI');
INSERT INTO "BP_Basisobjekte"."BP_Laermpegelbereich" ("Code", "Bezeichner") VALUES (1600, 'VII');

-- Änderung CR-085
UPDATE "SO_NachrichtlicheUebernahmen"."SO_KlassifizNachWasserrecht" SET "Code" = 10000 WHERE "Code" = 1000;
UPDATE "SO_NachrichtlicheUebernahmen"."SO_KlassifizNachWasserrecht" SET "Code" = 10001 WHERE "Code" = 1100;
UPDATE "SO_NachrichtlicheUebernahmen"."SO_KlassifizNachWasserrecht" SET "Code" = 10002 WHERE "Code" = 1300;
INSERT INTO "SO_NachrichtlicheUebernahmen"."SO_KlassifizNachWasserrecht" ("Code", "Bezeichner") VALUES (1000, 'Gewaesser');

-- Änderung CR-086
INSERT INTO "FP_Verkehr"."FP_ZweckbestimmungStrassenverkehr" ("Code", "Bezeichner") VALUES ('16000', 'Parkplatz');
INSERT INTO "FP_Verkehr"."FP_ZweckbestimmungStrassenverkehr" ("Code", "Bezeichner") VALUES ('16001', 'Fahrradabstellplatz');


-- Funktion, um übergeordnete Zweckbestimmungen etc. zu entfernen, wenn entsprechende besondereZweckbestimmungen etc. für das selbe Objekt vorhanden waren (nun alles zweckbestimmung etc.)
-- Die Funktion gibt SQL-DELETE-Statements zurück, die im Anschluß ausgeführt werden können
create or replace function "QGIS".delete_superordinate()
    RETURNS text
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE
AS $BODY$

 DECLARE
    rec record;
    lastgid bigint;
    wert character varying;
    returnvalue text;
 BEGIN
    returnvalue := '';
    lastgid := -9999;
    wert := '0';
    FOR rec in SELECT "BP_VerEntsorgung_gid",zweckbestimmung::varchar as zweck
        FROM "BP_Ver_und_Entsorgung"."BP_VerEntsorgung_zweckbestimmung"
        WHERE "BP_VerEntsorgung_gid" IN(
            select gid
            from "BP_Ver_und_Entsorgung"."BP_VerEntsorgung_qv"
            where anz_zweckbestimmung > 1)
        ORDER BY 1,2 DESC LOOP

        IF rec."BP_VerEntsorgung_gid" = lastgid THEN
            IF length(rec.zweck) = 4 AND left(rec.zweck,4) = left(wert,4) THEN
                returnvalue := returnvalue ||
                    E'\nDELETE FROM "BP_Ver_und_Entsorgung"."BP_VerEntsorgung_zweckbestimmung" WHERE "BP_VerEntsorgung_gid" = ' ||
                    lastgid::varchar ||
                    ' AND zweckbestimmung = ' ||
                    rec.zweck || ';';
            END IF;
        ELSE
            lastgid := rec."BP_VerEntsorgung_gid";
        END IF;
        wert := rec.zweck;
    END LOOP;

    wert := '0';
    FOR rec in SELECT "FP_VerEntsorgung_gid",zweckbestimmung::varchar as zweck
        FROM "FP_Ver_und_Entsorgung"."FP_VerEntsorgung_zweckbestimmung"
        WHERE "FP_VerEntsorgung_gid" IN(
            select gid
            from "FP_Ver_und_Entsorgung"."FP_VerEntsorgung_qv"
            where anz_zweckbestimmung > 1)
        ORDER BY 1,2 DESC LOOP

        IF rec."FP_VerEntsorgung_gid" = lastgid THEN
            IF length(rec.zweck) = 4 AND left(rec.zweck,4) = left(wert,4) THEN
                returnvalue := returnvalue ||
                    E'\nDELETE FROM "FP_Ver_und_Entsorgung"."FP_VerEntsorgung_zweckbestimmung" WHERE "FP_VerEntsorgung_gid" = ' ||
                    lastgid::varchar ||
                    ' AND zweckbestimmung = ' ||
                    rec.zweck || ';';
            END IF;
        ELSE
            lastgid := rec."FP_VerEntsorgung_gid";
        END IF;
        wert := rec.zweck;
    END LOOP;

    wert := '0';
    FOR rec in SELECT "BP_GemeinbedarfsFlaeche_gid",zweckbestimmung::varchar as zweck
        FROM "BP_Gemeinbedarf_Spiel_und_Sportanlagen"."BP_GemeinbedarfsFlaeche_zweckbestimmung"
        WHERE "BP_GemeinbedarfsFlaeche_gid" IN(
            select gid
            from "BP_Gemeinbedarf_Spiel_und_Sportanlagen"."BP_GemeinbedarfsFlaeche_qv"
            where anz_zweckbestimmung > 1)
        ORDER BY 1,2 DESC LOOP

        IF rec."BP_GemeinbedarfsFlaeche_gid" = lastgid THEN
            IF length(rec.zweck) = 4 AND left(rec.zweck,4) = left(wert,4) THEN
                returnvalue := returnvalue ||
                    E'\nDELETE FROM "BP_Gemeinbedarf_Spiel_und_Sportanlagen"."BP_GemeinbedarfsFlaeche_zweckbestimmung" WHERE "BP_GemeinbedarfsFlaeche_gid" = ' ||
                    lastgid::varchar ||
                    ' AND zweckbestimmung = ' ||
                    rec.zweck || ';';
            END IF;
        ELSE
            lastgid := rec."BP_GemeinbedarfsFlaeche_gid";
        END IF;
        wert := rec.zweck;
    END LOOP;

    wert := '0';
    FOR rec in SELECT "FP_Gemeinbedarf_gid",zweckbestimmung::varchar as zweck
        FROM "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_Gemeinbedarf_zweckbestimmung"
        WHERE "FP_Gemeinbedarf_gid" IN(
            select gid
            from "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_Gemeinbedarf_qv"
            where anz_zweckbestimmung > 1)
        ORDER BY 1,2 DESC LOOP

        IF rec."FP_Gemeinbedarf_gid" = lastgid THEN
            IF length(rec.zweck) = 4 AND left(rec.zweck,4) = left(wert,4) THEN
                returnvalue := returnvalue ||
                    E'\nDELETE FROM "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_Gemeinbedarf_zweckbestimmung" WHERE "FP_Gemeinbedarf_gid" = ' ||
                    lastgid::varchar ||
                    ' AND zweckbestimmung = ' ||
                    rec.zweck || ';';
            END IF;
        ELSE
            lastgid := rec."FP_Gemeinbedarf_gid";
        END IF;
        wert := rec.zweck;
    END LOOP;

    wert := '0';
    FOR rec in SELECT "BP_GruenFlaeche_gid",zweckbestimmung::varchar as zweck
        FROM "BP_Landwirtschaft_Wald_und_Gruen"."BP_GruenFlaeche_zweckbestimmung"
        WHERE "BP_GruenFlaeche_gid" IN(
            select gid
            from "BP_Landwirtschaft_Wald_und_Gruen"."BP_GruenFlaeche_qv"
            where anz_zweckbestimmung > 1)
        ORDER BY 1,2 DESC LOOP

        IF rec."BP_GruenFlaeche_gid" = lastgid THEN
            IF length(rec.zweck) = 4 AND left(rec.zweck,4) = left(wert,4) THEN
                returnvalue := returnvalue ||
                    E'\nDELETE FROM "BP_Landwirtschaft_Wald_und_Gruen"."BP_GruenFlaeche_zweckbestimmung" WHERE "BP_GruenFlaeche_gid" = ' ||
                    lastgid::varchar ||
                    ' AND zweckbestimmung = ' ||
                    rec.zweck || ';';
            END IF;
        ELSE
            lastgid := rec."BP_GruenFlaeche_gid";
        END IF;
        wert := rec.zweck;
    END LOOP;

    wert := '0';
    FOR rec in SELECT "FP_Gruen_gid",zweckbestimmung::varchar as zweck
        FROM "FP_Landwirtschaft_Wald_und_Gruen"."FP_Gruen_zweckbestimmung"
        WHERE "FP_Gruen_gid" IN(
            select gid
            from "FP_Landwirtschaft_Wald_und_Gruen"."FP_Gruen_qv"
            where anz_zweckbestimmung > 1)
        ORDER BY 1,2 DESC LOOP

        IF rec."FP_Gruen_gid" = lastgid THEN
            IF length(rec.zweck) = 4 AND left(rec.zweck,4) = left(wert,4) THEN
                returnvalue := returnvalue ||
                    E'\nDELETE FROM "FP_Landwirtschaft_Wald_und_Gruen"."FP_Gruen_zweckbestimmung" WHERE "FP_Gruen_gid" = ' ||
                    lastgid::varchar ||
                    ' AND zweckbestimmung = ' ||
                    rec.zweck || ';';
            END IF;
        ELSE
            lastgid := rec."FP_Gruen_gid";
        END IF;
        wert := rec.zweck;
    END LOOP;

    wert := '0';
    FOR rec in SELECT "FP_PrivilegiertesVorhaben_gid",zweckbestimmung::varchar as zweck
        FROM "FP_Sonstiges"."FP_PrivilegiertesVorhaben_zweckbestimmung"
        WHERE "FP_PrivilegiertesVorhaben_gid" IN(
            select gid
            from "FP_Sonstiges"."FP_PrivilegiertesVorhaben_qv"
            where anz_zweckbestimmung > 1)
        ORDER BY 1,2 DESC LOOP

        IF rec."FP_PrivilegiertesVorhaben_gid" = lastgid THEN
            IF length(rec.zweck) = 4 AND left(rec.zweck,4) = left(wert,4) THEN
                returnvalue := returnvalue ||
                    E'\nDELETE FROM "FP_Sonstiges"."FP_PrivilegiertesVorhaben_zweckbestimmung" WHERE "FP_PrivilegiertesVorhaben_gid" = ' ||
                    lastgid::varchar ||
                    ' AND zweckbestimmung = ' ||
                    rec.zweck || ';';
            END IF;
        ELSE
            lastgid := rec."FP_PrivilegiertesVorhaben_gid";
        END IF;
        wert := rec.zweck;
    END LOOP;

    RETURN returnvalue;
END;
$BODY$;

SELECT "QGIS".delete_superordinate();
