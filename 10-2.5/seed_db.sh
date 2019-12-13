#!/bin/bash
set -u

PSQL_DIR="/tmp/test"
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




if  exists "$PSQL_DIR"; then
    echo "no exist"
    exit 1
fi

if  is_empty "$PSQL_DIR"; then
    echo "empty"
 else 
    echo "not empty"
fi

#if no files in regular dir
#
#untar seed dir if exists
