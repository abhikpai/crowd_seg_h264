% This program reads the text file containing the motion vectors extracted 
% from H.264-coded video using FFmpeg and stores it in the variable
% "ffmpeg_data".

% April 2020, Abhilash K. Pai
function ffmpeg_data = step_1_read_mv_ffmpeg(mv_path)
    
    %open the text file containing the ffmpeg motion vectors
    fid=fopen(mv_path);
    %read the text file, line by line
    line_no=1;
    while ~feof(fid)
        ffmpeg_data{line_no,1} = fgetl(fid); 
        line_no = line_no + 1;
    end        
end