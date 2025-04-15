function I = Boundary_Validation(H,offset,opt)
    %%%
    % H: Entropy value matrix for the image
    % offset: location (row/col) of the detected boundary
    % opt: 1: verify vertical boundary; 2: verify horizontal boundary
    H_avg = mean(mean(H));
    H_max = max(max(H));
    thre = 5;
    [r,c] = size(H);
    if opt == 1
        if offset - thre <= 0
            xl = 1;
        else
            xl = offset - thre;
        end
        if offset + thre >= c
            xu = c;
        else
            xu = offset + thre;
        end
        if mean(mean(H(:,xl:xu))) > H_avg
            I = 1;
        else
            I = 0;
        end
    else
        if offset - thre <= 0
            yl = 1;
        else
            yl = offset - thre;
        end
        if offset + thre >= r
            yu = r;
        else
            yu = offset + thre;
        end
        if mean(mean(H(yl:yu,:)')) > 0.6*H_max
            I = 1;
        else
            I = 0;
        end
    end
end