function rf_shift=calc_shift(boot_center_poiss1,boot_center_poiss2,th)
%% calc_shift:drf/prf  significant shift test w.r.t crf.
%% input: boot_center_poiss1:crf bootstrapping centers
%%        boot_center_poiss2:drf/prf bootstrapping centers
%%        th : shift significant level.
%% output: testing result,1: significant shift,0 : no significant shift.


% 
boot_center1=boot_center_poiss1;%bootstrapping crf centers
boot_center2=boot_center_poiss2;%bootstrapping prf/drf centers

%% compute the mean of the crf/prf/drf bootstrapping centers

mean_crf = mean(boot_center1,1); 
mean_prf = mean(boot_center2,1);
%% compute the axis linking the mean crf center and mean prf/drf center.

crf_prf = mean_prf-mean_crf;

norm_xy = sqrt(sum(crf_prf.^2));


crf_prf = crf_prf./norm_xy;

%% Project the bootstrapping centers on the axis.


proj_crf = boot_center1*crf_prf';
proj_prf = boot_center2*crf_prf';

% why curve fitting ?? Could test the above 2 distributions directly or just count the overlapping points..
% [mu1,sigma1]=normfit(proj_crf);
% [mu2,sigma2]=normfit(proj_prf);
 mu1 = mean(proj_crf);
 mu2 = mean(proj_prf);
%% put the distribution which has a smaller mean on array A. A will on the left of B
if mu1>mu2
    proj_left=proj_prf;
    proj_right=proj_crf;
else
    proj_left=proj_crf;
    proj_right=proj_prf;
end

%% get the upper (th) threshold of A.
[yCDF,xCDF]=cdfcalc(proj_left);%%  empirical cumulative distribution function.
nup=yCDF(2:end)>1-th;
xup=xCDF(nup);
a_th=xup(1); % right side confidential interval 

%% get the lower (1-th) threshold of B.
[yCDF,xCDF]=cdfcalc(proj_right); %%  empirical cumulative distribution function.
nlo=yCDF(2:end)<th;
xlo=xCDF(nlo);
if isempty(xlo)
    b_th = xCDF(1);
else
    b_th=xlo(end); %% left side confidential interval 
end

%% check whether the two thresholds get cross.
if b_th>a_th; %% no overlap
    rf_shift=1;
else
    rf_shift=0;
end
