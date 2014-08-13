-- -----------------------------------------------------
-- Objektbereich:FP_ Fachschema FPlan
--
--Dieses Paket enthält alle Klassen von FPlan-Fachobjekten. Jede dieser Klassen modelliert eine nach BauGB mögliche Darstellung, Kennzeichnung, Vermerk oder eine Hinweis in einem Flächennutzungsplan.

-- *****************************************************
-- CREATE GROUP ROLES
-- *****************************************************

-- editierende Rolle für FP_Fachschema_FPlan
CREATE ROLE fp_user
  NOSUPERUSER NOINHERIT NOCREATEDB NOCREATEROLE;
GRANT xp_gast TO fp_user;
GRANT xp_user TO fp_user;

-- *****************************************************
-- CREATE SCHEMAS
-- *****************************************************

CREATE SCHEMA "FP_Basisobjekte";
CREATE SCHEMA "FP_Raster";
CREATE SCHEMA "FP_Bebauung";
CREATE SCHEMA "FP_Gemeinbedarf_Spiel_und_Sportanlagen";
CREATE SCHEMA "FP_Landwirtschaft_Wald_und_Gruen";
CREATE SCHEMA "FP_Naturschutz";
CREATE SCHEMA "FP_Sonstiges";
CREATE SCHEMA "FP_Ver_und_Entsorgung";
CREATE SCHEMA "FP_Verkehr";
CREATE SCHEMA "FP_Wasser";
CREATE SCHEMA "FP_Aufschuettung_Abgrabung";

COMMENT ON SCHEMA "FP_Basisobjekte" IS 'Das Paket enthält die Klassen zur Modellierung eines FPlans (abgeleitet von XP_Plan) und eines FPlan-Bereichs (abgeleitet von XP_Bereich), sowie die Basisklassen für FPlan-Fachobjekte.';
COMMENT ON SCHEMA "FP_Raster" IS 'Raster-Darstellung von FPlänen';
COMMENT ON SCHEMA "FP_Bebauung" IS 'Darstellung der für die Bebauung vorgesehenen Flächen (§5, Abs. 2, Nr. 1 BauGB).';
COMMENT ON SCHEMA "FP_Gemeinbedarf_Spiel_und_Sportanlagen" IS 'Darstellung der Ausstattung des Gemeindegebiets mit Einrichtungen und Anlagen zur Versorgung mit Gütern und Dienstleistungen des öffentlichen und privaten Bereichs, sowie die Flächen für Spiel- und Sportanlagen (§5, Abs. 2, Nr. 2 BauGB).';
COMMENT ON SCHEMA "FP_Landwirtschaft_Wald_und_Gruen" IS 'Darstellung von Grünflächen (§5, Abs. 2, Nr. 5 BauGB) und von Flächen für die Landwirtschaft und Wald (§5, Abs. 2, Nr. 9 BauGB).';
COMMENT ON SCHEMA "FP_Naturschutz" IS 'Darstellung von Flächen für Maßnahmen zum Schutz, zur Pflege und zur Entwicklung von Boden, Natur und Landschaft (§5 Abs. 2 Nr. 10 BauGB).';
COMMENT ON SCHEMA "FP_Sonstiges" IS 'Sonstige Klassen von FPlan-Objekten.';
COMMENT ON SCHEMA "FP_Ver_und_Entsorgung" IS 'Darstellung von Flächen für Versorgungsanlagen, für die Abfallentsorgung und Abwasserbeseitigung, für Ablagerungen, sowie für Hauptversorgungs- und Hauptabwasserleitungen (§5, Abs. 2, Nr. 4 BauGB).';
COMMENT ON SCHEMA "FP_Verkehr" IS 'Darstellung von Flächen für den überörtlichen Verkehr sowie für die örtlichen Hauptverkehrszüge (§5, Abs. 2, Nr. 3 BauGB).';
COMMENT ON SCHEMA "FP_Wasser" IS 'Darstellung von Wasserflächen, Häfen, und den für die Wasserwirtschaft vorgesehenen Flächen, sowie von Flächen, die im Interesse des Hochwasserschutzes und der Regelung des Wasserabflusses freizuhalten sind (§5, Abs. 2, Nr. 7 BauGB).';
COMMENT ON SCHEMA "FP_Aufschuettung_Abgrabung" IS 'Darstellung von Flächen für Aufschüttungen, Abgrabungen oder für die Gewinnung von Steinen, Erden und anderen Bodenschätzen (§5, Abs. 2, Nr. 8 BauGB).';

GRANT USAGE ON SCHEMA "FP_Basisobjekte" TO xp_gast;
GRANT USAGE ON SCHEMA "FP_Raster" TO xp_gast;
GRANT USAGE ON SCHEMA "FP_Bebauung" TO xp_gast;
GRANT USAGE ON SCHEMA "FP_Gemeinbedarf_Spiel_und_Sportanlagen" TO xp_gast;
GRANT USAGE ON SCHEMA "FP_Landwirtschaft_Wald_und_Gruen" TO xp_gast;
GRANT USAGE ON SCHEMA "FP_Naturschutz" TO xp_gast;
GRANT USAGE ON SCHEMA "FP_Sonstiges" TO xp_gast;
GRANT USAGE ON SCHEMA "FP_Ver_und_Entsorgung" TO xp_gast;
GRANT USAGE ON SCHEMA "FP_Verkehr" TO xp_gast;
GRANT USAGE ON SCHEMA "FP_Wasser" TO xp_gast;
GRANT USAGE ON SCHEMA "FP_Aufschuettung_Abgrabung" TO xp_gast;

-- *****************************************************
-- CREATE TRIGGER FUNCTIONs
-- *****************************************************

CREATE OR REPLACE FUNCTION "FP_Basisobjekte"."new_FP_Bereich"() 
RETURNS trigger AS
$BODY$
 DECLARE
    fp_plan_gid integer;
 BEGIN
    SELECT max(gid) from "FP_Basisobjekte"."FP_Plan" INTO fp_plan_gid;

    IF fp_plan_gid IS NULL THEN
        RETURN NULL;
    ELSE
        new."gehoertZuPlan" := fp_plan_gid;
        RETURN new;
    END IF;
 END; $BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
GRANT EXECUTE ON FUNCTION "FP_Basisobjekte"."new_FP_Bereich"() TO fp_user;


-- *****************************************************
-- CREATE TABLEs 
-- *****************************************************

-- -----------------------------------------------------
-- Table "FP_Basisobjekte"."FP_SonstPlanArt"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Basisobjekte"."FP_SonstPlanArt" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Code") );
GRANT SELECT ON TABLE "FP_Basisobjekte"."FP_SonstPlanArt" TO xp_gast;
GRANT ALL ON TABLE "FP_Basisobjekte"."FP_SonstPlanArt" TO fp_user;

-- -----------------------------------------------------
-- Table "FP_Basisobjekte"."FP_Verfahren"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Basisobjekte"."FP_Verfahren" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Code") );
GRANT SELECT ON TABLE "FP_Basisobjekte"."FP_Verfahren" TO xp_gast;

-- -----------------------------------------------------
-- Table "FP_Basisobjekte"."FP_Status"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Basisobjekte"."FP_Status" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Code") );
GRANT SELECT ON TABLE "FP_Basisobjekte"."FP_Status" TO xp_gast;
GRANT ALL ON TABLE "FP_Basisobjekte"."FP_Status" TO fp_user;

-- -----------------------------------------------------
-- Table "FP_Basisobjekte"."FP_Rechtsstand"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Basisobjekte"."FP_Rechtsstand" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Code") );
GRANT SELECT ON TABLE "FP_Basisobjekte"."FP_Rechtsstand" TO xp_gast;

-- -----------------------------------------------------
-- Table "FP_Basisobjekte"."FP_PlanArt"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Basisobjekte"."FP_PlanArt" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Code") );
GRANT SELECT ON TABLE "FP_Basisobjekte"."FP_PlanArt" TO xp_gast;

-- -----------------------------------------------------
-- Table "FP_Basisobjekte"."FP_Plan"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Basisobjekte"."FP_Plan" (
  "gid" BIGINT NOT NULL ,
  "name" VARCHAR (256) NOT NULL,
  "plangeber" INTEGER NULL ,
  "planArt" INTEGER NULL ,
  "sonstPlanArt" INTEGER NULL ,
  "sachgebiet" VARCHAR (256) NULL,
  "verfahren" INTEGER NULL ,
  "rechtsstand" INTEGER NULL ,
  "status" INTEGER NULL ,
  "aufstellungsbechlussDatum" DATE NULL ,
  "auslegungsStartDatum" DATE NULL ,
  "auslegungsEndDatum" DATE NULL ,
  "traegerbeteiligungsStartDatum" DATE NULL ,
  "traegerbeteiligungsEndDatum" DATE NULL ,
  "aenderungenBisDatum" DATE NULL ,
  "entwurfsbeschlussDatum" DATE NULL ,
  "planbeschlussDatum" DATE NULL ,
  "wirksamkeitsDatum" DATE NULL ,
  "refUmweltbericht" INTEGER NULL ,
  "refErlaeuterung" INTEGER NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_fp_plan_xp_plangeber1"
    FOREIGN KEY ("plangeber" )
    REFERENCES "XP_Sonstiges"."XP_Plangeber" ("id" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_fp_plan_fp_sonstplanart1"
    FOREIGN KEY ("sonstPlanArt" )
    REFERENCES "FP_Basisobjekte"."FP_SonstPlanArt" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_fp_plan_fp_verfahren1"
    FOREIGN KEY ("verfahren" )
    REFERENCES "FP_Basisobjekte"."FP_Verfahren" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_fp_plan_fp_status1"
    FOREIGN KEY ("status" )
    REFERENCES "FP_Basisobjekte"."FP_Status" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_fp_plan_fp_rechtsstand1"
    FOREIGN KEY ("rechtsstand" )
    REFERENCES "FP_Basisobjekte"."FP_Rechtsstand" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_fp_plan_xp_externereferenz1"
    FOREIGN KEY ("refUmweltbericht" )
    REFERENCES "XP_Basisobjekte"."XP_ExterneReferenz" ("id" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_fp_plan_xp_externereferenz2"
    FOREIGN KEY ("refErlaeuterung" )
    REFERENCES "XP_Basisobjekte"."XP_ExterneReferenz" ("id" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_Plan_XP_Plan1"
    FOREIGN KEY ("gid" )
    REFERENCES "XP_Basisobjekte"."XP_Plan" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_Plan_FP_PlanArt1"
    FOREIGN KEY ("planArt" )
    REFERENCES "FP_Basisobjekte"."FP_PlanArt" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE)
INHERITS("XP_Basisobjekte"."XP_RaeumlicherGeltungsbereich");

CREATE INDEX "idx_fk_fp_plan_xp_plangeber1" ON "FP_Basisobjekte"."FP_Plan" ("plangeber") ;
CREATE INDEX "idx_fk_fp_plan_fp_sonstplanart1" ON "FP_Basisobjekte"."FP_Plan" ("sonstPlanArt") ;
CREATE INDEX "idx_fk_fp_plan_fp_verfahren1" ON "FP_Basisobjekte"."FP_Plan" ("verfahren") ;
CREATE INDEX "idx_fk_fp_plan_fp_status1" ON "FP_Basisobjekte"."FP_Plan" ("status") ;
CREATE INDEX "idx_fk_fp_plan_fp_rechtsstand1" ON "FP_Basisobjekte"."FP_Plan" ("rechtsstand") ;
CREATE INDEX "idx_fk_fp_plan_xp_externereferenz4" ON "FP_Basisobjekte"."FP_Plan" ("refUmweltbericht") ;
GRANT SELECT ON TABLE "FP_Basisobjekte"."FP_Plan" TO xp_gast;
GRANT ALL ON TABLE "FP_Basisobjekte"."FP_Plan" TO fp_user;
COMMENT ON TABLE "FP_Basisobjekte"."FP_Plan" IS 'Klasse zur Modellierung eines gesamten Flächennutzungsplans.';
COMMENT ON COLUMN "FP_Basisobjekte"."FP_Plan"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN "FP_Basisobjekte"."FP_Plan"."name" IS 'Name des Plans. Der Name kann hier oder in XP_Plan geändert werden.';
COMMENT ON COLUMN "FP_Basisobjekte"."FP_Plan"."plangeber" IS 'Für die Planung zuständige Institution';
COMMENT ON COLUMN "FP_Basisobjekte"."FP_Plan"."planArt" IS 'Typ des FPlans';
COMMENT ON COLUMN "FP_Basisobjekte"."FP_Plan"."sonstPlanArt" IS 'Sonstige Art eines FPlans bei planArt == 9999.';
COMMENT ON COLUMN "FP_Basisobjekte"."FP_Plan"."sachgebiet" IS 'Sachgebiet eines Teilflächennutzungsplans.';
COMMENT ON COLUMN "FP_Basisobjekte"."FP_Plan"."verfahren" IS 'Verfahren nach dem ein FPlan aufgestellt oder geändert wird.';
COMMENT ON COLUMN "FP_Basisobjekte"."FP_Plan"."rechtsstand" IS 'Rechtsstand des Plans';
COMMENT ON COLUMN "FP_Basisobjekte"."FP_Plan"."status" IS 'Über eine ExternalCodeList definierter Status des Plans.';
COMMENT ON COLUMN "FP_Basisobjekte"."FP_Plan"."aufstellungsbechlussDatum" IS 'Datum des Plan-Aufstellungsbeschlusses.';
COMMENT ON COLUMN "FP_Basisobjekte"."FP_Plan"."auslegungsStartDatum" IS 'Start-Datum der öffentlichen Auslegung.';
COMMENT ON COLUMN "FP_Basisobjekte"."FP_Plan"."auslegungsEndDatum" IS 'End-Datum der öffentlichen Auslegung.';
COMMENT ON COLUMN "FP_Basisobjekte"."FP_Plan"."traegerbeteiligungsStartDatum" IS 'Start-Datum der Trägerbeteiligung.';
COMMENT ON COLUMN "FP_Basisobjekte"."FP_Plan"."traegerbeteiligungsEndDatum" IS 'End-Datum der Trägerbeteiligung.';
COMMENT ON COLUMN "FP_Basisobjekte"."FP_Plan"."aenderungenBisDatum" IS 'Datum, bis zu dem Änderungen des Plans berücksichtigt wurden.';
COMMENT ON COLUMN "FP_Basisobjekte"."FP_Plan"."entwurfsbeschlussDatum" IS 'Datum des Entwurfsbeschlusses';
COMMENT ON COLUMN "FP_Basisobjekte"."FP_Plan"."planbeschlussDatum" IS 'Datum des Planbeschlusses';
COMMENT ON COLUMN "FP_Basisobjekte"."FP_Plan"."wirksamkeitsDatum" IS 'Datum der Wirksamkeit';
COMMENT ON COLUMN "FP_Basisobjekte"."FP_Plan"."refUmweltbericht" IS 'Referenz auf den Umweltbericht.';
COMMENT ON COLUMN "FP_Basisobjekte"."FP_Plan"."refErlaeuterung" IS 'Referenz auf den Erläuterungsbericht.';
CREATE TRIGGER "change_to_FP_Plan" BEFORE INSERT OR UPDATE OR DELETE ON "FP_Basisobjekte"."FP_Plan" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Plan"();
CREATE TRIGGER "FP_Plan_propagate_name" AFTER UPDATE ON "FP_Basisobjekte"."FP_Plan" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."propagate_name_to_parent"();
SELECT "XP_Basisobjekte".registergeometrycolumn('','FP_Basisobjekte','FP_Plan', 'raeumlicherGeltungsbereich','MULTIPOLYGON',2);

-- -----------------------------------------------------
-- Table "FP_Basisobjekte"."FP_Bereich"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Basisobjekte"."FP_Bereich" (
  "gid" BIGINT NOT NULL ,
  "name" VARCHAR (256) NOT NULL,
  "versionBauNVO" INTEGER NULL ,
  "versionBauNVOText" VARCHAR(255) NULL ,
  "versionBauGB" DATE NULL ,
  "versionBauGBText" VARCHAR(255) NULL ,
  "gehoertZuPlan" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_Bereich_FP_Plan1"
    FOREIGN KEY ("gehoertZuPlan" )
    REFERENCES "FP_Basisobjekte"."FP_Plan" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_Bereich_XP_VersionBauNVO1"
    FOREIGN KEY ("versionBauNVO" )
    REFERENCES "XP_Enumerationen"."XP_VersionBauNVO" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_Bereich_XP_Bereich1"
    FOREIGN KEY ("gid" )
    REFERENCES "XP_Basisobjekte"."XP_Bereich" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("XP_Basisobjekte"."XP_Geltungsbereich");

CREATE INDEX "idx_fk_FP_Bereich_FP_Plan1" ON "FP_Basisobjekte"."FP_Bereich" ("gehoertZuPlan") ;
CREATE INDEX "idx_fk_FP_Bereich_XP_VersionBauNVO1" ON "FP_Basisobjekte"."FP_Bereich" ("versionBauNVO") ;
GRANT SELECT ON TABLE "FP_Basisobjekte"."FP_Bereich" TO xp_gast;
GRANT ALL ON TABLE "FP_Basisobjekte"."FP_Bereich" TO fp_user;
COMMENT ON TABLE "FP_Basisobjekte"."FP_Bereich" IS 'Diese Klasse modelliert einen Bereich eines Flächennutzungsplans.';
COMMENT ON COLUMN "FP_Basisobjekte"."FP_Bereich"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN "FP_Basisobjekte"."FP_Bereich"."name" IS 'Bezeichnung des Bereiches. Die Bezeichnung kann hier oder in XP_Bereich geändert werden.';
COMMENT ON COLUMN "FP_Basisobjekte"."FP_Bereich"."versionBauNVO" IS 'Benutzte Version der BauNVO';
COMMENT ON COLUMN "FP_Basisobjekte"."FP_Bereich"."versionBauNVOText" IS 'Textliche Spezifikation einer anderen Gesetzesgrundlage als der BauNVO. In diesem Fall muss das Attribut versionBauNVO den Wert 9999 haben.';
COMMENT ON COLUMN "FP_Basisobjekte"."FP_Bereich"."versionBauGB" IS 'Datum der zugrunde liegenden Version des BauGB.';
COMMENT ON COLUMN "FP_Basisobjekte"."FP_Bereich"."versionBauGBText" IS 'Zugrunde liegende Version des BauGB.';
COMMENT ON COLUMN "FP_Basisobjekte"."FP_Bereich"."gehoertZuPlan" IS '';
CREATE TRIGGER "change_to_FP_Bereich" BEFORE INSERT OR UPDATE OR DELETE ON "FP_Basisobjekte"."FP_Bereich" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Bereich"();
CREATE TRIGGER "insert_into_FP_Bereich" BEFORE INSERT ON "FP_Basisobjekte"."FP_Bereich" FOR EACH ROW EXECUTE PROCEDURE "FP_Basisobjekte"."new_FP_Bereich"();
CREATE TRIGGER "FP_Bereich_propagate_name" AFTER UPDATE ON "FP_Basisobjekte"."FP_Bereich" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."propagate_name_to_parent"();
SELECT "XP_Basisobjekte".registergeometrycolumn('','FP_Basisobjekte','FP_Bereich', 'geltungsbereich','MULTIPOLYGON',2);
  
-- -----------------------------------------------------
-- Table "FP_Basisobjekte"."FP_Rechtscharakter"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Basisobjekte"."FP_Rechtscharakter" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Code") );
GRANT SELECT ON TABLE "FP_Basisobjekte"."FP_Rechtscharakter" TO xp_gast;


-- -----------------------------------------------------
-- Table "FP_Basisobjekte"."FP_TextAbschnitt"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Basisobjekte"."FP_TextAbschnitt" (
  "id" INTEGER NOT NULL ,
  "rechtscharacter" INTEGER NOT NULL ,
  PRIMARY KEY ("id") ,
  CONSTRAINT "fk_FP_Textabschnitt_parent"
    FOREIGN KEY ("id" )
    REFERENCES "XP_Basisobjekte"."XP_TextAbschnitt" ("id" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_fp_textabschnitt_fp_rechtscharakter1"
    FOREIGN KEY ("rechtscharakter" )
    REFERENCES "FP_Basisobjekte"."FP_Rechtscharakter" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
CREATE INDEX "idx_fk_fp_textabschnitt_fp_rechtscharakter1" ON "FP_Basisobjekte"."FP_TextAbschnitt" ("rechtscharakter") ;
GRANT SELECT ON TABLE "FP_Basisobjekte"."FP_TextAbschnitt" TO xp_gast;
GRANT ALL ON TABLE "FP_Basisobjekte"."FP_TextAbschnitt" TO fp_user;
COMMENT ON TABLE  "FP_Basisobjekte"."FP_TextAbschnitt" IS 'Texlich formulierter Inhalt eines Flächennutzungsplans, der einen anderen Rechtscharakter als das zugrunde liegende Fachobjekt hat (Attribut "rechtscharakter" des Fachobjektes), oder dem Plan als Ganzes zugeordnet ist.';
COMMENT ON COLUMN  "FP_Basisobjekte"."FP_TextAbschnitt"."id" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN  "FP_Basisobjekte"."FP_TextAbschnitt"."rechtscharakter" IS 'Rechtscharakter des textlich formulierten Planinhalts. ';
CREATE TRIGGER "change_to_FP_TextAbschnitt" BEFORE INSERT OR UPDATE OR DELETE ON "FP_Basisobjekte"."FP_TextAbschnitt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_TextAbschnitt"();

-- -----------------------------------------------------
-- Table "FP_Basisobjekte"."FP_SpezifischePraegungTypen"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Basisobjekte"."FP_SpezifischePraegungTypen" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Code") );
GRANT SELECT ON TABLE "FP_Basisobjekte"."FP_SpezifischePraegungTypen" TO xp_gast;
GRANT ALL ON TABLE "FP_Basisobjekte"."FP_SpezifischePraegungTypen" TO fp_user;


-- -----------------------------------------------------
-- Table "FP_Basisobjekte"."FP_Objekt"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Basisobjekte"."FP_Objekt" (
  "gid" BIGINT NOT NULL ,
  "rechtscharakter" INTEGER NULL ,
  "spezifischePraegung" INTEGER NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_fp_objekt_fp_rechtscharakter1"
    FOREIGN KEY ("rechtscharakter" )
    REFERENCES "FP_Basisobjekte"."FP_Rechtscharakter" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT "fk_FP_Objekt_XP_Objekt1"
    FOREIGN KEY ("gid" )
    REFERENCES "XP_Basisobjekte"."XP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_Objekt_FP_SpezifischePraegungTypen1"
    FOREIGN KEY ("spezifischePraegung" )
    REFERENCES "FP_Basisobjekte"."FP_SpezifischePraegungTypen" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION);

