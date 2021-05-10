
%%  Deliver wage and preference parameter estimates in tables.
%
%   'Consumption Inequality across Heterogeneous Families'
%   This script delivers point estimates, standard errors, and p-values 
%   of the wage and preference parameters, and summary stats for pi and es.
%
%   Alexandros Theloudis
%   LISER Luxembourg 
%   Tilburg Econometrics & Operations Research 
%   Spring 2021
%
%   =======================================================================

%   Initial statements:
global  T do dDir stationary_wage_params ...
        vWageHat vModelHat_c1 vModelHat_c2 bootstrap ;

    
%%  1.  RETRIEVE PARAMETER POINT-ESTIMATES
%   Retrieve parameter estimates from memory or hard disk:
%   -----------------------------------------------------------------------

%   I. Baseline wage estimates (equally weighted GMM):
%   -------------------------------------------------
wages       = vWageHat ;

%   II. Baseline preferences estimates (equally weighted GMM):
%   ---------------------------------------------------------
%   -BPS, 2001-2011:
prefs_c11  	= vModelHat_c1.BPS_2001 ;
%   -TRANS:
prefs_c12 	= vModelHat_c1.TRANS ;
%   -TRANS3:
prefs_c13 	= vModelHat_c1.TRANS3 ;
%   -VAR:
prefs_c14	= vModelHat_c1.VAR ;
%   -COV:
prefs_c15 	= vModelHat_c1.COV ;
%   -COV, no labor supply cross-elasticities:
prefs_c16 	= vModelHat_c1.COV_nolsx ;
%   -PREFERRED:
prefs_c17   = vModelHat_c1.PREF ;

%   III. Alternatives to preferred specification (equally weighted GMM):
%   -------------------------------------------------------------------
%   -1: PREF_c1_0vls_fproport_c:
rob1        = vModelHat_c1.PREF_0vls_fproport_c ;
%   -2: PREF_c1_simple:
rob2        = vModelHat_c1.PREF_simple ;
%   -3: PREF_c1_proport_c_bare:
rob3        = vModelHat_c1.PREF_proport_c_bare ;
%   -4: PREF_c1_proport_c:
rob4        = vModelHat_c1.PREF_proport_c ;
%   -5: PREF_c1_same_c:
rob5        = vModelHat_c1.PREF_same_c ;

%   IV. Preferences estimates, data net of age youngest child (equally weighted GMM):
%   --------------------------------------------------------------------------------
%   -BPS, 2001-2011:
prefsa_c11  = vModelHat_c2.BPS_2001 ;
%   -TRANS:
prefsa_c12 	= vModelHat_c2.TRANS ;
%   -TRANS3:
prefsa_c13 	= vModelHat_c2.TRANS3 ;
%   -VAR:
prefsa_c14 	= vModelHat_c2.VAR ;
%   -COV:
prefsa_c15	= vModelHat_c2.COV ;
%   -COV, no labor supply cross-elasticities:
prefsa_c16  = vModelHat_c2.COV_nolsx ;
%   -PREFERRED:
prefsa_c17 	= vModelHat_c2.PREF ;

%   V. Preferences estimates (diagonally weighted GMM):
%   --------------------------------------------------
%   -BPS, 2001-2011:
diag_c11  	= vModelHat_c1.BPS_2001_diag ;
%   -TRANS:
diag_c12 	= vModelHat_c1.TRANS_diag ;
%   -TRANS3:
diag_c13  	= vModelHat_c1.TRANS3_diag ;
%   -VAR:
diag_c14  	= vModelHat_c1.VAR_diag ;
%   -COV:
diag_c15 	= vModelHat_c1.COV_diag ;
%   -COV, no labor supply cross-elasticities:
diag_c16  	= vModelHat_c1.COV_nolsx_diag ;
%   -PREFERRED:
diag_c17  	= vModelHat_c1.PREF_diag ;

%   VI. Alternatives to preferred specification (diagonally weighted GMM):
%   ---------------------------------------------------------------------
%   -1: PREF_c1_0vls_fproport_c:
diagrob1 	= vModelHat_c1.PREF_0vls_fproport_c_diag ;
%   -2: PREF_c1_simple:
diagrob2   	= vModelHat_c1.PREF_simple_diag ;
%   -3: PREF_c1_proport_c_bare:
diagrob3  	= vModelHat_c1.PREF_proport_c_bare_diag ;
%   -4: PREF_c1_proport_c:
diagrob4 	= vModelHat_c1.PREF_proport_c_diag ;
%   -5: PREF_c1_same_c:
diagrob5  	= vModelHat_c1.PREF_same_c_diag ;


%%  2.  RETRIEVE PARAMETER STANDARD ERRORS / p-VALUES
%   Retrieve inference objects from memory or hard disk:
%   -----------------------------------------------------------------------

%   Bootstrap has run recently and results are in memory:
if do.inference == 1
    
    %   I. Baseline wage estimates (equally weighted GMM):
    %   -------------------------------------------------
    se_wages        = seWages ;

    %   II. Baseline preferences estimates (equally weighted GMM):
    %   ---------------------------------------------------------
    %   -BPS, 2001-2011:
    se_prefs_c11    = se_BPS_2001_c1 ;
    %   -TRANS:
    se_prefs_c12    = se_TRANS_c1 ;
    %   -TRANS3:
    se_prefs_c13    = se_TRANS3_c1 ;
    %   -VAR:
    infer_prefs_c14 = inference_VAR_c1 ;
    %   -COV:
    infer_prefs_c15 = inference_COV_c1 ;
    %   -COV, no labor supply cross-elasticities:
    infer_prefs_c16 = inference_COV_nolsx_c1 ;
    %   -PREFERRED:
    infer_prefs_c17 = inference_PREF_c1 ;

    %   III. Alternatives to preferred specification (equally weighted GMM):
    %   -------------------------------------------------------------------
    %   -1: PREF_c1_0vls_fproport_c:
    infer_rob1      = inference_PREF_c1_0vls_fproport_c ;
    %   -2: PREF_c1_simple:
    infer_rob2      = inference_PREF_c1_simple ;
    %   -3: PREF_c1_proport_c_bare:
    infer_rob3      = inference_PREF_c1_proport_c_bare ;
    %   -4: PREF_c1_proport_c:
    infer_rob4      = inference_PREF_c1_proport_c ;
    %   -5: PREF_c1_same_c:
    infer_rob5      = inference_PREF_c1_same_c ;

    %   IV. Preferences estimates, data net of age youngest child (equally weighted GMM):
    %   --------------------------------------------------------------------------------
    %   -BPS, 2001-2011:
    se_prefsa_c11  	= se_BPS_2001_c2 ;
    %   -TRANS:
    se_prefsa_c12   = se_TRANS_c2 ;
    %   -TRANS3:
    se_prefsa_c13  	= se_TRANS3_c2 ;
    %   -VAR:
    infer_prefsa_c14= inference_VAR_c2 ;
    %   -COV:
    infer_prefsa_c15= inference_COV_c2 ;
    %   -COV, no labor supply cross-elasticities:
    infer_prefsa_c16= inference_COV_nolsx_c2 ;
    %   -PREFERRED:
    infer_prefsa_c17= inference_PREF_c2 ;

    %   V. Preferences estimates (diagonally weighted GMM):
    %   --------------------------------------------------
    %   -BPS, 2001-2011:
    se_diag_c11     = se_BPS_2001_c1_diag ;
    %   -TRANS:
    se_diag_c12     = se_TRANS_c1_diag ;
    %   -TRANS3:
    se_diag_c13     = se_TRANS3_c1_diag ;
    %   -VAR:
    infer_diag_c14  = inference_VAR_c1_diag ;
    %   -COV:
    infer_diag_c15  = inference_COV_c1_diag ;
    %   -COV, no labor supply cross-elasticities:
    infer_diag_c16  = inference_COV_nolsx_c1_diag ;
    %   -PREFERRED:
    infer_diag_c17  = inference_PREF_c1_diag ;

    %   VI. Alternatives to preferred specification (diagonally weighted GMM):
    %   ---------------------------------------------------------------------
    %   -1: PREF_c1_0vls_fproport_c:
    infer_diagrob1  = inference_PREF_c1_0vls_fproport_c_diag ;
    %   -2: PREF_c1_simple:
    infer_diagrob2  = inference_PREF_c1_simple_diag ;
    %   -3: PREF_c1_proport_c_bare:
    infer_diagrob3  = inference_PREF_c1_proport_c_bare_diag ;
    %   -4: PREF_c1_proport_c:
    infer_diagrob4  = inference_PREF_c1_proport_c_diag ;
    %   -5: PREF_c1_same_c:
    infer_diagrob5  = inference_PREF_c1_same_c_diag ;

