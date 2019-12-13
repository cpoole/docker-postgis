#!/bin/bash
set -u

PSQL_DIR="/var/lib/postgresql/"
PSQL_TAR_SEED="/opt/postgres-seed.tar.gz"

function exists(){
    if  [[ -z $( stat "$1" 2>/dev/null) ]]; then
        return 0
    fi

    return 1
}

function is_empty(){
    local found_files=$( ls "$PSQL_DIR" )

    if [ -z "$found_files" ]; then
        return 0
    fi

    return 1
}


if ! exists "$PSQL_DIR" ; then
    echo Creating "$PSQL_DIR..."
    mkdir "$PSQL_DIR"
fi

if  is_empty "$PSQL_DIR"; then
    echo "Planting postgres data seed..."
    tar -xzf "$PSQL_TAR_SEED" -C "$PSQL_DIR"
else 
    echo "psql dir not empty omgggg "
fi
