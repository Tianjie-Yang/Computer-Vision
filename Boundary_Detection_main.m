clear all; close all; clc;
H = importdata('Entropy_Single_facade_panel_front.mat');
Boundary_Binary = zeros(size(H));
thre_H = 0.9; % Threshold of entropy selection
Boundary_Binary(H >= max(max(H))*thre_H) = 1;
Boundary_Binary = imresize(Boundary_Binary,0.6);
filename = 'Single_facade_panel_front.jpg';
dp = [30 50 100 150]; % pixels 30 50 100 150
slope_limit_horizontal = 0.1;
slope_limit_vertical = 15;
%[k_v,b_v,x_offset_v] = Vertical_Boundary_Detection(filename,H,Boundary_Binary,dp(1),slope_limit_vertical);
[k_h,b_h,y_offset_h] = Horizontal_Boundary_Detection(filename,H,Boundary_Binary,dp(4),slope_limit_horizontal);
[vx,vy] = vertices_detection(filename,k_v,k_h,b_v,b_h,x_offset_v, y_offset_h)
%%
for i = 1:length(dp)
    tic
    [k,b,x_offset] = Vertical_Boundary_Detection(filename,H,Boundary_Binary,dp(i),slope_limit_vertical);
    %[k,b,x_offset] = Horizontal_Boundary_Detection(filename,H,Boundary_Binary,dp(i),slope_limit_horizontal);
    toc
end
%%
hold on;
for j = 1:4
   figure(j);
   str = sprintf("patch width = %d pixels",dp(j));
   title(str) 
end
%[k,b,x_offset] = Horizontal_Boundary_Detection(filename,H,Boundary_Binary,dp,slope_limit_horizontal);