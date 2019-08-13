fileID = fopen('PDVTimingParams.txt');
textscan(fileID,'%s',34)
A = textscan(fileID,'%f',1);
A = double(A{1});
textscan(fileID,'%s',7);
B = textscan(fileID,'%f,%f,%f',1);
B = [B{1}   B{2}    B{3}];
fclose(fileID);