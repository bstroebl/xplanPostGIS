-- Sammlung aller Bugfixes und Verbesserungen für XPlan 5.2 seit dem Release

-- füge vergessenes Attribut hinzu
-- -----------------------------------------------------
-- Table "BP_Gemeinbedarf_Spiel_und_Sportanlagen"."BP_DetailZweckbestGemeinbedarf"
-- -----------------------------------------------------
CREATE TABLE "BP_Gemeinbedarf_Spiel_und_Sportanlagen"."BP_DetailZweckbestGemeinbedarf" (
  "Code" INTEGER NOT NULL,
  "Bezeichner" VARCHAR(64) NOT NULL,
  PRIMARY KEY ("Code"));
GRANT SELECT ON TABLE "BP_Gemeinbedarf_Spiel_und_Sportanlagen"."BP_DetailZweckbestGemeinbedarf" TO xp_gast;

-- -----------------------------------------------------
-- Table "BP_Gemeinbedarf_Spiel_und_Sportanlagen"."BP_GemeinbedarfsFlaeche_detaillierteZweckbestimmung"
-- -----------------------------------------------------
CREATE TABLE "BP_Gemeinbedarf_Spiel_und_Sportanlagen"."BP_GemeinbedarfsFlaeche_detaillierteZweckbestimmung" (
  "BP_GemeinbedarfsFlaeche_gid" BIGINT NOT NULL,
  "detaillierteZweckbestimmung" INTEGER NOT NULL,
  PRIMARY KEY ("BP_GemeinbedarfsFlaeche_gid", "detaillierteZweckbestimmung"),
  CONSTRAINT "fk_BP_GemeinbedarfsFlaeche_detaillierteZweckbes1"
    FOREIGN KEY ("BP_GemeinbedarfsFlaeche_gid")
    REFERENCES "BP_Gemeinbedarf_Spiel_und_Sportanlagen"."BP_GemeinbedarfsFlaeche" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_BP_GemeinbedarfsFlaeche_detaillierteZweckbes2"
    FOREIGN KEY ("detaillierteZweckbestimmung")
    REFERENCES "BP_Gemeinbedarf_Spiel_und_Sportanlagen"."BP_DetailZweckbestGemeinbedarf" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE);

GRANT SELECT ON TABLE "BP_Gemeinbedarf_Spiel_und_Sportanlagen"."BP_GemeinbedarfsFlaeche_detaillierteZweckbestimmung" TO xp_gast;
GRANT ALL ON TABLE "BP_Gemeinbedarf_Spiel_und_Sportanlagen"."BP_GemeinbedarfsFlaeche_detaillierteZweckbestimmung" TO bp_user;
COMMENT ON TABLE  "BP_Gemeinbedarf_Spiel_und_Sportanlagen"."BP_GemeinbedarfsFlaeche_detaillierteZweckbestimmung" IS 'Über eine Codeliste definierte detailliertere Festlegung der Zweckbestimmung.
Der an einer bestimmten Listenposition aufgeführte Wert von "detaillierteZweckbestimmung" bezieht sich auf den an gleicher Position stehenden Attributwert von "zweckbestimmung".';
