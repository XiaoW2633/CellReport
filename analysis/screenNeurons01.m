function [rf_clear,rf_shift,direc,coordinate]   =  screenNeurons01(P,s,contour_loc,para)
if ~isfield(P,'XI') %% a few cells' XI (coordinates of recording grids) are stored in s(2).
    
    NonPcell=[NonPcell,name];
    P.XI = s(2).XI; 
    P.YI = s(2).YI;
end

%% get the fixation and target;
x_fp=P.fixLoc(1);
y_fp=P.fixLoc(2);
x_tg=P.tarLoc(1);
y_tg=P.tarLoc(2);

%% Generate the X,Y coordinates
Xrange=unique(P.XI(:));
Yrange=flipud(unique(P.YI(:)));
[X,Y] = meshgrid(Xrange,Yrange);

%% Interpolate the coordinates
Xrange_interp=Xrange(1):0.1:Xrange(end);
Yrange_interp=Yrange(1):-0.1:Yrange(end);

%% Find the fixation and target indices in the interpolated matrix.


[~, x_fp_interp]=min(abs(Xrange_interp-x_fp));


[~, y_fp_interp]=min(abs(Yrange_interp-y_fp));


[~, x_tg_interp]=min(abs(Xrange_interp-x_tg));


[~, y_tg_interp]=min(abs(Yrange_interp-y_tg));

coordinate.targetnfixationinter=[x_fp_interp; y_fp_interp; x_tg_interp; y_tg_interp];% indices
coordinate.targetnfixation = [x_fp; y_fp; x_tg; y_tg];%actual position values
%% Generate the X,Y interpolated coordinates
[XI,YI] = meshgrid(Xrange_interp,Yrange_interp);


if para.normalize
    crf_vis=contour_loc(1).loc_resp_fr;%% crf heatmap
   % drf_vis=contour_loc(2).loc_resp_fr;%% drf heatmap
    frf_vis=contour_loc(4).loc_resp_fr;%% frf heatmap
    prf_vis=contour_loc(para.tP).loc_resp_fr; %% drf/prf heatmap
else
    crf_vis=contour_loc(1).vis_bsl;%%unnormalized crf heatmap
   % drf_vis=contour_loc(2).vis_bsl;%% unnormalized drf heatmap
    frf_vis=contour_loc(4).vis_bsl;%% unnormalized frf heatmap
    prf_vis=contour_loc(para.tP).vis_bsl; %% unnormalized drf/prf heatmap
end
%% get the individual trial fr data
crf_trial=contour_loc(1).loc_resp_spike; %
%drf_trial=contour_loc(2).loc_resp_spike; %
frf_trial=contour_loc(4).loc_resp_spike; %contour_loc(4).loc_resp
prf_trial=contour_loc(para.tP).loc_resp_spike; %

%% computer the rf center in each time period

crfRF=CenterOfMass(crf_vis,X,Y,XI,YI,Xrange_interp,Yrange_interp,para);
%drfRF=CenterOfMass(drf_vis,X,Y,XI,YI,Xrange_interp,Yrange_interp,para);
frfRF=CenterOfMass(frf_vis,X,Y,XI,YI,Xrange_interp,Yrange_interp,para);
prfRF=CenterOfMass(prf_vis,X,Y,XI,YI,Xrange_interp,Yrange_interp,para); % drf/prf 


%% get saccade amplitude
coordinate.sacamp=comSacamp(P);
%% rf completeness test
[crfRF_clear,ratio]=FindClearRF(crf_vis,crf_trial,X,Y,XI,YI,para);
%[drfRF_clear,ratio]=FindClearRF(drf_vis,drf_trial,X,Y,XI,YI,para);
[frfRF_clear,ratio]=FindClearRF(frf_vis,frf_trial,X,Y,XI,YI,para);
[prfRF_clear,ratio]=FindClearRF(prf_vis,prf_trial,X,Y,XI,YI,para); % drf/prf 
rf_clear=(crfRF_clear.clear & prfRF_clear.clear & frfRF_clear.clear); % crf drf/prf frf should pass the test.
[direc,~]  = saccadeDirec(P); 
%Tar_angle = crf2tarAngle(P,crfRF.center);
%% rf significantly shift test
if para.bootstrap == 1; % sample from poisson distribution
    bootcenter1 = contour_loc(1).boot_center_poiss;
    bootcenter2 = contour_loc(para.tP).boot_center_poiss;
else % repeated sample with replacement
    bootcenter1 = contour_loc(1).boot_center_replace;
    bootcenter2 = contour_loc(para.tP).boot_center_replace;
end
rf_shift=calc_shift(bootcenter1,bootcenter2,para.shift_level); % crfRF.center,prfRF.center

%% wrap the output.
coordinate.Xrange_interp= Xrange_interp; %% Interpolated x-y range.
coordinate.Yrange_interp= Yrange_interp;
coordinate.X            = X; %% X,Y meshgrid before interpolation
coordinate.Y            = Y;
coordinate.XI           = XI; %%  X,Y meshgrid after interpolation
coordinate.YI           = YI;
coordinate.crfCenter       = crfRF.center;  %% crf center
coordinate.crfPos          = crfRF.center_pos;
coordinate.frfCenter       = frfRF.center;  %% frf center
coordinate.frfPos          = frfRF.center_pos;
coordinate.prfCenter       = prfRF.center;  %% prf/drf center
coordinate.prfPos          = prfRF.center_pos;
%coordinate.drfCenter       = drfRF.center;  %% drf center
%coordinate.drfPos          = drfRF.center_pos;


coordinate.crfMap          = crfRF.rawRF;
coordinate.frfMap          = frfRF.rawRF;
coordinate.prfMap          = prfRF.rawRF;
%coordinate.drfMap          = drfRF.rawRF;




end