-- Umstellung von XPlan 5.2.1 auf 5.3
-- Änderungen in der DB

-- CR-001
INSERT INTO "RP_Freiraumstruktur"."RP_NaturLandschaftTypen" ("Code", "Bezeichner") VALUES ('2600', 'Freiraumfunktionen');

-- CR-003
INSERT INTO "XP_Basisobjekte"."XP_ExterneReferenzTyp" ("Code", "Bezeichner") VALUES (4000, 'Genehmigung');
INSERT INTO "XP_Basisobjekte"."XP_ExterneReferenzTyp" ("Code", "Bezeichner") VALUES (5000, 'Bekanntmachung');
