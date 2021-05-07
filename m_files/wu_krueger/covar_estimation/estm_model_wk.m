function [modelhat,modelfval,modelflag] = ...
    estm_model_wk(what, smoms, smoms_bps, eta_c_p, mCEs, mCPi, mCAvg, full_opt_displ, moms)
%{ 
    This function estimates the structural model with and without 
    unobserved preference heterogeneity.

    Alexandros Theloudis
    -----------------------------------------------------------------------
%}

%%  1.  ESTIMATION ATTRIBUTES
%   Declare estimation features and initial parameter values
%   -----------------------------------------------------------------------

%   Estimation features:
full_opt_alg       = 'interior-point' ;
full_opt_contol    = 1e-6 ;
full_opt_funtol    = 1e-6 ;
full_opt_grdtol    = 1e-6 ;
full_opt_maxfunevl = 1e+5 ;
full_opt_maxiter   = 1000 ;

%   Declare initial values for default parameters:
x0  = [  -0.1           % eta_c_w1              : E[consumption wrt wage1]  1
         -0.1           % eta_c_w2              : E[consumption wrt wage2]  2
          0.4           % eta_h1_w1             : E[hours1 wrt wage1]       3
          0.0           % eta_h1_w2             : E[hours1 wrt wage2]       4
          0.0           % eta_h2_w1             : E[hours2 wrt wage1]       5
          0.7 ];        % eta_h2_w2             : E[hours2 wrt wage2]       6
%   -add parameters if BPS specification is estimated:
if moms == -1
    xM  = [ 0.3         % eta_h1_p              : E[hours1 wrt price]       7
            0.3];       % eta_h2_p              : E[hours2 wrt price]       8
    x0  = [x0;xM] ;
end

%   Declare bounds on default parameters:
xb   = [-1.5  1.5 ;      % eta_c_w1      
        -1.5  1.5 ;      % eta_c_w2   
         0.0  2.0 ;      % eta_h1_w1     % 0 lower bound if you want strictly non-zero labor supply elasticities (main specification)
        -1.0  1.0 ;      % eta_h1_w2 
    	-1.0  1.0 ;      % eta_h2_w1 
     	 0.0  2.0];      % eta_h2_w2     % 0 lower bound if you want strictly non-zero labor supply elasticities (main specification)

%   -add bounds if BPS specification is estimated:
if moms == -1
    xbM  = [  -1.0  1.0 ;       % eta_h1_p 
              -1.0  1.0] ;      % eta_h2_p
    xb  = [xb;xbM] ;     
end

%   Declare minimum and maximum bounds:       
xmin = xb(:,1);
xmax = xb(:,2);


%%  2.  IMPLEMENT GMM ESTIMATION OF STRUCTURAL MODEL
%   Define estimation features and implement GMM estimation
%   -----------------------------------------------------------------------

%   Define linear equality constraints on parameters:
[Aeq,beq] = model_eqcons_wk(x0, mCAvg, moms) ;

%   Define options set:
fminconopt = optimoptions('fmincon','Algorithm',full_opt_alg,'ConstraintTolerance',full_opt_contol,'Display',full_opt_displ,'OptimalityTolerance',full_opt_grdtol, ...
    'FunctionTolerance',full_opt_funtol,'MaxFunctionEvaluations',full_opt_maxfunevl,'MaxIterations',full_opt_maxiter) ;

%   Implement GMM estimation:
[modelhat,modelfval,modelflag] = fmincon(@(x) model_structure_wk(x, what, smoms, smoms_bps, eta_c_p, mCEs, mCPi, moms), ...
    x0,[],[],Aeq,beq,xmin,xmax,[],fminconopt) ;

end