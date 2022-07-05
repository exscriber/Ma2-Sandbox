-- NNZ Position to Offset plugin
--
-- This code is freely distributable under the terms of the [MIT license]
-- Copyright (c) 2022 Nick N. Zinovenko


local utils = require 'nnz.utils'
local pprint = require 'pl.pretty'.dump
local print = gma.echo

local obj = gma.show.getobj
local prop = gma.show.propety

local function impl(cfg, cmd)
    print('cmd: ' .. tostring(cmd))

    local data = utils.getFixtureData('Fixture 101')
    pprint(data)


    -- local handle = obj.handle('Group 1')
    -- print(obj.class(handle) .. ': ' .. handle)
    -- print('children: ' .. obj.amount(handle))
    -- for idx = 0, obj.amount(handle) do
    --     local child = obj.child(handle, idx)
    --     -- print('   ' .. obj.class(child) .. ': ' .. child)
    -- end

    -- utils.printTable(utils.attrFilter.Pos)
    -- utils.printTable(_G)
    -- utils.printTable(debug.getinfo(gma.draw.getperformance,"SLnltuf"))

    -- utils.printTable(_G["gma"])
    -- utils.printObject('Seq 1')
    -- utils.printObject('Fixture 101')

    -- utils.printObject(228626432,1,true)


    -- utils.printObject(262180864,1,true)
    -- utils.printObject(   369098752)
    -- utils.printObject(67109830, 1, true)

    -- gma.export('2.txt', tmp)
    -- local tbl = gma.import('2.txt') or {}

    -- utils.printTable(tbl,1)

    -- local result = gma.textinput ("Update from Programmer to Preset #", cfg.ref_preset)
    -- if result then print(result) end
end

return impl
