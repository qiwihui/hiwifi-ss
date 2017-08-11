#!/bin/sh

status() {
	hasfuckedGFW=$(curl -k -I -s --connect-timeout 7 --user-agent "Mozilla/5.0"  https://www.google.com.hk | wc -l)
	if [ $hasfuckedGFW = 0 ]; then
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