CREATE INDEX "idx_fk_fp_objekt_fp_rechtscharakter1" ON "FP_Basisobjekte"."FP_Objekt" ("rechtscharakter") ;
CREATE INDEX "idx_fk_FP_Objekt_FP_SpezifischePraegungTypen1" ON "FP_Basisobjekte"."FP_Objekt" ("spezifischePraegung") ;
GRANT SELECT ON TABLE "FP_Basisobjekte"."FP_Objekt" TO xp_gast;
GRANT ALL ON TABLE "FP_Basisobjekte"."FP_Objekt" TO fp_user;
COMMENT ON TABLE  "FP_Basisobjekte"."FP_Objekt" IS 'Basisklasse für alle Fachobjekte des Flächennutzungsplans.';
COMMENT ON COLUMN  "FP_Basisobjekte"."FP_Objekt"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN  "FP_Basisobjekte"."FP_Objekt"."rechtscharakter" IS 'Rechtliche Charakterisierung des Planinhalts';
COMMENT ON COLUMN  "FP_Basisobjekte"."FP_Objekt"."spezifischePraegung" IS 'Spezifische bauliche Prägung einer Darstellung.';
CREATE TRIGGER "change_to_FP_Objekt" BEFORE INSERT OR UPDATE OR DELETE ON "FP_Basisobjekte"."FP_Objekt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "FP_Basisobjekte"."gehoertZuFP_Bereich"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Basisobjekte"."gehoertZuFP_Bereich" (
  "FP_Bereich_gid" BIGINT NOT NULL ,
  "FP_Objekt_gid" BIGINT NOT NULL ,
  PRIMARY KEY ("FP_Bereich_gid", "FP_Objekt_gid") ,
  CONSTRAINT "fk_gehoertzuFP_Bereich_FP_Bereich1"
    FOREIGN KEY ("FP_Bereich_gid" )
    REFERENCES "FP_Basisobjekte"."FP_Bereich" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_gehoertZuFP_Bereich_FP_Objekt1"
    FOREIGN KEY ("FP_Objekt_gid" )
    REFERENCES "FP_Basisobjekte"."FP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE);
CREATE INDEX "idx_fk_gehoertzuFP_Bereich_FP_Bereich1" ON "FP_Basisobjekte"."gehoertZuFP_Bereich" ("FP_Bereich_gid") ;
CREATE INDEX "idx_fk_gehoertZuFP_Bereich_FP_Objekt1" ON "FP_Basisobjekte"."gehoertZuFP_Bereich" ("FP_Objekt_gid") ;
GRANT SELECT ON TABLE "FP_Basisobjekte"."gehoertZuFP_Bereich" TO xp_gast;
GRANT ALL ON TABLE "FP_Basisobjekte"."gehoertZuFP_Bereich" TO fp_user;

-- -----------------------------------------------------
-- Table "FP_Basisobjekte"."gemeinde"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Basisobjekte"."gemeinde" (
  "FP_Plan_gid" BIGINT NOT NULL ,
  "XP_Gemeinde_id" INTEGER NOT NULL ,
  PRIMARY KEY ("FP_Plan_gid", "XP_Gemeinde_id") ,
  CONSTRAINT "fk_gemeinde_FP_Plan1"
    FOREIGN KEY ("FP_Plan_gid" )
    REFERENCES "FP_Basisobjekte"."FP_Plan" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_gemeinde_XP_Gemeinde1"
    FOREIGN KEY ("XP_Gemeinde_id" )
    REFERENCES "XP_Sonstiges"."XP_Gemeinde" ("id" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE);

CREATE INDEX "idx_fk_gemeinde_FP_Plan1" ON "FP_Basisobjekte"."gemeinde" ("FP_Plan_gid") ;
CREATE INDEX "idx_fk_gemeinde_XP_Gemeinde1" ON "FP_Basisobjekte"."gemeinde" ("XP_Gemeinde_id") ;
GRANT SELECT ON TABLE "FP_Basisobjekte"."gemeinde" TO xp_gast;
GRANT ALL ON TABLE "FP_Basisobjekte"."gemeinde" TO fp_user;
COMMENT ON TABLE  "FP_Basisobjekte"."gemeinde" IS 'Zuständige Gemeinde';

-- -----------------------------------------------------
-- Table "FP_Raster"."FP_RasterplanAenderung"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Raster"."FP_RasterplanAenderung" (
  "gid" BIGINT NOT NULL ,
  "aufstellungbeschlussDatum" DATE NULL ,
  "aenderungenBisDatum" DATE NULL ,
  "entwurfsbeschlussDatum" DATE NULL ,
  "planbeschlussDatum" DATE NULL ,
  "wirksamkeitsDatum" DATE NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_RasterplanAenderung1"
    FOREIGN KEY ("gid" )
    REFERENCES "XP_Raster"."XP_RasterplanAenderung" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("XP_Raster"."XP_GeltungsbereichAenderung");

GRANT SELECT ON TABLE "FP_Raster"."FP_RasterplanAenderung" TO xp_gast;
GRANT ALL ON TABLE "FP_Raster"."FP_RasterplanAenderung" TO fp_user;
COMMENT ON TABLE "FP_Raster"."FP_RasterplanAenderung" IS 'Georeferenziertes Rasterbild der Änderung eines Basisplans. Die abgeleitete Klasse besitzt Datums-Attribute, die spezifisch für Flächennutzungspläne sind.';
COMMENT ON COLUMN "FP_Raster"."FP_RasterplanAenderung"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN "FP_Raster"."FP_RasterplanAenderung"."aufstellungbeschlussDatum" IS '';
COMMENT ON COLUMN "FP_Raster"."FP_RasterplanAenderung"."aenderungenBisDatum" IS '';
COMMENT ON COLUMN "FP_Raster"."FP_RasterplanAenderung"."entwurfsbeschlussDatum" IS '';
COMMENT ON COLUMN "FP_Raster"."FP_RasterplanAenderung"."planbeschlussDatum" IS '';
COMMENT ON COLUMN "FP_Raster"."FP_RasterplanAenderung"."wirksamkeitsDatum" IS '';
CREATE TRIGGER "change_to_FP_RasterplanAenderung" BEFORE INSERT OR UPDATE OR DELETE ON "FP_Raster"."FP_RasterplanAenderung" FOR EACH ROW EXECUTE PROCEDURE "XP_Raster"."child_of_XP_RasterplanAenderung"();
SELECT "XP_Basisobjekte".registergeometrycolumn('','FP_Raster','FP_RasterplanAenderung', 'geltungsbereichAenderung','MULTIPOLYGON',2);

-- -----------------------------------------------------
-- Table "FP_Basisobjekte"."rasterAenderung"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Basisobjekte"."rasterAenderung" (
  "FP_Bereich_gid" BIGINT NOT NULL ,
  "FP_RasterplanAenderung_gid" BIGINT NOT NULL ,
  PRIMARY KEY ("FP_Bereich_gid", "FP_RasterplanAenderung_gid") ,
  CONSTRAINT "fk_rasterAenderung_FP_Bereich"
    FOREIGN KEY ("FP_Bereich_gid" )
    REFERENCES "FP_Basisobjekte"."FP_Bereich" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_rasterAenderung_FP_RasterplanAenderung"
    FOREIGN KEY ("FP_RasterplanAenderung_gid" )
    REFERENCES "FP_Raster"."FP_RasterplanAenderung" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE);

CREATE INDEX "idx_fk_rasterAenderung_FP_Bereich" ON "FP_Basisobjekte"."rasterAenderung" ("FP_Bereich_gid") ;
CREATE INDEX "idx_fk_rasterAenderung_FP_RasterplanAenderung" ON "FP_Basisobjekte"."rasterAenderung" ("FP_RasterplanAenderung_gid") ;
GRANT SELECT ON TABLE "FP_Basisobjekte"."rasterAenderung" TO xp_gast;
GRANT ALL ON TABLE "FP_Basisobjekte"."rasterAenderung" TO fp_user;

-- -----------------------------------------------------
-- Table "FP_Basisobjekte"."FP_Punktobjekt"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Basisobjekte"."FP_Punktobjekt" (
  "gid" BIGINT NOT NULL ,
  "position" GEOMETRY NOT NULL ,
  PRIMARY KEY ("gid") );
GRANT SELECT ON TABLE "FP_Basisobjekte"."FP_Punktobjekt" TO xp_gast;
GRANT ALL ON TABLE "FP_Basisobjekte"."FP_Punktobjekt" TO fp_user;
CREATE TRIGGER "FP_Punktobjekt_isAbstract" BEFORE INSERT ON "FP_Basisobjekte"."FP_Punktobjekt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isAbstract"();

-- -----------------------------------------------------
-- Table "FP_Basisobjekte"."FP_Linienobjekt"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Basisobjekte"."FP_Linienobjekt" (
  "gid" BIGINT NOT NULL ,
  "position" GEOMETRY NOT NULL ,
  PRIMARY KEY ("gid") );
GRANT SELECT ON TABLE "FP_Basisobjekte"."FP_Linienobjekt" TO xp_gast;
GRANT ALL ON TABLE "FP_Basisobjekte"."FP_Linienobjekt" TO fp_user;
CREATE TRIGGER "FP_Linienobjekt_isAbstract" BEFORE INSERT ON "FP_Basisobjekte"."FP_Linienobjekt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isAbstract"();

-- -----------------------------------------------------
-- Table "FP_Basisobjekte"."FP_Flaechenobjekt"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Basisobjekte"."FP_Flaechenobjekt" (
  "gid" BIGINT NOT NULL ,
  "position" GEOMETRY NOT NULL ,
  "flaechenschluss" BOOLEAN NOT NULL,
  PRIMARY KEY ("gid") );
GRANT SELECT ON TABLE "FP_Basisobjekte"."FP_Flaechenobjekt" TO xp_gast;
GRANT ALL ON TABLE "FP_Basisobjekte"."FP_Flaechenobjekt" TO fp_user;
CREATE TRIGGER "FP_Flaechenobjekt_isAbstract" BEFORE INSERT ON "FP_Basisobjekte"."FP_Flaechenobjekt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isAbstract"();

-- -----------------------------------------------------
-- Table "FP_Naturschutz"."FP_AusgleichsFlaeche"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Naturschutz"."FP_AusgleichsFlaeche" (
  "gid" BIGINT NOT NULL ,
  "ziel" INTEGER NULL ,
  "refMassnahmenText" INTEGER NULL ,
  "refLandschaftsplan" INTEGER NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_AusgleichsFlaeche_XP_SPEZiele1"
    FOREIGN KEY ("ziel" )
    REFERENCES "XP_Sonstiges"."XP_SPEZiele" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_AusgleichsFlaeche_FP_Objekt1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Basisobjekte"."FP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_AusgleichsFlaeche_XP_ExterneReferenz1"
    FOREIGN KEY ("refMassnahmenText" )
    REFERENCES "XP_Basisobjekte"."XP_ExterneReferenz" ("id" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_AusgleichsFlaeche_XP_ExterneReferenz2"
    FOREIGN KEY ("refLandschaftsplan" )
    REFERENCES "XP_Basisobjekte"."XP_ExterneReferenz" ("id" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE)
INHERITS("FP_Basisobjekte"."FP_Flaechenobjekt");

CREATE INDEX "idx_fk_FP_AusgleichsFlaeche_XP_SPEZiele" ON "FP_Naturschutz"."FP_AusgleichsFlaeche" ("ziel") ;
CREATE INDEX "idx_fk_FP_AusgleichsFlaeche_XP_ExterneReferenz1" ON "FP_Naturschutz"."FP_AusgleichsFlaeche" ("refMassnahmenText") ;
CREATE INDEX "idx_fk_FP_AusgleichsFlaeche_XP_ExterneReferenz2" ON "FP_Naturschutz"."FP_AusgleichsFlaeche" ("refLandschaftsplan") ;
GRANT SELECT ON TABLE "FP_Naturschutz"."FP_AusgleichsFlaeche" TO xp_gast;
GRANT ALL ON TABLE "FP_Naturschutz"."FP_AusgleichsFlaeche" TO fp_user;
COMMENT ON TABLE  "FP_Naturschutz"."FP_AusgleichsFlaeche" IS 'Flächen und Maßnahmen zum Ausgleich gemäß §5, Abs. 2a BauBG.';
COMMENT ON COLUMN  "FP_Naturschutz"."FP_AusgleichsFlaeche"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN  "FP_Naturschutz"."FP_AusgleichsFlaeche"."ziel" IS 'Unterscheidung nach den Zielen "Schutz, Pflege" und "Entwicklung".';
COMMENT ON COLUMN  "FP_Naturschutz"."FP_AusgleichsFlaeche"."refMassnahmenText" IS 'Referenz auf ein Dokument in dem die Massnahmen beschrieben werden.';
COMMENT ON COLUMN  "FP_Naturschutz"."FP_AusgleichsFlaeche"."refLandschaftsplan" IS 'Referenz auf den Landschaftsplan.';
CREATE TRIGGER "change_to_FP_AusgleichsFlaeche" BEFORE INSERT OR UPDATE OR DELETE ON "FP_Naturschutz"."FP_AusgleichsFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "FP_AusgleichsFlaeche_Flaechenobjekt" BEFORE INSERT OR UPDATE ON "FP_Naturschutz"."FP_AusgleichsFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isFlaechenobjekt"();
SELECT "XP_Basisobjekte".registergeometrycolumn('','FP_Naturschutz','FP_AusgleichsFlaeche', 'position','MULTIPOLYGON',2);

-- -----------------------------------------------------
-- Table "FP_Naturschutz"."FP_AusgleichsFlaeche_massnahme"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Naturschutz"."FP_AusgleichsFlaeche_massnahme" (
  "gid" BIGINT NOT NULL ,
  "massnahme" INTEGER NULL ,
  PRIMARY KEY ("gid", "massnahme"),
  CONSTRAINT "fk_FP_AusgleichsFlaeche_massnahme1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Naturschutz"."FP_AusgleichsFlaeche" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_AusgleichsFlaeche_massnahme2"
    FOREIGN KEY ("massnahme" )
    REFERENCES "XP_Sonstiges"."XP_SPEMassnahmenDaten" ("id" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
GRANT SELECT ON TABLE "FP_Naturschutz"."FP_AusgleichsFlaeche_massnahme" TO xp_gast;
GRANT ALL ON TABLE "FP_Naturschutz"."FP_AusgleichsFlaeche_massnahme" TO fp_user;
COMMENT ON TABLE  "FP_Naturschutz"."FP_AusgleichsFlaeche_massnahme" IS 'Auf der Fläche durchzuführende Maßnahmen.';


-- -----------------------------------------------------
-- Table "FP_Basisobjekte"."wirdAusgeglichenDurchFlaeche"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Basisobjekte"."wirdAusgeglichenDurchFlaeche" (
  "FP_Objekt_gid" BIGINT NOT NULL ,
  "FP_AusgleichsFlaeche_gid" BIGINT NOT NULL ,
  PRIMARY KEY ("FP_Objekt_gid", "FP_AusgleichsFlaeche_gid") ,
  CONSTRAINT "fk_wirdAusgeglichenDurchFlaeche1"
    FOREIGN KEY ("FP_Objekt_gid" )
    REFERENCES "FP_Basisobjekte"."FP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_wirdAusgeglichenDurchFlaeche2"
    FOREIGN KEY ("FP_AusgleichsFlaeche_gid" )
    REFERENCES "FP_Naturschutz"."FP_AusgleichsFlaeche" ("gid" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE);

CREATE INDEX "idx_fk_wirdAusgeglichenDurchFlaeche1" ON "FP_Basisobjekte"."wirdAusgeglichenDurchFlaeche" ("FP_Objekt_gid") ;
CREATE INDEX "idx_fk_wirdAusgeglichenDurchFlaeche2" ON "FP_Basisobjekte"."wirdAusgeglichenDurchFlaeche" ("FP_AusgleichsFlaeche_gid") ;
GRANT SELECT ON TABLE "FP_Basisobjekte"."wirdAusgeglichenDurchFlaeche" TO xp_gast;
GRANT ALL ON TABLE "FP_Basisobjekte"."wirdAusgeglichenDurchFlaeche" TO fp_user;
COMMENT ON TABLE "FP_Basisobjekte"."wirdAusgeglichenDurchFlaeche" IS 'Relation auf Flächen (FP_AusgleichsFlaeche), durch den ein Eingriff ausgeglichen wird.';

-- -----------------------------------------------------
-- Table "FP_Naturschutz"."FP_SchutzPflegeEntwicklung"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Naturschutz"."FP_SchutzPflegeEntwicklung" (
  "gid" BIGINT NOT NULL ,
  "ziel" INTEGER NULL ,
  "massnahme" INTEGER NULL ,
  "weitereMassnahme1" INTEGER NULL ,
  "weitereMassnahme2" INTEGER NULL ,
  "istAusgleich" BOOLEAN  NULL DEFAULT false,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_SchutzPflegeEntwicklung_XP_SPEZiele"
    FOREIGN KEY ("ziel" )
    REFERENCES "XP_Sonstiges"."XP_SPEZiele" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_SchutzPflegeEntwicklung_XP_SPEMassnahmenDaten1"
    FOREIGN KEY ("massnahme" )
    REFERENCES "XP_Sonstiges"."XP_SPEMassnahmenDaten" ("id" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_SchutzPflegeEntwicklung_XP_SPEMassnahmenDaten2"
    FOREIGN KEY ("weitereMassnahme1" )
    REFERENCES "XP_Sonstiges"."XP_SPEMassnahmenDaten" ("id" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_SchutzPflegeEntwicklung_XP_SPEMassnahmenDaten3"
    FOREIGN KEY ("weitereMassnahme2" )
    REFERENCES "XP_Sonstiges"."XP_SPEMassnahmenDaten" ("id" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_SchutzPflegeEntwicklung_FP_Objekt1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Basisobjekte"."FP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE);

CREATE INDEX "idx_fk_FP_SchutzPflegeEntwicklung_XP_SPEZiele" ON "FP_Naturschutz"."FP_SchutzPflegeEntwicklung" ("ziel") ;
CREATE INDEX "idx_fk_FP_SchutzPflegeEntwicklung_XP_SPEMassnahmenDaten1" ON "FP_Naturschutz"."FP_SchutzPflegeEntwicklung" ("massnahme") ;
CREATE INDEX "idx_fk_FP_SchutzPflegeEntwicklung_XP_SPEMassnahmenDaten2" ON "FP_Naturschutz"."FP_SchutzPflegeEntwicklung" ("weitereMassnahme1") ;
CREATE INDEX "idx_fk_FP_SchutzPflegeEntwicklung_XP_SPEMassnahmenDaten3" ON "FP_Naturschutz"."FP_SchutzPflegeEntwicklung" ("weitereMassnahme2") ;
GRANT SELECT ON TABLE "FP_Naturschutz"."FP_SchutzPflegeEntwicklung" TO xp_gast;
GRANT ALL ON TABLE "FP_Naturschutz"."FP_SchutzPflegeEntwicklung" TO fp_user;
COMMENT ON TABLE  "FP_Naturschutz"."FP_SchutzPflegeEntwicklung" IS 'Flächen und Maßnahmen zum Ausgleich gemäß §5, Abs. 2a BauBG.';
COMMENT ON COLUMN  "FP_Naturschutz"."FP_SchutzPflegeEntwicklung"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN  "FP_Naturschutz"."FP_SchutzPflegeEntwicklung"."ziel" IS 'Unterscheidung nach den Zielen "Schutz, Pflege" und "Entwicklung".';
COMMENT ON COLUMN  "FP_Naturschutz"."FP_SchutzPflegeEntwicklung"."massnahme" IS 'Durchzuführende Maßnahme';
COMMENT ON COLUMN  "FP_Naturschutz"."FP_SchutzPflegeEntwicklung"."weitereMassnahme1" IS 'Weitere durchzuführende Massnahme.';
COMMENT ON COLUMN  "FP_Naturschutz"."FP_SchutzPflegeEntwicklung"."weitereMassnahme2" IS 'Weitere durchzuführende Massnahme.';
COMMENT ON COLUMN  "FP_Naturschutz"."FP_SchutzPflegeEntwicklung"."istAusgleich" IS 'Gibt an, ob die Maßnahme zum Ausgkeich eines Eingriffs benutzt wird.';
CREATE TRIGGER "change_to_FP_SchutzPflegeEntwicklung" BEFORE INSERT OR UPDATE OR DELETE ON "FP_Naturschutz"."FP_SchutzPflegeEntwicklung" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "FP_Naturschutz"."FP_SchutzPflegeEntwicklung_massnahme"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Naturschutz"."FP_SchutzPflegeEntwicklung_massnahme" (
  "gid" BIGINT NOT NULL ,
  "massnahme" INTEGER NULL ,
  PRIMARY KEY ("gid", "massnahme"),
  CONSTRAINT "fk_FP_SchutzPflegeEntwicklung_massnahme1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Naturschutz"."FP_SchutzPflegeEntwicklung" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_SchutzPflegeEntwicklung_massnahme2"
    FOREIGN KEY ("massnahme" )
    REFERENCES "XP_Sonstiges"."XP_SPEMassnahmenDaten" ("id" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
GRANT SELECT ON TABLE "FP_Naturschutz"."FP_SchutzPflegeEntwicklung_massnahme" TO xp_gast;
GRANT ALL ON TABLE "FP_Naturschutz"."FP_SchutzPflegeEntwicklung_massnahme" TO fp_user;
COMMENT ON TABLE  "FP_Naturschutz"."FP_SchutzPflegeEntwicklung_massnahme" IS 'Durchzuführende Maßnahmen.';

-- -----------------------------------------------------
-- Table "FP_Basisobjekte"."wirdAusgeglichenDurchSPE"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Basisobjekte"."wirdAusgeglichenDurchSPE" (
  "FP_Objekt_gid" BIGINT NOT NULL ,
  "FP_SchutzPflegeEntwicklung_gid" BIGINT NOT NULL ,
  PRIMARY KEY ("FP_Objekt_gid", "FP_SchutzPflegeEntwicklung_gid") ,
  CONSTRAINT "fk_wirdAusgeglichenDurchSPE1"
    FOREIGN KEY ("FP_Objekt_gid" )
    REFERENCES "FP_Basisobjekte"."FP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_wirdAusgeglichenDurchSPE2"
    FOREIGN KEY ("FP_SchutzPflegeEntwicklung_gid" )
    REFERENCES "FP_Naturschutz"."FP_SchutzPflegeEntwicklung" ("gid" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE);

CREATE INDEX "idx_fk_wirdAusgeglichenDurchSPE1" ON "FP_Basisobjekte"."wirdAusgeglichenDurchSPE" ("FP_Objekt_gid") ;
CREATE INDEX "idx_fk_wirdAusgeglichenDurchSPE2" ON "FP_Basisobjekte"."wirdAusgeglichenDurchSPE" ("FP_SchutzPflegeEntwicklung_gid") ;
GRANT SELECT ON TABLE "FP_Basisobjekte"."wirdAusgeglichenDurchSPE" TO xp_gast;
GRANT ALL ON TABLE "FP_Basisobjekte"."wirdAusgeglichenDurchSPE" TO fp_user;
COMMENT ON TABLE  "FP_Basisobjekte"."wirdAusgeglichenDurchSPE" IS 'Relation auf Maßnahmen (FP_SchutzPflegeEntwicklung), durch den ein Eingriff ausgeglichen wird.';

-- -----------------------------------------------------
-- Table "FP_Raster"."auslegungsStartDatum"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Raster"."auslegungsStartDatum" (
  "FP_RasterplanAenderung_gid" BIGINT NOT NULL ,
  "auslegungsStartDatum" DATE NOT NULL ,
  PRIMARY KEY ("FP_RasterplanAenderung_gid", "auslegungsStartDatum") ,
  CONSTRAINT "fk_auslegungsStartDatum_FP_RasterplanAenderung"
    FOREIGN KEY ("FP_RasterplanAenderung_gid" )
    REFERENCES "FP_Raster"."FP_RasterplanAenderung" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE);

CREATE INDEX "idx_fk_auslegungsStartDatum_FP_RasterplanAenderung" ON "FP_Raster"."auslegungsStartDatum" ("FP_RasterplanAenderung_gid") ;
GRANT SELECT ON TABLE "FP_Raster"."auslegungsStartDatum" TO xp_gast;
GRANT ALL ON TABLE "FP_Raster"."auslegungsStartDatum" TO fp_user;
COMMENT ON TABLE  "FP_Raster"."auslegungsStartDatum" IS 'Start-Datum der öffentlichen Auslegung.';

-- -----------------------------------------------------
-- Table "FP_Raster"."auslegungsEndDatum"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Raster"."auslegungsEndDatum" (
  "auslegungsEndDatum" DATE NOT NULL ,
  "FP_RasterplanAenderung_gid" BIGINT NOT NULL ,
  PRIMARY KEY ("auslegungsEndDatum", "FP_RasterplanAenderung_gid") ,
  CONSTRAINT "fk_auslegungsEndDatum_FP_RasterplanAenderung1"
    FOREIGN KEY ("FP_RasterplanAenderung_gid" )
    REFERENCES "FP_Raster"."FP_RasterplanAenderung" ("gid" )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION);

CREATE INDEX "idx_fk_auslegungsEndDatum_FP_RasterplanAenderung1" ON "FP_Raster"."auslegungsEndDatum" ("FP_RasterplanAenderung_gid") ;
GRANT SELECT ON TABLE "FP_Raster"."auslegungsEndDatum" TO xp_gast;
GRANT ALL ON TABLE "FP_Raster"."auslegungsEndDatum" TO fp_user;
COMMENT ON TABLE  "FP_Raster"."auslegungsEndDatum" IS 'End-Datum der öffentlichen Auslegung.';


-- -----------------------------------------------------
-- Table "FP_Raster"."traegerbeteiligungsStartDatum"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Raster"."traegerbeteiligungsStartDatum" (
  "traegerbeteiligungsStartDatum" DATE NOT NULL ,
  "FP_RasterplanAenderung_gid" BIGINT NOT NULL ,
  PRIMARY KEY ("traegerbeteiligungsStartDatum", "FP_RasterplanAenderung_gid") ,
  CONSTRAINT "fk_traegerbeteiligungsStartDatum_FP_RasterplanAenderung1"
    FOREIGN KEY ("FP_RasterplanAenderung_gid" )
    REFERENCES "FP_Raster"."FP_RasterplanAenderung" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE);
CREATE INDEX "idx_fk_traegerbeteiligungsStartDatum_FP_RasterplanAenderung1" ON "FP_Raster"."traegerbeteiligungsStartDatum" ("FP_RasterplanAenderung_gid") ;
GRANT SELECT ON TABLE "FP_Raster"."traegerbeteiligungsStartDatum" TO xp_gast;
GRANT ALL ON TABLE "FP_Raster"."traegerbeteiligungsStartDatum" TO fp_user;
COMMENT ON TABLE  "FP_Raster"."traegerbeteiligungsStartDatum" IS 'Start-Datum der Trägerbeteiligung.';

-- -----------------------------------------------------
-- Table "FP_Raster"."traegerbeteiligungsEndDatum"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Raster"."traegerbeteiligungsEndDatum" (
  "traegerbeteiligungsEndDatum" DATE NOT NULL ,
  "FP_RasterplanAenderung_gid" BIGINT NOT NULL ,
  PRIMARY KEY ("traegerbeteiligungsEndDatum", "FP_RasterplanAenderung_gid") ,
  CONSTRAINT "fk_traegerbeteiligungsEndDatum_FP_RasterplanAenderung1"
    FOREIGN KEY ("FP_RasterplanAenderung_gid" )
    REFERENCES "FP_Raster"."FP_RasterplanAenderung" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE);
CREATE INDEX "idx_fk_traegerbeteiligungsEndDatum_FP_RasterplanAenderung1" ON "FP_Raster"."traegerbeteiligungsEndDatum" ("FP_RasterplanAenderung_gid") ;
GRANT SELECT ON TABLE "FP_Raster"."traegerbeteiligungsEndDatum" TO xp_gast;
GRANT ALL ON TABLE "FP_Raster"."traegerbeteiligungsEndDatum" TO fp_user;
COMMENT ON TABLE  "FP_Raster"."traegerbeteiligungsEndDatum" IS 'End-Datum der Trägerbeteiligung.';

-- -----------------------------------------------------
-- Table "FP_Naturschutz"."FP_SchutzPflegeEntwicklungPunkt"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Naturschutz"."FP_SchutzPflegeEntwicklungPunkt" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_SchutzPflegeEntwicklungPunkt1"
    FOREIGN KEY ("gid")
    REFERENCES "FP_Naturschutz"."FP_SchutzPflegeEntwicklung" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("FP_Basisobjekte"."FP_Punktobjekt");

GRANT SELECT ON TABLE "FP_Naturschutz"."FP_SchutzPflegeEntwicklungPunkt" TO xp_gast;
GRANT ALL ON TABLE "FP_Naturschutz"."FP_SchutzPflegeEntwicklungPunkt" TO fp_user;
COMMENT ON COLUMN "FP_Naturschutz"."FP_SchutzPflegeEntwicklungPunkt"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_FP_SchutzPflegeEntwicklungPunkt" BEFORE INSERT OR UPDATE OR DELETE ON "FP_Naturschutz"."FP_SchutzPflegeEntwicklungPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
SELECT "XP_Basisobjekte".registergeometrycolumn('','FP_Naturschutz','FP_SchutzPflegeEntwicklungPunkt', 'position','MULTIPOINT',2);

-- -----------------------------------------------------
-- Table "FP_Naturschutz"."FP_SchutzPflegeEntwicklungLinie"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Naturschutz"."FP_SchutzPflegeEntwicklungLinie" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_SchutzPflegeEntwicklungLinie"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Naturschutz"."FP_SchutzPflegeEntwicklung" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("FP_Basisobjekte"."FP_Linienobjekt");

GRANT SELECT ON TABLE "FP_Naturschutz"."FP_SchutzPflegeEntwicklungLinie" TO xp_gast;
GRANT ALL ON TABLE "FP_Naturschutz"."FP_SchutzPflegeEntwicklungLinie" TO fp_user;
COMMENT ON COLUMN "FP_Naturschutz"."FP_SchutzPflegeEntwicklungLinie"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_FP_SchutzPflegeEntwicklungLinie" BEFORE INSERT OR UPDATE OR DELETE ON "FP_Naturschutz"."FP_SchutzPflegeEntwicklungLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
SELECT "XP_Basisobjekte".registergeometrycolumn('','FP_Naturschutz','FP_SchutzPflegeEntwicklungLinie', 'position','MULTILINESTRING',2);

-- -----------------------------------------------------
-- Table "FP_Naturschutz"."FP_SchutzPflegeEntwicklungFlaeche"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Naturschutz"."FP_SchutzPflegeEntwicklungFlaeche" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_SchutzPflegeEntwicklungFlaeche"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Naturschutz"."FP_SchutzPflegeEntwicklung" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("FP_Basisobjekte"."FP_Flaechenobjekt");

GRANT SELECT ON TABLE "FP_Naturschutz"."FP_SchutzPflegeEntwicklungFlaeche" TO xp_gast;
GRANT ALL ON TABLE "FP_Naturschutz"."FP_SchutzPflegeEntwicklungFlaeche" TO fp_user;
COMMENT ON COLUMN "FP_Naturschutz"."FP_SchutzPflegeEntwicklungFlaeche"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_FP_SchutzPflegeEntwicklungFlaeche" BEFORE INSERT OR UPDATE OR DELETE ON "FP_Naturschutz"."FP_SchutzPflegeEntwicklungFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "FP_SchutzPflegeEntwicklungFlaeche_Flaechenobjekt" BEFORE INSERT OR UPDATE ON "FP_Naturschutz"."FP_SchutzPflegeEntwicklungFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isFlaechenobjekt"();
SELECT "XP_Basisobjekte".registergeometrycolumn('','FP_Naturschutz','FP_SchutzPflegeEntwicklungFlaeche', 'position','MULTIPOLYGON',2);

-- -----------------------------------------------------
-- Table "FP_Bebauung"."FP_DetailArtDerBaulNutzung"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Bebauung"."FP_DetailArtDerBaulNutzung" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Code") );
GRANT SELECT ON TABLE "FP_Bebauung"."FP_DetailArtDerBaulNutzung" TO xp_gast;
GRANT ALL ON TABLE "FP_Bebauung"."FP_DetailArtDerBaulNutzung" TO fp_user;

