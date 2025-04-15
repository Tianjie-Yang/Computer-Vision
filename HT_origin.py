import cv2
import numpy as np
import math
from numpy.linalg import inv
import pandas as pd
from glob import glob
import matplotlib.pyplot as plt
import IPython.display as ipd
from tqdm.notebook import tqdm
import subprocess
import imutils

print(cv2.__version__)

def Hough_line_detection(file_name, scale_factor):
    str_test = isinstance(file_name, str)
    if not str_test:
        return False
    
    img = cv2.imread(file_name)
    width = int(img.shape[1]*scale_factor/100)
    height = int(img.shape[0]*scale_factor/100)
    # Print screen size
    print('width =' , width)
    print('hei = ', height)
    dim = (width, height)
    resized = cv2.resize(img, dim, interpolation=cv2.INTER_AREA)
    gray = cv2.cvtColor(resized, cv2.COLOR_BGR2GRAY)
    edges = cv2.Canny(gray, 50, 150, apertureSize=3)
    lines = cv2.HoughLines(edges, 1, np.pi / 180, 100)
    
    unique_rho = []
    unique_theta = []
    thre = 50
    flag = 1
    line_cnt = 1
    
    for line in lines:
        rho, theta = line[0]
        n = len(unique_rho)
        # There is not element in the unique_rho
        
        unique_rho.append(rho)
        unique_theta.append(theta)

    # Display the lines
    for element in range(len(unique_theta)):        
        a = np.cos(unique_theta[element])
        b = np.sin(unique_theta[element])
        x0 = a*unique_rho[element]
        y0 = b*unique_rho[element]
        
        x1 = int(x0 + 1000 * (-b))
        y1 = int(y0 + 1000 * (a))
        x2 = int(x0 - 1000 * (-b))
        y2 = int(y0 - 1000 * (a))
        cv2.line(resized, (x1, y1), (x2, y2), (0, 0, 255), 2)
    
    cv2.imshow(file_name, resized)
    return resized, unique_rho, unique_theta

file_name = "Set4_end_dust.jpg"
scale_factor = 45
resized, unique_rho, unique_theta = Hough_line_detection(file_name, scale_factor)

print(unique_rho)

print(unique_theta)

cv2.imshow("Facade panel with CoM", resized)


""" TEST Code
a = np.array([[1,0],
              [0,1]])
b = np.array([[4, 1]])
sol = np.matmul(inv(np.matrix(a)), np.transpose(b))
print(float(sol[0] + 1))
"""

"""
img = cv2.imread('test2.jpg')
scale_percent = 45
width = int(img.shape[1]*scale_percent/100)
height = int(img.shape[0]*scale_percent/100)
dim = (width, height)

resized = cv2.resize(img, dim, interpolation=cv2.INTER_AREA)

gray = cv2.cvtColor(resized, cv2.COLOR_BGR2GRAY)
cv2.imshow('gray_image',gray)
edges = cv2.Canny(gray, 50, 150, apertureSize=3)
lines = cv2.HoughLines(edges, 1, np.pi / 180, 200)

for line in lines:
    rho, theta = line[0]
    a = np.cos(theta)
    b = np.sin(theta)
    x0 = a*rho
    y0 = b*rho
    
    x1 = int(x0 + 1000 * (-b))
    y1 = int(y0 + 1000 * (a))
    x2 = int(x0 - 1000 * (-b))
    y2 = int(y0 - 1000 * (a))
    cv2.line(resized, (x1, y1), (x2, y2), (0 ,0, 255), 2)

cv2.imshow('test2',resized)
"""


cv2.waitKey(0)
cv2.destoryAllWindows()


    