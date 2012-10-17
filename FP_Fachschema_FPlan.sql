

-- -----------------------------------------------------
-- Table "FP_Basisobjekte"."FP_SonstPlanArt"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Basisobjekte"."FP_SonstPlanArt" (
  "Wert" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(255) NOT NULL ,
  PRIMARY KEY ("Wert") )
;


-- -----------------------------------------------------
-- Table "FP_Basisobjekte"."FP_Verfahren"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Basisobjekte"."FP_Verfahren" (
  "Wert" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(255) NOT NULL ,
  PRIMARY KEY ("Wert") )
;


-- -----------------------------------------------------
-- Table "FP_Basisobjekte"."FP_Status"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Basisobjekte"."FP_Status" (
  "Wert" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(255) NOT NULL ,
  PRIMARY KEY ("Wert") )
;


-- -----------------------------------------------------
-- Table "FP_Basisobjekte"."FP_Rechtsstand"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Basisobjekte"."FP_Rechtsstand" (
  "Wert" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(255) NOT NULL ,
  PRIMARY KEY ("Wert") )
;


-- -----------------------------------------------------
-- Table "FP_Basisobjekte"."FP_Plan"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Basisobjekte"."FP_Plan" (
  "gid" INTEGER NOT NULL ,
  "raeumlicherGeltungsbereich" GEOMETRY NULL ,
  "plangeber" INTEGER NULL ,
  "sonstPlanArt" INTEGER NULL ,
  "verfahren" INTEGER NULL ,
  "rechtsstand" INTEGER NULL ,
  "status" INTEGER NULL ,
  "aufstellungsbechlussDatum" DATE NULL ,
  "auslegungsStartDatum" DATE NULL ,
  "auslegungsEndDatum" DATE NULL ,
  "traegerbeteiligungsStartDatum" DATE NULL ,
  "traegerbeteiligungsEndDatum" DATE NULL ,
  "aenderungenBisDatum" DATE NULL ,
  "entwurfsbeschlussDatum" DATE NULL ,
  "planbeschlussDatum" DATE NULL ,
  "wirksamkeitsDatum" DATE NULL ,
  "refUmweltbericht" INTEGER NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_fp_plan_xp_plangeber1"
    FOREIGN KEY ("plangeber" )
    REFERENCES "XP_Sonstiges"."XP_Plangeber" ("id" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_fp_plan_fp_sonstplanart1"
    FOREIGN KEY ("sonstPlanArt" )
    REFERENCES "FP_Basisobjekte"."FP_SonstPlanArt" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_fp_plan_fp_verfahren1"
    FOREIGN KEY ("verfahren" )
    REFERENCES "FP_Basisobjekte"."FP_Verfahren" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_fp_plan_fp_status1"
    FOREIGN KEY ("status" )
    REFERENCES "FP_Basisobjekte"."FP_Status" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_fp_plan_fp_rechtsstand1"
    FOREIGN KEY ("rechtsstand" )
    REFERENCES "FP_Basisobjekte"."FP_Rechtsstand" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_fp_plan_xp_externereferenz4"
    FOREIGN KEY ("refUmweltbericht" )
    REFERENCES "XP_Basisobjekte"."XP_ExterneReferenz" ("id" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_Plan_XP_Plan1"
    FOREIGN KEY ("gid" )
    REFERENCES "XP_Basisobjekte"."XP_Plan" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
;

CREATE INDEX "idx_fk_fp_plan_xp_plangeber1" ON "FP_Basisobjekte"."FP_Plan" ("plangeber") ;

CREATE INDEX "idx_fk_fp_plan_fp_sonstplanart1" ON "FP_Basisobjekte"."FP_Plan" ("sonstPlanArt") ;

CREATE INDEX "idx_fk_fp_plan_fp_verfahren1" ON "FP_Basisobjekte"."FP_Plan" ("verfahren") ;

CREATE INDEX "idx_fk_fp_plan_fp_status1" ON "FP_Basisobjekte"."FP_Plan" ("status") ;

CREATE INDEX "idx_fk_fp_plan_fp_rechtsstand1" ON "FP_Basisobjekte"."FP_Plan" ("rechtsstand") ;

CREATE INDEX "idx_fk_fp_plan_xp_externereferenz4" ON "FP_Basisobjekte"."FP_Plan" ("refUmweltbericht") ;

CREATE INDEX "idx_fk_FP_Plan_XP_Plan1" ON "FP_Basisobjekte"."FP_Plan" ("gid") ;


-- -----------------------------------------------------
-- Table "FP_Basisobjekte"."FP_PlanArt"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Basisobjekte"."FP_PlanArt" (
  "Wert" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(255) NOT NULL ,
  PRIMARY KEY ("Wert") )
;


-- -----------------------------------------------------
-- Table "FP_Basisobjekte"."planArt"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Basisobjekte"."planArt" (
  "FP_Plan_gid" INTEGER NOT NULL ,
  "FP_Planart_Wert" INTEGER NOT NULL ,
  PRIMARY KEY ("FP_Plan_gid", "FP_Planart_Wert") ,
  CONSTRAINT "fk_planArt_FP_Plan"
    FOREIGN KEY ("FP_Plan_gid" )
    REFERENCES "FP_Basisobjekte"."FP_Plan" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_planArt_FP_PlanArt"
    FOREIGN KEY ("FP_Planart_Wert" )
    REFERENCES "FP_Basisobjekte"."FP_PlanArt" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE)
;

CREATE INDEX "idx_fk_planArt_FP_Plan" ON "FP_Basisobjekte"."planArt" ("FP_Plan_gid") ;

CREATE INDEX "idx_fk_planArt_FP_PlanArt" ON "FP_Basisobjekte"."planArt" ("FP_Planart_Wert") ;


-- -----------------------------------------------------
-- Table "FP_Basisobjekte"."FP_Bereich"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Basisobjekte"."FP_Bereich" (
  "gid" INTEGER NOT NULL ,
  "geltungsbereich" GEOMETRY NULL ,
  "versionBauNVO" INTEGER NULL ,
  "versionBauNVOText" VARCHAR(255) NULL ,
  "versionBauGB" DATE NULL ,
  "versionBauGBText" VARCHAR(255) NULL ,
  "gehoertZuPlan" INTEGER NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_Bereich_FP_Plan1"
    FOREIGN KEY ("gehoertZuPlan" )
    REFERENCES "FP_Basisobjekte"."FP_Plan" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_Bereich_XP_VersionBauNVO1"
    FOREIGN KEY ("versionBauNVO" )
    REFERENCES "XP_Enumerationen"."XP_VersionBauNVO" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_Bereich_XP_Bereich1"
    FOREIGN KEY ("gid" )
    REFERENCES "XP_Basisobjekte"."XP_Bereich" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
;

CREATE INDEX "idx_fk_FP_Bereich_FP_Plan1" ON "FP_Basisobjekte"."FP_Bereich" ("gehoertZuPlan") ;

CREATE INDEX "idx_fk_FP_Bereich_XP_VersionBauNVO1" ON "FP_Basisobjekte"."FP_Bereich" ("versionBauNVO") ;

CREATE INDEX "idx_fk_FP_Bereich_XP_Bereich1" ON "FP_Basisobjekte"."FP_Bereich" ("gid") ;


-- -----------------------------------------------------
-- Table "FP_Basisobjekte"."FP_Rechtscharakter"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Basisobjekte"."FP_Rechtscharakter" (
  "Wert" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Wert") )
;


-- -----------------------------------------------------
-- Table "FP_Basisobjekte"."FP_SpezifischePraegungTypen"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Basisobjekte"."FP_SpezifischePraegungTypen" (
  "Wert" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(255) NOT NULL ,
  PRIMARY KEY ("Wert") )
;


-- -----------------------------------------------------
-- Table "FP_Basisobjekte"."FP_Objekt"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Basisobjekte"."FP_Objekt" (
  "gid" INTEGER NOT NULL ,
  "rechtscharakter" INTEGER NULL ,
  "spezifischePraegung" INTEGER NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_bp_objekt_bp_rechtscharakter1"
    FOREIGN KEY ("rechtscharakter" )
    REFERENCES "FP_Basisobjekte"."FP_Rechtscharakter" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT "fk_BP_Objekt_XP_Objekt1"
    FOREIGN KEY ("gid" )
    REFERENCES "XP_Basisobjekte"."XP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_Objekt_FP_SpezifischePraegungTypen1"
    FOREIGN KEY ("spezifischePraegung" )
    REFERENCES "FP_Basisobjekte"."FP_SpezifischePraegungTypen" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
;

CREATE INDEX "idx_fk_bp_objekt_bp_rechtscharakter1" ON "FP_Basisobjekte"."FP_Objekt" ("rechtscharakter") ;

CREATE INDEX "idx_fk_BP_Objekt_XP_Objekt1" ON "FP_Basisobjekte"."FP_Objekt" ("gid") ;

CREATE INDEX "idx_fk_FP_Objekt_FP_SpezifischePraegungTypen1" ON "FP_Basisobjekte"."FP_Objekt" ("spezifischePraegung") ;


-- -----------------------------------------------------
-- Table "FP_Basisobjekte"."gehoertZuFP_Bereich"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Basisobjekte"."gehoertZuFP_Bereich" (
  "FP_Bereich_gid" INTEGER NOT NULL ,
  "FP_Objekt_gid" INTEGER NOT NULL ,
  PRIMARY KEY ("FP_Bereich_gid", "FP_Objekt_gid") ,
  CONSTRAINT "fk_gehoertzuFP_Bereich_FP_Bereich1"
    FOREIGN KEY ("FP_Bereich_gid" )
    REFERENCES "FP_Basisobjekte"."FP_Bereich" ("gid" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_gehoertZuFP_Bereich_FP_Objekt1"
    FOREIGN KEY ("FP_Objekt_gid" )
    REFERENCES "FP_Basisobjekte"."FP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
;

CREATE INDEX "idx_fk_gehoertzuFP_Bereich_FP_Bereich1" ON "FP_Basisobjekte"."gehoertZuFP_Bereich" ("FP_Bereich_gid") ;

CREATE INDEX "idx_fk_gehoertZuFP_Bereich_FP_Objekt1" ON "FP_Basisobjekte"."gehoertZuFP_Bereich" ("FP_Objekt_gid") ;


-- -----------------------------------------------------
-- Table "FP_Basisobjekte"."gemeinde"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Basisobjekte"."gemeinde" (
  "BP_Plan_gid" INTEGER NOT NULL ,
  "XP_Gemeinde_id" INTEGER NOT NULL ,
  PRIMARY KEY ("BP_Plan_gid", "XP_Gemeinde_id") ,
  CONSTRAINT "fk_gemeinde_BP_Plan1"
    FOREIGN KEY ("BP_Plan_gid" )
    REFERENCES "FP_Basisobjekte"."FP_Plan" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_gemeinde_XP_Gemeinde1"
    FOREIGN KEY ("XP_Gemeinde_id" )
    REFERENCES "XP_Sonstiges"."XP_Gemeinde" ("id" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE)
;

CREATE INDEX "idx_fk_gemeinde_BP_Plan1" ON "FP_Basisobjekte"."gemeinde" ("BP_Plan_gid") ;

CREATE INDEX "idx_fk_gemeinde_XP_Gemeinde1" ON "FP_Basisobjekte"."gemeinde" ("XP_Gemeinde_id") ;


-- -----------------------------------------------------
-- Table "FP_Raster"."FP_RasterplanAenderung"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Raster"."FP_RasterplanAenderung" (
  "gid" INTEGER NOT NULL ,
  "geltungsbereichAenderung" GEOMETRY NULL ,
  "aenderungenBisDatum" DATE NULL ,
  "entwurfsbeschlussDatum" DATE NULL ,
  "planbeschlussDatum" DATE NULL ,
  "wirksamkeitsDatum" DATE NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_BP_RasterplanAenderung1"
    FOREIGN KEY ("gid" )
    REFERENCES "XP_Raster"."XP_RasterplanAenderung" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
;

CREATE INDEX "idx_fk_BP_RasterplanAenderung1" ON "FP_Raster"."FP_RasterplanAenderung" ("gid") ;


-- -----------------------------------------------------
-- Table "FP_Basisobjekte"."rasterAenderung"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Basisobjekte"."rasterAenderung" (
  "FP_Bereich_gid" INTEGER NOT NULL ,
  "FP_RasterplanAenderung_gid" INTEGER NOT NULL ,
  PRIMARY KEY ("FP_Bereich_gid", "FP_RasterplanAenderung_gid") ,
  CONSTRAINT "fk_rasterAenderung_FP_Bereich"
    FOREIGN KEY ("FP_Bereich_gid" )
    REFERENCES "FP_Basisobjekte"."FP_Bereich" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_rasterAenderung_FP_RasterplanAenderung"
    FOREIGN KEY ("FP_RasterplanAenderung_gid" )
    REFERENCES "FP_Raster"."FP_RasterplanAenderung" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
;

CREATE INDEX "idx_fk_rasterAenderung_FP_Bereich" ON "FP_Basisobjekte"."rasterAenderung" ("FP_Bereich_gid") ;

CREATE INDEX "idx_fk_rasterAenderung_FP_RasterplanAenderung" ON "FP_Basisobjekte"."rasterAenderung" ("FP_RasterplanAenderung_gid") ;


-- -----------------------------------------------------
-- Table "FP_Basisobjekte"."FP_Punktobjekt"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Basisobjekte"."FP_Punktobjekt" (
  "gid" INTEGER NOT NULL ,
  "position" GEOMETRY NOT NULL ,
  PRIMARY KEY ("gid") )
;


-- -----------------------------------------------------
-- Table "FP_Basisobjekte"."FP_Linienobjekt"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Basisobjekte"."FP_Linienobjekt" (
  "gid" INTEGER NOT NULL ,
  "position" GEOMETRY NOT NULL ,
  PRIMARY KEY ("gid") )
;


-- -----------------------------------------------------
-- Table "FP_Basisobjekte"."FP_Flaechenobjekt"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Basisobjekte"."FP_Flaechenobjekt" (
  "gid" INTEGER NOT NULL ,
  "position" GEOMETRY NOT NULL ,
  "flaechenschluss" BOOLEAN  NOT NULL ,
  PRIMARY KEY ("gid") )
;


