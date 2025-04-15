function cp_check = critical_point_pick_up_16_single(grey_pixel_Matrix,x_c,y_c,threshold)
%%% 
    % Input parameters:
    % grey_pixel_Matrix: Average RGB value (grey picture)
    % x_c: central pixel x-coordinate
    % y_c: central pixel y_coordinate
    % threshold: Maximum pixel intensity that allowed
    
    % Output:
    % cp: (Bool) logical return: whether the target pixel is a cp
%%%
    [row,col] = size(grey_pixel_Matrix); % Read the size of the grey pixel matrix
    cp_check = 0;                        % Initialise an empty matrix to store the location of the cp
    
    if x_c < 4 || x_c > row - 4
       cp_check = 0; 

    elseif y_c < 4 || y_c > col - 4
       cp_check = 0; 
    else
        % Apply a 'circle mask' across the grey pixel matrix

        count = 0; % Reset the counter to 0 for every pixel we check
        std = grey_pixel_Matrix(x_c,y_c); % Pick up the pixel at the entre of the mask (circle)

        % Check the intendity of the surrending pixels
        if abs(std - grey_pixel_Matrix(x_c-3,y_c)) > threshold
           count = count + 1; 
        end

        % 2
        if abs(std - grey_pixel_Matrix(x_c-3,y_c+1)) > threshold
           count = count + 1;
        else
           count = 0;
        end

        % 3
        if abs(std - grey_pixel_Matrix(x_c-2,y_c+2)) > threshold
           count = count + 1; 
        else
           count = 0;
        end

        % 4
        if abs(std - grey_pixel_Matrix(x_c-1,y_c+3)) > threshold
           count = count + 1;
        else
           count = 0;
        end

        if abs(std - grey_pixel_Matrix(x_c,y_c+3)) > threshold
            count = count + 1; 
        else
            count = 0;
        end

        % 6
        if abs(std - grey_pixel_Matrix(x_c+1,y_c+3)) > threshold
           count = count + 1; 
        else
           count = 0;
        end

        % 7
        if abs(std - grey_pixel_Matrix(x_c+2,y_c+2)) > threshold
           count = count + 1; 
        else
           count = 0;
        end

        % 8
        if abs(std - grey_pixel_Matrix(x_c+3,y_c+1)) > threshold
           count = count + 1; 
        else
           count = 0;
        end

        if abs(std - grey_pixel_Matrix(x_c+3,y_c)) > threshold && count ~= 8
            count = count + 1; 
        elseif abs(std - grey_pixel_Matrix(x_c+3,y_c)) <= threshold && count ~= 8
            count = 0;
        end

        % 10
        if abs(std - grey_pixel_Matrix(x_c+3,y_c-1)) > threshold && count ~= 8
           count = count + 1; 
        elseif abs(std - grey_pixel_Matrix(x_c+3,y_c-1)) <= threshold && count ~= 8
           count = 0;
        end

        % 11
        if abs(std - grey_pixel_Matrix(x_c+2,y_c-2)) > threshold && count ~= 8
           count = count + 1; 
        elseif abs(std - grey_pixel_Matrix(x_c+2,y_c-2)) <= threshold && count ~= 8
           count = 0;
        end

        % 12
        if abs(std - grey_pixel_Matrix(x_c+1,y_c-2)) > threshold && count ~= 8
           count = count + 1; 
        elseif abs(std - grey_pixel_Matrix(x_c+1,y_c-2)) <= threshold && count ~= 8
           count = 0;
        end

        if abs(std - grey_pixel_Matrix(x_c,y_c-3)) > threshold && count ~= 8
            count = count + 1; 
        elseif abs(std - grey_pixel_Matrix(x_c,y_c-3)) <= threshold && count ~= 8
           count = 0;
        end

        % 14
        if abs(std - grey_pixel_Matrix(x_c-1,y_c-3)) > threshold && count ~= 8
           count = count + 1; 
        elseif abs(std - grey_pixel_Matrix(x_c-1,y_c-3)) <= threshold && count ~= 8
           count = 0;
        end

        % 15
        if abs(std - grey_pixel_Matrix(x_c-2,y_c-2)) > threshold && count ~= 8
           count = count + 1; 
        elseif abs(std - grey_pixel_Matrix(x_c-2,y_c-2)) <= threshold && count ~= 8
           count = 0;
        end

        % 16
        if abs(std - grey_pixel_Matrix(x_c-3,y_c-1)) > threshold && count ~= 8
           count = count + 1; 
        elseif abs(std - grey_pixel_Matrix(x_c-3,y_c-1)) <= threshold && count ~= 8
           count = 0;
        end

        % Determine whether the centre pixel is the critical pixel
        if count == 8
            % If so, store the location of the pixel into cp matrix
           cp_check = 1;
        end
    end
end