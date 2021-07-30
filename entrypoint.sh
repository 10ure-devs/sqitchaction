#!/bin/sh -l

echo "Hello $1"
PGUSER=$1 PGPASSWORD=$2 PGDATABASE=$3 PGHOST=$4 PGPORT=$5 SSLMODE=$6 sqitch deploy

time=$(date)
echo "::set-output name=time::$time"