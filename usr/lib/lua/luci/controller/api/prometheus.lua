--
-- Created by qiwihui
-- User: qiwihui
-- Date: 2/18/17
--

module("luci.controller.api.prometheus", package.seeall)

function index()

    local page   = node("api","prometheus")
    page.target  = firstchild()
    page.title   = ("")
    page.order   = 600
    page.sysauth = "admin"
    page.sysauth_authenticator = "jsonauth"
    page.index = true

    -- get_version 获取版本
    entry({ "api", "prometheus", "get_ss_version" }, call("get_ss_version"), _(""), 601)
    -- get_ss_cfg  获取 ss 配置
    entry({ "api", "prometheus", "get_ss_cfg" }, call("get_ss_cfg"), _(""), 602)
    -- set_ss_cfg  保存 ss 配置
    entry({ "api", "prometheus", "set_ss_cfg" }, call("set_ss_cfg"), _(""), 603)
    -- set_ss_switch  开关
    entry({ "api", "prometheus", "set_ss_switch" }, call("set_ss_switch"), _(""), 604)
    -- shutdown_ss  关闭
    entry({ "api", "prometheus", "shutdown_ss" }, call("shutdown_ss"), _(""), 605)
    -- start_ss  开启
    entry({ "api", "prometheus", "start_ss" }, call("start_ss"), _(""), 606)
    -- get_ss_status  获取 ss 状态
    entry({ "api", "prometheus", "get_ss_status" }, call("get_ss_status"), _(""), 607)
    --   升级
    entry({ "api", "prometheus", "check_ss_updates" }, call("check_ss_updates"), _(""), 608)
    entry({ "api", "prometheus", "upgrade_ss" }, call("upgrade_ss"), _(""), 608)
end


local luci_http = require("luci.http")
local VERSION = 'v1.0.6'
--local log = require "luci.log"

function json_return(content)
    luci_http.prepare_content("application/json")
	luci_http.write_json(content, true)
end


function check_ss_updates()
    local latest_version = luci.sys.exec('curl -k https://api.github.com/repos/qiwihui/hiwifi-ss/releases/latest -s | grep "tag_name" | awk "{ print $2 }" | sed s/\"//g | sed s/,//g')
    if VERSION ~= latest_version then
        result["code"] = 0
        result["has_updates"] = 1
        result["latest_version"] = latest_version
        json_return(result)
    else
        result["code"] = 0
        result["has_updates"] = 0
        result["latest_version"] = latest_version
        json_return(result)
    end
end

function upgrade_ss()
    luci.sys.exec("cd /tmp && curl -k -o shadow.sh https://raw.githubusercontent.com/qiwihui/hiwifi-ss/master/shadow.sh && sh shadow.sh && rm shadow.sh")
    -- todo check if upgraded?
    result['code'] = 0
	result['version'] = "success"
	json_return(result)
end

function get_ss_version()
    -- ss 版本
	local result = {}
	result['code'] = 0
	result['version'] = VERSION
	json_return(result)
end

function get_ss_cfg()
    -- 获取 shadowsocks 配置
    local cursor = require "luci.model.uci".cursor()
    local config = cursor.get_all("shadowsocks", "shadowsocks");
    local result = {}
    result['enable'] = config['enable'] or '0'
    result['server'] = config['server'] or ''
    result['server_port'] = config['server_port'] or ''
    result['local_port'] = config['local_port'] or '61080'
    result['password'] = config['password'] or ''
    result['timeout'] = config['timeout'] or '300'
    result['method'] = config['method'] or 'aes-256-cfb'
    result['defaultroute'] = config['defaultroute'] or '0'
    result['dnsserver'] = config['dnsserver'] or '8.8.4.4'
    result['udp_relay'] = config['udp_relay'] or '0'

    result['plugin_opts'] = config['plugin_opts'] or 'obfs=http;obfs-host=www.bing.com'
    result['plugin_enable'] = config['plugin_enable'] or '0'

    result["code"] = 0
    json_return(result)
end

