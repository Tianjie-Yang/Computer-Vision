function Num_cp = Combined_ORB_entropy2(filename,lower_BC,upper_BC,FAST,BRIEF,patch_size,STD_thre,relaxation_coe)
    %%%
    % Input parameters:
    % filename: (string) The image filename to be analyzed
    % lower_BC: (float number) lower percentage BC of the row
    % upper_BC: (float number) upper percentage BC of the row
    % patch_size: (int) The length of the pixel patch
    % FAST: (func handle) User can choose whether to use FAST4 or FAST16
    % BRIEF: (func handle) BRIEF algorithm function handle to remove
    %                      duplicated critical points
    % STD_thre: (int) Standard pixel threshold in FAST algorithm
    % relaxation_coe: (int) Additional pixel threshold to be added for cp
    %                       check
    % Output parameters:
    % Num_cp: (int) Number of non-repeating critical points
    %%%
    img = imread(filename);
    [Grey_pixel,h,~] = RGB2Grey(filename);
    grey_pixel_part = Grey_pixel(h*lower_BC:h*upper_BC,:);
    [~,~,H] = entropy_patch_based(filename,lower_BC,upper_BC,patch_size);
    H_max = max(max(H));
    H_min = min(min(H));
    % Find linear relation between H range and 0~1 percentage range.
    % Percentage = P * H + Q
    P = 1/(H_min - H_max);
    Q =  -P*H_max;
    Percentage = @(H) P * H + Q;
    threshold = @(H) STD_thre + Percentage(H)*relaxation_coe;
    [Row,Col] = size(H);
    cp = [];
    count = 1; sigma = 3; n = 256;
    for i = 1+(patch_size-1)/2:Row-(patch_size-1)/2
       for j = 1+(patch_size-1)/2:Col-(patch_size-1)/2
           thre = threshold(H(i,j));
           cp_check = FAST(grey_pixel_part,i,j,thre);
           if cp_check
              cp(count,:) = [(i + h*lower_BC) j];
              count = count + 1;
           end
       end
    end
    
    for q = 1:length(cp)
        [e_vec(q,:)] = BRIEF(grey_pixel_part,[cp(q,2) cp(q,1)-h*lower_BC],sigma,n);
    end
    [~,e_vec_unique] = check_repeat(e_vec);
    [row,~] = size(e_vec_unique);
    Num_cp = row;
end