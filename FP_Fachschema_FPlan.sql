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
CREATE SCHEMA "FP_Basisobjekte";
CREATE SCHEMA "FP_Basisobjekte";
CREATE SCHEMA "FP_Basisobjekte";
CREATE SCHEMA "FP_Basisobjekte";
CREATE SCHEMA "FP_Basisobjekte";
CREATE SCHEMA "FP_Basisobjekte";
CREATE SCHEMA "FP_Basisobjekte";


COMMENT ON SCHEMA "FP_Basisobjekte" IS 'Das Paket enthält die Klassen zur Modellierung eines FPlans (abgeleitet von XP_Plan) und eines FPlan-Bereichs (abgeleitet von XP_Bereich), sowie die Basisklassen für FPlan-Fachobjekte.'
COMMENT ON SCHEMA "FP_Basisobjekte" IS 'Das Paket enthält die Klassen zur Modellierung eines FPlans (abgeleitet von XP_Plan) und eines FPlan-Bereichs (abgeleitet von XP_Bereich), sowie die Basisklassen für FPlan-Fachobjekte.'
COMMENT ON SCHEMA "FP_Basisobjekte" IS 'Das Paket enthält die Klassen zur Modellierung eines FPlans (abgeleitet von XP_Plan) und eines FPlan-Bereichs (abgeleitet von XP_Bereich), sowie die Basisklassen für FPlan-Fachobjekte.'
COMMENT ON SCHEMA "FP_Basisobjekte" IS 'Das Paket enthält die Klassen zur Modellierung eines FPlans (abgeleitet von XP_Plan) und eines FPlan-Bereichs (abgeleitet von XP_Bereich), sowie die Basisklassen für FPlan-Fachobjekte.'
COMMENT ON SCHEMA "FP_Basisobjekte" IS 'Das Paket enthält die Klassen zur Modellierung eines FPlans (abgeleitet von XP_Plan) und eines FPlan-Bereichs (abgeleitet von XP_Bereich), sowie die Basisklassen für FPlan-Fachobjekte.'
COMMENT ON SCHEMA "FP_Basisobjekte" IS 'Das Paket enthält die Klassen zur Modellierung eines FPlans (abgeleitet von XP_Plan) und eines FPlan-Bereichs (abgeleitet von XP_Bereich), sowie die Basisklassen für FPlan-Fachobjekte.'
COMMENT ON SCHEMA "FP_Basisobjekte" IS 'Das Paket enthält die Klassen zur Modellierung eines FPlans (abgeleitet von XP_Plan) und eines FPlan-Bereichs (abgeleitet von XP_Bereich), sowie die Basisklassen für FPlan-Fachobjekte.'
COMMENT ON SCHEMA "FP_Basisobjekte" IS 'Das Paket enthält die Klassen zur Modellierung eines FPlans (abgeleitet von XP_Plan) und eines FPlan-Bereichs (abgeleitet von XP_Bereich), sowie die Basisklassen für FPlan-Fachobjekte.'

GRANT USAGE ON SCHEMA "FP_Basisobjekte" TO xp_gast;
GRANT USAGE ON SCHEMA "FP_Basisobjekte" TO xp_gast;
GRANT USAGE ON SCHEMA "FP_Basisobjekte" TO xp_gast;
GRANT USAGE ON SCHEMA "FP_Basisobjekte" TO xp_gast;
GRANT USAGE ON SCHEMA "FP_Basisobjekte" TO xp_gast;
GRANT USAGE ON SCHEMA "FP_Basisobjekte" TO xp_gast;
GRANT USAGE ON SCHEMA "FP_Basisobjekte" TO xp_gast;
GRANT USAGE ON SCHEMA "FP_Basisobjekte" TO xp_gast;
GRANT USAGE ON SCHEMA "FP_Basisobjekte" TO xp_gast;

-- *****************************************************
-- CREATE TRIGGER FUNCTIONs
-- *****************************************************

CREATE OR REPLACE FUNCTION "FP_Basisobjekte"."child_of_FP_Objekt"() 
RETURNS trigger AS
$BODY$ 
 BEGIN
    IF (TG_OP = 'INSERT') THEN
        IF new.gid IS NULL THEN
            new.gid := nextval('"XP_Basisobjekte"."XP_Objekt_gid_seq"');
        END IF;
        
        INSERT INTO "FP_Basisobjekte"."FP_Objekt"(gid) VALUES(new.gid);
        RETURN new;
    ELSIF (TG_OP = 'UPDATE') THEN
        new.gid := old.gid; --no change in gid allowed
        RETURN new;
    ELSIF (TG_OP = 'DELETE') THEN
        DELETE FROM "FP_Basisobjekte"."FP_Objekt" WHERE gid = old.gid;
        RETURN old;
    END IF;
 END; $BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
GRANT EXECUTE ON FUNCTION "FP_Basisobjekte"."child_of_FP_Objekt"() TO fp_user;

CREATE OR REPLACE FUNCTION "FP_Naturschutz"."child_of_FP_SchutzPflegeEntwicklung"() 
RETURNS trigger AS
$BODY$ 
 BEGIN
    IF (TG_OP = 'INSERT') THEN
        IF new.gid IS NULL THEN
            new.gid := nextval('"XP_Basisobjekte"."XP_Objekt_gid_seq"');
        END IF;
        
        INSERT INTO "FP_Naturschutz"."FP_SchutzPflegeEntwicklung"(gid) VALUES(new.gid);
        RETURN new;
    ELSIF (TG_OP = 'UPDATE') THEN
        new.gid := old.gid; --no change in gid allowed
        RETURN new;
    ELSIF (TG_OP = 'DELETE') THEN
        DELETE FROM "FP_Basisobjekte"."FP_Objekt" WHERE gid = old.gid;
        RETURN old;
    END IF;
 END; $BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
GRANT EXECUTE ON FUNCTION "FP_Naturschutz"."child_of_FP_SchutzPflegeEntwicklung"() TO fp_user;

CREATE OR REPLACE FUNCTION "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."child_of_FP_Gemeinbedarf"() 
RETURNS trigger AS
$BODY$ 
 BEGIN
    IF (TG_OP = 'INSERT') THEN
        IF new.gid IS NULL THEN
            new.gid := nextval('"XP_Basisobjekte"."XP_Objekt_gid_seq"');
        END IF;
        
        INSERT INTO "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_Gemeinbedarf"(gid) VALUES(new.gid);
        RETURN new;
    ELSIF (TG_OP = 'UPDATE') THEN
        new.gid := old.gid; --no change in gid allowed
        RETURN new;
    ELSIF (TG_OP = 'DELETE') THEN
        DELETE FROM "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_Gemeinbedarf" WHERE gid = old.gid;
        RETURN old;
    END IF;
 END; $BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
GRANT EXECUTE ON FUNCTION "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."child_of_FP_Gemeinbedarf"() TO fp_user;

CREATE OR REPLACE FUNCTION "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."child_of_FP_SpielSportanlage"() 
RETURNS trigger AS
$BODY$ 
 BEGIN
    IF (TG_OP = 'INSERT') THEN
        IF new.gid IS NULL THEN
            new.gid := nextval('"XP_Basisobjekte"."XP_Objekt_gid_seq"');
        END IF;
        
        INSERT INTO "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_SpielSportanlage"(gid) VALUES(new.gid);
        RETURN new;
    ELSIF (TG_OP = 'UPDATE') THEN
        new.gid := old.gid; --no change in gid allowed
        RETURN new;
    ELSIF (TG_OP = 'DELETE') THEN
        DELETE FROM "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_SpielSportanlage" WHERE gid = old.gid;
        RETURN old;
    END IF;
 END; $BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
GRANT EXECUTE ON FUNCTION "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."child_of_FP_SpielSportanlage"() TO fp_user;

CREATE OR REPLACE FUNCTION "FP_Landwirtschaft_Wald_und_Gruen"."child_of_FP_Gruen"() 
RETURNS trigger AS
$BODY$ 
 BEGIN
    IF (TG_OP = 'INSERT') THEN
        IF new.gid IS NULL THEN
            new.gid := nextval('"XP_Basisobjekte"."XP_Objekt_gid_seq"');
        END IF;
        
        INSERT INTO "FP_Landwirtschaft_Wald_und_Gruen"."FP_Gruen"(gid) VALUES(new.gid);
        RETURN new;
    ELSIF (TG_OP = 'UPDATE') THEN
        new.gid := old.gid; --no change in gid allowed
        RETURN new;
    ELSIF (TG_OP = 'DELETE') THEN
        DELETE FROM "FP_Landwirtschaft_Wald_und_Gruen"."FP_Gruen" WHERE gid = old.gid;
        RETURN old;
    END IF;
 END; $BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
GRANT EXECUTE ON FUNCTION "FP_Landwirtschaft_Wald_und_Gruen"."child_of_FP_Gruen"() TO fp_user;

CREATE OR REPLACE FUNCTION "FP_Sonstiges"."child_of_FP_GenerischesObjekt"() 
RETURNS trigger AS
$BODY$ 
 BEGIN
    IF (TG_OP = 'INSERT') THEN
        IF new.gid IS NULL THEN
            new.gid := nextval('"XP_Basisobjekte"."XP_Objekt_gid_seq"');
        END IF;
        
        INSERT INTO "FP_Sonstiges"."FP_GenerischesObjekt"(gid) VALUES(new.gid);
        RETURN new;
    ELSIF (TG_OP = 'UPDATE') THEN
        new.gid := old.gid; --no change in gid allowed
        RETURN new;
    ELSIF (TG_OP = 'DELETE') THEN
        DELETE FROM "FP_Sonstiges"."FP_GenerischesObjekt" WHERE gid = old.gid;
        RETURN old;
    END IF;
 END; $BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
GRANT EXECUTE ON FUNCTION "FP_Sonstiges"."child_of_FP_GenerischesObjekt"() TO fp_user;

CREATE OR REPLACE FUNCTION "FP_Sonstiges"."child_of_FP_Kennzeichnung"() 
RETURNS trigger AS
$BODY$ 
 BEGIN
    IF (TG_OP = 'INSERT') THEN
        IF new.gid IS NULL THEN
            new.gid := nextval('"XP_Basisobjekte"."XP_Objekt_gid_seq"');
        END IF;
        
        INSERT INTO "FP_Sonstiges"."FP_Kennzeichnung"(gid) VALUES(new.gid);
        RETURN new;
    ELSIF (TG_OP = 'UPDATE') THEN
        new.gid := old.gid; --no change in gid allowed
        RETURN new;
    ELSIF (TG_OP = 'DELETE') THEN
        DELETE FROM "FP_Sonstiges"."FP_Kennzeichnung" WHERE gid = old.gid;
        RETURN old;
    END IF;
 END; $BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
GRANT EXECUTE ON FUNCTION "FP_Sonstiges"."child_of_FP_Kennzeichnung"() TO fp_user;

CREATE OR REPLACE FUNCTION "FP_Sonstiges"."child_of_FP_PrivilegiertesVorhaben"() 
RETURNS trigger AS
$BODY$ 
 BEGIN
    IF (TG_OP = 'INSERT') THEN
        IF new.gid IS NULL THEN
            new.gid := nextval('"XP_Basisobjekte"."XP_Objekt_gid_seq"');
        END IF;
        
        INSERT INTO "FP_Sonstiges"."FP_PrivilegiertesVorhaben"(gid) VALUES(new.gid);
        RETURN new;
    ELSIF (TG_OP = 'UPDATE') THEN
        new.gid := old.gid; --no change in gid allowed
        RETURN new;
    ELSIF (TG_OP = 'DELETE') THEN
        DELETE FROM "FP_Sonstiges"."FP_PrivilegiertesVorhaben" WHERE gid = old.gid;
        RETURN old;
    END IF;
 END; $BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
GRANT EXECUTE ON FUNCTION "FP_Sonstiges"."child_of_FP_PrivilegiertesVorhaben"() TO fp_user;

CREATE OR REPLACE FUNCTION "FP_Sonstiges"."child_of_FP_UnverbindlicheVormerkung"() 
RETURNS trigger AS
$BODY$ 
 BEGIN
    IF (TG_OP = 'INSERT') THEN
        IF new.gid IS NULL THEN
            new.gid := nextval('"XP_Basisobjekte"."XP_Objekt_gid_seq"');
        END IF;
        
        INSERT INTO "FP_Sonstiges"."FP_UnverbindlicheVormerkung"(gid) VALUES(new.gid);
        RETURN new;
    ELSIF (TG_OP = 'UPDATE') THEN
        new.gid := old.gid; --no change in gid allowed
        RETURN new;
    ELSIF (TG_OP = 'DELETE') THEN
        DELETE FROM "FP_Sonstiges"."FP_UnverbindlicheVormerkung" WHERE gid = old.gid;
        RETURN old;
    END IF;
 END; $BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
GRANT EXECUTE ON FUNCTION "FP_Sonstiges"."child_of_FP_UnverbindlicheVormerkung"() TO fp_user;

CREATE OR REPLACE FUNCTION "FP_Ver_und_Entsorgung"."child_of_FP_VerEntsorgung"() 
RETURNS trigger AS
$BODY$ 
 BEGIN
    IF (TG_OP = 'INSERT') THEN
        IF new.gid IS NULL THEN
            new.gid := nextval('"XP_Basisobjekte"."XP_Objekt_gid_seq"');
        END IF;
        
        INSERT INTO "FP_Ver_und_Entsorgung"."FP_VerEntsorgung"(gid) VALUES(new.gid);
        RETURN new;
    ELSIF (TG_OP = 'UPDATE') THEN
        new.gid := old.gid; --no change in gid allowed
        RETURN new;
    ELSIF (TG_OP = 'DELETE') THEN
        DELETE FROM "FP_Ver_und_Entsorgung"."FP_VerEntsorgung" WHERE gid = old.gid;
        RETURN old;
    END IF;
 END; $BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
GRANT EXECUTE ON FUNCTION "FP_Ver_und_Entsorgung"."child_of_FP_VerEntsorgung"() TO fp_user;

CREATE OR REPLACE FUNCTION "FP_Verkehr"."child_of_FP_Strassenverkehr"() 
RETURNS trigger AS
$BODY$ 
 BEGIN
    IF (TG_OP = 'INSERT') THEN
        IF new.gid IS NULL THEN
            new.gid := nextval('"XP_Basisobjekte"."XP_Objekt_gid_seq"');
        END IF;
        
        INSERT INTO "FP_Verkehr"."FP_Strassenverkehr"(gid) VALUES(new.gid);
        RETURN new;
    ELSIF (TG_OP = 'UPDATE') THEN
        new.gid := old.gid; --no change in gid allowed
        RETURN new;
    ELSIF (TG_OP = 'DELETE') THEN
        DELETE FROM "FP_Verkehr"."FP_Strassenverkehr" WHERE gid = old.gid;
        RETURN old;
    END IF;
 END; $BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
GRANT EXECUTE ON FUNCTION "FP_Verkehr"."child_of_FP_Strassenverkehr"() TO fp_user;

CREATE OR REPLACE FUNCTION "FP_Wasser"."child_of_FP_Gewaesser"() 
RETURNS trigger AS
$BODY$ 
 BEGIN
    IF (TG_OP = 'INSERT') THEN
        IF new.gid IS NULL THEN
            new.gid := nextval('"XP_Basisobjekte"."XP_Objekt_gid_seq"');
        END IF;
        
        INSERT INTO "FP_Wasser"."FP_Gewaesser"(gid) VALUES(new.gid);
        RETURN new;
    ELSIF (TG_OP = 'UPDATE') THEN
        new.gid := old.gid; --no change in gid allowed
        RETURN new;
    ELSIF (TG_OP = 'DELETE') THEN
        DELETE FROM "FP_Wasser"."FP_Gewaesser" WHERE gid = old.gid;
        RETURN old;
    END IF;
 END; $BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
GRANT EXECUTE ON FUNCTION "FP_Wasser"."child_of_FP_Gewaesser"() TO fp_user;

CREATE OR REPLACE FUNCTION "FP_Wasser"."child_of_FP_Wasserwirtschaft"() 
RETURNS trigger AS
$BODY$ 
 BEGIN
    IF (TG_OP = 'INSERT') THEN
        IF new.gid IS NULL THEN
            new.gid := nextval('"XP_Basisobjekte"."XP_Objekt_gid_seq"');
        END IF;
        
        INSERT INTO "FP_Wasser"."FP_Wasserwirtschaft"(gid) VALUES(new.gid);
        RETURN new;
    ELSIF (TG_OP = 'UPDATE') THEN
        new.gid := old.gid; --no change in gid allowed
        RETURN new;
    ELSIF (TG_OP = 'DELETE') THEN
        DELETE FROM "FP_Wasser"."FP_Wasserwirtschaft" WHERE gid = old.gid;
        RETURN old;
    END IF;
 END; $BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
GRANT EXECUTE ON FUNCTION "FP_Wasser"."child_of_FP_Wasserwirtschaft"() TO fp_user;


-- *****************************************************
-- CREATE TABLEs 
-- *****************************************************

-- -----------------------------------------------------
-- Table "FP_Basisobjekte"."FP_SonstPlanArt"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Basisobjekte"."FP_SonstPlanArt" (
  "Wert" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Wert") );
GRANT SELECT ON TABLE "FP_Basisobjekte"."FP_SonstPlanArt" TO xp_gast;
GRANT ALL ON TABLE "FP_Basisobjekte"."FP_SonstPlanArt" TO fp_user;

-- -----------------------------------------------------
-- Table "FP_Basisobjekte"."FP_Verfahren"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Basisobjekte"."FP_Verfahren" (
  "Wert" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Wert") );
GRANT SELECT ON TABLE "FP_Basisobjekte"."FP_Verfahren" TO xp_gast;

-- -----------------------------------------------------
-- Table "FP_Basisobjekte"."FP_Status"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Basisobjekte"."FP_Status" (
  "Wert" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Wert") );
GRANT SELECT ON TABLE "FP_Basisobjekte"."FP_Status" TO xp_gast;
GRANT ALL ON TABLE "FP_Basisobjekte"."FP_Status" TO fp_user;

-- -----------------------------------------------------
-- Table "FP_Basisobjekte"."FP_Rechtsstand"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Basisobjekte"."FP_Rechtsstand" (
  "Wert" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Wert") );
GRANT SELECT ON TABLE "FP_Basisobjekte"."FP_Rechtsstand" TO xp_gast;

-- -----------------------------------------------------
-- Table "FP_Basisobjekte"."FP_PlanArt"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Basisobjekte"."FP_PlanArt" (
  "Wert" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Wert") );
GRANT SELECT ON TABLE "FP_Basisobjekte"."FP_PlanArt" TO xp_gast;

-- -----------------------------------------------------
-- Table "FP_Basisobjekte"."FP_Plan"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Basisobjekte"."FP_Plan" (
  "gid" INTEGER NOT NULL ,
  "plangeber" INTEGER NULL ,
  "planArt" INTEGER NULL ,
  "sonstPlanArt" INTEGER NULL ,
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
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_fp_plan_xp_plangeber1"
    FOREIGN KEY ("plangeber" )
    REFERENCES "XP_Sonstiges"."XP_Plangeber" ("id" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_fp_plan_fp_sonstplanart1"
    FOREIGN KEY ("sonstPlanArt" )
    REFERENCES "FP_Basisobjekte"."FP_SonstPlanArt" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_fp_plan_fp_verfahren1"
    FOREIGN KEY ("verfahren" )
    REFERENCES "FP_Basisobjekte"."FP_Verfahren" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_fp_plan_fp_status1"
    FOREIGN KEY ("status" )
    REFERENCES "FP_Basisobjekte"."FP_Status" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_fp_plan_fp_rechtsstand1"
    FOREIGN KEY ("rechtsstand" )
    REFERENCES "FP_Basisobjekte"."FP_Rechtsstand" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_fp_plan_xp_externereferenz4"
    FOREIGN KEY ("refUmweltbericht" )
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
    REFERENCES "FP_Basisobjekte"."FP_PlanArt" ("Wert" )
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
COMMENT ON COLUMN "FP_Basisobjekte"."FP_Plan"."plangeber" IS 'Für die Planung zuständige Institution';
COMMENT ON COLUMN "FP_Basisobjekte"."FP_Plan"."planArt" IS 'Typ des FPlans';
COMMENT ON COLUMN "FP_Basisobjekte"."FP_Plan"."sonstPlanArt" IS 'Sonstige Art eines FPlans bei planArt == 9999.';
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
CREATE TRIGGER "change_to_FP_Plan" BEFORE INSERT OR UPDATE OR DELETE ON "FP_Basisobjekte"."FP_Plan" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Plan"(); 
SELECT "XP_Basisobjekte".registergeometrycolumn('','FP_Basisobjekte','FP_Plan', 'reumlicherGeltungsbereich','MULTIPOLYGON',2, true);

-- -----------------------------------------------------
-- Table "FP_Basisobjekte"."FP_Bereich"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Basisobjekte"."FP_Bereich" (
  "gid" INTEGER NOT NULL ,
  "versionBauNVO" INTEGER NULL ,
  "versionBauNVOText" VARCHAR(255) NULL ,
  "versionBauGB" DATE NULL ,
  "versionBauGBText" VARCHAR(255) NULL ,
  "gehoertZuPlan" INTEGER NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_Bereich_FP_Plan1"
    FOREIGN KEY ("gehoertZuPlan" )
    REFERENCES "FP_Basisobjekte"."FP_Plan" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_Bereich_XP_VersionBauNVO1"
    FOREIGN KEY ("versionBauNVO" )
    REFERENCES "XP_Enumerationen"."XP_VersionBauNVO" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_Bereich_XP_Bereich1"
    FOREIGN KEY ("gid" )
    REFERENCES "XP_Basisobjekte"."XP_Bereich" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("XP_Basisobjekte"."XP_Geltungsbereich");;

CREATE INDEX "idx_fk_FP_Bereich_FP_Plan1" ON "FP_Basisobjekte"."FP_Bereich" ("gehoertZuPlan") ;
CREATE INDEX "idx_fk_FP_Bereich_XP_VersionBauNVO1" ON "FP_Basisobjekte"."FP_Bereich" ("versionBauNVO") ;
GRANT SELECT ON TABLE "FP_Basisobjekte"."FP_Bereich" TO xp_gast;
GRANT ALL ON TABLE "FP_Basisobjekte"."FP_Bereich" TO fp_user;
COMMENT ON TABLE "FP_Basisobjekte"."FP_Bereich" IS 'Diese Klasse modelliert einen Bereich eines Flächennutzungsplans.';
COMMENT ON COLUMN "FP_Basisobjekte"."FP_Bereich"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN "FP_Basisobjekte"."FP_Bereich"."versionBauNVO" IS 'Benutzte Version der BauNVO';
COMMENT ON COLUMN "FP_Basisobjekte"."FP_Bereich"."versionBauNVOText" IS 'Textliche Spezifikation einer anderen Gesetzesgrundlage als der BauNVO. In diesem Fall muss das Attribut versionBauNVO den Wert 9999 haben.';
COMMENT ON COLUMN "FP_Basisobjekte"."FP_Bereich"."versionBauGB" IS 'Datum der zugrunde liegenden Version des BauGB.';
COMMENT ON COLUMN "FP_Basisobjekte"."FP_Bereich"."versionBauGBText" IS 'Zugrunde liegende Version des BauGB.';
COMMENT ON COLUMN "FP_Basisobjekte"."FP_Bereich"."gehoertZuPlan" IS '';
CREATE TRIGGER "change_to_FP_Bereich" BEFORE INSERT OR UPDATE OR DELETE ON "FP_Basisobjekte"."FP_Bereich" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Bereich"(); 
SELECT "XP_Basisobjekte".registergeometrycolumn('','FP_Basisobjekte','FP_Bereich', 'geltungsbereich','MULTIPOLYGON',2, true);

-- -----------------------------------------------------
-- Table "FP_Basisobjekte"."FP_Rechtscharakter"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Basisobjekte"."FP_Rechtscharakter" (
  "Wert" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Wert") );
GRANT SELECT ON TABLE "FP_Basisobjekte"."FP_Rechtscharakter" TO xp_gast;

-- -----------------------------------------------------
-- Table "FP_Basisobjekte"."FP_SpezifischePraegungTypen"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Basisobjekte"."FP_SpezifischePraegungTypen" (
  "Wert" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Wert") );
GRANT SELECT ON TABLE "FP_Basisobjekte"."FP_SpezifischePraegungTypen" TO xp_gast;
GRANT ALL ON TABLE "FP_Basisobjekte"."FP_SpezifischePraegungTypen" TO fp_user;

-- -----------------------------------------------------
-- Table "FP_Basisobjekte"."FP_Objekt"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Basisobjekte"."FP_Objekt" (
  "gid" INTEGER NOT NULL ,
  "rechtscharakter" INTEGER NULL ,
  "spezifischePraegung" INTEGER NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_bp_objekt_bp_rechtscharakter1"
    FOREIGN KEY ("rechtscharakter" )
    REFERENCES "FP_Basisobjekte"."FP_Rechtscharakter" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT "fk_BP_Objekt_XP_Objekt1"
    FOREIGN KEY ("gid" )
    REFERENCES "XP_Basisobjekte"."XP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_Objekt_FP_SpezifischePraegungTypen1"
    FOREIGN KEY ("spezifischePraegung" )
    REFERENCES "FP_Basisobjekte"."FP_SpezifischePraegungTypen" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION);

