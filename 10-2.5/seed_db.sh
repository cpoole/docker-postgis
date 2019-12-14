#!/bin/bash
set -u

PSQL_DIR="/var/lib/postgresql/"
PSQL_TAR_SEED="/opt/postgres-seed.tar.gz"

function exists(){
    if  [[ -z $( stat "$1" 2>/dev/null) ]]; then
        return 1
    fi

    return 0
}

function is_empty(){
    local found_files=$( ls "$PSQL_DIR" )

    if [ -z "$found_files" ]; then
        return 1
    fi

    return 0
}


if ! exists "$PSQL_TAR_SEED"; then
    echo "No psql data seed found."
    exit 1 
fi

echo "Planting psql data seed..."
tar -xzf "$PSQL_TAR_SEED" -C "$PSQL_DIR"
