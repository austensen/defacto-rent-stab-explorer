#!/bin/sh

# update_nycdb_local.sh
# update_defacto_local.sh
# update defacto_remote.sh

# These scripts are designed to update all the tables used for the app in your
# local nycdb instance, then to recreate the derived table used for the app, 
# and finally push the updated table into a remote database for hosting the app.

# get variables for database connections
# edit nycdb_env_sample.sh for your information and and save it as nycdb_env.sh
source ./nycdb_env.sh

# Set password so psql does not prompt
export PGPASSWORD="$NYCDB_LOCAL_PASSWORD"


# check if pluto already exists in local database, if it does not then download/load it

PLUTO_EXISTS=`psql -q -t -U "$NYCDB_LOCAL_USER" -d "$NYCDB_LOCAL_DATABASE" -h "$NYCDB_LOCAL_HOST" \
	-c "SELECT 'TRUE' FROM pg_catalog.pg_tables where tablename = 'pluto_19v1';"`

if [[ "$PLUTO_EXISTS" != *"TRUE"* ]]; then
	echo "$PLUTO_EXISTS"
	nycdb -U "$NYCDB_LOCAL_USER" -D "$NYCDB_LOCAL_DATABASE" -H "$NYCDB_LOCAL_HOST" -P "$NYCDB_LOCAL_PASSWORD" \
		--download pluto_19v1
	nycdb -U "$NYCDB_LOCAL_USER" -D "$NYCDB_LOCAL_DATABASE" -H "$NYCDB_LOCAL_HOST" -P "$NYCDB_LOCAL_PASSWORD" \
		--load pluto_19v1
fi


# check if pad already exists in local database, if it does not then download/load it

PAD_EXISTS=`psql -q -t -U "$NYCDB_LOCAL_USER" -d "$NYCDB_LOCAL_DATABASE" -h "$NYCDB_LOCAL_HOST" \
	-c "SELECT 'TRUE' FROM pg_catalog.pg_tables where tablename = 'pad_adr';"`

if [[ "$PAD_EXISTS" != *"TRUE"* ]]; then
	echo "$PAD_EXISTS"
	nycdb -U "$NYCDB_LOCAL_USER" -D "$NYCDB_LOCAL_DATABASE" -H "$NYCDB_LOCAL_HOST" -P "$NYCDB_LOCAL_PASSWORD" \
		--download pad
	nycdb -U "$NYCDB_LOCAL_USER" -D "$NYCDB_LOCAL_DATABASE" -H "$NYCDB_LOCAL_HOST" -P "$NYCDB_LOCAL_PASSWORD" \
		--load pad
fi


# locally rebuild each of the tables that are frequently updated
for table in hpd_complaints hpd_violations ecb_violations dob_violations dob_complaints oath_hearings hpd_vacateorders; do
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