CREATE INDEX "idx_fk_bp_objekt_bp_rechtscharakter1" ON "FP_Basisobjekte"."FP_Objekt" ("rechtscharakter") ;
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
  "FP_Bereich_gid" INTEGER NOT NULL ,
  "FP_Objekt_gid" INTEGER NOT NULL ,
  PRIMARY KEY ("FP_Bereich_gid", "FP_Objekt_gid") ,
  CONSTRAINT "fk_gehoertzuFP_Bereich_FP_Bereich1"
    FOREIGN KEY ("FP_Bereich_gid" )
    REFERENCES "FP_Basisobjekte"."FP_Bereich" ("gid" )
    ON DELETE NO ACTION
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
  "BP_Plan_gid" INTEGER NOT NULL ,
  "XP_Gemeinde_id" INTEGER NOT NULL ,
  PRIMARY KEY ("BP_Plan_gid", "XP_Gemeinde_id") ,
  CONSTRAINT "fk_gemeinde_BP_Plan1"
    FOREIGN KEY ("BP_Plan_gid" )
    REFERENCES "FP_Basisobjekte"."FP_Plan" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_gemeinde_XP_Gemeinde1"
    FOREIGN KEY ("XP_Gemeinde_id" )
    REFERENCES "XP_Sonstiges"."XP_Gemeinde" ("id" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE);

CREATE INDEX "idx_fk_gemeinde_BP_Plan1" ON "FP_Basisobjekte"."gemeinde" ("BP_Plan_gid") ;
CREATE INDEX "idx_fk_gemeinde_XP_Gemeinde1" ON "FP_Basisobjekte"."gemeinde" ("XP_Gemeinde_id") ;
GRANT SELECT ON TABLE "FP_Basisobjekte"."gemeinde" TO xp_gast;
GRANT ALL ON TABLE "FP_Basisobjekte"."gemeinde" TO fp_user;
COMMENT ON TABLE  "FP_Basisobjekte"."gemeinde" IS 'Zuständige Gemeinde';

-- -----------------------------------------------------
-- Table "FP_Raster"."FP_RasterplanAenderung"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Raster"."FP_RasterplanAenderung" (
  "gid" INTEGER NOT NULL ,
  " aufstellungbeschlussDatum" DATE NULL ,
  "aenderungenBisDatum" DATE NULL ,
  "entwurfsbeschlussDatum" DATE NULL ,
  "planbeschlussDatum" DATE NULL ,
  "wirksamkeitsDatum" DATE NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_BP_RasterplanAenderung1"
    FOREIGN KEY ("gid" )
    REFERENCES "XP_Raster"."XP_RasterplanAenderung" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("XP_Raster"."XP_GeltungsbereichAenderung");

GRANT SELECT ON TABLE "FP_Raster"."FP_RasterplanAenderung" TO xp_gast;
GRANT ALL ON TABLE "FP_Raster"."FP_RasterplanAenderung" TO fp_user;
COMMENT ON TABLE "FP_Raster"."FP_RasterplanAenderung" IS 'Georeferenziertes Rasterbild der Änderung eines Basisplans. Die abgeleitete Klasse besitzt Datums-Attribute, die spezifisch für Flächennutzungspläne sind.';
COMMENT ON COLUMN "FP_Raster"."FP_RasterplanAenderung"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN "FP_Raster"."FP_RasterplanAenderung"." aufstellungbeschlussDatum" IS '';
COMMENT ON COLUMN "FP_Raster"."FP_RasterplanAenderung"."aenderungenBisDatum" IS '';
COMMENT ON COLUMN "FP_Raster"."FP_RasterplanAenderung"."entwurfsbeschlussDatum" IS '';
COMMENT ON COLUMN "FP_Raster"."FP_RasterplanAenderung"."planbeschlussDatum" IS '';
COMMENT ON COLUMN "FP_Raster"."FP_RasterplanAenderung"."wirksamkeitsDatum" IS '';
CREATE TRIGGER "change_to_FP_RasterplanAenderung" BEFORE INSERT OR UPDATE OR DELETE ON "FP_Raster"."FP_RasterplanAenderung" FOR EACH ROW EXECUTE PROCEDURE "XP_Raster"."child_of_XP_RasterplanAenderung"();
SELECT "XP_Basisobjekte".registergeometrycolumn('','FP_Raster','FP_RasterplanAenderung', 'geltungsbereichAenderung','MULTIPOLYGON',2, true);

-- -----------------------------------------------------
-- Table "FP_Basisobjekte"."rasterAenderung"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Basisobjekte"."rasterAenderung" (
  "FP_Bereich_gid" INTEGER NOT NULL ,
  "FP_RasterplanAenderung_gid" INTEGER NOT NULL ,
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
  "gid" INTEGER NOT NULL ,
  "position" GEOMETRY NOT NULL ,
  PRIMARY KEY ("gid") );
GRANT SELECT ON TABLE "FP_Basisobjekte"."FP_Punktobjekt" TO xp_gast;
GRANT ALL ON TABLE "FP_Basisobjekte"."FP_Punktobjekt" TO fp_user;
CREATE TRIGGER "FP_Punktobjekt_isAbstract" BEFORE INSERT OR UPDATE OR DELETE ON "FP_Basisobjekte"."FP_Punktobjekt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isAbstract"();

-- -----------------------------------------------------
-- Table "FP_Basisobjekte"."FP_Linienobjekt"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Basisobjekte"."FP_Linienobjekt" (
  "gid" INTEGER NOT NULL ,
  "position" GEOMETRY NOT NULL ,
  PRIMARY KEY ("gid") );
GRANT SELECT ON TABLE "FP_Basisobjekte"."FP_Linienobjekt" TO xp_gast;
GRANT ALL ON TABLE "FP_Basisobjekte"."FP_Linienobjekt" TO fp_user;
CREATE TRIGGER "FP_Linienobjekt_isAbstract" BEFORE INSERT OR UPDATE OR DELETE ON "FP_Basisobjekte"."FP_Linienobjekt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isAbstract"();

-- -----------------------------------------------------
-- Table "FP_Basisobjekte"."FP_Flaechenobjekt"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Basisobjekte"."FP_Flaechenobjekt" (
  "gid" INTEGER NOT NULL ,
  "position" GEOMETRY NOT NULL ,
  "flaechenschluss" BOOLEAN  NOT NULL ,
  PRIMARY KEY ("gid") );
GRANT SELECT ON TABLE "FP_Basisobjekte"."FP_Flaechenobjekt" TO xp_gast;
GRANT ALL ON TABLE "FP_Basisobjekte"."FP_Flaechenobjekt" TO fp_user;
CREATE TRIGGER "FP_Flaechenobjekt_isAbstract" BEFORE INSERT OR UPDATE OR DELETE ON "FP_Basisobjekte"."FP_Flaechenobjekt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isAbstract"();

-- -----------------------------------------------------
-- Table "FP_Naturschutz"."FP_AusgleichsFlaeche"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Naturschutz"."FP_AusgleichsFlaeche" (
  "gid" INTEGER NOT NULL ,
  "ziel" INTEGER NULL ,
  "massnahme" INTEGER NULL ,
  "weitereMassnahme1" INTEGER NULL ,
  "weitereMassnahme2" INTEGER NULL ,
  "refMassnahmenText" INTEGER NULL ,
  "refLandschaftsplan" INTEGER NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_AusgleichsFlaeche_XP_SPEZiele1"
    FOREIGN KEY ("ziel" )
    REFERENCES "XP_Sonstiges"."XP_SPEZiele" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_AusgleichsFlaeche_XP_SPEMassnahmenDaten1"
    FOREIGN KEY ("massnahme" )
    REFERENCES "XP_Sonstiges"."XP_SPEMassnahmenDaten" ("id" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_AusgleichsFlaeche_XP_SPEMassnahmenDaten2"
    FOREIGN KEY ("weitereMassnahme1" )
    REFERENCES "XP_Sonstiges"."XP_SPEMassnahmenDaten" ("id" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_AusgleichsFlaeche_XP_SPEMassnahmenDaten3"
    FOREIGN KEY ("weitereMassnahme2" )
    REFERENCES "XP_Sonstiges"."XP_SPEMassnahmenDaten" ("id" )
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
INHERITS("FP_Basisobjekte.FP_Flaechenobjekt");

CREATE INDEX "idx_fk_FP_SchutzPflegeEntwicklung_XP_SPEZiele" ON "FP_Naturschutz"."FP_AusgleichsFlaeche" ("ziel") ;
CREATE INDEX "idx_fk_FP_SchutzPflegeEntwicklung_XP_SPEMassnahmenDaten1" ON "FP_Naturschutz"."FP_AusgleichsFlaeche" ("massnahme") ;
CREATE INDEX "idx_fk_FP_SchutzPflegeEntwicklung_XP_SPEMassnahmenDaten2" ON "FP_Naturschutz"."FP_AusgleichsFlaeche" ("weitereMassnahme1") ;
CREATE INDEX "idx_fk_FP_SchutzPflegeEntwicklung_XP_SPEMassnahmenDaten3" ON "FP_Naturschutz"."FP_AusgleichsFlaeche" ("weitereMassnahme2") ;
CREATE INDEX "idx_fk_FP_AusgleichsFlaeche_XP_ExterneReferenz1" ON "FP_Naturschutz"."FP_AusgleichsFlaeche" ("refMassnahmenText") ;
CREATE INDEX "idx_fk_FP_AusgleichsFlaeche_XP_ExterneReferenz2" ON "FP_Naturschutz"."FP_AusgleichsFlaeche" ("refLandschaftsplan") ;
GRANT SELECT ON TABLE "FP_Naturschutz"."FP_AusgleichsFlaeche" TO xp_gast;
GRANT ALL ON TABLE "FP_Naturschutz"."FP_AusgleichsFlaeche" TO fp_user;
COMMENT ON TABLE  "FP_Naturschutz"."FP_AusgleichsFlaeche" IS 'Flächen und Maßnahmen zum Ausgleich gemäß §5, Abs. 2a BauBG.';
COMMENT ON COLUMN  "FP_Naturschutz"."FP_AusgleichsFlaeche"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN  "FP_Naturschutz"."FP_AusgleichsFlaeche"."ziel" IS 'Unterscheidung nach den Zielen "Schutz, Pflege" und "Entwicklung".';
COMMENT ON COLUMN  "FP_Naturschutz"."FP_AusgleichsFlaeche"."massnahme" IS 'Auf der Fläche durchzuführende Maßnahme.';
COMMENT ON COLUMN  "FP_Naturschutz"."FP_AusgleichsFlaeche"."weitereMassnahme1" IS 'Weitere durchzuführende Massnahme.';
COMMENT ON COLUMN  "FP_Naturschutz"."FP_AusgleichsFlaeche"."weitereMassnahme2" IS 'Weitere durchzuführende Massnahme.';
COMMENT ON COLUMN  "FP_Naturschutz"."FP_AusgleichsFlaeche"."refMassnahmenText" IS 'Referenz auf ein Dokument in dem die Massnahmen beschrieben werden.';
COMMENT ON COLUMN  "FP_Naturschutz"."FP_AusgleichsFlaeche"."refLandschaftsplan" IS 'Referenz auf den Landschaftsplan.';
CREATE TRIGGER "change_to_FP_AusgleichsFlaeche" BEFORE INSERT OR UPDATE OR DELETE ON "FP_Naturschutz"."FP_AusgleichsFlaeche" FOR EACH ROW EXECUTE PROCEDURE "FP_Basisobjekte"."child_of_FP_Objekt"();
CREATE TRIGGER "FP_AusgleichsFlaeche_RHR" BEFORE INSERT OR UPDATE ON "FP_Naturschutz"."FP_AusgleichsFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."positionFollowsRHR"();
SELECT "XP_Basisobjekte".registergeometrycolumn('','FP_Naturschutz','FP_AusgleichsFlaeche', 'position','MULTIPOLYGON',2, true);

-- -----------------------------------------------------
-- Table "FP_Basisobjekte"."wirdAusgeglichenDurchFlaeche"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Basisobjekte"."wirdAusgeglichenDurchFlaeche" (
  "FP_Objekt_gid" INTEGER NOT NULL ,
  "FP_AusgleichsFlaeche_gid" INTEGER NOT NULL ,
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
  "gid" INTEGER NOT NULL ,
  "ziel" INTEGER NULL ,
  "massnahme" INTEGER NULL ,
  "weitereMassnahme1" INTEGER NULL ,
  "weitereMassnahme2" INTEGER NULL ,
  "istAusgleich" BOOLEAN  NULL DEFAULT false,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_SchutzPflegeEntwicklung_XP_SPEZiele"
    FOREIGN KEY ("ziel" )
    REFERENCES "XP_Sonstiges"."XP_SPEZiele" ("Wert" )
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
CREATE TRIGGER "change_to_FP_SchutzPflegeEntwicklung" BEFORE INSERT OR UPDATE OR DELETE ON "FP_Naturschutz"."FP_SchutzPflegeEntwicklung" FOR EACH ROW EXECUTE PROCEDURE "FP_Basisobjekte"."child_of_FP_Objekt"();

-- -----------------------------------------------------
-- Table "FP_Basisobjekte"."wirdAusgeglichenDurchSPE"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Basisobjekte"."wirdAusgeglichenDurchSPE" (
  "FP_Objekt_gid" INTEGER NOT NULL ,
  "FP_SchutzPflegeEntwicklung_gid" INTEGER NOT NULL ,
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
  "BP_RasterplanAenderung_id" INTEGER NOT NULL ,
  "auslegungsStartDatum" DATE NOT NULL ,
  PRIMARY KEY ("BP_RasterplanAenderung_id", "auslegungsStartDatum") ,
  CONSTRAINT "fk_auslegungsStartDatum_FP_RasterplanAenderung"
    FOREIGN KEY ("BP_RasterplanAenderung_id" )
    REFERENCES "FP_Raster"."FP_RasterplanAenderung" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE);

CREATE INDEX "idx_fk_auslegungsStartDatum_FP_RasterplanAenderung" ON "FP_Raster"."auslegungsStartDatum" ("BP_RasterplanAenderung_id") ;
GRANT SELECT ON TABLE "FP_Raster"."auslegungsStartDatum" TO xp_gast;
GRANT ALL ON TABLE "FP_Raster"."auslegungsStartDatum" TO fp_user;
COMMENT ON TABLE  "FP_Raster"."auslegungsStartDatum" IS 'Start-Datum der öffentlichen Auslegung.';

-- -----------------------------------------------------
-- Table "FP_Raster"."auslegungsEndDatum"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Raster"."auslegungsEndDatum" (
  "auslegungsEndDatum" DATE NOT NULL ,
  "BP_RasterplanAenderung_id" INTEGER NOT NULL ,
  PRIMARY KEY ("auslegungsEndDatum", "BP_RasterplanAenderung_id") ,
  CONSTRAINT "fk_auslegungsEndDatum_FP_RasterplanAenderung1"
    FOREIGN KEY ("BP_RasterplanAenderung_id" )
    REFERENCES "FP_Raster"."FP_RasterplanAenderung" ("gid" )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION);

CREATE INDEX "idx_fk_auslegungsEndDatum_FP_RasterplanAenderung1" ON "FP_Raster"."auslegungsEndDatum" ("BP_RasterplanAenderung_id") ;
CREATE INDEX "idx_fk_auslegungsStartDatum_FP_RasterplanAenderung" ON "FP_Raster"."auslegungsStartDatum" ("BP_RasterplanAenderung_id") ;
GRANT SELECT ON TABLE "FP_Raster"."auslegungsEndDatum" TO xp_gast;
GRANT ALL ON TABLE "FP_Raster"."auslegungsEndDatum" TO fp_user;
COMMENT ON TABLE  "FP_Raster"."auslegungsEndDatum" IS 'End-Datum der öffentlichen Auslegung.';


-- -----------------------------------------------------
-- Table "FP_Raster"."traegerbeteiligungsStartDatum"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Raster"."traegerbeteiligungsStartDatum" (
  "traegerbeteiligungsStartDatum" DATE NOT NULL ,
  "BP_RasterplanAenderung_id" INTEGER NOT NULL ,
  PRIMARY KEY ("traegerbeteiligungsStartDatum", "BP_RasterplanAenderung_id") ,
  CONSTRAINT "fk_traegerbeteiligungsStartDatum_FP_RasterplanAenderung1"
    FOREIGN KEY ("BP_RasterplanAenderung_id" )
    REFERENCES "FP_Raster"."FP_RasterplanAenderung" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE);
CREATE INDEX "idx_fk_traegerbeteiligungsStartDatum_FP_RasterplanAenderung1" ON "FP_Raster"."traegerbeteiligungsStartDatum" ("BP_RasterplanAenderung_id") ;
GRANT SELECT ON TABLE "FP_Raster"."traegerbeteiligungsStartDatum" TO xp_gast;
GRANT ALL ON TABLE "FP_Raster"."traegerbeteiligungsStartDatum" TO fp_user;
COMMENT ON TABLE  "FP_Raster"."traegerbeteiligungsStartDatum" IS 'Start-Datum der Trägerbeteiligung.';

-- -----------------------------------------------------
-- Table "FP_Raster"."traegerbeteiligungsEndDatum"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Raster"."traegerbeteiligungsEndDatum" (
  "traegerbeteiligungsEndDatum" DATE NOT NULL ,
  "BP_RasterplanAenderung_id" INTEGER NOT NULL ,
  PRIMARY KEY ("traegerbeteiligungsEndDatum", "BP_RasterplanAenderung_id") ,
  CONSTRAINT "fk_traegerbeteiligungsEndDatum_FP_RasterplanAenderung1"
    FOREIGN KEY ("BP_RasterplanAenderung_id" )
    REFERENCES "FP_Raster"."FP_RasterplanAenderung" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE);
CREATE INDEX "idx_fk_traegerbeteiligungsEndDatum_FP_RasterplanAenderung1" ON "FP_Raster"."traegerbeteiligungsEndDatum" ("BP_RasterplanAenderung_id") ;
GRANT SELECT ON TABLE "FP_Raster"."traegerbeteiligungsEndDatum" TO xp_gast;
GRANT ALL ON TABLE "FP_Raster"."traegerbeteiligungsEndDatum" TO fp_user;
COMMENT ON TABLE  "FP_Raster"."traegerbeteiligungsEndDatum" IS 'End-Datum der Trägerbeteiligung.';

-- -----------------------------------------------------
-- Table "FP_Naturschutz"."FP_SchutzPflegeEntwicklungPunkt"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Naturschutz"."FP_SchutzPflegeEntwicklungPunkt" (
  "gid" INTEGER NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_SchutzPflegeEntwicklungPunkt1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Naturschutz"."FP_SchutzPflegeEntwicklung" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("FP_Basisobjekte"."FP_Punktobjekt");

GRANT SELECT ON TABLE "FP_Naturschutz"."FP_SchutzPflegeEntwicklungPunkt" TO xp_gast;
GRANT ALL ON TABLE "FP_Naturschutz"."FP_SchutzPflegeEntwicklungPunkt" TO fp_user;
COMMENT ON COLUMN "FP_Naturschutz"."FP_SchutzPflegeEntwicklungPunkt"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_FP_SchutzPflegeEntwicklungPunkt" BEFORE INSERT OR UPDATE OR DELETE ON "FP_Naturschutz"."FP_SchutzPflegeEntwicklungPunkt" FOR EACH ROW EXECUTE PROCEDURE "FP_Naturschutz"."child_of_FP_SchutzPflegeEntwicklung"();
SELECT "XP_Basisobjekte".registergeometrycolumn('','FP_Naturschutz','FP_SchutzPflegeEntwicklungPunkt', 'position','MULTIPOINT',2, true);

-- -----------------------------------------------------
-- Table "FP_Naturschutz"."FP_SchutzPflegeEntwicklungLinie"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Naturschutz"."FP_SchutzPflegeEntwicklungLinie" (
  "gid" INTEGER NOT NULL ,
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
CREATE TRIGGER "change_to_FP_SchutzPflegeEntwicklungLinie" BEFORE INSERT OR UPDATE OR DELETE ON "FP_Naturschutz"."FP_SchutzPflegeEntwicklungLinie" FOR EACH ROW EXECUTE PROCEDURE "FP_Naturschutz"."child_of_FP_SchutzPflegeEntwicklung"();
SELECT "XP_Basisobjekte".registergeometrycolumn('','FP_Naturschutz','FP_SchutzPflegeEntwicklungLinie', 'position','MULTILINESTRING',2, true);

-- -----------------------------------------------------
-- Table "FP_Naturschutz"."FP_SchutzPflegeEntwicklungFlaeche"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Naturschutz"."FP_SchutzPflegeEntwicklungFlaeche" (
  "gid" INTEGER NOT NULL ,
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
CREATE TRIGGER "change_to_FP_SchutzPflegeEntwicklungFlaeche" BEFORE INSERT OR UPDATE OR DELETE ON "FP_Naturschutz"."FP_SchutzPflegeEntwicklungFlaeche" FOR EACH ROW EXECUTE PROCEDURE "FP_Naturschutz"."child_of_FP_SchutzPflegeEntwicklung"();
CREATE TRIGGER "FP_SchutzPflegeEntwicklungFlaeche_RHR" BEFORE INSERT OR UPDATE ON "FP_Naturschutz"."FP_SchutzPflegeEntwicklungFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."positionFollowsRHR"();
SELECT "XP_Basisobjekte".registergeometrycolumn('','FP_Naturschutz','FP_SchutzPflegeEntwicklungFlaeche', 'position','MULTIPOLYGON',2, true);

-- -----------------------------------------------------
-- Table "FP_Bebauung"."FP_DetailArtDerBaulNutzung"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Bebauung"."FP_DetailArtDerBaulNutzung" (
  "Wert" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Wert") );
GRANT SELECT ON TABLE "FP_Bebauung"."FP_DetailArtDerBaulNutzung" TO xp_gast;
GRANT ALL ON TABLE "FP_Bebauung"."FP_DetailArtDerBaulNutzung" TO fp_user;

-- -----------------------------------------------------
-- Table "FP_Bebauung"."FP_BebauungsFlaeche"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Bebauung"."FP_BebauungsFlaeche" (
  "gid" INTEGER NOT NULL ,
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
    REFERENCES "XP_Enumerationen"."XP_AllgArtDerBaulNutzung" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_BebauungsFlaeche_XP_BesondereArtDerBaulNutzung1"
    FOREIGN KEY ("besondereArtDerBaulNutzung" )
    REFERENCES "XP_Enumerationen"."XP_BesondereArtDerBaulNutzung" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_BebauungsFlaeche_XP_Sondernutzungen1"
    FOREIGN KEY ("sonderNutzung" )
    REFERENCES "XP_Enumerationen"."XP_Sondernutzungen" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_BebauungsFlaeche_FP_Objekt1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Basisobjekte"."FP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_BebauungsFlaeche_FP_DetailArtDerBaulNutzung1"
    FOREIGN KEY ("detaillierteArtDerBaulNutzung" )
    REFERENCES "FP_Bebauung"."FP_DetailArtDerBaulNutzung" ("Wert" )
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
CREATE TRIGGER "change_to_FP_BebauungsFlaeche" BEFORE INSERT OR UPDATE OR DELETE ON "FP_Bebauung"."FP_BebauungsFlaeche" FOR EACH ROW EXECUTE PROCEDURE "FP_Basisobjekte"."child_of_FP_Objekt"();
CREATE TRIGGER "flaechenschluss_FP_BebauungsFlaeche" BEFORE INSERT OR UPDATE OR DELETE ON "FP_Bebauung"."FP_BebauungsFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isFlaechenschlussobjekt"();
CREATE TRIGGER "FP_BebauungsFlaeche_RHR" BEFORE INSERT OR UPDATE ON "FP_Bebauung"."FP_BebauungsFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."positionFollowsRHR"();
SELECT "XP_Basisobjekte".registergeometrycolumn('','FP_Bebauung','FP_BebauungsFlaeche', 'position','MULTIPOLYGON',2, true);

