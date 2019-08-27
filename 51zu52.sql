-- Umstellung von XPlan 5.1 auf 5.2
-- Änderungen in der DB

-- Umstellen des UUID-Generators von Python auf eine in einer Extension enthaltenen Funktion
CREATE EXTENSION pgcrypto;

CREATE OR REPLACE FUNCTION "XP_Basisobjekte".create_uuid()
  RETURNS character varying AS
$BODY$
BEGIN
    return gen_random_uuid(); -- version 4 uuid
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
GRANT EXECUTE ON FUNCTION "XP_Basisobjekte".create_uuid() TO xp_user;

DROP LANGUAGE plpython2u;

-- ACHTUNG
-- Before die CRs ausgeführt werden, muss das Skript fix_51.sql ausgeführt werden

-- CR 001
INSERT INTO "BP_Bebauung"."BP_Dachform" ("Code", "Bezeichner") VALUES (3000, 'GeneigtesDach');

-- CR 009
-- -----------------------------------------------------
-- Table "BP_Bebauung"."BP_NutzungNichUueberbaubGrundstFlaeche"
-- -----------------------------------------------------
CREATE TABLE  "BP_Bebauung"."BP_NutzungNichUueberbaubGrundstFlaeche" (
  "Code" INTEGER NOT NULL,
  "Bezeichner" VARCHAR(64) NOT NULL,
  PRIMARY KEY ("Code"));

GRANT SELECT ON TABLE "BP_Bebauung"."BP_NutzungNichUueberbaubGrundstFlaeche" TO xp_gast;

ALTER TABLE "BP_Bebauung"."BP_NichtUeberbaubareGrundstuecksflaeche" ADD COLUMN "nutzung" INTEGER;
ALTER TABLE "BP_Bebauung"."BP_NichtUeberbaubareGrundstuecksflaeche" ADD CONSTRAINT "fk_BP_NichtUeberbaubareGrundstuecksflaeche_nutzung"
    FOREIGN KEY ("nutzung")
    REFERENCES "BP_Bebauung"."BP_NutzungNichUueberbaubGrundstFlaeche" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE;

-- CR 010
-- Nacharbeit für BP_UeberbaubareGrundstuecksFlaeche, hätte bereits zu 5.0 geändert werden müssen
ALTER TABLE "BP_Bebauung"."BP_BaugebietBauweise" DISABLE TRIGGER "change_to_BP_BaugebietBauweise";
ALTER TABLE "BP_Bebauung"."BP_UeberbaubareGrundstuecksFlaeche" DROP CONSTRAINT "fk_BP_UeberbaubareGrundstuecksFlaeche_parent";
INSERT INTO "BP_Bebauung"."BP_BaugebietBauweise"(gid) SELECT gid FROM "BP_Bebauung"."BP_UeberbaubareGrundstuecksFlaeche";
ALTER TABLE "BP_Bebauung"."BP_UeberbaubareGrundstuecksFlaeche" ADD CONSTRAINT "fk_BP_UeberbaubareGrundstuecksFlaeche_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "BP_Bebauung"."BP_BaugebietBauweise" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE;
ALTER TABLE "BP_Bebauung"."BP_BaugebietBauweise" ENABLE TRIGGER "change_to_BP_BaugebietBauweise";

-- BP_GemeinbedarfsFlaeche
ALTER TABLE "BP_Gemeinbedarf_Spiel_und_Sportanlagen"."BP_GemeinbedarfsFlaeche" ADD COLUMN "bauweise" INTEGER;
ALTER TABLE "BP_Gemeinbedarf_Spiel_und_Sportanlagen"."BP_GemeinbedarfsFlaeche" ADD COLUMN "bebauungsArt" INTEGER;
ALTER TABLE "BP_Gemeinbedarf_Spiel_und_Sportanlagen"."BP_GemeinbedarfsFlaeche" ADD COLUMN "abweichendeBauweise" INTEGER;
ALTER TABLE "BP_Gemeinbedarf_Spiel_und_Sportanlagen"."BP_GemeinbedarfsFlaeche" ADD CONSTRAINT "fk_BP_GemeinbedarfsFlaeche_BP_Bauweise1"
    FOREIGN KEY ("bauweise")
    REFERENCES "BP_Bebauung"."BP_Bauweise" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE;
ALTER TABLE "BP_Gemeinbedarf_Spiel_und_Sportanlagen"."BP_GemeinbedarfsFlaeche" ADD CONSTRAINT "fk_BP_GemeinbedarfsFlaeche_BP_AbweichendeBauweise1"
    FOREIGN KEY ("abweichendeBauweise")
    REFERENCES "BP_Bebauung"."BP_AbweichendeBauweise" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE;
ALTER TABLE "BP_Gemeinbedarf_Spiel_und_Sportanlagen"."BP_GemeinbedarfsFlaeche" ADD CONSTRAINT "fk_BP_GemeinbedarfsFlaeche_BP_BebauungsArt1"
    FOREIGN KEY ("bebauungsArt")
    REFERENCES "BP_Bebauung"."BP_BebauungsArt" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE;
COMMENT ON COLUMN "BP_Gemeinbedarf_Spiel_und_Sportanlagen"."BP_GemeinbedarfsFlaeche"."bauweise" IS 'Festsetzung der Bauweise (§9, Abs. 1, Nr. 2 BauGB).';
COMMENT ON COLUMN "BP_Gemeinbedarf_Spiel_und_Sportanlagen"."BP_GemeinbedarfsFlaeche"."bebauungsArt" IS 'Detaillierte Festsetzung der Bauweise (§9, Abs. 1, Nr. 2 BauGB).';
COMMENT ON COLUMN "BP_Gemeinbedarf_Spiel_und_Sportanlagen"."BP_GemeinbedarfsFlaeche"."abweichendeBauweise" IS 'Nähere Bezeichnung einer "Abweichenden Bauweise" ("bauweise" == 3000).';
ALTER TABLE "BP_Bebauung"."BP_GestaltungBaugebiet" DISABLE TRIGGER "change_to_BP_GestaltungBaugebiet";
INSERT INTO "BP_Bebauung"."BP_GestaltungBaugebiet"(gid) SELECT gid FROM "BP_Gemeinbedarf_Spiel_und_Sportanlagen"."BP_GemeinbedarfsFlaeche";
ALTER TABLE "BP_Gemeinbedarf_Spiel_und_Sportanlagen"."BP_GemeinbedarfsFlaeche" DROP CONSTRAINT "fk_BP_GemeinbedarfsFlaeche_parent";
ALTER TABLE "BP_Gemeinbedarf_Spiel_und_Sportanlagen"."BP_GemeinbedarfsFlaeche" ADD CONSTRAINT "fk_BP_GemeinbedarfsFlaeche_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "BP_Bebauung"."BP_GestaltungBaugebiet" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE;
ALTER TABLE "BP_Bebauung"."BP_GestaltungBaugebiet" ENABLE TRIGGER "change_to_BP_GestaltungBaugebiet";

-- BP_BesondererNutzungszweckFlaeche
ALTER TABLE "BP_Bebauung"."BP_BesondererNutzungszweckFlaeche" ADD COLUMN "bauweise" INTEGER;
ALTER TABLE "BP_Bebauung"."BP_BesondererNutzungszweckFlaeche" ADD COLUMN "bebauungsArt" INTEGER;
ALTER TABLE "BP_Bebauung"."BP_BesondererNutzungszweckFlaeche" ADD COLUMN "abweichendeBauweise" INTEGER;
ALTER TABLE "BP_Bebauung"."BP_BesondererNutzungszweckFlaeche" ADD CONSTRAINT "fk_BP_BesondererNutzungszweckFlaeche_BP_Bauweise1"
    FOREIGN KEY ("bauweise")
    REFERENCES "BP_Bebauung"."BP_Bauweise" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE;
ALTER TABLE "BP_Bebauung"."BP_BesondererNutzungszweckFlaeche" ADD CONSTRAINT "fk_BP_BesondererNutzungszweckFlaeche_BP_AbweichendeBauweise1"
    FOREIGN KEY ("abweichendeBauweise")
    REFERENCES "BP_Bebauung"."BP_AbweichendeBauweise" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE;
ALTER TABLE "BP_Bebauung"."BP_BesondererNutzungszweckFlaeche" ADD CONSTRAINT "fk_BP_BesondererNutzungszweckFlaeche_BP_BebauungsArt1"
    FOREIGN KEY ("bebauungsArt")
    REFERENCES "BP_Bebauung"."BP_BebauungsArt" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE;
COMMENT ON COLUMN "BP_Bebauung"."BP_BesondererNutzungszweckFlaeche"."bauweise" IS 'Festsetzung der Bauweise (§9, Abs. 1, Nr. 2 BauGB).';
COMMENT ON COLUMN "BP_Bebauung"."BP_BesondererNutzungszweckFlaeche"."bebauungsArt" IS 'Detaillierte Festsetzung der Bauweise (§9, Abs. 1, Nr. 2 BauGB).';
COMMENT ON COLUMN "BP_Bebauung"."BP_BesondererNutzungszweckFlaeche"."abweichendeBauweise" IS 'Nähere Bezeichnung einer "Abweichenden Bauweise" ("bauweise" == 3000).';

-- CR 011
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

-- CR 012
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

-- CR 013
-- Verschiebe Enumeration BP_Laermpegelbereich nach BP_Umwelt
CREATE TABLE "BP_Umwelt"."BP_Laermpegelbereich" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Code") );
GRANT SELECT ON "BP_Umwelt"."BP_Laermpegelbereich" TO xp_gast;
INSERT INTO "BP_Umwelt"."BP_Laermpegelbereich" ("Code", "Bezeichner") VALUES (1000, 'I');
INSERT INTO "BP_Umwelt"."BP_Laermpegelbereich" ("Code", "Bezeichner") VALUES (1100, 'II');
INSERT INTO "BP_Umwelt"."BP_Laermpegelbereich" ("Code", "Bezeichner") VALUES (1200, 'III');
INSERT INTO "BP_Umwelt"."BP_Laermpegelbereich" ("Code", "Bezeichner") VALUES (1300, 'IV');
INSERT INTO "BP_Umwelt"."BP_Laermpegelbereich" ("Code", "Bezeichner") VALUES (1400, 'V');
INSERT INTO "BP_Umwelt"."BP_Laermpegelbereich" ("Code", "Bezeichner") VALUES (1500, 'VI');
INSERT INTO "BP_Umwelt"."BP_Laermpegelbereich" ("Code", "Bezeichner") VALUES (1600, 'VII');
ALTER TABLE "BP_Umwelt"."BP_Immissionsschutz" DROP CONSTRAINT "fk_BP_Immissionsschutz_BP_Laermpegelbereich1";
ALTER TABLE "BP_Umwelt"."BP_Immissionsschutz" ADD CONSTRAINT "fk_BP_Immissionsschutz_BP_Laermpegelbereich1"
    FOREIGN KEY ("laermpegelbereich")
    REFERENCES "BP_Umwelt"."BP_Laermpegelbereich" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE;
-- neue Enumerationen
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
-- -----------------------------------------------------
-- Table "BP_Umwelt"."BP_ImmissionsschutzTypen"
-- -----------------------------------------------------
CREATE TABLE "BP_Umwelt"."BP_ImmissionsschutzTypen" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Code") );
GRANT SELECT ON "BP_Umwelt"."BP_ImmissionsschutzTypen" TO xp_gast;
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
-- Tabelle BP_Immissionsschutz um neue Felder ergänzen
ALTER TABLE "BP_Umwelt"."BP_Immissionsschutz" ADD COLUMN "technVorkehrung" INTEGER;
ALTER TABLE "BP_Umwelt"."BP_Immissionsschutz" ADD COLUMN "detaillierteTechnVorkehrung" INTEGER;
ALTER TABLE "BP_Umwelt"."BP_Immissionsschutz" ADD COLUMN "typ" INTEGER;
ALTER TABLE "BP_Umwelt"."BP_Immissionsschutz" ADD CONSTRAINT "fk_BP_Immissionsschutz_BP_TechnVorkehrungenImmissionsschutz1"
    FOREIGN KEY ("technVorkehrung")
    REFERENCES "BP_Umwelt"."BP_TechnVorkehrungenImmissionsschutz" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE;
