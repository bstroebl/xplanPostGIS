-- Dieses Skript ist auszuführen, um eine XPlan-5.0.1-Datenbank für den Import von Plänen zu befähigen, in XPlan 5.1-Datenbanken ist die Funktionalität bereits enthalten

-- neue Funktionen
CREATE OR REPLACE FUNCTION "QGIS"."imp_create_xp_gid"(nspname character varying, relname character varying)
  RETURNS integer AS
$BODY$
BEGIN
    EXECUTE 'ALTER TABLE ' ||
        quote_ident(nspname) || '.' || quote_ident(relname) || 
        ' ADD COLUMN IF NOT EXISTS xp_gid bigint;';
    RETURN 1;
END;
$BODY$
LANGUAGE plpgsql VOLATILE STRICT
COST 100;
GRANT EXECUTE ON FUNCTION "QGIS"."imp_create_xp_gid"(character varying, character varying) TO xp_user;
COMMENT ON FUNCTION "QGIS"."imp_create_xp_gid"(character varying, character varying) IS 'Legt in der übergebenen Tabelle ein bigint-Feld xp_gid an; Funktion ist nötig, da der ALTER TABLE-Befehl aus QGIS selbst über QtSql nicht geht :-(';

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

-- Umdefinition vorhandener Triggerfunktionen
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

CREATE OR REPLACE FUNCTION "XP_Basisobjekte"."child_of_XP_Plan"()
RETURNS trigger AS
$BODY$
DECLARE
    num_parents integer;
 BEGIN
    IF (TG_OP = 'INSERT') THEN
        IF new.name IS NULL THEN
             new.name := 'XP_Plan ' || CAST(new.gid as varchar);
        END IF;

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

CREATE OR REPLACE FUNCTION "XP_Basisobjekte"."child_of_XP_Bereich"()
RETURNS trigger AS
$BODY$
DECLARE
    num_parents integer;
 BEGIN
    IF (TG_OP = 'INSERT') THEN
        IF new.name IS NULL THEN
            new.name := 'XP_Bereich ' || CAST(new.gid as varchar);
        END IF;

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

        RETURN new;
    ELSIF (TG_OP = 'DELETE') THEN
        DELETE FROM "XP_Basisobjekte"."XP_Bereich" WHERE gid = old.gid;
        RETURN old;
    END IF;
 END; $BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
GRANT EXECUTE ON FUNCTION "XP_Basisobjekte"."child_of_XP_Bereich"() TO xp_user;

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

-- Ergänzen des Feldes gml_id in bestehenden Basistabellen
ALTER TABLE "XP_Basisobjekte"."XP_ExterneReferenz" ADD COLUMN "gml_id" VARCHAR(64);
COMMENT ON COLUMN "XP_Basisobjekte"."XP_ExterneReferenz"."gml_id" IS 'Eindeutiger Identifier des Objektes für Im- und Export.';
CREATE TRIGGER "XP_ExterneReferenz_gml_id" BEFORE INSERT ON "XP_Basisobjekte"."XP_ExterneReferenz" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."create_gml_id"();
ALTER TABLE "XP_Basisobjekte"."XP_Plan" ADD COLUMN "gml_id" VARCHAR(64);
COMMENT ON COLUMN "XP_Basisobjekte"."XP_Plan"."gml_id" IS 'Eindeutiger Identifier des Objektes für Im- und Export.';
CREATE TRIGGER "XP_Plan_gml_id" BEFORE INSERT ON "XP_Basisobjekte"."XP_Plan" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."create_gml_id"();
ALTER TABLE "XP_Basisobjekte"."XP_Bereich" ADD COLUMN "gml_id" VARCHAR(64);
COMMENT ON COLUMN "XP_Basisobjekte"."XP_Bereich"."gml_id" IS 'Eindeutiger Identifier des Objektes für Im- und Export.';
CREATE TRIGGER "XP_Bereich_gml_id" BEFORE INSERT ON "XP_Basisobjekte"."XP_Bereich" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."create_gml_id"();
ALTER TABLE "XP_Basisobjekte"."XP_Objekt" ADD COLUMN "gml_id" VARCHAR(64);
COMMENT ON COLUMN "XP_Basisobjekte"."XP_Objekt"."gml_id" IS 'Eindeutiger Identifier des Objektes für Im- und Export.';
CREATE TRIGGER "XP_Objekt_gml_id" BEFORE INSERT ON "XP_Basisobjekte"."XP_Objekt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."create_gml_id"();
ALTER TABLE "XP_Basisobjekte"."XP_TextAbschnitt" ADD COLUMN "gml_id" VARCHAR(64);
COMMENT ON COLUMN "XP_Basisobjekte"."XP_TextAbschnitt"."gml_id" IS 'Eindeutiger Identifier des Objektes für Im- und Export.';
CREATE TRIGGER "XP_TextAbschnitt_gml_id" BEFORE INSERT ON "XP_Basisobjekte"."XP_TextAbschnitt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."create_gml_id"();
ALTER TABLE "XP_Praesentationsobjekte"."XP_AbstraktesPraesentationsobjekt" ADD COLUMN "gml_id" VARCHAR(64);
COMMENT ON COLUMN "XP_Praesentationsobjekte"."XP_AbstraktesPraesentationsobjekt"."gml_id" IS 'Eindeutiger Identifier des Objektes für Im- und Export.';
CREATE TRIGGER "XP_AbstraktesPraesentationsobjekt_gml_id" BEFORE INSERT ON "XP_Praesentationsobjekte"."XP_AbstraktesPraesentationsobjekt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."create_gml_id"();