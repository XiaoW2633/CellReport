function [loc_resp_spk,loc_resp_fr] = getBslVis(contour,para,Ind)
% getBslVis:get and save the baseline and visual response from preprocessed data (yanglin's data)
% input: tmp_contour, preprocessed data from yanglin.
%        para, parameters.
%        Ind , time period index,1-cRF,2-dRF,3-pRF(probe onset),4-fRF,5-pRF(sac.onset),8-pRF(sac.offset)

       

tmp_contour = contour(Ind).fr;
noiseInd = Ind;
if Ind == 8
    noiseInd = 3;
    tw_pre = para.pre_sac;
    tw_post = para.post_sac;
elseif Ind == 5
    noiseInd = 3;
    tw_pre = para.pre_sacon;
    tw_post = para.post_sacon;
else
    tw_pre = para.pre_probe;
    tw_post = para.post_probe; 
end
baseline_spk = contour(noiseInd).fr;

siz=size(tmp_contour);
   
%     if nargin == 3  % ??
%         baseline_spk = bsl_contour; %% saccade offset
%     else
%         baseline_spk = tmp_contour; %% probe onset
%     end
%     %% get the time window depend on alignment.
%     if strcmp(para.align,'probeon')
%         tw_pre = para.pre_probe;
%         tw_post = para.post_probe;
%     elseif strcmp(para.align,'sacoff')
%         tw_pre = para.pre_sac;
%         tw_post = para.post_sac;
%     else
%         error('invalid alignment');
%     end
    %% Initial arrays for visual response and baseline.
    loc_resp_fr = zeros(siz(1),siz(2));  %% heat map of rf
    loc_bsl_fr    = zeros(siz(1),siz(2)); %% heat map of baseline
    loc_resp_spk = cell(siz(1),siz(2)); %%% spike data for each trial
    
    
    %% loop the grids
    for k= 1:siz(2)
       
        for l = 1:siz(1)
          
            trials=tmp_contour{l,k};
            bsl_trials=baseline_spk{l,k};
            spk=[];
            loc_resp_spk{l,k} = zeros(length(trials),4); %% initial the array to collect the spike data
           % noise_trial = noise_bsl{l,k};
            for i=1:length(trials)
                spk=[spk,trials{i}];
                % firing rate of visual response in each trial.
                loc_resp_spk{l,k}(i,4) = para.nSpk2fr_probe*sum((trials{i}>=tw_pre) & (trials{i}<tw_post));
                % firing rate of baseline in each trial.
               
                loc_resp_spk{l,k}(i,3) =  para.nSpk2fr_bsl*sum((bsl_trials{i}>=para.bsl_start) & (bsl_trials{i}<para.bsl_end));
%                 
                
            end
            
            tmp_vis_I = (spk>=tw_pre) & (spk<tw_post);
            tmp_bsl_I = (spk>=para.bsl_start) & (spk<para.bsl_end);
            
%             if isempty(tmp_vis_I)
%                 loc_resp_fr(l,k) = 0;
%             else
%                 loc_resp_fr(l,k) = para.nSpk2fr_probe*sum(tmp_vis_I)/length(trials);
%             end
            loc_resp_fr(l,k) = mean(loc_resp_spk{l,k}(:,4));

            
            
            
        end
    end
   
end
  