%   Retrieved saved results:

else
    
    %   I. Baseline wage estimates (equally weighted GMM):
    %   -------------------------------------------------
    load(strcat(dDir,'/exports/results/EqGMM/',bootstrap.wages))
    se_wages        = seWages ;

    %   II. Baseline preferences estimates (equally weighted GMM):
    %   ---------------------------------------------------------
    %   -BPS, 2001-2011:
    load(strcat(dDir,'/exports/results/EqGMM/',bootstrap.BPS_2001_c1))
    se_prefs_c11    = se_BPS_2001_c1 ;
    %   -TRANS:
    load(strcat(dDir,'/exports/results/EqGMM/',bootstrap.TRANS_c1))
    se_prefs_c12    = se_TRANS_c1 ;
    %   -TRANS3:
    load(strcat(dDir,'/exports/results/EqGMM/',bootstrap.TRANS3_c1))
    se_prefs_c13    = se_TRANS3_c1 ;
    %   -VAR:
    load(strcat(dDir,'/exports/results/EqGMM/',bootstrap.VAR_c1))
    infer_prefs_c14 = inference_VAR_c1 ;
    %   -COV:
    load(strcat(dDir,'/exports/results/EqGMM/',bootstrap.COV_c1))
    infer_prefs_c15 = inference_COV_c1 ;
    %   -COV, no labor supply cross-elasticities:
    load(strcat(dDir,'/exports/results/EqGMM/',bootstrap.COV_nolsx_c1))
    infer_prefs_c16 = inference_COV_nolsx_c1 ;
    %   -PREFERRED:
    load(strcat(dDir,'/exports/results/EqGMM/',bootstrap.PREF_c1))
    infer_prefs_c17 = inference_PREF_c1 ;

    %   III. Alternatives to preferred specification (equally weighted GMM):
    %   -------------------------------------------------------------------
    %   -1: PREF_c1_0vls_fproport_c:
    load(strcat(dDir,'/exports/results/EqGMM/',bootstrap.c1_0vls_fproport_c))
    infer_rob1  = inference_PREF_c1_0vls_fproport_c ;
    %   -2: PREF_c1_simple:
    load(strcat(dDir,'/exports/results/EqGMM/',bootstrap.c1_simple))
    infer_rob2  = inference_PREF_c1_simple ;
    %   -3: PREF_c1_proport_c_bare:
    load(strcat(dDir,'/exports/results/EqGMM/',bootstrap.c1_proport_c_bare))
    infer_rob3  = inference_PREF_c1_proport_c_bare ;
    %   -4: PREF_c1_proport_c:
    load(strcat(dDir,'/exports/results/EqGMM/',bootstrap.c1_proport_c))
    infer_rob4  = inference_PREF_c1_proport_c ;
    %   -5: PREF_c1_same_c:
    load(strcat(dDir,'/exports/results/EqGMM/',bootstrap.c1_same_c))
    infer_rob5  = inference_PREF_c1_same_c ;

    %   IV. Preferences estimates, data net of age youngest child (equally weighted GMM):
    %   --------------------------------------------------------------------------------
    %   -BPS, 2001-2011:
    load(strcat(dDir,'/exports/results/EqGMM/',bootstrap.BPS_2001_c2))
    se_prefsa_c11    = se_BPS_2001_c2 ;
    %   -TRANS:
    load(strcat(dDir,'/exports/results/EqGMM/',bootstrap.TRANS_c2))
    se_prefsa_c12    = se_TRANS_c2 ;
    %   -TRANS3:
    load(strcat(dDir,'/exports/results/EqGMM/',bootstrap.TRANS3_c2))
    se_prefsa_c13    = se_TRANS3_c2 ;
    %   -VAR:
    load(strcat(dDir,'/exports/results/EqGMM/',bootstrap.VAR_c2))
    infer_prefsa_c14 = inference_VAR_c2 ;
    %   -COV:
    load(strcat(dDir,'/exports/results/EqGMM/',bootstrap.COV_c2))
    infer_prefsa_c15 = inference_COV_c2 ;
    %   -COV, no labor supply cross-elasticities:
    load(strcat(dDir,'/exports/results/EqGMM/',bootstrap.COV_nolsx_c2))
    infer_prefsa_c16 = inference_COV_nolsx_c2 ;
    %   -PREFERRED:
    load(strcat(dDir,'/exports/results/EqGMM/',bootstrap.PREF_c2))
    infer_prefsa_c17 = inference_PREF_c2 ;

    %   V. Preferences estimates (diagonally weighted GMM):
    %   --------------------------------------------------
    %   -BPS, 2001-2011:
    load(strcat(dDir,'/exports/results/DiagGMM/',bootstrap.BPS_2001_c1_diag))
    se_diag_c11    = se_BPS_2001_c1_diag ;
    %   -TRANS:
    load(strcat(dDir,'/exports/results/DiagGMM/',bootstrap.TRANS_c1_diag))
    se_diag_c12    = se_TRANS_c1_diag ;
    %   -TRANS3:
    load(strcat(dDir,'/exports/results/DiagGMM/',bootstrap.TRANS3_c1_diag))
    se_diag_c13    = se_TRANS3_c1_diag ;
    %   -VAR:
    load(strcat(dDir,'/exports/results/DiagGMM/',bootstrap.VAR_c1_diag))
    infer_diag_c14 = inference_VAR_c1_diag ;
    %   -COV:
    load(strcat(dDir,'/exports/results/DiagGMM/',bootstrap.COV_c1_diag))
    infer_diag_c15 = inference_COV_c1_diag ;
    %   -COV, no labor supply cross-elasticities:
    load(strcat(dDir,'/exports/results/DiagGMM/',bootstrap.COV_nolsx_c1_diag))
    infer_diag_c16 = inference_COV_nolsx_c1_diag ;
    %   -PREFERRED:
    load(strcat(dDir,'/exports/results/DiagGMM/',bootstrap.PREF_c1_diag))
    infer_diag_c17 = inference_PREF_c1_diag ;

    %   VI. Alternatives to preferred specification (diagonally weighted GMM):
    %   ---------------------------------------------------------------------
    %   -1: PREF_c1_0vls_fproport_c:
    load(strcat(dDir,'/exports/results/DiagGMM/',bootstrap.c1_0vls_fproport_c_diag))
    infer_diagrob1  = inference_PREF_c1_0vls_fproport_c_diag ;
    %   -2: PREF_c1_simple:
    load(strcat(dDir,'/exports/results/DiagGMM/',bootstrap.c1_simple_diag))
    infer_diagrob2  = inference_PREF_c1_simple_diag ;
    %   -3: PREF_c1_proport_c_bare:
    load(strcat(dDir,'/exports/results/DiagGMM/',bootstrap.c1_proport_c_bare_diag))
    infer_diagrob3  = inference_PREF_c1_proport_c_bare_diag ;
    %   -4: PREF_c1_proport_c:
    load(strcat(dDir,'/exports/results/DiagGMM/',bootstrap.c1_proport_c_diag))
    infer_diagrob4  = inference_PREF_c1_proport_c_diag ;
    %   -5: PREF_c1_same_c:
    load(strcat(dDir,'/exports/results/DiagGMM/',bootstrap.c1_same_c_diag))
    infer_diagrob5  = inference_PREF_c1_same_c_diag ;

end


%%  3.  DELIVER BASELINE WAGE PROCESS ESTIMATES (TABLE 3)
%   -----------------------------------------------------------------------

%   Check that wage parameters are stationary, else return error:
if stationary_wage_params == 0
    error('I cannot deliver parameter estimates because wages are non-stationary.')
end

