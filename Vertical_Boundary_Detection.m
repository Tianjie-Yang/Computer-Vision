function [k,b,offset] = Vertical_Boundary_Detection(filename,H_entropy,H_Binary,dp,slope_limit)
    %%%
    % filename: Name of the photo
    % H_entropy: The original entropy matrix used to filter the undesired
    % boundary
    % H_Binary:Binary pixel matrix from Entropy method
    % dp:Width of the pixel patch
    % slope_limit: slope constrain for the boundary
    %%%
    [r,c] = size(H_Binary);
    left_Bound = 1;
    flag = 0;
    k = [];
    b = [];
    offset = [];
    cnt = 1;
    while left_Bound + dp < c
        %imshow(filename); hold on;
        right_Bound = left_Bound + dp;
        %plot([left_Bound right_Bound right_Bound left_Bound left_Bound],[1 1 r r 1],'r-','Markersize',4);
        Binary_Patch = H_Binary(1:r,left_Bound:right_Bound);
        x_offset = left_Bound;
        [H,T,R] = hough(Binary_Patch);
        hPeaks = houghpeaks(H);
        theta = T(hPeaks(:,2));
        rho = R(hPeaks(:,1));
        slope = -cotd(theta);
%         fprintf("Current slope is %.3f\n",slope);
        if abs(slope) < slope_limit
%            fprintf("No valid vertical boundary is observed!\n");
           flag = 0;
        else
            if flag == 0
                y = @(theta,rho,x) -cotd(theta)*(x - x_offset/0.6) + rho/sind(theta)/0.6;
                x = left_Bound-100:0.01:right_Bound+100;
                if Boundary_Validation(H_entropy,round(x_offset/0.6),1)
                    k(cnt) = -cotd(theta);
                    b(cnt) = rho/sind(theta)/0.6;
                    offset(cnt) = x_offset/0.6;
                    cnt = cnt + 1;
%                     plot(x,y(theta,rho,x),'b-','Linewidth',3);
%                     fprintf("A valid boundary is observed!\n");
                    flag = 1;
                else
%                     fprintf("Boundary Test failed.\n");
                end
            else
%                 fprintf("Duplicated Boundary detected!\n");
                flag = 0;
            end
        end
        left_Bound = left_Bound + dp;
        %hold off;
%         pause(1);
    end
    figure;
    imshow(filename);
    hold on;
    for m = 1:2
        if m == 1
            if k(1) == Inf || k(1) == -Inf
                plot([offset(1), offset(1)],[1,r/0.6],'b-','Linewidth',3);
            else
                y = @(x) k(1)*(x - offset(1)) + b(1);
                x_bond = offset(1)-100:0.01:offset(1)+dp+100;
                plot(x_bond,y(x_bond),'b-','Linewidth',3);
            end
        else
            if k(end) == Inf || k(end) == -Inf
                plot([offset(end) + dp/2, offset(end) + dp/2],[1,r/0.6],'b-','Linewidth',3);
            else
                y = @(x) k(end)*(x - offset(end)) + b(end);
                x_bond = offset(end)-100:0.01:offset(end)+dp+100;
                plot(x_bond,y(x_bond),'b-','Linewidth',3);
            end
        end
    end
%     for m = 1:length(k)
%        y = @(x) k(m)*(x - offset(m)) + b(m);
%        x_bond = offset(m)-100:0.01:offset(m)+dp+100;
%        plot(x_bond,y(x_bond),'b-','Linewidth',3);
%     end
end