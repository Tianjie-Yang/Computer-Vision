function cp = critical_point_pick_up(grey_pixel_Matrix,threshold,f_density,x_c,y_c,offset_x,offset_y)
%%% 
    % Input parameters:
    % grey_pixel_Matrix: Average RGB value (grey picture)
    % threshold: Maximum pixel intensity that allowed
    % f_density: Density Cloud function
    % x_c, y_c: CoM of a 2D picture
    % offset_x, offset_y: The code will still work if only a small portion
    %                     of the picuture is picked for analysis
    % Output:
    % cp: localtion of critical points (contains 2 columns)
%%%
    [row,col] = size(grey_pixel_Matrix); % Read the size of the grey pixel matrix
    cp = [];                             % Initialise an empty matrix to store the location of the cp
    idx = 1;                             % Tracker of the No.cp
    
    % Apply a 'circle mask' across the grey pixel matrix
    for i = 4:row-3 % Do NOT exceed the boundary of the matrix
        for j = 4:col-3
            count = 0; % Reset the counter to 0 for every pixel we check
            std = grey_pixel_Matrix(i,j); % Pick up the pixel at the entre of the mask (circle)
            
            x_eq = j + offset_y;
            y_eq = i + offset_x;
            new_thre = f_density(abs(x_eq-y_c),abs(y_eq-x_c),1/(col/2))*threshold;
            % Check the intendity of the surrending pixels
            if abs(std - grey_pixel_Matrix(i-3,j)) > new_thre
               count = count + 1; 
            end
            
            if abs(std - grey_pixel_Matrix(i,j+3)) > new_thre
                count = count + 1; 
            else
                count = 0;
            end
            
            if abs(std - grey_pixel_Matrix(i-3,j)) > new_thre && count ~= 2
                count = count + 1; 
            else
                count = 0;
            end
            
            if abs(std - grey_pixel_Matrix(i,j-3)) > new_thre && count ~= 2
                count = count + 1; 
            else 
                count = 0;
            end
            
            % Determine whether the centre pixel is the critical pixel
            if count == 2
                % If so, store the location of the pixel into cp matrix
               cp(idx,:) = [i,j];
               idx = idx + 1; % Update the index number
            end
        end
    end
end