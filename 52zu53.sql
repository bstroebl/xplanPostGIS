-- Umstellung von XPlan 5.2.1 auf 5.3
-- Änderungen in der DB

-- CR-001
INSERT INTO "RP_Freiraumstruktur"."RP_NaturLandschaftTypen" ("Code", "Bezeichner") VALUES ('2600', 'Freiraumfunktionen');

-- CR-003
INSERT INTO "XP_Basisobjekte"."XP_ExterneReferenzTyp" ("Code", "Bezeichner") VALUES (4000, 'Genehmigung');
INSERT INTO "XP_Basisobjekte"."XP_ExterneReferenzTyp" ("Code", "Bezeichner") VALUES (5000, 'Bekanntmachung');

-- CR-004
-- -----------------------------------------------------
-- Table "SO_Sonstiges"."SO_KlassifizGelaendemorphologie"
-- -----------------------------------------------------
CREATE TABLE "SO_Sonstiges"."SO_KlassifizGelaendemorphologie" (
  "Code" INTEGER NOT NULL,
  "Bezeichner" VARCHAR(64) NOT NULL,
  PRIMARY KEY ("Code"));

GRANT SELECT ON TABLE "SO_Sonstiges"."SO_KlassifizGelaendemorphologie" TO xp_gast;

-- -----------------------------------------------------
-- Table "SO_Sonstiges"."SO_DetailKlassifizGelaendemorphologie"
-- -----------------------------------------------------
CREATE TABLE "SO_Sonstiges"."SO_DetailKlassifizGelaendemorphologie" (
  "Code" INTEGER NOT NULL,
  "Bezeichner" VARCHAR(64) NOT NULL,
  PRIMARY KEY ("Code"));
GRANT SELECT ON TABLE "SO_Sonstiges"."SO_DetailKlassifizGelaendemorphologie" TO xp_gast;
GRANT ALL ON TABLE "SO_Sonstiges"."SO_DetailKlassifizGelaendemorphologie" TO so_user;
CREATE TRIGGER "ins_upd_SO_DetailKlassifizGelaendemorphologie" BEFORE INSERT OR UPDATE ON "SO_Sonstiges"."SO_DetailKlassifizGelaendemorphologie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isCodeList"();

-- -----------------------------------------------------
-- Table "SO_Sonstiges"."SO_Gelaendemorphologie"
-- -----------------------------------------------------
CREATE TABLE "SO_Sonstiges"."SO_Gelaendemorphologie" (
  "gid" BIGINT NOT NULL,
  "artDerFestlegung" INTEGER NULL,
  "detailArtDerFestlegung" INTEGER NULL,
  "name" VARCHAR(64) NULL,
  "nummer" VARCHAR(64) NULL,
  PRIMARY KEY ("gid"),
  CONSTRAINT "fk_SO_Gelaendemorphologie_parent"
    FOREIGN KEY ("gid")
    REFERENCES "SO_Basisobjekte"."SO_Objekt" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_SO_Gelaendemorphologie_artDerFestlegung"
    FOREIGN KEY ("artDerFestlegung")
    REFERENCES "SO_Sonstiges"."SO_KlassifizGelaendemorphologie" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_SO_Gelaendemorphologie_detailArtDerFestlegung"
    FOREIGN KEY ("detailArtDerFestlegung")
    REFERENCES "SO_Sonstiges"."SO_DetailKlassifizGelaendemorphologie" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE);

