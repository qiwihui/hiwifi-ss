--
-- Created by qiwihui
-- User: qiwihui
-- Date: 2/18/17
--

module("luci.controller.prometheus.shadowsocks", package.seeall)

function index()
	-- entry for proemtheus
	entry({"admin_web", "prometheus"}, firstchild(), _(""), 700)
	entry({"admin_web", "prometheus", "shadowsocks"}, template("admin_web/prometheus/index"), _("shadowsocks"), 700, true)
end