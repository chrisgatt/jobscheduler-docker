#!/bin/bash

export PGHOST=${PG_HOST:-osjsdb}
export PG_SCHEDULER_DB=${PG_SCHEDULER_DB:-scheduler}
export PG_SCHEDULER_USER=${PG_SCHEDULER_USER:-scheduler}

if [[ -z "$PG_SCHEDULER_PASSWD" ]]; then
	echo "Error: variable 'PG_SCHEDULER_PASSWD' not set. Exiting..." >&2
	exit 1
fi

# Remove old configurations if exists
if [[ -d /home/user/sos-berlin.com/jobscheduler/osjs_4444 ]]; then
	cd /home/user/sos-berlin.com/jobscheduler/osjs_4444
	rm -f ./bin/jobscheduler_environment_variables.sh
	rm -f ./config/{scheduler.xml,jetty.xml,web.xml,sos.ini,factory.ini}
fi

# Update response file
cp /app/jobscheduler_install.$JSVER.xml /tmp/jobscheduler_install.xml
sed -i \
	-e "s/{{PGHOST}}/$PGHOST/g" \
	-e "s/{{PG_SCHEDULER_USER}}/$PG_SCHEDULER_USER/g" \
	-e "s/{{PG_SCHEDULER_PASSWD}}/$PG_SCHEDULER_PASSWD/g" \
	-e "s/{{PG_SCHEDULER_DB}}/$PG_SCHEDULER_DB/g" \
	/tmp/jobscheduler_install.xml

# Install jobscheduler
/app/setup.sh /tmp/jobscheduler_install.xml || exit $?

# Patch files
cd /opt/sos-berlin.com/jobscheduler/osjs_4444/bin
patch jobscheduler.sh /app/jobscheduler.sh.patch
patch jobscheduler_environment_variables.sh /app/jobscheduler_environment_variables.sh.patch

echo "====================================================================="

if [[ $(basename "$1") == "jobscheduler.sh" ]]; then
	# Check database connectivity
	export PGPASSWORD="$PG_ADMIN_PASSWD"

	echo "Checking database connectivity to postgres database at $PGHOST"
	max_attempts=20
	for a in $(seq 0 $max_attempts); do
		sleep $a
		psql -U postgres -d postgres -w -c 'select 1' >/dev/null && break
	done

	[[ $a -ge $max_attempts ]] && exit 1

	# Check database existence
	export PGPASSWORD="$PG_SCHEDULER_PASSWD"
	psql -U $PG_SCHEDULER_USER -d $PG_SCHEDULER_DB -w -c 'select 1' &>/dev/null

	# Init database if necessary
	if [[ $? -ne 0 ]]; then
		echo "Creating '$PG_SCHEDULER_DB' database..."
		export PGPASSWORD=$PG_ADMIN_PASSWD
		set -e
		psql -U postgres -w <<EOF
create database $PG_SCHEDULER_DB;
create role $PG_SCHEDULER_USER with login password '$PG_SCHEDULER_PASSWD';
GRANT ALL PRIVILEGES ON DATABASE $PG_SCHEDULER_DB TO $PG_SCHEDULER_USER;
alter user $PG_SCHEDULER_USER set standard_conforming_strings = off;
alter user $PG_SCHEDULER_USER set bytea_output = 'escape';
EOF
		/opt/sos-berlin.com/jobscheduler/osjs_4444/install/scheduler_install_tables.sh
	fi
fi

exec "$@"
