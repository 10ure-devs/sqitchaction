#!/bin/sh -l
set -eu

echo "Navigating to $7"
cd $7
ls



PGUSER=$1 PGPASSWORD=$2 PGDATABASE=$3 PGHOST=$4 PGPORT=$5 SSLMODE=$6 sqitch deploy $8 || exit 1

echo "GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO $9"
PGUSER=$1 PGPASSWORD=$2 PGDATABASE=$3 PGHOST=$4 PGPORT=$5 SSLMODE=$6 psql -c "GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO $9"

echo "GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO $9"
PGUSER=$1 PGPASSWORD=$2 PGDATABASE=$3 PGHOST=$4 PGPORT=$5 SSLMODE=$6 psql -c "GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO $9"

echo "ALTER DEFAULT PRIVILEGES FOR USER dbadmin IN SCHEMA public GRANT ALL PRIVILEGES ON TABLES TO $9"
PGUSER=$1 PGPASSWORD=$2 PGDATABASE=$3 PGHOST=$4 PGPORT=$5 SSLMODE=$6 psql -c "ALTER DEFAULT PRIVILEGES FOR USER dbadmin IN SCHEMA public GRANT ALL PRIVILEGES ON TABLES TO $9"

echo "ALTER DEFAULT PRIVILEGES FOR USER db IN SCHEMA public GRANT USAGE ON SEQUENCES TO $9"
PGUSER=$1 PGPASSWORD=$2 PGDATABASE=$3 PGHOST=$4 PGPORT=$5 SSLMODE=$6 psql -c "ALTER DEFAULT PRIVILEGES FOR USER db IN SCHEMA public GRANT USAGE ON SEQUENCES TO $9"

materialized_views=$(psql -tqc "select matviewname from pg_catalog.pg_matviews")
if [ -n "${materialized_views:-}" ]; then
    log "Setting ${USER_PGUSER} as the owner of the following materialized views:"
    log "${materialized_views}"
    for view in ${materialized_views}; do
        psql -c "ALTER MATERIALIZED VIEW ${view} OWNER TO ${USER_PGUSER?};"
    done
else
    log "No materialized views found, and that's ok."
fi



time=$(date)
echo "::set-output name=time::$time"