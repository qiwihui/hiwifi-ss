--
-- test if ss is working
--

local host, port = "www.youtube.com", 443
local socket = require("socket")
local tcp = assert(socket.tcp())
tcp:settimeout(5);
tcp:connect(host, port);
tcp:send("GET / HTTP/1.1\n");
local s, status, partial = tcp:receive()
if status == "closed" then
    io.write('yes')
else
    io.write('no')
end
tcp:close()

