--
-- test if ss is working
--

local log = require "luci.log"
local host, port = "www.youtube.com", 443
local socket = require("socket")
local tcp = assert(socket.tcp())
tcp:settimeout(2);
tcp:connect(host, port);
tcp:send("GET / HTTP/1.1\n");
local s, status, partial = tcp:receive()
if status == "closed" then
    io.write('yes')
    log.print('Connection Succeeded')
else
    io.write('no')
    if output == 'running' then
        log.print('Connection Failed')
        -- reload ss
        log.print('Reload Shadowsocks')
        luci.sys.exec('/etc/init.d/gw-shadowsocks restart')
    end
end
tcp:close()

