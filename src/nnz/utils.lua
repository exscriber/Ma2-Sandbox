-- NNZ utility library for GrandMA2 Lua plugins
--
-- This code is freely distributable under the terms of the [MIT license]
-- Copyright (c) 2022 Nick N. Zinovenko


if not gma then error('Suppose to run only as GrandMa plugin') end

local _M = { _VERSION = '1.0' }

local print = gma.echo or print
local obj = gma.show.getobj
local prop = gma.show.property

local gma_path = {
    base   = gma.show.getvar('path'),
    plugin = gma.show.getvar('pluginpath'),
    temp   = gma.show.getvar('temppath'),
}

local _cnt = 1
---Monotonic counter
---@return integer
local function counter()
    _cnt = _cnt + 1
    return _cnt
end

_M.attrPreset = {
    [0] = 'ALL', 'DIM', 'POSITION', 'GOBO', 'COLOR', 'BEAM', 'FOCUS', 'CONTROL', 'SHAPERS', 'VIDEO' }

_M.attrFilter = {
    Dim = { 'DIM' },
    Pos = { 'PAN', 'TILT' },
    Col = { 'COLORRGB1', 'COLORRGB2', 'COLORRGB3', 'COLORRGB4', 'COLORRGB5' },
}

function _M.readfile(filename)
    local file, err = io.open(filename, 'r')
    if file then
        local data = file:read("*all")
        file:close()
        return data
    else
        error(err)
    end
end

local function tableContains(table, item)
    for _, v in pairs(table) do
        if v == item then
            return true
        end
    end
    return false
end

local function getTableKeys(table)
    local result = {}
    for k, _ in pairs(table) do
        result[#result + 1] = k
    end
    return result
end

local function computePresetDelta(first, second)
    local result = {}
    for id, data1 in pairs(first) do
        for attr, value1 in pairs(data1) do
            local value2 = second[id][attr]
            if value2 then -- ensure preset2 have value to compare with
                if not result[id] then
                    result[id] = {}
                end
                result[id][attr] = value2 - value1
            end
        end
    end
    return result
end

--- Utility: print GrandMa2 property
---@param handle integer
---@param indent? integer
function _M.printProperty(handle, indent)
    indent = indent or 0
    local pad = string.rep('  ', indent)

    for i = 0, prop.amount(handle) do
        if prop.name(handle, i) == nil then break end

        local name = prop.name(handle, i) or ''
        local value = prop.get(handle, i) or ''
        print(pad .. '[' .. name .. ']: ' .. value)
    end
end

--- Utility: print GrandMa2 object
---@param handle integer | string
---@param indent? integer
---@param with_props? boolean
---@param recursive? boolean
---@param filter? string[]
function _M.printObject(handle, indent, with_props, recursive, filter)
    indent = indent or 0
    local pad = string.rep('  ', indent)

    if type(handle) == 'string' then
        handle = obj.handle(handle)
    end

    print(pad .. (obj.class(handle) or '') .. ": " .. handle)
    print(pad .. "[parent]: " .. (obj.parent(handle) or '-- root --'))
    print(pad .. "[index] : " .. obj.index(handle))
    print(pad .. "[number]: " .. obj.number(handle))
    print(pad .. "[name]  : " .. obj.name(handle))
    print(pad .. "[label] : " .. (obj.label(handle) or '-- nil --'))

    print(pad .. "[props] : " .. prop.amount(handle))
    if with_props then
        _M.printProperty(handle, indent + 1)
    end

    print(pad .. "[childs]: " .. obj.amount(handle))
    if recursive then
        for i = 1, obj.amount(handle) do
            _M.printObject(obj.child(handle, i), indent + 1, with_props, recursive, filter)
        end
    end
end

--- Utility: print table contents
-- TODO: implement __tostring()
---@param table table
---@param indent? integer
---@param recursive? boolean
function _M.printTable(table, indent, recursive)
    indent = indent or 0
    recursive = recursive or true
    local pad = string.rep('  ', indent);

    for k, v in pairs(table) do
        if v ~= table then
            if type(v) == "string" or type(v) == "number" then
                print(pad .. "[" .. k .. "]=" .. v)
            elseif type(v) == "boolean" then
                print(pad .. "[" .. k .. "]=" .. tostring(v))
            elseif type(v) == "table" then
                print(pad .. "[" .. k .. "]:")
                if recursive then
                    _M.pprint(v, indent + 1, recursive)
                end
            else
                print(pad .. "[" .. k .. "]=(" .. type(v) .. ")")
            end
        end
    end
end

--- Get Fixture data from Ma2 into Lua table
---@param id string | integer
---@return table | nil
function _M.getFixtureData(id)
    local fix_handle = obj.handle(id)

    if obj.class(fix_handle) ~= 'CMD_FIXTURE' then return end
    local sub_handle = obj.child(fix_handle, 0) -- Fixture have only #0 child: 'CMD_SUBFIXTURE'

    local result = {
        id     = fix_handle,
        name   = obj.name(fix_handle),
        cmd_id = obj.number(fix_handle),
        fix_id = prop.get(fix_handle, 'FixId'),
        cha_id = prop.get(fix_handle, 'ChaId'),

        offset = {
            pan_off  = tonumber(prop.get(sub_handle, 'Pan|Offset')),
            tilt_off = tonumber(prop.get(sub_handle, 'Tilt|Offset')),
        },
        invert = {
            swap_pt  = prop.get(sub_handle, 'Swap') == 'On',
            dmx_pan  = prop.get(sub_handle, 'PanDMX|Invert') == 'On',
            dmx_tilt = prop.get(sub_handle, 'TiltDMX|Invert') == 'On',
            enc_pan  = prop.get(sub_handle, 'PanEnc.Invert') == 'On',
            enc_tilt = prop.get(sub_handle, 'TiltEnc.Invert') == 'On',
        },
        stage = {
            pos_x = tonumber(prop.get(sub_handle, 'Pos|X')),
            pos_y = tonumber(prop.get(sub_handle, 'Pos|Y')),
            pos_z = tonumber(prop.get(sub_handle, 'Pos|Z')),
            rot_x = tonumber(prop.get(sub_handle, 'Rot|X')),
            rot_y = tonumber(prop.get(sub_handle, 'Rot|Y')),
            rot_z = tonumber(prop.get(sub_handle, 'Rot|Z')),
        },
    }
    return result
end

--- Get Ma2 Pool Item into Lua table
--- via tempory Xml file because Ma2 API sucks
---@param type string      -- eg 'Group', 'Preset', 'Macro', etc..
---@param id string        -- eg '2.222'
---@param filter? string[] -- eg {'PAN', 'TILT'} - for Position values only
---@return table
function _M.getPoolItem(type, id, filter)
    local XmlParsers = require 'nnz.parser'.XmlParsers
    type = type:lower() -- convert to lowercase for compare

    local result = {}
    if XmlParsers[type] then
        local itemname = type .. ' ' .. id
        local filename = 'tmp-' .. type .. '-' .. counter()
        local fullname = gma_path.base .. '/importexport/' .. filename .. '.xml'

        gma.cmd('SelectDrive 1') -- change to internal disk, otherway we can`t load xml from lua side
        gma.cmd('Export /o /nc ' .. itemname .. ' "' .. filename .. '"')

        local xml = _M.readfile(fullname)
        -- os.remove(fullname) -- FIXME: remove temp file after use (uncomment after debug)

        result = XmlParsers[type](xml, filter)
    end

    return result
end

return _M
