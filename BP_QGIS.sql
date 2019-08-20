/* *************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 ************************************************************************* */

-- *****************************************************
-- CREATE Views für BP
-- *****************************************************

-- -----------------------------------------------------
-- View "BP_Basisobjekte"."BP_Plan_qv"
-- -----------------------------------------------------

CREATE OR REPLACE VIEW "BP_Basisobjekte"."BP_Plan_qv" AS
SELECT x.gid, b."raeumlicherGeltungsbereich", x.name, x.nummer, x."internalId", x.beschreibung, x.kommentar,
    x."technHerstellDatum", x."genehmigungsDatum", x."untergangsDatum", x."erstellungsMassstab",
    x.bezugshoehe, b."sonstPlanArt", b.verfahren, b.rechtsstand, b.status, b.hoehenbezug, b."aenderungenBisDatum",
    b."aufstellungsbeschlussDatum", b."veraenderungssperreDatum", b."satzungsbeschlussDatum", b."rechtsverordnungsDatum",
    b."inkrafttretensDatum", b."ausfertigungsDatum", b.veraenderungssperre, b."staedtebaulicherVertrag",
    b."erschliessungsVertrag",  b."durchfuehrungsVertrag", b.gruenordnungsplan
FROM "BP_Basisobjekte"."BP_Plan" b
    JOIN "XP_Basisobjekte"."XP_Plan" x ON b.gid = x.gid;

GRANT SELECT ON TABLE "BP_Basisobjekte"."BP_Plan_qv" TO xp_gast;

-- -----------------------------------------------------
-- View "BP_Basisobjekte"."BP_Bereich_qv" berücksichtigt NULL geltungsbereich
-- -----------------------------------------------------
CREATE OR REPLACE VIEW "BP_Basisobjekte"."BP_Bereich_qv" AS
SELECT b.gid ,
    COALESCE(b.geltungsbereich ,p."raeumlicherGeltungsbereich")::geometry(MultiPolygon,25832) as geltungsbereich,
    b."name" ,
    b."versionBauNVODatum" ,
    b."versionBauNVOText" ,
    b."versionBauGBDatum" ,
    b."versionBauGBText" ,
    b."versionSonstRechtsgrundlageDatum" ,
    b."versionSonstRechtsgrundlageText" ,
    b."gehoertZuPlan"
    FROM "BP_Basisobjekte"."BP_Bereich" b
    JOIN "BP_Basisobjekte"."BP_Plan" p ON b."gehoertZuPlan" = p.gid;
GRANT SELECT ON "BP_Basisobjekte"."BP_Bereich_qv" TO xp_gast;

-- -----------------------------------------------------
-- View "BP_Bebauung"."BP_BaugebietsTeilFlaeche_qv"
-- -----------------------------------------------------

CREATE OR REPLACE VIEW "BP_Bebauung"."BP_BaugebietsTeilFlaeche_qv" AS
SELECT g.*
FROM "BP_Bebauung"."BP_BaugebietsTeilFlaeche" g;
GRANT SELECT ON TABLE "BP_Bebauung"."BP_BaugebietsTeilFlaeche_qv" TO xp_gast;

-- -----------------------------------------------------
-- View "BP_Gemeinbedarf_Spiel_und_Sportanlagen"."BP_GemeinbedarfsFlaeche_qv"
-- -----------------------------------------------------

CREATE OR REPLACE VIEW "BP_Gemeinbedarf_Spiel_und_Sportanlagen"."BP_GemeinbedarfsFlaeche_qv" AS
SELECT g.gid,g.position,z1 as zweckbestimmung1,z2 as zweckbestimmung2,z3 as zweckbestimmung3,z4 as zweckbestimmung4,
 coalesce(z1 / z1, 0) + coalesce(z2 / z2, 0) + coalesce(z3 / z3, 0) + coalesce(z4 / z4, 0) as anz_zweckbestimmung,
 CASE WHEN z1 > 9999 or z2 > 9999 or z3 > 9999 or z4 > 9999 THEN
    CASE WHEN 2400 IN(z1,z2,z3,z4) THEN 'SicherheitOrdnung'
    WHEN 2600 IN (z1,z2,z3,z4) THEN 'Infrastruktur'
    END
 ELSE
    zl1."Bezeichner"
 END as label1,
