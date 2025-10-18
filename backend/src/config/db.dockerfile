FROM mysql:9.4.0

COPY ./schema.sql /docker-entrypoint-initdb.d/