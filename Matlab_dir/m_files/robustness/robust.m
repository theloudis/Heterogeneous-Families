
%%  Subsamples that omit extreme observations in wages/earnings/consumption
%
%   'Consumption Inequality across Heterogeneous Families'
%   This script estimates (point-estimates and bootstrap standard errors) 
%   the preferred model on three 'robust' subsamples where extreme 
%   observations on wages, earnings, consumption are dropped.
%
%   Alexandros Theloudis
%   LISER Luxembourg 
%   Tilburg Econometrics & Operations Research 
%   Spring 2021
%
%   =======================================================================

%   Initial statements:
global  vWageHat vModelHat_c1 do num_boots dDir ;

%   Initialize matrices to hold wage results across robust subsamples:
r_wageHat    = NaN(length(vWageHat),3) ;
r_wageFval   = NaN(1,3) ;
r_wageFlag   = NaN(1,3) ;
r_wagesSe    = NaN(length(vWageHat),3) ;
mbs_r_Wage      = zeros(length(r_wageHat(:,1)),num_boots,3);
mbs_r_WageFval  = zeros(1,num_boots,3);
mbs_r_WageFlag  = zeros(1,num_boots,3);

%   Initialize matrices to hold preference results across robust subsamples:
r_modelHat   = NaN(length(vModelHat_c1.PREF),3) ;
r_modelFval  = NaN(1,3) ;
r_modelFlag  = NaN(1,3) ;
r_modelInfer = NaN(length(vModelHat_c1.PREF(1:14)),3) ;
mbs_r_Model     = zeros(length(r_modelHat(:,1)),num_boots,3);
mbs_r_ModelFval = zeros(1,num_boots,3);
mbs_r_ModelFlag = zeros(1,num_boots,3);
        
