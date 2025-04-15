clear all; close all; clc;

%% Pick up the patch we want to analyse
H = importdata('Entropy_Single_facade_panel_front.mat');
Boundary_Binary = zeros(size(H));
thre_H = 0.9; % Threshold of entropy selection
Boundary_Binary(H >= max(max(H))*thre_H) = 1;
figure(1);
imshow('Single_facade_panel_front.jpg'); hold on;
[r,c] = size(Boundary_Binary); x_offset = 200;
plot([200 350 350 200 200],[r*0.1 r*0.1 r*0.7 r*0.7 r*0.1],'r-','Markersize',4);
Binary_Patch = Boundary_Binary(r*0.2:r*0.7,200:350);

%% Apply RANSEC algorithm to the selected patch
[y,x] = find(Binary_Patch == 1); hold on;
k = zeros(size(x));
b = zeros(size(x));
x_top = x(y < max(y)*0.2);
y_top = y(y < max(y)*0.2);
x_bot = x(y > max(y)*0.8);
y_bot = y(y > max(y)*0.8);

case_num = 1;
sigma = 5;
%%
tic; % 94.14s
for i = 1:length(x_top) - 1
    for j = i + 1:length(x_bot)
        x_test = [x_top(i) x_bot(j)];
        y_test = [y_top(i) y_bot(j)];
        coefficient = polyfit(x_test,y_test,1);
        if abs(coefficient(1)) > 1e3 %Apply constraints to minimize the possibilities
            k(case_num) = coefficient(1);
            b(case_num) = coefficient(2);
            y_fit = @(x) coefficient(1)*x + coefficient(2);
            [L] = LineDist(y_fit,[x y]);% Vectorised function
            Num_point(case_num) = sum(L < sigma);
            case_num = case_num + 1;
        else
            continue;
        end
    end
end
toc;
%% Demo ONLY
Num_point = importdata('Num_point_RANSEC.mat');
k = importdata('K_RANSEC.mat');
b = importdata('b_RANSEC.mat');
%%
[M,~] = max(Num_point);
idx = find(Num_point == M);
k_best = k(idx(1));
b_best = b(idx(1));
x = 200:0.01:350;
plot(x,k_best*(x - x_offset) + b_best,'b-','LineWidth',3);