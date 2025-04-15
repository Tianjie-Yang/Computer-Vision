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
        CoM_x = -1
        CoM_y = -1
        vet_x = -1
        vet_y = -1
        return CoM_x, CoM_y, vet_x, vet_y
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
                if rho == unique_rho[idx] or theta == 0 or abs(abs(rho) - abs(unique_rho[idx])) < thre or line_cnt >= 4 or abs(theta - unique_theta[idx]) < 0.05:# or (theta > 2.2 and theta < 2.6) or (theta > 0.75 and theta < 0.85) or (theta > 2.85 and theta < 2.94): #or abs(abs(rho) - abs(unique_rho[idx])) < 200 or abs(rho) < 15
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
    # Test
    #unique_theta.pop()
    #unique_rho.pop()
    #

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

def Two_D_facade_rotation(x_coor, y_coor, rho, theta,w,h):
    if x_coor == -1:
        print("Boundary Invalid!")
    elif len(theta) < 3 or len(rho) < 3:
        print("Boundary Invalid!")
    elif x_coor == 0:
        horizontal_cnt = 0
        for i in theta:
            if math.degrees(i) > 60 and math.degrees(i) < 120:
                horizontal_cnt = horizontal_cnt + 1
        
        if horizontal_cnt == 2:
            print("2H1V")
            opt = 1
        else:
            print("2V1H")
            opt = 2
        
        for i in range(0,len(theta)-1):
            for j in range(i+1,len(theta)):
                if theta[i] > theta[j]:
                    temp = theta[j]
                    theta[j] =  theta[i]
                    theta[i] = temp
                    
                    temp = rho[j]
                    rho[j] =  rho[i]
                    rho[i] = temp
        
        if opt == 1:
            if (abs(abs(math.degrees(theta[2] - theta[1])) - 90) < 5 and abs(abs(math.degrees(theta[2]- theta[0])) - 90) < 5) or (abs(abs(math.degrees(theta[0] - theta[1])) - 90) < 5 and abs(abs(math.degrees(theta[0] - theta[2])) - 90) < 5):
                print("Perpendicular!")
            elif math.degrees(theta[0]) < 45: #VHH
                # FW
                if rho[1] > rho[2] and  math.degrees(theta[0]) < 10:
                    print("CCW")
                elif rho[1] < rho[2] and  math.degrees(theta[0]) < 10:
                    print("CW")
                elif math.degrees(theta[1]) > 85 and math.degrees(theta[1]) < 95 and math.degrees(theta[2]) > 85 and math.degrees(theta[2]) < 95 and math.degrees(theta[0]) > 10:
                    print("FW")
                elif rho[1] > rho[2]:
                    print("CCWFW")
                else:
                    print("CWFW")
            elif math.degrees(theta[2]) > 135: #HHV
                # BW
                if rho[0] > rho[1] and math.degrees(theta[2]) > 170:
                    print("CCW")
                elif rho[1] > rho[0] and math.degrees(theta[2]) > 170:
                    print("CW")
                elif math.degrees(theta[1]) > 85 and math.degrees(theta[1]) < 95 and math.degrees(theta[2]) > 85 and math.degrees(theta[2]) < 95 and math.degrees(theta[2]) < 170:
                    print("FW")
                elif rho[0] > rho[1]:
                    print("CCWBW")
                else:
                    print("CWBW")


        if opt == 2:
            if (abs(abs(math.degrees(theta[2] - theta[1])) - 90) < 5 and abs(abs(math.degrees(theta[2] - theta[0])) - 90) < 5) or (abs(abs(math.degrees(theta[1] - theta[0])) - 90) < 5 and abs(abs(math.degrees(theta[1] - theta[2])) - 90) < 5) or (abs(abs(math.degrees(theta[0] - theta[1])) - 90) < 5 or abs(abs(math.degrees(theta[0] - theta[2])) - 90) < 5):
                print("Perpendicular!")
            elif abs(rho[2]) < abs(rho[0]):
                if math.degrees(theta[0]) < 10 and math.degrees(theta[2]) > 170 and math.degrees(theta[1]) > 95:
                    print("CW")
                elif math.degrees(theta[0]) < 10 and math.degrees(theta[2]) > 170 and math.degrees(theta[1]) < 85:
                    print("CCW")
                elif math.degrees(theta[1]) > 85 and math.degrees(theta[1]) < 95 and math.degrees(theta[2]) < 170 and math.degrees(theta[0]) > 10:
                    print("BW")
                elif math.degrees(theta[1]) < 85 and math.degrees(theta[1]) > 50:
                    print("CCWBW")
                else:
                    print("CWBW")
                
                #if math.degrees(theta[1]) >= 85 and math.degrees(theta[1]) < 95:
                #    print("BW")
            else:
                if math.degrees(theta[0]) < 10 and math.degrees(theta[2]) > 170 and math.degrees(theta[1]) > 95:
                    print("CW")
                elif math.degrees(theta[0]) < 10 and math.degrees(theta[2]) > 170 and math.degrees(theta[1]) < 85:
                    print("CCW") 
                elif math.degrees(theta[1]) > 85 and math.degrees(theta[1]) < 95 and math.degrees(theta[2]) < 170 and math.degrees(theta[0]) > 10:
                    print("FW")   
                elif math.degrees(theta[1]) < 85 and math.degrees(theta[1]) > 50:
                    print("CCWFW")
                else:
                    print("CWFW")
                
                #if math.degrees(theta[1]) >= 85 and math.degrees(theta[1]) <= 95:
                #    print("FW")
    elif len(x_coor) == 4:
        for i in range(0,len(x_coor)-1):
            for j in range(i+1,len(x_coor)):
                if x_coor[i] > x_coor[j]:
                    temp = x_coor[j]
                    x_coor[j] =  x_coor[i]
                    x_coor[i] = temp
                    
                    temp = y_coor[j]
                    y_coor[j] =  y_coor[i]
                    y_coor[i] = temp
        
        for i in range(0,len(theta)-1):
            for j in range(i+1,len(theta)):
                if theta[i] > theta[j]:
                    temp = theta[j]
                    theta[j] =  theta[i]
                    theta[i] = temp
                    
                    temp = rho[j]
                    rho[j] =  rho[i]
                    rho[i] = temp

        if (abs(math.degrees(theta[0] - theta[3])) < 5 and abs(math.degrees(theta[1] - theta[2])) < 5) or (abs(math.degrees(theta[0] - theta[1])) < 5 and abs(math.degrees(theta[2] - theta[3])) < 5):
            print("Perpendicular!")
        elif y_coor[3] < y_coor[0] and y_coor[0] < y_coor[2] and y_coor[2] < y_coor[1] or y_coor[0] < y_coor[3] and y_coor[3] < y_coor[2] and y_coor[2] < y_coor[1]:
            if abs(y_coor[3] - y_coor[0]) < h/20 and abs(y_coor[1] - y_coor[2]) < h/20:
                print("BW")
            elif abs(x_coor[0] - x_coor[1]) < w/10 and abs(x_coor[2] - x_coor[3]) < w/10:
                print("CCW")
            else:
                print("CCWBW")
        elif y_coor[1] < y_coor[2] and y_coor[2] < y_coor[0] and y_coor[0] < y_coor[3]:
            if abs(y_coor[1] - y_coor[2]) < h/20 and abs(y_coor[0] - y_coor[3]) < h/20:
                print("FD")
            elif abs(x_coor[0] - x_coor[1]) < w/15 and abs(x_coor[2] - x_coor[3]) < w/15:
                print("CCW")
            else:
                print("CCWFD")
        elif y_coor[0] < y_coor[2] and y_coor[2] < y_coor[1] and y_coor[1] < y_coor[3] or y_coor[2] < y_coor[0] and y_coor[0] < y_coor[1] and y_coor[1] < y_coor[3] or y_coor[2] < y_coor[0] and y_coor[0] < y_coor[3] and y_coor[3] < y_coor[1]:
            if abs(y_coor[0] - y_coor[2]) < h/20 and abs(y_coor[1] - y_coor[3]) < h/20:
                print("BW")
            elif abs(x_coor[0] - x_coor[1]) < w/15 and abs(x_coor[2] - x_coor[3]) < w/15:
                print("CW")
            else:
                print("CWFD")
        elif y_coor[2] < y_coor[0] and y_coor[0] < y_coor[1] and y_coor[1] < y_coor[3]:
            if abs(y_coor[1] - y_coor[3]) < h/20 and abs(y_coor[0] - y_coor[2]) < h/20:
                print("FD")
            elif abs(x_coor[0] - x_coor[1]) < w/15 and abs(x_coor[2] - x_coor[3]) < w/15:
                print("CW")
            else:
                print("CWFD")


