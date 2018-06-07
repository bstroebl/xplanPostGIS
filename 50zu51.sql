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