-- -----------------------------------------------------
-- Table "FP_Naturschutz"."FP_AusgleichsFlaeche"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Naturschutz"."FP_AusgleichsFlaeche" (
  "gid" INTEGER NOT NULL ,
  "ziel" INTEGER NULL ,
  "massnahme" INTEGER NULL ,
  "weitereMassnahme1" INTEGER NULL ,
  "weitereMassnahme2" INTEGER NULL ,
  "istAusgleich" BOOLEAN  NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_AusgleichsFlaeche_XP_SPEZiele1"
    FOREIGN KEY ("ziel" )
    REFERENCES "XP_Sonstiges"."XP_SPEZiele" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_AusgleichsFlaeche_XP_SPEMassnahmenDaten1"
    FOREIGN KEY ("massnahme" )
    REFERENCES "XP_Sonstiges"."XP_SPEMassnahmenDaten" ("id" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_AusgleichsFlaeche_XP_SPEMassnahmenDaten2"
    FOREIGN KEY ("weitereMassnahme1" )
    REFERENCES "XP_Sonstiges"."XP_SPEMassnahmenDaten" ("id" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_AusgleichsFlaeche_XP_SPEMassnahmenDaten3"
    FOREIGN KEY ("weitereMassnahme2" )
    REFERENCES "XP_Sonstiges"."XP_SPEMassnahmenDaten" ("id" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_AusgleichsFlaeche_FP_Objekt1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Basisobjekte"."FP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
;

CREATE INDEX "idx_fk_FP_SchutzPflegeEntwicklung_XP_SPEZiele" ON "FP_Naturschutz"."FP_AusgleichsFlaeche" ("ziel") ;

CREATE INDEX "idx_fk_FP_SchutzPflegeEntwicklung_XP_SPEMassnahmenDaten1" ON "FP_Naturschutz"."FP_AusgleichsFlaeche" ("massnahme") ;

CREATE INDEX "idx_fk_FP_SchutzPflegeEntwicklung_XP_SPEMassnahmenDaten2" ON "FP_Naturschutz"."FP_AusgleichsFlaeche" ("weitereMassnahme1") ;

CREATE INDEX "idx_fk_FP_SchutzPflegeEntwicklung_XP_SPEMassnahmenDaten3" ON "FP_Naturschutz"."FP_AusgleichsFlaeche" ("weitereMassnahme2") ;

CREATE INDEX "idx_fk_FP_SchutzPflegeEntwicklung_FP_Objekt1" ON "FP_Naturschutz"."FP_AusgleichsFlaeche" ("gid") ;


-- -----------------------------------------------------
-- Table "FP_Basisobjekte"."wirdAusgeglichenDurchFlaeche"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Basisobjekte"."wirdAusgeglichenDurchFlaeche" (
  "FP_Objekt_gid" INTEGER NOT NULL ,
  "FP_AusgleichsFlaeche_gid" INTEGER NOT NULL ,
  PRIMARY KEY ("FP_Objekt_gid", "FP_AusgleichsFlaeche_gid") ,
  CONSTRAINT "fk_wirdAusgeglichenDurchFlaeche1"
    FOREIGN KEY ("FP_Objekt_gid" )
    REFERENCES "FP_Basisobjekte"."FP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_wirdAusgeglichenDurchFlaeche2"
    FOREIGN KEY ("FP_AusgleichsFlaeche_gid" )
    REFERENCES "FP_Naturschutz"."FP_AusgleichsFlaeche" ("gid" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE)
;

CREATE INDEX "idx_fk_wirdAusgeglichenDurchFlaeche1" ON "FP_Basisobjekte"."wirdAusgeglichenDurchFlaeche" ("FP_Objekt_gid") ;

CREATE INDEX "idx_fk_wirdAusgeglichenDurchFlaeche2" ON "FP_Basisobjekte"."wirdAusgeglichenDurchFlaeche" ("FP_AusgleichsFlaeche_gid") ;


-- -----------------------------------------------------
-- Table "FP_Naturschutz"."FP_SchutzPflegeEntwicklung"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Naturschutz"."FP_SchutzPflegeEntwicklung" (
  "gid" INTEGER NOT NULL ,
  "ziel" INTEGER NULL ,
  "massnahme" INTEGER NULL ,
  "weitereMassnahme1" INTEGER NULL ,
  "weitereMassnahme2" INTEGER NULL ,
  "istAusgleich" BOOLEAN  NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_SchutzPflegeEntwicklung_XP_SPEZiele"
    FOREIGN KEY ("ziel" )
    REFERENCES "XP_Sonstiges"."XP_SPEZiele" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_SchutzPflegeEntwicklung_XP_SPEMassnahmenDaten1"
    FOREIGN KEY ("massnahme" )
    REFERENCES "XP_Sonstiges"."XP_SPEMassnahmenDaten" ("id" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_SchutzPflegeEntwicklung_XP_SPEMassnahmenDaten2"
    FOREIGN KEY ("weitereMassnahme1" )
    REFERENCES "XP_Sonstiges"."XP_SPEMassnahmenDaten" ("id" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_SchutzPflegeEntwicklung_XP_SPEMassnahmenDaten3"
    FOREIGN KEY ("weitereMassnahme2" )
    REFERENCES "XP_Sonstiges"."XP_SPEMassnahmenDaten" ("id" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_SchutzPflegeEntwicklung_FP_Objekt1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Basisobjekte"."FP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
;

CREATE INDEX "idx_fk_FP_SchutzPflegeEntwicklung_XP_SPEZiele" ON "FP_Naturschutz"."FP_SchutzPflegeEntwicklung" ("ziel") ;

CREATE INDEX "idx_fk_FP_SchutzPflegeEntwicklung_XP_SPEMassnahmenDaten1" ON "FP_Naturschutz"."FP_SchutzPflegeEntwicklung" ("massnahme") ;

CREATE INDEX "idx_fk_FP_SchutzPflegeEntwicklung_XP_SPEMassnahmenDaten2" ON "FP_Naturschutz"."FP_SchutzPflegeEntwicklung" ("weitereMassnahme1") ;

CREATE INDEX "idx_fk_FP_SchutzPflegeEntwicklung_XP_SPEMassnahmenDaten3" ON "FP_Naturschutz"."FP_SchutzPflegeEntwicklung" ("weitereMassnahme2") ;

CREATE INDEX "idx_fk_FP_SchutzPflegeEntwicklung_FP_Objekt1" ON "FP_Naturschutz"."FP_SchutzPflegeEntwicklung" ("gid") ;


-- -----------------------------------------------------
-- Table "FP_Basisobjekte"."wirdAusgeglichenDurchSPE"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Basisobjekte"."wirdAusgeglichenDurchSPE" (
  "FP_Objekt_gid" INTEGER NOT NULL ,
  "FP_SchutzPflegeEntwicklung_gid" INTEGER NOT NULL ,
  PRIMARY KEY ("FP_Objekt_gid", "FP_SchutzPflegeEntwicklung_gid") ,
  CONSTRAINT "fk_wirdAusgeglichenDurchSPE1"
    FOREIGN KEY ("FP_Objekt_gid" )
    REFERENCES "FP_Basisobjekte"."FP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_wirdAusgeglichenDurchSPE2"
    FOREIGN KEY ("FP_SchutzPflegeEntwicklung_gid" )
    REFERENCES "FP_Naturschutz"."FP_SchutzPflegeEntwicklung" ("gid" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE)
;

CREATE INDEX "idx_fk_wirdAusgeglichenDurchSPE1" ON "FP_Basisobjekte"."wirdAusgeglichenDurchSPE" ("FP_Objekt_gid") ;

CREATE INDEX "idx_fk_wirdAusgeglichenDurchSPE2" ON "FP_Basisobjekte"."wirdAusgeglichenDurchSPE" ("FP_SchutzPflegeEntwicklung_gid") ;


-- -----------------------------------------------------
-- Table "FP_Raster"."auslegungsStartDatum"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Raster"."auslegungsStartDatum" (
  "BP_RasterplanAenderung_id" INTEGER NOT NULL ,
  "auslegungsStartDatum" DATE NOT NULL ,
  PRIMARY KEY ("BP_RasterplanAenderung_id", "auslegungsStartDatum") ,
  CONSTRAINT "fk_auslegungsStartDatum_FP_RasterplanAenderung"
    FOREIGN KEY ("BP_RasterplanAenderung_id" )
    REFERENCES "FP_Raster"."FP_RasterplanAenderung" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
;

CREATE INDEX "idx_fk_auslegungsStartDatum_FP_RasterplanAenderung" ON "FP_Raster"."auslegungsStartDatum" ("BP_RasterplanAenderung_id") ;


-- -----------------------------------------------------
-- Table "FP_Raster"."auslegungsEndDatum"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Raster"."auslegungsEndDatum" (
  "auslegungsEndDatum" DATE NOT NULL ,
  "BP_RasterplanAenderung_id" INTEGER NOT NULL ,
  PRIMARY KEY ("auslegungsEndDatum", "BP_RasterplanAenderung_id") ,
  CONSTRAINT "fk_auslegungsEndDatum_FP_RasterplanAenderung1"
    FOREIGN KEY ("BP_RasterplanAenderung_id" )
    REFERENCES "FP_Raster"."FP_RasterplanAenderung" ("gid" )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
;

CREATE INDEX "idx_fk_auslegungsEndDatum_FP_RasterplanAenderung1" ON "FP_Raster"."auslegungsEndDatum" ("BP_RasterplanAenderung_id") ;


-- -----------------------------------------------------
-- Table "FP_Raster"."traegerbeteiligungsStartDatum"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Raster"."traegerbeteiligungsStartDatum" (
  "traegerbeteiligungsStartDatum" DATE NOT NULL ,
  "BP_RasterplanAenderung_id" INTEGER NOT NULL ,
  PRIMARY KEY ("traegerbeteiligungsStartDatum", "BP_RasterplanAenderung_id") ,
  CONSTRAINT "fk_traegerbeteiligungsStartDatum_FP_RasterplanAenderung1"
    FOREIGN KEY ("BP_RasterplanAenderung_id" )
    REFERENCES "FP_Raster"."FP_RasterplanAenderung" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
;

CREATE INDEX "idx_fk_traegerbeteiligungsStartDatum_FP_RasterplanAenderung1" ON "FP_Raster"."traegerbeteiligungsStartDatum" ("BP_RasterplanAenderung_id") ;


-- -----------------------------------------------------
-- Table "FP_Raster"."traegerbeteiligungsEndDatum"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Raster"."traegerbeteiligungsEndDatum" (
  "traegerbeteiligungsEndDatum" DATE NOT NULL ,
  "BP_RasterplanAenderung_id" INTEGER NOT NULL ,
  PRIMARY KEY ("traegerbeteiligungsEndDatum", "BP_RasterplanAenderung_id") ,
  CONSTRAINT "fk_traegerbeteiligungsEndDatum_FP_RasterplanAenderung1"
    FOREIGN KEY ("BP_RasterplanAenderung_id" )
    REFERENCES "FP_Raster"."FP_RasterplanAenderung" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
;

CREATE INDEX "idx_fk_traegerbeteiligungsEndDatum_FP_RasterplanAenderung1" ON "FP_Raster"."traegerbeteiligungsEndDatum" ("BP_RasterplanAenderung_id") ;


-- -----------------------------------------------------
-- Table "FP_Naturschutz"."FP_SchutzPflegeEntwicklungPunkt"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Naturschutz"."FP_SchutzPflegeEntwicklungPunkt" (
  "gid" INTEGER NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_SchutzPflegeEntwicklungPunkt1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Naturschutz"."FP_SchutzPflegeEntwicklung" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
;

CREATE INDEX "idx_fk_FP_SchutzPflegeEntwicklungPunkt1" ON "FP_Naturschutz"."FP_SchutzPflegeEntwicklungPunkt" ("gid") ;


-- -----------------------------------------------------
-- Table "FP_Naturschutz"."FP_SchutzPflegeEntwicklungLinie"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Naturschutz"."FP_SchutzPflegeEntwicklungLinie" (
  "gid" INTEGER NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_SchutzPflegeEntwicklungLinie"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Naturschutz"."FP_SchutzPflegeEntwicklung" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
;

CREATE INDEX "idx_fk_FP_SchutzPflegeEntwicklungPunkt1" ON "FP_Naturschutz"."FP_SchutzPflegeEntwicklungLinie" ("gid") ;


-- -----------------------------------------------------
-- Table "FP_Naturschutz"."FP_SchutzPflegeEntwicklungFlaeche"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Naturschutz"."FP_SchutzPflegeEntwicklungFlaeche" (
  "gid" INTEGER NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_SchutzPflegeEntwicklungFlaeche"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Naturschutz"."FP_SchutzPflegeEntwicklung" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
;

CREATE INDEX "idx_fk_FP_SchutzPflegeEntwicklungPunkt1" ON "FP_Naturschutz"."FP_SchutzPflegeEntwicklungFlaeche" ("gid") ;


-- -----------------------------------------------------
-- Table "FP_Bebauung"."FP_DetailArtDerBaulNutzung"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Bebauung"."FP_DetailArtDerBaulNutzung" (
  "Wert" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(255) NOT NULL ,
  PRIMARY KEY ("Wert") )
;


-- -----------------------------------------------------
-- Table "FP_Bebauung"."FP_BebauungsFlaeche"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Bebauung"."FP_BebauungsFlaeche" (
  "gid" INTEGER NOT NULL ,
  "allgArtDerBaulNutzung" INTEGER NULL ,
  "besondereArtDerBaulNutzung" INTEGER NULL ,
  "sonderNutzung" INTEGER NULL ,
  "detaillierteArtDerBaulNutzung" INTEGER NULL ,
  "nutzungText" VARCHAR(255) NULL ,
  "GFZ" FLOAT NULL ,
  "GFZmin" FLOAT NULL ,
  "GFZmax" FLOAT NULL ,
  "BMZ" FLOAT NULL ,
  "GRZ" FLOAT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_BebauungsFlaeche_XP_AllgArtDerBaulNutzung"
    FOREIGN KEY ("allgArtDerBaulNutzung" )
    REFERENCES "XP_Enumerationen"."XP_AllgArtDerBaulNutzung" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_BebauungsFlaeche_XP_BesondereArtDerBaulNutzung1"
    FOREIGN KEY ("besondereArtDerBaulNutzung" )
    REFERENCES "XP_Enumerationen"."XP_BesondereArtDerBaulNutzung" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_BebauungsFlaeche_XP_Sondernutzungen1"
    FOREIGN KEY ("sonderNutzung" )
    REFERENCES "XP_Enumerationen"."XP_Sondernutzungen" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_BebauungsFlaeche_FP_Objekt1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Basisobjekte"."FP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_BebauungsFlaeche_FP_DetailArtDerBaulNutzung1"
    FOREIGN KEY ("detaillierteArtDerBaulNutzung" )
    REFERENCES "FP_Bebauung"."FP_DetailArtDerBaulNutzung" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE)
;

CREATE INDEX "idx_fk_FP_BebauungsFlaeche_XP_AllgArtDerBaulNutzung" ON "FP_Bebauung"."FP_BebauungsFlaeche" ("allgArtDerBaulNutzung") ;

CREATE INDEX "idx_fk_FP_BebauungsFlaeche_XP_BesondereArtDerBaulNutzung1" ON "FP_Bebauung"."FP_BebauungsFlaeche" ("besondereArtDerBaulNutzung") ;

CREATE INDEX "idx_fk_FP_BebauungsFlaeche_XP_Sondernutzungen1" ON "FP_Bebauung"."FP_BebauungsFlaeche" ("sonderNutzung") ;

CREATE INDEX "idx_fk_FP_BebauungsFlaeche_FP_Objekt1" ON "FP_Bebauung"."FP_BebauungsFlaeche" ("gid") ;

CREATE INDEX "idx_fk_FP_BebauungsFlaeche_FP_DetailArtDerBaulNutzung1" ON "FP_Bebauung"."FP_BebauungsFlaeche" ("detaillierteArtDerBaulNutzung") ;


-- -----------------------------------------------------
-- Table "FP_Bebauung"."FP_KeineZentrAbwasserBeseitigungFlaeche"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Bebauung"."FP_KeineZentrAbwasserBeseitigungFlaeche" (
  "gid" INTEGER NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_KeineZentrAbwasserBeseitigungFlaeche_FP_Objekt1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Basisobjekte"."FP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
;

CREATE INDEX "idx_fk_FP_KeineZentrAbwasserBeseitigungFlaeche_FP_Objekt1" ON "FP_Bebauung"."FP_KeineZentrAbwasserBeseitigungFlaeche" ("gid") ;


-- -----------------------------------------------------
-- Table "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_DetailZweckbestGemeinbedarf"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_DetailZweckbestGemeinbedarf" (
  "Wert" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(255) NOT NULL ,
  PRIMARY KEY ("Wert") )
;


-- -----------------------------------------------------
-- Table "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_Gemeinbedarf"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_Gemeinbedarf" (
  "gid" INTEGER NOT NULL ,
  "zweckbestimmung" INTEGER NULL ,
  "weitereZweckbestimmung1" INTEGER NULL ,
  "weitereZweckbestimmung2" INTEGER NULL ,
  "weitereZweckbestimmung3" INTEGER NULL ,
  "weitereZweckbestimmung4" INTEGER NULL ,
  "weitereZweckbestimmung5" INTEGER NULL ,
  "besondereZweckbestimmung" INTEGER NULL ,
  "weitereBesondZweckbestimmung1" INTEGER NULL ,
  "weitereBesondZweckbestimmung2" INTEGER NULL ,
  "weitereBesondZweckbestimmung3" INTEGER NULL ,
  "weitereBesondZweckbestimmung4" INTEGER NULL ,
  "weitereBesondZweckbestimmung5" INTEGER NULL ,
  "detaillierteZweckbestimmung" INTEGER NULL ,
  "weitereDetailZweckbestimmung1" INTEGER NULL ,
  "weitereDetailZweckbestimmung2" INTEGER NULL ,
  "weitereDetailZweckbestimmung3" INTEGER NULL ,
  "weitereDetailZweckbestimmung4" INTEGER NULL ,
  "weitereDetailZweckbestimmung5" INTEGER NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_XP_ZweckbestimmungGemeinbedarf0"
    FOREIGN KEY ("zweckbestimmung" )
    REFERENCES "XP_Enumerationen"."XP_ZweckbestimmungGemeinbedarf" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_Gemeinbedarf_XP_ZweckbestimmungGemeinbedarf1"
    FOREIGN KEY ("weitereZweckbestimmung1" )
    REFERENCES "XP_Enumerationen"."XP_ZweckbestimmungGemeinbedarf" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_Gemeinbedarf_XP_ZweckbestimmungGemeinbedarf2"
    FOREIGN KEY ("weitereZweckbestimmung2" )
    REFERENCES "XP_Enumerationen"."XP_ZweckbestimmungGemeinbedarf" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_Gemeinbedarf_XP_ZweckbestimmungGemeinbedarf3"
    FOREIGN KEY ("weitereZweckbestimmung3" )
    REFERENCES "XP_Enumerationen"."XP_ZweckbestimmungGemeinbedarf" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_Gemeinbedarf_XP_ZweckbestimmungGemeinbedarf4"
    FOREIGN KEY ("weitereZweckbestimmung4" )
    REFERENCES "XP_Enumerationen"."XP_ZweckbestimmungGemeinbedarf" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_Gemeinbedarf_XP_ZweckbestimmungGemeinbedarf5"
    FOREIGN KEY ("weitereZweckbestimmung5" )
    REFERENCES "XP_Enumerationen"."XP_ZweckbestimmungGemeinbedarf" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_Gemeinbedarf_XP_BesondereZweckbestGemeinbedarf1"
    FOREIGN KEY ("besondereZweckbestimmung" )
    REFERENCES "XP_Enumerationen"."XP_BesondereZweckbestGemeinbedarf" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_Gemeinbedarf_XP_BesondereZweckbestGemeinbedarf2"
    FOREIGN KEY ("weitereBesondZweckbestimmung1" )
    REFERENCES "XP_Enumerationen"."XP_BesondereZweckbestGemeinbedarf" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_Gemeinbedarf_XP_BesondereZweckbestGemeinbedarf3"
    FOREIGN KEY ("weitereBesondZweckbestimmung2" )
    REFERENCES "XP_Enumerationen"."XP_BesondereZweckbestGemeinbedarf" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_Gemeinbedarf_XP_BesondereZweckbestGemeinbedarf4"
    FOREIGN KEY ("weitereBesondZweckbestimmung3" )
    REFERENCES "XP_Enumerationen"."XP_BesondereZweckbestGemeinbedarf" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_Gemeinbedarf_XP_BesondereZweckbestGemeinbedarf5"
    FOREIGN KEY ("weitereBesondZweckbestimmung4" )
    REFERENCES "XP_Enumerationen"."XP_BesondereZweckbestGemeinbedarf" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_Gemeinbedarf_XP_BesondereZweckbestGemeinbedarf6"
    FOREIGN KEY ("weitereBesondZweckbestimmung5" )
    REFERENCES "XP_Enumerationen"."XP_BesondereZweckbestGemeinbedarf" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_Gemeinbedarf_FP_DetailZweckbestGemeinbedarf1"
    FOREIGN KEY ("detaillierteZweckbestimmung" )
    REFERENCES "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_DetailZweckbestGemeinbedarf" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_Gemeinbedarf_FP_DetailZweckbestGemeinbedarf2"
    FOREIGN KEY ("weitereDetailZweckbestimmung1" )
    REFERENCES "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_DetailZweckbestGemeinbedarf" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_Gemeinbedarf_FP_DetailZweckbestGemeinbedarf3"
    FOREIGN KEY ("weitereDetailZweckbestimmung2" )
    REFERENCES "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_DetailZweckbestGemeinbedarf" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_Gemeinbedarf_FP_DetailZweckbestGemeinbedarf4"
    FOREIGN KEY ("weitereDetailZweckbestimmung3" )
    REFERENCES "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_DetailZweckbestGemeinbedarf" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_Gemeinbedarf_FP_DetailZweckbestGemeinbedarf5"
    FOREIGN KEY ("weitereDetailZweckbestimmung4" )
    REFERENCES "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_DetailZweckbestGemeinbedarf" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_Gemeinbedarf_FP_DetailZweckbestGemeinbedarf6"
    FOREIGN KEY ("weitereDetailZweckbestimmung5" )
    REFERENCES "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_DetailZweckbestGemeinbedarf" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_Gemeinbedarf_FP_Objekt1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Basisobjekte"."FP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
;

CREATE INDEX "idx_fk_XP_ZweckbestimmungGemeinbedarf0" ON "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_Gemeinbedarf" ("zweckbestimmung") ;

CREATE INDEX "idx_fk_FP_Gemeinbedarf_XP_ZweckbestimmungGemeinbedarf1" ON "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_Gemeinbedarf" ("weitereZweckbestimmung1") ;

CREATE INDEX "idx_fk_FP_Gemeinbedarf_XP_ZweckbestimmungGemeinbedarf2" ON "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_Gemeinbedarf" ("weitereZweckbestimmung2") ;

CREATE INDEX "idx_fk_FP_Gemeinbedarf_XP_ZweckbestimmungGemeinbedarf3" ON "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_Gemeinbedarf" ("weitereZweckbestimmung3") ;

CREATE INDEX "idx_fk_FP_Gemeinbedarf_XP_ZweckbestimmungGemeinbedarf4" ON "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_Gemeinbedarf" ("weitereZweckbestimmung4") ;

CREATE INDEX "idx_fk_FP_Gemeinbedarf_XP_ZweckbestimmungGemeinbedarf5" ON "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_Gemeinbedarf" ("weitereZweckbestimmung5") ;

CREATE INDEX "idx_fk_FP_Gemeinbedarf_XP_BesondereZweckbestGemeinbedarf1" ON "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_Gemeinbedarf" ("besondereZweckbestimmung") ;

CREATE INDEX "idx_fk_FP_Gemeinbedarf_XP_BesondereZweckbestGemeinbedarf2" ON "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_Gemeinbedarf" ("weitereBesondZweckbestimmung1") ;

CREATE INDEX "idx_fk_FP_Gemeinbedarf_XP_BesondereZweckbestGemeinbedarf3" ON "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_Gemeinbedarf" ("weitereBesondZweckbestimmung2") ;

CREATE INDEX "idx_fk_FP_Gemeinbedarf_XP_BesondereZweckbestGemeinbedarf4" ON "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_Gemeinbedarf" ("weitereBesondZweckbestimmung3") ;

CREATE INDEX "idx_fk_FP_Gemeinbedarf_XP_BesondereZweckbestGemeinbedarf5" ON "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_Gemeinbedarf" ("weitereBesondZweckbestimmung4") ;

CREATE INDEX "idx_fk_FP_Gemeinbedarf_XP_BesondereZweckbestGemeinbedarf6" ON "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_Gemeinbedarf" ("weitereBesondZweckbestimmung5") ;

CREATE INDEX "idx_fk_FP_Gemeinbedarf_FP_DetailZweckbestGemeinbedarf1" ON "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_Gemeinbedarf" ("detaillierteZweckbestimmung") ;

CREATE INDEX "idx_fk_FP_Gemeinbedarf_FP_DetailZweckbestGemeinbedarf2" ON "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_Gemeinbedarf" ("weitereDetailZweckbestimmung1") ;

CREATE INDEX "idx_fk_FP_Gemeinbedarf_FP_DetailZweckbestGemeinbedarf3" ON "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_Gemeinbedarf" ("weitereDetailZweckbestimmung2") ;

CREATE INDEX "idx_fk_FP_Gemeinbedarf_FP_DetailZweckbestGemeinbedarf4" ON "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_Gemeinbedarf" ("weitereDetailZweckbestimmung3") ;

CREATE INDEX "idx_fk_FP_Gemeinbedarf_FP_DetailZweckbestGemeinbedarf5" ON "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_Gemeinbedarf" ("weitereDetailZweckbestimmung4") ;

CREATE INDEX "idx_fk_FP_Gemeinbedarf_FP_DetailZweckbestGemeinbedarf6" ON "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_Gemeinbedarf" ("weitereDetailZweckbestimmung5") ;

CREATE INDEX "idx_fk_FP_Gemeinbedarf_FP_Objekt1" ON "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_Gemeinbedarf" ("gid") ;


-- -----------------------------------------------------
-- Table "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_DetailZweckbestSpielSportanlage"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_DetailZweckbestSpielSportanlage" (
  "Wert" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(255) NOT NULL ,
  PRIMARY KEY ("Wert") )
;


-- -----------------------------------------------------
-- Table "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_SpielSportanlage"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_SpielSportanlage" (
  "gid" INTEGER NOT NULL ,
  "zweckbestimmung" INTEGER NULL ,
  "weitereZweckbestimmung1" INTEGER NULL ,
  "detaillierteZweckbestimmung" INTEGER NULL ,
  "weitereDetailZweckbestimmung1" INTEGER NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_SpielSportanlage_XP_ZweckSpielSportanlage1"
    FOREIGN KEY ("zweckbestimmung" )
    REFERENCES "XP_Enumerationen"."XP_ZweckbestimmungSpielSportanlage" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_SpielSportanlage_XP_ZweckSpielSportanlage2"
    FOREIGN KEY ("weitereZweckbestimmung1" )
    REFERENCES "XP_Enumerationen"."XP_ZweckbestimmungSpielSportanlage" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_SpielSportanlage_FP_DetaiSpielSportanlage1"
    FOREIGN KEY ("detaillierteZweckbestimmung" )
    REFERENCES "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_DetailZweckbestSpielSportanlage" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_SpielSportanlage_FP_DetailSpielSportanlage2"
    FOREIGN KEY ("weitereDetailZweckbestimmung1" )
    REFERENCES "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_DetailZweckbestSpielSportanlage" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_SpielSportanlage_FP_Objekt1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Basisobjekte"."FP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
;

CREATE INDEX "idx_fk_FP_SpielSportanlage_XP_ZweckSpielSportanlage1" ON "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_SpielSportanlage" ("zweckbestimmung") ;

CREATE INDEX "idx_fk_FP_SpielSportanlage_XP_ZweckSpielSportanlage2" ON "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_SpielSportanlage" ("weitereZweckbestimmung1") ;

CREATE INDEX "idx_fk_FP_SpielSportanlage_FP_DetaiSpielSportanlage1" ON "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_SpielSportanlage" ("detaillierteZweckbestimmung") ;

CREATE INDEX "idx_fk_FP_SpielSportanlage_FP_DetailSpielSportanlage2" ON "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_SpielSportanlage" ("weitereDetailZweckbestimmung1") ;

CREATE INDEX "idx_fk_FP_SpielSportanlage_FP_Objekt1" ON "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_SpielSportanlage" ("gid") ;


-- -----------------------------------------------------
-- Table "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_GemeinbedarfFlaeche"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_GemeinbedarfFlaeche" (
  "gid" INTEGER NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_GemeinbedarfFlaeche_FP_Gemeinbedarf1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_Gemeinbedarf" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
;

CREATE INDEX "idx_fk_FP_GemeinbedarfFlaeche_FP_Gemeinbedarf1" ON "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_GemeinbedarfFlaeche" ("gid") ;


-- -----------------------------------------------------
-- Table "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_GemeinbedarfLinie"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_GemeinbedarfLinie" (
  "gid" INTEGER NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_GemeinbedarfLinie_FP_Gemeinbedarf1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_Gemeinbedarf" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
;

CREATE INDEX "idx_fk_FP_GemeinbedarfFlaeche_FP_Gemeinbedarf1" ON "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_GemeinbedarfLinie" ("gid") ;


-- -----------------------------------------------------
-- Table "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_GemeinbedarfPunkt"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_GemeinbedarfPunkt" (
  "gid" INTEGER NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_GemeinbedarfPunkt_FP_Gemeinbedarf1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_Gemeinbedarf" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
;

CREATE INDEX "idx_fk_FP_GemeinbedarfFlaeche_FP_Gemeinbedarf1" ON "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_GemeinbedarfPunkt" ("gid") ;


-- -----------------------------------------------------
-- Table "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_SpielSportanlageFlaeche"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_SpielSportanlageFlaeche" (
  "gid" INTEGER NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_SpielSportanlageFlaeche_FP_SpielSportanlage1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_SpielSportanlage" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
;

CREATE INDEX "idx_fk_FP_SpielSportanlageFlaeche_FP_SpielSportanlage1" ON "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_SpielSportanlageFlaeche" ("gid") ;


-- -----------------------------------------------------
-- Table "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_SpielSportanlageLinie"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_SpielSportanlageLinie" (
  "gid" INTEGER NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_SpielSportanlageLinie_FP_SpielSportanlage1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_SpielSportanlage" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
;

CREATE INDEX "idx_fk_FP_SpielSportanlageFlaeche_FP_SpielSportanlage1" ON "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_SpielSportanlageLinie" ("gid") ;


-- -----------------------------------------------------
-- Table "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_SpielSportanlagePunkt"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_SpielSportanlagePunkt" (
  "gid" INTEGER NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_SpielSportanlagePunkt_FP_SpielSportanlage1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_SpielSportanlage" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
;

CREATE INDEX "idx_fk_FP_SpielSportanlageFlaeche_FP_SpielSportanlage1" ON "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_SpielSportanlagePunkt" ("gid") ;


-- -----------------------------------------------------
-- Table "FP_Landwirtschaft_Wald_und_Gruen"."FP_DetailZweckbestWaldFlaeche"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Landwirtschaft_Wald_und_Gruen"."FP_DetailZweckbestWaldFlaeche" (
  "Wert" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(255) NOT NULL ,
  PRIMARY KEY ("Wert") )
;


-- -----------------------------------------------------
-- Table "FP_Landwirtschaft_Wald_und_Gruen"."FP_WaldFlaeche"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Landwirtschaft_Wald_und_Gruen"."FP_WaldFlaeche" (
  "gid" INTEGER NOT NULL ,
  "zweckbestimmung" INTEGER NULL ,
  "weitereZweckbestimmung1" INTEGER NULL ,
  "weitereZweckbestimmung2" INTEGER NULL ,
  "detaillierteZweckbestimmung" INTEGER NULL ,
  "weitereDetailZweckbestimmung1" INTEGER NULL ,
  "weitereDetailZweckbestimmung2" INTEGER NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_WaldFlaeche_XP_ZweckbestimmungWald"
    FOREIGN KEY ("zweckbestimmung" )
    REFERENCES "XP_Enumerationen"."XP_ZweckbestimmungWald" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_WaldFlaeche_XP_ZweckbestimmungWald1"
    FOREIGN KEY ("weitereZweckbestimmung1" )
    REFERENCES "XP_Enumerationen"."XP_ZweckbestimmungWald" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_WaldFlaeche_XP_ZweckbestimmungWald2"
    FOREIGN KEY ("weitereZweckbestimmung2" )
    REFERENCES "XP_Enumerationen"."XP_ZweckbestimmungWald" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_WaldFlaeche_FP_DetailZweckbestWaldFlaeche1"
    FOREIGN KEY ("detaillierteZweckbestimmung" )
    REFERENCES "FP_Landwirtschaft_Wald_und_Gruen"."FP_DetailZweckbestWaldFlaeche" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_WaldFlaeche_FP_DetailZweckbestWaldFlaeche2"
    FOREIGN KEY ("weitereDetailZweckbestimmung1" )
    REFERENCES "FP_Landwirtschaft_Wald_und_Gruen"."FP_DetailZweckbestWaldFlaeche" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_WaldFlaeche_FP_DetailZweckbestWaldFlaeche3"
    FOREIGN KEY ("weitereDetailZweckbestimmung2" )
    REFERENCES "FP_Landwirtschaft_Wald_und_Gruen"."FP_DetailZweckbestWaldFlaeche" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_WaldFlaeche_FP_Objekt1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Basisobjekte"."FP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
;

CREATE INDEX "idx_fk_FP_WaldFlaeche_XP_ZweckbestimmungWald" ON "FP_Landwirtschaft_Wald_und_Gruen"."FP_WaldFlaeche" ("zweckbestimmung") ;

CREATE INDEX "idx_fk_FP_WaldFlaeche_XP_ZweckbestimmungWald1" ON "FP_Landwirtschaft_Wald_und_Gruen"."FP_WaldFlaeche" ("weitereZweckbestimmung1") ;

CREATE INDEX "idx_fk_FP_WaldFlaeche_XP_ZweckbestimmungWald2" ON "FP_Landwirtschaft_Wald_und_Gruen"."FP_WaldFlaeche" ("weitereZweckbestimmung2") ;

CREATE INDEX "idx_fk_FP_WaldFlaeche_FP_DetailZweckbestWaldFlaeche1" ON "FP_Landwirtschaft_Wald_und_Gruen"."FP_WaldFlaeche" ("detaillierteZweckbestimmung") ;

CREATE INDEX "idx_fk_FP_WaldFlaeche_FP_DetailZweckbestWaldFlaeche2" ON "FP_Landwirtschaft_Wald_und_Gruen"."FP_WaldFlaeche" ("weitereDetailZweckbestimmung1") ;

CREATE INDEX "idx_fk_FP_WaldFlaeche_FP_DetailZweckbestWaldFlaeche3" ON "FP_Landwirtschaft_Wald_und_Gruen"."FP_WaldFlaeche" ("weitereDetailZweckbestimmung2") ;

CREATE INDEX "idx_fk_FP_WaldFlaeche_FP_Objekt1" ON "FP_Landwirtschaft_Wald_und_Gruen"."FP_WaldFlaeche" ("gid") ;


-- -----------------------------------------------------
-- Table "FP_Landwirtschaft_Wald_und_Gruen"."FP_DetailZweckbestLandwirtschaftsFlaeche"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Landwirtschaft_Wald_und_Gruen"."FP_DetailZweckbestLandwirtschaftsFlaeche" (
  "Wert" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(255) NOT NULL ,
  PRIMARY KEY ("Wert") )
