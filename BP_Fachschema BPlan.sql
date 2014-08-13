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
  NOSUPERUSER NOINHERIT NOCREATEDB NOCREATEROLE;
GRANT xp_gast TO bp_user;
GRANT xp_user TO bp_user;

-- *****************************************************
-- CREATE SCHEMAS
-- *****************************************************

CREATE SCHEMA "BP_Basisobjekte";
CREATE SCHEMA "BP_Bebauung";
CREATE SCHEMA "BP_Naturschutz";
CREATE SCHEMA "BP_Raster";

COMMENT ON SCHEMA "BP_Basisobjekte" IS 'Das Paket enthält die Klassen zur Modellierung eines BPlans (abgeleitet von XP_Plan) und eines BPlan-Bereichs (abgeleitet von XP_Bereich), sowie die Basisklassen für BPlan-Fachobjekte.';
COMMENT ON SCHEMA "BP_Bebauung" IS 'Festsetzungen über baulich genutzte Flächen';
COMMENT ON SCHEMA "BP_Naturschutz" IS 'BP_Naturschutz, Landschaftsbild, Naturhaushalt: Festsetzungen von Flächen und Maßnahmen zum Schutz, zur Pflege und zur Entwicklung von Natur und Landschaft (§9, Abs. 1, Nr. 20 BauGB).';
COMMENT ON SCHEMA "BP_Raster" IS 'Rasterdarstellung von Bebauungsplänen';

GRANT USAGE ON SCHEMA "BP_Basisobjekte" TO xp_gast;
GRANT USAGE ON SCHEMA "BP_Bebauung" TO xp_gast;
GRANT USAGE ON SCHEMA "BP_Naturschutz" TO xp_gast;
GRANT USAGE ON SCHEMA "BP_Raster" TO xp_gast;


-- *****************************************************
-- CREATE SEQUENCES
-- *****************************************************

CREATE SEQUENCE "BP_Basisobjekte"."BP_WirksamkeitBedingung_id_seq"
   MINVALUE 1;
GRANT ALL ON TABLE "BP_Basisobjekte"."BP_WirksamkeitBedingung_id_seq" TO GROUP bp_user;
CREATE SEQUENCE "BP_Bebauung"."BP_GestaltungBaugebiet_id_seq"
   MINVALUE 1;
GRANT ALL ON TABLE "BP_Bebauung"."BP_GestaltungBaugebiet_id_seq" TO GROUP bp_user;
CREATE SEQUENCE "BP_Bebauung"."BP_FestsetzungenBaugebiet_id_seq"
   MINVALUE 1;
GRANT ALL ON TABLE "BP_Bebauung"."BP_FestsetzungenBaugebiet_id_seq" TO GROUP bp_user;

-- *****************************************************
-- CREATE TRIGGER FUNCTIONs
-- *****************************************************

CREATE OR REPLACE FUNCTION "BP_Basisobjekte"."child_of_BP_Objekt"() 
RETURNS trigger AS
$BODY$ 
 BEGIN
    IF (TG_OP = 'INSERT') THEN
        IF new.gid IS NULL THEN
            new.gid := nextval('"XP_Basisobjekte"."XP_Objekt_gid_seq"');
        END IF;
        
        INSERT INTO "BP_Basisobjekte"."BP_Objekt"(gid) VALUES (new.gid);
        RETURN new;
    ELSIF (TG_OP = 'UPDATE') THEN
        new.gid := old.gid; --no change in gid allowed
        RETURN new;
    ELSIF (TG_OP = 'DELETE') THEN
        DELETE FROM "BP_Basisobjekte"."BP_Objekt" WHERE gid = old.gid;
        RETURN old;
    END IF;
 END; $BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
GRANT EXECUTE ON FUNCTION "BP_Basisobjekte"."child_of_BP_Objekt"() TO bp_user;

CREATE OR REPLACE FUNCTION "BP_Naturschutz"."child_of_BP_AnpflanzungBindungErhaltung"() 
RETURNS trigger AS
$BODY$ 
 BEGIN
    IF (TG_OP = 'INSERT') THEN
        IF new.gid IS NULL THEN
            new.gid := nextval('"XP_Basisobjekte"."XP_Objekt_gid_seq"');
        END IF;
        
        INSERT INTO "BP_Naturschutz"."BP_AnpflanzungBindungErhaltung" (gid) VALUES (new.gid);
        RETURN new;
    ELSIF (TG_OP = 'UPDATE') THEN
        new.gid := old.gid; --no change in gid allowed
        RETURN new;
    ELSIF (TG_OP = 'DELETE') THEN
        DELETE FROM "BP_Naturschutz"."BP_AnpflanzungBindungErhaltung" WHERE gid = old.gid;
        RETURN old;
    END IF;
 END; $BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
GRANT EXECUTE ON FUNCTION "BP_Naturschutz"."child_of_BP_AnpflanzungBindungErhaltung"() TO bp_user;

