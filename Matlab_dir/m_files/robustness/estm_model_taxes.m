function [modelhat,modelfval,modelflag] = ...
    estm_model_taxes(what, mC, mCD, mCEs, merrC, mCAvg, full_opt_displ, moments, pref_heterogeneity, j0, cme, tax_mu)
%{ 
    This function estimates the structural model allowing for progressive
    joint taxation.

	Alexandros Theloudis
    -----------------------------------------------------------------------
%}

%   Initial statements:
global T ;


%%  1.  ESTIMATION ATTRIBUTES
%   Declare estimation features and initial parameter values
%   -----------------------------------------------------------------------

%   Estimation features:
full_opt_alg       = 'interior-point' ;
full_opt_contol    = 1e-6 ;
full_opt_funtol    = 1e-6 ;
full_opt_grdtol    = 1e-6 ;
full_opt_maxfunevl = 1e+5 ;
full_opt_maxiter   = 1500 ;

%   Request proportionality of consumption elasticities in the preferred
%   specification; equally weighted GMM used with taxes:
propc = 1.6 ;

%   Consumption measurement error in case error is fixed:
vdc = zeros(T,1);
j = 2 ;
while j <= (T-1) 
    vdc(j) = (mC(8*T+j,:).*mC(8*T+j,:)) * (mCD(8*T+j,:).*mCD(8*T+j,:))' ;
    vdc(j) = vdc(j) / (mCD(8*T+j,:)*mCD(8*T+j,:)') ;
    j = j + 1 ;
end
v_err_c = (cme/2)*mean(vdc(2:T-1)) ;

%   Declare initial values for default parameters:
x0  = [  -0.1       % eta_c_w1              : E[consumption wrt wage1]
         -0.1       % eta_c_w2              : E[consumption wrt wage2]
          0.2       % eta_h2_w1             : E[hours2 wrt wage1]
          0.4 ];    % eta_h2_w2             : E[hours2 wrt wage2]

%   Parameters depending on preference heterogeneity regime:
if  pref_heterogeneity == 1
    
    xA0 = [ 0.1     % Veta_c_w1             : V[consumption wrt wage1] 5
            0.1     % Veta_c_w2             : V[consumption wrt wage2] 6
            0.1     % Veta_h1_w1            : V[hours1 wrt wage1] 7
            0.1 ];  % Veta_h2_w2            : V[hours2 wrt wage2] 8
    x0 = [x0;xA0] ;
        
%   Preferred specification:   
elseif  pref_heterogeneity == 7
        
    xB0 = [ 0.1     % Veta_c_w1             : V[consumption wrt wage1] 5
            0.1     % Veta_c_w2             : V[consumption wrt wage2] 6
            0.1     % Veta_h1_w1            : V[hours1 wrt wage1] 7
            0.1     % Veta_h2_w2            : V[hours2 wrt wage2] 8
            0.0     % COVeta_c_w1_c_w2      : Cov[consumption wrt wage1, consumption wrt wage2] 9
            0.0     % COVeta_c_w1_h1_w1     : Cov[consumption wrt wage1, hours1 wrt wage1] 10
            0.0     % COVeta_c_w1_h2_w2     : Cov[consumption wrt wage1, hours2 wrt wage2] 11
            0.0     % COVeta_c_w2_h1_w1     : Cov[consumption wrt wage2, hours1 wrt wage1] 12
            0.0     % COVeta_c_w2_h2_w2     : Cov[consumption wrt wage2, hours2 wrt wage2] 13
            0.0 ];  % COVeta_h1_w1_h2_w2    : Cov[hours1 wrt wage1, hours2 wrt wage2] 14
    x0  = [x0;xB0;propc] ; 
end %pref_heterogeneity

%   Declare bounds on default parameters:
xb   = [  -1.5  1.5 ;       % eta_c_w1      
          -1.5  1.5 ;       % eta_c_w2   
           0.0  1.5 ;       % eta_h1_w1
           0.0  2.0];       % eta_h2_w2

%   Add bounds depending on preference heterogeneity regime:
if  pref_heterogeneity == 1
    
    xbA = [ 0.0  1.5 ;      % Veta_c_w1   
            0.0  1.5 ;      % Veta_c_w2 
            0.0  1.5 ;      % Veta_h1_w1  
            0.0  1.5];      % Veta_h2_w2
    xb = [xb;xbA] ;
    
%   Preferred specification:        
elseif  pref_heterogeneity == 7
    
    xbB = [ 0.0  1.5 ;      % Veta_c_w1   
            0.0  1.5 ;      % Veta_c_w2 
            0.0  1.5 ;      % Veta_h1_w1  
            0.0  1.5 ;      % Veta_h2_w2
           -0.2  0.2 ;      % COVeta_c_w1_c_w2 
           -0.2  0.2 ;      % COVeta_c_w1_h1_w1
           -0.2  0.2 ;      % COVeta_c_w1_h2_w2
           -0.2  0.2 ;      % COVeta_c_w2_h1_w1
           -0.2  0.2 ;      % COVeta_c_w2_h2_w2 
           -0.2  0.2];      % COVeta_h1_w1_h2_w2
    xb  = [xb;xbB;[propc propc]] ; 
end %pref_heterogeneity

%   Declare minimum and maximum bounds:       
xmin = xb(:,1) ;
xmax = xb(:,2) ;


%%  2.  IMPLEMENT GMM ESTIMATION OF STRUCTURAL MODEL
%   Define estimation features and implement GMM estimation
%   -----------------------------------------------------------------------

%   Define nonlinear constraints. Constraints are not active if preference
%   heterogeneity is completely shut down:
nleqcons = @(x) model_nlcons(x,mCAvg,pref_heterogeneity,'off') ;

%   Define (approximate) shares of male/female earnings into total household
%   earnings:
es      = mCEs(2:T,:);
AT_Es   = mean(es(es~=0)) ;
qratios = [AT_Es ; 1-AT_Es] ;

%   Define options set:
fminconopt = optimoptions('fmincon','Algorithm',full_opt_alg,'ConstraintTolerance',full_opt_contol,'Display',full_opt_displ,'OptimalityTolerance',full_opt_grdtol, ...
    'FunctionTolerance',full_opt_funtol,'MaxFunctionEvaluations',full_opt_maxfunevl,'MaxIterations',full_opt_maxiter) ;

%   Implement GMM optimisation:
[modelhat,modelfval,modelflag] = ...
    fmincon(@(x) model_structure_pref_taxes(x, what, mC, mCD, merrC, qratios, moments, pref_heterogeneity, j0, v_err_c, tax_mu), ...
    x0,[],[],[],[],xmin,xmax,nleqcons,fminconopt) ;

end