function f = model_structure_wk(vParams, vWages, smoms, smoms_bps, eta_c_p, mCes, mCpi, higher_moms)
%{  
    This function generates the moments conditions for the estimation of 
    the structural model from simulated data.

    Alexandros Theloudis
    -----------------------------------------------------------------------
%}

%   Initial statements: 
%   -zero variance of consumption measurement error - simulated data:
Vcons_err = 0.0 ;
%   -consumption substitution elasticity (fixed):
eta_c_p   = -eta_c_p ;


%%  1.  INITIALIZE OBJECTS
%   Initialize parameters and vectors to hold moments
%   -----------------------------------------------------------------------

%   Vector of pre-estimated wage parameters:
%   Second moments of wage parameters (required for all specifications):
vH  = vWages(1) ;       % variance:    permanent shock HD
uH  = vWages(2) ;       % variance:    transitory shock HD
vW  = vWages(3) ;       % variance:    permanent shock WF
uW  = vWages(4) ;       % variance:    transitory shock WF
vHW = vWages(5) ;       % covariance:  permanent shocks
uHW = vWages(6) ;       % covariance:  transitory shocks

%   First moments of parameters (always estimated across all specifications):
eta_c_w1  = vParams(1)  ;           % consumption wrt wage1
eta_c_w2  = vParams(2)  ;           % consumption wrt wage2
eta_h1_w1 = vParams(3)  ;           % hours1 wrt wage1
eta_h1_w2 = vParams(4)  ;           % hours1 wrt wage2
eta_h2_w1 = vParams(5)  ;           % hours2 wrt wage1
eta_h2_w2 = vParams(6)  ;           % hours2 wrt wage2

%   First moments of parameters identified in BPS specification only:
if higher_moms == -1   
	eta_h1_p  = vParams(7) ;        % hours1 wrt price
	eta_h2_p  = vParams(8) ;        % hours2 wrt price
end

%   Second moments of preferences, not identified in the simulated data: 
Veta_c_w1           = 0.0 ;     % consumption wrt wage1
Veta_c_w2           = 0.0 ;     % consumption wrt wage2
Veta_h1_w1          = 0.0 ;     % hours1 wrt wage1
Veta_h1_w2          = 0.0 ;     % hours1 wrt wage2
Veta_h2_w1          = 0.0 ;     % hours2 wrt wage1
Veta_h2_w2          = 0.0 ;     % hours2 wrt wage2
COVeta_c_w1_c_w2    = 0.0 ;     % consumption wrt wage1 ~ consumption wrt wage2
COVeta_c_w1_h1_w1   = 0.0 ;     % consumption wrt wage1 ~ hours1 wrt wage1
COVeta_c_w1_h1_w2   = 0.0 ;     % consumption wrt wage1 ~ hours1 wrt wage2
COVeta_c_w1_h2_w1   = 0.0 ;     % consumption wrt wage1 ~ hours2 wrt wage1
COVeta_c_w1_h2_w2   = 0.0 ;     % consumption wrt wage1 ~ hours2 wrt wage2
COVeta_c_w2_h1_w1   = 0.0 ;     % consumption wrt wage2 ~ hours1 wrt wage1
COVeta_c_w2_h1_w2   = 0.0 ;     % consumption wrt wage2 ~ hours1 wrt wage2
COVeta_c_w2_h2_w1   = 0.0 ;     % consumption wrt wage2 ~ hours2 wrt wage1
COVeta_c_w2_h2_w2   = 0.0 ;     % consumption wrt wage2 ~ hours2 wrt wage2
COVeta_h1_w1_h1_w2  = 0.0 ;     % hours1 wrt wage1 ~ hours1 wrt wage2
COVeta_h1_w1_h2_w1  = 0.0 ;     % hours1 wrt wage1 ~ hours2 wrt wage1
COVeta_h1_w1_h2_w2  = 0.0 ;     % hours1 wrt wage1 ~ hours2 wrt wage2
COVeta_h1_w2_h2_w1  = 0.0 ;     % hours1 wrt wage2 ~ hours2 wrt wage1
COVeta_h1_w2_h2_w2  = 0.0 ;     % hours1 wrt wage2 ~ hours2 wrt wage2
COVeta_h2_w1_h2_w2  = 0.0 ;     % hours2 wrt wage1 ~ hours2 wrt wage2 
        

