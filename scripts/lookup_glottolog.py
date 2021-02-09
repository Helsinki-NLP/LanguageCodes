import sys

from langinfo.glottolog import Glottolog


import sys

for line in sys.stdin:
    values = line.rstrip().split("\t")
    print(line.rstrip(), end = "\t")
    if len(values) > 1:
        try:
            langgroup = Glottolog[values[1].split(" ")[0]]
            for lang in langgroup.descendants(
                    lambda l: l.level == 'language' and l.iso639_3):
                print(lang.iso639_3, end=' ')
        except KeyError:
            print('Unknown language ID ' + values[1], file=sys.stderr)
    print("")

