#!/bin/sh

SUCCESS=0
logFile='/var/log/gfwlist-update.log'
logTime=`date "+%Y-%m-%d %H:%M:%S"`

if [ ! -f ${logFile} ]; then
    touch ${logFile}
fi

doDownload(){
    cd /etc/gw-shadowsocks/
    curl -s -o gfwlist2dnsmasq.sh https://raw.githubusercontent.com/cokebar/gfwlist2dnsmasq/master/gfwlist2dnsmasq.sh
    if [ $? != 0 ]; then
        echo -e "[ERROR] gfwlist2dnsmasq.sh download failed." >> ${logFile}
        exit 1
    fi
}

doUpdate(){
    cd /etc/gw-shadowsocks
    if [ -f "/etc/gw-shadowsocks/gw-shadowsocks.dnslist" ]; then
        mv gw-shadowsocks.dnslist gw-shadowsocks.dnslist_bkp

        rm -rf gw-shadowsocks.dnslist
    fi
    # Todo Check if the previous list if the same as the new one
    doGenerate
}

doGenerate(){
    chmod +x /etc/gw-shadowsocks/gfwlist2dnsmasq.sh
    /etc/gw-shadowsocks/gfwlist2dnsmasq.sh -i --port 53535 -o gw-shadowsocks.dnslist>/dev/null 2>&1
    if [ $? != 0 ]; then
        echo -e "[ERROR] ${logTime} gw-shadowsocks.dnslist update failed." >> ${logFile}
    else
        echo -e "[INFO] ${logTime} gw-shadowsocks.dnslist update successfully." >> ${logFile}
        SUCCESS=1
    fi
}

if [ -f "/etc/gw-shadowsocks/gfwlist2dnsmasq.sh" ]; then
    doUpdate
else
    doDownload
    doUpdate
fi

if [ ${SUCCESS} -eq "1" ]; then
    echo -n "success"
else
    echo -n "failed"
fi
