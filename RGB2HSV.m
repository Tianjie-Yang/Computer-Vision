function [H,S,V] = RGB2HSV(R,G,B)
    R = R/255;
    G = G/255;
    B = B/255;
    
    Cmax = max([R,G,B]);
    Cmin = min([R,G,B]);
    deltaC = Cmax - Cmin;
    
    % Determine the value of H (deg)
    if Cmax == R
        H = 60*mod((G - B)/deltaC,6);
    elseif Cmax == G
        H = 60*((B - R)/deltaC + 2);
    elseif Cmax == B
        H = 60*((R - G)/deltaC + 4);
    elseif deltaC == 0
        H = 0;
    end
    
    % Determine the saturation value
    if Cmax == 0
        S = 0;
    else
        S = deltaC/Cmax;
    end
    S = S*100;
    
    % Determine the value of V
    V = Cmax*100;
end