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

--CR-012
COMMENT ON TABLE "XP_Basisobjekte"."XP_Plan_begruendungsTexte" IS 'Referenz auf einen Abschnitt der Begründung. Diese Relation darf nicht verwendet werden, wenn die Begründung als Gesamt-Dokument referiert werden soll. In diesem Fall sollte über das Attribut externeReferenz eine Objekt XP_SpezExterneReferent mit typ=1010 (Begruendung) verwendet werden.';
/* optionale Prüfung, ob beides belegt ist:
SELECT * FROM "XP_Basisobjekte"."XP_Plan_externeReferenz" er
JOIN "XP_Basisobjekte"."XP_Plan_begruendungsTexte" bt ON er."XP_Plan_gid" = bt."XP_Plan_gid";
*/

--CR-013
COMMENT ON TABLE "XP_Basisobjekte"."XP_ExterneReferenz" IS 'Verweis auf ein extern gespeichertes Dokument oder einen extern gespeicherten, georeferenzierten Plan. Einer der beiden Attribute "referenzName" bzw. "referenzURL" muss belegt sein.';
COMMENT ON COLUMN "XP_Basisobjekte"."XP_ExterneReferenz"."georefMimeType" IS 'Mime-Type der Georeferenzierungs-Datei. Das Arrtibut ist nur relevant bei Verweisen auf georeferenzierte Rasterbilder.
Das Attribut ist als "veraltet" gekennzeichnet und wird in Version 6.0 evtl. wegfallen.';
COMMENT ON COLUMN "XP_Basisobjekte"."XP_ExterneReferenz"."informationssystemURL" IS 'URI des des zugehörigen Informationssystems
Dies Attribut ist als "veraltet" gekennzeichnet und wird in Version 6.0 evtl. wegfallen.';
INSERT INTO "XP_Basisobjekte"."XP_MimeTypes" ("Code", "Bezeichner") VALUES ('application/vnd.shp', 'application/vnd.shp');
INSERT INTO "XP_Basisobjekte"."XP_MimeTypes" ("Code", "Bezeichner") VALUES ('application/vnd.dbf', 'application/vnd.dbf');
INSERT INTO "XP_Basisobjekte"."XP_MimeTypes" ("Code", "Bezeichner") VALUES ('application/vnd.shx', 'application/vnd.shx');
INSERT INTO "XP_Basisobjekte"."XP_MimeTypes" ("Code", "Bezeichner") VALUES ('application/octet-stream', 'application/octet-stream');
INSERT INTO "XP_Basisobjekte"."XP_MimeTypes" ("Code", "Bezeichner") VALUES ('image/vnd.dxf ', 'image/vnd.dxf ');
INSERT INTO "XP_Basisobjekte"."XP_MimeTypes" ("Code", "Bezeichner") VALUES ('image/vnd.dwg', 'image/vnd.dwg');
INSERT INTO "XP_Basisobjekte"."XP_MimeTypes" ("Code", "Bezeichner") VALUES ('image/bmp', 'image/bmp');
-- DELETE FROM "XP_Basisobjekte"."XP_MimeTypes" WHERE "Code" = 'application/odt'; 
-- Dieser MimeType ist in der CodeList nicht mehr definiert. Um kongruent mit dem Standard zu sein, kann er entfernt werden. Da es sich um eine CodeList handelt, ist das jedoch nicht zwingend erforderlich, insbesondere, wenn dieser MimeType bereits verknüpft wurde.

--CR-014: nichts zu ändern
--CR-015: nichts zu ändern

--CR-016:
INSERT INTO "XP_Sonstiges"."XP_ArtHoehenbezug" ("Code", "Bezeichner") VALUES ('3500', 'relativStrasse');
INSERT INTO "XP_Sonstiges"."XP_ArtHoehenbezugspunkt" ("Code", "Bezeichner") VALUES ('6600', 'GOK');

--CR-017: nichts zu ändern
--CR-018: nichts zu ändern
--CR-019: nichts zu ändern

