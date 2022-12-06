FROM postgres:13.9-alpine
COPY init-db.sh /docker-entrypoint-initdb.d/
