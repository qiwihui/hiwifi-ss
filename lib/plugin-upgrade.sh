#!/bin/sh

check() {
    latest_version=`/usr/bin/curl -k https://api.github.com/repos/qiwihui/hiwifi-ss/releases/latest -s | grep 'tag_name' | awk '{ print $2 }' | sed s/\"//g | sed s/,//g`
    if [ `echo $?` == 1 ]
    then
        echo -n "Can't check the latest version."
    else
        echo -n "$latest_version"
    fi
}

upgrade() {
    doUpgrade=`cd /tmp && curl -k -o shadow.sh https://raw.githubusercontent.com/qiwihui/hiwifi-ss/master/shadow.sh && sh shadow.sh && rm shadow.sh`
    if [ `echo $?` == 1 ]
    then
        echo -n "1"
    else
        echo -n "0"
    fi
}

case "$1" in
    check)
        check
        ;;
    upgrade)
        upgrade
        ;;
esac
