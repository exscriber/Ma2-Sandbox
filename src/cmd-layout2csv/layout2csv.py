# GrandMA2 Layout to CSV convertor
# 
# This code is freely distributable under the terms of the [MIT license]
# Copyright (c) 2022 Nick N. Zinovenko

from xml.etree import ElementTree
from pprint import pprint

# MA2 namespace prefix for XML parser
MA2 = { '': 'http://schemas.malighting.de/grandma2/xml/MA' }


def parsePatchXML (filename):
    xml = ElementTree.parse(filename)

    result = {}
    for fixture in xml.iterfind('.//Fixture', MA2):
        for subfixture in fixture.iterfind('SubFixture', MA2):
            fix_id  = int( fixture.get('fixture_id') )
            sub_id  = int( subfixture.get('index') )
            address = int( subfixture.find('*Address', MA2).text )

            id = f'{fix_id}.{sub_id +1}'    # id string 123.45 with 1 base correction
            result[id] = address +512       # absolute address with 1 base correction
    return result


def parseLayoutXML (filename, patch):
    xml = ElementTree.parse(filename)

    result = {}
    for item in xml.iterfind('.//LayoutSubFix', MA2):        
        if (fixture := item.find('Subfixture', MA2)) is not None:

            #id string 123.45 already 1 based
            id = '{fix_id}.{sub_index}'.format(**fixture.attrib)

            # Universe and Channel from absolute address
            address  = patch[id]        
            universe = address // 512
            channel  = address % 512

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

    patch  = parsePatchXML( args.patch_file )
    layout = parseLayoutXML( args.layout_file, patch )

    csv = "{id},\t{addr[u]},{addr[c]},\t{pos[x]}, {pos[y]},\t{size[w]}, {size[h]}"
    
    for universe in layout.values():
        for item in universe:
            print (csv.format(**item))