;


-- -----------------------------------------------------
-- Table "FP_Landwirtschaft_Wald_und_Gruen"."FP_LandwirtschaftsFlaeche"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Landwirtschaft_Wald_und_Gruen"."FP_LandwirtschaftsFlaeche" (
  "gid" INTEGER NOT NULL ,
  "zweckbestimmung" INTEGER NULL ,
  "weitereZweckbestimmung1" INTEGER NULL ,
  "weitereZweckbestimmung2" INTEGER NULL ,
  "weitereZweckbestimmung3" INTEGER NULL ,
  "detaillierteZweckbestimmung" INTEGER NULL ,
  "weitereDetailZweckbestimmung1" INTEGER NULL ,
  "weitereDetailZweckbestimmung2" INTEGER NULL ,
  "weitereDetailZweckbestimmung3" INTEGER NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_LandwirtschaftsFlaeche_FP_Objekt1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Basisobjekte"."FP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_LandwirtschaftsFlaeche_XP_ZweckbestimmungLandwirtschaft1"
    FOREIGN KEY ("zweckbestimmung" )
    REFERENCES "XP_Enumerationen"."XP_ZweckbestimmungLandwirtschaft" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_LandwirtschaftsFlaeche_XP_ZweckbestimmungLandwirtschaft2"
    FOREIGN KEY ("weitereZweckbestimmung1" )
    REFERENCES "XP_Enumerationen"."XP_ZweckbestimmungLandwirtschaft" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_LandwirtschaftsFlaeche_XP_ZweckbestimmungLandwirtschaft3"
    FOREIGN KEY ("weitereZweckbestimmung2" )
    REFERENCES "XP_Enumerationen"."XP_ZweckbestimmungLandwirtschaft" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_LandwirtschaftsFlaeche_XP_ZweckbestimmungLandwirtschaft4"
    FOREIGN KEY ("weitereZweckbestimmung3" )
    REFERENCES "XP_Enumerationen"."XP_ZweckbestimmungLandwirtschaft" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_LandwirtschaftsFlaeche_FP_DetailZweckbestLandwirtschaft1"
    FOREIGN KEY ("detaillierteZweckbestimmung" )
    REFERENCES "FP_Landwirtschaft_Wald_und_Gruen"."FP_DetailZweckbestLandwirtschaftsFlaeche" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_LandwirtschaftsFlaeche_FP_DetailZweckbestLandwirtschaft2"
    FOREIGN KEY ("weitereDetailZweckbestimmung1" )
    REFERENCES "FP_Landwirtschaft_Wald_und_Gruen"."FP_DetailZweckbestLandwirtschaftsFlaeche" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_LandwirtschaftsFlaeche_FP_DetailZweckbestLandwirtschaft3"
    FOREIGN KEY ("weitereDetailZweckbestimmung2" )
    REFERENCES "FP_Landwirtschaft_Wald_und_Gruen"."FP_DetailZweckbestLandwirtschaftsFlaeche" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_LandwirtschaftsFlaeche_FP_DetailZweckbestLandwirtschaft4"
    FOREIGN KEY ("weitereDetailZweckbestimmung3" )
    REFERENCES "FP_Landwirtschaft_Wald_und_Gruen"."FP_DetailZweckbestLandwirtschaftsFlaeche" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE)
