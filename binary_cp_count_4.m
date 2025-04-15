function [cp] = binary_cp_count_4(binary_pix)
    [r,c] = size(binary_pix);
    cp = [];
    idx = 1;
    
    for i = 4:r-3
        for j = 4:c-3
            count = 0;
            std = binary_pix(i,j);
            
            % Check the intendity of the surrending pixels
            if std == 150
                if std ~= binary_pix(i-3,j)
                   count = count + 1; 
                end

                % 2
                if std ~= binary_pix(i+3,j)
                   count = count + 1;
                else
                   count = 0;
                end

                % 3
                if std ~= binary_pix(i,j+3) && count ~= 2
                   count = count + 1; 
                elseif count ~= 2
                   count = 0;
                end

                % 4
                if std ~= binary_pix(i,j-3) && count ~= 2
                   count = count + 1;
                elseif count ~= 2
                   count = 0;
                end
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