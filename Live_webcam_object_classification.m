clear all;
close all;
clc;

webcamlist
cam = webcam(1);
nnet = googlenet;

input_size = nnet.Layers(1).InputSize([1 2]); % 224 224

c = figure;

% c.WindowState = 'fullscreen';

while ishandle(c)
   a = subplot(1,2,1);
   img = snapshot(cam);
   image(img);
   img = imresize(img, input_size);
   
   [Predicted_name, probability] = classify(nnet ,img);
   title({char(Predicted_name),num2str(max(probability),2)});
   drawnow % Update figure windows
   
   b = subplot(1,2,2);
   [~,idx] = sort(probability,'descend');
   index = idx(5:(-1):1); % Extract the probabilities ranking in the first 5 places
   classes = nnet.Layers(end).Classes;
   classNameTop = string(classes(index));
   scoreTop = probability(index);
   barh(b,scoreTop);
   xlim(b,[0 1]);
   title(b,'TOP 5 Prediction');
   yticklabels(b,classNameTop);
   b.YAxisLocation = 'right';
end