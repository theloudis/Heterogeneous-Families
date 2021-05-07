function [c,ceq]=wage_correlations(vParams)
%{  
    This function calculates the correlation of wage shocks between 
    partners in the household. It delivers:

    c       a vector of nonlinear inequalities c(x)<=0
    ceq     a vector of nonlinear equalities ceq(x)=0

    Alexandros Theloudis

    -----------------------------------------------------------------------
%}

%   Initial statements:
global T ;

%   Declare parameters:
vH   = vParams(1:5)   ;   % variance:    permanent shock HD
uH   = vParams(6:11)  ;   % variance:    transitory shock HD
vW   = vParams(12:16) ;   % variance:    permanent shock WF
uW   = vParams(17:22) ;   % variance:    transitory shock WF
vHW  = vParams(23:27) ;   % covariance:  permanent shocks
uHW  = vParams(28:33) ;   % covariance:  ransitory shocks
rvHW = vParams(34:38) ;   % correlation: permanent shocks
ruHW = vParams(39:44) ;   % correlation: transitory shocks


%%  1.  INEQUALITY CONSTRAINTS
%   Declare nonlinear inequality constraints c(x)<=0
%   -----------------------------------------------------------------------

c = [] ;


%%  2.  EQUALITY CONSTRAINTS
%   Declare nonlinear equality constraints ceq(x)=0
%   -----------------------------------------------------------------------

%   Declare vector of nonlinear equality constraint:
%   (T-2 correlations of perm shocks and T-1 correlations of trans shocks)
ceq = zeros(T-2+T-1,1) ;

%   Populate the vector of nonlinear constraints:
k1 = 1;
while k1 <= T-2     % Correlation of permanent shocks
	ceq(k1) = rvHW(k1) - vHW(k1) / (sqrt(vH(k1)*vW(k1))) ;
    k1 = k1+1 ;
end
k2 = 1;
while k2 <= T-1     % Correlation of transitory shocks
    ceq(T-2+k2) = ruHW(k2) - uHW(k2) / (sqrt(uH(k2)*uW(k2)));
    k2 = k2+1;
end


end