CREATE OR REPLACE FUNCTION "BP_Naturschutz"."child_of_BP_Schutzgebiet"() 
RETURNS trigger AS
$BODY$ 
 BEGIN
    IF (TG_OP = 'INSERT') THEN
        IF new.gid IS NULL THEN
            new.gid := nextval('"XP_Basisobjekte"."XP_Objekt_gid_seq"');
        END IF;
        
        INSERT INTO "BP_Naturschutz"."BP_Schutzgebiet" (gid) VALUES (new.gid);
        RETURN new;
    ELSIF (TG_OP = 'UPDATE') THEN
        new.gid := old.gid; --no change in gid allowed
        RETURN new;
    ELSIF (TG_OP = 'DELETE') THEN
        DELETE FROM "BP_Naturschutz"."BP_Schutzgebiet" WHERE gid = old.gid;
        RETURN old;
    END IF;
 END; $BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
GRANT EXECUTE ON FUNCTION "BP_Naturschutz"."child_of_BP_Schutzgebiet"() TO bp_user;

CREATE OR REPLACE FUNCTION "BP_Naturschutz"."child_of_BP_AusgleichsMassnahme"() 
RETURNS trigger AS
$BODY$ 
 BEGIN
    IF (TG_OP = 'INSERT') THEN
        IF new.gid IS NULL THEN
            new.gid := nextval('"XP_Basisobjekte"."XP_Objekt_gid_seq"');
        END IF;
        
        INSERT INTO "BP_Naturschutz"."BP_AusgleichsMassnahme" (gid) VALUES (new.gid);
        RETURN new;
    ELSIF (TG_OP = 'UPDATE') THEN
        new.gid := old.gid; --no change in gid allowed
        RETURN new;
    ELSIF (TG_OP = 'DELETE') THEN
        DELETE FROM "BP_Naturschutz"."BP_AusgleichsMassnahme" WHERE gid = old.gid;
        RETURN old;
    END IF;
 END; $BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
GRANT EXECUTE ON FUNCTION "BP_Naturschutz"."child_of_BP_AusgleichsMassnahme"() TO bp_user; 

CREATE OR REPLACE FUNCTION "BP_Naturschutz"."child_of_BP_SchutzPflegeEntwicklungsMassnahme"() 
RETURNS trigger AS
$BODY$ 
 BEGIN
    IF (TG_OP = 'INSERT') THEN
        IF new.gid IS NULL THEN
            new.gid := nextval('"XP_Basisobjekte"."XP_Objekt_gid_seq"');
        END IF;
        
        INSERT INTO "BP_Naturschutz"."BP_SchutzPflegeEntwicklungsMassnahme" (gid) VALUES (new.gid);
        RETURN new;
    ELSIF (TG_OP = 'UPDATE') THEN
        new.gid := old.gid; --no change in gid allowed
        RETURN new;
    ELSIF (TG_OP = 'DELETE') THEN
        DELETE FROM "BP_Naturschutz"."BP_SchutzPflegeEntwicklungsMassnahme" WHERE gid = old.gid;
        RETURN old;
    END IF;
 END; $BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
GRANT EXECUTE ON FUNCTION "BP_Naturschutz"."child_of_BP_SchutzPflegeEntwicklungsMassnahme"() TO bp_user; 

-- *****************************************************
-- CREATE TABLEs 
-- *****************************************************

-- -----------------------------------------------------
-- Table "BP_Basisobjekte"."BP_SonstPlanArt"
-- -----------------------------------------------------
CREATE  TABLE  "BP_Basisobjekte"."BP_SonstPlanArt" (
  "Wert" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(255) NOT NULL ,
  PRIMARY KEY ("Wert") );
GRANT SELECT ON "BP_Basisobjekte"."BP_SonstPlanArt" TO xp_gast;
GRANT ALL ON "BP_Basisobjekte"."BP_SonstPlanArt" TO bp_user;

-- -----------------------------------------------------
-- Table "BP_Basisobjekte"."BP_Verfahren"
-- -----------------------------------------------------
CREATE  TABLE  "BP_Basisobjekte"."BP_Verfahren" (
  "Wert" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(255) NOT NULL ,
  PRIMARY KEY ("Wert") );
GRANT SELECT ON "BP_Basisobjekte"."BP_Verfahren" TO xp_gast;

-- -----------------------------------------------------
-- Table "BP_Basisobjekte"."BP_Status"
-- -----------------------------------------------------
CREATE  TABLE  "BP_Basisobjekte"."BP_Status" (
  "Wert" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(255) NOT NULL ,
  PRIMARY KEY ("Wert") );
GRANT SELECT ON "BP_Basisobjekte"."BP_Status" TO xp_gast;
GRANT ALL ON "BP_Basisobjekte"."BP_Status" TO bp_user;

-- -----------------------------------------------------
-- Table "BP_Basisobjekte"."BP_Rechtsstand"
-- -----------------------------------------------------
CREATE  TABLE  "BP_Basisobjekte"."BP_Rechtsstand" (
  "Wert" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(255) NOT NULL ,
  PRIMARY KEY ("Wert") );
GRANT SELECT ON "BP_Basisobjekte"."BP_Rechtsstand" TO xp_gast;