%   Second moments of stationary wage shocks (adjust permanent shocks 
%   for biennial nature of data):
vH    = wages(1)/2 ;    % variance: permanent shock HD
sevH  = se_wages(1)/2;  % 
uH    = wages(6)  ;     % variance: transitory shock HD
seuH  = se_wages(6);    % 
vW    = wages(12)/2 ;   % variance: permanent shock WF
sevW  = se_wages(12)/2;   
uW    = wages(17) ;     % variance: transitory shock WF
seuW  = se_wages(17);   %
vHW   = wages(23)/2 ;   % covariance: permanent shocks
sevHW = se_wages(23)/2;  
uHW   = wages(28) ;     % covariance: transitory shocks
seuHW = se_wages(28);   % 
rvHW  = wages(34) ;     % correlation: permanent shocks
servHW= se_wages(34);   % 
ruHW  = wages(39) ;     % correlation: transitory shocks
seruHW= se_wages(39);   % 

%   Third moments of stationary wage shocks (adjust permanent shocks
%   for biennial nature of data):
gvH     = wages(45)/2;      % skewness: permanent shock HD
segvH   = se_wages(45)/2;  
guH     = wages(50) ;       % skewness: transitory shock HD
seguH   = se_wages(50);   
gvW     = wages(56)/2;      % skewness: permanent shock WF
segvW   = se_wages(56)/2;  
guW     = wages(61) ;       % skewness: transitory shock WF
seguW   = se_wages(61);    
gvH2W   = wages(67)/2;      % co-skewness: E[vH^2 vW]
segvH2W = se_wages(67)/2;  
guH2W   = wages(72) ;       % co-skewness: E[uH^2 uW]
seguH2W = se_wages(72);   
gvHW2   = wages(78)/2;      % co-skewness: E[vH vW^2]
segvHW2 = se_wages(78)/2;  
guHW2   = wages(83) ;       % co-skewness: E[uH uW^2]
seguHW2 = se_wages(83);  

%   Place in table, and round up:
wageResults = [	 %	Men		Women	Family1	Family2
%	Permanent
					vH		vW   	vHW		rvHW 	; ...
					sevH	sevW 	sevHW	servHW	; ...
%   Transitory
					uH		uW   	uHW		ruHW 	; ...
					seuH	seuW 	seuHW	seruHW 	; ...
%	Permanent
					gvH		gvW  	gvHW2   gvH2W	; ...
					segvH	segvW   segvHW2 segvH2W	; ...
%   Transitory
					guH		guW  	guHW2   guH2W	; ...
					seguH	seguW  	seguHW2 seguH2W];
wageResults = round(wageResults,3) ;

%   Export results:
xlswrite(strcat(dDir,'/tables/table_3.csv'), wageResults, 1)
clearvars wageResults wages wagefilename* vH vW vHW uH uW uHW gv* gu* rv* ru* sev* seu* seg* ser* seWages se_wages


%%  3.  DELIVER BASELINE RESULTS (TABLES 4 & 5)
%       Equally Weighted GMM
%   -----------------------------------------------------------------------

%   First moments of paremeters and standard errors. First column is from
%   Blundell, Pistaferri, Saporta-Eksten (2016):
eta_c_w1  = [ -0.148  prefs_c11(1)        prefs_c12(1)        prefs_c13(1)        prefs_c14(1)        prefs_c15(1)        prefs_c16(1)        prefs_c17(1)        ; % consumption wrt wage1
               0.060  se_prefs_c11(1)     se_prefs_c12(1)     se_prefs_c13(1)     infer_prefs_c14(1)  infer_prefs_c15(1)  infer_prefs_c16(1)  infer_prefs_c17(1)] ;
eta_c_w2  = [ -0.030  prefs_c11(2)        prefs_c12(2)        prefs_c13(2)        prefs_c14(2)        prefs_c15(2)        prefs_c16(2)        prefs_c17(2)        ; % consumption wrt wage2
               0.059  se_prefs_c11(2)     se_prefs_c12(2)     se_prefs_c13(2)     infer_prefs_c14(2)  infer_prefs_c15(2)  infer_prefs_c16(2)  infer_prefs_c17(2)] ;   
eta_h1_w1 = [  0.594  prefs_c11(3)        prefs_c12(3)        prefs_c13(3)        prefs_c14(3)        prefs_c15(3)        prefs_c16(3)        prefs_c17(3)        ; % hours1 wrt wage1
               0.155  se_prefs_c11(3)     se_prefs_c12(3)     se_prefs_c13(3)     infer_prefs_c14(3)  infer_prefs_c15(3)  infer_prefs_c16(3)  infer_prefs_c17(3)] ;  
eta_h1_w2 = [  0.104  prefs_c11(4)        prefs_c12(4)        prefs_c13(4)        prefs_c14(4)        prefs_c15(4)        NaN                 NaN                 ; % hours1 wrt wage2
               0.053  se_prefs_c11(4)     se_prefs_c12(4)     se_prefs_c13(4)     infer_prefs_c14(4)  infer_prefs_c15(4)  NaN                 NaN]                ;   
eta_h2_w1 = [  0.212  prefs_c11(5)        prefs_c12(5)        prefs_c13(5)        prefs_c14(5)        prefs_c15(5)        NaN                 NaN                 ; % hours2 wrt wage1
               0.108  se_prefs_c11(5)     se_prefs_c12(5)     se_prefs_c13(5)     infer_prefs_c14(5)  infer_prefs_c15(5)  NaN                 NaN]                ;   
eta_h2_w2 = [  0.871  prefs_c11(6)        prefs_c12(6)        prefs_c13(6)        prefs_c14(6)        prefs_c15(6)        prefs_c16(4)        prefs_c17(4)        ; % hours2 wrt wage2
               0.221  se_prefs_c11(6)     se_prefs_c12(6)     se_prefs_c13(6)     infer_prefs_c14(6)  infer_prefs_c15(6)  infer_prefs_c16(4)  infer_prefs_c17(4)] ;

%   Second own-moments of paremeters and standard errors:
Veta_c_w1  = [ NaN    NaN                 NaN                 NaN                 prefs_c14(7)        prefs_c15(7)        prefs_c16(5)        prefs_c17(5)        ; % consumption wrt wage1
               NaN    NaN                 NaN                 NaN                 infer_prefs_c14(7)  infer_prefs_c15(7)  infer_prefs_c16(5)  infer_prefs_c17(5)] ; 
Veta_c_w2  = [ NaN    NaN                 NaN                 NaN                 prefs_c14(8)        prefs_c15(8)        prefs_c16(6)        prefs_c17(6)        ; % consumption wrt wage2
               NaN    NaN                 NaN                 NaN                 infer_prefs_c14(8)  infer_prefs_c15(8)  infer_prefs_c16(6)  infer_prefs_c17(6)] ; 
Veta_h1_w1 = [ NaN    NaN                 NaN                 NaN                 prefs_c14(9)        prefs_c15(9)        prefs_c16(7)        prefs_c17(7)        ; % hours1 wrt wage1
               NaN    NaN                 NaN                 NaN                 infer_prefs_c14(9)  infer_prefs_c15(9)  infer_prefs_c16(7)  infer_prefs_c17(7)] ; 
Veta_h1_w2 = [ NaN    NaN                 NaN                 NaN                 prefs_c14(10)       prefs_c15(10)       NaN                 NaN                 ; % hours1 wrt wage2
               NaN    NaN                 NaN                 NaN                 infer_prefs_c14(10) infer_prefs_c15(10) NaN                 NaN]                ; 
Veta_h2_w1 = [ NaN    NaN                 NaN                 NaN                 prefs_c14(11)       prefs_c15(11)       NaN                 NaN                 ; % hours2 wrt wage1
               NaN    NaN                 NaN                 NaN                 infer_prefs_c14(11) infer_prefs_c15(11) NaN                 NaN]                ; 
Veta_h2_w2 = [ NaN    NaN                 NaN                 NaN                 prefs_c14(12)       prefs_c15(12)       prefs_c16(8)        prefs_c17(8)        ; % hours2 wrt wage2
               NaN    NaN                 NaN                 NaN                 infer_prefs_c14(12) infer_prefs_c15(12) infer_prefs_c16(8)  infer_prefs_c17(8)] ; 

