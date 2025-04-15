function cp = critical_point_pick_up_4(grey_pixel_Matrix,threshold)
%%% 
    % Input parameters:
    % grey_pixel_Matrix: Average RGB value (grey picture)
    % threshold: Maximum pixel intensity that allowed
    
    % Output:
    % cp: localtion of critical points (contains 2 columns)
%%%
    grey_pixel_Matrix = im2double(grey_pixel_Matrix)*255;
    [row,col] = size(grey_pixel_Matrix); % Read the size of the grey pixel matrix
    cp = [];                             % Initialise an empty matrix to store the location of the cp
    idx = 1;                             % Tracker of the No.cp
    
    % Apply a 'circle mask' across the grey pixel matrix
    for i = 4:row-3 % Do NOT exceed the boundary of the matrix
        for j = 4:col-3
            count = 0; % Reset the counter to 0 for every pixel we check
            std = grey_pixel_Matrix(i,j); % Pick up the pixel at the entre of the mask (circle)
%             if i == 35 && j == 30
            % Check the intendity of the surrending pixels
            if abs(std - grey_pixel_Matrix(i-3,j)) > threshold
               count = count + 1; 
            end
            
            if abs(std - grey_pixel_Matrix(i,j+3)) > threshold && count ~= 2
                count = count + 1; 
            elseif abs(std - grey_pixel_Matrix(i,j+3)) <= threshold && count ~= 2
                count = 0;
            end
            
            if abs(std - grey_pixel_Matrix(i+3,j)) > threshold && count ~= 2
                count = count + 1; 
            elseif abs(std - grey_pixel_Matrix(i+3,j)) <= threshold && count ~= 2
                count = 0;
            end
            
            if abs(std - grey_pixel_Matrix(i,j-3)) > threshold && count ~= 2
                count = count + 1; 
            elseif abs(std - grey_pixel_Matrix(i,j-3)) <= threshold && count ~= 2
                count = 0;
            end
            
            % Determine whether the centre pixel is the critical pixel
            if count == 2
                % If so, store the location of the pixel into cp matrix
               cp(idx,:) = [i,j];
               idx = idx + 1; % Update the index number
            end
%             end
        end
    end
end