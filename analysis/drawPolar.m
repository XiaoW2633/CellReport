function p = drawPolar(polarInput,para)
%% drawPolar, plot polarmap.
%% input: polarInput, polar coordinates of shift direction. 
%%        para, parameters.
%% output: p, structure contains some circular tests of the shift directions.
figure;

shiftAngle = polarInput.crf2prfAngle;
shiftMag   =ones(1,length(shiftAngle)); % only consider the direction, make the shift magnitude as 1;

% compute the mean directions of frf,target and fixation,in radians;
mean_forward = circular_mean(polarInput.crf2frfAngle);
mean_target = circular_mean(polarInput.crf2tgAngle);
mean_fixation = circular_mean(polarInput.crf2fpAngle);
p.mean_forward = mean_forward;
p.mean_target  = mean_target;
p.mean_fixation = mean_fixation;

%% Rayleigh test for non-uniformity of circular data.
[p_uni z] = circ_rtest(shiftAngle);
p.pvalue = p_uni;


%% polar plot
h = polarplot(shiftAngle, shiftMag, 'ko');hold on;
set(h,'MarkerSize',13,'Color','k','LineWidth',2);
set(gcf,'position',[100 100 500 600]);

%shiftAngle(isnan(shiftAngle))=[];
[mean_direc,mean_len]=circular_mean(shiftAngle);
t = circ_confmean(shiftAngle(:),0.050);
upper_conf = mean_direc + t;
low_conf   = mean_direc - t;
%% plot the mean direction    Why divide by length(shiftMag) = number of cells ??
h=polarplot([0,mean_direc],[0,mean_len/length(shiftMag)],'k');
%   if para.dlip
%        h=polarplot([0,mu],[0,dfef/length(testRng)],'k');%0.09 fo
%   else
%   h=polarplot([0,mu],[0,dfef/length(testRng)],'k');%0.09 fo
%   end
set(h,'LineWidth',4,'Color','k');hold on;
ax = gca;
set(ax,'Fontsize',20);
pax = gca;
pax.RTickLabel = {};
pax.GridAlpha = 0.6;
hold on
hup=polarplot([0,upper_conf],[0,1],'color',[243 169 114]./255,'linestyle',':','linewidth',3);hold on
hlo=polarplot([0,low_conf],[0,1],'color',[243 169 114]./255,'linestyle',':','linewidth',3);hold on
%% plot the mean target;
h=polarplot(mean_target,1,'sr');
h.MarkerFaceColor='r';
h.MarkerSize = 16;
%% plot the mean fixation;
h=polarplot(mean_fixation,1,'sr');
h.MarkerFaceColor=[0.4660 0.6740 0.1880];
h.MarkerEdgeColor='None';
h.MarkerSize = 16;
%% plot the mean frf direction;
h=polarplot(mean_forward,1,'s');
h.MarkerFaceColor='b';
h.MarkerEdgeColor='b'
h.MarkerSize = 16;


% show_string=['N=',num2str(length(shiftMag))];
% text(pi/2+0.25,1.3,show_string,'FontSize',24);
text(pi/2+0.4,1.4,para.brain,'FontSize',24);
e= getFloat(p_uni);
% show_string1 = sprintf(['(p<','10^{-%g})'],e); % e
%show_string1 = sprintf(['(p<',num2str(p_uni),')']);
%show_string1 = sprintf(['(p=%1.2g)'],p_uni); 
%e= getFloat(p_uni);
show_string1 = sprintf(['N=%g (p<','10^{-%g})'],length(shiftMag),e);
%     %show_string1 = sprintf(['(p=%1.1fx','10^{-%d})'],3,2);
%   show_string=['N=',num2str(length(tot_rad))];
hpos = 1.27; % 1.27
%      if ~para.dlip
%          % show_string1 = sprintf(['(p=%1.1fx','10^{-%d})'],pv,e);
%          % show_string2 = [' (p<','0.01)',''];
%          % show_string2 = [' (p<','0.01)',''];
%          show_string1 = sprintf(['(p<','10^{-%d})'],e);
%          %
%          hpos = 1.29; % 1.29
%      else
%          show_string1 = sprintf(['(p=%0.2f)'],0.06);%p_uni_dlip
%          %     %show_string1 = sprintf(['(p=%1.1fx','10^{-%d})'],3,2);
%          %   show_string=['N=',num2str(length(tot_rad))];
%          hpos = 1.27; % 1.27
%      end
hpos = 1.34;
text(pi/2+0.23,hpos ,show_string1,'FontSize',24);
%      if para.pfef
%          hpos = 1.27;
%          text(pi/2-0.03,hpos ,show_string1,'FontSize',24);
%
%      else
%
%          text(pi/2-0.05,hpos ,show_string1,'FontSize',24);
%      end
% test the whether the mean direction is different from mean forward or
% mean target direction.  Why 0.02 ?? significance level?



%% save function;
if para.svfigFlag;
    para.plot = 'polar';
    %dataFolder = fullfile('results',para.align,para.brain);
     dataFolder = fullfile(['results',para.version],para.brain,para.align);
    if ~exist(dataFolder,'dir')
            mkdir(dataFolder)
        end
     
    timestamp = datestr(now, 31);
    % change space to @
    timestamp(11) = '@';
    % replace ':' and '-' with '_' because : means dir on Mac
    timestamp(timestamp == ':' | timestamp == '-') = '_';
    timestamp=timestamp(1:10);
    %% figure format : 1-polar-pRF-2022_08_17.png, ??
    %% it means the first polar/vector/timecourse plot of pRF/dRF in this folder, 2 means the seccond one, etc.
    dataFile = sprintf('%s/%d-%s-%s-%s.png', dataFolder,GetNextDataFileNumber(dataFolder, '.png',para),para.plot,para.RFtime,timestamp);
    %svfigname = [para.results_root,para.align,para.brain,num2str(para.tP),'_polar',timestamp,'.png'];
    saveas(gcf,dataFile);
end
end