-- -----------------------------------------------------
-- Table "FP_Bebauung"."FP_KeineZentrAbwasserBeseitigungFlaeche"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Bebauung"."FP_KeineZentrAbwasserBeseitigungFlaeche" (
  "gid" INTEGER NOT NULL ,
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
CREATE TRIGGER "change_to_FP_KeineZentrAbwasserBeseitigungFlaeche" BEFORE INSERT OR UPDATE OR DELETE ON "FP_Bebauung"."FP_KeineZentrAbwasserBeseitigungFlaeche" FOR EACH ROW EXECUTE PROCEDURE "FP_Basisobjekte"."child_of_FP_Objekt"();
CREATE TRIGGER "FP_KeineZentrAbwasserBeseitigungFlaeche_RHR" BEFORE INSERT OR UPDATE ON "FP_Bebauung"."FP_KeineZentrAbwasserBeseitigungFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."positionFollowsRHR"();
SELECT "XP_Basisobjekte".registergeometrycolumn('','FP_Bebauung','FP_KeineZentrAbwasserBeseitigungFlaeche', 'position','MULTIPOLYGON',2, true);

-- -----------------------------------------------------
-- Table "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_DetailZweckbestGemeinbedarf"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_DetailZweckbestGemeinbedarf" (
  "Wert" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Wert") );
GRANT SELECT ON TABLE "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_DetailZweckbestGemeinbedarf" TO xp_gast;
GRANT ALL ON TABLE "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_DetailZweckbestGemeinbedarf" TO fp_user;

-- -----------------------------------------------------
-- Table "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_Gemeinbedarf"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_Gemeinbedarf" (
  "gid" INTEGER NOT NULL ,
  "zweckbestimmung" INTEGER NULL ,
  "weitereZweckbestimmung1" INTEGER NULL ,
  "weitereZweckbestimmung2" INTEGER NULL ,
  "weitereZweckbestimmung3" INTEGER NULL ,
  "weitereZweckbestimmung4" INTEGER NULL ,
  "weitereZweckbestimmung5" INTEGER NULL ,
  "besondereZweckbestimmung" INTEGER NULL ,
  "weitereBesondZweckbestimmung1" INTEGER NULL ,
  "weitereBesondZweckbestimmung2" INTEGER NULL ,
  "weitereBesondZweckbestimmung3" INTEGER NULL ,
  "weitereBesondZweckbestimmung4" INTEGER NULL ,
  "weitereBesondZweckbestimmung5" INTEGER NULL ,
  "detaillierteZweckbestimmung" INTEGER NULL ,
  "weitereDetailZweckbestimmung1" INTEGER NULL ,
  "weitereDetailZweckbestimmung2" INTEGER NULL ,
  "weitereDetailZweckbestimmung3" INTEGER NULL ,
  "weitereDetailZweckbestimmung4" INTEGER NULL ,
  "weitereDetailZweckbestimmung5" INTEGER NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_XP_ZweckbestimmungGemeinbedarf0"
    FOREIGN KEY ("zweckbestimmung" )
    REFERENCES "XP_Enumerationen"."XP_ZweckbestimmungGemeinbedarf" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_Gemeinbedarf_XP_ZweckbestimmungGemeinbedarf1"
    FOREIGN KEY ("weitereZweckbestimmung1" )
    REFERENCES "XP_Enumerationen"."XP_ZweckbestimmungGemeinbedarf" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_Gemeinbedarf_XP_ZweckbestimmungGemeinbedarf2"
    FOREIGN KEY ("weitereZweckbestimmung2" )
    REFERENCES "XP_Enumerationen"."XP_ZweckbestimmungGemeinbedarf" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_Gemeinbedarf_XP_ZweckbestimmungGemeinbedarf3"
    FOREIGN KEY ("weitereZweckbestimmung3" )
    REFERENCES "XP_Enumerationen"."XP_ZweckbestimmungGemeinbedarf" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_Gemeinbedarf_XP_ZweckbestimmungGemeinbedarf4"
    FOREIGN KEY ("weitereZweckbestimmung4" )
    REFERENCES "XP_Enumerationen"."XP_ZweckbestimmungGemeinbedarf" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_Gemeinbedarf_XP_ZweckbestimmungGemeinbedarf5"
    FOREIGN KEY ("weitereZweckbestimmung5" )
    REFERENCES "XP_Enumerationen"."XP_ZweckbestimmungGemeinbedarf" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_Gemeinbedarf_XP_BesondereZweckbestGemeinbedarf1"
    FOREIGN KEY ("besondereZweckbestimmung" )
    REFERENCES "XP_Enumerationen"."XP_BesondereZweckbestGemeinbedarf" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_Gemeinbedarf_XP_BesondereZweckbestGemeinbedarf2"
    FOREIGN KEY ("weitereBesondZweckbestimmung1" )
    REFERENCES "XP_Enumerationen"."XP_BesondereZweckbestGemeinbedarf" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_Gemeinbedarf_XP_BesondereZweckbestGemeinbedarf3"
    FOREIGN KEY ("weitereBesondZweckbestimmung2" )
    REFERENCES "XP_Enumerationen"."XP_BesondereZweckbestGemeinbedarf" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_Gemeinbedarf_XP_BesondereZweckbestGemeinbedarf4"
    FOREIGN KEY ("weitereBesondZweckbestimmung3" )
    REFERENCES "XP_Enumerationen"."XP_BesondereZweckbestGemeinbedarf" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_Gemeinbedarf_XP_BesondereZweckbestGemeinbedarf5"
    FOREIGN KEY ("weitereBesondZweckbestimmung4" )
    REFERENCES "XP_Enumerationen"."XP_BesondereZweckbestGemeinbedarf" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_Gemeinbedarf_XP_BesondereZweckbestGemeinbedarf6"
    FOREIGN KEY ("weitereBesondZweckbestimmung5" )
    REFERENCES "XP_Enumerationen"."XP_BesondereZweckbestGemeinbedarf" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_Gemeinbedarf_FP_DetailZweckbestGemeinbedarf1"
    FOREIGN KEY ("detaillierteZweckbestimmung" )
    REFERENCES "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_DetailZweckbestGemeinbedarf" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_Gemeinbedarf_FP_DetailZweckbestGemeinbedarf2"
    FOREIGN KEY ("weitereDetailZweckbestimmung1" )
    REFERENCES "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_DetailZweckbestGemeinbedarf" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_Gemeinbedarf_FP_DetailZweckbestGemeinbedarf3"
    FOREIGN KEY ("weitereDetailZweckbestimmung2" )
    REFERENCES "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_DetailZweckbestGemeinbedarf" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_Gemeinbedarf_FP_DetailZweckbestGemeinbedarf4"
    FOREIGN KEY ("weitereDetailZweckbestimmung3" )
    REFERENCES "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_DetailZweckbestGemeinbedarf" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_Gemeinbedarf_FP_DetailZweckbestGemeinbedarf5"
    FOREIGN KEY ("weitereDetailZweckbestimmung4" )
    REFERENCES "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_DetailZweckbestGemeinbedarf" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_Gemeinbedarf_FP_DetailZweckbestGemeinbedarf6"
    FOREIGN KEY ("weitereDetailZweckbestimmung5" )
    REFERENCES "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_DetailZweckbestGemeinbedarf" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_Gemeinbedarf_FP_Objekt1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Basisobjekte"."FP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE);

CREATE INDEX "idx_fk_XP_ZweckbestimmungGemeinbedarf0" ON "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_Gemeinbedarf" ("zweckbestimmung") ;
CREATE INDEX "idx_fk_FP_Gemeinbedarf_XP_ZweckbestimmungGemeinbedarf1" ON "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_Gemeinbedarf" ("weitereZweckbestimmung1") ;
CREATE INDEX "idx_fk_FP_Gemeinbedarf_XP_ZweckbestimmungGemeinbedarf2" ON "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_Gemeinbedarf" ("weitereZweckbestimmung2") ;
CREATE INDEX "idx_fk_FP_Gemeinbedarf_XP_ZweckbestimmungGemeinbedarf3" ON "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_Gemeinbedarf" ("weitereZweckbestimmung3") ;
CREATE INDEX "idx_fk_FP_Gemeinbedarf_XP_ZweckbestimmungGemeinbedarf4" ON "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_Gemeinbedarf" ("weitereZweckbestimmung4") ;
CREATE INDEX "idx_fk_FP_Gemeinbedarf_XP_ZweckbestimmungGemeinbedarf5" ON "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_Gemeinbedarf" ("weitereZweckbestimmung5") ;
CREATE INDEX "idx_fk_FP_Gemeinbedarf_XP_BesondereZweckbestGemeinbedarf1" ON "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_Gemeinbedarf" ("besondereZweckbestimmung") ;
CREATE INDEX "idx_fk_FP_Gemeinbedarf_XP_BesondereZweckbestGemeinbedarf2" ON "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_Gemeinbedarf" ("weitereBesondZweckbestimmung1") ;
CREATE INDEX "idx_fk_FP_Gemeinbedarf_XP_BesondereZweckbestGemeinbedarf3" ON "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_Gemeinbedarf" ("weitereBesondZweckbestimmung2") ;
CREATE INDEX "idx_fk_FP_Gemeinbedarf_XP_BesondereZweckbestGemeinbedarf4" ON "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_Gemeinbedarf" ("weitereBesondZweckbestimmung3") ;
CREATE INDEX "idx_fk_FP_Gemeinbedarf_XP_BesondereZweckbestGemeinbedarf5" ON "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_Gemeinbedarf" ("weitereBesondZweckbestimmung4") ;
CREATE INDEX "idx_fk_FP_Gemeinbedarf_XP_BesondereZweckbestGemeinbedarf6" ON "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_Gemeinbedarf" ("weitereBesondZweckbestimmung5") ;
CREATE INDEX "idx_fk_FP_Gemeinbedarf_FP_DetailZweckbestGemeinbedarf1" ON "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_Gemeinbedarf" ("detaillierteZweckbestimmung") ;
CREATE INDEX "idx_fk_FP_Gemeinbedarf_FP_DetailZweckbestGemeinbedarf2" ON "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_Gemeinbedarf" ("weitereDetailZweckbestimmung1") ;
CREATE INDEX "idx_fk_FP_Gemeinbedarf_FP_DetailZweckbestGemeinbedarf3" ON "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_Gemeinbedarf" ("weitereDetailZweckbestimmung2") ;
CREATE INDEX "idx_fk_FP_Gemeinbedarf_FP_DetailZweckbestGemeinbedarf4" ON "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_Gemeinbedarf" ("weitereDetailZweckbestimmung3") ;
CREATE INDEX "idx_fk_FP_Gemeinbedarf_FP_DetailZweckbestGemeinbedarf5" ON "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_Gemeinbedarf" ("weitereDetailZweckbestimmung4") ;
CREATE INDEX "idx_fk_FP_Gemeinbedarf_FP_DetailZweckbestGemeinbedarf6" ON "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_Gemeinbedarf" ("weitereDetailZweckbestimmung5") ;
GRANT SELECT ON TABLE "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_Gemeinbedarf" TO xp_gast;
GRANT ALL ON TABLE "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_Gemeinbedarf" TO fp_user;
COMMENT ON TABLE  "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_Gemeinbedarf" IS 'Darstellung von Flächen für den Gemeinbedarf nach §5, Abs. 2, Nr. 2 BauGB.';
COMMENT ON COLUMN "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_Gemeinbedarf"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_Gemeinbedarf"."zweckbestimmung" IS 'Allgemeine Zweckbestimmung der Fläche';
COMMENT ON COLUMN "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_Gemeinbedarf"."weitereZweckbestimmung1" IS 'Weitere allgemeine Zweckbestimmung der Fläche.';
COMMENT ON COLUMN "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_Gemeinbedarf"."weitereZweckbestimmung2" IS 'Weitere allgemeine Zweckbestimmung der Fläche.';
COMMENT ON COLUMN "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_Gemeinbedarf"."weitereZweckbestimmung3" IS 'Weitere allgemeine Zweckbestimmung der Fläche.';
COMMENT ON COLUMN "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_Gemeinbedarf"."weitereZweckbestimmung4" IS 'Weitere allgemeine Zweckbestimmung der Fläche.';
COMMENT ON COLUMN "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_Gemeinbedarf"."weitereZweckbestimmung5" IS 'Weitere allgemeine Zweckbestimmung der Fläche.';
COMMENT ON COLUMN "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_Gemeinbedarf"."besondereZweckbestimmung" IS 'Besondere Zweckbestimmung der Fläche, die die zugehörige allgemeine Zweckbestimmung detailliert oder ersetzt.';
COMMENT ON COLUMN "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_Gemeinbedarf"."weitereBesondZweckbestimmung1" IS 'Weitere besondere Zweckbestimmung der Fläche, die die zugehörige allgemeine Zweckbestimmung detailliert oder ersetzt.';
COMMENT ON COLUMN "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_Gemeinbedarf"."weitereBesondZweckbestimmung2" IS 'Weitere besondere Zweckbestimmung der Fläche, die die zugehörige allgemeine Zweckbestimmung detailliert oder ersetzt.';
COMMENT ON COLUMN "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_Gemeinbedarf"."weitereBesondZweckbestimmung3" IS 'Weitere besondere Zweckbestimmung der Fläche, die die zugehörige allgemeine Zweckbestimmung detailliert oder ersetzt.';
COMMENT ON COLUMN "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_Gemeinbedarf"."weitereBesondZweckbestimmung4" IS 'Weitere besondere Zweckbestimmung der Fläche, die die zugehörige allgemeine Zweckbestimmung detailliert oder ersetzt.';
COMMENT ON COLUMN "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_Gemeinbedarf"."weitereBesondZweckbestimmung5" IS 'Weitere besondere Zweckbestimmung der Fläche, die die zugehörige allgemeine Zweckbestimmung detailliert oder ersetzt.';
COMMENT ON COLUMN "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_Gemeinbedarf"."detaillierteZweckbestimmung" IS 'Über eine ExternalCodeList definierte zusätzliche Zweckbestimmung';
COMMENT ON COLUMN "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_Gemeinbedarf"."weitereDetailZweckbestimmung1" IS 'Über eine CodeList definierte zusätzliche Zweckbestimmung';
COMMENT ON COLUMN "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_Gemeinbedarf"."weitereDetailZweckbestimmung2" IS 'Über eine CodeList definierte zusätzliche Zweckbestimmung';
COMMENT ON COLUMN "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_Gemeinbedarf"."weitereDetailZweckbestimmung3" IS 'Über eine CodeList definierte zusätzliche Zweckbestimmung';
COMMENT ON COLUMN "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_Gemeinbedarf"."weitereDetailZweckbestimmung4" IS 'Über eine CodeList definierte zusätzliche Zweckbestimmung';
COMMENT ON COLUMN "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_Gemeinbedarf"."weitereDetailZweckbestimmung5" IS 'Über eine CodeList definierte zusätzliche Zweckbestimmung';
CREATE TRIGGER "change_to_FP_Gemeinbedarf" BEFORE INSERT OR UPDATE OR DELETE ON "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_Gemeinbedarf" FOR EACH ROW EXECUTE PROCEDURE "FP_Basisobjekte"."child_of_FP_Objekt"();

-- -----------------------------------------------------
-- Table "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_DetailZweckbestSpielSportanlage"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_DetailZweckbestSpielSportanlage" (
  "Wert" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Wert") );
GRANT SELECT ON TABLE "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_DetailZweckbestSpielSportanlage" TO xp_gast;
GRANT ALL ON TABLE "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_DetailZweckbestSpielSportanlage" TO fp_user;

-- -----------------------------------------------------
-- Table "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_SpielSportanlage"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_SpielSportanlage" (
  "gid" INTEGER NOT NULL ,
  "zweckbestimmung" INTEGER NULL ,
  "weitereZweckbestimmung1" INTEGER NULL ,
  "detaillierteZweckbestimmung" INTEGER NULL ,
  "weitereDetailZweckbestimmung1" INTEGER NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_SpielSportanlage_XP_ZweckSpielSportanlage1"
    FOREIGN KEY ("zweckbestimmung" )
    REFERENCES "XP_Enumerationen"."XP_ZweckbestimmungSpielSportanlage" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_SpielSportanlage_XP_ZweckSpielSportanlage2"
    FOREIGN KEY ("weitereZweckbestimmung1" )
    REFERENCES "XP_Enumerationen"."XP_ZweckbestimmungSpielSportanlage" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_SpielSportanlage_FP_DetaiSpielSportanlage1"
    FOREIGN KEY ("detaillierteZweckbestimmung" )
    REFERENCES "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_DetailZweckbestSpielSportanlage" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_SpielSportanlage_FP_DetailSpielSportanlage2"
    FOREIGN KEY ("weitereDetailZweckbestimmung1" )
    REFERENCES "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_DetailZweckbestSpielSportanlage" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_SpielSportanlage_FP_Objekt1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Basisobjekte"."FP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE);

CREATE INDEX "idx_fk_FP_SpielSportanlage_XP_ZweckSpielSportanlage1" ON "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_SpielSportanlage" ("zweckbestimmung") ;
CREATE INDEX "idx_fk_FP_SpielSportanlage_XP_ZweckSpielSportanlage2" ON "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_SpielSportanlage" ("weitereZweckbestimmung1") ;
CREATE INDEX "idx_fk_FP_SpielSportanlage_FP_DetaiSpielSportanlage1" ON "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_SpielSportanlage" ("detaillierteZweckbestimmung") ;
CREATE INDEX "idx_fk_FP_SpielSportanlage_FP_DetailSpielSportanlage2" ON "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_SpielSportanlage" ("weitereDetailZweckbestimmung1") ;
GRANT SELECT ON TABLE "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_SpielSportanlage" TO xp_gast;
GRANT ALL ON TABLE "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_SpielSportanlage" TO fp_user;
COMMENT ON TABLE  "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_SpielSportanlage" IS 'Darstellung von Flächen für Spiel- und Sportanlagen nach §5, Abs. 2, Nr. 2 BauGB.';
COMMENT ON COLUMN "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_SpielSportanlage"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_SpielSportanlage"."zweckbestimmung" IS 'Zweckbestimmung der Fläche';
COMMENT ON COLUMN "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_SpielSportanlage"."weitereZweckbestimmung1" IS 'Weitere Zweckbestimmung der Fläche.';
COMMENT ON COLUMN "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_SpielSportanlage"."detaillierteZweckbestimmung" IS 'Über eine CodeList definierte zusätzliche Zweckbestimmung';
COMMENT ON COLUMN "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_SpielSportanlage"."weitereDetailZweckbestimmung1" IS 'Über eine CodeList definierte zusätzliche Zweckbestimmung';
CREATE TRIGGER "change_to_FP_SpielSportanlage" BEFORE INSERT OR UPDATE OR DELETE ON "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_SpielSportanlage" FOR EACH ROW EXECUTE PROCEDURE "FP_Basisobjekte"."child_of_FP_Objekt"();

-- -----------------------------------------------------
-- Table "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_GemeinbedarfFlaeche"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_GemeinbedarfFlaeche" (
  "gid" INTEGER NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_GemeinbedarfFlaeche_FP_Gemeinbedarf1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_Gemeinbedarf" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("FP_Basisobjekte"."FP_Flaechenobjekt");

GRANT SELECT ON TABLE "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_GemeinbedarfFlaeche" TO xp_gast;
GRANT ALL ON TABLE "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_GemeinbedarfFlaeche" TO fp_user;
CREATE TRIGGER "change_to_FP_GemeinbedarfFlaeche" BEFORE INSERT OR UPDATE OR DELETE ON "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_GemeinbedarfFlaeche" FOR EACH ROW EXECUTE PROCEDURE "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."child_of_FP_Gemeinbedarf"();
CREATE TRIGGER "FP_GemeinbedarfFlaeche_RHR" BEFORE INSERT OR UPDATE ON "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_GemeinbedarfFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."positionFollowsRHR"();
SELECT "XP_Basisobjekte".registergeometrycolumn('','FP_Gemeinbedarf_Spiel_und_Sportanlagen','FP_GemeinbedarfFlaeche', 'position','MULTIPOLYGON',2, true);

-- -----------------------------------------------------
-- Table "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_GemeinbedarfLinie"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_GemeinbedarfLinie" (
  "gid" INTEGER NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_GemeinbedarfLinie_FP_Gemeinbedarf1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_Gemeinbedarf" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("FP_Basisobjekte"."FP_Linienobjekt");

GRANT SELECT ON TABLE "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_GemeinbedarfLinie" TO xp_gast;
GRANT ALL ON TABLE "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_GemeinbedarfLinie" TO fp_user;
CREATE TRIGGER "change_to_FP_GemeinbedarfLinie" BEFORE INSERT OR UPDATE OR DELETE ON "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_GemeinbedarfLinie" FOR EACH ROW EXECUTE PROCEDURE "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."child_of_FP_Gemeinbedarf"();
SELECT "XP_Basisobjekte".registergeometrycolumn('','FP_Gemeinbedarf_Spiel_und_Sportanlagen','FP_GemeinbedarfLinie', 'position','MULTILINESTRING',2, true);

-- -----------------------------------------------------
-- Table "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_GemeinbedarfPunkt"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_GemeinbedarfPunkt" (
  "gid" INTEGER NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_GemeinbedarfPunkt_FP_Gemeinbedarf1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_Gemeinbedarf" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("FP_Basisobjekte"."FP_Punktobjekt");

GRANT SELECT ON TABLE "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_GemeinbedarfPunkt" TO xp_gast;
GRANT ALL ON TABLE "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_GemeinbedarfPunkt" TO fp_user;
CREATE TRIGGER "change_to_FP_GemeinbedarfPunkt" BEFORE INSERT OR UPDATE OR DELETE ON "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_GemeinbedarfPunkt" FOR EACH ROW EXECUTE PROCEDURE "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."child_of_FP_Gemeinbedarf"();
SELECT "XP_Basisobjekte".registergeometrycolumn('','FP_Gemeinbedarf_Spiel_und_Sportanlagen','FP_GemeinbedarfPunkt', 'position','MULTIPOINT',2, true);

-- -----------------------------------------------------
-- Table "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_SpielSportanlageFlaeche"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_SpielSportanlageFlaeche" (
  "gid" INTEGER NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_SpielSportanlageFlaeche_FP_SpielSportanlage1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_SpielSportanlage" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("FP_Basisobjekte"."FP_Flaechenobjekt");

GRANT SELECT ON TABLE "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_SpielSportanlageFlaeche" TO xp_gast;
GRANT ALL ON TABLE "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_SpielSportanlageFlaeche" TO fp_user;
CREATE TRIGGER "change_to_FP_SpielSportanlageFlaeche" BEFORE INSERT OR UPDATE OR DELETE ON "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_SpielSportanlageFlaeche" FOR EACH ROW EXECUTE PROCEDURE "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."child_of_FP_SpielSportanlage"();
CREATE TRIGGER "FP_SpielSportanlageFlaeche_RHR" BEFORE INSERT OR UPDATE ON "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_SpielSportanlageFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."positionFollowsRHR"();
SELECT "XP_Basisobjekte".registergeometrycolumn('','FP_Gemeinbedarf_Spiel_und_Sportanlagen','FP_SpielSportanlageFlaeche', 'position','MULTIPOLYGON',2, true);

-- -----------------------------------------------------
-- Table "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_SpielSportanlageLinie"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_SpielSportanlageLinie" (
  "gid" INTEGER NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_SpielSportanlageLinie_FP_SpielSportanlage1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_SpielSportanlage" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("FP_Basisobjekte"."FP_Linienobjekt");

GRANT SELECT ON TABLE "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_SpielSportanlageLinie" TO xp_gast;
GRANT ALL ON TABLE "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_SpielSportanlageLinie" TO fp_user;
CREATE TRIGGER "change_to_FP_SpielSportanlageLinie" BEFORE INSERT OR UPDATE OR DELETE ON "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_SpielSportanlageLinie" FOR EACH ROW EXECUTE PROCEDURE "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."child_of_FP_SpielSportanlage"();
SELECT "XP_Basisobjekte".registergeometrycolumn('','FP_Gemeinbedarf_Spiel_und_Sportanlagen','FP_SpielSportanlageLinie', 'position','MULTILINESTRING',2, true);

-- -----------------------------------------------------
-- Table "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_SpielSportanlagePunkt"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_SpielSportanlagePunkt" (
  "gid" INTEGER NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_SpielSportanlagePunkt_FP_SpielSportanlage1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_SpielSportanlage" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("FP_Basisobjekte"."FP_Punktobjekt");

GRANT SELECT ON TABLE "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_SpielSportanlagePunkt" TO xp_gast;
GRANT ALL ON TABLE "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_SpielSportanlagePunkt" TO fp_user;
CREATE TRIGGER "change_to_FP_SpielSportanlagePunkt" BEFORE INSERT OR UPDATE OR DELETE ON "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_SpielSportanlagePunkt" FOR EACH ROW EXECUTE PROCEDURE "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."child_of_FP_SpielSportanlage"();
SELECT "XP_Basisobjekte".registergeometrycolumn('','FP_Gemeinbedarf_Spiel_und_Sportanlagen','FP_SpielSportanlagePunkt', 'position','MULTIPOINT',2, true);

