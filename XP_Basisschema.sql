-- -----------------------------------------------------
-- XP__Basisschema
-- Das XPLanGML Basisschema enthält abstrakte Oberklassen, von denen alle Klassen der Fachschemata abgeleitet sind, sowie allgemeine Feature-Types, DataTypes und Enumerationen, die in verschiedenen Fach-Schemata verwendet werden.
-- -----------------------------------------------------

-- *****************************************************
-- CREATE GROUP ROLES
-- *****************************************************

-- Lesende Rolle
CREATE ROLE xp_gast
  NOSUPERUSER NOINHERIT NOCREATEDB NOCREATEROLE;

-- allgemein editierende Rolle, spezielle editierende Rollen werden in den jeweiligen Objektbereichen erzeugt
CREATE ROLE xp_user
  NOSUPERUSER NOINHERIT NOCREATEDB NOCREATEROLE;
GRANT xp_gast TO xp_user;

-- *****************************************************
-- CREATE SCHEMAS
-- *****************************************************

CREATE SCHEMA "XP_Basisobjekte";
CREATE SCHEMA "XP_Sonstiges";
CREATE SCHEMA "XP_Praesentationsobjekte";
CREATE SCHEMA "XP_Enumerationen";
CREATE SCHEMA "XP_Raster";
CREATE SCHEMA "SO_Schutzgebiete";

COMMENT ON SCHEMA "XP_Basisobjekte" IS 'Dieses Paket enthält die Basisklassen des XPlanGML Schemas.';
COMMENT ON SCHEMA "XP_Sonstiges" IS 'Allegemeine Datentypen.';
COMMENT ON SCHEMA "XP_Praesentationsobjekte" IS 'Das Paket Praesentationsobjekte modelliert Klassen, die lediglich der graphischen Ausgestaltung eines Plans dienen und selbst keine eigentlichen Plan-Inhalte repräsentieren. Die entsprechenden Fachobjekte können unmittelbar instanziiert werden.';
COMMENT ON SCHEMA "XP_Enumerationen" IS 'Dieses Paket enthält verschiedene Enumerationen, die Fachschema-übergreifend verwwendet werden';
COMMENT ON SCHEMA "XP_Raster" IS 'Dieses Paket enthält Basisklassen für die Rasterdarstellung von Bebauungsplänen, Flächennutzungsplänen, Landschafts- und Regionalplänen.';
COMMENT ON SCHEMA "SO_Schutzgebiete" IS 'Objektbereich SonstigePlanwerke: Fachschema zur Modellierung nachrichtlicher Übernahmen aus anderen Rechtsbereichen und sonstiger raumbezogener Pläne nach BauGB.
SO_Schutzgebiete: Schutzgebiete nach verschiedenen gesetzlichen Bestimmungen.';

GRANT USAGE ON SCHEMA "XP_Basisobjekte" TO xp_gast;
GRANT USAGE ON SCHEMA "XP_Sonstiges" TO xp_gast;
GRANT USAGE ON SCHEMA "XP_Praesentationsobjekte" TO xp_gast;
GRANT USAGE ON SCHEMA "XP_Enumerationen" TO xp_gast;
GRANT USAGE ON SCHEMA "XP_Raster" TO xp_gast;
GRANT USAGE ON SCHEMA "SO_Schutzgebiete" TO xp_gast;

-- *****************************************************
-- CREATE FUNCTIONs
-- *****************************************************

-- needs Python 2.5 or higher
CREATE OR REPLACE FUNCTION "XP_Basisobjekte".create_uuid()
  RETURNS character varying AS
$BODY$
	import uuid
	return uuid.uuid1()
$BODY$
  LANGUAGE 'plpythonu' VOLATILE
  COST 100;
GRANT EXECUTE ON FUNCTION "XP_Basisobjekte".create_uuid() TO xp_user;

CREATE OR REPLACE FUNCTION "XP_Basisobjekte"."gehoertZuPlan"(nspname character varying, relname character varying, gid integer)
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
GRANT EXECUTE ON FUNCTION "XP_Basisobjekte"."gehoertZuPlan"(character varying, character varying, integer) TO xp_user;
COMMENT ON FUNCTION "XP_Basisobjekte"."gehoertZuPlan"(character varying, character varying, integer) IS 'Gibt die gid des XP_Plans, zu dem ein XP_Bereich gehoert zurück';

CREATE OR REPLACE FUNCTION "XP_Basisobjekte"."XP_PO_artvalue"(nspname character varying, relname character varying, art character varying, gid integer)
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
GRANT EXECUTE ON FUNCTION "XP_Basisobjekte"."XP_PO_artvalue"(character varying, character varying, character varying, integer) TO xp_user;
COMMENT ON FUNCTION "XP_Basisobjekte"."XP_PO_artvalue"(character varying, character varying, character varying, integer) IS 'gibt den Wert für das Feld art für gid in der relation nspname.relname aus';

CREATE OR REPLACE FUNCTION "XP_Basisobjekte"."registergeometrycolumn"(character varying, character varying, character varying, character varying, character varying, integer)
  RETURNS text AS
$BODY$
DECLARE
	catalog_name alias for $1;
	schema_name alias for $2;
	table_name alias for $3;
	column_name alias for $4;
	new_type alias for $5;
	new_dim alias for $6;
    is_table boolean;
    not_null boolean;
    new_srid integer;
	rec RECORD;
	sr varchar;
	real_schema name;
	sql text;

BEGIN
    new_srid := 3397; --EPSG-code des räumlichen Referenzsystems hier ändern
	-- Verify geometry type
	IF ( NOT ( (new_type = 'GEOMETRY') OR
			   (new_type = 'GEOMETRYCOLLECTION') OR
			   (new_type = 'POINT') OR
			   (new_type = 'MULTIPOINT') OR
			   (new_type = 'POLYGON') OR
			   (new_type = 'MULTIPOLYGON') OR
			   (new_type = 'LINESTRING') OR
			   (new_type = 'MULTILINESTRING') OR
			   (new_type = 'GEOMETRYCOLLECTIONM') OR
			   (new_type = 'POINTM') OR
			   (new_type = 'MULTIPOINTM') OR
			   (new_type = 'POLYGONM') OR
			   (new_type = 'MULTIPOLYGONM') OR
			   (new_type = 'LINESTRINGM') OR
			   (new_type = 'MULTILINESTRINGM') OR
			   (new_type = 'CIRCULARSTRING') OR
			   (new_type = 'CIRCULARSTRINGM') OR
			   (new_type = 'COMPOUNDCURVE') OR
			   (new_type = 'COMPOUNDCURVEM') OR
			   (new_type = 'CURVEPOLYGON') OR
			   (new_type = 'CURVEPOLYGONM') OR
			   (new_type = 'MULTICURVE') OR
			   (new_type = 'MULTICURVEM') OR
			   (new_type = 'MULTISURFACE') OR
			   (new_type = 'MULTISURFACEM')) )
	THEN
		RAISE EXCEPTION 'Invalid type name - valid ones are:
	POINT, MULTIPOINT,
	LINESTRING, MULTILINESTRING,
	POLYGON, MULTIPOLYGON,
	CIRCULARSTRING, COMPOUNDCURVE, MULTICURVE,
	CURVEPOLYGON, MULTISURFACE,
	GEOMETRY, GEOMETRYCOLLECTION,
	POINTM, MULTIPOINTM,
	LINESTRINGM, MULTILINESTRINGM,
	POLYGONM, MULTIPOLYGONM,
	CIRCULARSTRINGM, COMPOUNDCURVEM, MULTICURVEM
	CURVEPOLYGONM, MULTISURFACEM,
	or GEOMETRYCOLLECTIONM';
		RETURN 'fail';
	END IF;


	-- Verify dimension
	IF ( (new_dim >4) OR (new_dim <0) ) THEN
		RAISE EXCEPTION 'invalid dimension';
		RETURN 'fail';
	END IF;

	IF ( (new_type LIKE '%M') AND (new_dim!=3) ) THEN
		RAISE EXCEPTION 'TypeM needs 3 dimensions';
		RETURN 'fail';
	END IF;


	-- Verify SRID
	IF ( new_srid != -1 ) THEN
		SELECT SRID INTO sr FROM spatial_ref_sys WHERE SRID = new_srid;
		IF NOT FOUND THEN
			RAISE EXCEPTION 'registergeometrycolumns() - invalid SRID';
			RETURN 'fail';
		END IF;
	END IF;


	-- Verify schema
	IF ( schema_name IS NOT NULL AND schema_name != '' ) THEN
		sql := 'SELECT nspname FROM pg_namespace ' ||
			'WHERE text(nspname) = ' || quote_literal(schema_name) ||
			'LIMIT 1';
		RAISE DEBUG '%', sql;
		EXECUTE sql INTO real_schema;

		IF ( real_schema IS NULL ) THEN
			RAISE EXCEPTION 'Schema % is not a valid schemaname', quote_literal(schema_name);
			RETURN 'fail';
		END IF;
	END IF;

	IF ( real_schema IS NULL ) THEN
		RAISE DEBUG 'Detecting schema';
		sql := 'SELECT n.nspname AS schemaname ' ||
			'FROM pg_catalog.pg_class c ' ||
			  'JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace ' ||
			'WHERE c.relkind = ' || quote_literal('r') ||
			' AND n.nspname NOT IN (' || quote_literal('pg_catalog') || ', ' || quote_literal('pg_toast') || ')' ||
			' AND pg_catalog.pg_table_is_visible(c.oid)' ||
			' AND c.relname = ' || quote_literal(table_name);
		RAISE DEBUG '%', sql;
		EXECUTE sql INTO real_schema;

		IF ( real_schema IS NULL ) THEN
			RAISE EXCEPTION 'Table % does not occur in the search_path', quote_literal(table_name);
			RETURN 'fail';
		END IF;
	END IF;

	-- Delete stale record in geometry_columns (if any)
	sql := 'DELETE FROM geometry_columns WHERE
		f_table_catalog = ' || quote_literal('') ||
		' AND f_table_schema = ' ||
		quote_literal(real_schema) ||
		' AND f_table_name = ' || quote_literal(table_name) ||
		' AND f_geometry_column = ' || quote_literal(column_name);
	RAISE DEBUG '%', sql;
	EXECUTE sql;


	-- Add record in geometry_columns
	sql := 'INSERT INTO geometry_columns (f_table_catalog,f_table_schema,f_table_name,' ||
										  'f_geometry_column,coord_dimension,srid,type)' ||
		' VALUES (' ||
		quote_literal('') || ',' ||
		quote_literal(real_schema) || ',' ||
		quote_literal(table_name) || ',' ||
		quote_literal(column_name) || ',' ||
		new_dim::text || ',' ||
		new_srid::text || ',' ||
		quote_literal(new_type) || ')';
	RAISE DEBUG '%', sql;
	EXECUTE sql;

    SELECT CASE relkind WHEN 'v' THEN false ELSE true END from pg_class JOIN  pg_namespace ON relnamespace = pg_namespace.oid WHERE nspname = quote_ident(real_schema) AND relname = quote_ident(table_name) INTO is_table;

    If is_table THEN
        -- Add table CHECKs
        sql := 'ALTER TABLE ' ||
            quote_ident(real_schema) || '.' || quote_ident(table_name)
            || ' ADD CONSTRAINT '
            || quote_ident('enforce_srid_' || column_name)
            || ' CHECK (ST_SRID(' || quote_ident(column_name) ||
            ') = ' || new_srid::text || ')' ;
        RAISE DEBUG '%', sql;
        EXECUTE sql;

        sql := 'ALTER TABLE ' ||
            quote_ident(real_schema) || '.' || quote_ident(table_name)
            || ' ADD CONSTRAINT '
            || quote_ident('enforce_dims_' || column_name)
            || ' CHECK (ST_NDims(' || quote_ident(column_name) ||
            ') = ' || new_dim::text || ')' ;
        RAISE DEBUG '%', sql;
        EXECUTE sql;

        IF ( NOT (new_type = 'GEOMETRY')) THEN
            SELECT attnotnull FROM pg_attribute JOIN pg_class on attrelid = pg_class.oid JOIN pg_namespace ON relnamespace = pg_namespace.oid WHERE nspname = quote_ident(real_schema) AND relname = quote_ident(table_name) AND attname = quote_ident(column_name) INTO not_null;
            sql := 'ALTER TABLE ' ||
                quote_ident(real_schema) || '.' || quote_ident(table_name) || ' ADD CONSTRAINT ' ||
                quote_ident('enforce_geotype_' || column_name) ||
                ' CHECK (GeometryType(' ||
                quote_ident(column_name) || ')=' ||
                quote_literal(new_type);

                IF not_null THEN
                    sql := sql || ' OR (' ||
                    quote_ident(column_name) || ') is null)';
                ELSE
                    sql := sql || ')';
                END IF;
                
            RAISE DEBUG '%', sql;
            EXECUTE sql;
        END IF;
        
        --Create spatial index
        sql := 'CREATE INDEX ' ||
            quote_ident(table_name || '_gidx')
            || ' ON '
            || quote_ident(real_schema) || '.' || quote_ident(table_name)
            || ' using gist(' || quote_ident(column_name) ||
            ')' ;
        RAISE DEBUG '%', sql;
        EXECUTE sql;
    END IF; -- is_table
    
	RETURN
		real_schema || '.' ||
		table_name || '.' || column_name ||
		' SRID:' || new_srid::text ||
		' TYPE:' || new_type ||
		' DIMS:' || new_dim::text || ' ';
END;
$BODY$
  LANGUAGE 'plpgsql' VOLATILE STRICT
  COST 100;
COMMENT ON FUNCTION "XP_Basisobjekte"."registergeometrycolumn"(character varying, character varying, character varying, character varying, character varying, integer) IS 'Funktion zur Registrierung in geometry columns für instantiierbare Tabellen, die ihr Geometriefeld erben';

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

CREATE SEQUENCE "XP_Raster"."XP_RasterplanAenderung_gid_seq"
   MINVALUE 1;
GRANT ALL ON TABLE "XP_Raster"."XP_RasterplanAenderung_gid_seq" TO GROUP xp_user;

CREATE SEQUENCE "XP_Raster"."XP_RasterplanBasis_id_seq"
   MINVALUE 1;
GRANT ALL ON TABLE "XP_Raster"."XP_RasterplanBasis_id_seq" TO GROUP xp_user;

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

CREATE SEQUENCE "XP_Sonstiges"."XP_SPEMassnahmenDaten_id_seq"
    MINVALUE 1;
GRANT ALL ON TABLE "XP_Sonstiges"."XP_SPEMassnahmenDaten_id_seq" TO GROUP xp_user;

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

CREATE OR REPLACE FUNCTION "XP_Basisobjekte"."isUeberlagerungsobjekt"() 
RETURNS trigger AS
$BODY$ 
 BEGIN
    IF (TG_OP = 'DELTE') THEN
        RETURN old;
    ELSE
        new.flaechenschluss = false;
        RETURN new;
    END IF;
 END; $BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
GRANT EXECUTE ON FUNCTION "XP_Basisobjekte"."isUeberlagerungsobjekt"() TO xp_user;

CREATE OR REPLACE FUNCTION "XP_Basisobjekte"."isFlaechenschlussobjekt"() 
RETURNS trigger AS
$BODY$ 
 BEGIN
    IF (TG_OP = 'DELETE') THEN
        RETURN old;
    ELSE
        new.flaechenschluss = true;
        RETURN new;
    END IF;
 END; $BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
GRANT EXECUTE ON FUNCTION "XP_Basisobjekte"."isFlaechenschlussobjekt"() TO xp_user;

CREATE OR REPLACE FUNCTION "XP_Basisobjekte"."change_to_XP_Plan"() 
RETURNS trigger AS
$BODY$ 
 BEGIN
    IF (TG_OP = 'INSERT') THEN
        INSERT INTO "XP_Basisobjekte"."XP_VerbundenerPlan"(gid, "planName") VALUES(new.gid, 'XP_Plan ' || CAST(new.gid as varchar));
        RETURN new;
    ELSIF (TG_OP = 'UPDATE') THEN
        new.gid := old.gid; --no change in gid allowed
        UPDATE "XP_Basisobjekte"."XP_VerbundenerPlan" SET "planName" = new.name WHERE gid = old.gid;
        RETURN new;
    END IF;
 END; $BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
GRANT EXECUTE ON FUNCTION "XP_Basisobjekte"."change_to_XP_Plan"() TO xp_user;

CREATE OR REPLACE FUNCTION "XP_Basisobjekte"."child_of_XP_Plan"() 
RETURNS trigger AS
$BODY$ 
 BEGIN
    IF (TG_OP = 'INSERT') THEN
        IF new.gid IS NULL THEN
            new.gid := nextval('"XP_Basisobjekte"."XP_Plan_gid_seq"');
        END IF;

        INSERT INTO "XP_Basisobjekte"."XP_Plan"(gid, name) VALUES(new.gid, 'XP_Plan ' || CAST(new.gid as varchar));
        
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
 BEGIN
    IF (TG_OP = 'INSERT') THEN
        IF new.gid IS NULL THEN
            new.gid := nextval('"XP_Basisobjekte"."XP_Bereich_gid_seq"');
        END IF;
        
        INSERT INTO "XP_Basisobjekte"."XP_Bereich"(gid, name) VALUES(new.gid, 'XP_Bereich ' || CAST(new.gid as varchar));

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
RETURNS trigger AS
$BODY$ 
 BEGIN
    IF (TG_OP = 'INSERT') THEN
        IF new.gid IS NULL THEN
            new.gid := nextval('"XP_Basisobjekte"."XP_Objekt_gid_seq"');
        END IF;
        
        INSERT INTO "XP_Basisobjekte"."XP_Objekt"(gid) VALUES(new.gid);
        RETURN new;
    ELSIF (TG_OP = 'UPDATE') THEN
        new.gid := old.gid; --no change in gid allowed
        RETURN new;
    ELSIF (TG_OP = 'DELETE') THEN
        DELETE FROM "XP_Basisobjekte"."XP_Objekt" WHERE gid = old.gid;
        RETURN old;
    END IF;
 END; $BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
GRANT EXECUTE ON FUNCTION "XP_Basisobjekte"."child_of_XP_Objekt"() TO xp_user;

CREATE OR REPLACE FUNCTION "XP_Praesentationsobjekte"."child_of_XP_APObjekt"() 
RETURNS trigger AS
$BODY$ 
 BEGIN
    IF (TG_OP = 'INSERT') THEN
        IF new.gid IS NULL THEN
            new.gid := nextval('"XP_Praesentationsobjekte"."XP_APObjekt_gid_seq"');
        END IF;
        
        INSERT INTO "XP_Praesentationsobjekte"."XP_AbstraktesPraesentationsobjekt" (gid) VALUES (new.gid);
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
 BEGIN
    IF (TG_OP = 'INSERT') THEN
        IF new.gid IS NULL THEN
            new.gid := currentval('"XP_Praesentationsobjekte"."XP_APObjekt_gid_seq"');
        END IF;
        
        INSERT INTO "XP_Praesentationsobjekte"."XP_TPO" (gid) VALUES (new.gid);
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

CREATE OR REPLACE FUNCTION "XP_Raster"."child_of_XP_RasterplanAenderung"() 
RETURNS trigger AS
$BODY$ 
 BEGIN
    IF (TG_OP = 'INSERT') THEN
        IF new.gid IS NULL THEN
            new.gid := nextval('"XP_Raster"."XP_RasterplanAenderung_gid_seq"');
        END IF;
        
        INSERT INTO "XP_Raster"."XP_RasterplanAenderung" (gid) VALUES (new.gid);

        IF new."geltungsbereichAenderung" IS NOT NULL THEN
            new."geltungsbereichAenderung" := ST_ForceRHR(new."geltungsbereichAenderung");
        END IF;
        
        RETURN new;
    ELSIF (TG_OP = 'UPDATE') THEN
        new.gid := old.gid; --no change in gid allowed

        IF new."geltungsbereichAenderung" IS NOT NULL THEN
            new."geltungsbereichAenderung" := ST_ForceRHR(new."geltungsbereichAenderung");
        END IF;
        
        RETURN new;
    ELSIF (TG_OP = 'DELETE') THEN
        PERFORM "XP_Basisobjekte"."XP_RasterplanAenderung_deleted"(old.gid);   
        RETURN old;
    END IF;
 END; $BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
GRANT EXECUTE ON FUNCTION "XP_Raster"."child_of_XP_RasterplanAenderung"() TO xp_user;

CREATE OR REPLACE FUNCTION "XP_Basisobjekte"."positionFollowsRHR"() 
RETURNS trigger AS
$BODY$ 
 BEGIN
    IF (TG_OP = 'INSERT') THEN
        IF new."position" IS NOT NULL THEN
            new."position" := ST_ForceRHR(new."position");
        END IF;
        
        RETURN new;
    ELSIF (TG_OP = 'UPDATE') THEN
        IF new."position" IS NOT NULL THEN
            new."position" := ST_ForceRHR(new."position");
        END IF;
    END IF;
 END; $BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
GRANT EXECUTE ON FUNCTION "XP_Basisobjekte"."child_of_XP_Bereich"() TO xp_user;



-- *****************************************************
-- CREATE TABLEs 
-- *****************************************************

