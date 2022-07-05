-- GrandMA2 Layout to CSV convertor
--
-- This code is freely distributable under the terms of the [MIT license]
-- Copyright (c) 2022 Nick N. Zinovenko

--[[Bundle]]

local utils = require 'pl.utils'
local template = require 'pl.template'
local Ma2Parser = require 'nnz.parser'

-- if __name__ == '__main__'
if not debug.getinfo(3) then
    local argparse = require 'argparse' ()
    argparse:argument('patch_file', 'MA2 patch xml file')
    argparse:argument('layout_file', 'MA2 layout xml file')
    local args = argparse:parse()

    local patch  = Ma2Parser.parsePatchXml(utils.readfile(args.patch_file))
    local layout = Ma2Parser.parseLayoutXml(utils.readfile(args.layout_file), patch)

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