;

CREATE INDEX "idx_fk_FP_LandwirtschaftsFlaeche_FP_Objekt1" ON "FP_Landwirtschaft_Wald_und_Gruen"."FP_LandwirtschaftsFlaeche" ("gid") ;

CREATE INDEX "idx_fk_FP_LandwirtschaftsFlaeche_XP_ZweckbestimmungLandwirtschaft1" ON "FP_Landwirtschaft_Wald_und_Gruen"."FP_LandwirtschaftsFlaeche" ("zweckbestimmung") ;

CREATE INDEX "idx_fk_FP_LandwirtschaftsFlaeche_XP_ZweckbestimmungLandwirtschaft2" ON "FP_Landwirtschaft_Wald_und_Gruen"."FP_LandwirtschaftsFlaeche" ("weitereZweckbestimmung1") ;

CREATE INDEX "idx_fk_FP_LandwirtschaftsFlaeche_XP_ZweckbestimmungLandwirtschaft3" ON "FP_Landwirtschaft_Wald_und_Gruen"."FP_LandwirtschaftsFlaeche" ("weitereZweckbestimmung2") ;

CREATE INDEX "idx_fk_FP_LandwirtschaftsFlaeche_XP_ZweckbestimmungLandwirtschaft4" ON "FP_Landwirtschaft_Wald_und_Gruen"."FP_LandwirtschaftsFlaeche" ("weitereZweckbestimmung3") ;

CREATE INDEX "idx_fk_FP_LandwirtschaftsFlaeche_FP_DetailZweckbestLandwirtschaft1" ON "FP_Landwirtschaft_Wald_und_Gruen"."FP_LandwirtschaftsFlaeche" ("detaillierteZweckbestimmung") ;

CREATE INDEX "idx_fk_FP_LandwirtschaftsFlaeche_FP_DetailZweckbestLandwirtschaft2" ON "FP_Landwirtschaft_Wald_und_Gruen"."FP_LandwirtschaftsFlaeche" ("weitereDetailZweckbestimmung1") ;

CREATE INDEX "idx_fk_FP_LandwirtschaftsFlaeche_FP_DetailZweckbestLandwirtschaft3" ON "FP_Landwirtschaft_Wald_und_Gruen"."FP_LandwirtschaftsFlaeche" ("weitereDetailZweckbestimmung2") ;

CREATE INDEX "idx_fk_FP_LandwirtschaftsFlaeche_FP_DetailZweckbestLandwirtschaft4" ON "FP_Landwirtschaft_Wald_und_Gruen"."FP_LandwirtschaftsFlaeche" ("weitereDetailZweckbestimmung3") ;


-- -----------------------------------------------------
-- Table "FP_Landwirtschaft_Wald_und_Gruen"."FP_DetailZweckbestGruen"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Landwirtschaft_Wald_und_Gruen"."FP_DetailZweckbestGruen" (
  "Wert" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(255) NOT NULL ,
  PRIMARY KEY ("Wert") )
;


-- -----------------------------------------------------
-- Table "FP_Landwirtschaft_Wald_und_Gruen"."FP_Gruen"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Landwirtschaft_Wald_und_Gruen"."FP_Gruen" (
  "gid" INTEGER NOT NULL ,
  "zweckbestimmung" INTEGER NULL ,
  "weitereZweckbestimmung1" INTEGER NULL ,
  "weitereZweckbestimmung2" INTEGER NULL ,
  "weitereZweckbestimmung3" INTEGER NULL ,
  "weitereZweckbestimmung4" INTEGER NULL ,
  "weitereZweckbestimmung5" INTEGER NULL ,
  "besondereZweckbestimmung" INTEGER NULL ,
  "weitereBesondZweckbestimmung1" INTEGER NULL ,
  "weitereBesondZweckbestimmung2" INTEGER NULL ,
  "weitereBesondZweckbestimmung3" INTEGER NULL ,
  "weitereBesondZweckbestimmung4" INTEGER NULL ,
  "weitereBesondZweckbestimmung5" INTEGER NULL ,
  "detaillierteZweckbestimmung" INTEGER NULL ,
  "weitereDetailZweckbestimmung1" INTEGER NULL ,
  "weitereDetailZweckbestimmung2" INTEGER NULL ,
  "weitereDetailZweckbestimmung3" INTEGER NULL ,
  "weitereDetailZweckbestimmung4" INTEGER NULL ,
  "weitereDetailZweckbestimmung5" INTEGER NULL ,
  "nutzungsform" INTEGER NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_Gruen_FP_Objekt1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Basisobjekte"."FP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_Gruen_XP_ZweckbestimmungGruen1"
    FOREIGN KEY ("zweckbestimmung" )
    REFERENCES "XP_Enumerationen"."XP_ZweckbestimmungGruen" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_Gruen_XP_ZweckbestimmungGruen2"
    FOREIGN KEY ("weitereZweckbestimmung1" )
    REFERENCES "XP_Enumerationen"."XP_ZweckbestimmungGruen" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_Gruen_XP_ZweckbestimmungGruen3"
    FOREIGN KEY ("weitereZweckbestimmung2" )
    REFERENCES "XP_Enumerationen"."XP_ZweckbestimmungGruen" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_Gruen_XP_ZweckbestimmungGruen4"
    FOREIGN KEY ("weitereZweckbestimmung3" )
    REFERENCES "XP_Enumerationen"."XP_ZweckbestimmungGruen" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_Gruen_XP_ZweckbestimmungGruen5"
    FOREIGN KEY ("weitereZweckbestimmung4" )
    REFERENCES "XP_Enumerationen"."XP_ZweckbestimmungGruen" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_Gruen_XP_ZweckbestimmungGruen6"
    FOREIGN KEY ("weitereZweckbestimmung5" )
    REFERENCES "XP_Enumerationen"."XP_ZweckbestimmungGruen" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_Gruen_XP_BesondereZweckbestimmungGruen1"
    FOREIGN KEY ("besondereZweckbestimmung" )
    REFERENCES "XP_Enumerationen"."XP_BesondereZweckbestimmungGruen" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_Gruen_XP_BesondereZweckbestimmungGruen2"
    FOREIGN KEY ("weitereBesondZweckbestimmung1" )
    REFERENCES "XP_Enumerationen"."XP_BesondereZweckbestimmungGruen" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_Gruen_XP_BesondereZweckbestimmungGruen3"
    FOREIGN KEY ("weitereBesondZweckbestimmung2" )
    REFERENCES "XP_Enumerationen"."XP_BesondereZweckbestimmungGruen" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_Gruen_XP_BesondereZweckbestimmungGruen4"
    FOREIGN KEY ("weitereBesondZweckbestimmung3" )
    REFERENCES "XP_Enumerationen"."XP_BesondereZweckbestimmungGruen" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_Gruen_XP_BesondereZweckbestimmungGruen5"
    FOREIGN KEY ("weitereBesondZweckbestimmung4" )
    REFERENCES "XP_Enumerationen"."XP_BesondereZweckbestimmungGruen" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_Gruen_XP_BesondereZweckbestimmungGruen6"
    FOREIGN KEY ("weitereBesondZweckbestimmung5" )
    REFERENCES "XP_Enumerationen"."XP_BesondereZweckbestimmungGruen" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_Gruen_FP_DetailZweckbestGruen1"
    FOREIGN KEY ("detaillierteZweckbestimmung" )
    REFERENCES "FP_Landwirtschaft_Wald_und_Gruen"."FP_DetailZweckbestGruen" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_Gruen_FP_DetailZweckbestGruen2"
    FOREIGN KEY ("weitereDetailZweckbestimmung1" )
    REFERENCES "FP_Landwirtschaft_Wald_und_Gruen"."FP_DetailZweckbestGruen" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_Gruen_FP_DetailZweckbestGruen3"
    FOREIGN KEY ("weitereDetailZweckbestimmung2" )
    REFERENCES "FP_Landwirtschaft_Wald_und_Gruen"."FP_DetailZweckbestGruen" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_Gruen_FP_DetailZweckbestGruen4"
    FOREIGN KEY ("weitereDetailZweckbestimmung3" )
    REFERENCES "FP_Landwirtschaft_Wald_und_Gruen"."FP_DetailZweckbestGruen" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_Gruen_FP_DetailZweckbestGruen5"
    FOREIGN KEY ("weitereDetailZweckbestimmung4" )
    REFERENCES "FP_Landwirtschaft_Wald_und_Gruen"."FP_DetailZweckbestGruen" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_Gruen_FP_DetailZweckbestGruen6"
    FOREIGN KEY ("weitereDetailZweckbestimmung5" )
    REFERENCES "FP_Landwirtschaft_Wald_und_Gruen"."FP_DetailZweckbestGruen" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_Gruen_XP_Nutzungsform1"
    FOREIGN KEY ("nutzungsform" )
    REFERENCES "XP_Enumerationen"."XP_Nutzungsform" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE)
