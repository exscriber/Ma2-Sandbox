-- GrandMA2 Layout to CSV convertor
--
-- This code is freely distributable under the terms of the [MIT license]
-- Copyright (c) 2022 Nick N. Zinovenko

--[[Bundle]]

local utils = require 'pl.utils'
local template = require 'pl.template'
-- local pprint = require 'pl.pretty'.debug


local function readPatchXML(filename)
    local xml = utils.readfile(filename) ---@type string|nil

    local result = {}
    for fix_attr, fix_data in xml:gmatch('<Fixture(.-)>(.-)</Fixture>') do
        for sub_attr, sub_data in fix_data:gmatch('<SubFixture(.-)>(.-)</SubFixture>') do
            -- id string '123.45' need 1 base correction in patch.xml
            local fix_id = fix_attr:match('fixture_id="(%d+)"')
                        or fix_attr:match('channel_id="(%d+)"')
            local sub_id = sub_attr:match('index="(%d+)"') or 0
            local id = fix_id .. '.' .. sub_id + 1

            -- Universe and Channel from absolute address
            local address  = sub_data:match('<Address>(%d+)</Address>')
            local universe = 1+ (address-1) // 512
            local channel  = 1+ (address-1) %  512

            result[id] = { universe, channel }
        end
    end
    return result
end


local function readLayoutXML(filename, patch)
    local xml = utils.readfile(filename) ---@type string|nil

    local result = {}
    for attr, data in xml:gmatch('<LayoutSubFix(.-)>(.-)</LayoutSubFix>') do
        -- id string '123.45' already 1 based in layout.xml
        local fix_id = data:match('fix_id="(%d+)"')
                    or data:match('cha_id="(%d+)"')
        local sub_id = data:match('sub_index="(%d+)"') or 1
        local id = fix_id .. '.' .. sub_id

        local universe, channel
        local address = patch[id]
        if address then
            universe, channel = table.unpack(address)
        else goto continue end -- no patch for item - next please...

        if not result[universe] then
            result[universe] = {}
        end

        local item = {}
        for k,v in attr:gmatch('([%w_]-)="(.-)"') do
            item[k] = v
        end

        table.insert(result[universe], {
            id   = id,
            addr = { u = universe, c = channel },
            pos  = { x = item.center_x, y = item.center_y },
            size = { w = item.size_w, h = item.size_h },
        })
    ::continue::
    end
    return result
end


-- if __name__ == '__main__'
if not debug.getinfo(3) then
    local parser = require 'argparse' ()
    parser:argument('patch_file', 'MA2 patch xml file')
    parser:argument('layout_file', 'MA2 layout xml file')
    local args = parser:parse()

    local patch  = readPatchXML(args.patch_file)
    local layout = readLayoutXML(args.layout_file, patch)

    local csv = template.compile(
        "{id},\t{addr.u},{addr.c},\t{pos.x}, {pos.y},\t{size.w}, {size.h}",
        { inline_escape = '', inline_brackets = '{}' })

    for universe, items in ipairs(layout) do
        print('Universe: ' .. universe)
        for _, item in ipairs(items) do
            print(tostring(csv:render(item)))
        end
    end
end
