
%%  Time aggregation in the PSID
%
%   'Consumption Inequality across Heterogeneous Families'
%   This script implements the estimation of wages and preferences 
%   addressing neglected time aggregation.
%
%   While estimation of the wage process is straightforward addressing time
%   aggregation, estimation of preferences is not. This is because the
%   moments of the transmission of transitory shocks are no longer linear
%   in preferences; instead they (also) depend on the transmission 
%   parameters of permanent shocks that are not identified in this context. 
%   Therefore overall identification of preferences and heterogeneity is 
%   no longer possible. To get around this issue, I estimate preferences 
%   and heterogeneity over a fixed grid of possible values for the moments
%   of the transmission parameters of permanent shocks. I retrieve possible
%   values for the average such parameters from Blundell et al. (2016) and 
%   Crawley (2020), while I also propose a grid of reasonable value for
%   their second moments, which these papers do not estimate.
%
%   Alexandros Theloudis
%   LISER Luxembourg 
%   Tilburg Econometrics & Operations Research 
%   Spring 2021
%
%   =======================================================================

%   Initial statements:
global  do num_boots vModelHat_c1 dDir ;

%   Declare depth of time aggregation:
%   -months_in_year = 1 is my baseline;
%   -months_in_year = 12 assumes twelve monthly salaries in year.
months_in_year = 12;

%   Declare depth of loops over fixed values for the transmission 
%   parameter \phi of permanent shocks:
depth_avg_phi       = 4;
depth_var_phimain   = 4;
depth_var_phicross  = 2;
depth_cov_phi       = 2;


%%  1.  ESTIMATION OF WAGES
%   Implements the GMM estimation of the parameters of the wage process
%   addressing neglected time aggregation. 
%   -----------------------------------------------------------------------

%   Wage estimation:
[vWageHat_timeaggr, wageFval_timeaggr, wageFlag_timeaggr] = ...
    estm_wages_timeaggr(mc1.Couple, mc1.Ind, mc1.Err, 'iter', 1, 'eye', months_in_year) ;

%   Boostrap standard errors:
if do.inference == 1
    %   -initialize objects that will collect bootstrap information:
    mbsWage_timeaggr        = zeros(length(vWageHat_timeaggr),num_boots) ;
    mbsWageFval_timeaggr    = zeros(1,num_boots) ;
    mbsWageFlag_timeaggr    = zeros(1,num_boots) ;
    %   -loop over bootstrap samples:
    for k = 1:num_boots

        %   Read bootstrap data:
        bs_dat = sprintf('_Cond1/bs_%d.csv',k) ;
        bs_err = sprintf('_Cond1/me_c1_bs_%d.csv',k) ;
        [mbsC_c1,mbsI_c1,~,~,mbsEr_c1,~,~,~] = handleData(bs_dat,bs_err,[],[]) ;

        %   Bootstrap wage parameters:
        [bswagehat_timeaggr,bswagefval_timeaggr,bswageflag_timeaggr] = ...
                estm_wages_timeaggr(mbsC_c1,mbsI_c1,mbsEr_c1,'notify-detailed',1,'eye', months_in_year) ;
        mbsWage_timeaggr(:,k)    = bswagehat_timeaggr ;
        mbsWageFval_timeaggr(k)  = bswagefval_timeaggr ;
        mbsWageFlag_timeaggr(k)  = bswageflag_timeaggr ;

        %   Clear bootstrap data of this round:
        clearvars bs_* mbsC_c1 mbsI_c1 mbsEr_c1 bswage*

        %   Report progress:
        fprintf('Finished Wage Bootstrap Time Aggregation round : %u\n',k)
    end
    clearvars k

    %   Deliver wage standard errors applying normal approximation to the 
    %   interquartile range of bootstrap replications (IQR =~ 1.349 sigma)
    seWages_timeaggr = iqr(mbsWage_timeaggr,2) / 1.349 ;
end %do.inference


%%  2.  ESTIMATION OF MODEL
%   Proposes grid for moments of transmission parameters of permanent 
%   shocks and implements the GMM estimation of preferences. 
%   -----------------------------------------------------------------------