;

CREATE INDEX "idx_fk_FP_Gruen_FP_Objekt1" ON "FP_Landwirtschaft_Wald_und_Gruen"."FP_Gruen" ("gid") ;

CREATE INDEX "idx_fk_FP_Gruen_XP_ZweckbestimmungGruen1" ON "FP_Landwirtschaft_Wald_und_Gruen"."FP_Gruen" ("zweckbestimmung") ;

CREATE INDEX "idx_fk_FP_Gruen_XP_ZweckbestimmungGruen2" ON "FP_Landwirtschaft_Wald_und_Gruen"."FP_Gruen" ("weitereZweckbestimmung1") ;

CREATE INDEX "idx_fk_FP_Gruen_XP_ZweckbestimmungGruen3" ON "FP_Landwirtschaft_Wald_und_Gruen"."FP_Gruen" ("weitereZweckbestimmung2") ;

CREATE INDEX "idx_fk_FP_Gruen_XP_ZweckbestimmungGruen4" ON "FP_Landwirtschaft_Wald_und_Gruen"."FP_Gruen" ("weitereZweckbestimmung3") ;

CREATE INDEX "idx_fk_FP_Gruen_XP_ZweckbestimmungGruen5" ON "FP_Landwirtschaft_Wald_und_Gruen"."FP_Gruen" ("weitereZweckbestimmung4") ;

CREATE INDEX "idx_fk_FP_Gruen_XP_ZweckbestimmungGruen6" ON "FP_Landwirtschaft_Wald_und_Gruen"."FP_Gruen" ("weitereZweckbestimmung5") ;

CREATE INDEX "idx_fk_FP_Gruen_XP_BesondereZweckbestimmungGruen1" ON "FP_Landwirtschaft_Wald_und_Gruen"."FP_Gruen" ("besondereZweckbestimmung") ;

CREATE INDEX "idx_fk_FP_Gruen_XP_BesondereZweckbestimmungGruen2" ON "FP_Landwirtschaft_Wald_und_Gruen"."FP_Gruen" ("weitereBesondZweckbestimmung1") ;

CREATE INDEX "idx_fk_FP_Gruen_XP_BesondereZweckbestimmungGruen3" ON "FP_Landwirtschaft_Wald_und_Gruen"."FP_Gruen" ("weitereBesondZweckbestimmung2") ;

CREATE INDEX "idx_fk_FP_Gruen_XP_BesondereZweckbestimmungGruen4" ON "FP_Landwirtschaft_Wald_und_Gruen"."FP_Gruen" ("weitereBesondZweckbestimmung3") ;

CREATE INDEX "idx_fk_FP_Gruen_XP_BesondereZweckbestimmungGruen5" ON "FP_Landwirtschaft_Wald_und_Gruen"."FP_Gruen" ("weitereBesondZweckbestimmung4") ;

CREATE INDEX "idx_fk_FP_Gruen_XP_BesondereZweckbestimmungGruen6" ON "FP_Landwirtschaft_Wald_und_Gruen"."FP_Gruen" ("weitereBesondZweckbestimmung5") ;

CREATE INDEX "idx_fk_FP_Gruen_FP_DetailZweckbestGruen1" ON "FP_Landwirtschaft_Wald_und_Gruen"."FP_Gruen" ("detaillierteZweckbestimmung") ;

CREATE INDEX "idx_fk_FP_Gruen_FP_DetailZweckbestGruen2" ON "FP_Landwirtschaft_Wald_und_Gruen"."FP_Gruen" ("weitereDetailZweckbestimmung1") ;

CREATE INDEX "idx_fk_FP_Gruen_FP_DetailZweckbestGruen3" ON "FP_Landwirtschaft_Wald_und_Gruen"."FP_Gruen" ("weitereDetailZweckbestimmung2") ;

CREATE INDEX "idx_fk_FP_Gruen_FP_DetailZweckbestGruen4" ON "FP_Landwirtschaft_Wald_und_Gruen"."FP_Gruen" ("weitereDetailZweckbestimmung3") ;

CREATE INDEX "idx_fk_FP_Gruen_FP_DetailZweckbestGruen5" ON "FP_Landwirtschaft_Wald_und_Gruen"."FP_Gruen" ("weitereDetailZweckbestimmung4") ;

CREATE INDEX "idx_fk_FP_Gruen_FP_DetailZweckbestGruen6" ON "FP_Landwirtschaft_Wald_und_Gruen"."FP_Gruen" ("weitereDetailZweckbestimmung5") ;

CREATE INDEX "idx_fk_FP_Gruen_XP_Nutzungsform1" ON "FP_Landwirtschaft_Wald_und_Gruen"."FP_Gruen" ("nutzungsform") ;


-- -----------------------------------------------------
-- Table "FP_Landwirtschaft_Wald_und_Gruen"."FP_GruenFlaeche"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Landwirtschaft_Wald_und_Gruen"."FP_GruenFlaeche" (
  "gid" INTEGER NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_GruenFlaeche_FP_Gruen1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Landwirtschaft_Wald_und_Gruen"."FP_Gruen" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
;

CREATE INDEX "idx_fk_FP_GruenFlaeche_FP_Gruen1" ON "FP_Landwirtschaft_Wald_und_Gruen"."FP_GruenFlaeche" ("gid") ;


-- -----------------------------------------------------
-- Table "FP_Landwirtschaft_Wald_und_Gruen"."FP_GruenLinie"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Landwirtschaft_Wald_und_Gruen"."FP_GruenLinie" (
  "gid" INTEGER NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_GruenLinie_FP_Gruen1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Landwirtschaft_Wald_und_Gruen"."FP_Gruen" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
;

CREATE INDEX "idx_fk_FP_GruenFlaeche_FP_Gruen1" ON "FP_Landwirtschaft_Wald_und_Gruen"."FP_GruenLinie" ("gid") ;


-- -----------------------------------------------------
-- Table "FP_Landwirtschaft_Wald_und_Gruen"."FP_GruenPunkt"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Landwirtschaft_Wald_und_Gruen"."FP_GruenPunkt" (
  "gid" INTEGER NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_GruenPunkt_FP_Gruen1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Landwirtschaft_Wald_und_Gruen"."FP_Gruen" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
;

CREATE INDEX "idx_fk_FP_GruenFlaeche_FP_Gruen1" ON "FP_Landwirtschaft_Wald_und_Gruen"."FP_GruenPunkt" ("gid") ;


-- -----------------------------------------------------
-- Table "FP_Sonstiges"."FP_ZweckbestimmungGenerischeObjekte"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Sonstiges"."FP_ZweckbestimmungGenerischeObjekte" (
  "Wert" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(255) NOT NULL ,
  PRIMARY KEY ("Wert") )
;


-- -----------------------------------------------------
-- Table "FP_Sonstiges"."FP_GenerischesObjekt"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Sonstiges"."FP_GenerischesObjekt" (
  "gid" INTEGER NOT NULL ,
  "zweckbestimmung" INTEGER NULL ,
  "weitereZweckbestimmung1" INTEGER NULL ,
  "weitereZweckbestimmung2" INTEGER NULL ,
  "weitereZweckbestimmung3" INTEGER NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_GenerischesObjekt_FP_ZweckbestimmungGenerischeObjekte"
    FOREIGN KEY ("zweckbestimmung" )
    REFERENCES "FP_Sonstiges"."FP_ZweckbestimmungGenerischeObjekte" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT "fk_FP_GenerischesObjekt_FP_ZweckbestimmungGenerischeObjekte1"
    FOREIGN KEY ("weitereZweckbestimmung1" )
    REFERENCES "FP_Sonstiges"."FP_ZweckbestimmungGenerischeObjekte" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT "fk_FP_GenerischesObjekt_FP_ZweckbestimmungGenerischeObjekte2"
    FOREIGN KEY ("weitereZweckbestimmung2" )
    REFERENCES "FP_Sonstiges"."FP_ZweckbestimmungGenerischeObjekte" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT "fk_FP_GenerischesObjekt_FP_ZweckbestimmungGenerischeObjekte3"
    FOREIGN KEY ("weitereZweckbestimmung3" )
    REFERENCES "FP_Sonstiges"."FP_ZweckbestimmungGenerischeObjekte" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT "fk_FP_GenerischesObjekt_FP_Objekt1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Basisobjekte"."FP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
;

CREATE INDEX "idx_fk_FP_GenerischesObjekt_FP_ZweckbestimmungGenerischeObjekte" ON "FP_Sonstiges"."FP_GenerischesObjekt" ("zweckbestimmung") ;

CREATE INDEX "idx_fk_FP_GenerischesObjekt_FP_ZweckbestimmungGenerischeObjekte1" ON "FP_Sonstiges"."FP_GenerischesObjekt" ("weitereZweckbestimmung1") ;

CREATE INDEX "idx_fk_FP_GenerischesObjekt_FP_ZweckbestimmungGenerischeObjekte2" ON "FP_Sonstiges"."FP_GenerischesObjekt" ("weitereZweckbestimmung2") ;

CREATE INDEX "idx_fk_FP_GenerischesObjekt_FP_ZweckbestimmungGenerischeObjekte3" ON "FP_Sonstiges"."FP_GenerischesObjekt" ("weitereZweckbestimmung3") ;

CREATE INDEX "idx_fk_FP_GenerischesObjekt_FP_Objekt1" ON "FP_Sonstiges"."FP_GenerischesObjekt" ("gid") ;


-- -----------------------------------------------------
-- Table "FP_Sonstiges"."FP_Kennzeichnung"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Sonstiges"."FP_Kennzeichnung" (
  "gid" INTEGER NOT NULL ,
  "zweckbestimmung" INTEGER NULL ,
  "weitereZweckbestimmung1" INTEGER NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_Kennzeichnung_XP_ZweckbestimmungKennzeichnung1"
    FOREIGN KEY ("zweckbestimmung" )
    REFERENCES "XP_Enumerationen"."XP_ZweckbestimmungKennzeichnung" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_Kennzeichnung_XP_ZweckbestimmungKennzeichnung2"
    FOREIGN KEY ("weitereZweckbestimmung1" )
    REFERENCES "XP_Enumerationen"."XP_ZweckbestimmungKennzeichnung" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_Kennzeichnung_FP_Objekt1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Basisobjekte"."FP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
;

CREATE INDEX "idx_fk_FP_Kennzeichnung_XP_ZweckbestimmungKennzeichnung1" ON "FP_Sonstiges"."FP_Kennzeichnung" ("zweckbestimmung") ;

CREATE INDEX "idx_fk_FP_Kennzeichnung_XP_ZweckbestimmungKennzeichnung2" ON "FP_Sonstiges"."FP_Kennzeichnung" ("weitereZweckbestimmung1") ;

CREATE INDEX "idx_fk_FP_Kennzeichnung_FP_Objekt1" ON "FP_Sonstiges"."FP_Kennzeichnung" ("gid") ;


-- -----------------------------------------------------
-- Table "FP_Sonstiges"."FP_GenerischesObjektFlaeche"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Sonstiges"."FP_GenerischesObjektFlaeche" (
  "gid" INTEGER NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_GenerischesObjektFlaeche_FP_GenerischesObjekt1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Sonstiges"."FP_GenerischesObjekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
;

CREATE INDEX "idx_fk_FP_GenerischesObjektFlaeche_FP_GenerischesObjekt1" ON "FP_Sonstiges"."FP_GenerischesObjektFlaeche" ("gid") ;


-- -----------------------------------------------------
-- Table "FP_Sonstiges"."FP_GenerischesObjektLinie"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Sonstiges"."FP_GenerischesObjektLinie" (
  "gid" INTEGER NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_GenerischesObjektLinie_FP_GenerischesObjekt1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Sonstiges"."FP_GenerischesObjekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
;

CREATE INDEX "idx_fk_table1_FP_GenerischesObjekt1" ON "FP_Sonstiges"."FP_GenerischesObjektLinie" ("gid") ;


-- -----------------------------------------------------
-- Table "FP_Sonstiges"."FP_GenerischesObjektPunkt"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Sonstiges"."FP_GenerischesObjektPunkt" (
  "gid" INTEGER NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_GenerischesObjektPunkt_FP_GenerischesObjekt1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Sonstiges"."FP_GenerischesObjekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
;

CREATE INDEX "idx_fk_FP_GenerischesObjektFlaeche_FP_GenerischesObjekt1" ON "FP_Sonstiges"."FP_GenerischesObjektPunkt" ("gid") ;


-- -----------------------------------------------------
-- Table "FP_Sonstiges"."FP_KennzeichnungFlaeche"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Sonstiges"."FP_KennzeichnungFlaeche" (
  "gid" INTEGER NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_KennzeichnungFlaeche_FP_Kennzeichnung1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Sonstiges"."FP_Kennzeichnung" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
;

CREATE INDEX "idx_fk_FP_KennzeichnungFlaeche_FP_Kennzeichnung1" ON "FP_Sonstiges"."FP_KennzeichnungFlaeche" ("gid") ;


-- -----------------------------------------------------
-- Table "FP_Sonstiges"."FP_KennzeichnungLinie"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Sonstiges"."FP_KennzeichnungLinie" (
  "gid" INTEGER NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_KennzeichnungLinie_FP_Kennzeichnung1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Sonstiges"."FP_Kennzeichnung" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
;

CREATE INDEX "idx_fk_FP_KennzeichnungFlaeche_FP_Kennzeichnung1" ON "FP_Sonstiges"."FP_KennzeichnungLinie" ("gid") ;


-- -----------------------------------------------------
-- Table "FP_Sonstiges"."FP_KennzeichnungPunkt"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Sonstiges"."FP_KennzeichnungPunkt" (
  "gid" INTEGER NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_KennzeichnungPunkt_FP_Kennzeichnung1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Sonstiges"."FP_Kennzeichnung" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
;

CREATE INDEX "idx_fk_FP_KennzeichnungFlaeche_FP_Kennzeichnung1" ON "FP_Sonstiges"."FP_KennzeichnungPunkt" ("gid") ;


-- -----------------------------------------------------
-- Table "FP_Sonstiges"."FP_NutzungsbeschraenkungsFlaeche"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Sonstiges"."FP_NutzungsbeschraenkungsFlaeche" (
  "gid" INTEGER NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_NutzungsbeschraenkungsFlaeche_FP_Objekt1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Basisobjekte"."FP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
