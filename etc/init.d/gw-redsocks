#!/bin/sh /etc/rc.common

#START=80
APP=gw_redsocks
PID_FILE=/var/run/$APP.pid

#export SERVICE_DAEMONIZE=1
#export SERVICE_WRITE_PID=1

appname=gw-shadowsocks
appdir=/etc/$appname

# 要翻墙解析的域名
addr_list=/etc/gw-shadowsocks/addr_list.conf
# 局域网使用ss的策略，可填 mac或ip
lan_list=/etc/gw-shadowsocks/lan_list.conf
# 自定义访问外网策略
wan_list=/etc/gw-shadowsocks/wan_list.conf
# 自定义策略可以填写域名或ip，域名会自动解析成ip
# 根据前缀来进行区分：
#
# @开头的 域名 使用 代理中转
# !开头的 域名 忽略 代理中转
# +开头的 IP网段/掩码 使用 代理
# -开头的 IP网段/掩码 忽略 代理

rs_getconfig() {
	lan_ip=$(uci get network.lan.ipaddr)
	source /lib/functions/network.sh
	network_get_ipaddr wanip wan
	local_ip=127.0.0.1

	rs_port_tcp=$(uci get shadowsocks.shadowsocks.rs_port)
	mode=$(uci get shadowsocks.shadowsocks.defaultroute)
	server_ip=$(uci get shadowsocks.shadowsocks.server)
}