%   A. Grid for moments of transmission parameters of permanent shocks.
%   There are in total 6 transmission parameters of permanent shocks: 
%       kappa_cv1
%       kappa_cv2
%       kappa_y1v1
%       kappa_y1v2
%       kappa_y2v1
%       kappa_y2v2
%   so ovearall there are 6 averages, 6 variances, and 15 covariances; a 
%   total of 27 parameters for which I need to loop over possible values.
%   To get around the curse of dimensionality, I fix certain covariances
%   to zero (see below).
%   -----------------------------------------------------------------------

%   Initialize array - first dimension holds values for 27 moments of the 
%   transmission parameters of permanent shocks: 
phi = zeros(27, depth_avg_phi,depth_avg_phi, ...            % dimensions 2-3:   index for loop over E(kappa_cv1)  and E(kappa_cv2)  
                depth_avg_phi,depth_avg_phi, ...            % dimensions 4-5:   index for loop over E(kappa_y1v1) and E(kappa_y1v2) 
                depth_avg_phi,depth_avg_phi, ...            % dimensions 6-7:   index for loop over E(kappa_y2v1) and E(kappa_y2v2)
                depth_var_phimain,depth_var_phimain, ...   	% dimensions 8-9:   index for loop over V(kappa_cv1)  and V(kappa_cv2)  
                depth_var_phimain,depth_var_phicross, ...  	% dimensions 10-11: index for loop over V(kappa_y1v1) and V(kappa_y1v2) 
                depth_var_phicross,depth_var_phimain, ...  	% dimensions 12-13: index for loop over V(kappa_y2v1) and V(kappa_y2v2)
                depth_cov_phi, ...                          % dimension  14:    index for loop over C(kappa_cv1,kappa_cv2)
                1, ...                                      % dimension  15:    index for loop over C(kappa_cv1,kappa_y1v1)
                1, ...                                      % dimension  16:    index for loop over C(kappa_cv1,kappa_y1v2)
                1, ...                                      % dimension  17:    index for loop over C(kappa_cv1,kappa_y2v1)
                1, ...                                      % dimension  18:    index for loop over C(kappa_cv1,kappa_y2v2)
                1, ...                                      % dimension  19:    index for loop over C(kappa_cv2,kappa_y1v1)
                1, ...                                      % dimension  20:    index for loop over C(kappa_cv2,kappa_y1v2)
                1, ...                                      % dimension  21:    index for loop over C(kappa_cv2,kappa_y2v1)
                1, ...                                      % dimension  22:    index for loop over C(kappa_cv2,kappa_y2v2)
                depth_cov_phi, ...                          % dimension  23:    index for loop over C(kappa_y1v1,kappa_y1v2)
                1, ...                                      % dimension  24:    index for loop over C(kappa_y1v1,kappa_y2v1)
                1, ...                                      % dimension  25:    index for loop over C(kappa_y1v1,kappa_y2v2)
                1, ...                                      % dimension  26:    index for loop over C(kappa_y1v2,kappa_y2v1)
                1, ...                                      % dimension  27:    index for loop over C(kappa_y1v2,kappa_y2v2)
                depth_cov_phi);                             % dimension  28:    index for loop over C(kappa_y2v1,kappa_y2v2)

%   Populate array with grid of reasonable values for the average and  
%   second moments of the transmission parameters of permanent shocks. 
%   These values are motivated by Blundell et al. (2016) & Crawley (2020),
%   complemented with common sense - i.e. what seems to be reasonable 
%   values for the average and variance of these transmission parameters.

%       - male permanent shock into consumption (kappa_cv1)
%   BPS (table 5) find a value of 0.34, so I generate a grid within 
%   [0.05;0.55] thus containing this value.
x = 0.5/(depth_avg_phi-1) ;
y = (0.05*depth_avg_phi-0.55)/(depth_avg_phi-1) ;
for kcv1 = 1:1:depth_avg_phi
    phi(1,kcv1,:,:,:,:,:,:,:,:,:,:,:,:,:,:,:,:,:,:,:,:,:,:,:,:,:,:) = x*kcv1 + y ;
end

