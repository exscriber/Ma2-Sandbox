-- NNZ Position to Offset plugin
--
-- This code is freely distributable under the terms of the [MIT license]
-- Copyright (c) 2022 Nick N. Zinovenko


-- User defined settings
local cfg = {
    ref_preset = '2.3', -- Reference preset:  known good preset (eg from previs software)
    cal_preset = '2.4', -- Calibrated preset: copy of reference with real world adjustments
    temp_group = '2.6', -- Temporary group:   fixture selection stored here
}

--[[Bundle]]

-- Dev Environment
package.path = package.path .. ';C:/Users/Nikolay/Code/Ma2-Sandbox/src/?.lua;C:/Users/Nikolay/Code/Ma2-Sandbox/lib/?.lua'

if gma then
    local print = gma.echo

    local internal_name = select(1, ...)
    local visible_name  = select(2, ...)
    print(internal_name .. ' loading...')
end

-- Plugin entry point
local function Start(cmd)
    require('plugin-pos2offset.impl')(cfg, cmd)
end

-- Plugin finalizer
local function Cleanup()
end

return Start, Cleanup
