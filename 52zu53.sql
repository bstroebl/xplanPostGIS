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

--CR-006
-- -----------------------------------------------------
-- Table "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_MassnahmeKlimawandelTypen"
-- -----------------------------------------------------
CREATE TABLE "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_MassnahmeKlimawandelTypen" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Code") );
GRANT SELECT ON TABLE "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_MassnahmeKlimawandelTypen" TO xp_gast;

-- -----------------------------------------------------
-- Table "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_DetailMassnahmeKlimawandel"
-- -----------------------------------------------------
CREATE TABLE "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_DetailMassnahmeKlimawandel" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Code") );
GRANT SELECT ON TABLE "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_DetailMassnahmeKlimawandel" TO xp_gast;
CREATE TRIGGER "ins_upd_FP_DetailMassnahmeKlimawandel" BEFORE INSERT OR UPDATE ON "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_DetailMassnahmeKlimawandel" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isCodeList"();

ALTER TABLE "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_AnpassungKlimawandel" ADD COLUMN "massnahme" integer;
ALTER TABLE "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_AnpassungKlimawandel" ADD COLUMN "detailMassnahme" integer;
ALTER TABLE "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_AnpassungKlimawandel" ADD
CONSTRAINT "fk_FP_AnpassungKlimawandel_massnahme"
    FOREIGN KEY ("massnahme" )
    REFERENCES "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_MassnahmeKlimawandelTypen" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE;
ALTER TABLE "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_AnpassungKlimawandel" ADD
  CONSTRAINT "fk_FP_AnpassungKlimawandel_detailMassnahme"
    FOREIGN KEY ("detailMassnahme" )
    REFERENCES "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_DetailMassnahmeKlimawandel" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE;
COMMENT ON COLUMN "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_AnpassungKlimawandel"."massnahme" IS 'Klassifikation der Massnahme';
COMMENT ON COLUMN "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_AnpassungKlimawandel"."detailMassnahme" IS 'Detaillierung der durch das Attribut massnahme festgelegten Maßnahme über eine Codeliste.';

-- -----------------------------------------------------
-- Data for table "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_MassnahmeKlimawandelTypen"
-- -----------------------------------------------------
INSERT INTO "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_MassnahmeKlimawandelTypen" ("Code", "Bezeichner") VALUES ('1000', 'ErhaltFreiflaechen');
INSERT INTO "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_MassnahmeKlimawandelTypen" ("Code", "Bezeichner") VALUES ('10000', 'ErhaltPrivGruen');
INSERT INTO "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_MassnahmeKlimawandelTypen" ("Code", "Bezeichner") VALUES ('10001', 'ErhaltOeffentlGruen');
INSERT INTO "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_MassnahmeKlimawandelTypen" ("Code", "Bezeichner") VALUES ('9999', 'SonstMassnahme');

--CR-011
COMMENT ON TABLE "BP_Bebauung"."BP_BaugebietsTeilFlaeche" IS 'Teil eines Baugebiets mit einheitlicher Art und Maß der baulichen Nutzung. Das Maß der baulichen Nutzung sowie Festsetzungen zur Bauweise oder Grenzbebauung können innerhalb einer BP_BaugebietsTeilFlaeche unterschiedlich sein (BP_UeberbaubareGrundstueckeFlaeche). Dabei sollte die gleichzeitige Belegung desselben Attributs in BP_BaugebietsTeilFlaeche und einem überlagernden Objekt BP_UeberbaubareGrunsdstuecksFlaeche verzichtet werden. Ab Version 6.0 wird dies evtl. durch eine Konformitätsregel erzwungen.';
COMMENT ON TABLE  "BP_Bebauung"."BP_UeberbaubareGrundstuecksFlaeche" IS 'Festsetzung der überbaubaren Grundstücksfläche (§9, Abs. 1, Nr. 2 BauGB). Über die Attribute geschossMin und geschossMax kann die Festsetzung auf einen Bereich von Geschossen beschränkt werden. Wenn eine Einschränkung der Festsetzung durch expliziter Höhenangaben erfolgen soll, ist dazu die Oberklassen-Relation hoehenangabe auf den komplexen Datentyp XP_Hoehenangabe zu verwenden.
Die gleichzeitige Belegung desselben Attributs in BP_BaugebietsTeilFlaeche und einem überlagernden Objekt BP_UeberbaubareGrunsdstuecksFlaeche sollte verzichtet werden. Ab Version 6.0 wird dies evtl. durch eine Konformitätsregel erzwungen.';
