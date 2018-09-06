-- Umstellung von XPlan 5.1 auf ?
-- Änderngen in der DB

-- Umsellen des UUID-Generators von Python auf eine in einer Extension entahltenen Funktion
CREATE EXTENSION pgcrypto;

CREATE OR REPLACE FUNCTION "XP_Basisobjekte".create_uuid()
  RETURNS character varying AS
$BODY$
BEGIN
    return gen_random_uuid(); -- version 4 uuid
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
GRANT EXECUTE ON FUNCTION "XP_Basisobjekte".create_uuid() TO xp_user;

DROP LANGUAGE plpython2u;

-- vergrössere Felder, damit auch lange Tabellenamen reinpassen
ALTER TABLE "QGIS"."layer" ALTER COLUMN schemaname character varying (256);
ALTER TABLE "QGIS"."layer" ALTER COLUMN tablename character varying (256);