%%  2.  DECLARE STRUCTURE
%   Initialize structural items
%   -----------------------------------------------------------------------

%   Declare items that transmit permanent wage shocks into earnings and
%   consumption; these items are used only when I estimate the BPS model
%   specification. Matrices 'e1' and 'e2' have size TxN: 
if higher_moms == -1

    %   Sum of average earnings & consumption Frish elasticities (scalars):
    eta_c_bar  = eta_c_w1 + eta_c_w2 + eta_c_p ;
    eta_h1_bar = eta_h1_w1 + eta_h1_w2 + eta_h1_p ;
    eta_h2_bar = eta_h2_w1 + eta_h2_w2 + eta_h2_p ;

    %   Denominator of 'epsilon':
    denom = eta_c_bar - (1-mCpi) .* (mCes*eta_h1_bar + (1-mCes)*eta_h2_bar) ;

    %   Construct 'epsilon' matrices:
    e1 = mean(nanmean(((1-mCpi) .* (mCes*(1+eta_h1_w1) + (1-mCes)*eta_h2_w1) - eta_c_w1) ./ denom)) ;
    e2 = mean(nanmean(((1-mCpi) .* (mCes*eta_h1_w2 + (1-mCes)*(1+eta_h2_w2)) - eta_c_w2) ./ denom)) ;
end %higher_moments == -1


%%  3.  FIRST MOMENTS PREFERENCES - SECOND MOMENTS WAGES
%   Construct vector of moments E(data_moment_i - model_moment_i) = 0
%   -----------------------------------------------------------------------

%   Matrix 15: E[DwH DyH]   
%   -----------------------------------------------------------------------

%   Contemporaneous co-variances:
if higher_moms == -1
mom_wHyH = smoms_bps(1) - (1+eta_h1_w1) * (uH + uH) ...
        - eta_h1_w2 * (uHW + uHW) ...
        - mean(nanmean(1+eta_h1_w1 + eta_h1_bar*e1)) * vH ...
        - mean(nanmean(eta_h1_w2 + eta_h1_bar*e2)) * vHW ;
end %higher_moments == -1

%   Intertemporal covariances:
mom_wHyH_a = smoms(8) + (1+eta_h1_w1) * uH + eta_h1_w2 * uHW ;
mom_wHyH_b = smoms(9) + (1+eta_h1_w1) * uH + eta_h1_w2 * uHW ;


%   Matrix 35: E[DwW DyH]   
%   -----------------------------------------------------------------------

%   Contemporaneous co-variances:
if higher_moms == -1
mom_wWyH = smoms_bps(2) - (1+eta_h1_w1) * (uHW + uHW) ...
        - eta_h1_w2 * (uW + uW) ...
        - mean(nanmean(1+eta_h1_w1 + eta_h1_bar*e1)) * vHW ...
        - mean(nanmean(eta_h1_w2 + eta_h1_bar*e2)) * vW ;
end %higher_moments == -1

%   Intertemporal co-variances:
mom_wWyH_a = smoms(10) + (1+eta_h1_w1) * uHW + eta_h1_w2 * uW ;
mom_wWyH_b = smoms(11) + (1+eta_h1_w1) * uHW + eta_h1_w2 * uW ;


%   Matrix 17: E[DwH DyW]   
%   -----------------------------------------------------------------------

%   Contemporaneous co-variances:
if higher_moms == -1
mom_wHyW = smoms_bps(3) - eta_h2_w1 * (uH + uH) ...
        - (1+eta_h2_w2) * (uHW + uHW) ...
        - mean(nanmean(eta_h2_w1 + eta_h2_bar*e1)) * vH ...
        - mean(nanmean(1+eta_h2_w2 + eta_h2_bar*e2)) * vHW ;
