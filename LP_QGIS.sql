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
-- View "LP_Basisobjekte"."LP_Bereich_qv" berücksichtigt NULL geltungsbereich
-- -----------------------------------------------------
CREATE OR REPLACE VIEW "LP_Basisobjekte"."LP_Bereich_qv" AS
SELECT b.gid ,
    COALESCE(b.geltungsbereich ,p."raeumlicherGeltungsbereich")::geometry(MultiPolygon,25832) as geltungsbereich,
    b."name",
    b."gehoertZuPlan" 
FROM "LP_Basisobjekte"."LP_Bereich" b
	JOIN "LP_Basisobjekte"."LP_Plan" p ON b."gehoertZuPlan" = p.gid;
GRANT SELECT ON "LP_Basisobjekte"."LP_Bereich_qv" TO xp_gast;  