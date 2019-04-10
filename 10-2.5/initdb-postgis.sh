#!/bin/sh

# http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'

POSTGIS_VERSION="${POSTGIS_VERSION%%+*}"
DATABASES=$(echo ${POSTGRES_DBS} | tr ',' ' ')
if [[ -n ${POSTGRES_DB} ]]; then
    DATABASES="${POSTGRES_DB} ${DATABASES}"
fi

# Create the 'template_postgis' template db
"${psql[@]}" <<-'EOSQL'
CREATE DATABASE template_postgis;
UPDATE pg_database SET datistemplate = TRUE WHERE datname = 'template_postgis';
EOSQL

# TODO: create multiple users

# Create databases
for DB in ${DATABASES}; do
    DB_USER_UPPER=$(echo "${DB}" | tr '[:lower:]' '[:upper:]')
    DB_USER="POSTGRES_${DB_USER_UPPER}_USER"
    if [[ -n "${DB_USER}" ]]; then
        DB_USER="${POSTGRES_USER}"
    fi
    echo "Creating database ${DB} for user ${DB_USER}"
    "${psql[@]}" --dbname="${DB}" --user="${DB_USER}" <<-'EOSQL'
CREATE DATABASE ${DB};
GRANT ALL PRIVILEGES ON DATABASE ${DB} TO ${DB_USER};
EOSQL
done

# Load PostGIS into both template_database and ${DATABASES}
for DB in template_postgis ${DATABASES} "${@}"; do
	echo "Loading PostGIS extensions into $DB"
	"${psql[@]}" --dbname="$DB" <<-'EOSQL'
		CREATE EXTENSION IF NOT EXISTS postgis;
		CREATE EXTENSION IF NOT EXISTS postgis_topology;
		CREATE EXTENSION IF NOT EXISTS fuzzystrmatch;
		CREATE EXTENSION IF NOT EXISTS postgis_tiger_geocoder;
EOSQL
done
