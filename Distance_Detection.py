# import the necessary packages
from imutils import paths
import numpy as np
import imutils
import cv2

def find_marker(image):
    # convert the image to grayscale, blur it, and detect edges
    gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
    gray = cv2.GaussianBlur(gray,(5 ,5), 0)
    edged = cv2.Canny(gray, 35, 125)

    # find the contours in the edged image and keep the largest one;
    # Assume it is the facade panel
    cnts = cv2.findContours(edged.copy(), cv2.RETR_LIST, cv2.CHAIN_APPROX_SIMPLE)
    cnts = imutils.grab_contours(cnts)
    c = max(cnts, key = cv2.contourArea)

    # compute the bounding box of the facade region and return it
    return cv2.minAreaRect(c)

def distance_to_camera(knowWidth, focalLength, perWidth):
    return (knowWidth * focalLength) / perWidth

# Initialise the know distance from the camera to the panel (in mm)
KNOWN_DISTANCE = 200

# Initialise the known facade width (in mm)
KNOWN_WIDTH = 100

image = cv2.imread("20cm.jpg")
marker = find_marker(image)
focalLength = (marker[1][0]* KNOWN_DISTANCE) / KNOWN_WIDTH # F = (P x D) / W
print(marker[1][0])
# print(focalLength)
image = cv2.imread("30cm.jpg")
marker = find_marker(image)
dist = distance_to_camera(KNOWN_WIDTH, focalLength, marker[1][0])
print(marker[1][0])
print(dist)

box = cv2.boxPoints(marker) if imutils.is_cv2() else cv2.boxPoints(marker)
box = np.int64(box)
cv2.drawContours(image, [box], -1, (0, 255, 0), 2)
cv2.putText(image, "%.2fmm" % dist,
            (image.shape[1] - 400, image.shape[0] - 20), cv2.FONT_HERSHEY_SIMPLEX,
            2.0, (0, 255, 0), 3)
image = cv2.resize(image, None, fx = 0.5, fy = 0.5)
cv2.imshow("image",image)
cv2.waitKey(0)