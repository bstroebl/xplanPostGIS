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

-- sichere Primärschlüssel in CodeListen
-- dieses Feature wird für den reibungslosen Import über QGIS benötigt, es kann evtl auch auf ältere Versionen angewendet werden
-- der Benutzer kann jederzeit eigene Schlüsselwerte (< 1000000) im Feld Code bei Neueintragungen vergeben
CREATE SEQUENCE "XP_Basisobjekte"."XP_Code_seq"
   MINVALUE 1000000; -- eigene Codelistenwerte des Benutzers < 1000000
GRANT ALL ON TABLE "XP_Basisobjekte"."XP_Code_seq" TO GROUP xp_user;
CREATE OR REPLACE FUNCTION "XP_Basisobjekte"."isCodeList"()
RETURNS trigger AS
$BODY$
 BEGIN
    IF (TG_OP = 'INSERT') THEN
        IF NEW."Code" IS NULL THEN
            NEW."Code" := nextval('"XP_Basisobjekte"."XP_Code_seq"');
        ELSE
            IF NEW."Code" > 1000000 THEN
                NEW."Code" := nextval('"XP_Basisobjekte"."XP_Code_seq"');
            END IF;
        END IF;
        RETURN new;
    ELSIF (TG_OP = 'UPDATE') THEN
        new."Code" := old."Code";
        RETURN new;
    END IF;
 END; $BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
