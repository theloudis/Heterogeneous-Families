
%%  Estimation of structural model -- various specifications
%
%   'Consumption Inequality across Heterogeneous Families'
%
%   Alexandros Theloudis
%   LISER Luxembourg 
%   Tilburg Econometrics & Operations Research 
%   Spring 2021
%
%   =======================================================================

%   Initial statements:
global  vWageHat vWageHat_diag vModelHat_c1 vModelHat_c2 ;


%%  1.  ESTIMATION OF BPS SPECIFICATION
%   Implements the GMM estimation of the parameters of the structural model 
%	under the specification of Blundell, Pistaferri, Saporta-Eksten (2016). 
%   -----------------------------------------------------------------------

%   1: BPS 2001-2011.
%   Configuration: third_moments = -1, heterogeneity = 0, j0 = 3 
%   (i.e. starting in 2001), consumption measurement error = 15%*Var(Dc).
[vModelHat_c1.BPS_2001,      modelFval_c1.BPS_2001,      modelFlag_c1.BPS_2001] ...
    	= estm_model(vWageHat,      mc1.Couple, mc1.Ind, mc1.Es, mc1.Pi, mc1.Err, mc1.Avg, 'iter', -1, 0, 3, 0.15, 'on', 'eye') ;   
[vModelHat_c1.BPS_2001_diag, modelFval_c1.BPS_2001_diag, modelFlag_c1.BPS_2001_diag] ...
    	= estm_model(vWageHat_diag, mc1.Couple, mc1.Ind, mc1.Es, mc1.Pi, mc1.Err, mc1.Avg, 'iter', -1, 0, 3, 0.15, 'on', varmoms_c1) ;   

%   1age: BPS 2001-2011, residuals net of age of youngest child.
%   Configuration: third_moments = -1, heterogeneity = 0, j0 = 3 
%   (i.e. starting in 2001), consumption measurement error = 15%*Var(Dc).
[vModelHat_c2.BPS_2001, modelFval_c2.BPS_2001, modelFlag_c2.BPS_2001] ...
    	= estm_model(vWageHat, mc2.Couple, mc2.Ind, mc2.Es, mc2.Pi, mc2.Err, mc2.Avg, 'iter', -1, 0, 3, 0.15, 'on', 'eye') ;   


%%  2.  TRANSITORY SHOCKS
%   Implements the GMM estimation of the parameters of the structural model 
%	using moments pertaining to transitory shocks only. 
%   -----------------------------------------------------------------------

%   2: Transitory shocks 2001-2011.
%   Configuration: third_moments = 0, heterogeneity = 0, j0 = 3 
%   (i.e. starting in 2001), consumption measurement error = 15%*Var(Dc).
[vModelHat_c1.TRANS,      modelFval_c1.TRANS,      modelFlag_c1.TRANS] ...
    	= estm_model(vWageHat,      mc1.Couple, mc1.Ind, mc1.Es, mc1.Pi, mc1.Err, mc1.Avg, 'iter', 0, 0, 3, 0.15, 'on', 'eye') ;  
[vModelHat_c1.TRANS_diag, modelFval_c1.TRANS_diag, modelFlag_c1.TRANS_diag] ...
    	= estm_model(vWageHat_diag, mc1.Couple, mc1.Ind, mc1.Es, mc1.Pi, mc1.Err, mc1.Avg, 'iter', 0, 0, 3, 0.15, 'on', cell2mat(varmoms_c1(1))) ;  

%   2age: Transitory shocks 2001-2011, residuals net of age of youngest child.
%   Configuration: third_moments = 0, heterogeneity = 0, j0 = 3 
%   (i.e. starting in 2001), consumption measurement error = 15%*Var(Dc).
[vModelHat_c2.TRANS, modelFval_c2.TRANS, modelFlag_c2.TRANS] ...
    	= estm_model(vWageHat, mc2.Couple, mc2.Ind, mc2.Es, mc2.Pi, mc2.Err, mc2.Avg, 'iter', 0, 0, 3, 0.15, 'on', 'eye') ;  


%%  3.  THIRD MOMENTS
%   Implements the GMM estimation of the parameters of the structural model 
%	adding selected third moments.
%   -----------------------------------------------------------------------

%   3: Third moments 2001-2011.
%   Configuration: third_moments = 1, heterogeneity = 0, j0 = 3 
%   (i.e. starting in 2001), consumption measurement error = 15%*Var(Dc).
[vModelHat_c1.TRANS3,      modelFval_c1.TRANS3,      modelFlag_c1.TRANS3] ...
    	= estm_model(vWageHat,      mc1.Couple, mc1.Ind, mc1.Es, mc1.Pi, mc1.Err, mc1.Avg, 'iter', 1, 0, 3, 0.15, 'on', 'eye') ;  
