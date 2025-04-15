clear all;
close all;
clc;

%% Aet up the parameters for a webcam
webcamlist
cam = webcam(1);
cam.WhiteBalanceMode = 'auto';
cam.Resolution = '1280x720';
preview(cam);

%% Image capture by webcam
fprintf('Hit any button to take a snapshot.');
pause;
img = snapshot(cam);
figure; image(img);

baseDir = '\\ad.monash.edu\home\User043\tyan0042\Documents\Computer Vision';
FileName = 'web_cap';
newName = fullfile(baseDir, sprintf('%s.jpg',FileName));
imwrite(img,newName);

%% Video capture by webcam
for frames = 1:30
   img = snapshot(cam);
   imshow(img);
end

%% Object classification by a pre-trained neural network
nnet = googlenet;
for i = 1:250
   img = snapshot(cam);
   img = imresize(img,[224 224]);
   [label, score] = classify(nnet, img);
   imshow(img);
   title({char(label),num2str(max(score),2)});
end