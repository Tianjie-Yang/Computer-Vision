function [k, b, offset] = Horizontal_Boundary_Detection(filename, H_entropy ,H_Binary, dp, slope_limit)
    %%%
    % filename: Name of the photo
    % H_Binary:Binary pixel matrix from Entropy method
    % dp:Width of the pixel patch
    % slope_limit: slope constrain for the boundary
    %%%
    [r,c] = size(H_Binary);
    top_Bound = 1;
    flag = 0;
    k = [];
    b = [];
    offset = [];
    cnt = 1;
    while top_Bound + dp < r
        % Test
        imshow(filename); hold on;
        % Test
        bottom_Bound = top_Bound + dp;
        % Test
        plot([1 c/0.6 c/0.6 1 1],[top_Bound/0.6 top_Bound/0.6 bottom_Bound/0.6 bottom_Bound/0.6 top_Bound/0.6],'r-','Markersize',4);
        % Test
        Binary_Patch = H_Binary(top_Bound:bottom_Bound, 1:c);
        y_offset = top_Bound;
        [H,T,R] = hough(Binary_Patch);
        hPeaks = houghpeaks(H);
        theta = T(hPeaks(:,2));
        rho = R(hPeaks(:,1));
        slope = -cotd(theta);
        %fprintf("Current slope is %.3f\n",slope);
        if abs(slope) > slope_limit
           %fprintf("No valid vertical boundary is observed!\n");
           flag = 0;
        else
            if flag == 0
                % Test
                y = @(theta,rho,x) -cotd(theta)*x + rho/sind(theta) + y_offset/0.6;
                x = 0:0.01:c;
                % Test
               if Boundary_Validation(H_entropy,y_offset/0.6,2)
                    k(cnt) = -cotd(theta);
                    b(cnt) = rho/sind(theta);
                    offset(cnt) = y_offset/0.6;
                    cnt = cnt + 1;
                    % Test
                    plot(x,y(theta,rho,x),'b-','Linewidth',3);
                    % Test
                    %fprintf("A valid boundary is observed!\n");
                    flag = 1;
                else
                   %fprintf("Boundary test failed!\n")
                end
            else
                %fprintf("Duplicated Boundary detected!\n");
                flag = 0;
            end
        end
        top_Bound = top_Bound + dp;
        % Test
        hold off;
        pause(.5);
        % Test
    end
    figure;
    imshow(filename);
    hold on;
    for m = 1:2
       if m == 1
           y = @(x) k(1)*x + b(1) + offset(1);
           x_bond = 0:0.01:c;
           plot(x_bond,y(x_bond),'b-','Linewidth',3);
       else
           y = @(x) k(end)*x + b(end) + offset(end);
           x_bond = 0:0.01:c;
           plot(x_bond,y(x_bond),'b-','Linewidth',3);
       end
    end
end