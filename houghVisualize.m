function houghVisualize(H,T,R)
    % H: Transformation matrix
    % T: theta
    % R: rho
    H_grey = mat2gray(H);
    H_grey = imadjust(H_grey); % Enhancing the brightness

    imshow(H_grey,'XData',T,'YData',R);
    hold on;

    axis on; axis normal;
    colormap(hot);
    title('Hough Transformation');

    xlabel('\theta');
    ylabel('\rho');
end