-- -----------------------------------------------------
-- Table "BP_Basisobjekte"."BP_Plan"
-- -----------------------------------------------------
CREATE  TABLE  "BP_Basisobjekte"."BP_Plan" (
  "gid" BIGINT NOT NULL ,
  "raeumlicherGeltungsbereich" GEOMETRY NULL ,
  "plangeber" INTEGER NULL ,
  "sonstPlanArt" INTEGER NULL ,
  "verfahren" INTEGER NULL ,
  "rechtsstand" INTEGER NULL ,
  "status" INTEGER NULL ,
  "hoehenbezug" VARCHAR(255) NULL ,
  "aenderungenBisDatum" DATE NULL ,
  "aufstellungsbechlussDatum" DATE NULL ,
  "veraenderungssperreDatum" DATE NULL ,
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
    REFERENCES "BP_Basisobjekte"."BP_SonstPlanArt" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_bp_plan_bp_verfahren1"
    FOREIGN KEY ("verfahren" )
    REFERENCES "BP_Basisobjekte"."BP_Verfahren" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_bp_plan_bp_status1"
    FOREIGN KEY ("status" )
    REFERENCES "BP_Basisobjekte"."BP_Status" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_bp_plan_bp_rechtsstand1"
    FOREIGN KEY ("rechtsstand" )
    REFERENCES "BP_Basisobjekte"."BP_Rechtsstand" ("Wert" )
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
    ON UPDATE CASCADE);
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
CREATE INDEX "idx_fk_bp_plan_xp_externereferenz4" ON "BP_Basisobjekte"."BP_Plan" ("refSatzung") ;
CREATE INDEX "idx_fk_bp_plan_xp_externereferenz4" ON "BP_Basisobjekte"."BP_Plan" ("refGruenordnungsplan") ;
CREATE INDEX "idx_fk_BP_Plan_XP_Plan1" ON "BP_Basisobjekte"."BP_Plan" ("gid") ;
COMMENT ON TABLE  "BP_Basisobjekte"."BP_Plan" IS 'Die Klasse modelliert einen Bebauungsplan';
COMMENT ON COLUMN  "BP_Basisobjekte"."BP_Plan"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN  "BP_Basisobjekte"."BP_Plan"."plangeber" IS 'Für den BPlan verantwortliche Stelle.';
COMMENT ON COLUMN  "BP_Basisobjekte"."BP_Plan"."sonstPlanArt" IS 'Spezifikation einer "Sonstigen Planart", wenn kein Plantyp aus der Enumeration BP_PlanArt zutraffend ist.';
COMMENT ON COLUMN  "BP_Basisobjekte"."BP_Plan"."verfahren" IS 'Verfahrensart der BPlan-Aufstellung oder -Änderung.';
COMMENT ON COLUMN  "BP_Basisobjekte"."BP_Plan"."rechtsstand" IS 'Aktueller Rechtsstand des Plans';
COMMENT ON COLUMN  "BP_Basisobjekte"."BP_Plan"."status" IS 'Über eine CodeList definieter aktueller Status des Plans.';
COMMENT ON COLUMN  "BP_Basisobjekte"."BP_Plan"."hoehenbezug" IS 'Bei Höhenangaben im Plan standardmäßig verwendeter Höhenbezug (z.B. Höhe über NN).';
COMMENT ON COLUMN  "BP_Basisobjekte"."BP_Plan"."aenderungenBisDatum" IS 'Datum der berücksichtigten Plan-Änderungen.';
COMMENT ON COLUMN  "BP_Basisobjekte"."BP_Plan"."aufstellungsbechlussDatum" IS 'Datum des Aufstellungsbeschlusses.';
COMMENT ON COLUMN  "BP_Basisobjekte"."BP_Plan"."veraenderungssperreDatum" IS 'Datum der Veränderungssperre';
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
CREATE TRIGGER "change_to_BP_Plan" BEFORE INSERT OR UPDATE OR DELETE ON "BP_Basisobjekte"."BP_Plan" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Plan"(); 

-- -----------------------------------------------------
-- Table "BP_Basisobjekte"."BP_PlanArt"
-- -----------------------------------------------------
CREATE  TABLE  "BP_Basisobjekte"."BP_PlanArt" (
  "Wert" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(255) NOT NULL ,
  PRIMARY KEY ("Wert") );
GRANT SELECT ON "BP_Basisobjekte"."BP_PlanArt" TO xp_gast;