-- -----------------------------------------------------
-- Table "XP_Enumerationen"."XP_Rechtsstand"
-- -----------------------------------------------------
CREATE  TABLE  "XP_Enumerationen"."XP_Rechtsstand" (
  "Wert" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Wert") );
GRANT SELECT ON TABLE "XP_Enumerationen"."XP_Rechtsstand" TO xp_gast;

-- -----------------------------------------------------
-- Table "XP_Enumerationen"."XP_VersionBauNVO"
-- -----------------------------------------------------
CREATE  TABLE  "XP_Enumerationen"."XP_VersionBauNVO" (
  "Wert" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Wert") );
GRANT SELECT ON TABLE "XP_Enumerationen"."XP_VersionBauNVO" TO xp_gast;

-- -----------------------------------------------------
-- Table "XP_Enumerationen"."XP_AllgArtDerBaulNutzung"
-- -----------------------------------------------------
CREATE  TABLE  "XP_Enumerationen"."XP_AllgArtDerBaulNutzung" (
  "Wert" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Wert") );
GRANT SELECT ON TABLE "XP_Enumerationen"."XP_AllgArtDerBaulNutzung" TO xp_gast;

-- -----------------------------------------------------
-- Table "XP_Enumerationen"."XP_BesondereArtDerBaulNutzung"
-- -----------------------------------------------------
CREATE  TABLE  "XP_Enumerationen"."XP_BesondereArtDerBaulNutzung" (
  "Wert" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Wert") );
GRANT SELECT ON TABLE "XP_Enumerationen"."XP_BesondereArtDerBaulNutzung" TO xp_gast;

-- -----------------------------------------------------
-- Table "XP_Enumerationen"."XP_Sondernutzungen"
-- -----------------------------------------------------
CREATE  TABLE  "XP_Enumerationen"."XP_Sondernutzungen" (
  "Wert" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Wert") );
GRANT SELECT ON TABLE "XP_Enumerationen"."XP_Sondernutzungen" TO xp_gast;

-- -----------------------------------------------------
-- Table "XP_Enumerationen"."XP_AbweichungBauNVOTypen"
-- -----------------------------------------------------
CREATE  TABLE  "XP_Enumerationen"."XP_AbweichungBauNVOTypen" (
  "Wert" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Wert") );
GRANT SELECT ON TABLE "XP_Enumerationen"."XP_AbweichungBauNVOTypen" TO xp_gast;

-- -----------------------------------------------------
-- Table "XP_Enumerationen"."XP_ZweckbestimmungGemeinbedarf"
-- -----------------------------------------------------
CREATE  TABLE  "XP_Enumerationen"."XP_ZweckbestimmungGemeinbedarf" (
  "Wert" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Wert") );
GRANT SELECT ON TABLE "XP_Enumerationen"."XP_ZweckbestimmungGemeinbedarf" TO xp_gast;

-- -----------------------------------------------------
-- Table "XP_Enumerationen"."XP_BesondereZweckbestGemeinbedarf"
-- -----------------------------------------------------
CREATE  TABLE  "XP_Enumerationen"."XP_BesondereZweckbestGemeinbedarf" (
  "Wert" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Wert") );
GRANT SELECT ON TABLE "XP_Enumerationen"."XP_BesondereZweckbestGemeinbedarf" TO xp_gast;

-- -----------------------------------------------------
-- Table "XP_Enumerationen"."XP_ZweckbestimmungSpielSportanlage"
-- -----------------------------------------------------
CREATE  TABLE  "XP_Enumerationen"."XP_ZweckbestimmungSpielSportanlage" (
  "Wert" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Wert") );
GRANT SELECT ON TABLE "XP_Enumerationen"."XP_ZweckbestimmungSpielSportanlage" TO xp_gast;

-- -----------------------------------------------------
-- Table "XP_Enumerationen"."XP_ZweckbestimmungGruen"
-- -----------------------------------------------------
CREATE  TABLE  "XP_Enumerationen"."XP_ZweckbestimmungGruen" (
  "Wert" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Wert") );
GRANT SELECT ON TABLE "XP_Enumerationen"."XP_ZweckbestimmungGruen" TO xp_gast;

-- -----------------------------------------------------
-- Table "XP_Enumerationen"."XP_BesondereZweckbestimmungGruen"
-- -----------------------------------------------------
CREATE  TABLE  "XP_Enumerationen"."XP_BesondereZweckbestimmungGruen" (
  "Wert" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Wert") );
GRANT SELECT ON TABLE "XP_Enumerationen"."XP_BesondereZweckbestimmungGruen" TO xp_gast;

-- -----------------------------------------------------
-- Table "XP_Enumerationen"."XP_ZweckbestimmungWald"
-- -----------------------------------------------------
CREATE  TABLE  "XP_Enumerationen"."XP_ZweckbestimmungWald" (
  "Wert" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Wert") );
GRANT SELECT ON TABLE "XP_Enumerationen"."XP_ZweckbestimmungWald" TO xp_gast;

-- -----------------------------------------------------
-- Table "XP_Enumerationen"."XP_ZweckbestimmungLandwirtschaft"
-- -----------------------------------------------------
CREATE  TABLE  "XP_Enumerationen"."XP_ZweckbestimmungLandwirtschaft" (
  "Wert" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Wert") );
GRANT SELECT ON TABLE "XP_Enumerationen"."XP_ZweckbestimmungLandwirtschaft" TO xp_gast;

-- -----------------------------------------------------
-- Table "XP_Enumerationen"."XP_Nutzungsform"
-- -----------------------------------------------------
CREATE  TABLE  "XP_Enumerationen"."XP_Nutzungsform" (
  "Wert" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Wert") );
GRANT SELECT ON TABLE "XP_Enumerationen"."XP_Nutzungsform" TO xp_gast;

-- -----------------------------------------------------
-- Table "XP_Enumerationen"."XP_ZweckbestimmungKennzeichnung"
-- -----------------------------------------------------
CREATE  TABLE  "XP_Enumerationen"."XP_ZweckbestimmungKennzeichnung" (
  "Wert" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Wert") );
GRANT SELECT ON TABLE "XP_Enumerationen"."XP_ZweckbestimmungKennzeichnung" TO xp_gast;

-- -----------------------------------------------------
-- Table "XP_Enumerationen"."XP_ZweckbestimmungVerEntsorgung"
-- -----------------------------------------------------
CREATE  TABLE  "XP_Enumerationen"."XP_ZweckbestimmungVerEntsorgung" (
  "Wert" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Wert") );
GRANT SELECT ON TABLE "XP_Enumerationen"."XP_ZweckbestimmungVerEntsorgung" TO xp_gast;

-- -----------------------------------------------------
-- Table "XP_Enumerationen"."XP_BesondereZweckbestimmungVerEntsorgung"
-- -----------------------------------------------------
CREATE  TABLE  "XP_Enumerationen"."XP_BesondereZweckbestimmungVerEntsorgung" (
  "Wert" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Wert") );
GRANT SELECT ON TABLE "XP_Enumerationen"."XP_BesondereZweckbestimmungVerEntsorgung" TO xp_gast;

-- -----------------------------------------------------
-- Table "XP_Enumerationen"."XP_ZweckbestimmungGewaesser"
-- -----------------------------------------------------
CREATE  TABLE  "XP_Enumerationen"."XP_ZweckbestimmungGewaesser" (
  "Wert" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Wert") );
GRANT SELECT ON TABLE "XP_Enumerationen"."XP_ZweckbestimmungGewaesser" TO xp_gast;

-- -----------------------------------------------------
-- Table "XP_Enumerationen"."XP_ZweckbestimmungWasserwirtschaft"
-- -----------------------------------------------------
CREATE  TABLE  "XP_Enumerationen"."XP_ZweckbestimmungWasserwirtschaft" (
  "Wert" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Wert") );
GRANT SELECT ON TABLE "XP_Enumerationen"."XP_ZweckbestimmungWasserwirtschaft" TO xp_gast;

-- -----------------------------------------------------
-- Table "XP_Enumerationen"."XP_Bundeslaender"
-- -----------------------------------------------------
CREATE  TABLE  "XP_Enumerationen"."XP_Bundeslaender" (
  "Wert" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Wert") );
GRANT SELECT ON TABLE "XP_Enumerationen"."XP_Bundeslaender" TO xp_gast;

-- -----------------------------------------------------
-- Table "SO_Schutzgebiete"."SO_KlassifizSchutzgebietNaturschutzrecht"
-- -----------------------------------------------------
CREATE  TABLE  "SO_Schutzgebiete"."SO_KlassifizSchutzgebietNaturschutzrecht" (
  "Wert" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Wert") );
GRANT SELECT ON TABLE "SO_Schutzgebiete"."SO_KlassifizSchutzgebietNaturschutzrecht" TO xp_gast;

-- -----------------------------------------------------
-- Table "SO_Schutzgebiete"."SO_DetailKlassifizSchutzgebietNaturschutzrecht"
-- -----------------------------------------------------
CREATE  TABLE  "SO_Schutzgebiete"."SO_DetailKlassifizSchutzgebietNaturschutzrecht" (
  "Wert" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Wert") );
GRANT SELECT ON TABLE "SO_Schutzgebiete"."SO_DetailKlassifizSchutzgebietNaturschutzrecht" TO xp_gast;
GRANT ALL ON TABLE "SO_Schutzgebiete"."SO_DetailKlassifizSchutzgebietNaturschutzrecht" TO xp_user;

-- -----------------------------------------------------
-- Table "XP_Basisobjekte"."XP_RaeumlicherGeltungsbereich"
-- -----------------------------------------------------
CREATE  TABLE  "XP_Basisobjekte"."XP_RaeumlicherGeltungsbereich" (
  "gid" INTEGER NOT NULL ,
  "raeumlicherGeltungsbereich" GEOMETRY NOT NULL ,
  PRIMARY KEY ("gid") );
GRANT SELECT ON TABLE "XP_Basisobjekte"."XP_RaeumlicherGeltungsbereich" TO xp_gast;
GRANT ALL ON TABLE "XP_Basisobjekte"."XP_RaeumlicherGeltungsbereich" TO xp_user;
CREATE TRIGGER  "XP_RaeumlicherGeltungsbereich_isAbstract" BEFORE INSERT ON "XP_Basisobjekte"."XP_RaeumlicherGeltungsbereich" FOR EACH STATEMENT EXECUTE PROCEDURE "XP_Basisobjekte"."isAbstract"();

-- -----------------------------------------------------
-- Table "XP_Basisobjekte"."XP_Geltungsbereich"
-- -----------------------------------------------------
CREATE  TABLE  "XP_Basisobjekte"."XP_Geltungsbereich" (
  "gid" INTEGER NOT NULL ,
  "geltungsbereich" GEOMETRY NOT NULL ,
  PRIMARY KEY ("gid") );
GRANT SELECT ON TABLE "XP_Basisobjekte"."XP_Geltungsbereich" TO xp_gast;
GRANT ALL ON TABLE "XP_Basisobjekte"."XP_Geltungsbereich" TO xp_user;
CREATE TRIGGER  "XP_Geltungsbereich_isAbstract" BEFORE INSERT ON "XP_Basisobjekte"."XP_Geltungsbereich" FOR EACH STATEMENT EXECUTE PROCEDURE "XP_Basisobjekte"."isAbstract"();

-- -----------------------------------------------------
-- Table "XP_Basisobjekte"."XP_GesetzlicheGrundlage"
-- -----------------------------------------------------
CREATE  TABLE  "XP_Basisobjekte"."XP_GesetzlicheGrundlage" (
  "Wert" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Wert") );
GRANT SELECT ON TABLE "XP_Basisobjekte"."XP_GesetzlicheGrundlage" TO xp_gast;
GRANT ALL ON TABLE "XP_Basisobjekte"."XP_GesetzlicheGrundlage" TO xp_user;

-- -----------------------------------------------------
-- Table "XP_Basisobjekte"."XP_BedeutungenBereich"
-- -----------------------------------------------------
CREATE  TABLE  "XP_Basisobjekte"."XP_BedeutungenBereich" (
  "Wert" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(45) NOT NULL ,
  PRIMARY KEY ("Wert") );
GRANT SELECT ON TABLE "XP_Basisobjekte"."XP_BedeutungenBereich" TO xp_gast;

-- -----------------------------------------------------
-- Table "XP_Basisobjekte"."XP_MimeTypes"
-- -----------------------------------------------------
CREATE  TABLE  "XP_Basisobjekte"."XP_MimeTypes" (
  "Wert" VARCHAR(64) NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Wert") );
GRANT SELECT ON TABLE "XP_Basisobjekte"."XP_MimeTypes" TO xp_gast;

-- -----------------------------------------------------
-- Table "XP_Basisobjekte"."XP_ExterneReferenzArt"
-- -----------------------------------------------------
CREATE  TABLE  "XP_Basisobjekte"."XP_ExterneReferenzArt" (
  "Wert" VARCHAR(64) NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Wert") );
GRANT SELECT ON TABLE "XP_Basisobjekte"."XP_ExterneReferenzArt" TO xp_gast;

-- -----------------------------------------------------
-- Table "XP_Basisobjekte"."XP_ExterneReferenz"
-- -----------------------------------------------------
CREATE  TABLE  "XP_Basisobjekte"."XP_ExterneReferenz" (
  "id" INTEGER NOT NULL DEFAULT nextval('"XP_Basisobjekte"."XP_ExterneReferenz_id_seq"'),
  "informationssystemURL" VARCHAR(255) NULL ,
  "referenzName" VARCHAR(255) NOT NULL ,
  "referenzURL" VARCHAR(255) NULL ,
  "referenzMimeType" VARCHAR(64) NULL ,
  "georefURL" VARCHAR(255) NULL ,
  "georefMimeType" VARCHAR(64) NULL ,
  "beschreibung" VARCHAR(255) NULL ,
  "art" VARCHAR(64) NULL ,
  PRIMARY KEY ("id") ,
  CONSTRAINT "fk_xp_externereferenz_xp_mimetypes"
    FOREIGN KEY ("referenzMimeType" )
    REFERENCES "XP_Basisobjekte"."XP_MimeTypes" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_xp_externereferenz_xp_mimetypes1"
    FOREIGN KEY ("georefMimeType" )
    REFERENCES "XP_Basisobjekte"."XP_MimeTypes" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_xp_externereferenz_xp_externereferenzart1"
    FOREIGN KEY ("art" )
    REFERENCES "XP_Basisobjekte"."XP_ExterneReferenzArt" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE);

COMMENT ON TABLE "XP_Basisobjekte"."XP_ExterneReferenz" IS 'Verweis auf ein extern gespeichertes Dokument, einen extern gespeicherten, georeferenzierten Plan oder einen Datenbank-Eintrag. Einer der beiden Attribute "referenzName" bzw. "referenzURL" muss belegt sein.';
COMMENT ON COLUMN "XP_Basisobjekte"."XP_ExterneReferenz"."id" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN "XP_Basisobjekte"."XP_ExterneReferenz"."informationssystemURL" IS 'URI des des zugehörigen Informationssystems';
COMMENT ON COLUMN "XP_Basisobjekte"."XP_ExterneReferenz"."referenzName" IS 'Name des referierten Dokuments.';
COMMENT ON COLUMN "XP_Basisobjekte"."XP_ExterneReferenz"."referenzURL" IS 'URI des referierten Dokuments, bzw. Datenbank-Schlüssel.';
COMMENT ON COLUMN "XP_Basisobjekte"."XP_ExterneReferenz"."referenzMimeType" IS 'Mime-Type des referierten Dokumentes';
COMMENT ON COLUMN "XP_Basisobjekte"."XP_ExterneReferenz"."georefURL" IS 'Referenz auf eine Georeferenzierungs-Datei. Das Arrtibut ist nur relevant bei Verweisen auf georeferenzierte Rasterbilder.';
COMMENT ON COLUMN "XP_Basisobjekte"."XP_ExterneReferenz"."georefMimeType" IS 'Mime-Type der Georeferenzierungs-Datei. Das Arrtibut ist nur relevant bei Verweisen auf georeferenzierte Rasterbilder.';
COMMENT ON COLUMN "XP_Basisobjekte"."XP_ExterneReferenz"."beschreibung" IS 'Beschreibung des referierten Dokuments';
COMMENT ON COLUMN "XP_Basisobjekte"."XP_ExterneReferenz"."art" IS 'Typisierung der referierten Dokumente';

CREATE INDEX "idx_fk_xp_externereferenz_xp_mimetypes" ON "XP_Basisobjekte"."XP_ExterneReferenz" ("referenzMimeType") ;
CREATE INDEX "idx_fk_xp_externereferenz_xp_mimetypes1" ON "XP_Basisobjekte"."XP_ExterneReferenz" ("georefMimeType") ;
CREATE INDEX "idx_fk_xp_externereferenz_xp_externereferenzart1" ON "XP_Basisobjekte"."XP_ExterneReferenz" ("art") ;

GRANT SELECT ON TABLE "XP_Basisobjekte"."XP_ExterneReferenz" TO xp_gast;
GRANT ALL ON TABLE "XP_Basisobjekte"."XP_ExterneReferenz" TO xp_user;

-- -----------------------------------------------------
-- Table "XP_Raster"."XP_GeltungsbereichAenderung"
-- -----------------------------------------------------
CREATE  TABLE  "XP_Raster"."XP_GeltungsbereichAenderung" (
  "gid" INTEGER NOT NULL ,
  "geltungsbereichAenderung" GEOMETRY NOT NULL ,
  PRIMARY KEY ("gid") );
GRANT SELECT ON TABLE "XP_Raster"."XP_GeltungsbereichAenderung" TO xp_gast;
GRANT ALL ON TABLE "XP_Raster"."XP_GeltungsbereichAenderung" TO xp_user;
CREATE TRIGGER  "XP_GeltungsbereichAenderung_isAbstract" BEFORE INSERT ON "XP_Raster"."XP_GeltungsbereichAenderung" FOR EACH STATEMENT EXECUTE PROCEDURE "XP_Basisobjekte"."isAbstract"();

-- -----------------------------------------------------
-- Table "XP_Raster"."XP_RasterplanBasis"
-- -----------------------------------------------------
CREATE  TABLE  "XP_Raster"."XP_RasterplanBasis" (
  "id" INTEGER NOT NULL DEFAULT nextval('"XP_Raster"."XP_RasterplanBasis_id_seq"'),
  "refText" INTEGER NULL ,
  PRIMARY KEY ("id") ,
  CONSTRAINT "fk_XP_RasterplanBasis_XP_ExterneReferenz1"
    FOREIGN KEY ("refText" )
    REFERENCES "XP_Basisobjekte"."XP_ExterneReferenz" ("id" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
COMMENT ON TABLE "XP_Raster"."XP_RasterplanBasis" IS 'Georeferenzierte Rasterdarstellung eines Plans. Das über refScan referierte Rasterbild zeigt den Basisplan, dessen Geltungsbereich durch den Geltungsbereich des Gesamtplans (Attribut geltungsbereich von XP_Bereich) repräsentiert ist. Diesem Basisplan können Änderungen überlagert sein, denen jeweils eigene Rasterbilder und Geltungsbereiche zugeordnet sind (XP_RasterplanAenderung und abgeleitete Klassen).
Im Standard sind nur georeferenzierte Rasterpläne zugelassen. Die über refScan referierte externe Referenz muss deshalb entweder vom Typ "PlanMitGeoreferenz" sein oder einen WMS-Request enthalten.';
COMMENT ON COLUMN "XP_Raster"."XP_RasterplanBasis"."id" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN "XP_Raster"."XP_RasterplanBasis"."refText" IS 'Referenz auf die textlich formulierten Inhalte des Plans.';

CREATE INDEX "idx_fk_XP_RasterplanBasis_XP_ExterneReferenz1" ON "XP_Raster"."XP_RasterplanBasis" ("refText") ;

GRANT SELECT ON TABLE "XP_Raster"."XP_RasterplanBasis" TO xp_gast;
GRANT ALL ON TABLE "XP_Raster"."XP_RasterplanBasis" TO xp_user;

-- -----------------------------------------------------
-- Table "XP_Raster"."XP_RasterplanBasis_refScan"
-- -----------------------------------------------------
CREATE  TABLE  "XP_Raster"."XP_RasterplanBasis_refScan" (
  "XP_RasterplanBasis_id" INTEGER NOT NULL ,
  "XP_ExterneReferenz_id" INTEGER NOT NULL ,
  PRIMARY KEY ("XP_RasterplanBasis_id", "XP_ExterneReferenz_id") ,
  CONSTRAINT "fk_XP_RasterplanBasis_refScan1"
    FOREIGN KEY ("XP_RasterplanBasis_id" )
    REFERENCES "XP_Raster"."XP_RasterplanBasis" ("id" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_XP_RasterplanBasis_refScan2"
    FOREIGN KEY ("XP_ExterneReferenz_id" )
    REFERENCES "XP_Basisobjekte"."XP_ExterneReferenz" ("id" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
COMMENT ON TABLE  "XP_Raster"."XP_RasterplanBasis_refScan" IS 'Referenz auf eine georeferenzierte Rasterversion des Basisplans';
CREATE INDEX "idx_fk_XP_RasterplanBasis_refScan1" ON "XP_Raster"."XP_RasterplanBasis_refScan" ("XP_RasterplanBasis_id") ;
CREATE INDEX "idx_fk_XP_RasterplanBasis_refScan2" ON "XP_Raster"."XP_RasterplanBasis_refScan" ("XP_ExterneReferenz_id") ;

GRANT SELECT ON TABLE "XP_Raster"."XP_RasterplanBasis_refScan" TO xp_gast;
GRANT ALL ON TABLE "XP_Raster"."XP_RasterplanBasis_refScan" TO xp_user;

-- -----------------------------------------------------
-- Table "XP_Raster"."XP_RasterplanBasis_refLegende"
-- -----------------------------------------------------
CREATE  TABLE  "XP_Raster"."XP_RasterplanBasis_refLegende" (
  "XP_RasterplanBasis_id" INTEGER NOT NULL ,
  "XP_ExterneReferenz_id" INTEGER NOT NULL ,
  PRIMARY KEY ("XP_RasterplanBasis_id", "XP_ExterneReferenz_id") ,
  CONSTRAINT "fk_XP_RasterplanBasis_refLegende1"
    FOREIGN KEY ("XP_RasterplanBasis_id" )
    REFERENCES "XP_Raster"."XP_RasterplanBasis" ("id" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_XP_RasterplanBasis_refLegende2"
    FOREIGN KEY ("XP_ExterneReferenz_id" )
    REFERENCES "XP_Basisobjekte"."XP_ExterneReferenz" ("id" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
COMMENT ON TABLE  "XP_Raster"."XP_RasterplanBasis_refLegende" IS 'Referenz auf die Legende des Plans.';
CREATE INDEX "idx_fk_XP_RasterplanBasis_refLegende1" ON "XP_Raster"."XP_RasterplanBasis_refLegende" ("XP_RasterplanBasis_id") ;
CREATE INDEX "idx_fk_XP_RasterplanBasis_refLegende2" ON "XP_Raster"."XP_RasterplanBasis_refLegende" ("XP_ExterneReferenz_id") ;

GRANT SELECT ON TABLE "XP_Raster"."XP_RasterplanBasis_refLegende" TO xp_gast;
GRANT ALL ON TABLE "XP_Raster"."XP_RasterplanBasis_refLegende" TO xp_user;

-- -----------------------------------------------------
-- Table "XP_Raster"."XP_RasterplanAenderung"
-- -----------------------------------------------------
CREATE  TABLE  "XP_Raster"."XP_RasterplanAenderung" (
  "gid" INTEGER NOT NULL DEFAULT nextval('"XP_Raster"."XP_RasterplanAenderung_gid_seq"'),
  "nameAenderung" VARCHAR(64) NULL ,
  "beschreibung" VARCHAR(255) NULL ,
  "refBeschreibung" INTEGER NULL ,
  "refBegruendung" INTEGER NULL ,
  "refText" INTEGER NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_XP_RasterplanAenderung_XP_ExterneReferenz1"
    FOREIGN KEY ("refBeschreibung" )
    REFERENCES "XP_Basisobjekte"."XP_ExterneReferenz" ("id" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_XP_RasterplanAenderung_XP_ExterneReferenz2"
    FOREIGN KEY ("refBegruendung" )
    REFERENCES "XP_Basisobjekte"."XP_ExterneReferenz" ("id" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_XP_RasterplanAenderung_XP_ExterneReferenz3"
    FOREIGN KEY ("refText" )
    REFERENCES "XP_Basisobjekte"."XP_ExterneReferenz" ("id" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
COMMENT ON TABLE  "XP_Raster"."XP_RasterplanAenderung" IS 'Basisklasse für georeferenzierte Rasterdarstellungen von Änderungen des Basisplans, die nicht in die Rasterdarstellung XP_RasterplanBasis integriert sind.
Im Standard sind nur georeferenzierte Rasterpläne zugelassen. Die über refScan referierte externe Referenz muss deshalb entweder vom Typ "PlanMitGeoreferenz" sein oder einen WMS-Request enthalten.
Es handelt sich um eine abstrakte Objektart.';
COMMENT ON COLUMN  "XP_Raster"."XP_RasterplanAenderung"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN  "XP_Raster"."XP_RasterplanAenderung"."nameAenderung" IS 'Bezeichnung der Plan-Änderung';
COMMENT ON COLUMN  "XP_Raster"."XP_RasterplanAenderung"."beschreibung" IS 'Nähere Beschreibung der Plan-Änderung';
COMMENT ON COLUMN  "XP_Raster"."XP_RasterplanAenderung"."refBeschreibung" IS 'Referenz auf das Beschreibungs-Dokument';
COMMENT ON COLUMN  "XP_Raster"."XP_RasterplanAenderung"."refBegruendung" IS 'Referenz auf das Begründungs-Dokument';
COMMENT ON COLUMN  "XP_Raster"."XP_RasterplanAenderung"."refText" IS 'Referenz auf die textlichen Inhalte der Planänderung.';
CREATE INDEX "idx_fk_XP_RasterplanAenderung_XP_ExterneReferenz1" ON "XP_Raster"."XP_RasterplanAenderung" ("refBeschreibung") ;
CREATE INDEX "idx_fk_XP_RasterplanAenderung_XP_ExterneReferenz2" ON "XP_Raster"."XP_RasterplanAenderung" ("refBegruendung") ;
CREATE INDEX "idx_fk_XP_RasterplanAenderung_XP_ExterneReferenz3" ON "XP_Raster"."XP_RasterplanAenderung" ("refText") ;
GRANT SELECT ON TABLE "XP_Raster"."XP_RasterplanAenderung" TO xp_gast; 
GRANT ALL ON TABLE "XP_Raster"."XP_RasterplanAenderung" TO xp_user; 

-- -----------------------------------------------------
-- Table "XP_Raster"."XP_RasterplanAenderung_refScan"
-- -----------------------------------------------------
CREATE  TABLE  "XP_Raster"."XP_RasterplanAenderung_refScan" (
  "XP_RasterplanAenderung_gid" INTEGER NOT NULL ,
  "XP_ExterneReferenz_id" INTEGER NOT NULL ,
  PRIMARY KEY ("XP_RasterplanAenderung_gid", "XP_ExterneReferenz_id") ,
  CONSTRAINT "fk_XP_RasterplanAenderung_refScan1"
    FOREIGN KEY ("XP_RasterplanAenderung_gid" )
    REFERENCES "XP_Raster"."XP_RasterplanAenderung" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_XP_RasterplanAenderung_refScan2"
    FOREIGN KEY ("XP_ExterneReferenz_id" )
    REFERENCES "XP_Basisobjekte"."XP_ExterneReferenz" ("id" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
COMMENT ON TABLE  "XP_Raster"."XP_RasterplanAenderung_refScan" IS 'Referenz auf eine Rasterversion der Plan-Änderung.';
CREATE INDEX "idx_fk_XP_RasterplanAenderung_refScan1" ON "XP_Raster"."XP_RasterplanAenderung_refScan" ("XP_RasterplanAenderung_gid") ;
CREATE INDEX "idx_fk_XP_RasterplanAenderung_refScan2" ON "XP_Raster"."XP_RasterplanAenderung_refScan" ("XP_ExterneReferenz_id") ;

GRANT SELECT ON TABLE "XP_Raster"."XP_RasterplanAenderung_refScan" TO xp_gast;
GRANT ALL ON TABLE "XP_Raster"."XP_RasterplanAenderung_refScan" TO xp_user;

-- -----------------------------------------------------
-- Table "XP_Raster"."XP_RasterplanAenderung_refLegende"
-- -----------------------------------------------------
CREATE  TABLE  "XP_Raster"."XP_RasterplanAenderung_refLegende" (
  "XP_RasterplanAenderung_gid" INTEGER NOT NULL ,
  "XP_ExterneReferenz_id" INTEGER NOT NULL ,
  PRIMARY KEY ("XP_RasterplanAenderung_gid", "XP_ExterneReferenz_id") ,
  CONSTRAINT "fk_XP_RasterplanAenderung_refLegende1"
    FOREIGN KEY ("XP_RasterplanAenderung_gid" )
    REFERENCES "XP_Raster"."XP_RasterplanAenderung" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_XP_RasterplanAenderung_refLegende2"
    FOREIGN KEY ("XP_ExterneReferenz_id" )
    REFERENCES "XP_Basisobjekte"."XP_ExterneReferenz" ("id" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
COMMENT ON TABLE  "XP_Raster"."XP_RasterplanAenderung_refLegende" IS 'Referenz auf die Legende der Plan-Änderung.';
CREATE INDEX "idx_fk_XP_RasterplanAenderung_refLegende1" ON "XP_Raster"."XP_RasterplanAenderung_refLegende" ("XP_RasterplanAenderung_gid") ;
CREATE INDEX "idx_fk_XP_RasterplanAenderung_refLegende2" ON "XP_Raster"."XP_RasterplanAenderung_refLegende" ("XP_ExterneReferenz_id") ;

GRANT SELECT ON TABLE "XP_Raster"."XP_RasterplanAenderung_refLegende" TO xp_gast;
GRANT ALL ON TABLE "XP_Raster"."XP_RasterplanAenderung_refLegende" TO xp_user;

-- -----------------------------------------------------
-- Table "XP_Basisobjekte"."XP_Plan"
-- -----------------------------------------------------
CREATE  TABLE  "XP_Basisobjekte"."XP_Plan" (
  "gid" INTEGER NOT NULL DEFAULT nextval('"XP_Basisobjekte"."XP_Plan_gid_seq"'),
  "name" VARCHAR(64) NOT NULL ,
  "nummer" VARCHAR(16) NULL ,
  "internalId" VARCHAR(255) NULL ,
  "beschreibung" VARCHAR(255) NULL ,
  "kommentar" VARCHAR(255) NULL ,
  "technHerstellDatum" DATE NULL ,
  "untergangsDatum" DATE NULL ,
  "erstellungsMassstab" INTEGER  NULL ,
  "xPlanGMLVersion" VARCHAR(8) NULL DEFAULT '4.0' ,
  "bezugshoehe" REAL NULL ,
  "refExternalCodeList" INTEGER NULL ,
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
COMMENT ON COLUMN "XP_Basisobjekte"."XP_Plan"."untergangsDatum" IS 'Datum, an dem der Plan (z.B. durch Ratsbeschluss oder Gerichtsurteil) aufgehoben oder für nichtig erklärt wurde.';
COMMENT ON COLUMN "XP_Basisobjekte"."XP_Plan"."erstellungsMassstab" IS 'Der bei der Erstellung des Plans benutzte Kartenmassstab.';
COMMENT ON COLUMN "XP_Basisobjekte"."XP_Plan"."xPlanGMLVersion" IS 'Version des XPlanGML-Schemas, nach dem der Datensatz erstellt wurde.';
COMMENT ON COLUMN "XP_Basisobjekte"."XP_Plan"."bezugshoehe" IS 'Standard Bezugshöhe (absolut NhN) für relative Höhenangaben von Planinhalten.';
COMMENT ON COLUMN "XP_Basisobjekte"."XP_Plan"."refExternalCodeList" IS 'Referenz auf ein GML-Dictionary mit Codelists.';
    
CREATE INDEX "idx_fk_XP_Plan_XP_ExterneReferenz1" ON "XP_Basisobjekte"."XP_Plan" ("refExternalCodeList") ;
CREATE TRIGGER "XP_Plan_hasChanged" AFTER INSERT OR UPDATE OR DELETE ON "XP_Basisobjekte"."XP_Plan" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."change_to_XP_Plan"();
GRANT SELECT ON TABLE "XP_Basisobjekte"."XP_Plan" TO xp_gast; 
GRANT ALL ON TABLE "XP_Basisobjekte"."XP_Plan" TO xp_user;

-- -----------------------------------------------------
-- Table "XP_Basisobjekte"."XP_Bereich"
-- -----------------------------------------------------
CREATE  TABLE  "XP_Basisobjekte"."XP_Bereich" (
  "gid" INTEGER NOT NULL DEFAULT nextval('"XP_Basisobjekte"."XP_Bereich_gid_seq"'),
  "nummer" INTEGER NOT NULL DEFAULT 0 ,
  "name" VARCHAR(255) NOT NULL ,
  "bedeutung" INTEGER NULL ,
  "detaillierteBedeutung" VARCHAR(255) NULL ,
  "erstellungsMassstab" INTEGER NULL ,
  "rasterBasis" INTEGER NULL,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_XP_Bereich_XP_BedeutungenBereich1"
    FOREIGN KEY ("bedeutung" )
    REFERENCES "XP_Basisobjekte"."XP_BedeutungenBereich" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
    CONSTRAINT "fk_XP_Bereich_XP_RasterplanBasis1"
    FOREIGN KEY ("rasterBasis" )
    REFERENCES "XP_Raster"."XP_RasterplanBasis" ("id" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
COMMENT ON TABLE "XP_Basisobjekte"."XP_Bereich" IS 'Abstrakte Oberklasse für die Modellierung von Planbereichen. Ein Planbereich fasst die Inhalte eines Plans nach bestimmten Kriterien zusammen.';
COMMENT ON COLUMN "XP_Basisobjekte"."XP_Bereich"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN "XP_Basisobjekte"."XP_Bereich"."nummer" IS 'Nummer des Bereichs. Wenn der Bereich als Ebene eines BPlans interpretiert wird, kann aus dem Attribut die vertikale Reihenfolge der Ebenen rekonstruiert werden.';
COMMENT ON COLUMN "XP_Basisobjekte"."XP_Bereich"."name" IS 'Bezeichnung des Bereiches';
COMMENT ON COLUMN "XP_Basisobjekte"."XP_Bereich"."bedeutung" IS 'Spezifikation der semantischen Bedeutung eines Bereiches.';
COMMENT ON COLUMN "XP_Basisobjekte"."XP_Bereich"."detaillierteBedeutung" IS 'Detaillierte Erklärung der semantischen Bedeutung eines Bereiches, in Ergänzung des Attributs bedeutung.';
COMMENT ON COLUMN "XP_Basisobjekte"."XP_Bereich"."erstellungsMassstab" IS 'Der bei der Erstellung der Inhalte des Planbereichs benutzte Kartenmassstab. Wenn dieses Attribut nicht spezifiziert ist, gilt für den Bereich der auf Planebene (XP_Plan) spezifizierte Masstab.';
COMMENT ON COLUMN "XP_Basisobjekte"."XP_Bereich"."rasterBasis" IS 'Ein Plan kann optional eine georeferenzierte Rasterkarte referieren.';
CREATE INDEX "idx_fk_XP_Bereich_XP_BedeutungenBereich1" ON "XP_Basisobjekte"."XP_Bereich" ("bedeutung") ;
CREATE INDEX "idx_fk_XP_Bereich_XP_RasterplanBasis1" ON "XP_Basisobjekte"."XP_Bereich" ("rasterBasis") ;
GRANT SELECT ON TABLE "XP_Basisobjekte"."XP_Bereich" TO xp_gast; 
GRANT ALL ON TABLE "XP_Basisobjekte"."XP_Bereich" TO xp_user;

-- -----------------------------------------------------
-- Table "XP_Basisobjekte"."XP_Objekt"
-- -----------------------------------------------------
CREATE  TABLE  "XP_Basisobjekte"."XP_Objekt" (
  "gid" INTEGER NOT NULL DEFAULT nextval('"XP_Basisobjekte"."XP_Objekt_gid_seq"'),
  "uuid" VARCHAR(64) NULL ,
  "text" VARCHAR(255) NULL ,
  "rechtsstand" INTEGER NULL ,
  "gesetzlicheGrundlage" INTEGER NULL ,
  "textSchluessel" VARCHAR(255) NULL ,
  "textSchluesselBegruendung" VARCHAR(255) NULL ,
  "gliederung1" VARCHAR(255) NULL ,
  "gliederung2" VARCHAR(255) NULL ,
  "ebene" INTEGER NULL DEFAULT 0 ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_XP_Objekt_XP_Rechtsstand1"
    FOREIGN KEY ("rechtsstand" )
    REFERENCES "XP_Enumerationen"."XP_Rechtsstand" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_XP_Objekt_xp_gesetzlichegrundlage1"
    FOREIGN KEY ("gesetzlicheGrundlage" )
    REFERENCES "XP_Basisobjekte"."XP_GesetzlicheGrundlage" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
COMMENT ON TABLE "XP_Basisobjekte"."XP_Objekt" IS 'Abstrakte Oberklasse für alle XPlanGML-Fachobjekte. Die Attribute dieser Klasse werden über den Vererbungs-Mechanismus an alle Fachobjekte weitergegeben.';
COMMENT ON COLUMN "XP_Basisobjekte"."XP_Objekt"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN "XP_Basisobjekte"."XP_Objekt"."uuid" IS 'Eindeutiger Identifier des Objektes.';
COMMENT ON COLUMN "XP_Basisobjekte"."XP_Objekt"."text" IS 'Beliebiger Text';
COMMENT ON COLUMN "XP_Basisobjekte"."XP_Objekt"."rechtsstand" IS 'Gibt an ob der Planinhalt bereits besteht, geplant ist, oder zukünftig wegfallen soll.';
COMMENT ON COLUMN "XP_Basisobjekte"."XP_Objekt"."gesetzlicheGrundlage" IS 'Angagbe der Gesetzlichen Grundlage des Planinhalts.';
COMMENT ON COLUMN "XP_Basisobjekte"."XP_Objekt"."textSchluessel" IS 'Abschnitts- oder Schlüsselnummer der Text-Abschnitte (XP_TextAbschnitt), die dem Objekt explizit zugeordnet sind.';
COMMENT ON COLUMN "XP_Basisobjekte"."XP_Objekt"."textSchluesselBegruendung" IS 'Abschnitts- oder Schlüsselnummer der Abschnitte der Begründung (XP_BegruendungAbschnitt), die dem Objekt explizit zugeordnet sind.';
COMMENT ON COLUMN "XP_Basisobjekte"."XP_Objekt"."gliederung1" IS 'Kennung im Plan für eine erste Gliederungsebene (z.B. GE-E für ein "Eingeschränktes Gewerbegebiet")';
COMMENT ON COLUMN "XP_Basisobjekte"."XP_Objekt"."gliederung2" IS 'Kennung im Plan für eine zweite Gliederungsebene (z.B. GE-E 3 für die "Variante 3 eines eingeschränkten Gewerbegebiets")';
COMMENT ON COLUMN "XP_Basisobjekte"."XP_Objekt"."ebene" IS 'Zuordnung des Objektes zu einer vertikalen Ebene.
Der Standard-Ebene 0 sind Objekte auf der Erdoberfläche zugeordnet.
Nur unter diesen Objekten wird der Flächenschluss hergestellt.
Bei Plan-Objekten, die unterirdische Bereiche (z.B. Tunnel) modellieren, ist ebene < 0.
Bei "überirdischen" Objekten (z.B. Festsetzungen auf Brücken) ist ebene > 0.';

CREATE INDEX "idx_fk_XP_Objekt_XP_Rechtsstand1" ON "XP_Basisobjekte"."XP_Objekt" ("rechtsstand") ;
CREATE INDEX "idx_fk_XP_Objekt_xp_gesetzlichegrundlage1" ON "XP_Basisobjekte"."XP_Objekt" ("gesetzlicheGrundlage") ;
GRANT SELECT ON TABLE "XP_Basisobjekte"."XP_Objekt" TO xp_gast; 
GRANT ALL ON TABLE "XP_Basisobjekte"."XP_Objekt" TO xp_user; 

-- -----------------------------------------------------
-- Table "XP_Basisobjekte"."XP_RechtscharakterPlanaenderung"
-- -----------------------------------------------------
CREATE  TABLE  "XP_Basisobjekte"."XP_RechtscharakterPlanaenderung" (
  "Wert" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Wert") );
GRANT SELECT ON TABLE "XP_Basisobjekte"."XP_RechtscharakterPlanaenderung" TO xp_gast;

-- -----------------------------------------------------
-- Table "XP_Basisobjekte"."XP_VerbundenerPlan"
-- -----------------------------------------------------
CREATE  TABLE  "XP_Basisobjekte"."XP_VerbundenerPlan" (
  "gid" INTEGER NOT NULL ,
  "planName" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("gid"));
COMMENT ON TABLE "XP_Basisobjekte"."XP_VerbundenerPlan" IS 'Spezifikation eines anderen Plans, der mit dem Ausgangsplan verbunden ist und diesen ändert bzw. von ihm geändert wird.';
COMMENT ON COLUMN "XP_Basisobjekte"."XP_VerbundenerPlan"."planName" IS 'Name (Attribut name von XP_Plan) des verbundenen Plans.';
GRANT SELECT ON TABLE "XP_Basisobjekte"."XP_VerbundenerPlan" TO xp_gast;
GRANT ALL ON TABLE "XP_Basisobjekte"."XP_VerbundenerPlan" TO xp_user;

-- -----------------------------------------------------
-- Table "XP_Basisobjekte"."aendert"
-- -----------------------------------------------------
CREATE  TABLE  "XP_Basisobjekte"."aendert" (
  "XP_Plan" INTEGER NOT NULL ,
  "XP_VerbundenerPlan" INTEGER NOT NULL ,
  "rechtscharakter" INTEGER NOT NULL DEFAULT 1000 ,
  PRIMARY KEY ("XP_Plan", "XP_VerbundenerPlan") ,
  CONSTRAINT "fk_XP_Plan_has_XP_VerbundenerPlan_XP_Plan1"
    FOREIGN KEY ("XP_Plan" )
    REFERENCES "XP_Basisobjekte"."XP_Plan" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_XP_Plan_has_XP_VerbundenerPlan_XP_VerbundenerPlan1"
    FOREIGN KEY ("XP_VerbundenerPlan" )
    REFERENCES "XP_Basisobjekte"."XP_VerbundenerPlan" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_aendert_XP_RechtscharakterPlanaenderung1"
    FOREIGN KEY ("rechtscharakter" )
    REFERENCES "XP_Basisobjekte"."XP_RechtscharakterPlanaenderung" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
GRANT SELECT ON TABLE "XP_Basisobjekte"."aendert" TO xp_gast;
GRANT ALL ON TABLE "XP_Basisobjekte"."aendert" TO xp_user;
CREATE INDEX "idx_fk_aendert_XP_Plan1" ON "XP_Basisobjekte"."aendert" ("XP_Plan") ;
CREATE INDEX "idx_fk_aendert_XP_VerbundenerPlan1" ON "XP_Basisobjekte"."aendert" ("XP_VerbundenerPlan") ;
CREATE INDEX "idx_fk_aendert_XP_RechtscharakterPlanaenderung1" ON "XP_Basisobjekte"."aendert" ("rechtscharakter") ;
COMMENT ON TABLE  "XP_Basisobjekte"."aendert" IS 'Bezeichnung eines anderen Planes der Gemeinde, der durch den vorliegenden Plan geändert wird.';
COMMENT ON COLUMN "XP_Basisobjekte"."aendert"."rechtscharakter" IS 'Rechtscharakter der Planänderung.';

-- -----------------------------------------------------
-- Table "XP_Basisobjekte"."wurdeGeaendertVon"
-- -----------------------------------------------------
CREATE  TABLE  "XP_Basisobjekte"."wurdeGeaendertVon" (
  "XP_Plan" INTEGER NOT NULL ,
  "XP_VerbundenerPlan" INTEGER NOT NULL ,
  "rechtscharakter" INTEGER NOT NULL DEFAULT 1000 ,
  PRIMARY KEY ("XP_Plan", "XP_VerbundenerPlan") ,
  CONSTRAINT "fk_XP_Plan_has_XP_VerbundenerPlan_XP_Plan2"
    FOREIGN KEY ("XP_Plan" )
    REFERENCES "XP_Basisobjekte"."XP_Plan" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_XP_Plan_has_XP_VerbundenerPlan_XP_VerbundenerPlan2"
    FOREIGN KEY ("XP_VerbundenerPlan" )
    REFERENCES "XP_Basisobjekte"."XP_VerbundenerPlan" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_wurdeGeaendertVon_XP_RechtscharakterPlanaenderung1"
    FOREIGN KEY ("rechtscharakter" )
    REFERENCES "XP_Basisobjekte"."XP_RechtscharakterPlanaenderung" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
GRANT SELECT ON TABLE "XP_Basisobjekte"."wurdeGeaendertVon" TO xp_gast;
GRANT ALL ON TABLE "XP_Basisobjekte"."wurdeGeaendertVon" TO xp_user;
CREATE INDEX "idx_fk_wurdeGeaendertVon_XP_Plan1" ON "XP_Basisobjekte"."wurdeGeaendertVon" ("XP_Plan") ;
CREATE INDEX "idx_fk_wurdeGeaendertVon_XP_VerbundenerPlan1" ON "XP_Basisobjekte"."wurdeGeaendertVon" ("XP_VerbundenerPlan") ;
CREATE INDEX "idx_fk_wurdeGeaendertVon_XP_RechtscharakterPlanaenderung1" ON "XP_Basisobjekte"."wurdeGeaendertVon" ("rechtscharakter") ;
COMMENT ON TABLE  "XP_Basisobjekte"."wurdeGeaendertVon" IS 'Bezeichnung eines anderen Plans , durch den der vorliegende Plan geändert wurde.';
COMMENT ON COLUMN "XP_Basisobjekte"."wurdeGeaendertVon"."rechtscharakter" IS 'Rechtscharakter der Planänderung.';

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
    FOREIGN KEY ("XP_Plan_gid" )
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
-- Table "XP_Basisobjekte"."gehoertNachrichtlichZuBereich"
-- -----------------------------------------------------
CREATE  TABLE  "XP_Basisobjekte"."gehoertNachrichtlichZuBereich" (
  "XP_Bereich_gid" INTEGER NOT NULL ,
  "XP_Objekt_gid" INTEGER NOT NULL ,
  PRIMARY KEY ("XP_Bereich_gid", "XP_Objekt_gid") ,
  CONSTRAINT "fk_XP_Bereich_has_XP_Objekt_XP_Bereich1"
    FOREIGN KEY ("XP_Bereich_gid" )
    REFERENCES "XP_Basisobjekte"."XP_Bereich" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_XP_Bereich_has_XP_Objekt_XP_Objekt1"
    FOREIGN KEY ("XP_Objekt_gid" )
    REFERENCES "XP_Basisobjekte"."XP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE);
COMMENT ON TABLE "XP_Basisobjekte"."gehoertNachrichtlichZuBereich" IS 'Über diese Relation wird angezeigt, dass ein Fachobjekt vom referierten Planbereich als "nachrichtlich übernommen" referiert wird.';
CREATE INDEX "idx_fk_XP_Bereich_has_XP_Objekt_XP_Bereich1" ON "XP_Basisobjekte"."gehoertNachrichtlichZuBereich" ("XP_Bereich_gid") ;
CREATE INDEX "idx_fk_XP_Bereich_has_XP_Objekt_XP_Objekt1" ON "XP_Basisobjekte"."gehoertNachrichtlichZuBereich" ("XP_Objekt_gid") ;

GRANT SELECT ON TABLE "XP_Basisobjekte"."gehoertNachrichtlichZuBereich" TO xp_gast;
GRANT ALL ON TABLE "XP_Basisobjekte"."gehoertNachrichtlichZuBereich" TO xp_user;

-- -----------------------------------------------------
-- Table "XP_Basisobjekte"."XP_Objekt_rechtsverbindlich"
-- -----------------------------------------------------
CREATE  TABLE  "XP_Basisobjekte"."XP_Objekt_rechtsverbindlich" (
  "XP_Objekt_gid" INTEGER NOT NULL ,
  "XP_ExterneReferenz_id" INTEGER NOT NULL ,
  PRIMARY KEY ("XP_Objekt_gid", "XP_ExterneReferenz_id") ,
  CONSTRAINT "fk_XP_Objekt_rechtsverbindlich1"
    FOREIGN KEY ("XP_Objekt_gid" )
    REFERENCES "XP_Basisobjekte"."XP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_XP_Plan_has_XP_ExterneReferenz_XP_ExterneReferenz1"
    FOREIGN KEY ("XP_ExterneReferenz_id" )
    REFERENCES "XP_Basisobjekte"."XP_ExterneReferenz" ("id" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
COMMENT ON TABLE "XP_Basisobjekte"."XP_Objekt_rechtsverbindlich" IS 'Referenz auf rechtsverbindliche Dokumente';
CREATE INDEX "idx_fk_XP_Objekt_has_XP_ExterneReferenz_XP_Objekt1" ON "XP_Basisobjekte"."XP_Objekt_rechtsverbindlich" ("XP_Objekt_gid") ;
CREATE INDEX "idx_fk_XP_Objekt_has_XP_ExterneReferenz_XP_ExterneReferenz1" ON "XP_Basisobjekte"."XP_Objekt_rechtsverbindlich" ("XP_ExterneReferenz_id") ;

GRANT SELECT ON TABLE "XP_Basisobjekte"."XP_Objekt_rechtsverbindlich" TO xp_gast;
GRANT ALL ON TABLE "XP_Basisobjekte"."XP_Objekt_rechtsverbindlich" TO xp_user;

-- -----------------------------------------------------
-- Table "XP_Basisobjekte"."XP_Objekt_informell"
-- -----------------------------------------------------
CREATE  TABLE  "XP_Basisobjekte"."XP_Objekt_informell" (
  "XP_Objekt_gid" INTEGER NOT NULL ,
  "XP_ExterneReferenz_id" INTEGER NOT NULL ,
  PRIMARY KEY ("XP_Objekt_gid", "XP_ExterneReferenz_id") ,
  CONSTRAINT "fk_XP_Objekt_informell2"
    FOREIGN KEY ("XP_Objekt_gid" )
    REFERENCES "XP_Basisobjekte"."XP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_XP_Plan_has_XP_ExterneReferenz_XP_ExterneReferenz2"
    FOREIGN KEY ("XP_ExterneReferenz_id" )
    REFERENCES "XP_Basisobjekte"."XP_ExterneReferenz" ("id" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
COMMENT ON TABLE "XP_Basisobjekte"."XP_Objekt_informell" IS 'Referenz auf nicht-rechtsverbindliche Dokumente';
CREATE INDEX "idx_fk_XP_Objekt_has_XP_ExterneReferenz_XP_Objekt2" ON "XP_Basisobjekte"."XP_Objekt_informell" ("XP_Objekt_gid") ;
CREATE INDEX "idx_fk_XP_Objekt_has_XP_ExterneReferenz_XP_ExterneReferenz2" ON "XP_Basisobjekte"."XP_Objekt_informell" ("XP_ExterneReferenz_id") ;

GRANT SELECT ON TABLE "XP_Basisobjekte"."XP_Objekt_informell" TO xp_gast;
GRANT ALL ON TABLE "XP_Basisobjekte"."XP_Objekt_informell" TO xp_user;

-- -----------------------------------------------------
-- Table "XP_Basisobjekte"."XP_Plan_rechtsverbindlich"
-- -----------------------------------------------------
CREATE  TABLE  "XP_Basisobjekte"."XP_Plan_rechtsverbindlich" (
  "XP_Plan_gid" INTEGER NOT NULL ,
  "XP_ExterneReferenz_id" INTEGER NOT NULL ,
  PRIMARY KEY ("XP_Plan_gid", "XP_ExterneReferenz_id") ,
  CONSTRAINT "fk_XP_Plan_has_XP_ExterneReferenz_XP_Plan1"
    FOREIGN KEY ("XP_Plan_gid" )
    REFERENCES "XP_Basisobjekte"."XP_Plan" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_XP_Plan_has_XP_ExterneReferenz_XP_ExterneReferenz1"
    FOREIGN KEY ("XP_ExterneReferenz_id" )
    REFERENCES "XP_Basisobjekte"."XP_ExterneReferenz" ("id" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
COMMENT ON TABLE "XP_Basisobjekte"."XP_Plan_rechtsverbindlich" IS 'Referenz auf rechtsverbindliche Dokumente';
CREATE INDEX "idx_fk_XP_Plan_has_XP_ExterneReferenz_XP_Plan1" ON "XP_Basisobjekte"."XP_Plan_rechtsverbindlich" ("XP_Plan_gid") ;
CREATE INDEX "idx_fk_XP_Plan_has_XP_ExterneReferenz_XP_ExterneReferenz1" ON "XP_Basisobjekte"."XP_Plan_rechtsverbindlich" ("XP_ExterneReferenz_id") ;

GRANT SELECT ON TABLE "XP_Basisobjekte"."XP_Plan_rechtsverbindlich" TO xp_gast;
GRANT ALL ON TABLE "XP_Basisobjekte"."XP_Plan_rechtsverbindlich" TO xp_user;

-- -----------------------------------------------------
-- Table "XP_Basisobjekte"."XP_Plan_informell"
-- -----------------------------------------------------
CREATE  TABLE  "XP_Basisobjekte"."XP_Plan_informell" (
  "XP_Plan_gid" INTEGER NOT NULL ,
  "XP_ExterneReferenz_id" INTEGER NOT NULL ,
  PRIMARY KEY ("XP_Plan_gid", "XP_ExterneReferenz_id") ,
  CONSTRAINT "fk_XP_Plan_has_XP_ExterneReferenz_XP_Plan2"
    FOREIGN KEY ("XP_Plan_gid" )
    REFERENCES "XP_Basisobjekte"."XP_Plan" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_XP_Plan_has_XP_ExterneReferenz_XP_ExterneReferenz2"
    FOREIGN KEY ("XP_ExterneReferenz_id" )
    REFERENCES "XP_Basisobjekte"."XP_ExterneReferenz" ("id" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
COMMENT ON TABLE "XP_Basisobjekte"."XP_Plan_informell" IS 'Referenz auf nicht-rechtsverbindliche Dokumente';
CREATE INDEX "idx_fk_XP_Plan_has_XP_ExterneReferenz_XP_Plan2" ON "XP_Basisobjekte"."XP_Plan_informell" ("XP_Plan_gid") ;
CREATE INDEX "idx_fk_XP_Plan_has_XP_ExterneReferenz_XP_ExterneReferenz2" ON "XP_Basisobjekte"."XP_Plan_informell" ("XP_ExterneReferenz_id") ;

GRANT SELECT ON TABLE "XP_Basisobjekte"."XP_Plan_informell" TO xp_gast;
GRANT ALL ON TABLE "XP_Basisobjekte"."XP_Plan_informell" TO xp_user;

-- -----------------------------------------------------
-- Table "XP_Basisobjekte"."refBeschreibung"
-- -----------------------------------------------------
CREATE  TABLE  "XP_Basisobjekte"."refBeschreibung" (
  "XP_Plan_gid" INTEGER NOT NULL ,
  "XP_ExterneReferenz_id" INTEGER NOT NULL ,
  PRIMARY KEY ("XP_Plan_gid", "XP_ExterneReferenz_id") ,
  CONSTRAINT "fk_XP_Plan_has_XP_ExterneReferenz_XP_Plan3"
    FOREIGN KEY ("XP_Plan_gid" )
    REFERENCES "XP_Basisobjekte"."XP_Plan" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_XP_Plan_has_XP_ExterneReferenz_XP_ExterneReferenz3"
    FOREIGN KEY ("XP_ExterneReferenz_id" )
    REFERENCES "XP_Basisobjekte"."XP_ExterneReferenz" ("id" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
COMMENT ON TABLE "XP_Basisobjekte"."refBeschreibung" IS 'Referenz auf die Beschreibung des Plans.';
CREATE INDEX "idx_fk_XP_Plan_has_XP_ExterneReferenz_XP_Plan3" ON "XP_Basisobjekte"."refBeschreibung" ("XP_Plan_gid") ;
CREATE INDEX "idx_fk_XP_Plan_has_XP_ExterneReferenz_XP_ExterneReferenz3" ON "XP_Basisobjekte"."refBeschreibung" ("XP_ExterneReferenz_id") ;

GRANT SELECT ON TABLE "XP_Basisobjekte"."refBeschreibung" TO xp_gast;
GRANT ALL ON TABLE "XP_Basisobjekte"."refBeschreibung" TO xp_user;

-- -----------------------------------------------------
-- Table "XP_Basisobjekte"."refBegruendung"
-- -----------------------------------------------------
CREATE  TABLE  "XP_Basisobjekte"."refBegruendung" (
  "XP_Plan_gid" INTEGER NOT NULL ,
  "XP_ExterneReferenz_id" INTEGER NOT NULL ,
  PRIMARY KEY ("XP_Plan_gid", "XP_ExterneReferenz_id") ,
  CONSTRAINT "fk_XP_Plan_has_XP_ExterneReferenz_XP_Plan4"
    FOREIGN KEY ("XP_Plan_gid" )
    REFERENCES "XP_Basisobjekte"."XP_Plan" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_XP_Plan_has_XP_ExterneReferenz_XP_ExterneReferenz4"
    FOREIGN KEY ("XP_ExterneReferenz_id" )
    REFERENCES "XP_Basisobjekte"."XP_ExterneReferenz" ("id" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
COMMENT ON TABLE "XP_Basisobjekte"."refBegruendung" IS 'Referenz auf die Begründung des Plans.';
CREATE INDEX "idx_fk_XP_Plan_has_XP_ExterneReferenz_XP_Plan4" ON "XP_Basisobjekte"."refBegruendung" ("XP_Plan_gid") ;
CREATE INDEX "idx_fk_XP_Plan_has_XP_ExterneReferenz_XP_ExterneReferenz4" ON "XP_Basisobjekte"."refBegruendung" ("XP_ExterneReferenz_id") ;

GRANT SELECT ON TABLE "XP_Basisobjekte"."refBegruendung" TO xp_gast;
GRANT ALL ON TABLE "XP_Basisobjekte"."refBegruendung" TO xp_user;

-- -----------------------------------------------------
-- Table "XP_Basisobjekte"."refLegende"
-- -----------------------------------------------------
CREATE  TABLE  "XP_Basisobjekte"."refLegende" (
  "XP_Plan_gid" INTEGER NOT NULL ,
  "XP_ExterneReferenz_id" INTEGER NOT NULL ,
  PRIMARY KEY ("XP_Plan_gid", "XP_ExterneReferenz_id") ,
  CONSTRAINT "fk_XP_Plan_has_XP_ExterneReferenz_XP_Plan5"
    FOREIGN KEY ("XP_Plan_gid" )
    REFERENCES "XP_Basisobjekte"."XP_Plan" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_XP_Plan_has_XP_ExterneReferenz_XP_ExterneReferenz5"
    FOREIGN KEY ("XP_ExterneReferenz_id" )
    REFERENCES "XP_Basisobjekte"."XP_ExterneReferenz" ("id" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
COMMENT ON TABLE "XP_Basisobjekte"."refLegende" IS 'Referenz auf die Legende des Plans.';
CREATE INDEX "idx_fk_XP_Plan_has_XP_ExterneReferenz_XP_Plan5" ON "XP_Basisobjekte"."refLegende" ("XP_Plan_gid") ;
CREATE INDEX "idx_fk_XP_Plan_has_XP_ExterneReferenz_XP_ExterneReferenz5" ON "XP_Basisobjekte"."refLegende" ("XP_ExterneReferenz_id") ;

GRANT SELECT ON TABLE "XP_Basisobjekte"."refLegende" TO xp_gast;
GRANT ALL ON TABLE "XP_Basisobjekte"."refLegende" TO xp_user;

-- -----------------------------------------------------
-- Table "XP_Basisobjekte"."refRechtsplan"
-- -----------------------------------------------------
CREATE  TABLE  "XP_Basisobjekte"."refRechtsplan" (
  "XP_Plan_gid" INTEGER NOT NULL ,
  "XP_ExterneReferenz_id" INTEGER NOT NULL ,
  PRIMARY KEY ("XP_Plan_gid", "XP_ExterneReferenz_id") ,
  CONSTRAINT "fk_XP_Plan_has_XP_ExterneReferenz_XP_Plan6"
    FOREIGN KEY ("XP_Plan_gid" )
    REFERENCES "XP_Basisobjekte"."XP_Plan" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_XP_Plan_has_XP_ExterneReferenz_XP_ExterneReferenz6"
    FOREIGN KEY ("XP_ExterneReferenz_id" )
    REFERENCES "XP_Basisobjekte"."XP_ExterneReferenz" ("id" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
COMMENT ON TABLE "XP_Basisobjekte"."refRechtsplan" IS 'Referenz auf eine elektronische Version des rechtsverbindlichen Plans.';
CREATE INDEX "idx_fk_XP_Plan_has_XP_ExterneReferenz_XP_Plan6" ON "XP_Basisobjekte"."refRechtsplan" ("XP_Plan_gid") ;
CREATE INDEX "idx_fk_XP_Plan_has_XP_ExterneReferenz_XP_ExterneReferenz6" ON "XP_Basisobjekte"."refRechtsplan" ("XP_ExterneReferenz_id") ;

GRANT SELECT ON TABLE "XP_Basisobjekte"."refRechtsplan" TO xp_gast;
GRANT ALL ON TABLE "XP_Basisobjekte"."refRechtsplan" TO xp_user;

-- -----------------------------------------------------
-- Table "XP_Basisobjekte"."refPlangrundlage"
-- -----------------------------------------------------
CREATE  TABLE  "XP_Basisobjekte"."refPlangrundlage" (
  "XP_Plan_gid" INTEGER NOT NULL ,
  "XP_ExterneReferenz_id" INTEGER NOT NULL ,
  PRIMARY KEY ("XP_Plan_gid", "XP_ExterneReferenz_id") ,
  CONSTRAINT "fk_XP_Plan_has_XP_ExterneReferenz_XP_Plan7"
    FOREIGN KEY ("XP_Plan_gid" )
    REFERENCES "XP_Basisobjekte"."XP_Plan" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_XP_Plan_has_XP_ExterneReferenz_XP_ExterneReferenz7"
    FOREIGN KEY ("XP_ExterneReferenz_id" )
    REFERENCES "XP_Basisobjekte"."XP_ExterneReferenz" ("id" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
COMMENT ON TABLE "XP_Basisobjekte"."refPlangrundlage" IS 'Referenz auf eine elektronische Version der Plangrundlage, z.B. ein Katasterplan.';
CREATE INDEX "idx_fk_XP_Plan_has_XP_ExterneReferenz_XP_Plan7" ON "XP_Basisobjekte"."refPlangrundlage" ("XP_Plan_gid") ;
CREATE INDEX "idx_fk_XP_Plan_has_XP_ExterneReferenz_XP_ExterneReferenz7" ON "XP_Basisobjekte"."refPlangrundlage" ("XP_ExterneReferenz_id") ;

GRANT SELECT ON TABLE "XP_Basisobjekte"."refPlangrundlage" TO xp_gast;
GRANT ALL ON TABLE "XP_Basisobjekte"."refPlangrundlage" TO xp_user;

-- -----------------------------------------------------
-- Table "XP_Basisobjekte"."XP_TextAbschnitt"
-- -----------------------------------------------------
CREATE  TABLE  "XP_Basisobjekte"."XP_TextAbschnitt" (
  "id" INTEGER NOT NULL DEFAULT nextval('"XP_Basisobjekte"."XP_TextAbschnitt_id_seq"'),
  "schluessel" VARCHAR(255) NULL ,
  "gesetzlicheGrundlage" VARCHAR(255) NULL ,
  "text" VARCHAR(1024) NULL ,
  "refText" INTEGER NULL ,
  PRIMARY KEY ("id") ,
  CONSTRAINT "fk_XP_TextAbschnitt_XP_ExterneReferenz1"
    FOREIGN KEY ("refText" )
    REFERENCES "XP_Basisobjekte"."XP_ExterneReferenz" ("id" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
COMMENT ON TABLE "XP_Basisobjekte"."XP_TextAbschnitt" IS 'Ein Abschnitt der textlich formulierten Inhalte des Plans.';
COMMENT ON COLUMN "XP_Basisobjekte"."XP_TextAbschnitt"."schluessel" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN "XP_Basisobjekte"."XP_TextAbschnitt"."schluessel" IS 'Schlüssel zur Referenzierung des Abschnitts.';
COMMENT ON COLUMN "XP_Basisobjekte"."XP_TextAbschnitt"."gesetzlicheGrundlage" IS 'Gesetzliche Grundlage des Text-Abschnittes';
COMMENT ON COLUMN "XP_Basisobjekte"."XP_TextAbschnitt"."text" IS 'Inhalt eines Abschnitts der textlichen Planinhalte';
COMMENT ON COLUMN "XP_Basisobjekte"."XP_TextAbschnitt"."refText" IS 'Referenz auf ein externes Dokument das den Textabschnitt enthält.';
CREATE INDEX "idx_fk_XP_TextAbschnitt_XP_ExterneReferenz1" ON "XP_Basisobjekte"."XP_TextAbschnitt" ("refText") ;

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

GRANT SELECT ON TABLE "XP_Basisobjekte"."XP_BegruendungAbschnitt" TO xp_gast;
GRANT ALL ON TABLE "XP_Basisobjekte"."XP_BegruendungAbschnitt" TO xp_user;

-- -----------------------------------------------------
-- Table "XP_Basisobjekte"."begruendungsTexte"
-- -----------------------------------------------------
CREATE  TABLE  "XP_Basisobjekte"."begruendungsTexte" (
  "XP_Plan_gid" INTEGER NOT NULL ,
  "XP_BegruendungAbschnitt_id" INTEGER NOT NULL ,
  PRIMARY KEY ("XP_Plan_gid", "XP_BegruendungAbschnitt_id") ,
  CONSTRAINT "fk_XP_Plan_has_XP_BegruendungAbschnitt_XP_Plan1"
    FOREIGN KEY ("XP_Plan_gid" )
    REFERENCES "XP_Basisobjekte"."XP_Plan" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_XP_Plan_has_XP_BegruendungAbschnitt_XP_BegruendungAbschnitt1"
    FOREIGN KEY ("XP_BegruendungAbschnitt_id" )
    REFERENCES "XP_Basisobjekte"."XP_BegruendungAbschnitt" ("id" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
COMMENT ON TABLE "XP_Basisobjekte"."begruendungsTexte" IS 'Verweis auf eine Abschnitt der Begründung.';
CREATE INDEX "idx_fk_begruendungsTexte_XP_Plan1" ON "XP_Basisobjekte"."begruendungsTexte" ("XP_Plan_gid") ;
CREATE INDEX "idx_fk_begruendungsTexte_XP_BegruendungAbschnitt1" ON "XP_Basisobjekte"."begruendungsTexte" ("XP_BegruendungAbschnitt_id") ;

GRANT SELECT ON TABLE "XP_Basisobjekte"."begruendungsTexte" TO xp_gast;
GRANT ALL ON TABLE "XP_Basisobjekte"."begruendungsTexte" TO xp_user;

-- -----------------------------------------------------
-- Table "XP_Basisobjekte"."texte"
-- -----------------------------------------------------
CREATE  TABLE  "XP_Basisobjekte"."texte" (
  "XP_Plan_gid" INTEGER NOT NULL ,
  "XP_TextAbschnitt_id" INTEGER NOT NULL ,
  PRIMARY KEY ("XP_Plan_gid", "XP_TextAbschnitt_id") ,
  CONSTRAINT "fk_XP_Plan_has_XP_TextAbschnitt_XP_Plan1"
    FOREIGN KEY ("XP_Plan_gid" )
    REFERENCES "XP_Basisobjekte"."XP_Plan" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_XP_Plan_has_XP_TextAbschnitt_XP_TextAbschnitt1"
    FOREIGN KEY ("XP_TextAbschnitt_id" )
    REFERENCES "XP_Basisobjekte"."XP_TextAbschnitt" ("id" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
COMMENT ON TABLE "XP_Basisobjekte"."texte" IS 'Verweis auf einen textuell formulierten Planinhalt';
CREATE INDEX "idx_fk_XP_Plan_has_XP_TextAbschnitt_XP_Plan1" ON "XP_Basisobjekte"."texte" ("XP_Plan_gid") ;
CREATE INDEX "idx_fk_XP_Plan_has_XP_TextAbschnitt_XP_TextAbschnitt1" ON "XP_Basisobjekte"."texte" ("XP_TextAbschnitt_id") ;

GRANT SELECT ON TABLE "XP_Basisobjekte"."texte" TO xp_gast;
GRANT ALL ON TABLE "XP_Basisobjekte"."texte" TO xp_user;

-- -----------------------------------------------------
-- Table "XP_Praesentationsobjekte"."XP_StylesheetListe"
-- -----------------------------------------------------
CREATE  TABLE  "XP_Praesentationsobjekte"."XP_StylesheetListe" (
  "Wert" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Wert") );

GRANT SELECT ON TABLE "XP_Praesentationsobjekte"."XP_StylesheetListe" TO xp_gast;
GRANT ALL ON TABLE "XP_Praesentationsobjekte"."XP_StylesheetListe" TO xp_user;

-- -----------------------------------------------------
-- Table "XP_Praesentationsobjekte"."XP_AbstraktesPraesentationsobjekt"
-- -----------------------------------------------------
CREATE  TABLE  "XP_Praesentationsobjekte"."XP_AbstraktesPraesentationsobjekt" (
  "gid" INTEGER NOT NULL DEFAULT nextval('"XP_Praesentationsobjekte"."XP_APObjekt_gid_seq"'),
  "stylesheetId" INTEGER NULL ,
  "darstellungsprioritaet" INTEGER NULL ,
  "gehoertZuBereich" INTEGER NULL ,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_xp_abstraktespraesentationsobjekt_XP_Bereich1"
    FOREIGN KEY ("gehoertZuBereich" )
    REFERENCES "XP_Basisobjekte"."XP_Bereich" ("gid" )
    ON DELETE SET NULL
    ON UPDATE CASCADE,
  CONSTRAINT "fk_XP_AbstraktesPraesentationsobjekt_xp_stylesheetliste1"
    FOREIGN KEY ("stylesheetId" )
    REFERENCES "XP_Praesentationsobjekte"."XP_StylesheetListe" ("Wert" )
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
CREATE INDEX "idx_fk_xp_abstraktespraesentationsobjekt_XP_Bereich1" ON "XP_Praesentationsobjekte"."XP_AbstraktesPraesentationsobjekt" ("gehoertZuBereich") ;
CREATE INDEX "idx_fk_XP_AbstraktesPraesentationsobjekt_xp_stylesheetliste1" ON "XP_Praesentationsobjekte"."XP_AbstraktesPraesentationsobjekt" ("stylesheetId") ;
GRANT SELECT ON TABLE "XP_Praesentationsobjekte"."XP_AbstraktesPraesentationsobjekt" TO xp_gast;
GRANT ALL ON TABLE "XP_Praesentationsobjekte"."XP_AbstraktesPraesentationsobjekt" TO xp_user; 

-- -----------------------------------------------------
-- Table "XP_Praesentationsobjekte"."dientZurDarstellungVon"
-- -----------------------------------------------------
CREATE  TABLE  "XP_Praesentationsobjekte"."dientZurDarstellungVon" (
  "XP_APObjekt_gid" INTEGER NOT NULL ,
  "XP_Objekt_gid" INTEGER NOT NULL ,
  "art" VARCHAR(255) NOT NULL ,
  PRIMARY KEY ("XP_APObjekt_gid", "XP_Objekt_gid") ,
  CONSTRAINT "fk_dientzurdarstellungvon_XP_AbstraktesPraesentationsobjekt1"
    FOREIGN KEY ("XP_APObjekt_gid" )
    REFERENCES "XP_Praesentationsobjekte"."XP_AbstraktesPraesentationsobjekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_dientzurdarstellungvon_XP_Objekt1"
    FOREIGN KEY ("XP_Objekt_gid" )
    REFERENCES "XP_Basisobjekte"."XP_Objekt" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE);
COMMENT ON TABLE "XP_Praesentationsobjekte"."dientZurDarstellungVon" IS 'Relation zu XP_Objekt';
COMMENT ON COLUMN "XP_Praesentationsobjekte"."dientZurDarstellungVon"."art" IS 'Gibt den Namen des Attributs an, das mit dem Präsentationsobjekt dargestellt werden soll.';
CREATE INDEX "idx_fk_dientzurdarstellungvon_XP_APO1" ON "XP_Praesentationsobjekte"."dientZurDarstellungVon" ("XP_APObjekt_gid") ;
CREATE INDEX "idx_fk_dientzurdarstellungvon_XP_Objekt1" ON "XP_Praesentationsobjekte"."dientZurDarstellungVon" ("XP_Objekt_gid") ;
GRANT SELECT ON TABLE "XP_Praesentationsobjekte"."dientZurDarstellungVon" TO xp_gast;
GRANT ALL ON TABLE "XP_Praesentationsobjekte"."dientZurDarstellungVon" TO xp_user;

-- -----------------------------------------------------
-- Table "XP_Praesentationsobjekte"."XP_PPO"
-- -----------------------------------------------------
CREATE  TABLE  "XP_Praesentationsobjekte"."XP_PPO" (
  "gid" INTEGER NOT NULL ,
  "position" GEOMETRY NOT NULL ,
  "drehwinkel" INTEGER NULL DEFAULT 0 ,
  "skalierung" REAL NULL DEFAULT 1 ,
  PRIMARY KEY ("gid") );
COMMENT ON TABLE "XP_Praesentationsobjekte"."XP_PPO" IS 'Punktförmiges Präsentationsobjekt.';
COMMENT ON COLUMN "XP_Praesentationsobjekte"."XP_PPO"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN "XP_Praesentationsobjekte"."XP_PPO"."drehwinkel" IS 'Winkel um den der Text oder die Signatur mit punktförmiger Bezugsgeometrie aus der Horizontalen gedreht ist. Angabe im Bogenmaß; Zählweise im mathematisch positiven Sinn (von Ost über Nord nach West und Süd).';
COMMENT ON COLUMN "XP_Praesentationsobjekte"."XP_PPO"."skalierung" IS 'Skalierungsfaktor für Symbole.';
CREATE TRIGGER "XP_PPO_hasInsert" BEFORE INSERT OR UPDATE OR DELETE ON "XP_Praesentationsobjekte"."XP_PPO" FOR EACH ROW EXECUTE PROCEDURE "XP_Praesentationsobjekte"."child_of_XP_APObjekt"();
GRANT SELECT ON TABLE "XP_Praesentationsobjekte"."XP_PPO" TO xp_gast;
GRANT ALL ON TABLE "XP_Praesentationsobjekte"."XP_PPO" TO xp_user;

-- -----------------------------------------------------
-- Table "XP_Praesentationsobjekte"."XP_FPO"
-- -----------------------------------------------------
CREATE  TABLE  "XP_Praesentationsobjekte"."XP_FPO" (
  "gid" INTEGER NOT NULL ,
  "position" GEOMETRY NOT NULL ,
  PRIMARY KEY ("gid") );
COMMENT ON TABLE "XP_Praesentationsobjekte"."XP_FPO" IS 'Flächenförmiges Präsentationsobjekt.';
COMMENT ON COLUMN "XP_Praesentationsobjekte"."XP_FPO"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "XP_FPO_hasInsert" BEFORE INSERT OR UPDATE OR DELETE ON "XP_Praesentationsobjekte"."XP_FPO" FOR EACH ROW EXECUTE PROCEDURE "XP_Praesentationsobjekte"."child_of_XP_APObjekt"();
CREATE TRIGGER "XP_FPO_RHR" BEFORE INSERT OR UPDATE ON "XP_Praesentationsobjekte"."XP_FPO" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."positionFollowsRHR"();
GRANT SELECT ON TABLE "XP_Praesentationsobjekte"."XP_FPO" TO xp_gast;
GRANT ALL ON TABLE "XP_Praesentationsobjekte"."XP_FPO" TO xp_user;

-- -----------------------------------------------------
-- Table "XP_Praesentationsobjekte"."XP_LPO"
-- -----------------------------------------------------
CREATE  TABLE  "XP_Praesentationsobjekte"."XP_LPO" (
  "gid" INTEGER NOT NULL ,
  "position" GEOMETRY NOT NULL ,
  PRIMARY KEY ("gid") );
COMMENT ON TABLE "XP_Praesentationsobjekte"."XP_LPO" IS 'Linienförmiges Präsentationsobjekt.';
COMMENT ON COLUMN "XP_Praesentationsobjekte"."XP_LPO"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "XP_LPO_hasInsert" BEFORE INSERT OR UPDATE OR DELETE ON "XP_Praesentationsobjekte"."XP_LPO" FOR EACH ROW EXECUTE PROCEDURE "XP_Praesentationsobjekte"."child_of_XP_APObjekt"();
GRANT SELECT ON TABLE "XP_Praesentationsobjekte"."XP_LPO" TO xp_gast;
GRANT ALL ON TABLE "XP_Praesentationsobjekte"."XP_LPO" TO xp_user;

-- -----------------------------------------------------
-- Table "XP_Praesentationsobjekte"."XP_VertikaleAusrichtung"
-- -----------------------------------------------------
CREATE  TABLE  "XP_Praesentationsobjekte"."XP_VertikaleAusrichtung" (
  "Wert" VARCHAR(64) NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Wert") );
  
GRANT SELECT ON TABLE "XP_Praesentationsobjekte"."XP_VertikaleAusrichtung" TO xp_gast;

-- -----------------------------------------------------
-- Table "XP_Praesentationsobjekte"."XP_HorizontaleAusrichtung"
-- -----------------------------------------------------
CREATE  TABLE  "XP_Praesentationsobjekte"."XP_HorizontaleAusrichtung" (
  "Wert" VARCHAR(64) NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Wert") );
  
GRANT SELECT ON TABLE "XP_Praesentationsobjekte"."XP_HorizontaleAusrichtung" TO xp_gast;

-- -----------------------------------------------------
-- Table "XP_Praesentationsobjekte"."XP_TPO"
-- -----------------------------------------------------
CREATE  TABLE  "XP_Praesentationsobjekte"."XP_TPO" (
  "gid" INTEGER NOT NULL ,
  "schriftinhalt" VARCHAR(255) NULL ,
  "fontSperrung" REAL NULL DEFAULT 0,
  "skalierung" REAL NULL DEFAULT 1,
  "horizontaleAusrichtung" VARCHAR(64) NULL DEFAULT 'linksbündig',
  "vertikaleAusrichtung" VARCHAR(64) NULL DEFAULT 'Basis',
  "hat" INTEGER NULL,
  PRIMARY KEY ("gid") ,
  CONSTRAINT "fk_XP_TPO_XP_VertikaleAusrichtung1"
    FOREIGN KEY ("vertikaleAusrichtung" )
    REFERENCES "XP_Praesentationsobjekte"."XP_VertikaleAusrichtung" ("Wert" )
    ON DELETE SET NULL
    ON UPDATE NO ACTION,
  CONSTRAINT "fk_XP_TPO_XP_HorizontaleAusrichtung1"
    FOREIGN KEY ("horizontaleAusrichtung" )
    REFERENCES "XP_Praesentationsobjekte"."XP_HorizontaleAusrichtung" ("Wert" )
    ON DELETE SET NULL
    ON UPDATE NO ACTION,
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
CREATE TRIGGER "XP_TPO_hasInsert" BEFORE INSERT OR UPDATE OR DELETE ON "XP_Praesentationsobjekte"."XP_TPO" FOR EACH ROW EXECUTE PROCEDURE "XP_Praesentationsobjekte"."child_of_XP_APObjekt"();
GRANT SELECT ON TABLE "XP_Praesentationsobjekte"."XP_TPO" TO xp_gast; 
GRANT ALL ON TABLE "XP_Praesentationsobjekte"."XP_TPO" TO xp_user;

-- -----------------------------------------------------
-- Table "XP_Praesentationsobjekte"."XP_PTO"
-- -----------------------------------------------------
CREATE  TABLE  "XP_Praesentationsobjekte"."XP_PTO" (
  "gid" INTEGER NOT NULL ,
  "position" GEOMETRY NOT NULL ,
  "drehwinkel" INTEGER NULL DEFAULT 0,
  PRIMARY KEY ("gid") );
COMMENT ON TABLE "XP_Praesentationsobjekte"."XP_PTO" IS 'Textförmiges Präsentationsobjekt mit punktförmiger Festlegung der Textposition.';
COMMENT ON COLUMN "XP_Praesentationsobjekte"."XP_PTO"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN "XP_Praesentationsobjekte"."XP_PTO"."drehwinkel" IS 'Winkel um den der Text oder die Signatur mit punktförmiger Bezugsgeometrie aus der Horizontalen gedreht ist.
Angabe im Bogenmaß; Zählweise im mathematisch positiven Sinn (von Ost über Nord nach West und Süd).';
CREATE TRIGGER "XP_PTO_hasInsert" BEFORE INSERT OR UPDATE OR DELETE ON "XP_Praesentationsobjekte"."XP_PTO" FOR EACH ROW EXECUTE PROCEDURE "XP_Praesentationsobjekte"."child_of_XP_TPO"();
GRANT SELECT ON TABLE "XP_Praesentationsobjekte"."XP_PTO" TO xp_gast;
GRANT ALL ON TABLE "XP_Praesentationsobjekte"."XP_PTO" TO xp_user;

-- -----------------------------------------------------
-- Table "XP_Praesentationsobjekte"."XP_LTO"
-- -----------------------------------------------------
CREATE  TABLE  "XP_Praesentationsobjekte"."XP_LTO" (
  "gid" INTEGER NOT NULL ,
  "position" GEOMETRY NOT NULL ,
  PRIMARY KEY ("gid") );
COMMENT ON TABLE "XP_Praesentationsobjekte"."XP_LTO" IS 'Textförmiges Präsentationsobjekt mit linienförmiger Textgeometrie.';
COMMENT ON COLUMN "XP_Praesentationsobjekte"."XP_LTO"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "XP_LTO_hasInsert" BEFORE INSERT OR UPDATE OR DELETE ON "XP_Praesentationsobjekte"."XP_LTO" FOR EACH ROW EXECUTE PROCEDURE "XP_Praesentationsobjekte"."child_of_XP_TPO"();
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
-- Table "XP_Sonstiges"."XP_SPEMassnamenTypen"
-- -----------------------------------------------------
CREATE  TABLE  "XP_Sonstiges"."XP_SPEMassnamenTypen" (
  "Wert" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Wert") );
COMMENT ON TABLE  "XP_Sonstiges"."XP_SPEMassnamenTypen" IS 'Klassifikation der Maßnahme';
GRANT SELECT ON TABLE "XP_Sonstiges"."XP_SPEMassnamenTypen" TO xp_gast;

-- -----------------------------------------------------
-- Table "XP_Sonstiges"."XP_SPEZiele"
-- -----------------------------------------------------
CREATE  TABLE  "XP_Sonstiges"."XP_SPEZiele" (
  "Wert" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Wert") );

GRANT SELECT ON TABLE "XP_Sonstiges"."XP_SPEZiele" TO xp_gast;

-- -----------------------------------------------------
-- Table "XP_Sonstiges"."XP_ArtHoehenbezug"
-- -----------------------------------------------------
CREATE  TABLE  "XP_Sonstiges"."XP_ArtHoehenbezug" (
  "Wert" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Wert") );

GRANT SELECT ON TABLE "XP_Sonstiges"."XP_ArtHoehenbezug" TO xp_gast;

-- -----------------------------------------------------
-- Table "XP_Sonstiges"."XP_ArtHoehenbezugspunkt"
-- -----------------------------------------------------
CREATE  TABLE  "XP_Sonstiges"."XP_ArtHoehenbezugspunkt" (
  "Wert" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Wert") );

GRANT SELECT ON TABLE "XP_Sonstiges"."XP_ArtHoehenbezugspunkt" TO xp_gast;

-- -----------------------------------------------------
-- Table "XP_Sonstiges"."XP_Hoehenangabe"
-- -----------------------------------------------------
CREATE  TABLE  "XP_Sonstiges"."XP_Hoehenangabe" (
  "id" INTEGER NOT NULL DEFAULT nextval('"XP_Sonstiges"."XP_Hoehenangabe_id_seq"'),
  "hoehenbezug" INTEGER NULL ,
  "abweichenderHoehenbezug" VARCHAR(255) NULL ,
  "bezugspunkt" INTEGER NULL ,
  "hMin" REAL NULL ,
  "hMax" REAL NULL ,
  "hZwingend" REAL NULL ,
  "h" REAL NULL ,
  PRIMARY KEY ("id") ,
  CONSTRAINT "fk_XP_Hoehenangabe_XP_ArtHoehenbezug"
    FOREIGN KEY ("hoehenbezug" )
    REFERENCES "XP_Sonstiges"."XP_ArtHoehenbezug" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_XP_Hoehenangabe_XP_ArtHoehenbezugspunkt1"
    FOREIGN KEY ("bezugspunkt" )
    REFERENCES "XP_Sonstiges"."XP_ArtHoehenbezugspunkt" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
COMMENT ON TABLE  "XP_Sonstiges"."XP_Hoehenangabe" IS 'Spezifikation einer Angabe zur vertikalen Höhe.';
COMMENT ON COLUMN "XP_Sonstiges"."XP_Hoehenangabe"."id" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN "XP_Sonstiges"."XP_Hoehenangabe"."hoehenbezug" IS 'Art des Höhenbezuges.';
COMMENT ON COLUMN "XP_Sonstiges"."XP_Hoehenangabe"."bezugspunkt" IS 'Bestimmung des Bezugspunktes für relative Höhenangaben.';
COMMENT ON COLUMN "XP_Sonstiges"."XP_Hoehenangabe"."hMin" IS 'Minimale Höhe.';
COMMENT ON COLUMN "XP_Sonstiges"."XP_Hoehenangabe"."hMax" IS 'Maximale Höhe bei einer Bereichsangabe. Das Attribut hMin muss ebenfalls belegt sein.';
COMMENT ON COLUMN "XP_Sonstiges"."XP_Hoehenangabe"."hZwingend" IS 'Zwingend einzuhaltende Höhe.';
COMMENT ON COLUMN "XP_Sonstiges"."XP_Hoehenangabe"."h" IS 'Maximal zulässige Höhe.';
CREATE INDEX "idx_fk_XP_Hoehenangabe_XP_ArtHoehenbezug" ON "XP_Sonstiges"."XP_Hoehenangabe" ("hoehenbezug") ;
CREATE INDEX "idx_fk_XP_Hoehenangabe_XP_ArtHoehenbezugspunkt1" ON "XP_Sonstiges"."XP_Hoehenangabe" ("bezugspunkt") ;

GRANT SELECT ON TABLE "XP_Sonstiges"."XP_Hoehenangabe" TO xp_gast;
GRANT ALL ON TABLE "XP_Sonstiges"."XP_Hoehenangabe" TO xp_user;

-- -----------------------------------------------------
-- Table "XP_Sonstiges"."XP_SPEMassnahmenDaten"
-- -----------------------------------------------------
CREATE  TABLE  "XP_Sonstiges"."XP_SPEMassnahmenDaten" (
  "id" INTEGER NOT NULL DEFAULT nextval('"XP_Sonstiges"."XP_SPEMassnahmenDaten_id_seq"'),
  "klassifizMassnahme" INTEGER NULL ,
  "massnahmeText" VARCHAR(1024) NULL ,
  "massnahmeKuerzel" VARCHAR(255) NULL ,
  PRIMARY KEY ("id") ,
  CONSTRAINT "fk_XP_SPEMassnahmenDaten_XP_SPEMassnamenTypen1"
    FOREIGN KEY ("klassifizMassnahme" )
    REFERENCES "XP_Sonstiges"."XP_SPEMassnamenTypen" ("Wert" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
COMMENT ON TABLE  "XP_Sonstiges"."XP_SPEMassnahmenDaten" IS 'Spezifikation der Attribute für einer Schutz-, Pflege- oder Entwicklungsmaßnahme.';
COMMENT ON COLUMN "XP_Sonstiges"."XP_SPEMassnahmenDaten"."id" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN "XP_Sonstiges"."XP_SPEMassnahmenDaten"."klassifizMassnahme" IS 'Klassifikation der Maßnahme';
COMMENT ON COLUMN "XP_Sonstiges"."XP_SPEMassnahmenDaten"."massnahmeText" IS 'Durchzuführende Maßnahme als freier Text.';
COMMENT ON COLUMN "XP_Sonstiges"."XP_SPEMassnahmenDaten"."massnahmeKuerzel" IS 'Kürzel der durchzuführenden Maßnahme.';
CREATE INDEX "idx_fk_XP_SPEMassnahmenDaten_XP_SPEMassnamenTypen1" ON "XP_Sonstiges"."XP_SPEMassnahmenDaten" ("klassifizMassnahme") ;

GRANT SELECT ON TABLE "XP_Sonstiges"."XP_Hoehenangabe" TO xp_gast;
GRANT ALL ON TABLE "XP_Sonstiges"."XP_Hoehenangabe" TO xp_user;

-- -----------------------------------------------------
-- Table `XP_Basisobjekte`.`hoehenangabe`
-- -----------------------------------------------------
CREATE TABLE "XP_Basisobjekte"."hoehenangabe" (
  "XP_Objekt_gid" INTEGER NOT NULL ,
  "XP_Hoehenangabe_id" INTEGER NOT NULL ,
  PRIMARY KEY ("XP_Objekt_gid", "XP_Hoehenangabe_id") ,
  CONSTRAINT "fk_XP_Objekt_has_XP_Hoehenangabe_XP_Objekt1"
    FOREIGN KEY ("XP_Objekt_gid")
    REFERENCES "XP_Basisobjekte"."XP_Objekt" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_XP_Objekt_has_XP_Hoehenangabe_XP_Hoehenangabe1"
    FOREIGN KEY ("XP_Hoehenangabe_id")
    REFERENCES "XP_Sonstiges"."XP_Hoehenangabe" ("id")
    ON DELETE NO ACTION
    ON UPDATE CASCADE);
COMMENT ON TABLE "XP_Basisobjekte"."hoehenangabe" IS 'Angaben zur vertikalen Lage eines Planinhalts.';
CREATE INDEX "fk_hoehenangabe_XP_Objekt1" ON "XP_Basisobjekte"."hoehenangabe" ("XP_Objekt_gid");
CREATE INDEX "fk_hoehenangabe_XP_Hoehenangabe1" ON "XP_Basisobjekte"."hoehenangabe" ("XP_Hoehenangabe_id");

GRANT SELECT ON TABLE "XP_Basisobjekte"."hoehenangabe" TO xp_gast;
GRANT ALL ON TABLE "XP_Basisobjekte"."hoehenangabe" TO xp_user;

-- *****************************************************
-- CREATE VIEWs
-- *****************************************************

-- -----------------------------------------------------
-- View "XP_Basisobjekte"."XP_Plaene"
-- -----------------------------------------------------
CREATE  OR REPLACE VIEW "XP_Basisobjekte"."XP_Plaene" AS
SELECT g.*, p.name, CAST(c.relname as varchar) as "Objektart" 
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
SELECT g.gid, COALESCE(g.geltungsbereich, p."raeumlicherGeltungsbereich") as geltungsbereich, p.name, CAST(c.relname as varchar) as "Objektart", p.gid as "planGid", p.name as "planName", p."Objektart" as "planArt"
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
-- View "XP_Raster"."XP_RasterplanAenderungen"
-- -----------------------------------------------------
CREATE  OR REPLACE VIEW "XP_Raster"."XP_RasterplanAenderungen" AS
SELECT g.*, p."nameAenderung", c.relname as "Objektart" 
FROM  "XP_Raster"."XP_GeltungsbereichAenderung" g
JOIN pg_class c ON g.tableoid = c.oid
JOIN "XP_Raster"."XP_RasterplanAenderung" p ON g.gid = p.gid;
GRANT SELECT ON TABLE "XP_Raster"."XP_RasterplanAenderungen" TO xp_gast;
GRANT ALL ON TABLE "XP_Raster"."XP_RasterplanAenderungen" TO xp_user;

CREATE OR REPLACE RULE _update AS
    ON UPDATE TO "XP_Raster"."XP_RasterplanAenderungen" DO INSTEAD  UPDATE "XP_Raster"."XP_GeltungsbereichAenderung" SET "geltungsbereichAenderung" = new."geltungsbereichAenderung"
  WHERE gid = old.gid;
CREATE OR REPLACE RULE _delete AS
    ON DELETE TO "XP_Raster"."XP_RasterplanAenderungen" DO INSTEAD  DELETE FROM "XP_Raster"."XP_GeltungsbereichAenderung"
  WHERE gid = old.gid;

-- *****************************************************
-- DATA
-- *****************************************************

-- -----------------------------------------------------
-- PostGIS für Views
-- -----------------------------------------------------

SELECT "XP_Basisobjekte".registergeometrycolumn('','XP_Basisobjekte','XP_Plaene', 'raeumlicherGeltungsbereich','MULTIPOLYGON',2);
SELECT "XP_Basisobjekte".registergeometrycolumn('','XP_Basisobjekte','XP_Bereiche', 'geltungsbereich','MULTIPOLYGON',2);
SELECT "XP_Basisobjekte".registergeometrycolumn('','XP_Raster','XP_RasterplanAenderungen', 'geltungsbereichAenderung','MULTIPOLYGON',2);

-- -----------------------------------------------------
-- PostGIS für XP_Praesentationsobjekte
-- -----------------------------------------------------

SELECT "XP_Basisobjekte".registergeometrycolumn('','XP_Praesentationsobjekte','XP_PPO', 'position','MULTIPOINT',2);
SELECT "XP_Basisobjekte".registergeometrycolumn('','XP_Praesentationsobjekte','XP_FPO', 'position','MULTIPOLYGON',2);
SELECT "XP_Basisobjekte".registergeometrycolumn('','XP_Praesentationsobjekte','XP_LPO', 'position','MULTILINESTRING',2);
SELECT "XP_Basisobjekte".registergeometrycolumn('','XP_Praesentationsobjekte','XP_LTO', 'position','MULTILINESTRING',2);
SELECT "XP_Basisobjekte".registergeometrycolumn('','XP_Praesentationsobjekte','XP_PTO', 'position','POINT',2);

-- -----------------------------------------------------
-- Data for table "XP_Enumerationen"."XP_AllgArtDerBaulNutzung"
-- -----------------------------------------------------
INSERT INTO "XP_Enumerationen"."XP_AllgArtDerBaulNutzung" ("Wert", "Bezeichner") VALUES ('1000', 'WohnBauflaeche');
INSERT INTO "XP_Enumerationen"."XP_AllgArtDerBaulNutzung" ("Wert", "Bezeichner") VALUES ('2000', 'GemischteBauflaeche');
INSERT INTO "XP_Enumerationen"."XP_AllgArtDerBaulNutzung" ("Wert", "Bezeichner") VALUES ('3000', 'GewerblicheBauflaeche');
INSERT INTO "XP_Enumerationen"."XP_AllgArtDerBaulNutzung" ("Wert", "Bezeichner") VALUES ('4000', 'SonderBauflaeche');
INSERT INTO "XP_Enumerationen"."XP_AllgArtDerBaulNutzung" ("Wert", "Bezeichner") VALUES ('9999', 'SonstigeBauflaeche');

-- -----------------------------------------------------
-- Data for table "XP_Enumerationen"."XP_BesondereArtDerBaulNutzung"
-- -----------------------------------------------------
INSERT INTO "XP_Enumerationen"."XP_BesondereArtDerBaulNutzung" ("Wert", "Bezeichner") VALUES ('1000', 'Kleinsiedlungsgebiet');
INSERT INTO "XP_Enumerationen"."XP_BesondereArtDerBaulNutzung" ("Wert", "Bezeichner") VALUES ('1100', 'ReinesWohngebiet');
INSERT INTO "XP_Enumerationen"."XP_BesondereArtDerBaulNutzung" ("Wert", "Bezeichner") VALUES ('1200', 'AllgWohngebiet');
INSERT INTO "XP_Enumerationen"."XP_BesondereArtDerBaulNutzung" ("Wert", "Bezeichner") VALUES ('1300', 'BesonderesWohngebiet');
INSERT INTO "XP_Enumerationen"."XP_BesondereArtDerBaulNutzung" ("Wert", "Bezeichner") VALUES ('1400', 'Dorfgebiet');
INSERT INTO "XP_Enumerationen"."XP_BesondereArtDerBaulNutzung" ("Wert", "Bezeichner") VALUES ('1500', 'Mischgebiet');
INSERT INTO "XP_Enumerationen"."XP_BesondereArtDerBaulNutzung" ("Wert", "Bezeichner") VALUES ('1600', 'Kerngebiet');
INSERT INTO "XP_Enumerationen"."XP_BesondereArtDerBaulNutzung" ("Wert", "Bezeichner") VALUES ('1700', 'Gewerbegebiet');
INSERT INTO "XP_Enumerationen"."XP_BesondereArtDerBaulNutzung" ("Wert", "Bezeichner") VALUES ('1800', 'Industriegebiet');
INSERT INTO "XP_Enumerationen"."XP_BesondereArtDerBaulNutzung" ("Wert", "Bezeichner") VALUES ('2000', 'SondergebietErholung');
INSERT INTO "XP_Enumerationen"."XP_BesondereArtDerBaulNutzung" ("Wert", "Bezeichner") VALUES ('2100', 'SondergebietSonst');
INSERT INTO "XP_Enumerationen"."XP_BesondereArtDerBaulNutzung" ("Wert", "Bezeichner") VALUES ('3000', 'Wochenendhausgebiet');
INSERT INTO "XP_Enumerationen"."XP_BesondereArtDerBaulNutzung" ("Wert", "Bezeichner") VALUES ('4000', 'Sondergebiet');
INSERT INTO "XP_Enumerationen"."XP_BesondereArtDerBaulNutzung" ("Wert", "Bezeichner") VALUES ('9999', 'SonstigesGebiet');

-- -----------------------------------------------------
-- Data for table "XP_Enumerationen"."XP_Sondernutzungen"
-- -----------------------------------------------------
INSERT INTO "XP_Enumerationen"."XP_Sondernutzungen" ("Wert", "Bezeichner") VALUES ('1000', 'Wochenendhausgebiet');
INSERT INTO "XP_Enumerationen"."XP_Sondernutzungen" ("Wert", "Bezeichner") VALUES ('1100', 'Ferienhausgebiet');
INSERT INTO "XP_Enumerationen"."XP_Sondernutzungen" ("Wert", "Bezeichner") VALUES ('1200', 'Campingplatzgebiet');
INSERT INTO "XP_Enumerationen"."XP_Sondernutzungen" ("Wert", "Bezeichner") VALUES ('1300', 'Kurgebiet');
INSERT INTO "XP_Enumerationen"."XP_Sondernutzungen" ("Wert", "Bezeichner") VALUES ('1400', 'SonstSondergebietErholung');
INSERT INTO "XP_Enumerationen"."XP_Sondernutzungen" ("Wert", "Bezeichner") VALUES ('1500', 'Einzelhandelsgebiet');
INSERT INTO "XP_Enumerationen"."XP_Sondernutzungen" ("Wert", "Bezeichner") VALUES ('1600', 'GrossflaechigerEinzelhandel');
INSERT INTO "XP_Enumerationen"."XP_Sondernutzungen" ("Wert", "Bezeichner") VALUES ('16000', 'Ladengebiet');
INSERT INTO "XP_Enumerationen"."XP_Sondernutzungen" ("Wert", "Bezeichner") VALUES ('16001', 'Einkaufszentrum');
INSERT INTO "XP_Enumerationen"."XP_Sondernutzungen" ("Wert", "Bezeichner") VALUES ('16002', 'SonstGrossflEinzelhandel');
INSERT INTO "XP_Enumerationen"."XP_Sondernutzungen" ("Wert", "Bezeichner") VALUES ('1700', 'Verkehrsuebungsplatz');
INSERT INTO "XP_Enumerationen"."XP_Sondernutzungen" ("Wert", "Bezeichner") VALUES ('1800', 'Hafengebiet');
INSERT INTO "XP_Enumerationen"."XP_Sondernutzungen" ("Wert", "Bezeichner") VALUES ('1900', 'SondergebietErneuerbareEnergie');
INSERT INTO "XP_Enumerationen"."XP_Sondernutzungen" ("Wert", "Bezeichner") VALUES ('2000', 'SondergebietMilitaer');
INSERT INTO "XP_Enumerationen"."XP_Sondernutzungen" ("Wert", "Bezeichner") VALUES ('2100', 'SondergebietLandwirtschaft');
INSERT INTO "XP_Enumerationen"."XP_Sondernutzungen" ("Wert", "Bezeichner") VALUES ('2200', 'SondergebietSport');
INSERT INTO "XP_Enumerationen"."XP_Sondernutzungen" ("Wert", "Bezeichner") VALUES ('2300', 'SondergebietGesundheitSoziales');
INSERT INTO "XP_Enumerationen"."XP_Sondernutzungen" ("Wert", "Bezeichner") VALUES ('2400', 'Golfplatz');
INSERT INTO "XP_Enumerationen"."XP_Sondernutzungen" ("Wert", "Bezeichner") VALUES ('2500', 'SondergebietKultur');
INSERT INTO "XP_Enumerationen"."XP_Sondernutzungen" ("Wert", "Bezeichner") VALUES ('2600', 'SondergebietTourismus');
INSERT INTO "XP_Enumerationen"."XP_Sondernutzungen" ("Wert", "Bezeichner") VALUES ('2700', 'SondergebietBueroUndVerwaltung');
INSERT INTO "XP_Enumerationen"."XP_Sondernutzungen" ("Wert", "Bezeichner") VALUES ('2800', 'SondergebietHochschuleEinrichtungen');
INSERT INTO "XP_Enumerationen"."XP_Sondernutzungen" ("Wert", "Bezeichner") VALUES ('2900', 'SondergebietMesse');
INSERT INTO "XP_Enumerationen"."XP_Sondernutzungen" ("Wert", "Bezeichner") VALUES ('9999', 'SondergebietAndereNutzungen');

-- -----------------------------------------------------
-- Data for table "XP_Enumerationen"."XP_AbweichungBauNVOTypen"
-- -----------------------------------------------------
INSERT INTO "XP_Enumerationen"."XP_AbweichungBauNVOTypen" ("Wert", "Bezeichner") VALUES ('1000', 'EinschraenkungNutzung');
INSERT INTO "XP_Enumerationen"."XP_AbweichungBauNVOTypen" ("Wert", "Bezeichner") VALUES ('2000', 'AusschlussNutzung');
INSERT INTO "XP_Enumerationen"."XP_AbweichungBauNVOTypen" ("Wert", "Bezeichner") VALUES ('3000', 'AusweitungNutzung');
INSERT INTO "XP_Enumerationen"."XP_AbweichungBauNVOTypen" ("Wert", "Bezeichner") VALUES ('9999', 'SonstAbweichung');

-- -----------------------------------------------------
-- Data for table "XP_Enumerationen"."XP_ZweckbestimmungGemeinbedarf"
-- -----------------------------------------------------
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungGemeinbedarf" ("Wert", "Bezeichner") VALUES ('1000', 'OffentlicheVerwaltung');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungGemeinbedarf" ("Wert", "Bezeichner") VALUES ('1200', 'BildungForschung');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungGemeinbedarf" ("Wert", "Bezeichner") VALUES ('1400', 'Kirche');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungGemeinbedarf" ("Wert", "Bezeichner") VALUES ('1600', 'Sozial');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungGemeinbedarf" ("Wert", "Bezeichner") VALUES ('1800', 'Gesundheit');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungGemeinbedarf" ("Wert", "Bezeichner") VALUES ('2000', 'Kultur');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungGemeinbedarf" ("Wert", "Bezeichner") VALUES ('2200', 'Sport');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungGemeinbedarf" ("Wert", "Bezeichner") VALUES ('2400', 'SicherheitOrdnung');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungGemeinbedarf" ("Wert", "Bezeichner") VALUES ('2600', 'Infrastruktur');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungGemeinbedarf" ("Wert", "Bezeichner") VALUES ('9999', 'Sonstiges');

-- -----------------------------------------------------
-- Data for table "XP_Enumerationen"."XP_BesondereZweckbestGemeinbedarf"
-- -----------------------------------------------------
INSERT INTO "XP_Enumerationen"."XP_BesondereZweckbestGemeinbedarf" ("Wert", "Bezeichner") VALUES ('10000', 'KommunaleEinrichtung');
INSERT INTO "XP_Enumerationen"."XP_BesondereZweckbestGemeinbedarf" ("Wert", "Bezeichner") VALUES ('10001', 'BetriebOeffentlZweckbestimmung');
INSERT INTO "XP_Enumerationen"."XP_BesondereZweckbestGemeinbedarf" ("Wert", "Bezeichner") VALUES ('10002', 'AnlageBundLand');
INSERT INTO "XP_Enumerationen"."XP_BesondereZweckbestGemeinbedarf" ("Wert", "Bezeichner") VALUES ('10003', 'SonstigeOeffentlicheVerwaltung');
INSERT INTO "XP_Enumerationen"."XP_BesondereZweckbestGemeinbedarf" ("Wert", "Bezeichner") VALUES ('12000', 'Schule');
INSERT INTO "XP_Enumerationen"."XP_BesondereZweckbestGemeinbedarf" ("Wert", "Bezeichner") VALUES ('12001', 'Hochschule');
INSERT INTO "XP_Enumerationen"."XP_BesondereZweckbestGemeinbedarf" ("Wert", "Bezeichner") VALUES ('12002', 'BerufsbildendeSchule');
INSERT INTO "XP_Enumerationen"."XP_BesondereZweckbestGemeinbedarf" ("Wert", "Bezeichner") VALUES ('12003', 'Forschungseinrichtung');
INSERT INTO "XP_Enumerationen"."XP_BesondereZweckbestGemeinbedarf" ("Wert", "Bezeichner") VALUES ('12004', 'SonstigesBildungForschung');
INSERT INTO "XP_Enumerationen"."XP_BesondereZweckbestGemeinbedarf" ("Wert", "Bezeichner") VALUES ('14000', 'Sakralgebaeude');
INSERT INTO "XP_Enumerationen"."XP_BesondereZweckbestGemeinbedarf" ("Wert", "Bezeichner") VALUES ('14001', 'KirchlicheVerwaltung');
INSERT INTO "XP_Enumerationen"."XP_BesondereZweckbestGemeinbedarf" ("Wert", "Bezeichner") VALUES ('14002', 'Kirchengemeinde');
INSERT INTO "XP_Enumerationen"."XP_BesondereZweckbestGemeinbedarf" ("Wert", "Bezeichner") VALUES ('14003', 'SonstigesKirche');
INSERT INTO "XP_Enumerationen"."XP_BesondereZweckbestGemeinbedarf" ("Wert", "Bezeichner") VALUES ('16000', 'EinrichtungKinder');
INSERT INTO "XP_Enumerationen"."XP_BesondereZweckbestGemeinbedarf" ("Wert", "Bezeichner") VALUES ('16001', 'EinrichtungJugendliche');
INSERT INTO "XP_Enumerationen"."XP_BesondereZweckbestGemeinbedarf" ("Wert", "Bezeichner") VALUES ('16002', 'EinrichtungFamilienErwachsene');
INSERT INTO "XP_Enumerationen"."XP_BesondereZweckbestGemeinbedarf" ("Wert", "Bezeichner") VALUES ('16003', 'EinrichtungSenioren');
INSERT INTO "XP_Enumerationen"."XP_BesondereZweckbestGemeinbedarf" ("Wert", "Bezeichner") VALUES ('16004', 'SonstigeSozialeEinrichtung');
INSERT INTO "XP_Enumerationen"."XP_BesondereZweckbestGemeinbedarf" ("Wert", "Bezeichner") VALUES ('18000', 'Krankenhaus');
INSERT INTO "XP_Enumerationen"."XP_BesondereZweckbestGemeinbedarf" ("Wert", "Bezeichner") VALUES ('18001', 'SonstigesGesundheit');
INSERT INTO "XP_Enumerationen"."XP_BesondereZweckbestGemeinbedarf" ("Wert", "Bezeichner") VALUES ('20000', 'MusikTheater');
INSERT INTO "XP_Enumerationen"."XP_BesondereZweckbestGemeinbedarf" ("Wert", "Bezeichner") VALUES ('20001', 'Bildung');
INSERT INTO "XP_Enumerationen"."XP_BesondereZweckbestGemeinbedarf" ("Wert", "Bezeichner") VALUES ('20002', 'SonstigeKultur');
INSERT INTO "XP_Enumerationen"."XP_BesondereZweckbestGemeinbedarf" ("Wert", "Bezeichner") VALUES ('22000', 'Bad');
INSERT INTO "XP_Enumerationen"."XP_BesondereZweckbestGemeinbedarf" ("Wert", "Bezeichner") VALUES ('22001', 'SportplatzSporthalle');
INSERT INTO "XP_Enumerationen"."XP_BesondereZweckbestGemeinbedarf" ("Wert", "Bezeichner") VALUES ('22002', 'SonstigerSport');
INSERT INTO "XP_Enumerationen"."XP_BesondereZweckbestGemeinbedarf" ("Wert", "Bezeichner") VALUES ('24000', 'Feuerwehr');
INSERT INTO "XP_Enumerationen"."XP_BesondereZweckbestGemeinbedarf" ("Wert", "Bezeichner") VALUES ('24001', 'Schutzbauwerk');
INSERT INTO "XP_Enumerationen"."XP_BesondereZweckbestGemeinbedarf" ("Wert", "Bezeichner") VALUES ('24002', 'Justiz');
INSERT INTO "XP_Enumerationen"."XP_BesondereZweckbestGemeinbedarf" ("Wert", "Bezeichner") VALUES ('24003', 'SonstigeSicherheitOrdnung');
INSERT INTO "XP_Enumerationen"."XP_BesondereZweckbestGemeinbedarf" ("Wert", "Bezeichner") VALUES ('26000', 'Post');
INSERT INTO "XP_Enumerationen"."XP_BesondereZweckbestGemeinbedarf" ("Wert", "Bezeichner") VALUES ('26001', 'SonstigeInfrastruktur');

-- -----------------------------------------------------
-- Data for table "XP_Enumerationen"."XP_ZweckbestimmungSpielSportanlage"
-- -----------------------------------------------------
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungSpielSportanlage" ("Wert", "Bezeichner") VALUES ('1000', 'Sportanlage');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungSpielSportanlage" ("Wert", "Bezeichner") VALUES ('2000', 'Spielanlage');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungSpielSportanlage" ("Wert", "Bezeichner") VALUES ('3000', 'SpielSportanlage');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungSpielSportanlage" ("Wert", "Bezeichner") VALUES ('9999', 'Sonstiges');

-- -----------------------------------------------------
-- Data for table "XP_Enumerationen"."XP_ZweckbestimmungGruen"
-- -----------------------------------------------------
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungGruen" ("Wert", "Bezeichner") VALUES ('1000', 'Parkanlage');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungGruen" ("Wert", "Bezeichner") VALUES ('1200', 'Dauerkleingaerten');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungGruen" ("Wert", "Bezeichner") VALUES ('1400', 'Sportplatz');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungGruen" ("Wert", "Bezeichner") VALUES ('1600', 'Spielplatz');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungGruen" ("Wert", "Bezeichner") VALUES ('1800', 'Zeltplatz');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungGruen" ("Wert", "Bezeichner") VALUES ('2000', 'Badeplatz');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungGruen" ("Wert", "Bezeichner") VALUES ('2200', 'FreizeitErholung');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungGruen" ("Wert", "Bezeichner") VALUES ('2400', 'SpezGruenflaeche');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungGruen" ("Wert", "Bezeichner") VALUES ('2600', 'Friedhof');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungGruen" ("Wert", "Bezeichner") VALUES ('9999', 'Sonstiges');

-- -----------------------------------------------------
-- Data for table "XP_Enumerationen"."XP_BesondereZweckbestimmungGruen"
-- -----------------------------------------------------
INSERT INTO "XP_Enumerationen"."XP_BesondereZweckbestimmungGruen" ("Wert", "Bezeichner") VALUES ('10000', 'ParkanlageHistorisch');
INSERT INTO "XP_Enumerationen"."XP_BesondereZweckbestimmungGruen" ("Wert", "Bezeichner") VALUES ('10001', 'ParkanlageNaturnah');
INSERT INTO "XP_Enumerationen"."XP_BesondereZweckbestimmungGruen" ("Wert", "Bezeichner") VALUES ('10002', 'ParkanlageWaldcharakter');
INSERT INTO "XP_Enumerationen"."XP_BesondereZweckbestimmungGruen" ("Wert", "Bezeichner") VALUES ('10003', 'NaturnaheUferParkanlage');
INSERT INTO "XP_Enumerationen"."XP_BesondereZweckbestimmungGruen" ("Wert", "Bezeichner") VALUES ('12000', 'ErholungsGaerten');
INSERT INTO "XP_Enumerationen"."XP_BesondereZweckbestimmungGruen" ("Wert", "Bezeichner") VALUES ('14000', 'Reitsportanlage');
INSERT INTO "XP_Enumerationen"."XP_BesondereZweckbestimmungGruen" ("Wert", "Bezeichner") VALUES ('14001', 'Hundesportanlage');
INSERT INTO "XP_Enumerationen"."XP_BesondereZweckbestimmungGruen" ("Wert", "Bezeichner") VALUES ('14002', 'Wassersportanlage');
INSERT INTO "XP_Enumerationen"."XP_BesondereZweckbestimmungGruen" ("Wert", "Bezeichner") VALUES ('14003', 'Schiessstand');
INSERT INTO "XP_Enumerationen"."XP_BesondereZweckbestimmungGruen" ("Wert", "Bezeichner") VALUES ('14004', 'Golfplatz');
INSERT INTO "XP_Enumerationen"."XP_BesondereZweckbestimmungGruen" ("Wert", "Bezeichner") VALUES ('14005', 'Skisport');
INSERT INTO "XP_Enumerationen"."XP_BesondereZweckbestimmungGruen" ("Wert", "Bezeichner") VALUES ('14006', 'Tennisanlage');
INSERT INTO "XP_Enumerationen"."XP_BesondereZweckbestimmungGruen" ("Wert", "Bezeichner") VALUES ('14007', 'SonstigerSportplatz');
INSERT INTO "XP_Enumerationen"."XP_BesondereZweckbestimmungGruen" ("Wert", "Bezeichner") VALUES ('16000', 'Bolzplatz');
INSERT INTO "XP_Enumerationen"."XP_BesondereZweckbestimmungGruen" ("Wert", "Bezeichner") VALUES ('16001', 'Abenteuerspielplatz');
INSERT INTO "XP_Enumerationen"."XP_BesondereZweckbestimmungGruen" ("Wert", "Bezeichner") VALUES ('18000', 'Campingplatz');
INSERT INTO "XP_Enumerationen"."XP_BesondereZweckbestimmungGruen" ("Wert", "Bezeichner") VALUES ('22000', 'Kleintierhaltung');
INSERT INTO "XP_Enumerationen"."XP_BesondereZweckbestimmungGruen" ("Wert", "Bezeichner") VALUES ('22001', 'Festplatz');
INSERT INTO "XP_Enumerationen"."XP_BesondereZweckbestimmungGruen" ("Wert", "Bezeichner") VALUES ('24000', 'StrassenbegleitGruen');
INSERT INTO "XP_Enumerationen"."XP_BesondereZweckbestimmungGruen" ("Wert", "Bezeichner") VALUES ('24001', 'BoeschungsFlaeche');
INSERT INTO "XP_Enumerationen"."XP_BesondereZweckbestimmungGruen" ("Wert", "Bezeichner") VALUES ('24002', 'FeldWaldWiese');
INSERT INTO "XP_Enumerationen"."XP_BesondereZweckbestimmungGruen" ("Wert", "Bezeichner") VALUES ('24003', 'Uferschutzstreifen');
INSERT INTO "XP_Enumerationen"."XP_BesondereZweckbestimmungGruen" ("Wert", "Bezeichner") VALUES ('24004', 'Abschirmgruen');
INSERT INTO "XP_Enumerationen"."XP_BesondereZweckbestimmungGruen" ("Wert", "Bezeichner") VALUES ('24005', 'UmweltbildungsparkSchaugatter');
INSERT INTO "XP_Enumerationen"."XP_BesondereZweckbestimmungGruen" ("Wert", "Bezeichner") VALUES ('24006', 'RuhenderVerkehr');
INSERT INTO "XP_Enumerationen"."XP_BesondereZweckbestimmungGruen" ("Wert", "Bezeichner") VALUES ('99990', 'Gaertnerei');

-- -----------------------------------------------------
-- Data for table "XP_Enumerationen"."XP_ZweckbestimmungWald"
-- -----------------------------------------------------
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungWald" ("Wert", "Bezeichner") VALUES ('1000', 'Naturwald');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungWald" ("Wert", "Bezeichner") VALUES ('1200', 'Nutzwald');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungWald" ("Wert", "Bezeichner") VALUES ('1400', 'Erholungswald');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungWald" ("Wert", "Bezeichner") VALUES ('1600', 'Schutzwald');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungWald" ("Wert", "Bezeichner") VALUES ('1800', 'FlaecheForstwirtschaft');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungWald" ("Wert", "Bezeichner") VALUES ('9999', 'Sonstiges');

-- -----------------------------------------------------
-- Data for table "XP_Enumerationen"."XP_ZweckbestimmungLandwirtschaft"
-- -----------------------------------------------------
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungLandwirtschaft" ("Wert", "Bezeichner") VALUES ('1000', 'LandwirtschaftAllgemein');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungLandwirtschaft" ("Wert", "Bezeichner") VALUES ('1100', 'Ackerbau');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungLandwirtschaft" ("Wert", "Bezeichner") VALUES ('1200', 'WiesenWeidewirtschaft');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungLandwirtschaft" ("Wert", "Bezeichner") VALUES ('1300', 'GartenbaulicheErzeugung');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungLandwirtschaft" ("Wert", "Bezeichner") VALUES ('1400', 'Obstbau');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungLandwirtschaft" ("Wert", "Bezeichner") VALUES ('1500', 'Weinbau');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungLandwirtschaft" ("Wert", "Bezeichner") VALUES ('1600', 'Imkerei');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungLandwirtschaft" ("Wert", "Bezeichner") VALUES ('1700', 'Binnenfischerei');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungLandwirtschaft" ("Wert", "Bezeichner") VALUES ('9999', 'Sonstiges');

-- -----------------------------------------------------
-- Data for table "XP_Enumerationen"."XP_Nutzungsform"
-- -----------------------------------------------------
INSERT INTO "XP_Enumerationen"."XP_Nutzungsform" ("Wert", "Bezeichner") VALUES ('1000', 'Privat');
INSERT INTO "XP_Enumerationen"."XP_Nutzungsform" ("Wert", "Bezeichner") VALUES ('2000', 'Oeffentlich');

-- -----------------------------------------------------
-- Data for table "XP_Enumerationen"."XP_ZweckbestimmungKennzeichnung"
-- -----------------------------------------------------
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungKennzeichnung" ("Wert", "Bezeichner") VALUES ('1000', 'Naturgewalten');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungKennzeichnung" ("Wert", "Bezeichner") VALUES ('2000', 'Abbauflaeche');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungKennzeichnung" ("Wert", "Bezeichner") VALUES ('3000', 'AeussereEinwirkungen');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungKennzeichnung" ("Wert", "Bezeichner") VALUES ('4000', 'SchadstoffBelastBoden');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungKennzeichnung" ("Wert", "Bezeichner") VALUES ('5000', 'LaermBelastung');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungKennzeichnung" ("Wert", "Bezeichner") VALUES ('6000', 'Bergbau');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungKennzeichnung" ("Wert", "Bezeichner") VALUES ('7000', 'Bodenordnung');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungKennzeichnung" ("Wert", "Bezeichner") VALUES ('9999', 'AndereGesetzlVorschriften');

-- -----------------------------------------------------
-- Data for table "XP_Enumerationen"."XP_ZweckbestimmungVerEntsorgung"
-- -----------------------------------------------------
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungVerEntsorgung" ("Wert", "Bezeichner") VALUES ('1000', 'Elektrizitaet');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungVerEntsorgung" ("Wert", "Bezeichner") VALUES ('1200', 'Gas');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungVerEntsorgung" ("Wert", "Bezeichner") VALUES ('1300', 'Erdoel');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungVerEntsorgung" ("Wert", "Bezeichner") VALUES ('1400', 'Waermeversorgung');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungVerEntsorgung" ("Wert", "Bezeichner") VALUES ('1600', 'Trinkwasser');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungVerEntsorgung" ("Wert", "Bezeichner") VALUES ('1800', 'Abwasser');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungVerEntsorgung" ("Wert", "Bezeichner") VALUES ('2000', 'Regenwasser');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungVerEntsorgung" ("Wert", "Bezeichner") VALUES ('2200', 'Abfallentsorgung');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungVerEntsorgung" ("Wert", "Bezeichner") VALUES ('2400', 'Ablagerung');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungVerEntsorgung" ("Wert", "Bezeichner") VALUES ('2600', 'Telekommunikation');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungVerEntsorgung" ("Wert", "Bezeichner") VALUES ('9999', 'Sonstiges');

-- -----------------------------------------------------
-- Data for table "XP_Enumerationen"."XP_BesondereZweckbestimmungVerEntsorgung"
-- -----------------------------------------------------
INSERT INTO "XP_Enumerationen"."XP_BesondereZweckbestimmungVerEntsorgung" ("Wert", "Bezeichner") VALUES ('10000', 'Hochspannungsleitung');
INSERT INTO "XP_Enumerationen"."XP_BesondereZweckbestimmungVerEntsorgung" ("Wert", "Bezeichner") VALUES ('10001', 'TrafostationUmspannwerk');
INSERT INTO "XP_Enumerationen"."XP_BesondereZweckbestimmungVerEntsorgung" ("Wert", "Bezeichner") VALUES ('10002', 'Solarkraftwerk');
INSERT INTO "XP_Enumerationen"."XP_BesondereZweckbestimmungVerEntsorgung" ("Wert", "Bezeichner") VALUES ('10003', 'Windkraftwerk');
INSERT INTO "XP_Enumerationen"."XP_BesondereZweckbestimmungVerEntsorgung" ("Wert", "Bezeichner") VALUES ('10004', 'Geothermiekraftwerk');
INSERT INTO "XP_Enumerationen"."XP_BesondereZweckbestimmungVerEntsorgung" ("Wert", "Bezeichner") VALUES ('10005', 'Elektrizitaetswerk');
INSERT INTO "XP_Enumerationen"."XP_BesondereZweckbestimmungVerEntsorgung" ("Wert", "Bezeichner") VALUES ('10006', 'Wasserkraftwerk');
INSERT INTO "XP_Enumerationen"."XP_BesondereZweckbestimmungVerEntsorgung" ("Wert", "Bezeichner") VALUES ('10007', 'BiomasseKraftwerk');
INSERT INTO "XP_Enumerationen"."XP_BesondereZweckbestimmungVerEntsorgung" ("Wert", "Bezeichner") VALUES ('10008', 'Kabelleitung');
INSERT INTO "XP_Enumerationen"."XP_BesondereZweckbestimmungVerEntsorgung" ("Wert", "Bezeichner") VALUES ('10009', 'Niederspannungsleitung');
INSERT INTO "XP_Enumerationen"."XP_BesondereZweckbestimmungVerEntsorgung" ("Wert", "Bezeichner") VALUES ('10010', 'Leitungsmast');
INSERT INTO "XP_Enumerationen"."XP_BesondereZweckbestimmungVerEntsorgung" ("Wert", "Bezeichner") VALUES ('12000', 'Ferngasleitung');
INSERT INTO "XP_Enumerationen"."XP_BesondereZweckbestimmungVerEntsorgung" ("Wert", "Bezeichner") VALUES ('12001', 'Gaswerk');
INSERT INTO "XP_Enumerationen"."XP_BesondereZweckbestimmungVerEntsorgung" ("Wert", "Bezeichner") VALUES ('12002', 'Gasbehaelter');
INSERT INTO "XP_Enumerationen"."XP_BesondereZweckbestimmungVerEntsorgung" ("Wert", "Bezeichner") VALUES ('12003', 'Gasdruckregler');
INSERT INTO "XP_Enumerationen"."XP_BesondereZweckbestimmungVerEntsorgung" ("Wert", "Bezeichner") VALUES ('12004', 'Gasstation');
INSERT INTO "XP_Enumerationen"."XP_BesondereZweckbestimmungVerEntsorgung" ("Wert", "Bezeichner") VALUES ('12005', 'Gasleitung');
INSERT INTO "XP_Enumerationen"."XP_BesondereZweckbestimmungVerEntsorgung" ("Wert", "Bezeichner") VALUES ('13000', 'Erdoelleitung');
INSERT INTO "XP_Enumerationen"."XP_BesondereZweckbestimmungVerEntsorgung" ("Wert", "Bezeichner") VALUES ('13001', 'Bohrstelle');
INSERT INTO "XP_Enumerationen"."XP_BesondereZweckbestimmungVerEntsorgung" ("Wert", "Bezeichner") VALUES ('13002', 'Erdoelpumpstation');
INSERT INTO "XP_Enumerationen"."XP_BesondereZweckbestimmungVerEntsorgung" ("Wert", "Bezeichner") VALUES ('13003', 'Oeltank');
INSERT INTO "XP_Enumerationen"."XP_BesondereZweckbestimmungVerEntsorgung" ("Wert", "Bezeichner") VALUES ('14000', 'Blockheizkraftwerk');
INSERT INTO "XP_Enumerationen"."XP_BesondereZweckbestimmungVerEntsorgung" ("Wert", "Bezeichner") VALUES ('14001', 'Fernwaermeleitung');
INSERT INTO "XP_Enumerationen"."XP_BesondereZweckbestimmungVerEntsorgung" ("Wert", "Bezeichner") VALUES ('14002', 'Fernheizwerk');
INSERT INTO "XP_Enumerationen"."XP_BesondereZweckbestimmungVerEntsorgung" ("Wert", "Bezeichner") VALUES ('16000', 'Wasserwerk');
INSERT INTO "XP_Enumerationen"."XP_BesondereZweckbestimmungVerEntsorgung" ("Wert", "Bezeichner") VALUES ('16001', 'Wasserleitung');
INSERT INTO "XP_Enumerationen"."XP_BesondereZweckbestimmungVerEntsorgung" ("Wert", "Bezeichner") VALUES ('16002', 'Wasserspeicher');
INSERT INTO "XP_Enumerationen"."XP_BesondereZweckbestimmungVerEntsorgung" ("Wert", "Bezeichner") VALUES ('16003', 'Brunnen');
INSERT INTO "XP_Enumerationen"."XP_BesondereZweckbestimmungVerEntsorgung" ("Wert", "Bezeichner") VALUES ('16004', 'Pumpwerk');
INSERT INTO "XP_Enumerationen"."XP_BesondereZweckbestimmungVerEntsorgung" ("Wert", "Bezeichner") VALUES ('16005', 'Quelle');
INSERT INTO "XP_Enumerationen"."XP_BesondereZweckbestimmungVerEntsorgung" ("Wert", "Bezeichner") VALUES ('18000', 'Abwasserleitung');
INSERT INTO "XP_Enumerationen"."XP_BesondereZweckbestimmungVerEntsorgung" ("Wert", "Bezeichner") VALUES ('18001', 'Abwasserrueckhaltebecken');
INSERT INTO "XP_Enumerationen"."XP_BesondereZweckbestimmungVerEntsorgung" ("Wert", "Bezeichner") VALUES ('18002', 'Abwasserpumpwerk');
INSERT INTO "XP_Enumerationen"."XP_BesondereZweckbestimmungVerEntsorgung" ("Wert", "Bezeichner") VALUES ('18003', 'Klaeranlage');
INSERT INTO "XP_Enumerationen"."XP_BesondereZweckbestimmungVerEntsorgung" ("Wert", "Bezeichner") VALUES ('18004', 'AnlageKlaerschlamm');
INSERT INTO "XP_Enumerationen"."XP_BesondereZweckbestimmungVerEntsorgung" ("Wert", "Bezeichner") VALUES ('18005', 'SonstigeAbwasserBehandlungsanlage');
INSERT INTO "XP_Enumerationen"."XP_BesondereZweckbestimmungVerEntsorgung" ("Wert", "Bezeichner") VALUES ('20000', 'RegenwasserRueckhaltebecken');
INSERT INTO "XP_Enumerationen"."XP_BesondereZweckbestimmungVerEntsorgung" ("Wert", "Bezeichner") VALUES ('20001', 'Niederschlagswasserleitung');
INSERT INTO "XP_Enumerationen"."XP_BesondereZweckbestimmungVerEntsorgung" ("Wert", "Bezeichner") VALUES ('22000', 'Muellumladestation');
INSERT INTO "XP_Enumerationen"."XP_BesondereZweckbestimmungVerEntsorgung" ("Wert", "Bezeichner") VALUES ('22001', 'Muellbeseitigungsanlage');
INSERT INTO "XP_Enumerationen"."XP_BesondereZweckbestimmungVerEntsorgung" ("Wert", "Bezeichner") VALUES ('22002', 'Muellsortieranlage');
INSERT INTO "XP_Enumerationen"."XP_BesondereZweckbestimmungVerEntsorgung" ("Wert", "Bezeichner") VALUES ('22003', 'Recyclinghof');
INSERT INTO "XP_Enumerationen"."XP_BesondereZweckbestimmungVerEntsorgung" ("Wert", "Bezeichner") VALUES ('24000', 'Erdaushubdeponie');
INSERT INTO "XP_Enumerationen"."XP_BesondereZweckbestimmungVerEntsorgung" ("Wert", "Bezeichner") VALUES ('24001', 'Bauschuttdeponie');
INSERT INTO "XP_Enumerationen"."XP_BesondereZweckbestimmungVerEntsorgung" ("Wert", "Bezeichner") VALUES ('24002', 'Hausmuelldeponie');
INSERT INTO "XP_Enumerationen"."XP_BesondereZweckbestimmungVerEntsorgung" ("Wert", "Bezeichner") VALUES ('24003', 'Sondermuelldeponie');
INSERT INTO "XP_Enumerationen"."XP_BesondereZweckbestimmungVerEntsorgung" ("Wert", "Bezeichner") VALUES ('24004', 'StillgelegteDeponie');
INSERT INTO "XP_Enumerationen"."XP_BesondereZweckbestimmungVerEntsorgung" ("Wert", "Bezeichner") VALUES ('24005', 'RekultivierteDeponie');
INSERT INTO "XP_Enumerationen"."XP_BesondereZweckbestimmungVerEntsorgung" ("Wert", "Bezeichner") VALUES ('26000', 'Fernmeldeanlage');
INSERT INTO "XP_Enumerationen"."XP_BesondereZweckbestimmungVerEntsorgung" ("Wert", "Bezeichner") VALUES ('26001', 'Mobilfunkstrecke');
INSERT INTO "XP_Enumerationen"."XP_BesondereZweckbestimmungVerEntsorgung" ("Wert", "Bezeichner") VALUES ('26002', 'Fernmeldekabel');
INSERT INTO "XP_Enumerationen"."XP_BesondereZweckbestimmungVerEntsorgung" ("Wert", "Bezeichner") VALUES ('99990', 'Produktenleitung');

-- -----------------------------------------------------
-- Data for table "XP_Enumerationen"."XP_ZweckbestimmungGewaesser"
-- -----------------------------------------------------
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungGewaesser" ("Wert", "Bezeichner") VALUES ('1000', 'Hafen');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungGewaesser" ("Wert", "Bezeichner") VALUES ('1100', 'Wasserflaeche');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungGewaesser" ("Wert", "Bezeichner") VALUES ('1200', 'Fliessgewaesser');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungGewaesser" ("Wert", "Bezeichner") VALUES ('9999', 'Sonstiges');

-- -----------------------------------------------------
-- Data for table "XP_Enumerationen"."XP_ZweckbestimmungWasserwirtschaft"
-- -----------------------------------------------------
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungWasserwirtschaft" ("Wert", "Bezeichner") VALUES ('1000', 'HochwasserRueckhaltebecken');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungWasserwirtschaft" ("Wert", "Bezeichner") VALUES ('1100', 'Ueberschwemmgebiet');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungWasserwirtschaft" ("Wert", "Bezeichner") VALUES ('1200', 'Versickerungsflaeche');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungWasserwirtschaft" ("Wert", "Bezeichner") VALUES ('1300', 'Entwaesserungsgraben');
INSERT INTO "XP_Enumerationen"."XP_ZweckbestimmungWasserwirtschaft" ("Wert", "Bezeichner") VALUES ('9999', 'Sonstiges');

-- -----------------------------------------------------
-- Data for table "XP_Enumerationen"."XP_Bundeslaender"
-- -----------------------------------------------------
INSERT INTO "XP_Enumerationen"."XP_Bundeslaender" ("Wert", "Bezeichner") VALUES ('1000', 'BB');
INSERT INTO "XP_Enumerationen"."XP_Bundeslaender" ("Wert", "Bezeichner") VALUES ('1100', 'BE');
INSERT INTO "XP_Enumerationen"."XP_Bundeslaender" ("Wert", "Bezeichner") VALUES ('1200', 'BW');
INSERT INTO "XP_Enumerationen"."XP_Bundeslaender" ("Wert", "Bezeichner") VALUES ('1300', 'BY');
INSERT INTO "XP_Enumerationen"."XP_Bundeslaender" ("Wert", "Bezeichner") VALUES ('1400', 'HB');
INSERT INTO "XP_Enumerationen"."XP_Bundeslaender" ("Wert", "Bezeichner") VALUES ('1500', 'HE');
INSERT INTO "XP_Enumerationen"."XP_Bundeslaender" ("Wert", "Bezeichner") VALUES ('1600', 'HH');
INSERT INTO "XP_Enumerationen"."XP_Bundeslaender" ("Wert", "Bezeichner") VALUES ('1700', 'MV');
INSERT INTO "XP_Enumerationen"."XP_Bundeslaender" ("Wert", "Bezeichner") VALUES ('1800', 'NI');
INSERT INTO "XP_Enumerationen"."XP_Bundeslaender" ("Wert", "Bezeichner") VALUES ('1900', 'NW');
INSERT INTO "XP_Enumerationen"."XP_Bundeslaender" ("Wert", "Bezeichner") VALUES ('2000', 'RP');
INSERT INTO "XP_Enumerationen"."XP_Bundeslaender" ("Wert", "Bezeichner") VALUES ('2100', 'SH');
INSERT INTO "XP_Enumerationen"."XP_Bundeslaender" ("Wert", "Bezeichner") VALUES ('2200', 'SL');
INSERT INTO "XP_Enumerationen"."XP_Bundeslaender" ("Wert", "Bezeichner") VALUES ('2300', 'SN');
INSERT INTO "XP_Enumerationen"."XP_Bundeslaender" ("Wert", "Bezeichner") VALUES ('2400', 'ST');
INSERT INTO "XP_Enumerationen"."XP_Bundeslaender" ("Wert", "Bezeichner") VALUES ('2500', 'TH');
INSERT INTO "XP_Enumerationen"."XP_Bundeslaender" ("Wert", "Bezeichner") VALUES ('3000', 'Bund');

-- -----------------------------------------------------
-- Data for table "SO_Schutzgebiete"."SO_KlassifizSchutzgebietNaturschutzrecht"
-- -----------------------------------------------------
INSERT INTO "SO_Schutzgebiete"."SO_KlassifizSchutzgebietNaturschutzrecht" ("Wert", "Bezeichner") VALUES ('1000', 'Naturschutzgebiet');
INSERT INTO "SO_Schutzgebiete"."SO_KlassifizSchutzgebietNaturschutzrecht" ("Wert", "Bezeichner") VALUES ('1100', 'Nationalpark');
INSERT INTO "SO_Schutzgebiete"."SO_KlassifizSchutzgebietNaturschutzrecht" ("Wert", "Bezeichner") VALUES ('1200', 'Biosphaerenreservat');
INSERT INTO "SO_Schutzgebiete"."SO_KlassifizSchutzgebietNaturschutzrecht" ("Wert", "Bezeichner") VALUES ('1300', 'Landschaftsschutzgebiet');
INSERT INTO "SO_Schutzgebiete"."SO_KlassifizSchutzgebietNaturschutzrecht" ("Wert", "Bezeichner") VALUES ('1400', 'Naturpark');
INSERT INTO "SO_Schutzgebiete"."SO_KlassifizSchutzgebietNaturschutzrecht" ("Wert", "Bezeichner") VALUES ('1500', 'Naturdenkmal');
INSERT INTO "SO_Schutzgebiete"."SO_KlassifizSchutzgebietNaturschutzrecht" ("Wert", "Bezeichner") VALUES ('1600', 'GeschuetzterLandschaftsBestandteil');
INSERT INTO "SO_Schutzgebiete"."SO_KlassifizSchutzgebietNaturschutzrecht" ("Wert", "Bezeichner") VALUES ('1700', 'GesetzlichGeschuetztesBiotop');
INSERT INTO "SO_Schutzgebiete"."SO_KlassifizSchutzgebietNaturschutzrecht" ("Wert", "Bezeichner") VALUES ('1800', 'Natura2000');
INSERT INTO "SO_Schutzgebiete"."SO_KlassifizSchutzgebietNaturschutzrecht" ("Wert", "Bezeichner") VALUES ('18000', 'GebietGemeinschaftlicherBedeutung');
INSERT INTO "SO_Schutzgebiete"."SO_KlassifizSchutzgebietNaturschutzrecht" ("Wert", "Bezeichner") VALUES ('18001', 'EuropaeischesVogelschutzgebiet');
INSERT INTO "SO_Schutzgebiete"."SO_KlassifizSchutzgebietNaturschutzrecht" ("Wert", "Bezeichner") VALUES ('2000', 'NationalesNaturmonument');
INSERT INTO "SO_Schutzgebiete"."SO_KlassifizSchutzgebietNaturschutzrecht" ("Wert", "Bezeichner") VALUES ('9999', 'Sonstiges');

-- -----------------------------------------------------
-- Data for table "XP_Basisobjekte"."XP_BedeutungenBereich"
-- -----------------------------------------------------
INSERT INTO "XP_Basisobjekte"."XP_BedeutungenBereich" ("Wert", "Bezeichner") VALUES ('1000', 'Aenderungsbereich');
INSERT INTO "XP_Basisobjekte"."XP_BedeutungenBereich" ("Wert", "Bezeichner") VALUES ('1500', 'Ergänzungsbereich');
INSERT INTO "XP_Basisobjekte"."XP_BedeutungenBereich" ("Wert", "Bezeichner") VALUES ('1600', 'Teilbereich');
INSERT INTO "XP_Basisobjekte"."XP_BedeutungenBereich" ("Wert", "Bezeichner") VALUES ('1700', 'Eingriffsbereich');
INSERT INTO "XP_Basisobjekte"."XP_BedeutungenBereich" ("Wert", "Bezeichner") VALUES ('1800', 'Ausgleichsbereich');
INSERT INTO "XP_Basisobjekte"."XP_BedeutungenBereich" ("Wert", "Bezeichner") VALUES ('2000', 'Nebenzeichnung');
INSERT INTO "XP_Basisobjekte"."XP_BedeutungenBereich" ("Wert", "Bezeichner") VALUES ('2500', 'Variante');
INSERT INTO "XP_Basisobjekte"."XP_BedeutungenBereich" ("Wert", "Bezeichner") VALUES ('3000', 'VertikaleGliederung');
INSERT INTO "XP_Basisobjekte"."XP_BedeutungenBereich" ("Wert", "Bezeichner") VALUES ('3500', 'Erstnutzung');
INSERT INTO "XP_Basisobjekte"."XP_BedeutungenBereich" ("Wert", "Bezeichner") VALUES ('4000', 'Folgenutzung');
INSERT INTO "XP_Basisobjekte"."XP_BedeutungenBereich" ("Wert", "Bezeichner") VALUES ('9999', 'Sonstiges');

-- -----------------------------------------------------
-- Data for table "XP_Basisobjekte"."XP_MimeTypes"
-- -----------------------------------------------------
INSERT INTO "XP_Basisobjekte"."XP_MimeTypes" ("Wert", "Bezeichner") VALUES ('application/pdf', 'application/pdf');
INSERT INTO "XP_Basisobjekte"."XP_MimeTypes" ("Wert", "Bezeichner") VALUES ('application/zip', 'application/zip');
INSERT INTO "XP_Basisobjekte"."XP_MimeTypes" ("Wert", "Bezeichner") VALUES ('application/xml', 'application/xml');
INSERT INTO "XP_Basisobjekte"."XP_MimeTypes" ("Wert", "Bezeichner") VALUES ('application/msword', 'application/msword');
INSERT INTO "XP_Basisobjekte"."XP_MimeTypes" ("Wert", "Bezeichner") VALUES ('application/msexcel', 'application/msexcel');
INSERT INTO "XP_Basisobjekte"."XP_MimeTypes" ("Wert", "Bezeichner") VALUES ('application/vnd.ogc.sld+xml', 'application/vnd.ogc.sld+xml');
INSERT INTO "XP_Basisobjekte"."XP_MimeTypes" ("Wert", "Bezeichner") VALUES ('application/vnd.ogc.wms_xml', 'application/vnd.ogc.wms_xml');
INSERT INTO "XP_Basisobjekte"."XP_MimeTypes" ("Wert", "Bezeichner") VALUES ('application/vnd.ogc.gml', 'application/vnd.ogc.gml');
INSERT INTO "XP_Basisobjekte"."XP_MimeTypes" ("Wert", "Bezeichner") VALUES ('application/odt', 'application/odt');
INSERT INTO "XP_Basisobjekte"."XP_MimeTypes" ("Wert", "Bezeichner") VALUES ('image/jpg', 'image/jpg');
INSERT INTO "XP_Basisobjekte"."XP_MimeTypes" ("Wert", "Bezeichner") VALUES ('image/png', 'image/png');
INSERT INTO "XP_Basisobjekte"."XP_MimeTypes" ("Wert", "Bezeichner") VALUES ('image/tiff', 'image/tiff');
INSERT INTO "XP_Basisobjekte"."XP_MimeTypes" ("Wert", "Bezeichner") VALUES ('image/ecw', 'image/ecw');
INSERT INTO "XP_Basisobjekte"."XP_MimeTypes" ("Wert", "Bezeichner") VALUES ('image/svg+xml', 'image/svg+xml');
INSERT INTO "XP_Basisobjekte"."XP_MimeTypes" ("Wert", "Bezeichner") VALUES ('text/html', 'text/html');
INSERT INTO "XP_Basisobjekte"."XP_MimeTypes" ("Wert", "Bezeichner") VALUES ('text/plain', 'text/plain');

-- -----------------------------------------------------
-- Data for table "XP_Basisobjekte"."XP_ExterneReferenzArt"
-- -----------------------------------------------------
INSERT INTO "XP_Basisobjekte"."XP_ExterneReferenzArt" ("Wert", "Bezeichner") VALUES ('Dokument', 'Dokument');
INSERT INTO "XP_Basisobjekte"."XP_ExterneReferenzArt" ("Wert", "Bezeichner") VALUES ('PlanMitGeoreferenz', 'PlanMitGeoreferenz');

-- -----------------------------------------------------
-- Data for table "XP_Basisobjekte"."XP_RechtscharakterPlanaenderung"
-- -----------------------------------------------------
INSERT INTO "XP_Basisobjekte"."XP_RechtscharakterPlanaenderung" ("Wert", "Bezeichner") VALUES ('1000', 'Aenderung');
INSERT INTO "XP_Basisobjekte"."XP_RechtscharakterPlanaenderung" ("Wert", "Bezeichner") VALUES ('2000', 'Aufhebung');

-- -----------------------------------------------------
-- Data for table "XP_Praesentationsobjekte"."XP_VertikaleAusrichtung"
-- -----------------------------------------------------
INSERT INTO "XP_Praesentationsobjekte"."XP_VertikaleAusrichtung" ("Wert", "Bezeichner") VALUES ('Basis', 'Basis');
INSERT INTO "XP_Praesentationsobjekte"."XP_VertikaleAusrichtung" ("Wert", "Bezeichner") VALUES ('Mitte', 'Mitte');
INSERT INTO "XP_Praesentationsobjekte"."XP_VertikaleAusrichtung" ("Wert", "Bezeichner") VALUES ('Oben', 'Oben');

-- -----------------------------------------------------
-- Data for table "XP_Praesentationsobjekte"."XP_HorizontaleAusrichtung"
-- -----------------------------------------------------
INSERT INTO "XP_Praesentationsobjekte"."XP_HorizontaleAusrichtung" ("Wert", "Bezeichner") VALUES ('linksbündig', 'linksbündig');
INSERT INTO "XP_Praesentationsobjekte"."XP_HorizontaleAusrichtung" ("Wert", "Bezeichner") VALUES ('rechtsbündig', 'rechtsbündig');
INSERT INTO "XP_Praesentationsobjekte"."XP_HorizontaleAusrichtung" ("Wert", "Bezeichner") VALUES ('zentrisch', 'zentrisch');

-- -----------------------------------------------------
-- Data for table "XP_Sonstiges"."XP_SPEMassnamenTypen"
-- -----------------------------------------------------
INSERT INTO "XP_Sonstiges"."XP_SPEMassnamenTypen" ("Wert", "Bezeichner") VALUES ('1000', 'ArtentreicherGehoelzbestand');
INSERT INTO "XP_Sonstiges"."XP_SPEMassnamenTypen" ("Wert", "Bezeichner") VALUES ('1100', 'NaturnaherWald');
INSERT INTO "XP_Sonstiges"."XP_SPEMassnamenTypen" ("Wert", "Bezeichner") VALUES ('1200', 'ExtensivesGruenland');
INSERT INTO "XP_Sonstiges"."XP_SPEMassnamenTypen" ("Wert", "Bezeichner") VALUES ('1300', 'Feuchtgruenland');
INSERT INTO "XP_Sonstiges"."XP_SPEMassnamenTypen" ("Wert", "Bezeichner") VALUES ('1400', 'Obstwiese');
INSERT INTO "XP_Sonstiges"."XP_SPEMassnamenTypen" ("Wert", "Bezeichner") VALUES ('1500', 'NaturnaherUferbereich');
INSERT INTO "XP_Sonstiges"."XP_SPEMassnamenTypen" ("Wert", "Bezeichner") VALUES ('1600', 'Roehrichtzone');
INSERT INTO "XP_Sonstiges"."XP_SPEMassnamenTypen" ("Wert", "Bezeichner") VALUES ('1700', 'Ackerrandstreifen');
INSERT INTO "XP_Sonstiges"."XP_SPEMassnamenTypen" ("Wert", "Bezeichner") VALUES ('1800', 'Ackerbrache');
INSERT INTO "XP_Sonstiges"."XP_SPEMassnamenTypen" ("Wert", "Bezeichner") VALUES ('1900', 'Gruenlandbrache');
INSERT INTO "XP_Sonstiges"."XP_SPEMassnamenTypen" ("Wert", "Bezeichner") VALUES ('2000', 'Sukzessionsflaeche');
INSERT INTO "XP_Sonstiges"."XP_SPEMassnamenTypen" ("Wert", "Bezeichner") VALUES ('2100', 'Hochstaudenflur');
INSERT INTO "XP_Sonstiges"."XP_SPEMassnamenTypen" ("Wert", "Bezeichner") VALUES ('2200', 'Trockenrasen');
INSERT INTO "XP_Sonstiges"."XP_SPEMassnamenTypen" ("Wert", "Bezeichner") VALUES ('2300', 'Heide');
INSERT INTO "XP_Sonstiges"."XP_SPEMassnamenTypen" ("Wert", "Bezeichner") VALUES ('9999', 'Sonstiges');

-- -----------------------------------------------------
-- Data for table "XP_Sonstiges"."XP_SPEZiele"
-- -----------------------------------------------------
INSERT INTO "XP_Sonstiges"."XP_SPEZiele" ("Wert", "Bezeichner") VALUES ('1000', 'SchutzPflege');
INSERT INTO "XP_Sonstiges"."XP_SPEZiele" ("Wert", "Bezeichner") VALUES ('2000', 'Entwicklung');
INSERT INTO "XP_Sonstiges"."XP_SPEZiele" ("Wert", "Bezeichner") VALUES ('9999', 'Sonstiges');

-- -----------------------------------------------------
-- Data for table "XP_Sonstiges"."XP_ArtHoehenbezug"
-- -----------------------------------------------------
INSERT INTO "XP_Sonstiges"."XP_ArtHoehenbezug" ("Wert", "Bezeichner") VALUES ('1000', 'absolutNHN');
INSERT INTO "XP_Sonstiges"."XP_ArtHoehenbezug" ("Wert", "Bezeichner") VALUES ('2000', 'relativGelaendeoberkante');
INSERT INTO "XP_Sonstiges"."XP_ArtHoehenbezug" ("Wert", "Bezeichner") VALUES ('2500', 'relativGehwegOberkante');
INSERT INTO "XP_Sonstiges"."XP_ArtHoehenbezug" ("Wert", "Bezeichner") VALUES ('3000', 'relativBezugshoehe');

-- -----------------------------------------------------
-- Data for table "XP_Sonstiges"."XP_ArtHoehenbezugspunkt"
-- -----------------------------------------------------
INSERT INTO "XP_Sonstiges"."XP_ArtHoehenbezugspunkt" ("Wert", "Bezeichner") VALUES ('1000', 'TH');
INSERT INTO "XP_Sonstiges"."XP_ArtHoehenbezugspunkt" ("Wert", "Bezeichner") VALUES ('2000', 'FH');
INSERT INTO "XP_Sonstiges"."XP_ArtHoehenbezugspunkt" ("Wert", "Bezeichner") VALUES ('3000', 'OK');
INSERT INTO "XP_Sonstiges"."XP_ArtHoehenbezugspunkt" ("Wert", "Bezeichner") VALUES ('3500', 'LH');
INSERT INTO "XP_Sonstiges"."XP_ArtHoehenbezugspunkt" ("Wert", "Bezeichner") VALUES ('4000', 'SH');
INSERT INTO "XP_Sonstiges"."XP_ArtHoehenbezugspunkt" ("Wert", "Bezeichner") VALUES ('4500', 'EFH');
INSERT INTO "XP_Sonstiges"."XP_ArtHoehenbezugspunkt" ("Wert", "Bezeichner") VALUES ('5000', 'HBA');
INSERT INTO "XP_Sonstiges"."XP_ArtHoehenbezugspunkt" ("Wert", "Bezeichner") VALUES ('5500', 'UK');
INSERT INTO "XP_Sonstiges"."XP_ArtHoehenbezugspunkt" ("Wert", "Bezeichner") VALUES ('6000', 'GBH');

