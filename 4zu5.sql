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
COMMENT ON TABLE "XP_Basisobjekte"."XP_Objekt_gehoertZuBereich"
    IS 'Verweis auf den Bereich, zu dem der Planinhalt gehört.';
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
GRANT ALL ON "XP_Basisobjekte"."XP_Plan_externeReferenz" TO xp_user;
GRANT SELECT ON "XP_Basisobjekte"."XP_Plan_externeReferenz" TO xp_gast;
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
DROP TABLE "XP_Raster"."XP_RasterplanAenderung_refLegende";
DROP TABLE "XP_Raster"."XP_RasterplanAenderung_refScan";
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

CREATE OR REPLACE FUNCTION "BP_Bebauung"."BP_FestsetzungenBaugebiet_konsistent"()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$

 BEGIN
    IF NEW."GFZmin" IS NOT NULL AND NEW."GFZmax" IS NULL THEN
        IF NEW."GFZ" IS NOT NULL THEN
            NEW."GFZmax" := NEW."GFZ";
        ELSE
            NEW."GFZmax" := NEW."GFZmin";
        END IF;
    ELSIF NEW."GFZmin" IS NULL AND NEW."GFZmax" IS NOT NULL THEN
        NEW."GFZmin" := NEW."GFZmax";
    ELSE
        IF NEW."GFZmin" > NEW."GFZmax" THEN
            NEW."GFZmin" := NEW."GFZmax";
        END IF;
    END IF;

    IF NEW."GFmin" IS NOT NULL AND NEW."GF" IS NOT NULL THEN
        NEW."GF" := NULL;
    END IF;

    IF NEW."GFmin" IS NOT NULL AND NEW."GFmax" IS NULL THEN
        IF NEW."GF" IS NOT NULL THEN
            NEW."GFmax" := NEW."GF";
        ELSE
            NEW."GFmax" := NEW."GFmin";
        END IF;
    ELSIF NEW."GFmin" IS NULL AND NEW."GFmax" IS NOT NULL THEN
        NEW."GFmin" := NEW."GFmax";
    ELSE
        IF NEW."GFmin" > NEW."GFmax" THEN
            NEW."GFmin" := NEW."GFmax";
        END IF;
    END IF;

    IF NEW."GFmin" IS NOT NULL AND NEW."GF" IS NOT NULL THEN
        NEW."GF" := NULL;
    END IF;

    IF NEW."GFmin" IS NOT NULL AND NEW."GF" IS NOT NULL THEN
        NEW."GF" := NULL;
    END IF;

    IF NEW."GRZmin" IS NOT NULL AND NEW."GRZ" IS NOT NULL THEN
        NEW."GRZ" := NULL;
    END IF;

    IF NEW."GRZmin" IS NOT NULL AND NEW."GRZmax" IS NULL THEN
        IF NEW."GRZ" IS NOT NULL THEN
            NEW."GRZmax" := NEW."GRZ";
        ELSE
            NEW."GRZmax" := NEW."GRZmin";
        END IF;
    ELSIF NEW."GRZmin" IS NULL AND NEW."GRZmax" IS NOT NULL THEN
        NEW."GRZmin" := NEW."GRZmax";
    ELSE
        IF NEW."GRZmin" > NEW."GRZmax" THEN
            NEW."GRZmin" := NEW."GRZmax";
        END IF;
    END IF;

    IF NEW."GRZmin" IS NOT NULL AND NEW."GRZ" IS NOT NULL THEN
        NEW."GRZ" := NULL;
    END IF;

    IF NEW."GRmin" IS NOT NULL AND NEW."GR" IS NOT NULL THEN
        NEW."GR" := NULL;
    END IF;

    IF NEW."GRmin" IS NOT NULL AND NEW."GRmax" IS NULL THEN
        IF NEW."GR" IS NOT NULL THEN
            NEW."GRmax" := NEW."GR";
        ELSE
            NEW."GRmax" := NEW."GRmin";
        END IF;
    ELSIF NEW."GRmin" IS NULL AND NEW."GRmax" IS NOT NULL THEN
        NEW."GRmin" := NEW."GRmax";
    ELSE
        IF NEW."GRmin" > NEW."GRmax" THEN
            NEW."GRmin" := NEW."GRmax";
        END IF;
    END IF;

    IF NEW."GRmin" IS NOT NULL AND NEW."GR" IS NOT NULL THEN
        NEW."GR" := NULL;
    END IF;

    IF NEW."Zmin" IS NOT NULL AND NEW."Z" IS NOT NULL THEN
        NEW."Z" := NULL;
    END IF;

    IF NEW."Zmin" IS NOT NULL AND NEW."Zmax" IS NULL THEN
        IF NEW."Z" IS NOT NULL THEN
            NEW."Zmax" := NEW."Z";
        ELSE
            NEW."Zmax" := NEW."Zmin";
        END IF;
    ELSIF NEW."Zmin" IS NULL AND NEW."Zmax" IS NOT NULL THEN
        NEW."Zmin" := NEW."Zmax";
    ELSE
        IF NEW."Zmin" > NEW."Zmax" THEN
            NEW."Zmin" := NEW."Zmax";
        END IF;
    END IF;

    IF NEW."Zmin" IS NOT NULL AND NEW."Z" IS NOT NULL THEN
        NEW."Z" := NULL;
    END IF;

    IF NEW."ZUmin" IS NOT NULL AND NEW."ZU" IS NOT NULL THEN
        NEW."ZU" := NULL;
    END IF;

    IF NEW."ZUmin" IS NOT NULL AND NEW."ZUmax" IS NULL THEN
        IF NEW."ZU" IS NOT NULL THEN
            NEW."ZUmax" := NEW."ZU";
        ELSE
            NEW."ZUmax" := NEW."ZUmin";
        END IF;
    ELSIF NEW."ZUmin" IS NULL AND NEW."ZUmax" IS NOT NULL THEN
        NEW."ZUmin" := NEW."ZUmax";
    ELSE
        IF NEW."ZUmin" > NEW."ZUmax" THEN
            NEW."ZUmin" := NEW."ZUmax";
        END IF;
    END IF;

    IF NEW."ZUmin" IS NOT NULL AND NEW."ZU" IS NOT NULL THEN
        NEW."ZU" := NULL;
    END IF;

    RETURN NEW;
 END;
$BODY$;

GRANT EXECUTE ON FUNCTION "BP_Bebauung"."BP_FestsetzungenBaugebiet_konsistent"() TO bp_user;

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
ALTER TABLE "SO_NachrichtlicheUebernahmen"."SO_Denkmalschutzrecht" DISABLE TRIGGER "change_to_SO_Denkmalschutzrecht";
ALTER TABLE "SO_NachrichtlicheUebernahmen"."SO_DenkmalschutzrechtFlaeche" DISABLE TRIGGER "change_to_SO_DenkmalschutzrechtFlaeche";
ALTER TABLE "SO_NachrichtlicheUebernahmen"."SO_DenkmalschutzrechtLinie" DISABLE TRIGGER "change_to_SO_DenkmalschutzrechtLinie";
ALTER TABLE "SO_NachrichtlicheUebernahmen"."SO_DenkmalschutzrechtPunkt" DISABLE TRIGGER "change_to_SO_DenkmalschutzrechtPunkt";
-- BP, refTextInhalt wird nicht übernommen!
ALTER TABLE "BP_Basisobjekte"."BP_Objekt" DISABLE TRIGGER "delete_BP_Objekt"; -- damit wird bei DELETE das XP_Objekt nicht gelöscht
INSERT INTO "SO_Basisobjekte"."SO_Objekt" (gid) SELECT gid FROM "BP_Erhaltungssatzung_und_Denkmalschutz"."BP_DenkmalschutzEinzelanlageFlaeche";
INSERT INTO "SO_NachrichtlicheUebernahmen"."SO_Denkmalschutzrecht" (gid) SELECT gid FROM "BP_Erhaltungssatzung_und_Denkmalschutz"."BP_DenkmalschutzEinzelanlageFlaeche";
INSERT INTO "SO_NachrichtlicheUebernahmen"."SO_DenkmalschutzrechtFlaeche" (gid, position, flaechenschluss) SELECT gid, position, flaechenschluss FROM "BP_Erhaltungssatzung_und_Denkmalschutz"."BP_DenkmalschutzEinzelanlageFlaeche";
INSERT INTO "SO_Basisobjekte"."SO_Objekt" (gid) SELECT gid FROM "BP_Erhaltungssatzung_und_Denkmalschutz"."BP_DenkmalschutzEinzelanlageLinie";
INSERT INTO "SO_NachrichtlicheUebernahmen"."SO_Denkmalschutzrecht" (gid) SELECT gid FROM "BP_Erhaltungssatzung_und_Denkmalschutz"."BP_DenkmalschutzEinzelanlageLinie";
INSERT INTO "SO_NachrichtlicheUebernahmen"."SO_DenkmalschutzrechtLinie" (gid, position) SELECT gid, position FROM "BP_Erhaltungssatzung_und_Denkmalschutz"."BP_DenkmalschutzEinzelanlageLinie";
INSERT INTO "SO_Basisobjekte"."SO_Objekt" (gid) SELECT gid FROM "BP_Erhaltungssatzung_und_Denkmalschutz"."BP_DenkmalschutzEinzelanlagePunkt";
INSERT INTO "SO_NachrichtlicheUebernahmen"."SO_Denkmalschutzrecht" (gid) SELECT gid FROM "BP_Erhaltungssatzung_und_Denkmalschutz"."BP_DenkmalschutzEinzelanlagePunkt";
INSERT INTO "SO_NachrichtlicheUebernahmen"."SO_DenkmalschutzrechtPunkt" (gid, position) SELECT gid, position FROM "BP_Erhaltungssatzung_und_Denkmalschutz"."BP_DenkmalschutzEinzelanlagePunkt";
UPDATE "SO_NachrichtlicheUebernahmen"."SO_Denkmalschutzrecht" so SET "name" = (SELECT "denkmal" FROM "BP_Erhaltungssatzung_und_Denkmalschutz"."BP_DenkmalschutzEinzelanlage" bp WHERE bp.gid = so.gid) WHERE gid in (SELECT gid from "BP_Erhaltungssatzung_und_Denkmalschutz"."BP_DenkmalschutzEinzelanlage" WHERE "name" IS NOT NULL);
UPDATE "SO_Basisobjekte"."SO_Objekt" so SET "rechtscharakter" = (SELECT "rechtscharakter" FROM "BP_Basisobjekte"."BP_Objekt" bp WHERE bp.gid = so.gid) WHERE gid in (SELECT gid from "BP_Erhaltungssatzung_und_Denkmalschutz"."BP_DenkmalschutzEinzelanlage");
INSERT INTO "SO_Basisobjekte"."SO_Objekt" (gid) SELECT gid FROM "BP_Erhaltungssatzung_und_Denkmalschutz"."BP_DenkmalschutzEnsembleFlaeche";
INSERT INTO "SO_NachrichtlicheUebernahmen"."SO_Denkmalschutzrecht" (gid) SELECT gid FROM "BP_Erhaltungssatzung_und_Denkmalschutz"."BP_DenkmalschutzEnsembleFlaeche";
INSERT INTO "SO_NachrichtlicheUebernahmen"."SO_DenkmalschutzrechtFlaeche" (gid, position, flaechenschluss) SELECT gid, position, flaechenschluss FROM "BP_Erhaltungssatzung_und_Denkmalschutz"."BP_DenkmalschutzEnsembleFlaeche";
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
INSERT INTO "SO_Basisobjekte"."SO_Objekt" (gid) SELECT gid FROM "LP_SchutzgebieteObjekte"."LP_DenkmalschutzrechtFlaeche";
INSERT INTO "SO_NachrichtlicheUebernahmen"."SO_Denkmalschutzrecht" (gid) SELECT gid FROM "LP_SchutzgebieteObjekte"."LP_DenkmalschutzrechtFlaeche";
INSERT INTO "SO_NachrichtlicheUebernahmen"."SO_DenkmalschutzrechtFlaeche" (gid, position) SELECT gid, position FROM "LP_SchutzgebieteObjekte"."LP_DenkmalschutzrechtFlaeche";
INSERT INTO "SO_Basisobjekte"."SO_Objekt" (gid) SELECT gid FROM "LP_SchutzgebieteObjekte"."LP_DenkmalschutzrechtLinie";
INSERT INTO "SO_NachrichtlicheUebernahmen"."SO_Denkmalschutzrecht" (gid) SELECT gid FROM "LP_SchutzgebieteObjekte"."LP_DenkmalschutzrechtLinie";
INSERT INTO "SO_NachrichtlicheUebernahmen"."SO_DenkmalschutzrechtLinie" (gid, position) SELECT gid, position FROM "LP_SchutzgebieteObjekte"."LP_DenkmalschutzrechtLinie";
INSERT INTO "SO_Basisobjekte"."SO_Objekt" (gid) SELECT gid FROM "LP_SchutzgebieteObjekte"."LP_DenkmalschutzrechtPunkt";
INSERT INTO "SO_NachrichtlicheUebernahmen"."SO_Denkmalschutzrecht" (gid) SELECT gid FROM "LP_SchutzgebieteObjekte"."LP_DenkmalschutzrechtPunkt";
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
ALTER TABLE "SO_NachrichtlicheUebernahmen"."SO_Denkmalschutzrecht" ENABLE TRIGGER "change_to_SO_Denkmalschutzrecht";
ALTER TABLE "SO_NachrichtlicheUebernahmen"."SO_DenkmalschutzrechtFlaeche" ENABLE TRIGGER "change_to_SO_DenkmalschutzrechtFlaeche";
ALTER TABLE "SO_NachrichtlicheUebernahmen"."SO_DenkmalschutzrechtLinie" ENABLE TRIGGER "change_to_SO_DenkmalschutzrechtLinie";
ALTER TABLE "SO_NachrichtlicheUebernahmen"."SO_DenkmalschutzrechtPunkt" ENABLE TRIGGER "change_to_SO_DenkmalschutzrechtPunkt";

-- Änderung CR-082
-- Vorbereitung; Plan: wie CR-081
ALTER TABLE "SO_Basisobjekte"."SO_Objekt" DISABLE TRIGGER "change_to_SO_Objekt"; -- damit wird bei INSERT kein XP_Objekt angelegt
ALTER TABLE "SO_Schutzgebiete"."SO_SchutzgebietNaturschutzrecht" DISABLE TRIGGER "change_to_SO_SchutzgebietNaturschutzrecht";
ALTER TABLE "SO_Schutzgebiete"."SO_SchutzgebietNaturschutzrechtFlaeche" DISABLE TRIGGER "change_to_SO_SchutzgebietNaturschutzrechtFlaeche";
ALTER TABLE "SO_Schutzgebiete"."SO_SchutzgebietNaturschutzrechtPunkt" DISABLE TRIGGER "change_to_SO_SchutzgebietNaturschutzrechtPunkt";
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
CREATE TRIGGER "delete_SO_SchutzgebietNaturschutzrechtLinie" AFTER DELETE ON "SO_Schutzgebiete"."SO_SchutzgebietNaturschutzrechtLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
-- BP, refTextInhalt wird nicht übernommen!
ALTER TABLE "BP_Basisobjekte"."BP_Objekt" DISABLE TRIGGER "delete_BP_Objekt"; -- damit wird bei DELETE das XP_Objekt nicht gelöscht
INSERT INTO "SO_Basisobjekte"."SO_Objekt" (gid) SELECT gid FROM "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_SchutzgebietFlaeche";
INSERT INTO "SO_Schutzgebiete"."SO_SchutzgebietNaturschutzrecht" (gid) SELECT gid FROM "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_SchutzgebietFlaeche";
INSERT INTO "SO_Schutzgebiete"."SO_SchutzgebietNaturschutzrechtFlaeche" (gid, position, flaechenschluss) SELECT gid, position, flaechenschluss FROM "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_SchutzgebietFlaeche";
INSERT INTO "SO_Basisobjekte"."SO_Objekt" (gid) SELECT gid FROM "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_SchutzgebietLinie";
INSERT INTO "SO_Schutzgebiete"."SO_SchutzgebietNaturschutzrecht" (gid) SELECT gid FROM "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_SchutzgebietLinie";
INSERT INTO "SO_Schutzgebiete"."SO_SchutzgebietNaturschutzrechtLinie" (gid, position) SELECT gid, position FROM "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_SchutzgebietLinie";
INSERT INTO "SO_Basisobjekte"."SO_Objekt" (gid) SELECT gid FROM "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_SchutzgebietPunkt";
INSERT INTO "SO_Schutzgebiete"."SO_SchutzgebietNaturschutzrecht" (gid) SELECT gid FROM "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_SchutzgebietPunkt";
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
INSERT INTO "SO_Basisobjekte"."SO_Objekt" (gid) SELECT gid FROM "LP_SchutzgebieteObjekte"."LP_SchutzobjektBundesrechtFlaeche";
INSERT INTO "SO_Schutzgebiete"."SO_SchutzgebietNaturschutzrecht" (gid) SELECT gid FROM "LP_SchutzgebieteObjekte"."LP_SchutzobjektBundesrechtFlaeche";
INSERT INTO "SO_Schutzgebiete"."SO_SchutzgebietNaturschutzrechtFlaeche" (gid, position) SELECT gid, position FROM "LP_SchutzgebieteObjekte"."LP_SchutzobjektBundesrechtFlaeche";
INSERT INTO "SO_Basisobjekte"."SO_Objekt" (gid) SELECT gid FROM "LP_SchutzgebieteObjekte"."LP_SchutzobjektBundesrechtLinie";
INSERT INTO "SO_Schutzgebiete"."SO_SchutzgebietNaturschutzrecht" (gid) SELECT gid FROM "LP_SchutzgebieteObjekte"."LP_SchutzobjektBundesrechtLinie";
INSERT INTO "SO_Schutzgebiete"."SO_SchutzgebietNaturschutzrechtLinie" (gid, position) SELECT gid, position FROM "LP_SchutzgebieteObjekte"."LP_SchutzobjektBundesrechtLinie";
INSERT INTO "SO_Basisobjekte"."SO_Objekt" (gid) SELECT gid FROM "LP_SchutzgebieteObjekte"."LP_SchutzobjektBundesrechtPunkt";
INSERT INTO "SO_Schutzgebiete"."SO_SchutzgebietNaturschutzrecht" (gid) SELECT gid FROM "LP_SchutzgebieteObjekte"."LP_SchutzobjektBundesrechtPunkt";
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
ALTER TABLE "SO_Schutzgebiete"."SO_SchutzgebietNaturschutzrecht" ENABLE TRIGGER "change_to_SO_SchutzgebietNaturschutzrecht";
ALTER TABLE "SO_Schutzgebiete"."SO_SchutzgebietNaturschutzrechtFlaeche" ENABLE TRIGGER "change_to_SO_SchutzgebietNaturschutzrechtFlaeche";
ALTER TABLE "SO_Schutzgebiete"."SO_SchutzgebietNaturschutzrechtPunkt" ENABLE TRIGGER "change_to_SO_SchutzgebietNaturschutzrechtPunkt";
CREATE TRIGGER "change_to_SO_SchutzgebietNaturschutzrechtLinie" BEFORE INSERT OR UPDATE ON "SO_Schutzgebiete"."SO_SchutzgebietNaturschutzrechtLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

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

-- ###########################################
-- ###########################################
-- nicht auf der Änderungs-Wikiseite dokumentierte Änderungen:
UPDATE "FP_Verkehr"."FP_ZweckbestimmungStrassenverkehr" SET "Code" = 140010 WHERE "Code" = 14010;
UPDATE "FP_Verkehr"."FP_ZweckbestimmungStrassenverkehr" SET "Code" = 140011 WHERE "Code" = 14011;

ALTER TABLE "RP_KernmodellSonstiges"."RP_ZweckbestimmungGenerischeObjekte" RENAME TO "RP_GenerischesObjektTypen";
ALTER TABLE "RP_KernmodellSonstiges"."RP_GenerischesObjekt" DROP CONSTRAINT "fk_RP_GenerischesObjekt_zweckbestimmung";
ALTER TABLE "RP_KernmodellSonstiges"."RP_GenerischesObjekt" RENAME "zweckbestimmung" TO "typ";
ALTER TABLE "RP_KernmodellSonstiges"."RP_GenerischesObjekt" ADD CONSTRAINT "fk_RP_GenerischesObjekt_typ"
    FOREIGN KEY ("typ" )
    REFERENCES "RP_KernmodellSonstiges"."RP_GenerischesObjektTypen" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE;

