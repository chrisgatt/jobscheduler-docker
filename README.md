# This image run opensource jobscheduler (http://www.sos-berlin.com)

## Build

The provided dockerfile allow you to specify the osjs version via the JSVER and the JSURL environment variables. The JSURL is the "base" URL without the .tar.gz file name.
You can use both an Oracle JRE or an OpenJdk you just need to change the lines beetween the tag "put your JRE stuff here" and "end JRE". 

## Dependencies

this image need a postgres database to run. You can use any avalaible postgres image, but I tested with the official 9.5

## Example run commads:

### postgres pour OSJS

docker run -d --name osjsdb -p 5432 \
	   -e POSTGRES_PASSWORD=manager \
	   -v osjs_pgdata:/var/lib/postgresql/data \
	   postgres


### OSJS server

docker run -d --link osjsdb \
	   --name osjs_server \
	   -p 4444:4444 \
	   -v osjs_data:/home/user/sos-berlin.com/jobscheduler \
	   -e PG_ADMIN_PASSWD=manager -e PG_SCHED_PASSWD=scheduler \
	   osjsserv

