﻿/* *************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 ************************************************************************* */

-- *****************************************************
-- CREATE Views für FP
-- *****************************************************

-- -----------------------------------------------------
-- View "FP_Basisobjekte"."FP_Bereich_qv" berücksichtigt NULL geltungsbereich
-- -----------------------------------------------------
CREATE OR REPLACE VIEW "FP_Basisobjekte"."FP_Bereich_qv" AS
SELECT b.gid ,
    COALESCE(b.geltungsbereich ,p."raeumlicherGeltungsbereich")::geometry(MultiPolygon,25832) as geltungsbereich,
    b."name",
    b."versionBauNVOText" ,
    b."versionBauGBDatum" ,
    b."versionBauGBText" ,
    b."gehoertZuPlan",
    b."versionBauNVODatum" ,
    b."versionSonstRechtsgrundlageDatum" ,
    b."versionSonstRechtsgrundlageText"
FROM "FP_Basisobjekte"."FP_Bereich" b
    JOIN "FP_Basisobjekte"."FP_Plan" p ON b."gehoertZuPlan" = p.gid;
GRANT SELECT ON "FP_Basisobjekte"."FP_Bereich_qv" TO xp_gast;

-- -----------------------------------------------------
-- View "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_Gemeinbedarf_qv"
-- -----------------------------------------------------
CREATE OR REPLACE VIEW "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_Gemeinbedarf_qv" AS
SELECT g.gid,z1 as zweckbestimmung1,z2 as zweckbestimmung2,z3 as zweckbestimmung3,z4 as zweckbestimmung4,
 coalesce(z1 / z1, 0) + coalesce(z2 / z2, 0) + coalesce(z3 / z3, 0) + coalesce(z4 / z4, 0) as anz_zweckbestimmung,
 CASE WHEN z1 <= 9999  THEN
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
 "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_Gemeinbedarf" g
 LEFT JOIN
 crosstab('SELECT "FP_Gemeinbedarf_gid", "FP_Gemeinbedarf_gid", zweckbestimmung FROM "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_Gemeinbedarf_zweckbestimmung" ORDER BY 1,3') zt
 (zgid bigint, z1 integer,z2 integer,z3 integer,z4 integer)
 ON g.gid=zt.zgid
  LEFT JOIN "XP_Enumerationen"."XP_ZweckbestimmungGemeinbedarf" zl1 ON zt.z1 = zl1."Code"
  LEFT JOIN "XP_Enumerationen"."XP_ZweckbestimmungGemeinbedarf" zl2 ON zt.z2 = zl2."Code"
  LEFT JOIN "XP_Enumerationen"."XP_ZweckbestimmungGemeinbedarf" zl3 ON zt.z3 = zl3."Code"
  LEFT JOIN "XP_Enumerationen"."XP_ZweckbestimmungGemeinbedarf" zl4 ON zt.z4 = zl4."Code";
GRANT SELECT ON TABLE "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_Gemeinbedarf_qv" TO xp_gast;

-- -----------------------------------------------------
-- View "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_GemeinbedarfFlaeche_qv"
-- -----------------------------------------------------
CREATE OR REPLACE VIEW "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_GemeinbedarfFlaeche_qv" AS
SELECT g.position, p.*
FROM "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_GemeinbedarfFlaeche" g
JOIN "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_Gemeinbedarf_qv" p ON g.gid = p.gid;
GRANT SELECT ON TABLE "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_GemeinbedarfFlaeche_qv" TO xp_gast;

-- -----------------------------------------------------
-- View "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_GemeinbedarfPunkt_qv"
-- -----------------------------------------------------
CREATE OR REPLACE VIEW "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_GemeinbedarfPunkt_qv" AS
SELECT g.position, p.*
FROM "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_GemeinbedarfPunkt" g
JOIN "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_Gemeinbedarf_qv" p ON g.gid = p.gid;
GRANT SELECT ON TABLE "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_GemeinbedarfPunkt_qv" TO xp_gast;

