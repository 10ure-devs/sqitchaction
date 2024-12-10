#!/bin/sh -l
set -eu

echo "Navigating to $7"
cd $7

export PGUSER=$1
export PGPASSWORD=$2
export PGDATABASE=$3
export PGHOST=$4
export PGPORT=$5
export SSLMODE=$6

PGUSER=$1 PGPASSWORD=$2 PGDATABASE=$3 PGHOST=$4 PGPORT=$5 SSLMODE=$6 sqitch deploy $8 || exit 1

# give snapshooter role min permissions to dump database for backups
PGUSER=$1 PGPASSWORD=$2 PGDATABASE=$3 PGHOST=$4 PGPORT=$5 SSLMODE=$6 psql -c "GRANT CONNECT ON DATABASE $3 TO snapshooter"
PGUSER=$1 PGPASSWORD=$2 PGDATABASE=$3 PGHOST=$4 PGPORT=$5 SSLMODE=$6 psql -c "GRANT SELECT ON ALL TABLES IN SCHEMA public TO snapshooter"
PGUSER=$1 PGPASSWORD=$2 PGDATABASE=$3 PGHOST=$4 PGPORT=$5 SSLMODE=$6 psql -c "GRANT USAGE ON ALL SEQUENCES IN SCHEMA public TO snapshooter"
PGUSER=$1 PGPASSWORD=$2 PGDATABASE=$3 PGHOST=$4 PGPORT=$5 SSLMODE=$6 psql -c "GRANT SELECT ON ALL SEQUENCES IN SCHEMA public TO snapshooter"
PGUSER=$1 PGPASSWORD=$2 PGDATABASE=$3 PGHOST=$4 PGPORT=$5 SSLMODE=$6 psql -c "GRANT USAGE ON SCHEMA sqitch TO snapshooter"
PGUSER=$1 PGPASSWORD=$2 PGDATABASE=$3 PGHOST=$4 PGPORT=$5 SSLMODE=$6 psql -c "GRANT SELECT ON ALL TABLES IN SCHEMA sqitch TO snapshooter"
PGUSER=$1 PGPASSWORD=$2 PGDATABASE=$3 PGHOST=$4 PGPORT=$5 SSLMODE=$6 psql -c "GRANT SELECT ON ALL SEQUENCES IN SCHEMA sqitch TO snapshooter"
PGUSER=$1 PGPASSWORD=$2 PGDATABASE=$3 PGHOST=$4 PGPORT=$5 SSLMODE=$6 psql -c "GRANT SELECT ON sqitch.releases TO snapshooter"
PGUSER=$1 PGPASSWORD=$2 PGDATABASE=$3 PGHOST=$4 PGPORT=$5 SSLMODE=$6 psql -c "GRANT USAGE ON ALL SEQUENCES IN SCHEMA sqitch TO snapshooter"

echo "Application User $9"
materialized_views=$(psql -tqc "select matviewname from pg_catalog.pg_matviews")
tables=$(psql -tqc "SELECT table_name FROM information_schema.tables WHERE table_schema = 'public' AND table_name like '%app_tble_org_usrs%'")
roles=$(psql -tqc "select usename FROM pg_catalog.pg_user where usename ~ '$9_[0-9A-Fa-f]{8}_[0-9A-Fa-f]{4}_[0-9A-Fa-f]{4}_[0-9A-Fa-f]{4}_[0-9A-Fa-f]{12}'")
echo "Queried roles ${roles}"
rolesLen=$(echo "$roles" | wc -w)
if [ "$rolesLen" -gt 1 ]; then
  echo "Expected 1 role got ${roles}"
  exit 1
fi

echo "Processing roles ${roles}"
for role in ${roles}; do
    echo "Granting role ${role} permissions"
    echo "GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO ${role}"
    PGUSER=$1 PGPASSWORD=$2 PGDATABASE=$3 PGHOST=$4 PGPORT=$5 SSLMODE=$6 psql -c "GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO ${role}"

    echo "GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO ${role}"
    PGUSER=$1 PGPASSWORD=$2 PGDATABASE=$3 PGHOST=$4 PGPORT=$5 SSLMODE=$6 psql -c "GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO ${role}"

    echo "ALTER DEFAULT PRIVILEGES FOR USER doadmin IN SCHEMA public GRANT ALL PRIVILEGES ON TABLES TO ${role}"
    PGUSER=$1 PGPASSWORD=$2 PGDATABASE=$3 PGHOST=$4 PGPORT=$5 SSLMODE=$6 psql -c "ALTER DEFAULT PRIVILEGES FOR USER doadmin IN SCHEMA public GRANT ALL PRIVILEGES ON TABLES TO ${role}"

    echo "ALTER DEFAULT PRIVILEGES FOR USER doadmin IN SCHEMA public GRANT USAGE ON SEQUENCES TO ${role}"
    PGUSER=$1 PGPASSWORD=$2 PGDATABASE=$3 PGHOST=$4 PGPORT=$5 SSLMODE=$6 psql -c "ALTER DEFAULT PRIVILEGES FOR USER doadmin IN SCHEMA public GRANT USAGE ON SEQUENCES TO ${role}"

    echo "ALTER DEFAULT PRIVILEGES FOR USER doadmin IN SCHEMA public GRANT ALL PRIVILEGES ON TABLES TO ${role}"
    PGUSER=$1 PGPASSWORD=$2 PGDATABASE=$3 PGHOST=$4 PGPORT=$5 SSLMODE=$6 psql -c "ALTER DEFAULT PRIVILEGES FOR USER ${role} IN SCHEMA public GRANT ALL PRIVILEGES ON TABLES TO snapshooter"

    if [ -n "${materialized_views:-}" ]; then
        for view in ${materialized_views}; do
            echo "Setting ${role} as the owner of the following materialized views: ${view}"
            psql -c "ALTER MATERIALIZED VIEW ${view} OWNER TO ${role};"
        done
    else
        echo "No materialized views found, and that's ok."
    fi

    if [ -n "${tables:-}" ]; then
        for tbl in ${tables}; do
            echo "Setting ${role} as the owner of the following table: ${tbl}"
            psql -c "ALTER TABLE ${tbl} OWNER TO ${role};"
        done
    else
        echo "No tables found, and that's ok."
    fi
done

time=$(date)
echo "::set-output name=time::$time"