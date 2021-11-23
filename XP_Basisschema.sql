-- -----------------------------------------------------
-- XP__Basisschema
-- Das XPLanGML Basisschema enthält abstrakte Oberklassen, von denen alle Klassen der Fachschemata abgeleitet sind,
-- sowie allgemeine Feature-Types, DataTypes und Enumerationen, die in verschiedenen Fach-Schemata verwendet werden.
-- Version für PostGIS 2.*
-- -----------------------------------------------------

/* *************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 ************************************************************************* */

-- *****************************************************
-- pgcrypto enthält einen uuid-Generator
-- *****************************************************
CREATE EXTENSION pgcrypto;

-- *****************************************************
-- CREATE SCHEMAS
-- *****************************************************

CREATE SCHEMA "XP_Basisobjekte";
CREATE SCHEMA "XP_Sonstiges";
CREATE SCHEMA "XP_Praesentationsobjekte";
CREATE SCHEMA "XP_Enumerationen";
CREATE SCHEMA "XP_Raster";

COMMENT ON SCHEMA "XP_Basisobjekte" IS 'Dieses Paket enthält die Basisklassen des XPlanGML Schemas.';
COMMENT ON SCHEMA "XP_Sonstiges" IS 'Allegemeine Datentypen.';
COMMENT ON SCHEMA "XP_Praesentationsobjekte" IS 'Das Paket Praesentationsobjekte modelliert Klassen, die lediglich der graphischen Ausgestaltung eines Plans dienen und selbst keine eigentlichen Plan-Inhalte repräsentieren. Die entsprechenden Fachobjekte können unmittelbar instanziiert werden.';
COMMENT ON SCHEMA "XP_Enumerationen" IS 'Dieses Paket enthält verschiedene Enumerationen, die Fachschema-übergreifend verwwendet werden';
COMMENT ON SCHEMA "XP_Raster" IS 'Dieses Paket enthält Basisklassen für die Rasterdarstellung von Bebauungsplänen, Flächennutzungsplänen, Landschafts- und Regionalplänen.';

GRANT USAGE ON SCHEMA "XP_Basisobjekte" TO xp_gast;
GRANT USAGE ON SCHEMA "XP_Sonstiges" TO xp_gast;
GRANT USAGE ON SCHEMA "XP_Praesentationsobjekte" TO xp_gast;
GRANT USAGE ON SCHEMA "XP_Enumerationen" TO xp_gast;
GRANT USAGE ON SCHEMA "XP_Raster" TO xp_gast;

-- *****************************************************
-- CREATE FUNCTIONs
-- *****************************************************

CREATE OR REPLACE FUNCTION "XP_Basisobjekte".ensure_sequence(name_of_schema character varying, name_of_table character varying, pk_column character varying)
  RETURNS character varying AS
$BODY$
 DECLARE
    str_trigger varchar;
 BEGIN
        str_trigger := 'CREATE FUNCTION ' || quote_ident(name_of_schema) || '.' || quote_ident(name_of_table || '_ensure_sequence') ||
            '() RETURNS TRIGGER AS $ensure_sequence$' || E'\n';
        str_trigger := str_trigger || 'DECLARE' || E'\n';
        str_trigger := str_trigger || '    str_execute text;' || E'\n';
        str_trigger := str_trigger || 'BEGIN' || E'\n';
        str_trigger := str_trigger || '    IF (TG_OP = ' || quote_literal('INSERT') || ') THEN' || E'\n';
        str_trigger := str_trigger || '        NEW.' || pk_column || ' := nextval(' ||
        quote_literal(quote_ident(name_of_schema) || '.' || quote_ident(name_of_table || '_' ||
        pk_column || '_seq')) || ');' || E'\n';
        str_trigger := str_trigger || '    ELSIF (TG_OP = ' || quote_literal('UPDATE') || ') THEN' || E'\n';
        str_trigger := str_trigger || '        NEW.' || pk_column || ' := ' || 'OLD.' || pk_column || ';' || E'\n';
        str_trigger := str_trigger || '    END IF;' || E'\n';
        str_trigger := str_trigger || '    RETURN NEW;' || E'\n';
        str_trigger := str_trigger || 'END; $ensure_sequence$ LANGUAGE plpgsql;' || E'\n';

        EXECUTE str_trigger;

        EXECUTE 'GRANT EXECUTE ON FUNCTION ' || quote_ident(name_of_schema) || '.' ||
        quote_ident(name_of_table || '_ensure_sequence') || '() TO xp_user;';
        EXECUTE 'ALTER FUNCTION ' || quote_ident(name_of_schema) || '.' || quote_ident(name_of_table || '_ensure_sequence') ||
        '() OWNER TO xp_user;';
        EXECUTE 'CREATE TRIGGER ' || quote_ident(name_of_table || '_ensure_sequence') || ' BEFORE INSERT OR UPDATE ON ' ||
        quote_ident(name_of_schema) || '.' || quote_ident(name_of_table) ||
        ' FOR EACH ROW EXECUTE PROCEDURE ' || quote_ident(name_of_schema) || '.' ||
            quote_ident(name_of_table || '_ensure_sequence') || '();';
        RETURN 'OK'; --*/
 END; $BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
COMMENT ON FUNCTION "XP_Basisobjekte".ensure_sequence(character varying, character varying, character varying) IS
'Erzeugt Trigger, die für das PK-Feld den nächsten Wert aus der Sequenz vergeben und sicherstellen, dass der PK-Wert
vom Nutzer nicht geändert werden kann.';

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

CREATE OR REPLACE FUNCTION "XP_Basisobjekte"."gehoertZuPlan"(nspname character varying, relname character varying, gid bigint)
  RETURNS integer AS
$BODY$
DECLARE
    retvalue integer;
BEGIN
    EXECUTE 'SELECT b."gehoertZuPlan" FROM ' ||
        quote_ident(nspname) || '.' || quote_ident(relname) || ' b ' ||
        ' WHERE b.gid = ' || CAST(gid as varchar) || ';' INTO retvalue;
    RETURN retvalue;
END;
$BODY$
LANGUAGE plpgsql VOLATILE STRICT
COST 100;
GRANT EXECUTE ON FUNCTION "XP_Basisobjekte"."gehoertZuPlan"(character varying, character varying, bigint) TO xp_user;
COMMENT ON FUNCTION "XP_Basisobjekte"."gehoertZuPlan"(character varying, character varying, bigint) IS 'Gibt die gid des XP_Plans, zu dem ein XP_Bereich gehoert zurück';

CREATE OR REPLACE FUNCTION "XP_Basisobjekte"."XP_PO_artvalue"(nspname character varying, relname character varying, art character varying, gid bigint)
  RETURNS character varying AS
$BODY$
DECLARE
    retvalue character varying;
BEGIN
    EXECUTE 'SELECT CAST(' || quote_ident(art) || ' as varchar) FROM ' ||
        quote_ident(nspname) || '.' || quote_ident(relname) ||
        ' WHERE gid = ' || CAST(gid as varchar) || ';' INTO retvalue;
    RETURN retvalue;
END;
$BODY$
LANGUAGE plpgsql VOLATILE STRICT
COST 100;
GRANT EXECUTE ON FUNCTION "XP_Basisobjekte"."XP_PO_artvalue"(character varying, character varying, character varying, bigint) TO xp_user;
COMMENT ON FUNCTION "XP_Basisobjekte"."XP_PO_artvalue"(character varying, character varying, character varying, bigint) IS 'gibt den Wert für das Feld art für gid in der relation nspname.relname aus';

-- *****************************************************
-- CREATE SEQUENCES
-- *****************************************************

CREATE SEQUENCE "XP_Basisobjekte"."XP_Plan_gid_seq"
   MINVALUE 1;
GRANT ALL ON TABLE "XP_Basisobjekte"."XP_Plan_gid_seq" TO GROUP xp_user;

CREATE SEQUENCE "XP_Basisobjekte"."XP_Bereich_gid_seq"
   MINVALUE 1;
GRANT ALL ON TABLE "XP_Basisobjekte"."XP_Bereich_gid_seq" TO GROUP xp_user;

CREATE SEQUENCE "XP_Basisobjekte"."XP_Objekt_gid_seq"
   MINVALUE 1;
GRANT ALL ON TABLE "XP_Basisobjekte"."XP_Objekt_gid_seq" TO GROUP xp_user;

CREATE SEQUENCE "XP_Praesentationsobjekte"."XP_APObjekt_gid_seq"
   MINVALUE 1;
GRANT ALL ON TABLE "XP_Praesentationsobjekte"."XP_APObjekt_gid_seq" TO GROUP xp_user;

CREATE SEQUENCE "XP_Praesentationsobjekte"."dientZurDarstellungVon_id_seq"
   MINVALUE 1;
GRANT ALL ON TABLE "XP_Praesentationsobjekte"."dientZurDarstellungVon_id_seq" TO GROUP xp_user;

CREATE SEQUENCE "XP_Raster"."XP_Rasterdarstellung_id_seq"
   MINVALUE 1;
GRANT ALL ON TABLE "XP_Raster"."XP_Rasterdarstellung_id_seq" TO GROUP xp_user;

CREATE SEQUENCE "XP_Basisobjekte"."XP_ExterneReferenz_id_seq"
   MINVALUE 1;
GRANT ALL ON TABLE "XP_Basisobjekte"."XP_ExterneReferenz_id_seq" TO GROUP xp_user;

CREATE SEQUENCE "XP_Basisobjekte"."XP_TextAbschnitt_id_seq"
    MINVALUE 1;
GRANT ALL ON TABLE "XP_Basisobjekte"."XP_TextAbschnitt_id_seq" TO GROUP xp_user;

CREATE SEQUENCE "XP_Basisobjekte"."XP_BegruendungAbschnitt_id_seq"
    MINVALUE 1;
GRANT ALL ON TABLE "XP_Basisobjekte"."XP_BegruendungAbschnitt_id_seq" TO GROUP xp_user;

CREATE SEQUENCE "XP_Basisobjekte"."XP_VerfahrensMerkmal_id_seq"
    MINVALUE 1;
GRANT ALL ON TABLE "XP_Basisobjekte"."XP_VerfahrensMerkmal_id_seq" TO GROUP xp_user;

CREATE SEQUENCE "XP_Sonstiges"."XP_Gemeinde_id_seq"
    MINVALUE 1;
GRANT ALL ON TABLE "XP_Sonstiges"."XP_Gemeinde_id_seq" TO GROUP xp_user;

CREATE SEQUENCE "XP_Sonstiges"."XP_Plangeber_id_seq"
    MINVALUE 1;
GRANT ALL ON TABLE "XP_Sonstiges"."XP_Plangeber_id_seq" TO GROUP xp_user;

CREATE SEQUENCE "XP_Sonstiges"."XP_Hoehenangabe_id_seq"
    MINVALUE 1;
GRANT ALL ON TABLE "XP_Sonstiges"."XP_Hoehenangabe_id_seq" TO GROUP xp_user;

CREATE SEQUENCE "XP_Basisobjekte"."XP_SPEMassnahmenDaten_id_seq"
    MINVALUE 1;
GRANT ALL ON TABLE "XP_Basisobjekte"."XP_SPEMassnahmenDaten_id_seq" TO GROUP xp_user;

CREATE SEQUENCE "XP_Basisobjekte"."XP_WirksamkeitBedingung_id_seq"
   MINVALUE 1;
GRANT ALL ON TABLE "XP_Basisobjekte"."XP_WirksamkeitBedingung_id_seq" TO GROUP xp_user;

CREATE SEQUENCE "XP_Basisobjekte"."XP_Code_seq"
   MINVALUE 1000000; -- eigene Codelistenwerte des Benutzers < 1000000
GRANT ALL ON TABLE "XP_Basisobjekte"."XP_Code_seq" TO GROUP xp_user;

-- *****************************************************
-- CREATE TRIGGER FUNCTIONs
-- *****************************************************

CREATE OR REPLACE FUNCTION "XP_Basisobjekte"."isAbstract"()
RETURNS trigger AS
$BODY$
 BEGIN
    IF (TG_OP = 'INSERT') THEN
        RAISE EXCEPTION 'Einfügen in abstrakte Klasse ist nicht zulässig';
        RETURN NULL;
    END IF;
 END; $BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
GRANT EXECUTE ON FUNCTION "XP_Basisobjekte"."isAbstract"() TO xp_user;

CREATE OR REPLACE FUNCTION "XP_Basisobjekte"."child_of_XP_ExterneReferenz"()
RETURNS trigger AS
$BODY$
DECLARE
    num_parents integer;
 BEGIN
    If (TG_OP = 'INSERT') THEN
        IF new.id IS NULL THEN
            num_parents := 0;
            new.id := nextval('"XP_Basisobjekte"."XP_ExterneReferenz_id_seq"');
        ELSE
            EXECUTE 'SELECT count(id) FROM "XP_Basisobjekte"."XP_ExterneReferenz"' ||
                ' WHERE id = ' || CAST(new.id as varchar) || ';' INTO num_parents;
            IF pg_trigger_depth() = 1 THEN -- Trigger wird für unterste Kindtabelle aufgerufen
                RAISE WARNING 'Die id sollte beim Einfügen in Tabelle % automatisch vergeben werden', TG_TABLE_NAME;
            END IF;
        END IF;

        IF num_parents = 0 THEN
            -- Elternobjekt anlegen
            INSERT INTO "XP_Basisobjekte"."XP_ExterneReferenz"(id, "referenzName") VALUES(new.id, 'Externe Referenz ' || CAST(new.id as varchar));
        END IF;

        RETURN new;
    ELSIf (TG_OP = 'UPDATE') THEN
        new.id := old.id;
        RETURN new;
    ELSIF (TG_OP = 'DELETE') THEN
        DELETE FROM "XP_Basisobjekte"."XP_ExterneReferenz" WHERE id = old.id;
        RETURN old;
    END IF;
 END; $BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
GRANT EXECUTE ON FUNCTION "XP_Basisobjekte"."child_of_XP_ExterneReferenz"() TO xp_user;

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

CREATE OR REPLACE FUNCTION "XP_Basisobjekte"."child_of_XP_Plan"()
RETURNS trigger AS
$BODY$
DECLARE
    num_parents integer;
 BEGIN
    IF (TG_OP = 'INSERT') THEN
        IF new.gid IS NULL THEN
            new.gid := nextval('"XP_Basisobjekte"."XP_Plan_gid_seq"');
            num_parents := 0;
        ELSE
            EXECUTE 'SELECT count(gid) FROM "XP_Basisobjekte"."XP_Plan"' ||
                ' WHERE gid = ' || CAST(new.gid as varchar) || ';' INTO num_parents;
            IF num_parents > 0 THEN
                RAISE WARNING 'Einen XP_Plan mit dieser gid gibt es bereits, erzeuge neue gid';
                new.gid := nextval('"XP_Basisobjekte"."XP_Plan_gid_seq"');
                num_parents := 0;
            ELSE
                RAISE WARNING 'Die gid sollte beim Einfügen in Tabelle % automatisch vergeben werden', TG_TABLE_NAME;
            END IF;
        END IF;

        IF new.name IS NULL THEN
             new.name := 'XP_Plan ' || CAST(new.gid as varchar);
        END IF;

        IF num_parents = 0 THEN
            INSERT INTO "XP_Basisobjekte"."XP_Plan"(gid, name) VALUES(new.gid, new.name);
        END IF;

        IF new."raeumlicherGeltungsbereich" IS NOT NULL THEN
            new."raeumlicherGeltungsbereich" := ST_ForceRHR(new."raeumlicherGeltungsbereich");
        END IF;

        RETURN new;
    ELSIF (TG_OP = 'UPDATE') THEN
        new.gid := old.gid; --no change in gid allowed

        IF new."raeumlicherGeltungsbereich" IS NOT NULL THEN
            new."raeumlicherGeltungsbereich" := ST_ForceRHR(new."raeumlicherGeltungsbereich");
        END IF;

        RETURN new;
    ELSIF (TG_OP = 'DELETE') THEN
        DELETE FROM "XP_Basisobjekte"."XP_Plan" WHERE gid = old.gid;
        RETURN old;
    END IF;
 END; $BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
GRANT EXECUTE ON FUNCTION "XP_Basisobjekte"."child_of_XP_Plan"() TO xp_user;

CREATE OR REPLACE FUNCTION "XP_Basisobjekte"."propagate_name_to_parent"()
RETURNS trigger AS
$BODY$
 BEGIN
    IF pg_trigger_depth() = 1 THEN -- UPDATE-Statement wird nicht über einen anderen Trigger aufgerufen
        IF new.name != old.name THEN
            IF TG_TABLE_NAME LIKE '%Plan' THEN
                UPDATE "XP_Basisobjekte"."XP_Plan" SET name = new.name WHERE gid = old.gid;
            ELSIF TG_TABLE_NAME LIKE '%Bereich' THEN
                UPDATE "XP_Basisobjekte"."XP_Bereich" SET name = new.name WHERE gid = old.gid;
            END IF;
        END IF;
    END IF;
    RETURN new;
 END; $BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
GRANT EXECUTE ON FUNCTION "XP_Basisobjekte"."propagate_name_to_parent"() TO xp_user;

CREATE OR REPLACE FUNCTION "XP_Basisobjekte"."propagate_name_to_child"()
RETURNS trigger AS
$BODY$
DECLARE
    rec record;
 BEGIN
    IF pg_trigger_depth() = 1 THEN -- UPDATE-Statement wird nicht über einen anderen Trigger aufgerufen
        IF new.name != old.name THEN
            IF TG_TABLE_NAME = 'XP_Plan' THEN
                FOR rec IN
                    SELECT nspname, relname
                    FROM pg_class c
                        JOIN pg_namespace n ON c.relnamespace = n.oid
                    WHERE relname IN ('FP_Plan', 'BP_Plan', 'LP_Plan', 'RP_Plan', 'SO_Plan')
                LOOP
                    EXECUTE 'UPDATE ' || quote_ident(rec.nspname) || '.' || quote_ident(rec.relname) ||
                    'SET name = ' || quote_literal(new.name) || ' WHERE gid = ' || CAST(old.gid as varchar) || ';';
                END LOOP;
            ELSIF TG_TABLE_NAME = 'XP_Bereich' THEN
                FOR rec IN
                    SELECT nspname, relname
                    FROM pg_class c
                        JOIN pg_namespace n ON c.relnamespace = n.oid
                    WHERE relname IN ('FP_Bereich', 'BP_Bereich', 'LP_Bereich', 'RP_Bereich', 'SO_Bereich')
                LOOP
                    EXECUTE 'UPDATE ' || quote_ident(rec.nspname) || '.' || quote_ident(rec.relname) ||
                    'SET name = ' || quote_literal(new.name) || ' WHERE gid = ' || CAST(old.gid as varchar) || ';';
                END LOOP;
            END IF;
        END IF;
    END IF;
    RETURN new;
 END; $BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
GRANT EXECUTE ON FUNCTION "XP_Basisobjekte"."propagate_name_to_child"() TO xp_user;

CREATE OR REPLACE FUNCTION "XP_Basisobjekte"."child_of_XP_Bereich"()
RETURNS trigger AS
$BODY$
DECLARE
    num_parents integer;
 BEGIN
    IF (TG_OP = 'INSERT') THEN
        IF new.gid IS NULL THEN
            new.gid := nextval('"XP_Basisobjekte"."XP_Bereich_gid_seq"');
            num_parents := 0;
        ELSE
            EXECUTE 'SELECT count(gid) FROM "XP_Basisobjekte"."XP_Bereich"' ||
                ' WHERE gid = ' || CAST(new.gid as varchar) || ';' INTO num_parents;
            IF num_parents > 0 THEN
                RAISE WARNING 'Einen XP_Bereich mit dieser gid gibt es bereits, erzeuge neue gid';
                new.gid := nextval('"XP_Basisobjekte"."XP_Bereich_gid_seq"');
                num_parents := 0;
            ELSE
                RAISE WARNING 'Die gid sollte beim Einfügen in Tabelle % automatisch vergeben werden', TG_TABLE_NAME;
            END IF;
        END IF;

        IF new.name IS NULL THEN
            new.name := 'XP_Bereich ' || CAST(new.gid as varchar);
        END IF;

        IF num_parents = 0 THEN
            INSERT INTO "XP_Basisobjekte"."XP_Bereich"(gid, name) VALUES(new.gid, new.name);
        END IF;

        IF new."geltungsbereich" IS NOT NULL THEN
            new."geltungsbereich" := ST_ForceRHR(new."geltungsbereich");
        END IF;

        RETURN new;
    ELSIF (TG_OP = 'UPDATE') THEN
        new.gid := old.gid; --no change in id allowed

        IF new."geltungsbereich" IS NOT NULL THEN
            new."geltungsbereich" := ST_ForceRHR(new."geltungsbereich");
        END IF;

        IF new.name IS NULL THEN
            new.name := old.name;
        END IF;

        RETURN new;
    ELSIF (TG_OP = 'DELETE') THEN
        DELETE FROM "XP_Basisobjekte"."XP_Bereich" WHERE gid = old.gid;
        RETURN old;
    END IF;
 END; $BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
GRANT EXECUTE ON FUNCTION "XP_Basisobjekte"."child_of_XP_Bereich"() TO xp_user;


CREATE OR REPLACE FUNCTION "XP_Basisobjekte"."XP_Bereich_before_update"()
RETURNS trigger AS
$BODY$
 BEGIN
    IF new.name IS NULL THEN
        new.name := old.name;
    END IF;

    return new;
 END; $BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
GRANT EXECUTE ON FUNCTION "XP_Basisobjekte"."XP_Bereich_before_update"() TO xp_user;

CREATE OR REPLACE FUNCTION "XP_Basisobjekte"."change_to_XP_Objekt"()
RETURNS trigger AS
$BODY$
 BEGIN
    IF (TG_OP = 'INSERT') THEN
        IF new.gid IS NULL THEN
            new.gid := nextval('"XP_Basisobjekte"."XP_Objekt_gid_seq"');
        END IF;

        IF new.uuid IS NULL THEN
            new.uuid := "XP_Basisobjekte"."create_uuid"();
        END IF;

        RETURN new;
    ELSIF (TG_OP = 'UPDATE') THEN
        new.gid := old.gid; --no change in gid allowed
        IF new.uuid IS NULL THEN
            new.uuid := old.uuid;
        END IF;
        RETURN new;
    END IF;
 END; $BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
GRANT EXECUTE ON FUNCTION "XP_Basisobjekte"."change_to_XP_Objekt"() TO xp_user;

CREATE OR REPLACE FUNCTION "XP_Basisobjekte"."create_gml_id"()
RETURNS trigger AS
$BODY$
 BEGIN
    IF new.gml_id IS NULL THEN
        new.gml_id := "XP_Basisobjekte"."create_uuid"();
    END IF;

    RETURN new;
 END; $BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
GRANT EXECUTE ON FUNCTION "XP_Basisobjekte"."create_gml_id"() TO xp_user;

-- FUNCTION: "XP_Basisobjekte"."child_of_XP_Objekt"()

-- DROP FUNCTION "XP_Basisobjekte"."child_of_XP_Objekt"();

CREATE OR REPLACE FUNCTION "XP_Basisobjekte"."child_of_XP_Objekt"()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$

 DECLARE
    parent_nspname varchar;
    parent_relname varchar;
    rec record;
    num_parents integer;
 BEGIN
    parent_nspname := NULL;
    -- die Elterntabelle rauskriegen und in Variablen speichern
    For rec IN
        SELECT
           ns.nspname, c.relname
        FROM pg_attribute att
            JOIN (SELECT * FROM pg_constraint WHERE contype = 'f') fcon ON att.attrelid = fcon.conrelid AND att.attnum = ANY (fcon.conkey)
            JOIN (SELECT * FROM pg_constraint WHERE contype = 'p') pcon ON att.attrelid = pcon.conrelid AND att.attnum = ANY (pcon.conkey)
            JOIN pg_class c ON fcon.confrelid = c.oid
            JOIN pg_namespace ns ON c.relnamespace = ns.oid
        WHERE att.attnum > 0
            AND att.attisdropped = false
            AND att.attrelid = TG_RELID
            AND array_length(pcon.conkey, 1) = 1
    LOOP
        parent_nspname := rec.nspname;
        parent_relname := rec.relname;
    END LOOP;

    IF (TG_OP = 'INSERT') THEN
        IF new.gid IS NULL THEN
            num_parents := 0;
            new.gid := nextval('"XP_Basisobjekte"."XP_Objekt_gid_seq"');
        ELSE
            EXECUTE 'SELECT count(gid) FROM ' || quote_ident(parent_nspname) || '.' || quote_ident(parent_relname) ||
                ' WHERE gid = ' || CAST(new.gid as varchar) || ';' INTO num_parents;

            IF pg_trigger_depth() = 1 THEN -- Trigger wird für unterste Kindtabelle aufgerufen
                RAISE WARNING 'Die gid sollte beim Einfügen in Tabelle % automatisch vergeben werden', TG_TABLE_NAME;
            END IF;
        END IF;

        IF parent_nspname IS NOT NULL AND num_parents = 0 THEN
            -- Elternobjekt anlegen
            EXECUTE 'INSERT INTO ' || quote_ident(parent_nspname) || '.' || quote_ident(parent_relname) ||
                '(gid) VALUES(' || CAST(new.gid as varchar) || ');';
        END IF;

        RETURN new;
    ELSIF (TG_OP = 'UPDATE') THEN
        new.gid := old.gid; --no change in gid allowed
        RETURN new;
    ELSIF (TG_OP = 'DELETE') THEN
        IF parent_nspname IS NOT NULL THEN
            -- Elternobjekt löschen
            EXECUTE 'DELETE FROM ' || quote_ident(parent_nspname) || '.' || quote_ident(parent_relname) ||
            ' WHERE gid = ' || CAST(old.gid as varchar) || ';';
        END IF;
        RETURN old;
    END IF;
 END;
$BODY$;
GRANT EXECUTE ON FUNCTION "XP_Basisobjekte"."child_of_XP_Objekt"() TO xp_user;