zl2."Bezeichner" as label2,
zl3."Bezeichner" as label3,
zl4."Bezeichner" as label4
  FROM
 "BP_Gemeinbedarf_Spiel_und_Sportanlagen"."BP_GemeinbedarfsFlaeche" g
 LEFT JOIN
 crosstab('SELECT "BP_GemeinbedarfsFlaeche_gid", "BP_GemeinbedarfsFlaeche_gid", zweckbestimmung FROM "BP_Gemeinbedarf_Spiel_und_Sportanlagen"."BP_GemeinbedarfsFlaeche_zweckbestimmung" ORDER BY 1,3') zt
 (zgid bigint, z1 integer,z2 integer,z3 integer,z4 integer)
 ON g.gid=zt.zgid
  LEFT JOIN "XP_Enumerationen"."XP_ZweckbestimmungGemeinbedarf" zl1 ON zt.z1 = zl1."Code"
  LEFT JOIN "XP_Enumerationen"."XP_ZweckbestimmungGemeinbedarf" zl2 ON zt.z2 = zl2."Code"
  LEFT JOIN "XP_Enumerationen"."XP_ZweckbestimmungGemeinbedarf" zl3 ON zt.z3 = zl3."Code"
  LEFT JOIN "XP_Enumerationen"."XP_ZweckbestimmungGemeinbedarf" zl4 ON zt.z4 = zl4."Code";
GRANT SELECT ON TABLE "BP_Gemeinbedarf_Spiel_und_Sportanlagen"."BP_GemeinbedarfsFlaeche_qv" TO xp_gast;

-- -----------------------------------------------------
-- View "BP_Gemeinbedarf_Spiel_und_Sportanlagen"."BP_SpielSportanlagenFlaeche_qv"
-- -----------------------------------------------------

CREATE OR REPLACE VIEW "BP_Gemeinbedarf_Spiel_und_Sportanlagen"."BP_SpielSportanlagenFlaeche_qv" AS
SELECT g.gid,g.position,z1 as zweckbestimmung1,z2 as zweckbestimmung2,z3 as zweckbestimmung3,z4 as zweckbestimmung4,
 coalesce(z1 / z1, 0) + coalesce(z2 / z2, 0) + coalesce(z3 / z3, 0) + coalesce(z4 / z4, 0) as anz_zweckbestimmung,
 CASE WHEN z1 = 3000 THEN
    'SpielSportanlage'
ELSE
    NULL
END as label1
  FROM
 "BP_Gemeinbedarf_Spiel_und_Sportanlagen"."BP_SpielSportanlagenFlaeche" g
 LEFT JOIN
 crosstab('SELECT "BP_SpielSportanlagenFlaeche_gid", "BP_SpielSportanlagenFlaeche_gid", zweckbestimmung FROM "BP_Gemeinbedarf_Spiel_und_Sportanlagen"."BP_SpielSportanlagenFlaeche_zweckbestimmung" ORDER BY 1,3') zt
 (zgid bigint, z1 integer,z2 integer,z3 integer,z4 integer)
 ON g.gid=zt.zgid;
GRANT SELECT ON TABLE "BP_Gemeinbedarf_Spiel_und_Sportanlagen"."BP_SpielSportanlagenFlaeche_qv" TO xp_gast;

-- -----------------------------------------------------
-- View "BP_Landwirtschaft_Wald_und_Gruen"."BP_GruenFlaeche_qv"
-- -----------------------------------------------------

CREATE OR REPLACE VIEW "BP_Landwirtschaft_Wald_und_Gruen"."BP_GruenFlaeche_qv" AS
SELECT g.gid,g.position,z1 as zweckbestimmung1,z2 as zweckbestimmung2,z3 as zweckbestimmung3,z4 as zweckbestimmung4,
 coalesce(z1 / z1, 0) + coalesce(z2 / z2, 0) + coalesce(z3 / z3, 0) + coalesce(z4 / z4, 0) as anz_zweckbestimmung,
 CASE WHEN z1 <= 9999 THEN
    CASE WHEN 2200 IN(z1,z2,z3,z4) THEN 'FreizeitErholung'
    END
