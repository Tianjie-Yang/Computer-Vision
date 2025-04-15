function [c,r] = BGF(H,factor,thre,flag)
%%% BDF: Background flitering
% Input: H: Local Entropy matrix
% factor: lower and upper boundary for background flitering
% thre: Threshold of the local entropy
% flag (opt): flitering on/off?
%%%
    Avg = mean(mean(H));
    [col,row] = size(H);
    if Avg < max(max(H))*thre
        fprintf("Lab environment! Homogenous Region (Low Entropy Area) is considered as a background.\n");
        [c,r] = find(H > max(max(H))*factor(2));
    else
        fprintf('Construction site! Non-homogenous Region (High Entropy Area) is considered as a background.\n');
        [c,r] = find(H < max(max(H))*factor(1));
    end
    % Flitering is ON
   if nargin == 4 && flag == 1
        idx1 = c > 0.1*col & c < 0.9*col;
        idx2 = r > 0.1*row & r < 0.9*row;
        c = c(idx1 & idx2);
        r = r(idx1 & idx2);
    end
end