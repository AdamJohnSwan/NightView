import numpy as np
import cv2
import sys
import math
from PIL import Image

file = str(sys.argv[1])

#get image size
img = Image.open(file)
img_width, img_height = img.size
#resize if too large
max_size = 1000
if (img_height > max_size or img_width > max_size):
	img.thumbnail([max_size, max_size])
	img.save(file)
	img_width, img_height = img.size

im = cv2.imread(file)

imgray = cv2.cvtColor(im,cv2.COLOR_BGR2GRAY)
ret,thresh = cv2.threshold(imgray,127,255,0)
image, contours, hier = cv2.findContours(thresh,cv2.RETR_LIST,cv2.CHAIN_APPROX_SIMPLE)

contours_list = []
# get rid of image border
for contour in contours:
	contours_list.append(contour.tolist())
contours_list = contours_list[:-1]
item = [[0,0]]
#ran = math.floor((img_width * img_height) * 0.0002)
ran = 20
dimx = 0
dimy = 0
for contour in contours_list:
	section = []
	last_unique_point = contour[0][0]
	for idx, node in enumerate(contour):
		#find max
		if node[0][0] > dimx: dimx = node[0][0]
		if node[0][1] > dimy: dimy = node[0][1]

		if(idx != 0):
			#only get points that have a unique value
			if(last_unique_point[0] - ran <= node[0][0] <= last_unique_point[0] + ran and last_unique_point[1] - ran <= node[0][1] <= last_unique_point[1] + ran):
				pass
			else:
				last_unique_point = node[0]
				section.append(node)
		else:
			section.append(node)
	item.append(section)
item[0][0] = dimx
item[0][1] = dimy
print(item)