%   Second cross-moments of paremeters and standard errors:
COVeta_c_w1_c_w2   = [  NaN      NaN      NaN                 NaN                 NaN                 prefs_c15(13)       prefs_c16(9)        prefs_c17(9)        ;
                        NaN      NaN      NaN                 NaN                 NaN                 infer_prefs_c15(13) infer_prefs_c16(9)  infer_prefs_c17(9)] ;                  
COVeta_c_w1_h1_w1  = [  NaN      NaN      NaN                 NaN                 NaN                 prefs_c15(14)       prefs_c16(10)       prefs_c17(10)       ;    
                        NaN      NaN      NaN                 NaN                 NaN                 infer_prefs_c15(14) infer_prefs_c16(10) infer_prefs_c17(10)]; 
COVeta_c_w1_h1_w2  = [  NaN      NaN      NaN                 NaN                 NaN                 prefs_c15(15)       NaN                 NaN                 ;              
                        NaN      NaN      NaN                 NaN                 NaN                 infer_prefs_c15(15) NaN                 NaN]                ;
COVeta_c_w1_h2_w1  = [  NaN      NaN      NaN                 NaN                 NaN                 prefs_c15(16)       NaN                 NaN                 ;              
                        NaN      NaN      NaN                 NaN                 NaN                 infer_prefs_c15(16) NaN                 NaN]                ; 
COVeta_c_w1_h2_w2  = [  NaN      NaN      NaN                 NaN                 NaN                 prefs_c15(17)       prefs_c16(11)       prefs_c17(11)       ;             
                        NaN      NaN      NaN                 NaN                 NaN                 infer_prefs_c15(17) infer_prefs_c16(11) infer_prefs_c17(11)];
COVeta_c_w2_h1_w1  = [  NaN      NaN      NaN                 NaN                 NaN                 prefs_c15(18)       prefs_c16(12)       prefs_c17(12)       ;    
                        NaN      NaN      NaN                 NaN                 NaN                 infer_prefs_c15(18) infer_prefs_c16(12) infer_prefs_c17(12)];
COVeta_c_w2_h1_w2  = [  NaN      NaN      NaN                 NaN                 NaN                 prefs_c15(19)       NaN                 NaN                 ;             
                        NaN      NaN      NaN                 NaN                 NaN                 infer_prefs_c15(19) NaN                 NaN]                ;
COVeta_c_w2_h2_w1  = [  NaN      NaN      NaN                 NaN                 NaN                 prefs_c15(20)       NaN                 NaN                 ;             
                        NaN      NaN      NaN                 NaN                 NaN                 infer_prefs_c15(20) NaN                 NaN]                ;
COVeta_c_w2_h2_w2  = [  NaN      NaN      NaN                 NaN                 NaN                 prefs_c15(21)       prefs_c16(13)       prefs_c17(13)       ;              
                        NaN      NaN      NaN                 NaN                 NaN                 infer_prefs_c15(21) infer_prefs_c16(13) infer_prefs_c17(13)]; 
COVeta_h1_w1_h1_w2 = [  NaN      NaN      NaN                 NaN                 NaN                 prefs_c15(22)       NaN                 NaN                 ;             
                        NaN      NaN      NaN                 NaN                 NaN                 infer_prefs_c15(22) NaN                 NaN]                ;
COVeta_h1_w1_h2_w1 = [  NaN      NaN      NaN                 NaN                 NaN                 prefs_c15(23)       NaN                 NaN                 ;              
                        NaN      NaN      NaN                 NaN                 NaN                 infer_prefs_c15(23) NaN                 NaN]                ; 
COVeta_h1_w1_h2_w2 = [  NaN      NaN      NaN                 NaN                 NaN                 prefs_c15(24)       prefs_c16(14)       prefs_c17(14)       ;            
                        NaN      NaN      NaN                 NaN                 NaN                 infer_prefs_c15(24) infer_prefs_c16(14) infer_prefs_c17(14)]; 
COVeta_h1_w2_h2_w1 = [  NaN      NaN      NaN                 NaN                 prefs_c14(13)       prefs_c15(25)       NaN                 NaN                 ;              
                        NaN      NaN      NaN                 NaN                 infer_prefs_c14(13) infer_prefs_c15(25) NaN                 NaN]                ; 
COVeta_h1_w2_h2_w2 = [  NaN      NaN      NaN                 NaN                 NaN                 prefs_c15(26)       NaN                 NaN                 ;            
                        NaN      NaN      NaN                 NaN                 NaN                 infer_prefs_c15(26) NaN                 NaN]                ; 
COVeta_h2_w1_h2_w2 = [  NaN      NaN      NaN                 NaN                 NaN                 prefs_c15(27)       NaN                 NaN                 ;              
                        NaN      NaN      NaN                 NaN                 NaN                 infer_prefs_c15(27) NaN                 NaN]                ;

%   Place in table, and round up:
param_table1 = [ eta_c_w1    ; ...
                 eta_c_w2    ; ...
                 eta_h1_w1   ; ...
                 eta_h1_w2   ; ...
                 eta_h2_w1   ; ...
                 eta_h2_w2   ; ... 
                 Veta_c_w1   ; ...
                 Veta_c_w2   ; ...
                 Veta_h1_w1  ; ...
                 Veta_h1_w2  ; ...
                 Veta_h2_w1  ; ...
                 Veta_h2_w2 ];                
param_table2 = [ COVeta_c_w1_c_w2   ; ...
                 COVeta_c_w1_h1_w1  ; ...
                 COVeta_c_w1_h1_w2  ; ...
                 COVeta_c_w1_h2_w1  ; ...
                 COVeta_c_w1_h2_w2  ; ...
                 COVeta_c_w2_h1_w1  ; ...
                 COVeta_c_w2_h1_w2  ; ...
                 COVeta_c_w2_h2_w1  ; ...
                 COVeta_c_w2_h2_w2  ; ...
                 COVeta_h1_w1_h1_w2 ; ...
                 COVeta_h1_w1_h2_w1 ; ...
                 COVeta_h1_w1_h2_w2 ; ...
                 COVeta_h1_w2_h2_w1 ; ...
                 COVeta_h1_w2_h2_w2 ; ...
                 COVeta_h2_w1_h2_w2 ];
param_table1 = round(param_table1,3) ;
param_table2 = round(param_table2,3) ;

%   Export results:
xlswrite(strcat(dDir,'/tables/table_4.csv'),param_table1,1)
xlswrite(strcat(dDir,'/tables/table_5.csv'),param_table2,1)


%%  4.  DELIVER ALTERNATIVE RESTRICTIONS FOR PREFERRED SPECIFICATION (TABLE E.1)
%       Equally Weighted GMM
%   -----------------------------------------------------------------------

%   First moments of paremeters and standard errors:
eta_c_w1  = [           rob1(1)         rob2(1)         rob3(1)         rob4(1)        rob5(1)        ; % consumption wrt wage1
                        infer_rob1(1)   infer_rob2(1)   infer_rob3(1)   infer_rob4(1)  infer_rob5(1)] ;
eta_c_w2  = [           rob1(2)         rob2(2)         rob3(2)         rob4(2)        rob5(2)        ; % consumption wrt wage2
                        infer_rob1(2)   infer_rob2(2)   infer_rob3(2)   infer_rob4(2)  infer_rob5(2)] ;   
eta_h1_w1 = [           rob1(3)         rob2(3)         rob3(3)         rob4(3)        rob5(3)        ; % hours1 wrt wage1
                        infer_rob1(3)   infer_rob2(3)   infer_rob3(3)   infer_rob4(3)  infer_rob5(3)] ;  
eta_h2_w2 = [           rob1(4)         rob2(4)         rob3(4)         rob4(4)        rob5(4)        ; % hours2 wrt wage2
                        infer_rob1(4)   infer_rob2(4)   infer_rob3(4)   infer_rob4(4)  infer_rob5(4)] ;

%   Second own-moments of paremeters and standard errors:
Veta_c_w1  = [          rob1(5)         rob2(5)         rob3(5)         rob4(5)        rob5(5)        ; % consumption wrt wage1
                        infer_rob1(5)   infer_rob2(5)   infer_rob3(5)   infer_rob4(5)  infer_rob5(5)] ; 
