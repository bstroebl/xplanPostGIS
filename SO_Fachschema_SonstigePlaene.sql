-- -----------------------------------------------------
-- Objektbereich:SonstigePlanwerke
--
--Fachschema zur Modellierung nachrichtlicher �bernahmen aus anderen Rechtsbereichen und sonstiger raumbezogener Pl�ne nach BauGB.

-- *****************************************************
-- CREATE GROUP ROLES
-- *****************************************************

-- editierende Rolle f�r SO_SonstigePlanwerke
CREATE ROLE so_user
  NOSUPERUSER NOINHERIT NOCREATEDB NOCREATEROLE;
GRANT xp_gast TO so_user;
GRANT xp_user TO so_user;

-- *****************************************************
-- CREATE SCHEMAS
-- *****************************************************

CREATE SCHEMA "SO_Raster";
CREATE SCHEMA "SO_Schutzgebiete";
CREATE SCHEMA "SO_Basisobjekte";
CREATE SCHEMA "SO_NachrichtlicheUebernahmen";
CREATE SCHEMA "SO_SonstigeGebiete";
CREATE SCHEMA "SO_Sonstiges";

COMMENT ON SCHEMA "SO_Raster" IS 'Rasterdarstellung sonstiger Planwerke';
COMMENT ON SCHEMA "SO_Schutzgebiete" IS 'Schutzgebiete nach verschiedenen gesetzlichen Bestimmungen.';
COMMENT ON SCHEMA "SO_Basisobjekte" IS 'Basisklassen des Modellbereichs "Sonstige raumbezogene Planwerke und Nachrichtliche �bernahmen".';
COMMENT ON SCHEMA "SO_NachrichtlicheUebernahmen" IS 'Klassen zur Modellierung nachrichtlicher �bernahmen aus anderen Rechtsbereichen.';
COMMENT ON SCHEMA "SO_SonstigeGebiete" IS 'Klassen zur Modellierung sonstiger Gebietsausweisungen in Bauleitpl�nen.';
COMMENT ON SCHEMA "SO_Sonstiges" IS '';

GRANT USAGE ON SCHEMA "SO_Raster" TO xp_gast;
GRANT USAGE ON SCHEMA "SO_Schutzgebiete" TO xp_gast;
GRANT USAGE ON SCHEMA "SO_Basisobjekte" TO xp_gast;
GRANT USAGE ON SCHEMA "SO_NachrichtlicheUebernahmen" TO xp_gast;
GRANT USAGE ON SCHEMA "SO_SonstigeGebiete" TO xp_gast;
GRANT USAGE ON SCHEMA "SO_Sonstiges" TO xp_gast;

-- *****************************************************
-- CREATE TRIGGER FUNCTIONs
-- *****************************************************

CREATE OR REPLACE FUNCTION "SO_Basisobjekte"."new_SO_Bereich"() 
RETURNS trigger AS
$BODY$
 DECLARE
    so_plan_gid integer;
 BEGIN
    SELECT max(gid) from "SO_Basisobjekte"."SO_Plan" INTO so_plan_gid;

    IF so_plan_gid IS NULL THEN
        RETURN NULL;
    ELSE
        new."gehoertZuPlan" := so_plan_gid;
        RETURN new;
    END IF;
 END; $BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
GRANT EXECUTE ON FUNCTION "SO_Basisobjekte"."new_SO_Bereich"() TO so_user;

-- *****************************************************
-- CREATE TABLEs
-- *****************************************************

