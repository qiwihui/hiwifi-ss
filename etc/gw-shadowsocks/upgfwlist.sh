#!/bin/sh
echo "$(date "+%F %T") GFW-List 更新中.................."

generate_china_banned()
{
	cat /tmp/gfwlist.b64 | base64 -d > /tmp/gfwlist.txt
	rm -f /tmp/gfwlist.b64
	
	cat /tmp/gfwlist.txt | sort -u |
		sed 's#!.\+##; s#|##g; s#@##g; s#http:\/\/##; s#https:\/\/##;' |
		sed '/\*/d; /apple\.com/d; /sina\.cn/d; /sina\.com\.cn/d; /baidu\.com/d; /byr\.cn/d; /jlike\.com/d; /weibo\.com/d; /zhongsou\.com/d; /youdao\.com/d; /sogou\.com/d; /so\.com/d; /soso\.com/d; /aliyun\.com/d; /taobao\.com/d; /jd\.com/d; /qq\.com/d' |
		sed '/^[0-9]\+\.[0-9]\+\.[0-9]\+\.[0-9]\+$/d' |
		grep '^[0-9a-zA-Z\.-]\+$' | grep '\.' | sed 's#^\.\+##' | sort -u |
		awk '
BEGIN { prev = "________"; }  {
	cur = $0;
	if (index(cur, prev) == 1 && substr(cur, 1 + length(prev) ,1) == ".") {
	} else {
		print cur;
		prev = cur;
	}
}' | sort -u

}

curl -k -s -o /tmp/gfwlist.b64 https://raw.githubusercontent.com/gfwlist/gfwlist/master/gfwlist.txt
	if [ -s "/tmp/gfwlist.b64" ]; then
		generate_china_banned > /tmp/ol-gfw.txt && rm -f /tmp/gfwlist.txt
		echo "$(date "+%F %T") gfwlist.b64 下载完成............."
		sort -u /etc/gw-shadowsocks/base-gfwlist.txt /tmp/ol-gfw.txt > /tmp/china-banned
		rm -f /tmp/ol-gfw.txt
		echo "$(date "+%F %T") china-banned 转换完成............"
		if ( ! cmp -s /tmp/china-banned /etc/gw-shadowsocks/china-banned ); then
				echo "$(date "+%F %T") 检测到 GFW-List 有更新..正在更新!"
				mv /tmp/china-banned /etc/gw-shadowsocks/china-banned
				/etc/init.d/gw-shadowsocks restart >/dev/null 2>&1
				echo "$(date "+%F %T") GFW-List 更新并应用.........完成!"
			else
				rm -f /tmp/china-banned
				echo "$(date "+%F %T") GFW-List 本地与在线相同，无需更新!"
				exit 0
		fi
	else
		echo "$(date "+%F %T") 获取在线规则时出错!"
		if [ -f /tmp/gfwlist.b64 ]; then
			rm -f /tmp/gfwlist.b64
		fi
		exit 0
	fi