;

CREATE INDEX "idx_fk_FP_NutzungsbeschraenkungsFlaeche_FP_Objekt1" ON "FP_Sonstiges"."FP_NutzungsbeschraenkungsFlaeche" ("gid") ;


-- -----------------------------------------------------
-- Table "FP_Sonstiges"."FP_ZweckbestimmungPrivilegiertesVorhaben"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Sonstiges"."FP_ZweckbestimmungPrivilegiertesVorhaben" (
  "Wert" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(255) NOT NULL ,
  PRIMARY KEY ("Wert") )
;


-- -----------------------------------------------------
-- Table "FP_Sonstiges"."FP_BesondZweckbestPrivilegiertesVorhaben"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Sonstiges"."FP_BesondZweckbestPrivilegiertesVorhaben" (
  "Wert" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(255) NOT NULL ,
  PRIMARY KEY ("Wert") )
;


-- -----------------------------------------------------
-- Table "FP_Sonstiges"."FP_PrivilegiertesVorhaben"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Sonstiges"."FP_PrivilegiertesVorhaben" (
  "gid" INTEGER NOT NULL ,
  "zweckbestimmung" INTEGER NULL ,
  "weitereZweckbestimmung1" INTEGER NULL ,
  "weitereZweckbestimmung2" INTEGER NULL ,
  "besondereZweckbestimmung" INTEGER NULL ,
  "weitereBesondZweckbestimmung1" INTEGER NULL ,
  "weitereBesondZweckbestimmung2" INTEGER NULL ,
  "vorhaben" VARCHAR(255) NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_PrivilegiertesVorhaben_FP_Objekt1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Basisobjekte"."FP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_PrivilegiertesVorhaben_FP_Zweckbestimmung1"
    FOREIGN KEY ("zweckbestimmung" )
    REFERENCES "FP_Sonstiges"."FP_ZweckbestimmungPrivilegiertesVorhaben" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_PrivilegiertesVorhaben_FP_Zweckbestimmung2"
    FOREIGN KEY ("weitereZweckbestimmung1" )
    REFERENCES "FP_Sonstiges"."FP_ZweckbestimmungPrivilegiertesVorhaben" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_PrivilegiertesVorhaben_FP_Zweckbestimmung3"
    FOREIGN KEY ("weitereZweckbestimmung2" )
    REFERENCES "FP_Sonstiges"."FP_ZweckbestimmungPrivilegiertesVorhaben" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_PrivilegiertesVorhaben_FP_BesondZweckbest1"
    FOREIGN KEY ("besondereZweckbestimmung" )
    REFERENCES "FP_Sonstiges"."FP_BesondZweckbestPrivilegiertesVorhaben" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_PrivilegiertesVorhaben_FP_BesondZweckbest2"
    FOREIGN KEY ("weitereBesondZweckbestimmung1" )
    REFERENCES "FP_Sonstiges"."FP_BesondZweckbestPrivilegiertesVorhaben" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_PrivilegiertesVorhaben_FP_BesondZweckbest3"
    FOREIGN KEY ("weitereBesondZweckbestimmung2" )
    REFERENCES "FP_Sonstiges"."FP_BesondZweckbestPrivilegiertesVorhaben" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE)
;

CREATE INDEX "idx_fk_FP_PrivilegiertesVorhaben_FP_Objekt1" ON "FP_Sonstiges"."FP_PrivilegiertesVorhaben" ("gid") ;

CREATE INDEX "idx_fk_FP_PrivilegiertesVorhaben_FP_Zweckbestimmung1" ON "FP_Sonstiges"."FP_PrivilegiertesVorhaben" ("zweckbestimmung") ;

CREATE INDEX "idx_fk_FP_PrivilegiertesVorhaben_FP_Zweckbestimmung2" ON "FP_Sonstiges"."FP_PrivilegiertesVorhaben" ("weitereZweckbestimmung1") ;

CREATE INDEX "idx_fk_FP_PrivilegiertesVorhaben_FP_Zweckbestimmung3" ON "FP_Sonstiges"."FP_PrivilegiertesVorhaben" ("weitereZweckbestimmung2") ;

CREATE INDEX "idx_fk_FP_PrivilegiertesVorhaben_FP_BesondZweckbest1" ON "FP_Sonstiges"."FP_PrivilegiertesVorhaben" ("besondereZweckbestimmung") ;

CREATE INDEX "idx_fk_FP_PrivilegiertesVorhaben_FP_BesondZweckbest2" ON "FP_Sonstiges"."FP_PrivilegiertesVorhaben" ("weitereBesondZweckbestimmung1") ;

CREATE INDEX "idx_fk_FP_PrivilegiertesVorhaben_FP_BesondZweckbest3" ON "FP_Sonstiges"."FP_PrivilegiertesVorhaben" ("weitereBesondZweckbestimmung2") ;


-- -----------------------------------------------------
-- Table "FP_Sonstiges"."FP_PrivilegiertesVorhabenFlaeche"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Sonstiges"."FP_PrivilegiertesVorhabenFlaeche" (
  "gid" INTEGER NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_PrivVorhaFlaeche_FP_PrivilegiertesVorhaben1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Sonstiges"."FP_PrivilegiertesVorhaben" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
;

CREATE INDEX "idx_fk_FP_PrivVorhaFlaeche_FP_PrivilegiertesVorhaben1" ON "FP_Sonstiges"."FP_PrivilegiertesVorhabenFlaeche" ("gid") ;


-- -----------------------------------------------------
-- Table "FP_Sonstiges"."FP_PrivilegiertesVorhabenLinie"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Sonstiges"."FP_PrivilegiertesVorhabenLinie" (
  "gid" INTEGER NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_PrivVorhaLinie_FP_PrivilegiertesVorhaben1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Sonstiges"."FP_PrivilegiertesVorhaben" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
;

CREATE INDEX "idx_fk_FP_PrivVorhaFlaeche_FP_PrivilegiertesVorhaben1" ON "FP_Sonstiges"."FP_PrivilegiertesVorhabenLinie" ("gid") ;


-- -----------------------------------------------------
-- Table "FP_Sonstiges"."FP_PrivilegiertesVorhabenPunkt"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Sonstiges"."FP_PrivilegiertesVorhabenPunkt" (
  "gid" INTEGER NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_PrivVorhaPunkt_FP_PrivilegiertesVorhaben1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Sonstiges"."FP_PrivilegiertesVorhaben" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
;

CREATE INDEX "idx_fk_FP_PrivVorhaFlaeche_FP_PrivilegiertesVorhaben1" ON "FP_Sonstiges"."FP_PrivilegiertesVorhabenPunkt" ("gid") ;


-- -----------------------------------------------------
-- Table "FP_Sonstiges"."FP_VorbehalteFlaeche"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Sonstiges"."FP_VorbehalteFlaeche" (
  "gid" INTEGER NOT NULL ,
  "vorbehalt" VARCHAR(255) NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_VorbehalteFlaeche_FP_Objekt1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Basisobjekte"."FP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
;

CREATE INDEX "idx_fk_FP_VorbehalteFlaeche_FP_Objekt1" ON "FP_Sonstiges"."FP_VorbehalteFlaeche" ("gid") ;


-- -----------------------------------------------------
-- Table "FP_Sonstiges"."FP_UnverbindlicheVormerkung"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Sonstiges"."FP_UnverbindlicheVormerkung" (
  "gid" INTEGER NOT NULL ,
  "vormerkung" VARCHAR(255) NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_UnverbindlicheVormerkung_FP_Objekt1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Basisobjekte"."FP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
;

CREATE INDEX "idx_fk_FP_UnverbindlicheVormerkung_FP_Objekt1" ON "FP_Sonstiges"."FP_UnverbindlicheVormerkung" ("gid") ;


-- -----------------------------------------------------
-- Table "FP_Sonstiges"."FP_UnverbindlicheVormerkungFlaeche"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Sonstiges"."FP_UnverbindlicheVormerkungFlaeche" (
  "gid" INTEGER NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_UnverVormerFlaeche_FP_UnverVormer1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Sonstiges"."FP_UnverbindlicheVormerkung" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
;

CREATE INDEX "idx_fk_FP_UnverVormerFlaeche_FP_UnverVormer1" ON "FP_Sonstiges"."FP_UnverbindlicheVormerkungFlaeche" ("gid") ;


-- -----------------------------------------------------
-- Table "FP_Sonstiges"."FP_UnverbindlicheVormerkungLinie"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Sonstiges"."FP_UnverbindlicheVormerkungLinie" (
  "gid" INTEGER NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_UnverVormerLinie_FP_UnverVormer1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Sonstiges"."FP_UnverbindlicheVormerkung" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
;

CREATE INDEX "idx_fk_FP_UnverVormerFlaeche_FP_UnverVormer1" ON "FP_Sonstiges"."FP_UnverbindlicheVormerkungLinie" ("gid") ;


-- -----------------------------------------------------
-- Table "FP_Sonstiges"."FP_UnverbindlicheVormerkungPunkt"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Sonstiges"."FP_UnverbindlicheVormerkungPunkt" (
  "gid" INTEGER NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_UnverVormerPunkt_FP_UnverVormer1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Sonstiges"."FP_UnverbindlicheVormerkung" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
;

CREATE INDEX "idx_fk_FP_UnverVormerFlaeche_FP_UnverVormer1" ON "FP_Sonstiges"."FP_UnverbindlicheVormerkungPunkt" ("gid") ;


-- -----------------------------------------------------
-- Table "FP_Sonstiges"."FP_TextlicheDarstellungsFlaeche"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Sonstiges"."FP_TextlicheDarstellungsFlaeche" (
  "gid" INTEGER NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_TextlicheDarstellungsFlaeche_FP_Objekt1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Basisobjekte"."FP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
;

CREATE INDEX "idx_fk_FP_TextlicheDarstellungsFlaeche_FP_Objekt1" ON "FP_Sonstiges"."FP_TextlicheDarstellungsFlaeche" ("gid") ;


-- -----------------------------------------------------
-- Table "FP_Ver_und_Entsorgung"."FP_DetailZweckbestVerEntsorgung"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Ver_und_Entsorgung"."FP_DetailZweckbestVerEntsorgung" (
  "Wert" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(255) NOT NULL ,
  PRIMARY KEY ("Wert") )
;


-- -----------------------------------------------------
-- Table "FP_Ver_und_Entsorgung"."FP_VerEntsorgung"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Ver_und_Entsorgung"."FP_VerEntsorgung" (
  "gid" INTEGER NOT NULL ,
  "zweckbestimmung" INTEGER NULL ,
  "weitereZweckbestimmung1" INTEGER NULL ,
  "weitereZweckbestimmung2" INTEGER NULL ,
  "weitereZweckbestimmung3" INTEGER NULL ,
  "besondereZweckbestimmung" INTEGER NULL ,
  "weitereBesondZweckbestimmung1" INTEGER NULL ,
  "weitereBesondZweckbestimmung2" INTEGER NULL ,
  "weitereBesondZweckbestimmung3" INTEGER NULL ,
  "detaillierteZweckbestimmung" INTEGER NULL ,
  "weitereDetailZweckbestimmung1" INTEGER NULL ,
  "weitereDetailZweckbestimmung2" INTEGER NULL ,
  "weitereDetailZweckbestimmung3" INTEGER NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_VerEntsorgung_FP_Objekt"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Basisobjekte"."FP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_VerEntsorgung_XP_ZweckbestimmungVerEntsorgung1"
    FOREIGN KEY ("zweckbestimmung" )
    REFERENCES "XP_Enumerationen"."XP_ZweckbestimmungVerEntsorgung" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_VerEntsorgung_XP_ZweckbestimmungVerEntsorgung2"
    FOREIGN KEY ("weitereZweckbestimmung1" )
    REFERENCES "XP_Enumerationen"."XP_ZweckbestimmungVerEntsorgung" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_VerEntsorgung_XP_ZweckbestimmungVerEntsorgung3"
    FOREIGN KEY ("weitereZweckbestimmung2" )
    REFERENCES "XP_Enumerationen"."XP_ZweckbestimmungVerEntsorgung" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_VerEntsorgung_XP_ZweckbestimmungVerEntsorgung4"
    FOREIGN KEY ("weitereZweckbestimmung3" )
    REFERENCES "XP_Enumerationen"."XP_ZweckbestimmungVerEntsorgung" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_VerEntsorgung_XP_BesZweckbestVerEntsorgung1"
    FOREIGN KEY ("besondereZweckbestimmung" )
    REFERENCES "XP_Enumerationen"."XP_BesondereZweckbestimmungVerEntsorgung" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_VerEntsorgung_XP_BesZweckbestVerEntsorgung2"
    FOREIGN KEY ("weitereBesondZweckbestimmung1" )
    REFERENCES "XP_Enumerationen"."XP_BesondereZweckbestimmungVerEntsorgung" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_VerEntsorgung_XP_BesZweckbestVerEntsorgung3"
    FOREIGN KEY ("weitereBesondZweckbestimmung2" )
    REFERENCES "XP_Enumerationen"."XP_BesondereZweckbestimmungVerEntsorgung" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_VerEntsorgung_XP_BesZweckbestVerEntsorgung4"
    FOREIGN KEY ("weitereBesondZweckbestimmung3" )
    REFERENCES "XP_Enumerationen"."XP_BesondereZweckbestimmungVerEntsorgung" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_VerEntsorgung_FP_DetailZweckbestVerEntsorgung1"
    FOREIGN KEY ("detaillierteZweckbestimmung" )
    REFERENCES "FP_Ver_und_Entsorgung"."FP_DetailZweckbestVerEntsorgung" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_VerEntsorgung_FP_DetailZweckbestVerEntsorgung2"
    FOREIGN KEY ("weitereDetailZweckbestimmung1" )
    REFERENCES "FP_Ver_und_Entsorgung"."FP_DetailZweckbestVerEntsorgung" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_VerEntsorgung_FP_DetailZweckbestVerEntsorgung3"
    FOREIGN KEY ("weitereDetailZweckbestimmung2" )
    REFERENCES "FP_Ver_und_Entsorgung"."FP_DetailZweckbestVerEntsorgung" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_VerEntsorgung_FP_DetailZweckbestVerEntsorgung4"
    FOREIGN KEY ("weitereDetailZweckbestimmung3" )
    REFERENCES "FP_Ver_und_Entsorgung"."FP_DetailZweckbestVerEntsorgung" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE)
;

CREATE INDEX "idx_fk_FP_VerEntsorgung_FP_Objekt" ON "FP_Ver_und_Entsorgung"."FP_VerEntsorgung" ("gid") ;

CREATE INDEX "idx_fk_FP_VerEntsorgung_XP_ZweckbestimmungVerEntsorgung1" ON "FP_Ver_und_Entsorgung"."FP_VerEntsorgung" ("zweckbestimmung") ;

CREATE INDEX "idx_fk_FP_VerEntsorgung_XP_ZweckbestimmungVerEntsorgung2" ON "FP_Ver_und_Entsorgung"."FP_VerEntsorgung" ("weitereZweckbestimmung1") ;

CREATE INDEX "idx_fk_FP_VerEntsorgung_XP_ZweckbestimmungVerEntsorgung3" ON "FP_Ver_und_Entsorgung"."FP_VerEntsorgung" ("weitereZweckbestimmung2") ;

