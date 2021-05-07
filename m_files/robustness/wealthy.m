
%%  Subsamples of wealthy households
%
%   'Consumption Inequality across Heterogeneous Families'
%   This script estimates (point-estimates and bootstrap standard errors) 
%   the preferred specification of the model on wealthy households. It 
%   collects the results in tables.
%
%   Alexandros Theloudis
%   LISER Luxembourg 
%   Tilburg Econometrics & Operations Research 
%   Spring 2021
%
%   =======================================================================

%   Initial statements:
global  vWageHat vModelHat_c1 do num_boots dDir ;

%   Initialize matrices to hold wage results across wealth regimes:
w_wageHat       = NaN(length(vWageHat),4) ;
w_wageFval      = NaN(1,4) ;
w_wageFlag      = NaN(1,4) ;
w_wagesSe       = NaN(length(vWageHat),4) ;
mbs_w_Wage      = zeros(length(w_wageHat(:,1)),num_boots,4) ;
mbs_w_WageFval  = zeros(1,num_boots,4) ;
mbs_w_WageFlag  = zeros(1,num_boots,4) ;

%   Initialize matrices to hold preferences results across wealth regimes:
w_modelHat      = NaN(length(vModelHat_c1.PREF),4) ;
w_modelFval     = NaN(1,4) ;
w_modelFlag     = NaN(1,4) ;
w_modelInfer    = NaN(length(vModelHat_c1.PREF(1:14)),4) ;
mbs_w_Model     = zeros(length(w_modelHat(:,1)),num_boots,4) ;
mbs_w_ModelFval = zeros(1,num_boots,4) ;
mbs_w_ModelFlag = zeros(1,num_boots,4) ;