end %higher_moments == -1

%   Intertemporal co-variances:
mom_wHyW_a = smoms(12) + eta_h2_w1 * uH + (1+eta_h2_w2) * uHW ;
mom_wHyW_b = smoms(13) + eta_h2_w1 * uH + (1+eta_h2_w2) * uHW ;


%   Matrix 37: E[DwW DyW]   
%   -----------------------------------------------------------------------

%   Contemporaneous covariance:
if higher_moms == -1 
mom_wWyW = smoms_bps(4) - eta_h2_w1 * (uHW + uHW) ...
        - (1+eta_h2_w2) * (uW + uW) ...
        - mean(nanmean(eta_h2_w1 + eta_h2_bar*e1)) * vHW ...
        - mean(nanmean(1+eta_h2_w2 + eta_h2_bar*e2)) * vW ;
end %higher_moments == -1

%   Intertemporal co-variances:
mom_wWyW_a = smoms(14) + eta_h2_w1 * uHW + (1+eta_h2_w2) * uW ; 
mom_wWyW_b = smoms(15) + eta_h2_w1 * uHW + (1+eta_h2_w2) * uW ;


%   Matrix 19: E[DwH Dc]   
%   -----------------------------------------------------------------------

%   Contemporaneous covariance:
if higher_moms == -1
mom_wHc = smoms_bps(5) - eta_c_w1 * (uH + uH) ...
        - eta_c_w2 * (uHW + uHW) ...
        - mean(nanmean(eta_c_w1 + eta_c_bar*e1)) * vH ...
        - mean(nanmean(eta_c_w2 + eta_c_bar*e2)) * vHW ;
end %higher_moments == -1

%   Intertemporal co-variances:
mom_wHc_a = smoms(16) + eta_c_w1 * uH + eta_c_w2 * uHW ;
mom_wHc_b = smoms(17) + eta_c_w1 * uH + eta_c_w2 * uHW ;


%   Matrix 39: E[DwW Dc]   
%   -----------------------------------------------------------------------

%   Contemporaneous covariance:
if higher_moms == -1
mom_wWc = smoms_bps(6) - eta_c_w1 * (uHW + uHW) ...
        - eta_c_w2 * (uW + uW) ...
        - mean(nanmean(eta_c_w1 + eta_c_bar*e1)) * vHW ...
        - mean(nanmean(eta_c_w2 + eta_c_bar*e2)) * vW ;
end %higher_moments == -1

%   Intertemporal co-variances:
mom_wWc_a = smoms(18) + eta_c_w1 * uHW + eta_c_w2 * uW ;
mom_wWc_b = smoms(19) + eta_c_w1 * uHW + eta_c_w2 * uW ;


%%  4.  SECOND MOMENTS PREFERENCES - SECOND MOMENTS WAGES
%   Construct vector of moments E(data_moment_i - model_moment_i) = 0
%   -----------------------------------------------------------------------

%   Matrix 55: E[DyH DyH]   
%   -----------------------------------------------------------------------

%   Contemporaneous covariance:
if higher_moms == -1
mom_yHyH = smoms_bps(7) ...
        - (1 + eta_h1_w1)^2 * (uH + uH) ...
        - 2*(1 + eta_h1_w1) * eta_h1_w2 * (uHW + uHW) ...
        - eta_h1_w2^2 * (uW + uW) ...
        - mean(nanmean((1 + eta_h1_w1 + eta_h1_bar*e1).^2)) * vH ...
        - 2*mean(nanmean((1 + eta_h1_w1 + eta_h1_bar*e1).*(eta_h1_w2 + eta_h1_bar*e2))) * vHW ...
        - mean(nanmean((eta_h1_w2 + eta_h1_bar*e2).^2)) * vW ;
end %higher_moments == -1

