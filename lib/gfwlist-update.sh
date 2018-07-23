#!/bin/sh

SUCCESS=0

doDownload(){
    cd /etc/gw-shadowsocks/
    echo "gfwlist2dnsmasq.sh is downloading..."
    curl -s -o gfwlist2dnsmasq.sh https://raw.githubusercontent.com/cokebar/gfwlist2dnsmasq/master/gfwlist2dnsmasq.sh
    if [ $? != 0 ]; then
        SUCCESS=0
        exit 1
    fi
    echo "gfwlist2dnsmasq.sh had been downloaded."
}

doUpdate(){
    cd /etc/gw-shadowsocks
    echo "gw-shadowsocks.dnslist is updating..."
    if [ -f "/etc/gw-shadowsocks/gw-shadowsocks.dnslist" ]; then
        mv gw-shadowsocks.dnslist gw-shadowsocks.dnslist_bkp
        echo "gw-shadowsocks.dnslist backup successfully."

        rm -rf gw-shadowsocks.dnslist
        /etc/gw-shadowsocks/gfwlist2dnsmasq.sh -i --port 53535 -o gw-shadowsocks.dnslist
        SUCCESS=1
        # Todo Check if the previous list if the same as the new one
    else
        /etc/gw-shadowsocks/gfwlist2dnsmasq.sh -i --port 53535 -o gw-shadowsocks.dnslist
        SUCCESS=1
    fi
}

if [ -f "/etc/gw-shadowsocks/gfwlist2dnsmasq.sh" ]; then
    doUpdate
else
    echo "gfwlist2dnsmasq.sh can't be found."
    doDownload
    doUpdate
fi

if [ ${SUCCESS} -eq "1" ]; then
    echo -n "success"
else
    echo -n "failed"
fi
