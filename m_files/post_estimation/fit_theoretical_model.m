function [matched,unmatchd] = fit_theoretical_model(vParams,vWages,specification,start_j)
%{  
    This function constructs the theoretical moments implied by a given
    vector of parameter estimates.

    Input 'specification' takes on the following values:
        =1 for BPS          (BPS model)
        =2 for TRANS        (Transmission of transitory shocks only)
        =3 for TRANS3       (+Third moments)
        =4 for VAR          (+Marginal heterogeneity)
        =5 for COV          (+Joint heterogeneity, i.e. full heterogeneity)
        =6 for PREFERRED    (for preferred model specification)

    Alexandros Theloudis
    -----------------------------------------------------------------------
%}

%   Initial statements:
global T ;


%%  1.  INITIALIZE PARAMETERS
%   Initialize vectors of parameters.
%   -----------------------------------------------------------------------

%   Vector of structural parameters:

%   First moments of parameters:
if specification~=6
    eta_c_w1            = vParams(1)  ;             % consumption wrt wage1
    eta_c_w2            = vParams(2)  ;             % consumption wrt wage2
    eta_h1_w1           = vParams(3)  ;             % hours1 wrt wage1
    eta_h1_w2           = vParams(4)  ;             % hours1 wrt wage2
    eta_h2_w1           = vParams(5)  ;             % hours2 wrt wage1
    eta_h2_w2           = vParams(6)  ;             % hours2 wrt wage2
else
    eta_c_w1            = vParams(1)  ;             % consumption wrt wage1
    eta_c_w2            = vParams(2)  ;             % consumption wrt wage2
    eta_h1_w1           = vParams(3)  ;             % hours1 wrt wage1
    eta_h1_w2           = 0.0         ;             % hours1 wrt wage2
    eta_h2_w1           = 0.0         ;             % hours2 wrt wage1
    eta_h2_w2           = vParams(4)  ;             % hours2 wrt wage2
end

%   Second moments of parameters - variances:
if specification<4
    Veta_c_w1           = 0.0 ;                     % consumption wrt wage1
    Veta_c_w2           = 0.0 ;                     % consumption wrt wage2
    Veta_h1_w1          = 0.0 ;                     % hours1 wrt wage1
    Veta_h1_w2          = 0.0 ;                     % hours1 wrt wage2
    Veta_h2_w1          = 0.0 ;                     % hours2 wrt wage1
    Veta_h2_w2          = 0.0 ;                     % hours2 wrt wage2
elseif specification==4 || specification==5
    Veta_c_w1           = vParams(7)  ;             % consumption wrt wage1
    Veta_c_w2           = vParams(8)  ;             % consumption wrt wage2
    Veta_h1_w1          = vParams(9)  ;             % hours1 wrt wage1
    Veta_h1_w2          = vParams(10) ;             % hours1 wrt wage2
    Veta_h2_w1          = vParams(11) ;             % hours2 wrt wage1
    Veta_h2_w2          = vParams(12) ;             % hours2 wrt wage2
else
    Veta_c_w1           = vParams(5)  ;             % consumption wrt wage1
    Veta_c_w2           = vParams(6)  ;             % consumption wrt wage2
    Veta_h1_w1          = vParams(7)  ;             % hours1 wrt wage1
    Veta_h1_w2          = 0.0         ;             % hours1 wrt wage2
    Veta_h2_w1          = 0.0         ;             % hours2 wrt wage1
    Veta_h2_w2          = vParams(8)  ;             % hours2 wrt wage2
end

%   Second moments of parameters - variances:
if specification<4
    COVeta_c_w1_c_w2    = 0.0 ;                     % consumption wrt wage1 ~ consumption wrt wage2
    COVeta_c_w1_h1_w1   = 0.0 ;                     % consumption wrt wage1 ~ hours1 wrt wage1
    COVeta_c_w1_h1_w2   = 0.0 ;                     % consumption wrt wage1 ~ hours1 wrt wage2
    COVeta_c_w1_h2_w1   = 0.0 ;                     % consumption wrt wage1 ~ hours2 wrt wage1
    COVeta_c_w1_h2_w2   = 0.0 ;                     % consumption wrt wage1 ~ hours2 wrt wage2
    COVeta_c_w2_h1_w1   = 0.0 ;                     % consumption wrt wage2 ~ hours1 wrt wage1
    COVeta_c_w2_h1_w2   = 0.0 ;                     % consumption wrt wage2 ~ hours1 wrt wage2
    COVeta_c_w2_h2_w1   = 0.0 ;                     % consumption wrt wage2 ~ hours2 wrt wage1
    COVeta_c_w2_h2_w2   = 0.0 ;                     % consumption wrt wage2 ~ hours2 wrt wage2
    COVeta_h1_w1_h1_w2  = 0.0 ;                     % hours1 wrt wage1 ~ hours1 wrt wage2
    COVeta_h1_w1_h2_w1  = 0.0 ;                     % hours1 wrt wage1 ~ hours2 wrt wage1
    COVeta_h1_w1_h2_w2  = 0.0 ;                     % hours1 wrt wage1 ~ hours2 wrt wage2
    COVeta_h1_w2_h2_w1  = 0.0 ;                     % hours1 wrt wage2 ~ hours2 wrt wage1
    COVeta_h1_w2_h2_w2  = 0.0 ;                     % hours1 wrt wage2 ~ hours2 wrt wage2
    COVeta_h2_w1_h2_w2  = 0.0 ;                     % hours2 wrt wage1 ~ hours2 wrt wage2 
elseif specification==4
    COVeta_c_w1_c_w2    = 0.0 ;                     % consumption wrt wage1 ~ consumption wrt wage2
    COVeta_c_w1_h1_w1   = 0.0 ;                     % consumption wrt wage1 ~ hours1 wrt wage1
    COVeta_c_w1_h1_w2   = 0.0 ;                     % consumption wrt wage1 ~ hours1 wrt wage2
    COVeta_c_w1_h2_w1   = 0.0 ;                     % consumption wrt wage1 ~ hours2 wrt wage1
    COVeta_c_w1_h2_w2   = 0.0 ;                     % consumption wrt wage1 ~ hours2 wrt wage2
    COVeta_c_w2_h1_w1   = 0.0 ;                     % consumption wrt wage2 ~ hours1 wrt wage1
    COVeta_c_w2_h1_w2   = 0.0 ;                     % consumption wrt wage2 ~ hours1 wrt wage2
    COVeta_c_w2_h2_w1   = 0.0 ;                     % consumption wrt wage2 ~ hours2 wrt wage1
    COVeta_c_w2_h2_w2   = 0.0 ;                     % consumption wrt wage2 ~ hours2 wrt wage2
    COVeta_h1_w1_h1_w2  = 0.0 ;                     % hours1 wrt wage1 ~ hours1 wrt wage2
    COVeta_h1_w1_h2_w1  = 0.0 ;                     % hours1 wrt wage1 ~ hours2 wrt wage1
    COVeta_h1_w1_h2_w2  = 0.0 ;                     % hours1 wrt wage1 ~ hours2 wrt wage2
    COVeta_h1_w2_h2_w1  = vParams(13) ;             % hours1 wrt wage2 ~ hours2 wrt wage1
    COVeta_h1_w2_h2_w2  = 0.0 ;                     % hours1 wrt wage2 ~ hours2 wrt wage2
    COVeta_h2_w1_h2_w2  = 0.0 ;                     % hours2 wrt wage1 ~ hours2 wrt wage2 
elseif specification==5
    COVeta_c_w1_c_w2    = vParams(13) ;             % consumption wrt wage1 ~ consumption wrt wage2
    COVeta_c_w1_h1_w1   = vParams(14) ;             % consumption wrt wage1 ~ hours1 wrt wage1
    COVeta_c_w1_h1_w2   = vParams(15) ;             % consumption wrt wage1 ~ hours1 wrt wage2
    COVeta_c_w1_h2_w1   = vParams(16) ;             % consumption wrt wage1 ~ hours2 wrt wage1
    COVeta_c_w1_h2_w2   = vParams(17) ;             % consumption wrt wage1 ~ hours2 wrt wage2
    COVeta_c_w2_h1_w1   = vParams(18) ;             % consumption wrt wage2 ~ hours1 wrt wage1
    COVeta_c_w2_h1_w2   = vParams(19) ;             % consumption wrt wage2 ~ hours1 wrt wage2
    COVeta_c_w2_h2_w1   = vParams(20) ;             % consumption wrt wage2 ~ hours2 wrt wage1
    COVeta_c_w2_h2_w2   = vParams(21) ;             % consumption wrt wage2 ~ hours2 wrt wage2
    COVeta_h1_w1_h1_w2  = vParams(22) ;             % hours1 wrt wage1 ~ hours1 wrt wage2
    COVeta_h1_w1_h2_w1  = vParams(23) ;             % hours1 wrt wage1 ~ hours2 wrt wage1
    COVeta_h1_w1_h2_w2  = vParams(24) ;             % hours1 wrt wage1 ~ hours2 wrt wage2
    COVeta_h1_w2_h2_w1  = vParams(25) ;             % hours1 wrt wage2 ~ hours2 wrt wage1
    COVeta_h1_w2_h2_w2  = vParams(26) ;             % hours1 wrt wage2 ~ hours2 wrt wage2
    COVeta_h2_w1_h2_w2  = vParams(27) ;             % hours2 wrt wage1 ~ hours2 wrt wage2 
else
    COVeta_c_w1_c_w2    = vParams(9) ;              % consumption wrt wage1 ~ consumption wrt wage2
    COVeta_c_w1_h1_w1   = vParams(10);              % consumption wrt wage1 ~ hours1 wrt wage1
    COVeta_c_w1_h1_w2   = 0.0 ;                     % consumption wrt wage1 ~ hours1 wrt wage2
    COVeta_c_w1_h2_w1   = 0.0 ;                     % consumption wrt wage1 ~ hours2 wrt wage1
    COVeta_c_w1_h2_w2   = vParams(11);              % consumption wrt wage1 ~ hours2 wrt wage2
    COVeta_c_w2_h1_w1   = vParams(12);              % consumption wrt wage2 ~ hours1 wrt wage1
    COVeta_c_w2_h1_w2   = 0.0 ;                     % consumption wrt wage2 ~ hours1 wrt wage2
    COVeta_c_w2_h2_w1   = 0.0 ;                     % consumption wrt wage2 ~ hours2 wrt wage1
    COVeta_c_w2_h2_w2   = vParams(13);              % consumption wrt wage2 ~ hours2 wrt wage2
    COVeta_h1_w1_h1_w2  = 0.0 ;                     % hours1 wrt wage1 ~ hours1 wrt wage2
    COVeta_h1_w1_h2_w1  = 0.0 ;                     % hours1 wrt wage1 ~ hours2 wrt wage1
    COVeta_h1_w1_h2_w2  = vParams(14);              % hours1 wrt wage1 ~ hours2 wrt wage2
    COVeta_h1_w2_h2_w1  = 0.0 ;                     % hours1 wrt wage2 ~ hours2 wrt wage1
    COVeta_h1_w2_h2_w2  = 0.0 ;                     % hours1 wrt wage2 ~ hours2 wrt wage2
    COVeta_h2_w1_h2_w2  = 0.0 ;                     % hours2 wrt wage1 ~ hours2 wrt wage2 