ALTER TABLE "BP_Umwelt"."BP_Immissionsschutz" ADD CONSTRAINT "fk_BP_Immissionsschutz_BP_DetailTechnVorkehrung1"
    FOREIGN KEY ("detaillierteTechnVorkehrung")
    REFERENCES "BP_Umwelt"."BP_DetailTechnVorkehrungImmissionsschutz" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE;
ALTER TABLE "BP_Umwelt"."BP_Immissionsschutz" ADD CONSTRAINT "fk_BP_Immissionsschutz_BP_ImmissionsschutzTypen1"
    FOREIGN KEY ("typ")
    REFERENCES "BP_Umwelt"."BP_ImmissionsschutzTypen" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE;
COMMENT ON COLUMN "BP_Umwelt"."BP_Immissionsschutz"."technVorkehrung" IS 'Klassifizierung der auf der Fläche zu treffenden baulichen oder sonstigen technischen Vorkehrungen';
COMMENT ON COLUMN "BP_Umwelt"."BP_Immissionsschutz"."detaillierteTechnVorkehrung" IS 'Detaillierte Klassifizierung der auf der Fläche zu treffenden baulichen oder sonstigen technischen Vorkehrungen';
COMMENT ON COLUMN "BP_Umwelt"."BP_Immissionsschutz"."typ" IS 'Differenzierung der Immissionsschutz-Fläche';

-- CR 014
ALTER TABLE "RP_Basisobjekte"."RP_Plan" ADD COLUMN "amtlicherSchluessel" VARCHAR(256);
COMMENT ON COLUMN "RP_Basisobjekte"."RP_Plan"."amtlicherSchluessel" IS 'Amtlicher Schlüssel eines Plans auf Basis des AGS-Schlüssels (Amtlicher Gemeindeschlüssel).';

-- CR 015
-- von 4 auf 5.0 wurde RP_Plan um das Attribut verfahren erweitert, dies ist in der DB bisher noch nicht nachvollzogen
-- -----------------------------------------------------
-- Table "RP_Basisobjekte"."RP_Verfahren"
-- -----------------------------------------------------
CREATE TABLE "RP_Basisobjekte"."RP_Verfahren" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Code") );
GRANT SELECT ON "RP_Basisobjekte"."RP_Verfahren" TO xp_gast;
-- -----------------------------------------------------
-- Data for table "RP_Basisobjekte"."RP_Verfahren"
-- -----------------------------------------------------
INSERT INTO "RP_Basisobjekte"."RP_Verfahren" ("Code", "Bezeichner") VALUES (1000, 'Aenderung');
INSERT INTO "RP_Basisobjekte"."RP_Verfahren" ("Code", "Bezeichner") VALUES (2000, 'Teilfortschreibung');
INSERT INTO "RP_Basisobjekte"."RP_Verfahren" ("Code", "Bezeichner") VALUES (3000, 'Neuaufstellung');
INSERT INTO "RP_Basisobjekte"."RP_Verfahren" ("Code", "Bezeichner") VALUES (4000, 'Gesamtfortschreibung');
INSERT INTO "RP_Basisobjekte"."RP_Verfahren" ("Code", "Bezeichner") VALUES (5000, 'Aktualisierung');
INSERT INTO "RP_Basisobjekte"."RP_Verfahren" ("Code", "Bezeichner") VALUES (6000, 'Neubekanntmachung');
-- RP_Plan ändern
ALTER TABLE  "RP_Basisobjekte"."RP_Plan" ADD COLUMN "verfahren" INTEGER;
ALTER TABLE  "RP_Basisobjekte"."RP_Plan" ADD CONSTRAINT "fk_rp_plan_rp_verfahren1"
    FOREIGN KEY ("verfahren" )
    REFERENCES "RP_Basisobjekte"."RP_Verfahren" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE;
COMMENT ON COLUMN "RP_Basisobjekte"."RP_Plan"."verfahren" IS 'Verfahrensstatus des Plans.';

-- CR 016
COMMENT ON COLUMN "XP_Praesentationsobjekte"."XP_APObjekt_dientZurDarstellungVon"."index" IS 'Wenn das Attribut art des Fachobjektes mehrfach belegt ist gibt index an, auf welche Instanz des Attributs sich das Präsentationsobjekt bezieht. Indexnummern beginnen dabei immer mit 0.';

-- CR 017
-- BP
ALTER TABLE "BP_Sonstiges"."BP_KennzeichnungsFlaeche" ADD COLUMN "istVerdachtsflaeche" BOOLEAN;
ALTER TABLE "BP_Sonstiges"."BP_KennzeichnungsFlaeche" ADD COLUMN "nummer" CHARACTER VARYING(256);
COMMENT ON COLUMN "BP_Sonstiges"."BP_KennzeichnungsFlaeche"."istVerdachtsflaeche" IS 'Legt fest, ob eine Altlast-Verdachtsfläche vorliegt';
COMMENT ON COLUMN "BP_Sonstiges"."BP_KennzeichnungsFlaeche"."nummer" IS 'Nummer im Altlastkataster';
-- FP
ALTER TABLE "FP_Sonstiges"."FP_Kennzeichnung" ADD COLUMN "istVerdachtsflaeche" BOOLEAN;
ALTER TABLE "FP_Sonstiges"."FP_Kennzeichnung" ADD COLUMN "nummer" CHARACTER VARYING(256);
COMMENT ON COLUMN "FP_Sonstiges"."FP_Kennzeichnung"."istVerdachtsflaeche" IS 'Legt fest, ob eine Altlast-Verdachtsfläche vorliegt';
COMMENT ON COLUMN "FP_Sonstiges"."FP_Kennzeichnung"."nummer" IS 'Nummer im Altlastkataster';
-- SO
COMMENT ON COLUMN "SO_NachrichtlicheUebernahmen"."SO_Bodenschutzrecht"."nummer" IS 'Amtliche Bezeichnung / Kennziffer der Festlegung bzw. Nummer in einem Altlast-Kataster.';

-- CR 019
-- wird für einen Umbau der Datenstruktur zum Anlass genommen: Entfernen der Klasse BP_BaugebietObjekt und Modellierung des types BP_ZusaetzlicheFestsetzungen
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
-- vorhandene Daten aus BP_BaugebietsTeilFlaeche übernehmen
INSERT INTO "BP_Bebauung"."BP_ZusaetzlicheFestsetzungen" ("gid","wohnnutzungEGStrasse","ZWohn","GFAntWohnen","GFWohnen","GFAntGewerbe","GFGewerbe")
SELECT "gid","wohnnutzungEGStrasse","ZWohn","GFAntWohnen","GFWohnen","GFAntGewerbe","GFGewerbe" FROM "BP_Bebauung"."BP_BaugebietsTeilFlaeche";
-- jetzt erst Trigger etablieren
CREATE TRIGGER "change_to_BP_ZusaetzlicheFestsetzungen" BEFORE INSERT OR UPDATE ON "BP_Bebauung"."BP_ZusaetzlicheFestsetzungen" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_BP_ZusaetzlicheFestsetzungen" AFTER DELETE ON "BP_Bebauung"."BP_ZusaetzlicheFestsetzungen" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
-- Löschen der vorhandenen Felder in BP_BaugebietsTeilFlaeche
ALTER TABLE "BP_Bebauung"."BP_BaugebietsTeilFlaeche" DROP COLUMN "wohnnutzungEGStrasse";
ALTER TABLE "BP_Bebauung"."BP_BaugebietsTeilFlaeche" DROP COLUMN "ZWohn";
ALTER TABLE "BP_Bebauung"."BP_BaugebietsTeilFlaeche" DROP COLUMN "GFAntWohnen";
ALTER TABLE "BP_Bebauung"."BP_BaugebietsTeilFlaeche" DROP COLUMN "GFWohnen";
ALTER TABLE "BP_Bebauung"."BP_BaugebietsTeilFlaeche" DROP COLUMN "GFAntGewerbe";
ALTER TABLE "BP_Bebauung"."BP_BaugebietsTeilFlaeche" DROP COLUMN "GFGewerbe";
-- Die Felder aus BP_BaugebietObjekt nach BP_BaugebietsTeilFlaeche
ALTER TABLE "BP_Bebauung"."BP_BaugebietsTeilFlaeche" ADD COLUMN "allgArtDerBaulNutzung" INTEGER;
ALTER TABLE "BP_Bebauung"."BP_BaugebietsTeilFlaeche" ADD COLUMN "besondereArtDerBaulNutzung" INTEGER;
ALTER TABLE "BP_Bebauung"."BP_BaugebietsTeilFlaeche" ADD COLUMN "sondernutzung" INTEGER;
ALTER TABLE "BP_Bebauung"."BP_BaugebietsTeilFlaeche" ADD COLUMN "detaillierteArtDerBaulNutzung" INTEGER;
ALTER TABLE "BP_Bebauung"."BP_BaugebietsTeilFlaeche" ADD COLUMN "nutzungText" VARCHAR(256);
ALTER TABLE "BP_Bebauung"."BP_BaugebietsTeilFlaeche" ADD COLUMN "abweichungBauNVO" INTEGER;
ALTER TABLE "BP_Bebauung"."BP_BaugebietsTeilFlaeche" ADD COLUMN "zugunstenVon" VARCHAR(64);
ALTER TABLE "BP_Bebauung"."BP_BaugebietsTeilFlaeche" ADD CONSTRAINT "fk_BP_Baugebiet_XP_AllgArtDerBaulNutzung1"
    FOREIGN KEY ("allgArtDerBaulNutzung")
    REFERENCES "XP_Enumerationen"."XP_AllgArtDerBaulNutzung" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE;
ALTER TABLE "BP_Bebauung"."BP_BaugebietsTeilFlaeche" ADD CONSTRAINT "fk_BP_BaugebietsTF_XP_BesondereArtDerBaulNutzung1"
    FOREIGN KEY ("besondereArtDerBaulNutzung")
    REFERENCES "XP_Enumerationen"."XP_BesondereArtDerBaulNutzung" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE;
ALTER TABLE "BP_Bebauung"."BP_BaugebietsTeilFlaeche" ADD CONSTRAINT "fk_BP_BaugebietsTF_XP_Sondernutzungen1"
    FOREIGN KEY ("sondernutzung")
    REFERENCES "XP_Enumerationen"."XP_Sondernutzungen" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE;
ALTER TABLE "BP_Bebauung"."BP_BaugebietsTeilFlaeche" ADD CONSTRAINT "fk_BP_BaugebietsTF_BP_DetailArtDerBaulNutzung1"
    FOREIGN KEY ("detaillierteArtDerBaulNutzung")
    REFERENCES "BP_Bebauung"."BP_DetailArtDerBaulNutzung" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE;
ALTER TABLE "BP_Bebauung"."BP_BaugebietsTeilFlaeche" ADD CONSTRAINT "fk_BP_BaugebietsTF_XP_AbweichungBauNVOTypen1"
    FOREIGN KEY ("abweichungBauNVO")
    REFERENCES "XP_Enumerationen"."XP_AbweichungBauNVOTypen" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE;
