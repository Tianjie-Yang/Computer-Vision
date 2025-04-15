function cp = critical_point_pick_up_16(grey_pixel_Matrix,threshold)
%%% 
    % Input parameters:
    % grey_pixel_Matrix: Average RGB value (grey picture)
    % threshold: Maximum pixel intensity that allowed
    
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
            
            % Check the intendity of the surrending pixels
            if abs(std - grey_pixel_Matrix(i-3,j)) > threshold
               count = count + 1; 
            end
            
            % 2
            if abs(std - grey_pixel_Matrix(i-3,j+1)) > threshold
               count = count + 1;
            else
               count = 0;
            end
            
            % 3
            if abs(std - grey_pixel_Matrix(i-2,j+2)) > threshold
               count = count + 1; 
            else
               count = 0;
            end
            
            % 4
            if abs(std - grey_pixel_Matrix(i-1,j+3)) > threshold
               count = count + 1;
            else
               count = 0;
            end
            
            if abs(std - grey_pixel_Matrix(i,j+3)) > threshold
                count = count + 1; 
            else
                count = 0;
            end
            
            % 6
            if abs(std - grey_pixel_Matrix(i+1,j+3)) > threshold
               count = count + 1; 
            else
               count = 0;
            end
            
            % 7
            if abs(std - grey_pixel_Matrix(i+2,j+2)) > threshold
               count = count + 1; 
            else
               count = 0;
            end
            
            % 8
            if abs(std - grey_pixel_Matrix(i+3,j+1)) > threshold
               count = count + 1; 
            else
               count = 0;
            end
            
            if abs(std - grey_pixel_Matrix(i+3,j)) > threshold && count ~= 8
                count = count + 1; 
            else%if abs(std - grey_pixel_Matrix(i+3,j)) <= threshold && count ~= 8
                count = 0;
            end
            
            % 10
            if abs(std - grey_pixel_Matrix(i+3,j-1)) > threshold && count ~= 8
               count = count + 1; 
            else%if abs(std - grey_pixel_Matrix(i+3,j-1)) <= threshold && count ~= 8
               count = 0;
            end
            
            % 11
            if abs(std - grey_pixel_Matrix(i+2,j-2)) > threshold && count ~= 8
               count = count + 1; 
            else%if abs(std - grey_pixel_Matrix(i+2,j-2)) <= threshold && count ~= 8
               count = 0;
            end
            
            % 12
            if abs(std - grey_pixel_Matrix(i+1,j-2)) > threshold && count ~= 8
               count = count + 1; 
            else%if abs(std - grey_pixel_Matrix(i+1,j-2)) <= threshold && count ~= 8
               count = 0;
            end
            
            if abs(std - grey_pixel_Matrix(i,j-3)) > threshold && count ~= 8
                count = count + 1; 
            else%if abs(std - grey_pixel_Matrix(i,j-3)) <= threshold && count ~= 8
               count = 0;
            end
            
            % 14
            if abs(std - grey_pixel_Matrix(i-1,j-3)) > threshold && count ~= 8
               count = count + 1; 
            else%if abs(std - grey_pixel_Matrix(i-1,j-3)) <= threshold && count ~= 8
               count = 0;
            end
            
            % 15
            if abs(std - grey_pixel_Matrix(i-2,j-2)) > threshold && count ~= 8
               count = count + 1; 
            else%if abs(std - grey_pixel_Matrix(i-2,j-2)) <= threshold && count ~= 8
               count = 0;
            end
            
            % 16
            if abs(std - grey_pixel_Matrix(i-3,j-1)) > threshold && count ~= 8
               count = count + 1; 
            else%if abs(std - grey_pixel_Matrix(i-3,j-1)) <= threshold && count ~= 8
               count = 0;
            end
            
            % Determine whether the centre pixel is the critical pixel
            if count == 8
                % If so, store the location of the pixel into cp matrix
               cp(idx,:) = [i,j];
               idx = idx + 1; % Update the index number
            end
        end
    end
end