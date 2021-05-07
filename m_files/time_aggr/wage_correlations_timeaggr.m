function [c,ceq]=wage_correlations_timeaggr(vParams)
%{  
    This function calculates the correlation of wage shocks between 
    partners in the household. It delivers:

    c       a vector of nonlinear inequalities c(x)<=0
    ceq     a vector of nonlinear equalities ceq(x)=0

    (C) Alexandros Theloudis, LISER & UCL, 2016-19

    -----------------------------------------------------------------------
%}

%   Declare parameters:
vH   = vParams(1) ;   % variance:    permanent shock HD
uH   = vParams(2) ;   % variance:    transitory shock HD
vW   = vParams(3) ;   % variance:    permanent shock WF
uW   = vParams(4) ;   % variance:    transitory shock WF
vHW  = vParams(5) ;   % covariance:  permanent shocks
uHW  = vParams(6) ;   % covariance:  ransitory shocks
rvHW = vParams(7) ;   % correlation: permanent shocks
ruHW = vParams(8) ;   % correlation: transitory shocks


%%  1.  INEQUALITY CONSTRAINTS
%   Declare nonlinear inequality constraints c(x)<=0
%   -----------------------------------------------------------------------

c = [] ;


%%  2.  EQUALITY CONSTRAINTS
%   Declare nonlinear equality constraints ceq(x)=0
%   -----------------------------------------------------------------------

%   Declare vector of nonlinear equality constraint:
%   (1 correlation of perm shocks and 1 correlation of trans shocks)
ceq = zeros(2,1) ;

%   Populate the vector of nonlinear constraints:
ceq(1) = rvHW - vHW / (sqrt(vH*vW)) ;
ceq(2) = ruHW - uHW / (sqrt(uH*uW));


end