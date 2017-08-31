#!/bin/sh

status() {
	if [ `killall -0 ss-local >/dev/null 2>&1; echo $?` == 1 ]
	then
		echo -n "stopped"
	else
		echo -n "running"
	fi
}

case "$1" in
	status)
		status
		;;
esac