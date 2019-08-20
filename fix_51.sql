/*
 * Diese Datei enthält Bugfixes für die Version 5.1
 */

-- vergrößere Feld Beschreibung
DROP VIEW "QGIS"."XP_Bereiche";
DROP VIEW "XP_Basisobjekte"."XP_Bereiche";
DROP VIEW "BP_Basisobjekte"."BP_Plan_qv";
DROP VIEW "XP_Basisobjekte"."XP_Plaene";

ALTER TABLE "XP_Basisobjekte"."XP_Plan"
    ALTER COLUMN beschreibung TYPE text;

CREATE  OR REPLACE VIEW "XP_Basisobjekte"."XP_Plaene" AS
SELECT g.gid, g."raeumlicherGeltungsbereich", name, nummer, "internalId", beschreibung,  kommentar,
  "technHerstellDatum",  "untergangsDatum",  "erstellungsMassstab" ,
  bezugshoehe, CAST(c.relname as varchar) as "Objektart"
FROM  "XP_Basisobjekte"."XP_RaeumlicherGeltungsbereich" g
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

-- vergrössere Felder, damit auch lange Tabellenamen reinpassen
ALTER TABLE "QGIS"."layer" ALTER COLUMN schemaname TYPE character varying (256);
ALTER TABLE "QGIS"."layer" ALTER COLUMN tablename TYPE character varying (256);

-- vergrößere Feld "text"
ALTER TABLE "XP_Basisobjekte"."XP_TextAbschnitt"
    ALTER COLUMN "text" TYPE text;
