#!/usr/bin/python

# Author: Stephen Leitnick
# Date:   July 22, 2017


import os
import re
import json

filelistName = "filelist.json"

prefix = "https://raw.githubusercontent.com/Sleitnick/AeroGameFramework/master/src/"

rootdir = os.path.join(".", "src")
data = {}
data["url"] = prefix
data["paths"] = []

# Get all files:
for subdir,dirs,files in os.walk(rootdir):
	if (len(files) == 0 and subdir != rootdir and len(dirs) == 0):
		data["paths"].append(subdir[len(rootdir) + 1:].replace("\\", "/") + "/EMPTY")
	for file in files:
		path = os.path.join(subdir, file)[len(rootdir) + 1:].replace("\\", "/")
		data["paths"].append(path)

# Sort and concatenate array:
data["paths"].sort(key=len)
filelistStr = json.dumps(data)

# Write file:
filelist = open(filelistName, "w")
filelist.write(filelistStr)
filelist.close()

print "File list built"