GRANT EXECUTE ON FUNCTION "XP_Basisobjekte"."isCodeList"() TO xp_user;
-- CodeLists in XP
GRANT ALL ON "XP_Basisobjekte"."XP_MimeTypes" TO xp_user;
CREATE TRIGGER "ins_upd_XP_MimeTypes" BEFORE INSERT OR UPDATE ON "XP_Basisobjekte"."XP_MimeTypes" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isCodeList"();
CREATE TRIGGER "ins_upd_XP_GesetzlicheGrundlage" BEFORE INSERT OR UPDATE ON "XP_Basisobjekte"."XP_GesetzlicheGrundlage" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isCodeList"();
CREATE TRIGGER "ins_upd_XP_StylesheetListe" BEFORE INSERT OR UPDATE ON "XP_Praesentationsobjekte"."XP_StylesheetListe" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isCodeList"();
-- CodeLists in BP
CREATE TRIGGER "ins_upd_BP_Status" BEFORE INSERT OR UPDATE ON "BP_Basisobjekte"."BP_Status" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isCodeList"();
CREATE TRIGGER "ins_upd_BP_SonstPlanArt" BEFORE INSERT OR UPDATE ON "BP_Basisobjekte"."BP_SonstPlanArt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isCodeList"();
GRANT ALL ON "BP_Bebauung"."BP_DetailArtDerBaulNutzung" TO bp_user;
CREATE TRIGGER "ins_upd_BP_DetailArtDerBaulNutzung" BEFORE INSERT OR UPDATE ON "BP_Bebauung"."BP_DetailArtDerBaulNutzung" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isCodeList"();
GRANT ALL ON "BP_Bebauung"."BP_AbweichendeBauweise" TO bp_user;
CREATE TRIGGER "ins_upd_BP_AbweichendeBauweise" BEFORE INSERT OR UPDATE ON "BP_Bebauung"."BP_AbweichendeBauweise" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isCodeList"();
GRANT ALL ON "BP_Bebauung"."BP_DetailDachform" TO bp_user;
CREATE TRIGGER "ins_upd_BP_DetailDachform" BEFORE INSERT OR UPDATE ON "BP_Bebauung"."BP_DetailDachform" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isCodeList"();
GRANT ALL ON "BP_Bebauung"."BP_DetailZweckbestGemeinschaftsanlagen" TO bp_user;
CREATE TRIGGER "ins_upd_BP_DetailZweckbestGemeinschaftsanlagen" BEFORE INSERT OR UPDATE ON "BP_Bebauung"."BP_DetailZweckbestGemeinschaftsanlagen" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isCodeList"();
GRANT ALL ON "BP_Bebauung"."BP_spezielleBauweiseSonstTypen" TO bp_user;
CREATE TRIGGER "ins_upd_BP_spezielleBauweiseSonstTypen" BEFORE INSERT OR UPDATE ON "BP_Bebauung"."BP_spezielleBauweiseSonstTypen" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isCodeList"();
GRANT ALL ON "BP_Bebauung"."BP_DetailZweckbestNebenanlagen" TO bp_user;
CREATE TRIGGER "ins_upd_BP_DetailZweckbestNebenanlagen" BEFORE INSERT OR UPDATE ON "BP_Bebauung"."BP_DetailZweckbestNebenanlagen" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isCodeList"();
GRANT ALL ON "BP_Bebauung"."BP_NutzungNichUueberbaubGrundstFlaeche" TO bp_user;
CREATE TRIGGER "ins_upd_BP_NutzungNichUueberbaubGrundstFlaechen" BEFORE INSERT OR UPDATE ON "BP_Bebauung"."BP_NutzungNichUueberbaubGrundstFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isCodeList"();
GRANT ALL ON "BP_Gemeinbedarf_Spiel_und_Sportanlagen"."BP_DetailZweckbestGemeinbedarf" TO bp_user;
CREATE TRIGGER "ins_upd_BP_DetailZweckbestGemeinbedarf" BEFORE INSERT OR UPDATE ON "BP_Gemeinbedarf_Spiel_und_Sportanlagen"."BP_DetailZweckbestGemeinbedarf" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isCodeList"();
GRANT ALL ON "BP_Gemeinbedarf_Spiel_und_Sportanlagen"."BP_DetailZweckbestSpielSportanlage" TO bp_user;
CREATE TRIGGER "ins_upd_BP_DetailZweckbestSpielSportanlage" BEFORE INSERT OR UPDATE ON "BP_Gemeinbedarf_Spiel_und_Sportanlagen"."BP_DetailZweckbestSpielSportanlage" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isCodeList"();
GRANT ALL ON "BP_Landwirtschaft_Wald_und_Gruen"."BP_DetailZweckbestGruenFlaeche" TO bp_user;
CREATE TRIGGER "ins_upd_BP_DetailZweckbestGruenFlaeche" BEFORE INSERT OR UPDATE ON "BP_Landwirtschaft_Wald_und_Gruen"."BP_DetailZweckbestGruenFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isCodeList"();
GRANT ALL ON "BP_Landwirtschaft_Wald_und_Gruen"."BP_DetailZweckbestLandwirtschaft" TO bp_user;
CREATE TRIGGER "ins_upd_BP_DetailZweckbestLandwirtschaft" BEFORE INSERT OR UPDATE ON "BP_Landwirtschaft_Wald_und_Gruen"."BP_DetailZweckbestLandwirtschaft" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isCodeList"();
GRANT ALL ON "BP_Landwirtschaft_Wald_und_Gruen"."BP_DetailZweckbestWaldFlaeche" TO bp_user;
CREATE TRIGGER "ins_upd_BP_DetailZweckbestWaldFlaeche" BEFORE INSERT OR UPDATE ON "BP_Landwirtschaft_Wald_und_Gruen"."BP_DetailZweckbestWaldFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isCodeList"();
GRANT ALL ON "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_VegetationsobjektTypen" TO bp_user;
CREATE TRIGGER "ins_upd_BP_VegetationsobjektTypen" BEFORE INSERT OR UPDATE ON "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_VegetationsobjektTypen" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isCodeList"();
CREATE TRIGGER "ins_upd_BP_ZweckbestimmungGenerischeObjekte" BEFORE INSERT OR UPDATE ON "BP_Sonstiges"."BP_ZweckbestimmungGenerischeObjekte" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isCodeList"();
GRANT ALL ON "BP_Sonstiges"."BP_DetailAbgrenzungenTypen" TO bp_user;
CREATE TRIGGER "ins_upd_BP_DetailAbgrenzungenTypen" BEFORE INSERT OR UPDATE ON "BP_Sonstiges"."BP_DetailAbgrenzungenTypen" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isCodeList"();
GRANT ALL ON "BP_Umwelt"."BP_DetailTechnVorkehrungImmissionsschutz" TO bp_user;
CREATE TRIGGER "ins_upd_BP_DetailTechnVorkehrungImmissionsschutz" BEFORE INSERT OR UPDATE ON "BP_Umwelt"."BP_DetailTechnVorkehrungImmissionsschutz" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isCodeList"();
GRANT ALL ON "BP_Ver_und_Entsorgung"."BP_DetailZweckbestVerEntsorgung" TO bp_user;
CREATE TRIGGER "ins_upd_BP_DetailZweckbestVerEntsorgung" BEFORE INSERT OR UPDATE ON "BP_Ver_und_Entsorgung"."BP_DetailZweckbestVerEntsorgung" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isCodeList"();
GRANT ALL ON "BP_Verkehr"."BP_DetailZweckbestStrassenverkehr" TO bp_user;
CREATE TRIGGER "ins_upd_BP_DetailZweckbestStrassenverkehr" BEFORE INSERT OR UPDATE ON "BP_Verkehr"."BP_DetailZweckbestStrassenverkehr" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isCodeList"();
GRANT ALL ON "BP_Wasser"."BP_DetailZweckbestWasserwirtschaft" TO bp_user;
CREATE TRIGGER "ins_upd_BP_DetailZweckbestWasserwirtschaft" BEFORE INSERT OR UPDATE ON "BP_Wasser"."BP_DetailZweckbestWasserwirtschaft" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isCodeList"();
GRANT ALL ON "BP_Wasser"."BP_DetailZweckbestGewaesser" TO bp_user;
CREATE TRIGGER "ins_upd_BP_DetailZweckbestGewaesser" BEFORE INSERT OR UPDATE ON "BP_Wasser"."BP_DetailZweckbestGewaesser" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isCodeList"();
-- CodeLists in FP
CREATE TRIGGER "ins_upd_FP_Status" BEFORE INSERT OR UPDATE ON "FP_Basisobjekte"."FP_Status" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isCodeList"();
CREATE TRIGGER "ins_upd_FP_SonstPlanArt" BEFORE INSERT OR UPDATE ON "FP_Basisobjekte"."FP_SonstPlanArt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isCodeList"();
CREATE TRIGGER "ins_upd_FP_SpezifischePraegungTypen" BEFORE INSERT OR UPDATE ON "FP_Basisobjekte"."FP_SpezifischePraegungTypen" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isCodeList"();
CREATE TRIGGER "ins_upd_FP_DetailArtDerBaulNutzung" BEFORE INSERT OR UPDATE ON "FP_Bebauung"."FP_DetailArtDerBaulNutzung" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isCodeList"();
CREATE TRIGGER "ins_upd_FP_DetailZweckbestGemeinbedarf" BEFORE INSERT OR UPDATE ON "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_DetailZweckbestGemeinbedarf" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isCodeList"();
CREATE TRIGGER "ins_upd_FP_DetailZweckbestSpielSportanlage" BEFORE INSERT OR UPDATE ON "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_DetailZweckbestSpielSportanlage" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isCodeList"();
CREATE TRIGGER "ins_upd_FP_DetailZweckbestLandwirtschaftsFlaeche" BEFORE INSERT OR UPDATE ON "FP_Landwirtschaft_Wald_und_Gruen"."FP_DetailZweckbestLandwirtschaftsFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isCodeList"();
CREATE TRIGGER "ins_upd_FP_DetailZweckbestGruen" BEFORE INSERT OR UPDATE ON "FP_Landwirtschaft_Wald_und_Gruen"."FP_DetailZweckbestGruen" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isCodeList"();
CREATE TRIGGER "ins_upd_FP_DetailZweckbestWaldFlaeche" BEFORE INSERT OR UPDATE ON "FP_Landwirtschaft_Wald_und_Gruen"."FP_DetailZweckbestWaldFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isCodeList"();
CREATE TRIGGER "ins_upd_FP_ZweckbestimmungGenerischeObjekte" BEFORE INSERT OR UPDATE ON "FP_Sonstiges"."FP_ZweckbestimmungGenerischeObjekte" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isCodeList"();
CREATE TRIGGER "ins_upd_FP_DetailZweckbestVerEntsorgung" BEFORE INSERT OR UPDATE ON "FP_Ver_und_Entsorgung"."FP_DetailZweckbestVerEntsorgung" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isCodeList"();
GRANT ALL ON TABLE "FP_Ver_und_Entsorgung"."FP_ZentralerVersorgungsbereichAuspraegung" TO fp_user;
CREATE TRIGGER "ins_upd_FP_ZentralerVersorgungsbereichAuspraegung" BEFORE INSERT OR UPDATE ON "FP_Ver_und_Entsorgung"."FP_ZentralerVersorgungsbereichAuspraegung" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isCodeList"();
CREATE TRIGGER "ins_upd_FP_DetailZweckbestStrassenverkehr" BEFORE INSERT OR UPDATE ON "FP_Verkehr"."FP_DetailZweckbestStrassenverkehr" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isCodeList"();
CREATE TRIGGER "ins_upd_FP_DetailZweckbestGewaesser" BEFORE INSERT OR UPDATE ON "FP_Wasser"."FP_DetailZweckbestGewaesser" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isCodeList"();
CREATE TRIGGER "ins_upd_FP_DetailZweckbestWasserwirtschaft" BEFORE INSERT OR UPDATE ON "FP_Wasser"."FP_DetailZweckbestWasserwirtschaft" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isCodeList"();
-- CodeLists und Rechte in RP
CREATE TRIGGER "ins_upd_RP_SonstPlanArt" BEFORE INSERT OR UPDATE ON "RP_Basisobjekte"."RP_SonstPlanArt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isCodeList"();
CREATE TRIGGER "ins_upd_RP_Status" BEFORE INSERT OR UPDATE ON "RP_Basisobjekte"."RP_Status" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isCodeList"();
GRANT ALL ON TABLE "RP_Sonstiges"."RP_GenerischesObjektTypen" TO rp_user;
CREATE TRIGGER "ins_upd_RP_GenerischesObjektTypen" BEFORE INSERT OR UPDATE ON "RP_Sonstiges"."RP_GenerischesObjektTypen" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isCodeList"();
CREATE TRIGGER "ins_upd_RP_SonstGrenzeTypen" BEFORE INSERT OR UPDATE ON "RP_Sonstiges"."RP_SonstGrenzeTypen" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isCodeList"();
-- CodeLists in LP
CREATE TRIGGER "ins_upd_LP_SonstPlanArt" BEFORE INSERT OR UPDATE ON "LP_Basisobjekte"."LP_SonstPlanArt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isCodeList"();
GRANT ALL ON TABLE "LP_Erholung"."LP_ErholungFreizeitDetailFunktionen" TO lp_user;
CREATE TRIGGER "ins_upd_LP_ErholungFreizeitDetailFunktionen" BEFORE INSERT OR UPDATE ON "LP_Erholung"."LP_ErholungFreizeitDetailFunktionen" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isCodeList"();
GRANT ALL ON TABLE "LP_MassnahmenNaturschutz"."LP_Pflanzart" TO lp_user;
CREATE TRIGGER "ins_upd_LP_Pflanzart" BEFORE INSERT OR UPDATE ON "LP_MassnahmenNaturschutz"."LP_Pflanzart" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isCodeList"();
GRANT ALL ON TABLE "LP_SchutzgebieteObjekte"."LP_SonstRechtDetailTypen" TO lp_user;
CREATE TRIGGER "ins_upd_LP_SonstRechtDetailTypen" BEFORE INSERT OR UPDATE ON "LP_SchutzgebieteObjekte"."LP_SonstRechtDetailTypen" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isCodeList"();
GRANT ALL ON TABLE "LP_SchutzgebieteObjekte"."LP_WaldschutzDetailTypen" TO lp_user;
CREATE TRIGGER "ins_upd_LP_WaldschutzDetailTypen" BEFORE INSERT OR UPDATE ON "LP_SchutzgebieteObjekte"."LP_WaldschutzDetailTypen" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isCodeList"();
GRANT ALL ON TABLE "LP_SchutzgebieteObjekte"."LP_InternatSchutzobjektDetailTypen" TO lp_user;
CREATE TRIGGER "ins_upd_LP_InternatSchutzobjektDetailTypen" BEFORE INSERT OR UPDATE ON "LP_SchutzgebieteObjekte"."LP_InternatSchutzobjektDetailTypen" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isCodeList"();
GRANT ALL ON TABLE "LP_SchutzgebieteObjekte"."LP_SchutzobjektLandesrechtDetailTypen" TO lp_user;
CREATE TRIGGER "ins_upd_LP_SchutzobjektLandesrechtDetailTypen" BEFORE INSERT OR UPDATE ON "LP_SchutzgebieteObjekte"."LP_SchutzobjektLandesrechtDetailTypen" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isCodeList"();
GRANT ALL ON TABLE "LP_SchutzgebieteObjekte"."LP_BodenschutzrechtDetailTypen" TO lp_user;
CREATE TRIGGER "ins_upd_LP_BodenschutzrechtDetailTypen" BEFORE INSERT OR UPDATE ON "LP_SchutzgebieteObjekte"."LP_BodenschutzrechtDetailTypen" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isCodeList"();
GRANT ALL ON TABLE "LP_SchutzgebieteObjekte"."LP_WasserrechtGemeingebrEinschraenkungNaturschutzDetailTypen" TO lp_user;
CREATE TRIGGER "ins_upd_LP_WasserrechtGemeingebrEinschraenkungNaturschutzDetailTypen" BEFORE INSERT OR UPDATE ON "LP_SchutzgebieteObjekte"."LP_WasserrechtGemeingebrEinschraenkungNaturschutzDetailTypen" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isCodeList"();
GRANT ALL ON TABLE "LP_SchutzgebieteObjekte"."LP_WasserrechtSchutzgebietDetailTypen" TO lp_user;
CREATE TRIGGER "ins_upd_LP_WasserrechtSchutzgebietDetailTypen" BEFORE INSERT OR UPDATE ON "LP_SchutzgebieteObjekte"."LP_WasserrechtSchutzgebietDetailTypen" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isCodeList"();
GRANT ALL ON TABLE "LP_SchutzgebieteObjekte"."LP_WasserrechtSonstigeTypen" TO lp_user;
CREATE TRIGGER "ins_upd_LP_WasserrechtSonstigeTypen" BEFORE INSERT OR UPDATE ON "LP_SchutzgebieteObjekte"."LP_WasserrechtSonstigeTypen" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isCodeList"();
GRANT ALL ON TABLE "LP_SchutzgebieteObjekte"."LP_WasserrechtWirtschaftAbflussHochwSchutzDetailTypen" TO lp_user;
CREATE TRIGGER "ins_upd_LP_WasserrechtWirtschaftAbflussHochwSchutzDetailTypen" BEFORE INSERT OR UPDATE ON "LP_SchutzgebieteObjekte"."LP_WasserrechtWirtschaftAbflussHochwSchutzDetailTypen" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isCodeList"();
GRANT ALL ON TABLE "LP_Sonstiges"."LP_MassnahmeLandschaftsbild" TO lp_user;
CREATE TRIGGER "ins_upd_LP_MassnahmeLandschaftsbild" BEFORE INSERT OR UPDATE ON "LP_Sonstiges"."LP_MassnahmeLandschaftsbild" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isCodeList"();
CREATE TRIGGER "ins_upd_LP_ZweckbestimmungGenerischeObjekte" BEFORE INSERT OR UPDATE ON "LP_Sonstiges"."LP_ZweckbestimmungGenerischeObjekte" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isCodeList"();
-- CodeLists in SO
CREATE TRIGGER "ins_upd_SO_PlanArt" BEFORE INSERT OR UPDATE ON "SO_Basisobjekte"."SO_PlanArt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isCodeList"();
GRANT ALL ON TABLE "SO_Basisobjekte"."SO_SonstRechtscharakter" TO so_user;
CREATE TRIGGER "ins_upd_SO_SonstRechtscharakter" BEFORE INSERT OR UPDATE ON "SO_Basisobjekte"."SO_SonstRechtscharakter" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isCodeList"();
CREATE TRIGGER "ins_upd_SO_DetailKlassifizNachStrassenverkehrsrecht" BEFORE INSERT OR UPDATE ON "SO_NachrichtlicheUebernahmen"."SO_DetailKlassifizNachStrassenverkehrsrecht" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isCodeList"();
CREATE TRIGGER "ins_upd_SO_DetailKlassifizNachSchienenverkehrsrecht" BEFORE INSERT OR UPDATE ON "SO_NachrichtlicheUebernahmen"."SO_DetailKlassifizNachSchienenverkehrsrecht" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isCodeList"();
CREATE TRIGGER "ins_upd_SO_DetailKlassifizNachLuftverkehrsrecht" BEFORE INSERT OR UPDATE ON "SO_NachrichtlicheUebernahmen"."SO_DetailKlassifizNachLuftverkehrsrecht" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isCodeList"();
CREATE TRIGGER "ins_upd_SO_DetailKlassifizNachWasserrecht" BEFORE INSERT OR UPDATE ON "SO_NachrichtlicheUebernahmen"."SO_DetailKlassifizNachWasserrecht" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isCodeList"();
CREATE TRIGGER "ins_upd_SO_DetailKlassifizNachDenkmalschutzrecht" BEFORE INSERT OR UPDATE ON "SO_NachrichtlicheUebernahmen"."SO_DetailKlassifizNachDenkmalschutzrecht" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isCodeList"();
CREATE TRIGGER "ins_upd_SO_DetailKlassifizGewaesser" BEFORE INSERT OR UPDATE ON "SO_NachrichtlicheUebernahmen"."SO_DetailKlassifizGewaesser" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isCodeList"();
CREATE TRIGGER "ins_upd_SO_DetailKlassifizNachForstrecht" BEFORE INSERT OR UPDATE ON "SO_NachrichtlicheUebernahmen"."SO_DetailKlassifizNachForstrecht" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isCodeList"();
CREATE TRIGGER "ins_upd_SO_DetailKlassifizNachBodenschutzrecht" BEFORE INSERT OR UPDATE ON "SO_NachrichtlicheUebernahmen"."SO_DetailKlassifizNachBodenschutzrecht" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isCodeList"();
CREATE TRIGGER "ins_upd_SO_DetailKlassifizNachSonstigemRecht" BEFORE INSERT OR UPDATE ON "SO_NachrichtlicheUebernahmen"."SO_DetailKlassifizNachSonstigemRecht" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isCodeList"();
CREATE TRIGGER "ins_upd_SO_DetailKlassifizBauverbot" BEFORE INSERT OR UPDATE ON "SO_NachrichtlicheUebernahmen"."SO_DetailKlassifizBauverbot" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isCodeList"();
CREATE TRIGGER "ins_upd_SO_DetailKlassifizSchutzgebietNaturschutzrecht" BEFORE INSERT OR UPDATE ON "SO_Schutzgebiete"."SO_DetailKlassifizSchutzgebietNaturschutzrecht" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isCodeList"();
CREATE TRIGGER "ins_upd_SO_DetailKlassifizSchutzgebietSonstRecht" BEFORE INSERT OR UPDATE ON "SO_Schutzgebiete"."SO_DetailKlassifizSchutzgebietSonstRecht" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isCodeList"();
CREATE TRIGGER "ins_upd_SO_DetailKlassifizSchutzgebietWasserrecht" BEFORE INSERT OR UPDATE ON "SO_Schutzgebiete"."SO_DetailKlassifizSchutzgebietWasserrecht" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isCodeList"();
CREATE TRIGGER "ins_upd_SO_SonstGebietsArt" BEFORE INSERT OR UPDATE ON "SO_SonstigeGebiete"."SO_SonstGebietsArt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isCodeList"();
CREATE TRIGGER "ins_upd_SO_SonstRechtsstandGebietTyp" BEFORE INSERT OR UPDATE ON "SO_SonstigeGebiete"."SO_SonstRechtsstandGebietTyp" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isCodeList"();
CREATE TRIGGER "ins_upd_SO_SonstGrenzeTypen" BEFORE INSERT OR UPDATE ON "SO_Sonstiges"."SO_SonstGrenzeTypen" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isCodeList"();