-- -----------------------------------------------------
-- View "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_SpielSportanlage_qv"
-- -----------------------------------------------------
CREATE OR REPLACE VIEW "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_SpielSportanlage_qv" AS
SELECT g.gid, z1 as zweckbestimmung1,z2 as zweckbestimmung2,z3 as zweckbestimmung3,z4 as zweckbestimmung4,
 coalesce(z1 / z1, 0) + coalesce(z2 / z2, 0) + coalesce(z3 / z3, 0) + coalesce(z4 / z4, 0) as anz_zweckbestimmung,
CASE WHEN 3000 IN(z1,z2,z3,z4) THEN 'SpielSportanlage'
ELSE
    ''
END as label1
  FROM
 "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_SpielSportanlage" g
 LEFT JOIN
 crosstab('SELECT "FP_SpielSportanlage_gid", "FP_SpielSportanlage_gid", zweckbestimmung FROM "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_SpielSportanlage_zweckbestimmung" ORDER BY 1,3') zt
 (zgid bigint, z1 integer,z2 integer,z3 integer,z4 integer)
 ON g.gid=zt.zgid;
GRANT SELECT ON TABLE "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_SpielSportanlage_qv" TO xp_gast;

-- -----------------------------------------------------
-- View "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_SpielSportanlageFlaeche_qv"
-- -----------------------------------------------------
CREATE OR REPLACE VIEW "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_SpielSportanlageFlaeche_qv" AS
SELECT g.position, p.*
  FROM "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_SpielSportanlageFlaeche" g
 JOIN "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_SpielSportanlage_qv" p ON g.gid = p.gid;
GRANT SELECT ON TABLE "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_SpielSportanlageFlaeche_qv" TO xp_gast;

-- -----------------------------------------------------
-- View "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_SpielSportanlagePunkt_qv"
-- -----------------------------------------------------
CREATE OR REPLACE VIEW "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_SpielSportanlagePunkt_qv" AS
SELECT g.position, p.*
  FROM "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_SpielSportanlagePunkt" g
 JOIN "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_SpielSportanlage_qv" p ON g.gid = p.gid;
GRANT SELECT ON TABLE "FP_Gemeinbedarf_Spiel_und_Sportanlagen"."FP_SpielSportanlagePunkt_qv" TO xp_gast;

-- -----------------------------------------------------
-- View "FP_Landwirtschaft_Wald_und_Gruen"."FP_Gruen_qv"
-- -----------------------------------------------------
CREATE OR REPLACE VIEW "FP_Landwirtschaft_Wald_und_Gruen"."FP_Gruen_qv" AS
SELECT g.gid,z1 as zweckbestimmung1,z2 as zweckbestimmung2,z3 as zweckbestimmung3,z4 as zweckbestimmung4,
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
FROM "FP_Landwirtschaft_Wald_und_Gruen"."FP_Gruen" g
    LEFT JOIN crosstab('SELECT "FP_Gruen_gid", "FP_Gruen_gid", zweckbestimmung FROM "FP_Landwirtschaft_Wald_und_Gruen"."FP_Gruen_zweckbestimmung" ORDER BY 1,3') zt
        (zgid bigint, z1 integer,z2 integer,z3 integer,z4 integer)
    ON g.gid=zt.zgid
    LEFT JOIN "XP_Enumerationen"."XP_ZweckbestimmungGruen" zl1 ON zt.z1 = zl1."Code"
    LEFT JOIN "XP_Enumerationen"."XP_ZweckbestimmungGruen" zl2 ON zt.z2 = zl2."Code"
    LEFT JOIN "XP_Enumerationen"."XP_ZweckbestimmungGruen" zl3 ON zt.z3 = zl3."Code"
    LEFT JOIN "XP_Enumerationen"."XP_ZweckbestimmungGruen" zl4 ON zt.z4 = zl4."Code";
GRANT SELECT ON TABLE "FP_Landwirtschaft_Wald_und_Gruen"."FP_Gruen_qv" TO xp_gast;

