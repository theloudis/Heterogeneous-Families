
%%  Progressive joint taxation
%
%   'Consumption Inequality across Heterogeneous Families'
%   This scripts estimates preferences in the preferred specification 
%   of the model allowing for progressive joint taxation.
%
%   Alexandros Theloudis
%   LISER Luxembourg 
%   Tilburg Econometrics & Operations Research 
%   Spring 2021
%
%   =======================================================================

%   Initial statements:
global  vWageHat dDir do num_boots ;

%   Read baseline sample:
[mCouple_c1, mInd_c1, mEs_c1, mPi_c1, mErr_c1, mAvg_c1, ~, N_c1]  ...
    = handleData('_Cond1/original_PSID_c1.csv', ...
                 '_Cond1/original_PSID_me_c1.csv', ...
                 '_Cond1/avgrat_original_PSID_c1.csv',[]) ;

        
%%  1.  ESTIMATION OF MODEL WITH AND WITHOUT TAXES - VARIOUS SPECIFICATIONS
%   Implements the GMM estimation of the paramaters of the structural model 
%	with and without progressive joint taxation. Progressive taxation has
%   the progressivity parameter of taxes set at \nu=0.185 as in Heathcote,
%   Storesletten, Violante (2014). Estimation without taxation is meant
%   to come very close to the baseline estimation of the model (under
%   various specifications) if the assumption of joint normality of
%   preferences (imposed here throughout) is not too far from reality.
%   -----------------------------------------------------------------------

%   Taxes 1_nt: Second moments only, no taxes.
[tax1_xhat_nt, tax1_fval_nt, tax1_flag_nt] = ...
    estm_model_taxes(vWageHat, mCouple_c1, mInd_c1, mEs_c1, mErr_c1, mAvg_c1, 'iter', 0, 0, 3, 0.15, 0.0) ;  

%   Taxes 1_wt: Second moments only, with progressive taxes.
[tax1_xhat_wt, tax1_fval_wt, tax1_flag_wt] = ...
    estm_model_taxes(vWageHat, mCouple_c1, mInd_c1, mEs_c1, mErr_c1, mAvg_c1, 'iter', 0, 0, 3, 0.15, 0.185) ;  

%   Taxes 2_nt: Third moments, no taxes.
[tax2_xhat_nt, tax2_fval_nt, tax2_flag_nt] = ...
    estm_model_taxes(vWageHat, mCouple_c1, mInd_c1, mEs_c1, mErr_c1, mAvg_c1, 'iter', 1, 0, 3, 0.15, 0.0) ;  

%   Taxes 2_wt: Third moments, with progressive taxes.
[tax2_xhat_wt, tax2_fval_wt, tax2_flag_wt] = ...
    estm_model_taxes(vWageHat, mCouple_c1, mInd_c1, mEs_c1, mErr_c1, mAvg_c1, 'iter', 1, 0, 3, 0.15, 0.185) ;  

%   Taxes 3: Restricted heterogeneity, no taxes.
[tax3_xhat_nt, tax3_fval_nt, tax3_flag_nt] = ...
    estm_model_taxes(vWageHat, mCouple_c1, mInd_c1, mEs_c1, mErr_c1, mAvg_c1, 'iter', 1, 1, 3, 0.15, 0.0) ;  

%   Taxes 3: Restricted heterogeneity, with progressive taxes.
[tax3_xhat_wt, tax3_fval_wt, tax3_flag_wt] = ...
    estm_model_taxes(vWageHat, mCouple_c1, mInd_c1, mEs_c1, mErr_c1, mAvg_c1, 'iter', 1, 1, 3, 0.15, 0.185) ;  

%   Taxes 4: Preferred specification, no taxes.
[tax4_xhat_nt, tax4_fval_nt, tax4_flag_nt] = ...
    estm_model_taxes(vWageHat, mCouple_c1, mInd_c1, mEs_c1, mErr_c1, mAvg_c1, 'iter', 1, 7, 3, 0.15, 0.0) ;  

%   Taxes 4: Preferred specification, with progressive taxes.
[tax4_xhat_wt, tax4_fval_wt, tax4_flag_wt] = ...
    estm_model_taxes(vWageHat, mCouple_c1, mInd_c1, mEs_c1, mErr_c1, mAvg_c1, 'iter', 1, 7, 3, 0.15, 0.185) ;  


