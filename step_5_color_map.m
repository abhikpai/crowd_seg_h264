function [color_img_after_smoothing,u_original_size,v_original_size] = ...
step_5_color_map(mean_u, mean_v, no_noise_block_pos,para_vid,uni_block_size,window_size)

x = no_noise_block_pos(:,2);
y = no_noise_block_pos(:,1);

u_original_size=zeros(para_vid.vid_height,para_vid.vid_width);
v_original_size=zeros(para_vid.vid_height,para_vid.vid_width);

%re-create the motion vector field original frame from the blockwise motion 
%vector field
for i=1:size(x,1)
    block_mid_x = x(i,1);
    block_mid_y = y(i,1);
    
    u_original_size(block_mid_y-((uni_block_size/2)-1):block_mid_y+(uni_block_size/2),...
    block_mid_x-((uni_block_size/2)-1):block_mid_x+(uni_block_size/2)) = mean_u(i);

    v_original_size(block_mid_y-((uni_block_size/2)-1):block_mid_y+(uni_block_size/2),...
    block_mid_x-((uni_block_size/2)-1):block_mid_x+(uni_block_size/2)) = mean_v(i);
    
end

%the function "computeColor" is used to convert a motion vector field to a
%colormap image
color_img_before_smoothing = computeColor(u_original_size,v_original_size);

%% smooth the motion vector field using median filtering
u_original_size = medfilt2(u_original_size,[window_size window_size]);
v_original_size = medfilt2(v_original_size,[window_size window_size]);

color_img_after_smoothing= computeColor(u_original_size,v_original_size);
figure; 
imshowpair(color_img_before_smoothing,color_img_after_smoothing,'montage');
title('color map before and after smoothing')
end