end

%   Vector of wage parameters:
vH      = vWages(1:5)   ;   % variance:    permanent shock HD
uH      = vWages(6:11)  ;   % variance:    transitory shock HD
vW      = vWages(12:16) ;   % variance:    permanent shock WF
uW      = vWages(17:22) ;   % variance:    transitory shock WF
vHW     = vWages(23:27) ;   % covariance:  permanent shocks
uHW     = vWages(28:33) ;   % covariance:  transitory shocks

gvH     = vWages(45:49) ; % skewness:    permanent shock HD
guH     = vWages(50:55) ; % skewness:    transitory shock HD
gvW     = vWages(56:60) ; % skewness:    permanent shock WF
guW     = vWages(61:66) ; % skewness:    transitory shock WF
gvH2W   = vWages(67:71) ; % third cross moment: E[vH^2 vW]
guH2W   = vWages(72:77) ; % third cross moment: E[uH^2 uW]
gvHW2   = vWages(78:82) ; % third cross moment: E[vH vW^2]
guHW2   = vWages(83:88) ; % third cross moment: E[uH uW^2]


%%  2.  INITIALIZE MOMENTS
%   Initialize vectors of moments.
%   -----------------------------------------------------------------------

%   Wages second moments:
%   matrix 11: E[DwH DwH]
mom_wHwH    = zeros(T,1) ;     
mom_wHwH_a  = zeros(T,1) ;
%   matrix 13: E[DwH DwW] 
mom_wHwW    = zeros(T,1) ;
mom_wHwW_a  = zeros(T,1) ;
mom_wHwW_b  = zeros(T,1) ;
%   matrix 33: E[DwW DwW]   
mom_wWwW    = zeros(T,1) ;
mom_wWwW_a  = zeros(T,1) ;