%%  2.  BOOTSTRAP FOR MODEL WITH TAXES - VARIOUS SPECIFICATIONS
%   Calculates standard-errors and p-values.
%   -----------------------------------------------------------------------

%   Run bootstrap:
if do.inference == 1
    
    %   Initialize objects to collect bootstrap information:
    mbs_tax1_nt_Model     = zeros(length(tax1_xhat_nt),num_boots) ;
    mbs_tax1_nt_ModelFval = zeros(1,num_boots) ;
    mbs_tax1_nt_ModelFlag = zeros(1,num_boots) ;

    mbs_tax1_wt_Model     = zeros(length(tax1_xhat_wt),num_boots) ;
    mbs_tax1_wt_ModelFval = zeros(1,num_boots) ;
    mbs_tax1_wt_ModelFlag = zeros(1,num_boots) ;

    mbs_tax2_nt_Model     = zeros(length(tax2_xhat_nt),num_boots) ;
    mbs_tax2_nt_ModelFval = zeros(1,num_boots) ;
    mbs_tax2_nt_ModelFlag = zeros(1,num_boots) ;

    mbs_tax2_wt_Model     = zeros(length(tax2_xhat_wt),num_boots) ;
    mbs_tax2_wt_ModelFval = zeros(1,num_boots) ;
    mbs_tax2_wt_ModelFlag = zeros(1,num_boots) ;

    mbs_tax3_nt_Model     = zeros(length(tax3_xhat_nt),num_boots) ;
    mbs_tax3_nt_ModelFval = zeros(1,num_boots) ;
    mbs_tax3_nt_ModelFlag = zeros(1,num_boots) ;

    mbs_tax3_wt_Model     = zeros(length(tax3_xhat_wt),num_boots) ;
    mbs_tax3_wt_ModelFval = zeros(1,num_boots) ;
    mbs_tax3_wt_ModelFlag = zeros(1,num_boots) ;

    mbs_tax4_nt_Model     = zeros(length(tax4_xhat_nt),num_boots) ;
    mbs_tax4_nt_ModelFval = zeros(1,num_boots) ;
    mbs_tax4_nt_ModelFlag = zeros(1,num_boots) ;

    mbs_tax4_wt_Model     = zeros(length(tax4_xhat_wt),num_boots) ;
    mbs_tax4_wt_ModelFval = zeros(1,num_boots) ;
    mbs_tax4_wt_ModelFlag = zeros(1,num_boots) ;

    %   Loop over bootstrap samples:
    for tk = 1:1:num_boots

        %   Read bootstrap data:
        bs_dat = sprintf('_Cond1/bs_%d.csv',k) ;
        bs_err = sprintf('_Cond1/me_c1_bs_%d.csv',k) ;
        bs_avg = sprintf('_Cond1/avgrat_bs_c1_%d.csv',k) ;
        [mbsC_c1,mbsI_c1,mbsE_c1,mbsPi_c1,mbsEr_c1,mbsA_c1,~,~] ...
            = handleData(bs_dat,bs_err,bs_avg,[]) ;
        clearvars bs_dat bs_err bs_avg

        %   Bootstrap wage parameters:
        bswagehat = estm_wages(mbsC_c1,mbsI_c1,mbsEr_c1,'notify-detailed',1,'eye') ;

        %   Bootstrap model parameters, model taxes 1_nt:
        [bsmodelhat,bsmodelfval,bsmodelflag] = ...
            estm_model_taxes(bswagehat, mbsC_c1, mbsI_c1, mbsE_c1, mbsEr_c1, mbsA_c1, 'notify-detailed', 0, 0, 3, 0.15, 0.0) ;
        mbs_tax1_nt_Model(:,tk)     = bsmodelhat ;
        mbs_tax1_nt_ModelFval(1,tk) = bsmodelfval ;
        mbs_tax1_nt_ModelFlag(1,tk) = bsmodelflag ;
        fprintf('Finished Bootstrap Estimation TAXES 1_nt round %u\n',tk)

        %   Bootstrap model parameters, model taxes 1_wt:
        [bsmodelhat,bsmodelfval,bsmodelflag] = ...
            estm_model_taxes(bswagehat, mbsC_c1, mbsI_c1, mbsE_c1, mbsEr_c1, mbsA_c1, 'notify-detailed', 0, 0, 3, 0.15, 0.185) ;
        mbs_tax1_wt_Model(:,tk)     = bsmodelhat ;
        mbs_tax1_wt_ModelFval(1,tk) = bsmodelfval ;
        mbs_tax1_wt_ModelFlag(1,tk) = bsmodelflag ;
        fprintf('Finished Bootstrap Estimation TAXES 1_wt round %u\n',tk)

        %   Bootstrap model parameters, model taxes 2_nt:
        [bsmodelhat,bsmodelfval,bsmodelflag] = ...
            estm_model_taxes(bswagehat, mbsC_c1, mbsI_c1, mbsE_c1, mbsEr_c1, mbsA_c1, 'notify-detailed', 1, 0, 3, 0.15, 0.0) ;
        mbs_tax2_nt_Model(:,tk)     = bsmodelhat ;
        mbs_tax2_nt_ModelFval(1,tk) = bsmodelfval ;
        mbs_tax2_nt_ModelFlag(1,tk) = bsmodelflag ;
        fprintf('Finished Bootstrap Estimation TAXES 2_nt round %u\n',tk)

        %   Bootstrap model parameters, model taxes 2_wt:
        [bsmodelhat,bsmodelfval,bsmodelflag] = ...
            estm_model_taxes(bswagehat, mbsC_c1, mbsI_c1, mbsE_c1, mbsEr_c1, mbsA_c1, 'notify-detailed', 1, 0, 3, 0.15, 0.185) ;
        mbs_tax2_wt_Model(:,tk)     = bsmodelhat ;
        mbs_tax2_wt_ModelFval(1,tk) = bsmodelfval ;
        mbs_tax2_wt_ModelFlag(1,tk) = bsmodelflag ;
        fprintf('Finished Bootstrap Estimation TAXES 2_wt round %u\n',tk)

        %   Bootstrap model parameters, model taxes 3_nt:
        [bsmodelhat,bsmodelfval,bsmodelflag] = ...
            estm_model_taxes(bswagehat, mbsC_c1, mbsI_c1, mbsE_c1, mbsEr_c1, mbsA_c1, 'notify-detailed', 1, 1, 3, 0.15, 0.0) ;
        mbs_tax3_nt_Model(:,tk)     = bsmodelhat ;
        mbs_tax3_nt_ModelFval(1,tk) = bsmodelfval ;
        mbs_tax3_nt_ModelFlag(1,tk) = bsmodelflag ;
        fprintf('Finished Bootstrap Estimation TAXES 3_nt round %u\n',tk)

        %   Bootstrap model parameters, model taxes 3_wt:
        [bsmodelhat,bsmodelfval,bsmodelflag] = ...
            estm_model_taxes(bswagehat, mbsC_c1, mbsI_c1, mbsE_c1, mbsEr_c1, mbsA_c1, 'notify-detailed', 1, 1, 3, 0.15, 0.185) ;
        mbs_tax3_wt_Model(:,tk)     = bsmodelhat ;
        mbs_tax3_wt_ModelFval(1,tk) = bsmodelfval ;
        mbs_tax3_wt_ModelFlag(1,tk) = bsmodelflag ;
        fprintf('Finished Bootstrap Estimation TAXES 3_wt round %u\n',tk)

        %   Bootstrap model parameters, model taxes 4_nt:
        [bsmodelhat,bsmodelfval,bsmodelflag] = ...
            estm_model_taxes(bswagehat, mbsC_c1, mbsI_c1, mbsE_c1, mbsEr_c1, mbsA_c1, 'notify-detailed', 1, 7, 3, 0.15, 0.0) ;
        mbs_tax4_nt_Model(:,tk)     = bsmodelhat ;
        mbs_tax4_nt_ModelFval(1,tk) = bsmodelfval ;
        mbs_tax4_nt_ModelFlag(1,tk) = bsmodelflag ;
        fprintf('Finished Bootstrap Estimation TAXES 4_nt round %u\n',tk)

        %   Bootstrap model parameters, model taxes 4_wt:
        [bsmodelhat,bsmodelfval,bsmodelflag] = ...
            estm_model_taxes(bswagehat, mbsC_c1, mbsI_c1, mbsE_c1, mbsEr_c1, mbsA_c1, 'notify-detailed', 1, 7, 3, 0.15, 0.185) ;
        mbs_tax4_wt_Model(:,tk)     = bsmodelhat ;
        mbs_tax4_wt_ModelFval(1,tk) = bsmodelfval ;
        mbs_tax4_wt_ModelFlag(1,tk) = bsmodelflag ;
        fprintf('Finished Bootstrap Estimation TAXES 4_wt round %u\n',tk)

        %   Clear bootstrap data of this round:
        clearvars bs* mbsCouple mbsInd mbsEs mbsPi mbsErr mbsAvg mbsMed nn
    end %tk
    clearvars tk

    %   Calculate standard errors and p-values for model taxes 1_nt:
    se_tax1_nt_Model = iqr(mbs_tax1_nt_Model,2) / 1.349 ;
    modelInfer_tax1_nt = se_tax1_nt_Model ;
    clearvars se_tax 

    %   Calculate standard errors and p-values for model taxes 1_wt:
    se_tax1_wt_Model = iqr(mbs_tax1_wt_Model,2) / 1.349 ;
    modelInfer_tax1_wt = se_tax1_wt_Model ;
    clearvars se_tax    

    %   Calculate standard errors and p-values for model taxes 2_nt:
    se_tax2_nt_Model = iqr(mbs_tax2_nt_Model,2) / 1.349 ;
    modelInfer_tax2_nt = se_tax2_nt_Model ;
    clearvars se_tax 

    %   Calculate standard errors and p-values for model taxes 2_wt:
    se_tax2_wt_Model = iqr(mbs_tax2_wt_Model,2) / 1.349 ;
    modelInfer_tax2_wt = se_tax2_wt_Model ;
    clearvars se_tax 

    %   Calculate standard errors and p-values for model taxes 3_nt:
    se_tax3_nt_Model = iqr(mbs_tax3_nt_Model,2) / 1.349 ;
    bsquantiles = sort(mbs_tax3_nt_Model(5:8,:) - mean(mbs_tax3_nt_Model(5:8,:),2),2) ;
    pvals = zeros(4,1) ;
    for paramvar = 1:4 % looping over variance parameters
        pvl = 1-find(bsquantiles(paramvar,:)>=tax3_xhat_nt(4+paramvar),1)/num_boots ;
        if isempty(pvl)==1  % result is empty if parameter estimate super highly significant
            pvals(paramvar) = 0.0 ;     
        else
            pvals(paramvar) = pvl ;
        end
    end %for paramvar
    modelInfer_tax3_nt = [se_tax3_nt_Model(1:4);pvals] ;
    clearvars bsquantiles paramvar pvl pvals se_tax       

    %   Calculate standard errors and p-values for model taxes 3_wt:
    se_tax3_wt_Model = iqr(mbs_tax3_wt_Model,2) / 1.349 ;
    bsquantiles = sort(mbs_tax3_wt_Model(5:8,:) - mean(mbs_tax3_wt_Model(5:8,:),2),2) ;
    pvals = zeros(4,1) ;
    for paramvar = 1:4 % looping over variance parameters
        pvl = 1-find(bsquantiles(paramvar,:)>=tax3_xhat_wt(4+paramvar),1)/num_boots ;
        if isempty(pvl)==1  % result is empty if parameter estimate super highly significant
            pvals(paramvar) = 0.0 ;     
        else
            pvals(paramvar) = pvl ;
        end
    end %for paramvar
    modelInfer_tax3_wt = [se_tax3_wt_Model(1:4);pvals] ;
    clearvars bsquantiles paramvar pvl pvals se_tax       

    %   Calculate standard errors and p-values for model taxes 4_nt:
    se_tax4_nt_Model = iqr(mbs_tax4_nt_Model,2) / 1.349 ;
    bsquantiles = sort(mbs_tax4_nt_Model(5:8,:) - mean(mbs_tax4_nt_Model(5:8,:),2),2) ;
    pvals = zeros(4,1) ;
    for paramvar = 1:4 % looping over variance parameters
        pvl = 1-find(bsquantiles(paramvar,:)>=tax4_xhat_nt(4+paramvar),1)/num_boots ;
        if isempty(pvl)==1  % result is empty if parameter estimate super highly significant
            pvals(paramvar) = 0.0 ;     
        else
            pvals(paramvar) = pvl ;
        end
    end %for paramvar
    modelInfer_tax4_nt = [se_tax4_nt_Model(1:4);pvals;se_tax4_nt_Model(9:14)] ;
    clearvars bsquantiles paramvar pvl pvals se_tax       

    %   Calculate standard errors and p-values for model taxes 4_wt:
    se_tax4_wt_Model = iqr(mbs_tax4_wt_Model,2) / 1.349 ;
    bsquantiles = sort(mbs_tax4_wt_Model(5:8,:) - mean(mbs_tax4_wt_Model(5:8,:),2),2) ;
    pvals = zeros(4,1) ;
    for paramvar = 1:4 % looping over variance parameters
        pvl = 1-find(bsquantiles(paramvar,:)>=tax4_xhat_wt(4+paramvar),1)/num_boots ;
        if isempty(pvl)==1  % result is empty if parameter estimate super highly significant
            pvals(paramvar) = 0.0 ;     
        else
            pvals(paramvar) = pvl ;
        end
    end %for paramvar
    modelInfer_tax4_wt = [se_tax4_wt_Model(1:4);pvals;se_tax4_wt_Model(9:14)] ;
    clearvars bsquantiles paramvar pvl pvals se_tax       

