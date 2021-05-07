function [modelhat,modelfval,modelflag] = ...
    estm_model(what,mC,mCD,mCEs,mCPi,merrC,mCAvg,full_opt_displ,moments,pref_heterogeneity,j0,cme,labor_xeta,type_wmatrix)
%{ 
    This function estimates the structural model with and without 
    unobserved preference heterogeneity.

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
%   specification; differentiate with respect to weighting matrix used.
if isequal(type_wmatrix,'eye')
    propc = 1.6 ;   % Eq.GMM
else
    propc = 1.9 ;   % Diag.GMM
end

%   Consumption measurement error in case error is fixed:
vdc = zeros(T,1);
j = 2 ;
while j <= (T-1) 
    vdc(j) = (mC(4*T+j,:).*mC(4*T+j,:)) * (mCD(4*T+j,:).*mCD(4*T+j,:))' ;
    vdc(j) = vdc(j) / (mCD(4*T+j,:)*mCD(4*T+j,:)') ;
    j = j + 1 ;
end
v_err_c = (cme/2)*mean(vdc(2:T-1)) ;

%   Declare initial values for default parameters:
x0  = [  -0.1           % eta_c_w1              : E[consumption wrt wage1]
         -0.1           % eta_c_w2              : E[consumption wrt wage2]
          0.4           % eta_h1_w1             : E[hours1 wrt wage1]
          0.1           % eta_h1_w2             : E[hours1 wrt wage2]
          0.2           % eta_h2_w1             : E[hours2 wrt wage1]
          0.8 ];        % eta_h2_w2             : E[hours2 wrt wage2]

%   Remove labor cross-elasticities if these are not allowed for:
if isequal(labor_xeta,'off')
    x0 = [x0(1:3);x0(6)] ;
end %isequal

%   Add parameters if BPS specification is estimated:
if moments == -1
    
    xM  = [ 0.2         % eta_h1_p              : hours1 wrt price
            0.2];       % eta_h2_p              : hours2 wrt price
    x0  = [x0;xM] ;
    
%   Add parameters if new specifications are estimated:   
else 
            
    %   Restricted preference heterogeneity:    
    if  pref_heterogeneity == 1
        
        xA0 = [ 0.1     % Veta_c_w1             : V[consumption wrt wage1] 1
                0.1     % Veta_c_w2             : V[consumption wrt wage2] 2
                0.1     % Veta_h1_w1            : V[hours1 wrt wage1] 3
                0.1     % Veta_h1_w2            : V[hours1 wrt wage2] 4
                0.1     % Veta_h2_w1            : V[hours2 wrt wage1] 5
                0.1     % Veta_h2_w2            : V[hours2 wrt wage2] 6
                0.1 ];  % COVeta_h1_w2_h2_w1    : Cov[hours1 wrt wage2, hours2 wrt wage1] 7
            
        %   Remove labor cross-elasticities if these are not allowed for:
        if isequal(labor_xeta,'off') 
            xA0 = [xA0(1:3);xA0(6)] ;
        end %isequal
        x0 = [x0;xA0] ;
        
    %   Full preference heterogeneity or preferred specification:    
    elseif  pref_heterogeneity >= 2
        
        xB0 = [ 0.1     % Veta_c_w1             : V[consumption wrt wage1] 1
                0.1     % Veta_c_w2             : V[consumption wrt wage2] 2
                0.1     % Veta_h1_w1            : V[hours1 wrt wage1] 3
                0.1     % Veta_h1_w2            : V[hours1 wrt wage2] 4
                0.1     % Veta_h2_w1            : V[hours2 wrt wage1] 5
                0.1     % Veta_h2_w2            : V[hours2 wrt wage2] 6
                0.1     % COVeta_c_w1_c_w2      : Cov[consumption wrt wage1, consumption wrt wage2] 7
                0.1     % COVeta_c_w1_h1_w1     : Cov[consumption wrt wage1, hours1 wrt wage1] 8
                0.1     % COVeta_c_w1_h1_w2     : Cov[consumption wrt wage1, hours1 wrt wage2] 9
                0.1     % COVeta_c_w1_h2_w1     : Cov[consumption wrt wage1, hours2 wrt wage1] 10 
                0.1     % COVeta_c_w1_h2_w2     : Cov[consumption wrt wage1, hours2 wrt wage2] 11
                0.1     % COVeta_c_w2_h1_w1     : Cov[consumption wrt wage2, hours1 wrt wage1] 12
                0.1     % COVeta_c_w2_h1_w2     : Cov[consumption wrt wage2, hours1 wrt wage2] 13
                0.1     % COVeta_c_w2_h2_w1     : Cov[consumption wrt wage2, hours2 wrt wage1] 14
                0.1     % COVeta_c_w2_h2_w2     : Cov[consumption wrt wage2, hours2 wrt wage2] 15
                0.1     % COVeta_h1_w1_h1_w2    : Cov[hours1 wrt wage1, hours1 wrt wage2] 16
                0.1     % COVeta_h1_w1_h2_w1    : Cov[hours1 wrt wage1, hours2 wrt wage1] 17
                0.1     % COVeta_h1_w1_h2_w2    : Cov[hours1 wrt wage1, hours2 wrt wage2] 18
                0.1     % COVeta_h1_w2_h2_w1    : Cov[hours1 wrt wage2, hours2 wrt wage1] 19
                0.1     % COVeta_h1_w2_h2_w2    : Cov[hours1 wrt wage2, hours2 wrt wage2] 20
                0.1 ];  % COVeta_h2_w1_h2_w2    : Cov[hours2 wrt wage1, hours2 wrt wage2] 21
            
        %   Remove labor cross-elasticities if these are not allowed for:
        if isequal(labor_xeta,'off')
            xB0 = [xB0(1:3);xB0(6:8);xB0(11:12);xB0(15);xB0(18)] ;
        end %isequal
        x0 = [x0;xB0] ;

        % Allow proportional consumption elasticities:
        if pref_heterogeneity == 5 || pref_heterogeneity == 6
            x0  = [x0;propc] ; 
        end %pref_heterogeneity
        
        % Fix proportional consumption elasticities:
        if pref_heterogeneity == 7
            x0  = [x0;propc] ; 
        end %pref_heterogeneity
        
        % Fix proportional consumption elasticities and terminate the
        % variance/covariance of labor supply elasticities:
        if pref_heterogeneity == 8
            x0(7:8)     = 0.0; % var labor supply elasticities
            x0(10:14)   = 0.0; % covar labor supply elasticities
            x0  = [x0;propc] ; 
        end %pref_heterogeneity
        
        % Terminate the covariance of labor supply elasticities:
        if pref_heterogeneity == 10
            x0(10:14)   = 0.0; % covar labor supply elasticities
            x0  = [x0;propc] ; 
        end %pref_heterogeneity
        
    end %pref_heterogeneity
end %moments

%   Declare bounds on default parameters:
xb   = [  -1.5  1.5 ;       % eta_c_w1      
          -1.5  1.5 ;       % eta_c_w2   
          -1.0  1.5 ;       % eta_h1_w1     % 0 lower bound if you want strictly non-zero labor supply elasticities (main specification)
          -1.0  1.0 ;       % eta_h1_w2 
          -1.0  1.0 ;       % eta_h2_w1 
          -1.0  2.0];       % eta_h2_w2     % 0 lower bound if you want strictly non-zero labor supply elasticities (main specification)
        
%   Remove bounds of labor cross-elasticities if these are not allowed for:
if isequal(labor_xeta,'off')
    xb = [xb(1:3,:);xb(6,:)] ;
end %isequal

%   Add bounds if BPS specification is estimated:
if moments == -1
    
    xbM  = [  -1.0  1.0 ;       % eta_h1_p 
              -1.0  1.0] ;      % eta_h2_p
    xb  = [xb;xbM] ;
    
%   Add parameter bounds if new specifications are estimated:   
else 
        
    %   Restricted preference heterogeneity:    
    if  pref_heterogeneity == 1
        
        xbA = [ 0.0  1.5 ;      % Veta_c_w1   
                0.0  1.5 ;      % Veta_c_w2 
                0.0  1.5 ;      % Veta_h1_w1  
                0.0  1.5 ;      % Veta_h1_w2
                0.0  1.5 ;      % Veta_h2_w1 
                0.0  1.5 ;      % Veta_h2_w2
               -1.5  1.5];      % COVeta_h1_w2_h2_w1
            
        %   Remove labor cross-elasticities if these are not allowed for:
        if isequal(labor_xeta,'off')
            xbA = [xbA(1:3,:);xbA(6,:)] ;
        end %isequal
        xb = [xb;xbA] ;
    
    %   Full preference heterogeneity or preferred specification:     
    elseif  pref_heterogeneity >= 2
        
        xbB = [ 0.0  1.5 ;      % Veta_c_w1   
                0.0  1.5 ;      % Veta_c_w2 
                0.0  1.5 ;      % Veta_h1_w1  
                0.0  1.5 ;      % Veta_h1_w2
                0.0  1.5 ;      % Veta_h2_w1 
                0.0  1.5 ;      % Veta_h2_w2
               -1.5  1.5 ;      % COVeta_c_w1_c_w2 
               -1.5  1.5 ;      % COVeta_c_w1_h1_w1
               -1.5  1.5 ;      % COVeta_c_w1_h1_w2
               -1.5  1.5 ;      % COVeta_c_w1_h2_w1
               -1.5  1.5 ;      % COVeta_c_w1_h2_w2
               -1.5  1.5 ;      % COVeta_c_w2_h1_w1
               -1.5  1.5 ;      % COVeta_c_w2_h1_w2
               -1.5  1.5 ;      % COVeta_c_w2_h2_w1
               -1.5  1.5 ;      % COVeta_c_w2_h2_w2 
               -1.5  1.5 ;      % COVeta_h1_w1_h1_w2 
               -1.5  1.5 ;      % COVeta_h1_w1_h2_w1
               -1.5  1.5 ;      % COVeta_h1_w1_h2_w2
               -1.5  1.5 ;      % COVeta_h1_w2_h2_w1
               -1.5  1.5 ;      % COVeta_h1_w2_h2_w2
               -1.5  1.5 ];     % COVeta_h2_w1_h2_w2
                        
        %   Remove labor cross-elasticities if these are not allowed for:
        if isequal(labor_xeta,'off') 
            xbB = [xbB(1:3,:);xbB(6:8,:);xbB(11:12,:);xbB(15,:);xbB(18,:)] ;
        end %isequal
        xb = [xb;xbB] ;

        % Allow proportional consumption elasticities:
        if pref_heterogeneity == 5 || pref_heterogeneity == 6
            propcb = [0.1  2.5];            % proportion parameter
            xb  = [xb;propcb] ; 
        end %isequal
        
        % Fix proportional consumption elasticities:
        if pref_heterogeneity == 7
            propcb = [propc  propc];        % proportion parameter
            xb  = [xb;propcb] ; 
        end %isequal
        
        % Fix proportional consumption elasticities and terminate the
        % variance/covariance of labor supply elasticities:
        if pref_heterogeneity == 8
            xb(7:8,:)   = 0.0 ;             % var labor supply elasticities
            xb(10:14,:) = 0.0 ;             % covar labor supply elasticities
            propcb      = [propc  propc];   % proportion parameter
            xb  = [xb;propcb] ;
        end %pref_heterogeneity
        
        % Terminate the covariance of labor supply elasticities:
        if pref_heterogeneity == 10
            xb(10:14,:) = 0.0 ;             % covar labor supply elasticities
            propcb      = [propc  propc];   % proportion parameter
            xb  = [xb;propcb] ;
        end %pref_heterogeneity
        
    end %pref_heterogeneity
end %moments

%   Declare minimum and maximum bounds:       
xmin = xb(:,1);
xmax = xb(:,2);


%%  2.  IMPLEMENT GMM ESTIMATION OF STRUCTURAL MODEL
%   Define estimation features and implement GMM estimation
%   -----------------------------------------------------------------------

%   Define linear equality constraints on parameters:
[Aeq,beq] = model_eqcons(x0,mCAvg,moments,pref_heterogeneity,labor_xeta) ;

%   Define nonlinear constraints. Constraints are not active if preference
%   heterogeneity is completely shut down:
nleqcons = @(x) model_nlcons(x,mCAvg,pref_heterogeneity,labor_xeta) ;

%   Define options set:
fminconopt = optimoptions('fmincon','Algorithm',full_opt_alg,'ConstraintTolerance',full_opt_contol,'Display',full_opt_displ,'OptimalityTolerance',full_opt_grdtol, ...
    'FunctionTolerance',full_opt_funtol,'MaxFunctionEvaluations',full_opt_maxfunevl,'MaxIterations',full_opt_maxiter) ;

%   Implement GMM estimation:
[modelhat,modelfval,modelflag] = fmincon(@(x) model_structure(x, what, mC, mCD, mCEs, mCPi, merrC, moments, pref_heterogeneity, j0, v_err_c, labor_xeta, type_wmatrix), ...
    x0,[],[],Aeq,beq,xmin,xmax,nleqcons,fminconopt) ;

end