-- -----------------------------------------------------
-- Table "FP_Landwirtschaft_Wald_und_Gruen"."FP_DetailZweckbestWaldFlaeche"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Landwirtschaft_Wald_und_Gruen"."FP_DetailZweckbestWaldFlaeche" (
  "Wert" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Wert") );
GRANT SELECT ON TABLE "FP_Landwirtschaft_Wald_und_Gruen"."FP_DetailZweckbestWaldFlaeche" TO xp_gast;
GRANT ALL ON TABLE "FP_Landwirtschaft_Wald_und_Gruen"."FP_DetailZweckbestWaldFlaeche" TO fp_user;

-- -----------------------------------------------------
-- Table "FP_Landwirtschaft_Wald_und_Gruen"."FP_WaldFlaeche"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Landwirtschaft_Wald_und_Gruen"."FP_WaldFlaeche" (
  "gid" INTEGER NOT NULL ,
  "zweckbestimmung" INTEGER NULL ,
  "weitereZweckbestimmung1" INTEGER NULL ,
  "weitereZweckbestimmung2" INTEGER NULL ,
  "detaillierteZweckbestimmung" INTEGER NULL ,
  "weitereDetailZweckbestimmung1" INTEGER NULL ,
  "weitereDetailZweckbestimmung2" INTEGER NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_WaldFlaeche_XP_ZweckbestimmungWald"
    FOREIGN KEY ("zweckbestimmung" )
    REFERENCES "XP_Enumerationen"."XP_ZweckbestimmungWald" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_WaldFlaeche_XP_ZweckbestimmungWald1"
    FOREIGN KEY ("weitereZweckbestimmung1" )
    REFERENCES "XP_Enumerationen"."XP_ZweckbestimmungWald" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_WaldFlaeche_XP_ZweckbestimmungWald2"
    FOREIGN KEY ("weitereZweckbestimmung2" )
    REFERENCES "XP_Enumerationen"."XP_ZweckbestimmungWald" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_WaldFlaeche_FP_DetailZweckbestWaldFlaeche1"
    FOREIGN KEY ("detaillierteZweckbestimmung" )
    REFERENCES "FP_Landwirtschaft_Wald_und_Gruen"."FP_DetailZweckbestWaldFlaeche" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_WaldFlaeche_FP_DetailZweckbestWaldFlaeche2"
    FOREIGN KEY ("weitereDetailZweckbestimmung1" )
    REFERENCES "FP_Landwirtschaft_Wald_und_Gruen"."FP_DetailZweckbestWaldFlaeche" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_WaldFlaeche_FP_DetailZweckbestWaldFlaeche3"
    FOREIGN KEY ("weitereDetailZweckbestimmung2" )
    REFERENCES "FP_Landwirtschaft_Wald_und_Gruen"."FP_DetailZweckbestWaldFlaeche" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_WaldFlaeche_FP_Objekt1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Basisobjekte"."FP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
    ON UPDATE CASCADE)
INHERITS ("FP_Basisobjekte"."FP_Flaechenobjekt");

CREATE INDEX "idx_fk_FP_WaldFlaeche_XP_ZweckbestimmungWald" ON "FP_Landwirtschaft_Wald_und_Gruen"."FP_WaldFlaeche" ("zweckbestimmung") ;
CREATE INDEX "idx_fk_FP_WaldFlaeche_XP_ZweckbestimmungWald1" ON "FP_Landwirtschaft_Wald_und_Gruen"."FP_WaldFlaeche" ("weitereZweckbestimmung1") ;
CREATE INDEX "idx_fk_FP_WaldFlaeche_XP_ZweckbestimmungWald2" ON "FP_Landwirtschaft_Wald_und_Gruen"."FP_WaldFlaeche" ("weitereZweckbestimmung2") ;
CREATE INDEX "idx_fk_FP_WaldFlaeche_FP_DetailZweckbestWaldFlaeche1" ON "FP_Landwirtschaft_Wald_und_Gruen"."FP_WaldFlaeche" ("detaillierteZweckbestimmung") ;
CREATE INDEX "idx_fk_FP_WaldFlaeche_FP_DetailZweckbestWaldFlaeche2" ON "FP_Landwirtschaft_Wald_und_Gruen"."FP_WaldFlaeche" ("weitereDetailZweckbestimmung1") ;
CREATE INDEX "idx_fk_FP_WaldFlaeche_FP_DetailZweckbestWaldFlaeche3" ON "FP_Landwirtschaft_Wald_und_Gruen"."FP_WaldFlaeche" ("weitereDetailZweckbestimmung2") ;
GRANT SELECT ON TABLE "FP_Landwirtschaft_Wald_und_Gruen"."FP_WaldFlaeche" TO xp_gast;
GRANT ALL ON TABLE "FP_Landwirtschaft_Wald_und_Gruen"."FP_WaldFlaeche" TO fp_user;
COMMENT ON TABLE  "FP_Landwirtschaft_Wald_und_Gruen"."FP_WaldFlaeche" IS 'Darstellung von Waldflächen nach §5, Abs. 2, Nr. 9b,';
COMMENT ON COLUMN  "FP_Landwirtschaft_Wald_und_Gruen"."FP_WaldFlaeche"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN  "FP_Landwirtschaft_Wald_und_Gruen"."FP_WaldFlaeche"."zweckbestimmung" IS 'Zweckbestimmung der Waldfläche.';
COMMENT ON COLUMN  "FP_Landwirtschaft_Wald_und_Gruen"."FP_WaldFlaeche"."weitereZweckbestimmung1" IS 'Weitere Zweckbestimmung der Waldfläche.';
COMMENT ON COLUMN  "FP_Landwirtschaft_Wald_und_Gruen"."FP_WaldFlaeche"."weitereZweckbestimmung2" IS 'Weitere Zweckbestimmung der Waldfläche.';
COMMENT ON COLUMN  "FP_Landwirtschaft_Wald_und_Gruen"."FP_WaldFlaeche"."detaillierteZweckbestimmung" IS 'Über eine CodeList definierte zusätzliche Zweckbestimmung';
COMMENT ON COLUMN  "FP_Landwirtschaft_Wald_und_Gruen"."FP_WaldFlaeche"."weitereDetailZweckbestimmung1" IS 'Über eine CodeList definierte zusätzliche Zweckbestimmung';
COMMENT ON COLUMN  "FP_Landwirtschaft_Wald_und_Gruen"."FP_WaldFlaeche"."weitereDetailZweckbestimmung2" IS 'Über eine CodeList definierte zusätzliche Zweckbestimmung';
CREATE TRIGGER "change_to_FP_WaldFlaeche" BEFORE INSERT OR UPDATE OR DELETE ON "FP_Landwirtschaft_Wald_und_Gruen"."FP_WaldFlaeche" FOR EACH ROW EXECUTE PROCEDURE "FP_Basisobjekte"."child_of_FP_Objekt"();
CREATE TRIGGER "flaechenschluss_FP_WaldFlaeche" BEFORE INSERT OR UPDATE OR DELETE ON "FP_Landwirtschaft_Wald_und_Gruen"."FP_WaldFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isFlaechenschlussobjekt"();
CREATE TRIGGER "FP_WaldFlaeche_RHR" BEFORE INSERT OR UPDATE ON "FP_Landwirtschaft_Wald_und_Gruen"."FP_WaldFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."positionFollowsRHR"();
SELECT "XP_Basisobjekte".registergeometrycolumn('','FP_Landwirtschaft_Wald_und_Gruen','FP_WaldFlaeche', 'position','MULTIPOLYGON',2, true);

-- -----------------------------------------------------
-- Table "FP_Landwirtschaft_Wald_und_Gruen"."FP_DetailZweckbestLandwirtschaftsFlaeche"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Landwirtschaft_Wald_und_Gruen"."FP_DetailZweckbestLandwirtschaftsFlaeche" (
  "Wert" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Wert") );
GRANT SELECT ON TABLE "FP_Landwirtschaft_Wald_und_Gruen"."FP_DetailZweckbestLandwirtschaftsFlaeche" TO xp_gast;
GRANT ALL ON TABLE "FP_Landwirtschaft_Wald_und_Gruen"."FP_DetailZweckbestLandwirtschaftsFlaeche" TO fp_user;

-- -----------------------------------------------------
-- Table "FP_Landwirtschaft_Wald_und_Gruen"."FP_LandwirtschaftsFlaeche"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Landwirtschaft_Wald_und_Gruen"."FP_LandwirtschaftsFlaeche" (
  "gid" INTEGER NOT NULL ,
  "zweckbestimmung" INTEGER NULL ,
  "weitereZweckbestimmung1" INTEGER NULL ,
  "weitereZweckbestimmung2" INTEGER NULL ,
  "weitereZweckbestimmung3" INTEGER NULL ,
  "detaillierteZweckbestimmung" INTEGER NULL ,
  "weitereDetailZweckbestimmung1" INTEGER NULL ,
  "weitereDetailZweckbestimmung2" INTEGER NULL ,
  "weitereDetailZweckbestimmung3" INTEGER NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_LandwirtschaftsFlaeche_FP_Objekt1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Basisobjekte"."FP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_LandwirtschaftsFlaeche_XP_ZweckbestimmungLandwirtschaft1"
    FOREIGN KEY ("zweckbestimmung" )
    REFERENCES "XP_Enumerationen"."XP_ZweckbestimmungLandwirtschaft" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_LandwirtschaftsFlaeche_XP_ZweckbestimmungLandwirtschaft2"
    FOREIGN KEY ("weitereZweckbestimmung1" )
    REFERENCES "XP_Enumerationen"."XP_ZweckbestimmungLandwirtschaft" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_LandwirtschaftsFlaeche_XP_ZweckbestimmungLandwirtschaft3"
    FOREIGN KEY ("weitereZweckbestimmung2" )
    REFERENCES "XP_Enumerationen"."XP_ZweckbestimmungLandwirtschaft" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_LandwirtschaftsFlaeche_XP_ZweckbestimmungLandwirtschaft4"
    FOREIGN KEY ("weitereZweckbestimmung3" )
    REFERENCES "XP_Enumerationen"."XP_ZweckbestimmungLandwirtschaft" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_LandwirtschaftsFlaeche_FP_DetailZweckbestLandwirtschaft1"
    FOREIGN KEY ("detaillierteZweckbestimmung" )
    REFERENCES "FP_Landwirtschaft_Wald_und_Gruen"."FP_DetailZweckbestLandwirtschaftsFlaeche" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_LandwirtschaftsFlaeche_FP_DetailZweckbestLandwirtschaft2"
    FOREIGN KEY ("weitereDetailZweckbestimmung1" )
    REFERENCES "FP_Landwirtschaft_Wald_und_Gruen"."FP_DetailZweckbestLandwirtschaftsFlaeche" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_LandwirtschaftsFlaeche_FP_DetailZweckbestLandwirtschaft3"
    FOREIGN KEY ("weitereDetailZweckbestimmung2" )
    REFERENCES "FP_Landwirtschaft_Wald_und_Gruen"."FP_DetailZweckbestLandwirtschaftsFlaeche" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_LandwirtschaftsFlaeche_FP_DetailZweckbestLandwirtschaft4"
    FOREIGN KEY ("weitereDetailZweckbestimmung3" )
    REFERENCES "FP_Landwirtschaft_Wald_und_Gruen"."FP_DetailZweckbestLandwirtschaftsFlaeche" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE)
INHERITS ("FP_Basisobjekte"."FP_Flaechenobjekt");

CREATE INDEX "idx_fk_FP_LandwirtschaftsFlaeche_XP_ZweckbestimmungLandwirtschaft1" ON "FP_Landwirtschaft_Wald_und_Gruen"."FP_LandwirtschaftsFlaeche" ("zweckbestimmung") ;
CREATE INDEX "idx_fk_FP_LandwirtschaftsFlaeche_XP_ZweckbestimmungLandwirtschaft2" ON "FP_Landwirtschaft_Wald_und_Gruen"."FP_LandwirtschaftsFlaeche" ("weitereZweckbestimmung1") ;
CREATE INDEX "idx_fk_FP_LandwirtschaftsFlaeche_XP_ZweckbestimmungLandwirtschaft3" ON "FP_Landwirtschaft_Wald_und_Gruen"."FP_LandwirtschaftsFlaeche" ("weitereZweckbestimmung2") ;
CREATE INDEX "idx_fk_FP_LandwirtschaftsFlaeche_XP_ZweckbestimmungLandwirtschaft4" ON "FP_Landwirtschaft_Wald_und_Gruen"."FP_LandwirtschaftsFlaeche" ("weitereZweckbestimmung3") ;
CREATE INDEX "idx_fk_FP_LandwirtschaftsFlaeche_FP_DetailZweckbestLandwirtschaft1" ON "FP_Landwirtschaft_Wald_und_Gruen"."FP_LandwirtschaftsFlaeche" ("detaillierteZweckbestimmung") ;
CREATE INDEX "idx_fk_FP_LandwirtschaftsFlaeche_FP_DetailZweckbestLandwirtschaft2" ON "FP_Landwirtschaft_Wald_und_Gruen"."FP_LandwirtschaftsFlaeche" ("weitereDetailZweckbestimmung1") ;
CREATE INDEX "idx_fk_FP_LandwirtschaftsFlaeche_FP_DetailZweckbestLandwirtschaft3" ON "FP_Landwirtschaft_Wald_und_Gruen"."FP_LandwirtschaftsFlaeche" ("weitereDetailZweckbestimmung2") ;
CREATE INDEX "idx_fk_FP_LandwirtschaftsFlaeche_FP_DetailZweckbestLandwirtschaft4" ON "FP_Landwirtschaft_Wald_und_Gruen"."FP_LandwirtschaftsFlaeche" ("weitereDetailZweckbestimmung3") ;
GRANT SELECT ON TABLE "FP_Landwirtschaft_Wald_und_Gruen"."FP_LandwirtschaftsFlaeche" TO xp_gast;
GRANT ALL ON TABLE "FP_Landwirtschaft_Wald_und_Gruen"."FP_LandwirtschaftsFlaeche" TO fp_user;
COMMENT ON TABLE  "FP_Landwirtschaft_Wald_und_Gruen"."FP_LandwirtschaftsFlaeche" IS 'Darstellung einer Landwirtschaftsfläche nach §5, Abs. 2, Nr. 9a.';
COMMENT ON COLUMN  "FP_Landwirtschaft_Wald_und_Gruen"."FP_LandwirtschaftsFlaeche"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN  "FP_Landwirtschaft_Wald_und_Gruen"."FP_LandwirtschaftsFlaeche"."zweckbestimmung" IS 'Zweckbestimmung der Fläche.';
COMMENT ON COLUMN  "FP_Landwirtschaft_Wald_und_Gruen"."FP_LandwirtschaftsFlaeche"."weitereZweckbestimmung1" IS 'Weitere Zweckbestimmung der Fläche.';
COMMENT ON COLUMN  "FP_Landwirtschaft_Wald_und_Gruen"."FP_LandwirtschaftsFlaeche"."weitereZweckbestimmung2" IS 'Weitere Zweckbestimmung der Fläche.';
COMMENT ON COLUMN  "FP_Landwirtschaft_Wald_und_Gruen"."FP_LandwirtschaftsFlaeche"."weitereZweckbestimmung3" IS 'Weitere Zweckbestimmung der Fläche.';
COMMENT ON COLUMN  "FP_Landwirtschaft_Wald_und_Gruen"."FP_LandwirtschaftsFlaeche"."detaillierteZweckbestimmung" IS 'Über eine CodeList definierte zusätzliche Zweckbestimmung';
COMMENT ON COLUMN  "FP_Landwirtschaft_Wald_und_Gruen"."FP_LandwirtschaftsFlaeche"."weitereDetailZweckbestimmung1" IS 'Über eine CodeList definierte zusätzliche Zweckbestimmung';
COMMENT ON COLUMN  "FP_Landwirtschaft_Wald_und_Gruen"."FP_LandwirtschaftsFlaeche"."weitereDetailZweckbestimmung2" IS 'Über eine CodeList definierte zusätzliche Zweckbestimmung';
COMMENT ON COLUMN  "FP_Landwirtschaft_Wald_und_Gruen"."FP_LandwirtschaftsFlaeche"."weitereDetailZweckbestimmung3" IS 'Über eine CodeList definierte zusätzliche Zweckbestimmung';
CREATE TRIGGER "change_to_FP_LandwirtschaftsFlaeche" BEFORE INSERT OR UPDATE OR DELETE ON "FP_Landwirtschaft_Wald_und_Gruen"."FP_LandwirtschaftsFlaeche" FOR EACH ROW EXECUTE PROCEDURE "FP_Basisobjekte"."child_of_FP_Objekt"();
CREATE TRIGGER "flaechenschluss_FP_LandwirtschaftsFlaeche" BEFORE INSERT OR UPDATE OR DELETE ON "FP_Landwirtschaft_Wald_und_Gruen"."FP_LandwirtschaftsFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isFlaechenschlussobjekt"();
CREATE TRIGGER "FP_LandwirtschaftsFlaeche_RHR" BEFORE INSERT OR UPDATE ON "FP_Landwirtschaft_Wald_und_Gruen"."FP_LandwirtschaftsFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."positionFollowsRHR"();
SELECT "XP_Basisobjekte".registergeometrycolumn('','FP_Landwirtschaft_Wald_und_Gruen','FP_LandwirtschaftsFlaeche', 'position','MULTIPOLYGON',2, true);

-- -----------------------------------------------------
-- Table "FP_Landwirtschaft_Wald_und_Gruen"."FP_DetailZweckbestGruen"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Landwirtschaft_Wald_und_Gruen"."FP_DetailZweckbestGruen" (
  "Wert" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Wert") );
GRANT SELECT ON TABLE "FP_Landwirtschaft_Wald_und_Gruen"."FP_DetailZweckbestGruen" TO xp_gast;
GRANT ALL ON TABLE "FP_Landwirtschaft_Wald_und_Gruen"."FP_DetailZweckbestGruen" TO fp_user;

-- -----------------------------------------------------
-- Table "FP_Landwirtschaft_Wald_und_Gruen"."FP_Gruen"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Landwirtschaft_Wald_und_Gruen"."FP_Gruen" (
  "gid" INTEGER NOT NULL ,
  "zweckbestimmung" INTEGER NULL ,
  "weitereZweckbestimmung1" INTEGER NULL ,
  "weitereZweckbestimmung2" INTEGER NULL ,
  "weitereZweckbestimmung3" INTEGER NULL ,
  "weitereZweckbestimmung4" INTEGER NULL ,
  "weitereZweckbestimmung5" INTEGER NULL ,
  "besondereZweckbestimmung" INTEGER NULL ,
  "weitereBesondZweckbestimmung1" INTEGER NULL ,
  "weitereBesondZweckbestimmung2" INTEGER NULL ,
  "weitereBesondZweckbestimmung3" INTEGER NULL ,
  "weitereBesondZweckbestimmung4" INTEGER NULL ,
  "weitereBesondZweckbestimmung5" INTEGER NULL ,
  "detaillierteZweckbestimmung" INTEGER NULL ,
  "weitereDetailZweckbestimmung1" INTEGER NULL ,
  "weitereDetailZweckbestimmung2" INTEGER NULL ,
  "weitereDetailZweckbestimmung3" INTEGER NULL ,
  "weitereDetailZweckbestimmung4" INTEGER NULL ,
  "weitereDetailZweckbestimmung5" INTEGER NULL ,
  "nutzungsform" INTEGER NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_Gruen_FP_Objekt1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Basisobjekte"."FP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_Gruen_XP_ZweckbestimmungGruen1"
    FOREIGN KEY ("zweckbestimmung" )
    REFERENCES "XP_Enumerationen"."XP_ZweckbestimmungGruen" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_Gruen_XP_ZweckbestimmungGruen2"
    FOREIGN KEY ("weitereZweckbestimmung1" )
    REFERENCES "XP_Enumerationen"."XP_ZweckbestimmungGruen" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_Gruen_XP_ZweckbestimmungGruen3"
    FOREIGN KEY ("weitereZweckbestimmung2" )
    REFERENCES "XP_Enumerationen"."XP_ZweckbestimmungGruen" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_Gruen_XP_ZweckbestimmungGruen4"
    FOREIGN KEY ("weitereZweckbestimmung3" )
    REFERENCES "XP_Enumerationen"."XP_ZweckbestimmungGruen" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_Gruen_XP_ZweckbestimmungGruen5"
    FOREIGN KEY ("weitereZweckbestimmung4" )
    REFERENCES "XP_Enumerationen"."XP_ZweckbestimmungGruen" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_Gruen_XP_ZweckbestimmungGruen6"
    FOREIGN KEY ("weitereZweckbestimmung5" )
    REFERENCES "XP_Enumerationen"."XP_ZweckbestimmungGruen" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_Gruen_XP_BesondereZweckbestimmungGruen1"
    FOREIGN KEY ("besondereZweckbestimmung" )
    REFERENCES "XP_Enumerationen"."XP_BesondereZweckbestimmungGruen" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_Gruen_XP_BesondereZweckbestimmungGruen2"
    FOREIGN KEY ("weitereBesondZweckbestimmung1" )
    REFERENCES "XP_Enumerationen"."XP_BesondereZweckbestimmungGruen" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_Gruen_XP_BesondereZweckbestimmungGruen3"
    FOREIGN KEY ("weitereBesondZweckbestimmung2" )
    REFERENCES "XP_Enumerationen"."XP_BesondereZweckbestimmungGruen" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_Gruen_XP_BesondereZweckbestimmungGruen4"
    FOREIGN KEY ("weitereBesondZweckbestimmung3" )
    REFERENCES "XP_Enumerationen"."XP_BesondereZweckbestimmungGruen" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_Gruen_XP_BesondereZweckbestimmungGruen5"
    FOREIGN KEY ("weitereBesondZweckbestimmung4" )
    REFERENCES "XP_Enumerationen"."XP_BesondereZweckbestimmungGruen" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_Gruen_XP_BesondereZweckbestimmungGruen6"
    FOREIGN KEY ("weitereBesondZweckbestimmung5" )
    REFERENCES "XP_Enumerationen"."XP_BesondereZweckbestimmungGruen" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_Gruen_FP_DetailZweckbestGruen1"
    FOREIGN KEY ("detaillierteZweckbestimmung" )
    REFERENCES "FP_Landwirtschaft_Wald_und_Gruen"."FP_DetailZweckbestGruen" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_Gruen_FP_DetailZweckbestGruen2"
    FOREIGN KEY ("weitereDetailZweckbestimmung1" )
    REFERENCES "FP_Landwirtschaft_Wald_und_Gruen"."FP_DetailZweckbestGruen" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_Gruen_FP_DetailZweckbestGruen3"
    FOREIGN KEY ("weitereDetailZweckbestimmung2" )
    REFERENCES "FP_Landwirtschaft_Wald_und_Gruen"."FP_DetailZweckbestGruen" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_Gruen_FP_DetailZweckbestGruen4"
    FOREIGN KEY ("weitereDetailZweckbestimmung3" )
    REFERENCES "FP_Landwirtschaft_Wald_und_Gruen"."FP_DetailZweckbestGruen" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_Gruen_FP_DetailZweckbestGruen5"
    FOREIGN KEY ("weitereDetailZweckbestimmung4" )
    REFERENCES "FP_Landwirtschaft_Wald_und_Gruen"."FP_DetailZweckbestGruen" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_Gruen_FP_DetailZweckbestGruen6"
    FOREIGN KEY ("weitereDetailZweckbestimmung5" )
    REFERENCES "FP_Landwirtschaft_Wald_und_Gruen"."FP_DetailZweckbestGruen" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_Gruen_XP_Nutzungsform1"
    FOREIGN KEY ("nutzungsform" )
    REFERENCES "XP_Enumerationen"."XP_Nutzungsform" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE);