--CR-020:
-- -----------------------------------------------------
-- Table "BP_Sonstiges"."BP_FlaecheOhneFestsetzung"
-- -----------------------------------------------------
CREATE TABLE "BP_Sonstiges"."BP_FlaecheOhneFestsetzung" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_BP_FlaecheOhneFestsetzung_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "BP_Basisobjekte"."BP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("BP_Basisobjekte"."BP_Flaechenobjekt");

GRANT SELECT ON TABLE "BP_Sonstiges"."BP_FlaecheOhneFestsetzung" TO xp_gast;
GRANT ALL ON TABLE "BP_Sonstiges"."BP_FlaecheOhneFestsetzung" TO bp_user;
CREATE INDEX "BP_FlaecheOhneFestsetzung_gidx" ON "BP_Sonstiges"."BP_FlaecheOhneFestsetzung" using gist ("position");
CREATE TRIGGER "change_to_BP_FlaecheOhneFestsetzung" BEFORE INSERT OR UPDATE ON "BP_Sonstiges"."BP_FlaecheOhneFestsetzung" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_BP_FlaecheOhneFestsetzung" AFTER DELETE ON "BP_Sonstiges"."BP_FlaecheOhneFestsetzung" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "flaechenschluss_BP_FlaecheOhneFestsetzung" BEFORE INSERT OR UPDATE ON "BP_Sonstiges"."BP_FlaecheOhneFestsetzung" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isFlaechenschlussobjekt"();
COMMENT ON TABLE "BP_Sonstiges"."BP_FlaecheOhneFestsetzung" IS 'Fläche, für die keine geplante Nutzung angegeben werden kann';

-- -----------------------------------------------------
-- Table "FP_Sonstiges"."FP_FlaecheOhneDarstellung"
-- -----------------------------------------------------
CREATE TABLE "FP_Sonstiges"."FP_FlaecheOhneDarstellung" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_FlaecheOhneDarstellung_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Basisobjekte"."FP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("FP_Basisobjekte"."FP_Flaechenobjekt");

GRANT SELECT ON TABLE "FP_Sonstiges"."FP_FlaecheOhneDarstellung" TO xp_gast;
GRANT ALL ON TABLE "FP_Sonstiges"."FP_FlaecheOhneDarstellung" TO fp_user;
CREATE INDEX "FP_FlaecheOhneDarstellung_gidx" ON "FP_Sonstiges"."FP_FlaecheOhneDarstellung" using gist ("position");
CREATE TRIGGER "change_to_FP_FlaecheOhneDarstellung" BEFORE INSERT OR UPDATE ON "FP_Sonstiges"."FP_FlaecheOhneDarstellung" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_FP_FlaecheOhneDarstellung" AFTER DELETE ON "FP_Sonstiges"."FP_FlaecheOhneDarstellung" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "flaechenschluss_FP_FlaecheOhneDarstellung" BEFORE INSERT OR UPDATE ON "FP_Sonstiges"."FP_FlaecheOhneDarstellung" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isFlaechenschlussobjekt"();
COMMENT ON TABLE "FP_Sonstiges"."FP_FlaecheOhneDarstellung" IS 'Fläche, für die keine geplante Nutzung angegeben werden kann';

--CR-021:
-- -----------------------------------------------------
-- Table "BP_Ver_und_Entsorgung"."BP_ZentralerVersorgungsbereich"
-- -----------------------------------------------------
CREATE TABLE "BP_Ver_und_Entsorgung"."BP_ZentralerVersorgungsbereich" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_BP_ZentralerVersorgungsbereich_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "BP_Basisobjekte"."BP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS ("BP_Basisobjekte"."BP_Flaechenobjekt");

