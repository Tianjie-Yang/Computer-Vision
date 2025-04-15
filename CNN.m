clear all;
close all;
clc;

%% Import numerical data set for training
digitDatasetPath = fullfile(matlabroot,'toolbox','nnet','nndemos','nndatasets','DigitDataset');
imds = imageDatastore(digitDatasetPath,'IncludeSubfolders',true,'LabelSource','foldernames');

%% Set 60% for training, 20% for validation and 20% for testing
fracTrainFiles = 0.6;
fracValFiles = 0.2;
fracTestFiles = 0.2;
[imdsTrain, imdsValidation, imdsTest] = splitEachLabel(imds, fracTrainFiles, fracValFiles, ...
    fracTestFiles, 'randomize');

%% Set up a couple of layers for training
layers = [
    imageInputLayer([28 28 1])  % Set up 28 pixel by 28 pixle for each individual fliter
    
    convolution2dLayer(3,10,'Padding','same') % Narrow down the size of fliter to 3x3
    batchNormalizationLayer
    reluLayer
    
    maxPooling2dLayer(2,'Stride',2)
    
    convolution2dLayer(3,10,'Padding','same')
    batchNormalizationLayer
    reluLayer
    
    fullyConnectedLayer(10)
    softmaxLayer
    classificationLayer]; 

%% Do the training
options = trainingOptions('sgdm',...
    'InitialLearnRate',0.01,...
    'MaxEpochs',50,...
    'Shuffle','every-epoch',...
    'ValidationData',imdsValidation,...
    'ValidationFrequency',30,...
    'Verbose',false,...
    'Plots','training-progress');

net = trainNetwork(imdsTrain,layers,options);

%% Calculate the Accuracy
YPred = classify(net,imdsTest);
YTest = imdsTest.Labels;

accuracy = sum(YPred == YTest)/numel(YTest)

%% Identify some mis-recognition during the test
ind = find(YPred ~= YTest);
length(ind)
pause;
figure;
for ii = 1:7
   subplot(3,3,ii);
   %Display the image with the scaled colors
   imagesc(imdsValidation.readimage(ind(ii)));
   title([num2str(double(YPred(ind(ii)))-1), ' predicted, ',...
       num2str(double(YTest(ind(ii)))-1), ' actual']);
end