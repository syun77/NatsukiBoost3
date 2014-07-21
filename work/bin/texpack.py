#!/usr/bin/python
# -*- coding: utf-8 -*-

import sys
import json
import yaml

def usage():
	print "Usage: # python texpack.py [infile] [outfile]"

def main(args):
	if len(args) <= 2:
		usage()
		return

	infile = args[1]
	outfile = args[2]
	print infile
	print outfile

	fIn = open(infile, "r")
	data = yaml.load(fIn)
	fIn.close
	frames = []
	for k in sorted(data["data"].keys()):
		texture = {}
		texture["filename"] = k
		v = data["data"][k]
		vals = v["frame"].split(",")
		frame = {}
		frame["x"] = int(vals[0])
		frame["y"] = int(vals[1])
		frame["w"] = int(vals[2])
		frame["h"] = int(vals[3])
		frame["rotated"] = False
		frame["trimmed"] = True
		texture["frame"] = frame
		spriteSourceSize = {}
		spriteSourceSize["x"] = 0
		spriteSourceSize["y"] = 0
		spriteSourceSize["w"] = frame["w"]
		spriteSourceSize["h"] = frame["h"]
		texture["spriteSourceSize"] = spriteSourceSize
		sourceSize = {}
		sourceSize["w"] = frame["w"]
		sourceSize["h"] = frame["h"]
		texture["sourceSize"] = sourceSize
		frames.append(texture)

	root = {}
	root["frames"] = frames

	header = data["header"]
	meta = {
		"app" : "http://www.texturepacker.com",
		"version" : "1.0",
		"images" : header["image"],
		"format" : "RGBA8888",
		"size" : {
			"w" : header["width"],
			"h" : header["height"]
		},
		"scale" : "1",
		"smartupdate": "$TexturePacker:SmartUpdate:7eff078e0be7ed90edad7bbef671fa5e$"
	}
	root["meta"] = meta

	out = json.dumps(root)
	fOut = open(outfile, "w")
	fOut.write(out)
	fOut.close


if __name__ == '__main__':
	main(sys.argv)
	# args = ["", "player.txt", "player.json"]
	main(args)