-- -----------------------------------------------------
-- View "FP_Landwirtschaft_Wald_und_Gruen"."FP_GruenFlaeche_qv"
-- -----------------------------------------------------
CREATE OR REPLACE VIEW "FP_Landwirtschaft_Wald_und_Gruen"."FP_GruenFlaeche_qv" AS
SELECT g.position, p.*
  FROM "FP_Landwirtschaft_Wald_und_Gruen"."FP_GruenFlaeche" g
 JOIN "FP_Landwirtschaft_Wald_und_Gruen"."FP_Gruen_qv" p ON g.gid = p.gid;
GRANT SELECT ON TABLE "FP_Landwirtschaft_Wald_und_Gruen"."FP_GruenFlaeche_qv" TO xp_gast;

-- -----------------------------------------------------
-- View "FP_Landwirtschaft_Wald_und_Gruen"."FP_GruenPunkt_qv"
-- -----------------------------------------------------
CREATE OR REPLACE VIEW "FP_Landwirtschaft_Wald_und_Gruen"."FP_GruenPunkt_qv" AS
SELECT g.position, p.*
  FROM "FP_Landwirtschaft_Wald_und_Gruen"."FP_GruenPunkt" g
 JOIN "FP_Landwirtschaft_Wald_und_Gruen"."FP_Gruen_qv" p ON g.gid = p.gid;
GRANT SELECT ON TABLE "FP_Landwirtschaft_Wald_und_Gruen"."FP_GruenPunkt_qv" TO xp_gast;

-- -----------------------------------------------------
-- View "FP_Landwirtschaft_Wald_und_Gruen"."FP_WaldFlaeche_qv"
-- -----------------------------------------------------
CREATE OR REPLACE VIEW "FP_Landwirtschaft_Wald_und_Gruen"."FP_WaldFlaeche_qv" AS
SELECT g.gid, g.position, z1 as zweckbestimmung1,z2 as zweckbestimmung2,z3 as zweckbestimmung3,z4 as zweckbestimmung4,
 coalesce(z1 / z1, 0) + coalesce(z2 / z2, 0) + coalesce(z3 / z3, 0) + coalesce(z4 / z4, 0) as anz_zweckbestimmung
  FROM
 "FP_Landwirtschaft_Wald_und_Gruen"."FP_WaldFlaeche" g
 LEFT JOIN
 crosstab('SELECT "FP_WaldFlaeche_gid", "FP_WaldFlaeche_gid", zweckbestimmung FROM "FP_Landwirtschaft_Wald_und_Gruen"."FP_WaldFlaeche_zweckbestimmung" ORDER BY 1,3') zt
 (zgid bigint, z1 integer,z2 integer,z3 integer,z4 integer)
 ON g.gid=zt.zgid;
GRANT SELECT ON TABLE "FP_Landwirtschaft_Wald_und_Gruen"."FP_WaldFlaeche_qv" TO xp_gast;

-- -----------------------------------------------------
-- View "FP_Sonstiges"."FP_Kennzeichnung_qv"
-- -----------------------------------------------------
CREATE OR REPLACE VIEW "FP_Sonstiges"."FP_Kennzeichnung_qv" AS
SELECT g.gid, z1 as zweckbestimmung1,z2 as zweckbestimmung2,z3 as zweckbestimmung3,z4 as zweckbestimmung4,
 coalesce(z1 / z1, 0) + coalesce(z2 / z2, 0) + coalesce(z3 / z3, 0) + coalesce(z4 / z4, 0) as anz_zweckbestimmung,
