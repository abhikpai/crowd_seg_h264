
function seg_image = display_segments(block_details,seg_image,cluster_no,uni_block_size)
% April 2020, Abhilash K. Pai

    x = block_details(:,2);
    y = block_details(:,1);
    idx = sub2ind(size(seg_image),y,x);
    seg_image(idx) = cluster_no;

    for i=1:size(x,1)

        block_mid_x = x(i,1);
        block_mid_y = y(i,1);
        seg_no = cluster_no(i,1);

        seg_image(block_mid_y-((uni_block_size/2)-1):block_mid_y+(uni_block_size/2),...
        block_mid_x-((uni_block_size/2)-1):block_mid_x+(uni_block_size/2)) = seg_no;

    end

    imshow(label2rgb(seg_image));

end