-- -----------------------------------------------------
-- Table "FP_Bebauung"."FP_BebauungsFlaeche"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Bebauung"."FP_BebauungsFlaeche" (
  "gid" BIGINT NOT NULL ,
  "allgArtDerBaulNutzung" INTEGER NULL ,
  "besondereArtDerBaulNutzung" INTEGER NULL ,
  "sonderNutzung" INTEGER NULL ,
  "detaillierteArtDerBaulNutzung" INTEGER NULL ,
  "nutzungText" VARCHAR(255) NULL ,
  "GFZ" FLOAT NULL ,
  "GFZmin" FLOAT NULL ,
  "GFZmax" FLOAT NULL ,
  "BMZ" FLOAT NULL ,
  "GRZ" FLOAT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_BebauungsFlaeche_XP_AllgArtDerBaulNutzung"
    FOREIGN KEY ("allgArtDerBaulNutzung" )
    REFERENCES "XP_Enumerationen"."XP_AllgArtDerBaulNutzung" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_BebauungsFlaeche_XP_BesondereArtDerBaulNutzung1"
    FOREIGN KEY ("besondereArtDerBaulNutzung" )
    REFERENCES "XP_Enumerationen"."XP_BesondereArtDerBaulNutzung" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_BebauungsFlaeche_XP_Sondernutzungen1"
    FOREIGN KEY ("sonderNutzung" )
    REFERENCES "XP_Enumerationen"."XP_Sondernutzungen" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_BebauungsFlaeche_FP_Objekt1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Basisobjekte"."FP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_BebauungsFlaeche_FP_DetailArtDerBaulNutzung1"
    FOREIGN KEY ("detaillierteArtDerBaulNutzung" )
    REFERENCES "FP_Bebauung"."FP_DetailArtDerBaulNutzung" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE)
INHERITS("FP_Basisobjekte"."FP_Flaechenobjekt");

CREATE INDEX "idx_fk_FP_BebauungsFlaeche_XP_AllgArtDerBaulNutzung" ON "FP_Bebauung"."FP_BebauungsFlaeche" ("allgArtDerBaulNutzung") ;
CREATE INDEX "idx_fk_FP_BebauungsFlaeche_XP_BesondereArtDerBaulNutzung1" ON "FP_Bebauung"."FP_BebauungsFlaeche" ("besondereArtDerBaulNutzung") ;
CREATE INDEX "idx_fk_FP_BebauungsFlaeche_XP_Sondernutzungen1" ON "FP_Bebauung"."FP_BebauungsFlaeche" ("sonderNutzung") ;
CREATE INDEX "idx_fk_FP_BebauungsFlaeche_FP_DetailArtDerBaulNutzung1" ON "FP_Bebauung"."FP_BebauungsFlaeche" ("detaillierteArtDerBaulNutzung") ;
GRANT SELECT ON TABLE "FP_Bebauung"."FP_BebauungsFlaeche" TO xp_gast;
GRANT ALL ON TABLE "FP_Bebauung"."FP_BebauungsFlaeche" TO fp_user;
COMMENT ON TABLE "FP_Bebauung"."FP_BebauungsFlaeche" IS 'Darstellung der für die Bebauung vorgesehenen Flächen (§5, Abs. 2, Nr. 1 BauGB).';
COMMENT ON COLUMN "FP_Bebauung"."FP_BebauungsFlaeche"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN "FP_Bebauung"."FP_BebauungsFlaeche"."allgArtDerBaulNutzung" IS 'Angabe der allgemeinen Art der baulichen Nutzung.';
COMMENT ON COLUMN "FP_Bebauung"."FP_BebauungsFlaeche"."besondereArtDerBaulNutzung" IS 'Angabe der besonderen Art der baulichen Nutzung.';
COMMENT ON COLUMN "FP_Bebauung"."FP_BebauungsFlaeche"."sonderNutzung" IS 'Bei Nutzungsform "Sondergebiet": Differenzierung verschiedener Arten von Sondergebieten nach §§ 10 und 11 BauNVO.';
COMMENT ON COLUMN "FP_Bebauung"."FP_BebauungsFlaeche"."detaillierteArtDerBaulNutzung" IS 'Über eine CodeList definierte Art der baulichen Nutzung.';
COMMENT ON COLUMN "FP_Bebauung"."FP_BebauungsFlaeche"."nutzungText" IS 'Bei Nutzungsform "Sondergebiet": Kurzform der besonderen Art der baulichen Nutzung.';
COMMENT ON COLUMN "FP_Bebauung"."FP_BebauungsFlaeche"."GFZ" IS 'Angabe einer maximalen Geschossflächenzahl als Maß der baulichen Nutzung.';
COMMENT ON COLUMN "FP_Bebauung"."FP_BebauungsFlaeche"."GFZmin" IS 'Minimale Geschossflächenzahl bei einer Bereichsangabe (GFZmax muss ebenfalls spezifiziert werden).';
COMMENT ON COLUMN "FP_Bebauung"."FP_BebauungsFlaeche"."GFZmax" IS 'Maximale Geschossflächenzahl bei einer Bereichsangabe (GFZmin muss ebenfalls spezifiziert werden).';
COMMENT ON COLUMN "FP_Bebauung"."FP_BebauungsFlaeche"."BMZ" IS 'Angabe einer maximalen Baumassenzahl als Maß der baulichen Nutzung.';
COMMENT ON COLUMN "FP_Bebauung"."FP_BebauungsFlaeche"."GRZ" IS 'Angabe einer maximalen Grundflächenzahl als Maß der baulichen Nutzung.';
CREATE TRIGGER "change_to_FP_BebauungsFlaeche" BEFORE INSERT OR UPDATE OR DELETE ON "FP_Bebauung"."FP_BebauungsFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "flaechenschluss_FP_BebauungsFlaeche" BEFORE INSERT OR UPDATE OR DELETE ON "FP_Bebauung"."FP_BebauungsFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isFlaechenschlussobjekt"();
CREATE TRIGGER "FP_BebauungsFlaeche_Flaechenobjekt" BEFORE INSERT OR UPDATE ON "FP_Bebauung"."FP_BebauungsFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isFlaechenobjekt"();
SELECT "XP_Basisobjekte".registergeometrycolumn('','FP_Bebauung','FP_BebauungsFlaeche', 'position','MULTIPOLYGON',2);

-- -----------------------------------------------------
-- Table "FP_Bebauung"."FP_KeineZentrAbwasserBeseitigungFlaeche"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Bebauung"."FP_KeineZentrAbwasserBeseitigungFlaeche" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_KeineZentrAbwasserBeseitigungFlaeche_FP_Objekt1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Basisobjekte"."FP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("FP_Basisobjekte"."FP_Flaechenobjekt");

GRANT SELECT ON TABLE "FP_Bebauung"."FP_KeineZentrAbwasserBeseitigungFlaeche" TO xp_gast;
GRANT ALL ON TABLE "FP_Bebauung"."FP_KeineZentrAbwasserBeseitigungFlaeche" TO fp_user;
COMMENT ON TABLE "FP_Bebauung"."FP_KeineZentrAbwasserBeseitigungFlaeche" IS 'Baufläche, für die eine zentrale Abwasserbeseitigung nicht vorgesehen ist (§5, Abs. 2, Nr. 1 BauGB).';
CREATE TRIGGER "change_to_FP_KeineZentrAbwasserBeseitigungFlaeche" BEFORE INSERT OR UPDATE OR DELETE ON "FP_Bebauung"."FP_KeineZentrAbwasserBeseitigungFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "FP_KeineZentrAbwasserBeseitigungFlaeche_Flaechenobjekt" BEFORE INSERT OR UPDATE ON "FP_Bebauung"."FP_KeineZentrAbwasserBeseitigungFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isFlaechenobjekt"();
SELECT "XP_Basisobjekte".registergeometrycolumn('','FP_Bebauung','FP_KeineZentrAbwasserBeseitigungFlaeche', 'position','MULTIPOLYGON',2);

-- -----------------------------------------------------
-- Table "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_DetailZweckbestGemeinbedarf"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_DetailZweckbestGemeinbedarf" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Code") );
GRANT SELECT ON TABLE "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_DetailZweckbestGemeinbedarf" TO xp_gast;
GRANT ALL ON TABLE "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_DetailZweckbestGemeinbedarf" TO fp_user;

-- -----------------------------------------------------
-- Table "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_Gemeinbedarf"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_Gemeinbedarf" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_Gemeinbedarf_FP_Objekt1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Basisobjekte"."FP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE);

GRANT SELECT ON TABLE "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_Gemeinbedarf" TO xp_gast;
GRANT ALL ON TABLE "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_Gemeinbedarf" TO fp_user;
COMMENT ON TABLE  "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_Gemeinbedarf" IS 'Darstellung von Flächen für den Gemeinbedarf nach §5, Abs. 2, Nr. 2 BauGB.';
COMMENT ON COLUMN "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_Gemeinbedarf"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_FP_Gemeinbedarf" BEFORE INSERT OR UPDATE OR DELETE ON "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_Gemeinbedarf" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_Gemeinbedarf_zweckbestimmung"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_Gemeinbedarf_zweckbestimmung" (
  "gid" BIGINT NOT NULL ,
  "zweckbestimmung" INTEGER NULL ,
  PRIMARY KEY ("gid", "zweckbestimmung"),
  CONSTRAINT "fk_FP_Gemeinbedarf_zweckbestimmung_FP_Gemeinbedarf1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_Gemeinbedarf" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_XP_ZweckbestimmungGemeinbedarf0"
    FOREIGN KEY ("zweckbestimmung" )
    REFERENCES "XP_Enumerationen"."XP_ZweckbestimmungGemeinbedarf" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
GRANT SELECT ON TABLE "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_Gemeinbedarf_zweckbestimmung" TO xp_gast;
GRANT ALL ON TABLE "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_Gemeinbedarf_zweckbestimmung" TO fp_user;
COMMENT ON TABLE  "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_Gemeinbedarf_zweckbestimmung" IS 'Allgemeine Zweckbestimmungen der Fläche';

-- -----------------------------------------------------
-- Table "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_Gemeinbedarf_besondereZweckbestimmung"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_Gemeinbedarf_besondereZweckbestimmung" (
  "gid" BIGINT NOT NULL ,
  "besondereZweckbestimmung" INTEGER NULL ,
  PRIMARY KEY ("gid", "besondereZweckbestimmung"),
  CONSTRAINT "fk_FP_Gemeinbedarf_besondereZweckbestimmung_FP_Gemeinbedarf1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_Gemeinbedarf" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_XP_besondereZweckbestimmungGemeinbedarf0"
    FOREIGN KEY ("besondereZweckbestimmung" )
    REFERENCES "XP_Enumerationen"."XP_BesondereZweckbestGemeinbedarf" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
GRANT SELECT ON TABLE "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_Gemeinbedarf_besondereZweckbestimmung" TO xp_gast;
GRANT ALL ON TABLE "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_Gemeinbedarf_besondereZweckbestimmung" TO fp_user;
COMMENT ON TABLE  "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_Gemeinbedarf_besondereZweckbestimmung" IS 'Besondere Zweckbestimmungen der Fläche, die die zugehörigen allgemeinen Zweckbestimmungen detaillieren oder ersetzen.';

-- -----------------------------------------------------
-- Table "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_Gemeinbedarf_detaillierteZweckbestimmung"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_Gemeinbedarf_detaillierteZweckbestimmung" (
  "gid" BIGINT NOT NULL ,
  "detaillierteZweckbestimmung" INTEGER NULL ,
  PRIMARY KEY ("gid", "detaillierteZweckbestimmung"),
  CONSTRAINT "fk_FP_Gemeinbedarf_detaillierteZweckbestimmung_FP_Gemeinbedarf1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_Gemeinbedarf" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_DetailZweckbestGemeinbedarf0"
    FOREIGN KEY ("detaillierteZweckbestimmung" )
    REFERENCES "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_DetailZweckbestGemeinbedarf" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
GRANT SELECT ON TABLE "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_Gemeinbedarf_detaillierteZweckbestimmung" TO xp_gast;
GRANT ALL ON TABLE "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_Gemeinbedarf_detaillierteZweckbestimmung" TO fp_user;
COMMENT ON TABLE  "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_Gemeinbedarf_detaillierteZweckbestimmung" IS 'BÜber eine ExternalCodeList definierte zusätzliche Zweckbestimmungen.';

-- -----------------------------------------------------
-- Table "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_DetailZweckbestSpielSportanlage"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_DetailZweckbestSpielSportanlage" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Code") );
GRANT SELECT ON TABLE "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_DetailZweckbestSpielSportanlage" TO xp_gast;
GRANT ALL ON TABLE "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_DetailZweckbestSpielSportanlage" TO fp_user;

-- -----------------------------------------------------
-- Table "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_SpielSportanlage"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_SpielSportanlage" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_SpielSportanlage_FP_Objekt1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Basisobjekte"."FP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE);

