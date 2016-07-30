#!/bin/bash

# database existence check and init if necessary
export PGPASSWORD=$PG_PASSWD
psql -h osjsdb -U scheduler <<EOF
\q
EOF

if [ $? -ne 0 ]
then
	echo Creating database

	psql -h osjsdb -U postgres <<EOF
create database scheduler;
create role scheduler with login password 'scheduler';
GRANT ALL PRIVILEGES ON DATABASE scheduler TO scheduler;
alter user scheduler set standard_conforming_strings = off;
alter user scheduler set bytea_output = 'escape';
EOF

	if [ $? -ne 0 ]
	then
		exit $?
	fi

	/opt/sos-berlin.com/jobscheduler/osjs_4444/install/scheduler_install_tables.sh
fi

# Osjs engine launch
exec /opt/sos-berlin.com/jobscheduler/osjs_4444/bin/jobscheduler.sh execfg