[vModelHat_c1.TRANS3_diag, modelFval_c1.TRANS3_diag, modelFlag_c1.TRANS3_diag] ...
    	= estm_model(vWageHat_diag, mc1.Couple, mc1.Ind, mc1.Es, mc1.Pi, mc1.Err, mc1.Avg, 'iter', 1, 0, 3, 0.15, 'on', cell2mat(varmoms_c1(1))) ;  

%   3age:  Third moments 2001-2011, residuals net of age of youngest child.
%   Configuration: third_moments = 1, heterogeneity = 0, j0 = 3 
%   (i.e. starting in 2001), consumption measurement error = 15%*Var(Dc).
[vModelHat_c2.TRANS3, modelFval_c2.TRANS3, modelFlag_c2.TRANS3] ...
    	= estm_model(vWageHat, mc2.Couple, mc2.Ind, mc2.Es, mc2.Pi, mc2.Err, mc2.Avg, 'iter', 1, 0, 3, 0.15, 'on', 'eye') ;  


%%  4.  ESTIMATION OF RESTRICTED HETEROGENEITY
%   Implements the GMM estimation of the parameters of the structural model 
%	allowing for marginal preference heterogeneity.
%   -----------------------------------------------------------------------

%   4: Restricted heterogeneity 2001-2011.
%   Configuration: third_moments = 1, heterogeneity = 1, j0 = 3 
%   (i.e. starting in 2001), consumption measurement error = 15%*Var(Dc).
[vModelHat_c1.VAR,      modelFval_c1.VAR,      modelFlag_c1.VAR] ...
    	= estm_model(vWageHat,      mc1.Couple, mc1.Ind, mc1.Es, mc1.Pi, mc1.Err, mc1.Avg, 'iter', 1, 1, 3, 0.15, 'on', 'eye') ;  
[vModelHat_c1.VAR_diag, modelFval_c1.VAR_diag, modelFlag_c1.VAR_diag] ...
    	= estm_model(vWageHat_diag, mc1.Couple, mc1.Ind, mc1.Es, mc1.Pi, mc1.Err, mc1.Avg, 'iter', 1, 1, 3, 0.15, 'on', cell2mat(varmoms_c1(1))) ;  

%   4age: Restricted heterogeneity 2001-2011, residuals net of age of   
%   youngest child.
%   Configuration: third_moments = 1, heterogeneity = 1, j0 = 3 
%   (i.e. starting in 2001), consumption measurement error = 15%*Var(Dc).
[vModelHat_c2.VAR, modelFval_c2.VAR, modelFlag_c2.VAR] ...
    	= estm_model(vWageHat, mc2.Couple, mc2.Ind, mc2.Es, mc2.Pi, mc2.Err, mc2.Avg, 'iter', 1, 1, 3, 0.15, 'on', 'eye') ;  


%%  5.  ESTIMATION OF FULL HETEROGENEITY
%   Implements the GMM estimation of the parameters of the structural model 
%	allowing for full preference heterogeneity.
%   -----------------------------------------------------------------------

%   5: Full heterogeneity 2001-2011.
%   Configuration: third_moments = 1, heterogeneity = 2, j0 = 3 
%   (i.e. starting in 2001), consumption measurement error = 15%*Var(Dc).
%   -labor supply cross-eslaticities on:
[vModelHat_c1.COV,      modelFval_c1.COV,      modelFlag_c1.COV] ...
    	= estm_model(vWageHat,      mc1.Couple, mc1.Ind, mc1.Es, mc1.Pi, mc1.Err, mc1.Avg, 'iter', 1, 2, 3, 0.15, 'on', 'eye') ;  
[vModelHat_c1.COV_diag, modelFval_c1.COV_diag, modelFlag_c1.COV_diag] ...
    	= estm_model(vWageHat_diag, mc1.Couple, mc1.Ind, mc1.Es, mc1.Pi, mc1.Err, mc1.Avg, 'iter', 1, 2, 3, 0.15, 'on', cell2mat(varmoms_c1(1))) ;  
%   -labor supply cross-eslaticities off:
[vModelHat_c1.COV_nolsx,      modelFval_c1.COV_nolsx,      modelFlag_c1.COV_nolsx] ...
    	= estm_model(vWageHat,      mc1.Couple, mc1.Ind, mc1.Es, mc1.Pi, mc1.Err, mc1.Avg, 'iter', 1, 2, 3, 0.15, 'off', 'eye') ;  
