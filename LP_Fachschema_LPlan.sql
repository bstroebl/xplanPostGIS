-- -----------------------------------------------------
-- Objektbereich:LP_ Fachschema LPlan
-- Dieses Paket enthält alle Klassen von LPlan-Fachobjekten nach BNatSchG
-- -----------------------------------------------------

/* *************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 ************************************************************************* */

-- *****************************************************
-- CREATE SCHEMAS
-- *****************************************************

CREATE SCHEMA "LP_Basisobjekte";
CREATE SCHEMA "LP_Erholung";
CREATE SCHEMA "LP_MassnahmenNaturschutz";
CREATE SCHEMA "LP_SchutzgebieteObjekte";
CREATE SCHEMA "LP_Sonstiges";

COMMENT ON SCHEMA "LP_Basisobjekte" IS 'Dies Paket enthält die Basisklassen des Kernmodells Landschaftsplanung.';
COMMENT ON SCHEMA "LP_Erholung" IS 'Grünflächen und Flächen, Zweckbestimmungen, Erfordernisse und Maßnahmen für die Erholung in Natur und Landschaft.';
COMMENT ON SCHEMA "LP_MassnahmenNaturschutz" IS 'Flächen, Erfordernisse und Maßnahmen zum Schutz, zur Pflege und zur Entwicklung von Natur und Landschaft (soweit nicht Gebiete und Gebietsteile zum Schutz, zur Pflege und zur Entwicklung von Natur und Landschaft).';
COMMENT ON SCHEMA "LP_SchutzgebieteObjekte" IS 'Gebiete und Gebietsteile zum Schutz, zur Pflege und zur Entwicklung von Natur und Landschaft.';
COMMENT ON SCHEMA "LP_Sonstiges" IS 'Sonstige Klassen des Kernmodells Landschaftsplanung.';

GRANT USAGE ON SCHEMA "LP_Basisobjekte" TO xp_gast;
GRANT USAGE ON SCHEMA "LP_Erholung" TO xp_gast;
GRANT USAGE ON SCHEMA "LP_MassnahmenNaturschutz" TO xp_gast;
GRANT USAGE ON SCHEMA "LP_SchutzgebieteObjekte" TO xp_gast;
GRANT USAGE ON SCHEMA "LP_Sonstiges" TO xp_gast;

-- *****************************************************
-- CREATE TRIGGER FUNCTIONs
-- *****************************************************

CREATE OR REPLACE FUNCTION "LP_Basisobjekte"."new_LP_Bereich"()
RETURNS trigger AS
$BODY$
 DECLARE
    lp_plan_gid integer;
 BEGIN
    SELECT max(gid) from "LP_Basisobjekte"."LP_Plan" INTO lp_plan_gid;

    IF lp_plan_gid IS NULL THEN
        RETURN NULL;
    ELSE
        new."gehoertZuPlan" := lp_plan_gid;
        RETURN new;
    END IF;
 END; $BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
GRANT EXECUTE ON FUNCTION "LP_Basisobjekte"."new_LP_Bereich"() TO lp_user;


-- *****************************************************
-- CREATE TABLEs
-- *****************************************************

-- -----------------------------------------------------
-- Table "LP_Basisobjekte"."LP_SonstPlanArt"
-- -----------------------------------------------------
CREATE  TABLE  "LP_Basisobjekte"."LP_SonstPlanArt" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Code") );
GRANT SELECT ON TABLE "LP_Basisobjekte"."LP_SonstPlanArt" TO xp_gast;
GRANT ALL ON TABLE "LP_Basisobjekte"."LP_SonstPlanArt" TO lp_user;
CREATE TRIGGER "ins_upd_LP_SonstPlanArt" BEFORE INSERT OR UPDATE ON "LP_Basisobjekte"."LP_SonstPlanArt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isCodeList"();

-- -----------------------------------------------------
-- Table "LP_Basisobjekte"."LP_Rechtsstand"
-- -----------------------------------------------------
CREATE  TABLE  "LP_Basisobjekte"."LP_Rechtsstand" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Code") );
GRANT SELECT ON TABLE "LP_Basisobjekte"."LP_Rechtsstand" TO xp_gast;

-- -----------------------------------------------------
-- Table "LP_Basisobjekte"."LP_PlanArt"
-- -----------------------------------------------------
CREATE  TABLE  "LP_Basisobjekte"."LP_PlanArt" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Code") );
GRANT SELECT ON TABLE "LP_Basisobjekte"."LP_PlanArt" TO xp_gast;

-- -----------------------------------------------------
-- Table "LP_Basisobjekte"."LP_Plan"
-- -----------------------------------------------------
CREATE  TABLE  "LP_Basisobjekte"."LP_Plan" (
  "gid" BIGINT NOT NULL ,
  "name" VARCHAR (256) NOT NULL,
  "bundesland" INTEGER NOT NULL DEFAULT 3000,
  "rechtlicheAussenwirkung" BOOLEAN NOT NULL DEFAULT 'f',
  "sonstPlanArt" INTEGER NULL ,
  "planungstraegerGKZ" VARCHAR(32) NOT NULL DEFAULT 'k.A.',
  "planungstraeger" VARCHAR(256) NULL,
  "rechtsstand" INTEGER NULL ,
  "aufstellungsbechlussDatum" DATE NULL ,
  "auslegungsDatum" DATE[],
  "tOeBbeteiligungsDatum" DATE[],
  "oeffentlichkeitsbeteiligungDatum" DATE[],
  "aenderungenBisDatum" DATE NULL ,
  "entwurfsbeschlussDatum" DATE NULL ,
  "planbeschlussDatum" DATE NULL ,
  "inkrafttretenDatum" DATE NULL ,
  "sonstVerfahrensDatum" DATE NULL ,
  PRIMARY KEY ("gid"),
  CONSTRAINT "fk_LP_Plan_XP_Plan1"
    FOREIGN KEY ("gid" )
    REFERENCES "XP_Basisobjekte"."XP_Plan" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_lp_plan_bundesland1"
    FOREIGN KEY ("bundesland" )
    REFERENCES "XP_Enumerationen"."XP_Bundeslaender" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_fp_plan_fp_sonstplanart1"
    FOREIGN KEY ("sonstPlanArt" )
    REFERENCES "LP_Basisobjekte"."LP_SonstPlanArt" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_fp_plan_fp_rechtsstand1"
    FOREIGN KEY ("rechtsstand" )
    REFERENCES "LP_Basisobjekte"."LP_Rechtsstand" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE)
INHERITS("XP_Basisobjekte"."XP_RaeumlicherGeltungsbereich");

CREATE INDEX "idx_fk_fp_plan_xp_plangeber1" ON "LP_Basisobjekte"."LP_Plan" ("bundesland") ;
CREATE INDEX "idx_fk_fp_plan_fp_sonstplanart1" ON "LP_Basisobjekte"."LP_Plan" ("sonstPlanArt") ;
CREATE INDEX "idx_fk_fp_plan_fp_rechtsstand1" ON "LP_Basisobjekte"."LP_Plan" ("rechtsstand") ;
CREATE INDEX "LP_Plan_gidx" ON "LP_Basisobjekte"."LP_Plan" using gist ("raeumlicherGeltungsbereich");
GRANT SELECT ON TABLE "LP_Basisobjekte"."LP_Plan" TO xp_gast;
GRANT ALL ON TABLE "LP_Basisobjekte"."LP_Plan" TO lp_user;
COMMENT ON TABLE "LP_Basisobjekte"."LP_Plan" IS 'Die Klasse modelliert ein Planwerk mit lanschaftsplanerischen Festlegungen, Darstellungen bzw. Festsetzungen.';
COMMENT ON COLUMN "LP_Basisobjekte"."LP_Plan"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN "LP_Basisobjekte"."LP_Plan"."name" IS 'Name des Plans. Der Name kann hier oder in XP_Plan geändert werden.';
COMMENT ON COLUMN "LP_Basisobjekte"."LP_Plan"."bundesland" IS 'Zuständiges Bundesland';
COMMENT ON COLUMN "LP_Basisobjekte"."LP_Plan"."rechtlicheAussenwirkung" IS 'Gibt an, ob der Plan eine rechtliche Außenwirkung hat.';
COMMENT ON COLUMN "LP_Basisobjekte"."LP_Plan"."sonstPlanArt" IS 'Spezifikation einer "Sonstigen Planart", wenn kein Plantyp aus der Enumeration LP_PlanArt zutreffend ist.';
COMMENT ON COLUMN "LP_Basisobjekte"."LP_Plan"."planungstraegerGKZ" IS 'Gemeindekennziffer des Planungsträgers.';
COMMENT ON COLUMN "LP_Basisobjekte"."LP_Plan"."planungstraeger" IS 'Bezeichnung des Planungsträgers.';
COMMENT ON COLUMN "LP_Basisobjekte"."LP_Plan"."rechtsstand" IS 'Rechtsstand des Plans';
COMMENT ON COLUMN "LP_Basisobjekte"."LP_Plan"."aufstellungsbechlussDatum" IS 'Datum des Aufstellungsbeschlusses.';
COMMENT ON COLUMN "LP_Basisobjekte"."LP_Plan"."auslegungsDatum" IS 'Datum der öffentlichen Auslegung.';
COMMENT ON COLUMN "LP_Basisobjekte"."LP_Plan"."tOeBbeteiligungsDatum" IS 'Datum der Beteiligung der Träger öffentlicher Belange.';
COMMENT ON COLUMN "LP_Basisobjekte"."LP_Plan"."oeffentlichkeitsbeteiligungDatum" IS 'Datum der Öffentlichkeits-Beteiligung.';
COMMENT ON COLUMN "LP_Basisobjekte"."LP_Plan"."aenderungenBisDatum" IS 'Datum, bis zu dem Änderungen des Plans berücksichtigt wurden.';
COMMENT ON COLUMN "LP_Basisobjekte"."LP_Plan"."entwurfsbeschlussDatum" IS 'Datum des Entwurfsbeschlusses';
COMMENT ON COLUMN "LP_Basisobjekte"."LP_Plan"."planbeschlussDatum" IS 'Datum des Planbeschlusses';
COMMENT ON COLUMN "LP_Basisobjekte"."LP_Plan"."inkrafttretenDatum" IS 'Datum des Inkrafttretens.';
COMMENT ON COLUMN "LP_Basisobjekte"."LP_Plan"."sonstVerfahrensDatum" IS 'Sonstiges Verfahrens-Datum.';
CREATE TRIGGER "change_to_LP_Plan" BEFORE INSERT OR UPDATE ON "LP_Basisobjekte"."LP_Plan" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Plan"();
CREATE TRIGGER "delete_LP_Plan" AFTER DELETE ON "LP_Basisobjekte"."LP_Plan" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Plan"();
CREATE TRIGGER "LP_Plan_propagate_name" AFTER UPDATE ON "LP_Basisobjekte"."LP_Plan" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."propagate_name_to_parent"();