CREATE OR REPLACE FUNCTION "XP_Praesentationsobjekte"."child_of_XP_APObjekt"()
RETURNS trigger AS
$BODY$
DECLARE
    num_parents integer;
 BEGIN
    IF (TG_OP = 'INSERT') THEN
        IF new.gid IS NULL THEN
            num_parents := 0;
            new.gid := nextval('"XP_Praesentationsobjekte"."XP_APObjekt_gid_seq"');
        ELSE
            EXECUTE 'SELECT count(gid) FROM "XP_Praesentationsobjekte"."XP_AbstraktesPraesentationsobjekt"' ||
                ' WHERE gid = ' || CAST(new.gid as varchar) || ';' INTO num_parents;

            IF pg_trigger_depth() = 1 THEN -- Trigger wird für unterste Kindtabelle aufgerufen
                RAISE WARNING 'Die gid sollte beim Einfügen in Tabelle % automatisch vergeben werden', TG_TABLE_NAME;
            END IF;
        END IF;

        IF num_parents = 0 THEN
            -- Elternobjekt anlegen
            INSERT INTO "XP_Praesentationsobjekte"."XP_AbstraktesPraesentationsobjekt" (gid) VALUES (new.gid);
        END IF;

        RETURN new;
    ELSIF (TG_OP = 'UPDATE') THEN
        new.gid := old.gid; --no change in gid allowed
        RETURN new;
    ELSIF (TG_OP = 'DELETE') THEN
        DELETE FROM "XP_Praesentationsobjekte"."XP_AbstraktesPraesentationsobjekt" WHERE gid = old.gid;
        RETURN old;
    END IF;
 END; $BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
GRANT EXECUTE ON FUNCTION "XP_Praesentationsobjekte"."child_of_XP_APObjekt"() TO xp_user;

CREATE OR REPLACE FUNCTION "XP_Praesentationsobjekte"."child_of_XP_TPO"()
RETURNS trigger AS
$BODY$
DECLARE
    num_parents integer;
 BEGIN
    IF (TG_OP = 'INSERT') THEN
        IF new.gid IS NULL THEN
            num_parents := 0;
            new.gid := nextval('"XP_Praesentationsobjekte"."XP_APObjekt_gid_seq"');
        ELSE
            EXECUTE 'SELECT count(gid) FROM "XP_Praesentationsobjekte"."XP_TPO"' ||
                ' WHERE gid = ' || CAST(new.gid as varchar) || ';' INTO num_parents;

            IF pg_trigger_depth() = 1 THEN -- Trigger wird für unterste Kindtabelle aufgerufen
                RAISE WARNING 'Die gid sollte beim Einfügen in Tabelle % automatisch vergeben werden', TG_TABLE_NAME;
            END IF;
        END IF;

        IF num_parents = 0 THEN
            -- Elternobjekt anlegen
            INSERT INTO "XP_Praesentationsobjekte"."XP_TPO" (gid) VALUES (new.gid);
        END IF;

        RETURN new;
    ELSIF (TG_OP = 'UPDATE') THEN
        new.gid := old.gid; --no change in gid allowed
        RETURN new;
    ELSIF (TG_OP = 'DELETE') THEN
        DELETE FROM "XP_Praesentationsobjekte"."XP_TPO" WHERE gid = old.gid;
        RETURN old;
    END IF;
 END; $BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
GRANT EXECUTE ON FUNCTION "XP_Praesentationsobjekte"."child_of_XP_TPO"() TO xp_user;

CREATE OR REPLACE FUNCTION "XP_Basisobjekte"."XP_Abschnitt_Konformitaet"()
RETURNS trigger AS
$BODY$
 BEGIN
    IF (TG_OP = 'INSERT') OR (TG_OP = 'UPDATE') THEN
        IF new.text IS NULL AND new."refText" IS NULL THEN
            new.text := 'kein Text';
            RAISE WARNING 'Entweder text oder refText muss belegt sein!';
        ELSIF new.text IS NOT NULL AND new."refText" IS NOT NULL THEN
            new.text := NULL;
            RAISE WARNING 'text und refText dürfen nicht gleichzeitig belegt sein!';
        END IF;
        RETURN new;
    END IF;
 END; $BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
GRANT EXECUTE ON FUNCTION "XP_Basisobjekte"."XP_Abschnitt_Konformitaet"() TO xp_user;

CREATE OR REPLACE FUNCTION "XP_Basisobjekte"."child_of_XP_TextAbschnitt"()
RETURNS trigger AS
$BODY$
DECLARE
    num_parents integer;
 BEGIN
    IF (TG_OP = 'INSERT') THEN
        IF new.id IS NULL THEN
            num_parents := 0;
            new.id := nextval('"XP_Basisobjekte"."XP_TextAbschnitt_id_seq"');
        ELSE
            EXECUTE 'SELECT count(id) FROM "XP_Basisobjekte"."XP_TextAbschnitt"' ||
                ' WHERE id = ' || CAST(new.id as varchar) || ';' INTO num_parents;

            IF pg_trigger_depth() = 1 THEN -- Trigger wird für unterste Kindtabelle aufgerufen
                RAISE WARNING 'Die id sollte beim Einfügen in Tabelle % automatisch vergeben werden', TG_TABLE_NAME;
            END IF;
        END IF;

        IF num_parents = 0 THEN
            -- Elternobjekt anlegen
            INSERT INTO "XP_Basisobjekte"."XP_TextAbschnitt" (id) VALUES (new.id);
        END IF;

        RETURN new;
    ELSIF (TG_OP = 'UPDATE') THEN
        new.id := old.id; --no change in id allowed
        RETURN new;
    ELSIF (TG_OP = 'DELETE') THEN
        DELETE FROM "XP_Basisobjekte"."XP_TextAbschnitt" WHERE id = old.id;
        RETURN old;
    END IF;
 END; $BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
GRANT EXECUTE ON FUNCTION "XP_Basisobjekte"."child_of_XP_TextAbschnitt"() TO xp_user;

CREATE OR REPLACE FUNCTION "XP_Basisobjekte"."isFlaechenschlussobjekt"()
RETURNS trigger AS
$BODY$
DECLARE
    ebene integer;
 BEGIN
    IF (TG_OP = 'DELETE') THEN
        RETURN old;
    ELSE
        IF new."position" IS NOT NULL THEN
            new."position" := ST_ForceRHR(new."position");
        END IF;

        -- Neu 5.1: Flächenschluss wird nur zwischen Objekten der ebene = 0 hergestellt
        EXECUTE 'SELECT ebene FROM "XP_Basisobjekte"."XP_Objekt"' ||
                ' WHERE gid = ' || CAST(new.gid as varchar) || ';' INTO ebene;

        IF ebene = 0 THEN
            new.flaechenschluss := true;
        END IF;
        RETURN new;
    END IF;
 END; $BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
GRANT EXECUTE ON FUNCTION "XP_Basisobjekte"."isFlaechenschlussobjekt"() TO xp_user;

CREATE OR REPLACE FUNCTION "XP_Basisobjekte"."isFlaechenobjekt"()
RETURNS trigger AS
$BODY$
 BEGIN
    IF (TG_OP = 'INSERT' or TG_OP = 'UPDATE') THEN
        IF new."position" IS NOT NULL THEN
            new."position" := ST_ForceRHR(new."position");
        END IF;
    END IF;

    IF (TG_OP = 'INSERT') THEN
        IF new."flaechenschluss" IS NULL THEN
            new."flaechenschluss" := false;
        END IF;
    END IF;

    RETURN new;
 END; $BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
GRANT EXECUTE ON FUNCTION "XP_Basisobjekte"."isFlaechenobjekt"() TO xp_user;

CREATE OR REPLACE FUNCTION "XP_Basisobjekte"."isUeberlagerungsobjekt"()
RETURNS trigger AS
$BODY$
 BEGIN
    IF (TG_OP = 'DELETE') THEN
        RETURN old;
    ELSE
        IF new."position" IS NOT NULL THEN
            new."position" := ST_ForceRHR(new."position");
        END IF;

        new.flaechenschluss := false;
        RETURN new;
    END IF;
 END; $BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
GRANT EXECUTE ON FUNCTION "XP_Basisobjekte"."isUeberlagerungsobjekt"() TO xp_user;

CREATE OR REPLACE FUNCTION "XP_Basisobjekte"."positionFollowsRHR"()
RETURNS trigger AS
$BODY$
 BEGIN
    IF new."position" IS NOT NULL THEN
        new."position" := ST_ForceRHR(new."position");
    END IF;

    RETURN new;
 END; $BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
GRANT EXECUTE ON FUNCTION "XP_Basisobjekte"."positionFollowsRHR"() TO xp_user;

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

-- *****************************************************
-- CREATE TABLEs
-- *****************************************************

-- -----------------------------------------------------
-- Table "XP_Modellbereich"
-- -----------------------------------------------------

CREATE TABLE public."XP_Modellbereich" (
  "Kurz" VARCHAR(2) NOT NULL ,
  "Modellbereich" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Kurz") );
COMMENT ON TABLE public."XP_Modellbereich" IS 'Auflistung der in dieser Datenbank enthaltenen Modellbereiche';
GRANT SELECT ON TABLE public."XP_Modellbereich" TO xp_gast;

-- -----------------------------------------------------
-- Table "XP_Enumerationen"."XP_Rechtsstand"
-- -----------------------------------------------------
CREATE  TABLE  "XP_Enumerationen"."XP_Rechtsstand" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Code") );
GRANT SELECT ON TABLE "XP_Enumerationen"."XP_Rechtsstand" TO xp_gast;

-- -----------------------------------------------------
-- Table "XP_Enumerationen"."XP_AllgArtDerBaulNutzung"
-- -----------------------------------------------------
CREATE  TABLE  "XP_Enumerationen"."XP_AllgArtDerBaulNutzung" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Code") );
GRANT SELECT ON TABLE "XP_Enumerationen"."XP_AllgArtDerBaulNutzung" TO xp_gast;

-- -----------------------------------------------------
-- Table "XP_Enumerationen"."XP_BesondereArtDerBaulNutzung"
-- -----------------------------------------------------
CREATE  TABLE  "XP_Enumerationen"."XP_BesondereArtDerBaulNutzung" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Code") );
GRANT SELECT ON TABLE "XP_Enumerationen"."XP_BesondereArtDerBaulNutzung" TO xp_gast;

-- -----------------------------------------------------
-- Table "XP_Enumerationen"."XP_Sondernutzungen"
-- -----------------------------------------------------
CREATE  TABLE  "XP_Enumerationen"."XP_Sondernutzungen" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Code") );
GRANT SELECT ON TABLE "XP_Enumerationen"."XP_Sondernutzungen" TO xp_gast;

-- -----------------------------------------------------
-- Table "XP_Enumerationen"."XP_AbweichungBauNVOTypen"
-- -----------------------------------------------------
CREATE  TABLE  "XP_Enumerationen"."XP_AbweichungBauNVOTypen" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Code") );
GRANT SELECT ON TABLE "XP_Enumerationen"."XP_AbweichungBauNVOTypen" TO xp_gast;

-- -----------------------------------------------------
-- Table "XP_Enumerationen"."XP_ZweckbestimmungGemeinbedarf"
-- -----------------------------------------------------
CREATE  TABLE  "XP_Enumerationen"."XP_ZweckbestimmungGemeinbedarf" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Code") );
GRANT SELECT ON TABLE "XP_Enumerationen"."XP_ZweckbestimmungGemeinbedarf" TO xp_gast;

-- -----------------------------------------------------
-- Table "XP_Enumerationen"."XP_KlassifizSchutzgebietNaturschutzrecht"
-- -----------------------------------------------------
CREATE TABLE  "XP_Enumerationen"."XP_KlassifizSchutzgebietNaturschutzrecht" (
  "Code" INTEGER NOT NULL,
  "Bezeichner" VARCHAR(64) NOT NULL,
  PRIMARY KEY ("Code"));

GRANT SELECT ON TABLE "XP_Enumerationen"."XP_KlassifizSchutzgebietNaturschutzrecht" TO xp_gast;

-- -----------------------------------------------------
-- Table "XP_Enumerationen"."XP_ZweckbestimmungSpielSportanlage"
-- -----------------------------------------------------
CREATE  TABLE  "XP_Enumerationen"."XP_ZweckbestimmungSpielSportanlage" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Code") );
GRANT SELECT ON TABLE "XP_Enumerationen"."XP_ZweckbestimmungSpielSportanlage" TO xp_gast;

-- -----------------------------------------------------
-- Table "XP_Enumerationen"."XP_ZweckbestimmungGruen"
-- -----------------------------------------------------
CREATE  TABLE  "XP_Enumerationen"."XP_ZweckbestimmungGruen" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Code") );
GRANT SELECT ON TABLE "XP_Enumerationen"."XP_ZweckbestimmungGruen" TO xp_gast;

-- -----------------------------------------------------
-- Table "XP_Enumerationen"."XP_ZweckbestimmungWald"
-- -----------------------------------------------------
CREATE  TABLE  "XP_Enumerationen"."XP_ZweckbestimmungWald" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Code") );
GRANT SELECT ON TABLE "XP_Enumerationen"."XP_ZweckbestimmungWald" TO xp_gast;

-- -----------------------------------------------------
-- Table "XP_Enumerationen"."XP_EigentumsartWald"
-- -----------------------------------------------------
CREATE  TABLE  "XP_Enumerationen"."XP_EigentumsartWald" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Code") );
GRANT SELECT ON TABLE "XP_Enumerationen"."XP_EigentumsartWald" TO xp_gast;

-- -----------------------------------------------------
-- Table "XP_Enumerationen"."XP_WaldbetretungTyp"
-- -----------------------------------------------------
CREATE  TABLE  "XP_Enumerationen"."XP_WaldbetretungTyp" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Code") );
GRANT SELECT ON TABLE "XP_Enumerationen"."XP_WaldbetretungTyp" TO xp_gast;

-- -----------------------------------------------------
-- Table "XP_Enumerationen"."XP_ZweckbestimmungLandwirtschaft"
-- -----------------------------------------------------
CREATE  TABLE  "XP_Enumerationen"."XP_ZweckbestimmungLandwirtschaft" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Code") );
GRANT SELECT ON TABLE "XP_Enumerationen"."XP_ZweckbestimmungLandwirtschaft" TO xp_gast;

-- -----------------------------------------------------
-- Table "XP_Enumerationen"."XP_Nutzungsform"
-- -----------------------------------------------------
CREATE  TABLE  "XP_Enumerationen"."XP_Nutzungsform" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Code") );
GRANT SELECT ON TABLE "XP_Enumerationen"."XP_Nutzungsform" TO xp_gast;

-- -----------------------------------------------------
-- Table "XP_Enumerationen"."XP_ZweckbestimmungKennzeichnung"
-- -----------------------------------------------------
CREATE  TABLE  "XP_Enumerationen"."XP_ZweckbestimmungKennzeichnung" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Code") );
GRANT SELECT ON TABLE "XP_Enumerationen"."XP_ZweckbestimmungKennzeichnung" TO xp_gast;

-- -----------------------------------------------------
-- Table "XP_Enumerationen"."XP_ZweckbestimmungVerEntsorgung"
-- -----------------------------------------------------
CREATE  TABLE  "XP_Enumerationen"."XP_ZweckbestimmungVerEntsorgung" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Code") );
GRANT SELECT ON TABLE "XP_Enumerationen"."XP_ZweckbestimmungVerEntsorgung" TO xp_gast;

-- -----------------------------------------------------
-- Table "XP_Enumerationen"."XP_ZweckbestimmungGewaesser"
-- -----------------------------------------------------
CREATE  TABLE  "XP_Enumerationen"."XP_ZweckbestimmungGewaesser" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Code") );
GRANT SELECT ON TABLE "XP_Enumerationen"."XP_ZweckbestimmungGewaesser" TO xp_gast;

-- -----------------------------------------------------
-- Table "XP_Enumerationen"."XP_ZweckbestimmungWasserwirtschaft"
-- -----------------------------------------------------
CREATE  TABLE  "XP_Enumerationen"."XP_ZweckbestimmungWasserwirtschaft" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Code") );
GRANT SELECT ON TABLE "XP_Enumerationen"."XP_ZweckbestimmungWasserwirtschaft" TO xp_gast;

-- -----------------------------------------------------
-- Table "XP_Enumerationen"."XP_Bundeslaender"
-- -----------------------------------------------------
CREATE  TABLE  "XP_Enumerationen"."XP_Bundeslaender" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Code") );
GRANT SELECT ON TABLE "XP_Enumerationen"."XP_Bundeslaender" TO xp_gast;

-- -----------------------------------------------------
-- Table "XP_Basisobjekte"."XP_RaeumlicherGeltungsbereich"
-- -----------------------------------------------------
CREATE  TABLE  "XP_Basisobjekte"."XP_RaeumlicherGeltungsbereich" (
  "gid" BIGINT NOT NULL ,
  "raeumlicherGeltungsbereich" GEOMETRY(Multipolygon,25832) NOT NULL ,
  PRIMARY KEY ("gid") );
GRANT SELECT ON TABLE "XP_Basisobjekte"."XP_RaeumlicherGeltungsbereich" TO xp_gast;
GRANT ALL ON TABLE "XP_Basisobjekte"."XP_RaeumlicherGeltungsbereich" TO xp_user;
CREATE TRIGGER  "XP_RaeumlicherGeltungsbereich_isAbstract" BEFORE INSERT ON "XP_Basisobjekte"."XP_RaeumlicherGeltungsbereich" FOR EACH STATEMENT EXECUTE PROCEDURE "XP_Basisobjekte"."isAbstract"();

-- -----------------------------------------------------
-- Table "XP_Basisobjekte"."XP_Geltungsbereich"
-- -----------------------------------------------------
CREATE  TABLE  "XP_Basisobjekte"."XP_Geltungsbereich" (
  "gid" BIGINT NOT NULL ,
  "geltungsbereich" GEOMETRY(Multipolygon,25832),
  PRIMARY KEY ("gid") );
GRANT SELECT ON TABLE "XP_Basisobjekte"."XP_Geltungsbereich" TO xp_gast;
GRANT ALL ON TABLE "XP_Basisobjekte"."XP_Geltungsbereich" TO xp_user;
CREATE TRIGGER  "XP_Geltungsbereich_isAbstract" BEFORE INSERT ON "XP_Basisobjekte"."XP_Geltungsbereich" FOR EACH STATEMENT EXECUTE PROCEDURE "XP_Basisobjekte"."isAbstract"();

-- -----------------------------------------------------
-- Table "XP_Basisobjekte"."XP_GesetzlicheGrundlage"
-- -----------------------------------------------------
CREATE  TABLE  "XP_Basisobjekte"."XP_GesetzlicheGrundlage" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Code") );
GRANT SELECT ON TABLE "XP_Basisobjekte"."XP_GesetzlicheGrundlage" TO xp_gast;
GRANT ALL ON TABLE "XP_Basisobjekte"."XP_GesetzlicheGrundlage" TO xp_user;
CREATE TRIGGER "ins_upd_XP_GesetzlicheGrundlage" BEFORE INSERT OR UPDATE ON "XP_Basisobjekte"."XP_GesetzlicheGrundlage" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isCodeList"();

-- -----------------------------------------------------
-- Table "XP_Basisobjekte"."XP_BedeutungenBereich"
-- -----------------------------------------------------
CREATE  TABLE  "XP_Basisobjekte"."XP_BedeutungenBereich" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(45) NOT NULL ,
  PRIMARY KEY ("Code") );
GRANT SELECT ON TABLE "XP_Basisobjekte"."XP_BedeutungenBereich" TO xp_gast;

