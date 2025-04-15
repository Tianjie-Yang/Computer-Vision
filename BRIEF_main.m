sigma = [5 10];
figure;
n = 512;
N = zeros(size(sigma));
for k = 1:length(sigma)
    e_vec = zeros(length(critical_point),n);
    for i = 1:length(critical_point)
        mu_x = critical_point(i,2);
        mu_y = critical_point(i,1);
       [e_vec(i,:)] = BRIEF(grey_pixel,[mu_x mu_y],sigma(k),n);
    end

    [N(k),e_vec_unique] = check_repeat(e_vec);
    fprintf('We have %d repeated eig-vector when sigma is %d.\n',N(k),sigma(k));
end
plot(sigma, N);
xlabel('sigma');
ylabel('No. Repeat');