CASE WHEN z1 != 4000 THEN zl1."Bezeichner"
END as label1,
CASE WHEN z2 != 4000 THEN zl2."Bezeichner"
END as label2,
CASE WHEN z3 != 4000 THEN zl3."Bezeichner"
END as label3,
CASE WHEN z4 != 4000 THEN zl4."Bezeichner"
END as label4
  FROM
 "FP_Sonstiges"."FP_Kennzeichnung" g
 LEFT JOIN
 crosstab('SELECT "FP_Kennzeichnung_gid", "FP_Kennzeichnung_gid", zweckbestimmung FROM "FP_Sonstiges"."FP_Kennzeichnung_zweckbestimmung" ORDER BY 1,3') zt
 (zgid bigint, z1 integer,z2 integer,z3 integer,z4 integer)
  ON g.gid=zt.zgid
    LEFT JOIN "XP_Enumerationen"."XP_ZweckbestimmungKennzeichnung" zl1 ON zt.z1 = zl1."Code"
    LEFT JOIN "XP_Enumerationen"."XP_ZweckbestimmungKennzeichnung" zl2 ON zt.z2 = zl2."Code"
    LEFT JOIN "XP_Enumerationen"."XP_ZweckbestimmungKennzeichnung" zl3 ON zt.z3 = zl3."Code"
    LEFT JOIN "XP_Enumerationen"."XP_ZweckbestimmungKennzeichnung" zl4 ON zt.z4 = zl4."Code";
GRANT SELECT ON TABLE "FP_Sonstiges"."FP_Kennzeichnung_qv" TO xp_gast;

-- -----------------------------------------------------
-- View "FP_Sonstiges"."FP_KennzeichnungFlaeche_qv"
-- -----------------------------------------------------
CREATE OR REPLACE VIEW "FP_Sonstiges"."FP_KennzeichnungFlaeche_qv" AS
SELECT g.position, p.*
  FROM "FP_Sonstiges"."FP_KennzeichnungFlaeche" g
 JOIN "FP_Sonstiges"."FP_Kennzeichnung_qv" p ON g.gid = p.gid;
GRANT SELECT ON TABLE "FP_Sonstiges"."FP_KennzeichnungFlaeche_qv" TO xp_gast;

-- -----------------------------------------------------
-- View "FP_Sonstiges"."FP_KennzeichnungLinie_qv"
-- -----------------------------------------------------
CREATE OR REPLACE VIEW "FP_Sonstiges"."FP_KennzeichnungLinie_qv" AS
SELECT g.position, p.*
  FROM "FP_Sonstiges"."FP_KennzeichnungLinie" g
 JOIN "FP_Sonstiges"."FP_Kennzeichnung_qv" p ON g.gid = p.gid;
GRANT SELECT ON TABLE "FP_Sonstiges"."FP_KennzeichnungLinie_qv" TO xp_gast;

-- -----------------------------------------------------
-- View "FP_Sonstiges"."FP_KennzeichnungPunkt_qv"
-- -----------------------------------------------------
CREATE OR REPLACE VIEW "FP_Sonstiges"."FP_KennzeichnungPunkt_qv" AS
SELECT g.position, p.*
  FROM "FP_Sonstiges"."FP_KennzeichnungPunkt" g
 JOIN "FP_Sonstiges"."FP_Kennzeichnung_qv" p ON g.gid = p.gid;
GRANT SELECT ON TABLE "FP_Sonstiges"."FP_KennzeichnungPunkt_qv" TO xp_gast;

-- -----------------------------------------------------
-- View "FP_Sonstiges"."FP_PrivilegiertesVorhaben_qv"
-- -----------------------------------------------------
CREATE OR REPLACE VIEW "FP_Sonstiges"."FP_PrivilegiertesVorhaben_qv" AS
 SELECT g.gid, z1 as zweckbestimmung1,z2 as zweckbestimmung2,z3 as zweckbestimmung3,z4 as zweckbestimmung4,
 coalesce(z1 / z1, 0) + coalesce(z2 / z2, 0) + coalesce(z3 / z3, 0) + coalesce(z4 / z4, 0) as anz_zweckbestimmung,
CASE WHEN z1 <= 9999 THEN
    zl1."Bezeichner"
END as label1,
CASE WHEN z1 <= 9999 THEN
    zl2."Bezeichner"
END as label2,
CASE WHEN z1 <= 9999 THEN
    zl3."Bezeichner"
