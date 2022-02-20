% For easier processing, the variable macroblocks are sub-divided into
% uniform smaller sized sub-macroblocks (usually, 4x4 for H.264).
% Assumption (observed from ffmpeg decoding): Reference point is the center
% of the macro block (e.g: for 16x16 macroblock, the reference point is
% (8,8))

% April 2020, Abhilash K. Pai
function mv_frame_details =  step_2_divide_to_uniform_blocks(ffmpeg_data, ...
    uni_block_size, para_vid, block_pos)
    
    num_blocks = (para_vid.vid_height/uni_block_size)*(para_vid.vid_width/uni_block_size);
    
    %initialize the variable in which the motion vector data will be stored
    mv_frame_details(1:para_vid.num_frames) = struct('yxuv',[block_pos(:,2) ...
    block_pos(:,1), zeros(num_blocks,2)]);                

    mv_frame_details(1).yxuv = []; % the first frame is empty
    
    meta_data = 2; % meta_data = 1, means there is no meta data
                   % meta_data = 2, there is meta data. So, skip it
                                      
    %process the data which was read from the file
    old_frame_num = 2; 
    for i=meta_data:size(ffmpeg_data,1) 
        str=textscan(ffmpeg_data{i},'%f','Delimiter' ,',()'); % retain only values
        
        if(str{1,1}(2,1) ~= -1) % to consider only I and P frames
            continue;
        end
        
        current_frame_num=str{1,1}(1,1); % get the current frame number
        
        %for a new set of GoP first frame is empty
        if(current_frame_num - old_frame_num > 1)
            mv_frame_details(old_frame_num+1:current_frame_num-1).yxuv = [];
        end
              
        x2=str{1,1}(7,1); %macroblock x-position
        y2=str{1,1}(8,1); %macroblock y-position
        
        u=x2-str{1,1}(5,1); %motion vector in x-direction
        v=y2-str{1,1}(6,1); %motion vector in y-direction
         
        %macro block details
        mb_width = str{1,1}(3,1); 
        mb_height = str{1,1}(4,1);        
        
        %get the reference co-ordinates of first uniform sub-macroblock of
        %the original macroblock
        x_pos_uni_block_1 =  ...
        x2 -  ((mb_width/2)- (uni_block_size/2));     
        y_pos_uni_block_1 =  ...
        y2 -  ((mb_height/2)- (uni_block_size/2));
        
        %get the reference co-ordinates of rest of the 4x4 sub-macroblocks
        %which is a sub-division of the original macroblock
        [Y1,X1]=ndgrid(y_pos_uni_block_1:uni_block_size:y2+(mb_height/2),...
         x_pos_uni_block_1:uni_block_size:x2+(mb_width/2));     
        yx = [reshape(Y1,size(Y1,1)*size(Y1,2),1) ...
        reshape(X1,size(X1,1)*size(X1,2),1)];
        
        %remove the sub-macro block co-ordinates
        %which are outside the image dimensions
        yx(yx(:,2)>para_vid.vid_width,:) = []; 
        yx(yx(:,1)>para_vid.vid_height,:) = [];
        
        %get the indices for the sub-marcoblock and insert the u,v 
        %information in the motion vector variable
        yx_bar = ceil(yx/uni_block_size);
        idx = sub2ind([(para_vid.vid_height/uni_block_size) ...
        (para_vid.vid_width/uni_block_size)],yx_bar(:,1),yx_bar(:,2)); 
        mv_frame_details(current_frame_num).yxuv(idx,3) = u;
        mv_frame_details(current_frame_num).yxuv(idx,4) = v;
              
        old_frame_num = current_frame_num;
    end  