%   Initiate loop over six wealth regimes:
%       Wealth regime 1: annual wealth > mean annual consumption
%       Wealth regime 2: annual wealth > double mean annual consumption
%       Wealth regime 3: annual wealth > mean annual consumption & annual real debt < $2000
%       Wealth regime 4: annual wealth net of home equity > mean annual consumption & annual real debt < $2000
for wr = 1:1:4

    %   Read data on 'wealthy':
    [w_mCouple, w_mInd, w_mEs, w_mPi, w_mErr, w_mAvg, ~, ~] = ...
        handleData(strcat(dDir,'/inputs/_Cond_wr',num2str(wr),'/wr',num2str(wr),'_PSID.csv'),...
                   strcat(dDir,'/inputs/_Cond_wr',num2str(wr),'/wr',num2str(wr),'_PSID_me.csv'),...
                   strcat(dDir,'/inputs/_Cond_wr',num2str(wr),'/avgrat_wr',num2str(wr),'.csv'),[]) ;

    %   Wage estimation:
    [w_wageHat(:,wr), w_wageFval(:,wr), w_wageFlag(:,wr)] = ...
        estm_wages(w_mCouple, w_mInd, w_mErr, 'iter', 1, 'eye') ;
    
    %   Model estimation - preferred specification:
    [w_modelHat(:,wr), w_modelFval(:,wr), w_modelFlag(:,wr)] = ...
        estm_model(w_wageHat(:,wr), w_mCouple, w_mInd, w_mEs, w_mPi, w_mErr, w_mAvg, 'iter', 1, 7, 3, 0.15, 'off', 'eye') ;
    
    %   Clear original data on 'wealthy':
    clearvars w_mCouple w_mIndd w_mEs w_mPi w_mErr w_mAvg

    %   Inference:
    if do.inference == 1

        %   Run bootstrap loop:
        for wk = 1:num_boots

            %   Read bootstrap data:
            bs_dat = strcat(dDir,'/inputs/_Cond_wr',num2str(wr),'/wr',num2str(wr),'_bs_',num2str(wk),'.csv') ;
            bs_err = strcat(dDir,'/inputs/_Cond_wr',num2str(wr),'/wr',num2str(wr),'_me_bs_',num2str(wk),'.csv') ;
            bs_avg = strcat(dDir,'/inputs/_Cond_wr',num2str(wr),'/avgrat_wr',num2str(wr),'_bs_',num2str(wk),'.csv') ;
            [mbs_w_Couple, mbs_w_Ind, mbs_w_Es, mbs_w_Pi, mbs_w_Err, mbs_w_Avg, ~, ~] = ...
                handleData(bs_dat,bs_err,bs_avg,[]) ;

            %   Bootstrap wage parameters:
            [mbs_w_Wage(:,wk,wr), mbs_w_WageFval(1,wk,wr), mbs_w_WageFlag(1,wk,wr)] = ...
                estm_wages(mbs_w_Couple, mbs_w_Ind, mbs_w_Err, 'notify-detailed', 1, 'eye') ;

            %   Bootstrap model parameters:
            [mbs_w_Model(:,wk,wr), mbs_w_ModelFval(1,wk,wr), mbs_w_ModelFlag(1,wk,wr)] = ...
                estm_model(bswagehat, mbs_w_Couple, mbs_w_Ind, mbs_w_Es, mbs_w_Pi, mbs_w_Err, mbs_w_Avg, 'notify-detailed', 1, 7, 3, 0.15, 'off', 'eye') ;

            %   Clear bootstrap data of this round:
            clearvars bs_* mbs_w_Couple mbs_w_Ind mbs_w_Es mbs_w_Pi mbs_w_Err mbs_w_Avg

            %   Report progress:
            fprintf('Finished Bootstrap Estimation Wealthy %u round %u\n',[wr,wk])
        end %wk
        clearvars wk
        
        %   Calculate wage standard errors applying normal approximation  
        %   to the interquartile range of bootstrap replications 
        %   (IQR =~ 1.349 sigma):
        w_wagesSe(:,wr) = iqr(mbs_w_Wage(:,:,wr),2) / 1.349 ;
        
        %   Deliver model standard errors applying normal approximation to  
        %   the interquartile range of bootstrap replications. These 
        %   standard errors are inconsistent for the variance estimates:
        se_w_Model = iqr(mbs_w_Model(:,:,wr),2) / 1.349 ;
        
        %   Estimate p-values for the variance estimates (see bootstrap.m
        %   for details):
        bsquantiles = sort(mbs_w_Model(5:8,:,wr) - mean(mbs_w_Model(5:8,:,wr),2),2) ;
        pvals = zeros(4,1) ;
        for paramvar = 1:4 % looping over variance parameters
            pvl = 1-find(bsquantiles(paramvar,:)>=w_modelHat(4+paramvar,wr),1)/num_boots ;
            if isempty(pvl)==1  % result is empty if parameter estimate super highly significant
                pvals(paramvar) = 0.0 ;     
            else
                pvals(paramvar) = pvl ;
            end
        end %for paramvar
        
        %   Put standard errors and p-values together:
        w_modelInfer(:,wr) = [se_w_Model(1:4);pvals;se_w_Model(9:14)] ;
        clearvars bsquantiles paramvar pvl pvals se_w_Model
    end %do.inference
end % for wr
clearvars wr

%   Load bootstrap results if bootstrap is not run:
if do.inference==0
    load(strcat(dDir,'/exports/results/robustness/w_modelInfer'),'w_modelInfer')    
end

%  	Export table with results (part of table E.9):

