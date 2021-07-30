#!/bin/sh -l
set -e 

echo "Navigating to $7"

cd $7

ls

PGUSER=$1 PGPASSWORD=$2 PGDATABASE=$3 PGHOST=$4 PGPORT=$5 SSLMODE=$6 sqitch deploy -v || exit 1

time=$(date)
echo "::set-output name=time::$time"