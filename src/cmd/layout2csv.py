# GrandMA2 Layout to CSV convertor
# 
# This code is freely distributable under the terms of the [MIT license]
# Copyright (c) 2022 Nick N. Zinovenko

from xml.etree import ElementTree
# from pprint import pprint

# MA2 namespace prefix for XML parser
MA2 = { '': 'http://schemas.malighting.de/grandma2/xml/MA' }

# Types
FixId = str
Address = tuple[int,int]
UniverseId = int
LayoutItem = dict


def readPatchXML (filename) -> dict[FixId, Address]:
    xml = ElementTree.parse(filename)

    result = {}
    for fixture in xml.iterfind('.//Fixture', MA2):
        for subfixt in fixture.iterfind('SubFixture', MA2):
            # id string '123.45' need 1 base correction in patch.xml
            fix_id = fixture.get('fixture_id') or fixture.get('channel_id')
            sub_id = subfixt.get('index', '0') # 0 based
            id = f'{fix_id}.{int(sub_id) +1}'

            # Universe and Channel from absolute address
            address  = int( subfixt.find('*Address', MA2).text )
            universe = 1+ (address-1) // 512
            channel  = 1+ (address-1) %  512

            result[id] = (universe, channel)
    return result


def readLayoutXML (filename, patch: dict[FixId, Address] ) -> dict[UniverseId,list[LayoutItem]]:
    xml = ElementTree.parse(filename)

    result = {}
    for item in xml.iterfind('.//LayoutSubFix', MA2):
        if (fixture := item.find('Subfixture', MA2)) is not None:
            # id string '123.45' already 1 based in layout.xml
            fix_id = fixture.get('fix_id') or fixture.get('cha_id')
            sub_id = fixture.get('sub_index', '1') # 1 based
            id = f'{fix_id}.{sub_id}'

            if address := patch.get(id):
                universe, channel = address
            else: continue # no patch for item - next please...

            if universe not in result:
                result[universe] = []

            result[universe].append({
                'id':   id,
                'addr': { 'u': universe, 'c':  channel, },
                'pos':  { 'x': item.get('center_x'), 'y': item.get('center_y') },
                'size': { 'w': item.get('size_w'),   'h': item.get('size_h') },
            })
    return result


if __name__ == '__main__':
    from argparse import ArgumentParser

    parser = ArgumentParser()
    parser.add_argument('patch_file',  help='MA2 patch xml file')
    parser.add_argument('layout_file', help='MA2 layout xml file')
    args = parser.parse_args()

    patch  = readPatchXML( args.patch_file )
    layout = readLayoutXML( args.layout_file, patch )

    csv = "{id},\t{addr[u]},{addr[c]},\t{pos[x]}, {pos[y]},\t{size[w]}, {size[h]}"

    for universe,items in layout.items():
        print (f'Universe: {universe}')
        for item in items:
            print (csv.format(**item))
