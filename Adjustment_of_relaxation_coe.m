clear all; close all; clc;

%% First layer scan of the picuture
% Convert the picuture into Grey pixel
filename = 'High-Rise Building window1.jpg';
[Grey_pixel,h,w] = RGB2Grey(filename);

% Mark the diagnoal
figure;
imshow(filename); hold on;
plot([1 w],[1 h],'r--',[w 1],[1 h],'r--');

%% Define the diagnoal profile according to the size of the image
diag1 = @(x) h/w*x;
diag2 = @(x) -h/w*x + h;

% Separate the background and foreground
% Assume that the background pixel value is the pixel that repeat most of
% the times
% median: O(nlog(n))for a full sort based approach
% Using loops: O(n^2) for a n-by-n matrix
background_pixel = median(median(Grey_pixel));

%% Set the constants
STD_pixel = 20; Initial_coe = 10; factor = 0.1;

%% Pick up 65 equally spaced pixel on both diagnoals (64 interval)
x_pix = linspace(1,w,65);
plot(round(x_pix),round(diag1(x_pix)),'ro');
pixel_scan1 = diag(Grey_pixel(round(diag1(x_pix)),round(x_pix)),0); % Pick up main diagnoal element
text(round(x_pix)+2, round(diag1(x_pix)), string(pixel_scan1));

plot(round(x_pix),round(diag2(x_pix)),'bo');
pixel_scan2 = diag(Grey_pixel(round(diag2(x_pix))+1,round(x_pix)),0); % Pick up main diagnoal element
text(round(x_pix)+2, round(diag2(x_pix)), string(pixel_scan2));

%% Calculate the variance of the coefficient from both diagnoals
variance_diag1 = reward(STD_pixel,Initial_coe,pixel_scan1, background_pixel,factor);
variance_diag2 = reward(STD_pixel,Initial_coe,pixel_scan2, background_pixel,factor);
Var = variance_diag1 + variance_diag2;
updated_coe = Initial_coe + Var;
updated_ratio = updated_coe/STD_pixel