CREATE INDEX "idx_fk_FP_VerEntsorgung_XP_ZweckbestimmungVerEntsorgung4" ON "FP_Ver_und_Entsorgung"."FP_VerEntsorgung" ("weitereZweckbestimmung3") ;

CREATE INDEX "idx_fk_FP_VerEntsorgung_XP_BesZweckbestVerEntsorgung1" ON "FP_Ver_und_Entsorgung"."FP_VerEntsorgung" ("besondereZweckbestimmung") ;

CREATE INDEX "idx_fk_FP_VerEntsorgung_XP_BesZweckbestVerEntsorgung2" ON "FP_Ver_und_Entsorgung"."FP_VerEntsorgung" ("weitereBesondZweckbestimmung1") ;

CREATE INDEX "idx_fk_FP_VerEntsorgung_XP_BesZweckbestVerEntsorgung3" ON "FP_Ver_und_Entsorgung"."FP_VerEntsorgung" ("weitereBesondZweckbestimmung2") ;

CREATE INDEX "idx_fk_FP_VerEntsorgung_XP_BesZweckbestVerEntsorgung4" ON "FP_Ver_und_Entsorgung"."FP_VerEntsorgung" ("weitereBesondZweckbestimmung3") ;

CREATE INDEX "idx_fk_FP_VerEntsorgung_FP_DetailZweckbestVerEntsorgung1" ON "FP_Ver_und_Entsorgung"."FP_VerEntsorgung" ("detaillierteZweckbestimmung") ;

CREATE INDEX "idx_fk_FP_VerEntsorgung_FP_DetailZweckbestVerEntsorgung2" ON "FP_Ver_und_Entsorgung"."FP_VerEntsorgung" ("weitereDetailZweckbestimmung1") ;

CREATE INDEX "idx_fk_FP_VerEntsorgung_FP_DetailZweckbestVerEntsorgung3" ON "FP_Ver_und_Entsorgung"."FP_VerEntsorgung" ("weitereDetailZweckbestimmung2") ;

CREATE INDEX "idx_fk_FP_VerEntsorgung_FP_DetailZweckbestVerEntsorgung4" ON "FP_Ver_und_Entsorgung"."FP_VerEntsorgung" ("weitereDetailZweckbestimmung3") ;


-- -----------------------------------------------------
-- Table "FP_Ver_und_Entsorgung"."FP_VerEntsorgungFlaeche"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Ver_und_Entsorgung"."FP_VerEntsorgungFlaeche" (
  "gid" INTEGER NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_VerEntsorgungFlaeche_FP_VerEntsorgung1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Ver_und_Entsorgung"."FP_VerEntsorgung" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
;

CREATE INDEX "idx_fk_FP_VerEntsorgungFlaeche_FP_VerEntsorgung1" ON "FP_Ver_und_Entsorgung"."FP_VerEntsorgungFlaeche" ("gid") ;


-- -----------------------------------------------------
-- Table "FP_Ver_und_Entsorgung"."FP_VerEntsorgungLinie"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Ver_und_Entsorgung"."FP_VerEntsorgungLinie" (
  "gid" INTEGER NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_VerEntsorgungLinie_FP_VerEntsorgung1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Ver_und_Entsorgung"."FP_VerEntsorgung" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
;

CREATE INDEX "idx_fk_FP_VerEntsorgungFlaeche_FP_VerEntsorgung1" ON "FP_Ver_und_Entsorgung"."FP_VerEntsorgungLinie" ("gid") ;


-- -----------------------------------------------------
-- Table "FP_Ver_und_Entsorgung"."FP_VerEntsorgungPunkt"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Ver_und_Entsorgung"."FP_VerEntsorgungPunkt" (
  "gid" INTEGER NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_VerEntsorgungPunkt_FP_VerEntsorgung1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Ver_und_Entsorgung"."FP_VerEntsorgung" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
;

CREATE INDEX "idx_fk_FP_VerEntsorgungFlaeche_FP_VerEntsorgung1" ON "FP_Ver_und_Entsorgung"."FP_VerEntsorgungPunkt" ("gid") ;


-- -----------------------------------------------------
-- Table "FP_Verkehr"."FP_ZweckbestimmungStrassenverkehr"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Verkehr"."FP_ZweckbestimmungStrassenverkehr" (
  "Wert" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(255) NOT NULL ,
  PRIMARY KEY ("Wert") )
;


-- -----------------------------------------------------
-- Table "FP_Verkehr"."FP_BesondereZweckbestimmungStrassenverkehr"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Verkehr"."FP_BesondereZweckbestimmungStrassenverkehr" (
  "Wert" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(255) NOT NULL ,
  PRIMARY KEY ("Wert") )
;


-- -----------------------------------------------------
-- Table "FP_Verkehr"."FP_DetailZweckbestStrassenverkehr"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Verkehr"."FP_DetailZweckbestStrassenverkehr" (
  "Wert" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(255) NOT NULL ,
  PRIMARY KEY ("Wert") )
;


-- -----------------------------------------------------
-- Table "FP_Verkehr"."FP_Strassenverkehr"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Verkehr"."FP_Strassenverkehr" (
  "gid" INTEGER NOT NULL ,
  "zweckbestimmung" INTEGER NULL ,
  "besondereZweckbestimmung" INTEGER NULL ,
  "detaillierteZweckbestimmung" INTEGER NULL ,
  "nutzungsform" INTEGER NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_Strassenverkehr_FP_ZweckStrassenverkehr"
    FOREIGN KEY ("zweckbestimmung" )
    REFERENCES "FP_Verkehr"."FP_ZweckbestimmungStrassenverkehr" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_Strassenverkehr_FP_BesZweckStrassenverk1"
    FOREIGN KEY ("besondereZweckbestimmung" )
    REFERENCES "FP_Verkehr"."FP_BesondereZweckbestimmungStrassenverkehr" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_Strassenverkehr_FP_DetailZweckStrassenverkehr1"
    FOREIGN KEY ("detaillierteZweckbestimmung" )
    REFERENCES "FP_Verkehr"."FP_DetailZweckbestStrassenverkehr" ("Wert" )
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_Strassenverkehr_XP_Nutzungsform1"
    FOREIGN KEY ("nutzungsform" )
    REFERENCES "XP_Enumerationen"."XP_Nutzungsform" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_Strassenverkehr_FP_Objekt1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Basisobjekte"."FP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
;

CREATE INDEX "idx_fk_FP_Strassenverkehr_FP_ZweckStrassenverkehr" ON "FP_Verkehr"."FP_Strassenverkehr" ("zweckbestimmung") ;

CREATE INDEX "idx_fk_FP_Strassenverkehr_FP_BesZweckStrassenverk1" ON "FP_Verkehr"."FP_Strassenverkehr" ("besondereZweckbestimmung") ;

CREATE INDEX "idx_fk_FP_Strassenverkehr_FP_DetailZweckStrassenverkehr1" ON "FP_Verkehr"."FP_Strassenverkehr" ("detaillierteZweckbestimmung") ;

CREATE INDEX "idx_fk_FP_Strassenverkehr_XP_Nutzungsform1" ON "FP_Verkehr"."FP_Strassenverkehr" ("nutzungsform") ;

CREATE INDEX "idx_fk_FP_Strassenverkehr_FP_Objekt1" ON "FP_Verkehr"."FP_Strassenverkehr" ("gid") ;


-- -----------------------------------------------------
-- Table "FP_Verkehr"."FP_StrassenverkehrFlaeche"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Verkehr"."FP_StrassenverkehrFlaeche" (
  "gid" INTEGER NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_StrassenverkehrFlaeche_FP_Strassenverkehr1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Verkehr"."FP_Strassenverkehr" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
;

CREATE INDEX "idx_fk_FP_StrassenverkehrFlaeche_FP_Strassenverkehr1" ON "FP_Verkehr"."FP_StrassenverkehrFlaeche" ("gid") ;


-- -----------------------------------------------------
-- Table "FP_Verkehr"."FP_StrassenverkehrLinie"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Verkehr"."FP_StrassenverkehrLinie" (
  "gid" INTEGER NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_StrassenverkehrLinie_FP_Strassenverkehr1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Verkehr"."FP_Strassenverkehr" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
;

CREATE INDEX "idx_fk_FP_StrassenverkehrFlaeche_FP_Strassenverkehr1" ON "FP_Verkehr"."FP_StrassenverkehrLinie" ("gid") ;


-- -----------------------------------------------------
-- Table "FP_Verkehr"."FP_StrassenverkehrPunkt"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Verkehr"."FP_StrassenverkehrPunkt" (
  "gid" INTEGER NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_StrassenverkehrPunkt_FP_Strassenverkehr1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Verkehr"."FP_Strassenverkehr" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
;

CREATE INDEX "idx_fk_FP_StrassenverkehrFlaeche_FP_Strassenverkehr1" ON "FP_Verkehr"."FP_StrassenverkehrPunkt" ("gid") ;


-- -----------------------------------------------------
-- Table "FP_Wasser"."FP_DetailZweckbestGewaesser"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Wasser"."FP_DetailZweckbestGewaesser" (
  "Wert" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(255) NOT NULL ,
  PRIMARY KEY ("Wert") )
;


-- -----------------------------------------------------
-- Table "FP_Wasser"."FP_Gewaesser"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Wasser"."FP_Gewaesser" (
  "gid" INTEGER NOT NULL ,
  "zweckbestimmung" INTEGER NOT NULL ,
  "detaillierteZweckbestimmung" INTEGER NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_Gewaesser_XP_ZweckbestimmungGewaesser"
    FOREIGN KEY ("zweckbestimmung" )
    REFERENCES "XP_Enumerationen"."XP_ZweckbestimmungGewaesser" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_Gewaesser_FP_DetailZweckbestGewaesser1"
    FOREIGN KEY ("detaillierteZweckbestimmung" )
    REFERENCES "FP_Wasser"."FP_DetailZweckbestGewaesser" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_Gewaesser_FP_Objekt1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Basisobjekte"."FP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
;

CREATE INDEX "idx_fk_FP_Gewaesser_XP_ZweckbestimmungGewaesser" ON "FP_Wasser"."FP_Gewaesser" ("zweckbestimmung") ;

CREATE INDEX "idx_fk_FP_Gewaesser_FP_DetailZweckbestGewaesser1" ON "FP_Wasser"."FP_Gewaesser" ("detaillierteZweckbestimmung") ;

CREATE INDEX "idx_fk_FP_Gewaesser_FP_Objekt1" ON "FP_Wasser"."FP_Gewaesser" ("gid") ;


-- -----------------------------------------------------
-- Table "FP_Wasser"."FP_DetailZweckbestWasserwirtschaft"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Wasser"."FP_DetailZweckbestWasserwirtschaft" (
  "Wert" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(255) NOT NULL ,
  PRIMARY KEY ("Wert") )
;


-- -----------------------------------------------------
-- Table "FP_Wasser"."FP_Wasserwirtschaft"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Wasser"."FP_Wasserwirtschaft" (
  "zweckbestimmung" INTEGER NULL ,
  "detaillierteZweckbestimmung" INTEGER NULL ,
  "gid" INTEGER NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_Wasserwirtschaft_XP_ZweckbestimmungWasserwirtschaft1"
    FOREIGN KEY ("zweckbestimmung" )
    REFERENCES "XP_Enumerationen"."XP_ZweckbestimmungWasserwirtschaft" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT "fk_FP_Wasserwirtschaft_FP_DetailZweckbestWasserwirtschaft1"
    FOREIGN KEY ("detaillierteZweckbestimmung" )
    REFERENCES "FP_Wasser"."FP_DetailZweckbestWasserwirtschaft" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT "fk_FP_Wasserwirtschaft_FP_Objekt1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Basisobjekte"."FP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
;

CREATE INDEX "idx_fk_FP_Wasserwirtschaft_XP_ZweckbestimmungWasserwirtschaft1" ON "FP_Wasser"."FP_Wasserwirtschaft" ("zweckbestimmung") ;

CREATE INDEX "idx_fk_FP_Wasserwirtschaft_FP_DetailZweckbestWasserwirtschaft1" ON "FP_Wasser"."FP_Wasserwirtschaft" ("detaillierteZweckbestimmung") ;

CREATE INDEX "idx_fk_FP_Wasserwirtschaft_FP_Objekt1" ON "FP_Wasser"."FP_Wasserwirtschaft" ("gid") ;


-- -----------------------------------------------------
-- Table "FP_Wasser"."FP_GewaesserFlaeche"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Wasser"."FP_GewaesserFlaeche" (
  "gid" INTEGER NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_GewaesserFlaeche_FP_Gewaesser1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Wasser"."FP_Gewaesser" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
;

CREATE INDEX "idx_fk_FP_GewaesserFlaeche_FP_Gewaesser1" ON "FP_Wasser"."FP_GewaesserFlaeche" ("gid") ;


-- -----------------------------------------------------
-- Table "FP_Wasser"."FP_GewaesserLinie"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Wasser"."FP_GewaesserLinie" (
  "gid" INTEGER NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_GewaesserLinie_FP_Gewaesser1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Wasser"."FP_Gewaesser" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
;

CREATE INDEX "idx_fk_FP_GewaesserFlaeche_FP_Gewaesser1" ON "FP_Wasser"."FP_GewaesserLinie" ("gid") ;


-- -----------------------------------------------------
-- Table "FP_Wasser"."FP_GewaesserPunkt"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Wasser"."FP_GewaesserPunkt" (
  "gid" INTEGER NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_GewaesserPunkt_FP_Gewaesser1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Wasser"."FP_Gewaesser" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
;

CREATE INDEX "idx_fk_FP_GewaesserFlaeche_FP_Gewaesser1" ON "FP_Wasser"."FP_GewaesserPunkt" ("gid") ;


-- -----------------------------------------------------
-- Table "FP_Wasser"."FP_WasserwirtschaftFlaeche"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Wasser"."FP_WasserwirtschaftFlaeche" (
  "gid" INTEGER NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_WasserwirtschaftFlaeche_FP_Wasserwirtschaft1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Wasser"."FP_Wasserwirtschaft" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
;

CREATE INDEX "idx_fk_FP_WasserwirtschaftFlaeche_FP_Wasserwirtschaft1" ON "FP_Wasser"."FP_WasserwirtschaftFlaeche" ("gid") ;


-- -----------------------------------------------------
-- Table "FP_Wasser"."FP_WasserwirtschaftLinie"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Wasser"."FP_WasserwirtschaftLinie" (
  "gid" INTEGER NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_WasserwirtschaftLinie_FP_Wasserwirtschaft1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Wasser"."FP_Wasserwirtschaft" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
;

CREATE INDEX "idx_fk_FP_WasserwirtschaftFlaeche_FP_Wasserwirtschaft1" ON "FP_Wasser"."FP_WasserwirtschaftLinie" ("gid") ;


-- -----------------------------------------------------
-- Table "FP_Wasser"."FP_WasserwirtschaftPunkt"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Wasser"."FP_WasserwirtschaftPunkt" (
  "gid" INTEGER NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_WasserwirtschaftPunkt_FP_Wasserwirtschaft1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Wasser"."FP_Wasserwirtschaft" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
;

CREATE INDEX "idx_fk_FP_WasserwirtschaftFlaeche_FP_Wasserwirtschaft1" ON "FP_Wasser"."FP_WasserwirtschaftPunkt" ("gid") ;


