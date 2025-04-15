function [L] = LineDist(y,p)
    % y: Function handle
    % p: point location
    x1 = 1;
    x2 = 2;
    k = (y(x2) - y(x1))/(x2 - x1);
    L = abs(y(p(:,1)) - p(:,2))/sqrt(1 + k^2);
end