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

### Functions
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

print(cv2.__version__)

# Given two detected lines, compute the intersection
def find_intersection(rho1, rho2, theta1, theta2):
    if theta1 == 0:
        theta1 = theta1 + 0.01
    
    if theta2 == 0:
        theta2 = theta2 + 0.01

    A = np.array([[1/math.tan(theta1), 1],
                  [1/math.tan(theta2), 1]])
    b = np.array([[rho1*(math.cos(theta1)/math.tan(theta1) + math.sin(theta1)), rho2*(math.cos(theta2)/math.tan(theta2) + math.sin(theta2))]])
    sol = np.matmul(inv(np.matrix(A)), np.transpose(b))
    x = float(sol[0])
    y = float(sol[1])
    return x, y

def CoM(unique_rho, unique_theta):
    # If we cannot detect exact four boundaries, then the current frame is invalid
    if len(unique_rho) != 4 or len(unique_theta) != 4:
        CoM_x = 0
        CoM_y = 0
        vet_x = 0
        vet_y = 0
        return CoM_x, CoM_y, vet_x, vet_y
    
    vertical_idx = []
    horizontal_idx = []
    vet_x = []
    vet_y = []
    for idx in range(len(unique_theta)):
        # horizontal line detection
        if np.rad2deg(unique_theta[idx]) <20 or np.rad2deg(unique_theta[idx]) > 160:
            horizontal_idx.append(idx)
        else:
            vertical_idx.append(idx)
    
    if len(vertical_idx) != 2:
        return None
    else:
        for i in vertical_idx:       
            for j in horizontal_idx:
                x, y = find_intersection(unique_rho[i], unique_rho[j], unique_theta[i], unique_theta[j])
                vet_x.append(x)
                vet_y.append(y)
                print(x)
                print(y)
    
    CoM_x = sum(vet_x)/len(vet_x)
    CoM_y = sum(vet_y)/len(vet_y)
    return CoM_x, CoM_y, vet_x, vet_y

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
    horizontal_line = 1
    vertical_line = 1
    
    for line in lines:
        rho, theta = line[0]
        n = len(unique_rho)
        # There is not element in the unique_rho
        if n == 0:
            unique_rho.append(rho)
            unique_theta.append(theta)
        else:   
            for idx in range(n):
                # Remove the duplicated lines by comparing the parameters
                if rho == unique_rho[idx] or theta == 0 or abs(abs(rho) - abs(unique_rho[idx])) < thre or abs(theta - unique_theta[idx]) < 0.25 or line_cnt >= 4:# or (theta > math.radians(120) and theta < math.radians(155)) or (theta > math.radians(18) and theta < math.radians(75))
                    flag = 0
                    break
        
            if flag:
                #if (horizontal_line == 2 and abs(np.rad2deg(theta) - 90) < 15) or (vertical_line == 2 and (abs(np.rad2deg(theta) - 180) < 15 or abs(np.rad2deg(theta)) < 15)):
                #    continue
                #else:
                unique_rho.append(rho)
                unique_theta.append(theta)
                line_cnt+=1
                    #if abs(np.rad2deg(theta) - 90) < 15:
                    #    horizontal_line+=1
                    #else:
                    #    vertical_line+=1
            
            flag = 1 #reset the flag

    unique_rho.pop()
    unique_theta.pop()
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

"""
def rotate_orientation_z(x_coor, y_coor, height):
    if len(x_coor) != 4 or len(y_coor) != 4:
        exit()
    else:
        for i in range(0,len(x_coor)-1):
            for j in range(i+1,len(x_coor)):
                if x_coor[i] > x_coor[j]:
                    temp = x_coor[j]
                    x_coor[j] =  x_coor[i]
                    x_coor[i] = temp
                    
                    temp = y_coor[j]
                    y_coor[j] =  y_coor[i]
                    y_coor[i] = temp
                    
        #print("vet_x = ", x_coor)
        #print("vet_x = ", y_coor)
        if abs(abs(y_coor[1] - y_coor[0]) - abs(y_coor[3] - y_coor[2])) < height/10:
            print("camera is perpendicular to the panel...")
        elif (abs(y_coor[1] - y_coor[0]) < abs(y_coor[3] - y_coor[2])):
            print("cw rotation...")
        else:
            print("ccw rotation...")
    
def rotate_orientation_z_slope(rho, theta):
    if len(rho) != 4 or len(theta) != 4:
        exit()
    else:
        for i in range(0,len(theta)-1):
            for j in range(i+1,len(theta)):
                if theta[i] > theta[j]:
                    temp = theta[j]
                    theta[j] =  theta[i]
                    theta[i] = temp
                    
                    temp = rho[j]
                    rho[j] =  rho[i]
                    rho[i] = temp
    
    if rho[2] < rho[1] and abs(theta[2] - theta[1]) > math.pi/6:
        print("ccw rotation")
    elif rho[2] > rho[1] and abs(theta[2] - theta[1]) > math.pi/6:
        print("cw rotation")
    else:
        print("Camera is perpendicular to the panel...")

"""