%       - female permanent shock into consumption (kappa_cv2)
%   BPS (table 5) find a value of 0.20, so I generate a grid within 
%   [0.05;0.4] thus containing this value.
x = 0.35/(depth_avg_phi-1) ;
y = (0.05*depth_avg_phi-0.4)/(depth_avg_phi-1) ; 
for kcv2 = 1:1:depth_avg_phi
    phi(2,:,kcv2,:,:,:,:,:,:,:,:,:,:,:,:,:,:,:,:,:,:,:,:,:,:,:,:,:) = x*kcv2 + y ;
end

%       - male permanent shock into male earnings (kappa_y1v1)
%   BPS (table 5) find a value of 0.9 (=1-0.1), so I generate a grid within 
%   [0.65;1.05] thus containing this value.
x = 0.4/(depth_avg_phi-1) ;
y = (0.65*depth_avg_phi-1.05)/(depth_avg_phi-1) ;
for ky1v1 = 1:1:depth_avg_phi
    phi(3,:,:,ky1v1,:,:,:,:,:,:,:,:,:,:,:,:,:,:,:,:,:,:,:,:,:,:,:,:) = x*ky1v1 + y ;
end

%       - female permanent shock into male earnings (kappa_y1v2)
%   BPS (table 5) find a value of -0.23, so I generate a grid within 
%   [-0.4;0.0] thus containing this value.
x = 0.4/(depth_avg_phi-1) ;
y = -0.4*depth_avg_phi/(depth_avg_phi-1) ;
for ky1v2 = 1:1:depth_avg_phi
    phi(4,:,:,:,ky1v2,:,:,:,:,:,:,:,:,:,:,:,:,:,:,:,:,:,:,:,:,:,:,:) = x*ky1v2 + y ;
end

%       - male permanent shock into female earnings (kappa_y2v1)
%   BPS (table 5) find a value of -0.78, so I generate a grid within 
%   [-0.9;-0.4] thus containing this value.
x = 0.5/(depth_avg_phi-1) ;
y = (-0.9*depth_avg_phi+0.4)/(depth_avg_phi-1) ;
for ky2v1 = 1:1:depth_avg_phi
    phi(5,:,:,:,:,ky2v1,:,:,:,:,:,:,:,:,:,:,:,:,:,:,:,:,:,:,:,:,:,:) = x*ky2v1 + y ;
end

%       - female permanent shock into female earnings (kappa_y2v2)
%   BPS (table 5) find a value of 1.4 (=1+0.4), so I generate a grid within 
%   [1.1;1.6] thus containing this value.
x = 0.5/(depth_avg_phi-1) ;
y = (1.1*depth_avg_phi-1.6)/(depth_avg_phi-1) ;
for ky2v2 = 1:1:depth_avg_phi
    phi(6,:,:,:,:,:,ky2v2,:,:,:,:,:,:,:,:,:,:,:,:,:,:,:,:,:,:,:,:,:) = x*ky2v2 + y ;
end

%       - Vkappa_cv1 and Vkappa_cv2: grid over values 0.05 - 0.4; 
x = 0.35/(depth_var_phimain-1) ;
y = (0.05*depth_var_phimain-0.4)/(depth_var_phimain-1) ;
for Vkcv1 = 1:1:depth_var_phimain
    phi(7,:,:,:,:,:,:,Vkcv1,:,:,:,:,:,:,:,:,:,:,:,:,:,:,:,:,:,:,:,:) = x*Vkcv1 + y ;
end
for Vkcv2 = 1:1:depth_var_phimain
    phi(8,:,:,:,:,:,:,:,Vkcv2,:,:,:,:,:,:,:,:,:,:,:,:,:,:,:,:,:,:,:) = x*Vkcv2 + y ;
end

%       - Vkappa_y1v1 and Vkappa_y2v2: grid over values 0.01 - 0.2; 
x = 0.19/(depth_var_phimain-1) ;
y = (0.01*depth_var_phimain-0.2)/(depth_var_phimain-1) ;
for Vky1v1 = 1:1:depth_var_phimain
    phi(9,:,:,:,:,:,:,:,:,Vky1v1,:,:,:,:,:,:,:,:,:,:,:,:,:,:,:,:,:,:) = x*Vky1v1 + y ;
end
for Vky2v2 = 1:1:depth_var_phimain
    phi(12,:,:,:,:,:,:,:,:,:,:,:,Vky2v2,:,:,:,:,:,:,:,:,:,:,:,:,:,:,:) = x*Vky2v2 + y ;