%   Retrieve results from memory:   
else
    load(strcat(dDir,'/exports/results/joint_taxation/modelInfer_tax1_nt'),'modelInfer_tax1_nt')
    load(strcat(dDir,'/exports/results/joint_taxation/modelInfer_tax1_wt'),'modelInfer_tax1_wt')
    load(strcat(dDir,'/exports/results/joint_taxation/modelInfer_tax2_nt'),'modelInfer_tax2_nt')
    load(strcat(dDir,'/exports/results/joint_taxation/modelInfer_tax2_wt'),'modelInfer_tax2_wt')
    load(strcat(dDir,'/exports/results/joint_taxation/modelInfer_tax3_nt'),'modelInfer_tax3_nt')
    load(strcat(dDir,'/exports/results/joint_taxation/modelInfer_tax3_wt'),'modelInfer_tax3_wt')
    load(strcat(dDir,'/exports/results/joint_taxation/modelInfer_tax4_nt'),'modelInfer_tax4_nt')
    load(strcat(dDir,'/exports/results/joint_taxation/modelInfer_tax4_wt'),'modelInfer_tax4_wt')

end %do.inference



%%  3.  EXPORT TABLE WITH RESULTS
%   Collect results in table but only export part that appears in table E.9.
%   -----------------------------------------------------------------------