ELSE
    CASE WHEN z1 IN (12000,14004,16000,22000,24000,24001) THEN
        NULL
    ELSE
        zl1."Bezeichner"
    END
END as label1,
CASE WHEN z1 <= 9999 THEN
    CASE WHEN 2400 IN (z1,z2,z3,z4) THEN 'Spez. Gruenflaeche'
    END
ELSE
    CASE WHEN z2 IN (12000,14004,16000,22000,24000,24001) THEN
        NULL
    ELSE
        zl2."Bezeichner"
    END
END as label2,
CASE WHEN z3 IN (12000,14004,16000,22000,24000,24001) THEN
    NULL
ELSE
    zl3."Bezeichner"
END as label3,
CASE WHEN z4 IN (12000,14004,16000,22000,24000,24001) THEN
    NULL
ELSE
    zl4."Bezeichner"
END as label4
FROM "BP_Landwirtschaft_Wald_und_Gruen"."BP_GruenFlaeche" g
    LEFT JOIN crosstab('SELECT "BP_GruenFlaeche_gid", "BP_GruenFlaeche_gid", zweckbestimmung FROM "BP_Landwirtschaft_Wald_und_Gruen"."BP_GruenFlaeche_zweckbestimmung" ORDER BY 1,3') zt
        (zgid bigint, z1 integer,z2 integer,z3 integer,z4 integer)
    ON g.gid=zt.zgid
    LEFT JOIN "XP_Enumerationen"."XP_ZweckbestimmungGruen" zl1 ON zt.z1 = zl1."Code"
    LEFT JOIN "XP_Enumerationen"."XP_ZweckbestimmungGruen" zl2 ON zt.z2 = zl2."Code"
    LEFT JOIN "XP_Enumerationen"."XP_ZweckbestimmungGruen" zl3 ON zt.z3 = zl3."Code"
    LEFT JOIN "XP_Enumerationen"."XP_ZweckbestimmungGruen" zl4 ON zt.z4 = zl4."Code";
GRANT SELECT ON TABLE "BP_Landwirtschaft_Wald_und_Gruen"."BP_GruenFlaeche_qv" TO xp_gast;

-- -----------------------------------------------------
-- View "BP_Landwirtschaft_Wald_und_Gruen"."BP_WaldFlaeche_qv"
-- -----------------------------------------------------

CREATE OR REPLACE VIEW "BP_Landwirtschaft_Wald_und_Gruen"."BP_WaldFlaeche_qv" AS
SELECT g.gid,g.position,z1 as zweckbestimmung1,z2 as zweckbestimmung2,z3 as zweckbestimmung3,z4 as zweckbestimmung4,
 coalesce(z1 / z1, 0) + coalesce(z2 / z2, 0) + coalesce(z3 / z3, 0) + coalesce(z4 / z4, 0) as anz_zweckbestimmung
  FROM
 "BP_Landwirtschaft_Wald_und_Gruen"."BP_WaldFlaeche" g
 LEFT JOIN
 crosstab('SELECT "BP_WaldFlaeche_gid", "BP_WaldFlaeche_gid", zweckbestimmung FROM "BP_Landwirtschaft_Wald_und_Gruen"."BP_WaldFlaeche_zweckbestimmung" ORDER BY 1,3') zt
 (zgid bigint, z1 integer,z2 integer,z3 integer,z4 integer)
 ON g.gid=zt.zgid;
GRANT SELECT ON TABLE "BP_Landwirtschaft_Wald_und_Gruen"."BP_WaldFlaeche_qv" TO xp_gast;

-- -----------------------------------------------------
-- View "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_AnpflanzungBindungErhaltung_qv"
-- -----------------------------------------------------

