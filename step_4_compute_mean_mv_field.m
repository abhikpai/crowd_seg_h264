
function [mean_u, mean_v] = step_4_compute_mean_mv_field(u,v)
% April 2020, Abhilash K. Pai

    mean_u = zeros(size(u,1),1);
    mean_v = zeros(size(v,1),1);

     for i = 1 : size(u,1) 
        u_data = u(i,1:end);
        v_data = v(i,1:end);
        
        %skip the zero-magnitude m.v. values
        zero_motion = (u_data == 0 & v_data == 0);
        u_data(zero_motion) = [];
        v_data(zero_motion) = [];

        mean_u(i,1) = mean(u_data);
        mean_v(i,1) = mean(v_data);
     end
end