%   Collect in table:
eta_c_w1                = [tax1_xhat_nt(1)          tax1_xhat_wt(1)         tax2_xhat_nt(1)         tax2_xhat_wt(1)         tax3_xhat_nt(1)         tax3_xhat_wt(1)         tax4_xhat_nt(1)         tax4_xhat_wt(1)       ];
se_eta_c_w1             = [modelInfer_tax1_nt(1)    modelInfer_tax1_wt(1)   modelInfer_tax2_nt(1)   modelInfer_tax2_wt(1)   modelInfer_tax3_nt(1)   modelInfer_tax3_wt(1)   modelInfer_tax4_nt(1)   modelInfer_tax4_wt(1) ];
eta_c_w2                = [tax1_xhat_nt(2)          tax1_xhat_wt(2)         tax2_xhat_nt(2)         tax2_xhat_wt(2)         tax3_xhat_nt(2)         tax3_xhat_wt(2)         tax4_xhat_nt(2)         tax4_xhat_wt(2)       ];
se_eta_c_w2             = [modelInfer_tax1_nt(2)    modelInfer_tax1_wt(2)   modelInfer_tax2_nt(2)   modelInfer_tax2_wt(2)   modelInfer_tax3_nt(2)   modelInfer_tax3_wt(2)   modelInfer_tax4_nt(2)   modelInfer_tax4_wt(2) ];
eta_h1_w1               = [tax1_xhat_nt(3)          tax1_xhat_wt(3)         tax2_xhat_nt(3)         tax2_xhat_wt(3)         tax3_xhat_nt(3)         tax3_xhat_wt(3)         tax4_xhat_nt(3)         tax4_xhat_wt(3)       ];
se_eta_h1_w1            = [modelInfer_tax1_nt(3)    modelInfer_tax1_wt(3)   modelInfer_tax2_nt(3)   modelInfer_tax2_wt(3)   modelInfer_tax3_nt(3)   modelInfer_tax3_wt(3)   modelInfer_tax4_nt(3)   modelInfer_tax4_wt(3) ];
eta_h2_w2               = [tax1_xhat_nt(4)          tax1_xhat_wt(4)         tax2_xhat_nt(4)         tax2_xhat_wt(4)         tax3_xhat_nt(4)         tax3_xhat_wt(4)         tax4_xhat_nt(4)         tax4_xhat_wt(4)       ];
se_eta_h2_w2            = [modelInfer_tax1_nt(4)    modelInfer_tax1_wt(4)   modelInfer_tax2_nt(4)   modelInfer_tax2_wt(4)   modelInfer_tax3_nt(4)   modelInfer_tax3_wt(4)   modelInfer_tax4_nt(4)   modelInfer_tax4_wt(4) ];
Veta_c_w1               = [NaN                      NaN                     NaN                     NaN                     tax3_xhat_nt(5)         tax3_xhat_wt(5)         tax4_xhat_nt(5)         tax4_xhat_wt(5)       ];
pv_Veta_c_w1            = [NaN                      NaN                     NaN                     NaN                     modelInfer_tax3_nt(5)   modelInfer_tax3_wt(5)   modelInfer_tax4_nt(5)   modelInfer_tax4_wt(5) ];
Veta_c_w2               = [NaN                      NaN                     NaN                     NaN                     tax3_xhat_nt(6)         tax3_xhat_wt(6)         tax4_xhat_nt(6)         tax4_xhat_wt(6)       ];
pv_Veta_c_w2            = [NaN                      NaN                     NaN                     NaN                     modelInfer_tax3_nt(6)   modelInfer_tax3_wt(6)   modelInfer_tax4_nt(6)   modelInfer_tax4_wt(6) ];
Veta_h1_w1              = [NaN                      NaN                     NaN                     NaN                     tax3_xhat_nt(7)         tax3_xhat_wt(7)         tax4_xhat_nt(7)         tax4_xhat_wt(7)       ];
pv_Veta_h1_w1           = [NaN                      NaN                     NaN                     NaN                     modelInfer_tax3_nt(7)   modelInfer_tax3_wt(7)   modelInfer_tax4_nt(7)   modelInfer_tax4_wt(7) ];
Veta_h2_w2              = [NaN                      NaN                     NaN                     NaN                     tax3_xhat_nt(8)         tax3_xhat_wt(8)         tax4_xhat_nt(8)         tax4_xhat_wt(8)       ];
pv_Veta_h2_w2           = [NaN                      NaN                     NaN                     NaN                     modelInfer_tax3_nt(8)   modelInfer_tax3_wt(8)   modelInfer_tax4_nt(8)   modelInfer_tax4_wt(8) ];
COVeta_c_w1_c_w2        = [NaN                      NaN                     NaN                     NaN                     NaN                     NaN                     tax4_xhat_nt(9)         tax4_xhat_wt(9)       ];
se_COVeta_c_w1_c_w2     = [NaN                      NaN                     NaN                     NaN                     NaN                     NaN                     modelInfer_tax4_nt(9)   modelInfer_tax4_wt(9) ];
COVeta_c_w1_h1_w1       = [NaN                      NaN                     NaN                     NaN                     NaN                     NaN                     tax4_xhat_nt(10)         tax4_xhat_wt(10)       ];
se_COVeta_c_w1_h1_w1    = [NaN                      NaN                     NaN                     NaN                     NaN                     NaN                     modelInfer_tax4_nt(10)   modelInfer_tax4_wt(10) ];
COVeta_c_w1_h2_w2       = [NaN                      NaN                     NaN                     NaN                     NaN                     NaN                     tax4_xhat_nt(11)         tax4_xhat_wt(11)       ];
se_COVeta_c_w1_h2_w2    = [NaN                      NaN                     NaN                     NaN                     NaN                     NaN                     modelInfer_tax4_nt(11)   modelInfer_tax4_wt(11) ];   
COVeta_c_w2_h1_w1       = [NaN                      NaN                     NaN                     NaN                     NaN                     NaN                     tax4_xhat_nt(12)         tax4_xhat_wt(12)       ];
se_COVeta_c_w2_h1_w1    = [NaN                      NaN                     NaN                     NaN                     NaN                     NaN                     modelInfer_tax4_nt(12)   modelInfer_tax4_wt(12) ];
COVeta_c_w2_h2_w2       = [NaN                      NaN                     NaN                     NaN                     NaN                     NaN                     tax4_xhat_nt(13)         tax4_xhat_wt(13)       ];
se_COVeta_c_w2_h2_w2    = [NaN                      NaN                     NaN                     NaN                     NaN                     NaN                     modelInfer_tax4_nt(13)   modelInfer_tax4_wt(13) ];
COVeta_h1_w1_h2_w2      = [NaN                      NaN                     NaN                     NaN                     NaN                     NaN                     tax4_xhat_nt(14)         tax4_xhat_wt(14)       ];
se_COVeta_h1_w1_h2_w2   = [NaN                      NaN                     NaN                     NaN                     NaN                     NaN                     modelInfer_tax4_nt(14)   modelInfer_tax4_wt(14) ];

