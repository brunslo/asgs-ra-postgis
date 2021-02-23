# ASGS-RA Postgis
This is a simple postgis wrapper for the Australian Statistical Geography Standard Remoteness Area (ASGS-RA) geopackage. The steps in the Dockerfile will download the most current version of the geopackage (1270.0.55.005 at the time of writing) and convert it to a postgres database with the postgis extension enabled, before finally wrapping it all up into a working Docker image.
