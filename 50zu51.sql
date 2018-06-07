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