rs_iptables_add() {
	echo -n > /dev/null
	iptables -t nat -N $appname 
	iptables -t nat -A PREROUTING -i br-lan -j $appname
	iptables -t nat -A OUTPUT -j $appname
	iptables -t nat -A $appname -m salist --salist local --match-dip -j RETURN 
	iptables -t nat -A $appname -m salist --salist hiwifi --match-dip -j RETURN 
	iptables -t nat -A $appname -d $lan_ip/24 -j RETURN
	iptables -t nat -A $appname -d $wanip/24 -j RETURN
	iptables -t nat -A $appname -d $server_ip/32 -j RETURN

	if [ ! -f "/tmp/ss_spec_lan.txt" ]; then
		# mac地址 禁用ss
		while read line
		do
			if [ ! -z "$linemac" ] ; then
				mac=$(echo $line | sed s/://g| sed s/：//g | tr '[a-z]' '[A-Z]')
				mac="${mac:0:2}:${mac:2:2}:${mac:4:2}:${mac:6:2}:${mac:8:2}:${mac:10:2}"
				if [ ! -z "$mac" ] ; then
					iptables -t nat -I $appname -m mac --mac-source $mac -j RETURN
				fi
			fi
		done <　/tmp/ss_spec_lan.txt
	fi

	# 翻墙地址，域名或ip
	iptables -t nat -A $appname -m set --match-set ss_white dst -j DNAT --to-destination $lan_ip:$rs_port_tcp
	# 不翻墙地址，域名或ip
	iptables -t nat -A $appname -m set --match-set ss_black dst -j RETURN

	[ "$mode" != "1" ] && {
		iptables -t nat -A $appname -m salist --salist china --match-dip -j RETURN
	}
	
    iptables -t nat -A $appname -p tcp -j DNAT --to-destination $lan_ip:$rs_port_tcp
}

rs_iptables_del() {
	echo -n > /dev/null
	iptables -t nat -D PREROUTING -i br-lan -j $appname
	iptables -t nat -D OUTPUT -j $appname
	iptables -t nat -F $appname
	iptables -t nat -X $appname
}

rs_getconfig

# 创建ipset
ipset -! create ss_white hash:net hashsize 64
ipset -! create ss_black hash:net hashsize 64

rs_ipset() {

	if [ ! -f "$wan_list" ]; then
		echo \# null > $wan_list
	fi
	if [ ! -f "$lan_list" ]; then
		echo \# null > $lan_list
	fi
	if [ ! -f "$addr_list" ]; then
		echo \# null> $addr_list
	fi

	grep -v '^#' $wan_list | sort -u | grep -v "^$" | sed s/！/!/g > /tmp/ss_spec_wan.txt
	grep -v '^#' $lan_list | sort -u > /tmp/ss_spec_lan.txt
	grep -v '^#' $addr_list | sort -u > /tmp/ss_addr.list
	rm -f /tmp/ss_wantoss.list
	rm -f /tmp/ss_wannoss.list

	while read line
	do
		# @开头的 域名 使用 代理中转
		del_line=`echo $line |grep "@"`
		if [ ! -z "$del_line" ] ; then
			del_line=`echo $del_line | sed s/WAN@//g`
			# 解析域名为ip地址
			/usr/bin/resolveip -4 -t 4 $del_line | grep -v :  > /tmp/ss_tmp.list
			[ ! -s /tmp/ss_tmp.list ] && arNslookup $del_line | sort -u | grep -v "^$"  >> /tmp/ss_wantoss.list
			[ -s /tmp/ss_tmp.list ] && cat /tmp/ss_tmp.list| sort -u | grep -v "^$" >> /tmp/ss_wantoss.list && echo "" > /tmp/ss_tmp.list
		fi

		# !开头的 域名 忽略 代理中转
		add_line=`echo $line |grep "!"`
		if [ ! -z "$add_line" ] ; then
			add_line=`echo $add_line | sed s/!//g` 
			# 解析域名为ip地址
			/usr/bin/resolveip -4 -t 4 $add_line | grep -v :  > /tmp/ss_tmp.list
			[ ! -s /tmp/ss_tmp.list ] && arNslookup $add_line | sort -u | grep -v "^$"  >> /tmp/ss_wannoss.list
			[ -s /tmp/ss_tmp.list ] && cat /tmp/ss_tmp.list| sort -u | grep -v "^$" >> /tmp/ss_wannoss.list && echo "" > /tmp/ss_tmp.list
		fi

		# +开头的 IP网段/掩码 使用 代理
		net_line=`echo $line |grep "+"`
		if [ ! -z "$net_line" ] ; then
			net_line=`echo $net_line | sed s/AN+//g` 
			echo $net_line  >> /tmp/ss_wantoss.list
		fi

		# -开头的 IP网段/掩码 忽略 代理
		net_line=`echo $line |grep "-"`
		if [ ! -z "$net_line" ] ; then
			net_line=`echo $net_line | sed s/-//g` 
			echo $net_line  >> /tmp/ss_wannoss.list
		fi
	done < /tmp/ss_spec_wan.txt
	rm /tmp/ss_spec_wan.txt

	# 从过滤后的文件中检测符合 点，筛选出ip
	grep "\." /tmp/ss_spec_lan.txt >> /tmp/ss_wantoss.list
	grep -v "\." /tmp/ss_spec_lan.txt >> /tmp/ss_spec_lan.txt

	# 加载telegram网段
	cat >> "/tmp/ss_wantoss.list" <<-\TELEGRAM
91.108.56.0/22
91.108.4.0/22
109.239.140.0/24
149.154.160.0/20
TELEGRAM

	# 清空原先的ipset内容
	ipset flush ss_white
	ipset flush ss_black

	# 更新进ipset
	if [ -s "/tmp/ss_wannoss.list" ] ; then
		sed -e "s/^/-A ss_black &/g" -e "1 i\-N ss_black hash:net " /tmp/ss_wannoss.list | ipset -R -!
	fi
	# if [ -s "/tmp/ss_addr.list" ] ; then
	# 	sed -e "s/^/-A ss_white &/g" -e "1 i\-N ss_white hash:net " /tmp/ss_addr.list | ipset -R -!
	# fi
	if [ -s "/tmp/ss_wantoss.list" ] ; then
		sed -e "s/^/-A ss_white &/g" -e "1 i\-N ss_white hash:net " /tmp/ss_wantoss.list | ipset -R -!
	fi
}

start() {
	rs_ipset
	rs_iptables_add

    echo > /tmp/dnsmasq.d/$appname.usr.dnslist
	echo >> /tmp/ss_addr.list
	if [ ! -f "/tmp/ss_addr.list" ] ; then
		while read line
		do
			if [ ! -z "$line" ] ; then
				echo "server=/$line/127.0.0.1#53535" >> /tmp/dnsmasq.d/$appname.usr.dnslist
			fi
		done < /tmp/ss_addr.list
	fi

	cp $appdir/$appname.dnslist /tmp/dnsmasq.d/
	[ "$mode" == "1" ] && {
        cat >> /tmp/dnsmasq.d/$appname.dnslist << EOF
no-resolv
server=127.0.0.1#53535
EOF
    }

	/etc/init.d/dnsmasq restart
}

stop() {
	rs_iptables_del
	
	rm /tmp/dnsmasq.d/$appname.dnslist
    rm /tmp/dnsmasq.d/$appname.usr.dnslist
	/etc/init.d/dnsmasq restart
}

restart() {
   stop
   start
}