%   Declare model parameter names:
eta_c_w1                = w_modelHat(1,:)   ;
se_eta_c_w1             = w_modelInfer(1,:) ;
eta_c_w2                = w_modelHat(2,:)   ;
se_eta_c_w2             = w_modelInfer(2,:) ;
eta_h1_w1               = w_modelHat(3,:)   ;
se_eta_h1_w1            = w_modelInfer(3,:) ;
eta_h2_w2               = w_modelHat(4,:)   ;
se_eta_h2_w2            = w_modelInfer(4,:) ;
Veta_c_w1               = w_modelHat(5,:)   ;
pv_Veta_c_w1            = w_modelInfer(5,:) ;
Veta_c_w2               = w_modelHat(6,:)   ;
pv_Veta_c_w2            = w_modelInfer(6,:) ;
Veta_h1_w1              = w_modelHat(7,:)   ;
pv_Veta_h1_w1           = w_modelInfer(7,:) ;
Veta_h2_w2              = w_modelHat(8,:)   ;
pv_Veta_h2_w2           = w_modelInfer(8,:) ;
COVeta_c_w1_c_w2        = w_modelHat(9,:)   ;
se_COVeta_c_w1_c_w2     = w_modelInfer(9,:) ;
COVeta_c_w1_h1_w1       = w_modelHat(10,:)  ;
se_COVeta_c_w1_h1_w1    = w_modelInfer(10,:);
COVeta_c_w1_h2_w2       = w_modelHat(11,:)  ;
se_COVeta_c_w1_h2_w2    = w_modelInfer(11,:);    
COVeta_c_w2_h1_w1       = w_modelHat(12,:)  ;
se_COVeta_c_w2_h1_w1    = w_modelInfer(12,:); 
COVeta_c_w2_h2_w2       = w_modelHat(13,:)  ;
se_COVeta_c_w2_h2_w2    = w_modelInfer(13,:);
COVeta_h1_w1_h2_w2      = w_modelHat(14,:)  ;
se_COVeta_h1_w1_h2_w2   = w_modelInfer(14,:);
    
%   Then create table:
w_mtable = [     eta_c_w1 ; se_eta_c_w1 ; eta_c_w2 ; se_eta_c_w2 ; ... 
                 eta_h1_w1 ; se_eta_h1_w1 ; eta_h2_w2 ; se_eta_h2_w2 ; ...
                 Veta_c_w1 ; pv_Veta_c_w1 ; Veta_c_w2 ; pv_Veta_c_w2 ; ...
                 Veta_h1_w1 ; pv_Veta_h1_w1 ; Veta_h2_w2 ; pv_Veta_h2_w2 ; ...
                 COVeta_c_w1_c_w2 ; se_COVeta_c_w1_c_w2 ; COVeta_c_w1_h1_w1 ; se_COVeta_c_w1_h1_w1 ; COVeta_c_w1_h2_w2 ; se_COVeta_c_w1_h2_w2 ; ...
                 COVeta_c_w2_h1_w1 ; se_COVeta_c_w2_h1_w1 ; COVeta_c_w2_h2_w2 ; se_COVeta_c_w2_h2_w2 ; COVeta_h1_w1_h2_w2 ; se_COVeta_h1_w1_h2_w2 ] ;
             
%   Write table:
w_mtable    = round(w_mtable,3) ;
xlswrite(strcat(dDir,'/tables/table_e9_w.csv'),w_mtable,1)
clearvars eta_c_w1 se_eta_c_w1 eta_c_w2 se_eta_c_w2 eta_h1_w1 se_eta_h1_w1 eta_h2_w2 se_eta_h2_w2 ;
clearvars Veta_c_w1 pv_Veta_c_w1 Veta_c_w2 pv_Veta_c_w2 Veta_h1_w1 pv_Veta_h1_w1 Veta_h2_w2 pv_Veta_h2_w2 ; 
clearvars COVeta_c_w1_c_w2 se_COVeta_c_w1_c_w2 COVeta_c_w1_h1_w1 se_COVeta_c_w1_h1_w1 COVeta_c_w1_h2_w2 se_COVeta_c_w1_h2_w2 ;
clearvars COVeta_c_w2_h1_w1 se_COVeta_c_w2_h1_w1 COVeta_c_w2_h2_w2 se_COVeta_c_w2_h2_w2 COVeta_h1_w1_h2_w2 se_COVeta_h1_w1_h2_w2 ;
clearvars mfilename* mbs_w* w_*