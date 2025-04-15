function [e_vec] = BRIEF(Grey_pix,p,sigma,n)
%%%
    % Function Input:
    % p: coordinate of the critical point (nx1)
    % n: The length of the e_vector (Between 128 - 256)
    
    % Function Output:
    % e_vec: length(p)-by-n, for each critical point
%%%
[BC_y, BC_x] = size(Grey_pix);
p = round(p);
x_c = p(1); y_c = p(2);
mu_x = x_c; mu_y = y_c;
e_vec = zeros(1,n);

for i = 1:n
    [mu_x,mu_y,sigma] = Gaussian_ran_generator(mu_x,mu_y,sigma,BC_x,BC_y);
    %%% TEST
%     fprintf('%.2f %.2f\n',y,x);
%     fprintf('%.2f %.2f\n',y_c,x_c);
    %%%
    if Grey_pix(mu_y,mu_x) > Grey_pix(y_c,x_c)
        e_vec(i) = 1;
    %%% TEST
%         fprintf('%.2f %.2f\n',y,x);
%         fprintf('%.2f %.2f\n',y_c,x_c);
    %%% TEST
    end
end