GRANT SELECT ON TABLE "BP_Ver_und_Entsorgung"."BP_ZentralerVersorgungsbereich" TO xp_gast;
GRANT ALL ON TABLE "BP_Ver_und_Entsorgung"."BP_ZentralerVersorgungsbereich" TO bp_user;
CREATE INDEX "BP_ZentralerVersorgungsbereich_gidx" ON "BP_Ver_und_Entsorgung"."BP_ZentralerVersorgungsbereich" using gist ("position");
CREATE TRIGGER "change_to_BP_ZentralerVersorgungsbereich" BEFORE INSERT OR UPDATE ON "BP_Ver_und_Entsorgung"."BP_ZentralerVersorgungsbereich" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_BP_ZentralerVersorgungsbereich" AFTER DELETE ON "BP_Ver_und_Entsorgung"."BP_ZentralerVersorgungsbereich" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "BP_ZentralerVersorgungsbereich_Flaechenobjekt" BEFORE INSERT OR UPDATE ON "BP_Ver_und_Entsorgung"."BP_ZentralerVersorgungsbereich" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isFlaechenobjekt"();
COMMENT ON TABLE "BP_Ver_und_Entsorgung"."BP_ZentralerVersorgungsbereich" IS 'Zentraler Versorgungsbereich gem. § 9 Abs. 2a BauGB';

--CR-022: nichts zu ändern
--CR-023: nichts zu ändern

--CR-024
COMMENT ON COLUMN "BP_Basisobjekte"."BP_Plan"."versionBauNVODatum" IS 'Bekanntmachungs-Datum der zugrunde liegenden Version der BauNVO';
COMMENT ON COLUMN "BP_Basisobjekte"."BP_Plan"."versionBauGBDatum" IS 'Bekanntmachungs-Datum der zugrunde liegenden Version des BauGB.';
COMMENT ON COLUMN "BP_Basisobjekte"."BP_Plan"."versionSonstRechtsgrundlageDatum" IS 'Bekanntmachungs-Datum einer zugrunde liegenden anderen Rechtsgrundlage als BauGB / BauNVO.';
COMMENT ON COLUMN "FP_Basisobjekte"."FP_Plan"."versionBauNVODatum" IS 'Bekanntmachungs-Datum der zugrunde liegenden Version der BauNVO.';
COMMENT ON COLUMN "FP_Basisobjekte"."FP_Plan"."versionBauGBDatum" IS 'DBekanntmachungs-Datum der zugrunde liegenden Version des BauGB.';
COMMENT ON COLUMN "FP_Basisobjekte"."FP_Plan"."versionSonstRechtsgrundlageDatum" IS 'Bekanntmachungs-Datum einer zugrunde liegenden anderen Rechtsgrundlage als BauGB / BauNVO.';
COMMENT ON COLUMN "SO_Basisobjekte"."SO_Plan"."versionBauGBDatum" IS 'Bekanntmachungs-Datum der zugrunde liegenden Version des BauGB.';
COMMENT ON COLUMN "SO_Basisobjekte"."SO_Plan"."versionSonstRechtsgrundlageDatum" IS 'Bekanntmachungs-Datum einer zugrunde liegenden anderen Rechtsgrundlage als das BauGB.';
COMMENT ON COLUMN "RP_Basisobjekte"."RP_Bereich"."versionBROG" IS 'Bekanntmachungs-Datum der zugrunde liegenden Version des ROG.';
COMMENT ON COLUMN "RP_Basisobjekte"."RP_Bereich"."versionLPLG" IS 'Bekanntmachungs-Datum des zugrunde liegenden Landesplanungsgesetzes.';

--CR-025: nichts zu ändern

--CR-026 und CR-027
COMMENT ON COLUMN "XP_Praesentationsobjekte"."XP_APObjekt_dientZurDarstellungVon"."art" IS '"art" gibt die Namen der Attribute an, die mit dem Präsentationsobjekt dargestellt werden sollen. Dabei ist beim Verweis auf komplexe Attribute des Fachobjekts die Xpath-Syntax zu verwenden. Wenn das zugehörige Attribut oder Sub-Attribut des Fachobjekts mehrfach belegt ist, sollte die []-Syntax zur Spezifikation des zugehörigen Instanz-Attributs benutzt werden. 
Die Attributart "art" darf im Regelfall nur bei "Freien Präsentationsobjekten" (dientZurDarstellungVon = NULL) nicht belegt sein.';
COMMENT ON COLUMN "XP_Praesentationsobjekte"."XP_APObjekt_dientZurDarstellungVon"."index" IS 'Wenn das Attribut, das vom Inhalt des Attributs "art“ bezeichnet wird, im Fachobjekt mehrfach belegt ist gibt "index" an, auf welche Instanz des Attributs sich das Präsentationsobjekt bezieht. Indexnummern beginnen dabei immer mit 0.
Dies Attribut ist als "veraltet" gekennzeichnet und wird in Version 6.0 voraussichtlich wegfallen. Alternativ sollte im Attribut "art" die XPath-Syntax benutzt werden.';