CREATE INDEX "idx_fk_BP_BaugebietsTF_XP_AllgArtDerBaulNutzung1_idx" ON "BP_Bebauung"."BP_BaugebietsTeilFlaeche" ("allgArtDerBaulNutzung");
CREATE INDEX "idx_fk_BP_BaugebietsTF_XP_BesondereArtDerBaulNutzung1_idx" ON "BP_Bebauung"."BP_BaugebietsTeilFlaeche" ("besondereArtDerBaulNutzung");
CREATE INDEX "idx_fk_BP_BaugebietsTF_XP_Sondernutzungen1_idx" ON "BP_Bebauung"."BP_BaugebietsTeilFlaeche" ("sondernutzung");
CREATE INDEX "idx_fk_BP_BaugebietsTF_BP_DetailArtDerBaulNutzung1_idx" ON "BP_Bebauung"."BP_BaugebietsTeilFlaeche" ("detaillierteArtDerBaulNutzung");
CREATE INDEX "idx_fk_BP_BaugebietsTF_XP_AbweichungBauNVOTypen1_idx" ON "BP_Bebauung"."BP_BaugebietsTeilFlaeche" ("abweichungBauNVO");
COMMENT ON COLUMN "BP_Bebauung"."BP_BaugebietsTeilFlaeche"."allgArtDerBaulNutzung" IS 'Spezifikation der allgemeinen Art der baulichen Nutzung.';
COMMENT ON COLUMN "BP_Bebauung"."BP_BaugebietsTeilFlaeche"."besondereArtDerBaulNutzung" IS 'Festsetzung der Art der baulichen Nutzung (§9, Abs. 1, Nr. 1 BauGB).';
COMMENT ON COLUMN "BP_Bebauung"."BP_BaugebietsTeilFlaeche"."sondernutzung" IS 'Bei Sondergebieten nach BauNVO 1977 oder 1000 (besondereArtDerBaulNutzung == 2000 oder 2100): Spezifische Nutzung der Sonderbaufläche nach §§ 10 und 11 BauNVO.';
COMMENT ON COLUMN "BP_Bebauung"."BP_BaugebietsTeilFlaeche"."detaillierteArtDerBaulNutzung" IS 'Über eine CodeList definierte Nutzungsart.';
COMMENT ON COLUMN "BP_Bebauung"."BP_BaugebietsTeilFlaeche"."nutzungText" IS 'Bei Nutzungsform "Sondergebiet" ("besondereArtDerBaulNutzung" == 2000, 2100, 3000 oder 4000): Kurzform der besonderen Art der baulichen Nutzung.';
COMMENT ON COLUMN "BP_Bebauung"."BP_BaugebietsTeilFlaeche"."abweichungBauNVO" IS 'Art der Abweichung von der BauNVO.';
COMMENT ON COLUMN "BP_Bebauung"."BP_BaugebietsTeilFlaeche"."zugunstenVon" IS 'Angabe des Begünstigen einer Ausweisung.';
-- Daten nach BP_BaugebietsTeilFlaeche übernehmen
UPDATE "BP_Bebauung"."BP_BaugebietsTeilFlaeche" tf SET "allgArtDerBaulNutzung" = (SELECT "allgArtDerBaulNutzung" FROM "BP_Bebauung"."BP_BaugebietObjekt" o WHERE tf.gid = o.gid);
UPDATE "BP_Bebauung"."BP_BaugebietsTeilFlaeche" tf SET "besondereArtDerBaulNutzung" = (SELECT "besondereArtDerBaulNutzung" FROM "BP_Bebauung"."BP_BaugebietObjekt" o WHERE tf.gid = o.gid);
UPDATE "BP_Bebauung"."BP_BaugebietsTeilFlaeche" tf SET "sondernutzung" = (SELECT "sondernutzung" FROM "BP_Bebauung"."BP_BaugebietObjekt" o WHERE tf.gid = o.gid);
UPDATE "BP_Bebauung"."BP_BaugebietsTeilFlaeche" tf SET "detaillierteArtDerBaulNutzung" = (SELECT "detaillierteArtDerBaulNutzung" FROM "BP_Bebauung"."BP_BaugebietObjekt" o WHERE tf.gid = o.gid);
UPDATE "BP_Bebauung"."BP_BaugebietsTeilFlaeche" tf SET "nutzungText" = (SELECT "nutzungText" FROM "BP_Bebauung"."BP_BaugebietObjekt" o WHERE tf.gid = o.gid);
UPDATE "BP_Bebauung"."BP_BaugebietsTeilFlaeche" tf SET "abweichungBauNVO" = (SELECT "abweichungBauNVO" FROM "BP_Bebauung"."BP_BaugebietObjekt" o WHERE tf.gid = o.gid);
UPDATE "BP_Bebauung"."BP_BaugebietsTeilFlaeche" tf SET "zugunstenVon" = (SELECT "zugunstenVon" FROM "BP_Bebauung"."BP_BaugebietObjekt" o WHERE tf.gid = o.gid);
-- -----------------------------------------------------
-- View "BP_Bebauung"."BP_BaugebietsTeilFlaeche_qv"
-- -----------------------------------------------------
DROP VIEW "BP_Bebauung"."BP_BaugebietsTeilFlaeche_qv";
CREATE OR REPLACE VIEW "BP_Bebauung"."BP_BaugebietsTeilFlaeche_qv" AS
SELECT g.*
FROM "BP_Bebauung"."BP_BaugebietsTeilFlaeche" g;
GRANT SELECT ON TABLE "BP_Bebauung"."BP_BaugebietsTeilFlaeche_qv" TO xp_gast;
-- parent von BP_BaugebietsTeilFlaeche neu ausrichten
ALTER TABLE "BP_Bebauung"."BP_BaugebietsTeilFlaeche" DROP CONSTRAINT "fk_BP_BaugebietsTeilFlaeche_parent";
ALTER TABLE "BP_Bebauung"."BP_BaugebietsTeilFlaeche" ADD CONSTRAINT "fk_BP_BaugebietsTeilFlaeche_parent"
    FOREIGN KEY ("gid")
    REFERENCES "BP_Bebauung"."BP_ZusaetzlicheFestsetzungen" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE;
-- parent von BP_BaugebietObjekt löschen und danach Tabelle löschen
ALTER TABLE "BP_Bebauung"."BP_BaugebietObjekt" DROP CONSTRAINT "fk_BP_Baugebiet_parent";
DROP TABLE "BP_Bebauung"."BP_BaugebietObjekt";

-- CR 020 nicht relevant

-- CR 021
ALTER TABLE "SO_Basisobjekte"."SO_Plan" ADD COLUMN "versionBauGBDatum" DATE;
ALTER TABLE "SO_Basisobjekte"."SO_Plan" ADD COLUMN "versionBauGBText" VARCHAR(255);
ALTER TABLE "SO_Basisobjekte"."SO_Plan" ADD COLUMN "versionSonstRechtsgrundlageDatum" DATE;
ALTER TABLE "SO_Basisobjekte"."SO_Plan" ADD COLUMN "versionSonstRechtsgrundlageText" VARCHAR(255);
COMMENT ON COLUMN "SO_Basisobjekte"."SO_Plan"."versionBauGBDatum" IS 'Datum der zugrunde liegenden Version des BauGB.';
COMMENT ON COLUMN "SO_Basisobjekte"."SO_Plan"."versionBauGBText" IS 'Textliche Spezifikation der zugrunde liegenden Version des BauGB.';
COMMENT ON COLUMN "SO_Basisobjekte"."SO_Plan"."versionSonstRechtsgrundlageDatum" IS 'Datum einer zugrunde liegenden anderen Rechtsgrundlage als das BauGB.';
COMMENT ON COLUMN "SO_Basisobjekte"."SO_Plan"."versionSonstRechtsgrundlageText" IS 'Textliche Spezifikation einer zugrunde liegenden anderen Rechtsgrundlage als das BauGB.';

-- CR 023 siehe CR 010

-- CR 024
-- BP
-- Tabellen anlegen
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
-- Daten übernehmen
INSERT INTO "BP_Verkehr"."BP_VerkehrsFlaecheBesondererZweckbestimmung_zweckbestimmung" ("BP_VerkehrsFlaecheBesondererZweckbestimmung_gid","zweckbestimmung") SELECT gid,"zweckbestimmung" FROM "BP_Verkehr"."BP_VerkehrsFlaecheBesondererZweckbestimmung" WHERE "zweckbestimmung" IS NOT NULL;
INSERT INTO "BP_Verkehr"."BP_VerkehrsFlaecheBesondererZweckbestimmung_detaillierteZweckbestimmung" ("BP_VerkehrsFlaecheBesondererZweckbestimmung_gid","detaillierteZweckbestimmung") SELECT gid,"detaillierteZweckbestimmung" FROM "BP_Verkehr"."BP_VerkehrsFlaecheBesondererZweckbestimmung" WHERE "detaillierteZweckbestimmung" IS NOT NULL;
-- View ersetzen
DROP VIEW "BP_Verkehr"."BP_VerkehrsFlaecheBesondererZweckbestimmungFlaeche_qv";
CREATE OR REPLACE VIEW "BP_Verkehr"."BP_VerkehrsFlaecheBesondererZweckbestimmungFlaeche_qv" AS
 SELECT g.gid, g.position, z1 as zweckbestimmung1,z2 as zweckbestimmung2,z3 as zweckbestimmung3,z4 as zweckbestimmung4,
 coalesce(z1 / z1, 0) + coalesce(z2 / z2, 0) + coalesce(z3 / z3, 0) + coalesce(z4 / z4, 0) as anz_zweckbestimmung
  FROM
 "BP_Verkehr"."BP_VerkehrsFlaecheBesondererZweckbestimmungFlaeche" g
 LEFT JOIN
 crosstab('SELECT "BP_VerkehrsFlaecheBesondererZweckbestimmung_gid", "BP_VerkehrsFlaecheBesondererZweckbestimmung_gid", zweckbestimmung FROM "BP_Verkehr"."BP_VerkehrsFlaecheBesondererZweckbestimmung_zweckbestimmung" ORDER BY 1,3') zt
 (zgid bigint, z1 integer,z2 integer,z3 integer,z4 integer)
 ON g.gid=zt.zgid;
GRANT SELECT ON TABLE "BP_Verkehr"."BP_VerkehrsFlaecheBesondererZweckbestimmungFlaeche_qv" TO xp_gast;
-- Felder löschen
ALTER TABLE "BP_Verkehr"."BP_VerkehrsFlaecheBesondererZweckbestimmung" DROP COLUMN "zweckbestimmung";
ALTER TABLE "BP_Verkehr"."BP_VerkehrsFlaecheBesondererZweckbestimmung" DROP COLUMN "detaillierteZweckbestimmung";
-- FP
-- Tabellen anlegen
-- -----------------------------------------------------
-- Table "FP_Verkehr"."FP_Strassenverkehr_zweckbestimmung"
-- -----------------------------------------------------
CREATE TABLE "FP_Verkehr"."FP_Strassenverkehr_zweckbestimmung" (
  "FP_Strassenverkehr_gid" BIGINT NOT NULL,
  "zweckbestimmung" INTEGER NOT NULL,
  PRIMARY KEY ("FP_Strassenverkehr_gid", "zweckbestimmung"),
  CONSTRAINT "fk_FP_Strassenverkehr_zweckbestimmung1"
    FOREIGN KEY ("FP_Strassenverkehr_gid")
    REFERENCES "FP_Verkehr"."FP_Strassenverkehr" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_Strassenverkehr_zweckbestimmung2"
    FOREIGN KEY ("zweckbestimmung")
    REFERENCES "FP_Verkehr"."FP_ZweckbestimmungStrassenverkehr" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE);

