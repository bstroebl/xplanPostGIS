-- Dieses Script stellt QGIS-Views wieder her, und sollte nach 4zu5.sql ausgeführt werden
--
-- -----------------------------------------------------
-- View "BP_Bebauung"."BP_BaugebietsTeilFlaeche_qv"
-- -----------------------------------------------------

CREATE OR REPLACE VIEW "BP_Bebauung"."BP_BaugebietsTeilFlaeche_qv" AS
SELECT g.position, p.*
FROM "BP_Bebauung"."BP_BaugebietsTeilFlaeche" g
JOIN "BP_Bebauung"."BP_BaugebietObjekt" p ON g.gid = p.gid;
GRANT SELECT ON TABLE "BP_Bebauung"."BP_BaugebietsTeilFlaeche_qv" TO xp_gast;
