clear all; close all; clc;

img_name = "cw3.jpg";
img = imread(img_name);
[r,c] = size(img);
ratio = r/768;
c = c/3;
x = 1:0.1:r;
figure;

uni_rho = [126.5854, 528.9802, 181.1762, 524.2042];
uni_theta = [89.2795, 102.5729, 173.6097, 90.7211];

k_uni = -cotd(uni_theta);
a0_uni = ratio*uni_rho./sind(uni_theta);

for j = 1:length(k_uni)
    y = k_uni(j)*x + a0_uni(j);
    plot(x,y,'b-','Linewidth',3, 'color', [0 0 1 1]);
end