CREATE INDEX "idx_fk_FP_Strassenverkehr_zweckbestimmung1_idx" ON "FP_Verkehr"."FP_Strassenverkehr_zweckbestimmung" ("zweckbestimmung");
CREATE INDEX "idx_fk_FP_Strassenverkehr_zweckbestimmung2_idx" ON "FP_Verkehr"."FP_Strassenverkehr_zweckbestimmung" ("FP_Strassenverkehr_gid");
GRANT SELECT ON TABLE "FP_Verkehr"."FP_Strassenverkehr_zweckbestimmung" TO xp_gast;
GRANT ALL ON TABLE "FP_Verkehr"."FP_Strassenverkehr_zweckbestimmung" TO fp_user;
COMMENT ON TABLE "FP_Verkehr"."FP_Strassenverkehr_zweckbestimmung" IS 'Zweckbestimmung der Fläche';
-- -----------------------------------------------------
-- Table "FP_Verkehr"."FP_Strassenverkehr_detaillierteZweckbestimmung"
-- -----------------------------------------------------
CREATE TABLE "FP_Verkehr"."FP_Strassenverkehr_detaillierteZweckbestimmung" (
  "FP_Strassenverkehr_gid" BIGINT NOT NULL,
  "detaillierteZweckbestimmung" INTEGER NOT NULL,
  PRIMARY KEY ("FP_Strassenverkehr_gid", "detaillierteZweckbestimmung"),
  CONSTRAINT "fk_FP_Strassenverkehr_detaillierteZweckbestimmung1"
    FOREIGN KEY ("FP_Strassenverkehr_gid")
    REFERENCES "FP_Verkehr"."FP_Strassenverkehr" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_Strassenverkehr_detaillierteZweckbestimmung2"
    FOREIGN KEY ("detaillierteZweckbestimmung")
    REFERENCES "FP_Verkehr"."FP_DetailZweckbestStrassenverkehr" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE);

CREATE INDEX "idx_fk_FP_Strassenverkehr_detaillierteZweckbestimmung1_idx" ON "FP_Verkehr"."FP_Strassenverkehr_detaillierteZweckbestimmung" ("detaillierteZweckbestimmung");
CREATE INDEX "idx_fk_FP_Strassenverkehr_detaillierteZweckbestimmung2_idx" ON "FP_Verkehr"."FP_Strassenverkehr_detaillierteZweckbestimmung" ("FP_Strassenverkehr_gid");
GRANT SELECT ON TABLE "FP_Verkehr"."FP_Strassenverkehr_detaillierteZweckbestimmung" TO xp_gast;
GRANT ALL ON TABLE "FP_Verkehr"."FP_Strassenverkehr_detaillierteZweckbestimmung" TO fp_user;
COMMENT ON TABLE "FP_Verkehr"."FP_Strassenverkehr_detaillierteZweckbestimmung" IS 'Über eine CodeList definierte detaillierte Zweckbestimmung der Fläche.';
-- Daten übernehmen
INSERT INTO "FP_Verkehr"."FP_Strassenverkehr_zweckbestimmung" ("FP_Strassenverkehr_gid","zweckbestimmung") SELECT gid,"zweckbestimmung" FROM "FP_Verkehr"."FP_Strassenverkehr" WHERE "zweckbestimmung" IS NOT NULL;
INSERT INTO "FP_Verkehr"."FP_Strassenverkehr_detaillierteZweckbestimmung" ("FP_Strassenverkehr_gid","detaillierteZweckbestimmung") SELECT gid,"detaillierteZweckbestimmung" FROM "FP_Verkehr"."FP_Strassenverkehr" WHERE "detaillierteZweckbestimmung" IS NOT NULL;
-- Views löschen
DROP VIEW IF EXISTS "FP_Verkehr"."FP_Strassenverkehr_qv";
DROP VIEW "FP_Verkehr"."FP_StrassenverkehrFlaeche_qv";
DROP VIEW "FP_Verkehr"."FP_StrassenverkehrLinie_qv";
DROP VIEW "FP_Verkehr"."FP_StrassenverkehrPunkt_qv";
-- Views neu anlegen
-- -----------------------------------------------------
-- View "FP_Verkehr"."FP_Strassenverkehr_qv"
-- -----------------------------------------------------
CREATE OR REPLACE VIEW "FP_Verkehr"."FP_Strassenverkehr_qv" AS
 SELECT g.gid, xpo.ebene, xpo.rechtsstand, z1 as zweckbestimmung1,z2 as zweckbestimmung2,z3 as zweckbestimmung3,z4 as zweckbestimmung4,
 coalesce(z1 / z1, 0) + coalesce(z2 / z2, 0) + coalesce(z3 / z3, 0) + coalesce(z4 / z4, 0) as anz_zweckbestimmung
  FROM
 "FP_Verkehr"."FP_Strassenverkehr" g
 LEFT JOIN
 crosstab('SELECT "FP_Strassenverkehr_gid", "FP_Strassenverkehr_gid", zweckbestimmung FROM "FP_Verkehr"."FP_Strassenverkehr_zweckbestimmung" ORDER BY 1,3') zt
 (zgid bigint, z1 integer,z2 integer,z3 integer,z4 integer)
 ON g.gid=zt.zgid
 JOIN "XP_Basisobjekte"."XP_Objekt" xpo ON g.gid = xpo.gid;
GRANT SELECT ON TABLE "FP_Verkehr"."FP_Strassenverkehr_qv" TO xp_gast;
-- -----------------------------------------------------
-- View "FP_Verkehr"."FP_StrassenverkehrFlaeche_qv"
-- -----------------------------------------------------
CREATE OR REPLACE VIEW "FP_Verkehr"."FP_StrassenverkehrFlaeche_qv" AS
 SELECT g.gid, g.position, p.ebene, p.rechtsstand, p.zweckbestimmung1, p.zweckbestimmung2, p.zweckbestimmung3, p.zweckbestimmung4, p.anz_zweckbestimmung
FROM "FP_Verkehr"."FP_StrassenverkehrFlaeche" g
    JOIN "FP_Verkehr"."FP_Strassenverkehr_qv" p ON g.gid = p.gid;
GRANT SELECT ON TABLE "FP_Verkehr"."FP_StrassenverkehrFlaeche_qv" TO xp_gast;
-- -----------------------------------------------------
-- View "FP_Verkehr"."FP_StrassenverkehrLinie_qv"
-- -----------------------------------------------------
CREATE OR REPLACE VIEW "FP_Verkehr"."FP_StrassenverkehrLinie_qv" AS
 SELECT g.gid, g.position, p.ebene, p.rechtsstand, p.zweckbestimmung1, p.zweckbestimmung2, p.zweckbestimmung3, p.zweckbestimmung4, p.anz_zweckbestimmung
FROM "FP_Verkehr"."FP_StrassenverkehrLinie" g
    JOIN "FP_Verkehr"."FP_Strassenverkehr_qv" p ON g.gid = p.gid;
GRANT SELECT ON TABLE "FP_Verkehr"."FP_StrassenverkehrLinie_qv" TO xp_gast;
-- -----------------------------------------------------
-- View "FP_Verkehr"."FP_StrassenverkehrPunkt_qv"
-- -----------------------------------------------------
CREATE OR REPLACE VIEW "FP_Verkehr"."FP_StrassenverkehrPunkt_qv" AS
 SELECT g.gid, g.position, p.ebene, p.rechtsstand, p.zweckbestimmung1, p.zweckbestimmung2, p.zweckbestimmung3, p.zweckbestimmung4, p.anz_zweckbestimmung
FROM "FP_Verkehr"."FP_StrassenverkehrPunkt" g
    JOIN "FP_Verkehr"."FP_Strassenverkehr_qv" p ON g.gid = p.gid;
GRANT SELECT ON TABLE "FP_Verkehr"."FP_StrassenverkehrPunkt_qv" TO xp_gast;
-- Felder löschen
ALTER TABLE "FP_Verkehr"."FP_Strassenverkehr" DROP COLUMN "zweckbestimmung";
ALTER TABLE "FP_Verkehr"."FP_Strassenverkehr" DROP COLUMN "detaillierteZweckbestimmung";

-- CR 025
INSERT INTO "BP_Bebauung"."BP_BebauungsArt" ("Code", "Bezeichner") VALUES (8000, 'EinzelhaeuserDoppelhaeuserHausgruppen');

-- CR 026
-- -----------------------------------------------------
-- Table "SO_NachrichtlicheUebernahmen"."SO_KlassifizBauverbot"
-- -----------------------------------------------------
CREATE TABLE "SO_NachrichtlicheUebernahmen"."SO_KlassifizBauverbot" (
  "Code" INTEGER NOT NULL,
  "Bezeichner" VARCHAR(64) NOT NULL,
  PRIMARY KEY ("Code"));

GRANT SELECT ON TABLE "SO_NachrichtlicheUebernahmen"."SO_KlassifizBauverbot" TO xp_gast;

-- -----------------------------------------------------
-- Table "SO_NachrichtlicheUebernahmen"."SO_DetailKlassifizBauverbot"
-- -----------------------------------------------------
CREATE TABLE "SO_NachrichtlicheUebernahmen"."SO_DetailKlassifizBauverbot" (
  "Code" INTEGER NOT NULL,
  "Bezeichner" VARCHAR(64) NOT NULL,
  PRIMARY KEY ("Code"));

GRANT SELECT ON TABLE "SO_NachrichtlicheUebernahmen"."SO_DetailKlassifizBauverbot" TO xp_gast;
GRANT ALL ON TABLE "SO_NachrichtlicheUebernahmen"."SO_DetailKlassifizBauverbot" TO so_user;

-- -----------------------------------------------------
-- Table "SO_NachrichtlicheUebernahmen"."SO_RechtlicheGrundlageBauverbot"
-- -----------------------------------------------------
CREATE TABLE "SO_NachrichtlicheUebernahmen"."SO_RechtlicheGrundlageBauverbot" (
  "Code" INTEGER NOT NULL,
  "Bezeichner" VARCHAR(64) NOT NULL,
  PRIMARY KEY ("Code"));

GRANT SELECT ON TABLE "SO_NachrichtlicheUebernahmen"."SO_RechtlicheGrundlageBauverbot" TO xp_gast;

-- -----------------------------------------------------
-- Table "SO_NachrichtlicheUebernahmen"."SO_Bauverbotszone"
-- -----------------------------------------------------
CREATE TABLE  "SO_NachrichtlicheUebernahmen"."SO_Bauverbotszone" (
  "gid" BIGINT NOT NULL,
  "artDerFestlegung" INTEGER,
  "detailArtDerFestlegung" INTEGER,
  "rechtlicheGrundlage" INTEGER,
  "name" VARCHAR(64) NULL,
  "nummer" VARCHAR(64) NULL,
  PRIMARY KEY ("gid"),
  CONSTRAINT "fk_SO_Bauverbotszone_SO_Objekt1"
    FOREIGN KEY ("gid")
    REFERENCES "SO_Basisobjekte"."SO_Objekt" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_SO_Bauverbotszone_artDerFestlegung"
    FOREIGN KEY ("artDerFestlegung")
    REFERENCES "SO_NachrichtlicheUebernahmen"."SO_KlassifizBauverbot" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_SO_Bauverbotszone_detailArtDerFestlegung"
    FOREIGN KEY ("detailArtDerFestlegung")
    REFERENCES "SO_NachrichtlicheUebernahmen"."SO_DetailKlassifizBauverbot" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_SO_Bauverbotszone_rechtlicheGrundlage"
    FOREIGN KEY ("rechtlicheGrundlage")
    REFERENCES "SO_NachrichtlicheUebernahmen"."SO_RechtlicheGrundlageBauverbot" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE);

