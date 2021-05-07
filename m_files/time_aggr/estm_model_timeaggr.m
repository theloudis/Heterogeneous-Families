function [modelhat,modelfval,modelflag] = estm_model_timeaggr(what, empirical_moments, mCAvg, full_opt_displ, moments, pref_heterogeneity, ...
                                            labor_xeta, type_wmatrix, months_in_year, phi_matrix)
%{ 
    This function estimates the preferred specification of the structural 
    model addressing neglected time aggregation in the PSID.

   Alexandros Theloudis
    -----------------------------------------------------------------------
%}

%	Assert that the code is asked to run a specification that is designed
%   for -- Essentially I only address time aggregation using the preferred
%   model specification rather than other model versions. 
if moments==-1 || (pref_heterogeneity>=2 && pref_heterogeneity<7) || pref_heterogeneity>7 || isequal(labor_xeta,'on')
	error("The code cannot run this specification in this context.")
end


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

%   Determine proportionality of consumption elasticities in the preferred
%   specifications. Depending on whether I carry out equally or diagonally
%   weighted GMM, I choose a slightly different proportionality in order
%   to better reflect the unconstrained variance estimates:
if isequal(type_wmatrix,'eye')
    propc = 1.6 ;   % Eq.GMM
else                                    
    propc = 1.9 ;   % Diag.GMM
end

%   Declare initial values for default parameters:
x0  = [  -0.1           % eta_c_w1              : E[consumption wrt wage1]
         -0.1           % eta_c_w2              : E[consumption wrt wage2]
          0.3           % eta_h1_w1             : E[hours1 wrt wage1]
          0.4 ];        % eta_h2_w2             : E[hours2 wrt wage2]

%   Declare parameters for other specifications:               
%   Restricted preference heterogeneity:    
if  pref_heterogeneity == 1
        
  	xA0 = [ 0.2     % Veta_c_w1             : V[consumption wrt wage1] 
         	0.4     % Veta_c_w2             : V[consumption wrt wage2] 
          	0.01    % Veta_h1_w1            : V[hours1 wrt wage1] 
          	0.1 ];  % Veta_h2_w2            : V[hours2 wrt wage2] 
    x0 = [x0;xA0] ;
        
%   Preferred specification:    
elseif  pref_heterogeneity == 7
        
 	xB0 = [ 0.2     % Veta_c_w1             : V[consumption wrt wage1] 
            0.4     % Veta_c_w2             : V[consumption wrt wage2]
           	0.1     % Veta_h1_w1            : V[hours1 wrt wage1] 
          	0.01    % Veta_h2_w2            : V[hours2 wrt wage2] 
        	0.0     % COVeta_c_w1_c_w2      : Cov[consumption wrt wage1, consumption wrt wage2] 
           	0.0     % COVeta_c_w1_h1_w1     : Cov[consumption wrt wage1, hours1 wrt wage1] 
           	0.0     % COVeta_c_w1_h2_w2     : Cov[consumption wrt wage1, hours2 wrt wage2] 
        	0.0     % COVeta_c_w2_h1_w1     : Cov[consumption wrt wage2, hours1 wrt wage1] 
          	0.0     % COVeta_c_w2_h2_w2     : Cov[consumption wrt wage2, hours2 wrt wage2] 
           	0.0];   % COVeta_h1_w1_h2_w2    : Cov[hours1 wrt wage1, hours2 wrt wage2]
  	x0 = [x0;xB0;propc] ;   % fix proportional consumption elasticities:
end %pref_heterogeneity

%   Declare bounds on default parameters:
xb   = [  -1.5  1.5 ;       % eta_c_w1      
          -1.5  1.5 ;       % eta_c_w2   
          -1.0  1.5 ;       % eta_h1_w1     % 0 lower bound if you want strictly non-zero labor supply elasticities (main specification) 
          -1.0  2.0];       % eta_h2_w2     % 0 lower bound if you want strictly non-zero labor supply elasticities (main specification)
  
%   Declare bounds for other specifications:               
%   Restricted preference heterogeneity:    
if  pref_heterogeneity == 1
        
 	xbA = [ 0.0  1.5 ;      % Veta_c_w1   
        	0.0  1.5 ;      % Veta_c_w2 
         	0.0  1.5 ;      % Veta_h1_w1  
          	0.0  1.5 ];     % Veta_h2_w2
    xb = [xb;xbA] ;
    
%   Ppreferred specification:     
elseif  pref_heterogeneity == 7
        
  	xbB = [ 0.0  1.5 ;      % Veta_c_w1   
          	0.0  1.5 ;      % Veta_c_w2 
         	0.0  1.5 ;      % Veta_h1_w1   
           	0.0  1.5 ;      % Veta_h2_w2
           -1.5  1.5 ;      % COVeta_c_w1_c_w2 
           -1.5  1.5 ;      % COVeta_c_w1_h1_w1
           -1.5  1.5 ;      % COVeta_c_w1_h2_w2
           -1.5  1.5 ;      % COVeta_c_w2_h1_w1
           -1.5  1.5 ;      % COVeta_c_w2_h2_w2 
           -1.5  1.5 ];     % COVeta_h1_w1_h2_w2
    propcb = [propc  propc];% fix proportional consumption elasticities.
   	xb  = [xb;xbB;propcb] ;     
end %pref_heterogeneity

%   Declare minimum and maximum bounds:       
xmin = xb(:,1);
xmax = xb(:,2);


%%  2.  IMPLEMENT GMM ESTIMATION OF STRUCTURAL MODEL
%   Define estimation features and implement GMM estimation
%   -----------------------------------------------------------------------

%   Define nonlinear constraints. Constraints are not active if preference
%   heterogeneity is completely shut down:
nleqcons = @(x) model_nlcons(x,mCAvg,pref_heterogeneity,labor_xeta) ;

%   Define options set:
fminconopt = optimoptions('fmincon','Algorithm',full_opt_alg,'ConstraintTolerance',full_opt_contol,'Display',full_opt_displ,'OptimalityTolerance',full_opt_grdtol, ...
    'FunctionTolerance',full_opt_funtol,'MaxFunctionEvaluations',full_opt_maxfunevl,'MaxIterations',full_opt_maxiter) ;

%   Implement GMM estimation: 
[modelhat,modelfval,modelflag] = fmincon(@(x) model_structure_timeaggr(x, what, moments, pref_heterogeneity, ...
                                 type_wmatrix, months_in_year, empirical_moments, phi_matrix), x0,[],[],[],[],xmin,xmax,nleqcons,fminconopt) ;
end