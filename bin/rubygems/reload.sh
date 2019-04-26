#!/bin/sh

public_tar=$1
base_url="https://s3-us-west-2.amazonaws.com/rubygems-dumps/"
prefix="production/public_postgresql"

export PGPASSWORD=$DB_PASSWORD

VERSION_FILE="$RAILS_ROOT/public/recent_dump.txt"
touch $VERSION_FILE

key=$(curl -s "${base_url}?prefix=${prefix}" | sed -ne 's/.*<Key>\(.*\)<\/Key>.*/\1/p')
latest_url="${base_url}${key}"

if grep -Fxq "$latest_url" $VERSION_FILE; then
  exit
else
  echo $latest_url > "$RAILS_ROOT/public/recent_dump.txt"
  echo "Downloading ${latest_url} to ${public_tar}"
  curl --progress-bar "${latest_url}" > ${public_tar}
fi

DROP_SQL="select 'drop table \"' || tablename || '\" cascade;' from pg_tables where schemaname = 'public';"

psql -q -h $DB_HOST -U $DB_USERNAME -p$DB_PORT -d $DB_NAME -t -c "$DROP_SQL" | psql -h $DB_HOST -U $DB_USERNAME -p$DB_PORT -d $DB_NAME
psql -q -h $DB_HOST -U $DB_USERNAME -p$DB_PORT -d $DB_NAME -c "CREATE EXTENSION IF NOT EXISTS hstore;"

tar xOf $public_tar public_postgresql/databases/PostgreSQL.sql.gz | \
  gunzip -c | \
  psql -h $DB_HOST --username $DB_USERNAME -p$DB_PORT --dbname $DB_NAME

rm $public_tar
