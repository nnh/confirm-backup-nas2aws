#!/usr/bin/env python
import sys
import os

dirs = sys.argv[1::] if len(sys.argv) > 1 else ["./"]

for dir in dirs:
    for r, d, f in os.walk(dir):
        counter = 0
        for file in f:
            path = os.path.join(r, file);
            if os.path.islink(path):
                print(path + '\t' + os.readlink(path))
            else:
                print(path + '\t' + str(os.path.getsize(path)))
