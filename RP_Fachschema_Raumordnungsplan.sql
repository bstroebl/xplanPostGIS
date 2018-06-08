-- -----------------------------------------------------
-- Objektbereich: RP_ Fachschema Raumordnungsplan
--
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
-- CREATE GROUP ROLES
-- *****************************************************

-- editierende Rolle für RP_Fachschema_FPlan
CREATE ROLE rp_user
  NOSUPERUSER INHERIT NOCREATEDB NOCREATEROLE;
GRANT xp_user TO rp_user;

-- *****************************************************
-- CREATE SCHEMAS
-- *****************************************************

CREATE SCHEMA "RP_Basisobjekte";
CREATE SCHEMA "RP_KernmodellFreiraumstruktur";
CREATE SCHEMA "RP_KernmodellInfrastruktur";
CREATE SCHEMA "RP_KernmodellSiedlungsstruktur";
CREATE SCHEMA "RP_KernmodellSonstiges";

COMMENT ON SCHEMA "RP_Basisobjekte" IS 'Dies Paket enthält die Basisobjekte des Raumordnungsplanschemas.';
COMMENT ON SCHEMA "RP_KernmodellFreiraumstruktur" IS 'Festlegungen im Bereich Freiraumstruktur.';
COMMENT ON SCHEMA "RP_KernmodellInfrastruktur" IS 'Festlegungen im Bereich Infrastruktur.';
COMMENT ON SCHEMA "RP_KernmodellSiedlungsstruktur" IS 'Festlegungen im Bereich Siedlungsstruktur.';
COMMENT ON SCHEMA "RP_KernmodellSonstiges" IS 'Sonstige Festlegungen.';

GRANT USAGE ON SCHEMA "RP_Basisobjekte" TO xp_gast;
GRANT USAGE ON SCHEMA "RP_KernmodellFreiraumstruktur" TO xp_gast;
GRANT USAGE ON SCHEMA "RP_KernmodellInfrastruktur" TO xp_gast;
GRANT USAGE ON SCHEMA "RP_KernmodellSiedlungsstruktur" TO xp_gast;
GRANT USAGE ON SCHEMA "RP_KernmodellSonstiges" TO xp_gast;

-- *****************************************************
-- CREATE TRIGGER FUNCTIONs
-- *****************************************************

CREATE OR REPLACE FUNCTION "RP_Basisobjekte"."new_RP_Bereich"()
RETURNS trigger AS
$BODY$
 DECLARE
    fp_plan_gid integer;
 BEGIN
    SELECT max(gid) from "RP_Basisobjekte"."RP_Plan" INTO fp_plan_gid;

    IF fp_plan_gid IS NULL THEN
        RETURN NULL;
    ELSE
        new."gehoertZuPlan" := fp_plan_gid;
        RETURN new;
    END IF;
 END; $BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
GRANT EXECUTE ON FUNCTION "RP_Basisobjekte"."new_RP_Bereich"() TO fp_user;


-- *****************************************************
-- CREATE TABLEs
-- *****************************************************

-- -----------------------------------------------------
-- Table "RP_Basisobjekte"."RP_PlanArt"
-- -----------------------------------------------------
CREATE  TABLE  "RP_Basisobjekte"."RP_PlanArt" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Code") );
GRANT SELECT ON TABLE "RP_Basisobjekte"."RP_PlanArt" TO xp_gast;

-- -----------------------------------------------------
-- Table "RP_Basisobjekte"."RP_SonstPlanArt"
-- -----------------------------------------------------
CREATE  TABLE  "RP_Basisobjekte"."RP_SonstPlanArt" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Code") );
GRANT SELECT ON TABLE "RP_Basisobjekte"."RP_SonstPlanArt" TO xp_gast;
GRANT ALL ON TABLE "RP_Basisobjekte"."RP_SonstPlanArt" TO lp_user;

-- -----------------------------------------------------
-- Table "RP_Basisobjekte"."RP_Status"
-- -----------------------------------------------------
CREATE  TABLE  "RP_Basisobjekte"."RP_Status" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Code") );
GRANT SELECT ON TABLE "RP_Basisobjekte"."RP_Status" TO xp_gast;
GRANT ALL ON TABLE "RP_Basisobjekte"."RP_Status" TO fp_user;

-- -----------------------------------------------------
-- Table "RP_Basisobjekte"."RP_Rechtsstand"
-- -----------------------------------------------------
CREATE  TABLE  "RP_Basisobjekte"."RP_Rechtsstand" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Code") );
GRANT SELECT ON TABLE "RP_Basisobjekte"."RP_Rechtsstand" TO xp_gast;

