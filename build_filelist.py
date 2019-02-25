#!/usr/bin/python

# Author: Stephen Leitnick
# Date:   February 12, 2019

from json import dump
from subprocess import check_output

FILELIST_NAME = "filelist.json"
FILELIST_MIN_NAME = "filelist.min.json"
FILELIST_INDENT = 2

FETCH_PREFIX = "https://raw.githubusercontent.com/Sleitnick/AeroGameFramework/master/"

def write_json_to_file(filename, json_obj, indent):
	with open(filename, "w") as f:
		dump(json_obj, f, indent=FILELIST_INDENT if indent else None)

# Find dictionary with the same name within the given array:
def find(ar, name):
	a = [x for x in ar if x["name"] == name]
	if len(a) > 0:
		return a[0]
	else:
		return None

if __name__ == "__main__":
	
	print("Building file list...")

	paths_data = []
	all_files = check_output(["git", "ls-tree", "--name-only", "-r", "master", "src"])
	paths = all_files.split("\n")
	for path in paths:
		path_array = path.split("/")
		current = paths_data
		for p in path_array:
			item = find(current, p)
			if not item:
				is_file = p.endswith(".lua")
				item = {
					"type": "file" if is_file else "directory",
					"name": p
				}
				if not is_file:
					item["children"] = []
				current.append(item)
			if item["type"] == "directory":
				current = item["children"]
	
	filelist_data = {
		"url": FETCH_PREFIX,
		"paths": paths_data[0]
	}

	write_json_to_file(FILELIST_NAME, filelist_data, True)
	write_json_to_file(FILELIST_MIN_NAME, filelist_data, False)

	print("File list built")