function sacAmp=comSacamp(P)
%% comSacamp: calculate the saccade amplitude.
%% input: P, saccade parameters in the original data.
%% output: sacAmp, saccade amplitude.
% abs_x=abs(P.fixLoc(1)-P.tarLoc(1));
% abs_y=abs(P.fixLoc(2)-P.tarLoc(2));

absAmp = abs(P.fixLoc-P.tarLoc);
% sacAmp=max(abs_x,abs_y);
sacAmp = sqrt(sum(absAmp.^2)); 
end