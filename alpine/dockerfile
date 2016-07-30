FROM alpine-jre-8
MAINTAINER <christophe.gattardi@gmail.com>

COPY jobscheduler_install.xml /tmp

# Image update
RUN apk update

#Pre-requisites
RUN apk add postgresql-client

# osjs install
RUN cd /tmp && wget -q http://192.168.99.1/osjs/jobscheduler_linux-x64.1.9.11.tar.gz && tar xzf /tmp/jobscheduler_linux-x64.1.9.11.tar.gz -C /tmp && /tmp/jobscheduler.1.9.11/setup.sh /tmp/jobscheduler_install.xml && rm -fr /tmp/jobscheduler.1.9.11 /tmp/jobscheduler_install.xml

COPY start_js.sh /opt/sos-berlin.com/jobscheduler/osjs_4444/bin
RUN chmod 755 /opt/sos-berlin.com/jobscheduler/osjs_4444/bin/start_js.sh

EXPOSE 4444

# ENTRYPOINT ["/opt/sos-berlin.com/jobscheduler/osjs_4444/bin/start_js.sh"]
