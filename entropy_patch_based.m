function [r_abs,c_abs,H] = entropy_patch_based(filename,low_thre,high_thre,patch_size)
%%%
    % Inputs:
    % filename: (string) Image to be analysis
    % low_thre: (float number) Lower threshold of the image to be analyzed.
    % high_thre: (float number) Higher threshold of the image to be
    %                           analzed.
    % patch_size: (int) Can only take 3,5,7,... 
    % Outputs:
    % r_abs: The absolute row location of the CP based on entropy method
    % c_abs: The absolute column location of the CP based on entropy method
    % H: Local entropy 2D matrix
%%%
    
    % Check the patch size
    if patch_size == 1 || mod(patch_size,2) == 0
       error('Invalid patch size! The patch should be square and central symmetrical!'); 
    end
    
    img = imread(filename);
    [r,c,~] = size(img);
    
    r_BC_low = round(r*low_thre); r_BC_high = round(r*high_thre);
    H_r = r_BC_high - r_BC_low - patch_size + 1;
    H_c = c - patch_size;
    H = zeros(H_r, H_c);
    
    x_idx = 1;
    for i = r_BC_low + (patch_size-1)/2 : r_BC_high - (patch_size-1)/2
        y_idx = 1;
        for j = 1 + (patch_size-1)/2 : c - (patch_size-1)/2
            H(x_idx,y_idx) = entropy(img(i-(patch_size-1)/2:i+(patch_size-1)/2,j-(patch_size-1)/2:j+(patch_size-1)/2,:));
            y_idx = y_idx + 1;
        end
        x_idx = x_idx + 1;
    end
    
    factor = 0.95;
    [r_abs,c_abs] = find(H > factor*max(H));
    r_abs = r_abs + r_BC_low;
end