GRANT SELECT ON TABLE "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_SpielSportanlage" TO xp_gast;
GRANT ALL ON TABLE "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_SpielSportanlage" TO fp_user;
COMMENT ON TABLE  "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_SpielSportanlage" IS 'Darstellung von Flächen für Spiel- und Sportanlagen nach §5, Abs. 2, Nr. 2 BauGB.';
COMMENT ON COLUMN "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_SpielSportanlage"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_FP_SpielSportanlage" BEFORE INSERT OR UPDATE OR DELETE ON "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_SpielSportanlage" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_SpielSportanlage_zweckbestimmung"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_SpielSportanlage_zweckbestimmung" (
  "gid" BIGINT NOT NULL ,
  "zweckbestimmung" INTEGER NULL ,
  PRIMARY KEY ("gid", "zweckbestimmung"),
  CONSTRAINT "fk_FP_SpielSportanlage_zweckbestimmung_FP_SpielSportanlage1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_SpielSportanlage" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_XP_ZweckbestimmungSpielSportanlage0"
    FOREIGN KEY ("zweckbestimmung" )
    REFERENCES "XP_Enumerationen"."XP_ZweckbestimmungSpielSportanlage" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
GRANT SELECT ON TABLE "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_SpielSportanlage_zweckbestimmung" TO xp_gast;
GRANT ALL ON TABLE "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_SpielSportanlage_zweckbestimmung" TO fp_user;
COMMENT ON TABLE  "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_SpielSportanlage_zweckbestimmung" IS 'Zweckbestimmungen der Fläche';

-- -----------------------------------------------------
-- Table "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_SpielSportanlage_detaillierteZweckbestimmung"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_SpielSportanlage_detaillierteZweckbestimmung" (
  "gid" BIGINT NOT NULL ,
  "detaillierteZweckbestimmung" INTEGER NULL ,
  PRIMARY KEY ("gid", "detaillierteZweckbestimmung"),
  CONSTRAINT "fk_FP_SpielSportanlage_besondereZweckbestimmung_FP_SpielSportanlage1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_SpielSportanlage" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_DetailZweckbestSpielSportanlage0"
    FOREIGN KEY ("detaillierteZweckbestimmung" )
    REFERENCES "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_DetailZweckbestSpielSportanlage" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
GRANT SELECT ON TABLE "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_SpielSportanlage_detaillierteZweckbestimmung" TO xp_gast;
GRANT ALL ON TABLE "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_SpielSportanlage_detaillierteZweckbestimmung" TO fp_user;
COMMENT ON TABLE  "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_SpielSportanlage_detaillierteZweckbestimmung" IS 'Über eine CodeList definierte zusätzliche Zweckbestimmungen.';


-- -----------------------------------------------------
-- Table "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_AnpassungKlimawandel"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_AnpassungKlimawandel" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_AnpassungKlimawandel_FP_Objekt1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Basisobjekte"."FP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE);

GRANT SELECT ON TABLE "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_AnpassungKlimawandel" TO xp_gast;
GRANT ALL ON TABLE "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_AnpassungKlimawandel" TO fp_user;
COMMENT ON TABLE  "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_AnpassungKlimawandel" IS 'Anlagen, Einrichtungen und sonstige Maßnahmen, die der Anpassung an den Klimawandel dienen.';
COMMENT ON COLUMN "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_AnpassungKlimawandel"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_FP_AnpassungKlimawandel" BEFORE INSERT OR UPDATE OR DELETE ON "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_AnpassungKlimawandel" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_GemeinbedarfFlaeche"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_GemeinbedarfFlaeche" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_GemeinbedarfFlaeche_FP_Gemeinbedarf1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_Gemeinbedarf" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("FP_Basisobjekte"."FP_Flaechenobjekt");

GRANT SELECT ON TABLE "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_GemeinbedarfFlaeche" TO xp_gast;
GRANT ALL ON TABLE "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_GemeinbedarfFlaeche" TO fp_user;
CREATE TRIGGER "change_to_FP_GemeinbedarfFlaeche" BEFORE INSERT OR UPDATE OR DELETE ON "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_GemeinbedarfFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "FP_GemeinbedarfFlaeche_Flaechenobjekt" BEFORE INSERT OR UPDATE ON "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_GemeinbedarfFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isFlaechenobjekt"();
SELECT "XP_Basisobjekte".registergeometrycolumn('','FP_Gemeinbedarf_Spiel_und_Sportanlagen','FP_GemeinbedarfFlaeche', 'position','MULTIPOLYGON',2);

-- -----------------------------------------------------
-- Table "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_GemeinbedarfLinie"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_GemeinbedarfLinie" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_GemeinbedarfLinie_FP_Gemeinbedarf1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_Gemeinbedarf" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("FP_Basisobjekte"."FP_Linienobjekt");

GRANT SELECT ON TABLE "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_GemeinbedarfLinie" TO xp_gast;
GRANT ALL ON TABLE "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_GemeinbedarfLinie" TO fp_user;
CREATE TRIGGER "change_to_FP_GemeinbedarfLinie" BEFORE INSERT OR UPDATE OR DELETE ON "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_GemeinbedarfLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
SELECT "XP_Basisobjekte".registergeometrycolumn('','FP_Gemeinbedarf_Spiel_und_Sportanlagen','FP_GemeinbedarfLinie', 'position','MULTILINESTRING',2);

-- -----------------------------------------------------
-- Table "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_GemeinbedarfPunkt"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_GemeinbedarfPunkt" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_GemeinbedarfPunkt_FP_Gemeinbedarf1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_Gemeinbedarf" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("FP_Basisobjekte"."FP_Punktobjekt");

GRANT SELECT ON TABLE "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_GemeinbedarfPunkt" TO xp_gast;
GRANT ALL ON TABLE "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_GemeinbedarfPunkt" TO fp_user;
CREATE TRIGGER "change_to_FP_GemeinbedarfPunkt" BEFORE INSERT OR UPDATE OR DELETE ON "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_GemeinbedarfPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
SELECT "XP_Basisobjekte".registergeometrycolumn('','FP_Gemeinbedarf_Spiel_und_Sportanlagen','FP_GemeinbedarfPunkt', 'position','MULTIPOINT',2);

-- -----------------------------------------------------
-- Table "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_SpielSportanlageFlaeche"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_SpielSportanlageFlaeche" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_SpielSportanlageFlaeche_FP_SpielSportanlage1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_SpielSportanlage" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("FP_Basisobjekte"."FP_Flaechenobjekt");

GRANT SELECT ON TABLE "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_SpielSportanlageFlaeche" TO xp_gast;
GRANT ALL ON TABLE "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_SpielSportanlageFlaeche" TO fp_user;
CREATE TRIGGER "change_to_FP_SpielSportanlageFlaeche" BEFORE INSERT OR UPDATE OR DELETE ON "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_SpielSportanlageFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "FP_SpielSportanlageFlaeche_Flaechenobjekt" BEFORE INSERT OR UPDATE ON "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_SpielSportanlageFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isFlaechenobjekt"();
SELECT "XP_Basisobjekte".registergeometrycolumn('','FP_Gemeinbedarf_Spiel_und_Sportanlagen','FP_SpielSportanlageFlaeche', 'position','MULTIPOLYGON',2);

-- -----------------------------------------------------
-- Table "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_SpielSportanlageLinie"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_SpielSportanlageLinie" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_SpielSportanlageLinie_FP_SpielSportanlage1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_SpielSportanlage" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("FP_Basisobjekte"."FP_Linienobjekt");

GRANT SELECT ON TABLE "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_SpielSportanlageLinie" TO xp_gast;
GRANT ALL ON TABLE "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_SpielSportanlageLinie" TO fp_user;
CREATE TRIGGER "change_to_FP_SpielSportanlageLinie" BEFORE INSERT OR UPDATE OR DELETE ON "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_SpielSportanlageLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
SELECT "XP_Basisobjekte".registergeometrycolumn('','FP_Gemeinbedarf_Spiel_und_Sportanlagen','FP_SpielSportanlageLinie', 'position','MULTILINESTRING',2);

-- -----------------------------------------------------
-- Table "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_SpielSportanlagePunkt"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_SpielSportanlagePunkt" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_SpielSportanlagePunkt_FP_SpielSportanlage1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_SpielSportanlage" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("FP_Basisobjekte"."FP_Punktobjekt");

GRANT SELECT ON TABLE "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_SpielSportanlagePunkt" TO xp_gast;
GRANT ALL ON TABLE "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_SpielSportanlagePunkt" TO fp_user;
CREATE TRIGGER "change_to_FP_SpielSportanlagePunkt" BEFORE INSERT OR UPDATE OR DELETE ON "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_SpielSportanlagePunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
SELECT "XP_Basisobjekte".registergeometrycolumn('','FP_Gemeinbedarf_Spiel_und_Sportanlagen','FP_SpielSportanlagePunkt', 'position','MULTIPOINT',2);

-- -----------------------------------------------------
-- Table "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_AnpassungKlimawandelFlaeche"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_AnpassungKlimawandelFlaeche" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_AnpassungKlimawandelFlaeche_FP_AnpassungKlimawandel1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_AnpassungKlimawandel" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("FP_Basisobjekte"."FP_Flaechenobjekt");

GRANT SELECT ON TABLE "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_AnpassungKlimawandelFlaeche" TO xp_gast;
GRANT ALL ON TABLE "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_AnpassungKlimawandelFlaeche" TO fp_user;
CREATE TRIGGER "change_to_FP_AnpassungKlimawandelFlaeche" BEFORE INSERT OR UPDATE OR DELETE ON "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_AnpassungKlimawandelFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "FP_AnpassungKlimawandelFlaeche_Flaechenobjekt" BEFORE INSERT OR UPDATE ON "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_AnpassungKlimawandelFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isFlaechenobjekt"();
SELECT "XP_Basisobjekte".registergeometrycolumn('','FP_Gemeinbedarf_Spiel_und_Sportanlagen','FP_AnpassungKlimawandelFlaeche', 'position','MULTIPOLYGON',2);

-- -----------------------------------------------------
-- Table "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_AnpassungKlimawandelLinie"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_AnpassungKlimawandelLinie" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_AnpassungKlimawandelLinie_FP_AnpassungKlimawandel1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_AnpassungKlimawandel" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("FP_Basisobjekte"."FP_Linienobjekt");

GRANT SELECT ON TABLE "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_AnpassungKlimawandelLinie" TO xp_gast;
GRANT ALL ON TABLE "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_AnpassungKlimawandelLinie" TO fp_user;
CREATE TRIGGER "change_to_FP_AnpassungKlimawandelLinie" BEFORE INSERT OR UPDATE OR DELETE ON "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_AnpassungKlimawandelLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
SELECT "XP_Basisobjekte".registergeometrycolumn('','FP_Gemeinbedarf_Spiel_und_Sportanlagen','FP_AnpassungKlimawandelLinie', 'position','MULTILINESTRING',2);

-- -----------------------------------------------------
-- Table "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_AnpassungKlimawandelPunkt"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_AnpassungKlimawandelPunkt" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_AnpassungKlimawandelPunkt_FP_AnpassungKlimawandel1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_AnpassungKlimawandel" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("FP_Basisobjekte"."FP_Punktobjekt");

GRANT SELECT ON TABLE "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_AnpassungKlimawandelPunkt" TO xp_gast;
GRANT ALL ON TABLE "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_AnpassungKlimawandelPunkt" TO fp_user;
CREATE TRIGGER "change_to_FP_AnpassungKlimawandelPunkt" BEFORE INSERT OR UPDATE OR DELETE ON "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_AnpassungKlimawandelPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
SELECT "XP_Basisobjekte".registergeometrycolumn('','FP_Gemeinbedarf_Spiel_und_Sportanlagen','FP_AnpassungKlimawandelPunkt', 'position','MULTIPOINT',2);

-- -----------------------------------------------------
-- Table "FP_Landwirtschaft_Wald_und_Gruen"."FP_DetailZweckbestWaldFlaeche"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Landwirtschaft_Wald_und_Gruen"."FP_DetailZweckbestWaldFlaeche" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Code") );
GRANT SELECT ON TABLE "FP_Landwirtschaft_Wald_und_Gruen"."FP_DetailZweckbestWaldFlaeche" TO xp_gast;
GRANT ALL ON TABLE "FP_Landwirtschaft_Wald_und_Gruen"."FP_DetailZweckbestWaldFlaeche" TO fp_user;

-- -----------------------------------------------------
-- Table "FP_Landwirtschaft_Wald_und_Gruen"."FP_WaldFlaeche"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Landwirtschaft_Wald_und_Gruen"."FP_WaldFlaeche" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_WaldFlaeche_FP_Objekt1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Basisobjekte"."FP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("FP_Basisobjekte"."FP_Flaechenobjekt");

GRANT SELECT ON TABLE "FP_Landwirtschaft_Wald_und_Gruen"."FP_WaldFlaeche" TO xp_gast;
GRANT ALL ON TABLE "FP_Landwirtschaft_Wald_und_Gruen"."FP_WaldFlaeche" TO fp_user;
COMMENT ON TABLE  "FP_Landwirtschaft_Wald_und_Gruen"."FP_WaldFlaeche" IS 'Darstellung von Waldflächen nach §5, Abs. 2, Nr. 9b,';
COMMENT ON COLUMN  "FP_Landwirtschaft_Wald_und_Gruen"."FP_WaldFlaeche"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN  "FP_Landwirtschaft_Wald_und_Gruen"."FP_WaldFlaeche"."weitereDetailZweckbestimmung2" IS 'Über eine CodeList definierte zusätzliche Zweckbestimmung';
CREATE TRIGGER "change_to_FP_WaldFlaeche" BEFORE INSERT OR UPDATE OR DELETE ON "FP_Landwirtschaft_Wald_und_Gruen"."FP_WaldFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "flaechenschluss_FP_WaldFlaeche" BEFORE INSERT OR UPDATE OR DELETE ON "FP_Landwirtschaft_Wald_und_Gruen"."FP_WaldFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isFlaechenschlussobjekt"();
CREATE TRIGGER "FP_WaldFlaeche_Flaechenobjekt" BEFORE INSERT OR UPDATE ON "FP_Landwirtschaft_Wald_und_Gruen"."FP_WaldFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isFlaechenobjekt"();
SELECT "XP_Basisobjekte".registergeometrycolumn('','FP_Landwirtschaft_Wald_und_Gruen','FP_WaldFlaeche', 'position','MULTIPOLYGON',2);

-- -----------------------------------------------------
-- Table "FP_Landwirtschaft_Wald_und_Gruen"."FP_WaldFlaeche_zweckbestimmung"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Landwirtschaft_Wald_und_Gruen"."FP_WaldFlaeche_zweckbestimmung" (
  "gid" BIGINT NOT NULL ,
  "zweckbestimmung" INTEGER NULL ,
  PRIMARY KEY ("gid", "zweckbestimmung"),
  CONSTRAINT "fk_FP_WaldFlaeche_zweckbestimmung1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Landwirtschaft_Wald_und_Gruen"."FP_WaldFlaeche" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_WaldFlaeche_zweckbestimmung2"
    FOREIGN KEY ("zweckbestimmung" )
    REFERENCES "XP_Enumerationen"."XP_ZweckbestimmungWald" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
GRANT SELECT ON TABLE "FP_Landwirtschaft_Wald_und_Gruen"."FP_WaldFlaeche_zweckbestimmung" TO xp_gast;
GRANT ALL ON TABLE "FP_Landwirtschaft_Wald_und_Gruen"."FP_WaldFlaeche_zweckbestimmung" TO fp_user;
COMMENT ON TABLE  "FP_Landwirtschaft_Wald_und_Gruen"."FP_WaldFlaeche_zweckbestimmung" IS 'Zweckbestimmungen der Waldfläche';


-- -----------------------------------------------------
-- Table "FP_Landwirtschaft_Wald_und_Gruen"."FP_WaldFlaeche_detaillierteZweckbestimmung"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Landwirtschaft_Wald_und_Gruen"."FP_WaldFlaeche_detaillierteZweckbestimmung" (
  "gid" BIGINT NOT NULL ,
  "detaillierteZweckbestimmung" INTEGER NULL ,
  PRIMARY KEY ("gid", "detaillierteZweckbestimmung"),
  CONSTRAINT "fk_FP_WaldFlaeche_detaillierteZweckbestimmung1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Landwirtschaft_Wald_und_Gruen"."FP_WaldFlaeche" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_WaldFlaeche_detaillierteZweckbestimmung2"
    FOREIGN KEY ("detaillierteZweckbestimmung" )
    REFERENCES "FP_Landwirtschaft_Wald_und_Gruen"."FP_DetailZweckbestWaldFlaeche" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
GRANT SELECT ON TABLE "FP_Landwirtschaft_Wald_und_Gruen"."FP_WaldFlaeche_detaillierteZweckbestimmung" TO xp_gast;
GRANT ALL ON TABLE "FP_Landwirtschaft_Wald_und_Gruen"."FP_WaldFlaeche_detaillierteZweckbestimmung" TO fp_user;
COMMENT ON TABLE  "FP_Landwirtschaft_Wald_und_Gruen"."FP_WaldFlaeche_detaillierteZweckbestimmung" IS 'Über eine CodeList definierte zusätzliche Zweckbestimmungen.';

-- -----------------------------------------------------
-- Table "FP_Landwirtschaft_Wald_und_Gruen"."FP_DetailZweckbestLandwirtschaftsFlaeche"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Landwirtschaft_Wald_und_Gruen"."FP_DetailZweckbestLandwirtschaftsFlaeche" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Code") );
GRANT SELECT ON TABLE "FP_Landwirtschaft_Wald_und_Gruen"."FP_DetailZweckbestLandwirtschaftsFlaeche" TO xp_gast;
GRANT ALL ON TABLE "FP_Landwirtschaft_Wald_und_Gruen"."FP_DetailZweckbestLandwirtschaftsFlaeche" TO fp_user;

-- -----------------------------------------------------
-- Table "FP_Landwirtschaft_Wald_und_Gruen"."FP_LandwirtschaftsFlaeche"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Landwirtschaft_Wald_und_Gruen"."FP_LandwirtschaftsFlaeche" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_LandwirtschaftsFlaeche_FP_Objekt1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Basisobjekte"."FP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("FP_Basisobjekte"."FP_Flaechenobjekt");

GRANT ALL ON TABLE "FP_Landwirtschaft_Wald_und_Gruen"."FP_LandwirtschaftsFlaeche" TO fp_user;
COMMENT ON TABLE  "FP_Landwirtschaft_Wald_und_Gruen"."FP_LandwirtschaftsFlaeche" IS 'Darstellung einer Landwirtschaftsfläche nach §5, Abs. 2, Nr. 9a.';
COMMENT ON COLUMN  "FP_Landwirtschaft_Wald_und_Gruen"."FP_LandwirtschaftsFlaeche"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_FP_LandwirtschaftsFlaeche" BEFORE INSERT OR UPDATE OR DELETE ON "FP_Landwirtschaft_Wald_und_Gruen"."FP_LandwirtschaftsFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "flaechenschluss_FP_LandwirtschaftsFlaeche" BEFORE INSERT OR UPDATE OR DELETE ON "FP_Landwirtschaft_Wald_und_Gruen"."FP_LandwirtschaftsFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isFlaechenschlussobjekt"();
CREATE TRIGGER "FP_LandwirtschaftsFlaeche_Flaechenobjekt" BEFORE INSERT OR UPDATE ON "FP_Landwirtschaft_Wald_und_Gruen"."FP_LandwirtschaftsFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isFlaechenobjekt"();
SELECT "XP_Basisobjekte".registergeometrycolumn('','FP_Landwirtschaft_Wald_und_Gruen','FP_LandwirtschaftsFlaeche', 'position','MULTIPOLYGON',2);

-- -----------------------------------------------------
-- Table "FP_Landwirtschaft_Wald_und_Gruen"."FP_LandwirtschaftsFlaeche_zweckbestimmung"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Landwirtschaft_Wald_und_Gruen"."FP_LandwirtschaftsFlaeche_zweckbestimmung" (
  "gid" BIGINT NOT NULL ,
  "zweckbestimmung" INTEGER NULL ,
  PRIMARY KEY ("gid", "zweckbestimmung"),
  CONSTRAINT "fk_FP_LandwirtschaftsFlaeche_zweckbestimmung1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Landwirtschaft_Wald_und_Gruen"."FP_LandwirtschaftsFlaeche" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_LandwirtschaftsFlaeche_zweckbestimmung2"
    FOREIGN KEY ("zweckbestimmung" )
    REFERENCES "XP_Enumerationen"."XP_ZweckbestimmungLandwirtschaft" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
GRANT SELECT ON TABLE "FP_Landwirtschaft_Wald_und_Gruen"."FP_LandwirtschaftsFlaeche_zweckbestimmung" TO xp_gast;
GRANT ALL ON TABLE "FP_Landwirtschaft_Wald_und_Gruen"."FP_LandwirtschaftsFlaeche_zweckbestimmung" TO fp_user;
COMMENT ON TABLE  "FP_Landwirtschaft_Wald_und_Gruen"."FP_LandwirtschaftsFlaeche_zweckbestimmung" IS 'Zweckbestimmungen der Fläche';


-- -----------------------------------------------------
-- Table "FP_Landwirtschaft_Wald_und_Gruen"."FP_LandwirtschaftsFlaeche_detaillierteZweckbestimmung"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Landwirtschaft_Wald_und_Gruen"."FP_LandwirtschaftsFlaeche_detaillierteZweckbestimmung" (
  "gid" BIGINT NOT NULL ,
  "detaillierteZweckbestimmung" INTEGER NULL ,
  PRIMARY KEY ("gid", "detaillierteZweckbestimmung"),
  CONSTRAINT "fk_FP_LandwirtschaftsFlaeche_detaillierteZweckbestimmung1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Landwirtschaft_Wald_und_Gruen"."FP_LandwirtschaftsFlaeche" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_LandwirtschaftsFlaeche_detaillierteZweckbestimmung2"
    FOREIGN KEY ("detaillierteZweckbestimmung" )
    REFERENCES "FP_Landwirtschaft_Wald_und_Gruen"."FP_DetailZweckbestLandwirtschaftsFlaeche" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
GRANT SELECT ON TABLE "FP_Landwirtschaft_Wald_und_Gruen"."FP_LandwirtschaftsFlaeche_detaillierteZweckbestimmung" TO xp_gast;
GRANT ALL ON TABLE "FP_Landwirtschaft_Wald_und_Gruen"."FP_LandwirtschaftsFlaeche_detaillierteZweckbestimmung" TO fp_user;
COMMENT ON TABLE  "FP_Landwirtschaft_Wald_und_Gruen"."FP_LandwirtschaftsFlaeche_detaillierteZweckbestimmung" IS 'Über eine CodeList definierte zusätzliche Zweckbestimmungen.';

