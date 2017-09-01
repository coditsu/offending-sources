#!/bin/sh

##############################################################################
# This script will download the most recently weekly dump listed on
# https://rubygems.org/pages/data and load it into a postgresql database.
#
# Assumptions:
#
# 1) a 'postgres' user exists your postgresql instance
#    The dump script explicitly assigns ownership to the 'postgres' user, and
#    so the 'postgres' user should exist
# 2) the user you pass with the -u option is a postgres super user
#
# Notes:
#
#  * This script will drop and create the database, so buyer beware.
#
##############################################################################

# variables
public_tar=
pg_database=$DB_NAME
pg_user=$DB_USERNAME
download=false

export PGPASSWORD=$DB_PASSWORD

## For downloading
base_url="https://s3-us-west-2.amazonaws.com/rubygems-dumps/"
prefix="production/public_postgresql"

## Usage info
show_help() {
  cat << EOF
Usage: ${0##*/} [-h] [-c] [-d DATABASE] [-u USER] FILE

Load a rubygems.org postgresql dump into a datatbase.

    -h          display this help and exit
    -c          download the latest file to FILE
    -d DATABASE load the data into this database (default: rubygems)
    -u USER     connect to postgresql using this username (default: postgres)
EOF
}

OPTIND=1
while getopts "hcd:u:" opt; do
    case "$opt" in
        h)
            show_help
            exit 0
            ;;
        c)  download=true
            ;;
        d)  pg_database=$OPTARG
            ;;
        u)  pg_user=$OPTARG
            ;;
        '?')
            show_help >&2
            exit 1
            ;;
    esac
done
shift "$((OPTIND-1))" # Shift off the options and optional

public_tar=$1
if [ -z "$public_tar" ]; then
  show_help >&2
  exit 1
fi

if true; then
  key=$(curl -s "${base_url}?prefix=${prefix}" | sed -ne 's/.*<Key>\(.*\)<\/Key>.*/\1/p')
  latest_url="${base_url}${key}"
  echo "Downloading ${latest_url} to ${public_tar}"
  curl --progress-bar "${latest_url}" > ${public_tar}
fi

printf 'Loading "%s" into database "%s" as user "%s"\n', "$public_tar", "$pg_database", "$pg_user"

DROP_SQL="select 'drop table \"' || tablename || '\" cascade;' from pg_tables where schemaname = 'public';"

psql -q -h $DB_HOST -U $pg_user -p$DB_PORT -d $pg_database -t -c "$DROP_SQL" | psql -h $DB_HOST -U $pg_user -p$DB_PORT -d $pg_database

echo "Adding hstore extension"
psql -q -h $DB_HOST -U $pg_user -p$DB_PORT -d $pg_database -c "CREATE EXTENSION IF NOT EXISTS hstore;"

# Extract the single PostgresSQL.sql.gz file from the tar file, pass it through gunzip
# and load it as quietly as possible into the database
echo "Loading the data from $public_tar"
tar xOf $public_tar public_postgresql/databases/PostgreSQL.sql.gz | \
  gunzip -c | \
  psql -h $DB_HOST --username $pg_user -p$DB_PORT --dbname $pg_database

echo "Done."
