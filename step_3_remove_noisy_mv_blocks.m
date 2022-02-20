
function [u, v, block_pos,idx_not_noisy_reduced] = step_3_remove_noisy_mv_blocks ...
    (u,v,block_pos,para_vid,uni_block_size,se_size,disp_inter_image)
% April 2020, Abhilash K. Pai

    count_vector = zeros(size(u,1),1);
    
    %for each sub-macroblock, compute the count of occurance of 
    %non-zero motion vector for the entire video sequence
    for i = 1:size(u,2)
        mag_uv = sqrt(u(:,i).^2 + v(:,i).^2); %magnitude of the vector
        idx = find(mag_uv>0); %find the blocks with non-zero m.v.
        count_vector(idx,1) = count_vector(idx,1) +1; %non-zero m.v. count
    end
    
    %find noisy sub-macroblocks which violate the defined criteria
    threshold_nonzero_count = mean(count_vector); %threshold is taken as the mean of the nonzero_count matrix
    idx_not_noisy = count_vector>=threshold_nonzero_count;  

    %perform morphological operations to find remaining noisy blocks
    im = morphological_operations(para_vid,idx_not_noisy,uni_block_size,se_size,disp_inter_image);
   
    %remove all the noisy blocks 
    im_col_vector = reshape(im,size(im,1)*size(im,2),1);
    idx_noise = (im_col_vector == 0 | count_vector == 0);
    u(idx_noise,:) = [];
    v(idx_noise,:) = [];
    block_pos(idx_noise,:) = [];
    idx_not_noisy_reduced = ~idx_noise;     
    
end

function im = morphological_operations(para_vid,idx_no_noise,uni_block_size,se_size,disp_inter_image)
    
    static_dynamic=zeros(para_vid.vid_height/uni_block_size,...
                   para_vid.vid_width/uni_block_size); 
    static_dynamic(idx_no_noise) = 1;
    
    im = static_dynamic;
    
    %removing isolated and disconnected blocks
    se = strel('square',se_size); %this structuring element does a decent job
    im = imclose(im,se);
    im = imopen(im,se);

    if(disp_inter_image==1)
        display_image(static_dynamic,im);
    end

end

function display_image(static_dynamic,im)
    figure;
    imshow(static_dynamic); title('Original Image');
    figure;
    imshowpair(static_dynamic,im); title('Purple regions are added,  Green regions are removed');
    figure;
    imshow(im);title('Final Image');

end