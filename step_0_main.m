clc;clear;close all;
addpath('util\');

%% parameters
scene_no = 7; %according to UCF dataset (1 to 7)
uni_block_size = 4; %smallest block size

% Note: For the below statements, no conditions are defined for the case of 
% exceeding of the frames. So, choose them carefully based on the number of 
% frames in the image.

fixed_range = 30; %range of frames to be processed. 
start_frame = 4; %better to start from frame#4 to avoid the initial noise effects
end_frame = start_frame + (fixed_range-1);

morph_struct_elem_size = 5; %structuring element for morphological operation
med_filt_size = 17; %window size for median filtering

disp_inter_image = 0; % value 1, means the result after step 3 will be displayed
                      % any other value, means no intermediate image will be displayed

%% data location
vid_folder = 'vid\'; 
vid_name = [num2str(scene_no) '.mp4']; %input video file for plotting

mv_folder = 'mv\';
mv_file_name =[num2str(scene_no) '.txt']; %input motion vector file

%% obtain the video details
para_vid = get_video_details([vid_folder vid_name],uni_block_size);

    % use "para_vid.vid_height" to get frame height
    % use "para_vid.vid_width" to get frame width
    % use "para_vid.vid_info(i).cdata" to get i-th frame
    % use "para_vid.num_frames" to get total no.of frames

%% Pre-defined the reference co-ordinates for sub-marcoblocks
%the reference position co-ordinates for the sub-macroblocks are pre-defined 
%depending on the uniform block size and size of the frame
[Y,X] = ndgrid((uni_block_size/2):uni_block_size:para_vid.vid_height, ...
        (uni_block_size/2):uni_block_size:para_vid.vid_width);
    
block_pos(:,1) = reshape(Y,size(Y,1)*size(Y,2),1); %[y x] for MATLAB
block_pos(:,2) = reshape(X,size(X,1)*size(X,2),1);

%% Step 1: get the data from ffmpeg output file (read for the enitre video)
ffmpeg_data = step_1_read_mv_ffmpeg([mv_folder mv_file_name]);

%% Step 2: divide the image into uniform sub-macro blocks 
mv_frame_details = step_2_divide_to_uniform_blocks(ffmpeg_data, uni_block_size, para_vid, block_pos);

%% Step 2.1: for fixed range of frames, re-arrange the data block-wise (for easy processing) 
[block_u, block_v] = get_block_wise_data(mv_frame_details, block_pos,start_frame,end_frame);

%% Step 3: remove noisy motion vectors
[no_noise_u, no_noise_v, no_noise_block_pos] = ...
step_3_remove_noisy_mv_blocks(block_u,block_v,block_pos,para_vid, ...
uni_block_size,morph_struct_elem_size, disp_inter_image);

%% Step 4: compute mean motion vector field
[mean_u, mean_v] = step_4_compute_mean_mv_field(no_noise_u,no_noise_v);

%% Step 5: convert the mean motion vector filed to a color image of the original frame size and smooth it
[color_img,U_smooth,V_smooth] = ...
step_5_color_map(mean_u, mean_v, no_noise_block_pos,para_vid,uni_block_size,med_filt_size);
                        
%% save the image
imwrite(color_img,['saved_color_maps\' num2str(scene_no) '.png']);

%% save the smoothed mean motion vector field
writematrix(U_smooth, ['saved_mean_mv\' num2str(scene_no) '_u.xlsx']);
writematrix(V_smooth, ['saved_mean_mv\' num2str(scene_no) '_v.xlsx']);