end

%       - Vkappa_y1v2 and Vkappa_y2v1: grid over values 0.01 - 0.1; 
x = 0.09/(depth_var_phicross-1) ;
y = (0.01*depth_var_phicross-0.1)/(depth_var_phicross-1) ;
for Vky1v2 = 1:1:depth_var_phicross
    phi(10,:,:,:,:,:,:,:,:,:,Vky1v2,:,:,:,:,:,:,:,:,:,:,:,:,:,:,:,:,:) = x*Vky1v2 + y ;
end
for Vky2v1 = 1:1:depth_var_phicross
    phi(11,:,:,:,:,:,:,:,:,:,:,Vky2v1,:,:,:,:,:,:,:,:,:,:,:,:,:,:,:,:) = x*Vky2v1 + y ;
end

%       - Covariances Ckappa_cv1_cv2; Ckappa_y1v1_y1v2; Ckappa_y2v1_y2v2:
%   these are most likely positive because of the underlying structure of
%   the problem (the transmission parameters in each pair are functions of
%   the same underlying Frisch elasticities), so I implement a grid over
%   grid over values 0.03 - 0.15:
x = 0.12/(depth_cov_phi-1) ;
y = (0.03*depth_cov_phi-0.15)/(depth_cov_phi-1) ;
for Ckappa = 1:1:depth_cov_phi
    phi(13,:,:,:,:,:,:,:,:,:,:,:,:,Ckappa,:,:,:,:,:,:,:,:,:,:,:,:,:,:) = x*Ckappa + y ;
end
for Ckappa = 1:1:depth_cov_phi
    phi(22,:,:,:,:,:,:,:,:,:,:,:,:,:,:,:,:,:,:,:,:,:,Ckappa,:,:,:,:,:) = x*Ckappa + y ;
end
for Ckappa = 1:1:depth_cov_phi
    phi(27,:,:,:,:,:,:,:,:,:,:,:,:,:,:,:,:,:,:,:,:,:,:,:,:,:,:,Ckappa) = x*Ckappa + y ;
end

%       - All other covariances: I assume that they are zero, otherwise
%   the problem becomes computationally too large.

%   B. Estimate over all possible values for the moments of the 
%   transmission parameters of permanent shocks.
%   
%   As there are 27 moments for all transmission parameters of permanent 
%   shocks, a meaningfully large loop over values for all of them is 
%   quickly subject to the curse of dimensionality. To avoid this, I
%   acknowledge that certain pairs of transmission parameters will in
%   practice be similar in value. For example, if male permanent shocks are
%   on average transmitted into consumption by 30%, it is unlikely that 
%   female shocks are transmitted by 0% (full insurance) or 100% (autarky).
%   In reality the value for the transmission of female shocks should be 
%   *around* 30%. Similarly, the values of the two transmission parameters 
%   of own shocks to own earnings should be similar; similarly for: 
%   -two transmission parameters of shocks to the partner's earnings. 
%   -variances V(kappa_cv1) and V(kappa_cv2)  
%   -variances V(kappa_y1v1) and V(kappa_y1v2) 
%   -variances V(kappa_y2v1) and V(kappa_y2v2).
%   -covariances C(kappa_cv1, kappa_cv2); C(kappa_y1v1, kappa_y1v2); and
%                C(kappa_y2v1, kappa_y2v2).
%   
%   This implies that in an array of results over all possible values for 
%   these parameters, results on and around the diagonal of such array
%   are more 'realistic' than results off the diagonal. In this spirit, I
%   do not calculate results away from this hypothetical diagonal, thus I
%   save on the dimensionality of the problem.

%   -----------------------------------------------------------------------

%   Initialize arrays to hold results:
vModelHat_timeaggr = NaN(length(vModelHat_c1.PREF), ...
                            depth_avg_phi,depth_avg_phi, ...
                            depth_avg_phi,depth_avg_phi, ...
                            depth_avg_phi,depth_avg_phi, ...
                            depth_var_phimain,depth_var_phimain, ...
                            depth_var_phicross,depth_cov_phi) ; 
modelFval_timeaggr = NaN(1,depth_avg_phi,depth_avg_phi, ...
                            depth_avg_phi,depth_avg_phi, ...
                            depth_avg_phi,depth_avg_phi, ...
                            depth_var_phimain,depth_var_phimain, ...
                            depth_var_phicross,depth_cov_phi) ;
