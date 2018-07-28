#!/bin/sh /etc/rc.common
# Copyright (C) 2007-2011 OpenWrt.org

START=99

export SERVICE_DAEMONIZE=1
export SERVICE_WRITE_PID=1

start() {
	local server
	local server_port
	local local_port
	local password
	local timeout
	local method
	local enable
	local plugin_enable
	local plugin_opts
    local dnsserver
    local udp_relay
	local params
	local kcptun_enable
	local kcptun_opts
	local section='shadowsocks'

	config_load 'shadowsocks'

	config_get enable "$section" 'enable'
	if [ "$enable" == "1" ]
	then
		config_get server "$section" 'server'
		config_get server_port "$section" 'server_port'
		config_get local_port "$section" 'local_port'
		config_get password "$section" 'password'
		config_get timeout "$section" 'timeout'
		config_get method "$section" 'method'
		config_get dnsserver "$section" 'dnsserver'
		# 3088
		config_get rs_port "$section" 'rs_port'
		# udp 转发
		config_get udp_relay "$section" 'udp_relay'
        # 混淆
		config_get plugin_enable "$section" 'plugin_enable'
		config_get plugin "$section" 'plugin'
		config_get plugin_opts "$section" 'plugin_opts'
		# kcptun
		config_get kcptun_enable "$section" 'kcptun_enable'
		config_get kcptun_opts "$section" 'kcptun_opts'

        params=''

        if [ "$plugin_enable" == '1' ]; then
            params="$params --plugin $plugin --plugin-opts $plugin_opts"
        fi
		if [ "$timeout" == "" ]; then
		    timeout=300
		fi
		if [ "$udp_relay" == "1" ]; then
		    params="$params -u"
		fi

        service_start /usr/bin/ss-local -s $server -p $server_port -b 0.0.0.0 -l $local_port -k $password -t $timeout -m $method $params
        service_start /usr/bin/ss-redir -s $server -p $server_port -b 0.0.0.0 -l $rs_port -k $password -t $timeout -m $method $params
        #/etc/init.d/dnscrypt-proxy start
		
		if [ "$kcptun_enable" == '1' ]; then
			kcp_params="-l :$server_port -r $server$kcptun_opts"
			service_start /usr/bin/kcptun $kcp_params > /var/log/kcptun_ss.log
		fi
		
		service_start /usr/bin/dns2socks 127.0.0.1:$local_port $dnsserver 127.0.0.1:53535 -d -q
		/etc/init.d/gw-redsocks start
	fi
}

stop() {
	/etc/init.d/gw-redsocks stop
    #/etc/init.d/dnscrypt-proxy stop
	
	service_stop /usr/bin/dns2socks
	service_stop /usr/bin/ss-local
	service_stop /usr/bin/ss-redir
	service_stop /usr/bin/kcptun
}

restart() {
   stop
   start
}
