function  [fr,Probe2sacon] = rearangeSpk(tmpSpkTrials,TrialInfo,para)
% Input:
% tmpSpkTrials: contains the spike data.
% TrialInfo: contains the time of probe and saccade onset information,1-d array
% (1*numberof trials of this cell) trail IDs are in
% tmpSpkTrials.TrialIDWithoutExtrVals(1*number of trials of this cell)

% Output:
% fr    : spike data within the time window 150ms before saccade onset.
% Probe2sacon : time between probe onset and saccade onset
fr = {}; % Initial the array to collect the spike data (same size as probe grids)
Probe2sacon = {};% Initial the array to collect the time of probe to saccade onset (same size as probe grids)

tmpTrialID = tmpSpkTrials.TrialIDWithoutExtrVals; % TrialID without extra values(>3std) same size as probe grids
%tmpSpkTrials = tmp_contour;

rfSize = size(tmpTrialID);

% Get the time of probe onset
tmpProbeInfo = TrialInfo.Probe{1,3}; %When 3 means peri-saccade period.
probeon = [tmpProbeInfo(:).onset]; % time of probe onset shape(1,numOfTotal trials(trial ID))
% Get the time of saccade onset
sacon = [TrialInfo.sac(:).sacOn]; % time of saccade onset
probe2sac = sacon-probeon; % time between probe onset and saccade onset.


% loop the grid, only collect the trial when 0 <probe2sac< 150ms.
for i = 1:rfSize(1)
    for j = 1:rfSize(2)
        gridTrialID = tmpTrialID{i,j};%(trial IDs in each grid)
        index = 1;
        for ti = 1:length(gridTrialID)
            tmpspktrial = tmpSpkTrials(gridTrialID(ti));
            tmpfr = tmpspktrial{:};% get the spike data
            %tmpfr = tmpspktrial(tmpspktrial>para.dataPreProbe &tmpspktrial<para.dataPostProbe);% spikes within -50~350ms aligned on probe onset
            
            % if tP == 3
            probe2sac2_ = probe2sac(gridTrialID(ti)); % get the probe to sac time for each trial
            if  (probe2sac2_ <= 150) & (probe2sac2_>0) % 1
                fr{i,j}{index,1} =tmpfr;% spike data within the time window 150ms before saccade onset.
                Probe2sacon{i,j}{index} = probe2sac2_; % 
                index = index + 1;
            end
            %             else
            %
            %                 fr{i,j}{ti,1} =tmpfr;
            %
            %             end
            
            
        end
        
    end
end