[vModelHat_c1.COV_nolsx_diag, modelFval_c1.COV_nolsx_diag, modelFlag_c1.COV_nolsx_diag] ...
    	= estm_model(vWageHat_diag, mc1.Couple, mc1.Ind, mc1.Es, mc1.Pi, mc1.Err, mc1.Avg, 'iter', 1, 2, 3, 0.15, 'off', cell2mat(varmoms_c1(1))) ;  

%   5age: Full heterogeneity 2001-2011, residuals net of age of youngest child.
%   Configuration: third_moments = 1, heterogeneity = 2, j0 = 3 
%   (i.e. starting in 2001), consumption measurement error = 15%*Var(Dc).
%   -labor supply cross-eslaticities on:
[vModelHat_c2.COV, modelFval_c2.COV, modelFlag_c2.COV] ...
    	= estm_model(vWageHat, mc2.Couple, mc2.Ind, mc2.Es, mc2.Pi, mc2.Err, mc2.Avg, 'iter', 1, 2, 3, 0.15, 'on', 'eye') ;  
%   -labor supply cross-eslaticities off:
[vModelHat_c2.COV_nolsx, modelFval_c2.COV_nolsx, modelFlag_c2.COV_nolsx] ...
    	= estm_model(vWageHat, mc2.Couple, mc2.Ind, mc2.Es, mc2.Pi, mc2.Err, mc2.Avg, 'iter', 1, 2, 3, 0.15, 'off', 'eye') ;  


%%  6.  PREFERRED SPECIFICATION
%   Implements the GMM estimation of the parameters of the structural  
%	model in the preferred specification. 
%   -----------------------------------------------------------------------

%   6: Preferred specification 2001-2011.
%   Configuration: third_moments = 1, heterogeneity = 7, j0 = 3 
%   (i.e. starting in 2001), consumption measurement error = 15%*Var(Dc).
[vModelHat_c1.PREF,      modelFval_c1.PREF,      modelFlag_c1.PREF] ...
    	= estm_model(vWageHat,      mc1.Couple, mc1.Ind, mc1.Es, mc1.Pi, mc1.Err, mc1.Avg, 'iter', 1, 7, 3, 0.15, 'off', 'eye') ;  
[vModelHat_c1.PREF_diag, modelFval_c1.PREF_diag, modelFlag_c1.PREF_diag] ...
    	= estm_model(vWageHat_diag, mc1.Couple, mc1.Ind, mc1.Es, mc1.Pi, mc1.Err, mc1.Avg, 'iter', 1, 7, 3, 0.15, 'off', cell2mat(varmoms_c1(1))) ;  

%   6age: Preferred specification 2001-2011, residuals net of age of    
%   youngest child.
%   Configuration: third_moments = 1, heterogeneity = 7, j0 = 3 
%   (i.e. starting in 2001), consumption measurement error = 15%*Var(Dc).
[vModelHat_c2.PREF, modelFval_c2.PREF, modelFlag_c2.PREF] ...
    	= estm_model(vWageHat, mc2.Couple, mc2.Ind, mc2.Es, mc2.Pi, mc2.Err, mc2.Avg, 'iter', 1, 7, 3, 0.15, 'off', 'eye') ;  


%%  7.  ALTERNATIVES TO PREFERRED SPECIFICATION
%   Implements the GMM estimation of the parameters of the structural  
%	model in various alternatives to the preferred specification. 
%   -----------------------------------------------------------------------

%   Alternative R1: 2001-2011.
%   Configuration: third_moments = 1, heterogeneity = 8 --> fixed propc = 1.5, 
%   no variation in labor supply elasticities, j0 = 3 (i.e. starting in 2001), 
%   consumption measurement error = 15%*Var(Dc).
[vModelHat_c1.PREF_0vls_fproport_c, modelFval_c1.PREF_0vls_fproport_c, modelFlag_c1.PREF_0vls_fproport_c] ...
    	= estm_model(vWageHat,         mc1.Couple, mc1.Ind, mc1.Es, mc1.Pi, mc1.Err, mc1.Avg, 'iter', 1, 8, 3, 0.15, 'off', 'eye') ;  
[vModelHat_c1.PREF_0vls_fproport_c_diag, modelFval_c1.PREF_0vls_fproport_c_diag, modelFlag_c1.PREF_0vls_fproport_c_diag] ...
        = estm_model(vWageHat_diag,    mc1.Couple, mc1.Ind, mc1.Es, mc1.Pi, mc1.Err, mc1.Avg, 'iter', 1, 8, 3, 0.15, 'off', cell2mat(varmoms_c1(1))) ;  