# Initialise the know distance from the camera to the panel (in mm)
KNOWN_DISTANCE = 200

# Initialise the known facade width (in mm)
KNOWN_WIDTH = 100

image = cv2.imread("20cm.jpg")
marker = find_marker(image)
focalLength = (marker[1][0]* KNOWN_DISTANCE) / KNOWN_WIDTH # F = (P x D) / W

file_name = "55.jpg" # CCWBW2
scale_factor = 45
resized, unique_rho, unique_theta = Hough_line_detection(file_name, scale_factor)

width = int(resized.shape[1]*scale_factor/100)
height = int(resized.shape[0]*scale_factor/100)
print("resized image width = ", width)
print("resized image height = ", height)

CoM_x, CoM_y, vet_x, vet_y = CoM(unique_rho, unique_theta)
#print("CoM x = ", CoM_x)
#print("CoM y = ", CoM_y)

for i in range(0,len(unique_theta)):
    print("unique_rho = ", unique_rho[i])

for j in range(0,len(unique_theta)):
    print("unique_theta = ", math.degrees(unique_theta[j]))

#for k in range(0,len(vet_x)):
#    print("x_coor = ", vet_x[k])

#for q in range(0,len(vet_y)):
#    print("y_coor = ", vet_y[q])

#Two_D_facade_rotation(vet_x, vet_y,unique_rho,unique_theta, width, height)

center_coordinates = (int(CoM_x), int(CoM_y))
radius = 5 #Radius of the marker
thickness = 10 #Thickness of the marker
color = (0, 0, 255) # Red color in BGR
image_with_marker = cv2.circle(resized, center_coordinates, radius, color, thickness)
#dist = distance_to_camera(KNOWN_WIDTH, focalLength, abs(vet_x[0] - vet_x[1])*3.74)
#print(dist)
cv2.imshow("Facade panel with CoM", image_with_marker)


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


    