CREATE INDEX "idx_fk_FP_Gruen_XP_ZweckbestimmungGruen1" ON "FP_Landwirtschaft_Wald_und_Gruen"."FP_Gruen" ("zweckbestimmung") ;
CREATE INDEX "idx_fk_FP_Gruen_XP_ZweckbestimmungGruen2" ON "FP_Landwirtschaft_Wald_und_Gruen"."FP_Gruen" ("weitereZweckbestimmung1") ;
CREATE INDEX "idx_fk_FP_Gruen_XP_ZweckbestimmungGruen3" ON "FP_Landwirtschaft_Wald_und_Gruen"."FP_Gruen" ("weitereZweckbestimmung2") ;
CREATE INDEX "idx_fk_FP_Gruen_XP_ZweckbestimmungGruen4" ON "FP_Landwirtschaft_Wald_und_Gruen"."FP_Gruen" ("weitereZweckbestimmung3") ;
CREATE INDEX "idx_fk_FP_Gruen_XP_ZweckbestimmungGruen5" ON "FP_Landwirtschaft_Wald_und_Gruen"."FP_Gruen" ("weitereZweckbestimmung4") ;
CREATE INDEX "idx_fk_FP_Gruen_XP_ZweckbestimmungGruen6" ON "FP_Landwirtschaft_Wald_und_Gruen"."FP_Gruen" ("weitereZweckbestimmung5") ;
CREATE INDEX "idx_fk_FP_Gruen_XP_BesondereZweckbestimmungGruen1" ON "FP_Landwirtschaft_Wald_und_Gruen"."FP_Gruen" ("besondereZweckbestimmung") ;
CREATE INDEX "idx_fk_FP_Gruen_XP_BesondereZweckbestimmungGruen2" ON "FP_Landwirtschaft_Wald_und_Gruen"."FP_Gruen" ("weitereBesondZweckbestimmung1") ;
CREATE INDEX "idx_fk_FP_Gruen_XP_BesondereZweckbestimmungGruen3" ON "FP_Landwirtschaft_Wald_und_Gruen"."FP_Gruen" ("weitereBesondZweckbestimmung2") ;
CREATE INDEX "idx_fk_FP_Gruen_XP_BesondereZweckbestimmungGruen4" ON "FP_Landwirtschaft_Wald_und_Gruen"."FP_Gruen" ("weitereBesondZweckbestimmung3") ;
CREATE INDEX "idx_fk_FP_Gruen_XP_BesondereZweckbestimmungGruen5" ON "FP_Landwirtschaft_Wald_und_Gruen"."FP_Gruen" ("weitereBesondZweckbestimmung4") ;
CREATE INDEX "idx_fk_FP_Gruen_XP_BesondereZweckbestimmungGruen6" ON "FP_Landwirtschaft_Wald_und_Gruen"."FP_Gruen" ("weitereBesondZweckbestimmung5") ;
CREATE INDEX "idx_fk_FP_Gruen_FP_DetailZweckbestGruen1" ON "FP_Landwirtschaft_Wald_und_Gruen"."FP_Gruen" ("detaillierteZweckbestimmung") ;
CREATE INDEX "idx_fk_FP_Gruen_FP_DetailZweckbestGruen2" ON "FP_Landwirtschaft_Wald_und_Gruen"."FP_Gruen" ("weitereDetailZweckbestimmung1") ;
CREATE INDEX "idx_fk_FP_Gruen_FP_DetailZweckbestGruen3" ON "FP_Landwirtschaft_Wald_und_Gruen"."FP_Gruen" ("weitereDetailZweckbestimmung2") ;
CREATE INDEX "idx_fk_FP_Gruen_FP_DetailZweckbestGruen4" ON "FP_Landwirtschaft_Wald_und_Gruen"."FP_Gruen" ("weitereDetailZweckbestimmung3") ;
CREATE INDEX "idx_fk_FP_Gruen_FP_DetailZweckbestGruen5" ON "FP_Landwirtschaft_Wald_und_Gruen"."FP_Gruen" ("weitereDetailZweckbestimmung4") ;
CREATE INDEX "idx_fk_FP_Gruen_FP_DetailZweckbestGruen6" ON "FP_Landwirtschaft_Wald_und_Gruen"."FP_Gruen" ("weitereDetailZweckbestimmung5") ;
CREATE INDEX "idx_fk_FP_Gruen_XP_Nutzungsform1" ON "FP_Landwirtschaft_Wald_und_Gruen"."FP_Gruen" ("nutzungsform") ;
GRANT SELECT ON TABLE "FP_Landwirtschaft_Wald_und_Gruen"."FP_Gruen" TO xp_gast;
GRANT ALL ON TABLE "FP_Landwirtschaft_Wald_und_Gruen"."FP_Gruen" TO fp_user;
COMMENT ON ON TABLE "FP_Landwirtschaft_Wald_und_Gruen"."FP_Gruen" IS 'Darstellung einer Grünfläche nach §5, Abs. 2, Nr. 5 BauGB';
COMMENT ON COLUMN  "FP_Landwirtschaft_Wald_und_Gruen"."FP_Gruen"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN  "FP_Landwirtschaft_Wald_und_Gruen"."FP_Gruen"."zweckbestimmung" IS 'Allgemeine Zweckbestimmung der Grünfläche.';
COMMENT ON COLUMN  "FP_Landwirtschaft_Wald_und_Gruen"."FP_Gruen"."weitereZweckbestimmung1" IS 'Weitere allgemeine Zweckbestimmung der Grünfläche.';
COMMENT ON COLUMN  "FP_Landwirtschaft_Wald_und_Gruen"."FP_Gruen"."weitereZweckbestimmung2" IS 'Weitere allgemeine Zweckbestimmung der Grünfläche.';
COMMENT ON COLUMN  "FP_Landwirtschaft_Wald_und_Gruen"."FP_Gruen"."weitereZweckbestimmung3" IS 'Weitere allgemeine Zweckbestimmung der Grünfläche.';
COMMENT ON COLUMN  "FP_Landwirtschaft_Wald_und_Gruen"."FP_Gruen"."weitereZweckbestimmung4" IS 'Weitere allgemeine Zweckbestimmung der Grünfläche.';
COMMENT ON COLUMN  "FP_Landwirtschaft_Wald_und_Gruen"."FP_Gruen"."weitereZweckbestimmung5" IS 'Weitere allgemeine Zweckbestimmung der Grünfläche.';
COMMENT ON COLUMN  "FP_Landwirtschaft_Wald_und_Gruen"."FP_Gruen"."besondereZweckbestimmung" IS 'Besondere Zweckbestimmung der Grünfläche, die die zugehörige allgemeine Zweckbestimmung detailliert oder ersetzt.';
COMMENT ON COLUMN  "FP_Landwirtschaft_Wald_und_Gruen"."FP_Gruen"."weitereBesondZweckbestimmung1" IS 'Weitere besondere Zweckbestimmung der Grünfläche, die die zugehörige allgemeine Zweckbestimmung detailliert oder ersetzt.';
COMMENT ON COLUMN  "FP_Landwirtschaft_Wald_und_Gruen"."FP_Gruen"."weitereBesondZweckbestimmung2" IS 'Weitere besondere Zweckbestimmung der Grünfläche, die die zugehörige allgemeine Zweckbestimmung detailliert oder ersetzt.';
COMMENT ON COLUMN  "FP_Landwirtschaft_Wald_und_Gruen"."FP_Gruen"."weitereBesondZweckbestimmung3" IS 'Weitere besondere Zweckbestimmung der Grünfläche, die die zugehörige allgemeine Zweckbestimmung detailliert oder ersetzt.';
COMMENT ON COLUMN  "FP_Landwirtschaft_Wald_und_Gruen"."FP_Gruen"."weitereBesondZweckbestimmung4" IS 'Weitere besondere Zweckbestimmung der Grünfläche, die die zugehörige allgemeine Zweckbestimmung detailliert oder ersetzt.';
COMMENT ON COLUMN  "FP_Landwirtschaft_Wald_und_Gruen"."FP_Gruen"."weitereBesondZweckbestimmung5" IS 'Weitere besondere Zweckbestimmung der Grünfläche, die die zugehörige allgemeine Zweckbestimmung detailliert oder ersetzt.';
COMMENT ON COLUMN  "FP_Landwirtschaft_Wald_und_Gruen"."FP_Gruen"."detaillierteZweckbestimmung" IS 'Über eine CodeList definierte zusätzliche Zweckbestimmung';
COMMENT ON COLUMN  "FP_Landwirtschaft_Wald_und_Gruen"."FP_Gruen"."weitereDetailZweckbestimmung1" IS 'Über eine CodeList definierte zusätzliche Zweckbestimmung';
COMMENT ON COLUMN  "FP_Landwirtschaft_Wald_und_Gruen"."FP_Gruen"."weitereDetailZweckbestimmung2" IS 'Über eine CodeList definierte zusätzliche Zweckbestimmung';
COMMENT ON COLUMN  "FP_Landwirtschaft_Wald_und_Gruen"."FP_Gruen"."weitereDetailZweckbestimmung3" IS 'Über eine CodeList definierte zusätzliche Zweckbestimmung';
COMMENT ON COLUMN  "FP_Landwirtschaft_Wald_und_Gruen"."FP_Gruen"."weitereDetailZweckbestimmung4" IS 'Über eine CodeList definierte zusätzliche Zweckbestimmung';
COMMENT ON COLUMN  "FP_Landwirtschaft_Wald_und_Gruen"."FP_Gruen"."weitereDetailZweckbestimmung5" IS 'Über eine CodeList definierte zusätzliche Zweckbestimmung';
CREATE TRIGGER "change_to_FP_Gruen" BEFORE INSERT OR UPDATE OR DELETE ON "FP_Landwirtschaft_Wald_und_Gruen"."FP_Gruen" FOR EACH ROW EXECUTE PROCEDURE "FP_Basisobjekte"."child_of_FP_Objekt"();

-- -----------------------------------------------------
-- Table "FP_Landwirtschaft_Wald_und_Gruen"."FP_GruenFlaeche"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Landwirtschaft_Wald_und_Gruen"."FP_GruenFlaeche" (
  "gid" INTEGER NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_GruenFlaeche_FP_Gruen1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Landwirtschaft_Wald_und_Gruen"."FP_Gruen" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("FP_Basisobjekte"."FP_Flaechenobjekt");

GRANT SELECT ON TABLE "FP_Landwirtschaft_Wald_und_Gruen"."FP_GruenFlaeche" TO xp_gast;
GRANT ALL ON TABLE "FP_Landwirtschaft_Wald_und_Gruen"."FP_GruenFlaeche" TO fp_user;
CREATE TRIGGER "change_to_FP_GruenFlaeche" BEFORE INSERT OR UPDATE OR DELETE ON "FP_Landwirtschaft_Wald_und_Gruen"."FP_GruenFlaeche" FOR EACH ROW EXECUTE PROCEDURE "FP_Landwirtschaft_Wald_und_Gruen"."child_of_FP_Gruen"();
CREATE TRIGGER "FP_GruenFlaeche_RHR" BEFORE INSERT OR UPDATE ON "FP_Landwirtschaft_Wald_und_Gruen"."FP_GruenFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."positionFollowsRHR"();
SELECT "XP_Basisobjekte".registergeometrycolumn('','FP_Landwirtschaft_Wald_und_Gruen','FP_GruenFlaeche', 'position','MULTIPOLYGON',2, true);

-- -----------------------------------------------------
-- Table "FP_Landwirtschaft_Wald_und_Gruen"."FP_GruenLinie"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Landwirtschaft_Wald_und_Gruen"."FP_GruenLinie" (
  "gid" INTEGER NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_GruenLinie_FP_Gruen1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Landwirtschaft_Wald_und_Gruen"."FP_Gruen" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("FP_Basisobjekte"."FP_Linienobjekt");

GRANT SELECT ON TABLE "FP_Landwirtschaft_Wald_und_Gruen"."FP_GruenLinie" TO xp_gast;
GRANT ALL ON TABLE "FP_Landwirtschaft_Wald_und_Gruen"."FP_GruenLinie" TO fp_user;
CREATE TRIGGER "change_to_FP_GruenLinie" BEFORE INSERT OR UPDATE OR DELETE ON "FP_Landwirtschaft_Wald_und_Gruen"."FP_GruenLinie" FOR EACH ROW EXECUTE PROCEDURE "FP_Landwirtschaft_Wald_und_Gruen"."child_of_FP_Gruen"();
SELECT "XP_Basisobjekte".registergeometrycolumn('','FP_Landwirtschaft_Wald_und_Gruen','FP_GruenLinie', 'position','MULTILINESTRING',2, true);

-- -----------------------------------------------------
-- Table "FP_Landwirtschaft_Wald_und_Gruen"."FP_GruenPunkt"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Landwirtschaft_Wald_und_Gruen"."FP_GruenPunkt" (
  "gid" INTEGER NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_GruenPunkt_FP_Gruen1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Landwirtschaft_Wald_und_Gruen"."FP_Gruen" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("FP_Basisobjekte"."FP_Punktobjekt");

GRANT SELECT ON TABLE "FP_Landwirtschaft_Wald_und_Gruen"."FP_GruenPunkt" TO xp_gast;
GRANT ALL ON TABLE "FP_Landwirtschaft_Wald_und_Gruen"."FP_GruenPunkt" TO fp_user;
CREATE TRIGGER "change_to_FP_GruenPunkt" BEFORE INSERT OR UPDATE OR DELETE ON "FP_Landwirtschaft_Wald_und_Gruen"."FP_GruenPunkt" FOR EACH ROW EXECUTE PROCEDURE "FP_Landwirtschaft_Wald_und_Gruen"."child_of_FP_Gruen"();
SELECT "XP_Basisobjekte".registergeometrycolumn('','FP_Landwirtschaft_Wald_und_Gruen','FP_GruenPunkt', 'position','MULTIPOINT',2, true);

-- -----------------------------------------------------
-- Table "FP_Sonstiges"."FP_ZweckbestimmungGenerischeObjekte"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Sonstiges"."FP_ZweckbestimmungGenerischeObjekte" (
  "Wert" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Wert") );
GRANT SELECT ON TABLE "FP_Sonstiges"."FP_ZweckbestimmungGenerischeObjekte" TO xp_gast;
GRANT ALL ON TABLE "FP_Sonstiges"."FP_ZweckbestimmungGenerischeObjekte" TO fp_user;

-- -----------------------------------------------------
-- Table "FP_Sonstiges"."FP_GenerischesObjekt"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Sonstiges"."FP_GenerischesObjekt" (
  "gid" INTEGER NOT NULL ,
  "zweckbestimmung" INTEGER NULL ,
  "weitereZweckbestimmung1" INTEGER NULL ,
  "weitereZweckbestimmung2" INTEGER NULL ,
  "weitereZweckbestimmung3" INTEGER NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_GenerischesObjekt_FP_ZweckbestimmungGenerischeObjekte"
    FOREIGN KEY ("zweckbestimmung" )
    REFERENCES "FP_Sonstiges"."FP_ZweckbestimmungGenerischeObjekte" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT "fk_FP_GenerischesObjekt_FP_ZweckbestimmungGenerischeObjekte1"
    FOREIGN KEY ("weitereZweckbestimmung1" )
    REFERENCES "FP_Sonstiges"."FP_ZweckbestimmungGenerischeObjekte" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT "fk_FP_GenerischesObjekt_FP_ZweckbestimmungGenerischeObjekte2"
    FOREIGN KEY ("weitereZweckbestimmung2" )
    REFERENCES "FP_Sonstiges"."FP_ZweckbestimmungGenerischeObjekte" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT "fk_FP_GenerischesObjekt_FP_ZweckbestimmungGenerischeObjekte3"
    FOREIGN KEY ("weitereZweckbestimmung3" )
    REFERENCES "FP_Sonstiges"."FP_ZweckbestimmungGenerischeObjekte" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT "fk_FP_GenerischesObjekt_FP_Objekt1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Basisobjekte"."FP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE);

CREATE INDEX "idx_fk_FP_GenerischesObjekt_FP_ZweckbestimmungGenerischeObjekte" ON "FP_Sonstiges"."FP_GenerischesObjekt" ("zweckbestimmung") ;
CREATE INDEX "idx_fk_FP_GenerischesObjekt_FP_ZweckbestimmungGenerischeObjekte1" ON "FP_Sonstiges"."FP_GenerischesObjekt" ("weitereZweckbestimmung1") ;
CREATE INDEX "idx_fk_FP_GenerischesObjekt_FP_ZweckbestimmungGenerischeObjekte2" ON "FP_Sonstiges"."FP_GenerischesObjekt" ("weitereZweckbestimmung2") ;
CREATE INDEX "idx_fk_FP_GenerischesObjekt_FP_ZweckbestimmungGenerischeObjekte3" ON "FP_Sonstiges"."FP_GenerischesObjekt" ("weitereZweckbestimmung3") ;
GRANT SELECT ON TABLE "FP_Sonstiges"."FP_GenerischesObjekt" TO xp_gast;
GRANT ALL ON TABLE "FP_Sonstiges"."FP_GenerischesObjekt" TO fp_user;
COMMENT ON ON TABLE "FP_Sonstiges"."FP_GenerischesObjekt" IS 'Klasse zur Modellierung aller Inhalte des FPlans, die keine nachrichtliche Übernahmen aus anderen Rechts-bereichen sind, aber durch keine andere Klasse des FPlan-Fachschemas dargestellt werden können.';
COMMENT ON COLUMN  "FP_Sonstiges"."FP_GenerischesObjekt"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN  "FP_Sonstiges"."FP_GenerischesObjekt"."zweckbestimmung" IS 'Über eine ExternalCodeList definierte Zweckbestimmung des Objekts.';
COMMENT ON COLUMN  "FP_Sonstiges"."FP_GenerischesObjekt"."weitereZweckbestimmung1" IS 'Über eine ExternalCodeList definierte weitere Zweckbestimmung des Objekts.';
COMMENT ON COLUMN  "FP_Sonstiges"."FP_GenerischesObjekt"."weitereZweckbestimmung2" IS 'Über eine ExternalCodeList definierte weitere Zweckbestimmung des Objekts.';
COMMENT ON COLUMN  "FP_Sonstiges"."FP_GenerischesObjekt"."weitereZweckbestimmung3" IS 'Über eine ExternalCodeList definierte weitere Zweckbestimmung des Objekts.';
CREATE TRIGGER "change_to_FP_GenerischesObjekt" BEFORE INSERT OR UPDATE OR DELETE ON "FP_Sonstiges"."FP_GenerischesObjekt" FOR EACH ROW EXECUTE PROCEDURE "FP_Basisobjekte"."child_of_FP_Objekt"();

-- -----------------------------------------------------
-- Table "FP_Sonstiges"."FP_Kennzeichnung"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Sonstiges"."FP_Kennzeichnung" (
  "gid" INTEGER NOT NULL ,
  "zweckbestimmung" INTEGER NULL ,
  "weitereZweckbestimmung1" INTEGER NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_Kennzeichnung_XP_ZweckbestimmungKennzeichnung1"
    FOREIGN KEY ("zweckbestimmung" )
    REFERENCES "XP_Enumerationen"."XP_ZweckbestimmungKennzeichnung" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_Kennzeichnung_XP_ZweckbestimmungKennzeichnung2"
    FOREIGN KEY ("weitereZweckbestimmung1" )
    REFERENCES "XP_Enumerationen"."XP_ZweckbestimmungKennzeichnung" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_Kennzeichnung_FP_Objekt1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Basisobjekte"."FP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE);

CREATE INDEX "idx_fk_FP_Kennzeichnung_XP_ZweckbestimmungKennzeichnung1" ON "FP_Sonstiges"."FP_Kennzeichnung" ("zweckbestimmung") ;
CREATE INDEX "idx_fk_FP_Kennzeichnung_XP_ZweckbestimmungKennzeichnung2" ON "FP_Sonstiges"."FP_Kennzeichnung" ("weitereZweckbestimmung1") ;
GRANT SELECT ON TABLE "FP_Sonstiges"."FP_GenerischesObjekt" TO xp_gast;
GRANT ALL ON TABLE "FP_Sonstiges"."FP_GenerischesObjekt" TO fp_user;
COMMENT ON ON TABLE "FP_Sonstiges"."FP_Kennzeichnung" IS 'Kennzeichnungen gemäß §5 Abs. 3 BauGB.';
COMMENT ON COLUMN  "FP_Sonstiges"."FP_Kennzeichnung"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN  "FP_Sonstiges"."FP_Kennzeichnung"."zweckbestimmung" IS 'Zweckbestimmung der Kennzeichnung.';
COMMENT ON COLUMN  "FP_Sonstiges"."FP_Kennzeichnung"."weitereZweckbestimmung1" IS 'Weitere Zweckbestimmung der Kennzeichnung.';
CREATE TRIGGER "change_to_FP_Kennzeichnung" BEFORE INSERT OR UPDATE OR DELETE ON "FP_Sonstiges"."FP_Kennzeichnung" FOR EACH ROW EXECUTE PROCEDURE "FP_Basisobjekte"."child_of_FP_Objekt"();

-- -----------------------------------------------------
-- Table "FP_Sonstiges"."FP_GenerischesObjektFlaeche"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Sonstiges"."FP_GenerischesObjektFlaeche" (
  "gid" INTEGER NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_GenerischesObjektFlaeche_FP_GenerischesObjekt1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Sonstiges"."FP_GenerischesObjekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("FP_Basisobjekte"."FP_Flaechenobjekt");

GRANT SELECT ON TABLE "FP_Sonstiges"."FP_GenerischesObjektFlaeche" TO xp_gast;
GRANT ALL ON TABLE "FP_Sonstiges"."FP_GenerischesObjektFlaeche" TO fp_user;
CREATE TRIGGER "change_to_FP_GenerischesObjektFlaeche" BEFORE INSERT OR UPDATE OR DELETE ON "FP_Sonstiges"."FP_GenerischesObjektFlaeche" FOR EACH ROW EXECUTE PROCEDURE "FP_Sonstiges"."child_of_FP_GenerischesObjekt"();
CREATE TRIGGER "FP_GenerischesObjektFlaeche_RHR" BEFORE INSERT OR UPDATE ON "FP_Sonstiges"."FP_GenerischesObjektFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."positionFollowsRHR"();
SELECT "XP_Basisobjekte".registergeometrycolumn('','FP_Sonstiges','FP_GenerischesObjektFlaeche', 'position','MULTIPOLYGON',2, true);

-- -----------------------------------------------------
-- Table "FP_Sonstiges"."FP_GenerischesObjektLinie"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Sonstiges"."FP_GenerischesObjektLinie" (
  "gid" INTEGER NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_GenerischesObjektLinie_FP_GenerischesObjekt1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Sonstiges"."FP_GenerischesObjekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("FP_Basisobjekte"."FP_Linienobjekt");

GRANT SELECT ON TABLE "FP_Sonstiges"."FP_GenerischesObjektLinie" TO xp_gast;
GRANT ALL ON TABLE "FP_Sonstiges"."FP_GenerischesObjektLinie" TO fp_user;
CREATE TRIGGER "change_to_FP_GenerischesObjektLinie" BEFORE INSERT OR UPDATE OR DELETE ON "FP_Sonstiges"."FP_GenerischesObjektLinie" FOR EACH ROW EXECUTE PROCEDURE "FP_Sonstiges"."child_of_FP_GenerischesObjekt"();
SELECT "XP_Basisobjekte".registergeometrycolumn('','FP_Sonstiges','FP_GenerischesObjektLinie', 'position','MULTILINESTRING',2, true);

-- -----------------------------------------------------
-- Table "FP_Sonstiges"."FP_GenerischesObjektPunkt"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Sonstiges"."FP_GenerischesObjektPunkt" (
  "gid" INTEGER NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_GenerischesObjektPunkt_FP_GenerischesObjekt1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Sonstiges"."FP_GenerischesObjekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("FP_Basisobjekte"."FP_Punktobjekt");

GRANT SELECT ON TABLE "FP_Sonstiges"."FP_GenerischesObjektPunkt" TO xp_gast;
GRANT ALL ON TABLE "FP_Sonstiges"."FP_GenerischesObjektPunkt" TO fp_user;
CREATE TRIGGER "change_to_FP_GenerischesObjektPunkt" BEFORE INSERT OR UPDATE OR DELETE ON "FP_Sonstiges"."FP_GenerischesObjektPunkt" FOR EACH ROW EXECUTE PROCEDURE "FP_Sonstiges"."child_of_FP_GenerischesObjekt"();
SELECT "XP_Basisobjekte".registergeometrycolumn('','FP_Sonstiges','FP_GenerischesObjektPunkt', 'position','MULTIPOINT',2, true);

-- -----------------------------------------------------
-- Table "FP_Sonstiges"."FP_KennzeichnungFlaeche"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Sonstiges"."FP_KennzeichnungFlaeche" (
  "gid" INTEGER NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_KennzeichnungFlaeche_FP_Kennzeichnung1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Sonstiges"."FP_Kennzeichnung" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("FP_Basisobjekte"."FP_Flaechenobjekt");

GRANT SELECT ON TABLE "FP_Sonstiges"."FP_KennzeichnungFlaeche" TO xp_gast;
GRANT ALL ON TABLE "FP_Sonstiges"."FP_KennzeichnungFlaeche" TO fp_user;
CREATE TRIGGER "change_to_FP_KennzeichnungFlaeche" BEFORE INSERT OR UPDATE OR DELETE ON "FP_Sonstiges"."FP_KennzeichnungFlaeche" FOR EACH ROW EXECUTE PROCEDURE "FP_Sonstiges"."child_of_FP_Kennzeichnung"();
CREATE TRIGGER "FP_KennzeichnungFlaeche_RHR" BEFORE INSERT OR UPDATE ON "FP_Sonstiges"."FP_KennzeichnungFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."positionFollowsRHR"();
SELECT "XP_Basisobjekte".registergeometrycolumn('','FP_Sonstiges','FP_KennzeichnungFlaeche', 'position','MULTIPOLYGON',2, true);

