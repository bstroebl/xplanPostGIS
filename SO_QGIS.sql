/* *************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 ************************************************************************* */

-- *****************************************************
-- CREATE Views für SO
-- *****************************************************

-- -----------------------------------------------------
-- View "SO_NachrichtlicheUebernahmen"."SO_StrassenverkehrsrechtFlaeche_qv"
-- -----------------------------------------------------
CREATE OR REPLACE VIEW "SO_NachrichtlicheUebernahmen"."SO_StrassenverkehrsrechtFlaeche_qv" AS 
 SELECT g.gid, g.position, xpo.ebene, p."artDerFestlegung"
FROM "SO_NachrichtlicheUebernahmen"."SO_StrassenverkehrsrechtFlaeche" g
    JOIN "SO_NachrichtlicheUebernahmen"."SO_Strassenverkehrsrecht" p ON g.gid = p.gid
    JOIN "XP_Basisobjekte"."XP_Objekt" xpo ON g.gid = xpo.gid;
GRANT SELECT ON TABLE "SO_NachrichtlicheUebernahmen"."SO_StrassenverkehrsrechtFlaeche_qv" TO xp_gast;

-- -----------------------------------------------------
-- View "SO_NachrichtlicheUebernahmen"."SO_StrassenverkehrsrechtLinie_qv"
-- -----------------------------------------------------
CREATE OR REPLACE VIEW "SO_NachrichtlicheUebernahmen"."SO_StrassenverkehrsrechtLinie_qv" AS 
 SELECT g.gid, g.position, xpo.ebene, p."artDerFestlegung"
FROM "SO_NachrichtlicheUebernahmen"."SO_StrassenverkehrsrechtLinie" g
    JOIN "SO_NachrichtlicheUebernahmen"."SO_Strassenverkehrsrecht" p ON g.gid = p.gid
    JOIN "XP_Basisobjekte"."XP_Objekt" xpo ON g.gid = xpo.gid;
GRANT SELECT ON TABLE "SO_NachrichtlicheUebernahmen"."SO_StrassenverkehrsrechtLinie_qv" TO xp_gast;

-- -----------------------------------------------------
-- View "SO_NachrichtlicheUebernahmen"."SO_DenkmalschutzrechtPunkt_qv"
-- -----------------------------------------------------
CREATE OR REPLACE VIEW "SO_NachrichtlicheUebernahmen"."SO_DenkmalschutzrechtPunkt_qv" AS 
 SELECT g.gid, g.position, p."artDerFestlegung"
FROM "SO_NachrichtlicheUebernahmen"."SO_DenkmalschutzrechtPunkt" g
    JOIN "SO_NachrichtlicheUebernahmen"."SO_Denkmalschutzrecht" p ON g.gid = p.gid;
GRANT SELECT ON TABLE "SO_NachrichtlicheUebernahmen"."SO_DenkmalschutzrechtPunkt_qv" TO xp_gast;

-- -----------------------------------------------------
-- View "SO_NachrichtlicheUebernahmen"."SO_ForstrechtPunkt_qv"
-- -----------------------------------------------------
CREATE OR REPLACE VIEW "SO_NachrichtlicheUebernahmen"."SO_ForstrechtPunkt_qv" AS 
 SELECT g.gid, g.position, p."artDerFestlegung"
FROM "SO_NachrichtlicheUebernahmen"."SO_ForstrechtPunkt" g
    JOIN "SO_NachrichtlicheUebernahmen"."SO_Forstrecht" p ON g.gid = p.gid;
GRANT SELECT ON TABLE "SO_NachrichtlicheUebernahmen"."SO_ForstrechtPunkt_qv" TO xp_gast;

-- -----------------------------------------------------
-- View "SO_NachrichtlicheUebernahmen"."SO_SonstigesRechtPunkt_qv"
-- -----------------------------------------------------
CREATE OR REPLACE VIEW "SO_NachrichtlicheUebernahmen"."SO_SonstigesRechtPunkt_qv" AS 
 SELECT g.gid, g.position, p."artDerFestlegung"
FROM "SO_NachrichtlicheUebernahmen"."SO_SonstigesRechtPunkt" g
    JOIN "SO_NachrichtlicheUebernahmen"."SO_SonstigesRecht" p ON g.gid = p.gid;
GRANT SELECT ON TABLE "SO_NachrichtlicheUebernahmen"."SO_SonstigesRechtPunkt_qv" TO xp_gast;

-- -----------------------------------------------------
-- View "SO_Schutzgebiete"."SO_SchutzgebietNaturschutzrechtPunkt_qv"
-- -----------------------------------------------------
CREATE OR REPLACE VIEW "SO_Schutzgebiete"."SO_SchutzgebietNaturschutzrechtPunkt_qv" AS 
 SELECT g.gid, g.position, p."artDerFestlegung"
FROM "SO_Schutzgebiete"."SO_SchutzgebietNaturschutzrechtPunkt" g
    JOIN "SO_Schutzgebiete"."SO_SchutzgebietNaturschutzrecht" p ON g.gid = p.gid;
GRANT SELECT ON TABLE "SO_Schutzgebiete"."SO_SchutzgebietNaturschutzrechtPunkt_qv" TO xp_gast;