-- -----------------------------------------------------
-- Table "SO_Raster"."SO_RasterplanAenderung"
-- -----------------------------------------------------
CREATE TABLE  "SO_Raster"."SO_RasterplanAenderung" (
  "gid" BIGINT NOT NULL,
  PRIMARY KEY ("gid"),
  CONSTRAINT "fk_SO_RasterplanAenderung_XP_RasterplanAenderung1"
    FOREIGN KEY ("gid")
    REFERENCES "XP_Raster"."XP_RasterplanAenderung" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("XP_Raster"."XP_GeltungsbereichAenderung");

GRANT SELECT ON TABLE "SO_Raster"."SO_RasterplanAenderung" TO xp_gast;
GRANT ALL ON TABLE "SO_Raster"."SO_RasterplanAenderung" TO so_user;
COMMENT ON TABLE "SO_Raster"."SO_RasterplanAenderung" IS '';
CREATE TRIGGER "change_to_SO_RasterplanAenderung" BEFORE INSERT OR UPDATE OR DELETE ON "SO_Raster"."SO_RasterplanAenderung" FOR EACH ROW EXECUTE PROCEDURE "XP_Raster"."child_of_XP_RasterplanAenderung"();

-- -----------------------------------------------------
-- Table "SO_Schutzgebiete"."SO_KlassifizSchutzgebietNaturschutzrecht"
-- -----------------------------------------------------
CREATE TABLE  "SO_Schutzgebiete"."SO_KlassifizSchutzgebietNaturschutzrecht" (
  "Code" INTEGER NOT NULL,
  "Bezeichner" VARCHAR(255) NOT NULL,
  PRIMARY KEY ("Code"));
  
GRANT SELECT ON TABLE "SO_Schutzgebiete"."SO_KlassifizSchutzgebietNaturschutzrecht" TO xp_gast;

-- -----------------------------------------------------
-- Table "SO_Schutzgebiete"."SO_DetailKlassifizSchutzgebietNaturschutzrecht"
-- -----------------------------------------------------
CREATE TABLE  "SO_Schutzgebiete"."SO_DetailKlassifizSchutzgebietNaturschutzrecht" (
  "Code" INTEGER NOT NULL,
  "Bezeichner" VARCHAR(255) NOT NULL,
  PRIMARY KEY ("Code"));
  
GRANT SELECT ON TABLE "SO_Schutzgebiete"."SO_DetailKlassifizSchutzgebietNaturschutzrecht" TO xp_gast;
GRANT ALL ON TABLE "SO_Schutzgebiete"."SO_DetailKlassifizSchutzgebietNaturschutzrecht" TO so_user;

-- -----------------------------------------------------
-- Table "SO_Basisobjekte"."SO_Rechtscharakter"
-- -----------------------------------------------------
CREATE TABLE  "SO_Basisobjekte"."SO_Rechtscharakter" (
  "Code" INTEGER NOT NULL,
  "Bezeichner" VARCHAR(64) NOT NULL,
  PRIMARY KEY ("Code"));
  
GRANT SELECT ON TABLE "SO_Basisobjekte"."SO_Rechtscharakter" TO xp_gast;

-- -----------------------------------------------------
-- Table "SO_Basisobjekte"."SO_SonstRechtscharakter"
-- -----------------------------------------------------
CREATE TABLE  "SO_Basisobjekte"."SO_SonstRechtscharakter" (
  "Code" VARCHAR(64) NOT NULL,
  "Bezeichner" VARCHAR(64) NOT NULL,
  PRIMARY KEY ("Code"));
  
GRANT SELECT ON TABLE "SO_Basisobjekte"."SO_SonstRechtscharakter" TO xp_gast;

-- -----------------------------------------------------
-- Table "SO_Basisobjekte"."SO_Objekt"
-- -----------------------------------------------------
CREATE TABLE  "SO_Basisobjekte"."SO_Objekt" (
  "gid" BIGINT NOT NULL,
  "rechtscharacter" INTEGER NULL,
  "sonstRechtscharacter" VARCHAR(64) NULL,
  PRIMARY KEY ("gid"),
  CONSTRAINT "fk_SO_Objekt_XP_Objekt1"
    FOREIGN KEY ("gid")
    REFERENCES "XP_Basisobjekte"."XP_Objekt" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_SO_Objekt_rechtscharacter"
    FOREIGN KEY ("rechtscharacter")
    REFERENCES "SO_Basisobjekte"."SO_Rechtscharakter" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_SO_Objekt_sonstRechtscharacter"
    FOREIGN KEY ("sonstRechtscharacter")
    REFERENCES "SO_Basisobjekte"."SO_SonstRechtscharakter" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE);

CREATE INDEX "idx_fk_SO_Objekt_SO_Rechtscharakter1_idx" ON "SO_Basisobjekte"."SO_Objekt" ("rechtscharacter");
CREATE INDEX "idx_fk_SO_Objekt_sonstRechtscharacter_idx" ON "SO_Basisobjekte"."SO_Objekt" ("sonstRechtscharacter");
GRANT SELECT ON TABLE "SO_Basisobjekte"."SO_Objekt" TO xp_gast;
GRANT ALL ON TABLE "SO_Basisobjekte"."SO_Objekt" TO so_user;
COMMENT ON TABLE "SO_Basisobjekte"."SO_Objekt" IS 'Basisklasse f�r die Inhalte sonstiger raumbezogener Planwerke sowie von Klassen zur Modellierung nachrichtlicher �bernahmen.';
COMMENT ON COLUMN "SO_Basisobjekte"."SO_Objekt"."gid" IS 'Prim�rschl�ssel, wird automatisch ausgef�llt!';
COMMENT ON COLUMN "SO_Basisobjekte"."SO_Objekt"."rechtscharacter" IS 'Rechtscharakter des Planinhalts.';
COMMENT ON COLUMN "SO_Basisobjekte"."SO_Objekt"."sonstRechtscharacter" IS 'Klassifizierung des Rechtscharakters wenn das Attribut rechtscharakter den Wert Sonstiges (1000) hat.
FestsetzungBPlan: Wird spezifiziert, wenn das Objekt den rechtlichen Charakter einer BPlan Festsetzung hat.
DarstellungFPlan: Wird spezifiziert, wenn das Objekt den rechtlichen Charakter einer FPlan Darstellung hat.';
CREATE TRIGGER "change_to_SO_Objekt" BEFORE INSERT OR UPDATE OR DELETE ON "SO_Basisobjekte"."SO_Objekt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "SO_Basisobjekte"."SO_Punktobjekt"
-- -----------------------------------------------------
CREATE TABLE  "SO_Basisobjekte"."SO_Punktobjekt" (
  "gid" BIGINT NOT NULL,
  "position" GEOMETRY(Multipoint,25832) NOT NULL,
  PRIMARY KEY ("gid"));
  
GRANT SELECT ON TABLE "SO_Basisobjekte"."SO_Punktobjekt" TO xp_gast;
CREATE TRIGGER "SO_Punktobjekt_isAbstract" BEFORE INSERT ON "SO_Basisobjekte"."SO_Punktobjekt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isAbstract"();

-- -----------------------------------------------------
-- Table "SO_Basisobjekte"."SO_Linienobjekt"
-- -----------------------------------------------------
CREATE TABLE  "SO_Basisobjekte"."SO_Linienobjekt" (
  "gid" BIGINT NOT NULL,
  "position" GEOMETRY(MultiLinestring,25832) NOT NULL,
  PRIMARY KEY ("gid"));

GRANT SELECT ON TABLE "SO_Basisobjekte"."SO_Linienobjekt" TO xp_gast;
CREATE TRIGGER "SO_Linienobjekt_isAbstract" BEFORE INSERT ON "SO_Basisobjekte"."SO_Linienobjekt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isAbstract"();

-- -----------------------------------------------------
-- Table "SO_Basisobjekte"."SO_Flaechenobjekt"
-- -----------------------------------------------------
CREATE TABLE  "SO_Basisobjekte"."SO_Flaechenobjekt" (
  "gid" BIGINT NOT NULL,
  "position" GEOMETRY(Multipolygon,25832) NOT NULL,
  "flaechenschluss" BOOLEAN NOT NULL,
  PRIMARY KEY ("gid"));
  
GRANT SELECT ON TABLE "SO_Basisobjekte"."SO_Flaechenobjekt" TO xp_gast;
CREATE TRIGGER "SO_Flaechenobjekt_isAbstract" BEFORE INSERT ON "SO_Basisobjekte"."SO_Flaechenobjekt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isAbstract"();

-- -----------------------------------------------------
-- Table "SO_Basisobjekte"."SO_TextAbschnitt"
-- -----------------------------------------------------
CREATE  TABLE  "SO_Basisobjekte"."SO_TextAbschnitt" (
  "id" INTEGER NOT NULL ,
  "rechtscharakter" INTEGER NOT NULL ,
  PRIMARY KEY ("id") ,
  CONSTRAINT "fk_SO_Textabschnitt_parent"
    FOREIGN KEY ("id" )
    REFERENCES "XP_Basisobjekte"."XP_TextAbschnitt" ("id" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_so_textabschnitt_so_rechtscharakter1"
    FOREIGN KEY ("rechtscharakter" )
    REFERENCES "SO_Basisobjekte"."SO_Rechtscharakter" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
CREATE INDEX "idx_fk_fp_textabschnitt_fp_rechtscharakter1" ON "SO_Basisobjekte"."SO_TextAbschnitt" ("rechtscharakter") ;
GRANT SELECT ON TABLE "SO_Basisobjekte"."SO_TextAbschnitt" TO xp_gast;
GRANT ALL ON TABLE "SO_Basisobjekte"."SO_TextAbschnitt" TO so_user;
COMMENT ON TABLE  "SO_Basisobjekte"."SO_TextAbschnitt" IS 'Texlich formulierter Inhalt eines Sonstigen Plans, der einen anderen Rechtscharakter als das zugrunde liegende Fachobjekt hat (Attribut "rechtscharakter" des Fachobjektes), oder dem Plan als Ganzes zugeordnet ist.';
COMMENT ON COLUMN  "SO_Basisobjekte"."SO_TextAbschnitt"."id" IS 'Prim�rschl�ssel, wird automatisch ausgef�llt!';
COMMENT ON COLUMN  "SO_Basisobjekte"."SO_TextAbschnitt"."rechtscharakter" IS 'Rechtscharakter des textlich formulierten Planinhalts. ';
CREATE TRIGGER "change_to_SO_TextAbschnitt" BEFORE INSERT OR UPDATE OR DELETE ON "SO_Basisobjekte"."SO_TextAbschnitt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_TextAbschnitt"();

-- -----------------------------------------------------
-- Table "SO_Schutzgebiete"."SO_SchutzzonenNaturschutzrecht"
-- -----------------------------------------------------
CREATE TABLE  "SO_Schutzgebiete"."SO_SchutzzonenNaturschutzrecht" (
  "Code" INTEGER NOT NULL,
  "Bezeichner" VARCHAR(64) NOT NULL,
  PRIMARY KEY ("Code"));

GRANT SELECT ON TABLE "SO_Schutzgebiete"."SO_SchutzzonenNaturschutzrecht" TO xp_gast;

-- -----------------------------------------------------
-- Table "SO_Schutzgebiete"."SO_SchutzgebietNaturschutzrecht"
-- -----------------------------------------------------
CREATE TABLE  "SO_Schutzgebiete"."SO_SchutzgebietNaturschutzrecht" (
  "gid" BIGINT NOT NULL,
  "artDerFestlegung" INTEGER NULL,
  "detailArtDerFestlegung" INTEGER NULL,
  "zone" INTEGER NULL,
  "name" VARCHAR(64) NULL,
  "nummer" VARCHAR(64) NULL,
  PRIMARY KEY ("gid"),
  CONSTRAINT "fk_SO_SchutzgebietNaturschutzrecht_SO_Objekt"
    FOREIGN KEY ("gid")
    REFERENCES "SO_Basisobjekte"."SO_Objekt" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_SO_SchutzgebietNaturschutzrecht_artDerFestlegung"
    FOREIGN KEY ("artDerFestlegung")
    REFERENCES "SO_Schutzgebiete"."SO_KlassifizSchutzgebietNaturschutzrecht" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_SO_SchutzgebietNaturschutzrecht_detailArtDerFestlegung"
    FOREIGN KEY ("detailArtDerFestlegung")
    REFERENCES "SO_Schutzgebiete"."SO_DetailKlassifizSchutzgebietNaturschutzrecht" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_SO_SchutzgebietNaturschutzrecht_zone"
    FOREIGN KEY ("zone")
    REFERENCES "SO_Schutzgebiete"."SO_SchutzzonenNaturschutzrecht" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE);

CREATE INDEX "idx_fk_SO_SchutzgebietNaturschutzrecht_artDerFestlegung_idx" ON "SO_Schutzgebiete"."SO_SchutzgebietNaturschutzrecht" ("artDerFestlegung");
CREATE INDEX "idx_fk_SO_SchutzgebietNaturschutzrecht_detailArtDerFestlegung_idx" ON "SO_Schutzgebiete"."SO_SchutzgebietNaturschutzrecht" ("detailArtDerFestlegung");
CREATE INDEX "idx_fk_SO_SchutzgebietNaturschutzrecht_zone_idx" ON "SO_Schutzgebiete"."SO_SchutzgebietNaturschutzrecht" ("zone");
GRANT SELECT ON TABLE "SO_Schutzgebiete"."SO_SchutzgebietNaturschutzrecht" TO xp_gast;
GRANT ALL ON TABLE "SO_Schutzgebiete"."SO_SchutzgebietNaturschutzrecht" TO so_user;

COMMENT ON TABLE "SO_Schutzgebiete"."SO_SchutzgebietNaturschutzrecht" IS 'Schutzgebiet nach Naturschutzrecht.';
COMMENT ON COLUMN "SO_Schutzgebiete"."SO_SchutzgebietNaturschutzrecht"."gid" IS 'Prim�rschl�ssel, wird automatisch ausgef�llt!';
COMMENT ON COLUMN "SO_Schutzgebiete"."SO_SchutzgebietNaturschutzrecht"."artDerFestlegung" IS 'Klassizizierung des Naturschutzgebietes';
COMMENT ON COLUMN "SO_Schutzgebiete"."SO_SchutzgebietNaturschutzrecht"."detailArtDerFestlegung" IS 'Weitere Klassifizierung';
COMMENT ON COLUMN "SO_Schutzgebiete"."SO_SchutzgebietNaturschutzrecht"."zone" IS 'Klassifizierung der Schutzzone';
COMMENT ON COLUMN "SO_Schutzgebiete"."SO_SchutzgebietNaturschutzrecht"."name" IS 'Informeller Name des Schutzgebiets';
COMMENT ON COLUMN "SO_Schutzgebiete"."SO_SchutzgebietNaturschutzrecht"."nummer" IS 'Amtlicher Name / Kennziffer des Gebiets.';
CREATE TRIGGER "change_to_SO_SchutzgebietNaturschutzrecht" BEFORE INSERT OR UPDATE OR DELETE ON "SO_Schutzgebiete"."SO_SchutzgebietNaturschutzrecht" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "SO_Schutzgebiete"."SO_SchutzgebietNaturschutzrechtPunkt"
-- -----------------------------------------------------
CREATE TABLE  "SO_Schutzgebiete"."SO_SchutzgebietNaturschutzrechtPunkt" (
  "gid" BIGINT NOT NULL,
  PRIMARY KEY ("gid"),
  CONSTRAINT "fk_SO_SchutzgebietNaturschutzrechtPunkt_parent"
    FOREIGN KEY ("gid")
    REFERENCES "SO_Schutzgebiete"."SO_SchutzgebietNaturschutzrecht" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("SO_Basisobjekte"."SO_Punktobjekt");

GRANT SELECT ON TABLE "SO_Schutzgebiete"."SO_SchutzgebietNaturschutzrechtPunkt" TO xp_gast;
GRANT ALL ON TABLE "SO_Schutzgebiete"."SO_SchutzgebietNaturschutzrechtPunkt" TO so_user;
COMMENT ON COLUMN "SO_Schutzgebiete"."SO_SchutzgebietNaturschutzrechtPunkt"."gid" IS 'Prim�rschl�ssel, wird automatisch ausgef�llt!';
CREATE TRIGGER "change_to_SO_SchutzgebietNaturschutzrechtPunkt" BEFORE INSERT OR UPDATE OR DELETE ON "SO_Schutzgebiete"."SO_SchutzgebietNaturschutzrechtPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "SO_Schutzgebiete"."SO_SchutzgebietNaturschutzrechtFlaeche"
-- -----------------------------------------------------
CREATE TABLE  "SO_Schutzgebiete"."SO_SchutzgebietNaturschutzrechtFlaeche" (
  "gid" BIGINT NOT NULL,
  PRIMARY KEY ("gid"),
  CONSTRAINT "fk_SO_SchutzgebietNaturschutzrechtFlaeche_parent"
    FOREIGN KEY ("gid")
    REFERENCES "SO_Schutzgebiete"."SO_SchutzgebietNaturschutzrecht" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("SO_Basisobjekte"."SO_Flaechenobjekt");
    
GRANT SELECT ON TABLE "SO_Schutzgebiete"."SO_SchutzgebietNaturschutzrechtFlaeche" TO xp_gast;
GRANT ALL ON TABLE "SO_Schutzgebiete"."SO_SchutzgebietNaturschutzrechtFlaeche" TO so_user;
COMMENT ON COLUMN "SO_Schutzgebiete"."SO_SchutzgebietNaturschutzrechtFlaeche"."gid" IS 'Prim�rschl�ssel, wird automatisch ausgef�llt!';
CREATE TRIGGER "change_to_SO_SchutzgebietNaturschutzrechtFlaeche" BEFORE INSERT OR UPDATE OR DELETE ON "SO_Schutzgebiete"."SO_SchutzgebietNaturschutzrechtFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "SO_SchutzgebietNaturschutzrechtFlaeche_Flaechenobjekt" BEFORE INSERT OR UPDATE ON "SO_Schutzgebiete"."SO_SchutzgebietNaturschutzrechtFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isFlaechenobjekt"();

-- -----------------------------------------------------
-- Table "SO_Schutzgebiete"."SO_KlassifizSchutzgebietWasserrecht"
-- -----------------------------------------------------
CREATE TABLE  "SO_Schutzgebiete"."SO_KlassifizSchutzgebietWasserrecht" (
  "Code" INTEGER NOT NULL,
  "Bezeichner" VARCHAR(64) NOT NULL,
  PRIMARY KEY ("Code"));
  
GRANT SELECT ON TABLE "SO_Schutzgebiete"."SO_KlassifizSchutzgebietWasserrecht" TO xp_gast;

-- -----------------------------------------------------
-- Table "SO_Schutzgebiete"."SO_DetailKlassifizSchutzgebietWasserrecht"
-- -----------------------------------------------------
CREATE TABLE  "SO_Schutzgebiete"."SO_DetailKlassifizSchutzgebietWasserrecht" (
  "Code" INTEGER NOT NULL,
  "Bezeichner" VARCHAR(64) NOT NULL,
  PRIMARY KEY ("Code"));

GRANT SELECT ON TABLE "SO_Schutzgebiete"."SO_DetailKlassifizSchutzgebietWasserrecht" TO xp_gast;
GRANT ALL ON TABLE "SO_Schutzgebiete"."SO_DetailKlassifizSchutzgebietWasserrecht" TO so_user;

-- -----------------------------------------------------
-- Table "SO_Schutzgebiete"."SO_SchutzzonenWasserrecht"
-- -----------------------------------------------------
CREATE TABLE  "SO_Schutzgebiete"."SO_SchutzzonenWasserrecht" (
  "Code" INTEGER NOT NULL,
  "Bezeichner" VARCHAR(64) NOT NULL,
  PRIMARY KEY ("Code"));

GRANT SELECT ON TABLE "SO_Schutzgebiete"."SO_SchutzzonenWasserrecht" TO xp_gast;

-- -----------------------------------------------------
-- Table "SO_Schutzgebiete"."SO_SchutzgebietWasserrecht"
-- -----------------------------------------------------
CREATE TABLE  "SO_Schutzgebiete"."SO_SchutzgebietWasserrecht" (
  "gid" BIGINT NOT NULL,
  "artDerFestlegung" INTEGER NULL,
  "detailArtDerFestlegung" INTEGER NULL,
  "zone" INTEGER NULL,
  "name" VARCHAR(64) NULL,
  "nummer" VARCHAR(64) NULL,
  PRIMARY KEY ("gid"),
  CONSTRAINT "fk_SO_SchutzgebietWasserrecht_SO_Objekt1"
    FOREIGN KEY ("gid")
    REFERENCES "SO_Basisobjekte"."SO_Objekt" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_SO_SchutzgebietWasserrecht_artDerFestlegung"
    FOREIGN KEY ("artDerFestlegung")
    REFERENCES "SO_Schutzgebiete"."SO_KlassifizSchutzgebietWasserrecht" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_SO_SchutzgebietWasserrecht_detailArtDerFestlegung"
    FOREIGN KEY ("detailArtDerFestlegung")
    REFERENCES "SO_Schutzgebiete"."SO_DetailKlassifizSchutzgebietWasserrecht" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_SO_SchutzgebietWasserrecht_zone"
    FOREIGN KEY ("zone")
    REFERENCES "SO_Schutzgebiete"."SO_SchutzzonenWasserrecht" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE);

CREATE INDEX "idx_fk_SO_SchutzgebietWasserrecht_artDerFestlegung_idx" ON "SO_Schutzgebiete"."SO_SchutzgebietWasserrecht" ("artDerFestlegung");
CREATE INDEX "idx_fk_SO_SchutzgebietWasserrecht_detailArtDerFestlegung_idx" ON "SO_Schutzgebiete"."SO_SchutzgebietWasserrecht" ("detailArtDerFestlegung");
CREATE INDEX "idx_fk_SO_SchutzgebietWasserrecht_zone_idx" ON "SO_Schutzgebiete"."SO_SchutzgebietWasserrecht" ("zone");

GRANT SELECT ON TABLE "SO_Schutzgebiete"."SO_SchutzgebietWasserrecht" TO xp_gast;
GRANT ALL ON TABLE "SO_Schutzgebiete"."SO_SchutzgebietWasserrecht" TO so_user;

COMMENT ON TABLE "SO_Schutzgebiete"."SO_SchutzgebietWasserrecht" IS 'Schutzgebiet nach WasserSchutzGesetz (WSG) bzw. HeilQuellenSchutzGesetz (HQSG).';
COMMENT ON COLUMN "SO_Schutzgebiete"."SO_SchutzgebietWasserrecht"."gid" IS 'Prim�rschl�ssel, wird automatisch ausgef�llt!';
COMMENT ON COLUMN "SO_Schutzgebiete"."SO_SchutzgebietWasserrecht"."artDerFestlegung" IS 'Klassifizierung des Schutzgebietes';
COMMENT ON COLUMN "SO_Schutzgebiete"."SO_SchutzgebietWasserrecht"."detailArtDerFestlegung" IS 'Detaillierte Klassifizierung';
COMMENT ON COLUMN "SO_Schutzgebiete"."SO_SchutzgebietWasserrecht"."zone" IS 'Klassifizierung der Schutzzone
Zone 3a existiert nur bei Wasserschutzgebieten.
Zone 3b existiert nur bei Wasserschutzgebieten.
Zone 4 existiert nur bei Heilquellen.';
COMMENT ON COLUMN "SO_Schutzgebiete"."SO_SchutzgebietWasserrecht"."name" IS 'Informelle Bezeichnung des Gebiets';
COMMENT ON COLUMN "SO_Schutzgebiete"."SO_SchutzgebietWasserrecht"."nummer" IS 'Amtliche Bezeichnung / Kennziffer des Gebiets.';
CREATE TRIGGER "change_to_SO_SchutzgebietWasserrecht" BEFORE INSERT OR UPDATE OR DELETE ON "SO_Schutzgebiete"."SO_SchutzgebietWasserrecht" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "SO_Schutzgebiete"."SO_SchutzgebietWasserrechtPunkt"
-- -----------------------------------------------------
CREATE TABLE  "SO_Schutzgebiete"."SO_SchutzgebietWasserrechtPunkt" (
  "gid" BIGINT NOT NULL,
  PRIMARY KEY ("gid"),
  CONSTRAINT "fk_SO_SchutzgebietWasserrechtPunkt_parent"
    FOREIGN KEY ("gid")
    REFERENCES "SO_Schutzgebiete"."SO_SchutzgebietWasserrecht" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("SO_Basisobjekte"."SO_Punktobjekt");

GRANT SELECT ON TABLE "SO_Schutzgebiete"."SO_SchutzgebietWasserrechtPunkt" TO xp_gast;
GRANT ALL ON TABLE "SO_Schutzgebiete"."SO_SchutzgebietWasserrechtPunkt" TO so_user;
COMMENT ON COLUMN "SO_Schutzgebiete"."SO_SchutzgebietWasserrechtPunkt"."gid" IS 'Prim�rschl�ssel, wird automatisch ausgef�llt!';
CREATE TRIGGER "change_to_SO_SchutzgebietWasserrechtPunkt" BEFORE INSERT OR UPDATE OR DELETE ON "SO_Schutzgebiete"."SO_SchutzgebietWasserrechtPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "SO_Schutzgebiete"."SO_SchutzgebietWasserrechtFlaeche"
-- -----------------------------------------------------
CREATE TABLE  "SO_Schutzgebiete"."SO_SchutzgebietWasserrechtFlaeche" (
  "gid" BIGINT NOT NULL,
  PRIMARY KEY ("gid"),
  CONSTRAINT "fk_SO_SchutzgebietWasserrecht_parent"
    FOREIGN KEY ("gid")
    REFERENCES "SO_Schutzgebiete"."SO_SchutzgebietWasserrecht" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("SO_Basisobjekte"."SO_Flaechenobjekt");

GRANT SELECT ON TABLE "SO_Schutzgebiete"."SO_SchutzgebietWasserrechtFlaeche" TO xp_gast;
GRANT ALL ON TABLE "SO_Schutzgebiete"."SO_SchutzgebietWasserrechtFlaeche" TO so_user;
COMMENT ON COLUMN "SO_Schutzgebiete"."SO_SchutzgebietWasserrechtFlaeche"."gid" IS 'Prim�rschl�ssel, wird automatisch ausgef�llt!';
CREATE TRIGGER "change_to_SO_SchutzgebietWasserrechtFlaeche" BEFORE INSERT OR UPDATE OR DELETE ON "SO_Schutzgebiete"."SO_SchutzgebietWasserrechtFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "SO_SchutzgebietWasserrechtFlaeche_Flaechenobjekt" BEFORE INSERT OR UPDATE ON "SO_Schutzgebiete"."SO_SchutzgebietWasserrechtFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isFlaechenobjekt"();

-- -----------------------------------------------------
-- Table "SO_Schutzgebiete"."SO_KlassifizSchutzgebietSonstRecht"
-- -----------------------------------------------------
CREATE TABLE  "SO_Schutzgebiete"."SO_KlassifizSchutzgebietSonstRecht" (
  "Code" INTEGER NOT NULL,
  "Bezeichner" VARCHAR(64) NOT NULL,
  PRIMARY KEY ("Code"));
  
GRANT SELECT ON TABLE "SO_Schutzgebiete"."SO_KlassifizSchutzgebietSonstRecht" TO xp_gast;

-- -----------------------------------------------------
-- Table "SO_Schutzgebiete"."SO_DetailKlassifizSchutzgebietSonstRecht"
-- -----------------------------------------------------
CREATE TABLE  "SO_Schutzgebiete"."SO_DetailKlassifizSchutzgebietSonstRecht" (
  "Code" INTEGER NOT NULL,
  "Bezeichner" VARCHAR(64) NOT NULL,
  PRIMARY KEY ("Code"));
  
GRANT SELECT ON TABLE "SO_Schutzgebiete"."SO_DetailKlassifizSchutzgebietSonstRecht" TO xp_gast;
GRANT ALL ON TABLE "SO_Schutzgebiete"."SO_DetailKlassifizSchutzgebietSonstRecht" TO so_user;


-- -----------------------------------------------------
-- Table "SO_Schutzgebiete"."SO_SchutzgebietSonstigesRecht"
-- -----------------------------------------------------
CREATE TABLE  "SO_Schutzgebiete"."SO_SchutzgebietSonstigesRecht" (
  "gid" BIGINT NOT NULL,
  "artDerFestlegung" INTEGER NULL,
  "detailArtDerFestlegung" INTEGER NULL,
  "name" VARCHAR(64) NULL,
  "nummer" VARCHAR(64) NULL,
  PRIMARY KEY ("gid"),
  CONSTRAINT "fk_SO_SchutzgebietSonstigesRecht_SO_Objekt1"
    FOREIGN KEY ("gid")
    REFERENCES "SO_Basisobjekte"."SO_Objekt" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_SO_SchutzgebietSonstigesRecht_artDerFestlegung"
    FOREIGN KEY ("artDerFestlegung")
    REFERENCES "SO_Schutzgebiete"."SO_KlassifizSchutzgebietSonstRecht" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_SO_SchutzgebietSonstigesRecht_detailArtDerFestlegung"
    FOREIGN KEY ("detailArtDerFestlegung")
    REFERENCES "SO_Schutzgebiete"."SO_DetailKlassifizSchutzgebietSonstRecht" ("Code")
    ON DELETE NO ACTION);

CREATE INDEX "idx_fk_SO_SchutzgebietSonstigesRecht_artDerFestlegung_idx" ON "SO_Schutzgebiete"."SO_SchutzgebietSonstigesRecht" ("artDerFestlegung");
CREATE INDEX "idx_fk_SO_SchutzgebietSonstigesRecht_detailArtDerFestlegung_idx" ON "SO_Schutzgebiete"."SO_SchutzgebietSonstigesRecht" ("detailArtDerFestlegung");
GRANT SELECT ON TABLE "SO_Schutzgebiete"."SO_SchutzgebietSonstigesRecht" TO xp_gast;
GRANT ALL ON TABLE "SO_Schutzgebiete"."SO_SchutzgebietSonstigesRecht" TO so_user;
COMMENT ON TABLE "SO_Schutzgebiete"."SO_SchutzgebietSonstigesRecht" IS 'Sonstige Schutzgebiete nach unterschiedlichen rechtlichen Bestimmungen.';
COMMENT ON COLUMN "SO_Schutzgebiete"."SO_SchutzgebietSonstigesRecht"."gid" IS 'Prim�rschl�ssel, wird automatisch ausgef�llt!';
COMMENT ON COLUMN "SO_Schutzgebiete"."SO_SchutzgebietSonstigesRecht"."artDerFestlegung" IS 'Klassifizierung des Schutzgebietes oder Schutzbereichs.';
COMMENT ON COLUMN "SO_Schutzgebiete"."SO_SchutzgebietSonstigesRecht"."detailArtDerFestlegung" IS 'Detaillierte Klassifizierung';
COMMENT ON COLUMN "SO_Schutzgebiete"."SO_SchutzgebietSonstigesRecht"."name" IS 'Informelle Bezeichnung des Gebiets';
COMMENT ON COLUMN "SO_Schutzgebiete"."SO_SchutzgebietSonstigesRecht"."nummer" IS 'Amtliche Bezeichnung / Kennziffer des Gebiets.';
CREATE TRIGGER "change_to_SO_SchutzgebietSonstigesRecht" BEFORE INSERT OR UPDATE OR DELETE ON "SO_Schutzgebiete"."SO_SchutzgebietSonstigesRecht" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "SO_Schutzgebiete"."SO_SchutzgebietSonstigesRechtFlaeche"
-- -----------------------------------------------------
CREATE TABLE  "SO_Schutzgebiete"."SO_SchutzgebietSonstigesRechtFlaeche" (
  "gid" BIGINT NOT NULL,
  PRIMARY KEY ("gid"),
  CONSTRAINT "fk_SO_SchutzgebietSonstigesRechtFlaeche_parent"
    FOREIGN KEY ("gid")
    REFERENCES "SO_Schutzgebiete"."SO_SchutzgebietSonstigesRecht" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("SO_Basisobjekte"."SO_Flaechenobjekt");

GRANT SELECT ON TABLE "SO_Schutzgebiete"."SO_SchutzgebietSonstigesRechtFlaeche" TO xp_gast;
GRANT ALL ON TABLE "SO_Schutzgebiete"."SO_SchutzgebietSonstigesRechtFlaeche" TO so_user;
COMMENT ON COLUMN "SO_Schutzgebiete"."SO_SchutzgebietSonstigesRechtFlaeche"."gid" IS 'Prim�rschl�ssel, wird automatisch ausgef�llt!';
CREATE TRIGGER "change_to_SO_SchutzgebietSonstigesRechtFlaeche" BEFORE INSERT OR UPDATE OR DELETE ON "SO_Schutzgebiete"."SO_SchutzgebietSonstigesRechtFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "SO_SchutzgebietSonstigesRechtFlaeche_Flaechenobjekt" BEFORE INSERT OR UPDATE ON "SO_Schutzgebiete"."SO_SchutzgebietSonstigesRechtFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isFlaechenobjekt"();

-- -----------------------------------------------------
-- Table "SO_Basisobjekte"."SO_PlanTyp"
-- -----------------------------------------------------
CREATE TABLE  "SO_Basisobjekte"."SO_PlanTyp" (
  "Code" VARCHAR(64) NOT NULL,
  "Bezeichner" VARCHAR(64) NOT NULL,
  PRIMARY KEY ("Code"))
;
GRANT SELECT ON TABLE "SO_Basisobjekte"."SO_PlanTyp" TO xp_gast;
GRANT ALL ON TABLE "SO_Basisobjekte"."SO_PlanTyp" TO so_user;

-- -----------------------------------------------------
-- Table "SO_Basisobjekte"."SO_Plan"
-- -----------------------------------------------------
CREATE TABLE  "SO_Basisobjekte"."SO_Plan" (
  "gid" BIGINT NOT NULL,
  "name" VARCHAR (256) NOT NULL,
  "planTyp" VARCHAR(64) NULL,
  "plangeber" INTEGER NULL,
  PRIMARY KEY ("gid"),
  CONSTRAINT "fk_SO_Plan_planTyp"
    FOREIGN KEY ("planTyp")
    REFERENCES "SO_Basisobjekte"."SO_PlanTyp" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_SO_Plan_plangeber"
    FOREIGN KEY ("plangeber")
    REFERENCES "XP_Sonstiges"."XP_Plangeber" ("id")
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_SO_Plan_XP_Plan"
    FOREIGN KEY ("gid")
    REFERENCES "XP_Basisobjekte"."XP_Plan" ("gid")
    ON DELETE NO ACTION
    ON UPDATE CASCADE)
INHERITS("XP_Basisobjekte"."XP_RaeumlicherGeltungsbereich");

CREATE INDEX "idx_fk_SO_Plan_planTyp_idx" ON "SO_Basisobjekte"."SO_Plan" ("planTyp");
CREATE INDEX "idx_fk_SO_Plan_plangeber_idx" ON "SO_Basisobjekte"."SO_Plan" ("plangeber");
CREATE INDEX "idx_fk_SO_Plan_XP_Plan1_idx" ON "SO_Basisobjekte"."SO_Plan" ("gid");

GRANT SELECT ON TABLE "SO_Basisobjekte"."SO_Plan" TO xp_gast;
GRANT ALL ON TABLE "SO_Basisobjekte"."SO_Plan" TO so_user;
COMMENT ON TABLE "SO_Basisobjekte"."SO_Plan" IS 'Klasse f�r sonstige, z. B. l�nderspezifische raumbezogene Planwerke.';
COMMENT ON COLUMN "SO_Basisobjekte"."SO_Plan"."gid" IS 'Prim�rschl�ssel, wird automatisch ausgef�llt!';
COMMENT ON COLUMN "SO_Basisobjekte"."SO_Plan"."name" IS 'Name des Plans. Der Name kann hier oder in XP_Plan ge�ndert werden.';
COMMENT ON COLUMN "SO_Basisobjekte"."SO_Plan"."planTyp" IS 'Typ des Plans';
COMMENT ON COLUMN "SO_Basisobjekte"."SO_Plan"."plangeber" IS 'F�r den Plan zust�ndige Stelle.';
CREATE TRIGGER "change_to_SO_Plan" BEFORE INSERT OR UPDATE OR DELETE ON "SO_Basisobjekte"."SO_Plan" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Plan"();
CREATE TRIGGER "SO_Plan_propagate_name" AFTER UPDATE ON "SO_Basisobjekte"."SO_Plan" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."propagate_name_to_parent"();

-- -----------------------------------------------------
-- Table "SO_Basisobjekte"."SO_Bereich"
-- -----------------------------------------------------
CREATE TABLE  "SO_Basisobjekte"."SO_Bereich" (
  "gid" BIGINT NOT NULL,
  "name" VARCHAR (256) NOT NULL,
  "gehoertZuPlan" BIGINT NOT NULL,
  PRIMARY KEY ("gid"),
  CONSTRAINT "fk_SO_Bereich_XP_Bereich"
    FOREIGN KEY ("gid")
    REFERENCES "XP_Basisobjekte"."XP_Bereich" ("gid")
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_SO_Bereich_SO_Plan1"
    FOREIGN KEY ("gehoertZuPlan")
    REFERENCES "SO_Basisobjekte"."SO_Plan" ("gid")
    ON DELETE NO ACTION
    ON UPDATE CASCADE)
INHERITS("XP_Basisobjekte"."XP_Geltungsbereich");

CREATE INDEX "idx_fk_SO_Bereich_SO_Plan1_idx" ON "SO_Basisobjekte"."SO_Bereich" ("gehoertZuPlan");
GRANT SELECT ON TABLE "SO_Basisobjekte"."SO_Bereich" TO xp_gast;
GRANT ALL ON TABLE "SO_Basisobjekte"."SO_Bereich" TO so_user;
COMMENT ON TABLE "SO_Basisobjekte"."SO_Bereich" IS 'Bereich eines sonstigen raumbezogenen Plans.';
COMMENT ON COLUMN "SO_Basisobjekte"."SO_Bereich"."gid" IS 'Prim�rschl�ssel, wird automatisch ausgef�llt!';
COMMENT ON COLUMN "SO_Basisobjekte"."SO_Bereich"."name" IS 'Bezeichnung des Bereiches. Die Bezeichnung kann hier oder in XP_Bereich ge�ndert werden.';
COMMENT ON COLUMN "SO_Basisobjekte"."SO_Bereich"."gehoertZuPlan" IS '';
CREATE TRIGGER "change_to_SO_Bereich" BEFORE INSERT OR UPDATE OR DELETE ON "SO_Basisobjekte"."SO_Bereich" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Bereich"();
CREATE TRIGGER "insert_into_SO_Bereich" BEFORE INSERT ON "SO_Basisobjekte"."SO_Bereich" FOR EACH ROW EXECUTE PROCEDURE "SO_Basisobjekte"."new_SO_Bereich"();
CREATE TRIGGER "SO_Bereich_propagate_name" AFTER UPDATE ON "SO_Basisobjekte"."SO_Bereich" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."propagate_name_to_parent"();

-- -----------------------------------------------------
-- Table "SO_Basisobjekte"."gehoertZuSO_Bereich"
-- -----------------------------------------------------
CREATE TABLE  "SO_Basisobjekte"."gehoertZuSO_Bereich" (
  "SO_Objekt_gid" BIGINT NOT NULL,
  "SO_Bereich_gid" BIGINT NOT NULL,
  PRIMARY KEY ("SO_Objekt_gid", "SO_Bereich_gid"),
  CONSTRAINT "fk_SO_Objekt_hatSO_Bereich_SO_Objekt1"
    FOREIGN KEY ("SO_Objekt_gid")
    REFERENCES "SO_Basisobjekte"."SO_Objekt" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_SO_Objekt_hatSO_Bereich_SO_Bereich1"
    FOREIGN KEY ("SO_Bereich_gid")
    REFERENCES "SO_Basisobjekte"."SO_Bereich" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE);

CREATE INDEX "idx_fk_SO_Objekt_hatSO_Bereich_SO_Bereich1_idx" ON "SO_Basisobjekte"."gehoertZuSO_Bereich" ("SO_Bereich_gid");

CREATE INDEX "idx_fk_SO_Objekt_hatSO_Bereich_SO_Objekt1_idx" ON "SO_Basisobjekte"."gehoertZuSO_Bereich" ("SO_Objekt_gid");
GRANT SELECT ON TABLE "SO_Basisobjekte"."gehoertZuSO_Bereich" TO xp_gast;
GRANT ALL ON TABLE "SO_Basisobjekte"."gehoertZuSO_Bereich" TO so_user;

-- -----------------------------------------------------
-- Table "SO_NachrichtlicheUebernahmen"."SO_KlassifizNachStrassenverkehrsrecht"
-- -----------------------------------------------------
CREATE TABLE  "SO_NachrichtlicheUebernahmen"."SO_KlassifizNachStrassenverkehrsrecht" (
  "Code" INTEGER NOT NULL,
  "Bezeichner" VARCHAR(64) NOT NULL,
  PRIMARY KEY ("Code"));
  
GRANT SELECT ON TABLE "SO_NachrichtlicheUebernahmen"."SO_KlassifizNachStrassenverkehrsrecht" TO xp_gast;

-- -----------------------------------------------------
-- Table "SO_NachrichtlicheUebernahmen"."SO_DetailKlassifizNachStrassenverkehrsrecht"
-- -----------------------------------------------------
CREATE TABLE  "SO_NachrichtlicheUebernahmen"."SO_DetailKlassifizNachStrassenverkehrsrecht" (
  "Code" INTEGER NOT NULL,
  "Bezeichner" VARCHAR(64) NOT NULL,
  PRIMARY KEY ("Code"));
  
GRANT SELECT ON TABLE "SO_NachrichtlicheUebernahmen"."SO_DetailKlassifizNachStrassenverkehrsrecht" TO xp_gast;
GRANT ALL ON TABLE "SO_NachrichtlicheUebernahmen"."SO_DetailKlassifizNachStrassenverkehrsrecht" TO so_user;

-- -----------------------------------------------------
-- Table "SO_NachrichtlicheUebernahmen"."SO_Strassenverkehrsrecht"
-- -----------------------------------------------------
CREATE TABLE  "SO_NachrichtlicheUebernahmen"."SO_Strassenverkehrsrecht" (
  "gid" BIGINT NOT NULL,
  "artDerFestlegung" INTEGER NULL,
  "detailArtDerFestlegung" INTEGER NULL,
  "name" VARCHAR(64) NULL,
  "nummer" VARCHAR(16) NULL,
  PRIMARY KEY ("gid"),
  CONSTRAINT "fk_SO_Strassenverkehrsrecht_SO_Objekt"
    FOREIGN KEY ("gid")
    REFERENCES "SO_Basisobjekte"."SO_Objekt" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_SO_Strassenverkehrsrecht_artDerFestlegung"
    FOREIGN KEY ("artDerFestlegung")
    REFERENCES "SO_NachrichtlicheUebernahmen"."SO_KlassifizNachStrassenverkehrsrecht" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_SO_Strassenverkehrsrecht_detailArtDerFestlegung"
    FOREIGN KEY ("detailArtDerFestlegung")
    REFERENCES "SO_NachrichtlicheUebernahmen"."SO_DetailKlassifizNachStrassenverkehrsrecht" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE);

CREATE INDEX "idx_fk_SO_Strassenverkehrsrecht_artDerFestlegung_idx" ON "SO_NachrichtlicheUebernahmen"."SO_Strassenverkehrsrecht" ("artDerFestlegung");
CREATE INDEX "idx_fk_SO_Strassenverkehrsrecht_detailArtDerFestlegung_idx" ON "SO_NachrichtlicheUebernahmen"."SO_Strassenverkehrsrecht" ("detailArtDerFestlegung");

GRANT SELECT ON TABLE "SO_NachrichtlicheUebernahmen"."SO_Strassenverkehrsrecht" TO xp_gast;
GRANT ALL ON TABLE "SO_NachrichtlicheUebernahmen"."SO_Strassenverkehrsrecht" TO so_user;

COMMENT ON TABLE "SO_NachrichtlicheUebernahmen"."SO_Strassenverkehrsrecht" IS 'Festlegung nach Stra�enverkehrsrecht.';
COMMENT ON COLUMN "SO_NachrichtlicheUebernahmen"."SO_Strassenverkehrsrecht"."gid" IS 'Prim�rschl�ssel, wird automatisch ausgef�llt!';
COMMENT ON COLUMN "SO_NachrichtlicheUebernahmen"."SO_Strassenverkehrsrecht"."artDerFestlegung" IS 'Grobe rechtliche Klassifizierung der Festlegung';
COMMENT ON COLUMN "SO_NachrichtlicheUebernahmen"."SO_Strassenverkehrsrecht"."detailArtDerFestlegung" IS 'Detaillierte rechtliche Klassifizierung der Festlegung.';
COMMENT ON COLUMN "SO_NachrichtlicheUebernahmen"."SO_Strassenverkehrsrecht"."name" IS 'Informelle Bezeichnung der Festlegung.';
COMMENT ON COLUMN "SO_NachrichtlicheUebernahmen"."SO_Strassenverkehrsrecht"."nummer" IS 'Amtliche Bezeichnung / Kennziffer der Festlegung.';
CREATE TRIGGER "change_to_SO_Strassenverkehrsrecht" BEFORE INSERT OR UPDATE OR DELETE ON "SO_NachrichtlicheUebernahmen"."SO_Strassenverkehrsrecht" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "SO_NachrichtlicheUebernahmen"."SO_StrassenverkehrsrechtLinie"
-- -----------------------------------------------------
CREATE TABLE  "SO_NachrichtlicheUebernahmen"."SO_StrassenverkehrsrechtLinie" (
  "gid" BIGINT NOT NULL,
  PRIMARY KEY ("gid"),
  CONSTRAINT "fk_SO_StrassenverkehrsrechtLinie_parent"
    FOREIGN KEY ("gid")
    REFERENCES "SO_NachrichtlicheUebernahmen"."SO_Strassenverkehrsrecht" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("SO_Basisobjekte"."SO_Linienobjekt");

CREATE INDEX "idx_fk_SO_StrassenverkehrsrechtLinie_parent_idx" ON "SO_NachrichtlicheUebernahmen"."SO_StrassenverkehrsrechtLinie" ("gid");
GRANT SELECT ON TABLE "SO_NachrichtlicheUebernahmen"."SO_StrassenverkehrsrechtLinie" TO xp_gast;
GRANT ALL ON TABLE "SO_NachrichtlicheUebernahmen"."SO_StrassenverkehrsrechtLinie" TO so_user;
COMMENT ON COLUMN "SO_NachrichtlicheUebernahmen"."SO_StrassenverkehrsrechtLinie"."gid" IS 'Prim�rschl�ssel, wird automatisch ausgef�llt!';
CREATE TRIGGER "change_to_SO_StrassenverkehrsrechtLinie" BEFORE INSERT OR UPDATE OR DELETE ON "SO_NachrichtlicheUebernahmen"."SO_StrassenverkehrsrechtLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "SO_NachrichtlicheUebernahmen"."SO_StrassenverkehrsrechtFlaeche"
-- -----------------------------------------------------
CREATE TABLE  "SO_NachrichtlicheUebernahmen"."SO_StrassenverkehrsrechtFlaeche" (
  "gid" BIGINT NOT NULL,
  PRIMARY KEY ("gid"),
  CONSTRAINT "fk_SO_StrassenverkehrsrechtFlaeche_parent"
    FOREIGN KEY ("gid")
    REFERENCES "SO_NachrichtlicheUebernahmen"."SO_Strassenverkehrsrecht" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("SO_Basisobjekte"."SO_Flaechenobjekt");    
    
GRANT SELECT ON TABLE "SO_NachrichtlicheUebernahmen"."SO_StrassenverkehrsrechtFlaeche" TO xp_gast;
GRANT ALL ON TABLE "SO_NachrichtlicheUebernahmen"."SO_StrassenverkehrsrechtFlaeche" TO so_user;
COMMENT ON COLUMN "SO_NachrichtlicheUebernahmen"."SO_StrassenverkehrsrechtLinie"."gid" IS 'Prim�rschl�ssel, wird automatisch ausgef�llt!';
CREATE TRIGGER "change_to_SO_StrassenverkehrsrechtFlaeche" BEFORE INSERT OR UPDATE OR DELETE ON "SO_NachrichtlicheUebernahmen"."SO_StrassenverkehrsrechtFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "SO_StrassenverkehrsrechtFlaeche_Flaechenobjekt" BEFORE INSERT OR UPDATE ON "SO_NachrichtlicheUebernahmen"."SO_StrassenverkehrsrechtFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isFlaechenobjekt"();

-- -----------------------------------------------------
-- Table "SO_NachrichtlicheUebernahmen"."SO_KlassifizNachWasserrecht"
-- -----------------------------------------------------
CREATE TABLE  "SO_NachrichtlicheUebernahmen"."SO_KlassifizNachWasserrecht" (
  "Code" INTEGER NOT NULL,
  "Bezeichner" VARCHAR(64) NOT NULL,
  PRIMARY KEY ("Code"));
GRANT SELECT ON TABLE "SO_NachrichtlicheUebernahmen"."SO_KlassifizNachWasserrecht" TO xp_gast;
GRANT ALL ON TABLE "SO_NachrichtlicheUebernahmen"."SO_KlassifizNachWasserrecht" TO so_user;

-- -----------------------------------------------------
-- Table "SO_NachrichtlicheUebernahmen"."SO_DetailKlassifizNachWasserrecht"
-- -----------------------------------------------------
CREATE TABLE  "SO_NachrichtlicheUebernahmen"."SO_DetailKlassifizNachWasserrecht" (
  "Code" INTEGER NOT NULL,
  "Bezeichner" VARCHAR(64) NOT NULL,
  PRIMARY KEY ("Code"));
  
GRANT SELECT ON TABLE "SO_NachrichtlicheUebernahmen"."SO_DetailKlassifizNachWasserrecht" TO xp_gast;
GRANT ALL ON TABLE "SO_NachrichtlicheUebernahmen"."SO_DetailKlassifizNachWasserrecht" TO so_user;

-- -----------------------------------------------------
-- Table "SO_NachrichtlicheUebernahmen"."SO_Wasserrecht"
-- -----------------------------------------------------
CREATE TABLE  "SO_NachrichtlicheUebernahmen"."SO_Wasserrecht" (
  "gid" BIGINT NOT NULL,
  "artDerFestlegung" INTEGER NULL,
  "detailArtDerFestlegung" INTEGER NULL,
  "istNatuerlichesUberschwemmungsgebiet" BOOLEAN NULL DEFAULT 'f',
  "name" VARCHAR(64) NULL,
  "nummer" VARCHAR(64) NULL,
  PRIMARY KEY ("gid"),
  CONSTRAINT "fk_SO_Wasserrecht_SO_Objekt1"
    FOREIGN KEY ("gid")
    REFERENCES "SO_Basisobjekte"."SO_Objekt" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_SO_Wasserrecht_artDerFestlegung"
    FOREIGN KEY ("artDerFestlegung")
    REFERENCES "SO_NachrichtlicheUebernahmen"."SO_KlassifizNachWasserrecht" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_SO_Wasserrecht_detailArtDerFestlegung"
    FOREIGN KEY ("detailArtDerFestlegung")
    REFERENCES "SO_NachrichtlicheUebernahmen"."SO_DetailKlassifizNachWasserrecht" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE);

CREATE INDEX "idx_fk_SO_Wasserrecht_artDerFestlegung_idx" ON "SO_NachrichtlicheUebernahmen"."SO_Wasserrecht" ("artDerFestlegung");
CREATE INDEX "idx_fk_SO_Wasserrecht_detailArtDerFestlegung_idx" ON "SO_NachrichtlicheUebernahmen"."SO_Wasserrecht" ("detailArtDerFestlegung");
GRANT SELECT ON TABLE "SO_NachrichtlicheUebernahmen"."SO_Wasserrecht" TO xp_gast;
GRANT ALL ON TABLE "SO_NachrichtlicheUebernahmen"."SO_Wasserrecht" TO so_user;
COMMENT ON TABLE "SO_NachrichtlicheUebernahmen"."SO_Wasserrecht" IS 'Festlegung nach Wasserrecht.';
COMMENT ON COLUMN "SO_NachrichtlicheUebernahmen"."SO_Wasserrecht"."gid" IS 'Prim�rschl�ssel, wird automatisch ausgef�llt!';
COMMENT ON COLUMN "SO_NachrichtlicheUebernahmen"."SO_Wasserrecht"."artDerFestlegung" IS 'Grundlegende rechtliche Klassifizierung der Festlegung
Ueberschwemmungsgebiet: �berschwemmungsgebiet nach . � 31b Abs. 1 WHG ist ein durch Rechtsverordnung festgesetztes oder nat�rliches Gebiet, das bei Hochwasser �berschwemmt werden kann bzw. �berschwemmt wird.
FestgesetztesUeberschwemmungsgebiet: Festgesetztes �berschwemmungsgebiet ist ein per Verordnung festgesetzte �berschwemmungsgebiete auf Basis HQ100
NochNichtFestgesetztesUeberschwemmungsgebiet: Noch nicht festgesetztes �berschwemmungsgebiet nach �31b Abs. 5 WHG.
UeberschwemmGefaehrdetesGebiet: �berschwemmungsgef�hrdetes Gebiet gem�� �31 c WHG.';
COMMENT ON COLUMN "SO_NachrichtlicheUebernahmen"."SO_Wasserrecht"."detailArtDerFestlegung" IS 'Detaillierte rechtliche Klassifizierung der Festlegung.';
COMMENT ON COLUMN "SO_NachrichtlicheUebernahmen"."SO_Wasserrecht"."istNatuerlichesUberschwemmungsgebiet" IS 'Gibt an, ob es sich bei der Fl�che um ein nat�rliches �berschwemmungsgebiet handelt.';
COMMENT ON COLUMN "SO_NachrichtlicheUebernahmen"."SO_Wasserrecht"."name" IS 'Informelle Bezeichnung der Festlegung.';
COMMENT ON COLUMN "SO_NachrichtlicheUebernahmen"."SO_Wasserrecht"."nummer" IS 'Amtliche Bezeichnung / Kennziffer der Festlegung.';
CREATE TRIGGER "change_to_SO_Wasserrecht" BEFORE INSERT OR UPDATE OR DELETE ON "SO_NachrichtlicheUebernahmen"."SO_Wasserrecht" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "SO_NachrichtlicheUebernahmen"."SO_WasserrechtPunkt"
-- -----------------------------------------------------
CREATE TABLE  "SO_NachrichtlicheUebernahmen"."SO_WasserrechtPunkt" (
  "gid" BIGINT NOT NULL,
  PRIMARY KEY ("gid"),
  CONSTRAINT "fk_SO_WasserrechtPunkt_parent"
    FOREIGN KEY ("gid")
    REFERENCES "SO_NachrichtlicheUebernahmen"."SO_Wasserrecht" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("SO_Basisobjekte"."SO_Punktobjekt");    
    
GRANT SELECT ON TABLE "SO_NachrichtlicheUebernahmen"."SO_WasserrechtPunkt" TO xp_gast;
GRANT ALL ON TABLE "SO_NachrichtlicheUebernahmen"."SO_WasserrechtPunkt" TO so_user;
COMMENT ON COLUMN "SO_NachrichtlicheUebernahmen"."SO_WasserrechtPunkt"."gid" IS 'Prim�rschl�ssel, wird automatisch ausgef�llt!';
CREATE TRIGGER "change_to_SO_WasserrechtPunkt" BEFORE INSERT OR UPDATE OR DELETE ON "SO_NachrichtlicheUebernahmen"."SO_WasserrechtPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();    

-- -----------------------------------------------------
-- Table "SO_NachrichtlicheUebernahmen"."SO_WasserrechtLinie"
-- -----------------------------------------------------
CREATE TABLE  "SO_NachrichtlicheUebernahmen"."SO_WasserrechtLinie" (
  "gid" BIGINT NOT NULL,
  PRIMARY KEY ("gid"),
  CONSTRAINT "fk_SO_WasserrechtLinie_parent"
    FOREIGN KEY ("gid")
    REFERENCES "SO_NachrichtlicheUebernahmen"."SO_Wasserrecht" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("SO_Basisobjekte"."SO_Linienobjekt");  
    
GRANT SELECT ON TABLE "SO_NachrichtlicheUebernahmen"."SO_WasserrechtLinie" TO xp_gast;
GRANT ALL ON TABLE "SO_NachrichtlicheUebernahmen"."SO_WasserrechtLinie" TO so_user;
COMMENT ON COLUMN "SO_NachrichtlicheUebernahmen"."SO_WasserrechtLinie"."gid" IS 'Prim�rschl�ssel, wird automatisch ausgef�llt!';
CREATE TRIGGER "change_to_SO_WasserrechtLinie" BEFORE INSERT OR UPDATE OR DELETE ON "SO_NachrichtlicheUebernahmen"."SO_WasserrechtLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "SO_NachrichtlicheUebernahmen"."SO_WasserrechtFlaeche"
-- -----------------------------------------------------
CREATE TABLE  "SO_NachrichtlicheUebernahmen"."SO_WasserrechtFlaeche" (
  "gid" BIGINT NOT NULL,
  PRIMARY KEY ("gid"),
  CONSTRAINT "fk_SO_WasserrechtFlaeche_parent"
    FOREIGN KEY ("gid")
    REFERENCES "SO_NachrichtlicheUebernahmen"."SO_Wasserrecht" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("SO_Basisobjekte"."SO_Flaechenobjekt");
    
GRANT SELECT ON TABLE "SO_NachrichtlicheUebernahmen"."SO_WasserrechtFlaeche" TO xp_gast;
GRANT ALL ON TABLE "SO_NachrichtlicheUebernahmen"."SO_WasserrechtFlaeche" TO so_user;
COMMENT ON COLUMN "SO_NachrichtlicheUebernahmen"."SO_WasserrechtFlaeche"."gid" IS 'Prim�rschl�ssel, wird automatisch ausgef�llt!';
CREATE TRIGGER "change_to_SO_WasserrechtFlaeche" BEFORE INSERT OR UPDATE OR DELETE ON "SO_NachrichtlicheUebernahmen"."SO_WasserrechtFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "SO_WasserrechtFlaeche_Flaechenobjekt" BEFORE INSERT OR UPDATE ON "SO_NachrichtlicheUebernahmen"."SO_WasserrechtFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isFlaechenobjekt"();

-- -----------------------------------------------------
-- Table "SO_NachrichtlicheUebernahmen"."SO_KlassifizNachForstrecht"
-- -----------------------------------------------------
CREATE TABLE  "SO_NachrichtlicheUebernahmen"."SO_KlassifizNachForstrecht" (
  "Code" INTEGER NOT NULL,
  "Bezeichner" VARCHAR(64) NOT NULL,
  PRIMARY KEY ("Code"));
  
GRANT SELECT ON TABLE "SO_NachrichtlicheUebernahmen"."SO_KlassifizNachForstrecht" TO xp_gast;

-- -----------------------------------------------------
-- Table "SO_NachrichtlicheUebernahmen"."SO_DetailKlassifizNachForstrecht"
-- -----------------------------------------------------
CREATE TABLE  "SO_NachrichtlicheUebernahmen"."SO_DetailKlassifizNachForstrecht" (
  "Code" INTEGER NOT NULL,
  "Bezeichner" VARCHAR(64) NOT NULL,
  PRIMARY KEY ("Code"));

GRANT SELECT ON TABLE "SO_NachrichtlicheUebernahmen"."SO_DetailKlassifizNachForstrecht" TO xp_gast;
GRANT ALL ON TABLE "SO_NachrichtlicheUebernahmen"."SO_DetailKlassifizNachForstrecht" TO so_user;

-- -----------------------------------------------------
-- Table "SO_NachrichtlicheUebernahmen"."SO_Forstrecht"
-- -----------------------------------------------------
CREATE TABLE  "SO_NachrichtlicheUebernahmen"."SO_Forstrecht" (
  "gid" BIGINT NOT NULL,
  "artDerFestlegung" INTEGER NULL,
  "detailArtDerFestlegung" INTEGER NULL,
  "name" VARCHAR(64) NULL,
  "nummer" VARCHAR(64) NULL,
  PRIMARY KEY ("gid"),
  CONSTRAINT "fk_SO_Forstrecht_SO_Objekt1"
    FOREIGN KEY ("gid")
    REFERENCES "SO_Basisobjekte"."SO_Objekt" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_SO_Forstrecht_artDerFestlegung"
    FOREIGN KEY ("artDerFestlegung")
    REFERENCES "SO_NachrichtlicheUebernahmen"."SO_KlassifizNachForstrecht" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_SO_Forstrecht_detailArtDerFestlegung"
    FOREIGN KEY ("detailArtDerFestlegung")
    REFERENCES "SO_NachrichtlicheUebernahmen"."SO_DetailKlassifizNachForstrecht" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE);

CREATE INDEX "idx_fk_SO_Forstrecht_artDerFestlegung_idx" ON "SO_NachrichtlicheUebernahmen"."SO_Forstrecht" ("artDerFestlegung");
CREATE INDEX "idx_fk_SO_Forstrecht_detailArtDerFestlegung_idx" ON "SO_NachrichtlicheUebernahmen"."SO_Forstrecht" ("detailArtDerFestlegung");

GRANT SELECT ON TABLE "SO_NachrichtlicheUebernahmen"."SO_Forstrecht" TO xp_gast;
GRANT ALL ON TABLE "SO_NachrichtlicheUebernahmen"."SO_Forstrecht" TO so_user;
COMMENT ON TABLE "SO_NachrichtlicheUebernahmen"."SO_Forstrecht" IS 'Festlegung nach Forstrecht.';
COMMENT ON COLUMN "SO_NachrichtlicheUebernahmen"."SO_Forstrecht"."gid" IS 'Prim�rschl�ssel, wird automatisch ausgef�llt!';
COMMENT ON COLUMN "SO_NachrichtlicheUebernahmen"."SO_Forstrecht"."artDerFestlegung" IS 'Grundlegende Klassifizierung der Festlegung';
COMMENT ON COLUMN "SO_NachrichtlicheUebernahmen"."SO_Forstrecht"."detailArtDerFestlegung" IS 'Detaillierte Klassifizierung der Festlegung.';
COMMENT ON COLUMN "SO_NachrichtlicheUebernahmen"."SO_Forstrecht"."name" IS 'Informelle Bezeichnung der Festlegung.';
COMMENT ON COLUMN "SO_NachrichtlicheUebernahmen"."SO_Forstrecht"."nummer" IS 'Amtliche Bezeichnung / Kennziffer der Festlegung.';
CREATE TRIGGER "change_to_SO_Forstrecht" BEFORE INSERT OR UPDATE OR DELETE ON "SO_NachrichtlicheUebernahmen"."SO_Forstrecht" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "SO_NachrichtlicheUebernahmen"."SO_ForstrechtPunkt"
-- -----------------------------------------------------
CREATE TABLE  "SO_NachrichtlicheUebernahmen"."SO_ForstrechtPunkt" (
  "gid" BIGINT NOT NULL,
  PRIMARY KEY ("gid"),
  CONSTRAINT "fk_SO_ForstrechtPunkt_SO_Forstrecht1"
    FOREIGN KEY ("gid")
    REFERENCES "SO_NachrichtlicheUebernahmen"."SO_Forstrecht" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("SO_Basisobjekte"."SO_Punktobjekt");    
    
GRANT SELECT ON TABLE "SO_NachrichtlicheUebernahmen"."SO_ForstrechtPunkt" TO xp_gast;
GRANT ALL ON TABLE "SO_NachrichtlicheUebernahmen"."SO_ForstrechtPunkt" TO so_user;
COMMENT ON COLUMN "SO_NachrichtlicheUebernahmen"."SO_ForstrechtPunkt"."gid" IS 'Prim�rschl�ssel, wird automatisch ausgef�llt!';
CREATE TRIGGER "change_to_SO_ForstrechtPunkt" BEFORE INSERT OR UPDATE OR DELETE ON "SO_NachrichtlicheUebernahmen"."SO_ForstrechtPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "SO_NachrichtlicheUebernahmen"."SO_ForstrechtFlaeche"
-- -----------------------------------------------------
CREATE TABLE  "SO_NachrichtlicheUebernahmen"."SO_ForstrechtFlaeche" (
  "gid" BIGINT NOT NULL,
  PRIMARY KEY ("gid"),
  CONSTRAINT "fk_SO_ForstrechtFlaeche_SO_Forstrecht1"
    FOREIGN KEY ("gid")
    REFERENCES "SO_NachrichtlicheUebernahmen"."SO_Forstrecht" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("SO_Basisobjekte"."SO_Flaechenobjekt");
    
GRANT SELECT ON TABLE "SO_NachrichtlicheUebernahmen"."SO_ForstrechtFlaeche" TO xp_gast;
GRANT ALL ON TABLE "SO_NachrichtlicheUebernahmen"."SO_ForstrechtFlaeche" TO so_user;
COMMENT ON COLUMN "SO_NachrichtlicheUebernahmen"."SO_ForstrechtFlaeche"."gid" IS 'Prim�rschl�ssel, wird automatisch ausgef�llt!';
CREATE TRIGGER "change_to_SO_ForstrechtFlaeche" BEFORE INSERT OR UPDATE OR DELETE ON "SO_NachrichtlicheUebernahmen"."SO_ForstrechtFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "SO_ForstrechtFlaeche_Flaechenobjekt" BEFORE INSERT OR UPDATE ON "SO_NachrichtlicheUebernahmen"."SO_ForstrechtFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isFlaechenobjekt"();

-- -----------------------------------------------------
-- Table "SO_NachrichtlicheUebernahmen"."SO_KlassifizNachDenkmalschutzrecht"
-- -----------------------------------------------------
CREATE TABLE  "SO_NachrichtlicheUebernahmen"."SO_KlassifizNachDenkmalschutzrecht" (
  "Code" INTEGER NOT NULL,
  "Bezeichner" VARCHAR(64) NOT NULL,
  PRIMARY KEY ("Code"));
  
GRANT SELECT ON TABLE "SO_NachrichtlicheUebernahmen"."SO_KlassifizNachDenkmalschutzrecht" TO xp_gast;

-- -----------------------------------------------------
-- Table "SO_NachrichtlicheUebernahmen"."SO_DetailKlassifizNachDenkmalschutzrecht"
-- -----------------------------------------------------
CREATE TABLE  "SO_NachrichtlicheUebernahmen"."SO_DetailKlassifizNachDenkmalschutzrecht" (
  "Code" INTEGER NOT NULL,
  "Bezeichner" VARCHAR(64) NOT NULL,
  PRIMARY KEY ("Code"));

GRANT SELECT ON TABLE "SO_NachrichtlicheUebernahmen"."SO_DetailKlassifizNachDenkmalschutzrecht" TO xp_gast;
GRANT ALL ON TABLE "SO_NachrichtlicheUebernahmen"."SO_DetailKlassifizNachDenkmalschutzrecht" TO so_user;

-- -----------------------------------------------------
-- Table "SO_NachrichtlicheUebernahmen"."SO_Denkmalschutzrecht"
-- -----------------------------------------------------
CREATE TABLE  "SO_NachrichtlicheUebernahmen"."SO_Denkmalschutzrecht" (
  "gid" BIGINT NOT NULL,
  "artDerFestlegung" INTEGER NULL,
  "detailArtDerFestlegung" INTEGER NULL,
  "weltkulturerbe" BOOLEAN NULL DEFAULT 'f',
  "name" VARCHAR(64) NULL,
  "nummer" VARCHAR(64) NULL,
  PRIMARY KEY ("gid"),
  CONSTRAINT "fk_SO_Denkmalschutzrecht_SO_Objekt1"
    FOREIGN KEY ("gid")
    REFERENCES "SO_Basisobjekte"."SO_Objekt" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_SO_Denkmalschutzrecht_artDerFestlegung"
    FOREIGN KEY ("artDerFestlegung")
    REFERENCES "SO_NachrichtlicheUebernahmen"."SO_KlassifizNachDenkmalschutzrecht" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_SO_Denkmalschutzrecht_detailArtDerFestlegung"
    FOREIGN KEY ("detailArtDerFestlegung")
    REFERENCES "SO_NachrichtlicheUebernahmen"."SO_DetailKlassifizNachDenkmalschutzrecht" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE);

CREATE INDEX "idx_fk_SO_Denkmalschutzrecht_artDerFestlegung_idx" ON "SO_NachrichtlicheUebernahmen"."SO_Denkmalschutzrecht" ("artDerFestlegung");
CREATE INDEX "idx_fk_SO_Denkmalschutzrecht_detailArtDerFestlegung_idx" ON "SO_NachrichtlicheUebernahmen"."SO_Denkmalschutzrecht" ("detailArtDerFestlegung");
GRANT SELECT ON TABLE "SO_NachrichtlicheUebernahmen"."SO_Denkmalschutzrecht" TO xp_gast;
GRANT ALL ON TABLE "SO_NachrichtlicheUebernahmen"."SO_Denkmalschutzrecht" TO so_user;
COMMENT ON TABLE "SO_NachrichtlicheUebernahmen"."SO_Denkmalschutzrecht" IS 'Festlegung nach Denkmalschutzrecht.';
COMMENT ON COLUMN "SO_NachrichtlicheUebernahmen"."SO_Denkmalschutzrecht"."gid" IS 'Prim�rschl�ssel, wird automatisch ausgef�llt!';
COMMENT ON COLUMN "SO_NachrichtlicheUebernahmen"."SO_Denkmalschutzrecht"."artDerFestlegung" IS 'Grundlegende rechtliche Klassifizierung der Festlegung';
COMMENT ON COLUMN "SO_NachrichtlicheUebernahmen"."SO_Denkmalschutzrecht"."detailArtDerFestlegung" IS 'Detaillierte rechtliche Klassifizierung der Festlegung.';
COMMENT ON COLUMN "SO_NachrichtlicheUebernahmen"."SO_Denkmalschutzrecht"."weltkulturerbe" IS '';
COMMENT ON COLUMN "SO_NachrichtlicheUebernahmen"."SO_Denkmalschutzrecht"."name" IS 'Informelle Bezeichnung der Festlegung.';
COMMENT ON COLUMN "SO_NachrichtlicheUebernahmen"."SO_Denkmalschutzrecht"."nummer" IS 'Amtliche Bezeichnung / Kennziffer der Festlegung.';
CREATE TRIGGER "change_to_SO_Denkmalschutzrecht" BEFORE INSERT OR UPDATE OR DELETE ON "SO_NachrichtlicheUebernahmen"."SO_Denkmalschutzrecht" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();


-- -----------------------------------------------------
-- Table "SO_NachrichtlicheUebernahmen"."SO_DenkmalschutzrechtPunkt"
-- -----------------------------------------------------
CREATE TABLE  "SO_NachrichtlicheUebernahmen"."SO_DenkmalschutzrechtPunkt" (
  "gid" BIGINT NOT NULL,
  PRIMARY KEY ("gid"),
  CONSTRAINT "fk_SO_DenkmalschutzrechtPunkt_parent"
    FOREIGN KEY ("gid")
    REFERENCES "SO_NachrichtlicheUebernahmen"."SO_Denkmalschutzrecht" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("SO_Basisobjekte"."SO_Punktobjekt");    
    
GRANT SELECT ON TABLE "SO_NachrichtlicheUebernahmen"."SO_DenkmalschutzrechtPunkt" TO xp_gast;
GRANT ALL ON TABLE "SO_NachrichtlicheUebernahmen"."SO_DenkmalschutzrechtPunkt" TO so_user;
COMMENT ON COLUMN "SO_NachrichtlicheUebernahmen"."SO_DenkmalschutzrechtPunkt"."gid" IS 'Prim�rschl�ssel, wird automatisch ausgef�llt!';
CREATE TRIGGER "change_to_SO_DenkmalschutzrechtPunkt" BEFORE INSERT OR UPDATE OR DELETE ON "SO_NachrichtlicheUebernahmen"."SO_DenkmalschutzrechtPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "SO_NachrichtlicheUebernahmen"."SO_DenkmalschutzrechtLinie"
-- -----------------------------------------------------
CREATE TABLE  "SO_NachrichtlicheUebernahmen"."SO_DenkmalschutzrechtLinie" (
  "gid" BIGINT NOT NULL,
  PRIMARY KEY ("gid"),
  CONSTRAINT "fk_SO_DenkmalschutzrechtLinie_parent"
    FOREIGN KEY ("gid")
    REFERENCES "SO_NachrichtlicheUebernahmen"."SO_Denkmalschutzrecht" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("SO_Basisobjekte"."SO_Linienobjekt");  
    
GRANT SELECT ON TABLE "SO_NachrichtlicheUebernahmen"."SO_DenkmalschutzrechtLinie" TO xp_gast;
GRANT ALL ON TABLE "SO_NachrichtlicheUebernahmen"."SO_DenkmalschutzrechtLinie" TO so_user;
COMMENT ON COLUMN "SO_NachrichtlicheUebernahmen"."SO_DenkmalschutzrechtLinie"."gid" IS 'Prim�rschl�ssel, wird automatisch ausgef�llt!';
CREATE TRIGGER "change_to_SO_DenkmalschutzrechtLinie" BEFORE INSERT OR UPDATE OR DELETE ON "SO_NachrichtlicheUebernahmen"."SO_DenkmalschutzrechtLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "SO_NachrichtlicheUebernahmen"."SO_DenkmalschutzrechtFlaeche"
-- -----------------------------------------------------
CREATE TABLE  "SO_NachrichtlicheUebernahmen"."SO_DenkmalschutzrechtFlaeche" (
  "gid" BIGINT NOT NULL,
  PRIMARY KEY ("gid"),
  CONSTRAINT "fk_SO_DenkmalschutzrechtFlaeche_parent"
    FOREIGN KEY ("gid")
    REFERENCES "SO_NachrichtlicheUebernahmen"."SO_Denkmalschutzrecht" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("SO_Basisobjekte"."SO_Flaechenobjekt");
    
GRANT SELECT ON TABLE "SO_NachrichtlicheUebernahmen"."SO_DenkmalschutzrechtFlaeche" TO xp_gast;
GRANT ALL ON TABLE "SO_NachrichtlicheUebernahmen"."SO_DenkmalschutzrechtFlaeche" TO so_user;
COMMENT ON COLUMN "SO_NachrichtlicheUebernahmen"."SO_DenkmalschutzrechtFlaeche"."gid" IS 'Prim�rschl�ssel, wird automatisch ausgef�llt!';
CREATE TRIGGER "change_to_SO_DenkmalschutzrechtFlaeche" BEFORE INSERT OR UPDATE OR DELETE ON "SO_NachrichtlicheUebernahmen"."SO_DenkmalschutzrechtFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "SO_DenkmalschutzrechtFlaeche_Flaechenobjekt" BEFORE INSERT OR UPDATE ON "SO_NachrichtlicheUebernahmen"."SO_DenkmalschutzrechtFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isFlaechenobjekt"();

-- -----------------------------------------------------
-- Table "SO_NachrichtlicheUebernahmen"."SO_KlassifizNachSonstigemRecht"
-- -----------------------------------------------------
CREATE TABLE  "SO_NachrichtlicheUebernahmen"."SO_KlassifizNachSonstigemRecht" (
  "Code" INTEGER NOT NULL,
  "Bezeichner" VARCHAR(64) NOT NULL,
  PRIMARY KEY ("Code"));

GRANT SELECT ON TABLE "SO_NachrichtlicheUebernahmen"."SO_KlassifizNachSonstigemRecht" TO xp_gast;

-- -----------------------------------------------------
-- Table "SO_NachrichtlicheUebernahmen"."SO_DetailKlassifizNachSonstigemRecht"
-- -----------------------------------------------------
CREATE TABLE  "SO_NachrichtlicheUebernahmen"."SO_DetailKlassifizNachSonstigemRecht" (
  "Code" INTEGER NOT NULL,
  "Bezeichner" VARCHAR(64) NOT NULL,
  PRIMARY KEY ("Code"));
  
GRANT SELECT ON TABLE "SO_NachrichtlicheUebernahmen"."SO_DetailKlassifizNachSonstigemRecht" TO xp_gast;
GRANT ALL ON TABLE "SO_NachrichtlicheUebernahmen"."SO_DetailKlassifizNachSonstigemRecht" TO so_user;

-- -----------------------------------------------------
-- Table "SO_NachrichtlicheUebernahmen"."SO_SonstigesRecht"
-- -----------------------------------------------------
CREATE TABLE  "SO_NachrichtlicheUebernahmen"."SO_SonstigesRecht" (
  "gid" BIGINT NOT NULL,
  "artDerFestlegung" INTEGER NULL,
  "detailArtDerFestlegung" INTEGER NULL,
  "name" VARCHAR(64) NULL,
  "nummer" VARCHAR(64) NULL,
  PRIMARY KEY ("gid"),
  CONSTRAINT "fk_SO_SonstigesRecht_SO_Objekt1"
    FOREIGN KEY ("gid")
    REFERENCES "SO_Basisobjekte"."SO_Objekt" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_SO_SonstigesRecht_artDerFestlegung"
    FOREIGN KEY ("artDerFestlegung")
    REFERENCES "SO_NachrichtlicheUebernahmen"."SO_KlassifizNachSonstigemRecht" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_SO_SonstigesRecht_detailArtDerFestlegung"
    FOREIGN KEY ("detailArtDerFestlegung")
    REFERENCES "SO_NachrichtlicheUebernahmen"."SO_DetailKlassifizNachSonstigemRecht" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE);

CREATE INDEX "idx_fk_SO_SonstigesRecht_artDerFestlegung_idx" ON "SO_NachrichtlicheUebernahmen"."SO_SonstigesRecht" ("artDerFestlegung");
CREATE INDEX "idx_fk_SO_SonstigesRecht_detailArtDerFestlegung_idx" ON "SO_NachrichtlicheUebernahmen"."SO_SonstigesRecht" ("detailArtDerFestlegung");

GRANT SELECT ON TABLE "SO_NachrichtlicheUebernahmen"."SO_SonstigesRecht" TO xp_gast;
GRANT ALL ON TABLE "SO_NachrichtlicheUebernahmen"."SO_SonstigesRecht" TO so_user;
COMMENT ON TABLE "SO_NachrichtlicheUebernahmen"."SO_SonstigesRecht" IS 'Sonstige Festlegung.';
COMMENT ON COLUMN "SO_NachrichtlicheUebernahmen"."SO_SonstigesRecht"."gid" IS 'Prim�rschl�ssel, wird automatisch ausgef�llt!';
COMMENT ON COLUMN "SO_NachrichtlicheUebernahmen"."SO_SonstigesRecht"."artDerFestlegung" IS 'Grundlegende rechtliche Klassifizierung der Festlegung
Bauschutzbereich: Bauschutzbereich zur Hindernis�berwachung f�r Flugpl�tze nach LuftVG.
Berggesetz: Beschr�nkung nach Berggesetz
Richtfunkverbindung: Baubeschr�nkungen durch Richtfunkverbindungen
VermessungsKatasterrecht: Beschr�nkungen nach Vermessungs- und Katasterrecht';
COMMENT ON COLUMN "SO_NachrichtlicheUebernahmen"."SO_SonstigesRecht"."detailArtDerFestlegung" IS 'Detaillierte rechtliche Klassifizierung der Festlegung.';
COMMENT ON COLUMN "SO_NachrichtlicheUebernahmen"."SO_SonstigesRecht"."name" IS 'Informelle Bezeichnung der Festlegung.';
COMMENT ON COLUMN "SO_NachrichtlicheUebernahmen"."SO_SonstigesRecht"."nummer" IS 'Amtliche Bezeichnung / Kennziffer der Festlegung.';
CREATE TRIGGER "change_to_SO_SonstigesRecht" BEFORE INSERT OR UPDATE OR DELETE ON "SO_NachrichtlicheUebernahmen"."SO_SonstigesRecht" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "SO_NachrichtlicheUebernahmen"."SO_SonstigesRechtPunkt"
-- -----------------------------------------------------
CREATE TABLE  "SO_NachrichtlicheUebernahmen"."SO_SonstigesRechtPunkt" (
  "gid" BIGINT NOT NULL,
  PRIMARY KEY ("gid"),
  CONSTRAINT "fk_SO_SonstigesRechtPunkt_SO_SonstigesRecht1"
    FOREIGN KEY ("gid")
    REFERENCES "SO_NachrichtlicheUebernahmen"."SO_SonstigesRecht" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("SO_Basisobjekte"."SO_Punktobjekt");    
    
GRANT SELECT ON TABLE "SO_NachrichtlicheUebernahmen"."SO_SonstigesRechtPunkt" TO xp_gast;
GRANT ALL ON TABLE "SO_NachrichtlicheUebernahmen"."SO_SonstigesRechtPunkt" TO so_user;
COMMENT ON COLUMN "SO_NachrichtlicheUebernahmen"."SO_SonstigesRechtPunkt"."gid" IS 'Prim�rschl�ssel, wird automatisch ausgef�llt!';
CREATE TRIGGER "change_to_SO_SonstigesRechtPunkt" BEFORE INSERT OR UPDATE OR DELETE ON "SO_NachrichtlicheUebernahmen"."SO_SonstigesRechtPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "SO_NachrichtlicheUebernahmen"."SO_SonstigesRechtLinie"
-- -----------------------------------------------------
CREATE TABLE  "SO_NachrichtlicheUebernahmen"."SO_SonstigesRechtLinie" (
  "gid" BIGINT NOT NULL,
  PRIMARY KEY ("gid"),
  CONSTRAINT "fk_SO_SonstigesRechtLinie_SO_SonstigesRecht1"
    FOREIGN KEY ("gid")
    REFERENCES "SO_NachrichtlicheUebernahmen"."SO_SonstigesRecht" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("SO_Basisobjekte"."SO_Linienobjekt");  
    
GRANT SELECT ON TABLE "SO_NachrichtlicheUebernahmen"."SO_SonstigesRechtLinie" TO xp_gast;
GRANT ALL ON TABLE "SO_NachrichtlicheUebernahmen"."SO_SonstigesRechtLinie" TO so_user;
COMMENT ON COLUMN "SO_NachrichtlicheUebernahmen"."SO_SonstigesRechtLinie"."gid" IS 'Prim�rschl�ssel, wird automatisch ausgef�llt!';
CREATE TRIGGER "change_to_SO_SonstigesRechtLinie" BEFORE INSERT OR UPDATE OR DELETE ON "SO_NachrichtlicheUebernahmen"."SO_SonstigesRechtLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "SO_NachrichtlicheUebernahmen"."SO_SonstigesRechtFlaeche"
-- -----------------------------------------------------
CREATE TABLE  "SO_NachrichtlicheUebernahmen"."SO_SonstigesRechtFlaeche" (
  "gid" BIGINT NOT NULL,
  PRIMARY KEY ("gid"),
  CONSTRAINT "fk_SO_SonstigesRechtFlaeche_SO_SonstigesRecht1"
    FOREIGN KEY ("gid")
    REFERENCES "SO_NachrichtlicheUebernahmen"."SO_SonstigesRecht" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("SO_Basisobjekte"."SO_Flaechenobjekt");
    
GRANT SELECT ON TABLE "SO_NachrichtlicheUebernahmen"."SO_SonstigesRechtFlaeche" TO xp_gast;
GRANT ALL ON TABLE "SO_NachrichtlicheUebernahmen"."SO_SonstigesRechtFlaeche" TO so_user;
COMMENT ON COLUMN "SO_NachrichtlicheUebernahmen"."SO_SonstigesRechtFlaeche"."gid" IS 'Prim�rschl�ssel, wird automatisch ausgef�llt!';
CREATE TRIGGER "change_to_SO_SonstigesRechtFlaeche" BEFORE INSERT OR UPDATE OR DELETE ON "SO_NachrichtlicheUebernahmen"."SO_SonstigesRechtFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "SO_SonstigesRechtFlaeche_Flaechenobjekt" BEFORE INSERT OR UPDATE ON "SO_NachrichtlicheUebernahmen"."SO_SonstigesRechtFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isFlaechenobjekt"();

-- -----------------------------------------------------
-- Table "SO_NachrichtlicheUebernahmen"."SO_KlassifizNachSchienenverkehrsrecht"
-- -----------------------------------------------------
CREATE TABLE  "SO_NachrichtlicheUebernahmen"."SO_KlassifizNachSchienenverkehrsrecht" (
  "Code" INTEGER NOT NULL,
  "Bezeichner" VARCHAR(64) NOT NULL,
  PRIMARY KEY ("Code"));
  
GRANT SELECT ON TABLE "SO_NachrichtlicheUebernahmen"."SO_KlassifizNachSchienenverkehrsrecht" TO xp_gast;

-- -----------------------------------------------------
-- Table "SO_NachrichtlicheUebernahmen"."SO_BesondereKlassifizNachSchienenverkehrsrecht"
-- -----------------------------------------------------
CREATE TABLE  "SO_NachrichtlicheUebernahmen"."SO_BesondereKlassifizNachSchienenverkehrsrecht" (
  "Code" INTEGER NOT NULL,
  "bezeichner" VARCHAR(64) NOT NULL,
  PRIMARY KEY ("Code"));
GRANT SELECT ON TABLE "SO_NachrichtlicheUebernahmen"."SO_BesondereKlassifizNachSchienenverkehrsrecht" TO xp_gast;

-- -----------------------------------------------------
-- Table "SO_NachrichtlicheUebernahmen"."SO_DetailKlassifizNachSchienenverkehrsrecht"
-- -----------------------------------------------------
CREATE TABLE  "SO_NachrichtlicheUebernahmen"."SO_DetailKlassifizNachSchienenverkehrsrecht" (
  "Code" INTEGER NOT NULL,
  "Bezeichner" VARCHAR(64) NOT NULL,
  PRIMARY KEY ("Code"));
GRANT SELECT ON TABLE "SO_NachrichtlicheUebernahmen"."SO_DetailKlassifizNachSchienenverkehrsrecht" TO xp_gast;
GRANT ALL ON TABLE "SO_NachrichtlicheUebernahmen"."SO_DetailKlassifizNachSchienenverkehrsrecht" TO so_user;

-- -----------------------------------------------------
-- Table "SO_NachrichtlicheUebernahmen"."SO_Schienenverkehrsrecht"
-- -----------------------------------------------------
CREATE TABLE  "SO_NachrichtlicheUebernahmen"."SO_Schienenverkehrsrecht" (
  "gid" BIGINT NOT NULL,
  "artDerFestlegung" INTEGER NULL,
  "besondereArtDerFestlegung" INTEGER NULL,
  "detailArtDerFestlegung" INTEGER NULL,
  "name" VARCHAR(64) NULL,
  "nummer" VARCHAR(64) NULL,
  PRIMARY KEY ("gid"),
  CONSTRAINT "fk_SO_Schienenverkehrsrecht_SO_Objekt1"
    FOREIGN KEY ("gid")
    REFERENCES "SO_Basisobjekte"."SO_Objekt" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_SO_Schienenverkehrsrecht_artDerFestlegung"
    FOREIGN KEY ("artDerFestlegung")
    REFERENCES "SO_NachrichtlicheUebernahmen"."SO_KlassifizNachSchienenverkehrsrecht" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_SO_Schienenverkehrsrecht_besondereArtDerFestlegung"
    FOREIGN KEY ("besondereArtDerFestlegung")
    REFERENCES "SO_NachrichtlicheUebernahmen"."SO_BesondereKlassifizNachSchienenverkehrsrecht" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_SO_Schienenverkehrsrecht_detailArtDerFestlegung"
    FOREIGN KEY ("detailArtDerFestlegung")
    REFERENCES "SO_NachrichtlicheUebernahmen"."SO_DetailKlassifizNachSchienenverkehrsrecht" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE);

CREATE INDEX "idx_fk_SO_Schienenverkehrsrecht_artDerFestlegung_idx" ON "SO_NachrichtlicheUebernahmen"."SO_Schienenverkehrsrecht" ("artDerFestlegung");
CREATE INDEX "idx_fk_SO_Schienenverkehrsrecht_besondereArtDerFestlegung_idx" ON "SO_NachrichtlicheUebernahmen"."SO_Schienenverkehrsrecht" ("besondereArtDerFestlegung");
CREATE INDEX "idx_fk_SO_Schienenverkehrsrecht_detailArtDerFestlegung_idx" ON "SO_NachrichtlicheUebernahmen"."SO_Schienenverkehrsrecht" ("detailArtDerFestlegung");
GRANT SELECT ON TABLE "SO_NachrichtlicheUebernahmen"."SO_Schienenverkehrsrecht" TO xp_gast;
GRANT ALL ON TABLE "SO_NachrichtlicheUebernahmen"."SO_Schienenverkehrsrecht" TO so_user;
COMMENT ON TABLE "SO_NachrichtlicheUebernahmen"."SO_Schienenverkehrsrecht" IS 'Festlegung nach Schienenverkehrsrecht.';
COMMENT ON COLUMN "SO_NachrichtlicheUebernahmen"."SO_Schienenverkehrsrecht"."gid" IS 'Prim�rschl�ssel, wird automatisch ausgef�llt!';
COMMENT ON COLUMN "SO_NachrichtlicheUebernahmen"."SO_Schienenverkehrsrecht"."artDerFestlegung" IS 'Grundlegende Klassifizierung der Festlegung';
COMMENT ON COLUMN "SO_NachrichtlicheUebernahmen"."SO_Schienenverkehrsrecht"."besondereArtDerFestlegung" IS '';
COMMENT ON COLUMN "SO_NachrichtlicheUebernahmen"."SO_Schienenverkehrsrecht"."detailArtDerFestlegung" IS 'Detaillierte Klassifizierung der Festlegung.';
COMMENT ON COLUMN "SO_NachrichtlicheUebernahmen"."SO_Schienenverkehrsrecht"."name" IS 'Informelle Bezeichnung der Festlegung.';
COMMENT ON COLUMN "SO_NachrichtlicheUebernahmen"."SO_Schienenverkehrsrecht"."nummer" IS 'Amtliche Bezeichnung / Kennziffer der Festlegung.';
CREATE TRIGGER "change_to_SO_Schienenverkehrsrecht" BEFORE INSERT OR UPDATE OR DELETE ON "SO_NachrichtlicheUebernahmen"."SO_Schienenverkehrsrecht" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "SO_NachrichtlicheUebernahmen"."SO_SchienenverkehrsrechtPunkt"
-- -----------------------------------------------------
CREATE TABLE  "SO_NachrichtlicheUebernahmen"."SO_SchienenverkehrsrechtPunkt" (
  "gid" BIGINT NOT NULL,
  PRIMARY KEY ("gid"),
  CONSTRAINT "fk_SO_SchienenverkehrsrechtPunkt_parent"
    FOREIGN KEY ("gid")
    REFERENCES "SO_NachrichtlicheUebernahmen"."SO_Schienenverkehrsrecht" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("SO_Basisobjekte"."SO_Punktobjekt");    
    
GRANT SELECT ON TABLE "SO_NachrichtlicheUebernahmen"."SO_SchienenverkehrsrechtPunkt" TO xp_gast;
GRANT ALL ON TABLE "SO_NachrichtlicheUebernahmen"."SO_SchienenverkehrsrechtPunkt" TO so_user;
COMMENT ON COLUMN "SO_NachrichtlicheUebernahmen"."SO_SchienenverkehrsrechtPunkt"."gid" IS 'Prim�rschl�ssel, wird automatisch ausgef�llt!';
CREATE TRIGGER "change_to_SO_SchienenverkehrsrechtPunkt" BEFORE INSERT OR UPDATE OR DELETE ON "SO_NachrichtlicheUebernahmen"."SO_SchienenverkehrsrechtPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "SO_NachrichtlicheUebernahmen"."SO_SchienenverkehrsrechtLinie"
-- -----------------------------------------------------
CREATE TABLE  "SO_NachrichtlicheUebernahmen"."SO_SchienenverkehrsrechtLinie" (
  "gid" BIGINT NOT NULL,
  PRIMARY KEY ("gid"),
  CONSTRAINT "fk_SO_SchienenverkehrsrechtLinie_parent"
    FOREIGN KEY ("gid")
    REFERENCES "SO_NachrichtlicheUebernahmen"."SO_Schienenverkehrsrecht" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("SO_Basisobjekte"."SO_Linienobjekt");  
    
GRANT SELECT ON TABLE "SO_NachrichtlicheUebernahmen"."SO_SchienenverkehrsrechtLinie" TO xp_gast;
GRANT ALL ON TABLE "SO_NachrichtlicheUebernahmen"."SO_SchienenverkehrsrechtLinie" TO so_user;
COMMENT ON COLUMN "SO_NachrichtlicheUebernahmen"."SO_SchienenverkehrsrechtLinie"."gid" IS 'Prim�rschl�ssel, wird automatisch ausgef�llt!';
CREATE TRIGGER "change_to_SO_SchienenverkehrsrechtLinie" BEFORE INSERT OR UPDATE OR DELETE ON "SO_NachrichtlicheUebernahmen"."SO_SchienenverkehrsrechtLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "SO_NachrichtlicheUebernahmen"."SO_SchienenverkehrsrechtFlaeche"
-- -----------------------------------------------------
CREATE TABLE  "SO_NachrichtlicheUebernahmen"."SO_SchienenverkehrsrechtFlaeche" (
  "gid" BIGINT NOT NULL,
  PRIMARY KEY ("gid"),
  CONSTRAINT "fk_SO_SchienenverkehrsrechtFlaeche_parent"
    FOREIGN KEY ("gid")
    REFERENCES "SO_NachrichtlicheUebernahmen"."SO_Schienenverkehrsrecht" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("SO_Basisobjekte"."SO_Flaechenobjekt");
    
GRANT SELECT ON TABLE "SO_NachrichtlicheUebernahmen"."SO_SchienenverkehrsrechtFlaeche" TO xp_gast;
GRANT ALL ON TABLE "SO_NachrichtlicheUebernahmen"."SO_SchienenverkehrsrechtFlaeche" TO so_user;
COMMENT ON COLUMN "SO_NachrichtlicheUebernahmen"."SO_SchienenverkehrsrechtFlaeche"."gid" IS 'Prim�rschl�ssel, wird automatisch ausgef�llt!';
CREATE TRIGGER "change_to_SO_SchienenverkehrsrechtFlaeche" BEFORE INSERT OR UPDATE OR DELETE ON "SO_NachrichtlicheUebernahmen"."SO_SchienenverkehrsrechtFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "SO_SchienenverkehrsrechtFlaeche_Flaechenobjekt" BEFORE INSERT OR UPDATE ON "SO_NachrichtlicheUebernahmen"."SO_SchienenverkehrsrechtFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isFlaechenobjekt"();

-- -----------------------------------------------------
-- Table "SO_NachrichtlicheUebernahmen"."SO_KlassifizNachLuftverkehrsrecht"
-- -----------------------------------------------------
CREATE TABLE  "SO_NachrichtlicheUebernahmen"."SO_KlassifizNachLuftverkehrsrecht" (
  "Code" INTEGER NOT NULL,
  "Bezeichner" VARCHAR(64) NOT NULL,
  PRIMARY KEY ("Code"));
  
GRANT SELECT ON TABLE "SO_NachrichtlicheUebernahmen"."SO_KlassifizNachLuftverkehrsrecht" TO xp_gast;

-- -----------------------------------------------------
-- Table "SO_NachrichtlicheUebernahmen"."SO_DetailKlassifizNachLuftverkehrsrecht"
-- -----------------------------------------------------
CREATE TABLE  "SO_NachrichtlicheUebernahmen"."SO_DetailKlassifizNachLuftverkehrsrecht" (
  "Code" INTEGER NOT NULL,
  "Bezeichner" VARCHAR(64) NOT NULL,
  PRIMARY KEY ("Code"));

GRANT SELECT ON TABLE "SO_NachrichtlicheUebernahmen"."SO_DetailKlassifizNachLuftverkehrsrecht" TO xp_gast;
GRANT ALL ON TABLE "SO_NachrichtlicheUebernahmen"."SO_DetailKlassifizNachLuftverkehrsrecht" TO so_user;

-- -----------------------------------------------------
-- Table "SO_NachrichtlicheUebernahmen"."SO_LaermschutzzoneTypen"
-- -----------------------------------------------------
CREATE TABLE  "SO_NachrichtlicheUebernahmen"."SO_LaermschutzzoneTypen" (
  "Code" INTEGER NOT NULL,
  "Bezeichner" VARCHAR(64) NOT NULL,
  PRIMARY KEY ("Code"));

GRANT SELECT ON TABLE "SO_NachrichtlicheUebernahmen"."SO_LaermschutzzoneTypen" TO xp_gast;

-- -----------------------------------------------------
-- Table "SO_NachrichtlicheUebernahmen"."SO_Luftverkehrsrecht"
-- -----------------------------------------------------
CREATE TABLE  "SO_NachrichtlicheUebernahmen"."SO_Luftverkehrsrecht" (
  "gid" BIGINT NOT NULL,
  "artDerFestlegung" INTEGER NULL,
  "detailArtDerFestlegung" INTEGER NULL,
  "name" VARCHAR(64) NULL,
  "nummer" VARCHAR(64) NULL,
  "laermschutzzone" INTEGER NULL,
  PRIMARY KEY ("gid"),
  CONSTRAINT "fk_SO_Luftverkehrsrecht_SO_Objekt1"
    FOREIGN KEY ("gid")
    REFERENCES "SO_Basisobjekte"."SO_Objekt" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_SO_Luftverkehrsrecht_artDerFestlegung"
    FOREIGN KEY ("artDerFestlegung")
    REFERENCES "SO_NachrichtlicheUebernahmen"."SO_KlassifizNachLuftverkehrsrecht" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_SO_Luftverkehrsrecht_detailArtDerFestlegung"
    FOREIGN KEY ("detailArtDerFestlegung")
    REFERENCES "SO_NachrichtlicheUebernahmen"."SO_DetailKlassifizNachLuftverkehrsrecht" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_SO_Luftverkehrsrecht_laermschutzzone"
    FOREIGN KEY ("laermschutzzone")
    REFERENCES "SO_NachrichtlicheUebernahmen"."SO_LaermschutzzoneTypen" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE);

CREATE INDEX "idx_fk_SO_Luftverkehrsrecht_artDerFestlegung_idx" ON "SO_NachrichtlicheUebernahmen"."SO_Luftverkehrsrecht" ("artDerFestlegung");
CREATE INDEX "idx_fk_SO_Luftverkehrsrecht_detailArtDerFestlegung_idx" ON "SO_NachrichtlicheUebernahmen"."SO_Luftverkehrsrecht" ("detailArtDerFestlegung");
GRANT SELECT ON TABLE "SO_NachrichtlicheUebernahmen"."SO_Luftverkehrsrecht" TO xp_gast;
GRANT ALL ON TABLE "SO_NachrichtlicheUebernahmen"."SO_Luftverkehrsrecht" TO so_user;
COMMENT ON TABLE "SO_NachrichtlicheUebernahmen"."SO_Luftverkehrsrecht" IS 'Festlegung nach Luftverkehrsrecht.';
COMMENT ON COLUMN "SO_NachrichtlicheUebernahmen"."SO_Luftverkehrsrecht"."gid" IS 'Prim�rschl�ssel, wird automatisch ausgef�llt!';
COMMENT ON COLUMN "SO_NachrichtlicheUebernahmen"."SO_Luftverkehrsrecht"."artDerFestlegung" IS 'Grundlegende Klassifizierung der Festlegung';
COMMENT ON COLUMN "SO_NachrichtlicheUebernahmen"."SO_Luftverkehrsrecht"."detailArtDerFestlegung" IS 'Detaillierte Klassifizierung der Festlegung.';
COMMENT ON COLUMN "SO_NachrichtlicheUebernahmen"."SO_Luftverkehrsrecht"."name" IS 'Informelle Bezeichnung der Festlegung.';
COMMENT ON COLUMN "SO_NachrichtlicheUebernahmen"."SO_Luftverkehrsrecht"."nummer" IS 'Amtliche Bezeichnung / Kennziffer der Festlegung.';
COMMENT ON COLUMN "SO_NachrichtlicheUebernahmen"."SO_Luftverkehrsrecht"."laermschutzzone" IS 'L�rmschutzzone nach LuftVG';
CREATE TRIGGER "change_to_SO_Luftverkehrsrecht" BEFORE INSERT OR UPDATE OR DELETE ON "SO_NachrichtlicheUebernahmen"."SO_Luftverkehrsrecht" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "SO_NachrichtlicheUebernahmen"."SO_LuftverkehrsrechtPunkt"
-- -----------------------------------------------------
CREATE TABLE  "SO_NachrichtlicheUebernahmen"."SO_LuftverkehrsrechtPunkt" (
  "gid" BIGINT NOT NULL,
  PRIMARY KEY ("gid"),
  CONSTRAINT "fk_SO_LuftverkehrsrechtPunkt_parent"
    FOREIGN KEY ("gid")
    REFERENCES "SO_NachrichtlicheUebernahmen"."SO_Luftverkehrsrecht" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("SO_Basisobjekte"."SO_Punktobjekt");    
    
GRANT SELECT ON TABLE "SO_NachrichtlicheUebernahmen"."SO_LuftverkehrsrechtPunkt" TO xp_gast;
GRANT ALL ON TABLE "SO_NachrichtlicheUebernahmen"."SO_LuftverkehrsrechtPunkt" TO so_user;
COMMENT ON COLUMN "SO_NachrichtlicheUebernahmen"."SO_LuftverkehrsrechtPunkt"."gid" IS 'Prim�rschl�ssel, wird automatisch ausgef�llt!';
CREATE TRIGGER "change_to_SO_LuftverkehrsrechtPunkt" BEFORE INSERT OR UPDATE OR DELETE ON "SO_NachrichtlicheUebernahmen"."SO_LuftverkehrsrechtPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "SO_NachrichtlicheUebernahmen"."SO_LuftverkehrsrechtFlaeche"
-- -----------------------------------------------------
CREATE TABLE  "SO_NachrichtlicheUebernahmen"."SO_LuftverkehrsrechtFlaeche" (
  "gid" BIGINT NOT NULL,
  PRIMARY KEY ("gid"),
  CONSTRAINT "fk_SO_LuftverkehrsrechtFlaeche_parent"
    FOREIGN KEY ("gid")
    REFERENCES "SO_NachrichtlicheUebernahmen"."SO_Luftverkehrsrecht" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("SO_Basisobjekte"."SO_Flaechenobjekt");
    
GRANT SELECT ON TABLE "SO_NachrichtlicheUebernahmen"."SO_LuftverkehrsrechtFlaeche" TO xp_gast;
GRANT ALL ON TABLE "SO_NachrichtlicheUebernahmen"."SO_LuftverkehrsrechtFlaeche" TO so_user;
COMMENT ON COLUMN "SO_NachrichtlicheUebernahmen"."SO_LuftverkehrsrechtFlaeche"."gid" IS 'Prim�rschl�ssel, wird automatisch ausgef�llt!';
CREATE TRIGGER "change_to_SO_LuftverkehrsrechtFlaeche" BEFORE INSERT OR UPDATE OR DELETE ON "SO_NachrichtlicheUebernahmen"."SO_LuftverkehrsrechtFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "SO_LuftverkehrsrechtFlaeche_Flaechenobjekt" BEFORE INSERT OR UPDATE ON "SO_NachrichtlicheUebernahmen"."SO_LuftverkehrsrechtFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isFlaechenobjekt"();

-- -----------------------------------------------------
-- Table "SO_NachrichtlicheUebernahmen"."SO_KlassifizNachBodenschutzrecht"
-- -----------------------------------------------------
CREATE TABLE  "SO_NachrichtlicheUebernahmen"."SO_KlassifizNachBodenschutzrecht" (
  "Code" INTEGER NOT NULL,
  "Bezeichner" VARCHAR(64) NOT NULL,
  PRIMARY KEY ("Code"));
  
GRANT SELECT ON TABLE "SO_NachrichtlicheUebernahmen"."SO_KlassifizNachBodenschutzrecht" TO xp_gast;

-- -----------------------------------------------------
-- Table "SO_NachrichtlicheUebernahmen"."SO_DetailKlassifizNachBodenschutzrecht"
-- -----------------------------------------------------
CREATE TABLE  "SO_NachrichtlicheUebernahmen"."SO_DetailKlassifizNachBodenschutzrecht" (
  "Code" INTEGER NOT NULL,
  "Bezeichner" VARCHAR(64) NOT NULL,
  PRIMARY KEY ("Code"));
  
GRANT SELECT ON TABLE "SO_NachrichtlicheUebernahmen"."SO_DetailKlassifizNachBodenschutzrecht" TO xp_gast;
GRANT ALL ON TABLE "SO_NachrichtlicheUebernahmen"."SO_DetailKlassifizNachBodenschutzrecht" TO so_user;

-- -----------------------------------------------------
-- Table "SO_NachrichtlicheUebernahmen"."SO_Bodenschutzrecht"
-- -----------------------------------------------------
CREATE TABLE  "SO_NachrichtlicheUebernahmen"."SO_Bodenschutzrecht" (
  "gid" BIGINT NOT NULL,
  "artDerFestlegung" INTEGER NULL,
  "detailArtDerFestlegung" INTEGER NULL,
  "istVerdachtsflaeche" BOOLEAN NULL DEFAULT 'f',
  "name" VARCHAR(64) NULL,
  "nummer" VARCHAR(64) NULL,
  PRIMARY KEY ("gid"),
  CONSTRAINT "fk_SO_Bodenschutzrecht_SO_Objekt1"
    FOREIGN KEY ("gid")
    REFERENCES "SO_Basisobjekte"."SO_Objekt" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_SO_Bodenschutzrecht_artDerFestlegung"
    FOREIGN KEY ("artDerFestlegung")
    REFERENCES "SO_NachrichtlicheUebernahmen"."SO_KlassifizNachBodenschutzrecht" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_SO_Bodenschutzrecht_detailArtDerFestlegung"
    FOREIGN KEY ("detailArtDerFestlegung")
    REFERENCES "SO_NachrichtlicheUebernahmen"."SO_DetailKlassifizNachBodenschutzrecht" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE);

CREATE INDEX "idx_fk_SO_Bodenschutzrecht_artDerFestlegung_idx" ON "SO_NachrichtlicheUebernahmen"."SO_Bodenschutzrecht" ("artDerFestlegung");
CREATE INDEX "idx_fk_SO_Bodenschutzrecht_detailArtDerFestlegung_idx" ON "SO_NachrichtlicheUebernahmen"."SO_Bodenschutzrecht" ("detailArtDerFestlegung");
GRANT SELECT ON TABLE "SO_NachrichtlicheUebernahmen"."SO_Bodenschutzrecht" TO xp_gast;
GRANT ALL ON TABLE "SO_NachrichtlicheUebernahmen"."SO_Bodenschutzrecht" TO so_user;
COMMENT ON TABLE "SO_NachrichtlicheUebernahmen"."SO_Bodenschutzrecht" IS 'Festlegung nach Bodenschutzrecht.';
COMMENT ON COLUMN "SO_NachrichtlicheUebernahmen"."SO_Bodenschutzrecht"."gid" IS 'Prim�rschl�ssel, wird automatisch ausgef�llt!';
COMMENT ON COLUMN "SO_NachrichtlicheUebernahmen"."SO_Bodenschutzrecht"."artDerFestlegung" IS 'Grundlegende Klassifizierung der Festlegung';
COMMENT ON COLUMN "SO_NachrichtlicheUebernahmen"."SO_Bodenschutzrecht"."detailArtDerFestlegung" IS 'Detaillierte Klassifizierung der Festlegung.';
COMMENT ON COLUMN "SO_NachrichtlicheUebernahmen"."SO_Bodenschutzrecht"."istVerdachtsflaeche" IS 'Angabe ob es sich um eine Verdachtsfl�che handelt.';
COMMENT ON COLUMN "SO_NachrichtlicheUebernahmen"."SO_Bodenschutzrecht"."name" IS 'Informelle Bezeichnung der Festlegung.';
COMMENT ON COLUMN "SO_NachrichtlicheUebernahmen"."SO_Bodenschutzrecht"."nummer" IS 'Amtliche Bezeichnung / Kennziffer der Festlegung.';
CREATE TRIGGER "change_to_SO_Bodenschutzrecht" BEFORE INSERT OR UPDATE OR DELETE ON "SO_NachrichtlicheUebernahmen"."SO_Bodenschutzrecht" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "SO_NachrichtlicheUebernahmen"."SO_BodenschutzrechtPunkt"
-- -----------------------------------------------------
CREATE TABLE  "SO_NachrichtlicheUebernahmen"."SO_BodenschutzrechtPunkt" (
  "gid" BIGINT NOT NULL,
  PRIMARY KEY ("gid"),
  CONSTRAINT "fk_SO_BodenschutzrechtPunkt_parent"
    FOREIGN KEY ("gid")
    REFERENCES "SO_NachrichtlicheUebernahmen"."SO_Bodenschutzrecht" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("SO_Basisobjekte"."SO_Punktobjekt");    
    
GRANT SELECT ON TABLE "SO_NachrichtlicheUebernahmen"."SO_BodenschutzrechtPunkt" TO xp_gast;
GRANT ALL ON TABLE "SO_NachrichtlicheUebernahmen"."SO_BodenschutzrechtPunkt" TO so_user;
COMMENT ON COLUMN "SO_NachrichtlicheUebernahmen"."SO_BodenschutzrechtPunkt"."gid" IS 'Prim�rschl�ssel, wird automatisch ausgef�llt!';
CREATE TRIGGER "change_to_SO_BodenschutzrechtPunkt" BEFORE INSERT OR UPDATE OR DELETE ON "SO_NachrichtlicheUebernahmen"."SO_BodenschutzrechtPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "SO_NachrichtlicheUebernahmen"."SO_BodenschutzrechtFlaeche"
-- -----------------------------------------------------
CREATE TABLE  "SO_NachrichtlicheUebernahmen"."SO_BodenschutzrechtFlaeche" (
  "gid" BIGINT NOT NULL,
  PRIMARY KEY ("gid"),
  CONSTRAINT "fk_SO_BodenschutzrechtFlaeche_parent"
    FOREIGN KEY ("gid")
    REFERENCES "SO_NachrichtlicheUebernahmen"."SO_Bodenschutzrecht" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("SO_Basisobjekte"."SO_Flaechenobjekt");
    
GRANT SELECT ON TABLE "SO_NachrichtlicheUebernahmen"."SO_BodenschutzrechtFlaeche" TO xp_gast;
GRANT ALL ON TABLE "SO_NachrichtlicheUebernahmen"."SO_BodenschutzrechtFlaeche" TO so_user;
COMMENT ON COLUMN "SO_NachrichtlicheUebernahmen"."SO_BodenschutzrechtFlaeche"."gid" IS 'Prim�rschl�ssel, wird automatisch ausgef�llt!';
CREATE TRIGGER "change_to_SO_BodenschutzrechtFlaeche" BEFORE INSERT OR UPDATE OR DELETE ON "SO_NachrichtlicheUebernahmen"."SO_BodenschutzrechtFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "SO_BodenschutzrechtFlaeche_Flaechenobjekt" BEFORE INSERT OR UPDATE ON "SO_NachrichtlicheUebernahmen"."SO_BodenschutzrechtFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isFlaechenobjekt"();

-- -----------------------------------------------------
-- Table "SO_SonstigeGebiete"."SO_GebietsArt"
-- -----------------------------------------------------
CREATE TABLE  "SO_SonstigeGebiete"."SO_GebietsArt" (
  "Code" INTEGER NOT NULL,
  "Bezeichner" VARCHAR(64) NOT NULL,
  PRIMARY KEY ("Code"));
  
GRANT SELECT ON TABLE "SO_SonstigeGebiete"."SO_GebietsArt" TO xp_gast;

-- -----------------------------------------------------
-- Table "SO_SonstigeGebiete"."SO_SonstGebietsArt"
-- -----------------------------------------------------
CREATE TABLE  "SO_SonstigeGebiete"."SO_SonstGebietsArt" (
  "Code" INTEGER NOT NULL,
  "Bezeichner" VARCHAR(64) NOT NULL,
  PRIMARY KEY ("Code"));
  
GRANT SELECT ON TABLE "SO_SonstigeGebiete"."SO_SonstGebietsArt" TO xp_gast;
GRANT ALL ON TABLE "SO_SonstigeGebiete"."SO_SonstGebietsArt" TO so_user;

-- -----------------------------------------------------
-- Table "SO_SonstigeGebiete"."SO_RechtsstandGebietTyp"
-- -----------------------------------------------------
CREATE TABLE  "SO_SonstigeGebiete"."SO_RechtsstandGebietTyp" (
  "Code" INTEGER NOT NULL,
  "Bezeichner" VARCHAR(64) NOT NULL,
  PRIMARY KEY ("Code"));

GRANT SELECT ON TABLE "SO_SonstigeGebiete"."SO_RechtsstandGebietTyp" TO xp_gast;

-- -----------------------------------------------------
-- Table "SO_SonstigeGebiete"."SO_SonstRechtsstandGebietTyp"
-- -----------------------------------------------------
CREATE TABLE  "SO_SonstigeGebiete"."SO_SonstRechtsstandGebietTyp" (
  "Code" INTEGER NOT NULL,
  "Bezeichner" VARCHAR(64) NOT NULL,
  PRIMARY KEY ("Code"));

GRANT SELECT ON TABLE "SO_SonstigeGebiete"."SO_SonstRechtsstandGebietTyp" TO xp_gast;
GRANT ALL ON TABLE "SO_SonstigeGebiete"."SO_SonstRechtsstandGebietTyp" TO so_user;

-- -----------------------------------------------------
-- Table "SO_SonstigeGebiete"."SO_Gebiet"
-- -----------------------------------------------------
CREATE TABLE  "SO_SonstigeGebiete"."SO_Gebiet" (
  "gid" BIGINT NOT NULL,
  "gemeinde" INTEGER NULL,
  "gebietsArt" INTEGER NULL,
  "sonstGebietsArt" INTEGER NULL,
  "rechtsstandGebiet" INTEGER NULL,
  "sonstRechtsstandGebiet" INTEGER NULL,
  "aufstellungsbeschhlussDatum" DATE NULL,
  "durchfuehrungStartDatum" DATE NULL,
  "durchfuehrungEndDatum" DATE NULL,
  "traegerMassnahme" VARCHAR(64) NULL,
  PRIMARY KEY ("gid"),
  CONSTRAINT "fk_SO_Gebiet_SO_Objekt"
    FOREIGN KEY ("gid")
    REFERENCES "SO_Basisobjekte"."SO_Objekt" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_SO_Gebiet_XP_Gemeinde1"
    FOREIGN KEY ("gemeinde")
    REFERENCES "XP_Sonstiges"."XP_Gemeinde" ("id")
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_SO_Gebiet_gebietsArt"
    FOREIGN KEY ("gebietsArt")
    REFERENCES "SO_SonstigeGebiete"."SO_GebietsArt" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_SO_Gebiet_sonstGebietsArt"
    FOREIGN KEY ("sonstGebietsArt")
    REFERENCES "SO_SonstigeGebiete"."SO_SonstGebietsArt" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_SO_Gebiet_rechtsstandGebiet"
    FOREIGN KEY ("rechtsstandGebiet")
    REFERENCES "SO_SonstigeGebiete"."SO_RechtsstandGebietTyp" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_SO_Gebiet_sonstRechtsstandGebiet"
    FOREIGN KEY ("sonstRechtsstandGebiet")
    REFERENCES "SO_SonstigeGebiete"."SO_SonstRechtsstandGebietTyp" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE)
INHERITS("SO_Basisobjekte"."SO_Flaechenobjekt");

CREATE INDEX "idx_fk_SO_Gebiet_XP_Gemeinde1_idx" ON "SO_SonstigeGebiete"."SO_Gebiet" ("gemeinde");
CREATE INDEX "idx_fk_SO_Gebiet_gebietsArt_idx" ON "SO_SonstigeGebiete"."SO_Gebiet" ("gebietsArt");
CREATE INDEX "idx_fk_SO_Gebiet_sonstGebietsArt_idx" ON "SO_SonstigeGebiete"."SO_Gebiet" ("sonstGebietsArt");
CREATE INDEX "idx_fk_SO_Gebiet_rechtsstandGebiet_idx" ON "SO_SonstigeGebiete"."SO_Gebiet" ("rechtsstandGebiet");
CREATE INDEX "idx_fk_SO_Gebiet_sonstRechtsstandGebiet_idx" ON "SO_SonstigeGebiete"."SO_Gebiet" ("sonstRechtsstandGebiet");
GRANT SELECT ON TABLE "SO_SonstigeGebiete"."SO_Gebiet" TO xp_gast;
GRANT ALL ON TABLE "SO_SonstigeGebiete"."SO_Gebiet" TO so_user;
COMMENT ON TABLE "SO_SonstigeGebiete"."SO_Gebiet" IS 'Umgrenzung eines sonstigen Gebietes nach BauGB';
COMMENT ON COLUMN "SO_SonstigeGebiete"."SO_Gebiet"."gid" IS 'Prim�rschl�ssel, wird automatisch ausgef�llt!';
COMMENT ON COLUMN "SO_SonstigeGebiete"."SO_Gebiet"."gemeinde" IS 'Zust�ndige Gemeinde';
COMMENT ON COLUMN "SO_SonstigeGebiete"."SO_Gebiet"."gebietsArt" IS 'Klassifikation des Gebietes nach BauGB.';
COMMENT ON COLUMN "SO_SonstigeGebiete"."SO_Gebiet"."sonstGebietsArt" IS 'Klassifikation einer nicht auf dem BauGB, z.B. l�nderspezifischen Gebietsausweisung.';
COMMENT ON COLUMN "SO_SonstigeGebiete"."SO_Gebiet"."rechtsstandGebiet" IS 'Rechtsstand der Gebietsausweisung';
COMMENT ON COLUMN "SO_SonstigeGebiete"."SO_Gebiet"."sonstRechtsstandGebiet" IS 'Sonstiger Rechtsstand der Gebietsausweisung, der nicht durch die Liste rechtsstandGebiet wiedergegeben werden kann.';
COMMENT ON COLUMN "SO_SonstigeGebiete"."SO_Gebiet"."aufstellungsbeschhlussDatum" IS 'Datum des Aufstellungsbeschlusses';
COMMENT ON COLUMN "SO_SonstigeGebiete"."SO_Gebiet"."durchfuehrungStartDatum" IS 'Start-Datum der Durchf�hrung';
COMMENT ON COLUMN "SO_SonstigeGebiete"."SO_Gebiet"."durchfuehrungEndDatum" IS 'End-Datum der Durchf�hrung';
COMMENT ON COLUMN "SO_SonstigeGebiete"."SO_Gebiet"."traegerMassnahme" IS '';
CREATE TRIGGER "change_to_SO_Gebiet" BEFORE INSERT OR UPDATE OR DELETE ON "SO_SonstigeGebiete"."SO_Gebiet" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "SO_Gebiet_Flaechenobjekt" BEFORE INSERT OR UPDATE ON "SO_SonstigeGebiete"."SO_Gebiet" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isFlaechenobjekt"();

-- -----------------------------------------------------
-- Table "SO_Sonstiges"."SO_GrenzeTypen"
-- -----------------------------------------------------
CREATE TABLE  "SO_Sonstiges"."SO_GrenzeTypen" (
  "Code" INTEGER NOT NULL,
  "Bezeichner" VARCHAR(64) NOT NULL,
  PRIMARY KEY ("Code"));
  
GRANT SELECT ON TABLE "SO_Sonstiges"."SO_GrenzeTypen" TO xp_gast;

-- -----------------------------------------------------
-- Table "SO_Sonstiges"."SO_SonstGrenzeTypen"
-- -----------------------------------------------------
CREATE TABLE  "SO_Sonstiges"."SO_SonstGrenzeTypen" (
  "Code" INTEGER NOT NULL,
  "Bezeichner" VARCHAR(64) NOT NULL,
  PRIMARY KEY ("Code"));

GRANT SELECT ON TABLE "SO_Sonstiges"."SO_SonstGrenzeTypen" TO xp_gast;
GRANT ALL ON TABLE "SO_Sonstiges"."SO_SonstGrenzeTypen" TO so_user;

-- -----------------------------------------------------
-- Table "SO_Sonstiges"."SO_Grenze"
-- -----------------------------------------------------
CREATE TABLE  "SO_Sonstiges"."SO_Grenze" (
  "gid" BIGINT NOT NULL,
  "typ" INTEGER NULL,
  "sonstTyp" INTEGER NULL,
  PRIMARY KEY ("gid"),
  CONSTRAINT "fk_SO_Grenze_SO_Objekt"
    FOREIGN KEY ("gid")
    REFERENCES "SO_Basisobjekte"."SO_Objekt" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_SO_Grenze_typ"
    FOREIGN KEY ("typ")
    REFERENCES "SO_Sonstiges"."SO_GrenzeTypen" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_SO_Grenze_sonstTyp"
    FOREIGN KEY ("sonstTyp")
    REFERENCES "SO_Sonstiges"."SO_SonstGrenzeTypen" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE)
INHERITS("SO_Basisobjekte"."SO_Linienobjekt");

CREATE INDEX "idx_fk_SO_Grenze_typ_idx" ON "SO_Sonstiges"."SO_Grenze" ("typ");
CREATE INDEX "idx_fk_SO_Grenze_sonstTyp_idx" ON "SO_Sonstiges"."SO_Grenze" ("sonstTyp");
GRANT SELECT ON TABLE "SO_Sonstiges"."SO_Grenze" TO xp_gast;
GRANT ALL ON TABLE "SO_Sonstiges"."SO_Grenze" TO so_user;
COMMENT ON TABLE "SO_Sonstiges"."SO_Grenze" IS 'Grenze einer Verwaltungseinheit oder sonstige Grenze in rambezogenen Pl�nen.';
COMMENT ON COLUMN "SO_Sonstiges"."SO_Grenze"."gid" IS 'Prim�rschl�ssel, wird automatisch ausgef�llt!';
COMMENT ON COLUMN "SO_Sonstiges"."SO_Grenze"."typ" IS 'Typ der Grenze';
COMMENT ON COLUMN "SO_Sonstiges"."SO_Grenze"."sonstTyp" IS '';
CREATE TRIGGER "change_to_SO_Grenze" BEFORE INSERT OR UPDATE OR DELETE ON "SO_Sonstiges"."SO_Grenze" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Data for table "SO_Schutzgebiete"."SO_KlassifizSchutzgebietNaturschutzrecht"
-- -----------------------------------------------------
INSERT INTO "SO_Schutzgebiete"."SO_KlassifizSchutzgebietNaturschutzrecht" ("Code", "Bezeichner") VALUES (1000, 'Naturschutzgebiet');
INSERT INTO "SO_Schutzgebiete"."SO_KlassifizSchutzgebietNaturschutzrecht" ("Code", "Bezeichner") VALUES (1100, 'Nationalpark');
INSERT INTO "SO_Schutzgebiete"."SO_KlassifizSchutzgebietNaturschutzrecht" ("Code", "Bezeichner") VALUES (1200, 'Biosphaerenreservat');
INSERT INTO "SO_Schutzgebiete"."SO_KlassifizSchutzgebietNaturschutzrecht" ("Code", "Bezeichner") VALUES (1300, 'Landschaftsschutzgebiet');
INSERT INTO "SO_Schutzgebiete"."SO_KlassifizSchutzgebietNaturschutzrecht" ("Code", "Bezeichner") VALUES (1400, 'Naturpark');
INSERT INTO "SO_Schutzgebiete"."SO_KlassifizSchutzgebietNaturschutzrecht" ("Code", "Bezeichner") VALUES (1500, 'Naturdenkmal');
INSERT INTO "SO_Schutzgebiete"."SO_KlassifizSchutzgebietNaturschutzrecht" ("Code", "Bezeichner") VALUES (1600, 'GeschuetzterLandschaftsBestandteil');
INSERT INTO "SO_Schutzgebiete"."SO_KlassifizSchutzgebietNaturschutzrecht" ("Code", "Bezeichner") VALUES (1700, 'GesetzlichGeschuetztesBiotop');
INSERT INTO "SO_Schutzgebiete"."SO_KlassifizSchutzgebietNaturschutzrecht" ("Code", "Bezeichner") VALUES (1800, 'Natura2000');
INSERT INTO "SO_Schutzgebiete"."SO_KlassifizSchutzgebietNaturschutzrecht" ("Code", "Bezeichner") VALUES (18000, 'GebietGemeinschaftlicherBedeutung');
INSERT INTO "SO_Schutzgebiete"."SO_KlassifizSchutzgebietNaturschutzrecht" ("Code", "Bezeichner") VALUES (18001, 'EuropaeischesVogelschutzgebiet');
INSERT INTO "SO_Schutzgebiete"."SO_KlassifizSchutzgebietNaturschutzrecht" ("Code", "Bezeichner") VALUES (2000, 'NationalesNaturmonument');
INSERT INTO "SO_Schutzgebiete"."SO_KlassifizSchutzgebietNaturschutzrecht" ("Code", "Bezeichner") VALUES (9999, 'Sonstiges');

-- -----------------------------------------------------
-- Data for table "SO_Basisobjekte"."SO_Rechtscharakter"
-- -----------------------------------------------------
INSERT INTO "SO_Basisobjekte"."SO_Rechtscharakter" ("Code", "Bezeichner") VALUES (3000, 'Hinweis');
INSERT INTO "SO_Basisobjekte"."SO_Rechtscharakter" ("Code", "Bezeichner") VALUES (4000, 'Vermerk');
INSERT INTO "SO_Basisobjekte"."SO_Rechtscharakter" ("Code", "Bezeichner") VALUES (5000, 'Kennzeichnung');
INSERT INTO "SO_Basisobjekte"."SO_Rechtscharakter" ("Code", "Bezeichner") VALUES (9999, 'Sonstiges');

-- -----------------------------------------------------
-- Data for table "SO_Basisobjekte"."SO_SonstRechtscharakter"
-- -----------------------------------------------------
INSERT INTO "SO_Basisobjekte"."SO_SonstRechtscharakter" ("Code", "Bezeichner") VALUES ('FestsetzungBPlan', 'FestsetzungBPlan');
INSERT INTO "SO_Basisobjekte"."SO_SonstRechtscharakter" ("Code", "Bezeichner") VALUES ('DarstellungFPlan', 'DarstellungFPlan');

-- -----------------------------------------------------
-- Data for table "SO_Schutzgebiete"."SO_SchutzzonenNaturschutzrecht"
-- -----------------------------------------------------
INSERT INTO "SO_Schutzgebiete"."SO_SchutzzonenNaturschutzrecht" ("Code", "Bezeichner") VALUES (1000, 'Schutzzone_1');
INSERT INTO "SO_Schutzgebiete"."SO_SchutzzonenNaturschutzrecht" ("Code", "Bezeichner") VALUES (1100, 'Schutzzone_2');
INSERT INTO "SO_Schutzgebiete"."SO_SchutzzonenNaturschutzrecht" ("Code", "Bezeichner") VALUES (1200, 'Schutzzone_3');
INSERT INTO "SO_Schutzgebiete"."SO_SchutzzonenNaturschutzrecht" ("Code", "Bezeichner") VALUES (2000, 'Kernzone');
INSERT INTO "SO_Schutzgebiete"."SO_SchutzzonenNaturschutzrecht" ("Code", "Bezeichner") VALUES (2100, 'Pflegezone');
INSERT INTO "SO_Schutzgebiete"."SO_SchutzzonenNaturschutzrecht" ("Code", "Bezeichner") VALUES (2200, 'Entwicklungszone');
INSERT INTO "SO_Schutzgebiete"."SO_SchutzzonenNaturschutzrecht" ("Code", "Bezeichner") VALUES (2300, 'Regenerationszone');

-- -----------------------------------------------------
-- Data for table "SO_Schutzgebiete"."SO_KlassifizSchutzgebietWasserrecht"
-- -----------------------------------------------------
INSERT INTO "SO_Schutzgebiete"."SO_KlassifizSchutzgebietWasserrecht" ("Code", "Bezeichner") VALUES (1000, 'Wasserschutzgebiet');
INSERT INTO "SO_Schutzgebiete"."SO_KlassifizSchutzgebietWasserrecht" ("Code", "Bezeichner") VALUES (10000, 'QuellGrundwasserSchutzgebiet');
INSERT INTO "SO_Schutzgebiete"."SO_KlassifizSchutzgebietWasserrecht" ("Code", "Bezeichner") VALUES (10001, 'OberflaechengewaesserSchutzgebiet');
INSERT INTO "SO_Schutzgebiete"."SO_KlassifizSchutzgebietWasserrecht" ("Code", "Bezeichner") VALUES (2000, 'Heilquellenschutzgebiet');
INSERT INTO "SO_Schutzgebiete"."SO_KlassifizSchutzgebietWasserrecht" ("Code", "Bezeichner") VALUES (9999, 'Sonstiges');

-- -----------------------------------------------------
-- Data for table "SO_Schutzgebiete"."SO_SchutzzonenWasserrecht"
-- -----------------------------------------------------
INSERT INTO "SO_Schutzgebiete"."SO_SchutzzonenWasserrecht" ("Code", "Bezeichner") VALUES (1000, 'Zone_1');
INSERT INTO "SO_Schutzgebiete"."SO_SchutzzonenWasserrecht" ("Code", "Bezeichner") VALUES (1100, 'Zone_2');
INSERT INTO "SO_Schutzgebiete"."SO_SchutzzonenWasserrecht" ("Code", "Bezeichner") VALUES (1200, 'Zone_3');
INSERT INTO "SO_Schutzgebiete"."SO_SchutzzonenWasserrecht" ("Code", "Bezeichner") VALUES (1300, 'Zone_3a');
INSERT INTO "SO_Schutzgebiete"."SO_SchutzzonenWasserrecht" ("Code", "Bezeichner") VALUES (1400, 'Zone_3b');
INSERT INTO "SO_Schutzgebiete"."SO_SchutzzonenWasserrecht" ("Code", "Bezeichner") VALUES (1500, 'Zone_4');

-- -----------------------------------------------------
-- Data for table "SO_Schutzgebiete"."SO_KlassifizSchutzgebietSonstRecht"
-- -----------------------------------------------------
INSERT INTO "SO_Schutzgebiete"."SO_KlassifizSchutzgebietSonstRecht" ("Code", "Bezeichner") VALUES (1000, 'Laermschutzbereich');
INSERT INTO "SO_Schutzgebiete"."SO_KlassifizSchutzgebietSonstRecht" ("Code", "Bezeichner") VALUES (2000, 'SchutzzoneLeitungstrasse');
INSERT INTO "SO_Schutzgebiete"."SO_KlassifizSchutzgebietSonstRecht" ("Code", "Bezeichner") VALUES (9999, 'Sonstiges');

-- -----------------------------------------------------
-- Data for table "SO_NachrichtlicheUebernahmen"."SO_KlassifizNachStrassenverkehrsrecht"
-- -----------------------------------------------------
INSERT INTO "SO_NachrichtlicheUebernahmen"."SO_KlassifizNachStrassenverkehrsrecht" ("Code", "Bezeichner") VALUES (1000, 'Bundesautobahn');
INSERT INTO "SO_NachrichtlicheUebernahmen"."SO_KlassifizNachStrassenverkehrsrecht" ("Code", "Bezeichner") VALUES (1100, 'Bundesstrasse');
INSERT INTO "SO_NachrichtlicheUebernahmen"."SO_KlassifizNachStrassenverkehrsrecht" ("Code", "Bezeichner") VALUES (1200, 'LandesStaatsstrasse');
INSERT INTO "SO_NachrichtlicheUebernahmen"."SO_KlassifizNachStrassenverkehrsrecht" ("Code", "Bezeichner") VALUES (1300, 'Kreisstrasse');
INSERT INTO "SO_NachrichtlicheUebernahmen"."SO_KlassifizNachStrassenverkehrsrecht" ("Code", "Bezeichner") VALUES (9999, 'SonstOeffentlStrasse');

-- -----------------------------------------------------
-- Data for table "SO_NachrichtlicheUebernahmen"."SO_KlassifizNachWasserrecht"
-- -----------------------------------------------------
INSERT INTO "SO_NachrichtlicheUebernahmen"."SO_KlassifizNachWasserrecht" ("Code", "Bezeichner") VALUES (1000, 'Gewaesser1Ordnung');
INSERT INTO "SO_NachrichtlicheUebernahmen"."SO_KlassifizNachWasserrecht" ("Code", "Bezeichner") VALUES (1100, 'Gewaesser2Ordnung');
INSERT INTO "SO_NachrichtlicheUebernahmen"."SO_KlassifizNachWasserrecht" ("Code", "Bezeichner") VALUES (1300, 'Gewaesser3Ordnung');
INSERT INTO "SO_NachrichtlicheUebernahmen"."SO_KlassifizNachWasserrecht" ("Code", "Bezeichner") VALUES (2000, 'Ueberschwemmungsgebiet');
INSERT INTO "SO_NachrichtlicheUebernahmen"."SO_KlassifizNachWasserrecht" ("Code", "Bezeichner") VALUES (20000, 'FestgesetztesUeberschwemmungsgebiet');
INSERT INTO "SO_NachrichtlicheUebernahmen"."SO_KlassifizNachWasserrecht" ("Code", "Bezeichner") VALUES (20001, 'NochNichtFestgesetztesUeberschwemmungsgebiet');
INSERT INTO "SO_NachrichtlicheUebernahmen"."SO_KlassifizNachWasserrecht" ("Code", "Bezeichner") VALUES (20002, 'UeberschwemmGefaehrdetesGebiet');
INSERT INTO "SO_NachrichtlicheUebernahmen"."SO_KlassifizNachWasserrecht" ("Code", "Bezeichner") VALUES (9999, 'Sonstiges');

-- -----------------------------------------------------
-- Data for table "SO_NachrichtlicheUebernahmen"."SO_KlassifizNachDenkmalschutzrecht"
-- -----------------------------------------------------
INSERT INTO "SO_NachrichtlicheUebernahmen"."SO_KlassifizNachDenkmalschutzrecht" ("Code", "Bezeichner") VALUES (1000, 'DenkmalschutzEnsemble');
INSERT INTO "SO_NachrichtlicheUebernahmen"."SO_KlassifizNachDenkmalschutzrecht" ("Code", "Bezeichner") VALUES (1100, 'DenkmalschutzEinzelanlage');
INSERT INTO "SO_NachrichtlicheUebernahmen"."SO_KlassifizNachDenkmalschutzrecht" ("Code", "Bezeichner") VALUES (1200, 'Grabungsschutzgebiet');
INSERT INTO "SO_NachrichtlicheUebernahmen"."SO_KlassifizNachDenkmalschutzrecht" ("Code", "Bezeichner") VALUES (9999, 'Sonstiges');

-- -----------------------------------------------------
-- Data for table "SO_NachrichtlicheUebernahmen"."SO_KlassifizNachForstrecht"
-- -----------------------------------------------------
INSERT INTO "SO_NachrichtlicheUebernahmen"."SO_KlassifizNachForstrecht" ("Code", "Bezeichner") VALUES (1000, 'OeffentlicherWald');
INSERT INTO "SO_NachrichtlicheUebernahmen"."SO_KlassifizNachForstrecht" ("Code", "Bezeichner") VALUES (2000, 'Privatwald');
INSERT INTO "SO_NachrichtlicheUebernahmen"."SO_KlassifizNachForstrecht" ("Code", "Bezeichner") VALUES (9999, 'Sonstiges');

-- -----------------------------------------------------
-- Data for table "SO_NachrichtlicheUebernahmen"."SO_KlassifizNachSonstigemRecht"
-- -----------------------------------------------------
INSERT INTO "SO_NachrichtlicheUebernahmen"."SO_KlassifizNachSonstigemRecht" ("Code", "Bezeichner") VALUES (1000, 'Bauschutzbereich');
INSERT INTO "SO_NachrichtlicheUebernahmen"."SO_KlassifizNachSonstigemRecht" ("Code", "Bezeichner") VALUES (1100, 'Berggesetz');
INSERT INTO "SO_NachrichtlicheUebernahmen"."SO_KlassifizNachSonstigemRecht" ("Code", "Bezeichner") VALUES (1200, 'Richtfunkverbindung');
INSERT INTO "SO_NachrichtlicheUebernahmen"."SO_KlassifizNachSonstigemRecht" ("Code", "Bezeichner") VALUES (1300, 'Truppenuebungsplatz');
INSERT INTO "SO_NachrichtlicheUebernahmen"."SO_KlassifizNachSonstigemRecht" ("Code", "Bezeichner") VALUES (1400, 'VermessungsKatasterrecht');
INSERT INTO "SO_NachrichtlicheUebernahmen"."SO_KlassifizNachSonstigemRecht" ("Code", "Bezeichner") VALUES (9999, 'Sonstiges');

-- -----------------------------------------------------
-- Data for table "SO_NachrichtlicheUebernahmen"."SO_KlassifizNachSchienenverkehrsrecht"
-- -----------------------------------------------------
INSERT INTO "SO_NachrichtlicheUebernahmen"."SO_KlassifizNachSchienenverkehrsrecht" ("Code", "Bezeichner") VALUES (1000, 'Bahnanlage');
INSERT INTO "SO_NachrichtlicheUebernahmen"."SO_KlassifizNachSchienenverkehrsrecht" ("Code", "Bezeichner") VALUES (1200, 'Bahnlinie');
INSERT INTO "SO_NachrichtlicheUebernahmen"."SO_KlassifizNachSchienenverkehrsrecht" ("Code", "Bezeichner") VALUES (1400, 'OEPNV');
INSERT INTO "SO_NachrichtlicheUebernahmen"."SO_KlassifizNachSchienenverkehrsrecht" ("Code", "Bezeichner") VALUES (9999, 'Sonstiges');

-- -----------------------------------------------------
-- Data for table "SO_NachrichtlicheUebernahmen"."SO_BesondereKlassifizNachSchienenverkehrsrecht"
-- -----------------------------------------------------
INSERT INTO "SO_NachrichtlicheUebernahmen"."SO_BesondereKlassifizNachSchienenverkehrsrecht" ("Code", "bezeichner") VALUES (10000, 'DB_Bahnanlage');
INSERT INTO "SO_NachrichtlicheUebernahmen"."SO_BesondereKlassifizNachSchienenverkehrsrecht" ("Code", "bezeichner") VALUES (10001, 'Personenbahnhof');
INSERT INTO "SO_NachrichtlicheUebernahmen"."SO_BesondereKlassifizNachSchienenverkehrsrecht" ("Code", "bezeichner") VALUES (10002, 'Fernbahnhof');
INSERT INTO "SO_NachrichtlicheUebernahmen"."SO_BesondereKlassifizNachSchienenverkehrsrecht" ("Code", "bezeichner") VALUES (10003, 'Gueterbahnhof');
INSERT INTO "SO_NachrichtlicheUebernahmen"."SO_BesondereKlassifizNachSchienenverkehrsrecht" ("Code", "bezeichner") VALUES (12000, 'Personenbahnlinie');
INSERT INTO "SO_NachrichtlicheUebernahmen"."SO_BesondereKlassifizNachSchienenverkehrsrecht" ("Code", "bezeichner") VALUES (12001, 'Regionalbahn');
INSERT INTO "SO_NachrichtlicheUebernahmen"."SO_BesondereKlassifizNachSchienenverkehrsrecht" ("Code", "bezeichner") VALUES (12002, 'Kleinbahn');
INSERT INTO "SO_NachrichtlicheUebernahmen"."SO_BesondereKlassifizNachSchienenverkehrsrecht" ("Code", "bezeichner") VALUES (12003, 'Gueterbahnlinie');
INSERT INTO "SO_NachrichtlicheUebernahmen"."SO_BesondereKlassifizNachSchienenverkehrsrecht" ("Code", "bezeichner") VALUES (12004, 'WerksHafenbahn');
INSERT INTO "SO_NachrichtlicheUebernahmen"."SO_BesondereKlassifizNachSchienenverkehrsrecht" ("Code", "bezeichner") VALUES (12005, 'Seilbahn');
INSERT INTO "SO_NachrichtlicheUebernahmen"."SO_BesondereKlassifizNachSchienenverkehrsrecht" ("Code", "bezeichner") VALUES (14000, 'Strassenbahn');
INSERT INTO "SO_NachrichtlicheUebernahmen"."SO_BesondereKlassifizNachSchienenverkehrsrecht" ("Code", "bezeichner") VALUES (14001, 'UBahn');
INSERT INTO "SO_NachrichtlicheUebernahmen"."SO_BesondereKlassifizNachSchienenverkehrsrecht" ("Code", "bezeichner") VALUES (14002, 'SBahn');
INSERT INTO "SO_NachrichtlicheUebernahmen"."SO_BesondereKlassifizNachSchienenverkehrsrecht" ("Code", "bezeichner") VALUES (14003, 'OEPNV_Haltestelle');

-- -----------------------------------------------------
-- Data for table "SO_NachrichtlicheUebernahmen"."SO_KlassifizNachLuftverkehrsrecht"
-- -----------------------------------------------------
INSERT INTO "SO_NachrichtlicheUebernahmen"."SO_KlassifizNachLuftverkehrsrecht" ("Code", "Bezeichner") VALUES (1000, 'Flughafen');
INSERT INTO "SO_NachrichtlicheUebernahmen"."SO_KlassifizNachLuftverkehrsrecht" ("Code", "Bezeichner") VALUES (2000, 'Landeplatz');
INSERT INTO "SO_NachrichtlicheUebernahmen"."SO_KlassifizNachLuftverkehrsrecht" ("Code", "Bezeichner") VALUES (3000, 'Segelfluggelaende');
INSERT INTO "SO_NachrichtlicheUebernahmen"."SO_KlassifizNachLuftverkehrsrecht" ("Code", "Bezeichner") VALUES (4000, 'HubschrauberLandeplatz');
INSERT INTO "SO_NachrichtlicheUebernahmen"."SO_KlassifizNachLuftverkehrsrecht" ("Code", "Bezeichner") VALUES (5000, 'Ballonstartplatz');
INSERT INTO "SO_NachrichtlicheUebernahmen"."SO_KlassifizNachLuftverkehrsrecht" ("Code", "Bezeichner") VALUES (5200, 'Haengegleiter');
INSERT INTO "SO_NachrichtlicheUebernahmen"."SO_KlassifizNachLuftverkehrsrecht" ("Code", "Bezeichner") VALUES (5400, 'Gleitsegler');
INSERT INTO "SO_NachrichtlicheUebernahmen"."SO_KlassifizNachLuftverkehrsrecht" ("Code", "Bezeichner") VALUES (6000, 'Laermschutzbereich');
INSERT INTO "SO_NachrichtlicheUebernahmen"."SO_KlassifizNachLuftverkehrsrecht" ("Code", "Bezeichner") VALUES (7000, 'Baubeschraenkungsbereich');
INSERT INTO "SO_NachrichtlicheUebernahmen"."SO_KlassifizNachLuftverkehrsrecht" ("Code", "Bezeichner") VALUES (9999, 'Sonstiges');

-- -----------------------------------------------------
-- Data for table "SO_NachrichtlicheUebernahmen"."SO_LaermschutzzoneTypen"
-- -----------------------------------------------------
INSERT INTO "SO_NachrichtlicheUebernahmen"."SO_LaermschutzzoneTypen" ("Code", "Bezeichner") VALUES (1000, 'TagZone1');
INSERT INTO "SO_NachrichtlicheUebernahmen"."SO_LaermschutzzoneTypen" ("Code", "Bezeichner") VALUES (2000, 'TagZone2');
INSERT INTO "SO_NachrichtlicheUebernahmen"."SO_LaermschutzzoneTypen" ("Code", "Bezeichner") VALUES (3000, 'Nacht');

-- -----------------------------------------------------
-- Data for table "SO_NachrichtlicheUebernahmen"."SO_KlassifizNachBodenschutzrecht"
-- -----------------------------------------------------
INSERT INTO "SO_NachrichtlicheUebernahmen"."SO_KlassifizNachBodenschutzrecht" ("Code", "Bezeichner") VALUES (1000, 'SchaedlicheBodenveraenderung');
INSERT INTO "SO_NachrichtlicheUebernahmen"."SO_KlassifizNachBodenschutzrecht" ("Code", "Bezeichner") VALUES (2000, 'Altlast');
INSERT INTO "SO_NachrichtlicheUebernahmen"."SO_KlassifizNachBodenschutzrecht" ("Code", "Bezeichner") VALUES (20000, 'Altablagerung');
INSERT INTO "SO_NachrichtlicheUebernahmen"."SO_KlassifizNachBodenschutzrecht" ("Code", "Bezeichner") VALUES (20001, 'Altstandort');
INSERT INTO "SO_NachrichtlicheUebernahmen"."SO_KlassifizNachBodenschutzrecht" ("Code", "Bezeichner") VALUES (20002, 'AltstandortAufAltablagerung');

-- -----------------------------------------------------
-- Data for table "SO_SonstigeGebiete"."SO_GebietsArt"
-- -----------------------------------------------------
INSERT INTO "SO_SonstigeGebiete"."SO_GebietsArt" ("Code", "Bezeichner") VALUES (1000, 'Umlegungsgebiet');
INSERT INTO "SO_SonstigeGebiete"."SO_GebietsArt" ("Code", "Bezeichner") VALUES (1100, 'StaedtebaulicheSanierung');
INSERT INTO "SO_SonstigeGebiete"."SO_GebietsArt" ("Code", "Bezeichner") VALUES (1200, 'StaedtebaulicheEntwicklungsmassnahme');
INSERT INTO "SO_SonstigeGebiete"."SO_GebietsArt" ("Code", "Bezeichner") VALUES (1300, 'Stadtumbaugebiet');
INSERT INTO "SO_SonstigeGebiete"."SO_GebietsArt" ("Code", "Bezeichner") VALUES (1400, 'SozialeStadt');
INSERT INTO "SO_SonstigeGebiete"."SO_GebietsArt" ("Code", "Bezeichner") VALUES (1500, 'BusinessImprovementDestrict');
INSERT INTO "SO_SonstigeGebiete"."SO_GebietsArt" ("Code", "Bezeichner") VALUES (1600, 'HousingImprovementDestrict');
INSERT INTO "SO_SonstigeGebiete"."SO_GebietsArt" ("Code", "Bezeichner") VALUES (1999, 'Erhaltungsverordnung');
INSERT INTO "SO_SonstigeGebiete"."SO_GebietsArt" ("Code", "Bezeichner") VALUES (2000, 'ErhaltungsverordnungStaedebaulicheGestalt');
INSERT INTO "SO_SonstigeGebiete"."SO_GebietsArt" ("Code", "Bezeichner") VALUES (2100, 'ErhaltungsverordnungWohnbevoelkerung');
INSERT INTO "SO_SonstigeGebiete"."SO_GebietsArt" ("Code", "Bezeichner") VALUES (2200, 'ErhaltungsverordnungUmstrukturierung');
INSERT INTO "SO_SonstigeGebiete"."SO_GebietsArt" ("Code", "Bezeichner") VALUES (9999, 'Sonstiges');

-- -----------------------------------------------------
-- Data for table "SO_SonstigeGebiete"."SO_RechtsstandGebietTyp"
-- -----------------------------------------------------
INSERT INTO "SO_SonstigeGebiete"."SO_RechtsstandGebietTyp" ("Code", "Bezeichner") VALUES (1000, 'VorbereitendeUntersuchung');
INSERT INTO "SO_SonstigeGebiete"."SO_RechtsstandGebietTyp" ("Code", "Bezeichner") VALUES (2000, 'Aufstellung');
INSERT INTO "SO_SonstigeGebiete"."SO_RechtsstandGebietTyp" ("Code", "Bezeichner") VALUES (3000, 'Festlegung');
INSERT INTO "SO_SonstigeGebiete"."SO_RechtsstandGebietTyp" ("Code", "Bezeichner") VALUES (4000, 'Abgeschlossen');
INSERT INTO "SO_SonstigeGebiete"."SO_RechtsstandGebietTyp" ("Code", "Bezeichner") VALUES (5000, 'Verstetigung');
INSERT INTO "SO_SonstigeGebiete"."SO_RechtsstandGebietTyp" ("Code", "Bezeichner") VALUES (9999, 'Sonstiges');

-- -----------------------------------------------------
-- Data for table "SO_Sonstiges"."SO_GrenzeTypen"
-- -----------------------------------------------------
INSERT INTO "SO_Sonstiges"."SO_GrenzeTypen" ("Code", "Bezeichner") VALUES (1000, 'Bundesgrenze');
INSERT INTO "SO_Sonstiges"."SO_GrenzeTypen" ("Code", "Bezeichner") VALUES (1100, 'Landesgrenze');
INSERT INTO "SO_Sonstiges"."SO_GrenzeTypen" ("Code", "Bezeichner") VALUES (1200, 'Regierungsbezirksgrenze');
INSERT INTO "SO_Sonstiges"."SO_GrenzeTypen" ("Code", "Bezeichner") VALUES (1250, 'Bezirksgrenze');
INSERT INTO "SO_Sonstiges"."SO_GrenzeTypen" ("Code", "Bezeichner") VALUES (1300, 'Kreisgrenze');
INSERT INTO "SO_Sonstiges"."SO_GrenzeTypen" ("Code", "Bezeichner") VALUES (1400, 'Gemeindegrenze');
INSERT INTO "SO_Sonstiges"."SO_GrenzeTypen" ("Code", "Bezeichner") VALUES (1450, 'Verbandsgemeindegrenze');
INSERT INTO "SO_Sonstiges"."SO_GrenzeTypen" ("Code", "Bezeichner") VALUES (1500, 'Samtgemeindegrenze');
INSERT INTO "SO_Sonstiges"."SO_GrenzeTypen" ("Code", "Bezeichner") VALUES (1510, 'Mitgliedsgemeindegrenze');
INSERT INTO "SO_Sonstiges"."SO_GrenzeTypen" ("Code", "Bezeichner") VALUES (1550, 'Amtsgrenze');
INSERT INTO "SO_Sonstiges"."SO_GrenzeTypen" ("Code", "Bezeichner") VALUES (1600, 'Stadtteilgrenze');
INSERT INTO "SO_Sonstiges"."SO_GrenzeTypen" ("Code", "Bezeichner") VALUES (2000, 'VorgeschlageneGrundstuecksgrenze');
INSERT INTO "SO_Sonstiges"."SO_GrenzeTypen" ("Code", "Bezeichner") VALUES (2100, 'GrenzeBestehenderBebauungsplan');
INSERT INTO "SO_Sonstiges"."SO_GrenzeTypen" ("Code", "Bezeichner") VALUES (9999, 'SonstGrenze');