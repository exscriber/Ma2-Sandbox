-- NNZ Videohub plugin
--
-- This code is freely distributable under the terms of the [MIT license]
-- Copyright (c) 2022 Nick N. Zinovenko


-- User defined settings
local cfg = {
    host = '127.0.0.1', -- Videohub IP address
    port = 9990,        -- Videohub port
    timeout = 1,        -- Timeout in seconds
    verbose = true,     -- Print verbose info
}

local socket = require('socket.core')

-- Plugin Init
do
    local internal_name = select(1, ...)
    local visible_name  = select(2, ...)
    gma.echo(internal_name .. ' loading...')
end

-- Plugin Entry point
local function Start(cmd)
    if not cmd then
        gma.feedback('Usage: Plugin Videohub "output input"')
        return
    end

    local conn = assert(
        socket.connect(cfg.host, cfg.port))
    conn:settimeout(cfg.timeout)

    if cfg.verbose then
        gma.feedback('Videohub command: XPT ' .. cmd)
    end

    local data = "VIDEO OUTPUT ROUTING:\r\n" .. cmd .. "\r\n\r\n"
    conn:send(data)
    conn:close()
end

-- Plugin Finalizer
local function Cleanup()
end

return Start, Cleanup
