FROM osgeo/gdal:latest AS asgsra

RUN apt-get update \
 && apt-get install -y postgis

RUN wget --trust-server-names "https://www.abs.gov.au/ausstats/subscriber.nsf/log?openagent&1270055005_ra_2016_aust_gpkg.zip&1270.0.55.005&Data%20Cubes&904192D3B43F6B0ACA258251000C8855&0&July%202016&16.03.2018&Latest" \
 && unzip 1270055005_ra_2016_aust_gpkg.zip

RUN touch asgsra.sql

RUN chown postgres:postgres ASGS\ 2016\ RA.gpkg \
 && chown postgres:postgres asgsra.sql

USER postgres

RUN /etc/init.d/postgresql start \
 && psql --command "CREATE USER asgsra WITH SUPERUSER PASSWORD 'asgsra';" \
 && createdb -O asgsra asgsra \
 && psql asgsra --command "CREATE EXTENSION postgis;" \
 && ogr2ogr -f PostgreSQL "PG:dbname=asgsra" ASGS\ 2016\ RA.gpkg \
 && pg_dump asgsra -O -x >> asgsra.sql

###

FROM postgis/postgis

ENV TZ=Australia/Melbourne
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime \
 && echo $TZ > /etc/timezone \
 && dpkg-reconfigure -f noninteractive tzdata

COPY postgresql.conf /etc/postgresql
COPY 0_init.sh /docker-entrypoint-initdb.d
COPY --from=asgsra /asgsra.sql asgsra.sql

RUN chown postgres:postgres /etc/postgresql/postgresql.conf \
 && chown postgres:postgres /docker-entrypoint-initdb.d/0_init.sh \
 && chown postgres:postgres /asgsra.sql

CMD ["postgres", "-c", "config_file=/etc/postgresql/postgresql.conf"]