Veta_c_w2  = [          rob1(6)         rob2(6)         rob3(6)         rob4(6)        rob5(6)        ; % consumption wrt wage2
                        infer_rob1(6)   infer_rob2(6)   infer_rob3(6)   infer_rob4(6)  infer_rob5(6)] ; 
Veta_h1_w1 = [          NaN             rob2(7)         rob3(7)         rob4(7)        rob5(7)        ; % hours1 wrt wage1
                        NaN             infer_rob2(7)   infer_rob3(7)   infer_rob4(7)  infer_rob5(7)] ; 
Veta_h2_w2 = [          NaN             rob2(8)         rob3(8)         rob4(8)        rob5(8)        ; % hours2 wrt wage2
                        NaN             infer_rob2(8)   infer_rob3(8)   infer_rob4(8)  infer_rob5(8)] ; 

%   Second cross-moments of paremeters and standard errors:
COVeta_c_w1_c_w2   = [  rob1(9)         rob2(9)         rob3(9)         rob4(9)        rob5(9)        ;
                        infer_rob1(9)   infer_rob2(9)   infer_rob3(9)   infer_rob4(9)  infer_rob5(9)] ;                  
COVeta_c_w1_h1_w1  = [  NaN             NaN             rob3(10)        rob4(10)       rob5(10)       ;    
                        NaN             NaN             infer_rob3(10)  infer_rob4(10) infer_rob5(10)]; 
COVeta_c_w1_h2_w2  = [  NaN             NaN             rob3(11)        rob4(11)       rob5(11)       ;             
                        NaN             NaN             infer_rob3(11)  infer_rob4(11) infer_rob5(11)];
COVeta_c_w2_h1_w1  = [  NaN             NaN             rob3(12)        rob4(12)       rob5(12)       ;    
                        NaN             NaN             infer_rob3(12)  infer_rob4(12) infer_rob5(12)];
COVeta_c_w2_h2_w2  = [  NaN             NaN             rob3(13)        rob4(13)       rob5(13)       ;              
                        NaN             NaN             infer_rob3(13)  infer_rob4(13) infer_rob5(13)]; 
COVeta_h1_w1_h2_w2 = [  NaN             NaN             rob3(14)        rob4(14)       rob5(14)       ;            
                        NaN             NaN             infer_rob3(14)  infer_rob4(14) infer_rob5(14)]; 

%   Place in table, and round up:
param_table = [ eta_c_w1          ; ...
                eta_c_w2          ; ...
                eta_h1_w1         ; ...
                eta_h2_w2         ; ... 
                Veta_c_w1         ; ...
                Veta_c_w2         ; ...
                Veta_h1_w1        ; ...
                Veta_h2_w2        ; ...                
                COVeta_c_w1_c_w2  ; ...
                COVeta_c_w1_h1_w1 ; ...
                COVeta_c_w1_h2_w2 ; ...
                COVeta_c_w2_h1_w1 ; ...
                COVeta_c_w2_h2_w2 ; ...
                COVeta_h1_w1_h2_w2 ];
param_table = round(param_table,3) ;

%   Export results:
xlswrite(strcat(dDir,'/tables/table_e1.csv'),param_table,1)


%%  5.  DELIVER PREFERENCES NET OF CHORES & AGE OF YOUNGEST CHILD (TABLES E.3-E.4)
%       Equally Weighted GMM
%   -----------------------------------------------------------------------

%   First moments of paremeters and standard errors:
eta_c_w1  = [ prefsa_c11(1)        prefsa_c12(1)       prefsa_c13(1)       prefsa_c14(1)        prefsa_c15(1)        prefsa_c16(1)        prefsa_c17(1)        ; % consumption wrt wage1
              se_prefsa_c11(1)     se_prefsa_c12(1)    se_prefsa_c13(1)    infer_prefsa_c14(1)  infer_prefsa_c15(1)  infer_prefsa_c16(1)  infer_prefsa_c17(1)] ;
eta_c_w2  = [ prefsa_c11(2)        prefsa_c12(2)       prefsa_c13(2)       prefsa_c14(2)        prefsa_c15(2)        prefsa_c16(2)        prefsa_c17(2)        ; % consumption wrt wage2
              se_prefsa_c11(2)     se_prefsa_c12(2)    se_prefsa_c13(2)    infer_prefsa_c14(2)  infer_prefsa_c15(2)  infer_prefsa_c16(2)  infer_prefsa_c17(2)] ;   
eta_h1_w1 = [ prefsa_c11(3)        prefsa_c12(3)       prefsa_c13(3)       prefsa_c14(3)        prefsa_c15(3)        prefsa_c16(3)        prefsa_c17(3)        ; % hours1 wrt wage1
              se_prefsa_c11(3)     se_prefsa_c12(3)    se_prefsa_c13(3)    infer_prefsa_c14(3)  infer_prefsa_c15(3)  infer_prefsa_c16(3)  infer_prefsa_c17(3)] ;  
eta_h1_w2 = [ prefsa_c11(4)        prefsa_c12(4)       prefsa_c13(4)       prefsa_c14(4)        prefsa_c15(4)        NaN                  NaN                  ; % hours1 wrt wage2
              se_prefsa_c11(4)     se_prefsa_c12(4)    se_prefsa_c13(4)    infer_prefsa_c14(4)  infer_prefsa_c15(4)  NaN                  NaN]                 ;   
eta_h2_w1 = [ prefsa_c11(5)        prefsa_c12(5)       prefsa_c13(5)       prefsa_c14(5)        prefsa_c15(5)        NaN                  NaN                  ; % hours2 wrt wage1
              se_prefsa_c11(5)     se_prefsa_c12(5)    se_prefsa_c13(5)    infer_prefsa_c14(5)  infer_prefsa_c15(5)  NaN                  NaN]                 ;   
eta_h2_w2 = [ prefsa_c11(6)        prefsa_c12(6)       prefsa_c13(6)       prefsa_c14(6)        prefsa_c15(6)        prefsa_c16(4)        prefsa_c17(4)        ; % hours2 wrt wage2
              se_prefsa_c11(6)     se_prefsa_c12(6)    se_prefsa_c13(6)    infer_prefsa_c14(6)  infer_prefsa_c15(6)  infer_prefsa_c16(4)  infer_prefsa_c17(4)] ;

%   Second own-moments of paremeters and standard errors:
Veta_c_w1  = [ NaN                 NaN                 NaN                 prefsa_c14(7)        prefsa_c15(7)        prefsa_c16(5)        prefsa_c17(5)        ; % consumption wrt wage1
               NaN                 NaN                 NaN                 infer_prefsa_c14(7)  infer_prefsa_c15(7)  infer_prefsa_c16(5)  infer_prefsa_c17(5)] ; 
Veta_c_w2  = [ NaN                 NaN                 NaN                 prefsa_c14(8)        prefsa_c15(8)        prefsa_c16(6)        prefsa_c17(6)        ; % consumption wrt wage2
               NaN                 NaN                 NaN                 infer_prefsa_c14(8)  infer_prefsa_c15(8)  infer_prefsa_c16(6)  infer_prefsa_c17(6)] ; 
Veta_h1_w1 = [ NaN                 NaN                 NaN                 prefsa_c14(9)        prefsa_c15(9)        prefsa_c16(7)        prefsa_c17(7)        ; % hours1 wrt wage1
               NaN                 NaN                 NaN                 infer_prefsa_c14(9)  infer_prefsa_c15(9)  infer_prefsa_c16(7)  infer_prefsa_c17(7)] ; 
Veta_h1_w2 = [ NaN                 NaN                 NaN                 prefsa_c14(10)       prefsa_c15(10)       NaN                  NaN                  ; % hours1 wrt wage2
               NaN                 NaN                 NaN                 infer_prefsa_c14(10) infer_prefsa_c15(10) NaN                  NaN]                 ; 
Veta_h2_w1 = [ NaN                 NaN                 NaN                 prefsa_c14(11)       prefsa_c15(11)       NaN                  NaN                  ; % hours2 wrt wage1
               NaN                 NaN                 NaN                 infer_prefsa_c14(11) infer_prefsa_c15(11) NaN                  NaN]                 ; 
