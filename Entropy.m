clear all; close all; clc;

%% Entropy of a image (Entropy = average information)
format = 'Environment%s.jpg';
magnificationFactor = [0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5];
H = zeros(1,length(magnificationFactor));
for i = 1:length(magnificationFactor)
   filename = sprintf(format,num2str(i));
   img = imread(filename);
   H(i) = entropy(img); % Global entropy (average entropy)
end
figure;
plot(magnificationFactor,H,'bo');
xlabel('Magnification Factor');
ylabel('Entropy (bits/pixel)');
title('Entropy VS Magnification Factor');

%% Use "patch-based" analysis: The image is divided into small patches and each patch is processed individually
% Goal: Final local entropy (absolute entropy)
% Create a patch for each image based on its magnification factor
% Let first target on the original picture!
clear;
% filename = 'Lab_environment_1.jpg';
filename = 'Single_facade_panel_front.jpg'; % Change file name here!
[~,h,w] = RGB2Grey(filename);
img = imread(filename);
H = zeros(h-2,w-2);
for i = 2:h-1
    for j = 2:w-1
        % Let's define a patch!
        img_patch = img(i-1:i+1,j-1:j+1);
        % Calculate the discrete entropy (local entropy)
        H(i-1,j-1) = entropy(img_patch);
    end
end
%%
[hplot,wplot] = meshgrid(2:w-1,2:h-1);
figure;
gca = surf(hplot,wplot,H);
hold on;
imagesc(H); 
set(gca,'LineStyle','none');
colorbar;

%% ChatGPT Update
% Use "patch-based" analysis: The image is divided into small patches and each patch is processed individually
% Goal: Final local entropy (absolute entropy)
% Create a patch for each image based on its magnification factor
% Let first target on the original picture!
clear;
% filename = 'Lab_environment_1.jpg';
filename = 'Single_facade_panel_front.jpg'; % Change file name here!
[~,h,w] = RGB2Grey(filename);
img = imread(filename);
H = zeros(h-2,w-2);

% Define patch size
patch_size = [3, 3];

% Calculate number of patches in each dimension
num_patches_h = h - patch_size(1) + 1;
num_patches_w = w - patch_size(2) + 1;

% Iterate over each patch
for patch_idx = 1:num_patches_h*num_patches_w
    % Convert patch index to 2D coordinates
    patch_i = floor((patch_idx-1)/num_patches_w) + 1;
    patch_j = mod(patch_idx-1, num_patches_w) + 1;
    
    % Define patch
    patch = img(patch_i:patch_i+patch_size(1)-1, patch_j:patch_j+patch_size(2)-1);
    
    % Calculate entropy
    H(patch_i, patch_j) = entropy(patch);
end

[hplot,wplot] = meshgrid(2:w-1,2:h-1);
figure;
gca = surf(hplot,wplot,H);
hold on;
imagesc(H); 
set(gca,'LineStyle','none');
colorbar;

%% Filtering for the pixels that have the highest entropy
factor = [0.05 0.95]; thre = 0.7;
% [c,r] = find((H > factor*max(H)));
[c,r] = BGF(H,factor,thre,1); % Background flitering
figure;
% imshow('Lab_environment_1.jpg');
imshow('Single_facade_panel_side.jpg');% Change file name here!
hold on;
plot(r,c,'r*');




%% Test 1：Simplify find the intersection between the 