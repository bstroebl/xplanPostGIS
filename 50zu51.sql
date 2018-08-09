-- Dieses SQL ausführen, um aus einer XPlanungsdatenbank Version 5.0.1 eine der Version 5.1 zu machen
-- CR 004
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
ALTER TABLE "BP_Basisobjekte"."BP_Plan" ADD COLUMN "versionBauNVODatum" DATE;
ALTER TABLE "BP_Basisobjekte"."BP_Plan" ADD COLUMN "versionBauNVOText" VARCHAR(255);
ALTER TABLE "BP_Basisobjekte"."BP_Plan" ADD COLUMN "versionBauGBDatum" DATE;
ALTER TABLE "BP_Basisobjekte"."BP_Plan" ADD COLUMN "versionBauGBText" VARCHAR(255);
ALTER TABLE "BP_Basisobjekte"."BP_Plan" ADD COLUMN "versionSonstRechtsgrundlageDatum" DATE;
ALTER TABLE "BP_Basisobjekte"."BP_Plan" ADD COLUMN "versionSonstRechtsgrundlageText" VARCHAR(255);
COMMENT ON COLUMN "BP_Basisobjekte"."BP_Plan"."versionBauNVODatum" IS 'Datum der zugrundeliegenden Version der BauNVO.';
COMMENT ON COLUMN "BP_Basisobjekte"."BP_Plan"."versionBauNVOText" IS 'Zugrundeliegende Version der BauNVO.';
COMMENT ON COLUMN "BP_Basisobjekte"."BP_Plan"."versionBauGBDatum" IS 'Datum der zugrunde liegenden Version des BauGB.';
COMMENT ON COLUMN "BP_Basisobjekte"."BP_Plan"."versionBauGBText" IS 'Zugrunde liegende Version des BauGB.';
COMMENT ON COLUMN "BP_Basisobjekte"."BP_Plan"."versionSonstRechtsgrundlageDatum" IS 'Datum einer zugrunde liegenden anderen Rechtsgrundlage als BauGB / BauNVO.';
COMMENT ON COLUMN "BP_Basisobjekte"."BP_Plan"."versionSonstRechtsgrundlageText" IS 'Textliche Spezifikation einer zugrunde liegenden anderen Rechtsgrundlage als BauGB / BauNVO.';

-- CR 005
COMMENT ON COLUMN "FP_Basisobjekte"."FP_Bereich"."versionBauNVODatum" IS 'Datum der zugrundeliegenden Version der BauNVO.
Das Attribut ist veraltet und wird in XPlanGML 6.0 wegfallen. Es sollte stattdessen das gleichnamige Attribut von FP_Plan verwendet werden.';
COMMENT ON COLUMN "FP_Basisobjekte"."FP_Bereich"."versionBauNVOText" IS 'Zugrundeliegende Version der BauNVO.
Das Attribut ist veraltet und wird in XPlanGML 6.0 wegfallen. Es sollte stattdessen das gleichnamige Attribut von FP_Plan verwendet werden.';
COMMENT ON COLUMN "FP_Basisobjekte"."FP_Bereich"."versionBauGBDatum" IS 'Datum der zugrunde liegenden Version des BauGB.
Das Attribut ist veraltet und wird in XPlanGML 6.0 wegfallen. Es sollte stattdessen das gleichnamige Attribut von FP_Plan verwendet werden.';
COMMENT ON COLUMN "FP_Basisobjekte"."FP_Bereich"."versionBauGBText" IS 'Zugrunde liegende Version des BauGB.
Das Attribut ist veraltet und wird in XPlanGML 6.0 wegfallen. Es sollte stattdessen das gleichnamige Attribut von FP_Plan verwendet werden.';
COMMENT ON COLUMN "FP_Basisobjekte"."FP_Bereich"."versionSonstRechtsgrundlageDatum" IS 'Datum einer zugrunde liegenden anderen Rechtsgrundlage als BauGB / BauNVO.
Das Attribut ist veraltet und wird in XPlanGML 6.0 wegfallen. Es sollte stattdessen das gleichnamige Attribut von FP_Plan verwendet werden.';
COMMENT ON COLUMN "FP_Basisobjekte"."FP_Bereich"."versionSonstRechtsgrundlageText" IS 'Textliche Spezifikation einer zugrunde liegenden anderen Rechtsgrundlage als BauGB / BauNVO.
Das Attribut ist veraltet und wird in XPlanGML 6.0 wegfallen. Es sollte stattdessen das gleichnamige Attribut von FP_Plan verwendet werden.';
ALTER TABLE "FP_Basisobjekte"."FP_Plan" ADD COLUMN "versionBauNVODatum" DATE;
ALTER TABLE "FP_Basisobjekte"."FP_Plan" ADD COLUMN "versionBauNVOText" VARCHAR(255);
ALTER TABLE "FP_Basisobjekte"."FP_Plan" ADD COLUMN "versionBauGBDatum" DATE;
ALTER TABLE "FP_Basisobjekte"."FP_Plan" ADD COLUMN "versionBauGBText" VARCHAR(255);
ALTER TABLE "FP_Basisobjekte"."FP_Plan" ADD COLUMN "versionSonstRechtsgrundlageDatum" DATE;
ALTER TABLE "FP_Basisobjekte"."FP_Plan" ADD COLUMN "versionSonstRechtsgrundlageText" VARCHAR(255);
COMMENT ON COLUMN "FP_Basisobjekte"."FP_Plan"."versionBauNVODatum" IS 'Datum der zugrundeliegenden Version der BauNVO.';
COMMENT ON COLUMN "FP_Basisobjekte"."FP_Plan"."versionBauNVOText" IS 'Zugrundeliegende Version der BauNVO.';
COMMENT ON COLUMN "FP_Basisobjekte"."FP_Plan"."versionBauGBDatum" IS 'Datum der zugrunde liegenden Version des BauGB.';
COMMENT ON COLUMN "FP_Basisobjekte"."FP_Plan"."versionBauGBText" IS 'Zugrunde liegende Version des BauGB.';
COMMENT ON COLUMN "FP_Basisobjekte"."FP_Plan"."versionSonstRechtsgrundlageDatum" IS 'Datum einer zugrunde liegenden anderen Rechtsgrundlage als BauGB / BauNVO.';
COMMENT ON COLUMN "FP_Basisobjekte"."FP_Plan"."versionSonstRechtsgrundlageText" IS 'Textliche Spezifikation einer zugrunde liegenden anderen Rechtsgrundlage als BauGB / BauNVO.';