Veta_h2_w2 = [ NaN                 NaN                 NaN                 prefsa_c14(12)       prefsa_c15(12)       prefsa_c16(8)        prefsa_c17(8)        ; % hours2 wrt wage2
               NaN                 NaN                 NaN                 infer_prefsa_c14(12) infer_prefsa_c15(12) infer_prefsa_c16(8)  infer_prefsa_c17(8)] ; 

%   Second cross-moments of paremeters and standard errors:
COVeta_c_w1_c_w2   = [  NaN        NaN                 NaN                 NaN                  prefsa_c15(13)       prefsa_c16(9)        prefsa_c17(9)        ;
                        NaN        NaN                 NaN                 NaN                  infer_prefsa_c15(13) infer_prefsa_c16(9)  infer_prefsa_c17(9)] ;                  
COVeta_c_w1_h1_w1  = [  NaN        NaN                 NaN                 NaN                  prefsa_c15(14)       prefsa_c16(10)       prefsa_c17(10)       ;    
                        NaN        NaN                 NaN                 NaN                  infer_prefsa_c15(14) infer_prefsa_c16(10) infer_prefsa_c17(10)]; 
COVeta_c_w1_h1_w2  = [  NaN        NaN                 NaN                 NaN                  prefsa_c15(15)       NaN                  NaN                  ;              
                        NaN        NaN                 NaN                 NaN                  infer_prefsa_c15(15) NaN                  NaN]                 ;
COVeta_c_w1_h2_w1  = [  NaN        NaN                 NaN                 NaN                  prefsa_c15(16)       NaN                  NaN                  ;              
                        NaN        NaN                 NaN                 NaN                  infer_prefsa_c15(16) NaN                  NaN]                 ; 
COVeta_c_w1_h2_w2  = [  NaN        NaN                 NaN                 NaN                  prefsa_c15(17)       prefsa_c16(11)       prefsa_c17(11)       ;             
                        NaN        NaN                 NaN                 NaN                  infer_prefsa_c15(17) infer_prefsa_c16(11) infer_prefsa_c17(11)];
COVeta_c_w2_h1_w1  = [  NaN        NaN                 NaN                 NaN                  prefsa_c15(18)       prefsa_c16(12)       prefsa_c17(12)       ;    
                        NaN        NaN                 NaN                 NaN                  infer_prefsa_c15(18) infer_prefsa_c16(12) infer_prefsa_c17(12)];
COVeta_c_w2_h1_w2  = [  NaN        NaN                 NaN                 NaN                  prefsa_c15(19)       NaN                  NaN                  ;             
                        NaN        NaN                 NaN                 NaN                  infer_prefsa_c15(19) NaN                  NaN]                 ;
COVeta_c_w2_h2_w1  = [  NaN        NaN                 NaN                 NaN                  prefsa_c15(20)       NaN                  NaN                  ;             
                        NaN        NaN                 NaN                 NaN                  infer_prefsa_c15(20) NaN                  NaN]                 ;
COVeta_c_w2_h2_w2  = [  NaN        NaN                 NaN                 NaN                  prefsa_c15(21)       prefsa_c16(13)       prefsa_c17(13)       ;              
                        NaN        NaN                 NaN                 NaN                  infer_prefsa_c15(21) infer_prefsa_c16(13) infer_prefsa_c17(13)]; 
COVeta_h1_w1_h1_w2 = [  NaN        NaN                 NaN                 NaN                  prefsa_c15(22)       NaN                  NaN                  ;             
                        NaN        NaN                 NaN                 NaN                  infer_prefsa_c15(22) NaN                  NaN]                 ;
COVeta_h1_w1_h2_w1 = [  NaN        NaN                 NaN                 NaN                  prefsa_c15(23)       NaN                  NaN                  ;              
                        NaN        NaN                 NaN                 NaN                  infer_prefsa_c15(23) NaN                  NaN]                 ; 
COVeta_h1_w1_h2_w2 = [  NaN        NaN                 NaN                 NaN                  prefsa_c15(24)       prefsa_c16(14)       prefsa_c17(14)       ;            
                        NaN        NaN                 NaN                 NaN                  infer_prefsa_c15(24) infer_prefsa_c16(14) infer_prefsa_c17(14)]; 
COVeta_h1_w2_h2_w1 = [  NaN        NaN                 NaN                 prefsa_c14(13)       prefsa_c15(25)       NaN                  NaN                  ;              
                        NaN        NaN                 NaN                 infer_prefsa_c14(13) infer_prefsa_c15(25) NaN                  NaN]                 ; 
COVeta_h1_w2_h2_w2 = [  NaN        NaN                 NaN                 NaN                  prefsa_c15(26)       NaN                  NaN                  ;            
                        NaN        NaN                 NaN                 NaN                  infer_prefsa_c15(26) NaN                  NaN]                 ; 
COVeta_h2_w1_h2_w2 = [  NaN        NaN                 NaN                 NaN                  prefsa_c15(27)       NaN                  NaN                  ;              
                        NaN        NaN                 NaN                 NaN                  infer_prefsa_c15(27) NaN                  NaN]                 ;

%   Place in table, and round up:
param_table1 = [ eta_c_w1    ; ...
                 eta_c_w2    ; ...
                 eta_h1_w1   ; ...
                 eta_h1_w2   ; ...
                 eta_h2_w1   ; ...
                 eta_h2_w2   ; ... 
                 Veta_c_w1   ; ...
                 Veta_c_w2   ; ...
                 Veta_h1_w1  ; ...
                 Veta_h1_w2  ; ...
                 Veta_h2_w1  ; ...
                 Veta_h2_w2 ];                
param_table2 = [ COVeta_c_w1_c_w2   ; ...
                 COVeta_c_w1_h1_w1  ; ...
                 COVeta_c_w1_h1_w2  ; ...
                 COVeta_c_w1_h2_w1  ; ...
                 COVeta_c_w1_h2_w2  ; ...
                 COVeta_c_w2_h1_w1  ; ...
                 COVeta_c_w2_h1_w2  ; ...
                 COVeta_c_w2_h2_w1  ; ...
                 COVeta_c_w2_h2_w2  ; ...
                 COVeta_h1_w1_h1_w2 ; ...
                 COVeta_h1_w1_h2_w1 ; ...
                 COVeta_h1_w1_h2_w2 ; ...
                 COVeta_h1_w2_h2_w1 ; ...
                 COVeta_h1_w2_h2_w2 ; ...
                 COVeta_h2_w1_h2_w2 ];
param_table1 = round(param_table1,3) ;
param_table2 = round(param_table2,3) ;

%   Export results:
xlswrite(strcat(dDir,'/tables/table_e3.csv'),param_table1,1)
xlswrite(strcat(dDir,'/tables/table_e4.csv'),param_table2,1)


%%  6.  DELIVER PREFERENCE RESULTS (TABLES E.5-E.6)
%       Diagonally Weighted GMM
%   -----------------------------------------------------------------------

%   First moments of paremeters and standard errors:
eta_c_w1  = [ NaN  diag_c11(1)        diag_c12(1)        diag_c13(1)        diag_c14(1)        diag_c15(1)        diag_c16(1)        diag_c17(1)        ; % consumption wrt wage1
              NaN  se_diag_c11(1)     se_diag_c12(1)     se_diag_c13(1)     infer_diag_c14(1)  infer_diag_c15(1)  infer_diag_c16(1)  infer_diag_c17(1)] ;
eta_c_w2  = [ NaN  diag_c11(2)        diag_c12(2)        diag_c13(2)        diag_c14(2)        diag_c15(2)        diag_c16(2)        diag_c17(2)        ; % consumption wrt wage2
              NaN  se_diag_c11(2)     se_diag_c12(2)     se_diag_c13(2)     infer_diag_c14(2)  infer_diag_c15(2)  infer_diag_c16(2)  infer_diag_c17(2)] ;   
eta_h1_w1 = [ NaN  diag_c11(3)        diag_c12(3)        diag_c13(3)        diag_c14(3)        diag_c15(3)        diag_c16(3)        diag_c17(3)        ; % hours1 wrt wage1
              NaN  se_diag_c11(3)     se_diag_c12(3)     se_diag_c13(3)     infer_diag_c14(3)  infer_diag_c15(3)  infer_diag_c16(3)  infer_diag_c17(3)] ;  