%   Initiate loop over three 'robust' subsamples:
%       Robust subsample 1: Trim bottom and top 0.5% of distribution of wages
%       Robust subsample 2: Trim bottom and top 2.0% of distribution of wages
%       Robust subsample 3: Trim bottom and top 0.5% of all variables
for rr = 1:1:3

    %   Read data of 'robust' subsamples:
    [r_mCouple, r_mInd, r_mEs, r_mPi, r_mErr, r_mAvg, ~, ~] = ...
        handleData(strcat(dDir,'/inputs/_Cond_rr',num2str(rr),'/rr',num2str(rr),'_PSID.csv'),...
                   strcat(dDir,'/inputs/_Cond_rr',num2str(rr),'/rr',num2str(rr),'_PSID_me.csv'),...
                   strcat(dDir,'/inputs/_Cond_rr',num2str(rr),'/avgrat_rr',num2str(rr),'.csv'),[]) ;

    %   Wage estimation:
    [r_wageHat(:,rr), r_wageFval(:,rr), r_wageFlag(:,rr)] = ...
        estm_wages(r_mCouple, r_mInd,r_mErr, 'iter', 1, 'eye') ;

    %   Model estimation - preferred specification:
    [r_modelHat(:,rr), r_modelFval(:,rr), r_modelFlag(:,rr)] = ...
        estm_model(r_wageHat(:,rr), r_mCouple, r_mInd, r_mEs, r_mPi, r_mErr, r_mAvg, 'iter', 1, 7, 3, 0.15, 'off', 'eye') ;

    %   Clear original data on 'robust':
    clearvars r_mCouple r_mInd r_mEs r_mPi r_mErr r_mAvg

    %   Inference:
    if do.inference == 1
        
        %   Run bootstrap loop:
        for rk = 1:num_boots

            %   Read bootstrap data:            
            bs_dat = strcat(dDir,'/inputs/_Cond_rr',num2str(rr),'/rr',num2str(rr),'_bs_',num2str(rk),'.csv') ;
            bs_err = strcat(dDir,'/inputs/_Cond_rr',num2str(rr),'/rr',num2str(rr),'_me_bs_',num2str(rk),'.csv') ;
            bs_avg = strcat(dDir,'/inputs/_Cond_rr',num2str(rr),'/avgrat_rr',num2str(rr),'_bs_',num2str(rk),'.csv') ;
            [mbs_r_Couple, mbs_r_Ind, mbs_r_Es, mbs_r_Pi, mbs_r_Err, mbs_r_Avg, ~, ~] = ...
                handleData(bs_dat,bs_err,bs_avg,[]) ;

            %   Bootstrap wage parameters:
            [mbs_r_Wage(:,rk,rr), mbs_r_WageFval(1,rk,rr), mbs_r_WageFlag(1,rk,rr)] = ...
                estm_wages(mbs_r_Couple, mbs_r_Ind, mbs_r_Err, 'notify-detailed', 1, 'eye') ;

            %   Bootstrap model parameters:
            [mbs_r_Model(:,rk,rr), mbs_r_ModelFval(1,rk,rr), mbs_r_ModelFlag(1,rk,rr)] = ...
                estm_model(bswagehat, mbs_r_Couple, mbs_r_Ind, mbs_r_Es, mbs_r_Pi, mbs_r_Err, mbs_r_Avg, 'notify-detailed', 1, 7, 3, 0.15, 'off', 'eye') ;

            %   Clear bootstrap data of this round:
            clearvars bs_* mbs_r_Couple mbs_r_Ind mbs_r_Es mbs_r_Pi mbs_r_Err mbs_r_Avg

            %   Report progress:
            fprintf('Robust regime %u finished bootstrap estimation round %u\n', [rr, rk])
        end %for rk
        clearvars rk
        
        %   Calculate wage standard errors applying normal approximation  
        %   to the interquartile range of bootstrap replications 
        %   (IQR =~ 1.349 sigma):
        r_wagesSe(:,rr) = iqr(mbs_r_Wage(:,:,rr),2) / 1.349 ;
        
        %   Deliver model standard errors applying normal approximation to  
        %   the interquartile range of bootstrap replications. These 
        %   standard errors are inconsistent for the variance estimates:
        se_r_Model = iqr(mbs_r_Model(:,:,rr),2) / 1.349 ;
        
        %   Estimate p-values for the variance estimates (see bootstrap.m
        %   for details):
        bsquantiles = sort(mbs_r_Model(5:8,:,rr) - mean(mbs_r_Model(5:8,:,rr),2),2) ;
        pvals = zeros(4,1) ;
        for paramvar = 1:4 % looping over variance parameters
            pvl = 1-find(bsquantiles(paramvar,:)>=r_modelHat(4+paramvar,rr),1)/num_boots ;
            if isempty(pvl)==1  % result is empty if parameter estimate super highly significant
                pvals(paramvar) = 0.0 ;     
            else
                pvals(paramvar) = pvl ;
            end
        end %for paramvar
        
        %   Put standard errors and p-values together:
        r_modelInfer(:,rr) = [se_r_Model(1:4);pvals;se_r_Model(9:14)] ;
        clearvars bsquantiles paramvar pvl pvals se_r_Model
    end %do.inference
end % for rr
clearvars rr

%   Load bootstrap results if bootstrap is not run:
if do.inference==0
    load(strcat(dDir,'/exports/results/robustness/r_modelInfer'),'r_modelInfer')    
end

%  	Export table with results (table E.2):
    