-- -----------------------------------------------------
-- Table "FP_Landwirtschaft_Wald_und_Gruen"."FP_DetailZweckbestGruen"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Landwirtschaft_Wald_und_Gruen"."FP_DetailZweckbestGruen" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Code") );
GRANT SELECT ON TABLE "FP_Landwirtschaft_Wald_und_Gruen"."FP_DetailZweckbestGruen" TO xp_gast;
GRANT ALL ON TABLE "FP_Landwirtschaft_Wald_und_Gruen"."FP_DetailZweckbestGruen" TO fp_user;

-- -----------------------------------------------------
-- Table "FP_Landwirtschaft_Wald_und_Gruen"."FP_Gruen"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Landwirtschaft_Wald_und_Gruen"."FP_Gruen" (
  "gid" BIGINT NOT NULL ,
  "nutzungsform" INTEGER NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_Gruen_FP_Objekt1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Basisobjekte"."FP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_Gruen_XP_Nutzungsform1"
    FOREIGN KEY ("nutzungsform" )
    REFERENCES "XP_Enumerationen"."XP_Nutzungsform" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE);

CREATE INDEX "idx_fk_FP_Gruen_XP_Nutzungsform1" ON "FP_Landwirtschaft_Wald_und_Gruen"."FP_Gruen" ("nutzungsform") ;
GRANT SELECT ON TABLE "FP_Landwirtschaft_Wald_und_Gruen"."FP_Gruen" TO xp_gast;
GRANT ALL ON TABLE "FP_Landwirtschaft_Wald_und_Gruen"."FP_Gruen" TO fp_user;
COMMENT ON TABLE "FP_Landwirtschaft_Wald_und_Gruen"."FP_Gruen" IS 'Darstellung einer Grünfläche nach §5, Abs. 2, Nr. 5 BauGB';
COMMENT ON COLUMN  "FP_Landwirtschaft_Wald_und_Gruen"."FP_Gruen"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN  "FP_Landwirtschaft_Wald_und_Gruen"."FP_Gruen"."nutzungsform" IS 'Nutzungsform der Grünfläche.';
CREATE TRIGGER "change_to_FP_Gruen" BEFORE INSERT OR UPDATE OR DELETE ON "FP_Landwirtschaft_Wald_und_Gruen"."FP_Gruen" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table FP_Landwirtschaft_Wald_und_Gruen"."FP_Gruen_zweckbestimmung"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Landwirtschaft_Wald_und_Gruen"."FP_Gruen_zweckbestimmung" (
  "gid" BIGINT NOT NULL ,
  "zweckbestimmung" INTEGER NULL ,
  PRIMARY KEY ("gid", "zweckbestimmung"),
  CONSTRAINT "fk_FP_Gruen_zweckbestimmung1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Landwirtschaft_Wald_und_Gruen"."FP_Gruen" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_Gruen_zweckbestimmung2"
    FOREIGN KEY ("zweckbestimmung" )
    REFERENCES "XP_Enumerationen"."XP_ZweckbestimmungGruen" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
GRANT SELECT ON TABLE "FP_Landwirtschaft_Wald_und_Gruen"."FP_Gruen_zweckbestimmung" TO xp_gast;
GRANT ALL ON TABLE "FP_Landwirtschaft_Wald_und_Gruen"."FP_Gruen_zweckbestimmung" TO fp_user;
COMMENT ON TABLE  "FP_Landwirtschaft_Wald_und_Gruen"."FP_Gruen_zweckbestimmung" IS 'Allgemeine Zweckbestimmungen der Grümläche';

-- -----------------------------------------------------
-- Table "FP_Landwirtschaft_Wald_und_Gruen"."FP_Gruen_besondereZweckbestimmung"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Landwirtschaft_Wald_und_Gruen"."FP_Gruen_besondereZweckbestimmung" (
  "gid" BIGINT NOT NULL ,
  "besondereZweckbestimmung" INTEGER NULL ,
  PRIMARY KEY ("gid", "besondereZweckbestimmung"),
  CONSTRAINT "fk_FP_Gruen_besondereZweckbestimmung1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Landwirtschaft_Wald_und_Gruen"."FP_Gruen" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_Gruen_besondereZweckbestimmung2"
    FOREIGN KEY ("besondereZweckbestimmung" )
    REFERENCES "XP_Enumerationen"."XP_BesondereZweckbestimmungGruen" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
GRANT SELECT ON TABLE "FP_Landwirtschaft_Wald_und_Gruen"."FP_Gruen_besondereZweckbestimmung" TO xp_gast;
GRANT ALL ON TABLE "FP_Landwirtschaft_Wald_und_Gruen"."FP_Gruen_besondereZweckbestimmung" TO fp_user;
COMMENT ON TABLE  "FP_Landwirtschaft_Wald_und_Gruen"."FP_Gruen_besondereZweckbestimmung" IS 'Besondere Zweckbestimmungen der Grünläche, die die zugehörigen allgemeinen Zweckbestimmungen detaillieren oder ersetzen.';

-- -----------------------------------------------------
-- Table "FP_Landwirtschaft_Wald_und_Gruen"."FP_Gruen_detaillierteZweckbestimmung"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Landwirtschaft_Wald_und_Gruen"."FP_Gruen_detaillierteZweckbestimmung" (
  "gid" BIGINT NOT NULL ,
  "detaillierteZweckbestimmung" INTEGER NULL ,
  PRIMARY KEY ("gid", "detaillierteZweckbestimmung"),
  CONSTRAINT "fk_FP_Gruen_detaillierteZweckbestimmung1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Landwirtschaft_Wald_und_Gruen"."FP_Gruen" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_Gruen_detaillierteZweckbestimmung2"
    FOREIGN KEY ("detaillierteZweckbestimmung" )
    REFERENCES "FP_Landwirtschaft_Wald_und_Gruen"."FP_DetailZweckbestGruen" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
GRANT SELECT ON TABLE "FP_Landwirtschaft_Wald_und_Gruen"."FP_Gruen_detaillierteZweckbestimmung" TO xp_gast;
GRANT ALL ON TABLE "FP_Landwirtschaft_Wald_und_Gruen"."FP_Gruen_detaillierteZweckbestimmung" TO fp_user;
COMMENT ON TABLE  "FP_Landwirtschaft_Wald_und_Gruen"."FP_Gruen_detaillierteZweckbestimmung" IS 'Über eine CodeList definierte zusätzliche Zweckbestimmungen.';

-- -----------------------------------------------------
-- Table "FP_Landwirtschaft_Wald_und_Gruen"."FP_GruenFlaeche"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Landwirtschaft_Wald_und_Gruen"."FP_GruenFlaeche" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_GruenFlaeche_FP_Gruen1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Landwirtschaft_Wald_und_Gruen"."FP_Gruen" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("FP_Basisobjekte"."FP_Flaechenobjekt");

GRANT SELECT ON TABLE "FP_Landwirtschaft_Wald_und_Gruen"."FP_GruenFlaeche" TO xp_gast;
GRANT ALL ON TABLE "FP_Landwirtschaft_Wald_und_Gruen"."FP_GruenFlaeche" TO fp_user;
CREATE TRIGGER "change_to_FP_GruenFlaeche" BEFORE INSERT OR UPDATE OR DELETE ON "FP_Landwirtschaft_Wald_und_Gruen"."FP_GruenFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "FP_GruenFlaeche_Flaechenobjekt" BEFORE INSERT OR UPDATE ON "FP_Landwirtschaft_Wald_und_Gruen"."FP_GruenFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isFlaechenobjekt"();
SELECT "XP_Basisobjekte".registergeometrycolumn('','FP_Landwirtschaft_Wald_und_Gruen','FP_GruenFlaeche', 'position','MULTIPOLYGON',2);

-- -----------------------------------------------------
-- Table "FP_Landwirtschaft_Wald_und_Gruen"."FP_GruenLinie"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Landwirtschaft_Wald_und_Gruen"."FP_GruenLinie" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_GruenLinie_FP_Gruen1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Landwirtschaft_Wald_und_Gruen"."FP_Gruen" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("FP_Basisobjekte"."FP_Linienobjekt");

GRANT SELECT ON TABLE "FP_Landwirtschaft_Wald_und_Gruen"."FP_GruenLinie" TO xp_gast;
GRANT ALL ON TABLE "FP_Landwirtschaft_Wald_und_Gruen"."FP_GruenLinie" TO fp_user;
CREATE TRIGGER "change_to_FP_GruenLinie" BEFORE INSERT OR UPDATE OR DELETE ON "FP_Landwirtschaft_Wald_und_Gruen"."FP_GruenLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
SELECT "XP_Basisobjekte".registergeometrycolumn('','FP_Landwirtschaft_Wald_und_Gruen','FP_GruenLinie', 'position','MULTILINESTRING',2);

-- -----------------------------------------------------
-- Table "FP_Landwirtschaft_Wald_und_Gruen"."FP_GruenPunkt"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Landwirtschaft_Wald_und_Gruen"."FP_GruenPunkt" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_GruenPunkt_FP_Gruen1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Landwirtschaft_Wald_und_Gruen"."FP_Gruen" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("FP_Basisobjekte"."FP_Punktobjekt");

GRANT SELECT ON TABLE "FP_Landwirtschaft_Wald_und_Gruen"."FP_GruenPunkt" TO xp_gast;
GRANT ALL ON TABLE "FP_Landwirtschaft_Wald_und_Gruen"."FP_GruenPunkt" TO fp_user;
CREATE TRIGGER "change_to_FP_GruenPunkt" BEFORE INSERT OR UPDATE OR DELETE ON "FP_Landwirtschaft_Wald_und_Gruen"."FP_GruenPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
SELECT "XP_Basisobjekte".registergeometrycolumn('','FP_Landwirtschaft_Wald_und_Gruen','FP_GruenPunkt', 'position','MULTIPOINT',2);

-- -----------------------------------------------------
-- Table "FP_Sonstiges"."FP_ZweckbestimmungGenerischeObjekte"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Sonstiges"."FP_ZweckbestimmungGenerischeObjekte" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Code") );
GRANT SELECT ON TABLE "FP_Sonstiges"."FP_ZweckbestimmungGenerischeObjekte" TO xp_gast;
GRANT ALL ON TABLE "FP_Sonstiges"."FP_ZweckbestimmungGenerischeObjekte" TO fp_user;

-- -----------------------------------------------------
-- Table "FP_Sonstiges"."FP_GenerischesObjekt"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Sonstiges"."FP_GenerischesObjekt" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_GenerischesObjekt_FP_Objekt1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Basisobjekte"."FP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE);

GRANT SELECT ON TABLE "FP_Sonstiges"."FP_GenerischesObjekt" TO xp_gast;
GRANT ALL ON TABLE "FP_Sonstiges"."FP_GenerischesObjekt" TO fp_user;
COMMENT ON TABLE "FP_Sonstiges"."FP_GenerischesObjekt" IS 'Klasse zur Modellierung aller Inhalte des FPlans, die keine nachrichtliche Übernahmen aus anderen Rechts-bereichen sind, aber durch keine andere Klasse des FPlan-Fachschemas dargestellt werden können.';
COMMENT ON COLUMN  "FP_Sonstiges"."FP_GenerischesObjekt"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_FP_GenerischesObjekt" BEFORE INSERT OR UPDATE OR DELETE ON "FP_Sonstiges"."FP_GenerischesObjekt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table FP_Sonstiges"."FP_GenerischesObjekt_zweckbestimmung"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Sonstiges"."FP_GenerischesObjekt_zweckbestimmung" (
  "gid" BIGINT NOT NULL ,
  "zweckbestimmung" INTEGER NULL ,
  PRIMARY KEY ("gid", "zweckbestimmung"),
  CONSTRAINT "fk_FP_GenerischesObjekt_zweckbestimmung1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Sonstiges"."FP_GenerischesObjekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_GenerischesObjekt_zweckbestimmung2"
    FOREIGN KEY ("zweckbestimmung" )
    REFERENCES "FP_Sonstiges"."FP_ZweckbestimmungGenerischeObjekte" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
GRANT SELECT ON TABLE "FP_Sonstiges"."FP_GenerischesObjekt_zweckbestimmung" TO xp_gast;
GRANT ALL ON TABLE "FP_Sonstiges"."FP_GenerischesObjekt_zweckbestimmung" TO fp_user;
COMMENT ON TABLE  "FP_Sonstiges"."FP_GenerischesObjekt_zweckbestimmung" IS 'Über eine ExternalCodeList definierte Zweckbestimmungen des Objekts.';

-- -----------------------------------------------------
-- Table "FP_Sonstiges"."FP_Kennzeichnung"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Sonstiges"."FP_Kennzeichnung" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_Kennzeichnung_FP_Objekt1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Basisobjekte"."FP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE);

GRANT SELECT ON TABLE "FP_Sonstiges"."FP_GenerischesObjekt" TO xp_gast;
GRANT ALL ON TABLE "FP_Sonstiges"."FP_GenerischesObjekt" TO fp_user;
COMMENT ON TABLE "FP_Sonstiges"."FP_Kennzeichnung" IS 'Kennzeichnungen gemäß §5 Abs. 3 BauGB.';
COMMENT ON COLUMN  "FP_Sonstiges"."FP_Kennzeichnung"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_FP_Kennzeichnung" BEFORE INSERT OR UPDATE OR DELETE ON "FP_Sonstiges"."FP_Kennzeichnung" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table FP_Sonstiges"."FP_Kennzeichnung_zweckbestimmung"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Sonstiges"."FP_Kennzeichnung_zweckbestimmung" (
  "gid" BIGINT NOT NULL ,
  "zweckbestimmung" INTEGER NULL ,
  PRIMARY KEY ("gid", "zweckbestimmung"),
  CONSTRAINT "fk_FP_Kennzeichnung_zweckbestimmung1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Sonstiges"."FP_Kennzeichnung" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_Kennzeichnung_zweckbestimmung2"
    FOREIGN KEY ("zweckbestimmung" )
    REFERENCES "XP_Enumerationen"."XP_ZweckbestimmungKennzeichnung" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
GRANT SELECT ON TABLE "FP_Sonstiges"."FP_Kennzeichnung_zweckbestimmung" TO xp_gast;
GRANT ALL ON TABLE "FP_Sonstiges"."FP_Kennzeichnung_zweckbestimmung" TO fp_user;
COMMENT ON TABLE  "FP_Sonstiges"."FP_Kennzeichnung_zweckbestimmung" IS 'Über eine ExternalCodeList definierte Zweckbestimmungen des Objekts.';

-- -----------------------------------------------------
-- Table "FP_Sonstiges"."FP_GenerischesObjektFlaeche"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Sonstiges"."FP_GenerischesObjektFlaeche" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_GenerischesObjektFlaeche_FP_GenerischesObjekt1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Sonstiges"."FP_GenerischesObjekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("FP_Basisobjekte"."FP_Flaechenobjekt");

GRANT SELECT ON TABLE "FP_Sonstiges"."FP_GenerischesObjektFlaeche" TO xp_gast;
GRANT ALL ON TABLE "FP_Sonstiges"."FP_GenerischesObjektFlaeche" TO fp_user;
CREATE TRIGGER "change_to_FP_GenerischesObjektFlaeche" BEFORE INSERT OR UPDATE OR DELETE ON "FP_Sonstiges"."FP_GenerischesObjektFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "FP_GenerischesObjektFlaeche_Flaechenobjekt" BEFORE INSERT OR UPDATE ON "FP_Sonstiges"."FP_GenerischesObjektFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isFlaechenobjekt"();
SELECT "XP_Basisobjekte".registergeometrycolumn('','FP_Sonstiges','FP_GenerischesObjektFlaeche', 'position','MULTIPOLYGON',2);

-- -----------------------------------------------------
-- Table "FP_Sonstiges"."FP_GenerischesObjektLinie"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Sonstiges"."FP_GenerischesObjektLinie" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_GenerischesObjektLinie_FP_GenerischesObjekt1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Sonstiges"."FP_GenerischesObjekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("FP_Basisobjekte"."FP_Linienobjekt");

GRANT SELECT ON TABLE "FP_Sonstiges"."FP_GenerischesObjektLinie" TO xp_gast;
GRANT ALL ON TABLE "FP_Sonstiges"."FP_GenerischesObjektLinie" TO fp_user;
CREATE TRIGGER "change_to_FP_GenerischesObjektLinie" BEFORE INSERT OR UPDATE OR DELETE ON "FP_Sonstiges"."FP_GenerischesObjektLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
SELECT "XP_Basisobjekte".registergeometrycolumn('','FP_Sonstiges','FP_GenerischesObjektLinie', 'position','MULTILINESTRING',2);

-- -----------------------------------------------------
-- Table "FP_Sonstiges"."FP_GenerischesObjektPunkt"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Sonstiges"."FP_GenerischesObjektPunkt" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_GenerischesObjektPunkt_FP_GenerischesObjekt1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Sonstiges"."FP_GenerischesObjekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("FP_Basisobjekte"."FP_Punktobjekt");

GRANT SELECT ON TABLE "FP_Sonstiges"."FP_GenerischesObjektPunkt" TO xp_gast;
GRANT ALL ON TABLE "FP_Sonstiges"."FP_GenerischesObjektPunkt" TO fp_user;
CREATE TRIGGER "change_to_FP_GenerischesObjektPunkt" BEFORE INSERT OR UPDATE OR DELETE ON "FP_Sonstiges"."FP_GenerischesObjektPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
SELECT "XP_Basisobjekte".registergeometrycolumn('','FP_Sonstiges','FP_GenerischesObjektPunkt', 'position','MULTIPOINT',2);

-- -----------------------------------------------------
-- Table "FP_Sonstiges"."FP_KennzeichnungFlaeche"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Sonstiges"."FP_KennzeichnungFlaeche" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_KennzeichnungFlaeche_FP_Kennzeichnung1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Sonstiges"."FP_Kennzeichnung" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("FP_Basisobjekte"."FP_Flaechenobjekt");

GRANT SELECT ON TABLE "FP_Sonstiges"."FP_KennzeichnungFlaeche" TO xp_gast;
GRANT ALL ON TABLE "FP_Sonstiges"."FP_KennzeichnungFlaeche" TO fp_user;
CREATE TRIGGER "change_to_FP_KennzeichnungFlaeche" BEFORE INSERT OR UPDATE OR DELETE ON "FP_Sonstiges"."FP_KennzeichnungFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "FP_KennzeichnungFlaeche_Flaechenobjekt" BEFORE INSERT OR UPDATE ON "FP_Sonstiges"."FP_KennzeichnungFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isFlaechenobjekt"();
SELECT "XP_Basisobjekte".registergeometrycolumn('','FP_Sonstiges','FP_KennzeichnungFlaeche', 'position','MULTIPOLYGON',2);

-- -----------------------------------------------------
-- Table "FP_Sonstiges"."FP_KennzeichnungLinie"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Sonstiges"."FP_KennzeichnungLinie" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_KennzeichnungLinie_FP_Kennzeichnung1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Sonstiges"."FP_Kennzeichnung" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("FP_Basisobjekte"."FP_Linienobjekt");

GRANT SELECT ON TABLE "FP_Sonstiges"."FP_KennzeichnungLinie" TO xp_gast;
GRANT ALL ON TABLE "FP_Sonstiges"."FP_KennzeichnungLinie" TO fp_user;
CREATE TRIGGER "change_to_FP_KennzeichnungLinie" BEFORE INSERT OR UPDATE OR DELETE ON "FP_Sonstiges"."FP_KennzeichnungLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
SELECT "XP_Basisobjekte".registergeometrycolumn('','FP_Sonstiges','FP_KennzeichnungLinie', 'position','MULTILINESTRING',2);

-- -----------------------------------------------------
-- Table "FP_Sonstiges"."FP_KennzeichnungPunkt"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Sonstiges"."FP_KennzeichnungPunkt" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_KennzeichnungPunkt_FP_Kennzeichnung1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Sonstiges"."FP_Kennzeichnung" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("FP_Basisobjekte"."FP_Punktobjekt");

GRANT SELECT ON TABLE "FP_Sonstiges"."FP_KennzeichnungPunkt" TO xp_gast;
GRANT ALL ON TABLE "FP_Sonstiges"."FP_KennzeichnungPunkt" TO fp_user;
CREATE TRIGGER "change_to_FP_KennzeichnungPunkt" BEFORE INSERT OR UPDATE OR DELETE ON "FP_Sonstiges"."FP_KennzeichnungPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
SELECT "XP_Basisobjekte".registergeometrycolumn('','FP_Sonstiges','FP_KennzeichnungPunkt', 'position','MULTIPOINT',2);

-- -----------------------------------------------------
-- Table "FP_Sonstiges"."FP_NutzungsbeschraenkungsFlaeche"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Sonstiges"."FP_NutzungsbeschraenkungsFlaeche" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_NutzungsbeschraenkungsFlaeche_FP_Objekt1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Basisobjekte"."FP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("FP_Basisobjekte"."FP_Flaechenobjekt");

GRANT SELECT ON TABLE "FP_Sonstiges"."FP_NutzungsbeschraenkungsFlaeche" TO xp_gast;
GRANT ALL ON TABLE "FP_Sonstiges"."FP_NutzungsbeschraenkungsFlaeche" TO fp_user;
COMMENT ON TABLE  "FP_Sonstiges"."FP_NutzungsbeschraenkungsFlaeche" IS 'Umgrenzungen der Flächen für besondere Anlagen und Vorkehrungen zum Schutz vor schädlichen Umwelteinwirkungen im Sinne des Bundes-Immissionsschutzgesetzes (§ 5, Abs. 2, Nr. 6 BauGB)';
CREATE TRIGGER "change_to_FP_NutzungsbeschraenkungsFlaeche" BEFORE INSERT OR UPDATE OR DELETE ON "FP_Sonstiges"."FP_NutzungsbeschraenkungsFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "ueberlagerung_FP_NutzungsbeschraenkungsFlaeche" BEFORE INSERT OR UPDATE OR DELETE ON "FP_Sonstiges"."FP_NutzungsbeschraenkungsFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isUeberlagerungsobjekt"();
CREATE TRIGGER "FP_NutzungsbeschraenkungsFlaeche_Flaechenobjekt" BEFORE INSERT OR UPDATE ON "FP_Sonstiges"."FP_NutzungsbeschraenkungsFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isFlaechenobjekt"();
SELECT "XP_Basisobjekte".registergeometrycolumn('','FP_Sonstiges','FP_NutzungsbeschraenkungsFlaeche', 'position','MULTIPOLYGON',2);

-- -----------------------------------------------------
-- Table "FP_Sonstiges"."FP_ZweckbestimmungPrivilegiertesVorhaben"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Sonstiges"."FP_ZweckbestimmungPrivilegiertesVorhaben" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Code") );
GRANT SELECT ON TABLE "FP_Sonstiges"."FP_ZweckbestimmungPrivilegiertesVorhaben" TO xp_gast;