eta_h1_w2 = [ NaN  diag_c11(4)        diag_c12(4)        diag_c13(4)        diag_c14(4)        diag_c15(4)        NaN                NaN                ; % hours1 wrt wage2
              NaN  se_diag_c11(4)     se_diag_c12(4)     se_diag_c13(4)     infer_diag_c14(4)  infer_diag_c15(4)  NaN                NaN]               ;   
eta_h2_w1 = [ NaN  diag_c11(5)        diag_c12(5)        diag_c13(5)        diag_c14(5)        diag_c15(5)        NaN                NaN                ; % hours2 wrt wage1
              NaN  se_diag_c11(5)     se_diag_c12(5)     se_diag_c13(5)     infer_diag_c14(5)  infer_diag_c15(5)  NaN                NaN]               ;   
eta_h2_w2 = [ NaN  diag_c11(6)        diag_c12(6)        diag_c13(6)        diag_c14(6)        diag_c15(6)        diag_c16(4)        diag_c17(4)        ; % hours2 wrt wage2
              NaN  se_diag_c11(6)     se_diag_c12(6)     se_diag_c13(6)     infer_diag_c14(6)  infer_diag_c15(6)  infer_diag_c16(4)  infer_diag_c17(4)] ;

%   Second own-moments of paremeters and standard errors:
Veta_c_w1  = [ NaN NaN                NaN                NaN                diag_c14(7)        diag_c15(7)        diag_c16(5)        diag_c17(5)        ; % consumption wrt wage1
               NaN NaN                NaN                NaN                infer_diag_c14(7)  infer_diag_c15(7)  infer_diag_c16(5)  infer_diag_c17(5)] ; 
Veta_c_w2  = [ NaN NaN                NaN                NaN                diag_c14(8)        diag_c15(8)        diag_c16(6)        diag_c17(6)        ; % consumption wrt wage2
               NaN NaN                NaN                NaN                infer_diag_c14(8)  infer_diag_c15(8)  infer_diag_c16(6)  infer_diag_c17(6)] ; 
Veta_h1_w1 = [ NaN NaN                NaN                NaN                diag_c14(9)        diag_c15(9)        diag_c16(7)        diag_c17(7)        ; % hours1 wrt wage1
               NaN NaN                NaN                NaN                infer_diag_c14(9)  infer_diag_c15(9)  infer_diag_c16(7)  infer_diag_c17(7)] ; 
Veta_h1_w2 = [ NaN NaN                NaN                NaN                diag_c14(10)       diag_c15(10)       NaN                NaN                ; % hours1 wrt wage2
               NaN NaN                NaN                NaN                infer_diag_c14(10) infer_diag_c15(10) NaN                NaN]               ; 
Veta_h2_w1 = [ NaN NaN                NaN                NaN                diag_c14(11)       diag_c15(11)       NaN                NaN                ; % hours2 wrt wage1
               NaN NaN                NaN                NaN                infer_diag_c14(11) infer_diag_c15(11) NaN                NaN]               ; 
Veta_h2_w2 = [ NaN NaN                NaN                NaN                diag_c14(12)       diag_c15(12)       diag_c16(8)        diag_c17(8)        ; % hours2 wrt wage2
               NaN NaN                NaN                NaN                infer_diag_c14(12) infer_diag_c15(12) infer_diag_c16(8)  infer_diag_c17(8)] ; 

%   Second cross-moments of paremeters and standard errors:
COVeta_c_w1_c_w2   = [  NaN  NaN      NaN                NaN                NaN                diag_c15(13)       diag_c16(9)        diag_c17(9)        ;
                        NaN  NaN      NaN                NaN                NaN                infer_diag_c15(13) infer_diag_c16(9)  infer_diag_c17(9)] ;                  
COVeta_c_w1_h1_w1  = [  NaN  NaN      NaN                NaN                NaN                diag_c15(14)       diag_c16(10)       diag_c17(10)       ;    
                        NaN  NaN      NaN                NaN                NaN                infer_diag_c15(14) infer_diag_c16(10) infer_diag_c17(10)]; 
COVeta_c_w1_h1_w2  = [  NaN  NaN      NaN                NaN                NaN                diag_c15(15)       NaN                NaN                ;              
                        NaN  NaN      NaN                NaN                NaN                infer_diag_c15(15) NaN                NaN]               ;
COVeta_c_w1_h2_w1  = [  NaN  NaN      NaN                NaN                NaN                diag_c15(16)       NaN                NaN                ;              
                        NaN  NaN      NaN                NaN                NaN                infer_diag_c15(16) NaN                NaN]               ; 
COVeta_c_w1_h2_w2  = [  NaN  NaN      NaN                NaN                NaN                diag_c15(17)       diag_c16(11)       diag_c17(11)       ;             
                        NaN  NaN      NaN                NaN                NaN                infer_diag_c15(17) infer_diag_c16(11) infer_diag_c17(11)];
COVeta_c_w2_h1_w1  = [  NaN  NaN      NaN                NaN                NaN                diag_c15(18)       diag_c16(12)       diag_c17(12)       ;    
                        NaN  NaN      NaN                NaN                NaN                infer_diag_c15(18) infer_diag_c16(12) infer_diag_c17(12)];
COVeta_c_w2_h1_w2  = [  NaN  NaN      NaN                NaN                NaN                diag_c15(19)       NaN                NaN                ;             
                        NaN  NaN      NaN                NaN                NaN                infer_diag_c15(19) NaN                NaN]               ;
COVeta_c_w2_h2_w1  = [  NaN  NaN      NaN                NaN                NaN                diag_c15(20)       NaN                NaN                ;             
                        NaN  NaN      NaN                NaN                NaN                infer_diag_c15(20) NaN                NaN]               ;
COVeta_c_w2_h2_w2  = [  NaN  NaN      NaN                NaN                NaN                diag_c15(21)       diag_c16(13)       diag_c17(13)       ;              
                        NaN  NaN      NaN                NaN                NaN                infer_diag_c15(21) infer_diag_c16(13) infer_diag_c17(13)]; 
COVeta_h1_w1_h1_w2 = [  NaN  NaN      NaN                NaN                NaN                diag_c15(22)       NaN                NaN                ;             
                        NaN  NaN      NaN                NaN                NaN                infer_diag_c15(22) NaN                NaN]               ;
COVeta_h1_w1_h2_w1 = [  NaN  NaN      NaN                NaN                NaN                diag_c15(23)       NaN                NaN                ;              
                        NaN  NaN      NaN                NaN                NaN                infer_diag_c15(23) NaN                NaN]               ; 
COVeta_h1_w1_h2_w2 = [  NaN  NaN      NaN                NaN                NaN                diag_c15(24)       diag_c16(14)       diag_c17(14)       ;            
                        NaN  NaN      NaN                NaN                NaN                infer_diag_c15(24) infer_diag_c16(14) infer_diag_c17(14)]; 
COVeta_h1_w2_h2_w1 = [  NaN  NaN      NaN                NaN                diag_c14(13)       diag_c15(25)       NaN                NaN                ;              
                        NaN  NaN      NaN                NaN                infer_diag_c14(13) infer_diag_c15(25) NaN                NaN]               ; 
COVeta_h1_w2_h2_w2 = [  NaN  NaN      NaN                NaN                NaN                diag_c15(26)       NaN                NaN                ;            
                        NaN  NaN      NaN                NaN                NaN                infer_diag_c15(26) NaN                NaN]               ; 
COVeta_h2_w1_h2_w2 = [  NaN  NaN      NaN                NaN                NaN                diag_c15(27)       NaN                NaN                ;              
                        NaN  NaN      NaN                NaN                NaN                infer_diag_c15(27) NaN                NaN]               ;

%   Place in table, and round up:
diag_table1 = [  eta_c_w1    ; ...
                 eta_c_w2    ; ...
                 eta_h1_w1   ; ...
                 eta_h1_w2   ; ...
                 eta_h2_w1   ; ...
                 eta_h2_w2   ; ... 
                 Veta_c_w1   ; ...
                 Veta_c_w2   ; ...
                 Veta_h1_w1  ; ...
                 Veta_h1_w2  ; ...
                 Veta_h2_w1  ; ...
                 Veta_h2_w2 ];                
