function [what,wfval,wflag] = estm_wages_timeaggr(mC,mCD,merrC,wage_opt_displ,do_higher_moments,type_wmatrix,months_in_year)
%{  
    This function estimates second and higher moments of the wage process 
    of men and women in the household, addressing neglected time 
    aggregation in the PSID.
   
    Alexandros Theloudis
    -----------------------------------------------------------------------
%}


%%  1.  ESTIMATION ATTRIBUTES
%   Declare estimation features and initial parameter values

%   I select a starting point for wages that is similar to the one I select
%   in the baseline wage estimation, only that I adjust its magnitude (as
%   well as the magnitude of the bounds) by a constant that reflects how
%   the moments of shocks in the time aggregated wage process compare to
%   those in the baseline wage process.

%   -----------------------------------------------------------------------

%   Estimation features:
wage_opt_alg            = 'interior-point' ;
wage_opt_contol         = 1e-6 ;
wage_opt_funtol         = 1e-6 ;
wage_opt_maxfunevl      = 6e+4 ;
wage_opt_maxiter        = 1000 ;

%   Declare initial parameter values (a max total of 16 parameters):
x0 = [     0.01/((1/3)*(5*months_in_year^3 + months_in_year))  ; ... % vH    (1)          
           0.01/months_in_year                                 ; ... % uH    (2)    
           0.01/((1/3)*(5*months_in_year^3 + months_in_year))  ; ... % vW    (3)    
           0.01/months_in_year                                 ; ... % uW    (4)  
           0.00/((1/3)*(5*months_in_year^3 + months_in_year))  ; ... % vHW   (5)
           0.00/months_in_year                                 ; ... % uHW   (6)
           0.0                                                 ; ... % rvHW  (7)
           0.0 ]                                               ; ... % ruHW  (8)
if do_higher_moments >= 1
x30 = [    0.00                                                ; ... % gvH   (9)          
           0.00                                                ; ... % guH   (10)    
           0.00                                                ; ... % gvW   (11)    
           0.00                                                ; ... % guW   (12) 
           0.00                                                ; ... % gvH2W (13)
           0.00                                                ; ... % guH2W (14)
           0.00                                                ; ... % gvHW2 (16)
           0.00]                                               ; ... % guHW2 (16)
x0 = [x0;x30] ;
end       
  
%   Declare parameter bounds:
xmin = [   0.0                                                 ; ... % vH    (1)          
           0.0                                                 ; ... % uH    (2)    
           0.0                                                 ; ... % vW    (3)    
           0.0                                                 ; ... % uW    (4)  
          -0.1/((1/3)*(5*months_in_year^3 + months_in_year))   ; ... % vHW   (5)
          -0.1/months_in_year                                  ; ... % uHW   (6)
          -1.0                                                 ; ... % rvHW  (7)
          -1.0]                                                ; ... % ruHW  (8)
if do_higher_moments >= 1
x3min = [ -0.5/((1/2)*(3*months_in_year^4 + months_in_year^2)) ; ... % gvH   (9)          
          -0.5/months_in_year                                  ; ... % guH   (10)    
          -0.5/((1/2)*(3*months_in_year^4 + months_in_year^2)) ; ... % gvW   (11)    
          -0.5/months_in_year                                  ; ... % guW   (12)
          -0.5/((1/2)*(3*months_in_year^4 + months_in_year^2)) ; ... % gvH2W (13)
          -0.5/months_in_year                                  ; ... % guH2W (14)
          -0.5/((1/2)*(3*months_in_year^4 + months_in_year^2)) ; ... % gvHW2 (15)
          -0.5/months_in_year]                                 ; ... % guHW2 (16)
xmin = [xmin;x3min] ;
end

xmax = [   1.0/((1/3)*(5*months_in_year^3 + months_in_year))   ; ... % vH    (1)          
           1.0/months_in_year                                  ; ... % uH    (2)    
           1.0/((1/3)*(5*months_in_year^3 + months_in_year))   ; ... % vW    (3)    
           1.0/months_in_year                                  ; ... % uW    (4)  
           0.1/((1/3)*(5*months_in_year^3 + months_in_year))   ; ... % vHW   (5)
           0.1/months_in_year                                  ; ... % uHW   (6)
           1.0                                                 ; ... % rvHW  (7)
           1.0]                                                ; ... % ruHW  (8)
if do_higher_moments >= 1
x3max = [  0.5/((1/2)*(3*months_in_year^4 + months_in_year^2)) ; ... % gvH   (9)          
           0.5/months_in_year                                  ; ... % guH   (10)    
           0.5/((1/2)*(3*months_in_year^4 + months_in_year^2)) ; ... % gvW   (11)    
           0.5/months_in_year                                  ; ... % guW   (12)     
           0.5/((1/2)*(3*months_in_year^4 + months_in_year^2)) ; ... % gvH2W (13)
           0.5/months_in_year                                  ; ... % guH2W (14)
           0.5/((1/2)*(3*months_in_year^4 + months_in_year^2)) ; ... % gvHW2 (15)
           0.5/months_in_year]                                 ; ... % guHW2 (16)
xmax = [xmax;x3max] ;
end

              
%%  2.  IMPLEMENT GMM ESTIMATION OF WAGE PROCESS
%   Define estimation features and implement GMM estimation
%   -----------------------------------------------------------------------

%   Define options set:
fminconopt = optimoptions('fmincon','Algorithm',wage_opt_alg,'ConstraintTolerance',wage_opt_contol,'Display',wage_opt_displ,...
    'FunctionTolerance',wage_opt_funtol,'MaxFunctionEvaluations',wage_opt_maxfunevl,'MaxIterations',wage_opt_maxiter) ;

%   Implement GMM optimisation:
[what,wfval,wflag] = fmincon(@(x) wage_structure_timeaggr(x,mC,mCD,merrC,do_higher_moments,type_wmatrix,months_in_year), ...
    x0,[],[],[],[],xmin,xmax,@(x) wage_correlations_timeaggr(x),fminconopt) ;

end