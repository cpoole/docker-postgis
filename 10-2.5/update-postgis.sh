#!/bin/sh

# http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'

POSTGIS_VERSION="${POSTGIS_VERSION%%+*}"
DATABASES=$(echo ${POSTGRES_DBS} | tr ',' ' ')
if [[ -n ${POSTGRES_DB} ]]; then
    DATABASES="${POSTGRES_DB} ${DATABASES}"
fi

# Load PostGIS into both template_database and ${DATABASES}
for DB in template_postgis ${DATABASES} "${@}"; do
    echo "Updating PostGIS extensions '$DB' to $POSTGIS_VERSION"
    psql --dbname="$DB" -c "
        -- Upgrade PostGIS (includes raster)
        CREATE EXTENSION IF NOT EXISTS postgis VERSION '$POSTGIS_VERSION';
        ALTER EXTENSION postgis  UPDATE TO '$POSTGIS_VERSION';

        -- Upgrade Topology
        CREATE EXTENSION IF NOT EXISTS postgis_topology VERSION '$POSTGIS_VERSION';
        ALTER EXTENSION postgis_topology UPDATE TO '$POSTGIS_VERSION';

        -- Install Tiger dependencies in case not already installed
        CREATE EXTENSION IF NOT EXISTS fuzzystrmatch;
        -- Upgrade US Tiger Geocoder
        CREATE EXTENSION IF NOT EXISTS postgis_tiger_geocoder VERSION '$POSTGIS_VERSION';
        ALTER EXTENSION postgis_tiger_geocoder UPDATE TO '$POSTGIS_VERSION';
    "
done
