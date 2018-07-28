#!/bin/sh

install(){
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
    if [ ${net_css_in_admin_web} -eq 0 ]; then
        sed -i "s!admin_web\/net\.css!net\.css!g" /usr/lib/lua/luci/view/admin_web/prometheus/index.htm
    fi

    # echo -n '==> 添加到手机版后台...'
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
    sleep 1

    echo '==> 清理临时文件...'
    if test -e /var/run/luci-indexcache; then
        rm /var/run/luci-indexcache && echo 'Done! 清理完成 ' && echo '';
    else
        echo 'luci-cache does not exist! 无法找到luci-cache,请确定是否是极路由环境' && echo ''
    fi
    rm -rf /tmp/geewan
}

uninstall(){
    opkg remove geewan-ss
}

# 检查运行状态
status() {
    local stat="running"

    pgrep ss-local >/dev/null 2>&1

    if [ $? -ne 0 ];then
        stat="stopped"
    fi

    echo "{ \"status\" : \"$stat\" }"
    return $?
}