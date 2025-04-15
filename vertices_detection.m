function [vx,vy] = vertices_detection(file_name,k_vertical,k_horizontal,b_vertical,b_horizontal,offset_vertical, offset_horizontal)
    vx = [];
    vy = [];
    if length(k_vertical) < 2 || length(k_horizontal) < 2 || length(b_vertical) < 2 || length(b_horizontal) < 2
       error("Boundary Detection Incomplete!\n"); 
    end
    figure;
    imshow(file_name);
    y_hori_top = @(x) k_horizontal(1)*x + b_horizontal(1) + offset_horizontal(1);
    y_hori_bot = @(x) k_horizontal(end)*x + b_horizontal(end) + offset_horizontal(end);
    % Left Corners
    if abs(b_vertical(1)) == Inf || abs(k_vertical(1)) == Inf
       x_verti_left = offset_vertical(1);
       hold on;
       plot(x_verti_left, y_hori_top(x_verti_left),"r*","Markersize",5);
       plot(x_verti_left, y_hori_bot(x_verti_left),"r*","Markersize",5);
       vx = [vx x_verti_left x_verti_left];
       vy = [vy y_hori_top(x_verti_left) y_hori_bot(x_verti_left)];
    else
        y_verti_left = @(x) k_vertical(1)*(x - offset_vertical(1)) + b_vertical(1);
        x_cor_idx1 = fzero(@(x) y_verti_left(x) - y_hori_top(x),100);
        x_cor_idx2 = fzero(@(x) y_verti_left(x) - y_hori_bot(x),100);
        hold on;
        plot(x_cor_idx1, y_hori_top(x_cor_idx1), "r*","Markersize",8);
        plot(x_cor_idx2, y_hori_bot(x_cor_idx2), "r*","Markersize",8);
        vx = [vx x_cor_idx1 x_cor_idx2];
        vy = [vy y_hori_top(x_cor_idx1) y_hori_bot(x_cor_idx2)];
    end
    
    % Right Corners
    if abs(b_vertical(end)) == Inf || abs(k_vertical(end)) == Inf
       x_verti_right = offset_vertical(end);
       hold on;
       plot(x_verti_right, y_hori_top(x_verti_right),"r*","Markersize",8);
       plot(x_verti_right, y_hori_bot(x_verti_right),"r*","Markersize",8);
       vx = [vx x_verti_right x_verti_right];
       vy = [vy y_hori_bot(x_verti_right) y_hori_top(x_verti_right)];
    else
        y_verti_left = @(x) k_vertical(end)*(x - offset_vertical(end)) + b_vertical(end);
        x_cor_idx1 = fzero(@(x) y_verti_left(x) - y_hori_top(x),100);
        x_cor_idx2 = fzero(@(x) y_verti_left(x) - y_hori_bot(x),100);
        hold on;
        plot(x_cor_idx1, y_hori_top(x_cor_idx1), "r*","Markersize",8);
        plot(x_cor_idx2, y_hori_bot(x_cor_idx2), "r*","Markersize",8);
        vx = [vx x_cor_idx2 x_cor_idx1];
        vy = [vy y_hori_bot(x_cor_idx2) y_hori_top(x_cor_idx1)];
    end
    x_CoM = mean(vx);
    y_CoM = mean(vy);
    plot(x_CoM,y_CoM,'bo');
    
    % Reveal the boundary
    plot([vx vx(1)],[vy vy(1)],'g-','Markersize',4);
end