diag_table2 = [  COVeta_c_w1_c_w2   ; ...
                 COVeta_c_w1_h1_w1  ; ...
                 COVeta_c_w1_h1_w2  ; ...
                 COVeta_c_w1_h2_w1  ; ...
                 COVeta_c_w1_h2_w2  ; ...
                 COVeta_c_w2_h1_w1  ; ...
                 COVeta_c_w2_h1_w2  ; ...
                 COVeta_c_w2_h2_w1  ; ...
                 COVeta_c_w2_h2_w2  ; ...
                 COVeta_h1_w1_h1_w2 ; ...
                 COVeta_h1_w1_h2_w1 ; ...
                 COVeta_h1_w1_h2_w2 ; ...
                 COVeta_h1_w2_h2_w1 ; ...
                 COVeta_h1_w2_h2_w2 ; ...
                 COVeta_h2_w1_h2_w2 ];
diag_table1 = round(diag_table1,3) ;
diag_table2 = round(diag_table2,3) ;

%   Export results:
xlswrite(strcat(dDir,'/tables/table_e5.csv'),diag_table1,1)
xlswrite(strcat(dDir,'/tables/table_e6.csv'),diag_table2,1)


%%  7.  DELIVER ALTERNATIVE RESTRICTIONS FOR PREFERRED SPECIFICATION (TABLE E.7)
%       Diagonally Weighted GMM
%   -----------------------------------------------------------------------

%   First moments of paremeters and standard errors:
eta_c_w1  = [           diagrob1(1)         diagrob2(1)         diagrob3(1)         diagrob4(1)        diagrob5(1)        ; % consumption wrt wage1
                        infer_diagrob1(1)   infer_diagrob2(1)   infer_diagrob3(1)   infer_diagrob4(1)  infer_diagrob5(1)] ;
eta_c_w2  = [           diagrob1(2)         diagrob2(2)         diagrob3(2)         diagrob4(2)        diagrob5(2)        ; % consumption wrt wage2
                        infer_diagrob1(2)   infer_diagrob2(2)   infer_diagrob3(2)   infer_diagrob4(2)  infer_diagrob5(2)] ;   
eta_h1_w1 = [           diagrob1(3)         diagrob2(3)         diagrob3(3)         diagrob4(3)        diagrob5(3)        ; % hours1 wrt wage1
                        infer_diagrob1(3)   infer_diagrob2(3)   infer_diagrob3(3)   infer_diagrob4(3)  infer_diagrob5(3)] ;  
eta_h2_w2 = [           diagrob1(4)         diagrob2(4)         diagrob3(4)         diagrob4(4)        diagrob5(4)        ; % hours2 wrt wage2
                        infer_diagrob1(4)   infer_diagrob2(4)   infer_diagrob3(4)   infer_diagrob4(4)  infer_diagrob5(4)] ;

%   Second own-moments of paremeters and standard errors:
Veta_c_w1  = [          diagrob1(5)         diagrob2(5)         diagrob3(5)         diagrob4(5)        diagrob5(5)        ; % consumption wrt wage1
                        infer_diagrob1(5)   infer_diagrob2(5)   infer_diagrob3(5)   infer_diagrob4(5)  infer_diagrob5(5)] ; 
Veta_c_w2  = [          diagrob1(6)         diagrob2(6)         diagrob3(6)         diagrob4(6)        diagrob5(6)        ; % consumption wrt wage2
                        infer_diagrob1(6)   infer_diagrob2(6)   infer_diagrob3(6)   infer_diagrob4(6)  infer_diagrob5(6)] ; 
Veta_h1_w1 = [          NaN                 diagrob2(7)         diagrob3(7)         diagrob4(7)        diagrob5(7)        ; % hours1 wrt wage1
                        NaN                 infer_diagrob2(7)   infer_diagrob3(7)   infer_diagrob4(7)  infer_diagrob5(7)] ; 
Veta_h2_w2 = [          NaN                 diagrob2(8)         diagrob3(8)         diagrob4(8)        diagrob5(8)        ; % hours2 wrt wage2
                        NaN                 infer_diagrob2(8)   infer_diagrob3(8)   infer_diagrob4(8)  infer_diagrob5(8)] ; 

%   Second cross-moments of paremeters and standard errors:
COVeta_c_w1_c_w2   = [  diagrob1(9)         diagrob2(9)         diagrob3(9)         diagrob4(9)        diagrob5(9)        ;
                        infer_diagrob1(9)   infer_diagrob2(9)   infer_diagrob3(9)   infer_diagrob4(9)  infer_diagrob5(9)] ;                  
COVeta_c_w1_h1_w1  = [  NaN                 NaN                 diagrob3(10)        diagrob4(10)       diagrob5(10)       ;    
                        NaN                 NaN                 infer_diagrob3(10)  infer_diagrob4(10) infer_diagrob5(10)]; 
COVeta_c_w1_h2_w2  = [  NaN                 NaN                 diagrob3(11)        diagrob4(11)       diagrob5(11)       ;             
                        NaN                 NaN                 infer_diagrob3(11)  infer_diagrob4(11) infer_diagrob5(11)];
COVeta_c_w2_h1_w1  = [  NaN                 NaN                 diagrob3(12)        diagrob4(12)       diagrob5(12)       ;    
                        NaN                 NaN                 infer_diagrob3(12)  infer_diagrob4(12) infer_diagrob5(12)];
COVeta_c_w2_h2_w2  = [  NaN                 NaN                 diagrob3(13)        diagrob4(13)       diagrob5(13)       ;              
                        NaN                 NaN                 infer_diagrob3(13)  infer_diagrob4(13) infer_diagrob5(13)]; 
COVeta_h1_w1_h2_w2 = [  NaN                 NaN                 diagrob3(14)        diagrob4(14)       diagrob5(14)       ;            
                        NaN                 NaN                 infer_diagrob3(14)  infer_diagrob4(14) infer_diagrob5(14)]; 

%   Place in table, and round up:
diag_table = [  eta_c_w1          ; ...
                eta_c_w2          ; ...
                eta_h1_w1         ; ...
                eta_h2_w2         ; ... 
                Veta_c_w1         ; ...
                Veta_c_w2         ; ...
                Veta_h1_w1        ; ...
                Veta_h2_w2        ; ...                
                COVeta_c_w1_c_w2  ; ...
                COVeta_c_w1_h1_w1 ; ...
                COVeta_c_w1_h2_w2 ; ...
                COVeta_c_w2_h1_w1 ; ...
                COVeta_c_w2_h2_w2 ; ...
                COVeta_h1_w1_h2_w2 ];
diag_table = round(diag_table,3) ;

%   Export results:
xlswrite(strcat(dDir,'/tables/table_e7.csv'),diag_table,1)


%%  8.  DELIVER SUMMARY STATISTICS FOR pi AND es (TABLE D.3)
%   Get summary statistics for partial insurance parameters.
%   -----------------------------------------------------------------------

%   Request data - read residuals from 1st stage regressions conditional 
%   on average past outcomes:
[mCouple_c1, mInd_c1, mEs_c1, mPi_c1, mErr_c1, mAvg_c1, ~, N_c1]  ...
    = handleData('_Cond1/original_PSID_c1.csv', ...
                 '_Cond1/original_PSID_me_c1.csv', ...
                 '_Cond1/avgrat_original_PSID_c1.csv',[]) ;

%   Obtain pi and es matrices in years 2001-2011:
es = mEs_c1(2:T,:) ;
pi = mPi_c1(2:T,:) ;

%   Calculate summary statistics:
sumstatses = [ mean(es(es~=0)) median(es(es~=0)) std(es(es~=0)) min(es(es~=0)) max(es(es~=0)) ] ;
sumstatspi = [ mean(pi(pi~=0)) median(pi(pi~=0)) std(pi(pi~=0)) min(pi(pi~=0)) max(pi(pi~=0)) ] ;
sumstats = [ sumstatses sumstatspi ] ;

%   Round up and deliver:
xlswrite(strcat(dDir,'/tables/table_d3.csv'),sumstats,1)

%   Clear variables, change directory:
clearvars sumstats* es pi param_table* eta_* Veta* COVeta* prefs_c* rob* se_prefs* prefsa_c* infer* diag*