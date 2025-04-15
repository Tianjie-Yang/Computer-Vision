function [N,e_vec_unique] = check_repeat(e_vec)
    [r,~] = size(e_vec);
    e_vec_unique = [];
    n = 1;
    for i = 1:r-1
       Num_repeat = 0;
       std = e_vec(i,:);
       for j = i+1:r
          if std == e_vec(j,:)
              Num_repeat = Num_repeat + 1;
%               fprintf('Row %d and %d repeated!\n',i,j);
          end
       end
       if Num_repeat == 0
           e_vec_unique(n,:) = e_vec(i,:);
%            fprintf('row %d is included the %d row\n',i,n);
           n = n + 1;
       end
    end
    e_vec_unique(n,:) = e_vec(r,:); % Add the last e-vector
    [r_final,~] = size(e_vec_unique);
    N = r - r_final;
end