%   Intertemporal co-variances:
mom_yHyH_a = smoms(20) ...
        + (1 + Veta_h1_w1 + eta_h1_w1^2 + 2*eta_h1_w1) * uH ...
        + 2*(eta_h1_w2 + COVeta_h1_w1_h1_w2 + eta_h1_w1*eta_h1_w2) * uHW ...
        + (Veta_h1_w2 + eta_h1_w2^2) * uW ;


%   Matrix 57: E[DyH DyW]   
%   -----------------------------------------------------------------------

%   Contemporaneous covariance:
if higher_moms == -1
mom_yHyW = smoms_bps(8) ...
        - (1 + eta_h1_w1) * eta_h2_w1 * (uH + uH) ...
        - (1 + eta_h1_w1) * (1 + eta_h2_w2) * (uHW + uHW) ...
        - eta_h1_w2*eta_h2_w1 * (uHW + uHW) ...
        - eta_h1_w2*(1 + eta_h2_w2) * (uW + uW) ...
        - mean(nanmean((1 + eta_h1_w1 + eta_h1_bar*e1) .* (eta_h2_w1 + eta_h2_bar*e1))) * vH ...
        - mean(nanmean((1 + eta_h1_w1 + eta_h1_bar*e1) .* (1 + eta_h2_w2 + eta_h2_bar*e2))) * vHW ...
        - mean(nanmean((eta_h1_w2 + eta_h1_bar*e2) .* (eta_h2_w1 + eta_h2_bar*e1))) * vHW ...
        - mean(nanmean((eta_h1_w2 + eta_h1_bar*e2) .* (1 + eta_h2_w2 + eta_h2_bar*e2))) * vW ;
end %higher_moments == -1

%   Intertemporal co-variances:
mom_yHyW_a = smoms(21) ...
        + (eta_h2_w1 + COVeta_h1_w1_h2_w1 + eta_h1_w1*eta_h2_w1) * uH ...
        + (1 + eta_h1_w1 + eta_h2_w2 + COVeta_h1_w1_h2_w2 + eta_h1_w1*eta_h2_w2) * uHW ...
        + (COVeta_h1_w2_h2_w1 + eta_h1_w2*eta_h2_w1) * uHW ...
        + (eta_h1_w2 + COVeta_h1_w2_h2_w2 + eta_h1_w2*eta_h2_w2) * uW ;

mom_yHyW_b = smoms(22) ...
        + (eta_h2_w1 + COVeta_h1_w1_h2_w1 + eta_h1_w1*eta_h2_w1) * uH ...
        + (1 + eta_h1_w1 + eta_h2_w2 + COVeta_h1_w1_h2_w2 + eta_h1_w1*eta_h2_w2) * uHW ...
        + (COVeta_h1_w2_h2_w1 + eta_h1_w2*eta_h2_w1) * uHW ...
        + (eta_h1_w2 + COVeta_h1_w2_h2_w2 + eta_h1_w2*eta_h2_w2) * uW ;


%   Matrix 77: E[DyW DyW]   
%   -----------------------------------------------------------------------

%   Contemporaneous covariance:
if higher_moms == -1
mom_yWyW = smoms_bps(9) ...
        - eta_h2_w1^2 * (uH + uH) ...
        - 2*eta_h2_w1*(1+eta_h2_w2) * (uHW + uHW) ...
        - (1 + eta_h2_w2)^2 * (uW + uW) ...
        - mean(nanmean((eta_h2_w1 + eta_h2_bar*e1).^2)) * vH ...
        - 2*mean(nanmean((eta_h2_w1 + eta_h2_bar*e1).*(1 + eta_h2_w2 + eta_h2_bar*e2))) * vHW ...
        - mean(nanmean((1 + eta_h2_w2 + eta_h2_bar*e2).^2)) * vW ;
end %higher_moments == -1

%   Intertemporal co-variances:
mom_yWyW_a = smoms(23) ...
        + (Veta_h2_w1 + eta_h2_w1^2) * uH ...
        + 2*(eta_h2_w1 + COVeta_h2_w1_h2_w2 + eta_h2_w1*eta_h2_w2) * uHW ...
        + (1 + Veta_h2_w2 + eta_h2_w2^2 + 2*eta_h2_w2) * uW ;


