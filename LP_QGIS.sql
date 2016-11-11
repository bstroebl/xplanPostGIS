/* *************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 ************************************************************************* */

-- *****************************************************
-- CREATE Views für LP
-- *****************************************************

-- -----------------------------------------------------
-- View "LP_SchutzgebieteObjekte"."LP_SchutzobjektBundesrechtFlaeche_qv"
-- -----------------------------------------------------
CREATE OR REPLACE VIEW "LP_SchutzgebieteObjekte"."LP_SchutzobjektBundesrechtFlaeche_qv" AS 
 SELECT g.gid, g.position, p.typ, p.eigenname, lpo.status
FROM "LP_SchutzgebieteObjekte"."LP_SchutzobjektBundesrechtFlaeche" g
    JOIN "LP_SchutzgebieteObjekte"."LP_SchutzobjektBundesrecht" p ON g.gid = p.gid
    JOIN "LP_Basisobjekte"."LP_Objekt" lpo ON g.gid = lpo.gid;
GRANT SELECT ON TABLE "LP_SchutzgebieteObjekte"."LP_SchutzobjektBundesrechtFlaeche_qv" TO xp_gast;

-- -----------------------------------------------------
-- View "LP_SchutzgebieteObjekte"."LP_SchutzobjektBundesrechtLinie_qv"
-- -----------------------------------------------------
CREATE OR REPLACE VIEW "LP_SchutzgebieteObjekte"."LP_SchutzobjektBundesrechtLinie_qv" AS 
 SELECT g.gid, g.position, p.typ, p.eigenname, lpo.status
FROM "LP_SchutzgebieteObjekte"."LP_SchutzobjektBundesrechtLinie" g
    JOIN "LP_SchutzgebieteObjekte"."LP_SchutzobjektBundesrecht" p ON g.gid = p.gid
    JOIN "LP_Basisobjekte"."LP_Objekt" lpo ON g.gid = lpo.gid;
GRANT SELECT ON TABLE "LP_SchutzgebieteObjekte"."LP_SchutzobjektBundesrechtLinie_qv" TO xp_gast;

-- -----------------------------------------------------
-- View "LP_SchutzgebieteObjekte"."LP_SchutzobjektBundesrechtPunkt_qv"
-- -----------------------------------------------------
CREATE OR REPLACE VIEW "LP_SchutzgebieteObjekte"."LP_SchutzobjektBundesrechtPunkt_qv" AS 
 SELECT g.gid, g.position, p.typ, p.eigenname, lpo.status
FROM "LP_SchutzgebieteObjekte"."LP_SchutzobjektBundesrechtPunkt" g
    JOIN "LP_SchutzgebieteObjekte"."LP_SchutzobjektBundesrecht" p ON g.gid = p.gid
    JOIN "LP_Basisobjekte"."LP_Objekt" lpo ON g.gid = lpo.gid;
GRANT SELECT ON TABLE "LP_SchutzgebieteObjekte"."LP_SchutzobjektBundesrechtPunkt_qv" TO xp_gast;
