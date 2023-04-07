#!/usr/bin/env python3

import json
import sys
import os

if len(sys.argv) > 1:
    xbar_plugin = sys.argv[1]
else:
    sys.exit(1)

if len(sys.argv) >2:
    xbar_path = os.path.expanduser(sys.argv[2])
else:
    xbar_path = os.path.expanduser("~/Library/Application Support/xbar/plugins")

params_file = os.path.join(xbar_path, [f for f in os.listdir(xbar_path) if f.endswith(".json") and xbar_plugin in f][0])

with open(params_file, "r") as f:
    params = json.loads(f.read())

for p in params:
    print(f'export {p}="{params[p]}"')
