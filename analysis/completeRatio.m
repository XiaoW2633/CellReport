function [bw,r]=completeRatio(img,th)
%% completeRatio:calculate the ratio of undetected rf contour to the total rf contour (completeness ratio),
%% input : img,normalized and interpolated heat map.
%%         th  ,rf threshold
%%         
%% output :bw, rf mask (0/1)matrix, 1 represents area above th.
%%       : r, completeness ratio.


%% get rf - heatmap above the threshold
img(img<th)=0;
%% get rf mask (0/1)matrix
bw=img~=0;
%% get multi-patches
imLabel = bwlabel(bw);
stats=regionprops(imLabel,'Area');

[b,index]=sort([stats.Area],'descend');
%firstRf=ismember(imLabel,index(1));
% max_area=[];
% if length(b)>1
%     
%     max_area = b(2:end)./b(1);
%     r_area = max(max_area); % explain ??
% else
%     r_area=0;
% end
% % r.area=r_area;
% r.area=0; % set it to 0 anyway ??
% r.num_area=length(stats);
%%

%%% completeness
%% calculate how many contour points on 4 borders(left,right,top,bottom).
%Rfmask = bw; %%
firstColom = sum(bw(:,1));%% left border
endColom   = sum(bw(:,end));%% right border
firstRow   = sum(bw(1,:));  %% top border
endRow     = sum(bw(end,:)); %% bottom border
totBound   = firstColom+endColom+firstRow+endRow;
contour=bwperim(bw);  %% get the contour of rf
%% compute how many points of the rf contour
sz = size(contour);
[I,J,V] = find(contour==1);
%% completeness ratio
r.edge=totBound/length(V);

%     Ib.I=I;
%     Ib.J=J;



end