END as label3,
CASE WHEN z1 <= 9999 THEN
    zl4."Bezeichner"
END as label4
  FROM
 "FP_Sonstiges"."FP_PrivilegiertesVorhaben" g
 LEFT JOIN
 crosstab('SELECT "FP_PrivilegiertesVorhaben_gid", "FP_PrivilegiertesVorhaben_gid", zweckbestimmung FROM "FP_Sonstiges"."FP_PrivilegiertesVorhaben_zweckbestimmung" ORDER BY 1,3') zt
 (zgid bigint, z1 integer,z2 integer,z3 integer,z4 integer)
 ON g.gid=zt.zgid
  LEFT JOIN "FP_Sonstiges"."FP_ZweckbestimmungPrivilegiertesVorhaben" zl1 ON zt.z1 = zl1."Code"
  LEFT JOIN "FP_Sonstiges"."FP_ZweckbestimmungPrivilegiertesVorhaben" zl2 ON zt.z2 = zl2."Code"
  LEFT JOIN "FP_Sonstiges"."FP_ZweckbestimmungPrivilegiertesVorhaben" zl3 ON zt.z3 = zl3."Code"
  LEFT JOIN "FP_Sonstiges"."FP_ZweckbestimmungPrivilegiertesVorhaben" zl4 ON zt.z4 = zl4."Code";

GRANT SELECT ON TABLE "FP_Sonstiges"."FP_PrivilegiertesVorhaben_qv" TO xp_gast;

-- -----------------------------------------------------
-- View "FP_Sonstiges"."FP_PrivilegiertesVorhabenFlaeche_qv"
-- -----------------------------------------------------
CREATE OR REPLACE VIEW "FP_Sonstiges"."FP_PrivilegiertesVorhabenFlaeche_qv" AS
SELECT g.position, p.*
  FROM "FP_Sonstiges"."FP_PrivilegiertesVorhabenFlaeche" g
 JOIN "FP_Sonstiges"."FP_PrivilegiertesVorhaben_qv" p ON g.gid = p.gid;
GRANT SELECT ON TABLE "FP_Sonstiges"."FP_PrivilegiertesVorhabenFlaeche_qv" TO xp_gast;

-- -----------------------------------------------------
-- View "FP_Sonstiges"."FP_PrivilegiertesVorhabenLinie_qv"
-- -----------------------------------------------------
CREATE OR REPLACE VIEW "FP_Sonstiges"."FP_PrivilegiertesVorhabenLinie_qv" AS
SELECT g.position, p.*
  FROM "FP_Sonstiges"."FP_PrivilegiertesVorhabenLinie" g
 JOIN "FP_Sonstiges"."FP_PrivilegiertesVorhaben_qv" p ON g.gid = p.gid;
GRANT SELECT ON TABLE "FP_Sonstiges"."FP_PrivilegiertesVorhabenLinie_qv" TO xp_gast;

-- -----------------------------------------------------
-- View "FP_Sonstiges"."FP_PrivilegiertesVorhabenPunkt_qv"
-- -----------------------------------------------------
CREATE OR REPLACE VIEW "FP_Sonstiges"."FP_PrivilegiertesVorhabenPunkt_qv" AS
SELECT g.position, p.*
  FROM "FP_Sonstiges"."FP_PrivilegiertesVorhabenPunkt" g
 JOIN "FP_Sonstiges"."FP_PrivilegiertesVorhaben_qv" p ON g.gid = p.gid;
GRANT SELECT ON TABLE "FP_Sonstiges"."FP_PrivilegiertesVorhabenPunkt_qv" TO xp_gast;

