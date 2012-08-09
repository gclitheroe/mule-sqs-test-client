#!/bin/sh
# A script to initialise the database.
# 
# Install postgres and postgis.
# There are comprehensive instructions here http://wiki.openstreetmap.org/wiki/Mapnik/PostGIS
#
# Set the default timezone to UTC and set the timezone abbreviations.  
# Assuming a yum install this will be `/var/lib/pgsql/data/postgresql.conf`
# ...
# timezone = UTC
# timezone_abbreviations = 'Default'
#
# For testing do not set a password for postgres and in /var/lib/pgsql/data/pg_hba.conf set
# connections for local ans host connections to trust:
#
# local   all             all                                     trust
# host    all             all             127.0.0.1/32            trust
#
# Restart postgres.
#
#
# Basic UTF8 postgres DB
#
dropdb --username=postgres hazard
dropuser --username=postgres hazard
createuser --username=postgres --no-createdb --no-superuser --no-createrole hazard
createdb --username=postgres -E UTF8 --template=template0 -O hazard hazard
createlang --username=postgres plpgsql hazard 
#
# Add postgis to the database
#
psql --quiet --username=postgres --dbname=hazard --file=/usr/share/pgsql/contrib/postgis-64.sql
echo "ALTER TABLE geometry_columns OWNER TO hazard; ALTER TABLE spatial_ref_sys OWNER TO hazard;"  | psql --quiet --dbname=hazard --username=postgres
psql --quiet --username=hazard --dbname=hazard --file=/usr/share/pgsql/contrib/spatial_ref_sys.sql
#
# Create the qrt schema.
#
psql --quiet --username=hazard --dbname=hazard --file=ddl/qrt-drop-create.ddl
