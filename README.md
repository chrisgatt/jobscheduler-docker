# Opensource jobscheduler (http://www.sos-berlin.com) in docker

 - run jobscheduler as a standalone server
 - run jobscheduler main process in foreground as PID 1 of the container
 - require a postgres database to run

## Content

 - alpine directory: a try to run jobscheduler on alpine-jre-8 (alpine 3.2 java 8u92 and glibc 2.21). At this time jobscheduler don't start and segfault
 - centos directory: a centos 7 based image to run jobscheduler. The provided dockerfile use:
   - java openjdk 8
   - jobscheduler 1.9.11
   - after install some files are patched to allow to start jobscheduler in foreground as PID 1 of the container
   - the directory "genPatch" contain both native and docker patched files to manually generate the patch file used to build the container
 - test directory: sample jobscheduler jobs to test the image

## Build

The provided dockerfile allow you to specify the ojs version via the JSVER and the JSURL environment variables.
The JSURL is the "base" URL without the <jobscheduler*>.tar.gz file name (see dockerfile for example).
You can use both an Oracle JRE or an OpenJdk you just need to change the lines beetween the tag "put your JRE stuff here" and "end JRE".



## Dependencies

this image need a postgres database to run. You can use any avalaible postgres image, but I tested with the official 9.5

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
	   osjsserv
```
