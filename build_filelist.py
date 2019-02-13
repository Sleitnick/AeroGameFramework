#!/usr/bin/python

# Author: Stephen Leitnick
# Date:   February 12, 2019

import os
import json

FILELIST_NAME = "filelist.json"
FILELIST_MIN_NAME = "filelist.min.json"
FILELIST_INDENT = 2

FETCH_PREFIX = "https://raw.githubusercontent.com/Sleitnick/AeroGameFramework/master/"
ROOT_DIR = os.path.join(".", "src")

def path_to_dictionary(path):
	d = {
		"name": os.path.basename(path),
		"type": "file"
	}
	if os.path.isdir(path):
		d["type"] = "directory"
		d["children"] = [path_to_dictionary(os.path.join(path, p)) for p in os.listdir(path)]
	return d

def write_json_to_file(filename, json_obj, indent):
	with open(filename, "w") as f:
		json.dump(json_obj, f, indent=FILELIST_INDENT if indent else None)

def build():
	data = {
		"url": FETCH_PREFIX,
		"paths": path_to_dictionary(ROOT_DIR)
	}
	write_json_to_file(FILELIST_NAME, data, True)
	write_json_to_file(FILELIST_MIN_NAME, data, False)

if __name__ == "__main__":
	print("Building file list...")
	build()
	print("File list built")