function [what,wfval,wflag] = estm_wages(mC,mCD,merrC,wage_opt_displ,do_higher_moments,type_wmatrix)
%{  
    This function estimates second and higher moments of the wage process 
    of men and women in the household.
   
    Alexandros Theloudis
    -----------------------------------------------------------------------
%}

%   Initial statements:
global  T stationary_wage_params ;


%%  1.  ESTIMATION ATTRIBUTES
%   Declare estimation features and initial parameter values
%   -----------------------------------------------------------------------

%   Estimation features:
wage_opt_alg            = 'interior-point' ;
wage_opt_contol         = 1e-6 ;
wage_opt_funtol         = 1e-6 ;
wage_opt_maxfunevl      = 6e+4 ;
wage_opt_maxiter        = 1000 ;

%   Declare initial parameter values (a max total of 88 parameters):
x0 = [     0.05 * ones(T-2,1) ; ... % vH    (1:5)          
           0.03 * ones(T-1,1) ; ... % uH    (6:11)    
           0.05 * ones(T-2,1) ; ... % vW    (12:16)    
           0.03 * ones(T-1,1) ; ... % uW    (17:22)  
           0.01 * ones(T-2,1) ; ... % vHW   (23:27)
           0.01 * ones(T-1,1) ; ... % uHW   (28:33)
           0.1  * ones(T-2,1) ; ... % rvHW  (34:38)
           0.1  * ones(T-1,1)]; ... % ruHW  (39:44)
if do_higher_moments >= 1
x30 = [    0.00 * ones(T-2,1) ; ... % gvH   (45:49)          
           0.00 * ones(T-1,1) ; ... % guH   (50:55)    
           0.00 * ones(T-2,1) ; ... % gvW   (56:60)    
           0.00 * ones(T-1,1) ; ... % guW   (61:66) 
           0.00 * ones(T-2,1) ; ... % gvH2W (67:71)
           0.00 * ones(T-1,1) ; ... % guH2W (72:77)
           0.00 * ones(T-2,1) ; ... % gvHW2 (78:82)
           0.00 * ones(T-1,1)]; ... % guHW2 (83:88)
x0 = [x0;x30] ;
end       
  
%   Declare parameter bounds:
xmin = [   0.0 * ones(T-2,1)  ; ... % vH    (1:5)          
           0.0 * ones(T-1,1)  ; ... % uH    (6:11)    
           0.0 * ones(T-2,1)  ; ... % vW    (12:16)    
           0.0 * ones(T-1,1)  ; ... % uW    (17:22)  
          -0.1 * ones(T-2,1)  ; ... % vHW   (23:27)
          -0.1 * ones(T-1,1)  ; ... % uHW   (28:33)
          -1.0 * ones(T-2,1)  ; ... % rvHW  (34:38)
          -1.0 * ones(T-1,1)] ; ... % ruHW  (39:44)
if do_higher_moments >= 1
x3min = [ -0.5 * ones(T-2,1)  ; ... % gvH   (45:49)          
          -0.5 * ones(T-1,1)  ; ... % guH   (50:55)    
          -0.5 * ones(T-2,1)  ; ... % gvW   (56:60)    
          -0.5 * ones(T-1,1)  ; ... % guW   (61:66)
          -0.5 * ones(T-2,1)  ; ... % gvH2W (67:71)
          -0.5 * ones(T-1,1)  ; ... % guH2W (72:77)
          -0.5 * ones(T-2,1)  ; ... % gvHW2 (78:82)
          -0.5 * ones(T-1,1)] ; ... % guHW2 (83:88)
xmin = [xmin;x3min] ;
end

xmax = [   1.0 * ones(T-2,1)  ; ... % vH    (1:5)          
           1.0 * ones(T-1,1)  ; ... % uH    (6:11)    
           1.0 * ones(T-2,1)  ; ... % vW    (12:16)    
           1.0 * ones(T-1,1)  ; ... % uW    (17:22)  
           0.1 * ones(T-2,1)  ; ... % vHW   (23:27)
           0.1 * ones(T-1,1)  ; ... % uHW   (28:33)
           1.0 * ones(T-2,1)  ; ... % rvHW  (34:38)
           1.0 * ones(T-1,1)] ; ... % ruHW  (39:44)
if do_higher_moments >= 1
x3max = [  0.5 * ones(T-2,1)  ; ... % gvH   (45:49)          
           0.5 * ones(T-1,1)  ; ... % guH   (50:55)    
           0.5 * ones(T-2,1)  ; ... % gvW   (56:60)    
           0.5 * ones(T-1,1)  ; ... % guW   (61:66)     
           0.5 * ones(T-2,1)  ; ... % gvH2W (67:71)
           0.5 * ones(T-1,1)  ; ... % guH2W (72:77)
           0.5 * ones(T-2,1)  ; ... % gvHW2 (78:82)
           0.5 * ones(T-1,1)] ; ... % guHW2 (83:88)
xmax = [xmax;x3max] ;
end


              
%%  2.  IMPLEMENT GMM ESTIMATION OF WAGE PROCESS
%   Define estimation features and implement GMM estimation
%   -----------------------------------------------------------------------

%   Define equality constraints:
if      stationary_wage_params == 0
    Aeq = [] ;
    beq = [] ;
elseif  stationary_wage_params == 1
    [Aeq,beq] = wage_eqcons(x0,do_higher_moments) ;
else
    error('Invalid value of switch "stationary_wage_params".')
end

%   Define options set:
fminconopt = optimoptions('fmincon','Algorithm',wage_opt_alg,'ConstraintTolerance',wage_opt_contol,'Display',wage_opt_displ,...
    'FunctionTolerance',wage_opt_funtol,'MaxFunctionEvaluations',wage_opt_maxfunevl,'MaxIterations',wage_opt_maxiter) ;

%   Implement GMM optimisation:
[what,wfval,wflag] = fmincon(@(x) wage_structure(x,mC,mCD,merrC,do_higher_moments,type_wmatrix), ...
    x0,[],[],Aeq,beq,xmin,xmax,@(x) wage_correlations(x),fminconopt) ;

end