-- -----------------------------------------------------
-- Table "FP_Sonstiges"."FP_BesondZweckbestPrivilegiertesVorhaben"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Sonstiges"."FP_BesondZweckbestPrivilegiertesVorhaben" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Code") );
GRANT SELECT ON TABLE "FP_Sonstiges"."FP_BesondZweckbestPrivilegiertesVorhaben" TO xp_gast;

-- -----------------------------------------------------
-- Table "FP_Sonstiges"."FP_PrivilegiertesVorhaben"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Sonstiges"."FP_PrivilegiertesVorhaben" (
  "gid" BIGINT NOT NULL ,
  "vorhaben" VARCHAR(255) NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_PrivilegiertesVorhaben_FP_Objekt1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Basisobjekte"."FP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE);

GRANT SELECT ON TABLE "FP_Sonstiges"."FP_PrivilegiertesVorhaben" TO xp_gast;
GRANT ALL ON TABLE "FP_Sonstiges"."FP_PrivilegiertesVorhaben" TO fp_user;
COMMENT ON TABLE  "FP_Sonstiges"."FP_PrivilegiertesVorhaben" IS 'Standorte für privilegierte Außenbereichsvorhaben und für sonstige Anlagen in Außenbereichen gem. § 35 Abs. 1 und 2 BauGB.';
COMMENT ON COLUMN  "FP_Sonstiges"."FP_PrivilegiertesVorhaben"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN  "FP_Sonstiges"."FP_PrivilegiertesVorhaben"."vorhaben" IS 'Nähere Beschreibung des Vorhabens';
CREATE TRIGGER "change_to_FP_PrivilegiertesVorhaben" BEFORE INSERT OR UPDATE OR DELETE ON "FP_Sonstiges"."FP_PrivilegiertesVorhaben" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table FP_Sonstiges"."FP_PrivilegiertesVorhaben_zweckbestimmung"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Sonstiges"."FP_PrivilegiertesVorhaben_zweckbestimmung" (
  "gid" BIGINT NOT NULL ,
  "zweckbestimmung" INTEGER NULL ,
  PRIMARY KEY ("gid", "zweckbestimmung"),
  CONSTRAINT "fk_FP_PrivilegiertesVorhaben_zweckbestimmung1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Sonstiges"."FP_PrivilegiertesVorhaben" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_PrivilegiertesVorhaben_zweckbestimmung2"
    FOREIGN KEY ("zweckbestimmung" )
    REFERENCES "FP_Sonstiges"."FP_ZweckbestimmungPrivilegiertesVorhaben" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
GRANT SELECT ON TABLE "FP_Sonstiges"."FP_PrivilegiertesVorhaben_zweckbestimmung" TO xp_gast;
GRANT ALL ON TABLE "FP_Sonstiges"."FP_PrivilegiertesVorhaben_zweckbestimmung" TO fp_user;
COMMENT ON TABLE  "FP_Sonstiges"."FP_PrivilegiertesVorhaben_zweckbestimmung" IS 'Zweckbestimmungen des Vorhabens.';

-- -----------------------------------------------------
-- Table "FP_Sonstiges"."FP_PrivilegiertesVorhaben_besondereZweckbestimmung"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Sonstiges"."FP_PrivilegiertesVorhaben_besondereZweckbestimmung" (
  "gid" BIGINT NOT NULL ,
  "besondereZweckbestimmung" INTEGER NULL ,
  PRIMARY KEY ("gid", "besondereZweckbestimmung"),
  CONSTRAINT "fk_FP_PrivilegiertesVorhaben_besondereZweckbestimmung1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Sonstiges"."FP_PrivilegiertesVorhaben" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_PrivilegiertesVorhaben_besondereZweckbestimmung1"
    FOREIGN KEY ("besondereZweckbestimmung" )
    REFERENCES "FP_Sonstiges"."FP_BesondZweckbestPrivilegiertesVorhaben" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
GRANT SELECT ON TABLE "FP_Sonstiges"."FP_PrivilegiertesVorhaben_besondereZweckbestimmung" TO xp_gast;
GRANT ALL ON TABLE "FP_Sonstiges"."FP_PrivilegiertesVorhaben_besondereZweckbestimmung" TO fp_user;
COMMENT ON TABLE  "FP_Sonstiges"."FP_PrivilegiertesVorhaben_besondereZweckbestimmung" IS 'Besondere Zweckbestimmungendes Vorhabens, die die spezifizierten allgemeinen Zweckbestimmungen detaillieren.';

-- -----------------------------------------------------
-- Table "FP_Sonstiges"."FP_PrivilegiertesVorhabenFlaeche"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Sonstiges"."FP_PrivilegiertesVorhabenFlaeche" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_PrivVorhaFlaeche_FP_PrivilegiertesVorhaben1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Sonstiges"."FP_PrivilegiertesVorhaben" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("FP_Basisobjekte"."FP_Flaechenobjekt");

GRANT SELECT ON TABLE "FP_Sonstiges"."FP_PrivilegiertesVorhabenFlaeche" TO xp_gast;
GRANT ALL ON TABLE "FP_Sonstiges"."FP_PrivilegiertesVorhabenFlaeche" TO fp_user;
CREATE TRIGGER "change_to_FP_PrivilegiertesVorhabenFlaeche" BEFORE INSERT OR UPDATE OR DELETE ON "FP_Sonstiges"."FP_PrivilegiertesVorhabenFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "FP_PrivilegiertesVorhabenFlaeche_Flaechenobjekt" BEFORE INSERT OR UPDATE ON "FP_Sonstiges"."FP_PrivilegiertesVorhabenFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isFlaechenobjekt"();
SELECT "XP_Basisobjekte".registergeometrycolumn('','FP_Sonstiges','FP_PrivilegiertesVorhabenFlaeche', 'position','MULTIPOLYGON',2);

-- -----------------------------------------------------
-- Table "FP_Sonstiges"."FP_PrivilegiertesVorhabenLinie"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Sonstiges"."FP_PrivilegiertesVorhabenLinie" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_PrivVorhaLinie_FP_PrivilegiertesVorhaben1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Sonstiges"."FP_PrivilegiertesVorhaben" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("FP_Basisobjekte"."FP_Linienobjekt");

GRANT SELECT ON TABLE "FP_Sonstiges"."FP_PrivilegiertesVorhabenLinie" TO xp_gast;
GRANT ALL ON TABLE "FP_Sonstiges"."FP_PrivilegiertesVorhabenLinie" TO fp_user;
CREATE TRIGGER "change_to_FP_PrivilegiertesVorhabenLinie" BEFORE INSERT OR UPDATE OR DELETE ON "FP_Sonstiges"."FP_PrivilegiertesVorhabenLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
SELECT "XP_Basisobjekte".registergeometrycolumn('','FP_Sonstiges','FP_PrivilegiertesVorhabenLinie', 'position','MULTILINESTRING',2);

-- -----------------------------------------------------
-- Table "FP_Sonstiges"."FP_PrivilegiertesVorhabenPunkt"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Sonstiges"."FP_PrivilegiertesVorhabenPunkt" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_PrivVorhaPunkt_FP_PrivilegiertesVorhaben1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Sonstiges"."FP_PrivilegiertesVorhaben" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("FP_Basisobjekte"."FP_Punktobjekt");

GRANT SELECT ON TABLE "FP_Sonstiges"."FP_PrivilegiertesVorhabenPunkt" TO xp_gast;
GRANT ALL ON TABLE "FP_Sonstiges"."FP_PrivilegiertesVorhabenPunkt" TO fp_user;
CREATE TRIGGER "change_to_FP_PrivilegiertesVorhabenPunkt" BEFORE INSERT OR UPDATE OR DELETE ON "FP_Sonstiges"."FP_PrivilegiertesVorhabenPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
SELECT "XP_Basisobjekte".registergeometrycolumn('','FP_Sonstiges','FP_PrivilegiertesVorhabenPunkt', 'position','MULTIPOINT',2);

-- -----------------------------------------------------
-- Table "FP_Sonstiges"."FP_VorbehalteFlaeche"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Sonstiges"."FP_VorbehalteFlaeche" (
  "gid" BIGINT NOT NULL ,
  "vorbehalt" VARCHAR(255) NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_VorbehalteFlaeche_FP_Objekt1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Basisobjekte"."FP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("FP_Basisobjekte"."FP_Flaechenobjekt");

GRANT SELECT ON TABLE "FP_Sonstiges"."FP_VorbehalteFlaeche" TO xp_gast;
GRANT ALL ON TABLE "FP_Sonstiges"."FP_VorbehalteFlaeche" TO fp_user;
COMMENT ON TABLE  "FP_Sonstiges"."FP_VorbehalteFlaeche" IS '';
COMMENT ON COLUMN  "FP_Sonstiges"."FP_VorbehalteFlaeche"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN  "FP_Sonstiges"."FP_VorbehalteFlaeche"."vorbehalt" IS '';
CREATE TRIGGER "change_to_FP_VorbehalteFlaeche" BEFORE INSERT OR UPDATE OR DELETE ON "FP_Sonstiges"."FP_VorbehalteFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "FP_VorbehalteFlaeche_Flaechenobjekt" BEFORE INSERT OR UPDATE ON "FP_Sonstiges"."FP_VorbehalteFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isFlaechenobjekt"();
SELECT "XP_Basisobjekte".registergeometrycolumn('','FP_Sonstiges','FP_VorbehalteFlaeche', 'position','MULTIPOLYGON',2);

-- -----------------------------------------------------
-- Table "FP_Sonstiges"."FP_UnverbindlicheVormerkung"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Sonstiges"."FP_UnverbindlicheVormerkung" (
  "gid" BIGINT NOT NULL ,
  "vormerkung" VARCHAR(255) NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_UnverbindlicheVormerkung_FP_Objekt1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Basisobjekte"."FP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE);

GRANT SELECT ON TABLE "FP_Sonstiges"."FP_UnverbindlicheVormerkung" TO xp_gast;
GRANT ALL ON TABLE "FP_Sonstiges"."FP_UnverbindlicheVormerkung" TO fp_user;
COMMENT ON TABLE  "FP_Sonstiges"."FP_UnverbindlicheVormerkung" IS 'Unverbindliche Vormerkung späterer Planungsabsichten';
COMMENT ON COLUMN  "FP_Sonstiges"."FP_UnverbindlicheVormerkung"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN  "FP_Sonstiges"."FP_UnverbindlicheVormerkung"."vormerkung" IS '';
CREATE TRIGGER "change_to_FP_UnverbindlicheVormerkung" BEFORE INSERT OR UPDATE OR DELETE ON "FP_Sonstiges"."FP_UnverbindlicheVormerkung" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "FP_Sonstiges"."FP_UnverbindlicheVormerkungFlaeche"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Sonstiges"."FP_UnverbindlicheVormerkungFlaeche" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_UnverVormerFlaeche_FP_UnverVormer1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Sonstiges"."FP_UnverbindlicheVormerkung" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("FP_Basisobjekte"."FP_Flaechenobjekt");

GRANT SELECT ON TABLE "FP_Sonstiges"."FP_UnverbindlicheVormerkungFlaeche" TO xp_gast;
GRANT ALL ON TABLE "FP_Sonstiges"."FP_UnverbindlicheVormerkungFlaeche" TO fp_user;
CREATE TRIGGER "change_to_FP_UnverbindlicheVormerkungFlaeche" BEFORE INSERT OR UPDATE OR DELETE ON "FP_Sonstiges"."FP_UnverbindlicheVormerkungFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "FP_UnverbindlicheVormerkungFlaeche_Flaechenobjekt" BEFORE INSERT OR UPDATE ON "FP_Sonstiges"."FP_UnverbindlicheVormerkungFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isFlaechenobjekt"();
SELECT "XP_Basisobjekte".registergeometrycolumn('','FP_Sonstiges','FP_UnverbindlicheVormerkungFlaeche', 'position','MULTIPOLYGON',2);

-- -----------------------------------------------------
-- Table "FP_Sonstiges"."FP_UnverbindlicheVormerkungLinie"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Sonstiges"."FP_UnverbindlicheVormerkungLinie" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_UnverVormerLinie_FP_UnverVormer1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Sonstiges"."FP_UnverbindlicheVormerkung" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("FP_Basisobjekte"."FP_Linienobjekt");

GRANT SELECT ON TABLE "FP_Sonstiges"."FP_UnverbindlicheVormerkungLinie" TO xp_gast;
GRANT ALL ON TABLE "FP_Sonstiges"."FP_UnverbindlicheVormerkungLinie" TO fp_user;
CREATE TRIGGER "change_to_FP_UnverbindlicheVormerkungLinie" BEFORE INSERT OR UPDATE OR DELETE ON "FP_Sonstiges"."FP_UnverbindlicheVormerkungLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
SELECT "XP_Basisobjekte".registergeometrycolumn('','FP_Sonstiges','FP_UnverbindlicheVormerkungLinie', 'position','MULTILINESTRING',2);

-- -----------------------------------------------------
-- Table "FP_Sonstiges"."FP_UnverbindlicheVormerkungPunkt"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Sonstiges"."FP_UnverbindlicheVormerkungPunkt" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_UnverVormerPunkt_FP_UnverVormer1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Sonstiges"."FP_UnverbindlicheVormerkung" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("FP_Basisobjekte"."FP_Punktobjekt");

GRANT SELECT ON TABLE "FP_Sonstiges"."FP_UnverbindlicheVormerkungPunkt" TO xp_gast;
GRANT ALL ON TABLE "FP_Sonstiges"."FP_UnverbindlicheVormerkungPunkt" TO fp_user;
CREATE TRIGGER "change_to_FP_FP_UnverbindlicheVormerkungPunkt" BEFORE INSERT OR UPDATE OR DELETE ON "FP_Sonstiges"."FP_UnverbindlicheVormerkungPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
SELECT "XP_Basisobjekte".registergeometrycolumn('','FP_Sonstiges','FP_UnverbindlicheVormerkungPunkt', 'position','MULTIPOINT',2);

-- -----------------------------------------------------
-- Table "FP_Sonstiges"."FP_TextlicheDarstellungsFlaeche"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Sonstiges"."FP_TextlicheDarstellungsFlaeche" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_TextlicheDarstellungsFlaeche_FP_Objekt1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Basisobjekte"."FP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("FP_Basisobjekte"."FP_Flaechenobjekt");

GRANT SELECT ON TABLE "FP_Sonstiges"."FP_TextlicheDarstellungsFlaeche" TO xp_gast;
GRANT ALL ON TABLE "FP_Sonstiges"."FP_TextlicheDarstellungsFlaeche" TO fp_user;
COMMENT ON TABLE  "FP_Sonstiges"."FP_TextlicheDarstellungsFlaeche" IS 'Bereich in dem bestimmte Textliche Darstellungen gültig sind, die über die Relation "refTextInhalt" (Basisklasse XP_Objekt) spezifiziert werden.';
COMMENT ON COLUMN  "FP_Sonstiges"."FP_TextlicheDarstellungsFlaeche"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_FP_TextlicheDarstellungsFlaeche" BEFORE INSERT OR UPDATE OR DELETE ON "FP_Sonstiges"."FP_TextlicheDarstellungsFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "ueberlagerung_FP_TextlicheDarstellungsFlaeche" BEFORE INSERT OR UPDATE OR DELETE ON "FP_Sonstiges"."FP_TextlicheDarstellungsFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isUeberlagerungsobjekt"();
CREATE TRIGGER "FP_TextlicheDarstellungsFlaeche_Flaechenobjekt" BEFORE INSERT OR UPDATE ON "FP_Sonstiges"."FP_TextlicheDarstellungsFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isFlaechenobjekt"();
SELECT "XP_Basisobjekte".registergeometrycolumn('','FP_Sonstiges','FP_TextlicheDarstellungsFlaeche', 'position','MULTIPOLYGON',2);

-- -----------------------------------------------------
-- Table "FP_Ver_und_Entsorgung"."FP_DetailZweckbestVerEntsorgung"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Ver_und_Entsorgung"."FP_DetailZweckbestVerEntsorgung" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Code") );
GRANT SELECT ON TABLE "FP_Ver_und_Entsorgung"."FP_DetailZweckbestVerEntsorgung" TO xp_gast;
GRANT ALL ON TABLE "FP_Ver_und_Entsorgung"."FP_DetailZweckbestVerEntsorgung" TO fp_user;

-- -----------------------------------------------------
-- Table "FP_Ver_und_Entsorgung"."FP_VerEntsorgung"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Ver_und_Entsorgung"."FP_VerEntsorgung" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_VerEntsorgung_FP_Objekt"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Basisobjekte"."FP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE);

GRANT SELECT ON TABLE "FP_Ver_und_Entsorgung"."FP_VerEntsorgung" TO xp_gast;
GRANT ALL ON TABLE "FP_Ver_und_Entsorgung"."FP_VerEntsorgung" TO fp_user;
COMMENT ON TABLE  "FP_Ver_und_Entsorgung"."FP_VerEntsorgung" IS 'Flächen für Versorgungsanlagen, für die Abfallentsorgung und Abwasserbeseitigung sowie für Ablagerungen (§5, Abs. 2, Nr. 4 BauGB).';
COMMENT ON COLUMN  "FP_Ver_und_Entsorgung"."FP_VerEntsorgung"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_FP_VerEntsorgung" BEFORE INSERT OR UPDATE OR DELETE ON "FP_Ver_und_Entsorgung"."FP_VerEntsorgung" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table FP_Ver_und_Entsorgung"."FP_VerEntsorgung_zweckbestimmung"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Ver_und_Entsorgung"."FP_VerEntsorgung_zweckbestimmung" (
  "gid" BIGINT NOT NULL ,
  "zweckbestimmung" INTEGER NULL ,
  PRIMARY KEY ("gid", "zweckbestimmung"),
  CONSTRAINT "fk_FP_VerEntsorgung_zweckbestimmung1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Ver_und_Entsorgung"."FP_VerEntsorgung" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_VerEntsorgung_zweckbestimmung2"
    FOREIGN KEY ("zweckbestimmung" )
    REFERENCES "XP_Enumerationen"."XP_ZweckbestimmungVerEntsorgung" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
GRANT SELECT ON TABLE "FP_Ver_und_Entsorgung"."FP_VerEntsorgung_zweckbestimmung" TO xp_gast;
GRANT ALL ON TABLE "FP_Ver_und_Entsorgung"."FP_VerEntsorgung_zweckbestimmung" TO fp_user;
COMMENT ON TABLE  "FP_Ver_und_Entsorgung"."FP_VerEntsorgung_zweckbestimmung" IS 'Allgemeine Zweckbestimmungen der Fläche';

-- -----------------------------------------------------
-- Table "FP_Ver_und_Entsorgung"."FP_VerEntsorgung_besondereZweckbestimmung"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Ver_und_Entsorgung"."FP_VerEntsorgung_besondereZweckbestimmung" (
  "gid" BIGINT NOT NULL ,
  "besondereZweckbestimmung" INTEGER NULL ,
  PRIMARY KEY ("gid", "besondereZweckbestimmung"),
  CONSTRAINT "fk_FP_VerEntsorgung_besondereZweckbestimmung1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Ver_und_Entsorgung"."FP_VerEntsorgung" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_VerEntsorgung_besondereZweckbestimmung2"
    FOREIGN KEY ("besondereZweckbestimmung" )
    REFERENCES "XP_Enumerationen"."XP_BesondereZweckbestimmungVerEntsorgung" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
GRANT SELECT ON TABLE "FP_Ver_und_Entsorgung"."FP_VerEntsorgung_besondereZweckbestimmung" TO xp_gast;
GRANT ALL ON TABLE "FP_Ver_und_Entsorgung"."FP_VerEntsorgung_besondereZweckbestimmung" TO fp_user;
COMMENT ON TABLE  "FP_Ver_und_Entsorgung"."FP_VerEntsorgung_besondereZweckbestimmung" IS 'Besondere Zweckbestimmungen der Fläche, die die zugehörigen allgemeinen Zweckbestimmungen detaillieren oder ersetzen.';

-- -----------------------------------------------------
-- Table "FP_Ver_und_Entsorgung"."FP_VerEntsorgung_detaillierteZweckbestimmung"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Ver_und_Entsorgung"."FP_VerEntsorgung_detaillierteZweckbestimmung" (
  "gid" BIGINT NOT NULL ,
  "detaillierteZweckbestimmung" INTEGER NULL ,
  PRIMARY KEY ("gid", "detaillierteZweckbestimmung"),
  CONSTRAINT "fk_FP_VerEntsorgung_detaillierteZweckbestimmung1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Ver_und_Entsorgung"."FP_VerEntsorgung" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_VerEntsorgung_detaillierteZweckbestimmung2"
    FOREIGN KEY ("detaillierteZweckbestimmung" )
    REFERENCES "FP_Ver_und_Entsorgung"."FP_DetailZweckbestVerEntsorgung" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
GRANT SELECT ON TABLE "FP_Ver_und_Entsorgung"."FP_VerEntsorgung_detaillierteZweckbestimmung" TO xp_gast;
GRANT ALL ON TABLE "FP_Ver_und_Entsorgung"."FP_VerEntsorgung_detaillierteZweckbestimmung" TO fp_user;
COMMENT ON TABLE  "FP_Ver_und_Entsorgung"."FP_VerEntsorgung_detaillierteZweckbestimmung" IS 'Über eine CodeList definierte zusätzliche Zweckbestimmungen.';


-- -----------------------------------------------------
-- Table "FP_Ver_und_Entsorgung"."FP_VerEntsorgungFlaeche"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Ver_und_Entsorgung"."FP_VerEntsorgungFlaeche" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_VerEntsorgungFlaeche_FP_VerEntsorgung1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Ver_und_Entsorgung"."FP_VerEntsorgung" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("FP_Basisobjekte"."FP_Flaechenobjekt");

GRANT SELECT ON TABLE "FP_Ver_und_Entsorgung"."FP_VerEntsorgungFlaeche" TO xp_gast;
GRANT ALL ON TABLE "FP_Ver_und_Entsorgung"."FP_VerEntsorgungFlaeche" TO fp_user;
CREATE TRIGGER "change_to_FP_VerEntsorgungFlaeche" BEFORE INSERT OR UPDATE OR DELETE ON "FP_Ver_und_Entsorgung"."FP_VerEntsorgungFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "FP_VerEntsorgungFlaeche_Flaechenobjekt" BEFORE INSERT OR UPDATE ON "FP_Ver_und_Entsorgung"."FP_VerEntsorgungFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isFlaechenobjekt"();
SELECT "XP_Basisobjekte".registergeometrycolumn('','FP_Ver_und_Entsorgung','FP_VerEntsorgungFlaeche', 'position','MULTIPOLYGON',2);

