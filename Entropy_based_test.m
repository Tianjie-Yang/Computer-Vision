clear all; close all; clc;

filename = 'Environment.jpg';
img = imread(filename);
[r_sample,c_sample,~] = size(img);
low_thre = 600/r_sample; high_thre = 800/r_sample;
patch_size = 3;
[r_abs,c_abs] = entropy_patch_based(filename,low_thre,high_thre,patch_size);
figure;
imshow(filename);
hold on;
plot(c_abs,r_abs,'r*')