%   Then create table:
t_mtable = [     eta_c_w1 ; se_eta_c_w1 ; eta_c_w2 ; se_eta_c_w2 ; ... 
                 eta_h1_w1 ; se_eta_h1_w1 ; eta_h2_w2 ; se_eta_h2_w2 ; ...
                 Veta_c_w1 ; pv_Veta_c_w1 ; Veta_c_w2 ; pv_Veta_c_w2 ; ...
                 Veta_h1_w1 ; pv_Veta_h1_w1 ; Veta_h2_w2 ; pv_Veta_h2_w2 ; ...
                 COVeta_c_w1_c_w2 ; se_COVeta_c_w1_c_w2 ; COVeta_c_w1_h1_w1 ; se_COVeta_c_w1_h1_w1 ; COVeta_c_w1_h2_w2 ; se_COVeta_c_w1_h2_w2 ; ...
                 COVeta_c_w2_h1_w1 ; se_COVeta_c_w2_h1_w1 ; COVeta_c_w2_h2_w2 ; se_COVeta_c_w2_h2_w2 ; COVeta_h1_w1_h2_w2 ; se_COVeta_h1_w1_h2_w2 ] ;

%   Round, and write only last column of table:
t_mtable = round(t_mtable,3) ;
t_mtable = t_mtable(:,8);
xlswrite(strcat(dDir,'/tables/table_e9_1.csv'),t_mtable,1)
clearvars eta_c_w1 se_eta_c_w1 eta_c_w2 se_eta_c_w2 eta_h1_w1 se_eta_h1_w1 eta_h2_w2 se_eta_h2_w2 ;
clearvars Veta_c_w1 pv_Veta_c_w1 Veta_c_w2 pv_Veta_c_w2 Veta_h1_w1 pv_Veta_h1_w1 Veta_h2_w2 pv_Veta_h2_w2 ; 
clearvars COVeta_c_w1_c_w2 se_COVeta_c_w1_c_w2 COVeta_c_w1_h1_w1 se_COVeta_c_w1_h1_w1 COVeta_c_w1_h2_w2 se_COVeta_c_w1_h2_w2 ;
clearvars COVeta_c_w2_h1_w1 se_COVeta_c_w2_h1_w1 COVeta_c_w2_h2_w2 se_COVeta_c_w2_h2_w2 COVeta_h1_w1_h2_w2 se_COVeta_h1_w1_h2_w2 ;
clearvars mfilename* modelInfer* t_mtable tax*