def rotate_orientation_z(x_coor, y_coor, rho, theta, height):
    if x_coor == 0 or y_coor == 0:
        # Missing lines. Cannot use corner to detect orientation.
        if len(rho) == 3 and len(theta) == 3:
            for i in range(0,len(theta)-1):
                for j in range(i+1,len(theta)):
                    if theta[i] > theta[j]:
                        temp = theta[j]
                        theta[j] =  theta[i]
                        theta[i] = temp
                        
                        temp = rho[j]
                        rho[j] =  rho[i]
                        rho[i] = temp
        
            if sum(theta)/len(theta) < math.radians(90): # left vertical line detected
                if rho[1] > rho[2] and abs(theta[1] - theta[2]) > math.pi/6:
                    print("CW...")
                    if abs(theta[1] - theta[2]) < math.pi/4:
                        print("Speed: Low")
                    elif(abs(theta[1] - theta[2]) < math.pi/3):
                        print("Speed: Medium")
                    else:
                        print("Speed: High")
                elif rho[1] < rho[2] and abs(theta[1] - theta[2]) > math.pi/6:
                    print("CCW...")
                    if abs(theta[1] - theta[2]) < math.pi/4:
                        print("Speed: Low")
                    elif(abs(theta[1] - theta[2]) < math.pi/3):
                        print("Speed: Medium")
                    else:
                        print("Speed: High")
                else:
                    print("Camera is perpendicular to the panel...")
            else:
                if rho[1] > rho[2] and abs(theta[1] - theta[2]) > math.pi/6:
                    print("CW...")
                    if abs(theta[1] - theta[2]) < math.pi/4:
                        print("Speed: Low")
                    elif(abs(theta[1] - theta[2]) < math.pi/3):
                        print("Speed: Medium")
                    else:
                        print("Speed: High")  
                elif rho[1] < rho[2] and abs(theta[1] - theta[2]) > math.pi/6:
                    print("CCW...")
                    if abs(theta[1] - theta[2]) < math.pi/4:
                        print("Speed: Low")
                    elif(abs(theta[1] - theta[2]) < math.pi/3):
                        print("Speed: Medium")
                    else:
                        print("Speed: High")
                else:
                    print("Camera is perpendicular to the panel...")
        else:
            exit()
    else:
        for i in range(0,len(x_coor)-1):
            for j in range(i+1,len(x_coor)):
                if x_coor[i] > x_coor[j]:
                    temp = x_coor[j]
                    x_coor[j] =  x_coor[i]
                    x_coor[i] = temp
                    
                    temp = y_coor[j]
                    y_coor[j] =  y_coor[i]
                    y_coor[i] = temp
                    
        #print("vet_x = ", x_coor)
        #print("vet_x = ", y_coor)
        if abs(abs(y_coor[1] - y_coor[0]) - abs(y_coor[3] - y_coor[2])) < height/10:
            print("camera is perpendicular to the panel...")
        elif (abs(y_coor[1] - y_coor[0]) < abs(y_coor[3] - y_coor[2])):
            print("cw rotation...")
            if abs(abs(y_coor[1] - y_coor[0]) - abs(y_coor[3] - y_coor[2])) > height/6:
                print("Speed: High")
            elif(abs(abs(y_coor[1] - y_coor[0]) - abs(y_coor[3] - y_coor[2])) > height/7):
                print("Speed: Medium")
            else:
                print("Speed: Low")
        else:
            print("ccw rotation...")
            if abs(abs(y_coor[1] - y_coor[0]) - abs(y_coor[3] - y_coor[2])) > height/6:
                print("Speed: High")
            elif(abs(abs(y_coor[1] - y_coor[0]) - abs(y_coor[3] - y_coor[2])) > height/7):
                print("Speed: Medium")
            else:
                print("Speed: Low")

