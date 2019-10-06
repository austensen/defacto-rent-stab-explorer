#!/bin/sh

# update_nycdb_local.sh
# update_defacto_local.sh
# update defacto_remote.sh

# These scripts are designed to update all the tables used for the app in your
# local nycdb instance, then to recreate the derived table used for the app, 
# and finally push the updated table into a remote database for hosting the app.

# Set password so psql does not prompt
export PGPASSWORD="$NYCDB_LOCAL_PASSWORD"

# run the sql script to create the table we need to run the app
psql -U "$NYCDB_LOCAL_USER" -d "$NYCDB_LOCAL_DATABASE"  -h "$NYCDB_LOCAL_HOST" \
	-f sql/defacto_bk_bbl_details.sql
