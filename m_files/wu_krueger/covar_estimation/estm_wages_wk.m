function [what,wfval,wflag] = estm_wages_wk(smoms, wage_opt_displ)
%{  
    This function estimates the second moments of the wage processes 
    of men and women in the household.
   
    Alexandros Theloudis
    -----------------------------------------------------------------------
%}

%%  1.  ESTIMATION ATTRIBUTES
%   Declare estimation features and initial parameter values
%   -----------------------------------------------------------------------

%   Estimation features:
wage_opt_alg            = 'interior-point' ;
wage_opt_contol         = 1e-6 ;
wage_opt_funtol         = 1e-6 ;
wage_opt_maxfunevl      = 6e+4 ;
wage_opt_maxiter        = 1000 ;

%   Declare initial parameter values (a max total of 6 parameters):
x0 = [     0.05 ; ... % vH    (1)          
           0.03 ; ... % uH    (2)    
           0.05 ; ... % vW    (3)    
           0.03 ; ... % uW    (4)  
           0.01 ; ... % vHW   (5)
           0.01];     % uHW   (6)      
  
%   Declare parameter bounds:
xmin = [   0.0 ; ... % vH           
           0.0 ; ... % uH       
           0.0 ; ... % vW    
           0.0 ; ... % uW    
          -0.1 ; ... % vHW   
          -0.1] ;    % uHW   
xmax = [   1.0 ; ... % vH        
           1.0 ; ... % uH     
           1.0 ; ... % vW      
           1.0 ; ... % uW     
           0.1 ; ... % vHW   
           0.1];     % uHW     

              
%%  2.  IMPLEMENT GMM ESTIMATION OF WAGE PROCESS
%   Define estimation features and implement GMM estimation
%   -----------------------------------------------------------------------

%   Define options set:
fminconopt = optimoptions('fmincon','Algorithm',wage_opt_alg,'ConstraintTolerance',wage_opt_contol,'Display',wage_opt_displ,...
    'FunctionTolerance',wage_opt_funtol,'MaxFunctionEvaluations',wage_opt_maxfunevl,'MaxIterations',wage_opt_maxiter) ;

%   Implement GMM optimisation:
[what,wfval,wflag] = fmincon(@(x) wage_structure_wk(x, smoms), ...
    x0,[],[],[],[],xmin,xmax,[],fminconopt) ;

end