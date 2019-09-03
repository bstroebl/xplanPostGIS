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

-- falsche Rechte auf CodeListen
REVOKE ALL ON TABLE "RP_Basisobjekte"."RP_SonstPlanArt" FROM lp_user;
GRANT ALL ON TABLE "RP_Basisobjekte"."RP_SonstPlanArt" TO rp_user;
REVOKE ALL ON TABLE "RP_Basisobjekte"."RP_Status" FROM fp_user;
GRANT ALL ON TABLE "RP_Basisobjekte"."RP_Status" TO rp_user;
REVOKE ALL ON TABLE "RP_Sonstiges"."RP_SonstGrenzeTypen" FROM so_user;
GRANT ALL ON TABLE "RP_Sonstiges"."RP_SonstGrenzeTypen" TO rp_user;
REVOKE ALL ON TABLE "RP_Sonstiges"."RP_SpezifischeGrenzeTypen" FROM so_user;
GRANT ALL ON TABLE "RP_Sonstiges"."RP_SpezifischeGrenzeTypen" TO rp_user;
REVOKE ALL ON FUNCTION "RP_Basisobjekte"."new_RP_Bereich"() FROM fp_user;
GRANT EXECUTE ON FUNCTION "RP_Basisobjekte"."new_RP_Bereich"() TO rp_user;
REVOKE ALL ON "RP_Basisobjekte"."RP_TextAbschnitt" FROM bp_user;
GRANT ALL ON "RP_Basisobjekte"."RP_TextAbschnitt" TO rp_user;
REVOKE ALL ON "RP_Basisobjekte"."RP_Objekt_refTextInhalt" FROM bp_user;
GRANT ALL ON "RP_Basisobjekte"."RP_Objekt_refTextInhalt" TO rp_user;

-- Korrektur Attributname:
ALTER TABLE "LP_SchutzgebieteObjekte"."LP_ForstrechtDetailTypen" RENAME TO "LP_WaldschutzDetailTypen";
