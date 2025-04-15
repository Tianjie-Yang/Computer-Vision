clear all; close all; clc;

%% Entropy of a image (Entropy = average information)
format = 'facade.jpg';
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

filename = 'facade.jpg';
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

%% Filtering for the pixels that have the highest entropy
factor = 0.95;
[c,r] = find(H > factor*max(H));
figure;
imshow('Environment.jpg');
hold on;
plot(r,c,'r*');
%% Test 1：Simplify find the intersection between the 