CREATE OR REPLACE VIEW "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_AnpflanzungBindungErhaltung_qv" AS
SELECT g.gid,g.massnahme,z1 as gegenstand1,z2 as gegenstand2,z3 as gegenstand3,z4 as gegenstand4,
 coalesce(z1 / z1, 0) + coalesce(z2 / z2, 0) + coalesce(z3 / z3, 0) + coalesce(z4 / z4, 0) as anz_gegenstand
  FROM
 "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_AnpflanzungBindungErhaltung" g
  LEFT JOIN
 crosstab('SELECT "BP_AnpflanzungBindungErhaltung_gid", "BP_AnpflanzungBindungErhaltung_gid", gegenstand FROM "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_AnpflanzungBindungErhaltung_gegenstand" ORDER BY 1,3') zt
 (zgid bigint, z1 integer,z2 integer,z3 integer,z4 integer)
 ON g.gid=zt.zgid;
GRANT SELECT ON TABLE "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_AnpflanzungBindungErhaltung_qv" TO xp_gast;

-- -----------------------------------------------------
-- View "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_AnpflanzungBindungErhaltungFlaeche_qv"
-- -----------------------------------------------------

CREATE OR REPLACE VIEW "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_AnpflanzungBindungErhaltungFlaeche_qv" AS
SELECT g.position,p.*
  FROM
 "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_AnpflanzungBindungErhaltungFlaeche" g
  JOIN
 "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_AnpflanzungBindungErhaltung_qv" p
 ON g.gid=p.gid;
GRANT SELECT ON TABLE "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_AnpflanzungBindungErhaltungFlaeche_qv" TO xp_gast;

-- -----------------------------------------------------
-- View "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_AnpflanzungBindungErhaltungLinie_qv"
-- -----------------------------------------------------

CREATE OR REPLACE VIEW "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_AnpflanzungBindungErhaltungLinie_qv" AS
SELECT g.position,p.*
  FROM
 "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_AnpflanzungBindungErhaltungLinie" g
  JOIN
 "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_AnpflanzungBindungErhaltung_qv" p
 ON g.gid=p.gid;
GRANT SELECT ON TABLE "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_AnpflanzungBindungErhaltungLinie_qv" TO xp_gast;

-- -----------------------------------------------------
-- View "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_AnpflanzungBindungErhaltungPunkt_qv"
-- -----------------------------------------------------

CREATE OR REPLACE VIEW "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_AnpflanzungBindungErhaltungPunkt_qv" AS
SELECT g.position,p.*
  FROM
 "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_AnpflanzungBindungErhaltungPunkt" g
  JOIN
 "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_AnpflanzungBindungErhaltung_qv" p
 ON g.gid=p.gid;
GRANT SELECT ON TABLE "BP_Naturschutz_Landschaftsbild_Naturhaushalt"."BP_AnpflanzungBindungErhaltungPunkt_qv" TO xp_gast;

-- -----------------------------------------------------
-- View "BP_Sonstiges"."BP_KennzeichnungsFlaeche_qv"
-- -----------------------------------------------------

CREATE OR REPLACE VIEW "BP_Sonstiges"."BP_KennzeichnungsFlaeche_qv" AS
SELECT g.gid,g.position,z1 as zweckbestimmung1,z2 as zweckbestimmung2,z3 as zweckbestimmung3,z4 as zweckbestimmung4,
 coalesce(z1 / z1, 0) + coalesce(z2 / z2, 0) + coalesce(z3 / z3, 0) + coalesce(z4 / z4, 0) as anz_zweckbestimmung,
 CASE WHEN z1 IN (4000) THEN
    NULL
ELSE
    zl1."Bezeichner"
END as label1,
CASE WHEN z2 IN (4000) THEN
    NULL
ELSE
    zl2."Bezeichner"
END as label2,
CASE WHEN z3 IN (4000) THEN
    NULL
ELSE
    zl3."Bezeichner"
END as label3,
CASE WHEN z4 IN (4000) THEN
    NULL
ELSE
    zl4."Bezeichner"
