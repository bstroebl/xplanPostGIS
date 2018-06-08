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