def rotate_orientation_x(x_coor, y_coor, rho, theta, width):
    if x_coor == 0 or y_coor == 0:
        # Missing lines. Cannot use corner to detect orientation.
        if len(rho) == 3 and len(theta) == 3:
            for i in range(0,len(theta)-1):
                for j in range(i+1,len(theta)):
                    if theta[i] > theta[j]:
                        temp = theta[j]
                        theta[j] =  theta[i]
                        theta[i] = temp
                        
                        temp = rho[j]
                        rho[j] =  rho[i]
                        rho[i] = temp
        
            if abs(rho[0]) > abs(rho[2]):
                print("BW...")
                if abs(theta[0] - theta[2]) < math.pi*8.5/9:
                    print("Speed: High")
                elif(abs(theta[0] - theta[2]) < math.pi*17.5/18):
                    print("Speed: Medium")
                else:
                    print("Speed: Low")
            elif abs(rho[0]) < abs(rho[2]):
                print("FW...")
                if abs(theta[0] - theta[2]) < math.pi*8.5/9:
                    print("Speed: High")
                elif(abs(theta[0] - theta[2]) < math.pi*17.5/18):
                    print("Speed: Medium")
                else:
                    print("Speed: Low")
        else:
            exit()
    else:
        for i in range(0,len(y_coor)-1):
            for j in range(i+1,len(y_coor)):
                if y_coor[i] > y_coor[j]:
                    temp = y_coor[j]
                    y_coor[j] =  y_coor[i]
                    y_coor[i] = temp
                    
                    temp = x_coor[j]
                    x_coor[j] =  x_coor[i]
                    x_coor[i] = temp
                    
        #print("vet_x = ", x_coor)
        #print("vet_x = ", y_coor)
        if abs(abs(x_coor[1] - x_coor[0]) - abs(x_coor[3] - x_coor[2])) < width/10:
            print("camera is perpendicular to the panel...")
        elif abs(x_coor[1] - x_coor[0]) < abs(x_coor[3] - x_coor[2]):
            print("FW...")
            if abs(abs(x_coor[1] - x_coor[0]) - abs(x_coor[3] - x_coor[2])) < width/8:
                print("Speed: Low")
            elif abs(abs(x_coor[1] - x_coor[0]) - abs(x_coor[3] - x_coor[2])) < width/6:
                print("Speed: Medium")
            else:
                print("Speed: High")
        else:
            print("BW...")
            if abs(abs(x_coor[1] - x_coor[0]) - abs(x_coor[3] - x_coor[2])) < width/8:
                print("Speed: Low")
            elif abs(abs(x_coor[1] - x_coor[0]) - abs(x_coor[3] - x_coor[2])) < width/6:
                print("Speed: Medium")
            else:
                print("Speed: High")

def Two_D_facade_rotation(x_coor, y_coor):
    if len(x_coor) == 4:
        for i in range(0,len(x_coor)-1):
            for j in range(i+1,len(x_coor)):
                if x_coor[i] > x_coor[j]:
                    temp = x_coor[j]
                    x_coor[j] =  x_coor[i]
                    x_coor[i] = temp
                    
                    temp = y_coor[j]
                    y_coor[j] =  y_coor[i]
                    y_coor[i] = temp
    
    if y_coor[0] > y_coor[3] and y_coor[3] > y_coor[2] and y_coor[2] > y_coor[1]:
        print("CCWBW")
    elif y_coor[0] < y_coor[3] and y_coor[3] < y_coor[2] and y_coor[2] < y_coor[1]:
        print("CCWFD")
    elif y_coor[0] > y_coor[3] and y_coor[3] > y_coor[1] and y_coor[1] > y_coor[2]:
        print("CWBW")
    else:
        print("CWFD")

### Main Code
# Initialise the know distance from the camera to the panel (in mm)
KNOWN_DISTANCE = 200

# Initialise the known facade width (in mm)
KNOWN_WIDTH = 100

image = cv2.imread("20cm.jpg")
marker = find_marker(image)
focalLength = (marker[1][0]* KNOWN_DISTANCE) / KNOWN_WIDTH # F = (P x D) / W

file_name = "Set1_end_dust_effect1.jpeg"
scale_factor = 45
resized, unique_rho, unique_theta = Hough_line_detection(file_name, scale_factor)
img = cv2.imread(file_name)
width = int(img.shape[1]*scale_factor/100)
height = int(img.shape[0]*scale_factor/100)

CoM_x, CoM_y, vet_x, vet_y = CoM(unique_rho, unique_theta)
print("CoM x = ", CoM_x)
print("CoM y = ", CoM_y)
print("vet_x = ", vet_x)
print("vet_y = ", vet_y)
for i in range(0,len(unique_theta)):
    print("unique_rho = ", unique_rho[i])

for j in range(0,len(unique_theta)):
    print("unique_theta = ", math.degrees(unique_theta[j]))
#center_coordinates = (int(CoM_x), int(CoM_y))

#rotate_orientation_z(vet_x, vet_y, height)
#rotate_orientation_z_slope(unique_rho, unique_theta)
#rotate_orientation_z(vet_x, vet_y, unique_rho, unique_theta, height)
#rotate_orientation_x(vet_x, vet_y, unique_rho, unique_theta, width)
#Two_D_facade_rotation(vet_x, vet_y)

radius = 5 #Radius of the marker
thickness = 10 #Thickness of the marker
color = (0, 0, 255) # Red color in BGR
#image_with_marker = cv2.circle(resized, center_coordinates, radius, color, thickness)
#dist = distance_to_camera(KNOWN_WIDTH, focalLength, abs(vet_x[0] - vet_x[1])*3.74)
#print(dist)
#cv2.imshow("Facade panel with CoM", image_with_marker)


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


    