CREATE INDEX "idx_fk_SO_Bauverbotszone_artDerFestlegung" ON "SO_NachrichtlicheUebernahmen"."SO_Bauverbotszone" ("artDerFestlegung");
CREATE INDEX "idx_fk_SO_Bauverbotszone_detailArtDerFestlegung" ON "SO_NachrichtlicheUebernahmen"."SO_Bauverbotszone" ("detailArtDerFestlegung");
CREATE INDEX "idx_fk_SO_Bauverbotszone_rechtlicheGrundlage" ON "SO_NachrichtlicheUebernahmen"."SO_Bauverbotszone" ("rechtlicheGrundlage");
GRANT SELECT ON TABLE "SO_NachrichtlicheUebernahmen"."SO_Bauverbotszone" TO xp_gast;
GRANT ALL ON TABLE "SO_NachrichtlicheUebernahmen"."SO_Bauverbotszone" TO so_user;
COMMENT ON TABLE "SO_NachrichtlicheUebernahmen"."SO_Bauverbotszone" IS 'Festlegung nach Bodenschutzrecht.';
COMMENT ON COLUMN "SO_NachrichtlicheUebernahmen"."SO_Bauverbotszone"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN "SO_NachrichtlicheUebernahmen"."SO_Bauverbotszone"."artDerFestlegung" IS 'Klassifizierung des Bauverbots bzw. der Baubeschränkung';
COMMENT ON COLUMN "SO_NachrichtlicheUebernahmen"."SO_Bauverbotszone"."detailArtDerFestlegung" IS 'Detaillierte Klassifizierung des Bauverbots bzw. der Baubeschränkung über eine Codeliste';
COMMENT ON COLUMN "SO_NachrichtlicheUebernahmen"."SO_Bauverbotszone"."rechtlicheGrundlage" IS 'Rechtliche Grundlage des Bauverbots bzw. der Baubeschränkung';
COMMENT ON COLUMN "SO_NachrichtlicheUebernahmen"."SO_Bauverbotszone"."name" IS 'Informelle Bezeichnung der Festlegung.';
COMMENT ON COLUMN "SO_NachrichtlicheUebernahmen"."SO_Bauverbotszone"."nummer" IS 'Amtliche Bezeichnung / Kennziffer der Festlegung';
CREATE TRIGGER "change_to_SO_Bauverbotszone" BEFORE INSERT OR UPDATE ON "SO_NachrichtlicheUebernahmen"."SO_Bauverbotszone" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_SO_Bauverbotszone" AFTER DELETE ON "SO_NachrichtlicheUebernahmen"."SO_Bauverbotszone" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "SO_NachrichtlicheUebernahmen"."SO_BauverbotszoneFlaeche"
-- -----------------------------------------------------
CREATE TABLE  "SO_NachrichtlicheUebernahmen"."SO_BauverbotszoneFlaeche" (
  "gid" BIGINT NOT NULL,
  PRIMARY KEY ("gid"),
  CONSTRAINT "fk_SO_BauverbotszoneFlaeche_parent"
    FOREIGN KEY ("gid")
    REFERENCES "SO_NachrichtlicheUebernahmen"."SO_Bauverbotszone" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("SO_Basisobjekte"."SO_Flaechenobjekt");

GRANT SELECT ON TABLE "SO_NachrichtlicheUebernahmen"."SO_BauverbotszoneFlaeche" TO xp_gast;
GRANT ALL ON TABLE "SO_NachrichtlicheUebernahmen"."SO_BauverbotszoneFlaeche" TO so_user;
COMMENT ON COLUMN "SO_NachrichtlicheUebernahmen"."SO_BauverbotszoneFlaeche"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_SO_BauverbotszoneFlaeche" BEFORE INSERT OR UPDATE ON "SO_NachrichtlicheUebernahmen"."SO_BauverbotszoneFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_SO_BauverbotszoneFlaeche" AFTER DELETE ON "SO_NachrichtlicheUebernahmen"."SO_BauverbotszoneFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "SO_BauverbotszoneFlaeche_Flaechenobjekt" BEFORE INSERT OR UPDATE ON "SO_NachrichtlicheUebernahmen"."SO_BauverbotszoneFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isFlaechenobjekt"();

-- -----------------------------------------------------
-- Table "SO_NachrichtlicheUebernahmen"."SO_BauverbotszoneLinie"
-- -----------------------------------------------------
CREATE TABLE  "SO_NachrichtlicheUebernahmen"."SO_BauverbotszoneLinie" (
  "gid" BIGINT NOT NULL,
  PRIMARY KEY ("gid"),
  CONSTRAINT "fk_SO_BauverbotszoneLinie_parent"
    FOREIGN KEY ("gid")
    REFERENCES "SO_NachrichtlicheUebernahmen"."SO_Bauverbotszone" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("SO_Basisobjekte"."SO_Linienobjekt");

GRANT SELECT ON TABLE "SO_NachrichtlicheUebernahmen"."SO_BauverbotszoneLinie" TO xp_gast;
GRANT ALL ON TABLE "SO_NachrichtlicheUebernahmen"."SO_BauverbotszoneLinie" TO so_user;
COMMENT ON COLUMN "SO_NachrichtlicheUebernahmen"."SO_BauverbotszoneLinie"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_SO_BauverbotszoneLinie" BEFORE INSERT OR UPDATE ON "SO_NachrichtlicheUebernahmen"."SO_BauverbotszoneLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_SO_BauverbotszoneLinie" AFTER DELETE ON "SO_NachrichtlicheUebernahmen"."SO_BauverbotszoneLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "SO_NachrichtlicheUebernahmen"."SO_BauverbotszonePunkt"
-- -----------------------------------------------------
CREATE TABLE  "SO_NachrichtlicheUebernahmen"."SO_BauverbotszonePunkt" (
  "gid" BIGINT NOT NULL,
  PRIMARY KEY ("gid"),
  CONSTRAINT "fk_SO_BauverbotszonePunkt_parent"
    FOREIGN KEY ("gid")
    REFERENCES "SO_NachrichtlicheUebernahmen"."SO_Bauverbotszone" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("SO_Basisobjekte"."SO_Punktobjekt");

GRANT SELECT ON TABLE "SO_NachrichtlicheUebernahmen"."SO_BauverbotszonePunkt" TO xp_gast;
GRANT ALL ON TABLE "SO_NachrichtlicheUebernahmen"."SO_BauverbotszonePunkt" TO so_user;
COMMENT ON COLUMN "SO_NachrichtlicheUebernahmen"."SO_BauverbotszonePunkt"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_SO_BauverbotszonePunkt" BEFORE INSERT OR UPDATE ON "SO_NachrichtlicheUebernahmen"."SO_BauverbotszonePunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_SO_BauverbotszonePunkt" AFTER DELETE ON "SO_NachrichtlicheUebernahmen"."SO_BauverbotszonePunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Data for table "SO_NachrichtlicheUebernahmen"."SO_KlassifizBauverbot"
-- -----------------------------------------------------
INSERT INTO "SO_NachrichtlicheUebernahmen"."SO_KlassifizBauverbot" ("Code", "Bezeichner") VALUES ('1000', 'Bauverbotszone');
INSERT INTO "SO_NachrichtlicheUebernahmen"."SO_KlassifizBauverbot" ("Code", "Bezeichner") VALUES ('2000', 'Baubeschraenkungszone');
INSERT INTO "SO_NachrichtlicheUebernahmen"."SO_KlassifizBauverbot" ("Code", "Bezeichner") VALUES ('3000', 'Waldabstand');
INSERT INTO "SO_NachrichtlicheUebernahmen"."SO_KlassifizBauverbot" ("Code", "Bezeichner") VALUES ('9999', 'SonstigeBeschraenkung');

-- -----------------------------------------------------
-- Data for table "SO_NachrichtlicheUebernahmen"."SO_RechtlicheGrundlageBauverbot"
-- -----------------------------------------------------
INSERT INTO "SO_NachrichtlicheUebernahmen"."SO_RechtlicheGrundlageBauverbot" ("Code", "Bezeichner") VALUES ('1000', 'Luftverkehrsrecht');
INSERT INTO "SO_NachrichtlicheUebernahmen"."SO_RechtlicheGrundlageBauverbot" ("Code", "Bezeichner") VALUES ('2000', 'Strassenverkehrsrecht');
INSERT INTO "SO_NachrichtlicheUebernahmen"."SO_RechtlicheGrundlageBauverbot" ("Code", "Bezeichner") VALUES ('9999', 'SonstigesRecht');
-- Deprecated
UPDATE "SO_NachrichtlicheUebernahmen"."SO_KlassifizNachSonstigemRecht" SET "Bezeichner" = 'Bauschutzbereich - künftig wegfallend' WHERE "Code" = 1000;
UPDATE "SO_NachrichtlicheUebernahmen"."SO_KlassifizNachLuftverkehrsrecht" SET "Bezeichner" = 'Baubeschraenkungsbereich - künftig wegfallend' WHERE "Code" = 7000;

-- CR 027
UPDATE "RP_Freiraumstruktur"."RP_ErholungTypen" SET "Bezeichner" = 'LandschaftsbezogeneErholung' WHERE "Code"= 2001;

-- CR 028
INSERT INTO "SO_NachrichtlicheUebernahmen"."SO_KlassifizNachDenkmalschutzrecht" ("Code", "Bezeichner") VALUES (1300, 'PufferzoneWeltkulturerbeEnger');
INSERT INTO "SO_NachrichtlicheUebernahmen"."SO_KlassifizNachDenkmalschutzrecht" ("Code", "Bezeichner") VALUES (1400, 'PufferzoneWeltkulturerbeWeiter');
INSERT INTO "SO_NachrichtlicheUebernahmen"."SO_KlassifizNachDenkmalschutzrecht" ("Code", "Bezeichner") VALUES (1500, 'ArcheologischesDenkmal');
INSERT INTO "SO_NachrichtlicheUebernahmen"."SO_KlassifizNachDenkmalschutzrecht" ("Code", "Bezeichner") VALUES (1600, 'Bodendenkmal');

-- CR 030
UPDATE "XP_Enumerationen"."XP_Sondernutzungen" SET "Bezeichner" = 'SondergebietHochschuleForschung' WHERE "Code"= 2800;

-- CR 033
UPDATE "XP_Enumerationen"."XP_ZweckbestimmungVerEntsorgung" SET "Bezeichner" = 'Mobilfunkanlage' WHERE "Code"= 26001;

-- CR 034
-- XP
-- -----------------------------------------------------
-- Table "XP_Enumerationen"."XP_EigentumsartWald"
-- -----------------------------------------------------
CREATE  TABLE  "XP_Enumerationen"."XP_EigentumsartWald" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Code") );
GRANT SELECT ON TABLE "XP_Enumerationen"."XP_EigentumsartWald" TO xp_gast;
-- -----------------------------------------------------
-- Data for table "XP_Enumerationen"."XP_EigentumsartWald"
-- -----------------------------------------------------
INSERT INTO "XP_Enumerationen"."XP_EigentumsartWald" ("Code", "Bezeichner") VALUES ('1000', 'OeffentlicherWald');
INSERT INTO "XP_Enumerationen"."XP_EigentumsartWald" ("Code", "Bezeichner") VALUES ('1100', 'Staatswald');
INSERT INTO "XP_Enumerationen"."XP_EigentumsartWald" ("Code", "Bezeichner") VALUES ('1200', 'Koerperschaftswald');
INSERT INTO "XP_Enumerationen"."XP_EigentumsartWald" ("Code", "Bezeichner") VALUES ('12000', 'Kommunalwald');
INSERT INTO "XP_Enumerationen"."XP_EigentumsartWald" ("Code", "Bezeichner") VALUES ('12001', 'Stiftungswald');
INSERT INTO "XP_Enumerationen"."XP_EigentumsartWald" ("Code", "Bezeichner") VALUES ('2000', 'Privatwald');
INSERT INTO "XP_Enumerationen"."XP_EigentumsartWald" ("Code", "Bezeichner") VALUES ('20000', 'Gemeinschaftswald');
INSERT INTO "XP_Enumerationen"."XP_EigentumsartWald" ("Code", "Bezeichner") VALUES ('20001', 'Genossenschaftswald');
INSERT INTO "XP_Enumerationen"."XP_EigentumsartWald" ("Code", "Bezeichner") VALUES ('3000', 'Kirchenwald');
INSERT INTO "XP_Enumerationen"."XP_EigentumsartWald" ("Code", "Bezeichner") VALUES ('9999', 'Sonstiges');
-- -----------------------------------------------------
-- Table "XP_Enumerationen"."XP_WaldbetretungTyp"
-- -----------------------------------------------------
CREATE  TABLE  "XP_Enumerationen"."XP_WaldbetretungTyp" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Code") );
GRANT SELECT ON TABLE "XP_Enumerationen"."XP_WaldbetretungTyp" TO xp_gast;
-- -----------------------------------------------------
-- Data for table "XP_Enumerationen"."XP_WaldbetretungTyp"
-- -----------------------------------------------------
INSERT INTO "XP_Enumerationen"."XP_WaldbetretungTyp" ("Code", "Bezeichner") VALUES ('1000', 'Radfahren');
INSERT INTO "XP_Enumerationen"."XP_WaldbetretungTyp" ("Code", "Bezeichner") VALUES ('2000', 'Reiten');
INSERT INTO "XP_Enumerationen"."XP_WaldbetretungTyp" ("Code", "Bezeichner") VALUES ('3000', 'Fahren');
INSERT INTO "XP_Enumerationen"."XP_WaldbetretungTyp" ("Code", "Bezeichner") VALUES ('4000', 'Hundesport');
-- -----------------------------------------------------
-- Data for table "XP_Enumerationen"."XP_ZweckbestimmungWald"
-- -----------------------------------------------------
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungWald" ("Code", "Bezeichner") VALUES ('10000', 'Waldschutzgebiet');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungWald" ("Code", "Bezeichner") VALUES ('16000', 'Bodenschutzwald');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungWald" ("Code", "Bezeichner") VALUES ('16001', 'Biotopschutzwald');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungWald" ("Code", "Bezeichner") VALUES ('16002', 'NaturnaherWald');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungWald" ("Code", "Bezeichner") VALUES ('16003', 'SchutzwaldSchaedlicheUmwelteinwirkungen');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungWald" ("Code", "Bezeichner") VALUES ('16004', 'Schonwald');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungWald" ("Code", "Bezeichner") VALUES ('1700', 'Bannwald');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungWald" ("Code", "Bezeichner") VALUES ('1900', 'ImmissionsgeschaedigterWald');
-- BP
ALTER TABLE "BP_Landwirtschaft_Wald_und_Gruen"."BP_WaldFlaeche" ADD COLUMN "eigentumsart" INTEGER;
ALTER TABLE "BP_Landwirtschaft_Wald_und_Gruen"."BP_WaldFlaeche" ADD CONSTRAINT "fk_BP_WaldFlaeche_eigentumsart"
    FOREIGN KEY ("eigentumsart" )
    REFERENCES "XP_Enumerationen"."XP_EigentumsartWald" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE;
COMMENT ON COLUMN "BP_Landwirtschaft_Wald_und_Gruen"."BP_WaldFlaeche"."eigentumsart" IS 'Festlegung der Eigentumsart des Waldes';
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
-- FP
ALTER TABLE "FP_Landwirtschaft_Wald_und_Gruen"."FP_WaldFlaeche" ADD COLUMN "eigentumsart" INTEGER;
ALTER TABLE "FP_Landwirtschaft_Wald_und_Gruen"."FP_WaldFlaeche" ADD CONSTRAINT "fk_FP_WaldFlaeche_eigentumsart"
    FOREIGN KEY ("eigentumsart" )
    REFERENCES "XP_Enumerationen"."XP_EigentumsartWald" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE;
COMMENT ON COLUMN "FP_Landwirtschaft_Wald_und_Gruen"."FP_WaldFlaeche"."eigentumsart" IS 'Festlegung der Eigentumsart des Waldes';
-- -----------------------------------------------------
-- Table "FP_Landwirtschaft_Wald_und_Gruen"."FP_WaldFlaeche_betreten"
-- -----------------------------------------------------
CREATE TABLE "FP_Landwirtschaft_Wald_und_Gruen"."FP_WaldFlaeche_betreten" (
  "FP_WaldFlaeche_gid" BIGINT NOT NULL ,
  "betreten" INTEGER NOT NULL ,
  PRIMARY KEY ("FP_WaldFlaeche_gid", "betreten"),
  CONSTRAINT "fk_FP_WaldFlaeche_betreten1"
    FOREIGN KEY ("FP_WaldFlaeche_gid" )
    REFERENCES "FP_Landwirtschaft_Wald_und_Gruen"."FP_WaldFlaeche" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_WaldFlaeche_betreten2"
    FOREIGN KEY ("betreten" )
    REFERENCES "XP_Enumerationen"."XP_WaldbetretungTyp" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
GRANT SELECT ON TABLE "FP_Landwirtschaft_Wald_und_Gruen"."FP_WaldFlaeche_betreten" TO xp_gast;
GRANT ALL ON TABLE "FP_Landwirtschaft_Wald_und_Gruen"."FP_WaldFlaeche_betreten" TO fp_user;
COMMENT ON TABLE "FP_Landwirtschaft_Wald_und_Gruen"."FP_WaldFlaeche_betreten" IS 'Festlegung zusätzlicher, normalerweise nicht-gestatteter Aktivitäten, die in dem Wald ausgeführt werden dürfen, nach §14 Abs. 2 Bundeswaldgesetz.';
-- SO
-- -----------------------------------------------------
-- Table "SO_NachrichtlicheUebernahmen"."SO_Forstrecht_funktion"
-- -----------------------------------------------------
CREATE TABLE "SO_NachrichtlicheUebernahmen"."SO_Forstrecht_funktion" (
  "SO_Forstrecht_gid" BIGINT NOT NULL ,
  "funktion" INTEGER NOT NULL ,
  PRIMARY KEY ("SO_Forstrecht_gid", "funktion"),
  CONSTRAINT "fk_SO_Forstrecht_funktion1"
    FOREIGN KEY ("SO_Forstrecht_gid" )
    REFERENCES "SO_NachrichtlicheUebernahmen"."SO_Forstrecht" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_SO_Forstrecht_funktion2"
    FOREIGN KEY ("funktion" )
    REFERENCES "XP_Enumerationen"."XP_ZweckbestimmungWald" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
GRANT SELECT ON TABLE "SO_NachrichtlicheUebernahmen"."SO_Forstrecht_funktion" TO xp_gast;
GRANT ALL ON TABLE "SO_NachrichtlicheUebernahmen"."SO_Forstrecht_funktion" TO so_user;
COMMENT ON TABLE "SO_NachrichtlicheUebernahmen"."SO_Forstrecht_funktion" IS 'Klassifizierung der Funktion des Waldes';
-- -----------------------------------------------------
-- Table "SO_NachrichtlicheUebernahmen"."SO_Forstrecht_betreten"
-- -----------------------------------------------------
CREATE TABLE "SO_NachrichtlicheUebernahmen"."SO_Forstrecht_betreten" (
  "SO_Forstrecht_gid" BIGINT NOT NULL ,
  "betreten" INTEGER NOT NULL ,
  PRIMARY KEY ("SO_Forstrecht_gid", "betreten"),
  CONSTRAINT "fk_SO_Forstrecht_betreten1"
    FOREIGN KEY ("SO_Forstrecht_gid" )
    REFERENCES "SO_NachrichtlicheUebernahmen"."SO_Forstrecht" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_SO_Forstrecht_betreten2"
    FOREIGN KEY ("betreten" )
    REFERENCES "XP_Enumerationen"."XP_WaldbetretungTyp" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
GRANT SELECT ON TABLE "SO_NachrichtlicheUebernahmen"."SO_Forstrecht_betreten" TO xp_gast;
GRANT ALL ON TABLE "SO_NachrichtlicheUebernahmen"."SO_Forstrecht_betreten" TO so_user;
COMMENT ON TABLE "SO_NachrichtlicheUebernahmen"."SO_Forstrecht_betreten" IS 'Festlegung zusätzlicher, normalerweise nicht-gestatteter Aktivitäten, die in dem Wald ausgeführt werden dürfen, nach §14 Abs. 2 Bundeswaldgesetz.';
ALTER TABLE "SO_NachrichtlicheUebernahmen"."SO_Forstrecht" DROP CONSTRAINT "fk_SO_Forstrecht_artDerFestlegung";
ALTER TABLE "SO_NachrichtlicheUebernahmen"."SO_Forstrecht" ADD CONSTRAINT "fk_SO_Forstrecht_artDerFestlegung"
    FOREIGN KEY ("artDerFestlegung")
    REFERENCES "XP_Enumerationen"."XP_EigentumsartWald" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE;
COMMENT ON COLUMN "SO_NachrichtlicheUebernahmen"."SO_Forstrecht"."artDerFestlegung" IS 'Klassifizierung der Eigentumsart des Waldes.';
DROP TABLE "SO_NachrichtlicheUebernahmen"."SO_KlassifizNachForstrecht";

-- CR 035
INSERT INTO "FP_Verkehr"."FP_ZweckbestimmungStrassenverkehr" ("Code", "Bezeichner") VALUES ('1300', 'Ortsdurchfahrt');

-- CR 036
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungGewaesser" ("Code", "Bezeichner") VALUES ('10000', 'Sportboothafen');

-- CR 037, siehe CR 034 und CR 026

-- CR 040
COMMENT ON COLUMN "BP_Bebauung"."BP_BaugebietsTeilFlaeche"."sondernutzung" IS 'Differenziert Sondernutzungen nach §10 und §11 der BauNVO von 1977 und 1990. Das Attribut wird nur benutzt, wenn besondereArtDerBaulNutzung unbelegt ist oder einen der Werte 2000 bzw. 2100 hat.';

--CR 041
INSERT INTO "RP_Freiraumstruktur"."RP_NaturLandschaftTypen" ("Code", "Bezeichner") VALUES ('1705', 'Waldlebensraum');
INSERT INTO "RP_Freiraumstruktur"."RP_NaturLandschaftTypen" ("Code", "Bezeichner") VALUES ('1706', 'Feuchtlebensraum');
INSERT INTO "RP_Freiraumstruktur"."RP_NaturLandschaftTypen" ("Code", "Bezeichner") VALUES ('1707', 'Trockenlebensraum');
INSERT INTO "RP_Freiraumstruktur"."RP_NaturLandschaftTypen" ("Code", "Bezeichner") VALUES ('1708', 'LebensraumLaenderuebergreifendeVernetzung');

-- CR 042
COMMENT ON TABLE "BP_Wasser"."BP_GewaesserFlaeche" IS 'Festsetzung neuer Wasserflächen nach §9 Abs. 1 Nr. 16a BauGB.
Diese Klasse wird in der nächsten Hauptversion des Standards eventuell wegfallen und durch SO_Gewaesser ersetzt werden.';

-- CR 043
COMMENT ON TABLE "BP_Wasser"."BP_WasserwirtschaftsFlaeche" IS 'Flächen für die Wasserwirtschaft (§9 Abs. 1 Nr. 16a BauGB), sowie Flächen für Hochwasserschutz-anlagen und für die Regelung des Wasserabflusses (§9 Abs. 1 Nr. 16b BauGB).';

-- CR 044
COMMENT ON TABLE "FP_Wasser"."FP_Wasserwirtschaft" IS 'Die für die Wasserwirtschaft vorgesehenen Flächen sowie Flächen, die im Interesse des Hochwasserschutzes und der Regelung des Wasserabflusses freizuhalten sind (§5 Abs. 2 Nr. 7 BauGB).';

-- CR 045
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungWasserwirtschaft" ("Code", "Bezeichner") VALUES ('1500', 'RegenRueckhaltebecken');

-- CR 046
-- SO
COMMENT ON TABLE "SO_NachrichtlicheUebernahmen"."SO_Wasserrecht" IS 'Festlegung nach Wasserhaushaltsgesetz (WHG)';
INSERT INTO "SO_NachrichtlicheUebernahmen"."SO_KlassifizNachWasserrecht" ("Code", "Bezeichner") VALUES (3000, 'Risikogebiet');
INSERT INTO "SO_NachrichtlicheUebernahmen"."SO_KlassifizNachWasserrecht" ("Code", "Bezeichner") VALUES (4000, 'RisikogebietAusserhUeberschwemmgebiet');
INSERT INTO "SO_NachrichtlicheUebernahmen"."SO_KlassifizNachWasserrecht" ("Code", "Bezeichner") VALUES (5000, 'Hochwasserentstehungsgebiet');
-- -----------------------------------------------------
-- Table "SO_NachrichtlicheUebernahmen"."SO_KlassifizGewaesser"
-- -----------------------------------------------------
CREATE TABLE  "SO_NachrichtlicheUebernahmen"."SO_KlassifizGewaesser" (
  "Code" INTEGER NOT NULL,
  "Bezeichner" VARCHAR(64) NOT NULL,
  PRIMARY KEY ("Code"));
GRANT SELECT ON TABLE "SO_NachrichtlicheUebernahmen"."SO_KlassifizGewaesser" TO xp_gast;
GRANT ALL ON TABLE "SO_NachrichtlicheUebernahmen"."SO_KlassifizGewaesser" TO so_user;
-- -----------------------------------------------------
-- Table "SO_NachrichtlicheUebernahmen"."SO_DetailKlassifizGewaesser"
-- -----------------------------------------------------
CREATE TABLE  "SO_NachrichtlicheUebernahmen"."SO_DetailKlassifizGewaesser" (
  "Code" INTEGER NOT NULL,
  "Bezeichner" VARCHAR(64) NOT NULL,
  PRIMARY KEY ("Code"));

GRANT SELECT ON TABLE "SO_NachrichtlicheUebernahmen"."SO_DetailKlassifizGewaesser" TO xp_gast;
GRANT ALL ON TABLE "SO_NachrichtlicheUebernahmen"."SO_DetailKlassifizGewaesser" TO so_user;
-- -----------------------------------------------------
-- Table "SO_NachrichtlicheUebernahmen"."SO_Gewaesser"
-- -----------------------------------------------------
CREATE TABLE "SO_NachrichtlicheUebernahmen"."SO_Gewaesser" (
  "gid" BIGINT NOT NULL,
  "artDerFestlegung" INTEGER NULL,
  "detailArtDerFestlegung" INTEGER NULL,
  "name" VARCHAR(64) NULL,
  "nummer" VARCHAR(64) NULL,
  PRIMARY KEY ("gid"),
  CONSTRAINT "fk_SO_Gewaesser_parent"
    FOREIGN KEY ("gid")
    REFERENCES "SO_Basisobjekte"."SO_Objekt" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_SO_Gewaesser_artDerFestlegung"
    FOREIGN KEY ("artDerFestlegung")
    REFERENCES "SO_NachrichtlicheUebernahmen"."SO_KlassifizGewaesser" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_SO_Gewaesser_detailArtDerFestlegung"
    FOREIGN KEY ("detailArtDerFestlegung")
    REFERENCES "SO_NachrichtlicheUebernahmen"."SO_DetailKlassifizGewaesser" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE);

CREATE INDEX "fk_SO_Gewaesser_artDerFestlegung_idx" ON "SO_NachrichtlicheUebernahmen"."SO_Gewaesser" ("artDerFestlegung");
CREATE INDEX "fk_SO_Gewaesser_detailArtDerFestlegung_idx" ON "SO_NachrichtlicheUebernahmen"."SO_Gewaesser" ("detailArtDerFestlegung");
GRANT SELECT ON TABLE "SO_NachrichtlicheUebernahmen"."SO_Gewaesser" TO xp_gast;
GRANT ALL ON TABLE "SO_NachrichtlicheUebernahmen"."SO_Gewaesser" TO so_user;
COMMENT ON TABLE "SO_NachrichtlicheUebernahmen"."SO_Gewaesser" IS 'Abbildung eines bestehenden Gewässers';
COMMENT ON COLUMN "SO_NachrichtlicheUebernahmen"."SO_Gewaesser"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN "SO_NachrichtlicheUebernahmen"."SO_Gewaesser"."artDerFestlegung" IS 'Klassifizierung des Gewässers';
COMMENT ON COLUMN "SO_NachrichtlicheUebernahmen"."SO_Gewaesser"."detailArtDerFestlegung" IS 'Über eine Codeliste definierte detailliertere Klassifizierung des Gewässers';
COMMENT ON COLUMN "SO_NachrichtlicheUebernahmen"."SO_Gewaesser"."name" IS 'Informelle Bezeichnung des Gewässers';
COMMENT ON COLUMN "SO_NachrichtlicheUebernahmen"."SO_Gewaesser"."nummer" IS 'Amtliche Bezeichnung / Kennziffer des Gewässers';
CREATE TRIGGER "change_to_SO_Gewaesser" BEFORE INSERT OR UPDATE ON "SO_NachrichtlicheUebernahmen"."SO_Gewaesser" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_SO_Gewaesser" AFTER DELETE ON "SO_NachrichtlicheUebernahmen"."SO_Gewaesser" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
-- -----------------------------------------------------
-- Table "SO_NachrichtlicheUebernahmen"."SO_GewaesserPunkt"
-- -----------------------------------------------------
CREATE TABLE  "SO_NachrichtlicheUebernahmen"."SO_GewaesserPunkt" (
  "gid" BIGINT NOT NULL,
  PRIMARY KEY ("gid"),
  CONSTRAINT "fk_SO_GewaesserPunkt_parent"
    FOREIGN KEY ("gid")
    REFERENCES "SO_NachrichtlicheUebernahmen"."SO_Gewaesser" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("SO_Basisobjekte"."SO_Punktobjekt");

GRANT SELECT ON TABLE "SO_NachrichtlicheUebernahmen"."SO_GewaesserPunkt" TO xp_gast;
GRANT ALL ON TABLE "SO_NachrichtlicheUebernahmen"."SO_GewaesserPunkt" TO so_user;
COMMENT ON COLUMN "SO_NachrichtlicheUebernahmen"."SO_GewaesserPunkt"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_SO_GewaesserPunkt" BEFORE INSERT OR UPDATE ON "SO_NachrichtlicheUebernahmen"."SO_GewaesserPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_SO_GewaesserPunkt" AFTER DELETE ON "SO_NachrichtlicheUebernahmen"."SO_GewaesserPunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
-- -----------------------------------------------------
-- Table "SO_NachrichtlicheUebernahmen"."SO_GewaesserLinie"
-- -----------------------------------------------------
CREATE TABLE  "SO_NachrichtlicheUebernahmen"."SO_GewaesserLinie" (
  "gid" BIGINT NOT NULL,
  PRIMARY KEY ("gid"),
  CONSTRAINT "fk_SO_GewaesserLinie_parent"
    FOREIGN KEY ("gid")
    REFERENCES "SO_NachrichtlicheUebernahmen"."SO_Gewaesser" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("SO_Basisobjekte"."SO_Linienobjekt");

GRANT SELECT ON TABLE "SO_NachrichtlicheUebernahmen"."SO_GewaesserLinie" TO xp_gast;
GRANT ALL ON TABLE "SO_NachrichtlicheUebernahmen"."SO_GewaesserLinie" TO so_user;
COMMENT ON COLUMN "SO_NachrichtlicheUebernahmen"."SO_GewaesserLinie"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_SO_GewaesserLinie" BEFORE INSERT OR UPDATE ON "SO_NachrichtlicheUebernahmen"."SO_GewaesserLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_SO_GewaesserLinie" AFTER DELETE ON "SO_NachrichtlicheUebernahmen"."SO_GewaesserLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
-- -----------------------------------------------------
-- Table "SO_NachrichtlicheUebernahmen"."SO_GewaesserFlaeche"
-- -----------------------------------------------------
CREATE TABLE  "SO_NachrichtlicheUebernahmen"."SO_GewaesserFlaeche" (
  "gid" BIGINT NOT NULL,
  PRIMARY KEY ("gid"),
  CONSTRAINT "fk_SO_GewaesserFlaeche_parent"
    FOREIGN KEY ("gid")
    REFERENCES "SO_NachrichtlicheUebernahmen"."SO_Gewaesser" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("SO_Basisobjekte"."SO_Flaechenobjekt");

GRANT SELECT ON TABLE "SO_NachrichtlicheUebernahmen"."SO_GewaesserFlaeche" TO xp_gast;
GRANT ALL ON TABLE "SO_NachrichtlicheUebernahmen"."SO_GewaesserFlaeche" TO so_user;
COMMENT ON COLUMN "SO_NachrichtlicheUebernahmen"."SO_GewaesserFlaeche"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_SO_GewaesserFlaeche" BEFORE INSERT OR UPDATE ON "SO_NachrichtlicheUebernahmen"."SO_GewaesserFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_SO_GewaesserFlaeche" AFTER DELETE ON "SO_NachrichtlicheUebernahmen"."SO_GewaesserFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "SO_GewaesserFlaeche_Flaechenobjekt" BEFORE INSERT OR UPDATE ON "SO_NachrichtlicheUebernahmen"."SO_GewaesserFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isFlaechenobjekt"();
-- -----------------------------------------------------
-- Data for table "SO_NachrichtlicheUebernahmen"."SO_KlassifizGewaesser"
-- -----------------------------------------------------
INSERT INTO "SO_NachrichtlicheUebernahmen"."SO_KlassifizGewaesser" ("Code", "Bezeichner") VALUES (1000, 'Gewaesser');
INSERT INTO "SO_NachrichtlicheUebernahmen"."SO_KlassifizGewaesser" ("Code", "Bezeichner") VALUES (10000, 'Gewaesser1Ordnung');
INSERT INTO "SO_NachrichtlicheUebernahmen"."SO_KlassifizGewaesser" ("Code", "Bezeichner") VALUES (10001, 'Gewaesser2Ordnung');
INSERT INTO "SO_NachrichtlicheUebernahmen"."SO_KlassifizGewaesser" ("Code", "Bezeichner") VALUES (10002, 'Gewaesser3Ordnung');
INSERT INTO "SO_NachrichtlicheUebernahmen"."SO_KlassifizGewaesser" ("Code", "Bezeichner") VALUES (10003, 'StehendesGewaesser');
INSERT INTO "SO_NachrichtlicheUebernahmen"."SO_KlassifizGewaesser" ("Code", "Bezeichner") VALUES (2000, 'Hafen');
INSERT INTO "SO_NachrichtlicheUebernahmen"."SO_KlassifizGewaesser" ("Code", "Bezeichner") VALUES (9999, 'Sonstiges');
-- FP
COMMENT ON TABLE  "FP_Wasser"."FP_Gewaesser" IS 'Darstellung von Wasserflächen nach §5, Abs. 2, Nr. 7 BauGB.
Diese Klasse wird in der nächsten Hauptversion des Standards eventuell wegfallen und durch SO_Gewaesser ersetzt werden.';
-- BP siehe CR 042

-- CR 047
-- BP_Laerm-Schema anlegen
CREATE SCHEMA "BP_Laerm";
COMMENT ON SCHEMA "BP_Laerm" IS '';
GRANT USAGE ON SCHEMA "BP_Laerm" TO xp_gast;
-- Triggerfunktionen
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
-- Sequenzen
CREATE SEQUENCE "BP_Laerm"."BP_EmissionskontingentLaerm_id_seq"
   MINVALUE 1;
GRANT ALL ON TABLE "BP_Laerm"."BP_EmissionskontingentLaerm_id_seq" TO GROUP bp_user;
CREATE SEQUENCE "BP_Laerm"."BP_Richtungssektor_id_seq"
   MINVALUE 2; -- Wert eins wird durch den Defaulteintrag belegt
GRANT ALL ON TABLE "BP_Laerm"."BP_Richtungssektor_id_seq" TO GROUP bp_user;
-- Klassen
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
-- Table "BP_Laerm"."BP_ZusatzkontingentLaerm"
-- -----------------------------------------------------
CREATE TABLE "BP_Laerm"."BP_ZusatzkontingentLaerm" (
  "gid" BIGINT NOT NULL,
  "bezeichnung" CHARACTER VARYING(256),
  PRIMARY KEY ("gid"),
  CONSTRAINT "fk_BP_ZusatzkontingentLaerm_parent"
    FOREIGN KEY ("gid")
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
-- Defaultwert "BP_Laerm"."BP_Richtungssektor"
-- -----------------------------------------------------
INSERT INTO "BP_Laerm"."BP_Richtungssektor" ("id") VALUES (1);
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

-- BP_Objekt ergänzen
ALTER TABLE "BP_Basisobjekte"."BP_Objekt" ADD COLUMN "laermkontingent" INTEGER;
COMMENT ON COLUMN "BP_Basisobjekte"."BP_Objekt"."laermkontingent" IS 'Festsetzung eines Lärmemissionskontingent nach DIN 45691';
ALTER TABLE "BP_Basisobjekte"."BP_Objekt" ADD CONSTRAINT "fk_BP_Ojekt_laermkontingent"
    FOREIGN KEY ("laermkontingent")
    REFERENCES "BP_Laerm"."BP_EmissionskontingentLaerm" ("id")
    ON DELETE NO ACTION
    ON UPDATE CASCADE;
ALTER TABLE "BP_Basisobjekte"."BP_Objekt" ADD COLUMN "zusatzkontingent" BIGINT;
COMMENT ON COLUMN "BP_Basisobjekte"."BP_Objekt"."zusatzkontingent" IS 'Festsetzung von Zusatzkontingenten für die Lärmemission, die einzelnen Richtungssektoren zugeordnet sind. Die einzelnen Richtungssektoren werden parametrisch definiert.';
ALTER TABLE "BP_Basisobjekte"."BP_Objekt" ADD CONSTRAINT "fk_BP_Ojekt_zusatzkontingent"
    FOREIGN KEY ("zusatzkontingent")
    REFERENCES "BP_Laerm"."BP_ZusatzkontingentLaerm" ("gid")
    ON DELETE NO ACTION
    ON UPDATE CASCADE;
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

-- CR 049
COMMENT ON COLUMN "FP_Bebauung"."FP_BebauungsFlaeche"."sonderNutzung" IS 'Differenziert Sondernutzungen nach §10 und §11 der BauNVO von 1977 und 1990. Das Attribut wird nur benutzt, wenn besondereArtDerBaulNutzung unbelegt ist oder einen der Werte 2000 bzw. 2100 hat';

-- CR 050 Konformitätsbedingungen werden bisher nicht abgebildet
-- CR 051 nicht relevant
-- CR 052
INSERT INTO "BP_Bebauung"."BP_Dachform" ("Code", "Bezeichner") VALUES (4100, 'Tonnendach');

-- CR 054
UPDATE "BP_Verkehr"."BP_ZweckbestimmungStrassenverkehr" SET "Bezeichner" = 'RadGehweg' WHERE "Code" = 1300;
UPDATE "BP_Verkehr"."BP_ZweckbestimmungStrassenverkehr" SET "Bezeichner" = 'Gehweg' WHERE "Code" = 1500;
UPDATE "FP_Verkehr"."FP_ZweckbestimmungStrassenverkehr" SET "Bezeichner" = 'RadGehweg' WHERE "Code" = 14003;
UPDATE "FP_Verkehr"."FP_ZweckbestimmungStrassenverkehr" SET "Bezeichner" = 'Gehweg' WHERE "Code" = 14005;

-- CR 055
INSERT INTO "BP_Basisobjekte"."BP_PlanArt" ("Code", "Bezeichner") VALUES ('3100', 'VorhabenUndErschliessungsplan');
INSERT INTO "XP_Basisobjekte"."XP_ExterneReferenzTyp" ("Code", "Bezeichner") VALUES (2900, 'VorhabenUndErschliessungsplan');

-- CR 057
ALTER TABLE "RP_Basisobjekte"."RP_Punktobjekt" ADD COLUMN "nordwinkel" INTEGER;
COMMENT ON COLUMN "RP_Basisobjekte"."RP_Punktobjekt"."nordwinkel" IS 'Orientierung des Punktobjektes als Winkel gegen die Nordrichtung. Zählweise im geographischen Sinn (von Nord über Ost nach Süd und West).';

-- CR 058
COMMENT ON COLUMN "XP_Basisobjekte"."XP_ExterneReferenz"."referenzURL" IS 'URI des referierten Dokuments, bzw. Datenbank-Schlüssel. Wenn der XPlanGML Datensatz und das referierte Dokument in einem hierarchischen Ordnersystem gespeichert sind, kann die URI auch einen relativen Pfad vom XPlanGML-Datensatz zum Dokument enthalten.';

-- CR 060
INSERT INTO "XP_Enumerationen"."XP_Sondernutzungen" ("Code", "Bezeichner") VALUES ('2720', 'SondergebietJustiz');

-- CR 061
INSERT INTO "XP_Enumerationen"."XP_Sondernutzungen" ("Code", "Bezeichner") VALUES ('23000', 'Klinikgebiet');

-- CR 062
-- BP
DROP VIEW "BP_Bebauung"."BP_BaugebietsTeilFlaeche_qv";
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
INSERT INTO "BP_Bebauung"."BP_BaugebietsTeilFlaeche_sondernutzung" ("BP_BaugebietsTeilFlaeche_gid","sondernutzung") SELECT gid, "sondernutzung" FROM "BP_Bebauung"."BP_BaugebietsTeilFlaeche" WHERE "sondernutzung" IS NOT NULL;
ALTER TABLE "BP_Bebauung"."BP_BaugebietsTeilFlaeche" DROP COLUMN "sondernutzung";
CREATE OR REPLACE VIEW "BP_Bebauung"."BP_BaugebietsTeilFlaeche_qv" AS
SELECT g.gid,g.position,so1 as sondernutzung1,so2 as sondernutzung2,so3 as sondernutzung3,so4 as sondernutzung4
  FROM
 "BP_Bebauung"."BP_BaugebietsTeilFlaeche" g
 LEFT JOIN
 crosstab('SELECT "BP_BaugebietsTeilFlaeche_gid", "BP_BaugebietsTeilFlaeche_gid", sondernutzung FROM "BP_Bebauung"."BP_BaugebietsTeilFlaeche_sondernutzung" ORDER BY 1,3') sot
 (sogid bigint, so1 integer,so2 integer,so3 integer,so4 integer)
 ON g.gid=sot.sogid;
GRANT SELECT ON TABLE "BP_Bebauung"."BP_BaugebietsTeilFlaeche_qv" TO xp_gast;
-- FP
-- -----------------------------------------------------
-- Table "FP_Bebauung"."FP_BebauungsFlaeche_sondernutzung"
-- -----------------------------------------------------
CREATE TABLE "FP_Bebauung"."FP_BebauungsFlaeche_sondernutzung" (
  "FP_BebauungsFlaeche_gid" BIGINT NOT NULL ,
  "sondernutzung" INTEGER NULL ,
  PRIMARY KEY ("FP_BebauungsFlaeche_gid", "sondernutzung"),
  CONSTRAINT "fk_FP_BebauungsFlaeche_sondernutzung1"
    FOREIGN KEY ("FP_BebauungsFlaeche_gid" )
    REFERENCES "FP_Bebauung"."FP_BebauungsFlaeche" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_BebauungsFlaeche_sondernutzung2"
    FOREIGN KEY ("sondernutzung" )
    REFERENCES "XP_Enumerationen"."XP_Sondernutzungen" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
GRANT SELECT ON TABLE "FP_Bebauung"."FP_BebauungsFlaeche_sondernutzung" TO xp_gast;
GRANT ALL ON TABLE "FP_Bebauung"."FP_BebauungsFlaeche_sondernutzung" TO fp_user;
COMMENT ON TABLE "FP_Bebauung"."FP_BebauungsFlaeche_sondernutzung" IS 'Differenziert Sondernutzungen nach §10 und §11 der BauNVO von 1977 und 1990. Das Attribut wird nur benutzt, wenn besondereArtDerBaulNutzung unbelegt ist oder einen der Werte 2000 bzw. 2100 hat';
INSERT INTO "FP_Bebauung"."FP_BebauungsFlaeche_sondernutzung" ("FP_BebauungsFlaeche_gid","sondernutzung") SELECT gid, "sonderNutzung" FROM "FP_Bebauung"."FP_BebauungsFlaeche" WHERE "sonderNutzung" IS NOT NULL;
ALTER TABLE "FP_Bebauung"."FP_BebauungsFlaeche" DROP COLUMN "sonderNutzung";

-- CR 065
ALTER TABLE "BP_Sonstiges"."BP_AbstandsMass" ALTER COLUMN "wert" DROP NOT NULL;
-- -----------------------------------------------------
-- Table "BP_Sonstiges"."BP_AbstandsMassTypen"
-- -----------------------------------------------------
CREATE  TABLE  "BP_Sonstiges"."BP_AbstandsMassTypen" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Code") );
GRANT SELECT ON "BP_Sonstiges"."BP_AbstandsMassTypen" TO xp_gast;
-- -----------------------------------------------------
-- Data for table "BP_Sonstiges"."BP_AbstandsMassTypen"
-- -----------------------------------------------------
INSERT INTO "BP_Sonstiges"."BP_AbstandsMassTypen" ("Code", "Bezeichner") VALUES ('1000', 'Masspfeil');
INSERT INTO "BP_Sonstiges"."BP_AbstandsMassTypen" ("Code", "Bezeichner") VALUES ('2000', 'Masskreis');
ALTER TABLE "BP_Sonstiges"."BP_AbstandsMass" ADD COLUMN "typ" INTEGER;
ALTER TABLE "BP_Sonstiges"."BP_AbstandsMass" ADD CONSTRAINT "fk_BP_AbstandsMass_typ"
    FOREIGN KEY ("typ" )
    REFERENCES "BP_Sonstiges"."BP_AbstandsMassTypen" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE;
COMMENT ON COLUMN "BP_Sonstiges"."BP_AbstandsMass"."typ" IS 'Typ der Massangabe (Maßpfeil oder Maßkreis).';
COMMENT ON TABLE  "BP_Sonstiges"."BP_AbstandsMass" IS 'Darstellung von Maßpfeilen oder Maßkreisen in BPlänen, um eine eindeutige Vermassung einzelner Festsetzungen zu erreichen.
Bei Masspfeilen (typ == 1000) sollte das Geometrie-Attribut position nur eine einfache Linie (gml:LineString mit 2 Punkten) enthalten
Bei Maßkreisen (typ == 2000) sollte position nur einen einfachen Kreisbogen (gml:Curve mit genau einem gml:Arc enthalten).
In der nächsten Hauptversion von XPlanGML werden diese Empfehlungen zu verpflichtenden Konformitätsbedingungen.';
COMMENT ON COLUMN "BP_Sonstiges"."BP_AbstandsMass"."startWinkel" IS 'Startwinkel für die Plandarstellung des Abstandsmaßes (nur relevant für Maßkreise). Die Winkelwerte beziehen sich auf den Rechtswert (Ost-Richtung)';
COMMENT ON COLUMN "BP_Sonstiges"."BP_AbstandsMass"."endWinkel" IS 'Endwinkel für die Planarstellung des Abstandsmaßes (nur relevant für Maßkreise). Die Winkelwerte beziehen sich auf den Rechtswert (Ost-Richtung)';

-- CR 066
INSERT INTO "RP_Infrastruktur"."RP_WasserwirtschaftTypen" ("Code", "Bezeichner") VALUES ('8000', 'Zuwaesserungskanal');
INSERT INTO "RP_Infrastruktur"."RP_WasserwirtschaftTypen" ("Code", "Bezeichner") VALUES ('8100', 'Entwaesserungskanal');
