function [Rf,ratio]=FindClearRF(vis,vis_trial,X,Y,XI,YI,para)
%% FindClearRF:trial number, receptive field visual response and completeness test.
%% input : vis_trial : spike data,3th colomn is baseline 4th colomn is visual response
%%         vis       : raw heatmap before normalization and interpolation.
%% output: Rf.rf     : nomalized and interpolated rf
%% output: Rf.clear  : complete rf,visual reponse,trial number test.
%% output. ratio     : completeness ratio.
th_rf=para.rf;%% get the receptive field threshold- contour criterior.

%th_edge=para.edge; %% completeness criterior.

sigLevel=para.sigLevel; %% significant visual response level

if ~para.normalize
    %    vis = max(vis,0); % In unnormalized condition,set negtive values to 0.
end

%% normalize the firing rate to [0,1];
vis_min=min(vis(:));
vis_max=max(vis(:));
vis_norm=(vis-vis_min)./(vis_max-vis_min);
[Rmax Cmax]=find(vis==max(max(vis)));% grid locations of the maximum firing rate.
%SigVis=[];
%% visual response test.
% if there are multiple peaks, pick the first.
[p,SigVis]=ranksum(vis_trial{Rmax(1),Cmax(1)}(:,4),vis_trial{Rmax(1),Cmax(1)}(:,3),'alpha',sigLevel,'tail','right');
%SigVis=h; %




% Find grids that above the threshold.0/1 matrix, 1 represents receptive field grid.
bw=vis_norm>=th_rf;
%bw=above_th;

% row and colomn index of receptive field.
[Ir,Ic] = find(bw == 1);

%%% rank sum test

%siz=size(vis_trial);
tot_trial_test=[];
%% Trial number test inside RF
for i =1: length(Ir) %% loop all rf grids
    l = Ir(i);
    k = Ic(i);
    trial_number = size(vis_trial{l,k},1);
    tot_trial_test = [tot_trial_test,trial_number<para.trialNum ]; % 
end
if sum(tot_trial_test(:)) >=1;
    trial_test = 0;
else
    trial_test = 1;
end
%min_above_th=min(vis(above_th));

% Rf.type=zeros(1,5);
% R.reason='';
%siz=size(vis);
vis_norm_intp=interp2(X,Y,vis_norm,XI,YI);
%rf_raw_hitmap = vis_norm_intp;
vis_norm_intp(vis_norm_intp<th_rf)=0;
Rf.rf=vis_norm_intp;

% clean up the following part ??

Rf.Sigresp=SigVis;


[RFmask,ratio] = completeRatio(vis_norm_intp,th_rf);

Rf.RFmask=RFmask;
Rf.rf1=vis_norm_intp.*RFmask;
%Rf.clear =  1;
% passed the visual response, trial number, and completeness tests
if SigVis && trial_test  && ratio.edge<= para.edge
  
    Rf.clear = 1;
else
    Rf.clear  = 0;

end



end
