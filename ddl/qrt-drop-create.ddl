-- For everthing to behave well the default timezone needs to be set e.g.,
-- in /var/lib/pgsql/data/postgresql.conf
--
-- timezone = UTC
-- timezone_abbreviations = 'Default'

DROP SCHEMA IF EXISTS qrt CASCADE;

DELETE from geometry_columns where f_table_schema='qrt';

CREATE SCHEMA qrt;

-- numeric without any precision or scale creates a column in which numeric
-- values of any precision and scale can be stored, up to the implementation
-- limit on precision.
-- http://www.postgresql.org/docs/8.3/static/datatype-numeric.html

CREATE TABLE qrt.testpoint (
latitude numeric NOT NULL,
longitude numeric NOT NULL,
epsgCode int4 DEFAULT 4326 NOT NULL);

CREATE TABLE qrt.gt_pk_metadata_table (table_schema varchar(255), table_name varchar(255), pk_column varchar(255), pk_column_idx integer, pk_policy varchar(255), pk_sequence varchar(255));

SELECT addgeometrycolumn('qrt', 'testpoint', 'geom', 4326, 'POINT', 2);

CREATE FUNCTION qrt.update_origin_geom() RETURNS  TRIGGER AS E' BEGIN NEW.geom = transform(setsrid(makepoint(NEW.longitude, NEW.latitude),New.epsgCode),4326); RETURN NEW;  END; ' LANGUAGE plpgsql;

CREATE TRIGGER origin_geom_trigger BEFORE INSERT OR UPDATE ON qrt.testpoint
  FOR EACH ROW EXECUTE PROCEDURE qrt.update_origin_geom();
