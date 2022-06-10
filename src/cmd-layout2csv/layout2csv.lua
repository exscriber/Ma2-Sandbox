-- GrandMA2 Layout to CSV convertor
--
-- This code is freely distributable under the terms of the [MIT license]
-- Copyright (c) 2022 Nick N. Zinovenko

--[[Bundle]]

local utils = require 'pl.utils'
local template = require 'pl.template'
-- local pprint = require 'pl.pretty'.debug


local function parsePatchXML(filename)
    local xml = utils.readfile(filename)

    local result = {}
    for fix_id, fix_data in xml:gmatch('<Fixture.-fixture_id="(%d+)".->(.-)</Fixture>') do
        for sub_id, sub_data in fix_data:gmatch('<SubFixture.-index="(%d+)".->(.-)</SubFixture>') do
            local address = sub_data:match('<Address>(%d+)</Address>')

            local id = fix_id .. '.' .. sub_id + 1 -- id string 123.45 with 1 base correction
            result[id] = address + 512 -- absolute address with 1 base correction
        end
    end
    return result
end

local function parseLayoutXML(filename, patch)
    local xml = utils.readfile(filename)

    local result = {}
    for item, fixture in xml:gmatch('<LayoutSubFix (.-)>(.-)</LayoutSubFix>') do

        -- #id string 123.45 already 1 based
        local fix_id = fixture:match('fix_id="(%d+)')
        local sub_id = fixture:match('sub_index="(%d+)"')
        local id = fix_id .. '.' .. sub_id

        -- Universe and Channel from absolute address
        local address  = patch[id]
        local universe = address // 512
        local channel  = address % 512

        if not result[universe] then
            result[universe] = {}
        end

        local attrib = {}
        for k, v in item:gmatch('([%w_]-)="(.-)"') do
            attrib[k] = v
        end

        table.insert(result[universe], {
            id   = id,
            addr = { u = universe, c = channel },
            pos  = { x = attrib.center_x, y = attrib.center_y },
            size = { w = attrib.size_w, h = attrib.size_h },
        })
    end
    return result
end

-- if __name__ == '__main__'
if not debug.getinfo(3) then
    local parser = require 'argparse' ()
    parser:argument('patch_file', 'MA2 patch xml file')
    parser:argument('layout_file', 'MA2 layout xml file')
    local args = parser:parse()

    local patch  = parsePatchXML(args.patch_file)
    local layout = parseLayoutXML(args.layout_file, patch)

    local csv = template.compile(
        "{id},\t{addr.u},{addr.c},\t{pos.x}, {pos.y},\t{size.w}, {size.h}",
        { inline_escape = '', inline_brackets = '{}' })

    for _, universe in ipairs(layout) do
        for _, item in ipairs(universe) do
            print(tostring(csv:render(item)))
        end
    end
end