-- -----------------------------------------------------
-- Table "RP_Basisobjekte"."RP_Plan"
-- -----------------------------------------------------
CREATE  TABLE  "RP_Basisobjekte"."RP_Plan" (
  "gid" BIGINT NOT NULL ,
  "name" VARCHAR (256) NOT NULL,
  "planArt" INTEGER NOT NULL DEFAULT 1000,
  "sonstPlanArt" INTEGER NULL ,
  "planungsregion" INTEGER NULL ,
  "teilabschnitt" INTEGER NULL ,
  "rechtsstand" INTEGER NULL ,
  "status" INTEGER NULL ,
  "aufstellungsbechlussDatum" DATE NULL ,
  "auslegungsStartDatum" DATE[],
  "auslegungsEndDatum" DATE[],
  "traegerbeteiligungsStartDatum" DATE[],
  "traegerbeteiligungsEndDatum" DATE[],
  "aenderungenBisDatum" DATE NULL ,
  "entwurfsbeschlussDatum" DATE NULL ,
  "planbeschlussDatum" DATE NULL ,
  "datumDesInkrafttretens" DATE NULL ,
  "refUmweltbericht" INTEGER NULL ,
  "refSatzung" INTEGER NULL ,
  PRIMARY KEY ("gid"),
  CONSTRAINT "fk_rp_plan_rp_planart1"
    FOREIGN KEY ("planArt" )
    REFERENCES "RP_Basisobjekte"."RP_PlanArt" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_rp_plan_rp_sonstplanart1"
    FOREIGN KEY ("sonstPlanArt" )
    REFERENCES "RP_Basisobjekte"."RP_SonstPlanArt" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_rp_plan_rp_status1"
    FOREIGN KEY ("status" )
    REFERENCES "RP_Basisobjekte"."RP_Status" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_rp_plan_xp_externereferenz1"
    FOREIGN KEY ("refUmweltbericht" )
    REFERENCES "XP_Basisobjekte"."XP_ExterneReferenz" ("id" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_rp_plan_xp_externereferenz2"
    FOREIGN KEY ("refSatzung" )
    REFERENCES "XP_Basisobjekte"."XP_ExterneReferenz" ("id" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_rp_plan_rp_rechtsstand1"
    FOREIGN KEY ("rechtsstand" )
    REFERENCES "RP_Basisobjekte"."RP_Rechtsstand" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE)
INHERITS("XP_Basisobjekte"."XP_RaeumlicherGeltungsbereich");

CREATE INDEX "idx_fk_fp_plan_fp_tplanart1" ON "RP_Basisobjekte"."RP_Plan" ("planArt") ;
CREATE INDEX "idx_fk_fp_plan_fp_sonstplanart1" ON "RP_Basisobjekte"."RP_Plan" ("sonstPlanArt") ;
CREATE INDEX "idx_fk_fp_plan_fp_rechtsstand1" ON "RP_Basisobjekte"."RP_Plan" ("rechtsstand") ;
CREATE INDEX "idx_fk_fp_plan_fp_status1" ON "RP_Basisobjekte"."RP_Plan" ("status") ;
CREATE INDEX "RP_Plan_gidx" ON "RP_Basisobjekte"."RP_Plan" using gist ("raeumlicherGeltungsbereich");
GRANT SELECT ON TABLE "RP_Basisobjekte"."RP_Plan" TO xp_gast;
GRANT ALL ON TABLE "RP_Basisobjekte"."RP_Plan" TO rp_user;
COMMENT ON TABLE "RP_Basisobjekte"."RP_Plan" IS 'Die Klasse RP_Plan modelliert einen Raumordnungsplan.';
COMMENT ON COLUMN "RP_Basisobjekte"."RP_Plan"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN "RP_Basisobjekte"."RP_Plan"."name" IS 'Name des Plans. Der Name kann hier oder in XP_Plan geändert werden.';
COMMENT ON COLUMN "RP_Basisobjekte"."RP_Plan"."planArt" IS 'Art des Raumordnungsplans.';
COMMENT ON COLUMN "RP_Basisobjekte"."RP_Plan"."sonstPlanArt" IS 'Spezifikation einer weiteren Planart (CodeList) bei planArt == 9999 (Sonstiges).';
COMMENT ON COLUMN "RP_Basisobjekte"."RP_Plan"."planungsregion" IS 'Kennziffer der Planungsregion.';
COMMENT ON COLUMN "RP_Basisobjekte"."RP_Plan"."teilabschnitt" IS 'Kennziffer des Teilabschnittes.';
COMMENT ON COLUMN "RP_Basisobjekte"."RP_Plan"."rechtsstand" IS 'Rechtsstand des Plans';
COMMENT ON COLUMN "RP_Basisobjekte"."RP_Plan"."status" IS 'Status des Plans, definiert über eine CodeList.';
COMMENT ON COLUMN "RP_Basisobjekte"."RP_Plan"."aufstellungsbechlussDatum" IS 'Datum des Plan-Aufstellungsbeschlusses.';
COMMENT ON COLUMN "RP_Basisobjekte"."RP_Plan"."auslegungsStartDatum" IS 'Start-Datum der öffentlichen Auslegung. Bei mehrfacher öffentlicher Auslegung können mehrere Datumsangaben spezifiziert werden.';
COMMENT ON COLUMN "RP_Basisobjekte"."RP_Plan"."auslegungsEndDatum" IS 'End-Datum der öffentlichen Auslegung. Bei mehrfacher öffentlicher Auslegung können mehrere Datumsangaben spezifiziert werden.';
COMMENT ON COLUMN "RP_Basisobjekte"."RP_Plan"."traegerbeteiligungsStartDatum" IS 'Start-Datum der Trägerbeteiligung. Bei mehrfacher Trägerbeteiligung können mehrere Datumsangaben spezifiziert werden.';
COMMENT ON COLUMN "RP_Basisobjekte"."RP_Plan"."traegerbeteiligungsEndDatum" IS 'End-Datum der Trägerbeteiligung. Bei mehrfacher Trägerbeteiligung können mehrere Datumsangaben spezifiziert werden.';
COMMENT ON COLUMN "RP_Basisobjekte"."RP_Plan"."aenderungenBisDatum" IS 'Datum, bis zu dem Änderungen des Plans berücksichtigt wurden.';
COMMENT ON COLUMN "RP_Basisobjekte"."RP_Plan"."entwurfsbeschlussDatum" IS 'Datum des Entwurfsbeschlusses';
COMMENT ON COLUMN "RP_Basisobjekte"."RP_Plan"."planbeschlussDatum" IS 'Datum des Planbeschlusses';
COMMENT ON COLUMN "RP_Basisobjekte"."RP_Plan"."datumDesInkrafttretens" IS 'Datum des Inkrafttretens des Plans.';
COMMENT ON COLUMN "RP_Basisobjekte"."RP_Plan"."refUmweltbericht" IS 'Referenz auf den Umweltbericht.';
COMMENT ON COLUMN "RP_Basisobjekte"."RP_Plan"."refSatzung" IS 'Referenz auf die Satzung ';
CREATE TRIGGER "change_to_RP_Plan" BEFORE INSERT OR UPDATE ON "RP_Basisobjekte"."RP_Plan" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Plan"();
CREATE TRIGGER "delete_RP_Plan" AFTER DELETE ON "RP_Basisobjekte"."RP_Plan" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Plan"();
CREATE TRIGGER "RP_Plan_propagate_name" AFTER UPDATE ON "RP_Basisobjekte"."RP_Plan" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."propagate_name_to_parent"();

-- -----------------------------------------------------
-- Table "RP_Basisobjekte"."RP_Plan_bundesland"
-- -----------------------------------------------------
CREATE TABLE "RP_Basisobjekte"."RP_Plan_bundesland" (
    "RP_Plan_gid" BIGINT NOT NULL,
    "bundesland" INTEGER NULL ,
  PRIMARY KEY ("RP_Plan_gid", "bundesland"),
  CONSTRAINT "fk_RP_Plan_bundesland1"
    FOREIGN KEY ("RP_Plan_gid" )
    REFERENCES "RP_Basisobjekte"."RP_Plan" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_RP_Plan_bundesland2"
    FOREIGN KEY ("bundesland" )
    REFERENCES "XP_Enumerationen"."XP_Bundeslaender" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
GRANT SELECT ON TABLE "RP_Basisobjekte"."RP_Plan_bundesland" TO xp_gast;
GRANT ALL ON TABLE "RP_Basisobjekte"."RP_Plan_bundesland" TO rp_user;
COMMENT ON TABLE  "RP_Basisobjekte"."RP_Plan_bundesland" IS 'Zuständige Bundesländer';

-- -----------------------------------------------------
-- Table "RP_Basisobjekte"."RP_Bereich"
-- -----------------------------------------------------
CREATE  TABLE  "RP_Basisobjekte"."RP_Bereich" (
  "gid" BIGINT NOT NULL ,
  "name" VARCHAR (256) NOT NULL,
  "versionBROG" DATE NULL ,
  "versionBROGText" VARCHAR(255) NULL ,
  "versionLPLG" DATE NULL ,
  "versionLPLGText" VARCHAR(255) NULL ,
  "gehoertZuPlan" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_RP_Bereich_RP_Plan1"
    FOREIGN KEY ("gehoertZuPlan" )
    REFERENCES "RP_Basisobjekte"."RP_Plan" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_RP_Bereich_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "XP_Basisobjekte"."XP_Bereich" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("XP_Basisobjekte"."XP_Geltungsbereich");

CREATE INDEX "idx_fk_RP_Bereich_RP_Plan1" ON "RP_Basisobjekte"."RP_Bereich" ("gehoertZuPlan") ;
CREATE INDEX "RP_Bereich_gidx" ON "RP_Basisobjekte"."RP_Bereich" using gist ("geltungsbereich");
GRANT SELECT ON TABLE "RP_Basisobjekte"."RP_Bereich" TO xp_gast;
GRANT ALL ON TABLE "RP_Basisobjekte"."RP_Bereich" TO rp_user;
COMMENT ON TABLE "RP_Basisobjekte"."RP_Bereich" IS 'Die Klasse RP_Bereich modelliert einen Bereich eines Raumordnungsplans. Bereiche strukturieren Pläne räumlich und inhaltlich.';
COMMENT ON COLUMN "RP_Basisobjekte"."RP_Bereich"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN "RP_Basisobjekte"."RP_Bereich"."name" IS 'Bezeichnung des Bereiches. Die Bezeichnung kann hier oder in XP_Bereich geändert werden.';
COMMENT ON COLUMN "RP_Basisobjekte"."RP_Bereich"."versionBROG" IS 'Datum der zugrunde liegenden Version des ROG.';
COMMENT ON COLUMN "RP_Basisobjekte"."RP_Bereich"."versionBROGText" IS 'Titel der zugrunde liegenden Version des Bundesraumordnungsgesetzes.';
COMMENT ON COLUMN "RP_Basisobjekte"."RP_Bereich"."versionLPLG" IS 'Datum des zugrunde liegenden Landesplanungsgesetzes.';
COMMENT ON COLUMN "RP_Basisobjekte"."RP_Bereich"."versionLPLGText" IS 'Titel des zugrunde liegenden Landesplanungsgesetzes.';
COMMENT ON COLUMN "RP_Basisobjekte"."RP_Bereich"."gehoertZuPlan" IS '';
CREATE TRIGGER "change_to_RP_Bereich" BEFORE INSERT OR UPDATE ON "RP_Basisobjekte"."RP_Bereich" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Bereich"();
CREATE TRIGGER "delete_RP_Bereich" AFTER DELETE ON "RP_Basisobjekte"."RP_Bereich" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Bereich"();
CREATE TRIGGER "insert_into_RP_Bereich" BEFORE INSERT ON "RP_Basisobjekte"."RP_Bereich" FOR EACH ROW EXECUTE PROCEDURE "RP_Basisobjekte"."new_RP_Bereich"();
CREATE TRIGGER "RP_Bereich_propagate_name" AFTER UPDATE ON "RP_Basisobjekte"."RP_Bereich" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."propagate_name_to_parent"();

-- -----------------------------------------------------
-- Table "RP_Basisobjekte"."RP_Rechtscharakter"
-- -----------------------------------------------------
CREATE  TABLE  "RP_Basisobjekte"."RP_Rechtscharakter" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Code") );
GRANT SELECT ON TABLE "RP_Basisobjekte"."RP_Rechtscharakter" TO xp_gast;

-- -----------------------------------------------------
-- Table "RP_Basisobjekte"."RP_TextAbschnitt"
-- -----------------------------------------------------
CREATE TABLE "RP_Basisobjekte"."RP_TextAbschnitt" (
  "id" BIGINT NOT NULL ,
  "rechtscharakter" INTEGER NOT NULL DEFAULT 9998,
  PRIMARY KEY ("id") ,
  CONSTRAINT "fk_RP_TextAbschnitt_rechtscharakter"
    FOREIGN KEY ("rechtscharakter" )
    REFERENCES "RP_Basisobjekte"."RP_Rechtscharakter" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_RP_TextAbschnitt_parent"
    FOREIGN KEY ("id" )
    REFERENCES "XP_Basisobjekte"."XP_TextAbschnitt" ("id" )
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
-- Table "RP_Basisobjekte"."RP_Objekt"
-- -----------------------------------------------------
CREATE  TABLE  "RP_Basisobjekte"."RP_Objekt" (
  "gid" BIGINT NOT NULL ,
  "rechtscharakter" INTEGER NOT NULL DEFAULT 9998,
  "konkretisierung" VARCHAR(64) NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_rp_objekt_rp_rechtscharakter1"
    FOREIGN KEY ("rechtscharakter" )
    REFERENCES "RP_Basisobjekte"."RP_Rechtscharakter" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_RP_Objekt_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "XP_Basisobjekte"."XP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE);

CREATE INDEX "idx_fk_fp_objekt_fp_rechtscharakter1" ON "RP_Basisobjekte"."RP_Objekt" ("rechtscharakter") ;
GRANT SELECT ON TABLE "RP_Basisobjekte"."RP_Objekt" TO xp_gast;
GRANT ALL ON TABLE "RP_Basisobjekte"."RP_Objekt" TO rp_user;
COMMENT ON TABLE "RP_Basisobjekte"."RP_Objekt" IS 'RP_Objekt ist die Basisklasse für alle spezifischen Festlegungen eines Raumordnungsplans. Sie selbst ist abstrakt, d.h. sie wird selbst nicht als eigenes Objekt verwendet, sondern vererbt nur ihre Attribute an spezielle Klassen.';
COMMENT ON COLUMN "RP_Basisobjekte"."RP_Objekt"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN "RP_Basisobjekte"."RP_Objekt"."rechtscharakter" IS 'Rechtscharakter des Planinhalts.';
COMMENT ON COLUMN "RP_Basisobjekte"."RP_Objekt"."konkretisierung" IS 'Konkretisierung des Rechtscharakters.';
CREATE TRIGGER "change_to_RP_Objekt" BEFORE INSERT OR UPDATE ON "RP_Basisobjekte"."RP_Objekt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_Objekt" AFTER DELETE ON "RP_Basisobjekte"."RP_Objekt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

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
-- Table "RP_Basisobjekte"."RP_Punktobjekt"
-- -----------------------------------------------------
CREATE  TABLE  "RP_Basisobjekte"."RP_Punktobjekt" (
  "gid" BIGINT NOT NULL ,
  "position" GEOMETRY(Multipoint,25832) NOT NULL ,
  PRIMARY KEY ("gid") );
GRANT SELECT ON TABLE "RP_Basisobjekte"."RP_Punktobjekt" TO xp_gast;
GRANT ALL ON TABLE "RP_Basisobjekte"."RP_Punktobjekt" TO rp_user;
CREATE TRIGGER "RP_Punktobjekt_isAbstract" BEFORE INSERT ON "RP_Basisobjekte"."RP_Punktobjekt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isAbstract"();

-- -----------------------------------------------------
-- Table "RP_Basisobjekte"."RP_Linienobjekt"
-- -----------------------------------------------------
CREATE  TABLE  "RP_Basisobjekte"."RP_Linienobjekt" (
  "gid" BIGINT NOT NULL ,
  "position" GEOMETRY(MultiLinestring,25832) NOT NULL ,
  "flussrichtung" boolean,
  PRIMARY KEY ("gid") );
GRANT SELECT ON TABLE "RP_Basisobjekte"."RP_Linienobjekt" TO xp_gast;
GRANT ALL ON TABLE "RP_Basisobjekte"."RP_Linienobjekt" TO rp_user;
CREATE TRIGGER "RP_Linienobjekt_isAbstract" BEFORE INSERT ON "RP_Basisobjekte"."RP_Linienobjekt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isAbstract"();

-- -----------------------------------------------------
-- Table "RP_Basisobjekte"."RP_Flaechenobjekt"
-- -----------------------------------------------------
CREATE  TABLE  "RP_Basisobjekte"."RP_Flaechenobjekt" (
  "gid" BIGINT NOT NULL ,
  "position" GEOMETRY(Multipolygon,25832) NOT NULL ,
  PRIMARY KEY ("gid") );
GRANT SELECT ON TABLE "RP_Basisobjekte"."RP_Flaechenobjekt" TO xp_gast;
GRANT ALL ON TABLE "RP_Basisobjekte"."RP_Flaechenobjekt" TO rp_user;
CREATE TRIGGER "RP_Flaechenobjekt_isAbstract" BEFORE INSERT ON "RP_Basisobjekte"."RP_Flaechenobjekt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isAbstract"();

-- -----------------------------------------------------
-- Table "RP_Basisobjekte"."RP_GebietsTyp"
-- -----------------------------------------------------
CREATE  TABLE  "RP_Basisobjekte"."RP_GebietsTyp" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Code") );
GRANT SELECT ON TABLE "RP_Basisobjekte"."RP_GebietsTyp" TO xp_gast;

-- -----------------------------------------------------
-- Table "RP_KernmodellFreiraumstruktur"."RP_Bodenschutz"
-- -----------------------------------------------------
CREATE  TABLE  "RP_KernmodellFreiraumstruktur"."RP_Bodenschutz" (
  "gid" BIGINT NOT NULL ,
  "istAusgleichsgebiet" BOOLEAN NULL,
  PRIMARY KEY ("gid"),
  CONSTRAINT "fk_RP_Bodenschutz_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "RP_Basisobjekte"."RP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE);

GRANT SELECT ON TABLE "RP_KernmodellFreiraumstruktur"."RP_Bodenschutz" TO xp_gast;
GRANT ALL ON TABLE "RP_KernmodellFreiraumstruktur"."RP_Bodenschutz" TO rp_user;
COMMENT ON TABLE  "RP_KernmodellFreiraumstruktur"."RP_Bodenschutz" IS 'Bodenschutz ';
COMMENT ON COLUMN  "RP_KernmodellFreiraumstruktur"."RP_Bodenschutz"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN  "RP_KernmodellFreiraumstruktur"."RP_Bodenschutz"."istAusgleichsgebiet" IS 'Gibt an, ob es sich um ein Ausgleichsgebiet handelt.';
CREATE TRIGGER "change_to_RP_Bodenschutz" BEFORE INSERT OR UPDATE ON "RP_KernmodellFreiraumstruktur"."RP_Bodenschutz" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_Bodenschutz" AFTER DELETE ON "RP_KernmodellFreiraumstruktur"."RP_Bodenschutz" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "RP_KernmodellFreiraumstruktur"."RP_Bodenschutz_gebietsTyp"
-- -----------------------------------------------------
CREATE  TABLE  "RP_KernmodellFreiraumstruktur"."RP_Bodenschutz_gebietsTyp" (
  "RP_Bodenschutz_gid" BIGINT NOT NULL ,
  "gebietsTyp" INTEGER NOT NULL ,
  PRIMARY KEY ("RP_Bodenschutz_gid", "gebietsTyp"),
  CONSTRAINT "fk_RP_Bodenschutz_gebietsTyp1"
    FOREIGN KEY ("RP_Bodenschutz_gid" )
    REFERENCES "RP_KernmodellFreiraumstruktur"."RP_Bodenschutz" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_RP_Bodenschutz_gebietsTyp2"
    FOREIGN KEY ("gebietsTyp" )
    REFERENCES "RP_Basisobjekte"."RP_GebietsTyp" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
GRANT SELECT ON TABLE "RP_KernmodellFreiraumstruktur"."RP_Bodenschutz_gebietsTyp" TO xp_gast;
GRANT ALL ON TABLE "RP_KernmodellFreiraumstruktur"."RP_Bodenschutz_gebietsTyp" TO rp_user;
COMMENT ON TABLE  "RP_KernmodellFreiraumstruktur"."RP_Bodenschutz_gebietsTyp" IS 'Klassifikation des Gebietes nach Bundesraumordnungsgesetz.';

-- -----------------------------------------------------
-- Table "RP_KernmodellFreiraumstruktur"."RP_BodenschutzFlaeche"
-- -----------------------------------------------------
CREATE  TABLE  "RP_KernmodellFreiraumstruktur"."RP_BodenschutzFlaeche" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_RP_BodenschutzFlaeche_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "RP_KernmodellFreiraumstruktur"."RP_Bodenschutz" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("RP_Basisobjekte"."RP_Flaechenobjekt");

GRANT SELECT ON TABLE "RP_KernmodellFreiraumstruktur"."RP_BodenschutzFlaeche" TO xp_gast;
GRANT ALL ON TABLE "RP_KernmodellFreiraumstruktur"."RP_BodenschutzFlaeche" TO rp_user;
COMMENT ON COLUMN "RP_KernmodellFreiraumstruktur"."RP_BodenschutzFlaeche"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_RP_BodenschutzFlaeche" BEFORE INSERT OR UPDATE ON "RP_KernmodellFreiraumstruktur"."RP_BodenschutzFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_BodenschutzFlaeche" AFTER DELETE ON "RP_KernmodellFreiraumstruktur"."RP_BodenschutzFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "RP_BodenschutzFlaeche_Flaechenobjekt" BEFORE INSERT OR UPDATE ON "RP_KernmodellFreiraumstruktur"."RP_BodenschutzFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."positionFollowsRHR"();

-- -----------------------------------------------------
-- Table "RP_KernmodellFreiraumstruktur"."RP_BodenschutzLinie"
-- -----------------------------------------------------
CREATE  TABLE  "RP_KernmodellFreiraumstruktur"."RP_BodenschutzLinie" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_RP_BodenschutzLinie_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "RP_KernmodellFreiraumstruktur"."RP_Bodenschutz" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("RP_Basisobjekte"."RP_Linienobjekt");

GRANT SELECT ON TABLE "RP_KernmodellFreiraumstruktur"."RP_BodenschutzLinie" TO xp_gast;
GRANT ALL ON TABLE "RP_KernmodellFreiraumstruktur"."RP_BodenschutzLinie" TO rp_user;
COMMENT ON COLUMN "RP_KernmodellFreiraumstruktur"."RP_BodenschutzLinie"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_RP_BodenschutzLinie" BEFORE INSERT OR UPDATE ON "RP_KernmodellFreiraumstruktur"."RP_BodenschutzLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_BodenschutzLinie" AFTER DELETE ON "RP_KernmodellFreiraumstruktur"."RP_BodenschutzLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "RP_KernmodellFreiraumstruktur"."RP_BodenschutzPunkt"
-- -----------------------------------------------------
CREATE  TABLE  "RP_KernmodellFreiraumstruktur"."RP_BodenschutzPunkt" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_RP_BodenschutzPunkt_parent"
    FOREIGN KEY ("gid")
    REFERENCES "RP_KernmodellFreiraumstruktur"."RP_Bodenschutz" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("RP_Basisobjekte"."RP_Punktobjekt");

GRANT SELECT ON TABLE "RP_KernmodellFreiraumstruktur"."RP_BodenschutzPunkt" TO xp_gast;
GRANT ALL ON TABLE "RP_KernmodellFreiraumstruktur"."RP_BodenschutzPunkt" TO rp_user;
COMMENT ON COLUMN "RP_KernmodellFreiraumstruktur"."RP_BodenschutzPunkt"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_RP_BodenschutzPunkt" BEFORE INSERT OR UPDATE ON "RP_KernmodellFreiraumstruktur"."RP_BodenschutzPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_BodenschutzPunkt" AFTER DELETE ON "RP_KernmodellFreiraumstruktur"."RP_BodenschutzPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "RP_KernmodellFreiraumstruktur"."RP_Forstwirtschaft"
-- -----------------------------------------------------
CREATE  TABLE  "RP_KernmodellFreiraumstruktur"."RP_Forstwirtschaft" (
  "gid" BIGINT NOT NULL ,
  "istAusgleichsgebiet" BOOLEAN NULL,
  PRIMARY KEY ("gid"),
  CONSTRAINT "fk_RP_Forstwirtschaft_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "RP_Basisobjekte"."RP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE);

GRANT SELECT ON TABLE "RP_KernmodellFreiraumstruktur"."RP_Forstwirtschaft" TO xp_gast;
GRANT ALL ON TABLE "RP_KernmodellFreiraumstruktur"."RP_Forstwirtschaft" TO rp_user;
COMMENT ON TABLE  "RP_KernmodellFreiraumstruktur"."RP_Forstwirtschaft" IS 'Forstwirtschaft';
COMMENT ON COLUMN  "RP_KernmodellFreiraumstruktur"."RP_Forstwirtschaft"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN  "RP_KernmodellFreiraumstruktur"."RP_Forstwirtschaft"."istAusgleichsgebiet" IS 'Gibt an, ob es sich um ein Ausgleichsgebiet handelt.';
CREATE TRIGGER "change_to_RP_Forstwirtschaft" BEFORE INSERT OR UPDATE ON "RP_KernmodellFreiraumstruktur"."RP_Forstwirtschaft" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_Forstwirtschaft" AFTER DELETE ON "RP_KernmodellFreiraumstruktur"."RP_Forstwirtschaft" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "RP_KernmodellFreiraumstruktur"."RP_Forstwirtschaft_gebietsTyp"
-- -----------------------------------------------------
CREATE  TABLE  "RP_KernmodellFreiraumstruktur"."RP_Forstwirtschaft_gebietsTyp" (
  "RP_Forstwirtschaft_gid" BIGINT NOT NULL ,
  "gebietsTyp" INTEGER NOT NULL ,
  PRIMARY KEY ("RP_Forstwirtschaft_gid", "gebietsTyp"),
  CONSTRAINT "fk_RP_Forstwirtschaft_gebietsTyp1"
    FOREIGN KEY ("RP_Forstwirtschaft_gid" )
    REFERENCES "RP_KernmodellFreiraumstruktur"."RP_Forstwirtschaft" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_RP_Forstwirtschaft_gebietsTyp2"
    FOREIGN KEY ("gebietsTyp" )
    REFERENCES "RP_Basisobjekte"."RP_GebietsTyp" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
GRANT SELECT ON TABLE "RP_KernmodellFreiraumstruktur"."RP_Forstwirtschaft_gebietsTyp" TO xp_gast;
GRANT ALL ON TABLE "RP_KernmodellFreiraumstruktur"."RP_Forstwirtschaft_gebietsTyp" TO rp_user;
COMMENT ON TABLE  "RP_KernmodellFreiraumstruktur"."RP_Forstwirtschaft_gebietsTyp" IS 'Klassifikation des Gebietes nach Bundesraumordnungsgesetz.';

-- -----------------------------------------------------
-- Table "RP_KernmodellFreiraumstruktur"."RP_ForstwirtschaftFlaeche"
-- -----------------------------------------------------
CREATE  TABLE  "RP_KernmodellFreiraumstruktur"."RP_ForstwirtschaftFlaeche" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_RP_ForstwirtschaftFlaeche_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "RP_KernmodellFreiraumstruktur"."RP_Forstwirtschaft" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("RP_Basisobjekte"."RP_Flaechenobjekt");

GRANT SELECT ON TABLE "RP_KernmodellFreiraumstruktur"."RP_ForstwirtschaftFlaeche" TO xp_gast;
GRANT ALL ON TABLE "RP_KernmodellFreiraumstruktur"."RP_ForstwirtschaftFlaeche" TO rp_user;
COMMENT ON COLUMN "RP_KernmodellFreiraumstruktur"."RP_ForstwirtschaftFlaeche"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_RP_ForstwirtschaftFlaeche" BEFORE INSERT OR UPDATE ON "RP_KernmodellFreiraumstruktur"."RP_ForstwirtschaftFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_ForstwirtschaftFlaeche" AFTER DELETE ON "RP_KernmodellFreiraumstruktur"."RP_ForstwirtschaftFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "RP_ForstwirtschaftFlaeche_Flaechenobjekt" BEFORE INSERT OR UPDATE ON "RP_KernmodellFreiraumstruktur"."RP_ForstwirtschaftFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."positionFollowsRHR"();

-- -----------------------------------------------------
-- Table "RP_KernmodellFreiraumstruktur"."RP_ForstwirtschaftLinie"
-- -----------------------------------------------------
CREATE  TABLE  "RP_KernmodellFreiraumstruktur"."RP_ForstwirtschaftLinie" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_RP_ForstwirtschaftLinie_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "RP_KernmodellFreiraumstruktur"."RP_Forstwirtschaft" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("RP_Basisobjekte"."RP_Linienobjekt");

GRANT SELECT ON TABLE "RP_KernmodellFreiraumstruktur"."RP_ForstwirtschaftLinie" TO xp_gast;
GRANT ALL ON TABLE "RP_KernmodellFreiraumstruktur"."RP_ForstwirtschaftLinie" TO rp_user;
COMMENT ON COLUMN "RP_KernmodellFreiraumstruktur"."RP_ForstwirtschaftLinie"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_RP_ForstwirtschaftLinie" BEFORE INSERT OR UPDATE ON "RP_KernmodellFreiraumstruktur"."RP_ForstwirtschaftLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_ForstwirtschaftLinie" AFTER DELETE ON "RP_KernmodellFreiraumstruktur"."RP_ForstwirtschaftLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "RP_KernmodellFreiraumstruktur"."RP_ForstwirtschaftPunkt"
-- -----------------------------------------------------
CREATE  TABLE  "RP_KernmodellFreiraumstruktur"."RP_ForstwirtschaftPunkt" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_RP_ForstwirtschaftPunkt_parent"
    FOREIGN KEY ("gid")
    REFERENCES "RP_KernmodellFreiraumstruktur"."RP_Forstwirtschaft" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("RP_Basisobjekte"."RP_Punktobjekt");

GRANT SELECT ON TABLE "RP_KernmodellFreiraumstruktur"."RP_ForstwirtschaftPunkt" TO xp_gast;
GRANT ALL ON TABLE "RP_KernmodellFreiraumstruktur"."RP_ForstwirtschaftPunkt" TO rp_user;
COMMENT ON COLUMN "RP_KernmodellFreiraumstruktur"."RP_ForstwirtschaftPunkt"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_RP_ForstwirtschaftPunkt" BEFORE INSERT OR UPDATE ON "RP_KernmodellFreiraumstruktur"."RP_ForstwirtschaftPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_ForstwirtschaftPunkt" AFTER DELETE ON "RP_KernmodellFreiraumstruktur"."RP_ForstwirtschaftPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "RP_KernmodellFreiraumstruktur"."RP_FreizeitErholung"
-- -----------------------------------------------------
CREATE  TABLE  "RP_KernmodellFreiraumstruktur"."RP_FreizeitErholung" (
  "gid" BIGINT NOT NULL ,
  "istAusgleichsgebiet" BOOLEAN NULL,
  PRIMARY KEY ("gid"),
  CONSTRAINT "fk_RP_FreizeitErholung_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "RP_Basisobjekte"."RP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE);

GRANT SELECT ON TABLE "RP_KernmodellFreiraumstruktur"."RP_FreizeitErholung" TO xp_gast;
GRANT ALL ON TABLE "RP_KernmodellFreiraumstruktur"."RP_FreizeitErholung" TO rp_user;
COMMENT ON TABLE  "RP_KernmodellFreiraumstruktur"."RP_FreizeitErholung" IS 'Freizeit und Erholung';
COMMENT ON COLUMN  "RP_KernmodellFreiraumstruktur"."RP_FreizeitErholung"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN  "RP_KernmodellFreiraumstruktur"."RP_FreizeitErholung"."istAusgleichsgebiet" IS 'Gibt an, ob es sich um ein Ausgleichsgebiet handelt.';
CREATE TRIGGER "change_to_RP_FreizeitErholung" BEFORE INSERT OR UPDATE ON "RP_KernmodellFreiraumstruktur"."RP_FreizeitErholung" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_FreizeitErholung" AFTER DELETE ON "RP_KernmodellFreiraumstruktur"."RP_FreizeitErholung" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "RP_KernmodellFreiraumstruktur"."RP_FreizeitErholung_gebietsTyp"
-- -----------------------------------------------------
CREATE  TABLE  "RP_KernmodellFreiraumstruktur"."RP_FreizeitErholung_gebietsTyp" (
  "RP_FreizeitErholung_gid" BIGINT NOT NULL ,
  "gebietsTyp" INTEGER NOT NULL ,
  PRIMARY KEY ("RP_FreizeitErholung_gid", "gebietsTyp"),
  CONSTRAINT "fk_RP_FreizeitErholung_gebietsTyp1"
    FOREIGN KEY ("RP_FreizeitErholung_gid" )
    REFERENCES "RP_KernmodellFreiraumstruktur"."RP_FreizeitErholung" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_RP_FreizeitErholung_gebietsTyp2"
    FOREIGN KEY ("gebietsTyp" )
    REFERENCES "RP_Basisobjekte"."RP_GebietsTyp" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
GRANT SELECT ON TABLE "RP_KernmodellFreiraumstruktur"."RP_FreizeitErholung_gebietsTyp" TO xp_gast;
GRANT ALL ON TABLE "RP_KernmodellFreiraumstruktur"."RP_FreizeitErholung_gebietsTyp" TO rp_user;
COMMENT ON TABLE  "RP_KernmodellFreiraumstruktur"."RP_FreizeitErholung_gebietsTyp" IS 'Klassifikation des Gebietes nach Bundesraumordnungsgesetz.';

-- -----------------------------------------------------
-- Table "RP_KernmodellFreiraumstruktur"."RP_FreizeitErholungFlaeche"
-- -----------------------------------------------------
CREATE  TABLE  "RP_KernmodellFreiraumstruktur"."RP_FreizeitErholungFlaeche" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_RP_FreizeitErholungFlaeche_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "RP_KernmodellFreiraumstruktur"."RP_FreizeitErholung" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("RP_Basisobjekte"."RP_Flaechenobjekt");

GRANT SELECT ON TABLE "RP_KernmodellFreiraumstruktur"."RP_FreizeitErholungFlaeche" TO xp_gast;
GRANT ALL ON TABLE "RP_KernmodellFreiraumstruktur"."RP_FreizeitErholungFlaeche" TO rp_user;
COMMENT ON COLUMN "RP_KernmodellFreiraumstruktur"."RP_FreizeitErholungFlaeche"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_RP_FreizeitErholungFlaeche" BEFORE INSERT OR UPDATE ON "RP_KernmodellFreiraumstruktur"."RP_FreizeitErholungFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_FreizeitErholungFlaeche" AFTER DELETE ON "RP_KernmodellFreiraumstruktur"."RP_FreizeitErholungFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "RP_FreizeitErholungFlaeche_Flaechenobjekt" BEFORE INSERT OR UPDATE ON "RP_KernmodellFreiraumstruktur"."RP_FreizeitErholungFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."positionFollowsRHR"();

-- -----------------------------------------------------
-- Table "RP_KernmodellFreiraumstruktur"."RP_FreizeitErholungLinie"
-- -----------------------------------------------------
CREATE  TABLE  "RP_KernmodellFreiraumstruktur"."RP_FreizeitErholungLinie" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_RP_FreizeitErholungLinie_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "RP_KernmodellFreiraumstruktur"."RP_FreizeitErholung" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("RP_Basisobjekte"."RP_Linienobjekt");

GRANT SELECT ON TABLE "RP_KernmodellFreiraumstruktur"."RP_FreizeitErholungLinie" TO xp_gast;
GRANT ALL ON TABLE "RP_KernmodellFreiraumstruktur"."RP_FreizeitErholungLinie" TO rp_user;
COMMENT ON COLUMN "RP_KernmodellFreiraumstruktur"."RP_FreizeitErholungLinie"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_RP_FreizeitErholungLinie" BEFORE INSERT OR UPDATE ON "RP_KernmodellFreiraumstruktur"."RP_FreizeitErholungLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_FreizeitErholungLinie" AFTER DELETE ON "RP_KernmodellFreiraumstruktur"."RP_FreizeitErholungLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "RP_KernmodellFreiraumstruktur"."RP_FreizeitErholungPunkt"
-- -----------------------------------------------------
CREATE  TABLE  "RP_KernmodellFreiraumstruktur"."RP_FreizeitErholungPunkt" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_RP_FreizeitErholungPunkt_parent"
    FOREIGN KEY ("gid")
    REFERENCES "RP_KernmodellFreiraumstruktur"."RP_FreizeitErholung" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("RP_Basisobjekte"."RP_Punktobjekt");

GRANT SELECT ON TABLE "RP_KernmodellFreiraumstruktur"."RP_FreizeitErholungPunkt" TO xp_gast;
GRANT ALL ON TABLE "RP_KernmodellFreiraumstruktur"."RP_FreizeitErholungPunkt" TO rp_user;
COMMENT ON COLUMN "RP_KernmodellFreiraumstruktur"."RP_FreizeitErholungPunkt"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_RP_FreizeitErholungPunkt" BEFORE INSERT OR UPDATE ON "RP_KernmodellFreiraumstruktur"."RP_FreizeitErholungPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_FreizeitErholungPunkt" AFTER DELETE ON "RP_KernmodellFreiraumstruktur"."RP_FreizeitErholungPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "RP_KernmodellFreiraumstruktur"."RP_Gewaesser"
-- -----------------------------------------------------
CREATE  TABLE  "RP_KernmodellFreiraumstruktur"."RP_Gewaesser" (
  "gid" BIGINT NOT NULL ,
  "istAusgleichsgebiet" BOOLEAN NULL,
  PRIMARY KEY ("gid"),
  CONSTRAINT "fk_RP_Gewaesser_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "RP_Basisobjekte"."RP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE);

GRANT SELECT ON TABLE "RP_KernmodellFreiraumstruktur"."RP_Gewaesser" TO xp_gast;
GRANT ALL ON TABLE "RP_KernmodellFreiraumstruktur"."RP_Gewaesser" TO rp_user;
COMMENT ON TABLE  "RP_KernmodellFreiraumstruktur"."RP_Gewaesser" IS 'Gewässer';
COMMENT ON COLUMN  "RP_KernmodellFreiraumstruktur"."RP_Gewaesser"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN  "RP_KernmodellFreiraumstruktur"."RP_Gewaesser"."istAusgleichsgebiet" IS 'Gibt an, ob es sich um ein Ausgleichsgebiet handelt.';
CREATE TRIGGER "change_to_RP_Gewaesser" BEFORE INSERT OR UPDATE ON "RP_KernmodellFreiraumstruktur"."RP_Gewaesser" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_Gewaesser" AFTER DELETE ON "RP_KernmodellFreiraumstruktur"."RP_Gewaesser" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "RP_KernmodellFreiraumstruktur"."RP_GewaesserFlaeche"
-- -----------------------------------------------------
CREATE  TABLE  "RP_KernmodellFreiraumstruktur"."RP_GewaesserFlaeche" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_RP_GewaesserFlaeche_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "RP_KernmodellFreiraumstruktur"."RP_Gewaesser" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("RP_Basisobjekte"."RP_Flaechenobjekt");

GRANT SELECT ON TABLE "RP_KernmodellFreiraumstruktur"."RP_GewaesserFlaeche" TO xp_gast;
GRANT ALL ON TABLE "RP_KernmodellFreiraumstruktur"."RP_GewaesserFlaeche" TO rp_user;
COMMENT ON COLUMN "RP_KernmodellFreiraumstruktur"."RP_GewaesserFlaeche"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_RP_GewaesserFlaeche" BEFORE INSERT OR UPDATE ON "RP_KernmodellFreiraumstruktur"."RP_GewaesserFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_GewaesserFlaeche" AFTER DELETE ON "RP_KernmodellFreiraumstruktur"."RP_GewaesserFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "RP_GewaesserFlaeche_Flaechenobjekt" BEFORE INSERT OR UPDATE ON "RP_KernmodellFreiraumstruktur"."RP_GewaesserFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."positionFollowsRHR"();

-- -----------------------------------------------------
-- Table "RP_KernmodellFreiraumstruktur"."RP_GewaesserLinie"
-- -----------------------------------------------------
CREATE  TABLE  "RP_KernmodellFreiraumstruktur"."RP_GewaesserLinie" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_RP_GewaesserLinie_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "RP_KernmodellFreiraumstruktur"."RP_Gewaesser" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("RP_Basisobjekte"."RP_Linienobjekt");

GRANT SELECT ON TABLE "RP_KernmodellFreiraumstruktur"."RP_GewaesserLinie" TO xp_gast;
GRANT ALL ON TABLE "RP_KernmodellFreiraumstruktur"."RP_GewaesserLinie" TO rp_user;
COMMENT ON COLUMN "RP_KernmodellFreiraumstruktur"."RP_GewaesserLinie"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_RP_GewaesserLinie" BEFORE INSERT OR UPDATE ON "RP_KernmodellFreiraumstruktur"."RP_GewaesserLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_GewaesserLinie" AFTER DELETE ON "RP_KernmodellFreiraumstruktur"."RP_GewaesserLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "RP_KernmodellFreiraumstruktur"."RP_GewaesserPunkt"
-- -----------------------------------------------------
CREATE  TABLE  "RP_KernmodellFreiraumstruktur"."RP_GewaesserPunkt" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_RP_GewaesserPunkt_parent"
    FOREIGN KEY ("gid")
    REFERENCES "RP_KernmodellFreiraumstruktur"."RP_Gewaesser" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("RP_Basisobjekte"."RP_Punktobjekt");

GRANT SELECT ON TABLE "RP_KernmodellFreiraumstruktur"."RP_GewaesserPunkt" TO xp_gast;
GRANT ALL ON TABLE "RP_KernmodellFreiraumstruktur"."RP_GewaesserPunkt" TO rp_user;
COMMENT ON COLUMN "RP_KernmodellFreiraumstruktur"."RP_GewaesserPunkt"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_RP_GewaesserPunkt" BEFORE INSERT OR UPDATE ON "RP_KernmodellFreiraumstruktur"."RP_GewaesserPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_GewaesserPunkt" AFTER DELETE ON "RP_KernmodellFreiraumstruktur"."RP_GewaesserPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "RP_KernmodellFreiraumstruktur"."RP_GruenzugGruenzaesur"
-- -----------------------------------------------------
CREATE  TABLE  "RP_KernmodellFreiraumstruktur"."RP_GruenzugGruenzaesur" (
  "gid" BIGINT NOT NULL ,
  "istAusgleichsgebiet" BOOLEAN NULL,
  PRIMARY KEY ("gid"),
  CONSTRAINT "fk_RP_GruenzugGruenzaesur_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "RP_Basisobjekte"."RP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE);

GRANT SELECT ON TABLE "RP_KernmodellFreiraumstruktur"."RP_GruenzugGruenzaesur" TO xp_gast;
GRANT ALL ON TABLE "RP_KernmodellFreiraumstruktur"."RP_GruenzugGruenzaesur" TO rp_user;
COMMENT ON TABLE  "RP_KernmodellFreiraumstruktur"."RP_GruenzugGruenzaesur" IS 'Grünzüge und kleinräumigere Grünzäsuren sind Ordnungsinstrumente zur Freiraumsicherung. Teilweise werden Grünzüge auch Trenngrün genannt.';
COMMENT ON COLUMN  "RP_KernmodellFreiraumstruktur"."RP_GruenzugGruenzaesur"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN  "RP_KernmodellFreiraumstruktur"."RP_GruenzugGruenzaesur"."istAusgleichsgebiet" IS 'Gibt an, ob es sich um ein Ausgleichsgebiet handelt.';
CREATE TRIGGER "change_to_RP_GruenzugGruenzaesur" BEFORE INSERT OR UPDATE ON "RP_KernmodellFreiraumstruktur"."RP_GruenzugGruenzaesur" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_GruenzugGruenzaesur" AFTER DELETE ON "RP_KernmodellFreiraumstruktur"."RP_GruenzugGruenzaesur" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "RP_KernmodellFreiraumstruktur"."RP_GruenzugGruenzaesur_gebietsTyp"
-- -----------------------------------------------------
CREATE  TABLE  "RP_KernmodellFreiraumstruktur"."RP_GruenzugGruenzaesur_gebietsTyp" (
  "RP_GruenzugGruenzaesur_gid" BIGINT NOT NULL ,
  "gebietsTyp" INTEGER NOT NULL ,
  PRIMARY KEY ("RP_GruenzugGruenzaesur_gid", "gebietsTyp"),
  CONSTRAINT "fk_RP_GruenzugGruenzaesur_gebietsTyp1"
    FOREIGN KEY ("RP_GruenzugGruenzaesur_gid" )
    REFERENCES "RP_KernmodellFreiraumstruktur"."RP_GruenzugGruenzaesur" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_RP_GruenzugGruenzaesur_gebietsTyp2"
    FOREIGN KEY ("gebietsTyp" )
    REFERENCES "RP_Basisobjekte"."RP_GebietsTyp" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
GRANT SELECT ON TABLE "RP_KernmodellFreiraumstruktur"."RP_GruenzugGruenzaesur_gebietsTyp" TO xp_gast;
GRANT ALL ON TABLE "RP_KernmodellFreiraumstruktur"."RP_GruenzugGruenzaesur_gebietsTyp" TO rp_user;
COMMENT ON TABLE  "RP_KernmodellFreiraumstruktur"."RP_GruenzugGruenzaesur_gebietsTyp" IS 'Klassifikation des Gebietes nach Bundesraumordnungsgesetz.';

-- -----------------------------------------------------
-- Table "RP_KernmodellFreiraumstruktur"."RP_GruenzugGruenzaesurFlaeche"
-- -----------------------------------------------------
CREATE  TABLE  "RP_KernmodellFreiraumstruktur"."RP_GruenzugGruenzaesurFlaeche" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_RP_GruenzugGruenzaesurFlaeche_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "RP_KernmodellFreiraumstruktur"."RP_GruenzugGruenzaesur" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("RP_Basisobjekte"."RP_Flaechenobjekt");

GRANT SELECT ON TABLE "RP_KernmodellFreiraumstruktur"."RP_GruenzugGruenzaesurFlaeche" TO xp_gast;
GRANT ALL ON TABLE "RP_KernmodellFreiraumstruktur"."RP_GruenzugGruenzaesurFlaeche" TO rp_user;
COMMENT ON COLUMN "RP_KernmodellFreiraumstruktur"."RP_GruenzugGruenzaesurFlaeche"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_RP_GruenzugGruenzaesurFlaeche" BEFORE INSERT OR UPDATE ON "RP_KernmodellFreiraumstruktur"."RP_GruenzugGruenzaesurFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_GruenzugGruenzaesurFlaeche" AFTER DELETE ON "RP_KernmodellFreiraumstruktur"."RP_GruenzugGruenzaesurFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "RP_GruenzugGruenzaesurFlaeche_Flaechenobjekt" BEFORE INSERT OR UPDATE ON "RP_KernmodellFreiraumstruktur"."RP_GruenzugGruenzaesurFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."positionFollowsRHR"();

-- -----------------------------------------------------
-- Table "RP_KernmodellFreiraumstruktur"."RP_GruenzugGruenzaesurLinie"
-- -----------------------------------------------------
CREATE  TABLE  "RP_KernmodellFreiraumstruktur"."RP_GruenzugGruenzaesurLinie" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_RP_GruenzugGruenzaesurLinie_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "RP_KernmodellFreiraumstruktur"."RP_GruenzugGruenzaesur" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("RP_Basisobjekte"."RP_Linienobjekt");

GRANT SELECT ON TABLE "RP_KernmodellFreiraumstruktur"."RP_GruenzugGruenzaesurLinie" TO xp_gast;
GRANT ALL ON TABLE "RP_KernmodellFreiraumstruktur"."RP_GruenzugGruenzaesurLinie" TO rp_user;
COMMENT ON COLUMN "RP_KernmodellFreiraumstruktur"."RP_GruenzugGruenzaesurLinie"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_RP_GruenzugGruenzaesurLinie" BEFORE INSERT OR UPDATE ON "RP_KernmodellFreiraumstruktur"."RP_GruenzugGruenzaesurLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_GruenzugGruenzaesurLinie" AFTER DELETE ON "RP_KernmodellFreiraumstruktur"."RP_GruenzugGruenzaesurLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "RP_KernmodellFreiraumstruktur"."RP_GruenzugGruenzaesurPunkt"
-- -----------------------------------------------------
CREATE  TABLE  "RP_KernmodellFreiraumstruktur"."RP_GruenzugGruenzaesurPunkt" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_RP_GruenzugGruenzaesurPunkt_parent"
    FOREIGN KEY ("gid")
    REFERENCES "RP_KernmodellFreiraumstruktur"."RP_GruenzugGruenzaesur" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("RP_Basisobjekte"."RP_Punktobjekt");

GRANT SELECT ON TABLE "RP_KernmodellFreiraumstruktur"."RP_GruenzugGruenzaesurPunkt" TO xp_gast;
GRANT ALL ON TABLE "RP_KernmodellFreiraumstruktur"."RP_GruenzugGruenzaesurPunkt" TO rp_user;
COMMENT ON COLUMN "RP_KernmodellFreiraumstruktur"."RP_GruenzugGruenzaesurPunkt"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_RP_GruenzugGruenzaesurPunkt" BEFORE INSERT OR UPDATE ON "RP_KernmodellFreiraumstruktur"."RP_GruenzugGruenzaesurPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_GruenzugGruenzaesurPunkt" AFTER DELETE ON "RP_KernmodellFreiraumstruktur"."RP_GruenzugGruenzaesurPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "RP_KernmodellFreiraumstruktur"."RP_Klimaschutz"
-- -----------------------------------------------------
CREATE  TABLE  "RP_KernmodellFreiraumstruktur"."RP_Klimaschutz" (
  "gid" BIGINT NOT NULL ,
  "istAusgleichsgebiet" BOOLEAN NULL,
  PRIMARY KEY ("gid"),
  CONSTRAINT "fk_RP_Klimaschutz_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "RP_Basisobjekte"."RP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE);

GRANT SELECT ON TABLE "RP_KernmodellFreiraumstruktur"."RP_Klimaschutz" TO xp_gast;
GRANT ALL ON TABLE "RP_KernmodellFreiraumstruktur"."RP_Klimaschutz" TO rp_user;
COMMENT ON TABLE  "RP_KernmodellFreiraumstruktur"."RP_Klimaschutz" IS '(Siedlungs-) Klimaschutz';
COMMENT ON COLUMN  "RP_KernmodellFreiraumstruktur"."RP_Klimaschutz"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN  "RP_KernmodellFreiraumstruktur"."RP_Klimaschutz"."istAusgleichsgebiet" IS 'Gibt an, ob es sich um ein Ausgleichsgebiet handelt.';
CREATE TRIGGER "change_to_RP_Klimaschutz" BEFORE INSERT OR UPDATE ON "RP_KernmodellFreiraumstruktur"."RP_Klimaschutz" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_Klimaschutz" AFTER DELETE ON "RP_KernmodellFreiraumstruktur"."RP_Klimaschutz" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "RP_KernmodellFreiraumstruktur"."RP_Klimaschutz_gebietsTyp"
-- -----------------------------------------------------
CREATE  TABLE  "RP_KernmodellFreiraumstruktur"."RP_Klimaschutz_gebietsTyp" (
  "RP_Klimaschutz_gid" BIGINT NOT NULL ,
  "gebietsTyp" INTEGER NOT NULL ,
  PRIMARY KEY ("RP_Klimaschutz_gid", "gebietsTyp"),
  CONSTRAINT "fk_RP_Klimaschutz_gebietsTyp1"
    FOREIGN KEY ("RP_Klimaschutz_gid" )
    REFERENCES "RP_KernmodellFreiraumstruktur"."RP_Klimaschutz" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_RP_Klimaschutz_gebietsTyp2"
    FOREIGN KEY ("gebietsTyp" )
    REFERENCES "RP_Basisobjekte"."RP_GebietsTyp" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
GRANT SELECT ON TABLE "RP_KernmodellFreiraumstruktur"."RP_Klimaschutz_gebietsTyp" TO xp_gast;
GRANT ALL ON TABLE "RP_KernmodellFreiraumstruktur"."RP_Klimaschutz_gebietsTyp" TO rp_user;
COMMENT ON TABLE  "RP_KernmodellFreiraumstruktur"."RP_Klimaschutz_gebietsTyp" IS 'Klassifikation des Gebietes nach Bundesraumordnungsgesetz.';

-- -----------------------------------------------------
-- Table "RP_KernmodellFreiraumstruktur"."RP_KlimaschutzFlaeche"
-- -----------------------------------------------------
CREATE  TABLE  "RP_KernmodellFreiraumstruktur"."RP_KlimaschutzFlaeche" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_RP_KlimaschutzFlaeche_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "RP_KernmodellFreiraumstruktur"."RP_Klimaschutz" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("RP_Basisobjekte"."RP_Flaechenobjekt");

GRANT SELECT ON TABLE "RP_KernmodellFreiraumstruktur"."RP_KlimaschutzFlaeche" TO xp_gast;
GRANT ALL ON TABLE "RP_KernmodellFreiraumstruktur"."RP_KlimaschutzFlaeche" TO rp_user;
COMMENT ON COLUMN "RP_KernmodellFreiraumstruktur"."RP_KlimaschutzFlaeche"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_RP_KlimaschutzFlaeche" BEFORE INSERT OR UPDATE ON "RP_KernmodellFreiraumstruktur"."RP_KlimaschutzFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_KlimaschutzFlaeche" AFTER DELETE ON "RP_KernmodellFreiraumstruktur"."RP_KlimaschutzFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "RP_KlimaschutzFlaeche_Flaechenobjekt" BEFORE INSERT OR UPDATE ON "RP_KernmodellFreiraumstruktur"."RP_KlimaschutzFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."positionFollowsRHR"();

-- -----------------------------------------------------
-- Table "RP_KernmodellFreiraumstruktur"."RP_KlimaschutzLinie"
-- -----------------------------------------------------
CREATE  TABLE  "RP_KernmodellFreiraumstruktur"."RP_KlimaschutzLinie" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_RP_KlimaschutzLinie_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "RP_KernmodellFreiraumstruktur"."RP_Klimaschutz" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("RP_Basisobjekte"."RP_Linienobjekt");

GRANT SELECT ON TABLE "RP_KernmodellFreiraumstruktur"."RP_KlimaschutzLinie" TO xp_gast;
GRANT ALL ON TABLE "RP_KernmodellFreiraumstruktur"."RP_KlimaschutzLinie" TO rp_user;
COMMENT ON COLUMN "RP_KernmodellFreiraumstruktur"."RP_KlimaschutzLinie"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_RP_KlimaschutzLinie" BEFORE INSERT OR UPDATE ON "RP_KernmodellFreiraumstruktur"."RP_KlimaschutzLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_KlimaschutzLinie" AFTER DELETE ON "RP_KernmodellFreiraumstruktur"."RP_KlimaschutzLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "RP_KernmodellFreiraumstruktur"."RP_KlimaschutzPunkt"
-- -----------------------------------------------------
CREATE  TABLE  "RP_KernmodellFreiraumstruktur"."RP_KlimaschutzPunkt" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_RP_KlimaschutzPunkt_parent"
    FOREIGN KEY ("gid")
    REFERENCES "RP_KernmodellFreiraumstruktur"."RP_Klimaschutz" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("RP_Basisobjekte"."RP_Punktobjekt");

GRANT SELECT ON TABLE "RP_KernmodellFreiraumstruktur"."RP_KlimaschutzPunkt" TO xp_gast;
GRANT ALL ON TABLE "RP_KernmodellFreiraumstruktur"."RP_KlimaschutzPunkt" TO rp_user;
COMMENT ON COLUMN "RP_KernmodellFreiraumstruktur"."RP_KlimaschutzPunkt"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_RP_KlimaschutzPunkt" BEFORE INSERT OR UPDATE ON "RP_KernmodellFreiraumstruktur"."RP_KlimaschutzPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_KlimaschutzPunkt" AFTER DELETE ON "RP_KernmodellFreiraumstruktur"."RP_KlimaschutzPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "RP_KernmodellFreiraumstruktur"."RP_KulturellesSachgut"
-- -----------------------------------------------------
CREATE  TABLE  "RP_KernmodellFreiraumstruktur"."RP_KulturellesSachgut" (
  "gid" BIGINT NOT NULL ,
  "istAusgleichsgebiet" BOOLEAN NULL,
  PRIMARY KEY ("gid"),
  CONSTRAINT "fk_RP_KulturellesSachgut_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "RP_Basisobjekte"."RP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE);

GRANT SELECT ON TABLE "RP_KernmodellFreiraumstruktur"."RP_KulturellesSachgut" TO xp_gast;
GRANT ALL ON TABLE "RP_KernmodellFreiraumstruktur"."RP_KulturellesSachgut" TO rp_user;
COMMENT ON TABLE  "RP_KernmodellFreiraumstruktur"."RP_KulturellesSachgut" IS 'Kulturelles Sachgut ';
COMMENT ON COLUMN  "RP_KernmodellFreiraumstruktur"."RP_KulturellesSachgut"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN  "RP_KernmodellFreiraumstruktur"."RP_KulturellesSachgut"."istAusgleichsgebiet" IS 'Gibt an, ob es sich um ein Ausgleichsgebiet handelt.';
CREATE TRIGGER "change_to_RP_KulturellesSachgut" BEFORE INSERT OR UPDATE ON "RP_KernmodellFreiraumstruktur"."RP_KulturellesSachgut" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_KulturellesSachgut" AFTER DELETE ON "RP_KernmodellFreiraumstruktur"."RP_KulturellesSachgut" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "RP_KernmodellFreiraumstruktur"."RP_KulturellesSachgut_gebietsTyp"
-- -----------------------------------------------------
CREATE  TABLE  "RP_KernmodellFreiraumstruktur"."RP_KulturellesSachgut_gebietsTyp" (
  "RP_KulturellesSachgut_gid" BIGINT NOT NULL ,
  "gebietsTyp" INTEGER NOT NULL ,
  PRIMARY KEY ("RP_KulturellesSachgut_gid", "gebietsTyp"),
  CONSTRAINT "fk_RP_KulturellesSachgut_gebietsTyp1"
    FOREIGN KEY ("RP_KulturellesSachgut_gid" )
    REFERENCES "RP_KernmodellFreiraumstruktur"."RP_KulturellesSachgut" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_RP_KulturellesSachgut_gebietsTyp2"
    FOREIGN KEY ("gebietsTyp" )
    REFERENCES "RP_Basisobjekte"."RP_GebietsTyp" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
GRANT SELECT ON TABLE "RP_KernmodellFreiraumstruktur"."RP_KulturellesSachgut_gebietsTyp" TO xp_gast;
GRANT ALL ON TABLE "RP_KernmodellFreiraumstruktur"."RP_KulturellesSachgut_gebietsTyp" TO rp_user;
COMMENT ON TABLE  "RP_KernmodellFreiraumstruktur"."RP_KulturellesSachgut_gebietsTyp" IS 'Klassifikation des Gebietes nach Bundesraumordnungsgesetz.';

-- -----------------------------------------------------
-- Table "RP_KernmodellFreiraumstruktur"."RP_KulturellesSachgutFlaeche"
-- -----------------------------------------------------
CREATE  TABLE  "RP_KernmodellFreiraumstruktur"."RP_KulturellesSachgutFlaeche" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_RP_KulturellesSachgutFlaeche_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "RP_KernmodellFreiraumstruktur"."RP_KulturellesSachgut" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("RP_Basisobjekte"."RP_Flaechenobjekt");

GRANT SELECT ON TABLE "RP_KernmodellFreiraumstruktur"."RP_KulturellesSachgutFlaeche" TO xp_gast;
GRANT ALL ON TABLE "RP_KernmodellFreiraumstruktur"."RP_KulturellesSachgutFlaeche" TO rp_user;
COMMENT ON COLUMN "RP_KernmodellFreiraumstruktur"."RP_KulturellesSachgutFlaeche"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_RP_KulturellesSachgutFlaeche" BEFORE INSERT OR UPDATE ON "RP_KernmodellFreiraumstruktur"."RP_KulturellesSachgutFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_KulturellesSachgutFlaeche" AFTER DELETE ON "RP_KernmodellFreiraumstruktur"."RP_KulturellesSachgutFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "RP_KulturellesSachgutFlaeche_Flaechenobjekt" BEFORE INSERT OR UPDATE ON "RP_KernmodellFreiraumstruktur"."RP_KulturellesSachgutFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."positionFollowsRHR"();

-- -----------------------------------------------------
-- Table "RP_KernmodellFreiraumstruktur"."RP_KulturellesSachgutLinie"
-- -----------------------------------------------------
CREATE  TABLE  "RP_KernmodellFreiraumstruktur"."RP_KulturellesSachgutLinie" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_RP_KulturellesSachgutLinie_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "RP_KernmodellFreiraumstruktur"."RP_KulturellesSachgut" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("RP_Basisobjekte"."RP_Linienobjekt");

GRANT SELECT ON TABLE "RP_KernmodellFreiraumstruktur"."RP_KulturellesSachgutLinie" TO xp_gast;
GRANT ALL ON TABLE "RP_KernmodellFreiraumstruktur"."RP_KulturellesSachgutLinie" TO rp_user;
COMMENT ON COLUMN "RP_KernmodellFreiraumstruktur"."RP_KulturellesSachgutLinie"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_RP_KulturellesSachgutLinie" BEFORE INSERT OR UPDATE ON "RP_KernmodellFreiraumstruktur"."RP_KulturellesSachgutLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_KulturellesSachgutLinie" AFTER DELETE ON "RP_KernmodellFreiraumstruktur"."RP_KulturellesSachgutLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "RP_KernmodellFreiraumstruktur"."RP_KulturellesSachgutPunkt"
-- -----------------------------------------------------
CREATE  TABLE  "RP_KernmodellFreiraumstruktur"."RP_KulturellesSachgutPunkt" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_RP_KulturellesSachgutPunkt_parent"
    FOREIGN KEY ("gid")
    REFERENCES "RP_KernmodellFreiraumstruktur"."RP_KulturellesSachgut" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("RP_Basisobjekte"."RP_Punktobjekt");

GRANT SELECT ON TABLE "RP_KernmodellFreiraumstruktur"."RP_KulturellesSachgutPunkt" TO xp_gast;
GRANT ALL ON TABLE "RP_KernmodellFreiraumstruktur"."RP_KulturellesSachgutPunkt" TO rp_user;
COMMENT ON COLUMN "RP_KernmodellFreiraumstruktur"."RP_KulturellesSachgutPunkt"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_RP_KulturellesSachgutPunkt" BEFORE INSERT OR UPDATE ON "RP_KernmodellFreiraumstruktur"."RP_KulturellesSachgutPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_KulturellesSachgutPunkt" AFTER DELETE ON "RP_KernmodellFreiraumstruktur"."RP_KulturellesSachgutPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "RP_KernmodellFreiraumstruktur"."RP_Landwirtschaft"
-- -----------------------------------------------------
CREATE  TABLE  "RP_KernmodellFreiraumstruktur"."RP_Landwirtschaft" (
  "gid" BIGINT NOT NULL ,
  "istAusgleichsgebiet" BOOLEAN NULL,
  PRIMARY KEY ("gid"),
  CONSTRAINT "fk_RP_Landwirtschaft_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "RP_Basisobjekte"."RP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE);

GRANT SELECT ON TABLE "RP_KernmodellFreiraumstruktur"."RP_Landwirtschaft" TO xp_gast;
GRANT ALL ON TABLE "RP_KernmodellFreiraumstruktur"."RP_Landwirtschaft" TO rp_user;
COMMENT ON TABLE  "RP_KernmodellFreiraumstruktur"."RP_Landwirtschaft" IS 'Landwirtschaft';
COMMENT ON COLUMN  "RP_KernmodellFreiraumstruktur"."RP_Landwirtschaft"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN  "RP_KernmodellFreiraumstruktur"."RP_Landwirtschaft"."istAusgleichsgebiet" IS 'Gibt an, ob es sich um ein Ausgleichsgebiet handelt.';
CREATE TRIGGER "change_to_RP_Landwirtschaft" BEFORE INSERT OR UPDATE ON "RP_KernmodellFreiraumstruktur"."RP_Landwirtschaft" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_Landwirtschaft" AFTER DELETE ON "RP_KernmodellFreiraumstruktur"."RP_Landwirtschaft" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "RP_KernmodellFreiraumstruktur"."RP_Landwirtschaft_gebietsTyp"
-- -----------------------------------------------------
CREATE  TABLE  "RP_KernmodellFreiraumstruktur"."RP_Landwirtschaft_gebietsTyp" (
  "RP_Landwirtschaft_gid" BIGINT NOT NULL ,
  "gebietsTyp" INTEGER NOT NULL ,
  PRIMARY KEY ("RP_Landwirtschaft_gid", "gebietsTyp"),
  CONSTRAINT "fk_RP_Landwirtschaft_gebietsTyp1"
    FOREIGN KEY ("RP_Landwirtschaft_gid" )
    REFERENCES "RP_KernmodellFreiraumstruktur"."RP_Landwirtschaft" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_RP_Landwirtschaft_gebietsTyp2"
    FOREIGN KEY ("gebietsTyp" )
    REFERENCES "RP_Basisobjekte"."RP_GebietsTyp" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
GRANT SELECT ON TABLE "RP_KernmodellFreiraumstruktur"."RP_Landwirtschaft_gebietsTyp" TO xp_gast;
GRANT ALL ON TABLE "RP_KernmodellFreiraumstruktur"."RP_Landwirtschaft_gebietsTyp" TO rp_user;
COMMENT ON TABLE  "RP_KernmodellFreiraumstruktur"."RP_Landwirtschaft_gebietsTyp" IS 'Klassifikation des Gebietes nach Bundesraumordnungsgesetz.';

-- -----------------------------------------------------
-- Table "RP_KernmodellFreiraumstruktur"."RP_LandwirtschaftFlaeche"
-- -----------------------------------------------------
CREATE  TABLE  "RP_KernmodellFreiraumstruktur"."RP_LandwirtschaftFlaeche" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_RP_LandwirtschaftFlaeche_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "RP_KernmodellFreiraumstruktur"."RP_Landwirtschaft" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("RP_Basisobjekte"."RP_Flaechenobjekt");

GRANT SELECT ON TABLE "RP_KernmodellFreiraumstruktur"."RP_LandwirtschaftFlaeche" TO xp_gast;
GRANT ALL ON TABLE "RP_KernmodellFreiraumstruktur"."RP_LandwirtschaftFlaeche" TO rp_user;
COMMENT ON COLUMN "RP_KernmodellFreiraumstruktur"."RP_LandwirtschaftFlaeche"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_RP_LandwirtschaftFlaeche" BEFORE INSERT OR UPDATE ON "RP_KernmodellFreiraumstruktur"."RP_LandwirtschaftFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_LandwirtschaftFlaeche" AFTER DELETE ON "RP_KernmodellFreiraumstruktur"."RP_LandwirtschaftFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "RP_LandwirtschaftFlaeche_Flaechenobjekt" BEFORE INSERT OR UPDATE ON "RP_KernmodellFreiraumstruktur"."RP_LandwirtschaftFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."positionFollowsRHR"();

-- -----------------------------------------------------
-- Table "RP_KernmodellFreiraumstruktur"."RP_LandwirtschaftLinie"
-- -----------------------------------------------------
CREATE  TABLE  "RP_KernmodellFreiraumstruktur"."RP_LandwirtschaftLinie" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_RP_LandwirtschaftLinie_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "RP_KernmodellFreiraumstruktur"."RP_Landwirtschaft" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("RP_Basisobjekte"."RP_Linienobjekt");

GRANT SELECT ON TABLE "RP_KernmodellFreiraumstruktur"."RP_LandwirtschaftLinie" TO xp_gast;
GRANT ALL ON TABLE "RP_KernmodellFreiraumstruktur"."RP_LandwirtschaftLinie" TO rp_user;
COMMENT ON COLUMN "RP_KernmodellFreiraumstruktur"."RP_LandwirtschaftLinie"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_RP_LandwirtschaftLinie" BEFORE INSERT OR UPDATE ON "RP_KernmodellFreiraumstruktur"."RP_LandwirtschaftLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_LandwirtschaftLinie" AFTER DELETE ON "RP_KernmodellFreiraumstruktur"."RP_LandwirtschaftLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "RP_KernmodellFreiraumstruktur"."RP_LandwirtschaftPunkt"
-- -----------------------------------------------------
CREATE  TABLE  "RP_KernmodellFreiraumstruktur"."RP_LandwirtschaftPunkt" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_RP_LandwirtschaftPunkt_parent"
    FOREIGN KEY ("gid")
    REFERENCES "RP_KernmodellFreiraumstruktur"."RP_Landwirtschaft" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("RP_Basisobjekte"."RP_Punktobjekt");

GRANT SELECT ON TABLE "RP_KernmodellFreiraumstruktur"."RP_LandwirtschaftPunkt" TO xp_gast;
GRANT ALL ON TABLE "RP_KernmodellFreiraumstruktur"."RP_LandwirtschaftPunkt" TO rp_user;
COMMENT ON COLUMN "RP_KernmodellFreiraumstruktur"."RP_LandwirtschaftPunkt"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_RP_LandwirtschaftPunkt" BEFORE INSERT OR UPDATE ON "RP_KernmodellFreiraumstruktur"."RP_LandwirtschaftPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_LandwirtschaftPunkt" AFTER DELETE ON "RP_KernmodellFreiraumstruktur"."RP_LandwirtschaftPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "RP_KernmodellFreiraumstruktur"."RP_NaturLandschaft"
-- -----------------------------------------------------
CREATE  TABLE  "RP_KernmodellFreiraumstruktur"."RP_NaturLandschaft" (
  "gid" BIGINT NOT NULL ,
  "istAusgleichsgebiet" BOOLEAN NULL,
  PRIMARY KEY ("gid"),
  CONSTRAINT "fk_RP_NaturLandschaft_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "RP_Basisobjekte"."RP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE);

GRANT SELECT ON TABLE "RP_KernmodellFreiraumstruktur"."RP_NaturLandschaft" TO xp_gast;
GRANT ALL ON TABLE "RP_KernmodellFreiraumstruktur"."RP_NaturLandschaft" TO rp_user;
COMMENT ON TABLE  "RP_KernmodellFreiraumstruktur"."RP_NaturLandschaft" IS 'Natur und Landschaft';
COMMENT ON COLUMN  "RP_KernmodellFreiraumstruktur"."RP_NaturLandschaft"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN  "RP_KernmodellFreiraumstruktur"."RP_NaturLandschaft"."istAusgleichsgebiet" IS 'Gibt an, ob es sich um ein Ausgleichsgebiet handelt.';
CREATE TRIGGER "change_to_RP_NaturLandschaft" BEFORE INSERT OR UPDATE ON "RP_KernmodellFreiraumstruktur"."RP_NaturLandschaft" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_NaturLandschaft" AFTER DELETE ON "RP_KernmodellFreiraumstruktur"."RP_NaturLandschaft" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "RP_KernmodellFreiraumstruktur"."RP_NaturLandschaft_gebietsTyp"
-- -----------------------------------------------------
CREATE  TABLE  "RP_KernmodellFreiraumstruktur"."RP_NaturLandschaft_gebietsTyp" (
  "RP_NaturLandschaft_gid" BIGINT NOT NULL ,
  "gebietsTyp" INTEGER NOT NULL ,
  PRIMARY KEY ("RP_NaturLandschaft_gid", "gebietsTyp"),
  CONSTRAINT "fk_RP_NaturLandschaft_gebietsTyp1"
    FOREIGN KEY ("RP_NaturLandschaft_gid" )
    REFERENCES "RP_KernmodellFreiraumstruktur"."RP_NaturLandschaft" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_RP_NaturLandschaft_gebietsTyp2"
    FOREIGN KEY ("gebietsTyp" )
    REFERENCES "RP_Basisobjekte"."RP_GebietsTyp" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
GRANT SELECT ON TABLE "RP_KernmodellFreiraumstruktur"."RP_NaturLandschaft_gebietsTyp" TO xp_gast;
GRANT ALL ON TABLE "RP_KernmodellFreiraumstruktur"."RP_NaturLandschaft_gebietsTyp" TO rp_user;
COMMENT ON TABLE  "RP_KernmodellFreiraumstruktur"."RP_NaturLandschaft_gebietsTyp" IS 'Klassifikation des Gebietes nach Bundesraumordnungsgesetz.';

-- -----------------------------------------------------
-- Table "RP_KernmodellFreiraumstruktur"."RP_NaturLandschaftFlaeche"
-- -----------------------------------------------------
CREATE  TABLE  "RP_KernmodellFreiraumstruktur"."RP_NaturLandschaftFlaeche" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_RP_NaturLandschaftFlaeche_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "RP_KernmodellFreiraumstruktur"."RP_NaturLandschaft" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("RP_Basisobjekte"."RP_Flaechenobjekt");

GRANT SELECT ON TABLE "RP_KernmodellFreiraumstruktur"."RP_NaturLandschaftFlaeche" TO xp_gast;
GRANT ALL ON TABLE "RP_KernmodellFreiraumstruktur"."RP_NaturLandschaftFlaeche" TO rp_user;
COMMENT ON COLUMN "RP_KernmodellFreiraumstruktur"."RP_NaturLandschaftFlaeche"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_RP_NaturLandschaftFlaeche" BEFORE INSERT OR UPDATE ON "RP_KernmodellFreiraumstruktur"."RP_NaturLandschaftFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_NaturLandschaftFlaeche" AFTER DELETE ON "RP_KernmodellFreiraumstruktur"."RP_NaturLandschaftFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "RP_NaturLandschaftFlaeche_Flaechenobjekt" BEFORE INSERT OR UPDATE ON "RP_KernmodellFreiraumstruktur"."RP_NaturLandschaftFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."positionFollowsRHR"();

-- -----------------------------------------------------
-- Table "RP_KernmodellFreiraumstruktur"."RP_NaturLandschaftLinie"
-- -----------------------------------------------------
CREATE  TABLE  "RP_KernmodellFreiraumstruktur"."RP_NaturLandschaftLinie" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_RP_NaturLandschaftLinie_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "RP_KernmodellFreiraumstruktur"."RP_NaturLandschaft" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("RP_Basisobjekte"."RP_Linienobjekt");

GRANT SELECT ON TABLE "RP_KernmodellFreiraumstruktur"."RP_NaturLandschaftLinie" TO xp_gast;
GRANT ALL ON TABLE "RP_KernmodellFreiraumstruktur"."RP_NaturLandschaftLinie" TO rp_user;
COMMENT ON COLUMN "RP_KernmodellFreiraumstruktur"."RP_NaturLandschaftLinie"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_RP_NaturLandschaftLinie" BEFORE INSERT OR UPDATE ON "RP_KernmodellFreiraumstruktur"."RP_NaturLandschaftLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_NaturLandschaftLinie" AFTER DELETE ON "RP_KernmodellFreiraumstruktur"."RP_NaturLandschaftLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "RP_KernmodellFreiraumstruktur"."RP_NaturLandschaftPunkt"
-- -----------------------------------------------------
CREATE  TABLE  "RP_KernmodellFreiraumstruktur"."RP_NaturLandschaftPunkt" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_RP_NaturLandschaftPunkt_parent"
    FOREIGN KEY ("gid")
    REFERENCES "RP_KernmodellFreiraumstruktur"."RP_NaturLandschaft" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("RP_Basisobjekte"."RP_Punktobjekt");

GRANT SELECT ON TABLE "RP_KernmodellFreiraumstruktur"."RP_NaturLandschaftPunkt" TO xp_gast;
GRANT ALL ON TABLE "RP_KernmodellFreiraumstruktur"."RP_NaturLandschaftPunkt" TO rp_user;
COMMENT ON COLUMN "RP_KernmodellFreiraumstruktur"."RP_NaturLandschaftPunkt"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_RP_NaturLandschaftPunkt" BEFORE INSERT OR UPDATE ON "RP_KernmodellFreiraumstruktur"."RP_NaturLandschaftPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_NaturLandschaftPunkt" AFTER DELETE ON "RP_KernmodellFreiraumstruktur"."RP_NaturLandschaftPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "RP_KernmodellFreiraumstruktur"."RP_NaturschutzrechtlichesSchutzgebiet"
-- -----------------------------------------------------
CREATE  TABLE  "RP_KernmodellFreiraumstruktur"."RP_NaturschutzrechtlichesSchutzgebiet" (
  "gid" BIGINT NOT NULL ,
  "zweckbestimmung" INTEGER,
  "istAusgleichsgebiet" BOOLEAN NULL,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_RP_NaturschutzrechtlichesSchutzgebiet_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "RP_Basisobjekte"."RP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_RP_NaturschutzrechtlichesSchutzgebiet_zweckbestimmung"
    FOREIGN KEY ("zweckbestimmung")
    REFERENCES "XP_Enumerationen"."XP_KlassifizSchutzgebietNaturschutzrecht" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE);

GRANT SELECT ON TABLE "RP_KernmodellFreiraumstruktur"."RP_NaturschutzrechtlichesSchutzgebiet" TO xp_gast;
GRANT ALL ON TABLE "RP_KernmodellFreiraumstruktur"."RP_NaturschutzrechtlichesSchutzgebiet" TO rp_user;
COMMENT ON TABLE  "RP_KernmodellFreiraumstruktur"."RP_NaturschutzrechtlichesSchutzgebiet" IS 'Schutzgebiet nach Bundes-Naturschutzgesetz';
COMMENT ON COLUMN  "RP_KernmodellFreiraumstruktur"."RP_NaturschutzrechtlichesSchutzgebiet"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN  "RP_KernmodellFreiraumstruktur"."RP_NaturschutzrechtlichesSchutzgebiet"."zweckbestimmung" IS 'Klassifikation des Naturschutzgebietes.';
COMMENT ON COLUMN  "RP_KernmodellFreiraumstruktur"."RP_NaturschutzrechtlichesSchutzgebiet"."istAusgleichsgebiet" IS 'Gibt an, ob es sich um ein Ausgleichsgebiet handelt.';
CREATE TRIGGER "change_to_RP_NaturschutzrechtlichesSchutzgebiet" BEFORE INSERT OR UPDATE ON "RP_KernmodellFreiraumstruktur"."RP_NaturschutzrechtlichesSchutzgebiet" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_NaturschutzrechtlichesSchutzgebiet" AFTER DELETE ON "RP_KernmodellFreiraumstruktur"."RP_NaturschutzrechtlichesSchutzgebiet" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "RP_KernmodellFreiraumstruktur"."RP_NaturschutzrechtlichesSchutzgebietFlaeche"
-- -----------------------------------------------------
CREATE  TABLE  "RP_KernmodellFreiraumstruktur"."RP_NaturschutzrechtlichesSchutzgebietFlaeche" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_RP_NaturschutzrechtlichesSchutzgebietFlaeche_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "RP_KernmodellFreiraumstruktur"."RP_NaturschutzrechtlichesSchutzgebiet" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("RP_Basisobjekte"."RP_Flaechenobjekt");

GRANT SELECT ON TABLE "RP_KernmodellFreiraumstruktur"."RP_NaturschutzrechtlichesSchutzgebietFlaeche" TO xp_gast;
GRANT ALL ON TABLE "RP_KernmodellFreiraumstruktur"."RP_NaturschutzrechtlichesSchutzgebietFlaeche" TO rp_user;
COMMENT ON COLUMN "RP_KernmodellFreiraumstruktur"."RP_NaturschutzrechtlichesSchutzgebietFlaeche"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_RP_NaturschutzrechtlichesSchutzgebietFlaeche" BEFORE INSERT OR UPDATE ON "RP_KernmodellFreiraumstruktur"."RP_NaturschutzrechtlichesSchutzgebietFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_NaturschutzrechtlichesSchutzgebietFlaeche" AFTER DELETE ON "RP_KernmodellFreiraumstruktur"."RP_NaturschutzrechtlichesSchutzgebietFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "RP_NaturschutzrechtlichesSchutzgebietFlaeche_Flaechenobjekt" BEFORE INSERT OR UPDATE ON "RP_KernmodellFreiraumstruktur"."RP_NaturschutzrechtlichesSchutzgebietFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."positionFollowsRHR"();

-- -----------------------------------------------------
-- Table "RP_KernmodellFreiraumstruktur"."RP_NaturschutzrechtlichesSchutzgebietLinie"
-- -----------------------------------------------------
CREATE  TABLE  "RP_KernmodellFreiraumstruktur"."RP_NaturschutzrechtlichesSchutzgebietLinie" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_RP_NaturschutzrechtlichesSchutzgebietLinie_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "RP_KernmodellFreiraumstruktur"."RP_NaturschutzrechtlichesSchutzgebiet" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("RP_Basisobjekte"."RP_Linienobjekt");

GRANT SELECT ON TABLE "RP_KernmodellFreiraumstruktur"."RP_NaturschutzrechtlichesSchutzgebietLinie" TO xp_gast;
GRANT ALL ON TABLE "RP_KernmodellFreiraumstruktur"."RP_NaturschutzrechtlichesSchutzgebietLinie" TO rp_user;
COMMENT ON COLUMN "RP_KernmodellFreiraumstruktur"."RP_NaturschutzrechtlichesSchutzgebietLinie"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_RP_NaturschutzrechtlichesSchutzgebietLinie" BEFORE INSERT OR UPDATE ON "RP_KernmodellFreiraumstruktur"."RP_NaturschutzrechtlichesSchutzgebietLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_NaturschutzrechtlichesSchutzgebietLinie" AFTER DELETE ON "RP_KernmodellFreiraumstruktur"."RP_NaturschutzrechtlichesSchutzgebietLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "RP_KernmodellFreiraumstruktur"."RP_NaturschutzrechtlichesSchutzgebietPunkt"
-- -----------------------------------------------------
CREATE  TABLE  "RP_KernmodellFreiraumstruktur"."RP_NaturschutzrechtlichesSchutzgebietPunkt" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_RP_NaturschutzrechtlichesSchutzgebietPunkt_parent"
    FOREIGN KEY ("gid")
    REFERENCES "RP_KernmodellFreiraumstruktur"."RP_NaturschutzrechtlichesSchutzgebiet" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("RP_Basisobjekte"."RP_Punktobjekt");

GRANT SELECT ON TABLE "RP_KernmodellFreiraumstruktur"."RP_NaturschutzrechtlichesSchutzgebietPunkt" TO xp_gast;
GRANT ALL ON TABLE "RP_KernmodellFreiraumstruktur"."RP_NaturschutzrechtlichesSchutzgebietPunkt" TO rp_user;
COMMENT ON COLUMN "RP_KernmodellFreiraumstruktur"."RP_NaturschutzrechtlichesSchutzgebietPunkt"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_RP_NaturschutzrechtlichesSchutzgebietPunkt" BEFORE INSERT OR UPDATE ON "RP_KernmodellFreiraumstruktur"."RP_NaturschutzrechtlichesSchutzgebietPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_NaturschutzrechtlichesSchutzgebietPunkt" AFTER DELETE ON "RP_KernmodellFreiraumstruktur"."RP_NaturschutzrechtlichesSchutzgebietPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "RP_KernmodellFreiraumstruktur"."RP_Rohstoff"
-- -----------------------------------------------------
CREATE  TABLE  "RP_KernmodellFreiraumstruktur"."RP_Rohstoff" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Code") );
GRANT SELECT ON TABLE "RP_KernmodellFreiraumstruktur"."RP_Rohstoff" TO xp_gast;

-- -----------------------------------------------------
-- Table "RP_KernmodellFreiraumstruktur"."RP_Rohstoffsicherung"
-- -----------------------------------------------------
CREATE  TABLE  "RP_KernmodellFreiraumstruktur"."RP_Rohstoffsicherung" (
  "gid" BIGINT NOT NULL ,
  "abbaugut" INTEGER NULL,
  "istAusgleichsgebiet" BOOLEAN NULL,
  PRIMARY KEY ("gid"),
  CONSTRAINT "fk_RP_Rohstoffsicherung_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "RP_Basisobjekte"."RP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_RP_Rohstoffsicherung_abbaugut"
    FOREIGN KEY ("abbaugut" )
    REFERENCES "RP_KernmodellFreiraumstruktur"."RP_Rohstoff" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE);

GRANT SELECT ON TABLE "RP_KernmodellFreiraumstruktur"."RP_Rohstoffsicherung" TO xp_gast;
GRANT ALL ON TABLE "RP_KernmodellFreiraumstruktur"."RP_Rohstoffsicherung" TO rp_user;
CREATE INDEX "idx_fk_RP_Rohstoffsicherung_abbaugut" ON "RP_KernmodellFreiraumstruktur"."RP_Rohstoffsicherung" ("abbaugut") ;
COMMENT ON TABLE  "RP_KernmodellFreiraumstruktur"."RP_Rohstoffsicherung" IS 'Rohstoffsicherung';
COMMENT ON COLUMN  "RP_KernmodellFreiraumstruktur"."RP_Rohstoffsicherung"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN  "RP_KernmodellFreiraumstruktur"."RP_Rohstoffsicherung"."abbaugut" IS 'Abgebauter Rohstoff.';
COMMENT ON COLUMN  "RP_KernmodellFreiraumstruktur"."RP_Rohstoffsicherung"."istAusgleichsgebiet" IS 'Gibt an, ob es sich um ein Ausgleichsgebiet handelt.';
CREATE TRIGGER "change_to_RP_Rohstoffsicherung" BEFORE INSERT OR UPDATE ON "RP_KernmodellFreiraumstruktur"."RP_Rohstoffsicherung" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_Rohstoffsicherung" AFTER DELETE ON "RP_KernmodellFreiraumstruktur"."RP_Rohstoffsicherung" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "RP_KernmodellFreiraumstruktur"."RP_Rohstoffsicherung_gebietsTyp"
-- -----------------------------------------------------
CREATE  TABLE  "RP_KernmodellFreiraumstruktur"."RP_Rohstoffsicherung_gebietsTyp" (
  "RP_Rohstoffsicherung_gid" BIGINT NOT NULL ,
  "gebietsTyp" INTEGER NOT NULL ,
  PRIMARY KEY ("RP_Rohstoffsicherung_gid", "gebietsTyp"),
  CONSTRAINT "fk_RP_Rohstoffsicherung_gebietsTyp1"
    FOREIGN KEY ("RP_Rohstoffsicherung_gid" )
    REFERENCES "RP_KernmodellFreiraumstruktur"."RP_Rohstoffsicherung" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_RP_Rohstoffsicherung_gebietsTyp2"
    FOREIGN KEY ("gebietsTyp" )
    REFERENCES "RP_Basisobjekte"."RP_GebietsTyp" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
GRANT SELECT ON TABLE "RP_KernmodellFreiraumstruktur"."RP_Rohstoffsicherung_gebietsTyp" TO xp_gast;
GRANT ALL ON TABLE "RP_KernmodellFreiraumstruktur"."RP_Rohstoffsicherung_gebietsTyp" TO rp_user;
COMMENT ON TABLE  "RP_KernmodellFreiraumstruktur"."RP_Rohstoffsicherung_gebietsTyp" IS 'Klassifikation des Gebietes nach Bundesraumordnungsgesetz.';

-- -----------------------------------------------------
-- Table "RP_KernmodellFreiraumstruktur"."RP_RohstoffsicherungFlaeche"
-- -----------------------------------------------------
CREATE  TABLE  "RP_KernmodellFreiraumstruktur"."RP_RohstoffsicherungFlaeche" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_RP_RohstoffsicherungFlaeche_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "RP_KernmodellFreiraumstruktur"."RP_Rohstoffsicherung" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("RP_Basisobjekte"."RP_Flaechenobjekt");

GRANT SELECT ON TABLE "RP_KernmodellFreiraumstruktur"."RP_RohstoffsicherungFlaeche" TO xp_gast;
GRANT ALL ON TABLE "RP_KernmodellFreiraumstruktur"."RP_RohstoffsicherungFlaeche" TO rp_user;
COMMENT ON COLUMN "RP_KernmodellFreiraumstruktur"."RP_RohstoffsicherungFlaeche"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_RP_RohstoffsicherungFlaeche" BEFORE INSERT OR UPDATE ON "RP_KernmodellFreiraumstruktur"."RP_RohstoffsicherungFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_RohstoffsicherungFlaeche" AFTER DELETE ON "RP_KernmodellFreiraumstruktur"."RP_RohstoffsicherungFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "RP_RohstoffsicherungFlaeche_Flaechenobjekt" BEFORE INSERT OR UPDATE ON "RP_KernmodellFreiraumstruktur"."RP_RohstoffsicherungFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."positionFollowsRHR"();

-- -----------------------------------------------------
-- Table "RP_KernmodellFreiraumstruktur"."RP_RohstoffsicherungLinie"
-- -----------------------------------------------------
CREATE  TABLE  "RP_KernmodellFreiraumstruktur"."RP_RohstoffsicherungLinie" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_RP_RohstoffsicherungLinie_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "RP_KernmodellFreiraumstruktur"."RP_Rohstoffsicherung" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("RP_Basisobjekte"."RP_Linienobjekt");

GRANT SELECT ON TABLE "RP_KernmodellFreiraumstruktur"."RP_RohstoffsicherungLinie" TO xp_gast;
GRANT ALL ON TABLE "RP_KernmodellFreiraumstruktur"."RP_RohstoffsicherungLinie" TO rp_user;
COMMENT ON COLUMN "RP_KernmodellFreiraumstruktur"."RP_RohstoffsicherungLinie"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_RP_RohstoffsicherungLinie" BEFORE INSERT OR UPDATE ON "RP_KernmodellFreiraumstruktur"."RP_RohstoffsicherungLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_RohstoffsicherungLinie" AFTER DELETE ON "RP_KernmodellFreiraumstruktur"."RP_RohstoffsicherungLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "RP_KernmodellFreiraumstruktur"."RP_RohstoffsicherungPunkt"
-- -----------------------------------------------------
CREATE  TABLE  "RP_KernmodellFreiraumstruktur"."RP_RohstoffsicherungPunkt" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_RP_RohstoffsicherungPunkt_parent"
    FOREIGN KEY ("gid")
    REFERENCES "RP_KernmodellFreiraumstruktur"."RP_Rohstoffsicherung" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("RP_Basisobjekte"."RP_Punktobjekt");

GRANT SELECT ON TABLE "RP_KernmodellFreiraumstruktur"."RP_RohstoffsicherungPunkt" TO xp_gast;
GRANT ALL ON TABLE "RP_KernmodellFreiraumstruktur"."RP_RohstoffsicherungPunkt" TO rp_user;
COMMENT ON COLUMN "RP_KernmodellFreiraumstruktur"."RP_RohstoffsicherungPunkt"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_RP_RohstoffsicherungPunkt" BEFORE INSERT OR UPDATE ON "RP_KernmodellFreiraumstruktur"."RP_RohstoffsicherungPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_RohstoffsicherungPunkt" AFTER DELETE ON "RP_KernmodellFreiraumstruktur"."RP_RohstoffsicherungPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "RP_KernmodellFreiraumstruktur"."RP_SonstigerFreiraumstruktur"
-- -----------------------------------------------------
CREATE  TABLE  "RP_KernmodellFreiraumstruktur"."RP_SonstigerFreiraumstruktur" (
  "gid" BIGINT NOT NULL ,
  "istAusgleichsgebiet" BOOLEAN NULL,
  PRIMARY KEY ("gid"),
  CONSTRAINT "fk_RP_SonstigerFreiraumstruktur_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "RP_Basisobjekte"."RP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE);

GRANT SELECT ON TABLE "RP_KernmodellFreiraumstruktur"."RP_SonstigerFreiraumstruktur" TO xp_gast;
GRANT ALL ON TABLE "RP_KernmodellFreiraumstruktur"."RP_SonstigerFreiraumstruktur" TO rp_user;
COMMENT ON TABLE  "RP_KernmodellFreiraumstruktur"."RP_SonstigerFreiraumstruktur" IS 'Sonstiger Freiraumschutz';
COMMENT ON COLUMN  "RP_KernmodellFreiraumstruktur"."RP_SonstigerFreiraumstruktur"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN  "RP_KernmodellFreiraumstruktur"."RP_SonstigerFreiraumstruktur"."istAusgleichsgebiet" IS 'Gibt an, ob es sich um ein Ausgleichsgebiet handelt.';
CREATE TRIGGER "change_to_RP_SonstigerFreiraumstruktur" BEFORE INSERT OR UPDATE ON "RP_KernmodellFreiraumstruktur"."RP_SonstigerFreiraumstruktur" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_SonstigerFreiraumstruktur" AFTER DELETE ON "RP_KernmodellFreiraumstruktur"."RP_SonstigerFreiraumstruktur" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "RP_KernmodellFreiraumstruktur"."RP_SonstigerFreiraumstruktur_gebietsTyp"
-- -----------------------------------------------------
CREATE  TABLE  "RP_KernmodellFreiraumstruktur"."RP_SonstigerFreiraumstruktur_gebietsTyp" (
  "RP_SonstigerFreiraumstruktur_gid" BIGINT NOT NULL ,
  "gebietsTyp" INTEGER NOT NULL ,
  PRIMARY KEY ("RP_SonstigerFreiraumstruktur_gid", "gebietsTyp"),
  CONSTRAINT "fk_RP_SonstigerFreiraumstruktur_gebietsTyp1"
    FOREIGN KEY ("RP_SonstigerFreiraumstruktur_gid" )
    REFERENCES "RP_KernmodellFreiraumstruktur"."RP_SonstigerFreiraumstruktur" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_RP_SonstigerFreiraumstruktur_gebietsTyp2"
    FOREIGN KEY ("gebietsTyp" )
    REFERENCES "RP_Basisobjekte"."RP_GebietsTyp" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
GRANT SELECT ON TABLE "RP_KernmodellFreiraumstruktur"."RP_SonstigerFreiraumstruktur_gebietsTyp" TO xp_gast;
GRANT ALL ON TABLE "RP_KernmodellFreiraumstruktur"."RP_SonstigerFreiraumstruktur_gebietsTyp" TO rp_user;
COMMENT ON TABLE  "RP_KernmodellFreiraumstruktur"."RP_SonstigerFreiraumstruktur_gebietsTyp" IS 'Klassifikation des Gebietes nach Bundesraumordnungsgesetz.';

-- -----------------------------------------------------
-- Table "RP_KernmodellFreiraumstruktur"."RP_SonstigerFreiraumstrukturFlaeche"
-- -----------------------------------------------------
CREATE  TABLE  "RP_KernmodellFreiraumstruktur"."RP_SonstigerFreiraumstrukturFlaeche" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_RP_SonstigerFreiraumstrukturFlaeche_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "RP_KernmodellFreiraumstruktur"."RP_SonstigerFreiraumstruktur" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("RP_Basisobjekte"."RP_Flaechenobjekt");

GRANT SELECT ON TABLE "RP_KernmodellFreiraumstruktur"."RP_SonstigerFreiraumstrukturFlaeche" TO xp_gast;
GRANT ALL ON TABLE "RP_KernmodellFreiraumstruktur"."RP_SonstigerFreiraumstrukturFlaeche" TO rp_user;
COMMENT ON COLUMN "RP_KernmodellFreiraumstruktur"."RP_SonstigerFreiraumstrukturFlaeche"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_RP_SonstigerFreiraumstrukturFlaeche" BEFORE INSERT OR UPDATE ON "RP_KernmodellFreiraumstruktur"."RP_SonstigerFreiraumstrukturFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_SonstigerFreiraumstrukturFlaeche" AFTER DELETE ON "RP_KernmodellFreiraumstruktur"."RP_SonstigerFreiraumstrukturFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "RP_SonstigerFreiraumstrukturFlaeche_Flaechenobjekt" BEFORE INSERT OR UPDATE ON "RP_KernmodellFreiraumstruktur"."RP_SonstigerFreiraumstrukturFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."positionFollowsRHR"();

-- -----------------------------------------------------
-- Table "RP_KernmodellFreiraumstruktur"."RP_SonstigerFreiraumstrukturLinie"
-- -----------------------------------------------------
CREATE  TABLE  "RP_KernmodellFreiraumstruktur"."RP_SonstigerFreiraumstrukturLinie" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_RP_SonstigerFreiraumstrukturLinie_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "RP_KernmodellFreiraumstruktur"."RP_SonstigerFreiraumstruktur" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("RP_Basisobjekte"."RP_Linienobjekt");

GRANT SELECT ON TABLE "RP_KernmodellFreiraumstruktur"."RP_SonstigerFreiraumstrukturLinie" TO xp_gast;
GRANT ALL ON TABLE "RP_KernmodellFreiraumstruktur"."RP_SonstigerFreiraumstrukturLinie" TO rp_user;
COMMENT ON COLUMN "RP_KernmodellFreiraumstruktur"."RP_SonstigerFreiraumstrukturLinie"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_RP_SonstigerFreiraumstrukturLinie" BEFORE INSERT OR UPDATE ON "RP_KernmodellFreiraumstruktur"."RP_SonstigerFreiraumstrukturLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_SonstigerFreiraumstrukturLinie" AFTER DELETE ON "RP_KernmodellFreiraumstruktur"."RP_SonstigerFreiraumstrukturLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "RP_KernmodellFreiraumstruktur"."RP_SonstigerFreiraumstrukturPunkt"
-- -----------------------------------------------------
CREATE  TABLE  "RP_KernmodellFreiraumstruktur"."RP_SonstigerFreiraumstrukturPunkt" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_RP_SonstigerFreiraumstrukturPunkt_parent"
    FOREIGN KEY ("gid")
    REFERENCES "RP_KernmodellFreiraumstruktur"."RP_SonstigerFreiraumstruktur" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("RP_Basisobjekte"."RP_Punktobjekt");

GRANT SELECT ON TABLE "RP_KernmodellFreiraumstruktur"."RP_SonstigerFreiraumstrukturPunkt" TO xp_gast;
GRANT ALL ON TABLE "RP_KernmodellFreiraumstruktur"."RP_SonstigerFreiraumstrukturPunkt" TO rp_user;
COMMENT ON COLUMN "RP_KernmodellFreiraumstruktur"."RP_SonstigerFreiraumstrukturPunkt"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_RP_SonstigerFreiraumstrukturPunkt" BEFORE INSERT OR UPDATE ON "RP_KernmodellFreiraumstruktur"."RP_SonstigerFreiraumstrukturPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_SonstigerFreiraumstrukturPunkt" AFTER DELETE ON "RP_KernmodellFreiraumstruktur"."RP_SonstigerFreiraumstrukturPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "RP_KernmodellFreiraumstruktur"."RP_VorbHochwasserschutz"
-- -----------------------------------------------------
CREATE  TABLE  "RP_KernmodellFreiraumstruktur"."RP_VorbHochwasserschutz" (
  "gid" BIGINT NOT NULL ,
  "istAusgleichsgebiet" BOOLEAN NULL,
  PRIMARY KEY ("gid"),
  CONSTRAINT "fk_RP_VorbHochwasserschutz_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "RP_Basisobjekte"."RP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE);

GRANT SELECT ON TABLE "RP_KernmodellFreiraumstruktur"."RP_VorbHochwasserschutz" TO xp_gast;
GRANT ALL ON TABLE "RP_KernmodellFreiraumstruktur"."RP_VorbHochwasserschutz" TO rp_user;
COMMENT ON TABLE  "RP_KernmodellFreiraumstruktur"."RP_VorbHochwasserschutz" IS 'Vorbeugender Hochwasserschutz';
COMMENT ON COLUMN  "RP_KernmodellFreiraumstruktur"."RP_VorbHochwasserschutz"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN  "RP_KernmodellFreiraumstruktur"."RP_VorbHochwasserschutz"."istAusgleichsgebiet" IS 'Gibt an, ob es sich um ein Ausgleichsgebiet handelt.';
CREATE TRIGGER "change_to_RP_VorbHochwasserschutz" BEFORE INSERT OR UPDATE ON "RP_KernmodellFreiraumstruktur"."RP_VorbHochwasserschutz" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_VorbHochwasserschutz" AFTER DELETE ON "RP_KernmodellFreiraumstruktur"."RP_VorbHochwasserschutz" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "RP_KernmodellFreiraumstruktur"."RP_VorbHochwasserschutz_gebietsTyp"
-- -----------------------------------------------------
CREATE  TABLE  "RP_KernmodellFreiraumstruktur"."RP_VorbHochwasserschutz_gebietsTyp" (
  "RP_VorbHochwasserschutz_gid" BIGINT NOT NULL ,
  "gebietsTyp" INTEGER NOT NULL ,
  PRIMARY KEY ("RP_VorbHochwasserschutz_gid", "gebietsTyp"),
  CONSTRAINT "fk_RP_VorbHochwasserschutz_gebietsTyp1"
    FOREIGN KEY ("RP_VorbHochwasserschutz_gid" )
    REFERENCES "RP_KernmodellFreiraumstruktur"."RP_VorbHochwasserschutz" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_RP_VorbHochwasserschutz_gebietsTyp2"
    FOREIGN KEY ("gebietsTyp" )
    REFERENCES "RP_Basisobjekte"."RP_GebietsTyp" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
GRANT SELECT ON TABLE "RP_KernmodellFreiraumstruktur"."RP_VorbHochwasserschutz_gebietsTyp" TO xp_gast;
GRANT ALL ON TABLE "RP_KernmodellFreiraumstruktur"."RP_VorbHochwasserschutz_gebietsTyp" TO rp_user;
COMMENT ON TABLE  "RP_KernmodellFreiraumstruktur"."RP_VorbHochwasserschutz_gebietsTyp" IS 'Klassifikation des Gebietes nach Bundesraumordnungsgesetz.';

-- -----------------------------------------------------
-- Table "RP_KernmodellFreiraumstruktur"."RP_VorbHochwasserschutzFlaeche"
-- -----------------------------------------------------
CREATE  TABLE  "RP_KernmodellFreiraumstruktur"."RP_VorbHochwasserschutzFlaeche" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_RP_VorbHochwasserschutzFlaeche_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "RP_KernmodellFreiraumstruktur"."RP_VorbHochwasserschutz" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("RP_Basisobjekte"."RP_Flaechenobjekt");

GRANT SELECT ON TABLE "RP_KernmodellFreiraumstruktur"."RP_VorbHochwasserschutzFlaeche" TO xp_gast;
GRANT ALL ON TABLE "RP_KernmodellFreiraumstruktur"."RP_VorbHochwasserschutzFlaeche" TO rp_user;
COMMENT ON COLUMN "RP_KernmodellFreiraumstruktur"."RP_VorbHochwasserschutzFlaeche"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_RP_VorbHochwasserschutzFlaeche" BEFORE INSERT OR UPDATE ON "RP_KernmodellFreiraumstruktur"."RP_VorbHochwasserschutzFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_VorbHochwasserschutzFlaeche" AFTER DELETE ON "RP_KernmodellFreiraumstruktur"."RP_VorbHochwasserschutzFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "RP_VorbHochwasserschutzFlaeche_Flaechenobjekt" BEFORE INSERT OR UPDATE ON "RP_KernmodellFreiraumstruktur"."RP_VorbHochwasserschutzFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."positionFollowsRHR"();

-- -----------------------------------------------------
-- Table "RP_KernmodellFreiraumstruktur"."RP_VorbHochwasserschutzLinie"
-- -----------------------------------------------------
CREATE  TABLE  "RP_KernmodellFreiraumstruktur"."RP_VorbHochwasserschutzLinie" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_RP_VorbHochwasserschutzLinie_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "RP_KernmodellFreiraumstruktur"."RP_VorbHochwasserschutz" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("RP_Basisobjekte"."RP_Linienobjekt");

GRANT SELECT ON TABLE "RP_KernmodellFreiraumstruktur"."RP_VorbHochwasserschutzLinie" TO xp_gast;
GRANT ALL ON TABLE "RP_KernmodellFreiraumstruktur"."RP_VorbHochwasserschutzLinie" TO rp_user;
COMMENT ON COLUMN "RP_KernmodellFreiraumstruktur"."RP_VorbHochwasserschutzLinie"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_RP_VorbHochwasserschutzLinie" BEFORE INSERT OR UPDATE ON "RP_KernmodellFreiraumstruktur"."RP_VorbHochwasserschutzLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_VorbHochwasserschutzLinie" AFTER DELETE ON "RP_KernmodellFreiraumstruktur"."RP_VorbHochwasserschutzLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "RP_KernmodellFreiraumstruktur"."RP_VorbHochwasserschutzPunkt"
-- -----------------------------------------------------
CREATE  TABLE  "RP_KernmodellFreiraumstruktur"."RP_VorbHochwasserschutzPunkt" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_RP_VorbHochwasserschutzPunkt_parent"
    FOREIGN KEY ("gid")
    REFERENCES "RP_KernmodellFreiraumstruktur"."RP_VorbHochwasserschutz" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("RP_Basisobjekte"."RP_Punktobjekt");

GRANT SELECT ON TABLE "RP_KernmodellFreiraumstruktur"."RP_VorbHochwasserschutzPunkt" TO xp_gast;
GRANT ALL ON TABLE "RP_KernmodellFreiraumstruktur"."RP_VorbHochwasserschutzPunkt" TO rp_user;
COMMENT ON COLUMN "RP_KernmodellFreiraumstruktur"."RP_VorbHochwasserschutzPunkt"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_RP_VorbHochwasserschutzPunkt" BEFORE INSERT OR UPDATE ON "RP_KernmodellFreiraumstruktur"."RP_VorbHochwasserschutzPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_VorbHochwasserschutzPunkt" AFTER DELETE ON "RP_KernmodellFreiraumstruktur"."RP_VorbHochwasserschutzPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "RP_KernmodellFreiraumstruktur"."RP_WasserschutzZone"
-- -----------------------------------------------------
CREATE  TABLE  "RP_KernmodellFreiraumstruktur"."RP_WasserschutzZone" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Code") );
GRANT SELECT ON TABLE "RP_KernmodellFreiraumstruktur"."RP_WasserschutzZone" TO xp_gast;

-- -----------------------------------------------------
-- Table "RP_KernmodellFreiraumstruktur"."RP_Wasserschutz"
-- -----------------------------------------------------
CREATE  TABLE  "RP_KernmodellFreiraumstruktur"."RP_Wasserschutz" (
  "gid" BIGINT NOT NULL ,
  "zone" INTEGER NULL,
  "istAusgleichsgebiet" BOOLEAN NULL,
  PRIMARY KEY ("gid"),
  CONSTRAINT "fk_RP_Wasserschutz_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "RP_Basisobjekte"."RP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_RP_Wasserschutz_zone"
    FOREIGN KEY ("zone" )
    REFERENCES "RP_KernmodellFreiraumstruktur"."RP_WasserschutzZone" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE);

GRANT SELECT ON TABLE "RP_KernmodellFreiraumstruktur"."RP_Wasserschutz" TO xp_gast;
GRANT ALL ON TABLE "RP_KernmodellFreiraumstruktur"."RP_Wasserschutz" TO rp_user;
CREATE INDEX "idx_fk_RP_Wasserschutz_zone" ON "RP_KernmodellFreiraumstruktur"."RP_Wasserschutz" ("zone");
COMMENT ON TABLE  "RP_KernmodellFreiraumstruktur"."RP_Wasserschutz" IS 'Grund- und Oberflächenwasserschutz';
COMMENT ON COLUMN  "RP_KernmodellFreiraumstruktur"."RP_Wasserschutz"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN  "RP_KernmodellFreiraumstruktur"."RP_Wasserschutz"."zone" IS 'Wasserschutzzone';
COMMENT ON COLUMN  "RP_KernmodellFreiraumstruktur"."RP_Wasserschutz"."istAusgleichsgebiet" IS 'Gibt an, ob es sich um ein Ausgleichsgebiet handelt.';
CREATE TRIGGER "change_to_RP_Wasserschutz" BEFORE INSERT OR UPDATE ON "RP_KernmodellFreiraumstruktur"."RP_Wasserschutz" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_Wasserschutz" AFTER DELETE ON "RP_KernmodellFreiraumstruktur"."RP_Wasserschutz" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "RP_KernmodellFreiraumstruktur"."RP_Wasserschutz_gebietsTyp"
-- -----------------------------------------------------
CREATE  TABLE  "RP_KernmodellFreiraumstruktur"."RP_Wasserschutz_gebietsTyp" (
  "RP_Wasserschutz_gid" BIGINT NOT NULL ,
  "gebietsTyp" INTEGER NOT NULL ,
  PRIMARY KEY ("RP_Wasserschutz_gid", "gebietsTyp"),
  CONSTRAINT "fk_RP_Wasserschutz_gebietsTyp1"
    FOREIGN KEY ("RP_Wasserschutz_gid" )
    REFERENCES "RP_KernmodellFreiraumstruktur"."RP_Wasserschutz" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_RP_Wasserschutz_gebietsTyp2"
    FOREIGN KEY ("gebietsTyp" )
    REFERENCES "RP_Basisobjekte"."RP_GebietsTyp" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
GRANT SELECT ON TABLE "RP_KernmodellFreiraumstruktur"."RP_Wasserschutz_gebietsTyp" TO xp_gast;
GRANT ALL ON TABLE "RP_KernmodellFreiraumstruktur"."RP_Wasserschutz_gebietsTyp" TO rp_user;
COMMENT ON TABLE  "RP_KernmodellFreiraumstruktur"."RP_Wasserschutz_gebietsTyp" IS 'Klassifikation des Gebietes nach Bundesraumordnungsgesetz.';

-- -----------------------------------------------------
-- Table "RP_KernmodellFreiraumstruktur"."RP_WasserschutzFlaeche"
-- -----------------------------------------------------
CREATE  TABLE  "RP_KernmodellFreiraumstruktur"."RP_WasserschutzFlaeche" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_RP_WasserschutzFlaeche_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "RP_KernmodellFreiraumstruktur"."RP_Wasserschutz" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("RP_Basisobjekte"."RP_Flaechenobjekt");

GRANT SELECT ON TABLE "RP_KernmodellFreiraumstruktur"."RP_WasserschutzFlaeche" TO xp_gast;
GRANT ALL ON TABLE "RP_KernmodellFreiraumstruktur"."RP_WasserschutzFlaeche" TO rp_user;
COMMENT ON COLUMN "RP_KernmodellFreiraumstruktur"."RP_WasserschutzFlaeche"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_RP_WasserschutzFlaeche" BEFORE INSERT OR UPDATE ON "RP_KernmodellFreiraumstruktur"."RP_WasserschutzFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_WasserschutzFlaeche" AFTER DELETE ON "RP_KernmodellFreiraumstruktur"."RP_WasserschutzFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "RP_WasserschutzFlaeche_Flaechenobjekt" BEFORE INSERT OR UPDATE ON "RP_KernmodellFreiraumstruktur"."RP_WasserschutzFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."positionFollowsRHR"();

-- -----------------------------------------------------
-- Table "RP_KernmodellFreiraumstruktur"."RP_WasserschutzLinie"
-- -----------------------------------------------------
CREATE  TABLE  "RP_KernmodellFreiraumstruktur"."RP_WasserschutzLinie" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_RP_WasserschutzLinie_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "RP_KernmodellFreiraumstruktur"."RP_Wasserschutz" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("RP_Basisobjekte"."RP_Linienobjekt");

GRANT SELECT ON TABLE "RP_KernmodellFreiraumstruktur"."RP_WasserschutzLinie" TO xp_gast;
GRANT ALL ON TABLE "RP_KernmodellFreiraumstruktur"."RP_WasserschutzLinie" TO rp_user;
COMMENT ON COLUMN "RP_KernmodellFreiraumstruktur"."RP_WasserschutzLinie"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_RP_WasserschutzLinie" BEFORE INSERT OR UPDATE ON "RP_KernmodellFreiraumstruktur"."RP_WasserschutzLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_WasserschutzLinie" AFTER DELETE ON "RP_KernmodellFreiraumstruktur"."RP_WasserschutzLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "RP_KernmodellFreiraumstruktur"."RP_WasserschutzPunkt"
-- -----------------------------------------------------
CREATE  TABLE  "RP_KernmodellFreiraumstruktur"."RP_WasserschutzPunkt" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_RP_WasserschutzPunkt_parent"
    FOREIGN KEY ("gid")
    REFERENCES "RP_KernmodellFreiraumstruktur"."RP_Wasserschutz" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("RP_Basisobjekte"."RP_Punktobjekt");

GRANT SELECT ON TABLE "RP_KernmodellFreiraumstruktur"."RP_WasserschutzPunkt" TO xp_gast;
GRANT ALL ON TABLE "RP_KernmodellFreiraumstruktur"."RP_WasserschutzPunkt" TO rp_user;
COMMENT ON COLUMN "RP_KernmodellFreiraumstruktur"."RP_WasserschutzPunkt"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_RP_WasserschutzPunkt" BEFORE INSERT OR UPDATE ON "RP_KernmodellFreiraumstruktur"."RP_WasserschutzPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_WasserschutzPunkt" AFTER DELETE ON "RP_KernmodellFreiraumstruktur"."RP_WasserschutzPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "RP_KernmodellFreiraumstruktur"."RP_Windenergienutzung"
-- -----------------------------------------------------
CREATE  TABLE  "RP_KernmodellFreiraumstruktur"."RP_Windenergienutzung" (
  "gid" BIGINT NOT NULL ,
  "istAusgleichsgebiet" BOOLEAN NULL,
  PRIMARY KEY ("gid"),
  CONSTRAINT "fk_RP_Windenergienutzung_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "RP_Basisobjekte"."RP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE);

GRANT SELECT ON TABLE "RP_KernmodellFreiraumstruktur"."RP_Windenergienutzung" TO xp_gast;
GRANT ALL ON TABLE "RP_KernmodellFreiraumstruktur"."RP_Windenergienutzung" TO rp_user;
COMMENT ON TABLE  "RP_KernmodellFreiraumstruktur"."RP_Windenergienutzung" IS 'Windenergienutzung';
COMMENT ON COLUMN  "RP_KernmodellFreiraumstruktur"."RP_Windenergienutzung"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN  "RP_KernmodellFreiraumstruktur"."RP_Windenergienutzung"."istAusgleichsgebiet" IS 'Gibt an, ob es sich um ein Ausgleichsgebiet handelt.';
CREATE TRIGGER "change_to_RP_Windenergienutzung" BEFORE INSERT OR UPDATE ON "RP_KernmodellFreiraumstruktur"."RP_Windenergienutzung" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_Windenergienutzung" AFTER DELETE ON "RP_KernmodellFreiraumstruktur"."RP_Windenergienutzung" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "RP_KernmodellFreiraumstruktur"."RP_Windenergienutzung_gebietsTyp"
-- -----------------------------------------------------
CREATE  TABLE  "RP_KernmodellFreiraumstruktur"."RP_Windenergienutzung_gebietsTyp" (
  "RP_Windenergienutzung_gid" BIGINT NOT NULL ,
  "gebietsTyp" INTEGER NOT NULL ,
  PRIMARY KEY ("RP_Windenergienutzung_gid", "gebietsTyp"),
  CONSTRAINT "fk_RP_Windenergienutzung_gebietsTyp1"
    FOREIGN KEY ("RP_Windenergienutzung_gid" )
    REFERENCES "RP_KernmodellFreiraumstruktur"."RP_Windenergienutzung" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_RP_Windenergienutzung_gebietsTyp2"
    FOREIGN KEY ("gebietsTyp" )
    REFERENCES "RP_Basisobjekte"."RP_GebietsTyp" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
GRANT SELECT ON TABLE "RP_KernmodellFreiraumstruktur"."RP_Windenergienutzung_gebietsTyp" TO xp_gast;
GRANT ALL ON TABLE "RP_KernmodellFreiraumstruktur"."RP_Windenergienutzung_gebietsTyp" TO rp_user;
COMMENT ON TABLE  "RP_KernmodellFreiraumstruktur"."RP_Windenergienutzung_gebietsTyp" IS 'Klassifikation des Gebietes nach Bundesraumordnungsgesetz.';

-- -----------------------------------------------------
-- Table "RP_KernmodellFreiraumstruktur"."RP_WindenergienutzungFlaeche"
-- -----------------------------------------------------
CREATE  TABLE  "RP_KernmodellFreiraumstruktur"."RP_WindenergienutzungFlaeche" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_RP_WindenergienutzungFlaeche_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "RP_KernmodellFreiraumstruktur"."RP_Windenergienutzung" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("RP_Basisobjekte"."RP_Flaechenobjekt");

GRANT SELECT ON TABLE "RP_KernmodellFreiraumstruktur"."RP_WindenergienutzungFlaeche" TO xp_gast;
GRANT ALL ON TABLE "RP_KernmodellFreiraumstruktur"."RP_WindenergienutzungFlaeche" TO rp_user;
COMMENT ON COLUMN "RP_KernmodellFreiraumstruktur"."RP_WindenergienutzungFlaeche"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_RP_WindenergienutzungFlaeche" BEFORE INSERT OR UPDATE ON "RP_KernmodellFreiraumstruktur"."RP_WindenergienutzungFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_WindenergienutzungFlaeche" AFTER DELETE ON "RP_KernmodellFreiraumstruktur"."RP_WindenergienutzungFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "RP_WindenergienutzungFlaeche_Flaechenobjekt" BEFORE INSERT OR UPDATE ON "RP_KernmodellFreiraumstruktur"."RP_WindenergienutzungFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."positionFollowsRHR"();

-- -----------------------------------------------------
-- Table "RP_KernmodellFreiraumstruktur"."RP_WindenergienutzungLinie"
-- -----------------------------------------------------
CREATE  TABLE  "RP_KernmodellFreiraumstruktur"."RP_WindenergienutzungLinie" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_RP_WindenergienutzungLinie_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "RP_KernmodellFreiraumstruktur"."RP_Windenergienutzung" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("RP_Basisobjekte"."RP_Linienobjekt");

GRANT SELECT ON TABLE "RP_KernmodellFreiraumstruktur"."RP_WindenergienutzungLinie" TO xp_gast;
GRANT ALL ON TABLE "RP_KernmodellFreiraumstruktur"."RP_WindenergienutzungLinie" TO rp_user;
COMMENT ON COLUMN "RP_KernmodellFreiraumstruktur"."RP_WindenergienutzungLinie"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_RP_WindenergienutzungLinie" BEFORE INSERT OR UPDATE ON "RP_KernmodellFreiraumstruktur"."RP_WindenergienutzungLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_WindenergienutzungLinie" AFTER DELETE ON "RP_KernmodellFreiraumstruktur"."RP_WindenergienutzungLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "RP_KernmodellFreiraumstruktur"."RP_WindenergienutzungPunkt"
-- -----------------------------------------------------
CREATE  TABLE  "RP_KernmodellFreiraumstruktur"."RP_WindenergienutzungPunkt" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_RP_WindenergienutzungPunkt_parent"
    FOREIGN KEY ("gid")
    REFERENCES "RP_KernmodellFreiraumstruktur"."RP_Windenergienutzung" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("RP_Basisobjekte"."RP_Punktobjekt");

GRANT SELECT ON TABLE "RP_KernmodellFreiraumstruktur"."RP_WindenergienutzungPunkt" TO xp_gast;
GRANT ALL ON TABLE "RP_KernmodellFreiraumstruktur"."RP_WindenergienutzungPunkt" TO rp_user;
COMMENT ON COLUMN "RP_KernmodellFreiraumstruktur"."RP_WindenergienutzungPunkt"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_RP_WindenergienutzungPunkt" BEFORE INSERT OR UPDATE ON "RP_KernmodellFreiraumstruktur"."RP_WindenergienutzungPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_WindenergienutzungPunkt" AFTER DELETE ON "RP_KernmodellFreiraumstruktur"."RP_WindenergienutzungPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "RP_KernmodellInfrastruktur"."RP_EnergieversorgungTypen"
-- -----------------------------------------------------
CREATE  TABLE  "RP_KernmodellInfrastruktur"."RP_EnergieversorgungTypen" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Code") );
GRANT SELECT ON TABLE "RP_KernmodellInfrastruktur"."RP_EnergieversorgungTypen" TO xp_gast;

-- -----------------------------------------------------
-- Table "RP_KernmodellInfrastruktur"."RP_Energieversorgung"
-- -----------------------------------------------------
CREATE  TABLE  "RP_KernmodellInfrastruktur"."RP_Energieversorgung" (
  "gid" BIGINT NOT NULL ,
  "typ" INTEGER NULL,
  PRIMARY KEY ("gid"),
  CONSTRAINT "fk_RP_Energieversorgung_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "RP_Basisobjekte"."RP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_RP_Energieversorgung_typ"
    FOREIGN KEY ("typ" )
    REFERENCES "RP_KernmodellInfrastruktur"."RP_EnergieversorgungTypen" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE);

GRANT SELECT ON TABLE "RP_KernmodellInfrastruktur"."RP_Energieversorgung" TO xp_gast;
GRANT ALL ON TABLE "RP_KernmodellInfrastruktur"."RP_Energieversorgung" TO rp_user;
COMMENT ON TABLE  "RP_KernmodellInfrastruktur"."RP_Energieversorgung" IS 'Infrastruktur zur Energieversorgung';
COMMENT ON COLUMN  "RP_KernmodellInfrastruktur"."RP_Energieversorgung"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN  "RP_KernmodellInfrastruktur"."RP_Energieversorgung"."typ" IS 'Klassifikation von Energieversorgungs-Einrichtungen.';
CREATE TRIGGER "change_to_RP_Energieversorgung" BEFORE INSERT OR UPDATE ON "RP_KernmodellInfrastruktur"."RP_Energieversorgung" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_Energieversorgung" AFTER DELETE ON "RP_KernmodellInfrastruktur"."RP_Energieversorgung" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "RP_KernmodellInfrastruktur"."RP_Energieversorgung_gebietsTyp"
-- -----------------------------------------------------
CREATE  TABLE  "RP_KernmodellInfrastruktur"."RP_Energieversorgung_gebietsTyp" (
  "RP_Energieversorgung_gid" BIGINT NOT NULL ,
  "gebietsTyp" INTEGER NOT NULL ,
  PRIMARY KEY ("RP_Energieversorgung_gid", "gebietsTyp"),
  CONSTRAINT "fk_RP_Energieversorgung_gebietsTyp1"
    FOREIGN KEY ("RP_Energieversorgung_gid" )
    REFERENCES "RP_KernmodellInfrastruktur"."RP_Energieversorgung" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_RP_Energieversorgung_gebietsTyp2"
    FOREIGN KEY ("gebietsTyp" )
    REFERENCES "RP_Basisobjekte"."RP_GebietsTyp" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
GRANT SELECT ON TABLE "RP_KernmodellInfrastruktur"."RP_Energieversorgung_gebietsTyp" TO xp_gast;
GRANT ALL ON TABLE "RP_KernmodellInfrastruktur"."RP_Energieversorgung_gebietsTyp" TO rp_user;
COMMENT ON TABLE  "RP_KernmodellInfrastruktur"."RP_Energieversorgung_gebietsTyp" IS 'Klassifikation des Gebietes nach Bundesraumordnungsgesetz.';

-- -----------------------------------------------------
-- Table "RP_KernmodellInfrastruktur"."RP_EnergieversorgungFlaeche"
-- -----------------------------------------------------
CREATE  TABLE  "RP_KernmodellInfrastruktur"."RP_EnergieversorgungFlaeche" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_RP_EnergieversorgungFlaeche_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "RP_KernmodellInfrastruktur"."RP_Energieversorgung" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("RP_Basisobjekte"."RP_Flaechenobjekt");

GRANT SELECT ON TABLE "RP_KernmodellInfrastruktur"."RP_EnergieversorgungFlaeche" TO xp_gast;
GRANT ALL ON TABLE "RP_KernmodellInfrastruktur"."RP_EnergieversorgungFlaeche" TO rp_user;
COMMENT ON COLUMN "RP_KernmodellInfrastruktur"."RP_EnergieversorgungFlaeche"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_RP_EnergieversorgungFlaeche" BEFORE INSERT OR UPDATE ON "RP_KernmodellInfrastruktur"."RP_EnergieversorgungFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_EnergieversorgungFlaeche" AFTER DELETE ON "RP_KernmodellInfrastruktur"."RP_EnergieversorgungFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "RP_EnergieversorgungFlaeche_Flaechenobjekt" BEFORE INSERT OR UPDATE ON "RP_KernmodellInfrastruktur"."RP_EnergieversorgungFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."positionFollowsRHR"();

-- -----------------------------------------------------
-- Table "RP_KernmodellInfrastruktur"."RP_EnergieversorgungLinie"
-- -----------------------------------------------------
CREATE  TABLE  "RP_KernmodellInfrastruktur"."RP_EnergieversorgungLinie" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_RP_EnergieversorgungLinie_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "RP_KernmodellInfrastruktur"."RP_Energieversorgung" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("RP_Basisobjekte"."RP_Linienobjekt");

GRANT SELECT ON TABLE "RP_KernmodellInfrastruktur"."RP_EnergieversorgungLinie" TO xp_gast;
GRANT ALL ON TABLE "RP_KernmodellInfrastruktur"."RP_EnergieversorgungLinie" TO rp_user;
COMMENT ON COLUMN "RP_KernmodellInfrastruktur"."RP_EnergieversorgungLinie"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_RP_EnergieversorgungLinie" BEFORE INSERT OR UPDATE ON "RP_KernmodellInfrastruktur"."RP_EnergieversorgungLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_EnergieversorgungLinie" AFTER DELETE ON "RP_KernmodellInfrastruktur"."RP_EnergieversorgungLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "RP_KernmodellInfrastruktur"."RP_EnergieversorgungPunkt"
-- -----------------------------------------------------
CREATE  TABLE  "RP_KernmodellInfrastruktur"."RP_EnergieversorgungPunkt" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_RP_EnergieversorgungPunkt_parent"
    FOREIGN KEY ("gid")
    REFERENCES "RP_KernmodellInfrastruktur"."RP_Energieversorgung" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("RP_Basisobjekte"."RP_Punktobjekt");

GRANT SELECT ON TABLE "RP_KernmodellInfrastruktur"."RP_EnergieversorgungPunkt" TO xp_gast;
GRANT ALL ON TABLE "RP_KernmodellInfrastruktur"."RP_EnergieversorgungPunkt" TO rp_user;
COMMENT ON COLUMN "RP_KernmodellInfrastruktur"."RP_EnergieversorgungPunkt"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_RP_EnergieversorgungPunkt" BEFORE INSERT OR UPDATE ON "RP_KernmodellInfrastruktur"."RP_EnergieversorgungPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_EnergieversorgungPunkt" AFTER DELETE ON "RP_KernmodellInfrastruktur"."RP_EnergieversorgungPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "RP_KernmodellInfrastruktur"."RP_EntsorgungTypen"
-- -----------------------------------------------------
CREATE  TABLE  "RP_KernmodellInfrastruktur"."RP_EntsorgungTypen" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Code") );
GRANT SELECT ON TABLE "RP_KernmodellInfrastruktur"."RP_EntsorgungTypen" TO xp_gast;

-- -----------------------------------------------------
-- Table "RP_KernmodellInfrastruktur"."RP_Entsorgung"
-- -----------------------------------------------------
CREATE  TABLE  "RP_KernmodellInfrastruktur"."RP_Entsorgung" (
  "gid" BIGINT NOT NULL ,
  "typ" INTEGER NULL,
  PRIMARY KEY ("gid"),
  CONSTRAINT "fk_RP_Entsorgung_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "RP_Basisobjekte"."RP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_RP_Entsorgung_typ"
    FOREIGN KEY ("typ" )
    REFERENCES "RP_KernmodellInfrastruktur"."RP_EntsorgungTypen" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE);

GRANT SELECT ON TABLE "RP_KernmodellInfrastruktur"."RP_Entsorgung" TO xp_gast;
GRANT ALL ON TABLE "RP_KernmodellInfrastruktur"."RP_Entsorgung" TO rp_user;
COMMENT ON TABLE  "RP_KernmodellInfrastruktur"."RP_Entsorgung" IS 'Entsorgungs-Infrastruktur';
COMMENT ON COLUMN  "RP_KernmodellInfrastruktur"."RP_Entsorgung"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN  "RP_KernmodellInfrastruktur"."RP_Entsorgung"."typ" IS 'Klassifikation von Entsorgungs-Arten.';
CREATE TRIGGER "change_to_RP_Entsorgung" BEFORE INSERT OR UPDATE ON "RP_KernmodellInfrastruktur"."RP_Entsorgung" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_Entsorgung" AFTER DELETE ON "RP_KernmodellInfrastruktur"."RP_Entsorgung" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "RP_KernmodellInfrastruktur"."RP_Entsorgung_gebietsTyp"
-- -----------------------------------------------------
CREATE  TABLE  "RP_KernmodellInfrastruktur"."RP_Entsorgung_gebietsTyp" (
  "RP_Entsorgung_gid" BIGINT NOT NULL ,
  "gebietsTyp" INTEGER NOT NULL ,
  PRIMARY KEY ("RP_Entsorgung_gid", "gebietsTyp"),
  CONSTRAINT "fk_RP_Entsorgung_gebietsTyp1"
    FOREIGN KEY ("RP_Entsorgung_gid" )
    REFERENCES "RP_KernmodellInfrastruktur"."RP_Entsorgung" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_RP_Entsorgung_gebietsTyp2"
    FOREIGN KEY ("gebietsTyp" )
    REFERENCES "RP_Basisobjekte"."RP_GebietsTyp" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
GRANT SELECT ON TABLE "RP_KernmodellInfrastruktur"."RP_Entsorgung_gebietsTyp" TO xp_gast;
GRANT ALL ON TABLE "RP_KernmodellInfrastruktur"."RP_Entsorgung_gebietsTyp" TO rp_user;
COMMENT ON TABLE  "RP_KernmodellInfrastruktur"."RP_Entsorgung_gebietsTyp" IS 'Klassifikation des Gebietes nach Bundesraumordnungsgesetz.';

-- -----------------------------------------------------
-- Table "RP_KernmodellInfrastruktur"."RP_EntsorgungFlaeche"
-- -----------------------------------------------------
CREATE  TABLE  "RP_KernmodellInfrastruktur"."RP_EntsorgungFlaeche" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_RP_EntsorgungFlaeche_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "RP_KernmodellInfrastruktur"."RP_Entsorgung" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("RP_Basisobjekte"."RP_Flaechenobjekt");

GRANT SELECT ON TABLE "RP_KernmodellInfrastruktur"."RP_EntsorgungFlaeche" TO xp_gast;
GRANT ALL ON TABLE "RP_KernmodellInfrastruktur"."RP_EntsorgungFlaeche" TO rp_user;
COMMENT ON COLUMN "RP_KernmodellInfrastruktur"."RP_EntsorgungFlaeche"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_RP_EntsorgungFlaeche" BEFORE INSERT OR UPDATE ON "RP_KernmodellInfrastruktur"."RP_EntsorgungFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_EntsorgungFlaeche" AFTER DELETE ON "RP_KernmodellInfrastruktur"."RP_EntsorgungFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "RP_EntsorgungFlaeche_Flaechenobjekt" BEFORE INSERT OR UPDATE ON "RP_KernmodellInfrastruktur"."RP_EntsorgungFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."positionFollowsRHR"();

-- -----------------------------------------------------
-- Table "RP_KernmodellInfrastruktur"."RP_EntsorgungLinie"
-- -----------------------------------------------------
CREATE  TABLE  "RP_KernmodellInfrastruktur"."RP_EntsorgungLinie" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_RP_EntsorgungLinie_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "RP_KernmodellInfrastruktur"."RP_Entsorgung" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("RP_Basisobjekte"."RP_Linienobjekt");

GRANT SELECT ON TABLE "RP_KernmodellInfrastruktur"."RP_EntsorgungLinie" TO xp_gast;
GRANT ALL ON TABLE "RP_KernmodellInfrastruktur"."RP_EntsorgungLinie" TO rp_user;
COMMENT ON COLUMN "RP_KernmodellInfrastruktur"."RP_EntsorgungLinie"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_RP_EntsorgungLinie" BEFORE INSERT OR UPDATE ON "RP_KernmodellInfrastruktur"."RP_EntsorgungLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_EntsorgungLinie" AFTER DELETE ON "RP_KernmodellInfrastruktur"."RP_EntsorgungLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "RP_KernmodellInfrastruktur"."RP_EntsorgungPunkt"
-- -----------------------------------------------------
CREATE  TABLE  "RP_KernmodellInfrastruktur"."RP_EntsorgungPunkt" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_RP_EntsorgungPunkt_parent"
    FOREIGN KEY ("gid")
    REFERENCES "RP_KernmodellInfrastruktur"."RP_Entsorgung" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("RP_Basisobjekte"."RP_Punktobjekt");

GRANT SELECT ON TABLE "RP_KernmodellInfrastruktur"."RP_EntsorgungPunkt" TO xp_gast;
GRANT ALL ON TABLE "RP_KernmodellInfrastruktur"."RP_EntsorgungPunkt" TO rp_user;
COMMENT ON COLUMN "RP_KernmodellInfrastruktur"."RP_EntsorgungPunkt"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_RP_EntsorgungPunkt" BEFORE INSERT OR UPDATE ON "RP_KernmodellInfrastruktur"."RP_EntsorgungPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_EntsorgungPunkt" AFTER DELETE ON "RP_KernmodellInfrastruktur"."RP_EntsorgungPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "RP_KernmodellInfrastruktur"."RP_Kommunikation"
-- -----------------------------------------------------
CREATE  TABLE  "RP_KernmodellInfrastruktur"."RP_Kommunikation" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid"),
  CONSTRAINT "fk_RP_Kommunikation_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "RP_Basisobjekte"."RP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE);

GRANT SELECT ON TABLE "RP_KernmodellInfrastruktur"."RP_Kommunikation" TO xp_gast;
GRANT ALL ON TABLE "RP_KernmodellInfrastruktur"."RP_Kommunikation" TO rp_user;
COMMENT ON TABLE  "RP_KernmodellInfrastruktur"."RP_Kommunikation" IS 'Infrastruktur zur Telekommunikation';
COMMENT ON COLUMN  "RP_KernmodellInfrastruktur"."RP_Kommunikation"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_RP_Kommunikation" BEFORE INSERT OR UPDATE ON "RP_KernmodellInfrastruktur"."RP_Kommunikation" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_Kommunikation" AFTER DELETE ON "RP_KernmodellInfrastruktur"."RP_Kommunikation" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "RP_KernmodellInfrastruktur"."RP_Kommunikation_gebietsTyp"
-- -----------------------------------------------------
CREATE  TABLE  "RP_KernmodellInfrastruktur"."RP_Kommunikation_gebietsTyp" (
  "RP_Kommunikation_gid" BIGINT NOT NULL ,
  "gebietsTyp" INTEGER NOT NULL ,
  PRIMARY KEY ("RP_Kommunikation_gid", "gebietsTyp"),
  CONSTRAINT "fk_RP_Kommunikation_gebietsTyp1"
    FOREIGN KEY ("RP_Kommunikation_gid" )
    REFERENCES "RP_KernmodellInfrastruktur"."RP_Kommunikation" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_RP_Kommunikation_gebietsTyp2"
    FOREIGN KEY ("gebietsTyp" )
    REFERENCES "RP_Basisobjekte"."RP_GebietsTyp" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
GRANT SELECT ON TABLE "RP_KernmodellInfrastruktur"."RP_Kommunikation_gebietsTyp" TO xp_gast;
GRANT ALL ON TABLE "RP_KernmodellInfrastruktur"."RP_Kommunikation_gebietsTyp" TO rp_user;
COMMENT ON TABLE  "RP_KernmodellInfrastruktur"."RP_Kommunikation_gebietsTyp" IS 'Klassifikation des Gebietes nach Bundesraumordnungsgesetz.';

-- -----------------------------------------------------
-- Table "RP_KernmodellInfrastruktur"."RP_KommunikationFlaeche"
-- -----------------------------------------------------
CREATE  TABLE  "RP_KernmodellInfrastruktur"."RP_KommunikationFlaeche" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_RP_KommunikationFlaeche_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "RP_KernmodellInfrastruktur"."RP_Kommunikation" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("RP_Basisobjekte"."RP_Flaechenobjekt");

GRANT SELECT ON TABLE "RP_KernmodellInfrastruktur"."RP_KommunikationFlaeche" TO xp_gast;
GRANT ALL ON TABLE "RP_KernmodellInfrastruktur"."RP_KommunikationFlaeche" TO rp_user;
COMMENT ON COLUMN "RP_KernmodellInfrastruktur"."RP_KommunikationFlaeche"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_RP_KommunikationFlaeche" BEFORE INSERT OR UPDATE ON "RP_KernmodellInfrastruktur"."RP_KommunikationFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_KommunikationFlaeche" AFTER DELETE ON "RP_KernmodellInfrastruktur"."RP_KommunikationFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "RP_KommunikationFlaeche_Flaechenobjekt" BEFORE INSERT OR UPDATE ON "RP_KernmodellInfrastruktur"."RP_KommunikationFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."positionFollowsRHR"();

-- -----------------------------------------------------
-- Table "RP_KernmodellInfrastruktur"."RP_KommunikationLinie"
-- -----------------------------------------------------
CREATE  TABLE  "RP_KernmodellInfrastruktur"."RP_KommunikationLinie" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_RP_KommunikationLinie_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "RP_KernmodellInfrastruktur"."RP_Kommunikation" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("RP_Basisobjekte"."RP_Linienobjekt");

GRANT SELECT ON TABLE "RP_KernmodellInfrastruktur"."RP_KommunikationLinie" TO xp_gast;
GRANT ALL ON TABLE "RP_KernmodellInfrastruktur"."RP_KommunikationLinie" TO rp_user;
COMMENT ON COLUMN "RP_KernmodellInfrastruktur"."RP_KommunikationLinie"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_RP_KommunikationLinie" BEFORE INSERT OR UPDATE ON "RP_KernmodellInfrastruktur"."RP_KommunikationLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_KommunikationLinie" AFTER DELETE ON "RP_KernmodellInfrastruktur"."RP_KommunikationLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "RP_KernmodellInfrastruktur"."RP_KommunikationPunkt"
-- -----------------------------------------------------
CREATE  TABLE  "RP_KernmodellInfrastruktur"."RP_KommunikationPunkt" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_RP_KommunikationPunkt_parent"
    FOREIGN KEY ("gid")
    REFERENCES "RP_KernmodellInfrastruktur"."RP_Kommunikation" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("RP_Basisobjekte"."RP_Punktobjekt");

GRANT SELECT ON TABLE "RP_KernmodellInfrastruktur"."RP_KommunikationPunkt" TO xp_gast;
GRANT ALL ON TABLE "RP_KernmodellInfrastruktur"."RP_KommunikationPunkt" TO rp_user;
COMMENT ON COLUMN "RP_KernmodellInfrastruktur"."RP_KommunikationPunkt"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_RP_KommunikationPunkt" BEFORE INSERT OR UPDATE ON "RP_KernmodellInfrastruktur"."RP_KommunikationPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_KommunikationPunkt" AFTER DELETE ON "RP_KernmodellInfrastruktur"."RP_KommunikationPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "RP_KernmodellInfrastruktur"."RP_Laermschutzbereich"
-- -----------------------------------------------------
CREATE  TABLE  "RP_KernmodellInfrastruktur"."RP_Laermschutzbereich" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid"),
  CONSTRAINT "fk_RP_Laermschutzbereich_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "RP_Basisobjekte"."RP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE);

GRANT SELECT ON TABLE "RP_KernmodellInfrastruktur"."RP_Laermschutzbereich" TO xp_gast;
GRANT ALL ON TABLE "RP_KernmodellInfrastruktur"."RP_Laermschutzbereich" TO rp_user;
COMMENT ON TABLE  "RP_KernmodellInfrastruktur"."RP_Laermschutzbereich" IS 'Infrastruktur zum Lärmschutz';
COMMENT ON COLUMN  "RP_KernmodellInfrastruktur"."RP_Laermschutzbereich"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_RP_Laermschutzbereich" BEFORE INSERT OR UPDATE ON "RP_KernmodellInfrastruktur"."RP_Laermschutzbereich" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_Laermschutzbereich" AFTER DELETE ON "RP_KernmodellInfrastruktur"."RP_Laermschutzbereich" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "RP_KernmodellInfrastruktur"."RP_Laermschutzbereich_gebietsTyp"
-- -----------------------------------------------------
CREATE  TABLE  "RP_KernmodellInfrastruktur"."RP_Laermschutzbereich_gebietsTyp" (
  "RP_Laermschutzbereich_gid" BIGINT NOT NULL ,
  "gebietsTyp" INTEGER NOT NULL ,
  PRIMARY KEY ("RP_Laermschutzbereich_gid", "gebietsTyp"),
  CONSTRAINT "fk_RP_Laermschutzbereich_gebietsTyp1"
    FOREIGN KEY ("RP_Laermschutzbereich_gid" )
    REFERENCES "RP_KernmodellInfrastruktur"."RP_Laermschutzbereich" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_RP_Laermschutzbereich_gebietsTyp2"
    FOREIGN KEY ("gebietsTyp" )
    REFERENCES "RP_Basisobjekte"."RP_GebietsTyp" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
GRANT SELECT ON TABLE "RP_KernmodellInfrastruktur"."RP_Laermschutzbereich_gebietsTyp" TO xp_gast;
GRANT ALL ON TABLE "RP_KernmodellInfrastruktur"."RP_Laermschutzbereich_gebietsTyp" TO rp_user;
COMMENT ON TABLE  "RP_KernmodellInfrastruktur"."RP_Laermschutzbereich_gebietsTyp" IS 'Klassifikation des Gebietes nach Bundesraumordnungsgesetz.';

-- -----------------------------------------------------
-- Table "RP_KernmodellInfrastruktur"."RP_LaermschutzbereichFlaeche"
-- -----------------------------------------------------
CREATE  TABLE  "RP_KernmodellInfrastruktur"."RP_LaermschutzbereichFlaeche" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_RP_LaermschutzbereichFlaeche_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "RP_KernmodellInfrastruktur"."RP_Laermschutzbereich" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("RP_Basisobjekte"."RP_Flaechenobjekt");

GRANT SELECT ON TABLE "RP_KernmodellInfrastruktur"."RP_LaermschutzbereichFlaeche" TO xp_gast;
GRANT ALL ON TABLE "RP_KernmodellInfrastruktur"."RP_LaermschutzbereichFlaeche" TO rp_user;
COMMENT ON COLUMN "RP_KernmodellInfrastruktur"."RP_LaermschutzbereichFlaeche"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_RP_LaermschutzbereichFlaeche" BEFORE INSERT OR UPDATE ON "RP_KernmodellInfrastruktur"."RP_LaermschutzbereichFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_LaermschutzbereichFlaeche" AFTER DELETE ON "RP_KernmodellInfrastruktur"."RP_LaermschutzbereichFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "RP_LaermschutzbereichFlaeche_Flaechenobjekt" BEFORE INSERT OR UPDATE ON "RP_KernmodellInfrastruktur"."RP_LaermschutzbereichFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."positionFollowsRHR"();

-- -----------------------------------------------------
-- Table "RP_KernmodellInfrastruktur"."RP_LaermschutzbereichLinie"
-- -----------------------------------------------------
CREATE  TABLE  "RP_KernmodellInfrastruktur"."RP_LaermschutzbereichLinie" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_RP_LaermschutzbereichLinie_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "RP_KernmodellInfrastruktur"."RP_Laermschutzbereich" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("RP_Basisobjekte"."RP_Linienobjekt");

GRANT SELECT ON TABLE "RP_KernmodellInfrastruktur"."RP_LaermschutzbereichLinie" TO xp_gast;
GRANT ALL ON TABLE "RP_KernmodellInfrastruktur"."RP_LaermschutzbereichLinie" TO rp_user;
COMMENT ON COLUMN "RP_KernmodellInfrastruktur"."RP_LaermschutzbereichLinie"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_RP_LaermschutzbereichLinie" BEFORE INSERT OR UPDATE ON "RP_KernmodellInfrastruktur"."RP_LaermschutzbereichLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_LaermschutzbereichLinie" AFTER DELETE ON "RP_KernmodellInfrastruktur"."RP_LaermschutzbereichLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "RP_KernmodellInfrastruktur"."RP_LaermschutzbereichPunkt"
-- -----------------------------------------------------
CREATE  TABLE  "RP_KernmodellInfrastruktur"."RP_LaermschutzbereichPunkt" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_RP_LaermschutzbereichPunkt_parent"
    FOREIGN KEY ("gid")
    REFERENCES "RP_KernmodellInfrastruktur"."RP_Laermschutzbereich" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("RP_Basisobjekte"."RP_Punktobjekt");

GRANT SELECT ON TABLE "RP_KernmodellInfrastruktur"."RP_LaermschutzbereichPunkt" TO xp_gast;
GRANT ALL ON TABLE "RP_KernmodellInfrastruktur"."RP_LaermschutzbereichPunkt" TO rp_user;
COMMENT ON COLUMN "RP_KernmodellInfrastruktur"."RP_LaermschutzbereichPunkt"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_RP_LaermschutzbereichPunkt" BEFORE INSERT OR UPDATE ON "RP_KernmodellInfrastruktur"."RP_LaermschutzbereichPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_LaermschutzbereichPunkt" AFTER DELETE ON "RP_KernmodellInfrastruktur"."RP_LaermschutzbereichPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "RP_KernmodellInfrastruktur"."RP_SonstigeInfrastruktur"
-- -----------------------------------------------------
CREATE  TABLE  "RP_KernmodellInfrastruktur"."RP_SonstigeInfrastruktur" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid"),
  CONSTRAINT "fk_RP_SonstigeInfrastruktur_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "RP_Basisobjekte"."RP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE);

GRANT SELECT ON TABLE "RP_KernmodellInfrastruktur"."RP_SonstigeInfrastruktur" TO xp_gast;
GRANT ALL ON TABLE "RP_KernmodellInfrastruktur"."RP_SonstigeInfrastruktur" TO rp_user;
COMMENT ON TABLE  "RP_KernmodellInfrastruktur"."RP_SonstigeInfrastruktur" IS 'Sonstige Infrastruktur';
COMMENT ON COLUMN  "RP_KernmodellInfrastruktur"."RP_SonstigeInfrastruktur"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_RP_SonstigeInfrastruktur" BEFORE INSERT OR UPDATE ON "RP_KernmodellInfrastruktur"."RP_SonstigeInfrastruktur" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_SonstigeInfrastruktur" AFTER DELETE ON "RP_KernmodellInfrastruktur"."RP_SonstigeInfrastruktur" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "RP_KernmodellInfrastruktur"."RP_SonstigeInfrastruktur_gebietsTyp"
-- -----------------------------------------------------
CREATE  TABLE  "RP_KernmodellInfrastruktur"."RP_SonstigeInfrastruktur_gebietsTyp" (
  "RP_SonstigeInfrastruktur_gid" BIGINT NOT NULL ,
  "gebietsTyp" INTEGER NOT NULL ,
  PRIMARY KEY ("RP_SonstigeInfrastruktur_gid", "gebietsTyp"),
  CONSTRAINT "fk_RP_SonstigeInfrastruktur_gebietsTyp1"
    FOREIGN KEY ("RP_SonstigeInfrastruktur_gid" )
    REFERENCES "RP_KernmodellInfrastruktur"."RP_SonstigeInfrastruktur" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_RP_SonstigeInfrastruktur_gebietsTyp2"
    FOREIGN KEY ("gebietsTyp" )
    REFERENCES "RP_Basisobjekte"."RP_GebietsTyp" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
GRANT SELECT ON TABLE "RP_KernmodellInfrastruktur"."RP_SonstigeInfrastruktur_gebietsTyp" TO xp_gast;
GRANT ALL ON TABLE "RP_KernmodellInfrastruktur"."RP_SonstigeInfrastruktur_gebietsTyp" TO rp_user;
COMMENT ON TABLE  "RP_KernmodellInfrastruktur"."RP_SonstigeInfrastruktur_gebietsTyp" IS 'Klassifikation des Gebietes nach Bundesraumordnungsgesetz.';

-- -----------------------------------------------------
-- Table "RP_KernmodellInfrastruktur"."RP_SonstigeInfrastrukturFlaeche"
-- -----------------------------------------------------
CREATE  TABLE  "RP_KernmodellInfrastruktur"."RP_SonstigeInfrastrukturFlaeche" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_RP_SonstigeInfrastrukturFlaeche_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "RP_KernmodellInfrastruktur"."RP_SonstigeInfrastruktur" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("RP_Basisobjekte"."RP_Flaechenobjekt");

GRANT SELECT ON TABLE "RP_KernmodellInfrastruktur"."RP_SonstigeInfrastrukturFlaeche" TO xp_gast;
GRANT ALL ON TABLE "RP_KernmodellInfrastruktur"."RP_SonstigeInfrastrukturFlaeche" TO rp_user;
COMMENT ON COLUMN "RP_KernmodellInfrastruktur"."RP_SonstigeInfrastrukturFlaeche"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_RP_SonstigeInfrastrukturFlaeche" BEFORE INSERT OR UPDATE ON "RP_KernmodellInfrastruktur"."RP_SonstigeInfrastrukturFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_SonstigeInfrastrukturFlaeche" AFTER DELETE ON "RP_KernmodellInfrastruktur"."RP_SonstigeInfrastrukturFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "RP_SonstigeInfrastrukturFlaeche_Flaechenobjekt" BEFORE INSERT OR UPDATE ON "RP_KernmodellInfrastruktur"."RP_SonstigeInfrastrukturFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."positionFollowsRHR"();

-- -----------------------------------------------------
-- Table "RP_KernmodellInfrastruktur"."RP_SonstigeInfrastrukturLinie"
-- -----------------------------------------------------
CREATE  TABLE  "RP_KernmodellInfrastruktur"."RP_SonstigeInfrastrukturLinie" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_RP_SonstigeInfrastrukturLinie_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "RP_KernmodellInfrastruktur"."RP_SonstigeInfrastruktur" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("RP_Basisobjekte"."RP_Linienobjekt");

GRANT SELECT ON TABLE "RP_KernmodellInfrastruktur"."RP_SonstigeInfrastrukturLinie" TO xp_gast;
GRANT ALL ON TABLE "RP_KernmodellInfrastruktur"."RP_SonstigeInfrastrukturLinie" TO rp_user;
COMMENT ON COLUMN "RP_KernmodellInfrastruktur"."RP_SonstigeInfrastrukturLinie"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_RP_SonstigeInfrastrukturLinie" BEFORE INSERT OR UPDATE ON "RP_KernmodellInfrastruktur"."RP_SonstigeInfrastrukturLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_SonstigeInfrastrukturLinie" AFTER DELETE ON "RP_KernmodellInfrastruktur"."RP_SonstigeInfrastrukturLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "RP_KernmodellInfrastruktur"."RP_SonstigeInfrastrukturPunkt"
-- -----------------------------------------------------
CREATE  TABLE  "RP_KernmodellInfrastruktur"."RP_SonstigeInfrastrukturPunkt" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_RP_SonstigeInfrastrukturPunkt_parent"
    FOREIGN KEY ("gid")
    REFERENCES "RP_KernmodellInfrastruktur"."RP_SonstigeInfrastruktur" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("RP_Basisobjekte"."RP_Punktobjekt");

GRANT SELECT ON TABLE "RP_KernmodellInfrastruktur"."RP_SonstigeInfrastrukturPunkt" TO xp_gast;
GRANT ALL ON TABLE "RP_KernmodellInfrastruktur"."RP_SonstigeInfrastrukturPunkt" TO rp_user;
COMMENT ON COLUMN "RP_KernmodellInfrastruktur"."RP_SonstigeInfrastrukturPunkt"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_RP_SonstigeInfrastrukturPunkt" BEFORE INSERT OR UPDATE ON "RP_KernmodellInfrastruktur"."RP_SonstigeInfrastrukturPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_SonstigeInfrastrukturPunkt" AFTER DELETE ON "RP_KernmodellInfrastruktur"."RP_SonstigeInfrastrukturPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "RP_KernmodellInfrastruktur"."RP_SozialeInfrastrukturTypen"
-- -----------------------------------------------------
CREATE  TABLE  "RP_KernmodellInfrastruktur"."RP_SozialeInfrastrukturTypen" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Code") );
GRANT SELECT ON TABLE "RP_KernmodellInfrastruktur"."RP_SozialeInfrastrukturTypen" TO xp_gast;

-- -----------------------------------------------------
-- Table "RP_KernmodellInfrastruktur"."RP_SozialeInfrastruktur"
-- -----------------------------------------------------
CREATE  TABLE  "RP_KernmodellInfrastruktur"."RP_SozialeInfrastruktur" (
  "gid" BIGINT NOT NULL ,
  "typ" INTEGER NULL,
  PRIMARY KEY ("gid"),
  CONSTRAINT "fk_RP_SozialeInfrastruktur_typ"
    FOREIGN KEY ("typ" )
    REFERENCES "RP_KernmodellInfrastruktur"."RP_SozialeInfrastrukturTypen" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_RP_SozialeInfrastruktur_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "RP_Basisobjekte"."RP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE);

GRANT SELECT ON TABLE "RP_KernmodellInfrastruktur"."RP_SozialeInfrastruktur" TO xp_gast;
GRANT ALL ON TABLE "RP_KernmodellInfrastruktur"."RP_SozialeInfrastruktur" TO rp_user;
COMMENT ON TABLE  "RP_KernmodellInfrastruktur"."RP_SozialeInfrastruktur" IS 'Soziale Infrastruktur';
COMMENT ON COLUMN  "RP_KernmodellInfrastruktur"."RP_SozialeInfrastruktur"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN  "RP_KernmodellInfrastruktur"."RP_SozialeInfrastruktur"."typ" IS '';
CREATE TRIGGER "change_to_RP_SozialeInfrastruktur" BEFORE INSERT OR UPDATE ON "RP_KernmodellInfrastruktur"."RP_SozialeInfrastruktur" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_SozialeInfrastruktur" AFTER DELETE ON "RP_KernmodellInfrastruktur"."RP_SozialeInfrastruktur" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "RP_KernmodellInfrastruktur"."RP_SozialeInfrastruktur_gebietsTyp"
-- -----------------------------------------------------
CREATE  TABLE  "RP_KernmodellInfrastruktur"."RP_SozialeInfrastruktur_gebietsTyp" (
  "RP_SozialeInfrastruktur_gid" BIGINT NOT NULL ,
  "gebietsTyp" INTEGER NOT NULL ,
  PRIMARY KEY ("RP_SozialeInfrastruktur_gid", "gebietsTyp"),
  CONSTRAINT "fk_RP_SozialeInfrastruktur_gebietsTyp1"
    FOREIGN KEY ("RP_SozialeInfrastruktur_gid" )
    REFERENCES "RP_KernmodellInfrastruktur"."RP_SozialeInfrastruktur" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_RP_SozialeInfrastruktur_gebietsTyp2"
    FOREIGN KEY ("gebietsTyp" )
    REFERENCES "RP_Basisobjekte"."RP_GebietsTyp" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
GRANT SELECT ON TABLE "RP_KernmodellInfrastruktur"."RP_SozialeInfrastruktur_gebietsTyp" TO xp_gast;
GRANT ALL ON TABLE "RP_KernmodellInfrastruktur"."RP_SozialeInfrastruktur_gebietsTyp" TO rp_user;
COMMENT ON TABLE  "RP_KernmodellInfrastruktur"."RP_SozialeInfrastruktur_gebietsTyp" IS 'Klassifikation des Gebietes nach Bundesraumordnungsgesetz.';

-- -----------------------------------------------------
-- Table "RP_KernmodellInfrastruktur"."RP_SozialeInfrastrukturFlaeche"
-- -----------------------------------------------------
CREATE  TABLE  "RP_KernmodellInfrastruktur"."RP_SozialeInfrastrukturFlaeche" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_RP_SozialeInfrastrukturFlaeche_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "RP_KernmodellInfrastruktur"."RP_SozialeInfrastruktur" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("RP_Basisobjekte"."RP_Flaechenobjekt");

GRANT SELECT ON TABLE "RP_KernmodellInfrastruktur"."RP_SozialeInfrastrukturFlaeche" TO xp_gast;
GRANT ALL ON TABLE "RP_KernmodellInfrastruktur"."RP_SozialeInfrastrukturFlaeche" TO rp_user;
COMMENT ON COLUMN "RP_KernmodellInfrastruktur"."RP_SozialeInfrastrukturFlaeche"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_RP_SozialeInfrastrukturFlaeche" BEFORE INSERT OR UPDATE ON "RP_KernmodellInfrastruktur"."RP_SozialeInfrastrukturFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_SozialeInfrastrukturFlaeche" AFTER DELETE ON "RP_KernmodellInfrastruktur"."RP_SozialeInfrastrukturFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "RP_SozialeInfrastrukturFlaeche_Flaechenobjekt" BEFORE INSERT OR UPDATE ON "RP_KernmodellInfrastruktur"."RP_SozialeInfrastrukturFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."positionFollowsRHR"();

-- -----------------------------------------------------
-- Table "RP_KernmodellInfrastruktur"."RP_SozialeInfrastrukturLinie"
-- -----------------------------------------------------
CREATE  TABLE  "RP_KernmodellInfrastruktur"."RP_SozialeInfrastrukturLinie" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_RP_SozialeInfrastrukturLinie_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "RP_KernmodellInfrastruktur"."RP_SozialeInfrastruktur" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("RP_Basisobjekte"."RP_Linienobjekt");

GRANT SELECT ON TABLE "RP_KernmodellInfrastruktur"."RP_SozialeInfrastrukturLinie" TO xp_gast;
GRANT ALL ON TABLE "RP_KernmodellInfrastruktur"."RP_SozialeInfrastrukturLinie" TO rp_user;
COMMENT ON COLUMN "RP_KernmodellInfrastruktur"."RP_SozialeInfrastrukturLinie"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_RP_SozialeInfrastrukturLinie" BEFORE INSERT OR UPDATE ON "RP_KernmodellInfrastruktur"."RP_SozialeInfrastrukturLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_SozialeInfrastrukturLinie" AFTER DELETE ON "RP_KernmodellInfrastruktur"."RP_SozialeInfrastrukturLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "RP_KernmodellInfrastruktur"."RP_SozialeInfrastrukturPunkt"
-- -----------------------------------------------------
CREATE  TABLE  "RP_KernmodellInfrastruktur"."RP_SozialeInfrastrukturPunkt" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_RP_SozialeInfrastrukturPunkt_parent"
    FOREIGN KEY ("gid")
    REFERENCES "RP_KernmodellInfrastruktur"."RP_SozialeInfrastruktur" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("RP_Basisobjekte"."RP_Punktobjekt");

GRANT SELECT ON TABLE "RP_KernmodellInfrastruktur"."RP_SozialeInfrastrukturPunkt" TO xp_gast;
GRANT ALL ON TABLE "RP_KernmodellInfrastruktur"."RP_SozialeInfrastrukturPunkt" TO rp_user;
COMMENT ON COLUMN "RP_KernmodellInfrastruktur"."RP_SozialeInfrastrukturPunkt"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_RP_SozialeInfrastrukturPunkt" BEFORE INSERT OR UPDATE ON "RP_KernmodellInfrastruktur"."RP_SozialeInfrastrukturPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_SozialeInfrastrukturPunkt" AFTER DELETE ON "RP_KernmodellInfrastruktur"."RP_SozialeInfrastrukturPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "RP_KernmodellInfrastruktur"."RP_VerkehrTypen"
-- -----------------------------------------------------
CREATE  TABLE  "RP_KernmodellInfrastruktur"."RP_VerkehrTypen" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Code") );
GRANT SELECT ON TABLE "RP_KernmodellInfrastruktur"."RP_VerkehrTypen" TO xp_gast;

-- -----------------------------------------------------
-- Table "RP_KernmodellInfrastruktur"."RP_Verkehr"
-- -----------------------------------------------------
CREATE  TABLE  "RP_KernmodellInfrastruktur"."RP_Verkehr" (
  "gid" BIGINT NOT NULL ,
  "typ" INTEGER NULL,
  PRIMARY KEY ("gid"),
  CONSTRAINT "fk_RP_Verkehr_typ"
    FOREIGN KEY ("typ" )
    REFERENCES "RP_KernmodellInfrastruktur"."RP_VerkehrTypen" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_RP_Verkehr_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "RP_Basisobjekte"."RP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE);

GRANT SELECT ON TABLE "RP_KernmodellInfrastruktur"."RP_Verkehr" TO xp_gast;
GRANT ALL ON TABLE "RP_KernmodellInfrastruktur"."RP_Verkehr" TO rp_user;
COMMENT ON TABLE  "RP_KernmodellInfrastruktur"."RP_Verkehr" IS 'Verkehrs-Infrastruktur';
COMMENT ON COLUMN  "RP_KernmodellInfrastruktur"."RP_Verkehr"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN  "RP_KernmodellInfrastruktur"."RP_Verkehr"."typ" IS 'Klassifikation der Verkehrs-Arten.';
CREATE TRIGGER "change_to_RP_Verkehr" BEFORE INSERT OR UPDATE ON "RP_KernmodellInfrastruktur"."RP_Verkehr" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_Verkehr" AFTER DELETE ON "RP_KernmodellInfrastruktur"."RP_Verkehr" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "RP_KernmodellInfrastruktur"."RP_Verkehr_gebietsTyp"
-- -----------------------------------------------------
CREATE  TABLE  "RP_KernmodellInfrastruktur"."RP_Verkehr_gebietsTyp" (
  "RP_Verkehr_gid" BIGINT NOT NULL ,
  "gebietsTyp" INTEGER NOT NULL ,
  PRIMARY KEY ("RP_Verkehr_gid", "gebietsTyp"),
  CONSTRAINT "fk_RP_Verkehr_gebietsTyp1"
    FOREIGN KEY ("RP_Verkehr_gid" )
    REFERENCES "RP_KernmodellInfrastruktur"."RP_Verkehr" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_RP_Verkehr_gebietsTyp2"
    FOREIGN KEY ("gebietsTyp" )
    REFERENCES "RP_Basisobjekte"."RP_GebietsTyp" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
GRANT SELECT ON TABLE "RP_KernmodellInfrastruktur"."RP_Verkehr_gebietsTyp" TO xp_gast;
GRANT ALL ON TABLE "RP_KernmodellInfrastruktur"."RP_Verkehr_gebietsTyp" TO rp_user;
COMMENT ON TABLE  "RP_KernmodellInfrastruktur"."RP_Verkehr_gebietsTyp" IS 'Klassifikation des Gebietes nach Bundesraumordnungsgesetz.';

-- -----------------------------------------------------
-- Table "RP_KernmodellInfrastruktur"."RP_VerkehrFlaeche"
-- -----------------------------------------------------
CREATE  TABLE  "RP_KernmodellInfrastruktur"."RP_VerkehrFlaeche" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_RP_VerkehrFlaeche_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "RP_KernmodellInfrastruktur"."RP_Verkehr" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("RP_Basisobjekte"."RP_Flaechenobjekt");

GRANT SELECT ON TABLE "RP_KernmodellInfrastruktur"."RP_VerkehrFlaeche" TO xp_gast;
GRANT ALL ON TABLE "RP_KernmodellInfrastruktur"."RP_VerkehrFlaeche" TO rp_user;
COMMENT ON COLUMN "RP_KernmodellInfrastruktur"."RP_VerkehrFlaeche"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_RP_VerkehrFlaeche" BEFORE INSERT OR UPDATE ON "RP_KernmodellInfrastruktur"."RP_VerkehrFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_VerkehrFlaeche" AFTER DELETE ON "RP_KernmodellInfrastruktur"."RP_VerkehrFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "RP_VerkehrFlaeche_Flaechenobjekt" BEFORE INSERT OR UPDATE ON "RP_KernmodellInfrastruktur"."RP_VerkehrFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."positionFollowsRHR"();

-- -----------------------------------------------------
-- Table "RP_KernmodellInfrastruktur"."RP_VerkehrLinie"
-- -----------------------------------------------------
CREATE  TABLE  "RP_KernmodellInfrastruktur"."RP_VerkehrLinie" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_RP_VerkehrLinie_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "RP_KernmodellInfrastruktur"."RP_Verkehr" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("RP_Basisobjekte"."RP_Linienobjekt");

GRANT SELECT ON TABLE "RP_KernmodellInfrastruktur"."RP_VerkehrLinie" TO xp_gast;
GRANT ALL ON TABLE "RP_KernmodellInfrastruktur"."RP_VerkehrLinie" TO rp_user;
COMMENT ON COLUMN "RP_KernmodellInfrastruktur"."RP_VerkehrLinie"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_RP_VerkehrLinie" BEFORE INSERT OR UPDATE ON "RP_KernmodellInfrastruktur"."RP_VerkehrLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_VerkehrLinie" AFTER DELETE ON "RP_KernmodellInfrastruktur"."RP_VerkehrLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "RP_KernmodellInfrastruktur"."RP_VerkehrPunkt"
-- -----------------------------------------------------
CREATE  TABLE  "RP_KernmodellInfrastruktur"."RP_VerkehrPunkt" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_RP_VerkehrPunkt_parent"
    FOREIGN KEY ("gid")
    REFERENCES "RP_KernmodellInfrastruktur"."RP_Verkehr" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("RP_Basisobjekte"."RP_Punktobjekt");

GRANT SELECT ON TABLE "RP_KernmodellInfrastruktur"."RP_VerkehrPunkt" TO xp_gast;
GRANT ALL ON TABLE "RP_KernmodellInfrastruktur"."RP_VerkehrPunkt" TO rp_user;
COMMENT ON COLUMN "RP_KernmodellInfrastruktur"."RP_VerkehrPunkt"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_RP_VerkehrPunkt" BEFORE INSERT OR UPDATE ON "RP_KernmodellInfrastruktur"."RP_VerkehrPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_VerkehrPunkt" AFTER DELETE ON "RP_KernmodellInfrastruktur"."RP_VerkehrPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "RP_KernmodellInfrastruktur"."RP_WasserwirtschaftTypen"
-- -----------------------------------------------------
CREATE  TABLE  "RP_KernmodellInfrastruktur"."RP_WasserwirtschaftTypen" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Code") );
GRANT SELECT ON TABLE "RP_KernmodellInfrastruktur"."RP_WasserwirtschaftTypen" TO xp_gast;

-- -----------------------------------------------------
-- Table "RP_KernmodellInfrastruktur"."RP_Wasserwirtschaft"
-- -----------------------------------------------------
CREATE  TABLE  "RP_KernmodellInfrastruktur"."RP_Wasserwirtschaft" (
  "gid" BIGINT NOT NULL ,
  "typ" INTEGER NULL,
  PRIMARY KEY ("gid"),
  CONSTRAINT "fk_RP_Wasserwirtschaft_typ"
    FOREIGN KEY ("typ" )
    REFERENCES "RP_KernmodellInfrastruktur"."RP_WasserwirtschaftTypen" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
   CONSTRAINT "fk_RP_Wasserwirtschaft_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "RP_Basisobjekte"."RP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE);

GRANT SELECT ON TABLE "RP_KernmodellInfrastruktur"."RP_Wasserwirtschaft" TO xp_gast;
GRANT ALL ON TABLE "RP_KernmodellInfrastruktur"."RP_Wasserwirtschaft" TO rp_user;
COMMENT ON TABLE  "RP_KernmodellInfrastruktur"."RP_Wasserwirtschaft" IS 'Wasserwirtschaft';
COMMENT ON COLUMN  "RP_KernmodellInfrastruktur"."RP_Wasserwirtschaft"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN  "RP_KernmodellInfrastruktur"."RP_Wasserwirtschaft"."typ" IS 'Klasifikation von Anlagen und Einrichtungen der Wasserwirtschaft';
CREATE TRIGGER "change_to_RP_Wasserwirtschaft" BEFORE INSERT OR UPDATE ON "RP_KernmodellInfrastruktur"."RP_Wasserwirtschaft" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_Wasserwirtschaft" AFTER DELETE ON "RP_KernmodellInfrastruktur"."RP_Wasserwirtschaft" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "RP_KernmodellInfrastruktur"."RP_Wasserwirtschaft_gebietsTyp"
-- -----------------------------------------------------
CREATE  TABLE  "RP_KernmodellInfrastruktur"."RP_Wasserwirtschaft_gebietsTyp" (
  "RP_Wasserwirtschaft_gid" BIGINT NOT NULL ,
  "gebietsTyp" INTEGER NOT NULL ,
  PRIMARY KEY ("RP_Wasserwirtschaft_gid", "gebietsTyp"),
  CONSTRAINT "fk_RP_Wasserwirtschaft_gebietsTyp1"
    FOREIGN KEY ("RP_Wasserwirtschaft_gid" )
    REFERENCES "RP_KernmodellInfrastruktur"."RP_Wasserwirtschaft" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_RP_Wasserwirtschaft_gebietsTyp2"
    FOREIGN KEY ("gebietsTyp" )
    REFERENCES "RP_Basisobjekte"."RP_GebietsTyp" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
GRANT SELECT ON TABLE "RP_KernmodellInfrastruktur"."RP_Wasserwirtschaft_gebietsTyp" TO xp_gast;
GRANT ALL ON TABLE "RP_KernmodellInfrastruktur"."RP_Wasserwirtschaft_gebietsTyp" TO rp_user;
COMMENT ON TABLE  "RP_KernmodellInfrastruktur"."RP_Wasserwirtschaft_gebietsTyp" IS 'Klassifikation des Gebietes nach Bundesraumordnungsgesetz.';

-- -----------------------------------------------------
-- Table "RP_KernmodellInfrastruktur"."RP_WasserwirtschaftFlaeche"
-- -----------------------------------------------------
CREATE  TABLE  "RP_KernmodellInfrastruktur"."RP_WasserwirtschaftFlaeche" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_RP_WasserwirtschaftFlaeche_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "RP_KernmodellInfrastruktur"."RP_Wasserwirtschaft" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("RP_Basisobjekte"."RP_Flaechenobjekt");

GRANT SELECT ON TABLE "RP_KernmodellInfrastruktur"."RP_WasserwirtschaftFlaeche" TO xp_gast;
GRANT ALL ON TABLE "RP_KernmodellInfrastruktur"."RP_WasserwirtschaftFlaeche" TO rp_user;
COMMENT ON COLUMN "RP_KernmodellInfrastruktur"."RP_WasserwirtschaftFlaeche"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_RP_WasserwirtschaftFlaeche" BEFORE INSERT OR UPDATE ON "RP_KernmodellInfrastruktur"."RP_WasserwirtschaftFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_WasserwirtschaftFlaeche" AFTER DELETE ON "RP_KernmodellInfrastruktur"."RP_WasserwirtschaftFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "RP_WasserwirtschaftFlaeche_Flaechenobjekt" BEFORE INSERT OR UPDATE ON "RP_KernmodellInfrastruktur"."RP_WasserwirtschaftFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."positionFollowsRHR"();

-- -----------------------------------------------------
-- Table "RP_KernmodellInfrastruktur"."RP_WasserwirtschaftLinie"
-- -----------------------------------------------------
CREATE  TABLE  "RP_KernmodellInfrastruktur"."RP_WasserwirtschaftLinie" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_RP_WasserwirtschaftLinie_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "RP_KernmodellInfrastruktur"."RP_Wasserwirtschaft" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("RP_Basisobjekte"."RP_Linienobjekt");

GRANT SELECT ON TABLE "RP_KernmodellInfrastruktur"."RP_WasserwirtschaftLinie" TO xp_gast;
GRANT ALL ON TABLE "RP_KernmodellInfrastruktur"."RP_WasserwirtschaftLinie" TO rp_user;
COMMENT ON COLUMN "RP_KernmodellInfrastruktur"."RP_WasserwirtschaftLinie"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_RP_WasserwirtschaftLinie" BEFORE INSERT OR UPDATE ON "RP_KernmodellInfrastruktur"."RP_WasserwirtschaftLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_WasserwirtschaftLinie" AFTER DELETE ON "RP_KernmodellInfrastruktur"."RP_WasserwirtschaftLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "RP_KernmodellInfrastruktur"."RP_WasserwirtschaftPunkt"
-- -----------------------------------------------------
CREATE  TABLE  "RP_KernmodellInfrastruktur"."RP_WasserwirtschaftPunkt" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_RP_WasserwirtschaftPunkt_parent"
    FOREIGN KEY ("gid")
    REFERENCES "RP_KernmodellInfrastruktur"."RP_Wasserwirtschaft" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("RP_Basisobjekte"."RP_Punktobjekt");

GRANT SELECT ON TABLE "RP_KernmodellInfrastruktur"."RP_WasserwirtschaftPunkt" TO xp_gast;
GRANT ALL ON TABLE "RP_KernmodellInfrastruktur"."RP_WasserwirtschaftPunkt" TO rp_user;
COMMENT ON COLUMN "RP_KernmodellInfrastruktur"."RP_WasserwirtschaftPunkt"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_RP_WasserwirtschaftPunkt" BEFORE INSERT OR UPDATE ON "RP_KernmodellInfrastruktur"."RP_WasserwirtschaftPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_WasserwirtschaftPunkt" AFTER DELETE ON "RP_KernmodellInfrastruktur"."RP_WasserwirtschaftPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "RP_KernmodellSiedlungsstruktur"."RP_AchseTypen"
-- -----------------------------------------------------
CREATE  TABLE  "RP_KernmodellSiedlungsstruktur"."RP_AchseTypen" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Code") );
GRANT SELECT ON TABLE "RP_KernmodellSiedlungsstruktur"."RP_AchseTypen" TO xp_gast;

-- -----------------------------------------------------
-- Table "RP_KernmodellSiedlungsstruktur"."RP_Achse"
-- -----------------------------------------------------
CREATE  TABLE  "RP_KernmodellSiedlungsstruktur"."RP_Achse" (
  "gid" BIGINT NOT NULL ,
  "achsenTyp" INTEGER NULL,
  PRIMARY KEY ("gid"),
  CONSTRAINT "fk_RP_Achse_achsenTyp"
    FOREIGN KEY ("achsenTyp" )
    REFERENCES "RP_KernmodellSiedlungsstruktur"."RP_AchseTypen" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_RP_Achse_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "RP_Basisobjekte"."RP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("RP_Basisobjekte"."RP_Linienobjekt");

GRANT SELECT ON TABLE "RP_KernmodellSiedlungsstruktur"."RP_Achse" TO xp_gast;
GRANT ALL ON TABLE "RP_KernmodellSiedlungsstruktur"."RP_Achse" TO rp_user;
COMMENT ON TABLE  "RP_KernmodellSiedlungsstruktur"."RP_Achse" IS 'Abgrenzungen unterschiedlicher Ziel- und Zweckbestimmungen und Nutzungsarten, Abgrenzungen unterschiedlicher Biotoptypen.';
CREATE INDEX "RP_WasserrechtWirtschaftAbflussHochwSchutzLinie_gidx" ON "RP_KernmodellSiedlungsstruktur"."RP_Achse" using gist ("position");
CREATE TRIGGER "change_to_RP_WasserrechtWirtschaftAbflussHochwSchutzLinie" BEFORE INSERT OR UPDATE ON "RP_KernmodellSiedlungsstruktur"."RP_Achse" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_WasserrechtWirtschaftAbflussHochwSchutzLinie" AFTER DELETE ON "RP_KernmodellSiedlungsstruktur"."RP_Achse" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "RP_KernmodellSiedlungsstruktur"."RP_Gemeindefunktionen"
-- -----------------------------------------------------
CREATE  TABLE  "RP_KernmodellSiedlungsstruktur"."RP_Gemeindefunktionen" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Code") );
GRANT SELECT ON TABLE "RP_KernmodellSiedlungsstruktur"."RP_Gemeindefunktionen" TO xp_gast;

-- -----------------------------------------------------
-- Table "RP_KernmodellSiedlungsstruktur"."RP_GemeindeFunktionSiedlungsentwicklung"
-- -----------------------------------------------------
CREATE  TABLE  "RP_KernmodellSiedlungsstruktur"."RP_GemeindeFunktionSiedlungsentwicklung" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid"),
  CONSTRAINT "fk_RP_GemeindeFunktionSiedlungsentwicklung_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "RP_Basisobjekte"."RP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE);

GRANT SELECT ON TABLE "RP_KernmodellSiedlungsstruktur"."RP_GemeindeFunktionSiedlungsentwicklung" TO xp_gast;
GRANT ALL ON TABLE "RP_KernmodellSiedlungsstruktur"."RP_GemeindeFunktionSiedlungsentwicklung" TO rp_user;
COMMENT ON TABLE  "RP_KernmodellSiedlungsstruktur"."RP_GemeindeFunktionSiedlungsentwicklung" IS 'Infrastruktur zur Energieversorgung ';
COMMENT ON COLUMN  "RP_KernmodellSiedlungsstruktur"."RP_GemeindeFunktionSiedlungsentwicklung"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_RP_GemeindeFunktionSiedlungsentwicklung" BEFORE INSERT OR UPDATE ON "RP_KernmodellSiedlungsstruktur"."RP_GemeindeFunktionSiedlungsentwicklung" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_GemeindeFunktionSiedlungsentwicklung" AFTER DELETE ON "RP_KernmodellSiedlungsstruktur"."RP_GemeindeFunktionSiedlungsentwicklung" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "RP_KernmodellSiedlungsstruktur"."RP_GemeindeFunktionSiedlungsentwicklung_gebietsTyp"
-- -----------------------------------------------------
CREATE  TABLE  "RP_KernmodellSiedlungsstruktur"."RP_GemeindeFunktionSiedlungsentwicklung_gebietsTyp" (
  "RP_GemeindeFunktionSiedlungsentwicklung_gid" BIGINT NOT NULL ,
  "gebietsTyp" INTEGER NOT NULL ,
  PRIMARY KEY ("RP_GemeindeFunktionSiedlungsentwicklung_gid", "gebietsTyp"),
  CONSTRAINT "fk_RP_GemeindeFunktionSiedlungsentwicklung_gebietsTyp1"
    FOREIGN KEY ("RP_GemeindeFunktionSiedlungsentwicklung_gid" )
    REFERENCES "RP_KernmodellSiedlungsstruktur"."RP_GemeindeFunktionSiedlungsentwicklung" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_RP_GemeindeFunktionSiedlungsentwicklung_gebietsTyp2"
    FOREIGN KEY ("gebietsTyp" )
    REFERENCES "RP_Basisobjekte"."RP_GebietsTyp" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
GRANT SELECT ON TABLE "RP_KernmodellSiedlungsstruktur"."RP_GemeindeFunktionSiedlungsentwicklung_gebietsTyp" TO xp_gast;
GRANT ALL ON TABLE "RP_KernmodellSiedlungsstruktur"."RP_GemeindeFunktionSiedlungsentwicklung_gebietsTyp" TO rp_user;
COMMENT ON TABLE  "RP_KernmodellSiedlungsstruktur"."RP_GemeindeFunktionSiedlungsentwicklung_gebietsTyp" IS 'Klassifikation des Gebietes nach Bundesraumordnungsgesetz.';

-- -----------------------------------------------------
-- Table "RP_KernmodellSiedlungsstruktur"."RP_GemeindeFunktionSiedlungsentwicklung_funktion"
-- -----------------------------------------------------
CREATE  TABLE  "RP_KernmodellSiedlungsstruktur"."RP_GemeindeFunktionSiedlungsentwicklung_funktion" (
  "RP_GemeindeFunktionSiedlungsentwicklung_gid" BIGINT NOT NULL ,
  "funktion" INTEGER NOT NULL ,
  PRIMARY KEY ("RP_GemeindeFunktionSiedlungsentwicklung_gid", "funktion"),
  CONSTRAINT "fk_RP_GemeindeFunktionSiedlungsentwicklung_funktion1"
    FOREIGN KEY ("RP_GemeindeFunktionSiedlungsentwicklung_gid" )
    REFERENCES "RP_KernmodellSiedlungsstruktur"."RP_GemeindeFunktionSiedlungsentwicklung" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_RP_GemeindeFunktionSiedlungsentwicklung_funktion2"
    FOREIGN KEY ("funktion" )
    REFERENCES "RP_KernmodellSiedlungsstruktur"."RP_Gemeindefunktionen" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
GRANT SELECT ON TABLE "RP_KernmodellSiedlungsstruktur"."RP_GemeindeFunktionSiedlungsentwicklung_funktion" TO xp_gast;
GRANT ALL ON TABLE "RP_KernmodellSiedlungsstruktur"."RP_GemeindeFunktionSiedlungsentwicklung_funktion" TO rp_user;
COMMENT ON TABLE  "RP_KernmodellSiedlungsstruktur"."RP_GemeindeFunktionSiedlungsentwicklung_funktion" IS 'Klassifikation von Gemeindefunktionen.';

-- -----------------------------------------------------
-- Table "RP_KernmodellSiedlungsstruktur"."RP_GemeindeFunktionSiedlungsentwicklungFlaeche"
-- -----------------------------------------------------
CREATE  TABLE  "RP_KernmodellSiedlungsstruktur"."RP_GemeindeFunktionSiedlungsentwicklungFlaeche" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_RP_GemeindeFunktionSiedlungsentwicklungFlaeche_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "RP_KernmodellSiedlungsstruktur"."RP_GemeindeFunktionSiedlungsentwicklung" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("RP_Basisobjekte"."RP_Flaechenobjekt");

GRANT SELECT ON TABLE "RP_KernmodellSiedlungsstruktur"."RP_GemeindeFunktionSiedlungsentwicklungFlaeche" TO xp_gast;
GRANT ALL ON TABLE "RP_KernmodellSiedlungsstruktur"."RP_GemeindeFunktionSiedlungsentwicklungFlaeche" TO rp_user;
COMMENT ON COLUMN "RP_KernmodellSiedlungsstruktur"."RP_GemeindeFunktionSiedlungsentwicklungFlaeche"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_RP_GemeindeFunktionSiedlungsentwicklungFlaeche" BEFORE INSERT OR UPDATE ON "RP_KernmodellSiedlungsstruktur"."RP_GemeindeFunktionSiedlungsentwicklungFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_GemeindeFunktionSiedlungsentwicklungFlaeche" AFTER DELETE ON "RP_KernmodellSiedlungsstruktur"."RP_GemeindeFunktionSiedlungsentwicklungFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "RP_GemeindeFunktionSiedlungsentwicklungFlaeche_Flaechenobjekt" BEFORE INSERT OR UPDATE ON "RP_KernmodellSiedlungsstruktur"."RP_GemeindeFunktionSiedlungsentwicklungFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."positionFollowsRHR"();

-- -----------------------------------------------------
-- Table "RP_KernmodellSiedlungsstruktur"."RP_GemeindeFunktionSiedlungsentwicklungLinie"
-- -----------------------------------------------------
CREATE  TABLE  "RP_KernmodellSiedlungsstruktur"."RP_GemeindeFunktionSiedlungsentwicklungLinie" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_RP_GemeindeFunktionSiedlungsentwicklungLinie_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "RP_KernmodellSiedlungsstruktur"."RP_GemeindeFunktionSiedlungsentwicklung" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("RP_Basisobjekte"."RP_Linienobjekt");

GRANT SELECT ON TABLE "RP_KernmodellSiedlungsstruktur"."RP_GemeindeFunktionSiedlungsentwicklungLinie" TO xp_gast;
GRANT ALL ON TABLE "RP_KernmodellSiedlungsstruktur"."RP_GemeindeFunktionSiedlungsentwicklungLinie" TO rp_user;
COMMENT ON COLUMN "RP_KernmodellSiedlungsstruktur"."RP_GemeindeFunktionSiedlungsentwicklungLinie"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_RP_GemeindeFunktionSiedlungsentwicklungLinie" BEFORE INSERT OR UPDATE ON "RP_KernmodellSiedlungsstruktur"."RP_GemeindeFunktionSiedlungsentwicklungLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_GemeindeFunktionSiedlungsentwicklungLinie" AFTER DELETE ON "RP_KernmodellSiedlungsstruktur"."RP_GemeindeFunktionSiedlungsentwicklungLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "RP_KernmodellSiedlungsstruktur"."RP_GemeindeFunktionSiedlungsentwicklungPunkt"
-- -----------------------------------------------------
CREATE  TABLE  "RP_KernmodellSiedlungsstruktur"."RP_GemeindeFunktionSiedlungsentwicklungPunkt" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_RP_GemeindeFunktionSiedlungsentwicklungPunkt_parent"
    FOREIGN KEY ("gid")
    REFERENCES "RP_KernmodellSiedlungsstruktur"."RP_GemeindeFunktionSiedlungsentwicklung" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("RP_Basisobjekte"."RP_Punktobjekt");

GRANT SELECT ON TABLE "RP_KernmodellSiedlungsstruktur"."RP_GemeindeFunktionSiedlungsentwicklungPunkt" TO xp_gast;
GRANT ALL ON TABLE "RP_KernmodellSiedlungsstruktur"."RP_GemeindeFunktionSiedlungsentwicklungPunkt" TO rp_user;
COMMENT ON COLUMN "RP_KernmodellSiedlungsstruktur"."RP_GemeindeFunktionSiedlungsentwicklungPunkt"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_RP_GemeindeFunktionSiedlungsentwicklungPunkt" BEFORE INSERT OR UPDATE ON "RP_KernmodellSiedlungsstruktur"."RP_GemeindeFunktionSiedlungsentwicklungPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_GemeindeFunktionSiedlungsentwicklungPunkt" AFTER DELETE ON "RP_KernmodellSiedlungsstruktur"."RP_GemeindeFunktionSiedlungsentwicklungPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "RP_KernmodellSiedlungsstruktur"."RP_RaumkategorieFlaeche"
-- -----------------------------------------------------
CREATE  TABLE  "RP_KernmodellSiedlungsstruktur"."RP_RaumkategorieFlaeche" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_RP_RaumkategorieFlaeche_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "RP_Basisobjekte"."RP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("RP_Basisobjekte"."RP_Flaechenobjekt");

GRANT SELECT ON TABLE "RP_KernmodellSiedlungsstruktur"."RP_RaumkategorieFlaeche" TO xp_gast;
GRANT ALL ON TABLE "RP_KernmodellSiedlungsstruktur"."RP_RaumkategorieFlaeche" TO rp_user;
COMMENT ON COLUMN "RP_KernmodellSiedlungsstruktur"."RP_RaumkategorieFlaeche"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_RP_RaumkategorieFlaeche" BEFORE INSERT OR UPDATE ON "RP_KernmodellSiedlungsstruktur"."RP_RaumkategorieFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_RaumkategorieFlaeche" AFTER DELETE ON "RP_KernmodellSiedlungsstruktur"."RP_RaumkategorieFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "RP_RaumkategorieFlaeche_Flaechenobjekt" BEFORE INSERT OR UPDATE ON "RP_KernmodellSiedlungsstruktur"."RP_RaumkategorieFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."positionFollowsRHR"();

-- -----------------------------------------------------
-- Table "RP_KernmodellSiedlungsstruktur"."RP_RaumkategorieLinie"
-- -----------------------------------------------------
CREATE  TABLE  "RP_KernmodellSiedlungsstruktur"."RP_RaumkategorieLinie" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_RP_RaumkategorieLinie_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "RP_Basisobjekte"."RP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("RP_Basisobjekte"."RP_Linienobjekt");

GRANT SELECT ON TABLE "RP_KernmodellSiedlungsstruktur"."RP_RaumkategorieLinie" TO xp_gast;
GRANT ALL ON TABLE "RP_KernmodellSiedlungsstruktur"."RP_RaumkategorieLinie" TO rp_user;
COMMENT ON COLUMN "RP_KernmodellSiedlungsstruktur"."RP_RaumkategorieLinie"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_RP_RaumkategorieLinie" BEFORE INSERT OR UPDATE ON "RP_KernmodellSiedlungsstruktur"."RP_RaumkategorieLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_RaumkategorieLinie" AFTER DELETE ON "RP_KernmodellSiedlungsstruktur"."RP_RaumkategorieLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "RP_KernmodellSiedlungsstruktur"."RP_RaumkategoriePunkt"
-- -----------------------------------------------------
CREATE  TABLE  "RP_KernmodellSiedlungsstruktur"."RP_RaumkategoriePunkt" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_RP_RaumkategoriePunkt_parent"
    FOREIGN KEY ("gid")
    REFERENCES "RP_Basisobjekte"."RP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("RP_Basisobjekte"."RP_Punktobjekt");

GRANT SELECT ON TABLE "RP_KernmodellSiedlungsstruktur"."RP_RaumkategoriePunkt" TO xp_gast;
GRANT ALL ON TABLE "RP_KernmodellSiedlungsstruktur"."RP_RaumkategoriePunkt" TO rp_user;
COMMENT ON COLUMN "RP_KernmodellSiedlungsstruktur"."RP_RaumkategoriePunkt"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_RP_RaumkategoriePunkt" BEFORE INSERT OR UPDATE ON "RP_KernmodellSiedlungsstruktur"."RP_RaumkategoriePunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_RaumkategoriePunkt" AFTER DELETE ON "RP_KernmodellSiedlungsstruktur"."RP_RaumkategoriePunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "RP_KernmodellSiedlungsstruktur"."RP_SonstigeSiedlungsstruktur"
-- -----------------------------------------------------
CREATE  TABLE  "RP_KernmodellSiedlungsstruktur"."RP_SonstigeSiedlungsstruktur" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid"),
  CONSTRAINT "fk_RP_SonstigeSiedlungsstruktur_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "RP_Basisobjekte"."RP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE);

GRANT SELECT ON TABLE "RP_KernmodellSiedlungsstruktur"."RP_SonstigeSiedlungsstruktur" TO xp_gast;
GRANT ALL ON TABLE "RP_KernmodellSiedlungsstruktur"."RP_SonstigeSiedlungsstruktur" TO rp_user;
COMMENT ON TABLE  "RP_KernmodellSiedlungsstruktur"."RP_SonstigeSiedlungsstruktur" IS 'Sonstige Siedlungsstruktur';
COMMENT ON COLUMN  "RP_KernmodellSiedlungsstruktur"."RP_SonstigeSiedlungsstruktur"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_RP_SonstigeSiedlungsstruktur" BEFORE INSERT OR UPDATE ON "RP_KernmodellSiedlungsstruktur"."RP_SonstigeSiedlungsstruktur" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_SonstigeSiedlungsstruktur" AFTER DELETE ON "RP_KernmodellSiedlungsstruktur"."RP_SonstigeSiedlungsstruktur" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "RP_KernmodellSiedlungsstruktur"."RP_SonstigeSiedlungsstruktur_gebietsTyp"
-- -----------------------------------------------------
CREATE  TABLE  "RP_KernmodellSiedlungsstruktur"."RP_SonstigeSiedlungsstruktur_gebietsTyp" (
  "RP_SonstigeSiedlungsstruktur_gid" BIGINT NOT NULL ,
  "gebietsTyp" INTEGER NOT NULL ,
  PRIMARY KEY ("RP_SonstigeSiedlungsstruktur_gid", "gebietsTyp"),
  CONSTRAINT "fk_RP_SonstigeSiedlungsstruktur_gebietsTyp1"
    FOREIGN KEY ("RP_SonstigeSiedlungsstruktur_gid" )
    REFERENCES "RP_KernmodellSiedlungsstruktur"."RP_SonstigeSiedlungsstruktur" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_RP_SonstigeSiedlungsstruktur_gebietsTyp2"
    FOREIGN KEY ("gebietsTyp" )
    REFERENCES "RP_Basisobjekte"."RP_GebietsTyp" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
GRANT SELECT ON TABLE "RP_KernmodellSiedlungsstruktur"."RP_SonstigeSiedlungsstruktur_gebietsTyp" TO xp_gast;
GRANT ALL ON TABLE "RP_KernmodellSiedlungsstruktur"."RP_SonstigeSiedlungsstruktur_gebietsTyp" TO rp_user;
COMMENT ON TABLE  "RP_KernmodellSiedlungsstruktur"."RP_SonstigeSiedlungsstruktur_gebietsTyp" IS 'Klassifikation des Gebietes nach Bundesraumordnungsgesetz.';

-- -----------------------------------------------------
-- Table "RP_KernmodellSiedlungsstruktur"."RP_SonstigeSiedlungsstrukturFlaeche"
-- -----------------------------------------------------
CREATE  TABLE  "RP_KernmodellSiedlungsstruktur"."RP_SonstigeSiedlungsstrukturFlaeche" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_RP_SonstigeSiedlungsstrukturFlaeche_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "RP_KernmodellSiedlungsstruktur"."RP_SonstigeSiedlungsstruktur" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("RP_Basisobjekte"."RP_Flaechenobjekt");

GRANT SELECT ON TABLE "RP_KernmodellSiedlungsstruktur"."RP_SonstigeSiedlungsstrukturFlaeche" TO xp_gast;
GRANT ALL ON TABLE "RP_KernmodellSiedlungsstruktur"."RP_SonstigeSiedlungsstrukturFlaeche" TO rp_user;
COMMENT ON COLUMN "RP_KernmodellSiedlungsstruktur"."RP_SonstigeSiedlungsstrukturFlaeche"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_RP_SonstigeSiedlungsstrukturFlaeche" BEFORE INSERT OR UPDATE ON "RP_KernmodellSiedlungsstruktur"."RP_SonstigeSiedlungsstrukturFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_SonstigeSiedlungsstrukturFlaeche" AFTER DELETE ON "RP_KernmodellSiedlungsstruktur"."RP_SonstigeSiedlungsstrukturFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "RP_SonstigeSiedlungsstrukturFlaeche_Flaechenobjekt" BEFORE INSERT OR UPDATE ON "RP_KernmodellSiedlungsstruktur"."RP_SonstigeSiedlungsstrukturFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."positionFollowsRHR"();

-- -----------------------------------------------------
-- Table "RP_KernmodellSiedlungsstruktur"."RP_SonstigeSiedlungsstrukturLinie"
-- -----------------------------------------------------
CREATE  TABLE  "RP_KernmodellSiedlungsstruktur"."RP_SonstigeSiedlungsstrukturLinie" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_RP_SonstigeSiedlungsstrukturLinie_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "RP_KernmodellSiedlungsstruktur"."RP_SonstigeSiedlungsstruktur" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("RP_Basisobjekte"."RP_Linienobjekt");

GRANT SELECT ON TABLE "RP_KernmodellSiedlungsstruktur"."RP_SonstigeSiedlungsstrukturLinie" TO xp_gast;
GRANT ALL ON TABLE "RP_KernmodellSiedlungsstruktur"."RP_SonstigeSiedlungsstrukturLinie" TO rp_user;
COMMENT ON COLUMN "RP_KernmodellSiedlungsstruktur"."RP_SonstigeSiedlungsstrukturLinie"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_RP_SonstigeSiedlungsstrukturLinie" BEFORE INSERT OR UPDATE ON "RP_KernmodellSiedlungsstruktur"."RP_SonstigeSiedlungsstrukturLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_SonstigeSiedlungsstrukturLinie" AFTER DELETE ON "RP_KernmodellSiedlungsstruktur"."RP_SonstigeSiedlungsstrukturLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "RP_KernmodellSiedlungsstruktur"."RP_SonstigeSiedlungsstrukturPunkt"
-- -----------------------------------------------------
CREATE  TABLE  "RP_KernmodellSiedlungsstruktur"."RP_SonstigeSiedlungsstrukturPunkt" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_RP_SonstigeSiedlungsstrukturPunkt_parent"
    FOREIGN KEY ("gid")
    REFERENCES "RP_KernmodellSiedlungsstruktur"."RP_SonstigeSiedlungsstruktur" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("RP_Basisobjekte"."RP_Punktobjekt");

GRANT SELECT ON TABLE "RP_KernmodellSiedlungsstruktur"."RP_SonstigeSiedlungsstrukturPunkt" TO xp_gast;
GRANT ALL ON TABLE "RP_KernmodellSiedlungsstruktur"."RP_SonstigeSiedlungsstrukturPunkt" TO rp_user;
COMMENT ON COLUMN "RP_KernmodellSiedlungsstruktur"."RP_SonstigeSiedlungsstrukturPunkt"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_RP_SonstigeSiedlungsstrukturPunkt" BEFORE INSERT OR UPDATE ON "RP_KernmodellSiedlungsstruktur"."RP_SonstigeSiedlungsstrukturPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_SonstigeSiedlungsstrukturPunkt" AFTER DELETE ON "RP_KernmodellSiedlungsstruktur"."RP_SonstigeSiedlungsstrukturPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "RP_KernmodellSiedlungsstruktur"."RP_SperrgebietFlaeche"
-- -----------------------------------------------------
CREATE  TABLE  "RP_KernmodellSiedlungsstruktur"."RP_SperrgebietFlaeche" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_RP_SperrgebietFlaeche_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "RP_Basisobjekte"."RP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("RP_Basisobjekte"."RP_Flaechenobjekt");

GRANT SELECT ON TABLE "RP_KernmodellSiedlungsstruktur"."RP_SperrgebietFlaeche" TO xp_gast;
GRANT ALL ON TABLE "RP_KernmodellSiedlungsstruktur"."RP_SperrgebietFlaeche" TO rp_user;
COMMENT ON COLUMN "RP_KernmodellSiedlungsstruktur"."RP_SperrgebietFlaeche"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_RP_SperrgebietFlaeche" BEFORE INSERT OR UPDATE ON "RP_KernmodellSiedlungsstruktur"."RP_SperrgebietFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_SperrgebietFlaeche" AFTER DELETE ON "RP_KernmodellSiedlungsstruktur"."RP_SperrgebietFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "RP_SperrgebietFlaeche_Flaechenobjekt" BEFORE INSERT OR UPDATE ON "RP_KernmodellSiedlungsstruktur"."RP_SperrgebietFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."positionFollowsRHR"();

-- -----------------------------------------------------
-- Table "RP_KernmodellSiedlungsstruktur"."RP_SperrgebietLinie"
-- -----------------------------------------------------
CREATE  TABLE  "RP_KernmodellSiedlungsstruktur"."RP_SperrgebietLinie" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_RP_SperrgebietLinie_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "RP_Basisobjekte"."RP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("RP_Basisobjekte"."RP_Linienobjekt");

GRANT SELECT ON TABLE "RP_KernmodellSiedlungsstruktur"."RP_SperrgebietLinie" TO xp_gast;
GRANT ALL ON TABLE "RP_KernmodellSiedlungsstruktur"."RP_SperrgebietLinie" TO rp_user;
COMMENT ON COLUMN "RP_KernmodellSiedlungsstruktur"."RP_SperrgebietLinie"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_RP_SperrgebietLinie" BEFORE INSERT OR UPDATE ON "RP_KernmodellSiedlungsstruktur"."RP_SperrgebietLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_SperrgebietLinie" AFTER DELETE ON "RP_KernmodellSiedlungsstruktur"."RP_SperrgebietLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "RP_KernmodellSiedlungsstruktur"."RP_SperrgebietPunkt"
-- -----------------------------------------------------
CREATE  TABLE  "RP_KernmodellSiedlungsstruktur"."RP_SperrgebietPunkt" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_RP_SperrgebietPunkt_parent"
    FOREIGN KEY ("gid")
    REFERENCES "RP_Basisobjekte"."RP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("RP_Basisobjekte"."RP_Punktobjekt");

GRANT SELECT ON TABLE "RP_KernmodellSiedlungsstruktur"."RP_SperrgebietPunkt" TO xp_gast;
GRANT ALL ON TABLE "RP_KernmodellSiedlungsstruktur"."RP_SperrgebietPunkt" TO rp_user;
COMMENT ON COLUMN "RP_KernmodellSiedlungsstruktur"."RP_SperrgebietPunkt"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_RP_SperrgebietPunkt" BEFORE INSERT OR UPDATE ON "RP_KernmodellSiedlungsstruktur"."RP_SperrgebietPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_SperrgebietPunkt" AFTER DELETE ON "RP_KernmodellSiedlungsstruktur"."RP_SperrgebietPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "RP_KernmodellSiedlungsstruktur"."RP_ZentralerOrtFunktionen"
-- -----------------------------------------------------
CREATE  TABLE  "RP_KernmodellSiedlungsstruktur"."RP_ZentralerOrtFunktionen" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Code") );
GRANT SELECT ON TABLE "RP_KernmodellSiedlungsstruktur"."RP_ZentralerOrtFunktionen" TO xp_gast;

-- -----------------------------------------------------
-- Table "RP_KernmodellSiedlungsstruktur"."RP_ZentralerOrt"
-- -----------------------------------------------------
CREATE  TABLE  "RP_KernmodellSiedlungsstruktur"."RP_ZentralerOrt" (
  "gid" BIGINT NOT NULL ,
  "funktion" INTEGER NULL,
  PRIMARY KEY ("gid"),
  CONSTRAINT "fk_RP_ZentralerOrt_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "RP_Basisobjekte"."RP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_RP_ZentralerOrt_funktion"
    FOREIGN KEY ("funktion" )
    REFERENCES "RP_KernmodellSiedlungsstruktur"."RP_ZentralerOrtFunktionen" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE);

GRANT SELECT ON TABLE "RP_KernmodellSiedlungsstruktur"."RP_ZentralerOrt" TO xp_gast;
GRANT ALL ON TABLE "RP_KernmodellSiedlungsstruktur"."RP_ZentralerOrt" TO rp_user;
COMMENT ON TABLE  "RP_KernmodellSiedlungsstruktur"."RP_ZentralerOrt" IS 'Zentrale Orte';
COMMENT ON COLUMN  "RP_KernmodellSiedlungsstruktur"."RP_ZentralerOrt"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN  "RP_KernmodellSiedlungsstruktur"."RP_ZentralerOrt"."funktion" IS 'Klassifikation von zentralen Orten.';
CREATE TRIGGER "change_to_RP_ZentralerOrt" BEFORE INSERT OR UPDATE ON "RP_KernmodellSiedlungsstruktur"."RP_ZentralerOrt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_ZentralerOrt" AFTER DELETE ON "RP_KernmodellSiedlungsstruktur"."RP_ZentralerOrt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "RP_KernmodellSiedlungsstruktur"."RP_ZentralerOrtFlaeche"
-- -----------------------------------------------------
CREATE  TABLE  "RP_KernmodellSiedlungsstruktur"."RP_ZentralerOrtFlaeche" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_RP_ZentralerOrtFlaeche_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "RP_KernmodellSiedlungsstruktur"."RP_ZentralerOrt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("RP_Basisobjekte"."RP_Flaechenobjekt");

GRANT SELECT ON TABLE "RP_KernmodellSiedlungsstruktur"."RP_ZentralerOrtFlaeche" TO xp_gast;
GRANT ALL ON TABLE "RP_KernmodellSiedlungsstruktur"."RP_ZentralerOrtFlaeche" TO rp_user;
COMMENT ON COLUMN "RP_KernmodellSiedlungsstruktur"."RP_ZentralerOrtFlaeche"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_RP_ZentralerOrtFlaeche" BEFORE INSERT OR UPDATE ON "RP_KernmodellSiedlungsstruktur"."RP_ZentralerOrtFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_ZentralerOrtFlaeche" AFTER DELETE ON "RP_KernmodellSiedlungsstruktur"."RP_ZentralerOrtFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "RP_ZentralerOrtFlaeche_Flaechenobjekt" BEFORE INSERT OR UPDATE ON "RP_KernmodellSiedlungsstruktur"."RP_ZentralerOrtFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."positionFollowsRHR"();

-- -----------------------------------------------------
-- Table "RP_KernmodellSiedlungsstruktur"."RP_ZentralerOrtLinie"
-- -----------------------------------------------------
CREATE  TABLE  "RP_KernmodellSiedlungsstruktur"."RP_ZentralerOrtLinie" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_RP_ZentralerOrtLinie_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "RP_KernmodellSiedlungsstruktur"."RP_ZentralerOrt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("RP_Basisobjekte"."RP_Linienobjekt");

GRANT SELECT ON TABLE "RP_KernmodellSiedlungsstruktur"."RP_ZentralerOrtLinie" TO xp_gast;
GRANT ALL ON TABLE "RP_KernmodellSiedlungsstruktur"."RP_ZentralerOrtLinie" TO rp_user;
COMMENT ON COLUMN "RP_KernmodellSiedlungsstruktur"."RP_ZentralerOrtLinie"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_RP_ZentralerOrtLinie" BEFORE INSERT OR UPDATE ON "RP_KernmodellSiedlungsstruktur"."RP_ZentralerOrtLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_ZentralerOrtLinie" AFTER DELETE ON "RP_KernmodellSiedlungsstruktur"."RP_ZentralerOrtLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "RP_KernmodellSiedlungsstruktur"."RP_ZentralerOrtPunkt"
-- -----------------------------------------------------
CREATE  TABLE  "RP_KernmodellSiedlungsstruktur"."RP_ZentralerOrtPunkt" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_RP_ZentralerOrtPunkt_parent"
    FOREIGN KEY ("gid")
    REFERENCES "RP_KernmodellSiedlungsstruktur"."RP_ZentralerOrt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("RP_Basisobjekte"."RP_Punktobjekt");

GRANT SELECT ON TABLE "RP_KernmodellSiedlungsstruktur"."RP_ZentralerOrtPunkt" TO xp_gast;
GRANT ALL ON TABLE "RP_KernmodellSiedlungsstruktur"."RP_ZentralerOrtPunkt" TO rp_user;
COMMENT ON COLUMN "RP_KernmodellSiedlungsstruktur"."RP_ZentralerOrtPunkt"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_RP_ZentralerOrtPunkt" BEFORE INSERT OR UPDATE ON "RP_KernmodellSiedlungsstruktur"."RP_ZentralerOrtPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_ZentralerOrtPunkt" AFTER DELETE ON "RP_KernmodellSiedlungsstruktur"."RP_ZentralerOrtPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "RP_KernmodellSonstiges"."RP_GenerischesObjektTypen"
-- -----------------------------------------------------
CREATE TABLE "RP_KernmodellSonstiges"."RP_GenerischesObjektTypen" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Code") );
GRANT SELECT ON TABLE "RP_KernmodellSonstiges"."RP_GenerischesObjektTypen" TO xp_gast;

-- -----------------------------------------------------
-- Table "RP_KernmodellSonstiges"."RP_GenerischesObjekt"
-- -----------------------------------------------------
CREATE  TABLE  "RP_KernmodellSonstiges"."RP_GenerischesObjekt" (
  "gid" BIGINT NOT NULL ,
  "typ" INTEGER NULL,
  PRIMARY KEY ("gid"),
  CONSTRAINT "fk_RP_GenerischesObjekt_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "RP_Basisobjekte"."RP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_RP_GenerischesObjekt_typ"
    FOREIGN KEY ("typ" )
    REFERENCES "RP_KernmodellSonstiges"."RP_GenerischesObjektTypen" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE);

GRANT SELECT ON TABLE "RP_KernmodellSonstiges"."RP_GenerischesObjekt" TO xp_gast;
GRANT ALL ON TABLE "RP_KernmodellSonstiges"."RP_GenerischesObjekt" TO rp_user;
COMMENT ON TABLE  "RP_KernmodellSonstiges"."RP_GenerischesObjekt" IS 'Klasse zur Modellierung aller Inhalte des Raumordnungsplans, die durch keine andere Klasse des RPlan-Fachschemas dargestellt werden können.';
COMMENT ON COLUMN  "RP_KernmodellSonstiges"."RP_GenerischesObjekt"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN  "RP_KernmodellSonstiges"."RP_GenerischesObjekt"."typ" IS 'Über eine CodeList definierte Zweckbestimmung der Festlegung.';
CREATE TRIGGER "change_to_RP_GenerischesObjekt" BEFORE INSERT OR UPDATE ON "RP_KernmodellSonstiges"."RP_GenerischesObjekt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_GenerischesObjekt" AFTER DELETE ON "RP_KernmodellSonstiges"."RP_GenerischesObjekt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "RP_KernmodellSonstiges"."RP_GenerischesObjektFlaeche"
-- -----------------------------------------------------
CREATE  TABLE  "RP_KernmodellSonstiges"."RP_GenerischesObjektFlaeche" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_RP_GenerischesObjektFlaeche_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "RP_KernmodellSonstiges"."RP_GenerischesObjekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("RP_Basisobjekte"."RP_Flaechenobjekt");

GRANT SELECT ON TABLE "RP_KernmodellSonstiges"."RP_GenerischesObjektFlaeche" TO xp_gast;
GRANT ALL ON TABLE "RP_KernmodellSonstiges"."RP_GenerischesObjektFlaeche" TO rp_user;
COMMENT ON COLUMN "RP_KernmodellSonstiges"."RP_GenerischesObjektFlaeche"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_RP_GenerischesObjektFlaeche" BEFORE INSERT OR UPDATE ON "RP_KernmodellSonstiges"."RP_GenerischesObjektFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_GenerischesObjektFlaeche" AFTER DELETE ON "RP_KernmodellSonstiges"."RP_GenerischesObjektFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "RP_GenerischesObjektFlaeche_Flaechenobjekt" BEFORE INSERT OR UPDATE ON "RP_KernmodellSonstiges"."RP_GenerischesObjektFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."positionFollowsRHR"();

-- -----------------------------------------------------
-- Table "RP_KernmodellSonstiges"."RP_GenerischesObjektLinie"
-- -----------------------------------------------------
CREATE  TABLE  "RP_KernmodellSonstiges"."RP_GenerischesObjektLinie" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_RP_GenerischesObjektLinie_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "RP_KernmodellSonstiges"."RP_GenerischesObjekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("RP_Basisobjekte"."RP_Linienobjekt");

GRANT SELECT ON TABLE "RP_KernmodellSonstiges"."RP_GenerischesObjektLinie" TO xp_gast;
GRANT ALL ON TABLE "RP_KernmodellSonstiges"."RP_GenerischesObjektLinie" TO rp_user;
COMMENT ON COLUMN "RP_KernmodellSonstiges"."RP_GenerischesObjektLinie"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_RP_GenerischesObjektLinie" BEFORE INSERT OR UPDATE ON "RP_KernmodellSonstiges"."RP_GenerischesObjektLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_GenerischesObjektLinie" AFTER DELETE ON "RP_KernmodellSonstiges"."RP_GenerischesObjektLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "RP_KernmodellSonstiges"."RP_GenerischesObjektPunkt"
-- -----------------------------------------------------
CREATE  TABLE  "RP_KernmodellSonstiges"."RP_GenerischesObjektPunkt" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_RP_GenerischesObjektPunkt_parent"
    FOREIGN KEY ("gid")
    REFERENCES "RP_KernmodellSonstiges"."RP_GenerischesObjekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("RP_Basisobjekte"."RP_Punktobjekt");

GRANT SELECT ON TABLE "RP_KernmodellSonstiges"."RP_GenerischesObjektPunkt" TO xp_gast;
GRANT ALL ON TABLE "RP_KernmodellSonstiges"."RP_GenerischesObjektPunkt" TO rp_user;
COMMENT ON COLUMN "RP_KernmodellSonstiges"."RP_GenerischesObjektPunkt"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_RP_GenerischesObjektPunkt" BEFORE INSERT OR UPDATE ON "RP_KernmodellSonstiges"."RP_GenerischesObjektPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_GenerischesObjektPunkt" AFTER DELETE ON "RP_KernmodellSonstiges"."RP_GenerischesObjektPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "RP_KernmodellSonstiges"."RP_SonstGrenzeTypen"
-- -----------------------------------------------------
CREATE TABLE  "RP_KernmodellSonstiges"."RP_SonstGrenzeTypen" (
  "Code" INTEGER NOT NULL,
  "Bezeichner" VARCHAR(64) NOT NULL,
  PRIMARY KEY ("Code"));

GRANT SELECT ON TABLE "RP_KernmodellSonstiges"."RP_SonstGrenzeTypen" TO xp_gast;
GRANT ALL ON TABLE "RP_KernmodellSonstiges"."RP_SonstGrenzeTypen" TO so_user;

-- -----------------------------------------------------
-- Table "RP_KernmodellSonstiges"."RP_Grenze"
-- -----------------------------------------------------
CREATE TABLE  "RP_KernmodellSonstiges"."RP_Grenze" (
  "gid" BIGINT NOT NULL,
  "typ" INTEGER NULL,
  "sonstTyp" INTEGER NULL,
  PRIMARY KEY ("gid"),
  CONSTRAINT "fk_RP_Grenze_parent"
    FOREIGN KEY ("gid")
    REFERENCES "RP_Basisobjekte"."RP_Objekt" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_RP_Grenze_typ"
    FOREIGN KEY ("typ")
    REFERENCES "XP_Enumerationen"."XP_GrenzeTypen" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_RP_Grenze_sonstTyp"
    FOREIGN KEY ("sonstTyp")
    REFERENCES "RP_KernmodellSonstiges"."RP_SonstGrenzeTypen" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE)
INHERITS("RP_Basisobjekte"."RP_Linienobjekt");

CREATE INDEX "idx_fk_RP_Grenze_typ_idx" ON "RP_KernmodellSonstiges"."RP_Grenze" ("typ");
CREATE INDEX "idx_fk_RP_Grenze_sonstTyp_idx" ON "RP_KernmodellSonstiges"."RP_Grenze" ("sonstTyp");
GRANT SELECT ON TABLE "RP_KernmodellSonstiges"."RP_Grenze" TO xp_gast;
GRANT ALL ON TABLE "RP_KernmodellSonstiges"."RP_Grenze" TO rp_user;
COMMENT ON TABLE "RP_KernmodellSonstiges"."RP_Grenze" IS 'Grenzen';
COMMENT ON COLUMN "RP_KernmodellSonstiges"."RP_Grenze"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN "RP_KernmodellSonstiges"."RP_Grenze"."typ" IS 'Typ der Grenze';
COMMENT ON COLUMN "RP_KernmodellSonstiges"."RP_Grenze"."sonstTyp" IS 'Erweiterter Typ';
CREATE TRIGGER "change_to_RP_Grenze" BEFORE INSERT OR UPDATE ON "RP_KernmodellSonstiges"."RP_Grenze" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_RP_Grenze" AFTER DELETE ON "RP_KernmodellSonstiges"."RP_Grenze" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- *****************************************************
-- CREATE VIEWs
-- *****************************************************

-- -----------------------------------------------------
-- View "RP_Basisobjekte"."RP_Punktobjekte"
-- -----------------------------------------------------
CREATE  OR REPLACE VIEW "RP_Basisobjekte"."RP_Punktobjekte" AS
SELECT g.*, CAST(c.relname as varchar) as "Objektart",
CAST(n.nspname as varchar) as "Objektartengruppe"
FROM  "RP_Basisobjekte"."RP_Punktobjekt" g
JOIN pg_class c ON g.tableoid = c.oid
JOIN pg_namespace n ON c.relnamespace = n.oid;

GRANT SELECT ON TABLE "RP_Basisobjekte"."RP_Punktobjekte" TO xp_gast;
GRANT ALL ON TABLE "RP_Basisobjekte"."RP_Punktobjekte" TO rp_user;

CREATE OR REPLACE RULE _update AS
    ON UPDATE TO "RP_Basisobjekte"."RP_Punktobjekte" DO INSTEAD  UPDATE "RP_Basisobjekte"."RP_Punktobjekt" SET "position" = new."position"
  WHERE gid = old.gid;
CREATE OR REPLACE RULE _delete AS
    ON DELETE TO "RP_Basisobjekte"."RP_Punktobjekte" DO INSTEAD  DELETE FROM "RP_Basisobjekte"."RP_Punktobjekt"
  WHERE gid = old.gid;

-- -----------------------------------------------------
-- View "RP_Basisobjekte"."RP_Linienobjekte"
-- -----------------------------------------------------
CREATE  OR REPLACE VIEW "RP_Basisobjekte"."RP_Linienobjekte" AS
SELECT g.*, CAST(c.relname as varchar) as "Objektart",
CAST(n.nspname as varchar) as "Objektartengruppe"
FROM  "RP_Basisobjekte"."RP_Linienobjekt" g
JOIN pg_class c ON g.tableoid = c.oid
JOIN pg_namespace n ON c.relnamespace = n.oid;

GRANT SELECT ON TABLE "RP_Basisobjekte"."RP_Linienobjekte" TO xp_gast;
GRANT ALL ON TABLE "RP_Basisobjekte"."RP_Linienobjekte" TO rp_user;

CREATE OR REPLACE RULE _update AS
    ON UPDATE TO "RP_Basisobjekte"."RP_Linienobjekte" DO INSTEAD  UPDATE "RP_Basisobjekte"."RP_Linienobjekt" SET "position" = new."position"
  WHERE gid = old.gid;
CREATE OR REPLACE RULE _delete AS
    ON DELETE TO "RP_Basisobjekte"."RP_Linienobjekte" DO INSTEAD  DELETE FROM "RP_Basisobjekte"."RP_Linienobjekt"
  WHERE gid = old.gid;

-- -----------------------------------------------------
-- View "RP_Basisobjekte"."RP_Flaechenobjekte"
-- -----------------------------------------------------
CREATE  OR REPLACE VIEW "RP_Basisobjekte"."RP_Flaechenobjekte" AS
SELECT g.*, CAST(c.relname as varchar) as "Objektart",
CAST(n.nspname as varchar) as "Objektartengruppe"
FROM  "RP_Basisobjekte"."RP_Flaechenobjekt" g
JOIN pg_class c ON g.tableoid = c.oid
JOIN pg_namespace n ON c.relnamespace = n.oid;

GRANT SELECT ON TABLE "RP_Basisobjekte"."RP_Flaechenobjekte" TO xp_gast;
GRANT ALL ON TABLE "RP_Basisobjekte"."RP_Flaechenobjekte" TO rp_user;

CREATE OR REPLACE RULE _update AS
    ON UPDATE TO "RP_Basisobjekte"."RP_Flaechenobjekte" DO INSTEAD  UPDATE "RP_Basisobjekte"."RP_Flaechenobjekt" SET "position" = new."position"
  WHERE gid = old.gid;
CREATE OR REPLACE RULE _delete AS
    ON DELETE TO "RP_Basisobjekte"."RP_Flaechenobjekte" DO INSTEAD  DELETE FROM "RP_Basisobjekte"."RP_Flaechenobjekt"
  WHERE gid = old.gid;

-- -----------------------------------------------------
-- View "RP_Basisobjekte"."RP_Objekte"
-- -----------------------------------------------------
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

-- *****************************************************
-- DATA
-- *****************************************************

-- -----------------------------------------------------
-- Data for table public."XP_Modellbereich"
-- -----------------------------------------------------
INSERT INTO public."XP_Modellbereich" ("Kurz", "Modellbereich") VALUES ('RP', 'Regionalplan Kernmodell');

-- -----------------------------------------------------
-- Data for table "RP_Basisobjekte"."RP_PlanArt"
-- -----------------------------------------------------
INSERT INTO "RP_Basisobjekte"."RP_PlanArt" ("Code", "Bezeichner") VALUES (1000, 'Regionalplan');
INSERT INTO "RP_Basisobjekte"."RP_PlanArt" ("Code", "Bezeichner") VALUES (2000, 'SachlicherTeilplanRegionalebene');
INSERT INTO "RP_Basisobjekte"."RP_PlanArt" ("Code", "Bezeichner") VALUES (2001, 'SachlicherTeilplanLandesebene');
INSERT INTO "RP_Basisobjekte"."RP_PlanArt" ("Code", "Bezeichner") VALUES (3000, 'Braunkohlenplan');
INSERT INTO "RP_Basisobjekte"."RP_PlanArt" ("Code", "Bezeichner") VALUES (4000, 'LandesweiterRaumordnungsplan');
INSERT INTO "RP_Basisobjekte"."RP_PlanArt" ("Code", "Bezeichner") VALUES (5000, 'StandortkonzeptBund');
INSERT INTO "RP_Basisobjekte"."RP_PlanArt" ("Code", "Bezeichner") VALUES (5001, 'AWZPlan');
INSERT INTO "RP_Basisobjekte"."RP_PlanArt" ("Code", "Bezeichner") VALUES (6000, 'RaeumlicherTeilplan');
INSERT INTO "RP_Basisobjekte"."RP_PlanArt" ("Code", "Bezeichner") VALUES (9999, 'Sonstiges');

-- -----------------------------------------------------
-- Data for table "RP_Basisobjekte"."RP_Rechtsstand"
-- -----------------------------------------------------
INSERT INTO "RP_Basisobjekte"."RP_Rechtsstand" ("Code", "Bezeichner") VALUES (1000, 'Aufstellungsbeschluss');
INSERT INTO "RP_Basisobjekte"."RP_Rechtsstand" ("Code", "Bezeichner") VALUES (2000, 'Entwurf');
INSERT INTO "RP_Basisobjekte"."RP_Rechtsstand" ("Code", "Bezeichner") VALUES (3000, 'Plan');
INSERT INTO "RP_Basisobjekte"."RP_Rechtsstand" ("Code", "Bezeichner") VALUES (4000, 'Inkraftgetreten');
INSERT INTO "RP_Basisobjekte"."RP_Rechtsstand" ("Code", "Bezeichner") VALUES (5000, 'Untergegangen');

-- -----------------------------------------------------
-- Data for table "RP_Basisobjekte"."RP_Rechtscharakter"
-- -----------------------------------------------------
INSERT INTO "RP_Basisobjekte"."RP_Rechtscharakter" ("Code", "Bezeichner") VALUES ('1000', 'ZielDerRaumordnung');
INSERT INTO "RP_Basisobjekte"."RP_Rechtscharakter" ("Code", "Bezeichner") VALUES ('2000', 'GrundsatzDerRaumordnung');
INSERT INTO "RP_Basisobjekte"."RP_Rechtscharakter" ("Code", "Bezeichner") VALUES ('3000', 'NachrichtlicheUbernahme');
INSERT INTO "RP_Basisobjekte"."RP_Rechtscharakter" ("Code", "Bezeichner") VALUES ('4000', 'NachrichtlicheUebernahmeZiel');
INSERT INTO "RP_Basisobjekte"."RP_Rechtscharakter" ("Code", "Bezeichner") VALUES ('5000', 'NachrichtlicheUebernahmeGrundsatz');
INSERT INTO "RP_Basisobjekte"."RP_Rechtscharakter" ("Code", "Bezeichner") VALUES ('6000', 'NurInformationsgehalt');
INSERT INTO "RP_Basisobjekte"."RP_Rechtscharakter" ("Code", "Bezeichner") VALUES ('7000', 'TextlichesZiel');
INSERT INTO "RP_Basisobjekte"."RP_Rechtscharakter" ("Code", "Bezeichner") VALUES ('8000', 'ZielundGrundsatz');
INSERT INTO "RP_Basisobjekte"."RP_Rechtscharakter" ("Code", "Bezeichner") VALUES ('9000', 'Vorschlag');
INSERT INTO "RP_Basisobjekte"."RP_Rechtscharakter" ("Code", "Bezeichner") VALUES ('9998', 'Unbekannt');

-- -----------------------------------------------------
-- Data for table "RP_Basisobjekte"."RP_GebietsTyp"
-- -----------------------------------------------------
INSERT INTO "RP_Basisobjekte"."RP_GebietsTyp" ("Code", "Bezeichner") VALUES ('1000', 'Vorranggebiet');
INSERT INTO "RP_Basisobjekte"."RP_GebietsTyp" ("Code", "Bezeichner") VALUES ('2000', 'Vorbehaltsgebiet');
INSERT INTO "RP_Basisobjekte"."RP_GebietsTyp" ("Code", "Bezeichner") VALUES ('3000', 'Eignungsgebiet');
INSERT INTO "RP_Basisobjekte"."RP_GebietsTyp" ("Code", "Bezeichner") VALUES ('4000', 'Ausschlussgebiet');
INSERT INTO "RP_Basisobjekte"."RP_GebietsTyp" ("Code", "Bezeichner") VALUES ('5000', 'SonstigesGebiet');

-- -----------------------------------------------------
-- Data for table "RP_KernmodellFreiraumstruktur"."RP_Rohstoff"
-- -----------------------------------------------------
INSERT INTO "RP_KernmodellFreiraumstruktur"."RP_Rohstoff" ("Code", "Bezeichner") VALUES ('1000', 'Anhydridstein');
INSERT INTO "RP_KernmodellFreiraumstruktur"."RP_Rohstoff" ("Code", "Bezeichner") VALUES ('1100', 'Baryt');
INSERT INTO "RP_KernmodellFreiraumstruktur"."RP_Rohstoff" ("Code", "Bezeichner") VALUES ('1200', 'BasaltDiabas');
INSERT INTO "RP_KernmodellFreiraumstruktur"."RP_Rohstoff" ("Code", "Bezeichner") VALUES ('1300', 'Bentonit');
INSERT INTO "RP_KernmodellFreiraumstruktur"."RP_Rohstoff" ("Code", "Bezeichner") VALUES ('1400', 'Blaehton');
INSERT INTO "RP_KernmodellFreiraumstruktur"."RP_Rohstoff" ("Code", "Bezeichner") VALUES ('1500', 'Braunkohle');
INSERT INTO "RP_KernmodellFreiraumstruktur"."RP_Rohstoff" ("Code", "Bezeichner") VALUES ('1600', 'Bundsandstein');
INSERT INTO "RP_KernmodellFreiraumstruktur"."RP_Rohstoff" ("Code", "Bezeichner") VALUES ('1700', 'Diorit');
INSERT INTO "RP_KernmodellFreiraumstruktur"."RP_Rohstoff" ("Code", "Bezeichner") VALUES ('1800', 'Dolomitstein');
INSERT INTO "RP_KernmodellFreiraumstruktur"."RP_Rohstoff" ("Code", "Bezeichner") VALUES ('1900', 'Erdgas');
INSERT INTO "RP_KernmodellFreiraumstruktur"."RP_Rohstoff" ("Code", "Bezeichner") VALUES ('2000', 'Erdoel');
INSERT INTO "RP_KernmodellFreiraumstruktur"."RP_Rohstoff" ("Code", "Bezeichner") VALUES ('2100', 'Erz');
INSERT INTO "RP_KernmodellFreiraumstruktur"."RP_Rohstoff" ("Code", "Bezeichner") VALUES ('2200', 'Feldspat');
INSERT INTO "RP_KernmodellFreiraumstruktur"."RP_Rohstoff" ("Code", "Bezeichner") VALUES ('2300', 'Flussspat');
INSERT INTO "RP_KernmodellFreiraumstruktur"."RP_Rohstoff" ("Code", "Bezeichner") VALUES ('2400', 'Gangquarz');
INSERT INTO "RP_KernmodellFreiraumstruktur"."RP_Rohstoff" ("Code", "Bezeichner") VALUES ('2500', 'Gipsstein');
INSERT INTO "RP_KernmodellFreiraumstruktur"."RP_Rohstoff" ("Code", "Bezeichner") VALUES ('2600', 'Granit');
INSERT INTO "RP_KernmodellFreiraumstruktur"."RP_Rohstoff" ("Code", "Bezeichner") VALUES ('2800', 'Grauwacke');
INSERT INTO "RP_KernmodellFreiraumstruktur"."RP_Rohstoff" ("Code", "Bezeichner") VALUES ('2900', 'KalkKalktuffKreide');
INSERT INTO "RP_KernmodellFreiraumstruktur"."RP_Rohstoff" ("Code", "Bezeichner") VALUES ('3000', 'Kalkmergelstein');
INSERT INTO "RP_KernmodellFreiraumstruktur"."RP_Rohstoff" ("Code", "Bezeichner") VALUES ('3100', 'Kalkstein');
INSERT INTO "RP_KernmodellFreiraumstruktur"."RP_Rohstoff" ("Code", "Bezeichner") VALUES ('3200', 'Karbonatgestein');
INSERT INTO "RP_KernmodellFreiraumstruktur"."RP_Rohstoff" ("Code", "Bezeichner") VALUES ('3300', 'KiesSand');
INSERT INTO "RP_KernmodellFreiraumstruktur"."RP_Rohstoff" ("Code", "Bezeichner") VALUES ('3400', 'Kieselgur');
INSERT INTO "RP_KernmodellFreiraumstruktur"."RP_Rohstoff" ("Code", "Bezeichner") VALUES ('3500', 'Kristallin');
INSERT INTO "RP_KernmodellFreiraumstruktur"."RP_Rohstoff" ("Code", "Bezeichner") VALUES ('3600', 'Kupfer');
INSERT INTO "RP_KernmodellFreiraumstruktur"."RP_Rohstoff" ("Code", "Bezeichner") VALUES ('3700', 'Lehm');
INSERT INTO "RP_KernmodellFreiraumstruktur"."RP_Rohstoff" ("Code", "Bezeichner") VALUES ('3800', 'Mergel');
INSERT INTO "RP_KernmodellFreiraumstruktur"."RP_Rohstoff" ("Code", "Bezeichner") VALUES ('3900', 'Mergelstein');
INSERT INTO "RP_KernmodellFreiraumstruktur"."RP_Rohstoff" ("Code", "Bezeichner") VALUES ('4100', 'Muschelkalk');
INSERT INTO "RP_KernmodellFreiraumstruktur"."RP_Rohstoff" ("Code", "Bezeichner") VALUES ('4200', 'Naturwerkstein');
INSERT INTO "RP_KernmodellFreiraumstruktur"."RP_Rohstoff" ("Code", "Bezeichner") VALUES ('4300', 'Pegmatitsand');
INSERT INTO "RP_KernmodellFreiraumstruktur"."RP_Rohstoff" ("Code", "Bezeichner") VALUES ('4400', 'Quarzit');
INSERT INTO "RP_KernmodellFreiraumstruktur"."RP_Rohstoff" ("Code", "Bezeichner") VALUES ('4500', 'Quarzsand');
INSERT INTO "RP_KernmodellFreiraumstruktur"."RP_Rohstoff" ("Code", "Bezeichner") VALUES ('4600', 'Salz');
INSERT INTO "RP_KernmodellFreiraumstruktur"."RP_Rohstoff" ("Code", "Bezeichner") VALUES ('4700', 'Sand');
INSERT INTO "RP_KernmodellFreiraumstruktur"."RP_Rohstoff" ("Code", "Bezeichner") VALUES ('4800', 'Sandstein');
INSERT INTO "RP_KernmodellFreiraumstruktur"."RP_Rohstoff" ("Code", "Bezeichner") VALUES ('4900', 'Spezialton');
INSERT INTO "RP_KernmodellFreiraumstruktur"."RP_Rohstoff" ("Code", "Bezeichner") VALUES ('5000', 'Steinkohle');
INSERT INTO "RP_KernmodellFreiraumstruktur"."RP_Rohstoff" ("Code", "Bezeichner") VALUES ('5100', 'Ton');
INSERT INTO "RP_KernmodellFreiraumstruktur"."RP_Rohstoff" ("Code", "Bezeichner") VALUES ('5200', 'Tonstein');
INSERT INTO "RP_KernmodellFreiraumstruktur"."RP_Rohstoff" ("Code", "Bezeichner") VALUES ('5300', 'Torf');
INSERT INTO "RP_KernmodellFreiraumstruktur"."RP_Rohstoff" ("Code", "Bezeichner") VALUES ('5400', 'TuffBimsstein');
INSERT INTO "RP_KernmodellFreiraumstruktur"."RP_Rohstoff" ("Code", "Bezeichner") VALUES ('5500', 'Uran');
INSERT INTO "RP_KernmodellFreiraumstruktur"."RP_Rohstoff" ("Code", "Bezeichner") VALUES ('5600', 'Vulkanit');
INSERT INTO "RP_KernmodellFreiraumstruktur"."RP_Rohstoff" ("Code", "Bezeichner") VALUES ('5700', 'KieshaltigerSand');
INSERT INTO "RP_KernmodellFreiraumstruktur"."RP_Rohstoff" ("Code", "Bezeichner") VALUES ('5800', 'Naturstein');
INSERT INTO "RP_KernmodellFreiraumstruktur"."RP_Rohstoff" ("Code", "Bezeichner") VALUES ('5900', 'Oelschiefer');
INSERT INTO "RP_KernmodellFreiraumstruktur"."RP_Rohstoff" ("Code", "Bezeichner") VALUES ('6000', 'Klei');
INSERT INTO "RP_KernmodellFreiraumstruktur"."RP_Rohstoff" ("Code", "Bezeichner") VALUES ('9999', 'Sonstiges');

-- -----------------------------------------------------
-- Data for table "RP_KernmodellFreiraumstruktur"."RP_WasserschutzZone"
-- -----------------------------------------------------
INSERT INTO "RP_KernmodellFreiraumstruktur"."RP_WasserschutzZone" ("Code", "Bezeichner") VALUES ('1000', 'Zone_1');
INSERT INTO "RP_KernmodellFreiraumstruktur"."RP_WasserschutzZone" ("Code", "Bezeichner") VALUES ('2000', 'Zone_2');
INSERT INTO "RP_KernmodellFreiraumstruktur"."RP_WasserschutzZone" ("Code", "Bezeichner") VALUES ('3000', 'Zone_3');

-- -----------------------------------------------------
-- Data for table "RP_KernmodellInfrastruktur"."RP_EnergieversorgungTypen"
-- -----------------------------------------------------
INSERT INTO "RP_KernmodellInfrastruktur"."RP_EnergieversorgungTypen" ("Code", "Bezeichner") VALUES ('1000', 'Hochspannungsleitung');
INSERT INTO "RP_KernmodellInfrastruktur"."RP_EnergieversorgungTypen" ("Code", "Bezeichner") VALUES ('2000', 'Pipeline');
INSERT INTO "RP_KernmodellInfrastruktur"."RP_EnergieversorgungTypen" ("Code", "Bezeichner") VALUES ('3000', 'Kraftwerk');
INSERT INTO "RP_KernmodellInfrastruktur"."RP_EnergieversorgungTypen" ("Code", "Bezeichner") VALUES ('4000', 'EnergieSpeicherung');
INSERT INTO "RP_KernmodellInfrastruktur"."RP_EnergieversorgungTypen" ("Code", "Bezeichner") VALUES ('5000', 'Umspannwerk');
INSERT INTO "RP_KernmodellInfrastruktur"."RP_EnergieversorgungTypen" ("Code", "Bezeichner") VALUES ('9999', 'SonstigeEnergieversorgung');

-- -----------------------------------------------------
-- Data for table "RP_KernmodellInfrastruktur"."RP_EntsorgungTypen"
-- -----------------------------------------------------
INSERT INTO "RP_KernmodellInfrastruktur"."RP_EntsorgungTypen" ("Code", "Bezeichner") VALUES ('1000', 'Abfallwirtschaft');
INSERT INTO "RP_KernmodellInfrastruktur"."RP_EntsorgungTypen" ("Code", "Bezeichner") VALUES ('2000', 'Abwasserwirtschaft');
INSERT INTO "RP_KernmodellInfrastruktur"."RP_EntsorgungTypen" ("Code", "Bezeichner") VALUES ('9999', 'SonstigeEntsorgung');

-- -----------------------------------------------------
-- Data for table "RP_KernmodellInfrastruktur"."RP_SozialeInfrastrukturTypen"
-- -----------------------------------------------------
INSERT INTO "RP_KernmodellInfrastruktur"."RP_SozialeInfrastrukturTypen" ("Code", "Bezeichner") VALUES ('1000', 'Kultur');
INSERT INTO "RP_KernmodellInfrastruktur"."RP_SozialeInfrastrukturTypen" ("Code", "Bezeichner") VALUES ('2000', 'Sozialeinrichtung');
INSERT INTO "RP_KernmodellInfrastruktur"."RP_SozialeInfrastrukturTypen" ("Code", "Bezeichner") VALUES ('3000', 'Gesundheit');
INSERT INTO "RP_KernmodellInfrastruktur"."RP_SozialeInfrastrukturTypen" ("Code", "Bezeichner") VALUES ('4000', 'Bildung');
INSERT INTO "RP_KernmodellInfrastruktur"."RP_SozialeInfrastrukturTypen" ("Code", "Bezeichner") VALUES ('9999', 'SonstigeSozialeInfrastruktur');

-- -----------------------------------------------------
-- Data for table "RP_KernmodellInfrastruktur"."RP_VerkehrTypen"
-- -----------------------------------------------------
INSERT INTO "RP_KernmodellInfrastruktur"."RP_VerkehrTypen" ("Code", "Bezeichner") VALUES ('1000', 'Schienenverkehr');
INSERT INTO "RP_KernmodellInfrastruktur"."RP_VerkehrTypen" ("Code", "Bezeichner") VALUES ('2000', 'Strassenverkehr');
INSERT INTO "RP_KernmodellInfrastruktur"."RP_VerkehrTypen" ("Code", "Bezeichner") VALUES ('3000', 'Luftverkehr');
INSERT INTO "RP_KernmodellInfrastruktur"."RP_VerkehrTypen" ("Code", "Bezeichner") VALUES ('4000', 'Wasserverkehr');
INSERT INTO "RP_KernmodellInfrastruktur"."RP_VerkehrTypen" ("Code", "Bezeichner") VALUES ('9999', 'SonstigerVerkehr');

-- -----------------------------------------------------
-- Data for table "RP_KernmodellInfrastruktur"."RP_WasserwirtschaftTypen"
-- -----------------------------------------------------
INSERT INTO "RP_KernmodellInfrastruktur"."RP_WasserwirtschaftTypen" ("Code", "Bezeichner") VALUES ('1000', 'Wasserleitung');
INSERT INTO "RP_KernmodellInfrastruktur"."RP_WasserwirtschaftTypen" ("Code", "Bezeichner") VALUES ('2000', 'Wasserwerk');
INSERT INTO "RP_KernmodellInfrastruktur"."RP_WasserwirtschaftTypen" ("Code", "Bezeichner") VALUES ('3000', 'TalsperreStaudammDeich');
INSERT INTO "RP_KernmodellInfrastruktur"."RP_WasserwirtschaftTypen" ("Code", "Bezeichner") VALUES ('4000', 'Rückhaltebecken');
INSERT INTO "RP_KernmodellInfrastruktur"."RP_WasserwirtschaftTypen" ("Code", "Bezeichner") VALUES ('3500', 'TalsperreSpeicherbecken');
INSERT INTO "RP_KernmodellInfrastruktur"."RP_WasserwirtschaftTypen" ("Code", "Bezeichner") VALUES ('9999', 'SonstigeWasserwirtschaft');

-- -----------------------------------------------------
-- Data for table "RP_KernmodellSiedlungsstruktur"."RP_AchseTypen"
-- -----------------------------------------------------
INSERT INTO "RP_KernmodellSiedlungsstruktur"."RP_AchseTypen" ("Code", "Bezeichner") VALUES ('1000', 'Siedlungsachse');
INSERT INTO "RP_KernmodellSiedlungsstruktur"."RP_AchseTypen" ("Code", "Bezeichner") VALUES ('2000', 'GrossraeumigeAchse');
INSERT INTO "RP_KernmodellSiedlungsstruktur"."RP_AchseTypen" ("Code", "Bezeichner") VALUES ('9999', 'SonstigeAchse');

-- -----------------------------------------------------
-- Data for table "RP_KernmodellSiedlungsstruktur"."RP_Gemeindefunktionen"
-- -----------------------------------------------------
INSERT INTO "RP_KernmodellSiedlungsstruktur"."RP_Gemeindefunktionen" ("Code", "Bezeichner") VALUES ('1000', 'Wohnen');
INSERT INTO "RP_KernmodellSiedlungsstruktur"."RP_Gemeindefunktionen" ("Code", "Bezeichner") VALUES ('2000', 'Arbeiten');
INSERT INTO "RP_KernmodellSiedlungsstruktur"."RP_Gemeindefunktionen" ("Code", "Bezeichner") VALUES ('3000', 'Landwirtschaft');
INSERT INTO "RP_KernmodellSiedlungsstruktur"."RP_Gemeindefunktionen" ("Code", "Bezeichner") VALUES ('4000', 'Einzelhandel');
INSERT INTO "RP_KernmodellSiedlungsstruktur"."RP_Gemeindefunktionen" ("Code", "Bezeichner") VALUES ('5000', 'ErholungFremdenverkehr');
INSERT INTO "RP_KernmodellSiedlungsstruktur"."RP_Gemeindefunktionen" ("Code", "Bezeichner") VALUES ('6000', 'Verteidigung');
INSERT INTO "RP_KernmodellSiedlungsstruktur"."RP_Gemeindefunktionen" ("Code", "Bezeichner") VALUES ('9999', 'SonstigeNutzung');

-- -----------------------------------------------------
-- Data for table "RP_KernmodellSiedlungsstruktur"."RP_ZentralerOrtFunktionen"
-- -----------------------------------------------------
INSERT INTO "RP_KernmodellSiedlungsstruktur"."RP_ZentralerOrtFunktionen" ("Code", "Bezeichner") VALUES ('1000', 'Oberzentrum');
INSERT INTO "RP_KernmodellSiedlungsstruktur"."RP_ZentralerOrtFunktionen" ("Code", "Bezeichner") VALUES ('2000', 'Mittelzentrum');
INSERT INTO "RP_KernmodellSiedlungsstruktur"."RP_ZentralerOrtFunktionen" ("Code", "Bezeichner") VALUES ('3000', 'Grundzentrum');
INSERT INTO "RP_KernmodellSiedlungsstruktur"."RP_ZentralerOrtFunktionen" ("Code", "Bezeichner") VALUES ('4000', 'Kleinzentrum');
INSERT INTO "RP_KernmodellSiedlungsstruktur"."RP_ZentralerOrtFunktionen" ("Code", "Bezeichner") VALUES ('9999', 'SonstigeFunktion');
