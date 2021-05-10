
%%  Declare program switches
%
%   'Consumption Inequality across Heterogeneous Families'
%
%   Alexandros Theloudis
%   LISER Luxembourg 
%   Tilburg Econometrics & Operations Research 
%   Spring 2021
%
%   =======================================================================

%   Global variables:
global  do T stationary_wage_params bootstrap ...
        num_boots num_pref_rdraws num_pref_sims sd_trim_pref_draws min_abs_denom_epsilon ...
        num_pref_rdraws_taxestim sd_trim_pref_draws_taxestim ;

    
%%  1.  CONTROL SWITCHES
%   Set the program switches & attributes.
%   -----------------------------------------------------------------------

%   Switches 'do' and 'deliver' that control what parts of the code are executed:
do.inference                                = 0 ;   %   do_inference = { 0 No ; 1 Do }
do.wu_krueger                               = 0 ;   %   do_wu_krueger = { 0 No ; 1 Do }
do.welfare                                  = 0 ;   %   do_welfare = { 0 No ; 1 Do }

%   Attributes of wage and model structures:
T                                           = 7 ;   %   number of periods in data (6, 7, or 10)
stationary_wage_params                      = 1 ;   %   stationary_wage_params = { 0 non-stationary; 1 stationary (default) }
num_boots                                   = 1000 ;

%   Wage estimates in memory:
bootstrap.wages                             = 'seWages' ;

%   Model estimates in memory:
%   -BPS
bootstrap.BPS_2001_c1                       = 'se_BPS_2001_c1' ;
bootstrap.BPS_2001_c1_diag                  = 'se_BPS_2001_c1_diag' ;
bootstrap.BPS_2001_c2                       = 'se_BPS_2001_c2' ;
%   -TRANS
bootstrap.TRANS_c1                          = 'se_TRANS_c1' ;
bootstrap.TRANS_c1_diag                     = 'se_TRANS_c1_diag' ;
bootstrap.TRANS_c2                          = 'se_TRANS_c2' ;
%   -TRANS3
bootstrap.TRANS3_c1                         = 'se_TRANS3_c1' ;
bootstrap.TRANS3_c1_diag                    = 'se_TRANS3_c1_diag' ;
bootstrap.TRANS3_c2                         = 'se_TRANS3_c2' ;
%   -VAR
bootstrap.VAR_c1                            = 'inference_VAR_c1' ;
bootstrap.VAR_c1_diag                       = 'inference_VAR_c1_diag' ;
bootstrap.VAR_c2                            = 'inference_VAR_c2' ;
%   -COV
bootstrap.COV_c1                            = 'inference_COV_c1' ;
bootstrap.COV_c1_diag                       = 'inference_COV_c1_diag' ;
bootstrap.COV_nolsx_c1                      = 'inference_COV_nolsx_c1' ;
bootstrap.COV_nolsx_c1_diag                 = 'inference_COV_nolsx_c1_diag' ;
bootstrap.COV_c2                            = 'inference_COV_c2' ;
bootstrap.COV_nolsx_c2                      = 'inference_COV_nolsx_c2' ;
%   -PREF
bootstrap.PREF_c1                           = 'inference_PREF_c1' ;
bootstrap.PREF_c1_diag                      = 'inference_PREF_c1_diag' ;
bootstrap.PREF_c2                           = 'inference_PREF_c2' ;
%   -ALTERNATIVE
bootstrap.c1_0vls_fproport_c                = 'inference_PREF_c1_0vls_fproport_c' ;
bootstrap.c1_0vls_fproport_c_diag           = 'inference_PREF_c1_0vls_fproport_c_diag' ;
bootstrap.c1_simple                         = 'inference_PREF_c1_simple' ;
bootstrap.c1_simple_diag                    = 'inference_PREF_c1_simple_diag' ;
bootstrap.c1_proport_c_bare                 = 'inference_PREF_c1_proport_c_bare' ; 
bootstrap.c1_proport_c_bare_diag            = 'inference_PREF_c1_proport_c_bare_diag' ;
bootstrap.c1_proport_c                      = 'inference_PREF_c1_proport_c' ;
bootstrap.c1_proport_c_diag                 = 'inference_PREF_c1_proport_c_diag' ;
bootstrap.c1_same_c                         = 'inference_PREF_c1_same_c' ;
bootstrap.c1_same_c_diag                    = 'inference_PREF_c1_same_c_diag' ;

%   Attributes of simulations:
num_pref_rdraws                             = 10000 ;   %   size of population to simulate
num_pref_sims                               = 1000 ;    %   number of populations to simulate
sd_trim_pref_draws                          = 2.5 ;     %   standard deviations above & below mean to trim preference draws when distribution is joint normal
min_abs_denom_epsilon                       = 0.0015 ;  %   minimum absolute value of denominator in epsilon; prevent division by zero or near zero 
num_pref_rdraws_taxestim                    = 10000 ;   %   size of population to simulate for estimation with taxes
sd_trim_pref_draws_taxestim                 = 2.5 ; 	%   st.dev. around mean to trim joint normal preference draws in estimation with taxes