-- -----------------------------------------------------
-- Table "FP_Sonstiges"."FP_KennzeichnungLinie"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Sonstiges"."FP_KennzeichnungLinie" (
  "gid" INTEGER NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_KennzeichnungLinie_FP_Kennzeichnung1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Sonstiges"."FP_Kennzeichnung" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("FP_Basisobjekte"."FP_Linienobjekt");

GRANT SELECT ON TABLE "FP_Sonstiges"."FP_KennzeichnungLinie" TO xp_gast;
GRANT ALL ON TABLE "FP_Sonstiges"."FP_KennzeichnungLinie" TO fp_user;
CREATE TRIGGER "change_to_FP_KennzeichnungLinie" BEFORE INSERT OR UPDATE OR DELETE ON "FP_Sonstiges"."FP_KennzeichnungLinie" FOR EACH ROW EXECUTE PROCEDURE "FP_Sonstiges"."child_of_FP_Kennzeichnung"();
SELECT "XP_Basisobjekte".registergeometrycolumn('','FP_Sonstiges','FP_KennzeichnungLinie', 'position','MULTILINESTRING',2, true);

-- -----------------------------------------------------
-- Table "FP_Sonstiges"."FP_KennzeichnungPunkt"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Sonstiges"."FP_KennzeichnungPunkt" (
  "gid" INTEGER NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_KennzeichnungPunkt_FP_Kennzeichnung1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Sonstiges"."FP_Kennzeichnung" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("FP_Basisobjekte"."FP_Punktobjekt");

GRANT SELECT ON TABLE "FP_Sonstiges"."FP_KennzeichnungPunkt" TO xp_gast;
GRANT ALL ON TABLE "FP_Sonstiges"."FP_KennzeichnungPunkt" TO fp_user;
CREATE TRIGGER "change_to_FP_KennzeichnungPunkt" BEFORE INSERT OR UPDATE OR DELETE ON "FP_Sonstiges"."FP_KennzeichnungPunkt" FOR EACH ROW EXECUTE PROCEDURE "FP_Sonstiges"."child_of_FP_Kennzeichnung"();
SELECT "XP_Basisobjekte".registergeometrycolumn('','FP_Sonstiges','FP_KennzeichnungPunkt', 'position','MULTIPOINT',2, true);

-- -----------------------------------------------------
-- Table "FP_Sonstiges"."FP_NutzungsbeschraenkungsFlaeche"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Sonstiges"."FP_NutzungsbeschraenkungsFlaeche" (
  "gid" INTEGER NOT NULL ,
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
CREATE TRIGGER "change_to_FP_NutzungsbeschraenkungsFlaeche" BEFORE INSERT OR UPDATE OR DELETE ON "FP_Sonstiges"."FP_NutzungsbeschraenkungsFlaeche" FOR EACH ROW EXECUTE PROCEDURE "FP_Basisobjekte"."child_of_FP_Objekt"();
CREATE TRIGGER "ueberlagerung_FP_NutzungsbeschraenkungsFlaeche" BEFORE INSERT OR UPDATE OR DELETE ON "FP_Sonstiges"."FP_NutzungsbeschraenkungsFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isUeberlagerungsobjekt"();
CREATE TRIGGER "FP_NutzungsbeschraenkungsFlaeche_RHR" BEFORE INSERT OR UPDATE ON "FP_Sonstiges"."FP_NutzungsbeschraenkungsFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."positionFollowsRHR"();
SELECT "XP_Basisobjekte".registergeometrycolumn('','FP_Sonstiges','FP_NutzungsbeschraenkungsFlaeche', 'position','MULTIPOLYGON',2, true);

-- -----------------------------------------------------
-- Table "FP_Sonstiges"."FP_ZweckbestimmungPrivilegiertesVorhaben"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Sonstiges"."FP_ZweckbestimmungPrivilegiertesVorhaben" (
  "Wert" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Wert") );
GRANT SELECT ON TABLE "FP_Sonstiges"."FP_ZweckbestimmungPrivilegiertesVorhaben" TO xp_gast;

-- -----------------------------------------------------
-- Table "FP_Sonstiges"."FP_BesondZweckbestPrivilegiertesVorhaben"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Sonstiges"."FP_BesondZweckbestPrivilegiertesVorhaben" (
  "Wert" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Wert") );
GRANT SELECT ON TABLE "FP_Sonstiges"."FP_BesondZweckbestPrivilegiertesVorhaben" TO xp_gast;

-- -----------------------------------------------------
-- Table "FP_Sonstiges"."FP_PrivilegiertesVorhaben"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Sonstiges"."FP_PrivilegiertesVorhaben" (
  "gid" INTEGER NOT NULL ,
  "zweckbestimmung" INTEGER NULL ,
  "weitereZweckbestimmung1" INTEGER NULL ,
  "weitereZweckbestimmung2" INTEGER NULL ,
  "besondereZweckbestimmung" INTEGER NULL ,
  "weitereBesondZweckbestimmung1" INTEGER NULL ,
  "weitereBesondZweckbestimmung2" INTEGER NULL ,
  "vorhaben" VARCHAR(255) NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_PrivilegiertesVorhaben_FP_Objekt1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Basisobjekte"."FP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_PrivilegiertesVorhaben_FP_Zweckbestimmung1"
    FOREIGN KEY ("zweckbestimmung" )
    REFERENCES "FP_Sonstiges"."FP_ZweckbestimmungPrivilegiertesVorhaben" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_PrivilegiertesVorhaben_FP_Zweckbestimmung2"
    FOREIGN KEY ("weitereZweckbestimmung1" )
    REFERENCES "FP_Sonstiges"."FP_ZweckbestimmungPrivilegiertesVorhaben" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_PrivilegiertesVorhaben_FP_Zweckbestimmung3"
    FOREIGN KEY ("weitereZweckbestimmung2" )
    REFERENCES "FP_Sonstiges"."FP_ZweckbestimmungPrivilegiertesVorhaben" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_PrivilegiertesVorhaben_FP_BesondZweckbest1"
    FOREIGN KEY ("besondereZweckbestimmung" )
    REFERENCES "FP_Sonstiges"."FP_BesondZweckbestPrivilegiertesVorhaben" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_PrivilegiertesVorhaben_FP_BesondZweckbest2"
    FOREIGN KEY ("weitereBesondZweckbestimmung1" )
    REFERENCES "FP_Sonstiges"."FP_BesondZweckbestPrivilegiertesVorhaben" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_PrivilegiertesVorhaben_FP_BesondZweckbest3"
    FOREIGN KEY ("weitereBesondZweckbestimmung2" )
    REFERENCES "FP_Sonstiges"."FP_BesondZweckbestPrivilegiertesVorhaben" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE);

CREATE INDEX "idx_fk_FP_PrivilegiertesVorhaben_FP_Zweckbestimmung1" ON "FP_Sonstiges"."FP_PrivilegiertesVorhaben" ("zweckbestimmung") ;
CREATE INDEX "idx_fk_FP_PrivilegiertesVorhaben_FP_Zweckbestimmung2" ON "FP_Sonstiges"."FP_PrivilegiertesVorhaben" ("weitereZweckbestimmung1") ;
CREATE INDEX "idx_fk_FP_PrivilegiertesVorhaben_FP_Zweckbestimmung3" ON "FP_Sonstiges"."FP_PrivilegiertesVorhaben" ("weitereZweckbestimmung2") ;
CREATE INDEX "idx_fk_FP_PrivilegiertesVorhaben_FP_BesondZweckbest1" ON "FP_Sonstiges"."FP_PrivilegiertesVorhaben" ("besondereZweckbestimmung") ;
CREATE INDEX "idx_fk_FP_PrivilegiertesVorhaben_FP_BesondZweckbest2" ON "FP_Sonstiges"."FP_PrivilegiertesVorhaben" ("weitereBesondZweckbestimmung1") ;
CREATE INDEX "idx_fk_FP_PrivilegiertesVorhaben_FP_BesondZweckbest3" ON "FP_Sonstiges"."FP_PrivilegiertesVorhaben" ("weitereBesondZweckbestimmung2") ;
GRANT SELECT ON TABLE "FP_Sonstiges"."FP_PrivilegiertesVorhaben" TO xp_gast;
GRANT ALL ON TABLE "FP_Sonstiges"."FP_PrivilegiertesVorhaben" TO fp_user;
COMMENT ON TABLE  "FP_Sonstiges"."FP_PrivilegiertesVorhaben" IS 'Standorte für privilegierte Außenbereichsvorhaben und für sonstige Anlagen in Außenbereichen gem. § 35 Abs. 1 und 2 BauGB.';
COMMENT ON COLUMN  "FP_Sonstiges"."FP_PrivilegiertesVorhaben"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN  "FP_Sonstiges"."FP_PrivilegiertesVorhaben"."zweckbestimmung" IS 'Zweckbestimmung des Vorhabens';
COMMENT ON COLUMN  "FP_Sonstiges"."FP_PrivilegiertesVorhaben"."weitereZweckbestimmung1" IS 'Weitere Zweckbestimmung des Vorhabens';
COMMENT ON COLUMN  "FP_Sonstiges"."FP_PrivilegiertesVorhaben"."weitereZweckbestimmung2" IS 'Weitere Zweckbestimmung des Vorhabens';
COMMENT ON COLUMN  "FP_Sonstiges"."FP_PrivilegiertesVorhaben"."besondereZweckbestimmung" IS 'Besondere Zweckbestimmung';
COMMENT ON COLUMN  "FP_Sonstiges"."FP_PrivilegiertesVorhaben"."weitereBesondZweckbestimmung1" IS 'Weitere besondere Zweckbestimmung';
COMMENT ON COLUMN  "FP_Sonstiges"."FP_PrivilegiertesVorhaben"."weitereBesondZweckbestimmung2" IS 'Weitere besondere Zweckbestimmung';
COMMENT ON COLUMN  "FP_Sonstiges"."FP_PrivilegiertesVorhaben"."vorhaben" IS 'Nähere Beschreibung des Vorhabens';
CREATE TRIGGER "change_to_FP_PrivilegiertesVorhaben" BEFORE INSERT OR UPDATE OR DELETE ON "FP_Sonstiges"."FP_PrivilegiertesVorhaben" FOR EACH ROW EXECUTE PROCEDURE "FP_Basisobjekte"."child_of_FP_Objekt"();

-- -----------------------------------------------------
-- Table "FP_Sonstiges"."FP_PrivilegiertesVorhabenFlaeche"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Sonstiges"."FP_PrivilegiertesVorhabenFlaeche" (
  "gid" INTEGER NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_PrivVorhaFlaeche_FP_PrivilegiertesVorhaben1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Sonstiges"."FP_PrivilegiertesVorhaben" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("FP_Basisobjekte"."FP_Flaechenobjekt");

GRANT SELECT ON TABLE "FP_Sonstiges"."FP_PrivilegiertesVorhabenFlaeche" TO xp_gast;
GRANT ALL ON TABLE "FP_Sonstiges"."FP_PrivilegiertesVorhabenFlaeche" TO fp_user;
CREATE TRIGGER "change_to_FP_PrivilegiertesVorhabenFlaeche" BEFORE INSERT OR UPDATE OR DELETE ON "FP_Sonstiges"."FP_PrivilegiertesVorhabenFlaeche" FOR EACH ROW EXECUTE PROCEDURE "FP_Sonstiges"."child_of_FP_PrivilegiertesVorhaben"();
CREATE TRIGGER "FP_PrivilegiertesVorhabenFlaeche_RHR" BEFORE INSERT OR UPDATE ON "FP_Sonstiges"."FP_PrivilegiertesVorhabenFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."positionFollowsRHR"();
SELECT "XP_Basisobjekte".registergeometrycolumn('','FP_Sonstiges','FP_PrivilegiertesVorhabenFlaeche', 'position','MULTIPOLYGON',2, true);

-- -----------------------------------------------------
-- Table "FP_Sonstiges"."FP_PrivilegiertesVorhabenLinie"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Sonstiges"."FP_PrivilegiertesVorhabenLinie" (
  "gid" INTEGER NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_PrivVorhaLinie_FP_PrivilegiertesVorhaben1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Sonstiges"."FP_PrivilegiertesVorhaben" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("FP_Basisobjekte"."FP_Linienobjekt");

GRANT SELECT ON TABLE "FP_Sonstiges"."FP_PrivilegiertesVorhabenLinie" TO xp_gast;
GRANT ALL ON TABLE "FP_Sonstiges"."FP_PrivilegiertesVorhabenLinie" TO fp_user;
CREATE TRIGGER "change_to_FP_PrivilegiertesVorhabenLinie" BEFORE INSERT OR UPDATE OR DELETE ON "FP_Sonstiges"."FP_PrivilegiertesVorhabenLinie" FOR EACH ROW EXECUTE PROCEDURE "FP_Sonstiges"."child_of_FP_PrivilegiertesVorhaben"();
SELECT "XP_Basisobjekte".registergeometrycolumn('','FP_Sonstiges','FP_PrivilegiertesVorhabenLinie', 'position','MULTILINESTRING',2, true);

-- -----------------------------------------------------
-- Table "FP_Sonstiges"."FP_PrivilegiertesVorhabenPunkt"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Sonstiges"."FP_PrivilegiertesVorhabenPunkt" (
  "gid" INTEGER NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_PrivVorhaPunkt_FP_PrivilegiertesVorhaben1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Sonstiges"."FP_PrivilegiertesVorhaben" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("FP_Basisobjekte"."FP_Punktobjekt");

GRANT SELECT ON TABLE "FP_Sonstiges"."FP_PrivilegiertesVorhabenPunkt" TO xp_gast;
GRANT ALL ON TABLE "FP_Sonstiges"."FP_PrivilegiertesVorhabenPunkt" TO fp_user;
CREATE TRIGGER "change_to_FP_PrivilegiertesVorhabenPunkt" BEFORE INSERT OR UPDATE OR DELETE ON "FP_Sonstiges"."FP_PrivilegiertesVorhabenPunkt" FOR EACH ROW EXECUTE PROCEDURE "FP_Sonstiges"."child_of_FP_PrivilegiertesVorhaben"();
SELECT "XP_Basisobjekte".registergeometrycolumn('','FP_Sonstiges','FP_PrivilegiertesVorhabenPunkt', 'position','MULTIPOINT',2, true);

-- -----------------------------------------------------
-- Table "FP_Sonstiges"."FP_VorbehalteFlaeche"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Sonstiges"."FP_VorbehalteFlaeche" (
  "gid" INTEGER NOT NULL ,
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
CREATE TRIGGER "change_to_FP_VorbehalteFlaeche" BEFORE INSERT OR UPDATE OR DELETE ON "FP_Sonstiges"."FP_VorbehalteFlaeche" FOR EACH ROW EXECUTE PROCEDURE "FP_Basisobjekte"."child_of_FP_Objekt"();
CREATE TRIGGER "FP_VorbehalteFlaeche_RHR" BEFORE INSERT OR UPDATE ON "FP_Sonstiges"."FP_VorbehalteFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."positionFollowsRHR"();
SELECT "XP_Basisobjekte".registergeometrycolumn('','FP_Sonstiges','FP_VorbehalteFlaeche', 'position','MULTIPOLYGON',2, true);

-- -----------------------------------------------------
-- Table "FP_Sonstiges"."FP_UnverbindlicheVormerkung"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Sonstiges"."FP_UnverbindlicheVormerkung" (
  "gid" INTEGER NOT NULL ,
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
CREATE TRIGGER "change_to_FP_UnverbindlicheVormerkung" BEFORE INSERT OR UPDATE OR DELETE ON "FP_Sonstiges"."FP_UnverbindlicheVormerkung" FOR EACH ROW EXECUTE PROCEDURE "FP_Basisobjekte"."child_of_FP_Objekt"();

-- -----------------------------------------------------
-- Table "FP_Sonstiges"."FP_UnverbindlicheVormerkungFlaeche"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Sonstiges"."FP_UnverbindlicheVormerkungFlaeche" (
  "gid" INTEGER NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_UnverVormerFlaeche_FP_UnverVormer1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Sonstiges"."FP_UnverbindlicheVormerkung" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("FP_Basisobjekte"."FP_Flaechenobjekt");

GRANT SELECT ON TABLE "FP_Sonstiges"."FP_UnverbindlicheVormerkungFlaeche" TO xp_gast;
GRANT ALL ON TABLE "FP_Sonstiges"."FP_UnverbindlicheVormerkungFlaeche" TO fp_user;
CREATE TRIGGER "change_to_FP_UnverbindlicheVormerkungFlaeche" BEFORE INSERT OR UPDATE OR DELETE ON "FP_Sonstiges"."FP_UnverbindlicheVormerkungFlaeche" FOR EACH ROW EXECUTE PROCEDURE "FP_Sonstiges"."child_of_FP_UnverbindlicheVormerkung"();
CREATE TRIGGER "FP_UnverbindlicheVormerkungFlaeche_RHR" BEFORE INSERT OR UPDATE ON "FP_Sonstiges"."FP_UnverbindlicheVormerkungFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."positionFollowsRHR"();
SELECT "XP_Basisobjekte".registergeometrycolumn('','FP_Sonstiges','FP_UnverbindlicheVormerkungFlaeche', 'position','MULTIPOLYGON',2, true);

-- -----------------------------------------------------
-- Table "FP_Sonstiges"."FP_UnverbindlicheVormerkungLinie"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Sonstiges"."FP_UnverbindlicheVormerkungLinie" (
  "gid" INTEGER NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_UnverVormerLinie_FP_UnverVormer1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Sonstiges"."FP_UnverbindlicheVormerkung" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("FP_Basisobjekte"."FP_Linieobjekt");

GRANT SELECT ON TABLE "FP_Sonstiges"."FP_UnverbindlicheVormerkungLinie" TO xp_gast;
GRANT ALL ON TABLE "FP_Sonstiges"."FP_UnverbindlicheVormerkungLinie" TO fp_user;
CREATE TRIGGER "change_to_FP_UnverbindlicheVormerkungLinie" BEFORE INSERT OR UPDATE OR DELETE ON "FP_Sonstiges"."FP_UnverbindlicheVormerkungLinie" FOR EACH ROW EXECUTE PROCEDURE "FP_Sonstiges"."child_of_FP_UnverbindlicheVormerkung"();
SELECT "XP_Basisobjekte".registergeometrycolumn('','FP_Sonstiges','FP_UnverbindlicheVormerkungLinie', 'position','MULTILINESTRING',2, true);

-- -----------------------------------------------------
-- Table "FP_Sonstiges"."FP_UnverbindlicheVormerkungPunkt"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Sonstiges"."FP_UnverbindlicheVormerkungPunkt" (
  "gid" INTEGER NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_UnverVormerPunkt_FP_UnverVormer1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Sonstiges"."FP_UnverbindlicheVormerkung" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("FP_Basisobjekte"."FP_Punktobjekt");

GRANT SELECT ON TABLE "FP_Sonstiges"."FP_UnverbindlicheVormerkungPunkt" TO xp_gast;
GRANT ALL ON TABLE "FP_Sonstiges"."FP_UnverbindlicheVormerkungPunkt" TO fp_user;
CREATE TRIGGER "change_to_FP_FP_UnverbindlicheVormerkungPunkt" BEFORE INSERT OR UPDATE OR DELETE ON "FP_Sonstiges"."FP_UnverbindlicheVormerkungPunkt" FOR EACH ROW EXECUTE PROCEDURE "FP_Sonstiges"."child_of_FP_UnverbindlicheVormerkung"();
SELECT "XP_Basisobjekte".registergeometrycolumn('','FP_Sonstiges','FP_UnverbindlicheVormerkungPunkt', 'position','MULTIPOINT',2, true);

-- -----------------------------------------------------
-- Table "FP_Sonstiges"."FP_TextlicheDarstellungsFlaeche"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Sonstiges"."FP_TextlicheDarstellungsFlaeche" (
  "gid" INTEGER NOT NULL ,
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
CREATE TRIGGER "change_to_FP_TextlicheDarstellungsFlaeche" BEFORE INSERT OR UPDATE OR DELETE ON "FP_Sonstiges"."FP_TextlicheDarstellungsFlaeche" FOR EACH ROW EXECUTE PROCEDURE "FP_Basisobjekte"."child_of_FP_Objekt"();
CREATE TRIGGER "ueberlagerung_FP_TextlicheDarstellungsFlaeche" BEFORE INSERT OR UPDATE OR DELETE ON "FP_Sonstiges"."FP_TextlicheDarstellungsFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isUeberlagerungsobjekt"();
CREATE TRIGGER "FP_TextlicheDarstellungsFlaeche_RHR" BEFORE INSERT OR UPDATE ON "FP_Sonstiges"."FP_TextlicheDarstellungsFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."positionFollowsRHR"();
SELECT "XP_Basisobjekte".registergeometrycolumn('','FP_Sonstiges','FP_TextlicheDarstellungsFlaeche', 'position','MULTIPOLYGON',2, true);

-- -----------------------------------------------------
-- Table "FP_Ver_und_Entsorgung"."FP_DetailZweckbestVerEntsorgung"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Ver_und_Entsorgung"."FP_DetailZweckbestVerEntsorgung" (
  "Wert" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Wert") );
GRANT SELECT ON TABLE "FP_Ver_und_Entsorgung"."FP_DetailZweckbestVerEntsorgung" TO xp_gast;
GRANT ALL ON TABLE "FP_Ver_und_Entsorgung"."FP_DetailZweckbestVerEntsorgung" TO fp_user;

-- -----------------------------------------------------
-- Table "FP_Ver_und_Entsorgung"."FP_VerEntsorgung"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Ver_und_Entsorgung"."FP_VerEntsorgung" (
  "gid" INTEGER NOT NULL ,
  "zweckbestimmung" INTEGER NULL ,
  "weitereZweckbestimmung1" INTEGER NULL ,
  "weitereZweckbestimmung2" INTEGER NULL ,
  "weitereZweckbestimmung3" INTEGER NULL ,
  "besondereZweckbestimmung" INTEGER NULL ,
  "weitereBesondZweckbestimmung1" INTEGER NULL ,
  "weitereBesondZweckbestimmung2" INTEGER NULL ,
  "weitereBesondZweckbestimmung3" INTEGER NULL ,
  "detaillierteZweckbestimmung" INTEGER NULL ,
  "weitereDetailZweckbestimmung1" INTEGER NULL ,
  "weitereDetailZweckbestimmung2" INTEGER NULL ,
  "weitereDetailZweckbestimmung3" INTEGER NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_VerEntsorgung_FP_Objekt"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Basisobjekte"."FP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_VerEntsorgung_XP_ZweckbestimmungVerEntsorgung1"
    FOREIGN KEY ("zweckbestimmung" )
    REFERENCES "XP_Enumerationen"."XP_ZweckbestimmungVerEntsorgung" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_VerEntsorgung_XP_ZweckbestimmungVerEntsorgung2"
    FOREIGN KEY ("weitereZweckbestimmung1" )
    REFERENCES "XP_Enumerationen"."XP_ZweckbestimmungVerEntsorgung" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_VerEntsorgung_XP_ZweckbestimmungVerEntsorgung3"
    FOREIGN KEY ("weitereZweckbestimmung2" )
    REFERENCES "XP_Enumerationen"."XP_ZweckbestimmungVerEntsorgung" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_VerEntsorgung_XP_ZweckbestimmungVerEntsorgung4"
    FOREIGN KEY ("weitereZweckbestimmung3" )
    REFERENCES "XP_Enumerationen"."XP_ZweckbestimmungVerEntsorgung" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_VerEntsorgung_XP_BesZweckbestVerEntsorgung1"
    FOREIGN KEY ("besondereZweckbestimmung" )
    REFERENCES "XP_Enumerationen"."XP_BesondereZweckbestimmungVerEntsorgung" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_VerEntsorgung_XP_BesZweckbestVerEntsorgung2"
    FOREIGN KEY ("weitereBesondZweckbestimmung1" )
    REFERENCES "XP_Enumerationen"."XP_BesondereZweckbestimmungVerEntsorgung" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_VerEntsorgung_XP_BesZweckbestVerEntsorgung3"
    FOREIGN KEY ("weitereBesondZweckbestimmung2" )
    REFERENCES "XP_Enumerationen"."XP_BesondereZweckbestimmungVerEntsorgung" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_VerEntsorgung_XP_BesZweckbestVerEntsorgung4"
    FOREIGN KEY ("weitereBesondZweckbestimmung3" )
    REFERENCES "XP_Enumerationen"."XP_BesondereZweckbestimmungVerEntsorgung" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_VerEntsorgung_FP_DetailZweckbestVerEntsorgung1"
    FOREIGN KEY ("detaillierteZweckbestimmung" )
    REFERENCES "FP_Ver_und_Entsorgung"."FP_DetailZweckbestVerEntsorgung" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_VerEntsorgung_FP_DetailZweckbestVerEntsorgung2"
    FOREIGN KEY ("weitereDetailZweckbestimmung1" )
    REFERENCES "FP_Ver_und_Entsorgung"."FP_DetailZweckbestVerEntsorgung" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_VerEntsorgung_FP_DetailZweckbestVerEntsorgung3"
    FOREIGN KEY ("weitereDetailZweckbestimmung2" )
    REFERENCES "FP_Ver_und_Entsorgung"."FP_DetailZweckbestVerEntsorgung" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_VerEntsorgung_FP_DetailZweckbestVerEntsorgung4"
    FOREIGN KEY ("weitereDetailZweckbestimmung3" )
    REFERENCES "FP_Ver_und_Entsorgung"."FP_DetailZweckbestVerEntsorgung" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE);

