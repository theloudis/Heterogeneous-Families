
%%  Bootstrap wage and model parameters -- various specifications
%
%   'Consumption Inequality across Heterogeneous Families'.
%
%   This file implements the bootstrap estimation of standard errors for
%   the parameters of the wage process and the structural model.
%
%   Alexandros Theloudis
%
%   =======================================================================

%   Initial statements:
global  num_boots do vWageHat vWageHat_diag vModelHat_c1 vModelHat_c2 ;

    
%%  Run bootstrap.
if do.inference == 1
    
    
    %%  1. Implement bootstrap loop for wages.
    %   -------------------------------------------------------------------
    
	%   Initialize objects that will collect bootstrap information:
	%   -using the identity weight matrix:
	mbsWage           = zeros(length(vWageHat),num_boots) ;
	mbsWageFval       = zeros(1,num_boots) ;
	mbsWageFlag       = zeros(1,num_boots) ;
	%   -using diagonally weighted GMM:
	mbsWage_diag      = zeros(length(vWageHat_diag),num_boots) ;
	mbsWageFval_diag  = zeros(1,num_boots) ;
	mbsWageFlag_diag  = zeros(1,num_boots) ;
        
	%   Loop over bootstrap samples:
	for k = 1:num_boots

        %   Read bootstrap data:
        bs_dat = sprintf('_Cond1/bs_%d.csv',k) ;
        bs_err = sprintf('_Cond1/me_c1_bs_%d.csv',k) ;
        [mbsC_c1,mbsI_c1,~,~,mbsEr_c1,~,~,~] = handleData(bs_dat,bs_err,[],[]) ;

        %   Bootstrap wage parameters:
        %   -estimation using the identity weight matrix:
        [bswagehat,bswagefval,bswageflag] = ...
                estm_wages(mbsC_c1,mbsI_c1,mbsEr_c1,'notify-detailed',1,'eye') ;
        mbsWage(:,k)    = bswagehat ;
        mbsWageFval(k)  = bswagefval ;
        mbsWageFlag(k)  = bswageflag ;
        %   -estimation using diagonally weighted GMM:
        [bswagehat_diag,bswagefval_diag,bswageflag_diag] = ...
                estm_wages(mbsC_c1,mbsI_c1,mbsEr_c1,'notify-detailed',1,cell2mat(varmoms_c1(1))) ;
        mbsWage_diag(:,k)    = bswagehat_diag ;
        mbsWageFval_diag(k)  = bswagefval_diag ;
        mbsWageFlag_diag(k)  = bswageflag_diag ;

        %   Clear bootstrap data of this round:
        clearvars bs_* mbsC_c1 mbsI_c1 mbsEr_c1 bswage*

        %   Report progress:
        fprintf('Finished Wage Bootstrap Estimation round : %u\n',k)
	end
	clearvars k
    
	%   Deliver wage standard errors applying normal approximation to the 
	%   interquartile range of bootstrap replications (IQR =~ 1.349 sigma)
	%   -results from identity weight matrix:
	seWages = iqr(mbsWage,2) / 1.349 ;
	%   -results from diaginally weighted GMM:
	seWages_diag = iqr(mbsWage_diag,2) / 1.349 ;


    %%  2. Bootstrap over model estimates.
    %   -------------------------------------------------------------------

    %   Initialize objects that collect bootstrap replications:
    
    %  1: BPS
    %   -EqGMM:
    mbsModel_BPS_2001_c1                      	= zeros(length(vModelHat_c1.BPS_2001),num_boots) ;
    mbsModelFval_BPS_2001_c1                 	= zeros(1,num_boots) ;
    mbsModelFlag_BPS_2001_c1                 	= zeros(1,num_boots) ;
    %   -DiagGMM:
    mbsModel_BPS_2001_c1_diag                	= zeros(length(vModelHat_c1.BPS_2001_diag),num_boots) ;
    mbsModelFval_BPS_2001_c1_diag             	= zeros(1,num_boots) ;
    mbsModelFlag_BPS_2001_c1_diag             	= zeros(1,num_boots) ;
    
    %   1age: BPS 
    %   -EqGMM:
    mbsModel_BPS_2001_c2                     	= zeros(length(vModelHat_c2.BPS_2001),num_boots) ;
    mbsModelFval_BPS_2001_c2                 	= zeros(1,num_boots) ;
    mbsModelFlag_BPS_2001_c2                	= zeros(1,num_boots) ;
    
    %   2: TRANS
    %   -EqGMM:
    mbsModel_TRANS_c1                           = zeros(length(vModelHat_c1.TRANS),num_boots) ;
    mbsModelFval_TRANS_c1                       = zeros(1,num_boots) ;
    mbsModelFlag_TRANS_c1                       = zeros(1,num_boots) ; 
    %   -DiagGMM:
    mbsModel_TRANS_c1_diag                      = zeros(length(vModelHat_c1.TRANS_diag),num_boots) ;
    mbsModelFval_TRANS_c1_diag                  = zeros(1,num_boots) ;
    mbsModelFlag_TRANS_c1_diag                  = zeros(1,num_boots) ; 
    
    %   2age: TRANS
    %   -EqGMM:
    mbsModel_TRANS_c2                           = zeros(length(vModelHat_c2.TRANS),num_boots) ;
    mbsModelFval_TRANS_c2                       = zeros(1,num_boots) ;
    mbsModelFlag_TRANS_c2                       = zeros(1,num_boots) ; 
    
    %   3: TRANS3
    %   -EqGMM:
    mbsModel_TRANS3_c1                          = zeros(length(vModelHat_c1.TRANS3),num_boots) ;
    mbsModelFval_TRANS3_c1                      = zeros(1,num_boots) ;
    mbsModelFlag_TRANS3_c1                      = zeros(1,num_boots) ;
    %   -DiagGMM:
    mbsModel_TRANS3_c1_diag                     = zeros(length(vModelHat_c1.TRANS3_diag),num_boots) ;
    mbsModelFval_TRANS3_c1_diag                 = zeros(1,num_boots) ;
    mbsModelFlag_TRANS3_c1_diag                 = zeros(1,num_boots) ;
    
    %   3age: TRANS3
    %   -EqGMM:
    mbsModel_TRANS3_c2                          = zeros(length(vModelHat_c2.TRANS3),num_boots) ;
    mbsModelFval_TRANS3_c2                      = zeros(1,num_boots) ;
    mbsModelFlag_TRANS3_c2                      = zeros(1,num_boots) ;

    %   4: VAR
    %   -EqGMM:
    mbsModel_VAR_c1                             = zeros(length(vModelHat_c1.VAR),num_boots) ;
    mbsModelFval_VAR_c1                         = zeros(1,num_boots) ;
    mbsModelFlag_VAR_c1                         = zeros(1,num_boots) ;
    %   -DiagGMM:
    mbsModel_VAR_c1_diag                        = zeros(length(vModelHat_c1.VAR_diag),num_boots) ;
    mbsModelFval_VAR_c1_diag                    = zeros(1,num_boots) ;
    mbsModelFlag_VAR_c1_diag                    = zeros(1,num_boots) ;

    %   4age: VAR
    %   -EqGMM:
    mbsModel_VAR_c2                             = zeros(length(vModelHat_c2.VAR),num_boots) ;
    mbsModelFval_VAR_c2                         = zeros(1,num_boots) ;
    mbsModelFlag_VAR_c2                         = zeros(1,num_boots) ;

    %   5: COV
    %   -EqGMM:
    mbsModel_COV_c1                             = zeros(length(vModelHat_c1.COV),num_boots) ;
    mbsModelFval_COV_c1                         = zeros(1,num_boots) ;
    mbsModelFlag_COV_c1                         = zeros(1,num_boots) ;
    %   -DiagGMM:
    mbsModel_COV_c1_diag                        = zeros(length(vModelHat_c1.COV_diag),num_boots) ;
    mbsModelFval_COV_c1_diag                    = zeros(1,num_boots) ;
    mbsModelFlag_COV_c1_diag                    = zeros(1,num_boots) ;
    %   -EqGMM:
    mbsModel_COV_c1_nolsx                       = zeros(length(vModelHat_c1.COV_nolsx),num_boots) ;
    mbsModelFval_COV_c1_nolsx                   = zeros(1,num_boots) ;
    mbsModelFlag_COV_c1_nolsx                   = zeros(1,num_boots) ; 
    %   -DiagGMM:  
    mbsModel_COV_c1_nolsx_diag                  = zeros(length(vModelHat_c1.COV_nolsx_diag),num_boots) ;
    mbsModelFval_COV_c1_nolsx_diag              = zeros(1,num_boots) ;
    mbsModelFlag_COV_c1_nolsx_diag              = zeros(1,num_boots) ;  

    %   5age: COV
    %   -EqGMM:
    mbsModel_COV_c2                             = zeros(length(vModelHat_c2.COV),num_boots) ;
    mbsModelFval_COV_c2                         = zeros(1,num_boots) ;
    mbsModelFlag_COV_c2                         = zeros(1,num_boots) ;
    %   -EqGMM:
    mbsModel_COV_c2_nolsx                       = zeros(length(vModelHat_c2.COV_nolsx),num_boots) ;
    mbsModelFval_COV_c2_nolsx                   = zeros(1,num_boots) ;
    mbsModelFlag_COV_c2_nolsx                   = zeros(1,num_boots) ;    

    %   6: PREF
    %   -EqGMM:
    mbsModel_PREF_c1                            = zeros(length(vModelHat_c1.PREF),num_boots) ;
    mbsModelFval_PREF_c1                        = zeros(1,num_boots) ;
    mbsModelFlag_PREF_c1                        = zeros(1,num_boots) ;
    %   -DiagGMM:
    mbsModel_PREF_c1_diag                       = zeros(length(vModelHat_c1.PREF_diag),num_boots) ;
    mbsModelFval_PREF_c1_diag                   = zeros(1,num_boots) ;
    mbsModelFlag_PREF_c1_diag                   = zeros(1,num_boots) ;  

    %   6age: PREF
    %   -EqGMM:
    mbsModel_PREF_c2                            = zeros(length(vModelHat_c2.PREF),num_boots) ;
    mbsModelFval_PREF_c2                        = zeros(1,num_boots) ;
    mbsModelFlag_PREF_c2                        = zeros(1,num_boots) ;  

    %   Alternative specification R1
    %   -EqGMM:
    mbsModel_PREF_c1_0vls_fproport_c 	        = zeros(length(vModelHat_c1.PREF_0vls_fproport_c),num_boots) ;
    mbsModelFval_PREF_c1_0vls_fproport_c        = zeros(1,num_boots) ;
    mbsModelFlag_PREF_c1_0vls_fproport_c        = zeros(1,num_boots) ;  
    %   -DiagGMM:
    mbsModel_PREF_c1_0vls_fproport_c_diag       = zeros(length(vModelHat_c1.PREF_0vls_fproport_c_diag),num_boots) ;
    mbsModelFval_PREF_c1_0vls_fproport_c_diag   = zeros(1,num_boots) ;
    mbsModelFlag_PREF_c1_0vls_fproport_c_diag   = zeros(1,num_boots) ; 
    
    %   Alternative specification R2
    %   -EqGMM:
    mbsModel_PREF_c1_simple                     = zeros(length(vModelHat_c1.PREF_simple),num_boots) ;
    mbsModelFval_PREF_c1_simple                 = zeros(1,num_boots) ;
    mbsModelFlag_PREF_c1_simple                 = zeros(1,num_boots) ;
    %   -DiagGMM:
    mbsModel_PREF_c1_simple_diag                = zeros(length(vModelHat_c1.PREF_simple_diag),num_boots) ;
    mbsModelFval_PREF_c1_simple_diag            = zeros(1,num_boots) ;
    mbsModelFlag_PREF_c1_simple_diag            = zeros(1,num_boots) ;

    %   Alternative specification R3
    %   -EqGMM:
    mbsModel_PREF_c1_proport_c_bare   	        = zeros(length(vModelHat_c1.PREF_proport_c_bare),num_boots) ;
    mbsModelFval_PREF_c1_proport_c_bare         = zeros(1,num_boots) ;
    mbsModelFlag_PREF_c1_proport_c_bare         = zeros(1,num_boots) ; 
    %   -DiagGMM:
    mbsModel_PREF_c1_proport_c_bare_diag        = zeros(length(vModelHat_c1.PREF_proport_c_bare_diag),num_boots) ;
    mbsModelFval_PREF_c1_proport_c_bare_diag    = zeros(1,num_boots) ;
    mbsModelFlag_PREF_c1_proport_c_bare_diag    = zeros(1,num_boots) ; 

    %   Alternative specification R4
    %   -EqGMM:
    mbsModel_PREF_c1_proport_c                  = zeros(length(vModelHat_c1.PREF_proport_c),num_boots) ;
    mbsModelFval_PREF_c1_proport_c              = zeros(1,num_boots) ;
    mbsModelFlag_PREF_c1_proport_c              = zeros(1,num_boots) ; 
    %   -DiagGMM: 
    mbsModel_PREF_c1_proport_c_diag             = zeros(length(vModelHat_c1.PREF_proport_c_diag),num_boots) ;
    mbsModelFval_PREF_c1_proport_c_diag         = zeros(1,num_boots) ;
    mbsModelFlag_PREF_c1_proport_c_diag         = zeros(1,num_boots) ; 

    %   Alternative specification R5
    %   -EqGMM:
    mbsModel_PREF_c1_same_c                     = zeros(length(vModelHat_c1.PREF_same_c),num_boots) ;
    mbsModelFval_PREF_c1_same_c                 = zeros(1,num_boots) ;
    mbsModelFlag_PREF_c1_same_c                 = zeros(1,num_boots) ;
    %   -DiagGMM:
    mbsModel_PREF_c1_same_c_diag                = zeros(length(vModelHat_c1.PREF_same_c_diag),num_boots) ;
    mbsModelFval_PREF_c1_same_c_diag            = zeros(1,num_boots) ;
    mbsModelFlag_PREF_c1_same_c_diag            = zeros(1,num_boots) ;

    %   Loop over bootstrap samples:
    for k = 1:num_boots
    
        %   Read bootstrap data (baseline sample):
        bs_dat = sprintf('_Cond1/bs_%d.csv',k) ;
        bs_err = sprintf('_Cond1/me_c1_bs_%d.csv',k) ;
        bs_avg = sprintf('_Cond1/avgrat_bs_c1_%d.csv',k) ;
        [mbsC_c1,mbsI_c1,mbsE_c1,mbsPi_c1,mbsEr_c1,mbsA_c1,~,~] ...
            = handleData(bs_dat,bs_err,bs_avg,[]) ;
        clearvars bs_dat bs_err bs_avg
    
        %   Read bootstrap data (residuals net of age of youngest child):  
        bs_dat = sprintf('_Cond2/bs_%d.csv',k) ;
        bs_err = sprintf('_Cond2/me_c2_bs_%d.csv',k) ;
        bs_avg = sprintf('_Cond2/avgrat_bs_c2_%d.csv',k) ;
        [mbsC_c2,mbsI_c2,mbsE_c2,mbsPi_c2,mbsEr_c2,mbsA_c2,~,~] ...
            = handleData(bs_dat,bs_err,bs_avg,[]) ;
        clearvars bs_dat bs_err bs_avg
    
        %   Bootstrap wage parameters:
        %   -results from identity weight matrix:
        bswagehat       = mbsWage(:,k) ; 
        %   -results from diagonally weighted GMM:
        bswagehat_diag  = mbsWage_diag(:,k) ;
  
    
        %%  2A. Bootstrap BPS model estimates.
        %   ---------------------------------------------------------------

        %   1: BPS 2001-2011.
        %   Configuration: third_moments = -1, heterogeneity = 0, j0 = 3 
        %   (i.e. starting in 2001), consumption measurement error = 15%*Var(Dc).
    
        %   Bootstrap model parameters:
        %   -EqGMM:
        [bsmodelhat,bsmodelfval,bsmodelflag] = ...
            estm_model(bswagehat,       mbsC_c1, mbsI_c1, mbsE_c1, mbsPi_c1, mbsEr_c1, mbsA_c1, 'notify-detailed', -1, 0, 3, 0.15, 'on', 'eye') ;
        mbsModel_BPS_2001_c1(:,k)           = bsmodelhat ;
        mbsModelFval_BPS_2001_c1(k)         = bsmodelfval ;
        mbsModelFlag_BPS_2001_c1(k)         = bsmodelflag ;
        %   -DiagGMM:
        [bsmodelhat_diag,bsmodelfval_diag,bsmodelflag_diag] = ...
            estm_model(bswagehat_diag,  mbsC_c1, mbsI_c1, mbsE_c1, mbsPi_c1, mbsEr_c1, mbsA_c1, 'notify-detailed', -1, 0, 3, 0.15, 'on', varmoms_c1) ;
        mbsModel_BPS_2001_c1_diag(:,k)      = bsmodelhat_diag ;
        mbsModelFval_BPS_2001_c1_diag(k)    = bsmodelfval_diag ;
        mbsModelFlag_BPS_2001_c1_diag(k)    = bsmodelflag_diag ;
        
        %   Report progress:
        clearvars bsmodel*
        fprintf('Finished Model Bootstrap Estimation (1: BPS) round : %u\n',k)

        %   ---------------------------------------------------------------

        %   1age: BPS 2001-2011, residuals net of age of youngest child.
        %   Configuration: third_moments = -1, heterogeneity = 0, j0 = 3 
        %   (i.e. starting in 2001), consumption measurement error = 15%*Var(Dc).
    
        %   Bootstrap model parameters:
        [bsmodelhat,bsmodelfval,bsmodelflag] ...
            = estm_model(bswagehat,       mbsC_c2, mbsI_c2, mbsE_c2, mbsPi_c2, mbsEr_c2, mbsA_c2, 'notify-detailed', -1, 0, 3, 0.15, 'on', 'eye') ;
        mbsModel_BPS_2001_c2(:,k)       = bsmodelhat ;
        mbsModelFval_BPS_2001_c2(k)     = bsmodelfval ;
        mbsModelFlag_BPS_2001_c2(k)     = bsmodelflag ;

        %   Report progress:
        clearvars bsmodel*
        fprintf('Finished Model Bootstrap Estimation (1age: BPS) round : %u\n',k)


        %%  2B. Bootstrap TRANS model estimates.
        %   ---------------------------------------------------------------

        %   2: Transitory shocks 2001-2011.
        %   Configuration: third_moments = 0, heterogeneity = 0, j0 = 3 
        %   (i.e. starting in 2001), consumption measurement error = 15%*Var(Dc).

        %   Bootstrap model parameters:
        %   -EqGMM:
        [bsmodelhat,bsmodelfval,bsmodelflag] ...
            = estm_model(bswagehat,       mbsC_c1, mbsI_c1, mbsE_c1, mbsPi_c1, mbsEr_c1, mbsA_c1, 'notify-detailed', 0, 0, 3, 0.15, 'on', 'eye') ;
        mbsModel_TRANS_c1(:,k)          = bsmodelhat ;
        mbsModelFval_TRANS_c1(k)        = bsmodelfval ;
        mbsModelFlag_TRANS_c1(k)        = bsmodelflag ;
        %   -DiagGMM:
        [bsmodelhat_diag,bsmodelfval_diag,bsmodelflag_diag] ...
            = estm_model(bswagehat_diag,  mbsC_c1, mbsI_c1, mbsE_c1, mbsPi_c1, mbsEr_c1, mbsA_c1, 'notify-detailed', 0, 0, 3, 0.15, 'on', cell2mat(varmoms_c1(1))) ;
        mbsModel_TRANS_c1_diag(:,k)     = bsmodelhat_diag ;
        mbsModelFval_TRANS_c1_diag(k)   = bsmodelfval_diag ;
        mbsModelFlag_TRANS_c1_diag(k)   = bsmodelflag_diag ;

        %   Report progress:
        clearvars bsmodel*
      	fprintf('Finished Model Bootstrap Estimation (2: TRANS) round : %u\n',k)
    
        %   ---------------------------------------------------------------
    
        %   2age: Transitory shocks 2001-2011, residuals net of age of youngest child.
        %   Configuration: third_moments = 0, heterogeneity = 0, j0 = 3 
        %   (i.e. starting in 2001), consumption measurement error = 15%*Var(Dc).

        %   Bootstrap model parameters:
        %   -EqGMM:
        [bsmodelhat,bsmodelfval,bsmodelflag] ...
            = estm_model(bswagehat,       mbsC_c2, mbsI_c2, mbsE_c2, mbsPi_c2, mbsEr_c2, mbsA_c2, 'notify-detailed', 0, 0, 3, 0.15, 'on', 'eye') ;
        mbsModel_TRANS_c2(:,k)          = bsmodelhat ;
        mbsModelFval_TRANS_c2(k)        = bsmodelfval ;
        mbsModelFlag_TRANS_c2(k)        = bsmodelflag ;

        %   Report progress:
        clearvars bsmodel*
      	fprintf('Finished Model Bootstrap Estimation (2age: TRANS) round : %u\n',k)


        %%  2C. Bootstrap TRANS3 model estimates
        %   ---------------------------------------------------------------
    
        %   3: Third moments 2001-2011.
        %   Configuration: third_moments = 1, heterogeneity = 0, j0 = 3 
        %   (i.e. starting in 2001), consumption measurement error = 15%*Var(Dc).

        %   Bootstrap model parameters:
        %   -EqGMM:
    	[bsmodelhat,bsmodelfval,bsmodelflag] ...
            = estm_model(bswagehat,       mbsC_c1, mbsI_c1, mbsE_c1, mbsPi_c1, mbsEr_c1, mbsA_c1, 'notify-detailed', 1, 0, 3, 0.15, 'on', 'eye') ;
      	mbsModel_TRANS3_c1(:,k)         = bsmodelhat ;
    	mbsModelFval_TRANS3_c1(k)       = bsmodelfval ;
     	mbsModelFlag_TRANS3_c1(k)       = bsmodelflag ;
        %   -DiagGMM:
        [bsmodelhat_diag,bsmodelfval_diag,bsmodelflag_diag] ...
            = estm_model(bswagehat_diag,  mbsC_c1, mbsI_c1, mbsE_c1, mbsPi_c1, mbsEr_c1, mbsA_c1, 'notify-detailed', 1, 0, 3, 0.15, 'on', cell2mat(varmoms_c1(1))) ;
        mbsModel_TRANS3_c1_diag(:,k)    = bsmodelhat_diag ;
        mbsModelFval_TRANS3_c1_diag(k)  = bsmodelfval_diag ;
        mbsModelFlag_TRANS3_c1_diag(k)  = bsmodelflag_diag ;

     	%   Report progress:
        clearvars  bsmodel*
       	fprintf('Finished Model Bootstrap Estimation (3: TRANS3) round : %u\n',k)
    
        %   ---------------------------------------------------------------
    
        %   3age:  Third moments 2001-2011, residuals net of age of youngest child.
        %   Configuration: third_moments = 1, heterogeneity = 0, j0 = 3 
        %   (i.e. starting in 2001), consumption measurement error = 15%*Var(Dc).

        %   Bootstrap model parameters:
    	[bsmodelhat,bsmodelfval,bsmodelflag] ...
            = estm_model(bswagehat,       mbsC_c2, mbsI_c2, mbsE_c2, mbsPi_c2, mbsEr_c2, mbsA_c2, 'notify-detailed', 1, 0, 3, 0.15, 'on', 'eye') ;
      	mbsModel_TRANS3_c2(:,k)     = bsmodelhat ;
    	mbsModelFval_TRANS3_c2(k)   = bsmodelfval ;
     	mbsModelFlag_TRANS3_c2(k)   = bsmodelflag ;

     	%   Report progress:
        clearvars  bsmodel*
       	fprintf('Finished Model Bootstrap Estimation (3age: TRANS3) round : %u\n',k)


        %%  2D. Bootstrap VAR model estimates
        %   ---------------------------------------------------------------

        %   4: Restricted heterogeneity 2001-2011.
        %   Configuration: third_moments = 1, heterogeneity = 1, j0 = 3 
        %   (i.e. starting in 2001), consumption measurement error = 15%*Var(Dc).

        %   Bootstrap model parameters:
        %   -EqGMM:
     	[bsmodelhat,bsmodelfval,bsmodelflag] = ...
            estm_model(bswagehat,       mbsC_c1, mbsI_c1, mbsE_c1, mbsPi_c1, mbsEr_c1, mbsA_c1, 'notify-detailed', 1, 1, 3, 0.15, 'on', 'eye') ;
     	mbsModel_VAR_c1(:,k)            = bsmodelhat ;
       	mbsModelFval_VAR_c1(k)          = bsmodelfval ;
      	mbsModelFlag_VAR_c1(k)          = bsmodelflag ;
        %   -DiagGMM:
        [bsmodelhat_diag,bsmodelfval_diag,bsmodelflag_diag] = ...
            estm_model(bswagehat_diag,  mbsC_c1, mbsI_c1, mbsE_c1, mbsPi_c1, mbsEr_c1, mbsA_c1, 'notify-detailed', 1, 1, 3, 0.15, 'on', cell2mat(varmoms_c1(1))) ;
        mbsModel_VAR_c1_diag(:,k)       = bsmodelhat_diag ;
        mbsModelFval_VAR_c1_diag(k)     = bsmodelfval_diag ;
        mbsModelFlag_VAR_c1_diag(k)     = bsmodelflag_diag ;

      	%   Report progress:
        clearvars bsmodel*
      	fprintf('Finished Model Bootstrap Estimation (4: VAR) round : %u\n',k)
    
        %   ---------------------------------------------------------------
        
        %   4age: Restricted heterogeneity 2001-2011, residuals net of age of   
        %   youngest child.
        %   Configuration: third_moments = 1, heterogeneity = 1, j0 = 3 
        %   (i.e. starting in 2001), consumption measurement error = 15%*Var(Dc).

        %   Bootstrap model parameters:
        %   -EqGMM:
     	[bsmodelhat,bsmodelfval,bsmodelflag] = ...
            estm_model(bswagehat,       mbsC_c2, mbsI_c2, mbsE_c2, mbsPi_c2, mbsEr_c2, mbsA_c2, 'notify-detailed', 1, 1, 3, 0.15, 'on', 'eye') ;
     	mbsModel_VAR_c2(:,k)        = bsmodelhat ;
       	mbsModelFval_VAR_c2(k)      = bsmodelfval ;
      	mbsModelFlag_VAR_c2(k)      = bsmodelflag ;
        
      	%   Report progress:
        clearvars bsmodel*
      	fprintf('Finished Model Bootstrap Estimation (4age: VAR) round : %u\n',k)


        %%  2E. Bootstrap COV model estimates
        %   ---------------------------------------------------------------

        %   5: Full heterogeneity 2001-2011.
        %   Configuration: third_moments = 1, heterogeneity = 2, j0 = 3 
        %   (i.e. starting in 2001), consumption measurement error = 15%*Var(Dc).
        %   -labor supply cross-eslaticities on:

        %   Bootstrap model parameters (labor supply cross-elasticities on):
        %   -EqGMM:
     	[bsmodelhat,bsmodelfval,bsmodelflag] ...
            = estm_model(bswagehat,       mbsC_c1, mbsI_c1, mbsE_c1, mbsPi_c1, mbsEr_c1, mbsA_c1, 'notify-detailed', 1, 2, 3, 0.15, 'on', 'eye') ;
      	mbsModel_COV_c1(:,k)            = bsmodelhat ;
     	mbsModelFval_COV_c1(k)          = bsmodelfval ;
    	mbsModelFlag_COV_c1(k)          = bsmodelflag ;
        %   -DiagGMM:
        [bsmodelhat_diag,bsmodelfval_diag,bsmodelflag_diag] ...
            = estm_model(bswagehat_diag,  mbsC_c1, mbsI_c1, mbsE_c1, mbsPi_c1, mbsEr_c1, mbsA_c1, 'notify-detailed', 1, 2, 3, 0.15, 'on', cell2mat(varmoms_c1(1))) ;
        mbsModel_COV_c1_diag(:,k)       = bsmodelhat_diag ;
        mbsModelFval_COV_c1_diag(k)     = bsmodelfval_diag ;
        mbsModelFlag_COV_c1_diag(k)     = bsmodelflag_diag ;

      	%   Report progress:
     	clearvars bsmodel*
      	fprintf('Finished Model Bootstrap Estimation (5: COV) round : %u\n',k)  

        %   Bootstrap model parameters (labor supply cross-elasticities off):
        %   -EqGMM:
      	[bsmodelhat,bsmodelfval,bsmodelflag] ...
            = estm_model(bswagehat,       mbsC_c1, mbsI_c1, mbsE_c1, mbsPi_c1, mbsEr_c1, mbsA_c1, 'notify-detailed', 1, 2, 3, 0.15, 'off', 'eye') ;
       	mbsModel_COV_c1_nolsx(:,k)           = bsmodelhat ;
       	mbsModelFval_COV_c1_nolsx(k)         = bsmodelfval ;
      	mbsModelFlag_COV_c1_nolsx(k)         = bsmodelflag ;
        %   -DiagGMM:
        [bsmodelhat_diag,bsmodelfval_diag,bsmodelflag_diag] ...
            = estm_model(bswagehat_diag,  mbsC_c1, mbsI_c1, mbsE_c1, mbsPi_c1, mbsEr_c1, mbsA_c1, 'notify-detailed', 1, 2, 3, 0.15, 'off', cell2mat(varmoms_c1(1))) ;
        mbsModel_COV_c1_nolsx_diag(:,k)      = bsmodelhat_diag ;
        mbsModelFval_COV_c1_nolsx_diag(k)    = bsmodelfval_diag ;
        mbsModelFlag_COV_c1_nolsx_diag(k)    = bsmodelflag_diag ;

      	%   Report progress:
       	clearvars bsmodel*
      	fprintf('Finished Model Bootstrap Estimation (5: COV nolsx) round : %u\n',k)  
    
        %   ---------------------------------------------------------------
    
        %   5age: Full heterogeneity 2001-2011, residuals net of age of youngest child.
        %   Configuration: third_moments = 1, heterogeneity = 2, j0 = 3 
        %   (i.e. starting in 2001), consumption measurement error = 15%*Var(Dc).

        %   Bootstrap model parameters (labor supply cross-elasticities on):
     	[bsmodelhat,bsmodelfval,bsmodelflag] ...
            = estm_model(bswagehat,       mbsC_c2, mbsI_c2, mbsE_c2, mbsPi_c2, mbsEr_c2, mbsA_c2, 'notify-detailed', 1, 2, 3, 0.15, 'on', 'eye') ;
      	mbsModel_COV_c2(:,k)            = bsmodelhat ;
     	mbsModelFval_COV_c2(k)          = bsmodelfval ;
    	mbsModelFlag_COV_c2(k)          = bsmodelflag ;

      	%   Report progress:
     	clearvars bsmodel*
      	fprintf('Finished Model Bootstrap Estimation (5age: COV) round : %u\n',k) 

        %   Bootstrap model parameters (labor supply cross-elasticities off):
      	[bsmodelhat,bsmodelfval,bsmodelflag] ...
            = estm_model(bswagehat,       mbsC_c2, mbsI_c2, mbsE_c2, mbsPi_c2, mbsEr_c2, mbsA_c2, 'notify-detailed', 1, 2, 3, 0.15, 'off', 'eye') ;
       	mbsModel_COV_c2_nolsx(:,k)      = bsmodelhat ;
       	mbsModelFval_COV_c2_nolsx(k)    = bsmodelfval ;
      	mbsModelFlag_COV_c2_nolsx(k)    = bsmodelflag ;

      	%   Report progress:
       	clearvars bsmodel*
      	fprintf('Finished Model Bootstrap Estimation (5age: COV nolsx) round : %u\n',k)  


        %%  2F. Bootstrap PREF model estimates
        %   ---------------------------------------------------------------

        %   6: Preferred specification 2001-2011.
        %   Configuration: third_moments = 1, heterogeneity = 7, j0 = 3 
        %   (i.e. starting in 2001), consumption measurement error = 15%*Var(Dc).

     	%   Bootstrap model parameters:
        %   -EqGMM:
      	[bsmodelhat,bsmodelfval,bsmodelflag] ...
            = estm_model(bswagehat,       mbsC_c1, mbsI_c1, mbsE_c1, mbsPi_c1, mbsEr_c1, mbsA_c1, 'notify-detailed', 1, 7, 3, 0.15, 'off', 'eye') ;
       	mbsModel_PREF_c1(:,k)           = bsmodelhat ;
        mbsModelFval_PREF_c1(k)         = bsmodelfval ;
     	mbsModelFlag_PREF_c1(k)         = bsmodelflag ;
        %   -DiagGMM:
        [bsmodelhat_diag,bsmodelfval_diag,bsmodelflag_diag] ...
            = estm_model(bswagehat_diag,  mbsC_c1, mbsI_c1, mbsE_c1, mbsPi_c1, mbsEr_c1, mbsA_c1, 'notify-detailed', 1, 7, 3, 0.15, 'off', cell2mat(varmoms_c1(1))) ;
        mbsModel_PREF_c1_diag(:,k)      = bsmodelhat_diag ;
        mbsModelFval_PREF_c1_diag(k)    = bsmodelfval_diag ;
        mbsModelFlag_PREF_c1_diag(k)    = bsmodelflag_diag ;

      	%   Report progress:
    	clearvars bsmodel*
     	fprintf('Finished Model Bootstrap Estimation (6: PREF) round : %u\n',k) 
    
        %   ---------------------------------------------------------------
    
        %   6age: Preferred specification 2001-2011, residuals net of age of    
        %   youngest child.
        %   Configuration: third_moments = 1, heterogeneity = 7, j0 = 3 
        %   (i.e. starting in 2001), consumption measurement error = 15%*Var(Dc).

     	%   Bootstrap model parameters:
        %   -EqGMM:
      	[bsmodelhat,bsmodelfval,bsmodelflag] ...
            = estm_model(bswagehat,       mbsC_c2, mbsI_c2, mbsE_c2, mbsPi_c2, mbsEr_c2, mbsA_c2, 'notify-detailed', 1, 7, 3, 0.15, 'off', 'eye') ;
       	mbsModel_PREF_c2(:,k)       = bsmodelhat ;
        mbsModelFval_PREF_c2(k)     = bsmodelfval ;
     	mbsModelFlag_PREF_c2(k)     = bsmodelflag ;
        %   -DiagGMM:
        
      	%   Report progress:
    	clearvars bsmodel*
     	fprintf('Finished Model Bootstrap Estimation (6: PREF) round : %u\n',k) 

    
        %%  2F. Bootstrap ALTERNATIVE SPECIFICATIONS model estimates
        %   ---------------------------------------------------------------

        %   Alternative R1: 2001-2011.
        %   Configuration: third_moments = 1, heterogeneity = 8 --> fixed propc = 1.5, 
        %   no variation in labor supply elasticities, j0 = 3 (i.e. starting in 2001), 
        %   consumption measurement error = 15%*Var(Dc).

        %   Bootstrap model parameters:
        %   -EqGMM:
        [bsmodelhat,bsmodelfval,bsmodelflag] ...
            = estm_model(bswagehat,       mbsC_c1, mbsI_c1, mbsE_c1, mbsPi_c1, mbsEr_c1, mbsA_c1, 'notify-detailed', 1, 8, 3, 0.15, 'off', 'eye') ;
        mbsModel_PREF_c1_0vls_fproport_c(:,k)       = bsmodelhat ;
        mbsModelFval_PREF_c1_0vls_fproport_c(k)     = bsmodelfval ;
        mbsModelFlag_PREF_c1_0vls_fproport_c(k)     = bsmodelflag ;
        %   -DiagGMM:
        [bsmodelhat_diag,bsmodelfval_diag,bsmodelflag_diag] ...
            = estm_model(bswagehat_diag,  mbsC_c1, mbsI_c1, mbsE_c1, mbsPi_c1, mbsEr_c1, mbsA_c1, 'notify-detailed', 1, 8, 3, 0.15, 'off', cell2mat(varmoms_c1(1))) ;
        mbsModel_PREF_c1_0vls_fproport_c_diag(:,k)  = bsmodelhat_diag ;
        mbsModelFval_PREF_c1_0vls_fproport_c_diag(k)= bsmodelfval_diag ;
        mbsModelFlag_PREF_c1_0vls_fproport_c_diag(k)= bsmodelflag_diag ;

        %   Report progress:
        clearvars bsmodel*
        fprintf('Finished Model Bootstrap Estimation (R1: ALTERNATIVE) round : %u\n',k)

        %   ---------------------------------------------------------------

        %   Alternative R2: 2001-2011.
        %   Configuration: third_moments = 1, heterogeneity = 10 --> fixed propc = 1.5, 
        %   no joint variation in labor supply elasticities, j0 = 3 (i.e. starting in 2001), 
        %   consumption measurement error = 15%*Var(Dc).

        %   Bootstrap model parameters:
        %   -EqGMM:
        [bsmodelhat,bsmodelfval,bsmodelflag] ...
            = estm_model(bswagehat,       mbsC_c1, mbsI_c1, mbsE_c1, mbsPi_c1, mbsEr_c1, mbsA_c1, 'notify-detailed', 1, 10, 3, 0.15, 'off', 'eye') ;
        mbsModel_PREF_c1_simple(:,k)        = bsmodelhat ;
        mbsModelFval_PREF_c1_simple(k)      = bsmodelfval ;
        mbsModelFlag_PREF_c1_simple(k)      = bsmodelflag ;
        %   -DiagGMM:
        [bsmodelhat_diag,bsmodelfval_diag,bsmodelflag_diag] ...
            = estm_model(bswagehat_diag,  mbsC_c1, mbsI_c1, mbsE_c1, mbsPi_c1, mbsEr_c1, mbsA_c1, 'notify-detailed', 1, 10, 3, 0.15, 'off', cell2mat(varmoms_c1(1))) ;
        mbsModel_PREF_c1_simple_diag(:,k)   = bsmodelhat_diag ;
        mbsModelFval_PREF_c1_simple_diag(k) = bsmodelfval_diag ;
        mbsModelFlag_PREF_c1_simple_diag(k) = bsmodelflag_diag ;
        
        %   Report progress:
        clearvars bsmodel*
        fprintf('Finished Model Bootstrap Estimation (R2: ALTERNATIVE) round : %u\n',k)

        %   ---------------------------------------------------------------

        %   Alternative R3: 2001-2011.
        %   Configuration: third_moments = 1, heterogeneity = 6 --> estimate propc, 
        %   j0 = 3 (i.e. starting in 2001), consumption measurement error = 15%*Var(Dc).

        %   Bootstrap model parameters:
        %   -EqGMM:
        [bsmodelhat,bsmodelfval,bsmodelflag] ...
            = estm_model(bswagehat,       mbsC_c1, mbsI_c1, mbsE_c1, mbsPi_c1, mbsEr_c1, mbsA_c1, 'notify-detailed', 1, 6, 3, 0.15, 'off', 'eye') ;
        mbsModel_PREF_c1_proport_c_bare(:,k)        = bsmodelhat ;
        mbsModelFval_PREF_c1_proport_c_bare(k)      = bsmodelfval ;
        mbsModelFlag_PREF_c1_proport_c_bare(k)      = bsmodelflag ;
        %   -DiagGMM:
        [bsmodelhat_diag,bsmodelfval_diag,bsmodelflag_diag] ...
            = estm_model(bswagehat_diag,  mbsC_c1, mbsI_c1, mbsE_c1, mbsPi_c1, mbsEr_c1, mbsA_c1, 'notify-detailed', 1, 6, 3, 0.15, 'off', cell2mat(varmoms_c1(1))) ;
        mbsModel_PREF_c1_proport_c_bare_diag(:,k)   = bsmodelhat_diag ;
        mbsModelFval_PREF_c1_proport_c_bare_diag(k) = bsmodelfval_diag ;
        mbsModelFlag_PREF_c1_proport_c_bare_diag(k) = bsmodelflag_diag ;

        %   Report progress:
        clearvars bsmodel*
        fprintf('Finished Model Bootstrap Estimation (R3: ALTERNATIVE) round : %u\n',k)

        %   ---------------------------------------------------------------

        %   Alternative R4: 2001-2011.
        %   Configuration: third_moments = 1, heterogeneity = 5 --> estimate propc, 
        %   equal labor supply elasticities, j0 = 3 (i.e. starting in 2001), 
        %   consumption measurement error = 15%*Var(Dc).

        %   Bootstrap model parameters:
        %   -EqGMM:
        [bsmodelhat,bsmodelfval,bsmodelflag] ...
            = estm_model(bswagehat,       mbsC_c1, mbsI_c1, mbsE_c1, mbsPi_c1, mbsEr_c1, mbsA_c1, 'notify-detailed', 1, 5, 3, 0.15, 'off', 'eye') ;
        mbsModel_PREF_c1_proport_c(:,k)     = bsmodelhat ;
        mbsModelFval_PREF_c1_proport_c(k)   = bsmodelfval ;
        mbsModelFlag_PREF_c1_proport_c(k)   = bsmodelflag ;
        %   -DiagGMM:
        [bsmodelhat_diag,bsmodelfval_diag,bsmodelflag_diag] ...
            = estm_model(bswagehat_diag,  mbsC_c1, mbsI_c1, mbsE_c1, mbsPi_c1, mbsEr_c1, mbsA_c1, 'notify-detailed', 1, 5, 3, 0.15, 'off', cell2mat(varmoms_c1(1))) ;
        mbsModel_PREF_c1_proport_c_diag(:,k)   = bsmodelhat_diag ;
        mbsModelFval_PREF_c1_proport_c_diag(k) = bsmodelfval_diag ;
        mbsModelFlag_PREF_c1_proport_c_diag(k) = bsmodelflag_diag ;

        %   Report progress:
        clearvars bsmodel*
        fprintf('Finished Model Bootstrap Estimation (R4: ALTERNATIVE) round : %u\n',k)

        %   ---------------------------------------------------------------

        %   Alternative R5: 2001-2011.
        %   Configuration: third_moments = 1, heterogeneity = 11 --> equal
        %   consumption elasticities, j0 = 3 (i.e. starting in 2001), 
        %   consumption measurement error = 15%*Var(Dc).

        %   Bootstrap model parameters:
        %   -EqGMM:
        [bsmodelhat,bsmodelfval,bsmodelflag] ...
            = estm_model(bswagehat,       mbsC_c1, mbsI_c1, mbsE_c1, mbsPi_c1, mbsEr_c1, mbsA_c1, 'notify-detailed', 1, 11, 3, 0.15, 'off', 'eye') ;
        mbsModel_PREF_c1_same_c(:,k)        = bsmodelhat ;
        mbsModelFval_PREF_c1_same_c(k)      = bsmodelfval ;
        mbsModelFlag_PREF_c1_same_c(k)      = bsmodelflag ;
        %   -DiagGMM:
        [bsmodelhat_diag,bsmodelfval_diag,bsmodelflag_diag] ...
            = estm_model(bswagehat_diag,  mbsC_c1, mbsI_c1, mbsE_c1, mbsPi_c1, mbsEr_c1, mbsA_c1, 'notify-detailed', 1, 11, 3, 0.15, 'off', cell2mat(varmoms_c1(1))) ;
        mbsModel_PREF_c1_same_c_diag(:,k)   = bsmodelhat_diag ;
        mbsModelFval_PREF_c1_same_c_diag(k) = bsmodelfval_diag ;
        mbsModelFlag_PREF_c1_same_c_diag(k) = bsmodelflag_diag ;

        %   Report progress:
        clearvars bsmodel*
        fprintf('Finished Model Bootstrap Estimation (R5: ALTERNATIVE) round : %u\n',k)
    
        %   ---------------------------------------------------------------

        %   Report overall progress:
        fprintf('Finished bootstrap loop round : %u\n',k)
    end %for k=1:num_boots


    %%  3. Calculate standard errors.
    %   -------------------------------------------------------------------
    
    %   Deliver parameter standard errors applying normal approximation to the 
    %   interquartile range of bootstrap replications (IQR =~ 1.349 sigma):
        
    %   BPS:
	se_BPS_2001_c1      = iqr(mbsModel_BPS_2001_c1,2)       / 1.349 ;
	se_BPS_2001_c1_diag = iqr(mbsModel_BPS_2001_c1_diag,2)  / 1.349 ;
    se_BPS_2001_c2      = iqr(mbsModel_BPS_2001_c2,2)       / 1.349 ;
    %   TRANS:
	se_TRANS_c1         = iqr(mbsModel_TRANS_c1,2)          / 1.349 ;
	se_TRANS_c1_diag    = iqr(mbsModel_TRANS_c1_diag,2)     / 1.349 ;
	se_TRANS_c2         = iqr(mbsModel_TRANS_c2,2)          / 1.349 ;
    %   TRANS3:
	se_TRANS3_c1        = iqr(mbsModel_TRANS3_c1,2)         / 1.349 ;
	se_TRANS3_c1_diag   = iqr(mbsModel_TRANS3_c1_diag,2)    / 1.349 ;
	se_TRANS3_c2        = iqr(mbsModel_TRANS3_c2,2)         / 1.349 ;
    
    %   -------------------------------------------------------------------
    
    %   For the following specifications, I calculate the standard errors 
    %   applying a normal approximation to the interquartile range of 
    %   bootstrap replications (IQR =~ 1.349 sigma). These standard errors 
    %   are inconsistent for the variance estimates. So for them, I 
    %   estimate p-values. I obtain p-values for the one-sided hypothesis 
    %   test
    %       H0 : theta = 0
	%       Ha : theta > 0 (one-sided alternative).
	%   Andrews (2000) shows the one-sided bootstrap test has the correct 
	%   asymptotic null rejection rate; it rejects H0 at the a=(0,0.5) 
	%   level when 
	%       theta_hat > t_bs{1-a}
	%   where t_bs{1-a} is the 1-a quantile of the bootstrap 
	%   distribution of (theta_hat_bs* - theta_hat_bs). I first
	%   calculate (theta_hat_bs* - theta_hat_bs*). Then I request the 
	%   share of replications for which 
	%       theta_hat > (theta_hat_bs* - theta_hat_bs)
	%   and then (1-share) is the probability Pr(H0 true|H0 rejected).

    %   VAR:
	se_VAR_c1       = iqr(mbsModel_VAR_c1,2)        / 1.349 ;
	se_VAR_c1_diag  = iqr(mbsModel_VAR_c1_diag,2)   / 1.349 ;

        bsquantiles = sort(mbsModel_VAR_c1(7:12,:) - mean(mbsModel_VAR_c1(7:12,:),2),2) ;
        pvals = zeros(6,1) ;
        for paramvar = 1:6 % looping over variance parameters
            pvl = 1-find(bsquantiles(paramvar,:)>=vModelHat_c1.VAR(6+paramvar),1)/num_boots ;
            if isempty(pvl)==1  % result is empty if parameter estimate super highly significant
                pvals(paramvar) = 0.0 ;     
            else
                pvals(paramvar) = pvl ;
            end
        end
        bsquantiles = sort(mbsModel_VAR_c1_diag(7:12,:) - mean(mbsModel_VAR_c1_diag(7:12,:),2),2) ;
        pvals_diag = zeros(6,1) ;
        for paramvar = 1:6 % looping over variance parameters
            pvl = 1-find(bsquantiles(paramvar,:)>=vModelHat_c1.VAR_diag(6+paramvar),1)/num_boots ;
            if isempty(pvl)==1  % result is empty if parameter estimate super highly significant
                pvals_diag(paramvar) = 0.0 ;     
            else
                pvals_diag(paramvar) = pvl ;
            end
        end

	%   Put together standard errors and p-values:
	inference_VAR_c1        = [se_VAR_c1(1:6); pvals; se_VAR_c1(13)] ;
	inference_VAR_c1_diag   = [se_VAR_c1_diag(1:6); pvals_diag; se_VAR_c1_diag(13)] ;
	clearvars bsquantiles pvals pvals_diag se_VAR_c1 se_VAR_c1_diag


    %   -------------------------------------------------------------------

    %   VAR (age youngest child):
	se_VAR_c2 = iqr(mbsModel_VAR_c2,2) / 1.349 ;

        bsquantiles = sort(mbsModel_VAR_c2(7:12,:) - mean(mbsModel_VAR_c2(7:12,:),2),2) ;
        pvals = zeros(6,1) ;
        for paramvar = 1:6 % looping over variance parameters
            pvl = 1-find(bsquantiles(paramvar,:)>=vModelHat_c2.VAR(6+paramvar),1)/num_boots ;
            if isempty(pvl)==1  % result is empty if parameter estimate super highly significant
                pvals(paramvar) = 0.0 ;     
            else
                pvals(paramvar) = pvl ;
            end
        end

	%   Put together standard errors and p-values:
	inference_VAR_c2 = [se_VAR_c2(1:6); pvals; se_VAR_c2(13)] ;
	clearvars bsquantiles pvals se_VAR_c2

    %   -------------------------------------------------------------------

    %   COV (labor supply cross-elasticities on): 
	se_COV_c1       = iqr(mbsModel_COV_c1,2)        / 1.349 ;
	se_COV_c1_diag  = iqr(mbsModel_COV_c1_diag,2)   / 1.349 ;

        bsquantiles = sort(mbsModel_COV_c1(7:12,:) - mean(mbsModel_COV_c1(7:12,:),2),2) ;
        pvals = zeros(6,1) ;
        for paramvar = 1:6 % looping over variance parameters
            pvl = 1-find(bsquantiles(paramvar,:)>=vModelHat_c1.COV(6+paramvar),1)/num_boots ;
            if isempty(pvl)==1  % result is empty if parameter estimate super highly significant
                pvals(paramvar) = 0.0 ;     
            else
                pvals(paramvar) = pvl ;
            end
        end
        bsquantiles = sort(mbsModel_COV_c1_diag(7:12,:) - mean(mbsModel_COV_c1_diag(7:12,:),2),2) ;
        pvals_diag = zeros(6,1) ;
        for paramvar = 1:6 % looping over variance parameters
            pvl = 1-find(bsquantiles(paramvar,:)>=vModelHat_c1.COV_diag(6+paramvar),1)/num_boots ;
            if isempty(pvl)==1  % result is empty if parameter estimate super highly significant
                pvals_diag(paramvar) = 0.0 ;     
            else
                pvals_diag(paramvar) = pvl ;
            end
        end

	%   Put together standard errors and p-values:
	inference_COV_c1        = [se_COV_c1(1:6); pvals; se_COV_c1(13:27)] ;
	inference_COV_c1_diag   = [se_COV_c1_diag(1:6); pvals_diag; se_COV_c1_diag(13:27)] ;
	clearvars bsquantiles pvals pvals_diag pvl se_COV_c1 se_COV_c1_diag

    %   -------------------------------------------------------------------
    
    %   COV (labor supply cross-elasticities off): 
	se_COV_nolsx_c1      = iqr(mbsModel_COV_c1_nolsx,2)         / 1.349 ;
	se_COV_nolsx_c1_diag = iqr(mbsModel_COV_c1_nolsx_diag,2)    / 1.349 ;

        bsquantiles = sort(mbsModel_COV_c1_nolsx(5:8,:) - mean(mbsModel_COV_c1_nolsx(5:8,:),2),2) ;
        pvals = zeros(4,1) ;
        for paramvar = 1:4 % looping over variance parameters
            pvl = 1-find(bsquantiles(paramvar,:)>=vModelHat_c1.COV_nolsx(4+paramvar),1)/num_boots ;
            if isempty(pvl)==1  % result is empty if parameter estimate super highly significant
                pvals(paramvar) = 0.0 ;     
            else
                pvals(paramvar) = pvl ;
            end
        end
        bsquantiles = sort(mbsModel_COV_c1_nolsx_diag(5:8,:) - mean(mbsModel_COV_c1_nolsx_diag(5:8,:),2),2) ;
        pvals_diag = zeros(4,1) ;
        for paramvar = 1:4 % looping over variance parameters
            pvl = 1-find(bsquantiles(paramvar,:)>=vModelHat_c1.COV_nolsx_diag(4+paramvar),1)/num_boots ;
            if isempty(pvl)==1  % result is empty if parameter estimate super highly significant
                pvals_diag(paramvar) = 0.0 ;     
            else
                pvals_diag(paramvar) = pvl ;
            end
        end

	%   Put together standard errors and p-values:
	inference_COV_nolsx_c1      = [se_COV_nolsx_c1(1:4); pvals; se_COV_nolsx_c1(9:14)] ;
	inference_COV_nolsx_c1_diag = [se_COV_nolsx_c1_diag(1:4); pvals_diag; se_COV_nolsx_c1_diag(9:14)] ;
	clearvars bsquantiles pvals pvals_diag pvl se_COV_nolsx_c1 se_COV_nolsx_c1_diag

    %   -------------------------------------------------------------------
    
    %   COV (age youngest child, labor supply cross-elasticities on):
    se_COV_c2 = iqr(mbsModel_COV_c2,2) / 1.349 ;

        bsquantiles = sort(mbsModel_COV_c2(7:12,:) - mean(mbsModel_COV_c2(7:12,:),2),2) ;
        pvals = zeros(6,1) ;
        for paramvar = 1:6 % looping over variance parameters
            pvl = 1-find(bsquantiles(paramvar,:)>=vModelHat_c2.COV(6+paramvar),1)/num_boots ;
            if isempty(pvl)==1  % result is empty if parameter estimate super highly significant
                pvals(paramvar) = 0.0 ;     
            else
                pvals(paramvar) = pvl ;
            end
        end

	%   Put together standard errors and p-values:
	inference_COV_c2 = [se_COV_c2(1:6); pvals; se_COV_c2(13:27)] ;
	clearvars bsquantiles pvals pvl se_COV_c2

    %   -------------------------------------------------------------------
    
    %   COV (age youngest child, labor supply cross-elasticities off):
	se_COV_nolsx_c2 = iqr(mbsModel_COV_c2_nolsx,2) / 1.349 ;

        bsquantiles = sort(mbsModel_COV_c2_nolsx(5:8,:) - mean(mbsModel_COV_c2_nolsx(5:8,:),2),2) ;
        pvals = zeros(4,1) ;
        for paramvar = 1:4 % looping over variance parameters
            pvl = 1-find(bsquantiles(paramvar,:)>=vModelHat_c2.COV_nolsx(4+paramvar),1)/num_boots ;
            if isempty(pvl)==1  % result is empty if parameter estimate super highly significant
                pvals(paramvar) = 0.0 ;     
            else
                pvals(paramvar) = pvl ;
            end
        end

	%   Put together standard errors and p-values:
	inference_COV_nolsx_c2 = [se_COV_nolsx_c2(1:4); pvals; se_COV_nolsx_c2(9:14)] ;
	clearvars bsquantiles pvals pvl se_COV_nolsx_c2

    %   -------------------------------------------------------------------

    %   PREF:
	se_PREF_c1      = iqr(mbsModel_PREF_c1,2) / 1.349 ;
	se_PREF_c1_diag = iqr(mbsModel_PREF_c1_diag,2) / 1.349 ;

        bsquantiles = sort(mbsModel_PREF_c1(5:8,:) - mean(mbsModel_PREF_c1(5:8,:),2),2) ;
        pvals = zeros(4,1) ;
        for paramvar = 1:4 % looping over variance parameters
            pvl = 1-find(bsquantiles(paramvar,:)>=vModelHat_c1.PREF(4+paramvar),1)/num_boots ;
            if isempty(pvl)==1  % result is empty if parameter estimate super highly significant
                pvals(paramvar) = 0.0 ;     
            else
                pvals(paramvar) = pvl ;
            end
        end
        bsquantiles = sort(mbsModel_PREF_c1_diag(5:8,:) - mean(mbsModel_PREF_c1_diag(5:8,:),2),2) ;
        pvals_diag = zeros(4,1) ;
        for paramvar = 1:4 % looping over variance parameters
            pvl = 1-find(bsquantiles(paramvar,:)>=vModelHat_c1.PREF_diag(4+paramvar),1)/num_boots ;
            if isempty(pvl)==1  % result is empty if parameter estimate super highly significant
                pvals_diag(paramvar) = 0.0 ;     
            else
                pvals_diag(paramvar) = pvl ;
            end
        end

	%   Put together standard errors and p-values:
	inference_PREF_c1       = [se_PREF_c1(1:4); pvals; se_PREF_c1(9:14)] ;
	inference_PREF_c1_diag  = [se_PREF_c1_diag(1:4); pvals_diag; se_PREF_c1_diag(9:14)] ;
	clearvars bsquantiles pvals pvals_diag pvl se_PREF_c11

    %   -------------------------------------------------------------------

    %   PREF (age youngest child):
	se_PREF_c2 = iqr(mbsModel_PREF_c2,2) / 1.349 ;

        bsquantiles = sort(mbsModel_PREF_c2(5:8,:) - mean(mbsModel_PREF_c2(5:8,:),2),2) ;
        pvals = zeros(4,1) ;
        for paramvar = 1:4 % looping over variance parameters
            pvl = 1-find(bsquantiles(paramvar,:)>=vModelHat_c2.PREF(4+paramvar),1)/num_boots ;
            if isempty(pvl)==1  % result is empty if parameter estimate super highly significant
                pvals(paramvar) = 0.0 ;     
            else
                pvals(paramvar) = pvl ;
            end
        end

	%   Put together standard errors and p-values:
	inference_PREF_c2 = [se_PREF_c2(1:4); pvals; se_PREF_c2(9:14)] ;
	clearvars bsquantiles pvals pvl se_PREF_c2

    %   -------------------------------------------------------------------

    %   ALTERNATIVE SPEC 1:
	se_PREF_c1_0vls_fproport_c      = iqr(mbsModel_PREF_c1_0vls_fproport_c,2)       / 1.349 ;
	se_PREF_c1_0vls_fproport_c_diag = iqr(mbsModel_PREF_c1_0vls_fproport_c_diag,2)  / 1.349 ;
        
        bsquantiles = sort(mbsModel_PREF_c1_0vls_fproport_c(5:8,:) - mean(mbsModel_PREF_c1_0vls_fproport_c(5:8,:),2),2) ;
        pvals = zeros(4,1) ;
        for paramvar = 1:4 % looping over variance parameters
            pvl = 1-find(bsquantiles(paramvar,:)>=vModelHat_c1.PREF_0vls_fproport_c(4+paramvar),1)/num_boots ;
            if isempty(pvl)==1  % result is empty if parameter estimate super highly significant
                pvals(paramvar) = 0.0 ;     
            else
                pvals(paramvar) = pvl ;
            end
        end
        bsquantiles = sort(mbsModel_PREF_c1_0vls_fproport_c_diag(5:8,:) - mean(mbsModel_PREF_c1_0vls_fproport_c_diag(5:8,:),2),2) ;
        pvals_diag = zeros(4,1) ;
        for paramvar = 1:4 % looping over variance parameters
            pvl = 1-find(bsquantiles(paramvar,:)>=vModelHat_c1.PREF_0vls_fproport_c_diag(4+paramvar),1)/num_boots ;
            if isempty(pvl)==1  % result is empty if parameter estimate super highly significant
                pvals_diag(paramvar) = 0.0 ;     
            else
                pvals_diag(paramvar) = pvl ;
            end
        end
        
	%   Put together standard errors and p-values:
	inference_PREF_c1_0vls_fproport_c       = [se_PREF_c1_0vls_fproport_c(1:4); pvals; se_PREF_c1_0vls_fproport_c(9)] ;
	inference_PREF_c1_0vls_fproport_c_diag  = [se_PREF_c1_0vls_fproport_c_diag(1:4); pvals_diag; se_PREF_c1_0vls_fproport_c_diag(9)] ;
	clearvars bsquantiles pvals pvl se_PREF_c1_0vls_fproport_c se_PREF_c1_0vls_fproport_c_diag

    %   -------------------------------------------------------------------

    %   ALTERNATIVE SPEC 2:
	se_PREF_c1_simple       = iqr(mbsModel_PREF_c1_simple,2)        / 1.349 ;
	se_PREF_c1_simple_diag  = iqr(mbsModel_PREF_c1_simple_diag,2)   / 1.349 ;
        
        bsquantiles = sort(mbsModel_PREF_c1_simple(5:8,:) - mean(mbsModel_PREF_c1_simple(5:8,:),2),2) ;
        pvals = zeros(4,1) ;
        for paramvar = 1:4 % looping over variance parameters
            pvl = 1-find(bsquantiles(paramvar,:)>=vModelHat_c1.PREF_simple(4+paramvar),1)/num_boots ;
            if isempty(pvl)==1  % result is empty if parameter estimate super highly significant
                pvals(paramvar) = 0.0 ;     
            else
                pvals(paramvar) = pvl ;
            end
        end
        bsquantiles = sort(mbsModel_PREF_c1_simple_diag(5:8,:) - mean(mbsModel_PREF_c1_simple_diag(5:8,:),2),2) ;
        pvals_diag = zeros(4,1) ;
        for paramvar = 1:4 % looping over variance parameters
            pvl = 1-find(bsquantiles(paramvar,:)>=vModelHat_c1.PREF_simple_diag(4+paramvar),1)/num_boots ;
            if isempty(pvl)==1  % result is empty if parameter estimate super highly significant
                pvals_diag(paramvar) = 0.0 ;     
            else
                pvals_diag(paramvar) = pvl ;
            end
        end
        
	%   Put together standard errors and p-values:
	inference_PREF_c1_simple        = [se_PREF_c1_simple(1:4); pvals; se_PREF_c1_simple(9)] ;
	inference_PREF_c1_simple_diag   = [se_PREF_c1_simple_diag(1:4); pvals_diag; se_PREF_c1_simple_diag(9)] ;
	clearvars bsquantiles pvals pvl se_PREF_c1_simple se_PREF_c1_simple_diag

    %   -------------------------------------------------------------------

    %   ALTERNATIVE SPEC 3:
	se_PREF_c1_proport_c_bare       = iqr(mbsModel_PREF_c1_proport_c_bare,2)        / 1.349 ;
	se_PREF_c1_proport_c_bare_diag  = iqr(mbsModel_PREF_c1_proport_c_bare_diag,2)   / 1.349 ;
        
        bsquantiles = sort(mbsModel_PREF_c1_proport_c_bare(5:8,:) - mean(mbsModel_PREF_c1_proport_c_bare(5:8,:),2),2) ;
        pvals = zeros(4,1) ;
        for paramvar = 1:4 % looping over variance parameters
            pvl = 1-find(bsquantiles(paramvar,:)>=vModelHat_c1.PREF_proport_c_bare(4+paramvar),1)/num_boots ;
            if isempty(pvl)==1  % result is empty if parameter estimate super highly significant
                pvals(paramvar) = 0.0 ;     
            else
                pvals(paramvar) = pvl ;
            end
        end
        bsquantiles = sort(mbsModel_PREF_c1_proport_c_bare_diag(5:8,:) - mean(mbsModel_PREF_c1_proport_c_bare_diag(5:8,:),2),2) ;
        pvals_diag = zeros(4,1) ;
        for paramvar = 1:4 % looping over variance parameters
            pvl = 1-find(bsquantiles(paramvar,:)>=vModelHat_c1.PREF_proport_c_bare_diag(4+paramvar),1)/num_boots ;
            if isempty(pvl)==1  % result is empty if parameter estimate super highly significant
                pvals_diag(paramvar) = 0.0 ;     
            else
                pvals_diag(paramvar) = pvl ;
            end
        end
        
	%   Put together standard errors and p-values:
	inference_PREF_c1_proport_c_bare        = [se_PREF_c1_proport_c_bare(1:4); pvals; se_PREF_c1_proport_c_bare(9:end)] ;
	inference_PREF_c1_proport_c_bare_diag   = [se_PREF_c1_proport_c_bare_diag(1:4); pvals_diag; se_PREF_c1_proport_c_bare_diag(9:end)] ;
	clearvars bsquantiles pvals pvl se_PREF_c1_proport_c_bare se_PREF_c1_proport_c_bare_diag

    %   -------------------------------------------------------------------

	%   ALTERNATIVE SPEC 4:
	se_PREF_c1_proport_c        = iqr(mbsModel_PREF_c1_proport_c,2)         / 1.349 ;
	se_PREF_c1_proport_c_diag   = iqr(mbsModel_PREF_c1_proport_c_diag,2)    / 1.349 ;
        
        bsquantiles = sort(mbsModel_PREF_c1_proport_c(5:8,:) - mean(mbsModel_PREF_c1_proport_c(5:8,:),2),2) ;
        pvals = zeros(4,1) ;
        for paramvar = 1:4 % looping over variance parameters
            pvl = 1-find(bsquantiles(paramvar,:)>=vModelHat_c1.PREF_proport_c(4+paramvar),1)/num_boots ;
            if isempty(pvl)==1  % result is empty if parameter estimate super highly significant
                pvals(paramvar) = 0.0 ;     
            else
                pvals(paramvar) = pvl ;
            end
        end
        bsquantiles = sort(mbsModel_PREF_c1_proport_c_diag(5:8,:) - mean(mbsModel_PREF_c1_proport_c_diag(5:8,:),2),2) ;
        pvals_diag = zeros(4,1) ;
        for paramvar = 1:4 % looping over variance parameters
            pvl = 1-find(bsquantiles(paramvar,:)>=vModelHat_c1.PREF_proport_c_diag(4+paramvar),1)/num_boots ;
            if isempty(pvl)==1  % result is empty if parameter estimate super highly significant
                pvals_diag(paramvar) = 0.0 ;     
            else
                pvals_diag(paramvar) = pvl ;
            end
        end
        
	%   Put together standard errors and p-values:
	inference_PREF_c1_proport_c         = [se_PREF_c1_proport_c(1:4); pvals; se_PREF_c1_proport_c(9:end)] ;
	inference_PREF_c1_proport_c_diag    = [se_PREF_c1_proport_c_diag(1:4); pvals_diag; se_PREF_c1_proport_c_diag(9:end)] ;
	clearvars bsquantiles pvals pvl se_PREF_c1_proport_c se_PREF_c1_proport_c_diag

    %   -------------------------------------------------------------------

    %   ALTERNATIVE SPEC 5:
	se_PREF_c1_same_c       = iqr(mbsModel_PREF_c1_same_c,2)        / 1.349 ;
	se_PREF_c1_same_c_diag  = iqr(mbsModel_PREF_c1_same_c_diag,2)   / 1.349 ;
        
        bsquantiles = sort(mbsModel_PREF_c1_same_c(5:8,:) - mean(mbsModel_PREF_c1_same_c(5:8,:),2),2) ;
        pvals = zeros(4,1) ;
        for paramvar = 1:4 % looping over variance parameters
            pvl = 1-find(bsquantiles(paramvar,:)>=vModelHat_c1.PREF_same_c(4+paramvar),1)/num_boots ;
            if isempty(pvl)==1  % result is empty if parameter estimate super highly significant
                pvals(paramvar) = 0.0 ;     
            else
                pvals(paramvar) = pvl ;
            end
        end
        bsquantiles = sort(mbsModel_PREF_c1_same_c_diag(5:8,:) - mean(mbsModel_PREF_c1_same_c_diag(5:8,:),2),2) ;
        pvals_diag = zeros(4,1) ;
        for paramvar = 1:4 % looping over variance parameters
            pvl = 1-find(bsquantiles(paramvar,:)>=vModelHat_c1.PREF_same_c_diag(4+paramvar),1)/num_boots ;
            if isempty(pvl)==1  % result is empty if parameter estimate super highly significant
                pvals_diag(paramvar) = 0.0 ;     
            else
                pvals_diag(paramvar) = pvl ;
            end
        end
        
	%   Put together standard errors and p-values:
	inference_PREF_c1_same_c        = [se_PREF_c1_same_c(1:4); pvals; se_PREF_c1_same_c(9:14)] ;
	inference_PREF_c1_same_c_diag   = [se_PREF_c1_same_c_diag(1:4); pvals_diag; se_PREF_c1_same_c_diag(9:14)] ;
	clearvars bsquantiles pvals pvl se_PREF_c1_same_c se_PREF_c1_same_c_diag

end