-- CR 006
COMMENT ON COLUMN "XP_Basisobjekte"."XP_Bereich"."rasterBasis" IS 'Ein Plan kann optional eine georeferenzierte Rasterkarte referieren.
Diese Relation ist veraltet und wird in XPlanGML 6.0 wegfallen. XP_Rasterdarstellung sollte folgendermaßen abgebildet werden:
XP_Rasterdarstellung.refScan --> XP_Bereich.refScan
XP_Rasterdarstellung.refText --> XP_Plan.texte
XP_Rasterdarstellung.refLegende --> XP_Plan.externeReferenz';
COMMENT ON TABLE "XP_Raster"."XP_Rasterdarstellung" IS 'Georeferenzierte Rasterdarstellung eines Plans. Das über refScan referierte Rasterbild zeigt den Basisplan, dessen Geltungsbereich durch den Geltungsbereich des Gesamtplans (Attribut geltungsbereich von XP_Bereich) repräsentiert ist.
Im Standard sind nur georeferenzierte Rasterpläne zugelassen. Die über refScan referierte externe Referenz muss deshalb entweder vom Typ "PlanMitGeoreferenz" sein oder einen WMS-Request enthalten.
Die Klasse ist veraltet und wird in XPlanGML V. 6.0 eliminiert.';
CREATE TABLE "XP_Basisobjekte"."XP_Bereich_refScan" (
  "XP_Bereich_gid" BIGINT NOT NULL ,
  "externeReferenz" INTEGER NOT NULL ,
  PRIMARY KEY ("XP_Bereich_gid", "externeReferenz") ,
  CONSTRAINT "fk_XP_Bereich_refScan_XP_Bereich"
    FOREIGN KEY ("XP_Bereich_gid" )
    REFERENCES "XP_Basisobjekte"."XP_Bereich" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_XP_Bereich_refScan_XP_ExterneReferenz"
    FOREIGN KEY ("externeReferenz" )
    REFERENCES "XP_Basisobjekte"."XP_SpezExterneReferenz" ("id" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
COMMENT ON TABLE "XP_Basisobjekte"."XP_Bereich_refScan" IS 'Referenz auf einen georeferenzierten Rasterplan, der die Inhalte des Bereichs wiedergibt. Das über refScan referierte Rasterbild zeigt einen Plan, dessen Geltungsbereich durch den Geltungsbereich des Bereiches (Attribut geltungsbereich von XP_Bereich) oder, wenn geltungsbereich nicht belegt ist, den Geltungsbereich des Gesamtplans (Attribut raeumlicherGeltungsbereich von XP_PLan) definiert ist.
Im Standard sind nur georeferenzierte Rasterpläne zugelassen. Die über refScan referierte externe Referenz muss deshalb entweder vom Typ "PlanMitGeoreferenz" sein oder einen WMS-Request enthalten.';
CREATE INDEX "idx_fk_XP_Bereich_refScan_XP_Bereich" ON "XP_Basisobjekte"."XP_Bereich_refScan" ("XP_Bereich_gid") ;
CREATE INDEX "idx_fk_XP_Bereich_refScan_XP_ExterneReferenz" ON "XP_Basisobjekte"."XP_Plan_externeReferenz" ("externeReferenz");

GRANT SELECT ON TABLE "XP_Basisobjekte"."XP_Bereich_refScan" TO xp_gast;
GRANT ALL ON TABLE "XP_Basisobjekte"."XP_Bereich_refScan" TO xp_user;

-- CR 007
REVOKE ALL ON TABLE "BP_Erhaltungssatzung_und_Denkmalschutz"."BP_ErhaltungsBereichFlaeche" FROM bp_user;
COMMENT ON TABLE "BP_Erhaltungssatzung_und_Denkmalschutz"."BP_ErhaltungsBereichFlaeche" IS 'Fläche, auf denen der Rückbau, die Änderung oder die Nutzungsänderung baulichen Anlagen der Genehmigung durch die Gemeinde bedarf (§172 BauGB)
Die Klasse wird als veraltet gekennzeichnet und fällt in XPlanGML V. 6.0 weg. Stattdessen sollte die Klasse SO_Gebiet verwendet werden.';

-- CR 008
REVOKE ALL ON TABLE "BP_Aufschuettung_Abgrabung_Bodenschaetze"."BP_BodenschaetzeFlaeche" FROM bp_user;
COMMENT ON TABLE "BP_Aufschuettung_Abgrabung_Bodenschaetze"."BP_BodenschaetzeFlaeche" IS 'Flächen für Aufschüttungen, Abgrabungen oder für die Gewinnung von Bodenschätzen (§ 9 Abs. 1 Nr. 17 und Abs. 6 BauGB). Hier: Flächen für Gewinnung von Bodenschätzen
Die Klasse wird als veraltet gekennzeichnet und wird in XPlanGML V. 6.0 wegfallen. Es sollte stattdessen die Klasse BP_AbgrabungsFlaeche verwendet werden.';
ALTER TABLE "BP_Aufschuettung_Abgrabung_Bodenschaetze"."BP_AbgrabungsFlaeche" ADD COLUMN "abbaugut" VARCHAR(255);
COMMENT ON COLUMN "BP_Aufschuettung_Abgrabung_Bodenschaetze"."BP_AbgrabungsFlaeche"."abbaugut" IS 'Bezeichnung des Abbauguts.';

REVOKE ALL ON TABLE "FP_Aufschuettung_Abgrabung_Bodenschaetze"."FP_BodenschaetzeFlaeche" FROM fp_user;
COMMENT ON TABLE "FP_Aufschuettung_Abgrabung_Bodenschaetze"."FP_BodenschaetzeFlaeche" IS 'Flächen für Aufschüttungen, Abgrabungen oder für die Gewinnung von Bodenschätzen (§5, Abs. 2, Nr. 8 BauGB. Hier: Flächen für Bodenschätze.
Die Klasse wird als veraltet gekennzeichnet und wird in XPlanGML V. 6.0 wegfallen. Es sollte stattdessen die Klasse FP_AbgrabungsFlaeche verwendet werden.';
ALTER TABLE "FP_Aufschuettung_Abgrabung_Bodenschaetze"."FP_AbgrabungsFlaeche" ADD COLUMN "abbaugut" VARCHAR(255);
COMMENT ON TABLE "FP_Aufschuettung_Abgrabung_Bodenschaetze"."FP_AbgrabungFlaeche" IS 'Flächen für Aufschüttungen, Abgrabungen oder für die Gewinnung von Bodenschätzen (§5, Abs. 2, Nr. 8 BauGB). Hier: Flächen für Abgrabungen und die Gewinnung von Bodenschätzen.';
COMMENT ON COLUMN "FP_Aufschuettung_Abgrabung_Bodenschaetze"."FP_AbgrabungFlaeche"."abbaugut" IS 'Bezeichnung des Abbauguts.';

-- CR 009
UPDATE "XP_Enumerationen"."XP_ZweckbestimmungGemeinbedarf" SET "Bezeichner" = 'veraltet - ' || "Bezeichner" WHERE "Code" IN (10003,12004,14003,16004,18001,20002,22002,24003,26001);

-- CR 010
UPDATE "XP_Enumerationen"."XP_ZweckbestimmungGruen" SET "Bezeichner" = 'veraltet - ' || "Bezeichner" WHERE "Code" = 14007;

-- CR 011
UPDATE "XP_Enumerationen"."XP_ZweckbestimmungVerEntsorgung" SET "Bezeichner" = 'veraltet - ' || "Bezeichner" WHERE "Code" = 18005;
UPDATE "XP_Enumerationen"."XP_ZweckbestimmungVerEntsorgung" SET "Bezeichner" = 'SalzOderSoleleitungen' WHERE "Code" = 18006;

-- CR 012
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

INSERT INTO "BP_Verkehr"."BP_VerkehrsFlaecheBesondererZweckbestimmungFlaeche"(gid,position,flaechenschluss)
SELECT gid,position,flaechenschluss FROM "BP_Verkehr"."BP_VerkehrsFlaecheBesondererZweckbestimmung";

CREATE TRIGGER "change_to_BP_VerkehrsFlaecheBesondererZweckbestimmungFlaeche" BEFORE INSERT OR UPDATE ON "BP_Verkehr"."BP_VerkehrsFlaecheBesondererZweckbestimmungFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_BP_VerkehrsFlaecheBesondererZweckbestimmungFlaeche" AFTER DELETE ON "BP_Verkehr"."BP_VerkehrsFlaecheBesondererZweckbestimmungFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "flaechenschluss_BP_VerkehrsFlaecheBesondererZweckbestimmungFlaeche" BEFORE INSERT OR UPDATE OR DELETE ON "BP_Verkehr"."BP_VerkehrsFlaecheBesondererZweckbestimmungFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isFlaechenschlussobjekt"();

DROP TRIGGER "flaechenschluss_BP_VerkehrsFlaecheBesondererZweckbestimmung" ON "BP_Verkehr"."BP_VerkehrsFlaecheBesondererZweckbestimmung";
ALTER TABLE "BP_Verkehr"."BP_VerkehrsFlaecheBesondererZweckbestimmung" DROP COLUMN "position" CASCADE;
ALTER TABLE "BP_Verkehr"."BP_VerkehrsFlaecheBesondererZweckbestimmung" DROP COLUMN "flaechenschluss";

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

-- CR 013
UPDATE "BP_Verkehr"."BP_ZweckbestimmungStrassenverkehr" SET "Bezeichner" = 'Parkplatz' WHERE "Code" = 1000;
INSERT INTO "BP_Verkehr"."BP_ZweckbestimmungStrassenverkehr" ("Code", "Bezeichner") VALUES (1560, 'ReitKutschweg');
INSERT INTO "BP_Verkehr"."BP_ZweckbestimmungStrassenverkehr" ("Code", "Bezeichner") VALUES (2500, 'Rastanlage');
INSERT INTO "BP_Verkehr"."BP_ZweckbestimmungStrassenverkehr" ("Code", "Bezeichner") VALUES (2600, 'Busbahnhof');

INSERT INTO "FP_Verkehr"."FP_ZweckbestimmungStrassenverkehr" ("Code", "Bezeichner") VALUES ('140012', 'Wirtschaftsweg');
INSERT INTO "FP_Verkehr"."FP_ZweckbestimmungStrassenverkehr" ("Code", "Bezeichner") VALUES ('140013', 'LandwirtschaftlicherVerkehr');
INSERT INTO "FP_Verkehr"."FP_ZweckbestimmungStrassenverkehr" ("Code", "Bezeichner") VALUES ('16002', 'P_RAnlage');
INSERT INTO "FP_Verkehr"."FP_ZweckbestimmungStrassenverkehr" ("Code", "Bezeichner") VALUES ('3000', 'CarSharing');
INSERT INTO "FP_Verkehr"."FP_ZweckbestimmungStrassenverkehr" ("Code", "Bezeichner") VALUES ('3100', 'BikeSharing');
INSERT INTO "FP_Verkehr"."FP_ZweckbestimmungStrassenverkehr" ("Code", "Bezeichner") VALUES ('3200', 'Bike_RideAnlage');
INSERT INTO "FP_Verkehr"."FP_ZweckbestimmungStrassenverkehr" ("Code", "Bezeichner") VALUES ('3300', 'Parkhaus');
INSERT INTO "FP_Verkehr"."FP_ZweckbestimmungStrassenverkehr" ("Code", "Bezeichner") VALUES ('3400', 'Mischverkehrsflaeche');
INSERT INTO "FP_Verkehr"."FP_ZweckbestimmungStrassenverkehr" ("Code", "Bezeichner") VALUES ('3500', 'Ladestation');

-- CR 014
INSERT INTO "XP_Basisobjekte"."XP_ExterneReferenzTyp" ("Code", "Bezeichner") VALUES (1065, 'Verordnung');
INSERT INTO "XP_Basisobjekte"."XP_ExterneReferenzTyp" ("Code", "Bezeichner") VALUES (2600, 'StaedtebaulicherVertrag');

-- CR 015
INSERT INTO "BP_Basisobjekte"."BP_Verfahren" ("Code", "Bezeichner") VALUES ('4000', 'Parag13b');

-- CR 016
-- keine Änderung nötig, war bereits so implementiert

-- CR 017
-- für LP keine Änderung, war bereits implementiert
-- RP
CREATE TABLE "RP_Sonstiges"."RP_GenerischesObjekt_typ" (
  "RP_GenerischesObjekt_gid" BIGINT NOT NULL ,
  "typ" INTEGER NULL ,
  PRIMARY KEY ("RP_GenerischesObjekt_gid", "typ"),
  CONSTRAINT "fk_RP_GenerischesObjekt_typ1"
    FOREIGN KEY ("RP_GenerischesObjekt_gid" )
    REFERENCES "RP_Sonstiges"."RP_GenerischesObjekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_RP_GenerischesObjekt_typ2"
    FOREIGN KEY ("typ" )
    REFERENCES "RP_Sonstiges"."RP_GenerischesObjektTypen" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
GRANT SELECT ON TABLE "RP_Sonstiges"."RP_GenerischesObjekt_typ" TO xp_gast;
GRANT ALL ON TABLE "RP_Sonstiges"."RP_GenerischesObjekt_typ" TO rp_user;
COMMENT ON TABLE "RP_Sonstiges"."RP_GenerischesObjekt_typ" IS 'Über eine CodeList definierte Zweckbestimmungen der Festlegung.';

INSERT INTO "RP_Sonstiges"."RP_GenerischesObjekt_typ"("RP_GenerischesObjekt_gid", "typ") SELECT "gid","typ" FROM "RP_Sonstiges"."RP_GenerischesObjekt";
ALTER TABLE "RP_Sonstiges"."RP_GenerischesObjekt" DROP COLUMN "typ";

-- CR 021
ALTER TABLE "RP_Basisobjekte"."RP_Plan" ADD COLUMN "genehmigungsbehoerde" VARCHAR(256);
COMMENT ON COLUMN "RP_Basisobjekte"."RP_Plan"."genehmigungsbehoerde" IS 'Zuständige Genehmigungsbehörde';
INSERT INTO "RP_Freiraumstruktur"."RP_ErneuerbareEnergieTypen" ("Code", "Bezeichner") VALUES ('5000', 'Wasserkraft');

-- CR 022
INSERT INTO "RP_Siedlungsstruktur"."RP_ZentralerOrtSonstigeTypen" ("Code", "Bezeichner") VALUES ('2200', 'Kongruenzraum');
INSERT INTO "RP_Freiraumstruktur"."RP_BodenschutzTypen" ("Code", "Bezeichner") VALUES ('4000', 'Torferhalt');
INSERT INTO "RP_Infrastruktur"."RP_SonstVerkehrTypen" ("Code", "Bezeichner") VALUES ('2001', 'Teststrecke');

-- CR 023
-- nicht relevant

-- CR 024
INSERT INTO "XP_Sonstiges"."XP_ArtHoehenbezug" ("Code", "Bezeichner") VALUES ('1100', 'absolutNN');
INSERT INTO "XP_Sonstiges"."XP_ArtHoehenbezug" ("Code", "Bezeichner") VALUES ('1200', 'absolutDHHN');

-- CR 026
INSERT INTO "RP_Siedlungsstruktur"."RP_FunktionszuweisungTypen" ("Code", "Bezeichner") VALUES ('9000', 'LaendlicheSiedlung');
UPDATE "RP_Freiraumstruktur"."RP_BergbauplanungTypen" SET "Bezeichner" = 'Abbau' WHERE "Code" = 1300;
ALTER TABLE "RP_Freiraumstruktur"."RP_LuftTypen" RENAME TO "RP_KlimaschutzTypen";
INSERT INTO "RP_Freiraumstruktur"."RP_KlimaschutzTypen" ("Code", "Bezeichner") VALUES ('3000', 'BesondereKlimaschutzfunktion');
INSERT INTO "RP_Freiraumstruktur"."RP_ErholungTypen" ("Code", "Bezeichner") VALUES ('3001', 'InfrastrukturelleErholung');
INSERT INTO "RP_Freiraumstruktur"."RP_ErholungTypen" ("Code", "Bezeichner") VALUES ('2001', 'LandschaftebezogeneErholung');
INSERT INTO "RP_Infrastruktur"."RP_EnergieversorgungTypen" ("Code", "Bezeichner") VALUES ('8000', 'Korridor');
INSERT INTO "RP_Freiraumstruktur"."RP_RohstoffTypen" ("Code", "Bezeichner") VALUES ('7200', 'Andesit');
INSERT INTO "RP_Freiraumstruktur"."RP_RohstoffTypen" ("Code", "Bezeichner") VALUES ('7300', 'Formsand');
INSERT INTO "RP_Freiraumstruktur"."RP_RohstoffTypen" ("Code", "Bezeichner") VALUES ('7400', 'Gabbro');
INSERT INTO "RP_Freiraumstruktur"."RP_RohstoffTypen" ("Code", "Bezeichner") VALUES ('7500', 'MikrodioritKuselit');

-- CR 027
UPDATE "SO_SonstigeGebiete"."SO_GebietsArt" SET "Bezeichner" = 'BusinessImprovementDistrict' WHERE "Code" = 1500;
UPDATE "SO_SonstigeGebiete"."SO_GebietsArt" SET "Bezeichner" = 'HousingImprovementDistrict' WHERE "Code" = 1600;
-- andere Änderungen nicht relevant

-- CR 028
-- nicht relevant, da Konformitätsbedingung nicht umgesetzt war

-- CR 030
INSERT INTO "XP_Sonstiges"."XP_ArtHoehenbezugspunkt" ("Code", "Bezeichner") VALUES ('6500', 'WH');

-- CR 031
ALTER TABLE "BP_Verkehr"."BP_VerkehrsFlaecheBesondererZweckbestimmung" ADD COLUMN "zugunstenVon" VARCHAR(64);
COMMENT ON COLUMN "BP_Verkehr"."BP_VerkehrsFlaecheBesondererZweckbestimmung"."zugunstenVon" IS 'Begünstigter der Festsetzung';

-- CR 032
CREATE SEQUENCE "BP_Bebauung"."BP_Dachgestaltung_id_seq"
   MINVALUE 1;
GRANT ALL ON TABLE "BP_Bebauung"."BP_Dachgestaltung_id_seq" TO GROUP bp_user;
-- -----------------------------------------------------
-- Table "BP_Bebauung"."BP_Dachgestaltung"
-- -----------------------------------------------------
CREATE TABLE "BP_Bebauung"."BP_Dachgestaltung" (
  "id" INTEGER NOT NULL DEFAULT nextval('"BP_Bebauung"."BP_Dachgestaltung_id_seq"'),
  "DNmin" INTEGER,
  "DNmax" INTEGER,
  "DN" INTEGER,
  "DNZwingend" INTEGER,
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
COMMENT ON COLUMN "BP_Bebauung"."BP_Dachgestaltung"."DNZwingend" IS 'Zwingend vorgeschriebene Dachneigung.';
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

COMMENT ON COLUMN "BP_Bebauung"."BP_GestaltungBaugebiet"."DNmin" IS 'Minimal zulässige Dachneigung bei einer Bereichsangabe.
Dies Attribut ist veraltet und wird in Version 6.0 wegfallen. Es sollte stattdessen der Datentyp BP_Dachgestaltung (Attribut dachgestaltung) verwendet werden.';
COMMENT ON COLUMN "BP_Bebauung"."BP_GestaltungBaugebiet"."DNmax" IS 'Maximal zulässige Dachneigung bei einer Bereichsangabe.
Dies Attribut ist veraltet und wird in Version 6.0 wegfallen. Es sollte stattdessen der Datentyp BP_Dachgestaltung (Attribut dachgestaltung) verwendet werden.';
COMMENT ON COLUMN "BP_Bebauung"."BP_GestaltungBaugebiet"."DN" IS 'Maximal zulässige Dachneigung.
Dies Attribut ist veraltet und wird in Version 6.0 wegfallen. Es sollte stattdessen der Datentyp BP_Dachgestaltung (Attribut dachgestaltung) verwendet werden.';
COMMENT ON COLUMN "BP_Bebauung"."BP_GestaltungBaugebiet"."DNZwingend" IS 'Zwingend vorgeschriebene Dachneigung.
Dies Attribut ist veraltet und wird in Version 6.0 wegfallen. Es sollte stattdessen der Datentyp BP_Dachgestaltung (Attribut dachgestaltung) verwendet werden.';
COMMENT ON TABLE "BP_Bebauung"."BP_GestaltungBaugebiet_dachform" IS 'Erlaubte Dachformen.
Dies Attribut ist veraltet und wird in Version 6.0 wegfallen. Es sollte stattdessen der Datentyp BP_Dachgestaltung (Attribut dachgestaltung) verwendet werden.';
COMMENT ON TABLE "BP_Bebauung"."BP_GestaltungBaugebiet_detaillierteDachform" IS 'Über eine Codeliste definiertere detailliertere Dachform.
Der an einer bestimmten Listenposition aufgeführte Wert von "detaillierteDachform" bezieht sich auf den an gleicher Position stehenden Attributwert von dachform.
Dies Attribut ist veraltet und wird in Version 6.0 wegfallen. Es sollte stattdessen der Datentyp BP_Dachgestaltung (Attribut dachgestaltung) verwendet werden.';

-- CR 033
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
INSERT INTO "BP_Sonstiges"."BP_Wegerecht_typ"("BP_Wegerecht_gid","typ") SELECT gid, 1000 WHERE "typ" IN (1000,3000,4100,5000);
INSERT INTO "BP_Sonstiges"."BP_Wegerecht_typ"("BP_Wegerecht_gid","typ") SELECT gid, 2000 WHERE "typ" IN (2000,3000,4200,5000);
INSERT INTO "BP_Sonstiges"."BP_Wegerecht_typ"("BP_Wegerecht_gid","typ") SELECT gid, 4000 WHERE "typ" IN (4000,4100,4200,5000);
ALTER TABLE "BP_Sonstiges"."BP_Wegerecht" DROP COLUMN "typ";
INSERT INTO "BP_Sonstiges"."BP_WegerechtTypen" ("Code", "Bezeichner") VALUES ('2500', 'Radfahrrecht');

-- CR 034
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
    REFERENCES "BP_Bebauung"."BP_Wegerecht" ("gid" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
GRANT SELECT ON TABLE "BP_Bebauung"."BP_SpezielleBauweise_wegerecht" TO xp_gast;
GRANT ALL ON TABLE "BP_Bebauung"."BP_SpezielleBauweise_wegerecht" TO bp_user;
COMMENT ON TABLE "BP_Bebauung"."BP_SpezielleBauweise_wegerecht" IS 'Relation auf Angaben zu Wegerechten.';
INSERT INTO "BP_Bebauung"."BP_SpezielleBauweiseTypen" ("Code", "Bezeichner") VALUES (1600, 'Bruecke');
INSERT INTO "BP_Bebauung"."BP_SpezielleBauweiseTypen" ("Code", "Bezeichner") VALUES (1700, 'Tunnel');
INSERT INTO "BP_Bebauung"."BP_SpezielleBauweiseTypen" ("Code", "Bezeichner") VALUES (1800, 'Rampe');

-- CR 036, siehe auch CR 013
INSERT INTO "BP_Verkehr"."BP_ZweckbestimmungStrassenverkehr" ("Code", "Bezeichner") VALUES (3000, 'CarSharing');
INSERT INTO "BP_Verkehr"."BP_ZweckbestimmungStrassenverkehr" ("Code", "Bezeichner") VALUES (3100, 'BikeSharing');
INSERT INTO "BP_Verkehr"."BP_ZweckbestimmungStrassenverkehr" ("Code", "Bezeichner") VALUES (3200, 'B_RAnlage');
INSERT INTO "BP_Verkehr"."BP_ZweckbestimmungStrassenverkehr" ("Code", "Bezeichner") VALUES (3300, 'Parkhaus');
INSERT INTO "BP_Verkehr"."BP_ZweckbestimmungStrassenverkehr" ("Code", "Bezeichner") VALUES (3400, 'Mischverkehrsflaeche');
INSERT INTO "BP_Verkehr"."BP_ZweckbestimmungStrassenverkehr" ("Code", "Bezeichner") VALUES (3500, 'Ladestation');

-- CR 037
INSERT INTO "BP_Bebauung"."BP_ZweckbestimmungGemeinschaftsanlagen" ("Code", "Bezeichner") VALUES (4100, 'Fahrradstellplaetze');
INSERT INTO "BP_Bebauung"."BP_ZweckbestimmungGemeinschaftsanlagen" ("Code", "Bezeichner") VALUES (4200, 'Gemeinschaftsdachgaerten');
INSERT INTO "BP_Bebauung"."BP_ZweckbestimmungGemeinschaftsanlagen" ("Code", "Bezeichner") VALUES (4300, 'GemeinschaftlichNutzbareDachflaechen');

-- CR 038
INSERT INTO "BP_Bebauung"."BP_ZweckbestimmungNebenanlagen" ("Code", "Bezeichner") VALUES (3700, 'Fahrradstellplaetze');

-- CR 039
ALTER TABLE "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_AnpflanzungBindungErhaltung" ADD COLUMN "anzahl" INTEGER;
COMMENT ON COLUMN "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_AnpflanzungBindungErhaltung"."anzahl" IS 'Anzahl der anzupflanzenden Objekte';
ALTER TABLE "LP_MassnahmenNaturschutz"."LP_AnpflanzungBindungErhaltung" ADD COLUMN "anzahl" INTEGER;
COMMENT ON COLUMN "LP_MassnahmenNaturschutz"."LP_AnpflanzungBindungErhaltung"."anzahl" IS 'Anzahl der anzupflanzenden Objekte';

-- CR 040
ALTER TABLE "XP_Basisobjekte"."XP_Plan" ADD COLUMN "technischerPlanersteller" VARCHAR(1024);
COMMENT ON COLUMN "XP_Basisobjekte"."XP_Plan"."technischerPlanersteller" IS 'Bezeichnung der Institution oder Firma, die den Plan technisch erstellt hat.';

-- CR 041
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
-- Table "FP_Basisobjekte"."FP_Plan_planaufstellendeGemeinde"
-- -----------------------------------------------------
CREATE TABLE "FP_Basisobjekte"."FP_Plan_planaufstellendeGemeinde" (
  "FP_Plan_gid" BIGINT NOT NULL ,
  "planaufstellendeGemeinde" INTEGER NOT NULL ,
  PRIMARY KEY ("FP_Plan_gid", "planaufstellendeGemeinde") ,
  CONSTRAINT "fk_planaufstellendeGemeinde_FP_Plan1"
    FOREIGN KEY ("FP_Plan_gid" )
    REFERENCES "FP_Basisobjekte"."FP_Plan" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_planaufstellendeGemeinde_XP_Gemeinde1"
    FOREIGN KEY ("planaufstellendeGemeinde" )
    REFERENCES "XP_Sonstiges"."XP_Gemeinde" ("id" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
GRANT SELECT ON "FP_Basisobjekte"."FP_Plan_planaufstellendeGemeinde" TO xp_gast;
GRANT ALL ON "FP_Basisobjekte"."FP_Plan_planaufstellendeGemeinde" TO fp_user;
COMMENT ON TABLE "FP_Basisobjekte"."FP_Plan_planaufstellendeGemeinde" IS 'Die für die ursprüngliche Planaufstellung zuständige Gemeinde, falls diese nicht unter dem Attribut gemeinde aufgeführt ist. Dies kann z.B. nach Gemeindefusionen der Fall sein.';
CREATE INDEX "idx_fk_planaufstellendeGemeinde_FP_Plan1" ON "FP_Basisobjekte"."FP_Plan_planaufstellendeGemeinde" ("FP_Plan_gid") ;
CREATE INDEX "idx_fk_planaufstellendeGemeinde_XP_Gemeinde1" ON "FP_Basisobjekte"."FP_Plan_planaufstellendeGemeinde" ("planaufstellendeGemeinde");
-- -----------------------------------------------------
-- Table "SO_Basisobjekte"."SO_Plan_planaufstellendeGemeinde"
-- -----------------------------------------------------
CREATE TABLE "SO_Basisobjekte"."SO_Plan_planaufstellendeGemeinde" (
  "SO_Plan_gid" BIGINT NOT NULL ,
  "planaufstellendeGemeinde" INTEGER NOT NULL ,
  PRIMARY KEY ("SO_Plan_gid", "planaufstellendeGemeinde") ,
  CONSTRAINT "fk_planaufstellendeGemeinde_SO_Plan1"
    FOREIGN KEY ("SO_Plan_gid" )
    REFERENCES "SO_Basisobjekte"."SO_Plan" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_planaufstellendeGemeinde_XP_Gemeinde1"
    FOREIGN KEY ("planaufstellendeGemeinde" )
    REFERENCES "XP_Sonstiges"."XP_Gemeinde" ("id" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
GRANT SELECT ON "SO_Basisobjekte"."SO_Plan_planaufstellendeGemeinde" TO xp_gast;
GRANT ALL ON "SO_Basisobjekte"."SO_Plan_planaufstellendeGemeinde" TO so_user;
COMMENT ON TABLE "SO_Basisobjekte"."SO_Plan_planaufstellendeGemeinde" IS 'Die für die ursprüngliche Planaufstellung zuständige Gemeinde, falls diese nicht unter dem Attribut gemeinde aufgeführt ist. Dies kann z.B. nach Gemeindefusionen der Fall sein.';
CREATE INDEX "idx_fk_planaufstellendeGemeinde_SO_Plan1" ON "SO_Basisobjekte"."SO_Plan_planaufstellendeGemeinde" ("SO_Plan_gid") ;
CREATE INDEX "idx_fk_planaufstellendeGemeinde_XP_Gemeinde1" ON "SO_Basisobjekte"."SO_Plan_planaufstellendeGemeinde" ("planaufstellendeGemeinde");

-- CR 042
INSERT INTO "XP_Basisobjekte"."XP_ExterneReferenzTyp" ("Code", "Bezeichner") VALUES (2700, 'UmweltbezogeneStellungnahmen');
INSERT INTO "XP_Basisobjekte"."XP_ExterneReferenzTyp" ("Code", "Bezeichner") VALUES (2800, 'Beschluss');

-- CR 043
-- -----------------------------------------------------
-- Table "SO_Basisobjekte"."SO_Plan_gemeinde"
-- -----------------------------------------------------
CREATE TABLE "SO_Basisobjekte"."SO_Plan_gemeinde" (
  "SO_Plan_gid" BIGINT NOT NULL ,
  "gemeinde" INTEGER NOT NULL ,
  PRIMARY KEY ("SO_Plan_gid", "gemeinde") ,
  CONSTRAINT "fk_gemeinde_SO_Plan1"
    FOREIGN KEY ("SO_Plan_gid" )
    REFERENCES "SO_Basisobjekte"."SO_Plan" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_gemeinde_XP_Gemeinde1"
    FOREIGN KEY ("gemeinde" )
    REFERENCES "XP_Sonstiges"."XP_Gemeinde" ("id" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
GRANT SELECT ON "SO_Basisobjekte"."SO_Plan_gemeinde" TO xp_gast;
GRANT ALL ON "SO_Basisobjekte"."SO_Plan_gemeinde" TO so_user;
COMMENT ON TABLE "SO_Basisobjekte"."SO_Plan_gemeinde" IS 'Zuständige Gemeinde';
CREATE INDEX "idx_fk_gemeinde_SO_Plan1" ON "SO_Basisobjekte"."SO_Plan_gemeinde" ("SO_Plan_gid") ;
CREATE INDEX "idx_fk_gemeinde_XP_Gemeinde1" ON "SO_Basisobjekte"."SO_Plan_gemeinde" ("gemeinde");

-- CR 044
UPDATE "XP_Enumerationen"."XP_ZweckbestimmungGruen" SET "Bezeichner" = 'veraltet - ' || "Bezeichner" WHERE "Code" = 24002;

-- CR 046
COMMENT ON TABLE  "BP_Aufschuettung_Abgrabung_Bodenschaetze"."BP_RekultivierungsFlaeche" IS 'Rekultivierungs-Fläche
Die Klasse wird als veraltet gekennzeichnet und wird in XPlanGML 6.0 wegfallen. Es sollte stattdessen die Klasse SO_SonstigesRecht verwendet werden.';
