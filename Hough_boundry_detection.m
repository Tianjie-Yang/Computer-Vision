clear all; close all; clc;

%% Pick up the patch we want to analyse
H = importdata('Entropy_Single_facade_panel_front.mat');
Boundary_Binary = zeros(size(H));
thre_H = 0.9; % Threshold of entropy selection
Boundary_Binary(H >= max(max(H))*thre_H) = 1;
figure(1);
imshow('Single_facade_panel_front.jpg'); hold on;
[r,c] = size(Boundary_Binary);
plot([200 350 350 200 200],[1 1 r*0.7 r*0.7 1],'r-','Markersize',4);
Binary_Patch = Boundary_Binary(1:r*0.7,200:350);

%% Apply Hough Transformation to the selected patch
figure(2);
x_offset = 200;
imshow(Binary_Patch);
[H,T,R] = hough(Binary_Patch);
figure(3);
houghVisualize(H,T,R);
tic; %0.04s
hPeaks = houghpeaks(H);
theta = T(hPeaks(:,2));
rho = R(hPeaks(:,1));
plot(theta,rho,'gs');
% rho = xcos(theta) + ysin(theta)
y = @(theta,rho,x) -cotd(theta)*(x - x_offset) + rho/sind(theta);
figure(1); hold on;
x = 200:0.01:350;
plot(x,y(theta,rho,x),'b-','Linewidth',3);
toc;