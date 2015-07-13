-- -----------------------------------------------------
-- BP_Fachschema BPlan
-- Das Fachschema BPlan enthält alle Klassen von BPlan-Fachobjekten. Jede dieser Klassen modelliert eine nach BauGB mögliche Festsetzung, Kennzeichnung oder einen Vermerk in einem Bebauungsplan.
-- Wichtig bevor dieses Schema installiert werden kann, muß erst das XP_Basisschema installiert werden
-- -----------------------------------------------------

-- *****************************************************
-- CREATE GROUP ROLES
-- *****************************************************

-- editierende Rolle für BP_Fachschema_BPlan
CREATE ROLE bp_user
  NOSUPERUSER INHERIT NOCREATEDB NOCREATEROLE;
GRANT xp_user TO bp_user;

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
CREATE SCHEMA "BP_Raster";

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
COMMENT ON SCHEMA "BP_Raster" IS 'Rasterdarstellung von Bebauungsplänen';

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
GRANT USAGE ON SCHEMA "BP_Raster" TO xp_gast;


-- *****************************************************
-- CREATE SEQUENCES
-- *****************************************************

CREATE SEQUENCE "BP_Basisobjekte"."BP_WirksamkeitBedingung_id_seq"
   MINVALUE 1;
GRANT ALL ON TABLE "BP_Basisobjekte"."BP_WirksamkeitBedingung_id_seq" TO GROUP bp_user;


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
  "aufstellungsbechlussDatum" DATE NULL ,
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
COMMENT ON COLUMN  "BP_Basisobjekte"."BP_Plan"."aufstellungsbechlussDatum" IS 'Datum des Aufstellungsbeschlusses.';
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
  "versionBauNVO" INTEGER NULL ,
  "versionBauNVOText" VARCHAR(255) NULL ,
  "versionBauGB" DATE NULL ,
  "versionBauGBText" VARCHAR(255) NULL ,
  "gehoertZuPlan" INTEGER NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_BP_Bereich_BP_Plan1"
    FOREIGN KEY ("gehoertZuPlan" )
    REFERENCES "BP_Basisobjekte"."BP_Plan" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_BP_Bereich_XP_VersionBauNVO1"
    FOREIGN KEY ("versionBauNVO" )
    REFERENCES "XP_Enumerationen"."XP_VersionBauNVO" ("Code" )
    ON DELETE NO ACTION
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
COMMENT ON COLUMN  "BP_Basisobjekte"."BP_Bereich"."versionBauNVO" IS 'Benutzte Version der BauNVO';
COMMENT ON COLUMN  "BP_Basisobjekte"."BP_Bereich"."versionBauNVOText" IS 'Textliche Spezifikation einer anderen Gesetzesgrundlage als der BauNVO. In diesem Fall muss das Attribut versionBauNVO den Wert 9999 haben.';
COMMENT ON COLUMN  "BP_Basisobjekte"."BP_Bereich"."versionBauGB" IS 'Datum der zugrunde liegenden Version des BauGB.';
COMMENT ON COLUMN  "BP_Basisobjekte"."BP_Bereich"."versionBauGBText" IS 'Zugrunde liegende Version des BauGB.';
CREATE INDEX "idx_fk_BP_Bereich_BP_Plan1" ON "BP_Basisobjekte"."BP_Bereich" ("gehoertZuPlan") ;
CREATE INDEX "idx_fk_BP_Bereich_XP_VersionBauNVO1" ON "BP_Basisobjekte"."BP_Bereich" ("versionBauNVO") ;
CREATE INDEX "idx_fk_BP_Bereich_XP_Bereich1" ON "BP_Basisobjekte"."BP_Bereich" ("gid") ;
CREATE INDEX "idx_fk_BP_Bereich_XP_Bereich2" ON "BP_Basisobjekte"."BP_Bereich" ("gid") ;
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
-- Table "BP_Basisobjekte"."BP_WirksamkeitBedingung"
-- -----------------------------------------------------
CREATE  TABLE  "BP_Basisobjekte"."BP_WirksamkeitBedingung" (
  "id" INTEGER NOT NULL DEFAULT nextval('"BP_Basisobjekte"."BP_WirksamkeitBedingung_id_seq"'),
  "bedingung" VARCHAR(255) NULL ,
  "datumAbsolut" DATE NULL ,
  "datumRelativ" INTEGER NULL ,
  PRIMARY KEY ("id") );
GRANT SELECT ON "BP_Basisobjekte"."BP_WirksamkeitBedingung" TO xp_gast;
GRANT ALL ON "BP_Basisobjekte"."BP_WirksamkeitBedingung" TO bp_user;
COMMENT ON TABLE  "BP_Basisobjekte"."BP_WirksamkeitBedingung" IS 'Spezifikation von Bedingungen für die Wirksamkeit oder Unwirksamkeit einer Festsetzung.';
COMMENT ON COLUMN  "BP_Basisobjekte"."BP_WirksamkeitBedingung"."bedingung" IS 'Textlich formulierte Bedingung für die Wirksamkeit oder Unwirksamkeit einer Festsetzung.';
COMMENT ON COLUMN  "BP_Basisobjekte"."BP_WirksamkeitBedingung"."datumAbsolut" IS 'Datum an dem eine Festsetzung wirksam oder unwirksam wird.';
COMMENT ON COLUMN  "BP_Basisobjekte"."BP_WirksamkeitBedingung"."datumRelativ" IS 'Zeitspanne, nach der eine Festsetzung wirksam oder unwirksam wird, wenn die im Attribut bedingung spezifizierte Bedingung erfüllt ist.';

-- -----------------------------------------------------
-- Table "BP_Basisobjekte"."BP_Punktobjekt"
-- -----------------------------------------------------
CREATE  TABLE  "BP_Basisobjekte"."BP_Punktobjekt" (
  "gid" BIGINT NOT NULL ,
  "position" GEOMETRY(Multipoint,25832) NOT NULL ,
  PRIMARY KEY ("gid") );
GRANT SELECT ON TABLE "BP_Basisobjekte"."BP_Punktobjekt" TO xp_gast;
GRANT ALL ON TABLE "BP_Basisobjekte"."BP_Punktobjekt" TO bp_user;
CREATE TRIGGER "BP_Punktobjekt_isAbstract" BEFORE INSERT ON "BP_Basisobjekte"."BP_Punktobjekt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isAbstract"();