-- -----------------------------------------------------
-- Table "LP_Basisobjekte"."LP_Plan_planArt"
-- -----------------------------------------------------
CREATE TABLE "LP_Basisobjekte"."LP_Plan_planArt" (
    "LP_Plan_gid" BIGINT NOT NULL,
    "planArt" INTEGER NULL ,
  PRIMARY KEY ("LP_Plan_gid", "planArt"),
  CONSTRAINT "fk_LP_Plan_planArt1"
    FOREIGN KEY ("LP_Plan_gid" )
    REFERENCES "LP_Basisobjekte"."LP_Plan" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_LP_Plan_planArt2"
    FOREIGN KEY ("planArt" )
    REFERENCES "LP_Basisobjekte"."LP_PlanArt" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
GRANT SELECT ON TABLE "LP_Basisobjekte"."LP_Plan_planArt" TO xp_gast;
GRANT ALL ON TABLE "LP_Basisobjekte"."LP_Plan_planArt" TO lp_user;
COMMENT ON TABLE  "LP_Basisobjekte"."LP_Plan_planArt" IS 'Typ des vorliegenden Landschaftsplans.';

-- -----------------------------------------------------
-- Table "LP_Basisobjekte"."LP_Bereich"
-- -----------------------------------------------------
CREATE  TABLE  "LP_Basisobjekte"."LP_Bereich" (
  "gid" BIGINT NOT NULL ,
  "name" VARCHAR (256) NOT NULL,
  "gehoertZuPlan" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_LP_Bereich_XP_Bereich1"
    FOREIGN KEY ("gid" )
    REFERENCES "XP_Basisobjekte"."XP_Bereich" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_LP_Bereich_LP_Plan1"
    FOREIGN KEY ("gehoertZuPlan" )
    REFERENCES "LP_Basisobjekte"."LP_Plan" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("XP_Basisobjekte"."XP_Geltungsbereich");

CREATE INDEX "idx_fk_LP_Bereich_LP_Plan1" ON "LP_Basisobjekte"."LP_Bereich" ("gehoertZuPlan") ;
CREATE INDEX "LP_Bereich_gidx" ON "LP_Basisobjekte"."LP_Bereich" using gist ("geltungsbereich");
GRANT SELECT ON TABLE "LP_Basisobjekte"."LP_Bereich" TO xp_gast;
GRANT ALL ON TABLE "LP_Basisobjekte"."LP_Bereich" TO lp_user;
COMMENT ON TABLE "LP_Basisobjekte"."LP_Bereich" IS 'Ein Bereich eines Landschaftsplans.';
COMMENT ON COLUMN "LP_Basisobjekte"."LP_Bereich"."gehoertZuPlan" IS '';
CREATE TRIGGER "change_to_LP_Bereich" BEFORE INSERT OR UPDATE ON "LP_Basisobjekte"."LP_Bereich" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Bereich"();
CREATE TRIGGER "delete_LP_Bereich" AFTER DELETE ON "LP_Basisobjekte"."LP_Bereich" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Bereich"();
CREATE TRIGGER "insert_into_LP_Bereich" BEFORE INSERT ON "LP_Basisobjekte"."LP_Bereich" FOR EACH ROW EXECUTE PROCEDURE "LP_Basisobjekte"."new_LP_Bereich"();
CREATE TRIGGER "LP_Bereich_propagate_name" AFTER UPDATE ON "LP_Basisobjekte"."LP_Bereich" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."propagate_name_to_parent"();

-- -----------------------------------------------------
-- Table "LP_Basisobjekte"."LP_Rechtscharakter"
-- -----------------------------------------------------
CREATE  TABLE  "LP_Basisobjekte"."LP_Rechtscharakter" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Code") );
GRANT SELECT ON TABLE "LP_Basisobjekte"."LP_Rechtscharakter" TO xp_gast;

-- -----------------------------------------------------
-- Table "LP_Basisobjekte"."LP_TextAbschnitt"
-- -----------------------------------------------------
CREATE  TABLE  "LP_Basisobjekte"."LP_TextAbschnitt" (
  "id" INTEGER NOT NULL ,
  "rechtscharakter" INTEGER NOT NULL DEFAULT 9998,
  PRIMARY KEY ("id") ,
  CONSTRAINT "fk_LP_Textabschnitt_parent"
    FOREIGN KEY ("id" )
    REFERENCES "XP_Basisobjekte"."XP_TextAbschnitt" ("id" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_lp_textabschnitt_lp_rechtscharakter1"
    FOREIGN KEY ("rechtscharakter" )
    REFERENCES "LP_Basisobjekte"."LP_Rechtscharakter" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
CREATE INDEX "idx_fk_fp_textabschnitt_fp_rechtscharakter1" ON "LP_Basisobjekte"."LP_TextAbschnitt" ("rechtscharakter") ;
GRANT SELECT ON TABLE "LP_Basisobjekte"."LP_TextAbschnitt" TO xp_gast;
GRANT ALL ON TABLE "LP_Basisobjekte"."LP_TextAbschnitt" TO lp_user;
COMMENT ON TABLE  "LP_Basisobjekte"."LP_TextAbschnitt" IS 'Texlich formulierter Inhalt eines Landschaftsplans, der einen anderen Rechtscharakter als das zugrunde liegende Fachobjekt hat (Attribut rechtscharakter des Fachobjektes), oder dem Plan als Ganzes zugeordnet ist.';
COMMENT ON COLUMN  "LP_Basisobjekte"."LP_TextAbschnitt"."id" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN  "LP_Basisobjekte"."LP_TextAbschnitt"."rechtscharakter" IS 'Rechtscharakter des textlich formulierten Planinhalts.';
CREATE TRIGGER "change_to_LP_TextAbschnitt" BEFORE INSERT OR UPDATE  ON "LP_Basisobjekte"."LP_TextAbschnitt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_TextAbschnitt"();
CREATE TRIGGER "delete_LP_TextAbschnitt" AFTER DELETE ON "LP_Basisobjekte"."LP_TextAbschnitt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_TextAbschnitt"();

-- -----------------------------------------------------
-- Table "LP_Basisobjekte"."LP_Objekt"
-- -----------------------------------------------------
CREATE  TABLE  "LP_Basisobjekte"."LP_Objekt" (
  "gid" BIGINT NOT NULL ,
  "rechtscharakter" INTEGER NOT NULL DEFAULT 9998,
  "konkretisierung" VARCHAR(256) NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_fp_objekt_lp_rechtscharakter1"
    FOREIGN KEY ("rechtscharakter" )
    REFERENCES "LP_Basisobjekte"."LP_Rechtscharakter" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT "fk_LP_Objekt_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "XP_Basisobjekte"."XP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE);

CREATE INDEX "idx_fk_fp_objekt_fp_rechtscharakter1" ON "LP_Basisobjekte"."LP_Objekt" ("rechtscharakter") ;
GRANT SELECT ON TABLE "LP_Basisobjekte"."LP_Objekt" TO xp_gast;
GRANT ALL ON TABLE "LP_Basisobjekte"."LP_Objekt" TO lp_user;
COMMENT ON TABLE  "LP_Basisobjekte"."LP_Objekt" IS 'Basisklasse für alle Fachobjekte des Flächennutzungsplans.';
COMMENT ON COLUMN  "LP_Basisobjekte"."LP_Objekt"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN  "LP_Basisobjekte"."LP_Objekt"."rechtscharakter" IS 'Rechtliche Charakterisierung des Planinhalts';
COMMENT ON COLUMN  "LP_Basisobjekte"."LP_Objekt"."konkretisierung" IS 'Textliche Konkretisierung der rechtlichen Charakterisierung..';
CREATE TRIGGER "change_to_LP_Objekt" BEFORE INSERT OR UPDATE ON "LP_Basisobjekte"."LP_Objekt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_LP_Objekt" AFTER DELETE ON "LP_Basisobjekte"."LP_Objekt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

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
-- Table "LP_Basisobjekte"."LP_Punktobjekt"
-- -----------------------------------------------------
CREATE  TABLE  "LP_Basisobjekte"."LP_Punktobjekt" (
  "gid" BIGINT NOT NULL ,
  "position" GEOMETRY(Multipoint,25832) NOT NULL ,
  "nordwinkel" INTEGER,
  PRIMARY KEY ("gid") );
COMMENT ON COLUMN "LP_Basisobjekte"."LP_Punktobjekt"."nordwinkel" IS 'Orientierung des Punktobjektes als Winkel gegen die Nordrichtung. Zählweise im geographischen Sinn (von Nord über Ost nach Süd und West).';
GRANT SELECT ON TABLE "LP_Basisobjekte"."LP_Punktobjekt" TO xp_gast;
GRANT ALL ON TABLE "LP_Basisobjekte"."LP_Punktobjekt" TO lp_user;
CREATE TRIGGER "LP_Punktobjekt_isAbstract" BEFORE INSERT ON "LP_Basisobjekte"."LP_Punktobjekt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isAbstract"();

-- -----------------------------------------------------
-- Table "LP_Basisobjekte"."LP_Linienobjekt"
-- -----------------------------------------------------
CREATE  TABLE  "LP_Basisobjekte"."LP_Linienobjekt" (
  "gid" BIGINT NOT NULL ,
  "position" GEOMETRY(MultiLinestring,25832) NOT NULL ,
  "flussrichtung" boolean,
  PRIMARY KEY ("gid") );
GRANT SELECT ON TABLE "LP_Basisobjekte"."LP_Linienobjekt" TO xp_gast;
GRANT ALL ON TABLE "LP_Basisobjekte"."LP_Linienobjekt" TO lp_user;
CREATE TRIGGER "LP_Linienobjekt_isAbstract" BEFORE INSERT ON "LP_Basisobjekte"."LP_Linienobjekt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isAbstract"();

-- -----------------------------------------------------
-- Table "LP_Basisobjekte"."LP_Flaechenobjekt"
-- -----------------------------------------------------
CREATE  TABLE  "LP_Basisobjekte"."LP_Flaechenobjekt" (
  "gid" BIGINT NOT NULL ,
  "position" GEOMETRY(Multipolygon,25832) NOT NULL ,
  PRIMARY KEY ("gid") );
GRANT SELECT ON TABLE "LP_Basisobjekte"."LP_Flaechenobjekt" TO xp_gast;
GRANT ALL ON TABLE "LP_Basisobjekte"."LP_Flaechenobjekt" TO lp_user;
CREATE TRIGGER "LP_Flaechenobjekt_isAbstract" BEFORE INSERT ON "LP_Basisobjekte"."LP_Flaechenobjekt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isAbstract"();

-- -----------------------------------------------------
-- Table "LP_Erholung"."LP_AllgGruenflaeche"
-- -----------------------------------------------------
CREATE  TABLE  "LP_Erholung"."LP_AllgGruenflaeche" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_LP_AllgGruenflaeche_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "LP_Basisobjekte"."LP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("LP_Basisobjekte"."LP_Flaechenobjekt");

GRANT SELECT ON TABLE "LP_Erholung"."LP_AllgGruenflaeche" TO xp_gast;
GRANT ALL ON TABLE "LP_Erholung"."LP_AllgGruenflaeche" TO lp_user;
COMMENT ON TABLE  "LP_Erholung"."LP_AllgGruenflaeche" IS 'Allgemeine Grünflächen.';
COMMENT ON COLUMN  "LP_Erholung"."LP_AllgGruenflaeche"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';

CREATE TRIGGER "change_to_LP_AllgGruenflaeche" BEFORE INSERT OR UPDATE ON "LP_Erholung"."LP_AllgGruenflaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_LP_AllgGruenflaeche" AFTER DELETE ON "LP_Erholung"."LP_AllgGruenflaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "LP_AllgGruenflaeche_Flaechenobjekt" BEFORE INSERT OR UPDATE ON "LP_Erholung"."LP_AllgGruenflaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."positionFollowsRHR"();

-- -----------------------------------------------------
-- Table "LP_Erholung"."LP_ErholungFreizeit"
-- -----------------------------------------------------
CREATE  TABLE  "LP_Erholung"."LP_ErholungFreizeit" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid"),
  CONSTRAINT "fk_LP_ErholungFreizeit_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "LP_Basisobjekte"."LP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE);

GRANT SELECT ON TABLE "LP_Erholung"."LP_ErholungFreizeit" TO xp_gast;
GRANT ALL ON TABLE "LP_Erholung"."LP_ErholungFreizeit" TO lp_user;
COMMENT ON TABLE  "LP_Erholung"."LP_ErholungFreizeit" IS 'Sonstige Gebiete, Objekte, Zweckbestimmungen oder Maßnahmen mit besonderen Funktionen für die landschaftsgebundene Erholung und Freizeit.';
COMMENT ON COLUMN  "LP_Erholung"."LP_ErholungFreizeit"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_LP_ErholungFreizeit" BEFORE INSERT OR UPDATE ON "LP_Erholung"."LP_ErholungFreizeit" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_LP_ErholungFreizeit" AFTER DELETE ON "LP_Erholung"."LP_ErholungFreizeit" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "LP_Erholung"."LP_ErholungFreizeitFunktionen"
-- -----------------------------------------------------
CREATE  TABLE  "LP_Erholung"."LP_ErholungFreizeitFunktionen" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Code") );
GRANT SELECT ON TABLE "LP_Erholung"."LP_ErholungFreizeitFunktionen" TO xp_gast;

-- -----------------------------------------------------
-- Table "LP_Erholung"."LP_ErholungFreizeit_funktion"
-- -----------------------------------------------------
CREATE  TABLE  "LP_Erholung"."LP_ErholungFreizeit_funktion" (
  "LP_ErholungFreizeit_gid" BIGINT NOT NULL ,
  "funktion" INTEGER NOT NULL ,
  PRIMARY KEY ("LP_ErholungFreizeit_gid", "funktion"),
  CONSTRAINT "fk_LP_ErholungFreizeit_funktion1"
    FOREIGN KEY ("LP_ErholungFreizeit_gid" )
    REFERENCES "LP_Erholung"."LP_ErholungFreizeit" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_LP_ErholungFreizeit_funktion2"
    FOREIGN KEY ("funktion" )
    REFERENCES "LP_Erholung"."LP_ErholungFreizeitFunktionen" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
GRANT SELECT ON TABLE "LP_Erholung"."LP_ErholungFreizeit_funktion" TO xp_gast;
GRANT ALL ON TABLE "LP_Erholung"."LP_ErholungFreizeit_funktion" TO lp_user;
COMMENT ON TABLE  "LP_Erholung"."LP_ErholungFreizeit_funktion" IS 'Funktion der Fläche.';

-- -----------------------------------------------------
-- Table "LP_Erholung"."LP_ErholungFreizeitDetailFunktionen"
-- -----------------------------------------------------
CREATE  TABLE  "LP_Erholung"."LP_ErholungFreizeitDetailFunktionen" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(256) NOT NULL ,
  PRIMARY KEY ("Code") );
GRANT SELECT ON TABLE "LP_Erholung"."LP_ErholungFreizeitDetailFunktionen" TO xp_gast;
GRANT ALL ON TABLE "LP_Erholung"."LP_ErholungFreizeitDetailFunktionen" TO lp_user;
CREATE TRIGGER "ins_upd_LP_ErholungFreizeitDetailFunktionen" BEFORE INSERT OR UPDATE ON "LP_Erholung"."LP_ErholungFreizeitDetailFunktionen" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isCodeList"();

-- -----------------------------------------------------
-- Table "LP_Erholung"."LP_ErholungFreizeit_detaillierteFunktion"
-- -----------------------------------------------------
CREATE  TABLE  "LP_Erholung"."LP_ErholungFreizeit_detaillierteFunktion" (
  "LP_ErholungFreizeit_gid" BIGINT NOT NULL ,
  "detaillierteFunktion" INTEGER NOT NULL ,
  PRIMARY KEY ("LP_ErholungFreizeit_gid", "detaillierteFunktion"),
  CONSTRAINT "fk_LP_ErholungFreizeit_detaillierteFunktion1"
    FOREIGN KEY ("LP_ErholungFreizeit_gid" )
    REFERENCES "LP_Erholung"."LP_ErholungFreizeit" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_LP_ErholungFreizeit_detaillierteFunktion2"
    FOREIGN KEY ("detaillierteFunktion" )
    REFERENCES "LP_Erholung"."LP_ErholungFreizeitDetailFunktionen" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
GRANT SELECT ON TABLE "LP_Erholung"."LP_ErholungFreizeit_detaillierteFunktion" TO xp_gast;
GRANT ALL ON TABLE "LP_Erholung"."LP_ErholungFreizeit_detaillierteFunktion" TO lp_user;
COMMENT ON TABLE  "LP_Erholung"."LP_ErholungFreizeit_detaillierteFunktion" IS 'Über eine CodeList definierte zusätzliche Funktion der Fläche.';

-- -----------------------------------------------------
-- Table "LP_Erholung"."LP_ErholungFreizeitFlaeche"
-- -----------------------------------------------------
CREATE  TABLE  "LP_Erholung"."LP_ErholungFreizeitFlaeche" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_LP_ErholungFreizeitFlaeche_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "LP_Erholung"."LP_ErholungFreizeit" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("LP_Basisobjekte"."LP_Flaechenobjekt");

GRANT SELECT ON TABLE "LP_Erholung"."LP_ErholungFreizeitFlaeche" TO xp_gast;
GRANT ALL ON TABLE "LP_Erholung"."LP_ErholungFreizeitFlaeche" TO lp_user;
COMMENT ON COLUMN "LP_Erholung"."LP_ErholungFreizeitFlaeche"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_LP_ErholungFreizeitFlaeche" BEFORE INSERT OR UPDATE ON "LP_Erholung"."LP_ErholungFreizeitFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_LP_ErholungFreizeitFlaeche" AFTER DELETE ON "LP_Erholung"."LP_ErholungFreizeitFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "LP_ErholungFreizeitFlaeche_Flaechenobjekt" BEFORE INSERT OR UPDATE ON "LP_Erholung"."LP_ErholungFreizeitFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."positionFollowsRHR"();

-- -----------------------------------------------------
-- Table "LP_Erholung"."LP_ErholungFreizeitLinie"
-- -----------------------------------------------------
CREATE  TABLE  "LP_Erholung"."LP_ErholungFreizeitLinie" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_LP_ErholungFreizeitLinie_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "LP_Erholung"."LP_ErholungFreizeit" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("LP_Basisobjekte"."LP_Linienobjekt");

GRANT SELECT ON TABLE "LP_Erholung"."LP_ErholungFreizeitLinie" TO xp_gast;
GRANT ALL ON TABLE "LP_Erholung"."LP_ErholungFreizeitLinie" TO lp_user;
COMMENT ON COLUMN "LP_Erholung"."LP_ErholungFreizeitLinie"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_LP_ErholungFreizeitLinie" BEFORE INSERT OR UPDATE ON "LP_Erholung"."LP_ErholungFreizeitLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_LP_ErholungFreizeitLinie" AFTER DELETE ON "LP_Erholung"."LP_ErholungFreizeitLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "LP_Erholung"."LP_ErholungFreizeitPunkt"
-- -----------------------------------------------------
CREATE  TABLE  "LP_Erholung"."LP_ErholungFreizeitPunkt" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_LP_ErholungFreizeitPunkt_parent"
    FOREIGN KEY ("gid")
    REFERENCES "LP_Erholung"."LP_ErholungFreizeit" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("LP_Basisobjekte"."LP_Punktobjekt");

GRANT SELECT ON TABLE "LP_Erholung"."LP_ErholungFreizeitPunkt" TO xp_gast;
GRANT ALL ON TABLE "LP_Erholung"."LP_ErholungFreizeitPunkt" TO lp_user;
COMMENT ON COLUMN "LP_Erholung"."LP_ErholungFreizeitPunkt"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_LP_ErholungFreizeitPunkt" BEFORE INSERT OR UPDATE ON "LP_Erholung"."LP_ErholungFreizeitPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_LP_ErholungFreizeitPunkt" AFTER DELETE ON "LP_Erholung"."LP_ErholungFreizeitPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "LP_MassnahmenNaturschutz"."LP_AnpflanzungBindungErhaltung"
-- -----------------------------------------------------
CREATE  TABLE  "LP_MassnahmenNaturschutz"."LP_AnpflanzungBindungErhaltung" (
  "gid" BIGINT NOT NULL ,
  "massnahme" INTEGER,
  "kronendurchmesser" NUMERIC(6,2) ,
  "pflanztiefe" NUMERIC(6,2) ,
  "istAusgleich" BOOLEAN,
  "mindesthoehe" NUMERIC(6,2),
  "anzahl" INTEGER,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_LP_AnpflanzungBindungErhaltung_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "LP_Basisobjekte"."LP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_LP_AnpflanzungBindungErhaltung_massnahme"
    FOREIGN KEY ("massnahme" )
    REFERENCES "XP_Enumerationen"."XP_ABEMassnahmenTypen" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE);

GRANT SELECT ON TABLE "LP_MassnahmenNaturschutz"."LP_AnpflanzungBindungErhaltung" TO xp_gast;
GRANT ALL ON TABLE "LP_MassnahmenNaturschutz"."LP_AnpflanzungBindungErhaltung" TO lp_user;
COMMENT ON TABLE  "LP_MassnahmenNaturschutz"."LP_AnpflanzungBindungErhaltung" IS 'Für einzelne Flächen oder für ein Bebauungsplangebiet oder Teile davon sowie für Teile baulicher Anlagen mit Ausnahme der für landwirtschaftliche Nutzungen oder Wald festgesetzten Flächen:\n
a) Festsetzung des Anpflanzens von Bäumen, Sträuchern und sonstigen Bepflanzungen;\n
b) Festsetzung von Bindungen für Bepflanzungen und für die Erhaltung von Bäumen, Sträuchern und sonstigen Bepflanzungen sowie von Gewässern; (§9 Abs. 1 Nr. 25 und Abs. 4 BauGB)';
COMMENT ON COLUMN  "LP_MassnahmenNaturschutz"."LP_AnpflanzungBindungErhaltung"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN  "LP_MassnahmenNaturschutz"."LP_AnpflanzungBindungErhaltung"."massnahme" IS 'Art der Maßnahme';
COMMENT ON COLUMN  "LP_MassnahmenNaturschutz"."LP_AnpflanzungBindungErhaltung"."kronendurchmesser" IS 'Durchmesser der Baumkrone bei zu erhaltenden Bäumen.';
COMMENT ON COLUMN  "LP_MassnahmenNaturschutz"."LP_AnpflanzungBindungErhaltung"."pflanztiefe" IS 'Pflanztiefe';
COMMENT ON COLUMN  "LP_MassnahmenNaturschutz"."LP_AnpflanzungBindungErhaltung"."istAusgleich" IS 'Gibt an, ob die Fläche oder Maßnahme zum Ausgleich von Eingriffen genutzt wird.';
COMMENT ON COLUMN  "LP_MassnahmenNaturschutz"."LP_AnpflanzungBindungErhaltung"."mindesthoehe" IS 'Mindesthöhe einer Pflanze (z.B. Mindesthöhe einer zu pflanzenden Hecke)';
COMMENT ON COLUMN "LP_MassnahmenNaturschutz"."LP_AnpflanzungBindungErhaltung"."anzahl" IS 'Anzahl der anzupflanzenden Objekte';
CREATE TRIGGER "change_to_LP_AnpflanzungBindungErhaltung" BEFORE INSERT OR UPDATE ON "LP_MassnahmenNaturschutz"."LP_AnpflanzungBindungErhaltung" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_LP_AnpflanzungBindungErhaltung" AFTER DELETE ON "LP_MassnahmenNaturschutz"."LP_AnpflanzungBindungErhaltung" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "LP_MassnahmenNaturschutz"."LP_AnpflanzungBindungErhaltung_gegenstand"
-- -----------------------------------------------------
CREATE  TABLE  "LP_MassnahmenNaturschutz"."LP_AnpflanzungBindungErhaltung_gegenstand" (
  "LP_AnpflanzungBindungErhaltung_gid" BIGINT NOT NULL ,
  "gegenstand" INTEGER NOT NULL ,
  PRIMARY KEY ("LP_AnpflanzungBindungErhaltung_gid", "gegenstand"),
  CONSTRAINT "fk_LP_AnpflanzungBindungErhaltung_gegenstand1"
    FOREIGN KEY ("LP_AnpflanzungBindungErhaltung_gid" )
    REFERENCES "LP_MassnahmenNaturschutz"."LP_AnpflanzungBindungErhaltung" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_LP_AnpflanzungBindungErhaltung_gegenstand2"
    FOREIGN KEY ("gegenstand" )
    REFERENCES "XP_Enumerationen"."XP_AnpflanzungBindungErhaltungsGegenstand" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
GRANT SELECT ON TABLE "LP_MassnahmenNaturschutz"."LP_AnpflanzungBindungErhaltung_gegenstand" TO xp_gast;
GRANT ALL ON TABLE "LP_MassnahmenNaturschutz"."LP_AnpflanzungBindungErhaltung_gegenstand" TO lp_user;
COMMENT ON TABLE  "LP_MassnahmenNaturschutz"."LP_AnpflanzungBindungErhaltung_gegenstand" IS 'Gegenstände der Maßnahme';

-- -----------------------------------------------------
-- Table "LP_MassnahmenNaturschutz"."LP_Pflanzart"
-- -----------------------------------------------------
CREATE  TABLE  "LP_MassnahmenNaturschutz"."LP_Pflanzart" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Code") );
GRANT SELECT ON TABLE "LP_MassnahmenNaturschutz"."LP_Pflanzart" TO xp_gast;
GRANT ALL ON TABLE "LP_MassnahmenNaturschutz"."LP_Pflanzart" TO lp_user;
CREATE TRIGGER "ins_upd_LP_Pflanzart" BEFORE INSERT OR UPDATE ON "LP_MassnahmenNaturschutz"."LP_Pflanzart" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isCodeList"();

-- -----------------------------------------------------
-- Table "LP_MassnahmenNaturschutz"."LP_AnpflanzungBindungErhaltung_pflanzart"
-- -----------------------------------------------------
CREATE  TABLE  "LP_MassnahmenNaturschutz"."LP_AnpflanzungBindungErhaltung_pflanzart" (
  "LP_AnpflanzungBindungErhaltung_gid" BIGINT NOT NULL ,
  "pflanzart" INTEGER NOT NULL ,
  PRIMARY KEY ("LP_AnpflanzungBindungErhaltung_gid", "pflanzart"),
  CONSTRAINT "fk_LP_AnpflanzungBindungErhaltung_pflanzart1"
    FOREIGN KEY ("LP_AnpflanzungBindungErhaltung_gid" )
    REFERENCES "LP_MassnahmenNaturschutz"."LP_AnpflanzungBindungErhaltung" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_LP_AnpflanzungBindungErhaltung_pflanzart2"
    FOREIGN KEY ("pflanzart" )
    REFERENCES "LP_MassnahmenNaturschutz"."LP_Pflanzart" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
GRANT SELECT ON TABLE "LP_MassnahmenNaturschutz"."LP_AnpflanzungBindungErhaltung_pflanzart" TO xp_gast;
GRANT ALL ON TABLE "LP_MassnahmenNaturschutz"."LP_AnpflanzungBindungErhaltung_pflanzart" TO lp_user;
COMMENT ON TABLE  "LP_MassnahmenNaturschutz"."LP_AnpflanzungBindungErhaltung_pflanzart" IS 'Botanische Angabe der zu erhaltenden bzw. der zu pflanzenden Pflanzen.';

-- -----------------------------------------------------
-- Table "LP_MassnahmenNaturschutz"."LP_AnpflanzungBindungErhaltungFlaeche"
-- -----------------------------------------------------
CREATE  TABLE  "LP_MassnahmenNaturschutz"."LP_AnpflanzungBindungErhaltungFlaeche" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_LP_AnpflanzungBindungErhaltungFlaeche_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "LP_MassnahmenNaturschutz"."LP_AnpflanzungBindungErhaltung" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("LP_Basisobjekte"."LP_Flaechenobjekt");

GRANT SELECT ON TABLE "LP_MassnahmenNaturschutz"."LP_AnpflanzungBindungErhaltungFlaeche" TO xp_gast;
GRANT ALL ON TABLE "LP_MassnahmenNaturschutz"."LP_AnpflanzungBindungErhaltungFlaeche" TO lp_user;
CREATE INDEX "LP_AnpflanzungBindungErhaltungFlaeche_gidx" ON "LP_MassnahmenNaturschutz"."LP_AnpflanzungBindungErhaltungFlaeche" using gist ("position");
CREATE TRIGGER "change_to_LP_AnpflanzungBindungErhaltungFlaeche" BEFORE INSERT OR UPDATE ON "LP_MassnahmenNaturschutz"."LP_AnpflanzungBindungErhaltungFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_LP_AnpflanzungBindungErhaltungFlaeche" AFTER DELETE ON "LP_MassnahmenNaturschutz"."LP_AnpflanzungBindungErhaltungFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "LP_AnpflanzungBindungErhaltungFlaeche_Flaechenobjekt" BEFORE INSERT OR UPDATE ON "LP_MassnahmenNaturschutz"."LP_AnpflanzungBindungErhaltungFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."positionFollowsRHR"();

-- -----------------------------------------------------
-- Table "LP_MassnahmenNaturschutz"."LP_AnpflanzungBindungErhaltungLinie"
-- -----------------------------------------------------
CREATE  TABLE  "LP_MassnahmenNaturschutz"."LP_AnpflanzungBindungErhaltungLinie" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_LP_AnpflanzungBindungErhaltungLinie_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "LP_MassnahmenNaturschutz"."LP_AnpflanzungBindungErhaltung" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("LP_Basisobjekte"."LP_Linienobjekt");

GRANT SELECT ON TABLE "LP_MassnahmenNaturschutz"."LP_AnpflanzungBindungErhaltungLinie" TO xp_gast;
GRANT ALL ON TABLE "LP_MassnahmenNaturschutz"."LP_AnpflanzungBindungErhaltungLinie" TO lp_user;
CREATE INDEX "LP_AnpflanzungBindungErhaltungLinie_gidx" ON "LP_MassnahmenNaturschutz"."LP_AnpflanzungBindungErhaltungLinie" using gist ("position");
CREATE TRIGGER "change_to_LP_AnpflanzungBindungErhaltungLinie" BEFORE INSERT OR UPDATE ON "LP_MassnahmenNaturschutz"."LP_AnpflanzungBindungErhaltungLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_LP_AnpflanzungBindungErhaltungLinie" AFTER DELETE ON "LP_MassnahmenNaturschutz"."LP_AnpflanzungBindungErhaltungLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "LP_MassnahmenNaturschutz"."LP_AnpflanzungBindungErhaltungPunkt"
-- -----------------------------------------------------
CREATE  TABLE  "LP_MassnahmenNaturschutz"."LP_AnpflanzungBindungErhaltungPunkt" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_LP_AnpflanzungBindungErhaltungPunkt_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "LP_MassnahmenNaturschutz"."LP_AnpflanzungBindungErhaltung" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("LP_Basisobjekte"."LP_Punktobjekt");

GRANT SELECT ON TABLE "LP_MassnahmenNaturschutz"."LP_AnpflanzungBindungErhaltungPunkt" TO xp_gast;
GRANT ALL ON TABLE "LP_MassnahmenNaturschutz"."LP_AnpflanzungBindungErhaltungPunkt" TO lp_user;
CREATE INDEX "LP_AnpflanzungBindungErhaltungPunkt_gidx" ON "LP_MassnahmenNaturschutz"."LP_AnpflanzungBindungErhaltungPunkt" using gist ("position");
CREATE TRIGGER "change_to_LP_AnpflanzungBindungErhaltungPunkt" BEFORE INSERT OR UPDATE ON "LP_MassnahmenNaturschutz"."LP_AnpflanzungBindungErhaltungPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_LP_AnpflanzungBindungErhaltungPunkt" AFTER DELETE ON "LP_MassnahmenNaturschutz"."LP_AnpflanzungBindungErhaltungPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "LP_MassnahmenNaturschutz"."LP_Ausgleich"
-- -----------------------------------------------------
CREATE  TABLE  "LP_MassnahmenNaturschutz"."LP_Ausgleich" (
  "gid" BIGINT NOT NULL ,
  "ziel" INTEGER NULL ,
  "massnahme" VARCHAR(1024) NULL ,
  "massnahmeKuerzel" VARCHAR(64) NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_LP_Ausgleich_XP_SPEZiele1"
    FOREIGN KEY ("ziel" )
    REFERENCES "XP_Enumerationen"."XP_SPEZiele" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_LP_Ausgleich_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "LP_Basisobjekte"."LP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE);

GRANT SELECT ON TABLE "LP_MassnahmenNaturschutz"."LP_Ausgleich" TO xp_gast;
GRANT ALL ON TABLE "LP_MassnahmenNaturschutz"."LP_Ausgleich" TO lp_user;
COMMENT ON TABLE  "LP_MassnahmenNaturschutz"."LP_Ausgleich" IS 'Flächen und Maßnahmen zum Ausgleich von Eingriffen im Sinne des §8 und 8A BNatSchG (in Verbindung mit §1a BauGB, Ausgleichs- und Ersatzmaßnahmen).';
COMMENT ON COLUMN  "LP_MassnahmenNaturschutz"."LP_Ausgleich"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN  "LP_MassnahmenNaturschutz"."LP_Ausgleich"."ziel" IS 'Unterscheidung nach den Zielen "Schutz, Pflege" und "Entwicklung".';
COMMENT ON COLUMN  "LP_MassnahmenNaturschutz"."LP_Ausgleich"."massnahme" IS 'Durchzuführende Maßnahme (Textform)';
COMMENT ON COLUMN  "LP_MassnahmenNaturschutz"."LP_Ausgleich"."massnahmeKuerzel" IS 'Kürzel der durchzuführenden Maßnahme.';
CREATE INDEX "idx_fk_LP_Ausgleich_XP_SPEZiele1" ON "LP_MassnahmenNaturschutz"."LP_Ausgleich" ("ziel") ;
CREATE TRIGGER "change_to_LP_Ausgleich" BEFORE INSERT OR UPDATE ON "LP_MassnahmenNaturschutz"."LP_Ausgleich" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_LP_Ausgleich" AFTER DELETE ON "LP_MassnahmenNaturschutz"."LP_Ausgleich" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "LP_MassnahmenNaturschutz"."LP_AusgleichFlaeche"
-- -----------------------------------------------------
CREATE  TABLE  "LP_MassnahmenNaturschutz"."LP_AusgleichFlaeche" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_LP_AusgleichFlaeche_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "LP_MassnahmenNaturschutz"."LP_Ausgleich" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("LP_Basisobjekte"."LP_Flaechenobjekt");

GRANT SELECT ON TABLE "LP_MassnahmenNaturschutz"."LP_AusgleichFlaeche" TO xp_gast;
GRANT ALL ON TABLE "LP_MassnahmenNaturschutz"."LP_AusgleichFlaeche" TO lp_user;
CREATE INDEX "LP_AusgleichFlaeche_gidx" ON "LP_MassnahmenNaturschutz"."LP_AusgleichFlaeche" using gist ("position");
CREATE TRIGGER "change_to_LP_AusgleichFlaeche" BEFORE INSERT OR UPDATE ON "LP_MassnahmenNaturschutz"."LP_AusgleichFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_LP_AusgleichFlaeche" AFTER DELETE ON "LP_MassnahmenNaturschutz"."LP_AusgleichFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "LP_AusgleichFlaeche_Flaechenobjekt" BEFORE INSERT OR UPDATE ON "LP_MassnahmenNaturschutz"."LP_AusgleichFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."positionFollowsRHR"();

-- -----------------------------------------------------
-- Table "LP_MassnahmenNaturschutz"."LP_AusgleichLinie"
-- -----------------------------------------------------
CREATE  TABLE  "LP_MassnahmenNaturschutz"."LP_AusgleichLinie" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_LP_AusgleichLinie_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "LP_MassnahmenNaturschutz"."LP_Ausgleich" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("LP_Basisobjekte"."LP_Linienobjekt");

GRANT SELECT ON TABLE "LP_MassnahmenNaturschutz"."LP_AusgleichLinie" TO xp_gast;
GRANT ALL ON TABLE "LP_MassnahmenNaturschutz"."LP_AusgleichLinie" TO lp_user;
CREATE INDEX "LP_AusgleichLinie_gidx" ON "LP_MassnahmenNaturschutz"."LP_AusgleichLinie" using gist ("position");
CREATE TRIGGER "change_to_LP_AusgleichLinie" BEFORE INSERT OR UPDATE ON "LP_MassnahmenNaturschutz"."LP_AusgleichLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_LP_AusgleichLinie" AFTER DELETE ON "LP_MassnahmenNaturschutz"."LP_AusgleichLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "LP_MassnahmenNaturschutz"."LP_AusgleichPunkt"
-- -----------------------------------------------------
CREATE  TABLE  "LP_MassnahmenNaturschutz"."LP_AusgleichPunkt" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_LP_AusgleichPunkt_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "LP_MassnahmenNaturschutz"."LP_Ausgleich" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("LP_Basisobjekte"."LP_Punktobjekt");

GRANT SELECT ON TABLE "LP_MassnahmenNaturschutz"."LP_AusgleichPunkt" TO xp_gast;
GRANT ALL ON TABLE "LP_MassnahmenNaturschutz"."LP_AusgleichPunkt" TO lp_user;
CREATE INDEX "LP_AusgleichPunkt_gidx" ON "LP_MassnahmenNaturschutz"."LP_AusgleichPunkt" using gist ("position");
CREATE TRIGGER "change_to_LP_AusgleichPunkt" BEFORE INSERT OR UPDATE ON "LP_MassnahmenNaturschutz"."LP_AusgleichPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_LP_AusgleichPunkt" AFTER DELETE ON "LP_MassnahmenNaturschutz"."LP_AusgleichPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "LP_MassnahmenNaturschutz"."LP_Regelungen"
-- -----------------------------------------------------
CREATE  TABLE  "LP_MassnahmenNaturschutz"."LP_Regelungen" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Code") );
GRANT SELECT ON TABLE "LP_MassnahmenNaturschutz"."LP_Regelungen" TO xp_gast;

-- -----------------------------------------------------
-- Table "LP_MassnahmenNaturschutz"."LP_NutzungserfordernisRegelung"
-- -----------------------------------------------------
CREATE  TABLE  "LP_MassnahmenNaturschutz"."LP_NutzungserfordernisRegelung" (
  "gid" BIGINT NOT NULL ,
  "ziel" INTEGER NULL ,
  "regelung" INTEGER NULL ,
  "erfordernisRegelung" VARCHAR(256) NULL ,
  "erfordernisRegelungKuerzel" VARCHAR(64) NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_LP_NutzungserfordernisRegelung_XP_SPEZiele1"
    FOREIGN KEY ("ziel" )
    REFERENCES "XP_Enumerationen"."XP_SPEZiele" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_LP_NutzungserfordernisRegelung_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "LP_Basisobjekte"."LP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_LP_NutzungserfordernisRegelung_LP_Regelungen1"
    FOREIGN KEY ("regelung" )
    REFERENCES "LP_MassnahmenNaturschutz"."LP_Regelungen" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE);

GRANT SELECT ON TABLE "LP_MassnahmenNaturschutz"."LP_NutzungserfordernisRegelung" TO xp_gast;
GRANT ALL ON TABLE "LP_MassnahmenNaturschutz"."LP_NutzungserfordernisRegelung" TO lp_user;
COMMENT ON TABLE  "LP_MassnahmenNaturschutz"."LP_NutzungserfordernisRegelung" IS 'Flächen mit Nutzungserfordernissen und Nutzungsregelungen zum Schutz, zur Pflege und zur Entwicklung von Natur und Landschaft.';
COMMENT ON COLUMN  "LP_MassnahmenNaturschutz"."LP_NutzungserfordernisRegelung"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN  "LP_MassnahmenNaturschutz"."LP_NutzungserfordernisRegelung"."ziel" IS 'Unterscheidung nach den Zielen "Schutz, Pflege" und "Entwicklung".';
COMMENT ON COLUMN  "LP_MassnahmenNaturschutz"."LP_NutzungserfordernisRegelung"."regelung" IS 'Nutzungsregelung (Klassifikation).';
COMMENT ON COLUMN  "LP_MassnahmenNaturschutz"."LP_NutzungserfordernisRegelung"."erfordernisRegelung" IS 'Nutzungserfordernis oder -Regelung (Textform).';
COMMENT ON COLUMN  "LP_MassnahmenNaturschutz"."LP_NutzungserfordernisRegelung"."erfordernisRegelungKuerzel" IS 'Nutzungserfordernis oder -Regelung (Kürzel).';
CREATE INDEX "idx_fk_LP_NutzungserfordernisRegelung_XP_SPEZiele1" ON "LP_MassnahmenNaturschutz"."LP_NutzungserfordernisRegelung" ("ziel") ;
CREATE TRIGGER "change_to_LP_NutzungserfordernisRegelung" BEFORE INSERT OR UPDATE ON "LP_MassnahmenNaturschutz"."LP_NutzungserfordernisRegelung" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_LP_NutzungserfordernisRegelung" AFTER DELETE ON "LP_MassnahmenNaturschutz"."LP_NutzungserfordernisRegelung" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "LP_MassnahmenNaturschutz"."LP_NutzungserfordernisRegelungFlaeche"
-- -----------------------------------------------------
CREATE  TABLE  "LP_MassnahmenNaturschutz"."LP_NutzungserfordernisRegelungFlaeche" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_LP_NutzungserfordernisRegelungFlaeche_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "LP_MassnahmenNaturschutz"."LP_NutzungserfordernisRegelung" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("LP_Basisobjekte"."LP_Flaechenobjekt");

GRANT SELECT ON TABLE "LP_MassnahmenNaturschutz"."LP_NutzungserfordernisRegelungFlaeche" TO xp_gast;
GRANT ALL ON TABLE "LP_MassnahmenNaturschutz"."LP_NutzungserfordernisRegelungFlaeche" TO lp_user;
CREATE INDEX "LP_NutzungserfordernisRegelungFlaeche_gidx" ON "LP_MassnahmenNaturschutz"."LP_NutzungserfordernisRegelungFlaeche" using gist ("position");
CREATE TRIGGER "change_to_LP_NutzungserfordernisRegelungFlaeche" BEFORE INSERT OR UPDATE ON "LP_MassnahmenNaturschutz"."LP_NutzungserfordernisRegelungFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_LP_NutzungserfordernisRegelungFlaeche" AFTER DELETE ON "LP_MassnahmenNaturschutz"."LP_NutzungserfordernisRegelungFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "LP_NutzungserfordernisRegelungFlaeche_Flaechenobjekt" BEFORE INSERT OR UPDATE ON "LP_MassnahmenNaturschutz"."LP_NutzungserfordernisRegelungFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."positionFollowsRHR"();

-- -----------------------------------------------------
-- Table "LP_MassnahmenNaturschutz"."LP_NutzungserfordernisRegelungLinie"
-- -----------------------------------------------------
CREATE  TABLE  "LP_MassnahmenNaturschutz"."LP_NutzungserfordernisRegelungLinie" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_LP_NutzungserfordernisRegelungLinie_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "LP_MassnahmenNaturschutz"."LP_NutzungserfordernisRegelung" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("LP_Basisobjekte"."LP_Linienobjekt");

GRANT SELECT ON TABLE "LP_MassnahmenNaturschutz"."LP_NutzungserfordernisRegelungLinie" TO xp_gast;
GRANT ALL ON TABLE "LP_MassnahmenNaturschutz"."LP_NutzungserfordernisRegelungLinie" TO lp_user;
CREATE INDEX "LP_NutzungserfordernisRegelungLinie_gidx" ON "LP_MassnahmenNaturschutz"."LP_NutzungserfordernisRegelungLinie" using gist ("position");
CREATE TRIGGER "change_to_LP_NutzungserfordernisRegelungLinie" BEFORE INSERT OR UPDATE ON "LP_MassnahmenNaturschutz"."LP_NutzungserfordernisRegelungLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_LP_NutzungserfordernisRegelungLinie" AFTER DELETE ON "LP_MassnahmenNaturschutz"."LP_NutzungserfordernisRegelungLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "LP_MassnahmenNaturschutz"."LP_NutzungserfordernisRegelungPunkt"
-- -----------------------------------------------------
CREATE  TABLE  "LP_MassnahmenNaturschutz"."LP_NutzungserfordernisRegelungPunkt" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_LP_NutzungserfordernisRegelungPunkt_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "LP_MassnahmenNaturschutz"."LP_NutzungserfordernisRegelung" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("LP_Basisobjekte"."LP_Punktobjekt");

GRANT SELECT ON TABLE "LP_MassnahmenNaturschutz"."LP_NutzungserfordernisRegelungPunkt" TO xp_gast;
GRANT ALL ON TABLE "LP_MassnahmenNaturschutz"."LP_NutzungserfordernisRegelungPunkt" TO lp_user;
CREATE INDEX "LP_NutzungserfordernisRegelungPunkt_gidx" ON "LP_MassnahmenNaturschutz"."LP_NutzungserfordernisRegelungPunkt" using gist ("position");
CREATE TRIGGER "change_to_LP_NutzungserfordernisRegelungPunkt" BEFORE INSERT OR UPDATE ON "LP_MassnahmenNaturschutz"."LP_NutzungserfordernisRegelungPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_LP_NutzungserfordernisRegelungPunkt" AFTER DELETE ON "LP_MassnahmenNaturschutz"."LP_NutzungserfordernisRegelungPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "LP_MassnahmenNaturschutz"."LP_SchutzPflegeEntwicklung"
-- -----------------------------------------------------
CREATE  TABLE  "LP_MassnahmenNaturschutz"."LP_SchutzPflegeEntwicklung" (
  "gid" BIGINT NOT NULL ,
  "ziel" INTEGER NULL ,
  "massnahme" INTEGER NULL ,
  "massnahmeText" VARCHAR(1024) NULL ,
  "massnahmeKuerzel" VARCHAR(64) NULL ,
  "istAusgleich" BOOLEAN NULL,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_LP_SchutzPflegeEntwicklung_XP_SPEZiele1"
    FOREIGN KEY ("ziel" )
    REFERENCES "XP_Enumerationen"."XP_SPEZiele" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_LP_SchutzPflegeEntwicklung_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "LP_Basisobjekte"."LP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_LP_SchutzPflegeEntwicklung_XP_SPEMassnahmenTypen1"
    FOREIGN KEY ("massnahme" )
    REFERENCES "XP_Basisobjekte"."XP_SPEMassnahmenTypen" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE);

GRANT SELECT ON TABLE "LP_MassnahmenNaturschutz"."LP_SchutzPflegeEntwicklung" TO xp_gast;
GRANT ALL ON TABLE "LP_MassnahmenNaturschutz"."LP_SchutzPflegeEntwicklung" TO lp_user;
COMMENT ON TABLE  "LP_MassnahmenNaturschutz"."LP_SchutzPflegeEntwicklung" IS 'Sonstige Flächen und Maßnahmen zum Schutz, zur Pflege und zur Entwicklung von Natur und Landschaft, soweit sie nicht durch die Klasse LP_NutzungserfordernisRegelung modelliert werden.';
COMMENT ON COLUMN  "LP_MassnahmenNaturschutz"."LP_SchutzPflegeEntwicklung"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN  "LP_MassnahmenNaturschutz"."LP_SchutzPflegeEntwicklung"."ziel" IS 'Unterscheidung nach den Zielen "Schutz, Pflege" und "Entwicklung".';
COMMENT ON COLUMN  "LP_MassnahmenNaturschutz"."LP_SchutzPflegeEntwicklung"."massnahme" IS 'Durchzuführende Maßnahme (Klassifikation).';
COMMENT ON COLUMN  "LP_MassnahmenNaturschutz"."LP_SchutzPflegeEntwicklung"."massnahmeText" IS 'Durchzuführende Maßnahme (Textform).';
COMMENT ON COLUMN  "LP_MassnahmenNaturschutz"."LP_SchutzPflegeEntwicklung"."massnahmeKuerzel" IS 'Kürzel der durchzuführenden Maßnahme.';
COMMENT ON COLUMN  "LP_MassnahmenNaturschutz"."LP_SchutzPflegeEntwicklung"."istAusgleich" IS 'Gibt an, ob die Maßnahme zum Ausgleich von Eingriffen genutzt wird.';
CREATE INDEX "idx_fk_LP_SchutzPflegeEntwicklung_XP_SPEZiele1" ON "LP_MassnahmenNaturschutz"."LP_SchutzPflegeEntwicklung" ("ziel") ;
CREATE INDEX "idx_fk_LP_SchutzPflegeEntwicklung_externeReferenz1" ON "LP_MassnahmenNaturschutz"."LP_SchutzPflegeEntwicklung" ("massnahme") ;
CREATE TRIGGER "change_to_LP_SchutzPflegeEntwicklung" BEFORE INSERT OR UPDATE ON "LP_MassnahmenNaturschutz"."LP_SchutzPflegeEntwicklung" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_LP_SchutzPflegeEntwicklung" AFTER DELETE ON "LP_MassnahmenNaturschutz"."LP_SchutzPflegeEntwicklung" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "LP_MassnahmenNaturschutz"."LP_SchutzPflegeEntwicklungFlaeche"
-- -----------------------------------------------------
CREATE  TABLE  "LP_MassnahmenNaturschutz"."LP_SchutzPflegeEntwicklungFlaeche" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_LP_SchutzPflegeEntwicklungFlaeche_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "LP_MassnahmenNaturschutz"."LP_SchutzPflegeEntwicklung" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("LP_Basisobjekte"."LP_Flaechenobjekt");

GRANT SELECT ON TABLE "LP_MassnahmenNaturschutz"."LP_SchutzPflegeEntwicklungFlaeche" TO xp_gast;
GRANT ALL ON TABLE "LP_MassnahmenNaturschutz"."LP_SchutzPflegeEntwicklungFlaeche" TO lp_user;
CREATE INDEX "LP_SchutzPflegeEntwicklungFlaeche_gidx" ON "LP_MassnahmenNaturschutz"."LP_SchutzPflegeEntwicklungFlaeche" using gist ("position");
CREATE TRIGGER "change_to_LP_SchutzPflegeEntwicklungFlaeche" BEFORE INSERT OR UPDATE ON "LP_MassnahmenNaturschutz"."LP_SchutzPflegeEntwicklungFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_LP_SchutzPflegeEntwicklungFlaeche" AFTER DELETE ON "LP_MassnahmenNaturschutz"."LP_SchutzPflegeEntwicklungFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "LP_SchutzPflegeEntwicklungFlaeche_Flaechenobjekt" BEFORE INSERT OR UPDATE ON "LP_MassnahmenNaturschutz"."LP_SchutzPflegeEntwicklungFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."positionFollowsRHR"();

-- -----------------------------------------------------
-- Table "LP_MassnahmenNaturschutz"."LP_SchutzPflegeEntwicklungLinie"
-- -----------------------------------------------------
CREATE  TABLE  "LP_MassnahmenNaturschutz"."LP_SchutzPflegeEntwicklungLinie" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_LP_SchutzPflegeEntwicklungLinie_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "LP_MassnahmenNaturschutz"."LP_SchutzPflegeEntwicklung" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("LP_Basisobjekte"."LP_Linienobjekt");

GRANT SELECT ON TABLE "LP_MassnahmenNaturschutz"."LP_SchutzPflegeEntwicklungLinie" TO xp_gast;
GRANT ALL ON TABLE "LP_MassnahmenNaturschutz"."LP_SchutzPflegeEntwicklungLinie" TO lp_user;
CREATE INDEX "LP_SchutzPflegeEntwicklungLinie_gidx" ON "LP_MassnahmenNaturschutz"."LP_SchutzPflegeEntwicklungLinie" using gist ("position");
CREATE TRIGGER "change_to_LP_SchutzPflegeEntwicklungLinie" BEFORE INSERT OR UPDATE ON "LP_MassnahmenNaturschutz"."LP_SchutzPflegeEntwicklungLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_LP_SchutzPflegeEntwicklungLinie" AFTER DELETE ON "LP_MassnahmenNaturschutz"."LP_SchutzPflegeEntwicklungLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "LP_MassnahmenNaturschutz"."LP_SchutzPflegeEntwicklungPunkt"
-- -----------------------------------------------------
CREATE  TABLE  "LP_MassnahmenNaturschutz"."LP_SchutzPflegeEntwicklungPunkt" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_LP_SchutzPflegeEntwicklungPunkt_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "LP_MassnahmenNaturschutz"."LP_SchutzPflegeEntwicklung" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("LP_Basisobjekte"."LP_Punktobjekt");

GRANT SELECT ON TABLE "LP_MassnahmenNaturschutz"."LP_SchutzPflegeEntwicklungPunkt" TO xp_gast;
GRANT ALL ON TABLE "LP_MassnahmenNaturschutz"."LP_SchutzPflegeEntwicklungPunkt" TO lp_user;
CREATE INDEX "LP_SchutzPflegeEntwicklungPunkt_gidx" ON "LP_MassnahmenNaturschutz"."LP_SchutzPflegeEntwicklungPunkt" using gist ("position");
CREATE TRIGGER "change_to_LP_SchutzPflegeEntwicklungPunkt" BEFORE INSERT OR UPDATE ON "LP_MassnahmenNaturschutz"."LP_SchutzPflegeEntwicklungPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_LP_SchutzPflegeEntwicklungPunkt" AFTER DELETE ON "LP_MassnahmenNaturschutz"."LP_SchutzPflegeEntwicklungPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "LP_MassnahmenNaturschutz"."LP_Zwischennutzung"
-- -----------------------------------------------------
CREATE  TABLE  "LP_MassnahmenNaturschutz"."LP_Zwischennutzung" (
  "gid" BIGINT NOT NULL ,
  "ziel" INTEGER NULL ,
  "bindung" VARCHAR(1024) NULL ,
  "bindungKuerzel" VARCHAR(64) NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_LP_Zwischennutzung_XP_SPEZiele1"
    FOREIGN KEY ("ziel" )
    REFERENCES "XP_Enumerationen"."XP_SPEZiele" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_LP_Zwischennutzung_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "LP_Basisobjekte"."LP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE);

GRANT SELECT ON TABLE "LP_MassnahmenNaturschutz"."LP_Zwischennutzung" TO xp_gast;
GRANT ALL ON TABLE "LP_MassnahmenNaturschutz"."LP_Zwischennutzung" TO lp_user;
COMMENT ON TABLE  "LP_MassnahmenNaturschutz"."LP_Zwischennutzung" IS 'Flächen und Maßnahmen mit zeitlich befristeten Bindungen zum Schutz, zur Pflege und zur Entwicklung von Natur und Landschaft ("Zwischennutzungsvorgaben").';
COMMENT ON COLUMN  "LP_MassnahmenNaturschutz"."LP_Zwischennutzung"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN  "LP_MassnahmenNaturschutz"."LP_Zwischennutzung"."ziel" IS 'Unterscheidung nach den Zielen "Schutz, Pflege" und "Entwicklung".';
COMMENT ON COLUMN  "LP_MassnahmenNaturschutz"."LP_Zwischennutzung"."bindung" IS 'Beschreibung der Bindung (Textform).';
COMMENT ON COLUMN  "LP_MassnahmenNaturschutz"."LP_Zwischennutzung"."bindungKuerzel" IS 'Beschreibung der Bindung (Kürzel).';
CREATE INDEX "idx_fk_LP_Zwischennutzung_XP_SPEZiele1" ON "LP_MassnahmenNaturschutz"."LP_Zwischennutzung" ("ziel") ;
CREATE TRIGGER "change_to_LP_Zwischennutzung" BEFORE INSERT OR UPDATE ON "LP_MassnahmenNaturschutz"."LP_Zwischennutzung" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_LP_Zwischennutzung" AFTER DELETE ON "LP_MassnahmenNaturschutz"."LP_Zwischennutzung" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "LP_MassnahmenNaturschutz"."LP_ZwischennutzungFlaeche"
-- -----------------------------------------------------
CREATE  TABLE  "LP_MassnahmenNaturschutz"."LP_ZwischennutzungFlaeche" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_LP_ZwischennutzungFlaeche_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "LP_MassnahmenNaturschutz"."LP_Zwischennutzung" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("LP_Basisobjekte"."LP_Flaechenobjekt");

GRANT SELECT ON TABLE "LP_MassnahmenNaturschutz"."LP_ZwischennutzungFlaeche" TO xp_gast;
GRANT ALL ON TABLE "LP_MassnahmenNaturschutz"."LP_ZwischennutzungFlaeche" TO lp_user;
CREATE INDEX "LP_ZwischennutzungFlaeche_gidx" ON "LP_MassnahmenNaturschutz"."LP_ZwischennutzungFlaeche" using gist ("position");
CREATE TRIGGER "change_to_LP_ZwischennutzungFlaeche" BEFORE INSERT OR UPDATE ON "LP_MassnahmenNaturschutz"."LP_ZwischennutzungFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_LP_ZwischennutzungFlaeche" AFTER DELETE ON "LP_MassnahmenNaturschutz"."LP_ZwischennutzungFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "LP_ZwischennutzungFlaeche_Flaechenobjekt" BEFORE INSERT OR UPDATE ON "LP_MassnahmenNaturschutz"."LP_ZwischennutzungFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."positionFollowsRHR"();

-- -----------------------------------------------------
-- Table "LP_MassnahmenNaturschutz"."LP_ZwischennutzungLinie"
-- -----------------------------------------------------
CREATE  TABLE  "LP_MassnahmenNaturschutz"."LP_ZwischennutzungLinie" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_LP_ZwischennutzungLinie_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "LP_MassnahmenNaturschutz"."LP_Zwischennutzung" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("LP_Basisobjekte"."LP_Linienobjekt");

GRANT SELECT ON TABLE "LP_MassnahmenNaturschutz"."LP_ZwischennutzungLinie" TO xp_gast;
GRANT ALL ON TABLE "LP_MassnahmenNaturschutz"."LP_ZwischennutzungLinie" TO lp_user;
CREATE INDEX "LP_ZwischennutzungLinie_gidx" ON "LP_MassnahmenNaturschutz"."LP_ZwischennutzungLinie" using gist ("position");
CREATE TRIGGER "change_to_LP_ZwischennutzungLinie" BEFORE INSERT OR UPDATE ON "LP_MassnahmenNaturschutz"."LP_ZwischennutzungLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_LP_ZwischennutzungLinie" AFTER DELETE ON "LP_MassnahmenNaturschutz"."LP_ZwischennutzungLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "LP_MassnahmenNaturschutz"."LP_ZwischennutzungPunkt"
-- -----------------------------------------------------
CREATE  TABLE  "LP_MassnahmenNaturschutz"."LP_ZwischennutzungPunkt" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_LP_ZwischennutzungPunkt_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "LP_MassnahmenNaturschutz"."LP_Zwischennutzung" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("LP_Basisobjekte"."LP_Punktobjekt");

GRANT SELECT ON TABLE "LP_MassnahmenNaturschutz"."LP_ZwischennutzungPunkt" TO xp_gast;
GRANT ALL ON TABLE "LP_MassnahmenNaturschutz"."LP_ZwischennutzungPunkt" TO lp_user;
CREATE INDEX "LP_ZwischennutzungPunkt_gidx" ON "LP_MassnahmenNaturschutz"."LP_ZwischennutzungPunkt" using gist ("position");
CREATE TRIGGER "change_to_LP_ZwischennutzungPunkt" BEFORE INSERT OR UPDATE ON "LP_MassnahmenNaturschutz"."LP_ZwischennutzungPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_LP_ZwischennutzungPunkt" AFTER DELETE ON "LP_MassnahmenNaturschutz"."LP_ZwischennutzungPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "LP_SchutzgebieteObjekte"."LP_BiotopverbundflaecheFlaeche"
-- -----------------------------------------------------
CREATE  TABLE  "LP_SchutzgebieteObjekte"."LP_BiotopverbundflaecheFlaeche" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_LP_BiotopverbundflaecheFlaeche_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "LP_Basisobjekte"."LP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("LP_Basisobjekte"."LP_Flaechenobjekt");

GRANT SELECT ON TABLE "LP_SchutzgebieteObjekte"."LP_BiotopverbundflaecheFlaeche" TO xp_gast;
GRANT ALL ON TABLE "LP_SchutzgebieteObjekte"."LP_BiotopverbundflaecheFlaeche" TO lp_user;
COMMENT ON TABLE  "LP_SchutzgebieteObjekte"."LP_BiotopverbundflaecheFlaeche" IS 'Biotop-Verbundfläche';
COMMENT ON COLUMN  "LP_SchutzgebieteObjekte"."LP_BiotopverbundflaecheFlaeche"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE INDEX "LP_BiotopverbundflaecheFlaeche_gidx" ON "LP_SchutzgebieteObjekte"."LP_BiotopverbundflaecheFlaeche" using gist ("position");
CREATE TRIGGER "change_to_LP_BiotopverbundflaecheFlaeche" BEFORE INSERT OR UPDATE ON "LP_SchutzgebieteObjekte"."LP_BiotopverbundflaecheFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_LP_BiotopverbundflaecheFlaeche" AFTER DELETE ON "LP_SchutzgebieteObjekte"."LP_BiotopverbundflaecheFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "LP_BiotopverbundflaecheFlaeche_Flaechenobjekt" BEFORE INSERT OR UPDATE ON "LP_SchutzgebieteObjekte"."LP_BiotopverbundflaecheFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."positionFollowsRHR"();

-- -----------------------------------------------------
-- Table "LP_SchutzgebieteObjekte"."LP_BiotopverbundflaecheLinie"
-- -----------------------------------------------------
CREATE  TABLE  "LP_SchutzgebieteObjekte"."LP_BiotopverbundflaecheLinie" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_LP_BiotopverbundflaecheLinie_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "LP_Basisobjekte"."LP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("LP_Basisobjekte"."LP_Linienobjekt");

GRANT SELECT ON TABLE "LP_SchutzgebieteObjekte"."LP_BiotopverbundflaecheLinie" TO xp_gast;
GRANT ALL ON TABLE "LP_SchutzgebieteObjekte"."LP_BiotopverbundflaecheLinie" TO lp_user;
COMMENT ON TABLE  "LP_SchutzgebieteObjekte"."LP_BiotopverbundflaecheLinie" IS 'Biotop-Verbundfläche';
COMMENT ON COLUMN  "LP_SchutzgebieteObjekte"."LP_BiotopverbundflaecheLinie"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE INDEX "LP_BiotopverbundflaecheLinie_gidx" ON "LP_SchutzgebieteObjekte"."LP_BiotopverbundflaecheLinie" using gist ("position");
CREATE TRIGGER "change_to_LP_BiotopverbundflaecheLinie" BEFORE INSERT OR UPDATE ON "LP_SchutzgebieteObjekte"."LP_BiotopverbundflaecheLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_LP_BiotopverbundflaecheLinie" AFTER DELETE ON "LP_SchutzgebieteObjekte"."LP_BiotopverbundflaecheLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "LP_SchutzgebieteObjekte"."LP_BiotopverbundflaechePunkt"
-- -----------------------------------------------------
CREATE  TABLE  "LP_SchutzgebieteObjekte"."LP_BiotopverbundflaechePunkt" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_LP_BiotopverbundflaechePunkt_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "LP_Basisobjekte"."LP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("LP_Basisobjekte"."LP_Punktobjekt");

GRANT SELECT ON TABLE "LP_SchutzgebieteObjekte"."LP_BiotopverbundflaechePunkt" TO xp_gast;
GRANT ALL ON TABLE "LP_SchutzgebieteObjekte"."LP_BiotopverbundflaechePunkt" TO lp_user;
COMMENT ON TABLE  "LP_SchutzgebieteObjekte"."LP_BiotopverbundflaechePunkt" IS 'Biotop-Verbundfläche';
COMMENT ON COLUMN  "LP_SchutzgebieteObjekte"."LP_BiotopverbundflaechePunkt"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE INDEX "LP_BiotopverbundflaechePunkt_gidx" ON "LP_SchutzgebieteObjekte"."LP_BiotopverbundflaechePunkt" using gist ("position");
CREATE TRIGGER "change_to_LP_BiotopverbundflaechePunkt" BEFORE INSERT OR UPDATE ON "LP_SchutzgebieteObjekte"."LP_BiotopverbundflaechePunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_LP_BiotopverbundflaechePunkt" AFTER DELETE ON "LP_SchutzgebieteObjekte"."LP_BiotopverbundflaechePunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "LP_SchutzgebieteObjekte"."LP_BodenschutzrechtTypen"
-- -----------------------------------------------------
CREATE  TABLE  "LP_SchutzgebieteObjekte"."LP_BodenschutzrechtTypen" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Code") );
GRANT SELECT ON TABLE "LP_SchutzgebieteObjekte"."LP_BodenschutzrechtTypen" TO xp_gast;

-- -----------------------------------------------------
-- Table "LP_SchutzgebieteObjekte"."LP_BodenschutzrechtDetailTypen"
-- -----------------------------------------------------
CREATE  TABLE  "LP_SchutzgebieteObjekte"."LP_BodenschutzrechtDetailTypen" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Code") );
GRANT SELECT ON TABLE "LP_SchutzgebieteObjekte"."LP_BodenschutzrechtDetailTypen" TO xp_gast;
GRANT ALL ON TABLE "LP_SchutzgebieteObjekte"."LP_BodenschutzrechtDetailTypen" TO lp_user;
CREATE TRIGGER "ins_upd_LP_BodenschutzrechtDetailTypen" BEFORE INSERT OR UPDATE ON "LP_SchutzgebieteObjekte"."LP_BodenschutzrechtDetailTypen" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isCodeList"();

-- -----------------------------------------------------
-- Table "LP_SchutzgebieteObjekte"."LP_Bodenschutzrecht"
-- -----------------------------------------------------
CREATE  TABLE  "LP_SchutzgebieteObjekte"."LP_Bodenschutzrecht" (
  "gid" BIGINT NOT NULL ,
  "typ" INTEGER NULL ,
  "detailTyp" INTEGER NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_LP_Bodenschutzrecht_typ1"
    FOREIGN KEY ("typ" )
    REFERENCES "LP_SchutzgebieteObjekte"."LP_BodenschutzrechtTypen" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_LP_Bodenschutzrecht_detailTyp1"
    FOREIGN KEY ("detailTyp" )
    REFERENCES "LP_SchutzgebieteObjekte"."LP_BodenschutzrechtDetailTypen" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_LP_Bodenschutzrecht_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "LP_Basisobjekte"."LP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE);

GRANT SELECT ON TABLE "LP_SchutzgebieteObjekte"."LP_Bodenschutzrecht" TO xp_gast;
GRANT ALL ON TABLE "LP_SchutzgebieteObjekte"."LP_Bodenschutzrecht" TO lp_user;
COMMENT ON TABLE  "LP_SchutzgebieteObjekte"."LP_Bodenschutzrecht" IS 'Gebiete und Gebietsteile mit rechtlichen Bindungen nach anderen Fachgesetzen (soweit sie für den Schutz, die Pflege und die Entwicklung von Natur und Landschaft bedeutsam sind). Hier: Flächen mit schädlichen Bodenveränderungen nach dem Bodenschutzgesetz.';
COMMENT ON COLUMN  "LP_SchutzgebieteObjekte"."LP_Bodenschutzrecht"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN  "LP_SchutzgebieteObjekte"."LP_Bodenschutzrecht"."typ" IS 'Typ des Schutzobjektes';
COMMENT ON COLUMN  "LP_SchutzgebieteObjekte"."LP_Bodenschutzrecht"."detailTyp" IS 'Über eine CodeList definierter zusätzlicher Typ des Schutzobjektes.';
CREATE INDEX "idx_fk_LP_Bodenschutzrecht_detailTyp" ON "LP_SchutzgebieteObjekte"."LP_Bodenschutzrecht" ("detailTyp") ;
CREATE TRIGGER "change_to_LP_Bodenschutzrecht" BEFORE INSERT OR UPDATE ON "LP_SchutzgebieteObjekte"."LP_Bodenschutzrecht" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_LP_Bodenschutzrecht" AFTER DELETE ON "LP_SchutzgebieteObjekte"."LP_Bodenschutzrecht" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "LP_SchutzgebieteObjekte"."LP_BodenschutzrechtFlaeche"
-- -----------------------------------------------------
CREATE  TABLE  "LP_SchutzgebieteObjekte"."LP_BodenschutzrechtFlaeche" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_LP_BodenschutzrechtFlaeche_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "LP_SchutzgebieteObjekte"."LP_Bodenschutzrecht" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("LP_Basisobjekte"."LP_Flaechenobjekt");

GRANT SELECT ON TABLE "LP_SchutzgebieteObjekte"."LP_BodenschutzrechtFlaeche" TO xp_gast;
GRANT ALL ON TABLE "LP_SchutzgebieteObjekte"."LP_BodenschutzrechtFlaeche" TO lp_user;
CREATE INDEX "LP_BodenschutzrechtFlaeche_gidx" ON "LP_SchutzgebieteObjekte"."LP_BodenschutzrechtFlaeche" using gist ("position");
CREATE TRIGGER "change_to_LP_BodenschutzrechtFlaeche" BEFORE INSERT OR UPDATE ON "LP_SchutzgebieteObjekte"."LP_BodenschutzrechtFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_LP_BodenschutzrechtFlaeche" AFTER DELETE ON "LP_SchutzgebieteObjekte"."LP_BodenschutzrechtFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "LP_BodenschutzrechtFlaeche_Flaechenobjekt" BEFORE INSERT OR UPDATE ON "LP_SchutzgebieteObjekte"."LP_BodenschutzrechtFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."positionFollowsRHR"();

-- -----------------------------------------------------
-- Table "LP_SchutzgebieteObjekte"."LP_BodenschutzrechtLinie"
-- -----------------------------------------------------
CREATE  TABLE  "LP_SchutzgebieteObjekte"."LP_BodenschutzrechtLinie" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_LP_BodenschutzrechtLinie_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "LP_SchutzgebieteObjekte"."LP_Bodenschutzrecht" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("LP_Basisobjekte"."LP_Linienobjekt");

GRANT SELECT ON TABLE "LP_SchutzgebieteObjekte"."LP_BodenschutzrechtLinie" TO xp_gast;
GRANT ALL ON TABLE "LP_SchutzgebieteObjekte"."LP_BodenschutzrechtLinie" TO lp_user;
CREATE INDEX "LP_BodenschutzrechtLinie_gidx" ON "LP_SchutzgebieteObjekte"."LP_BodenschutzrechtLinie" using gist ("position");
CREATE TRIGGER "change_to_LP_BodenschutzrechtLinie" BEFORE INSERT OR UPDATE ON "LP_SchutzgebieteObjekte"."LP_BodenschutzrechtLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_LP_BodenschutzrechtLinie" AFTER DELETE ON "LP_SchutzgebieteObjekte"."LP_BodenschutzrechtLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "LP_SchutzgebieteObjekte"."LP_BodenschutzrechtPunkt"
-- -----------------------------------------------------
CREATE  TABLE  "LP_SchutzgebieteObjekte"."LP_BodenschutzrechtPunkt" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_LP_BodenschutzrechtPunkt_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "LP_SchutzgebieteObjekte"."LP_Bodenschutzrecht" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("LP_Basisobjekte"."LP_Punktobjekt");

GRANT SELECT ON TABLE "LP_SchutzgebieteObjekte"."LP_BodenschutzrechtPunkt" TO xp_gast;
GRANT ALL ON TABLE "LP_SchutzgebieteObjekte"."LP_BodenschutzrechtPunkt" TO lp_user;
CREATE INDEX "LP_BodenschutzrechtPunkt_gidx" ON "LP_SchutzgebieteObjekte"."LP_BodenschutzrechtPunkt" using gist ("position");
CREATE TRIGGER "change_to_LP_BodenschutzrechtPunkt" BEFORE INSERT OR UPDATE ON "LP_SchutzgebieteObjekte"."LP_BodenschutzrechtPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_LP_BodenschutzrechtPunkt" AFTER DELETE ON "LP_SchutzgebieteObjekte"."LP_BodenschutzrechtPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "LP_SchutzgebieteObjekte"."LP_ForstrechtTypen"
-- -----------------------------------------------------
CREATE  TABLE  "LP_SchutzgebieteObjekte"."LP_ForstrechtTypen" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Code") );
GRANT SELECT ON TABLE "LP_SchutzgebieteObjekte"."LP_ForstrechtTypen" TO xp_gast;

-- -----------------------------------------------------
-- Table "LP_SchutzgebieteObjekte"."LP_WaldschutzDetailTypen"
-- -----------------------------------------------------
CREATE  TABLE  "LP_SchutzgebieteObjekte"."LP_WaldschutzDetailTypen" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Code") );
GRANT SELECT ON TABLE "LP_SchutzgebieteObjekte"."LP_WaldschutzDetailTypen" TO xp_gast;
GRANT ALL ON TABLE "LP_SchutzgebieteObjekte"."LP_WaldschutzDetailTypen" TO lp_user;
CREATE TRIGGER "ins_upd_LP_WaldschutzDetailTypen" BEFORE INSERT OR UPDATE ON "LP_SchutzgebieteObjekte"."LP_WaldschutzDetailTypen" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isCodeList"();

-- -----------------------------------------------------
-- Table "LP_SchutzgebieteObjekte"."LP_Forstrecht"
-- -----------------------------------------------------
CREATE  TABLE  "LP_SchutzgebieteObjekte"."LP_Forstrecht" (
  "gid" BIGINT NOT NULL ,
  "typ" INTEGER NULL ,
  "detailTyp" INTEGER NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_LP_Forstrecht_typ1"
    FOREIGN KEY ("typ" )
    REFERENCES "LP_SchutzgebieteObjekte"."LP_ForstrechtTypen" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_LP_Forstrecht_detailTyp1"
    FOREIGN KEY ("detailTyp" )
    REFERENCES "LP_SchutzgebieteObjekte"."LP_WaldschutzDetailTypen" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_LP_Forstrecht_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "LP_Basisobjekte"."LP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE);

GRANT SELECT ON TABLE "LP_SchutzgebieteObjekte"."LP_Forstrecht" TO xp_gast;
GRANT ALL ON TABLE "LP_SchutzgebieteObjekte"."LP_Forstrecht" TO lp_user;
COMMENT ON TABLE  "LP_SchutzgebieteObjekte"."LP_Forstrecht" IS 'Gebiete und Gebietsteile mit rechtlichen Bindungen nach anderen Fachgesetzen (soweit sie für den Schutz, die Pflege und die Entwicklung von Natur und Landschaft bedeutsam sind). Hier: Schutzgebiete und sonstige Flächen nach dem Bundeswaldgesetz.';
COMMENT ON COLUMN  "LP_SchutzgebieteObjekte"."LP_Forstrecht"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN  "LP_SchutzgebieteObjekte"."LP_Forstrecht"."typ" IS 'Typ des Schutzobjektes';
COMMENT ON COLUMN  "LP_SchutzgebieteObjekte"."LP_Forstrecht"."detailTyp" IS 'Über eine CodeList definierter zusätzlicher Typ des Schutzobjektes.';
CREATE INDEX "idx_fk_LP_Forstrecht_detailTyp" ON "LP_SchutzgebieteObjekte"."LP_Forstrecht" ("detailTyp") ;
CREATE TRIGGER "change_to_LP_Forstrecht" BEFORE INSERT OR UPDATE ON "LP_SchutzgebieteObjekte"."LP_Forstrecht" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_LP_Forstrecht" AFTER DELETE ON "LP_SchutzgebieteObjekte"."LP_Forstrecht" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "LP_SchutzgebieteObjekte"."LP_ForstrechtFlaeche"
-- -----------------------------------------------------
CREATE  TABLE  "LP_SchutzgebieteObjekte"."LP_ForstrechtFlaeche" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_LP_ForstrechtFlaeche_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "LP_SchutzgebieteObjekte"."LP_Forstrecht" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("LP_Basisobjekte"."LP_Flaechenobjekt");

GRANT SELECT ON TABLE "LP_SchutzgebieteObjekte"."LP_ForstrechtFlaeche" TO xp_gast;
GRANT ALL ON TABLE "LP_SchutzgebieteObjekte"."LP_ForstrechtFlaeche" TO lp_user;
CREATE INDEX "LP_ForstrechtFlaeche_gidx" ON "LP_SchutzgebieteObjekte"."LP_ForstrechtFlaeche" using gist ("position");
CREATE TRIGGER "change_to_LP_ForstrechtFlaeche" BEFORE INSERT OR UPDATE ON "LP_SchutzgebieteObjekte"."LP_ForstrechtFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_LP_ForstrechtFlaeche" AFTER DELETE ON "LP_SchutzgebieteObjekte"."LP_ForstrechtFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "LP_ForstrechtFlaeche_Flaechenobjekt" BEFORE INSERT OR UPDATE ON "LP_SchutzgebieteObjekte"."LP_ForstrechtFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."positionFollowsRHR"();

-- -----------------------------------------------------
-- Table "LP_SchutzgebieteObjekte"."LP_ForstrechtLinie"
-- -----------------------------------------------------
CREATE  TABLE  "LP_SchutzgebieteObjekte"."LP_ForstrechtLinie" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_LP_ForstrechtLinie_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "LP_SchutzgebieteObjekte"."LP_Forstrecht" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("LP_Basisobjekte"."LP_Linienobjekt");

GRANT SELECT ON TABLE "LP_SchutzgebieteObjekte"."LP_ForstrechtLinie" TO xp_gast;
GRANT ALL ON TABLE "LP_SchutzgebieteObjekte"."LP_ForstrechtLinie" TO lp_user;
CREATE INDEX "LP_ForstrechtLinie_gidx" ON "LP_SchutzgebieteObjekte"."LP_ForstrechtLinie" using gist ("position");
CREATE TRIGGER "change_to_LP_ForstrechtLinie" BEFORE INSERT OR UPDATE ON "LP_SchutzgebieteObjekte"."LP_ForstrechtLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_LP_ForstrechtLinie" AFTER DELETE ON "LP_SchutzgebieteObjekte"."LP_ForstrechtLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "LP_SchutzgebieteObjekte"."LP_ForstrechtPunkt"
-- -----------------------------------------------------
CREATE  TABLE  "LP_SchutzgebieteObjekte"."LP_ForstrechtPunkt" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_LP_ForstrechtPunkt_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "LP_SchutzgebieteObjekte"."LP_Forstrecht" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("LP_Basisobjekte"."LP_Punktobjekt");

GRANT SELECT ON TABLE "LP_SchutzgebieteObjekte"."LP_ForstrechtPunkt" TO xp_gast;
GRANT ALL ON TABLE "LP_SchutzgebieteObjekte"."LP_ForstrechtPunkt" TO lp_user;
CREATE INDEX "LP_ForstrechtPunkt_gidx" ON "LP_SchutzgebieteObjekte"."LP_ForstrechtPunkt" using gist ("position");
CREATE TRIGGER "change_to_LP_ForstrechtPunkt" BEFORE INSERT OR UPDATE ON "LP_SchutzgebieteObjekte"."LP_ForstrechtPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_LP_ForstrechtPunkt" AFTER DELETE ON "LP_SchutzgebieteObjekte"."LP_ForstrechtPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "LP_SchutzgebieteObjekte"."LP_InternatSchutzobjektTypen"
-- -----------------------------------------------------
CREATE  TABLE  "LP_SchutzgebieteObjekte"."LP_InternatSchutzobjektTypen" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Code") );
GRANT SELECT ON TABLE "LP_SchutzgebieteObjekte"."LP_InternatSchutzobjektTypen" TO xp_gast;

-- -----------------------------------------------------
-- Table "LP_SchutzgebieteObjekte"."LP_InternatSchutzobjektDetailTypen"
-- -----------------------------------------------------
CREATE  TABLE  "LP_SchutzgebieteObjekte"."LP_InternatSchutzobjektDetailTypen" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Code") );
GRANT SELECT ON TABLE "LP_SchutzgebieteObjekte"."LP_InternatSchutzobjektDetailTypen" TO xp_gast;
GRANT ALL ON TABLE "LP_SchutzgebieteObjekte"."LP_InternatSchutzobjektDetailTypen" TO lp_user;
CREATE TRIGGER "ins_upd_LP_InternatSchutzobjektDetailTypen" BEFORE INSERT OR UPDATE ON "LP_SchutzgebieteObjekte"."LP_InternatSchutzobjektDetailTypen" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isCodeList"();

-- -----------------------------------------------------
-- Table "LP_SchutzgebieteObjekte"."LP_SchutzobjektInternatRecht"
-- -----------------------------------------------------
CREATE  TABLE  "LP_SchutzgebieteObjekte"."LP_SchutzobjektInternatRecht" (
  "gid" BIGINT NOT NULL ,
  "typ" INTEGER NULL ,
  "detailTyp" INTEGER NULL ,
  "eigenname" VARCHAR (64) NULL,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_LP_SchutzobjektInternatRecht_typ1"
    FOREIGN KEY ("typ" )
    REFERENCES "LP_SchutzgebieteObjekte"."LP_InternatSchutzobjektTypen" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_LP_SchutzobjektInternatRecht_detailTyp1"
    FOREIGN KEY ("detailTyp" )
    REFERENCES "LP_SchutzgebieteObjekte"."LP_InternatSchutzobjektDetailTypen" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_LP_SchutzobjektInternatRecht_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "LP_Basisobjekte"."LP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE);

GRANT SELECT ON TABLE "LP_SchutzgebieteObjekte"."LP_SchutzobjektInternatRecht" TO xp_gast;
GRANT ALL ON TABLE "LP_SchutzgebieteObjekte"."LP_SchutzobjektInternatRecht" TO lp_user;
COMMENT ON TABLE  "LP_SchutzgebieteObjekte"."LP_SchutzobjektInternatRecht" IS 'Sonstige Schutzgebiete und Schutzobjekte nach internationalem Recht.';
COMMENT ON COLUMN  "LP_SchutzgebieteObjekte"."LP_SchutzobjektInternatRecht"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN  "LP_SchutzgebieteObjekte"."LP_SchutzobjektInternatRecht"."typ" IS 'Typ des Schutzobjektes';
COMMENT ON COLUMN  "LP_SchutzgebieteObjekte"."LP_SchutzobjektInternatRecht"."detailTyp" IS 'Über eine CodeList definierter zusätzlicher Typ des Schutzobjektes.';
COMMENT ON COLUMN  "LP_SchutzgebieteObjekte"."LP_SchutzobjektInternatRecht"."eigenname" IS 'Eigennahme des Schutzgebietes.';
CREATE INDEX "idx_fk_LP_SchutzobjektInternatRecht_detailTyp" ON "LP_SchutzgebieteObjekte"."LP_SchutzobjektInternatRecht" ("detailTyp") ;
CREATE TRIGGER "change_to_LP_SchutzobjektInternatRecht" BEFORE INSERT OR UPDATE ON "LP_SchutzgebieteObjekte"."LP_SchutzobjektInternatRecht" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_LP_SchutzobjektInternatRecht" AFTER DELETE ON "LP_SchutzgebieteObjekte"."LP_SchutzobjektInternatRecht" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "LP_SchutzgebieteObjekte"."LP_SchutzobjektInternatRechtFlaeche"
-- -----------------------------------------------------
CREATE  TABLE  "LP_SchutzgebieteObjekte"."LP_SchutzobjektInternatRechtFlaeche" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_LP_SchutzobjektInternatRechtFlaeche_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "LP_SchutzgebieteObjekte"."LP_SchutzobjektInternatRecht" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("LP_Basisobjekte"."LP_Flaechenobjekt");

GRANT SELECT ON TABLE "LP_SchutzgebieteObjekte"."LP_SchutzobjektInternatRechtFlaeche" TO xp_gast;
GRANT ALL ON TABLE "LP_SchutzgebieteObjekte"."LP_SchutzobjektInternatRechtFlaeche" TO lp_user;
CREATE INDEX "LP_SchutzobjektInternatRechtFlaeche_gidx" ON "LP_SchutzgebieteObjekte"."LP_SchutzobjektInternatRechtFlaeche" using gist ("position");
CREATE TRIGGER "change_to_LP_SchutzobjektInternatRechtFlaeche" BEFORE INSERT OR UPDATE ON "LP_SchutzgebieteObjekte"."LP_SchutzobjektInternatRechtFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_LP_SchutzobjektInternatRechtFlaeche" AFTER DELETE ON "LP_SchutzgebieteObjekte"."LP_SchutzobjektInternatRechtFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "LP_SchutzobjektInternatRechtFlaeche_Flaechenobjekt" BEFORE INSERT OR UPDATE ON "LP_SchutzgebieteObjekte"."LP_SchutzobjektInternatRechtFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."positionFollowsRHR"();

-- -----------------------------------------------------
-- Table "LP_SchutzgebieteObjekte"."LP_SchutzobjektInternatRechtLinie"
-- -----------------------------------------------------
CREATE  TABLE  "LP_SchutzgebieteObjekte"."LP_SchutzobjektInternatRechtLinie" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_LP_SchutzobjektInternatRechtLinie_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "LP_SchutzgebieteObjekte"."LP_SchutzobjektInternatRecht" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("LP_Basisobjekte"."LP_Linienobjekt");

GRANT SELECT ON TABLE "LP_SchutzgebieteObjekte"."LP_SchutzobjektInternatRechtLinie" TO xp_gast;
GRANT ALL ON TABLE "LP_SchutzgebieteObjekte"."LP_SchutzobjektInternatRechtLinie" TO lp_user;
CREATE INDEX "LP_SchutzobjektInternatRechtLinie_gidx" ON "LP_SchutzgebieteObjekte"."LP_SchutzobjektInternatRechtLinie" using gist ("position");
CREATE TRIGGER "change_to_LP_SchutzobjektInternatRechtLinie" BEFORE INSERT OR UPDATE ON "LP_SchutzgebieteObjekte"."LP_SchutzobjektInternatRechtLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_LP_SchutzobjektInternatRechtLinie" AFTER DELETE ON "LP_SchutzgebieteObjekte"."LP_SchutzobjektInternatRechtLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "LP_SchutzgebieteObjekte"."LP_SchutzobjektInternatRechtPunkt"
-- -----------------------------------------------------
CREATE  TABLE  "LP_SchutzgebieteObjekte"."LP_SchutzobjektInternatRechtPunkt" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_LP_SchutzobjektInternatRechtPunkt_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "LP_SchutzgebieteObjekte"."LP_SchutzobjektInternatRecht" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("LP_Basisobjekte"."LP_Punktobjekt");

GRANT SELECT ON TABLE "LP_SchutzgebieteObjekte"."LP_SchutzobjektInternatRechtPunkt" TO xp_gast;
GRANT ALL ON TABLE "LP_SchutzgebieteObjekte"."LP_SchutzobjektInternatRechtPunkt" TO lp_user;
CREATE INDEX "LP_SchutzobjektInternatRechtPunkt_gidx" ON "LP_SchutzgebieteObjekte"."LP_SchutzobjektInternatRechtPunkt" using gist ("position");
CREATE TRIGGER "change_to_LP_SchutzobjektInternatRechtPunkt" BEFORE INSERT OR UPDATE ON "LP_SchutzgebieteObjekte"."LP_SchutzobjektInternatRechtPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_LP_SchutzobjektInternatRechtPunkt" AFTER DELETE ON "LP_SchutzgebieteObjekte"."LP_SchutzobjektInternatRechtPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "LP_SchutzgebieteObjekte"."LP_SchutzobjektLandesrechtDetailTypen"
-- -----------------------------------------------------
CREATE  TABLE  "LP_SchutzgebieteObjekte"."LP_SchutzobjektLandesrechtDetailTypen" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Code") );
GRANT SELECT ON TABLE "LP_SchutzgebieteObjekte"."LP_SchutzobjektLandesrechtDetailTypen" TO xp_gast;
GRANT ALL ON TABLE "LP_SchutzgebieteObjekte"."LP_SchutzobjektLandesrechtDetailTypen" TO lp_user;
CREATE TRIGGER "ins_upd_LP_SchutzobjektLandesrechtDetailTypen" BEFORE INSERT OR UPDATE ON "LP_SchutzgebieteObjekte"."LP_SchutzobjektLandesrechtDetailTypen" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isCodeList"();

-- -----------------------------------------------------
-- Table "LP_SchutzgebieteObjekte"."LP_SchutzobjektLandesrecht"
-- -----------------------------------------------------
CREATE  TABLE  "LP_SchutzgebieteObjekte"."LP_SchutzobjektLandesrecht" (
  "gid" BIGINT NOT NULL ,
  "detailTyp" INTEGER NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_LP_SchutzobjektLandesrecht_detailTyp1"
    FOREIGN KEY ("detailTyp" )
    REFERENCES "LP_SchutzgebieteObjekte"."LP_SchutzobjektLandesrechtDetailTypen" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_LP_SchutzobjektLandesrecht_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "LP_Basisobjekte"."LP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE);

GRANT SELECT ON TABLE "LP_SchutzgebieteObjekte"."LP_SchutzobjektLandesrecht" TO xp_gast;
GRANT ALL ON TABLE "LP_SchutzgebieteObjekte"."LP_SchutzobjektLandesrecht" TO lp_user;
COMMENT ON TABLE  "LP_SchutzgebieteObjekte"."LP_SchutzobjektLandesrecht" IS 'Sonstige Schutzgebiete und Schutzobjekte nach Landesrecht.';
COMMENT ON COLUMN  "LP_SchutzgebieteObjekte"."LP_SchutzobjektLandesrecht"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN  "LP_SchutzgebieteObjekte"."LP_SchutzobjektLandesrecht"."detailTyp" IS 'Über eine CodeList definierter Typ des Schutzobjektes.';
CREATE INDEX "idx_fk_LP_SchutzobjektLandesrecht_detailTyp" ON "LP_SchutzgebieteObjekte"."LP_SchutzobjektLandesrecht" ("detailTyp") ;
CREATE TRIGGER "change_to_LP_SchutzobjektLandesrecht" BEFORE INSERT OR UPDATE ON "LP_SchutzgebieteObjekte"."LP_SchutzobjektLandesrecht" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_LP_SchutzobjektLandesrecht" AFTER DELETE ON "LP_SchutzgebieteObjekte"."LP_SchutzobjektLandesrecht" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "LP_SchutzgebieteObjekte"."LP_SchutzobjektLandesrechtFlaeche"
-- -----------------------------------------------------
CREATE  TABLE  "LP_SchutzgebieteObjekte"."LP_SchutzobjektLandesrechtFlaeche" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_LP_SchutzobjektLandesrechtFlaeche_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "LP_SchutzgebieteObjekte"."LP_SchutzobjektLandesrecht" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("LP_Basisobjekte"."LP_Flaechenobjekt");

GRANT SELECT ON TABLE "LP_SchutzgebieteObjekte"."LP_SchutzobjektLandesrechtFlaeche" TO xp_gast;
GRANT ALL ON TABLE "LP_SchutzgebieteObjekte"."LP_SchutzobjektLandesrechtFlaeche" TO lp_user;
CREATE INDEX "LP_SchutzobjektLandesrechtFlaeche_gidx" ON "LP_SchutzgebieteObjekte"."LP_SchutzobjektLandesrechtFlaeche" using gist ("position");
CREATE TRIGGER "change_to_LP_SchutzobjektLandesrechtFlaeche" BEFORE INSERT OR UPDATE ON "LP_SchutzgebieteObjekte"."LP_SchutzobjektLandesrechtFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_LP_SchutzobjektLandesrechtFlaeche" AFTER DELETE ON "LP_SchutzgebieteObjekte"."LP_SchutzobjektLandesrechtFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "LP_SchutzobjektLandesrechtFlaeche_Flaechenobjekt" BEFORE INSERT OR UPDATE ON "LP_SchutzgebieteObjekte"."LP_SchutzobjektLandesrechtFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."positionFollowsRHR"();

-- -----------------------------------------------------
-- Table "LP_SchutzgebieteObjekte"."LP_SchutzobjektLandesrechtLinie"
-- -----------------------------------------------------
CREATE  TABLE  "LP_SchutzgebieteObjekte"."LP_SchutzobjektLandesrechtLinie" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_LP_SchutzobjektLandesrechtLinie_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "LP_SchutzgebieteObjekte"."LP_SchutzobjektLandesrecht" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("LP_Basisobjekte"."LP_Linienobjekt");

GRANT SELECT ON TABLE "LP_SchutzgebieteObjekte"."LP_SchutzobjektLandesrechtLinie" TO xp_gast;
GRANT ALL ON TABLE "LP_SchutzgebieteObjekte"."LP_SchutzobjektLandesrechtLinie" TO lp_user;
CREATE INDEX "LP_SchutzobjektLandesrechtLinie_gidx" ON "LP_SchutzgebieteObjekte"."LP_SchutzobjektLandesrechtLinie" using gist ("position");
CREATE TRIGGER "change_to_LP_SchutzobjektLandesrechtLinie" BEFORE INSERT OR UPDATE ON "LP_SchutzgebieteObjekte"."LP_SchutzobjektLandesrechtLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_LP_SchutzobjektLandesrechtLinie" AFTER DELETE ON "LP_SchutzgebieteObjekte"."LP_SchutzobjektLandesrechtLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "LP_SchutzgebieteObjekte"."LP_SchutzobjektLandesrechtPunkt"
-- -----------------------------------------------------
CREATE  TABLE  "LP_SchutzgebieteObjekte"."LP_SchutzobjektLandesrechtPunkt" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_LP_SchutzobjektLandesrechtPunkt_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "LP_SchutzgebieteObjekte"."LP_SchutzobjektLandesrecht" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("LP_Basisobjekte"."LP_Punktobjekt");

GRANT SELECT ON TABLE "LP_SchutzgebieteObjekte"."LP_SchutzobjektLandesrechtPunkt" TO xp_gast;
GRANT ALL ON TABLE "LP_SchutzgebieteObjekte"."LP_SchutzobjektLandesrechtPunkt" TO lp_user;
CREATE INDEX "LP_SchutzobjektLandesrechtPunkt_gidx" ON "LP_SchutzgebieteObjekte"."LP_SchutzobjektLandesrechtPunkt" using gist ("position");
CREATE TRIGGER "change_to_LP_SchutzobjektLandesrechtPunkt" BEFORE INSERT OR UPDATE ON "LP_SchutzgebieteObjekte"."LP_SchutzobjektLandesrechtPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_LP_SchutzobjektLandesrechtPunkt" AFTER DELETE ON "LP_SchutzgebieteObjekte"."LP_SchutzobjektLandesrechtPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "LP_SchutzgebieteObjekte"."LP_SonstRechtTypen"
-- -----------------------------------------------------
CREATE  TABLE  "LP_SchutzgebieteObjekte"."LP_SonstRechtTypen" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Code") );
GRANT SELECT ON TABLE "LP_SchutzgebieteObjekte"."LP_SonstRechtTypen" TO xp_gast;

-- -----------------------------------------------------
-- Table "LP_SchutzgebieteObjekte"."LP_SonstRechtDetailTypen"
-- -----------------------------------------------------
CREATE  TABLE  "LP_SchutzgebieteObjekte"."LP_SonstRechtDetailTypen" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Code") );
GRANT SELECT ON TABLE "LP_SchutzgebieteObjekte"."LP_SonstRechtDetailTypen" TO xp_gast;
GRANT ALL ON TABLE "LP_SchutzgebieteObjekte"."LP_SonstRechtDetailTypen" TO lp_user;
CREATE TRIGGER "ins_upd_LP_SonstRechtDetailTypen" BEFORE INSERT OR UPDATE ON "LP_SchutzgebieteObjekte"."LP_SonstRechtDetailTypen" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isCodeList"();

-- -----------------------------------------------------
-- Table "LP_SchutzgebieteObjekte"."LP_SonstigesRecht"
-- -----------------------------------------------------
CREATE  TABLE  "LP_SchutzgebieteObjekte"."LP_SonstigesRecht" (
  "gid" BIGINT NOT NULL ,
  "typ" INTEGER NULL ,
  "detailTyp" INTEGER NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_LP_SonstigesRecht_typ1"
    FOREIGN KEY ("typ" )
    REFERENCES "LP_SchutzgebieteObjekte"."LP_SonstRechtTypen" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_LP_SonstigesRecht_detailTyp1"
    FOREIGN KEY ("detailTyp" )
    REFERENCES "LP_SchutzgebieteObjekte"."LP_SonstRechtDetailTypen" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_LP_SonstigesRecht_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "LP_Basisobjekte"."LP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE);

GRANT SELECT ON TABLE "LP_SchutzgebieteObjekte"."LP_SonstigesRecht" TO xp_gast;
GRANT ALL ON TABLE "LP_SchutzgebieteObjekte"."LP_SonstigesRecht" TO lp_user;
COMMENT ON TABLE  "LP_SchutzgebieteObjekte"."LP_SonstigesRecht" IS 'Gebiete und Gebietsteile mit rechtlichen Bindungen nach anderen Fachgesetzen (soweit sie für den Schutz, die Pflege und die Entwicklung von Natur und Landschaft bedeutsam sind). Hier: Sonstige Flächen und Gebiete (z.B. nach Jagdrecht).';
COMMENT ON COLUMN  "LP_SchutzgebieteObjekte"."LP_SonstigesRecht"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN  "LP_SchutzgebieteObjekte"."LP_SonstigesRecht"."typ" IS 'Typ des Schutzobjektes';
COMMENT ON COLUMN  "LP_SchutzgebieteObjekte"."LP_SonstigesRecht"."detailTyp" IS 'Über eine CodeList definierter zusätzlicher Typ des Schutzobjektes.';
CREATE TRIGGER "change_to_LP_SonstigesRecht" BEFORE INSERT OR UPDATE ON "LP_SchutzgebieteObjekte"."LP_SonstigesRecht" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_LP_SonstigesRecht" AFTER DELETE ON "LP_SchutzgebieteObjekte"."LP_SonstigesRecht" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "LP_SchutzgebieteObjekte"."LP_SonstigesRechtFlaeche"
-- -----------------------------------------------------
CREATE  TABLE  "LP_SchutzgebieteObjekte"."LP_SonstigesRechtFlaeche" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_LP_SonstigesRechtFlaeche_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "LP_SchutzgebieteObjekte"."LP_SonstigesRecht" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("LP_Basisobjekte"."LP_Flaechenobjekt");

GRANT SELECT ON TABLE "LP_SchutzgebieteObjekte"."LP_SonstigesRechtFlaeche" TO xp_gast;
GRANT ALL ON TABLE "LP_SchutzgebieteObjekte"."LP_SonstigesRechtFlaeche" TO lp_user;
CREATE INDEX "LP_SonstigesRechtFlaeche_gidx" ON "LP_SchutzgebieteObjekte"."LP_SonstigesRechtFlaeche" using gist ("position");
CREATE TRIGGER "change_to_LP_SonstigesRechtFlaeche" BEFORE INSERT OR UPDATE ON "LP_SchutzgebieteObjekte"."LP_SonstigesRechtFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_LP_SonstigesRechtFlaeche" AFTER DELETE ON "LP_SchutzgebieteObjekte"."LP_SonstigesRechtFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "LP_SonstigesRechtFlaeche_Flaechenobjekt" BEFORE INSERT OR UPDATE ON "LP_SchutzgebieteObjekte"."LP_SonstigesRechtFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."positionFollowsRHR"();

-- -----------------------------------------------------
-- Table "LP_SchutzgebieteObjekte"."LP_SonstigesRechtLinie"
-- -----------------------------------------------------
CREATE  TABLE  "LP_SchutzgebieteObjekte"."LP_SonstigesRechtLinie" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_LP_SonstigesRechtLinie_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "LP_SchutzgebieteObjekte"."LP_SonstigesRecht" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("LP_Basisobjekte"."LP_Linienobjekt");

GRANT SELECT ON TABLE "LP_SchutzgebieteObjekte"."LP_SonstigesRechtLinie" TO xp_gast;
GRANT ALL ON TABLE "LP_SchutzgebieteObjekte"."LP_SonstigesRechtLinie" TO lp_user;
CREATE INDEX "LP_SonstigesRechtLinie_gidx" ON "LP_SchutzgebieteObjekte"."LP_SonstigesRechtLinie" using gist ("position");
CREATE TRIGGER "change_to_LP_SonstigesRechtLinie" BEFORE INSERT OR UPDATE ON "LP_SchutzgebieteObjekte"."LP_SonstigesRechtLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_LP_SonstigesRechtLinie" AFTER DELETE ON "LP_SchutzgebieteObjekte"."LP_SonstigesRechtLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "LP_SchutzgebieteObjekte"."LP_SonstigesRechtPunkt"
-- -----------------------------------------------------
CREATE  TABLE  "LP_SchutzgebieteObjekte"."LP_SonstigesRechtPunkt" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_LP_SonstigesRechtPunkt_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "LP_SchutzgebieteObjekte"."LP_SonstigesRecht" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("LP_Basisobjekte"."LP_Punktobjekt");

GRANT SELECT ON TABLE "LP_SchutzgebieteObjekte"."LP_SonstigesRechtPunkt" TO xp_gast;
GRANT ALL ON TABLE "LP_SchutzgebieteObjekte"."LP_SonstigesRechtPunkt" TO lp_user;
CREATE INDEX "LP_SonstigesRechtPunkt_gidx" ON "LP_SchutzgebieteObjekte"."LP_SonstigesRechtPunkt" using gist ("position");
CREATE TRIGGER "change_to_LP_SonstigesRechtPunkt" BEFORE INSERT OR UPDATE ON "LP_SchutzgebieteObjekte"."LP_SonstigesRechtPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_LP_SonstigesRechtPunkt" AFTER DELETE ON "LP_SchutzgebieteObjekte"."LP_SonstigesRechtPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "LP_SchutzgebieteObjekte"."LP_WasserrechtGemeingebrEinschraenkungNaturschutzDetailTypen"
-- -----------------------------------------------------
CREATE  TABLE  "LP_SchutzgebieteObjekte"."LP_WasserrechtGemeingebrEinschraenkungNaturschutzDetailTypen" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Code") );
GRANT SELECT ON TABLE "LP_SchutzgebieteObjekte"."LP_WasserrechtGemeingebrEinschraenkungNaturschutzDetailTypen" TO xp_gast;
GRANT ALL ON TABLE "LP_SchutzgebieteObjekte"."LP_WasserrechtGemeingebrEinschraenkungNaturschutzDetailTypen" TO lp_user;
CREATE TRIGGER "ins_upd_LP_WasserrechtGemeingebrEinschraenkungNaturschutzDetailTypen" BEFORE INSERT OR UPDATE ON "LP_SchutzgebieteObjekte"."LP_WasserrechtGemeingebrEinschraenkungNaturschutzDetailTypen" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isCodeList"();

-- -----------------------------------------------------
-- Table "LP_SchutzgebieteObjekte"."LP_WasserrechtGemeingebrEinschraenkungNaturschutz"
-- -----------------------------------------------------
CREATE  TABLE  "LP_SchutzgebieteObjekte"."LP_WasserrechtGemeingebrEinschraenkungNaturschutz" (
  "gid" BIGINT NOT NULL ,
  "detailTyp" INTEGER NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_LP_WasserrechtGemeingebrEinschraenkungNaturschutz_detailTyp1"
    FOREIGN KEY ("detailTyp" )
    REFERENCES "LP_SchutzgebieteObjekte"."LP_WasserrechtGemeingebrEinschraenkungNaturschutzDetailTypen" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_LP_WasserrechtGemeingebrEinschraenkungNaturschutz_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "LP_Basisobjekte"."LP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE);

GRANT SELECT ON TABLE "LP_SchutzgebieteObjekte"."LP_WasserrechtGemeingebrEinschraenkungNaturschutz" TO xp_gast;
GRANT ALL ON TABLE "LP_SchutzgebieteObjekte"."LP_WasserrechtGemeingebrEinschraenkungNaturschutz" TO lp_user;
COMMENT ON TABLE  "LP_SchutzgebieteObjekte"."LP_WasserrechtGemeingebrEinschraenkungNaturschutz" IS 'Gebiete und Gebietsteile mit rechtlichen Bindungen nach anderen Fachgesetzen (soweit sie für den Schutz, die Pflege und die Entwicklung von Natur und Landschaft bedeutsam sind). Hier: Flächen mit Einschränkungen des wasserrechtlichen Gemeingebrauchs aus Gründen des Naturschutzes.';
COMMENT ON COLUMN  "LP_SchutzgebieteObjekte"."LP_WasserrechtGemeingebrEinschraenkungNaturschutz"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN  "LP_SchutzgebieteObjekte"."LP_WasserrechtGemeingebrEinschraenkungNaturschutz"."detailTyp" IS 'Über eine CodeList definierter zusätzlicher Typ des Schutzobjektes.';
CREATE TRIGGER "change_to_LP_WasserrechtGemeingebrEinschraenkungNaturschutz" BEFORE INSERT OR UPDATE ON "LP_SchutzgebieteObjekte"."LP_WasserrechtGemeingebrEinschraenkungNaturschutz" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_LP_WasserrechtGemeingebrEinschraenkungNaturschutz" AFTER DELETE ON "LP_SchutzgebieteObjekte"."LP_WasserrechtGemeingebrEinschraenkungNaturschutz" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "LP_SchutzgebieteObjekte"."LP_WasserrechtGemeingebrEinschraenkungNaturschutzFlaeche"
-- -----------------------------------------------------
CREATE  TABLE  "LP_SchutzgebieteObjekte"."LP_WasserrechtGemeingebrEinschraenkungNaturschutzFlaeche" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_LP_WasserrGemeingebrEinschrNaturschutzFlaeche_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "LP_SchutzgebieteObjekte"."LP_WasserrechtGemeingebrEinschraenkungNaturschutz" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("LP_Basisobjekte"."LP_Flaechenobjekt");

GRANT SELECT ON TABLE "LP_SchutzgebieteObjekte"."LP_WasserrechtGemeingebrEinschraenkungNaturschutzFlaeche" TO xp_gast;
GRANT ALL ON TABLE "LP_SchutzgebieteObjekte"."LP_WasserrechtGemeingebrEinschraenkungNaturschutzFlaeche" TO lp_user;
CREATE INDEX "LP_WasserrechtGemeingebrEinschraenkungNaturschutzFlaeche_gidx" ON "LP_SchutzgebieteObjekte"."LP_WasserrechtGemeingebrEinschraenkungNaturschutzFlaeche" using gist ("position");
CREATE TRIGGER "change_to_LP_WasserrGemeingebrEinschrNaturschutzFlaeche" BEFORE INSERT OR UPDATE ON "LP_SchutzgebieteObjekte"."LP_WasserrechtGemeingebrEinschraenkungNaturschutzFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_LP_WasserrechtGemeingebrEinschraenkungNaturschutzFlaeche" AFTER DELETE ON "LP_SchutzgebieteObjekte"."LP_WasserrechtGemeingebrEinschraenkungNaturschutzFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "LP_WasserrGemeingebrEinschrNaturschutzFlaeche_Flaechenobjekt" BEFORE INSERT OR UPDATE ON "LP_SchutzgebieteObjekte"."LP_WasserrechtGemeingebrEinschraenkungNaturschutzFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."positionFollowsRHR"();

-- -----------------------------------------------------
-- Table "LP_SchutzgebieteObjekte"."LP_WasserrechtGemeingebrEinschraenkungNaturschutzLinie"
-- -----------------------------------------------------
CREATE  TABLE  "LP_SchutzgebieteObjekte"."LP_WasserrechtGemeingebrEinschraenkungNaturschutzLinie" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_LP_WasserrGemeingebrEinschrNaturschutzLinie_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "LP_SchutzgebieteObjekte"."LP_WasserrechtGemeingebrEinschraenkungNaturschutz" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("LP_Basisobjekte"."LP_Linienobjekt");

GRANT SELECT ON TABLE "LP_SchutzgebieteObjekte"."LP_WasserrechtGemeingebrEinschraenkungNaturschutzLinie" TO xp_gast;
GRANT ALL ON TABLE "LP_SchutzgebieteObjekte"."LP_WasserrechtGemeingebrEinschraenkungNaturschutzLinie" TO lp_user;
CREATE INDEX "LP_WasserrGemeingebrEinschrNaturschutzLinie_gidx" ON "LP_SchutzgebieteObjekte"."LP_WasserrechtGemeingebrEinschraenkungNaturschutzLinie" using gist ("position");
CREATE TRIGGER "change_to_LP_WasserrGemeingebrEinschrNaturschutzLinie" BEFORE INSERT OR UPDATE ON "LP_SchutzgebieteObjekte"."LP_WasserrechtGemeingebrEinschraenkungNaturschutzLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_LP_WasserrGemeingebrEinschrNaturschutzLinie" AFTER DELETE ON "LP_SchutzgebieteObjekte"."LP_WasserrechtGemeingebrEinschraenkungNaturschutzLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "LP_SchutzgebieteObjekte"."LP_WasserrechtGemeingebrEinschraenkungNaturschutzPunkt"
-- -----------------------------------------------------
CREATE  TABLE  "LP_SchutzgebieteObjekte"."LP_WasserrechtGemeingebrEinschraenkungNaturschutzPunkt" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_LP_WasserrGemeingebrEinschrNaturschutzPunkt_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "LP_SchutzgebieteObjekte"."LP_WasserrechtGemeingebrEinschraenkungNaturschutz" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("LP_Basisobjekte"."LP_Punktobjekt");

GRANT SELECT ON TABLE "LP_SchutzgebieteObjekte"."LP_WasserrechtGemeingebrEinschraenkungNaturschutzPunkt" TO xp_gast;
GRANT ALL ON TABLE "LP_SchutzgebieteObjekte"."LP_WasserrechtGemeingebrEinschraenkungNaturschutzPunkt" TO lp_user;
CREATE INDEX "LP_WasserrGemeingebrEinschrNaturschutzPunkt_gidx" ON "LP_SchutzgebieteObjekte"."LP_WasserrechtGemeingebrEinschraenkungNaturschutzPunkt" using gist ("position");
CREATE TRIGGER "change_to_LP_WasserrGemeingebrEinschrNaturschutzPunkt" BEFORE INSERT OR UPDATE ON "LP_SchutzgebieteObjekte"."LP_WasserrechtGemeingebrEinschraenkungNaturschutzPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_LP_WasserrGemeingebrEinschrNaturschutzPunkt" AFTER DELETE ON "LP_SchutzgebieteObjekte"."LP_WasserrechtGemeingebrEinschraenkungNaturschutzPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "LP_SchutzgebieteObjekte"."LP_WasserrechtSchutzgebietTypen"
-- -----------------------------------------------------
CREATE  TABLE  "LP_SchutzgebieteObjekte"."LP_WasserrechtSchutzgebietTypen" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Code") );
GRANT SELECT ON TABLE "LP_SchutzgebieteObjekte"."LP_WasserrechtSchutzgebietTypen" TO xp_gast;

-- -----------------------------------------------------
-- Table "LP_SchutzgebieteObjekte"."LP_WasserrechtSchutzgebietDetailTypen"
-- -----------------------------------------------------
CREATE  TABLE  "LP_SchutzgebieteObjekte"."LP_WasserrechtSchutzgebietDetailTypen" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Code") );
GRANT SELECT ON TABLE "LP_SchutzgebieteObjekte"."LP_WasserrechtSchutzgebietDetailTypen" TO xp_gast;
GRANT ALL ON TABLE "LP_SchutzgebieteObjekte"."LP_WasserrechtSchutzgebietDetailTypen" TO lp_user;
CREATE TRIGGER "ins_upd_LP_WasserrechtSchutzgebietDetailTypen" BEFORE INSERT OR UPDATE ON "LP_SchutzgebieteObjekte"."LP_WasserrechtSchutzgebietDetailTypen" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isCodeList"();

-- -----------------------------------------------------
-- Table "LP_SchutzgebieteObjekte"."LP_WasserrechtSchutzgebiet"
-- -----------------------------------------------------
CREATE  TABLE  "LP_SchutzgebieteObjekte"."LP_WasserrechtSchutzgebiet" (
  "gid" BIGINT NOT NULL ,
  "typ" INTEGER NULL ,
  "detailTyp" INTEGER NULL ,
  "eigenname" VARCHAR (64) NULL,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_LP_WasserrechtSchutzgebiet_typ1"
    FOREIGN KEY ("typ" )
    REFERENCES "LP_SchutzgebieteObjekte"."LP_WasserrechtSchutzgebietTypen" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_LP_WasserrechtSchutzgebiet_detailTyp1"
    FOREIGN KEY ("detailTyp" )
    REFERENCES "LP_SchutzgebieteObjekte"."LP_WasserrechtSchutzgebietDetailTypen" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_LP_WasserrechtSchutzgebiet_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "LP_Basisobjekte"."LP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE);

GRANT SELECT ON TABLE "LP_SchutzgebieteObjekte"."LP_WasserrechtSchutzgebiet" TO xp_gast;
GRANT ALL ON TABLE "LP_SchutzgebieteObjekte"."LP_WasserrechtSchutzgebiet" TO lp_user;
COMMENT ON TABLE  "LP_SchutzgebieteObjekte"."LP_WasserrechtSchutzgebiet" IS 'Gebiete und Gebietsteile mit rechtlichen Bindungen nach anderen Fachgesetzen (soweit sie für den Schutz, die Pflege und die Entwicklung von Natur und Landschaft bedeutsam sind). Hier: Flächen mit schädlichen Bodenveränderungen nach dem Bodenschutzgesetz.';
COMMENT ON COLUMN  "LP_SchutzgebieteObjekte"."LP_WasserrechtSchutzgebiet"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN  "LP_SchutzgebieteObjekte"."LP_WasserrechtSchutzgebiet"."typ" IS 'Typ des Schutzobjektes';
COMMENT ON COLUMN  "LP_SchutzgebieteObjekte"."LP_WasserrechtSchutzgebiet"."detailTyp" IS 'Über eine CodeList definierter zusätzlicher Typ des Schutzobjektes.';
COMMENT ON COLUMN  "LP_SchutzgebieteObjekte"."LP_WasserrechtSchutzgebiet"."eigenname" IS 'Eigennahme des Schutzgebietes.';
CREATE INDEX "idx_fk_LP_WasserrechtSchutzgebiet_typ" ON "LP_SchutzgebieteObjekte"."LP_WasserrechtSchutzgebiet" ("typ") ;
CREATE TRIGGER "change_to_LP_WasserrechtSchutzgebiet" BEFORE INSERT OR UPDATE ON "LP_SchutzgebieteObjekte"."LP_WasserrechtSchutzgebiet" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_LP_WasserrechtSchutzgebiet" AFTER DELETE ON "LP_SchutzgebieteObjekte"."LP_WasserrechtSchutzgebiet" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "LP_SchutzgebieteObjekte"."LP_WasserrechtSchutzgebietFlaeche"
-- -----------------------------------------------------
CREATE  TABLE  "LP_SchutzgebieteObjekte"."LP_WasserrechtSchutzgebietFlaeche" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_LP_WasserrechtSchutzgebietFlaeche_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "LP_SchutzgebieteObjekte"."LP_WasserrechtSchutzgebiet" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("LP_Basisobjekte"."LP_Flaechenobjekt");

GRANT SELECT ON TABLE "LP_SchutzgebieteObjekte"."LP_WasserrechtSchutzgebietFlaeche" TO xp_gast;
GRANT ALL ON TABLE "LP_SchutzgebieteObjekte"."LP_WasserrechtSchutzgebietFlaeche" TO lp_user;
CREATE INDEX "LP_WasserrechtSchutzgebietFlaeche_gidx" ON "LP_SchutzgebieteObjekte"."LP_WasserrechtSchutzgebietFlaeche" using gist ("position");
CREATE TRIGGER "change_to_LP_WasserrechtSchutzgebietFlaeche" BEFORE INSERT OR UPDATE ON "LP_SchutzgebieteObjekte"."LP_WasserrechtSchutzgebietFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_LP_WasserrechtSchutzgebietFlaeche" AFTER DELETE ON "LP_SchutzgebieteObjekte"."LP_WasserrechtSchutzgebietFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "LP_WasserrechtSchutzgebietFlaeche_Flaechenobjekt" BEFORE INSERT OR UPDATE ON "LP_SchutzgebieteObjekte"."LP_WasserrechtSchutzgebietFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."positionFollowsRHR"();

-- -----------------------------------------------------
-- Table "LP_SchutzgebieteObjekte"."LP_WasserrechtSchutzgebietLinie"
-- -----------------------------------------------------
CREATE  TABLE  "LP_SchutzgebieteObjekte"."LP_WasserrechtSchutzgebietLinie" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_LP_WasserrechtSchutzgebietLinie_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "LP_SchutzgebieteObjekte"."LP_WasserrechtSchutzgebiet" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("LP_Basisobjekte"."LP_Linienobjekt");

GRANT SELECT ON TABLE "LP_SchutzgebieteObjekte"."LP_WasserrechtSchutzgebietLinie" TO xp_gast;
GRANT ALL ON TABLE "LP_SchutzgebieteObjekte"."LP_WasserrechtSchutzgebietLinie" TO lp_user;
CREATE INDEX "LP_WasserrechtSchutzgebietLinie_gidx" ON "LP_SchutzgebieteObjekte"."LP_WasserrechtSchutzgebietLinie" using gist ("position");
CREATE TRIGGER "change_to_LP_WasserrechtSchutzgebietLinie" BEFORE INSERT OR UPDATE ON "LP_SchutzgebieteObjekte"."LP_WasserrechtSchutzgebietLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_LP_WasserrechtSchutzgebietLinie" AFTER DELETE ON "LP_SchutzgebieteObjekte"."LP_WasserrechtSchutzgebietLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "LP_SchutzgebieteObjekte"."LP_WasserrechtSchutzgebietPunkt"
-- -----------------------------------------------------
CREATE  TABLE  "LP_SchutzgebieteObjekte"."LP_WasserrechtSchutzgebietPunkt" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_LP_WasserrechtSchutzgebietPunkt_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "LP_SchutzgebieteObjekte"."LP_WasserrechtSchutzgebiet" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("LP_Basisobjekte"."LP_Punktobjekt");

GRANT SELECT ON TABLE "LP_SchutzgebieteObjekte"."LP_WasserrechtSchutzgebietPunkt" TO xp_gast;
GRANT ALL ON TABLE "LP_SchutzgebieteObjekte"."LP_WasserrechtSchutzgebietPunkt" TO lp_user;
CREATE INDEX "LP_WasserrechtSchutzgebietPunkt_gidx" ON "LP_SchutzgebieteObjekte"."LP_WasserrechtSchutzgebietPunkt" using gist ("position");
CREATE TRIGGER "change_to_LP_WasserrechtSchutzgebietPunkt" BEFORE INSERT OR UPDATE ON "LP_SchutzgebieteObjekte"."LP_WasserrechtSchutzgebietPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_LP_WasserrechtSchutzgebietPunkt" AFTER DELETE ON "LP_SchutzgebieteObjekte"."LP_WasserrechtSchutzgebietPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "LP_SchutzgebieteObjekte"."LP_WasserrechtSonstigeTypen"
-- -----------------------------------------------------
CREATE  TABLE  "LP_SchutzgebieteObjekte"."LP_WasserrechtSonstigeTypen" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Code") );
GRANT SELECT ON TABLE "LP_SchutzgebieteObjekte"."LP_WasserrechtSonstigeTypen" TO xp_gast;
GRANT ALL ON TABLE "LP_SchutzgebieteObjekte"."LP_WasserrechtSonstigeTypen" TO lp_user;
CREATE TRIGGER "ins_upd_LP_WasserrechtSonstigeTypen" BEFORE INSERT OR UPDATE ON "LP_SchutzgebieteObjekte"."LP_WasserrechtSonstigeTypen" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isCodeList"();

-- -----------------------------------------------------
-- Table "LP_SchutzgebieteObjekte"."LP_WasserrechtSonstige"
-- -----------------------------------------------------
CREATE  TABLE  "LP_SchutzgebieteObjekte"."LP_WasserrechtSonstige" (
  "gid" BIGINT NOT NULL ,
  "typ" INTEGER NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_LP_WasserrechtSonstige_typ1"
    FOREIGN KEY ("typ" )
    REFERENCES "LP_SchutzgebieteObjekte"."LP_WasserrechtSonstigeTypen" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_LP_WasserrechtSonstige_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "LP_Basisobjekte"."LP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE);

GRANT SELECT ON TABLE "LP_SchutzgebieteObjekte"."LP_WasserrechtSonstige" TO xp_gast;
GRANT ALL ON TABLE "LP_SchutzgebieteObjekte"."LP_WasserrechtSonstige" TO lp_user;
COMMENT ON TABLE  "LP_SchutzgebieteObjekte"."LP_WasserrechtSonstige" IS 'Gebiete und Gebietsteile mit rechtlichen Bindungen nach anderen Fachgesetzen (soweit sie für den Schutz, die Pflege und die Entwicklung von Natur und Landschaft bedeutsam sind). Hier: Sonstige wasserrechtliche Flächen';
COMMENT ON COLUMN  "LP_SchutzgebieteObjekte"."LP_WasserrechtSonstige"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN  "LP_SchutzgebieteObjekte"."LP_WasserrechtSonstige"."typ" IS 'Über eine CodeList definierter Typ des Schutzobjektes.';
CREATE TRIGGER "change_to_LP_WasserrechtSonstige" BEFORE INSERT OR UPDATE ON "LP_SchutzgebieteObjekte"."LP_WasserrechtSonstige" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_LP_WasserrechtSonstige" AFTER DELETE ON "LP_SchutzgebieteObjekte"."LP_WasserrechtSonstige" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "LP_SchutzgebieteObjekte"."LP_WasserrechtSonstigeFlaeche"
-- -----------------------------------------------------
CREATE  TABLE  "LP_SchutzgebieteObjekte"."LP_WasserrechtSonstigeFlaeche" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_LP_WasserrechtSonstigeFlaeche_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "LP_SchutzgebieteObjekte"."LP_WasserrechtSonstige" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("LP_Basisobjekte"."LP_Flaechenobjekt");

GRANT SELECT ON TABLE "LP_SchutzgebieteObjekte"."LP_WasserrechtSonstigeFlaeche" TO xp_gast;
GRANT ALL ON TABLE "LP_SchutzgebieteObjekte"."LP_WasserrechtSonstigeFlaeche" TO lp_user;
CREATE INDEX "LP_WasserrechtSonstigeFlaeche_gidx" ON "LP_SchutzgebieteObjekte"."LP_WasserrechtSonstigeFlaeche" using gist ("position");
CREATE TRIGGER "change_to_LP_WasserrechtSonstigeFlaeche" BEFORE INSERT OR UPDATE ON "LP_SchutzgebieteObjekte"."LP_WasserrechtSonstigeFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_LP_WasserrechtSonstigeFlaeche" AFTER DELETE ON "LP_SchutzgebieteObjekte"."LP_WasserrechtSonstigeFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "LP_WasserrechtSonstigeFlaeche_Flaechenobjekt" BEFORE INSERT OR UPDATE ON "LP_SchutzgebieteObjekte"."LP_WasserrechtSonstigeFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."positionFollowsRHR"();

-- -----------------------------------------------------
-- Table "LP_SchutzgebieteObjekte"."LP_WasserrechtSonstigeLinie"
-- -----------------------------------------------------
CREATE  TABLE  "LP_SchutzgebieteObjekte"."LP_WasserrechtSonstigeLinie" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_LP_WasserrechtSonstigeLinie_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "LP_SchutzgebieteObjekte"."LP_WasserrechtSonstige" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("LP_Basisobjekte"."LP_Linienobjekt");

GRANT SELECT ON TABLE "LP_SchutzgebieteObjekte"."LP_WasserrechtSonstigeLinie" TO xp_gast;
GRANT ALL ON TABLE "LP_SchutzgebieteObjekte"."LP_WasserrechtSonstigeLinie" TO lp_user;
CREATE INDEX "LP_WasserrechtSonstigeLinie_gidx" ON "LP_SchutzgebieteObjekte"."LP_WasserrechtSonstigeLinie" using gist ("position");
CREATE TRIGGER "change_to_LP_WasserrechtSonstigeLinie" BEFORE INSERT OR UPDATE ON "LP_SchutzgebieteObjekte"."LP_WasserrechtSonstigeLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_LP_WasserrechtSonstigeLinie" AFTER DELETE ON "LP_SchutzgebieteObjekte"."LP_WasserrechtSonstigeLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "LP_SchutzgebieteObjekte"."LP_WasserrechtSonstigePunkt"
-- -----------------------------------------------------
CREATE  TABLE  "LP_SchutzgebieteObjekte"."LP_WasserrechtSonstigePunkt" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_LP_WasserrechtSonstigePunkt_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "LP_SchutzgebieteObjekte"."LP_WasserrechtSonstige" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("LP_Basisobjekte"."LP_Punktobjekt");

GRANT SELECT ON TABLE "LP_SchutzgebieteObjekte"."LP_WasserrechtSonstigePunkt" TO xp_gast;
GRANT ALL ON TABLE "LP_SchutzgebieteObjekte"."LP_WasserrechtSonstigePunkt" TO lp_user;
CREATE INDEX "LP_WasserrechtSonstigePunkt_gidx" ON "LP_SchutzgebieteObjekte"."LP_WasserrechtSonstigePunkt" using gist ("position");
CREATE TRIGGER "change_to_LP_WasserrechtSonstigePunkt" BEFORE INSERT OR UPDATE ON "LP_SchutzgebieteObjekte"."LP_WasserrechtSonstigePunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_LP_WasserrechtSonstigePunkt" AFTER DELETE ON "LP_SchutzgebieteObjekte"."LP_WasserrechtSonstigePunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "LP_SchutzgebieteObjekte"."LP_WasserrechtWirtschaftAbflussHochwSchutzTypen"
-- -----------------------------------------------------
CREATE  TABLE  "LP_SchutzgebieteObjekte"."LP_WasserrechtWirtschaftAbflussHochwSchutzTypen" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Code") );
GRANT SELECT ON TABLE "LP_SchutzgebieteObjekte"."LP_WasserrechtWirtschaftAbflussHochwSchutzTypen" TO xp_gast;

-- -----------------------------------------------------
-- Table "LP_SchutzgebieteObjekte"."LP_WasserrechtWirtschaftAbflussHochwSchutzDetailTypen"
-- -----------------------------------------------------
CREATE  TABLE  "LP_SchutzgebieteObjekte"."LP_WasserrechtWirtschaftAbflussHochwSchutzDetailTypen" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Code") );
GRANT SELECT ON TABLE "LP_SchutzgebieteObjekte"."LP_WasserrechtWirtschaftAbflussHochwSchutzDetailTypen" TO xp_gast;
GRANT ALL ON TABLE "LP_SchutzgebieteObjekte"."LP_WasserrechtWirtschaftAbflussHochwSchutzDetailTypen" TO lp_user;
CREATE TRIGGER "ins_upd_LP_WasserrechtWirtschaftAbflussHochwSchutzDetailTypen" BEFORE INSERT OR UPDATE ON "LP_SchutzgebieteObjekte"."LP_WasserrechtWirtschaftAbflussHochwSchutzDetailTypen" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isCodeList"();

-- -----------------------------------------------------
-- Table "LP_SchutzgebieteObjekte"."LP_WasserrechtWirtschaftAbflussHochwSchutz"
-- -----------------------------------------------------
CREATE  TABLE  "LP_SchutzgebieteObjekte"."LP_WasserrechtWirtschaftAbflussHochwSchutz" (
  "gid" BIGINT NOT NULL ,
  "typ" INTEGER NULL ,
  "detailTyp" INTEGER NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_LP_WasserrechtWirtschaftAbflussHochwSchutz_typ1"
    FOREIGN KEY ("typ" )
    REFERENCES "LP_SchutzgebieteObjekte"."LP_WasserrechtWirtschaftAbflussHochwSchutzTypen" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_LP_WasserrechtWirtschaftAbflussHochwSchutz_detailTyp1"
    FOREIGN KEY ("detailTyp" )
    REFERENCES "LP_SchutzgebieteObjekte"."LP_WasserrechtWirtschaftAbflussHochwSchutzDetailTypen" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_LP_WasserrechtWirtschaftAbflussHochwSchutz_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "LP_Basisobjekte"."LP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE);

GRANT SELECT ON TABLE "LP_SchutzgebieteObjekte"."LP_WasserrechtWirtschaftAbflussHochwSchutz" TO xp_gast;
GRANT ALL ON TABLE "LP_SchutzgebieteObjekte"."LP_WasserrechtWirtschaftAbflussHochwSchutz" TO lp_user;
COMMENT ON TABLE  "LP_SchutzgebieteObjekte"."LP_WasserrechtWirtschaftAbflussHochwSchutz" IS 'Gebiete und Gebietsteile mit rechtlichen Bindungen nach anderen Fachgesetzen (soweit sie für den Schutz, die Pflege und die Entwicklung von Natur und Landschaft bedeutsam sind). Hier: Flächen für die Wasserwirtschaft, den Hochwasserschutz und die Regelung des Wasserabflusses nach dem Wasserhaushaltsgesetz.';
COMMENT ON COLUMN  "LP_SchutzgebieteObjekte"."LP_WasserrechtWirtschaftAbflussHochwSchutz"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN  "LP_SchutzgebieteObjekte"."LP_WasserrechtWirtschaftAbflussHochwSchutz"."typ" IS 'Typ des Schutzobjektes';
COMMENT ON COLUMN  "LP_SchutzgebieteObjekte"."LP_WasserrechtWirtschaftAbflussHochwSchutz"."detailTyp" IS 'Über eine CodeList definierter zusätzlicher Typ des Schutzobjektes.';
CREATE INDEX "idx_fk_LP_WasserrechtWirtschaftAbflussHochwSchutz_typ" ON "LP_SchutzgebieteObjekte"."LP_WasserrechtWirtschaftAbflussHochwSchutz" ("typ") ;
CREATE TRIGGER "change_to_LP_WasserrechtWirtschaftAbflussHochwSchutz" BEFORE INSERT OR UPDATE ON "LP_SchutzgebieteObjekte"."LP_WasserrechtWirtschaftAbflussHochwSchutz" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_LP_WasserrechtWirtschaftAbflussHochwSchutz" AFTER DELETE ON "LP_SchutzgebieteObjekte"."LP_WasserrechtWirtschaftAbflussHochwSchutz" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "LP_SchutzgebieteObjekte"."LP_WasserrechtWirtschaftAbflussHochwSchutzFlaeche"
-- -----------------------------------------------------
CREATE  TABLE  "LP_SchutzgebieteObjekte"."LP_WasserrechtWirtschaftAbflussHochwSchutzFlaeche" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_LP_WasserrechtWirtschaftAbflussHochwSchutzFlaeche_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "LP_SchutzgebieteObjekte"."LP_WasserrechtWirtschaftAbflussHochwSchutz" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("LP_Basisobjekte"."LP_Flaechenobjekt");

GRANT SELECT ON TABLE "LP_SchutzgebieteObjekte"."LP_WasserrechtWirtschaftAbflussHochwSchutzFlaeche" TO xp_gast;
GRANT ALL ON TABLE "LP_SchutzgebieteObjekte"."LP_WasserrechtWirtschaftAbflussHochwSchutzFlaeche" TO lp_user;
CREATE INDEX "LP_WasserrechtWirtschaftAbflussHochwSchutzFlaeche_gidx" ON "LP_SchutzgebieteObjekte"."LP_WasserrechtWirtschaftAbflussHochwSchutzFlaeche" using gist ("position");
CREATE TRIGGER "change_to_LP_WasserrechtWirtschaftAbflussHochwSchutzFlaeche" BEFORE INSERT OR UPDATE ON "LP_SchutzgebieteObjekte"."LP_WasserrechtWirtschaftAbflussHochwSchutzFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_LP_WasserrechtWirtschaftAbflussHochwSchutzFlaeche" AFTER DELETE ON "LP_SchutzgebieteObjekte"."LP_WasserrechtWirtschaftAbflussHochwSchutzFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "LP_WasserrechtWirtschaftAbflussHochwSchutzFlaeche_Flaechenobjekt" BEFORE INSERT OR UPDATE ON "LP_SchutzgebieteObjekte"."LP_WasserrechtWirtschaftAbflussHochwSchutzFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."positionFollowsRHR"();

-- -----------------------------------------------------
-- Table "LP_SchutzgebieteObjekte"."LP_WasserrechtWirtschaftAbflussHochwSchutzLinie"
-- -----------------------------------------------------
CREATE  TABLE  "LP_SchutzgebieteObjekte"."LP_WasserrechtWirtschaftAbflussHochwSchutzLinie" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_LP_WasserrechtWirtschaftAbflussHochwSchutzLinie_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "LP_SchutzgebieteObjekte"."LP_WasserrechtWirtschaftAbflussHochwSchutz" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("LP_Basisobjekte"."LP_Linienobjekt");

GRANT SELECT ON TABLE "LP_SchutzgebieteObjekte"."LP_WasserrechtWirtschaftAbflussHochwSchutzLinie" TO xp_gast;
GRANT ALL ON TABLE "LP_SchutzgebieteObjekte"."LP_WasserrechtWirtschaftAbflussHochwSchutzLinie" TO lp_user;
CREATE INDEX "LP_WasserrechtWirtschaftAbflussHochwSchutzLinie_gidx" ON "LP_SchutzgebieteObjekte"."LP_WasserrechtWirtschaftAbflussHochwSchutzLinie" using gist ("position");
CREATE TRIGGER "change_to_LP_WasserrechtWirtschaftAbflussHochwSchutzLinie" BEFORE INSERT OR UPDATE ON "LP_SchutzgebieteObjekte"."LP_WasserrechtWirtschaftAbflussHochwSchutzLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_LP_WasserrechtWirtschaftAbflussHochwSchutzLinie" AFTER DELETE ON "LP_SchutzgebieteObjekte"."LP_WasserrechtWirtschaftAbflussHochwSchutzLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "LP_SchutzgebieteObjekte"."LP_WasserrechtWirtschaftAbflussHochwSchutzPunkt"
-- -----------------------------------------------------
CREATE  TABLE  "LP_SchutzgebieteObjekte"."LP_WasserrechtWirtschaftAbflussHochwSchutzPunkt" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_LP_WasserrechtWirtschaftAbflussHochwSchutzPunkt_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "LP_SchutzgebieteObjekte"."LP_WasserrechtWirtschaftAbflussHochwSchutz" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("LP_Basisobjekte"."LP_Punktobjekt");

GRANT SELECT ON TABLE "LP_SchutzgebieteObjekte"."LP_WasserrechtWirtschaftAbflussHochwSchutzPunkt" TO xp_gast;
GRANT ALL ON TABLE "LP_SchutzgebieteObjekte"."LP_WasserrechtWirtschaftAbflussHochwSchutzPunkt" TO lp_user;
CREATE INDEX "LP_WasserrechtWirtschaftAbflussHochwSchutzPunkt_gidx" ON "LP_SchutzgebieteObjekte"."LP_WasserrechtWirtschaftAbflussHochwSchutzPunkt" using gist ("position");
CREATE TRIGGER "change_to_LP_WasserrechtWirtschaftAbflussHochwSchutzPunkt" BEFORE INSERT OR UPDATE ON "LP_SchutzgebieteObjekte"."LP_WasserrechtWirtschaftAbflussHochwSchutzPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_LP_WasserrechtWirtschaftAbflussHochwSchutzPunkt" AFTER DELETE ON "LP_SchutzgebieteObjekte"."LP_WasserrechtWirtschaftAbflussHochwSchutzPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "LP_Sonstiges"."LP_Abgrenzung"
-- -----------------------------------------------------
CREATE  TABLE  "LP_Sonstiges"."LP_Abgrenzung" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_LP_Abgrenzung_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "LP_Basisobjekte"."LP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("LP_Basisobjekte"."LP_Linienobjekt");

GRANT SELECT ON TABLE "LP_Sonstiges"."LP_Abgrenzung" TO xp_gast;
GRANT ALL ON TABLE "LP_Sonstiges"."LP_Abgrenzung" TO lp_user;
COMMENT ON TABLE  "LP_Sonstiges"."LP_Abgrenzung" IS 'Abgrenzungen unterschiedlicher Ziel- und Zweckbestimmungen und Nutzungsarten, Abgrenzungen unterschiedlicher Biotoptypen.';
CREATE INDEX "LP_WasserrechtWirtschaftAbflussHochwSchutzLinie_gidx" ON "LP_Sonstiges"."LP_Abgrenzung" using gist ("position");
CREATE TRIGGER "change_to_LP_WasserrechtWirtschaftAbflussHochwSchutzLinie" BEFORE INSERT OR UPDATE ON "LP_Sonstiges"."LP_Abgrenzung" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_LP_WasserrechtWirtschaftAbflussHochwSchutzLinie" AFTER DELETE ON "LP_Sonstiges"."LP_Abgrenzung" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "LP_Sonstiges"."LP_GenerischesObjekt"
-- -----------------------------------------------------
CREATE  TABLE  "LP_Sonstiges"."LP_GenerischesObjekt" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_LP_GenerischesObjekt_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "LP_Basisobjekte"."LP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE);

GRANT SELECT ON TABLE "LP_Sonstiges"."LP_GenerischesObjekt" TO xp_gast;
GRANT ALL ON TABLE "LP_Sonstiges"."LP_GenerischesObjekt" TO fp_user;
COMMENT ON TABLE "LP_Sonstiges"."LP_GenerischesObjekt" IS 'Klasse zur Modellierung aller Inhalte des Landschaftsplans, die durch keine andere Klasse des LPlan-Fachschemas dargestellt werden können.';
COMMENT ON COLUMN  "LP_Sonstiges"."LP_GenerischesObjekt"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_LP_GenerischesObjekt" BEFORE INSERT OR UPDATE ON "LP_Sonstiges"."LP_GenerischesObjekt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_LP_GenerischesObjekt" AFTER DELETE ON "LP_Sonstiges"."LP_GenerischesObjekt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "LP_Sonstiges"."LP_ZweckbestimmungGenerischeObjekte"
-- -----------------------------------------------------
CREATE TABLE "LP_Sonstiges"."LP_ZweckbestimmungGenerischeObjekte" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Code") );
GRANT SELECT ON TABLE "LP_Sonstiges"."LP_ZweckbestimmungGenerischeObjekte" TO xp_gast;
GRANT ALL ON TABLE "LP_Sonstiges"."LP_ZweckbestimmungGenerischeObjekte" TO lp_user;
CREATE TRIGGER "ins_upd_LP_ZweckbestimmungGenerischeObjekte" BEFORE INSERT OR UPDATE ON "LP_Sonstiges"."LP_ZweckbestimmungGenerischeObjekte" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isCodeList"();


-- -----------------------------------------------------
-- Table LP_Sonstiges"."LP_GenerischesObjekt_zweckbestimmung"
-- -----------------------------------------------------
CREATE TABLE "LP_Sonstiges"."LP_GenerischesObjekt_zweckbestimmung" (
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
GRANT ALL ON TABLE "LP_Sonstiges"."LP_GenerischesObjekt_zweckbestimmung" TO lp_user;
COMMENT ON TABLE  "LP_Sonstiges"."LP_GenerischesObjekt_zweckbestimmung" IS 'Über eine CodeList definierte Zweckbestimmungen des Generischen Objekts.';

-- -----------------------------------------------------
-- Table "LP_Sonstiges"."LP_GenerischesObjektFlaeche"
-- -----------------------------------------------------
CREATE  TABLE  "LP_Sonstiges"."LP_GenerischesObjektFlaeche" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_LP_GenerischesObjektFlaeche_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "LP_Sonstiges"."LP_GenerischesObjekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("LP_Basisobjekte"."LP_Flaechenobjekt");

GRANT SELECT ON TABLE "LP_Sonstiges"."LP_GenerischesObjektFlaeche" TO xp_gast;
GRANT ALL ON TABLE "LP_Sonstiges"."LP_GenerischesObjektFlaeche" TO fp_user;
CREATE TRIGGER "change_to_LP_GenerischesObjektFlaeche" BEFORE INSERT OR UPDATE ON "LP_Sonstiges"."LP_GenerischesObjektFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_LP_GenerischesObjektFlaeche" AFTER DELETE ON "LP_Sonstiges"."LP_GenerischesObjektFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "LP_GenerischesObjektFlaeche_Flaechenobjekt" BEFORE INSERT OR UPDATE ON "LP_Sonstiges"."LP_GenerischesObjektFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."positionFollowsRHR"();

-- -----------------------------------------------------
-- Table "LP_Sonstiges"."LP_GenerischesObjektLinie"
-- -----------------------------------------------------
CREATE  TABLE  "LP_Sonstiges"."LP_GenerischesObjektLinie" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_LP_GenerischesObjektLinie_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "LP_Sonstiges"."LP_GenerischesObjekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("LP_Basisobjekte"."LP_Linienobjekt");

GRANT SELECT ON TABLE "LP_Sonstiges"."LP_GenerischesObjektLinie" TO xp_gast;
GRANT ALL ON TABLE "LP_Sonstiges"."LP_GenerischesObjektLinie" TO fp_user;
CREATE TRIGGER "change_to_LP_GenerischesObjektLinie" BEFORE INSERT OR UPDATE ON "LP_Sonstiges"."LP_GenerischesObjektLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_LP_GenerischesObjektLinie" AFTER DELETE ON "LP_Sonstiges"."LP_GenerischesObjektLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "LP_Sonstiges"."LP_GenerischesObjektPunkt"
-- -----------------------------------------------------
CREATE  TABLE  "LP_Sonstiges"."LP_GenerischesObjektPunkt" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_LP_GenerischesObjektPunkt_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "LP_Sonstiges"."LP_GenerischesObjekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("LP_Basisobjekte"."LP_Punktobjekt");

GRANT SELECT ON TABLE "LP_Sonstiges"."LP_GenerischesObjektPunkt" TO xp_gast;
GRANT ALL ON TABLE "LP_Sonstiges"."LP_GenerischesObjektPunkt" TO fp_user;
CREATE TRIGGER "change_to_LP_GenerischesObjektPunkt" BEFORE INSERT OR UPDATE ON "LP_Sonstiges"."LP_GenerischesObjektPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_LP_GenerischesObjektPunkt" AFTER DELETE ON "LP_Sonstiges"."LP_GenerischesObjektPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "LP_Sonstiges"."LP_MassnahmeLandschaftsbild"
-- -----------------------------------------------------
CREATE  TABLE  "LP_Sonstiges"."LP_MassnahmeLandschaftsbild" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(256) NOT NULL ,
  PRIMARY KEY ("Code") );
GRANT SELECT ON TABLE "LP_Sonstiges"."LP_MassnahmeLandschaftsbild" TO xp_gast;
GRANT ALL ON TABLE "LP_Sonstiges"."LP_MassnahmeLandschaftsbild" TO lp_user;
CREATE TRIGGER "ins_upd_LP_MassnahmeLandschaftsbild" BEFORE INSERT OR UPDATE ON "LP_Sonstiges"."LP_MassnahmeLandschaftsbild" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isCodeList"();

-- -----------------------------------------------------
-- Table "LP_Sonstiges"."LP_Landschaftsbild"
-- -----------------------------------------------------
CREATE  TABLE  "LP_Sonstiges"."LP_Landschaftsbild" (
  "gid" BIGINT NOT NULL ,
  "massnahme" INTEGER NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_LP_Landschaftsbild_massnahme1"
    FOREIGN KEY ("massnahme" )
    REFERENCES "LP_Sonstiges"."LP_MassnahmeLandschaftsbild" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_LP_Landschaftsbild_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "LP_Basisobjekte"."LP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE);

GRANT SELECT ON TABLE "LP_Sonstiges"."LP_Landschaftsbild" TO xp_gast;
GRANT ALL ON TABLE "LP_Sonstiges"."LP_Landschaftsbild" TO lp_user;
COMMENT ON TABLE  "LP_Sonstiges"."LP_Landschaftsbild" IS 'Festlegung, Darstellung bzw. Festsetzung zum Landschaftsbild in einem landschaftsplanerischen Planwerk';
COMMENT ON COLUMN  "LP_Sonstiges"."LP_Landschaftsbild"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN  "LP_Sonstiges"."LP_Landschaftsbild"."massnahme" IS 'Spezifizierung einer Massnahme zum Landschaftsbild.';
CREATE INDEX "idx_fk_LP_Landschaftsbild_massnahme" ON "LP_Sonstiges"."LP_Landschaftsbild" ("massnahme") ;
CREATE TRIGGER "change_to_LP_Landschaftsbild" BEFORE INSERT OR UPDATE ON "LP_Sonstiges"."LP_Landschaftsbild" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_LP_Landschaftsbild" AFTER DELETE ON "LP_Sonstiges"."LP_Landschaftsbild" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "LP_Sonstiges"."LP_LandschaftsbildFlaeche"
-- -----------------------------------------------------
CREATE  TABLE  "LP_Sonstiges"."LP_LandschaftsbildFlaeche" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_LP_LandschaftsbildFlaeche_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "LP_Sonstiges"."LP_Landschaftsbild" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("LP_Basisobjekte"."LP_Flaechenobjekt");

GRANT SELECT ON TABLE "LP_Sonstiges"."LP_LandschaftsbildFlaeche" TO xp_gast;
GRANT ALL ON TABLE "LP_Sonstiges"."LP_LandschaftsbildFlaeche" TO lp_user;
CREATE INDEX "LP_LandschaftsbildFlaeche_gidx" ON "LP_Sonstiges"."LP_LandschaftsbildFlaeche" using gist ("position");
CREATE TRIGGER "change_to_LP_LandschaftsbildFlaeche" BEFORE INSERT OR UPDATE ON "LP_Sonstiges"."LP_LandschaftsbildFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_LP_LandschaftsbildFlaeche" AFTER DELETE ON "LP_Sonstiges"."LP_LandschaftsbildFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "LP_LandschaftsbildFlaeche_Flaechenobjekt" BEFORE INSERT OR UPDATE ON "LP_Sonstiges"."LP_LandschaftsbildFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."positionFollowsRHR"();

-- -----------------------------------------------------
-- Table "LP_Sonstiges"."LP_LandschaftsbildLinie"
-- -----------------------------------------------------
CREATE  TABLE  "LP_Sonstiges"."LP_LandschaftsbildLinie" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_LP_LandschaftsbildLinie_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "LP_Sonstiges"."LP_Landschaftsbild" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("LP_Basisobjekte"."LP_Linienobjekt");

GRANT SELECT ON TABLE "LP_Sonstiges"."LP_LandschaftsbildLinie" TO xp_gast;
GRANT ALL ON TABLE "LP_Sonstiges"."LP_LandschaftsbildLinie" TO lp_user;
CREATE INDEX "LP_LandschaftsbildLinie_gidx" ON "LP_Sonstiges"."LP_LandschaftsbildLinie" using gist ("position");
CREATE TRIGGER "change_to_LP_LandschaftsbildLinie" BEFORE INSERT OR UPDATE ON "LP_Sonstiges"."LP_LandschaftsbildLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_LP_LandschaftsbildLinie" AFTER DELETE ON "LP_Sonstiges"."LP_LandschaftsbildLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "LP_Sonstiges"."LP_LandschaftsbildPunkt"
-- -----------------------------------------------------
CREATE  TABLE  "LP_Sonstiges"."LP_LandschaftsbildPunkt" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_LP_LandschaftsbildPunkt_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "LP_Sonstiges"."LP_Landschaftsbild" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("LP_Basisobjekte"."LP_Punktobjekt");

GRANT SELECT ON TABLE "LP_Sonstiges"."LP_LandschaftsbildPunkt" TO xp_gast;
GRANT ALL ON TABLE "LP_Sonstiges"."LP_LandschaftsbildPunkt" TO lp_user;
CREATE INDEX "LP_LandschaftsbildPunkt_gidx" ON "LP_Sonstiges"."LP_LandschaftsbildPunkt" using gist ("position");
CREATE TRIGGER "change_to_LP_LandschaftsbildPunkt" BEFORE INSERT OR UPDATE ON "LP_Sonstiges"."LP_LandschaftsbildPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_LP_LandschaftsbildPunkt" AFTER DELETE ON "LP_Sonstiges"."LP_LandschaftsbildPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "LP_Sonstiges"."LP_NutzungsAusschluss"
-- -----------------------------------------------------
CREATE  TABLE  "LP_Sonstiges"."LP_NutzungsAusschluss" (
  "gid" BIGINT NOT NULL ,
  "auszuschliessendeNutzungen" VARCHAR(256) NULL ,
  "auszuschliessendeNutzungenKuerzel" VARCHAR(32) NULL ,
  "begruendung" VARCHAR(256) NULL ,
  "begruendungKuerzel" VARCHAR(32) NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_LP_NutzungsAusschluss_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "LP_Basisobjekte"."LP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE);

GRANT SELECT ON TABLE "LP_Sonstiges"."LP_NutzungsAusschluss" TO xp_gast;
GRANT ALL ON TABLE "LP_Sonstiges"."LP_NutzungsAusschluss" TO lp_user;
COMMENT ON TABLE  "LP_Sonstiges"."LP_NutzungsAusschluss" IS 'Flächen und Objekte die bestimmte geplante oder absehbare Nutzungsänderungen nicht erfahren sollen.';
COMMENT ON COLUMN  "LP_Sonstiges"."LP_NutzungsAusschluss"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN  "LP_Sonstiges"."LP_NutzungsAusschluss"."auszuschliessendeNutzungen" IS 'Typ des Schutzobjektes';
COMMENT ON COLUMN  "LP_Sonstiges"."LP_NutzungsAusschluss"."auszuschliessendeNutzungenKuerzel" IS 'Auszuschließende Nutzungen (Kürzel).';
COMMENT ON COLUMN  "LP_Sonstiges"."LP_NutzungsAusschluss"."begruendung" IS 'Begründung des Ausschlusses (Textform).';
COMMENT ON COLUMN  "LP_Sonstiges"."LP_NutzungsAusschluss"."begruendungKuerzel" IS 'Begründung des Ausschlusses (Kürzel)';
CREATE TRIGGER "change_to_LP_NutzungsAusschluss" BEFORE INSERT OR UPDATE ON "LP_Sonstiges"."LP_NutzungsAusschluss" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_LP_NutzungsAusschluss" AFTER DELETE ON "LP_Sonstiges"."LP_NutzungsAusschluss" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "LP_Sonstiges"."LP_NutzungsAusschlussFlaeche"
-- -----------------------------------------------------
CREATE  TABLE  "LP_Sonstiges"."LP_NutzungsAusschlussFlaeche" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_LP_NutzungsAusschlussFlaeche_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "LP_Sonstiges"."LP_NutzungsAusschluss" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("LP_Basisobjekte"."LP_Flaechenobjekt");

GRANT SELECT ON TABLE "LP_Sonstiges"."LP_NutzungsAusschlussFlaeche" TO xp_gast;
GRANT ALL ON TABLE "LP_Sonstiges"."LP_NutzungsAusschlussFlaeche" TO lp_user;
CREATE INDEX "LP_NutzungsAusschlussFlaeche_gidx" ON "LP_Sonstiges"."LP_NutzungsAusschlussFlaeche" using gist ("position");
CREATE TRIGGER "change_to_LP_NutzungsAusschlussFlaeche" BEFORE INSERT OR UPDATE ON "LP_Sonstiges"."LP_NutzungsAusschlussFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_LP_NutzungsAusschlussFlaeche" AFTER DELETE ON "LP_Sonstiges"."LP_NutzungsAusschlussFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "LP_NutzungsAusschlussFlaeche_Flaechenobjekt" BEFORE INSERT OR UPDATE ON "LP_Sonstiges"."LP_NutzungsAusschlussFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."positionFollowsRHR"();

-- -----------------------------------------------------
-- Table "LP_Sonstiges"."LP_NutzungsAusschlussLinie"
-- -----------------------------------------------------
CREATE  TABLE  "LP_Sonstiges"."LP_NutzungsAusschlussLinie" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_LP_NutzungsAusschlussLinie_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "LP_Sonstiges"."LP_NutzungsAusschluss" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("LP_Basisobjekte"."LP_Linienobjekt");

GRANT SELECT ON TABLE "LP_Sonstiges"."LP_NutzungsAusschlussLinie" TO xp_gast;
GRANT ALL ON TABLE "LP_Sonstiges"."LP_NutzungsAusschlussLinie" TO lp_user;
CREATE INDEX "LP_NutzungsAusschlussLinie_gidx" ON "LP_Sonstiges"."LP_NutzungsAusschlussLinie" using gist ("position");
CREATE TRIGGER "change_to_LP_NutzungsAusschlussLinie" BEFORE INSERT OR UPDATE ON "LP_Sonstiges"."LP_NutzungsAusschlussLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_LP_NutzungsAusschlussLinie" AFTER DELETE ON "LP_Sonstiges"."LP_NutzungsAusschlussLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "LP_Sonstiges"."LP_NutzungsAusschlussPunkt"
-- -----------------------------------------------------
CREATE  TABLE  "LP_Sonstiges"."LP_NutzungsAusschlussPunkt" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_LP_NutzungsAusschlussPunkt_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "LP_Sonstiges"."LP_NutzungsAusschluss" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("LP_Basisobjekte"."LP_Punktobjekt");

GRANT SELECT ON TABLE "LP_Sonstiges"."LP_NutzungsAusschlussPunkt" TO xp_gast;
GRANT ALL ON TABLE "LP_Sonstiges"."LP_NutzungsAusschlussPunkt" TO lp_user;
CREATE INDEX "LP_NutzungsAusschlussPunkt_gidx" ON "LP_Sonstiges"."LP_NutzungsAusschlussPunkt" using gist ("position");
CREATE TRIGGER "change_to_LP_NutzungsAusschlussPunkt" BEFORE INSERT OR UPDATE ON "LP_Sonstiges"."LP_NutzungsAusschlussPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_LP_NutzungsAusschlussPunkt" AFTER DELETE ON "LP_Sonstiges"."LP_NutzungsAusschlussPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "LP_Sonstiges"."LP_PlanerischeVertiefung"
-- -----------------------------------------------------
CREATE  TABLE  "LP_Sonstiges"."LP_PlanerischeVertiefung" (
  "gid" BIGINT NOT NULL ,
  "vertiefung" VARCHAR(256) NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_LP_PlanerischeVertiefung_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "LP_Basisobjekte"."LP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE);

GRANT SELECT ON TABLE "LP_Sonstiges"."LP_PlanerischeVertiefung" TO xp_gast;
GRANT ALL ON TABLE "LP_Sonstiges"."LP_PlanerischeVertiefung" TO lp_user;
COMMENT ON TABLE  "LP_Sonstiges"."LP_PlanerischeVertiefung" IS 'Bereiche, die einer planerischen Vertiefung bedürfen.';
COMMENT ON COLUMN  "LP_Sonstiges"."LP_PlanerischeVertiefung"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN  "LP_Sonstiges"."LP_PlanerischeVertiefung"."vertiefung" IS 'TTextliche Formulierung der Vertiefung';
CREATE TRIGGER "change_to_LP_PlanerischeVertiefung" BEFORE INSERT OR UPDATE ON "LP_Sonstiges"."LP_PlanerischeVertiefung" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_LP_PlanerischeVertiefung" AFTER DELETE ON "LP_Sonstiges"."LP_PlanerischeVertiefung" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "LP_Sonstiges"."LP_PlanerischeVertiefungFlaeche"
-- -----------------------------------------------------
CREATE  TABLE  "LP_Sonstiges"."LP_PlanerischeVertiefungFlaeche" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_LP_PlanerischeVertiefungFlaeche_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "LP_Sonstiges"."LP_PlanerischeVertiefung" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("LP_Basisobjekte"."LP_Flaechenobjekt");

GRANT SELECT ON TABLE "LP_Sonstiges"."LP_PlanerischeVertiefungFlaeche" TO xp_gast;
GRANT ALL ON TABLE "LP_Sonstiges"."LP_PlanerischeVertiefungFlaeche" TO lp_user;
CREATE INDEX "LP_PlanerischeVertiefungFlaeche_gidx" ON "LP_Sonstiges"."LP_PlanerischeVertiefungFlaeche" using gist ("position");
CREATE TRIGGER "change_to_LP_PlanerischeVertiefungFlaeche" BEFORE INSERT OR UPDATE ON "LP_Sonstiges"."LP_PlanerischeVertiefungFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_LP_PlanerischeVertiefungFlaeche" AFTER DELETE ON "LP_Sonstiges"."LP_PlanerischeVertiefungFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "LP_PlanerischeVertiefungFlaeche_Flaechenobjekt" BEFORE INSERT OR UPDATE ON "LP_Sonstiges"."LP_PlanerischeVertiefungFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."positionFollowsRHR"();

-- -----------------------------------------------------
-- Table "LP_Sonstiges"."LP_PlanerischeVertiefungLinie"
-- -----------------------------------------------------
CREATE  TABLE  "LP_Sonstiges"."LP_PlanerischeVertiefungLinie" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_LP_PlanerischeVertiefungLinie_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "LP_Sonstiges"."LP_PlanerischeVertiefung" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("LP_Basisobjekte"."LP_Linienobjekt");

GRANT SELECT ON TABLE "LP_Sonstiges"."LP_PlanerischeVertiefungLinie" TO xp_gast;
GRANT ALL ON TABLE "LP_Sonstiges"."LP_PlanerischeVertiefungLinie" TO lp_user;
CREATE INDEX "LP_PlanerischeVertiefungLinie_gidx" ON "LP_Sonstiges"."LP_PlanerischeVertiefungLinie" using gist ("position");
CREATE TRIGGER "change_to_LP_PlanerischeVertiefungLinie" BEFORE INSERT OR UPDATE ON "LP_Sonstiges"."LP_PlanerischeVertiefungLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_LP_PlanerischeVertiefungLinie" AFTER DELETE ON "LP_Sonstiges"."LP_PlanerischeVertiefungLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "LP_Sonstiges"."LP_PlanerischeVertiefungPunkt"
-- -----------------------------------------------------
CREATE  TABLE  "LP_Sonstiges"."LP_PlanerischeVertiefungPunkt" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_LP_PlanerischeVertiefungPunkt_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "LP_Sonstiges"."LP_PlanerischeVertiefung" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("LP_Basisobjekte"."LP_Punktobjekt");

GRANT SELECT ON TABLE "LP_Sonstiges"."LP_PlanerischeVertiefungPunkt" TO xp_gast;
GRANT ALL ON TABLE "LP_Sonstiges"."LP_PlanerischeVertiefungPunkt" TO lp_user;
CREATE INDEX "LP_PlanerischeVertiefungPunkt_gidx" ON "LP_Sonstiges"."LP_PlanerischeVertiefungPunkt" using gist ("position");
CREATE TRIGGER "change_to_LP_PlanerischeVertiefungPunkt" BEFORE INSERT OR UPDATE ON "LP_Sonstiges"."LP_PlanerischeVertiefungPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_LP_PlanerischeVertiefungPunkt" AFTER DELETE ON "LP_Sonstiges"."LP_PlanerischeVertiefungPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "LP_Sonstiges"."LP_TextlicheFestsetzungsFlaeche"
-- -----------------------------------------------------
CREATE  TABLE  "LP_Sonstiges"."LP_TextlicheFestsetzungsFlaeche" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_LP_TextlicheFestsetzungsFlaeche_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "LP_Basisobjekte"."LP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("LP_Basisobjekte"."LP_Flaechenobjekt");

GRANT SELECT ON TABLE "LP_Sonstiges"."LP_TextlicheFestsetzungsFlaeche" TO xp_gast;
GRANT ALL ON TABLE "LP_Sonstiges"."LP_TextlicheFestsetzungsFlaeche" TO lp_user;
COMMENT ON TABLE "LP_Sonstiges"."LP_TextlicheFestsetzungsFlaeche" IS 'Bereich in dem bestimmte textliche Festsetzungen gültig sind, die über die Relation "refTextInhalt" (Basisklasse LP_Objekt) spezifiziert werden.';
CREATE INDEX "LP_TextlicheFestsetzungsFlaeche_gidx" ON "LP_Sonstiges"."LP_TextlicheFestsetzungsFlaeche" using gist ("position");
CREATE TRIGGER "change_to_LP_TextlicheFestsetzungsFlaeche" BEFORE INSERT OR UPDATE ON "LP_Sonstiges"."LP_TextlicheFestsetzungsFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_LP_TextlicheFestsetzungsFlaeche" AFTER DELETE ON "LP_Sonstiges"."LP_TextlicheFestsetzungsFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "LP_TextlicheFestsetzungsFlaeche_Flaechenobjekt" BEFORE INSERT OR UPDATE ON "LP_Sonstiges"."LP_TextlicheFestsetzungsFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."positionFollowsRHR"();

-- -----------------------------------------------------
-- Table "LP_Sonstiges"."LP_ZuBegruenendeGrundstueckflaeche"
-- -----------------------------------------------------
CREATE  TABLE  "LP_Sonstiges"."LP_ZuBegruenendeGrundstueckflaeche" (
  "gid" BIGINT NOT NULL ,
  "gruenflaechenFaktor" NUMERIC(6,2),
  "gaertnerischanzulegen" BOOLEAN,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_LP_ZuBegruenendeGrundstueckflaeche_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "LP_Basisobjekte"."LP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("LP_Basisobjekte"."LP_Flaechenobjekt");

GRANT SELECT ON TABLE "LP_Sonstiges"."LP_ZuBegruenendeGrundstueckflaeche" TO xp_gast;
GRANT ALL ON TABLE "LP_Sonstiges"."LP_ZuBegruenendeGrundstueckflaeche" TO lp_user;
COMMENT ON TABLE  "LP_Sonstiges"."LP_ZuBegruenendeGrundstueckflaeche" IS 'Zu begrünende Grundstücksfläche';
COMMENT ON COLUMN  "LP_Sonstiges"."LP_ZuBegruenendeGrundstueckflaeche"."gruenflaechenFaktor" IS 'Angabe des Verhältnisses zwischen einem Flächenanteil Grün und einer bebauten Fläche (auch als Biotopflächenfaktor bekannt)';
COMMENT ON COLUMN  "LP_Sonstiges"."LP_ZuBegruenendeGrundstueckflaeche"."gaertnerischanzulegen" IS 'Angabe in wie weit ein Grünfläche gärtnerish anzulegen ist.';
CREATE INDEX "LP_ZuBegruenendeGrundstueckflaeche_gidx" ON "LP_Sonstiges"."LP_ZuBegruenendeGrundstueckflaeche" using gist ("position");
CREATE TRIGGER "change_to_LP_ZuBegruenendeGrundstueckflaeche" BEFORE INSERT OR UPDATE ON "LP_Sonstiges"."LP_ZuBegruenendeGrundstueckflaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_LP_ZuBegruenendeGrundstueckflaeche" AFTER DELETE ON "LP_Sonstiges"."LP_ZuBegruenendeGrundstueckflaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "LP_ZuBegruenendeGrundstueckflaeche_Flaechenobjekt" BEFORE INSERT OR UPDATE ON "LP_Sonstiges"."LP_ZuBegruenendeGrundstueckflaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."positionFollowsRHR"();

-- *****************************************************
-- CREATE VIEWs
-- *****************************************************

-- -----------------------------------------------------
-- View "LP_Basisobjekte"."LP_Punktobjekte"
-- -----------------------------------------------------
CREATE  OR REPLACE VIEW "LP_Basisobjekte"."LP_Punktobjekte" AS
SELECT g.*, CAST(c.relname as varchar) as "Objektart",
CAST(n.nspname as varchar) as "Objektartengruppe"
FROM  "LP_Basisobjekte"."LP_Punktobjekt" g
JOIN pg_class c ON g.tableoid = c.oid
JOIN pg_namespace n ON c.relnamespace = n.oid;

GRANT SELECT ON TABLE "LP_Basisobjekte"."LP_Punktobjekte" TO xp_gast;
GRANT ALL ON TABLE "LP_Basisobjekte"."LP_Punktobjekte" TO lp_user;

CREATE OR REPLACE RULE _update AS
    ON UPDATE TO "LP_Basisobjekte"."LP_Punktobjekte" DO INSTEAD  UPDATE "LP_Basisobjekte"."LP_Punktobjekt" SET "position" = new."position"
  WHERE gid = old.gid;
CREATE OR REPLACE RULE _delete AS
    ON DELETE TO "LP_Basisobjekte"."LP_Punktobjekte" DO INSTEAD  DELETE FROM "LP_Basisobjekte"."LP_Punktobjekt"
  WHERE gid = old.gid;

-- -----------------------------------------------------
-- View "LP_Basisobjekte"."LP_Linienobjekte"
-- -----------------------------------------------------
CREATE  OR REPLACE VIEW "LP_Basisobjekte"."LP_Linienobjekte" AS
SELECT g.*, CAST(c.relname as varchar) as "Objektart",
CAST(n.nspname as varchar) as "Objektartengruppe"
FROM  "LP_Basisobjekte"."LP_Linienobjekt" g
JOIN pg_class c ON g.tableoid = c.oid
JOIN pg_namespace n ON c.relnamespace = n.oid;

GRANT SELECT ON TABLE "LP_Basisobjekte"."LP_Linienobjekte" TO xp_gast;
GRANT ALL ON TABLE "LP_Basisobjekte"."LP_Linienobjekte" TO lp_user;

CREATE OR REPLACE RULE _update AS
    ON UPDATE TO "LP_Basisobjekte"."LP_Linienobjekte" DO INSTEAD  UPDATE "LP_Basisobjekte"."LP_Linienobjekt" SET "position" = new."position"
  WHERE gid = old.gid;
CREATE OR REPLACE RULE _delete AS
    ON DELETE TO "LP_Basisobjekte"."LP_Linienobjekte" DO INSTEAD  DELETE FROM "LP_Basisobjekte"."LP_Linienobjekt"
  WHERE gid = old.gid;

-- -----------------------------------------------------
-- View "LP_Basisobjekte"."LP_Flaechenobjekte"
-- -----------------------------------------------------
CREATE  OR REPLACE VIEW "LP_Basisobjekte"."LP_Flaechenobjekte" AS
SELECT g.*, CAST(c.relname as varchar) as "Objektart",
CAST(n.nspname as varchar) as "Objektartengruppe"
FROM  "LP_Basisobjekte"."LP_Flaechenobjekt" g
JOIN pg_class c ON g.tableoid = c.oid
JOIN pg_namespace n ON c.relnamespace = n.oid;

GRANT SELECT ON TABLE "LP_Basisobjekte"."LP_Flaechenobjekte" TO xp_gast;
GRANT ALL ON TABLE "LP_Basisobjekte"."LP_Flaechenobjekte" TO lp_user;

CREATE OR REPLACE RULE _update AS
    ON UPDATE TO "LP_Basisobjekte"."LP_Flaechenobjekte" DO INSTEAD  UPDATE "LP_Basisobjekte"."LP_Flaechenobjekt" SET "position" = new."position"
  WHERE gid = old.gid;
CREATE OR REPLACE RULE _delete AS
    ON DELETE TO "LP_Basisobjekte"."LP_Flaechenobjekte" DO INSTEAD  DELETE FROM "LP_Basisobjekte"."LP_Flaechenobjekt"
  WHERE gid = old.gid;

-- -----------------------------------------------------
-- View "LP_Basisobjekte"."LP_Objekte"
-- -----------------------------------------------------
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

-- *****************************************************
-- DATA
-- *****************************************************

-- -----------------------------------------------------
-- Data for table public."XP_Modellbereich"
-- -----------------------------------------------------
INSERT INTO public."XP_Modellbereich" ("Kurz", "Modellbereich") VALUES ('LP', 'Landschaftsplan Kernmodell');

-- -----------------------------------------------------
-- Data for table "LP_Basisobjekte"."LP_PlanArt"
-- -----------------------------------------------------
INSERT INTO "LP_Basisobjekte"."LP_PlanArt" ("Code", "Bezeichner") VALUES (1000, 'Landschaftsprogramm');
INSERT INTO "LP_Basisobjekte"."LP_PlanArt" ("Code", "Bezeichner") VALUES (2000, 'Landschaftsrahmenplan');
INSERT INTO "LP_Basisobjekte"."LP_PlanArt" ("Code", "Bezeichner") VALUES (3000, 'Landschaftsplan');
INSERT INTO "LP_Basisobjekte"."LP_PlanArt" ("Code", "Bezeichner") VALUES (4000, 'Gruenordnungsplan');
INSERT INTO "LP_Basisobjekte"."LP_PlanArt" ("Code", "Bezeichner") VALUES (9999, 'Sonstiges');

-- -----------------------------------------------------
-- Data for table "LP_Basisobjekte"."LP_Rechtsstand"
-- -----------------------------------------------------
INSERT INTO "LP_Basisobjekte"."LP_Rechtsstand" ("Code", "Bezeichner") VALUES (1000, 'Aufstellungsbeschluss');
INSERT INTO "LP_Basisobjekte"."LP_Rechtsstand" ("Code", "Bezeichner") VALUES (2000, 'Entwurf');
INSERT INTO "LP_Basisobjekte"."LP_Rechtsstand" ("Code", "Bezeichner") VALUES (3000, 'Plan');
INSERT INTO "LP_Basisobjekte"."LP_Rechtsstand" ("Code", "Bezeichner") VALUES (4000, 'Wirksamkeit');
INSERT INTO "LP_Basisobjekte"."LP_Rechtsstand" ("Code", "Bezeichner") VALUES (5000, 'Untergegangen');

-- -----------------------------------------------------
-- Data for table "LP_Basisobjekte"."LP_Rechtscharakter"
-- -----------------------------------------------------
INSERT INTO "LP_Basisobjekte"."LP_Rechtscharakter" ("Code", "Bezeichner") VALUES (1000, 'Festsetzung');
INSERT INTO "LP_Basisobjekte"."LP_Rechtscharakter" ("Code", "Bezeichner") VALUES (2000, 'Geplant');
INSERT INTO "LP_Basisobjekte"."LP_Rechtscharakter" ("Code", "Bezeichner") VALUES (3000, 'NachrichtlicheUebernahme');
INSERT INTO "LP_Basisobjekte"."LP_Rechtscharakter" ("Code", "Bezeichner") VALUES (4000, 'DarstellungKennzeichnung');
INSERT INTO "LP_Basisobjekte"."LP_Rechtscharakter" ("Code", "Bezeichner") VALUES (5000, 'FestsetzungInBPlan');
INSERT INTO "LP_Basisobjekte"."LP_Rechtscharakter" ("Code", "Bezeichner") VALUES (9998, 'Unbekannt');
INSERT INTO "LP_Basisobjekte"."LP_Rechtscharakter" ("Code", "Bezeichner") VALUES (9999, 'SonstigerStatus');

-- -----------------------------------------------------
-- Data for table "LP_Erholung"."LP_ErholungFreizeitFunktionen"
-- -----------------------------------------------------
INSERT INTO "LP_Erholung"."LP_ErholungFreizeitFunktionen" ("Code", "Bezeichner") VALUES (1000, 'Parkanlage');
INSERT INTO "LP_Erholung"."LP_ErholungFreizeitFunktionen" ("Code", "Bezeichner") VALUES (1030, 'Dauerkleingaerten');
INSERT INTO "LP_Erholung"."LP_ErholungFreizeitFunktionen" ("Code", "Bezeichner") VALUES (1050, 'Sportplatz');
INSERT INTO "LP_Erholung"."LP_ErholungFreizeitFunktionen" ("Code", "Bezeichner") VALUES (1100, 'Spielplatz');
INSERT INTO "LP_Erholung"."LP_ErholungFreizeitFunktionen" ("Code", "Bezeichner") VALUES (1200, 'Zeltplatz');
INSERT INTO "LP_Erholung"."LP_ErholungFreizeitFunktionen" ("Code", "Bezeichner") VALUES (1300, 'BadeplatzFreibad');
INSERT INTO "LP_Erholung"."LP_ErholungFreizeitFunktionen" ("Code", "Bezeichner") VALUES (1400, 'Schutzhuette');
INSERT INTO "LP_Erholung"."LP_ErholungFreizeitFunktionen" ("Code", "Bezeichner") VALUES (1500, 'Rastplatz');
INSERT INTO "LP_Erholung"."LP_ErholungFreizeitFunktionen" ("Code", "Bezeichner") VALUES (1600, 'Informationstafel');
INSERT INTO "LP_Erholung"."LP_ErholungFreizeitFunktionen" ("Code", "Bezeichner") VALUES (1700, 'FeuerstelleGrillplatz');
INSERT INTO "LP_Erholung"."LP_ErholungFreizeitFunktionen" ("Code", "Bezeichner") VALUES (1800, 'Liegewiese');
INSERT INTO "LP_Erholung"."LP_ErholungFreizeitFunktionen" ("Code", "Bezeichner") VALUES (1900, 'Aussichtsturm');
INSERT INTO "LP_Erholung"."LP_ErholungFreizeitFunktionen" ("Code", "Bezeichner") VALUES (2000, 'Aussichtspunkt');
INSERT INTO "LP_Erholung"."LP_ErholungFreizeitFunktionen" ("Code", "Bezeichner") VALUES (2100, 'Angelteich');
INSERT INTO "LP_Erholung"."LP_ErholungFreizeitFunktionen" ("Code", "Bezeichner") VALUES (2200, 'Modellflugplatz');
INSERT INTO "LP_Erholung"."LP_ErholungFreizeitFunktionen" ("Code", "Bezeichner") VALUES (2300, 'WildgehegeSchaugatter');
INSERT INTO "LP_Erholung"."LP_ErholungFreizeitFunktionen" ("Code", "Bezeichner") VALUES (2400, 'JugendzeltplatzEinzelcamp');
INSERT INTO "LP_Erholung"."LP_ErholungFreizeitFunktionen" ("Code", "Bezeichner") VALUES (2500, 'Gleitschirmplatz');
INSERT INTO "LP_Erholung"."LP_ErholungFreizeitFunktionen" ("Code", "Bezeichner") VALUES (2600, 'Wandern');
INSERT INTO "LP_Erholung"."LP_ErholungFreizeitFunktionen" ("Code", "Bezeichner") VALUES (2700, 'Wanderweg');
INSERT INTO "LP_Erholung"."LP_ErholungFreizeitFunktionen" ("Code", "Bezeichner") VALUES (2800, 'Lehrpfad');
INSERT INTO "LP_Erholung"."LP_ErholungFreizeitFunktionen" ("Code", "Bezeichner") VALUES (2900, 'Reitweg');
INSERT INTO "LP_Erholung"."LP_ErholungFreizeitFunktionen" ("Code", "Bezeichner") VALUES (3000, 'Radweg');
INSERT INTO "LP_Erholung"."LP_ErholungFreizeitFunktionen" ("Code", "Bezeichner") VALUES (3100, 'Wintersport');
INSERT INTO "LP_Erholung"."LP_ErholungFreizeitFunktionen" ("Code", "Bezeichner") VALUES (3200, 'Skiabfahrt');
INSERT INTO "LP_Erholung"."LP_ErholungFreizeitFunktionen" ("Code", "Bezeichner") VALUES (3300, 'Skilanglaufloipe');
INSERT INTO "LP_Erholung"."LP_ErholungFreizeitFunktionen" ("Code", "Bezeichner") VALUES (3400, 'RodelbahnBobbahn');
INSERT INTO "LP_Erholung"."LP_ErholungFreizeitFunktionen" ("Code", "Bezeichner") VALUES (3500, 'Wassersport');
INSERT INTO "LP_Erholung"."LP_ErholungFreizeitFunktionen" ("Code", "Bezeichner") VALUES (3600, 'Wasserwanderweg');
INSERT INTO "LP_Erholung"."LP_ErholungFreizeitFunktionen" ("Code", "Bezeichner") VALUES (3700, 'Schifffahrtsroute');
INSERT INTO "LP_Erholung"."LP_ErholungFreizeitFunktionen" ("Code", "Bezeichner") VALUES (3800, 'AnlegestelleMitMotorbooten');
INSERT INTO "LP_Erholung"."LP_ErholungFreizeitFunktionen" ("Code", "Bezeichner") VALUES (3900, 'AnlegestelleOhneMotorboote');
INSERT INTO "LP_Erholung"."LP_ErholungFreizeitFunktionen" ("Code", "Bezeichner") VALUES (4000, 'SesselliftSchlepplift');
INSERT INTO "LP_Erholung"."LP_ErholungFreizeitFunktionen" ("Code", "Bezeichner") VALUES (4100, 'Kabinenseilbahn');
INSERT INTO "LP_Erholung"."LP_ErholungFreizeitFunktionen" ("Code", "Bezeichner") VALUES (5000, 'Parkplatz');
INSERT INTO "LP_Erholung"."LP_ErholungFreizeitFunktionen" ("Code", "Bezeichner") VALUES (9999, 'Sonstiges');

-- -----------------------------------------------------
-- Data for table "LP_MassnahmenNaturschutz"."LP_Regelungen"
-- -----------------------------------------------------
INSERT INTO "LP_MassnahmenNaturschutz"."LP_Regelungen" ("Code", "Bezeichner") VALUES (1000, 'Gruenlandumbruchverbot');
INSERT INTO "LP_MassnahmenNaturschutz"."LP_Regelungen" ("Code", "Bezeichner") VALUES (9999, 'Sonstiges');

-- -----------------------------------------------------
-- Data for table "LP_SchutzgebieteObjekte"."LP_BodenschutzrechtTypen"
-- -----------------------------------------------------
INSERT INTO "LP_SchutzgebieteObjekte"."LP_BodenschutzrechtTypen" ("Code", "Bezeichner") VALUES (1000, 'Altlastenflaeche');
INSERT INTO "LP_SchutzgebieteObjekte"."LP_BodenschutzrechtTypen" ("Code", "Bezeichner") VALUES (9999, 'Sonstiges');

-- -----------------------------------------------------
-- Data for table "LP_SchutzgebieteObjekte"."LP_ForstrechtTypen"
-- -----------------------------------------------------
INSERT INTO "LP_SchutzgebieteObjekte"."LP_ForstrechtTypen" ("Code", "Bezeichner") VALUES (1000, 'Naturwaldreservat');
INSERT INTO "LP_SchutzgebieteObjekte"."LP_ForstrechtTypen" ("Code", "Bezeichner") VALUES (2000, 'SchutzwaldAllgemein');
INSERT INTO "LP_SchutzgebieteObjekte"."LP_ForstrechtTypen" ("Code", "Bezeichner") VALUES (2100, 'Lawinenschutzwald');
INSERT INTO "LP_SchutzgebieteObjekte"."LP_ForstrechtTypen" ("Code", "Bezeichner") VALUES (2200, 'Bodenschutzwald');
INSERT INTO "LP_SchutzgebieteObjekte"."LP_ForstrechtTypen" ("Code", "Bezeichner") VALUES (2300, 'Klimaschutzwald');
INSERT INTO "LP_SchutzgebieteObjekte"."LP_ForstrechtTypen" ("Code", "Bezeichner") VALUES (2400, 'Immissionsschutzwald');
INSERT INTO "LP_SchutzgebieteObjekte"."LP_ForstrechtTypen" ("Code", "Bezeichner") VALUES (2500, 'Biotopschutzwald');
INSERT INTO "LP_SchutzgebieteObjekte"."LP_ForstrechtTypen" ("Code", "Bezeichner") VALUES (3000, 'ErholungswaldAllgemein');
INSERT INTO "LP_SchutzgebieteObjekte"."LP_ForstrechtTypen" ("Code", "Bezeichner") VALUES (3100, 'ErholungswaldHeilbaeder');
INSERT INTO "LP_SchutzgebieteObjekte"."LP_ForstrechtTypen" ("Code", "Bezeichner") VALUES (3200, 'ErholungswaldBallungsraeume');
INSERT INTO "LP_SchutzgebieteObjekte"."LP_ForstrechtTypen" ("Code", "Bezeichner") VALUES (9999, 'Sonstiges');

-- -----------------------------------------------------
-- Data for table "LP_SchutzgebieteObjekte"."LP_InternatSchutzobjektTypen"
-- -----------------------------------------------------
INSERT INTO "LP_SchutzgebieteObjekte"."LP_InternatSchutzobjektTypen" ("Code", "Bezeichner") VALUES (1000, 'Feuchtgebiet');
INSERT INTO "LP_SchutzgebieteObjekte"."LP_InternatSchutzobjektTypen" ("Code", "Bezeichner") VALUES (2000, 'VogelschutzgebietInternat');
INSERT INTO "LP_SchutzgebieteObjekte"."LP_InternatSchutzobjektTypen" ("Code", "Bezeichner") VALUES (9999, 'Sonstiges');

-- -----------------------------------------------------
-- Data for table "LP_SchutzgebieteObjekte"."LP_SonstRechtTypen"
-- -----------------------------------------------------
INSERT INTO "LP_SchutzgebieteObjekte"."LP_SonstRechtTypen" ("Code", "Bezeichner") VALUES (1000, 'Jagdgesetz');
INSERT INTO "LP_SchutzgebieteObjekte"."LP_SonstRechtTypen" ("Code", "Bezeichner") VALUES (2000, 'Fischereigesetz');
INSERT INTO "LP_SchutzgebieteObjekte"."LP_SonstRechtTypen" ("Code", "Bezeichner") VALUES (9999, 'Sonstiges');

-- -----------------------------------------------------
-- Data for table "LP_SchutzgebieteObjekte"."LP_WasserrechtSchutzgebietTypen"
-- -----------------------------------------------------
INSERT INTO "LP_SchutzgebieteObjekte"."LP_WasserrechtSchutzgebietTypen" ("Code", "Bezeichner") VALUES (1000, 'GrundQuellwasser');
INSERT INTO "LP_SchutzgebieteObjekte"."LP_WasserrechtSchutzgebietTypen" ("Code", "Bezeichner") VALUES (2000, 'Oberflaechengewaesser');
INSERT INTO "LP_SchutzgebieteObjekte"."LP_WasserrechtSchutzgebietTypen" ("Code", "Bezeichner") VALUES (3000, 'Heilquellen');
INSERT INTO "LP_SchutzgebieteObjekte"."LP_WasserrechtSchutzgebietTypen" ("Code", "Bezeichner") VALUES (9999, 'Sonstiges');

-- -----------------------------------------------------
-- Data for table "LP_SchutzgebieteObjekte"."LP_WasserrechtWirtschaftAbflussHochwSchutzTypen"
-- -----------------------------------------------------
INSERT INTO "LP_SchutzgebieteObjekte"."LP_WasserrechtWirtschaftAbflussHochwSchutzTypen" ("Code", "Bezeichner") VALUES (1000, 'Hochwasserrueckhaltebecken');
INSERT INTO "LP_SchutzgebieteObjekte"."LP_WasserrechtWirtschaftAbflussHochwSchutzTypen" ("Code", "Bezeichner") VALUES (2000, 'UeberschwemmGebiet');
INSERT INTO "LP_SchutzgebieteObjekte"."LP_WasserrechtWirtschaftAbflussHochwSchutzTypen" ("Code", "Bezeichner") VALUES (9999, 'Sonstiges');