-- -----------------------------------------------------
-- Table "XP_Basisobjekte"."XP_MimeTypes"
-- -----------------------------------------------------
CREATE  TABLE  "XP_Basisobjekte"."XP_MimeTypes" (
  "Code" VARCHAR(64) NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Code") );
GRANT SELECT ON TABLE "XP_Basisobjekte"."XP_MimeTypes" TO xp_gast;
GRANT ALL ON "XP_Basisobjekte"."XP_MimeTypes" TO xp_user;

-- -----------------------------------------------------
-- Table "XP_Basisobjekte"."XP_ExterneReferenzArt"
-- -----------------------------------------------------
CREATE  TABLE  "XP_Basisobjekte"."XP_ExterneReferenzArt" (
  "Code" VARCHAR(64) NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Code") );
GRANT SELECT ON TABLE "XP_Basisobjekte"."XP_ExterneReferenzArt" TO xp_gast;

-- -----------------------------------------------------
-- Table "XP_Basisobjekte"."XP_ExterneReferenz"
-- -----------------------------------------------------
CREATE  TABLE  "XP_Basisobjekte"."XP_ExterneReferenz" (
  "id" INTEGER NOT NULL DEFAULT nextval('"XP_Basisobjekte"."XP_ExterneReferenz_id_seq"'),
  "georefURL" VARCHAR(255) NULL ,
  "georefMimeType" VARCHAR(64) NULL ,
  "art" VARCHAR(64) NULL ,
  "informationssystemURL" VARCHAR(255) NULL ,
  "referenzName" VARCHAR(255) NOT NULL ,
  "referenzURL" VARCHAR(255) NULL ,
  "referenzMimeType" VARCHAR(64) NULL ,
  "beschreibung" VARCHAR(255) NULL ,
  "datum" DATE NULL,
  "gml_id" VARCHAR(64) NULL ,
  PRIMARY KEY ("id") ,
  CONSTRAINT "fk_xp_externereferenz_xp_mimetypes"
    FOREIGN KEY ("referenzMimeType" )
    REFERENCES "XP_Basisobjekte"."XP_MimeTypes" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_xp_externereferenz_xp_mimetypes1"
    FOREIGN KEY ("georefMimeType" )
    REFERENCES "XP_Basisobjekte"."XP_MimeTypes" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_xp_externereferenz_xp_externereferenzart1"
    FOREIGN KEY ("art" )
    REFERENCES "XP_Basisobjekte"."XP_ExterneReferenzArt" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE);

COMMENT ON TABLE "XP_Basisobjekte"."XP_ExterneReferenz" IS 'Verweis auf ein extern gespeichertes Dokument, einen extern gespeicherten, georeferenzierten Plan oder einen Datenbank-Eintrag. Einer der beiden Attribute "referenzName" bzw. "referenzURL" muss belegt sein.';
COMMENT ON COLUMN "XP_Basisobjekte"."XP_ExterneReferenz"."id" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN "XP_Basisobjekte"."XP_ExterneReferenz"."informationssystemURL" IS 'URI des des zugehörigen Informationssystems';
COMMENT ON COLUMN "XP_Basisobjekte"."XP_ExterneReferenz"."referenzName" IS 'Name des referierten Dokuments innerhalb des Informationssystems.';
COMMENT ON COLUMN "XP_Basisobjekte"."XP_ExterneReferenz"."referenzURL" IS 'URI des referierten Dokuments, bzw. Datenbank-Schlüssel. Wenn der XPlanGML Datensatz und das referierte Dokument in einem hierarchischen Ordnersystem gespeichert sind, kann die URI auch einen relativen Pfad vom XPlanGML-Datensatz zum Dokument enthalten.';
COMMENT ON COLUMN "XP_Basisobjekte"."XP_ExterneReferenz"."referenzMimeType" IS 'Mime-Type des referierten Dokumentes';
COMMENT ON COLUMN "XP_Basisobjekte"."XP_ExterneReferenz"."georefURL" IS 'Referenz auf eine Georeferenzierungs-Datei. Das Attribut ist nur relevant bei Verweisen auf georeferenzierte Rasterbilder.';
COMMENT ON COLUMN "XP_Basisobjekte"."XP_ExterneReferenz"."georefMimeType" IS 'Mime-Type der Georeferenzierungs-Datei. Das Arrtibut ist nur relevant bei Verweisen auf georeferenzierte Rasterbilder.';
COMMENT ON COLUMN "XP_Basisobjekte"."XP_ExterneReferenz"."beschreibung" IS 'Beschreibung des referierten Dokuments';
COMMENT ON COLUMN "XP_Basisobjekte"."XP_ExterneReferenz"."art" IS 'Typisierung der referierten Dokumente: Beliebiges Dokument oder georeferenzierter Plan';
COMMENT ON COLUMN "XP_Basisobjekte"."XP_ExterneReferenz"."datum" IS 'Datum des referierten Dokuments';
COMMENT ON COLUMN "XP_Basisobjekte"."XP_ExterneReferenz"."gml_id" IS 'Eindeutiger Identifier des Objektes für Im- und Export.';
CREATE TRIGGER "XP_ExterneReferenz_gml_id" BEFORE INSERT ON "XP_Basisobjekte"."XP_ExterneReferenz" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."create_gml_id"();
CREATE INDEX "idx_fk_xp_externereferenz_xp_mimetypes" ON "XP_Basisobjekte"."XP_ExterneReferenz" ("referenzMimeType") ;
CREATE INDEX "idx_fk_xp_externereferenz_xp_mimetypes1" ON "XP_Basisobjekte"."XP_ExterneReferenz" ("georefMimeType") ;
CREATE INDEX "idx_fk_xp_externereferenz_xp_externereferenzart1" ON "XP_Basisobjekte"."XP_ExterneReferenz" ("art") ;

GRANT SELECT ON TABLE "XP_Basisobjekte"."XP_ExterneReferenz" TO xp_gast;
GRANT ALL ON TABLE "XP_Basisobjekte"."XP_ExterneReferenz" TO xp_user;

-- -----------------------------------------------------
-- Table "XP_Basisobjekte"."XP_ExterneReferenzTyp"
-- -----------------------------------------------------
CREATE  TABLE  "XP_Basisobjekte"."XP_ExterneReferenzTyp" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Code") );
GRANT SELECT ON TABLE "XP_Basisobjekte"."XP_ExterneReferenzTyp" TO xp_gast;

-- -----------------------------------------------------
-- Table "XP_Basisobjekte"."XP_SpezExterneReferenz"
-- -----------------------------------------------------
CREATE  TABLE  "XP_Basisobjekte"."XP_SpezExterneReferenz" (
  "id" INTEGER NOT NULL,
  "typ" INTEGER NOT NULL DEFAULT 9999,
  PRIMARY KEY ("id") ,
  CONSTRAINT "fk_xp_externereferenz_xp_referenz_typen"
    FOREIGN KEY ("typ" )
    REFERENCES "XP_Basisobjekte"."XP_ExterneReferenzTyp" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_XP_SpezExterneReferenz_parent"
    FOREIGN KEY ("id" )
    REFERENCES "XP_Basisobjekte"."XP_ExterneReferenz" ("id")
    ON DELETE CASCADE
    ON UPDATE CASCADE
);
COMMENT ON TABLE "XP_Basisobjekte"."XP_SpezExterneReferenz" IS 'Verweis auf ein extern gespeichertes Dokument, einen extern gespeicherten, georeferenzierten Plan oder einen Datenbank-Eintrag. Einer der beiden Attribute "referenzName" bzw. "referenzURL" muss belegt sein.';
COMMENT ON COLUMN "XP_Basisobjekte"."XP_SpezExterneReferenz"."id" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN "XP_Basisobjekte"."XP_SpezExterneReferenz"."typ" IS 'Typ / Inhalt des referierten Dokuments oder Rasterplans.';
CREATE INDEX "idx_fk_xp_externereferenz_xp_referenz_typen" ON "XP_Basisobjekte"."XP_SpezExterneReferenz" ("typ");
CREATE TRIGGER "change_to_XP_SpezExterneReferenz" BEFORE INSERT OR UPDATE ON "XP_Basisobjekte"."XP_SpezExterneReferenz" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_ExterneReferenz"();
CREATE TRIGGER "delete_XP_SpezExterneReferenz" AFTER DELETE ON "XP_Basisobjekte"."XP_SpezExterneReferenz" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_ExterneReferenz"();
GRANT SELECT ON TABLE "XP_Basisobjekte"."XP_SpezExterneReferenz" TO xp_gast;
GRANT ALL ON TABLE "XP_Basisobjekte"."XP_SpezExterneReferenz" TO xp_user;

-- -----------------------------------------------------
-- Table "XP_Raster"."XP_Rasterdarstellung"
-- -----------------------------------------------------
CREATE TABLE "XP_Raster"."XP_Rasterdarstellung" (
  "id" INTEGER NOT NULL DEFAULT nextval('"XP_Raster"."XP_Rasterdarstellung_id_seq"'),
  "refText" INTEGER NULL ,
  PRIMARY KEY ("id") ,
  CONSTRAINT "fk_XP_Rasterdarstellung_XP_ExterneReferenz1"
    FOREIGN KEY ("refText" )
    REFERENCES "XP_Basisobjekte"."XP_ExterneReferenz" ("id" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
COMMENT ON TABLE "XP_Raster"."XP_Rasterdarstellung" IS 'Georeferenzierte Rasterdarstellung eines Plans. Das über refScan referierte Rasterbild zeigt den Basisplan, dessen Geltungsbereich durch den Geltungsbereich des Gesamtplans (Attribut geltungsbereich von XP_Bereich) repräsentiert ist.
Im Standard sind nur georeferenzierte Rasterpläne zugelassen. Die über refScan referierte externe Referenz muss deshalb entweder vom Typ "PlanMitGeoreferenz" sein oder einen WMS-Request enthalten.
Die Klasse ist veraltet und wird in XPlanGML V. 6.0 eliminiert.';
COMMENT ON COLUMN "XP_Raster"."XP_Rasterdarstellung"."id" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN "XP_Raster"."XP_Rasterdarstellung"."refText" IS 'Referenz auf die textlich formulierten Inhalte des Plans.';

CREATE INDEX "idx_fk_XP_Rasterdarstellung_XP_ExterneReferenz1" ON "XP_Raster"."XP_Rasterdarstellung" ("refText") ;

GRANT SELECT ON TABLE "XP_Raster"."XP_Rasterdarstellung" TO xp_gast;
GRANT ALL ON TABLE "XP_Raster"."XP_Rasterdarstellung" TO xp_user;

-- -----------------------------------------------------
-- Table "XP_Raster"."XP_Rasterdarstellung_refScan"
-- -----------------------------------------------------
CREATE TABLE  "XP_Raster"."XP_Rasterdarstellung_refScan" (
  "XP_Rasterdarstellung_id" INTEGER NOT NULL ,
  "refScan" INTEGER NOT NULL ,
  PRIMARY KEY ("XP_Rasterdarstellung_id", "refScan") ,
  CONSTRAINT "fk_XP_Rasterdarstellung_refScan1"
    FOREIGN KEY ("XP_Rasterdarstellung_id" )
    REFERENCES "XP_Raster"."XP_Rasterdarstellung" ("id" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_XP_Rasterdarstellung_refScan2"
    FOREIGN KEY ("refScan" )
    REFERENCES "XP_Basisobjekte"."XP_ExterneReferenz" ("id" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
COMMENT ON TABLE "XP_Raster"."XP_Rasterdarstellung_refScan" IS 'Referenz auf eine georeferenzierte Rasterversion des Basisplans';
CREATE INDEX "idx_fk_XP_Rasterdarstellung_refScan1" ON "XP_Raster"."XP_Rasterdarstellung_refScan" ("XP_Rasterdarstellung_id") ;
CREATE INDEX "idx_fk_XP_Rasterdarstellung_refScan2" ON "XP_Raster"."XP_Rasterdarstellung_refScan" ("refScan") ;

GRANT SELECT ON TABLE "XP_Raster"."XP_Rasterdarstellung_refScan" TO xp_gast;
GRANT ALL ON TABLE "XP_Raster"."XP_Rasterdarstellung_refScan" TO xp_user;

-- -----------------------------------------------------
-- Table "XP_Raster"."XP_Rasterdarstellung_refLegende"
-- -----------------------------------------------------
CREATE TABLE "XP_Raster"."XP_Rasterdarstellung_refLegende" (
  "XP_Rasterdarstellung_id" INTEGER NOT NULL ,
  "refLegende" INTEGER NOT NULL ,
  PRIMARY KEY ("XP_Rasterdarstellung_id", "refLegende") ,
  CONSTRAINT "fk_XP_Rasterdarstellung_refLegende1"
    FOREIGN KEY ("XP_Rasterdarstellung_id" )
    REFERENCES "XP_Raster"."XP_Rasterdarstellung" ("id" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_XP_Rasterdarstellung_refLegende2"
    FOREIGN KEY ("refLegende" )
    REFERENCES "XP_Basisobjekte"."XP_ExterneReferenz" ("id" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
COMMENT ON TABLE "XP_Raster"."XP_Rasterdarstellung_refLegende" IS 'Referenz auf die Legende des Plans.';
CREATE INDEX "idx_fk_XP_Rasterdarstellung_refLegende1" ON "XP_Raster"."XP_Rasterdarstellung_refLegende" ("XP_Rasterdarstellung_id") ;
CREATE INDEX "idx_fk_XP_Rasterdarstellung_refLegende2" ON "XP_Raster"."XP_Rasterdarstellung_refLegende" ("refLegende") ;

GRANT SELECT ON TABLE "XP_Raster"."XP_Rasterdarstellung_refLegende" TO xp_gast;
GRANT ALL ON TABLE "XP_Raster"."XP_Rasterdarstellung_refLegende" TO xp_user;

-- -----------------------------------------------------
-- Table "XP_Basisobjekte"."XP_Plan"
-- -----------------------------------------------------
CREATE  TABLE  "XP_Basisobjekte"."XP_Plan" (
  "gid" BIGINT NOT NULL DEFAULT nextval('"XP_Basisobjekte"."XP_Plan_gid_seq"'),
  "name" VARCHAR(256) NOT NULL ,
  "nummer" VARCHAR(16) NULL ,
  "internalId" VARCHAR(255) NULL ,
  "beschreibung" text NULL ,
  "kommentar" VARCHAR(1028) NULL ,
  "technHerstellDatum" DATE NULL ,
  "genehmigungsDatum" DATE NULL ,
  "untergangsDatum" DATE NULL ,
  "erstellungsMassstab" INTEGER  NULL ,
  "bezugshoehe" REAL NULL ,
  "technischerPlanersteller" VARCHAR(1024),
  "refExternalCodeList" INTEGER NULL ,
  "gml_id" VARCHAR(64) NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_XP_Plan_XP_ExterneReferenz1"
    FOREIGN KEY ("refExternalCodeList" )
    REFERENCES "XP_Basisobjekte"."XP_ExterneReferenz" ("id" )
    ON DELETE SET NULL
    ON UPDATE CASCADE);
COMMENT ON TABLE "XP_Basisobjekte"."XP_Plan" IS 'Abstrakte Oberklasse für alle Klassen von raumbezogenen Plänen.';
COMMENT ON COLUMN "XP_Basisobjekte"."XP_Plan"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN "XP_Basisobjekte"."XP_Plan"."name" IS 'Name des Plans.';
COMMENT ON COLUMN "XP_Basisobjekte"."XP_Plan"."nummer" IS 'Nummer des Plans.';
COMMENT ON COLUMN "XP_Basisobjekte"."XP_Plan"."internalId" IS 'Interner Identifikator des Plans.';
COMMENT ON COLUMN "XP_Basisobjekte"."XP_Plan"."beschreibung" IS 'Kommentierende Beschreibung des Plans.';
COMMENT ON COLUMN "XP_Basisobjekte"."XP_Plan"."kommentar" IS 'Beliebiger Kommentar zum Plan';
COMMENT ON COLUMN "XP_Basisobjekte"."XP_Plan"."technHerstellDatum" IS 'Datum, an dem der Plan technisch ausgefertigt wurde.';
COMMENT ON COLUMN "XP_Basisobjekte"."XP_Plan"."genehmigungsDatum" IS 'Datum der Genehmigung des Plans.';
COMMENT ON COLUMN "XP_Basisobjekte"."XP_Plan"."untergangsDatum" IS 'Datum, an dem der Plan (z.B. durch Ratsbeschluss oder Gerichtsurteil) aufgehoben oder für nichtig erklärt wurde.';
COMMENT ON COLUMN "XP_Basisobjekte"."XP_Plan"."erstellungsMassstab" IS 'Der bei der Erstellung des Plans benutzte Kartenmassstab.';
COMMENT ON COLUMN "XP_Basisobjekte"."XP_Plan"."bezugshoehe" IS 'Standard Bezugshöhe (absolut NhN) für relative Höhenangaben von Planinhalten.';
COMMENT ON COLUMN "XP_Basisobjekte"."XP_Plan"."technischerPlanersteller" IS 'Bezeichnung der Institution oder Firma, die den Plan technisch erstellt hat.';
COMMENT ON COLUMN "XP_Basisobjekte"."XP_Plan"."refExternalCodeList" IS 'Referenz auf ein GML-Dictionary mit Codelists.';
COMMENT ON COLUMN "XP_Basisobjekte"."XP_Plan"."gml_id" IS 'Eindeutiger Identifier des Objektes für Im- und Export.';
CREATE TRIGGER "XP_Plan_gml_id" BEFORE INSERT ON "XP_Basisobjekte"."XP_Plan" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."create_gml_id"();
CREATE INDEX "idx_fk_XP_Plan_XP_ExterneReferenz1" ON "XP_Basisobjekte"."XP_Plan" ("refExternalCodeList") ;
CREATE TRIGGER "XP_Plan_hasChanged" AFTER INSERT OR UPDATE OR DELETE ON "XP_Basisobjekte"."XP_Plan" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."change_to_XP_Plan"();
CREATE TRIGGER "XP_Plan_propagate_name" AFTER UPDATE ON "XP_Basisobjekte"."XP_Plan" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."propagate_name_to_child"();
GRANT SELECT ON TABLE "XP_Basisobjekte"."XP_Plan" TO xp_gast;
GRANT ALL ON TABLE "XP_Basisobjekte"."XP_Plan" TO xp_user;

-- -----------------------------------------------------
-- Table "XP_Basisobjekte"."XP_Bereich"
-- -----------------------------------------------------
CREATE  TABLE  "XP_Basisobjekte"."XP_Bereich" (
  "gid" BIGINT NOT NULL DEFAULT nextval('"XP_Basisobjekte"."XP_Bereich_gid_seq"'),
  "nummer" INTEGER NOT NULL DEFAULT 0 ,
  "name" VARCHAR(255) NOT NULL ,
  "bedeutung" INTEGER NULL ,
  "detaillierteBedeutung" VARCHAR(255) NULL ,
  "erstellungsMassstab" INTEGER NULL ,
  "rasterBasis" INTEGER NULL,
  "gml_id" VARCHAR(64) NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_XP_Bereich_XP_BedeutungenBereich1"
    FOREIGN KEY ("bedeutung" )
    REFERENCES "XP_Basisobjekte"."XP_BedeutungenBereich" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
    CONSTRAINT "fk_XP_Bereich_XP_Rasterdarstellung1"
    FOREIGN KEY ("rasterBasis" )
    REFERENCES "XP_Raster"."XP_Rasterdarstellung" ("id" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
COMMENT ON TABLE "XP_Basisobjekte"."XP_Bereich" IS 'Abstrakte Oberklasse für die Modellierung von Planbereichen. Ein Planbereich fasst die Inhalte eines Plans nach bestimmten Kriterien zusammen.';
COMMENT ON COLUMN "XP_Basisobjekte"."XP_Bereich"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN "XP_Basisobjekte"."XP_Bereich"."nummer" IS 'Nummer des Bereichs. Wenn der Bereich als Ebene eines BPlans interpretiert wird, kann aus dem Attribut die vertikale Reihenfolge der Ebenen rekonstruiert werden.';
COMMENT ON COLUMN "XP_Basisobjekte"."XP_Bereich"."name" IS 'Bezeichnung des Bereiches';
COMMENT ON COLUMN "XP_Basisobjekte"."XP_Bereich"."bedeutung" IS 'Spezifikation der semantischen Bedeutung eines Bereiches.';
COMMENT ON COLUMN "XP_Basisobjekte"."XP_Bereich"."detaillierteBedeutung" IS 'Detaillierte Erklärung der semantischen Bedeutung eines Bereiches, in Ergänzung des Attributs bedeutung.';
COMMENT ON COLUMN "XP_Basisobjekte"."XP_Bereich"."erstellungsMassstab" IS 'Der bei der Erstellung der Inhalte des Planbereichs benutzte Kartenmassstab. Wenn dieses Attribut nicht spezifiziert ist, gilt für den Bereich der auf Planebene (XP_Plan) spezifizierte Masstab.';
COMMENT ON COLUMN "XP_Basisobjekte"."XP_Bereich"."rasterBasis" IS 'Ein Plan kann optional eine georeferenzierte Rasterkarte referieren.
Diese Relation ist veraltet und wird in XPlanGML 6.0 wegfallen. XP_Rasterdarstellung sollte folgendermaßen abgebildet werden:
XP_Rasterdarstellung.refScan --> XP_Bereich.refScan
XP_Rasterdarstellung.refText --> XP_Plan.texte
XP_Rasterdarstellung.refLegende --> XP_Plan.externeReferenz';
COMMENT ON COLUMN "XP_Basisobjekte"."XP_Bereich"."gml_id" IS 'Eindeutiger Identifier des Objektes für Im- und Export.';
CREATE INDEX "idx_fk_XP_Bereich_XP_BedeutungenBereich1" ON "XP_Basisobjekte"."XP_Bereich" ("bedeutung") ;
CREATE INDEX "idx_fk_XP_Bereich_XP_Rasterdarstellung1" ON "XP_Basisobjekte"."XP_Bereich" ("rasterBasis") ;
GRANT SELECT ON TABLE "XP_Basisobjekte"."XP_Bereich" TO xp_gast;
GRANT ALL ON TABLE "XP_Basisobjekte"."XP_Bereich" TO xp_user;
CREATE TRIGGER "XP_Bereich_propagate_name" AFTER UPDATE ON "XP_Basisobjekte"."XP_Bereich" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."propagate_name_to_child"();
CREATE TRIGGER "XP_Bereich_gml_id" BEFORE INSERT ON "XP_Basisobjekte"."XP_Bereich" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."create_gml_id"();
CREATE TRIGGER "XP_Bereich_has_update" BEFORE UPDATE ON "XP_Basisobjekte"."XP_Bereich" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."XP_Bereich_before_update"();

-- -----------------------------------------------------
-- Table "XP_Basisobjekte"."XP_Bereich_refScan"
-- -----------------------------------------------------
CREATE TABLE "XP_Basisobjekte"."XP_Bereich_refScan" (
  "XP_Bereich_gid" BIGINT NOT NULL ,
  "externeReferenz" INTEGER NOT NULL ,
  PRIMARY KEY ("XP_Bereich_gid", "externeReferenz") ,
  CONSTRAINT "fk_XP_Bereich_refScan_XP_Bereich"
    FOREIGN KEY ("XP_Bereich_gid" )
    REFERENCES "XP_Basisobjekte"."XP_Bereich" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
    CONSTRAINT "fk_XP_Bereich_refScan_XP_ExterneReferenz"
    FOREIGN KEY ("externeReferenz" )
    REFERENCES "XP_Basisobjekte"."XP_ExterneReferenz" ("id" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
COMMENT ON TABLE "XP_Basisobjekte"."XP_Bereich_refScan" IS 'Referenz auf einen georeferenzierten Rasterplan, der die Inhalte des Bereichs wiedergibt. Das über refScan referierte Rasterbild zeigt einen Plan, dessen Geltungsbereich durch den Geltungsbereich des Bereiches (Attribut geltungsbereich von XP_Bereich) oder, wenn geltungsbereich nicht belegt ist, den Geltungsbereich des Gesamtplans (Attribut raeumlicherGeltungsbereich von XP_PLan) definiert ist.
Im Standard sind nur georeferenzierte Rasterpläne zugelassen. Die über refScan referierte externe Referenz muss deshalb entweder vom Typ "PlanMitGeoreferenz" sein oder einen WMS-Request enthalten.';
CREATE INDEX "idx_fk_XP_Bereich_refScan_XP_Bereich" ON "XP_Basisobjekte"."XP_Bereich_refScan" ("XP_Bereich_gid") ;
CREATE INDEX "idx_fk_XP_Bereich_refScan_XP_ExterneReferenz" ON "XP_Basisobjekte"."XP_Bereich_refScan" ("externeReferenz");

GRANT SELECT ON TABLE "XP_Basisobjekte"."XP_Bereich_refScan" TO xp_gast;
GRANT ALL ON TABLE "XP_Basisobjekte"."XP_Bereich_refScan" TO xp_user;

-- -----------------------------------------------------
-- Table "XP_Basisobjekte"."XP_WirksamkeitBedingung"
-- -----------------------------------------------------
CREATE TABLE "XP_Basisobjekte"."XP_WirksamkeitBedingung" (
  "id" INTEGER NOT NULL DEFAULT nextval('"XP_Basisobjekte"."XP_WirksamkeitBedingung_id_seq"'),
  "bedingung" VARCHAR(255) NULL ,
  "datumAbsolut" DATE NULL ,
  "datumRelativ" INTEGER NULL ,
  PRIMARY KEY ("id") );
GRANT SELECT ON "XP_Basisobjekte"."XP_WirksamkeitBedingung" TO xp_gast;
GRANT ALL ON "XP_Basisobjekte"."XP_WirksamkeitBedingung" TO xp_user;
COMMENT ON TABLE "XP_Basisobjekte"."XP_WirksamkeitBedingung" IS 'Spezifikation von Bedingungen für die Wirksamkeit oder Unwirksamkeit einer Festsetzung.';
COMMENT ON COLUMN "XP_Basisobjekte"."XP_WirksamkeitBedingung"."bedingung" IS 'Textlich formulierte Bedingung für die Wirksamkeit oder Unwirksamkeit einer Festsetzung.';
COMMENT ON COLUMN "XP_Basisobjekte"."XP_WirksamkeitBedingung"."datumAbsolut" IS 'Datum an dem eine Festsetzung wirksam oder unwirksam wird.';
COMMENT ON COLUMN "XP_Basisobjekte"."XP_WirksamkeitBedingung"."datumRelativ" IS 'Zeitspanne, nach der eine Festsetzung wirksam oder unwirksam wird, wenn die im Attribut bedingung spezifizierte Bedingung erfüllt ist.';

-- -----------------------------------------------------
-- Table "XP_Basisobjekte"."XP_Objekt"
-- -----------------------------------------------------
CREATE  TABLE  "XP_Basisobjekte"."XP_Objekt" (
  "gid" BIGINT NOT NULL DEFAULT nextval('"XP_Basisobjekte"."XP_Objekt_gid_seq"'),
  "uuid" VARCHAR(64) NULL ,
  "text" VARCHAR(255) NULL ,
  "rechtsstand" INTEGER NULL ,
  "gesetzlicheGrundlage" INTEGER NULL ,
  "gliederung1" VARCHAR(255) NULL ,
  "gliederung2" VARCHAR(255) NULL ,
  "ebene" INTEGER NULL DEFAULT 0 ,
  "startBedingung" INTEGER NULL ,
  "endeBedingung" INTEGER NULL ,
  "gml_id" VARCHAR(64) NULL ,
  "aufschrift" VARCHAR(64) NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_XP_Objekt_XP_Rechtsstand1"
    FOREIGN KEY ("rechtsstand" )
    REFERENCES "XP_Enumerationen"."XP_Rechtsstand" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_XP_Objekt_xp_gesetzlichegrundlage1"
    FOREIGN KEY ("gesetzlicheGrundlage" )
    REFERENCES "XP_Basisobjekte"."XP_GesetzlicheGrundlage" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_XP_Objekt_XP_WirksamkeitBedingung1"
    FOREIGN KEY ("startBedingung" )
    REFERENCES "XP_Basisobjekte"."XP_WirksamkeitBedingung" ("id" )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT "fk_XP_Objekt_XP_WirksamkeitBedingung2"
    FOREIGN KEY ("endeBedingung" )
    REFERENCES "XP_Basisobjekte"."XP_WirksamkeitBedingung" ("id" )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION);
COMMENT ON TABLE "XP_Basisobjekte"."XP_Objekt" IS 'Abstrakte Oberklasse für alle XPlanGML-Fachobjekte. Die Attribute dieser Klasse werden über den Vererbungs-Mechanismus an alle Fachobjekte weitergegeben.';
COMMENT ON COLUMN "XP_Basisobjekte"."XP_Objekt"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN "XP_Basisobjekte"."XP_Objekt"."uuid" IS 'Eindeutiger Identifier des Objektes.';
COMMENT ON COLUMN "XP_Basisobjekte"."XP_Objekt"."text" IS 'Beliebiger Text';
COMMENT ON COLUMN "XP_Basisobjekte"."XP_Objekt"."rechtsstand" IS 'Gibt an ob der Planinhalt bereits besteht, geplant ist, oder zukünftig wegfallen soll.';
COMMENT ON COLUMN "XP_Basisobjekte"."XP_Objekt"."gesetzlicheGrundlage" IS 'Angabe der Gesetzlichen Grundlage des Planinhalts.';
COMMENT ON COLUMN "XP_Basisobjekte"."XP_Objekt"."gliederung1" IS 'Kennung im Plan für eine erste Gliederungsebene (z.B. GE-E für ein "Eingeschränktes Gewerbegebiet")';
COMMENT ON COLUMN "XP_Basisobjekte"."XP_Objekt"."gliederung2" IS 'Kennung im Plan für eine zweite Gliederungsebene (z.B. GE-E 3 für die "Variante 3 eines eingeschränkten Gewerbegebiets")';
COMMENT ON COLUMN "XP_Basisobjekte"."XP_Objekt"."ebene" IS 'Zuordnung des Objektes zu einer vertikalen Ebene.
Der Standard-Ebene 0 sind Objekte auf der Erdoberfläche zugeordnet.
Nur unter diesen Objekten wird der Flächenschluss hergestellt.
Bei Plan-Objekten, die unterirdische Bereiche (z.B. Tunnel) modellieren, ist ebene < 0.
Bei "überirdischen" Objekten (z.B. Festsetzungen auf Brücken) ist ebene > 0.';
COMMENT ON COLUMN "XP_Basisobjekte"."XP_Objekt"."startBedingung" IS 'Notwendige Bedingung für die Wirksamkeit eines Planinhalts.';
COMMENT ON COLUMN "XP_Basisobjekte"."XP_Objekt"."endeBedingung" IS 'Notwendige Bedingung für das Ende der Wirksamkeit eines Planinhalts.';
COMMENT ON COLUMN "XP_Basisobjekte"."XP_Objekt"."gml_id" IS 'Eindeutiger Identifier des Objektes für Im- und Export.';
COMMENT ON COLUMN "XP_Basisobjekte"."XP_Objekt"."aufschrift" IS 'Spezifischer Text zur Beschriftung von Planinhalten';
CREATE TRIGGER "XP_Objekt_gml_id" BEFORE INSERT ON "XP_Basisobjekte"."XP_Objekt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."create_gml_id"();
CREATE TRIGGER "XP_Objekt_hasChanged" BEFORE INSERT OR UPDATE ON "XP_Basisobjekte"."XP_Objekt" FOR EACH ROW EXECUTE PROCEDURE  "XP_Basisobjekte"."change_to_XP_Objekt"();
CREATE INDEX "idx_fk_XP_Objekt_XP_Rechtsstand1" ON "XP_Basisobjekte"."XP_Objekt" ("rechtsstand") ;
CREATE INDEX "idx_fk_XP_Objekt_xp_gesetzlichegrundlage1" ON "XP_Basisobjekte"."XP_Objekt" ("gesetzlicheGrundlage") ;
CREATE INDEX "idx_XP_Objekt_uuid" ON "XP_Basisobjekte"."XP_Objekt" ("uuid");
GRANT SELECT ON TABLE "XP_Basisobjekte"."XP_Objekt" TO xp_gast;
GRANT ALL ON TABLE "XP_Basisobjekte"."XP_Objekt" TO xp_user;

-- -----------------------------------------------------
-- Table "XP_Basisobjekte"."XP_RechtscharakterPlanaenderung"
-- -----------------------------------------------------
CREATE  TABLE  "XP_Basisobjekte"."XP_RechtscharakterPlanaenderung" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Code") );
GRANT SELECT ON TABLE "XP_Basisobjekte"."XP_RechtscharakterPlanaenderung" TO xp_gast;

-- -----------------------------------------------------
-- Table "XP_Basisobjekte"."XP_VerbundenerPlan"
-- -----------------------------------------------------
CREATE  TABLE  "XP_Basisobjekte"."XP_VerbundenerPlan" (
  "planName" VARCHAR(256) NOT NULL ,
  "rechtscharakter" INTEGER NOT NULL DEFAULT 1000 ,
  "nummer" VARCHAR(64) NULL ,
  "verbundenerPlan" BIGINT NOT NULL ,
  PRIMARY KEY ("verbundenerPlan"),
  CONSTRAINT "fk_XP_VerbundenerPlan_XP_RechtscharakterPlanaenderung1"
    FOREIGN KEY ("rechtscharakter" )
    REFERENCES "XP_Basisobjekte"."XP_RechtscharakterPlanaenderung" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
COMMENT ON TABLE "XP_Basisobjekte"."XP_VerbundenerPlan" IS 'Spezifikation eines anderen Plans, der mit dem Ausgangsplan verbunden ist und diesen ändert bzw. von ihm geändert wird.';
COMMENT ON COLUMN "XP_Basisobjekte"."XP_VerbundenerPlan"."planName" IS 'Name (Attribut name von XP_Plan) des verbundenen Plans.';
COMMENT ON COLUMN "XP_Basisobjekte"."XP_VerbundenerPlan"."rechtscharakter" IS 'Rechtscharakter der Planänderung.';
COMMENT ON COLUMN "XP_Basisobjekte"."XP_VerbundenerPlan"."nummer" IS 'Nummer des verbundenen Plans.';
COMMENT ON COLUMN "XP_Basisobjekte"."XP_VerbundenerPlan"."verbundenerPlan" IS 'Referenz auf einen anderen Plan, der den aktuellen Plan ändert oder von ihm geändert wird.';
CREATE TRIGGER "XP_VerbundenerPlan_InsUpd" BEFORE INSERT OR UPDATE ON "XP_Basisobjekte"."XP_VerbundenerPlan" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."change_to_XP_VerbundenerPlan"();
GRANT SELECT ON TABLE "XP_Basisobjekte"."XP_VerbundenerPlan" TO xp_gast;
GRANT ALL ON TABLE "XP_Basisobjekte"."XP_VerbundenerPlan" TO xp_user;

-- -----------------------------------------------------
-- Table "XP_Basisobjekte"."XP_Plan_aendert"
-- -----------------------------------------------------
CREATE  TABLE  "XP_Basisobjekte"."XP_Plan_aendert" (
  "XP_Plan_gid" BIGINT NOT NULL ,
  "aendert" BIGINT NOT NULL ,
  PRIMARY KEY ("XP_Plan_gid", "aendert") ,
  CONSTRAINT "fk_XP_Plan_has_XP_VerbundenerPlan_XP_Plan1"
    FOREIGN KEY ("XP_Plan_gid" )
    REFERENCES "XP_Basisobjekte"."XP_Plan" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_XP_Plan_has_XP_VerbundenerPlan_XP_VerbundenerPlan1"
    FOREIGN KEY ("aendert" )
    REFERENCES "XP_Basisobjekte"."XP_VerbundenerPlan" ("verbundenerPlan" )
    ON DELETE CASCADE
    ON UPDATE CASCADE);
GRANT SELECT ON TABLE "XP_Basisobjekte"."XP_Plan_aendert" TO xp_gast;
GRANT ALL ON TABLE "XP_Basisobjekte"."XP_Plan_aendert" TO xp_user;
CREATE INDEX "idx_fk_aendert_XP_Plan1" ON "XP_Basisobjekte"."XP_Plan_aendert" ("XP_Plan_gid") ;
CREATE INDEX "idx_fk_aendert_XP_VerbundenerPlan1" ON "XP_Basisobjekte"."XP_Plan_aendert" ("aendert") ;
COMMENT ON TABLE  "XP_Basisobjekte"."XP_Plan_aendert" IS 'Bezeichnung eines anderen Planes, der durch den vorliegenden Plan geändert wird.';

-- -----------------------------------------------------
-- Table "XP_Basisobjekte"."XP_Plan_wurdeGeaendertVon"
-- -----------------------------------------------------
CREATE  TABLE  "XP_Basisobjekte"."XP_Plan_wurdeGeaendertVon" (
  "XP_Plan_gid" BIGINT NOT NULL ,
  "wurdeGeaendertVon" BIGINT NOT NULL ,
  PRIMARY KEY ("XP_Plan_gid", "wurdeGeaendertVon") ,
  CONSTRAINT "fk_XP_Plan_has_XP_VerbundenerPlan_XP_Plan2"
    FOREIGN KEY ("XP_Plan_gid" )
    REFERENCES "XP_Basisobjekte"."XP_Plan" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_XP_Plan_has_XP_VerbundenerPlan_XP_VerbundenerPlan2"
    FOREIGN KEY ("wurdeGeaendertVon" )
    REFERENCES "XP_Basisobjekte"."XP_VerbundenerPlan" ("verbundenerPlan" )
    ON DELETE CASCADE
    ON UPDATE CASCADE);
GRANT SELECT ON TABLE "XP_Basisobjekte"."XP_Plan_wurdeGeaendertVon" TO xp_gast;
GRANT ALL ON TABLE "XP_Basisobjekte"."XP_Plan_wurdeGeaendertVon" TO xp_user;
CREATE INDEX "idx_fk_wurdeGeaendertVon_XP_Plan1" ON "XP_Basisobjekte"."XP_Plan_wurdeGeaendertVon" ("XP_Plan_gid") ;
CREATE INDEX "idx_fk_wurdeGeaendertVon_XP_VerbundenerPlan1" ON "XP_Basisobjekte"."XP_Plan_wurdeGeaendertVon" ("wurdeGeaendertVon") ;
COMMENT ON TABLE  "XP_Basisobjekte"."XP_Plan_wurdeGeaendertVon" IS 'Bezeichnung eines anderen Plans , durch den der vorliegende Plan geändert wurde.';

-- -----------------------------------------------------
-- Table "XP_Basisobjekte"."XP_VerfahrensMerkmal"
-- -----------------------------------------------------
CREATE  TABLE  "XP_Basisobjekte"."XP_VerfahrensMerkmal" (
  "id" INTEGER NOT NULL DEFAULT nextval('"XP_Basisobjekte"."XP_VerfahrensMerkmal_id_seq"'),
  "vermerk" VARCHAR(1024) NOT NULL ,
  "datum" DATE NOT NULL ,
  "signatur" VARCHAR(255) NOT NULL ,
  "signiert" BOOLEAN  NOT NULL ,
  "XP_Plan" INTEGER NOT NULL ,
  PRIMARY KEY ("id") ,
  CONSTRAINT "fk_xp_verfahrensmerkmal_xp_plan1"
    FOREIGN KEY ("XP_Plan" )
    REFERENCES "XP_Basisobjekte"."XP_Plan" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE);
COMMENT ON TABLE "XP_Basisobjekte"."XP_VerfahrensMerkmal" IS 'Vermerke der am Planungssverfahrens beteiligten Akteure.';
COMMENT ON COLUMN "XP_Basisobjekte"."XP_VerfahrensMerkmal"."vermerk" IS 'Inhat des Vermerks';
COMMENT ON COLUMN "XP_Basisobjekte"."XP_VerfahrensMerkmal"."id" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN "XP_Basisobjekte"."XP_VerfahrensMerkmal"."datum" IS 'Datum des Vermerks';
COMMENT ON COLUMN "XP_Basisobjekte"."XP_VerfahrensMerkmal"."signatur" IS 'Unterschrift';
COMMENT ON COLUMN "XP_Basisobjekte"."XP_VerfahrensMerkmal"."signiert" IS 'Angabe, ob die Unterschrift erfolgt ist.';
COMMENT ON COLUMN "XP_Basisobjekte"."XP_VerfahrensMerkmal"."XP_Plan" IS 'Plan, auf den sich der Vermerk bezieht.';
CREATE INDEX "idx_fk_xp_verfahrensmerkmal_xp_plan1" ON "XP_Basisobjekte"."XP_VerfahrensMerkmal" ("XP_Plan") ;

GRANT SELECT ON TABLE "XP_Basisobjekte"."XP_VerfahrensMerkmal" TO xp_gast;
GRANT ALL ON TABLE "XP_Basisobjekte"."XP_VerfahrensMerkmal" TO xp_user;

-- -----------------------------------------------------
-- Table "XP_Basisobjekte"."XP_Objekt_gehoertZuBereich"
-- -----------------------------------------------------
CREATE  TABLE  "XP_Basisobjekte"."XP_Objekt_gehoertZuBereich" (
  "gehoertZuBereich" BIGINT NOT NULL ,
  "XP_Objekt_gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gehoertZuBereich", "XP_Objekt_gid") ,
  CONSTRAINT "fk_XP_Bereich_has_XP_Objekt_XP_Bereich1"
    FOREIGN KEY ("gehoertZuBereich" )
    REFERENCES "XP_Basisobjekte"."XP_Bereich" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_XP_Bereich_has_XP_Objekt_XP_Objekt1"
    FOREIGN KEY ("XP_Objekt_gid" )
    REFERENCES "XP_Basisobjekte"."XP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE);
COMMENT ON TABLE "XP_Basisobjekte"."XP_Objekt_gehoertZuBereich" IS 'Verweis auf den Bereich, zu dem der Planinhalt gehört.';
CREATE INDEX "idx_fk_XP_Bereich_has_XP_Objekt_XP_Bereich1" ON "XP_Basisobjekte"."XP_Objekt_gehoertZuBereich" ("gehoertZuBereich") ;
CREATE INDEX "idx_fk_XP_Bereich_has_XP_Objekt_XP_Objekt1" ON "XP_Basisobjekte"."XP_Objekt_gehoertZuBereich" ("XP_Objekt_gid") ;

GRANT SELECT ON TABLE "XP_Basisobjekte"."XP_Objekt_gehoertZuBereich" TO xp_gast;
GRANT ALL ON TABLE "XP_Basisobjekte"."XP_Objekt_gehoertZuBereich" TO xp_user;

-- -----------------------------------------------------
-- Table "XP_Basisobjekte"."XP_Objekt_externeReferenz"
-- -----------------------------------------------------
CREATE  TABLE  "XP_Basisobjekte"."XP_Objekt_externeReferenz" (
  "XP_Objekt_gid" BIGINT NOT NULL ,
  "externeReferenz" INTEGER NOT NULL ,
  PRIMARY KEY ("XP_Objekt_gid", "externeReferenz") ,
  CONSTRAINT "fk_XP_Objekt_externeReferenz_XP_Objekt"
    FOREIGN KEY ("XP_Objekt_gid" )
    REFERENCES "XP_Basisobjekte"."XP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_XP_Objekt_externeReferenz_XP_ExterneReferenz"
    FOREIGN KEY ("externeReferenz" )
    REFERENCES "XP_Basisobjekte"."XP_SpezExterneReferenz" ("id" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
COMMENT ON TABLE "XP_Basisobjekte"."XP_Objekt_externeReferenz" IS 'Referenz auf ein Dokument oder einen georeferenzierten Rasterplan.';
CREATE INDEX "idx_fk_XP_Objekt_externeReferenz_XP_Objekt" ON "XP_Basisobjekte"."XP_Objekt_externeReferenz" ("XP_Objekt_gid") ;
CREATE INDEX "idx_fk_XP_Objekt_externeReferenz_XP_ExterneReferenz" ON "XP_Basisobjekte"."XP_Objekt_externeReferenz" ("externeReferenz");

GRANT SELECT ON TABLE "XP_Basisobjekte"."XP_Objekt_externeReferenz" TO xp_gast;
GRANT ALL ON TABLE "XP_Basisobjekte"."XP_Objekt_externeReferenz" TO xp_user;

-- -----------------------------------------------------
-- Table "XP_Basisobjekte"."XP_Plan_externeReferenz"
-- -----------------------------------------------------
CREATE  TABLE  "XP_Basisobjekte"."XP_Plan_externeReferenz" (
  "XP_Plan_gid" BIGINT NOT NULL ,
  "externeReferenz" INTEGER NOT NULL ,
  PRIMARY KEY ("XP_Plan_gid", "externeReferenz") ,
  CONSTRAINT "fk_XP_Plan_externeReferenz_XP_Plan"
    FOREIGN KEY ("XP_Plan_gid" )
    REFERENCES "XP_Basisobjekte"."XP_Plan" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_XP_Plan_externeReferenz_XP_ExterneReferenz"
    FOREIGN KEY ("externeReferenz" )
    REFERENCES "XP_Basisobjekte"."XP_SpezExterneReferenz" ("id" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
COMMENT ON TABLE "XP_Basisobjekte"."XP_Plan_externeReferenz" IS 'Referenz auf ein Dokument oder einen georeferenzierten Rasterplan.';
CREATE INDEX "idx_fk_XP_Plan_externeReferenz_XP_Plan" ON "XP_Basisobjekte"."XP_Plan_externeReferenz" ("XP_Plan_gid") ;
CREATE INDEX "idx_fk_XP_Plan_externeReferenz_XP_ExterneReferenz" ON "XP_Basisobjekte"."XP_Plan_externeReferenz" ("externeReferenz");

GRANT SELECT ON TABLE "XP_Basisobjekte"."XP_Plan_externeReferenz" TO xp_gast;
GRANT ALL ON TABLE "XP_Basisobjekte"."XP_Plan_externeReferenz" TO xp_user;

-- -----------------------------------------------------
-- Table "XP_Basisobjekte"."XP_TextAbschnitt"
-- -----------------------------------------------------
CREATE  TABLE  "XP_Basisobjekte"."XP_TextAbschnitt" (
  "id" INTEGER NOT NULL DEFAULT nextval('"XP_Basisobjekte"."XP_TextAbschnitt_id_seq"'),
  "schluessel" VARCHAR(255) NULL ,
  "gesetzlicheGrundlage" VARCHAR(255) NULL ,
  "text" text NULL,
  "refText" INTEGER NULL ,
  "gml_id" VARCHAR(64) NULL ,
  PRIMARY KEY ("id") ,
  CONSTRAINT "fk_XP_TextAbschnitt_XP_ExterneReferenz1"
    FOREIGN KEY ("refText" )
    REFERENCES "XP_Basisobjekte"."XP_ExterneReferenz" ("id" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
COMMENT ON TABLE "XP_Basisobjekte"."XP_TextAbschnitt" IS 'Ein Abschnitt der textlich formulierten Inhalte des Plans.';
COMMENT ON COLUMN "XP_Basisobjekte"."XP_TextAbschnitt"."id" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN "XP_Basisobjekte"."XP_TextAbschnitt"."schluessel" IS 'Schlüssel zur Referenzierung des Abschnitts.';
COMMENT ON COLUMN "XP_Basisobjekte"."XP_TextAbschnitt"."gesetzlicheGrundlage" IS 'Gesetzliche Grundlage des Text-Abschnittes';
COMMENT ON COLUMN "XP_Basisobjekte"."XP_TextAbschnitt"."text" IS 'Inhalt eines Abschnitts der textlichen Planinhalte';
COMMENT ON COLUMN "XP_Basisobjekte"."XP_TextAbschnitt"."refText" IS 'Referenz auf ein externes Dokument das den Textabschnitt enthält.';
CREATE INDEX "idx_fk_XP_TextAbschnitt_XP_ExterneReferenz1" ON "XP_Basisobjekte"."XP_TextAbschnitt" ("refText") ;
COMMENT ON COLUMN "XP_Basisobjekte"."XP_TextAbschnitt"."gml_id" IS 'Eindeutiger Identifier des Objektes für Im- und Export.';
CREATE TRIGGER "XP_TextAbschnitt_gml_id" BEFORE INSERT ON "XP_Basisobjekte"."XP_TextAbschnitt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."create_gml_id"();
CREATE TRIGGER "change_to_XP_TextAbschnitt" BEFORE INSERT OR UPDATE ON "XP_Basisobjekte"."XP_TextAbschnitt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."XP_Abschnitt_Konformitaet"();

GRANT SELECT ON TABLE "XP_Basisobjekte"."XP_TextAbschnitt" TO xp_gast;
GRANT ALL ON TABLE "XP_Basisobjekte"."XP_TextAbschnitt" TO xp_user;

-- -----------------------------------------------------
-- Table "XP_Basisobjekte"."XP_BegruendungAbschnitt"
-- -----------------------------------------------------
CREATE  TABLE  "XP_Basisobjekte"."XP_BegruendungAbschnitt" (
  "id" INTEGER NOT NULL DEFAULT nextval('"XP_Basisobjekte"."XP_BegruendungAbschnitt_id_seq"'),
  "schluessel" VARCHAR(255) NULL ,
  "text" VARCHAR(255) NULL ,
  "refText" INTEGER NULL ,
  PRIMARY KEY ("id") ,
  CONSTRAINT "fk_XP_BegruendungAbschnitt_XP_ExterneReferenz1"
    FOREIGN KEY ("refText" )
    REFERENCES "XP_Basisobjekte"."XP_ExterneReferenz" ("id" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
COMMENT ON TABLE "XP_Basisobjekte"."XP_BegruendungAbschnitt" IS 'Ein Abschnitt der Begründung des Plans.';
COMMENT ON COLUMN "XP_Basisobjekte"."XP_BegruendungAbschnitt"."schluessel" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN "XP_Basisobjekte"."XP_BegruendungAbschnitt"."schluessel" IS 'Schlüssel zur Referenzierung des Abschnitts von einem Fachobjekt aus.';
COMMENT ON COLUMN "XP_Basisobjekte"."XP_BegruendungAbschnitt"."text" IS 'Inhalt eines Abschnitts der Begründung.';
COMMENT ON COLUMN "XP_Basisobjekte"."XP_BegruendungAbschnitt"."refText" IS 'Referenz auf ein externes Dokument das den Begründungs-Abschnitt enthält.';
CREATE INDEX "idx_fk_XP_BegruendungAbschnitt_XP_ExterneReferenz1" ON "XP_Basisobjekte"."XP_BegruendungAbschnitt" ("refText") ;
CREATE TRIGGER "change_to_XP_BegruendungAbschnitt" BEFORE INSERT OR UPDATE ON "XP_Basisobjekte"."XP_BegruendungAbschnitt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."XP_Abschnitt_Konformitaet"();

GRANT SELECT ON TABLE "XP_Basisobjekte"."XP_BegruendungAbschnitt" TO xp_gast;
GRANT ALL ON TABLE "XP_Basisobjekte"."XP_BegruendungAbschnitt" TO xp_user;

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

-- -----------------------------------------------------
-- Table "XP_Basisobjekte"."XP_Plan_begruendungsTexte"
-- -----------------------------------------------------
CREATE  TABLE  "XP_Basisobjekte"."XP_Plan_begruendungsTexte" (
  "XP_Plan_gid" BIGINT NOT NULL ,
  "begruendungsTexte" INTEGER NOT NULL ,
  PRIMARY KEY ("XP_Plan_gid", "begruendungsTexte") ,
  CONSTRAINT "fk_XP_Plan_has_XP_BegruendungAbschnitt_XP_Plan1"
    FOREIGN KEY ("XP_Plan_gid" )
    REFERENCES "XP_Basisobjekte"."XP_Plan" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_XP_Plan_has_XP_BegruendungAbschnitt_XP_BegruendungAbschnitt1"
    FOREIGN KEY ("begruendungsTexte" )
    REFERENCES "XP_Basisobjekte"."XP_BegruendungAbschnitt" ("id" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
COMMENT ON TABLE "XP_Basisobjekte"."XP_Plan_begruendungsTexte" IS 'Referenz auf einen Abschnitt der Begründung. Diese Relation darf nicht verwendet werden, wenn die Begründung als Gesamt-Dokument referiert werden soll. In diesem Fall sollte über das Attribut externeReferenz eine Objekt XP_SpezExterneReferent mit typ=1010 (Begruendung) verwendet werden.';
CREATE INDEX "idx_fk_begruendungsTexte_XP_Plan1" ON "XP_Basisobjekte"."XP_Plan_begruendungsTexte" ("XP_Plan_gid") ;
CREATE INDEX "idx_fk_begruendungsTexte_XP_BegruendungAbschnitt1" ON "XP_Basisobjekte"."XP_Plan_begruendungsTexte" ("begruendungsTexte") ;

GRANT SELECT ON TABLE "XP_Basisobjekte"."XP_Plan_begruendungsTexte" TO xp_gast;
GRANT ALL ON TABLE "XP_Basisobjekte"."XP_Plan_begruendungsTexte" TO xp_user;

-- -----------------------------------------------------
-- Table "XP_Basisobjekte"."XP_Plan_texte"
-- -----------------------------------------------------
CREATE  TABLE  "XP_Basisobjekte"."XP_Plan_texte" (
  "XP_Plan_gid" BIGINT NOT NULL ,
  "texte" INTEGER NOT NULL ,
  PRIMARY KEY ("XP_Plan_gid", "texte") ,
  CONSTRAINT "fk_XP_Plan_has_XP_TextAbschnitt_XP_Plan1"
    FOREIGN KEY ("XP_Plan_gid" )
    REFERENCES "XP_Basisobjekte"."XP_Plan" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_XP_Plan_has_XP_TextAbschnitt_XP_TextAbschnitt1"
    FOREIGN KEY ("texte" )
    REFERENCES "XP_Basisobjekte"."XP_TextAbschnitt" ("id" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
COMMENT ON TABLE "XP_Basisobjekte"."XP_Plan_texte" IS 'Verweis auf einen textuell formulierten Planinhalt';
CREATE INDEX "idx_fk_XP_Plan_has_XP_TextAbschnitt_XP_Plan1" ON "XP_Basisobjekte"."XP_Plan_texte" ("XP_Plan_gid") ;
CREATE INDEX "idx_fk_XP_Plan_has_XP_TextAbschnitt_XP_TextAbschnitt1" ON "XP_Basisobjekte"."XP_Plan_texte" ("texte") ;

GRANT SELECT ON TABLE "XP_Basisobjekte"."XP_Plan_texte" TO xp_gast;
GRANT ALL ON TABLE "XP_Basisobjekte"."XP_Plan_texte" TO xp_user;

-- -----------------------------------------------------
-- Table "XP_Praesentationsobjekte"."XP_StylesheetListe"
-- -----------------------------------------------------
CREATE  TABLE  "XP_Praesentationsobjekte"."XP_StylesheetListe" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(256) NOT NULL ,
  PRIMARY KEY ("Code") );

GRANT SELECT ON TABLE "XP_Praesentationsobjekte"."XP_StylesheetListe" TO xp_gast;
GRANT ALL ON TABLE "XP_Praesentationsobjekte"."XP_StylesheetListe" TO xp_user;
CREATE TRIGGER "ins_upd_XP_StylesheetListe" BEFORE INSERT OR UPDATE ON "XP_Praesentationsobjekte"."XP_StylesheetListe" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isCodeList"();

-- -----------------------------------------------------
-- Table "XP_Praesentationsobjekte"."XP_APO"
-- -----------------------------------------------------
CREATE  TABLE  "XP_Praesentationsobjekte"."XP_APO" (
  "gid" BIGINT NOT NULL ,
  PRIMARY KEY ("gid") );
GRANT SELECT ON TABLE "XP_Praesentationsobjekte"."XP_APO" TO xp_gast;

-- -----------------------------------------------------
-- Table "XP_Praesentationsobjekte"."XP_AbstraktesPraesentationsobjekt"
-- -----------------------------------------------------
CREATE  TABLE  "XP_Praesentationsobjekte"."XP_AbstraktesPraesentationsobjekt" (
  "gid" BIGINT NOT NULL DEFAULT nextval('"XP_Praesentationsobjekte"."XP_APObjekt_gid_seq"'),
  "stylesheetId" INTEGER NULL ,
  "darstellungsprioritaet" INTEGER NULL ,
  "gehoertZuBereich" INTEGER NULL ,
  "gml_id" VARCHAR(64) NULL,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_xp_abstraktespraesentationsobjekt_XP_Bereich1"
    FOREIGN KEY ("gehoertZuBereich" )
    REFERENCES "XP_Basisobjekte"."XP_Bereich" ("gid" )
    ON DELETE SET NULL
    ON UPDATE CASCADE,
  CONSTRAINT "fk_XP_AbstraktesPraesentationsobjekt_xp_stylesheetliste1"
    FOREIGN KEY ("stylesheetId" )
    REFERENCES "XP_Praesentationsobjekte"."XP_StylesheetListe" ("Code" )
    ON DELETE SET NULL
    ON UPDATE CASCADE);
COMMENT ON TABLE "XP_Praesentationsobjekte"."XP_AbstraktesPraesentationsobjekt" IS 'Abstrakte Basisklasse für alle Präsentationsobjekte.
Bei freien Präsentationsobjekten ist die Relation "dientZurDarstellungVon" unbelegt, bei gebundenen Präsentationsobjekten zeigt die Relation auf ein von XP_Objekt abgeleitetes Fachobjekt.
Freie Präsentationsobjekte dürfen ausschließlich zur graphischen Annotation eines Plans verwendet werden.
Gebundene Präsentationsobjekte mit Raumbezug dienen ausschließlich dazu, Attributwerte des verbundenen Fachobjekts im Plan darzustellen.
Die Namen der darzustellenden Fachobjekt-Attribute werden über das Attribut "art" spezifiziert.';
COMMENT ON COLUMN "XP_Praesentationsobjekte"."XP_AbstraktesPraesentationsobjekt"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN "XP_Praesentationsobjekte"."XP_AbstraktesPraesentationsobjekt"."stylesheetId" IS 'Zeigt auf ein extern definierte Stylesheet, das Parameter zur Visualisierung von Flächen, Linien, Punkten und Texten enthält.
Jedem Stylesheet ist weiterhin eine Darstellungspriorität zugeordnet.
Ausserdem kann ein Stylesheet logische Elemente enthalten, die die Visualisierung abhängig machen vom Wert des durch "art" definierten Attributes des Fachobjektes, das durch die Relation "dientZurDarstellungVon" referiert wird.';
COMMENT ON COLUMN "XP_Praesentationsobjekte"."XP_AbstraktesPraesentationsobjekt"."darstellungsprioritaet" IS 'Enthält die Darstellungspriorität für Elemente der Signatur. Eine vom Standardwert abweichende Priorität wird über dieses Attribut definiert und nicht über eine neue Signatur.';
COMMENT ON COLUMN "XP_Praesentationsobjekte"."XP_AbstraktesPraesentationsobjekt"."gehoertZuBereich" IS 'Relation zu XP_Bereich';
COMMENT ON COLUMN "XP_Praesentationsobjekte"."XP_AbstraktesPraesentationsobjekt"."gml_id" IS 'Eindeutiger Identifier des Objektes für Im- und Export.';
CREATE INDEX "idx_fk_xp_abstraktespraesentationsobjekt_XP_Bereich1" ON "XP_Praesentationsobjekte"."XP_AbstraktesPraesentationsobjekt" ("gehoertZuBereich") ;
CREATE INDEX "idx_fk_XP_AbstraktesPraesentationsobjekt_xp_stylesheetliste1" ON "XP_Praesentationsobjekte"."XP_AbstraktesPraesentationsobjekt" ("stylesheetId") ;
GRANT SELECT ON TABLE "XP_Praesentationsobjekte"."XP_AbstraktesPraesentationsobjekt" TO xp_gast;
GRANT ALL ON TABLE "XP_Praesentationsobjekte"."XP_AbstraktesPraesentationsobjekt" TO xp_user;
CREATE TRIGGER "XP_AbstraktesPraesentationsobjekt_gml_id" BEFORE INSERT ON "XP_Praesentationsobjekte"."XP_AbstraktesPraesentationsobjekt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."create_gml_id"();

-- -----------------------------------------------------
-- Table "XP_Praesentationsobjekte"."XP_APObjekt_dientZurDarstellungVon"
-- -----------------------------------------------------
CREATE  TABLE  "XP_Praesentationsobjekte"."XP_APObjekt_dientZurDarstellungVon" (
  "XP_APObjekt_gid" BIGINT NOT NULL ,
  "dientZurDarstellungVon" BIGINT NOT NULL ,
  "art" VARCHAR(64)[] NOT NULL DEFAULT '{"text"}',
  "index" INTEGER[],
  PRIMARY KEY ("XP_APObjekt_gid", "dientZurDarstellungVon") ,
  CONSTRAINT "fk_dientzurdarstellungvon_XP_APOt1"
    FOREIGN KEY ("XP_APObjekt_gid" )
    REFERENCES "XP_Praesentationsobjekte"."XP_AbstraktesPraesentationsobjekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_dientzurdarstellungvon_XP_Objekt1"
    FOREIGN KEY ("dientZurDarstellungVon" )
    REFERENCES "XP_Basisobjekte"."XP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE);

COMMENT ON TABLE "XP_Praesentationsobjekte"."XP_APObjekt_dientZurDarstellungVon" IS 'Relation zu XP_Objekt';
COMMENT ON COLUMN "XP_Praesentationsobjekte"."XP_APObjekt_dientZurDarstellungVon"."dientZurDarstellungVon" IS 'Verweis auf das Fachobjekt';
COMMENT ON COLUMN "XP_Praesentationsobjekte"."XP_APObjekt_dientZurDarstellungVon"."XP_APObjekt_gid" IS 'Verweis auf das Präsentationsobjekt';
COMMENT ON COLUMN "XP_Praesentationsobjekte"."XP_APObjekt_dientZurDarstellungVon"."art" IS '"Art" gibt den Namen des Attributs an, das mit dem Präsentationsobjekt dargestellt werden soll.
Die Attributart "Art" darf im Regelfall nur bei "Freien Präsentationsobjekten" (dientZurDarstellungVon = NULL) nicht belegt sein.';
COMMENT ON COLUMN "XP_Praesentationsobjekte"."XP_APObjekt_dientZurDarstellungVon"."index" IS 'Wenn das Attribut art des Fachobjektes mehrfach belegt ist gibt index an, auf welche Instanz des Attributs sich das Präsentationsobjekt bezieht. Indexnummern beginnen dabei immer mit 0.';
CREATE INDEX "idx_fk_dientzurdarstellungvon_XP_APO1" ON "XP_Praesentationsobjekte"."XP_APObjekt_dientZurDarstellungVon" ("XP_APObjekt_gid") ;
CREATE INDEX "idx_fk_dientzurdarstellungvon_XP_Objekt1" ON "XP_Praesentationsobjekte"."XP_APObjekt_dientZurDarstellungVon" ("dientZurDarstellungVon") ;
GRANT SELECT ON TABLE "XP_Praesentationsobjekte"."XP_APObjekt_dientZurDarstellungVon" TO xp_gast;
GRANT ALL ON TABLE "XP_Praesentationsobjekte"."XP_APObjekt_dientZurDarstellungVon" TO xp_user;

-- -----------------------------------------------------
-- Table "XP_Praesentationsobjekte"."XP_LPO"
-- -----------------------------------------------------
CREATE  TABLE  "XP_Praesentationsobjekte"."XP_LPO" (
  "gid" BIGINT NOT NULL ,
  "position" GEOMETRY(MultiLinestring,25832) NOT NULL ,
  PRIMARY KEY ("gid"),
  CONSTRAINT "fk_XP_LPO_XP_APO1"
    FOREIGN KEY ("gid" )
    REFERENCES "XP_Praesentationsobjekte"."XP_AbstraktesPraesentationsobjekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("XP_Praesentationsobjekte"."XP_APO");
COMMENT ON TABLE "XP_Praesentationsobjekte"."XP_LPO" IS 'Linienförmiges Präsentationsobjekt.';
COMMENT ON COLUMN "XP_Praesentationsobjekte"."XP_LPO"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_XP_LPO" BEFORE INSERT OR UPDATE ON "XP_Praesentationsobjekte"."XP_LPO" FOR EACH ROW EXECUTE PROCEDURE "XP_Praesentationsobjekte"."child_of_XP_APObjekt"();
CREATE TRIGGER "delete_XP_LPO" AFTER DELETE ON "XP_Praesentationsobjekte"."XP_LPO" FOR EACH ROW EXECUTE PROCEDURE "XP_Praesentationsobjekte"."child_of_XP_APObjekt"();
GRANT SELECT ON TABLE "XP_Praesentationsobjekte"."XP_LPO" TO xp_gast;
GRANT ALL ON TABLE "XP_Praesentationsobjekte"."XP_LPO" TO xp_user;

-- -----------------------------------------------------
-- Table "XP_Praesentationsobjekte"."XP_PPO"
-- -----------------------------------------------------
CREATE  TABLE  "XP_Praesentationsobjekte"."XP_PPO" (
  "gid" BIGINT NOT NULL ,
  "position" GEOMETRY(Multipoint,25832) NOT NULL ,
  "drehwinkel" INTEGER NULL DEFAULT 0 ,
  "skalierung" REAL NULL DEFAULT 1 ,
  "hat" INTEGER NULL,
  PRIMARY KEY ("gid"),
  CONSTRAINT "fk_XP_PPO_XP_APO1"
    FOREIGN KEY ("gid" )
    REFERENCES "XP_Praesentationsobjekte"."XP_AbstraktesPraesentationsobjekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_XP_PPO_XP_LPO1"
    FOREIGN KEY ("hat" )
    REFERENCES "XP_Praesentationsobjekte"."XP_LPO" ("gid" )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
INHERITS("XP_Praesentationsobjekte"."XP_APO");
COMMENT ON TABLE "XP_Praesentationsobjekte"."XP_PPO" IS 'Punktförmiges Präsentationsobjekt.';
COMMENT ON COLUMN "XP_Praesentationsobjekte"."XP_PPO"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN "XP_Praesentationsobjekte"."XP_PPO"."drehwinkel" IS 'Winkel um den der Text oder die Signatur mit punktförmiger Bezugsgeometrie aus der Horizontalen gedreht ist. Angabe im Bogenmaß; Zählweise im mathematisch positiven Sinn (von Ost über Nord nach West und Süd).';
COMMENT ON COLUMN "XP_Praesentationsobjekte"."XP_PPO"."skalierung" IS 'Skalierungsfaktor für Symbole.';
COMMENT ON COLUMN "XP_Praesentationsobjekte"."XP_PPO"."hat" IS 'Die Relation ermöglicht es, einem punktförmigen Präsentationsobjekt ein linienförmiges Präsentationsobjekt zuzuweisen. Einziger bekannter Anwendungsfall ist der Zuordnungspfeil eines Symbols oder einer Nutzungsschablone.';
CREATE INDEX "idx_fk_XP_PPO_XP_LPO1" ON "XP_Praesentationsobjekte"."XP_PPO" ("hat") ;
CREATE TRIGGER "change_to_XP_PPO" BEFORE INSERT OR UPDATE ON "XP_Praesentationsobjekte"."XP_PPO" FOR EACH ROW EXECUTE PROCEDURE "XP_Praesentationsobjekte"."child_of_XP_APObjekt"();
CREATE TRIGGER "delete_XP_PPO" AFTER DELETE ON "XP_Praesentationsobjekte"."XP_PPO" FOR EACH ROW EXECUTE PROCEDURE "XP_Praesentationsobjekte"."child_of_XP_APObjekt"();
GRANT SELECT ON TABLE "XP_Praesentationsobjekte"."XP_PPO" TO xp_gast;
GRANT ALL ON TABLE "XP_Praesentationsobjekte"."XP_PPO" TO xp_user;

-- -----------------------------------------------------
-- Table "XP_Praesentationsobjekte"."XP_FPO"
-- -----------------------------------------------------
CREATE  TABLE  "XP_Praesentationsobjekte"."XP_FPO" (
  "gid" BIGINT NOT NULL ,
  "position" GEOMETRY(Multipolygon,25832) NOT NULL ,
  PRIMARY KEY ("gid"),
  CONSTRAINT "fk_XP_FPO_XP_APO1"
    FOREIGN KEY ("gid" )
    REFERENCES "XP_Praesentationsobjekte"."XP_AbstraktesPraesentationsobjekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("XP_Praesentationsobjekte"."XP_APO");
COMMENT ON TABLE "XP_Praesentationsobjekte"."XP_FPO" IS 'Flächenförmiges Präsentationsobjekt.';
COMMENT ON COLUMN "XP_Praesentationsobjekte"."XP_FPO"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_XP_FPO" BEFORE INSERT OR UPDATE ON "XP_Praesentationsobjekte"."XP_FPO" FOR EACH ROW EXECUTE PROCEDURE "XP_Praesentationsobjekte"."child_of_XP_APObjekt"();
CREATE TRIGGER "delete_XP_FPO" AFTER DELETE ON "XP_Praesentationsobjekte"."XP_FPO" FOR EACH ROW EXECUTE PROCEDURE "XP_Praesentationsobjekte"."child_of_XP_APObjekt"();
CREATE TRIGGER "XP_FPO_RHR" BEFORE INSERT OR UPDATE ON "XP_Praesentationsobjekte"."XP_FPO" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."positionFollowsRHR"();
GRANT SELECT ON TABLE "XP_Praesentationsobjekte"."XP_FPO" TO xp_gast;
GRANT ALL ON TABLE "XP_Praesentationsobjekte"."XP_FPO" TO xp_user;

-- -----------------------------------------------------
-- Table "XP_Praesentationsobjekte"."XP_VertikaleAusrichtung"
-- -----------------------------------------------------
CREATE  TABLE  "XP_Praesentationsobjekte"."XP_VertikaleAusrichtung" (
  "Code" VARCHAR(64) NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Code") );

GRANT SELECT ON TABLE "XP_Praesentationsobjekte"."XP_VertikaleAusrichtung" TO xp_gast;

-- -----------------------------------------------------
-- Table "XP_Praesentationsobjekte"."XP_HorizontaleAusrichtung"
-- -----------------------------------------------------
CREATE  TABLE  "XP_Praesentationsobjekte"."XP_HorizontaleAusrichtung" (
  "Code" VARCHAR(64) NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Code") );

GRANT SELECT ON TABLE "XP_Praesentationsobjekte"."XP_HorizontaleAusrichtung" TO xp_gast;

-- -----------------------------------------------------
-- Table "XP_Praesentationsobjekte"."XP_TPO"
-- -----------------------------------------------------
CREATE  TABLE  "XP_Praesentationsobjekte"."XP_TPO" (
  "gid" BIGINT NOT NULL ,
  "schriftinhalt" VARCHAR(1024) NULL ,
  "fontSperrung" REAL NULL DEFAULT 0,
  "skalierung" REAL NULL DEFAULT 1,
  "horizontaleAusrichtung" VARCHAR(64) NULL DEFAULT 'linksbündig',
  "vertikaleAusrichtung" VARCHAR(64) NULL DEFAULT 'Basis',
  "hat" INTEGER NULL,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_XP_TPO_XP_VertikaleAusrichtung1"
    FOREIGN KEY ("vertikaleAusrichtung" )
    REFERENCES "XP_Praesentationsobjekte"."XP_VertikaleAusrichtung" ("Code" )
    ON DELETE SET NULL
    ON UPDATE RESTRICT,
  CONSTRAINT "fk_XP_TPO_XP_HorizontaleAusrichtung1"
    FOREIGN KEY ("horizontaleAusrichtung" )
    REFERENCES "XP_Praesentationsobjekte"."XP_HorizontaleAusrichtung" ("Code" )
    ON DELETE SET NULL
    ON UPDATE RESTRICT,
  CONSTRAINT "fk_XP_TPO_XP_APO1"
    FOREIGN KEY ("gid" )
    REFERENCES "XP_Praesentationsobjekte"."XP_AbstraktesPraesentationsobjekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_XP_TPO_XP_LPO1"
    FOREIGN KEY ("hat" )
    REFERENCES "XP_Praesentationsobjekte"."XP_LPO" ("gid" )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION);
COMMENT ON TABLE "XP_Praesentationsobjekte"."XP_TPO" IS 'Abstrakte Oberklasse für textliche Präsentationsobjekte.';
COMMENT ON COLUMN "XP_Praesentationsobjekte"."XP_TPO"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN "XP_Praesentationsobjekte"."XP_TPO"."schriftinhalt" IS 'Schriftinhalt; enthält die darzustellenden Zeichen';
COMMENT ON COLUMN "XP_Praesentationsobjekte"."XP_TPO"."fontSperrung" IS 'Die Zeichensperrung steuert den zusätzlichen Raum, der zwischen 2 aufeinanderfolgende Zeichenkörper geschoben wird.
Er ist ein Faktor, der mit der angegebenen Zeichenhöhe mulitpliziert wird, um den einzufügenden Zusatzabstand zu erhalten.
Mit der Abhängigkeit von der Zeichenhöhe wird erreicht, dass das Schriftbild unabhängig von der Zeichenhöhe gleich wirkt.';
COMMENT ON COLUMN "XP_Praesentationsobjekte"."XP_TPO"."skalierung" IS 'Skalierungsfaktor für die Schriftgröße (fontGroesse * skalierung).';
COMMENT ON COLUMN "XP_Praesentationsobjekte"."XP_TPO"."horizontaleAusrichtung" IS 'Gibt die Ausrichtung des Textes bezüglich der Textgeometrie an.
linksbündig : Der Text beginnt an der Punktgeometrie bzw. am Anfangspunkt der Liniengeometrie.
rechtsbündig: Der Text endet an der Punktgeometrie bzw. am Endpunkt der Liniengeometrie
zentrisch: Der Text erstreckt sich von der Punktgeometrie gleich weit nach links und rechts bzw. steht auf der Mitte der Standlinie.';
COMMENT ON COLUMN "XP_Praesentationsobjekte"."XP_TPO"."vertikaleAusrichtung" IS 'Die vertikale Ausrichtung eines Textes gibt an, ob die Bezugsgeometrie die Basis (Grundlinie) des Textes, die Mitte oder obere Buchstabenbegrenzung betrifft.';
COMMENT ON COLUMN "XP_Praesentationsobjekte"."XP_TPO"."hat" IS 'Die Relation ermöglicht es, einem textlichen Präsentationsobjekt ein linienförmiges Präsentationsobjekt zuzuweisen. Einziger bekannter Anwendungsfall ist der Zuordnungspfeil eines Symbols oder einer Nutzungsschablone.';
CREATE INDEX "idx_fk_XP_TPO_XP_VertikaleAusrichtung1" ON "XP_Praesentationsobjekte"."XP_TPO" ("vertikaleAusrichtung") ;
CREATE INDEX "idx_fk_XP_TPO_XP_HorizontaleAusrichtung1" ON "XP_Praesentationsobjekte"."XP_TPO" ("horizontaleAusrichtung") ;
CREATE INDEX "idx_fk_XP_TPO_XP_LPO1" ON "XP_Praesentationsobjekte"."XP_TPO" ("hat") ;
CREATE TRIGGER "change_to_XP_TPO" BEFORE INSERT OR UPDATE ON "XP_Praesentationsobjekte"."XP_TPO" FOR EACH ROW EXECUTE PROCEDURE "XP_Praesentationsobjekte"."child_of_XP_APObjekt"();
CREATE TRIGGER "delete_XP_TPO" AFTER DELETE ON "XP_Praesentationsobjekte"."XP_TPO" FOR EACH ROW EXECUTE PROCEDURE "XP_Praesentationsobjekte"."child_of_XP_APObjekt"();
GRANT SELECT ON TABLE "XP_Praesentationsobjekte"."XP_TPO" TO xp_gast;
GRANT ALL ON TABLE "XP_Praesentationsobjekte"."XP_TPO" TO xp_user;

-- -----------------------------------------------------
-- Table "XP_Praesentationsobjekte"."XP_PTO"
-- -----------------------------------------------------
CREATE  TABLE  "XP_Praesentationsobjekte"."XP_PTO" (
  "gid" BIGINT NOT NULL ,
  "position" GEOMETRY(Multipoint,25832) NOT NULL ,
  "drehwinkel" INTEGER NULL DEFAULT 0,
  PRIMARY KEY ("gid"),
  CONSTRAINT "fk_XP_PTO_XP_TPO1"
    FOREIGN KEY ("gid" )
    REFERENCES "XP_Praesentationsobjekte"."XP_TPO" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("XP_Praesentationsobjekte"."XP_APO");
COMMENT ON TABLE "XP_Praesentationsobjekte"."XP_PTO" IS 'Textförmiges Präsentationsobjekt mit punktförmiger Festlegung der Textposition.';
COMMENT ON COLUMN "XP_Praesentationsobjekte"."XP_PTO"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN "XP_Praesentationsobjekte"."XP_PTO"."drehwinkel" IS 'Winkel um den der Text oder die Signatur mit punktförmiger Bezugsgeometrie aus der Horizontalen gedreht ist.
Angabe im Bogenmaß; Zählweise im mathematisch positiven Sinn (von Ost über Nord nach West und Süd).';
CREATE TRIGGER "change_to_XP_PTO" BEFORE INSERT OR UPDATE ON "XP_Praesentationsobjekte"."XP_PTO" FOR EACH ROW EXECUTE PROCEDURE "XP_Praesentationsobjekte"."child_of_XP_TPO"();
CREATE TRIGGER "delete_XP_PTO" AFTER DELETE ON "XP_Praesentationsobjekte"."XP_PTO" FOR EACH ROW EXECUTE PROCEDURE "XP_Praesentationsobjekte"."child_of_XP_TPO"();
GRANT SELECT ON TABLE "XP_Praesentationsobjekte"."XP_PTO" TO xp_gast;
GRANT ALL ON TABLE "XP_Praesentationsobjekte"."XP_PTO" TO xp_user;

-- -----------------------------------------------------
-- Table "XP_Praesentationsobjekte"."XP_Nutzungsschablone"
-- wird hier als Kind von XP_TPO definiert, und nicht als Kind von XP_PTO
-- da die Geometrie nicht in einer Elterntabelle liegen kann
-- -----------------------------------------------------
CREATE  TABLE  "XP_Praesentationsobjekte"."XP_Nutzungsschablone" (
  "gid" BIGINT NOT NULL ,
  "position" GEOMETRY(Multipoint,25832) NOT NULL ,
  "drehwinkel" INTEGER NULL DEFAULT 0,
  "spaltenAnz" INTEGER NOT NULL ,
  "zeilenAnz" INTEGER NULL,
  PRIMARY KEY ("gid"),
  CONSTRAINT "fk_XP_Nutzungsschablone_XP_TPO1"
    FOREIGN KEY ("gid" )
    REFERENCES "XP_Praesentationsobjekte"."XP_TPO" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("XP_Praesentationsobjekte"."XP_APO");

COMMENT ON TABLE "XP_Praesentationsobjekte"."XP_Nutzungsschablone" IS 'Modelliert eine Nutzungsschablone. Die darzustellenden Attributwerte werden zeilenweise in die Nutzungsschablone geschrieben.';
COMMENT ON COLUMN "XP_Praesentationsobjekte"."XP_Nutzungsschablone"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN "XP_Praesentationsobjekte"."XP_Nutzungsschablone"."drehwinkel" IS 'Winkel um den der Text oder die Signatur mit punktförmiger Bezugsgeometrie aus der Horizontalen gedreht ist.
Angabe im Bogenmaß; Zählweise im mathematisch positiven Sinn (von Ost über Nord nach West und Süd).';
COMMENT ON COLUMN "XP_Praesentationsobjekte"."XP_Nutzungsschablone"."spaltenAnz" IS 'Anzahl der Spalten in der Nutzungsschablone';
COMMENT ON COLUMN "XP_Praesentationsobjekte"."XP_Nutzungsschablone"."zeilenAnz" IS 'Anzahl der Zeilen in der Nutzungsschablone';
CREATE TRIGGER "change_to_XP_Nutzungsschablone" BEFORE INSERT OR UPDATE ON "XP_Praesentationsobjekte"."XP_Nutzungsschablone" FOR EACH ROW EXECUTE PROCEDURE "XP_Praesentationsobjekte"."child_of_XP_TPO"();
CREATE TRIGGER "delete_XP_Nutzungsschablone" AFTER DELETE ON "XP_Praesentationsobjekte"."XP_Nutzungsschablone" FOR EACH ROW EXECUTE PROCEDURE "XP_Praesentationsobjekte"."child_of_XP_TPO"();
GRANT SELECT ON TABLE "XP_Praesentationsobjekte"."XP_Nutzungsschablone" TO xp_gast;
GRANT ALL ON TABLE "XP_Praesentationsobjekte"."XP_Nutzungsschablone" TO xp_user;

-- -----------------------------------------------------
-- Table "XP_Praesentationsobjekte"."XP_LTO"
-- -----------------------------------------------------
CREATE  TABLE  "XP_Praesentationsobjekte"."XP_LTO" (
  "gid" BIGINT NOT NULL ,
  "position" GEOMETRY(MultiLinestring,25832) NOT NULL ,
  PRIMARY KEY ("gid"),
  CONSTRAINT "fk_XP_LTO_XP_TPO1"
    FOREIGN KEY ("gid" )
    REFERENCES "XP_Praesentationsobjekte"."XP_TPO" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
    INHERITS("XP_Praesentationsobjekte"."XP_APO");
COMMENT ON TABLE "XP_Praesentationsobjekte"."XP_LTO" IS 'Textförmiges Präsentationsobjekt mit linienförmiger Textgeometrie.';
COMMENT ON COLUMN "XP_Praesentationsobjekte"."XP_LTO"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_XP_LTO" BEFORE INSERT OR UPDATE ON "XP_Praesentationsobjekte"."XP_LTO" FOR EACH ROW EXECUTE PROCEDURE "XP_Praesentationsobjekte"."child_of_XP_TPO"();
CREATE TRIGGER "delete_XP_LTO" AFTER DELETE ON "XP_Praesentationsobjekte"."XP_LTO" FOR EACH ROW EXECUTE PROCEDURE "XP_Praesentationsobjekte"."child_of_XP_TPO"();
GRANT SELECT ON TABLE "XP_Praesentationsobjekte"."XP_LTO" TO xp_gast;
GRANT ALL ON TABLE "XP_Praesentationsobjekte"."XP_LTO" TO xp_user;

-- -----------------------------------------------------
-- Table "XP_Sonstiges"."XP_Gemeinde"
-- -----------------------------------------------------
CREATE  TABLE  "XP_Sonstiges"."XP_Gemeinde" (
  "id" INTEGER NOT NULL DEFAULT nextval('"XP_Sonstiges"."XP_Gemeinde_id_seq"'),
  "ags" VARCHAR(16) NULL ,
  "rs" VARCHAR(16) NULL ,
  "gemeindeName" VARCHAR(255) NULL ,
  "ortsteilName" VARCHAR(255) NULL ,
  PRIMARY KEY ("id") );
COMMENT ON TABLE "XP_Sonstiges"."XP_Gemeinde" IS 'Spezifikation einer Gemeinde';
COMMENT ON COLUMN "XP_Sonstiges"."XP_Gemeinde"."id" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN "XP_Sonstiges"."XP_Gemeinde"."ags" IS 'Amtlicher Gemeindsschlüssel (früher Gemeinde-Kennziffer)';
COMMENT ON COLUMN "XP_Sonstiges"."XP_Gemeinde"."rs" IS 'Regionalschlüssel';
COMMENT ON COLUMN "XP_Sonstiges"."XP_Gemeinde"."gemeindeName" IS 'Name der Gemeinde.';
COMMENT ON COLUMN "XP_Sonstiges"."XP_Gemeinde"."ortsteilName" IS 'Name des Ortsteils';
GRANT SELECT ON TABLE "XP_Sonstiges"."XP_Gemeinde" TO xp_gast;
GRANT ALL ON TABLE "XP_Sonstiges"."XP_Gemeinde" TO xp_user;

-- -----------------------------------------------------
-- Table "XP_Sonstiges"."XP_Plangeber"
-- -----------------------------------------------------
CREATE  TABLE  "XP_Sonstiges"."XP_Plangeber" (
  "id" INTEGER NOT NULL DEFAULT nextval('"XP_Sonstiges"."XP_Plangeber_id_seq"'),
  "name" VARCHAR(255) NOT NULL ,
  "kennziffer" VARCHAR(16) NULL ,
  PRIMARY KEY ("id") );
COMMENT ON TABLE "XP_Sonstiges"."XP_Plangeber" IS 'Spezifikation der Institution, die für den Plan verantwortlich ist.';
COMMENT ON COLUMN "XP_Sonstiges"."XP_Plangeber"."id" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN "XP_Sonstiges"."XP_Plangeber"."name" IS 'Name des Plangebers.';
COMMENT ON COLUMN "XP_Sonstiges"."XP_Plangeber"."kennziffer" IS 'Kennziffer des Plangebers.';
GRANT SELECT ON TABLE "XP_Sonstiges"."XP_Plangeber" TO xp_gast;
GRANT ALL ON TABLE "XP_Sonstiges"."XP_Plangeber" TO xp_user;

-- -----------------------------------------------------
-- Table "XP_Basisobjekte"."XP_SPEMassnahmenTypen"
-- -----------------------------------------------------
CREATE  TABLE  "XP_Basisobjekte"."XP_SPEMassnahmenTypen" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Code") );
COMMENT ON TABLE  "XP_Basisobjekte"."XP_SPEMassnahmenTypen" IS 'Klassifikation der Maßnahme';
GRANT SELECT ON TABLE "XP_Basisobjekte"."XP_SPEMassnahmenTypen" TO xp_gast;

-- -----------------------------------------------------
-- Table "XP_Enumerationen"."XP_SPEZiele"
-- -----------------------------------------------------
CREATE  TABLE  "XP_Enumerationen"."XP_SPEZiele" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Code") );

GRANT SELECT ON TABLE "XP_Enumerationen"."XP_SPEZiele" TO xp_gast;

-- -----------------------------------------------------
-- Table "XP_Enumerationen"."XP_VerlaengerungVeraenderungssperre"
-- -----------------------------------------------------
CREATE  TABLE  "XP_Enumerationen"."XP_VerlaengerungVeraenderungssperre" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Code") );

GRANT SELECT ON TABLE "XP_Enumerationen"."XP_VerlaengerungVeraenderungssperre" TO xp_gast;

-- -----------------------------------------------------
-- Table "XP_Enumerationen"."XP_ABEMassnahmenTypen"
-- -----------------------------------------------------
CREATE  TABLE  "XP_Enumerationen"."XP_ABEMassnahmenTypen" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Code") );
COMMENT ON TABLE  "XP_Enumerationen"."XP_ABEMassnahmenTypen" IS 'Anpflanzung, Bindung, Erhaltung: Art der Maßnahme';
GRANT SELECT ON TABLE "XP_Enumerationen"."XP_ABEMassnahmenTypen" TO xp_gast;

-- -----------------------------------------------------
-- Table "XP_Enumerationen"."XP_AnpflanzungBindungErhaltungsGegenstand"
-- -----------------------------------------------------
CREATE  TABLE  "XP_Enumerationen"."XP_AnpflanzungBindungErhaltungsGegenstand" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Code") );
COMMENT ON TABLE  "XP_Enumerationen"."XP_AnpflanzungBindungErhaltungsGegenstand" IS 'Anpflanzung, Bindung, Erhaltung: Gegenstände der Maßnahme ';
GRANT SELECT ON TABLE "XP_Enumerationen"."XP_AnpflanzungBindungErhaltungsGegenstand" TO xp_gast;

-- -----------------------------------------------------
-- Table "XP_Enumerationen"."XP_GrenzeTypen"
-- -----------------------------------------------------
CREATE TABLE  "XP_Enumerationen"."XP_GrenzeTypen" (
  "Code" INTEGER NOT NULL,
  "Bezeichner" VARCHAR(64) NOT NULL,
  PRIMARY KEY ("Code"));

GRANT SELECT ON TABLE "XP_Enumerationen"."XP_GrenzeTypen" TO xp_gast;

-- -----------------------------------------------------
-- Table "XP_Sonstiges"."XP_ArtHoehenbezug"
-- -----------------------------------------------------
CREATE  TABLE  "XP_Sonstiges"."XP_ArtHoehenbezug" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Code") );

GRANT SELECT ON TABLE "XP_Sonstiges"."XP_ArtHoehenbezug" TO xp_gast;

-- -----------------------------------------------------
-- Table "XP_Sonstiges"."XP_ArtHoehenbezugspunkt"
-- -----------------------------------------------------
CREATE  TABLE  "XP_Sonstiges"."XP_ArtHoehenbezugspunkt" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Code") );

GRANT SELECT ON TABLE "XP_Sonstiges"."XP_ArtHoehenbezugspunkt" TO xp_gast;

-- -----------------------------------------------------
-- Table "XP_Sonstiges"."XP_Hoehenangabe"
-- -----------------------------------------------------
CREATE  TABLE  "XP_Sonstiges"."XP_Hoehenangabe" (
  "id" INTEGER NOT NULL DEFAULT nextval('"XP_Sonstiges"."XP_Hoehenangabe_id_seq"'),
  "hoehenbezug" INTEGER NULL ,
  "abweichenderHoehenbezug" VARCHAR(255) NULL ,
  "bezugspunkt" INTEGER NULL ,
  "abweichenderBezugspunkt" VARCHAR(255) NULL ,
  "hMin" REAL NULL ,
  "hMax" REAL NULL ,
  "hZwingend" REAL NULL ,
  "h" REAL NULL ,
  PRIMARY KEY ("id") ,
  CONSTRAINT "fk_XP_Hoehenangabe_XP_ArtHoehenbezug"
    FOREIGN KEY ("hoehenbezug" )
    REFERENCES "XP_Sonstiges"."XP_ArtHoehenbezug" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_XP_Hoehenangabe_XP_ArtHoehenbezugspunkt1"
    FOREIGN KEY ("bezugspunkt" )
    REFERENCES "XP_Sonstiges"."XP_ArtHoehenbezugspunkt" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
COMMENT ON TABLE  "XP_Sonstiges"."XP_Hoehenangabe" IS 'Spezifikation einer Angabe zur vertikalen Höhe oder zu einem Bereich vertikaler Höhen. Es ist möglich, spezifische Höhenangaben (z.B. die First- oder Traufhöhe eines Gebäudes) vorzugeben oder einzuschränken, oder den Gültigkeitsbereich eines Planinhalts auf eine bestimmte Höhe (hZwingend) bzw. einen Höhenbereich (hMin - hMax) zu beschränken, was vor allem bei der höhenabhängigen Festsetzung einer überbaubaren Grundstücksfläche (BP_UeberbaubareGrundstuecksflaeche), einer Baulinie (BP_Baulinie) oder einer Baugrenze (BP_Baugrenze) relevant ist. In diesem Fall bleiben die Attribute bezugspunkt und abweichenderBezugspunkt unbelegt.';
COMMENT ON COLUMN "XP_Sonstiges"."XP_Hoehenangabe"."id" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN "XP_Sonstiges"."XP_Hoehenangabe"."hoehenbezug" IS 'Art des Höhenbezuges.';
COMMENT ON COLUMN "XP_Sonstiges"."XP_Hoehenangabe"."bezugspunkt" IS 'BBestimmung des Bezugspunktes der Höhenangaben. Wenn weder dies Attribut noch das Attribut "abweichenderBezugspunkt" belegt sind, soll die Höhenangabe als vertikale Einschränkung des zugeordneten Planinhalts interpretiert werden.';
COMMENT ON COLUMN "XP_Sonstiges"."XP_Hoehenangabe"."abweichenderBezugspunkt" IS 'Textuelle Spezifikation eines Höhenbezugspunktes wenn das Attribut "bezugspunkt" nicht belegt ist.';
COMMENT ON COLUMN "XP_Sonstiges"."XP_Hoehenangabe"."hMin" IS 'Minimal zulassige Höhe des Bezugspunktes (bezugspunkt) bei einer Bereichsangabe, bzw. untere Grenze des vertikalen Gültigkeitsbereiches eines Planinhalts, wenn bezugspunkt nicht belegt ist. In diesem Fall gilt: Ist hMax nicht belegt, gilt die Festlegung ab der Höhe hMin. ';
COMMENT ON COLUMN "XP_Sonstiges"."XP_Hoehenangabe"."hMax" IS 'Maximal zulässige Höhe des Bezugspunktes (bezugspunkt) bei einer Bereichsangabe, bzw. obere Grenze des vertikalen Gültigkeitsbereiches eines Planinhalts, wenn bezugspunkt nicht belegt ist. In diesem Fall gilt: Ist hMin nicht belegt, gilt die Festlegung bis zur Höhe hMax. ';
COMMENT ON COLUMN "XP_Sonstiges"."XP_Hoehenangabe"."hZwingend" IS 'Zwingend einzuhaltende Höhe des Bezugspunktes (bezugspunkt) , bzw. Beschränkung der vertikalen Gültigkeitsbereiches eines Planinhalts auf eine bestimmte Höhe. ';
COMMENT ON COLUMN "XP_Sonstiges"."XP_Hoehenangabe"."h" IS 'Maximal zulässige Höhe des Bezugspunktes (bezugspunkt) ';
CREATE INDEX "idx_fk_XP_Hoehenangabe_XP_ArtHoehenbezug" ON "XP_Sonstiges"."XP_Hoehenangabe" ("hoehenbezug") ;
CREATE INDEX "idx_fk_XP_Hoehenangabe_XP_ArtHoehenbezugspunkt1" ON "XP_Sonstiges"."XP_Hoehenangabe" ("bezugspunkt") ;

GRANT SELECT ON TABLE "XP_Sonstiges"."XP_Hoehenangabe" TO xp_gast;
GRANT ALL ON TABLE "XP_Sonstiges"."XP_Hoehenangabe" TO xp_user;

-- -----------------------------------------------------
-- Table "XP_Basisobjekte"."XP_SPEMassnahmenDaten"
-- -----------------------------------------------------
CREATE  TABLE  "XP_Basisobjekte"."XP_SPEMassnahmenDaten" (
  "id" INTEGER NOT NULL DEFAULT nextval('"XP_Basisobjekte"."XP_SPEMassnahmenDaten_id_seq"'),
  "klassifizMassnahme" INTEGER NULL ,
  "massnahmeText" VARCHAR(1024) NULL ,
  "massnahmeKuerzel" VARCHAR(255) NULL ,
  PRIMARY KEY ("id") ,
  CONSTRAINT "fk_XP_SPEMassnahmenDaten_XP_SPEMassnahmenTypen1"
    FOREIGN KEY ("klassifizMassnahme" )
    REFERENCES "XP_Basisobjekte"."XP_SPEMassnahmenTypen" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
COMMENT ON TABLE  "XP_Basisobjekte"."XP_SPEMassnahmenDaten" IS 'Spezifikation der Attribute für einer Schutz-, Pflege- oder Entwicklungsmaßnahme.';
COMMENT ON COLUMN "XP_Basisobjekte"."XP_SPEMassnahmenDaten"."id" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN "XP_Basisobjekte"."XP_SPEMassnahmenDaten"."klassifizMassnahme" IS 'Klassifikation der Maßnahme';
COMMENT ON COLUMN "XP_Basisobjekte"."XP_SPEMassnahmenDaten"."massnahmeText" IS 'Durchzuführende Maßnahme als freier Text.';
COMMENT ON COLUMN "XP_Basisobjekte"."XP_SPEMassnahmenDaten"."massnahmeKuerzel" IS 'Kürzel der durchzuführenden Maßnahme.';
CREATE INDEX "idx_fk_XP_SPEMassnahmenDaten_XP_SPEMassnahmenTypen1" ON "XP_Basisobjekte"."XP_SPEMassnahmenDaten" ("klassifizMassnahme") ;

GRANT SELECT ON TABLE "XP_Sonstiges"."XP_Hoehenangabe" TO xp_gast;
GRANT ALL ON TABLE "XP_Sonstiges"."XP_Hoehenangabe" TO xp_user;

-- -----------------------------------------------------
-- Table `XP_Basisobjekte`.`XP_Objekt_hoehenangabe`
-- -----------------------------------------------------
CREATE TABLE "XP_Basisobjekte"."XP_Objekt_hoehenangabe" (
  "XP_Objekt_gid" BIGINT NOT NULL ,
  "hoehenangabe" INTEGER NOT NULL ,
  PRIMARY KEY ("XP_Objekt_gid", "hoehenangabe") ,
  CONSTRAINT "fk_XP_Objekt_has_XP_Hoehenangabe_XP_Objekt1"
    FOREIGN KEY ("XP_Objekt_gid")
    REFERENCES "XP_Basisobjekte"."XP_Objekt" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_XP_Objekt_has_XP_Hoehenangabe_XP_Hoehenangabe1"
    FOREIGN KEY ("hoehenangabe")
    REFERENCES "XP_Sonstiges"."XP_Hoehenangabe" ("id")
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
COMMENT ON TABLE "XP_Basisobjekte"."XP_Objekt_hoehenangabe" IS 'Angaben zur vertikalen Lage eines Planinhalts.';
CREATE INDEX "fk_hoehenangabe_XP_Objekt1" ON "XP_Basisobjekte"."XP_Objekt_hoehenangabe" ("XP_Objekt_gid");
CREATE INDEX "fk_hoehenangabe_XP_Hoehenangabe1" ON "XP_Basisobjekte"."XP_Objekt_hoehenangabe" ("hoehenangabe");

GRANT SELECT ON TABLE "XP_Basisobjekte"."XP_Objekt_hoehenangabe" TO xp_gast;
GRANT ALL ON TABLE "XP_Basisobjekte"."XP_Objekt_hoehenangabe" TO xp_user;

-- *****************************************************
-- CREATE VIEWs
-- *****************************************************

-- -----------------------------------------------------
-- View "XP_Basisobjekte"."XP_Plaene"
-- -----------------------------------------------------
CREATE  OR REPLACE VIEW "XP_Basisobjekte"."XP_Plaene" AS
SELECT g.gid, g."raeumlicherGeltungsbereich", name, nummer, "internalId", beschreibung,  kommentar,
  "technHerstellDatum",  "untergangsDatum",  "erstellungsMassstab" ,
  bezugshoehe, CAST(c.relname as varchar) as "Objektart"
FROM  "XP_Basisobjekte"."XP_RaeumlicherGeltungsbereich" g
JOIN pg_class c ON g.tableoid = c.oid
JOIN "XP_Basisobjekte"."XP_Plan" p ON g.gid = p.gid;

GRANT SELECT ON TABLE "XP_Basisobjekte"."XP_Plaene" TO xp_gast;
GRANT ALL ON TABLE "XP_Basisobjekte"."XP_Plaene" TO xp_user;

CREATE OR REPLACE RULE _update AS
    ON UPDATE TO "XP_Basisobjekte"."XP_Plaene" DO INSTEAD  UPDATE "XP_Basisobjekte"."XP_RaeumlicherGeltungsbereich" SET "raeumlicherGeltungsbereich" = new."raeumlicherGeltungsbereich"
  WHERE gid = old.gid;
CREATE OR REPLACE RULE _delete AS
    ON DELETE TO "XP_Basisobjekte"."XP_Plaene" DO INSTEAD  DELETE FROM "XP_Basisobjekte"."XP_RaeumlicherGeltungsbereich"
  WHERE gid = old.gid;

-- -----------------------------------------------------
-- View "XP_Basisobjekte"."XP_Bereiche"
-- -----------------------------------------------------
CREATE  OR REPLACE VIEW "XP_Basisobjekte"."XP_Bereiche" AS
SELECT g.gid, COALESCE(g.geltungsbereich, p."raeumlicherGeltungsbereich") as geltungsbereich, b.name, CAST(c.relname as varchar) as "Objektart", p.gid as "planGid", p.name as "planName", p."Objektart" as "planArt"
   FROM "XP_Basisobjekte"."XP_Geltungsbereich" g
   JOIN pg_class c ON g.tableoid = c.oid
   JOIN pg_namespace n ON c.relnamespace = n.oid
   JOIN "XP_Basisobjekte"."XP_Bereich" b ON g.gid = b.gid
   JOIN "XP_Basisobjekte"."XP_Plaene" p ON "XP_Basisobjekte"."gehoertZuPlan"(CAST(n.nspname as varchar), CAST(c.relname as varchar), g.gid) = p.gid;
GRANT SELECT ON TABLE "XP_Basisobjekte"."XP_Bereiche" TO xp_gast;
GRANT ALL ON TABLE "XP_Basisobjekte"."XP_Bereiche" TO xp_user;

CREATE OR REPLACE RULE _update AS
    ON UPDATE TO "XP_Basisobjekte"."XP_Bereiche" DO INSTEAD  UPDATE "XP_Basisobjekte"."XP_Geltungsbereich" SET "geltungsbereich" = new."geltungsbereich"
  WHERE gid = old.gid;
CREATE OR REPLACE RULE _delete AS
    ON DELETE TO "XP_Basisobjekte"."XP_Bereiche" DO INSTEAD  DELETE FROM "XP_Basisobjekte"."XP_Geltungsbereich"
  WHERE gid = old.gid;

-- -----------------------------------------------------
-- View "XP_Praesentationsobjekte"."XP_AbstraktePraesentationsobjekte"
-- -----------------------------------------------------
CREATE  OR REPLACE VIEW "XP_Praesentationsobjekte"."XP_AbstraktePraesentationsobjekte" AS
SELECT g.gid, p."gehoertZuBereich", CAST(c.relname as varchar) as "Objektart" , d."XP_Objekt_gid"
FROM  "XP_Praesentationsobjekte"."XP_APO" g
JOIN pg_class c ON g.tableoid = c.oid
JOIN "XP_Praesentationsobjekte"."XP_AbstraktesPraesentationsobjekt" p ON g.gid = p.gid
LEFT JOIN (SELECT DISTINCT "XP_APObjekt_gid" as gid, "dientZurDarstellungVon" as "XP_Objekt_gid" FROM "XP_Praesentationsobjekte"."XP_APObjekt_dientZurDarstellungVon") d ON g.gid = d.gid;
GRANT SELECT ON TABLE "XP_Praesentationsobjekte"."XP_AbstraktePraesentationsobjekte" TO xp_gast;

-- *****************************************************
-- DATA
-- *****************************************************

-- -----------------------------------------------------
-- Data for table "XP_Enumerationen"."XP_AllgArtDerBaulNutzung"
-- -----------------------------------------------------
INSERT INTO "XP_Enumerationen"."XP_AllgArtDerBaulNutzung" ("Code", "Bezeichner") VALUES ('1000', 'WohnBauflaeche');
INSERT INTO "XP_Enumerationen"."XP_AllgArtDerBaulNutzung" ("Code", "Bezeichner") VALUES ('2000', 'GemischteBauflaeche');
INSERT INTO "XP_Enumerationen"."XP_AllgArtDerBaulNutzung" ("Code", "Bezeichner") VALUES ('3000', 'GewerblicheBauflaeche');
INSERT INTO "XP_Enumerationen"."XP_AllgArtDerBaulNutzung" ("Code", "Bezeichner") VALUES ('4000', 'SonderBauflaeche');
INSERT INTO "XP_Enumerationen"."XP_AllgArtDerBaulNutzung" ("Code", "Bezeichner") VALUES ('9999', 'SonstigeBauflaeche');

-- -----------------------------------------------------
-- Data for table "XP_Enumerationen"."XP_BesondereArtDerBaulNutzung"
-- -----------------------------------------------------
INSERT INTO "XP_Enumerationen"."XP_BesondereArtDerBaulNutzung" ("Code", "Bezeichner") VALUES ('1000', 'Kleinsiedlungsgebiet');
INSERT INTO "XP_Enumerationen"."XP_BesondereArtDerBaulNutzung" ("Code", "Bezeichner") VALUES ('1100', 'ReinesWohngebiet');
INSERT INTO "XP_Enumerationen"."XP_BesondereArtDerBaulNutzung" ("Code", "Bezeichner") VALUES ('1200', 'AllgWohngebiet');
INSERT INTO "XP_Enumerationen"."XP_BesondereArtDerBaulNutzung" ("Code", "Bezeichner") VALUES ('1300', 'BesonderesWohngebiet');
INSERT INTO "XP_Enumerationen"."XP_BesondereArtDerBaulNutzung" ("Code", "Bezeichner") VALUES ('1400', 'Dorfgebiet');
INSERT INTO "XP_Enumerationen"."XP_BesondereArtDerBaulNutzung" ("Code", "Bezeichner") VALUES ('1500', 'Mischgebiet');
INSERT INTO "XP_Enumerationen"."XP_BesondereArtDerBaulNutzung" ("Code", "Bezeichner") VALUES ('1550', 'UrbanesGebiet');
INSERT INTO "XP_Enumerationen"."XP_BesondereArtDerBaulNutzung" ("Code", "Bezeichner") VALUES ('1600', 'Kerngebiet');
INSERT INTO "XP_Enumerationen"."XP_BesondereArtDerBaulNutzung" ("Code", "Bezeichner") VALUES ('1700', 'Gewerbegebiet');
INSERT INTO "XP_Enumerationen"."XP_BesondereArtDerBaulNutzung" ("Code", "Bezeichner") VALUES ('1800', 'Industriegebiet');
INSERT INTO "XP_Enumerationen"."XP_BesondereArtDerBaulNutzung" ("Code", "Bezeichner") VALUES ('2000', 'SondergebietErholung');
INSERT INTO "XP_Enumerationen"."XP_BesondereArtDerBaulNutzung" ("Code", "Bezeichner") VALUES ('2100', 'SondergebietSonst');
INSERT INTO "XP_Enumerationen"."XP_BesondereArtDerBaulNutzung" ("Code", "Bezeichner") VALUES ('3000', 'Wochenendhausgebiet');
INSERT INTO "XP_Enumerationen"."XP_BesondereArtDerBaulNutzung" ("Code", "Bezeichner") VALUES ('4000', 'Sondergebiet');
INSERT INTO "XP_Enumerationen"."XP_BesondereArtDerBaulNutzung" ("Code", "Bezeichner") VALUES ('9999', 'SonstigesGebiet');

-- -----------------------------------------------------
-- Data for table "XP_Enumerationen"."XP_Rechtsstand"
-- -----------------------------------------------------
INSERT INTO "XP_Enumerationen"."XP_Rechtsstand" ("Code", "Bezeichner") VALUES ('1000', 'Geplant');
INSERT INTO "XP_Enumerationen"."XP_Rechtsstand" ("Code", "Bezeichner") VALUES ('2000', 'Bestehend');
INSERT INTO "XP_Enumerationen"."XP_Rechtsstand" ("Code", "Bezeichner") VALUES ('3000', 'Fortfallend');

-- -----------------------------------------------------
-- Data for table "XP_Enumerationen"."XP_Sondernutzungen"
-- -----------------------------------------------------
INSERT INTO "XP_Enumerationen"."XP_Sondernutzungen" ("Code", "Bezeichner") VALUES ('1000', 'Wochenendhausgebiet');
INSERT INTO "XP_Enumerationen"."XP_Sondernutzungen" ("Code", "Bezeichner") VALUES ('1100', 'Ferienhausgebiet');
INSERT INTO "XP_Enumerationen"."XP_Sondernutzungen" ("Code", "Bezeichner") VALUES ('1200', 'Campingplatzgebiet');
INSERT INTO "XP_Enumerationen"."XP_Sondernutzungen" ("Code", "Bezeichner") VALUES ('1300', 'Kurgebiet');
INSERT INTO "XP_Enumerationen"."XP_Sondernutzungen" ("Code", "Bezeichner") VALUES ('1400', 'SonstSondergebietErholung');
INSERT INTO "XP_Enumerationen"."XP_Sondernutzungen" ("Code", "Bezeichner") VALUES ('1500', 'Einzelhandelsgebiet');
INSERT INTO "XP_Enumerationen"."XP_Sondernutzungen" ("Code", "Bezeichner") VALUES ('1600', 'GrossflaechigerEinzelhandel');
INSERT INTO "XP_Enumerationen"."XP_Sondernutzungen" ("Code", "Bezeichner") VALUES ('16000', 'Ladengebiet');
INSERT INTO "XP_Enumerationen"."XP_Sondernutzungen" ("Code", "Bezeichner") VALUES ('16001', 'Einkaufszentrum');
INSERT INTO "XP_Enumerationen"."XP_Sondernutzungen" ("Code", "Bezeichner") VALUES ('16002', 'SonstGrossflEinzelhandel');
INSERT INTO "XP_Enumerationen"."XP_Sondernutzungen" ("Code", "Bezeichner") VALUES ('1700', 'Verkehrsuebungsplatz');
INSERT INTO "XP_Enumerationen"."XP_Sondernutzungen" ("Code", "Bezeichner") VALUES ('1800', 'Hafengebiet');
INSERT INTO "XP_Enumerationen"."XP_Sondernutzungen" ("Code", "Bezeichner") VALUES ('1900', 'SondergebietErneuerbareEnergie');
INSERT INTO "XP_Enumerationen"."XP_Sondernutzungen" ("Code", "Bezeichner") VALUES ('2000', 'SondergebietMilitaer');
INSERT INTO "XP_Enumerationen"."XP_Sondernutzungen" ("Code", "Bezeichner") VALUES ('2100', 'SondergebietLandwirtschaft');
INSERT INTO "XP_Enumerationen"."XP_Sondernutzungen" ("Code", "Bezeichner") VALUES ('2200', 'SondergebietSport');
INSERT INTO "XP_Enumerationen"."XP_Sondernutzungen" ("Code", "Bezeichner") VALUES ('2300', 'SondergebietGesundheitSoziales');
INSERT INTO "XP_Enumerationen"."XP_Sondernutzungen" ("Code", "Bezeichner") VALUES ('23000', 'Klinikgebiet');
INSERT INTO "XP_Enumerationen"."XP_Sondernutzungen" ("Code", "Bezeichner") VALUES ('2400', 'Golfplatz');
INSERT INTO "XP_Enumerationen"."XP_Sondernutzungen" ("Code", "Bezeichner") VALUES ('2500', 'SondergebietKultur');
INSERT INTO "XP_Enumerationen"."XP_Sondernutzungen" ("Code", "Bezeichner") VALUES ('2600', 'SondergebietTourismus');
INSERT INTO "XP_Enumerationen"."XP_Sondernutzungen" ("Code", "Bezeichner") VALUES ('2700', 'SondergebietBueroUndVerwaltung');
INSERT INTO "XP_Enumerationen"."XP_Sondernutzungen" ("Code", "Bezeichner") VALUES ('2720', 'SondergebietJustiz');
INSERT INTO "XP_Enumerationen"."XP_Sondernutzungen" ("Code", "Bezeichner") VALUES ('2800', 'SondergebietHochschuleForschung');
INSERT INTO "XP_Enumerationen"."XP_Sondernutzungen" ("Code", "Bezeichner") VALUES ('2900', 'SondergebietMesse');
INSERT INTO "XP_Enumerationen"."XP_Sondernutzungen" ("Code", "Bezeichner") VALUES ('9999', 'SondergebietAndereNutzungen');

-- -----------------------------------------------------
-- Data for table "XP_Enumerationen"."XP_AbweichungBauNVOTypen"
-- -----------------------------------------------------
INSERT INTO "XP_Enumerationen"."XP_AbweichungBauNVOTypen" ("Code", "Bezeichner") VALUES ('1000', 'EinschraenkungNutzung');
INSERT INTO "XP_Enumerationen"."XP_AbweichungBauNVOTypen" ("Code", "Bezeichner") VALUES ('2000', 'AusschlussNutzung');
INSERT INTO "XP_Enumerationen"."XP_AbweichungBauNVOTypen" ("Code", "Bezeichner") VALUES ('3000', 'AusweitungNutzung');
INSERT INTO "XP_Enumerationen"."XP_AbweichungBauNVOTypen" ("Code", "Bezeichner") VALUES ('9999', 'SonstAbweichung');

-- -----------------------------------------------------
-- Data for table "XP_Enumerationen"."XP_ZweckbestimmungGemeinbedarf"
-- -----------------------------------------------------
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungGemeinbedarf" ("Code", "Bezeichner") VALUES ('1000', 'OeffentlicheVerwaltung');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungGemeinbedarf" ("Code", "Bezeichner") VALUES ('1200', 'BildungForschung');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungGemeinbedarf" ("Code", "Bezeichner") VALUES ('1400', 'Kirche');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungGemeinbedarf" ("Code", "Bezeichner") VALUES ('1600', 'Sozial');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungGemeinbedarf" ("Code", "Bezeichner") VALUES ('1800', 'Gesundheit');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungGemeinbedarf" ("Code", "Bezeichner") VALUES ('2000', 'Kultur');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungGemeinbedarf" ("Code", "Bezeichner") VALUES ('2200', 'Sport');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungGemeinbedarf" ("Code", "Bezeichner") VALUES ('2400', 'SicherheitOrdnung');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungGemeinbedarf" ("Code", "Bezeichner") VALUES ('2600', 'Infrastruktur');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungGemeinbedarf" ("Code", "Bezeichner") VALUES ('9999', 'Sonstiges');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungGemeinbedarf" ("Code", "Bezeichner") VALUES ('10000', 'KommunaleEinrichtung');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungGemeinbedarf" ("Code", "Bezeichner") VALUES ('10001', 'BetriebOeffentlZweckbestimmung');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungGemeinbedarf" ("Code", "Bezeichner") VALUES ('10002', 'AnlageBundLand');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungGemeinbedarf" ("Code", "Bezeichner") VALUES ('10003', 'veraltet - SonstigeOeffentlicheVerwaltung');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungGemeinbedarf" ("Code", "Bezeichner") VALUES ('12000', 'Schule');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungGemeinbedarf" ("Code", "Bezeichner") VALUES ('12001', 'Hochschule');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungGemeinbedarf" ("Code", "Bezeichner") VALUES ('12002', 'BerufsbildendeSchule');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungGemeinbedarf" ("Code", "Bezeichner") VALUES ('12003', 'Forschungseinrichtung');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungGemeinbedarf" ("Code", "Bezeichner") VALUES ('12004', 'veraltet - SonstigesBildungForschung');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungGemeinbedarf" ("Code", "Bezeichner") VALUES ('14000', 'Sakralgebaeude');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungGemeinbedarf" ("Code", "Bezeichner") VALUES ('14001', 'KirchlicheVerwaltung');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungGemeinbedarf" ("Code", "Bezeichner") VALUES ('14002', 'Kirchengemeinde');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungGemeinbedarf" ("Code", "Bezeichner") VALUES ('14003', 'veraltet - SonstigesKirche');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungGemeinbedarf" ("Code", "Bezeichner") VALUES ('16000', 'EinrichtungKinder');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungGemeinbedarf" ("Code", "Bezeichner") VALUES ('16001', 'EinrichtungJugendliche');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungGemeinbedarf" ("Code", "Bezeichner") VALUES ('16002', 'EinrichtungFamilienErwachsene');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungGemeinbedarf" ("Code", "Bezeichner") VALUES ('16003', 'EinrichtungSenioren');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungGemeinbedarf" ("Code", "Bezeichner") VALUES ('16004', 'veraltet - SonstigeSozialeEinrichtung');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungGemeinbedarf" ("Code", "Bezeichner") VALUES ('18000', 'Krankenhaus');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungGemeinbedarf" ("Code", "Bezeichner") VALUES ('18001', 'veraltet - SonstigesGesundheit');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungGemeinbedarf" ("Code", "Bezeichner") VALUES ('20000', 'MusikTheater');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungGemeinbedarf" ("Code", "Bezeichner") VALUES ('20001', 'Bildung');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungGemeinbedarf" ("Code", "Bezeichner") VALUES ('20002', 'veraltet - SonstigeKultur');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungGemeinbedarf" ("Code", "Bezeichner") VALUES ('22000', 'Bad');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungGemeinbedarf" ("Code", "Bezeichner") VALUES ('22001', 'SportplatzSporthalle');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungGemeinbedarf" ("Code", "Bezeichner") VALUES ('22002', 'veraltet - SonstigerSport');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungGemeinbedarf" ("Code", "Bezeichner") VALUES ('24000', 'Feuerwehr');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungGemeinbedarf" ("Code", "Bezeichner") VALUES ('24001', 'Schutzbauwerk');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungGemeinbedarf" ("Code", "Bezeichner") VALUES ('24002', 'Justiz');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungGemeinbedarf" ("Code", "Bezeichner") VALUES ('24003', 'veraltet - SonstigeSicherheitOrdnung');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungGemeinbedarf" ("Code", "Bezeichner") VALUES ('26000', 'Post');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungGemeinbedarf" ("Code", "Bezeichner") VALUES ('26001', 'veraltet - SonstigeInfrastruktur');

-- -----------------------------------------------------
-- Data for table "XP_Enumerationen"."XP_ZweckbestimmungSpielSportanlage"
-- -----------------------------------------------------
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungSpielSportanlage" ("Code", "Bezeichner") VALUES ('1000', 'Sportanlage');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungSpielSportanlage" ("Code", "Bezeichner") VALUES ('2000', 'Spielanlage');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungSpielSportanlage" ("Code", "Bezeichner") VALUES ('3000', 'SpielSportanlage');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungSpielSportanlage" ("Code", "Bezeichner") VALUES ('9999', 'Sonstiges');

-- -----------------------------------------------------
-- Data for table "XP_Enumerationen"."XP_VerlaengerungVeraenderungssperre"
-- -----------------------------------------------------
INSERT INTO "XP_Enumerationen"."XP_VerlaengerungVeraenderungssperre" ("Code", "Bezeichner") VALUES ('1000', 'Keine');
INSERT INTO "XP_Enumerationen"."XP_VerlaengerungVeraenderungssperre" ("Code", "Bezeichner") VALUES ('2000', 'ErsteVerlaengerung');
INSERT INTO "XP_Enumerationen"."XP_VerlaengerungVeraenderungssperre" ("Code", "Bezeichner") VALUES ('3000', 'ZweiteVerlaengerung');

-- -----------------------------------------------------
-- Data for table "XP_Enumerationen"."XP_ZweckbestimmungGruen"
-- -----------------------------------------------------
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungGruen" ("Code", "Bezeichner") VALUES ('1000', 'Parkanlage');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungGruen" ("Code", "Bezeichner") VALUES ('1200', 'Dauerkleingaerten');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungGruen" ("Code", "Bezeichner") VALUES ('1400', 'Sportplatz');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungGruen" ("Code", "Bezeichner") VALUES ('1600', 'Spielplatz');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungGruen" ("Code", "Bezeichner") VALUES ('1800', 'Zeltplatz');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungGruen" ("Code", "Bezeichner") VALUES ('2000', 'Badeplatz');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungGruen" ("Code", "Bezeichner") VALUES ('2200', 'FreizeitErholung');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungGruen" ("Code", "Bezeichner") VALUES ('2400', 'SpezGruenflaeche');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungGruen" ("Code", "Bezeichner") VALUES ('2600', 'Friedhof');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungGruen" ("Code", "Bezeichner") VALUES ('9999', 'Sonstiges');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungGruen" ("Code", "Bezeichner") VALUES ('10000', 'ParkanlageHistorisch');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungGruen" ("Code", "Bezeichner") VALUES ('10001', 'ParkanlageNaturnah');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungGruen" ("Code", "Bezeichner") VALUES ('10002', 'ParkanlageWaldcharakter');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungGruen" ("Code", "Bezeichner") VALUES ('10003', 'NaturnaheUferParkanlage');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungGruen" ("Code", "Bezeichner") VALUES ('12000', 'ErholungsGaerten');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungGruen" ("Code", "Bezeichner") VALUES ('14000', 'Reitsportanlage');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungGruen" ("Code", "Bezeichner") VALUES ('14001', 'Hundesportanlage');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungGruen" ("Code", "Bezeichner") VALUES ('14002', 'Wassersportanlage');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungGruen" ("Code", "Bezeichner") VALUES ('14003', 'Schiessstand');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungGruen" ("Code", "Bezeichner") VALUES ('14004', 'Golfplatz');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungGruen" ("Code", "Bezeichner") VALUES ('14005', 'Skisport');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungGruen" ("Code", "Bezeichner") VALUES ('14006', 'Tennisanlage');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungGruen" ("Code", "Bezeichner") VALUES ('14007', 'veraltet - SonstigerSportplatz');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungGruen" ("Code", "Bezeichner") VALUES ('16000', 'Bolzplatz');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungGruen" ("Code", "Bezeichner") VALUES ('16001', 'Abenteuerspielplatz');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungGruen" ("Code", "Bezeichner") VALUES ('18000', 'Campingplatz');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungGruen" ("Code", "Bezeichner") VALUES ('22000', 'Kleintierhaltung');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungGruen" ("Code", "Bezeichner") VALUES ('22001', 'Festplatz');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungGruen" ("Code", "Bezeichner") VALUES ('24000', 'StrassenbegleitGruen');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungGruen" ("Code", "Bezeichner") VALUES ('24001', 'BoeschungsFlaeche');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungGruen" ("Code", "Bezeichner") VALUES ('24002', 'veraltet - FeldWaldWiese');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungGruen" ("Code", "Bezeichner") VALUES ('24003', 'Uferschutzstreifen');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungGruen" ("Code", "Bezeichner") VALUES ('24004', 'Abschirmgruen');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungGruen" ("Code", "Bezeichner") VALUES ('24005', 'UmweltbildungsparkSchaugatter');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungGruen" ("Code", "Bezeichner") VALUES ('24006', 'RuhenderVerkehr');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungGruen" ("Code", "Bezeichner") VALUES ('99990', 'Gaertnerei');

-- -----------------------------------------------------
-- Data for table "XP_Enumerationen"."XP_ZweckbestimmungWald"
-- -----------------------------------------------------
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungWald" ("Code", "Bezeichner") VALUES ('1000', 'Naturwald');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungWald" ("Code", "Bezeichner") VALUES ('10000', 'Waldschutzgebiet');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungWald" ("Code", "Bezeichner") VALUES ('1200', 'Nutzwald');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungWald" ("Code", "Bezeichner") VALUES ('1400', 'Erholungswald');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungWald" ("Code", "Bezeichner") VALUES ('1600', 'Schutzwald');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungWald" ("Code", "Bezeichner") VALUES ('16000', 'Bodenschutzwald');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungWald" ("Code", "Bezeichner") VALUES ('16001', 'Biotopschutzwald');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungWald" ("Code", "Bezeichner") VALUES ('16002', 'NaturnaherWald');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungWald" ("Code", "Bezeichner") VALUES ('16003', 'SchutzwaldSchaedlicheUmwelteinwirkungen');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungWald" ("Code", "Bezeichner") VALUES ('16004', 'Schonwald');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungWald" ("Code", "Bezeichner") VALUES ('1700', 'Bannwald');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungWald" ("Code", "Bezeichner") VALUES ('1800', 'FlaecheForstwirtschaft');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungWald" ("Code", "Bezeichner") VALUES ('1900', 'ImmissionsgeschaedigterWald');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungWald" ("Code", "Bezeichner") VALUES ('9999', 'Sonstiges');

-- -----------------------------------------------------
-- Data for table "XP_Enumerationen"."XP_EigentumsartWald"
-- -----------------------------------------------------
INSERT INTO "XP_Enumerationen"."XP_EigentumsartWald" ("Code", "Bezeichner") VALUES ('1000', 'OeffentlicherWald');
INSERT INTO "XP_Enumerationen"."XP_EigentumsartWald" ("Code", "Bezeichner") VALUES ('1100', 'Staatswald');
INSERT INTO "XP_Enumerationen"."XP_EigentumsartWald" ("Code", "Bezeichner") VALUES ('1200', 'Koerperschaftswald');
INSERT INTO "XP_Enumerationen"."XP_EigentumsartWald" ("Code", "Bezeichner") VALUES ('12000', 'Kommunalwald');
INSERT INTO "XP_Enumerationen"."XP_EigentumsartWald" ("Code", "Bezeichner") VALUES ('12001', 'Stiftungswald');
INSERT INTO "XP_Enumerationen"."XP_EigentumsartWald" ("Code", "Bezeichner") VALUES ('2000', 'Privatwald');
INSERT INTO "XP_Enumerationen"."XP_EigentumsartWald" ("Code", "Bezeichner") VALUES ('20000', 'Gemeinschaftswald');
INSERT INTO "XP_Enumerationen"."XP_EigentumsartWald" ("Code", "Bezeichner") VALUES ('20001', 'Genossenschaftswald');
INSERT INTO "XP_Enumerationen"."XP_EigentumsartWald" ("Code", "Bezeichner") VALUES ('3000', 'Kirchenwald');
INSERT INTO "XP_Enumerationen"."XP_EigentumsartWald" ("Code", "Bezeichner") VALUES ('9999', 'Sonstiges');

-- -----------------------------------------------------
-- Data for table "XP_Enumerationen"."XP_WaldbetretungTyp"
-- -----------------------------------------------------
INSERT INTO "XP_Enumerationen"."XP_WaldbetretungTyp" ("Code", "Bezeichner") VALUES ('1000', 'Radfahren');
INSERT INTO "XP_Enumerationen"."XP_WaldbetretungTyp" ("Code", "Bezeichner") VALUES ('2000', 'Reiten');
INSERT INTO "XP_Enumerationen"."XP_WaldbetretungTyp" ("Code", "Bezeichner") VALUES ('3000', 'Fahren');
INSERT INTO "XP_Enumerationen"."XP_WaldbetretungTyp" ("Code", "Bezeichner") VALUES ('4000', 'Hundesport');

-- -----------------------------------------------------
-- Data for table "XP_Enumerationen"."XP_ZweckbestimmungLandwirtschaft"
-- -----------------------------------------------------
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungLandwirtschaft" ("Code", "Bezeichner") VALUES ('1000', 'LandwirtschaftAllgemein');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungLandwirtschaft" ("Code", "Bezeichner") VALUES ('1100', 'Ackerbau');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungLandwirtschaft" ("Code", "Bezeichner") VALUES ('1200', 'WiesenWeidewirtschaft');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungLandwirtschaft" ("Code", "Bezeichner") VALUES ('1300', 'GartenbaulicheErzeugung');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungLandwirtschaft" ("Code", "Bezeichner") VALUES ('1400', 'Obstbau');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungLandwirtschaft" ("Code", "Bezeichner") VALUES ('1500', 'Weinbau');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungLandwirtschaft" ("Code", "Bezeichner") VALUES ('1600', 'Imkerei');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungLandwirtschaft" ("Code", "Bezeichner") VALUES ('1700', 'Binnenfischerei');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungLandwirtschaft" ("Code", "Bezeichner") VALUES ('9999', 'Sonstiges');

-- -----------------------------------------------------
-- Data for table "XP_Enumerationen"."XP_Nutzungsform"
-- -----------------------------------------------------
INSERT INTO "XP_Enumerationen"."XP_Nutzungsform" ("Code", "Bezeichner") VALUES ('1000', 'Privat');
INSERT INTO "XP_Enumerationen"."XP_Nutzungsform" ("Code", "Bezeichner") VALUES ('2000', 'Oeffentlich');

-- -----------------------------------------------------
-- Data for table "XP_Enumerationen"."XP_ZweckbestimmungKennzeichnung"
-- -----------------------------------------------------
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungKennzeichnung" ("Code", "Bezeichner") VALUES ('1000', 'Naturgewalten');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungKennzeichnung" ("Code", "Bezeichner") VALUES ('2000', 'Abbauflaeche');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungKennzeichnung" ("Code", "Bezeichner") VALUES ('3000', 'AeussereEinwirkungen');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungKennzeichnung" ("Code", "Bezeichner") VALUES ('4000', 'SchadstoffBelastBoden');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungKennzeichnung" ("Code", "Bezeichner") VALUES ('5000', 'LaermBelastung');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungKennzeichnung" ("Code", "Bezeichner") VALUES ('6000', 'Bergbau');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungKennzeichnung" ("Code", "Bezeichner") VALUES ('7000', 'Bodenordnung');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungKennzeichnung" ("Code", "Bezeichner") VALUES ('8000', 'Vorhabensgebiet');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungKennzeichnung" ("Code", "Bezeichner") VALUES ('9999', 'AndereGesetzlVorschriften');

-- -----------------------------------------------------
-- Data for table "XP_Enumerationen"."XP_ZweckbestimmungVerEntsorgung"
-- -----------------------------------------------------
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungVerEntsorgung" ("Code", "Bezeichner") VALUES ('1000', 'Elektrizitaet');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungVerEntsorgung" ("Code", "Bezeichner") VALUES ('1200', 'Gas');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungVerEntsorgung" ("Code", "Bezeichner") VALUES ('1300', 'Erdoel');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungVerEntsorgung" ("Code", "Bezeichner") VALUES ('1400', 'Waermeversorgung');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungVerEntsorgung" ("Code", "Bezeichner") VALUES ('1600', 'Wasser');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungVerEntsorgung" ("Code", "Bezeichner") VALUES ('1800', 'Abwasser');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungVerEntsorgung" ("Code", "Bezeichner") VALUES ('2000', 'Regenwasser');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungVerEntsorgung" ("Code", "Bezeichner") VALUES ('2200', 'Abfallentsorgung');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungVerEntsorgung" ("Code", "Bezeichner") VALUES ('2400', 'Ablagerung');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungVerEntsorgung" ("Code", "Bezeichner") VALUES ('2600', 'Telekommunikation');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungVerEntsorgung" ("Code", "Bezeichner") VALUES ('2800', 'ErneuerbareEnergien');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungVerEntsorgung" ("Code", "Bezeichner") VALUES ('3000', 'KraftWaermeKopplung');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungVerEntsorgung" ("Code", "Bezeichner") VALUES ('9999', 'Sonstiges');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungVerEntsorgung" ("Code", "Bezeichner") VALUES ('10000', 'Hochspannungsleitung');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungVerEntsorgung" ("Code", "Bezeichner") VALUES ('10001', 'TrafostationUmspannwerk');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungVerEntsorgung" ("Code", "Bezeichner") VALUES ('10002', 'Solarkraftwerk');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungVerEntsorgung" ("Code", "Bezeichner") VALUES ('10003', 'Windkraftwerk');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungVerEntsorgung" ("Code", "Bezeichner") VALUES ('10004', 'Geothermiekraftwerk');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungVerEntsorgung" ("Code", "Bezeichner") VALUES ('10005', 'Elektrizitaetswerk');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungVerEntsorgung" ("Code", "Bezeichner") VALUES ('10006', 'Wasserkraftwerk');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungVerEntsorgung" ("Code", "Bezeichner") VALUES ('10007', 'BiomasseKraftwerk');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungVerEntsorgung" ("Code", "Bezeichner") VALUES ('10008', 'Kabelleitung');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungVerEntsorgung" ("Code", "Bezeichner") VALUES ('10009', 'Niederspannungsleitung');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungVerEntsorgung" ("Code", "Bezeichner") VALUES ('100010', 'Leitungsmast');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungVerEntsorgung" ("Code", "Bezeichner") VALUES ('12000', 'Ferngasleitung');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungVerEntsorgung" ("Code", "Bezeichner") VALUES ('12001', 'Gaswerk');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungVerEntsorgung" ("Code", "Bezeichner") VALUES ('12002', 'Gasbehaelter');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungVerEntsorgung" ("Code", "Bezeichner") VALUES ('12003', 'Gasdruckregler');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungVerEntsorgung" ("Code", "Bezeichner") VALUES ('12004', 'Gasstation');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungVerEntsorgung" ("Code", "Bezeichner") VALUES ('12005', 'Gasleitung');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungVerEntsorgung" ("Code", "Bezeichner") VALUES ('13000', 'Erdoelleitung');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungVerEntsorgung" ("Code", "Bezeichner") VALUES ('13001', 'Bohrstelle');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungVerEntsorgung" ("Code", "Bezeichner") VALUES ('13002', 'Erdoelpumpstation');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungVerEntsorgung" ("Code", "Bezeichner") VALUES ('13003', 'Oeltank');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungVerEntsorgung" ("Code", "Bezeichner") VALUES ('14000', 'Blockheizkraftwerk');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungVerEntsorgung" ("Code", "Bezeichner") VALUES ('14001', 'Fernwaermeleitung');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungVerEntsorgung" ("Code", "Bezeichner") VALUES ('14002', 'Fernheizwerk');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungVerEntsorgung" ("Code", "Bezeichner") VALUES ('16000', 'Wasserwerk');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungVerEntsorgung" ("Code", "Bezeichner") VALUES ('16001', 'Wasserleitung');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungVerEntsorgung" ("Code", "Bezeichner") VALUES ('16002', 'Wasserspeicher');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungVerEntsorgung" ("Code", "Bezeichner") VALUES ('16003', 'Brunnen');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungVerEntsorgung" ("Code", "Bezeichner") VALUES ('16004', 'Pumpwerk');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungVerEntsorgung" ("Code", "Bezeichner") VALUES ('16005', 'Quelle');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungVerEntsorgung" ("Code", "Bezeichner") VALUES ('18000', 'Abwasserleitung');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungVerEntsorgung" ("Code", "Bezeichner") VALUES ('18001', 'Abwasserrueckhaltebecken');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungVerEntsorgung" ("Code", "Bezeichner") VALUES ('18002', 'Abwasserpumpwerk');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungVerEntsorgung" ("Code", "Bezeichner") VALUES ('18003', 'Klaeranlage');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungVerEntsorgung" ("Code", "Bezeichner") VALUES ('18004', 'AnlageKlaerschlamm');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungVerEntsorgung" ("Code", "Bezeichner") VALUES ('18005', 'veraltet - SonstigeAbwasserBehandlungsanlage');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungVerEntsorgung" ("Code", "Bezeichner") VALUES ('18006', 'SalzOderSoleleitungen');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungVerEntsorgung" ("Code", "Bezeichner") VALUES ('20000', 'RegenwasserRueckhaltebecken');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungVerEntsorgung" ("Code", "Bezeichner") VALUES ('20001', 'Niederschlagswasserleitung');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungVerEntsorgung" ("Code", "Bezeichner") VALUES ('22000', 'Muellumladestation');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungVerEntsorgung" ("Code", "Bezeichner") VALUES ('22001', 'Muellbeseitigungsanlage');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungVerEntsorgung" ("Code", "Bezeichner") VALUES ('22002', 'Muellsortieranlage');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungVerEntsorgung" ("Code", "Bezeichner") VALUES ('22003', 'Recyclinghof');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungVerEntsorgung" ("Code", "Bezeichner") VALUES ('24000', 'Erdaushubdeponie');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungVerEntsorgung" ("Code", "Bezeichner") VALUES ('24001', 'Bauschuttdeponie');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungVerEntsorgung" ("Code", "Bezeichner") VALUES ('24002', 'Hausmuelldeponie');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungVerEntsorgung" ("Code", "Bezeichner") VALUES ('24003', 'Sondermuelldeponie');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungVerEntsorgung" ("Code", "Bezeichner") VALUES ('24004', 'StillgelegteDeponie');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungVerEntsorgung" ("Code", "Bezeichner") VALUES ('24005', 'RekultivierteDeponie');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungVerEntsorgung" ("Code", "Bezeichner") VALUES ('26000', 'Fernmeldeanlage');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungVerEntsorgung" ("Code", "Bezeichner") VALUES ('26001', 'Mobilfunkanlage');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungVerEntsorgung" ("Code", "Bezeichner") VALUES ('26002', 'Fernmeldekabel');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungVerEntsorgung" ("Code", "Bezeichner") VALUES ('28000', 'Windenergie');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungVerEntsorgung" ("Code", "Bezeichner") VALUES ('28001', 'Photovoltaik');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungVerEntsorgung" ("Code", "Bezeichner") VALUES ('28002', 'Biomasse');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungVerEntsorgung" ("Code", "Bezeichner") VALUES ('28003', 'Geothermie');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungVerEntsorgung" ("Code", "Bezeichner") VALUES ('28004', 'SonstErneuerbareEnergie');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungVerEntsorgung" ("Code", "Bezeichner") VALUES ('99990', 'Produktenleitung');

-- -----------------------------------------------------
-- Data for table "XP_Enumerationen"."XP_ZweckbestimmungGewaesser"
-- -----------------------------------------------------
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungGewaesser" ("Code", "Bezeichner") VALUES ('1000', 'Hafen');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungGewaesser" ("Code", "Bezeichner") VALUES ('10000', 'Sportboothafen');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungGewaesser" ("Code", "Bezeichner") VALUES ('1100', 'Wasserflaeche');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungGewaesser" ("Code", "Bezeichner") VALUES ('1200', 'Fliessgewaesser');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungGewaesser" ("Code", "Bezeichner") VALUES ('9999', 'Sonstiges');

-- -----------------------------------------------------
-- Data for table "XP_Enumerationen"."XP_ZweckbestimmungWasserwirtschaft"
-- -----------------------------------------------------
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungWasserwirtschaft" ("Code", "Bezeichner") VALUES ('1000', 'HochwasserRueckhaltebecken');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungWasserwirtschaft" ("Code", "Bezeichner") VALUES ('1100', 'Ueberschwemmgebiet');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungWasserwirtschaft" ("Code", "Bezeichner") VALUES ('1200', 'Versickerungsflaeche');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungWasserwirtschaft" ("Code", "Bezeichner") VALUES ('1300', 'Entwaesserungsgraben');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungWasserwirtschaft" ("Code", "Bezeichner") VALUES ('1400', 'Deich');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungWasserwirtschaft" ("Code", "Bezeichner") VALUES ('1500', 'RegenRueckhaltebecken');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungWasserwirtschaft" ("Code", "Bezeichner") VALUES ('9999', 'Sonstiges');

-- -----------------------------------------------------
-- Data for table "XP_Enumerationen"."XP_Bundeslaender"
-- -----------------------------------------------------
INSERT INTO "XP_Enumerationen"."XP_Bundeslaender" ("Code", "Bezeichner") VALUES ('1000', 'BB');
INSERT INTO "XP_Enumerationen"."XP_Bundeslaender" ("Code", "Bezeichner") VALUES ('1100', 'BE');
INSERT INTO "XP_Enumerationen"."XP_Bundeslaender" ("Code", "Bezeichner") VALUES ('1200', 'BW');
INSERT INTO "XP_Enumerationen"."XP_Bundeslaender" ("Code", "Bezeichner") VALUES ('1300', 'BY');
INSERT INTO "XP_Enumerationen"."XP_Bundeslaender" ("Code", "Bezeichner") VALUES ('1400', 'HB');
INSERT INTO "XP_Enumerationen"."XP_Bundeslaender" ("Code", "Bezeichner") VALUES ('1500', 'HE');
INSERT INTO "XP_Enumerationen"."XP_Bundeslaender" ("Code", "Bezeichner") VALUES ('1600', 'HH');
INSERT INTO "XP_Enumerationen"."XP_Bundeslaender" ("Code", "Bezeichner") VALUES ('1700', 'MV');
INSERT INTO "XP_Enumerationen"."XP_Bundeslaender" ("Code", "Bezeichner") VALUES ('1800', 'NI');
INSERT INTO "XP_Enumerationen"."XP_Bundeslaender" ("Code", "Bezeichner") VALUES ('1900', 'NW');
INSERT INTO "XP_Enumerationen"."XP_Bundeslaender" ("Code", "Bezeichner") VALUES ('2000', 'RP');
INSERT INTO "XP_Enumerationen"."XP_Bundeslaender" ("Code", "Bezeichner") VALUES ('2100', 'SH');
INSERT INTO "XP_Enumerationen"."XP_Bundeslaender" ("Code", "Bezeichner") VALUES ('2200', 'SL');
INSERT INTO "XP_Enumerationen"."XP_Bundeslaender" ("Code", "Bezeichner") VALUES ('2300', 'SN');
INSERT INTO "XP_Enumerationen"."XP_Bundeslaender" ("Code", "Bezeichner") VALUES ('2400', 'ST');
INSERT INTO "XP_Enumerationen"."XP_Bundeslaender" ("Code", "Bezeichner") VALUES ('2500', 'TH');
INSERT INTO "XP_Enumerationen"."XP_Bundeslaender" ("Code", "Bezeichner") VALUES ('3000', 'Bund');

-- -----------------------------------------------------
-- Data for table "XP_Basisobjekte"."XP_BedeutungenBereich"
-- -----------------------------------------------------
INSERT INTO "XP_Basisobjekte"."XP_BedeutungenBereich" ("Code", "Bezeichner") VALUES ('1600', 'Teilbereich');
INSERT INTO "XP_Basisobjekte"."XP_BedeutungenBereich" ("Code", "Bezeichner") VALUES ('1800', 'Kompensationsbereich');
INSERT INTO "XP_Basisobjekte"."XP_BedeutungenBereich" ("Code", "Bezeichner") VALUES ('9999', 'Sonstiges');

-- -----------------------------------------------------
-- Data for table "XP_Basisobjekte"."XP_MimeTypes"
-- -----------------------------------------------------
INSERT INTO "XP_Basisobjekte"."XP_MimeTypes" ("Code", "Bezeichner") VALUES ('application/pdf', 'application/pdf');
INSERT INTO "XP_Basisobjekte"."XP_MimeTypes" ("Code", "Bezeichner") VALUES ('application/zip', 'application/zip');
INSERT INTO "XP_Basisobjekte"."XP_MimeTypes" ("Code", "Bezeichner") VALUES ('application/xml', 'application/xml');
INSERT INTO "XP_Basisobjekte"."XP_MimeTypes" ("Code", "Bezeichner") VALUES ('application/msword', 'application/msword');
INSERT INTO "XP_Basisobjekte"."XP_MimeTypes" ("Code", "Bezeichner") VALUES ('application/msexcel', 'application/msexcel');
INSERT INTO "XP_Basisobjekte"."XP_MimeTypes" ("Code", "Bezeichner") VALUES ('application/vnd.ogc.sld+xml', 'application/vnd.ogc.sld+xml');
INSERT INTO "XP_Basisobjekte"."XP_MimeTypes" ("Code", "Bezeichner") VALUES ('application/vnd.ogc.wms_xml', 'application/vnd.ogc.wms_xml');
INSERT INTO "XP_Basisobjekte"."XP_MimeTypes" ("Code", "Bezeichner") VALUES ('application/vnd.ogc.gml', 'application/vnd.ogc.gml');
INSERT INTO "XP_Basisobjekte"."XP_MimeTypes" ("Code", "Bezeichner") VALUES ('application/odt', 'application/odt');
INSERT INTO "XP_Basisobjekte"."XP_MimeTypes" ("Code", "Bezeichner") VALUES ('image/jpg', 'image/jpg');
INSERT INTO "XP_Basisobjekte"."XP_MimeTypes" ("Code", "Bezeichner") VALUES ('image/png', 'image/png');
INSERT INTO "XP_Basisobjekte"."XP_MimeTypes" ("Code", "Bezeichner") VALUES ('image/tiff', 'image/tiff');
INSERT INTO "XP_Basisobjekte"."XP_MimeTypes" ("Code", "Bezeichner") VALUES ('image/ecw', 'image/ecw');
INSERT INTO "XP_Basisobjekte"."XP_MimeTypes" ("Code", "Bezeichner") VALUES ('image/svg+xml', 'image/svg+xml');
INSERT INTO "XP_Basisobjekte"."XP_MimeTypes" ("Code", "Bezeichner") VALUES ('text/html', 'text/html');
INSERT INTO "XP_Basisobjekte"."XP_MimeTypes" ("Code", "Bezeichner") VALUES ('text/plain', 'text/plain');

-- -----------------------------------------------------
-- Data for table "XP_Basisobjekte"."XP_ExterneReferenzArt"
-- -----------------------------------------------------
INSERT INTO "XP_Basisobjekte"."XP_ExterneReferenzArt" ("Code", "Bezeichner") VALUES ('Dokument', 'Dokument');
INSERT INTO "XP_Basisobjekte"."XP_ExterneReferenzArt" ("Code", "Bezeichner") VALUES ('PlanMitGeoreferenz', 'PlanMitGeoreferenz');

-- -----------------------------------------------------
-- Data for table "XP_Basisobjekte"."XP_ExterneReferenzTyp"
-- -----------------------------------------------------
INSERT INTO "XP_Basisobjekte"."XP_ExterneReferenzTyp" ("Code", "Bezeichner") VALUES (1000, 'Beschreibung');
INSERT INTO "XP_Basisobjekte"."XP_ExterneReferenzTyp" ("Code", "Bezeichner") VALUES (1010, 'Begruendung');
INSERT INTO "XP_Basisobjekte"."XP_ExterneReferenzTyp" ("Code", "Bezeichner") VALUES (1020, 'Legende');
INSERT INTO "XP_Basisobjekte"."XP_ExterneReferenzTyp" ("Code", "Bezeichner") VALUES (1030, 'Rechtsplan');
INSERT INTO "XP_Basisobjekte"."XP_ExterneReferenzTyp" ("Code", "Bezeichner") VALUES (1040, 'Plangrundlage');
INSERT INTO "XP_Basisobjekte"."XP_ExterneReferenzTyp" ("Code", "Bezeichner") VALUES (1050, 'Umweltbericht');
INSERT INTO "XP_Basisobjekte"."XP_ExterneReferenzTyp" ("Code", "Bezeichner") VALUES (1060, 'Satzung');
INSERT INTO "XP_Basisobjekte"."XP_ExterneReferenzTyp" ("Code", "Bezeichner") VALUES (1065, 'Verordnung');
INSERT INTO "XP_Basisobjekte"."XP_ExterneReferenzTyp" ("Code", "Bezeichner") VALUES (1070, 'Karte');
INSERT INTO "XP_Basisobjekte"."XP_ExterneReferenzTyp" ("Code", "Bezeichner") VALUES (1080, 'Erlaeuterung');
INSERT INTO "XP_Basisobjekte"."XP_ExterneReferenzTyp" ("Code", "Bezeichner") VALUES (1090, 'ZusammenfassendeErklaerung');
INSERT INTO "XP_Basisobjekte"."XP_ExterneReferenzTyp" ("Code", "Bezeichner") VALUES (2000, 'Koordinatenliste');
INSERT INTO "XP_Basisobjekte"."XP_ExterneReferenzTyp" ("Code", "Bezeichner") VALUES (2100, 'Grundstuecksverzeichnis');
INSERT INTO "XP_Basisobjekte"."XP_ExterneReferenzTyp" ("Code", "Bezeichner") VALUES (2200, 'Pflanzliste');
INSERT INTO "XP_Basisobjekte"."XP_ExterneReferenzTyp" ("Code", "Bezeichner") VALUES (2300, 'Gruenordnungsplan');
INSERT INTO "XP_Basisobjekte"."XP_ExterneReferenzTyp" ("Code", "Bezeichner") VALUES (2400, 'Erschliessungsvertrag');
INSERT INTO "XP_Basisobjekte"."XP_ExterneReferenzTyp" ("Code", "Bezeichner") VALUES (2500, 'Durchfuehrungsvertrag');
INSERT INTO "XP_Basisobjekte"."XP_ExterneReferenzTyp" ("Code", "Bezeichner") VALUES (2600, 'StaedtebaulicherVertrag');
INSERT INTO "XP_Basisobjekte"."XP_ExterneReferenzTyp" ("Code", "Bezeichner") VALUES (2700, 'UmweltbezogeneStellungnahmen');
INSERT INTO "XP_Basisobjekte"."XP_ExterneReferenzTyp" ("Code", "Bezeichner") VALUES (2800, 'Beschluss');
INSERT INTO "XP_Basisobjekte"."XP_ExterneReferenzTyp" ("Code", "Bezeichner") VALUES (2900, 'VorhabenUndErschliessungsplan');
INSERT INTO "XP_Basisobjekte"."XP_ExterneReferenzTyp" ("Code", "Bezeichner") VALUES (3000, 'MetadatenPlan');
INSERT INTO "XP_Basisobjekte"."XP_ExterneReferenzTyp" ("Code", "Bezeichner") VALUES (4000, 'Genehmigung');
INSERT INTO "XP_Basisobjekte"."XP_ExterneReferenzTyp" ("Code", "Bezeichner") VALUES (5000, 'Bekanntmachung');
INSERT INTO "XP_Basisobjekte"."XP_ExterneReferenzTyp" ("Code", "Bezeichner") VALUES (9998, 'Rechtsverbindlich');
INSERT INTO "XP_Basisobjekte"."XP_ExterneReferenzTyp" ("Code", "Bezeichner") VALUES (9999, 'Informell');

-- -----------------------------------------------------
-- Data for table "XP_Basisobjekte"."XP_RechtscharakterPlanaenderung"
-- -----------------------------------------------------
INSERT INTO "XP_Basisobjekte"."XP_RechtscharakterPlanaenderung" ("Code", "Bezeichner") VALUES ('1000', 'Aenderung');
INSERT INTO "XP_Basisobjekte"."XP_RechtscharakterPlanaenderung" ("Code", "Bezeichner") VALUES ('1100', 'Ergaenzung');
INSERT INTO "XP_Basisobjekte"."XP_RechtscharakterPlanaenderung" ("Code", "Bezeichner") VALUES ('2000', 'Aufhebung');

-- -----------------------------------------------------
-- Data for table "XP_Praesentationsobjekte"."XP_VertikaleAusrichtung"
-- -----------------------------------------------------
INSERT INTO "XP_Praesentationsobjekte"."XP_VertikaleAusrichtung" ("Code", "Bezeichner") VALUES ('Basis', 'Basis');
INSERT INTO "XP_Praesentationsobjekte"."XP_VertikaleAusrichtung" ("Code", "Bezeichner") VALUES ('Mitte', 'Mitte');
INSERT INTO "XP_Praesentationsobjekte"."XP_VertikaleAusrichtung" ("Code", "Bezeichner") VALUES ('Oben', 'Oben');

-- -----------------------------------------------------
-- Data for table "XP_Praesentationsobjekte"."XP_HorizontaleAusrichtung"
-- -----------------------------------------------------
INSERT INTO "XP_Praesentationsobjekte"."XP_HorizontaleAusrichtung" ("Code", "Bezeichner") VALUES ('linksbündig', 'linksbündig');
INSERT INTO "XP_Praesentationsobjekte"."XP_HorizontaleAusrichtung" ("Code", "Bezeichner") VALUES ('rechtsbündig', 'rechtsbündig');
INSERT INTO "XP_Praesentationsobjekte"."XP_HorizontaleAusrichtung" ("Code", "Bezeichner") VALUES ('zentrisch', 'zentrisch');

-- -----------------------------------------------------
-- Data for table "XP_Basisobjekte"."XP_SPEMassnahmenTypen"
-- -----------------------------------------------------
INSERT INTO "XP_Basisobjekte"."XP_SPEMassnahmenTypen" ("Code", "Bezeichner") VALUES ('1000', 'ArtentreicherGehoelzbestand');
INSERT INTO "XP_Basisobjekte"."XP_SPEMassnahmenTypen" ("Code", "Bezeichner") VALUES ('1100', 'NaturnaherWald');
INSERT INTO "XP_Basisobjekte"."XP_SPEMassnahmenTypen" ("Code", "Bezeichner") VALUES ('1200', 'ExtensivesGruenland');
INSERT INTO "XP_Basisobjekte"."XP_SPEMassnahmenTypen" ("Code", "Bezeichner") VALUES ('1300', 'Feuchtgruenland');
INSERT INTO "XP_Basisobjekte"."XP_SPEMassnahmenTypen" ("Code", "Bezeichner") VALUES ('1400', 'Obstwiese');
INSERT INTO "XP_Basisobjekte"."XP_SPEMassnahmenTypen" ("Code", "Bezeichner") VALUES ('1500', 'NaturnaherUferbereich');
INSERT INTO "XP_Basisobjekte"."XP_SPEMassnahmenTypen" ("Code", "Bezeichner") VALUES ('1600', 'Roehrichtzone');
INSERT INTO "XP_Basisobjekte"."XP_SPEMassnahmenTypen" ("Code", "Bezeichner") VALUES ('1700', 'Ackerrandstreifen');
INSERT INTO "XP_Basisobjekte"."XP_SPEMassnahmenTypen" ("Code", "Bezeichner") VALUES ('1800', 'Ackerbrache');
INSERT INTO "XP_Basisobjekte"."XP_SPEMassnahmenTypen" ("Code", "Bezeichner") VALUES ('1900', 'Gruenlandbrache');
INSERT INTO "XP_Basisobjekte"."XP_SPEMassnahmenTypen" ("Code", "Bezeichner") VALUES ('2000', 'Sukzessionsflaeche');
INSERT INTO "XP_Basisobjekte"."XP_SPEMassnahmenTypen" ("Code", "Bezeichner") VALUES ('2100', 'Hochstaudenflur');
INSERT INTO "XP_Basisobjekte"."XP_SPEMassnahmenTypen" ("Code", "Bezeichner") VALUES ('2200', 'Trockenrasen');
INSERT INTO "XP_Basisobjekte"."XP_SPEMassnahmenTypen" ("Code", "Bezeichner") VALUES ('2300', 'Heide');
INSERT INTO "XP_Basisobjekte"."XP_SPEMassnahmenTypen" ("Code", "Bezeichner") VALUES ('9999', 'Sonstiges');

-- -----------------------------------------------------
-- Data for table "XP_Enumerationen"."XP_SPEZiele"
-- -----------------------------------------------------
INSERT INTO "XP_Enumerationen"."XP_SPEZiele" ("Code", "Bezeichner") VALUES ('1000', 'SchutzPflege');
INSERT INTO "XP_Enumerationen"."XP_SPEZiele" ("Code", "Bezeichner") VALUES ('2000', 'Entwicklung');
INSERT INTO "XP_Enumerationen"."XP_SPEZiele" ("Code", "Bezeichner") VALUES ('3000', 'Anlage');
INSERT INTO "XP_Enumerationen"."XP_SPEZiele" ("Code", "Bezeichner") VALUES ('4000', 'SchutzPflegeEntwicklung');
INSERT INTO "XP_Enumerationen"."XP_SPEZiele" ("Code", "Bezeichner") VALUES ('9999', 'Sonstiges');

-- -----------------------------------------------------
-- Data for table "XP_Enumerationen"."XP_ABEMassnahmenTypen"
-- -----------------------------------------------------
INSERT INTO "XP_Enumerationen"."XP_ABEMassnahmenTypen" ("Code", "Bezeichner") VALUES ('1000', 'BindungErhaltung');
INSERT INTO "XP_Enumerationen"."XP_ABEMassnahmenTypen" ("Code", "Bezeichner") VALUES ('2000', 'Anpflanzung');
INSERT INTO "XP_Enumerationen"."XP_ABEMassnahmenTypen" ("Code", "Bezeichner") VALUES ('3000', 'AnpflanzungBindungErhaltung');

-- -----------------------------------------------------
-- Data for table "XP_Enumerationen"."XP_AnpflanzungBindungErhaltungsGegenstand"
-- -----------------------------------------------------
INSERT INTO "XP_Enumerationen"."XP_AnpflanzungBindungErhaltungsGegenstand" ("Code", "Bezeichner") VALUES ('1000', 'Baeume');
INSERT INTO "XP_Enumerationen"."XP_AnpflanzungBindungErhaltungsGegenstand" ("Code", "Bezeichner") VALUES ('1100', 'Kopfbaeume');
INSERT INTO "XP_Enumerationen"."XP_AnpflanzungBindungErhaltungsGegenstand" ("Code", "Bezeichner") VALUES ('1200', 'Baumreihe');
INSERT INTO "XP_Enumerationen"."XP_AnpflanzungBindungErhaltungsGegenstand" ("Code", "Bezeichner") VALUES ('2000', 'Straeucher');
INSERT INTO "XP_Enumerationen"."XP_AnpflanzungBindungErhaltungsGegenstand" ("Code", "Bezeichner") VALUES ('2050', 'BaeumeUndStraeucher');
INSERT INTO "XP_Enumerationen"."XP_AnpflanzungBindungErhaltungsGegenstand" ("Code", "Bezeichner") VALUES ('2100', 'Hecke');
INSERT INTO "XP_Enumerationen"."XP_AnpflanzungBindungErhaltungsGegenstand" ("Code", "Bezeichner") VALUES ('2200', 'Knick');
INSERT INTO "XP_Enumerationen"."XP_AnpflanzungBindungErhaltungsGegenstand" ("Code", "Bezeichner") VALUES ('3000', 'SonstBepflanzung');
INSERT INTO "XP_Enumerationen"."XP_AnpflanzungBindungErhaltungsGegenstand" ("Code", "Bezeichner") VALUES ('4000', 'Gewaesser');
INSERT INTO "XP_Enumerationen"."XP_AnpflanzungBindungErhaltungsGegenstand" ("Code", "Bezeichner") VALUES ('5000', 'Fassadenbegruenung');
INSERT INTO "XP_Enumerationen"."XP_AnpflanzungBindungErhaltungsGegenstand" ("Code", "Bezeichner") VALUES ('6000', 'Dachbegruenung');

-- -----------------------------------------------------
-- Data for table "XP_Sonstiges"."XP_ArtHoehenbezug"
-- -----------------------------------------------------
INSERT INTO "XP_Sonstiges"."XP_ArtHoehenbezug" ("Code", "Bezeichner") VALUES ('1000', 'absolutNHN');
INSERT INTO "XP_Sonstiges"."XP_ArtHoehenbezug" ("Code", "Bezeichner") VALUES ('1100', 'absolutNN');
INSERT INTO "XP_Sonstiges"."XP_ArtHoehenbezug" ("Code", "Bezeichner") VALUES ('1200', 'absolutDHHN');
INSERT INTO "XP_Sonstiges"."XP_ArtHoehenbezug" ("Code", "Bezeichner") VALUES ('2000', 'relativGelaendeoberkante');
INSERT INTO "XP_Sonstiges"."XP_ArtHoehenbezug" ("Code", "Bezeichner") VALUES ('2500', 'relativGehwegOberkante');
INSERT INTO "XP_Sonstiges"."XP_ArtHoehenbezug" ("Code", "Bezeichner") VALUES ('3000', 'relativBezugshoehe');

-- -----------------------------------------------------
-- Data for table "XP_Sonstiges"."XP_ArtHoehenbezugspunkt"
-- -----------------------------------------------------
INSERT INTO "XP_Sonstiges"."XP_ArtHoehenbezugspunkt" ("Code", "Bezeichner") VALUES ('1000', 'TH');
INSERT INTO "XP_Sonstiges"."XP_ArtHoehenbezugspunkt" ("Code", "Bezeichner") VALUES ('2000', 'FH');
INSERT INTO "XP_Sonstiges"."XP_ArtHoehenbezugspunkt" ("Code", "Bezeichner") VALUES ('3000', 'OK');
INSERT INTO "XP_Sonstiges"."XP_ArtHoehenbezugspunkt" ("Code", "Bezeichner") VALUES ('3500', 'LH');
INSERT INTO "XP_Sonstiges"."XP_ArtHoehenbezugspunkt" ("Code", "Bezeichner") VALUES ('4000', 'SH');
INSERT INTO "XP_Sonstiges"."XP_ArtHoehenbezugspunkt" ("Code", "Bezeichner") VALUES ('4500', 'EFH');
INSERT INTO "XP_Sonstiges"."XP_ArtHoehenbezugspunkt" ("Code", "Bezeichner") VALUES ('5000', 'HBA');
INSERT INTO "XP_Sonstiges"."XP_ArtHoehenbezugspunkt" ("Code", "Bezeichner") VALUES ('5500', 'UK');
INSERT INTO "XP_Sonstiges"."XP_ArtHoehenbezugspunkt" ("Code", "Bezeichner") VALUES ('6000', 'GBH');
INSERT INTO "XP_Sonstiges"."XP_ArtHoehenbezugspunkt" ("Code", "Bezeichner") VALUES ('6500', 'WH');

-- -----------------------------------------------------
-- Data for table "XP_Enumerationen"."XP_KlassifizSchutzgebietNaturschutzrecht"
-- -----------------------------------------------------
INSERT INTO "XP_Enumerationen"."XP_KlassifizSchutzgebietNaturschutzrecht" ("Code", "Bezeichner") VALUES (1000, 'Naturschutzgebiet');
INSERT INTO "XP_Enumerationen"."XP_KlassifizSchutzgebietNaturschutzrecht" ("Code", "Bezeichner") VALUES (1100, 'Nationalpark');
INSERT INTO "XP_Enumerationen"."XP_KlassifizSchutzgebietNaturschutzrecht" ("Code", "Bezeichner") VALUES (1200, 'Biosphaerenreservat');
INSERT INTO "XP_Enumerationen"."XP_KlassifizSchutzgebietNaturschutzrecht" ("Code", "Bezeichner") VALUES (1300, 'Landschaftsschutzgebiet');
INSERT INTO "XP_Enumerationen"."XP_KlassifizSchutzgebietNaturschutzrecht" ("Code", "Bezeichner") VALUES (1400, 'Naturpark');
INSERT INTO "XP_Enumerationen"."XP_KlassifizSchutzgebietNaturschutzrecht" ("Code", "Bezeichner") VALUES (1500, 'Naturdenkmal');
INSERT INTO "XP_Enumerationen"."XP_KlassifizSchutzgebietNaturschutzrecht" ("Code", "Bezeichner") VALUES (1600, 'GeschuetzterLandschaftsBestandteil');
INSERT INTO "XP_Enumerationen"."XP_KlassifizSchutzgebietNaturschutzrecht" ("Code", "Bezeichner") VALUES (1700, 'GesetzlichGeschuetztesBiotop');
INSERT INTO "XP_Enumerationen"."XP_KlassifizSchutzgebietNaturschutzrecht" ("Code", "Bezeichner") VALUES (1800, 'Natura2000');
INSERT INTO "XP_Enumerationen"."XP_KlassifizSchutzgebietNaturschutzrecht" ("Code", "Bezeichner") VALUES (18000, 'GebietGemeinschaftlicherBedeutung');
INSERT INTO "XP_Enumerationen"."XP_KlassifizSchutzgebietNaturschutzrecht" ("Code", "Bezeichner") VALUES (18001, 'EuropaeischesVogelschutzgebiet');
INSERT INTO "XP_Enumerationen"."XP_KlassifizSchutzgebietNaturschutzrecht" ("Code", "Bezeichner") VALUES (2000, 'NationalesNaturmonument');
INSERT INTO "XP_Enumerationen"."XP_KlassifizSchutzgebietNaturschutzrecht" ("Code", "Bezeichner") VALUES (9999, 'Sonstiges');

-- -----------------------------------------------------
-- Data for table "XP_Enumerationen"."XP_GrenzeTypen"
-- -----------------------------------------------------
INSERT INTO "XP_Enumerationen"."XP_GrenzeTypen" ("Code", "Bezeichner") VALUES (1000, 'Bundesgrenze');
INSERT INTO "XP_Enumerationen"."XP_GrenzeTypen" ("Code", "Bezeichner") VALUES (1100, 'Landesgrenze');
INSERT INTO "XP_Enumerationen"."XP_GrenzeTypen" ("Code", "Bezeichner") VALUES (1200, 'Regierungsbezirksgrenze');
INSERT INTO "XP_Enumerationen"."XP_GrenzeTypen" ("Code", "Bezeichner") VALUES (1250, 'Bezirksgrenze');
INSERT INTO "XP_Enumerationen"."XP_GrenzeTypen" ("Code", "Bezeichner") VALUES (1300, 'Kreisgrenze');
INSERT INTO "XP_Enumerationen"."XP_GrenzeTypen" ("Code", "Bezeichner") VALUES (1400, 'Gemeindegrenze');
INSERT INTO "XP_Enumerationen"."XP_GrenzeTypen" ("Code", "Bezeichner") VALUES (1450, 'Verbandsgemeindegrenze');
INSERT INTO "XP_Enumerationen"."XP_GrenzeTypen" ("Code", "Bezeichner") VALUES (1500, 'Samtgemeindegrenze');
INSERT INTO "XP_Enumerationen"."XP_GrenzeTypen" ("Code", "Bezeichner") VALUES (1510, 'Mitgliedsgemeindegrenze');
INSERT INTO "XP_Enumerationen"."XP_GrenzeTypen" ("Code", "Bezeichner") VALUES (1550, 'Amtsgrenze');
INSERT INTO "XP_Enumerationen"."XP_GrenzeTypen" ("Code", "Bezeichner") VALUES (1600, 'Stadtteilgrenze');
INSERT INTO "XP_Enumerationen"."XP_GrenzeTypen" ("Code", "Bezeichner") VALUES (2000, 'VorgeschlageneGrundstuecksgrenze');
INSERT INTO "XP_Enumerationen"."XP_GrenzeTypen" ("Code", "Bezeichner") VALUES (2100, 'GrenzeBestehenderBebauungsplan');
INSERT INTO "XP_Enumerationen"."XP_GrenzeTypen" ("Code", "Bezeichner") VALUES (9999, 'SonstGrenze');
