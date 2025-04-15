clear all; close all; clc;
a = zeros(50,50); % Create a 50x50 patch
a(20,20) = 1;
a(30,15) = 1;
a(40,10) = 1;
a(30,40) = 1; % Noise pixel
imshow(a);

y_coor = [20 30 30 40];
x_coor = [20 15 40 10];
k = [];
b = [];
Num_point = [];
x_con = 0:0.01:50;
sigma = 2;
case_num = 1;
for i = 1:length(x_coor)-1
   for j = i+1:length(y_coor)
      x_test = [x_coor(i) x_coor(j)];
      y_test = [y_coor(i) y_coor(j)];
      coefficient = polyfit(x_test,y_test,1);
      k(case_num) = coefficient(1);
      b(case_num) = coefficient(2);
      case_num = case_num + 1;
   end
end

for q = 1:length(k)
   cont = 0;
   y_fit = @(x) k(q)*x + b(q);
   for a = 1:length(x_coor)
       [L] = LineDist(y_fit,[x_coor(a) y_coor(a)]);
       if L < sigma
            cont = cont + 1;
       end
   end
   Num_point(q) = cont;
end

[max_num,~] = max(Num_point)
index = find(Num_point == max_num);

k_fix = k(index(1));
b_fix = b(index(2));
hold on;
plot(x_con,k_fix*x_con+b_fix,'r-');
