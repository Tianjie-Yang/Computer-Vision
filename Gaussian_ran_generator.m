function [x,y,sigma_update] = Gaussian_ran_generator(mu_x,mu_y,sigma,BC_xu,BC_yu)
    x = round(normrnd(mu_x,sigma));
    y = round(normrnd(mu_y,sigma));
    if mu_x == round(x)
       if x > mu_x
          x = mu_x + 1; 
       else
          x = mu_x - 1;
       end
    end
    
    if mu_y == round(y)
       if y > mu_y
           y = mu_y + 1;
       else
           y = mu_y - 1; 
       end
    end
    
    if x <= 0
       x = 1;
    end
    if x > BC_xu
       x = BC_xu; 
    end
    if y <= 0
       y = 1; 
    end
    if y > BC_yu
       y = BC_yu; 
    end
    sigma_update = sigma/2;
end