-- -----------------------------------------------------
-- View "FP_Ver_und_Entsorgung"."FP_VerEntsorgung_qv"
-- -----------------------------------------------------
CREATE OR REPLACE VIEW "FP_Ver_und_Entsorgung"."FP_VerEntsorgung_qv" AS
 SELECT g.gid, xpo.ebene, z1 as zweckbestimmung1,z2 as zweckbestimmung2,z3 as zweckbestimmung3,z4 as zweckbestimmung4,
 coalesce(z1 / z1, 0) + coalesce(z2 / z2, 0) + coalesce(z3 / z3, 0) + coalesce(z4 / z4, 0) as anz_zweckbestimmung,
 CASE WHEN 2000 IN(z1,z2,z3,z4) THEN 'Regenwasser'
    WHEN 2600 IN (z1,z2,z3,z4) THEN 'Telekom.'
 ELSE
    zl1."Bezeichner"
 END as label1,
 zl2."Bezeichner" as label2,
 zl3."Bezeichner" as label3,
 zl4."Bezeichner" as label4
  FROM
 "FP_Ver_und_Entsorgung"."FP_VerEntsorgung" g
 JOIN "XP_Basisobjekte"."XP_Objekt" xpo ON g.gid = xpo.gid
 LEFT JOIN
 crosstab('SELECT "FP_VerEntsorgung_gid", "FP_VerEntsorgung_gid", zweckbestimmung FROM "FP_Ver_und_Entsorgung"."FP_VerEntsorgung_zweckbestimmung" ORDER BY 1,3') zt
 (zgid bigint, z1 integer,z2 integer,z3 integer,z4 integer)
 ON g.gid=zt.zgid
  LEFT JOIN "XP_Enumerationen"."XP_ZweckbestimmungVerEntsorgung" zl1 ON zt.z1 = zl1."Code"
  LEFT JOIN "XP_Enumerationen"."XP_ZweckbestimmungVerEntsorgung" zl2 ON zt.z2 = zl2."Code"
  LEFT JOIN "XP_Enumerationen"."XP_ZweckbestimmungVerEntsorgung" zl3 ON zt.z3 = zl3."Code"
  LEFT JOIN "XP_Enumerationen"."XP_ZweckbestimmungVerEntsorgung" zl4 ON zt.z4 = zl4."Code";
GRANT SELECT ON TABLE "FP_Ver_und_Entsorgung"."FP_VerEntsorgung_qv" TO xp_gast;

-- -----------------------------------------------------
-- View "FP_Ver_und_Entsorgung"."FP_VerEntsorgungFlaeche_qv"
-- -----------------------------------------------------
CREATE OR REPLACE VIEW "FP_Ver_und_Entsorgung"."FP_VerEntsorgungFlaeche_qv" AS
SELECT g.position, p.*
  FROM "FP_Ver_und_Entsorgung"."FP_VerEntsorgungFlaeche" g
 JOIN "FP_Ver_und_Entsorgung"."FP_VerEntsorgung_qv" p ON g.gid = p.gid;
GRANT SELECT ON TABLE "FP_Ver_und_Entsorgung"."FP_VerEntsorgungFlaeche_qv" TO xp_gast;

-- -----------------------------------------------------
-- View "FP_Ver_und_Entsorgung"."FP_VerEntsorgungLinie_qv"
-- -----------------------------------------------------
CREATE OR REPLACE VIEW "FP_Ver_und_Entsorgung"."FP_VerEntsorgungLinie_qv" AS
SELECT g.position, p.*
  FROM "FP_Ver_und_Entsorgung"."FP_VerEntsorgungLinie" g
 JOIN "FP_Ver_und_Entsorgung"."FP_VerEntsorgung_qv" p ON g.gid = p.gid;
GRANT SELECT ON TABLE "FP_Ver_und_Entsorgung"."FP_VerEntsorgungLinie_qv" TO xp_gast;

-- -----------------------------------------------------
-- View "FP_Ver_und_Entsorgung"."FP_VerEntsorgungPunkt_qv"
-- -----------------------------------------------------
CREATE OR REPLACE VIEW "FP_Ver_und_Entsorgung"."FP_VerEntsorgungPunkt_qv" AS
SELECT g.position, p.*
  FROM "FP_Ver_und_Entsorgung"."FP_VerEntsorgungPunkt" g
 JOIN "FP_Ver_und_Entsorgung"."FP_VerEntsorgung_qv" p ON g.gid = p.gid;