-- -----------------------------------------------------
-- Table "FP_Ver_und_Entsorgung"."FP_VerEntsorgungLinie"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Ver_und_Entsorgung"."FP_VerEntsorgungLinie" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_VerEntsorgungLinie_FP_VerEntsorgung1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Ver_und_Entsorgung"."FP_VerEntsorgung" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("FP_Basisobjekte"."FP_Linienobjekt");

GRANT SELECT ON TABLE "FP_Ver_und_Entsorgung"."FP_VerEntsorgungLinie" TO xp_gast;
GRANT ALL ON TABLE "FP_Ver_und_Entsorgung"."FP_VerEntsorgungLinie" TO fp_user;
CREATE TRIGGER "change_to_FP_VerEntsorgungLinie" BEFORE INSERT OR UPDATE OR DELETE ON "FP_Ver_und_Entsorgung"."FP_VerEntsorgungLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
SELECT "XP_Basisobjekte".registergeometrycolumn('','FP_Ver_und_Entsorgung','FP_VerEntsorgungLinie', 'position','MULTILINESTRING',2);

-- -----------------------------------------------------
-- Table "FP_Ver_und_Entsorgung"."FP_VerEntsorgungPunkt"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Ver_und_Entsorgung"."FP_VerEntsorgungPunkt" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_VerEntsorgungPunkt_FP_VerEntsorgung1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Ver_und_Entsorgung"."FP_VerEntsorgung" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("FP_Basisobjekte"."FP_Punktobjekt");

GRANT SELECT ON TABLE "FP_Ver_und_Entsorgung"."FP_VerEntsorgungPunkt" TO xp_gast;
GRANT ALL ON TABLE "FP_Ver_und_Entsorgung"."FP_VerEntsorgungPunkt" TO fp_user;
CREATE TRIGGER "change_to_FP_VerEntsorgungPunkt" BEFORE INSERT OR UPDATE OR DELETE ON "FP_Ver_und_Entsorgung"."FP_VerEntsorgungPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
SELECT "XP_Basisobjekte".registergeometrycolumn('','FP_Ver_und_Entsorgung','FP_VerEntsorgungPunkt', 'position','MULTIPOINT',2);

-- -----------------------------------------------------
-- Table "FP_Verkehr"."FP_ZweckbestimmungStrassenverkehr"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Verkehr"."FP_ZweckbestimmungStrassenverkehr" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Code") );
GRANT SELECT ON TABLE "FP_Verkehr"."FP_ZweckbestimmungStrassenverkehr" TO xp_gast;

-- -----------------------------------------------------
-- Table "FP_Verkehr"."FP_BesondereZweckbestimmungStrassenverkehr"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Verkehr"."FP_BesondereZweckbestimmungStrassenverkehr" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Code") );
GRANT SELECT ON TABLE "FP_Verkehr"."FP_BesondereZweckbestimmungStrassenverkehr" TO xp_gast;

-- -----------------------------------------------------
-- Table "FP_Verkehr"."FP_DetailZweckbestStrassenverkehr"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Verkehr"."FP_DetailZweckbestStrassenverkehr" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Code") );
GRANT SELECT ON TABLE "FP_Verkehr"."FP_DetailZweckbestStrassenverkehr" TO xp_gast;
GRANT ALL ON TABLE "FP_Verkehr"."FP_DetailZweckbestStrassenverkehr" TO fp_user;

-- -----------------------------------------------------
-- Table "FP_Verkehr"."FP_Strassenverkehr"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Verkehr"."FP_Strassenverkehr" (
  "gid" BIGINT NOT NULL ,
  "zweckbestimmung" INTEGER NULL ,
  "besondereZweckbestimmung" INTEGER NULL ,
  "detaillierteZweckbestimmung" INTEGER NULL ,
  "nutzungsform" INTEGER NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_Strassenverkehr_FP_ZweckStrassenverkehr"
    FOREIGN KEY ("zweckbestimmung" )
    REFERENCES "FP_Verkehr"."FP_ZweckbestimmungStrassenverkehr" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_Strassenverkehr_FP_BesZweckStrassenverk1"
    FOREIGN KEY ("besondereZweckbestimmung" )
    REFERENCES "FP_Verkehr"."FP_BesondereZweckbestimmungStrassenverkehr" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_Strassenverkehr_FP_DetailZweckStrassenverkehr1"
    FOREIGN KEY ("detaillierteZweckbestimmung" )
    REFERENCES "FP_Verkehr"."FP_DetailZweckbestStrassenverkehr" ("Code" )
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_Strassenverkehr_XP_Nutzungsform1"
    FOREIGN KEY ("nutzungsform" )
    REFERENCES "XP_Enumerationen"."XP_Nutzungsform" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_Strassenverkehr_FP_Objekt1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Basisobjekte"."FP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE);

CREATE INDEX "idx_fk_FP_Strassenverkehr_FP_ZweckStrassenverkehr" ON "FP_Verkehr"."FP_Strassenverkehr" ("zweckbestimmung") ;
CREATE INDEX "idx_fk_FP_Strassenverkehr_FP_BesZweckStrassenverk1" ON "FP_Verkehr"."FP_Strassenverkehr" ("besondereZweckbestimmung") ;
CREATE INDEX "idx_fk_FP_Strassenverkehr_FP_DetailZweckStrassenverkehr1" ON "FP_Verkehr"."FP_Strassenverkehr" ("detaillierteZweckbestimmung") ;
CREATE INDEX "idx_fk_FP_Strassenverkehr_XP_Nutzungsform1" ON "FP_Verkehr"."FP_Strassenverkehr" ("nutzungsform") ;
GRANT SELECT ON TABLE "FP_Verkehr"."FP_Strassenverkehr" TO xp_gast;
GRANT ALL ON TABLE "FP_Verkehr"."FP_Strassenverkehr" TO fp_user;
COMMENT ON TABLE  "FP_Verkehr"."FP_Strassenverkehr" IS 'Darstellung von Flächen für den überörtlichen Verkehr und für die örtlichen Hauptverkehrszüge ( §5, Abs. 2, Nr. 3 BauGB).';
COMMENT ON COLUMN  "FP_Verkehr"."FP_Strassenverkehr"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN  "FP_Verkehr"."FP_Strassenverkehr"."zweckbestimmung" IS 'Allgemeine Zweckbestimmung des Objektes.';
COMMENT ON COLUMN  "FP_Verkehr"."FP_Strassenverkehr"."besondereZweckbestimmung" IS 'Besondere Zweckbestimmung des Objektes, der die allgemiene Zweckbestimmung detaillliert oder ersetzt.';
COMMENT ON COLUMN  "FP_Verkehr"."FP_Strassenverkehr"."detaillierteZweckbestimmung" IS 'Über eine CodeList definierte zusätzliche Zweckbestimmung';
COMMENT ON COLUMN  "FP_Verkehr"."FP_Strassenverkehr"."nutzungsform" IS 'Nutzungsform';
CREATE TRIGGER "change_to_FP_Strassenverkehr" BEFORE INSERT OR UPDATE OR DELETE ON "FP_Verkehr"."FP_Strassenverkehr" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "FP_Verkehr"."FP_StrassenverkehrFlaeche"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Verkehr"."FP_StrassenverkehrFlaeche" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_StrassenverkehrFlaeche_FP_Strassenverkehr1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Verkehr"."FP_Strassenverkehr" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("FP_Basisobjekte"."FP_Flaechenobjekt");

GRANT SELECT ON TABLE "FP_Verkehr"."FP_StrassenverkehrFlaeche" TO xp_gast;
GRANT ALL ON TABLE "FP_Verkehr"."FP_StrassenverkehrFlaeche" TO fp_user;
CREATE TRIGGER "change_to_FP_StrassenverkehrFlaeche" BEFORE INSERT OR UPDATE OR DELETE ON "FP_Verkehr"."FP_StrassenverkehrFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "FP_StrassenverkehrFlaeche_Flaechenobjekt" BEFORE INSERT OR UPDATE ON "FP_Verkehr"."FP_StrassenverkehrFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isFlaechenobjekt"();
SELECT "XP_Basisobjekte".registergeometrycolumn('','FP_Verkehr','FP_StrassenverkehrFlaeche', 'position','MULTIPOLYGON',2);

-- -----------------------------------------------------
-- Table "FP_Verkehr"."FP_StrassenverkehrLinie"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Verkehr"."FP_StrassenverkehrLinie" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_StrassenverkehrLinie_FP_Strassenverkehr1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Verkehr"."FP_Strassenverkehr" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("FP_Basisobjekte"."FP_Linienobjekt");

GRANT SELECT ON TABLE "FP_Verkehr"."FP_StrassenverkehrLinie" TO xp_gast;
GRANT ALL ON TABLE "FP_Verkehr"."FP_StrassenverkehrLinie" TO fp_user;
CREATE TRIGGER "change_to_FP_StrassenverkehrLinie" BEFORE INSERT OR UPDATE OR DELETE ON "FP_Verkehr"."FP_StrassenverkehrLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
SELECT "XP_Basisobjekte".registergeometrycolumn('','FP_Verkehr','FP_StrassenverkehrLinie', 'position','MULTILINESTRING',2);

-- -----------------------------------------------------
-- Table "FP_Verkehr"."FP_StrassenverkehrPunkt"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Verkehr"."FP_StrassenverkehrPunkt" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_StrassenverkehrPunkt_FP_Strassenverkehr1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Verkehr"."FP_Strassenverkehr" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("FP_Basisobjekte"."FP_Punktobjekt");

GRANT SELECT ON TABLE "FP_Verkehr"."FP_StrassenverkehrPunkt" TO xp_gast;
GRANT ALL ON TABLE "FP_Verkehr"."FP_StrassenverkehrPunkt" TO fp_user;
CREATE TRIGGER "change_to_FP_StrassenverkehrPunkt" BEFORE INSERT OR UPDATE OR DELETE ON "FP_Verkehr"."FP_StrassenverkehrPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
SELECT "XP_Basisobjekte".registergeometrycolumn('','FP_Verkehr','FP_StrassenverkehrPunkt', 'position','MULTIPOINT',2);

-- -----------------------------------------------------
-- Table "FP_Wasser"."FP_DetailZweckbestGewaesser"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Wasser"."FP_DetailZweckbestGewaesser" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Code") );
GRANT SELECT ON TABLE "FP_Wasser"."FP_DetailZweckbestGewaesser" TO xp_gast;
GRANT ALL ON TABLE "FP_Wasser"."FP_DetailZweckbestGewaesser" TO fp_user;

-- -----------------------------------------------------
-- Table "FP_Wasser"."FP_Gewaesser"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Wasser"."FP_Gewaesser" (
  "gid" BIGINT NOT NULL ,
  "zweckbestimmung" INTEGER,
  "detaillierteZweckbestimmung" INTEGER,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_Gewaesser_XP_ZweckbestimmungGewaesser"
    FOREIGN KEY ("zweckbestimmung" )
    REFERENCES "XP_Enumerationen"."XP_ZweckbestimmungGewaesser" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_Gewaesser_FP_DetailZweckbestGewaesser1"
    FOREIGN KEY ("detaillierteZweckbestimmung" )
    REFERENCES "FP_Wasser"."FP_DetailZweckbestGewaesser" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_Gewaesser_FP_Objekt1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Basisobjekte"."FP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE);

CREATE INDEX "idx_fk_FP_Gewaesser_XP_ZweckbestimmungGewaesser" ON "FP_Wasser"."FP_Gewaesser" ("zweckbestimmung") ;
CREATE INDEX "idx_fk_FP_Gewaesser_FP_DetailZweckbestGewaesser1" ON "FP_Wasser"."FP_Gewaesser" ("detaillierteZweckbestimmung") ;
GRANT SELECT ON TABLE "FP_Wasser"."FP_Gewaesser" TO xp_gast;
GRANT ALL ON TABLE "FP_Wasser"."FP_Gewaesser" TO fp_user;
COMMENT ON TABLE  "FP_Wasser"."FP_Gewaesser" IS 'Darstellung von Wasserflächen nach §5, Abs. 2, Nr. 7 BauGB.';
COMMENT ON COLUMN  "FP_Wasser"."FP_Gewaesser"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN  "FP_Wasser"."FP_Gewaesser"."zweckbestimmung" IS 'Zweckbestimmung des Gewässers.';
COMMENT ON COLUMN  "FP_Wasser"."FP_Gewaesser"."detaillierteZweckbestimmung" IS 'Über eine CodeList definierte zusätzliche Zweckbestimmung des Objektes.';
CREATE TRIGGER "change_to_FP_Gewaesser" BEFORE INSERT OR UPDATE OR DELETE ON "FP_Wasser"."FP_Gewaesser" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "FP_Wasser"."FP_DetailZweckbestWasserwirtschaft"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Wasser"."FP_DetailZweckbestWasserwirtschaft" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Code") );
GRANT SELECT ON TABLE "FP_Wasser"."FP_DetailZweckbestWasserwirtschaft" TO xp_gast;
GRANT ALL ON TABLE "FP_Wasser"."FP_DetailZweckbestWasserwirtschaft" TO fp_user;

-- -----------------------------------------------------
-- Table "FP_Wasser"."FP_Wasserwirtschaft"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Wasser"."FP_Wasserwirtschaft" (
  "gid" BIGINT NOT NULL ,
  "zweckbestimmung" INTEGER NULL ,
  "detaillierteZweckbestimmung" INTEGER NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_Wasserwirtschaft_XP_ZweckbestimmungWasserwirtschaft1"
    FOREIGN KEY ("zweckbestimmung" )
    REFERENCES "XP_Enumerationen"."XP_ZweckbestimmungWasserwirtschaft" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT "fk_FP_Wasserwirtschaft_FP_DetailZweckbestWasserwirtschaft1"
    FOREIGN KEY ("detaillierteZweckbestimmung" )
    REFERENCES "FP_Wasser"."FP_DetailZweckbestWasserwirtschaft" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT "fk_FP_Wasserwirtschaft_FP_Objekt1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Basisobjekte"."FP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE);

CREATE INDEX "idx_fk_FP_Wasserwirtschaft_XP_ZweckbestimmungWasserwirtschaft1" ON "FP_Wasser"."FP_Wasserwirtschaft" ("zweckbestimmung") ;
CREATE INDEX "idx_fk_FP_Wasserwirtschaft_FP_DetailZweckbestWasserwirtschaft1" ON "FP_Wasser"."FP_Wasserwirtschaft" ("detaillierteZweckbestimmung") ;
GRANT SELECT ON TABLE "FP_Wasser"."FP_Wasserwirtschaft" TO xp_gast;
GRANT ALL ON TABLE "FP_Wasser"."FP_Wasserwirtschaft" TO fp_user;
COMMENT ON TABLE  "FP_Wasser"."FP_Wasserwirtschaft" IS 'Darstellung von Wasserflächen nach §5, Abs. 2, Nr. 7 BauGB.';
COMMENT ON COLUMN  "FP_Wasser"."FP_Wasserwirtschaft"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN  "FP_Wasser"."FP_Wasserwirtschaft"."zweckbestimmung" IS 'Zweckbestimmung des Gewässers.';
COMMENT ON COLUMN  "FP_Wasser"."FP_Wasserwirtschaft"."detaillierteZweckbestimmung" IS 'Über eine CodeList definierte zusätzliche Zweckbestimmung des Objektes.';
CREATE TRIGGER "change_to_FP_Wasserwirtschaft" BEFORE INSERT OR UPDATE OR DELETE ON "FP_Wasser"."FP_Wasserwirtschaft" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "FP_Wasser"."FP_GewaesserFlaeche"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Wasser"."FP_GewaesserFlaeche" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_GewaesserFlaeche_FP_Gewaesser1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Wasser"."FP_Gewaesser" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("FP_Basisobjekte"."FP_Flaechenobjekt");

GRANT SELECT ON TABLE "FP_Wasser"."FP_GewaesserFlaeche" TO xp_gast;
GRANT ALL ON TABLE "FP_Wasser"."FP_GewaesserFlaeche" TO fp_user;
CREATE TRIGGER "change_to_FP_GewaesserFlaeche" BEFORE INSERT OR UPDATE OR DELETE ON "FP_Wasser"."FP_GewaesserFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "FP_GewaesserFlaeche_Flaechenobjekt" BEFORE INSERT OR UPDATE ON "FP_Wasser"."FP_GewaesserFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isFlaechenobjekt"();
SELECT "XP_Basisobjekte".registergeometrycolumn('','FP_Wasser','FP_GewaesserFlaeche', 'position','MULTIPOLYGON',2);

-- -----------------------------------------------------
-- Table "FP_Wasser"."FP_GewaesserLinie"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Wasser"."FP_GewaesserLinie" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_GewaesserLinie_FP_Gewaesser1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Wasser"."FP_Gewaesser" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("FP_Basisobjekte"."FP_Linienobjekt");

GRANT SELECT ON TABLE "FP_Wasser"."FP_GewaesserLinie" TO xp_gast;
GRANT ALL ON TABLE "FP_Wasser"."FP_GewaesserLinie" TO fp_user;
CREATE TRIGGER "change_to_FP_GewaesserLinie" BEFORE INSERT OR UPDATE OR DELETE ON "FP_Wasser"."FP_GewaesserLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
SELECT "XP_Basisobjekte".registergeometrycolumn('','FP_Wasser','FP_GewaesserLinie', 'position','MULTILINESTRING',2);

-- -----------------------------------------------------
-- Table "FP_Wasser"."FP_GewaesserPunkt"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Wasser"."FP_GewaesserPunkt" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_GewaesserPunkt_FP_Gewaesser1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Wasser"."FP_Gewaesser" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("FP_Basisobjekte"."FP_Punktobjekt");

GRANT SELECT ON TABLE "FP_Wasser"."FP_GewaesserPunkt" TO xp_gast;
GRANT ALL ON TABLE "FP_Wasser"."FP_GewaesserPunkt" TO fp_user;
CREATE TRIGGER "change_to_FP_GewaesserPunkt" BEFORE INSERT OR UPDATE OR DELETE ON "FP_Wasser"."FP_GewaesserPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
SELECT "XP_Basisobjekte".registergeometrycolumn('','FP_Wasser','FP_GewaesserPunkt', 'position','MULTIPOINT',2);

-- -----------------------------------------------------
-- Table "FP_Wasser"."FP_WasserwirtschaftFlaeche"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Wasser"."FP_WasserwirtschaftFlaeche" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_WasserwirtschaftFlaeche_FP_Wasserwirtschaft1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Wasser"."FP_Wasserwirtschaft" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("FP_Basisobjekte"."FP_Flaechenobjekt");

GRANT SELECT ON TABLE "FP_Wasser"."FP_WasserwirtschaftFlaeche" TO xp_gast;
GRANT ALL ON TABLE "FP_Wasser"."FP_WasserwirtschaftFlaeche" TO fp_user;
CREATE TRIGGER "change_to_FP_WasserwirtschaftFlaeche" BEFORE INSERT OR UPDATE OR DELETE ON "FP_Wasser"."FP_WasserwirtschaftFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "FP_WasserwirtschaftFlaeche_Flaechenobjekt" BEFORE INSERT OR UPDATE ON "FP_Wasser"."FP_WasserwirtschaftFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isFlaechenobjekt"();
SELECT "XP_Basisobjekte".registergeometrycolumn('','FP_Wasser','FP_WasserwirtschaftFlaeche', 'position','MULTIPOLYGON',2);

-- -----------------------------------------------------
-- Table "FP_Wasser"."FP_WasserwirtschaftLinie"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Wasser"."FP_WasserwirtschaftLinie" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_WasserwirtschaftLinie_FP_Wasserwirtschaft1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Wasser"."FP_Wasserwirtschaft" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("FP_Basisobjekte"."FP_Linienobjekt");

GRANT SELECT ON TABLE "FP_Wasser"."FP_WasserwirtschaftLinie" TO xp_gast;
GRANT ALL ON TABLE "FP_Wasser"."FP_WasserwirtschaftLinie" TO fp_user;
CREATE TRIGGER "change_to_FP_WasserwirtschaftLinie" BEFORE INSERT OR UPDATE OR DELETE ON "FP_Wasser"."FP_WasserwirtschaftLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
SELECT "XP_Basisobjekte".registergeometrycolumn('','FP_Wasser','FP_WasserwirtschaftLinie', 'position','MULTILINESTRING',2);

-- -----------------------------------------------------
-- Table "FP_Wasser"."FP_WasserwirtschaftPunkt"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Wasser"."FP_WasserwirtschaftPunkt" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_WasserwirtschaftPunkt_FP_Wasserwirtschaft1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Wasser"."FP_Wasserwirtschaft" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("FP_Basisobjekte"."FP_Punktobjekt");

GRANT SELECT ON TABLE "FP_Wasser"."FP_WasserwirtschaftPunkt" TO xp_gast;
GRANT ALL ON TABLE "FP_Wasser"."FP_WasserwirtschaftPunkt" TO fp_user;
CREATE TRIGGER "change_to_FP_WasserwirtschaftPunkt" BEFORE INSERT OR UPDATE OR DELETE ON "FP_Wasser"."FP_WasserwirtschaftPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
SELECT "XP_Basisobjekte".registergeometrycolumn('','FP_Wasser','FP_WasserwirtschaftPunkt', 'position','MULTIPOINT',2);

-- -----------------------------------------------------
-- Table "FP_Aufschuettung_Abgrabung"."FP_Aufschuettung"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Aufschuettung_Abgrabung"."FP_Aufschuettung" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_Aufschuettung_FP_Objekt"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Basisobjekte"."FP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("FP_Basisobjekte"."FP_Flaechenobjekt");

GRANT SELECT ON TABLE "FP_Aufschuettung_Abgrabung"."FP_Aufschuettung" TO xp_gast;
GRANT ALL ON TABLE "FP_Aufschuettung_Abgrabung"."FP_Aufschuettung" TO fp_user;
COMMENT ON TABLE  "FP_Aufschuettung_Abgrabung"."FP_Aufschuettung" IS 'Flächen für Aufschüttungen, Abgrabungen oder für die Gewinnung von Bodenschätzen (§5, Abs. 2, Nr. 8 BauGB). Hier: Flächen für Aufschüttungen.';
COMMENT ON COLUMN  "FP_Aufschuettung_Abgrabung"."FP_Aufschuettung"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_FP_Aufschuettung" BEFORE INSERT OR UPDATE OR DELETE ON "FP_Aufschuettung_Abgrabung"."FP_Aufschuettung" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "FP_Aufschuettung_Flaechenobjekt" BEFORE INSERT OR UPDATE ON "FP_Aufschuettung_Abgrabung"."FP_Aufschuettung" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isFlaechenobjekt"();
SELECT "XP_Basisobjekte".registergeometrycolumn('','FP_Aufschuettung_Abgrabung','FP_Aufschuettung', 'position','MULTIPOLYGON',2);

