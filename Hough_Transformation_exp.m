clear all; close all; clc;

a = zeros(50,50); % Create a 50x50 patch
a(20,20) = 1;
a(30,15) = 1;
a(40,10) = 1;
a(30,40) = 1; % Noise pixel
subplot(2,1,1);
imshow(a);

[H,T,R] = hough(a);
subplot(2,1,2);
houghVisualize(H,T,R);

hPeaks = houghpeaks(H);
theta = T(hPeaks(:,2));
rho = R(hPeaks(:,1));
plot(theta,rho,'gs');
% rho = xcos(theta) + ysin(theta)
y = @(theta,rho,x) -cotd(theta)*x + rho/sind(theta);
subplot(2,1,1);
hold on;
x = 0:0.01:50;
plot(x,y(theta,rho,x),'r-');
