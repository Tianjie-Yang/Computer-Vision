clear all; close all; clc;

magnificationFactor = [0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5];
format = 'Environment%s.jpg';
width = zeros(1,5);
height = zeros(1,5);

figure;
for i = 1:length(magnificationFactor)
   filename = sprintf(format,num2str(i));
   L = imread(filename);
   [height(i),width(i),~] = size(L);
   if magnificationFactor(i) == 1.0
       % Set the factor to extract part of the picture
        lower_factor = 600/height(i);
        upper_factor = 800/height(i);
   end
end

Num_pixel = width.*height;
coe = polyfit(magnificationFactor,Num_pixel,1);
factor = magnificationFactor(1):0.01:magnificationFactor(end);
Num_pixel_fit = polyval(coe,factor);
yyaxis left;
plot(factor,Num_pixel_fit); hold on;
plot(magnificationFactor, Num_pixel,'r*');
xlabel('Magnification Factor of the picture');
ylabel('Toal number of the pixels in the picture');

%%
Num_critical_points = zeros(1,length(magnificationFactor)); % Pre-allocatgion
thre = 20;
patch_size = 3;
for j = 1:length(magnificationFactor)
    filename = sprintf(format,num2str(j));
    [grey_pixel,h,~] = RGB2Grey(filename);
    [r_abs,c_abs,~] = entropy_patch_based(filename,lower_factor,upper_factor,patch_size);
    grey_pixel_part = grey_pixel(lower_factor*h:upper_factor*h,:);
    count = 1;
    for i = 1:length(r_abs)
       cp_check = critical_point_pick_up_16_single(grey_pixel_part,round(r_abs(i)-h*lower_factor),c_abs(i),thre);
       if cp_check
           cp(count,:) = [r_abs(i) c_abs(i)];
           Num_critical_points(j) = Num_critical_points(j) + 1;
           count = count + 1;
       end
    end
    figure;
    imshow(filename);
    hold on;
    plot(cp(:,2),round(cp(:,1)),'r*'); % Update the lower Boundary!
end

%%
coe2 = polyfit(magnificationFactor,Num_critical_points,1);
Num_cp_fit = polyval(coe2,factor);
yyaxis right
plot(factor,Num_cp_fit); hold on;
plot(magnificationFactor,Num_critical_points,'bo');
ylabel('No. critical points');

%% Error Test (without removiong the duplicated critical point)
St = sum((Num_critical_points - mean(Num_critical_points)).^2);
Sr = sum((Num_critical_points - polyval(coe2,magnificationFactor)).^2);
r2 = abs(St - Sr)/St; % Coefficient of Determintion: Around 0.8803 without removing the duplicated critical points.

%% Remove the duplicated critical point using BRIEF algorithm
sigma = 3; n = 256; % Length of the e-vector
for k = 1:length(magnificationFactor)
    filename = sprintf(format,num2str(j));
    [grey_pixel,h,~] = RGB2Grey(filename);
    [r_abs,c_abs] = entropy_patch_based(filename,lower_factor,upper_factor,patch_size);
    grey_pixel_part = grey_pixel(lower_factor*h:upper_factor*h,:);
    count = 1;
    for i = 1:length(r_abs)
       cp_check = critical_point_pick_up_16_single(grey_pixel_part,round(r_abs(i)-h*lower_factor),c_abs(i),thre);
       if cp_check
           cp(count,:) = [r_abs(i) c_abs(i)];
           Num_critical_points(j) = Num_critical_points(j) + 1;
           count = count + 1;
       end
    end
    for q = 1:length(cp)
        [e_vec(q,:)] = BRIEF(grey_pixel_part,[cp(q,2) cp(q,1)-h*lower_factor],sigma,n);
    end
    [~,e_vec_unique] = check_repeat(e_vec);
    [row,~] = size(e_vec_unique);
    Num_critical_points(k) = row;
end

%%
figure;
coe3 = polyfit(magnificationFactor,Num_critical_points,1);
Num_cp_fit = polyval(coe3,factor);
plot(factor,Num_cp_fit); hold on;
plot(magnificationFactor,Num_critical_points,'bo');
