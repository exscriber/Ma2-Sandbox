-- NNZ XML parser library for GrandMA2 Lua plugins
--
-- This code is freely distributable under the terms of the [MIT license]
-- Copyright (c) 2022 Nick N. Zinovenko


local _M = { _VERSION = '1.0' }

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

--- Parse GrandMa2 Groups XML File to LUA table {##=id} maintaining selection order
---@param xml string
---@return string[] list
function _M.parseGroupXml(xml)
    local result = {}
    for item in xml:gmatch('<Subfixture(.-)/>') do
        local fix_id = item:match('fix_id="(%d+)"')
                    or item:match('cha_id="(%d+)"')
                    or 'NoID'
        local sub_id = item:match('sub_index="(%d+)"') or "1"

        local id = fix_id .. '.' .. sub_id
        table.insert(result, id)
    end
    return result
end

--- Parse GrandMa2 Preset XML File to LUA table: {id={attribute=value}}
---@param xml string
---@param filter? string[]
---@return table
function _M.parsePresetXml(xml, filter)
    -- narrow XML to Values block, ignoring Fade/Delay/etc... stuff
    -- And limit selection to first XML preset
    xml = xml:match('<Values>(.-)</Values>')

    local result = {}
    for preset, data in xml:gmatch('<PresetValue(.-)>%s*<Channel(.-)/>%s*</PresetValue>') do
        local fix_id = data:match('fixture_id="(%d+)"')
                    or data:match('channel_id="(%d+)"')
                    or 'NoID'
        local sub_id = data:match('subfixture_id="(%d+)"') or "1"

        local id = fix_id .. '.' .. sub_id

        local attribute = data:match('attribute_name="(.-)"')
        if not filter or tableContains(filter, attribute) then
            if not result[id] then
                result[id] = {}
            end
            result[id][attribute] = tonumber(preset:match('Value="(.-)"'))
        end
    end
    return result
end

--- Parse GrandMa2 Patch XML File to LUA table
---@param xml string
---@return table
function _M.parsePatchXml(xml)
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
            local universe = 1 + (address - 1) // 512
            local channel  = 1 + (address - 1) % 512

            result[id] = { universe, channel }
        end
    end
    return result
end

--- Parse GrandMa2 Layout XML File to LUA table
---@param xml string
---@param patch table
---@return table
function _M.parseLayoutXml(xml, patch)
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

---@type table <string, fun(xml: string, filter?: string[])>
_M.XmlParsers = {
    group  = _M.parseGroupXml,
    preset = _M.parsePatchXml
}

return _M
