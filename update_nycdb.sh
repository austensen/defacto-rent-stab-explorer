#!/bin/sh

# This script is designed to locally update all the tables used for the app in 
# your local nycdb instance, then to recreate the derived table used for the app, 
# and finally push the updated table into a remote database for hosting the app.

# get variables for database connections
# edit nycdb_env_sample.sh for your information and and save it as nycdb_env.sh
source ./nycdb_env.sh

# Set password so psql does not prompt
export PGPASSWORD="$NYCDB_LOCAL_PASSWORD"


# check if pluto already exists in local database, if it does not then download/load it

PLUTO_EXISTS=`psql -q -t -U "$NYCDB_LOCAL_USER" -d "$NYCDB_LOCAL_DATABASE" -h "$NYCDB_LOCAL_HOST" \
	-c "SELECT 'TRUE' FROM pg_catalog.pg_tables where tablename = 'pluto_18v2';"`

if [[ "$PLUTO_EXISTS" != *"TRUE"* ]]; then
	echo "$PLUTO_EXISTS"
	nycdb -U "$NYCDB_LOCAL_USER" -D "$NYCDB_LOCAL_DATABASE" -H "$NYCDB_LOCAL_HOST" -P "$NYCDB_LOCAL_PASSWORD" \
		--download pluto_18v2
	nycdb -U "$NYCDB_LOCAL_USER" -D "$NYCDB_LOCAL_DATABASE" -H "$NYCDB_LOCAL_HOST" -P "$NYCDB_LOCAL_PASSWORD" \
		--load pluto_18v2
fi


# check if pad already exists in local database, if it does not then download/load it

PAD_EXISTS=`psql -q -t -U "$NYCDB_LOCAL_USER" -d "$NYCDB_LOCAL_DATABASE" -h "$NYCDB_LOCAL_HOST" \
	-c "SELECT 'TRUE' FROM pg_catalog.pg_tables where tablename = 'pad_adr';"`

if [[ "$PAD_EXISTS" != *"TRUE"* ]]; then
	echo "$PAD_EXISTS"
	nycdb -U "$NYCDB_LOCAL_USER" -D "$NYCDB_LOCAL_DATABASE" -H "$NYCDB_LOCAL_HOST" -P "$NYCDB_LOCAL_PASSWORD" \
		--download pad_adr
	nycdb -U "$NYCDB_LOCAL_USER" -D "$NYCDB_LOCAL_DATABASE" -H "$NYCDB_LOCAL_HOST" -P "$NYCDB_LOCAL_PASSWORD" \
		--load pad_adr
fi


# locally rebuild each of the tables that are frequently updated
for table in hpd_complaints hpd_violations ecb_violations dob_violations oath_hearings hpd_vacateorders; do
	echo "$table"

	psql -U "$NYCDB_LOCAL_USER" -d "$NYCDB_LOCAL_DATABASE" -h "$NYCDB_LOCAL_HOST" \
	-c "DROP TABLE IF EXISTS $table;"
	
	# hpd_complaints also includes hpd_complaint_problems
	if [[ "$table" == "hpd_complaints" ]]; then
		psql -U "$NYCDB_LOCAL_USER" -d "$NYCDB_LOCAL_DATABASE" -h "$NYCDB_LOCAL_HOST" \
		-c "DROP TABLE IF EXISTS hpd_complaint_problems;"
	fi

	nycdb -U "$NYCDB_LOCAL_USER" -D "$NYCDB_LOCAL_DATABASE" -H "$NYCDB_LOCAL_HOST" -P "$NYCDB_LOCAL_PASSWORD" \
		--download "$table"
	nycdb -U "$NYCDB_LOCAL_USER" -D "$NYCDB_LOCAL_DATABASE" -H "$NYCDB_LOCAL_HOST" -P "$NYCDB_LOCAL_PASSWORD" \
		--load "$table"
done


# run the sql script to create the table we need to run the app
psql -U "$NYCDB_LOCAL_USER" -d "$NYCDB_LOCAL_DATABASE"  -h "$NYCDB_LOCAL_HOST" \
	-f sql/defacto_bk_bbl_details.sql


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