%   Matrix 59: E[DyH Dc]   
%   -----------------------------------------------------------------------

%   Contemporaneous covariance:
if higher_moms == -1 
mom_yHc = smoms_bps(10) ...
        - (1 + eta_h1_w1) * eta_c_w1 * (uH + uH) ...
        - (1 + eta_h1_w1) * eta_c_w2 * (uHW + uHW) ...
        - eta_h1_w2 * eta_c_w1 * (uHW + uHW) ...
        - eta_h1_w2 * eta_c_w2 * (uW + uW) ...
        - mean(nanmean((1 + eta_h1_w1 + eta_h1_bar*e1) .* (eta_c_w1 + eta_c_bar*e1))) * vH ...
        - mean(nanmean((1 + eta_h1_w1 + eta_h1_bar*e1) .* (eta_c_w2 + eta_c_bar*e2))) * vHW ...
        - mean(nanmean((eta_h1_w2 + eta_h1_bar*e2) .* (eta_c_w1 + eta_c_bar*e1))) * vHW ...
        - mean(nanmean((eta_h1_w2 + eta_h1_bar*e2) .* (eta_c_w2 + eta_c_bar*e2))) * vW ;
end %higher_moments == -1

%   Intertemporal co-variances: 
mom_yHc_a = smoms(24) ...
        + (eta_c_w1 + COVeta_c_w1_h1_w1 + eta_c_w1*eta_h1_w1) * uH ...
        + (eta_c_w2 + COVeta_c_w2_h1_w1 + eta_c_w2*eta_h1_w1) * uHW ...
        + (COVeta_c_w1_h1_w2 + eta_c_w1*eta_h1_w2) * uHW ...
        + (COVeta_c_w2_h1_w2 + eta_c_w2*eta_h1_w2) * uW ;

mom_yHc_b = smoms(25) ...
        + (eta_c_w1 + COVeta_c_w1_h1_w1 + eta_c_w1*eta_h1_w1) * uH ...
        + (eta_c_w2 + COVeta_c_w2_h1_w1 + eta_c_w2*eta_h1_w1) * uHW ...
        + (COVeta_c_w1_h1_w2 + eta_c_w1*eta_h1_w2) * uHW ...
        + (COVeta_c_w2_h1_w2 + eta_c_w2*eta_h1_w2) * uW ;


%   Matrix 79: E[DyW Dc]   
%   -----------------------------------------------------------------------

%   Contemporaneous covariance:
if higher_moms == -1 
mom_yWc = smoms_bps(11) ...
        - eta_h2_w1 * eta_c_w1 * (uH + uH) ...
        - eta_h2_w1 * eta_c_w2 * (uHW + uHW) ...
        - (1 + eta_h2_w2) * eta_c_w1 * (uHW + uHW) ...
        - (1 + eta_h2_w2) * eta_c_w2 * (uW + uW) ...
        - mean(nanmean((eta_h2_w1 + eta_h2_bar*e1) .* (eta_c_w1 + eta_c_bar*e1))) * vH ...
        - mean(nanmean((eta_h2_w1 + eta_h2_bar*e1) .* (eta_c_w2 + eta_c_bar*e2))) * vHW ...
        - mean(nanmean((1 + eta_h2_w2 + eta_h2_bar*e2) .* (eta_c_w1 + eta_c_bar*e1))) * vHW ...
        - mean(nanmean((1 + eta_h2_w2 + eta_h2_bar*e2) .* (eta_c_w2 + eta_c_bar*e2))) * vW ;
end %higher_moments == -1

%   Intertemporal co-variances:
mom_yWc_a = smoms(26) ...
        + (COVeta_c_w1_h2_w1 + eta_c_w1*eta_h2_w1) * uH ...
        + (COVeta_c_w2_h2_w1 + eta_c_w2*eta_h2_w1) * uHW ...
        + (eta_c_w1 + COVeta_c_w1_h2_w2 + eta_c_w1*eta_h2_w2) * uHW ...
        + (eta_c_w2 + COVeta_c_w2_h2_w2 + eta_c_w2*eta_h2_w2) * uW ;