END as label4
  FROM
 "BP_Sonstiges"."BP_KennzeichnungsFlaeche" g
 LEFT JOIN
 crosstab('SELECT "BP_KennzeichnungsFlaeche_gid", "BP_KennzeichnungsFlaeche_gid", zweckbestimmung FROM "BP_Sonstiges"."BP_KennzeichnungsFlaeche_zweckbestimmung" ORDER BY 1,3') zt
 (zgid bigint, z1 integer,z2 integer,z3 integer,z4 integer)
 ON g.gid=zt.zgid
 LEFT JOIN "XP_Enumerationen"."XP_ZweckbestimmungKennzeichnung" zl1 ON zt.z1 = zl1."Code"
    LEFT JOIN "XP_Enumerationen"."XP_ZweckbestimmungKennzeichnung" zl2 ON zt.z2 = zl2."Code"
    LEFT JOIN "XP_Enumerationen"."XP_ZweckbestimmungKennzeichnung" zl3 ON zt.z3 = zl3."Code"
    LEFT JOIN "XP_Enumerationen"."XP_ZweckbestimmungKennzeichnung" zl4 ON zt.z4 = zl4."Code";
GRANT SELECT ON TABLE "BP_Sonstiges"."BP_KennzeichnungsFlaeche_qv" TO xp_gast;

-- -----------------------------------------------------
-- View "BP_Ver_und_Entsorgung"."BP_VerEntsorgung_qv"
-- -----------------------------------------------------
CREATE OR REPLACE VIEW "BP_Ver_und_Entsorgung"."BP_VerEntsorgung_qv" AS
 SELECT g.gid, xpo.ebene, z1 as zweckbestimmung1,z2 as zweckbestimmung2,z3 as zweckbestimmung3,z4 as zweckbestimmung4,
 coalesce(z1 / z1, 0) + coalesce(z2 / z2, 0) + coalesce(z3 / z3, 0) + coalesce(z4 / z4, 0) as anz_zweckbestimmung,
CASE WHEN 2000 IN(z1,z2,z3,z4) THEN 'Regenwasser'
ELSE
    NULL
END as label1,
CASE WHEN 2600 IN (z1,z2,z3,z4) THEN 'Telekomm.'
ELSE NULL
END as label2,
CASE WHEN 10000 IN (z1,z2,z3,z4) THEN 'Hochspannungsleitung'
ELSE NULL
END as label3
  FROM
 "BP_Ver_und_Entsorgung"."BP_VerEntsorgung" g
 JOIN "XP_Basisobjekte"."XP_Objekt" xpo ON g.gid = xpo.gid
 LEFT JOIN
 crosstab('SELECT "BP_VerEntsorgung_gid", "BP_VerEntsorgung_gid", zweckbestimmung FROM "BP_Ver_und_Entsorgung"."BP_VerEntsorgung_zweckbestimmung" ORDER BY 1,3') zt
 (zgid bigint, z1 integer,z2 integer,z3 integer,z4 integer)
 ON g.gid=zt.zgid;
GRANT SELECT ON TABLE "BP_Ver_und_Entsorgung"."BP_VerEntsorgung_qv" TO xp_gast;

-- -----------------------------------------------------
-- View "BP_Ver_und_Entsorgung"."BP_VerEntsorgungFlaeche_qv"
-- -----------------------------------------------------
CREATE OR REPLACE VIEW "BP_Ver_und_Entsorgung"."BP_VerEntsorgungFlaeche_qv" AS
SELECT g.position, p.*
  FROM "BP_Ver_und_Entsorgung"."BP_VerEntsorgungFlaeche" g
 JOIN "BP_Ver_und_Entsorgung"."BP_VerEntsorgung_qv" p ON g.gid = p.gid;
GRANT SELECT ON TABLE "BP_Ver_und_Entsorgung"."BP_VerEntsorgungFlaeche_qv" TO xp_gast;

-- -----------------------------------------------------
-- View "BP_Ver_und_Entsorgung"."BP_VerEntsorgungLinie_qv"
-- -----------------------------------------------------
CREATE OR REPLACE VIEW "BP_Ver_und_Entsorgung"."BP_VerEntsorgungLinie_qv" AS
SELECT g.position, p.*
  FROM "BP_Ver_und_Entsorgung"."BP_VerEntsorgungLinie" g
 JOIN "BP_Ver_und_Entsorgung"."BP_VerEntsorgung_qv" p ON g.gid = p.gid;
GRANT SELECT ON TABLE "BP_Ver_und_Entsorgung"."BP_VerEntsorgungLinie_qv" TO xp_gast;

