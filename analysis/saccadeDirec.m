function [direc,R]= saccadeDirec(P) %
%% saccadeDirec : compute the saccade direction w.r.t rightward.
%% input: P, saccade parameters, fixation and target (degrees); center: crf center (degrees)
%% output: direc in radians, saccade direction.



 designDirec   = P.tarLoc-P.fixLoc; % saccade direction in Cartesian

[direc,R] = cart2pol(designDirec(1),designDirec(2)); %  Transform Cartesian to polar coordinates (0~2*pi)

end