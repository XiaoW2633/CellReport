
% ----------------------------------------------------------------------- %
% Function plot_areaerrorbar plots the mean and standard deviation of a   %
% set of data filling the space between the positive and negative mean    %
% error using a semi-transparent background, completely customizable.     %
% Modified by Xiao Wang for the timecourse plots                                                                      %
%   Input parameters:                                                     %
%       - data:     Data matrix, with rows corresponding to observations  %
%                   and columns to samples.                               %
%       - options:  (Optional) Struct that contains the customized params.%
%           * options.handle:       Figure handle to plot the result.     %
%           * options.color_area:   RGB color of the filled area.         %
%           * options.color_line:   RGB color of the mean line.           %
%           * options.alpha:        Alpha value for transparency.         %
%           * options.line_width:   Mean line width.                      %
%           * options.x_axis:       X time vector.                        %
%           * options.error:        Type of error to plot (+/-).          %
%                   if 'std',       one standard deviation;               %
%                   if 'sem',       standard error mean;                  %
%                   if 'var',       one variance;                         %
%                   if 'c95',       95% confidence interval.              %
% ----------------------------------------------------------------------- %
%   Example of use:                                                       %
%       data = repmat(sin(1:0.01:2*pi),100,1);                            %
%       data = data + randn(size(data));                                  %
%       plot_areaerrorbar(data);                                          %
% ----------------------------------------------------------------------- %
%   Author:  Victor Martinez-Cagigal                                      %
%   Date:    30/04/2018                                                   %
%   E-mail:  vicmarcag (at) gmail (dot) com                               %
% ----------------------------------------------------------------------- %
function pstat=plot_areaerrorbar(data1, tot_theta_radian ,polarInput,para)

mean_forward = circular_mean(polarInput.crf2frfAngle)*180/pi;
mean_target = circular_mean(polarInput.crf2tgAngle)*180/pi;
mean_fixation = circular_mean(polarInput.crf2fpAngle)*180/pi;

pstat.mean_target=mean_target;
pstat.mean_forward=mean_forward;

pstat.mean_fixation = mean_fixation;

%options.handle     = figure(1);
options.color_area = [0.4940 0.1840 0.5560];    % Blue theme
options.color_area2 = [0.4660 0.6740 0.1880];
options.color_line = [0.4940 0.1840 0.5560];
%options.color_area = [243 169 114]./255;    % Orange theme
options.color_line2 = [0.4660 0.6740 0.1880];
options.alpha      = 0.4;
options.line_width = 2;
options.error      = 'sem';

if(isfield(options,'x_axis')==0), options.x_axis =para.sbin; end
options.x_axis = options.x_axis(:);

% Computing the mean and standard deviation of the data matrix
data_mean1 = nanmean(data1,1);
data_std1  = nanstd(data1,0,1);

% Type of error plot
switch(options.error)
    case 'std', error = data_std;
    case 'sem', error = (data_std1./sqrt(size(data1,1)));
    case 'var', error = (data_std.^2);
    case 'c95', error = (data_std./sqrt(size(data,1))).*1.96;
end


sem_theta = []; %% standard error mean of direction.
mean_theta=[]; %% mean direction

for i = 1:size(tot_theta_radian,2) % do you need the loop ??
    tmp_theta = tot_theta_radian(:,i);
     Indval = find(~isnan(tmp_theta));
    [s s0] = circ_std(tmp_theta(Indval));
    sem_theta = [sem_theta,s0*180/pi/sqrt(size(tot_theta_radian,1))]; % standard error named std ??
    %% computer the circular mean without nan values
    
   
    
    %mean_theta=[mean_theta,circ_mean(tot_theta_radian(:,i))];
    mean_theta=[mean_theta,circ_mean(tmp_theta(Indval))];
    [pval, z] = circ_rtest(tot_theta_radian(:,i)');
   % ptheta = [ptheta,pval];
end

set(gcf,'defaultAxesColorOrder',[options.color_area; options.color_area2]);
mean_theta = mean_theta*180/pi;
% mean_theta , sem_theta
%
%     % Plotting the result
%     figure(options.handle);
%     x_vector = [options.x_axis', fliplr(options.x_axis')];
%     patch = fill(x_vector, [data_mean+error,fliplr(data_mean-error)], options.color_area);
%     set(patch, 'edgecolor', 'none');
%     set(patch, 'FaceAlpha', options.alpha);
%     hold on;
%     plot(options.x_axis, data_mean, 'color', options.color_line, ...
%         'LineWidth', options.line_width);
%     hold off;figure1=figure;
%close all
xlimt=[para.sbin(1),para.sbin(end)];
% figure1=figure;
% figsizex = 800;
% figsizey = 500;
% set(figure1,'position',[100 100 figsizex figsizey]);
% yyaxis left   % ??
set(gca,'FontSize',20);
x_vector = [options.x_axis', fliplr(options.x_axis')];
%ax(1) = gca;
patch_sem = fill(x_vector, [data_mean1+error,fliplr(data_mean1-error)], options.color_area);
set(patch_sem, 'edgecolor', 'none');
set(patch_sem, 'FaceAlpha', options.alpha);
hold on
plot(options.x_axis, data_mean1, 'color', options.color_line, ...
    'LineWidth', options.line_width,'linestyle','-');
hold on;
plot([xlimt(1)-50,xlimt(2)+20],[1,1],'color',options.color_area,'LineWidth',3,'LineStyle','-'); hold on

 set(gca,'YColor',options.color_line,'YTick',[0  0.2  0.4  0.6 0.8 1],'YTickLabel',...
     {'0','0.2','0.4','0.6','0.8','1'});
%ylabel(ax(1),'Norm. shift magnitude');
%set(gca,'ylim',[0,1.1]);
set(gca,'ylim',[0,1.1],'YColor',options.color_area);
set(gca,'FontSize',25); 
%% Direction
yyaxis right
set(gca,'FontSize',20);
patch_direc = fill(x_vector, [mean_theta+sem_theta,fliplr(mean_theta-sem_theta)], options.color_area2);
set(patch_direc, 'edgecolor', 'none');
set(patch_direc, 'FaceAlpha', options.alpha);
hold on
plot(options.x_axis, mean_theta, 'color', options.color_line2, ...
    'LineWidth', options.line_width,'linestyle','-');
%ylim([-100,20]);
set(gca,'YColor',options.color_area2,'YTick',[-100,-60,-20,20],'YTickLabel',...
    {'-100','-60','-20','20'}); %,[-40 -20 0 20 40 60 80]
set(gca,'ylim',[-120,20],'YColor',options.color_area2);
hold on;

plot([xlimt(1)-50,xlimt(2)+20],[mean_target,mean_target],'color',options.color_area2,'LineWidth',3,'LineStyle','--');hold on % 6 horizontal saccade;
plot([xlimt(1)-50,xlimt(2)+20],[mean_forward,mean_forward],'color',options.color_area2,'LineWidth',3,'LineStyle',':');hold on
%mean_fixation
plot([xlimt(1)-50,xlimt(2)+20],[mean_fixation,mean_fixation],'color',options.color_area2,'LineWidth',3,'LineStyle','-.');hold on
set(gca,'xlim',[xlimt(1),xlimt(2)]);
% ax = gca;
% set(ax.,'YColor',options.color_area);
end