-- -----------------------------------------------------
-- View "BP_Ver_und_Entsorgung"."BP_VerEntsorgungPunkt_qv"
-- -----------------------------------------------------
CREATE OR REPLACE VIEW "BP_Ver_und_Entsorgung"."BP_VerEntsorgungPunkt_qv" AS
SELECT g.position, p.*
  FROM "BP_Ver_und_Entsorgung"."BP_VerEntsorgungPunkt" g
 JOIN "BP_Ver_und_Entsorgung"."BP_VerEntsorgung_qv" p ON g.gid = p.gid;
GRANT SELECT ON TABLE "BP_Ver_und_Entsorgung"."BP_VerEntsorgungPunkt_qv" TO xp_gast;

-- -----------------------------------------------------
-- View "BP_Verkehr"."BP_StrassenVerkehrsFlaeche_qv"
-- -----------------------------------------------------
CREATE OR REPLACE VIEW "BP_Verkehr"."BP_StrassenVerkehrsFlaeche_qv" AS
 SELECT g.gid, g.position,xpo.ebene
 FROM
 "BP_Verkehr"."BP_StrassenVerkehrsFlaeche" g
 JOIN "XP_Basisobjekte"."XP_Objekt" xpo ON g.gid = xpo.gid;
 GRANT SELECT ON TABLE "BP_Verkehr"."BP_StrassenVerkehrsFlaeche_qv" TO xp_gast;

-- -----------------------------------------------------
-- View "BP_Verkehr"."BP_StrassenkoerperFlaeche_qv"
-- -----------------------------------------------------

CREATE OR REPLACE VIEW "BP_Verkehr"."BP_StrassenkoerperFlaeche_qv" AS
SELECT g.gid,g.position,p.typ
  FROM
 "BP_Verkehr"."BP_StrassenkoerperFlaeche" g
  JOIN
 "BP_Verkehr"."BP_Strassenkoerper" p
 ON g.gid=p.gid;
GRANT SELECT ON TABLE "BP_Verkehr"."BP_StrassenkoerperFlaeche_qv" TO xp_gast;

-- -----------------------------------------------------
-- View "BP_Verkehr"."BP_StrassenkoerperLinie_qv"
-- -----------------------------------------------------

CREATE OR REPLACE VIEW "BP_Verkehr"."BP_StrassenkoerperLinie_qv" AS
SELECT g.gid,g.position,p.typ
  FROM
 "BP_Verkehr"."BP_StrassenkoerperLinie" g
  JOIN
 "BP_Verkehr"."BP_Strassenkoerper" p
 ON g.gid=p.gid;
GRANT SELECT ON TABLE "BP_Verkehr"."BP_StrassenkoerperLinie_qv" TO xp_gast;

-- -----------------------------------------------------
-- View "BP_Verkehr"."BP_StrassenkoerperPunkt_qv"
-- -----------------------------------------------------

CREATE OR REPLACE VIEW "BP_Verkehr"."BP_StrassenkoerperPunkt_qv" AS
SELECT g.gid,g.position,p.typ
  FROM
 "BP_Verkehr"."BP_StrassenkoerperPunkt" g
  JOIN
 "BP_Verkehr"."BP_Strassenkoerper" p
 ON g.gid=p.gid;
GRANT SELECT ON TABLE "BP_Verkehr"."BP_StrassenkoerperPunkt_qv" TO xp_gast;

-- -----------------------------------------------------
-- View "BP_Verkehr"."BP_VerkehrsFlaecheBesondererZweckbestimmungFlaeche_qv"
-- -----------------------------------------------------
CREATE OR REPLACE VIEW "BP_Verkehr"."BP_VerkehrsFlaecheBesondererZweckbestimmungFlaeche_qv" AS
 SELECT g.gid, g.position,zweckbestimmung
 FROM
 "BP_Verkehr"."BP_VerkehrsFlaecheBesondererZweckbestimmungFlaeche" g
 JOIN "BP_Verkehr"."BP_VerkehrsFlaecheBesondererZweckbestimmung" p ON g.gid = p.gid;
 GRANT SELECT ON TABLE "BP_Verkehr"."BP_VerkehrsFlaecheBesondererZweckbestimmungFlaeche_qv" TO xp_gast;