-- -----------------------------------------------------
-- Table "FP_Aufschuettung_Abgrabung"."FP_AufschuettungsFlaeche"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Aufschuettung_Abgrabung"."FP_AufschuettungsFlaeche" (
  "gid" INTEGER NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_AufschuettungsFlaeche_FP_Objekt"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Basisobjekte"."FP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
;

CREATE INDEX "idx_fk_FP_AufschuettungsFlaeche_FP_Objekt" ON "FP_Aufschuettung_Abgrabung"."FP_AufschuettungsFlaeche" ("gid") ;


-- -----------------------------------------------------
-- Table "FP_Aufschuettung_Abgrabung"."FP_AbgrabungsFlaeche"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Aufschuettung_Abgrabung"."FP_AbgrabungsFlaeche" (
  "gid" INTEGER NOT NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_AbgrabungsFlaeche_FP_Objekt0"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Basisobjekte"."FP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
;

CREATE INDEX "idx_fk_table1_FP_Objekt" ON "FP_Aufschuettung_Abgrabung"."FP_AbgrabungsFlaeche" ("gid") ;


-- -----------------------------------------------------
-- Table "FP_Aufschuettung_Abgrabung"."FP_BodenschaetzeFlaeche"
-- -----------------------------------------------------
CREATE  TABLE  "FP_Aufschuettung_Abgrabung"."FP_BodenschaetzeFlaeche" (
  "gid" INTEGER NOT NULL ,
  "abbaugut" VARCHAR(255) NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_FP_FP_BodenschaetzeFlaeche_FP_Objekt1"
    FOREIGN KEY ("gid" )
    REFERENCES "FP_Basisobjekte"."FP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
;

CREATE INDEX "idx_fk_FP_AufschuettungsFlaeche_FP_Objekt" ON "FP_Aufschuettung_Abgrabung"."FP_BodenschaetzeFlaeche" ("gid") ;




-- -----------------------------------------------------
-- Data for table "FP_Basisobjekte"."FP_Verfahren"
-- -----------------------------------------------------
INSERT INTO "FP_Basisobjekte"."FP_Verfahren" ("Wert", "Bezeichner") VALUES ('1000', 'Normal');
INSERT INTO "FP_Basisobjekte"."FP_Verfahren" ("Wert", "Bezeichner") VALUES ('2000', 'Parag13');



-- -----------------------------------------------------
-- Data for table "FP_Basisobjekte"."FP_Rechtsstand"
-- -----------------------------------------------------
INSERT INTO "FP_Basisobjekte"."FP_Rechtsstand" ("Wert", "Bezeichner") VALUES ('1000', 'Aufstellungsbeschluss');
INSERT INTO "FP_Basisobjekte"."FP_Rechtsstand" ("Wert", "Bezeichner") VALUES ('2000', 'Entwurf');
INSERT INTO "FP_Basisobjekte"."FP_Rechtsstand" ("Wert", "Bezeichner") VALUES ('2100', 'FruehzeitigeBehoerdenBeteiligung');
INSERT INTO "FP_Basisobjekte"."FP_Rechtsstand" ("Wert", "Bezeichner") VALUES ('2200', 'FruehzeitigeOeffentlichkeitsBeteiligung');
INSERT INTO "FP_Basisobjekte"."FP_Rechtsstand" ("Wert", "Bezeichner") VALUES ('2300', 'BehoerdenBeteiligung');
INSERT INTO "FP_Basisobjekte"."FP_Rechtsstand" ("Wert", "Bezeichner") VALUES ('2400', 'OeffentlicheAuslegung');
INSERT INTO "FP_Basisobjekte"."FP_Rechtsstand" ("Wert", "Bezeichner") VALUES ('3000', 'Plan');
INSERT INTO "FP_Basisobjekte"."FP_Rechtsstand" ("Wert", "Bezeichner") VALUES ('4000', 'Wirksamkeit');
INSERT INTO "FP_Basisobjekte"."FP_Rechtsstand" ("Wert", "Bezeichner") VALUES ('5000', 'Untergegangen');



-- -----------------------------------------------------
-- Data for table "FP_Basisobjekte"."FP_PlanArt"
-- -----------------------------------------------------
INSERT INTO "FP_Basisobjekte"."FP_PlanArt" ("Wert", "Bezeichner") VALUES ('1000', 'FPlan');
INSERT INTO "FP_Basisobjekte"."FP_PlanArt" ("Wert", "Bezeichner") VALUES ('2000', 'GemeinsamerFPlan');
INSERT INTO "FP_Basisobjekte"."FP_PlanArt" ("Wert", "Bezeichner") VALUES ('3000', 'RegFPlan');
INSERT INTO "FP_Basisobjekte"."FP_PlanArt" ("Wert", "Bezeichner") VALUES ('4000', 'FPlanRegPlan');
INSERT INTO "FP_Basisobjekte"."FP_PlanArt" ("Wert", "Bezeichner") VALUES ('9999', 'Sonstiges');



-- -----------------------------------------------------
-- Data for table "FP_Basisobjekte"."FP_Rechtscharakter"
-- -----------------------------------------------------
INSERT INTO "FP_Basisobjekte"."FP_Rechtscharakter" ("Wert", "Bezeichner") VALUES ('1000', 'Darstellung');
INSERT INTO "FP_Basisobjekte"."FP_Rechtscharakter" ("Wert", "Bezeichner") VALUES ('3000', 'Hinweis');
INSERT INTO "FP_Basisobjekte"."FP_Rechtscharakter" ("Wert", "Bezeichner") VALUES ('4000', 'Vermerk');
INSERT INTO "FP_Basisobjekte"."FP_Rechtscharakter" ("Wert", "Bezeichner") VALUES ('5000', 'Kennzeichnung');



-- -----------------------------------------------------
-- Data for table "FP_Sonstiges"."FP_ZweckbestimmungPrivilegiertesVorhaben"
-- -----------------------------------------------------
INSERT INTO "FP_Sonstiges"."FP_ZweckbestimmungPrivilegiertesVorhaben" ("Wert", "Bezeichner") VALUES ('1000', 'LandForstwirtschaft');
INSERT INTO "FP_Sonstiges"."FP_ZweckbestimmungPrivilegiertesVorhaben" ("Wert", "Bezeichner") VALUES ('1200', 'OeffentlicheVersorgung');
INSERT INTO "FP_Sonstiges"."FP_ZweckbestimmungPrivilegiertesVorhaben" ("Wert", "Bezeichner") VALUES ('1400', 'OrtsgebundenerGewerbebetrieb');
INSERT INTO "FP_Sonstiges"."FP_ZweckbestimmungPrivilegiertesVorhaben" ("Wert", "Bezeichner") VALUES ('1600', 'BesonderesVorhaben');
INSERT INTO "FP_Sonstiges"."FP_ZweckbestimmungPrivilegiertesVorhaben" ("Wert", "Bezeichner") VALUES ('1800', 'ErneuerbareEnergie');
INSERT INTO "FP_Sonstiges"."FP_ZweckbestimmungPrivilegiertesVorhaben" ("Wert", "Bezeichner") VALUES ('2000', 'Kernenergie');
INSERT INTO "FP_Sonstiges"."FP_ZweckbestimmungPrivilegiertesVorhaben" ("Wert", "Bezeichner") VALUES ('9999', 'Sonstiges');



-- -----------------------------------------------------
-- Data for table "FP_Sonstiges"."FP_BesondZweckbestPrivilegiertesVorhaben"
-- -----------------------------------------------------
INSERT INTO "FP_Sonstiges"."FP_BesondZweckbestPrivilegiertesVorhaben" ("Wert", "Bezeichner") VALUES ('10000', 'Aussiedlerhof');
INSERT INTO "FP_Sonstiges"."FP_BesondZweckbestPrivilegiertesVorhaben" ("Wert", "Bezeichner") VALUES ('10001', 'Altenteil');
INSERT INTO "FP_Sonstiges"."FP_BesondZweckbestPrivilegiertesVorhaben" ("Wert", "Bezeichner") VALUES ('10002', 'Reiterhof');
INSERT INTO "FP_Sonstiges"."FP_BesondZweckbestPrivilegiertesVorhaben" ("Wert", "Bezeichner") VALUES ('10003', 'Gartenbaubetrieb');
INSERT INTO "FP_Sonstiges"."FP_BesondZweckbestPrivilegiertesVorhaben" ("Wert", "Bezeichner") VALUES ('10004', 'Baumschule');
INSERT INTO "FP_Sonstiges"."FP_BesondZweckbestPrivilegiertesVorhaben" ("Wert", "Bezeichner") VALUES ('12000', 'Wasser');
INSERT INTO "FP_Sonstiges"."FP_BesondZweckbestPrivilegiertesVorhaben" ("Wert", "Bezeichner") VALUES ('12001', 'Gas');
INSERT INTO "FP_Sonstiges"."FP_BesondZweckbestPrivilegiertesVorhaben" ("Wert", "Bezeichner") VALUES ('12002', 'Waerme');
INSERT INTO "FP_Sonstiges"."FP_BesondZweckbestPrivilegiertesVorhaben" ("Wert", "Bezeichner") VALUES ('12003', 'Elektrizitaet');
INSERT INTO "FP_Sonstiges"."FP_BesondZweckbestPrivilegiertesVorhaben" ("Wert", "Bezeichner") VALUES ('12004', 'Telekommunikation');
INSERT INTO "FP_Sonstiges"."FP_BesondZweckbestPrivilegiertesVorhaben" ("Wert", "Bezeichner") VALUES ('12005', 'Abwasser');
INSERT INTO "FP_Sonstiges"."FP_BesondZweckbestPrivilegiertesVorhaben" ("Wert", "Bezeichner") VALUES ('16000', 'BesondereUmgebungsAnforderung');
INSERT INTO "FP_Sonstiges"."FP_BesondZweckbestPrivilegiertesVorhaben" ("Wert", "Bezeichner") VALUES ('16001', 'NachteiligeUmgebungsWirkung');
INSERT INTO "FP_Sonstiges"."FP_BesondZweckbestPrivilegiertesVorhaben" ("Wert", "Bezeichner") VALUES ('16002', 'BesondereZweckbestimmung');
INSERT INTO "FP_Sonstiges"."FP_BesondZweckbestPrivilegiertesVorhaben" ("Wert", "Bezeichner") VALUES ('18000', 'Windenergie');
INSERT INTO "FP_Sonstiges"."FP_BesondZweckbestPrivilegiertesVorhaben" ("Wert", "Bezeichner") VALUES ('18001', 'Wasserenergie');
INSERT INTO "FP_Sonstiges"."FP_BesondZweckbestPrivilegiertesVorhaben" ("Wert", "Bezeichner") VALUES ('18002', 'Solarenergie');
INSERT INTO "FP_Sonstiges"."FP_BesondZweckbestPrivilegiertesVorhaben" ("Wert", "Bezeichner") VALUES ('18003', 'Biomasse');
INSERT INTO "FP_Sonstiges"."FP_BesondZweckbestPrivilegiertesVorhaben" ("Wert", "Bezeichner") VALUES ('20000', 'NutzungKernerergie');
INSERT INTO "FP_Sonstiges"."FP_BesondZweckbestPrivilegiertesVorhaben" ("Wert", "Bezeichner") VALUES ('20001', 'EntsorgungRadioaktiveAbfaelle');
INSERT INTO "FP_Sonstiges"."FP_BesondZweckbestPrivilegiertesVorhaben" ("Wert", "Bezeichner") VALUES ('99990', 'StandortEinzelhof');
INSERT INTO "FP_Sonstiges"."FP_BesondZweckbestPrivilegiertesVorhaben" ("Wert", "Bezeichner") VALUES ('99991', 'BebauteFlaecheAussenbereich');



-- -----------------------------------------------------
-- Data for table "FP_Verkehr"."FP_ZweckbestimmungStrassenverkehr"
-- -----------------------------------------------------
INSERT INTO "FP_Verkehr"."FP_ZweckbestimmungStrassenverkehr" ("Wert", "Bezeichner") VALUES ('1000', 'Autobahn');
INSERT INTO "FP_Verkehr"."FP_ZweckbestimmungStrassenverkehr" ("Wert", "Bezeichner") VALUES ('1200', 'Hauptverkehrsstrasse');
INSERT INTO "FP_Verkehr"."FP_ZweckbestimmungStrassenverkehr" ("Wert", "Bezeichner") VALUES ('1400', 'SonstigerVerkehrswegAnlage');
INSERT INTO "FP_Verkehr"."FP_ZweckbestimmungStrassenverkehr" ("Wert", "Bezeichner") VALUES ('1600', 'RuhenderVerkehr');
INSERT INTO "FP_Verkehr"."FP_ZweckbestimmungStrassenverkehr" ("Wert", "Bezeichner") VALUES ('9999', 'Sonstiges');



-- -----------------------------------------------------
-- Data for table "FP_Verkehr"."FP_BesondereZweckbestimmungStrassenverkehr"
-- -----------------------------------------------------
INSERT INTO "FP_Verkehr"."FP_BesondereZweckbestimmungStrassenverkehr" ("Wert", "Bezeichner") VALUES ('14000', 'VerkehrsberuhigterBereich');
INSERT INTO "FP_Verkehr"."FP_BesondereZweckbestimmungStrassenverkehr" ("Wert", "Bezeichner") VALUES ('14001', 'Platz');
INSERT INTO "FP_Verkehr"."FP_BesondereZweckbestimmungStrassenverkehr" ("Wert", "Bezeichner") VALUES ('14002', 'Fussgaengerbereich');
INSERT INTO "FP_Verkehr"."FP_BesondereZweckbestimmungStrassenverkehr" ("Wert", "Bezeichner") VALUES ('14003', 'RadFussweg');
INSERT INTO "FP_Verkehr"."FP_BesondereZweckbestimmungStrassenverkehr" ("Wert", "Bezeichner") VALUES ('14004', 'Radweg');
INSERT INTO "FP_Verkehr"."FP_BesondereZweckbestimmungStrassenverkehr" ("Wert", "Bezeichner") VALUES ('14005', 'Fussweg');
INSERT INTO "FP_Verkehr"."FP_BesondereZweckbestimmungStrassenverkehr" ("Wert", "Bezeichner") VALUES ('14006', 'Wanderweg');
INSERT INTO "FP_Verkehr"."FP_BesondereZweckbestimmungStrassenverkehr" ("Wert", "Bezeichner") VALUES ('14007', 'ReitKutschweg');
INSERT INTO "FP_Verkehr"."FP_BesondereZweckbestimmungStrassenverkehr" ("Wert", "Bezeichner") VALUES ('14008', 'Rastanlage');
INSERT INTO "FP_Verkehr"."FP_BesondereZweckbestimmungStrassenverkehr" ("Wert", "Bezeichner") VALUES ('14009', 'Busbahnhof');
INSERT INTO "FP_Verkehr"."FP_BesondereZweckbestimmungStrassenverkehr" ("Wert", "Bezeichner") VALUES ('14010', 'UeberfuehrenderVerkehrsweg');
INSERT INTO "FP_Verkehr"."FP_BesondereZweckbestimmungStrassenverkehr" ("Wert", "Bezeichner") VALUES ('14011', 'UnterfuehrenderVerkehrsweg');


