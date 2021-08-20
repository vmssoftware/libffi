import sys
import os
import re
import _decc

if len(sys.argv) < 2:
    print("Input file required")
    exit()

print("Input is {}".format(sys.argv[1]))

unix_names = _decc.from_vms(sys.argv[1])
if len(unix_names) != 1:
    print("Cannot resolve vms name, got {}".format(unix_names))
    exit()

unix_name = unix_names[0]
pre, ext = os.path.splitext(unix_name)
new_unix_name = pre + ".asm"

print("Output is {}".format(new_unix_name))

with open(unix_name) as fi, open(new_unix_name, "w") as fo:
    for l in fi.readlines():
        l = re.sub("\.\s+L(\S+)", ".L\g<1>", l)
        l = re.sub("L(\S+)\s+@\s+rel", "L\g<1>@rel", l)
        l = re.sub("\.\s+balign", ".balign", l)
        l = re.sub("\.\s+byte", ".byte", l)
        fo.write(l)