function set_ss_cfg()
    -- 保存 shadowsocks 配置
    -- local enable = luci.http.formvalue("enable")
    local server = luci.http.formvalue("server")
    local server_port = luci.http.formvalue("server_port")
    -- local local_port = luci.http.formvalue("local_port") -- local_port 61080
    local password = luci.http.formvalue("password")
    local timeout = luci.http.formvalue("timeout")
    local method = luci.http.formvalue("method")
    local defaultroute = luci.http.formvalue("defaultroute")
    local dnsserver = luci.http.formvalue("dnsserver")
    local udp_relay = luci.http.formvalue("udp_relay")
    -- simple obfs switch
    local plugin_enable = luci.http.formvalue("plugin_enable")
--    local plugin = luci.http.formvalue("plugin")
    local plugin_opts = luci.http.formvalue("plugin_opts")

    -- 查看是否有 shadowsocks 的配置，有则修改，无则创建
    local has_config = luci.sys.exec("test -f /etc/config/shadowsocks && echo -n 'yes' || echo -n 'no'")
    if has_config == 'no' then
        luci.sys.exec('touch /etc/config/shadowsocks')
        luci.sys.exec('uci set shadowsocks.shadowsocks=ssproxy;')
        luci.sys.exec('uci set shadowsocks.shadowsocks.enable="0";')
        luci.sys.exec('uci set shadowsocks.shadowsocks.local_port="61080";')
        luci.sys.exec('uci set shadowsocks.shadowsocks.rs_port=3088;')
        -- default obfs config
        luci.sys.exec('uci set shadowsocks.shadowsocks.plugin_enable="0";')
    end

    luci.sys.exec('uci set shadowsocks.shadowsocks.server='..server..';')
    luci.sys.exec('uci set shadowsocks.shadowsocks.server_port='..server_port..';')
    luci.sys.exec('uci set shadowsocks.shadowsocks.password='..password..';')
    luci.sys.exec('uci set shadowsocks.shadowsocks.method='..method..';')
    luci.sys.exec('uci set shadowsocks.shadowsocks.defaultroute='..defaultroute..';')
    luci.sys.exec('uci set shadowsocks.shadowsocks.dnsserver='..dnsserver..';')
    luci.sys.exec('uci set shadowsocks.shadowsocks.timeout='..timeout..';')
    luci.sys.exec('uci set shadowsocks.shadowsocks.udp_relay='..udp_relay..';')
    -- simple obfs
    luci.sys.exec('uci set shadowsocks.shadowsocks.plugin_enable='..plugin_enable..';')
    luci.sys.exec('uci set shadowsocks.shadowsocks.plugin="obfs-local";')
    luci.sys.exec('uci set shadowsocks.shadowsocks.plugin_opts=\"'..plugin_opts..'\";')
    luci.sys.exec('uci commit;')

    -- reload ss
    luci.sys.exec('/etc/init.d/gw-shadowsocks restart')

    local result = {}
    local codeResp = 0
    result["code"] = codeResp
    result["msg"] = luci.util.get_api_error(codeResp)
    json_return(result)
end

function shutdown_ss()
    -- stop ss
    luci.sys.exec('/etc/init.d/gw-shadowsocks stop')
end

function start_ss()
    -- start
    luci.sys.exec('/etc/init.d/gw-shadowsocks start')
end

function set_ss_switch()
    -- 关闭/开启 ss
    local enable = luci.http.formvalue("enable")
    -- log.print(enable)
    luci.sys.exec('uci set shadowsocks.shadowsocks.enable='..enable..';')
    luci.sys.exec('uci commit;')
    if enable == '1' then
        start_ss()
    else
        shutdown_ss()
    end
    local codeResp = 0
    local result = {}
    result['code'] = codeResp
    result['msg'] = luci.util.get_api_error(codeResp)
    result['enable'] = enable
    json_return(result)
end

function get_ss_status()
    -- 获取 shadowsocks 的运行状态
    local result = {}
    -- ss 运行状态
    local output = luci.sys.exec('/lib/gw-shadowsocks.sh status')
    local accel = 'no'
    if output == 'running' then
        -- 是否能访问 youtube
        accel = luci.sys.exec('lua /lib/ss-test.lua')
    end
    local codeResp = 0
    result['code'] = codeResp
    result['msg'] = luci.util.get_api_error(codeResp)
    result['accel'] = accel
    result['status'] = output
    json_return(result)
end

function prometheus_upgrade()
end
