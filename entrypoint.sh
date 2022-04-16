#!/bin/sh -l
set -e 

echo "Navigating to $7"
cd $7

ls

set -x
PGUSER=$1 PGPASSWORD=$2 PGDATABASE=$3 PGHOST=$4 PGPORT=$5 SSLMODE=$6 sqitch deploy $8 || exit 1
set +x

time=$(date)
echo "::set-output name=time::$time"