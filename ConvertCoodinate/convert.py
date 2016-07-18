# -*- coding: utf-8 -*-
from coordTransform_utils import bd09togcj02
import re

file_path = '../原始数据百度座标系.csv'
write_path = '../转换成火星座标系.csv'

with open(file_path, 'r') as f:
	line_list = f.readlines()

#for line in line_list:
#	print line

with open(write_path, 'a') as w:
	for line_index in range(len(line_list)):
		#得到这一行的字符串
		line = line_list[line_index]
		#第一行是表头不用转换，直接写入
		if line_index==0:
			w.write(line)
		else:
			p = re.compile(r'\"[^\"]*"')
			node_list = p.findall(line)
			#从百度座标系转换成火星座标系
			lng = float(node_list[4].strip('\"'))
			lat = float(node_list[5].strip('\"'))
			gcj02_location = bd09togcj02(lng, lat)
			#拼接字符串再写入
			convert_line = ""
			for node_index in range(len(node_list)):
				if node_index == 4:
					convert_line += ('\"' + str(gcj02_location[0]) + '\",')
				elif node_index == 5:
					convert_line += ('\"' + str(gcj02_location[1]) + '\",')
				elif node_index == (len(node_list) - 1):
					convert_line += (node_list[node_index] + "\n")
				else:
					convert_line += (node_list[node_index] + ",")
			w.write(convert_line)