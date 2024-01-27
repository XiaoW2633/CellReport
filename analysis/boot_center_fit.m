function [boot_center_poisson,boot_center_replace]=boot_center_fit(spk_trial,X,Y,XI,YI,para)
%% boot_center_fit: bootstrap the rf's center of mass to test the significant shift.
%% input : spk_trial,spike data contains firing rate of each trial on each grid.
%%         X and Y, coordinates of recording grids
%%         XI and YI, interpolated coordinates.
%%         para, parameters.
%% output: boot_center_poiss, rf's bootstrapped center of mass.
%%
siz=size(spk_trial);
nboot=para.nboot;
bootstat_unit_poisson = zeros(siz(1),siz(2),para.nboot);
bootstat_unit_replace = zeros(siz(1),siz(2),para.nboot);
%% loop the grids.
for k=1:siz(2)
    for l=1:siz(1)
        if ~isempty(spk_trial{l,k})
            
            % [mu_lamda]=poissfit(spk_trial{l,k}(:,4));%% fit a poiss distribution. what is 4 ??
            Ntrials = spk_trial{l,k}(:,4); %trial fr
            for ib = 1:para.nboot
                
                rng(1);
                % resample from the poisson distribution
                mu_lamda = mean(Ntrials); % mean firing rate
                rnd_resample=poissrnd(mu_lamda,1,length(Ntrials));
                bootstat_unit_poisson(l,k,ib)=mean(rnd_resample);
                      
                % resample with replacement
                rnd_resample = randsample(Ntrials,length(Ntrials),'true');
                bootstat_unit_replace(l,k,ib)=mean(rnd_resample);
            end
            
        else
            % filled with 0 if this grid is empty.
            
            bootstat_unit_poisson(l,k,:)=0;
            bootstat_unit_replace(l,k,:)=0;
            
        end
    end
end

boot_center_poisson=calc_cent_mass(bootstat_unit_poisson,X,Y,XI,YI,nboot,para);
boot_center_replace=calc_cent_mass(bootstat_unit_replace,X,Y,XI,YI,nboot,para);
%     boot_center.gauss=boot_center_gauss;
%     boot_center.poiss=boot_center_poiss;




end

function boot_center=calc_cent_mass(bootstat_unit,X,Y,XI,YI,nboot,para)

bootmin = repmat(min(min(bootstat_unit)),size(bootstat_unit,1),size(bootstat_unit,2));
bootmax = repmat(max(max(bootstat_unit)),size(bootstat_unit,1),size(bootstat_unit,2));
bootstat_norm = (bootstat_unit-bootmin)./(bootmax-bootmin);

for i = 1:nboot
    
    
    bootstat_interp(:,:,i) = interp2(X,Y,bootstat_norm(:,:,i),XI,YI);
    
end
bootstat_interp(bootstat_interp < para.rf) = 0;

M=sum(sum(bootstat_interp));
xmean = bsxfun(@times,XI,bootstat_interp);
xmean = sum(sum(xmean))./M;
xmean = permute(xmean,[1 3 2]);

ymean = bsxfun(@times,YI,bootstat_interp);
ymean = sum(sum(ymean))./M;
ymean = permute(ymean,[1 3 2]);
boot_center=[xmean',ymean'];

end