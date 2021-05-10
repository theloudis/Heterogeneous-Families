function f = wage_structure_wk(vParams, smoms)
%{
    This function generates the moment conditions for the estimation of 
    the second moments of the wage process.

    Alexandros Theloudis
    -----------------------------------------------------------------------
%}

%%  1.  INITIALIZE OBJECTS
%   Initialize parameters and vectors to hold moments
%   -----------------------------------------------------------------------

%   Vectors of second moments of shocks:
vH  = vParams(1) ;   % variance:    permanent shock HD
uH  = vParams(2) ;   % variance:    transitory shock HD
vW  = vParams(3) ;   % variance:    permanent shock WF
uW  = vParams(4) ;   % variance:    transitory shock WF
vHW = vParams(5) ;   % covariance:  permanent shocks
uHW = vParams(6) ;   % covariance:  transitory shocks


%%  2.  SECOND MOMENTS OF WAGES
%   Construct vector of moments E(data_moment_i - model_moment_i) = 0
%   -----------------------------------------------------------------------

%   Matrix 11: E[DwH DwH]   
%   -----------------------------------------------------------------------

%   Variances:
mom_wHwH        = smoms(1) - vH - uH - uH ;
    
%   Intertemporal covariances:
mom_wHwH_a      = smoms(2) + uH ;


%   Matrix 13: E[DwH DwW]   
%   -----------------------------------------------------------------------

%   Auto-covariances:
mom_wHwW        = smoms(3) - vHW - uHW - uHW ;
    
%   Intertemporal covariances: 
mom_wHwW_a      = smoms(4) + uHW ;
mom_wHwW_b      = smoms(5) + uHW ; 


%   Matrix 33: E[DwW DwW]   
%   -----------------------------------------------------------------------

%   Variances:
mom_wWwW        = smoms(6) - vW - uW - uW ;
    
%   Intertemporal covariances:
mom_wWwW_a      = smoms(7) + uW ;


%%  3.  CHOOSE WEIGHTING MATRIX AND STACK MOMENTS TOGETHER
%   Choose GMM weighting matrix; stack vectors of moments together.
%   -----------------------------------------------------------------------

%   Declare appropriate weighting matrix (equally weighted GMM) and
%   stack moments together:
vMoms = [   mom_wHwH    ; ...      
            mom_wHwH_a  ; ...
           	mom_wHwW    ; ...
           	mom_wHwW_a  ; ...
          	mom_wHwW_b  ; ...
          	mom_wWwW    ; ...
          	mom_wWwW_a] ;
    
%   Declare matrix:
wmatrix = eye(size(vMoms,1)) ;


%%  4.  DELIVER CRITERION OBJECTIVE FUNCTION
%   -----------------------------------------------------------------------

%   Objective function criterion:
f = vMoms' * wmatrix * vMoms ;