CREATE INDEX "idx_fk_FP_VerEntsorgung_XP_ZweckbestimmungVerEntsorgung1" ON "FP_Ver_und_Entsorgung"."FP_VerEntsorgung" ("zweckbestimmung") ;
CREATE INDEX "idx_fk_FP_VerEntsorgung_XP_ZweckbestimmungVerEntsorgung2" ON "FP_Ver_und_Entsorgung"."FP_VerEntsorgung" ("weitereZweckbestimmung1") ;
CREATE INDEX "idx_fk_FP_VerEntsorgung_XP_ZweckbestimmungVerEntsorgung3" ON "FP_Ver_und_Entsorgung"."FP_VerEntsorgung" ("weitereZweckbestimmung2") ;
CREATE INDEX "idx_fk_FP_VerEntsorgung_XP_ZweckbestimmungVerEntsorgung4" ON "FP_Ver_und_Entsorgung"."FP_VerEntsorgung" ("weitereZweckbestimmung3") ;
CREATE INDEX "idx_fk_FP_VerEntsorgung_XP_BesZweckbestVerEntsorgung1" ON "FP_Ver_und_Entsorgung"."FP_VerEntsorgung" ("besondereZweckbestimmung") ;
CREATE INDEX "idx_fk_FP_VerEntsorgung_XP_BesZweckbestVerEntsorgung2" ON "FP_Ver_und_Entsorgung"."FP_VerEntsorgung" ("weitereBesondZweckbestimmung1") ;
CREATE INDEX "idx_fk_FP_VerEntsorgung_XP_BesZweckbestVerEntsorgung3" ON "FP_Ver_und_Entsorgung"."FP_VerEntsorgung" ("weitereBesondZweckbestimmung2") ;
CREATE INDEX "idx_fk_FP_VerEntsorgung_XP_BesZweckbestVerEntsorgung4" ON "FP_Ver_und_Entsorgung"."FP_VerEntsorgung" ("weitereBesondZweckbestimmung3") ;
CREATE INDEX "idx_fk_FP_VerEntsorgung_FP_DetailZweckbestVerEntsorgung1" ON "FP_Ver_und_Entsorgung"."FP_VerEntsorgung" ("detaillierteZweckbestimmung") ;
CREATE INDEX "idx_fk_FP_VerEntsorgung_FP_DetailZweckbestVerEntsorgung2" ON "FP_Ver_und_Entsorgung"."FP_VerEntsorgung" ("weitereDetailZweckbestimmung1") ;
CREATE INDEX "idx_fk_FP_VerEntsorgung_FP_DetailZweckbestVerEntsorgung3" ON "FP_Ver_und_Entsorgung"."FP_VerEntsorgung" ("weitereDetailZweckbestimmung2") ;
CREATE INDEX "idx_fk_FP_VerEntsorgung_FP_DetailZweckbestVerEntsorgung4" ON "FP_Ver_und_Entsorgung"."FP_VerEntsorgung" ("weitereDetailZweckbestimmung3") ;
GRANT SELECT ON TABLE "FP_Ver_und_Entsorgung"."FP_VerEntsorgung" TO xp_gast;
GRANT ALL ON TABLE "FP_Ver_und_Entsorgung"."FP_VerEntsorgung" TO fp_user;
COMMENT ON TABLE  "FP_Ver_und_Entsorgung"."FP_VerEntsorgung" IS 'Flächen für Versorgungsanlagen, für die Abfallentsorgung und Abwasserbeseitigung sowie für Ablagerungen (§5, Abs. 2, Nr. 4 BauGB).';
COMMENT ON COLUMN  "FP_Ver_und_Entsorgung"."FP_VerEntsorgung"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN  "FP_Ver_und_Entsorgung"."FP_VerEntsorgung"."zweckbestimmung" IS 'Allgemeine Zweckbestimmung der Fläche.';
COMMENT ON COLUMN  "FP_Ver_und_Entsorgung"."FP_VerEntsorgung"."weitereZweckbestimmung1" IS 'Weitere allgemeine Zweckbestimmung der Fläche.';
COMMENT ON COLUMN  "FP_Ver_und_Entsorgung"."FP_VerEntsorgung"."weitereZweckbestimmung2" IS 'Weitere allgemeine Zweckbestimmung der Fläche.';
COMMENT ON COLUMN  "FP_Ver_und_Entsorgung"."FP_VerEntsorgung"."weitereZweckbestimmung3" IS 'Weitere allgemeine Zweckbestimmung der Fläche.';
COMMENT ON COLUMN  "FP_Ver_und_Entsorgung"."FP_VerEntsorgung"."besondereZweckbestimmung" IS 'Besondere Zweckbestimmung der Fläche, die die zugehörige allgemeine Zweckbestimmung detailliert oder ersetzt.';
COMMENT ON COLUMN  "FP_Ver_und_Entsorgung"."FP_VerEntsorgung"."weitereBesondZweckbestimmung1" IS 'Weitere besondere Zweckbestimmung der Fläche, die die zugehörige allgemeine Zweckbestimmung detailliert oder ersetzt.';
COMMENT ON COLUMN  "FP_Ver_und_Entsorgung"."FP_VerEntsorgung"."weitereBesondZweckbestimmung2" IS 'Weitere besondere Zweckbestimmung der Fläche, die die zugehörige allgemeine Zweckbestimmung detailliert oder ersetzt.';
COMMENT ON COLUMN  "FP_Ver_und_Entsorgung"."FP_VerEntsorgung"."weitereBesondZweckbestimmung3" IS 'Weitere besondere Zweckbestimmung der Fläche, die die zugehörige allgemeine Zweckbestimmung detailliert oder ersetzt.';
COMMENT ON COLUMN  "FP_Ver_und_Entsorgung"."FP_VerEntsorgung"."detaillierteZweckbestimmung" IS 'Über eine CodeList definierte zusätzliche Zweckbestimmung';
COMMENT ON COLUMN  "FP_Ver_und_Entsorgung"."FP_VerEntsorgung"."weitereDetailZweckbestimmung1" IS 'Über eine CodeList definierte zusätzliche Zweckbestimmung';
COMMENT ON COLUMN  "FP_Ver_und_Entsorgung"."FP_VerEntsorgung"."weitereDetailZweckbestimmung2" IS 'Über eine CodeList definierte zusätzliche Zweckbestimmung';
COMMENT ON COLUMN  "FP_Ver_und_Entsorgung"."FP_VerEntsorgung"."weitereDetailZweckbestimmung3" IS 'Über eine CodeList definierte zusätzliche Zweckbestimmung';
CREATE TRIGGER "change_to_FP_VerEntsorgung" BEFORE INSERT OR UPDATE OR DELETE ON "FP_Ver_und_Entsorgung"."FP_VerEntsorgung" FOR EACH ROW EXECUTE PROCEDURE "FP_Basisobjekte"."child_of_FP_Objekt"();

-- -----------------------------------------------------
-- Table "FP_Ver_und_Entsorgung"."FP_VerEntsorgungFlaeche"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Ver_und_Entsorgung"."FP_VerEntsorgungFlaeche" (
  "gid" INTEGER NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_VerEntsorgungFlaeche_FP_VerEntsorgung1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Ver_und_Entsorgung"."FP_VerEntsorgung" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("FP_Basisobjekte"."FP_Flaechenobjekt");

GRANT SELECT ON TABLE "FP_Ver_und_Entsorgung"."FP_VerEntsorgungFlaeche" TO xp_gast;
GRANT ALL ON TABLE "FP_Ver_und_Entsorgung"."FP_VerEntsorgungFlaeche" TO fp_user;
CREATE TRIGGER "change_to_FP_VerEntsorgungFlaeche" BEFORE INSERT OR UPDATE OR DELETE ON "FP_Ver_und_Entsorgung"."FP_VerEntsorgungFlaeche" FOR EACH ROW EXECUTE PROCEDURE "FP_Ver_und_Entsorgung"."child_of_FP_VerEntsorgung"();
CREATE TRIGGER "FP_VerEntsorgungFlaeche_RHR" BEFORE INSERT OR UPDATE ON "FP_Ver_und_Entsorgung"."FP_VerEntsorgungFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."positionFollowsRHR"();
SELECT "XP_Basisobjekte".registergeometrycolumn('','FP_Ver_und_Entsorgung','FP_VerEntsorgungFlaeche', 'position','MULTIPOLYGON',2, true);

-- -----------------------------------------------------
-- Table "FP_Ver_und_Entsorgung"."FP_VerEntsorgungLinie"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Ver_und_Entsorgung"."FP_VerEntsorgungLinie" (
  "gid" INTEGER NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_VerEntsorgungLinie_FP_VerEntsorgung1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Ver_und_Entsorgung"."FP_VerEntsorgung" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("FP_Basisobjekte"."FP_Linienobjekt");

GRANT SELECT ON TABLE "FP_Ver_und_Entsorgung"."FP_VerEntsorgungLinie" TO xp_gast;
GRANT ALL ON TABLE "FP_Ver_und_Entsorgung"."FP_VerEntsorgungLinie" TO fp_user;
CREATE TRIGGER "change_to_FP_VerEntsorgungLinie" BEFORE INSERT OR UPDATE OR DELETE ON "FP_Ver_und_Entsorgung"."FP_VerEntsorgungLinie" FOR EACH ROW EXECUTE PROCEDURE "FP_Ver_und_Entsorgung"."child_of_FP_VerEntsorgung"();
SELECT "XP_Basisobjekte".registergeometrycolumn('','FP_Ver_und_Entsorgung','FP_VerEntsorgungLinie', 'position','MULTILINESTRING',2, true);

-- -----------------------------------------------------
-- Table "FP_Ver_und_Entsorgung"."FP_VerEntsorgungPunkt"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Ver_und_Entsorgung"."FP_VerEntsorgungPunkt" (
  "gid" INTEGER NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_VerEntsorgungPunkt_FP_VerEntsorgung1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Ver_und_Entsorgung"."FP_VerEntsorgung" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("FP_Basisobjekte"."FP_Punktobjekt");

GRANT SELECT ON TABLE "FP_Ver_und_Entsorgung"."FP_VerEntsorgungPunkt" TO xp_gast;
GRANT ALL ON TABLE "FP_Ver_und_Entsorgung"."FP_VerEntsorgungPunkt" TO fp_user;
CREATE TRIGGER "change_to_FP_VerEntsorgungPunkt" BEFORE INSERT OR UPDATE OR DELETE ON "FP_Ver_und_Entsorgung"."FP_VerEntsorgungPunkt" FOR EACH ROW EXECUTE PROCEDURE "FP_Ver_und_Entsorgung"."child_of_FP_VerEntsorgung"();
SELECT "XP_Basisobjekte".registergeometrycolumn('','FP_Ver_und_Entsorgung','FP_VerEntsorgungPunkt', 'position','MULTIPOINT',2, true);

-- -----------------------------------------------------
-- Table "FP_Verkehr"."FP_ZweckbestimmungStrassenverkehr"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Verkehr"."FP_ZweckbestimmungStrassenverkehr" (
  "Wert" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Wert") );
GRANT SELECT ON TABLE "FP_Verkehr"."FP_ZweckbestimmungStrassenverkehr" TO xp_gast;

-- -----------------------------------------------------
-- Table "FP_Verkehr"."FP_BesondereZweckbestimmungStrassenverkehr"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Verkehr"."FP_BesondereZweckbestimmungStrassenverkehr" (
  "Wert" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Wert") );
GRANT SELECT ON TABLE "FP_Verkehr"."FP_BesondereZweckbestimmungStrassenverkehr" TO xp_gast;

-- -----------------------------------------------------
-- Table "FP_Verkehr"."FP_DetailZweckbestStrassenverkehr"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Verkehr"."FP_DetailZweckbestStrassenverkehr" (
  "Wert" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Wert") );
GRANT SELECT ON TABLE "FP_Verkehr"."FP_DetailZweckbestStrassenverkehr" TO xp_gast;
GRANT ALL ON TABLE "FP_Verkehr"."FP_DetailZweckbestStrassenverkehr" TO fp_user;

-- -----------------------------------------------------
-- Table "FP_Verkehr"."FP_Strassenverkehr"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Verkehr"."FP_Strassenverkehr" (
  "gid" INTEGER NOT NULL ,
  "zweckbestimmung" INTEGER NULL ,
  "besondereZweckbestimmung" INTEGER NULL ,
  "detaillierteZweckbestimmung" INTEGER NULL ,
  "nutzungsform" INTEGER NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_Strassenverkehr_FP_ZweckStrassenverkehr"
    FOREIGN KEY ("zweckbestimmung" )
    REFERENCES "FP_Verkehr"."FP_ZweckbestimmungStrassenverkehr" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_Strassenverkehr_FP_BesZweckStrassenverk1"
    FOREIGN KEY ("besondereZweckbestimmung" )
    REFERENCES "FP_Verkehr"."FP_BesondereZweckbestimmungStrassenverkehr" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_Strassenverkehr_FP_DetailZweckStrassenverkehr1"
    FOREIGN KEY ("detaillierteZweckbestimmung" )
    REFERENCES "FP_Verkehr"."FP_DetailZweckbestStrassenverkehr" ("Wert" )
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_Strassenverkehr_XP_Nutzungsform1"
    FOREIGN KEY ("nutzungsform" )
    REFERENCES "XP_Enumerationen"."XP_Nutzungsform" ("Wert" )
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
CREATE TRIGGER "change_to_FP_Strassenverkehr" BEFORE INSERT OR UPDATE OR DELETE ON "FP_Verkehr"."FP_Strassenverkehr" FOR EACH ROW EXECUTE PROCEDURE "FP_Basisobjekte"."child_of_FP_Objekt"();

-- -----------------------------------------------------
-- Table "FP_Verkehr"."FP_StrassenverkehrFlaeche"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Verkehr"."FP_StrassenverkehrFlaeche" (
  "gid" INTEGER NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_StrassenverkehrFlaeche_FP_Strassenverkehr1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Verkehr"."FP_Strassenverkehr" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("FP_Basisobjekte"."FP_Flaechenobjekt");

GRANT SELECT ON TABLE "FP_Verkehr"."FP_StrassenverkehrFlaeche" TO xp_gast;
GRANT ALL ON TABLE "FP_Verkehr"."FP_StrassenverkehrFlaeche" TO fp_user;
CREATE TRIGGER "change_to_FP_StrassenverkehrFlaeche" BEFORE INSERT OR UPDATE OR DELETE ON "FP_Verkehr"."FP_StrassenverkehrFlaeche" FOR EACH ROW EXECUTE PROCEDURE "FP_Verkehr"."child_of_FP_Strassenverkehr"();
CREATE TRIGGER "FP_StrassenverkehrFlaeche_RHR" BEFORE INSERT OR UPDATE ON "FP_Verkehr"."FP_StrassenverkehrFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."positionFollowsRHR"();
SELECT "XP_Basisobjekte".registergeometrycolumn('','FP_Verkehr','FP_StrassenverkehrFlaeche', 'position','MULTIPOLYGON',2, true);

-- -----------------------------------------------------
-- Table "FP_Verkehr"."FP_StrassenverkehrLinie"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Verkehr"."FP_StrassenverkehrLinie" (
  "gid" INTEGER NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_StrassenverkehrLinie_FP_Strassenverkehr1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Verkehr"."FP_Strassenverkehr" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("FP_Basisobjekte"."FP_Linienobjekt");

GRANT SELECT ON TABLE "FP_Verkehr"."FP_StrassenverkehrLinie" TO xp_gast;
GRANT ALL ON TABLE "FP_Verkehr"."FP_StrassenverkehrLinie" TO fp_user;
CREATE TRIGGER "change_to_FP_StrassenverkehrLinie" BEFORE INSERT OR UPDATE OR DELETE ON "FP_Verkehr"."FP_StrassenverkehrLinie" FOR EACH ROW EXECUTE PROCEDURE "FP_Verkehr"."child_of_FP_Strassenverkehr"();
SELECT "XP_Basisobjekte".registergeometrycolumn('','FP_Verkehr','FP_StrassenverkehrLinie', 'position','MULTILINESTRING',2, true);

-- -----------------------------------------------------
-- Table "FP_Verkehr"."FP_StrassenverkehrPunkt"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Verkehr"."FP_StrassenverkehrPunkt" (
  "gid" INTEGER NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_StrassenverkehrPunkt_FP_Strassenverkehr1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Verkehr"."FP_Strassenverkehr" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("FP_Basisobjekte"."FP_Punktobjekt");

GRANT SELECT ON TABLE "FP_Verkehr"."FP_StrassenverkehrPunkt" TO xp_gast;
GRANT ALL ON TABLE "FP_Verkehr"."FP_StrassenverkehrPunkt" TO fp_user;
CREATE TRIGGER "change_to_FP_StrassenverkehrPunkt" BEFORE INSERT OR UPDATE OR DELETE ON "FP_Verkehr"."FP_StrassenverkehrPunkt" FOR EACH ROW EXECUTE PROCEDURE "FP_Verkehr"."child_of_FP_Strassenverkehr"();
SELECT "XP_Basisobjekte".registergeometrycolumn('','FP_Verkehr','FP_StrassenverkehrPunkt', 'position','MULTIPOINT',2, true);

-- -----------------------------------------------------
-- Table "FP_Wasser"."FP_DetailZweckbestGewaesser"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Wasser"."FP_DetailZweckbestGewaesser" (
  "Wert" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Wert") );
GRANT SELECT ON TABLE "FP_Wasser"."FP_DetailZweckbestGewaesser" TO xp_gast;
GRANT ALL ON TABLE "FP_Wasser"."FP_DetailZweckbestGewaesser" TO fp_user;

-- -----------------------------------------------------
-- Table "FP_Wasser"."FP_Gewaesser"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Wasser"."FP_Gewaesser" (
  "gid" INTEGER NOT NULL ,
  "zweckbestimmung" INTEGER NOT NULL ,
  "detaillierteZweckbestimmung" INTEGER NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_Gewaesser_XP_ZweckbestimmungGewaesser"
    FOREIGN KEY ("zweckbestimmung" )
    REFERENCES "XP_Enumerationen"."XP_ZweckbestimmungGewaesser" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_Gewaesser_FP_DetailZweckbestGewaesser1"
    FOREIGN KEY ("detaillierteZweckbestimmung" )
    REFERENCES "FP_Wasser"."FP_DetailZweckbestGewaesser" ("Wert" )
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
CREATE TRIGGER "change_to_FP_Gewaesser" BEFORE INSERT OR UPDATE OR DELETE ON "FP_Wasser"."FP_Gewaesser" FOR EACH ROW EXECUTE PROCEDURE "FP_Basisobjekte"."child_of_FP_Objekt"();

-- -----------------------------------------------------
-- Table "FP_Wasser"."FP_DetailZweckbestWasserwirtschaft"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Wasser"."FP_DetailZweckbestWasserwirtschaft" (
  "Wert" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Wert") );
GRANT SELECT ON TABLE "FP_Wasser"."FP_DetailZweckbestWasserwirtschaft" TO xp_gast;
GRANT ALL ON TABLE "FP_Wasser"."FP_DetailZweckbestWasserwirtschaft" TO fp_user;

-- -----------------------------------------------------
-- Table "FP_Wasser"."FP_Wasserwirtschaft"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Wasser"."FP_Wasserwirtschaft" (
  "gid" INTEGER NOT NULL ,
  "zweckbestimmung" INTEGER NULL ,
  "detaillierteZweckbestimmung" INTEGER NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_Wasserwirtschaft_XP_ZweckbestimmungWasserwirtschaft1"
    FOREIGN KEY ("zweckbestimmung" )
    REFERENCES "XP_Enumerationen"."XP_ZweckbestimmungWasserwirtschaft" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT "fk_FP_Wasserwirtschaft_FP_DetailZweckbestWasserwirtschaft1"
    FOREIGN KEY ("detaillierteZweckbestimmung" )
    REFERENCES "FP_Wasser"."FP_DetailZweckbestWasserwirtschaft" ("Wert" )
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
CREATE TRIGGER "change_to_FP_Wasserwirtschaft" BEFORE INSERT OR UPDATE OR DELETE ON "FP_Wasser"."FP_Wasserwirtschaft" FOR EACH ROW EXECUTE PROCEDURE "FP_Basisobjekte"."child_of_FP_Objekt"();

-- -----------------------------------------------------
-- Table "FP_Wasser"."FP_GewaesserFlaeche"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Wasser"."FP_GewaesserFlaeche" (
  "gid" INTEGER NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_GewaesserFlaeche_FP_Gewaesser1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Wasser"."FP_Gewaesser" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("FP_Basisobjekte"."FP_Flaechenobjekt");

GRANT SELECT ON TABLE "FP_Wasser"."FP_GewaesserFlaeche" TO xp_gast;
GRANT ALL ON TABLE "FP_Wasser"."FP_GewaesserFlaeche" TO fp_user;
CREATE TRIGGER "change_to_FP_GewaesserFlaeche" BEFORE INSERT OR UPDATE OR DELETE ON "FP_Wasser"."FP_GewaesserFlaeche" FOR EACH ROW EXECUTE PROCEDURE "FP_Wasser"."child_of_FP_Gewaesser"();
CREATE TRIGGER "FP_GewaesserFlaeche_RHR" BEFORE INSERT OR UPDATE ON "FP_Wasser"."FP_GewaesserFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."positionFollowsRHR"();
SELECT "XP_Basisobjekte".registergeometrycolumn('','FP_Wasser','FP_GewaesserFlaeche', 'position','MULTIPOLYGON',2, true);

-- -----------------------------------------------------
-- Table "FP_Wasser"."FP_GewaesserLinie"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Wasser"."FP_GewaesserLinie" (
  "gid" INTEGER NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_GewaesserLinie_FP_Gewaesser1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Wasser"."FP_Gewaesser" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("FP_Basisobjekte"."FP_Linienobjekt");

GRANT SELECT ON TABLE "FP_Wasser"."FP_GewaesserLinie" TO xp_gast;
GRANT ALL ON TABLE "FP_Wasser"."FP_GewaesserLinie" TO fp_user;
CREATE TRIGGER "change_to_FP_GewaesserLinie" BEFORE INSERT OR UPDATE OR DELETE ON "FP_Wasser"."FP_GewaesserLinie" FOR EACH ROW EXECUTE PROCEDURE "FP_Wasser"."child_of_FP_Gewaesser"();
SELECT "XP_Basisobjekte".registergeometrycolumn('','FP_Wasser','FP_GewaesserLinie', 'position','MULTILINESTRING',2, true);

-- -----------------------------------------------------
-- Table "FP_Wasser"."FP_GewaesserPunkt"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Wasser"."FP_GewaesserPunkt" (
  "gid" INTEGER NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_GewaesserPunkt_FP_Gewaesser1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Wasser"."FP_Gewaesser" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("FP_Basisobjekte"."FP_Punktobjekt");

GRANT SELECT ON TABLE "FP_Wasser"."FP_GewaesserPunkt" TO xp_gast;
GRANT ALL ON TABLE "FP_Wasser"."FP_GewaesserPunkt" TO fp_user;
CREATE TRIGGER "change_to_FP_GewaesserPunkt" BEFORE INSERT OR UPDATE OR DELETE ON "FP_Wasser"."FP_GewaesserPunkt" FOR EACH ROW EXECUTE PROCEDURE "FP_Wasser"."child_of_FP_Gewaesser"();
SELECT "XP_Basisobjekte".registergeometrycolumn('','FP_Wasser','FP_GewaesserPunkt', 'position','MULTIPOINT',2, true);

-- -----------------------------------------------------
-- Table "FP_Wasser"."FP_WasserwirtschaftFlaeche"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Wasser"."FP_WasserwirtschaftFlaeche" (
  "gid" INTEGER NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_WasserwirtschaftFlaeche_FP_Wasserwirtschaft1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Wasser"."FP_Wasserwirtschaft" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("FP_Basisobjekte"."FP_Flaechenobjekt");

