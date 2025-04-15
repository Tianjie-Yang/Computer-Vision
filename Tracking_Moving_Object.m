clear all;
close all;
clc;

%% Input the video
dir = ...
    '\\ad.monash.edu\home\User043\tyan0042\Documents\Computer Vision\Moving_Tester1.mp4';
videoReader = vision.VideoFileReader(dir);

%% Create two video player (One for foreground and one for the whole video)
videoPlayer = vision.VideoPlayer;
fgPlayer = vision.VideoPlayer;

%% Create Foreground Detector (Moving = Video input - Background)
foregroundDetector = vision.ForegroundDetector('NumGaussians', 3, 'NumTrainingFrames', 50);

%% Take the first 150 frames to be the background (learn background)
for i = 1:150
   videoFrame = step(videoReader);
   foreground = step(foregroundDetector, videoFrame);
end
figure;
imshow(videoFrame);
title('Input Frame');
figure;
imshow(foreground);
title('Foreground');

%% Using morphology to clean the noise in the background
% 'strel' creates morphological structuring element. 'Disk' means a flat disk-shaped structuring element
% Function choose from
% imdilate, imerode, imopen, imclose
cleanForeground = imerode(foreground, strel('Disk',1)); 
figure;
subplot(1,2,1);
imshow(foreground);
title('Original Foreground');
subplot(1,2,2);
imshow(cleanForeground);
title('Clean Foreground');

%% Create blob analysis onbject
% Reject the blobs that are less than 150 pixels
blobAnalysis = vision.BlobAnalysis('BoundingBoxOutputPort', true,...
    'AreaOutputPort', false, 'CentroidOutputPort', false, ...
    'MinimumBlobArea', 150);

%% Loop through the whole video
while ~isDone(videoReader)
   % Extrate the next frame
   videoFrame = step(videoReader);
   
   % Process the video
   foreground = step(foregroundDetector, videoFrame);
   cleanForeground = imerode(foreground, strel('Disk',1));
   
   % Detect the moving object and generate the bounding box for the moving
   % object
   bound = step(blobAnalysis, cleanForeground);
   
   result = insertShape(videoFrame, 'Rectangle', bound, 'Color','red');
   
   % End of video processing
   
   % Display output
   step(videoPlayer,result);
   step(fgPlayer,cleanForeground);
end