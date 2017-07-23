#!/usr/bin/python

# Author: Stephen Leitnick
# Date:   July 22, 2017


import os
import re
import json

filelistName = "filelist.json"

prefix = "https://raw.githubusercontent.com/Sleitnick/AeroGameFramework/master/src/"
emptyDirSuffix = "EMPTY"

rootdir = os.path.join(".", "src")
data = {}
data["url"] = prefix
data["paths"] = []


def fix_path(path):
	return path[len(rootdir) + 1:].replace("\\", "/")


# Get all files:
def get_all_files():
	for subdir,dirs,files in os.walk(rootdir):
		if (len(files) == 0 and subdir != rootdir and len(dirs) == 0):
			data["paths"].append(fix_path(rootdir) + "/" + emptyDirSuffix)
		for file in files:
			path = fix_path(os.path.join(subdir, file))
			data["paths"].append(path)


def write_to_filelist_file():

	# Sort and concatenate array:
	data["paths"].sort(key=len)
	filelistStr = json.dumps(data, indent=4)

	# Write file:
	filelist = open(filelistName, "w")
	filelist.write(filelistStr)
	filelist.close()


def build():
	get_all_files()
	write_to_filelist_file()


build()
print "File list built"