-- CR-028
-- -----------------------------------------------------
-- Table "BP_Sonstiges"."BP_SichtflaecheKnotenpunktTypen"
-- -----------------------------------------------------
CREATE TABLE "BP_Sonstiges"."BP_SichtflaecheKnotenpunktTypen" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Code") );
GRANT SELECT ON "BP_Sonstiges"."BP_SichtflaecheKnotenpunktTypen" TO xp_gast;

ALTER TABLE "BP_Sonstiges"."BP_Sichtflaeche" ADD COLUMN "knotenpunkt" INTEGER;
ALTER TABLE "BP_Sonstiges"."BP_Sichtflaeche" ADD COLUMN "geschwindigkeit" INTEGER;
ALTER TABLE "BP_Sonstiges"."BP_Sichtflaeche" ADD COLUMN "schenkellaenge" REAL;
ALTER TABLE "BP_Sonstiges"."BP_Sichtflaeche" ADD CONSTRAINT "fk_BP_Sichtflaeche_Knotenpunkt"
    FOREIGN KEY ("knotenpunkt" )
    REFERENCES "BP_Sonstiges"."BP_SichtflaecheKnotenpunktTypen" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE;
COMMENT ON COLUMN "BP_Sonstiges"."BP_Sichtflaeche"."knotenpunkt" IS 'Klassifikation des Knotenpunktes, dem die Sichtfläche zugeordnet ist';
COMMENT ON COLUMN "BP_Sonstiges"."BP_Sichtflaeche"."geschwindigkeit" IS 'Zulässige Geschwindigkeit in der übergeordneten Straße, im km/h';
COMMENT ON COLUMN "BP_Sonstiges"."BP_Sichtflaeche"."schenkellaenge" IS 'Schenkellänge des Sichtdreiecks gemäß RAST 06';

-- -----------------------------------------------------
-- Data for table "BP_Sonstiges"."BP_SichtflaecheKnotenpunktTypen"
-- -----------------------------------------------------
INSERT INTO "BP_Sonstiges"."BP_SichtflaecheKnotenpunktTypen" ("Code", "Bezeichner") VALUES (1000, 'AnlgStr-AnlgWeg');
INSERT INTO "BP_Sonstiges"."BP_SichtflaecheKnotenpunktTypen" ("Code", "Bezeichner") VALUES (2000, 'AnlgStr-AnlgStr');
INSERT INTO "BP_Sonstiges"."BP_SichtflaecheKnotenpunktTypen" ("Code", "Bezeichner") VALUES (3000, 'SammelStr-AnlgStr');
INSERT INTO "BP_Sonstiges"."BP_SichtflaecheKnotenpunktTypen" ("Code", "Bezeichner") VALUES (4000, 'HauptSammelStr');
INSERT INTO "BP_Sonstiges"."BP_SichtflaecheKnotenpunktTypen" ("Code", "Bezeichner") VALUES (5000, 'HauptVerkStrAngeb');
INSERT INTO "BP_Sonstiges"."BP_SichtflaecheKnotenpunktTypen" ("Code", "Bezeichner") VALUES (6000, 'HauptVerkStrNichtAngeb');
INSERT INTO "BP_Sonstiges"."BP_SichtflaecheKnotenpunktTypen" ("Code", "Bezeichner") VALUES (9999, 'SonstigerKnotenpunkt');