CREATE INDEX "idx_fk_SO_Gelaendemorphologie_artDerFestlegung" ON "SO_Sonstiges"."SO_Gelaendemorphologie" ("artDerFestlegung");
CREATE INDEX "idx_fk_SO_Gelaendemorphologie_detailArtDerFestlegung" ON "SO_Sonstiges"."SO_Gelaendemorphologie" ("detailArtDerFestlegung");
GRANT SELECT ON TABLE "SO_Sonstiges"."SO_Gelaendemorphologie" TO xp_gast;
GRANT ALL ON TABLE "SO_Sonstiges"."SO_Gelaendemorphologie" TO so_user;
COMMENT ON TABLE "SO_Sonstiges"."SO_Gelaendemorphologie" IS 'Das Landschaftsbild prägende Geländestruktur.';
COMMENT ON COLUMN "SO_Sonstiges"."SO_Gelaendemorphologie"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN "SO_Sonstiges"."SO_Gelaendemorphologie"."artDerFestlegung" IS 'Klassifikation der Geländestruktur';
COMMENT ON COLUMN "SO_Sonstiges"."SO_Gelaendemorphologie"."detailArtDerFestlegung" IS 'Über eine Codeliste definierte detailliertere Klassifikation der Geländestruktur.';
COMMENT ON COLUMN "SO_Sonstiges"."SO_Gelaendemorphologie"."name" IS 'Informelle Bezeichnung der Struktur.';
COMMENT ON COLUMN "SO_Sonstiges"."SO_Gelaendemorphologie"."nummer" IS 'Amtliche Bezeichnung / Kennziffer der Struktur.';
CREATE TRIGGER "change_to_SO_Gelaendemorphologie" BEFORE INSERT OR UPDATE ON "SO_Sonstiges"."SO_Gelaendemorphologie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_SO_Gelaendemorphologie" AFTER DELETE ON "SO_Sonstiges"."SO_Gelaendemorphologie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "SO_Sonstiges"."SO_GelaendemorphologiePunkt"
-- -----------------------------------------------------
CREATE TABLE "SO_Sonstiges"."SO_GelaendemorphologiePunkt" (
  "gid" BIGINT NOT NULL,
  PRIMARY KEY ("gid"),
  CONSTRAINT "fk_SO_GelaendemorphologiePunkt_parent"
    FOREIGN KEY ("gid")
    REFERENCES "SO_Sonstiges"."SO_Gelaendemorphologie" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("SO_Basisobjekte"."SO_Punktobjekt");

GRANT SELECT ON TABLE "SO_Sonstiges"."SO_GelaendemorphologiePunkt" TO xp_gast;
GRANT ALL ON TABLE "SO_Sonstiges"."SO_GelaendemorphologiePunkt" TO so_user;
COMMENT ON COLUMN "SO_Sonstiges"."SO_GelaendemorphologiePunkt"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_SO_GelaendemorphologiePunkt" BEFORE INSERT OR UPDATE ON "SO_Sonstiges"."SO_GelaendemorphologiePunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_SO_GelaendemorphologiePunkt" AFTER DELETE ON "SO_Sonstiges"."SO_GelaendemorphologiePunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "SO_Sonstiges"."SO_GelaendemorphologieLinie"
-- -----------------------------------------------------
CREATE TABLE "SO_Sonstiges"."SO_GelaendemorphologieLinie" (
  "gid" BIGINT NOT NULL,
  PRIMARY KEY ("gid"),
  CONSTRAINT "fk_SO_GelaendemorphologieLinie_parent"
    FOREIGN KEY ("gid")
    REFERENCES "SO_Sonstiges"."SO_Gelaendemorphologie" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("SO_Basisobjekte"."SO_Linienobjekt");

GRANT SELECT ON TABLE "SO_Sonstiges"."SO_GelaendemorphologieLinie" TO xp_gast;
GRANT ALL ON TABLE "SO_Sonstiges"."SO_GelaendemorphologieLinie" TO so_user;
COMMENT ON COLUMN "SO_Sonstiges"."SO_GelaendemorphologieLinie"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_SO_GelaendemorphologieLinie" BEFORE INSERT OR UPDATE ON "SO_Sonstiges"."SO_GelaendemorphologieLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_SO_GelaendemorphologieLinie" AFTER DELETE ON "SO_Sonstiges"."SO_GelaendemorphologieLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "SO_Sonstiges"."SO_GelaendemorphologieFlaeche"
-- -----------------------------------------------------
CREATE TABLE "SO_Sonstiges"."SO_GelaendemorphologieFlaeche" (
  "gid" BIGINT NOT NULL,
  PRIMARY KEY ("gid"),
  CONSTRAINT "fk_SO_GelaendemorphologieFlaeche_parent"
    FOREIGN KEY ("gid")
    REFERENCES "SO_Sonstiges"."SO_Gelaendemorphologie" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("SO_Basisobjekte"."SO_Flaechenobjekt");

GRANT SELECT ON TABLE "SO_Sonstiges"."SO_GelaendemorphologieFlaeche" TO xp_gast;
GRANT ALL ON TABLE "SO_Sonstiges"."SO_GelaendemorphologieFlaeche" TO so_user;
COMMENT ON COLUMN "SO_Sonstiges"."SO_GelaendemorphologieFlaeche"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_SO_GelaendemorphologieFlaeche" BEFORE INSERT OR UPDATE ON "SO_Sonstiges"."SO_GelaendemorphologieFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_SO_GelaendemorphologieFlaeche" AFTER DELETE ON "SO_Sonstiges"."SO_GelaendemorphologieFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "SO_GelaendemorphologieFlaeche_Flaechenobjekt" BEFORE INSERT OR UPDATE ON "SO_Sonstiges"."SO_GelaendemorphologieFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isFlaechenobjekt"();

-- -----------------------------------------------------
-- Data for table "SO_Sonstiges"."SO_KlassifizGelaendemorphologie"
-- -----------------------------------------------------
INSERT INTO "SO_Sonstiges"."SO_KlassifizGelaendemorphologie" ("Code", "Bezeichner") VALUES (1000, 'Terassenkante');
INSERT INTO "SO_Sonstiges"."SO_KlassifizGelaendemorphologie" ("Code", "Bezeichner") VALUES (1100, 'Rinne');
INSERT INTO "SO_Sonstiges"."SO_KlassifizGelaendemorphologie" ("Code", "Bezeichner") VALUES (1200, 'EhemMaeander');
INSERT INTO "SO_Sonstiges"."SO_KlassifizGelaendemorphologie" ("Code", "Bezeichner") VALUES (9999, 'SonstigeStruktur');

--CR-005: nichts zu ändern
