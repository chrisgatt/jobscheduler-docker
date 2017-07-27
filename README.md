# Opensource jobscheduler (http://www.sos-berlin.com) in docker

 - run jobscheduler as a standalone server
 - run jobscheduler main process in foreground as PID 1 of the container
 - require a postgres database to run

## Content

 - centos directory: a centos based image to run jobscheduler. The provided dockerfile use:
   - java openjdk 8
   - jobscheduler 1.9.11
   - latest centos version
   - after install some files are patched to allow to start jobscheduler in foreground as PID 1 of the container
 - test directory: sample jobscheduler jobs to test the image

## Build

The provided dockerfile allow you to specify the ojs version via the JSVER and the JSURL environment variables.
The JSURL is the "base" URL without the <jobscheduler*>.tar.gz file name (see dockerfile for example).
You can use both an Oracle JRE or an OpenJdk you just need to change the lines beetween the tag "put your JRE stuff here" and "end JRE".
In case of change in JSVER you have to provide a compatible "jobscheduler_install" xml file.

## Dependencies

this image need a postgres database to run. You can use any avalaible postgres image, but I tested with the latest official version which is 9.6.3 at the time being.

## Environnement variables

  - PG_HOST: hostname of the db server (default: osjsdb)
  - PG_SCHEDULER_DB: name of the jobscheduler database (default: scheduler)
  - PG_SCHEDULER_USER: name of the user to connect to the db (default: scheduler)
  - PG_SCHEDULER_PASSWD: password of the user to connect to the db (no default)
  - PG_ADMIN_PASSWD: password of the administrator of the db (no default)
  - SCHEDULER_ID: jobscheduler id (default: osjs_4444)
  - SCHEDULER_HOST: jobscheduler host name (not so usefull in container context) (default: osjs)
  - SCHEDULER_ALLOWED_HOST: ip range allowed to connect to the scheduler (default: 0.0.0.0 all ip allowed)

The container is designed to reconfigure ojs at each startup to reflect change in the context (change of database server name for example).

## Example run commads:

### postgres pour OSJS
```bash
docker run -d --name osjsdb -p 5432 \
	   -e POSTGRES_PASSWORD=manager \
	   -v osjs_pgdata:/var/lib/postgresql/data \
	   postgres
```

### OSJS server
```bash
docker run -d --link osjsdb \
	   --name osjs_server \
	   -p 4444:4444 \
	   -v osjs_data:/home/user/sos-berlin.com/jobscheduler \
	   -v osjs_logs:/var/log/sos-berlin.com \
	   -e PG_ADMIN_PASSWD=manager -e PG_SCHEDULER_PASSWD=scheduler \
	   -e SCHEDULER_ALLOWED_HOST=127.0.0.1 \
	    chrisgatt/jobscheduler-docker
```
