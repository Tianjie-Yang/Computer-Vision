clear all; close all; clc;

%% 
magnificationFactor = [0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5];
format = 'High-Rise Building window1_%s.jpg';

for i = 1:length(magnificationFactor)
   filename = sprintf(format,num2str(i));
   L = imread(filename);
   [height(i),width(i),~] = size(L);
%    if magnificationFactor(i) == 1.0
%        % Set the factor to extract part of the picture
%         lower_BC = 600/height(i);
%         upper_BC = 800/height(i);
%    end
end

lower_BC = 0.1; upper_BC = 0.9;
patch_size = 7; STD_thre = 20; relaxation_coe = 20*0.2695;
Num_cp = zeros(1,length(magnificationFactor));
tic;
fprintf('Processing the image...\n');
for j = 1:length(magnificationFactor)
    filename = sprintf(format,num2str(j));
    Num_cp(j) = Combined_ORB_entropy2(filename,lower_BC,upper_BC,@critical_point_pick_up_16_single,@BRIEF,patch_size,STD_thre,relaxation_coe);
end
toc;
%%
figure;
factor = magnificationFactor(1):0.01:magnificationFactor(end);
coe2 = polyfit(magnificationFactor,Num_cp,1);
Num_cp_fit = polyval(coe2,factor);
plot(factor,Num_cp_fit); hold on;
plot(magnificationFactor,Num_cp,'bo');
xlabel('Magnification Factor');
ylabel('No. non-repeating critical points');

%%
St = sum((Num_cp - mean(Num_cp)).^2);
Sr = sum((Num_cp - polyval(coe2,magnificationFactor)).^2);
r22 = abs(St - Sr)/St; % Coefficient of Determintion: Around 0.9546 without removing the duplicated critical points.
