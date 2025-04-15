clear all;
close all;
clc;

%% Declear file name
file_name = 'Environment.jpg';

%% Import picture into MATLAB
RGB = imread(file_name);

%% Determine the size of the RGB Matrix
[row,col,layer] = size(RGB);

%% Degrade 3D matrix to 3 2D Matrices
R = RGB(:,:,1);
G = RGB(:,:,2);
B = RGB(:,:,3);

%% Covert RGB pixels into grey pixels (Digitization)
grey_pixel = (R+G+B)/3;
[a,b] = size(grey_pixel);
ref = median(median(grey_pixel));
ref_double = median(median(im2double(grey_pixel)));
higher_ref = grey_pixel >= ref; % dark
light = sum(sum(higher_ref));
if light < 1/2*a*b
    fprintf('Light pixel will be considered as main pixel.\n');
else
    fprintf('Dark pixel will be considered as main pixel.\n');
end

% Remove background
foreground = abs(im2double(grey_pixel) - ref_double);
[x_c,y_c] = Pixel_COM(foreground);
fprintf('The equlvanet pixel COM is x_c = %.2f, y_c = %.2f\n',x_c,y_c);

%% Introduce 'Density Cloud' --- PDF function
sigma = 1/sqrt(2*pi);
Z =@(X,Y,squeeze) 1/(sigma*sqrt(2*pi))*exp(-0.5*(squeeze*sqrt(X.^2+Y.^2)/sigma).^2);
%% Use surf to display the intensity of the picture
% figure(1);
% [ROW,COL] = meshgrid(1:col,1:row);
% surf(ROW,COL,grey_pixel)

%% Only select a part of the picture to test our algorithm (pixel row:600-800)
grey_pixel_part = grey_pixel(600:800,:);
thre_d = 100; %  Set the intensity threshold to 100 with density cloud applied
thre = 20;

%% Call the function to identify the critical point
tic
%critical_point = critical_point_pick_up(grey_pixel_part,thre_d,Z,x_c,y_c,0,599);
critical_point = critical_point_pick_up_16(grey_pixel_part,thre);
toc
%% Consider the 'base' number of row pixels
base = 599;
critical_point(:,1) = critical_point(:,1) + base;

%% Create plot
figure(2);
imshow(file_name);
hold on;
critical_y = critical_point(:,1)';
critical_x = critical_point(:,2)';
plot(critical_x,critical_y,'r*','MarkerSize',5);

%% Export the critical point to an external excel for future analysis
file_name = 'Coordinate for critical point.xlsx';
writematrix(critical_point,file_name,'Sheet',1,'Range','A1:B32')