GRANT SELECT ON TABLE "FP_Wasser"."FP_WasserwirtschaftFlaeche" TO xp_gast;
GRANT ALL ON TABLE "FP_Wasser"."FP_WasserwirtschaftFlaeche" TO fp_user;
CREATE TRIGGER "change_to_FP_WasserwirtschaftFlaeche" BEFORE INSERT OR UPDATE OR DELETE ON "FP_Wasser"."FP_WasserwirtschaftFlaeche" FOR EACH ROW EXECUTE PROCEDURE "FP_Wasser"."child_of_FP_Wasserwirtschaft"();
CREATE TRIGGER "FP_WasserwirtschaftFlaeche_RHR" BEFORE INSERT OR UPDATE ON "FP_Wasser"."FP_WasserwirtschaftFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."positionFollowsRHR"();
SELECT "XP_Basisobjekte".registergeometrycolumn('','FP_Wasser','FP_WasserwirtschaftFlaeche', 'position','MULTIPOLYGON',2, true);

-- -----------------------------------------------------
-- Table "FP_Wasser"."FP_WasserwirtschaftLinie"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Wasser"."FP_WasserwirtschaftLinie" (
  "gid" INTEGER NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_WasserwirtschaftLinie_FP_Wasserwirtschaft1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Wasser"."FP_Wasserwirtschaft" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("FP_Basisobjekte"."FP_Linienobjekt");

GRANT SELECT ON TABLE "FP_Wasser"."FP_WasserwirtschaftLinie" TO xp_gast;
GRANT ALL ON TABLE "FP_Wasser"."FP_WasserwirtschaftLinie" TO fp_user;
CREATE TRIGGER "change_to_FP_WasserwirtschaftLinie" BEFORE INSERT OR UPDATE OR DELETE ON "FP_Wasser"."FP_WasserwirtschaftLinie" FOR EACH ROW EXECUTE PROCEDURE "FP_Wasser"."child_of_FP_Wasserwirtschaft"();
SELECT "XP_Basisobjekte".registergeometrycolumn('','FP_Wasser','FP_WasserwirtschaftLinie', 'position','MULTILINESTRING',2, true);

-- -----------------------------------------------------
-- Table "FP_Wasser"."FP_WasserwirtschaftPunkt"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Wasser"."FP_WasserwirtschaftPunkt" (
  "gid" INTEGER NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_WasserwirtschaftPunkt_FP_Wasserwirtschaft1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Wasser"."FP_Wasserwirtschaft" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("FP_Basisobjekte"."FP_Punktobjekt");

GRANT SELECT ON TABLE "FP_Wasser"."FP_WasserwirtschaftPunkt" TO xp_gast;
GRANT ALL ON TABLE "FP_Wasser"."FP_WasserwirtschaftPunkt" TO fp_user;
CREATE TRIGGER "change_to_FP_WasserwirtschaftPunkt" BEFORE INSERT OR UPDATE OR DELETE ON "FP_Wasser"."FP_WasserwirtschaftPunkt" FOR EACH ROW EXECUTE PROCEDURE "FP_Wasser"."child_of_FP_Wasserwirtschaft"();
SELECT "XP_Basisobjekte".registergeometrycolumn('','FP_Wasser','FP_WasserwirtschaftPunkt', 'position','MULTIPOINT',2, true);

-- -----------------------------------------------------
-- Table "FP_Aufschuettung_Abgrabung"."FP_AufschuettungsFlaeche"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Aufschuettung_Abgrabung"."FP_AufschuettungsFlaeche" (
  "gid" INTEGER NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_AufschuettungsFlaeche_FP_Objekt"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Basisobjekte"."FP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("FP_Basisobjekte"."FP_Flaechenobjekt");

GRANT SELECT ON TABLE "FP_Aufschuettung_Abgrabung"."FP_AufschuettungsFlaeche" TO xp_gast;
GRANT ALL ON TABLE "FP_Aufschuettung_Abgrabung"."FP_AufschuettungsFlaeche" TO fp_user;
COMMENT ON TABLE  "FP_Aufschuettung_Abgrabung"."FP_AufschuettungsFlaeche" IS 'Flächen für Aufschüttungen, Abgrabungen oder für die Gewinnung von Bodenschätzen (§5, Abs. 2, Nr. 8 BauGB). Hier: Flächen für Aufschüttungen.';
COMMENT ON COLUMN  "FP_Aufschuettung_Abgrabung"."FP_AufschuettungsFlaeche"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_FP_AufschuettungsFlaeche" BEFORE INSERT OR UPDATE OR DELETE ON "FP_Aufschuettung_Abgrabung"."FP_AufschuettungsFlaeche" FOR EACH ROW EXECUTE PROCEDURE "FP_Basisobjekte"."child_of_FP_Objekt"();
CREATE TRIGGER "FP_AufschuettungsFlaeche_RHR" BEFORE INSERT OR UPDATE ON "FP_Aufschuettung_Abgrabung"."FP_AufschuettungsFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."positionFollowsRHR"();
SELECT "XP_Basisobjekte".registergeometrycolumn('','FP_Aufschuettung_Abgrabung','FP_AufschuettungsFlaeche', 'position','MULTIPOLYGON',2, true);

-- -----------------------------------------------------
-- Table "FP_Aufschuettung_Abgrabung"."FP_AbgrabungsFlaeche"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Aufschuettung_Abgrabung"."FP_AbgrabungsFlaeche" (
  "gid" INTEGER NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_AbgrabungsFlaeche_FP_Objekt0"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Basisobjekte"."FP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("FP_Basisobjekte"."FP_Flaechenobjekt");

GRANT SELECT ON TABLE "FP_Aufschuettung_Abgrabung"."FP_AbgrabungsFlaeche" TO xp_gast;
GRANT ALL ON TABLE "FP_Aufschuettung_Abgrabung"."FP_AbgrabungsFlaeche" TO fp_user;
COMMENT ON TABLE  "FP_Aufschuettung_Abgrabung"."FP_AbgrabungsFlaeche" IS 'Flächen für Aufschüttungen, Abgrabungen oder für die Gewinnung von Bodenschätzen (§5, Abs. 2, Nr. 8 BauGB). Hier: Flächen für Abgrabungen';
COMMENT ON COLUMN  "FP_Aufschuettung_Abgrabung"."FP_AbgrabungsFlaeche"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_FP_AbgrabungsFlaeche" BEFORE INSERT OR UPDATE OR DELETE ON "FP_Aufschuettung_Abgrabung"."FP_AbgrabungsFlaeche" FOR EACH ROW EXECUTE PROCEDURE "FP_Basisobjekte"."child_of_FP_Objekt"();
CREATE TRIGGER "FP_AbgrabungsFlaeche_RHR" BEFORE INSERT OR UPDATE ON "FP_Aufschuettung_Abgrabung"."FP_AbgrabungsFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."positionFollowsRHR"();
SELECT "XP_Basisobjekte".registergeometrycolumn('','FP_Aufschuettung_Abgrabung','FP_AbgrabungsFlaeche', 'position','MULTIPOLYGON',2, true);

-- -----------------------------------------------------
-- Table "FP_Aufschuettung_Abgrabung"."FP_BodenschaetzeFlaeche"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Aufschuettung_Abgrabung"."FP_BodenschaetzeFlaeche" (
  "gid" INTEGER NOT NULL ,
  "abbaugut" VARCHAR(255) NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_FP_BodenschaetzeFlaeche_FP_Objekt1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Basisobjekte"."FP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("FP_Basisobjekte"."FP_Flaechenobjekt");

GRANT SELECT ON TABLE "FP_Aufschuettung_Abgrabung"."FP_BodenschaetzeFlaeche" TO xp_gast;
GRANT ALL ON TABLE "FP_Aufschuettung_Abgrabung"."FP_BodenschaetzeFlaeche" TO fp_user;
COMMENT ON TABLE  "FP_Aufschuettung_Abgrabung"."FP_BodenschaetzeFlaeche" IS 'Flächen für Aufschüttungen, Abgrabungen oder für die Gewinnung von Bodenschätzen (§5, Abs. 2, Nr. 8 BauGB. Hier: Flächen für Bodenschätze.';
COMMENT ON COLUMN  "FP_Aufschuettung_Abgrabung"."FP_BodenschaetzeFlaeche"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN  "FP_Aufschuettung_Abgrabung"."FP_BodenschaetzeFlaeche"."abbaugut" IS 'Bezeichnung des Abbauguts.';
CREATE TRIGGER "change_to_FP_BodenschaetzeFlaeche" BEFORE INSERT OR UPDATE OR DELETE ON "FP_Aufschuettung_Abgrabung"."FP_BodenschaetzeFlaeche" FOR EACH ROW EXECUTE PROCEDURE "FP_Basisobjekte"."child_of_FP_Objekt"();
CREATE TRIGGER "FP_BodenschaetzeFlaeche_RHR" BEFORE INSERT OR UPDATE ON "FP_Aufschuettung_Abgrabung"."FP_BodenschaetzeFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."positionFollowsRHR"();
SELECT "XP_Basisobjekte".registergeometrycolumn('','FP_Aufschuettung_Abgrabung','FP_BodenschaetzeFlaeche', 'position','MULTIPOLYGON',2, true);

-- *****************************************************
-- CREATE VIEWs
-- *****************************************************

-- -----------------------------------------------------
-- View "FP_Basisobjekte"."FP_Punktobjekte"
-- -----------------------------------------------------
CREATE  OR REPLACE VIEW "FP_Basisobjekte"."FP_Punktobjekte" AS
SELECT g.*, c.relname as "Objektart" 
FROM  "FP_Basisobjekte"."FP_Punktobjekt" g
JOIN pg_class c ON g.tableoid = c.oid;
GRANT SELECT ON TABLE "FP_Basisobjekte"."FP_Punktobjekte" TO xp_gast;
GRANT ALL ON TABLE "FP_Basisobjekte"."FP_Punktobjekte" TO xp_user;
SELECT "XP_Basisobjekte".registergeometrycolumn('','FP_Basisobjekte','FP_Punktobjekte', 'position','MULTIPOINT',2, false);

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
SELECT g.*, c.relname as "Objektart" 
FROM  "FP_Basisobjekte"."FP_Punktobjekt" g
JOIN pg_class c ON g.tableoid = c.oid;

GRANT SELECT ON TABLE "FP_Basisobjekte"."FP_Linienobjekte" TO xp_gast;
GRANT ALL ON TABLE "FP_Basisobjekte"."FP_Linienobjekte" TO xp_user;
SELECT "XP_Basisobjekte".registergeometrycolumn('','FP_Basisobjekte','FP_Linienobjekte', 'position','MULTILINESTRING',2, false);

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
SELECT g.*, c.relname as "Objektart" 
FROM  "FP_Basisobjekte"."FP_Punktobjekt" g
JOIN pg_class c ON g.tableoid = c.oid;

GRANT SELECT ON TABLE "FP_Basisobjekte"."FP_Flaechenobjekte" TO xp_gast;
GRANT ALL ON TABLE "FP_Basisobjekte"."FP_Flaechenobjekte" TO xp_user;
SELECT "XP_Basisobjekte".registergeometrycolumn('','FP_Basisobjekte','FP_Flaechenobjekte', 'position','MULTIPOLYGON',2, false);

CREATE OR REPLACE RULE _update AS
    ON UPDATE TO "FP_Basisobjekte"."FP_Flaechenobjekte" DO INSTEAD  UPDATE "FP_Basisobjekte"."FP_Flaechenobjekt" SET "position" = new."position"
  WHERE gid = old.gid;
CREATE OR REPLACE RULE _delete AS
    ON DELETE TO "FP_Basisobjekte"."FP_Flaechenobjekte" DO INSTEAD  DELETE FROM "FP_Basisobjekte"."FP_Flaechenobjekt"
  WHERE gid = old.gid;

-- *****************************************************
-- DATA
-- *****************************************************

-- -----------------------------------------------------
-- Data for table "FP_Basisobjekte"."FP_Verfahren"
-- -----------------------------------------------------
INSERT INTO "FP_Basisobjekte"."FP_Verfahren" ("Wert", "Bezeichner") VALUES ('1000', 'Normal');
INSERT INTO "FP_Basisobjekte"."FP_Verfahren" ("Wert", "Bezeichner") VALUES ('2000', 'Parag13');

-- -----------------------------------------------------
-- Data for table "FP_Basisobjekte"."FP_Rechtsstand"
-- -----------------------------------------------------
INSERT INTO "FP_Basisobjekte"."FP_Rechtsstand" ("Wert", "Bezeichner") VALUES ('1000', 'Aufstellungsbeschluss');
INSERT INTO "FP_Basisobjekte"."FP_Rechtsstand" ("Wert", "Bezeichner") VALUES ('2000', 'Entwurf');
INSERT INTO "FP_Basisobjekte"."FP_Rechtsstand" ("Wert", "Bezeichner") VALUES ('2100', 'FruehzeitigeBehoerdenBeteiligung');
INSERT INTO "FP_Basisobjekte"."FP_Rechtsstand" ("Wert", "Bezeichner") VALUES ('2200', 'FruehzeitigeOeffentlichkeitsBeteiligung');
INSERT INTO "FP_Basisobjekte"."FP_Rechtsstand" ("Wert", "Bezeichner") VALUES ('2300', 'BehoerdenBeteiligung');
INSERT INTO "FP_Basisobjekte"."FP_Rechtsstand" ("Wert", "Bezeichner") VALUES ('2400', 'OeffentlicheAuslegung');
INSERT INTO "FP_Basisobjekte"."FP_Rechtsstand" ("Wert", "Bezeichner") VALUES ('3000', 'Plan');
INSERT INTO "FP_Basisobjekte"."FP_Rechtsstand" ("Wert", "Bezeichner") VALUES ('4000', 'Wirksamkeit');
INSERT INTO "FP_Basisobjekte"."FP_Rechtsstand" ("Wert", "Bezeichner") VALUES ('5000', 'Untergegangen');

-- -----------------------------------------------------
-- Data for table "FP_Basisobjekte"."FP_PlanArt"
-- -----------------------------------------------------
INSERT INTO "FP_Basisobjekte"."FP_PlanArt" ("Wert", "Bezeichner") VALUES ('1000', 'FPlan');
INSERT INTO "FP_Basisobjekte"."FP_PlanArt" ("Wert", "Bezeichner") VALUES ('2000', 'GemeinsamerFPlan');
INSERT INTO "FP_Basisobjekte"."FP_PlanArt" ("Wert", "Bezeichner") VALUES ('3000', 'RegFPlan');
INSERT INTO "FP_Basisobjekte"."FP_PlanArt" ("Wert", "Bezeichner") VALUES ('4000', 'FPlanRegPlan');
INSERT INTO "FP_Basisobjekte"."FP_PlanArt" ("Wert", "Bezeichner") VALUES ('9999', 'Sonstiges');

-- -----------------------------------------------------
-- Data for table "FP_Basisobjekte"."FP_Rechtscharakter"
-- -----------------------------------------------------
INSERT INTO "FP_Basisobjekte"."FP_Rechtscharakter" ("Wert", "Bezeichner") VALUES ('1000', 'Darstellung');
INSERT INTO "FP_Basisobjekte"."FP_Rechtscharakter" ("Wert", "Bezeichner") VALUES ('3000', 'Hinweis');
INSERT INTO "FP_Basisobjekte"."FP_Rechtscharakter" ("Wert", "Bezeichner") VALUES ('4000', 'Vermerk');
INSERT INTO "FP_Basisobjekte"."FP_Rechtscharakter" ("Wert", "Bezeichner") VALUES ('5000', 'Kennzeichnung');

-- -----------------------------------------------------
-- Data for table "FP_Sonstiges"."FP_ZweckbestimmungPrivilegiertesVorhaben"
-- -----------------------------------------------------
INSERT INTO "FP_Sonstiges"."FP_ZweckbestimmungPrivilegiertesVorhaben" ("Wert", "Bezeichner") VALUES ('1000', 'LandForstwirtschaft');
INSERT INTO "FP_Sonstiges"."FP_ZweckbestimmungPrivilegiertesVorhaben" ("Wert", "Bezeichner") VALUES ('1200', 'OeffentlicheVersorgung');
INSERT INTO "FP_Sonstiges"."FP_ZweckbestimmungPrivilegiertesVorhaben" ("Wert", "Bezeichner") VALUES ('1400', 'OrtsgebundenerGewerbebetrieb');
INSERT INTO "FP_Sonstiges"."FP_ZweckbestimmungPrivilegiertesVorhaben" ("Wert", "Bezeichner") VALUES ('1600', 'BesonderesVorhaben');
INSERT INTO "FP_Sonstiges"."FP_ZweckbestimmungPrivilegiertesVorhaben" ("Wert", "Bezeichner") VALUES ('1800', 'ErneuerbareEnergie');
INSERT INTO "FP_Sonstiges"."FP_ZweckbestimmungPrivilegiertesVorhaben" ("Wert", "Bezeichner") VALUES ('2000', 'Kernenergie');
INSERT INTO "FP_Sonstiges"."FP_ZweckbestimmungPrivilegiertesVorhaben" ("Wert", "Bezeichner") VALUES ('9999', 'Sonstiges');

-- -----------------------------------------------------
-- Data for table "FP_Sonstiges"."FP_BesondZweckbestPrivilegiertesVorhaben"
-- -----------------------------------------------------
INSERT INTO "FP_Sonstiges"."FP_BesondZweckbestPrivilegiertesVorhaben" ("Wert", "Bezeichner") VALUES ('10000', 'Aussiedlerhof');
INSERT INTO "FP_Sonstiges"."FP_BesondZweckbestPrivilegiertesVorhaben" ("Wert", "Bezeichner") VALUES ('10001', 'Altenteil');
INSERT INTO "FP_Sonstiges"."FP_BesondZweckbestPrivilegiertesVorhaben" ("Wert", "Bezeichner") VALUES ('10002', 'Reiterhof');
INSERT INTO "FP_Sonstiges"."FP_BesondZweckbestPrivilegiertesVorhaben" ("Wert", "Bezeichner") VALUES ('10003', 'Gartenbaubetrieb');
INSERT INTO "FP_Sonstiges"."FP_BesondZweckbestPrivilegiertesVorhaben" ("Wert", "Bezeichner") VALUES ('10004', 'Baumschule');
INSERT INTO "FP_Sonstiges"."FP_BesondZweckbestPrivilegiertesVorhaben" ("Wert", "Bezeichner") VALUES ('12000', 'Wasser');
INSERT INTO "FP_Sonstiges"."FP_BesondZweckbestPrivilegiertesVorhaben" ("Wert", "Bezeichner") VALUES ('12001', 'Gas');
INSERT INTO "FP_Sonstiges"."FP_BesondZweckbestPrivilegiertesVorhaben" ("Wert", "Bezeichner") VALUES ('12002', 'Waerme');
INSERT INTO "FP_Sonstiges"."FP_BesondZweckbestPrivilegiertesVorhaben" ("Wert", "Bezeichner") VALUES ('12003', 'Elektrizitaet');
INSERT INTO "FP_Sonstiges"."FP_BesondZweckbestPrivilegiertesVorhaben" ("Wert", "Bezeichner") VALUES ('12004', 'Telekommunikation');
INSERT INTO "FP_Sonstiges"."FP_BesondZweckbestPrivilegiertesVorhaben" ("Wert", "Bezeichner") VALUES ('12005', 'Abwasser');
INSERT INTO "FP_Sonstiges"."FP_BesondZweckbestPrivilegiertesVorhaben" ("Wert", "Bezeichner") VALUES ('16000', 'BesondereUmgebungsAnforderung');
INSERT INTO "FP_Sonstiges"."FP_BesondZweckbestPrivilegiertesVorhaben" ("Wert", "Bezeichner") VALUES ('16001', 'NachteiligeUmgebungsWirkung');
INSERT INTO "FP_Sonstiges"."FP_BesondZweckbestPrivilegiertesVorhaben" ("Wert", "Bezeichner") VALUES ('16002', 'BesondereZweckbestimmung');
INSERT INTO "FP_Sonstiges"."FP_BesondZweckbestPrivilegiertesVorhaben" ("Wert", "Bezeichner") VALUES ('18000', 'Windenergie');
INSERT INTO "FP_Sonstiges"."FP_BesondZweckbestPrivilegiertesVorhaben" ("Wert", "Bezeichner") VALUES ('18001', 'Wasserenergie');
INSERT INTO "FP_Sonstiges"."FP_BesondZweckbestPrivilegiertesVorhaben" ("Wert", "Bezeichner") VALUES ('18002', 'Solarenergie');
INSERT INTO "FP_Sonstiges"."FP_BesondZweckbestPrivilegiertesVorhaben" ("Wert", "Bezeichner") VALUES ('18003', 'Biomasse');
INSERT INTO "FP_Sonstiges"."FP_BesondZweckbestPrivilegiertesVorhaben" ("Wert", "Bezeichner") VALUES ('20000', 'NutzungKernerergie');
INSERT INTO "FP_Sonstiges"."FP_BesondZweckbestPrivilegiertesVorhaben" ("Wert", "Bezeichner") VALUES ('20001', 'EntsorgungRadioaktiveAbfaelle');
INSERT INTO "FP_Sonstiges"."FP_BesondZweckbestPrivilegiertesVorhaben" ("Wert", "Bezeichner") VALUES ('99990', 'StandortEinzelhof');
INSERT INTO "FP_Sonstiges"."FP_BesondZweckbestPrivilegiertesVorhaben" ("Wert", "Bezeichner") VALUES ('99991', 'BebauteFlaecheAussenbereich');

-- -----------------------------------------------------
-- Data for table "FP_Verkehr"."FP_ZweckbestimmungStrassenverkehr"
-- -----------------------------------------------------
INSERT INTO "FP_Verkehr"."FP_ZweckbestimmungStrassenverkehr" ("Wert", "Bezeichner") VALUES ('1000', 'Autobahn');
INSERT INTO "FP_Verkehr"."FP_ZweckbestimmungStrassenverkehr" ("Wert", "Bezeichner") VALUES ('1200', 'Hauptverkehrsstrasse');
INSERT INTO "FP_Verkehr"."FP_ZweckbestimmungStrassenverkehr" ("Wert", "Bezeichner") VALUES ('1400', 'SonstigerVerkehrswegAnlage');
INSERT INTO "FP_Verkehr"."FP_ZweckbestimmungStrassenverkehr" ("Wert", "Bezeichner") VALUES ('1600', 'RuhenderVerkehr');
INSERT INTO "FP_Verkehr"."FP_ZweckbestimmungStrassenverkehr" ("Wert", "Bezeichner") VALUES ('9999', 'Sonstiges');

-- -----------------------------------------------------
-- Data for table "FP_Verkehr"."FP_BesondereZweckbestimmungStrassenverkehr"
-- -----------------------------------------------------
INSERT INTO "FP_Verkehr"."FP_BesondereZweckbestimmungStrassenverkehr" ("Wert", "Bezeichner") VALUES ('14000', 'VerkehrsberuhigterBereich');
INSERT INTO "FP_Verkehr"."FP_BesondereZweckbestimmungStrassenverkehr" ("Wert", "Bezeichner") VALUES ('14001', 'Platz');
INSERT INTO "FP_Verkehr"."FP_BesondereZweckbestimmungStrassenverkehr" ("Wert", "Bezeichner") VALUES ('14002', 'Fussgaengerbereich');
INSERT INTO "FP_Verkehr"."FP_BesondereZweckbestimmungStrassenverkehr" ("Wert", "Bezeichner") VALUES ('14003', 'RadFussweg');
INSERT INTO "FP_Verkehr"."FP_BesondereZweckbestimmungStrassenverkehr" ("Wert", "Bezeichner") VALUES ('14004', 'Radweg');
INSERT INTO "FP_Verkehr"."FP_BesondereZweckbestimmungStrassenverkehr" ("Wert", "Bezeichner") VALUES ('14005', 'Fussweg');
INSERT INTO "FP_Verkehr"."FP_BesondereZweckbestimmungStrassenverkehr" ("Wert", "Bezeichner") VALUES ('14006', 'Wanderweg');
INSERT INTO "FP_Verkehr"."FP_BesondereZweckbestimmungStrassenverkehr" ("Wert", "Bezeichner") VALUES ('14007', 'ReitKutschweg');
INSERT INTO "FP_Verkehr"."FP_BesondereZweckbestimmungStrassenverkehr" ("Wert", "Bezeichner") VALUES ('14008', 'Rastanlage');
INSERT INTO "FP_Verkehr"."FP_BesondereZweckbestimmungStrassenverkehr" ("Wert", "Bezeichner") VALUES ('14009', 'Busbahnhof');
INSERT INTO "FP_Verkehr"."FP_BesondereZweckbestimmungStrassenverkehr" ("Wert", "Bezeichner") VALUES ('14010', 'UeberfuehrenderVerkehrsweg');
INSERT INTO "FP_Verkehr"."FP_BesondereZweckbestimmungStrassenverkehr" ("Wert", "Bezeichner") VALUES ('14011', 'UnterfuehrenderVerkehrsweg');