-- -----------------------------------------------------
-- Table "BP_Basisobjekte"."planArt"
-- -----------------------------------------------------
CREATE  TABLE  "BP_Basisobjekte"."planArt" (
  "BP_Plan_gid" BIGINT NOT NULL ,
  "BP_Planart_Wert" INTEGER NOT NULL ,
  PRIMARY KEY ("BP_Plan_gid", "BP_Planart_Wert") ,
  CONSTRAINT "fk_planArt_BP_Plan"
    FOREIGN KEY ("BP_Plan_gid" )
    REFERENCES "BP_Basisobjekte"."BP_Plan" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_planArt_BP_PlanArt"
    FOREIGN KEY ("BP_Planart_Wert" )
    REFERENCES "BP_Basisobjekte"."BP_PlanArt" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
GRANT SELECT ON "BP_Basisobjekte"."planArt" TO xp_gast;
GRANT ALL ON "BP_Basisobjekte"."planArt" TO bp_user;
COMMENT ON TABLE  "BP_Basisobjekte"."planArt" IS 'Typ des vorliegenden BPlans.';
CREATE INDEX "idx_fk_planArt_BP_Plan" ON "BP_Basisobjekte"."planArt" ("BP_Plan_gid") ;
CREATE INDEX "idx_fk_planArt_BP_PlanArt" ON "BP_Basisobjekte"."planArt" ("BP_Planart_Wert") ;

-- -----------------------------------------------------
-- Table "BP_Basisobjekte"."auslegungsStartDatum"
-- -----------------------------------------------------
CREATE  TABLE  "BP_Basisobjekte"."auslegungsStartDatum" (
  "auslegungsStartDatum" DATE NOT NULL ,
  "BP_Plan_gid" BIGINT NOT NULL ,
  PRIMARY KEY ("auslegungsStartDatum", "BP_Plan_gid") ,
  CONSTRAINT "fk_auslegungsstartdatum_bp_plan1"
    FOREIGN KEY ("BP_Plan_gid" )
    REFERENCES "BP_Basisobjekte"."BP_Plan" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE);
GRANT SELECT ON "BP_Basisobjekte"."auslegungsStartDatum" TO xp_gast;
GRANT ALL ON "BP_Basisobjekte"."auslegungsStartDatum" TO bp_user;
COMMENT ON TABLE  "BP_Basisobjekte"."auslegungsStartDatum" IS 'Start-Datum des Auslegungs-Zeitraums. Bei mehrfacher öffentlicher Auslegung können mehrere Datumsangeben spezifiziert werden.';  
CREATE INDEX "idx_fk_auslegungsstartdatum_bp_plan1" ON "BP_Basisobjekte"."auslegungsStartDatum" ("BP_Plan_gid") ;

-- -----------------------------------------------------
-- Table "BP_Basisobjekte"."auslegungsEndDatum"
-- -----------------------------------------------------
CREATE  TABLE  "BP_Basisobjekte"."auslegungsEndDatum" (
  "auslegungsEndDatum" DATE NOT NULL ,
  "BP_Plan_gid" BIGINT NOT NULL ,
  PRIMARY KEY ("auslegungsEndDatum", "BP_Plan_gid") ,
  CONSTRAINT "fk_auslegungsenddatum_bp_plan1"
    FOREIGN KEY ("BP_Plan_gid" )
    REFERENCES "BP_Basisobjekte"."BP_Plan" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE);
GRANT SELECT ON "BP_Basisobjekte"."auslegungsEndDatum" TO xp_gast;
GRANT ALL ON "BP_Basisobjekte"."auslegungsEndDatum" TO bp_user;
COMMENT ON TABLE  "BP_Basisobjekte"."auslegungsEndDatum" IS 'End-Datum des Auslegungs-Zeitraums. Bei mehrfacher öffentlicher Auslegung können mehrere Datumsangeben spezifiziert werden.';
CREATE INDEX "idx_fk_auslegungsenddatum_bp_plan1" ON "BP_Basisobjekte"."auslegungsEndDatum" ("BP_Plan_gid") ;

-- -----------------------------------------------------
-- Table "BP_Basisobjekte"."traegerbeteiligungsStartDatum"
-- -----------------------------------------------------
CREATE  TABLE  "BP_Basisobjekte"."traegerbeteiligungsStartDatum" (
  "traegerbeteiligungsStartDatum" DATE NOT NULL ,
  "BP_Plan_gid" BIGINT NOT NULL ,
  PRIMARY KEY ("traegerbeteiligungsStartDatum", "BP_Plan_gid") ,
  CONSTRAINT "fk_traegerbeteiligungsstartdatum_bp_plan1"
    FOREIGN KEY ("BP_Plan_gid" )
    REFERENCES "BP_Basisobjekte"."BP_Plan" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE);
GRANT SELECT ON "BP_Basisobjekte"."traegerbeteiligungsStartDatum" TO xp_gast;
GRANT ALL ON "BP_Basisobjekte"."traegerbeteiligungsStartDatum" TO bp_user;
COMMENT ON TABLE  "BP_Basisobjekte"."traegerbeteiligungsStartDatum" IS 'Start-Datum der Trägerbeteiligung. Bei mehrfacher Trägerbeteiligung können mehrere Datumsangeben spezifiziert werden.';
CREATE INDEX "idx_fk_traegerbeteiligungsstartdatum_bp_plan1" ON "BP_Basisobjekte"."traegerbeteiligungsStartDatum" ("BP_Plan_gid") ;

-- -----------------------------------------------------
-- Table "BP_Basisobjekte"."traegerbeteiligungsEndDatum"
-- -----------------------------------------------------
CREATE  TABLE  "BP_Basisobjekte"."traegerbeteiligungsEndDatum" (
  "traegerbeteiligungsEndDatum" DATE NOT NULL ,
  "BP_Plan_gid" BIGINT NOT NULL ,
  PRIMARY KEY ("traegerbeteiligungsEndDatum", "BP_Plan_gid") ,
  CONSTRAINT "fk_traegerbeteiligungsenddatum_bp_plan1"
    FOREIGN KEY ("BP_Plan_gid" )
    REFERENCES "BP_Basisobjekte"."BP_Plan" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE);
GRANT SELECT ON "BP_Basisobjekte"."traegerbeteiligungsEndDatum" TO xp_gast;
GRANT ALL ON "BP_Basisobjekte"."traegerbeteiligungsEndDatum" TO bp_user;
COMMENT ON TABLE  "BP_Basisobjekte"."traegerbeteiligungsEndDatum" IS 'End-Datum der Trägerbeteiligung. Bei mehrfacher Trägerbeteiligung können mehrere Datumsangeben spezifiziert werden.';
CREATE INDEX "idx_fk_traegerbeteiligungsenddatum_bp_plan1" ON "BP_Basisobjekte"."traegerbeteiligungsEndDatum" ("BP_Plan_gid") ;

-- -----------------------------------------------------
-- Table "BP_Basisobjekte"."BP_Bereich"
-- -----------------------------------------------------
CREATE  TABLE  "BP_Basisobjekte"."BP_Bereich" (
  "gid" BIGINT NOT NULL ,
  "geltungsbereich" GEOMETRY NULL ,
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
    REFERENCES "XP_Enumerationen"."XP_VersionBauNVO" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_BP_Bereich_XP_Bereich1"
    FOREIGN KEY ("gid" )
    REFERENCES "XP_Basisobjekte"."XP_Bereich" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE);
GRANT SELECT ON "BP_Basisobjekte"."BP_Bereich" TO xp_gast;
GRANT ALL ON "BP_Basisobjekte"."BP_Bereich" TO bp_user;
COMMENT ON TABLE  "BP_Basisobjekte"."BP_Bereich" IS 'Diese Klasse modelliert einen Bereich eines Bebauungsplans, z.B. eine vertikale Ebene.';
COMMENT ON COLUMN  "BP_Basisobjekte"."BP_Bereich"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN  "BP_Basisobjekte"."BP_Bereich"."versionBauNVO" IS 'Benutzte Version der BauNVO';
COMMENT ON COLUMN  "BP_Basisobjekte"."BP_Bereich"."versionBauNVOText" IS 'Textliche Spezifikation einer anderen Gesetzesgrundlage als der BauNVO. In diesem Fall muss das Attribut versionBauNVO den Wert 9999 haben.';
COMMENT ON COLUMN  "BP_Basisobjekte"."BP_Bereich"."versionBauGB" IS 'Datum der zugrunde liegenden Version des BauGB.';
COMMENT ON COLUMN  "BP_Basisobjekte"."BP_Bereich"."versionBauGBText" IS 'Zugrunde liegende Version des BauGB.';
CREATE INDEX "idx_fk_BP_Bereich_BP_Plan1" ON "BP_Basisobjekte"."BP_Bereich" ("gehoertZuPlan") ;
CREATE INDEX "idx_fk_BP_Bereich_XP_VersionBauNVO1" ON "BP_Basisobjekte"."BP_Bereich" ("versionBauNVO") ;
CREATE INDEX "idx_fk_BP_Bereich_XP_Bereich1" ON "BP_Basisobjekte"."BP_Bereich" ("gid") ;
CREATE INDEX "idx_fk_BP_Bereich_XP_Bereich2" ON "BP_Basisobjekte"."BP_Bereich" ("gid") ;
CREATE TRIGGER "change_to_BP_Bereich" BEFORE INSERT OR UPDATE OR DELETE ON "BP_Basisobjekte"."BP_Bereich" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Bereich"(); 

-- -----------------------------------------------------
-- Table "BP_Basisobjekte"."BP_Rechtscharakter"
-- -----------------------------------------------------
CREATE  TABLE  "BP_Basisobjekte"."BP_Rechtscharakter" (
  "Wert" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Wert") );
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
    REFERENCES "BP_Basisobjekte"."BP_Rechtscharakter" ("Wert" )
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
CREATE TRIGGER "change_to_BP_Objekt" BEFORE INSERT OR UPDATE OR DELETE ON "BP_Basisobjekte"."BP_Objekt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"(); 

-- -----------------------------------------------------
-- Table "BP_Basisobjekte"."gehoertZuBP_Bereich"
-- -----------------------------------------------------
CREATE  TABLE  "BP_Basisobjekte"."gehoertZuBP_Bereich" (
  "BP_Bereich_gid" BIGINT NOT NULL ,
  "BP_Objekt_gid" BIGINT NOT NULL ,
  PRIMARY KEY ("BP_Bereich_gid", "BP_Objekt_gid") ,
  CONSTRAINT "fk_gehoertzubp_bereich_bp_bereich1"
    FOREIGN KEY ("BP_Bereich_gid" )
    REFERENCES "BP_Basisobjekte"."BP_Bereich" ("gid" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_gehoertZuBP_Bereich_BP_Objekt1"
    FOREIGN KEY ("BP_Objekt_gid" )
    REFERENCES "BP_Basisobjekte"."BP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE);
GRANT SELECT ON "BP_Basisobjekte"."BP_Objekt" TO xp_gast;
GRANT ALL ON "BP_Basisobjekte"."BP_Objekt" TO bp_user;
COMMENT ON TABLE  "BP_Basisobjekte"."gehoertZuBP_Bereich" IS 'Die Relation zeigt an, dass das BPlan-Fachobjekt vom referierten Planbereich als originärer Planinhalt referiert wird.';
CREATE INDEX "idx_fk_gehoertzubp_bereich_bp_bereich1" ON "BP_Basisobjekte"."gehoertZuBP_Bereich" ("BP_Bereich_gid") ;
CREATE INDEX "idx_fk_gehoertZuBP_Bereich_BP_Objekt1" ON "BP_Basisobjekte"."gehoertZuBP_Bereich" ("BP_Objekt_gid") ;

-- -----------------------------------------------------
-- Table "BP_Basisobjekte"."gemeinde"
-- -----------------------------------------------------
CREATE  TABLE  "BP_Basisobjekte"."gemeinde" (
  "BP_Plan_gid" BIGINT NOT NULL ,
  "XP_Gemeinde_id" INTEGER NOT NULL ,
  PRIMARY KEY ("BP_Plan_gid", "XP_Gemeinde_id") ,
  CONSTRAINT "fk_gemeinde_BP_Plan1"
    FOREIGN KEY ("BP_Plan_gid" )
    REFERENCES "BP_Basisobjekte"."BP_Plan" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_gemeinde_XP_Gemeinde1"
    FOREIGN KEY ("XP_Gemeinde_id" )
    REFERENCES "XP_Sonstiges"."XP_Gemeinde" ("id" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
GRANT SELECT ON "BP_Basisobjekte"."gemeinde" TO xp_gast;
GRANT ALL ON "BP_Basisobjekte"."gemeinde" TO bp_user;
COMMENT ON TABLE  "BP_Basisobjekte"."gemeinde" IS 'Die für den Plan zuständige Gemeinde.';
CREATE INDEX "idx_fk_gemeinde_BP_Plan1" ON "BP_Basisobjekte"."gemeinde" ("BP_Plan_gid") ;
CREATE INDEX "idx_fk_gemeinde_XP_Gemeinde1" ON "BP_Basisobjekte"."gemeinde" ("XP_Gemeinde_id") ;

-- -----------------------------------------------------
-- Table "BP_Raster"."BP_RasterplanAenderung"
-- -----------------------------------------------------
CREATE  TABLE  "BP_Raster"."BP_RasterplanAenderung" (
  "gid" BIGINT NOT NULL ,
  "geltungsbereichAenderung" GEOMETRY NULL ,
  "aufstellungsbeschlussDatum" DATE NULL ,
  "veraenderungssperreDatum" DATE NULL ,
  "satzungsbeschlussDatum" DATE NULL ,
  "rechtsverordnungsDatum" DATE NULL ,
  "inkrafttretensDatum" DATE NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_BP_RasterplanAenderung1"
    FOREIGN KEY ("gid" )
    REFERENCES "XP_Raster"."XP_RasterplanAenderung" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE);
GRANT SELECT ON "BP_Raster"."BP_RasterplanAenderung" TO xp_gast;
GRANT ALL ON "BP_Raster"."BP_RasterplanAenderung" TO bp_user;
COMMENT ON TABLE  "BP_Raster"."BP_RasterplanAenderung" IS 'Georeferenziertes Rasterbild der Änderung eines Basisplans. Die abgeleitete Klasse besitzt Datums-Attribute, die spezifisch für Bebauungspläne sind.';
COMMENT ON COLUMN  "BP_Raster"."BP_RasterplanAenderung"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN  "BP_Raster"."BP_RasterplanAenderung"."aufstellungsbeschlussDatum" IS 'Datum des Aufstellungsbeschlusses';
COMMENT ON COLUMN  "BP_Raster"."BP_RasterplanAenderung"."veraenderungssperreDatum" IS 'Datum einer Veränderungssperre';
COMMENT ON COLUMN  "BP_Raster"."BP_RasterplanAenderung"."satzungsbeschlussDatum" IS 'Datum des Satzungsbeschlusses der Änderung.';
COMMENT ON COLUMN  "BP_Raster"."BP_RasterplanAenderung"."rechtsverordnungsDatum" IS 'Datum der Rechtsverordnung';
COMMENT ON COLUMN  "BP_Raster"."BP_RasterplanAenderung"."inkrafttretensDatum" IS 'Datum des Inkrafttretens der Änderung';
CREATE INDEX "idx_fk_BP_RasterplanAenderung1" ON "BP_Raster"."BP_RasterplanAenderung" ("gid") ;
CREATE TRIGGER "change_to_BP_RasterplanAenderung" BEFORE INSERT OR UPDATE OR DELETE ON "BP_Raster"."BP_RasterplanAenderung" FOR EACH ROW EXECUTE PROCEDURE "XP_Raster"."child_of_XP_RasterplanAenderung"();

-- -----------------------------------------------------
-- Table "BP_Raster"."auslegungsStartDatum"
-- -----------------------------------------------------
CREATE  TABLE  "BP_Raster"."auslegungsStartDatum" (
  "BP_RasterplanAenderung_id" INTEGER NOT NULL ,
  "auslegungsStartDatum" DATE NOT NULL ,
  PRIMARY KEY ("BP_RasterplanAenderung_id", "auslegungsStartDatum") ,
  CONSTRAINT "fk_auslegungsStartDatum_BP_RasterplanAenderung"
    FOREIGN KEY ("BP_RasterplanAenderung_id" )
    REFERENCES "BP_Raster"."BP_RasterplanAenderung" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE);
GRANT SELECT ON "BP_Raster"."auslegungsStartDatum" TO xp_gast;
GRANT ALL ON "BP_Raster"."auslegungsStartDatum" TO bp_user;
COMMENT ON TABLE "BP_Raster"."auslegungsStartDatum" IS 'Start-Datum der öffentlichen Auslegung.';
CREATE INDEX "idx_fk_auslegungsStartDatum1" ON "BP_Raster"."auslegungsStartDatum" ("BP_RasterplanAenderung_id") ;


-- -----------------------------------------------------
-- Table "BP_Raster"."auslegungsEndDatum"
-- -----------------------------------------------------
CREATE  TABLE  "BP_Raster"."auslegungsEndDatum" (
  "auslegungsEndDatum" DATE NOT NULL ,
  "BP_RasterplanAenderung_id" INTEGER NOT NULL ,
  PRIMARY KEY ("auslegungsEndDatum", "BP_RasterplanAenderung_id") ,
  CONSTRAINT "fk_auslegungsEndDatum1"
    FOREIGN KEY ("BP_RasterplanAenderung_id" )
    REFERENCES "BP_Raster"."BP_RasterplanAenderung" ("gid" )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION);
GRANT SELECT ON "BP_Raster"."auslegungsEndDatum" TO xp_gast;
GRANT ALL ON "BP_Raster"."auslegungsEndDatum" TO bp_user;
COMMENT ON TABLE "BP_Raster"."auslegungsEndDatum" IS 'End-Datum der öffentlichen Auslegung.';
CREATE INDEX "idx_fk_auslegungsEndDatum1" ON "BP_Raster"."auslegungsEndDatum" ("BP_RasterplanAenderung_id") ;

-- -----------------------------------------------------
-- Table "BP_Raster"."traegerbeteiligungsStartDatum"
-- -----------------------------------------------------
CREATE  TABLE  "BP_Raster"."traegerbeteiligungsStartDatum" (
  "traegerbeteiligungsStartDatum" DATE NOT NULL ,
  "BP_RasterplanAenderung_id" INTEGER NOT NULL ,
  PRIMARY KEY ("traegerbeteiligungsStartDatum", "BP_RasterplanAenderung_id") ,
  CONSTRAINT "fk_traegerbeteiligungsStartDatum1"
    FOREIGN KEY ("BP_RasterplanAenderung_id" )
    REFERENCES "BP_Raster"."BP_RasterplanAenderung" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE);
GRANT SELECT ON "BP_Raster"."traegerbeteiligungsStartDatum" TO xp_gast;
GRANT ALL ON "BP_Raster"."traegerbeteiligungsStartDatum" TO bp_user;
COMMENT ON TABLE "BP_Raster"."traegerbeteiligungsStartDatum" IS 'Start-Datum der Trägerbeteiligung.';
CREATE INDEX "idx_fk_traegerbeteiligungsStartDatum1" ON "BP_Raster"."traegerbeteiligungsStartDatum" ("BP_RasterplanAenderung_id") ;

-- -----------------------------------------------------
-- Table "BP_Raster"."traegerbeteiligungsEndDatum"
-- -----------------------------------------------------
CREATE  TABLE  "BP_Raster"."traegerbeteiligungsEndDatum" (
  "traegerbeteiligungsEndDatum" DATE NOT NULL ,
  "BP_RasterplanAenderung_id" INTEGER NOT NULL ,
  PRIMARY KEY ("traegerbeteiligungsEndDatum", "BP_RasterplanAenderung_id") ,
  CONSTRAINT "fk_traegerbeteiligungsEndDatum1"
    FOREIGN KEY ("BP_RasterplanAenderung_id" )
    REFERENCES "BP_Raster"."BP_RasterplanAenderung" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE);
GRANT SELECT ON "BP_Raster"."traegerbeteiligungsEndDatum" TO xp_gast;
GRANT ALL ON "BP_Raster"."traegerbeteiligungsEndDatum" TO bp_user;
COMMENT ON TABLE "BP_Raster"."traegerbeteiligungsEndDatum" IS 'End-Datum der Trägerbeteiligung.';
CREATE INDEX "idx_fk_traegerbeteiligungsEndDatum1" ON "BP_Raster"."traegerbeteiligungsEndDatum" ("BP_RasterplanAenderung_id") ;

-- *****************************************************
-- INSERT DATA
-- *****************************************************

-- -----------------------------------------------------
-- PostGIS für instantiierbare Objekte
-- -----------------------------------------------------

SELECT "XP_Basisobjekte".registergeometrycolumn('','BP_Basisobjekte','BP_Plan', 'raeumlicherGeltungsbereich','MULTIPOLYGON',2);
SELECT "XP_Basisobjekte".registergeometrycolumn('','BP_Raster','BP_RasterplanAenderung', 'geltungsbereichAenderung','MULTIPOLYGON',2);
SELECT "XP_Basisobjekte".registergeometrycolumn('','BP_Basisobjekte','BP_Bereich', 'geltungsbereich','MULTIPOLYGON',2);

-- -----------------------------------------------------
-- Data for table "BP_Basisobjekte"."BP_Verfahren"
-- -----------------------------------------------------
INSERT INTO "BP_Basisobjekte"."BP_Verfahren" ("Wert", "Bezeichner") VALUES ('1000', 'Normal');
INSERT INTO "BP_Basisobjekte"."BP_Verfahren" ("Wert", "Bezeichner") VALUES ('2000', 'Parag13');
INSERT INTO "BP_Basisobjekte"."BP_Verfahren" ("Wert", "Bezeichner") VALUES ('3000', 'Parag13a');

-- -----------------------------------------------------
-- Data for table "BP_Basisobjekte"."BP_Rechtsstand"
-- -----------------------------------------------------
INSERT INTO "BP_Basisobjekte"."BP_Rechtsstand" ("Wert", "Bezeichner") VALUES ('1000', 'Aufstellungsbeschluss');
INSERT INTO "BP_Basisobjekte"."BP_Rechtsstand" ("Wert", "Bezeichner") VALUES ('2000', 'Entwurf');
INSERT INTO "BP_Basisobjekte"."BP_Rechtsstand" ("Wert", "Bezeichner") VALUES ('2100', 'FruehzeitigeBehoerdenBeteiligung');
INSERT INTO "BP_Basisobjekte"."BP_Rechtsstand" ("Wert", "Bezeichner") VALUES ('2200', 'FruehzeitigeOeffentlichkeitsBeteiligung');
INSERT INTO "BP_Basisobjekte"."BP_Rechtsstand" ("Wert", "Bezeichner") VALUES ('2300', 'BehoerdenBeteiligung');
INSERT INTO "BP_Basisobjekte"."BP_Rechtsstand" ("Wert", "Bezeichner") VALUES ('2400', 'OeffentlicheAuslegung');
INSERT INTO "BP_Basisobjekte"."BP_Rechtsstand" ("Wert", "Bezeichner") VALUES ('3000', 'Satzung');
INSERT INTO "BP_Basisobjekte"."BP_Rechtsstand" ("Wert", "Bezeichner") VALUES ('4000', 'InkraftGetreten');
INSERT INTO "BP_Basisobjekte"."BP_Rechtsstand" ("Wert", "Bezeichner") VALUES ('4500', 'TeilweiseUntergegangen');
INSERT INTO "BP_Basisobjekte"."BP_Rechtsstand" ("Wert", "Bezeichner") VALUES ('5000', 'Untergegangen');

-- -----------------------------------------------------
-- Data for table "BP_Basisobjekte"."BP_PlanArt"
-- -----------------------------------------------------
INSERT INTO "BP_Basisobjekte"."BP_PlanArt" ("Wert", "Bezeichner") VALUES ('1000', 'BPlan');
INSERT INTO "BP_Basisobjekte"."BP_PlanArt" ("Wert", "Bezeichner") VALUES ('10000', 'EinfacherBPlan');
INSERT INTO "BP_Basisobjekte"."BP_PlanArt" ("Wert", "Bezeichner") VALUES ('10001', 'QualifizierterBPlan');
INSERT INTO "BP_Basisobjekte"."BP_PlanArt" ("Wert", "Bezeichner") VALUES ('3000', 'VorhabenbezogenerBPlan');
INSERT INTO "BP_Basisobjekte"."BP_PlanArt" ("Wert", "Bezeichner") VALUES ('4000', 'InnenbereichsSatzung');
INSERT INTO "BP_Basisobjekte"."BP_PlanArt" ("Wert", "Bezeichner") VALUES ('40000', 'KlarstellungsSatzung');
INSERT INTO "BP_Basisobjekte"."BP_PlanArt" ("Wert", "Bezeichner") VALUES ('40001', 'EntwicklungsSatzung');
INSERT INTO "BP_Basisobjekte"."BP_PlanArt" ("Wert", "Bezeichner") VALUES ('40002', 'ErgaenzungsSatzung');
INSERT INTO "BP_Basisobjekte"."BP_PlanArt" ("Wert", "Bezeichner") VALUES ('5000', 'AussenbereichsSatzung');
INSERT INTO "BP_Basisobjekte"."BP_PlanArt" ("Wert", "Bezeichner") VALUES ('7000', 'OertlicheBauvorschrift');
INSERT INTO "BP_Basisobjekte"."BP_PlanArt" ("Wert", "Bezeichner") VALUES ('9999', 'Sonstiges');

-- -----------------------------------------------------
-- Data for table "BP_Basisobjekte"."BP_Rechtscharakter"
-- -----------------------------------------------------
INSERT INTO "BP_Basisobjekte"."BP_Rechtscharakter" ("Wert", "Bezeichner") VALUES ('1000', 'Festsetzung');
INSERT INTO "BP_Basisobjekte"."BP_Rechtscharakter" ("Wert", "Bezeichner") VALUES ('3000', 'Hinweis');
INSERT INTO "BP_Basisobjekte"."BP_Rechtscharakter" ("Wert", "Bezeichner") VALUES ('4000', 'Vermerk');
INSERT INTO "BP_Basisobjekte"."BP_Rechtscharakter" ("Wert", "Bezeichner") VALUES ('5000', 'Kennzeichnung');