modelFlag_timeaggr = NaN(1,depth_avg_phi,depth_avg_phi, ...
                            depth_avg_phi,depth_avg_phi, ...
                            depth_avg_phi,depth_avg_phi, ...
                            depth_var_phimain,depth_var_phimain, ...
                            depth_var_phicross,depth_cov_phi) ;

%   Model estimation - preferred specification, avoiding calculating
%   results for pairs of transmission parameters off the aforementioned
%   hypothetical diagonal:
tic;
%   B1. Loop over values for E(kappa_cv1)
for kcv1 = 1:1:depth_avg_phi
    %   -declare loop over E(kappa_cv1) that avoids elements off-diagonal:
    if kcv1==1 && depth_avg_phi~=2; kcv2_range = 1:1:3 ;
    elseif kcv1==1 && depth_avg_phi==2; kcv2_range = 1:1:2 ;
    elseif kcv1==depth_avg_phi && depth_avg_phi~=2; kcv2_range = (depth_avg_phi-2):1:depth_avg_phi ;
    elseif kcv1==depth_avg_phi && depth_avg_phi==2; kcv2_range = 1:1:depth_avg_phi ;
    else; kcv2_range = (kcv1-1):1:(kcv1+1) ; 
    end
    
%   B2. Loop over values for E(kappa_cv2)
    for kcv2 = kcv2_range
        
%   B3. Loop over values for E(kappa_y1v1)
        for ky1v1 = 1:1:depth_avg_phi
            %   -declare loop over E(kappa_y2v2) that avoids elements 
            %   off-diagonal:
            if ky1v1==1 && depth_avg_phi~=2; ky2v2_range = 1:1:3 ;
            elseif ky1v1==1 && depth_avg_phi==2; ky2v2_range = 1:1:2 ;
            elseif ky1v1==depth_avg_phi && depth_avg_phi~=2; ky2v2_range = (depth_avg_phi-2):1:depth_avg_phi ;
            elseif ky1v1==depth_avg_phi && depth_avg_phi==2; ky2v2_range = 1:1:depth_avg_phi ;
            else; ky2v2_range = (ky1v1-1):1:(ky1v1+1) ;
            end
            
%   B4. Loop over values for E(kappa_y2v2)
            for ky2v2 = ky2v2_range

%   B5. Loop over values for E(kappa_y1v2)
                for ky1v2 = 1:1:depth_avg_phi
                    %   -declare loop over E(kappa_y2v1) that avoids  
                    %   elements off-diagonal:
                    if ky1v2==1 && depth_avg_phi~=2; ky2v1_range = 1:1:3 ;
                    elseif ky1v2==1 && depth_avg_phi==2; ky2v1_range = 1:1:2 ;
                    elseif ky1v2==depth_avg_phi && depth_avg_phi~=2; ky2v1_range = (depth_avg_phi-2):1:depth_avg_phi ;
                    elseif ky1v2==depth_avg_phi && depth_avg_phi==2; ky2v1_range = 1:1:depth_avg_phi ;
                    else; ky2v1_range = (ky1v2-1):1:(ky1v2+1) ;
                    end
                    
%   B6. Loop over values for E(kappa_y2v1)
                    for ky2v1 = ky2v1_range
                        
%   B7. Loop over values for Vkappa_cv1 and Vkappa_cv2:
                        for Vkcvj = 1:1:depth_var_phimain
                            
%   B8. Loop over values for Vkappa_y1v1 and Vkappa_y2v2:
                            for Vkyjvj = 1:1:depth_var_phimain
 
%   B9. Loop over values for Vkappa_y1v2 and Vkappa_y2v1:
                                for Vkyjvk = 1:1:depth_var_phicross 