-- ###########################################
-- Überarbeitung RP_Objekt
-- -----------------------------------------------------
-- Table "RP_Basisobjekte"."RP_Objekt_gebietsTyp"
-- -----------------------------------------------------
CREATE TABLE "RP_Basisobjekte"."RP_Objekt_gebietsTyp" (
  "RP_Objekt_gid" BIGINT NOT NULL ,
  "gebietsTyp" INTEGER NOT NULL ,
  PRIMARY KEY ("RP_Objekt_gid", "gebietsTyp"),
  CONSTRAINT "fk_RP_Bodenschutz_gebietsTyp1"
    FOREIGN KEY ("RP_Objekt_gid" )
    REFERENCES "RP_Basisobjekte"."RP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_RP_Objekt_gebietsTyp2"
    FOREIGN KEY ("gebietsTyp" )
    REFERENCES "RP_Basisobjekte"."RP_GebietsTyp" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
GRANT SELECT ON TABLE "RP_Basisobjekte"."RP_Objekt_gebietsTyp" TO xp_gast;
GRANT ALL ON TABLE "RP_Basisobjekte"."RP_Objekt_gebietsTyp" TO rp_user;
COMMENT ON TABLE "RP_Basisobjekte"."RP_Objekt_gebietsTyp" IS 'Gebietstyp eines Objekts.';

INSERT INTO "RP_Basisobjekte"."RP_Objekt_gebietsTyp" ("RP_Objekt_gid","gebietsTyp") SELECT "RP_Bodenschutz_gid","gebietsTyp" FROM "RP_KernmodellFreiraumstruktur"."RP_Bodenschutz_gebietsTyp";
DROP TABLE "RP_KernmodellFreiraumstruktur"."RP_Bodenschutz_gebietsTyp";
INSERT INTO "RP_Basisobjekte"."RP_Objekt_gebietsTyp" ("RP_Objekt_gid","gebietsTyp") SELECT "RP_Forstwirtschaft_gid","gebietsTyp" FROM "RP_KernmodellFreiraumstruktur"."RP_Forstwirtschaft_gebietsTyp";
DROP TABLE "RP_KernmodellFreiraumstruktur"."RP_Forstwirtschaft_gebietsTyp";
INSERT INTO "RP_Basisobjekte"."RP_Objekt_gebietsTyp" ("RP_Objekt_gid","gebietsTyp") SELECT "RP_FreizeitErholung_gid","gebietsTyp" FROM "RP_KernmodellFreiraumstruktur"."RP_FreizeitErholung_gebietsTyp";
DROP TABLE "RP_KernmodellFreiraumstruktur"."RP_FreizeitErholung_gebietsTyp";
INSERT INTO "RP_Basisobjekte"."RP_Objekt_gebietsTyp" ("RP_Objekt_gid","gebietsTyp") SELECT "RP_GruenzugGruenzaesur_gid","gebietsTyp" FROM "RP_KernmodellFreiraumstruktur"."RP_GruenzugGruenzaesur_gebietsTyp";
DROP TABLE "RP_KernmodellFreiraumstruktur"."RP_GruenzugGruenzaesur_gebietsTyp";
INSERT INTO "RP_Basisobjekte"."RP_Objekt_gebietsTyp" ("RP_Objekt_gid","gebietsTyp") SELECT "RP_Klimaschutz_gid","gebietsTyp" FROM "RP_KernmodellFreiraumstruktur"."RP_Klimaschutz_gebietsTyp";
DROP TABLE "RP_KernmodellFreiraumstruktur"."RP_Klimaschutz_gebietsTyp";
INSERT INTO "RP_Basisobjekte"."RP_Objekt_gebietsTyp" ("RP_Objekt_gid","gebietsTyp") SELECT "RP_KulturellesSachgut_gid","gebietsTyp" FROM "RP_KernmodellFreiraumstruktur"."RP_KulturellesSachgut_gebietsTyp";
DROP TABLE "RP_KernmodellFreiraumstruktur"."RP_KulturellesSachgut_gebietsTyp";
INSERT INTO "RP_Basisobjekte"."RP_Objekt_gebietsTyp" ("RP_Objekt_gid","gebietsTyp") SELECT "RP_Landwirtschaft_gid","gebietsTyp" FROM "RP_KernmodellFreiraumstruktur"."RP_Landwirtschaft_gebietsTyp";
DROP TABLE "RP_KernmodellFreiraumstruktur"."RP_Landwirtschaft_gebietsTyp";
INSERT INTO "RP_Basisobjekte"."RP_Objekt_gebietsTyp" ("RP_Objekt_gid","gebietsTyp") SELECT "RP_NaturLandschaft_gid","gebietsTyp" FROM "RP_KernmodellFreiraumstruktur"."RP_NaturLandschaft_gebietsTyp";
DROP TABLE "RP_KernmodellFreiraumstruktur"."RP_NaturLandschaft_gebietsTyp";
INSERT INTO "RP_Basisobjekte"."RP_Objekt_gebietsTyp" ("RP_Objekt_gid","gebietsTyp") SELECT "RP_Rohstoffsicherung_gid","gebietsTyp" FROM "RP_KernmodellFreiraumstruktur"."RP_Rohstoffsicherung_gebietsTyp";
DROP TABLE "RP_KernmodellFreiraumstruktur"."RP_Rohstoffsicherung_gebietsTyp";
INSERT INTO "RP_Basisobjekte"."RP_Objekt_gebietsTyp" ("RP_Objekt_gid","gebietsTyp") SELECT "RP_SonstigerFreiraumstruktur_gid","gebietsTyp" FROM "RP_KernmodellFreiraumstruktur"."RP_SonstigerFreiraumstruktur_gebietsTyp";
DROP TABLE "RP_KernmodellFreiraumstruktur"."RP_SonstigerFreiraumstruktur_gebietsTyp";
INSERT INTO "RP_Basisobjekte"."RP_Objekt_gebietsTyp" ("RP_Objekt_gid","gebietsTyp") SELECT "RP_VorbHochwasserschutz_gid","gebietsTyp" FROM "RP_KernmodellFreiraumstruktur"."RP_VorbHochwasserschutz_gebietsTyp";
DROP TABLE "RP_KernmodellFreiraumstruktur"."RP_VorbHochwasserschutz_gebietsTyp";
INSERT INTO "RP_Basisobjekte"."RP_Objekt_gebietsTyp" ("RP_Objekt_gid","gebietsTyp") SELECT "RP_Wasserschutz_gid","gebietsTyp" FROM "RP_KernmodellFreiraumstruktur"."RP_Wasserschutz_gebietsTyp";
DROP TABLE "RP_KernmodellFreiraumstruktur"."RP_Wasserschutz_gebietsTyp";
INSERT INTO "RP_Basisobjekte"."RP_Objekt_gebietsTyp" ("RP_Objekt_gid","gebietsTyp") SELECT "RP_Windenergienutzung_gid","gebietsTyp" FROM "RP_KernmodellFreiraumstruktur"."RP_Windenergienutzung_gebietsTyp";
DROP TABLE "RP_KernmodellFreiraumstruktur"."RP_Windenergienutzung_gebietsTyp";
INSERT INTO "RP_Basisobjekte"."RP_Objekt_gebietsTyp" ("RP_Objekt_gid","gebietsTyp") SELECT "RP_Energieversorgung_gid","gebietsTyp" FROM "RP_KernmodellInfrastruktur"."RP_Energieversorgung_gebietsTyp";
DROP TABLE "RP_KernmodellInfrastruktur"."RP_Energieversorgung_gebietsTyp";
INSERT INTO "RP_Basisobjekte"."RP_Objekt_gebietsTyp" ("RP_Objekt_gid","gebietsTyp") SELECT "RP_Entsorgung_gid","gebietsTyp" FROM "RP_KernmodellInfrastruktur"."RP_Entsorgung_gebietsTyp";
DROP TABLE "RP_KernmodellInfrastruktur"."RP_Entsorgung_gebietsTyp";
INSERT INTO "RP_Basisobjekte"."RP_Objekt_gebietsTyp" ("RP_Objekt_gid","gebietsTyp") SELECT "RP_Kommunikation_gid","gebietsTyp" FROM "RP_KernmodellInfrastruktur"."RP_Kommunikation_gebietsTyp";
DROP TABLE "RP_KernmodellInfrastruktur"."RP_Kommunikation_gebietsTyp";
INSERT INTO "RP_Basisobjekte"."RP_Objekt_gebietsTyp" ("RP_Objekt_gid","gebietsTyp") SELECT "RP_Laermschutzbereich_gid","gebietsTyp" FROM "RP_KernmodellInfrastruktur"."RP_Laermschutzbereich_gebietsTyp";
DROP TABLE "RP_KernmodellInfrastruktur"."RP_Laermschutzbereich_gebietsTyp";
INSERT INTO "RP_Basisobjekte"."RP_Objekt_gebietsTyp" ("RP_Objekt_gid","gebietsTyp") SELECT "RP_SonstigeInfrastruktur_gid","gebietsTyp" FROM "RP_KernmodellInfrastruktur"."RP_SonstigeInfrastruktur_gebietsTyp";
DROP TABLE "RP_KernmodellInfrastruktur"."RP_SonstigeInfrastruktur_gebietsTyp";
INSERT INTO "RP_Basisobjekte"."RP_Objekt_gebietsTyp" ("RP_Objekt_gid","gebietsTyp") SELECT "RP_SozialeInfrastruktur_gid","gebietsTyp" FROM "RP_KernmodellInfrastruktur"."RP_SozialeInfrastruktur_gebietsTyp";
DROP TABLE "RP_KernmodellInfrastruktur"."RP_SozialeInfrastruktur_gebietsTyp";
INSERT INTO "RP_Basisobjekte"."RP_Objekt_gebietsTyp" ("RP_Objekt_gid","gebietsTyp") SELECT "RP_Verkehr_gid","gebietsTyp" FROM "RP_KernmodellInfrastruktur"."RP_Verkehr_gebietsTyp";
DROP TABLE "RP_KernmodellInfrastruktur"."RP_Verkehr_gebietsTyp";
INSERT INTO "RP_Basisobjekte"."RP_Objekt_gebietsTyp" ("RP_Objekt_gid","gebietsTyp") SELECT "RP_Wasserwirtschaft_gid","gebietsTyp" FROM "RP_KernmodellInfrastruktur"."RP_Wasserwirtschaft_gebietsTyp";
DROP TABLE "RP_KernmodellInfrastruktur"."RP_Wasserwirtschaft_gebietsTyp";
INSERT INTO "RP_Basisobjekte"."RP_Objekt_gebietsTyp" ("RP_Objekt_gid","gebietsTyp") SELECT "RP_GemeindeFunktionSiedlungsentwicklung_gid","gebietsTyp" FROM "RP_KernmodellSiedlungsstruktur"."RP_GemeindeFunktionSiedlungsentwicklung_gebietsTyp";
DROP TABLE "RP_KernmodellSiedlungsstruktur"."RP_GemeindeFunktionSiedlungsentwicklung_gebietsTyp";
INSERT INTO "RP_Basisobjekte"."RP_Objekt_gebietsTyp" ("RP_Objekt_gid","gebietsTyp") SELECT "RP_SonstigeSiedlungsstruktur_gid","gebietsTyp" FROM "RP_KernmodellSiedlungsstruktur"."RP_SonstigeSiedlungsstruktur_gebietsTyp";
DROP TABLE "RP_KernmodellSiedlungsstruktur"."RP_SonstigeSiedlungsstruktur_gebietsTyp";
INSERT INTO "RP_Basisobjekte"."RP_GebietsTyp" ("Code", "Bezeichner") VALUES ('1001', 'Vorrangstandort');
UPDATE "RP_Basisobjekte"."RP_GebietsTyp" SET "Code" = 1100 WHERE "Code" = 2000;
INSERT INTO "RP_Basisobjekte"."RP_GebietsTyp" ("Code", "Bezeichner") VALUES ('1101', 'Vorbehaltsstandort');
UPDATE "RP_Basisobjekte"."RP_GebietsTyp" SET "Code" = 1200 WHERE "Code" = 3000;
INSERT INTO "RP_Basisobjekte"."RP_GebietsTyp" ("Code", "Bezeichner") VALUES ('1300', 'VorrangundEignungsgebiet');
UPDATE "RP_Basisobjekte"."RP_GebietsTyp" SET "Code" = 1400 WHERE "Code" = 4000;
INSERT INTO "RP_Basisobjekte"."RP_GebietsTyp" ("Code", "Bezeichner") VALUES ('1500', 'Vorsorgegebiet');
INSERT INTO "RP_Basisobjekte"."RP_GebietsTyp" ("Code", "Bezeichner") VALUES ('1501', 'Vorsorgestandort');
INSERT INTO "RP_Basisobjekte"."RP_GebietsTyp" ("Code", "Bezeichner") VALUES ('1600', 'Vorzugsraum');
INSERT INTO "RP_Basisobjekte"."RP_GebietsTyp" ("Code", "Bezeichner") VALUES ('1700', 'Potenzialgebiet');
INSERT INTO "RP_Basisobjekte"."RP_GebietsTyp" ("Code", "Bezeichner") VALUES ('1800', 'Schwerpunktraum');
UPDATE "RP_Basisobjekte"."RP_GebietsTyp" SET "Code" = 9999 WHERE "Code" = 5000;


-- ###########################################
-- Überarbeitung RP_KernmodellFreiraumstruktur
ALTER SCHEMA "RP_KernmodellFreiraumstruktur" RENAME TO "RP_Freiraumstruktur";
-- -----------------------------------------------------
-- Table "RP_Freiraumstruktur"."RP_Freiraum"
-- -----------------------------------------------------
CREATE TABLE "RP_Freiraumstruktur"."RP_Freiraum" (
  "gid" BIGINT NOT NULL ,
  "istAusgleichsgebiet" BOOLEAN NULL,
  "imVerbund" BOOLEAN NULL,
  PRIMARY KEY ("gid"),
  CONSTRAINT "fk_RP_Freiraum_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "RP_Basisobjekte"."RP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE);

GRANT SELECT ON TABLE "RP_Freiraumstruktur"."RP_Freiraum" TO xp_gast;
GRANT ALL ON TABLE "RP_Freiraumstruktur"."RP_Freiraum" TO rp_user;
COMMENT ON TABLE "RP_Freiraumstruktur"."RP_Freiraum" IS 'Allgemeines Freiraumobjekt.
Freiräume sind naturnahem Zustand, oder beinhalten Nutzungsformen, die mit seinen ökologischen Grundfunktionen überwiegend verträglich sind (z.B. Land- oder Forstwirtschaft). Freiraum ist somit ein Gegenbegriff zur Siedlungsstruktur.';
COMMENT ON COLUMN "RP_Freiraumstruktur"."RP_Freiraum"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN "RP_Freiraumstruktur"."RP_Freiraum"."istAusgleichsgebiet" IS 'Zeigt an, ob das Objekt ein Ausgleichsgebiet ist.';
COMMENT ON COLUMN "RP_Freiraumstruktur"."RP_Freiraum"."imVerbund" IS 'Zeigt an, ob das Objekt in einem (Freiraum-)Verbund liegt.';
-- RP_Bodenschutz
ALTER TABLE "RP_Freiraumstruktur"."RP_Bodenschutz" DROP CONSTRAINT "fk_RP_Bodenschutz_parent";
INSERT INTO "RP_Freiraumstruktur"."RP_Freiraum" ("gid","istAusgleichsgebiet") SELECT "gid","istAusgleichsgebiet" FROM "RP_Freiraumstruktur"."RP_Bodenschutz";
ALTER TABLE "RP_Freiraumstruktur"."RP_Bodenschutz" ADD CONSTRAINT "fk_RP_Bodenschutz_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "RP_Freiraumstruktur"."RP_Freiraum" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE;
ALTER TABLE "RP_Freiraumstruktur"."RP_Bodenschutz" DROP COLUMN "istAusgleichsgebiet";
-- RP_FreizeitErholung -> RP_Erholung
ALTER TABLE "RP_Freiraumstruktur"."RP_FreizeitErholung" RENAME TO "RP_Erholung";
ALTER TABLE "RP_Freiraumstruktur"."RP_Erholung" DROP CONSTRAINT "fk_RP_FreizeitErholung_parent";
INSERT INTO "RP_Freiraumstruktur"."RP_Freiraum" ("gid","istAusgleichsgebiet") SELECT "gid","istAusgleichsgebiet" FROM "RP_Freiraumstruktur"."RP_Erholung";
ALTER TABLE "RP_Freiraumstruktur"."RP_Erholung" ADD CONSTRAINT "fk_RP_Erholung_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "RP_Freiraumstruktur"."RP_Freiraum" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE;
ALTER TABLE "RP_Freiraumstruktur"."RP_Erholung" DROP COLUMN "istAusgleichsgebiet";
COMMENT ON TABLE "RP_Freiraumstruktur"."RP_Erholung" IS 'Freizeit, Erholung und Tourismus.';
ALTER TABLE "RP_Freiraumstruktur"."RP_FreizeitErholungFlaeche" RENAME CONSTRAINT "fk_RP_FreizeitErholungFlaeche_parent" TO "fk_RP_ErholungFlaeche_parent";
ALTER TABLE "RP_Freiraumstruktur"."RP_FreizeitErholungFlaeche" RENAME TO "RP_ErholungFlaeche";
ALTER TABLE "RP_Freiraumstruktur"."RP_FreizeitErholungLinie" RENAME CONSTRAINT "fk_RP_FreizeitErholungLinie_parent" TO "fk_RP_ErholungLinie_parent";
ALTER TABLE "RP_Freiraumstruktur"."RP_FreizeitErholungLinie" RENAME TO "RP_ErholungLinie";
ALTER TABLE "RP_Freiraumstruktur"."RP_FreizeitErholungPunkt" RENAME CONSTRAINT "fk_RP_FreizeitErholungPunkt_parent" TO "fk_RP_ErholungPunkt_parent";
ALTER TABLE "RP_Freiraumstruktur"."RP_FreizeitErholungPunkt" RENAME TO "RP_ErholungPunkt";
-- RP_Windenergienutzung -> RP_ErneuerbareEnergie
CREATE TABLE "RP_Freiraumstruktur"."RP_ErneuerbareEnergieTypen" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Code") );
GRANT SELECT ON TABLE "RP_Freiraumstruktur"."RP_ErneuerbareEnergieTypen" TO xp_gast;
INSERT INTO "RP_Freiraumstruktur"."RP_ErneuerbareEnergieTypen" ("Code", "Bezeichner") VALUES ('1000', 'Windenergie');
INSERT INTO "RP_Freiraumstruktur"."RP_ErneuerbareEnergieTypen" ("Code", "Bezeichner") VALUES ('2000', 'Solarenergie');
INSERT INTO "RP_Freiraumstruktur"."RP_ErneuerbareEnergieTypen" ("Code", "Bezeichner") VALUES ('3000', 'Geothermie');
INSERT INTO "RP_Freiraumstruktur"."RP_ErneuerbareEnergieTypen" ("Code", "Bezeichner") VALUES ('4000', 'Biomasse');
INSERT INTO "RP_Freiraumstruktur"."RP_ErneuerbareEnergieTypen" ("Code", "Bezeichner") VALUES ('9999', 'SonstigeErneuerbareEnergie');
ALTER TABLE "RP_Freiraumstruktur"."RP_Windenergienutzung" RENAME TO "RP_ErneuerbareEnergie";
ALTER TABLE "RP_Freiraumstruktur"."RP_ErneuerbareEnergie" DROP CONSTRAINT "fk_RP_Windenergienutzung_parent";
INSERT INTO "RP_Freiraumstruktur"."RP_Freiraum" ("gid","istAusgleichsgebiet") SELECT "gid","istAusgleichsgebiet" FROM "RP_Freiraumstruktur"."RP_ErneuerbareEnergie";
ALTER TABLE "RP_Freiraumstruktur"."RP_ErneuerbareEnergie" ADD CONSTRAINT "fk_RP_ErneuerbareEnergie_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "RP_Freiraumstruktur"."RP_Freiraum" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE;
ALTER TABLE "RP_Freiraumstruktur"."RP_ErneuerbareEnergie" DROP COLUMN "istAusgleichsgebiet";
ALTER TABLE "RP_Freiraumstruktur"."RP_ErneuerbareEnergie" ADD COLUMN "typ" INTEGER;
COMMENT ON COLUMN "RP_Freiraumstruktur"."RP_ErneuerbareEnergie"."typ" IS 'Klassifikation von Typen Erneuerbarer Energie.';
ALTER TABLE "RP_Freiraumstruktur"."RP_ErneuerbareEnergie" ADD CONSTRAINT "fk_RP_ErneuerbareEnergie_typ"
    FOREIGN KEY ("typ")
    REFERENCES "RP_Freiraumstruktur"."RP_ErneuerbareEnergieTypen" ("Code")
    ON DELETE RESTRICT
    ON UPDATE CASCADE;
UPDATE "RP_Freiraumstruktur"."RP_ErneuerbareEnergie" set "typ" = 1000;
COMMENT ON TABLE "RP_Freiraumstruktur"."RP_ErneuerbareEnergie" IS 'Erneuerbare Energie inklusive Windenergienutzung.
Erneuerbare Energien sind Energiequellen, die keine endlichen Rohstoffe verbrauchen, sondern natürliche, sich erneuernde Kreisläufe anzapfen (Sonne, Wind, Wasserkraft, Bioenergie). Meist werden auch Gezeiten, die Meeresströmung und die Erdwärme dazugezählt.';
ALTER TABLE "RP_Freiraumstruktur"."RP_WindenergienutzungFlaeche" RENAME CONSTRAINT "fk_RP_WindenergienutzungFlaeche_parent" TO "fk_RP_ErneuerbareEnergieFlaeche_parent";
ALTER TABLE "RP_Freiraumstruktur"."RP_WindenergienutzungFlaeche" RENAME TO "RP_ErneuerbareEnergieFlaeche";
ALTER TABLE "RP_Freiraumstruktur"."RP_WindenergienutzungLinie" RENAME CONSTRAINT "fk_RP_WindenergienutzungLinie_parent" TO "fk_RP_ErneuerbareEnergieLinie_parent";
ALTER TABLE "RP_Freiraumstruktur"."RP_WindenergienutzungLinie" RENAME TO "RP_ErneuerbareEnergieLinie";
ALTER TABLE "RP_Freiraumstruktur"."RP_WindenergienutzungPunkt" RENAME CONSTRAINT "fk_RP_WindenergienutzungPunkt_parent" TO "fk_RP_ErneuerbareEnergiePunkt_parent";
ALTER TABLE "RP_Freiraumstruktur"."RP_WindenergienutzungPunkt" RENAME TO "RP_ErneuerbareEnergiePunkt";
-- RP_Forstwirtschaft
CREATE TABLE "RP_Freiraumstruktur"."RP_ForstwirtschaftTypen" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Code") );
GRANT SELECT ON TABLE "RP_Freiraumstruktur"."RP_ForstwirtschaftTypen" TO xp_gast;
INSERT INTO "RP_Freiraumstruktur"."RP_ForstwirtschaftTypen" ("Code", "Bezeichner") VALUES ('1000', 'Wald');
INSERT INTO "RP_Freiraumstruktur"."RP_ForstwirtschaftTypen" ("Code", "Bezeichner") VALUES ('1001', 'Bannwald');
INSERT INTO "RP_Freiraumstruktur"."RP_ForstwirtschaftTypen" ("Code", "Bezeichner") VALUES ('1002', 'Schonwald');
INSERT INTO "RP_Freiraumstruktur"."RP_ForstwirtschaftTypen" ("Code", "Bezeichner") VALUES ('2000', 'Waldmehrung');
INSERT INTO "RP_Freiraumstruktur"."RP_ForstwirtschaftTypen" ("Code", "Bezeichner") VALUES ('2001', 'WaldmehrungErholung');
INSERT INTO "RP_Freiraumstruktur"."RP_ForstwirtschaftTypen" ("Code", "Bezeichner") VALUES ('2002', 'VergroesserungDesWaldanteils');
INSERT INTO "RP_Freiraumstruktur"."RP_ForstwirtschaftTypen" ("Code", "Bezeichner") VALUES ('3000', 'Waldschutz');
INSERT INTO "RP_Freiraumstruktur"."RP_ForstwirtschaftTypen" ("Code", "Bezeichner") VALUES ('3001', 'BesondereSchutzfunktionDesWaldes');
INSERT INTO "RP_Freiraumstruktur"."RP_ForstwirtschaftTypen" ("Code", "Bezeichner") VALUES ('4000', 'VonAufforstungFreizuhalten');
INSERT INTO "RP_Freiraumstruktur"."RP_ForstwirtschaftTypen" ("Code", "Bezeichner") VALUES ('9999', 'SonstigeForstwirtschaft');
ALTER TABLE "RP_Freiraumstruktur"."RP_Forstwirtschaft" DROP CONSTRAINT "fk_RP_Forstwirtschaft_parent";
INSERT INTO "RP_Freiraumstruktur"."RP_Freiraum" ("gid","istAusgleichsgebiet") SELECT "gid","istAusgleichsgebiet" FROM "RP_Freiraumstruktur"."RP_Forstwirtschaft";
ALTER TABLE "RP_Freiraumstruktur"."RP_Forstwirtschaft" ADD CONSTRAINT "fk_RP_Forstwirtschaft_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "RP_Freiraumstruktur"."RP_Freiraum" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE;
ALTER TABLE "RP_Freiraumstruktur"."RP_Forstwirtschaft" DROP COLUMN "istAusgleichsgebiet";
ALTER TABLE "RP_Freiraumstruktur"."RP_Forstwirtschaft" ADD COLUMN "typ" INTEGER;
COMMENT ON COLUMN "RP_Freiraumstruktur"."RP_Forstwirtschaft"."typ" IS 'Klassifikation von Forstwirtschaftstypen und Wäldern.';
ALTER TABLE "RP_Freiraumstruktur"."RP_Forstwirtschaft" ADD CONSTRAINT "fk_RP_Forstwirtschaft_typ"
    FOREIGN KEY ("typ")
    REFERENCES "RP_Freiraumstruktur"."RP_ForstwirtschaftTypen" ("Code")
    ON DELETE RESTRICT
    ON UPDATE CASCADE;
COMMENT ON TABLE "RP_Freiraumstruktur"."RP_Forstwirtschaft" IS 'Forstwirtschaft ist die zielgerichtete Bewirtschaftung von Wäldern.
Die natürlichen Abläufe in den Waldökosystemen werden dabei so gestaltet und gesteuert, dass sie einen möglichst großen Beitrag zur Erfüllung von Leistungen erbringen, die von den Waldeigentümern und der Gesellschaft gewünscht werden.';
-- RP_Gewaesser
ALTER TABLE "RP_Freiraumstruktur"."RP_Gewaesser" DROP CONSTRAINT "fk_RP_Gewaesser_parent";
INSERT INTO "RP_Freiraumstruktur"."RP_Freiraum" ("gid","istAusgleichsgebiet") SELECT "gid","istAusgleichsgebiet" FROM "RP_Freiraumstruktur"."RP_Gewaesser";
ALTER TABLE "RP_Freiraumstruktur"."RP_Gewaesser" ADD CONSTRAINT "fk_RP_Gewaesser_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "RP_Freiraumstruktur"."RP_Freiraum" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE;
ALTER TABLE "RP_Freiraumstruktur"."RP_Gewaesser" DROP COLUMN "istAusgleichsgebiet";
ALTER TABLE "RP_Freiraumstruktur"."RP_Gewaesser" ADD COLUMN "gewaesserTyp" VARCHAR (255);
COMMENT ON COLUMN "RP_Freiraumstruktur"."RP_Gewaesser"."gewaesserTyp" IS 'Spezifiziert den Typ des Gewässers.';
COMMENT ON TABLE "RP_Freiraumstruktur"."RP_Gewaesser" IS 'Gewässer, die nicht andersweitig erfasst werden, zum Beispiel Flüsse oder Seen.';
-- RP_GruenzugGruenzaesur
CREATE TABLE "RP_Freiraumstruktur"."RP_ZaesurTypen" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Code") );
GRANT SELECT ON TABLE "RP_Freiraumstruktur"."RP_ZaesurTypen" TO xp_gast;
INSERT INTO "RP_Freiraumstruktur"."RP_ZaesurTypen" ("Code", "Bezeichner") VALUES ('1000', 'Gruenzug');
INSERT INTO "RP_Freiraumstruktur"."RP_ZaesurTypen" ("Code", "Bezeichner") VALUES ('2000', 'Gruenzaesur');
INSERT INTO "RP_Freiraumstruktur"."RP_ZaesurTypen" ("Code", "Bezeichner") VALUES ('3000', 'Siedlungszaesur');
CREATE TABLE "RP_Freiraumstruktur"."RP_GruenzugGruenzaesur_typ" (
  "RP_GruenzugGruenzaesur_gid" BIGINT NOT NULL,
  "typ" INTEGER NOT NULL,
  PRIMARY KEY ("RP_GruenzugGruenzaesur_gid", "typ"),
  CONSTRAINT "fk_RP_GruenzugGruenzaesur_typ1"
    FOREIGN KEY ("RP_GruenzugGruenzaesur_gid")
    REFERENCES "RP_Freiraumstruktur"."RP_GruenzugGruenzaesur" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_RP_GruenzugGruenzaesur_typ2"
    FOREIGN KEY ("typ")
    REFERENCES "RP_Freiraumstruktur"."RP_ZaesurTypen" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
GRANT SELECT ON TABLE "RP_Freiraumstruktur"."RP_GruenzugGruenzaesur_typ" TO xp_gast;
GRANT ALL ON TABLE "RP_Freiraumstruktur"."RP_GruenzugGruenzaesur_typ" TO rp_user;
COMMENT ON TABLE "RP_Freiraumstruktur"."RP_GruenzugGruenzaesur_typ" IS 'Klassifikation von Zäsurtypen.';
ALTER TABLE "RP_Freiraumstruktur"."RP_GruenzugGruenzaesur" DROP CONSTRAINT "fk_RP_GruenzugGruenzaesur_parent";
INSERT INTO "RP_Freiraumstruktur"."RP_Freiraum" ("gid","istAusgleichsgebiet") SELECT "gid","istAusgleichsgebiet" FROM "RP_Freiraumstruktur"."RP_GruenzugGruenzaesur";
ALTER TABLE "RP_Freiraumstruktur"."RP_GruenzugGruenzaesur" ADD CONSTRAINT "fk_RP_GruenzugGruenzaesur_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "RP_Freiraumstruktur"."RP_Freiraum" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE;
ALTER TABLE "RP_Freiraumstruktur"."RP_GruenzugGruenzaesur" DROP COLUMN "istAusgleichsgebiet";
-- RP_VorbHochwasserschutz -> RP_Hochwasserschutz
CREATE TABLE "RP_Freiraumstruktur"."RP_HochwasserschutzTypen" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Code") );
GRANT SELECT ON TABLE "RP_Freiraumstruktur"."RP_HochwasserschutzTypen" TO xp_gast;
INSERT INTO "RP_Freiraumstruktur"."RP_HochwasserschutzTypen" ("Code", "Bezeichner") VALUES ('1000', 'Hochwasserschutz');
INSERT INTO "RP_Freiraumstruktur"."RP_HochwasserschutzTypen" ("Code", "Bezeichner") VALUES ('1001', 'TechnischerHochwasserschutz');
INSERT INTO "RP_Freiraumstruktur"."RP_HochwasserschutzTypen" ("Code", "Bezeichner") VALUES ('1100', 'Hochwasserrueckhaltebecken');
INSERT INTO "RP_Freiraumstruktur"."RP_HochwasserschutzTypen" ("Code", "Bezeichner") VALUES ('1101', 'HochwasserrueckhaltebeckenPolder');
INSERT INTO "RP_Freiraumstruktur"."RP_HochwasserschutzTypen" ("Code", "Bezeichner") VALUES ('1102', 'HochwasserrueckhaltebeckenBauwerk');
INSERT INTO "RP_Freiraumstruktur"."RP_HochwasserschutzTypen" ("Code", "Bezeichner") VALUES ('1200', 'RisikobereichHochwasser');
INSERT INTO "RP_Freiraumstruktur"."RP_HochwasserschutzTypen" ("Code", "Bezeichner") VALUES ('1300', 'Kuestenhochwasserschutz');
INSERT INTO "RP_Freiraumstruktur"."RP_HochwasserschutzTypen" ("Code", "Bezeichner") VALUES ('1301', 'Deich');
INSERT INTO "RP_Freiraumstruktur"."RP_HochwasserschutzTypen" ("Code", "Bezeichner") VALUES ('1302', 'Deichrueckverlegung');
INSERT INTO "RP_Freiraumstruktur"."RP_HochwasserschutzTypen" ("Code", "Bezeichner") VALUES ('1303', 'DeichgeschuetztesGebiet');
INSERT INTO "RP_Freiraumstruktur"."RP_HochwasserschutzTypen" ("Code", "Bezeichner") VALUES ('1400', 'Sperrwerk');
INSERT INTO "RP_Freiraumstruktur"."RP_HochwasserschutzTypen" ("Code", "Bezeichner") VALUES ('1500', 'HochwGefaehrdeteKuestenniederung');
INSERT INTO "RP_Freiraumstruktur"."RP_HochwasserschutzTypen" ("Code", "Bezeichner") VALUES ('1600', 'Ueberschwemmungsgebiet');
INSERT INTO "RP_Freiraumstruktur"."RP_HochwasserschutzTypen" ("Code", "Bezeichner") VALUES ('1700', 'UeberschwemmungsgefaehrdeterBereich');
INSERT INTO "RP_Freiraumstruktur"."RP_HochwasserschutzTypen" ("Code", "Bezeichner") VALUES ('1800', 'Retentionsraum');
INSERT INTO "RP_Freiraumstruktur"."RP_HochwasserschutzTypen" ("Code", "Bezeichner") VALUES ('1801', 'PotenziellerRetentionsraum');
INSERT INTO "RP_Freiraumstruktur"."RP_HochwasserschutzTypen" ("Code", "Bezeichner") VALUES ('9999', 'SonstigerHochwasserschutz');
ALTER TABLE "RP_Freiraumstruktur"."RP_VorbHochwasserschutz" RENAME TO "RP_Hochwasserschutz";
ALTER TABLE "RP_Freiraumstruktur"."RP_Hochwasserschutz" DROP CONSTRAINT "fk_RP_VorbHochwasserschutz_parent";
INSERT INTO "RP_Freiraumstruktur"."RP_Freiraum" ("gid","istAusgleichsgebiet") SELECT "gid","istAusgleichsgebiet" FROM "RP_Freiraumstruktur"."RP_Hochwasserschutz";
ALTER TABLE "RP_Freiraumstruktur"."RP_Hochwasserschutz" ADD CONSTRAINT "fk_RP_Hochwasserschutz_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "RP_Freiraumstruktur"."RP_Freiraum" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE;
ALTER TABLE "RP_Freiraumstruktur"."RP_Hochwasserschutz" DROP COLUMN "istAusgleichsgebiet";
COMMENT ON TABLE "RP_Freiraumstruktur"."RP_Hochwasserschutz" IS 'Die Klasse RP_Hochwasserschutz enthält Hochwasserschutz und vorbeugenden Hochwasserschutz.
Hochwasserschutz und vorbeugender Hochwasserschutz beinhaltet den Schutz von Siedlungen, Nutz- und Verkehrsflächen vor Überschwemmungen. Im Binnenland besteht der Hochwasserschutz vor allem in der Sicherung und Rückgewinnung von Auen, Wasserrückhalteflächen (Retentionsflächen) und überschwemmungsgefährdeten Bereichen. An der Nord- und Ostsee erfolgt der Schutz vor Sturmfluten hauptsächlich durch Deiche und Siele (Küstenschutz).';
CREATE TABLE "RP_Freiraumstruktur"."RP_Hochwasserschutz_typ" (
  "RP_Hochwasserschutz_gid" BIGINT NOT NULL,
  "typ" INTEGER NOT NULL,
  PRIMARY KEY ("RP_Hochwasserschutz_gid", "typ"),
  CONSTRAINT "fk_RP_Hochwasserschutz_typ1"
    FOREIGN KEY ("RP_Hochwasserschutz_gid")
    REFERENCES "RP_Freiraumstruktur"."RP_Hochwasserschutz" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_RP_Hochwasserschutz_typ2"
    FOREIGN KEY ("typ")
    REFERENCES "RP_Freiraumstruktur"."RP_HochwasserschutzTypen" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
COMMENT ON TABLE "RP_Freiraumstruktur"."RP_Hochwasserschutz_typ" IS 'Klassifikation von Hochwasserschutztypen.';
GRANT SELECT ON TABLE "RP_Freiraumstruktur"."RP_Hochwasserschutz_typ" TO xp_gast;
GRANT ALL ON TABLE "RP_Freiraumstruktur"."RP_Hochwasserschutz_typ" TO rp_user;
ALTER TABLE "RP_Freiraumstruktur"."RP_VorbHochwasserschutzFlaeche" RENAME CONSTRAINT "fk_RP_VorbHochwasserschutzFlaeche_parent" TO "fk_RP_HochwasserschutzFlaeche_parent";
ALTER TABLE "RP_Freiraumstruktur"."RP_VorbHochwasserschutzFlaeche" RENAME TO "RP_HochwasserschutzFlaeche";
ALTER TABLE "RP_Freiraumstruktur"."RP_VorbHochwasserschutzLinie" RENAME CONSTRAINT "fk_RP_VorbHochwasserschutzLinie_parent" TO "fk_RP_HochwasserschutzLinie_parent";
ALTER TABLE "RP_Freiraumstruktur"."RP_VorbHochwasserschutzLinie" RENAME TO "RP_HochwasserschutzLinie";
ALTER TABLE "RP_Freiraumstruktur"."RP_VorbHochwasserschutzPunkt" RENAME CONSTRAINT "fk_RP_VorbHochwasserschutzPunkt_parent" TO "fk_RP_HochwasserschutzPunkt_parent";
ALTER TABLE "RP_Freiraumstruktur"."RP_VorbHochwasserschutzPunkt" RENAME TO "RP_HochwasserschutzPunkt";
-- RP_Klimaschutz
CREATE TABLE "RP_Freiraumstruktur"."RP_LuftTypen" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Code") );
GRANT SELECT ON TABLE "RP_Freiraumstruktur"."RP_LuftTypen" TO xp_gast;
INSERT INTO "RP_Freiraumstruktur"."RP_LuftTypen" ("Code", "Bezeichner") VALUES ('1000', 'Kaltluft');
INSERT INTO "RP_Freiraumstruktur"."RP_LuftTypen" ("Code", "Bezeichner") VALUES ('2000', 'Frischluft');
INSERT INTO "RP_Freiraumstruktur"."RP_LuftTypen" ("Code", "Bezeichner") VALUES ('9999', 'SonstigeLufttypen');
ALTER TABLE "RP_Freiraumstruktur"."RP_Klimaschutz" DROP CONSTRAINT "fk_RP_Klimaschutz_parent";
INSERT INTO "RP_Freiraumstruktur"."RP_Freiraum" ("gid","istAusgleichsgebiet") SELECT "gid","istAusgleichsgebiet" FROM "RP_Freiraumstruktur"."RP_Klimaschutz";
ALTER TABLE "RP_Freiraumstruktur"."RP_Klimaschutz" ADD CONSTRAINT "fk_RP_Klimaschutz_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "RP_Freiraumstruktur"."RP_Freiraum" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE;
ALTER TABLE "RP_Freiraumstruktur"."RP_Klimaschutz" DROP COLUMN "istAusgleichsgebiet";
COMMENT ON TABLE "RP_Freiraumstruktur"."RP_Klimaschutz" IS '(Siedlungs-) Klimaschutz. Beinhaltet zum Beispiel auch Kalt- und Frischluftschneisen.';
CREATE TABLE "RP_Freiraumstruktur"."RP_Klimaschutz_typ" (
  "RP_Klimaschutz_gid" BIGINT NOT NULL,
  "typ" INTEGER NOT NULL,
  PRIMARY KEY ("RP_Klimaschutz_gid", "typ"),
  CONSTRAINT "fk_RP_Klimaschutz_typ1"
    FOREIGN KEY ("RP_Klimaschutz_gid")
    REFERENCES "RP_Freiraumstruktur"."RP_Klimaschutz" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_RP_Klimaschutz_typ2"
    FOREIGN KEY ("typ")
    REFERENCES "RP_Freiraumstruktur"."RP_LuftTypen" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
GRANT SELECT ON TABLE "RP_Freiraumstruktur"."RP_Klimaschutz_typ" TO xp_gast;
GRANT ALL ON TABLE "RP_Freiraumstruktur"."RP_Klimaschutz_typ" TO rp_user;

-- RP_KulturellesSachgut -> RP_Kulturlandschaft
CREATE TABLE "RP_Freiraumstruktur"."RP_KulturlandschaftTypen" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Code") );
GRANT SELECT ON TABLE "RP_Freiraumstruktur"."RP_KulturlandschaftTypen" TO xp_gast;
INSERT INTO "RP_Freiraumstruktur"."RP_KulturlandschaftTypen" ("Code", "Bezeichner") VALUES ('1000', 'KulturellesSachgut');
INSERT INTO "RP_Freiraumstruktur"."RP_KulturlandschaftTypen" ("Code", "Bezeichner") VALUES ('2000', 'Welterbe');
INSERT INTO "RP_Freiraumstruktur"."RP_KulturlandschaftTypen" ("Code", "Bezeichner") VALUES ('3000', 'KulturerbeLandschaft');
INSERT INTO "RP_Freiraumstruktur"."RP_KulturlandschaftTypen" ("Code", "Bezeichner") VALUES ('4000', 'KulturDenkmalpflege');
INSERT INTO "RP_Freiraumstruktur"."RP_KulturlandschaftTypen" ("Code", "Bezeichner") VALUES ('9999', 'SonstigeKulturlandschaftTypen');
ALTER TABLE "RP_Freiraumstruktur"."RP_KulturellesSachgut" RENAME TO "RP_Kulturlandschaft";
ALTER TABLE "RP_Freiraumstruktur"."RP_Kulturlandschaft" DROP CONSTRAINT "fk_RP_KulturellesSachgut_parent";
INSERT INTO "RP_Freiraumstruktur"."RP_Freiraum" ("gid","istAusgleichsgebiet") SELECT "gid","istAusgleichsgebiet" FROM "RP_Freiraumstruktur"."RP_Kulturlandschaft";
ALTER TABLE "RP_Freiraumstruktur"."RP_Kulturlandschaft" ADD CONSTRAINT "fk_RP_Kulturlandschaft_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "RP_Freiraumstruktur"."RP_Freiraum" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE;
ALTER TABLE "RP_Freiraumstruktur"."RP_Kulturlandschaft" DROP COLUMN "istAusgleichsgebiet";
ALTER TABLE "RP_Freiraumstruktur"."RP_Kulturlandschaft" ADD COLUMN "typ" INTEGER;
COMMENT ON COLUMN "RP_Freiraumstruktur"."RP_Kulturlandschaft"."typ" IS 'Klassifikation von Kulturlandschaftstypen.';
ALTER TABLE "RP_Freiraumstruktur"."RP_Kulturlandschaft" ADD CONSTRAINT "fk_RP_Kulturlandschaft_typ"
    FOREIGN KEY ("typ")
    REFERENCES "RP_Freiraumstruktur"."RP_KulturlandschaftTypen" ("Code")
    ON DELETE RESTRICT
    ON UPDATE CASCADE;
UPDATE "RP_Freiraumstruktur"."RP_Kulturlandschaft" set "typ" = 1000;
COMMENT ON TABLE "RP_Freiraumstruktur"."RP_Kulturlandschaft" IS 'Landschaftsbereich mit überwiegend anthropogenen Ökosystemen (historisch geprägt und gewachsen). Sie sind nach §2, Nr. 5 des ROG mit ihren Kultur- und Naturdenkmälern zu erhalten und zu entwickeln.
Beinhaltet unter anderem die Begriffe Kulturlandschaft, kulturelle Sachgüter und Welterbestätten.';
ALTER TABLE "RP_Freiraumstruktur"."RP_KulturellesSachgutFlaeche" RENAME CONSTRAINT "fk_RP_KulturellesSachgutFlaeche_parent" TO "fk_RP_KulturlandschaftFlaeche_parent";
ALTER TABLE "RP_Freiraumstruktur"."RP_KulturellesSachgutFlaeche" RENAME TO "RP_KulturlandschaftFlaeche";
ALTER TABLE "RP_Freiraumstruktur"."RP_KulturellesSachgutLinie" RENAME CONSTRAINT "fk_RP_KulturellesSachgutLinie_parent" TO "fk_RP_KulturlandschaftLinie_parent";
ALTER TABLE "RP_Freiraumstruktur"."RP_KulturellesSachgutLinie" RENAME TO "RP_KulturlandschaftLinie";
ALTER TABLE "RP_Freiraumstruktur"."RP_KulturellesSachgutPunkt" RENAME CONSTRAINT "fk_RP_KulturellesSachgutPunkt_parent" TO "fk_RP_KulturlandschaftPunkt_parent";
ALTER TABLE "RP_Freiraumstruktur"."RP_KulturellesSachgutPunkt" RENAME TO "RP_KulturlandschaftPunkt";
-- RP_Landwirtschaft
CREATE TABLE "RP_Freiraumstruktur"."RP_LandwirtschaftTypen" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Code") );
GRANT SELECT ON TABLE "RP_Freiraumstruktur"."RP_LandwirtschaftTypen" TO xp_gast;
INSERT INTO "RP_Freiraumstruktur"."RP_LandwirtschaftTypen" ("Code", "Bezeichner") VALUES ('1000', 'LandwirtschaftlicheNutzung');
INSERT INTO "RP_Freiraumstruktur"."RP_LandwirtschaftTypen" ("Code", "Bezeichner") VALUES ('1001', 'KernzoneLandwirtschaft');
INSERT INTO "RP_Freiraumstruktur"."RP_LandwirtschaftTypen" ("Code", "Bezeichner") VALUES ('2000', 'IntensivLandwirtschaft');
INSERT INTO "RP_Freiraumstruktur"."RP_LandwirtschaftTypen" ("Code", "Bezeichner") VALUES ('3000', 'Fischerei');
INSERT INTO "RP_Freiraumstruktur"."RP_LandwirtschaftTypen" ("Code", "Bezeichner") VALUES ('4000', 'Weinbau');
INSERT INTO "RP_Freiraumstruktur"."RP_LandwirtschaftTypen" ("Code", "Bezeichner") VALUES ('5000', 'AufGrundHohenErtragspotenzials');
INSERT INTO "RP_Freiraumstruktur"."RP_LandwirtschaftTypen" ("Code", "Bezeichner") VALUES ('6000', 'AufGrundBesondererFunktionen');
INSERT INTO "RP_Freiraumstruktur"."RP_LandwirtschaftTypen" ("Code", "Bezeichner") VALUES ('7000', 'Gruenlandbewirtschaftung');
INSERT INTO "RP_Freiraumstruktur"."RP_LandwirtschaftTypen" ("Code", "Bezeichner") VALUES ('8000', 'Sonderkultur');
INSERT INTO "RP_Freiraumstruktur"."RP_LandwirtschaftTypen" ("Code", "Bezeichner") VALUES ('9999', 'SonstigeLandwirtschaft');
ALTER TABLE "RP_Freiraumstruktur"."RP_Landwirtschaft" DROP CONSTRAINT "fk_RP_Landwirtschaft_parent";
INSERT INTO "RP_Freiraumstruktur"."RP_Freiraum" ("gid","istAusgleichsgebiet") SELECT "gid","istAusgleichsgebiet" FROM "RP_Freiraumstruktur"."RP_Landwirtschaft";
ALTER TABLE "RP_Freiraumstruktur"."RP_Landwirtschaft" ADD CONSTRAINT "fk_RP_Landwirtschaft_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "RP_Freiraumstruktur"."RP_Freiraum" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE;
ALTER TABLE "RP_Freiraumstruktur"."RP_Landwirtschaft" DROP COLUMN "istAusgleichsgebiet";
ALTER TABLE "RP_Freiraumstruktur"."RP_Landwirtschaft" ADD COLUMN "typ" INTEGER;
COMMENT ON COLUMN "RP_Freiraumstruktur"."RP_Landwirtschaft"."typ" IS 'Klassifikation von Landwirtschaftstypen.';
ALTER TABLE "RP_Freiraumstruktur"."RP_Landwirtschaft" ADD CONSTRAINT "fk_RP_Landwirtschaft_typ"
    FOREIGN KEY ("typ")
    REFERENCES "RP_Freiraumstruktur"."RP_LandwirtschaftTypen" ("Code")
    ON DELETE RESTRICT
    ON UPDATE CASCADE;
UPDATE "RP_Freiraumstruktur"."RP_Landwirtschaft" set "typ" = 1000;
COMMENT ON TABLE "RP_Freiraumstruktur"."RP_Landwirtschaft" IS 'Landwirtschaft, hauptsächlich im ländlichen Raum angesiedelt, erfüllt für die Gesellschaft wichtige Funktionen in der Produktion- und Versorgung mit Lebensmitteln, für Freizeit und Freiraum oder zur Biodiversität.';

-- RP_NaturLandschaft
-- -----------------------------------------------------
-- Table "RP_Freiraumstruktur"."RP_NaturLandschaftTypen"
-- -----------------------------------------------------
CREATE TABLE "RP_Freiraumstruktur"."RP_NaturLandschaftTypen" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Code") );
GRANT SELECT ON TABLE "RP_Freiraumstruktur"."RP_NaturLandschaftTypen" TO xp_gast;
INSERT INTO "RP_Freiraumstruktur"."RP_NaturLandschaftTypen" ("Code", "Bezeichner") VALUES ('1000', 'NaturLandschaft');
INSERT INTO "RP_Freiraumstruktur"."RP_NaturLandschaftTypen" ("Code", "Bezeichner") VALUES ('1100', 'NaturschutzLandschaftspflege');
INSERT INTO "RP_Freiraumstruktur"."RP_NaturLandschaftTypen" ("Code", "Bezeichner") VALUES ('1101', 'NaturschutzLandschaftspflegeAufGewaessern');
INSERT INTO "RP_Freiraumstruktur"."RP_NaturLandschaftTypen" ("Code", "Bezeichner") VALUES ('1200', 'Flurdurchgruenung');
INSERT INTO "RP_Freiraumstruktur"."RP_NaturLandschaftTypen" ("Code", "Bezeichner") VALUES ('1300', 'UnzerschnitteneRaeume');
INSERT INTO "RP_Freiraumstruktur"."RP_NaturLandschaftTypen" ("Code", "Bezeichner") VALUES ('1301', 'UnzerschnitteneVerkehrsarmeRaeume');
INSERT INTO "RP_Freiraumstruktur"."RP_NaturLandschaftTypen" ("Code", "Bezeichner") VALUES ('1400', 'Feuchtgebiet');
INSERT INTO "RP_Freiraumstruktur"."RP_NaturLandschaftTypen" ("Code", "Bezeichner") VALUES ('1500', 'OekologischesVerbundssystem');
INSERT INTO "RP_Freiraumstruktur"."RP_NaturLandschaftTypen" ("Code", "Bezeichner") VALUES ('1501', 'OekologischerRaum');
INSERT INTO "RP_Freiraumstruktur"."RP_NaturLandschaftTypen" ("Code", "Bezeichner") VALUES ('1600', 'VerbesserungLandschaftsstrukturNaturhaushalt');
INSERT INTO "RP_Freiraumstruktur"."RP_NaturLandschaftTypen" ("Code", "Bezeichner") VALUES ('1700', 'Biotop');
INSERT INTO "RP_Freiraumstruktur"."RP_NaturLandschaftTypen" ("Code", "Bezeichner") VALUES ('1701', 'Biotopverbund');
INSERT INTO "RP_Freiraumstruktur"."RP_NaturLandschaftTypen" ("Code", "Bezeichner") VALUES ('1702', 'Biotopverbundachse');
INSERT INTO "RP_Freiraumstruktur"."RP_NaturLandschaftTypen" ("Code", "Bezeichner") VALUES ('1703', 'ArtenBiotopschutz');
INSERT INTO "RP_Freiraumstruktur"."RP_NaturLandschaftTypen" ("Code", "Bezeichner") VALUES ('1704', 'Regionalpark');
INSERT INTO "RP_Freiraumstruktur"."RP_NaturLandschaftTypen" ("Code", "Bezeichner") VALUES ('1800', 'KompensationEntwicklung');
INSERT INTO "RP_Freiraumstruktur"."RP_NaturLandschaftTypen" ("Code", "Bezeichner") VALUES ('1900', 'GruenlandBewirtschaftungPflegeEntwicklung');
INSERT INTO "RP_Freiraumstruktur"."RP_NaturLandschaftTypen" ("Code", "Bezeichner") VALUES ('2000', 'Landschaftsstruktur');
INSERT INTO "RP_Freiraumstruktur"."RP_NaturLandschaftTypen" ("Code", "Bezeichner") VALUES ('2100', 'LandschaftErholung');
INSERT INTO "RP_Freiraumstruktur"."RP_NaturLandschaftTypen" ("Code", "Bezeichner") VALUES ('2200', 'Landschaftspraegend');
INSERT INTO "RP_Freiraumstruktur"."RP_NaturLandschaftTypen" ("Code", "Bezeichner") VALUES ('2300', 'SchutzderNatur');
INSERT INTO "RP_Freiraumstruktur"."RP_NaturLandschaftTypen" ("Code", "Bezeichner") VALUES ('2400', 'SchutzdesLandschaftsbildes');
INSERT INTO "RP_Freiraumstruktur"."RP_NaturLandschaftTypen" ("Code", "Bezeichner") VALUES ('2500', 'Alpenpark');
INSERT INTO "RP_Freiraumstruktur"."RP_NaturLandschaftTypen" ("Code", "Bezeichner") VALUES ('9999', 'SonstigerNaturLandschaftSchutz');
ALTER TABLE "RP_Freiraumstruktur"."RP_NaturLandschaft" DROP CONSTRAINT "fk_RP_NaturLandschaft_parent";
INSERT INTO "RP_Freiraumstruktur"."RP_Freiraum" ("gid","istAusgleichsgebiet") SELECT "gid","istAusgleichsgebiet" FROM "RP_Freiraumstruktur"."RP_NaturLandschaft";
ALTER TABLE "RP_Freiraumstruktur"."RP_NaturLandschaft" ADD CONSTRAINT "fk_RP_NaturLandschaft_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "RP_Freiraumstruktur"."RP_Freiraum" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE;
ALTER TABLE "RP_Freiraumstruktur"."RP_NaturLandschaft" DROP COLUMN "istAusgleichsgebiet";
COMMENT ON TABLE "RP_Freiraumstruktur"."RP_NaturLandschaft" IS 'Naturlandschaften sind von umitellbaren menschlichen Aktivitäten weitestgehend unbeeinflusst gebliebene Landschaft.';

-- -----------------------------------------------------
-- Table "RP_Freiraumstruktur"."RP_NaturLandschaft_typ"
-- -----------------------------------------------------
CREATE TABLE "RP_Freiraumstruktur"."RP_NaturLandschaft_typ" (
  "RP_NaturLandschaft_gid" BIGINT NOT NULL,
  "typ" INTEGER NOT NULL,
  PRIMARY KEY ("RP_NaturLandschaft_gid", "typ"),
  CONSTRAINT "fk_RP_NaturLandschaft_typ1"
    FOREIGN KEY ("RP_NaturLandschaft_gid")
    REFERENCES "RP_Freiraumstruktur"."RP_NaturLandschaft" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_RP_NaturLandschaft_typ2"
    FOREIGN KEY ("typ")
    REFERENCES "RP_Freiraumstruktur"."RP_NaturLandschaftTypen" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
COMMENT ON TABLE "RP_Freiraumstruktur"."RP_NaturLandschaft_typ" IS 'Klassifikation von Naturschutz, Landschaftsschutz und Naturlandschafttypen.';
GRANT SELECT ON TABLE "RP_Freiraumstruktur"."RP_NaturLandschaft_typ" TO xp_gast;
GRANT ALL ON TABLE "RP_Freiraumstruktur"."RP_NaturLandschaft_typ" TO rp_user;
-- RP_NaturschutzrechtlichesSchutzgebiet
ALTER TABLE "RP_Freiraumstruktur"."RP_NaturschutzrechtlichesSchutzgebiet" DROP CONSTRAINT "fk_RP_NaturschutzrechtlichesSchutzgebiet_parent";
INSERT INTO "RP_Freiraumstruktur"."RP_Freiraum" ("gid","istAusgleichsgebiet") SELECT "gid","istAusgleichsgebiet" FROM "RP_Freiraumstruktur"."RP_NaturschutzrechtlichesSchutzgebiet";
ALTER TABLE "RP_Freiraumstruktur"."RP_NaturschutzrechtlichesSchutzgebiet" ADD CONSTRAINT "fk_RP_NaturschutzrechtlichesSchutzgebiet_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "RP_Freiraumstruktur"."RP_Freiraum" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE;
ALTER TABLE "RP_Freiraumstruktur"."RP_NaturschutzrechtlichesSchutzgebiet" DROP COLUMN "istAusgleichsgebiet";

-- -----------------------------------------------------
-- Table "RP_Freiraumstruktur"."RP_NaturschutzrechtlichesSchutzgebiet_typ"
-- -----------------------------------------------------
CREATE TABLE "RP_Freiraumstruktur"."RP_NaturschutzrechtlichesSchutzgebiet_typ" (
  "RP_NaturschutzrechtlichesSchutzgebiet_gid" BIGINT NOT NULL,
  "typ" INTEGER NOT NULL,
  PRIMARY KEY ("RP_NaturschutzrechtlichesSchutzgebiet_gid", "typ"),
  CONSTRAINT "fk_RP_NaturschutzrechtlichesSchutzgebiet_typ1"
    FOREIGN KEY ("RP_NaturschutzrechtlichesSchutzgebiet_gid")
    REFERENCES "RP_Freiraumstruktur"."RP_NaturschutzrechtlichesSchutzgebiet" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_RP_NaturschutzrechtlichesSchutzgebiet_typ2"
    FOREIGN KEY ("typ")
    REFERENCES "XP_Enumerationen"."XP_KlassifizSchutzgebietNaturschutzrecht" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
COMMENT ON TABLE "RP_Freiraumstruktur"."RP_NaturschutzrechtlichesSchutzgebiet_typ" IS 'Klassifikation des Naturschutzgebietes.';
GRANT SELECT ON TABLE "RP_Freiraumstruktur"."RP_NaturschutzrechtlichesSchutzgebiet_typ" TO xp_gast;
GRANT ALL ON TABLE "RP_Freiraumstruktur"."RP_NaturschutzrechtlichesSchutzgebiet_typ" TO rp_user;
INSERT INTO "RP_Freiraumstruktur"."RP_NaturschutzrechtlichesSchutzgebiet_typ" ("RP_NaturschutzrechtlichesSchutzgebiet_gid","typ")
  SELECT gid,"zweckbestimmung" FROM "RP_Freiraumstruktur"."RP_NaturschutzrechtlichesSchutzgebiet" WHERE "zweckbestimmung" IS NOT NULL;
ALTER TABLE "RP_Freiraumstruktur"."RP_NaturschutzrechtlichesSchutzgebiet" DROP COLUMN "zweckbestimmung";
ALTER TABLE "RP_Freiraumstruktur"."RP_NaturschutzrechtlichesSchutzgebiet" ADD COLUMN "istKernzone" BOOLEAN;
COMMENT ON COLUMN "RP_Freiraumstruktur"."RP_NaturschutzrechtlichesSchutzgebiet"."istKernzone" IS 'Gibt an, ob es sich um eine Kernzone handelt.';

-- neue Klasse RP_RadwegWanderweg
-- -----------------------------------------------------
-- Table "RP_Freiraumstruktur"."RP_RadwegWanderwegTypen"
-- -----------------------------------------------------
CREATE TABLE "RP_Freiraumstruktur"."RP_RadwegWanderwegTypen" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Code") );
GRANT SELECT ON TABLE "RP_Freiraumstruktur"."RP_RadwegWanderwegTypen" TO xp_gast;

-- -----------------------------------------------------
-- Table "RP_Freiraumstruktur"."RP_RadwegWanderweg"
-- -----------------------------------------------------
CREATE TABLE "RP_Freiraumstruktur"."RP_RadwegWanderweg" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid"),
  CONSTRAINT "fk_RP_RadwegWanderweg_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "RP_Freiraumstruktur"."RP_Freiraum" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE);

GRANT SELECT ON TABLE "RP_Freiraumstruktur"."RP_RadwegWanderweg" TO xp_gast;
GRANT ALL ON TABLE "RP_Freiraumstruktur"."RP_RadwegWanderweg" TO rp_user;
COMMENT ON TABLE "RP_Freiraumstruktur"."RP_RadwegWanderweg" IS 'Radwege und Wanderwege. Straßenbegleitend oder selbstständig geführt.';
COMMENT ON COLUMN "RP_Freiraumstruktur"."RP_RadwegWanderweg"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_RP_RadwegWanderweg" BEFORE INSERT OR UPDATE ON "RP_Freiraumstruktur"."RP_RadwegWanderweg" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_RadwegWanderweg" AFTER DELETE ON "RP_Freiraumstruktur"."RP_RadwegWanderweg" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "RP_Freiraumstruktur"."RP_RadwegWanderweg_typ"
-- -----------------------------------------------------
CREATE TABLE "RP_Freiraumstruktur"."RP_RadwegWanderweg_typ" (
  "RP_RadwegWanderweg_gid" BIGINT NOT NULL,
  "typ" INTEGER NOT NULL,
  PRIMARY KEY ("RP_RadwegWanderweg_gid", "typ"),
  CONSTRAINT "fk_RP_RadwegWanderweg_typ1"
    FOREIGN KEY ("RP_RadwegWanderweg_gid")
    REFERENCES "RP_Freiraumstruktur"."RP_RadwegWanderweg" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_RP_RadwegWanderweg_typ2"
    FOREIGN KEY ("typ")
    REFERENCES "RP_Freiraumstruktur"."RP_RadwegWanderwegTypen" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
COMMENT ON TABLE "RP_Freiraumstruktur"."RP_RadwegWanderweg_typ" IS 'KKlassifikation von Radwegen und Wanderwegen.';
GRANT SELECT ON TABLE "RP_Freiraumstruktur"."RP_RadwegWanderweg_typ" TO xp_gast;
GRANT ALL ON TABLE "RP_Freiraumstruktur"."RP_RadwegWanderweg_typ" TO rp_user;

-- -----------------------------------------------------
-- Table "RP_Freiraumstruktur"."RP_RadwegWanderwegFlaeche"
-- -----------------------------------------------------
CREATE TABLE "RP_Freiraumstruktur"."RP_RadwegWanderwegFlaeche" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_RP_RadwegWanderwegFlaeche_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "RP_Freiraumstruktur"."RP_RadwegWanderweg" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("RP_Basisobjekte"."RP_Flaechenobjekt");

GRANT SELECT ON TABLE "RP_Freiraumstruktur"."RP_RadwegWanderwegFlaeche" TO xp_gast;
GRANT ALL ON TABLE "RP_Freiraumstruktur"."RP_RadwegWanderwegFlaeche" TO rp_user;
COMMENT ON COLUMN "RP_Freiraumstruktur"."RP_RadwegWanderwegFlaeche"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_RP_RadwegWanderwegFlaeche" BEFORE INSERT OR UPDATE ON "RP_Freiraumstruktur"."RP_RadwegWanderwegFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_RadwegWanderwegFlaeche" AFTER DELETE ON "RP_Freiraumstruktur"."RP_RadwegWanderwegFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "RP_RadwegWanderwegFlaeche_Flaechenobjekt" BEFORE INSERT OR UPDATE ON "RP_Freiraumstruktur"."RP_RadwegWanderwegFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."positionFollowsRHR"();

-- -----------------------------------------------------
-- Table "RP_Freiraumstruktur"."RP_RadwegWanderwegLinie"
-- -----------------------------------------------------
CREATE  TABLE  "RP_Freiraumstruktur"."RP_RadwegWanderwegLinie" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_RP_RadwegWanderwegLinie_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "RP_Freiraumstruktur"."RP_RadwegWanderweg" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("RP_Basisobjekte"."RP_Linienobjekt");

GRANT SELECT ON TABLE "RP_Freiraumstruktur"."RP_RadwegWanderwegLinie" TO xp_gast;
GRANT ALL ON TABLE "RP_Freiraumstruktur"."RP_RadwegWanderwegLinie" TO rp_user;
COMMENT ON COLUMN "RP_Freiraumstruktur"."RP_RadwegWanderwegLinie"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_RP_RadwegWanderwegLinie" BEFORE INSERT OR UPDATE ON "RP_Freiraumstruktur"."RP_RadwegWanderwegLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_RadwegWanderwegLinie" AFTER DELETE ON "RP_Freiraumstruktur"."RP_RadwegWanderwegLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "RP_Freiraumstruktur"."RP_RadwegWanderwegPunkt"
-- -----------------------------------------------------
CREATE TABLE "RP_Freiraumstruktur"."RP_RadwegWanderwegPunkt" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_RP_RadwegWanderwegPunkt_parent"
    FOREIGN KEY ("gid")
    REFERENCES "RP_Freiraumstruktur"."RP_RadwegWanderweg" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("RP_Basisobjekte"."RP_Punktobjekt");

GRANT SELECT ON TABLE "RP_Freiraumstruktur"."RP_RadwegWanderwegPunkt" TO xp_gast;
GRANT ALL ON TABLE "RP_Freiraumstruktur"."RP_RadwegWanderwegPunkt" TO rp_user;
COMMENT ON COLUMN "RP_Freiraumstruktur"."RP_RadwegWanderwegPunkt"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_RP_RadwegWanderwegPunkt" BEFORE INSERT OR UPDATE ON "RP_Freiraumstruktur"."RP_RadwegWanderwegPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_RadwegWanderwegPunkt" AFTER DELETE ON "RP_Freiraumstruktur"."RP_RadwegWanderwegPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

INSERT INTO "RP_Freiraumstruktur"."RP_RadwegWanderwegTypen" ("Code", "Bezeichner") VALUES ('1000', 'Wanderweg');
INSERT INTO "RP_Freiraumstruktur"."RP_RadwegWanderwegTypen" ("Code", "Bezeichner") VALUES ('1001', 'Fernwanderweg');
INSERT INTO "RP_Freiraumstruktur"."RP_RadwegWanderwegTypen" ("Code", "Bezeichner") VALUES ('2000', 'Radwandern');
INSERT INTO "RP_Freiraumstruktur"."RP_RadwegWanderwegTypen" ("Code", "Bezeichner") VALUES ('2001', 'Fernradweg');
INSERT INTO "RP_Freiraumstruktur"."RP_RadwegWanderwegTypen" ("Code", "Bezeichner") VALUES ('3000', 'Reiten');
INSERT INTO "RP_Freiraumstruktur"."RP_RadwegWanderwegTypen" ("Code", "Bezeichner") VALUES ('4000', 'Wasserwandern');
INSERT INTO "RP_Freiraumstruktur"."RP_RadwegWanderwegTypen" ("Code", "Bezeichner") VALUES ('9999', 'SonstigerWanderweg');

-- RP_Rohstoffsicherung -> RP_Rohstoff
ALTER TABLE "RP_Freiraumstruktur"."RP_Rohstoff" RENAME TO "RP_RohstoffTypen";
ALTER TABLE "RP_Freiraumstruktur"."RP_Rohstoffsicherung" RENAME TO "RP_Rohstoff";
ALTER TABLE "RP_Freiraumstruktur"."RP_Rohstoff" DROP CONSTRAINT "fk_RP_Rohstoffsicherung_parent";
INSERT INTO "RP_Freiraumstruktur"."RP_Freiraum" ("gid","istAusgleichsgebiet") SELECT "gid","istAusgleichsgebiet" FROM "RP_Freiraumstruktur"."RP_Rohstoff";
ALTER TABLE "RP_Freiraumstruktur"."RP_Rohstoff" ADD CONSTRAINT "fk_RP_Rohstoff_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "RP_Freiraumstruktur"."RP_Freiraum" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE;
ALTER TABLE "RP_Freiraumstruktur"."RP_Rohstoff" DROP COLUMN "istAusgleichsgebiet";

-- -----------------------------------------------------
-- Table "RP_Freiraumstruktur"."RP_Rohstoff_typ"
-- -----------------------------------------------------
CREATE TABLE "RP_Freiraumstruktur"."RP_Rohstoff_typ" (
  "RP_Rohstoff_gid" BIGINT NOT NULL,
  "typ" INTEGER NOT NULL,
  PRIMARY KEY ("RP_Rohstoff_gid", "typ"),
  CONSTRAINT "fk_RP_Rohstoff_typ1"
    FOREIGN KEY ("RP_Rohstoff_gid")
    REFERENCES "RP_Freiraumstruktur"."RP_Rohstoff" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_RP_Rohstoff_typ2"
    FOREIGN KEY ("typ")
    REFERENCES "RP_Freiraumstruktur"."RP_RohstoffTypen" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
COMMENT ON TABLE "RP_Freiraumstruktur"."RP_Rohstoff_typ" IS 'Abgebauter Rohstoff.';
GRANT SELECT ON TABLE "RP_Freiraumstruktur"."RP_Rohstoff_typ" TO xp_gast;
GRANT ALL ON TABLE "RP_Freiraumstruktur"."RP_Rohstoff_typ" TO rp_user;
INSERT INTO "RP_Freiraumstruktur"."RP_Rohstoff_typ" ("RP_Rohstoff_gid","typ") SELECT gid,"abbaugut" FROM "RP_Freiraumstruktur"."RP_Rohstoff" WHERE "abbaugut" IS NOT NULL;
ALTER TABLE "RP_Freiraumstruktur"."RP_Rohstoff" DROP COLUMN "abbaugut";

-- -----------------------------------------------------
-- Table "RP_Freiraumstruktur"."RP_BergbauFolgenutzung"
-- -----------------------------------------------------
CREATE TABLE "RP_Freiraumstruktur"."RP_BergbauFolgenutzung" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Code") );
GRANT SELECT ON TABLE "RP_Freiraumstruktur"."RP_BergbauFolgenutzung" TO xp_gast;

-- -----------------------------------------------------
-- Table "RP_Freiraumstruktur"."RP_Rohstoff_folgenutzung"
-- -----------------------------------------------------
CREATE TABLE "RP_Freiraumstruktur"."RP_Rohstoff_folgenutzung" (
  "RP_Rohstoff_gid" BIGINT NOT NULL,
  "folgenutzung" INTEGER NOT NULL,
  PRIMARY KEY ("RP_Rohstoff_gid", "folgenutzung"),
  CONSTRAINT "fk_RP_Rohstoff_folgenutzung1"
    FOREIGN KEY ("RP_Rohstoff_gid")
    REFERENCES "RP_Freiraumstruktur"."RP_Rohstoff" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_RP_Rohstoff_folgenutzung2"
    FOREIGN KEY ("folgenutzung")
    REFERENCES "RP_Freiraumstruktur"."RP_BergbauFolgenutzung" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
COMMENT ON TABLE "RP_Freiraumstruktur"."RP_Rohstoff_folgenutzung" IS 'Klassifikation von Folgenutzungen bestimmter bergbaulicher Maßnahmen.';
GRANT SELECT ON TABLE "RP_Freiraumstruktur"."RP_Rohstoff_folgenutzung" TO xp_gast;
GRANT ALL ON TABLE "RP_Freiraumstruktur"."RP_Rohstoff_folgenutzung" TO rp_user;
INSERT INTO "RP_Freiraumstruktur"."RP_BergbauFolgenutzung" ("Code", "Bezeichner") VALUES ('1000', 'Landwirtschaft');
INSERT INTO "RP_Freiraumstruktur"."RP_BergbauFolgenutzung" ("Code", "Bezeichner") VALUES ('2000', 'Forstwirtschaft');
INSERT INTO "RP_Freiraumstruktur"."RP_BergbauFolgenutzung" ("Code", "Bezeichner") VALUES ('3000', 'Gruenlandbewirtschaftung');
INSERT INTO "RP_Freiraumstruktur"."RP_BergbauFolgenutzung" ("Code", "Bezeichner") VALUES ('4000', 'NaturLandschaft');
INSERT INTO "RP_Freiraumstruktur"."RP_BergbauFolgenutzung" ("Code", "Bezeichner") VALUES ('5000', 'Naturschutz');
INSERT INTO "RP_Freiraumstruktur"."RP_BergbauFolgenutzung" ("Code", "Bezeichner") VALUES ('6000', 'Erholung');
INSERT INTO "RP_Freiraumstruktur"."RP_BergbauFolgenutzung" ("Code", "Bezeichner") VALUES ('7000', 'Gewaesser');
INSERT INTO "RP_Freiraumstruktur"."RP_BergbauFolgenutzung" ("Code", "Bezeichner") VALUES ('8000', 'Verkehr');
INSERT INTO "RP_Freiraumstruktur"."RP_BergbauFolgenutzung" ("Code", "Bezeichner") VALUES ('9000', 'Altbergbau');
INSERT INTO "RP_Freiraumstruktur"."RP_BergbauFolgenutzung" ("Code", "Bezeichner") VALUES ('9999', 'SonstigeNutzung');
ALTER TABLE "RP_Freiraumstruktur"."RP_Rohstoff" ADD COLUMN "folgenutzungText" TEXT;
COMMENT ON COLUMN "RP_Freiraumstruktur"."RP_Rohstoff"."folgenutzungText" IS 'Textliche Festlegungen und Spezifizierungen zur Folgenutzung einer Bergbauplanung.';

-- -----------------------------------------------------
-- Table "RP_Basisobjekte"."RP_Zeitstufen"
-- -----------------------------------------------------
CREATE TABLE "RP_Basisobjekte"."RP_Zeitstufen" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Code") );
GRANT SELECT ON TABLE "RP_Basisobjekte"."RP_Zeitstufen" TO xp_gast;
ALTER TABLE "RP_Freiraumstruktur"."RP_Rohstoff" ADD COLUMN "zeitstufe" INTEGER;
COMMENT ON COLUMN "RP_Freiraumstruktur"."RP_Rohstoff"."zeitstufe" IS 'Zeitstufe des Rohstoffabbaus.';
ALTER TABLE "RP_Freiraumstruktur"."RP_Rohstoff" ADD CONSTRAINT "fk_RP_Rohstoff_zeitstufe"
    FOREIGN KEY ("zeitstufe")
    REFERENCES "RP_Basisobjekte"."RP_Zeitstufen" ("Code")
    ON DELETE RESTRICT
    ON UPDATE CASCADE;
INSERT INTO "RP_Basisobjekte"."RP_Zeitstufen" ("Code", "Bezeichner") VALUES ('1000', 'Zeitstufe1');
INSERT INTO "RP_Basisobjekte"."RP_Zeitstufen" ("Code", "Bezeichner") VALUES ('2000', 'Zeitstufe2');
ALTER TABLE "RP_Freiraumstruktur"."RP_Rohstoff" ADD COLUMN "zeitstufeText" VARCHAR(255);
COMMENT ON COLUMN "RP_Freiraumstruktur"."RP_Rohstoff"."zeitstufeText" IS 'Textliche Spezifizierung einer Rohstoffzeitstufe, zum Beispiel kurzfristiger Abbau (Zeitstufe I) und langfristige Sicherung für mindestens 25-30 Jahre (Zeitstufe II).';

-- -----------------------------------------------------
-- Table "RP_Freiraumstruktur"."RP_BodenschatzTiefen"
-- -----------------------------------------------------
CREATE TABLE "RP_Freiraumstruktur"."RP_BodenschatzTiefen" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Code") );
GRANT SELECT ON TABLE "RP_Freiraumstruktur"."RP_BodenschatzTiefen" TO xp_gast;
ALTER TABLE "RP_Freiraumstruktur"."RP_Rohstoff" ADD COLUMN "tiefe" INTEGER;
COMMENT ON COLUMN "RP_Freiraumstruktur"."RP_Rohstoff"."tiefe" IS 'Tiefe eines Rohstoffes';
ALTER TABLE "RP_Freiraumstruktur"."RP_Rohstoff" ADD CONSTRAINT "fk_RP_Rohstoff_tiefe"
    FOREIGN KEY ("tiefe")
    REFERENCES "RP_Freiraumstruktur"."RP_BodenschatzTiefen" ("Code")
    ON DELETE RESTRICT
    ON UPDATE CASCADE;
INSERT INTO "RP_Freiraumstruktur"."RP_BodenschatzTiefen" ("Code", "Bezeichner") VALUES ('1000', 'Oberflaechennah');
INSERT INTO "RP_Freiraumstruktur"."RP_BodenschatzTiefen" ("Code", "Bezeichner") VALUES ('2000', 'Tiefliegend');

-- -----------------------------------------------------
-- Table "RP_Freiraumstruktur"."RP_BergbauplanungTypen"
-- -----------------------------------------------------
CREATE TABLE "RP_Freiraumstruktur"."RP_BergbauplanungTypen" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Code") );
GRANT SELECT ON TABLE "RP_Freiraumstruktur"."RP_BergbauplanungTypen" TO xp_gast;

-- -----------------------------------------------------
-- Table "RP_Freiraumstruktur"."RP_Rohstoff_bergbauplanungTyp"
-- -----------------------------------------------------
CREATE TABLE "RP_Freiraumstruktur"."RP_Rohstoff_bergbauplanungTyp" (
  "RP_Rohstoff_gid" BIGINT NOT NULL,
  "bergbauplanungTyp" INTEGER NOT NULL,
  PRIMARY KEY ("RP_Rohstoff_gid", "bergbauplanungTyp"),
  CONSTRAINT "fk_RP_Rohstoff_bergbauplanungTyp1"
    FOREIGN KEY ("RP_Rohstoff_gid")
    REFERENCES "RP_Freiraumstruktur"."RP_Rohstoff" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_RP_Rohstoff_bergbauplanungTyp2"
    FOREIGN KEY ("bergbauplanungTyp")
    REFERENCES "RP_Freiraumstruktur"."RP_BergbauplanungTypen" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
COMMENT ON TABLE "RP_Freiraumstruktur"."RP_Rohstoff_bergbauplanungTyp" IS 'Klassifikation von Bergbauplanungstypen.';
GRANT SELECT ON TABLE "RP_Freiraumstruktur"."RP_Rohstoff_bergbauplanungTyp" TO xp_gast;
GRANT ALL ON TABLE "RP_Freiraumstruktur"."RP_Rohstoff_bergbauplanungTyp" TO rp_user;
INSERT INTO "RP_Freiraumstruktur"."RP_BergbauplanungTypen" ("Code", "Bezeichner") VALUES ('1000', 'Lagerstaette');
INSERT INTO "RP_Freiraumstruktur"."RP_BergbauplanungTypen" ("Code", "Bezeichner") VALUES ('1100', 'Sicherung');
INSERT INTO "RP_Freiraumstruktur"."RP_BergbauplanungTypen" ("Code", "Bezeichner") VALUES ('1200', 'Gewinnung');
INSERT INTO "RP_Freiraumstruktur"."RP_BergbauplanungTypen" ("Code", "Bezeichner") VALUES ('1300', 'Abbaubereich');
INSERT INTO "RP_Freiraumstruktur"."RP_BergbauplanungTypen" ("Code", "Bezeichner") VALUES ('1400', 'Sicherheitszone');
INSERT INTO "RP_Freiraumstruktur"."RP_BergbauplanungTypen" ("Code", "Bezeichner") VALUES ('1500', 'AnlageEinrichtungBergbau');
INSERT INTO "RP_Freiraumstruktur"."RP_BergbauplanungTypen" ("Code", "Bezeichner") VALUES ('1600', 'Halde');
INSERT INTO "RP_Freiraumstruktur"."RP_BergbauplanungTypen" ("Code", "Bezeichner") VALUES ('1700', 'Sanierungsflaeche');
INSERT INTO "RP_Freiraumstruktur"."RP_BergbauplanungTypen" ("Code", "Bezeichner") VALUES ('1800', 'AnsiedlungUmsiedlung');
INSERT INTO "RP_Freiraumstruktur"."RP_BergbauplanungTypen" ("Code", "Bezeichner") VALUES ('1900', 'Bergbaufolgelandschaft');
INSERT INTO "RP_Freiraumstruktur"."RP_BergbauplanungTypen" ("Code", "Bezeichner") VALUES ('9999', 'SonstigeBergbauplanung');

ALTER TABLE "RP_Freiraumstruktur"."RP_Rohstoff" ADD COLUMN "istAufschuettungAblagerung" BOOLEAN;
COMMENT ON COLUMN "RP_Freiraumstruktur"."RP_Rohstoff"."istAufschuettungAblagerung" IS '';

ALTER TABLE "RP_Freiraumstruktur"."RP_RohstoffsicherungFlaeche" RENAME CONSTRAINT "fk_RP_RohstoffsicherungFlaeche_parent" TO "fk_RP_RohstoffFlaeche_parent";
ALTER TABLE "RP_Freiraumstruktur"."RP_RohstoffsicherungFlaeche" RENAME TO "RP_RohstoffFlaeche";
ALTER TABLE "RP_Freiraumstruktur"."RP_RohstoffsicherungLinie" RENAME CONSTRAINT "fk_RP_RohstoffsicherungLinie_parent" TO "fk_RP_RohstoffLinie_parent";
ALTER TABLE "RP_Freiraumstruktur"."RP_RohstoffsicherungLinie" RENAME TO "RP_RohstoffLinie";
ALTER TABLE "RP_Freiraumstruktur"."RP_RohstoffsicherungPunkt" RENAME CONSTRAINT "fk_RP_RohstoffsicherungPunkt_parent" TO "fk_RP_RohstoffPunkt_parent";
ALTER TABLE "RP_Freiraumstruktur"."RP_RohstoffsicherungPunkt" RENAME TO "RP_RohstoffPunkt";

-- Anpassen der Enumeration
UPDATE "RP_Freiraumstruktur"."RP_RohstoffTypen" SET "Code" = 13900 WHERE "Code" = 5700; -- Freimachen
UPDATE "RP_Freiraumstruktur"."RP_RohstoffTypen" SET "Code" = 15100 WHERE "Code" = 5800; -- für
UPDATE "RP_Freiraumstruktur"."RP_RohstoffTypen" SET "Code" = 15300 WHERE "Code" = 5900; -- Neube-
UPDATE "RP_Freiraumstruktur"."RP_RohstoffTypen" SET "Code" = 14100 WHERE "Code" = 6000; -- legung
UPDATE "RP_Freiraumstruktur"."RP_RohstoffTypen" SET "Code" = "Code" + 1400 WHERE "Code" IN (5000,5100,5200,5300,5400,5500,5600);
UPDATE "RP_Freiraumstruktur"."RP_RohstoffTypen" SET "Code" = "Code" + 1300 WHERE "Code" IN (4600,4700,4800,4900);
UPDATE "RP_Freiraumstruktur"."RP_RohstoffTypen" SET "Code" = "Code" + 1100 WHERE "Code" IN (4300,4400,4500);
UPDATE "RP_Freiraumstruktur"."RP_RohstoffTypen" SET "Code" = "Code" + 1000 WHERE "Code" IN (4200);
UPDATE "RP_Freiraumstruktur"."RP_RohstoffTypen" SET "Code" = "Code" + 900 WHERE "Code" IN (4100);
UPDATE "RP_Freiraumstruktur"."RP_RohstoffTypen" SET "Code" = "Code" + 800 WHERE "Code" IN (3800,3900);
UPDATE "RP_Freiraumstruktur"."RP_RohstoffTypen" SET "Code" = "Code" + 700 WHERE "Code" IN (3300,3500,3600,3700);
UPDATE "RP_Freiraumstruktur"."RP_RohstoffTypen" SET "Code" = "Code" + 400 WHERE "Code" IN (3200,3400);
UPDATE "RP_Freiraumstruktur"."RP_RohstoffTypen" SET "Code" = "Code" + 10300 WHERE "Code" IN (2600,2900,3000,3100); -- damit keine Neubelegung
UPDATE "RP_Freiraumstruktur"."RP_RohstoffTypen" SET "Code" = "Code" + 10200 WHERE "Code" IN (2300,2400,2500,2800); -- eines schon bestehenden Codes
UPDATE "RP_Freiraumstruktur"."RP_RohstoffTypen" SET "Code" = "Code" + 10100 WHERE "Code" IN (1700,1800,1900,2000,2100,2200); -- innerhalb diesr Abfrage erfolgt
UPDATE "RP_Freiraumstruktur"."RP_RohstoffTypen" SET "Code" = "Code" - 10000 WHERE "Code" > 10000; -- endgültige Werte eintragen
-- neue Einträge
INSERT INTO "RP_Freiraumstruktur"."RP_RohstoffTypen" ("Code","Bezeichner") VALUES ('1700', 'Dekostein');
INSERT INTO "RP_Freiraumstruktur"."RP_RohstoffTypen" ("Code", "Bezeichner") VALUES ('2400', 'Festgestein');
INSERT INTO "RP_Freiraumstruktur"."RP_RohstoffTypen" ("Code", "Bezeichner") VALUES ('2800', 'Gneis');
INSERT INTO "RP_Freiraumstruktur"."RP_RohstoffTypen" ("Code", "Bezeichner") VALUES ('3100', 'Hartgestein');
INSERT INTO "RP_Freiraumstruktur"."RP_RohstoffTypen" ("Code", "Bezeichner") VALUES ('3500', 'Kaolin');
INSERT INTO "RP_Freiraumstruktur"."RP_RohstoffTypen" ("Code", "Bezeichner") VALUES ('3700', 'Kies');
INSERT INTO "RP_Freiraumstruktur"."RP_RohstoffTypen" ("Code", "Bezeichner") VALUES ('4500', 'Marmor');
INSERT INTO "RP_Freiraumstruktur"."RP_RohstoffTypen" ("Code", "Bezeichner") VALUES ('4800', 'MikrogranitGranitporphyr');
INSERT INTO "RP_Freiraumstruktur"."RP_RohstoffTypen" ("Code", "Bezeichner") VALUES ('4900', 'Monzonit');
INSERT INTO "RP_Freiraumstruktur"."RP_RohstoffTypen" ("Code", "Bezeichner") VALUES ('5700', 'Rhyolith');
INSERT INTO "RP_Freiraumstruktur"."RP_RohstoffTypen" ("Code", "Bezeichner") VALUES ('5800', 'RhyolithQuarzporphyr');
INSERT INTO "RP_Freiraumstruktur"."RP_RohstoffTypen" ("Code", "Bezeichner") VALUES ('6300', 'SteineundErden');
INSERT INTO "RP_Freiraumstruktur"."RP_RohstoffTypen" ("Code", "Bezeichner") VALUES ('7100', 'Werkstein');

-- RP_SonstigerFreiraumstruktur -> RP_SonstigerFreiraumschutz
ALTER TABLE "RP_Freiraumstruktur"."RP_SonstigerFreiraumstruktur" RENAME TO "RP_SonstigerFreiraumschutz";
ALTER TABLE "RP_Freiraumstruktur"."RP_SonstigerFreiraumschutz" DROP CONSTRAINT "fk_RP_SonstigerFreiraumstruktur_parent";
INSERT INTO "RP_Freiraumstruktur"."RP_Freiraum" ("gid","istAusgleichsgebiet") SELECT "gid","istAusgleichsgebiet" FROM "RP_Freiraumstruktur"."RP_SonstigerFreiraumschutz";
ALTER TABLE "RP_Freiraumstruktur"."RP_SonstigerFreiraumschutz" ADD CONSTRAINT "fk_RP_SonstigerFreiraumschutz_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "RP_Freiraumstruktur"."RP_Freiraum" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE;
ALTER TABLE "RP_Freiraumstruktur"."RP_SonstigerFreiraumschutz" DROP COLUMN "istAusgleichsgebiet";
COMMENT ON TABLE "RP_Freiraumstruktur"."RP_SonstigerFreiraumschutz" IS 'Sonstiger Freiraumschutz. Nicht anderweitig zuzuordnende Freiraumstrukturen.';
ALTER TABLE "RP_Freiraumstruktur"."RP_SonstigerFreiraumstrukturFlaeche" RENAME CONSTRAINT "fk_RP_SonstigerFreiraumstrukturFlaeche_parent" TO "fk_RP_SonstigerFreiraumschutzFlaeche_parent";
ALTER TABLE "RP_Freiraumstruktur"."RP_SonstigerFreiraumstrukturFlaeche" RENAME TO "RP_SonstigerFreiraumschutzFlaeche";
ALTER TABLE "RP_Freiraumstruktur"."RP_SonstigerFreiraumstrukturLinie" RENAME CONSTRAINT "fk_RP_SonstigerFreiraumstrukturLinie_parent" TO "fk_RP_SonstigerFreiraumschutzLinie_parent";
ALTER TABLE "RP_Freiraumstruktur"."RP_SonstigerFreiraumstrukturLinie" RENAME TO "RP_SonstigerFreiraumschutzLinie";
ALTER TABLE "RP_Freiraumstruktur"."RP_SonstigerFreiraumstrukturPunkt" RENAME CONSTRAINT "fk_RP_SonstigerFreiraumstrukturPunkt_parent" TO "fk_RP_SonstigerFreiraumschutzPunkt_parent";
ALTER TABLE "RP_Freiraumstruktur"."RP_SonstigerFreiraumstrukturPunkt" RENAME TO "RP_SonstigerFreiraumschutzPunkt";

-- neu Klasse RP_Sportanlage
-- -----------------------------------------------------
-- Table "RP_Freiraumstruktur"."RP_SportanlageTypen"
-- -----------------------------------------------------
CREATE TABLE "RP_Freiraumstruktur"."RP_SportanlageTypen" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Code") );
GRANT SELECT ON TABLE "RP_Freiraumstruktur"."RP_SportanlageTypen" TO xp_gast;

-- -----------------------------------------------------
-- Table "RP_Freiraumstruktur"."RP_Sportanlage"
-- -----------------------------------------------------
CREATE TABLE "RP_Freiraumstruktur"."RP_Sportanlage" (
  "gid" BIGINT NOT NULL ,
  "typ" INTEGER NULL,
  PRIMARY KEY ("gid"),
  CONSTRAINT "fk_RP_Sportanlage_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "RP_Freiraumstruktur"."RP_Freiraum" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_RP_Sportanlage_typ"
    FOREIGN KEY ("typ")
    REFERENCES "RP_Freiraumstruktur"."RP_SportanlageTypen" ("Code")
    ON DELETE RESTRICT
    ON UPDATE CASCADE);

GRANT SELECT ON TABLE "RP_Freiraumstruktur"."RP_Sportanlage" TO xp_gast;
GRANT ALL ON TABLE "RP_Freiraumstruktur"."RP_Sportanlage" TO rp_user;
COMMENT ON TABLE "RP_Freiraumstruktur"."RP_Sportanlage" IS 'Sportanlagen und -bereiche.
Sportanlagen sind ortsfeste Einrichtungen, die zur Sportausübung bestimmt sind. Zur Sportanlage zählen auch Einrichtungen, die mit der Sportanlage in einem engen räumlichen und betrieblichen Zusammenhang stehen (nach BImSchV 18 §1).';
COMMENT ON COLUMN "RP_Freiraumstruktur"."RP_Sportanlage"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN "RP_Freiraumstruktur"."RP_Sportanlage"."typ" IS 'Klassifikation von Sportanlagen.';
CREATE TRIGGER "change_to_RP_Sportanlage" BEFORE INSERT OR UPDATE ON "RP_Freiraumstruktur"."RP_Sportanlage" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_Sportanlage" AFTER DELETE ON "RP_Freiraumstruktur"."RP_Sportanlage" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "RP_Freiraumstruktur"."RP_SportanlageFlaeche"
-- -----------------------------------------------------
CREATE TABLE "RP_Freiraumstruktur"."RP_SportanlageFlaeche" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_RP_SportanlageFlaeche_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "RP_Freiraumstruktur"."RP_Sportanlage" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("RP_Basisobjekte"."RP_Flaechenobjekt");

GRANT SELECT ON TABLE "RP_Freiraumstruktur"."RP_SportanlageFlaeche" TO xp_gast;
GRANT ALL ON TABLE "RP_Freiraumstruktur"."RP_SportanlageFlaeche" TO rp_user;
COMMENT ON COLUMN "RP_Freiraumstruktur"."RP_SportanlageFlaeche"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_RP_SportanlageFlaeche" BEFORE INSERT OR UPDATE ON "RP_Freiraumstruktur"."RP_SportanlageFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_SportanlageFlaeche" AFTER DELETE ON "RP_Freiraumstruktur"."RP_SportanlageFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "RP_SportanlageFlaeche_Flaechenobjekt" BEFORE INSERT OR UPDATE ON "RP_Freiraumstruktur"."RP_SportanlageFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."positionFollowsRHR"();

-- -----------------------------------------------------
-- Table "RP_Freiraumstruktur"."RP_SportanlageLinie"
-- -----------------------------------------------------
CREATE TABLE "RP_Freiraumstruktur"."RP_SportanlageLinie" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_RP_SportanlageLinie_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "RP_Freiraumstruktur"."RP_Sportanlage" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("RP_Basisobjekte"."RP_Linienobjekt");

GRANT SELECT ON TABLE "RP_Freiraumstruktur"."RP_SportanlageLinie" TO xp_gast;
GRANT ALL ON TABLE "RP_Freiraumstruktur"."RP_SportanlageLinie" TO rp_user;
COMMENT ON COLUMN "RP_Freiraumstruktur"."RP_SportanlageLinie"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_RP_SportanlageLinie" BEFORE INSERT OR UPDATE ON "RP_Freiraumstruktur"."RP_SportanlageLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_SportanlageLinie" AFTER DELETE ON "RP_Freiraumstruktur"."RP_SportanlageLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "RP_Freiraumstruktur"."RP_SportanlagePunkt"
-- -----------------------------------------------------
CREATE TABLE "RP_Freiraumstruktur"."RP_SportanlagePunkt" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_RP_SportanlagePunkt_parent"
    FOREIGN KEY ("gid")
    REFERENCES "RP_Freiraumstruktur"."RP_Sportanlage" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("RP_Basisobjekte"."RP_Punktobjekt");

GRANT SELECT ON TABLE "RP_Freiraumstruktur"."RP_SportanlagePunkt" TO xp_gast;
GRANT ALL ON TABLE "RP_Freiraumstruktur"."RP_SportanlagePunkt" TO rp_user;
COMMENT ON COLUMN "RP_Freiraumstruktur"."RP_SportanlagePunkt"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_RP_SportanlagePunkt" BEFORE INSERT OR UPDATE ON "RP_Freiraumstruktur"."RP_SportanlagePunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_SportanlagePunkt" AFTER DELETE ON "RP_Freiraumstruktur"."RP_SportanlagePunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

INSERT INTO "RP_Freiraumstruktur"."RP_SportanlageTypen" ("Code", "Bezeichner") VALUES ('1000', 'Sportanlage');
INSERT INTO "RP_Freiraumstruktur"."RP_SportanlageTypen" ("Code", "Bezeichner") VALUES ('2000', 'Wassersport');
INSERT INTO "RP_Freiraumstruktur"."RP_SportanlageTypen" ("Code", "Bezeichner") VALUES ('3000', 'Motorsport');
INSERT INTO "RP_Freiraumstruktur"."RP_SportanlageTypen" ("Code", "Bezeichner") VALUES ('4000', 'Flugsport');
INSERT INTO "RP_Freiraumstruktur"."RP_SportanlageTypen" ("Code", "Bezeichner") VALUES ('5000', 'Reitsport');
INSERT INTO "RP_Freiraumstruktur"."RP_SportanlageTypen" ("Code", "Bezeichner") VALUES ('6000', 'Golfsport');
INSERT INTO "RP_Freiraumstruktur"."RP_SportanlageTypen" ("Code", "Bezeichner") VALUES ('7000', 'Sportzentrum');
INSERT INTO "RP_Freiraumstruktur"."RP_SportanlageTypen" ("Code", "Bezeichner") VALUES ('9999', 'SonstigeSportanlage');

-- RP_Wasserschutz
-- -----------------------------------------------------
-- Table "RP_Freiraumstruktur"."RP_WasserschutzTypen"
-- -----------------------------------------------------
CREATE TABLE "RP_Freiraumstruktur"."RP_WasserschutzTypen" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Code") );
GRANT SELECT ON TABLE "RP_Freiraumstruktur"."RP_WasserschutzTypen" TO xp_gast;
INSERT INTO "RP_Freiraumstruktur"."RP_WasserschutzTypen" ("Code", "Bezeichner") VALUES ('1000', 'Wasserschutzgebiet');
INSERT INTO "RP_Freiraumstruktur"."RP_WasserschutzTypen" ("Code", "Bezeichner") VALUES ('2000', 'Grundwasserschutz');
INSERT INTO "RP_Freiraumstruktur"."RP_WasserschutzTypen" ("Code", "Bezeichner") VALUES ('2001', 'Grundwasservorkommen');
INSERT INTO "RP_Freiraumstruktur"."RP_WasserschutzTypen" ("Code", "Bezeichner") VALUES ('2002', 'Gewaesserschutz');
INSERT INTO "RP_Freiraumstruktur"."RP_WasserschutzTypen" ("Code", "Bezeichner") VALUES ('3000', 'Trinkwasserschutz');
INSERT INTO "RP_Freiraumstruktur"."RP_WasserschutzTypen" ("Code", "Bezeichner") VALUES ('4000', 'Trinkwassergewinnung');
INSERT INTO "RP_Freiraumstruktur"."RP_WasserschutzTypen" ("Code", "Bezeichner") VALUES ('5000', 'Oberflaechenwasserschutz');
INSERT INTO "RP_Freiraumstruktur"."RP_WasserschutzTypen" ("Code", "Bezeichner") VALUES ('6000', 'Heilquelle');
INSERT INTO "RP_Freiraumstruktur"."RP_WasserschutzTypen" ("Code", "Bezeichner") VALUES ('7000', 'Wasserversorgung');
INSERT INTO "RP_Freiraumstruktur"."RP_WasserschutzTypen" ("Code", "Bezeichner") VALUES ('9999', 'SonstigerWasserschutz');

ALTER TABLE "RP_Freiraumstruktur"."RP_Wasserschutz" DROP CONSTRAINT "fk_RP_Wasserschutz_parent";
INSERT INTO "RP_Freiraumstruktur"."RP_Freiraum" ("gid","istAusgleichsgebiet") SELECT "gid","istAusgleichsgebiet" FROM "RP_Freiraumstruktur"."RP_Wasserschutz";
ALTER TABLE "RP_Freiraumstruktur"."RP_Wasserschutz" ADD CONSTRAINT "fk_RP_Wasserschutz_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "RP_Freiraumstruktur"."RP_Freiraum" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE;
ALTER TABLE "RP_Freiraumstruktur"."RP_Wasserschutz" DROP COLUMN "istAusgleichsgebiet";
ALTER TABLE "RP_Freiraumstruktur"."RP_Wasserschutz" ADD COLUMN "typ" INTEGER;
ALTER TABLE "RP_Freiraumstruktur"."RP_Wasserschutz" ADD CONSTRAINT "fk_RP_Wasserschutz_typ"
    FOREIGN KEY ("typ")
    REFERENCES "RP_Freiraumstruktur"."RP_WasserschutzTypen" ("Code")
    ON DELETE RESTRICT
    ON UPDATE CASCADE;
COMMENT ON TABLE "RP_Freiraumstruktur"."RP_Wasserschutz" IS 'Grund-, Trink- und Oberflächenwasserschutz.';
COMMENT ON COLUMN "RP_Freiraumstruktur"."RP_Wasserschutz"."typ" IS 'Klassifikation des Wasserschutztyps.';

-- jetzt Trigger definieren
CREATE TRIGGER "change_to_RP_Freiraum" BEFORE INSERT OR UPDATE ON "RP_Freiraumstruktur"."RP_Freiraum" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_Freiraum" AFTER DELETE ON "RP_Freiraumstruktur"."RP_Freiraum" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- ###########################################
-- Überarbeitung RP_KernmodellInfrastruktur
ALTER SCHEMA "RP_KernmodellInfrastruktur" RENAME TO "RP_Infrastruktur";

-- RP_Energieversorgung
-- Anpassen der Enumeration
UPDATE "RP_Infrastruktur"."RP_EnergieversorgungTypen" SET "Code" = 1001 WHERE "Code" = 1000;
UPDATE "RP_Infrastruktur"."RP_EnergieversorgungTypen" SET "Bezeichner" = 'Energiespeicherung' WHERE "Code" = 4000;
-- neue Einträge
INSERT INTO "RP_Infrastruktur"."RP_EnergieversorgungTypen" ("Code", "Bezeichner") VALUES ('1000', 'Leitungstrasse');
INSERT INTO "RP_Infrastruktur"."RP_EnergieversorgungTypen" ("Code", "Bezeichner") VALUES ('1002', 'KabeltrasseNetzanbindung');
INSERT INTO "RP_Infrastruktur"."RP_EnergieversorgungTypen" ("Code", "Bezeichner") VALUES ('2001', 'Uebergabestation');
INSERT INTO "RP_Infrastruktur"."RP_EnergieversorgungTypen" ("Code", "Bezeichner") VALUES ('3001', 'Grosskraftwerk');
INSERT INTO "RP_Infrastruktur"."RP_EnergieversorgungTypen" ("Code", "Bezeichner") VALUES ('3002', 'Energiegewinnung');
INSERT INTO "RP_Infrastruktur"."RP_EnergieversorgungTypen" ("Code", "Bezeichner") VALUES ('4001', 'VerstetigungSpeicherung');
INSERT INTO "RP_Infrastruktur"."RP_EnergieversorgungTypen" ("Code", "Bezeichner") VALUES ('4002', 'Untergrundspeicher');
INSERT INTO "RP_Infrastruktur"."RP_EnergieversorgungTypen" ("Code", "Bezeichner") VALUES ('6000', 'Raffinerie');
INSERT INTO "RP_Infrastruktur"."RP_EnergieversorgungTypen" ("Code", "Bezeichner") VALUES ('7000', 'Leitungsabbau');

-- -----------------------------------------------------
-- Table "RP_Infrastruktur"."RP_Energieversorgung_typ"
-- -----------------------------------------------------
CREATE TABLE "RP_Infrastruktur"."RP_Energieversorgung_typ" (
  "RP_Energieversorgung_gid" BIGINT NOT NULL,
  "typ" INTEGER NOT NULL,
  PRIMARY KEY ("RP_Energieversorgung_gid", "typ"),
  CONSTRAINT "fk_RP_Energieversorgung_typ1"
    FOREIGN KEY ("RP_Energieversorgung_gid")
    REFERENCES "RP_Infrastruktur"."RP_Energieversorgung" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_RP_Energieversorgung_typ2"
    FOREIGN KEY ("typ")
    REFERENCES "RP_Infrastruktur"."RP_EnergieversorgungTypen" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
COMMENT ON TABLE "RP_Infrastruktur"."RP_Energieversorgung_typ" IS 'Klassifikation von Energieversorgungs-Einrichtungen.';
GRANT SELECT ON TABLE "RP_Infrastruktur"."RP_Energieversorgung_typ" TO xp_gast;
GRANT ALL ON TABLE "RP_Infrastruktur"."RP_Energieversorgung_typ" TO rp_user;
INSERT INTO "RP_Infrastruktur"."RP_Energieversorgung_typ" ("RP_Energieversorgung_gid","typ") SELECT gid,"typ" FROM "RP_Infrastruktur"."RP_Energieversorgung" WHERE "typ" IS NOT NULL;
ALTER TABLE "RP_Infrastruktur"."RP_Energieversorgung" DROP COLUMN "typ";

-- -----------------------------------------------------
-- Table "RP_Infrastruktur"."RP_PrimaerenergieTypen"
-- -----------------------------------------------------
CREATE TABLE "RP_Infrastruktur"."RP_PrimaerenergieTypen" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Code") );
GRANT SELECT ON TABLE "RP_Infrastruktur"."RP_PrimaerenergieTypen" TO xp_gast;

INSERT INTO "RP_Infrastruktur"."RP_PrimaerenergieTypen" ("Code", "Bezeichner") VALUES ('1000', 'Erdoel');
INSERT INTO "RP_Infrastruktur"."RP_PrimaerenergieTypen" ("Code", "Bezeichner") VALUES ('2000', 'Gas');
INSERT INTO "RP_Infrastruktur"."RP_PrimaerenergieTypen" ("Code", "Bezeichner") VALUES ('2001', 'Ferngas');
INSERT INTO "RP_Infrastruktur"."RP_PrimaerenergieTypen" ("Code", "Bezeichner") VALUES ('3000', 'Fernwaerme');
INSERT INTO "RP_Infrastruktur"."RP_PrimaerenergieTypen" ("Code", "Bezeichner") VALUES ('4000', 'Kraftstoff');
INSERT INTO "RP_Infrastruktur"."RP_PrimaerenergieTypen" ("Code", "Bezeichner") VALUES ('5000', 'Kohle');
INSERT INTO "RP_Infrastruktur"."RP_PrimaerenergieTypen" ("Code", "Bezeichner") VALUES ('6000', 'Wasser');
INSERT INTO "RP_Infrastruktur"."RP_PrimaerenergieTypen" ("Code", "Bezeichner") VALUES ('7000', 'Kernenergie');
INSERT INTO "RP_Infrastruktur"."RP_PrimaerenergieTypen" ("Code", "Bezeichner") VALUES ('8000', 'Reststoffverwertung');
INSERT INTO "RP_Infrastruktur"."RP_PrimaerenergieTypen" ("Code", "Bezeichner") VALUES ('9000', 'ErneuerbareEnergie');
INSERT INTO "RP_Infrastruktur"."RP_PrimaerenergieTypen" ("Code", "Bezeichner") VALUES ('9001', 'Windenergie');
INSERT INTO "RP_Infrastruktur"."RP_PrimaerenergieTypen" ("Code", "Bezeichner") VALUES ('9999', 'SonstigePrimaerenergie');

-- -----------------------------------------------------
-- Table "RP_Infrastruktur"."RP_Energieversorgung_primaerenergieTyp"
-- -----------------------------------------------------
CREATE TABLE "RP_Infrastruktur"."RP_Energieversorgung_primaerenergieTyp" (
  "RP_Energieversorgung_gid" BIGINT NOT NULL,
  "primaerenergieTyp" INTEGER NOT NULL,
  PRIMARY KEY ("RP_Energieversorgung_gid", "primaerenergieTyp"),
  CONSTRAINT "fk_RP_Energieversorgung_primaerenergieTyp1"
    FOREIGN KEY ("RP_Energieversorgung_gid")
    REFERENCES "RP_Infrastruktur"."RP_Energieversorgung" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_RP_Energieversorgung_primaerenergieTyp2"
    FOREIGN KEY ("primaerenergieTyp")
    REFERENCES "RP_Infrastruktur"."RP_PrimaerenergieTypen" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
COMMENT ON TABLE "RP_Infrastruktur"."RP_Energieversorgung_primaerenergieTyp" IS 'Klassifikation von der mit der Infrastruktur in Beziehung stehenden Primärenergie.';
GRANT SELECT ON TABLE "RP_Infrastruktur"."RP_Energieversorgung_primaerenergieTyp" TO xp_gast;
GRANT ALL ON TABLE "RP_Infrastruktur"."RP_Energieversorgung_primaerenergieTyp" TO rp_user;

-- -----------------------------------------------------
-- Table "RP_Infrastruktur"."RP_SpannungTypen"
-- -----------------------------------------------------
CREATE TABLE "RP_Infrastruktur"."RP_SpannungTypen" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Code") );
GRANT SELECT ON TABLE "RP_Infrastruktur"."RP_SpannungTypen" TO xp_gast;

INSERT INTO "RP_Infrastruktur"."RP_SpannungTypen" ("Code", "Bezeichner") VALUES ('1000', '110KV');
INSERT INTO "RP_Infrastruktur"."RP_SpannungTypen" ("Code", "Bezeichner") VALUES ('2000', '220KV');
INSERT INTO "RP_Infrastruktur"."RP_SpannungTypen" ("Code", "Bezeichner") VALUES ('3000', '330KV');
INSERT INTO "RP_Infrastruktur"."RP_SpannungTypen" ("Code", "Bezeichner") VALUES ('4000', '380KV');
ALTER TABLE "RP_Infrastruktur"."RP_Energieversorgung" ADD COLUMN "spannung" INTEGER;
ALTER TABLE "RP_Infrastruktur"."RP_Energieversorgung" ADD CONSTRAINT "fk_RP_Energieversorgung_spannung"
    FOREIGN KEY ("spannung")
    REFERENCES "RP_Infrastruktur"."RP_SpannungTypen" ("Code")
    ON DELETE RESTRICT
    ON UPDATE CASCADE;
COMMENT ON COLUMN "RP_Infrastruktur"."RP_Energieversorgung"."spannung" IS 'Klassifikation von Spannungen.';


-- RP_Entsorgung
-- -----------------------------------------------------
-- Table "RP_Infrastruktur"."RP_AbfallentsorgungTypen"
-- -----------------------------------------------------
CREATE TABLE "RP_Infrastruktur"."RP_AbfallentsorgungTypen" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Code") );
GRANT SELECT ON TABLE "RP_Infrastruktur"."RP_AbfallentsorgungTypen" TO xp_gast;

INSERT INTO "RP_Infrastruktur"."RP_AbfallentsorgungTypen" ("Code", "Bezeichner") VALUES ('1000', 'BeseitigungEntsorgung');
INSERT INTO "RP_Infrastruktur"."RP_AbfallentsorgungTypen" ("Code", "Bezeichner") VALUES ('1100', 'Abfallbeseitigungsanlage');
INSERT INTO "RP_Infrastruktur"."RP_AbfallentsorgungTypen" ("Code", "Bezeichner") VALUES ('1101', 'ZentraleAbfallbeseitigungsanlage');
INSERT INTO "RP_Infrastruktur"."RP_AbfallentsorgungTypen" ("Code", "Bezeichner") VALUES ('1200', 'Deponie');
INSERT INTO "RP_Infrastruktur"."RP_AbfallentsorgungTypen" ("Code", "Bezeichner") VALUES ('1300', 'Untertageeinlagerung');
INSERT INTO "RP_Infrastruktur"."RP_AbfallentsorgungTypen" ("Code", "Bezeichner") VALUES ('1400', 'Behandlung');
INSERT INTO "RP_Infrastruktur"."RP_AbfallentsorgungTypen" ("Code", "Bezeichner") VALUES ('1500', 'Kompostierung');
INSERT INTO "RP_Infrastruktur"."RP_AbfallentsorgungTypen" ("Code", "Bezeichner") VALUES ('1600', 'Verbrennung');
INSERT INTO "RP_Infrastruktur"."RP_AbfallentsorgungTypen" ("Code", "Bezeichner") VALUES ('1700', 'Umladestation');
INSERT INTO "RP_Infrastruktur"."RP_AbfallentsorgungTypen" ("Code", "Bezeichner") VALUES ('1800', 'Standortsicherung');
INSERT INTO "RP_Infrastruktur"."RP_AbfallentsorgungTypen" ("Code", "Bezeichner") VALUES ('9999', 'SonstigeAbfallentsorgung');

-- -----------------------------------------------------
-- Table "RP_Infrastruktur"."RP_Entsorgung_typAE"
-- -----------------------------------------------------
CREATE TABLE "RP_Infrastruktur"."RP_Entsorgung_typAE" (
  "RP_Entsorgung_gid" BIGINT NOT NULL,
  "typAE" INTEGER NOT NULL,
  PRIMARY KEY ("RP_Entsorgung_gid", "typAE"),
  CONSTRAINT "fk_RP_Entsorgung_typAE1"
    FOREIGN KEY ("RP_Entsorgung_gid")
    REFERENCES "RP_Infrastruktur"."RP_Entsorgung" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_RP_Entsorgung_typAE2"
    FOREIGN KEY ("typAE")
    REFERENCES "RP_Infrastruktur"."RP_AbfallentsorgungTypen" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
COMMENT ON TABLE "RP_Infrastruktur"."RP_Entsorgung_typAE" IS 'Klassifikation von Abfallentsorgung-Infrastruktur.';
GRANT SELECT ON TABLE "RP_Infrastruktur"."RP_Entsorgung_typAE" TO xp_gast;
GRANT ALL ON TABLE "RP_Infrastruktur"."RP_Entsorgung_typAE" TO rp_user;

INSERT INTO "RP_Infrastruktur"."RP_Entsorgung_typAE" ("RP_Entsorgung_gid","typAE") SELECT gid, 9999 FROM "RP_Infrastruktur"."RP_Entsorgung" WHERE typ = 1000;

-- -----------------------------------------------------
-- Table "RP_Infrastruktur"."RP_AbfallTypen"
-- -----------------------------------------------------
CREATE TABLE "RP_Infrastruktur"."RP_AbfallTypen" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Code") );
GRANT SELECT ON TABLE "RP_Infrastruktur"."RP_AbfallTypen" TO xp_gast;

INSERT INTO "RP_Infrastruktur"."RP_AbfallTypen" ("Code", "Bezeichner") VALUES ('1000', 'Siedlungsabfall');
INSERT INTO "RP_Infrastruktur"."RP_AbfallTypen" ("Code", "Bezeichner") VALUES ('2000', 'Mineralstoffabfall');
INSERT INTO "RP_Infrastruktur"."RP_AbfallTypen" ("Code", "Bezeichner") VALUES ('3000', 'Industrieabfall');
INSERT INTO "RP_Infrastruktur"."RP_AbfallTypen" ("Code", "Bezeichner") VALUES ('4000', 'Sonderabfall');
INSERT INTO "RP_Infrastruktur"."RP_AbfallTypen" ("Code", "Bezeichner") VALUES ('5000', 'RadioaktiverAbfall');
INSERT INTO "RP_Infrastruktur"."RP_AbfallTypen" ("Code", "Bezeichner") VALUES ('9999', 'SonstigerAbfall');

-- -----------------------------------------------------
-- Table "RP_Infrastruktur"."RP_Entsorgung_abfallTyp"
-- -----------------------------------------------------
CREATE TABLE "RP_Infrastruktur"."RP_Entsorgung_abfallTyp" (
  "RP_Entsorgung_gid" BIGINT NOT NULL,
  "abfallTyp" INTEGER NOT NULL,
  PRIMARY KEY ("RP_Entsorgung_gid", "abfallTyp"),
  CONSTRAINT "fk_RP_Entsorgung_abfallTyp1"
    FOREIGN KEY ("RP_Entsorgung_gid")
    REFERENCES "RP_Infrastruktur"."RP_Entsorgung" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_RP_Entsorgung_abfallTyp2"
    FOREIGN KEY ("abfallTyp")
    REFERENCES "RP_Infrastruktur"."RP_AbfallTypen" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
COMMENT ON TABLE "RP_Infrastruktur"."RP_Entsorgung_abfallTyp" IS 'Klassifikation von mit der Entsorgungsinfrastruktur in Beziehung stehenden Abfalltypen';
GRANT SELECT ON TABLE "RP_Infrastruktur"."RP_Entsorgung_abfallTyp" TO xp_gast;
GRANT ALL ON TABLE "RP_Infrastruktur"."RP_Entsorgung_abfallTyp" TO rp_user;

-- -----------------------------------------------------
-- Table "RP_Infrastruktur"."RP_AbwasserTypen"
-- -----------------------------------------------------
CREATE TABLE "RP_Infrastruktur"."RP_AbwasserTypen" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Code") );
GRANT SELECT ON TABLE "RP_Infrastruktur"."RP_AbwasserTypen" TO xp_gast;

INSERT INTO "RP_Infrastruktur"."RP_AbwasserTypen" ("Code", "Bezeichner") VALUES ('1000', 'Klaeranlage');
INSERT INTO "RP_Infrastruktur"."RP_AbwasserTypen" ("Code", "Bezeichner") VALUES ('1001', 'ZentraleKlaeranlage');
INSERT INTO "RP_Infrastruktur"."RP_AbwasserTypen" ("Code", "Bezeichner") VALUES ('1002', 'Grossklaerwerk');
INSERT INTO "RP_Infrastruktur"."RP_AbwasserTypen" ("Code", "Bezeichner") VALUES ('2000', 'Hauptwasserableitung');
INSERT INTO "RP_Infrastruktur"."RP_AbwasserTypen" ("Code", "Bezeichner") VALUES ('3000', 'Abwasserverwertungsflaeche');
INSERT INTO "RP_Infrastruktur"."RP_AbwasserTypen" ("Code", "Bezeichner") VALUES ('4000', 'Abwasserbehandlungsanlage');
INSERT INTO "RP_Infrastruktur"."RP_AbwasserTypen" ("Code", "Bezeichner") VALUES ('9999', 'SonstigeAbwasserinfrastruktur');

-- -----------------------------------------------------
-- Table "RP_Infrastruktur"."RP_Entsorgung_typAW"
-- -----------------------------------------------------
CREATE TABLE "RP_Infrastruktur"."RP_Entsorgung_typAW" (
  "RP_Entsorgung_gid" BIGINT NOT NULL,
  "typAW" INTEGER NOT NULL,
  PRIMARY KEY ("RP_Entsorgung_gid", "typAW"),
  CONSTRAINT "fk_RP_Entsorgung_typAW1"
    FOREIGN KEY ("RP_Entsorgung_gid")
    REFERENCES "RP_Infrastruktur"."RP_Entsorgung" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_RP_Entsorgung_typAW2"
    FOREIGN KEY ("typAW")
    REFERENCES "RP_Infrastruktur"."RP_AbwasserTypen" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
COMMENT ON TABLE "RP_Infrastruktur"."RP_Entsorgung_typAW" IS 'Klassifikation von Abwasser-Infrastruktur.';
GRANT SELECT ON TABLE "RP_Infrastruktur"."RP_Entsorgung_typAW" TO xp_gast;
GRANT ALL ON TABLE "RP_Infrastruktur"."RP_Entsorgung_typAW" TO rp_user;

INSERT INTO "RP_Infrastruktur"."RP_Entsorgung_typAW" ("RP_Entsorgung_gid","typAW") SELECT gid, 9999 FROM "RP_Infrastruktur"."RP_Entsorgung" WHERE typ = 2000;
ALTER TABLE "RP_Infrastruktur"."RP_Entsorgung" DROP COLUMN "typ";
ALTER TABLE "RP_Infrastruktur"."RP_Entsorgung" ADD COLUMN "istAufschuettungAblagerung" BOOLEAN;

DROP TABLE "RP_Infrastruktur"."RP_EntsorgungTypen";

-- RP_Kommunikation
-- -----------------------------------------------------
-- Table "RP_Infrastruktur"."RP_KommunikationTypen"
-- -----------------------------------------------------
CREATE TABLE "RP_Infrastruktur"."RP_KommunikationTypen" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Code") );
GRANT SELECT ON TABLE "RP_Infrastruktur"."RP_KommunikationTypen" TO xp_gast;

INSERT INTO "RP_Infrastruktur"."RP_KommunikationTypen" ("Code", "Bezeichner") VALUES ('1000', 'Richtfunkstrecke');
INSERT INTO "RP_Infrastruktur"."RP_KommunikationTypen" ("Code", "Bezeichner") VALUES ('2000', 'Fernmeldeanlage');
INSERT INTO "RP_Infrastruktur"."RP_KommunikationTypen" ("Code", "Bezeichner") VALUES ('2001', 'SendeEmpfangsstation');
INSERT INTO "RP_Infrastruktur"."RP_KommunikationTypen" ("Code", "Bezeichner") VALUES ('2002', 'TonFernsehsender');
INSERT INTO "RP_Infrastruktur"."RP_KommunikationTypen" ("Code", "Bezeichner") VALUES ('9999', 'SonstigeKommunikation');

-- -----------------------------------------------------
-- Table "RP_Infrastruktur"."RP_Kommunikation_typ"
-- -----------------------------------------------------
CREATE TABLE "RP_Infrastruktur"."RP_Kommunikation_typ" (
  "RP_Kommunikation_gid" BIGINT NOT NULL,
  "typ" INTEGER NOT NULL,
  PRIMARY KEY ("RP_Kommunikation_gid", "typ"),
  CONSTRAINT "fk_RP_Kommunikation_typ1"
    FOREIGN KEY ("RP_Kommunikation_gid")
    REFERENCES "RP_Infrastruktur"."RP_Kommunikation" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_RP_Kommunikation_typ2"
    FOREIGN KEY ("typ")
    REFERENCES "RP_Infrastruktur"."RP_KommunikationTypen" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
COMMENT ON TABLE "RP_Infrastruktur"."RP_Kommunikation_typ" IS 'KKlassifikation von Kommunikations-Infrastruktur.';
GRANT SELECT ON TABLE "RP_Infrastruktur"."RP_Kommunikation_typ" TO xp_gast;
GRANT ALL ON TABLE "RP_Infrastruktur"."RP_Kommunikation_typ" TO rp_user;

-- RP_Laermschutzbereich -> RP_LaermschutzBauschutz
-- -----------------------------------------------------
-- Table "RP_Infrastruktur"."RP_LaermschutzTypen"
-- -----------------------------------------------------
CREATE TABLE "RP_Infrastruktur"."RP_LaermschutzTypen" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Code") );
GRANT SELECT ON TABLE "RP_Infrastruktur"."RP_LaermschutzTypen" TO xp_gast;

INSERT INTO "RP_Infrastruktur"."RP_LaermschutzTypen" ("Code", "Bezeichner") VALUES ('1000', 'Laermbereich');
INSERT INTO "RP_Infrastruktur"."RP_LaermschutzTypen" ("Code", "Bezeichner") VALUES ('1001', 'Laermschutzbereich');
INSERT INTO "RP_Infrastruktur"."RP_LaermschutzTypen" ("Code", "Bezeichner") VALUES ('2000', 'Siedlungsbeschraenkungsbereich');
INSERT INTO "RP_Infrastruktur"."RP_LaermschutzTypen" ("Code", "Bezeichner") VALUES ('3000', 'ZoneA');
INSERT INTO "RP_Infrastruktur"."RP_LaermschutzTypen" ("Code", "Bezeichner") VALUES ('4000', 'ZoneB');
INSERT INTO "RP_Infrastruktur"."RP_LaermschutzTypen" ("Code", "Bezeichner") VALUES ('5000', 'ZoneC');
INSERT INTO "RP_Infrastruktur"."RP_LaermschutzTypen" ("Code", "Bezeichner") VALUES ('9999', 'SonstigerLaermschutzBauschutz');

ALTER TABLE "RP_Infrastruktur"."RP_Laermschutzbereich" RENAME TO "RP_LaermschutzBauschutz";
ALTER TABLE "RP_Infrastruktur"."RP_LaermschutzBauschutz" RENAME CONSTRAINT "fk_RP_Laermschutzbereich_parent" TO "fk_RP_LaermschutzBauschutz_parent";
ALTER TABLE "RP_Infrastruktur"."RP_LaermschutzBauschutz" ADD COLUMN "typ" INTEGER;
ALTER TABLE "RP_Infrastruktur"."RP_LaermschutzBauschutz" ADD CONSTRAINT "fk_RP_LaermschutzBauschutz_typ"
    FOREIGN KEY ("typ")
    REFERENCES "RP_Infrastruktur"."RP_LaermschutzTypen" ("Code")
    ON DELETE RESTRICT
    ON UPDATE CASCADE;
COMMENT ON TABLE "RP_Infrastruktur"."RP_LaermschutzBauschutz" IS 'Infrastruktur zum Lärmschutz und/oder Bauschutz.';
COMMENT ON COLUMN "RP_Infrastruktur"."RP_LaermschutzBauschutz"."typ" IS 'Klassifikation von Lärmschutztypen.';

ALTER TABLE "RP_Infrastruktur"."RP_LaermschutzbereichFlaeche" RENAME CONSTRAINT "fk_RP_LaermschutzbereichFlaeche_parent" TO "fk_RP_LaermschutzBauschutzFlaeche_parent";
ALTER TABLE "RP_Infrastruktur"."RP_LaermschutzbereichFlaeche" RENAME TO "RP_LaermschutzBauschutzFlaeche";
ALTER TABLE "RP_Infrastruktur"."RP_LaermschutzbereichLinie" RENAME CONSTRAINT "fk_RP_LaermschutzbereichLinie_parent" TO "fk_RP_LaermschutzBauschutzLinie_parent";
ALTER TABLE "RP_Infrastruktur"."RP_LaermschutzbereichLinie" RENAME TO "RP_LaermschutzBauschutzLinie";
ALTER TABLE "RP_Infrastruktur"."RP_LaermschutzbereichPunkt" RENAME CONSTRAINT "fk_RP_LaermschutzbereichPunkt_parent" TO "fk_RP_LaermschutzBauschutzPunkt_parent";
ALTER TABLE "RP_Infrastruktur"."RP_LaermschutzbereichPunkt" RENAME TO "RP_LaermschutzBauschutzPunkt";


-- RP_SozialeInfrastruktur
-- Anpassen der Enumeration
UPDATE "RP_Infrastruktur"."RP_SozialeInfrastrukturTypen" SET "Bezeichner" = 'BildungForschung' WHERE "Code" = 4000;
-- neue Einträge
INSERT INTO "RP_Infrastruktur"."RP_SozialeInfrastrukturTypen" ("Code", "Bezeichner") VALUES ('3001', 'Krankenhaus');
INSERT INTO "RP_Infrastruktur"."RP_SozialeInfrastrukturTypen" ("Code", "Bezeichner") VALUES ('4001', 'Hochschule');
INSERT INTO "RP_Infrastruktur"."RP_SozialeInfrastrukturTypen" ("Code", "Bezeichner") VALUES ('5000', 'Polizei');

-- -----------------------------------------------------
-- Table "RP_Infrastruktur"."RP_SozialeInfrastruktur_typ"
-- -----------------------------------------------------
CREATE TABLE "RP_Infrastruktur"."RP_SozialeInfrastruktur_typ" (
  "RP_SozialeInfrastruktur_gid" BIGINT NOT NULL,
  "typ" INTEGER NOT NULL,
  PRIMARY KEY ("RP_SozialeInfrastruktur_gid", "typ"),
  CONSTRAINT "fk_RP_SozialeInfrastruktur_typ1"
    FOREIGN KEY ("RP_SozialeInfrastruktur_gid")
    REFERENCES "RP_Infrastruktur"."RP_SozialeInfrastruktur" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_RP_SozialeInfrastruktur_typ2"
    FOREIGN KEY ("typ")
    REFERENCES "RP_Infrastruktur"."RP_SozialeInfrastrukturTypen" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
COMMENT ON TABLE "RP_Infrastruktur"."RP_SozialeInfrastruktur_typ" IS 'Klassifikation von Sozialer Infrastruktur.';
GRANT SELECT ON TABLE "RP_Infrastruktur"."RP_SozialeInfrastruktur_typ" TO xp_gast;
GRANT ALL ON TABLE "RP_Infrastruktur"."RP_SozialeInfrastruktur_typ" TO rp_user;
INSERT INTO "RP_Infrastruktur"."RP_SozialeInfrastruktur_typ" ("RP_SozialeInfrastruktur_gid","typ") SELECT gid,"typ" FROM "RP_Infrastruktur"."RP_SozialeInfrastruktur" WHERE "typ" IS NOT NULL;
ALTER TABLE "RP_Infrastruktur"."RP_SozialeInfrastruktur" DROP COLUMN "typ";

-- RP_Wasserwirtschaft
-- Anpassen der Enumeration
UPDATE "RP_Infrastruktur"."RP_WasserwirtschaftTypen" SET "Bezeichner" = 'StaudammDeich' WHERE "Code" = 3000;
UPDATE "RP_Infrastruktur"."RP_WasserwirtschaftTypen" SET "Code" = 5000 WHERE "Code" = 4000;
UPDATE "RP_Infrastruktur"."RP_WasserwirtschaftTypen" SET "Code" = 4000, "Bezeichner" = 'Speicherbecken' WHERE "Code" = 3500;
-- neue Einträge
INSERT INTO "RP_Infrastruktur"."RP_WasserwirtschaftTypen" ("Code", "Bezeichner") VALUES ('6000', 'Talsperre');
INSERT INTO "RP_Infrastruktur"."RP_WasserwirtschaftTypen" ("Code", "Bezeichner") VALUES ('7000', 'PumpwerkSchoepfwerk');

-- -----------------------------------------------------
-- Table "RP_Infrastruktur"."RP_Wasserwirtschaft_typ"
-- -----------------------------------------------------
CREATE TABLE "RP_Infrastruktur"."RP_Wasserwirtschaft_typ" (
  "RP_Wasserwirtschaft_gid" BIGINT NOT NULL,
  "typ" INTEGER NOT NULL,
  PRIMARY KEY ("RP_Wasserwirtschaft_gid", "typ"),
  CONSTRAINT "fk_RP_Wasserwirtschaft_typ1"
    FOREIGN KEY ("RP_Wasserwirtschaft_gid")
    REFERENCES "RP_Infrastruktur"."RP_Wasserwirtschaft" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_RP_Wasserwirtschaft_typ2"
    FOREIGN KEY ("typ")
    REFERENCES "RP_Infrastruktur"."RP_WasserwirtschaftTypen" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
COMMENT ON TABLE "RP_Infrastruktur"."RP_Wasserwirtschaft_typ" IS 'Klassifikation von Anlagen und Einrichtungen der Wasserwirtschaft.';
GRANT SELECT ON TABLE "RP_Infrastruktur"."RP_Wasserwirtschaft_typ" TO xp_gast;
GRANT ALL ON TABLE "RP_Infrastruktur"."RP_Wasserwirtschaft_typ" TO rp_user;
INSERT INTO "RP_Infrastruktur"."RP_Wasserwirtschaft_typ" ("RP_Wasserwirtschaft_gid","typ") SELECT gid,"typ" FROM "RP_Infrastruktur"."RP_Wasserwirtschaft" WHERE "typ" IS NOT NULL;
ALTER TABLE "RP_Infrastruktur"."RP_Wasserwirtschaft" DROP COLUMN "typ";

-- RP_Verkehr mit Aufspaltung
ALTER TABLE "RP_Infrastruktur"."RP_Verkehr" DISABLE TRIGGER "change_to_RP_Verkehr";
ALTER TABLE "RP_Infrastruktur"."RP_Verkehr" DISABLE TRIGGER "delete_RP_Verkehr";
ALTER TABLE "RP_Infrastruktur"."RP_VerkehrFlaeche" DISABLE TRIGGER "delete_RP_VerkehrFlaeche";
ALTER TABLE "RP_Infrastruktur"."RP_VerkehrLinie" DISABLE TRIGGER "delete_RP_VerkehrLinie";
ALTER TABLE "RP_Infrastruktur"."RP_VerkehrPunkt" DISABLE TRIGGER "delete_RP_VerkehrPunkt";

COMMENT ON TABLE "RP_Infrastruktur"."RP_Verkehr" IS 'Enthält allgemeine Verkehrs-Infrastruktur, die auch multiple Typen (etwa Straße und Schiene) beinhalten kann. Die Klasse selbst vererbt an spezialisierte Verkehrsarten, ist aber nicht abstrakt (d.h. sie kann selbst auch verwendet werden).';

-- -----------------------------------------------------
-- Table "RP_Infrastruktur"."RP_Verkehr_allgemeinerTyp"
-- -----------------------------------------------------
CREATE TABLE "RP_Infrastruktur"."RP_Verkehr_allgemeinerTyp" (
  "RP_Verkehr_gid" BIGINT NOT NULL,
  "allgemeinerTyp" INTEGER NOT NULL,
  PRIMARY KEY ("RP_Verkehr_gid", "allgemeinerTyp"),
  CONSTRAINT "fk_RP_Verkehr_allgemeinerTyp1"
    FOREIGN KEY ("RP_Verkehr_gid")
    REFERENCES "RP_Infrastruktur"."RP_Verkehr" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_RP_Verkehr_allgemeinerTyp2"
    FOREIGN KEY ("allgemeinerTyp")
    REFERENCES "RP_Infrastruktur"."RP_VerkehrTypen" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
COMMENT ON TABLE "RP_Infrastruktur"."RP_Verkehr_allgemeinerTyp" IS 'Allgemeine Klassifikation der Verkehrs-Arten.';
GRANT SELECT ON TABLE "RP_Infrastruktur"."RP_Verkehr_allgemeinerTyp" TO xp_gast;
GRANT ALL ON TABLE "RP_Infrastruktur"."RP_Verkehr_allgemeinerTyp" TO rp_user;
INSERT INTO "RP_Infrastruktur"."RP_Verkehr_allgemeinerTyp" ("RP_Verkehr_gid","allgemeinerTyp") SELECT gid,"typ" FROM "RP_Infrastruktur"."RP_Verkehr" WHERE "typ" IS NOT NULL;

-- -----------------------------------------------------
-- Table "RP_Infrastruktur"."RP_VerkehrStatus"
-- -----------------------------------------------------
CREATE TABLE "RP_Infrastruktur"."RP_VerkehrStatus" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Code") );
GRANT SELECT ON TABLE "RP_Infrastruktur"."RP_VerkehrStatus" TO xp_gast;

INSERT INTO "RP_Infrastruktur"."RP_VerkehrStatus" ("Code", "Bezeichner") VALUES ('1000', 'Ausbau');
INSERT INTO "RP_Infrastruktur"."RP_VerkehrStatus" ("Code", "Bezeichner") VALUES ('1001', 'LinienfuehrungOffen');
INSERT INTO "RP_Infrastruktur"."RP_VerkehrStatus" ("Code", "Bezeichner") VALUES ('2000', 'Sicherung');
INSERT INTO "RP_Infrastruktur"."RP_VerkehrStatus" ("Code", "Bezeichner") VALUES ('3000', 'Neubau');
INSERT INTO "RP_Infrastruktur"."RP_VerkehrStatus" ("Code", "Bezeichner") VALUES ('4000', 'ImBau');
INSERT INTO "RP_Infrastruktur"."RP_VerkehrStatus" ("Code", "Bezeichner") VALUES ('5000', 'VorhPlanfestgestLinienbestGrobtrasse');
INSERT INTO "RP_Infrastruktur"."RP_VerkehrStatus" ("Code", "Bezeichner") VALUES ('6000', 'BedarfsplanmassnahmeOhneRaeumlFestlegung');
INSERT INTO "RP_Infrastruktur"."RP_VerkehrStatus" ("Code", "Bezeichner") VALUES ('7000', 'Korridor');
INSERT INTO "RP_Infrastruktur"."RP_VerkehrStatus" ("Code", "Bezeichner") VALUES ('8000', 'Verlegung');
INSERT INTO "RP_Infrastruktur"."RP_VerkehrStatus" ("Code", "Bezeichner") VALUES ('9999', 'SonstigerVerkehrStatus');

-- -----------------------------------------------------
-- Table "RP_Infrastruktur"."RP_Verkehr_status"
-- -----------------------------------------------------
CREATE TABLE "RP_Infrastruktur"."RP_Verkehr_status" (
  "RP_Verkehr_gid" BIGINT NOT NULL,
  "status" INTEGER NOT NULL,
  PRIMARY KEY ("RP_Verkehr_gid", "status"),
  CONSTRAINT "fk_RP_Verkehr_status1"
    FOREIGN KEY ("RP_Verkehr_gid")
    REFERENCES "RP_Infrastruktur"."RP_Verkehr" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_RP_Verkehr_status2"
    FOREIGN KEY ("status")
    REFERENCES "RP_Infrastruktur"."RP_VerkehrStatus" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
COMMENT ON TABLE "RP_Infrastruktur"."RP_Verkehr_status" IS 'Klassifikation von Verkehrsstati.';
GRANT SELECT ON TABLE "RP_Infrastruktur"."RP_Verkehr_status" TO xp_gast;
GRANT ALL ON TABLE "RP_Infrastruktur"."RP_Verkehr_status" TO rp_user;

ALTER TABLE "RP_Infrastruktur"."RP_Verkehr" ADD COLUMN "bezeichnung" VARCHAR(64);
COMMENT ON COLUMN "RP_Infrastruktur"."RP_Verkehr"."bezeichnung" IS 'Bezeichnung eines Verkehrstyps.';

-- -----------------------------------------------------
-- Table "RP_Infrastruktur"."RP_LuftverkehrTypen"
-- -----------------------------------------------------
CREATE TABLE "RP_Infrastruktur"."RP_LuftverkehrTypen" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Code") );
GRANT SELECT ON TABLE "RP_Infrastruktur"."RP_LuftverkehrTypen" TO xp_gast;

INSERT INTO "RP_Infrastruktur"."RP_LuftverkehrTypen" ("Code", "Bezeichner") VALUES ('1000', 'Flughafen');
INSERT INTO "RP_Infrastruktur"."RP_LuftverkehrTypen" ("Code", "Bezeichner") VALUES ('1001', 'Verkehrsflughafen');
INSERT INTO "RP_Infrastruktur"."RP_LuftverkehrTypen" ("Code", "Bezeichner") VALUES ('1002', 'Regionalflughafen');
INSERT INTO "RP_Infrastruktur"."RP_LuftverkehrTypen" ("Code", "Bezeichner") VALUES ('1003', 'InternationalerFlughafen');
INSERT INTO "RP_Infrastruktur"."RP_LuftverkehrTypen" ("Code", "Bezeichner") VALUES ('1004', 'InternationalerVerkehrsflughafen');
INSERT INTO "RP_Infrastruktur"."RP_LuftverkehrTypen" ("Code", "Bezeichner") VALUES ('1005', 'Flughafenentwicklung');
INSERT INTO "RP_Infrastruktur"."RP_LuftverkehrTypen" ("Code", "Bezeichner") VALUES ('2000', 'Flugplatz');
INSERT INTO "RP_Infrastruktur"."RP_LuftverkehrTypen" ("Code", "Bezeichner") VALUES ('2001', 'Regionalflugplatz');
INSERT INTO "RP_Infrastruktur"."RP_LuftverkehrTypen" ("Code", "Bezeichner") VALUES ('2002', 'Segelflugplatz');
INSERT INTO "RP_Infrastruktur"."RP_LuftverkehrTypen" ("Code", "Bezeichner") VALUES ('2003', 'SonstigerFlugplatz');
INSERT INTO "RP_Infrastruktur"."RP_LuftverkehrTypen" ("Code", "Bezeichner") VALUES ('3000', 'Bauschutzbereich');
INSERT INTO "RP_Infrastruktur"."RP_LuftverkehrTypen" ("Code", "Bezeichner") VALUES ('4000', 'Militaerflughafen');
INSERT INTO "RP_Infrastruktur"."RP_LuftverkehrTypen" ("Code", "Bezeichner") VALUES ('5000', 'Landeplatz');
INSERT INTO "RP_Infrastruktur"."RP_LuftverkehrTypen" ("Code", "Bezeichner") VALUES ('5001', 'Verkehrslandeplatz');
INSERT INTO "RP_Infrastruktur"."RP_LuftverkehrTypen" ("Code", "Bezeichner") VALUES ('5002', 'Hubschrauberlandeplatz');
INSERT INTO "RP_Infrastruktur"."RP_LuftverkehrTypen" ("Code", "Bezeichner") VALUES ('5003', 'Landebahn');
INSERT INTO "RP_Infrastruktur"."RP_LuftverkehrTypen" ("Code", "Bezeichner") VALUES ('9999', 'SonstigerLuftverkehr');

-- -----------------------------------------------------
-- Table "RP_Infrastruktur"."RP_Luftverkehr"
-- -----------------------------------------------------
CREATE TABLE "RP_Infrastruktur"."RP_Luftverkehr" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid"),
  CONSTRAINT "fk_RP_Luftverkehr_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "RP_Infrastruktur"."RP_Verkehr" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE);

GRANT SELECT ON TABLE "RP_Infrastruktur"."RP_Luftverkehr" TO xp_gast;
GRANT ALL ON TABLE "RP_Infrastruktur"."RP_Luftverkehr" TO rp_user;
COMMENT ON TABLE "RP_Infrastruktur"."RP_Luftverkehr" IS 'Luftverkehr-Infrastruktur ist Infrastruktur, die im Zusammenhang mit der Beförderung von Personen, Gepäck, Fracht und Post mit staatlich zugelassenen Luftfahrzeugen, besonders Flugzeugen steht.';
COMMENT ON COLUMN "RP_Infrastruktur"."RP_Luftverkehr"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';

-- -----------------------------------------------------
-- Table "RP_Infrastruktur"."RP_Luftverkehr_typ"
-- -----------------------------------------------------
CREATE TABLE "RP_Infrastruktur"."RP_Luftverkehr_typ" (
  "RP_Luftverkehr_gid" BIGINT NOT NULL,
  "typ" INTEGER NOT NULL,
  PRIMARY KEY ("RP_Luftverkehr_gid", "typ"),
  CONSTRAINT "fk_RP_Luftverkehr_typ1"
    FOREIGN KEY ("RP_Luftverkehr_gid")
    REFERENCES "RP_Infrastruktur"."RP_Luftverkehr" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_RP_Luftverkehr_typ2"
    FOREIGN KEY ("typ")
    REFERENCES "RP_Infrastruktur"."RP_LuftverkehrTypen" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
COMMENT ON TABLE "RP_Infrastruktur"."RP_Luftverkehr_typ" IS 'Klassifikation von Verkehrsstati.';
GRANT SELECT ON TABLE "RP_Infrastruktur"."RP_Luftverkehr_typ" TO xp_gast;
GRANT ALL ON TABLE "RP_Infrastruktur"."RP_Luftverkehr_typ" TO rp_user;

-- -----------------------------------------------------
-- Table "RP_Infrastruktur"."RP_LuftverkehrFlaeche"
-- -----------------------------------------------------
CREATE TABLE "RP_Infrastruktur"."RP_LuftverkehrFlaeche" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_RP_LuftverkehrFlaeche_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "RP_Infrastruktur"."RP_Luftverkehr" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("RP_Basisobjekte"."RP_Flaechenobjekt");

GRANT SELECT ON TABLE "RP_Infrastruktur"."RP_LuftverkehrFlaeche" TO xp_gast;
GRANT ALL ON TABLE "RP_Infrastruktur"."RP_LuftverkehrFlaeche" TO rp_user;
COMMENT ON COLUMN "RP_Infrastruktur"."RP_LuftverkehrFlaeche"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_RP_LuftverkehrFlaeche" BEFORE INSERT OR UPDATE ON "RP_Infrastruktur"."RP_LuftverkehrFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "RP_Infrastruktur"."RP_LuftverkehrLinie"
-- -----------------------------------------------------
CREATE TABLE "RP_Infrastruktur"."RP_LuftverkehrLinie" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_RP_LuftverkehrLinie_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "RP_Infrastruktur"."RP_Luftverkehr" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("RP_Basisobjekte"."RP_Linienobjekt");

GRANT SELECT ON TABLE "RP_Infrastruktur"."RP_LuftverkehrLinie" TO xp_gast;
GRANT ALL ON TABLE "RP_Infrastruktur"."RP_LuftverkehrLinie" TO rp_user;
COMMENT ON COLUMN "RP_Infrastruktur"."RP_LuftverkehrLinie"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';

-- -----------------------------------------------------
-- Table "RP_Infrastruktur"."RP_LuftverkehrPunkt"
-- -----------------------------------------------------
CREATE TABLE "RP_Infrastruktur"."RP_LuftverkehrPunkt" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_RP_LuftverkehrPunkt_parent"
    FOREIGN KEY ("gid")
    REFERENCES "RP_Infrastruktur"."RP_Luftverkehr" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("RP_Basisobjekte"."RP_Punktobjekt");

GRANT SELECT ON TABLE "RP_Infrastruktur"."RP_LuftverkehrPunkt" TO xp_gast;
GRANT ALL ON TABLE "RP_Infrastruktur"."RP_LuftverkehrPunkt" TO rp_user;
COMMENT ON COLUMN "RP_Infrastruktur"."RP_LuftverkehrPunkt"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';

-- -----------------------------------------------------
-- Table "RP_Infrastruktur"."RP_SchienenverkehrTypen"
-- -----------------------------------------------------
CREATE TABLE "RP_Infrastruktur"."RP_SchienenverkehrTypen" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Code") );
GRANT SELECT ON TABLE "RP_Infrastruktur"."RP_SchienenverkehrTypen" TO xp_gast;

INSERT INTO "RP_Infrastruktur"."RP_SchienenverkehrTypen" ("Code", "Bezeichner") VALUES ('1000', 'Schienenverkehr');
INSERT INTO "RP_Infrastruktur"."RP_SchienenverkehrTypen" ("Code", "Bezeichner") VALUES ('1001', 'Eisenbahnstrecke');
INSERT INTO "RP_Infrastruktur"."RP_SchienenverkehrTypen" ("Code", "Bezeichner") VALUES ('1002', 'Haupteisenbahnstrecke');
INSERT INTO "RP_Infrastruktur"."RP_SchienenverkehrTypen" ("Code", "Bezeichner") VALUES ('1100', 'Trasse');
INSERT INTO "RP_Infrastruktur"."RP_SchienenverkehrTypen" ("Code", "Bezeichner") VALUES ('1200', 'Schienennetz');
INSERT INTO "RP_Infrastruktur"."RP_SchienenverkehrTypen" ("Code", "Bezeichner") VALUES ('1300', 'Stadtbahn');
INSERT INTO "RP_Infrastruktur"."RP_SchienenverkehrTypen" ("Code", "Bezeichner") VALUES ('1301', 'Strassenbahn');
INSERT INTO "RP_Infrastruktur"."RP_SchienenverkehrTypen" ("Code", "Bezeichner") VALUES ('1302', 'SBahn');
INSERT INTO "RP_Infrastruktur"."RP_SchienenverkehrTypen" ("Code", "Bezeichner") VALUES ('1303', 'UBahn');
INSERT INTO "RP_Infrastruktur"."RP_SchienenverkehrTypen" ("Code", "Bezeichner") VALUES ('1400', 'AnschlussgleisIndustrieGewerbe');
INSERT INTO "RP_Infrastruktur"."RP_SchienenverkehrTypen" ("Code", "Bezeichner") VALUES ('1500', 'Haltepunkt');
INSERT INTO "RP_Infrastruktur"."RP_SchienenverkehrTypen" ("Code", "Bezeichner") VALUES ('1600', 'Bahnhof');
INSERT INTO "RP_Infrastruktur"."RP_SchienenverkehrTypen" ("Code", "Bezeichner") VALUES ('1700', 'Hochgeschwindigkeitsverkehr');
INSERT INTO "RP_Infrastruktur"."RP_SchienenverkehrTypen" ("Code", "Bezeichner") VALUES ('1800', 'Bahnbetriebsgelaende');
INSERT INTO "RP_Infrastruktur"."RP_SchienenverkehrTypen" ("Code", "Bezeichner") VALUES ('1801', 'AnlagemitgrossemFlaechenbedarf');
INSERT INTO "RP_Infrastruktur"."RP_SchienenverkehrTypen" ("Code", "Bezeichner") VALUES ('9999', 'SonstigerSchienenverkehr');

-- -----------------------------------------------------
-- Table "RP_Infrastruktur"."RP_BesondererSchienenverkehrTypen"
-- -----------------------------------------------------
CREATE TABLE "RP_Infrastruktur"."RP_BesondererSchienenverkehrTypen" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Code") );
GRANT SELECT ON TABLE "RP_Infrastruktur"."RP_BesondererSchienenverkehrTypen" TO xp_gast;

INSERT INTO "RP_Infrastruktur"."RP_BesondererSchienenverkehrTypen" ("Code", "Bezeichner") VALUES ('1000', 'Eingleisig');
INSERT INTO "RP_Infrastruktur"."RP_BesondererSchienenverkehrTypen" ("Code", "Bezeichner") VALUES ('1001', 'Zweigleisig');
INSERT INTO "RP_Infrastruktur"."RP_BesondererSchienenverkehrTypen" ("Code", "Bezeichner") VALUES ('1002', 'Mehrgleisig');
INSERT INTO "RP_Infrastruktur"."RP_BesondererSchienenverkehrTypen" ("Code", "Bezeichner") VALUES ('2000', 'OhneBetrieb');
INSERT INTO "RP_Infrastruktur"."RP_BesondererSchienenverkehrTypen" ("Code", "Bezeichner") VALUES ('3000', 'MitFernverkehrsfunktion');
INSERT INTO "RP_Infrastruktur"."RP_BesondererSchienenverkehrTypen" ("Code", "Bezeichner") VALUES ('3001', 'MitVerknuepfungsfunktionFuerOEPNV');
INSERT INTO "RP_Infrastruktur"."RP_BesondererSchienenverkehrTypen" ("Code", "Bezeichner") VALUES ('4000', 'ElektrischerBetrieb');
INSERT INTO "RP_Infrastruktur"."RP_BesondererSchienenverkehrTypen" ("Code", "Bezeichner") VALUES ('4001', 'ZuElektrifizieren');
INSERT INTO "RP_Infrastruktur"."RP_BesondererSchienenverkehrTypen" ("Code", "Bezeichner") VALUES ('5000', 'VerbesserungLeistungsfaehigkeit');
INSERT INTO "RP_Infrastruktur"."RP_BesondererSchienenverkehrTypen" ("Code", "Bezeichner") VALUES ('6000', 'RaeumlicheFreihaltungentwidmeterBahntrassen');
INSERT INTO "RP_Infrastruktur"."RP_BesondererSchienenverkehrTypen" ("Code", "Bezeichner") VALUES ('6001', 'NachnutzungstillgelegterStrecken');
INSERT INTO "RP_Infrastruktur"."RP_BesondererSchienenverkehrTypen" ("Code", "Bezeichner") VALUES ('7000', 'Personenverkehr');
INSERT INTO "RP_Infrastruktur"."RP_BesondererSchienenverkehrTypen" ("Code", "Bezeichner") VALUES ('7001', 'Gueterverkehr');
INSERT INTO "RP_Infrastruktur"."RP_BesondererSchienenverkehrTypen" ("Code", "Bezeichner") VALUES ('8000', 'Nahverkehr');
INSERT INTO "RP_Infrastruktur"."RP_BesondererSchienenverkehrTypen" ("Code", "Bezeichner") VALUES ('8001', 'Fernverkehr');

-- -----------------------------------------------------
-- Table "RP_Infrastruktur"."RP_Schienenverkehr"
-- -----------------------------------------------------
CREATE TABLE "RP_Infrastruktur"."RP_Schienenverkehr" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid"),
  CONSTRAINT "fk_RP_Schienenverkehr_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "RP_Infrastruktur"."RP_Verkehr" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE);

GRANT SELECT ON TABLE "RP_Infrastruktur"."RP_Schienenverkehr" TO xp_gast;
GRANT ALL ON TABLE "RP_Infrastruktur"."RP_Schienenverkehr" TO rp_user;
COMMENT ON TABLE "RP_Infrastruktur"."RP_Schienenverkehr" IS 'Schienenverkehr-Infrastruktur.';
COMMENT ON COLUMN "RP_Infrastruktur"."RP_Schienenverkehr"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';

-- -----------------------------------------------------
-- Table "RP_Infrastruktur"."RP_Schienenverkehr_typ"
-- -----------------------------------------------------
CREATE TABLE "RP_Infrastruktur"."RP_Schienenverkehr_typ" (
  "RP_Schienenverkehr_gid" BIGINT NOT NULL,
  "typ" INTEGER NOT NULL,
  PRIMARY KEY ("RP_Schienenverkehr_gid", "typ"),
  CONSTRAINT "fk_RP_Schienenverkehr_typ1"
    FOREIGN KEY ("RP_Schienenverkehr_gid")
    REFERENCES "RP_Infrastruktur"."RP_Schienenverkehr" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_RP_Schienenverkehr_typ2"
    FOREIGN KEY ("typ")
    REFERENCES "RP_Infrastruktur"."RP_SchienenverkehrTypen" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
COMMENT ON TABLE "RP_Infrastruktur"."RP_Schienenverkehr_typ" IS 'Klassifikation von Schienenverkehr-Infrastruktur.';
GRANT SELECT ON TABLE "RP_Infrastruktur"."RP_Schienenverkehr_typ" TO xp_gast;
GRANT ALL ON TABLE "RP_Infrastruktur"."RP_Schienenverkehr_typ" TO rp_user;

-- -----------------------------------------------------
-- Table "RP_Infrastruktur"."RP_Schienenverkehr_besondererTyp"
-- -----------------------------------------------------
CREATE TABLE "RP_Infrastruktur"."RP_Schienenverkehr_besondererTyp" (
  "RP_Schienenverkehr_gid" BIGINT NOT NULL,
  "besondererTyp" INTEGER NOT NULL,
  PRIMARY KEY ("RP_Schienenverkehr_gid", "besondererTyp"),
  CONSTRAINT "fk_RP_Schienenverkehr_besondererTyp1"
    FOREIGN KEY ("RP_Schienenverkehr_gid")
    REFERENCES "RP_Infrastruktur"."RP_Schienenverkehr" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_RP_Schienenverkehr_besondererTyp2"
    FOREIGN KEY ("besondererTyp")
    REFERENCES "RP_Infrastruktur"."RP_BesondererSchienenverkehrTypen" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
COMMENT ON TABLE "RP_Infrastruktur"."RP_Schienenverkehr_besondererTyp" IS 'Klassifikation von besonderer Schienenverkehr-Infrastruktur.';
GRANT SELECT ON TABLE "RP_Infrastruktur"."RP_Schienenverkehr_besondererTyp" TO xp_gast;
GRANT ALL ON TABLE "RP_Infrastruktur"."RP_Schienenverkehr_besondererTyp" TO rp_user;

-- -----------------------------------------------------
-- Table "RP_Infrastruktur"."RP_SchienenverkehrFlaeche"
-- -----------------------------------------------------
CREATE TABLE "RP_Infrastruktur"."RP_SchienenverkehrFlaeche" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_RP_SchienenverkehrFlaeche_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "RP_Infrastruktur"."RP_Schienenverkehr" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("RP_Basisobjekte"."RP_Flaechenobjekt");

GRANT SELECT ON TABLE "RP_Infrastruktur"."RP_SchienenverkehrFlaeche" TO xp_gast;
GRANT ALL ON TABLE "RP_Infrastruktur"."RP_SchienenverkehrFlaeche" TO rp_user;
COMMENT ON COLUMN "RP_Infrastruktur"."RP_SchienenverkehrFlaeche"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_RP_SchienenverkehrFlaeche" BEFORE INSERT OR UPDATE ON "RP_Infrastruktur"."RP_SchienenverkehrFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "RP_Infrastruktur"."RP_SchienenverkehrLinie"
-- -----------------------------------------------------
CREATE TABLE "RP_Infrastruktur"."RP_SchienenverkehrLinie" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_RP_SchienenverkehrLinie_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "RP_Infrastruktur"."RP_Schienenverkehr" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("RP_Basisobjekte"."RP_Linienobjekt");

GRANT SELECT ON TABLE "RP_Infrastruktur"."RP_SchienenverkehrLinie" TO xp_gast;
GRANT ALL ON TABLE "RP_Infrastruktur"."RP_SchienenverkehrLinie" TO rp_user;
COMMENT ON COLUMN "RP_Infrastruktur"."RP_SchienenverkehrLinie"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';

-- -----------------------------------------------------
-- Table "RP_Infrastruktur"."RP_SchienenverkehrPunkt"
-- -----------------------------------------------------
CREATE TABLE "RP_Infrastruktur"."RP_SchienenverkehrPunkt" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_RP_SchienenverkehrPunkt_parent"
    FOREIGN KEY ("gid")
    REFERENCES "RP_Infrastruktur"."RP_Schienenverkehr" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("RP_Basisobjekte"."RP_Punktobjekt");

GRANT SELECT ON TABLE "RP_Infrastruktur"."RP_SchienenverkehrPunkt" TO xp_gast;
GRANT ALL ON TABLE "RP_Infrastruktur"."RP_SchienenverkehrPunkt" TO rp_user;
COMMENT ON COLUMN "RP_Infrastruktur"."RP_SchienenverkehrPunkt"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';

-- RP_Strassenverkehr
-- -----------------------------------------------------
-- Table "RP_Infrastruktur"."RP_StrassenverkehrTypen"
-- -----------------------------------------------------
CREATE TABLE "RP_Infrastruktur"."RP_StrassenverkehrTypen" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Code") );
GRANT SELECT ON TABLE "RP_Infrastruktur"."RP_StrassenverkehrTypen" TO xp_gast;

INSERT INTO "RP_Infrastruktur"."RP_StrassenverkehrTypen" ("Code", "Bezeichner") VALUES ('1000', 'Strassenverkehr');
INSERT INTO "RP_Infrastruktur"."RP_StrassenverkehrTypen" ("Code", "Bezeichner") VALUES ('1001', 'Hauptverkehrsstrasse');
INSERT INTO "RP_Infrastruktur"."RP_StrassenverkehrTypen" ("Code", "Bezeichner") VALUES ('1002', 'Autobahn');
INSERT INTO "RP_Infrastruktur"."RP_StrassenverkehrTypen" ("Code", "Bezeichner") VALUES ('1003', 'Bundesstrasse');
INSERT INTO "RP_Infrastruktur"."RP_StrassenverkehrTypen" ("Code", "Bezeichner") VALUES ('1004', 'Staatsstrasse');
INSERT INTO "RP_Infrastruktur"."RP_StrassenverkehrTypen" ("Code", "Bezeichner") VALUES ('1005', 'Landesstrasse');
INSERT INTO "RP_Infrastruktur"."RP_StrassenverkehrTypen" ("Code", "Bezeichner") VALUES ('1006', 'Kreisstrasse');
INSERT INTO "RP_Infrastruktur"."RP_StrassenverkehrTypen" ("Code", "Bezeichner") VALUES ('1007', 'Fernstrasse');
INSERT INTO "RP_Infrastruktur"."RP_StrassenverkehrTypen" ("Code", "Bezeichner") VALUES ('2000', 'Trasse');
INSERT INTO "RP_Infrastruktur"."RP_StrassenverkehrTypen" ("Code", "Bezeichner") VALUES ('3000', 'Strassennetz');
INSERT INTO "RP_Infrastruktur"."RP_StrassenverkehrTypen" ("Code", "Bezeichner") VALUES ('4000', 'Busverkehr');
INSERT INTO "RP_Infrastruktur"."RP_StrassenverkehrTypen" ("Code", "Bezeichner") VALUES ('5000', 'Anschlussstelle');
INSERT INTO "RP_Infrastruktur"."RP_StrassenverkehrTypen" ("Code", "Bezeichner") VALUES ('6000', 'Strassentunnel');
INSERT INTO "RP_Infrastruktur"."RP_StrassenverkehrTypen" ("Code", "Bezeichner") VALUES ('9999', 'SonstigerStrassenverkehr');

-- -----------------------------------------------------
-- Table "RP_Infrastruktur"."RP_BesondererStrassenverkehrTypen"
-- -----------------------------------------------------
CREATE TABLE "RP_Infrastruktur"."RP_BesondererStrassenverkehrTypen" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Code") );
GRANT SELECT ON TABLE "RP_Infrastruktur"."RP_BesondererStrassenverkehrTypen" TO xp_gast;

INSERT INTO "RP_Infrastruktur"."RP_BesondererStrassenverkehrTypen" ("Code", "Bezeichner") VALUES ('1000', 'Zweistreifig');
INSERT INTO "RP_Infrastruktur"."RP_BesondererStrassenverkehrTypen" ("Code", "Bezeichner") VALUES ('1001', 'Dreistreifig');
INSERT INTO "RP_Infrastruktur"."RP_BesondererStrassenverkehrTypen" ("Code", "Bezeichner") VALUES ('1002', 'Vierstreifig');
INSERT INTO "RP_Infrastruktur"."RP_BesondererStrassenverkehrTypen" ("Code", "Bezeichner") VALUES ('1003', 'Sechsstreifig');
INSERT INTO "RP_Infrastruktur"."RP_BesondererStrassenverkehrTypen" ("Code", "Bezeichner") VALUES ('2000', 'Problembereich');
INSERT INTO "RP_Infrastruktur"."RP_BesondererStrassenverkehrTypen" ("Code", "Bezeichner") VALUES ('3000', 'GruenbrueckeQuerungsmoeglichkeit');

-- -----------------------------------------------------
-- Table "RP_Infrastruktur"."RP_Strassenverkehr"
-- -----------------------------------------------------
CREATE TABLE "RP_Infrastruktur"."RP_Strassenverkehr" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid"),
  CONSTRAINT "fk_RP_Strassenverkehr_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "RP_Infrastruktur"."RP_Verkehr" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE);

GRANT SELECT ON TABLE "RP_Infrastruktur"."RP_Strassenverkehr" TO xp_gast;
GRANT ALL ON TABLE "RP_Infrastruktur"."RP_Strassenverkehr" TO rp_user;
COMMENT ON TABLE "RP_Infrastruktur"."RP_Strassenverkehr" IS 'Strassenverkehr-Infrastruktur.';
COMMENT ON COLUMN "RP_Infrastruktur"."RP_Strassenverkehr"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';

-- -----------------------------------------------------
-- Table "RP_Infrastruktur"."RP_Strassenverkehr_typ"
-- -----------------------------------------------------
CREATE TABLE "RP_Infrastruktur"."RP_Strassenverkehr_typ" (
  "RP_Strassenverkehr_gid" BIGINT NOT NULL,
  "typ" INTEGER NOT NULL,
  PRIMARY KEY ("RP_Strassenverkehr_gid", "typ"),
  CONSTRAINT "fk_RP_Strassenverkehr_typ1"
    FOREIGN KEY ("RP_Strassenverkehr_gid")
    REFERENCES "RP_Infrastruktur"."RP_Strassenverkehr" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_RP_Strassenverkehr_typ2"
    FOREIGN KEY ("typ")
    REFERENCES "RP_Infrastruktur"."RP_StrassenverkehrTypen" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
COMMENT ON TABLE "RP_Infrastruktur"."RP_Strassenverkehr_typ" IS 'Klassifikation von Strassenverkehr-Infrastruktur.';
GRANT SELECT ON TABLE "RP_Infrastruktur"."RP_Strassenverkehr_typ" TO xp_gast;
GRANT ALL ON TABLE "RP_Infrastruktur"."RP_Strassenverkehr_typ" TO rp_user;

-- -----------------------------------------------------
-- Table "RP_Infrastruktur"."RP_Strassenverkehr_besondererTyp"
-- -----------------------------------------------------
CREATE TABLE "RP_Infrastruktur"."RP_Strassenverkehr_besondererTyp" (
  "RP_Strassenverkehr_gid" BIGINT NOT NULL,
  "besondererTyp" INTEGER NOT NULL,
  PRIMARY KEY ("RP_Strassenverkehr_gid", "besondererTyp"),
  CONSTRAINT "fk_RP_Strassenverkehr_besondererTyp1"
    FOREIGN KEY ("RP_Strassenverkehr_gid")
    REFERENCES "RP_Infrastruktur"."RP_Strassenverkehr" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_RP_Strassenverkehr_besondererTyp2"
    FOREIGN KEY ("besondererTyp")
    REFERENCES "RP_Infrastruktur"."RP_BesondererStrassenverkehrTypen" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
COMMENT ON TABLE "RP_Infrastruktur"."RP_Strassenverkehr_besondererTyp" IS 'Klassifikation von besonderer Strassenverkehr-Infrastruktur.';
GRANT SELECT ON TABLE "RP_Infrastruktur"."RP_Strassenverkehr_besondererTyp" TO xp_gast;
GRANT ALL ON TABLE "RP_Infrastruktur"."RP_Strassenverkehr_besondererTyp" TO rp_user;

-- -----------------------------------------------------
-- Table "RP_Infrastruktur"."RP_StrassenverkehrFlaeche"
-- -----------------------------------------------------
CREATE TABLE "RP_Infrastruktur"."RP_StrassenverkehrFlaeche" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_RP_StrassenverkehrFlaeche_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "RP_Infrastruktur"."RP_Strassenverkehr" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("RP_Basisobjekte"."RP_Flaechenobjekt");

GRANT SELECT ON TABLE "RP_Infrastruktur"."RP_StrassenverkehrFlaeche" TO xp_gast;
GRANT ALL ON TABLE "RP_Infrastruktur"."RP_StrassenverkehrFlaeche" TO rp_user;
COMMENT ON COLUMN "RP_Infrastruktur"."RP_StrassenverkehrFlaeche"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_RP_StrassenverkehrFlaeche" BEFORE INSERT OR UPDATE ON "RP_Infrastruktur"."RP_StrassenverkehrFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "RP_Infrastruktur"."RP_StrassenverkehrLinie"
-- -----------------------------------------------------
CREATE TABLE "RP_Infrastruktur"."RP_StrassenverkehrLinie" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_RP_StrassenverkehrLinie_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "RP_Infrastruktur"."RP_Strassenverkehr" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("RP_Basisobjekte"."RP_Linienobjekt");

GRANT SELECT ON TABLE "RP_Infrastruktur"."RP_StrassenverkehrLinie" TO xp_gast;
GRANT ALL ON TABLE "RP_Infrastruktur"."RP_StrassenverkehrLinie" TO rp_user;
COMMENT ON COLUMN "RP_Infrastruktur"."RP_StrassenverkehrLinie"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';

-- -----------------------------------------------------
-- Table "RP_Infrastruktur"."RP_StrassenverkehrPunkt"
-- -----------------------------------------------------
CREATE TABLE "RP_Infrastruktur"."RP_StrassenverkehrPunkt" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_RP_StrassenverkehrPunkt_parent"
    FOREIGN KEY ("gid")
    REFERENCES "RP_Infrastruktur"."RP_Strassenverkehr" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("RP_Basisobjekte"."RP_Punktobjekt");

GRANT SELECT ON TABLE "RP_Infrastruktur"."RP_StrassenverkehrPunkt" TO xp_gast;
GRANT ALL ON TABLE "RP_Infrastruktur"."RP_StrassenverkehrPunkt" TO rp_user;
COMMENT ON COLUMN "RP_Infrastruktur"."RP_StrassenverkehrPunkt"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';

-- RP_SonstVerkehr
-- -----------------------------------------------------
-- Table "RP_Infrastruktur"."RP_SonstVerkehrTypen"
-- -----------------------------------------------------
CREATE TABLE "RP_Infrastruktur"."RP_SonstVerkehrTypen" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Code") );
GRANT SELECT ON TABLE "RP_Infrastruktur"."RP_SonstVerkehrTypen" TO xp_gast;

INSERT INTO "RP_Infrastruktur"."RP_SonstVerkehrTypen" ("Code", "Bezeichner") VALUES ('1000', 'Verkehrsanlage');
INSERT INTO "RP_Infrastruktur"."RP_SonstVerkehrTypen" ("Code", "Bezeichner") VALUES ('1100', 'Gueterverkehrszentrum');
INSERT INTO "RP_Infrastruktur"."RP_SonstVerkehrTypen" ("Code", "Bezeichner") VALUES ('1200', 'Logistikzentrum');
INSERT INTO "RP_Infrastruktur"."RP_SonstVerkehrTypen" ("Code", "Bezeichner") VALUES ('1300', 'TerminalkombinierterVerkehr');
INSERT INTO "RP_Infrastruktur"."RP_SonstVerkehrTypen" ("Code", "Bezeichner") VALUES ('1400', 'OEPNV');
INSERT INTO "RP_Infrastruktur"."RP_SonstVerkehrTypen" ("Code", "Bezeichner") VALUES ('1500', 'VerknuepfungspunktBahnBus');
INSERT INTO "RP_Infrastruktur"."RP_SonstVerkehrTypen" ("Code", "Bezeichner") VALUES ('1600', 'ParkandRideBikeandRide');
INSERT INTO "RP_Infrastruktur"."RP_SonstVerkehrTypen" ("Code", "Bezeichner") VALUES ('1700', 'Faehrverkehr');
INSERT INTO "RP_Infrastruktur"."RP_SonstVerkehrTypen" ("Code", "Bezeichner") VALUES ('1800', 'Infrastrukturkorridor');
INSERT INTO "RP_Infrastruktur"."RP_SonstVerkehrTypen" ("Code", "Bezeichner") VALUES ('1900', 'Tunnel');
INSERT INTO "RP_Infrastruktur"."RP_SonstVerkehrTypen" ("Code", "Bezeichner") VALUES ('2000', 'NeueVerkehrstechniken');
INSERT INTO "RP_Infrastruktur"."RP_SonstVerkehrTypen" ("Code", "Bezeichner") VALUES ('9999', 'SonstigerVerkehr');

-- -----------------------------------------------------
-- Table "RP_Infrastruktur"."RP_SonstVerkehr"
-- -----------------------------------------------------
CREATE TABLE "RP_Infrastruktur"."RP_SonstVerkehr" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid"),
  CONSTRAINT "fk_RP_SonstVerkehr_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "RP_Infrastruktur"."RP_Verkehr" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE);

GRANT SELECT ON TABLE "RP_Infrastruktur"."RP_SonstVerkehr" TO xp_gast;
GRANT ALL ON TABLE "RP_Infrastruktur"."RP_SonstVerkehr" TO rp_user;
COMMENT ON TABLE "RP_Infrastruktur"."RP_SonstVerkehr" IS 'Strassenverkehr-Infrastruktur.';
COMMENT ON COLUMN "RP_Infrastruktur"."RP_SonstVerkehr"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';

-- -----------------------------------------------------
-- Table "RP_Infrastruktur"."RP_SonstVerkehr_typ"
-- -----------------------------------------------------
CREATE TABLE "RP_Infrastruktur"."RP_SonstVerkehr_typ" (
  "RP_SonstVerkehr_gid" BIGINT NOT NULL,
  "typ" INTEGER NOT NULL,
  PRIMARY KEY ("RP_SonstVerkehr_gid", "typ"),
  CONSTRAINT "fk_RP_SonstVerkehr_typ1"
    FOREIGN KEY ("RP_SonstVerkehr_gid")
    REFERENCES "RP_Infrastruktur"."RP_SonstVerkehr" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_RP_SonstVerkehr_typ2"
    FOREIGN KEY ("typ")
    REFERENCES "RP_Infrastruktur"."RP_SonstVerkehrTypen" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
COMMENT ON TABLE "RP_Infrastruktur"."RP_SonstVerkehr_typ" IS 'Sonstige Klassifikation von Verkehrs-Infrastruktur.';
GRANT SELECT ON TABLE "RP_Infrastruktur"."RP_SonstVerkehr_typ" TO xp_gast;
GRANT ALL ON TABLE "RP_Infrastruktur"."RP_SonstVerkehr_typ" TO rp_user;

-- -----------------------------------------------------
-- Table "RP_Infrastruktur"."RP_SonstVerkehrFlaeche"
-- -----------------------------------------------------
CREATE TABLE "RP_Infrastruktur"."RP_SonstVerkehrFlaeche" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_RP_SonstVerkehrFlaeche_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "RP_Infrastruktur"."RP_SonstVerkehr" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("RP_Basisobjekte"."RP_Flaechenobjekt");

GRANT SELECT ON TABLE "RP_Infrastruktur"."RP_SonstVerkehrFlaeche" TO xp_gast;
GRANT ALL ON TABLE "RP_Infrastruktur"."RP_SonstVerkehrFlaeche" TO rp_user;
COMMENT ON COLUMN "RP_Infrastruktur"."RP_SonstVerkehrFlaeche"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';

-- -----------------------------------------------------
-- Table "RP_Infrastruktur"."RP_SonstVerkehrLinie"
-- -----------------------------------------------------
CREATE TABLE "RP_Infrastruktur"."RP_SonstVerkehrLinie" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_RP_SonstVerkehrLinie_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "RP_Infrastruktur"."RP_SonstVerkehr" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("RP_Basisobjekte"."RP_Linienobjekt");

GRANT SELECT ON TABLE "RP_Infrastruktur"."RP_SonstVerkehrLinie" TO xp_gast;
GRANT ALL ON TABLE "RP_Infrastruktur"."RP_SonstVerkehrLinie" TO rp_user;
COMMENT ON COLUMN "RP_Infrastruktur"."RP_SonstVerkehrLinie"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';

-- -----------------------------------------------------
-- Table "RP_Infrastruktur"."RP_SonstVerkehrPunkt"
-- -----------------------------------------------------
CREATE TABLE "RP_Infrastruktur"."RP_SonstVerkehrPunkt" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_RP_SonstVerkehrPunkt_parent"
    FOREIGN KEY ("gid")
    REFERENCES "RP_Infrastruktur"."RP_SonstVerkehr" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("RP_Basisobjekte"."RP_Punktobjekt");

GRANT SELECT ON TABLE "RP_Infrastruktur"."RP_SonstVerkehrPunkt" TO xp_gast;
GRANT ALL ON TABLE "RP_Infrastruktur"."RP_SonstVerkehrPunkt" TO rp_user;
COMMENT ON COLUMN "RP_Infrastruktur"."RP_SonstVerkehrPunkt"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';

-- RP_Wasserverkehr
-- -----------------------------------------------------
-- Table "RP_Infrastruktur"."RP_WasserverkehrTypen"
-- -----------------------------------------------------
CREATE TABLE "RP_Infrastruktur"."RP_WasserverkehrTypen" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Code") );
GRANT SELECT ON TABLE "RP_Infrastruktur"."RP_WasserverkehrTypen" TO xp_gast;

INSERT INTO "RP_Infrastruktur"."RP_WasserverkehrTypen" ("Code", "Bezeichner") VALUES ('1000', 'Hafen');
INSERT INTO "RP_Infrastruktur"."RP_WasserverkehrTypen" ("Code", "Bezeichner") VALUES ('1001', 'Seehafen');
INSERT INTO "RP_Infrastruktur"."RP_WasserverkehrTypen" ("Code", "Bezeichner") VALUES ('1002', 'Binnenhafen');
INSERT INTO "RP_Infrastruktur"."RP_WasserverkehrTypen" ("Code", "Bezeichner") VALUES ('1003', 'Sportboothafen');
INSERT INTO "RP_Infrastruktur"."RP_WasserverkehrTypen" ("Code", "Bezeichner") VALUES ('1004', 'Laende');
INSERT INTO "RP_Infrastruktur"."RP_WasserverkehrTypen" ("Code", "Bezeichner") VALUES ('2000', 'Umschlagplatz');
INSERT INTO "RP_Infrastruktur"."RP_WasserverkehrTypen" ("Code", "Bezeichner") VALUES ('3000', 'SchleuseHebewerk');
INSERT INTO "RP_Infrastruktur"."RP_WasserverkehrTypen" ("Code", "Bezeichner") VALUES ('4000', 'Schifffahrt');
INSERT INTO "RP_Infrastruktur"."RP_WasserverkehrTypen" ("Code", "Bezeichner") VALUES ('4001', 'WichtigerSchifffahrtsweg');
INSERT INTO "RP_Infrastruktur"."RP_WasserverkehrTypen" ("Code", "Bezeichner") VALUES ('4002', 'SonstigerSchifffahrtsweg');
INSERT INTO "RP_Infrastruktur"."RP_WasserverkehrTypen" ("Code", "Bezeichner") VALUES ('4003', 'Wasserstrasse');
INSERT INTO "RP_Infrastruktur"."RP_WasserverkehrTypen" ("Code", "Bezeichner") VALUES ('5000', 'Reede');
INSERT INTO "RP_Infrastruktur"."RP_WasserverkehrTypen" ("Code", "Bezeichner") VALUES ('9999', 'SonstigerWasserverkehr');

-- -----------------------------------------------------
-- Table "RP_Infrastruktur"."RP_Wasserverkehr"
-- -----------------------------------------------------
CREATE TABLE "RP_Infrastruktur"."RP_Wasserverkehr" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid"),
  CONSTRAINT "fk_RP_Wasserverkehr_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "RP_Infrastruktur"."RP_Verkehr" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE);

GRANT SELECT ON TABLE "RP_Infrastruktur"."RP_Wasserverkehr" TO xp_gast;
GRANT ALL ON TABLE "RP_Infrastruktur"."RP_Wasserverkehr" TO rp_user;
COMMENT ON TABLE "RP_Infrastruktur"."RP_Wasserverkehr" IS 'Strassenverkehr-Infrastruktur.';
COMMENT ON COLUMN "RP_Infrastruktur"."RP_Wasserverkehr"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';

-- -----------------------------------------------------
-- Table "RP_Infrastruktur"."RP_Wasserverkehr_typ"
-- -----------------------------------------------------
CREATE TABLE "RP_Infrastruktur"."RP_Wasserverkehr_typ" (
  "RP_Wasserverkehr_gid" BIGINT NOT NULL,
  "typ" INTEGER NOT NULL,
  PRIMARY KEY ("RP_Wasserverkehr_gid", "typ"),
  CONSTRAINT "fk_RP_Wasserverkehr_typ1"
    FOREIGN KEY ("RP_Wasserverkehr_gid")
    REFERENCES "RP_Infrastruktur"."RP_Wasserverkehr" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_RP_Wasserverkehr_typ2"
    FOREIGN KEY ("typ")
    REFERENCES "RP_Infrastruktur"."RP_WasserverkehrTypen" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
COMMENT ON TABLE "RP_Infrastruktur"."RP_Wasserverkehr_typ" IS 'Klassifikation von Wasserverkehr-Infrastruktur.';
GRANT SELECT ON TABLE "RP_Infrastruktur"."RP_Wasserverkehr_typ" TO xp_gast;
GRANT ALL ON TABLE "RP_Infrastruktur"."RP_Wasserverkehr_typ" TO rp_user;

-- -----------------------------------------------------
-- Table "RP_Infrastruktur"."RP_WasserverkehrFlaeche"
-- -----------------------------------------------------
CREATE TABLE "RP_Infrastruktur"."RP_WasserverkehrFlaeche" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_RP_WasserverkehrFlaeche_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "RP_Infrastruktur"."RP_Wasserverkehr" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("RP_Basisobjekte"."RP_Flaechenobjekt");

GRANT SELECT ON TABLE "RP_Infrastruktur"."RP_WasserverkehrFlaeche" TO xp_gast;
GRANT ALL ON TABLE "RP_Infrastruktur"."RP_WasserverkehrFlaeche" TO rp_user;
COMMENT ON COLUMN "RP_Infrastruktur"."RP_WasserverkehrFlaeche"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';

-- -----------------------------------------------------
-- Table "RP_Infrastruktur"."RP_WasserverkehrLinie"
-- -----------------------------------------------------
CREATE TABLE "RP_Infrastruktur"."RP_WasserverkehrLinie" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_RP_WasserverkehrLinie_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "RP_Infrastruktur"."RP_Wasserverkehr" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("RP_Basisobjekte"."RP_Linienobjekt");

GRANT SELECT ON TABLE "RP_Infrastruktur"."RP_WasserverkehrLinie" TO xp_gast;
GRANT ALL ON TABLE "RP_Infrastruktur"."RP_WasserverkehrLinie" TO rp_user;
COMMENT ON COLUMN "RP_Infrastruktur"."RP_WasserverkehrLinie"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';

-- -----------------------------------------------------
-- Table "RP_Infrastruktur"."RP_WasserverkehrPunkt"
-- -----------------------------------------------------
CREATE TABLE "RP_Infrastruktur"."RP_WasserverkehrPunkt" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_RP_WasserverkehrPunkt_parent"
    FOREIGN KEY ("gid")
    REFERENCES "RP_Infrastruktur"."RP_Wasserverkehr" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("RP_Basisobjekte"."RP_Punktobjekt");

GRANT SELECT ON TABLE "RP_Infrastruktur"."RP_WasserverkehrPunkt" TO xp_gast;
GRANT ALL ON TABLE "RP_Infrastruktur"."RP_WasserverkehrPunkt" TO rp_user;
COMMENT ON COLUMN "RP_Infrastruktur"."RP_WasserverkehrPunkt"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';

-- Obwohl RP_Verkehr nicht abstrakt ist, werden die darin bereits enthaltenen Objekte in die entsprechenden Unterklassen getan
-- RP_Luftverkehr
INSERT INTO "RP_Infrastruktur"."RP_Luftverkehr"(gid) SELECT gid FROM "RP_Infrastruktur"."RP_Verkehr" WHERE "typ" = 3000;
INSERT INTO "RP_Infrastruktur"."RP_LuftverkehrFlaeche"(gid,position) SELECT gid,position FROM "RP_Infrastruktur"."RP_VerkehrFlaeche" WHERE gid IN (SELECT gid FROM "RP_Infrastruktur"."RP_Verkehr" WHERE "typ" = 3000);
DELETE FROM "RP_Infrastruktur"."RP_VerkehrFlaeche" WHERE gid IN (SELECT gid FROM "RP_Infrastruktur"."RP_Verkehr" WHERE "typ" = 3000);
INSERT INTO "RP_Infrastruktur"."RP_LuftverkehrLinie"(gid,position) SELECT gid,position FROM "RP_Infrastruktur"."RP_VerkehrLinie" WHERE gid IN (SELECT gid FROM "RP_Infrastruktur"."RP_Verkehr" WHERE "typ" = 3000);
DELETE FROM "RP_Infrastruktur"."RP_VerkehrLinie" WHERE gid IN (SELECT gid FROM "RP_Infrastruktur"."RP_Verkehr" WHERE "typ" = 3000);
INSERT INTO "RP_Infrastruktur"."RP_LuftverkehrPunkt"(gid,position) SELECT gid,position FROM "RP_Infrastruktur"."RP_VerkehrPunkt" WHERE gid IN (SELECT gid FROM "RP_Infrastruktur"."RP_Verkehr" WHERE "typ" = 3000);
DELETE FROM "RP_Infrastruktur"."RP_VerkehrPunkt" WHERE gid IN (SELECT gid FROM "RP_Infrastruktur"."RP_Verkehr" WHERE "typ" = 3000);
CREATE TRIGGER "change_to_RP_Luftverkehr" BEFORE INSERT OR UPDATE ON "RP_Infrastruktur"."RP_Luftverkehr" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_Luftverkehr" AFTER DELETE ON "RP_Infrastruktur"."RP_Luftverkehr" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_LuftverkehrFlaeche" AFTER DELETE ON "RP_Infrastruktur"."RP_LuftverkehrFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "RP_LuftverkehrFlaeche_Flaechenobjekt" BEFORE INSERT OR UPDATE ON "RP_Infrastruktur"."RP_LuftverkehrFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."positionFollowsRHR"();
CREATE TRIGGER "change_to_RP_LuftverkehrLinie" BEFORE INSERT OR UPDATE ON "RP_Infrastruktur"."RP_LuftverkehrLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_LuftverkehrLinie" AFTER DELETE ON "RP_Infrastruktur"."RP_LuftverkehrLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "change_to_RP_LuftverkehrPunkt" BEFORE INSERT OR UPDATE ON "RP_Infrastruktur"."RP_LuftverkehrPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_LuftverkehrPunkt" AFTER DELETE ON "RP_Infrastruktur"."RP_LuftverkehrPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
-- RP_Schienenverkehr
INSERT INTO "RP_Infrastruktur"."RP_Schienenverkehr"(gid) SELECT gid FROM "RP_Infrastruktur"."RP_Verkehr" WHERE "typ" = 1000;
INSERT INTO "RP_Infrastruktur"."RP_SchienenverkehrFlaeche"(gid,position) SELECT gid,position FROM "RP_Infrastruktur"."RP_VerkehrFlaeche" WHERE gid IN (SELECT gid FROM "RP_Infrastruktur"."RP_Verkehr" WHERE "typ" = 1000);
DELETE FROM "RP_Infrastruktur"."RP_VerkehrFlaeche" WHERE gid IN (SELECT gid FROM "RP_Infrastruktur"."RP_Verkehr" WHERE "typ" = 1000);
INSERT INTO "RP_Infrastruktur"."RP_SchienenverkehrLinie"(gid,position) SELECT gid,position FROM "RP_Infrastruktur"."RP_VerkehrLinie" WHERE gid IN (SELECT gid FROM "RP_Infrastruktur"."RP_Verkehr" WHERE "typ" = 1000);
DELETE FROM "RP_Infrastruktur"."RP_VerkehrLinie" WHERE gid IN (SELECT gid FROM "RP_Infrastruktur"."RP_Verkehr" WHERE "typ" = 1000);
INSERT INTO "RP_Infrastruktur"."RP_SchienenverkehrPunkt"(gid,position) SELECT gid,position FROM "RP_Infrastruktur"."RP_VerkehrPunkt" WHERE gid IN (SELECT gid FROM "RP_Infrastruktur"."RP_Verkehr" WHERE "typ" = 1000);
DELETE FROM "RP_Infrastruktur"."RP_VerkehrPunkt" WHERE gid IN (SELECT gid FROM "RP_Infrastruktur"."RP_Verkehr" WHERE "typ" = 1000);
CREATE TRIGGER "change_to_RP_Schienenverkehr" BEFORE INSERT OR UPDATE ON "RP_Infrastruktur"."RP_Schienenverkehr" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_Schienenverkehr" AFTER DELETE ON "RP_Infrastruktur"."RP_Schienenverkehr" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_SchienenverkehrFlaeche" AFTER DELETE ON "RP_Infrastruktur"."RP_SchienenverkehrFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "RP_SchienenverkehrFlaeche_Flaechenobjekt" BEFORE INSERT OR UPDATE ON "RP_Infrastruktur"."RP_SchienenverkehrFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."positionFollowsRHR"();
CREATE TRIGGER "change_to_RP_SchienenverkehrLinie" BEFORE INSERT OR UPDATE ON "RP_Infrastruktur"."RP_SchienenverkehrLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_SchienenverkehrLinie" AFTER DELETE ON "RP_Infrastruktur"."RP_SchienenverkehrLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "change_to_RP_SchienenverkehrPunkt" BEFORE INSERT OR UPDATE ON "RP_Infrastruktur"."RP_SchienenverkehrPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_SchienenverkehrPunkt" AFTER DELETE ON "RP_Infrastruktur"."RP_SchienenverkehrPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
-- RP_Strassenverkehr
INSERT INTO "RP_Infrastruktur"."RP_Strassenverkehr"(gid) SELECT gid FROM "RP_Infrastruktur"."RP_Verkehr" WHERE "typ" = 2000;
INSERT INTO "RP_Infrastruktur"."RP_StrassenverkehrFlaeche"(gid,position) SELECT gid,position FROM "RP_Infrastruktur"."RP_VerkehrFlaeche" WHERE gid IN (SELECT gid FROM "RP_Infrastruktur"."RP_Verkehr" WHERE "typ" = 2000);
DELETE FROM "RP_Infrastruktur"."RP_VerkehrFlaeche" WHERE gid IN (SELECT gid FROM "RP_Infrastruktur"."RP_Verkehr" WHERE "typ" = 2000);
INSERT INTO "RP_Infrastruktur"."RP_StrassenverkehrLinie"(gid,position) SELECT gid,position FROM "RP_Infrastruktur"."RP_VerkehrLinie" WHERE gid IN (SELECT gid FROM "RP_Infrastruktur"."RP_Verkehr" WHERE "typ" = 2000);
DELETE FROM "RP_Infrastruktur"."RP_VerkehrLinie" WHERE gid IN (SELECT gid FROM "RP_Infrastruktur"."RP_Verkehr" WHERE "typ" = 2000);
INSERT INTO "RP_Infrastruktur"."RP_StrassenverkehrPunkt"(gid,position) SELECT gid,position FROM "RP_Infrastruktur"."RP_VerkehrPunkt" WHERE gid IN (SELECT gid FROM "RP_Infrastruktur"."RP_Verkehr" WHERE "typ" = 2000);
DELETE FROM "RP_Infrastruktur"."RP_VerkehrPunkt" WHERE gid IN (SELECT gid FROM "RP_Infrastruktur"."RP_Verkehr" WHERE "typ" = 2000);
CREATE TRIGGER "change_to_RP_Strassenverkehr" BEFORE INSERT OR UPDATE ON "RP_Infrastruktur"."RP_Strassenverkehr" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_Strassenverkehr" AFTER DELETE ON "RP_Infrastruktur"."RP_Strassenverkehr" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_StrassenverkehrFlaeche" AFTER DELETE ON "RP_Infrastruktur"."RP_StrassenverkehrFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "RP_StrassenverkehrFlaeche_Flaechenobjekt" BEFORE INSERT OR UPDATE ON "RP_Infrastruktur"."RP_StrassenverkehrFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."positionFollowsRHR"();
CREATE TRIGGER "change_to_RP_StrassenverkehrLinie" BEFORE INSERT OR UPDATE ON "RP_Infrastruktur"."RP_StrassenverkehrLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_StrassenverkehrLinie" AFTER DELETE ON "RP_Infrastruktur"."RP_StrassenverkehrLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "change_to_RP_StrassenverkehrPunkt" BEFORE INSERT OR UPDATE ON "RP_Infrastruktur"."RP_StrassenverkehrPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_StrassenverkehrPunkt" AFTER DELETE ON "RP_Infrastruktur"."RP_StrassenverkehrPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
-- RP_SonstVerkehr
INSERT INTO "RP_Infrastruktur"."RP_SonstVerkehr"(gid) SELECT gid FROM "RP_Infrastruktur"."RP_Verkehr" WHERE "typ" = 9999;
INSERT INTO "RP_Infrastruktur"."RP_SonstVerkehrFlaeche"(gid,position) SELECT gid,position FROM "RP_Infrastruktur"."RP_VerkehrFlaeche" WHERE gid IN (SELECT gid FROM "RP_Infrastruktur"."RP_Verkehr" WHERE "typ" = 9999);
DELETE FROM "RP_Infrastruktur"."RP_VerkehrFlaeche" WHERE gid IN (SELECT gid FROM "RP_Infrastruktur"."RP_Verkehr" WHERE "typ" = 9999);
INSERT INTO "RP_Infrastruktur"."RP_SonstVerkehrLinie"(gid,position) SELECT gid,position FROM "RP_Infrastruktur"."RP_VerkehrLinie" WHERE gid IN (SELECT gid FROM "RP_Infrastruktur"."RP_Verkehr" WHERE "typ" = 9999);
DELETE FROM "RP_Infrastruktur"."RP_VerkehrLinie" WHERE gid IN (SELECT gid FROM "RP_Infrastruktur"."RP_Verkehr" WHERE "typ" = 9999);
INSERT INTO "RP_Infrastruktur"."RP_SonstVerkehrPunkt"(gid,position) SELECT gid,position FROM "RP_Infrastruktur"."RP_VerkehrPunkt" WHERE gid IN (SELECT gid FROM "RP_Infrastruktur"."RP_Verkehr" WHERE "typ" = 9999);
DELETE FROM "RP_Infrastruktur"."RP_VerkehrPunkt" WHERE gid IN (SELECT gid FROM "RP_Infrastruktur"."RP_Verkehr" WHERE "typ" = 9999);
CREATE TRIGGER "change_to_RP_SonstVerkehr" BEFORE INSERT OR UPDATE ON "RP_Infrastruktur"."RP_SonstVerkehr" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_SonstVerkehr" AFTER DELETE ON "RP_Infrastruktur"."RP_SonstVerkehr" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "change_to_RP_SonstVerkehrFlaeche" BEFORE INSERT OR UPDATE ON "RP_Infrastruktur"."RP_SonstVerkehrFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_SonstVerkehrFlaeche" AFTER DELETE ON "RP_Infrastruktur"."RP_SonstVerkehrFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "RP_SonstVerkehrFlaeche_Flaechenobjekt" BEFORE INSERT OR UPDATE ON "RP_Infrastruktur"."RP_SonstVerkehrFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."positionFollowsRHR"();
CREATE TRIGGER "change_to_RP_SonstVerkehrLinie" BEFORE INSERT OR UPDATE ON "RP_Infrastruktur"."RP_SonstVerkehrLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_SonstVerkehrLinie" AFTER DELETE ON "RP_Infrastruktur"."RP_SonstVerkehrLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "change_to_RP_SonstVerkehrPunkt" BEFORE INSERT OR UPDATE ON "RP_Infrastruktur"."RP_SonstVerkehrPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_SonstVerkehrPunkt" AFTER DELETE ON "RP_Infrastruktur"."RP_SonstVerkehrPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
-- RP_Wasserverkehr
INSERT INTO "RP_Infrastruktur"."RP_Wasserverkehr"(gid) SELECT gid FROM "RP_Infrastruktur"."RP_Verkehr" WHERE "typ" = 4000;
INSERT INTO "RP_Infrastruktur"."RP_WasserverkehrFlaeche"(gid,position) SELECT gid,position FROM "RP_Infrastruktur"."RP_VerkehrFlaeche" WHERE gid IN (SELECT gid FROM "RP_Infrastruktur"."RP_Verkehr" WHERE "typ" = 4000);
DELETE FROM "RP_Infrastruktur"."RP_VerkehrFlaeche" WHERE gid IN (SELECT gid FROM "RP_Infrastruktur"."RP_Verkehr" WHERE "typ" = 4000);
INSERT INTO "RP_Infrastruktur"."RP_WasserverkehrLinie"(gid,position) SELECT gid,position FROM "RP_Infrastruktur"."RP_VerkehrLinie" WHERE gid IN (SELECT gid FROM "RP_Infrastruktur"."RP_Verkehr" WHERE "typ" = 4000);
DELETE FROM "RP_Infrastruktur"."RP_VerkehrLinie" WHERE gid IN (SELECT gid FROM "RP_Infrastruktur"."RP_Verkehr" WHERE "typ" = 4000);
INSERT INTO "RP_Infrastruktur"."RP_WasserverkehrPunkt"(gid,position) SELECT gid,position FROM "RP_Infrastruktur"."RP_VerkehrPunkt" WHERE gid IN (SELECT gid FROM "RP_Infrastruktur"."RP_Verkehr" WHERE "typ" = 4000);
DELETE FROM "RP_Infrastruktur"."RP_VerkehrPunkt" WHERE gid IN (SELECT gid FROM "RP_Infrastruktur"."RP_Verkehr" WHERE "typ" = 4000);
CREATE TRIGGER "change_to_RP_Wasserverkehr" BEFORE INSERT OR UPDATE ON "RP_Infrastruktur"."RP_Wasserverkehr" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_Wasserverkehr" AFTER DELETE ON "RP_Infrastruktur"."RP_Wasserverkehr" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "change_to_RP_WasserverkehrFlaeche" BEFORE INSERT OR UPDATE ON "RP_Infrastruktur"."RP_WasserverkehrFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_WasserverkehrFlaeche" AFTER DELETE ON "RP_Infrastruktur"."RP_WasserverkehrFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "RP_WasserverkehrFlaeche_Flaechenobjekt" BEFORE INSERT OR UPDATE ON "RP_Infrastruktur"."RP_WasserverkehrFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."positionFollowsRHR"();
CREATE TRIGGER "change_to_RP_WasserverkehrLinie" BEFORE INSERT OR UPDATE ON "RP_Infrastruktur"."RP_WasserverkehrLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_WasserverkehrLinie" AFTER DELETE ON "RP_Infrastruktur"."RP_WasserverkehrLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "change_to_RP_WasserverkehrPunkt" BEFORE INSERT OR UPDATE ON "RP_Infrastruktur"."RP_WasserverkehrPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_WasserverkehrPunkt" AFTER DELETE ON "RP_Infrastruktur"."RP_WasserverkehrPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

ALTER TABLE "RP_Infrastruktur"."RP_VerkehrFlaeche" ENABLE TRIGGER "delete_RP_VerkehrFlaeche";
ALTER TABLE "RP_Infrastruktur"."RP_VerkehrLinie" ENABLE TRIGGER "delete_RP_VerkehrLinie";
ALTER TABLE "RP_Infrastruktur"."RP_VerkehrPunkt" ENABLE TRIGGER "delete_RP_VerkehrPunkt";
ALTER TABLE "RP_Infrastruktur"."RP_Verkehr" ENABLE TRIGGER "change_to_RP_Verkehr";
ALTER TABLE "RP_Infrastruktur"."RP_Verkehr" ENABLE TRIGGER "delete_RP_Verkehr";

-- ###########################################
-- Überarbeitung RP_KernmodellSiedlungsstruktur
ALTER SCHEMA "RP_KernmodellSiedlungsstruktur" RENAME TO "RP_Siedlungsstruktur";
ALTER TABLE "RP_Siedlungsstruktur"."RP_AchseTypen" RENAME TO "RP_AchsenTypen";

-- RP_Achse
-- bisher gab es nur Linien, jetz sind alle Geometrietypen erlaubt
ALTER TABLE "RP_Siedlungsstruktur"."RP_Achse" RENAME TO "RP_AchseLinie";

-- -----------------------------------------------------
-- Table "RP_Siedlungsstruktur"."RP_Achse"
-- -----------------------------------------------------
CREATE TABLE "RP_Siedlungsstruktur"."RP_Achse" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid"),
  CONSTRAINT "fk_RP_Achse_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "RP_Basisobjekte"."RP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE);

GRANT SELECT ON TABLE "RP_Siedlungsstruktur"."RP_Achse" TO xp_gast;
GRANT ALL ON TABLE "RP_Siedlungsstruktur"."RP_Achse" TO rp_user;
COMMENT ON TABLE "RP_Siedlungsstruktur"."RP_Achse" IS 'Achsen bündeln i.d.R. Verkehrs- und Versorgungsinfrastruktur und enthalten eine relativ dichte Folge von Siedlungskonzentrationen und Zentralen Orten.';
INSERT INTO "RP_Siedlungsstruktur"."RP_Achse" (gid) SELECT gid FROM "RP_Siedlungsstruktur"."RP_AchseLinie";
CREATE TRIGGER "change_to_RP_Achse" BEFORE INSERT OR UPDATE ON "RP_Siedlungsstruktur"."RP_Achse" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_Achse" AFTER DELETE ON "RP_Siedlungsstruktur"."RP_Achse" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "RP_Siedlungsstruktur"."RP_Achse_typ"
-- -----------------------------------------------------
CREATE TABLE "RP_Siedlungsstruktur"."RP_Achse_typ" (
  "RP_Achse_gid" BIGINT NOT NULL,
  "typ" INTEGER NOT NULL,
  PRIMARY KEY ("RP_Achse_gid", "typ"),
  CONSTRAINT "fk_RP_Achse_typ1"
    FOREIGN KEY ("RP_Achse_gid")
    REFERENCES "RP_Siedlungsstruktur"."RP_Achse" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_RP_Achse_typ2"
    FOREIGN KEY ("typ")
    REFERENCES "RP_Siedlungsstruktur"."RP_AchsenTypen" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
COMMENT ON TABLE "RP_Siedlungsstruktur"."RP_Achse_typ" IS 'Klassifikation verschiedener Achsen.';
GRANT SELECT ON TABLE "RP_Siedlungsstruktur"."RP_Achse_typ" TO xp_gast;
GRANT ALL ON TABLE "RP_Siedlungsstruktur"."RP_Achse_typ" TO rp_user;

UPDATE "RP_Siedlungsstruktur"."RP_AchseLinie" SET "achsenTyp" = NULL WHERE "achsenTyp" = 2000;
DELETE FROM "RP_Siedlungsstruktur"."RP_AchsenTypen" WHERE "Code" = 2000;
UPDATE "RP_Siedlungsstruktur"."RP_AchsenTypen" SET "Code" = 2000 WHERE "Code" = 1000;
INSERT INTO "RP_Siedlungsstruktur"."RP_AchsenTypen" ("Code", "Bezeichner") VALUES ('1000', 'Achse');
INSERT INTO "RP_Siedlungsstruktur"."RP_AchsenTypen" ("Code", "Bezeichner") VALUES ('3000', 'Entwicklungsachse');
INSERT INTO "RP_Siedlungsstruktur"."RP_AchsenTypen" ("Code", "Bezeichner") VALUES ('3001', 'Landesentwicklungsachse');
INSERT INTO "RP_Siedlungsstruktur"."RP_AchsenTypen" ("Code", "Bezeichner") VALUES ('3002', 'Verbindungsachse');
INSERT INTO "RP_Siedlungsstruktur"."RP_AchsenTypen" ("Code", "Bezeichner") VALUES ('3003', 'Entwicklungskorridor');
INSERT INTO "RP_Siedlungsstruktur"."RP_AchsenTypen" ("Code", "Bezeichner") VALUES ('4000', 'AbgrenzungEntwicklungsEntlastungsorte');
INSERT INTO "RP_Siedlungsstruktur"."RP_AchsenTypen" ("Code", "Bezeichner") VALUES ('5000', 'Achsengrundrichtung');
INSERT INTO "RP_Siedlungsstruktur"."RP_AchsenTypen" ("Code", "Bezeichner") VALUES ('6000', 'AuessererAchsenSchwerpunkt');

INSERT INTO "RP_Siedlungsstruktur"."RP_Achse_typ" ("RP_Achse_gid","typ") SELECT gid,"achsenTyp" FROM "RP_Siedlungsstruktur"."RP_AchseLinie" WHERE "achsenTyp" IS NOT NULL;
ALTER TABLE "RP_Siedlungsstruktur"."RP_AchseLinie" DROP COLUMN "achsenTyp";
-- umbenennen von Trigger (Copy-Paste-Fehler)
ALTER TRIGGER "change_to_RP_WasserrechtWirtschaftAbflussHochwSchutzLinie" ON "RP_Siedlungsstruktur"."RP_AchseLinie" RENAME TO "change_to_RP_AchseLinie";
ALTER TRIGGER "delete_RP_WasserrechtWirtschaftAbflussHochwSchutzLinie" ON "RP_Siedlungsstruktur"."RP_AchseLinie" RENAME TO "delete_to_RP_AchseLinie";

-- -----------------------------------------------------
-- Table "RP_Siedlungsstruktur"."RP_AchseFlaeche"
-- -----------------------------------------------------
CREATE TABLE "RP_Siedlungsstruktur"."RP_AchseFlaeche" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid"),
  CONSTRAINT "fk_RP_AchseFlaeche_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "RP_Siedlungsstruktur"."RP_Achse" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("RP_Basisobjekte"."RP_Flaechenobjekt");

GRANT SELECT ON TABLE "RP_Siedlungsstruktur"."RP_AchseFlaeche" TO xp_gast;
GRANT ALL ON TABLE "RP_Siedlungsstruktur"."RP_AchseFlaeche" TO rp_user;
CREATE INDEX "RP_AchseFlaeche_gidx" ON "RP_Siedlungsstruktur"."RP_AchseFlaeche" using gist ("position");
CREATE TRIGGER "change_to_RP_AchseFlaeche" BEFORE INSERT OR UPDATE ON "RP_Siedlungsstruktur"."RP_AchseFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_AchseFlaeche" AFTER DELETE ON "RP_Siedlungsstruktur"."RP_AchseFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "RP_AchseFlaeche_Flaechenobjekt" BEFORE INSERT OR UPDATE ON "RP_Siedlungsstruktur"."RP_AchseFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."positionFollowsRHR"();

-- -----------------------------------------------------
-- Table "RP_Siedlungsstruktur"."RP_AchsePunkt"
-- -----------------------------------------------------
CREATE TABLE "RP_Siedlungsstruktur"."RP_AchsePunkt" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid"),
  CONSTRAINT "fk_RP_AchsePunkt_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "RP_Siedlungsstruktur"."RP_Achse" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("RP_Basisobjekte"."RP_Punktobjekt");

GRANT SELECT ON TABLE "RP_Siedlungsstruktur"."RP_AchsePunkt" TO xp_gast;
GRANT ALL ON TABLE "RP_Siedlungsstruktur"."RP_AchsePunkt" TO rp_user;
CREATE INDEX "RP_AchsePunkt_gidx" ON "RP_Siedlungsstruktur"."RP_AchsePunkt" using gist ("position");
CREATE TRIGGER "change_to_RP_AchsePunkt" BEFORE INSERT OR UPDATE ON "RP_Siedlungsstruktur"."RP_AchsePunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_AchsePunkt" AFTER DELETE ON "RP_Siedlungsstruktur"."RP_AchsePunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- RP_GemeindeFunktionSiedlungsentwicklung -> RP_Funktionszuweisung
ALTER TABLE "RP_Siedlungsstruktur"."RP_Gemeindefunktionen" RENAME TO "RP_FunktionszuweisungTypen";
UPDATE "RP_Siedlungsstruktur"."RP_FunktionszuweisungTypen" SET "Bezeichner" = 'Arbeit' WHERE "Code" = 2000;
UPDATE "RP_Siedlungsstruktur"."RP_FunktionszuweisungTypen" SET "Code" = 7000 WHERE "Code" = 6000;
UPDATE "RP_Siedlungsstruktur"."RP_FunktionszuweisungTypen" SET "Code" = 6000 WHERE "Code" = 5000;
UPDATE "RP_Siedlungsstruktur"."RP_FunktionszuweisungTypen" SET "Code" = 5000 WHERE "Code" = 3000;
INSERT INTO "RP_Siedlungsstruktur"."RP_FunktionszuweisungTypen"("Code","Bezeichner") VALUES ('3000','GewerbeDienstleistung');
INSERT INTO "RP_Siedlungsstruktur"."RP_FunktionszuweisungTypen"("Code","Bezeichner") VALUES ('8000','UeberoertlicheVersorgungsfunktionLaendlicherRaum');
ALTER TABLE "RP_Siedlungsstruktur"."RP_GemeindeFunktionSiedlungsentwicklung" RENAME TO "RP_Funktionszuweisung";
COMMENT ON TABLE "RP_Siedlungsstruktur"."RP_Funktionszuweisung" IS 'Gebiets- und Gemeindefunktionen.';
ALTER TABLE "RP_Siedlungsstruktur"."RP_Funktionszuweisung" RENAME CONSTRAINT "fk_RP_GemeindeFunktionSiedlungsentwicklung_parent" TO "fk_RP_Funktionszuweisung_parent";
ALTER TABLE "RP_Siedlungsstruktur"."RP_GemeindeFunktionSiedlungsentwicklungFlaeche" RENAME TO "RP_FunktionszuweisungFlaeche";
ALTER TABLE "RP_Siedlungsstruktur"."RP_FunktionszuweisungFlaeche" RENAME CONSTRAINT "fk_RP_GemeindeFunktionSiedlungsentwicklungFlaeche_parent" TO "fk_RP_FunktionszuweisungFlaeche_parent";
ALTER TABLE "RP_Siedlungsstruktur"."RP_GemeindeFunktionSiedlungsentwicklungLinie" RENAME TO "RP_FunktionszuweisungLinie";
ALTER TABLE "RP_Siedlungsstruktur"."RP_FunktionszuweisungLinie" RENAME CONSTRAINT "fk_RP_GemeindeFunktionSiedlungsentwicklungLinie_parent" TO "fk_RP_FunktionszuweisungLinie_parent";
ALTER TABLE "RP_Siedlungsstruktur"."RP_GemeindeFunktionSiedlungsentwicklungPunkt" RENAME TO "RP_FunktionszuweisungPunkt";
ALTER TABLE "RP_Siedlungsstruktur"."RP_FunktionszuweisungPunkt" RENAME CONSTRAINT "fk_RP_GemeindeFunktionSiedlungsentwicklungPunkt_parent" TO "fk_RP_FunktionszuweisungPunkt_parent";
ALTER TABLE "RP_Siedlungsstruktur"."RP_GemeindeFunktionSiedlungsentwicklung_funktion" RENAME TO "RP_Funktionszuweisung_typ";
ALTER TABLE "RP_Siedlungsstruktur"."RP_Funktionszuweisung_typ" RENAME "RP_GemeindeFunktionSiedlungsentwicklung_gid" TO "RP_Funktionszuweisung_gid";
COMMENT ON TABLE "RP_Siedlungsstruktur"."RP_Funktionszuweisung_typ" IS 'Klassifikation des Gebietes nach Bundesraumordnungsgesetz.';
ALTER TABLE "RP_Siedlungsstruktur"."RP_Funktionszuweisung" ADD COLUMN "bezeichnung" VARCHAR(256);
COMMENT ON COLUMN "RP_Siedlungsstruktur"."RP_Funktionszuweisung"."bezeichnung" IS 'Bezeichnung und/oder Erörterung einer Gebietsfunktion.';
ALTER TRIGGER "change_to_RP_GemeindeFunktionSiedlungsentwicklung" ON "RP_Siedlungsstruktur"."RP_Funktionszuweisung" RENAME TO "change_to_RP_Funktionszuweisung";
ALTER TRIGGER "delete_RP_GemeindeFunktionSiedlungsentwicklung" ON "RP_Siedlungsstruktur"."RP_Funktionszuweisung" RENAME TO "delete_to_RP_Funktionszuweisung";
ALTER TRIGGER "change_to_RP_GemeindeFunktionSiedlungsentwicklungFlaeche" ON "RP_Siedlungsstruktur"."RP_FunktionszuweisungFlaeche" RENAME TO "change_to_RP_FunktionszuweisungFlaeche";
ALTER TRIGGER "delete_RP_GemeindeFunktionSiedlungsentwicklungFlaeche" ON "RP_Siedlungsstruktur"."RP_FunktionszuweisungFlaeche" RENAME TO "delete_to_RP_FunktionszuweisungFlaeche";
ALTER TRIGGER "change_to_RP_GemeindeFunktionSiedlungsentwicklungLinie" ON "RP_Siedlungsstruktur"."RP_FunktionszuweisungLinie" RENAME TO "change_to_RP_FunktionszuweisungLinie";
ALTER TRIGGER "delete_RP_GemeindeFunktionSiedlungsentwicklungLinie" ON "RP_Siedlungsstruktur"."RP_FunktionszuweisungLinie" RENAME TO "delete_to_RP_FunktionszuweisungLinie";
ALTER TRIGGER "change_to_RP_GemeindeFunktionSiedlungsentwicklungPunkt" ON "RP_Siedlungsstruktur"."RP_FunktionszuweisungPunkt" RENAME TO "change_to_RP_FunktionszuweisungPunkt";
ALTER TRIGGER "delete_RP_GemeindeFunktionSiedlungsentwicklungPunkt" ON "RP_Siedlungsstruktur"."RP_FunktionszuweisungPunkt" RENAME TO "delete_to_RP_FunktionszuweisungPunkt";

-- RP_Raumkategorie
-- -----------------------------------------------------
-- Table "RP_Siedlungsstruktur"."RP_RaumkategorieTypen"
-- -----------------------------------------------------
CREATE TABLE "RP_Siedlungsstruktur"."RP_RaumkategorieTypen" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Code") );
GRANT SELECT ON TABLE "RP_Siedlungsstruktur"."RP_RaumkategorieTypen" TO xp_gast;

INSERT INTO "RP_Siedlungsstruktur"."RP_RaumkategorieTypen" ("Code", "Bezeichner") VALUES ('1000', 'Ordnungsraum');
INSERT INTO "RP_Siedlungsstruktur"."RP_RaumkategorieTypen" ("Code", "Bezeichner") VALUES ('1001', 'OrdnungsraumTourismusErholung');
INSERT INTO "RP_Siedlungsstruktur"."RP_RaumkategorieTypen" ("Code", "Bezeichner") VALUES ('1100', 'Verdichtungsraum');
INSERT INTO "RP_Siedlungsstruktur"."RP_RaumkategorieTypen" ("Code", "Bezeichner") VALUES ('1101', 'KernzoneVerdichtungsraum');
INSERT INTO "RP_Siedlungsstruktur"."RP_RaumkategorieTypen" ("Code", "Bezeichner") VALUES ('1102', 'RandzoneVerdichtungsraum');
INSERT INTO "RP_Siedlungsstruktur"."RP_RaumkategorieTypen" ("Code", "Bezeichner") VALUES ('1103', 'Ballungskernzone');
INSERT INTO "RP_Siedlungsstruktur"."RP_RaumkategorieTypen" ("Code", "Bezeichner") VALUES ('1104', 'Ballungsrandzone');
INSERT INTO "RP_Siedlungsstruktur"."RP_RaumkategorieTypen" ("Code", "Bezeichner") VALUES ('1105', 'HochverdichteterRaum');
INSERT INTO "RP_Siedlungsstruktur"."RP_RaumkategorieTypen" ("Code", "Bezeichner") VALUES ('1106', 'StadtUmlandBereichVerdichtungsraum');
INSERT INTO "RP_Siedlungsstruktur"."RP_RaumkategorieTypen" ("Code", "Bezeichner") VALUES ('1200', 'LaendlicherRaum');
INSERT INTO "RP_Siedlungsstruktur"."RP_RaumkategorieTypen" ("Code", "Bezeichner") VALUES ('1201', 'VerdichteterBereichimLaendlichenRaum');
INSERT INTO "RP_Siedlungsstruktur"."RP_RaumkategorieTypen" ("Code", "Bezeichner") VALUES ('1202', 'Gestaltungsraum');
INSERT INTO "RP_Siedlungsstruktur"."RP_RaumkategorieTypen" ("Code", "Bezeichner") VALUES ('1203', 'LaendlicherGestaltungsraum');
INSERT INTO "RP_Siedlungsstruktur"."RP_RaumkategorieTypen" ("Code", "Bezeichner") VALUES ('1300', 'StadtUmlandRaum');
INSERT INTO "RP_Siedlungsstruktur"."RP_RaumkategorieTypen" ("Code", "Bezeichner") VALUES ('1301', 'StadtUmlandBereichLaendlicherRaum');
INSERT INTO "RP_Siedlungsstruktur"."RP_RaumkategorieTypen" ("Code", "Bezeichner") VALUES ('1400', 'AbgrenzungOrdnungsraum');
INSERT INTO "RP_Siedlungsstruktur"."RP_RaumkategorieTypen" ("Code", "Bezeichner") VALUES ('1500', 'DuennbesiedeltesAbgelegenesGebiet');
INSERT INTO "RP_Siedlungsstruktur"."RP_RaumkategorieTypen" ("Code", "Bezeichner") VALUES ('1600', 'Umkreis10KM');
INSERT INTO "RP_Siedlungsstruktur"."RP_RaumkategorieTypen" ("Code", "Bezeichner") VALUES ('1700', 'RaummitbesonderemHandlungsbedarf');
INSERT INTO "RP_Siedlungsstruktur"."RP_RaumkategorieTypen" ("Code", "Bezeichner") VALUES ('1800', 'Funktionsraum');
INSERT INTO "RP_Siedlungsstruktur"."RP_RaumkategorieTypen" ("Code", "Bezeichner") VALUES ('1900', 'GrenzeWirtschaftsraum');
INSERT INTO "RP_Siedlungsstruktur"."RP_RaumkategorieTypen" ("Code", "Bezeichner") VALUES ('2000', 'Funktionsschwerpunkt');
INSERT INTO "RP_Siedlungsstruktur"."RP_RaumkategorieTypen" ("Code", "Bezeichner") VALUES ('2100', 'Grundversorgung');
INSERT INTO "RP_Siedlungsstruktur"."RP_RaumkategorieTypen" ("Code", "Bezeichner") VALUES ('2200', 'Alpengebiet');
INSERT INTO "RP_Siedlungsstruktur"."RP_RaumkategorieTypen" ("Code", "Bezeichner") VALUES ('2300', 'RaeumeMitGuenstigenEntwicklungsvoraussetzungen');
INSERT INTO "RP_Siedlungsstruktur"."RP_RaumkategorieTypen" ("Code", "Bezeichner") VALUES ('2400', 'RaeumeMitAusgeglichenenEntwicklungspotenzialen');
INSERT INTO "RP_Siedlungsstruktur"."RP_RaumkategorieTypen" ("Code", "Bezeichner") VALUES ('2500', 'RaeumeMitBesonderenEntwicklungsaufgaben');
INSERT INTO "RP_Siedlungsstruktur"."RP_RaumkategorieTypen" ("Code", "Bezeichner") VALUES ('9999', 'SonstigeRaumkategorie');

-- -----------------------------------------------------
-- Table "RP_Siedlungsstruktur"."RP_BesondereRaumkategorieTypen"
-- -----------------------------------------------------
CREATE TABLE "RP_Siedlungsstruktur"."RP_BesondereRaumkategorieTypen" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Code") );
GRANT SELECT ON TABLE "RP_Siedlungsstruktur"."RP_BesondereRaumkategorieTypen" TO xp_gast;

INSERT INTO "RP_Siedlungsstruktur"."RP_BesondereRaumkategorieTypen" ("Code", "Bezeichner") VALUES ('1000', 'Grenzgebiet');
INSERT INTO "RP_Siedlungsstruktur"."RP_BesondereRaumkategorieTypen" ("Code", "Bezeichner") VALUES ('2000', 'Bergbaufolgelandschaft');
INSERT INTO "RP_Siedlungsstruktur"."RP_BesondereRaumkategorieTypen" ("Code", "Bezeichner") VALUES ('3000', 'Braunkohlenfolgelandschaft');

-- -----------------------------------------------------
-- Table "RP_Siedlungsstruktur"."RP_Raumkategorie"
-- -----------------------------------------------------
CREATE TABLE "RP_Siedlungsstruktur"."RP_Raumkategorie" (
  "gid" BIGINT NOT NULL ,
  "besondererTyp" INTEGER,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_RP_Raumkategorie_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "RP_Basisobjekte"."RP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_RP_Raumkategorie_besondererTyp"
    FOREIGN KEY ("besondererTyp" )
    REFERENCES "RP_Siedlungsstruktur"."RP_BesondereRaumkategorieTypen" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE);

GRANT SELECT ON TABLE "RP_Siedlungsstruktur"."RP_Raumkategorie" TO xp_gast;
GRANT ALL ON TABLE "RP_Siedlungsstruktur"."RP_Raumkategorie" TO rp_user;
COMMENT ON TABLE "RP_Siedlungsstruktur"."RP_Raumkategorie" IS 'Raumkategorien sind nach bestimmten Kriterien abgegrenze Gebiete, in denen vergleichbare Strukturen bestehen und in denen die Raumordnung gleichartige Ziele verfolgt. Kriterien können z.B. siedlungsstrukturell, qualitativ oder potentialorientiert sein.';
COMMENT ON COLUMN "RP_Siedlungsstruktur"."RP_Raumkategorie"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';

INSERT INTO "RP_Siedlungsstruktur"."RP_Raumkategorie" (gid) SELECT gid FROM "RP_Siedlungsstruktur"."RP_RaumkategorieFlaeche";
INSERT INTO "RP_Siedlungsstruktur"."RP_Raumkategorie" (gid) SELECT gid FROM "RP_Siedlungsstruktur"."RP_RaumkategorieLinie";
INSERT INTO "RP_Siedlungsstruktur"."RP_Raumkategorie" (gid) SELECT gid FROM "RP_Siedlungsstruktur"."RP_RaumkategoriePunkt";

CREATE TRIGGER "change_to_RP_Raumkategorie" BEFORE INSERT OR UPDATE ON "RP_Siedlungsstruktur"."RP_Raumkategorie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_Raumkategorie" AFTER DELETE ON "RP_Siedlungsstruktur"."RP_Raumkategorie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "RP_Siedlungsstruktur"."RP_Raumkategorie_typ"
-- -----------------------------------------------------
CREATE TABLE "RP_Siedlungsstruktur"."RP_Raumkategorie_typ" (
  "RP_Raumkategorie_gid" BIGINT NOT NULL,
  "typ" INTEGER NOT NULL,
  PRIMARY KEY ("RP_Raumkategorie_gid", "typ"),
  CONSTRAINT "fk_RP_Raumkategorie_typ1"
    FOREIGN KEY ("RP_Raumkategorie_gid")
    REFERENCES "RP_Siedlungsstruktur"."RP_Raumkategorie" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_RP_Raumkategorie_typ2"
    FOREIGN KEY ("typ")
    REFERENCES "RP_Siedlungsstruktur"."RP_RaumkategorieTypen" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
COMMENT ON TABLE "RP_Siedlungsstruktur"."RP_Raumkategorie_typ" IS 'Klassifikation verschiedener Raumkategorien.';
GRANT SELECT ON TABLE "RP_Siedlungsstruktur"."RP_Raumkategorie_typ" TO xp_gast;
GRANT ALL ON TABLE "RP_Siedlungsstruktur"."RP_Raumkategorie_typ" TO rp_user;

ALTER TABLE "RP_Siedlungsstruktur"."RP_RaumkategorieFlaeche" DROP CONSTRAINT "fk_RP_RaumkategorieFlaeche_parent";
ALTER TABLE "RP_Siedlungsstruktur"."RP_RaumkategorieFlaeche" ADD CONSTRAINT "fk_RP_RaumkategorieFlaeche_parent" FOREIGN KEY ("gid" )
    REFERENCES "RP_Siedlungsstruktur"."RP_Raumkategorie" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE;
ALTER TABLE "RP_Siedlungsstruktur"."RP_RaumkategorieLinie" DROP CONSTRAINT "fk_RP_RaumkategorieLinie_parent";
ALTER TABLE "RP_Siedlungsstruktur"."RP_RaumkategorieLinie" ADD CONSTRAINT "fk_RP_RaumkategorieLinie_parent" FOREIGN KEY ("gid" )
    REFERENCES "RP_Siedlungsstruktur"."RP_Raumkategorie" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE;
ALTER TABLE "RP_Siedlungsstruktur"."RP_RaumkategoriePunkt" DROP CONSTRAINT "fk_RP_RaumkategoriePunkt_parent";
ALTER TABLE "RP_Siedlungsstruktur"."RP_RaumkategoriePunkt" ADD CONSTRAINT "fk_RP_RaumkategoriePunkt_parent" FOREIGN KEY ("gid" )
    REFERENCES "RP_Siedlungsstruktur"."RP_Raumkategorie" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE;

-- -----------------------------------------------------
-- Table "RP_Siedlungsstruktur"."RP_SperrgebietTypen"
-- -----------------------------------------------------
CREATE TABLE "RP_Siedlungsstruktur"."RP_SperrgebietTypen" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Code") );
GRANT SELECT ON TABLE "RP_Siedlungsstruktur"."RP_SperrgebietTypen" TO xp_gast;

INSERT INTO "RP_Siedlungsstruktur"."RP_SperrgebietTypen" ("Code", "Bezeichner") VALUES ('1000', 'Verteidigung');
INSERT INTO "RP_Siedlungsstruktur"."RP_SperrgebietTypen" ("Code", "Bezeichner") VALUES ('2000', 'SondergebietBund');
INSERT INTO "RP_Siedlungsstruktur"."RP_SperrgebietTypen" ("Code", "Bezeichner") VALUES ('3000', 'Warngebiet');
INSERT INTO "RP_Siedlungsstruktur"."RP_SperrgebietTypen" ("Code", "Bezeichner") VALUES ('4000', 'MilitaerischeEinrichtung');
INSERT INTO "RP_Siedlungsstruktur"."RP_SperrgebietTypen" ("Code", "Bezeichner") VALUES ('4001', 'GrosseMilitaerischeAnlage');
INSERT INTO "RP_Siedlungsstruktur"."RP_SperrgebietTypen" ("Code", "Bezeichner") VALUES ('5000', 'MilitaerischeLiegenschaft');
INSERT INTO "RP_Siedlungsstruktur"."RP_SperrgebietTypen" ("Code", "Bezeichner") VALUES ('6000', 'Konversionsflaeche');
INSERT INTO "RP_Siedlungsstruktur"."RP_SperrgebietTypen" ("Code", "Bezeichner") VALUES ('9999', 'SonstigesSperrgebiet');

-- -----------------------------------------------------
-- Table "RP_Siedlungsstruktur"."RP_Sperrgebiet"
-- -----------------------------------------------------
CREATE TABLE "RP_Siedlungsstruktur"."RP_Sperrgebiet" (
  "gid" BIGINT NOT NULL ,
  "typ" INTEGER,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_RP_Sperrgebiet_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "RP_Basisobjekte"."RP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_RP_Sperrgebiet_Typen"
    FOREIGN KEY ("typ" )
    REFERENCES "RP_Siedlungsstruktur"."RP_SperrgebietTypen" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE);

GRANT SELECT ON TABLE "RP_Siedlungsstruktur"."RP_Sperrgebiet" TO xp_gast;
GRANT ALL ON TABLE "RP_Siedlungsstruktur"."RP_Sperrgebiet" TO rp_user;
COMMENT ON TABLE "RP_Siedlungsstruktur"."RP_Sperrgebiet" IS 'Sperrgebiet, Gelände oder Areal, das für die Zivilbevölkerung überhaupt nicht oder zeitweise nicht zugänglich ist.';
COMMENT ON COLUMN "RP_Siedlungsstruktur"."RP_Sperrgebiet"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN "RP_Siedlungsstruktur"."RP_Sperrgebiet"."typ" IS 'Klassifikation verschiedener Sperrgebiettypen.';

INSERT INTO "RP_Siedlungsstruktur"."RP_Sperrgebiet" (gid) SELECT gid FROM "RP_Siedlungsstruktur"."RP_SperrgebietFlaeche";
INSERT INTO "RP_Siedlungsstruktur"."RP_Sperrgebiet" (gid) SELECT gid FROM "RP_Siedlungsstruktur"."RP_SperrgebietLinie";
INSERT INTO "RP_Siedlungsstruktur"."RP_Sperrgebiet" (gid) SELECT gid FROM "RP_Siedlungsstruktur"."RP_SperrgebietPunkt";

CREATE TRIGGER "change_to_RP_Sperrgebiet" BEFORE INSERT OR UPDATE ON "RP_Siedlungsstruktur"."RP_Sperrgebiet" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_Sperrgebiet" AFTER DELETE ON "RP_Siedlungsstruktur"."RP_Sperrgebiet" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

ALTER TABLE "RP_Siedlungsstruktur"."RP_SperrgebietFlaeche" DROP CONSTRAINT "fk_RP_SperrgebietFlaeche_parent";
ALTER TABLE "RP_Siedlungsstruktur"."RP_SperrgebietFlaeche" ADD CONSTRAINT "fk_RP_SperrgebietFlaeche_parent" FOREIGN KEY ("gid" )
    REFERENCES "RP_Siedlungsstruktur"."RP_Sperrgebiet" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE;
ALTER TABLE "RP_Siedlungsstruktur"."RP_SperrgebietLinie" DROP CONSTRAINT "fk_RP_SperrgebietLinie_parent";
ALTER TABLE "RP_Siedlungsstruktur"."RP_SperrgebietLinie" ADD CONSTRAINT "fk_RP_SperrgebietLinie_parent" FOREIGN KEY ("gid" )
    REFERENCES "RP_Siedlungsstruktur"."RP_Sperrgebiet" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE;
ALTER TABLE "RP_Siedlungsstruktur"."RP_SperrgebietPunkt" DROP CONSTRAINT "fk_RP_SperrgebietPunkt_parent";
ALTER TABLE "RP_Siedlungsstruktur"."RP_SperrgebietPunkt" ADD CONSTRAINT "fk_RP_SperrgebietPunkt_parent" FOREIGN KEY ("gid" )
    REFERENCES "RP_Siedlungsstruktur"."RP_Sperrgebiet" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE;

-- RP_ZentralerOrt
ALTER TABLE "RP_Siedlungsstruktur"."RP_ZentralerOrtFunktionen" RENAME TO "RP_ZentralerOrtTypen";
UPDATE "RP_Siedlungsstruktur"."RP_ZentralerOrtTypen" SET "Bezeichner" = 'SonstigerZentralerOrt' WHERE "Code" = 9999;
INSERT INTO "RP_Siedlungsstruktur"."RP_ZentralerOrtTypen" ("Code", "Bezeichner") VALUES ('1001', 'GemeinsamesOberzentrum');
INSERT INTO "RP_Siedlungsstruktur"."RP_ZentralerOrtTypen" ("Code", "Bezeichner") VALUES ('1500', 'Oberbereich');
INSERT INTO "RP_Siedlungsstruktur"."RP_ZentralerOrtTypen" ("Code", "Bezeichner") VALUES ('2500', 'Mittelbereich');
INSERT INTO "RP_Siedlungsstruktur"."RP_ZentralerOrtTypen" ("Code", "Bezeichner") VALUES ('3001', 'Unterzentrum');
INSERT INTO "RP_Siedlungsstruktur"."RP_ZentralerOrtTypen" ("Code", "Bezeichner") VALUES ('3500', 'Nahbereich');
INSERT INTO "RP_Siedlungsstruktur"."RP_ZentralerOrtTypen" ("Code", "Bezeichner") VALUES ('5000', 'LaendlicherZentralort');
INSERT INTO "RP_Siedlungsstruktur"."RP_ZentralerOrtTypen" ("Code", "Bezeichner") VALUES ('6000', 'Stadtrandkern1Ordnung');
INSERT INTO "RP_Siedlungsstruktur"."RP_ZentralerOrtTypen" ("Code", "Bezeichner") VALUES ('6001', 'Stadtrandkern2Ordnung');
INSERT INTO "RP_Siedlungsstruktur"."RP_ZentralerOrtTypen" ("Code", "Bezeichner") VALUES ('7000', 'VersorgungskernSiedlungskern');
INSERT INTO "RP_Siedlungsstruktur"."RP_ZentralerOrtTypen" ("Code", "Bezeichner") VALUES ('8000', 'ZentralesSiedlungsgebiet');
INSERT INTO "RP_Siedlungsstruktur"."RP_ZentralerOrtTypen" ("Code", "Bezeichner") VALUES ('9000', 'Metropole');

-- -----------------------------------------------------
-- Table "RP_Siedlungsstruktur"."RP_ZentralerOrtSonstigeTypen"
-- -----------------------------------------------------
CREATE TABLE "RP_Siedlungsstruktur"."RP_ZentralerOrtSonstigeTypen" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Code") );
GRANT SELECT ON TABLE "RP_Siedlungsstruktur"."RP_ZentralerOrtSonstigeTypen" TO xp_gast;

INSERT INTO "RP_Siedlungsstruktur"."RP_ZentralerOrtSonstigeTypen" ("Code", "Bezeichner") VALUES ('1000', 'Doppelzentrum');
INSERT INTO "RP_Siedlungsstruktur"."RP_ZentralerOrtSonstigeTypen" ("Code", "Bezeichner") VALUES ('1100', 'Funktionsteilig');
INSERT INTO "RP_Siedlungsstruktur"."RP_ZentralerOrtSonstigeTypen" ("Code", "Bezeichner") VALUES ('1101', 'MitOberzentralerTeilfunktion');
INSERT INTO "RP_Siedlungsstruktur"."RP_ZentralerOrtSonstigeTypen" ("Code", "Bezeichner") VALUES ('1102', 'MitMittelzentralerTeilfunktion');
INSERT INTO "RP_Siedlungsstruktur"."RP_ZentralerOrtSonstigeTypen" ("Code", "Bezeichner") VALUES ('1200', 'ImVerbund');
INSERT INTO "RP_Siedlungsstruktur"."RP_ZentralerOrtSonstigeTypen" ("Code", "Bezeichner") VALUES ('1300', 'Kooperierend');
INSERT INTO "RP_Siedlungsstruktur"."RP_ZentralerOrtSonstigeTypen" ("Code", "Bezeichner") VALUES ('1301', 'KooperierendFreiwillig');
INSERT INTO "RP_Siedlungsstruktur"."RP_ZentralerOrtSonstigeTypen" ("Code", "Bezeichner") VALUES ('1302', 'KooperierendVerpflichtend');
INSERT INTO "RP_Siedlungsstruktur"."RP_ZentralerOrtSonstigeTypen" ("Code", "Bezeichner") VALUES ('1400', 'ImVerdichtungsraum');
INSERT INTO "RP_Siedlungsstruktur"."RP_ZentralerOrtSonstigeTypen" ("Code", "Bezeichner") VALUES ('1500', 'SiedlungsGrundnetz');
INSERT INTO "RP_Siedlungsstruktur"."RP_ZentralerOrtSonstigeTypen" ("Code", "Bezeichner") VALUES ('1501', 'SiedlungsErgaenzungsnetz');
INSERT INTO "RP_Siedlungsstruktur"."RP_ZentralerOrtSonstigeTypen" ("Code", "Bezeichner") VALUES ('1600', 'Entwicklungsschwerpunkt');
INSERT INTO "RP_Siedlungsstruktur"."RP_ZentralerOrtSonstigeTypen" ("Code", "Bezeichner") VALUES ('1700', 'Ueberschneidungsbereich');
INSERT INTO "RP_Siedlungsstruktur"."RP_ZentralerOrtSonstigeTypen" ("Code", "Bezeichner") VALUES ('1800', 'Ergaenzungsfunktion');
INSERT INTO "RP_Siedlungsstruktur"."RP_ZentralerOrtSonstigeTypen" ("Code", "Bezeichner") VALUES ('1900', 'Nachbar');
INSERT INTO "RP_Siedlungsstruktur"."RP_ZentralerOrtSonstigeTypen" ("Code", "Bezeichner") VALUES ('2000', 'MoeglichesZentrum');
INSERT INTO "RP_Siedlungsstruktur"."RP_ZentralerOrtSonstigeTypen" ("Code", "Bezeichner") VALUES ('2100', 'FunktionsraumEindeutigeAusrichtung');
INSERT INTO "RP_Siedlungsstruktur"."RP_ZentralerOrtSonstigeTypen" ("Code", "Bezeichner") VALUES ('2101', 'FunktionsraumBilateraleAusrichtung');
INSERT INTO "RP_Siedlungsstruktur"."RP_ZentralerOrtSonstigeTypen" ("Code", "Bezeichner") VALUES ('9999', 'SonstigeSonstigerZentralerOrt');

-- -----------------------------------------------------
-- Table "RP_Siedlungsstruktur"."RP_ZentralerOrt_typ"
-- -----------------------------------------------------
CREATE TABLE "RP_Siedlungsstruktur"."RP_ZentralerOrt_typ" (
  "RP_ZentralerOrt_gid" BIGINT NOT NULL,
  "typ" INTEGER NOT NULL,
  PRIMARY KEY ("RP_ZentralerOrt_gid", "typ"),
  CONSTRAINT "fk_RP_ZentralerOrt_typ1"
    FOREIGN KEY ("RP_ZentralerOrt_gid")
    REFERENCES "RP_Siedlungsstruktur"."RP_ZentralerOrt" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_RP_ZentralerOrt_typ2"
    FOREIGN KEY ("typ")
    REFERENCES "RP_Siedlungsstruktur"."RP_ZentralerOrtTypen" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
COMMENT ON TABLE "RP_Siedlungsstruktur"."RP_ZentralerOrt_typ" IS 'Klassifikation von Zentralen Orten.';
GRANT SELECT ON TABLE "RP_Siedlungsstruktur"."RP_ZentralerOrt_typ" TO xp_gast;
GRANT ALL ON TABLE "RP_Siedlungsstruktur"."RP_ZentralerOrt_typ" TO rp_user;

-- -----------------------------------------------------
-- Table "RP_Siedlungsstruktur"."RP_ZentralerOrt_sonstigerTyp"
-- -----------------------------------------------------
CREATE TABLE "RP_Siedlungsstruktur"."RP_ZentralerOrt_sonstigerTyp" (
  "RP_ZentralerOrt_gid" BIGINT NOT NULL,
  "sonstigerTyp" INTEGER NOT NULL,
  PRIMARY KEY ("RP_ZentralerOrt_gid", "sonstigerTyp"),
  CONSTRAINT "fk_RP_ZentralerOrt_sonstigerTyp1"
    FOREIGN KEY ("RP_ZentralerOrt_gid")
    REFERENCES "RP_Siedlungsstruktur"."RP_ZentralerOrt" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_RP_ZentralerOrt_sonstigerTyp2"
    FOREIGN KEY ("sonstigerTyp")
    REFERENCES "RP_Siedlungsstruktur"."RP_ZentralerOrtSonstigeTypen" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
COMMENT ON TABLE "RP_Siedlungsstruktur"."RP_ZentralerOrt_sonstigerTyp" IS 'Sonstige Klassifikation von Zentralen Orten.';
GRANT SELECT ON TABLE "RP_Siedlungsstruktur"."RP_ZentralerOrt_sonstigerTyp" TO xp_gast;
GRANT ALL ON TABLE "RP_Siedlungsstruktur"."RP_ZentralerOrt_sonstigerTyp" TO rp_user;

-- RP_SonstigeSiedlungsstruktur -> RP_Siedlung
-- und neue Ableitungen davon
ALTER TABLE "RP_Siedlungsstruktur"."RP_SonstigeSiedlungsstruktur" RENAME TO "RP_Siedlung";
ALTER TABLE "RP_Siedlungsstruktur"."RP_Siedlung" RENAME CONSTRAINT "fk_RP_SonstigeSiedlungsstruktur_parent" TO "fk_RP_Siedlung_parent";
COMMENT ON TABLE "RP_Siedlungsstruktur"."RP_Siedlung" IS 'Allgemeines Siedlungsobjekt. Dieses vererbt an mehrere Spezialisierungen, ist aber selbst nicht abstrakt.';
ALTER TABLE "RP_Siedlungsstruktur"."RP_Siedlung" ADD COLUMN "bauhoehenbeschraenkung" INTEGER;
COMMENT ON COLUMN "RP_Siedlungsstruktur"."RP_Siedlung"."bauhoehenbeschraenkung" IS 'Assoziierte Bauhöhenbeschränkung.';
ALTER TABLE "RP_Siedlungsstruktur"."RP_Siedlung" ADD COLUMN "istSiedlungsbeschraenkung" BOOLEAN;
COMMENT ON COLUMN "RP_Siedlungsstruktur"."RP_Siedlung"."istSiedlungsbeschraenkung" IS 'Abfrage, ob der FeatureType eine Siedlungsbeschränkung ist.';
ALTER TABLE "RP_Siedlungsstruktur"."RP_SonstigeSiedlungsstrukturFlaeche" RENAME TO "RP_SiedlungFlaeche";
ALTER TABLE "RP_Siedlungsstruktur"."RP_SiedlungFlaeche" RENAME CONSTRAINT "fk_RP_SonstigeSiedlungsstrukturFlaeche_parent" TO "fk_RP_SiedlungFlaeche_parent";
ALTER TABLE "RP_Siedlungsstruktur"."RP_SonstigeSiedlungsstrukturLinie" RENAME TO "RP_SiedlungLinie";
ALTER TABLE "RP_Siedlungsstruktur"."RP_SiedlungLinie" RENAME CONSTRAINT "fk_RP_SonstigeSiedlungsstrukturLinie_parent" TO "fk_RP_SiedlungLinie_parent";
ALTER TABLE "RP_Siedlungsstruktur"."RP_SonstigeSiedlungsstrukturPunkt" RENAME TO "RP_SiedlungPunkt";
ALTER TABLE "RP_Siedlungsstruktur"."RP_SiedlungPunkt" RENAME CONSTRAINT "fk_RP_SonstigeSiedlungsstrukturPunkt_parent" TO "fk_RP_SiedlungPunkt_parent";
ALTER TRIGGER "change_to_RP_SonstigeSiedlungsstruktur" ON "RP_Siedlungsstruktur"."RP_Siedlung" RENAME TO "change_to_RP_Siedlung";
ALTER TRIGGER "delete_RP_SonstigeSiedlungsstruktur" ON "RP_Siedlungsstruktur"."RP_Siedlung" RENAME TO "delete_to_RP_Siedlung";
ALTER TRIGGER "change_to_RP_SonstigeSiedlungsstrukturFlaeche" ON "RP_Siedlungsstruktur"."RP_SiedlungFlaeche" RENAME TO "change_to_RP_SiedlungFlaeche";
ALTER TRIGGER "delete_RP_SonstigeSiedlungsstrukturFlaeche" ON "RP_Siedlungsstruktur"."RP_SiedlungFlaeche" RENAME TO "delete_to_RP_SiedlungFlaeche";
ALTER TRIGGER "change_to_RP_SonstigeSiedlungsstrukturLinie" ON "RP_Siedlungsstruktur"."RP_SiedlungLinie" RENAME TO "change_to_RP_SiedlungLinie";
ALTER TRIGGER "delete_RP_SonstigeSiedlungsstrukturLinie" ON "RP_Siedlungsstruktur"."RP_SiedlungLinie" RENAME TO "delete_to_RP_SiedlungLinie";
ALTER TRIGGER "change_to_RP_SonstigeSiedlungsstrukturPunkt" ON "RP_Siedlungsstruktur"."RP_SiedlungPunkt" RENAME TO "change_to_RP_SiedlungPunkt";
ALTER TRIGGER "delete_RP_SonstigeSiedlungsstrukturPunkt" ON "RP_Siedlungsstruktur"."RP_SiedlungPunkt" RENAME TO "delete_to_RP_SiedlungPunkt";
-- RP_Einzelhandel
-- -----------------------------------------------------
-- Table "RP_Siedlungsstruktur"."RP_EinzelhandelTypen"
-- -----------------------------------------------------
CREATE TABLE "RP_Siedlungsstruktur"."RP_EinzelhandelTypen" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Code") );
GRANT SELECT ON TABLE "RP_Siedlungsstruktur"."RP_EinzelhandelTypen" TO xp_gast;

INSERT INTO "RP_Siedlungsstruktur"."RP_EinzelhandelTypen" ("Code", "Bezeichner") VALUES ('1000', 'Einzelhandel');
INSERT INTO "RP_Siedlungsstruktur"."RP_EinzelhandelTypen" ("Code", "Bezeichner") VALUES ('2000', 'ZentralerVersorgungsbereich');
INSERT INTO "RP_Siedlungsstruktur"."RP_EinzelhandelTypen" ("Code", "Bezeichner") VALUES ('3000', 'ZentralerEinkaufsbereich');
INSERT INTO "RP_Siedlungsstruktur"."RP_EinzelhandelTypen" ("Code", "Bezeichner") VALUES ('4000', 'ZentrenrelevantesGrossprojekt');
INSERT INTO "RP_Siedlungsstruktur"."RP_EinzelhandelTypen" ("Code", "Bezeichner") VALUES ('5000', 'NichtzentrenrelevantesGrossprojekt');
INSERT INTO "RP_Siedlungsstruktur"."RP_EinzelhandelTypen" ("Code", "Bezeichner") VALUES ('6000', 'GrossflaechigerEinzelhandel');
INSERT INTO "RP_Siedlungsstruktur"."RP_EinzelhandelTypen" ("Code", "Bezeichner") VALUES ('7000', 'Fachmarktstandort');
INSERT INTO "RP_Siedlungsstruktur"."RP_EinzelhandelTypen" ("Code", "Bezeichner") VALUES ('8000', 'Ergaenzungsstandort');
INSERT INTO "RP_Siedlungsstruktur"."RP_EinzelhandelTypen" ("Code", "Bezeichner") VALUES ('9000', 'StaedtischerKernbereich');
INSERT INTO "RP_Siedlungsstruktur"."RP_EinzelhandelTypen" ("Code", "Bezeichner") VALUES ('9999', 'SonstigerEinzelhandel');

-- -----------------------------------------------------
-- Table "RP_Siedlungsstruktur"."RP_Einzelhandel"
-- -----------------------------------------------------
CREATE TABLE "RP_Siedlungsstruktur"."RP_Einzelhandel" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid"),
  CONSTRAINT "fk_RP_Einzelhandel_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "RP_Siedlungsstruktur"."RP_Siedlung" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE);

GRANT SELECT ON TABLE "RP_Siedlungsstruktur"."RP_Einzelhandel" TO xp_gast;
GRANT ALL ON TABLE "RP_Siedlungsstruktur"."RP_Einzelhandel" TO rp_user;
COMMENT ON TABLE "RP_Siedlungsstruktur"."RP_Einzelhandel" IS 'Einzelhandelsstruktur und -funktionen.';
COMMENT ON COLUMN "RP_Siedlungsstruktur"."RP_Einzelhandel"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_RP_Einzelhandel" BEFORE INSERT OR UPDATE ON "RP_Siedlungsstruktur"."RP_Einzelhandel" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_Einzelhandel" AFTER DELETE ON "RP_Siedlungsstruktur"."RP_Einzelhandel" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "RP_Siedlungsstruktur"."RP_Einzelhandel_typ"
-- -----------------------------------------------------
CREATE TABLE "RP_Siedlungsstruktur"."RP_Einzelhandel_typ" (
  "RP_Einzelhandel_gid" BIGINT NOT NULL,
  "typ" INTEGER NOT NULL,
  PRIMARY KEY ("RP_Einzelhandel_gid", "typ"),
  CONSTRAINT "fk_RP_Einzelhandel_typ1"
    FOREIGN KEY ("RP_Einzelhandel_gid")
    REFERENCES "RP_Siedlungsstruktur"."RP_Einzelhandel" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_RP_Einzelhandel_typ2"
    FOREIGN KEY ("typ")
    REFERENCES "RP_Siedlungsstruktur"."RP_EinzelhandelTypen" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
COMMENT ON TABLE "RP_Siedlungsstruktur"."RP_Einzelhandel_typ" IS 'Klassifikation von Einzelhandelstypen';
GRANT SELECT ON TABLE "RP_Siedlungsstruktur"."RP_Einzelhandel_typ" TO xp_gast;
GRANT ALL ON TABLE "RP_Siedlungsstruktur"."RP_Einzelhandel_typ" TO rp_user;

-- -----------------------------------------------------
-- Table "RP_Siedlungsstruktur"."RP_EinzelhandelFlaeche"
-- -----------------------------------------------------
CREATE TABLE "RP_Siedlungsstruktur"."RP_EinzelhandelFlaeche" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_RP_EinzelhandelFlaeche_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "RP_Siedlungsstruktur"."RP_Einzelhandel" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("RP_Basisobjekte"."RP_Flaechenobjekt");

GRANT SELECT ON TABLE "RP_Siedlungsstruktur"."RP_EinzelhandelFlaeche" TO xp_gast;
GRANT ALL ON TABLE "RP_Siedlungsstruktur"."RP_EinzelhandelFlaeche" TO rp_user;
COMMENT ON COLUMN "RP_Siedlungsstruktur"."RP_EinzelhandelFlaeche"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_RP_EinzelhandelFlaeche" BEFORE INSERT OR UPDATE ON "RP_Siedlungsstruktur"."RP_EinzelhandelFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_EinzelhandelFlaeche" AFTER DELETE ON "RP_Siedlungsstruktur"."RP_EinzelhandelFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "RP_EinzelhandelFlaeche_Flaechenobjekt" BEFORE INSERT OR UPDATE ON "RP_Siedlungsstruktur"."RP_EinzelhandelFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."positionFollowsRHR"();

-- -----------------------------------------------------
-- Table "RP_Siedlungsstruktur"."RP_EinzelhandelLinie"
-- -----------------------------------------------------
CREATE TABLE "RP_Siedlungsstruktur"."RP_EinzelhandelLinie" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_RP_EinzelhandelLinie_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "RP_Siedlungsstruktur"."RP_Einzelhandel" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("RP_Basisobjekte"."RP_Linienobjekt");

GRANT SELECT ON TABLE "RP_Siedlungsstruktur"."RP_EinzelhandelLinie" TO xp_gast;
GRANT ALL ON TABLE "RP_Siedlungsstruktur"."RP_EinzelhandelLinie" TO rp_user;
COMMENT ON COLUMN "RP_Siedlungsstruktur"."RP_EinzelhandelLinie"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_RP_EinzelhandelLinie" BEFORE INSERT OR UPDATE ON "RP_Siedlungsstruktur"."RP_EinzelhandelLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_EinzelhandelLinie" AFTER DELETE ON "RP_Siedlungsstruktur"."RP_EinzelhandelLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "RP_Siedlungsstruktur"."RP_EinzelhandelPunkt"
-- -----------------------------------------------------
CREATE TABLE "RP_Siedlungsstruktur"."RP_EinzelhandelPunkt" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_RP_EinzelhandelPunkt_parent"
    FOREIGN KEY ("gid")
    REFERENCES "RP_Siedlungsstruktur"."RP_Einzelhandel" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("RP_Basisobjekte"."RP_Punktobjekt");

GRANT SELECT ON TABLE "RP_Siedlungsstruktur"."RP_EinzelhandelPunkt" TO xp_gast;
GRANT ALL ON TABLE "RP_Siedlungsstruktur"."RP_EinzelhandelPunkt" TO rp_user;
COMMENT ON COLUMN "RP_Siedlungsstruktur"."RP_EinzelhandelPunkt"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_RP_EinzelhandelPunkt" BEFORE INSERT OR UPDATE ON "RP_Siedlungsstruktur"."RP_EinzelhandelPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_EinzelhandelPunkt" AFTER DELETE ON "RP_Siedlungsstruktur"."RP_EinzelhandelPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- RP_IndustrieGewerbe
-- -----------------------------------------------------
-- Table "RP_Siedlungsstruktur"."RP_IndustrieGewerbeTypen"
-- -----------------------------------------------------
CREATE TABLE "RP_Siedlungsstruktur"."RP_IndustrieGewerbeTypen" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Code") );
GRANT SELECT ON TABLE "RP_Siedlungsstruktur"."RP_IndustrieGewerbeTypen" TO xp_gast;

INSERT INTO "RP_Siedlungsstruktur"."RP_IndustrieGewerbeTypen" ("Code", "Bezeichner") VALUES ('1000', 'Industrie');
INSERT INTO "RP_Siedlungsstruktur"."RP_IndustrieGewerbeTypen" ("Code", "Bezeichner") VALUES ('1001', 'IndustrielleAnlage');
INSERT INTO "RP_Siedlungsstruktur"."RP_IndustrieGewerbeTypen" ("Code", "Bezeichner") VALUES ('2000', 'Gewerbe');
INSERT INTO "RP_Siedlungsstruktur"."RP_IndustrieGewerbeTypen" ("Code", "Bezeichner") VALUES ('2001', 'GewerblicherBereich');
INSERT INTO "RP_Siedlungsstruktur"."RP_IndustrieGewerbeTypen" ("Code", "Bezeichner") VALUES ('2002', 'Gewerbepark');
INSERT INTO "RP_Siedlungsstruktur"."RP_IndustrieGewerbeTypen" ("Code", "Bezeichner") VALUES ('2003', 'DienstleistungGewerbeZentrum');
INSERT INTO "RP_Siedlungsstruktur"."RP_IndustrieGewerbeTypen" ("Code", "Bezeichner") VALUES ('3000', 'GewerbeIndustrie');
INSERT INTO "RP_Siedlungsstruktur"."RP_IndustrieGewerbeTypen" ("Code", "Bezeichner") VALUES ('3001', 'BedeutsamerEntwicklungsstandortGewerbeIndustrie');
INSERT INTO "RP_Siedlungsstruktur"."RP_IndustrieGewerbeTypen" ("Code", "Bezeichner") VALUES ('4000', 'SicherungundEntwicklungvonArbeitsstaetten');
INSERT INTO "RP_Siedlungsstruktur"."RP_IndustrieGewerbeTypen" ("Code", "Bezeichner") VALUES ('5000', 'FlaechenintensivesGrossvorhaben');
INSERT INTO "RP_Siedlungsstruktur"."RP_IndustrieGewerbeTypen" ("Code", "Bezeichner") VALUES ('6000', 'BetriebsanlageBergbau');
INSERT INTO "RP_Siedlungsstruktur"."RP_IndustrieGewerbeTypen" ("Code", "Bezeichner") VALUES ('7000', 'HafenorientierteWirtschaftlicheAnlage');
INSERT INTO "RP_Siedlungsstruktur"."RP_IndustrieGewerbeTypen" ("Code", "Bezeichner") VALUES ('8000', 'TankRastanlage');
INSERT INTO "RP_Siedlungsstruktur"."RP_IndustrieGewerbeTypen" ("Code", "Bezeichner") VALUES ('9000', 'BereichFuerGewerblicheUndIndustrielleNutzungGIB');
INSERT INTO "RP_Siedlungsstruktur"."RP_IndustrieGewerbeTypen" ("Code", "Bezeichner") VALUES ('9999', 'SonstigeIndustrieGewerbe');

-- -----------------------------------------------------
-- Table "RP_Siedlungsstruktur"."RP_IndustrieGewerbe"
-- -----------------------------------------------------
CREATE TABLE "RP_Siedlungsstruktur"."RP_IndustrieGewerbe" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid"),
  CONSTRAINT "fk_RP_IndustrieGewerbe_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "RP_Siedlungsstruktur"."RP_Siedlung" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE);

GRANT SELECT ON TABLE "RP_Siedlungsstruktur"."RP_IndustrieGewerbe" TO xp_gast;
GRANT ALL ON TABLE "RP_Siedlungsstruktur"."RP_IndustrieGewerbe" TO rp_user;
COMMENT ON TABLE "RP_Siedlungsstruktur"."RP_IndustrieGewerbe" IS 'Industrie- und Gewerbestrukturen und -funktionen.';
COMMENT ON COLUMN "RP_Siedlungsstruktur"."RP_IndustrieGewerbe"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_RP_IndustrieGewerbe" BEFORE INSERT OR UPDATE ON "RP_Siedlungsstruktur"."RP_IndustrieGewerbe" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_IndustrieGewerbe" AFTER DELETE ON "RP_Siedlungsstruktur"."RP_IndustrieGewerbe" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "RP_Siedlungsstruktur"."RP_IndustrieGewerbe_typ"
-- -----------------------------------------------------
CREATE TABLE "RP_Siedlungsstruktur"."RP_IndustrieGewerbe_typ" (
  "RP_IndustrieGewerbe_gid" BIGINT NOT NULL,
  "typ" INTEGER NOT NULL,
  PRIMARY KEY ("RP_IndustrieGewerbe_gid", "typ"),
  CONSTRAINT "fk_RP_IndustrieGewerbe_typ1"
    FOREIGN KEY ("RP_IndustrieGewerbe_gid")
    REFERENCES "RP_Siedlungsstruktur"."RP_IndustrieGewerbe" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_RP_IndustrieGewerbe_typ2"
    FOREIGN KEY ("typ")
    REFERENCES "RP_Siedlungsstruktur"."RP_IndustrieGewerbeTypen" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
COMMENT ON TABLE "RP_Siedlungsstruktur"."RP_IndustrieGewerbe_typ" IS 'Klassifikation von Industrie- und Gewerbetypen.';
GRANT SELECT ON TABLE "RP_Siedlungsstruktur"."RP_IndustrieGewerbe_typ" TO xp_gast;
GRANT ALL ON TABLE "RP_Siedlungsstruktur"."RP_IndustrieGewerbe_typ" TO rp_user;

-- -----------------------------------------------------
-- Table "RP_Siedlungsstruktur"."RP_IndustrieGewerbeFlaeche"
-- -----------------------------------------------------
CREATE TABLE "RP_Siedlungsstruktur"."RP_IndustrieGewerbeFlaeche" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_RP_IndustrieGewerbeFlaeche_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "RP_Siedlungsstruktur"."RP_IndustrieGewerbe" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("RP_Basisobjekte"."RP_Flaechenobjekt");

GRANT SELECT ON TABLE "RP_Siedlungsstruktur"."RP_IndustrieGewerbeFlaeche" TO xp_gast;
GRANT ALL ON TABLE "RP_Siedlungsstruktur"."RP_IndustrieGewerbeFlaeche" TO rp_user;
COMMENT ON COLUMN "RP_Siedlungsstruktur"."RP_IndustrieGewerbeFlaeche"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_RP_IndustrieGewerbeFlaeche" BEFORE INSERT OR UPDATE ON "RP_Siedlungsstruktur"."RP_IndustrieGewerbeFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_IndustrieGewerbeFlaeche" AFTER DELETE ON "RP_Siedlungsstruktur"."RP_IndustrieGewerbeFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "RP_IndustrieGewerbeFlaeche_Flaechenobjekt" BEFORE INSERT OR UPDATE ON "RP_Siedlungsstruktur"."RP_IndustrieGewerbeFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."positionFollowsRHR"();

-- -----------------------------------------------------
-- Table "RP_Siedlungsstruktur"."RP_IndustrieGewerbeLinie"
-- -----------------------------------------------------
CREATE TABLE "RP_Siedlungsstruktur"."RP_IndustrieGewerbeLinie" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_RP_IndustrieGewerbeLinie_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "RP_Siedlungsstruktur"."RP_IndustrieGewerbe" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("RP_Basisobjekte"."RP_Linienobjekt");

GRANT SELECT ON TABLE "RP_Siedlungsstruktur"."RP_IndustrieGewerbeLinie" TO xp_gast;
GRANT ALL ON TABLE "RP_Siedlungsstruktur"."RP_IndustrieGewerbeLinie" TO rp_user;
COMMENT ON COLUMN "RP_Siedlungsstruktur"."RP_IndustrieGewerbeLinie"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_RP_IndustrieGewerbeLinie" BEFORE INSERT OR UPDATE ON "RP_Siedlungsstruktur"."RP_IndustrieGewerbeLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_IndustrieGewerbeLinie" AFTER DELETE ON "RP_Siedlungsstruktur"."RP_IndustrieGewerbeLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "RP_Siedlungsstruktur"."RP_IndustrieGewerbePunkt"
-- -----------------------------------------------------
CREATE TABLE "RP_Siedlungsstruktur"."RP_IndustrieGewerbePunkt" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_RP_IndustrieGewerbePunkt_parent"
    FOREIGN KEY ("gid")
    REFERENCES "RP_Siedlungsstruktur"."RP_IndustrieGewerbe" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("RP_Basisobjekte"."RP_Punktobjekt");

GRANT SELECT ON TABLE "RP_Siedlungsstruktur"."RP_IndustrieGewerbePunkt" TO xp_gast;
GRANT ALL ON TABLE "RP_Siedlungsstruktur"."RP_IndustrieGewerbePunkt" TO rp_user;
COMMENT ON COLUMN "RP_Siedlungsstruktur"."RP_IndustrieGewerbePunkt"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_RP_IndustrieGewerbePunkt" BEFORE INSERT OR UPDATE ON "RP_Siedlungsstruktur"."RP_IndustrieGewerbePunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_IndustrieGewerbePunkt" AFTER DELETE ON "RP_Siedlungsstruktur"."RP_IndustrieGewerbePunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- RP_WohnenSiedlung
-- -----------------------------------------------------
-- Table "RP_Siedlungsstruktur"."RP_WohnenSiedlungTypen"
-- -----------------------------------------------------
CREATE TABLE "RP_Siedlungsstruktur"."RP_WohnenSiedlungTypen" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Code") );
GRANT SELECT ON TABLE "RP_Siedlungsstruktur"."RP_WohnenSiedlungTypen" TO xp_gast;

INSERT INTO "RP_Siedlungsstruktur"."RP_WohnenSiedlungTypen" ("Code", "Bezeichner") VALUES ('1000', 'Wohnen');
INSERT INTO "RP_Siedlungsstruktur"."RP_WohnenSiedlungTypen" ("Code", "Bezeichner") VALUES ('2000', 'Baugebietsgrenze');
INSERT INTO "RP_Siedlungsstruktur"."RP_WohnenSiedlungTypen" ("Code", "Bezeichner") VALUES ('3000', 'Siedlungsgebiet');
INSERT INTO "RP_Siedlungsstruktur"."RP_WohnenSiedlungTypen" ("Code", "Bezeichner") VALUES ('3001', 'Siedlungsschwerpunkt');
INSERT INTO "RP_Siedlungsstruktur"."RP_WohnenSiedlungTypen" ("Code", "Bezeichner") VALUES ('3002', 'Siedlungsentwicklung');
INSERT INTO "RP_Siedlungsstruktur"."RP_WohnenSiedlungTypen" ("Code", "Bezeichner") VALUES ('3003', 'Siedlungsbeschraenkung');
INSERT INTO "RP_Siedlungsstruktur"."RP_WohnenSiedlungTypen" ("Code", "Bezeichner") VALUES ('3004', 'Siedlungsnutzung');
INSERT INTO "RP_Siedlungsstruktur"."RP_WohnenSiedlungTypen" ("Code", "Bezeichner") VALUES ('4000', 'SicherungEntwicklungWohnstaetten');
INSERT INTO "RP_Siedlungsstruktur"."RP_WohnenSiedlungTypen" ("Code", "Bezeichner") VALUES ('5000', 'AllgemeinerSiedlungsbereichASB');
INSERT INTO "RP_Siedlungsstruktur"."RP_WohnenSiedlungTypen" ("Code", "Bezeichner") VALUES ('9999', 'SonstigeWohnenSiedlung');

-- -----------------------------------------------------
-- Table "RP_Siedlungsstruktur"."RP_WohnenSiedlung"
-- -----------------------------------------------------
CREATE TABLE "RP_Siedlungsstruktur"."RP_WohnenSiedlung" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid"),
  CONSTRAINT "fk_RP_WohnenSiedlung_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "RP_Siedlungsstruktur"."RP_Siedlung" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE);

GRANT SELECT ON TABLE "RP_Siedlungsstruktur"."RP_WohnenSiedlung" TO xp_gast;
GRANT ALL ON TABLE "RP_Siedlungsstruktur"."RP_WohnenSiedlung" TO rp_user;
COMMENT ON TABLE "RP_Siedlungsstruktur"."RP_WohnenSiedlung" IS 'Wohn- und Siedlungsstruktur und -funktionen.';
COMMENT ON COLUMN "RP_Siedlungsstruktur"."RP_WohnenSiedlung"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_RP_WohnenSiedlung" BEFORE INSERT OR UPDATE ON "RP_Siedlungsstruktur"."RP_WohnenSiedlung" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_WohnenSiedlung" AFTER DELETE ON "RP_Siedlungsstruktur"."RP_WohnenSiedlung" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "RP_Siedlungsstruktur"."RP_WohnenSiedlung_typ"
-- -----------------------------------------------------
CREATE TABLE "RP_Siedlungsstruktur"."RP_WohnenSiedlung_typ" (
  "RP_WohnenSiedlung_gid" BIGINT NOT NULL,
  "typ" INTEGER NOT NULL,
  PRIMARY KEY ("RP_WohnenSiedlung_gid", "typ"),
  CONSTRAINT "fk_RP_WohnenSiedlung_typ1"
    FOREIGN KEY ("RP_WohnenSiedlung_gid")
    REFERENCES "RP_Siedlungsstruktur"."RP_WohnenSiedlung" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_RP_WohnenSiedlung_typ2"
    FOREIGN KEY ("typ")
    REFERENCES "RP_Siedlungsstruktur"."RP_WohnenSiedlungTypen" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
COMMENT ON TABLE "RP_Siedlungsstruktur"."RP_WohnenSiedlung_typ" IS 'Klassifikation von Wohnen- und Siedlungstypen';
GRANT SELECT ON TABLE "RP_Siedlungsstruktur"."RP_WohnenSiedlung_typ" TO xp_gast;
GRANT ALL ON TABLE "RP_Siedlungsstruktur"."RP_WohnenSiedlung_typ" TO rp_user;

-- -----------------------------------------------------
-- Table "RP_Siedlungsstruktur"."RP_WohnenSiedlungFlaeche"
-- -----------------------------------------------------
CREATE TABLE "RP_Siedlungsstruktur"."RP_WohnenSiedlungFlaeche" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_RP_WohnenSiedlungFlaeche_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "RP_Siedlungsstruktur"."RP_WohnenSiedlung" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("RP_Basisobjekte"."RP_Flaechenobjekt");

GRANT SELECT ON TABLE "RP_Siedlungsstruktur"."RP_WohnenSiedlungFlaeche" TO xp_gast;
GRANT ALL ON TABLE "RP_Siedlungsstruktur"."RP_WohnenSiedlungFlaeche" TO rp_user;
COMMENT ON COLUMN "RP_Siedlungsstruktur"."RP_WohnenSiedlungFlaeche"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_RP_WohnenSiedlungFlaeche" BEFORE INSERT OR UPDATE ON "RP_Siedlungsstruktur"."RP_WohnenSiedlungFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_WohnenSiedlungFlaeche" AFTER DELETE ON "RP_Siedlungsstruktur"."RP_WohnenSiedlungFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "RP_WohnenSiedlungFlaeche_Flaechenobjekt" BEFORE INSERT OR UPDATE ON "RP_Siedlungsstruktur"."RP_WohnenSiedlungFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."positionFollowsRHR"();

-- -----------------------------------------------------
-- Table "RP_Siedlungsstruktur"."RP_WohnenSiedlungLinie"
-- -----------------------------------------------------
CREATE TABLE "RP_Siedlungsstruktur"."RP_WohnenSiedlungLinie" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_RP_WohnenSiedlungLinie_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "RP_Siedlungsstruktur"."RP_WohnenSiedlung" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("RP_Basisobjekte"."RP_Linienobjekt");

GRANT SELECT ON TABLE "RP_Siedlungsstruktur"."RP_WohnenSiedlungLinie" TO xp_gast;
GRANT ALL ON TABLE "RP_Siedlungsstruktur"."RP_WohnenSiedlungLinie" TO rp_user;
COMMENT ON COLUMN "RP_Siedlungsstruktur"."RP_WohnenSiedlungLinie"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_RP_WohnenSiedlungLinie" BEFORE INSERT OR UPDATE ON "RP_Siedlungsstruktur"."RP_WohnenSiedlungLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_WohnenSiedlungLinie" AFTER DELETE ON "RP_Siedlungsstruktur"."RP_WohnenSiedlungLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "RP_Siedlungsstruktur"."RP_WohnenSiedlungPunkt"
-- -----------------------------------------------------
CREATE TABLE "RP_Siedlungsstruktur"."RP_WohnenSiedlungPunkt" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_RP_WohnenSiedlungPunkt_parent"
    FOREIGN KEY ("gid")
    REFERENCES "RP_Siedlungsstruktur"."RP_WohnenSiedlung" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("RP_Basisobjekte"."RP_Punktobjekt");

GRANT SELECT ON TABLE "RP_Siedlungsstruktur"."RP_WohnenSiedlungPunkt" TO xp_gast;
GRANT ALL ON TABLE "RP_Siedlungsstruktur"."RP_WohnenSiedlungPunkt" TO rp_user;
COMMENT ON COLUMN "RP_Siedlungsstruktur"."RP_WohnenSiedlungPunkt"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_RP_WohnenSiedlungPunkt" BEFORE INSERT OR UPDATE ON "RP_Siedlungsstruktur"."RP_WohnenSiedlungPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_WohnenSiedlungPunkt" AFTER DELETE ON "RP_Siedlungsstruktur"."RP_WohnenSiedlungPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();


-- RP_SonstigerSiedlungsbereich

-- -----------------------------------------------------
-- Table "RP_Siedlungsstruktur"."RP_SonstigerSiedlungsbereich"
-- -----------------------------------------------------
CREATE TABLE "RP_Siedlungsstruktur"."RP_SonstigerSiedlungsbereich" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid"),
  CONSTRAINT "fk_RP_SonstigerSiedlungsbereich_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "RP_Siedlungsstruktur"."RP_Siedlung" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE);

GRANT SELECT ON TABLE "RP_Siedlungsstruktur"."RP_SonstigerSiedlungsbereich" TO xp_gast;
GRANT ALL ON TABLE "RP_Siedlungsstruktur"."RP_SonstigerSiedlungsbereich" TO rp_user;
COMMENT ON TABLE "RP_Siedlungsstruktur"."RP_SonstigerSiedlungsbereich" IS 'Wohn- und Siedlungsstruktur und -funktionen.';
COMMENT ON COLUMN "RP_Siedlungsstruktur"."RP_SonstigerSiedlungsbereich"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_RP_SonstigerSiedlungsbereich" BEFORE INSERT OR UPDATE ON "RP_Siedlungsstruktur"."RP_SonstigerSiedlungsbereich" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_SonstigerSiedlungsbereich" AFTER DELETE ON "RP_Siedlungsstruktur"."RP_SonstigerSiedlungsbereich" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "RP_Siedlungsstruktur"."RP_SonstigerSiedlungsbereichFlaeche"
-- -----------------------------------------------------
CREATE TABLE "RP_Siedlungsstruktur"."RP_SonstigerSiedlungsbereichFlaeche" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_RP_SonstigerSiedlungsbereichFlaeche_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "RP_Siedlungsstruktur"."RP_SonstigerSiedlungsbereich" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("RP_Basisobjekte"."RP_Flaechenobjekt");

GRANT SELECT ON TABLE "RP_Siedlungsstruktur"."RP_SonstigerSiedlungsbereichFlaeche" TO xp_gast;
GRANT ALL ON TABLE "RP_Siedlungsstruktur"."RP_SonstigerSiedlungsbereichFlaeche" TO rp_user;
COMMENT ON COLUMN "RP_Siedlungsstruktur"."RP_SonstigerSiedlungsbereichFlaeche"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_RP_SonstigerSiedlungsbereichFlaeche" BEFORE INSERT OR UPDATE ON "RP_Siedlungsstruktur"."RP_SonstigerSiedlungsbereichFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_SonstigerSiedlungsbereichFlaeche" AFTER DELETE ON "RP_Siedlungsstruktur"."RP_SonstigerSiedlungsbereichFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "RP_SonstigerSiedlungsbereichFlaeche_Flaechenobjekt" BEFORE INSERT OR UPDATE ON "RP_Siedlungsstruktur"."RP_SonstigerSiedlungsbereichFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."positionFollowsRHR"();

-- -----------------------------------------------------
-- Table "RP_Siedlungsstruktur"."RP_SonstigerSiedlungsbereichLinie"
-- -----------------------------------------------------
CREATE TABLE "RP_Siedlungsstruktur"."RP_SonstigerSiedlungsbereichLinie" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_RP_SonstigerSiedlungsbereichLinie_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "RP_Siedlungsstruktur"."RP_SonstigerSiedlungsbereich" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("RP_Basisobjekte"."RP_Linienobjekt");

GRANT SELECT ON TABLE "RP_Siedlungsstruktur"."RP_SonstigerSiedlungsbereichLinie" TO xp_gast;
GRANT ALL ON TABLE "RP_Siedlungsstruktur"."RP_SonstigerSiedlungsbereichLinie" TO rp_user;
COMMENT ON COLUMN "RP_Siedlungsstruktur"."RP_SonstigerSiedlungsbereichLinie"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_RP_SonstigerSiedlungsbereichLinie" BEFORE INSERT OR UPDATE ON "RP_Siedlungsstruktur"."RP_SonstigerSiedlungsbereichLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_SonstigerSiedlungsbereichLinie" AFTER DELETE ON "RP_Siedlungsstruktur"."RP_SonstigerSiedlungsbereichLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "RP_Siedlungsstruktur"."RP_SonstigerSiedlungsbereichPunkt"
-- -----------------------------------------------------
CREATE TABLE "RP_Siedlungsstruktur"."RP_SonstigerSiedlungsbereichPunkt" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_RP_SonstigerSiedlungsbereichPunkt_parent"
    FOREIGN KEY ("gid")
    REFERENCES "RP_Siedlungsstruktur"."RP_SonstigerSiedlungsbereich" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("RP_Basisobjekte"."RP_Punktobjekt");

GRANT SELECT ON TABLE "RP_Siedlungsstruktur"."RP_SonstigerSiedlungsbereichPunkt" TO xp_gast;
GRANT ALL ON TABLE "RP_Siedlungsstruktur"."RP_SonstigerSiedlungsbereichPunkt" TO rp_user;
COMMENT ON COLUMN "RP_Siedlungsstruktur"."RP_SonstigerSiedlungsbereichPunkt"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_RP_SonstigerSiedlungsbereichPunkt" BEFORE INSERT OR UPDATE ON "RP_Siedlungsstruktur"."RP_SonstigerSiedlungsbereichPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_SonstigerSiedlungsbereichPunkt" AFTER DELETE ON "RP_Siedlungsstruktur"."RP_SonstigerSiedlungsbereichPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- ###########################################
-- Überarbeitung RP_KernmodellSonstiges
ALTER SCHEMA "RP_KernmodellSonstiges" RENAME TO "RP_Sonstiges";
ALTER TABLE "RP_Sonstiges"."RP_Grenze" RENAME TO "RP_GrenzeLinie";

-- -----------------------------------------------------
-- Table "RP_Sonstiges"."RP_SpezifischeGrenzeTypen"
-- -----------------------------------------------------
CREATE TABLE  "RP_Sonstiges"."RP_SpezifischeGrenzeTypen" (
  "Code" INTEGER NOT NULL,
  "Bezeichner" VARCHAR(64) NOT NULL,
  PRIMARY KEY ("Code"));

GRANT SELECT ON TABLE "RP_Sonstiges"."RP_SpezifischeGrenzeTypen" TO xp_gast;
GRANT ALL ON TABLE "RP_Sonstiges"."RP_SpezifischeGrenzeTypen" TO so_user;

INSERT INTO "RP_Sonstiges"."RP_SpezifischeGrenzeTypen" ("Code", "Bezeichner") VALUES ('1000', 'Zwoelfmeilenzone');
INSERT INTO "RP_Sonstiges"."RP_SpezifischeGrenzeTypen" ("Code", "Bezeichner") VALUES ('1001', 'BegrenzungDesKuestenmeeres');
INSERT INTO "RP_Sonstiges"."RP_SpezifischeGrenzeTypen" ("Code", "Bezeichner") VALUES ('2000', 'VerlaufUmstritten');
INSERT INTO "RP_Sonstiges"."RP_SpezifischeGrenzeTypen" ("Code", "Bezeichner") VALUES ('3000', 'GrenzeDtAusschlWirtschaftszone');
INSERT INTO "RP_Sonstiges"."RP_SpezifischeGrenzeTypen" ("Code", "Bezeichner") VALUES ('4000', 'MittlereTideHochwasserlinie');
INSERT INTO "RP_Sonstiges"."RP_SpezifischeGrenzeTypen" ("Code", "Bezeichner") VALUES ('5000', 'PlanungsregionsgrenzeRegion');
INSERT INTO "RP_Sonstiges"."RP_SpezifischeGrenzeTypen" ("Code", "Bezeichner") VALUES ('6000', 'PlanungsregionsgrenzeLand');
INSERT INTO "RP_Sonstiges"."RP_SpezifischeGrenzeTypen" ("Code", "Bezeichner") VALUES ('7000', 'GrenzeBraunkohlenplan');
INSERT INTO "RP_Sonstiges"."RP_SpezifischeGrenzeTypen" ("Code", "Bezeichner") VALUES ('8000', 'Grenzuebergangsstelle');

-- -----------------------------------------------------
-- Table "RP_Sonstiges"."RP_Grenze"
-- -----------------------------------------------------
CREATE TABLE  "RP_Sonstiges"."RP_Grenze" (
  "gid" BIGINT NOT NULL,
  "spezifischerTyp" INTEGER NULL,
  "sonstTyp" INTEGER NULL,
  PRIMARY KEY ("gid"),
  CONSTRAINT "fk_RP_Grenze_parent"
    FOREIGN KEY ("gid")
    REFERENCES "RP_Basisobjekte"."RP_Objekt" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_RP_Grenze_spezifischerTyp"
    FOREIGN KEY ("spezifischerTyp")
    REFERENCES "RP_Sonstiges"."RP_SpezifischeGrenzeTypen" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_RP_Grenze_sonstTyp"
    FOREIGN KEY ("sonstTyp")
    REFERENCES "RP_Sonstiges"."RP_SonstGrenzeTypen" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE);

CREATE INDEX "idx_fk_RP_Grenze_spezifischerTyp" ON "RP_Sonstiges"."RP_Grenze" ("spezifischerTyp");
CREATE INDEX "idx_fk_RP_Grenze_sonstTyp" ON "RP_Sonstiges"."RP_Grenze" ("sonstTyp");
GRANT SELECT ON TABLE "RP_Sonstiges"."RP_Grenze" TO xp_gast;
GRANT ALL ON TABLE "RP_Sonstiges"."RP_Grenze" TO rp_user;
COMMENT ON TABLE "RP_Sonstiges"."RP_Grenze" IS 'Grenzen';
COMMENT ON COLUMN "RP_Sonstiges"."RP_Grenze"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN "RP_Sonstiges"."RP_Grenze"."spezifischerTyp" IS 'Spezifischer Typ der Grenze';
COMMENT ON COLUMN "RP_Sonstiges"."RP_Grenze"."sonstTyp" IS 'Erweiterter Typ';
INSERT INTO "RP_Sonstiges"."RP_Grenze" (gid) SELECT gid FROM "RP_Sonstiges"."RP_GrenzeLinie";
CREATE TRIGGER "change_to_RP_Grenze" BEFORE INSERT OR UPDATE ON "RP_Sonstiges"."RP_Grenze" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_Grenze" AFTER DELETE ON "RP_Sonstiges"."RP_Grenze" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table RP_Sonstiges"."RP_Grenze_typ"
-- -----------------------------------------------------
CREATE TABLE "RP_Sonstiges"."RP_Grenze_typ" (
  "RP_Grenze_gid" BIGINT NOT NULL ,
  "typ" INTEGER NULL ,
  PRIMARY KEY ("RP_Grenze_gid", "typ"),
  CONSTRAINT "fk_RP_Grenze_typ1"
    FOREIGN KEY ("RP_Grenze_gid" )
    REFERENCES "RP_Sonstiges"."RP_Grenze" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_RP_Grenze_typ2"
    FOREIGN KEY ("typ" )
    REFERENCES "XP_Enumerationen"."XP_GrenzeTypen" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
GRANT SELECT ON TABLE "RP_Sonstiges"."RP_Grenze_typ" TO xp_gast;
GRANT ALL ON TABLE "RP_Sonstiges"."RP_Grenze_typ" TO rp_user;
COMMENT ON TABLE "RP_Sonstiges"."RP_Grenze_typ" IS 'Typ der Grenze';
INSERT INTO "RP_Sonstiges"."RP_Grenze_typ" ("RP_Grenze_gid","typ") SELECT gid,typ FROM "RP_Sonstiges"."RP_GrenzeLinie";
ALTER TABLE "RP_Sonstiges"."RP_GrenzeLinie" DROP COLUMN "typ";

-- -----------------------------------------------------
-- Table "RP_Sonstiges"."RP_GrenzeFlaeche"
-- -----------------------------------------------------
CREATE TABLE "RP_Sonstiges"."RP_GrenzeFlaeche" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_RP_GrenzeFlaeche_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "RP_Sonstiges"."RP_Grenze" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("RP_Basisobjekte"."RP_Flaechenobjekt");

GRANT SELECT ON TABLE "RP_Sonstiges"."RP_GrenzeFlaeche" TO xp_gast;
GRANT ALL ON TABLE "RP_Sonstiges"."RP_GrenzeFlaeche" TO rp_user;
COMMENT ON COLUMN "RP_Sonstiges"."RP_GrenzeFlaeche"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_RP_GrenzeFlaeche" BEFORE INSERT OR UPDATE ON "RP_Sonstiges"."RP_GrenzeFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_GrenzeFlaeche" AFTER DELETE ON "RP_Sonstiges"."RP_GrenzeFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "RP_GrenzeFlaeche_Flaechenobjekt" BEFORE INSERT OR UPDATE ON "RP_Sonstiges"."RP_GrenzeFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."positionFollowsRHR"();

-- -----------------------------------------------------
-- Table "RP_Sonstiges"."RP_GrenzePunkt"
-- -----------------------------------------------------
CREATE TABLE "RP_Sonstiges"."RP_GrenzePunkt" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_RP_GrenzePunkt_parent"
    FOREIGN KEY ("gid")
    REFERENCES "RP_Sonstiges"."RP_Grenze" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("RP_Basisobjekte"."RP_Punktobjekt");

GRANT SELECT ON TABLE "RP_Sonstiges"."RP_GrenzePunkt" TO xp_gast;
GRANT ALL ON TABLE "RP_Sonstiges"."RP_GrenzePunkt" TO rp_user;
COMMENT ON COLUMN "RP_Sonstiges"."RP_GrenzePunkt"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_RP_GrenzePunkt" BEFORE INSERT OR UPDATE ON "RP_Sonstiges"."RP_GrenzePunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_GrenzePunkt" AFTER DELETE ON "RP_Sonstiges"."RP_GrenzePunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- RP_Planungsraum
-- -----------------------------------------------------
-- Table "RP_Sonstiges"."RP_Planungsraum"
-- -----------------------------------------------------
CREATE TABLE  "RP_Sonstiges"."RP_Planungsraum" (
  "gid" BIGINT NOT NULL,
  "planungsraumBeschreibung" TEXT,
  PRIMARY KEY ("gid"),
  CONSTRAINT "fk_RP_Planungsraum_parent"
    FOREIGN KEY ("gid")
    REFERENCES "RP_Basisobjekte"."RP_Objekt" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE);

GRANT SELECT ON TABLE "RP_Sonstiges"."RP_Planungsraum" TO xp_gast;
GRANT ALL ON TABLE "RP_Sonstiges"."RP_Planungsraum" TO rp_user;
COMMENT ON TABLE "RP_Sonstiges"."RP_Planungsraum" IS 'Modelliert einen allgemeinen Planungsraum.';
COMMENT ON COLUMN "RP_Sonstiges"."RP_Planungsraum"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN "RP_Sonstiges"."RP_Planungsraum"."planungsraumBeschreibung" IS 'Textliche Beschreibung eines Planungsrauminhalts.';
CREATE TRIGGER "change_to_RP_Planungsraum" BEFORE INSERT OR UPDATE ON "RP_Sonstiges"."RP_Planungsraum" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_Planungsraum" AFTER DELETE ON "RP_Sonstiges"."RP_Planungsraum" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "RP_Sonstiges"."RP_PlanungsraumFlaeche"
-- -----------------------------------------------------
CREATE TABLE "RP_Sonstiges"."RP_PlanungsraumFlaeche" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_RP_PlanungsraumFlaeche_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "RP_Sonstiges"."RP_Planungsraum" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("RP_Basisobjekte"."RP_Flaechenobjekt");

GRANT SELECT ON TABLE "RP_Sonstiges"."RP_PlanungsraumFlaeche" TO xp_gast;
GRANT ALL ON TABLE "RP_Sonstiges"."RP_PlanungsraumFlaeche" TO rp_user;
CREATE INDEX "RP_PlanungsraumFlaeche_gidx" ON "RP_Sonstiges"."RP_PlanungsraumFlaeche" USING gist(position);
COMMENT ON COLUMN "RP_Sonstiges"."RP_PlanungsraumFlaeche"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_RP_PlanungsraumFlaeche" BEFORE INSERT OR UPDATE ON "RP_Sonstiges"."RP_PlanungsraumFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_PlanungsraumFlaeche" AFTER DELETE ON "RP_Sonstiges"."RP_PlanungsraumFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "RP_PlanungsraumFlaeche_Flaechenobjekt" BEFORE INSERT OR UPDATE ON "RP_Sonstiges"."RP_PlanungsraumFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."positionFollowsRHR"();

-- -----------------------------------------------------
-- Table "RP_Sonstiges"."RP_PlanungsraumLinie"
-- -----------------------------------------------------
CREATE TABLE "RP_Sonstiges"."RP_PlanungsraumLinie" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_RP_PlanungsraumLinie_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "RP_Sonstiges"."RP_Planungsraum" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("RP_Basisobjekte"."RP_Linienobjekt");

GRANT SELECT ON TABLE "RP_Sonstiges"."RP_PlanungsraumLinie" TO xp_gast;
GRANT ALL ON TABLE "RP_Sonstiges"."RP_PlanungsraumLinie" TO rp_user;
CREATE INDEX "RP_PlanungsraumLinie_gidx" ON "RP_Sonstiges"."RP_PlanungsraumLinie" USING gist(position);
COMMENT ON COLUMN "RP_Sonstiges"."RP_PlanungsraumLinie"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_RP_PlanungsraumLinie" BEFORE INSERT OR UPDATE ON "RP_Sonstiges"."RP_PlanungsraumLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_PlanungsraumLinie" AFTER DELETE ON "RP_Sonstiges"."RP_PlanungsraumLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "RP_Sonstiges"."RP_PlanungsraumPunkt"
-- -----------------------------------------------------
CREATE TABLE "RP_Sonstiges"."RP_PlanungsraumPunkt" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_RP_PlanungsraumPunkt_parent"
    FOREIGN KEY ("gid")
    REFERENCES "RP_Sonstiges"."RP_Planungsraum" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("RP_Basisobjekte"."RP_Punktobjekt");

GRANT SELECT ON TABLE "RP_Sonstiges"."RP_PlanungsraumPunkt" TO xp_gast;
GRANT ALL ON TABLE "RP_Sonstiges"."RP_PlanungsraumPunkt" TO rp_user;
CREATE INDEX "RP_PlanungsraumPunkt_gidx" ON "RP_Sonstiges"."RP_PlanungsraumPunkt" USING gist(position);
COMMENT ON COLUMN "RP_Sonstiges"."RP_PlanungsraumPunkt"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_RP_PlanungsraumPunkt" BEFORE INSERT OR UPDATE ON "RP_Sonstiges"."RP_PlanungsraumPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_PlanungsraumPunkt" AFTER DELETE ON "RP_Sonstiges"."RP_PlanungsraumPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- ###########################################
-- Überarbeitung RP_Basisobjekte
-- RP_Plan
INSERT INTO "XP_Basisobjekte"."XP_SpezExterneReferenz" (id,typ) SELECT "refUmweltbericht",1050 FROM "RP_Basisobjekte"."RP_Plan" WHERE "refUmweltbericht" IS NOT NULL;
INSERT INTO "XP_Basisobjekte"."XP_Plan_externeReferenz" ("XP_Plan_gid", "externeReferenz")
SELECT "gid", "refUmweltbericht" FROM "RP_Basisobjekte"."RP_Plan" WHERE "refUmweltbericht" IS NOT NULL;
ALTER TABLE "RP_Basisobjekte"."RP_Plan" DROP COLUMN "refUmweltbericht" CASCADE;
INSERT INTO "XP_Basisobjekte"."XP_SpezExterneReferenz" (id,typ) SELECT "refSatzung",1060 FROM "RP_Basisobjekte"."RP_Plan" WHERE "refSatzung" IS NOT NULL;
INSERT INTO "XP_Basisobjekte"."XP_Plan_externeReferenz" ("XP_Plan_gid", "externeReferenz")
SELECT "gid", "refUmweltbericht" FROM "RP_Basisobjekte"."RP_Plan" WHERE "refSatzung" IS NOT NULL;
ALTER TABLE "RP_Basisobjekte"."RP_Plan" DROP COLUMN "refSatzung" CASCADE;

-- RP_Bereich
ALTER TABLE "RP_Basisobjekte"."RP_Bereich" ADD COLUMN "geltungsmassstab" INTEGER;
COMMENT ON COLUMN "RP_Basisobjekte"."RP_Bereich"."geltungsmassstab" IS '(Rechtlicher) Geltungsmaßstab des Bereichs.';

-- RP_Objekt
ALTER TABLE "RP_Basisobjekte"."RP_Objekt" ADD COLUMN "kuestenmeer" BOOLEAN;
ALTER TABLE "RP_Basisobjekte"."RP_Objekt" ADD COLUMN "istZweckbindung" BOOLEAN;
COMMENT ON COLUMN "RP_Basisobjekte"."RP_Objekt"."kuestenmeer" IS 'Zeigt an, ob das Objekt im Küstenmeer liegt.';
COMMENT ON COLUMN "RP_Basisobjekte"."RP_Objekt"."istZweckbindung" IS 'Zeigt an, ob es sich bei diesem Objekt um eine Zweckbindung handelt.';

-- -----------------------------------------------------
-- Table "RP_Basisobjekte"."RP_Bedeutsamkeit"
-- -----------------------------------------------------
CREATE TABLE "RP_Basisobjekte"."RP_Bedeutsamkeit" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Code") );
GRANT SELECT ON TABLE "RP_Basisobjekte"."RP_Bedeutsamkeit" TO xp_gast;

-- -----------------------------------------------------
-- Table "RP_Basisobjekte"."RP_Objekt_bedeutsamkeit"
-- -----------------------------------------------------
CREATE TABLE "RP_Basisobjekte"."RP_Objekt_bedeutsamkeit" (
  "RP_Objekt_gid" BIGINT NOT NULL ,
  "bedeutsamkeit" INTEGER NOT NULL ,
  PRIMARY KEY ("RP_Objekt_gid", "bedeutsamkeit"),
  CONSTRAINT "fk_RP_Bodenschutz_bedeutsamkeit1"
    FOREIGN KEY ("RP_Objekt_gid" )
    REFERENCES "RP_Basisobjekte"."RP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_RP_Objekt_bedeutsamkeit2"
    FOREIGN KEY ("bedeutsamkeit" )
    REFERENCES "RP_Basisobjekte"."RP_Bedeutsamkeit" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
GRANT SELECT ON TABLE "RP_Basisobjekte"."RP_Objekt_bedeutsamkeit" TO xp_gast;
GRANT ALL ON TABLE "RP_Basisobjekte"."RP_Objekt_bedeutsamkeit" TO rp_user;
COMMENT ON TABLE "RP_Basisobjekte"."RP_Objekt_bedeutsamkeit" IS 'Bedeutsamkeit eines Objekts.';

-- -----------------------------------------------------
-- Data for table "RP_Basisobjekte"."RP_Bedeutsamkeit"
-- -----------------------------------------------------
INSERT INTO "RP_Basisobjekte"."RP_Bedeutsamkeit" ("Code", "Bezeichner") VALUES ('1000', 'Regional');
INSERT INTO "RP_Basisobjekte"."RP_Bedeutsamkeit" ("Code", "Bezeichner") VALUES ('2000', 'Ueberregional');
INSERT INTO "RP_Basisobjekte"."RP_Bedeutsamkeit" ("Code", "Bezeichner") VALUES ('3000', 'Grossraeumig');
INSERT INTO "RP_Basisobjekte"."RP_Bedeutsamkeit" ("Code", "Bezeichner") VALUES ('4000', 'Landesweit');
INSERT INTO "RP_Basisobjekte"."RP_Bedeutsamkeit" ("Code", "Bezeichner") VALUES ('5000', 'Bundesweit');
INSERT INTO "RP_Basisobjekte"."RP_Bedeutsamkeit" ("Code", "Bezeichner") VALUES ('6000', 'Europaeisch');
INSERT INTO "RP_Basisobjekte"."RP_Bedeutsamkeit" ("Code", "Bezeichner") VALUES ('7000', 'International');
INSERT INTO "RP_Basisobjekte"."RP_Bedeutsamkeit" ("Code", "Bezeichner") VALUES ('8000', 'Flaechenerschliessend');
INSERT INTO "RP_Basisobjekte"."RP_Bedeutsamkeit" ("Code", "Bezeichner") VALUES ('9000', 'Herausragend');
