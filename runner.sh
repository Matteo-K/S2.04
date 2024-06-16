PGDATA=data
PGUSER=postgres

mkdir -p /run/postgresql/

# initialize PostgreSQL database cluster
initdb -D $PGDATA -U $PGUSER >/dev/null 2>&1
sed -i 's/#listen_addresses/listen_addresses/' $PGDATA/postgresql.conf

# shut down server
pg_ctl -D $PGDATA stop >/dev/null 2>&1

# start database server
pg_ctl -D $PGDATA -l logfile start >/dev/null 2>&1

# start psql
psql --quiet -U $PGUSER -f create.sql
psql -U $PGUSER -f populate.sql
psql -U $PGUSER