%   Declare model parameter names:
eta_c_w1                = r_modelHat(1,:)   ;
se_eta_c_w1             = r_modelInfer(1,:) ;
eta_c_w2                = r_modelHat(2,:)   ;
se_eta_c_w2             = r_modelInfer(2,:) ;
eta_h1_w1               = r_modelHat(3,:)   ;
se_eta_h1_w1            = r_modelInfer(3,:) ;
eta_h2_w2               = r_modelHat(4,:)   ;
se_eta_h2_w2            = r_modelInfer(4,:) ;
Veta_c_w1               = r_modelHat(5,:)   ;
pv_Veta_c_w1            = r_modelInfer(5,:) ;
Veta_c_w2               = r_modelHat(6,:)   ;
pv_Veta_c_w2            = r_modelInfer(6,:) ;
Veta_h1_w1              = r_modelHat(7,:)   ;
pv_Veta_h1_w1           = r_modelInfer(7,:) ;
Veta_h2_w2              = r_modelHat(8,:)   ;
pv_Veta_h2_w2           = r_modelInfer(8,:) ;
COVeta_c_w1_c_w2        = r_modelHat(9,:)   ;
se_COVeta_c_w1_c_w2     = r_modelInfer(9,:) ;
COVeta_c_w1_h1_w1       = r_modelHat(10,:)  ;
se_COVeta_c_w1_h1_w1    = r_modelInfer(10,:);
COVeta_c_w1_h2_w2       = r_modelHat(11,:)  ;
se_COVeta_c_w1_h2_w2    = r_modelInfer(11,:);    
COVeta_c_w2_h1_w1       = r_modelHat(12,:)  ;
se_COVeta_c_w2_h1_w1    = r_modelInfer(12,:); 
COVeta_c_w2_h2_w2       = r_modelHat(13,:)  ;
se_COVeta_c_w2_h2_w2    = r_modelInfer(13,:);
COVeta_h1_w1_h2_w2      = r_modelHat(14,:)  ;
se_COVeta_h1_w1_h2_w2   = r_modelInfer(14,:);
    
%   Then create table:
r_mtable = [     eta_c_w1 ; se_eta_c_w1 ; eta_c_w2 ; se_eta_c_w2 ; ... 
                 eta_h1_w1 ; se_eta_h1_w1 ; eta_h2_w2 ; se_eta_h2_w2 ; ...
                 Veta_c_w1 ; pv_Veta_c_w1 ; Veta_c_w2 ; pv_Veta_c_w2 ; ...
                 Veta_h1_w1 ; pv_Veta_h1_w1 ; Veta_h2_w2 ; pv_Veta_h2_w2 ; ...
                 COVeta_c_w1_c_w2 ; se_COVeta_c_w1_c_w2 ; COVeta_c_w1_h1_w1 ; se_COVeta_c_w1_h1_w1 ; COVeta_c_w1_h2_w2 ; se_COVeta_c_w1_h2_w2 ; ...
                 COVeta_c_w2_h1_w1 ; se_COVeta_c_w2_h1_w1 ; COVeta_c_w2_h2_w2 ; se_COVeta_c_w2_h2_w2 ; COVeta_h1_w1_h2_w2 ; se_COVeta_h1_w1_h2_w2 ] ;
             
%   Write table:
r_mtable    = round(r_mtable,3) ;
xlswrite(strcat(dDir,'/tables/table_e2.csv'),r_mtable,1)
clearvars eta_c_w1 se_eta_c_w1 eta_c_w2 se_eta_c_w2 eta_h1_w1 se_eta_h1_w1 eta_h2_w2 se_eta_h2_w2 ;
clearvars Veta_c_w1 pv_Veta_c_w1 Veta_c_w2 pv_Veta_c_w2 Veta_h1_w1 pv_Veta_h1_w1 Veta_h2_w2 pv_Veta_h2_w2 ; 
clearvars COVeta_c_w1_c_w2 se_COVeta_c_w1_c_w2 COVeta_c_w1_h1_w1 se_COVeta_c_w1_h1_w1 COVeta_c_w1_h2_w2 se_COVeta_c_w1_h2_w2 ;
clearvars COVeta_c_w2_h1_w1 se_COVeta_c_w2_h1_w1 COVeta_c_w2_h2_w2 se_COVeta_c_w2_h2_w2 COVeta_h1_w1_h2_w2 se_COVeta_h1_w1_h2_w2 ;
clearvars mfilename* mbs_r* r_*