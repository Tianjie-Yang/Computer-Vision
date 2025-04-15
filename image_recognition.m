clear all;
close all;
clc;

%% Import image from external source
% P1 = imread('single_cover.JPG');
% P1 = imread('Sanitiser.JPG');
% P1 = imread('Beer.PNG');
P1 = imread('Beer_new.PNG');
figure;
% P1 = imresize(P1, [224 224]);
imshow(P1);
title('single object');
% P2 = imread('overview_new.JPG');
P2 = imread('Environment.JPG');
% P2 = imread('web_cap.jpg');
% P2 = imresize(P2, [224 224]);
figure;
imshow(P2);
title('Scene');

%% Picuture Detection (convert to gray)
data_points1 = detectSURFFeatures(rgb2gray(P1));
data_points2 = detectSURFFeatures(rgb2gray(P2));

%% Extract pixels
[P11,validpts1] = extractFeatures(rgb2gray(P1),data_points1);
[P22,validpts2] = extractFeatures(rgb2gray(P2),data_points2);

%% Display extract pictures
figure;
imshow(P1);
hold on;
plot(validpts1,'showOrientation',true);
title('Detected picutures');

%% Match the strong points
strong_points_pairs = matchFeatures(P11, P22,...
    'Prenormalized',true);
matched_pts1 = validpts1(strong_points_pairs(:,1));
matched_pts2 = validpts2(strong_points_pairs(:,2));
figure;
showMatchedFeatures(P1,P2,matched_pts1,matched_pts2,'montage');
title('Picture perception');

% Define location of object in image
boxPolygon = [1, 1;...                           % top-left
             size(P1, 2), 1;...                  % top-right
             size(P1, 2), size(P1, 1);...        % bottom-right
             1, size(P1, 1);...                  % bottom-left
             1, 1];                               % top-left again to close the polygon
%% Remove the outliers (Using Random Sample Consensus (RANSEC) algorithm)
% Calculate the percentage of accurate perception
iter = 1;
acc = 10; % Set a random initial value below 20 to triger the while loop
while acc < 20
    [tform, inlierPoints1, inlierPoints2]...
        = estimateGeometricTransform(matched_pts1,matched_pts2,'affine');
    inlierPoints_size = size(inlierPoints1);
    matched_pts_size = size(matched_pts1);
    acc = inlierPoints_size(1)/matched_pts_size(1)*100;
    fprintf('%d: The accurate perception of the key points is %.2f%%.\n',iter,acc);
    iter = iter + 1;
end
figure;
showMatchedFeatures(P1,P2,inlierPoints1,inlierPoints2,'montage');
title('Filtered Matches without outliers');

%% Locate the exact position of target object
newBoxPolygon = transformPointsForward(tform, boxPolygon);
figure;
% P2 = imresize(P2 ,[224 224]);
imshow(P2);
hold on;
line(newBoxPolygon(:,1),newBoxPolygon(:,2),'Color','g','LineWidth',5);
title('Location of the target object');