-- lösche Autowerttrigger auf XP_MimeTypes
DROP TRIGGER IF EXISTS "ins_upd_XP_MimeTypes" ON "XP_Basisobjekte"."XP_MimeTypes";

-- referenziere auf XP_ExterneReferenz anstatt auf XP_SpezExterneReferenz
ALTER TABLE "XP_Basisobjekte"."XP_Bereich_refScan" DROP CONSTRAINT "fk_XP_Bereich_refScan_XP_ExterneReferenz";
ALTER TABLE "XP_Basisobjekte"."XP_Bereich_refScan" ADD CONSTRAINT "fk_XP_Bereich_refScan_XP_ExterneReferenz" FOREIGN KEY ("externeReferenz" )
    REFERENCES "XP_Basisobjekte"."XP_ExterneReferenz" ("id" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE;

-- korrigiere Rechtschreibfehler
ALTER TABLE "FP_Basisobjekte"."FP_Plan" RENAME "aufstellungsbechlussDatum" TO "aufstellungsbeschlussDatum";
COMMENT ON COLUMN "FP_Basisobjekte"."FP_Plan"."aufstellungsbeschlussDatum" IS 'Datum des Plan-Aufstellungsbeschlusses.';

-- ändere datentyp varchar(255) zu text
-- -----------------------------------------------------
-- Table "XP_Basisobjekte"."XP_Objekt"
-- -----------------------------------------------------
ALTER TABLE "XP_Basisobjekte"."XP_Objekt" ALTER COLUMN "text" SET DATA TYPE text;


-- füge fehlendes Attribut XP_Objekt.refBegruendungInhalt ein
-- -----------------------------------------------------
-- Table "XP_Basisobjekte"."XP_Objekt_refBegruendungInhalt"
-- -----------------------------------------------------
CREATE TABLE "XP_Basisobjekte"."XP_Objekt_refBegruendungInhalt" (
  "XP_Objekt_gid" BIGINT NOT NULL ,
  "refBegruendungInhalt" INTEGER NOT NULL ,
  PRIMARY KEY ("XP_Objekt_gid", "refBegruendungInhalt") ,
  CONSTRAINT "fk_XP_Objekt_refBegruendungInhalt_XP_Objekt1"
    FOREIGN KEY ("XP_Objekt_gid" )
    REFERENCES "XP_Basisobjekte"."XP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_XP_Objekt_refBegruendungInhalt_XP_BegruendungAbschnitt1"
    FOREIGN KEY ("refBegruendungInhalt" )
    REFERENCES "XP_Basisobjekte"."XP_BegruendungAbschnitt" ("id" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
COMMENT ON TABLE "XP_Basisobjekte"."XP_Objekt_refBegruendungInhalt" IS 'Referenz eines raumbezogenen Fachobjektes auf Teile der Begründung.';
CREATE INDEX "idx_fk_refBegruendungInhalt_XP_Objekt1" ON "XP_Basisobjekte"."XP_Objekt_refBegruendungInhalt" ("XP_Objekt_gid") ;
CREATE INDEX "idx_fk_refBegruendungInhalt_XP_BegruendungAbschnitt1" ON "XP_Basisobjekte"."XP_Objekt_refBegruendungInhalt" ("refBegruendungInhalt") ;

GRANT SELECT ON TABLE "XP_Basisobjekte"."XP_Objekt_refBegruendungInhalt" TO xp_gast;
GRANT ALL ON TABLE "XP_Basisobjekte"."XP_Objekt_refBegruendungInhalt" TO xp_user;

-- Änderungen zu 5.2.1
ALTER TABLE "BP_Bebauung"."BP_Dachgestaltung" RENAME "DNZwingend" TO "DNzwingend";

-- füge fehlendes Attribut FP_Ausgleichsflaeche.sonstZiel ein
ALTER TABLE "FP_Naturschutz"."FP_AusgleichsFlaeche" ADD COLUMN "sonstZiel" VARCHAR (255);
COMMENT ON COLUMN "FP_Naturschutz"."FP_AusgleichsFlaeche"."sonstZiel" IS 'Textlich formuliertes Ziel, wenn das Attribut ziel den Wert 9999 (Sonstiges) hat.';

-- passe Feldgröße an Feld name in XP_Plan an
ALTER TABLE "XP_Basisobjekte"."XP_VerbundenerPlan" ALTER COLUMN "planName" TYPE character varying(256);

-- vergrössere Feld
ALTER TABLE "BP_Sonstiges"."BP_Wegerecht" ALTER COLUMN "zugunstenVon" TYPE character varying(256);

--
-- Korrektur Column Type von "Code" und "planArt" in "SO_Basisobjekte"."SO_Plan" bzw. "SO_Basisobjekte"."SO_PlanArt"
ALTER TABLE "SO_Basisobjekte"."SO_Plan" DROP CONSTRAINT "fk_SO_Plan_planArt";

ALTER TABLE "SO_Basisobjekte"."SO_Plan" ALTER COLUMN "planArt" TYPE integer USING "planArt"::integer;
ALTER TABLE "SO_Basisobjekte"."SO_PlanArt" ALTER COLUMN "Code" TYPE integer USING "Code"::integer;

ALTER TABLE "SO_Basisobjekte"."SO_Plan" ADD CONSTRAINT "fk_SO_Plan_planArt" FOREIGN KEY ("planArt")
    REFERENCES "SO_Basisobjekte"."SO_PlanArt" ("Code") MATCH SIMPLE
    ON UPDATE CASCADE ON DELETE NO ACTION;

-- fehlgeschlagenes Insert in "SO_Basisobjekte""."SO_PlanArt" nachholen
DROP TRIGGER "ins_upd_SO_PlanArt" ON "SO_Basisobjekte"."SO_PlanArt";

INSERT INTO "SO_Basisobjekte"."SO_PlanArt" ("Code", "Bezeichner") VALUES (9999, 'Sonstiges');

CREATE TRIGGER "ins_upd_SO_PlanArt" BEFORE INSERT OR UPDATE ON "SO_Basisobjekte"."SO_PlanArt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isCodeList"();

-- Ändere Felder in Arrays
ALTER TABLE "XP_Praesentationsobjekte"."XP_APObjekt_dientZurDarstellungVon" DROP CONSTRAINT "XP_APObjekt_dientZurDarstellungVon_pkey";
ALTER TABLE "XP_Praesentationsobjekte"."XP_APObjekt_dientZurDarstellungVon"
  ADD CONSTRAINT "XP_APObjekt_dientZurDarstellungVon_pkey" PRIMARY KEY("XP_APObjekt_gid", "dientZurDarstellungVon");

ALTER TABLE "XP_Praesentationsobjekte"."XP_APObjekt_dientZurDarstellungVon" rename art TO art_alt;
ALTER TABLE "XP_Praesentationsobjekte"."XP_APObjekt_dientZurDarstellungVon" ADD COLUMN "art" VARCHAR(64)[] NOT NULL DEFAULT '{"text"}';
COMMENT ON COLUMN "XP_Praesentationsobjekte"."XP_APObjekt_dientZurDarstellungVon"."art" IS '"Art" gibt den Namen des Attributs an, das mit dem Präsentationsobjekt dargestellt werden soll.
Die Attributart "Art" darf im Regelfall nur bei "Freien Präsentationsobjekten" (dientZurDarstellungVon = NULL) nicht belegt sein.';
UPDATE "XP_Praesentationsobjekte"."XP_APObjekt_dientZurDarstellungVon" SET art = ARRAY [art_alt] WHERE art_alt IS NOT NULL;
ALTER TABLE "XP_Praesentationsobjekte"."XP_APObjekt_dientZurDarstellungVon" DROP COLUMN art_alt;

ALTER TABLE "XP_Praesentationsobjekte"."XP_APObjekt_dientZurDarstellungVon" rename "index" TO "index_alt";
ALTER TABLE "XP_Praesentationsobjekte"."XP_APObjekt_dientZurDarstellungVon" ADD COLUMN "index" INTEGER[];
COMMENT ON COLUMN "XP_Praesentationsobjekte"."XP_APObjekt_dientZurDarstellungVon"."index" IS 'Wenn das Attribut art des Fachobjektes mehrfach belegt ist gibt index an, auf welche Instanz des Attributs sich das Präsentationsobjekt bezieht. Indexnummern beginnen dabei immer mit 0.';
UPDATE "XP_Praesentationsobjekte"."XP_APObjekt_dientZurDarstellungVon" SET "index" = ARRAY ["index_alt"] WHERE "index_alt" IS NOT NULL;
ALTER TABLE "XP_Praesentationsobjekte"."XP_APObjekt_dientZurDarstellungVon" DROP COLUMN "index_alt";

-- Zeige auch TPOs ohne Ausrichtung
CREATE OR REPLACE VIEW "XP_Praesentationsobjekte"."XP_TPO_qv" AS
SELECT p.*, b."schriftinhalt", b."fontSperrung",
  b."skalierung", COALESCE(ha."Bezeichner",'left')::varchar(64) as "horizontaleAusrichtung", COALESCE(va."Bezeichner",'Half')::varchar(64) as "vertikaleAusrichtung"
FROM "XP_Praesentationsobjekte"."XP_TPO" b
    JOIN "QGIS"."HorizontaleAusrichtung" ha ON b."horizontaleAusrichtung" = ha."Code"
    LEFT JOIN "QGIS"."VertikaleAusrichtung" va ON b."vertikaleAusrichtung" = va."Code"
    LEFT JOIN "XP_Praesentationsobjekte"."XP_AbstraktesPraesentationsobjekt_qv" p ON b.gid = p.gid;
GRANT SELECT ON TABLE "XP_Praesentationsobjekte"."XP_TPO_qv" TO xp_gast;

-- ziehe rechtscharakter in XP_VerbundenerPlan hinein, wie im Standard
ALTER TABLE "XP_Basisobjekte"."XP_VerbundenerPlan" ADD COLUMN "rechtscharakter" INTEGER;
UPDATE "XP_Basisobjekte"."XP_VerbundenerPlan" SET "rechtscharakter" = 1000;
ALTER TABLE "XP_Basisobjekte"."XP_VerbundenerPlan" ALTER COLUMN rechtscharakter SET NOT NULL;
ALTER TABLE "XP_Basisobjekte"."XP_VerbundenerPlan" ALTER COLUMN rechtscharakter SET DEFAULT 1000;
ALTER TABLE "XP_Basisobjekte"."XP_VerbundenerPlan" ADD CONSTRAINT "fk_XP_VerbundenerPlan_XP_RechtscharakterPlanaenderung1"
    FOREIGN KEY ("rechtscharakter" )
    REFERENCES "XP_Basisobjekte"."XP_RechtscharakterPlanaenderung" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE;
COMMENT ON COLUMN "XP_Basisobjekte"."XP_VerbundenerPlan"."rechtscharakter" IS 'Rechtscharakter der Planänderung.';
UPDATE "XP_Basisobjekte"."XP_VerbundenerPlan" vp SET "rechtscharakter" =
  (SELECT "rechtscharakter" FROM "XP_Basisobjekte"."XP_Plan_aendert" a WHERE a."aendert" = vp."verbundenerPlan")
  WHERE vp."verbundenerPlan" IN (SELECT "aendert" FROM "XP_Basisobjekte"."XP_Plan_aendert");
UPDATE "XP_Basisobjekte"."XP_VerbundenerPlan" vp SET "rechtscharakter" =
  (SELECT "rechtscharakter" FROM "XP_Basisobjekte"."XP_Plan_wurdeGeaendertVon" a WHERE a."wurdeGeaendertVon" = vp."verbundenerPlan")
  WHERE vp."verbundenerPlan" IN (SELECT "wurdeGeaendertVon" FROM "XP_Basisobjekte"."XP_Plan_wurdeGeaendertVon");
ALTER TABLE "XP_Basisobjekte"."XP_Plan_aendert" DROP COLUMN "rechtscharakter";
ALTER TABLE "XP_Basisobjekte"."XP_Plan_wurdeGeaendertVon" DROP COLUMN "rechtscharakter";

-- synchronisiere XP_Plan und XP_VerbundenerPlan
CREATE OR REPLACE FUNCTION "XP_Basisobjekte"."change_to_XP_Plan"()
RETURNS trigger AS
$BODY$
 BEGIN
    IF (TG_OP = 'INSERT') THEN
        INSERT INTO "XP_Basisobjekte"."XP_VerbundenerPlan"("verbundenerPlan", "planName", "nummer") VALUES(new.gid, new."name", new."nummer");
        RETURN new;
    ELSIF (TG_OP = 'UPDATE') THEN
        new.gid := old.gid; --no change in gid allowed
        UPDATE "XP_Basisobjekte"."XP_VerbundenerPlan" SET "planName" = new."name" WHERE "verbundenerPlan" = old.gid;
        UPDATE "XP_Basisobjekte"."XP_VerbundenerPlan" SET "nummer" = new."nummer" WHERE "verbundenerPlan" = old.gid;
        RETURN new;
    ELSIF (TG_OP = 'DELETE') THEN
        DELETE FROM "XP_Basisobjekte"."XP_VerbundenerPlan" WHERE "verbundenerPlan" = old.gid;
        RETURN old;
    END IF;
 END; $BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
GRANT EXECUTE ON FUNCTION "XP_Basisobjekte"."change_to_XP_Plan"() TO xp_user;

CREATE OR REPLACE FUNCTION "XP_Basisobjekte"."change_to_XP_VerbundenerPlan"()
RETURNS trigger AS
$BODY$
 BEGIN
    IF (TG_OP = 'INSERT') THEN
    new."planName" := COALESCE(new."planName",'kein Name in XP_VerbundenerPlan');

    IF NEW."verbundenerPlan" IS NULL THEN
      INSERT INTO "XP_Basisobjekte"."XP_Plan" ("name","nummer") VALUES(new."planName", new."nummer");
      RETURN NULL;
    ELSE
      RETURN new;
    END IF;
    ELSIF (TG_OP = 'UPDATE') THEN
        new."verbundenerPlan" := old."verbundenerPlan"; --no change in gid allowed

        IF pg_trigger_depth() = 1 THEN
        -- UPDATE-Statement wird nicht über den Trigger change_to_XP_Plan aufgerufen, sondern das UPDATE erfolgt direkt auf XP_VerbundenerPlan
      new."planName" := old."planName";
      new."nummer" := old."nummer";
    END IF;

        RETURN new;
    END IF;
 END; $BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
GRANT EXECUTE ON FUNCTION "XP_Basisobjekte"."change_to_XP_VerbundenerPlan"() TO xp_user;
CREATE TRIGGER "XP_VerbundenerPlan_InsUpd" BEFORE INSERT OR UPDATE ON "XP_Basisobjekte"."XP_VerbundenerPlan" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."change_to_XP_VerbundenerPlan"();
GRANT SELECT ON TABLE "XP_Basisobjekte"."XP_VerbundenerPlan" TO xp_gast;
