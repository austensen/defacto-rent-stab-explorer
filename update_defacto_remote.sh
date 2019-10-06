#!/bin/sh

# update_nycdb_local.sh
# update_defacto_local.sh
# update_defacto_remote.sh

# These scripts are designed to update all the tables used for the app in your
# local nycdb instance, then to recreate the derived table used for the app, 
# and finally push the updated table into a remote database for hosting the app.

# get variables for database connections
# edit nycdb_env_sample.sh for your information and and save it as nycdb_env.sh
source ./nycdb_env.sh

# Set password so psql does not prompt
export PGPASSWORD="$NYCDB_LOCAL_PASSWORD"

# create a pg_dump of only the table we just created
pg_dump -U "$NYCDB_LOCAL_USER" -d "$NYCDB_LOCAL_DATABASE" -h "$NYCDB_LOCAL_HOST" \
	--table=defacto_bk_bbl_details --file=defacto_table_dump.sql --clean --no-owner


# re-set password to remote server now
export PGPASSWORD="$NYCDB_REMOTE_PASSWORD"


# get list of all databases in our remote server
REMOTE_DATABASES=`psql -q -t -U "$NYCDB_REMOTE_USER" -h "$NYCDB_REMOTE_HOST" --list`

# if nycdb does not already exist there then create it
if [[ "$REMOTE_DATABASES" != *"nycdb"* ]]; then
	psql -U "$NYCDB_REMOTE_USER" -h "$NYCDB_REMOTE_HOST" \
		-c "CREATE DATABASE nycdb;"
fi


# load the sql dump of our table into the remote database
psql -U "$NYCDB_REMOTE_USER" -d "$NYCDB_REMOTE_DATABASE" -h "$NYCDB_REMOTE_HOST" \
	< defacto_table_dump.sql
