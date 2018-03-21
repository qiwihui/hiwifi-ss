#!/bin/sh
#
echo 'Go!'
echo '==> 创建临时目录 /tmp/geewan'
mkdir -p /tmp/geewan
cd /tmp/geewan
echo 'Done! 成功创建临时目录!'
echo ''
echo '==> 下载插件...'

curl -k https://raw.githubusercontent.com/qiwihui/hiwifi-ss/master/hiwifi-ss.tar.gz -o hiwifi-ss.tar.gz
echo 'Done! 下载完成'
echo ''
sleep 2
echo -n "==> 备份系统文件...."

if [ -f /usr/lib/lua/luci/view/admin_web/menu/menu_left.htm.ssbak ]; then
    echo -e "...[\e[31m备份已存在\e[0m]"
else
    cp -a /usr/lib/lua/luci/view/admin_web/menu/menu_left.htm /usr/lib/lua/luci/view/admin_web/menu/menu_left.htm.ssbak
    echo -e "....[\e[32m备份完成\e[0m]"
fi
echo ''
echo -n '==> 安装插件...'
tar xzvf hiwifi-ss.tar.gz -C / >>/dev/null
# 兼容 1.2.5.15805s 等版本用的 v2/style/net.css，而 1.4.8.20462s 用的是 v2/style/admin_web/net.css
net_css_in_admin_web=`grep "admin_web/net\.css" /usr/lib/lua/luci/view/admin_web/network/index.htm | wc -l`
if [ $net_css_in_admin_web -eq 0 ]; then
    sed -i "s/admin_web\/net\.css/net\.css/g" /usr/lib/lua/luci/view/admin_web/prometheus/index.htm
fi

# 添加到手机版后台
cd /usr/lib/lua/luci/view/admin_mobile
cp home.htm home.htm.ssbak
mobile_router_control_line_num=`grep -n "mobile_router_control" home.htm | cut -d : -f 1`
ul_end_relative_line_num=`tail -n +$mobile_router_control_line_num home.htm | grep -n -m 1 "/ul" | cut -d : -f 1`
ul_end_line_num=`expr $mobile_router_control_line_num + $ul_end_relative_line_num - 1`
ul_end_line_num_sub_1=`expr $ul_end_line_num - 1`
head -n $ul_end_line_num_sub_1 home.htm > new_home.htm
echo '<li> <a href="<%=luci.dispatcher.build_url('\''admin_web'\'','\''prometheus'\'')%>" target="_blank">安全上网<span class="right-bar"><em class="enter-pointer"></em></span></a> </li>' >> new_home.htm
tail -n +$ul_end_line_num home.htm >> new_home.htm
mv new_home.htm home.htm
cd /tmp/geewan
echo -e '...[\e[32m安装成功\e[0m]'

echo ''
sleep 2
echo '==> 添加卸载信息...'
echo '' >>/usr/lib/opkg/status
echo 'Package: geewan-ss' >>/usr/lib/opkg/status
echo 'Version: master-20130924-eb9d31869e1d7590cd8c2fb1e7d226ac6cf32fad-20141024' >>/usr/lib/opkg/status
echo 'Provides:' >>/usr/lib/opkg/status
echo 'Status: install hold installed' >>/usr/lib/opkg/status
echo 'Architecture: ralink' >>/usr/lib/opkg/status
echo 'Installed-Time: 1422509506' >>/usr/lib/opkg/status
echo 'Auto-Installed: yes' >>/usr/lib/opkg/status
echo '' >>/usr/lib/opkg/status
echo ''
echo '==> 清理临时文件...'
if test -e /var/run/luci-indexcache; then
    rm /var/run/luci-indexcache && echo 'Done! 清理完成 ' && echo '';
else
    echo 'luci-cache does not exist! 无法找到luci-cache,请确定是否是极路由环境' && echo ''
fi
rm -rf /tmp/geewan
sleep 2
echo ''
echo '插件成功安装!'
echo '1987年9月14日21时07分'
echo '中国第一封电子邮件'
echo '从北京发往德国'
echo '越过长城，走向世界'
echo 'Done! Hello World! 一切就绪,你好世界!'
