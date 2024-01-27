function output  =  ConvertAngle(P,crfCenter,frfCenter,prfCenter,sacDirec)
%% ConvertAngle : Align saccade direction to rightward.
%% input : 
%%         P     : parameters
%%         crfCenter: crf xy center
%%         frfCenter: frf xy center
%%         prfCenter: prf/drf xy center
%%         sacDirec / %sacDirec   : designed saccade direction ,0: right; 1: left; 2:up; 3:down;
%% output:X
% % output(1) fixation to crf center x
% % output(2) fixation to crf center y
% % output(3) crf to frf center x
% % output(4) crf to frf center y
% % output(5) crf to prf/drf center x
% % output(6) crf to prf/drf center y
% % output(7) crf to target center x
% % output(8) crf to target center y
%   towards_flag: flag for toward or away saccade, 1: toward saccade, 0: away saccade.
fp=P.fixLoc; %% fixation (x,y)
tg=P.tarLoc; %% target   (x,y)

%% vectors before rotation
crf2fp  = fp-crfCenter;%% crf to fixation vector
crf2tg  = tg-crfCenter;%% crf   to target vector
crf2frf = frfCenter-crfCenter;%%  crf to frf vector
crf2prf = prfCenter-crfCenter;%%  crf to  prf/drf vector
centers_vec = [crf2fp;crf2frf;crf2prf;crf2tg]';%% Combine the centers for rotation operation;

%% method:
%% Rotation matrix
%% [cos(t),-sin(t);sin(t),cos(t)]*[x;y]
%% counterclockwise t (radians) of vector (x,y);
%% centers_vec = [crf2fp;crf2frf;crf2prf]';
%% centers_vec = rotationMatrix * centers_vec;
%% after rotation, if the crf below the fp, reverse the y components.
%%  centers_vec(2,:) =-centers_vec(2,:);



% use the saccade direction to generate rotation matrix.
theta = sacDirec;
rotationMatrix = [cos(theta),-sin(theta);sin(theta),cos(theta)];
% rotate the vectors
% align the saccade rigthward and put the crf center on the top of fixation.
centers_vec = rotationMatrix*centers_vec;
% if the crf below the fixation, flip the y components.
% We always put the center of crf above the fixation
if  centers_vec(2,1) > 0
    centers_vec(2,:) =-centers_vec(2,:);
    
end

output = reshape(centers_vec,1,numel(centers_vec));

end

