#!/bin/sh

curl -k -s http://ftp.apnic.net/apnic/stats/apnic/delegated-apnic-latest \
	| awk -F\| '/CN\|ipv4/ { printf("%s/%d\n", $4, 32-log($5)/log(2)) }' >> /tmp/china.ipset

	if [ -s "/tmp/china.ipset" ]; then
		if ( ! cmp -s /tmp/china.ipset /etc/ipset.d/china.ipset ); then
			echo "$(date "+%F %T") 检测到 china 有更新...正在更新!"
			mv /tmp/china.ipset /etc/ipset.d/china.ipset
			/etc/init.d/ipset restart >/dev/null 2>&1
			echo "$(date "+%F %T") china 更新并应用..........完成!"
		else
			rm -f /tmp/china.ipset
			echo "$(date "+%F %T") china......已经是最新,无需更新!"
			exit 0
		fi
	else
		echo "$(date "+%F %T") 获取在线规则时出错,请检查网络!"
		if [ -f /tmp/china.ipset ]; then
			rm -f /tmp/china.ipset
		fi
		exit 0
	fi