%   Wages third moments:
%   matrix 12: E[DwH DwH2]
mom_wHwH2   = zeros(T,1) ;     
mom_wHwH2_a = zeros(T,1) ;
mom_wHwH2_b = zeros(T,1) ;
%   matrix 23: E[DwH2 DwW]
mom_wH2wW   = zeros(T,1) ;     
mom_wH2wW_a = zeros(T,1) ;
mom_wH2wW_b = zeros(T,1) ;
%   matrix 14: E[DwH DwW2]
mom_wHwW2   = zeros(T,1) ;     
mom_wHwW2_a = zeros(T,1) ;
mom_wHwW2_b = zeros(T,1) ;
%   matrix 34: E[DwW DwW2]
mom_wWwW2   = zeros(T,1) ;
mom_wWwW2_a = zeros(T,1) ;
mom_wWwW2_b = zeros(T,1) ;
%   matrix X.31: E[DwW DwH DwH']
mom_wWwHwHt   = zeros(T,1) ;
mom_wWwHwHt_b = zeros(T,1) ;
%   matrix X.13: E[DwH DwW DwW']
mom_wHwWwWt   = zeros(T,1) ;
mom_wHwWwWt_b = zeros(T,1) ;

%   Wage-earnings/consumption second moments:
%   matrix 15: E[DwH DyH]      
mom_wHyH_a = NaN(T,1) ;
mom_wHyH_b = NaN(T,1) ;
%   matrix 35: E[DwW DyH]
mom_wWyH_a = NaN(T,1) ;
mom_wWyH_b = NaN(T,1) ;
%   matrix 17: E[DwH DyW]
mom_wHyW_a = NaN(T,1) ;
mom_wHyW_b = NaN(T,1) ;
%   matrix 37: E[DwW DyW]       
mom_wWyW_a = NaN(T,1) ; 
mom_wWyW_b = NaN(T,1) ; 
%   matrix 19: E[DwH Dc]
mom_wHc_a  = NaN(T,1) ;
mom_wHc_b  = NaN(T,1) ;
%   matrix 39: E[DwW Dc] 
mom_wWc_a  = NaN(T,1) ;
mom_wWc_b  = NaN(T,1) ; 

%   Earnings & consumption second moments:
%   matrix 55: E[DyH DyH]
mom_yHyH_a  = NaN(T,1) ;
%   matrix 57: E[DyH DyW]
mom_yHyW_a  = NaN(T,1) ;
mom_yHyW_b  = NaN(T,1) ;
%   matrix 77: E[DyW DyW]  
mom_yWyW_a  = NaN(T,1) ;
%   matrix 59: E[DyH Dc] 	
mom_yHc_a  = NaN(T,1) ;
mom_yHc_b  = NaN(T,1) ;
%   matrix 79: E[DyW Dc]   
mom_yWc_a  = NaN(T,1) ;
mom_yWc_b  = NaN(T,1) ;
%   matrix 99: E[Dc Dc]	
mom_cc_a   = NaN(T,1) ;

%   Wage-earnings/consumption third moments:
%   matrix 25: E[DwH2 DyH]      
mom_wH2yH_a = NaN(T,1) ;
mom_wH2yH_b = NaN(T,1) ;
%   matrix 45: E[DwW2 DyH]
mom_wW2yH_a = NaN(T,1) ;
mom_wW2yH_b = NaN(T,1) ;
%   matrix 27: E[DwH2 DyW]
mom_wH2yW_a = NaN(T,1) ;
mom_wH2yW_b = NaN(T,1) ;
%   matrix 47: E[DwW2 DyW]       
mom_wW2yW_a = NaN(T,1) ; 
mom_wW2yW_b = NaN(T,1) ; 
%   matrix 29: E[DwH2 Dc]
mom_wH2c_a  = NaN(T,1) ;
mom_wH2c_b  = NaN(T,1) ;
%   matrix 49: E[DwW2 Dc] 
mom_wW2c_a  = NaN(T,1) ;
mom_wW2c_b  = NaN(T,1) ;
%   matrix 16: E[DwH DyH2]      
mom_wHyH2_a = NaN(T,1) ;
mom_wHyH2_b = NaN(T,1) ;
%   matrix 36: E[DwW DyH2]
mom_wWyH2_a = NaN(T,1) ;
mom_wWyH2_b = NaN(T,1) ;
%   matrix 18: E[DwH DyW2]
mom_wHyW2_a = NaN(T,1) ;
mom_wHyW2_b = NaN(T,1) ;
%   matrix 38: E[DwW DyW2]       
mom_wWyW2_a = NaN(T,1) ; 
mom_wWyW2_b = NaN(T,1) ; 
%   matrix 1.10: E[DwH Dc2]
mom_wHc2_a  = NaN(T,1) ;
mom_wHc2_b  = NaN(T,1) ;
%   matrix 3.10: E[DwW Dc2] 
mom_wWc2_a  = NaN(T,1) ;
mom_wWc2_b  = NaN(T,1) ;
%   matrix 1.11: E[DwH DyH DyW]
mom_wHyHyW_a = NaN(T,1) ;
mom_wHyHyW_b = NaN(T,1) ;
%   matrix 3.11: E[DwW DyH DyW]       
mom_wWyHyW_a = NaN(T,1) ; 
mom_wWyHyW_b = NaN(T,1) ; 
%   matrix 1.12: E[DwH DyH Dc]
mom_wHyHc_a  = NaN(T,1) ;
mom_wHyHc_b  = NaN(T,1) ;
%   matrix 3.12: E[DwW DyH Dc] 
mom_wWyHc_a  = NaN(T,1) ;
mom_wWyHc_b  = NaN(T,1) ;
%   matrix 1.13: E[DwH DyW Dc]
mom_wHyWc_a  = NaN(T,1) ;
mom_wHyWc_b  = NaN(T,1) ;
%   matrix 3.13: E[DwW DyW Dc] 
mom_wWyWc_a  = NaN(T,1) ;
mom_wWyWc_b  = NaN(T,1) ;

%   Vectors to hold additional not-targeted moments:
%   matrix X15: E[DwH DyH DyH']      
mom_wHyHyHt   = NaN(T,1) ;
mom_wHyHyHt_b = NaN(T,1) ;
%   matrix X35: E[DwW DyH DyH']
mom_wWyHyHt   = NaN(T,1) ;
mom_wWyHyHt_b = NaN(T,1) ;
%   matrix X17: E[DwH DyW DyW']
mom_wHyWyWt   = NaN(T,1) ;
mom_wHyWyWt_b = NaN(T,1) ;
%   matrix X37: E[DwW DyW DyW']       
mom_wWyWyWt   = NaN(T,1) ; 
mom_wWyWyWt_b = NaN(T,1) ; 
%   matrix X19: E[DwH Dc Dc']
mom_wHcct     = NaN(T,1) ;
mom_wHcct_b   = NaN(T,1) ;
%   matrix X39: E[DwW Dc Dc'] 
mom_wWcct     = NaN(T,1) ;
mom_wWcct_b   = NaN(T,1) ;
%   matrix XA1.11: E[DwH DyH DyW']
mom_wHyHyWt   = NaN(T,1) ;
mom_wHyHyWt_b = NaN(T,1) ;
%   matrix XA3.11: E[DwW DyH DyW']       
mom_wWyHyWt   = NaN(T,1) ; 
mom_wWyHyWt_b = NaN(T,1) ; 
%   matrix XB1.11: E[DwH DyH' DyW]
mom_wHyHtyW   = NaN(T,1) ;
mom_wHyHtyW_b = NaN(T,1) ;
%   matrix XB3.11: E[DwW DyH' DyW]       
mom_wWyHtyW   = NaN(T,1) ; 
mom_wWyHtyW_b = NaN(T,1) ;
%   matrix XA1.12: E[DwH DyH Dc']
mom_wHyHct    = NaN(T,1) ;
mom_wHyHct_b  = NaN(T,1) ;
%   matrix XA3.12: E[DwW DyH Dc'] 
mom_wWyHct    = NaN(T,1) ;
mom_wWyHct_b  = NaN(T,1) ;
%   matrix XB1.12: E[DwH DyH' Dc]
mom_wHyHtc    = NaN(T,1) ;
mom_wHyHtc_b  = NaN(T,1) ;
%   matrix XB3.12: E[DwW DyH' Dc] 
mom_wWyHtc    = NaN(T,1) ;
mom_wWyHtc_b  = NaN(T,1) ;
%   matrix XA1.13: E[DwH DyW Dc']
mom_wHyWct    = NaN(T,1) ;
mom_wHyWct_b  = NaN(T,1) ;
%   matrix XA3.13: E[DwW DyW Dc'] 
mom_wWyWct    = NaN(T,1) ;
mom_wWyWct_b  = NaN(T,1) ;
%   matrix XB1.13: E[DwH DyW' Dc]
mom_wHyWtc    = NaN(T,1) ;
mom_wHyWtc_b  = NaN(T,1) ;
%   matrix XB3.13: E[DwW DyW' Dc] 
mom_wWyWtc    = NaN(T,1) ;
mom_wWyWtc_b  = NaN(T,1) ; 


%%  3.  CONSTRUCT THEORETICAL MOMENTS
%   Construct vector of moments E(model_moment_i)
%   -----------------------------------------------------------------------

%   Matrix 11: E[DwH DwH]   
%   -----------------------------------------------------------------------

%   Variances 2001-2009:
j = 2 ;
while j <= T-1  
    mom_wHwH(j) = vH(j-1) + uH(j) + uH(j-1) ;
    j = j + 1 ;
end 
    
%   Intertemporal covariances:
j = 2 ;
while j <= T
    mom_wHwH_a(j) = -uH(j-1) ;
    j = j + 1 ;
end

%   Matrix 13: E[DwH DwW]   
%   -----------------------------------------------------------------------

%   Auto-covariances 2001-2009:
j = 2 ;
while j <= T-1
	mom_wHwW(j) = vHW(j-1) + uHW(j) + uHW(j-1) ;
	j = j + 1 ;
end
    
%   Intertemporal covariances:
j = 2 ;
while j <= T 
    mom_wHwW_a(j) = -uHW(j-1) ;
	j = j + 1 ;
end

j = 2 ;
while j <= T 
	mom_wHwW_b(j) = -uHW(j-1) ; 
	j = j + 1 ;
end

%   Matrix 33: E[DwW DwW]   
%   -----------------------------------------------------------------------

%   Variances 2001-2009:
j = 2 ;
while j <= T-1
    mom_wWwW(j) = vW(j-1) + uW(j) + uW(j-1) ;
    j = j + 1 ;
end 
    
%   Intertemporal covariances:
j = 2 ;
while j <= T
    mom_wWwW_a(j) = -uW(j-1) ;
    j = j + 1 ;
end

%   Matrix 12: E[DwH DwH2]   
%   -----------------------------------------------------------------------

%   Variances 2001-2009:
j = 2 ;
while j <= T-1  
    mom_wHwH2(j) = gvH(j-1) + guH(j) - guH(j-1) ;
    j = j + 1 ;
end 
    
%   Intertemporal covariances:
j = 2 ;
while j <= T 
    mom_wHwH2_a(j) = guH(j-1) ;
	j = j + 1 ;
end

j = 2 ;
while j <= T 
	mom_wHwH2_b(j) = -guH(j-1) ; 
	j = j + 1 ;
end

%   Matrix 23: E[DwH2 DwW]   
%   -----------------------------------------------------------------------

%   Variances 2001-2009:
j = 2 ;
while j <= T-1  
    mom_wH2wW(j) = gvH2W(j-1) + guH2W(j) - guH2W(j-1) ;
    j = j + 1 ;
end 
    
%   Intertemporal covariances:
j = 2 ;
while j <= T 
    mom_wH2wW_a(j) = -guH2W(j-1) ;
	j = j + 1 ;
end

j = 2 ;
while j <= T 
	mom_wH2wW_b(j) = guH2W(j-1) ; 
	j = j + 1 ;
end

%   Matrix 14: E[DwH DwW2]   
%   -----------------------------------------------------------------------

%   Variances 2001-2009:
j = 2 ;
while j <= T-1  
    mom_wHwW2(j) = gvHW2(j-1) + guHW2(j) - guHW2(j-1) ;
    j = j + 1 ;
end 

%   Intertemporal covariances:
j = 2 ;
while j <= T 
    mom_wHwW2_a(j) = guHW2(j-1) ;
	j = j + 1 ;
end

j = 2 ;
while j <= T 
	mom_wHwW2_b(j) = -guHW2(j-1) ; 
	j = j + 1 ;
end

%   Matrix 34: E[DwW DwW2]
%   -----------------------------------------------------------------------

%   Variances 2001-2009:
j = 2 ;
while j <= T-1  
    mom_wWwW2(j) = gvW(j-1) + guW(j) - guW(j-1) ;
    j = j + 1 ;
end 
    
%   Intertemporal covariances:
j = 2 ;
while j <= T 
    mom_wWwW2_a(j) = guW(j-1) ;
	j = j + 1 ;
end

j = 2 ;
while j <= T 
	mom_wWwW2_b(j) = -guW(j-1) ; 
	j = j + 1 ;
end

%   Matrix X.31: E[DwW DwH DwH']
%   -----------------------------------------------------------------------

%   Intertemporal covariances 1999-2011:
j = 2 ;
while j <= T 
    mom_wWwHwHt(j) = -guH2W(j-1) ;
	j = j + 1 ;
end

j = 2 ;
while j <= T 
	mom_wWwHwHt_b(j) = guH2W(j-1) ;
	j = j + 1 ;
end

%   Matrix X.13: E[DwH DwW DwW']
%   -----------------------------------------------------------------------
    
%   Intertemporal covariances 1999-2011:
j = 2 ;
while j <= T 
    mom_wHwWwWt(j) = -guHW2(j-1) ;
	j = j + 1 ;
end

j = 2 ;
while j <= T 
	mom_wHwWwWt_b(j) = guHW2(j-1) ;
	j = j + 1 ;
end

%   Matrix 15: E[DwH DyH]   
%   -----------------------------------------------------------------------

%   Intertemporal covariances:
j = 2 ;
while j <= T 
	mom_wHyH_a(j) = -(1+eta_h1_w1) * uH(j-1) -eta_h1_w2 * uHW(j-1) ;
	j = j + 1 ;
end

j = start_j ;
while j <= T 
    mom_wHyH_b(j) = -(1+eta_h1_w1) * uH(j-1) -eta_h1_w2 * uHW(j-1) ;
	j = j + 1 ;
end

%   Matrix 35: E[DwW DyH]   
%   -----------------------------------------------------------------------

%   Intertemporal co-variances:
j = 2 ;
while j <= T 
	mom_wWyH_a(j) = -(1+eta_h1_w1) * uHW(j-1) -eta_h1_w2 * uW(j-1) ;
	j = j + 1 ;
end

j = start_j ;
while j <= T
    mom_wWyH_b(j) = -(1+eta_h1_w1) * uHW(j-1) -eta_h1_w2 * uW(j-1) ;
	j = j + 1 ;
end

%   Matrix 17: E[DwH DyW]   
%   -----------------------------------------------------------------------

%   Intertemporal co-variances:
j = 2 ;
while j <= T 
	mom_wHyW_a(j) = -eta_h2_w1 * uH(j-1) -(1+eta_h2_w2) * uHW(j-1) ;
	j = j + 1 ;
end

j = start_j ;
while j <= T 
	mom_wHyW_b(j) = -eta_h2_w1 * uH(j-1) -(1+eta_h2_w2) * uHW(j-1) ;
	j = j + 1 ;
end

%   Matrix 37: E[DwW DyW]   
%   -----------------------------------------------------------------------

%   Intertemporal co-variances:
j = 2 ;
while j <= T 
	mom_wWyW_a(j) = -eta_h2_w1 * uHW(j-1) -(1+eta_h2_w2) * uW(j-1) ;
	j = j + 1 ;
end

j = start_j ;
while j <= T 
	mom_wWyW_b(j) = -eta_h2_w1 * uHW(j-1) -(1+eta_h2_w2) * uW(j-1) ;
	j = j + 1 ;
end

%   Matrix 19: E[DwH Dc]   
%   -----------------------------------------------------------------------

%   Intertemporal co-variances:
j = 2 ;
while j <= T 
	mom_wHc_a(j) = -eta_c_w1 * uH(j-1) -eta_c_w2 * uHW(j-1) ;
	j = j + 1 ;
end

j = 3 ;
while j <= T
	mom_wHc_b(j) = -eta_c_w1 * uH(j-1) -eta_c_w2 * uHW(j-1) ;
	j = j + 1 ;
end

%   Matrix 39: E[DwW Dc]   
%   -----------------------------------------------------------------------

%   Intertemporal co-variances:
j = 2 ;
while j <= T 
	mom_wWc_a(j) = -eta_c_w1 * uHW(j-1) -eta_c_w2 * uW(j-1) ;
	j = j + 1 ;
end

j = 3 ;
while j <= T
	mom_wWc_b(j) = -eta_c_w1 * uHW(j-1) -eta_c_w2 * uW(j-1) ;
	j = j + 1 ;
end

%   Matrix 25: E[DwH2 DyH]
%   -----------------------------------------------------------------------

%   Intertemporal covariances:
j = 2 ;
while j <= T 
	mom_wH2yH_a(j) = -(1+eta_h1_w1) * guH(j-1) -eta_h1_w2 * guH2W(j-1) ;
	j = j + 1 ;
end

j = start_j ;
while j <= T 
    mom_wH2yH_b(j) = (1+eta_h1_w1) * guH(j-1) + eta_h1_w2 * guH2W(j-1) ;
	j = j + 1 ;
end

%   Matrix 45: E[DwW2 DyH]
%   -----------------------------------------------------------------------

%   Intertemporal co-variances:
j = 2 ;
while j <= T 
	mom_wW2yH_a(j) = -(1+eta_h1_w1) * guHW2(j-1) -eta_h1_w2 * guW(j-1) ;
	j = j + 1 ;
end

j = start_j ;
while j <= T
    mom_wW2yH_b(j) = (1+eta_h1_w1) * guHW2(j-1) + eta_h1_w2 * guW(j-1) ;
	j = j + 1 ;
end

%   Matrix 27: E[DwH2 DyW]
%   -----------------------------------------------------------------------

%   Intertemporal co-variances:
j = 2 ;
while j <= T 
	mom_wH2yW_a(j) = -eta_h2_w1 * guH(j-1) -(1+eta_h2_w2) * guH2W(j-1) ;
	j = j + 1 ;
end

j = start_j ;
while j <= T 
	mom_wH2yW_b(j) = eta_h2_w1 * guH(j-1) + (1+eta_h2_w2) * guH2W(j-1) ;
	j = j + 1 ;
end

%   Matrix 47: E[DwW2 DyW]
%   -----------------------------------------------------------------------

%   Intertemporal co-variances:
j = 2 ;
while j <= T 
	mom_wW2yW_a(j) = -eta_h2_w1 * guHW2(j-1) -(1+eta_h2_w2) * guW(j-1) ;
	j = j + 1 ;
end

j = start_j ;
while j <= T 
	mom_wW2yW_b(j) = eta_h2_w1 * guHW2(j-1) + (1+eta_h2_w2) * guW(j-1) ;
	j = j + 1 ;
end

%   Matrix 29: E[DwH2 Dc]
%   -----------------------------------------------------------------------

%   Intertemporal co-variances:
j = 2 ;
while j <= T 
	mom_wH2c_a(j) = -eta_c_w1 * guH(j-1) -eta_c_w2 * guH2W(j-1) ;
	j = j + 1 ;
end

j = 3 ;
while j <= T
	mom_wH2c_b(j) = eta_c_w1 * guH(j-1) + eta_c_w2 * guH2W(j-1) ;
	j = j + 1 ;
end

%   Matrix 49: E[DwW2 Dc] 
%   -----------------------------------------------------------------------

%   Intertemporal co-variances:
j = 2 ;
while j <= T 
	mom_wW2c_a(j) = -eta_c_w1 * guHW2(j-1) -eta_c_w2 * guW(j-1) ;
	j = j + 1 ;
end

j = 3 ;
while j <= T
	mom_wW2c_b(j) = eta_c_w1 * guHW2(j-1) + eta_c_w2 * guW(j-1) ;
	j = j + 1 ;
end

%   Matrix 55: E[DyH DyH]   
%   -----------------------------------------------------------------------

%   Intertemporal co-variances:
j = start_j ;
while j <= T 
	mom_yHyH_a(j) = ...
        - (1 + Veta_h1_w1 + eta_h1_w1^2 + 2*eta_h1_w1) * uH(j-1) ...
        - 2*(eta_h1_w2 + COVeta_h1_w1_h1_w2 + eta_h1_w1*eta_h1_w2) * uHW(j-1) ...
        - (Veta_h1_w2 + eta_h1_w2^2) * uW(j-1) ;
	j = j + 1 ;
end

%   Matrix 57: E[DyH DyW]   
%   -----------------------------------------------------------------------

%   Intertemporal co-variances:
j = start_j ;
while j <= T
	mom_yHyW_a(j) = ...
        - (eta_h2_w1 + COVeta_h1_w1_h2_w1 + eta_h1_w1*eta_h2_w1) * uH(j-1) ...
        - (1 + eta_h1_w1 + eta_h2_w2 + COVeta_h1_w1_h2_w2 + eta_h1_w1*eta_h2_w2) * uHW(j-1) ...
        - (COVeta_h1_w2_h2_w1 + eta_h1_w2*eta_h2_w1) * uHW(j-1) ...
        - (eta_h1_w2 + COVeta_h1_w2_h2_w2 + eta_h1_w2*eta_h2_w2) * uW(j-1) ;
	j = j + 1 ;
end

j = start_j ;
while j <= T
	mom_yHyW_b(j) = ...
        - (eta_h2_w1 + COVeta_h1_w1_h2_w1 + eta_h1_w1*eta_h2_w1) * uH(j-1) ...
        - (1 + eta_h1_w1 + eta_h2_w2 + COVeta_h1_w1_h2_w2 + eta_h1_w1*eta_h2_w2) * uHW(j-1) ...
        - (COVeta_h1_w2_h2_w1 + eta_h1_w2*eta_h2_w1) * uHW(j-1) ...
        - (eta_h1_w2 + COVeta_h1_w2_h2_w2 + eta_h1_w2*eta_h2_w2) * uW(j-1) ;
	j = j + 1 ;
end

%   Matrix 77: E[DyW DyW]   
%   -----------------------------------------------------------------------

%   Intertemporal co-variances:
j = start_j ;
while j <= T 
	mom_yWyW_a(j) = ...
        - (Veta_h2_w1 + eta_h2_w1^2) * uH(j-1) ...
        - 2*(eta_h2_w1 + COVeta_h2_w1_h2_w2 + eta_h2_w1*eta_h2_w2) * uHW(j-1) ...
        - (1 + Veta_h2_w2 + eta_h2_w2^2 + 2*eta_h2_w2) * uW(j-1) ;
	j = j + 1 ;
end

%   Matrix 59: E[DyH Dc]   
%   -----------------------------------------------------------------------

%   Intertemporal co-variances:
j = start_j ;
while j <= T 
	mom_yHc_a(j) = ...
        - (eta_c_w1 + COVeta_c_w1_h1_w1 + eta_c_w1*eta_h1_w1) * uH(j-1) ...
        - (eta_c_w2 + COVeta_c_w2_h1_w1 + eta_c_w2*eta_h1_w1) * uHW(j-1) ...
        - (COVeta_c_w1_h1_w2 + eta_c_w1*eta_h1_w2) * uHW(j-1) ...
        - (COVeta_c_w2_h1_w2 + eta_c_w2*eta_h1_w2) * uW(j-1) ;
	j = j + 1 ;
end

j = 3 ;
while j <= T 
	mom_yHc_b(j) = ...
        - (eta_c_w1 + COVeta_c_w1_h1_w1 + eta_c_w1*eta_h1_w1) * uH(j-1) ...
        - (eta_c_w2 + COVeta_c_w2_h1_w1 + eta_c_w2*eta_h1_w1) * uHW(j-1) ...
        - (COVeta_c_w1_h1_w2 + eta_c_w1*eta_h1_w2) * uHW(j-1) ...
        - (COVeta_c_w2_h1_w2 + eta_c_w2*eta_h1_w2) * uW(j-1) ;
	j = j + 1 ;
end

%   Matrix 79: E[DyW Dc]   
%   -----------------------------------------------------------------------

%   Intertemporal co-variances:
j = start_j ;
while j <= T 
	mom_yWc_a(j) = ...
        - (COVeta_c_w1_h2_w1 + eta_c_w1*eta_h2_w1) * uH(j-1) ...
        - (COVeta_c_w2_h2_w1 + eta_c_w2*eta_h2_w1) * uHW(j-1) ...
        - (eta_c_w1 + COVeta_c_w1_h2_w2 + eta_c_w1*eta_h2_w2) * uHW(j-1) ...
        - (eta_c_w2 + COVeta_c_w2_h2_w2 + eta_c_w2*eta_h2_w2) * uW(j-1) ; 
	j = j + 1 ;
end

j = 3 ;
while j <= T
	mom_yWc_b(j) = ...
        - (COVeta_c_w1_h2_w1 + eta_c_w1*eta_h2_w1) * uH(j-1) ...
        - (COVeta_c_w2_h2_w1 + eta_c_w2*eta_h2_w1) * uHW(j-1) ...
        - (eta_c_w1 + COVeta_c_w1_h2_w2 + eta_c_w1*eta_h2_w2) * uHW(j-1) ...
        - (eta_c_w2 + COVeta_c_w2_h2_w2 + eta_c_w2*eta_h2_w2) * uW(j-1) ; 
	j = j + 1 ;
end

%   Matrix 99: E[Dc Dc]   
%   -----------------------------------------------------------------------

%   Intertemporal co-variances:
j = 3 ;
while j <= T
	mom_cc_a(j) = ...
        - (Veta_c_w1 + eta_c_w1^2) * uH(j-1) ...
        - 2*(COVeta_c_w1_c_w2 + eta_c_w1*eta_c_w2) * uHW(j-1) ...
        - (Veta_c_w2 + eta_c_w2^2) * uW(j-1) ;
	j = j + 1 ;
end

%   Matrix 16: E[DwH DyH2]
%   -----------------------------------------------------------------------

%   Intertemporal co-variances:
j = 2 ;
while j <= T 
	mom_wHyH2_a(j) = ...
          (1 + Veta_h1_w1 + eta_h1_w1^2 + 2*eta_h1_w1) * guH(j-1) ...
        + 2*(eta_h1_w2 + COVeta_h1_w1_h1_w2 + eta_h1_w1*eta_h1_w2) * guH2W(j-1) ...
        + (Veta_h1_w2 + eta_h1_w2^2) * guHW2(j-1) ;
	j = j + 1 ;
end

j = start_j ;
while j <= T 
	mom_wHyH2_b(j) = ...
        - (1 + Veta_h1_w1 + eta_h1_w1^2 + 2*eta_h1_w1) * guH(j-1) ...
        - 2*(eta_h1_w2 + COVeta_h1_w1_h1_w2 + eta_h1_w1*eta_h1_w2) * guH2W(j-1) ...
        - (Veta_h1_w2 + eta_h1_w2^2) * guHW2(j-1) ;
	j = j + 1 ;
end

%   Matrix 36: E[DwW DyH2]
%   -----------------------------------------------------------------------

%   Intertemporal co-variances:
j = 2 ;
while j <= T 
	mom_wWyH2_a(j) = ...
          (1 + Veta_h1_w1 + eta_h1_w1^2 + 2*eta_h1_w1) * guH2W(j-1) ...
        + 2*(eta_h1_w2 + COVeta_h1_w1_h1_w2 + eta_h1_w1*eta_h1_w2) * guHW2(j-1) ...
        + (Veta_h1_w2 + eta_h1_w2^2) * guW(j-1) ;
	j = j + 1 ;
end

j = start_j ;
while j <= T 
	mom_wWyH2_b(j) = ...
        - (1 + Veta_h1_w1 + eta_h1_w1^2 + 2*eta_h1_w1) * guH2W(j-1) ...
        - 2*(eta_h1_w2 + COVeta_h1_w1_h1_w2 + eta_h1_w1*eta_h1_w2) * guHW2(j-1) ...
        - (Veta_h1_w2 + eta_h1_w2^2) * guW(j-1) ;
	j = j + 1 ;
end

%   Matrix 18: E[DwH DyW2]
%   -----------------------------------------------------------------------

%   Intertemporal co-variances:
j = 2 ;
while j <= T 
	mom_wHyW2_a(j) = ...
          (Veta_h2_w1 + eta_h2_w1^2) * guH(j-1) ...
        + 2*(eta_h2_w1 + COVeta_h2_w1_h2_w2 + eta_h2_w1*eta_h2_w2) * guH2W(j-1) ...
        + (1 + Veta_h2_w2 + eta_h2_w2^2 + 2*eta_h2_w2) * guHW2(j-1) ;
	j = j + 1 ;
end

j = start_j ;
while j <= T 
	mom_wHyW2_b(j) = ...
        - (Veta_h2_w1 + eta_h2_w1^2) * guH(j-1) ...
        - 2*(eta_h2_w1 + COVeta_h2_w1_h2_w2 + eta_h2_w1*eta_h2_w2) * guH2W(j-1) ...
        - (1 + Veta_h2_w2 + eta_h2_w2^2 + 2*eta_h2_w2) * guHW2(j-1) ;
	j = j + 1 ;
end

%   Matrix 38: E[DwW DyW2]   
%   -----------------------------------------------------------------------

%   Intertemporal co-variances:
j = 2 ;
while j <= T 
	mom_wWyW2_a(j) = ...
          (Veta_h2_w1 + eta_h2_w1^2) * guH2W(j-1) ...
        + 2*(eta_h2_w1 + COVeta_h2_w1_h2_w2 + eta_h2_w1*eta_h2_w2) * guHW2(j-1) ...
        + (1 + Veta_h2_w2 + eta_h2_w2^2 + 2*eta_h2_w2) * guW(j-1) ;
	j = j + 1 ;
end

j = start_j ;
while j <= T 
	mom_wWyW2_b(j) = ...
        - (Veta_h2_w1 + eta_h2_w1^2) * guH2W(j-1) ...
        - 2*(eta_h2_w1 + COVeta_h2_w1_h2_w2 + eta_h2_w1*eta_h2_w2) * guHW2(j-1) ...
        - (1 + Veta_h2_w2 + eta_h2_w2^2 + 2*eta_h2_w2) * guW(j-1) ;
	j = j + 1 ;
end

%   Matrix 1.10: E[DwH Dc2]
%   -----------------------------------------------------------------------

%   Intertemporal co-variances:
j = 2 ;
while j <= T
	mom_wHc2_a(j) = ...
          (Veta_c_w1 + eta_c_w1^2) * guH(j-1) ...
        + 2*(COVeta_c_w1_c_w2 + eta_c_w1*eta_c_w2) * guH2W(j-1) ...
        + (Veta_c_w2 + eta_c_w2^2) * guHW2(j-1) ;
	j = j + 1 ;
end

j = 3 ;
while j <= T
	mom_wHc2_b(j) = ...
        - (Veta_c_w1 + eta_c_w1^2) * guH(j-1) ...
        - 2*(COVeta_c_w1_c_w2 + eta_c_w1*eta_c_w2) * guH2W(j-1) ...
        - (Veta_c_w2 + eta_c_w2^2) * guHW2(j-1) ;
	j = j + 1 ;
end

%   Matrix 3.10: E[DwW Dc2] 
%   -----------------------------------------------------------------------

%   Intertemporal co-variances:
j = 2 ;
while j <= T
	mom_wWc2_a(j) = ...
          (Veta_c_w1 + eta_c_w1^2) * guH2W(j-1) ...
        + 2*(COVeta_c_w1_c_w2 + eta_c_w1*eta_c_w2) * guHW2(j-1) ...
        + (Veta_c_w2 + eta_c_w2^2) * guW(j-1) ;
	j = j + 1 ;
end

j = 3 ;
while j <= T
	mom_wWc2_b(j) = ...
        - (Veta_c_w1 + eta_c_w1^2) * guH2W(j-1) ...
        - 2*(COVeta_c_w1_c_w2 + eta_c_w1*eta_c_w2) * guHW2(j-1) ...
        - (Veta_c_w2 + eta_c_w2^2) * guW(j-1) ;
	j = j + 1 ;
end

%   Matrix 1.11: E[DwH DyH DyW]
%   -----------------------------------------------------------------------

%   Intertemporal co-variances:
j = 2 ;
while j <= T
	mom_wHyHyW_a(j) = ...
          (eta_h2_w1 + COVeta_h1_w1_h2_w1 + eta_h1_w1*eta_h2_w1) * guH(j-1) ...
        + (1 + eta_h1_w1 + eta_h2_w2 + COVeta_h1_w1_h2_w2 + eta_h1_w1*eta_h2_w2) * guH2W(j-1) ...
        + (COVeta_h1_w2_h2_w1 + eta_h1_w2*eta_h2_w1) * guH2W(j-1) ...
        + (eta_h1_w2 + COVeta_h1_w2_h2_w2 + eta_h1_w2*eta_h2_w2) * guHW2(j-1) ;
	j = j + 1 ;
end

j = start_j ;
while j <= T
	mom_wHyHyW_b(j) = ...
        - (eta_h2_w1 + COVeta_h1_w1_h2_w1 + eta_h1_w1*eta_h2_w1) * guH(j-1) ...
        - (1 + eta_h1_w1 + eta_h2_w2 + COVeta_h1_w1_h2_w2 + eta_h1_w1*eta_h2_w2) * guH2W(j-1) ...
        - (COVeta_h1_w2_h2_w1 + eta_h1_w2*eta_h2_w1) * guH2W(j-1) ...
        - (eta_h1_w2 + COVeta_h1_w2_h2_w2 + eta_h1_w2*eta_h2_w2) * guHW2(j-1) ;
	j = j + 1 ;
end

%   Matrix 3.11: E[DwW DyH DyW]    
%   -----------------------------------------------------------------------

%   Intertemporal co-variances:
j = 2 ;
while j <= T
	mom_wWyHyW_a(j) = ...
          (eta_h2_w1 + COVeta_h1_w1_h2_w1 + eta_h1_w1*eta_h2_w1) * guH2W(j-1) ...
        + (1 + eta_h1_w1 + eta_h2_w2 + COVeta_h1_w1_h2_w2 + eta_h1_w1*eta_h2_w2) * guHW2(j-1) ...
        + (COVeta_h1_w2_h2_w1 + eta_h1_w2*eta_h2_w1) * guHW2(j-1) ...
        + (eta_h1_w2 + COVeta_h1_w2_h2_w2 + eta_h1_w2*eta_h2_w2) * guW(j-1) ;
	j = j + 1 ;
end

j = start_j ;
while j <= T
	mom_wWyHyW_b(j) = ...
        - (eta_h2_w1 + COVeta_h1_w1_h2_w1 + eta_h1_w1*eta_h2_w1) * guH2W(j-1) ...
        - (1 + eta_h1_w1 + eta_h2_w2 + COVeta_h1_w1_h2_w2 + eta_h1_w1*eta_h2_w2) * guHW2(j-1) ...
        - (COVeta_h1_w2_h2_w1 + eta_h1_w2*eta_h2_w1) * guHW2(j-1) ...
        - (eta_h1_w2 + COVeta_h1_w2_h2_w2 + eta_h1_w2*eta_h2_w2) * guW(j-1) ;
	j = j + 1 ;
end

%   Matrix 1.12: E[DwH DyH Dc]
%   -----------------------------------------------------------------------

%   Intertemporal co-variances:
j = 2 ;
while j <= T 
	mom_wHyHc_a(j) = ...
          (eta_c_w1 + COVeta_c_w1_h1_w1 + eta_c_w1*eta_h1_w1) * guH(j-1) ...
        + (eta_c_w2 + COVeta_c_w2_h1_w1 + eta_c_w2*eta_h1_w1) * guH2W(j-1) ...
        + (COVeta_c_w1_h1_w2 + eta_c_w1*eta_h1_w2) * guH2W(j-1) ...
        + (COVeta_c_w2_h1_w2 + eta_c_w2*eta_h1_w2) * guHW2(j-1) ;
	j = j + 1 ;
end

j = 3 ;
while j <= T 
	mom_wHyHc_b(j) = ...
        - (eta_c_w1 + COVeta_c_w1_h1_w1 + eta_c_w1*eta_h1_w1) * guH(j-1) ...
        - (eta_c_w2 + COVeta_c_w2_h1_w1 + eta_c_w2*eta_h1_w1) * guH2W(j-1) ...
        - (COVeta_c_w1_h1_w2 + eta_c_w1*eta_h1_w2) * guH2W(j-1) ...
        - (COVeta_c_w2_h1_w2 + eta_c_w2*eta_h1_w2) * guHW2(j-1) ;
	j = j + 1 ;
end

%   Matrix 3.12: E[DwW DyH Dc] 
%   -----------------------------------------------------------------------

%   Intertemporal co-variances:
j = 2 ;
while j <= T 
	mom_wWyHc_a(j) = ...
          (eta_c_w1 + COVeta_c_w1_h1_w1 + eta_c_w1*eta_h1_w1) * guH2W(j-1) ...
        + (eta_c_w2 + COVeta_c_w2_h1_w1 + eta_c_w2*eta_h1_w1) * guHW2(j-1) ...
        + (COVeta_c_w1_h1_w2 + eta_c_w1*eta_h1_w2) * guHW2(j-1) ...
        + (COVeta_c_w2_h1_w2 + eta_c_w2*eta_h1_w2) * guW(j-1) ;
	j = j + 1 ;
end

j = 3 ;
while j <= T 
	mom_wWyHc_b(j) = ...
        - (eta_c_w1 + COVeta_c_w1_h1_w1 + eta_c_w1*eta_h1_w1) * guH2W(j-1) ...
        - (eta_c_w2 + COVeta_c_w2_h1_w1 + eta_c_w2*eta_h1_w1) * guHW2(j-1) ...
        - (COVeta_c_w1_h1_w2 + eta_c_w1*eta_h1_w2) * guHW2(j-1) ...
        - (COVeta_c_w2_h1_w2 + eta_c_w2*eta_h1_w2) * guW(j-1) ;
	j = j + 1 ;
end

%   Matrix 1.13: E[DwH DyW Dc]
%   -----------------------------------------------------------------------

%   Intertemporal co-variances:
j = 2 ;
while j <= T 
	mom_wHyWc_a(j) = ...
          (COVeta_c_w1_h2_w1 + eta_c_w1*eta_h2_w1) * guH(j-1) ...
        + (COVeta_c_w2_h2_w1 + eta_c_w2*eta_h2_w1) * guH2W(j-1) ...
        + (eta_c_w1 + COVeta_c_w1_h2_w2 + eta_c_w1*eta_h2_w2) * guH2W(j-1) ...
        + (eta_c_w2 + COVeta_c_w2_h2_w2 + eta_c_w2*eta_h2_w2) * guHW2(j-1) ; 
	j = j + 1 ;
end

j = 3 ;
while j <= T
	mom_wHyWc_b(j) = ...
        - (COVeta_c_w1_h2_w1 + eta_c_w1*eta_h2_w1) * guH(j-1) ...
        - (COVeta_c_w2_h2_w1 + eta_c_w2*eta_h2_w1) * guH2W(j-1) ...
        - (eta_c_w1 + COVeta_c_w1_h2_w2 + eta_c_w1*eta_h2_w2) * guH2W(j-1) ...
        - (eta_c_w2 + COVeta_c_w2_h2_w2 + eta_c_w2*eta_h2_w2) * guHW2(j-1) ; 
	j = j + 1 ;
end

%   Matrix 3.13: E[DwW DyW Dc] 
%   -----------------------------------------------------------------------

%   Intertemporal co-variances:
j = 2 ;
while j <= T 
	mom_wWyWc_a(j) = ...
          (COVeta_c_w1_h2_w1 + eta_c_w1*eta_h2_w1) * guH2W(j-1) ...
        + (COVeta_c_w2_h2_w1 + eta_c_w2*eta_h2_w1) * guHW2(j-1) ...
        + (eta_c_w1 + COVeta_c_w1_h2_w2 + eta_c_w1*eta_h2_w2) * guHW2(j-1) ...
        + (eta_c_w2 + COVeta_c_w2_h2_w2 + eta_c_w2*eta_h2_w2) * guW(j-1) ;
	j = j + 1 ;
end

j = 3 ;
while j <= T
	mom_wWyWc_b(j) = ...
        - (COVeta_c_w1_h2_w1 + eta_c_w1*eta_h2_w1) * guH2W(j-1) ...
        - (COVeta_c_w2_h2_w1 + eta_c_w2*eta_h2_w1) * guHW2(j-1) ...
        - (eta_c_w1 + COVeta_c_w1_h2_w2 + eta_c_w1*eta_h2_w2) * guHW2(j-1) ...
        - (eta_c_w2 + COVeta_c_w2_h2_w2 + eta_c_w2*eta_h2_w2) * guW(j-1) ;
	j = j + 1 ;
end


%%  4.  ADDITIONAL MOMENTS - NOT MATCHED
%   Construct vector of moments E(model_moment_i)
%   -----------------------------------------------------------------------

%   Matrix X15: E[DwH DyH DyH'] 
%   -----------------------------------------------------------------------

%   Intertemporal co-variances:
j = start_j ;
while j <= T 
	mom_wHyHyHt(j) = ...
        - (1 + Veta_h1_w1 + eta_h1_w1^2 + 2*eta_h1_w1) * guH(j-1) ...
        - 2*(eta_h1_w2 + COVeta_h1_w1_h1_w2 + eta_h1_w1*eta_h1_w2) * guH2W(j-1) ...
        - (Veta_h1_w2 + eta_h1_w2^2) * guHW2(j-1) ;
	j = j + 1 ;
end

j = start_j ;
while j <= T 
	mom_wHyHyHt_b(j) = ...
          (1 + Veta_h1_w1 + eta_h1_w1^2 + 2*eta_h1_w1) * guH(j-1) ...
        + 2*(eta_h1_w2 + COVeta_h1_w1_h1_w2 + eta_h1_w1*eta_h1_w2) * guH2W(j-1) ...
        + (Veta_h1_w2 + eta_h1_w2^2) * guHW2(j-1) ;
	j = j + 1 ;
end

%   Matrix X35: E[DwW DyH DyH']
%   -----------------------------------------------------------------------

%   Intertemporal co-variances:
j = start_j ;
while j <= T 
	mom_wWyHyHt(j) = ...
        - (1 + Veta_h1_w1 + eta_h1_w1^2 + 2*eta_h1_w1) * guH2W(j-1) ...
        - 2*(eta_h1_w2 + COVeta_h1_w1_h1_w2 + eta_h1_w1*eta_h1_w2) * guHW2(j-1) ...
        - (Veta_h1_w2 + eta_h1_w2^2) * guW(j-1) ;
	j = j + 1 ;
end

j = start_j ;
while j <= T 
	mom_wWyHyHt_b(j) = ...
          (1 + Veta_h1_w1 + eta_h1_w1^2 + 2*eta_h1_w1) * guH2W(j-1) ...
        + 2*(eta_h1_w2 + COVeta_h1_w1_h1_w2 + eta_h1_w1*eta_h1_w2) * guHW2(j-1) ...
        + (Veta_h1_w2 + eta_h1_w2^2) * guW(j-1) ;
	j = j + 1 ;
end

%   Matrix X17: E[DwH DyW DyW']
%   -----------------------------------------------------------------------

%   Intertemporal co-variances:
j = start_j ;
while j <= T 
	mom_wHyWyWt(j) = ...
        - (Veta_h2_w1 + eta_h2_w1^2) * guH(j-1) ...
        - 2*(eta_h2_w1 + COVeta_h2_w1_h2_w2 + eta_h2_w1*eta_h2_w2) * guH2W(j-1) ...
        - (1 + Veta_h2_w2 + eta_h2_w2^2 + 2*eta_h2_w2) * guHW2(j-1) ;
	j = j + 1 ;
end

j = start_j ;
while j <= T 
	mom_wHyWyWt_b(j) = ...
          (Veta_h2_w1 + eta_h2_w1^2) * guH(j-1) ...
        + 2*(eta_h2_w1 + COVeta_h2_w1_h2_w2 + eta_h2_w1*eta_h2_w2) * guH2W(j-1) ...
        + (1 + Veta_h2_w2 + eta_h2_w2^2 + 2*eta_h2_w2) * guHW2(j-1) ;
	j = j + 1 ;
end

%   Matrix X37: E[DwW DyW DyW']    
%   -----------------------------------------------------------------------

%   Intertemporal co-variances:
j = start_j ;
while j <= T 
	mom_wWyWyWt(j) = ...
        - (Veta_h2_w1 + eta_h2_w1^2) * guH2W(j-1) ...
        - 2*(eta_h2_w1 + COVeta_h2_w1_h2_w2 + eta_h2_w1*eta_h2_w2) * guHW2(j-1) ...
        - (1 + Veta_h2_w2 + eta_h2_w2^2 + 2*eta_h2_w2) * guW(j-1) ;
	j = j + 1 ;
end

j = start_j ;
while j <= T 
	mom_wWyWyWt_b(j) = ...
          (Veta_h2_w1 + eta_h2_w1^2) * guH2W(j-1) ...
        + 2*(eta_h2_w1 + COVeta_h2_w1_h2_w2 + eta_h2_w1*eta_h2_w2) * guHW2(j-1) ...
        + (1 + Veta_h2_w2 + eta_h2_w2^2 + 2*eta_h2_w2) * guW(j-1) ;
	j = j + 1 ;
end

%   Matrix X19: E[DwH Dc Dc']
%   -----------------------------------------------------------------------

%   Intertemporal co-variances:
j = start_j ;
while j <= T
	mom_wHcct(j) = ...
        - (Veta_c_w1 + eta_c_w1^2) * guH(j-1) ...
        - 2*(COVeta_c_w1_c_w2 + eta_c_w1*eta_c_w2) * guH2W(j-1) ...
        - (Veta_c_w2 + eta_c_w2^2) * guHW2(j-1) ;
	j = j + 1 ;
end

j = start_j ;
while j <= T
	mom_wHcct_b(j) = ...
          (Veta_c_w1 + eta_c_w1^2) * guH(j-1) ...
        + 2*(COVeta_c_w1_c_w2 + eta_c_w1*eta_c_w2) * guH2W(j-1) ...
        + (Veta_c_w2 + eta_c_w2^2) * guHW2(j-1) ;
	j = j + 1 ;
end

%   Matrix X39: E[DwW Dc Dc'] 
%   -----------------------------------------------------------------------

%   Intertemporal co-variances:
j = start_j ;
while j <= T
	mom_wWcct(j) = ...
        - (Veta_c_w1 + eta_c_w1^2) * guH2W(j-1) ...
        - 2*(COVeta_c_w1_c_w2 + eta_c_w1*eta_c_w2) * guHW2(j-1) ...
        - (Veta_c_w2 + eta_c_w2^2) * guW(j-1) ;
	j = j + 1 ;
end

j = start_j ;
while j <= T
	mom_wWcct_b(j) = ...
          (Veta_c_w1 + eta_c_w1^2) * guH2W(j-1) ...
        + 2*(COVeta_c_w1_c_w2 + eta_c_w1*eta_c_w2) * guHW2(j-1) ...
        + (Veta_c_w2 + eta_c_w2^2) * guW(j-1) ;
	j = j + 1 ;
end

%   Matrix XA1.11: E[DwH DyH DyW']
%   -----------------------------------------------------------------------

%   Intertemporal co-variances:
j = start_j ;
while j <= T
	mom_wHyHyWt(j) = ...
        - (eta_h2_w1 + COVeta_h1_w1_h2_w1 + eta_h1_w1*eta_h2_w1) * guH(j-1) ...
        - (1 + eta_h1_w1 + eta_h2_w2 + COVeta_h1_w1_h2_w2 + eta_h1_w1*eta_h2_w2) * guH2W(j-1) ...
        - (COVeta_h1_w2_h2_w1 + eta_h1_w2*eta_h2_w1) * guH2W(j-1) ...
        - (eta_h1_w2 + COVeta_h1_w2_h2_w2 + eta_h1_w2*eta_h2_w2) * guHW2(j-1) ;
	j = j + 1 ;
end

j = start_j ;
while j <= T
	mom_wHyHyWt_b(j) = ...
          (eta_h2_w1 + COVeta_h1_w1_h2_w1 + eta_h1_w1*eta_h2_w1) * guH(j-1) ...
        + (1 + eta_h1_w1 + eta_h2_w2 + COVeta_h1_w1_h2_w2 + eta_h1_w1*eta_h2_w2) * guH2W(j-1) ...
        + (COVeta_h1_w2_h2_w1 + eta_h1_w2*eta_h2_w1) * guH2W(j-1) ...
        + (eta_h1_w2 + COVeta_h1_w2_h2_w2 + eta_h1_w2*eta_h2_w2) * guHW2(j-1) ;
	j = j + 1 ;
end

%   Matrix XA3.11: E[DwW DyH DyW']    
%   -----------------------------------------------------------------------

%   Intertemporal co-variances:
j = start_j ;
while j <= T
	mom_wWyHyWt(j) = ...
        - (eta_h2_w1 + COVeta_h1_w1_h2_w1 + eta_h1_w1*eta_h2_w1) * guH2W(j-1) ...
        - (1 + eta_h1_w1 + eta_h2_w2 + COVeta_h1_w1_h2_w2 + eta_h1_w1*eta_h2_w2) * guHW2(j-1) ...
        - (COVeta_h1_w2_h2_w1 + eta_h1_w2*eta_h2_w1) * guHW2(j-1) ...
        - (eta_h1_w2 + COVeta_h1_w2_h2_w2 + eta_h1_w2*eta_h2_w2) * guW(j-1) ;
	j = j + 1 ;
end

j = start_j ;
while j <= T
	mom_wWyHyWt_b(j) = ...
          (eta_h2_w1 + COVeta_h1_w1_h2_w1 + eta_h1_w1*eta_h2_w1) * guH2W(j-1) ...
        + (1 + eta_h1_w1 + eta_h2_w2 + COVeta_h1_w1_h2_w2 + eta_h1_w1*eta_h2_w2) * guHW2(j-1) ...
        + (COVeta_h1_w2_h2_w1 + eta_h1_w2*eta_h2_w1) * guHW2(j-1) ...
        + (eta_h1_w2 + COVeta_h1_w2_h2_w2 + eta_h1_w2*eta_h2_w2) * guW(j-1) ;
	j = j + 1 ;
end

%   Matrix XB1.11: E[DwH DyH' DyW]
%   -----------------------------------------------------------------------

%   Intertemporal co-variances:
j = start_j ;
while j <= T
	mom_wHyHtyW(j) = ...
        - (eta_h2_w1 + COVeta_h1_w1_h2_w1 + eta_h1_w1*eta_h2_w1) * guH(j-1) ...
        - (1 + eta_h1_w1 + eta_h2_w2 + COVeta_h1_w1_h2_w2 + eta_h1_w1*eta_h2_w2) * guH2W(j-1) ...
        - (COVeta_h1_w2_h2_w1 + eta_h1_w2*eta_h2_w1) * guH2W(j-1) ...
        - (eta_h1_w2 + COVeta_h1_w2_h2_w2 + eta_h1_w2*eta_h2_w2) * guHW2(j-1) ;
	j = j + 1 ;
end

j = start_j ;
while j <= T
	mom_wHyHtyW_b(j) = ...
          (eta_h2_w1 + COVeta_h1_w1_h2_w1 + eta_h1_w1*eta_h2_w1) * guH(j-1) ...
        + (1 + eta_h1_w1 + eta_h2_w2 + COVeta_h1_w1_h2_w2 + eta_h1_w1*eta_h2_w2) * guH2W(j-1) ...
        + (COVeta_h1_w2_h2_w1 + eta_h1_w2*eta_h2_w1) * guH2W(j-1) ...
        + (eta_h1_w2 + COVeta_h1_w2_h2_w2 + eta_h1_w2*eta_h2_w2) * guHW2(j-1) ;
	j = j + 1 ;
end

%   Matrix XB3.11: E[DwW DyH' DyW]    
%   -----------------------------------------------------------------------

%   Intertemporal co-variances:
j = start_j ;
while j <= T
	mom_wWyHtyW(j) = ...
        - (eta_h2_w1 + COVeta_h1_w1_h2_w1 + eta_h1_w1*eta_h2_w1) * guH2W(j-1) ...
        - (1 + eta_h1_w1 + eta_h2_w2 + COVeta_h1_w1_h2_w2 + eta_h1_w1*eta_h2_w2) * guHW2(j-1) ...
        - (COVeta_h1_w2_h2_w1 + eta_h1_w2*eta_h2_w1) * guHW2(j-1) ...
        - (eta_h1_w2 + COVeta_h1_w2_h2_w2 + eta_h1_w2*eta_h2_w2) * guW(j-1) ;
	j = j + 1 ;
end

j = start_j ;
while j <= T
	mom_wWyHtyW_b(j) = ...
          (eta_h2_w1 + COVeta_h1_w1_h2_w1 + eta_h1_w1*eta_h2_w1) * guH2W(j-1) ...
        + (1 + eta_h1_w1 + eta_h2_w2 + COVeta_h1_w1_h2_w2 + eta_h1_w1*eta_h2_w2) * guHW2(j-1) ...
        + (COVeta_h1_w2_h2_w1 + eta_h1_w2*eta_h2_w1) * guHW2(j-1) ...
        + (eta_h1_w2 + COVeta_h1_w2_h2_w2 + eta_h1_w2*eta_h2_w2) * guW(j-1) ;
	j = j + 1 ;
end

%   Matrix XA1.12: E[DwH DyH Dc']
%   -----------------------------------------------------------------------

%   Intertemporal co-variances:
j = start_j ;
while j <= T 
	mom_wHyHct(j) = ...
        - (eta_c_w1 + COVeta_c_w1_h1_w1 + eta_c_w1*eta_h1_w1) * guH(j-1) ...
        - (eta_c_w2 + COVeta_c_w2_h1_w1 + eta_c_w2*eta_h1_w1) * guH2W(j-1) ...
        - (COVeta_c_w1_h1_w2 + eta_c_w1*eta_h1_w2) * guH2W(j-1) ...
        - (COVeta_c_w2_h1_w2 + eta_c_w2*eta_h1_w2) * guHW2(j-1) ;
	j = j + 1 ;
end

j = start_j ;
while j <= T 
	mom_wHyHct_b(j) = ...
          (eta_c_w1 + COVeta_c_w1_h1_w1 + eta_c_w1*eta_h1_w1) * guH(j-1) ...
        + (eta_c_w2 + COVeta_c_w2_h1_w1 + eta_c_w2*eta_h1_w1) * guH2W(j-1) ...
        + (COVeta_c_w1_h1_w2 + eta_c_w1*eta_h1_w2) * guH2W(j-1) ...
        + (COVeta_c_w2_h1_w2 + eta_c_w2*eta_h1_w2) * guHW2(j-1) ;
	j = j + 1 ;
end

%   Matrix XA3.12: E[DwW DyH Dc'] 
%   -----------------------------------------------------------------------

%   Intertemporal co-variances:
j = start_j ;
while j <= T 
	mom_wWyHct(j) = ...
        - (eta_c_w1 + COVeta_c_w1_h1_w1 + eta_c_w1*eta_h1_w1) * guH2W(j-1) ...
        - (eta_c_w2 + COVeta_c_w2_h1_w1 + eta_c_w2*eta_h1_w1) * guHW2(j-1) ...
        - (COVeta_c_w1_h1_w2 + eta_c_w1*eta_h1_w2) * guHW2(j-1) ...
        - (COVeta_c_w2_h1_w2 + eta_c_w2*eta_h1_w2) * guW(j-1) ;
	j = j + 1 ;
end

j = start_j ;
while j <= T 
	mom_wWyHct_b(j) = ...
          (eta_c_w1 + COVeta_c_w1_h1_w1 + eta_c_w1*eta_h1_w1) * guH2W(j-1) ...
        + (eta_c_w2 + COVeta_c_w2_h1_w1 + eta_c_w2*eta_h1_w1) * guHW2(j-1) ...
        + (COVeta_c_w1_h1_w2 + eta_c_w1*eta_h1_w2) * guHW2(j-1) ...
        + (COVeta_c_w2_h1_w2 + eta_c_w2*eta_h1_w2) * guW(j-1) ;
	j = j + 1 ;
end

%   Matrix XB1.12: E[DwH DyH' Dc]
%   -----------------------------------------------------------------------

%   Intertemporal co-variances:
j = start_j ;
while j <= T 
	mom_wHyHtc(j) = ...
        - (eta_c_w1 + COVeta_c_w1_h1_w1 + eta_c_w1*eta_h1_w1) * guH(j-1) ...
        - (eta_c_w2 + COVeta_c_w2_h1_w1 + eta_c_w2*eta_h1_w1) * guH2W(j-1) ...
        - (COVeta_c_w1_h1_w2 + eta_c_w1*eta_h1_w2) * guH2W(j-1) ...
        - (COVeta_c_w2_h1_w2 + eta_c_w2*eta_h1_w2) * guHW2(j-1) ;
	j = j + 1 ;
end

j = start_j ;
while j <= T 
	mom_wHyHtc_b(j) = ...
          (eta_c_w1 + COVeta_c_w1_h1_w1 + eta_c_w1*eta_h1_w1) * guH(j-1) ...
        + (eta_c_w2 + COVeta_c_w2_h1_w1 + eta_c_w2*eta_h1_w1) * guH2W(j-1) ...
        + (COVeta_c_w1_h1_w2 + eta_c_w1*eta_h1_w2) * guH2W(j-1) ...
        + (COVeta_c_w2_h1_w2 + eta_c_w2*eta_h1_w2) * guHW2(j-1) ;
	j = j + 1 ;
end

%   Matrix XB3.12: E[DwW DyH' Dc] 
%   -----------------------------------------------------------------------

%   Intertemporal co-variances:
j = start_j ;
while j <= T 
	mom_wWyHtc(j) = ...
        - (eta_c_w1 + COVeta_c_w1_h1_w1 + eta_c_w1*eta_h1_w1) * guH2W(j-1) ...
        - (eta_c_w2 + COVeta_c_w2_h1_w1 + eta_c_w2*eta_h1_w1) * guHW2(j-1) ...
        - (COVeta_c_w1_h1_w2 + eta_c_w1*eta_h1_w2) * guHW2(j-1) ...
        - (COVeta_c_w2_h1_w2 + eta_c_w2*eta_h1_w2) * guW(j-1) ;
	j = j + 1 ;
end

j = start_j ;
while j <= T 
	mom_wWyHtc_b(j) = ...
          (eta_c_w1 + COVeta_c_w1_h1_w1 + eta_c_w1*eta_h1_w1) * guH2W(j-1) ...
        + (eta_c_w2 + COVeta_c_w2_h1_w1 + eta_c_w2*eta_h1_w1) * guHW2(j-1) ...
        + (COVeta_c_w1_h1_w2 + eta_c_w1*eta_h1_w2) * guHW2(j-1) ...
        + (COVeta_c_w2_h1_w2 + eta_c_w2*eta_h1_w2) * guW(j-1) ;
	j = j + 1 ;
end

%   Matrix XA1.13: E[DwH DyW Dc']
%   -----------------------------------------------------------------------

%   Intertemporal co-variances:
j = start_j ;
while j <= T 
	mom_wHyWct(j) = ...
        - (COVeta_c_w1_h2_w1 + eta_c_w1*eta_h2_w1) * guH(j-1) ...
        - (COVeta_c_w2_h2_w1 + eta_c_w2*eta_h2_w1) * guH2W(j-1) ...
        - (eta_c_w1 + COVeta_c_w1_h2_w2 + eta_c_w1*eta_h2_w2) * guH2W(j-1) ...
        - (eta_c_w2 + COVeta_c_w2_h2_w2 + eta_c_w2*eta_h2_w2) * guHW2(j-1) ; 
	j = j + 1 ;
end

j = start_j ;
while j <= T
	mom_wHyWct_b(j) = ...
          (COVeta_c_w1_h2_w1 + eta_c_w1*eta_h2_w1) * guH(j-1) ...
        + (COVeta_c_w2_h2_w1 + eta_c_w2*eta_h2_w1) * guH2W(j-1) ...
        + (eta_c_w1 + COVeta_c_w1_h2_w2 + eta_c_w1*eta_h2_w2) * guH2W(j-1) ...
        + (eta_c_w2 + COVeta_c_w2_h2_w2 + eta_c_w2*eta_h2_w2) * guHW2(j-1) ; 
	j = j + 1 ;
end

%   Matrix XA3.13: E[DwW DyW Dc']
%   -----------------------------------------------------------------------

%   Intertemporal co-variances:
j = start_j ;
while j <= T 
	mom_wWyWct(j) = ...
        - (COVeta_c_w1_h2_w1 + eta_c_w1*eta_h2_w1) * guH2W(j-1) ...
        - (COVeta_c_w2_h2_w1 + eta_c_w2*eta_h2_w1) * guHW2(j-1) ...
        - (eta_c_w1 + COVeta_c_w1_h2_w2 + eta_c_w1*eta_h2_w2) * guHW2(j-1) ...
        - (eta_c_w2 + COVeta_c_w2_h2_w2 + eta_c_w2*eta_h2_w2) * guW(j-1) ; 
	j = j + 1 ;
end

j = start_j ;
while j <= T
	mom_wWyWct_b(j) = ...
          (COVeta_c_w1_h2_w1 + eta_c_w1*eta_h2_w1) * guH2W(j-1) ...
        + (COVeta_c_w2_h2_w1 + eta_c_w2*eta_h2_w1) * guHW2(j-1) ...
        + (eta_c_w1 + COVeta_c_w1_h2_w2 + eta_c_w1*eta_h2_w2) * guHW2(j-1) ...
        + (eta_c_w2 + COVeta_c_w2_h2_w2 + eta_c_w2*eta_h2_w2) * guW(j-1) ;
	j = j + 1 ;
end

%   Matrix XB1.13: E[DwH DyW' Dc]
%   -----------------------------------------------------------------------

%   Intertemporal co-variances:
j = start_j ;
while j <= T 
	mom_wHyWtc(j) = ...
        - (COVeta_c_w1_h2_w1 + eta_c_w1*eta_h2_w1) * guH(j-1) ...
        - (COVeta_c_w2_h2_w1 + eta_c_w2*eta_h2_w1) * guH2W(j-1) ...
        - (eta_c_w1 + COVeta_c_w1_h2_w2 + eta_c_w1*eta_h2_w2) * guH2W(j-1) ...
        - (eta_c_w2 + COVeta_c_w2_h2_w2 + eta_c_w2*eta_h2_w2) * guHW2(j-1) ; 
	j = j + 1 ;
end

j = start_j ;
while j <= T
	mom_wHyWtc_b(j) = ...
          (COVeta_c_w1_h2_w1 + eta_c_w1*eta_h2_w1) * guH(j-1) ...
        + (COVeta_c_w2_h2_w1 + eta_c_w2*eta_h2_w1) * guH2W(j-1) ...
        + (eta_c_w1 + COVeta_c_w1_h2_w2 + eta_c_w1*eta_h2_w2) * guH2W(j-1) ...
        + (eta_c_w2 + COVeta_c_w2_h2_w2 + eta_c_w2*eta_h2_w2) * guHW2(j-1) ; 
	j = j + 1 ;
end

%   Matrix XB3.13: E[DwW DyW' Dc]
%   -----------------------------------------------------------------------

%   Intertemporal co-variances:
j = start_j ;
while j <= T 
	mom_wWyWtc(j) = ...
        - (COVeta_c_w1_h2_w1 + eta_c_w1*eta_h2_w1) * guH2W(j-1) ...
        - (COVeta_c_w2_h2_w1 + eta_c_w2*eta_h2_w1) * guHW2(j-1) ...
        - (eta_c_w1 + COVeta_c_w1_h2_w2 + eta_c_w1*eta_h2_w2) * guHW2(j-1) ...
        - (eta_c_w2 + COVeta_c_w2_h2_w2 + eta_c_w2*eta_h2_w2) * guW(j-1) ;
	j = j + 1 ;
end

j = start_j ;
while j <= T
	mom_wWyWtc_b(j) = ...
          (COVeta_c_w1_h2_w1 + eta_c_w1*eta_h2_w1) * guH2W(j-1) ...
        + (COVeta_c_w2_h2_w1 + eta_c_w2*eta_h2_w1) * guHW2(j-1) ...
        + (eta_c_w1 + COVeta_c_w1_h2_w2 + eta_c_w1*eta_h2_w2) * guHW2(j-1) ...
        + (eta_c_w2 + COVeta_c_w2_h2_w2 + eta_c_w2*eta_h2_w2) * guW(j-1) ;  
	j = j + 1 ;
end


%%  5.  DELIVER VECTORS OF THEORETICAL MOMENTS
%   Stack and deliver vectors of matched and unmatched moments.
%   -----------------------------------------------------------------------

%   Stack moments together. I condition some consumption vectors to 3:T or
%   start_j:T to remove zero entries resulting from the fact that these
%   moments are not observed in the data.
matched = [ mean(mom_wHwH(2:T-1))           ; ...  % 1        
            mean(mom_wHwH_a(2:T))           ; ...  % 2  
            mean(mom_wHwW(2:T-1))           ; ...  % 3    
            mean(mom_wHwW_a(2:T))           ; ...  % 4  
            mean(mom_wHwW_b(2:T))           ; ...  % 5  
            mean(mom_wWwW(2:T-1))           ; ...  % 6    
            mean(mom_wWwW_a(2:T))           ; ...  % 7  
            mean(mom_wHwH2(2:T-1))          ; ...  % 8       
            mean(mom_wHwH2_a(2:T))          ; ...  % 9 
            mean(mom_wHwH2_b(2:T))          ; ...  % 10 
            mean(mom_wH2wW(2:T-1))          ; ...  % 11       
            mean(mom_wH2wW_a(2:T))          ; ...  % 12 
            mean(mom_wH2wW_b(2:T))          ; ...  % 13 
            mean(mom_wHwW2(2:T-1))          ; ...  % 14       
            mean(mom_wHwW2_a(2:T))          ; ...  % 15
            mean(mom_wHwW2_b(2:T))          ; ...  % 16
            mean(mom_wWwW2(2:T-1))          ; ...  % 17  
            mean(mom_wWwW2_a(2:T))          ; ...  % 18 
            mean(mom_wWwW2_b(2:T))          ; ...  % 19 
            mean(mom_wWwHwHt(2:T))          ; ...  % 20  
            mean(mom_wWwHwHt_b(2:T))        ; ...  % 21 
            mean(mom_wHwWwWt(2:T))          ; ...  % 22  
            mean(mom_wHwWwWt_b(2:T))        ; ...  % 23       
            mean(mom_wHyH_a(2:T))           ; ...  % 24
            mean(mom_wHyH_b(start_j:T))     ; ...  % 25
            mean(mom_wWyH_a(2:T))           ; ...  % 26
            mean(mom_wWyH_b(start_j:T))     ; ...  % 27
            mean(mom_wHyW_a(2:T))           ; ...  % 28
            mean(mom_wHyW_b(start_j:T))     ; ...  % 29
            mean(mom_wWyW_a(2:T))           ; ...  % 30
            mean(mom_wWyW_b(start_j:T))     ; ...  % 31
            mean(mom_wHc_a(2:T))            ; ...  % 32
            mean(mom_wHc_b(3:T))            ; ...  % 33
            mean(mom_wWc_a(2:T))            ; ...  % 34
            mean(mom_wWc_b(3:T))            ; ...  % 35 
            mean(mom_yHyH_a(start_j:T))     ; ...  % 36
            mean(mom_yHyW_a(start_j:T))     ; ...  % 37
            mean(mom_yHyW_b(start_j:T))     ; ...  % 38
            mean(mom_yWyW_a(start_j:T))     ; ...  % 39
            mean(mom_yHc_a(start_j:T))      ; ...  % 40
            mean(mom_yHc_b(3:T))            ; ...  % 41
            mean(mom_yWc_a(start_j:T))      ; ...  % 42
            mean(mom_yWc_b(3:T))            ; ...  % 43
            mean(mom_cc_a(3:T))             ; ...  % 44
            mean(mom_wH2yH_a(2:T))          ; ...  % 45
            mean(mom_wH2yH_b(start_j:T))    ; ...  % 46
            mean(mom_wW2yH_a(2:T))          ; ...  % 47
            mean(mom_wW2yH_b(start_j:T))    ; ...  % 48
            mean(mom_wH2yW_a(2:T))          ; ...  % 49
            mean(mom_wH2yW_b(start_j:T))    ; ...  % 50
            mean(mom_wW2yW_a(2:T))          ; ...  % 51
            mean(mom_wW2yW_b(start_j:T))    ; ...  % 52
            mean(mom_wH2c_a(2:T))           ; ...  % 53
            mean(mom_wH2c_b(3:T))           ; ...  % 54
            mean(mom_wW2c_a(2:T))           ; ...  % 55
            mean(mom_wW2c_b(3:T))           ; ...  % 56
            mean(mom_wHyH2_a(2:T))          ; ...  % 57
            mean(mom_wHyH2_b(start_j:T))    ; ...  % 58
            mean(mom_wWyH2_a(2:T))          ; ...  % 59
            mean(mom_wWyH2_b(start_j:T))    ; ...  % 60
            mean(mom_wHyW2_a(2:T))          ; ...  % 61
            mean(mom_wHyW2_b(start_j:T))    ; ...  % 62
            mean(mom_wWyW2_a(2:T))          ; ...  % 63
            mean(mom_wWyW2_b(start_j:T))    ; ...  % 64
            mean(mom_wHc2_a(2:T))           ; ...  % 65
            mean(mom_wHc2_b(3:T))           ; ...  % 66
            mean(mom_wWc2_a(2:T))           ; ...  % 67
            mean(mom_wWc2_b(3:T))           ; ...  % 68
            mean(mom_wHyHyW_a(2:T))         ; ...  % 69
            mean(mom_wHyHyW_b(start_j:T))   ; ...  % 70
            mean(mom_wWyHyW_a(2:T))         ; ...  % 71
            mean(mom_wWyHyW_b(start_j:T))   ; ...  % 72
            mean(mom_wHyHc_a(2:T))          ; ...  % 73
            mean(mom_wHyHc_b(3:T))          ; ...  % 74
            mean(mom_wWyHc_a(2:T))          ; ...  % 75
            mean(mom_wWyHc_b(3:T))          ; ...  % 76
            mean(mom_wHyWc_a(2:T))          ; ...  % 77
            mean(mom_wHyWc_b(3:T))          ; ...  % 78
            mean(mom_wWyWc_a(2:T))          ; ...  % 79
            mean(mom_wWyWc_b(3:T))]         ;      % 80
unmatchd= [ mean(mom_wHyHyHt(start_j:T))    ; ...  % 1
            mean(mom_wHyHyHt_b(start_j:T))  ; ...  % 2
            mean(mom_wWyHyHt(start_j:T))    ; ...  % 3
            mean(mom_wWyHyHt_b(start_j:T))  ; ...  % 4
            mean(mom_wHyWyWt(start_j:T))    ; ...  % 5
            mean(mom_wHyWyWt_b(start_j:T))  ; ...  % 6  
            mean(mom_wWyWyWt(start_j:T))    ; ...  % 7
            mean(mom_wWyWyWt_b(start_j:T))  ; ...  % 8
            mean(mom_wHcct(3:T))            ; ...  % 9
            mean(mom_wHcct_b(3:T))          ; ...  % 10
            mean(mom_wWcct(3:T))            ; ...  % 11
            mean(mom_wWcct_b(3:T))          ; ...  % 12
            mean(mom_wHyHyWt(start_j:T))    ; ...  % 13
            mean(mom_wHyHyWt_b(start_j:T))  ; ...  % 14
            mean(mom_wWyHyWt(start_j:T))    ; ...  % 15
            mean(mom_wWyHyWt_b(start_j:T))  ; ...  % 16
            mean(mom_wHyHtyW(start_j:T))    ; ...  % 17
            mean(mom_wHyHtyW_b(start_j:T))  ; ...  % 18
            mean(mom_wWyHtyW(start_j:T))    ; ...  % 19
            mean(mom_wWyHtyW_b(start_j:T))  ; ...  % 20
            mean(mom_wHyHct(start_j:T))     ; ...  % 21
            mean(mom_wHyHct_b(start_j:T))   ; ...  % 22
            mean(mom_wWyHct(start_j:T))     ; ...  % 23
            mean(mom_wWyHct_b(start_j:T))   ; ...  % 24
            mean(mom_wHyHtc(3:T))           ; ...  % 25
            mean(mom_wHyHtc_b(3:T))         ; ...  % 26
            mean(mom_wWyHtc(3:T))           ; ...  % 27
            mean(mom_wWyHtc_b(3:T))         ; ...  % 28
            mean(mom_wHyWct(start_j:T))     ; ...  % 29
            mean(mom_wHyWct_b(start_j:T))   ; ...  % 30
            mean(mom_wWyWct(start_j:T))     ; ...  % 31
            mean(mom_wWyWct_b(start_j:T))   ; ...  % 32
            mean(mom_wHyWtc(3:T))           ; ...  % 33
            mean(mom_wHyWtc_b(3:T))         ; ...  % 34
            mean(mom_wWyWtc(3:T))           ; ...  % 35
            mean(mom_wWyWtc_b(3:T))]        ;      % 36
end