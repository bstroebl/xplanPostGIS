-- -----------------------------------------------------
-- BP_Fachschema BPlan
-- Das Fachschema BPlan enthält alle Klassen von BPlan-Fachobjekten. Jede dieser Klassen modelliert eine nach BauGB mögliche Festsetzung, Kennzeichnung oder einen Vermerk in einem Bebauungsplan.
-- Wichtig bevor dieses Schema installiert werden kann, muß erst das XP_Basisschema installiert werden
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

CREATE SCHEMA "BP_Basisobjekte";
CREATE SCHEMA "BP_Bebauung";
CREATE SCHEMA "BP_Gemeinbedarf_Spiel_und_Sportanlagen";
CREATE SCHEMA "BP_Ver_und_Entsorgung";
CREATE SCHEMA "BP_Verkehr";
CREATE SCHEMA "BP_Wasser";
CREATE SCHEMA "BP_Naturschutz_Landschaftsbild_Naturhaushalt";
CREATE SCHEMA "BP_Landwirtschaft_Wald_und_Gruen";
CREATE SCHEMA "BP_Sonstiges";
CREATE SCHEMA "BP_Aufschuettung_Abgrabung_Bodenschaetze";
CREATE SCHEMA "BP_Erhaltungssatzung_und_Denkmalschutz";
CREATE SCHEMA "BP_Umwelt";
CREATE SCHEMA "BP_Laerm";

COMMENT ON SCHEMA "BP_Basisobjekte" IS 'Das Paket enthält die Klassen zur Modellierung eines BPlans (abgeleitet von XP_Plan) und eines BPlan-Bereichs (abgeleitet von XP_Bereich), sowie die Basisklassen für BPlan-Fachobjekte.';
COMMENT ON SCHEMA "BP_Bebauung" IS 'Festsetzungen über baulich genutzte Flächen';
COMMENT ON SCHEMA "BP_Gemeinbedarf_Spiel_und_Sportanlagen" IS 'Festsetzung von Flächen für den Gemeinbedarf sowie für Sport- und Spielanlagen.';
COMMENT ON SCHEMA "BP_Ver_und_Entsorgung" IS 'Festsetzung von Versorgungsflächen, Festsetzung der Führung von oberirdischen und unterirdischen Versorgungsanlagen und -leitungen, von Flächen für die Abfall- und Abwasserbeseitigung, sowie von Ablagerungen (§9, Abs. 1, Nr. 12-14 BauGB).';
COMMENT ON SCHEMA "BP_Verkehr" IS 'Verkehrsflächen und Verkehrsflächen besonderer Zweckbestimmung (§9, Abs. 1, Nr. 11 BauGB).';
COMMENT ON SCHEMA "BP_Wasser" IS 'Festsetzung von Gewässerflächen und Flächen für die Wasserwirtschaft.';
COMMENT ON SCHEMA "BP_Naturschutz_Landschaftsbild_Naturhaushalt" IS 'BP_Naturschutz, Landschaftsbild, Naturhaushalt: Festsetzungen von Flächen und Maßnahmen zum Schutz, zur Pflege und zur Entwicklung von Natur und Landschaft (§9, Abs. 1, Nr. 20 BauGB).';
COMMENT ON SCHEMA "BP_Landwirtschaft_Wald_und_Gruen" IS 'Festsetzungen von Flächen für die Landwirtschaft und Wald (§9, Abs. 1, Nr. 18 BauGB) für öffentliche und private Grünflächen (§9, Abs. 1, Nr. 15 BauGB), und für die Kleintierhaltung (§9, Abs. 1, Nr. 19 BauGB)';
COMMENT ON SCHEMA "BP_Sonstiges" IS 'Sonstige Festsetzungen';
COMMENT ON SCHEMA "BP_Aufschuettung_Abgrabung_Bodenschaetze" IS 'Festsetzungen von Flächen für Aufschüttungen, Abgrabungen oder für die Gewinnung von Steinen, Erden und anderen Bodenschätzen (§9, Abs. 1, Nr. 17 BauGB).';
COMMENT ON SCHEMA "BP_Erhaltungssatzung_und_Denkmalschutz" IS 'Festsetzungen zur Erhaltungssatzungen(§172 BauGB), Denkmalschutz-Ensembles sowie Einzelanlagen des Denkmalschutzes.';
COMMENT ON SCHEMA "BP_Umwelt" IS 'Umweltbezogene Festsetzungen';
COMMENT ON SCHEMA "BP_Laerm" IS '';

GRANT USAGE ON SCHEMA "BP_Basisobjekte" TO xp_gast;
GRANT USAGE ON SCHEMA "BP_Bebauung" TO xp_gast;
GRANT USAGE ON SCHEMA "BP_Gemeinbedarf_Spiel_und_Sportanlagen" TO xp_gast;
GRANT USAGE ON SCHEMA "BP_Ver_und_Entsorgung" TO xp_gast;
GRANT USAGE ON SCHEMA "BP_Verkehr" TO xp_gast;
GRANT USAGE ON SCHEMA "BP_Wasser" TO xp_gast;
GRANT USAGE ON SCHEMA "BP_Naturschutz_Landschaftsbild_Naturhaushalt" TO xp_gast;
GRANT USAGE ON SCHEMA "BP_Landwirtschaft_Wald_und_Gruen" TO xp_gast;
GRANT USAGE ON SCHEMA "BP_Sonstiges" TO xp_gast;
GRANT USAGE ON SCHEMA "BP_Aufschuettung_Abgrabung_Bodenschaetze" TO xp_gast;
GRANT USAGE ON SCHEMA "BP_Erhaltungssatzung_und_Denkmalschutz" TO xp_gast;
GRANT USAGE ON SCHEMA "BP_Umwelt" TO xp_gast;
GRANT USAGE ON SCHEMA "BP_Laerm" TO xp_gast;

-- *****************************************************
-- CREATE TRIGGER FUNCTIONs
-- *****************************************************

CREATE OR REPLACE FUNCTION "BP_Basisobjekte"."new_BP_Bereich"()
RETURNS trigger AS
$BODY$
 DECLARE
    bp_plan_gid integer;
 BEGIN
    SELECT max(gid) from "BP_Basisobjekte"."BP_Plan" INTO bp_plan_gid;

    IF bp_plan_gid IS NULL THEN
        RETURN NULL;
    ELSE
        new."gehoertZuPlan" := bp_plan_gid;
        RETURN new;
    END IF;
 END; $BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
GRANT EXECUTE ON FUNCTION "BP_Basisobjekte"."new_BP_Bereich"() TO bp_user;

CREATE OR REPLACE FUNCTION "BP_Basisobjekte"."new_BP_Plan"()
RETURNS trigger AS
$BODY$
 BEGIN
    INSERT INTO "BP_Basisobjekte"."BP_Plan_planArt"("BP_Plan_gid", "planArt") VALUES(NEW.gid, 1000);
    RETURN NEW;
 END; $BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
GRANT EXECUTE ON FUNCTION "BP_Basisobjekte"."new_BP_Plan"() TO bp_user;

CREATE OR REPLACE FUNCTION "BP_Bebauung"."BP_FestsetzungenBaugebiet_konsistent"()
RETURNS trigger AS
$BODY$
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
 END; $BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
GRANT EXECUTE ON FUNCTION "BP_Bebauung"."BP_FestsetzungenBaugebiet_konsistent"() TO bp_user;

CREATE OR REPLACE FUNCTION "BP_Laerm"."ins_updt_BP_EmissionskontingentLaerm"()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$

 DECLARE
    parent_nspname varchar;
    parent_relname varchar;
 BEGIN
    parent_nspname := 'BP_Laerm';
    parent_relname := 'BP_EmissionskontingentLaerm';

    IF (TG_OP = 'INSERT') THEN
        IF TG_TABLE_NAME = parent_relname THEN
            IF new.id IS NULL THEN -- in diese Tabelle kann auch direkt eingefügt werden
                new.id := nextval('"BP_Laerm"."BP_EmissionskontingentLaerm_id_seq"');
            END IF;
        ELSE -- BP_EmissionskontingentLaermGebiet
            new.id := nextval('"BP_Laerm"."BP_EmissionskontingentLaerm_id_seq"');
            -- Elternobjekt anlegen
            EXECUTE 'INSERT INTO ' || quote_ident(parent_nspname) || '.' || quote_ident(parent_relname) ||
                '(id) VALUES(' || CAST(new.id as varchar) || ');';
        END IF;
    ELSIF (TG_OP = 'UPDATE') THEN
        new.id := old.id; --no change in id allowed
    END IF; -- Kein DELETE weil in BP_EmissionskontingentLaerm auch direkt eingefügt werden kann

    RETURN new;
 END;
$BODY$;
GRANT EXECUTE ON FUNCTION "BP_Laerm"."ins_updt_BP_EmissionskontingentLaerm"() TO bp_user;

-- *****************************************************
-- CREATE SEQUENCES
-- *****************************************************
CREATE SEQUENCE "BP_Bebauung"."BP_Dachgestaltung_id_seq"
   MINVALUE 1;
GRANT ALL ON TABLE "BP_Bebauung"."BP_Dachgestaltung_id_seq" TO GROUP bp_user;

CREATE SEQUENCE "BP_Laerm"."BP_EmissionskontingentLaerm_id_seq"
   MINVALUE 1;
GRANT ALL ON TABLE "BP_Laerm"."BP_EmissionskontingentLaerm_id_seq" TO GROUP bp_user;

CREATE SEQUENCE "BP_Laerm"."BP_Richtungssektor_id_seq"
   MINVALUE 2; -- Wert eins wird durch den Defaulteintrag belegt
GRANT ALL ON TABLE "BP_Laerm"."BP_Richtungssektor_id_seq" TO GROUP bp_user;

-- *****************************************************
-- CREATE TABLEs
-- *****************************************************

-- -----------------------------------------------------
-- Table "BP_Basisobjekte"."BP_SonstPlanArt"
-- -----------------------------------------------------
CREATE  TABLE  "BP_Basisobjekte"."BP_SonstPlanArt" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(255) NOT NULL ,
  PRIMARY KEY ("Code") );
GRANT SELECT ON "BP_Basisobjekte"."BP_SonstPlanArt" TO xp_gast;
GRANT ALL ON "BP_Basisobjekte"."BP_SonstPlanArt" TO bp_user;
CREATE TRIGGER "ins_upd_BP_SonstPlanArt" BEFORE INSERT OR UPDATE ON "BP_Basisobjekte"."BP_SonstPlanArt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isCodeList"();

-- -----------------------------------------------------
-- Table "BP_Basisobjekte"."BP_Verfahren"
-- -----------------------------------------------------
CREATE  TABLE  "BP_Basisobjekte"."BP_Verfahren" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(255) NOT NULL ,
  PRIMARY KEY ("Code") );
GRANT SELECT ON "BP_Basisobjekte"."BP_Verfahren" TO xp_gast;

-- -----------------------------------------------------
-- Table "BP_Basisobjekte"."BP_Status"
-- -----------------------------------------------------
CREATE  TABLE  "BP_Basisobjekte"."BP_Status" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(255) NOT NULL ,
  PRIMARY KEY ("Code") );
GRANT SELECT ON "BP_Basisobjekte"."BP_Status" TO xp_gast;
GRANT ALL ON "BP_Basisobjekte"."BP_Status" TO bp_user;
CREATE TRIGGER "ins_upd_BP_Status" BEFORE INSERT OR UPDATE ON "BP_Basisobjekte"."BP_Status" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isCodeList"();

-- -----------------------------------------------------
-- Table "BP_Basisobjekte"."BP_Rechtsstand"
-- -----------------------------------------------------
CREATE  TABLE  "BP_Basisobjekte"."BP_Rechtsstand" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(255) NOT NULL ,
  PRIMARY KEY ("Code") );
GRANT SELECT ON "BP_Basisobjekte"."BP_Rechtsstand" TO xp_gast;

-- -----------------------------------------------------
-- Table "BP_Basisobjekte"."BP_Plan"
-- -----------------------------------------------------
CREATE  TABLE  "BP_Basisobjekte"."BP_Plan" (
  "gid" BIGINT NOT NULL ,
  "name" VARCHAR (256) NOT NULL,
  "plangeber" INTEGER NULL ,
  "sonstPlanArt" INTEGER NULL ,
  "verfahren" INTEGER NULL ,
  "rechtsstand" INTEGER NULL ,
  "status" INTEGER NULL ,
  "hoehenbezug" VARCHAR(255) NULL ,
  "aenderungenBisDatum" DATE NULL ,
  "aufstellungsbeschlussDatum" DATE NULL ,
  "veraenderungssperreDatum" DATE NULL ,
  "auslegungsStartDatum" DATE[],
  "auslegungsEndDatum" DATE[],
  "traegerbeteiligungsStartDatum" DATE[],
  "traegerbeteiligungsEndDatum" DATE[],
  "satzungsbeschlussDatum" DATE NULL ,
  "rechtsverordnungsDatum" DATE NULL ,
  "inkrafttretensDatum" DATE NULL ,
  "ausfertigungsDatum" DATE NULL ,
  "veraenderungssperre" BOOLEAN  NULL DEFAULT false ,
  "staedtebaulicherVertrag" BOOLEAN  NULL DEFAULT false ,
  "erschliessungsVertrag" BOOLEAN  NULL DEFAULT false ,
  "durchfuehrungsVertrag" BOOLEAN  NULL DEFAULT false ,
  "gruenordnungsplan" BOOLEAN  NULL DEFAULT false ,
  "refKoordinatenListe" INTEGER NULL ,
  "refGrundstuecksverzeichnis" INTEGER NULL ,
  "refPflanzliste" INTEGER NULL ,
  "refUmweltbericht" INTEGER NULL ,
  "refSatzung" INTEGER NULL ,
  "refGruenordnungsplan" INTEGER NULL ,
  "versionBauNVODatum" DATE NULL ,
  "versionBauNVOText" VARCHAR(255) NULL ,
  "versionBauGBDatum" DATE NULL ,
  "versionBauGBText" VARCHAR(255) NULL ,
  "versionSonstRechtsgrundlageDatum" DATE,
  "versionSonstRechtsgrundlageText" VARCHAR(255),
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_bp_plan_xp_plangeber1"
    FOREIGN KEY ("plangeber" )
    REFERENCES "XP_Sonstiges"."XP_Plangeber" ("id" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_bp_plan_bp_sonstplanart1"
    FOREIGN KEY ("sonstPlanArt" )
    REFERENCES "BP_Basisobjekte"."BP_SonstPlanArt" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_bp_plan_bp_verfahren1"
    FOREIGN KEY ("verfahren" )
    REFERENCES "BP_Basisobjekte"."BP_Verfahren" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_bp_plan_bp_status1"
    FOREIGN KEY ("status" )
    REFERENCES "BP_Basisobjekte"."BP_Status" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_bp_plan_bp_rechtsstand1"
    FOREIGN KEY ("rechtsstand" )
    REFERENCES "BP_Basisobjekte"."BP_Rechtsstand" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_bp_plan_xp_externereferenz1"
    FOREIGN KEY ("refKoordinatenListe" )
    REFERENCES "XP_Basisobjekte"."XP_ExterneReferenz" ("id" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_bp_plan_xp_externereferenz2"
    FOREIGN KEY ("refGrundstuecksverzeichnis" )
    REFERENCES "XP_Basisobjekte"."XP_ExterneReferenz" ("id" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_bp_plan_xp_externereferenz3"
    FOREIGN KEY ("refPflanzliste" )
    REFERENCES "XP_Basisobjekte"."XP_ExterneReferenz" ("id" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_bp_plan_xp_externereferenz4"
    FOREIGN KEY ("refUmweltbericht" )
    REFERENCES "XP_Basisobjekte"."XP_ExterneReferenz" ("id" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_bp_plan_xp_externereferenz5"
    FOREIGN KEY ("refSatzung" )
    REFERENCES "XP_Basisobjekte"."XP_ExterneReferenz" ("id" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_bp_plan_xp_externereferenz6"
    FOREIGN KEY ("refGruenordnungsplan" )
    REFERENCES "XP_Basisobjekte"."XP_ExterneReferenz" ("id" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_BP_Plan_XP_Plan1"
    FOREIGN KEY ("gid" )
    REFERENCES "XP_Basisobjekte"."XP_Plan" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("XP_Basisobjekte"."XP_RaeumlicherGeltungsbereich");

GRANT SELECT ON "BP_Basisobjekte"."BP_Plan" TO xp_gast;
GRANT ALL ON "BP_Basisobjekte"."BP_Plan" TO bp_user;
CREATE INDEX "idx_fk_bp_plan_xp_plangeber1" ON "BP_Basisobjekte"."BP_Plan" ("plangeber") ;
CREATE INDEX "idx_fk_bp_plan_bp_sonstplanart1" ON "BP_Basisobjekte"."BP_Plan" ("sonstPlanArt") ;
CREATE INDEX "idx_fk_bp_plan_bp_verfahren1" ON "BP_Basisobjekte"."BP_Plan" ("verfahren") ;
CREATE INDEX "idx_fk_bp_plan_bp_status1" ON "BP_Basisobjekte"."BP_Plan" ("status") ;
CREATE INDEX "idx_fk_bp_plan_bp_rechtsstand1" ON "BP_Basisobjekte"."BP_Plan" ("rechtsstand") ;
CREATE INDEX "idx_fk_bp_plan_xp_externereferenz1" ON "BP_Basisobjekte"."BP_Plan" ("refKoordinatenListe") ;
CREATE INDEX "idx_fk_bp_plan_xp_externereferenz2" ON "BP_Basisobjekte"."BP_Plan" ("refGrundstuecksverzeichnis") ;
CREATE INDEX "idx_fk_bp_plan_xp_externereferenz3" ON "BP_Basisobjekte"."BP_Plan" ("refPflanzliste") ;
CREATE INDEX "idx_fk_bp_plan_xp_externereferenz4" ON "BP_Basisobjekte"."BP_Plan" ("refUmweltbericht") ;
CREATE INDEX "idx_fk_bp_plan_xp_externereferenz5" ON "BP_Basisobjekte"."BP_Plan" ("refSatzung") ;
CREATE INDEX "idx_fk_bp_plan_xp_externereferenz6" ON "BP_Basisobjekte"."BP_Plan" ("refGruenordnungsplan") ;
CREATE INDEX "idx_fk_BP_Plan_XP_Plan1" ON "BP_Basisobjekte"."BP_Plan" ("gid") ;
CREATE INDEX "BP_Plan_gidx" ON "BP_Basisobjekte"."BP_Plan" using gist ("raeumlicherGeltungsbereich");
COMMENT ON TABLE  "BP_Basisobjekte"."BP_Plan" IS 'Die Klasse modelliert einen Bebauungsplan';
COMMENT ON COLUMN  "BP_Basisobjekte"."BP_Plan"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN "BP_Basisobjekte"."BP_Plan"."name" IS 'Name des Plans. Der Name kann hier oder in XP_Plan geändert werden.';
COMMENT ON COLUMN  "BP_Basisobjekte"."BP_Plan"."plangeber" IS 'Für den BPlan verantwortliche Stelle.';
COMMENT ON COLUMN  "BP_Basisobjekte"."BP_Plan"."sonstPlanArt" IS 'Spezifikation einer "Sonstigen Planart", wenn kein Plantyp aus der Enumeration BP_PlanArt zutraffend ist.';
COMMENT ON COLUMN  "BP_Basisobjekte"."BP_Plan"."verfahren" IS 'Verfahrensart der BPlan-Aufstellung oder -Änderung.';
COMMENT ON COLUMN  "BP_Basisobjekte"."BP_Plan"."rechtsstand" IS 'Aktueller Rechtsstand des Plans';
COMMENT ON COLUMN  "BP_Basisobjekte"."BP_Plan"."status" IS 'Über eine CodeList definieter aktueller Status des Plans.';
COMMENT ON COLUMN  "BP_Basisobjekte"."BP_Plan"."hoehenbezug" IS 'Bei Höhenangaben im Plan standardmäßig verwendeter Höhenbezug (z.B. Höhe über NN).';
COMMENT ON COLUMN  "BP_Basisobjekte"."BP_Plan"."aenderungenBisDatum" IS 'Datum der berücksichtigten Plan-Änderungen.';
COMMENT ON COLUMN  "BP_Basisobjekte"."BP_Plan"."aufstellungsbeschlussDatum" IS 'Datum des Aufstellungsbeschlusses.';
COMMENT ON COLUMN  "BP_Basisobjekte"."BP_Plan"."veraenderungssperreDatum" IS 'Datum der Veränderungssperre';
COMMENT ON COLUMN  "BP_Basisobjekte"."BP_Plan"."auslegungsStartDatum" IS 'Start-Datum des Auslegungs-Zeitraums. Bei mehrfacher öffentlicher Auslegung können mehrere Datumsangeben spezifiziert werden.';
COMMENT ON COLUMN  "BP_Basisobjekte"."BP_Plan"."auslegungsEndDatum" IS 'End-Datum des Auslegungs-Zeitraums. Bei mehrfacher öffentlicher Auslegung können mehrere Datumsangeben spezifiziert werden.';
COMMENT ON COLUMN  "BP_Basisobjekte"."BP_Plan"."traegerbeteiligungsStartDatum" IS 'Start-Datum der Trägerbeteiligung. Bei mehrfacher Trägerbeteiligung können mehrere Datumsangeben spezifiziert werden.';
COMMENT ON COLUMN  "BP_Basisobjekte"."BP_Plan"."traegerbeteiligungsEndDatum" IS 'End-Datum der Trägerbeteiligung. Bei mehrfacher Trägerbeteiligung können mehrere Datumsangeben spezifiziert werden.';
COMMENT ON COLUMN  "BP_Basisobjekte"."BP_Plan"."satzungsbeschlussDatum" IS 'Datum des Satzungsbeschlusses';
COMMENT ON COLUMN  "BP_Basisobjekte"."BP_Plan"."rechtsverordnungsDatum" IS 'Datum der Rechtsverordnung.';
COMMENT ON COLUMN  "BP_Basisobjekte"."BP_Plan"."inkrafttretensDatum" IS 'Datum des Inkrafttretens.';
COMMENT ON COLUMN  "BP_Basisobjekte"."BP_Plan"."ausfertigungsDatum" IS 'Datum der Ausfertigung';
COMMENT ON COLUMN  "BP_Basisobjekte"."BP_Plan"."veraenderungssperre" IS 'Gibt an ob es im gesamten Geltungsbereich des Plans eine Veränderungssperre gibt.';
COMMENT ON COLUMN  "BP_Basisobjekte"."BP_Plan"."staedtebaulicherVertrag" IS 'Gibt an, ob es zum Plan einen städtebaulichen Vertrag gibt.';
COMMENT ON COLUMN  "BP_Basisobjekte"."BP_Plan"."erschliessungsVertrag" IS 'Gibt an, ob es für den Plan einen Erschließungsvertrag gibt.';
COMMENT ON COLUMN  "BP_Basisobjekte"."BP_Plan"."durchfuehrungsVertrag" IS 'Gibt an, ob für das gebiet ein Durchführungsvertrag (Kombination aus Städtebaulichen Vertrag und Erschließungsvertrag) existiert.';
COMMENT ON COLUMN  "BP_Basisobjekte"."BP_Plan"."gruenordnungsplan" IS 'Gibt an, ob für den BPlan ein zugehöriger Grünordnungsplan existiert.';
COMMENT ON COLUMN  "BP_Basisobjekte"."BP_Plan"."refKoordinatenListe" IS 'Referenz auf eine Koordinaten-Liste.';
COMMENT ON COLUMN  "BP_Basisobjekte"."BP_Plan"."refGrundstuecksverzeichnis" IS 'Referenz auf ein Grundstücksverzeichnis.';
COMMENT ON COLUMN  "BP_Basisobjekte"."BP_Plan"."refPflanzliste" IS 'Referenz auf eine Pflanzliste.';
COMMENT ON COLUMN  "BP_Basisobjekte"."BP_Plan"."refUmweltbericht" IS 'Referenz auf den Umweltbericht.';
COMMENT ON COLUMN  "BP_Basisobjekte"."BP_Plan"."refSatzung" IS 'Referenz auf die Satzung.';
COMMENT ON COLUMN  "BP_Basisobjekte"."BP_Plan"."refGruenordnungsplan" IS 'Referenz auf den Grünordnungsplan .';
COMMENT ON COLUMN "BP_Basisobjekte"."BP_Plan"."versionBauNVODatum" IS 'Datum der zugrundeliegenden Version der BauNVO.';
COMMENT ON COLUMN "BP_Basisobjekte"."BP_Plan"."versionBauNVOText" IS 'Zugrundeliegende Version der BauNVO.';
COMMENT ON COLUMN "BP_Basisobjekte"."BP_Plan"."versionBauGBDatum" IS 'Datum der zugrunde liegenden Version des BauGB.';
COMMENT ON COLUMN "BP_Basisobjekte"."BP_Plan"."versionBauGBText" IS 'Zugrunde liegende Version des BauGB.';
COMMENT ON COLUMN "BP_Basisobjekte"."BP_Plan"."versionSonstRechtsgrundlageDatum" IS 'Datum einer zugrunde liegenden anderen Rechtsgrundlage als BauGB / BauNVO.';
COMMENT ON COLUMN "BP_Basisobjekte"."BP_Plan"."versionSonstRechtsgrundlageText" IS 'Textliche Spezifikation einer zugrunde liegenden anderen Rechtsgrundlage als BauGB / BauNVO.';
CREATE TRIGGER "change_to_BP_Plan" BEFORE INSERT OR UPDATE ON "BP_Basisobjekte"."BP_Plan" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Plan"();
CREATE TRIGGER "new_BP_Plan" AFTER INSERT ON "BP_Basisobjekte"."BP_Plan" FOR EACH ROW EXECUTE PROCEDURE "BP_Basisobjekte"."new_BP_Plan"();
CREATE TRIGGER "delete_BP_Plan" AFTER DELETE ON "BP_Basisobjekte"."BP_Plan" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Plan"();
CREATE TRIGGER "BP_Plan_propagate_name" AFTER UPDATE ON "BP_Basisobjekte"."BP_Plan" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."propagate_name_to_parent"();

-- -----------------------------------------------------
-- Table "BP_Basisobjekte"."BP_PlanArt"
-- -----------------------------------------------------
CREATE  TABLE  "BP_Basisobjekte"."BP_PlanArt" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(255) NOT NULL ,
  PRIMARY KEY ("Code") );
GRANT SELECT ON "BP_Basisobjekte"."BP_PlanArt" TO xp_gast;

-- -----------------------------------------------------
-- Table "BP_Basisobjekte"."BP_Plan_planArt"
-- -----------------------------------------------------
CREATE  TABLE  "BP_Basisobjekte"."BP_Plan_planArt" (
  "BP_Plan_gid" BIGINT NOT NULL ,
  "planArt" INTEGER NOT NULL ,
  PRIMARY KEY ("BP_Plan_gid", "planArt") ,
  CONSTRAINT "fk_planArt_BP_Plan"
    FOREIGN KEY ("BP_Plan_gid" )
    REFERENCES "BP_Basisobjekte"."BP_Plan" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_planArt_BP_PlanArt"
    FOREIGN KEY ("planArt" )
    REFERENCES "BP_Basisobjekte"."BP_PlanArt" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
GRANT SELECT ON "BP_Basisobjekte"."BP_Plan_planArt" TO xp_gast;
GRANT ALL ON "BP_Basisobjekte"."BP_Plan_planArt" TO bp_user;
COMMENT ON TABLE  "BP_Basisobjekte"."BP_Plan_planArt" IS 'Typ des vorliegenden BPlans.';
CREATE INDEX "idx_fk_planArt_BP_Plan" ON "BP_Basisobjekte"."BP_Plan_planArt" ("BP_Plan_gid") ;
CREATE INDEX "idx_fk_planArt_BP_PlanArt" ON "BP_Basisobjekte"."BP_Plan_planArt" ("planArt") ;

-- -----------------------------------------------------
-- Table "BP_Basisobjekte"."BP_Bereich"
-- -----------------------------------------------------
CREATE  TABLE  "BP_Basisobjekte"."BP_Bereich" (
  "gid" BIGINT NOT NULL ,
  "name" VARCHAR (256) NOT NULL,
  "versionBauNVODatum" DATE NULL ,
  "versionBauNVOText" VARCHAR(255) NULL ,
  "versionBauGBDatum" DATE NULL ,
  "versionBauGBText" VARCHAR(255) NULL ,
  "versionSonstRechtsgrundlageDatum" DATE,
  "versionSonstRechtsgrundlageText" VARCHAR(255),
  "gehoertZuPlan" INTEGER NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_BP_Bereich_BP_Plan1"
    FOREIGN KEY ("gehoertZuPlan" )
    REFERENCES "BP_Basisobjekte"."BP_Plan" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_BP_Bereich_XP_Bereich1"
    FOREIGN KEY ("gid" )
    REFERENCES "XP_Basisobjekte"."XP_Bereich" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("XP_Basisobjekte"."XP_Geltungsbereich");

GRANT SELECT ON "BP_Basisobjekte"."BP_Bereich" TO xp_gast;
GRANT ALL ON "BP_Basisobjekte"."BP_Bereich" TO bp_user;
COMMENT ON TABLE  "BP_Basisobjekte"."BP_Bereich" IS 'Diese Klasse modelliert einen Bereich eines Bebauungsplans, z.B. eine vertikale Ebene.';
COMMENT ON COLUMN  "BP_Basisobjekte"."BP_Bereich"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN "BP_Basisobjekte"."BP_Bereich"."name" IS 'Bezeichnung des Bereiches. Die Bezeichnung kann hier oder in XP_Bereich geändert werden.';
COMMENT ON COLUMN "BP_Basisobjekte"."BP_Bereich"."versionBauNVODatum" IS 'Datum der zugrundeliegenden Version der BauNVO.
Das Attribut ist veraltet und wird in XPlanGML 6.0 wegfallen. Es sollte stattdessen das gleichnamige Attribut von BP_Plan verwendet werden.';
COMMENT ON COLUMN "BP_Basisobjekte"."BP_Bereich"."versionBauNVOText" IS 'Zugrundeliegende Version der BauNVO.
Das Attribut ist veraltet und wird in XPlanGML 6.0 wegfallen. Es sollte stattdessen das gleichnamige Attribut von BP_Plan verwendet werden.';
COMMENT ON COLUMN "BP_Basisobjekte"."BP_Bereich"."versionBauGBDatum" IS 'Datum der zugrunde liegenden Version des BauGB.
Das Attribut ist veraltet und wird in XPlanGML 6.0 wegfallen. Es sollte stattdessen das gleichnamige Attribut von BP_Plan verwendet werden.';
COMMENT ON COLUMN "BP_Basisobjekte"."BP_Bereich"."versionBauGBText" IS 'Zugrunde liegende Version des BauGB.
Das Attribut ist veraltet und wird in XPlanGML 6.0 wegfallen. Es sollte stattdessen das gleichnamige Attribut von BP_Plan verwendet werden.';
COMMENT ON COLUMN "BP_Basisobjekte"."BP_Bereich"."versionSonstRechtsgrundlageDatum" IS 'Datum einer zugrunde liegenden anderen Rechtsgrundlage als BauGB / BauNVO.
Das Attribut ist veraltet und wird in XPlanGML 6.0 wegfallen. Es sollte stattdessen das gleichnamige Attribut von BP_Plan verwendet werden.';
COMMENT ON COLUMN "BP_Basisobjekte"."BP_Bereich"."versionSonstRechtsgrundlageText" IS 'Textliche Spezifikation einer zugrunde liegenden anderen Rechtsgrundlage als BauGB / BauNVO.
Das Attribut ist veraltet und wird in XPlanGML 6.0 wegfallen. Es sollte stattdessen das gleichnamige Attribut von BP_Plan verwendet werden.';
CREATE INDEX "idx_fk_BP_Bereich_BP_Plan1" ON "BP_Basisobjekte"."BP_Bereich" ("gehoertZuPlan") ;
CREATE INDEX "idx_fk_BP_Bereich_XP_Bereich1" ON "BP_Basisobjekte"."BP_Bereich" ("gid") ;
CREATE INDEX "idx_fk_BP_Bereich_XP_Bereich2" ON "BP_Basisobjekte"."BP_Bereich" ("gid") ;
CREATE INDEX "BP_Bereich_gidx" ON "BP_Basisobjekte"."BP_Bereich" using gist ("geltungsbereich");
CREATE TRIGGER "change_to_BP_Bereich" BEFORE INSERT OR UPDATE ON "BP_Basisobjekte"."BP_Bereich" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Bereich"();
CREATE TRIGGER "delete_BP_Bereich" AFTER DELETE ON "BP_Basisobjekte"."BP_Bereich" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Bereich"();
CREATE TRIGGER "insert_into_BP_Bereich" BEFORE INSERT ON "BP_Basisobjekte"."BP_Bereich" FOR EACH ROW EXECUTE PROCEDURE "BP_Basisobjekte"."new_BP_Bereich"();
CREATE TRIGGER "BP_Bereich_propagate_name" AFTER UPDATE ON "BP_Basisobjekte"."BP_Bereich" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."propagate_name_to_parent"();

-- -----------------------------------------------------
-- Table "BP_Basisobjekte"."BP_Rechtscharakter"
-- -----------------------------------------------------
CREATE  TABLE  "BP_Basisobjekte"."BP_Rechtscharakter" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Code") );
GRANT SELECT ON "BP_Basisobjekte"."BP_Rechtscharakter" TO xp_gast;

-- -----------------------------------------------------
-- Table "BP_Basisobjekte"."BP_Punktobjekt"
-- -----------------------------------------------------
CREATE  TABLE  "BP_Basisobjekte"."BP_Punktobjekt" (
  "gid" BIGINT NOT NULL ,
  "position" GEOMETRY(Multipoint,25832) NOT NULL ,
  "nordwinkel" INTEGER,
  PRIMARY KEY ("gid") );
COMMENT ON COLUMN  "BP_Basisobjekte"."BP_Punktobjekt"."nordwinkel" IS 'Orientierung des Punktobjektes als Winkel gegen die Nordrichtung. Zählweise im geographischen Sinn (von Nord über Ost nach Süd und West).';
GRANT SELECT ON TABLE "BP_Basisobjekte"."BP_Punktobjekt" TO xp_gast;
GRANT ALL ON TABLE "BP_Basisobjekte"."BP_Punktobjekt" TO bp_user;
CREATE TRIGGER "BP_Punktobjekt_isAbstract" BEFORE INSERT ON "BP_Basisobjekte"."BP_Punktobjekt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isAbstract"();

-- -----------------------------------------------------
-- Table "BP_Basisobjekte"."BP_Linienobjekt"
-- -----------------------------------------------------
CREATE  TABLE  "BP_Basisobjekte"."BP_Linienobjekt" (
  "gid" BIGINT NOT NULL ,
  "position" GEOMETRY(Multilinestring,25832) NOT NULL ,
  "flussrichtung" boolean,
  PRIMARY KEY ("gid") );
GRANT SELECT ON TABLE "BP_Basisobjekte"."BP_Linienobjekt" TO xp_gast;
GRANT ALL ON TABLE "BP_Basisobjekte"."BP_Linienobjekt" TO bp_user;
CREATE TRIGGER "BP_Linienobjekt_isAbstract" BEFORE INSERT ON "BP_Basisobjekte"."BP_Linienobjekt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isAbstract"();

-- -----------------------------------------------------
-- Table "BP_Basisobjekte"."BP_Flaechenobjekt"
-- -----------------------------------------------------
CREATE  TABLE  "BP_Basisobjekte"."BP_Flaechenobjekt" (
  "gid" BIGINT NOT NULL ,
  "position" GEOMETRY(Multipolygon,25832) NOT NULL ,
  "flaechenschluss" BOOLEAN NOT NULL,
  PRIMARY KEY ("gid") );
GRANT SELECT ON TABLE "BP_Basisobjekte"."BP_Flaechenobjekt" TO xp_gast;
GRANT ALL ON TABLE "BP_Basisobjekte"."BP_Flaechenobjekt" TO bp_user;
CREATE TRIGGER "BP_Flaechenobjekt_isAbstract" BEFORE INSERT ON "BP_Basisobjekte"."BP_Flaechenobjekt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isAbstract"();

-- -----------------------------------------------------
-- Table "BP_Laerm"."BP_EmissionskontingentLaerm"
-- -----------------------------------------------------
CREATE TABLE "BP_Laerm"."BP_EmissionskontingentLaerm" (
  "id" INTEGER NOT NULL,
  "ekwertTag" REAL NOT NULL DEFAULT 0,
  "ekwertNacht" REAL NOT NULL DEFAULT 0,
  "erlaeuterung" VARCHAR (256),
  PRIMARY KEY ("id") );

COMMENT ON TABLE "BP_Laerm"."BP_EmissionskontingentLaerm" IS 'Lärmemissionskontingent eines Teilgebietes nach DIN 45691, Abschnitt 4.6';
COMMENT ON COLUMN "BP_Laerm"."BP_EmissionskontingentLaerm"."id" IS 'Primärschlüssel, wird automatisch vergeben';
COMMENT ON COLUMN "BP_Laerm"."BP_EmissionskontingentLaerm"."ekwertTag" IS 'Emissionskontingent Tag in db';
COMMENT ON COLUMN "BP_Laerm"."BP_EmissionskontingentLaerm"."ekwertNacht" IS 'Emissionskontingent Nacht in db';
COMMENT ON COLUMN "BP_Laerm"."BP_EmissionskontingentLaerm"."erlaeuterung" IS 'Erläuterung';
CREATE TRIGGER "BP_EmissionskontingentLaerm_ins_upd" BEFORE INSERT OR UPDATE ON "BP_Laerm"."BP_EmissionskontingentLaerm" FOR EACH ROW EXECUTE PROCEDURE "BP_Laerm"."ins_updt_BP_EmissionskontingentLaerm"();
GRANT SELECT ON TABLE "BP_Laerm"."BP_EmissionskontingentLaerm" TO xp_gast;
GRANT ALL ON TABLE "BP_Laerm"."BP_EmissionskontingentLaerm" TO bp_user;

-- -----------------------------------------------------
-- Table "BP_Basisobjekte"."BP_Objekt"
-- -----------------------------------------------------
CREATE  TABLE  "BP_Basisobjekte"."BP_Objekt" (
  "gid" BIGINT NOT NULL ,
  "rechtscharakter" INTEGER NOT NULL DEFAULT 9998,
  "laermkontingent" INTEGER,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_bp_objekt_bp_rechtscharakter1"
    FOREIGN KEY ("rechtscharakter" )
    REFERENCES "BP_Basisobjekte"."BP_Rechtscharakter" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT "fk_BP_Objekt_XP_Objekt1"
    FOREIGN KEY ("gid" )
    REFERENCES "XP_Basisobjekte"."XP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_BP_Ojekt_laermkontingent"
    FOREIGN KEY ("laermkontingent")
    REFERENCES "BP_Laerm"."BP_EmissionskontingentLaerm" ("id")
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
GRANT SELECT ON "BP_Basisobjekte"."BP_Objekt" TO xp_gast;
GRANT ALL ON "BP_Basisobjekte"."BP_Objekt" TO bp_user;
COMMENT ON TABLE  "BP_Basisobjekte"."BP_Objekt" IS 'Basisklasse für alle raumbezogenen Festsetzungen, Hinweise, Vermerke und Kennzeichnungen eines Bebauungsplans.';
COMMENT ON COLUMN  "BP_Basisobjekte"."BP_Objekt"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN  "BP_Basisobjekte"."BP_Objekt"."rechtscharakter" IS 'Rechtliche Charakterisierung des Planinhaltes.';
COMMENT ON COLUMN "BP_Basisobjekte"."BP_Objekt"."laermkontingent" IS 'Festsetzung eines Lärmemissionskontingent nach DIN 45691';
CREATE INDEX "idx_fk_bp_objekt_bp_rechtscharakter1" ON "BP_Basisobjekte"."BP_Objekt" ("rechtscharakter") ;
CREATE TRIGGER "change_to_BP_Objekt" BEFORE INSERT OR UPDATE ON "BP_Basisobjekte"."BP_Objekt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_BP_Objekt" AFTER DELETE ON "BP_Basisobjekte"."BP_Objekt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "BP_Laerm"."BP_ZusatzkontingentLaerm"
-- -----------------------------------------------------
CREATE TABLE "BP_Laerm"."BP_ZusatzkontingentLaerm" (
  "gid" BIGINT NOT NULL,
  "bezeichnung" CHARACTER VARYING(256),
  PRIMARY KEY ("gid"),
  CONSTRAINT "fk_BP_ZusatzkontingentLaerm_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "BP_Basisobjekte"."BP_Objekt" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("BP_Basisobjekte"."BP_Punktobjekt");

COMMENT ON TABLE "BP_Laerm"."BP_ZusatzkontingentLaerm" IS 'Parametrische Spezifikation von zusätzlichen Lärmemissionskontingenten für einzelne Richtungssektoren (DIN 45691, Anhang 2).';
COMMENT ON COLUMN "BP_Laerm"."BP_ZusatzkontingentLaerm"."gid" IS 'Primärschlüssel, wird automatisch vergeben';
COMMENT ON COLUMN "BP_Laerm"."BP_ZusatzkontingentLaerm"."bezeichnung" IS 'Bezeichnung des Kontingentes';
GRANT SELECT ON TABLE "BP_Laerm"."BP_ZusatzkontingentLaerm" TO xp_gast;
GRANT ALL ON TABLE "BP_Laerm"."BP_ZusatzkontingentLaerm" TO bp_user;
CREATE INDEX "BP_ZusatzkontingentLaerm_gidx" ON "BP_Laerm"."BP_ZusatzkontingentLaerm" using gist ("position");
CREATE TRIGGER "change_to_BP_ZusatzkontingentLaerm" BEFORE INSERT OR UPDATE ON "BP_Laerm"."BP_ZusatzkontingentLaerm" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_BP_ZusatzkontingentLaerm" AFTER DELETE ON "BP_Laerm"."BP_ZusatzkontingentLaerm" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Verknüpfe BP_Objekt und BP_ZusatzkontingentLaerm
-- -----------------------------------------------------
ALTER TABLE "BP_Basisobjekte"."BP_Objekt" ADD COLUMN "zusatzkontingent" BIGINT;
COMMENT ON COLUMN "BP_Basisobjekte"."BP_Objekt"."zusatzkontingent" IS 'Festsetzung von Zusatzkontingenten für die Lärmemission, die einzelnen Richtungssektoren zugeordnet sind. Die einzelnen Richtungssektoren werden parametrisch definiert.';
ALTER TABLE "BP_Basisobjekte"."BP_Objekt" ADD CONSTRAINT "fk_BP_Ojekt_zusatzkontingent"
    FOREIGN KEY ("zusatzkontingent")
    REFERENCES "BP_Laerm"."BP_ZusatzkontingentLaerm" ("gid")
    ON DELETE NO ACTION
    ON UPDATE CASCADE;

-- -----------------------------------------------------
-- Table "BP_Laerm"."BP_Richtungssektor"
-- -----------------------------------------------------
CREATE TABLE "BP_Laerm"."BP_Richtungssektor" (
  "id" INTEGER NOT NULL DEFAULT nextval('"BP_Laerm"."BP_Richtungssektor_id_seq"'),
  "winkelAnfang" INTEGER NOT NULL DEFAULT 0,
  "winkelEnde" INTEGER NOT NULL DEFAULT 0,
  "zkWertTag" INTEGER NOT NULL DEFAULT 1,
  "zkWertNacht" INTEGER NOT NULL DEFAULT 1,
  PRIMARY KEY ("id") );

COMMENT ON TABLE "BP_Laerm"."BP_Richtungssektor" IS 'Lärmemissionskontingent eines Teilgebietes nach DIN 45691, Abschnitt 4.6';
COMMENT ON COLUMN "BP_Laerm"."BP_Richtungssektor"."id" IS 'Primärschlüssel, wird automatisch vergeben';
COMMENT ON COLUMN "BP_Laerm"."BP_Richtungssektor"."winkelAnfang" IS 'Startwinkel des Emissionssektors';
COMMENT ON COLUMN "BP_Laerm"."BP_Richtungssektor"."winkelEnde" IS 'Endwinkel des Emissionssektors';
COMMENT ON COLUMN "BP_Laerm"."BP_Richtungssektor"."zkWertTag" IS 'Zusatzkontingent Tag';
COMMENT ON COLUMN "BP_Laerm"."BP_Richtungssektor"."zkWertNacht" IS 'Zusatzkontingent Nacht';
GRANT SELECT ON TABLE "BP_Laerm"."BP_Richtungssektor" TO xp_gast;
GRANT ALL ON TABLE "BP_Laerm"."BP_Richtungssektor" TO bp_user;

-- -----------------------------------------------------
-- Table "BP_Laerm"."BP_ZusatzkontingentLaerm_richtungssektor"
-- -----------------------------------------------------
CREATE TABLE "BP_Laerm"."BP_ZusatzkontingentLaerm_richtungssektor" (
  "BP_ZusatzkontingentLaerm_gid" BIGINT NOT NULL ,
  "richtungssektor" INTEGER NOT NULL ,
  PRIMARY KEY ("BP_ZusatzkontingentLaerm_gid", "richtungssektor") ,
  CONSTRAINT "fk_BP_ZusatzkontingentLaerm_richtungssektor1"
    FOREIGN KEY ("BP_ZusatzkontingentLaerm_gid")
    REFERENCES "BP_Laerm"."BP_ZusatzkontingentLaerm" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_BP_ZusatzkontingentLaerm_richtungssektor2"
    FOREIGN KEY ("richtungssektor")
    REFERENCES "BP_Laerm"."BP_Richtungssektor" ("id")
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
GRANT SELECT ON "BP_Laerm"."BP_ZusatzkontingentLaerm_richtungssektor" TO xp_gast;
GRANT ALL ON "BP_Laerm"."BP_ZusatzkontingentLaerm_richtungssektor" TO bp_user;
COMMENT ON TABLE "BP_Laerm"."BP_ZusatzkontingentLaerm_richtungssektor" IS 'Spezifikation der Richtungssektoren';

-- -----------------------------------------------------
-- Table "BP_Laerm"."BP_ZusatzkontingentLaermFlaeche"
-- -----------------------------------------------------
CREATE TABLE "BP_Laerm"."BP_ZusatzkontingentLaermFlaeche" (
  "gid" BIGINT NOT NULL ,
  "bezeichnung" CHARACTER VARYING(256),
  "richtungssektor" INTEGER NOT NULL DEFAULT 1,
  PRIMARY KEY ("gid"),
  CONSTRAINT "fk_BP_ZusatzkontingentLaermFlaeche_parent"
    FOREIGN KEY ("gid")
    REFERENCES "BP_Basisobjekte"."BP_Objekt" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_BP_ZusatzkontingentLaermFlaeche_richtungssektor1"
    FOREIGN KEY ("richtungssektor")
    REFERENCES "BP_Laerm"."BP_Richtungssektor" ("id")
    ON DELETE NO ACTION
    ON UPDATE CASCADE)
INHERITS ("BP_Basisobjekte"."BP_Flaechenobjekt");

GRANT SELECT ON TABLE "BP_Laerm"."BP_ZusatzkontingentLaermFlaeche" TO xp_gast;
GRANT ALL ON TABLE "BP_Laerm"."BP_ZusatzkontingentLaermFlaeche" TO bp_user;
CREATE INDEX "BP_ZusatzkontingentLaermFlaeche_gidx" ON "BP_Laerm"."BP_ZusatzkontingentLaermFlaeche" using gist ("position");
COMMENT ON TABLE "BP_Laerm"."BP_ZusatzkontingentLaermFlaeche" IS 'Flächenhafte Spezifikation von zusätzlichen Lärmemissionskontingenten für einzelne Richtungssektoren (DIN 45691, Anhang 2).';
COMMENT ON COLUMN "BP_Laerm"."BP_ZusatzkontingentLaermFlaeche"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN "BP_Laerm"."BP_ZusatzkontingentLaermFlaeche"."bezeichnung" IS 'Bezeichnung des Kontingentes';
COMMENT ON COLUMN "BP_Laerm"."BP_ZusatzkontingentLaermFlaeche"."richtungssektor" IS 'Spezifikation des zugehörigen Richtungssektors';
CREATE TRIGGER "change_to_BP_ZusatzkontingentLaermFlaeche" BEFORE INSERT OR UPDATE ON "BP_Laerm"."BP_ZusatzkontingentLaermFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_BP_ZusatzkontingentLaermFlaeche" AFTER DELETE ON "BP_Laerm"."BP_ZusatzkontingentLaermFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "BP_ZusatzkontingentLaermFlaeche_Ueberlagerung" BEFORE INSERT OR UPDATE ON "BP_Laerm"."BP_ZusatzkontingentLaermFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isUeberlagerungsobjekt"();

-- -----------------------------------------------------
-- Table "BP_Laerm"."BP_RichtungssektorGrenze"
-- -----------------------------------------------------
CREATE TABLE "BP_Laerm"."BP_RichtungssektorGrenze" (
  "gid" BIGINT NOT NULL,
  "winkel" INTEGER,
  PRIMARY KEY ("gid"),
  CONSTRAINT "fk_BP_RichtungssektorGrenze_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "BP_Basisobjekte"."BP_Objekt" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("BP_Basisobjekte"."BP_Linienobjekt");

COMMENT ON TABLE "BP_Laerm"."BP_RichtungssektorGrenze" IS 'Linienhafte Repräsentation einer Richtungssektor-Grenze';
COMMENT ON COLUMN "BP_Laerm"."BP_RichtungssektorGrenze"."gid" IS 'Primärschlüssel, wird automatisch vergeben';
COMMENT ON COLUMN "BP_Laerm"."BP_RichtungssektorGrenze"."winkel" IS 'Richtungswinkel der Sektorengrenze';
GRANT SELECT ON TABLE "BP_Laerm"."BP_RichtungssektorGrenze" TO xp_gast;
GRANT ALL ON TABLE "BP_Laerm"."BP_RichtungssektorGrenze" TO bp_user;
CREATE INDEX "BP_RichtungssektorGrenze_gidx" ON "BP_Laerm"."BP_RichtungssektorGrenze" using gist ("position");
CREATE TRIGGER "change_to_BP_RichtungssektorGrenze" BEFORE INSERT OR UPDATE ON "BP_Laerm"."BP_RichtungssektorGrenze" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_BP_RichtungssektorGrenze" AFTER DELETE ON "BP_Laerm"."BP_RichtungssektorGrenze" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "BP_Laerm"."BP_EmissionskontingentLaermGebiet"
-- -----------------------------------------------------
CREATE TABLE "BP_Laerm"."BP_EmissionskontingentLaermGebiet" (
  "id" INTEGER NOT NULL,
  "gebietsbezeichnung" VARCHAR (256),
  PRIMARY KEY ("id"),
  CONSTRAINT "fk_BP_EmissionskontingentLaermGebiet_parent"
    FOREIGN KEY ("id")
    REFERENCES "BP_Laerm"."BP_EmissionskontingentLaerm" ("id")
    ON DELETE CASCADE
    ON UPDATE CASCADE);

COMMENT ON TABLE "BP_Laerm"."BP_EmissionskontingentLaermGebiet" IS 'Lärmemissionskontingent eines Teilgebietes, das einem bestimmten Immissionsgebiet außerhalb des Geltungsbereiches des BPlans zugeordnet ist (Anhang A4 von DIN 45691).';
COMMENT ON COLUMN "BP_Laerm"."BP_EmissionskontingentLaermGebiet"."id" IS 'Primärschlüssel, wird automatisch vergeben';
COMMENT ON COLUMN "BP_Laerm"."BP_EmissionskontingentLaermGebiet"."gebietsbezeichnung" IS 'Bezeichnung des Immissionsgebietes';
CREATE TRIGGER "BP_EmissionskontingentLaermGebiet_ins_upd" BEFORE INSERT OR UPDATE ON "BP_Laerm"."BP_EmissionskontingentLaermGebiet" FOR EACH ROW EXECUTE PROCEDURE "BP_Laerm"."ins_updt_BP_EmissionskontingentLaerm"();
GRANT SELECT ON TABLE "BP_Laerm"."BP_EmissionskontingentLaermGebiet" TO xp_gast;
GRANT ALL ON TABLE "BP_Laerm"."BP_EmissionskontingentLaermGebiet" TO bp_user;

-- -----------------------------------------------------
-- Table "BP_Basisobjekte"."BP_Objekt_laermkontingentGebiet"
-- -----------------------------------------------------
CREATE TABLE "BP_Basisobjekte"."BP_Objekt_laermkontingentGebiet" (
  "BP_Objekt_gid" BIGINT NOT NULL ,
  "laermkontingentGebiet" INTEGER NOT NULL ,
  PRIMARY KEY ("BP_Objekt_gid", "laermkontingentGebiet") ,
  CONSTRAINT "fk_laermkontingentGebiet_BP_Objekt1"
    FOREIGN KEY ("BP_Objekt_gid")
    REFERENCES "BP_Basisobjekte"."BP_Objekt" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_laermkontingentGebiet_BP_EmissionskontingentLaermGebiet1"
    FOREIGN KEY ("laermkontingentGebiet")
    REFERENCES "BP_Laerm"."BP_EmissionskontingentLaermGebiet" ("id")
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
GRANT SELECT ON "BP_Basisobjekte"."BP_Objekt_laermkontingentGebiet" TO xp_gast;
GRANT ALL ON "BP_Basisobjekte"."BP_Objekt_laermkontingentGebiet" TO bp_user;
COMMENT ON TABLE "BP_Basisobjekte"."BP_Objekt_laermkontingentGebiet" IS 'Festsetzung von Lärmemissionskontingenten nach DIN 45691, die einzelnen Immissionsgebieten zugeordnet sind';

-- -----------------------------------------------------
-- Table "BP_Basisobjekte"."BP_Objekt_zusatzkontingentFlaeche"
-- -----------------------------------------------------
CREATE TABLE "BP_Basisobjekte"."BP_Objekt_zusatzkontingentFlaeche" (
  "BP_Objekt_gid" BIGINT NOT NULL ,
  "zusatzkontingentFlaeche" BIGINT NOT NULL ,
  PRIMARY KEY ("BP_Objekt_gid", "zusatzkontingentFlaeche") ,
  CONSTRAINT "fk_zusatzkontingentFlaeche_BP_Objekt1"
    FOREIGN KEY ("BP_Objekt_gid")
    REFERENCES "BP_Basisobjekte"."BP_Objekt" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_zusatzkontingentFlaeche_BP_ZusatzkontingentLaermFlaeche1"
    FOREIGN KEY ("zusatzkontingentFlaeche")
    REFERENCES "BP_Laerm"."BP_ZusatzkontingentLaermFlaeche" ("gid")
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
GRANT SELECT ON "BP_Basisobjekte"."BP_Objekt_zusatzkontingentFlaeche" TO xp_gast;
GRANT ALL ON "BP_Basisobjekte"."BP_Objekt_zusatzkontingentFlaeche" TO bp_user;
COMMENT ON TABLE "BP_Basisobjekte"."BP_Objekt_zusatzkontingentFlaeche" IS 'Festsetzung von Zusatzkontingenten für die Lärmemission, die einzelnen Richtungssektoren zugeordnet sind. Die einzelnen Richtungssektoren werden durch explizite Flächen definiert.';

-- -----------------------------------------------------
-- Table "BP_Basisobjekte"."BP_Objekt_richtungssektorGrenze"
-- -----------------------------------------------------
CREATE TABLE "BP_Basisobjekte"."BP_Objekt_richtungssektorGrenze" (
  "BP_Objekt_gid" BIGINT NOT NULL ,
  "richtungssektorGrenze" BIGINT NOT NULL ,
  PRIMARY KEY ("BP_Objekt_gid", "richtungssektorGrenze") ,
  CONSTRAINT "fk_richtungssektorGrenze_BP_Objekt1"
    FOREIGN KEY ("BP_Objekt_gid")
    REFERENCES "BP_Basisobjekte"."BP_Objekt" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_richtungssektorGrenze_BP_RichtungssektorGrenze1"
    FOREIGN KEY ("richtungssektorGrenze")
    REFERENCES "BP_Laerm"."BP_RichtungssektorGrenze" ("gid")
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
GRANT SELECT ON "BP_Basisobjekte"."BP_Objekt_richtungssektorGrenze" TO xp_gast;
GRANT ALL ON "BP_Basisobjekte"."BP_Objekt_richtungssektorGrenze" TO bp_user;
COMMENT ON TABLE "BP_Basisobjekte"."BP_Objekt_richtungssektorGrenze" IS 'Zuordnung einer Richtungssektor-Grenze für die Festlegung zusätzlicher Lärmkontingente';

-- -----------------------------------------------------
-- Table "BP_Basisobjekte"."BP_TextAbschnitt"
-- -----------------------------------------------------
CREATE  TABLE  "BP_Basisobjekte"."BP_TextAbschnitt" (
  "id" BIGINT NOT NULL ,
  "rechtscharakter" INTEGER NOT NULL DEFAULT 9998,
  PRIMARY KEY ("id") ,
  CONSTRAINT "fk_BP_TextAbschnitt_rechtscharakter"
    FOREIGN KEY ("rechtscharakter" )
    REFERENCES "BP_Basisobjekte"."BP_Rechtscharakter" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_BP_TextAbschnitt_parent"
    FOREIGN KEY ("id" )
    REFERENCES "XP_Basisobjekte"."XP_TextAbschnitt" ("id" )
    ON DELETE CASCADE
    ON UPDATE CASCADE);

GRANT SELECT ON "BP_Basisobjekte"."BP_TextAbschnitt" TO xp_gast;
GRANT ALL ON "BP_Basisobjekte"."BP_TextAbschnitt" TO bp_user;
COMMENT ON TABLE  "BP_Basisobjekte"."BP_TextAbschnitt" IS 'Texlich formulierter Inhalt eines Bebauungsplans, der einen anderen Rechtscharakter als das zugrunde liegende Fachobjekt hat (Attribut rechtscharakter des Fachobjektes), oder dem Plan als Ganzes zugeordnet ist.';
COMMENT ON COLUMN  "BP_Basisobjekte"."BP_TextAbschnitt"."id" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN  "BP_Basisobjekte"."BP_TextAbschnitt"."rechtscharakter" IS 'Rechtscharakter des textlich formulierten Planinhalts.';
CREATE INDEX "idx_fk_BP_TextAbschnitt_rechtscharakter" ON "BP_Basisobjekte"."BP_TextAbschnitt" ("rechtscharakter") ;
CREATE TRIGGER "change_to_BP_TextAbschnitt" BEFORE INSERT OR UPDATE ON "BP_Basisobjekte"."BP_TextAbschnitt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_TextAbschnitt"();
CREATE TRIGGER "delete_BP_TextAbschnitt" AFTER DELETE ON "BP_Basisobjekte"."BP_TextAbschnitt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_TextAbschnitt"();

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

-- -----------------------------------------------------
-- Table "BP_Basisobjekte"."BP_Plan_gemeinde"
-- -----------------------------------------------------
CREATE  TABLE  "BP_Basisobjekte"."BP_Plan_gemeinde" (
  "BP_Plan_gid" BIGINT NOT NULL ,
  "gemeinde" INTEGER NOT NULL ,
  PRIMARY KEY ("BP_Plan_gid", "gemeinde") ,
  CONSTRAINT "fk_gemeinde_BP_Plan1"
    FOREIGN KEY ("BP_Plan_gid" )
    REFERENCES "BP_Basisobjekte"."BP_Plan" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_gemeinde_XP_Gemeinde1"
    FOREIGN KEY ("gemeinde" )
    REFERENCES "XP_Sonstiges"."XP_Gemeinde" ("id" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
GRANT SELECT ON "BP_Basisobjekte"."BP_Plan_gemeinde" TO xp_gast;
GRANT ALL ON "BP_Basisobjekte"."BP_Plan_gemeinde" TO bp_user;
COMMENT ON TABLE  "BP_Basisobjekte"."BP_Plan_gemeinde" IS 'Die für den Plan zuständige Gemeinde.';
CREATE INDEX "idx_fk_gemeinde_BP_Plan1" ON "BP_Basisobjekte"."BP_Plan_gemeinde" ("BP_Plan_gid") ;
CREATE INDEX "idx_fk_gemeinde_XP_Gemeinde1" ON "BP_Basisobjekte"."BP_Plan_gemeinde" ("gemeinde") ;

-- -----------------------------------------------------
-- Table "BP_Basisobjekte"."BP_Plan_planaufstellendeGemeinde"
-- -----------------------------------------------------
CREATE TABLE "BP_Basisobjekte"."BP_Plan_planaufstellendeGemeinde" (
  "BP_Plan_gid" BIGINT NOT NULL ,
  "planaufstellendeGemeinde" INTEGER NOT NULL ,
  PRIMARY KEY ("BP_Plan_gid", "planaufstellendeGemeinde") ,
  CONSTRAINT "fk_planaufstellendeGemeinde_BP_Plan1"
    FOREIGN KEY ("BP_Plan_gid" )
    REFERENCES "BP_Basisobjekte"."BP_Plan" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_planaufstellendeGemeinde_XP_Gemeinde1"
    FOREIGN KEY ("planaufstellendeGemeinde" )
    REFERENCES "XP_Sonstiges"."XP_Gemeinde" ("id" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
GRANT SELECT ON "BP_Basisobjekte"."BP_Plan_planaufstellendeGemeinde" TO xp_gast;
GRANT ALL ON "BP_Basisobjekte"."BP_Plan_planaufstellendeGemeinde" TO bp_user;
COMMENT ON TABLE "BP_Basisobjekte"."BP_Plan_planaufstellendeGemeinde" IS 'Die für die ursprüngliche Planaufstellung zuständige Gemeinde, falls diese nicht unter dem Attribut gemeinde aufgeführt ist. Dies kann z.B. nach Gemeindefusionen der Fall sein.';
CREATE INDEX "idx_fk_planaufstellendeGemeinde_BP_Plan1" ON "BP_Basisobjekte"."BP_Plan_planaufstellendeGemeinde" ("BP_Plan_gid") ;
CREATE INDEX "idx_fk_planaufstellendeGemeinde_XP_Gemeinde1" ON "BP_Basisobjekte"."BP_Plan_planaufstellendeGemeinde" ("planaufstellendeGemeinde");

-- -----------------------------------------------------
-- Table "BP_Aufschuettung_Abgrabung_Bodenschaetze"."BP_AbgrabungsFlaeche"
-- -----------------------------------------------------
CREATE  TABLE  "BP_Aufschuettung_Abgrabung_Bodenschaetze"."BP_AbgrabungsFlaeche" (
  "gid" BIGINT NOT NULL ,
  "abbaugut" VARCHAR(255),
  PRIMARY KEY ("gid"),
  CONSTRAINT "fk_BP_AbgrabungsFlaeche_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "BP_Basisobjekte"."BP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("BP_Basisobjekte"."BP_Flaechenobjekt");

GRANT SELECT ON TABLE "BP_Aufschuettung_Abgrabung_Bodenschaetze"."BP_AbgrabungsFlaeche" TO xp_gast;
GRANT ALL ON TABLE "BP_Aufschuettung_Abgrabung_Bodenschaetze"."BP_AbgrabungsFlaeche" TO bp_user;
CREATE INDEX "BP_AbgrabungsFlaeche_gidx" ON "BP_Aufschuettung_Abgrabung_Bodenschaetze"."BP_AbgrabungsFlaeche" using gist ("position");
COMMENT ON TABLE  "BP_Aufschuettung_Abgrabung_Bodenschaetze"."BP_AbgrabungsFlaeche" IS 'Flächen für Aufschüttungen, Abgrabungen oder für die Gewinnung von Bodenschätzen (§9, Abs. 1, Nr. 17 BauGB)). Hier: Flächen für Abgrabungen.';
COMMENT ON COLUMN  "BP_Aufschuettung_Abgrabung_Bodenschaetze"."BP_AbgrabungsFlaeche"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN "BP_Aufschuettung_Abgrabung_Bodenschaetze"."BP_AbgrabungsFlaeche"."abbaugut" IS 'Bezeichnung des Abbauguts.';
CREATE TRIGGER "change_to_BP_AbgrabungsFlaeche" BEFORE INSERT OR UPDATE ON "BP_Aufschuettung_Abgrabung_Bodenschaetze"."BP_AbgrabungsFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_BP_AbgrabungsFlaeche" AFTER DELETE ON "BP_Aufschuettung_Abgrabung_Bodenschaetze"."BP_AbgrabungsFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "BP_AbgrabungsFlaeche_Flaechenobjekt" BEFORE INSERT OR UPDATE ON "BP_Aufschuettung_Abgrabung_Bodenschaetze"."BP_AbgrabungsFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isFlaechenobjekt"();

-- -----------------------------------------------------
-- Table "BP_Bebauung"."BP_AbstandsFlaeche"
-- -----------------------------------------------------
CREATE  TABLE  "BP_Bebauung"."BP_AbstandsFlaeche" (
  "gid" BIGINT NOT NULL ,
  "tiefe" NUMERIC(6,2),
  PRIMARY KEY ("gid"),
  CONSTRAINT "fk_BP_AbstandsFlaeche_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "BP_Basisobjekte"."BP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("BP_Basisobjekte"."BP_Flaechenobjekt");

GRANT SELECT ON TABLE "BP_Bebauung"."BP_AbstandsFlaeche" TO xp_gast;
GRANT ALL ON TABLE "BP_Bebauung"."BP_AbstandsFlaeche" TO bp_user;
CREATE INDEX "BP_AbstandsFlaeche_gidx" ON "BP_Bebauung"."BP_AbstandsFlaeche" using gist ("position");
COMMENT ON TABLE  "BP_Bebauung"."BP_AbstandsFlaeche" IS 'Festsetzung eines vom Bauordnungsrecht abweichenden Maßes der Tiefe der Abstandsfläche gemäß § 9 Abs 1. Nr. 2a BauGB';
COMMENT ON COLUMN  "BP_Bebauung"."BP_AbstandsFlaeche"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN  "BP_Bebauung"."BP_AbstandsFlaeche"."tiefe" IS 'Absolute Angabe derTiefe.';
CREATE TRIGGER "change_to_BP_AbstandsFlaeche" BEFORE INSERT OR UPDATE ON "BP_Bebauung"."BP_AbstandsFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_BP_AbstandsFlaeche" AFTER DELETE ON "BP_Bebauung"."BP_AbstandsFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "BP_AbstandsFlaeche_Ueberlagerung" BEFORE INSERT OR UPDATE ON "BP_Bebauung"."BP_AbstandsFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isUeberlagerungsobjekt"();

-- -----------------------------------------------------
-- Table "BP_Sonstiges"."BP_AbstandsMassTypen"
-- -----------------------------------------------------
CREATE  TABLE  "BP_Sonstiges"."BP_AbstandsMassTypen" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Code") );
GRANT SELECT ON "BP_Sonstiges"."BP_AbstandsMassTypen" TO xp_gast;

-- -----------------------------------------------------
-- Table "BP_Sonstiges"."BP_AbstandsMass"
-- -----------------------------------------------------
CREATE  TABLE  "BP_Sonstiges"."BP_AbstandsMass" (
  "gid" BIGINT NOT NULL ,
  "typ" INTEGER,
  "wert" NUMERIC(6,2),
  "startWinkel" INTEGER,
  "endWinkel" INTEGER,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_BP_AbstandsMass_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "BP_Basisobjekte"."BP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_BP_AbstandsMass_typ"
    FOREIGN KEY ("typ" )
    REFERENCES "BP_Sonstiges"."BP_AbstandsMassTypen" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE);

GRANT SELECT ON TABLE "BP_Sonstiges"."BP_AbstandsMass" TO xp_gast;
GRANT ALL ON TABLE "BP_Sonstiges"."BP_AbstandsMass" TO bp_user;
COMMENT ON TABLE  "BP_Sonstiges"."BP_AbstandsMass" IS 'Darstellung von Maßpfeilen oder Maßkreisen in BPlänen, um eine eindeutige Vermassung einzelner Festsetzungen zu erreichen.
Bei Masspfeilen (typ == 1000) sollte das Geometrie-Attribut position nur eine einfache Linie (gml:LineString mit 2 Punkten) enthalten
Bei Maßkreisen (typ == 2000) sollte position nur einen einfachen Kreisbogen (gml:Curve mit genau einem gml:Arc enthalten).
In der nächsten Hauptversion von XPlanGML werden diese Empfehlungen zu verpflichtenden Konformitätsbedingungen.';
COMMENT ON COLUMN  "BP_Sonstiges"."BP_AbstandsMass"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN  "BP_Sonstiges"."BP_AbstandsMass"."wert" IS 'Längenangabe des Abstandsmasses.';
COMMENT ON COLUMN "BP_Sonstiges"."BP_AbstandsMass"."typ" IS 'Typ der Massangabe (Maßpfeil oder Maßkreis).';
COMMENT ON COLUMN "BP_Sonstiges"."BP_AbstandsMass"."startWinkel" IS 'Startwinkel für die Plandarstellung des Abstandsmaßes (nur relevant für Maßkreise). Die Winkelwerte beziehen sich auf den Rechtswert (Ost-Richtung)';
COMMENT ON COLUMN "BP_Sonstiges"."BP_AbstandsMass"."endWinkel" IS 'Endwinkel für die Planarstellung des Abstandsmaßes (nur relevant für Maßkreise). Die Winkelwerte beziehen sich auf den Rechtswert (Ost-Richtung)';
CREATE TRIGGER "change_to_BP_AbstandsMass" BEFORE INSERT OR UPDATE ON "BP_Sonstiges"."BP_AbstandsMass" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_BP_AbstandsMass" AFTER DELETE ON "BP_Sonstiges"."BP_AbstandsMass" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "BP_Sonstiges"."BP_AbstandsMassFlaeche"
-- -----------------------------------------------------
CREATE  TABLE  "BP_Sonstiges"."BP_AbstandsMassFlaeche" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_BP_AbstandsMassFlaeche_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "BP_Sonstiges"."BP_AbstandsMass" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("BP_Basisobjekte"."BP_Flaechenobjekt");

GRANT SELECT ON TABLE "BP_Sonstiges"."BP_AbstandsMassFlaeche" TO xp_gast;
GRANT ALL ON TABLE "BP_Sonstiges"."BP_AbstandsMassFlaeche" TO bp_user;
CREATE INDEX "BP_AbstandsMassFlaeche_gidx" ON "BP_Sonstiges"."BP_AbstandsMassFlaeche" using gist ("position");
CREATE TRIGGER "change_to_BP_AbstandsMassFlaeche" BEFORE INSERT OR UPDATE ON "BP_Sonstiges"."BP_AbstandsMassFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_BP_AbstandsMassFlaeche" AFTER DELETE ON "BP_Sonstiges"."BP_AbstandsMassFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "BP_AbstandsMassFlaeche_Flaechenobjekt" BEFORE INSERT OR UPDATE ON "BP_Sonstiges"."BP_AbstandsMassFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isFlaechenobjekt"();

-- -----------------------------------------------------
-- Table "BP_Sonstiges"."BP_AbstandsMassLinie"
-- -----------------------------------------------------
CREATE  TABLE  "BP_Sonstiges"."BP_AbstandsMassLinie" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_BP_AbstandsMassLinie_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "BP_Sonstiges"."BP_AbstandsMass" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("BP_Basisobjekte"."BP_Linienobjekt");

GRANT SELECT ON TABLE "BP_Sonstiges"."BP_AbstandsMassLinie" TO xp_gast;
GRANT ALL ON TABLE "BP_Sonstiges"."BP_AbstandsMassLinie" TO bp_user;
CREATE INDEX "BP_AbstandsMassLinie_gidx" ON "BP_Sonstiges"."BP_AbstandsMassLinie" using gist ("position");
CREATE TRIGGER "change_to_BP_AbstandsMassLinie" BEFORE INSERT OR UPDATE ON "BP_Sonstiges"."BP_AbstandsMassLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_BP_AbstandsMassLinie" AFTER DELETE ON "BP_Sonstiges"."BP_AbstandsMassLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "BP_Sonstiges"."BP_AbstandsMassPunkt"
-- -----------------------------------------------------
CREATE  TABLE  "BP_Sonstiges"."BP_AbstandsMassPunkt" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_BP_AbstandsMassPunkt_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "BP_Sonstiges"."BP_AbstandsMass" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("BP_Basisobjekte"."BP_Punktobjekt");

GRANT SELECT ON TABLE "BP_Sonstiges"."BP_AbstandsMassPunkt" TO xp_gast;
GRANT ALL ON TABLE "BP_Sonstiges"."BP_AbstandsMassPunkt" TO bp_user;
CREATE INDEX "BP_AbstandsMassPunkt_gidx" ON "BP_Sonstiges"."BP_AbstandsMassPunkt" using gist ("position");
CREATE TRIGGER "change_to_BP_AbstandsMassPunkt" BEFORE INSERT OR UPDATE ON "BP_Sonstiges"."BP_AbstandsMassPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_BP_AbstandsMassPunkt" AFTER DELETE ON "BP_Sonstiges"."BP_AbstandsMassPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_VegetationsobjektTypen"
-- -----------------------------------------------------
CREATE TABLE "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_VegetationsobjektTypen" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Code") );
GRANT SELECT ON "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_VegetationsobjektTypen" TO xp_gast;
GRANT ALL ON "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_VegetationsobjektTypen" TO bp_user;
CREATE TRIGGER "ins_upd_BP_VegetationsobjektTypen" BEFORE INSERT OR UPDATE ON "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_VegetationsobjektTypen" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isCodeList"();

-- -----------------------------------------------------
-- Table "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_AnpflanzungBindungErhaltung"
-- -----------------------------------------------------
CREATE  TABLE  "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_AnpflanzungBindungErhaltung" (
  "gid" BIGINT NOT NULL ,
  "massnahme" INTEGER,
  "kronendurchmesser" NUMERIC(6,2),
  "pflanztiefe" NUMERIC(6,2),
  "istAusgleich" BOOLEAN,
  "baumArt" INTEGER,
  "anzahl" INTEGER,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_BP_AnpflanzungBindungErhaltung_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "BP_Basisobjekte"."BP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_LP_AnpflanzungBindungErhaltung_massnahme"
    FOREIGN KEY ("massnahme" )
    REFERENCES "XP_Enumerationen"."XP_ABEMassnahmenTypen" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_LP_AnpflanzungBindungErhaltung_baumArt"
    FOREIGN KEY ("baumArt")
    REFERENCES "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_VegetationsobjektTypen" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE);

GRANT SELECT ON TABLE "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_AnpflanzungBindungErhaltung" TO xp_gast;
GRANT ALL ON TABLE "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_AnpflanzungBindungErhaltung" TO bp_user;
COMMENT ON TABLE  "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_AnpflanzungBindungErhaltung" IS 'Für einzelne Flächen oder für ein Bebauungsplangebiet oder Teile davon sowie für Teile baulicher Anlagen mit Ausnahme der für landwirtschaftliche Nutzungen oder Wald festgesetzten Flächen:\n
a) Festsetzung des Anpflanzens von Bäumen, Sträuchern und sonstigen Bepflanzungen;\n
b) Festsetzung von Bindungen für Bepflanzungen und für die Erhaltung von Bäumen, Sträuchern und sonstigen Bepflanzungen sowie von Gewässern; (§9 Abs. 1 Nr. 25 und Abs. 4 BauGB)';
COMMENT ON COLUMN  "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_AnpflanzungBindungErhaltung"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN  "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_AnpflanzungBindungErhaltung"."massnahme" IS 'Art der Maßnahme';
COMMENT ON COLUMN  "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_AnpflanzungBindungErhaltung"."kronendurchmesser" IS 'Durchmesser der Baumkrone bei zu erhaltenden Bäumen.';
COMMENT ON COLUMN  "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_AnpflanzungBindungErhaltung"."pflanztiefe" IS 'Pflanztiefe';
COMMENT ON COLUMN  "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_AnpflanzungBindungErhaltung"."istAusgleich" IS 'Gibt an, ob die Fläche oder Maßnahme zum Ausgleich von Eingriffen genutzt wird.';
COMMENT ON COLUMN  "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_AnpflanzungBindungErhaltung"."baumArt" IS 'Spezifikation einer Baumart.';
COMMENT ON COLUMN "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_AnpflanzungBindungErhaltung"."anzahl" IS 'Anzahl der anzupflanzenden Objekte';
CREATE TRIGGER "change_to_BP_AnpflanzungBindungErhaltung" BEFORE INSERT OR UPDATE ON "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_AnpflanzungBindungErhaltung" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_BP_AnpflanzungBindungErhaltung" AFTER DELETE ON "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_AnpflanzungBindungErhaltung" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_AnpflanzungBindungErhaltung_gegenstand"
-- -----------------------------------------------------
CREATE  TABLE  "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_AnpflanzungBindungErhaltung_gegenstand" (
  "BP_AnpflanzungBindungErhaltung_gid" BIGINT NOT NULL ,
  "gegenstand" INTEGER NOT NULL ,
  PRIMARY KEY ("BP_AnpflanzungBindungErhaltung_gid", "gegenstand"),
  CONSTRAINT "fk_BP_AnpflanzungBindungErhaltung_gegenstand1"
    FOREIGN KEY ("BP_AnpflanzungBindungErhaltung_gid" )
    REFERENCES "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_AnpflanzungBindungErhaltung" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_BP_AnpflanzungBindungErhaltung_gegenstand2"
    FOREIGN KEY ("gegenstand" )
    REFERENCES "XP_Enumerationen"."XP_AnpflanzungBindungErhaltungsGegenstand" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
GRANT SELECT ON TABLE "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_AnpflanzungBindungErhaltung_gegenstand" TO xp_gast;
GRANT ALL ON TABLE "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_AnpflanzungBindungErhaltung_gegenstand" TO bp_user;
COMMENT ON TABLE  "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_AnpflanzungBindungErhaltung_gegenstand" IS 'Gegenstände der Maßnahme';

-- -----------------------------------------------------
-- Table "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_AnpflanzungBindungErhaltungFlaeche"
-- -----------------------------------------------------
CREATE  TABLE  "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_AnpflanzungBindungErhaltungFlaeche" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_BP_AnpflanzungBindungErhaltungFlaeche_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_AnpflanzungBindungErhaltung" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("BP_Basisobjekte"."BP_Flaechenobjekt");

GRANT SELECT ON TABLE "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_AnpflanzungBindungErhaltungFlaeche" TO xp_gast;
GRANT ALL ON TABLE "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_AnpflanzungBindungErhaltungFlaeche" TO bp_user;
CREATE INDEX "BP_AnpflanzungBindungErhaltungFlaeche_gidx" ON "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_AnpflanzungBindungErhaltungFlaeche" using gist ("position");
CREATE TRIGGER "change_to_BP_AnpflanzungBindungErhaltungFlaeche" BEFORE INSERT OR UPDATE ON "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_AnpflanzungBindungErhaltungFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_BP_AnpflanzungBindungErhaltungFlaeche" AFTER DELETE ON "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_AnpflanzungBindungErhaltungFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "BP_AnpflanzungBindungErhaltungFlaeche_Flaechenobjekt" BEFORE INSERT OR UPDATE ON "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_AnpflanzungBindungErhaltungFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isFlaechenobjekt"();

-- -----------------------------------------------------
-- Table "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_AnpflanzungBindungErhaltungLinie"
-- -----------------------------------------------------
CREATE  TABLE  "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_AnpflanzungBindungErhaltungLinie" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_BP_AnpflanzungBindungErhaltungLinie_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_AnpflanzungBindungErhaltung" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("BP_Basisobjekte"."BP_Linienobjekt");

GRANT SELECT ON TABLE "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_AnpflanzungBindungErhaltungLinie" TO xp_gast;
GRANT ALL ON TABLE "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_AnpflanzungBindungErhaltungLinie" TO bp_user;
CREATE INDEX "BP_AnpflanzungBindungErhaltungLinie_gidx" ON "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_AnpflanzungBindungErhaltungLinie" using gist ("position");
CREATE TRIGGER "change_to_BP_AnpflanzungBindungErhaltungLinie" BEFORE INSERT OR UPDATE ON "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_AnpflanzungBindungErhaltungLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_BP_AnpflanzungBindungErhaltungLinie" AFTER DELETE ON "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_AnpflanzungBindungErhaltungLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_AnpflanzungBindungErhaltungPunkt"
-- -----------------------------------------------------
CREATE  TABLE  "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_AnpflanzungBindungErhaltungPunkt" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_BP_AnpflanzungBindungErhaltungPunkt_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_AnpflanzungBindungErhaltung" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("BP_Basisobjekte"."BP_Punktobjekt");

GRANT SELECT ON TABLE "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_AnpflanzungBindungErhaltungPunkt" TO xp_gast;
GRANT ALL ON TABLE "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_AnpflanzungBindungErhaltungPunkt" TO bp_user;
CREATE INDEX "BP_AnpflanzungBindungErhaltungPunkt_gidx" ON "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_AnpflanzungBindungErhaltungPunkt" using gist ("position");
CREATE TRIGGER "change_to_BP_AnpflanzungBindungErhaltungPunkt" BEFORE INSERT OR UPDATE ON "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_AnpflanzungBindungErhaltungPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_BP_AnpflanzungBindungErhaltungPunkt" AFTER DELETE ON "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_AnpflanzungBindungErhaltungPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "BP_Aufschuettung_Abgrabung_Bodenschaetze"."BP_AufschuettungsFlaeche"
-- -----------------------------------------------------
CREATE  TABLE  "BP_Aufschuettung_Abgrabung_Bodenschaetze"."BP_AufschuettungsFlaeche" (
  "gid" BIGINT NOT NULL ,
  "aufschuettungsmaterial" VARCHAR (64),
  PRIMARY KEY ("gid"),
  CONSTRAINT "fk_BP_AufschuettungsFlaeche_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "BP_Basisobjekte"."BP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE
  )
INHERITS ("BP_Basisobjekte"."BP_Flaechenobjekt");

GRANT SELECT ON TABLE "BP_Aufschuettung_Abgrabung_Bodenschaetze"."BP_AufschuettungsFlaeche" TO xp_gast;
GRANT ALL ON TABLE "BP_Aufschuettung_Abgrabung_Bodenschaetze"."BP_AufschuettungsFlaeche" TO bp_user;
CREATE INDEX "BP_AufschuettungsFlaeche_gidx" ON "BP_Aufschuettung_Abgrabung_Bodenschaetze"."BP_AufschuettungsFlaeche" using gist ("position");
COMMENT ON TABLE  "BP_Aufschuettung_Abgrabung_Bodenschaetze"."BP_AufschuettungsFlaeche" IS 'Flächen für Aufschüttungen, Abgrabungen oder für die Gewinnung von Bodenschätzen (§ 9 Abs. 1 Nr. 17 und Abs. 6 BauGB). Hier: Flächen für Aufschüttungen';
COMMENT ON COLUMN "BP_Aufschuettung_Abgrabung_Bodenschaetze"."BP_AufschuettungsFlaeche"."aufschuettungsmaterial" IS 'Bezeichnung des aufgeschütteten Materials';
CREATE TRIGGER "change_to_BP_AufschuettungsFlaeche" BEFORE INSERT OR UPDATE ON "BP_Aufschuettung_Abgrabung_Bodenschaetze"."BP_AufschuettungsFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_BP_AufschuettungsFlaeche" AFTER DELETE ON "BP_Aufschuettung_Abgrabung_Bodenschaetze"."BP_AufschuettungsFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "BP_AufschuettungsFlaeche_Flaechenobjekt" BEFORE INSERT OR UPDATE ON "BP_Aufschuettung_Abgrabung_Bodenschaetze"."BP_AufschuettungsFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isFlaechenobjekt"();

-- -----------------------------------------------------
-- Table "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_AusgleichsFlaeche"
-- -----------------------------------------------------
CREATE  TABLE  "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_AusgleichsFlaeche" (
  "gid" BIGINT NOT NULL ,
  "ziel" INTEGER NULL ,
  "sonstZiel" VARCHAR(255),
  "refMassnahmenText" INTEGER NULL ,
  "refLandschaftsplan" INTEGER NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_BP_AusgleichsFlaeche_XP_SPEZiele1"
    FOREIGN KEY ("ziel" )
    REFERENCES "XP_Enumerationen"."XP_SPEZiele" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_BP_AusgleichsFlaeche_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "BP_Basisobjekte"."BP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_BP_AusgleichsFlaeche_XP_ExterneReferenz1"
    FOREIGN KEY ("refMassnahmenText" )
    REFERENCES "XP_Basisobjekte"."XP_ExterneReferenz" ("id" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_BP_AusgleichsFlaeche_XP_ExterneReferenz2"
    FOREIGN KEY ("refLandschaftsplan" )
    REFERENCES "XP_Basisobjekte"."XP_ExterneReferenz" ("id" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE)
INHERITS("BP_Basisobjekte"."BP_Flaechenobjekt");

GRANT SELECT ON TABLE "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_AusgleichsFlaeche" TO xp_gast;
GRANT ALL ON TABLE "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_AusgleichsFlaeche" TO bp_user;
CREATE INDEX "BP_AusgleichsFlaeche_gidx" ON "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_AusgleichsFlaeche" using gist ("position");
COMMENT ON TABLE  "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_AusgleichsFlaeche" IS 'Festsetzung einer Fläche zum Ausgleich im Sinne des § 1a Abs.3 und §9 Abs. 1a BauGB.';
COMMENT ON COLUMN  "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_AusgleichsFlaeche"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN  "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_AusgleichsFlaeche"."ziel" IS 'Unterscheidung nach den Zielen "Schutz, Pflege" und "Entwicklung".';
COMMENT ON COLUMN "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_AusgleichsFlaeche"."sonstZiel" IS 'Textlich formuliertes Ziel, wenn das Attribut ziel den Wert 9999 (Sonstiges) hat.';
COMMENT ON COLUMN  "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_AusgleichsFlaeche"."refMassnahmenText" IS 'Referenz auf ein Dokument, das die durchzuführenden Massnahmen beschreibt.';
COMMENT ON COLUMN  "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_AusgleichsFlaeche"."refLandschaftsplan" IS 'Referenz auf den Landschaftsplan.';
CREATE INDEX "idx_fk_BP_AusgleichsFlaeche_XP_SPEZiele1" ON "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_AusgleichsFlaeche" ("ziel") ;
CREATE INDEX "idx_fk_BP_AusgleichsFlaeche_externeReferenz1" ON "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_AusgleichsFlaeche" ("refMassnahmenText") ;
CREATE INDEX "idx_fk_BP_AusgleichsFlaeche_externeReferenz2" ON "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_AusgleichsFlaeche" ("refLandschaftsplan") ;
CREATE TRIGGER "change_to_BP_AusgleichsFlaeche" BEFORE INSERT OR UPDATE ON "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_AusgleichsFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_BP_AusgleichsFlaeche" AFTER DELETE ON "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_AusgleichsFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "BP_AusgleichsFlaeche_Flaechenobjekt" BEFORE INSERT OR UPDATE ON "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_AusgleichsFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isFlaechenobjekt"();

-- -----------------------------------------------------
-- Table "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_AusgleichsFlaeche_massnahme"
-- -----------------------------------------------------
CREATE  TABLE  "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_AusgleichsFlaeche_massnahme" (
  "BP_AusgleichsFlaeche_gid" BIGINT NOT NULL ,
  "massnahme" INTEGER NOT NULL ,
  PRIMARY KEY ("BP_AusgleichsFlaeche_gid", "massnahme"),
  CONSTRAINT "fk_BP_AusgleichsFlaeche_massnahme1"
    FOREIGN KEY ("BP_AusgleichsFlaeche_gid" )
    REFERENCES "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_AusgleichsFlaeche" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_BP_AusgleichsFlaeche_massnahme2"
    FOREIGN KEY ("massnahme" )
    REFERENCES "XP_Basisobjekte"."XP_SPEMassnahmenDaten" ("id" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
GRANT SELECT ON TABLE "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_AusgleichsFlaeche_massnahme" TO xp_gast;
GRANT ALL ON TABLE "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_AusgleichsFlaeche_massnahme" TO bp_user;
COMMENT ON TABLE  "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_AusgleichsFlaeche_massnahme" IS 'Auf der Fläche durchzuführende Maßnahmen.';

-- -----------------------------------------------------
-- Table "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_AusgleichsMassnahme"
-- -----------------------------------------------------
CREATE  TABLE  "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_AusgleichsMassnahme" (
  "gid" BIGINT NOT NULL ,
  "ziel" INTEGER NULL ,
  "sonstZiel" VARCHAR(255),
  "refMassnahmenText" INTEGER NULL ,
  "refLandschaftsplan" INTEGER NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_BP_AusgleichsMassnahme_XP_SPEZiele1"
    FOREIGN KEY ("ziel" )
    REFERENCES "XP_Enumerationen"."XP_SPEZiele" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_BP_AusgleichsMassnahme_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "BP_Basisobjekte"."BP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_BP_AusgleichsMassnahme_XP_ExterneReferenz1"
    FOREIGN KEY ("refMassnahmenText" )
    REFERENCES "XP_Basisobjekte"."XP_ExterneReferenz" ("id" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_BP_AusgleichsMassnahme_XP_ExterneReferenz2"
    FOREIGN KEY ("refLandschaftsplan" )
    REFERENCES "XP_Basisobjekte"."XP_ExterneReferenz" ("id" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE);

GRANT SELECT ON TABLE "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_AusgleichsMassnahme" TO xp_gast;
GRANT ALL ON TABLE "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_AusgleichsMassnahme" TO bp_user;
COMMENT ON TABLE  "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_AusgleichsMassnahme" IS 'Festsetzung einer Einzelmaßnahme zum Ausgleich im Sinne des § 1a Abs.3 und §9 Abs. 1a BauGB.';
COMMENT ON COLUMN  "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_AusgleichsMassnahme"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN  "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_AusgleichsMassnahme"."ziel" IS 'Ziel der Ausgleichsmassnahme';
COMMENT ON COLUMN "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_AusgleichsMassnahme"."sonstZiel" IS 'Textlich formuliertes Ziel, wenn das Attribut ziel den Wert 9999 (Sonstiges) hat.';
COMMENT ON COLUMN  "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_AusgleichsMassnahme"."refMassnahmenText" IS 'Referenz auf ein Dokument, das die durchzuführenden Maßnahmen beschreibt.';
COMMENT ON COLUMN  "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_AusgleichsMassnahme"."refLandschaftsplan" IS 'Referenz auf den Landschaftsplan.';
CREATE INDEX "idx_fk_BP_AusgleichsMassnahme_XP_SPEZiele1" ON "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_AusgleichsMassnahme" ("ziel") ;
CREATE INDEX "idx_fk_BP_AusgleichsMassnahme_externeReferenz1" ON "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_AusgleichsMassnahme" ("refMassnahmenText") ;
CREATE INDEX "idx_fk_BP_AusgleichsMassnahme_externeReferenz2" ON "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_AusgleichsMassnahme" ("refLandschaftsplan") ;
CREATE TRIGGER "change_to_BP_AusgleichsMassnahme" BEFORE INSERT OR UPDATE ON "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_AusgleichsMassnahme" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_BP_AusgleichsMassnahme" AFTER DELETE ON "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_AusgleichsMassnahme" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_AusgleichsMassnahme_massnahme"
-- -----------------------------------------------------
CREATE  TABLE  "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_AusgleichsMassnahme_massnahme" (
  "BP_AusgleichsMassnahme_gid" BIGINT NOT NULL ,
  "massnahme" INTEGER NOT NULL ,
  PRIMARY KEY ("BP_AusgleichsMassnahme_gid", "massnahme"),
  CONSTRAINT "fk_BP_AusgleichsMassnahme_massnahme1"
    FOREIGN KEY ("BP_AusgleichsMassnahme_gid" )
    REFERENCES "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_AusgleichsMassnahme" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_BP_AusgleichsMassnahme_massnahme2"
    FOREIGN KEY ("massnahme" )
    REFERENCES "XP_Basisobjekte"."XP_SPEMassnahmenDaten" ("id" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
GRANT SELECT ON TABLE "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_AusgleichsMassnahme_massnahme" TO xp_gast;
GRANT ALL ON TABLE "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_AusgleichsMassnahme_massnahme" TO bp_user;
COMMENT ON TABLE  "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_AusgleichsMassnahme_massnahme" IS 'Durchzuführende Ausgleichsmaßnahmen.';

-- -----------------------------------------------------
-- Table "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_AusgleichsMassnahmeFlaeche"
-- -----------------------------------------------------
CREATE  TABLE  "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_AusgleichsMassnahmeFlaeche" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_BP_AusgleichsMassnahmeFlaeche_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_AusgleichsMassnahme" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("BP_Basisobjekte"."BP_Flaechenobjekt");

GRANT SELECT ON TABLE "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_AusgleichsMassnahmeFlaeche" TO xp_gast;
GRANT ALL ON TABLE "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_AusgleichsMassnahmeFlaeche" TO bp_user;
CREATE INDEX "BP_AusgleichsMassnahmeFlaeche_gidx" ON "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_AusgleichsMassnahmeFlaeche" using gist ("position");
CREATE TRIGGER "change_to_BP_AusgleichsMassnahmeFlaeche" BEFORE INSERT OR UPDATE ON "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_AusgleichsMassnahmeFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_BP_AusgleichsMassnahmeFlaeche" AFTER DELETE ON "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_AusgleichsMassnahmeFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "BP_AusgleichsMassnahmeFlaeche_Flaechenobjekt" BEFORE INSERT OR UPDATE ON "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_AusgleichsMassnahmeFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isFlaechenobjekt"();

-- -----------------------------------------------------
-- Table "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_AusgleichsMassnahmeLinie"
-- -----------------------------------------------------
CREATE  TABLE  "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_AusgleichsMassnahmeLinie" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_BP_AusgleichsMassnahmeLinie_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_AusgleichsMassnahme" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("BP_Basisobjekte"."BP_Linienobjekt");

GRANT SELECT ON TABLE "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_AusgleichsMassnahmeLinie" TO xp_gast;
GRANT ALL ON TABLE "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_AusgleichsMassnahmeLinie" TO bp_user;
CREATE INDEX "BP_AusgleichsMassnahmeLinie_gidx" ON "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_AusgleichsMassnahmeLinie" using gist ("position");
CREATE TRIGGER "change_to_BP_AusgleichsMassnahmeLinie" BEFORE INSERT OR UPDATE ON "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_AusgleichsMassnahmeLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_BP_AusgleichsMassnahmeLinie" AFTER DELETE ON "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_AusgleichsMassnahmeLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_AusgleichsMassnahmePunkt"
-- -----------------------------------------------------
CREATE  TABLE  "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_AusgleichsMassnahmePunkt" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_BP_AusgleichsMassnahmePunkt_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_AusgleichsMassnahme" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("BP_Basisobjekte"."BP_Punktobjekt");

GRANT SELECT ON TABLE "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_AusgleichsMassnahmePunkt" TO xp_gast;
GRANT ALL ON TABLE "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_AusgleichsMassnahmePunkt" TO bp_user;
CREATE INDEX "BP_AusgleichsMassnahmePunkt_gidx" ON "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_AusgleichsMassnahmePunkt" using gist ("position");
CREATE TRIGGER "change_to_BP_AusgleichsMassnahmePunkt" BEFORE INSERT OR UPDATE ON "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_AusgleichsMassnahmePunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_BP_AusgleichsMassnahmePunkt" AFTER DELETE ON "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_AusgleichsMassnahmePunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "BP_Verkehr"."BP_BereichOhneEinAusfahrtTypen"
-- -----------------------------------------------------
CREATE  TABLE  "BP_Verkehr"."BP_BereichOhneEinAusfahrtTypen" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Code") );
GRANT SELECT ON "BP_Verkehr"."BP_BereichOhneEinAusfahrtTypen" TO xp_gast;

-- -----------------------------------------------------
-- Table "BP_Verkehr"."BP_BereichOhneEinAusfahrtLinie"
-- -----------------------------------------------------
CREATE  TABLE  "BP_Verkehr"."BP_BereichOhneEinAusfahrtLinie" (
  "gid" BIGINT NOT NULL ,
  "typ" INTEGER,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_BP_BereichOhneEinAusfahrtLinie_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "BP_Basisobjekte"."BP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_BP_BereichOhneEinAusfahrtLinie_typ"
    FOREIGN KEY ("typ" )
    REFERENCES "BP_Verkehr"."BP_BereichOhneEinAusfahrtTypen" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE)
INHERITS ("BP_Basisobjekte"."BP_Linienobjekt");

GRANT SELECT ON TABLE "BP_Verkehr"."BP_BereichOhneEinAusfahrtLinie" TO xp_gast;
GRANT ALL ON TABLE "BP_Verkehr"."BP_BereichOhneEinAusfahrtLinie" TO bp_user;
CREATE INDEX "BP_BereichOhneEinAusfahrtLinie_gidx" ON "BP_Verkehr"."BP_BereichOhneEinAusfahrtLinie" using gist ("position");
COMMENT ON TABLE "BP_Verkehr"."BP_BereichOhneEinAusfahrtLinie" IS 'Bereich ohne Ein- und Ausfahrt (§9 Abs. 1 Nr. 11 und Abs. 6 BauGB). Durch die Digitalisierungsreihenfolge der Linienstützpunkte muss sichergestellt sein, dass der angrenzende Bereich ohne Ein- und Ausfahrt relativ zur Laufrichtung auf der linken Seite liegt.';
COMMENT ON COLUMN  "BP_Verkehr"."BP_BereichOhneEinAusfahrtLinie"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN "BP_Verkehr"."BP_BereichOhneEinAusfahrtLinie"."typ" IS 'Typ der EIn- oder Ausfahrt.';
CREATE INDEX "idx_fk_BP_BereichOhneEinAusfahrtLinie_typ" ON "BP_Verkehr"."BP_BereichOhneEinAusfahrtLinie" ("typ") ;
CREATE TRIGGER "change_to_BP_BereichOhneEinAusfahrtLinie" BEFORE INSERT OR UPDATE ON "BP_Verkehr"."BP_BereichOhneEinAusfahrtLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_BP_BereichOhneEinAusfahrtLinie" AFTER DELETE ON "BP_Verkehr"."BP_BereichOhneEinAusfahrtLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "BP_Aufschuettung_Abgrabung_Bodenschaetze"."BP_BodenschaetzeFlaeche"
-- -----------------------------------------------------
CREATE  TABLE  "BP_Aufschuettung_Abgrabung_Bodenschaetze"."BP_BodenschaetzeFlaeche" (
  "gid" BIGINT NOT NULL ,
  "abbaugut" CHARACTER VARYING(64),
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_BP_BodenschaetzeFlaeche_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "BP_Basisobjekte"."BP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("BP_Basisobjekte"."BP_Flaechenobjekt");

GRANT SELECT ON TABLE "BP_Aufschuettung_Abgrabung_Bodenschaetze"."BP_BodenschaetzeFlaeche" TO xp_gast;
CREATE INDEX "BP_BodenschaetzeFlaeche_gidx" ON "BP_Aufschuettung_Abgrabung_Bodenschaetze"."BP_BodenschaetzeFlaeche" using gist ("position");
COMMENT ON TABLE "BP_Aufschuettung_Abgrabung_Bodenschaetze"."BP_BodenschaetzeFlaeche" IS 'Flächen für Aufschüttungen, Abgrabungen oder für die Gewinnung von Bodenschätzen (§ 9 Abs. 1 Nr. 17 und Abs. 6 BauGB). Hier: Flächen für Gewinnung von Bodenschätzen
Die Klasse wird als veraltet gekennzeichnet und wird in XPlanGML V. 6.0 wegfallen. Es sollte stattdessen die Klasse BP_AbgrabungsFlaeche verwendet werden.';
COMMENT ON COLUMN  "BP_Aufschuettung_Abgrabung_Bodenschaetze"."BP_BodenschaetzeFlaeche"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN "BP_Aufschuettung_Abgrabung_Bodenschaetze"."BP_BodenschaetzeFlaeche"."abbaugut" IS 'Bezeichnung des Abbauguts.';
CREATE TRIGGER "change_to_BP_BodenschaetzeFlaeche" BEFORE INSERT OR UPDATE ON "BP_Aufschuettung_Abgrabung_Bodenschaetze"."BP_BodenschaetzeFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_BP_BodenschaetzeFlaeche" AFTER DELETE ON "BP_Aufschuettung_Abgrabung_Bodenschaetze"."BP_BodenschaetzeFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "BP_BodenschaetzeFlaeche_Flaechenobjekt" BEFORE INSERT OR UPDATE ON "BP_Aufschuettung_Abgrabung_Bodenschaetze"."BP_BodenschaetzeFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isFlaechenobjekt"();

-- -----------------------------------------------------
-- Table "BP_Verkehr"."BP_EinfahrtTypen"
-- -----------------------------------------------------
CREATE  TABLE  "BP_Verkehr"."BP_EinfahrtTypen" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Code") );
GRANT SELECT ON "BP_Verkehr"."BP_EinfahrtTypen" TO xp_gast;

-- -----------------------------------------------------
-- Table "BP_Verkehr"."BP_EinfahrtPunkt"
-- -----------------------------------------------------
CREATE  TABLE  "BP_Verkehr"."BP_EinfahrtPunkt" (
  "gid" BIGINT NOT NULL ,
  "typ" INTEGER NULL,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_BP_EinfahrtPunkt_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "BP_Basisobjekte"."BP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_BP_EinfahrtPunkt_typ"
    FOREIGN KEY ("typ" )
    REFERENCES "BP_Verkehr"."BP_EinfahrtTypen" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE)
INHERITS ("BP_Basisobjekte"."BP_Punktobjekt");

GRANT SELECT ON TABLE "BP_Verkehr"."BP_EinfahrtPunkt" TO xp_gast;
GRANT ALL ON TABLE "BP_Verkehr"."BP_EinfahrtPunkt" TO bp_user;
CREATE INDEX "BP_EinfahrtPunkt_gidx" ON "BP_Verkehr"."BP_EinfahrtPunkt" using gist ("position");
COMMENT ON TABLE "BP_Verkehr"."BP_EinfahrtPunkt" IS 'Einfahrt (§9 Abs. 1 Nr. 11 und Abs. 6 BauGB).';
COMMENT ON COLUMN  "BP_Verkehr"."BP_EinfahrtPunkt"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN  "BP_Verkehr"."BP_EinfahrtPunkt"."typ" IS 'Typ der Einfahrt';
CREATE TRIGGER "change_to_BP_EinfahrtPunkt" BEFORE INSERT OR UPDATE ON "BP_Verkehr"."BP_EinfahrtPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_BP_EinfahrtPunkt" AFTER DELETE ON "BP_Verkehr"."BP_EinfahrtPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "BP_Verkehr"."BP_EinfahrtsbereichLinie"
-- -----------------------------------------------------
CREATE  TABLE  "BP_Verkehr"."BP_EinfahrtsbereichLinie" (
  "gid" BIGINT NOT NULL ,
  "typ" INTEGER NULL,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_BP_EinfahrtsbereichLinie_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "BP_Basisobjekte"."BP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_BP_EinfahrtsbereichLinie_typ"
    FOREIGN KEY ("typ" )
    REFERENCES "BP_Verkehr"."BP_EinfahrtTypen" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE)
INHERITS ("BP_Basisobjekte"."BP_Linienobjekt");

GRANT SELECT ON TABLE "BP_Verkehr"."BP_EinfahrtsbereichLinie" TO xp_gast;
GRANT ALL ON TABLE "BP_Verkehr"."BP_EinfahrtsbereichLinie" TO bp_user;
CREATE INDEX "BP_EinfahrtsbereichLinie_gidx" ON "BP_Verkehr"."BP_EinfahrtsbereichLinie" using gist ("position");
COMMENT ON TABLE "BP_Verkehr"."BP_EinfahrtsbereichLinie" IS 'Einfahrtsbereich (§9 Abs. 1 Nr. 11 und Abs. 6 BauGB). Durch die Digitalisierungsreihenfolge der Linienstützpunkte muss sichergestellt sein, dass die angrenzende Einfahrt relativ zur Laufrichtung auf der linken Seite liegt.';
COMMENT ON COLUMN  "BP_Verkehr"."BP_EinfahrtsbereichLinie"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN "BP_Verkehr"."BP_EinfahrtsbereichLinie"."typ" IS 'Typ der Einfahrt';
CREATE TRIGGER "change_to_BP_EinfahrtsbereichLinie" BEFORE INSERT OR UPDATE ON "BP_Verkehr"."BP_EinfahrtsbereichLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_BP_EinfahrtsbereichLinie" AFTER DELETE ON "BP_Verkehr"."BP_EinfahrtsbereichLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_EingriffsBereich"
-- -----------------------------------------------------
CREATE  TABLE  "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_EingriffsBereich" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_BP_EingriffsBereich_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "BP_Basisobjekte"."BP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("BP_Basisobjekte"."BP_Flaechenobjekt");

GRANT SELECT ON TABLE "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_EingriffsBereich" TO xp_gast;
GRANT ALL ON TABLE "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_EingriffsBereich" TO bp_user;
CREATE INDEX "BP_EingriffsBereich_gidx" ON "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_EingriffsBereich" using gist ("position");
COMMENT ON TABLE "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_EingriffsBereich" IS 'Bestimmt einen Bereich, in dem ein Eingriff nach dem Naturschutzrecht zugelassen wird, der durch geeignete Flächen oder Maßnahmen ausgeglichen werden muss.';
COMMENT ON COLUMN  "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_EingriffsBereich"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_BP_EingriffsBereich" BEFORE INSERT OR UPDATE ON "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_EingriffsBereich" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_BP_EingriffsBereich" AFTER DELETE ON "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_EingriffsBereich" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "ueberlagerung_BP_EingriffsBereich" BEFORE INSERT OR UPDATE ON "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_EingriffsBereich" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isUeberlagerungsobjekt"();

-- -----------------------------------------------------
-- Table "BP_Erhaltungssatzung_und_Denkmalschutz"."BP_ErhaltungsGrund"
-- -----------------------------------------------------
CREATE  TABLE  "BP_Erhaltungssatzung_und_Denkmalschutz"."BP_ErhaltungsGrund" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Code") );
GRANT SELECT ON "BP_Erhaltungssatzung_und_Denkmalschutz"."BP_ErhaltungsGrund" TO xp_gast;

-- -----------------------------------------------------
-- Table "BP_Erhaltungssatzung_und_Denkmalschutz"."BP_ErhaltungsBereichFlaeche"
-- -----------------------------------------------------
CREATE  TABLE  "BP_Erhaltungssatzung_und_Denkmalschutz"."BP_ErhaltungsBereichFlaeche" (
  "gid" BIGINT NOT NULL ,
  "grund" INTEGER NOT NULL DEFAULT 1000,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_BP_ErhaltungsBereichFlaeche_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "BP_Basisobjekte"."BP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_BP_ErhaltungsBereichFlaeche_grund"
    FOREIGN KEY ("grund" )
    REFERENCES "BP_Erhaltungssatzung_und_Denkmalschutz"."BP_ErhaltungsGrund" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE)
INHERITS ("BP_Basisobjekte"."BP_Flaechenobjekt");

GRANT SELECT ON TABLE "BP_Erhaltungssatzung_und_Denkmalschutz"."BP_ErhaltungsBereichFlaeche" TO xp_gast;
CREATE INDEX "BP_ErhaltungsBereichFlaeche_gidx" ON "BP_Erhaltungssatzung_und_Denkmalschutz"."BP_ErhaltungsBereichFlaeche" using gist ("position");
COMMENT ON TABLE "BP_Erhaltungssatzung_und_Denkmalschutz"."BP_ErhaltungsBereichFlaeche" IS 'Fläche, auf denen der Rückbau, die Änderung oder die Nutzungsänderung baulichen Anlagen der Genehmigung durch die Gemeinde bedarf (§172 BauGB)
Die Klasse wird als veraltet gekennzeichnet und fällt in XPlanGML V. 6.0 weg. Stattdessen sollte die Klasse SO_Gebiet verwendet werden.';
COMMENT ON COLUMN  "BP_Erhaltungssatzung_und_Denkmalschutz"."BP_ErhaltungsBereichFlaeche"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN  "BP_Erhaltungssatzung_und_Denkmalschutz"."BP_ErhaltungsBereichFlaeche"."grund" IS 'Erhaltungsgrund';
CREATE INDEX "idx_fk_BP_ErhaltungsBereichFlaeche_grund" ON "BP_Erhaltungssatzung_und_Denkmalschutz"."BP_ErhaltungsBereichFlaeche" ("grund") ;
CREATE TRIGGER "change_to_BP_ErhaltungsBereichFlaeche" BEFORE INSERT OR UPDATE ON "BP_Erhaltungssatzung_und_Denkmalschutz"."BP_ErhaltungsBereichFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_BP_ErhaltungsBereichFlaeche" AFTER DELETE ON "BP_Erhaltungssatzung_und_Denkmalschutz"."BP_ErhaltungsBereichFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "ueberlagerung_BP_ErhaltungsBereichFlaeche" BEFORE INSERT OR UPDATE ON "BP_Erhaltungssatzung_und_Denkmalschutz"."BP_ErhaltungsBereichFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isUeberlagerungsobjekt"();

-- -----------------------------------------------------
-- Table "BP_Umwelt"."BP_ErneuerbareEnergieFlaeche"
-- -----------------------------------------------------
CREATE  TABLE  "BP_Umwelt"."BP_ErneuerbareEnergieFlaeche" (
  "gid" BIGINT NOT NULL ,
  "technischeMassnahme" CHARACTER VARYING(256),
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_BP_ErneuerbareEnergieFlaeche_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "BP_Basisobjekte"."BP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("BP_Basisobjekte"."BP_Flaechenobjekt");

GRANT SELECT ON TABLE "BP_Umwelt"."BP_ErneuerbareEnergieFlaeche" TO xp_gast;
GRANT ALL ON TABLE "BP_Umwelt"."BP_ErneuerbareEnergieFlaeche" TO bp_user;
CREATE INDEX "BP_ErneuerbareEnergieFlaeche_gidx" ON "BP_Umwelt"."BP_ErneuerbareEnergieFlaeche" using gist ("position");
COMMENT ON TABLE "BP_Umwelt"."BP_ErneuerbareEnergieFlaeche" IS 'Festsetzung nach §9 Abs. 1 Nr. 23b: Gebiete in denen bei der Errichtung von Gebäuden bestimmte bauliche Maßnahmen für den Einsatz erneuerbarer Energien wie insbesondere Solarenergie getroffen werden müssen.';
COMMENT ON COLUMN  "BP_Umwelt"."BP_ErneuerbareEnergieFlaeche"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN  "BP_Umwelt"."BP_ErneuerbareEnergieFlaeche"."technischeMassnahme" IS 'Beschreibung der baulichen oder sonstigen technischen Maßnahme.';
CREATE TRIGGER "change_to_BP_ErneuerbareEnergieFlaeche" BEFORE INSERT OR UPDATE ON "BP_Umwelt"."BP_ErneuerbareEnergieFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_BP_ErneuerbareEnergieFlaeche" AFTER DELETE ON "BP_Umwelt"."BP_ErneuerbareEnergieFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "ueberlagerung_BP_ErneuerbareEnergieFlaeche" BEFORE INSERT OR UPDATE ON "BP_Umwelt"."BP_ErneuerbareEnergieFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isUeberlagerungsobjekt"();

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
-- Table "BP_Sonstiges"."BP_FestsetzungNachLandesrecht"
-- -----------------------------------------------------
CREATE  TABLE  "BP_Sonstiges"."BP_FestsetzungNachLandesrecht" (
  "gid" BIGINT NOT NULL ,
  "kurzbeschreibung" CHARACTER VARYING(256),
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_BP_FestsetzungNachLandesrecht_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "BP_Basisobjekte"."BP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE);

GRANT SELECT ON TABLE "BP_Sonstiges"."BP_FestsetzungNachLandesrecht" TO xp_gast;
GRANT ALL ON TABLE "BP_Sonstiges"."BP_FestsetzungNachLandesrecht" TO bp_user;
COMMENT ON TABLE "BP_Sonstiges"."BP_FestsetzungNachLandesrecht" IS 'Festsetzung nach §9 Nr. (4) BauGB';
COMMENT ON COLUMN  "BP_Sonstiges"."BP_FestsetzungNachLandesrecht"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN  "BP_Sonstiges"."BP_FestsetzungNachLandesrecht"."kurzbeschreibung" IS 'Kurzbeschreibung der Festsetzung';
CREATE TRIGGER "change_to_BP_FestsetzungNachLandesrecht" BEFORE INSERT OR UPDATE ON "BP_Sonstiges"."BP_FestsetzungNachLandesrecht" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_BP_FestsetzungNachLandesrecht" AFTER DELETE ON "BP_Sonstiges"."BP_FestsetzungNachLandesrecht" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "BP_Sonstiges"."BP_FestsetzungNachLandesrechtFlaeche"
-- -----------------------------------------------------
CREATE  TABLE  "BP_Sonstiges"."BP_FestsetzungNachLandesrechtFlaeche" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_BP_FestsetzungNachLandesrechtFlaeche_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "BP_Sonstiges"."BP_FestsetzungNachLandesrecht" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("BP_Basisobjekte"."BP_Flaechenobjekt");

GRANT SELECT ON TABLE "BP_Sonstiges"."BP_FestsetzungNachLandesrechtFlaeche" TO xp_gast;
GRANT ALL ON TABLE "BP_Sonstiges"."BP_FestsetzungNachLandesrechtFlaeche" TO bp_user;
CREATE INDEX "BP_FestsetzungNachLandesrechtFlaeche_gidx" ON "BP_Sonstiges"."BP_FestsetzungNachLandesrechtFlaeche" using gist ("position");
CREATE TRIGGER "change_to_BP_FestsetzungNachLandesrechtFlaeche" BEFORE INSERT OR UPDATE ON "BP_Sonstiges"."BP_FestsetzungNachLandesrechtFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_BP_FestsetzungNachLandesrechtFlaeche" AFTER DELETE ON "BP_Sonstiges"."BP_FestsetzungNachLandesrechtFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "BP_FestsetzungNachLandesrechtFlaeche_Flaechenobjekt" BEFORE INSERT OR UPDATE ON "BP_Sonstiges"."BP_FestsetzungNachLandesrechtFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isFlaechenobjekt"();

-- -----------------------------------------------------
-- Table "BP_Sonstiges"."BP_FestsetzungNachLandesrechtLinie"
-- -----------------------------------------------------
CREATE  TABLE  "BP_Sonstiges"."BP_FestsetzungNachLandesrechtLinie" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_BP_FestsetzungNachLandesrechtLinie_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "BP_Sonstiges"."BP_FestsetzungNachLandesrecht" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("BP_Basisobjekte"."BP_Linienobjekt");

GRANT SELECT ON TABLE "BP_Sonstiges"."BP_FestsetzungNachLandesrechtLinie" TO xp_gast;
GRANT ALL ON TABLE "BP_Sonstiges"."BP_FestsetzungNachLandesrechtLinie" TO bp_user;
CREATE INDEX "BP_FestsetzungNachLandesrechtLinie_gidx" ON "BP_Sonstiges"."BP_FestsetzungNachLandesrechtLinie" using gist ("position");
CREATE TRIGGER "change_to_BP_FestsetzungNachLandesrechtLinie" BEFORE INSERT OR UPDATE ON "BP_Sonstiges"."BP_FestsetzungNachLandesrechtLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_BP_FestsetzungNachLandesrechtLinie" AFTER DELETE ON "BP_Sonstiges"."BP_FestsetzungNachLandesrechtLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "BP_Sonstiges"."BP_FestsetzungNachLandesrechtPunkt"
-- -----------------------------------------------------
CREATE  TABLE  "BP_Sonstiges"."BP_FestsetzungNachLandesrechtPunkt" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_BP_FestsetzungNachLandesrechtPunkt_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "BP_Sonstiges"."BP_FestsetzungNachLandesrecht" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("BP_Basisobjekte"."BP_Punktobjekt");

GRANT SELECT ON TABLE "BP_Sonstiges"."BP_FestsetzungNachLandesrechtPunkt" TO xp_gast;
GRANT ALL ON TABLE "BP_Sonstiges"."BP_FestsetzungNachLandesrechtPunkt" TO bp_user;
CREATE INDEX "BP_FestsetzungNachLandesrechtPunkt_gidx" ON "BP_Sonstiges"."BP_FestsetzungNachLandesrechtPunkt" using gist ("position");
CREATE TRIGGER "change_to_BP_FestsetzungNachLandesrechtPunkt" BEFORE INSERT OR UPDATE ON "BP_Sonstiges"."BP_FestsetzungNachLandesrechtPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_BP_FestsetzungNachLandesrechtPunkt" AFTER DELETE ON "BP_Sonstiges"."BP_FestsetzungNachLandesrechtPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "BP_Sonstiges"."BP_FreiFlaeche"
-- -----------------------------------------------------
CREATE  TABLE  "BP_Sonstiges"."BP_FreiFlaeche" (
  "gid" BIGINT NOT NULL ,
  "nutzung" CHARACTER VARYING(256),
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_BP_FreiFlaeche_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "BP_Basisobjekte"."BP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("BP_Basisobjekte"."BP_Flaechenobjekt");

GRANT SELECT ON TABLE "BP_Sonstiges"."BP_FreiFlaeche" TO xp_gast;
GRANT ALL ON TABLE "BP_Sonstiges"."BP_FreiFlaeche" TO bp_user;
CREATE INDEX "BP_FreiFlaeche_gidx" ON "BP_Sonstiges"."BP_FreiFlaeche" using gist ("position");
COMMENT ON TABLE "BP_Sonstiges"."BP_FreiFlaeche" IS 'Umgrenzung der Flächen, die von der Bebauung freizuhalten sind, und ihre Nutzung (§ 9 Abs. 1 Nr. 10 BauGB).';
COMMENT ON COLUMN  "BP_Sonstiges"."BP_FreiFlaeche"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN  "BP_Sonstiges"."BP_FreiFlaeche"."nutzung" IS 'Festgesetzte Nutzung der Freifläche.';
CREATE TRIGGER "change_to_BP_FreiFlaeche" BEFORE INSERT OR UPDATE ON "BP_Sonstiges"."BP_FreiFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_BP_FreiFlaeche" AFTER DELETE ON "BP_Sonstiges"."BP_FreiFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "ueberlagerung_BP_FreiFlaeche" BEFORE INSERT OR UPDATE ON "BP_Sonstiges"."BP_FreiFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isUeberlagerungsobjekt"();

-- -----------------------------------------------------
-- Table "BP_Sonstiges"."BP_ZweckbestimmungGenerischeObjekte"
-- -----------------------------------------------------
CREATE  TABLE  "BP_Sonstiges"."BP_ZweckbestimmungGenerischeObjekte" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Code") );
GRANT SELECT ON TABLE "BP_Sonstiges"."BP_ZweckbestimmungGenerischeObjekte" TO xp_gast;
GRANT ALL ON TABLE "BP_Sonstiges"."BP_ZweckbestimmungGenerischeObjekte" TO bp_user;
CREATE TRIGGER "ins_upd_BP_ZweckbestimmungGenerischeObjekte" BEFORE INSERT OR UPDATE ON "BP_Sonstiges"."BP_ZweckbestimmungGenerischeObjekte" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isCodeList"();

-- -----------------------------------------------------
-- Table "BP_Sonstiges"."BP_GenerischesObjekt"
-- -----------------------------------------------------
CREATE  TABLE  "BP_Sonstiges"."BP_GenerischesObjekt" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_BP_GenerischesObjekt_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "BP_Basisobjekte"."BP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE);

GRANT SELECT ON TABLE "BP_Sonstiges"."BP_GenerischesObjekt" TO xp_gast;
GRANT ALL ON TABLE "BP_Sonstiges"."BP_GenerischesObjekt" TO bp_user;
COMMENT ON TABLE "BP_Sonstiges"."BP_GenerischesObjekt" IS 'Klasse zur Modellierung aller Inhalte des BPlans, die keine nachrichtliche Übernahmen aus anderen Rechtsbereichen sind, aber durch keine andere Klasse des BPlan-Fachschemas dargestellt werden können.';
COMMENT ON COLUMN  "BP_Sonstiges"."BP_GenerischesObjekt"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_BP_GenerischesObjekt" BEFORE INSERT OR UPDATE ON "BP_Sonstiges"."BP_GenerischesObjekt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_BP_GenerischesObjekt" AFTER DELETE ON "BP_Sonstiges"."BP_GenerischesObjekt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table BP_Sonstiges"."BP_GenerischesObjekt_zweckbestimmung"
-- -----------------------------------------------------
CREATE  TABLE  "BP_Sonstiges"."BP_GenerischesObjekt_zweckbestimmung" (
  "BP_GenerischesObjekt_gid" BIGINT NOT NULL ,
  "zweckbestimmung" INTEGER NOT NULL ,
  PRIMARY KEY ("BP_GenerischesObjekt_gid", "zweckbestimmung"),
  CONSTRAINT "fk_BP_GenerischesObjekt_zweckbestimmung1"
    FOREIGN KEY ("BP_GenerischesObjekt_gid" )
    REFERENCES "BP_Sonstiges"."BP_GenerischesObjekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_BP_GenerischesObjekt_zweckbestimmung2"
    FOREIGN KEY ("zweckbestimmung" )
    REFERENCES "BP_Sonstiges"."BP_ZweckbestimmungGenerischeObjekte" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
GRANT SELECT ON TABLE "BP_Sonstiges"."BP_GenerischesObjekt_zweckbestimmung" TO xp_gast;
GRANT ALL ON TABLE "BP_Sonstiges"."BP_GenerischesObjekt_zweckbestimmung" TO bp_user;
COMMENT ON TABLE  "BP_Sonstiges"."BP_GenerischesObjekt_zweckbestimmung" IS 'Über eine CodeList definierte Zweckbestimmungen des Objekts.';

-- -----------------------------------------------------
-- Table "BP_Sonstiges"."BP_GenerischesObjektFlaeche"
-- -----------------------------------------------------
CREATE  TABLE  "BP_Sonstiges"."BP_GenerischesObjektFlaeche" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_BP_GenerischesObjektFlaeche_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "BP_Sonstiges"."BP_GenerischesObjekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("BP_Basisobjekte"."BP_Flaechenobjekt");

GRANT SELECT ON TABLE "BP_Sonstiges"."BP_GenerischesObjektFlaeche" TO xp_gast;
GRANT ALL ON TABLE "BP_Sonstiges"."BP_GenerischesObjektFlaeche" TO bp_user;
CREATE INDEX "BP_GenerischesObjektFlaeche_gidx" ON "BP_Sonstiges"."BP_GenerischesObjektFlaeche" using gist ("position");
CREATE TRIGGER "change_to_BP_GenerischesObjektFlaeche" BEFORE INSERT OR UPDATE ON "BP_Sonstiges"."BP_GenerischesObjektFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_BP_GenerischesObjektFlaeche" AFTER DELETE ON "BP_Sonstiges"."BP_GenerischesObjektFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "BP_GenerischesObjektFlaeche_Flaechenobjekt" BEFORE INSERT OR UPDATE ON "BP_Sonstiges"."BP_GenerischesObjektFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isFlaechenobjekt"();

-- -----------------------------------------------------
-- Table "BP_Sonstiges"."BP_GenerischesObjektLinie"
-- -----------------------------------------------------
CREATE  TABLE  "BP_Sonstiges"."BP_GenerischesObjektLinie" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_BP_GenerischesObjektLinie_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "BP_Sonstiges"."BP_GenerischesObjekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("BP_Basisobjekte"."BP_Linienobjekt");

GRANT SELECT ON TABLE "BP_Sonstiges"."BP_GenerischesObjektLinie" TO xp_gast;
GRANT ALL ON TABLE "BP_Sonstiges"."BP_GenerischesObjektLinie" TO bp_user;
CREATE INDEX "BP_GenerischesObjektLinie_gidx" ON "BP_Sonstiges"."BP_GenerischesObjektLinie" using gist ("position");
CREATE TRIGGER "change_to_BP_GenerischesObjektLinie" BEFORE INSERT OR UPDATE ON "BP_Sonstiges"."BP_GenerischesObjektLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_BP_GenerischesObjektLinie" AFTER DELETE ON "BP_Sonstiges"."BP_GenerischesObjektLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "BP_Sonstiges"."BP_GenerischesObjektPunkt"
-- -----------------------------------------------------
CREATE  TABLE  "BP_Sonstiges"."BP_GenerischesObjektPunkt" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_BP_GenerischesObjektPunkt_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "BP_Sonstiges"."BP_GenerischesObjekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("BP_Basisobjekte"."BP_Punktobjekt");

GRANT SELECT ON TABLE "BP_Sonstiges"."BP_GenerischesObjektPunkt" TO xp_gast;
GRANT ALL ON TABLE "BP_Sonstiges"."BP_GenerischesObjektPunkt" TO bp_user;
CREATE INDEX "BP_GenerischesObjektPunkt_gidx" ON "BP_Sonstiges"."BP_GenerischesObjektPunkt" using gist ("position");
CREATE TRIGGER "change_to_BP_GenerischesObjektPunkt" BEFORE INSERT OR UPDATE ON "BP_Sonstiges"."BP_GenerischesObjektPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_BP_GenerischesObjektPunkt" AFTER DELETE ON "BP_Sonstiges"."BP_GenerischesObjektPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "BP_Wasser"."BP_DetailZweckbestGewaesser"
-- -----------------------------------------------------
CREATE  TABLE  "BP_Wasser"."BP_DetailZweckbestGewaesser" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Code") );
GRANT SELECT ON TABLE "BP_Wasser"."BP_DetailZweckbestGewaesser" TO xp_gast;
GRANT ALL ON "BP_Wasser"."BP_DetailZweckbestGewaesser" TO bp_user;
CREATE TRIGGER "ins_upd_BP_DetailZweckbestGewaesser" BEFORE INSERT OR UPDATE ON "BP_Wasser"."BP_DetailZweckbestGewaesser" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isCodeList"();

-- -----------------------------------------------------
-- Table "BP_Wasser"."BP_GewaesserFlaeche"
-- -----------------------------------------------------
CREATE  TABLE  "BP_Wasser"."BP_GewaesserFlaeche" (
  "gid" BIGINT NOT NULL ,
  "zweckbestimmung" INTEGER,
  "detaillierteZweckbestimmung" INTEGER,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_BP_GewaesserFlaeche_XP_ZweckbestimmungGewaesser"
    FOREIGN KEY ("zweckbestimmung" )
    REFERENCES "XP_Enumerationen"."XP_ZweckbestimmungGewaesser" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_BP_GewaesserFlaeche_BP_DetailZweckbestGewaesser1"
    FOREIGN KEY ("detaillierteZweckbestimmung" )
    REFERENCES "BP_Wasser"."BP_DetailZweckbestGewaesser" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_BP_GewaesserFlaeche_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "BP_Basisobjekte"."BP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("BP_Basisobjekte"."BP_Flaechenobjekt");

CREATE INDEX "idx_fk_BP_GewaesserFlaeche_XP_ZweckbestimmungGewaesser" ON "BP_Wasser"."BP_GewaesserFlaeche" ("zweckbestimmung") ;
CREATE INDEX "idx_fk_BP_GewaesserFlaeche_BP_DetailZweckbestGewaesser1" ON "BP_Wasser"."BP_GewaesserFlaeche" ("detaillierteZweckbestimmung") ;
GRANT SELECT ON TABLE "BP_Wasser"."BP_GewaesserFlaeche" TO xp_gast;
GRANT ALL ON TABLE "BP_Wasser"."BP_GewaesserFlaeche" TO bp_user;
COMMENT ON TABLE "BP_Wasser"."BP_GewaesserFlaeche" IS 'Festsetzung neuer Wasserflächen nach §9 Abs. 1 Nr. 16a BauGB.
Diese Klasse wird in der nächsten Hauptversion des Standards eventuell wegfallen und durch SO_Gewaesser ersetzt werden.';
COMMENT ON COLUMN  "BP_Wasser"."BP_GewaesserFlaeche"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN  "BP_Wasser"."BP_GewaesserFlaeche"."zweckbestimmung" IS 'Zweckbestimmung der Wasserfläche.';
COMMENT ON COLUMN  "BP_Wasser"."BP_GewaesserFlaeche"."detaillierteZweckbestimmung" IS 'Über eine CodeList definierte Zweckbestimmung der Fläche.';
CREATE TRIGGER "change_to_BP_GewaesserFlaeche" BEFORE INSERT OR UPDATE ON "BP_Wasser"."BP_GewaesserFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_BP_GewaesserFlaeche" AFTER DELETE ON "BP_Wasser"."BP_GewaesserFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "flaechenschluss_BP_GewaesserFlaeche" BEFORE INSERT OR UPDATE OR DELETE ON "BP_Wasser"."BP_GewaesserFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isFlaechenschlussobjekt"();

-- -----------------------------------------------------
-- Table "BP_Sonstiges"."BP_HoehenMass"
-- -----------------------------------------------------
CREATE  TABLE  "BP_Sonstiges"."BP_HoehenMass" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_BP_HoehenMass_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "BP_Basisobjekte"."BP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE);

GRANT SELECT ON TABLE "BP_Sonstiges"."BP_HoehenMass" TO xp_gast;
GRANT ALL ON TABLE "BP_Sonstiges"."BP_HoehenMass" TO bp_user;
COMMENT ON TABLE  "BP_Sonstiges"."BP_HoehenMass" IS 'Festsetzungen nach §9 Abs. 1 Nr. 1 BauGB für übereinanderliegende Geschosse und Ebenen und sonstige Teile baulicher Anlagen (§9 Abs.3 BauGB), sowie Hinweise auf Geländehöhen.';
COMMENT ON COLUMN  "BP_Sonstiges"."BP_HoehenMass"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_BP_HoehenMass" BEFORE INSERT OR UPDATE ON "BP_Sonstiges"."BP_HoehenMass" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_BP_HoehenMass" AFTER DELETE ON "BP_Sonstiges"."BP_HoehenMass" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "BP_Sonstiges"."BP_HoehenMassFlaeche"
-- -----------------------------------------------------
CREATE  TABLE  "BP_Sonstiges"."BP_HoehenMassFlaeche" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_BP_HoehenMassFlaeche_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "BP_Sonstiges"."BP_HoehenMass" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("BP_Basisobjekte"."BP_Flaechenobjekt");

GRANT SELECT ON TABLE "BP_Sonstiges"."BP_HoehenMassFlaeche" TO xp_gast;
GRANT ALL ON TABLE "BP_Sonstiges"."BP_HoehenMassFlaeche" TO bp_user;
CREATE INDEX "BP_HoehenMassFlaeche_gidx" ON "BP_Sonstiges"."BP_HoehenMassFlaeche" using gist ("position");
CREATE TRIGGER "change_to_BP_HoehenMassFlaeche" BEFORE INSERT OR UPDATE ON "BP_Sonstiges"."BP_HoehenMassFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_BP_HoehenMassFlaeche" AFTER DELETE ON "BP_Sonstiges"."BP_HoehenMassFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "BP_HoehenMassFlaeche_Flaechenobjekt" BEFORE INSERT OR UPDATE ON "BP_Sonstiges"."BP_HoehenMassFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isFlaechenobjekt"();

-- -----------------------------------------------------
-- Table "BP_Sonstiges"."BP_HoehenMassLinie"
-- -----------------------------------------------------
CREATE  TABLE  "BP_Sonstiges"."BP_HoehenMassLinie" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_BP_HoehenMassLinie_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "BP_Sonstiges"."BP_HoehenMass" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("BP_Basisobjekte"."BP_Linienobjekt");

GRANT SELECT ON TABLE "BP_Sonstiges"."BP_HoehenMassLinie" TO xp_gast;
GRANT ALL ON TABLE "BP_Sonstiges"."BP_HoehenMassLinie" TO bp_user;
CREATE INDEX "BP_HoehenMassLinie_gidx" ON "BP_Sonstiges"."BP_HoehenMassLinie" using gist ("position");
CREATE TRIGGER "change_to_BP_HoehenMassLinie" BEFORE INSERT OR UPDATE ON "BP_Sonstiges"."BP_HoehenMassLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_BP_HoehenMassLinie" AFTER DELETE ON "BP_Sonstiges"."BP_HoehenMassLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "BP_Sonstiges"."BP_HoehenMassPunkt"
-- -----------------------------------------------------
CREATE  TABLE  "BP_Sonstiges"."BP_HoehenMassPunkt" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_BP_HoehenMassPunkt_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "BP_Sonstiges"."BP_HoehenMass" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("BP_Basisobjekte"."BP_Punktobjekt");

GRANT SELECT ON TABLE "BP_Sonstiges"."BP_HoehenMassPunkt" TO xp_gast;
GRANT ALL ON TABLE "BP_Sonstiges"."BP_HoehenMassPunkt" TO bp_user;
CREATE INDEX "BP_HoehenMassPunkt_gidx" ON "BP_Sonstiges"."BP_HoehenMassPunkt" using gist ("position");
CREATE TRIGGER "change_to_BP_HoehenMassPunkt" BEFORE INSERT OR UPDATE ON "BP_Sonstiges"."BP_HoehenMassPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_BP_HoehenMassPunkt" AFTER DELETE ON "BP_Sonstiges"."BP_HoehenMassPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "BP_Umwelt"."BP_Laermpegelbereich"
-- -----------------------------------------------------
CREATE TABLE "BP_Umwelt"."BP_Laermpegelbereich" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Code") );
GRANT SELECT ON "BP_Umwelt"."BP_Laermpegelbereich" TO xp_gast;

-- -----------------------------------------------------
-- Table "BP_Umwelt"."BP_TechnVorkehrungenImmissionsschutz"
-- -----------------------------------------------------
CREATE TABLE "BP_Umwelt"."BP_TechnVorkehrungenImmissionsschutz" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Code") );
GRANT SELECT ON "BP_Umwelt"."BP_TechnVorkehrungenImmissionsschutz" TO xp_gast;

-- -----------------------------------------------------
-- Table "BP_Umwelt"."BP_DetailTechnVorkehrungImmissionsschutz"
-- -----------------------------------------------------
CREATE TABLE "BP_Umwelt"."BP_DetailTechnVorkehrungImmissionsschutz" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Code") );
GRANT SELECT ON "BP_Umwelt"."BP_DetailTechnVorkehrungImmissionsschutz" TO xp_gast;
GRANT ALL ON "BP_Umwelt"."BP_DetailTechnVorkehrungImmissionsschutz" TO bp_user;
CREATE TRIGGER "ins_upd_BP_DetailTechnVorkehrungImmissionsschutz" BEFORE INSERT OR UPDATE ON "BP_Umwelt"."BP_DetailTechnVorkehrungImmissionsschutz" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isCodeList"();

-- -----------------------------------------------------
-- Table "BP_Umwelt"."BP_ImmissionsschutzTypen"
-- -----------------------------------------------------
CREATE TABLE "BP_Umwelt"."BP_ImmissionsschutzTypen" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Code") );
GRANT SELECT ON "BP_Umwelt"."BP_ImmissionsschutzTypen" TO xp_gast;

-- -----------------------------------------------------
-- Table "BP_Umwelt"."BP_Immissionsschutz"
-- -----------------------------------------------------
CREATE  TABLE  "BP_Umwelt"."BP_Immissionsschutz" (
  "gid" BIGINT NOT NULL ,
  "nutzung" CHARACTER VARYING (256),
  "laermpegelbereich" INTEGER,
  "technVorkehrung" INTEGER,
  "detaillierteTechnVorkehrung" INTEGER,
  "typ" INTEGER,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_BP_Immissionsschutz_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "BP_Basisobjekte"."BP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_BP_Immissionsschutz_BP_Laermpegelbereich1"
    FOREIGN KEY ("laermpegelbereich")
    REFERENCES "BP_Umwelt"."BP_Laermpegelbereich" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_BP_Immissionsschutz_BP_TechnVorkehrungenImmissionsschutz1"
    FOREIGN KEY ("technVorkehrung")
    REFERENCES "BP_Umwelt"."BP_TechnVorkehrungenImmissionsschutz" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_BP_Immissionsschutz_BP_DetailTechnVorkehrung1"
    FOREIGN KEY ("detaillierteTechnVorkehrung")
    REFERENCES "BP_Umwelt"."BP_DetailTechnVorkehrungImmissionsschutz" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_BP_Immissionsschutz_BP_ImmissionsschutzTypen1"
    FOREIGN KEY ("typ")
    REFERENCES "BP_Umwelt"."BP_ImmissionsschutzTypen" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE);

GRANT SELECT ON TABLE "BP_Umwelt"."BP_Immissionsschutz" TO xp_gast;
GRANT ALL ON TABLE "BP_Umwelt"."BP_Immissionsschutz" TO bp_user;
COMMENT ON TABLE  "BP_Umwelt"."BP_Immissionsschutz" IS 'Festsetzung einer von der Bebauung freizuhaltenden Schutzfläche und ihre Nutzung, sowie einer Fläche für besondere Anlagen und Vorkehrungen zum Schutz vor schädlichen Umwelteinwirkungen und sonstigen Gefahren im Sinne des Bundes-Immissionsschutzgesetzes sowie die zum Schutz vor solchen Einwirkungen oder zur Vermeidung oder Minderung solcher Einwirkungen zu treffenden baulichen und sonstigen technischen Vorkehrungen (§9, Abs. 1, Nr. 24 BauGB).';
COMMENT ON COLUMN  "BP_Umwelt"."BP_Immissionsschutz"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN  "BP_Umwelt"."BP_Immissionsschutz"."nutzung" IS 'Festgesetzte Nutzung einer Schutzfläche';
COMMENT ON COLUMN "BP_Umwelt"."BP_Immissionsschutz"."laermpegelbereich" IS 'FFestlegung der erforderlichen Luftschalldämmung von Außenbauteilen nach DIN 4109.';
COMMENT ON COLUMN "BP_Umwelt"."BP_Immissionsschutz"."technVorkehrung" IS 'Klassifizierung der auf der Fläche zu treffenden baulichen oder sonstigen technischen Vorkehrungen';
COMMENT ON COLUMN "BP_Umwelt"."BP_Immissionsschutz"."detaillierteTechnVorkehrung" IS 'Detaillierte Klassifizierung der auf der Fläche zu treffenden baulichen oder sonstigen technischen Vorkehrungen';
COMMENT ON COLUMN "BP_Umwelt"."BP_Immissionsschutz"."typ" IS 'Differenzierung der Immissionsschutz-Fläche';
CREATE TRIGGER "change_to_BP_Immissionsschutz" BEFORE INSERT OR UPDATE ON "BP_Umwelt"."BP_Immissionsschutz" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_BP_Immissionsschutz" AFTER DELETE ON "BP_Umwelt"."BP_Immissionsschutz" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "BP_Umwelt"."BP_ImmissionsschutzFlaeche"
-- -----------------------------------------------------
CREATE  TABLE  "BP_Umwelt"."BP_ImmissionsschutzFlaeche" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_BP_ImmissionsschutzFlaeche_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "BP_Umwelt"."BP_Immissionsschutz" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("BP_Basisobjekte"."BP_Flaechenobjekt");

GRANT SELECT ON TABLE "BP_Umwelt"."BP_ImmissionsschutzFlaeche" TO xp_gast;
GRANT ALL ON TABLE "BP_Umwelt"."BP_ImmissionsschutzFlaeche" TO bp_user;
CREATE INDEX "BP_ImmissionsschutzFlaeche_gidx" ON "BP_Umwelt"."BP_ImmissionsschutzFlaeche" using gist ("position");
CREATE TRIGGER "change_to_BP_ImmissionsschutzFlaeche" BEFORE INSERT OR UPDATE ON "BP_Umwelt"."BP_ImmissionsschutzFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_BP_ImmissionsschutzFlaeche" AFTER DELETE ON "BP_Umwelt"."BP_ImmissionsschutzFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "BP_ImmissionsschutzFlaeche_Flaechenobjekt" BEFORE INSERT OR UPDATE ON "BP_Umwelt"."BP_ImmissionsschutzFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isFlaechenobjekt"();

-- -----------------------------------------------------
-- Table "BP_Umwelt"."BP_ImmissionsschutzLinie"
-- -----------------------------------------------------
CREATE  TABLE  "BP_Umwelt"."BP_ImmissionsschutzLinie" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_BP_ImmissionsschutzLinie_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "BP_Umwelt"."BP_Immissionsschutz" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("BP_Basisobjekte"."BP_Linienobjekt");

GRANT SELECT ON TABLE "BP_Umwelt"."BP_ImmissionsschutzLinie" TO xp_gast;
GRANT ALL ON TABLE "BP_Umwelt"."BP_ImmissionsschutzLinie" TO bp_user;
CREATE INDEX "BP_ImmissionsschutzLinie_gidx" ON "BP_Umwelt"."BP_ImmissionsschutzLinie" using gist ("position");
CREATE TRIGGER "change_to_BP_ImmissionsschutzLinie" BEFORE INSERT OR UPDATE ON "BP_Umwelt"."BP_ImmissionsschutzLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_BP_ImmissionsschutzLinie" AFTER DELETE ON "BP_Umwelt"."BP_ImmissionsschutzLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "BP_Umwelt"."BP_ImmissionsschutzPunkt"
-- -----------------------------------------------------
CREATE  TABLE  "BP_Umwelt"."BP_ImmissionsschutzPunkt" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_BP_ImmissionsschutzPunkt_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "BP_Umwelt"."BP_Immissionsschutz" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("BP_Basisobjekte"."BP_Punktobjekt");

GRANT SELECT ON TABLE "BP_Umwelt"."BP_ImmissionsschutzPunkt" TO xp_gast;
GRANT ALL ON TABLE "BP_Umwelt"."BP_ImmissionsschutzPunkt" TO bp_user;
CREATE INDEX "BP_ImmissionsschutzPunkt_gidx" ON "BP_Umwelt"."BP_ImmissionsschutzPunkt" using gist ("position");
CREATE TRIGGER "change_to_BP_ImmissionsschutzPunkt" BEFORE INSERT OR UPDATE ON "BP_Umwelt"."BP_ImmissionsschutzPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_BP_ImmissionsschutzPunkt" AFTER DELETE ON "BP_Umwelt"."BP_ImmissionsschutzPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "BP_Sonstiges"."BP_KennzeichnungsFlaeche"
-- -----------------------------------------------------
CREATE  TABLE  "BP_Sonstiges"."BP_KennzeichnungsFlaeche" (
  "gid" BIGINT NOT NULL ,
  "istVerdachtsflaeche" BOOLEAN,
  "nummer" CHARACTER VARYING(256),
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_BP_KennzeichnungsFlaeche_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "BP_Basisobjekte"."BP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("BP_Basisobjekte"."BP_Flaechenobjekt");

GRANT SELECT ON TABLE "BP_Sonstiges"."BP_KennzeichnungsFlaeche" TO xp_gast;
GRANT ALL ON TABLE "BP_Sonstiges"."BP_KennzeichnungsFlaeche" TO bp_user;
CREATE INDEX "BP_KennzeichnungsFlaeche_gidx" ON "BP_Sonstiges"."BP_KennzeichnungsFlaeche" using gist ("position");
COMMENT ON TABLE  "BP_Sonstiges"."BP_KennzeichnungsFlaeche" IS 'Flächen für Kennzeichnungen gemäß §9 Abs. 5 BauGB.';
COMMENT ON COLUMN  "BP_Sonstiges"."BP_KennzeichnungsFlaeche"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN "BP_Sonstiges"."BP_KennzeichnungsFlaeche"."istVerdachtsflaeche" IS 'Legt fest, ob eine Altlast-Verdachtsfläche vorliegt';
COMMENT ON COLUMN "BP_Sonstiges"."BP_KennzeichnungsFlaeche"."nummer" IS 'Nummer im Altlastkataster';
CREATE TRIGGER "change_to_BP_KennzeichnungsFlaeche" BEFORE INSERT OR UPDATE ON "BP_Sonstiges"."BP_KennzeichnungsFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_BP_KennzeichnungsFlaeche" AFTER DELETE ON "BP_Sonstiges"."BP_KennzeichnungsFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "BP_KennzeichnungsFlaeche_Flaechenobjekt" BEFORE INSERT OR UPDATE ON "BP_Sonstiges"."BP_KennzeichnungsFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isFlaechenobjekt"();

-- -----------------------------------------------------
-- Table BP_Sonstiges"."BP_KennzeichnungsFlaeche_zweckbestimmung"
-- -----------------------------------------------------
CREATE  TABLE  "BP_Sonstiges"."BP_KennzeichnungsFlaeche_zweckbestimmung" (
  "BP_KennzeichnungsFlaeche_gid" BIGINT NOT NULL ,
  "zweckbestimmung" INTEGER NOT NULL ,
  PRIMARY KEY ("BP_KennzeichnungsFlaeche_gid", "zweckbestimmung"),
  CONSTRAINT "fk_BP_KennzeichnungsFlaeche_zweckbestimmung1"
    FOREIGN KEY ("BP_KennzeichnungsFlaeche_gid" )
    REFERENCES "BP_Sonstiges"."BP_KennzeichnungsFlaeche" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_BP_KennzeichnungsFlaeche_zweckbestimmung2"
    FOREIGN KEY ("zweckbestimmung" )
    REFERENCES "XP_Enumerationen"."XP_ZweckbestimmungKennzeichnung" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
GRANT SELECT ON TABLE "BP_Sonstiges"."BP_KennzeichnungsFlaeche_zweckbestimmung" TO xp_gast;
GRANT ALL ON TABLE "BP_Sonstiges"."BP_KennzeichnungsFlaeche_zweckbestimmung" TO bp_user;
COMMENT ON TABLE  "BP_Sonstiges"."BP_KennzeichnungsFlaeche_zweckbestimmung" IS 'Zweckbestimmungen der Fläche.';

-- -----------------------------------------------------
-- Table "BP_Landwirtschaft_Wald_und_Gruen"."BP_KleintierhaltungFlaeche"
-- -----------------------------------------------------
CREATE  TABLE  "BP_Landwirtschaft_Wald_und_Gruen"."BP_KleintierhaltungFlaeche" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_BP_KleintierhaltungFlaeche_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "BP_Basisobjekte"."BP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE);

GRANT SELECT ON TABLE "BP_Landwirtschaft_Wald_und_Gruen"."BP_KleintierhaltungFlaeche" TO xp_gast;
GRANT ALL ON TABLE "BP_Landwirtschaft_Wald_und_Gruen"."BP_KleintierhaltungFlaeche" TO bp_user;
COMMENT ON TABLE  "BP_Landwirtschaft_Wald_und_Gruen"."BP_KleintierhaltungFlaeche" IS 'Fläche für die Errichtung von Anlagen für die Kleintierhaltung woe Ausstellungs- und Zuchtanlagen, Zwinger, Koppeln und dergleichen (§9 Abs. 19 BauGB).';
COMMENT ON COLUMN  "BP_Landwirtschaft_Wald_und_Gruen"."BP_KleintierhaltungFlaeche"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_BP_KleintierhaltungFlaeche" BEFORE INSERT OR UPDATE ON "BP_Landwirtschaft_Wald_und_Gruen"."BP_KleintierhaltungFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_BP_KleintierhaltungFlaeche" AFTER DELETE ON "BP_Landwirtschaft_Wald_und_Gruen"."BP_KleintierhaltungFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "flaechenschluss_BP_KleintierhaltungFlaeche" BEFORE INSERT OR UPDATE OR DELETE ON "BP_Landwirtschaft_Wald_und_Gruen"."BP_KleintierhaltungFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isFlaechenschlussobjekt"();

-- -----------------------------------------------------
-- Table "BP_Landwirtschaft_Wald_und_Gruen"."BP_Landwirtschaft"
-- -----------------------------------------------------
CREATE  TABLE  "BP_Landwirtschaft_Wald_und_Gruen"."BP_Landwirtschaft" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_BP_Landwirtschaft_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "BP_Basisobjekte"."BP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE);

GRANT SELECT ON TABLE "BP_Landwirtschaft_Wald_und_Gruen"."BP_Landwirtschaft" TO xp_gast;
GRANT ALL ON TABLE "BP_Landwirtschaft_Wald_und_Gruen"."BP_Landwirtschaft" TO bp_user;
COMMENT ON TABLE  "BP_Landwirtschaft_Wald_und_Gruen"."BP_Landwirtschaft" IS 'Festsetzung einer Einzelmaßnahme zum Ausgleich im Sinne des § 1a Abs.3 und §9 Abs. 1a BauGB.';
COMMENT ON COLUMN  "BP_Landwirtschaft_Wald_und_Gruen"."BP_Landwirtschaft"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_BP_Landwirtschaft" BEFORE INSERT OR UPDATE ON "BP_Landwirtschaft_Wald_und_Gruen"."BP_Landwirtschaft" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_BP_Landwirtschaft" AFTER DELETE ON "BP_Landwirtschaft_Wald_und_Gruen"."BP_Landwirtschaft" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "BP_Landwirtschaft_Wald_und_Gruen"."BP_DetailZweckbestLandwirtschaft"
-- -----------------------------------------------------
CREATE  TABLE  "BP_Landwirtschaft_Wald_und_Gruen"."BP_DetailZweckbestLandwirtschaft" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Code") );
GRANT SELECT ON TABLE "BP_Landwirtschaft_Wald_und_Gruen"."BP_DetailZweckbestLandwirtschaft" TO xp_gast;
GRANT ALL ON "BP_Landwirtschaft_Wald_und_Gruen"."BP_DetailZweckbestLandwirtschaft" TO bp_user;
CREATE TRIGGER "ins_upd_BP_DetailZweckbestLandwirtschaft" BEFORE INSERT OR UPDATE ON "BP_Landwirtschaft_Wald_und_Gruen"."BP_DetailZweckbestLandwirtschaft" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isCodeList"();

-- -----------------------------------------------------
-- Table "BP_Landwirtschaft_Wald_und_Gruen"."BP_Landwirtschaft_zweckbestimmung"
-- -----------------------------------------------------
CREATE  TABLE  "BP_Landwirtschaft_Wald_und_Gruen"."BP_Landwirtschaft_zweckbestimmung" (
  "BP_Landwirtschaft_gid" BIGINT NOT NULL ,
  "zweckbestimmung" INTEGER NOT NULL ,
  PRIMARY KEY ("BP_Landwirtschaft_gid", "zweckbestimmung"),
  CONSTRAINT "fk_BP_Landwirtschaft_zweckbestimmung1"
    FOREIGN KEY ("BP_Landwirtschaft_gid" )
    REFERENCES "BP_Landwirtschaft_Wald_und_Gruen"."BP_Landwirtschaft" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_BP_Landwirtschaft_zweckbestimmung2"
    FOREIGN KEY ("zweckbestimmung" )
    REFERENCES "XP_Enumerationen"."XP_ZweckbestimmungLandwirtschaft" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
GRANT SELECT ON TABLE "BP_Landwirtschaft_Wald_und_Gruen"."BP_Landwirtschaft_zweckbestimmung" TO xp_gast;
GRANT ALL ON TABLE "BP_Landwirtschaft_Wald_und_Gruen"."BP_Landwirtschaft_zweckbestimmung" TO bp_user;
COMMENT ON TABLE  "BP_Landwirtschaft_Wald_und_Gruen"."BP_Landwirtschaft_zweckbestimmung" IS 'Zweckbestimmungen der Ausweisung.';

-- -----------------------------------------------------
-- Table "BP_Landwirtschaft_Wald_und_Gruen"."BP_Landwirtschaft_detaillierteZweckbestimmung"
-- -----------------------------------------------------
CREATE  TABLE  "BP_Landwirtschaft_Wald_und_Gruen"."BP_Landwirtschaft_detaillierteZweckbestimmung" (
  "BP_Landwirtschaft_gid" BIGINT NOT NULL ,
  "detaillierteZweckbestimmung" INTEGER NOT NULL ,
  PRIMARY KEY ("BP_Landwirtschaft_gid", "detaillierteZweckbestimmung"),
  CONSTRAINT "fk_BP_Landwirtschaft_detaillierteZweckbestimmung1"
    FOREIGN KEY ("BP_Landwirtschaft_gid" )
    REFERENCES "BP_Landwirtschaft_Wald_und_Gruen"."BP_Landwirtschaft" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_BP_Landwirtschaft_detaillierteZweckbestimmung2"
    FOREIGN KEY ("detaillierteZweckbestimmung" )
    REFERENCES "BP_Landwirtschaft_Wald_und_Gruen"."BP_DetailZweckbestLandwirtschaft" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
GRANT SELECT ON TABLE "BP_Landwirtschaft_Wald_und_Gruen"."BP_Landwirtschaft_detaillierteZweckbestimmung" TO xp_gast;
GRANT ALL ON TABLE "BP_Landwirtschaft_Wald_und_Gruen"."BP_Landwirtschaft_detaillierteZweckbestimmung" TO bp_user;
COMMENT ON TABLE  "BP_Landwirtschaft_Wald_und_Gruen"."BP_Landwirtschaft_detaillierteZweckbestimmung" IS 'ZÜber eine CodeList definierte zusätzliche Zweckbestimmungen.';

-- -----------------------------------------------------
-- Table "BP_Landwirtschaft_Wald_und_Gruen"."BP_LandwirtschaftsFlaeche"
-- -----------------------------------------------------
CREATE  TABLE  "BP_Landwirtschaft_Wald_und_Gruen"."BP_LandwirtschaftsFlaeche" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_BP_LandwirtschaftsFlaeche_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "BP_Landwirtschaft_Wald_und_Gruen"."BP_Landwirtschaft" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("BP_Basisobjekte"."BP_Flaechenobjekt");

GRANT SELECT ON TABLE "BP_Landwirtschaft_Wald_und_Gruen"."BP_LandwirtschaftsFlaeche" TO xp_gast;
GRANT ALL ON TABLE "BP_Landwirtschaft_Wald_und_Gruen"."BP_LandwirtschaftsFlaeche" TO bp_user;
CREATE INDEX "BP_LandwirtschaftsFlaeche_gidx" ON "BP_Landwirtschaft_Wald_und_Gruen"."BP_LandwirtschaftsFlaeche" using gist ("position");
CREATE TRIGGER "change_to_BP_LandwirtschaftsFlaeche" BEFORE INSERT OR UPDATE ON "BP_Landwirtschaft_Wald_und_Gruen"."BP_LandwirtschaftsFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_BP_LandwirtschaftsFlaeche" AFTER DELETE ON "BP_Landwirtschaft_Wald_und_Gruen"."BP_LandwirtschaftsFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "flaechenschluss_BP_LandwirtschaftsFlaeche" BEFORE INSERT OR UPDATE ON "BP_Landwirtschaft_Wald_und_Gruen"."BP_LandwirtschaftsFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isFlaechenschlussobjekt"();

-- -----------------------------------------------------
-- Table "BP_Landwirtschaft_Wald_und_Gruen"."BP_LandwirtschaftLinie"
-- -----------------------------------------------------
CREATE  TABLE  "BP_Landwirtschaft_Wald_und_Gruen"."BP_LandwirtschaftLinie" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_BP_LandwirtschaftLinie_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "BP_Landwirtschaft_Wald_und_Gruen"."BP_Landwirtschaft" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("BP_Basisobjekte"."BP_Linienobjekt");

COMMENT ON TABLE "BP_Landwirtschaft_Wald_und_Gruen"."BP_LandwirtschaftLinie" IS 'Die Klasse wird als veraltet gekennzeichnet und wird in Version 6.0 wegfallen. Es sollte stattdessen die Klasse BP_LandwirtschaftsFlaeche verwendet werden.';
GRANT SELECT ON TABLE "BP_Landwirtschaft_Wald_und_Gruen"."BP_LandwirtschaftLinie" TO xp_gast;
GRANT ALL ON TABLE "BP_Landwirtschaft_Wald_und_Gruen"."BP_LandwirtschaftLinie" TO bp_user;
CREATE INDEX "BP_LandwirtschaftLinie_gidx" ON "BP_Landwirtschaft_Wald_und_Gruen"."BP_LandwirtschaftLinie" using gist ("position");
CREATE TRIGGER "change_to_BP_LandwirtschaftLinie" BEFORE INSERT OR UPDATE ON "BP_Landwirtschaft_Wald_und_Gruen"."BP_LandwirtschaftLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_BP_LandwirtschaftLinie" AFTER DELETE ON "BP_Landwirtschaft_Wald_und_Gruen"."BP_LandwirtschaftLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "BP_Landwirtschaft_Wald_und_Gruen"."BP_LandwirtschaftPunkt"
-- -----------------------------------------------------
CREATE  TABLE  "BP_Landwirtschaft_Wald_und_Gruen"."BP_LandwirtschaftPunkt" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_BP_LandwirtschaftPunkt_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "BP_Landwirtschaft_Wald_und_Gruen"."BP_Landwirtschaft" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("BP_Basisobjekte"."BP_Punktobjekt");

COMMENT ON TABLE "BP_Landwirtschaft_Wald_und_Gruen"."BP_LandwirtschaftPunkt" IS 'Die Klasse wird als veraltet gekennzeichnet und wird in Version 6.0 wegfallen. Es sollte stattdessen die Klasse BP_LandwirtschaftsFlaeche verwendet werden.';
GRANT SELECT ON TABLE "BP_Landwirtschaft_Wald_und_Gruen"."BP_LandwirtschaftPunkt" TO xp_gast;
GRANT ALL ON TABLE "BP_Landwirtschaft_Wald_und_Gruen"."BP_LandwirtschaftPunkt" TO bp_user;
CREATE INDEX "BP_LandwirtschaftPunkt_gidx" ON "BP_Landwirtschaft_Wald_und_Gruen"."BP_LandwirtschaftPunkt" using gist ("position");
CREATE TRIGGER "change_to_BP_LandwirtschaftPunkt" BEFORE INSERT OR UPDATE ON "BP_Landwirtschaft_Wald_und_Gruen"."BP_LandwirtschaftPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_BP_LandwirtschaftPunkt" AFTER DELETE ON "BP_Landwirtschaft_Wald_und_Gruen"."BP_LandwirtschaftPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "BP_Umwelt"."BP_LuftreinhalteFlaeche"
-- -----------------------------------------------------
CREATE  TABLE  "BP_Umwelt"."BP_LuftreinhalteFlaeche" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_BP_LuftreinhalteFlaeche_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "BP_Basisobjekte"."BP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("BP_Basisobjekte"."BP_Flaechenobjekt");

GRANT SELECT ON TABLE "BP_Umwelt"."BP_LuftreinhalteFlaeche" TO xp_gast;
GRANT ALL ON TABLE "BP_Umwelt"."BP_LuftreinhalteFlaeche" TO bp_user;
CREATE INDEX "BP_LuftreinhalteFlaeche_gidx" ON "BP_Umwelt"."BP_LuftreinhalteFlaeche" using gist ("position");
COMMENT ON TABLE  "BP_Umwelt"."BP_LuftreinhalteFlaeche" IS 'Festsetzung von Gebieten, in denen zum Schutz vor schädlichen Umwelteinwirkungen im Sinne des Bundes-Immissionsschutzgesetzes bestimmte Luft verunreinigende Stoffe nicht oder nur beschränkt verwendet werden dürfen (§9, Abs. 1, Nr. 23a BauGB).';
COMMENT ON COLUMN  "BP_Umwelt"."BP_LuftreinhalteFlaeche"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_BP_LuftreinhalteFlaeche" BEFORE INSERT OR UPDATE ON "BP_Umwelt"."BP_LuftreinhalteFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_BP_LuftreinhalteFlaeche" AFTER DELETE ON "BP_Umwelt"."BP_LuftreinhalteFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "BP_LuftreinhalteFlaeche_Ueberlagerung" BEFORE INSERT OR UPDATE ON "BP_Umwelt"."BP_LuftreinhalteFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isUeberlagerungsobjekt"();

-- -----------------------------------------------------
-- Table "BP_Sonstiges"."BP_AbgrenzungenTypen"
-- -----------------------------------------------------
CREATE  TABLE  "BP_Sonstiges"."BP_AbgrenzungenTypen" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Code") );
GRANT SELECT ON "BP_Sonstiges"."BP_AbgrenzungenTypen" TO xp_gast;

-- -----------------------------------------------------
-- Table "BP_Sonstiges"."BP_DetailAbgrenzungenTypen"
-- -----------------------------------------------------
CREATE  TABLE  "BP_Sonstiges"."BP_DetailAbgrenzungenTypen" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Code") );
GRANT SELECT ON "BP_Sonstiges"."BP_DetailAbgrenzungenTypen" TO xp_gast;
GRANT ALL ON "BP_Sonstiges"."BP_DetailAbgrenzungenTypen" TO bp_user;
CREATE TRIGGER "ins_upd_BP_DetailAbgrenzungenTypen" BEFORE INSERT OR UPDATE ON "BP_Sonstiges"."BP_DetailAbgrenzungenTypen" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isCodeList"();

-- -----------------------------------------------------
-- Table "BP_Sonstiges"."BP_NutzungsartenGrenze"
-- -----------------------------------------------------
CREATE  TABLE  "BP_Sonstiges"."BP_NutzungsartenGrenze" (
  "gid" BIGINT NOT NULL ,
  "typ" INTEGER ,
  "detailTyp" INTEGER,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_BP_NutzungsartenGrenze_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "BP_Basisobjekte"."BP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_BP_NutzungsartenGrenze_typ"
    FOREIGN KEY ("typ" )
    REFERENCES "BP_Sonstiges"."BP_AbgrenzungenTypen" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_BP_NutzungsartenGrenze_detailTyp"
    FOREIGN KEY ("detailTyp" )
    REFERENCES "BP_Sonstiges"."BP_DetailAbgrenzungenTypen" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE)
INHERITS("BP_Basisobjekte"."BP_Linienobjekt");

GRANT SELECT ON TABLE "BP_Sonstiges"."BP_NutzungsartenGrenze" TO xp_gast;
GRANT ALL ON TABLE "BP_Sonstiges"."BP_NutzungsartenGrenze" TO bp_user;
CREATE INDEX "BP_NutzungsartenGrenze_gidx" ON "BP_Sonstiges"."BP_NutzungsartenGrenze" using gist ("position");
COMMENT ON TABLE  "BP_Sonstiges"."BP_NutzungsartenGrenze" IS 'Abgrenzung unterschiedlicher Nutzung, z.B. von Baugebieten wenn diese nach PlanzVO in der gleichen Farbe dargestellt werden, oder Abgrenzung unterschiedlicher Nutzungsmaße innerhalb eines Baugebiets ("Knödellinie", §1 Abs. 4, §16 Abs. 5 BauNVO).';
COMMENT ON COLUMN  "BP_Sonstiges"."BP_NutzungsartenGrenze"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN  "BP_Sonstiges"."BP_NutzungsartenGrenze"."typ" IS 'Typ der Abgrenzung. Wenn das Attribut nicht belegt ist, ist die Abgrenzung eine Nutzungsarten-Grenze (Schlüsselnummer 1000).';
COMMENT ON COLUMN  "BP_Sonstiges"."BP_NutzungsartenGrenze"."detailTyp" IS 'Detaillierter Typ der Abgrenzung, wenn das Attribut typ den Wert 9999 (Sonstige Abgrenzung) hat.';
CREATE TRIGGER "change_to_BP_NutzungsartenGrenze" BEFORE INSERT OR UPDATE ON "BP_Sonstiges"."BP_NutzungsartenGrenze" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_BP_NutzungsartenGrenze" AFTER DELETE ON "BP_Sonstiges"."BP_NutzungsartenGrenze" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "BP_Aufschuettung_Abgrabung_Bodenschaetze"."BP_RekultivierungsFlaeche"
-- -----------------------------------------------------
CREATE  TABLE  "BP_Aufschuettung_Abgrabung_Bodenschaetze"."BP_RekultivierungsFlaeche" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_BP_RekultivierungsFlaeche_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "BP_Basisobjekte"."BP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("BP_Basisobjekte"."BP_Flaechenobjekt");

GRANT SELECT ON TABLE "BP_Aufschuettung_Abgrabung_Bodenschaetze"."BP_RekultivierungsFlaeche" TO xp_gast;
GRANT ALL ON TABLE "BP_Aufschuettung_Abgrabung_Bodenschaetze"."BP_RekultivierungsFlaeche" TO bp_user;
CREATE INDEX "BP_RekultivierungsFlaeche_gidx" ON "BP_Aufschuettung_Abgrabung_Bodenschaetze"."BP_RekultivierungsFlaeche" using gist ("position");
COMMENT ON TABLE  "BP_Aufschuettung_Abgrabung_Bodenschaetze"."BP_RekultivierungsFlaeche" IS 'Rekultivierungs-Fläche
Die Klasse wird als veraltet gekennzeichnet und wird in XPlanGML 6.0 wegfallen. Es sollte stattdessen die Klasse SO_SonstigesRecht verwendet werden.';
COMMENT ON COLUMN  "BP_Aufschuettung_Abgrabung_Bodenschaetze"."BP_RekultivierungsFlaeche"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_BP_RekultivierungsFlaeche" BEFORE INSERT OR UPDATE ON "BP_Aufschuettung_Abgrabung_Bodenschaetze"."BP_RekultivierungsFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_BP_RekultivierungsFlaeche" AFTER DELETE ON "BP_Aufschuettung_Abgrabung_Bodenschaetze"."BP_RekultivierungsFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "BP_RekultivierungsFlaeche_Flaechenobjekt" BEFORE INSERT OR UPDATE ON "BP_Aufschuettung_Abgrabung_Bodenschaetze"."BP_RekultivierungsFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isFlaechenobjekt"();

-- -----------------------------------------------------
-- Table "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_SchutzPflegeEntwicklungsFlaeche"
-- -----------------------------------------------------
CREATE  TABLE  "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_SchutzPflegeEntwicklungsFlaeche" (
  "gid" BIGINT NOT NULL ,
  "ziel" INTEGER NULL ,
  "sonstZiel" VARCHAR(255),
  "istAusgleich" BOOLEAN,
  "refMassnahmenText" INTEGER,
  "refLandschaftsplan" INTEGER,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_BP_SchutzPflegeEntwicklungsFlaeche_XP_SPEZiele"
    FOREIGN KEY ("ziel" )
    REFERENCES "XP_Enumerationen"."XP_SPEZiele" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_BP_SchutzPflegeEntwicklungsFlaeche_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "BP_Basisobjekte"."BP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_BP_SchutzPflegeEntwicklungsFlaeche_refMassnahmenText"
    FOREIGN KEY ("refMassnahmenText" )
    REFERENCES "XP_Basisobjekte"."XP_ExterneReferenz" ("id" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_BP_SchutzPflegeEntwicklungsFlaeche_refLandschaftsplan"
    FOREIGN KEY ("refLandschaftsplan" )
    REFERENCES "XP_Basisobjekte"."XP_ExterneReferenz" ("id" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE)
  INHERITS("BP_Basisobjekte"."BP_Flaechenobjekt");

CREATE INDEX "idx_fk_BP_SchutzPflegeEntwicklungsFlaeche_XP_SPEZiele" ON "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_SchutzPflegeEntwicklungsFlaeche" ("ziel") ;
CREATE INDEX "idx_fk_BP_SchutzPflegeEntwicklungsFlaeche_refMassnahmenText" ON "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_SchutzPflegeEntwicklungsFlaeche" ("refMassnahmenText") ;
CREATE INDEX "idx_fk_BP_SchutzPflegeEntwicklungsFlaeche_refLandschaftsplan" ON "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_SchutzPflegeEntwicklungsFlaeche" ("refLandschaftsplan") ;
GRANT SELECT ON TABLE "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_SchutzPflegeEntwicklungsFlaeche" TO xp_gast;
GRANT ALL ON TABLE "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_SchutzPflegeEntwicklungsFlaeche" TO bp_user;
COMMENT ON TABLE  "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_SchutzPflegeEntwicklungsFlaeche" IS 'Umgrenzung von Flächen für Maßnahmen zum Schutz, zur Pflege und zur Entwicklung von Natur und Landschaft (§9 Abs. 1 Nr. 20 und Abs. 6 BauGB)';
COMMENT ON COLUMN  "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_SchutzPflegeEntwicklungsFlaeche"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN  "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_SchutzPflegeEntwicklungsFlaeche"."ziel" IS 'Unterscheidung nach den Zielen "Schutz, Pflege" und "Entwicklung".';
COMMENT ON COLUMN "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_SchutzPflegeEntwicklungsFlaeche"."sonstZiel" IS 'Textlich formuliertes Ziel, wenn das Attribut ziel den Wert 9999 (Sonstiges) hat.';
COMMENT ON COLUMN  "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_SchutzPflegeEntwicklungsFlaeche"."istAusgleich" IS 'Gibt an, ob die Maßnahme zum Ausgleich eines Eingriffs benutzt wird.';
CREATE TRIGGER "change_to_BP_SchutzPflegeEntwicklungsFlaeche" BEFORE INSERT OR UPDATE ON "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_SchutzPflegeEntwicklungsFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_BP_SchutzPflegeEntwicklungsFlaeche" AFTER DELETE ON "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_SchutzPflegeEntwicklungsFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "BP_SchutzPflegeEntwicklungsFlaeche_Flaechenobjekt" BEFORE INSERT OR UPDATE ON "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_SchutzPflegeEntwicklungsFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isFlaechenobjekt"();

-- -----------------------------------------------------
-- Table "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_SchutzPflegeEntwicklungsFlaeche_massnahme"
-- -----------------------------------------------------
CREATE  TABLE  "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_SchutzPflegeEntwicklungsFlaeche_massnahme" (
  "BP_SchutzPflegeEntwicklungsFlaeche_gid" BIGINT NOT NULL ,
  "massnahme" INTEGER NOT NULL ,
  PRIMARY KEY ("BP_SchutzPflegeEntwicklungsFlaeche_gid", "massnahme"),
  CONSTRAINT "fk_BP_SchutzPflegeEntwicklungsFlaeche_massnahme1"
    FOREIGN KEY ("BP_SchutzPflegeEntwicklungsFlaeche_gid" )
    REFERENCES "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_SchutzPflegeEntwicklungsFlaeche" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_BP_SchutzPflegeEntwicklungsFlaeche_massnahme2"
    FOREIGN KEY ("massnahme" )
    REFERENCES "XP_Basisobjekte"."XP_SPEMassnahmenDaten" ("id" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
GRANT SELECT ON TABLE "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_SchutzPflegeEntwicklungsFlaeche_massnahme" TO xp_gast;
GRANT ALL ON TABLE "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_SchutzPflegeEntwicklungsFlaeche_massnahme" TO bp_user;
COMMENT ON TABLE  "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_SchutzPflegeEntwicklungsFlaeche_massnahme" IS 'Durchzuführende Maßnahmen.';

-- -----------------------------------------------------
-- Table "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_SchutzPflegeEntwicklungsMassnahme"
-- -----------------------------------------------------
CREATE  TABLE  "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_SchutzPflegeEntwicklungsMassnahme" (
  "gid" BIGINT NOT NULL ,
  "ziel" INTEGER NULL ,
  "sonstZiel" VARCHAR(255),
  "istAusgleich" BOOLEAN,
  "refMassnahmenText" INTEGER,
  "refLandschaftsplan" INTEGER,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_BP_SchutzPflegeEntwicklungsMassnahme_XP_SPEZiele"
    FOREIGN KEY ("ziel" )
    REFERENCES "XP_Enumerationen"."XP_SPEZiele" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_BP_SchutzPflegeEntwicklungsMassnahme_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "BP_Basisobjekte"."BP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_BP_SchutzPflegeEntwicklungsMassnahme_refMassnahmenText"
    FOREIGN KEY ("refMassnahmenText" )
    REFERENCES "XP_Basisobjekte"."XP_ExterneReferenz" ("id" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_BP_SchutzPflegeEntwicklungsMassnahme_refLandschaftsplan"
    FOREIGN KEY ("refLandschaftsplan" )
    REFERENCES "XP_Basisobjekte"."XP_ExterneReferenz" ("id" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE);

CREATE INDEX "idx_fk_BP_SchutzPflegeEntwicklungsMassnahme_XP_SPEZiele" ON "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_SchutzPflegeEntwicklungsMassnahme" ("ziel") ;
CREATE INDEX "idx_fk_BP_SchutzPflegeEntwicklungsMassnahme_refMassnahmenText" ON "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_SchutzPflegeEntwicklungsMassnahme" ("refMassnahmenText") ;
CREATE INDEX "idx_fk_BP_SchutzPflegeEntwicklungsMassnahme_refLandschaftsplan" ON "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_SchutzPflegeEntwicklungsMassnahme" ("refLandschaftsplan") ;
GRANT SELECT ON TABLE "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_SchutzPflegeEntwicklungsMassnahme" TO xp_gast;
GRANT ALL ON TABLE "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_SchutzPflegeEntwicklungsMassnahme" TO bp_user;
COMMENT ON TABLE  "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_SchutzPflegeEntwicklungsMassnahme" IS 'Maßnahmen zum Schutz, zur Pflege und zur Entwicklung von Natur und Landschaft (§9 Abs. 1 Nr. 20 und Abs. 6 BauGB).';
COMMENT ON COLUMN  "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_SchutzPflegeEntwicklungsMassnahme"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN  "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_SchutzPflegeEntwicklungsMassnahme"."ziel" IS 'Unterscheidung nach den Zielen "Schutz, Pflege" und "Entwicklung".';
COMMENT ON COLUMN "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_SchutzPflegeEntwicklungsMassnahme"."sonstZiel" IS 'Textlich formuliertes Ziel, wenn das Attribut ziel den Wert 9999 (Sonstiges) hat.';
COMMENT ON COLUMN  "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_SchutzPflegeEntwicklungsMassnahme"."istAusgleich" IS 'Gibt an, ob die Maßnahme zum Ausgkeich von Eingriffen genutzt wird.';
COMMENT ON COLUMN  "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_SchutzPflegeEntwicklungsMassnahme"."refMassnahmenText" IS 'Referenz auf ein Dokument, das die durchzuführenden Maßnahmen beschreibt.';
COMMENT ON COLUMN  "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_SchutzPflegeEntwicklungsMassnahme"."refLandschaftsplan" IS 'Referenz auf den Landschaftsplan.';
CREATE TRIGGER "change_to_BP_SchutzPflegeEntwicklungsMassnahme" BEFORE INSERT OR UPDATE ON "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_SchutzPflegeEntwicklungsMassnahme" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_BP_SchutzPflegeEntwicklungsMassnahme" AFTER DELETE ON "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_SchutzPflegeEntwicklungsMassnahme" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_SchutzPflegeEntwicklungsMassnahme_massnahme"
-- -----------------------------------------------------
CREATE  TABLE  "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_SchutzPflegeEntwicklungsMassnahme_massnahme" (
  "BP_SchutzPflegeEntwicklungsMassnahme_gid" BIGINT NOT NULL ,
  "massnahme" INTEGER NOT NULL ,
  PRIMARY KEY ("BP_SchutzPflegeEntwicklungsMassnahme_gid", "massnahme"),
  CONSTRAINT "fk_BP_SchutzPflegeEntwicklungsMassnahme_massnahme1"
    FOREIGN KEY ("BP_SchutzPflegeEntwicklungsMassnahme_gid" )
    REFERENCES "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_SchutzPflegeEntwicklungsMassnahme" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_BP_SchutzPflegeEntwicklungsMassnahme_massnahme2"
    FOREIGN KEY ("massnahme" )
    REFERENCES "XP_Basisobjekte"."XP_SPEMassnahmenDaten" ("id" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
GRANT SELECT ON TABLE "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_SchutzPflegeEntwicklungsMassnahme_massnahme" TO xp_gast;
GRANT ALL ON TABLE "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_SchutzPflegeEntwicklungsMassnahme_massnahme" TO bp_user;
COMMENT ON TABLE  "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_SchutzPflegeEntwicklungsMassnahme_massnahme" IS 'Durchzuführende Maßnahmen.';

-- -----------------------------------------------------
-- Table "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_SchutzPflegeEntwicklungsMassnahmeFlaeche"
-- -----------------------------------------------------
CREATE  TABLE  "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_SchutzPflegeEntwicklungsMassnahmeFlaeche" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_BP_SchutzPflegeEntwicklungsMassnahmeFlaeche_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_SchutzPflegeEntwicklungsMassnahme" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("BP_Basisobjekte"."BP_Flaechenobjekt");

GRANT SELECT ON TABLE "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_SchutzPflegeEntwicklungsMassnahmeFlaeche" TO xp_gast;
GRANT ALL ON TABLE "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_SchutzPflegeEntwicklungsMassnahmeFlaeche" TO bp_user;
CREATE INDEX "BP_SchutzPflegeEntwicklungsMassnahmeFlaeche_gidx" ON "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_SchutzPflegeEntwicklungsMassnahmeFlaeche" using gist ("position");
COMMENT ON COLUMN "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_SchutzPflegeEntwicklungsMassnahmeFlaeche"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_BP_SchutzPflegeEntwicklungsMassnahmeFlaeche" BEFORE INSERT OR UPDATE ON "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_SchutzPflegeEntwicklungsMassnahmeFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_BP_SchutzPflegeEntwicklungsMassnahmeFlaeche" AFTER DELETE ON "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_SchutzPflegeEntwicklungsMassnahmeFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "BP_SchutzPflegeEntwicklungsMassnahmeFlaeche_Flaechenobjekt" BEFORE INSERT OR UPDATE ON "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_SchutzPflegeEntwicklungsMassnahmeFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isFlaechenobjekt"();

-- -----------------------------------------------------
-- Table "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_SchutzPflegeEntwicklungsMassnahmeLinie"
-- -----------------------------------------------------
CREATE  TABLE  "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_SchutzPflegeEntwicklungsMassnahmeLinie" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_BP_SchutzPflegeEntwicklungsMassnahmeLinie_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_SchutzPflegeEntwicklungsMassnahme" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("BP_Basisobjekte"."BP_Linienobjekt");

GRANT SELECT ON TABLE "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_SchutzPflegeEntwicklungsMassnahmeLinie" TO xp_gast;
GRANT ALL ON TABLE "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_SchutzPflegeEntwicklungsMassnahmeLinie" TO bp_user;
CREATE INDEX "BP_SchutzPflegeEntwicklungsMassnahmeLinie_gidx" ON "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_SchutzPflegeEntwicklungsMassnahmeLinie" using gist ("position");
COMMENT ON COLUMN "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_SchutzPflegeEntwicklungsMassnahmeLinie"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_BP_SchutzPflegeEntwicklungsMassnahmeLinie" BEFORE INSERT OR UPDATE ON "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_SchutzPflegeEntwicklungsMassnahmeLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_BP_SchutzPflegeEntwicklungsMassnahmeLinie" AFTER DELETE ON "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_SchutzPflegeEntwicklungsMassnahmeLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_SchutzPflegeEntwicklungsMassnahmePunkt"
-- -----------------------------------------------------
CREATE  TABLE  "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_SchutzPflegeEntwicklungsMassnahmePunkt" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_BP_SchutzPflegeEntwicklungsMassnahmePunkt_parent"
    FOREIGN KEY ("gid")
    REFERENCES "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_SchutzPflegeEntwicklungsMassnahme" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("BP_Basisobjekte"."BP_Punktobjekt");

GRANT SELECT ON TABLE "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_SchutzPflegeEntwicklungsMassnahmePunkt" TO xp_gast;
GRANT ALL ON TABLE "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_SchutzPflegeEntwicklungsMassnahmePunkt" TO bp_user;
CREATE INDEX "BP_SchutzPflegeEntwicklungsMassnahmePunkt_gidx" ON "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_SchutzPflegeEntwicklungsMassnahmePunkt" using gist ("position");
COMMENT ON COLUMN "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_SchutzPflegeEntwicklungsMassnahmePunkt"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_BP_SchutzPflegeEntwicklungsMassnahmePunkt" BEFORE INSERT OR UPDATE ON "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_SchutzPflegeEntwicklungsMassnahmePunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_BP_SchutzPflegeEntwicklungsMassnahmePunkt" AFTER DELETE ON "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_SchutzPflegeEntwicklungsMassnahmePunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "BP_Verkehr"."BP_StrassenbegrenzungsLinie"
-- -----------------------------------------------------
CREATE  TABLE  "BP_Verkehr"."BP_StrassenbegrenzungsLinie" (
  "gid" BIGINT NOT NULL ,
  "bautiefe" NUMERIC(10,2) ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_BP_StrassenbegrenzungsLinie_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "BP_Basisobjekte"."BP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("BP_Basisobjekte"."BP_Linienobjekt");

GRANT SELECT ON TABLE "BP_Verkehr"."BP_StrassenbegrenzungsLinie" TO xp_gast;
GRANT ALL ON TABLE "BP_Verkehr"."BP_StrassenbegrenzungsLinie" TO bp_user;
CREATE INDEX "BP_StrassenbegrenzungsLinie_gidx" ON "BP_Verkehr"."BP_StrassenbegrenzungsLinie" using gist ("position");
COMMENT ON TABLE "BP_Verkehr"."BP_StrassenbegrenzungsLinie" IS 'Straßenbegrenzungslinie (§9 Abs. 1 Nr. 11 und Abs. 6 BauGB). Durch die Digitalisierungsreihenfolge der Linienstützpunkte muss sichergestellt sein, dass die abzugrenzende Straßenfläche relativ zur Laufrichtung auf der linken Seite liegt.';
COMMENT ON COLUMN  "BP_Verkehr"."BP_StrassenbegrenzungsLinie"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_BP_StrassenbegrenzungsLinie" BEFORE INSERT OR UPDATE ON "BP_Verkehr"."BP_StrassenbegrenzungsLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_BP_StrassenbegrenzungsLinie" AFTER DELETE ON "BP_Verkehr"."BP_StrassenbegrenzungsLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "BP_Verkehr"."BP_StrassenkoerperHerstellung"
-- -----------------------------------------------------
CREATE TABLE  "BP_Verkehr"."BP_StrassenkoerperHerstellung" (
  "Code" INTEGER NOT NULL,
  "Bezeichner" VARCHAR(64) NOT NULL,
  PRIMARY KEY ("Code"));

GRANT SELECT ON TABLE "BP_Verkehr"."BP_StrassenkoerperHerstellung" TO xp_gast;

-- -----------------------------------------------------
-- Table "BP_Verkehr"."BP_Strassenkoerper"
-- -----------------------------------------------------
CREATE  TABLE  "BP_Verkehr"."BP_Strassenkoerper" (
  "gid" BIGINT NOT NULL ,
  "typ" INTEGER NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_BP_Strassenkoerper_typ"
    FOREIGN KEY ("typ" )
    REFERENCES "BP_Verkehr"."BP_StrassenkoerperHerstellung" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_BP_Strassenkoerper_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "BP_Basisobjekte"."BP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE);

GRANT SELECT ON TABLE "BP_Verkehr"."BP_Strassenkoerper" TO xp_gast;
GRANT ALL ON TABLE "BP_Verkehr"."BP_Strassenkoerper" TO bp_user;
COMMENT ON TABLE  "BP_Verkehr"."BP_Strassenkoerper" IS 'Flächen für Aufschüttungen, Abgrabungen und Stützmauern, soweit sie zur Herstellung des Straßenkörpers erforderlich sind (§9, Abs. 1, Nr. 26 BauGB).';
COMMENT ON COLUMN  "BP_Verkehr"."BP_Strassenkoerper"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN  "BP_Verkehr"."BP_Strassenkoerper"."typ" IS 'Notwendige Maßnahme zur Herstellung des Straßenkörpers.';
CREATE TRIGGER "change_to_BP_Strassenkoerper" BEFORE INSERT OR UPDATE ON "BP_Verkehr"."BP_Strassenkoerper" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_BP_Strassenkoerper" AFTER DELETE ON "BP_Verkehr"."BP_Strassenkoerper" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "BP_Verkehr"."BP_StrassenkoerperFlaeche"
-- -----------------------------------------------------
CREATE  TABLE  "BP_Verkehr"."BP_StrassenkoerperFlaeche" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_BP_StrassenkoerperFlaeche_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "BP_Verkehr"."BP_Strassenkoerper" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("BP_Basisobjekte"."BP_Flaechenobjekt");

GRANT SELECT ON TABLE "BP_Verkehr"."BP_StrassenkoerperFlaeche" TO xp_gast;
GRANT ALL ON TABLE "BP_Verkehr"."BP_StrassenkoerperFlaeche" TO bp_user;
CREATE INDEX "BP_StrassenkoerperFlaeche_gidx" ON "BP_Verkehr"."BP_StrassenkoerperFlaeche" using gist ("position");
COMMENT ON COLUMN "BP_Verkehr"."BP_StrassenkoerperFlaeche"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_BP_StrassenkoerperFlaeche" BEFORE INSERT OR UPDATE ON "BP_Verkehr"."BP_StrassenkoerperFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_BP_StrassenkoerperFlaeche" AFTER DELETE ON "BP_Verkehr"."BP_StrassenkoerperFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "BP_StrassenkoerperFlaeche_Flaechenobjekt" BEFORE INSERT OR UPDATE ON "BP_Verkehr"."BP_StrassenkoerperFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isFlaechenobjekt"();

-- -----------------------------------------------------
-- Table "BP_Verkehr"."BP_StrassenkoerperLinie"
-- -----------------------------------------------------
CREATE  TABLE  "BP_Verkehr"."BP_StrassenkoerperLinie" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_BP_StrassenkoerperLinie_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "BP_Verkehr"."BP_Strassenkoerper" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("BP_Basisobjekte"."BP_Linienobjekt");

GRANT SELECT ON TABLE "BP_Verkehr"."BP_StrassenkoerperLinie" TO xp_gast;
GRANT ALL ON TABLE "BP_Verkehr"."BP_StrassenkoerperLinie" TO bp_user;
CREATE INDEX "BP_StrassenkoerperLinie_gidx" ON "BP_Verkehr"."BP_StrassenkoerperLinie" using gist ("position");
COMMENT ON COLUMN "BP_Verkehr"."BP_StrassenkoerperLinie"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_BP_StrassenkoerperLinie" BEFORE INSERT OR UPDATE ON "BP_Verkehr"."BP_StrassenkoerperLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_BP_StrassenkoerperLinie" AFTER DELETE ON "BP_Verkehr"."BP_StrassenkoerperLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "BP_Verkehr"."BP_StrassenkoerperPunkt"
-- -----------------------------------------------------
CREATE  TABLE  "BP_Verkehr"."BP_StrassenkoerperPunkt" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_BP_StrassenkoerperPunkt_parent"
    FOREIGN KEY ("gid")
    REFERENCES "BP_Verkehr"."BP_Strassenkoerper" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("BP_Basisobjekte"."BP_Punktobjekt");

GRANT SELECT ON TABLE "BP_Verkehr"."BP_StrassenkoerperPunkt" TO xp_gast;
GRANT ALL ON TABLE "BP_Verkehr"."BP_StrassenkoerperPunkt" TO bp_user;
CREATE INDEX "BP_StrassenkoerperPunkt_gidx" ON "BP_Verkehr"."BP_StrassenkoerperPunkt" using gist ("position");
COMMENT ON COLUMN "BP_Verkehr"."BP_StrassenkoerperPunkt"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_BP_StrassenkoerperPunkt" BEFORE INSERT OR UPDATE ON "BP_Verkehr"."BP_StrassenkoerperPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_BP_StrassenkoerperPunkt" AFTER DELETE ON "BP_Verkehr"."BP_StrassenkoerperPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "BP_Sonstiges"."BP_TextlicheFestsetzungsFlaeche"
-- -----------------------------------------------------
CREATE  TABLE  "BP_Sonstiges"."BP_TextlicheFestsetzungsFlaeche" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_BP_TextlicheFestsetzungsFlaeche_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "BP_Basisobjekte"."BP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("BP_Basisobjekte"."BP_Flaechenobjekt");

GRANT SELECT ON TABLE "BP_Sonstiges"."BP_TextlicheFestsetzungsFlaeche" TO xp_gast;
GRANT ALL ON TABLE "BP_Sonstiges"."BP_TextlicheFestsetzungsFlaeche" TO bp_user;
CREATE INDEX "BP_TextlicheFestsetzungsFlaeche_gidx" ON "BP_Sonstiges"."BP_TextlicheFestsetzungsFlaeche" using gist ("position");
COMMENT ON TABLE "BP_Sonstiges"."BP_TextlicheFestsetzungsFlaeche" IS 'Bereich in dem bestimmte Textliche Festsetzungen gültig sind, die über die Relation "refTextInhalt" (Basisklasse BP_Objekt) spezifiziert werden.';
COMMENT ON COLUMN  "BP_Sonstiges"."BP_TextlicheFestsetzungsFlaeche"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_BP_TextlicheFestsetzungsFlaeche" BEFORE INSERT OR UPDATE ON "BP_Sonstiges"."BP_TextlicheFestsetzungsFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_BP_TextlicheFestsetzungsFlaeche" AFTER DELETE ON "BP_Sonstiges"."BP_TextlicheFestsetzungsFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "ueberlagerung_BP_TextlicheFestsetzungsFlaeche" BEFORE INSERT OR UPDATE ON "BP_Sonstiges"."BP_TextlicheFestsetzungsFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isUeberlagerungsobjekt"();

-- -----------------------------------------------------
-- Table "BP_Sonstiges"."BP_UnverbindlicheVormerkung"
-- -----------------------------------------------------
CREATE  TABLE  "BP_Sonstiges"."BP_UnverbindlicheVormerkung" (
  "gid" BIGINT NOT NULL ,
  "vormerkung" CHARACTER VARYING(256) ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_BP_UnverbindlicheVormerkung_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "BP_Basisobjekte"."BP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE);

GRANT SELECT ON TABLE "BP_Sonstiges"."BP_UnverbindlicheVormerkung" TO xp_gast;
GRANT ALL ON TABLE "BP_Sonstiges"."BP_UnverbindlicheVormerkung" TO bp_user;
COMMENT ON TABLE  "BP_Sonstiges"."BP_UnverbindlicheVormerkung" IS 'Unverbindliche Vormerkung späterer Planungsabsichten.';
COMMENT ON COLUMN  "BP_Sonstiges"."BP_UnverbindlicheVormerkung"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN  "BP_Sonstiges"."BP_UnverbindlicheVormerkung"."vormerkung" IS 'Text der Vormerkung.';
CREATE TRIGGER "change_to_BP_UnverbindlicheVormerkung" BEFORE INSERT OR UPDATE ON "BP_Sonstiges"."BP_UnverbindlicheVormerkung" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_BP_UnverbindlicheVormerkung" AFTER DELETE ON "BP_Sonstiges"."BP_UnverbindlicheVormerkung" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "BP_Sonstiges"."BP_UnverbindlicheVormerkungFlaeche"
-- -----------------------------------------------------
CREATE  TABLE  "BP_Sonstiges"."BP_UnverbindlicheVormerkungFlaeche" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_BP_UnverbindlicheVormerkungFlaeche_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "BP_Sonstiges"."BP_UnverbindlicheVormerkung" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("BP_Basisobjekte"."BP_Flaechenobjekt");

GRANT SELECT ON TABLE "BP_Sonstiges"."BP_UnverbindlicheVormerkungFlaeche" TO xp_gast;
GRANT ALL ON TABLE "BP_Sonstiges"."BP_UnverbindlicheVormerkungFlaeche" TO bp_user;
CREATE INDEX "BP_UnverbindlicheVormerkungFlaeche_gidx" ON "BP_Sonstiges"."BP_UnverbindlicheVormerkungFlaeche" using gist ("position");
COMMENT ON COLUMN "BP_Sonstiges"."BP_UnverbindlicheVormerkungFlaeche"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_BP_UnverbindlicheVormerkungFlaeche" BEFORE INSERT OR UPDATE ON "BP_Sonstiges"."BP_UnverbindlicheVormerkungFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_BP_UnverbindlicheVormerkungFlaeche" AFTER DELETE ON "BP_Sonstiges"."BP_UnverbindlicheVormerkungFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "BP_UnverbindlicheVormerkungFlaeche_Flaechenobjekt" BEFORE INSERT OR UPDATE ON "BP_Sonstiges"."BP_UnverbindlicheVormerkungFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isFlaechenobjekt"();

-- -----------------------------------------------------
-- Table "BP_Sonstiges"."BP_UnverbindlicheVormerkungLinie"
-- -----------------------------------------------------
CREATE  TABLE  "BP_Sonstiges"."BP_UnverbindlicheVormerkungLinie" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_BP_UnverbindlicheVormerkungLinie_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "BP_Sonstiges"."BP_UnverbindlicheVormerkung" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("BP_Basisobjekte"."BP_Linienobjekt");

GRANT SELECT ON TABLE "BP_Sonstiges"."BP_UnverbindlicheVormerkungLinie" TO xp_gast;
GRANT ALL ON TABLE "BP_Sonstiges"."BP_UnverbindlicheVormerkungLinie" TO bp_user;
CREATE INDEX "BP_UnverbindlicheVormerkungLinie_gidx" ON "BP_Sonstiges"."BP_UnverbindlicheVormerkungLinie" using gist ("position");
COMMENT ON COLUMN "BP_Sonstiges"."BP_UnverbindlicheVormerkungLinie"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_BP_UnverbindlicheVormerkungLinie" BEFORE INSERT OR UPDATE ON "BP_Sonstiges"."BP_UnverbindlicheVormerkungLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_BP_UnverbindlicheVormerkungLinie" AFTER DELETE ON "BP_Sonstiges"."BP_UnverbindlicheVormerkungLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "BP_Sonstiges"."BP_UnverbindlicheVormerkungPunkt"
-- -----------------------------------------------------
CREATE  TABLE  "BP_Sonstiges"."BP_UnverbindlicheVormerkungPunkt" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_BP_UnverbindlicheVormerkungPunkt_parent"
    FOREIGN KEY ("gid")
    REFERENCES "BP_Sonstiges"."BP_UnverbindlicheVormerkung" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("BP_Basisobjekte"."BP_Punktobjekt");

GRANT SELECT ON TABLE "BP_Sonstiges"."BP_UnverbindlicheVormerkungPunkt" TO xp_gast;
GRANT ALL ON TABLE "BP_Sonstiges"."BP_UnverbindlicheVormerkungPunkt" TO bp_user;
CREATE INDEX "BP_UnverbindlicheVormerkungPunkt_gidx" ON "BP_Sonstiges"."BP_UnverbindlicheVormerkungPunkt" using gist ("position");
COMMENT ON COLUMN "BP_Sonstiges"."BP_UnverbindlicheVormerkungPunkt"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_BP_UnverbindlicheVormerkungPunkt" BEFORE INSERT OR UPDATE ON "BP_Sonstiges"."BP_UnverbindlicheVormerkungPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_BP_UnverbindlicheVormerkungPunkt" AFTER DELETE ON "BP_Sonstiges"."BP_UnverbindlicheVormerkungPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "BP_Sonstiges"."BP_Veraenderungssperre"
-- -----------------------------------------------------
CREATE  TABLE  "BP_Sonstiges"."BP_Veraenderungssperre" (
  "gid" BIGINT NOT NULL ,
  "gueltigkeitsDatum" DATE NOT NULL default current_date,
  "verlaengerung" INTEGER NOT NULL default 1000,
  "refBeschluss" INTEGER,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_BP_Veraenderungssperre_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "BP_Basisobjekte"."BP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_BP_Veraenderungssperre_XP_ExterneReferenz1"
    FOREIGN KEY ("refBeschluss" )
    REFERENCES "XP_Basisobjekte"."XP_ExterneReferenz" ("id" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_BP_Veraenderungssperre_verlaengerung"
    FOREIGN KEY ("verlaengerung" )
    REFERENCES "XP_Enumerationen"."XP_VerlaengerungVeraenderungssperre" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE)
INHERITS ("BP_Basisobjekte"."BP_Flaechenobjekt");

GRANT SELECT ON TABLE "BP_Sonstiges"."BP_Veraenderungssperre" TO xp_gast;
GRANT ALL ON TABLE "BP_Sonstiges"."BP_Veraenderungssperre" TO bp_user;
CREATE INDEX "BP_Veraenderungssperre_gidx" ON "BP_Sonstiges"."BP_Veraenderungssperre" using gist ("position");
CREATE INDEX "idx_fk_BP_Veraenderungssperre1" ON "BP_Sonstiges"."BP_Veraenderungssperre" ("refBeschluss") ;
COMMENT ON TABLE "BP_Sonstiges"."BP_Veraenderungssperre" IS 'Ausweisung einer Veränderungssperre, die nicht den gesamten Geltungsbereich des Plans umfasst. Bei Verwendung dieser Klasse muss das Attribut "veraenderungssperre" des zugehörigen Plans (Klasse BP_Plan) auf "false" gesetzt werden.';
COMMENT ON COLUMN  "BP_Sonstiges"."BP_Veraenderungssperre"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN  "BP_Sonstiges"."BP_Veraenderungssperre"."gueltigkeitsDatum" IS 'Datum bis zu dem die Veränderungssperre bestehen bleibt.';
COMMENT ON COLUMN  "BP_Sonstiges"."BP_Veraenderungssperre"."verlaengerung" IS 'Gibt an, ob die Veränderungssperre bereits ein- oder zweimal verlängert wurde.';
COMMENT ON COLUMN  "BP_Sonstiges"."BP_Veraenderungssperre"."refBeschluss" IS 'Referenz auf das Dokument mit dem zug. Beschluss.';
CREATE TRIGGER "change_to_BP_Veraenderungssperre" BEFORE INSERT OR UPDATE ON "BP_Sonstiges"."BP_Veraenderungssperre" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_BP_Veraenderungssperre" AFTER DELETE ON "BP_Sonstiges"."BP_Veraenderungssperre" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "ueberlagerung_BP_Veraenderungssperre" BEFORE INSERT OR UPDATE ON "BP_Sonstiges"."BP_Veraenderungssperre" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isUeberlagerungsobjekt"();

-- -----------------------------------------------------
-- Table "BP_Landwirtschaft_Wald_und_Gruen"."BP_WaldFlaeche"
-- -----------------------------------------------------
CREATE  TABLE  "BP_Landwirtschaft_Wald_und_Gruen"."BP_WaldFlaeche" (
  "gid" BIGINT NOT NULL ,
  "eigentumsart" INTEGER,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_BP_WaldFlaeche_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "BP_Basisobjekte"."BP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_BP_WaldFlaeche_eigentumsart"
    FOREIGN KEY ("eigentumsart" )
    REFERENCES "XP_Enumerationen"."XP_EigentumsartWald" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE)
INHERITS ("BP_Basisobjekte"."BP_Flaechenobjekt");

GRANT SELECT ON TABLE "BP_Landwirtschaft_Wald_und_Gruen"."BP_WaldFlaeche" TO xp_gast;
GRANT ALL ON TABLE "BP_Landwirtschaft_Wald_und_Gruen"."BP_WaldFlaeche" TO bp_user;
CREATE INDEX "BP_WaldFlaeche_gidx" ON "BP_Landwirtschaft_Wald_und_Gruen"."BP_WaldFlaeche" using gist ("position");
COMMENT ON TABLE "BP_Landwirtschaft_Wald_und_Gruen"."BP_WaldFlaeche" IS 'Festsetzung von Waldflächen (§9, Abs. 1, Nr. 18b BauGB).';
COMMENT ON COLUMN  "BP_Landwirtschaft_Wald_und_Gruen"."BP_WaldFlaeche"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN "BP_Landwirtschaft_Wald_und_Gruen"."BP_WaldFlaeche"."eigentumsart" IS 'Festlegung der Eigentumsart des Waldes';
CREATE TRIGGER "change_to_BP_WaldFlaeche" BEFORE INSERT OR UPDATE ON "BP_Landwirtschaft_Wald_und_Gruen"."BP_WaldFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_BP_WaldFlaeche" AFTER DELETE ON "BP_Landwirtschaft_Wald_und_Gruen"."BP_WaldFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "flaechenschluss_BP_WaldFlaeche" BEFORE INSERT OR UPDATE OR DELETE ON "BP_Landwirtschaft_Wald_und_Gruen"."BP_WaldFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isFlaechenschlussobjekt"();

-- -----------------------------------------------------
-- Table "BP_Landwirtschaft_Wald_und_Gruen"."BP_WaldFlaeche_zweckbestimmung"
-- -----------------------------------------------------
CREATE  TABLE  "BP_Landwirtschaft_Wald_und_Gruen"."BP_WaldFlaeche_zweckbestimmung" (
  "BP_WaldFlaeche_gid" BIGINT NOT NULL ,
  "zweckbestimmung" INTEGER NOT NULL ,
  PRIMARY KEY ("BP_WaldFlaeche_gid", "zweckbestimmung"),
  CONSTRAINT "fk_BP_WaldFlaeche_zweckbestimmung1"
    FOREIGN KEY ("BP_WaldFlaeche_gid" )
    REFERENCES "BP_Landwirtschaft_Wald_und_Gruen"."BP_WaldFlaeche" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_BP_WaldFlaeche_zweckbestimmung2"
    FOREIGN KEY ("zweckbestimmung" )
    REFERENCES "XP_Enumerationen"."XP_ZweckbestimmungWald" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
GRANT SELECT ON TABLE "BP_Landwirtschaft_Wald_und_Gruen"."BP_WaldFlaeche_zweckbestimmung" TO xp_gast;
GRANT ALL ON TABLE "BP_Landwirtschaft_Wald_und_Gruen"."BP_WaldFlaeche_zweckbestimmung" TO bp_user;
COMMENT ON TABLE  "BP_Landwirtschaft_Wald_und_Gruen"."BP_WaldFlaeche_zweckbestimmung" IS 'Zweckbestimmungen der Waldfläche';

-- -----------------------------------------------------
-- Table "BP_Landwirtschaft_Wald_und_Gruen"."BP_DetailZweckbestWaldFlaeche"
-- -----------------------------------------------------
CREATE  TABLE  "BP_Landwirtschaft_Wald_und_Gruen"."BP_DetailZweckbestWaldFlaeche" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Code") );
GRANT SELECT ON TABLE "BP_Landwirtschaft_Wald_und_Gruen"."BP_DetailZweckbestWaldFlaeche" TO xp_gast;
GRANT ALL ON "BP_Landwirtschaft_Wald_und_Gruen"."BP_DetailZweckbestWaldFlaeche" TO bp_user;
CREATE TRIGGER "ins_upd_BP_DetailZweckbestWaldFlaeche" BEFORE INSERT OR UPDATE ON "BP_Landwirtschaft_Wald_und_Gruen"."BP_DetailZweckbestWaldFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isCodeList"();

-- -----------------------------------------------------
-- Table "BP_Landwirtschaft_Wald_und_Gruen"."BP_WaldFlaeche_detaillierteZweckbestimmung"
-- -----------------------------------------------------
CREATE  TABLE  "BP_Landwirtschaft_Wald_und_Gruen"."BP_WaldFlaeche_detaillierteZweckbestimmung" (
  "BP_WaldFlaeche_gid" BIGINT NOT NULL ,
  "detaillierteZweckbestimmung" INTEGER NOT NULL ,
  PRIMARY KEY ("BP_WaldFlaeche_gid", "detaillierteZweckbestimmung"),
  CONSTRAINT "fk_BP_WaldFlaeche_detaillierteZweckbestimmung1"
    FOREIGN KEY ("BP_WaldFlaeche_gid" )
    REFERENCES "BP_Landwirtschaft_Wald_und_Gruen"."BP_WaldFlaeche" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_BP_WaldFlaeche_detaillierteZweckbestimmung2"
    FOREIGN KEY ("detaillierteZweckbestimmung" )
    REFERENCES "BP_Landwirtschaft_Wald_und_Gruen"."BP_DetailZweckbestWaldFlaeche" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
GRANT SELECT ON TABLE "BP_Landwirtschaft_Wald_und_Gruen"."BP_WaldFlaeche_detaillierteZweckbestimmung" TO xp_gast;
GRANT ALL ON TABLE "BP_Landwirtschaft_Wald_und_Gruen"."BP_WaldFlaeche_detaillierteZweckbestimmung" TO bp_user;
COMMENT ON TABLE  "BP_Landwirtschaft_Wald_und_Gruen"."BP_WaldFlaeche_detaillierteZweckbestimmung" IS 'Über eine CodeList definierte zusätzliche Zweckbestimmung.';

-- -----------------------------------------------------
-- Table "BP_Landwirtschaft_Wald_und_Gruen"."BP_WaldFlaeche_betreten"
-- -----------------------------------------------------
CREATE TABLE "BP_Landwirtschaft_Wald_und_Gruen"."BP_WaldFlaeche_betreten" (
  "BP_WaldFlaeche_gid" BIGINT NOT NULL ,
  "betreten" INTEGER NOT NULL ,
  PRIMARY KEY ("BP_WaldFlaeche_gid", "betreten"),
  CONSTRAINT "fk_BP_WaldFlaeche_betreten1"
    FOREIGN KEY ("BP_WaldFlaeche_gid" )
    REFERENCES "BP_Landwirtschaft_Wald_und_Gruen"."BP_WaldFlaeche" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_BP_WaldFlaeche_betreten2"
    FOREIGN KEY ("betreten" )
    REFERENCES "XP_Enumerationen"."XP_WaldbetretungTyp" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
GRANT SELECT ON TABLE "BP_Landwirtschaft_Wald_und_Gruen"."BP_WaldFlaeche_betreten" TO xp_gast;
GRANT ALL ON TABLE "BP_Landwirtschaft_Wald_und_Gruen"."BP_WaldFlaeche_betreten" TO bp_user;
COMMENT ON TABLE "BP_Landwirtschaft_Wald_und_Gruen"."BP_WaldFlaeche_betreten" IS 'Festlegung zusätzlicher, normalerweise nicht-gestatteter Aktivitäten, die in dem Wald ausgeführt werden dürfen, nach §14 Abs. 2 Bundeswaldgesetz.';

-- -----------------------------------------------------
-- Table "BP_Wasser"."BP_DetailZweckbestWasserwirtschaft"
-- -----------------------------------------------------
CREATE  TABLE  "BP_Wasser"."BP_DetailZweckbestWasserwirtschaft" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Code") );
GRANT SELECT ON TABLE "BP_Wasser"."BP_DetailZweckbestWasserwirtschaft" TO xp_gast;
GRANT ALL ON "BP_Wasser"."BP_DetailZweckbestWasserwirtschaft" TO bp_user;
CREATE TRIGGER "ins_upd_BP_DetailZweckbestWasserwirtschaft" BEFORE INSERT OR UPDATE ON "BP_Wasser"."BP_DetailZweckbestWasserwirtschaft" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isCodeList"();

-- -----------------------------------------------------
-- Table "BP_Wasser"."BP_WasserwirtschaftsFlaeche"
-- -----------------------------------------------------
CREATE  TABLE  "BP_Wasser"."BP_WasserwirtschaftsFlaeche" (
  "gid" BIGINT NOT NULL ,
  "zweckbestimmung" INTEGER,
  "detaillierteZweckbestimmung" INTEGER,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_BP_WasserwirtschaftsFlaeche_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "BP_Basisobjekte"."BP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_BP_WasserwirtschaftsFlaeche_zweckbestimmung"
    FOREIGN KEY ("zweckbestimmung" )
    REFERENCES "XP_Enumerationen"."XP_ZweckbestimmungWasserwirtschaft" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_BP_WasserwirtschaftsFlaeche_detaillierteZweckbestimmung"
    FOREIGN KEY ("detaillierteZweckbestimmung" )
    REFERENCES "BP_Wasser"."BP_DetailZweckbestWasserwirtschaft" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE)
INHERITS ("BP_Basisobjekte"."BP_Flaechenobjekt");

GRANT SELECT ON TABLE "BP_Wasser"."BP_WasserwirtschaftsFlaeche" TO xp_gast;
GRANT ALL ON TABLE "BP_Wasser"."BP_WasserwirtschaftsFlaeche" TO bp_user;
CREATE INDEX "BP_WasserwirtschaftsFlaeche_gidx" ON "BP_Wasser"."BP_WasserwirtschaftsFlaeche" using gist ("position");
CREATE INDEX "idx_fk_BP_WasserwirtschaftsFlaeche1" ON "BP_Wasser"."BP_WasserwirtschaftsFlaeche" ("zweckbestimmung") ;
CREATE INDEX "idx_fk_BP_WasserwirtschaftsFlaeche2" ON "BP_Wasser"."BP_WasserwirtschaftsFlaeche" ("detaillierteZweckbestimmung") ;
COMMENT ON TABLE "BP_Wasser"."BP_WasserwirtschaftsFlaeche" IS 'Flächen für die Wasserwirtschaft (§9 Abs. 1 Nr. 16a BauGB), sowie Flächen für Hochwasserschutz-anlagen und für die Regelung des Wasserabflusses (§9 Abs. 1 Nr. 16b BauGB).';
COMMENT ON COLUMN  "BP_Wasser"."BP_WasserwirtschaftsFlaeche"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN  "BP_Wasser"."BP_WasserwirtschaftsFlaeche"."zweckbestimmung" IS 'Zweckbestimmung der Fläche.';
COMMENT ON COLUMN  "BP_Wasser"."BP_WasserwirtschaftsFlaeche"."detaillierteZweckbestimmung" IS 'Über eine CodeList definierte Zweckbestimmung der Fläche.';
CREATE TRIGGER "change_to_BP_WasserwirtschaftsFlaeche" BEFORE INSERT OR UPDATE ON "BP_Wasser"."BP_WasserwirtschaftsFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_BP_WasserwirtschaftsFlaeche" AFTER DELETE ON "BP_Wasser"."BP_WasserwirtschaftsFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "BP_WasserwirtschaftsFlaeche_Flaechenobjekt" BEFORE INSERT OR UPDATE ON "BP_Wasser"."BP_WasserwirtschaftsFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isFlaechenobjekt"();

-- -----------------------------------------------------
-- Table "BP_Sonstiges"."BP_WegerechtTypen"
-- -----------------------------------------------------
CREATE  TABLE  "BP_Sonstiges"."BP_WegerechtTypen" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Code") );
GRANT SELECT ON TABLE "BP_Sonstiges"."BP_WegerechtTypen" TO xp_gast;

-- -----------------------------------------------------
-- Table "BP_Sonstiges"."BP_Wegerecht"
-- -----------------------------------------------------
CREATE  TABLE  "BP_Sonstiges"."BP_Wegerecht" (
  "gid" BIGINT NOT NULL ,
  "zugunstenVon" CHARACTER VARYING(256),
  "thema" CHARACTER VARYING(256) ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_BP_Wegerecht_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "BP_Basisobjekte"."BP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE);

GRANT SELECT ON TABLE "BP_Sonstiges"."BP_Wegerecht" TO xp_gast;
GRANT ALL ON TABLE "BP_Sonstiges"."BP_Wegerecht" TO bp_user;
COMMENT ON TABLE  "BP_Sonstiges"."BP_Wegerecht" IS 'Unverbindliche Vormerkung späterer Planungsabsichten.';
COMMENT ON COLUMN  "BP_Sonstiges"."BP_Wegerecht"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN  "BP_Sonstiges"."BP_Wegerecht"."zugunstenVon" IS 'Inhaber der Rechte.';
COMMENT ON COLUMN  "BP_Sonstiges"."BP_Wegerecht"."thema" IS 'Beschreibung des Rechtes.';
CREATE TRIGGER "change_to_BP_Wegerecht" BEFORE INSERT OR UPDATE ON "BP_Sonstiges"."BP_Wegerecht" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_BP_Wegerecht" AFTER DELETE ON "BP_Sonstiges"."BP_Wegerecht" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "BP_Sonstiges"."BP_Wegerecht_typ"
-- -----------------------------------------------------
CREATE TABLE "BP_Sonstiges"."BP_Wegerecht_typ" (
  "BP_Wegerecht_gid" BIGINT NOT NULL ,
  "typ" INTEGER NOT NULL ,
  PRIMARY KEY ("BP_Wegerecht_gid", "typ"),
  CONSTRAINT "fk_BP_Wegerecht_typ1"
    FOREIGN KEY ("BP_Wegerecht_gid" )
    REFERENCES "BP_Sonstiges"."BP_Wegerecht" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_BP_Wegerecht_typ2"
    FOREIGN KEY ("typ" )
    REFERENCES "BP_Sonstiges"."BP_WegerechtTypen" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
GRANT SELECT ON TABLE "BP_Sonstiges"."BP_Wegerecht_typ" TO xp_gast;
GRANT ALL ON TABLE "BP_Sonstiges"."BP_Wegerecht_typ" TO bp_user;
COMMENT ON TABLE "BP_Sonstiges"."BP_Wegerecht_typ" IS 'Typ des Wegerechts.
Die kombinierten Enumerationswerte sind veraltet und werden in Version 6.0 wegfallen. Stattdessen sollte das Attribut typ mehrfach belegt werden.';

-- -----------------------------------------------------
-- Table "BP_Sonstiges"."BP_WegerechtFlaeche"
-- -----------------------------------------------------
CREATE  TABLE  "BP_Sonstiges"."BP_WegerechtFlaeche" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_BP_WegerechtFlaeche_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "BP_Sonstiges"."BP_Wegerecht" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("BP_Basisobjekte"."BP_Flaechenobjekt");

GRANT SELECT ON TABLE "BP_Sonstiges"."BP_WegerechtFlaeche" TO xp_gast;
GRANT ALL ON TABLE "BP_Sonstiges"."BP_WegerechtFlaeche" TO bp_user;
CREATE INDEX "BP_WegerechtFlaeche_gidx" ON "BP_Sonstiges"."BP_WegerechtFlaeche" using gist ("position");
COMMENT ON COLUMN "BP_Sonstiges"."BP_WegerechtFlaeche"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_BP_WegerechtFlaeche" BEFORE INSERT OR UPDATE ON "BP_Sonstiges"."BP_WegerechtFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_BP_WegerechtFlaeche" AFTER DELETE ON "BP_Sonstiges"."BP_WegerechtFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "BP_WegerechtFlaeche_Flaechenobjekt" BEFORE INSERT OR UPDATE ON "BP_Sonstiges"."BP_WegerechtFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isFlaechenobjekt"();

-- -----------------------------------------------------
-- Table "BP_Sonstiges"."BP_WegerechtLinie"
-- -----------------------------------------------------
CREATE  TABLE  "BP_Sonstiges"."BP_WegerechtLinie" (
  "gid" BIGINT NOT NULL ,
  "breite" REAL,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_BP_WegerechtLinie_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "BP_Sonstiges"."BP_Wegerecht" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("BP_Basisobjekte"."BP_Linienobjekt");

GRANT SELECT ON TABLE "BP_Sonstiges"."BP_WegerechtLinie" TO xp_gast;
GRANT ALL ON TABLE "BP_Sonstiges"."BP_WegerechtLinie" TO bp_user;
CREATE INDEX "BP_WegerechtLinie_gidx" ON "BP_Sonstiges"."BP_WegerechtLinie" using gist ("position");
COMMENT ON COLUMN "BP_Sonstiges"."BP_WegerechtLinie"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN  "BP_Sonstiges"."BP_WegerechtLinie"."breite" IS 'Breite des Wegerechts bei linienförmiger Ausweisung der Geometrie.';
CREATE TRIGGER "change_to_BP_WegerechtLinie" BEFORE INSERT OR UPDATE ON "BP_Sonstiges"."BP_WegerechtLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_BP_WegerechtLinie" AFTER DELETE ON "BP_Sonstiges"."BP_WegerechtLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "BP_Sonstiges"."BP_WegerechtPunkt"
-- -----------------------------------------------------
CREATE  TABLE  "BP_Sonstiges"."BP_WegerechtPunkt" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_BP_WegerechtPunkt_parent"
    FOREIGN KEY ("gid")
    REFERENCES "BP_Sonstiges"."BP_Wegerecht" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("BP_Basisobjekte"."BP_Punktobjekt");

GRANT SELECT ON TABLE "BP_Sonstiges"."BP_WegerechtPunkt" TO xp_gast;
GRANT ALL ON TABLE "BP_Sonstiges"."BP_WegerechtPunkt" TO bp_user;
CREATE INDEX "BP_WegerechtPunkt_gidx" ON "BP_Sonstiges"."BP_WegerechtPunkt" using gist ("position");
COMMENT ON COLUMN "BP_Sonstiges"."BP_WegerechtPunkt"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_BP_WegerechtPunkt" BEFORE INSERT OR UPDATE ON "BP_Sonstiges"."BP_WegerechtPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_BP_WegerechtPunkt" AFTER DELETE ON "BP_Sonstiges"."BP_WegerechtPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "BP_Sonstiges"."BP_Sichtflaeche"
-- -----------------------------------------------------
CREATE TABLE "BP_Sonstiges"."BP_Sichtflaeche" (
  "gid" BIGINT NOT NULL,
  PRIMARY KEY ("gid"),
  CONSTRAINT "fk_BP_Sichtflaeche_parent"
    FOREIGN KEY ("gid")
    REFERENCES "BP_Basisobjekte"."BP_Objekt" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("BP_Basisobjekte"."BP_Flaechenobjekt");

GRANT SELECT ON TABLE "BP_Sonstiges"."BP_Sichtflaeche" TO xp_gast;
GRANT ALL ON TABLE "BP_Sonstiges"."BP_Sichtflaeche" TO bp_user;
CREATE INDEX "BP_Sichtflaeche_gidx" ON "BP_Sonstiges"."BP_Sichtflaeche" using gist ("position");
COMMENT ON TABLE "BP_Sonstiges"."BP_Sichtflaeche" IS 'Flächenhafte Festlegung einer Sichtfläche';
COMMENT ON COLUMN "BP_Sonstiges"."BP_Sichtflaeche"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_BP_Sichtflaeche" BEFORE INSERT OR UPDATE ON "BP_Sonstiges"."BP_Sichtflaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_BP_Sichtflaeche" AFTER DELETE ON "BP_Sonstiges"."BP_Sichtflaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "ueberlagerung_BP_Sichtflaeche" BEFORE INSERT OR UPDATE ON "BP_Sonstiges"."BP_Sichtflaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isUeberlagerungsobjekt"();

-- -----------------------------------------------------
-- Table "BP_Bebauung"."BP_Bauweise"
-- -----------------------------------------------------
CREATE TABLE  "BP_Bebauung"."BP_Bauweise" (
  "Code" INTEGER NOT NULL,
  "Bezeichner" VARCHAR(64) NOT NULL,
  PRIMARY KEY ("Code"));
GRANT SELECT ON "BP_Bebauung"."BP_Bauweise" TO xp_gast;

-- -----------------------------------------------------
-- Table "BP_Bebauung"."BP_BebauungsArt"
-- -----------------------------------------------------
CREATE TABLE  "BP_Bebauung"."BP_BebauungsArt" (
  "Code" INTEGER NOT NULL,
  "Bezeichner" VARCHAR(64) NOT NULL,
  PRIMARY KEY ("Code"));
GRANT SELECT ON "BP_Bebauung"."BP_BebauungsArt" TO xp_gast;

-- -----------------------------------------------------
-- Table "BP_Bebauung"."BP_GrenzBebauung"
-- -----------------------------------------------------
CREATE TABLE  "BP_Bebauung"."BP_GrenzBebauung" (
  "Code" INTEGER NOT NULL,
  "Bezeichner" VARCHAR(64) NOT NULL,
  PRIMARY KEY ("Code"));
GRANT SELECT ON "BP_Bebauung"."BP_GrenzBebauung" TO xp_gast;

-- -----------------------------------------------------
-- Table "BP_Bebauung"."BP_Dachform"
-- -----------------------------------------------------
CREATE TABLE  "BP_Bebauung"."BP_Dachform" (
  "Code" INTEGER NOT NULL,
  "Bezeichner" VARCHAR(64) NOT NULL,
  PRIMARY KEY ("Code"));
GRANT SELECT ON "BP_Bebauung"."BP_Dachform" TO xp_gast;

-- -----------------------------------------------------
-- Table "BP_Bebauung"."BP_DetailDachform"
-- -----------------------------------------------------
CREATE TABLE  "BP_Bebauung"."BP_DetailDachform" (
  "Code" INTEGER NOT NULL,
  "Bezeichner" VARCHAR(64) NOT NULL,
  PRIMARY KEY ("Code"));
GRANT SELECT ON "BP_Bebauung"."BP_DetailDachform" TO xp_gast;
GRANT ALL ON "BP_Bebauung"."BP_DetailDachform" TO bp_user;
CREATE TRIGGER "ins_upd_BP_DetailDachform" BEFORE INSERT OR UPDATE ON "BP_Bebauung"."BP_DetailDachform" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isCodeList"();

-- ----------------------------------------------------
-- Table "BP_Bebauung"."BP_DetailArtDerBaulNutzung"
-- -----------------------------------------------------
CREATE TABLE  "BP_Bebauung"."BP_DetailArtDerBaulNutzung" (
  "Code" INTEGER NOT NULL,
  "Bezeichner" VARCHAR(64) NOT NULL,
  PRIMARY KEY ("Code"));
GRANT SELECT ON "BP_Bebauung"."BP_DetailArtDerBaulNutzung" TO xp_gast;
GRANT ALL ON "BP_Bebauung"."BP_DetailArtDerBaulNutzung" TO bp_user;
CREATE TRIGGER "ins_upd_BP_DetailArtDerBaulNutzung" BEFORE INSERT OR UPDATE ON "BP_Bebauung"."BP_DetailArtDerBaulNutzung" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isCodeList"();

-- ----------------------------------------------------
-- Table "BP_Bebauung"."BP_Zulaessigkeit"
-- -----------------------------------------------------
CREATE TABLE  "BP_Bebauung"."BP_Zulaessigkeit" (
  "Code" INTEGER NOT NULL,
  "Bezeichner" VARCHAR(64) NOT NULL,
  PRIMARY KEY ("Code"));
GRANT SELECT ON "BP_Bebauung"."BP_Zulaessigkeit" TO xp_gast;

-- -----------------------------------------------------
-- Table "BP_Bebauung"."BP_AbweichendeBauweise"
-- -----------------------------------------------------
CREATE TABLE  "BP_Bebauung"."BP_AbweichendeBauweise" (
  "Code" INTEGER NOT NULL,
  "Bezeichner" VARCHAR(64) NOT NULL,
  PRIMARY KEY ("Code"));
GRANT SELECT ON "BP_Bebauung"."BP_AbweichendeBauweise" TO xp_gast;
GRANT ALL ON "BP_Bebauung"."BP_AbweichendeBauweise" TO bp_user;
CREATE TRIGGER "ins_upd_BP_AbweichendeBauweise" BEFORE INSERT OR UPDATE ON "BP_Bebauung"."BP_AbweichendeBauweise" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isCodeList"();

-- -----------------------------------------------------
-- Table "BP_Bebauung"."BP_FestsetzungenBaugebiet"
-- -----------------------------------------------------
CREATE TABLE  "BP_Bebauung"."BP_FestsetzungenBaugebiet" (
  "gid" BIGINT NOT NULL,
  "MaxZahlWohnungen" INTEGER,
  "Fmin" REAL,
  "Fmax" REAL,
  "Bmin" REAL,
  "Bmax" REAL,
  "Tmin" REAL,
  "Tmax" REAL,
  "GFZmin" REAL,
  "GFZmax" REAL,
  "GFZ" REAL,
  "GFZ_Ausn" REAL,
  "GFmin" REAL,
  "GFmax" REAL,
  "GF" REAL,
  "GF_Ausn" REAL,
  "BMZ" REAL,
  "BMZ_Ausn" REAL,
  "BM" REAL,
  "BM_Ausn" REAL,
  "GRZmin" REAL,
  "GRZmax" REAL,
  "GRZ" REAL,
  "GRZ_Ausn" REAL,
  "GRmin" REAL,
  "GRmax" REAL,
  "GR" REAL,
  "GR_Ausn" REAL,
  "Zmin" INTEGER,
  "Zmax" INTEGER,
  "Zzwingend" INTEGER,
  "Z" INTEGER,
  "Z_Ausn" INTEGER,
  "Z_Staffel" INTEGER,
  "Z_Dach" INTEGER,
  "ZUmin" INTEGER,
  "ZUmax" INTEGER,
  "ZUzwingend" INTEGER,
  "ZU" INTEGER,
  "ZU_Ausn" INTEGER,
  PRIMARY KEY ("gid"),
  CONSTRAINT "fk_BP_FestsetzungenBaugebiet_parent"
    FOREIGN KEY ("gid")
    REFERENCES "BP_Basisobjekte"."BP_Objekt" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE);
GRANT SELECT ON TABLE "BP_Bebauung"."BP_FestsetzungenBaugebiet" TO xp_gast;
GRANT ALL ON TABLE "BP_Bebauung"."BP_FestsetzungenBaugebiet" TO bp_user;
COMMENT ON TABLE  "BP_Bebauung"."BP_FestsetzungenBaugebiet" IS '';
COMMENT ON COLUMN  "BP_Bebauung"."BP_FestsetzungenBaugebiet"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN  "BP_Bebauung"."BP_FestsetzungenBaugebiet"."MaxZahlWohnungen" IS 'Höchstzulässige Zahl der Wohnungen in Wohngebäuden';
COMMENT ON COLUMN  "BP_Bebauung"."BP_FestsetzungenBaugebiet"."Fmin" IS 'Mindestmaß für die Größe (Fläche) eines Baugrundstücks.';
COMMENT ON COLUMN  "BP_Bebauung"."BP_FestsetzungenBaugebiet"."Fmax" IS 'Höchstmaß für die Größe (Fläche) eines Baugrundstücks.';
COMMENT ON COLUMN  "BP_Bebauung"."BP_FestsetzungenBaugebiet"."Bmin" IS 'Minimale Breite von Baugrundstücken';
COMMENT ON COLUMN  "BP_Bebauung"."BP_FestsetzungenBaugebiet"."Bmax" IS 'Maximale Breite von Baugrundstücken.';
COMMENT ON COLUMN  "BP_Bebauung"."BP_FestsetzungenBaugebiet"."Tmin" IS 'Minimale Tiefe von Baugrundstücken.';
COMMENT ON COLUMN  "BP_Bebauung"."BP_FestsetzungenBaugebiet"."Tmax" IS 'Maximale Tiefe von Baugrundstücken.';
COMMENT ON COLUMN  "BP_Bebauung"."BP_FestsetzungenBaugebiet"."GFZmin" IS 'Minimal zulässige Geschossflächenzahl.';
COMMENT ON COLUMN  "BP_Bebauung"."BP_FestsetzungenBaugebiet"."GFZmax" IS 'Maximal zulässige Geschossflächenzahl bei einer Bereichsangabe. Das Attribut GFZmin muss ebenfalls belegt sein.';
COMMENT ON COLUMN  "BP_Bebauung"."BP_FestsetzungenBaugebiet"."GFZ" IS 'Maximal zulässige Geschossflächenzahl.';
COMMENT ON COLUMN  "BP_Bebauung"."BP_FestsetzungenBaugebiet"."GFZ_Ausn" IS 'Maximal zulässige Geschossflächenzahl als Ausnahme.';
COMMENT ON COLUMN  "BP_Bebauung"."BP_FestsetzungenBaugebiet"."GFmin" IS 'Minimal zulässige Geschossfläche';
COMMENT ON COLUMN  "BP_Bebauung"."BP_FestsetzungenBaugebiet"."GFmax" IS 'Maximal zulässige Geschossfläche bei einer Bereichsabgabe. Das Attribut GFmin muss ebenfalls belegt sein.';
COMMENT ON COLUMN  "BP_Bebauung"."BP_FestsetzungenBaugebiet"."GF" IS 'Maximal zulässige Geschossfläche.';
COMMENT ON COLUMN  "BP_Bebauung"."BP_FestsetzungenBaugebiet"."GF_Ausn" IS 'Ausnahmsweise maximal zulässige Geschossfläche.';
COMMENT ON COLUMN  "BP_Bebauung"."BP_FestsetzungenBaugebiet"."BMZ" IS 'Maximal zulässige Baumassenzahl.';
COMMENT ON COLUMN  "BP_Bebauung"."BP_FestsetzungenBaugebiet"."BMZ_Ausn" IS 'Ausnahmsweise maximal zulässige Baumassenzahl.';
COMMENT ON COLUMN  "BP_Bebauung"."BP_FestsetzungenBaugebiet"."BM" IS 'Maximal zulässige Baumasse.';
COMMENT ON COLUMN  "BP_Bebauung"."BP_FestsetzungenBaugebiet"."BM_Ausn" IS 'Ausnahmsweise maximal zulässige Baumasse.';
COMMENT ON COLUMN  "BP_Bebauung"."BP_FestsetzungenBaugebiet"."GRZmin" IS 'Minimal zulässige Grundflächenzahl.';
COMMENT ON COLUMN  "BP_Bebauung"."BP_FestsetzungenBaugebiet"."GRZmax" IS 'Maximal zulässige Grundflächenzahl bei einer Bereichsangabe. Das Attribut GRZmin muss ebenfalls spezifiziert werden.';
COMMENT ON COLUMN  "BP_Bebauung"."BP_FestsetzungenBaugebiet"."GRZ" IS 'Maximal zulässige Grundflächenzahl';
COMMENT ON COLUMN  "BP_Bebauung"."BP_FestsetzungenBaugebiet"."GRZ_Ausn" IS 'Ausnahmsweise maximal zulässige Grundflächenzahl.';
COMMENT ON COLUMN  "BP_Bebauung"."BP_FestsetzungenBaugebiet"."GRmin" IS 'Minimal zulässige Grundfläche.';
COMMENT ON COLUMN  "BP_Bebauung"."BP_FestsetzungenBaugebiet"."GRmax" IS 'Maximal zulässige Grundfläche bei einer Bereichsangabe. Das Attribut GRmin muss ebenfalls spezifiziert werden.';
COMMENT ON COLUMN  "BP_Bebauung"."BP_FestsetzungenBaugebiet"."GR" IS 'Maximal zulässige Grundfläche.';
COMMENT ON COLUMN  "BP_Bebauung"."BP_FestsetzungenBaugebiet"."GR_Ausn" IS 'Ausnahmsweise maximal zulässige Grundfläche.';
COMMENT ON COLUMN  "BP_Bebauung"."BP_FestsetzungenBaugebiet"."Zmin" IS 'Minimal zulässige Zahl der oberirdischen Vollgeschosse.';
COMMENT ON COLUMN  "BP_Bebauung"."BP_FestsetzungenBaugebiet"."Zmax" IS 'Maximal zulässige Zahl der oberirdischen Vollgeschosse bei einer Bereichsangabe. Das Attribut Zmin muss ebenfalls belegt sein.';
COMMENT ON COLUMN  "BP_Bebauung"."BP_FestsetzungenBaugebiet"."Zzwingend" IS 'Zwingend vorgeschriebene Zahl der oberirdischen Vollgeschosse.';
COMMENT ON COLUMN  "BP_Bebauung"."BP_FestsetzungenBaugebiet"."Z" IS 'Maximalzahl der oberirdischen Vollgeschosse.';
COMMENT ON COLUMN  "BP_Bebauung"."BP_FestsetzungenBaugebiet"."Z_Ausn" IS 'Ausnahmsweise maximal zulässige Zahl der oberirdischen Vollgeschosse.';
COMMENT ON COLUMN  "BP_Bebauung"."BP_FestsetzungenBaugebiet"."Z_Staffel" IS 'Maximalzahl von oberirdischen zurückgesetzten Vollgeschossen als Staffelgeschoss.';
COMMENT ON COLUMN  "BP_Bebauung"."BP_FestsetzungenBaugebiet"."Z_Dach" IS 'Maximalzahl der zusätzlich erlaubten Dachgeschosse, die gleichzeitig Vollgeschosse sind.';
COMMENT ON COLUMN  "BP_Bebauung"."BP_FestsetzungenBaugebiet"."ZUmin" IS 'Minimal zulässige Zahl der unterirdischen Geschosse.';
COMMENT ON COLUMN  "BP_Bebauung"."BP_FestsetzungenBaugebiet"."ZUmax" IS 'Maximal zulässige Zahl der unterirdischen Geschosse bei einer Bereichsangabe. Das Attribut ZUmin muss ebenfalls belegt sein.';
COMMENT ON COLUMN  "BP_Bebauung"."BP_FestsetzungenBaugebiet"."ZUzwingend" IS 'Zwingend vorgeschriebene Zahl der unterirdischen Geschosse.';
COMMENT ON COLUMN  "BP_Bebauung"."BP_FestsetzungenBaugebiet"."ZU" IS 'Maximal zulässige Zahl der unterirdischen Geschosse.';
COMMENT ON COLUMN  "BP_Bebauung"."BP_FestsetzungenBaugebiet"."ZU_Ausn" IS 'Ausnahmsweise maximal zulässige Zahl der unterirdischen Geschosse.';
CREATE TRIGGER "change_to_BP_FestsetzungenBaugebiet" BEFORE INSERT OR UPDATE ON "BP_Bebauung"."BP_FestsetzungenBaugebiet" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "consistancy_BP_FestsetzungenBaugebiet" BEFORE INSERT OR UPDATE ON "BP_Bebauung"."BP_FestsetzungenBaugebiet" FOR EACH ROW EXECUTE PROCEDURE "BP_Bebauung"."BP_FestsetzungenBaugebiet_konsistent"();
CREATE TRIGGER "delete_BP_FestsetzungenBaugebiet" AFTER DELETE ON "BP_Bebauung"."BP_FestsetzungenBaugebiet" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "BP_Bebauung"."BP_GestaltungBaugebiet"
-- -----------------------------------------------------
CREATE TABLE  "BP_Bebauung"."BP_GestaltungBaugebiet" (
  "gid" BIGINT NOT NULL,
  "DNmin" INTEGER,
  "DNmax" INTEGER,
  "DN" INTEGER,
  "DNZwingend" INTEGER,
  "FR" INTEGER,
  PRIMARY KEY ("gid"),
  CONSTRAINT "fk_BP_GestaltungBaugebiet_parent"
    FOREIGN KEY ("gid")
    REFERENCES "BP_Bebauung"."BP_FestsetzungenBaugebiet" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE);

GRANT SELECT ON TABLE "BP_Bebauung"."BP_GestaltungBaugebiet" TO xp_gast;
GRANT ALL ON TABLE "BP_Bebauung"."BP_GestaltungBaugebiet" TO bp_user;
COMMENT ON TABLE  "BP_Bebauung"."BP_GestaltungBaugebiet" IS '';
COMMENT ON COLUMN  "BP_Bebauung"."BP_GestaltungBaugebiet"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN "BP_Bebauung"."BP_GestaltungBaugebiet"."DNmin" IS 'Minimal zulässige Dachneigung bei einer Bereichsangabe.
Dies Attribut ist veraltet und wird in Version 6.0 wegfallen. Es sollte stattdessen der Datentyp BP_Dachgestaltung (Attribut dachgestaltung) verwendet werden.';
COMMENT ON COLUMN "BP_Bebauung"."BP_GestaltungBaugebiet"."DNmax" IS 'Maximal zulässige Dachneigung bei einer Bereichsangabe.
Dies Attribut ist veraltet und wird in Version 6.0 wegfallen. Es sollte stattdessen der Datentyp BP_Dachgestaltung (Attribut dachgestaltung) verwendet werden.';
COMMENT ON COLUMN "BP_Bebauung"."BP_GestaltungBaugebiet"."DN" IS 'Maximal zulässige Dachneigung.
Dies Attribut ist veraltet und wird in Version 6.0 wegfallen. Es sollte stattdessen der Datentyp BP_Dachgestaltung (Attribut dachgestaltung) verwendet werden.';
COMMENT ON COLUMN "BP_Bebauung"."BP_GestaltungBaugebiet"."DNZwingend" IS 'Zwingend vorgeschriebene Dachneigung.
Dies Attribut ist veraltet und wird in Version 6.0 wegfallen. Es sollte stattdessen der Datentyp BP_Dachgestaltung (Attribut dachgestaltung) verwendet werden.';
COMMENT ON COLUMN  "BP_Bebauung"."BP_GestaltungBaugebiet"."FR" IS 'Vorgeschriebene Firstrichtung (Gradangabe)';
CREATE TRIGGER "change_to_BP_GestaltungBaugebiet" BEFORE INSERT OR UPDATE ON "BP_Bebauung"."BP_GestaltungBaugebiet" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_BP_GestaltungBaugebiet" AFTER DELETE ON "BP_Bebauung"."BP_GestaltungBaugebiet" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "BP_Bebauung"."BP_Dachgestaltung"
-- -----------------------------------------------------
CREATE TABLE "BP_Bebauung"."BP_Dachgestaltung" (
  "id" INTEGER NOT NULL DEFAULT nextval('"BP_Bebauung"."BP_Dachgestaltung_id_seq"'),
  "DNmin" INTEGER,
  "DNmax" INTEGER,
  "DN" INTEGER,
  "DNzwingend" INTEGER,
  "dachform" INTEGER,
  "detaillierteDachform" INTEGER,
  PRIMARY KEY ("id"),
  CONSTRAINT "fk_BP_Dachgestaltung_dachform1"
    FOREIGN KEY ("dachform" )
    REFERENCES "BP_Bebauung"."BP_Dachform" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_BP_Dachgestaltung_detaillierteDachform1"
    FOREIGN KEY ("detaillierteDachform")
    REFERENCES "BP_Bebauung"."BP_DetailDachform" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE);

GRANT SELECT ON TABLE "BP_Bebauung"."BP_Dachgestaltung" TO xp_gast;
GRANT ALL ON TABLE "BP_Bebauung"."BP_Dachgestaltung" TO bp_user;
COMMENT ON TABLE "BP_Bebauung"."BP_Dachgestaltung" IS 'Zusammenfassung von Parametern zur Festlegung der zulässigen Dachformen.';
COMMENT ON COLUMN "BP_Bebauung"."BP_Dachgestaltung"."id" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN "BP_Bebauung"."BP_Dachgestaltung"."DNmin" IS 'Minimale Dachneigung bei einer Bereichsangabe. Das Attribut DNmax muss ebenfalls belegt sein.';
COMMENT ON COLUMN "BP_Bebauung"."BP_Dachgestaltung"."DNmax" IS 'Maximale Dachneigung bei einer Bereichsangabe. Das Attribut DNmin muss ebenfalls belegt sein.';
COMMENT ON COLUMN "BP_Bebauung"."BP_Dachgestaltung"."DN" IS 'Maximal zulässige Dachneigung.';
COMMENT ON COLUMN "BP_Bebauung"."BP_Dachgestaltung"."DNzwingend" IS 'Zwingend vorgeschriebene Dachneigung.';
COMMENT ON COLUMN "BP_Bebauung"."BP_Dachgestaltung"."dachform" IS 'Erlaubte Dachform';
COMMENT ON COLUMN "BP_Bebauung"."BP_Dachgestaltung"."detaillierteDachform" IS 'Über eine Codeliste definiertere detailliertere Dachform.';

-- -----------------------------------------------------
-- Table "BP_Bebauung"."BP_GestaltungBaugebiet_dachgestaltung"
-- -----------------------------------------------------
CREATE TABLE "BP_Bebauung"."BP_GestaltungBaugebiet_dachgestaltung" (
  "BP_GestaltungBaugebiet_gid" BIGINT NOT NULL ,
  "dachgestaltung" INTEGER NOT NULL ,
  PRIMARY KEY ("BP_GestaltungBaugebiet_gid", "dachgestaltung"),
  CONSTRAINT "fk_BP_GestaltungBaugebiet_dachgestaltung1"
    FOREIGN KEY ("BP_GestaltungBaugebiet_gid" )
    REFERENCES "BP_Bebauung"."BP_GestaltungBaugebiet" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_BP_GestaltungBaugebiet_dachgestaltung2"
    FOREIGN KEY ("dachgestaltung" )
    REFERENCES "BP_Bebauung"."BP_Dachgestaltung" ("id" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
GRANT SELECT ON TABLE "BP_Bebauung"."BP_GestaltungBaugebiet_dachgestaltung" TO xp_gast;
GRANT ALL ON TABLE "BP_Bebauung"."BP_GestaltungBaugebiet_dachgestaltung" TO bp_user;
COMMENT ON TABLE "BP_Bebauung"."BP_GestaltungBaugebiet_dachgestaltung" IS 'Parameter zur Einschränkung der zulässigen Dachformen.';

-- -----------------------------------------------------
-- Table "BP_Bebauung"."BP_GestaltungBaugebiet_dachform"
-- -----------------------------------------------------
CREATE  TABLE  "BP_Bebauung"."BP_GestaltungBaugebiet_dachform" (
  "BP_GestaltungBaugebiet_gid" BIGINT NOT NULL ,
  "dachform" INTEGER NOT NULL ,
  PRIMARY KEY ("BP_GestaltungBaugebiet_gid", "dachform"),
  CONSTRAINT "fk_BP_GestaltungBaugebiet_dachform1"
    FOREIGN KEY ("BP_GestaltungBaugebiet_gid" )
    REFERENCES "BP_Bebauung"."BP_GestaltungBaugebiet" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_BP_GestaltungBaugebiet_dachform2"
    FOREIGN KEY ("dachform" )
    REFERENCES "BP_Bebauung"."BP_Dachform" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
GRANT SELECT ON TABLE "BP_Bebauung"."BP_GestaltungBaugebiet_dachform" TO xp_gast;
GRANT ALL ON TABLE "BP_Bebauung"."BP_GestaltungBaugebiet_dachform" TO bp_user;
COMMENT ON TABLE "BP_Bebauung"."BP_GestaltungBaugebiet_dachform" IS 'Erlaubte Dachformen.
Dies Attribut ist veraltet und wird in Version 6.0 wegfallen. Es sollte stattdessen der Datentyp BP_Dachgestaltung (Attribut dachgestaltung) verwendet werden.';

-- -----------------------------------------------------
-- Table "BP_Bebauung"."BP_GestaltungBaugebiet_detaillierteDachform"
-- -----------------------------------------------------
CREATE TABLE "BP_Bebauung"."BP_GestaltungBaugebiet_detaillierteDachform" (
  "BP_GestaltungBaugebiet_gid" BIGINT NOT NULL,
  "detaillierteDachform" INTEGER NOT NULL,
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
Der an einer bestimmten Listenposition aufgeführte Wert von "detaillierteDachform" bezieht sich auf den an gleicher Position stehenden Attributwert von dachform.
Dies Attribut ist veraltet und wird in Version 6.0 wegfallen. Es sollte stattdessen der Datentyp BP_Dachgestaltung (Attribut dachgestaltung) verwendet werden.';

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
CREATE TRIGGER "change_to_BP_BaugebietBauweise" BEFORE INSERT OR UPDATE ON "BP_Bebauung"."BP_BaugebietBauweise" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_BP_BaugebietBauweise" AFTER DELETE ON "BP_Bebauung"."BP_BaugebietBauweise" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "BP_Bebauung"."BP_ZusaetzlicheFestsetzungen"
-- -----------------------------------------------------
CREATE TABLE "BP_Bebauung"."BP_ZusaetzlicheFestsetzungen" (
  "gid" BIGINT NOT NULL,
  "wohnnutzungEGStrasse" INTEGER,
  "ZWohn" INTEGER,
  "GFAntWohnen" INTEGER,
  "GFWohnen" INTEGER,
  "GFAntGewerbe" INTEGER,
  "GFGewerbe" INTEGER,
  "VF" INTEGER,
  PRIMARY KEY ("gid"),
  CONSTRAINT "fk_BP_ZusaetzlicheFestsetzungen_parent"
    FOREIGN KEY ("gid")
    REFERENCES "BP_Bebauung"."BP_BaugebietBauweise" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_BP_ZusaetzlicheFestsetzungen_BP_Zulaessigkeit"
    FOREIGN KEY ("wohnnutzungEGStrasse")
    REFERENCES "BP_Bebauung"."BP_Zulaessigkeit" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE);

GRANT SELECT ON TABLE "BP_Bebauung"."BP_ZusaetzlicheFestsetzungen" TO xp_gast;
GRANT ALL ON TABLE "BP_Bebauung"."BP_ZusaetzlicheFestsetzungen" TO bp_user;
COMMENT ON COLUMN "BP_Bebauung"."BP_ZusaetzlicheFestsetzungen"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN "BP_Bebauung"."BP_ZusaetzlicheFestsetzungen"."wohnnutzungEGStrasse" IS 'Festsetzung nach §6a Abs. (4) Nr. 1 BauNVO: Für urbane Gebiete oder Teile solcher Gebiete kann festgesetzt werden, dass in Gebäuden im Erdgeschoss an der Straßenseite eine Wohnnutzung nicht oder nur ausnahmsweise zulässig ist.';
COMMENT ON COLUMN "BP_Bebauung"."BP_ZusaetzlicheFestsetzungen"."ZWohn" IS 'Festsetzung nach §4a Abs. (4) Nr. 1 bzw. nach §6a Abs. (4) Nr. 2 BauNVO: Für besondere Wohngebiete und urbane Gebiete oder Teile solcher Gebiete kann festgesetzt werden, dass in Gebäuden oberhalb eines im Bebauungsplan bestimmten Geschosses nur Wohnungen zulässig sind.';
COMMENT ON COLUMN "BP_Bebauung"."BP_ZusaetzlicheFestsetzungen"."GFAntWohnen" IS 'Festsetzung nach §4a Abs. (4) Nr. 2 bzw. §6a Abs. (4) Nr. 3 BauNVO: Für besondere Wohngebiete und urbane Gebiete oder Teile solcher Gebiete kann festgesetzt werden, dass in Gebäuden ein im Bebauungsplan bestimmter Anteil der zulässigen Geschossfläche für Wohnungen zu verwenden ist.';
COMMENT ON COLUMN "BP_Bebauung"."BP_ZusaetzlicheFestsetzungen"."GFWohnen" IS 'Festsetzung nach §4a Abs. (4) Nr. 2 bzw. §6a Abs. (4) Nr. 3 BauNVO: Für besondere Wohngebiete und urbane Gebiete oder Teile solcher Gebiete kann festgesetzt werden, dass in Gebäuden eine im Bebauungsplan bestimmte Größe der Geschossfläche für Wohnungen zu verwenden ist.';
COMMENT ON COLUMN "BP_Bebauung"."BP_ZusaetzlicheFestsetzungen"."GFAntGewerbe" IS 'Festsetzung nach §6a Abs. (4) Nr. 4 BauNVO: Für urbane Gebiete oder Teile solcher Gebiete kann festgesetzt werden, dass in Gebäuden ein im Bebauungsplan bestimmter Anteil der zulässigen Geschossfläche für gewerbliche Nutzungen zu verwenden ist.';
COMMENT ON COLUMN "BP_Bebauung"."BP_ZusaetzlicheFestsetzungen"."GFGewerbe" IS 'Festsetzung nach §6a Abs. (4) Nr. 4 BauNVO: Für urbane Gebiete oder Teile solcher Gebiete kann festgesetzt werden, dass in Gebäuden eine im Bebauungsplan bestimmte Größe der Geschossfläche für gewerbliche Nutzungen zu verwenden ist.';
COMMENT ON COLUMN "BP_Bebauung"."BP_ZusaetzlicheFestsetzungen"."VF" IS 'Festsetzung der maximal zulässigen Verkaufsfläche in einem Sondergebiet';
CREATE TRIGGER "change_to_BP_ZusaetzlicheFestsetzungen" BEFORE INSERT OR UPDATE ON "BP_Bebauung"."BP_ZusaetzlicheFestsetzungen" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_BP_ZusaetzlicheFestsetzungen" AFTER DELETE ON "BP_Bebauung"."BP_ZusaetzlicheFestsetzungen" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "BP_Bebauung"."BP_BaugebietBauweise_refGebauedequerschnitt"
-- -----------------------------------------------------
CREATE TABLE  "BP_Bebauung"."BP_BaugebietBauweise_refGebauedequerschnitt" (
  "BP_BaugebietBauweise_gid" BIGINT NOT NULL,
  "refGebauedequerschnitt" INTEGER NOT NULL,
  PRIMARY KEY ("BP_BaugebietBauweise_gid", "refGebauedequerschnitt"),
  CONSTRAINT "fk_BP_Baugebiet_refGebauedequerschnitt1"
    FOREIGN KEY ("BP_BaugebietBauweise_gid")
    REFERENCES "BP_Bebauung"."BP_BaugebietBauweise" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_BP_Baugebiet_refGebauedequerschnitt"
    FOREIGN KEY ("refGebauedequerschnitt")
    REFERENCES "XP_Basisobjekte"."XP_ExterneReferenz" ("id")
    ON DELETE NO ACTION
    ON UPDATE CASCADE);

CREATE INDEX "idx_fk_BP_Baugebiet_refGebauedequerschnitt1_idx" ON "BP_Bebauung"."BP_BaugebietBauweise_refGebauedequerschnitt" ("refGebauedequerschnitt");
CREATE INDEX "idx_fk_BP_Baugebiet_refGebauedequerschnitt2_idx" ON "BP_Bebauung"."BP_BaugebietBauweise_refGebauedequerschnitt" ("BP_BaugebietBauweise_gid");
GRANT SELECT ON TABLE "BP_Bebauung"."BP_BaugebietBauweise_refGebauedequerschnitt" TO xp_gast;
GRANT ALL ON TABLE "BP_Bebauung"."BP_BaugebietBauweise_refGebauedequerschnitt" TO bp_user;
COMMENT ON TABLE  "BP_Bebauung"."BP_BaugebietBauweise_refGebauedequerschnitt" IS 'Referenz auf ein Dokument mit vorgeschriebenen Gebäudequerschnitten.';

-- -----------------------------------------------------
-- Table "BP_Bebauung"."BP_BaugebietsTeilFlaeche"
-- -----------------------------------------------------
CREATE TABLE  "BP_Bebauung"."BP_BaugebietsTeilFlaeche" (
  "gid" BIGINT NOT NULL,
  "allgArtDerBaulNutzung" INTEGER,
  "besondereArtDerBaulNutzung" INTEGER,
  "detaillierteArtDerBaulNutzung" INTEGER,
  "nutzungText" VARCHAR(256),
  "abweichungBauNVO" INTEGER,
  "zugunstenVon" VARCHAR(64),
  PRIMARY KEY ("gid"),
  CONSTRAINT "fk_BP_BaugebietsTeilFlaeche_parent"
    FOREIGN KEY ("gid")
    REFERENCES "BP_Bebauung"."BP_ZusaetzlicheFestsetzungen" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_BP_BaugebietsTF_XP_AllgArtDerBaulNutzung1"
    FOREIGN KEY ("allgArtDerBaulNutzung")
    REFERENCES "XP_Enumerationen"."XP_AllgArtDerBaulNutzung" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_BP_BaugebietsTF_XP_BesondereArtDerBaulNutzung1"
    FOREIGN KEY ("besondereArtDerBaulNutzung")
    REFERENCES "XP_Enumerationen"."XP_BesondereArtDerBaulNutzung" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_BP_BaugebietsTF_BP_DetailArtDerBaulNutzung1"
    FOREIGN KEY ("detaillierteArtDerBaulNutzung")
    REFERENCES "BP_Bebauung"."BP_DetailArtDerBaulNutzung" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_BP_BaugebietsTF_XP_AbweichungBauNVOTypen1"
    FOREIGN KEY ("abweichungBauNVO")
    REFERENCES "XP_Enumerationen"."XP_AbweichungBauNVOTypen" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE)
INHERITS ("BP_Basisobjekte"."BP_Flaechenobjekt");

GRANT SELECT ON TABLE "BP_Bebauung"."BP_BaugebietsTeilFlaeche" TO xp_gast;
GRANT ALL ON TABLE "BP_Bebauung"."BP_BaugebietsTeilFlaeche" TO bp_user;
CREATE INDEX "BP_BaugebietsTeilFlaeche_gidx" ON "BP_Bebauung"."BP_BaugebietsTeilFlaeche" using gist ("position");
CREATE INDEX "idx_fk_BP_BaugebietsTF_XP_AllgArtDerBaulNutzung1_idx" ON "BP_Bebauung"."BP_BaugebietsTeilFlaeche" ("allgArtDerBaulNutzung");
CREATE INDEX "idx_fk_BP_BaugebietsTF_XP_BesondereArtDerBaulNutzung1_idx" ON "BP_Bebauung"."BP_BaugebietsTeilFlaeche" ("besondereArtDerBaulNutzung");
CREATE INDEX "idx_fk_BP_BaugebietsTF_BP_DetailArtDerBaulNutzung1_idx" ON "BP_Bebauung"."BP_BaugebietsTeilFlaeche" ("detaillierteArtDerBaulNutzung");
CREATE INDEX "idx_fk_BP_BaugebietsTF_XP_AbweichungBauNVOTypen1_idx" ON "BP_Bebauung"."BP_BaugebietsTeilFlaeche" ("abweichungBauNVO");
COMMENT ON TABLE "BP_Bebauung"."BP_BaugebietsTeilFlaeche" IS 'Teil eines Baugebiets mit einheitlicher Art und Maß der baulichen Nutzung. Das Maß der baulichen Nutzung sowie Festsetzungen zur Bauweise oder Grenzbebauung können innerhalb einer BP_BaugebietsTeilFlaeche unterschiedlich sein (BP_UeberbaubareGrundstueckeFlaeche). Dabei sollte die gleichzeitige Belegung desselben Attributs in BP_BaugebietsTeilFlaeche und einem überlagernden Objekt BP_UeberbaubareGrunsdstuecksFlaeche verzichtet werden. Ab Version 6.0 wird dies evtl. durch eine Konformitätsregel erzwungen.';
COMMENT ON COLUMN  "BP_Bebauung"."BP_BaugebietsTeilFlaeche"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN "BP_Bebauung"."BP_BaugebietsTeilFlaeche"."allgArtDerBaulNutzung" IS 'Spezifikation der allgemeinen Art der baulichen Nutzung.';
COMMENT ON COLUMN "BP_Bebauung"."BP_BaugebietsTeilFlaeche"."besondereArtDerBaulNutzung" IS 'Festsetzung der Art der baulichen Nutzung (§9, Abs. 1, Nr. 1 BauGB).';
COMMENT ON COLUMN "BP_Bebauung"."BP_BaugebietsTeilFlaeche"."detaillierteArtDerBaulNutzung" IS 'Über eine CodeList definierte Nutzungsart.';
COMMENT ON COLUMN "BP_Bebauung"."BP_BaugebietsTeilFlaeche"."nutzungText" IS 'Bei Nutzungsform "Sondergebiet" ("besondereArtDerBaulNutzung" == 2000, 2100, 3000 oder 4000): Kurzform der besonderen Art der baulichen Nutzung.';
COMMENT ON COLUMN "BP_Bebauung"."BP_BaugebietsTeilFlaeche"."abweichungBauNVO" IS 'Art der Abweichung von der BauNVO.';
COMMENT ON COLUMN "BP_Bebauung"."BP_BaugebietsTeilFlaeche"."zugunstenVon" IS 'Angabe des Begünstigen einer Ausweisung.';
CREATE TRIGGER "change_to_BP_BaugebietsTeilFlaeche" BEFORE INSERT OR UPDATE ON "BP_Bebauung"."BP_BaugebietsTeilFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_BP_BaugebietsTeilFlaeche" AFTER DELETE ON "BP_Bebauung"."BP_BaugebietsTeilFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "flaechenschluss_BP_BaugebietsTeilFlaeche" BEFORE INSERT OR UPDATE OR DELETE ON "BP_Bebauung"."BP_BaugebietsTeilFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isFlaechenschlussobjekt"();

-- -----------------------------------------------------
-- Table "BP_Bebauung"."BP_BaugebietsTeilFlaeche_sondernutzung"
-- -----------------------------------------------------
CREATE TABLE "BP_Bebauung"."BP_BaugebietsTeilFlaeche_sondernutzung" (
  "BP_BaugebietsTeilFlaeche_gid" BIGINT NOT NULL ,
  "sondernutzung" INTEGER NULL ,
  PRIMARY KEY ("BP_BaugebietsTeilFlaeche_gid", "sondernutzung"),
  CONSTRAINT "fk_BP_BaugebietsTeilFlaeche_sondernutzung1"
    FOREIGN KEY ("BP_BaugebietsTeilFlaeche_gid" )
    REFERENCES "BP_Bebauung"."BP_BaugebietsTeilFlaeche" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_BP_BaugebietsTeilFlaeche_sondernutzung2"
    FOREIGN KEY ("sondernutzung" )
    REFERENCES "XP_Enumerationen"."XP_Sondernutzungen" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
GRANT SELECT ON TABLE "BP_Bebauung"."BP_BaugebietsTeilFlaeche_sondernutzung" TO xp_gast;
GRANT ALL ON TABLE "BP_Bebauung"."BP_BaugebietsTeilFlaeche_sondernutzung" TO bp_user;
COMMENT ON TABLE "BP_Bebauung"."BP_BaugebietsTeilFlaeche_sondernutzung" IS 'Differenziert Sondernutzungen nach §10 und §11 der BauNVO von 1977 und 1990. Das Attribut wird nur benutzt, wenn besondereArtDerBaulNutzung unbelegt ist oder einen der Werte 2000 bzw. 2100 hat.';

-- -----------------------------------------------------
-- Table "BP_Bebauung"."BP_BauLinie"
-- -----------------------------------------------------
CREATE TABLE  "BP_Bebauung"."BP_BauLinie" (
  "gid" BIGINT NOT NULL,
  "bautiefe" NUMERIC(10,2),
  "geschossMin" INTEGER,
  "geschossMax" INTEGER,
  PRIMARY KEY ("gid"),
  CONSTRAINT "fk_BP_BauLinie_parent"
    FOREIGN KEY ("gid")
    REFERENCES "BP_Basisobjekte"."BP_Objekt" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("BP_Basisobjekte"."BP_Linienobjekt");

GRANT SELECT ON TABLE "BP_Bebauung"."BP_BauLinie" TO xp_gast;
GRANT ALL ON TABLE "BP_Bebauung"."BP_BauLinie" TO bp_user;
CREATE INDEX "BP_BauLinie_gidx" ON "BP_Bebauung"."BP_BauLinie" using gist ("position");
COMMENT ON TABLE "BP_Bebauung"."BP_BauLinie" IS 'Festsetzung einer Baulinie (§9 Abs. 1 Nr. 2 BauGB, §22 und 23 BauNVO). Über die Attribute geschossMin und geschossMax kann die Festsetzung auf einen Bereich von Geschossen beschränkt werden. Wenn eine Einschränkung der Festsetzung durch expliziter Höhenangaben erfolgen soll, ist dazu die Oberklassen-Relation hoehenangabe auf den komplexen Datentyp XP_Hoehenangabe zu verwenden. Durch die Digitalisierungsreihenfolge der Linienstützpunkte muss sichergestellt sein, dass die überbaute Fläche (BP_UeberbaubareGrundstuecksFlaeche) relativ zur Laufrichtung auf der linken Seite liegt.';
COMMENT ON COLUMN "BP_Bebauung"."BP_BauLinie"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN "BP_Bebauung"."BP_BauLinie"."bautiefe" IS 'Angabe einer Bautiefe.';
COMMENT ON COLUMN "BP_Bebauung"."BP_BauLinie"."geschossMin" IS 'Gibt bei geschossweiser Festsetzung die Nummer des Geschosses an, ab den die Festsetzung gilt. Wenn das Attribut nicht belegt ist, gilt die Festsetzung für alle Geschosse bis einschl. geschossMax.';
COMMENT ON COLUMN "BP_Bebauung"."BP_BauLinie"."geschossMax" IS 'Gibt bei geschossweiser Feststzung die Nummer des Geschosses an, bis zu der die Festsetzung gilt. Wenn das Attribut nicht belegt ist, gilt die Festsetzung für alle Geschosse ab einschl. geschossMin.';
CREATE TRIGGER "change_to_BP_BauLinie" BEFORE INSERT OR UPDATE ON "BP_Bebauung"."BP_BauLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_BP_BauLinie" AFTER DELETE ON "BP_Bebauung"."BP_BauLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "BP_Bebauung"."BP_BesondererNutzungszweckFlaeche"
-- -----------------------------------------------------
CREATE TABLE  "BP_Bebauung"."BP_BesondererNutzungszweckFlaeche" (
  "gid" BIGINT NOT NULL,
  "zweckbestimmung" VARCHAR(256),
  "bauweise" INTEGER,
  "bebauungsArt" INTEGER,
  "abweichendeBauweise" INTEGER,
  PRIMARY KEY ("gid"),
  CONSTRAINT "fk_BP_BesondererNutzungszweckFlaeche_parent"
    FOREIGN KEY ("gid")
    REFERENCES "BP_Bebauung"."BP_GestaltungBaugebiet" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_BP_BesondererNutzungszweckFlaeche_BP_Bauweise1"
    FOREIGN KEY ("bauweise")
    REFERENCES "BP_Bebauung"."BP_Bauweise" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_BP_BesondererNutzungszweckFlaeche_BP_AbweichendeBauweise1"
    FOREIGN KEY ("abweichendeBauweise")
    REFERENCES "BP_Bebauung"."BP_AbweichendeBauweise" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_BP_BesondererNutzungszweckFlaeche_BP_BebauungsArt1"
    FOREIGN KEY ("bebauungsArt")
    REFERENCES "BP_Bebauung"."BP_BebauungsArt" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE)
INHERITS("BP_Basisobjekte"."BP_Flaechenobjekt");

GRANT SELECT ON TABLE "BP_Bebauung"."BP_BesondererNutzungszweckFlaeche" TO xp_gast;
GRANT ALL ON TABLE "BP_Bebauung"."BP_BesondererNutzungszweckFlaeche" TO bp_user;
CREATE INDEX "BP_BesondererNutzungszweckFlaeche_gidx" ON "BP_Bebauung"."BP_BesondererNutzungszweckFlaeche" using gist ("position");
COMMENT ON TABLE  "BP_Bebauung"."BP_BesondererNutzungszweckFlaeche" IS 'Festsetzung einer Fläche mit besonderem Nutzungszweck, der durch besondere städtebauliche Gründe erfordert wird (§9 Abs. 1 Nr. 9 BauGB.)';
COMMENT ON COLUMN "BP_Bebauung"."BP_BesondererNutzungszweckFlaeche"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN "BP_Bebauung"."BP_BesondererNutzungszweckFlaeche"."zweckbestimmung" IS 'Angabe des besonderen Nutzungszwecks';
COMMENT ON COLUMN "BP_Bebauung"."BP_BesondererNutzungszweckFlaeche"."bauweise" IS 'Festsetzung der Bauweise (§9, Abs. 1, Nr. 2 BauGB).';
COMMENT ON COLUMN "BP_Bebauung"."BP_BesondererNutzungszweckFlaeche"."bebauungsArt" IS 'Detaillierte Festsetzung der Bauweise (§9, Abs. 1, Nr. 2 BauGB).';
COMMENT ON COLUMN "BP_Bebauung"."BP_BesondererNutzungszweckFlaeche"."abweichendeBauweise" IS 'Nähere Bezeichnung einer "Abweichenden Bauweise" ("bauweise" == 3000).';
CREATE TRIGGER "change_to_BP_BesondererNutzungszweckFlaeche" BEFORE INSERT OR UPDATE ON "BP_Bebauung"."BP_BesondererNutzungszweckFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_BP_BesondererNutzungszweckFlaeche" AFTER DELETE ON "BP_Bebauung"."BP_BesondererNutzungszweckFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "BP_BesondererNutzungszweckFlaeche_Flaechenobjekt" BEFORE INSERT OR UPDATE ON "BP_Bebauung"."BP_BesondererNutzungszweckFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isFlaechenobjekt"();

-- -----------------------------------------------------
-- Table "BP_Bebauung"."BP_FirstRichtungsLinie"
-- -----------------------------------------------------
CREATE TABLE  "BP_Bebauung"."BP_FirstRichtungsLinie" (
  "gid" BIGINT NOT NULL,
  PRIMARY KEY ("gid"),
  CONSTRAINT "fk_BP_FirstRichtungsLinie_parent"
    FOREIGN KEY ("gid")
    REFERENCES "BP_Basisobjekte"."BP_Objekt" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("BP_Basisobjekte"."BP_Linienobjekt");

GRANT SELECT ON TABLE "BP_Bebauung"."BP_FirstRichtungsLinie" TO xp_gast;
GRANT ALL ON TABLE "BP_Bebauung"."BP_FirstRichtungsLinie" TO bp_user;
CREATE INDEX "BP_FirstRichtungsLinie_gidx" ON "BP_Bebauung"."BP_FirstRichtungsLinie" using gist ("position");
COMMENT ON TABLE  "BP_Bebauung"."BP_FirstRichtungsLinie" IS 'Gestaltungs-Festsetzung der Firstrichtung, beruhend auf Landesrecht, gemäß §9 Abs. 4 BauGB.';
COMMENT ON COLUMN "BP_Bebauung"."BP_FirstRichtungsLinie"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_BP_FirstRichtungsLinie" BEFORE INSERT OR UPDATE ON "BP_Bebauung"."BP_FirstRichtungsLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_BP_FirstRichtungsLinie" AFTER DELETE ON "BP_Bebauung"."BP_FirstRichtungsLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "BP_Bebauung"."BP_FoerderungsFlaeche"
-- -----------------------------------------------------
CREATE TABLE  "BP_Bebauung"."BP_FoerderungsFlaeche" (
  "gid" BIGINT NOT NULL,
  PRIMARY KEY ("gid"),
  CONSTRAINT "fk_BP_FoerderungsFlaeche_parent"
    FOREIGN KEY ("gid")
    REFERENCES "BP_Basisobjekte"."BP_Objekt" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("BP_Basisobjekte"."BP_Flaechenobjekt");

GRANT SELECT ON TABLE "BP_Bebauung"."BP_FoerderungsFlaeche" TO xp_gast;
GRANT ALL ON TABLE "BP_Bebauung"."BP_FoerderungsFlaeche" TO bp_user;
CREATE INDEX "BP_FoerderungsFlaeche_gidx" ON "BP_Bebauung"."BP_FoerderungsFlaeche" using gist ("position");
COMMENT ON TABLE  "BP_Bebauung"."BP_FoerderungsFlaeche" IS 'Fläche, auf der ganz oder teilweise nur Wohngebäude, die mit Mitteln der sozialen Wohnraumförderung gefördert werden könnten, errichtet werden dürfen (§9, Abs. 1, Nr. 7 BauGB).';
COMMENT ON COLUMN "BP_Bebauung"."BP_FoerderungsFlaeche"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_BP_FoerderungsFlaeche" BEFORE INSERT OR UPDATE ON "BP_Bebauung"."BP_FoerderungsFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_BP_FoerderungsFlaeche" AFTER DELETE ON "BP_Bebauung"."BP_FoerderungsFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "ueberlagerung_BP_FoerderungsFlaeche" BEFORE INSERT OR UPDATE ON "BP_Bebauung"."BP_FoerderungsFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isUeberlagerungsobjekt"();

-- -----------------------------------------------------
-- Table "BP_Bebauung"."BP_GebaeudeFlaeche"
-- -----------------------------------------------------
CREATE TABLE  "BP_Bebauung"."BP_GebaeudeFlaeche" (
  "gid" BIGINT NOT NULL,
  PRIMARY KEY ("gid"),
  CONSTRAINT "fk_BP_GebaeudeFlaeche_parent"
    FOREIGN KEY ("gid")
    REFERENCES "BP_Basisobjekte"."BP_Objekt" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("BP_Basisobjekte"."BP_Flaechenobjekt");

GRANT SELECT ON TABLE "BP_Bebauung"."BP_GebaeudeFlaeche" TO xp_gast;
GRANT ALL ON TABLE "BP_Bebauung"."BP_GebaeudeFlaeche" TO bp_user;
CREATE INDEX "BP_GebaeudeFlaeche_gidx" ON "BP_Bebauung"."BP_GebaeudeFlaeche" using gist ("position");
COMMENT ON TABLE  "BP_Bebauung"."BP_GebaeudeFlaeche" IS 'Grundrissfläche eines existierenden Gebäudes';
COMMENT ON COLUMN "BP_Bebauung"."BP_GebaeudeFlaeche"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_BP_GebaeudeFlaeche" BEFORE INSERT OR UPDATE ON "BP_Bebauung"."BP_GebaeudeFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_BP_GebaeudeFlaeche" AFTER DELETE ON "BP_Bebauung"."BP_GebaeudeFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "ueberlagerung_BP_GebaeudeFlaeche" BEFORE INSERT OR UPDATE ON "BP_Bebauung"."BP_GebaeudeFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isUeberlagerungsobjekt"();

-- -----------------------------------------------------
-- Table "BP_Bebauung"."BP_GemeinschaftsanlagenFlaeche"
-- -----------------------------------------------------
CREATE TABLE  "BP_Bebauung"."BP_GemeinschaftsanlagenFlaeche" (
  "gid" BIGINT NOT NULL,
  "Zmax" INTEGER,
  PRIMARY KEY ("gid"),
  CONSTRAINT "fk_BP_GemeinschaftsanlagenFlaeche_parent"
    FOREIGN KEY ("gid")
    REFERENCES "BP_Basisobjekte"."BP_Objekt" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("BP_Basisobjekte"."BP_Flaechenobjekt");

GRANT SELECT ON TABLE "BP_Bebauung"."BP_GemeinschaftsanlagenFlaeche" TO xp_gast;
GRANT ALL ON TABLE "BP_Bebauung"."BP_GemeinschaftsanlagenFlaeche" TO bp_user;
CREATE INDEX "BP_GemeinschaftsanlagenFlaeche_gidx" ON "BP_Bebauung"."BP_GemeinschaftsanlagenFlaeche" using gist ("position");
COMMENT ON TABLE  "BP_Bebauung"."BP_GemeinschaftsanlagenFlaeche" IS 'Fläche für Gemeinschaftsanlagen für bestimmte räumliche Bereiche wie Kinderspielplätze, Freizeiteinrichtungen, Stellplätze und Garagen (§9 Abs. 22 BauGB)';
COMMENT ON COLUMN "BP_Bebauung"."BP_GemeinschaftsanlagenFlaeche"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN "BP_Bebauung"."BP_GemeinschaftsanlagenFlaeche"."Zmax" IS 'Maximale Anzahl von Garagen-Geschossen';
CREATE TRIGGER "change_to_BP_GemeinschaftsanlagenFlaeche" BEFORE INSERT OR UPDATE ON "BP_Bebauung"."BP_GemeinschaftsanlagenFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_BP_GemeinschaftsanlagenFlaeche" AFTER DELETE ON "BP_Bebauung"."BP_GemeinschaftsanlagenFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "ueberlagerung_BP_GemeinschaftsanlagenFlaeche" BEFORE INSERT OR UPDATE ON "BP_Bebauung"."BP_GemeinschaftsanlagenFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isUeberlagerungsobjekt"();

-- -----------------------------------------------------
-- Table "BP_Bebauung"."BP_ZweckbestimmungGemeinschaftsanlagen"
-- -----------------------------------------------------
CREATE TABLE  "BP_Bebauung"."BP_ZweckbestimmungGemeinschaftsanlagen" (
  "Code" INTEGER NOT NULL,
  "Bezeichner" VARCHAR(64) NOT NULL,
  PRIMARY KEY ("Code"));
GRANT SELECT ON "BP_Bebauung"."BP_ZweckbestimmungGemeinschaftsanlagen" TO xp_gast;

-- -----------------------------------------------------
-- Table "BP_Bebauung"."BP_GemeinschaftsanlagenFlaeche_zweckbestimmung"
-- -----------------------------------------------------
CREATE TABLE  "BP_Bebauung"."BP_GemeinschaftsanlagenFlaeche_zweckbestimmung" (
  "BP_GemeinschaftsanlagenFlaeche_gid" BIGINT NOT NULL,
  "zweckbestimmung" INTEGER NOT NULL,
  PRIMARY KEY ("BP_GemeinschaftsanlagenFlaeche_gid", "zweckbestimmung"),
  CONSTRAINT "fk_BP_GemeinschaftsanlagenFlaeche_zweckbestimmung1"
    FOREIGN KEY ("BP_GemeinschaftsanlagenFlaeche_gid")
    REFERENCES "BP_Bebauung"."BP_GemeinschaftsanlagenFlaeche" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_BP_GemeinschaftsanlagenFlaeche_zweckbestimmung2"
    FOREIGN KEY ("zweckbestimmung")
    REFERENCES "BP_Bebauung"."BP_ZweckbestimmungGemeinschaftsanlagen" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE);

CREATE INDEX "idx_fk_BP_GemeinschaftsanlagenFlaeche_zweckbestimmung1_idx" ON "BP_Bebauung"."BP_GemeinschaftsanlagenFlaeche_zweckbestimmung" ("zweckbestimmung");
CREATE INDEX "idx_fk_BP_GemeinschaftsanlagenFlaeche_zweckbestimmung2_idx" ON "BP_Bebauung"."BP_GemeinschaftsanlagenFlaeche_zweckbestimmung" ("BP_GemeinschaftsanlagenFlaeche_gid");
GRANT SELECT ON TABLE "BP_Bebauung"."BP_GemeinschaftsanlagenFlaeche_zweckbestimmung" TO xp_gast;
GRANT ALL ON TABLE "BP_Bebauung"."BP_GemeinschaftsanlagenFlaeche_zweckbestimmung" TO bp_user;
COMMENT ON TABLE  "BP_Bebauung"."BP_GemeinschaftsanlagenFlaeche_zweckbestimmung" IS 'Zweckbestimmung der Fläche';

-- -----------------------------------------------------
-- Table "BP_Bebauung"."BP_DetailZweckbestGemeinschaftsanlagen"
-- -----------------------------------------------------
CREATE TABLE  "BP_Bebauung"."BP_DetailZweckbestGemeinschaftsanlagen" (
  "Code" INTEGER NOT NULL,
  "Bezeichner" VARCHAR(64) NOT NULL,
  PRIMARY KEY ("Code"));

GRANT SELECT ON TABLE "BP_Bebauung"."BP_DetailZweckbestGemeinschaftsanlagen" TO xp_gast;
GRANT ALL ON "BP_Bebauung"."BP_DetailZweckbestGemeinschaftsanlagen" TO bp_user;
CREATE TRIGGER "ins_upd_BP_DetailZweckbestGemeinschaftsanlagen" BEFORE INSERT OR UPDATE ON "BP_Bebauung"."BP_DetailZweckbestGemeinschaftsanlagen" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isCodeList"();

-- -----------------------------------------------------
-- Table "BP_Bebauung"."BP_GemeinschaftsanlagenFlaeche_detaillierteZweckbestimmung"
-- -----------------------------------------------------
CREATE TABLE  "BP_Bebauung"."BP_GemeinschaftsanlagenFlaeche_detaillierteZweckbestimmung" (
  "BP_GemeinschaftsanlagenFlaeche_gid" BIGINT NOT NULL,
  "detaillierteZweckbestimmung" INTEGER NOT NULL,
  PRIMARY KEY ("BP_GemeinschaftsanlagenFlaeche_gid", "detaillierteZweckbestimmung"),
  CONSTRAINT "fk_BP_GemeinanlFlaeche_detaillierteZweckbest1"
    FOREIGN KEY ("BP_GemeinschaftsanlagenFlaeche_gid")
    REFERENCES "BP_Bebauung"."BP_GemeinschaftsanlagenFlaeche" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_BP_GemeinanlFlaeche_detaillierteZweckbest2"
    FOREIGN KEY ("detaillierteZweckbestimmung")
    REFERENCES "BP_Bebauung"."BP_DetailZweckbestGemeinschaftsanlagen" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE);

CREATE INDEX "idx_fk_BP_GemeinanlFlaeche_detaillierteZweckbest1" ON "BP_Bebauung"."BP_GemeinschaftsanlagenFlaeche_detaillierteZweckbestimmung" ("detaillierteZweckbestimmung");
CREATE INDEX "idx_fk_BP_GemeinanlFlaeche_detaillierteZweckbest2" ON "BP_Bebauung"."BP_GemeinschaftsanlagenFlaeche_detaillierteZweckbestimmung" ("BP_GemeinschaftsanlagenFlaeche_gid");
GRANT SELECT ON TABLE "BP_Bebauung"."BP_GemeinschaftsanlagenFlaeche_detaillierteZweckbestimmung" TO xp_gast;
GRANT ALL ON TABLE "BP_Bebauung"."BP_GemeinschaftsanlagenFlaeche_detaillierteZweckbestimmung" TO bp_user;
COMMENT ON TABLE  "BP_Bebauung"."BP_GemeinschaftsanlagenFlaeche_detaillierteZweckbestimmung" IS 'Über eine CodeList definierte zusätzliche Zweckbestimmung.';

-- -----------------------------------------------------
-- Table "BP_Bebauung"."BP_GemeinschaftsanlagenFlaeche_eigentuemer"
-- -----------------------------------------------------
CREATE TABLE  "BP_Bebauung"."BP_GemeinschaftsanlagenFlaeche_eigentuemer" (
  "BP_GemeinschaftsanlagenFlaeche_gid" BIGINT NOT NULL,
  "eigentuemer" BIGINT NOT NULL,
  PRIMARY KEY ("BP_GemeinschaftsanlagenFlaeche_gid", "eigentuemer"),
  CONSTRAINT "fk_BP_GemeinschaftsanlagenFlaeche_eigentuemer1"
    FOREIGN KEY ("BP_GemeinschaftsanlagenFlaeche_gid")
    REFERENCES "BP_Bebauung"."BP_GemeinschaftsanlagenFlaeche" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_BP_GemeinschaftsanlagenFlaeche_eigentuemer2"
    FOREIGN KEY ("eigentuemer")
    REFERENCES "BP_Bebauung"."BP_BaugebietsTeilFlaeche" ("gid")
    ON DELETE NO ACTION
    ON UPDATE CASCADE);

CREATE INDEX "idx_fk_BP_GemeinschaftsanlagenFlaeche_eigentuemer1_idx" ON "BP_Bebauung"."BP_GemeinschaftsanlagenFlaeche_eigentuemer" ("eigentuemer");
CREATE INDEX "idx_fk_BP_GemeinschaftsanlagenFlaeche_eigentuemer2_idx" ON "BP_Bebauung"."BP_GemeinschaftsanlagenFlaeche_eigentuemer" ("BP_GemeinschaftsanlagenFlaeche_gid");
GRANT SELECT ON TABLE "BP_Bebauung"."BP_GemeinschaftsanlagenFlaeche_eigentuemer" TO xp_gast;
GRANT ALL ON TABLE "BP_Bebauung"."BP_GemeinschaftsanlagenFlaeche_eigentuemer" TO bp_user;
COMMENT ON TABLE  "BP_Bebauung"."BP_GemeinschaftsanlagenFlaeche_eigentuemer" IS '';

-- -----------------------------------------------------
-- Table "BP_Bebauung"."BP_GemeinschaftsanlagenZuordnung"
-- -----------------------------------------------------
CREATE TABLE  "BP_Bebauung"."BP_GemeinschaftsanlagenZuordnung" (
  "gid" BIGINT NOT NULL,
  PRIMARY KEY ("gid"),
  CONSTRAINT "fk_BP_GemeinschaftsanlagenZuordnung_parent"
    FOREIGN KEY ("gid")
    REFERENCES "BP_Basisobjekte"."BP_Objekt" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE);

GRANT SELECT ON TABLE "BP_Bebauung"."BP_GemeinschaftsanlagenZuordnung" TO xp_gast;
GRANT ALL ON TABLE "BP_Bebauung"."BP_GemeinschaftsanlagenZuordnung" TO bp_user;
COMMENT ON TABLE  "BP_Bebauung"."BP_GemeinschaftsanlagenZuordnung" IS 'Zuordnung von Gemeinschaftsanlagen zu Grundstücken.';
COMMENT ON COLUMN "BP_Bebauung"."BP_GemeinschaftsanlagenZuordnung"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_BP_GemeinschaftsanlagenZuordnung" BEFORE INSERT OR UPDATE ON "BP_Bebauung"."BP_GemeinschaftsanlagenZuordnung" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_BP_GemeinschaftsanlagenZuordnung" AFTER DELETE ON "BP_Bebauung"."BP_GemeinschaftsanlagenZuordnung" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "BP_Bebauung"."BP_GemeinschaftsanlagenZuordnung_zuordnung"
-- -----------------------------------------------------
CREATE TABLE  "BP_Bebauung"."BP_GemeinschaftsanlagenZuordnung_zuordnung" (
  "BP_GemeinschaftsanlagenZuordnung_gid" BIGINT NOT NULL,
  "zuordnung" BIGINT NOT NULL,
  PRIMARY KEY ("BP_GemeinschaftsanlagenZuordnung_gid", "zuordnung"),
  CONSTRAINT "fk_BP_GemeinschaftsanlagenZuordnung_zuordnung1"
    FOREIGN KEY ("BP_GemeinschaftsanlagenZuordnung_gid")
    REFERENCES "BP_Bebauung"."BP_GemeinschaftsanlagenZuordnung" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_BP_GemeinschaftsanlagenZuordnung_zuordnung2"
    FOREIGN KEY ("zuordnung")
    REFERENCES "BP_Bebauung"."BP_GemeinschaftsanlagenFlaeche" ("gid")
    ON DELETE NO ACTION
    ON UPDATE CASCADE);

CREATE INDEX "idx_fk_BP_GemeinschaftsanlagenZuordnung_zuordnung1" ON "BP_Bebauung"."BP_GemeinschaftsanlagenZuordnung_zuordnung" ("zuordnung");
CREATE INDEX "idx_fk_BP_GemeinschaftsanlagenZuordnung_zuordnung2" ON "BP_Bebauung"."BP_GemeinschaftsanlagenZuordnung_zuordnung" ("BP_GemeinschaftsanlagenZuordnung_gid");
GRANT SELECT ON TABLE "BP_Bebauung"."BP_GemeinschaftsanlagenZuordnung_zuordnung" TO xp_gast;
GRANT ALL ON TABLE "BP_Bebauung"."BP_GemeinschaftsanlagenZuordnung_zuordnung" TO bp_user;
COMMENT ON TABLE  "BP_Bebauung"."BP_GemeinschaftsanlagenZuordnung_zuordnung" IS 'Relation auf die zugeordneten Gemeinschaftsanlagen-Flächen, die außerhalb des Baugebiets liegen.';

-- -----------------------------------------------------
-- Table "BP_Bebauung"."BP_GemeinschaftsanlagenZuordnungFlaeche"
-- -----------------------------------------------------
CREATE TABLE  "BP_Bebauung"."BP_GemeinschaftsanlagenZuordnungFlaeche" (
  "gid" BIGINT NOT NULL,
  PRIMARY KEY ("gid"),
  CONSTRAINT "fk_BP_GemeinschaftsanlagenZuordnungFlaeche_parent"
    FOREIGN KEY ("gid")
    REFERENCES "BP_Bebauung"."BP_GemeinschaftsanlagenZuordnung" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("BP_Basisobjekte"."BP_Flaechenobjekt");

GRANT SELECT ON TABLE "BP_Bebauung"."BP_GemeinschaftsanlagenZuordnungFlaeche" TO xp_gast;
GRANT ALL ON TABLE "BP_Bebauung"."BP_GemeinschaftsanlagenZuordnungFlaeche" TO bp_user;
CREATE INDEX "BP_GemeinschaftsanlagenZuordnungFlaeche_gidx" ON "BP_Bebauung"."BP_GemeinschaftsanlagenZuordnungFlaeche" using gist ("position");
COMMENT ON COLUMN "BP_Bebauung"."BP_GemeinschaftsanlagenZuordnungFlaeche"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_BP_GemeinschaftsanlagenZuordnungFlaeche" BEFORE INSERT OR UPDATE ON "BP_Bebauung"."BP_GemeinschaftsanlagenZuordnungFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_BP_GemeinschaftsanlagenZuordnungFlaeche" AFTER DELETE ON "BP_Bebauung"."BP_GemeinschaftsanlagenZuordnungFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "BP_GemeinschaftsanlagenZuordnungFlaeche_Flaechenobjekt" BEFORE INSERT OR UPDATE ON "BP_Bebauung"."BP_GemeinschaftsanlagenZuordnungFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isFlaechenobjekt"();


-- -----------------------------------------------------
-- Table "BP_Bebauung"."BP_GemeinschaftsanlagenZuordnungLinie"
-- -----------------------------------------------------
CREATE TABLE  "BP_Bebauung"."BP_GemeinschaftsanlagenZuordnungLinie" (
  "gid" BIGINT NOT NULL,
  PRIMARY KEY ("gid"),
  CONSTRAINT "fk_BP_GemeinschaftsanlagenZuordnungLinie_parent"
    FOREIGN KEY ("gid")
    REFERENCES "BP_Bebauung"."BP_GemeinschaftsanlagenZuordnung" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("BP_Basisobjekte"."BP_Linienobjekt");

GRANT SELECT ON TABLE "BP_Bebauung"."BP_GemeinschaftsanlagenZuordnungLinie" TO xp_gast;
GRANT ALL ON TABLE "BP_Bebauung"."BP_GemeinschaftsanlagenZuordnungLinie" TO bp_user;
CREATE INDEX "BP_GemeinschaftsanlagenZuordnungLinie_gidx" ON "BP_Bebauung"."BP_GemeinschaftsanlagenZuordnungLinie" using gist ("position");
COMMENT ON COLUMN "BP_Bebauung"."BP_GemeinschaftsanlagenZuordnungLinie"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_BP_GemeinschaftsanlagenZuordnungLinie" BEFORE INSERT OR UPDATE ON "BP_Bebauung"."BP_GemeinschaftsanlagenZuordnungLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_BP_GemeinschaftsanlagenZuordnungLinie" AFTER DELETE ON "BP_Bebauung"."BP_GemeinschaftsanlagenZuordnungLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "BP_Bebauung"."BP_GemeinschaftsanlagenZuordnungPunkt"
-- -----------------------------------------------------
CREATE TABLE  "BP_Bebauung"."BP_GemeinschaftsanlagenZuordnungPunkt" (
  "gid" BIGINT NOT NULL,
  PRIMARY KEY ("gid"),
  CONSTRAINT "fk_BP_GemeinschaftsanlagenZuordnungPunkt_parent"
    FOREIGN KEY ("gid")
    REFERENCES "BP_Bebauung"."BP_GemeinschaftsanlagenZuordnung" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("BP_Basisobjekte"."BP_Punktobjekt");

GRANT SELECT ON TABLE "BP_Bebauung"."BP_GemeinschaftsanlagenZuordnungPunkt" TO xp_gast;
GRANT ALL ON TABLE "BP_Bebauung"."BP_GemeinschaftsanlagenZuordnungPunkt" TO bp_user;
CREATE INDEX "BP_GemeinschaftsanlagenZuordnungPunkt_gidx" ON "BP_Bebauung"."BP_GemeinschaftsanlagenZuordnungPunkt" using gist ("position");
COMMENT ON COLUMN "BP_Bebauung"."BP_GemeinschaftsanlagenZuordnungPunkt"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_BP_GemeinschaftsanlagenZuordnungPunkt" BEFORE INSERT OR UPDATE ON "BP_Bebauung"."BP_GemeinschaftsanlagenZuordnungPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_BP_GemeinschaftsanlagenZuordnungPunkt" AFTER DELETE ON "BP_Bebauung"."BP_GemeinschaftsanlagenZuordnungPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "BP_Bebauung"."BP_NebenanlangenAusschlussTyp"
-- -----------------------------------------------------
CREATE TABLE  "BP_Bebauung"."BP_NebenanlangenAusschlussTyp" (
  "Code" INTEGER NOT NULL,
  "Bezeichner" VARCHAR(64) NOT NULL,
  PRIMARY KEY ("Code"));

GRANT SELECT ON TABLE "BP_Bebauung"."BP_NebenanlangenAusschlussTyp" TO xp_gast;

-- -----------------------------------------------------
-- Table "BP_Bebauung"."BP_NebenanlagenAusschlussFlaeche"
-- -----------------------------------------------------
CREATE TABLE  "BP_Bebauung"."BP_NebenanlagenAusschlussFlaeche" (
  "gid" BIGINT NOT NULL,
  "typ" INTEGER,
  PRIMARY KEY ("gid"),
  CONSTRAINT "fk_BP_NebenanlagenAusschlussFlaeche_parent"
    FOREIGN KEY ("gid")
    REFERENCES "BP_Basisobjekte"."BP_Objekt" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_BP_NebenanlagenAusschlussFlaeche_typ"
    FOREIGN KEY ("typ")
    REFERENCES "BP_Bebauung"."BP_NebenanlangenAusschlussTyp" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE)
INHERITS("BP_Basisobjekte"."BP_Flaechenobjekt");

GRANT SELECT ON TABLE "BP_Bebauung"."BP_NebenanlagenAusschlussFlaeche" TO xp_gast;
GRANT ALL ON TABLE "BP_Bebauung"."BP_NebenanlagenAusschlussFlaeche" TO bp_user;
CREATE INDEX "BP_NebenanlagenAusschlussFlaeche_gidx" ON "BP_Bebauung"."BP_NebenanlagenAusschlussFlaeche" using gist ("position");
COMMENT ON TABLE  "BP_Bebauung"."BP_NebenanlagenAusschlussFlaeche" IS 'Festsetzung einer Fläche für die Einschränkung oder den Ausschluss von Nebenanlagen.';
COMMENT ON COLUMN "BP_Bebauung"."BP_NebenanlagenAusschlussFlaeche"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN "BP_Bebauung"."BP_NebenanlagenAusschlussFlaeche"."typ" IS 'Art des Ausschlusses.';
CREATE TRIGGER "change_to_BP_NebenanlagenAusschlussFlaeche" BEFORE INSERT OR UPDATE ON "BP_Bebauung"."BP_NebenanlagenAusschlussFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_BP_NebenanlagenAusschlussFlaeche" AFTER DELETE ON "BP_Bebauung"."BP_NebenanlagenAusschlussFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "ueberlagerung_BP_NebenanlagenAusschlussFlaeche" BEFORE INSERT OR UPDATE ON "BP_Bebauung"."BP_NebenanlagenAusschlussFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isUeberlagerungsobjekt"();

-- -----------------------------------------------------
-- Table "BP_Bebauung"."BP_NebenanlagenAusschlussFlaeche_abweichungText"
-- -----------------------------------------------------
CREATE TABLE  "BP_Bebauung"."BP_NebenanlagenAusschlussFlaeche_abweichungText" (
  "BP_NebenanlagenAusschlussFlaeche_gid" BIGINT NOT NULL,
  "abweichungText" INTEGER NOT NULL,
  PRIMARY KEY ("BP_NebenanlagenAusschlussFlaeche_gid", "abweichungText"),
  CONSTRAINT "fk_BP_NebenanlagenAusschlussFlaeche_abweichungText1"
    FOREIGN KEY ("BP_NebenanlagenAusschlussFlaeche_gid")
    REFERENCES "BP_Bebauung"."BP_NebenanlagenAusschlussFlaeche" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_BP_NebenanlagenAusschlussFlaeche_abweichungText2"
    FOREIGN KEY ("abweichungText")
    REFERENCES "BP_Basisobjekte"."BP_TextAbschnitt" ("id")
    ON DELETE NO ACTION
    ON UPDATE CASCADE);

CREATE INDEX "idx_fk_BP_NebenanlagenAusschlussFlaeche_abweichungText1_idx" ON "BP_Bebauung"."BP_NebenanlagenAusschlussFlaeche_abweichungText" ("abweichungText");
CREATE INDEX "idx_fk_BP_NebenanlagenAusschlussFlaeche_abweichungText2_idx" ON "BP_Bebauung"."BP_NebenanlagenAusschlussFlaeche_abweichungText" ("BP_NebenanlagenAusschlussFlaeche_gid");
GRANT SELECT ON TABLE "BP_Bebauung"."BP_NebenanlagenAusschlussFlaeche_abweichungText" TO xp_gast;
GRANT ALL ON TABLE "BP_Bebauung"."BP_NebenanlagenAusschlussFlaeche_abweichungText" TO bp_user;
COMMENT ON TABLE  "BP_Bebauung"."BP_NebenanlagenAusschlussFlaeche_abweichungText" IS '';

-- -----------------------------------------------------
-- Table "BP_Bebauung"."BP_NebenanlagenFlaeche"
-- -----------------------------------------------------
CREATE TABLE  "BP_Bebauung"."BP_NebenanlagenFlaeche" (
  "gid" BIGINT NOT NULL,
  "Zmax" INTEGER,
  PRIMARY KEY ("gid"),
  CONSTRAINT "fk_BP_NebenanlagenFlaeche_parent"
    FOREIGN KEY ("gid")
    REFERENCES "BP_Basisobjekte"."BP_Objekt" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("BP_Basisobjekte"."BP_Flaechenobjekt");

GRANT SELECT ON TABLE "BP_Bebauung"."BP_NebenanlagenFlaeche" TO xp_gast;
GRANT ALL ON TABLE "BP_Bebauung"."BP_NebenanlagenFlaeche" TO bp_user;
CREATE INDEX "BP_NebenanlagenFlaeche_gidx" ON "BP_Bebauung"."BP_NebenanlagenFlaeche" using gist ("position");
COMMENT ON TABLE  "BP_Bebauung"."BP_NebenanlagenFlaeche" IS 'Fläche für Nebenanlagen, die auf Grund anderer Vorschriften für die Nutzung von Grundstücken erforderlich sind, wie Spiel-, Freizeit- und Erholungsflächen sowie die Fläche für Stellplätze und Garagen mit ihren Einfahrten (§9 Abs. 4 BauGB)';
COMMENT ON COLUMN "BP_Bebauung"."BP_NebenanlagenFlaeche"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN "BP_Bebauung"."BP_NebenanlagenFlaeche"."Zmax" IS 'Maximale Anzahl der Garagengeschosse.';
CREATE TRIGGER "change_to_BP_NebenanlagenFlaeche" BEFORE INSERT OR UPDATE ON "BP_Bebauung"."BP_NebenanlagenFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_BP_NebenanlagenFlaeche" AFTER DELETE ON "BP_Bebauung"."BP_NebenanlagenFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "ueberlagerung_BP_NebenanlagenFlaeche" BEFORE INSERT OR UPDATE ON "BP_Bebauung"."BP_NebenanlagenFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isUeberlagerungsobjekt"();

-- -----------------------------------------------------
-- Table "BP_Bebauung"."BP_ZweckbestimmungNebenanlagen"
-- -----------------------------------------------------
CREATE TABLE  "BP_Bebauung"."BP_ZweckbestimmungNebenanlagen" (
  "Code" INTEGER NOT NULL,
  "Bezeichner" VARCHAR(64) NOT NULL,
  PRIMARY KEY ("Code"));

GRANT SELECT ON TABLE "BP_Bebauung"."BP_ZweckbestimmungNebenanlagen" TO xp_gast;

-- -----------------------------------------------------
-- Table "BP_Bebauung"."BP_DetailZweckbestNebenanlagen"
-- -----------------------------------------------------
CREATE TABLE  "BP_Bebauung"."BP_DetailZweckbestNebenanlagen" (
  "Code" INTEGER NOT NULL,
  "Bezeichner" VARCHAR(64) NOT NULL,
  PRIMARY KEY ("Code"));

GRANT SELECT ON TABLE "BP_Bebauung"."BP_DetailZweckbestNebenanlagen" TO xp_gast;
GRANT ALL ON "BP_Bebauung"."BP_DetailZweckbestNebenanlagen" TO bp_user;
CREATE TRIGGER "ins_upd_BP_DetailZweckbestNebenanlagen" BEFORE INSERT OR UPDATE ON "BP_Bebauung"."BP_DetailZweckbestNebenanlagen" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isCodeList"();

-- -----------------------------------------------------
-- Table "BP_Bebauung"."BP_NebenanlagenFlaeche_zweckbestimmung"
-- -----------------------------------------------------
CREATE TABLE  "BP_Bebauung"."BP_NebenanlagenFlaeche_zweckbestimmung" (
  "BP_NebenanlagenFlaeche_gid" BIGINT NOT NULL,
  "zweckbestimmung" INTEGER NOT NULL,
  PRIMARY KEY ("BP_NebenanlagenFlaeche_gid", "zweckbestimmung"),
  CONSTRAINT "fk_BP_NebenanlagenFlaeche_zweckbestimmung1"
    FOREIGN KEY ("BP_NebenanlagenFlaeche_gid")
    REFERENCES "BP_Bebauung"."BP_NebenanlagenFlaeche" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_BP_NebenanlagenFlaeche_zweckbestimmung2"
    FOREIGN KEY ("zweckbestimmung")
    REFERENCES "BP_Bebauung"."BP_ZweckbestimmungNebenanlagen" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE);

CREATE INDEX "idx_fk_BP_NebenanlagenFlaeche_zweckbestimmung1_idx" ON "BP_Bebauung"."BP_NebenanlagenFlaeche_zweckbestimmung" ("zweckbestimmung");
CREATE INDEX "idx_fk_BP_NebenanlagenFlaeche_zweckbestimmung2_idx" ON "BP_Bebauung"."BP_NebenanlagenFlaeche_zweckbestimmung" ("BP_NebenanlagenFlaeche_gid");
GRANT SELECT ON TABLE "BP_Bebauung"."BP_NebenanlagenFlaeche_zweckbestimmung" TO xp_gast;
GRANT ALL ON TABLE "BP_Bebauung"."BP_NebenanlagenFlaeche_zweckbestimmung" TO bp_user;
COMMENT ON TABLE  "BP_Bebauung"."BP_NebenanlagenFlaeche_zweckbestimmung" IS 'Zweckbestimmungen der Nebenanlagen-Fläche';

-- -----------------------------------------------------
-- Table "BP_Bebauung"."BP_NebenanlagenFlaeche_detaillierteZweckbestimmung"
-- -----------------------------------------------------
CREATE TABLE  "BP_Bebauung"."BP_NebenanlagenFlaeche_detaillierteZweckbestimmung" (
  "BP_NebenanlagenFlaeche_gid" BIGINT NOT NULL,
  "detaillierteZweckbestimmung" INTEGER NOT NULL,
  PRIMARY KEY ("BP_NebenanlagenFlaeche_gid", "detaillierteZweckbestimmung"),
  CONSTRAINT "fk_BP_NebenanlagenFlaeche_detaillierteZweckbestimmung1"
    FOREIGN KEY ("BP_NebenanlagenFlaeche_gid")
    REFERENCES "BP_Bebauung"."BP_NebenanlagenFlaeche" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_BP_NebenanlagenFlaeche_detaillierteZweckbestimmung2"
    FOREIGN KEY ("detaillierteZweckbestimmung")
    REFERENCES "BP_Bebauung"."BP_DetailZweckbestNebenanlagen" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE);

CREATE INDEX "idx_fk_BP_NebenanlagenFlaeche_detaillierteZweckbestimmung1_idx" ON "BP_Bebauung"."BP_NebenanlagenFlaeche_detaillierteZweckbestimmung" ("detaillierteZweckbestimmung");
CREATE INDEX "idx_fk_BP_NebenanlagenFlaeche_detaillierteZweckbestimmung2_idx" ON "BP_Bebauung"."BP_NebenanlagenFlaeche_detaillierteZweckbestimmung" ("BP_NebenanlagenFlaeche_gid");
GRANT SELECT ON TABLE "BP_Bebauung"."BP_NebenanlagenFlaeche_detaillierteZweckbestimmung" TO xp_gast;
GRANT ALL ON TABLE "BP_Bebauung"."BP_NebenanlagenFlaeche_detaillierteZweckbestimmung" TO bp_user;
COMMENT ON TABLE  "BP_Bebauung"."BP_NebenanlagenFlaeche_detaillierteZweckbestimmung" IS 'Über eine CodeList definierte zusätzliche Zweckbestimmung.';

-- -----------------------------------------------------
-- Table "BP_Bebauung"."BP_PersGruppenBestimmteFlaeche"
-- -----------------------------------------------------
CREATE TABLE  "BP_Bebauung"."BP_PersGruppenBestimmteFlaeche" (
  "gid" BIGINT NOT NULL,
  PRIMARY KEY ("gid"),
  CONSTRAINT "fk_BP_PersGruppenBestimmteFlaeche_parent"
    FOREIGN KEY ("gid")
    REFERENCES "BP_Basisobjekte"."BP_Objekt" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("BP_Basisobjekte"."BP_Flaechenobjekt");

GRANT SELECT ON TABLE "BP_Bebauung"."BP_PersGruppenBestimmteFlaeche" TO xp_gast;
GRANT ALL ON TABLE "BP_Bebauung"."BP_PersGruppenBestimmteFlaeche" TO bp_user;
CREATE INDEX "BP_PersGruppenBestimmteFlaeche_gidx" ON "BP_Bebauung"."BP_PersGruppenBestimmteFlaeche" using gist ("position");
COMMENT ON TABLE  "BP_Bebauung"."BP_PersGruppenBestimmteFlaeche" IS 'Fläche, auf denen ganz oder teilweise nur Wohngebäude errichtet werden dürfen, die für Personengruppen mit besonderem Wohnbedarf bestimmt sind (§9, Abs. 1, Nr. 8 BauGB)';
COMMENT ON COLUMN "BP_Bebauung"."BP_PersGruppenBestimmteFlaeche"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_BP_PersGruppenBestimmteFlaeche" BEFORE INSERT OR UPDATE ON "BP_Bebauung"."BP_PersGruppenBestimmteFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_BP_PersGruppenBestimmteFlaeche" AFTER DELETE ON "BP_Bebauung"."BP_PersGruppenBestimmteFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "ueberlagerung_BP_PersGruppenBestimmteFlaeche" BEFORE INSERT OR UPDATE ON "BP_Bebauung"."BP_PersGruppenBestimmteFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isUeberlagerungsobjekt"();

-- -----------------------------------------------------
-- Table "BP_Bebauung"."BP_ZulaessigkeitVergnuegungsstaetten"
-- -----------------------------------------------------
CREATE TABLE  "BP_Bebauung"."BP_ZulaessigkeitVergnuegungsstaetten" (
  "Code" INTEGER NOT NULL,
  "Bezeichner" VARCHAR(64) NOT NULL,
  PRIMARY KEY ("Code"));

GRANT SELECT ON TABLE "BP_Bebauung"."BP_ZulaessigkeitVergnuegungsstaetten" TO xp_gast;

-- -----------------------------------------------------
-- Table "BP_Bebauung"."BP_RegelungVergnuegungsstaetten"
-- -----------------------------------------------------
CREATE TABLE  "BP_Bebauung"."BP_RegelungVergnuegungsstaetten" (
  "gid" BIGINT NOT NULL,
  "zulaessigkeit" INTEGER,
  PRIMARY KEY ("gid"),
  CONSTRAINT "fk_BP_RegelungVergneugungsstaetten_parent"
    FOREIGN KEY ("gid")
    REFERENCES "BP_Basisobjekte"."BP_Objekt" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_BP_RegelungVergneugungsstaetten_zulaessigkeit"
    FOREIGN KEY ("zulaessigkeit")
    REFERENCES "BP_Bebauung"."BP_ZulaessigkeitVergnuegungsstaetten" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE)
INHERITS("BP_Basisobjekte"."BP_Flaechenobjekt");

GRANT SELECT ON TABLE "BP_Bebauung"."BP_RegelungVergnuegungsstaetten" TO xp_gast;
GRANT ALL ON TABLE "BP_Bebauung"."BP_RegelungVergnuegungsstaetten" TO bp_user;
CREATE INDEX "BP_RegelungVergnuegungsstaetten_gidx" ON "BP_Bebauung"."BP_RegelungVergnuegungsstaetten" using gist ("position");
COMMENT ON TABLE  "BP_Bebauung"."BP_RegelungVergnuegungsstaetten" IS 'Festsetzung nach §9 Abs. 2b BauGB (Zulässigkeit von Vergnügungsstätten)';
COMMENT ON COLUMN "BP_Bebauung"."BP_RegelungVergnuegungsstaetten"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN "BP_Bebauung"."BP_RegelungVergnuegungsstaetten"."zulaessigkeit" IS 'Zulässigkeit von Vergnügungsstätten.';
CREATE TRIGGER "change_to_BP_RegelungVergnuegungsstaetten" BEFORE INSERT OR UPDATE ON "BP_Bebauung"."BP_RegelungVergnuegungsstaetten" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_BP_RegelungVergnuegungsstaetten" AFTER DELETE ON "BP_Bebauung"."BP_RegelungVergnuegungsstaetten" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "ueberlagerung_BP_RegelungVergnuegungsstaetten" BEFORE INSERT OR UPDATE ON "BP_Bebauung"."BP_RegelungVergnuegungsstaetten" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isUeberlagerungsobjekt"();

-- -----------------------------------------------------
-- Table "BP_Bebauung"."BP_SpezielleBauweiseTypen"
-- -----------------------------------------------------
CREATE TABLE  "BP_Bebauung"."BP_SpezielleBauweiseTypen" (
  "Code" INTEGER NOT NULL,
  "Bezeichner" VARCHAR(64) NOT NULL,
  PRIMARY KEY ("Code"));

GRANT SELECT ON TABLE "BP_Bebauung"."BP_SpezielleBauweiseTypen" TO xp_gast;

-- -----------------------------------------------------
-- Table "BP_Bebauung"."BP_spezielleBauweiseSonstTypen"
-- -----------------------------------------------------
CREATE TABLE  "BP_Bebauung"."BP_spezielleBauweiseSonstTypen" (
  "Code" INTEGER NOT NULL,
  "Bezeichner" VARCHAR(64) NOT NULL,
  PRIMARY KEY ("Code"));

GRANT SELECT ON TABLE "BP_Bebauung"."BP_spezielleBauweiseSonstTypen" TO xp_gast;
GRANT ALL ON "BP_Bebauung"."BP_spezielleBauweiseSonstTypen" TO bp_user;
CREATE TRIGGER "ins_upd_BP_spezielleBauweiseSonstTypen" BEFORE INSERT OR UPDATE ON "BP_Bebauung"."BP_spezielleBauweiseSonstTypen" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isCodeList"();

-- -----------------------------------------------------
-- Table "BP_Bebauung"."BP_SpezielleBauweise"
-- -----------------------------------------------------
CREATE TABLE  "BP_Bebauung"."BP_SpezielleBauweise" (
  "gid" BIGINT NOT NULL,
  "typ" INTEGER,
  "sonstTyp" INTEGER,
  "Bmin" REAL,
  "Bmax" REAL,
  "Tmin" REAL,
  "Tmax" REAL,
  PRIMARY KEY ("gid"),
  CONSTRAINT "fk_BP_SpezielleBauweise_parent"
    FOREIGN KEY ("gid")
    REFERENCES "BP_Basisobjekte"."BP_Objekt" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_BP_SpezielleBauweise_typ"
    FOREIGN KEY ("typ")
    REFERENCES "BP_Bebauung"."BP_SpezielleBauweiseTypen" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_BP_SpezielleBauweise_sonstTyp"
    FOREIGN KEY ("sonstTyp")
    REFERENCES "BP_Bebauung"."BP_spezielleBauweiseSonstTypen" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE)
INHERITS("BP_Basisobjekte"."BP_Flaechenobjekt");

CREATE INDEX "idx_fk_BP_SpezielleBauweise_typ_idx" ON "BP_Bebauung"."BP_SpezielleBauweise" ("typ");
CREATE INDEX "idx_fk_BP_SpezielleBauweise_sonstTyp_idx" ON "BP_Bebauung"."BP_SpezielleBauweise" ("sonstTyp");
CREATE INDEX "BP_SpezielleBauweise_gidx" ON "BP_Bebauung"."BP_SpezielleBauweise" using gist ("position");
GRANT SELECT ON TABLE "BP_Bebauung"."BP_SpezielleBauweise" TO xp_gast;
GRANT ALL ON TABLE "BP_Bebauung"."BP_SpezielleBauweise" TO bp_user;
COMMENT ON TABLE  "BP_Bebauung"."BP_SpezielleBauweise" IS 'Festsetzung der speziellen Bauweise / baulichen Besonderheit eines Gebäudes oder Bauwerks.';
COMMENT ON COLUMN "BP_Bebauung"."BP_SpezielleBauweise"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN "BP_Bebauung"."BP_SpezielleBauweise"."typ" IS 'Typ der speziellen Bauweise.';
COMMENT ON COLUMN "BP_Bebauung"."BP_SpezielleBauweise"."sonstTyp" IS 'Über eine CodeList definierter Typ der speziellen Bauweise.';
COMMENT ON COLUMN "BP_Bebauung"."BP_SpezielleBauweise"."Bmin" IS 'Minimale Breite von Baugrundstücken.';
COMMENT ON COLUMN "BP_Bebauung"."BP_SpezielleBauweise"."Bmax" IS 'Maximale Breite von Baugrundstücken.';
COMMENT ON COLUMN "BP_Bebauung"."BP_SpezielleBauweise"."Tmin" IS 'Minimale Tiefe von Baugrundstücken.';
COMMENT ON COLUMN "BP_Bebauung"."BP_SpezielleBauweise"."Tmax" IS 'Maximale Tiefe von Baugrundstücken.';
CREATE TRIGGER "change_to_BP_SpezielleBauweise" BEFORE INSERT OR UPDATE ON "BP_Bebauung"."BP_SpezielleBauweise" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_BP_SpezielleBauweise" AFTER DELETE ON "BP_Bebauung"."BP_SpezielleBauweise" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "ueberlagerung_BP_SpezielleBauweise" BEFORE INSERT OR UPDATE ON "BP_Bebauung"."BP_SpezielleBauweise" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isUeberlagerungsobjekt"();

-- -----------------------------------------------------
-- Table "BP_Bebauung"."BP_SpezielleBauweise_wegerecht"
-- -----------------------------------------------------
CREATE TABLE "BP_Bebauung"."BP_SpezielleBauweise_wegerecht" (
  "BP_SpezielleBauweise_gid" BIGINT NOT NULL ,
  "wegerecht" BIGINT NOT NULL ,
  PRIMARY KEY ("BP_SpezielleBauweise_gid", "wegerecht"),
  CONSTRAINT "fk_BP_SpezielleBauweise_wegerecht1"
    FOREIGN KEY ("BP_SpezielleBauweise_gid" )
    REFERENCES "BP_Bebauung"."BP_SpezielleBauweise" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_BP_SpezielleBauweise_wegerecht2"
    FOREIGN KEY ("wegerecht" )
    REFERENCES "BP_Sonstiges"."BP_Wegerecht" ("gid" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
GRANT SELECT ON TABLE "BP_Bebauung"."BP_SpezielleBauweise_wegerecht" TO xp_gast;
GRANT ALL ON TABLE "BP_Bebauung"."BP_SpezielleBauweise_wegerecht" TO bp_user;
COMMENT ON TABLE "BP_Bebauung"."BP_SpezielleBauweise_wegerecht" IS 'Relation auf Angaben zu Wegerechten.';

-- -----------------------------------------------------
-- Table "BP_Bebauung"."BP_UeberbaubareGrundstuecksFlaeche"
-- -----------------------------------------------------
CREATE TABLE  "BP_Bebauung"."BP_UeberbaubareGrundstuecksFlaeche" (
  "gid" BIGINT NOT NULL,
  "geschossMin" INTEGER,
  "geschossMax" INTEGER,
  "wohnnutzungEGStrasse" INTEGER,
  "ZWohn" INTEGER,
  "GFAntWohnen" INTEGER,
  "GFWohnen" INTEGER,
  "GFAntGewerbe" INTEGER,
  "GFGewerbe" INTEGER,
  PRIMARY KEY ("gid"),
  CONSTRAINT "fk_BP_UeberbaubareGrundstuecksFlaeche_parent"
    FOREIGN KEY ("gid")
    REFERENCES "BP_Bebauung"."BP_BaugebietBauweise" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_BP_UeberbaubareGrundstuecksFlaeche_BP_Zulaessigkeit"
    FOREIGN KEY ("wohnnutzungEGStrasse")
    REFERENCES "BP_Bebauung"."BP_Zulaessigkeit" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE)
INHERITS("BP_Basisobjekte"."BP_Flaechenobjekt");

GRANT SELECT ON TABLE "BP_Bebauung"."BP_UeberbaubareGrundstuecksFlaeche" TO xp_gast;
GRANT ALL ON TABLE "BP_Bebauung"."BP_UeberbaubareGrundstuecksFlaeche" TO bp_user;
CREATE INDEX "BP_UeberbaubareGrundstuecksFlaeche_gidx" ON "BP_Bebauung"."BP_UeberbaubareGrundstuecksFlaeche" using gist ("position");
COMMENT ON TABLE  "BP_Bebauung"."BP_UeberbaubareGrundstuecksFlaeche" IS 'Festsetzung der überbaubaren Grundstücksfläche (§9, Abs. 1, Nr. 2 BauGB). Über die Attribute geschossMin und geschossMax kann die Festsetzung auf einen Bereich von Geschossen beschränkt werden. Wenn eine Einschränkung der Festsetzung durch expliziter Höhenangaben erfolgen soll, ist dazu die Oberklassen-Relation hoehenangabe auf den komplexen Datentyp XP_Hoehenangabe zu verwenden.
Die gleichzeitige Belegung desselben Attributs in BP_BaugebietsTeilFlaeche und einem überlagernden Objekt BP_UeberbaubareGrunsdstuecksFlaeche sollte verzichtet werden. Ab Version 6.0 wird dies evtl. durch eine Konformitätsregel erzwungen.';
COMMENT ON COLUMN "BP_Bebauung"."BP_UeberbaubareGrundstuecksFlaeche"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN "BP_Bebauung"."BP_UeberbaubareGrundstuecksFlaeche"."geschossMin" IS 'Gibt bei geschossweiser Festsetzung die Nummer des Geschosses an, ab den die Festsetzung gilt. Wenn das Attribut nicht belegt ist, gilt die Festsetzung für alle Geschosse bis einschl. geschossMax.';
COMMENT ON COLUMN "BP_Bebauung"."BP_UeberbaubareGrundstuecksFlaeche"."geschossMax" IS 'Gibt bei geschossweiser Feststzung die Nummer des Geschosses an, bis zu der die Festsetzung gilt. Wenn das Attribut nicht belegt ist, gilt die Festsetzung für alle Geschosse ab einschl. geschossMin.';
COMMENT ON COLUMN "BP_Bebauung"."BP_UeberbaubareGrundstuecksFlaeche"."wohnnutzungEGStrasse" IS 'Festsetzung nach §6a Abs. (4) Nr. 1 BauNVO: Für urbane Gebiete oder Teile solcher Gebiete kann festgesetzt werden, dass in Gebäuden im Erdgeschoss an der Straßenseite eine Wohnnutzung nicht oder nur ausnahmsweise zulässig ist.';
COMMENT ON COLUMN "BP_Bebauung"."BP_UeberbaubareGrundstuecksFlaeche"."ZWohn" IS 'Festsetzung nach §4a Abs. (4) Nr. 1 bzw. nach §6a Abs. (4) Nr. 2 BauNVO: Für besondere Wohngebiete und urbane Gebiete oder Teile solcher Gebiete kann festgesetzt werden, dass in Gebäuden oberhalb eines im Bebauungsplan bestimmten Geschosses nur Wohnungen zulässig sind.';
COMMENT ON COLUMN "BP_Bebauung"."BP_UeberbaubareGrundstuecksFlaeche"."GFAntWohnen" IS 'Festsetzung nach §4a Abs. (4) Nr. 2 bzw. §6a Abs. (4) Nr. 3 BauNVO: Für besondere Wohngebiete und urbane Gebiete oder Teile solcher Gebiete kann festgesetzt werden, dass in Gebäuden ein im Bebauungsplan bestimmter Anteil der zulässigen Geschossfläche für Wohnungen zu verwenden ist.';
COMMENT ON COLUMN "BP_Bebauung"."BP_UeberbaubareGrundstuecksFlaeche"."GFWohnen" IS 'Festsetzung nach §4a Abs. (4) Nr. 2 bzw. §6a Abs. (4) Nr. 3 BauNVO: Für besondere Wohngebiete und urbane Gebiete oder Teile solcher Gebiete kann festgesetzt werden, dass in Gebäuden eine im Bebauungsplan bestimmte Größe der Geschossfläche für Wohnungen zu verwenden ist.';
COMMENT ON COLUMN "BP_Bebauung"."BP_UeberbaubareGrundstuecksFlaeche"."GFAntGewerbe" IS 'Festsetzung nach §6a Abs. (4) Nr. 4 BauNVO: Für urbane Gebiete oder Teile solcher Gebiete kann festgesetzt werden, dass in Gebäuden ein im Bebauungsplan bestimmter Anteil der zulässigen Geschossfläche für gewerbliche Nutzungen zu verwenden ist.';
COMMENT ON COLUMN "BP_Bebauung"."BP_UeberbaubareGrundstuecksFlaeche"."GFGewerbe" IS 'Festsetzung nach §6a Abs. (4) Nr. 4 BauNVO: Für urbane Gebiete oder Teile solcher Gebiete kann festgesetzt werden, dass in Gebäuden eine im Bebauungsplan bestimmte Größe der Geschossfläche für gewerbliche Nutzungen zu verwenden ist.';
CREATE TRIGGER "change_to_BP_UeberbaubareGrundstuecksFlaeche" BEFORE INSERT OR UPDATE ON "BP_Bebauung"."BP_UeberbaubareGrundstuecksFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_BP_UeberbaubareGrundstuecksFlaeche" AFTER DELETE ON "BP_Bebauung"."BP_UeberbaubareGrundstuecksFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "ueberlagerung_BP_UeberbaubareGrundstuecksFlaeche" BEFORE INSERT OR UPDATE ON "BP_Bebauung"."BP_UeberbaubareGrundstuecksFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isUeberlagerungsobjekt"();

-- -----------------------------------------------------
-- Table "BP_Bebauung"."BP_NutzungNichUueberbaubGrundstFlaeche"
-- -----------------------------------------------------
CREATE TABLE  "BP_Bebauung"."BP_NutzungNichUueberbaubGrundstFlaeche" (
  "Code" INTEGER NOT NULL,
  "Bezeichner" VARCHAR(64) NOT NULL,
  PRIMARY KEY ("Code"));

GRANT SELECT ON TABLE "BP_Bebauung"."BP_NutzungNichUueberbaubGrundstFlaeche" TO xp_gast;
GRANT ALL ON "BP_Bebauung"."BP_NutzungNichUueberbaubGrundstFlaeche" TO bp_user;
CREATE TRIGGER "ins_upd_BP_NutzungNichUueberbaubGrundstFlaechen" BEFORE INSERT OR UPDATE ON "BP_Bebauung"."BP_NutzungNichUueberbaubGrundstFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isCodeList"();

-- -----------------------------------------------------
-- Table "BP_Bebauung"."BP_NichtUeberbaubareGrundstuecksflaeche"
-- -----------------------------------------------------
CREATE TABLE "BP_Bebauung"."BP_NichtUeberbaubareGrundstuecksflaeche" (
  "gid" BIGINT NOT NULL,
  "nutzung" INTEGER,
  PRIMARY KEY ("gid"),
  CONSTRAINT "fk_BP_NichtUeberbaubareGrundstuecksflaeche_parent"
    FOREIGN KEY ("gid")
    REFERENCES "BP_Basisobjekte"."BP_Objekt" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_BP_NichtUeberbaubareGrundstuecksflaeche_nutzung"
    FOREIGN KEY ("nutzung")
    REFERENCES "BP_Bebauung"."BP_NutzungNichUueberbaubGrundstFlaeche" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE)
INHERITS("BP_Basisobjekte"."BP_Flaechenobjekt");

GRANT SELECT ON TABLE "BP_Bebauung"."BP_NichtUeberbaubareGrundstuecksflaeche" TO xp_gast;
GRANT ALL ON TABLE "BP_Bebauung"."BP_NichtUeberbaubareGrundstuecksflaeche" TO bp_user;
CREATE INDEX "BP_NichtUeberbaubareGrundstuecksflaeche_gidx" ON "BP_Bebauung"."BP_NichtUeberbaubareGrundstuecksflaeche" using gist ("position");
COMMENT ON COLUMN "BP_Bebauung"."BP_NichtUeberbaubareGrundstuecksflaeche"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_BP_NichtUeberbaubareGrundstuecksflaeche" BEFORE INSERT OR UPDATE ON "BP_Bebauung"."BP_NichtUeberbaubareGrundstuecksflaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_BP_NichtUeberbaubareGrundstuecksflaeche" AFTER DELETE ON "BP_Bebauung"."BP_NichtUeberbaubareGrundstuecksflaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "ueberlagerung_BP_NichtUeberbaubareGrundstuecksflaeche" BEFORE INSERT OR UPDATE ON "BP_Bebauung"."BP_NichtUeberbaubareGrundstuecksflaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isUeberlagerungsobjekt"();

-- -----------------------------------------------------
-- Table "BP_Bebauung"."BP_BauGrenze"
-- -----------------------------------------------------
CREATE TABLE  "BP_Bebauung"."BP_BauGrenze" (
  "gid" BIGINT NOT NULL,
  "bautiefe" NUMERIC(10,2),
  "geschossMin" INTEGER,
  "geschossMax" INTEGER,
  PRIMARY KEY ("gid"),
  CONSTRAINT "fk_BP_BauGrenze_parent0"
    FOREIGN KEY ("gid")
    REFERENCES "BP_Basisobjekte"."BP_Objekt" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("BP_Basisobjekte"."BP_Linienobjekt");

GRANT SELECT ON TABLE "BP_Bebauung"."BP_BauGrenze" TO xp_gast;
GRANT ALL ON TABLE "BP_Bebauung"."BP_BauGrenze" TO bp_user;
CREATE INDEX "BP_BauGrenze_gidx" ON "BP_Bebauung"."BP_BauGrenze" using gist ("position");
COMMENT ON TABLE "BP_Bebauung"."BP_BauGrenze" IS 'Festsetzung einer Baulinie (§9 Abs. 1 Nr. 2 BauGB, §22 und 23 BauNVO). Über die Attribute geschossMin und geschossMax kann die Festsetzung auf einen Bereich von Geschossen beschränkt werden. Wenn eine Einschränkung der Festsetzung durch expliziter Höhenangaben erfolgen soll, ist dazu die Oberklassen-Relation hoehenangabe auf den komplexen Datentyp XP_Hoehenangabe zu verwenden. Durch die Digitalisierungsreihenfolge der Linienstützpunkte muss sichergestellt sein, dass die überbaute Fläche (BP_UeberbaubareGrundstuecksFlaeche) relativ zur Laufrichtung auf der linken Seite liegt.';
COMMENT ON COLUMN "BP_Bebauung"."BP_BauGrenze"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN "BP_Bebauung"."BP_BauGrenze"."bautiefe" IS 'Angabe einer Bautiefe.';
COMMENT ON COLUMN "BP_Bebauung"."BP_BauGrenze"."geschossMin" IS 'Gibt bei geschossweiser Festsetzung die Nummer des Geschosses an, ab den die Festsetzung gilt. Wenn das Attribut nicht belegt ist, gilt die Festsetzung für alle Geschosse bis einschl. geschossMax.';
COMMENT ON COLUMN "BP_Bebauung"."BP_BauGrenze"."geschossMax" IS 'Gibt bei geschossweiser Feststzung die Nummer des Geschosses an, bis zu der die Festsetzung gilt. Wenn das Attribut nicht belegt ist, gilt die Festsetzung für alle Geschosse ab einschl. geschossMin.';
CREATE TRIGGER "change_to_BP_BauGrenze" BEFORE INSERT OR UPDATE ON "BP_Bebauung"."BP_BauGrenze" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_BP_BauGrenze" AFTER DELETE ON "BP_Bebauung"."BP_BauGrenze" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "BP_Bebauung"."BP_UeberbaubareGrundstuecksFlaeche_baulinie"
-- -----------------------------------------------------
CREATE TABLE  "BP_Bebauung"."BP_UeberbaubareGrundstuecksFlaeche_baulinie" (
  "BP_UeberbaubareGrundstuecksFlaeche_gid" BIGINT NOT NULL,
  "baulinie" BIGINT NOT NULL,
  PRIMARY KEY ("BP_UeberbaubareGrundstuecksFlaeche_gid", "baulinie"),
  CONSTRAINT "fk_BP_UeberbaubareGrundstuecksFlaeche_baulinie1"
    FOREIGN KEY ("BP_UeberbaubareGrundstuecksFlaeche_gid")
    REFERENCES "BP_Bebauung"."BP_UeberbaubareGrundstuecksFlaeche" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_BP_UeberbaubareGrundstuecksFlaeche_baulinie2"
    FOREIGN KEY ("baulinie")
    REFERENCES "BP_Bebauung"."BP_BauLinie" ("gid")
    ON DELETE NO ACTION
    ON UPDATE CASCADE);

CREATE INDEX "fk_BP_UeberbaubareGrundstuecksFlaeche_baulinie1_idx" ON "BP_Bebauung"."BP_UeberbaubareGrundstuecksFlaeche_baulinie" ("baulinie");
CREATE INDEX "fk_BP_UeberbaubareGrundstuecksFlaeche_baulinie2_idx" ON "BP_Bebauung"."BP_UeberbaubareGrundstuecksFlaeche_baulinie" ("BP_UeberbaubareGrundstuecksFlaeche_gid");
GRANT SELECT ON TABLE "BP_Bebauung"."BP_UeberbaubareGrundstuecksFlaeche_baulinie" TO xp_gast;
GRANT ALL ON TABLE "BP_Bebauung"."BP_UeberbaubareGrundstuecksFlaeche_baulinie" TO bp_user;
COMMENT ON TABLE  "BP_Bebauung"."BP_UeberbaubareGrundstuecksFlaeche_baulinie" IS '';

-- -----------------------------------------------------
-- Table "BP_Bebauung"."BP_UeberbaubareGrundstuecksFlaeche_baugrenze"
-- -----------------------------------------------------
CREATE TABLE  "BP_Bebauung"."BP_UeberbaubareGrundstuecksFlaeche_baugrenze" (
  "BP_UeberbaubareGrundstuecksFlaeche_gid" BIGINT NOT NULL,
  "baugrenze" BIGINT NOT NULL,
  PRIMARY KEY ("BP_UeberbaubareGrundstuecksFlaeche_gid", "baugrenze"),
  CONSTRAINT "fk_BP_UeberbaubareGrundstuecksFlaeche_baugrenze1"
    FOREIGN KEY ("BP_UeberbaubareGrundstuecksFlaeche_gid")
    REFERENCES "BP_Bebauung"."BP_UeberbaubareGrundstuecksFlaeche" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_BP_UeberbaubareGrundstuecksFlaeche_baugrenze2"
    FOREIGN KEY ("baugrenze")
    REFERENCES "BP_Bebauung"."BP_BauGrenze" ("gid")
    ON DELETE NO ACTION
    ON UPDATE CASCADE);

CREATE INDEX "fk_BP_UeberbaubareGrundstuecksFlaeche_baugrenze1_idx" ON "BP_Bebauung"."BP_UeberbaubareGrundstuecksFlaeche_baugrenze" ("baugrenze");
CREATE INDEX "fk_BP_UeberbaubareGrundstuecksFlaeche_baugrenze2_idx" ON "BP_Bebauung"."BP_UeberbaubareGrundstuecksFlaeche_baugrenze" ("BP_UeberbaubareGrundstuecksFlaeche_gid");
GRANT SELECT ON TABLE "BP_Bebauung"."BP_UeberbaubareGrundstuecksFlaeche_baugrenze" TO xp_gast;
GRANT ALL ON TABLE "BP_Bebauung"."BP_UeberbaubareGrundstuecksFlaeche_baugrenze" TO bp_user;
COMMENT ON TABLE  "BP_Bebauung"."BP_UeberbaubareGrundstuecksFlaeche_baugrenze" IS '';

-- -----------------------------------------------------
-- Table "BP_Bebauung"."BP_AbweichungVonBaugrenze"
-- -----------------------------------------------------
CREATE TABLE "BP_Bebauung"."BP_AbweichungVonBaugrenze" (
  "gid" BIGINT NOT NULL,
  PRIMARY KEY ("gid"),
  CONSTRAINT "fk_BP_AbweichungVonBaugrenze_parent0"
    FOREIGN KEY ("gid")
    REFERENCES "BP_Basisobjekte"."BP_Objekt" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("BP_Basisobjekte"."BP_Linienobjekt");

GRANT SELECT ON TABLE "BP_Bebauung"."BP_AbweichungVonBaugrenze" TO xp_gast;
GRANT ALL ON TABLE "BP_Bebauung"."BP_AbweichungVonBaugrenze" TO bp_user;
CREATE INDEX "BP_AbweichungVonBaugrenze_gidx" ON "BP_Bebauung"."BP_AbweichungVonBaugrenze" using gist ("position");
COMMENT ON TABLE "BP_Bebauung"."BP_AbweichungVonBaugrenze" IS 'Linienhafte Festlegung des Umfangs der Abweichung von der Baugrenze (§23 Abs. 3 Satz 3 BauNVO).';
COMMENT ON COLUMN "BP_Bebauung"."BP_AbweichungVonBaugrenze"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_BP_AbweichungVonBaugrenze" BEFORE INSERT OR UPDATE ON "BP_Bebauung"."BP_AbweichungVonBaugrenze" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_BP_AbweichungVonBaugrenze" AFTER DELETE ON "BP_Bebauung"."BP_AbweichungVonBaugrenze" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "BP_Bebauung"."BP_AbweichungVonUeberbaubererGrundstuecksFlaeche"
-- -----------------------------------------------------
CREATE TABLE "BP_Bebauung"."BP_AbweichungVonUeberbaubererGrundstuecksFlaeche" (
  "gid" BIGINT NOT NULL,
  PRIMARY KEY ("gid"),
  CONSTRAINT "fk_BP_AbweichungVonUeberbaubererGrundstuecksFlaeche_parent"
    FOREIGN KEY ("gid")
    REFERENCES "BP_Basisobjekte"."BP_Objekt" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("BP_Basisobjekte"."BP_Flaechenobjekt");

GRANT SELECT ON TABLE "BP_Bebauung"."BP_AbweichungVonUeberbaubererGrundstuecksFlaeche" TO xp_gast;
GRANT ALL ON TABLE "BP_Bebauung"."BP_AbweichungVonUeberbaubererGrundstuecksFlaeche" TO bp_user;
CREATE INDEX "BP_AbweichungVonUeberbaubererGrundstuecksFlaeche_gidx" ON "BP_Bebauung"."BP_AbweichungVonUeberbaubererGrundstuecksFlaeche" using gist ("position");
COMMENT ON TABLE "BP_Bebauung"."BP_AbweichungVonUeberbaubererGrundstuecksFlaeche" IS 'Flächenhafte Festlegung des Umfangs der Abweichung von der überbaubaren Grundstücksfläche (§23 Abs. 3 Satz 3 BauNVO).';
COMMENT ON COLUMN "BP_Bebauung"."BP_AbweichungVonUeberbaubererGrundstuecksFlaeche"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_BP_AbweichungVonUeberbaubererGrundstuecksFlaeche" BEFORE INSERT OR UPDATE ON "BP_Bebauung"."BP_AbweichungVonUeberbaubererGrundstuecksFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_BP_AbweichungVonUeberbaubererGrundstuecksFlaeche" AFTER DELETE ON "BP_Bebauung"."BP_AbweichungVonUeberbaubererGrundstuecksFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "ueberlagerung_BP_AbweichungVonUeberbaubererGrundstuecksFlaeche" BEFORE INSERT OR UPDATE ON "BP_Bebauung"."BP_AbweichungVonUeberbaubererGrundstuecksFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isUeberlagerungsobjekt"();

-- -----------------------------------------------------
-- Table "BP_Gemeinbedarf_Spiel_und_Sportanlagen"."BP_GemeinbedarfsFlaeche"
-- -----------------------------------------------------
CREATE TABLE  "BP_Gemeinbedarf_Spiel_und_Sportanlagen"."BP_GemeinbedarfsFlaeche" (
  "gid" BIGINT NOT NULL,
  "zugunstenVon" VARCHAR(64),
  "bauweise" INTEGER,
  "bebauungsArt" INTEGER,
  "abweichendeBauweise" INTEGER,
  PRIMARY KEY ("gid"),
  CONSTRAINT "fk_BP_GemeinbedarfsFlaeche_parent"
    FOREIGN KEY ("gid")
    REFERENCES "BP_Bebauung"."BP_GestaltungBaugebiet" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_BP_GemeinbedarfsFlaeche_BP_Bauweise1"
    FOREIGN KEY ("bauweise")
    REFERENCES "BP_Bebauung"."BP_Bauweise" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_BP_GemeinbedarfsFlaeche_BP_AbweichendeBauweise1"
    FOREIGN KEY ("abweichendeBauweise")
    REFERENCES "BP_Bebauung"."BP_AbweichendeBauweise" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_BP_GemeinbedarfsFlaeche_BP_BebauungsArt1"
    FOREIGN KEY ("bebauungsArt")
    REFERENCES "BP_Bebauung"."BP_BebauungsArt" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE)
INHERITS ("BP_Basisobjekte"."BP_Flaechenobjekt");

GRANT SELECT ON TABLE "BP_Gemeinbedarf_Spiel_und_Sportanlagen"."BP_GemeinbedarfsFlaeche" TO xp_gast;
GRANT ALL ON TABLE "BP_Gemeinbedarf_Spiel_und_Sportanlagen"."BP_GemeinbedarfsFlaeche" TO bp_user;
CREATE INDEX "BP_GemeinbedarfsFlaeche_gidx" ON "BP_Gemeinbedarf_Spiel_und_Sportanlagen"."BP_GemeinbedarfsFlaeche" using gist ("position");
COMMENT ON TABLE  "BP_Gemeinbedarf_Spiel_und_Sportanlagen"."BP_GemeinbedarfsFlaeche" IS 'Einrichtungen und Anlagen zur Versorgung mit Gütern und Dienstleistungen des öffentlichen und privaten Bereichs, hier Flächen für den Gemeindebedarf (§9, Abs. 1, Nr.5 und Abs. 6 BauGB).';
COMMENT ON COLUMN  "BP_Gemeinbedarf_Spiel_und_Sportanlagen"."BP_GemeinbedarfsFlaeche"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN  "BP_Gemeinbedarf_Spiel_und_Sportanlagen"."BP_GemeinbedarfsFlaeche"."zugunstenVon" IS 'Angabe des Begünstigten einer Ausweisung.';
COMMENT ON COLUMN "BP_Gemeinbedarf_Spiel_und_Sportanlagen"."BP_GemeinbedarfsFlaeche"."bauweise" IS 'Festsetzung der Bauweise (§9, Abs. 1, Nr. 2 BauGB).';
COMMENT ON COLUMN "BP_Gemeinbedarf_Spiel_und_Sportanlagen"."BP_GemeinbedarfsFlaeche"."bebauungsArt" IS 'Detaillierte Festsetzung der Bauweise (§9, Abs. 1, Nr. 2 BauGB).';
COMMENT ON COLUMN "BP_Gemeinbedarf_Spiel_und_Sportanlagen"."BP_GemeinbedarfsFlaeche"."abweichendeBauweise" IS 'Nähere Bezeichnung einer "Abweichenden Bauweise" ("bauweise" == 3000).';
CREATE TRIGGER "change_to_BP_GemeinbedarfsFlaeche" BEFORE INSERT OR UPDATE ON "BP_Gemeinbedarf_Spiel_und_Sportanlagen"."BP_GemeinbedarfsFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_BP_GemeinbedarfsFlaeche" AFTER DELETE ON "BP_Gemeinbedarf_Spiel_und_Sportanlagen"."BP_GemeinbedarfsFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "flaechenschluss_BP_GemeinbedarfsFlaeche" BEFORE INSERT OR UPDATE OR DELETE ON "BP_Gemeinbedarf_Spiel_und_Sportanlagen"."BP_GemeinbedarfsFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isFlaechenschlussobjekt"();

-- -----------------------------------------------------
-- Table "BP_Gemeinbedarf_Spiel_und_Sportanlagen"."BP_GemeinbedarfsFlaeche_zweckbestimmung"
-- -----------------------------------------------------
CREATE TABLE  "BP_Gemeinbedarf_Spiel_und_Sportanlagen"."BP_GemeinbedarfsFlaeche_zweckbestimmung" (
  "BP_GemeinbedarfsFlaeche_gid" BIGINT NOT NULL,
  "zweckbestimmung" INTEGER NOT NULL,
  PRIMARY KEY ("BP_GemeinbedarfsFlaeche_gid", "zweckbestimmung"),
  CONSTRAINT "fk_BP_GemeinbedarfsFlaeche_zweckbestimmung_1"
    FOREIGN KEY ("BP_GemeinbedarfsFlaeche_gid")
    REFERENCES "BP_Gemeinbedarf_Spiel_und_Sportanlagen"."BP_GemeinbedarfsFlaeche" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_BP_GemeinbedarfsFlaeche_zweckbestimmung_2"
    FOREIGN KEY ("zweckbestimmung")
    REFERENCES "XP_Enumerationen"."XP_ZweckbestimmungGemeinbedarf" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE);

CREATE INDEX "idx_fk_BP_GemeinbedarfsFlaeche_zweckbestimmung1_idx" ON "BP_Gemeinbedarf_Spiel_und_Sportanlagen"."BP_GemeinbedarfsFlaeche_zweckbestimmung" ("zweckbestimmung");
CREATE INDEX "idx_fk_BP_GemeinbedarfsFlaeche_zweckbestimmung2_idx" ON "BP_Gemeinbedarf_Spiel_und_Sportanlagen"."BP_GemeinbedarfsFlaeche_zweckbestimmung" ("BP_GemeinbedarfsFlaeche_gid");
GRANT SELECT ON TABLE "BP_Gemeinbedarf_Spiel_und_Sportanlagen"."BP_GemeinbedarfsFlaeche_zweckbestimmung" TO xp_gast;
GRANT ALL ON TABLE "BP_Gemeinbedarf_Spiel_und_Sportanlagen"."BP_GemeinbedarfsFlaeche_zweckbestimmung" TO bp_user;
COMMENT ON TABLE  "BP_Gemeinbedarf_Spiel_und_Sportanlagen"."BP_GemeinbedarfsFlaeche_zweckbestimmung" IS 'Allgemeine Zweckbestimmungen der festgesetzten Fläche';

-- -----------------------------------------------------
-- Table "BP_Gemeinbedarf_Spiel_und_Sportanlagen"."BP_DetailZweckbestGemeinbedarf"
-- -----------------------------------------------------
CREATE TABLE "BP_Gemeinbedarf_Spiel_und_Sportanlagen"."BP_DetailZweckbestGemeinbedarf" (
  "Code" INTEGER NOT NULL,
  "Bezeichner" VARCHAR(64) NOT NULL,
  PRIMARY KEY ("Code"));
GRANT SELECT ON TABLE "BP_Gemeinbedarf_Spiel_und_Sportanlagen"."BP_DetailZweckbestGemeinbedarf" TO xp_gast;
GRANT ALL ON "BP_Gemeinbedarf_Spiel_und_Sportanlagen"."BP_DetailZweckbestGemeinbedarf" TO bp_user;
CREATE TRIGGER "ins_upd_BP_DetailZweckbestGemeinbedarf" BEFORE INSERT OR UPDATE ON "BP_Gemeinbedarf_Spiel_und_Sportanlagen"."BP_DetailZweckbestGemeinbedarf" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isCodeList"();

-- -----------------------------------------------------
-- Table "BP_Gemeinbedarf_Spiel_und_Sportanlagen"."BP_GemeinbedarfsFlaeche_detaillierteZweckbestimmung"
-- -----------------------------------------------------
CREATE TABLE "BP_Gemeinbedarf_Spiel_und_Sportanlagen"."BP_GemeinbedarfsFlaeche_detaillierteZweckbestimmung" (
  "BP_GemeinbedarfsFlaeche_gid" BIGINT NOT NULL,
  "detaillierteZweckbestimmung" INTEGER NOT NULL,
  PRIMARY KEY ("BP_GemeinbedarfsFlaeche_gid", "detaillierteZweckbestimmung"),
  CONSTRAINT "fk_BP_GemeinbedarfsFlaeche_detaillierteZweckbes1"
    FOREIGN KEY ("BP_GemeinbedarfsFlaeche_gid")
    REFERENCES "BP_Gemeinbedarf_Spiel_und_Sportanlagen"."BP_GemeinbedarfsFlaeche" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_BP_GemeinbedarfsFlaeche_detaillierteZweckbes2"
    FOREIGN KEY ("detaillierteZweckbestimmung")
    REFERENCES "BP_Gemeinbedarf_Spiel_und_Sportanlagen"."BP_DetailZweckbestGemeinbedarf" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE);

GRANT SELECT ON TABLE "BP_Gemeinbedarf_Spiel_und_Sportanlagen"."BP_GemeinbedarfsFlaeche_detaillierteZweckbestimmung" TO xp_gast;
GRANT ALL ON TABLE "BP_Gemeinbedarf_Spiel_und_Sportanlagen"."BP_GemeinbedarfsFlaeche_detaillierteZweckbestimmung" TO bp_user;
COMMENT ON TABLE  "BP_Gemeinbedarf_Spiel_und_Sportanlagen"."BP_GemeinbedarfsFlaeche_detaillierteZweckbestimmung" IS 'Über eine Codeliste definierte detailliertere Festlegung der Zweckbestimmung.
Der an einer bestimmten Listenposition aufgeführte Wert von "detaillierteZweckbestimmung" bezieht sich auf den an gleicher Position stehenden Attributwert von "zweckbestimmung".';

-- -----------------------------------------------------
-- Table "BP_Gemeinbedarf_Spiel_und_Sportanlagen"."BP_SpielSportanlagenFlaeche"
-- -----------------------------------------------------
CREATE TABLE  "BP_Gemeinbedarf_Spiel_und_Sportanlagen"."BP_SpielSportanlagenFlaeche" (
  "gid" BIGINT NOT NULL,
  "zugunstenVon" VARCHAR(64),
  PRIMARY KEY ("gid"),
  CONSTRAINT "fk_BP_SpielSportanlagenFlaeche_parent"
    FOREIGN KEY ("gid")
    REFERENCES "BP_Bebauung"."BP_FestsetzungenBaugebiet" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("BP_Basisobjekte"."BP_Flaechenobjekt");

GRANT SELECT ON TABLE "BP_Gemeinbedarf_Spiel_und_Sportanlagen"."BP_SpielSportanlagenFlaeche" TO xp_gast;
GRANT ALL ON TABLE "BP_Gemeinbedarf_Spiel_und_Sportanlagen"."BP_SpielSportanlagenFlaeche" TO bp_user;
CREATE INDEX "BP_SpielSportanlagenFlaeche_gidx" ON "BP_Gemeinbedarf_Spiel_und_Sportanlagen"."BP_SpielSportanlagenFlaeche" using gist ("position");
COMMENT ON TABLE  "BP_Gemeinbedarf_Spiel_und_Sportanlagen"."BP_SpielSportanlagenFlaeche" IS 'Einrichtungen und Anlagen zur Versorgung mit Gütern und Dienstleistungen des öffentlichen und privaten Bereichs, hier Flächen für Sport- und Spielanlagen (§9, Abs. 1, Nr. 5 und Abs. 6 BauGB).';
COMMENT ON COLUMN  "BP_Gemeinbedarf_Spiel_und_Sportanlagen"."BP_SpielSportanlagenFlaeche"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN  "BP_Gemeinbedarf_Spiel_und_Sportanlagen"."BP_SpielSportanlagenFlaeche"."zugunstenVon" IS 'Angabe des Begünstigten einer Ausweisung.';
CREATE TRIGGER "change_to_BP_SpielSportanlagenFlaeche" BEFORE INSERT OR UPDATE ON "BP_Gemeinbedarf_Spiel_und_Sportanlagen"."BP_SpielSportanlagenFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_BP_SpielSportanlagenFlaeche" AFTER DELETE ON "BP_Gemeinbedarf_Spiel_und_Sportanlagen"."BP_SpielSportanlagenFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "flaechenschluss_BP_SpielSportanlagenFlaeche" BEFORE INSERT OR UPDATE OR DELETE ON "BP_Gemeinbedarf_Spiel_und_Sportanlagen"."BP_SpielSportanlagenFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isFlaechenschlussobjekt"();

-- -----------------------------------------------------
-- Table "BP_Gemeinbedarf_Spiel_und_Sportanlagen"."BP_SpielSportanlagenFlaeche_zweckbestimmung"
-- -----------------------------------------------------
CREATE TABLE  "BP_Gemeinbedarf_Spiel_und_Sportanlagen"."BP_SpielSportanlagenFlaeche_zweckbestimmung" (
  "BP_SpielSportanlagenFlaeche_gid" BIGINT NOT NULL,
  "zweckbestimmung" INTEGER NOT NULL,
  PRIMARY KEY ("BP_SpielSportanlagenFlaeche_gid", "zweckbestimmung"),
  CONSTRAINT "fk_BP_SpielSportanlagenFlaeche_zweckbestimmung1"
    FOREIGN KEY ("BP_SpielSportanlagenFlaeche_gid")
    REFERENCES "BP_Gemeinbedarf_Spiel_und_Sportanlagen"."BP_SpielSportanlagenFlaeche" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_BP_SpielSportanlagenFlaeche_zweckbestimmung2"
    FOREIGN KEY ("zweckbestimmung")
    REFERENCES "XP_Enumerationen"."XP_ZweckbestimmungSpielSportanlage" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE);

CREATE INDEX "idx_fk_BP_SpielSportanlagenFlaeche_zweckbestimmung1_idx" ON "BP_Gemeinbedarf_Spiel_und_Sportanlagen"."BP_SpielSportanlagenFlaeche_zweckbestimmung" ("zweckbestimmung");
CREATE INDEX "idx_fk_BP_SpielSportanlagenFlaeche_zweckbestimmung2_idx" ON "BP_Gemeinbedarf_Spiel_und_Sportanlagen"."BP_SpielSportanlagenFlaeche_zweckbestimmung" ("BP_SpielSportanlagenFlaeche_gid");
GRANT SELECT ON TABLE "BP_Gemeinbedarf_Spiel_und_Sportanlagen"."BP_SpielSportanlagenFlaeche_zweckbestimmung" TO xp_gast;
GRANT ALL ON TABLE "BP_Gemeinbedarf_Spiel_und_Sportanlagen"."BP_SpielSportanlagenFlaeche_zweckbestimmung" TO bp_user;
COMMENT ON TABLE  "BP_Gemeinbedarf_Spiel_und_Sportanlagen"."BP_SpielSportanlagenFlaeche_zweckbestimmung" IS 'Zweckbestimmungen der festgesetzten Fläche.';

-- -----------------------------------------------------
-- Table "BP_Gemeinbedarf_Spiel_und_Sportanlagen"."BP_DetailZweckbestSpielSportanlage"
-- -----------------------------------------------------
CREATE TABLE  "BP_Gemeinbedarf_Spiel_und_Sportanlagen"."BP_DetailZweckbestSpielSportanlage" (
  "Code" INTEGER NOT NULL,
  "Bezeichner" VARCHAR(64) NOT NULL,
  PRIMARY KEY ("Code"));
GRANT SELECT ON TABLE "BP_Gemeinbedarf_Spiel_und_Sportanlagen"."BP_DetailZweckbestSpielSportanlage" TO xp_gast;
GRANT ALL ON "BP_Gemeinbedarf_Spiel_und_Sportanlagen"."BP_DetailZweckbestSpielSportanlage" TO bp_user;
CREATE TRIGGER "ins_upd_BP_DetailZweckbestSpielSportanlage" BEFORE INSERT OR UPDATE ON "BP_Gemeinbedarf_Spiel_und_Sportanlagen"."BP_DetailZweckbestSpielSportanlage" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isCodeList"();

-- -----------------------------------------------------
-- Table "BP_Gemeinbedarf_Spiel_und_Sportanlagen"."BP_SpielSportanlagenFlaeche_detaillierteZweckbestimmung"
-- -----------------------------------------------------
CREATE TABLE  "BP_Gemeinbedarf_Spiel_und_Sportanlagen"."BP_SpielSportanlagenFlaeche_detaillierteZweckbestimmung" (
  "BP_SpielSportanlagenFlaeche_gid" BIGINT NOT NULL,
  "detaillierteZweckbestimmung" INTEGER NOT NULL,
  PRIMARY KEY ("BP_SpielSportanlagenFlaeche_gid", "detaillierteZweckbestimmung"),
  CONSTRAINT "fk_BP_SpielSportanlagenFlaeche_detaillierteZweckbes1"
    FOREIGN KEY ("BP_SpielSportanlagenFlaeche_gid")
    REFERENCES "BP_Gemeinbedarf_Spiel_und_Sportanlagen"."BP_SpielSportanlagenFlaeche" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_BP_SpielSportanlagenFlaeche_detaillierteZweckbes2"
    FOREIGN KEY ("detaillierteZweckbestimmung")
    REFERENCES "BP_Gemeinbedarf_Spiel_und_Sportanlagen"."BP_DetailZweckbestSpielSportanlage" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE);

CREATE INDEX "idx_fk_BP_SpielSportanlagenFlaeche_detaillierteZweckbes1_idx" ON "BP_Gemeinbedarf_Spiel_und_Sportanlagen"."BP_SpielSportanlagenFlaeche_detaillierteZweckbestimmung" ("detaillierteZweckbestimmung");
CREATE INDEX "idx_fk_BP_SpielSportanlagenFlaeche_detaillierteZweckbest2_idx" ON "BP_Gemeinbedarf_Spiel_und_Sportanlagen"."BP_SpielSportanlagenFlaeche_detaillierteZweckbestimmung" ("BP_SpielSportanlagenFlaeche_gid");
GRANT SELECT ON TABLE "BP_Gemeinbedarf_Spiel_und_Sportanlagen"."BP_SpielSportanlagenFlaeche_detaillierteZweckbestimmung" TO xp_gast;
GRANT ALL ON TABLE "BP_Gemeinbedarf_Spiel_und_Sportanlagen"."BP_SpielSportanlagenFlaeche_detaillierteZweckbestimmung" TO bp_user;
COMMENT ON TABLE  "BP_Gemeinbedarf_Spiel_und_Sportanlagen"."BP_SpielSportanlagenFlaeche_detaillierteZweckbestimmung" IS 'Über eine CodeList definierte zusätzliche Zweckbestimmungen.';

-- -----------------------------------------------------
-- Table "BP_Landwirtschaft_Wald_und_Gruen"."BP_GruenFlaeche"
-- -----------------------------------------------------
CREATE TABLE  "BP_Landwirtschaft_Wald_und_Gruen"."BP_GruenFlaeche" (
  "gid" BIGINT NOT NULL,
  "nutzungsform" INTEGER,
  "zugunstenVon" VARCHAR(64),
  PRIMARY KEY ("gid"),
  CONSTRAINT "fk_BP_GruenFlaeche_parent"
    FOREIGN KEY ("gid")
    REFERENCES "BP_Bebauung"."BP_FestsetzungenBaugebiet" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_BP_GruenFlaeche_XP_Nutzungsform1"
    FOREIGN KEY ("nutzungsform")
    REFERENCES "XP_Enumerationen"."XP_Nutzungsform" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE)
INHERITS ("BP_Basisobjekte"."BP_Flaechenobjekt");

GRANT SELECT ON TABLE "BP_Landwirtschaft_Wald_und_Gruen"."BP_GruenFlaeche" TO xp_gast;
GRANT ALL ON TABLE "BP_Landwirtschaft_Wald_und_Gruen"."BP_GruenFlaeche" TO bp_user;
CREATE INDEX "BP_GruenFlaeche_gidx" ON "BP_Landwirtschaft_Wald_und_Gruen"."BP_GruenFlaeche" using gist ("position");
COMMENT ON TABLE  "BP_Landwirtschaft_Wald_und_Gruen"."BP_GruenFlaeche" IS 'Festsetzungen von öffentlichen und privaten Grünflächen(§9, Abs. 1, Nr. 15 BauGB) und von Flächen für die Kleintierhaltung (§9, Abs. 1, Nr. 19 BauGB).';
COMMENT ON COLUMN  "BP_Landwirtschaft_Wald_und_Gruen"."BP_GruenFlaeche"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN  "BP_Landwirtschaft_Wald_und_Gruen"."BP_GruenFlaeche"."nutzungsform" IS 'Nutzungform der festgesetzten Fläche.';
COMMENT ON COLUMN  "BP_Landwirtschaft_Wald_und_Gruen"."BP_GruenFlaeche"."zugunstenVon" IS 'Angabe des Begünstigten einer Ausweisung.';
CREATE TRIGGER "change_to_BP_GruenFlaeche" BEFORE INSERT OR UPDATE ON "BP_Landwirtschaft_Wald_und_Gruen"."BP_GruenFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_BP_GruenFlaeche" AFTER DELETE ON "BP_Landwirtschaft_Wald_und_Gruen"."BP_GruenFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "flaechenschluss_BP_GruenFlaeche" BEFORE INSERT OR UPDATE OR DELETE ON "BP_Landwirtschaft_Wald_und_Gruen"."BP_GruenFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isFlaechenschlussobjekt"();

-- -----------------------------------------------------
-- Table "BP_Landwirtschaft_Wald_und_Gruen"."BP_GruenFlaeche_zweckbestimmung"
-- -----------------------------------------------------
CREATE TABLE  "BP_Landwirtschaft_Wald_und_Gruen"."BP_GruenFlaeche_zweckbestimmung" (
  "BP_GruenFlaeche_gid" BIGINT NOT NULL,
  "zweckbestimmung" INTEGER NOT NULL,
  PRIMARY KEY ("BP_GruenFlaeche_gid", "zweckbestimmung"),
  CONSTRAINT "fk_BP_GruenFlaeche_zweckbestimmung1"
    FOREIGN KEY ("BP_GruenFlaeche_gid")
    REFERENCES "BP_Landwirtschaft_Wald_und_Gruen"."BP_GruenFlaeche" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_BP_GruenFlaeche_zweckbestimmung2"
    FOREIGN KEY ("zweckbestimmung")
    REFERENCES "XP_Enumerationen"."XP_ZweckbestimmungGruen" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE);

CREATE INDEX "idx_fk_BP_GruenFlaeche_zweckbestimmung1_idx" ON "BP_Landwirtschaft_Wald_und_Gruen"."BP_GruenFlaeche_zweckbestimmung" ("zweckbestimmung");
CREATE INDEX "idx_fk_BP_GruenFlaeche_zweckbestimmung2_idx" ON "BP_Landwirtschaft_Wald_und_Gruen"."BP_GruenFlaeche_zweckbestimmung" ("BP_GruenFlaeche_gid");
GRANT SELECT ON TABLE "BP_Landwirtschaft_Wald_und_Gruen"."BP_GruenFlaeche_zweckbestimmung" TO xp_gast;
GRANT ALL ON TABLE "BP_Landwirtschaft_Wald_und_Gruen"."BP_GruenFlaeche_zweckbestimmung" TO bp_user;
COMMENT ON TABLE  "BP_Landwirtschaft_Wald_und_Gruen"."BP_GruenFlaeche_zweckbestimmung" IS 'Allgemeine Zweckbestimmungen der Grünfläche';

-- -----------------------------------------------------
-- Table "BP_Landwirtschaft_Wald_und_Gruen"."BP_DetailZweckbestGruenFlaeche"
-- -----------------------------------------------------
CREATE TABLE  "BP_Landwirtschaft_Wald_und_Gruen"."BP_DetailZweckbestGruenFlaeche" (
  "Code" INTEGER NOT NULL,
  "Bezeichner" VARCHAR(64) NOT NULL,
  PRIMARY KEY ("Code"));

GRANT SELECT ON TABLE "BP_Landwirtschaft_Wald_und_Gruen"."BP_DetailZweckbestGruenFlaeche" TO xp_gast;
GRANT ALL ON "BP_Landwirtschaft_Wald_und_Gruen"."BP_DetailZweckbestGruenFlaeche" TO bp_user;
CREATE TRIGGER "ins_upd_BP_DetailZweckbestGruenFlaeche" BEFORE INSERT OR UPDATE ON "BP_Landwirtschaft_Wald_und_Gruen"."BP_DetailZweckbestGruenFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isCodeList"();

-- -----------------------------------------------------
-- Table "BP_Landwirtschaft_Wald_und_Gruen"."BP_GruenFlaeche_detaillierteZweckbestimmung"
-- -----------------------------------------------------
CREATE TABLE  "BP_Landwirtschaft_Wald_und_Gruen"."BP_GruenFlaeche_detaillierteZweckbestimmung" (
  "BP_GruenFlaeche_gid" BIGINT NOT NULL,
  "detaillierteZweckbestimmung" INTEGER NOT NULL,
  PRIMARY KEY ("BP_GruenFlaeche_gid", "detaillierteZweckbestimmung"),
  CONSTRAINT "fk_BP_GruenFlaeche_detaillierteZweckbestimmung1"
    FOREIGN KEY ("BP_GruenFlaeche_gid")
    REFERENCES "BP_Landwirtschaft_Wald_und_Gruen"."BP_GruenFlaeche" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_BP_GruenFlaeche_detaillierteZweckbestimmung2"
    FOREIGN KEY ("detaillierteZweckbestimmung")
    REFERENCES "BP_Landwirtschaft_Wald_und_Gruen"."BP_DetailZweckbestGruenFlaeche" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE);

CREATE INDEX "idx_fk_BP_GruenFlaeche_detaillierteZweckbestimmung1_idx" ON "BP_Landwirtschaft_Wald_und_Gruen"."BP_GruenFlaeche_detaillierteZweckbestimmung" ("detaillierteZweckbestimmung");
CREATE INDEX "idx_fk_BP_GruenFlaeche_detaillierteZweckbestimmung2_idx" ON "BP_Landwirtschaft_Wald_und_Gruen"."BP_GruenFlaeche_detaillierteZweckbestimmung" ("BP_GruenFlaeche_gid");
GRANT SELECT ON TABLE "BP_Landwirtschaft_Wald_und_Gruen"."BP_GruenFlaeche_detaillierteZweckbestimmung" TO xp_gast;
GRANT ALL ON TABLE "BP_Landwirtschaft_Wald_und_Gruen"."BP_GruenFlaeche_detaillierteZweckbestimmung" TO bp_user;
COMMENT ON TABLE  "BP_Landwirtschaft_Wald_und_Gruen"."BP_GruenFlaeche_detaillierteZweckbestimmung" IS 'Über eine CodeList definierte zusätzliche Zweckbestimmungen.';

-- -----------------------------------------------------
-- Table "BP_Verkehr"."BP_StrassenVerkehrsFlaeche"
-- -----------------------------------------------------
CREATE TABLE  "BP_Verkehr"."BP_StrassenVerkehrsFlaeche" (
  "gid" BIGINT NOT NULL,
  "nutzungsform" INTEGER,
  PRIMARY KEY ("gid"),
  CONSTRAINT "fk_BP_StrassenVerkehrsFlaeche_parent"
    FOREIGN KEY ("gid")
    REFERENCES "BP_Bebauung"."BP_FestsetzungenBaugebiet" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_BP_StrassenVerkehrsFlaeche_nutzungsform"
    FOREIGN KEY ("nutzungsform")
    REFERENCES "XP_Enumerationen"."XP_Nutzungsform" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE)
INHERITS ("BP_Basisobjekte"."BP_Flaechenobjekt");

GRANT SELECT ON TABLE "BP_Verkehr"."BP_StrassenVerkehrsFlaeche" TO xp_gast;
GRANT ALL ON TABLE "BP_Verkehr"."BP_StrassenVerkehrsFlaeche" TO bp_user;
CREATE INDEX "BP_StrassenVerkehrsFlaeche_gidx" ON "BP_Verkehr"."BP_StrassenVerkehrsFlaeche" using gist ("position");
COMMENT ON TABLE  "BP_Verkehr"."BP_StrassenVerkehrsFlaeche" IS 'Strassenverkehrsfläche (§9 Abs. 1 Nr. 11 und Abs. 6 BauGB).';
COMMENT ON COLUMN  "BP_Verkehr"."BP_StrassenVerkehrsFlaeche"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN  "BP_Verkehr"."BP_StrassenVerkehrsFlaeche"."nutzungsform" IS 'Nutzungform der Fläche.';
CREATE TRIGGER "change_to_BP_StrassenVerkehrsFlaeche" BEFORE INSERT OR UPDATE ON "BP_Verkehr"."BP_StrassenVerkehrsFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_BP_StrassenVerkehrsFlaeche" AFTER DELETE ON "BP_Verkehr"."BP_StrassenVerkehrsFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "flaechenschluss_BP_StrassenVerkehrsFlaeche" BEFORE INSERT OR UPDATE OR DELETE ON "BP_Verkehr"."BP_StrassenVerkehrsFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isFlaechenschlussobjekt"();

-- -----------------------------------------------------
-- Table "BP_Verkehr"."BP_StrassenVerkehrsFlaeche_begrenzungsLinie"
-- -----------------------------------------------------
CREATE TABLE  "BP_Verkehr"."BP_StrassenVerkehrsFlaeche_begrenzungsLinie" (
  "BP_StrassenVerkehrsFlaeche_gid" BIGINT NOT NULL,
  "begrenzungsLinie" BIGINT NOT NULL,
  PRIMARY KEY ("BP_StrassenVerkehrsFlaeche_gid", "begrenzungsLinie"),
  CONSTRAINT "fk_BP_StrassenVerkehrsFlaeche_begrenzungsLinie1"
    FOREIGN KEY ("BP_StrassenVerkehrsFlaeche_gid")
    REFERENCES "BP_Verkehr"."BP_StrassenVerkehrsFlaeche" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_BP_StrassenVerkehrsFlaeche_begrenzungsLinie2"
    FOREIGN KEY ("begrenzungsLinie")
    REFERENCES "BP_Verkehr"."BP_StrassenbegrenzungsLinie" ("gid")
    ON DELETE NO ACTION
    ON UPDATE CASCADE);

CREATE INDEX "idx_fk_BP_StrassenVerkehrsFlaeche_begrenzungsLinie1_idx" ON "BP_Verkehr"."BP_StrassenVerkehrsFlaeche_begrenzungsLinie" ("begrenzungsLinie");
CREATE INDEX "idx_fk_BP_StrassenVerkehrsFlaeche_begrenzungsLinie2_idx" ON "BP_Verkehr"."BP_StrassenVerkehrsFlaeche_begrenzungsLinie" ("BP_StrassenVerkehrsFlaeche_gid");
GRANT SELECT ON TABLE "BP_Verkehr"."BP_StrassenVerkehrsFlaeche_begrenzungsLinie" TO xp_gast;
GRANT ALL ON TABLE "BP_Verkehr"."BP_StrassenVerkehrsFlaeche_begrenzungsLinie" TO bp_user;
COMMENT ON TABLE "BP_Verkehr"."BP_StrassenVerkehrsFlaeche_begrenzungsLinie" IS '';

-- -----------------------------------------------------
-- Table "BP_Verkehr"."BP_ZweckbestimmungStrassenverkehr"
-- -----------------------------------------------------
CREATE TABLE  "BP_Verkehr"."BP_ZweckbestimmungStrassenverkehr" (
  "Code" INTEGER NOT NULL,
  "Bezeichner" VARCHAR(64) NOT NULL,
  PRIMARY KEY ("Code"));

GRANT SELECT ON TABLE "BP_Verkehr"."BP_ZweckbestimmungStrassenverkehr" TO xp_gast;

-- -----------------------------------------------------
-- Table "BP_Verkehr"."BP_DetailZweckbestStrassenverkehr"
-- -----------------------------------------------------
CREATE TABLE  "BP_Verkehr"."BP_DetailZweckbestStrassenverkehr" (
  "Code" INTEGER NOT NULL,
  "Bezeichner" VARCHAR(64) NOT NULL,
  PRIMARY KEY ("Code"));

GRANT SELECT ON TABLE "BP_Verkehr"."BP_DetailZweckbestStrassenverkehr" TO xp_gast;
GRANT ALL ON "BP_Verkehr"."BP_DetailZweckbestStrassenverkehr" TO bp_user;
CREATE TRIGGER "ins_upd_BP_DetailZweckbestStrassenverkehr" BEFORE INSERT OR UPDATE ON "BP_Verkehr"."BP_DetailZweckbestStrassenverkehr" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isCodeList"();

-- -----------------------------------------------------
-- Table "BP_Verkehr"."BP_VerkehrsFlaecheBesondererZweckbestimmung"
-- -----------------------------------------------------
CREATE TABLE  "BP_Verkehr"."BP_VerkehrsFlaecheBesondererZweckbestimmung" (
  "gid" BIGINT NOT NULL,
  "nutzungsform" INTEGER,
  "zugunstenVon" VARCHAR(64),
  PRIMARY KEY ("gid"),
  CONSTRAINT "fk_BP_VerkehrsFlaecheBesondererZweckbestimmung_parent"
    FOREIGN KEY ("gid")
    REFERENCES "BP_Bebauung"."BP_FestsetzungenBaugebiet" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_BP_VerkehrsFlaecheBesZweckbest_nutzungsform"
    FOREIGN KEY ("nutzungsform")
    REFERENCES "XP_Enumerationen"."XP_Nutzungsform" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE);

GRANT SELECT ON TABLE "BP_Verkehr"."BP_VerkehrsFlaecheBesondererZweckbestimmung" TO xp_gast;
GRANT ALL ON TABLE "BP_Verkehr"."BP_VerkehrsFlaecheBesondererZweckbestimmung" TO bp_user;
COMMENT ON TABLE  "BP_Verkehr"."BP_VerkehrsFlaecheBesondererZweckbestimmung" IS 'Strassenverkehrsfläche (§9 Abs. 1 Nr. 11 und Abs. 6 BauGB).';
COMMENT ON COLUMN  "BP_Verkehr"."BP_VerkehrsFlaecheBesondererZweckbestimmung"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN  "BP_Verkehr"."BP_VerkehrsFlaecheBesondererZweckbestimmung"."nutzungsform" IS 'Nutzungform der Fläche.';
COMMENT ON COLUMN "BP_Verkehr"."BP_VerkehrsFlaecheBesondererZweckbestimmung"."zugunstenVon" IS 'Begünstigter der Festsetzung';
CREATE TRIGGER "change_to_BP_VerkehrsFlaecheBesondererZweckbestimmung" BEFORE INSERT OR UPDATE ON "BP_Verkehr"."BP_VerkehrsFlaecheBesondererZweckbestimmung" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_BP_VerkehrsFlaecheBesondererZweckbestimmung" AFTER DELETE ON "BP_Verkehr"."BP_VerkehrsFlaecheBesondererZweckbestimmung" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "BP_Verkehr"."BP_VerkehrsFlaecheBesondererZweckbestimmung_zweckbestimmung"
-- -----------------------------------------------------
CREATE TABLE "BP_Verkehr"."BP_VerkehrsFlaecheBesondererZweckbestimmung_zweckbestimmung" (
  "BP_VerkehrsFlaecheBesondererZweckbestimmung_gid" BIGINT NOT NULL,
  "zweckbestimmung" INTEGER NOT NULL,
  PRIMARY KEY ("BP_VerkehrsFlaecheBesondererZweckbestimmung_gid", "zweckbestimmung"),
  CONSTRAINT "fk_BP_VerkehrsFlaecheBZ_zweckbestimmung1"
    FOREIGN KEY ("BP_VerkehrsFlaecheBesondererZweckbestimmung_gid")
    REFERENCES "BP_Verkehr"."BP_VerkehrsFlaecheBesondererZweckbestimmung" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_BP_VerkehrsFlaecheBZ_zweckbestimmung2"
    FOREIGN KEY ("zweckbestimmung")
    REFERENCES "BP_Verkehr"."BP_ZweckbestimmungStrassenverkehr" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE);

CREATE INDEX "idx_fk_BP_VerkehrsFlaecheBZ_zweckbestimmung1" ON "BP_Verkehr"."BP_VerkehrsFlaecheBesondererZweckbestimmung_zweckbestimmung" ("zweckbestimmung");
CREATE INDEX "idx_fk_BP_VerkehrsFlaecheBZ_zweckbestimmung2" ON "BP_Verkehr"."BP_VerkehrsFlaecheBesondererZweckbestimmung_zweckbestimmung" ("BP_VerkehrsFlaecheBesondererZweckbestimmung_gid");
GRANT SELECT ON TABLE "BP_Verkehr"."BP_VerkehrsFlaecheBesondererZweckbestimmung_zweckbestimmung" TO xp_gast;
GRANT ALL ON TABLE "BP_Verkehr"."BP_VerkehrsFlaecheBesondererZweckbestimmung_zweckbestimmung" TO bp_user;
COMMENT ON TABLE "BP_Verkehr"."BP_VerkehrsFlaecheBesondererZweckbestimmung_zweckbestimmung" IS 'Zweckbestimmung der Fläche';

-- -----------------------------------------------------
-- Table "BP_Verkehr"."BP_VerkehrsFlaecheBesondererZweckbestimmung_detaillierteZweckbestimmung"
-- -----------------------------------------------------
CREATE TABLE "BP_Verkehr"."BP_VerkehrsFlaecheBesondererZweckbestimmung_detaillierteZweckbestimmung" (
  "BP_VerkehrsFlaecheBesondererZweckbestimmung_gid" BIGINT NOT NULL,
  "detaillierteZweckbestimmung" INTEGER NOT NULL,
  PRIMARY KEY ("BP_VerkehrsFlaecheBesondererZweckbestimmung_gid", "detaillierteZweckbestimmung"),
  CONSTRAINT "fk_BP_VerkehrsFlaecheBZ_detaillierteZweckbestimmung1"
    FOREIGN KEY ("BP_VerkehrsFlaecheBesondererZweckbestimmung_gid")
    REFERENCES "BP_Verkehr"."BP_VerkehrsFlaecheBesondererZweckbestimmung" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_BP_VerkehrsFlaecheBZ_detaillierteZweckbestimmung2"
    FOREIGN KEY ("detaillierteZweckbestimmung")
    REFERENCES "BP_Verkehr"."BP_DetailZweckbestStrassenverkehr" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE);

CREATE INDEX "idx_fk_BP_VerkehrsFlaecheBZ_detaillierteZweckbestimmung1" ON "BP_Verkehr"."BP_VerkehrsFlaecheBesondererZweckbestimmung_detaillierteZweckbestimmung" ("detaillierteZweckbestimmung");
CREATE INDEX "idx_fk_BP_VerkehrsFlaecheBZ_detaillierteZweckbestimmung2" ON "BP_Verkehr"."BP_VerkehrsFlaecheBesondererZweckbestimmung_detaillierteZweckbestimmung" ("BP_VerkehrsFlaecheBesondererZweckbestimmung_gid");
GRANT SELECT ON TABLE "BP_Verkehr"."BP_VerkehrsFlaecheBesondererZweckbestimmung_detaillierteZweckbestimmung" TO xp_gast;
GRANT ALL ON TABLE "BP_Verkehr"."BP_VerkehrsFlaecheBesondererZweckbestimmung_detaillierteZweckbestimmung" TO bp_user;
COMMENT ON TABLE "BP_Verkehr"."BP_VerkehrsFlaecheBesondererZweckbestimmung_detaillierteZweckbestimmung" IS 'Über eine CodeList definierte zusätzliche Zweckbestimmung der Fläche.';

-- -----------------------------------------------------
-- Table "BP_Verkehr"."BP_VerkehrsFlaecheBesondererZweckbestimmungFlaeche"
-- -----------------------------------------------------
CREATE TABLE "BP_Verkehr"."BP_VerkehrsFlaecheBesondererZweckbestimmungFlaeche" (
  "gid" BIGINT NOT NULL,
  PRIMARY KEY ("gid"),
  CONSTRAINT "fk_BP_VerkehrsFlaecheBesondererZweckbestimmungFlaeche_parent"
    FOREIGN KEY ("gid")
    REFERENCES "BP_Verkehr"."BP_VerkehrsFlaecheBesondererZweckbestimmung" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("BP_Basisobjekte"."BP_Flaechenobjekt");

GRANT SELECT ON TABLE "BP_Verkehr"."BP_VerkehrsFlaecheBesondererZweckbestimmungFlaeche" TO xp_gast;
GRANT ALL ON TABLE "BP_Verkehr"."BP_VerkehrsFlaecheBesondererZweckbestimmungFlaeche" TO bp_user;
CREATE INDEX "BP_VerkehrsFlaecheBesondererZweckbestimmungFlaeche_gidx" ON "BP_Verkehr"."BP_VerkehrsFlaecheBesondererZweckbestimmungFlaeche" using gist ("position");
COMMENT ON COLUMN "BP_Verkehr"."BP_VerkehrsFlaecheBesondererZweckbestimmungFlaeche"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_BP_VerkehrsFlaecheBesondererZweckbestimmungFlaeche" BEFORE INSERT OR UPDATE ON "BP_Verkehr"."BP_VerkehrsFlaecheBesondererZweckbestimmungFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_BP_VerkehrsFlaecheBesondererZweckbestimmungFlaeche" AFTER DELETE ON "BP_Verkehr"."BP_VerkehrsFlaecheBesondererZweckbestimmungFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "flaechenschluss_BP_VerkehrsFlaecheBesondererZweckbestimmungFlaeche" BEFORE INSERT OR UPDATE OR DELETE ON "BP_Verkehr"."BP_VerkehrsFlaecheBesondererZweckbestimmungFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isFlaechenschlussobjekt"();

-- -----------------------------------------------------
-- Table "BP_Verkehr"."BP_VerkehrsFlaecheBesondererZweckbestimmungLinie"
-- -----------------------------------------------------
CREATE TABLE "BP_Verkehr"."BP_VerkehrsFlaecheBesondererZweckbestimmungLinie" (
  "gid" BIGINT NOT NULL,
  PRIMARY KEY ("gid"),
  CONSTRAINT "fk_BP_VerkehrsFlaecheBesondererZweckbestimmungLinie_parent"
    FOREIGN KEY ("gid")
    REFERENCES "BP_Verkehr"."BP_VerkehrsFlaecheBesondererZweckbestimmung" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("BP_Basisobjekte"."BP_Linienobjekt");

GRANT SELECT ON TABLE "BP_Verkehr"."BP_VerkehrsFlaecheBesondererZweckbestimmungLinie" TO xp_gast;
GRANT ALL ON TABLE "BP_Verkehr"."BP_VerkehrsFlaecheBesondererZweckbestimmungLinie" TO bp_user;
CREATE INDEX "BP_VerkehrsFlaecheBesondererZweckbestimmungLinie_gidx" ON "BP_Verkehr"."BP_VerkehrsFlaecheBesondererZweckbestimmungLinie" using gist ("position");
COMMENT ON COLUMN "BP_Verkehr"."BP_VerkehrsFlaecheBesondererZweckbestimmungLinie"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_BP_VerkehrsFlaecheBesondererZweckbestimmungLinie" BEFORE INSERT OR UPDATE ON "BP_Verkehr"."BP_VerkehrsFlaecheBesondererZweckbestimmungLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_BP_VerkehrsFlaecheBesondererZweckbestimmungLinie" AFTER DELETE ON "BP_Verkehr"."BP_VerkehrsFlaecheBesondererZweckbestimmungLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "BP_Verkehr"."BP_VerkehrsFlaecheBesondererZweckbestimmung_begrenzungslinie"
-- -----------------------------------------------------
CREATE TABLE  "BP_Verkehr"."BP_VerkehrsFlaecheBesondererZweckbestimmung_begrenzungslinie" (
  "BP_VerkehrsFlaecheBesondererZweckbestimmung_gid" BIGINT NOT NULL,
  "begrenzungslinie" INTEGER NOT NULL,
  PRIMARY KEY ("BP_VerkehrsFlaecheBesondererZweckbestimmung_gid", "begrenzungslinie"),
  CONSTRAINT "fk_BP_VerkehrsFlaecheBesZweckbest_begrenzungslinie1"
    FOREIGN KEY ("BP_VerkehrsFlaecheBesondererZweckbestimmung_gid")
    REFERENCES "BP_Verkehr"."BP_VerkehrsFlaecheBesondererZweckbestimmung" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_BP_VerkehrsFlaecheBesZweckbest_begrenzungslinie2"
    FOREIGN KEY ("begrenzungslinie")
    REFERENCES "BP_Verkehr"."BP_StrassenbegrenzungsLinie" ("gid")
    ON DELETE NO ACTION
    ON UPDATE CASCADE);

CREATE INDEX "idx_fk_BP_VerkehrsFlaecheBesZweckbest_begrenzungslinie1_idx" ON "BP_Verkehr"."BP_VerkehrsFlaecheBesondererZweckbestimmung_begrenzungslinie" ("begrenzungslinie");
CREATE INDEX "idx_fk_BP_VerkehrsFlaecheBesZweckbest_begrenzungslinie2_idx" ON "BP_Verkehr"."BP_VerkehrsFlaecheBesondererZweckbestimmung_begrenzungslinie" ("BP_VerkehrsFlaecheBesondererZweckbestimmung_gid");
GRANT SELECT ON TABLE "BP_Verkehr"."BP_VerkehrsFlaecheBesondererZweckbestimmung_begrenzungslinie" TO xp_gast;
GRANT ALL ON TABLE "BP_Verkehr"."BP_VerkehrsFlaecheBesondererZweckbestimmung_begrenzungslinie" TO bp_user;
COMMENT ON TABLE  "BP_Verkehr"."BP_VerkehrsFlaecheBesondererZweckbestimmung_begrenzungslinie" IS '';

-- -----------------------------------------------------
-- Table "BP_Ver_und_Entsorgung"."BP_VerEntsorgung"
-- -----------------------------------------------------
CREATE TABLE  "BP_Ver_und_Entsorgung"."BP_VerEntsorgung" (
  "gid" BIGINT NOT NULL,
  "textlicheErgaenzung" VARCHAR(156),
  "zugunstenVon" VARCHAR(64),
  PRIMARY KEY ("gid"),
  CONSTRAINT "fk_BP_VerEntsorgung_parent"
    FOREIGN KEY ("gid")
    REFERENCES "BP_Bebauung"."BP_FestsetzungenBaugebiet" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE);

GRANT SELECT ON TABLE "BP_Ver_und_Entsorgung"."BP_VerEntsorgung" TO xp_gast;
GRANT ALL ON TABLE "BP_Ver_und_Entsorgung"."BP_VerEntsorgung" TO bp_user;
COMMENT ON TABLE  "BP_Ver_und_Entsorgung"."BP_VerEntsorgung" IS 'Flächen und Leitungen für Versorgungsanlagen, für die Abfallentsorgung und Abwasserbeseitigung sowie für Ablagerungen (§9 Abs. 1, Nr. 12, 14 und Abs. 6 BauGB)';
COMMENT ON COLUMN  "BP_Ver_und_Entsorgung"."BP_VerEntsorgung"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN  "BP_Ver_und_Entsorgung"."BP_VerEntsorgung"."textlicheErgaenzung" IS 'Zusätzliche textliche Beschreibung der Ver- bzw. Entsorgungseinrichtung.';
COMMENT ON COLUMN  "BP_Ver_und_Entsorgung"."BP_VerEntsorgung"."zugunstenVon" IS 'Angabe des Begünstigen einer Ausweisung.';
CREATE TRIGGER "change_to_BP_VerEntsorgung" BEFORE INSERT OR UPDATE ON "BP_Ver_und_Entsorgung"."BP_VerEntsorgung" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_BP_VerEntsorgung" AFTER DELETE ON "BP_Ver_und_Entsorgung"."BP_VerEntsorgung" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "BP_Ver_und_Entsorgung"."BP_VerEntsorgungFlaeche"
-- -----------------------------------------------------
CREATE TABLE  "BP_Ver_und_Entsorgung"."BP_VerEntsorgungFlaeche" (
  "gid" BIGINT NOT NULL,
  PRIMARY KEY ("gid"),
  CONSTRAINT "fk_BP_VerEntsorgungFlaeche_parent"
    FOREIGN KEY ("gid")
    REFERENCES "BP_Ver_und_Entsorgung"."BP_VerEntsorgung" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("BP_Basisobjekte"."BP_Flaechenobjekt");

GRANT SELECT ON TABLE "BP_Ver_und_Entsorgung"."BP_VerEntsorgungFlaeche" TO xp_gast;
GRANT ALL ON TABLE "BP_Ver_und_Entsorgung"."BP_VerEntsorgungFlaeche" TO bp_user;
CREATE INDEX "BP_VerEntsorgungFlaeche_gidx" ON "BP_Ver_und_Entsorgung"."BP_VerEntsorgungFlaeche" using gist ("position");
COMMENT ON COLUMN  "BP_Ver_und_Entsorgung"."BP_VerEntsorgungFlaeche"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_BP_VerEntsorgungFlaeche" BEFORE INSERT OR UPDATE ON "BP_Ver_und_Entsorgung"."BP_VerEntsorgungFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_BP_VerEntsorgungFlaeche" AFTER DELETE ON "BP_Ver_und_Entsorgung"."BP_VerEntsorgungFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "BP_VerEntsorgungFlaeche_Flaechenobjekt" BEFORE INSERT OR UPDATE ON "BP_Ver_und_Entsorgung"."BP_VerEntsorgungFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isFlaechenobjekt"();

-- -----------------------------------------------------
-- Table "BP_Ver_und_Entsorgung"."BP_VerEntsorgungLinie"
-- -----------------------------------------------------
CREATE TABLE  "BP_Ver_und_Entsorgung"."BP_VerEntsorgungLinie" (
  "gid" BIGINT NOT NULL,
  PRIMARY KEY ("gid"),
  CONSTRAINT "fk_BP_VerEntsorgungLinie_parent"
    FOREIGN KEY ("gid")
    REFERENCES "BP_Ver_und_Entsorgung"."BP_VerEntsorgung" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("BP_Basisobjekte"."BP_Linienobjekt");

GRANT SELECT ON TABLE "BP_Ver_und_Entsorgung"."BP_VerEntsorgungLinie" TO xp_gast;
GRANT ALL ON TABLE "BP_Ver_und_Entsorgung"."BP_VerEntsorgungLinie" TO bp_user;
CREATE INDEX "BP_VerEntsorgungLinie_gidx" ON "BP_Ver_und_Entsorgung"."BP_VerEntsorgungLinie" using gist ("position");
COMMENT ON COLUMN  "BP_Ver_und_Entsorgung"."BP_VerEntsorgungLinie"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_BP_VerEntsorgungLinie" BEFORE INSERT OR UPDATE ON "BP_Ver_und_Entsorgung"."BP_VerEntsorgungLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_BP_VerEntsorgungLinie" AFTER DELETE ON "BP_Ver_und_Entsorgung"."BP_VerEntsorgungLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "BP_Ver_und_Entsorgung"."BP_VerEntsorgungPunkt"
-- -----------------------------------------------------
CREATE TABLE  "BP_Ver_und_Entsorgung"."BP_VerEntsorgungPunkt" (
  "gid" BIGINT NOT NULL,
  PRIMARY KEY ("gid"),
  CONSTRAINT "fk_BP_VerEntsorgungPunkt_parent"
    FOREIGN KEY ("gid")
    REFERENCES "BP_Ver_und_Entsorgung"."BP_VerEntsorgung" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("BP_Basisobjekte"."BP_Punktobjekt");

GRANT SELECT ON TABLE "BP_Ver_und_Entsorgung"."BP_VerEntsorgungPunkt" TO xp_gast;
GRANT ALL ON TABLE "BP_Ver_und_Entsorgung"."BP_VerEntsorgungPunkt" TO bp_user;
CREATE INDEX "BP_VerEntsorgungPunkt_gidx" ON "BP_Ver_und_Entsorgung"."BP_VerEntsorgungPunkt" using gist ("position");
COMMENT ON COLUMN  "BP_Ver_und_Entsorgung"."BP_VerEntsorgungPunkt"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_BP_VerEntsorgungPunkt" BEFORE INSERT OR UPDATE ON "BP_Ver_und_Entsorgung"."BP_VerEntsorgungPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_BP_VerEntsorgungPunkt" AFTER DELETE ON "BP_Ver_und_Entsorgung"."BP_VerEntsorgungPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "BP_Ver_und_Entsorgung"."BP_VerEntsorgung_zweckbestimmung"
-- -----------------------------------------------------
CREATE TABLE  "BP_Ver_und_Entsorgung"."BP_VerEntsorgung_zweckbestimmung" (
  "BP_VerEntsorgung_gid" BIGINT NOT NULL,
  "zweckbestimmung" INTEGER NOT NULL,
  PRIMARY KEY ("BP_VerEntsorgung_gid", "zweckbestimmung"),
  CONSTRAINT "fk_BP_VerEntsorgung_zweckbestimmung1"
    FOREIGN KEY ("BP_VerEntsorgung_gid")
    REFERENCES "BP_Ver_und_Entsorgung"."BP_VerEntsorgung" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_BP_VerEntsorgung_zweckbestimmung2"
    FOREIGN KEY ("zweckbestimmung")
    REFERENCES "XP_Enumerationen"."XP_ZweckbestimmungVerEntsorgung" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE);

CREATE INDEX "idx_fk_BP_VerEntsorgung_zweckbestimmung1_idx" ON "BP_Ver_und_Entsorgung"."BP_VerEntsorgung_zweckbestimmung" ("zweckbestimmung");
CREATE INDEX "idx_fk_BP_VerEntsorgung_zweckbestimmung2_idx" ON "BP_Ver_und_Entsorgung"."BP_VerEntsorgung_zweckbestimmung" ("BP_VerEntsorgung_gid");
GRANT SELECT ON TABLE "BP_Ver_und_Entsorgung"."BP_VerEntsorgung_zweckbestimmung" TO xp_gast;
GRANT ALL ON TABLE "BP_Ver_und_Entsorgung"."BP_VerEntsorgung_zweckbestimmung" TO bp_user;
COMMENT ON TABLE  "BP_Ver_und_Entsorgung"."BP_VerEntsorgung_zweckbestimmung" IS 'Zweckbestimmung der Fläche';

-- -----------------------------------------------------
-- Table "BP_Ver_und_Entsorgung"."BP_DetailZweckbestVerEntsorgung"
-- -----------------------------------------------------
CREATE TABLE  "BP_Ver_und_Entsorgung"."BP_DetailZweckbestVerEntsorgung" (
  "Code" INTEGER NOT NULL,
  "Bezeichner" VARCHAR(64) NOT NULL,
  PRIMARY KEY ("Code"));

GRANT SELECT ON TABLE "BP_Ver_und_Entsorgung"."BP_DetailZweckbestVerEntsorgung" TO xp_gast;
GRANT ALL ON "BP_Ver_und_Entsorgung"."BP_DetailZweckbestVerEntsorgung" TO bp_user;
CREATE TRIGGER "ins_upd_BP_DetailZweckbestVerEntsorgung" BEFORE INSERT OR UPDATE ON "BP_Ver_und_Entsorgung"."BP_DetailZweckbestVerEntsorgung" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isCodeList"();

-- -----------------------------------------------------
-- Table "BP_Ver_und_Entsorgung"."BP_VerEntsorgung_detaillierteZweckbestimmung"
-- -----------------------------------------------------
CREATE TABLE  "BP_Ver_und_Entsorgung"."BP_VerEntsorgung_detaillierteZweckbestimmung" (
  "BP_VerEntsorgung_gid" BIGINT NOT NULL,
  "detaillierteZweckbestimmung" INTEGER NOT NULL,
  PRIMARY KEY ("BP_VerEntsorgung_gid", "detaillierteZweckbestimmung"),
  CONSTRAINT "fk_BP_VerEntsorgung_detaillierteZweckbestimmung1"
    FOREIGN KEY ("BP_VerEntsorgung_gid")
    REFERENCES "BP_Ver_und_Entsorgung"."BP_VerEntsorgung" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_BP_VerEntsorgung_detaillierteZweckbestimmung2"
    FOREIGN KEY ("detaillierteZweckbestimmung")
    REFERENCES "BP_Ver_und_Entsorgung"."BP_DetailZweckbestVerEntsorgung" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE);

CREATE INDEX "idx_fk_BP_VerEntsorgung_detaillierteZweckbestimmung1_idx" ON "BP_Ver_und_Entsorgung"."BP_VerEntsorgung_detaillierteZweckbestimmung" ("detaillierteZweckbestimmung");
CREATE INDEX "idx_fk_BP_VerEntsorgung_detaillierteZweckbestimmung2_idx" ON "BP_Ver_und_Entsorgung"."BP_VerEntsorgung_detaillierteZweckbestimmung" ("BP_VerEntsorgung_gid");
GRANT SELECT ON TABLE "BP_Ver_und_Entsorgung"."BP_VerEntsorgung_detaillierteZweckbestimmung" TO xp_gast;
GRANT ALL ON TABLE "BP_Ver_und_Entsorgung"."BP_VerEntsorgung_detaillierteZweckbestimmung" TO bp_user;
COMMENT ON TABLE  "BP_Ver_und_Entsorgung"."BP_VerEntsorgung_detaillierteZweckbestimmung" IS 'Über eine CodeList definierte zusätzliche Zweckbestimmungen.';


-- *****************************************************
-- CREATE VIEWs
-- *****************************************************

-- -----------------------------------------------------
-- View "BP_Basisobjekte"."BP_Punktobjekte"
-- -----------------------------------------------------
CREATE  OR REPLACE VIEW "BP_Basisobjekte"."BP_Punktobjekte" AS
SELECT g.*, CAST(c.relname as varchar) as "Objektart",
CAST(n.nspname as varchar) as "Objektartengruppe"
FROM  "BP_Basisobjekte"."BP_Punktobjekt" g
JOIN pg_class c ON g.tableoid = c.oid
JOIN pg_namespace n ON c.relnamespace = n.oid;

GRANT SELECT ON TABLE "BP_Basisobjekte"."BP_Punktobjekte" TO xp_gast;
GRANT ALL ON TABLE "BP_Basisobjekte"."BP_Punktobjekte" TO bp_user;

CREATE OR REPLACE RULE _update AS
    ON UPDATE TO "BP_Basisobjekte"."BP_Punktobjekte" DO INSTEAD  UPDATE "BP_Basisobjekte"."BP_Punktobjekt" SET "position" = new."position"
  WHERE gid = old.gid;
CREATE OR REPLACE RULE _delete AS
    ON DELETE TO "BP_Basisobjekte"."BP_Punktobjekte" DO INSTEAD  DELETE FROM "BP_Basisobjekte"."BP_Punktobjekt"
  WHERE gid = old.gid;

-- -----------------------------------------------------
-- View "BP_Basisobjekte"."BP_Linienobjekte"
-- -----------------------------------------------------
CREATE  OR REPLACE VIEW "BP_Basisobjekte"."BP_Linienobjekte" AS
SELECT g.*, CAST(c.relname as varchar) as "Objektart",
CAST(n.nspname as varchar) as "Objektartengruppe"
FROM  "BP_Basisobjekte"."BP_Linienobjekt" g
JOIN pg_class c ON g.tableoid = c.oid
JOIN pg_namespace n ON c.relnamespace = n.oid;

GRANT SELECT ON TABLE "BP_Basisobjekte"."BP_Linienobjekte" TO xp_gast;
GRANT ALL ON TABLE "BP_Basisobjekte"."BP_Linienobjekte" TO bp_user;

CREATE OR REPLACE RULE _update AS
    ON UPDATE TO "BP_Basisobjekte"."BP_Linienobjekte" DO INSTEAD  UPDATE "BP_Basisobjekte"."BP_Linienobjekt" SET "position" = new."position"
  WHERE gid = old.gid;
CREATE OR REPLACE RULE _delete AS
    ON DELETE TO "BP_Basisobjekte"."BP_Linienobjekte" DO INSTEAD  DELETE FROM "BP_Basisobjekte"."BP_Linienobjekt"
  WHERE gid = old.gid;

-- -----------------------------------------------------
-- View "BP_Basisobjekte"."BP_Flaechenobjekte"
-- -----------------------------------------------------
CREATE  OR REPLACE VIEW "BP_Basisobjekte"."BP_Flaechenobjekte" AS
SELECT g.*, CAST(c.relname as varchar) as "Objektart",
CAST(n.nspname as varchar) as "Objektartengruppe"
FROM  "BP_Basisobjekte"."BP_Flaechenobjekt" g
JOIN pg_class c ON g.tableoid = c.oid
JOIN pg_namespace n ON c.relnamespace = n.oid;

GRANT SELECT ON TABLE "BP_Basisobjekte"."BP_Flaechenobjekte" TO xp_gast;
GRANT ALL ON TABLE "BP_Basisobjekte"."BP_Flaechenobjekte" TO bp_user;

CREATE OR REPLACE RULE _update AS
    ON UPDATE TO "BP_Basisobjekte"."BP_Flaechenobjekte" DO INSTEAD  UPDATE "BP_Basisobjekte"."BP_Flaechenobjekt" SET "position" = new."position"
  WHERE gid = old.gid;
CREATE OR REPLACE RULE _delete AS
    ON DELETE TO "BP_Basisobjekte"."BP_Flaechenobjekte" DO INSTEAD  DELETE FROM "BP_Basisobjekte"."BP_Flaechenobjekt"
  WHERE gid = old.gid;

-- -----------------------------------------------------
-- View "BP_Basisobjekte"."BP_Objekte"
-- -----------------------------------------------------
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

-- *****************************************************
-- INSERT DATA
-- *****************************************************

-- -----------------------------------------------------
-- Data for table public."XP_Modellbereich"
-- -----------------------------------------------------
INSERT INTO public."XP_Modellbereich" ("Kurz", "Modellbereich") VALUES ('BP', 'Bebauungsplan');

-- -----------------------------------------------------
-- Defaultwert "BP_Laerm"."BP_Richtungssektor"
-- -----------------------------------------------------
INSERT INTO "BP_Laerm"."BP_Richtungssektor" ("id") VALUES (1);

-- -----------------------------------------------------
-- Data for table "BP_Basisobjekte"."BP_Verfahren"
-- -----------------------------------------------------
INSERT INTO "BP_Basisobjekte"."BP_Verfahren" ("Code", "Bezeichner") VALUES ('1000', 'Normal');
INSERT INTO "BP_Basisobjekte"."BP_Verfahren" ("Code", "Bezeichner") VALUES ('2000', 'Parag13');
INSERT INTO "BP_Basisobjekte"."BP_Verfahren" ("Code", "Bezeichner") VALUES ('3000', 'Parag13a');
INSERT INTO "BP_Basisobjekte"."BP_Verfahren" ("Code", "Bezeichner") VALUES ('4000', 'Parag13b');

-- -----------------------------------------------------
-- Data for table "BP_Basisobjekte"."BP_Rechtsstand"
-- -----------------------------------------------------
INSERT INTO "BP_Basisobjekte"."BP_Rechtsstand" ("Code", "Bezeichner") VALUES ('1000', 'Aufstellungsbeschluss');
INSERT INTO "BP_Basisobjekte"."BP_Rechtsstand" ("Code", "Bezeichner") VALUES ('2000', 'Entwurf');
INSERT INTO "BP_Basisobjekte"."BP_Rechtsstand" ("Code", "Bezeichner") VALUES ('2100', 'FruehzeitigeBehoerdenBeteiligung');
INSERT INTO "BP_Basisobjekte"."BP_Rechtsstand" ("Code", "Bezeichner") VALUES ('2200', 'FruehzeitigeOeffentlichkeitsBeteiligung');
INSERT INTO "BP_Basisobjekte"."BP_Rechtsstand" ("Code", "Bezeichner") VALUES ('2300', 'BehoerdenBeteiligung');
INSERT INTO "BP_Basisobjekte"."BP_Rechtsstand" ("Code", "Bezeichner") VALUES ('2400', 'OeffentlicheAuslegung');
INSERT INTO "BP_Basisobjekte"."BP_Rechtsstand" ("Code", "Bezeichner") VALUES ('3000', 'Satzung');
INSERT INTO "BP_Basisobjekte"."BP_Rechtsstand" ("Code", "Bezeichner") VALUES ('4000', 'InkraftGetreten');
INSERT INTO "BP_Basisobjekte"."BP_Rechtsstand" ("Code", "Bezeichner") VALUES ('4500', 'TeilweiseUntergegangen');
INSERT INTO "BP_Basisobjekte"."BP_Rechtsstand" ("Code", "Bezeichner") VALUES ('5000', 'Untergegangen');

-- -----------------------------------------------------
-- Data for table "BP_Basisobjekte"."BP_PlanArt"
-- -----------------------------------------------------
INSERT INTO "BP_Basisobjekte"."BP_PlanArt" ("Code", "Bezeichner") VALUES ('1000', 'BPlan');
INSERT INTO "BP_Basisobjekte"."BP_PlanArt" ("Code", "Bezeichner") VALUES ('10000', 'EinfacherBPlan');
INSERT INTO "BP_Basisobjekte"."BP_PlanArt" ("Code", "Bezeichner") VALUES ('10001', 'QualifizierterBPlan');
INSERT INTO "BP_Basisobjekte"."BP_PlanArt" ("Code", "Bezeichner") VALUES ('3000', 'VorhabenbezogenerBPlan');
INSERT INTO "BP_Basisobjekte"."BP_PlanArt" ("Code", "Bezeichner") VALUES ('3100', 'VorhabenUndErschliessungsplan');
INSERT INTO "BP_Basisobjekte"."BP_PlanArt" ("Code", "Bezeichner") VALUES ('4000', 'InnenbereichsSatzung');
INSERT INTO "BP_Basisobjekte"."BP_PlanArt" ("Code", "Bezeichner") VALUES ('40000', 'KlarstellungsSatzung');
INSERT INTO "BP_Basisobjekte"."BP_PlanArt" ("Code", "Bezeichner") VALUES ('40001', 'EntwicklungsSatzung');
INSERT INTO "BP_Basisobjekte"."BP_PlanArt" ("Code", "Bezeichner") VALUES ('40002', 'ErgaenzungsSatzung');
INSERT INTO "BP_Basisobjekte"."BP_PlanArt" ("Code", "Bezeichner") VALUES ('5000', 'AussenbereichsSatzung');
INSERT INTO "BP_Basisobjekte"."BP_PlanArt" ("Code", "Bezeichner") VALUES ('7000', 'OertlicheBauvorschrift');
INSERT INTO "BP_Basisobjekte"."BP_PlanArt" ("Code", "Bezeichner") VALUES ('9999', 'Sonstiges');

-- -----------------------------------------------------
-- Data for table "BP_Basisobjekte"."BP_Rechtscharakter"
-- -----------------------------------------------------
INSERT INTO "BP_Basisobjekte"."BP_Rechtscharakter" ("Code", "Bezeichner") VALUES ('1000', 'Festsetzung');
INSERT INTO "BP_Basisobjekte"."BP_Rechtscharakter" ("Code", "Bezeichner") VALUES ('2000', 'NachrichtlicheUebernahme');
INSERT INTO "BP_Basisobjekte"."BP_Rechtscharakter" ("Code", "Bezeichner") VALUES ('3000', 'Hinweis');
INSERT INTO "BP_Basisobjekte"."BP_Rechtscharakter" ("Code", "Bezeichner") VALUES ('4000', 'Vermerk');
INSERT INTO "BP_Basisobjekte"."BP_Rechtscharakter" ("Code", "Bezeichner") VALUES ('5000', 'Kennzeichnung');
INSERT INTO "BP_Basisobjekte"."BP_Rechtscharakter" ("Code", "Bezeichner") VALUES ('9998', 'Unbekannt');

-- -----------------------------------------------------
-- Data for table "BP_Verkehr"."BP_StrassenkoerperHerstellung"
-- -----------------------------------------------------
INSERT INTO "BP_Verkehr"."BP_StrassenkoerperHerstellung" ("Code", "Bezeichner") VALUES ('1000', 'Aufschuettung');
INSERT INTO "BP_Verkehr"."BP_StrassenkoerperHerstellung" ("Code", "Bezeichner") VALUES ('2000', 'Abgrabung');
INSERT INTO "BP_Verkehr"."BP_StrassenkoerperHerstellung" ("Code", "Bezeichner") VALUES ('3000', 'Stuetzmauer');

-- -----------------------------------------------------
-- Data for table "BP_Verkehr"."BP_BereichOhneEinAusfahrtTypen"
-- -----------------------------------------------------
INSERT INTO "BP_Verkehr"."BP_BereichOhneEinAusfahrtTypen" ("Code", "Bezeichner") VALUES ('1000', 'KeineEinfahrt');
INSERT INTO "BP_Verkehr"."BP_BereichOhneEinAusfahrtTypen" ("Code", "Bezeichner") VALUES ('2000', 'KeineAusfahrt');
INSERT INTO "BP_Verkehr"."BP_BereichOhneEinAusfahrtTypen" ("Code", "Bezeichner") VALUES ('3000', 'KeineEinAusfahrt');

-- -----------------------------------------------------
-- Data for table "BP_Erhaltungssatzung_und_Denkmalschutz"."BP_ErhaltungsGrund"
-- -----------------------------------------------------
INSERT INTO "BP_Erhaltungssatzung_und_Denkmalschutz"."BP_ErhaltungsGrund" ("Code", "Bezeichner") VALUES ('1000', 'StaedtebaulicheGestalt');
INSERT INTO "BP_Erhaltungssatzung_und_Denkmalschutz"."BP_ErhaltungsGrund" ("Code", "Bezeichner") VALUES ('2000', 'Wohnbevoelkerung');
INSERT INTO "BP_Erhaltungssatzung_und_Denkmalschutz"."BP_ErhaltungsGrund" ("Code", "Bezeichner") VALUES ('3000', 'Umstrukturierung');

-- -----------------------------------------------------
-- Data for table "BP_Sonstiges"."BP_AbgrenzungenTypen"
-- -----------------------------------------------------
INSERT INTO "BP_Sonstiges"."BP_AbgrenzungenTypen" ("Code", "Bezeichner") VALUES ('1000', 'Nutzungsartengrenze');
INSERT INTO "BP_Sonstiges"."BP_AbgrenzungenTypen" ("Code", "Bezeichner") VALUES ('2000', 'UnterschiedlicheHoehen');
INSERT INTO "BP_Sonstiges"."BP_AbgrenzungenTypen" ("Code", "Bezeichner") VALUES ('9999', 'SonstigeAbgrenzung');

-- -----------------------------------------------------
-- Data for table "BP_Sonstiges"."BP_AbstandsMassTypen"
-- -----------------------------------------------------
INSERT INTO "BP_Sonstiges"."BP_AbstandsMassTypen" ("Code", "Bezeichner") VALUES ('1000', 'Masspfeil');
INSERT INTO "BP_Sonstiges"."BP_AbstandsMassTypen" ("Code", "Bezeichner") VALUES ('2000', 'Masskreis');

-- -----------------------------------------------------
-- Data for table "BP_Sonstiges"."BP_WegerechtTypen"
-- -----------------------------------------------------
INSERT INTO "BP_Sonstiges"."BP_WegerechtTypen" ("Code", "Bezeichner") VALUES ('1000', 'Gehrecht');
INSERT INTO "BP_Sonstiges"."BP_WegerechtTypen" ("Code", "Bezeichner") VALUES ('2000', 'Fahrrecht');
INSERT INTO "BP_Sonstiges"."BP_WegerechtTypen" ("Code", "Bezeichner") VALUES ('2500', 'Radfahrrecht');
INSERT INTO "BP_Sonstiges"."BP_WegerechtTypen" ("Code", "Bezeichner") VALUES ('3000', 'GehFahrrecht');
INSERT INTO "BP_Sonstiges"."BP_WegerechtTypen" ("Code", "Bezeichner") VALUES ('4000', 'Leitungsrecht');
INSERT INTO "BP_Sonstiges"."BP_WegerechtTypen" ("Code", "Bezeichner") VALUES ('4100', 'GehLeitungsrecht');
INSERT INTO "BP_Sonstiges"."BP_WegerechtTypen" ("Code", "Bezeichner") VALUES ('4200', 'FahrLeitungsrecht');
INSERT INTO "BP_Sonstiges"."BP_WegerechtTypen" ("Code", "Bezeichner") VALUES ('5000', 'GehFahrLeitungsrecht');
INSERT INTO "BP_Sonstiges"."BP_WegerechtTypen" ("Code", "Bezeichner") VALUES ('9999', 'Sonstiges');

-- -----------------------------------------------------
-- Data for table "BP_Bebauung"."BP_Bauweise"
-- -----------------------------------------------------
INSERT INTO "BP_Bebauung"."BP_Bauweise" ("Code", "Bezeichner") VALUES (1000, 'OffeneBauweise');
INSERT INTO "BP_Bebauung"."BP_Bauweise" ("Code", "Bezeichner") VALUES (2000, 'GeschlosseneBauweise');
INSERT INTO "BP_Bebauung"."BP_Bauweise" ("Code", "Bezeichner") VALUES (3000, 'AbweichendeBauweise');

-- -----------------------------------------------------
-- Data for table "BP_Bebauung"."BP_BebauungsArt"
-- -----------------------------------------------------
INSERT INTO "BP_Bebauung"."BP_BebauungsArt" ("Code", "Bezeichner") VALUES (1000, 'Einzelhaeuser');
INSERT INTO "BP_Bebauung"."BP_BebauungsArt" ("Code", "Bezeichner") VALUES (2000, 'Doppelhaeuser');
INSERT INTO "BP_Bebauung"."BP_BebauungsArt" ("Code", "Bezeichner") VALUES (3000, 'Hausgruppen');
INSERT INTO "BP_Bebauung"."BP_BebauungsArt" ("Code", "Bezeichner") VALUES (4000, 'EinzelDopplehaeuser');
INSERT INTO "BP_Bebauung"."BP_BebauungsArt" ("Code", "Bezeichner") VALUES (5000, 'EinzelhaeuserHausgruppen');
INSERT INTO "BP_Bebauung"."BP_BebauungsArt" ("Code", "Bezeichner") VALUES (6000, 'DoppelhaeuserHausgruppen');
INSERT INTO "BP_Bebauung"."BP_BebauungsArt" ("Code", "Bezeichner") VALUES (7000, 'Reihenhaeuser');
INSERT INTO "BP_Bebauung"."BP_BebauungsArt" ("Code", "Bezeichner") VALUES (8000, 'EinzelhaeuserDoppelhaeuserHausgruppen');

-- -----------------------------------------------------
-- Data for table "BP_Bebauung"."BP_GrenzBebauung"
-- -----------------------------------------------------
INSERT INTO "BP_Bebauung"."BP_GrenzBebauung" ("Code", "Bezeichner") VALUES (1000, 'Verboten');
INSERT INTO "BP_Bebauung"."BP_GrenzBebauung" ("Code", "Bezeichner") VALUES (2000, 'Erlaubt');
INSERT INTO "BP_Bebauung"."BP_GrenzBebauung" ("Code", "Bezeichner") VALUES (3000, 'Erzwungen');

-- -----------------------------------------------------
-- Data for table "BP_Bebauung"."BP_Dachform"
-- -----------------------------------------------------
INSERT INTO "BP_Bebauung"."BP_Dachform" ("Code", "Bezeichner") VALUES (1000, 'Flachdach');
INSERT INTO "BP_Bebauung"."BP_Dachform" ("Code", "Bezeichner") VALUES (2100, 'Pultdach');
INSERT INTO "BP_Bebauung"."BP_Dachform" ("Code", "Bezeichner") VALUES (2200, 'Versetztes Pultdach');
INSERT INTO "BP_Bebauung"."BP_Dachform" ("Code", "Bezeichner") VALUES (3000, 'GeneigtesDach');
INSERT INTO "BP_Bebauung"."BP_Dachform" ("Code", "Bezeichner") VALUES (3100, 'Satteldach');
INSERT INTO "BP_Bebauung"."BP_Dachform" ("Code", "Bezeichner") VALUES (3200, 'Walmdach');
INSERT INTO "BP_Bebauung"."BP_Dachform" ("Code", "Bezeichner") VALUES (3300, 'Krüppelwalmdach');
INSERT INTO "BP_Bebauung"."BP_Dachform" ("Code", "Bezeichner") VALUES (3400, 'Masarddach');
INSERT INTO "BP_Bebauung"."BP_Dachform" ("Code", "Bezeichner") VALUES (3500, 'Zeltdach');
INSERT INTO "BP_Bebauung"."BP_Dachform" ("Code", "Bezeichner") VALUES (3600, 'Kegeldach');
INSERT INTO "BP_Bebauung"."BP_Dachform" ("Code", "Bezeichner") VALUES (3700, 'Kuppeldach');
INSERT INTO "BP_Bebauung"."BP_Dachform" ("Code", "Bezeichner") VALUES (3800, 'Sheddach');
INSERT INTO "BP_Bebauung"."BP_Dachform" ("Code", "Bezeichner") VALUES (3900, 'Bogendach');
INSERT INTO "BP_Bebauung"."BP_Dachform" ("Code", "Bezeichner") VALUES (4000, 'Turmdach');
INSERT INTO "BP_Bebauung"."BP_Dachform" ("Code", "Bezeichner") VALUES (4100, 'Tonnendach');
INSERT INTO "BP_Bebauung"."BP_Dachform" ("Code", "Bezeichner") VALUES (5000, 'Mischform');
INSERT INTO "BP_Bebauung"."BP_Dachform" ("Code", "Bezeichner") VALUES (9999, 'Sonstiges');

-- -----------------------------------------------------
-- Data for table "BP_Bebauung"."BP_ZweckbestimmungGemeinschaftsanlagen"
-- -----------------------------------------------------
INSERT INTO "BP_Bebauung"."BP_ZweckbestimmungGemeinschaftsanlagen" ("Code", "Bezeichner") VALUES (1000, 'Gemeinschaftsstellplaetze');
INSERT INTO "BP_Bebauung"."BP_ZweckbestimmungGemeinschaftsanlagen" ("Code", "Bezeichner") VALUES (2000, 'Gemeinschaftsgaragen');
INSERT INTO "BP_Bebauung"."BP_ZweckbestimmungGemeinschaftsanlagen" ("Code", "Bezeichner") VALUES (3000, 'Spielplatz');
INSERT INTO "BP_Bebauung"."BP_ZweckbestimmungGemeinschaftsanlagen" ("Code", "Bezeichner") VALUES (3100, 'Carport');
INSERT INTO "BP_Bebauung"."BP_ZweckbestimmungGemeinschaftsanlagen" ("Code", "Bezeichner") VALUES (3200, 'GemeinschaftsTiefgarage');
INSERT INTO "BP_Bebauung"."BP_ZweckbestimmungGemeinschaftsanlagen" ("Code", "Bezeichner") VALUES (3300, 'Nebengebaeude');
INSERT INTO "BP_Bebauung"."BP_ZweckbestimmungGemeinschaftsanlagen" ("Code", "Bezeichner") VALUES (3400, 'AbfallSammelanlagen');
INSERT INTO "BP_Bebauung"."BP_ZweckbestimmungGemeinschaftsanlagen" ("Code", "Bezeichner") VALUES (3500, 'EnergieVerteilungsanlagen');
INSERT INTO "BP_Bebauung"."BP_ZweckbestimmungGemeinschaftsanlagen" ("Code", "Bezeichner") VALUES (3600, 'AbfallWertstoffbehaelter');
INSERT INTO "BP_Bebauung"."BP_ZweckbestimmungGemeinschaftsanlagen" ("Code", "Bezeichner") VALUES (3700, 'Freizeiteinrichtungen');
INSERT INTO "BP_Bebauung"."BP_ZweckbestimmungGemeinschaftsanlagen" ("Code", "Bezeichner") VALUES (3800, 'Laermschutzanlagen');
INSERT INTO "BP_Bebauung"."BP_ZweckbestimmungGemeinschaftsanlagen" ("Code", "Bezeichner") VALUES (3900, 'AbwasserRegenwasser');
INSERT INTO "BP_Bebauung"."BP_ZweckbestimmungGemeinschaftsanlagen" ("Code", "Bezeichner") VALUES (4000, 'Ausgleichsmassnahmen');
INSERT INTO "BP_Bebauung"."BP_ZweckbestimmungGemeinschaftsanlagen" ("Code", "Bezeichner") VALUES (4100, 'Fahrradstellplaetze');
INSERT INTO "BP_Bebauung"."BP_ZweckbestimmungGemeinschaftsanlagen" ("Code", "Bezeichner") VALUES (4200, 'Gemeinschaftsdachgaerten');
INSERT INTO "BP_Bebauung"."BP_ZweckbestimmungGemeinschaftsanlagen" ("Code", "Bezeichner") VALUES (4300, 'GemeinschaftlichNutzbareDachflaechen');
INSERT INTO "BP_Bebauung"."BP_ZweckbestimmungGemeinschaftsanlagen" ("Code", "Bezeichner") VALUES (9999, 'Sonstiges');

-- -----------------------------------------------------
-- Data for table "BP_Bebauung"."BP_NebenanlangenAusschlussTyp"
-- -----------------------------------------------------
INSERT INTO "BP_Bebauung"."BP_NebenanlangenAusschlussTyp" ("Code", "Bezeichner") VALUES (1000, 'Einschraenkung');
INSERT INTO "BP_Bebauung"."BP_NebenanlangenAusschlussTyp" ("Code", "Bezeichner") VALUES (2000, 'Ausschluss');

-- -----------------------------------------------------
-- Data for table "BP_Bebauung"."BP_Zulaessigkeit"
-- -----------------------------------------------------
INSERT INTO "BP_Bebauung"."BP_Zulaessigkeit" ("Code", "Bezeichner") VALUES (1000, 'Zulaessig');
INSERT INTO "BP_Bebauung"."BP_Zulaessigkeit" ("Code", "Bezeichner") VALUES (2000, 'NichtZulaessig');
INSERT INTO "BP_Bebauung"."BP_Zulaessigkeit" ("Code", "Bezeichner") VALUES (3000, 'AusnahmsweiseZulaessig');

-- -----------------------------------------------------
-- Data for table "BP_Bebauung"."BP_ZweckbestimmungNebenanlagen"
-- -----------------------------------------------------
INSERT INTO "BP_Bebauung"."BP_ZweckbestimmungNebenanlagen" ("Code", "Bezeichner") VALUES (1000, 'Stellplaetze');
INSERT INTO "BP_Bebauung"."BP_ZweckbestimmungNebenanlagen" ("Code", "Bezeichner") VALUES (2000, 'Garagen');
INSERT INTO "BP_Bebauung"."BP_ZweckbestimmungNebenanlagen" ("Code", "Bezeichner") VALUES (3000, 'Spielplatz');
INSERT INTO "BP_Bebauung"."BP_ZweckbestimmungNebenanlagen" ("Code", "Bezeichner") VALUES (3100, 'Carport');
INSERT INTO "BP_Bebauung"."BP_ZweckbestimmungNebenanlagen" ("Code", "Bezeichner") VALUES (3200, 'Tiefgarage');
INSERT INTO "BP_Bebauung"."BP_ZweckbestimmungNebenanlagen" ("Code", "Bezeichner") VALUES (3300, 'Nebengebaeude');
INSERT INTO "BP_Bebauung"."BP_ZweckbestimmungNebenanlagen" ("Code", "Bezeichner") VALUES (3400, 'AbfallSammelanlagen');
INSERT INTO "BP_Bebauung"."BP_ZweckbestimmungNebenanlagen" ("Code", "Bezeichner") VALUES (3500, 'EnergieVerteilungsanlagen');
INSERT INTO "BP_Bebauung"."BP_ZweckbestimmungNebenanlagen" ("Code", "Bezeichner") VALUES (3600, 'AbfallWertstoffbehaelter');
INSERT INTO "BP_Bebauung"."BP_ZweckbestimmungNebenanlagen" ("Code", "Bezeichner") VALUES (3700, 'Fahrradstellplaetze');
INSERT INTO "BP_Bebauung"."BP_ZweckbestimmungNebenanlagen" ("Code", "Bezeichner") VALUES (9999, 'Sonstiges');

-- -----------------------------------------------------
-- Data for table "BP_Bebauung"."BP_ZulaessigkeitVergnuegungsstaetten"
-- -----------------------------------------------------
INSERT INTO "BP_Bebauung"."BP_ZulaessigkeitVergnuegungsstaetten" ("Code", "Bezeichner") VALUES (1000, 'Zulaessig');
INSERT INTO "BP_Bebauung"."BP_ZulaessigkeitVergnuegungsstaetten" ("Code", "Bezeichner") VALUES (2000, 'NichtZulaessig');
INSERT INTO "BP_Bebauung"."BP_ZulaessigkeitVergnuegungsstaetten" ("Code", "Bezeichner") VALUES (3000, 'AusnahmsweiseZulaessig');

-- -----------------------------------------------------
-- Data for table "BP_Bebauung"."BP_SpezielleBauweiseTypen"
-- -----------------------------------------------------
INSERT INTO "BP_Bebauung"."BP_SpezielleBauweiseTypen" ("Code", "Bezeichner") VALUES (1000, 'Durchfahrt');
INSERT INTO "BP_Bebauung"."BP_SpezielleBauweiseTypen" ("Code", "Bezeichner") VALUES (1100, 'Durchgang');
INSERT INTO "BP_Bebauung"."BP_SpezielleBauweiseTypen" ("Code", "Bezeichner") VALUES (1200, 'DurchfahrtDurchgang');
INSERT INTO "BP_Bebauung"."BP_SpezielleBauweiseTypen" ("Code", "Bezeichner") VALUES (1300, 'Auskragung');
INSERT INTO "BP_Bebauung"."BP_SpezielleBauweiseTypen" ("Code", "Bezeichner") VALUES (1400, 'Arkade');
INSERT INTO "BP_Bebauung"."BP_SpezielleBauweiseTypen" ("Code", "Bezeichner") VALUES (1500, 'Luftgeschoss');
INSERT INTO "BP_Bebauung"."BP_SpezielleBauweiseTypen" ("Code", "Bezeichner") VALUES (1600, 'Bruecke');
INSERT INTO "BP_Bebauung"."BP_SpezielleBauweiseTypen" ("Code", "Bezeichner") VALUES (1700, 'Tunnel');
INSERT INTO "BP_Bebauung"."BP_SpezielleBauweiseTypen" ("Code", "Bezeichner") VALUES (1800, 'Rampe');
INSERT INTO "BP_Bebauung"."BP_SpezielleBauweiseTypen" ("Code", "Bezeichner") VALUES (9999, 'Sonstiges');

-- -----------------------------------------------------
-- Data for table "BP_Verkehr"."BP_ZweckbestimmungStrassenverkehr"
-- -----------------------------------------------------
INSERT INTO "BP_Verkehr"."BP_ZweckbestimmungStrassenverkehr" ("Code", "Bezeichner") VALUES (1000, 'Parkplatz');
INSERT INTO "BP_Verkehr"."BP_ZweckbestimmungStrassenverkehr" ("Code", "Bezeichner") VALUES (1100, 'Fussgaengerbereich');
INSERT INTO "BP_Verkehr"."BP_ZweckbestimmungStrassenverkehr" ("Code", "Bezeichner") VALUES (1200, 'VerkehrsberuhigterBereich');
INSERT INTO "BP_Verkehr"."BP_ZweckbestimmungStrassenverkehr" ("Code", "Bezeichner") VALUES (1300, 'RadGehweg');
INSERT INTO "BP_Verkehr"."BP_ZweckbestimmungStrassenverkehr" ("Code", "Bezeichner") VALUES (1400, 'Radweg');
INSERT INTO "BP_Verkehr"."BP_ZweckbestimmungStrassenverkehr" ("Code", "Bezeichner") VALUES (1500, 'Gehweg');
INSERT INTO "BP_Verkehr"."BP_ZweckbestimmungStrassenverkehr" ("Code", "Bezeichner") VALUES (1550, 'Wanderweg');
INSERT INTO "BP_Verkehr"."BP_ZweckbestimmungStrassenverkehr" ("Code", "Bezeichner") VALUES (1560, 'ReitKutschweg');
INSERT INTO "BP_Verkehr"."BP_ZweckbestimmungStrassenverkehr" ("Code", "Bezeichner") VALUES (1580, 'Wirtschaftsweg');
INSERT INTO "BP_Verkehr"."BP_ZweckbestimmungStrassenverkehr" ("Code", "Bezeichner") VALUES (1600, 'FahrradAbstellplatz');
INSERT INTO "BP_Verkehr"."BP_ZweckbestimmungStrassenverkehr" ("Code", "Bezeichner") VALUES (1700, 'UeberfuehrenderVerkehrsweg');
INSERT INTO "BP_Verkehr"."BP_ZweckbestimmungStrassenverkehr" ("Code", "Bezeichner") VALUES (1800, 'UnterfuehrenderVerkehrsweg');
INSERT INTO "BP_Verkehr"."BP_ZweckbestimmungStrassenverkehr" ("Code", "Bezeichner") VALUES (2000, 'P_RAnlage');
INSERT INTO "BP_Verkehr"."BP_ZweckbestimmungStrassenverkehr" ("Code", "Bezeichner") VALUES (2100, 'Platz');
INSERT INTO "BP_Verkehr"."BP_ZweckbestimmungStrassenverkehr" ("Code", "Bezeichner") VALUES (2200, 'Anschlussflaeche');
INSERT INTO "BP_Verkehr"."BP_ZweckbestimmungStrassenverkehr" ("Code", "Bezeichner") VALUES (2300, 'LandwirtschaftlicherVerkehr');
INSERT INTO "BP_Verkehr"."BP_ZweckbestimmungStrassenverkehr" ("Code", "Bezeichner") VALUES (2400, 'Verkehrsgruen');
INSERT INTO "BP_Verkehr"."BP_ZweckbestimmungStrassenverkehr" ("Code", "Bezeichner") VALUES (2500, 'Rastanlage');
INSERT INTO "BP_Verkehr"."BP_ZweckbestimmungStrassenverkehr" ("Code", "Bezeichner") VALUES (2600, 'Busbahnhof');
INSERT INTO "BP_Verkehr"."BP_ZweckbestimmungStrassenverkehr" ("Code", "Bezeichner") VALUES (3000, 'CarSharing');
INSERT INTO "BP_Verkehr"."BP_ZweckbestimmungStrassenverkehr" ("Code", "Bezeichner") VALUES (3100, 'BikeSharing');
INSERT INTO "BP_Verkehr"."BP_ZweckbestimmungStrassenverkehr" ("Code", "Bezeichner") VALUES (3200, 'B_RAnlage');
INSERT INTO "BP_Verkehr"."BP_ZweckbestimmungStrassenverkehr" ("Code", "Bezeichner") VALUES (3300, 'Parkhaus');
INSERT INTO "BP_Verkehr"."BP_ZweckbestimmungStrassenverkehr" ("Code", "Bezeichner") VALUES (3400, 'Mischverkehrsflaeche');
INSERT INTO "BP_Verkehr"."BP_ZweckbestimmungStrassenverkehr" ("Code", "Bezeichner") VALUES (3500, 'Ladestation');
INSERT INTO "BP_Verkehr"."BP_ZweckbestimmungStrassenverkehr" ("Code", "Bezeichner") VALUES (9999, 'Sonstiges');

-- -----------------------------------------------------
-- Data for table "BP_Verkehr"."BP_EinfahrtTypen"
-- -----------------------------------------------------
INSERT INTO "BP_Verkehr"."BP_EinfahrtTypen" ("Code", "Bezeichner") VALUES (1000, 'Einfahrt');
INSERT INTO "BP_Verkehr"."BP_EinfahrtTypen" ("Code", "Bezeichner") VALUES (2000, 'Ausfahrt');
INSERT INTO "BP_Verkehr"."BP_EinfahrtTypen" ("Code", "Bezeichner") VALUES (3000, 'EinAusfahrt');

-- -----------------------------------------------------
-- Data for table "BP_Umwelt"."BP_ZweckbestimmungenTMF"
-- -----------------------------------------------------
INSERT INTO "BP_Umwelt"."BP_ZweckbestimmungenTMF" ("Code", "Bezeichner") VALUES (1000, 'Luftreinhaltung');
INSERT INTO "BP_Umwelt"."BP_ZweckbestimmungenTMF" ("Code", "Bezeichner") VALUES (2000, 'NutzungErneurerbarerEnergien');
INSERT INTO "BP_Umwelt"."BP_ZweckbestimmungenTMF" ("Code", "Bezeichner") VALUES (3000, 'MinderungStoerfallfolgen');

-- -----------------------------------------------------
-- Data for table "BP_Basisobjekte"."BP_Laermpegelbereich"
-- -----------------------------------------------------
INSERT INTO "BP_Umwelt"."BP_Laermpegelbereich" ("Code", "Bezeichner") VALUES (1000, 'I');
INSERT INTO "BP_Umwelt"."BP_Laermpegelbereich" ("Code", "Bezeichner") VALUES (1100, 'II');
INSERT INTO "BP_Umwelt"."BP_Laermpegelbereich" ("Code", "Bezeichner") VALUES (1200, 'III');
INSERT INTO "BP_Umwelt"."BP_Laermpegelbereich" ("Code", "Bezeichner") VALUES (1300, 'IV');
INSERT INTO "BP_Umwelt"."BP_Laermpegelbereich" ("Code", "Bezeichner") VALUES (1400, 'V');
INSERT INTO "BP_Umwelt"."BP_Laermpegelbereich" ("Code", "Bezeichner") VALUES (1500, 'VI');
INSERT INTO "BP_Umwelt"."BP_Laermpegelbereich" ("Code", "Bezeichner") VALUES (1600, 'VII');

-- -----------------------------------------------------
-- Data for table "BP_Basisobjekte"."BP_TechnVorkehrungenImmissionsschutz"
-- -----------------------------------------------------
INSERT INTO "BP_Umwelt"."BP_TechnVorkehrungenImmissionsschutz" ("Code", "Bezeichner") VALUES (1000, 'Laermschutzvorkehrung');
INSERT INTO "BP_Umwelt"."BP_TechnVorkehrungenImmissionsschutz" ("Code", "Bezeichner") VALUES (10000, 'FassadenMitSchallschutzmassnahmen');
INSERT INTO "BP_Umwelt"."BP_TechnVorkehrungenImmissionsschutz" ("Code", "Bezeichner") VALUES (10001, 'Laermschutzwand');
INSERT INTO "BP_Umwelt"."BP_TechnVorkehrungenImmissionsschutz" ("Code", "Bezeichner") VALUES (10002, 'Laermschutzwall');
INSERT INTO "BP_Umwelt"."BP_TechnVorkehrungenImmissionsschutz" ("Code", "Bezeichner") VALUES (9999, 'SonstigeVorkehrung');

-- -----------------------------------------------------
-- Data for table "BP_Basisobjekte"."BP_ImmissionsschutzTypen"
-- -----------------------------------------------------
INSERT INTO "BP_Umwelt"."BP_ImmissionsschutzTypen" ("Code", "Bezeichner") VALUES (1000, 'Schutzflaeche');
INSERT INTO "BP_Umwelt"."BP_ImmissionsschutzTypen" ("Code", "Bezeichner") VALUES (2000, 'BesondereAnlagenVorkehrungen');

