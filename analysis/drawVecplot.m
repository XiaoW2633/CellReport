function  drawVecplot(ploar_vec_rf,polarInput,para)
%% drawVecplot: vector plot function.
%% input: polar_vec_rf, %% main result array for ploting polar and vector plots,contains the centers of crf frf and prf; Numofcell X 7...
%% ...[crfx,crfy,frfx,frfy,prfx/drfx,prfy/drfy,saccade amplitude].
%% polarInput: polar coordinates of shift direction.
%% para, parameters.




mksize=40;  %% marker size of frf and target centers.
alpha = 0.3; %% low contrast of the markers.
stline = 2;

%pvec = drawVecplot(tot_rfvec,para);
%vec=0;




nvec = 0;% number of vectors;


cq = [0.5,0.5,0.5]; % color of the individual shift vector
lq = 1.2;           % linewidth of the individual shift vector
mean_line = 3.2;    % linewidth of the mean vector.
Target = [];
shift=[];
FRF    = [];

figure;
siz = size(ploar_vec_rf);
%% frf center.
scatter(ploar_vec_rf(:,para.CRF2FRF),ploar_vec_rf(:,para.CRF2FRF+1),mksize,'bo','filled','MarkerFaceAlpha',alpha);hold on
%% plot crf to target vectors: crf2fp + fp2target = crf2target;fp2target vector = (sac,0);
scatter(( ploar_vec_rf(:,para.SACAMP)+ploar_vec_rf(:,para.CRF2FP )),(ploar_vec_rf(:,para.CRF2FP +1)),mksize,'ro','filled','linewidth',stline,'MarkerFaceAlpha',alpha);hold on
quiver(zeros(siz(1),1),zeros(siz(1),1),ploar_vec_rf(:,para.CRF2PRF),ploar_vec_rf(:,para.CRF2PRF+1),'filled','LineWidth',lq,'Color',cq,'MaxHeadSize',0.05);hold on




%% compute the mean target and frf
ploar_vec_rf(:,para.CRF2FP)=ploar_vec_rf(:,para.CRF2FP)+ploar_vec_rf(:,para.SACAMP);

Mean_target = mean(ploar_vec_rf(:,para.CRF2FP:para.CRF2FP+1));
Mean_frf    = mean(ploar_vec_rf(:,para.CRF2FRF:para.CRF2FRF+1),1);
%% crf
ploar_vec_rf(:,para.CRF2FP+1) = -ploar_vec_rf(:,para.CRF2FP+1);
crf = floor(19 - ploar_vec_rf(:,para.CRF2FP:para.CRF2FP+1)/4);
%% set the mean target and frf larger than other scatters.
scatter(Mean_target(1),Mean_target(2),mksize*3,'rs','filled','linewidth',stline*2);hold on
scatter(Mean_frf(1),Mean_frf(2),mksize*3,'bs','filled','linewidth',stline*2);hold on

if para.vecFlag ==1
    [theta_mean,~,~] = circ_mean(polarInput.crf2prfAngle);% mean shift angle.
r_mean     = mean(polarInput.crf2prfMag); %% mean shift magnitude
vecx = r_mean*cos(theta_mean);
vecy = r_mean*sin(theta_mean);
else
    meanVec = nanmean(ploar_vec_rf(:,para.CRF2PRF:para.CRF2PRF+1),1);
    vecx = meanVec(1);
    vecy = meanVec(2);
end


quiver(0,0,vecx,vecy,'filled','LineWidth',mean_line,'Color',[0,0,0],'AutoScale','off');hold on


show_string=['N=',num2str(siz(1))];
%show_string=['N=',num2str(size(shift_cell,2))];
%show_string1 = sprintf(['(p=%1.1fx','10^{-%d})'],pv,ev);
text(18,18,show_string,'FontSize',24);
text(10,18,para.brain,'FontSize',24);
%text(14,20 ,show_string1,'FontSize',24);

ylabel('Vertical (deg)','FontSize',20);
xlabel('Horizontal (deg)','FontSize',20);
xlim([-15,50]);
ylim([-30,15]);
set(gca,'FontSize',20,'linewidth',1);
%set(gca,'Ytick',[-2,-1,0,1],'FontSize',20);
box(gca,'on');
output = 0;
%% save the figure
if para.svfigFlag
    para.plot = 'vector';
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
    dataFile = sprintf('%s/%d-%s-%s-%s.png', dataFolder,GetNextDataFileNumber(dataFolder, '.png',para),para.plot,para.RFtime,timestamp);
    %svfigname = [para.results_root,para.align,para.brain,num2str(para.tP),'_polar',timestamp,'.png'];
    saveas(gcf,dataFile);
end

vecdata = sprintf('%s/%s_%s.mat', 'vecdata',para.brain,'sacon');
shift = ploar_vec_rf(:,para.CRF2PRF:para.CRF2PRF+1);

if para.svecFlag
    save(vecdata,'crf','shift');
end
end