%   B10. Loop over values for covariances Ckappa_cv1_cv2, Ckappa_y1v1_y1v2, Ckappa_y2v1_y2v2: 
                                    for Ckappa = 1:1:depth_cov_phi
    [vModelHat_timeaggr(:,kcv1,kcv2,ky1v1,ky1v2,ky2v1,ky2v2,Vkcvj,Vkyjvj,Vkyjvk,Ckappa), ...
     modelFval_timeaggr(1,kcv1,kcv2,ky1v1,ky1v2,ky2v1,ky2v2,Vkcvj,Vkyjvj,Vkyjvk,Ckappa), ...
     modelFlag_timeaggr(1,kcv1,kcv2,ky1v1,ky1v2,ky2v1,ky2v2,Vkcvj,Vkyjvj,Vkyjvk,Ckappa)] = ...
        estm_model_timeaggr(vWageHat_timeaggr, emp_MATCHED_c1(24:80), mAvg_c1, 'notify-detailed', 1, 7, 'off', 'eye', months_in_year, ...
                            phi(:,kcv1,kcv2,ky1v1,ky1v2,ky2v1,ky2v2,Vkcvj,Vkcvj,Vkyjvj,Vkyjvk,Vkyjvk,Vkyjvj,Ckappa,1,1,1,1,1,1,1,1,Ckappa,1,1,1,1,Ckappa)) ;
     fprintf('Time Aggr round : kcv1=%1$u, kcv2=%2$u, ky1v1=%3$u, ky2v2=%4$u, ky1v2=%5$u, ky2v1=%6$u, Vkcvj=%7$u, Vkyjvj=%8$u, Vkyjvk=%9$u, Ckappa=%10$u.\n',...
             kcv1,kcv2,ky1v1,ky2v2,ky1v2,ky2v1,Vkcvj,Vkyjvj,Vkyjvk,Ckappa)
                                    end %Ckappa
                                end %Vkyjvk
                            end %Vkyjvj
                        end %Vkcvj
                    end %ky2v1
                end %ky1v2
            end %ky2v2
        end %ky1v1
    end %kcv2
end %kcv1
toc;

%   Clear redundant variables:
clearvars *_range kcv1 kcv2 ky1v1 ky1v2 ky2v1 ky2v2 Vkcv* Vkyjv* Vky1v* Vky2v* Ckappa phi x y ;


%%  3.  DELIVER RESULTS FOR PREFERENCES
%   Delivers summary statistics for preferences.
%   -----------------------------------------------------------------------

%   Initialize matrices for summary statistics:
timeaggr_pref_lowestfval    = zeros(length(vModelHat_c1.PREF),1) ;
timeaggr_pref_means         = zeros(length(vModelHat_c1.PREF)-1,1) ;
timeaggr_pref_std           = zeros(length(vModelHat_c1.PREF)-1,1) ;
timeaggr_pref_central50     = zeros(length(vModelHat_c1.PREF)-1,2) ;

%   Assemble summary statistics by parameter estimate:
for pp = 1:1:(length(vModelHat_c1.PREF)-1)
    %   -retrieve parameter estimates:
    param = vModelHat_timeaggr(pp,:,:,:,:,:,:,:,:,:,:) ;
    %   -parameter mean:
    timeaggr_pref_means(pp) = nanmean(param(:)) ;
    %   -parameter standard deviation:
    timeaggr_pref_std(pp)   = nanstd(param(:)) ;
    %   -central 50% of parameter estimates:
    timeaggr_pref_central50(pp,1) = quantile(param(:),0.25) ; 
    timeaggr_pref_central50(pp,2) = quantile(param(:),0.75) ;
end

%   Retrieve parameter estimate that delivers lowest fval:
[~,I] = min(modelFval_timeaggr(1,:)) ;
vectorize_est = vModelHat_timeaggr(1:length(vModelHat_c1.PREF),:) ;
timeaggr_pref_lowestfval(:,1) = vectorize_est(:,I) ;

%   Place results in array, round up:
prefResults_timeaggr = [timeaggr_pref_lowestfval(1:(length(vModelHat_c1.PREF)-1)) timeaggr_pref_means timeaggr_pref_std timeaggr_pref_central50] ;
prefResults_timeaggr = round(prefResults_timeaggr,3) ;

%   Export preference results:
xlswrite(strcat(dDir,'/tables/table_g1.csv'),prefResults_timeaggr,1)

%   Clear redundant variables:
clearvars pp param vectorize_est I timeaggr_pref_lowestfval timeaggr_pref_means timeaggr_pref_std timeaggr_pref_central50 preffilenamexls 
clearvars depth* months_in_year