-- -----------------------------------------------------
-- Table "BP_Basisobjekte"."BP_Linienobjekt"
-- -----------------------------------------------------
CREATE  TABLE  "BP_Basisobjekte"."BP_Linienobjekt" (
  "gid" BIGINT NOT NULL ,
  "position" GEOMETRY(Multilinestring,25832) NOT NULL ,
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
-- Table "BP_Basisobjekte"."BP_Objekt"
-- -----------------------------------------------------
CREATE  TABLE  "BP_Basisobjekte"."BP_Objekt" (
  "gid" BIGINT NOT NULL ,
  "rechtscharakter" INTEGER NULL ,
  "startBedingung" INTEGER NULL ,
  "endeBedingung" INTEGER NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_bp_objekt_bp_rechtscharakter1"
    FOREIGN KEY ("rechtscharakter" )
    REFERENCES "BP_Basisobjekte"."BP_Rechtscharakter" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT "fk_BP_Objekt_BP_WirksamkeitBedingung1"
    FOREIGN KEY ("startBedingung" )
    REFERENCES "BP_Basisobjekte"."BP_WirksamkeitBedingung" ("id" )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT "fk_BP_Objekt_BP_WirksamkeitBedingung2"
    FOREIGN KEY ("endeBedingung" )
    REFERENCES "BP_Basisobjekte"."BP_WirksamkeitBedingung" ("id" )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT "fk_BP_Objekt_XP_Objekt1"
    FOREIGN KEY ("gid" )
    REFERENCES "XP_Basisobjekte"."XP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE);
GRANT SELECT ON "BP_Basisobjekte"."BP_Objekt" TO xp_gast;
GRANT ALL ON "BP_Basisobjekte"."BP_Objekt" TO bp_user;
COMMENT ON TABLE  "BP_Basisobjekte"."BP_Objekt" IS 'Basisklasse für alle raumbezogenen Festsetzungen, Hinweise, Vermerke und Kennzeichnungen eines Bebauungsplans.';
COMMENT ON COLUMN  "BP_Basisobjekte"."BP_Objekt"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN  "BP_Basisobjekte"."BP_Objekt"."rechtscharakter" IS 'Rechtliche Charakterisierung des Planinhaltes.';
COMMENT ON COLUMN  "BP_Basisobjekte"."BP_Objekt"."startBedingung" IS 'Notwendige Bedingung für die Wirksamkeit einer Festsetzung.';
COMMENT ON COLUMN  "BP_Basisobjekte"."BP_Objekt"."endeBedingung" IS 'Notwendige Bedingung für das Ende der Wirksamkeit einer Festsetzung';
CREATE INDEX "idx_fk_bp_objekt_bp_rechtscharakter1" ON "BP_Basisobjekte"."BP_Objekt" ("rechtscharakter") ;
CREATE INDEX "idx_fk_BP_Objekt_BP_WirksamkeitBedingung1" ON "BP_Basisobjekte"."BP_Objekt" ("startBedingung") ;
CREATE INDEX "idx_fk_BP_Objekt_BP_WirksamkeitBedingung2" ON "BP_Basisobjekte"."BP_Objekt" ("endeBedingung") ;
CREATE INDEX "idx_fk_BP_Objekt_XP_Objekt1" ON "BP_Basisobjekte"."BP_Objekt" ("gid") ;
CREATE TRIGGER "change_to_BP_Objekt" BEFORE INSERT OR UPDATE ON "BP_Basisobjekte"."BP_Objekt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_BP_Objekt" AFTER DELETE ON "BP_Basisobjekte"."BP_Objekt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "BP_Basisobjekte"."BP_TextAbschnitt"
-- -----------------------------------------------------
CREATE  TABLE  "BP_Basisobjekte"."BP_TextAbschnitt" (
  "id" BIGINT NOT NULL ,
  "rechtscharakter" INTEGER NULL ,
  PRIMARY KEY ("gid") ,
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
CREATE INDEX "idx_fk_bp_objekt_bp_rechtscharakter1" ON "BP_Basisobjekte"."BP_TextAbschnitt" ("rechtscharakter") ;
CREATE TRIGGER "change_to_BP_TextAbschnitt" BEFORE INSERT OR UPDATE ON "BP_Basisobjekte"."BP_TextAbschnitt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_TextAbschnitt"();
CREATE TRIGGER "delete_BP_TextAbschnitt" AFTER DELETE ON "BP_Basisobjekte"."BP_TextAbschnitt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_TextAbschnitt"();

-- -----------------------------------------------------
-- Table "BP_Basisobjekte"."BP_Objekt_gehoertZuBP_Bereich"
-- -----------------------------------------------------
CREATE  TABLE  "BP_Basisobjekte"."BP_Objekt_gehoertZuBP_Bereich" (
  "gehoertZuBP_Bereich" BIGINT NOT NULL ,
  "BP_Objekt_gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gehoertZuBP_Bereich", "BP_Objekt_gid") ,
  CONSTRAINT "fk_gehoertzubp_bereich_bp_bereich1"
    FOREIGN KEY ("gehoertZuBP_Bereich" )
    REFERENCES "BP_Basisobjekte"."BP_Bereich" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_gehoertZuBP_Bereich_BP_Objekt1"
    FOREIGN KEY ("BP_Objekt_gid" )
    REFERENCES "BP_Basisobjekte"."BP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE);
GRANT SELECT ON "BP_Basisobjekte"."BP_Objekt_gehoertZuBP_Bereich" TO xp_gast;
GRANT ALL ON "BP_Basisobjekte"."BP_Objekt_gehoertZuBP_Bereich" TO bp_user;
COMMENT ON TABLE  "BP_Basisobjekte"."BP_Objekt_gehoertZuBP_Bereich" IS 'Die Relation zeigt an, dass das BPlan-Fachobjekt vom referierten Planbereich als originärer Planinhalt referiert wird.';
CREATE INDEX "idx_fk_gehoertzubp_bereich_bp_bereich1" ON "BP_Basisobjekte"."BP_Objekt_gehoertZuBP_Bereich" ("gehoertZuBP_Bereich") ;
CREATE INDEX "idx_fk_gehoertZuBP_Bereich_BP_Objekt1" ON "BP_Basisobjekte"."BP_Objekt_gehoertZuBP_Bereich" ("BP_Objekt_gid") ;

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
-- Table "BP_Raster"."BP_RasterplanAenderung"
-- -----------------------------------------------------
CREATE  TABLE  "BP_Raster"."BP_RasterplanAenderung" (
  "gid" BIGINT NOT NULL ,
  "aufstellungsbeschlussDatum" DATE NULL ,
  "auslegungsStartDatum" DATE[],
  "auslegungsEndDatum" DATE[],
  "traegerbeteiligungsStartDatum" DATE[],
  "traegerbeteiligungsEndDatum" DATE[],
  "veraenderungssperreDatum" DATE NULL ,
  "satzungsbeschlussDatum" DATE NULL ,
  "rechtsverordnungsDatum" DATE NULL ,
  "inkrafttretensDatum" DATE NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_BP_RasterplanAenderung1"
    FOREIGN KEY ("gid" )
    REFERENCES "XP_Raster"."XP_RasterplanAenderung" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("XP_Raster"."XP_GeltungsbereichAenderung");

GRANT SELECT ON "BP_Raster"."BP_RasterplanAenderung" TO xp_gast;
GRANT ALL ON "BP_Raster"."BP_RasterplanAenderung" TO bp_user;
COMMENT ON TABLE  "BP_Raster"."BP_RasterplanAenderung" IS 'Georeferenziertes Rasterbild der Änderung eines Basisplans. Die abgeleitete Klasse besitzt Datums-Attribute, die spezifisch für Bebauungspläne sind.';
COMMENT ON COLUMN  "BP_Raster"."BP_RasterplanAenderung"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN  "BP_Raster"."BP_RasterplanAenderung"."aufstellungsbeschlussDatum" IS 'Datum des Aufstellungsbeschlusses';
COMMENT ON COLUMN  "BP_Raster"."BP_RasterplanAenderung"."auslegungsStartDatum" IS 'Start-Datum der öffentlichen Auslegung.';
COMMENT ON COLUMN  "BP_Raster"."BP_RasterplanAenderung"."auslegungsEndDatum" IS 'End-Datum der öffentlichen Auslegung.';
COMMENT ON COLUMN  "BP_Raster"."BP_RasterplanAenderung"."traegerbeteiligungsStartDatum" IS 'Start-Datum der Trägerbeteiligung.';
COMMENT ON COLUMN  "BP_Raster"."BP_RasterplanAenderung"."traegerbeteiligungsEndDatum" IS 'End-Datum der Trägerbeteiligung.';
COMMENT ON COLUMN  "BP_Raster"."BP_RasterplanAenderung"."veraenderungssperreDatum" IS 'Datum einer Veränderungssperre';
COMMENT ON COLUMN  "BP_Raster"."BP_RasterplanAenderung"."satzungsbeschlussDatum" IS 'Datum des Satzungsbeschlusses der Änderung.';
COMMENT ON COLUMN  "BP_Raster"."BP_RasterplanAenderung"."rechtsverordnungsDatum" IS 'Datum der Rechtsverordnung';
COMMENT ON COLUMN  "BP_Raster"."BP_RasterplanAenderung"."inkrafttretensDatum" IS 'Datum des Inkrafttretens der Änderung';
CREATE INDEX "idx_fk_BP_RasterplanAenderung1" ON "BP_Raster"."BP_RasterplanAenderung" ("gid") ;
CREATE TRIGGER "change_to_BP_RasterplanAenderung" BEFORE INSERT OR UPDATE ON "BP_Raster"."BP_RasterplanAenderung" FOR EACH ROW EXECUTE PROCEDURE "XP_Raster"."child_of_XP_RasterplanAenderung"();
CREATE TRIGGER "delete_BP_RasterplanAenderung" AFTER DELETE ON "BP_Raster"."BP_RasterplanAenderung" FOR EACH ROW EXECUTE PROCEDURE "XP_Raster"."child_of_XP_RasterplanAenderung"();


-- -----------------------------------------------------
-- Table "BP_Aufschuettung_Abgrabung_Bodenschaetze"."BP_AbgrabungsFlaeche"
-- -----------------------------------------------------
CREATE  TABLE  "BP_Aufschuettung_Abgrabung_Bodenschaetze"."BP_AbgrabungsFlaeche" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid"),
  CONSTRAINT "fk_BP_AbgrabungsFlaeche_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "BP_Basisobjekte"."BP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE
  )
INHERITS ("BP_Basisobjekte"."BP_Flaechenobjekt");

GRANT SELECT ON TABLE "BP_Aufschuettung_Abgrabung_Bodenschaetze"."BP_AbgrabungsFlaeche" TO xp_gast;
GRANT ALL ON TABLE "BP_Aufschuettung_Abgrabung_Bodenschaetze"."BP_AbgrabungsFlaeche" TO bp_user;
COMMENT ON TABLE  "BP_Aufschuettung_Abgrabung_Bodenschaetze"."BP_AbgrabungsFlaeche" IS 'Flächen für Aufschüttungen, Abgrabungen oder für die Gewinnung von Bodenschätzen (§9, Abs. 1, Nr. 17 BauGB)). Hier: Flächen für Abgrabungen.';
COMMENT ON COLUMN  "BP_Aufschuettung_Abgrabung_Bodenschaetze"."BP_AbgrabungsFlaeche"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
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
    ON UPDATE CASCADE
  )
INHERITS ("BP_Basisobjekte"."BP_Flaechenobjekt");

GRANT SELECT ON TABLE "BP_Bebauung"."BP_AbstandsFlaeche" TO xp_gast;
GRANT ALL ON TABLE "BP_Bebauung"."BP_AbstandsFlaeche" TO bp_user;
COMMENT ON TABLE  "BP_Bebauung"."BP_AbstandsFlaeche" IS 'Festsetzung eines vom Bauordnungsrecht abweichenden Maßes der Tiefe der Abstandsfläche gemäß § 9 Abs 1. Nr. 2a BauGB';
COMMENT ON COLUMN  "BP_Bebauung"."BP_AbstandsFlaeche"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN  "BP_Bebauung"."BP_AbstandsFlaeche"."tiefe" IS 'Absolute Angabe derTiefe.';
CREATE TRIGGER "change_to_BP_AbstandsFlaeche" BEFORE INSERT OR UPDATE ON "BP_Bebauung"."BP_AbstandsFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_BP_AbstandsFlaeche" AFTER DELETE ON "BP_Bebauung"."BP_AbstandsFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "BP_AbstandsFlaeche_Ueberlagerung" BEFORE INSERT OR UPDATE ON "BP_Bebauung"."BP_AbstandsFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isUeberlagerungsobjekt"();

-- -----------------------------------------------------
-- Table "BP_Sonstiges"."BP_AbstandsMass"
-- -----------------------------------------------------
CREATE  TABLE  "BP_Sonstiges"."BP_AbstandsMass" (
  "gid" BIGINT NOT NULL ,
  "wert" NUMERIC(6,2) NOT NULL,
  "startWinkel" INTEGER,
  "endWinkel" INTEGER,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_BP_AbstandsMass_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "BP_Basisobjekte"."BP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE);

GRANT SELECT ON TABLE "BP_Sonstiges"."BP_AbstandsMass" TO xp_gast;
GRANT ALL ON TABLE "BP_Sonstiges"."BP_AbstandsMass" TO bp_user;
COMMENT ON TABLE  "BP_Sonstiges"."BP_AbstandsMass" IS 'Darstellung von Maßpfeilen oder Maßkreisen in BPlänen um eine eindeutige Vermassung einzelner Festsetzungen zu erreichen.';
COMMENT ON COLUMN  "BP_Sonstiges"."BP_AbstandsMass"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN  "BP_Sonstiges"."BP_AbstandsMass"."wert" IS 'Längenangabe des Abstandsmasses.';
COMMENT ON COLUMN  "BP_Sonstiges"."BP_AbstandsMass"."startWinkel" IS 'Startwinkel für Darstellung eines Abstandsmaßes (nur relevant für Maßkeise)';
COMMENT ON COLUMN  "BP_Sonstiges"."BP_AbstandsMass"."endWinkel" IS 'Endwinkel für Darstellung eines Abstandsmaßes (nur relevant für Maßkeise)';
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
CREATE TRIGGER "change_to_BP_AbstandsMassPunkt" BEFORE INSERT OR UPDATE ON "BP_Sonstiges"."BP_AbstandsMassPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_BP_AbstandsMassPunkt" AFTER DELETE ON "BP_Sonstiges"."BP_AbstandsMassPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_AnpflanzungBindungErhaltung"
-- -----------------------------------------------------
CREATE  TABLE  "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_AnpflanzungBindungErhaltung" (
  "gid" BIGINT NOT NULL ,
  "massnahme" INTEGER,
  "gegenstand" INTEGER,
  "kronendurchmesser" NUMERIC(6,2) NOT NULL,
  "pflanztiefe" NUMERIC(6,2) NOT NULL,
  "istAusgleich" BOOLEAN
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_BP_AnpflanzungBindungErhaltung_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "BP_Basisobjekte"."BP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE);

GRANT SELECT ON TABLE "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_AnpflanzungBindungErhaltung" TO xp_gast;
GRANT ALL ON TABLE "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_AnpflanzungBindungErhaltung" TO bp_user;
COMMENT ON TABLE  "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_AnpflanzungBindungErhaltung" IS 'Für einzelne Flächen oder für ein Bebauungsplangebiet oder Teile davon sowie für Teile baulicher Anlagen mit Ausnahme der für landwirtschaftliche Nutzungen oder Wald festgesetzten Flächen:\n
a) Festsetzung des Anpflanzens von Bäumen, Sträuchern und sonstigen Bepflanzungen;\n
b) Festsetzung von Bindungen für Bepflanzungen und für die Erhaltung von Bäumen, Sträuchern und sonstigen Bepflanzungen sowie von Gewässern; (§9 Abs. 1 Nr. 25 und Abs. 4 BauGB) ';
COMMENT ON COLUMN  "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_AnpflanzungBindungErhaltung"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN  "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_AnpflanzungBindungErhaltung"."massnahme" IS 'Art der Maßnahme';
COMMENT ON COLUMN  "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_AnpflanzungBindungErhaltung"."gegenstand" IS 'Gegenstände der Maßnahme';
COMMENT ON COLUMN  "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_AnpflanzungBindungErhaltung"."kronendurchmesser" IS 'Durchmesser der Baumkrone bei zu erhaltenden Bäumen.';
COMMENT ON COLUMN  "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_AnpflanzungBindungErhaltung"."pflanztiefe" IS 'Pflanztiefe';
COMMENT ON COLUMN  "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_AnpflanzungBindungErhaltung"."istAusgleich" IS 'Gibt an, ob die Fläche oder Maßnahme zum Ausgleich von Eingriffen genutzt wird.';
CREATE TRIGGER "change_to_BP_AnpflanzungBindungErhaltung" BEFORE INSERT OR UPDATE ON "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_AnpflanzungBindungErhaltung" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_BP_AnpflanzungBindungErhaltung" AFTER DELETE ON "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_AnpflanzungBindungErhaltung" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

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
CREATE TRIGGER "change_to_BP_AnpflanzungBindungErhaltungPunkt" BEFORE INSERT OR UPDATE ON "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_AnpflanzungBindungErhaltungPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_BP_AnpflanzungBindungErhaltungPunkt" AFTER DELETE ON "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_AnpflanzungBindungErhaltungPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "BP_Aufschuettung_Abgrabung_Bodenschaetze"."BP_AufschuettungsFlaeche"
-- -----------------------------------------------------
CREATE  TABLE  "BP_Aufschuettung_Abgrabung_Bodenschaetze"."BP_AufschuettungsFlaeche" (
  "gid" BIGINT NOT NULL ,
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
COMMENT ON TABLE  "BP_Aufschuettung_Abgrabung_Bodenschaetze"."BP_AufschuettungsFlaeche" IS 'Flächen für Aufschüttungen, Abgrabungen oder für die Gewinnung von Bodenschätzen (§ 9 Abs. 1 Nr. 17 und Abs. 6 BauGB). Hier: Flächen für Aufschüttungen';
CREATE TRIGGER "change_to_BP_AufschuettungsFlaeche" BEFORE INSERT OR UPDATE ON "BP_Aufschuettung_Abgrabung_Bodenschaetze"."BP_AufschuettungsFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_BP_AufschuettungsFlaeche" AFTER DELETE ON "BP_Aufschuettung_Abgrabung_Bodenschaetze"."BP_AufschuettungsFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "BP_AufschuettungsFlaeche_Flaechenobjekt" BEFORE INSERT OR UPDATE ON "BP_Aufschuettung_Abgrabung_Bodenschaetze"."BP_AufschuettungsFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isFlaechenobjekt"();

-- -----------------------------------------------------
-- Table "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_AusgleichsFlaeche"
-- -----------------------------------------------------
CREATE  TABLE  "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_AusgleichsFlaeche" (
  "gid" BIGINT NOT NULL ,
  "ziel" INTEGER NULL ,
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
COMMENT ON TABLE  "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_AusgleichsFlaeche" IS 'Festsetzung einer Fläche zum Ausgleich im Sinne des § 1a Abs.3 und §9 Abs. 1a BauGB.';
COMMENT ON COLUMN  "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_AusgleichsFlaeche"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN  "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_AusgleichsFlaeche"."ziel" IS 'Unterscheidung nach den Zielen "Schutz, Pflege" und "Entwicklung".';
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
  "massnahme" INTEGER NULL ,
  PRIMARY KEY ("BP_AusgleichsFlaeche_gid", "massnahme"),
  CONSTRAINT "fk_BP_AusgleichsFlaeche_massnahme1"
    FOREIGN KEY ("BP_AusgleichsFlaeche_gid" )
    REFERENCES "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_AusgleichsFlaeche" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_BP_AusgleichsFlaeche_massnahme2"
    FOREIGN KEY ("massnahme" )
    REFERENCES "XP_Sonstiges"."XP_SPEMassnahmenDaten" ("id" )
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
  "massnahme" INTEGER NULL ,
  PRIMARY KEY ("BP_AusgleichsMassnahme_gid", "massnahme"),
  CONSTRAINT "fk_BP_AusgleichsMassnahme_massnahme1"
    FOREIGN KEY ("BP_AusgleichsMassnahme_gid" )
    REFERENCES "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_AusgleichsMassnahme" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_BP_AusgleichsMassnahme_massnahme2"
    FOREIGN KEY ("massnahme" )
    REFERENCES "XP_Sonstiges"."XP_SPEMassnahmenDaten" ("id" )
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
COMMENT ON TABLE "BP_Verkehr"."BP_BereichOhneEinAusfahrtLinie" IS 'Bereich ohne Ein- und Ausfahrt (§9 Abs. 1 Nr. 11 und Abs. 6 BauGB).';
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
GRANT ALL ON TABLE "BP_Aufschuettung_Abgrabung_Bodenschaetze"."BP_BodenschaetzeFlaeche" TO bp_user;
COMMENT ON TABLE "BP_Aufschuettung_Abgrabung_Bodenschaetze"."BP_BodenschaetzeFlaeche" IS 'Flächen für Aufschüttungen, Abgrabungen oder für die Gewinnung von Bodenschätzen (§ 9 Abs. 1 Nr. 17 und Abs. 6 BauGB). Hier: Flächen für Gewinnung von Bodenschätzen ';
COMMENT ON COLUMN  "BP_Aufschuettung_Abgrabung_Bodenschaetze"."BP_BodenschaetzeFlaeche"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN "BP_Aufschuettung_Abgrabung_Bodenschaetze"."BP_BodenschaetzeFlaeche"."abbaugut" IS 'Bezeichnung des Abbauguts.';
CREATE TRIGGER "change_to_BP_BodenschaetzeFlaeche" BEFORE INSERT OR UPDATE ON "BP_Aufschuettung_Abgrabung_Bodenschaetze"."BP_BodenschaetzeFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_BP_BodenschaetzeFlaeche" AFTER DELETE ON "BP_Aufschuettung_Abgrabung_Bodenschaetze"."BP_BodenschaetzeFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "BP_BodenschaetzeFlaeche_Flaechenobjekt" BEFORE INSERT OR UPDATE ON "BP_Aufschuettung_Abgrabung_Bodenschaetze"."BP_BodenschaetzeFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isFlaechenobjekt"();

-- -----------------------------------------------------
-- Table "BP_Erhaltungssatzung_und_Denkmalschutz"."BP_DenkmalschutzEinzelanlage"
-- -----------------------------------------------------
CREATE  TABLE  "BP_Erhaltungssatzung_und_Denkmalschutz"."BP_DenkmalschutzEinzelanlage" (
  "gid" BIGINT NOT NULL ,
  "denkmal" CHARACTER VARYING(64),
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_BP_DenkmalschutzEinzelanlage_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "BP_Basisobjekte"."BP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE);

GRANT SELECT ON TABLE "BP_Erhaltungssatzung_und_Denkmalschutz"."BP_DenkmalschutzEinzelanlage" TO xp_gast;
GRANT ALL ON TABLE "BP_Erhaltungssatzung_und_Denkmalschutz"."BP_DenkmalschutzEinzelanlage" TO bp_user;
COMMENT ON TABLE  "BP_Erhaltungssatzung_und_Denkmalschutz"."BP_DenkmalschutzEinzelanlage" IS 'Denkmalgeschützte Einzelanlage, sofern es sich um eine Festsetzung des Bebauungsplans handelt (§9 Abs. 4 BauGB - landesrechtliche Regelung).';
COMMENT ON COLUMN  "BP_Erhaltungssatzung_und_Denkmalschutz"."BP_DenkmalschutzEinzelanlage"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN  "BP_Erhaltungssatzung_und_Denkmalschutz"."BP_DenkmalschutzEinzelanlage"."denkmal" IS 'Nähere Bezeichnung des Denkmals.';
CREATE TRIGGER "change_to_BP_DenkmalschutzEinzelanlage" BEFORE INSERT OR UPDATE ON "BP_Erhaltungssatzung_und_Denkmalschutz"."BP_DenkmalschutzEinzelanlage" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_BP_DenkmalschutzEinzelanlage" AFTER DELETE ON "BP_Erhaltungssatzung_und_Denkmalschutz"."BP_DenkmalschutzEinzelanlage" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "BP_Erhaltungssatzung_und_Denkmalschutz"."BP_DenkmalschutzEinzelanlageFlaeche"
-- -----------------------------------------------------
CREATE  TABLE  "BP_Erhaltungssatzung_und_Denkmalschutz"."BP_DenkmalschutzEinzelanlageFlaeche" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_BP_DenkmalschutzEinzelanlageFlaeche_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "BP_Erhaltungssatzung_und_Denkmalschutz"."BP_DenkmalschutzEinzelanlage" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("BP_Basisobjekte"."BP_Flaechenobjekt");

GRANT SELECT ON TABLE "BP_Erhaltungssatzung_und_Denkmalschutz"."BP_DenkmalschutzEinzelanlageFlaeche" TO xp_gast;
GRANT ALL ON TABLE "BP_Erhaltungssatzung_und_Denkmalschutz"."BP_DenkmalschutzEinzelanlageFlaeche" TO bp_user;
CREATE TRIGGER "change_to_BP_DenkmalschutzEinzelanlageFlaeche" BEFORE INSERT OR UPDATE ON "BP_Erhaltungssatzung_und_Denkmalschutz"."BP_DenkmalschutzEinzelanlageFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_BP_DenkmalschutzEinzelanlageFlaeche" AFTER DELETE ON "BP_Erhaltungssatzung_und_Denkmalschutz"."BP_DenkmalschutzEinzelanlageFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "BP_DenkmalschutzEinzelanlageFlaeche_Flaechenobjekt" BEFORE INSERT OR UPDATE ON "BP_Erhaltungssatzung_und_Denkmalschutz"."BP_DenkmalschutzEinzelanlageFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isFlaechenobjekt"();

-- -----------------------------------------------------
-- Table "BP_Erhaltungssatzung_und_Denkmalschutz"."BP_DenkmalschutzEinzelanlageLinie"
-- -----------------------------------------------------
CREATE  TABLE  "BP_Erhaltungssatzung_und_Denkmalschutz"."BP_DenkmalschutzEinzelanlageLinie" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_BP_DenkmalschutzEinzelanlageLinie_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "BP_Erhaltungssatzung_und_Denkmalschutz"."BP_DenkmalschutzEinzelanlage" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("BP_Basisobjekte"."BP_Linienobjekt");

GRANT SELECT ON TABLE "BP_Erhaltungssatzung_und_Denkmalschutz"."BP_DenkmalschutzEinzelanlageLinie" TO xp_gast;
GRANT ALL ON TABLE "BP_Erhaltungssatzung_und_Denkmalschutz"."BP_DenkmalschutzEinzelanlageLinie" TO bp_user;
CREATE TRIGGER "change_to_BP_DenkmalschutzEinzelanlageLinie" BEFORE INSERT OR UPDATE ON "BP_Erhaltungssatzung_und_Denkmalschutz"."BP_DenkmalschutzEinzelanlageLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_BP_DenkmalschutzEinzelanlageLinie" AFTER DELETE ON "BP_Erhaltungssatzung_und_Denkmalschutz"."BP_DenkmalschutzEinzelanlageLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "BP_Erhaltungssatzung_und_Denkmalschutz"."BP_DenkmalschutzEinzelanlagePunkt"
-- -----------------------------------------------------
CREATE  TABLE  "BP_Erhaltungssatzung_und_Denkmalschutz"."BP_DenkmalschutzEinzelanlagePunkt" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_BP_DenkmalschutzEinzelanlagePunkt_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "BP_Erhaltungssatzung_und_Denkmalschutz"."BP_DenkmalschutzEinzelanlage" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("BP_Basisobjekte"."BP_Punktobjekt");

GRANT SELECT ON TABLE "BP_Erhaltungssatzung_und_Denkmalschutz"."BP_DenkmalschutzEinzelanlagePunkt" TO xp_gast;
GRANT ALL ON TABLE "BP_Erhaltungssatzung_und_Denkmalschutz"."BP_DenkmalschutzEinzelanlagePunkt" TO bp_user;
CREATE TRIGGER "change_to_BP_DenkmalschutzEinzelanlagePunkt" BEFORE INSERT OR UPDATE ON "BP_Erhaltungssatzung_und_Denkmalschutz"."BP_DenkmalschutzEinzelanlagePunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_BP_DenkmalschutzEinzelanlagePunkt" AFTER DELETE ON "BP_Erhaltungssatzung_und_Denkmalschutz"."BP_DenkmalschutzEinzelanlagePunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "BP_Erhaltungssatzung_und_Denkmalschutz"."BP_DenkmalschutzEnsembleFlaeche"
-- -----------------------------------------------------
CREATE  TABLE  "BP_Erhaltungssatzung_und_Denkmalschutz"."BP_DenkmalschutzEnsembleFlaeche" (
  "gid" BIGINT NOT NULL ,
  "denkmal" CHARACTER VARYING(64),
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_BP_DenkmalschutzEnsembleFlaeche_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "BP_Basisobjekte"."BP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("BP_Basisobjekte"."BP_Flaechenobjekt");

GRANT SELECT ON TABLE "BP_Erhaltungssatzung_und_Denkmalschutz"."BP_DenkmalschutzEnsembleFlaeche" TO xp_gast;
GRANT ALL ON TABLE "BP_Erhaltungssatzung_und_Denkmalschutz"."BP_DenkmalschutzEnsembleFlaeche" TO bp_user;
COMMENT ON TABLE "BP_Erhaltungssatzung_und_Denkmalschutz"."BP_DenkmalschutzEnsembleFlaeche" IS 'Umgrenzung eines Denkmalgeschützten Ensembles, sofern es sich um eine Festsetzung des Bebauungsplans handelt (§9 Abs. 4 BauGB - landesrechtliche Regelung). Weltkulturerbe kann eigentlich nicht vorkommen.';
COMMENT ON COLUMN  "BP_Erhaltungssatzung_und_Denkmalschutz"."BP_DenkmalschutzEnsembleFlaeche"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN  "BP_Erhaltungssatzung_und_Denkmalschutz"."BP_DenkmalschutzEnsembleFlaeche"."denkmal" IS 'Nähere Bezeichnung des Denkmals.';
CREATE TRIGGER "change_to_BP_DenkmalschutzEnsembleFlaeche" BEFORE INSERT OR UPDATE ON "BP_Erhaltungssatzung_und_Denkmalschutz"."BP_DenkmalschutzEnsembleFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_BP_DenkmalschutzEnsembleFlaeche" AFTER DELETE ON "BP_Erhaltungssatzung_und_Denkmalschutz"."BP_DenkmalschutzEnsembleFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "ueberlagerung_BP_DenkmalschutzEnsembleFlaeche" BEFORE INSERT OR UPDATE ON "BP_Erhaltungssatzung_und_Denkmalschutz"."BP_DenkmalschutzEnsembleFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isUeberlagerungsobjekt"();

-- -----------------------------------------------------
-- Table "BP_Verkehr"."BP_EinfahrtPunkt"
-- -----------------------------------------------------
CREATE  TABLE  "BP_Verkehr"."BP_EinfahrtPunkt" (
  "gid" BIGINT NOT NULL ,
  "richtung" INTEGER NOT NULL DEFAULT 0,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_BP_EinfahrtPunkt_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "BP_Basisobjekte"."BP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("BP_Basisobjekte"."BP_Punktobjekt");

GRANT SELECT ON TABLE "BP_Verkehr"."BP_EinfahrtPunkt" TO xp_gast;
GRANT ALL ON TABLE "BP_Verkehr"."BP_EinfahrtPunkt" TO bp_user;
COMMENT ON TABLE "BP_Verkehr"."BP_EinfahrtPunkt" IS 'Einfahrt (§9 Abs. 1 Nr. 11 und Abs. 6 BauGB).';
COMMENT ON COLUMN  "BP_Verkehr"."BP_EinfahrtPunkt"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN  "BP_Verkehr"."BP_EinfahrtPunkt"."richtung" IS 'Winkel-Richtung der Einfahrt (in Grad).';
CREATE TRIGGER "change_to_BP_EinfahrtPunkt" BEFORE INSERT OR UPDATE ON "BP_Verkehr"."BP_EinfahrtPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_BP_EinfahrtPunkt" AFTER DELETE ON "BP_Verkehr"."BP_EinfahrtPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "BP_Verkehr"."BP_EinfahrtsbereichLinie"
-- -----------------------------------------------------
CREATE  TABLE  "BP_Verkehr"."BP_EinfahrtsbereichLinie" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_BP_EinfahrtsbereichLinie_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "BP_Basisobjekte"."BP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("BP_Basisobjekte"."BP_Linienobjekt");

GRANT SELECT ON TABLE "BP_Verkehr"."BP_EinfahrtsbereichLinie" TO xp_gast;
GRANT ALL ON TABLE "BP_Verkehr"."BP_EinfahrtsbereichLinie" TO bp_user;
COMMENT ON TABLE "BP_Verkehr"."BP_EinfahrtsbereichLinie" IS 'Einfahrtsbereich (§9 Abs. 1 Nr. 11 und Abs. 6 BauGB).';
COMMENT ON COLUMN  "BP_Verkehr"."BP_EinfahrtsbereichLinie"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
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
GRANT ALL ON TABLE "BP_Erhaltungssatzung_und_Denkmalschutz"."BP_ErhaltungsBereichFlaeche" TO bp_user;
COMMENT ON TABLE "BP_Erhaltungssatzung_und_Denkmalschutz"."BP_ErhaltungsBereichFlaeche" IS 'Bestimmt einen Bereich, in dem ein Eingriff nach dem Naturschutzrecht zugelassen wird, der durch geeignete Flächen oder Maßnahmen ausgeglichen werden muss.';
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
COMMENT ON TABLE "BP_Umwelt"."BP_ErneuerbareEnergieFlaeche" IS 'Festsetzung nach §9 Abs. 1 Nr. 23b: Gebiete in denen bei der Errichtung von Gebäuden bestimmte bauliche Maßnahmen für den Einsatz erneuerbarer Energien wie insbesondere Solarenergie getroffen werden müssen.';
COMMENT ON COLUMN  "BP_Umwelt"."BP_ErneuerbareEnergieFlaeche"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN  "BP_Umwelt"."BP_ErneuerbareEnergieFlaeche"."technischeMassnahme" IS 'Beschreibung der baulichen oder sonstigen technischen Maßnahme.';
CREATE TRIGGER "change_to_BP_ErneuerbareEnergieFlaeche" BEFORE INSERT OR UPDATE ON "BP_Umwelt"."BP_ErneuerbareEnergieFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_BP_ErneuerbareEnergieFlaeche" AFTER DELETE ON "BP_Umwelt"."BP_ErneuerbareEnergieFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "ueberlagerung_BP_ErneuerbareEnergieFlaeche" BEFORE INSERT OR UPDATE ON "BP_Umwelt"."BP_ErneuerbareEnergieFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isUeberlagerungsobjekt"();

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
COMMENT ON TABLE "BP_Sonstiges"."BP_FestsetzungNachLandesrecht" IS 'Festsetzung nach §9 Nr. (4) BauGB ';
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
COMMENT ON TABLE "BP_Sonstiges"."BP_GenerischesObjekt" IS 'Klasse zur Modellierung aller Inhalte des BPlans, die keine nachrichtliche Übernahmen aus anderen Rechtsbereichen sind, aber durch keine andere Klasse des BPlan-Fachschemas dargestellt werden können. ';
COMMENT ON COLUMN  "BP_Sonstiges"."BP_GenerischesObjekt"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_BP_GenerischesObjekt" BEFORE INSERT OR UPDATE ON "BP_Sonstiges"."BP_GenerischesObjekt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_BP_GenerischesObjekt" AFTER DELETE ON "BP_Sonstiges"."BP_GenerischesObjekt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table BP_Sonstiges"."BP_GenerischesObjekt_zweckbestimmung"
-- -----------------------------------------------------
CREATE  TABLE  "BP_Sonstiges"."BP_GenerischesObjekt_zweckbestimmung" (
  "BP_GenerischesObjekt_gid" BIGINT NOT NULL ,
  "zweckbestimmung" INTEGER NULL ,
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
GRANT ALL ON TABLE "BP_Wasser"."BP_DetailZweckbestGewaesser" TO bp_user;

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
    ON UPDATE CASCADE);

CREATE INDEX "idx_fk_BP_GewaesserFlaeche_XP_ZweckbestimmungGewaesser" ON "BP_Wasser"."BP_GewaesserFlaeche" ("zweckbestimmung") ;
CREATE INDEX "idx_fk_BP_GewaesserFlaeche_BP_DetailZweckbestGewaesser1" ON "BP_Wasser"."BP_GewaesserFlaeche" ("detaillierteZweckbestimmung") ;
GRANT SELECT ON TABLE "BP_Wasser"."BP_GewaesserFlaeche" TO xp_gast;
GRANT ALL ON TABLE "BP_Wasser"."BP_GewaesserFlaeche" TO bp_user;
COMMENT ON TABLE  "BP_Wasser"."BP_GewaesserFlaeche" IS 'Wasserfläche (§9 Abs. 1 Nr. 16 und Abs. 6 BauGB). ';
COMMENT ON COLUMN  "BP_Wasser"."BP_GewaesserFlaeche"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN  "BP_Wasser"."BP_GewaesserFlaeche"."zweckbestimmung" IS 'Zweckbestimmung der Wasserfläche.';
COMMENT ON COLUMN  "BP_Wasser"."BP_GewaesserFlaeche"."detaillierteZweckbestimmung" IS 'Über eine CodeList definierte Zweckbestimmung der Fläche. ';
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
CREATE TRIGGER "change_to_BP_HoehenMassPunkt" BEFORE INSERT OR UPDATE ON "BP_Sonstiges"."BP_HoehenMassPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_BP_HoehenMassPunkt" AFTER DELETE ON "BP_Sonstiges"."BP_HoehenMassPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "BP_Umwelt"."BP_Immissionsschutz"
-- -----------------------------------------------------
CREATE  TABLE  "BP_Umwelt"."BP_Immissionsschutz" (
  "gid" BIGINT NOT NULL ,
  "nutzung" CHARACTER VARYING (256),
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_BP_Immissionsschutz_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "BP_Basisobjekte"."BP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE);

GRANT SELECT ON TABLE "BP_Umwelt"."BP_Immissionsschutz" TO xp_gast;
GRANT ALL ON TABLE "BP_Umwelt"."BP_Immissionsschutz" TO bp_user;
COMMENT ON TABLE  "BP_Umwelt"."BP_Immissionsschutz" IS 'Festsetzung einer von der Bebauung freizuhaltenden Schutzfläche und ihre Nutzung, sowie einer Fläche für besondere Anlagen und Vorkehrungen zum Schutz vor schädlichen Umwelteinwirkungen und sonstigen Gefahren im Sinne des Bundes-Immissionsschutzgesetzes sowie die zum Schutz vor solchen Einwirkungen oder zur Vermeidung oder Minderung solcher Einwirkungen zu treffenden baulichen und sonstigen technischen Vorkehrungen (§9, Abs. 1, Nr. 24 BauGB).';
COMMENT ON COLUMN  "BP_Umwelt"."BP_Immissionsschutz"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN  "BP_Umwelt"."BP_Immissionsschutz"."nutzung" IS 'Festgesetzte Nutzung einer Schutzfläche';
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
CREATE TRIGGER "change_to_BP_ImmissionsschutzPunkt" BEFORE INSERT OR UPDATE ON "BP_Umwelt"."BP_ImmissionsschutzPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_BP_ImmissionsschutzPunkt" AFTER DELETE ON "BP_Umwelt"."BP_ImmissionsschutzPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "BP_Sonstiges"."BP_KennzeichnungsFlaeche"
-- -----------------------------------------------------
CREATE  TABLE  "BP_Sonstiges"."BP_KennzeichnungsFlaeche" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_BP_KennzeichnungsFlaeche_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "BP_Basisobjekte"."BP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("BP_Basisobjekte"."BP_Flaechenobjekt");

GRANT SELECT ON TABLE "BP_Sonstiges"."BP_KennzeichnungsFlaeche" TO xp_gast;
GRANT ALL ON TABLE "BP_Sonstiges"."BP_KennzeichnungsFlaeche" TO bp_user;
COMMENT ON TABLE  "BP_Sonstiges"."BP_KennzeichnungsFlaeche" IS 'Flächen für Kennzeichnungen gemäß §9 Abs. 5 BauGB.';
COMMENT ON COLUMN  "BP_Sonstiges"."BP_KennzeichnungsFlaeche"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_BP_KennzeichnungsFlaeche" BEFORE INSERT OR UPDATE ON "BP_Sonstiges"."BP_KennzeichnungsFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_BP_KennzeichnungsFlaeche" AFTER DELETE ON "BP_Sonstiges"."BP_KennzeichnungsFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "BP_KennzeichnungsFlaeche_Flaechenobjekt" BEFORE INSERT OR UPDATE ON "BP_Sonstiges"."BP_KennzeichnungsFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isFlaechenobjekt"();

-- -----------------------------------------------------
-- Table BP_Sonstiges"."BP_KennzeichnungsFlaeche_zweckbestimmung"
-- -----------------------------------------------------
CREATE  TABLE  "BP_Sonstiges"."BP_KennzeichnungsFlaeche_zweckbestimmung" (
  "BP_KennzeichnungsFlaeche_gid" BIGINT NOT NULL ,
  "zweckbestimmung" INTEGER NULL ,
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

-- -----------------------------------------------------
-- Table "BP_Landwirtschaft_Wald_und_Gruen"."BP_Landwirtschaft_zweckbestimmung"
-- -----------------------------------------------------
CREATE  TABLE  "BP_Landwirtschaft_Wald_und_Gruen"."BP_Landwirtschaft_zweckbestimmung" (
  "BP_Landwirtschaft_gid" BIGINT NOT NULL ,
  "zweckbestimmung" INTEGER NULL ,
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
  "detaillierteZweckbestimmung" INTEGER NULL ,
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
-- Table "BP_Landwirtschaft_Wald_und_Gruen"."BP_LandwirtschaftFlaeche"
-- -----------------------------------------------------
CREATE  TABLE  "BP_Landwirtschaft_Wald_und_Gruen"."BP_LandwirtschaftFlaeche" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_BP_LandwirtschaftFlaeche_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "BP_Landwirtschaft_Wald_und_Gruen"."BP_Landwirtschaft" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("BP_Basisobjekte"."BP_Flaechenobjekt");

GRANT SELECT ON TABLE "BP_Landwirtschaft_Wald_und_Gruen"."BP_LandwirtschaftFlaeche" TO xp_gast;
GRANT ALL ON TABLE "BP_Landwirtschaft_Wald_und_Gruen"."BP_LandwirtschaftFlaeche" TO bp_user;
CREATE TRIGGER "change_to_BP_LandwirtschaftFlaeche" BEFORE INSERT OR UPDATE ON "BP_Landwirtschaft_Wald_und_Gruen"."BP_LandwirtschaftFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_BP_LandwirtschaftFlaeche" AFTER DELETE ON "BP_Landwirtschaft_Wald_und_Gruen"."BP_LandwirtschaftFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "BP_LandwirtschaftFlaeche_Flaechenobjekt" BEFORE INSERT OR UPDATE ON "BP_Landwirtschaft_Wald_und_Gruen"."BP_LandwirtschaftFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isFlaechenobjekt"();

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

GRANT SELECT ON TABLE "BP_Landwirtschaft_Wald_und_Gruen"."BP_LandwirtschaftLinie" TO xp_gast;
GRANT ALL ON TABLE "BP_Landwirtschaft_Wald_und_Gruen"."BP_LandwirtschaftLinie" TO bp_user;
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

GRANT SELECT ON TABLE "BP_Landwirtschaft_Wald_und_Gruen"."BP_LandwirtschaftPunkt" TO xp_gast;
GRANT ALL ON TABLE "BP_Landwirtschaft_Wald_und_Gruen"."BP_LandwirtschaftPunkt" TO bp_user;
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

-- -----------------------------------------------------
-- Table "BP_Sonstiges"."BP_NutzungsartenGrenze"
-- -----------------------------------------------------
CREATE  TABLE  "BP_Sonstiges"."BP_NutzungsartenGrenze" (
  "gid" BIGINT NOT NULL ,
  "typ" INTEGER NOT NULL DEFAULT 1000,
  "detailTyp" INTEGER NOT NULL DEFAULT 1000,
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
COMMENT ON TABLE  "BP_Aufschuettung_Abgrabung_Bodenschaetze"."BP_RekultivierungsFlaeche" IS 'Rekultivierungs-Fläche ';
COMMENT ON COLUMN  "BP_Aufschuettung_Abgrabung_Bodenschaetze"."BP_RekultivierungsFlaeche"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_BP_RekultivierungsFlaeche" BEFORE INSERT OR UPDATE ON "BP_Aufschuettung_Abgrabung_Bodenschaetze"."BP_RekultivierungsFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_BP_RekultivierungsFlaeche" AFTER DELETE ON "BP_Aufschuettung_Abgrabung_Bodenschaetze"."BP_RekultivierungsFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "BP_RekultivierungsFlaeche_Flaechenobjekt" BEFORE INSERT OR UPDATE ON "BP_Aufschuettung_Abgrabung_Bodenschaetze"."BP_RekultivierungsFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isFlaechenobjekt"();

-- -----------------------------------------------------
-- Table "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_DetailZweckbestNaturschutzgebiet"
-- -----------------------------------------------------
CREATE  TABLE  "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_DetailZweckbestNaturschutzgebiet" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Code") );
GRANT SELECT ON "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_DetailZweckbestNaturschutzgebiet" TO xp_gast;

-- -----------------------------------------------------
-- Table "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_Schutzgebiet"
-- -----------------------------------------------------
CREATE  TABLE  "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_Schutzgebiet" (
  "gid" BIGINT NOT NULL ,
  "zweckbestimmung" INTEGER,
  "detaillierteZweckbestimmung" INTEGER,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_BP_Schutzgebiet_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "BP_Basisobjekte"."BP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_SO_SchutzgebietNaturschutzrecht_zweckbestimmung"
    FOREIGN KEY ("zweckbestimmung")
    REFERENCES "XP_Enumerationen"."XP_KlassifizSchutzgebietNaturschutzrecht" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_SO_SchutzgebietNaturschutzrecht_detaillierteZweckbestimmung"
    FOREIGN KEY ("detaillierteZweckbestimmung")
    REFERENCES "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_DetailZweckbestNaturschutzgebiet" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE);

GRANT SELECT ON TABLE "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_Schutzgebiet" TO xp_gast;
GRANT ALL ON TABLE "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_Schutzgebiet" TO bp_user;
COMMENT ON TABLE  "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_Schutzgebiet" IS 'Umgrenzung von Schutzgebieten und Schutzobjekten im Sinne des Naturschutzrechts (§9 Abs. 4 BauGB), sofern es sich um eine Festsetzung des Bebauungsplans handelt.';
COMMENT ON COLUMN  "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_Schutzgebiet"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN  "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_Schutzgebiet"."zweckbestimmung" IS 'Zweckbestimmung des Schutzgebiets';
COMMENT ON COLUMN  "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_Schutzgebiet"."detaillierteZweckbestimmung" IS 'Über eine CodeList definierte Zweckbestimmung des Schutzgebietes.';
CREATE TRIGGER "change_to_BP_Schutzgebiet" BEFORE INSERT OR UPDATE ON "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_Schutzgebiet" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_BP_Schutzgebiet" AFTER DELETE ON "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_Schutzgebiet" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_SchutzgebietFlaeche"
-- -----------------------------------------------------
CREATE  TABLE  "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_SchutzgebietFlaeche" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_BP_SchutzgebietFlaeche_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_Schutzgebiet" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("BP_Basisobjekte"."BP_Flaechenobjekt");

GRANT SELECT ON TABLE "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_SchutzgebietFlaeche" TO xp_gast;
GRANT ALL ON TABLE "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_SchutzgebietFlaeche" TO bp_user;
CREATE TRIGGER "change_to_BP_SchutzgebietFlaeche" BEFORE INSERT OR UPDATE ON "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_SchutzgebietFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_BP_SchutzgebietFlaeche" AFTER DELETE ON "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_SchutzgebietFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "BP_SchutzgebietFlaeche_Flaechenobjekt" BEFORE INSERT OR UPDATE ON "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_SchutzgebietFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isFlaechenobjekt"();

-- -----------------------------------------------------
-- Table "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_SchutzgebietLinie"
-- -----------------------------------------------------
CREATE  TABLE  "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_SchutzgebietLinie" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_BP_SchutzgebietLinie_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_Schutzgebiet" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("BP_Basisobjekte"."BP_Linienobjekt");

GRANT SELECT ON TABLE "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_SchutzgebietLinie" TO xp_gast;
GRANT ALL ON TABLE "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_SchutzgebietLinie" TO bp_user;
CREATE TRIGGER "change_to_BP_SchutzgebietLinie" BEFORE INSERT OR UPDATE ON "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_SchutzgebietLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_BP_SchutzgebietLinie" AFTER DELETE ON "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_SchutzgebietLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_SchutzgebietPunkt"
-- -----------------------------------------------------
CREATE  TABLE  "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_SchutzgebietPunkt" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_BP_SchutzgebietPunkt_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_Schutzgebiet" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("BP_Basisobjekte"."BP_Punktobjekt");

GRANT SELECT ON TABLE "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_SchutzgebietPunkt" TO xp_gast;
GRANT ALL ON TABLE "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_SchutzgebietPunkt" TO bp_user;
CREATE TRIGGER "change_to_BP_SchutzgebietPunkt" BEFORE INSERT OR UPDATE ON "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_SchutzgebietPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_BP_SchutzgebietPunkt" AFTER DELETE ON "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_SchutzgebietPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_SchutzPflegeEntwicklungsFlaeche"
-- -----------------------------------------------------
CREATE  TABLE  "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_SchutzPflegeEntwicklungsFlaeche" (
  "gid" BIGINT NOT NULL ,
  "ziel" INTEGER NULL ,
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
    ON UPDATE CASCADE);

CREATE INDEX "idx_fk_BP_SchutzPflegeEntwicklungsFlaeche_XP_SPEZiele" ON "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_SchutzPflegeEntwicklungsFlaeche" ("ziel") ;
CREATE INDEX "idx_fk_BP_SchutzPflegeEntwicklungsFlaeche_refMassnahmenText" ON "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_SchutzPflegeEntwicklungsFlaeche" ("refMassnahmenText") ;
CREATE INDEX "idx_fk_BP_SchutzPflegeEntwicklungsFlaeche_refLandschaftsplan" ON "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_SchutzPflegeEntwicklungsFlaeche" ("refLandschaftsplan") ;
GRANT SELECT ON TABLE "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_SchutzPflegeEntwicklungsFlaeche" TO xp_gast;
GRANT ALL ON TABLE "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_SchutzPflegeEntwicklungsFlaeche" TO bp_user;
COMMENT ON TABLE  "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_SchutzPflegeEntwicklungsFlaeche" IS 'Flächen und Maßnahmen zum Ausgleich gemäß §5, Abs. 2a BauBG.';
COMMENT ON COLUMN  "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_SchutzPflegeEntwicklungsFlaeche"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN  "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_SchutzPflegeEntwicklungsFlaeche"."ziel" IS 'Unterscheidung nach den Zielen "Schutz, Pflege" und "Entwicklung".';
COMMENT ON COLUMN  "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_SchutzPflegeEntwicklungsFlaeche"."istAusgleich" IS 'Gibt an, ob die Maßnahme zum Ausgkeich eines Eingriffs benutzt wird.';
CREATE TRIGGER "change_to_BP_SchutzPflegeEntwicklungsFlaeche" BEFORE INSERT OR UPDATE ON "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_SchutzPflegeEntwicklungsFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_BP_SchutzPflegeEntwicklungsFlaeche" AFTER DELETE ON "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_SchutzPflegeEntwicklungsFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "BP_SchutzPflegeEntwicklungsFlaeche_Flaechenobjekt" BEFORE INSERT OR UPDATE ON "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_SchutzPflegeEntwicklungsFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isFlaechenobjekt"();

-- -----------------------------------------------------
-- Table "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_SchutzPflegeEntwicklungsFlaeche_massnahme"
-- -----------------------------------------------------
CREATE  TABLE  "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_SchutzPflegeEntwicklungsFlaeche_massnahme" (
  "BP_SchutzPflegeEntwicklungsFlaeche_gid" BIGINT NOT NULL ,
  "massnahme" INTEGER NULL ,
  PRIMARY KEY ("BP_SchutzPflegeEntwicklungsFlaeche_gid", "massnahme"),
  CONSTRAINT "fk_BP_SchutzPflegeEntwicklungsFlaeche_massnahme1"
    FOREIGN KEY ("BP_SchutzPflegeEntwicklungsFlaeche_gid" )
    REFERENCES "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_SchutzPflegeEntwicklungsFlaeche" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_BP_SchutzPflegeEntwicklungsFlaeche_massnahme2"
    FOREIGN KEY ("massnahme" )
    REFERENCES "XP_Sonstiges"."XP_SPEMassnahmenDaten" ("id" )
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
COMMENT ON TABLE  "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_SchutzPflegeEntwicklungsMassnahme" IS 'Flächen und Maßnahmen zum Ausgleich gemäß §5, Abs. 2a BauBG.';
COMMENT ON COLUMN  "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_SchutzPflegeEntwicklungsMassnahme"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN  "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_SchutzPflegeEntwicklungsMassnahme"."ziel" IS 'Unterscheidung nach den Zielen "Schutz, Pflege" und "Entwicklung".';
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
  "massnahme" INTEGER NULL ,
  PRIMARY KEY ("BP_SchutzPflegeEntwicklungsMassnahme_gid", "massnahme"),
  CONSTRAINT "fk_BP_SchutzPflegeEntwicklungsMassnahme_massnahme1"
    FOREIGN KEY ("BP_SchutzPflegeEntwicklungsMassnahme_gid" )
    REFERENCES "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_SchutzPflegeEntwicklungsMassnahme" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_BP_SchutzPflegeEntwicklungsMassnahme_massnahme2"
    FOREIGN KEY ("massnahme" )
    REFERENCES "XP_Sonstiges"."XP_SPEMassnahmenDaten" ("id" )
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
COMMENT ON TABLE  "BP_Verkehr"."BP_StrassenbegrenzungsLinie" IS 'Straßenbegrenzungslinie (§9 Abs. 1 Nr. 11 und Abs. 6 BauGB).';
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
    FOREIGN KEY ("ziel" )
    REFERENCES "XP_Enumerationen"."XP_SPEZiele" ("Code" )
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
COMMENT ON TABLE "BP_Sonstiges"."BP_TextlicheFestsetzungsFlaeche" IS 'Bereich in dem bestimmte Textliche Festsetzungen gültig sind, die über die Relation "refTextInhalt" (Basisklasse XP_Objekt) spezifiziert werden.';
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
COMMENT ON COLUMN "BP_Sonstiges"."BP_UnverbindlicheVormerkungPunkt"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_BP_UnverbindlicheVormerkungPunkt" BEFORE INSERT OR UPDATE ON "BP_Sonstiges"."BP_UnverbindlicheVormerkungPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_BP_UnverbindlicheVormerkungPunkt" AFTER DELETE ON "BP_Sonstiges"."BP_UnverbindlicheVormerkungPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

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
    g."gehoertZuBP_Bereich" AS "BP_Bereich_gid",
    bp_o."Objektart",
    bp_o."Objektartengruppe"
   FROM ( SELECT o.gid,
            c.relname::character varying AS "Objektart",
            n.nspname::character varying AS "Objektartengruppe"
           FROM ( SELECT p.gid,
                    p.tableoid
                   FROM "BP_Basisobjekte"."BP_Punktobjekt" p
                UNION
                 SELECT "BP_Linienobjekt".gid,
                    "BP_Linienobjekt".tableoid
                   FROM "BP_Basisobjekte"."BP_Linienobjekt"
                UNION
                 SELECT "BP_Flaechenobjekt".gid,
                    "BP_Flaechenobjekt".tableoid
                   FROM "BP_Basisobjekte"."BP_Flaechenobjekt") o
             JOIN pg_class c ON o.tableoid = c.oid
             JOIN pg_namespace n ON c.relnamespace = n.oid) bp_o
     LEFT JOIN "BP_Basisobjekte"."BP_Objekt_gehoertZuBP_Bereich" g ON bp_o.gid = g."BP_Objekt_gid";

GRANT ALL ON TABLE "BP_Basisobjekte"."BP_Objekte" TO "StroeblB";
GRANT SELECT ON TABLE "BP_Basisobjekte"."BP_Objekte" TO xp_gast;

-- *****************************************************
-- INSERT DATA
-- *****************************************************

-- -----------------------------------------------------
-- Data for table "BP_Verkehr"."BP_StrassenkoerperHerstellung"
-- -----------------------------------------------------
INSERT INTO "BP_Verkehr"."BP_StrassenkoerperHerstellung" ("Code", "Bezeichner") VALUES ('1000', 'Aufschuettung');
INSERT INTO "BP_Verkehr"."BP_StrassenkoerperHerstellung" ("Code", "Bezeichner") VALUES ('2000', 'Abgrabung');
INSERT INTO "BP_Verkehr"."BP_StrassenkoerperHerstellung" ("Code", "Bezeichner") VALUES ('3000', 'Stuetzmauer');

-- -----------------------------------------------------
-- Data for table "BP_Basisobjekte"."BP_Verfahren"
-- -----------------------------------------------------
INSERT INTO "BP_Basisobjekte"."BP_Verfahren" ("Code", "Bezeichner") VALUES ('1000', 'Normal');
INSERT INTO "BP_Basisobjekte"."BP_Verfahren" ("Code", "Bezeichner") VALUES ('2000', 'Parag13');
INSERT INTO "BP_Basisobjekte"."BP_Verfahren" ("Code", "Bezeichner") VALUES ('3000', 'Parag13a');

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
INSERT INTO "BP_Basisobjekte"."BP_Rechtscharakter" ("Code", "Bezeichner") VALUES ('3000', 'Hinweis');
INSERT INTO "BP_Basisobjekte"."BP_Rechtscharakter" ("Code", "Bezeichner") VALUES ('4000', 'Vermerk');
INSERT INTO "BP_Basisobjekte"."BP_Rechtscharakter" ("Code", "Bezeichner") VALUES ('5000', 'Kennzeichnung');

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
INSERT INTO "BP_Sonstiges"."BP_AbgrenzungenTypen" ("Code", "Bezeichner") VALUES ('9999', 'SonstigeAbgrenzung');