mom_yWc_b = smoms(27) ...
        + (COVeta_c_w1_h2_w1 + eta_c_w1*eta_h2_w1) * uH ...
        + (COVeta_c_w2_h2_w1 + eta_c_w2*eta_h2_w1) * uHW ...
        + (eta_c_w1 + COVeta_c_w1_h2_w2 + eta_c_w1*eta_h2_w2) * uHW ...
        + (eta_c_w2 + COVeta_c_w2_h2_w2 + eta_c_w2*eta_h2_w2) * uW ;


%   Matrix 99: E[Dc Dc]   
%   -----------------------------------------------------------------------

%   Contemporaneous covariance:
if higher_moms == -1 
mom_cc = smoms_bps(12) - 2*Vcons_err ...
        - eta_c_w1^2 * (uH + uH) ...
        - 2*eta_c_w1*eta_c_w2 * (uHW + uHW) ...
        - eta_c_w2^2 * (uW + uW) ...
        - mean(nanmean((eta_c_w1 + eta_c_bar*e1).^2)) * vH ...
        - 2*mean(nanmean((eta_c_w1 + eta_c_bar*e1) .* (eta_c_w2 + eta_c_bar*e2))) * vHW ...
        - mean(nanmean((eta_c_w2 + eta_c_bar*e2).^2)) * vW ;
end %higher_moments == -1

%   Intertemporal co-variance:
mom_cc_a = smoms(28) ...
        + (Veta_c_w1 + eta_c_w1^2) * uH ...
        + 2*(COVeta_c_w1_c_w2 + eta_c_w1*eta_c_w2) * uHW ...
        + (Veta_c_w2 + eta_c_w2^2) * uW ;


%%  5.  STACK MOMENTS TOGETHER; CHOOSE WEIGHTING MATRIX
%   Stack vectors of moments together; choose GMM weighting matrix
%   -----------------------------------------------------------------------

%   Stack together:
vMoms = [       mom_wHyH_a     ; ...    %
                mom_wHyH_b     ; ...    %
                mom_wWyH_a     ; ...    %
                mom_wWyH_b     ; ...    %
                mom_wHyW_a     ; ...    %
                mom_wHyW_b     ; ...    %
                mom_wWyW_a     ; ...    %
                mom_wWyW_b     ; ...    %
                mom_wHc_a      ; ...    %
                mom_wHc_b      ; ...    %
                mom_wWc_a      ; ...    %
                mom_wWc_b      ; ...    %   
                mom_yHyH_a     ; ...    %
                mom_yHyW_a     ; ...
                mom_yHyW_b     ; ...
                mom_yWyW_a     ; ...    %
                mom_yHc_a      ; ...    %
                mom_yHc_b      ; ...    %
                mom_yWc_a      ; ...    %
                mom_yWc_b      ; ...    %
                mom_cc_a ]     ;        %
    
if      higher_moms == -1
    vtMoms = [  mom_wHyH     ; ...      %
                mom_wWyH     ; ...      %
                mom_wHyW     ; ...      %
                mom_wWyW     ; ...      %
                mom_wHc      ; ...      %
                mom_wWc      ; ...      %
                mom_yHyH     ; ...      %
                mom_yHyW     ; ...      %
                mom_yWyW     ; ...      %
                mom_yHc      ; ...      %
                mom_yWc      ; ...      %
                mom_cc ]     ;          %
    vMoms = [vMoms;vtMoms] ;
end %higher_moments == -1

%   Declare appropriate weighting matrix (equally weighted GMM):  
wmatrix = eye(size(vMoms,1)) ;


%%  9.  DELIVER CRITERION OBJECTIVE FUNCTION
%   -----------------------------------------------------------------------

%   Objective function criterion:
f = vMoms' * wmatrix * vMoms ;