%   Alternative R2: 2001-2011.
%   Configuration: third_moments = 1, heterogeneity = 10 --> fixed propc = 1.5, 
%   no joint variation in labor supply elasticities, j0 = 3 (i.e. starting in 2001), 
%   consumption measurement error = 15%*Var(Dc).
[vModelHat_c1.PREF_simple, modelFval_c1.PREF_simple, modelFlag_c1.PREF_simple] ...
    	= estm_model(vWageHat,         mc1.Couple, mc1.Ind, mc1.Es, mc1.Pi, mc1.Err, mc1.Avg, 'iter', 1, 10, 3, 0.15, 'off', 'eye') ;  
[vModelHat_c1.PREF_simple_diag, modelFval_c1.PREF_simple_diag, modelFlag_c1.PREF_simple_diag] ...
        = estm_model(vWageHat_diag,    mc1.Couple, mc1.Ind, mc1.Es, mc1.Pi, mc1.Err, mc1.Avg, 'iter', 1, 10, 3, 0.15, 'off', cell2mat(varmoms_c1(1))) ;  

%   Alternative R3: 2001-2011.
%   Configuration: third_moments = 1, heterogeneity = 6 --> estimate propc, 
%   j0 = 3 (i.e. starting in 2001), consumption measurement error = 15%*Var(Dc).
[vModelHat_c1.PREF_proport_c_bare, modelFval_c1.PREF_proport_c_bare, modelFlag_c1.PREF_proport_c_bare] ...
    	= estm_model(vWageHat,         mc1.Couple, mc1.Ind, mc1.Es, mc1.Pi, mc1.Err, mc1.Avg, 'iter', 1, 6, 3, 0.15, 'off', 'eye') ;  
[vModelHat_c1.PREF_proport_c_bare_diag, modelFval_c1.PREF_proport_c_bare_diag, modelFlag_c1.PREF_proport_c_bare_diag] ...
        = estm_model(vWageHat_diag,    mc1.Couple, mc1.Ind, mc1.Es, mc1.Pi, mc1.Err, mc1.Avg, 'iter', 1, 6, 3, 0.15, 'off', cell2mat(varmoms_c1(1))) ;  

%   Alternative R4: 2001-2011.
%   Configuration: third_moments = 1, heterogeneity = 5 --> estimate propc, 
%   equal labor supply elasticities, j0 = 3 (i.e. starting in 2001), 
%   consumption measurement error = 15%*Var(Dc).
[vModelHat_c1.PREF_proport_c, modelFval_c1.PREF_proport_c, modelFlag_c1.PREF_proport_c] ...
    	= estm_model(vWageHat,         mc1.Couple, mc1.Ind, mc1.Es, mc1.Pi, mc1.Err, mc1.Avg, 'iter', 1, 5, 3, 0.15, 'off', 'eye') ;  
[vModelHat_c1.PREF_proport_c_diag, modelFval_c1.PREF_proport_c_diag, modelFlag_c1.PREF_proport_c_diag] ...
        = estm_model(vWageHat_diag,    mc1.Couple, mc1.Ind, mc1.Es, mc1.Pi, mc1.Err, mc1.Avg, 'iter', 1, 5, 3, 0.15, 'off', cell2mat(varmoms_c1(1))) ;  

%   Alternative R5: 2001-2011.
%   Configuration: third_moments = 1, heterogeneity = 11 --> equal
%   consumption elasticities, j0 = 3 (i.e. starting in 2001), 
%   consumption measurement error = 15%*Var(Dc).
[vModelHat_c1.PREF_same_c, modelFval_c1.PREF_same_c, modelFlag_c1.PREF_same_c] ...
    	= estm_model(vWageHat,         mc1.Couple, mc1.Ind, mc1.Es, mc1.Pi, mc1.Err, mc1.Avg, 'iter', 1, 11, 3, 0.15, 'off', 'eye') ;  
[vModelHat_c1.PREF_same_c_diag, modelFval_c1.PREF_same_c_diag, modelFlag_c1.PREF_same_c_diag] ...
        = estm_model(vWageHat_diag,    mc1.Couple, mc1.Ind, mc1.Es, mc1.Pi, mc1.Err, mc1.Avg, 'iter', 1, 11, 3, 0.15, 'off', cell2mat(varmoms_c1(1))) ;  