-- -----------------------------------------------------
-- Table "FP_Aufschuettung_Abgrabung"."FP_Abgrabung"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Aufschuettung_Abgrabung"."FP_Abgrabung" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_Abgrabung_FP_Objekt0"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Basisobjekte"."FP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("FP_Basisobjekte"."FP_Flaechenobjekt");

GRANT SELECT ON TABLE "FP_Aufschuettung_Abgrabung"."FP_Abgrabung" TO xp_gast;
GRANT ALL ON TABLE "FP_Aufschuettung_Abgrabung"."FP_Abgrabung" TO fp_user;
COMMENT ON TABLE  "FP_Aufschuettung_Abgrabung"."FP_Abgrabung" IS 'Flächen für Aufschüttungen, Abgrabungen oder für die Gewinnung von Bodenschätzen (§5, Abs. 2, Nr. 8 BauGB). Hier: Flächen für Abgrabungen';
COMMENT ON COLUMN  "FP_Aufschuettung_Abgrabung"."FP_Abgrabung"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_FP_Abgrabung" BEFORE INSERT OR UPDATE OR DELETE ON "FP_Aufschuettung_Abgrabung"."FP_Abgrabung" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "FP_Abgrabung_Flaechenobjekt" BEFORE INSERT OR UPDATE ON "FP_Aufschuettung_Abgrabung"."FP_Abgrabung" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isFlaechenobjekt"();
SELECT "XP_Basisobjekte".registergeometrycolumn('','FP_Aufschuettung_Abgrabung','FP_Abgrabung', 'position','MULTIPOLYGON',2);

-- -----------------------------------------------------
-- Table "FP_Aufschuettung_Abgrabung"."FP_Bodenschaetze"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Aufschuettung_Abgrabung"."FP_Bodenschaetze" (
  "gid" BIGINT NOT NULL ,
  "abbaugut" VARCHAR(255) NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_FP_Bodenschaetze_FP_Objekt1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Basisobjekte"."FP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("FP_Basisobjekte"."FP_Flaechenobjekt");

GRANT SELECT ON TABLE "FP_Aufschuettung_Abgrabung"."FP_Bodenschaetze" TO xp_gast;
GRANT ALL ON TABLE "FP_Aufschuettung_Abgrabung"."FP_Bodenschaetze" TO fp_user;
COMMENT ON TABLE  "FP_Aufschuettung_Abgrabung"."FP_Bodenschaetze" IS 'Flächen für Aufschüttungen, Abgrabungen oder für die Gewinnung von Bodenschätzen (§5, Abs. 2, Nr. 8 BauGB. Hier: Flächen für Bodenschätze.';
COMMENT ON COLUMN  "FP_Aufschuettung_Abgrabung"."FP_Bodenschaetze"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN  "FP_Aufschuettung_Abgrabung"."FP_Bodenschaetze"."abbaugut" IS 'Bezeichnung des Abbauguts.';
CREATE TRIGGER "change_to_FP_Bodenschaetze" BEFORE INSERT OR UPDATE OR DELETE ON "FP_Aufschuettung_Abgrabung"."FP_Bodenschaetze" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "FP_Bodenschaetze_Flaechenobjekt" BEFORE INSERT OR UPDATE ON "FP_Aufschuettung_Abgrabung"."FP_Bodenschaetze" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isFlaechenobjekt"();
SELECT "XP_Basisobjekte".registergeometrycolumn('','FP_Aufschuettung_Abgrabung','FP_Bodenschaetze', 'position','MULTIPOLYGON',2);

-- *****************************************************
-- CREATE VIEWs
-- *****************************************************

-- -----------------------------------------------------
-- View "FP_Basisobjekte"."FP_Punktobjekte"
-- -----------------------------------------------------
CREATE  OR REPLACE VIEW "FP_Basisobjekte"."FP_Punktobjekte" AS
SELECT g.*, CAST(c.relname as varchar) as "Objektart",
CAST(n.nspname as varchar) as "Objektartengruppe"
FROM  "FP_Basisobjekte"."FP_Punktobjekt" g
JOIN pg_class c ON g.tableoid = c.oid
JOIN pg_namespace n ON c.relnamespace = n.oid;

GRANT SELECT ON TABLE "FP_Basisobjekte"."FP_Punktobjekte" TO xp_gast;
GRANT ALL ON TABLE "FP_Basisobjekte"."FP_Punktobjekte" TO fp_user;

SELECT "XP_Basisobjekte".registergeometrycolumn('','FP_Basisobjekte','FP_Punktobjekte', 'position','MULTIPOINT',2);

CREATE OR REPLACE RULE _update AS
    ON UPDATE TO "FP_Basisobjekte"."FP_Punktobjekte" DO INSTEAD  UPDATE "FP_Basisobjekte"."FP_Punktobjekt" SET "position" = new."position"
  WHERE gid = old.gid;
CREATE OR REPLACE RULE _delete AS
    ON DELETE TO "FP_Basisobjekte"."FP_Punktobjekte" DO INSTEAD  DELETE FROM "FP_Basisobjekte"."FP_Punktobjekt"
  WHERE gid = old.gid;

-- -----------------------------------------------------
-- View "FP_Basisobjekte"."FP_Linienobjekte"
-- -----------------------------------------------------
CREATE  OR REPLACE VIEW "FP_Basisobjekte"."FP_Linienobjekte" AS
SELECT g.*, CAST(c.relname as varchar) as "Objektart",
CAST(n.nspname as varchar) as "Objektartengruppe"
FROM  "FP_Basisobjekte"."FP_Linienobjekt" g
JOIN pg_class c ON g.tableoid = c.oid
JOIN pg_namespace n ON c.relnamespace = n.oid;

GRANT SELECT ON TABLE "FP_Basisobjekte"."FP_Linienobjekte" TO xp_gast;
GRANT ALL ON TABLE "FP_Basisobjekte"."FP_Linienobjekte" TO fp_user;

SELECT "XP_Basisobjekte".registergeometrycolumn('','FP_Basisobjekte','FP_Linienobjekte', 'position','MULTILINESTRING',2);

CREATE OR REPLACE RULE _update AS
    ON UPDATE TO "FP_Basisobjekte"."FP_Linienobjekte" DO INSTEAD  UPDATE "FP_Basisobjekte"."FP_Linienobjekt" SET "position" = new."position"
  WHERE gid = old.gid;
CREATE OR REPLACE RULE _delete AS
    ON DELETE TO "FP_Basisobjekte"."FP_Linienobjekte" DO INSTEAD  DELETE FROM "FP_Basisobjekte"."FP_Linienobjekt"
  WHERE gid = old.gid;
  
-- -----------------------------------------------------
-- View "FP_Basisobjekte"."FP_Flaechenobjekte"
-- -----------------------------------------------------
CREATE  OR REPLACE VIEW "FP_Basisobjekte"."FP_Flaechenobjekte" AS
SELECT g.*, CAST(c.relname as varchar) as "Objektart",
CAST(n.nspname as varchar) as "Objektartengruppe"
FROM  "FP_Basisobjekte"."FP_Flaechenobjekt" g
JOIN pg_class c ON g.tableoid = c.oid
JOIN pg_namespace n ON c.relnamespace = n.oid;

GRANT SELECT ON TABLE "FP_Basisobjekte"."FP_Flaechenobjekte" TO xp_gast;
GRANT ALL ON TABLE "FP_Basisobjekte"."FP_Flaechenobjekte" TO fp_user;

SELECT "XP_Basisobjekte".registergeometrycolumn('','FP_Basisobjekte','FP_Flaechenobjekte', 'position','MULTIPOLYGON',2);

CREATE OR REPLACE RULE _update AS
    ON UPDATE TO "FP_Basisobjekte"."FP_Flaechenobjekte" DO INSTEAD  UPDATE "FP_Basisobjekte"."FP_Flaechenobjekt" SET "position" = new."position"
  WHERE gid = old.gid;
CREATE OR REPLACE RULE _delete AS
    ON DELETE TO "FP_Basisobjekte"."FP_Flaechenobjekte" DO INSTEAD  DELETE FROM "FP_Basisobjekte"."FP_Flaechenobjekt"
  WHERE gid = old.gid;

-- -----------------------------------------------------
-- View "FP_Basisobjekte"."FP_Objekte"
-- -----------------------------------------------------
CREATE OR REPLACE VIEW "FP_Basisobjekte"."FP_Objekte" AS 
 SELECT fp_o.gid, g."FP_Bereich_gid", fp_o."Objektart", fp_o."Objektartengruppe"
 FROM 
  ( SELECT o.gid, c.relname::character varying AS "Objektart", n.nspname::character varying AS "Objektartengruppe"
         FROM (        (         SELECT p.gid, p.tableoid
                                 FROM "FP_Basisobjekte"."FP_Punktobjekt" p
                      UNION 
                               SELECT "FP_Linienobjekt".gid, "FP_Linienobjekt".tableoid
                                 FROM "FP_Basisobjekte"."FP_Linienobjekt")
              UNION 
                       SELECT "FP_Flaechenobjekt".gid, "FP_Flaechenobjekt".tableoid
                         FROM "FP_Basisobjekte"."FP_Flaechenobjekt") o
    JOIN pg_class c ON o.tableoid = c.oid
    JOIN pg_namespace n ON c.relnamespace = n.oid) fp_o
    left join "FP_Basisobjekte"."gehoertZuFP_Bereich" g ON fp_o.gid = g."FP_Objekt_gid";
GRANT SELECT ON TABLE "FP_Basisobjekte"."FP_Objekte" TO xp_gast;

-- *****************************************************
-- DATA
-- *****************************************************

-- -----------------------------------------------------
-- Data for table "FP_Basisobjekte"."FP_Verfahren"
-- -----------------------------------------------------
INSERT INTO "FP_Basisobjekte"."FP_Verfahren" ("Code", "Bezeichner") VALUES ('1000', 'Normal');
INSERT INTO "FP_Basisobjekte"."FP_Verfahren" ("Code", "Bezeichner") VALUES ('2000', 'Parag13');

-- -----------------------------------------------------
-- Data for table "FP_Basisobjekte"."FP_Rechtsstand"
-- -----------------------------------------------------
INSERT INTO "FP_Basisobjekte"."FP_Rechtsstand" ("Code", "Bezeichner") VALUES ('1000', 'Aufstellungsbeschluss');
INSERT INTO "FP_Basisobjekte"."FP_Rechtsstand" ("Code", "Bezeichner") VALUES ('2000', 'Entwurf');
INSERT INTO "FP_Basisobjekte"."FP_Rechtsstand" ("Code", "Bezeichner") VALUES ('2100', 'FruehzeitigeBehoerdenBeteiligung');
INSERT INTO "FP_Basisobjekte"."FP_Rechtsstand" ("Code", "Bezeichner") VALUES ('2200', 'FruehzeitigeOeffentlichkeitsBeteiligung');
INSERT INTO "FP_Basisobjekte"."FP_Rechtsstand" ("Code", "Bezeichner") VALUES ('2300', 'BehoerdenBeteiligung');
INSERT INTO "FP_Basisobjekte"."FP_Rechtsstand" ("Code", "Bezeichner") VALUES ('2400', 'OeffentlicheAuslegung');
INSERT INTO "FP_Basisobjekte"."FP_Rechtsstand" ("Code", "Bezeichner") VALUES ('3000', 'Plan');
INSERT INTO "FP_Basisobjekte"."FP_Rechtsstand" ("Code", "Bezeichner") VALUES ('4000', 'Wirksamkeit');
INSERT INTO "FP_Basisobjekte"."FP_Rechtsstand" ("Code", "Bezeichner") VALUES ('5000', 'Untergegangen');

-- -----------------------------------------------------
-- Data for table "FP_Basisobjekte"."FP_PlanArt"
-- -----------------------------------------------------
INSERT INTO "FP_Basisobjekte"."FP_PlanArt" ("Code", "Bezeichner") VALUES ('1000', 'FPlan');
INSERT INTO "FP_Basisobjekte"."FP_PlanArt" ("Code", "Bezeichner") VALUES ('2000', 'GemeinsamerFPlan');
INSERT INTO "FP_Basisobjekte"."FP_PlanArt" ("Code", "Bezeichner") VALUES ('3000', 'RegFPlan');
INSERT INTO "FP_Basisobjekte"."FP_PlanArt" ("Code", "Bezeichner") VALUES ('4000', 'FPlanRegPlan');
INSERT INTO "FP_Basisobjekte"."FP_PlanArt" ("Code", "Bezeichner") VALUES ('5000', 'SachlicherTeilplan');
INSERT INTO "FP_Basisobjekte"."FP_PlanArt" ("Code", "Bezeichner") VALUES ('9999', 'Sonstiges');

-- -----------------------------------------------------
-- Data for table "FP_Basisobjekte"."FP_Rechtscharakter"
-- -----------------------------------------------------
INSERT INTO "FP_Basisobjekte"."FP_Rechtscharakter" ("Code", "Bezeichner") VALUES ('1000', 'Darstellung');
INSERT INTO "FP_Basisobjekte"."FP_Rechtscharakter" ("Code", "Bezeichner") VALUES ('3000', 'Hinweis');
INSERT INTO "FP_Basisobjekte"."FP_Rechtscharakter" ("Code", "Bezeichner") VALUES ('4000', 'Vermerk');
INSERT INTO "FP_Basisobjekte"."FP_Rechtscharakter" ("Code", "Bezeichner") VALUES ('5000', 'Kennzeichnung');

-- -----------------------------------------------------
-- Data for table "FP_Sonstiges"."FP_ZweckbestimmungPrivilegiertesVorhaben"
-- -----------------------------------------------------
INSERT INTO "FP_Sonstiges"."FP_ZweckbestimmungPrivilegiertesVorhaben" ("Code", "Bezeichner") VALUES ('1000', 'LandForstwirtschaft');
INSERT INTO "FP_Sonstiges"."FP_ZweckbestimmungPrivilegiertesVorhaben" ("Code", "Bezeichner") VALUES ('1200', 'OeffentlicheVersorgung');
INSERT INTO "FP_Sonstiges"."FP_ZweckbestimmungPrivilegiertesVorhaben" ("Code", "Bezeichner") VALUES ('1400', 'OrtsgebundenerGewerbebetrieb');
INSERT INTO "FP_Sonstiges"."FP_ZweckbestimmungPrivilegiertesVorhaben" ("Code", "Bezeichner") VALUES ('1600', 'BesonderesVorhaben');
INSERT INTO "FP_Sonstiges"."FP_ZweckbestimmungPrivilegiertesVorhaben" ("Code", "Bezeichner") VALUES ('1800', 'ErneuerbareEnergie');
INSERT INTO "FP_Sonstiges"."FP_ZweckbestimmungPrivilegiertesVorhaben" ("Code", "Bezeichner") VALUES ('2000', 'Kernenergie');
INSERT INTO "FP_Sonstiges"."FP_ZweckbestimmungPrivilegiertesVorhaben" ("Code", "Bezeichner") VALUES ('9999', 'Sonstiges');

-- -----------------------------------------------------
-- Data for table "FP_Sonstiges"."FP_BesondZweckbestPrivilegiertesVorhaben"
-- -----------------------------------------------------
INSERT INTO "FP_Sonstiges"."FP_BesondZweckbestPrivilegiertesVorhaben" ("Code", "Bezeichner") VALUES ('10000', 'Aussiedlerhof');
INSERT INTO "FP_Sonstiges"."FP_BesondZweckbestPrivilegiertesVorhaben" ("Code", "Bezeichner") VALUES ('10001', 'Altenteil');
INSERT INTO "FP_Sonstiges"."FP_BesondZweckbestPrivilegiertesVorhaben" ("Code", "Bezeichner") VALUES ('10002', 'Reiterhof');
INSERT INTO "FP_Sonstiges"."FP_BesondZweckbestPrivilegiertesVorhaben" ("Code", "Bezeichner") VALUES ('10003', 'Gartenbaubetrieb');
INSERT INTO "FP_Sonstiges"."FP_BesondZweckbestPrivilegiertesVorhaben" ("Code", "Bezeichner") VALUES ('10004', 'Baumschule');
INSERT INTO "FP_Sonstiges"."FP_BesondZweckbestPrivilegiertesVorhaben" ("Code", "Bezeichner") VALUES ('12000', 'Wasser');
INSERT INTO "FP_Sonstiges"."FP_BesondZweckbestPrivilegiertesVorhaben" ("Code", "Bezeichner") VALUES ('12001', 'Gas');
INSERT INTO "FP_Sonstiges"."FP_BesondZweckbestPrivilegiertesVorhaben" ("Code", "Bezeichner") VALUES ('12002', 'Waerme');
INSERT INTO "FP_Sonstiges"."FP_BesondZweckbestPrivilegiertesVorhaben" ("Code", "Bezeichner") VALUES ('12003', 'Elektrizitaet');
INSERT INTO "FP_Sonstiges"."FP_BesondZweckbestPrivilegiertesVorhaben" ("Code", "Bezeichner") VALUES ('12004', 'Telekommunikation');
INSERT INTO "FP_Sonstiges"."FP_BesondZweckbestPrivilegiertesVorhaben" ("Code", "Bezeichner") VALUES ('12005', 'Abwasser');
INSERT INTO "FP_Sonstiges"."FP_BesondZweckbestPrivilegiertesVorhaben" ("Code", "Bezeichner") VALUES ('16000', 'BesondereUmgebungsAnforderung');
INSERT INTO "FP_Sonstiges"."FP_BesondZweckbestPrivilegiertesVorhaben" ("Code", "Bezeichner") VALUES ('16001', 'NachteiligeUmgebungsWirkung');
INSERT INTO "FP_Sonstiges"."FP_BesondZweckbestPrivilegiertesVorhaben" ("Code", "Bezeichner") VALUES ('16002', 'BesondereZweckbestimmung');
INSERT INTO "FP_Sonstiges"."FP_BesondZweckbestPrivilegiertesVorhaben" ("Code", "Bezeichner") VALUES ('18000', 'Windenergie');
INSERT INTO "FP_Sonstiges"."FP_BesondZweckbestPrivilegiertesVorhaben" ("Code", "Bezeichner") VALUES ('18001', 'Wasserenergie');
INSERT INTO "FP_Sonstiges"."FP_BesondZweckbestPrivilegiertesVorhaben" ("Code", "Bezeichner") VALUES ('18002', 'Solarenergie');
INSERT INTO "FP_Sonstiges"."FP_BesondZweckbestPrivilegiertesVorhaben" ("Code", "Bezeichner") VALUES ('18003', 'Biomasse');
INSERT INTO "FP_Sonstiges"."FP_BesondZweckbestPrivilegiertesVorhaben" ("Code", "Bezeichner") VALUES ('20000', 'NutzungKernerergie');
INSERT INTO "FP_Sonstiges"."FP_BesondZweckbestPrivilegiertesVorhaben" ("Code", "Bezeichner") VALUES ('20001', 'EntsorgungRadioaktiveAbfaelle');
INSERT INTO "FP_Sonstiges"."FP_BesondZweckbestPrivilegiertesVorhaben" ("Code", "Bezeichner") VALUES ('99990', 'StandortEinzelhof');
INSERT INTO "FP_Sonstiges"."FP_BesondZweckbestPrivilegiertesVorhaben" ("Code", "Bezeichner") VALUES ('99991', 'BebauteFlaecheAussenbereich');

-- -----------------------------------------------------
-- Data for table "FP_Verkehr"."FP_ZweckbestimmungStrassenverkehr"
-- -----------------------------------------------------
INSERT INTO "FP_Verkehr"."FP_ZweckbestimmungStrassenverkehr" ("Code", "Bezeichner") VALUES ('1000', 'Autobahn');
INSERT INTO "FP_Verkehr"."FP_ZweckbestimmungStrassenverkehr" ("Code", "Bezeichner") VALUES ('1200', 'Hauptverkehrsstrasse');
INSERT INTO "FP_Verkehr"."FP_ZweckbestimmungStrassenverkehr" ("Code", "Bezeichner") VALUES ('1400', 'SonstigerVerkehrswegAnlage');
INSERT INTO "FP_Verkehr"."FP_ZweckbestimmungStrassenverkehr" ("Code", "Bezeichner") VALUES ('1600', 'RuhenderVerkehr');
INSERT INTO "FP_Verkehr"."FP_ZweckbestimmungStrassenverkehr" ("Code", "Bezeichner") VALUES ('9999', 'Sonstiges');

-- -----------------------------------------------------
-- Data for table "FP_Verkehr"."FP_BesondereZweckbestimmungStrassenverkehr"
-- -----------------------------------------------------
INSERT INTO "FP_Verkehr"."FP_BesondereZweckbestimmungStrassenverkehr" ("Code", "Bezeichner") VALUES ('14000', 'VerkehrsberuhigterBereich');
INSERT INTO "FP_Verkehr"."FP_BesondereZweckbestimmungStrassenverkehr" ("Code", "Bezeichner") VALUES ('14001', 'Platz');
INSERT INTO "FP_Verkehr"."FP_BesondereZweckbestimmungStrassenverkehr" ("Code", "Bezeichner") VALUES ('14002', 'Fussgaengerbereich');
INSERT INTO "FP_Verkehr"."FP_BesondereZweckbestimmungStrassenverkehr" ("Code", "Bezeichner") VALUES ('14003', 'RadFussweg');
INSERT INTO "FP_Verkehr"."FP_BesondereZweckbestimmungStrassenverkehr" ("Code", "Bezeichner") VALUES ('14004', 'Radweg');
INSERT INTO "FP_Verkehr"."FP_BesondereZweckbestimmungStrassenverkehr" ("Code", "Bezeichner") VALUES ('14005', 'Fussweg');
INSERT INTO "FP_Verkehr"."FP_BesondereZweckbestimmungStrassenverkehr" ("Code", "Bezeichner") VALUES ('14006', 'Wanderweg');
INSERT INTO "FP_Verkehr"."FP_BesondereZweckbestimmungStrassenverkehr" ("Code", "Bezeichner") VALUES ('14007', 'ReitKutschweg');
INSERT INTO "FP_Verkehr"."FP_BesondereZweckbestimmungStrassenverkehr" ("Code", "Bezeichner") VALUES ('14008', 'Rastanlage');
INSERT INTO "FP_Verkehr"."FP_BesondereZweckbestimmungStrassenverkehr" ("Code", "Bezeichner") VALUES ('14009', 'Busbahnhof');
INSERT INTO "FP_Verkehr"."FP_BesondereZweckbestimmungStrassenverkehr" ("Code", "Bezeichner") VALUES ('14010', 'UeberfuehrenderVerkehrsweg');
INSERT INTO "FP_Verkehr"."FP_BesondereZweckbestimmungStrassenverkehr" ("Code", "Bezeichner") VALUES ('14011', 'UnterfuehrenderVerkehrsweg');