GRANT SELECT ON TABLE "FP_Ver_und_Entsorgung"."FP_VerEntsorgungPunkt_qv" TO xp_gast;

CREATE OR REPLACE VIEW "FP_Verkehr"."FP_Strassenverkehr_qv" AS
 SELECT g.gid, xpo.ebene, xpo.rechtsstand, z1 as zweckbestimmung1,z2 as zweckbestimmung2,z3 as zweckbestimmung3,z4 as zweckbestimmung4,
 coalesce(z1 / z1, 0) + coalesce(z2 / z2, 0) + coalesce(z3 / z3, 0) + coalesce(z4 / z4, 0) as anz_zweckbestimmung
  FROM
 "FP_Verkehr"."FP_Strassenverkehr" g
 LEFT JOIN
 crosstab('SELECT "FP_Strassenverkehr_gid", "FP_Strassenverkehr_gid", zweckbestimmung FROM "FP_Verkehr"."FP_Strassenverkehr_zweckbestimmung" ORDER BY 1,3') zt
 (zgid bigint, z1 integer,z2 integer,z3 integer,z4 integer)
 ON g.gid=zt.zgid
 JOIN "XP_Basisobjekte"."XP_Objekt" xpo ON g.gid = xpo.gid;
GRANT SELECT ON TABLE "FP_Verkehr"."FP_Strassenverkehr_qv" TO xp_gast;

-- -----------------------------------------------------
-- View "FP_Verkehr"."FP_StrassenverkehrFlaeche_qv"
-- -----------------------------------------------------
CREATE OR REPLACE VIEW "FP_Verkehr"."FP_StrassenverkehrFlaeche_qv" AS
 SELECT g.gid, g.position, p.ebene, p.rechtsstand, p.zweckbestimmung1, p.zweckbestimmung2, p.zweckbestimmung3, p.zweckbestimmung4, p.anz_zweckbestimmung
FROM "FP_Verkehr"."FP_StrassenverkehrFlaeche" g
    JOIN "FP_Verkehr"."FP_Strassenverkehr_qv" p ON g.gid = p.gid;
GRANT SELECT ON TABLE "FP_Verkehr"."FP_StrassenverkehrFlaeche_qv" TO xp_gast;

-- -----------------------------------------------------
-- View "FP_Verkehr"."FP_StrassenverkehrLinie_qv"
-- -----------------------------------------------------
CREATE OR REPLACE VIEW "FP_Verkehr"."FP_StrassenverkehrLinie_qv" AS
 SELECT g.gid, g.position, p.ebene, p.rechtsstand, p.zweckbestimmung1, p.zweckbestimmung2, p.zweckbestimmung3, p.zweckbestimmung4, p.anz_zweckbestimmung
FROM "FP_Verkehr"."FP_StrassenverkehrLinie" g
    JOIN "FP_Verkehr"."FP_Strassenverkehr_qv" p ON g.gid = p.gid;
GRANT SELECT ON TABLE "FP_Verkehr"."FP_StrassenverkehrLinie_qv" TO xp_gast;

-- -----------------------------------------------------
-- View "FP_Verkehr"."FP_StrassenverkehrPunkt_qv"
-- -----------------------------------------------------
CREATE OR REPLACE VIEW "FP_Verkehr"."FP_StrassenverkehrPunkt_qv" AS
 SELECT g.gid, g.position, p.ebene, p.rechtsstand, p.zweckbestimmung1, p.zweckbestimmung2, p.zweckbestimmung3, p.zweckbestimmung4, p.anz_zweckbestimmung
FROM "FP_Verkehr"."FP_StrassenverkehrPunkt" g
    JOIN "FP_Verkehr"."FP_Strassenverkehr_qv" p ON g.gid = p.gid;
GRANT SELECT ON TABLE "FP_Verkehr"."FP_StrassenverkehrPunkt_qv" TO xp_gast;

-- -----------------------------------------------------
-- View "FP_Wasser"."FP_GewaesserFlaeche_qv"
-- -----------------------------------------------------
CREATE OR REPLACE VIEW "FP_Wasser"."FP_GewaesserFlaeche_qv" AS
 SELECT g.gid, g.position, p.zweckbestimmung as zweckbestimmung1
FROM "FP_Wasser"."FP_GewaesserFlaeche" g
    JOIN "FP_Wasser"."FP_Gewaesser" p ON g.gid = p.gid;
GRANT SELECT ON TABLE "FP_Wasser"."FP_GewaesserFlaeche_qv" TO xp_gast;

-- -----------------------------------------------------
-- View "FP_Wasser"."FP_GewaesserLinie_qv"
-- -----------------------------------------------------
CREATE OR REPLACE VIEW "FP_Wasser"."FP_GewaesserLinie_qv" AS
 SELECT g.gid, g.position, p.zweckbestimmung as zweckbestimmung1
FROM "FP_Wasser"."FP_GewaesserLinie" g
    JOIN "FP_Wasser"."FP_Gewaesser" p ON g.gid = p.gid;
GRANT SELECT ON TABLE "FP_Wasser"."FP_GewaesserLinie_qv" TO xp_gast;

-- -----------------------------------------------------
-- View "FP_Wasser"."FP_GewaesserPunkt_qv"
-- -----------------------------------------------------
CREATE OR REPLACE VIEW "FP_Wasser"."FP_GewaesserPunkt_qv" AS
 SELECT g.gid, g.position, p.zweckbestimmung as zweckbestimmung1
FROM "FP_Wasser"."FP_GewaesserPunkt" g
    JOIN "FP_Wasser"."FP_Gewaesser" p ON g.gid = p.gid;
GRANT SELECT ON TABLE "FP_Wasser"."FP_GewaesserPunkt_qv" TO xp_gast;

-- -----------------------------------------------------
-- View "FP_Wasser"."FP_WasserwirtschaftFlaeche_qv"
-- -----------------------------------------------------
CREATE OR REPLACE VIEW "FP_Wasser"."FP_WasserwirtschaftFlaeche_qv" AS
 SELECT g.gid, g.position, p.zweckbestimmung as zweckbestimmung1
FROM "FP_Wasser"."FP_WasserwirtschaftFlaeche" g
    JOIN "FP_Wasser"."FP_Wasserwirtschaft" p ON g.gid = p.gid;
GRANT SELECT ON TABLE "FP_Wasser"."FP_WasserwirtschaftFlaeche_qv" TO xp_gast;

-- -----------------------------------------------------
-- View "FP_Wasser"."FP_WasserwirtschaftLinie_qv"
-- -----------------------------------------------------
CREATE OR REPLACE VIEW "FP_Wasser"."FP_WasserwirtschaftLinie_qv" AS
 SELECT g.gid, g.position, p.zweckbestimmung as zweckbestimmung1
FROM "FP_Wasser"."FP_WasserwirtschaftLinie" g
    JOIN "FP_Wasser"."FP_Wasserwirtschaft" p ON g.gid = p.gid;
GRANT SELECT ON TABLE "FP_Wasser"."FP_WasserwirtschaftLinie_qv" TO xp_gast;

-- -----------------------------------------------------
-- View "FP_Wasser"."FP_WasserwirtschaftPunkt_qv"
-- -----------------------------------------------------
CREATE OR REPLACE VIEW "FP_Wasser"."FP_WasserwirtschaftPunkt_qv" AS
 SELECT g.gid, g.position, p.zweckbestimmung as zweckbestimmung1
FROM "FP_Wasser"."FP_WasserwirtschaftPunkt" g
    JOIN "FP_Wasser"."FP_Wasserwirtschaft" p ON g.gid = p.gid;
GRANT SELECT ON TABLE "FP_Wasser"."FP_WasserwirtschaftPunkt_qv" TO xp_gast;
