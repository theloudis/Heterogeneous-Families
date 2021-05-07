function f = ...
    model_structure_pref_taxes(vParams,vWages,mC,mCD,merrC,qratios,higher_moments,preference_heterogeneity,start_j,v_err_c,tax_progress)
%{  
    This function generates the moments conditions for the estimation of 
    the preferred specification of the structural model with joint taxation.

    Alexandros Theloudis
    -----------------------------------------------------------------------
%}

%   Initial statements:
global T num_pref_rdraws_taxestim sd_trim_pref_draws_taxestim ;


%%  1.  INITIALIZE OBJECTS
%   Initialize parameters and vectors to hold moments
%   -----------------------------------------------------------------------

%   Vector of pre-estimated wage parameters:
%   Second moments of wage parameters (required for all specifications):
uH  = vWages(6:11) ;        % variance:    transitory shock HD
uW  = vWages(17:22) ;       % variance:    transitory shock WF
uHW = vWages(28:33) ;       % covariance:  transitory shocks

%   Third moments of wage parameters (required for heterogeneity):
if higher_moments >= 1
    guH   = vWages(50:55) ; % skewness:    transitory shock HD
    guW   = vWages(61:66) ; % skewness:    transitory shock WF
    guH2W = vWages(72:77) ; % third cross moment: E[uH^2 uW]
    guHW2 = vWages(83:88) ; % third cross moment: E[uH uW^2]
end

%   Variance of consumption measurement error:
Vcons_err = v_err_c ;           

%   Vector of structural parameters:
%   First moments of parameters (always estimated across all specifications):
eta_c_w1  = vParams(1)  ;           % consumption wrt wage1
eta_c_w2  = vParams(2)  ;           % consumption wrt wage2
eta_h1_w1 = vParams(3)  ;           % hours1 wrt wage1
eta_h2_w2 = vParams(4)  ;           % hours2 wrt wage2

%   Higher moments:
if higher_moments == 0
    Veta_c_w1           = 0.0 ;     % consumption wrt wage1
    Veta_c_w2           = 0.0 ;     % consumption wrt wage2
    Veta_h1_w1          = 0.0 ;     % hours1 wrt wage1
    Veta_h2_w2          = 0.0 ;     % hours2 wrt wage2
    COVeta_c_w1_c_w2    = 0.0 ;     % consumption wrt wage1 ~ consumption wrt wage2
    COVeta_c_w1_h1_w1   = 0.0 ;     % consumption wrt wage1 ~ hours1 wrt wage1
    COVeta_c_w1_h2_w2   = 0.0 ;     % consumption wrt wage1 ~ hours2 wrt wage2
    COVeta_c_w2_h1_w1   = 0.0 ;     % consumption wrt wage2 ~ hours1 wrt wage1
    COVeta_c_w2_h2_w2   = 0.0 ;     % consumption wrt wage2 ~ hours2 wrt wage2
    COVeta_h1_w1_h2_w2  = 0.0 ;     % hours1 wrt wage1 ~ hours2 wrt wage2
elseif higher_moments == 1  
    if      preference_heterogeneity == 0
        Veta_c_w1           = 0.0 ;         % consumption wrt wage1
        Veta_c_w2           = 0.0 ;         % consumption wrt wage2
        Veta_h1_w1          = 0.0 ;         % hours1 wrt wage1
        Veta_h2_w2          = 0.0 ;         % hours2 wrt wage2
        COVeta_c_w1_c_w2    = 0.0 ;         % consumption wrt wage1 ~ consumption wrt wage2
        COVeta_c_w1_h1_w1   = 0.0 ;         % consumption wrt wage1 ~ hours1 wrt wage1    
        COVeta_c_w1_h2_w2   = 0.0 ;         % consumption wrt wage1 ~ hours2 wrt wage2
        COVeta_c_w2_h1_w1   = 0.0 ;         % consumption wrt wage2 ~ hours1 wrt wage1   
        COVeta_c_w2_h2_w2   = 0.0 ;         % consumption wrt wage2 ~ hours2 wrt wage2
        COVeta_h1_w1_h2_w2  = 0.0 ;         % hours1 wrt wage1 ~ hours2 wrt wage2       
    elseif  preference_heterogeneity == 1
        Veta_c_w1           = vParams(5) ;  % consumption wrt wage1
        Veta_c_w2           = vParams(6) ;  % consumption wrt wage2
        Veta_h1_w1          = vParams(7) ;  % hours1 wrt wage1
        Veta_h2_w2          = vParams(8) ;  % hours2 wrt wage2
        COVeta_c_w1_c_w2    = 0.0 ;         % consumption wrt wage1 ~ consumption wrt wage2
        COVeta_c_w1_h1_w1   = 0.0 ;         % consumption wrt wage1 ~ hours1 wrt wage1  
        COVeta_c_w1_h2_w2   = 0.0 ;         % consumption wrt wage1 ~ hours2 wrt wage2
        COVeta_c_w2_h1_w1   = 0.0 ;         % consumption wrt wage2 ~ hours1 wrt wage1  
        COVeta_c_w2_h2_w2   = 0.0 ;         % consumption wrt wage2 ~ hours2 wrt wage2
        COVeta_h1_w1_h2_w2  = 0.0 ;         % hours1 wrt wage1 ~ hours2 wrt wage2        
    elseif  preference_heterogeneity == 7
        Veta_c_w1           = vParams(5)  ; % consumption wrt wage1
        Veta_c_w2           = vParams(6)  ; % consumption wrt wage2
        Veta_h1_w1          = vParams(7)  ; % hours1 wrt wage1
        Veta_h2_w2          = vParams(8) ;  % hours2 wrt wage2
        COVeta_c_w1_c_w2    = vParams(9) ;  % consumption wrt wage1 ~ consumption wrt wage2
        COVeta_c_w1_h1_w1   = vParams(10);  % consumption wrt wage1 ~ hours1 wrt wage1
        COVeta_c_w1_h2_w2   = vParams(11);  % consumption wrt wage1 ~ hours2 wrt wage2
        COVeta_c_w2_h1_w1   = vParams(12);  % consumption wrt wage2 ~ hours1 wrt wage1
        COVeta_c_w2_h2_w2   = vParams(13);  % consumption wrt wage2 ~ hours2 wrt wage2    
        COVeta_h1_w1_h2_w2  = vParams(14);  % hours1 wrt wage1 ~ hours2 wrt wage2        
    else
        error('I cannot estimate model with joint taxation in this heterogeneity regime.')           
    end %preference_heterogeneity
end %higher_moments==0

%   Initialize vectors to hold first moments preferences 
%   & second moments wages:
%   matrix 15: E[DwH DyH]   
mom_wHyH_a = zeros(T,1) ;
mom_wHyH_b = zeros(T,1) ;
%   matrix 35: E[DwW DyH] 
mom_wWyH_a = zeros(T,1) ;
mom_wWyH_b = zeros(T,1) ;
%   matrix 17: E[DwH DyW] 
mom_wHyW_a = zeros(T,1) ;
mom_wHyW_b = zeros(T,1) ;
%   matrix 37: E[DwW DyW]       
mom_wWyW_a = zeros(T,1) ; 
mom_wWyW_b = zeros(T,1) ; 
%   matrix 19: E[DwH Dc]
mom_wHc_a  = zeros(T,1) ;
mom_wHc_b  = zeros(T,1) ;
%   matrix 39: E[DwW Dc]  
mom_wWc_a  = zeros(T,1) ;
mom_wWc_b  = zeros(T,1) ; 

%   Initialize vectors to hold second moments preferences:
%   matrix 55: E[DyH DyH] 
mom_yHyH_a  = zeros(T,1) ;
%   matrix 57: E[DyH DyW]  
mom_yHyW_a  = zeros(T,1) ;
mom_yHyW_b  = zeros(T,1) ;
%   matrix 77: E[DyW DyW] 
mom_yWyW_a  = zeros(T,1) ;
%   matrix 59: E[DyH Dc]
mom_yHc_a  = zeros(T,1) ;
mom_yHc_b  = zeros(T,1) ;
%   matrix 79: E[DyW Dc]  
mom_yWc_a  = zeros(T,1) ;
mom_yWc_b  = zeros(T,1) ;
%   matrix 99: E[Dc Dc] 
mom_cc_a   = zeros(T,1) ;

%   Initialize vectors to hold first moments preferences 
%   & third moments wages:
if higher_moments == 1
%   matrix 25: E[DwH2 DyH]      
mom_wH2yH_a = zeros(T,1) ;
mom_wH2yH_b = zeros(T,1) ;
%   matrix 45: E[DwW2 DyH]
mom_wW2yH_a = zeros(T,1) ;
mom_wW2yH_b = zeros(T,1) ;
%   matrix 27: E[DwH2 DyW]
mom_wH2yW_a = zeros(T,1) ;
mom_wH2yW_b = zeros(T,1) ;
%   matrix 47: E[DwW2 DyW]       
mom_wW2yW_a = zeros(T,1) ; 
mom_wW2yW_b = zeros(T,1) ; 
%   matrix 29: E[DwH2 Dc]
mom_wH2c_a  = zeros(T,1) ;
mom_wH2c_b  = zeros(T,1) ;
%   matrix 49: E[DwW2 Dc] 
mom_wW2c_a  = zeros(T,1) ;
mom_wW2c_b  = zeros(T,1) ;
end

%   Initialize vectors to hold second moments preferences 
%   & third moments wages:
if higher_moments == 1
%   matrix 16: E[DwH DyH2]      
mom_wHyH2_a = zeros(T,1) ;
mom_wHyH2_b = zeros(T,1) ;
%   matrix 36: E[DwW DyH2]
mom_wWyH2_a = zeros(T,1) ;
mom_wWyH2_b = zeros(T,1) ;
%   matrix 18: E[DwH DyW2]
mom_wHyW2_a = zeros(T,1) ;
mom_wHyW2_b = zeros(T,1) ;
%   matrix 38: E[DwW DyW2]       
mom_wWyW2_a = zeros(T,1) ; 
mom_wWyW2_b = zeros(T,1) ; 
%   matrix 1.10: E[DwH Dc2]
mom_wHc2_a  = zeros(T,1) ;
mom_wHc2_b  = zeros(T,1) ;
%   matrix 3.10: E[DwW Dc2] 
mom_wWc2_a  = zeros(T,1) ;
mom_wWc2_b  = zeros(T,1) ;
%   matrix 1.11: E[DwH DyH DyW]
mom_wHyHyW_a = zeros(T,1) ;
mom_wHyHyW_b = zeros(T,1) ;
%   matrix 3.11: E[DwW DyH DyW]       
mom_wWyHyW_a = zeros(T,1) ; 
mom_wWyHyW_b = zeros(T,1) ; 
%   matrix 1.12: E[DwH DyH Dc]
mom_wHyHc_a  = zeros(T,1) ;
mom_wHyHc_b  = zeros(T,1) ;
%   matrix 3.12: E[DwW DyH Dc] 
mom_wWyHc_a  = zeros(T,1) ;
mom_wWyHc_b  = zeros(T,1) ;
%   matrix 1.13: E[DwH DyW Dc]
mom_wHyWc_a  = zeros(T,1) ;
mom_wHyWc_b  = zeros(T,1) ;
%   matrix 3.13: E[DwW DyW Dc] 
mom_wWyWc_a  = zeros(T,1) ;
mom_wWyWc_b  = zeros(T,1) ;
end


%%  2.  SIMULATE RANDOM PREFERENCES
%   Simulate random preferences based on a joint normal distribution.
%   -----------------------------------------------------------------------

%   Declare first moments of preferences:
Mu = [ eta_c_w1 eta_c_w2 eta_h1_w1 eta_h2_w2 ] ;

%   I make adjustment to the covariances so that the implied correlations
%   lie always within [-1,1]. This should not be needed if the optimizer
%   attempted points that always satisfy the nonlinear inequality
%   constraints (the correlations are modelled there). In reality, however,
%   the optimizer first tries a guess for the covariances, evaluating the
%   objective function below, and then checks if the nonlinear constraints 
%   are satisfied. While this was not an issue in the baseline estimation 
%   of the model, it is a problem here as certain covariance values imply
%   a non-positive definite covariance matrix, which then halts the 
%   simulation of preferences from the multivariate normal. The mvn normal 
%   gives an error and halts the optimization. The adjustments below
%   inevitably produce some non-differentiabilities when the optimizer
%   attempts guesses that are too big or too small, but in reality this
%   does not cause problems as the optimal point needs to satisfy these 
%   inequalities anyway (modelled within model_nlcons.m). Furthermore, the 
%   multivariate normal may produce an error if the implied correlations 
%   are exactly 1 or -1; this is because of rounding errors. To avoid this,
%   I make such correlations a bit less than 1 or a bit more than -1.
if preference_heterogeneity == 7
    %   -COVeta_c_w1_c_w2
    if      COVeta_c_w1_c_w2/sqrt(Veta_c_w1*Veta_c_w1) >= 1
        COVeta_c_w1_c_w2 = 0.995*sqrt(Veta_c_w1*Veta_c_w1) ;
    elseif  COVeta_c_w1_c_w2/sqrt(Veta_c_w1*Veta_c_w1) <= -1
        COVeta_c_w1_c_w2 = -0.995*sqrt(Veta_c_w1*Veta_c_w1) ;
    end
    %   -COVeta_c_w1_h1_w1
    if      COVeta_c_w1_h1_w1/sqrt(Veta_c_w1*Veta_h1_w1) >= 1
        COVeta_c_w1_h1_w1 = 0.995*sqrt(Veta_c_w1*Veta_h1_w1) ;
    elseif  COVeta_c_w1_h1_w1/sqrt(Veta_c_w1*Veta_h1_w1) <= -1
        COVeta_c_w1_h1_w1 = -0.995*sqrt(Veta_c_w1*Veta_h1_w1) ;
    end
    %   -COVeta_c_w1_h2_w2
    if      COVeta_c_w1_h2_w2/sqrt(Veta_c_w1*Veta_h2_w2) >= 1
        COVeta_c_w1_h2_w2 = 0.995*sqrt(Veta_c_w1*Veta_h2_w2) ;
    elseif  COVeta_c_w1_h2_w2/sqrt(Veta_c_w1*Veta_h2_w2) <= -1
        COVeta_c_w1_h2_w2 = -0.995*sqrt(Veta_c_w1*Veta_h2_w2) ;
    end
    %   -COVeta_c_w2_h1_w1
    if      COVeta_c_w2_h1_w1/sqrt(Veta_c_w2*Veta_h1_w1) >= 1
        COVeta_c_w2_h1_w1 = 0.995*sqrt(Veta_c_w2*Veta_h1_w1) ;
    elseif  COVeta_c_w2_h1_w1/sqrt(Veta_c_w2*Veta_h1_w1) <= -1
        COVeta_c_w2_h1_w1 = -0.995*sqrt(Veta_c_w2*Veta_h1_w1) ;
    end
    %   -COVeta_c_w2_h2_w2
    if      COVeta_c_w2_h2_w2/sqrt(Veta_c_w2*Veta_h2_w2) >= 1
        COVeta_c_w2_h2_w2 = 0.995*sqrt(Veta_c_w2*Veta_h2_w2) ;
    elseif  COVeta_c_w2_h2_w2/sqrt(Veta_c_w2*Veta_h2_w2) <= -1
        COVeta_c_w2_h2_w2 = -0.995*sqrt(Veta_c_w2*Veta_h2_w2) ;
    end
    %   -COVeta_h1_w1_h2_w2
    if      COVeta_h1_w1_h2_w2/sqrt(Veta_h1_w1*Veta_h2_w2) >= 1
        COVeta_h1_w1_h2_w2 = 0.995*sqrt(Veta_h1_w1*Veta_h2_w2) ;
    elseif  COVeta_h1_w1_h2_w2/sqrt(Veta_h1_w1*Veta_h2_w2) <= -1
        COVeta_h1_w1_h2_w2 = -0.995*sqrt(Veta_h1_w1*Veta_h2_w2) ;
    end
end %preference_heterogeneity

%   Declare second moments of preferences:
%           eta_c_w1            eta_c_w2            eta_h1_w1           eta_h2_w2
Sigma = [   Veta_c_w1           COVeta_c_w1_c_w2    COVeta_c_w1_h1_w1   COVeta_c_w1_h2_w2   ; % eta_c_w1
            COVeta_c_w1_c_w2    Veta_c_w2           COVeta_c_w2_h1_w1   COVeta_c_w2_h2_w2   ; % eta_c_w2
            COVeta_c_w1_h1_w1   COVeta_c_w2_h1_w1   Veta_h1_w1          COVeta_h1_w1_h2_w2  ; % eta_h1_w1
            COVeta_c_w1_h2_w2   COVeta_c_w2_h2_w2   COVeta_h1_w1_h2_w2  Veta_h2_w2 ] ;        % eta_h2_w2

%   Obtain eigenvalues of Sigma matrix - to simulate preferences, matrix
%   needs to be positive-definite. If it is, carry on; otherwise, break:
if preference_heterogeneity == 7
    eigv = eig(Sigma) ;
end
if preference_heterogeneity == 7 && min(eigv)<0
    %   Matrix not positive-definite:
    f = 50 ;
    
    %   Matrix positive-definite:
else
    
    %   Draw preferences from multivariate normal (MVN): 
    if preference_heterogeneity == 0
        simPrefDrawsMVN = ones(num_pref_rdraws_taxestim,1)*Mu ;
    else
        rng(0);     % Set a starting seed
        simPrefDrawsMVN = mvnrnd(Mu,Sigma,num_pref_rdraws_taxestim) ;

        %   Replace preference draws that fall outside 'sd_trim_pref_draws_taxestim' 
        %   s.d. of the marginal distributions of the respective parameters in 
        %   order to minimize the effect of a few extreme preference draws:
        parambounds         = [Mu'-sd_trim_pref_draws_taxestim*sqrt(diag(Sigma)) , Mu'+sd_trim_pref_draws_taxestim*sqrt(diag(Sigma))] ;
        for pp = 1:1:length(Mu)
            simPrefDrawsMVN(pp,simPrefDrawsMVN(pp,:)<parambounds(pp,1)) = parambounds(pp,1) ;
            simPrefDrawsMVN(pp,simPrefDrawsMVN(pp,:)>parambounds(pp,2)) = parambounds(pp,2) ;
        end 
        clearvars pp parambounds Sigma
    end %preference_heterogeneity
    
    %   Clear unneeded variables:
    clearvars eta_* Veta_* COVeta_* Mu ;
        
    %   Declare simulated preferences:
    sim_eta_c_w1  = simPrefDrawsMVN(:,1) ;
    sim_eta_c_w2  = simPrefDrawsMVN(:,2) ;
    sim_eta_h1_w1 = simPrefDrawsMVN(:,3) ;
    sim_eta_h2_w2 = simPrefDrawsMVN(:,4) ;

    %  DECLARE HOUSEHOLD STRUCTURE
    %   -------------------------------------------------------------------

    %   Declare income proportions:
    q1 = qratios(1) ;
    q2 = qratios(2) ;

    %   Declare elements of matrix Ypsilon:
    Y11 = 1 ;
    Y12 = tax_progress*(sim_eta_c_w1+sim_eta_c_w2)*q1 ;
    Y13 = tax_progress*(sim_eta_c_w1+sim_eta_c_w2)*q2 ;
    Y21 = 0 ;
    Y22 = 1 + tax_progress*sim_eta_h1_w1*q1 ;
    Y23 = tax_progress*sim_eta_h1_w1*q2 ;
    Y31 = 0 ;
    Y32 = tax_progress*sim_eta_h2_w2*q1 ;
    Y33 = 1 + tax_progress*sim_eta_h2_w2*q2 ;

    %   Declare elements of matrix Rho:
    R_c_w1  = sim_eta_c_w1 - tax_progress*(sim_eta_c_w1+sim_eta_c_w2)*q1 ;
    R_c_w2  = sim_eta_c_w2 - tax_progress*(sim_eta_c_w1+sim_eta_c_w2)*q2 ;
    R_h1_w1 = sim_eta_h1_w1 - tax_progress*sim_eta_h1_w1*q1 ;
    R_h1_w2 = - tax_progress*sim_eta_h1_w1*q2 ;
    R_h2_w1 = - tax_progress*sim_eta_h2_w2*q1 ;
    R_h2_w2 = sim_eta_h2_w2 - tax_progress*sim_eta_h2_w2*q2 ;

    %   Construction of transmission matrix Psi_bar (3x2 matrix):
    if preference_heterogeneity == 0
        Psi = repmat([  Y11   Y12(1)   Y13(1) ; ...
                        Y21   Y22(1)   Y23(1) ; ...
                        Y31   Y32(1)   Y33(1)]\ ...
                      [ R_c_w1(1)    R_c_w2(1)  ; ... 
                        R_h1_w1(1)   R_h1_w2(1) ; ...
                        R_h2_w1(1)   R_h2_w2(1) ], [1,1,num_pref_rdraws_taxestim]) ;
    else
        Psi = NaN(3,2,num_pref_rdraws_taxestim) ;
        for ss=1:1:num_pref_rdraws_taxestim
            Psi(:,:,ss) = [ Y11   Y12(ss)   Y13(ss) ; ...
                            Y21   Y22(ss)   Y23(ss) ; ...
                            Y31   Y32(ss)   Y33(ss)]\ ...
                          [ R_c_w1(ss)    R_c_w2(ss)  ; ... 
                            R_h1_w1(ss)   R_h1_w2(ss) ; ...
                            R_h2_w1(ss)   R_h2_w2(ss) ] ;
        end %ss
    end %preference_heterogeneity

    %   Construction of first moments of Psi_bar matrix:
    EPsi_c_w1  = mean(Psi(1,1,:)) ;
    EPsi_c_w2  = mean(Psi(1,2,:)) ;
    EPsi_h1_w1 = mean(Psi(2,1,:)) ;
    EPsi_h1_w2 = mean(Psi(2,2,:)) ;
    EPsi_h2_w1 = mean(Psi(3,1,:)) ;
    EPsi_h2_w2 = mean(Psi(3,2,:)) ;

    %   Construction of second moments of Psi_bar matrix:
    %   -consumption c
    EPsi_c_w1_sq        = mean(Psi(1,1,:).^2) ;
    EPsi_c_w2_sq        = mean(Psi(1,2,:).^2) ;
    EPsi_c_w1_c_w2      = mean(Psi(1,1,:).*Psi(1,2,:)) ;
    %   -consumption c and male hours h1
    EPsi_c_w1_h1_w1     = mean(Psi(1,1,:).*Psi(2,1,:)) ;
    EPsi_c_w1_h1_w2     = mean(Psi(1,1,:).*Psi(2,2,:)) ;
    EPsi_c_w2_h1_w1     = mean(Psi(1,2,:).*Psi(2,1,:)) ;
    EPsi_c_w2_h1_w2     = mean(Psi(1,2,:).*Psi(2,2,:)) ;
    %   -consumption c and female hours h2
    EPsi_c_w1_h2_w1     = mean(Psi(1,1,:).*Psi(3,1,:)) ;
    EPsi_c_w1_h2_w2     = mean(Psi(1,1,:).*Psi(3,2,:)) ;
    EPsi_c_w2_h2_w1     = mean(Psi(1,2,:).*Psi(3,1,:)) ;
    EPsi_c_w2_h2_w2     = mean(Psi(1,2,:).*Psi(3,2,:)) ;
    %   -male hours h1
    EPsi_h1_w1_sq       = mean(Psi(2,1,:).^2) ;
    EPsi_h1_w2_sq       = mean(Psi(2,2,:).^2) ;
    EPsi_h1_w1_h1_w2    = mean(Psi(2,1,:).*Psi(2,2,:)) ;
    %   -female hours h2
    EPsi_h2_w1_sq       = mean(Psi(3,1,:).^2) ;
    EPsi_h2_w2_sq       = mean(Psi(3,2,:).^2) ;
    EPsi_h2_w1_h2_w2    = mean(Psi(3,1,:).*Psi(3,2,:)) ;
    %   -male hours h1 and female hours h2
    EPsi_h1_w1_h2_w1    = mean(Psi(2,1,:).*Psi(3,1,:)) ;
    EPsi_h1_w1_h2_w2    = mean(Psi(2,1,:).*Psi(3,2,:)) ;
    EPsi_h1_w2_h2_w1    = mean(Psi(2,2,:).*Psi(3,1,:)) ;
    EPsi_h1_w2_h2_w2    = mean(Psi(2,2,:).*Psi(3,2,:)) ;


    %$  FIRST MOMENTS PREFERENCES - SECOND MOMENTS WAGES
    %   -------------------------------------------------------------------

    %   Matrix 15: E[DwH DyH]   
    %   -------------------------------------------------------------------

    %   Intertemporal co-variances:
    j = 2 ;
    while j <= T 
        mom_wHyH_a(j) = (mC(6*T+j-1,:) + merrC(j-1,5) ...
            + (1+EPsi_h1_w1) * uH(j-1) + EPsi_h1_w2 * uHW(j-1)) ...
            * mCD(6*T+j-1,:)' ;
        mom_wHyH_a(j) = mom_wHyH_a(j) / sum(mCD(6*T+j-1,:)) ;
        j = j + 1 ;
    end

    j = start_j ;
    while j <= T 
        mom_wHyH_b(j) = (mC(7*T+j-1,:) + merrC(j-1,5) ...
            + (1+EPsi_h1_w1) * uH(j-1) + EPsi_h1_w2 * uHW(j-1)) ...
            * mCD(7*T+j-1,:)' ;
        mom_wHyH_b(j) = mom_wHyH_b(j) / sum(mCD(7*T+j-1,:)) ;
        j = j + 1 ;
    end


    %   Matrix 35: E[DwW DyH]   
    %   -------------------------------------------------------------------

    %   Intertemporal co-variances:
    j = 2 ;
    while j <= T 
        mom_wWyH_a(j) = (mC(9*T+j-1,:) ...
            + (1+EPsi_h1_w1) * uHW(j-1) + EPsi_h1_w2 * uW(j-1)) ...
            * mCD(9*T+j-1,:)' ;
        mom_wWyH_a(j) = mom_wWyH_a(j) / sum(mCD(9*T+j-1,:)) ;
        j = j + 1 ;
    end

    j = start_j ;
    while j <= T
        mom_wWyH_b(j) = (mC(10*T+j-1,:) ...
            + (1+EPsi_h1_w1) * uHW(j-1) + EPsi_h1_w2 * uW(j-1)) ...
            * mCD(10*T+j-1,:)' ;
        mom_wWyH_b(j) = mom_wWyH_b(j) / sum(mCD(10*T+j-1,:)) ;
        j = j + 1 ;
    end


    %   Matrix 17: E[DwH DyW]   
    %   -------------------------------------------------------------------

    %   Intertemporal co-variances:
    j = 2 ;
    while j <= T 
        mom_wHyW_a(j) = (mC(12*T+j-1,:) ...
            + EPsi_h2_w1 * uH(j-1) + (1+EPsi_h2_w2) * uHW(j-1)) ...
            * mCD(12*T+j-1,:)' ; 
        mom_wHyW_a(j) = mom_wHyW_a(j) / sum(mCD(12*T+j-1,:)) ;
        j = j + 1 ;
    end

    j = start_j ;
    while j <= T 
        mom_wHyW_b(j) = (mC(13*T+j-1,:) ...
            + EPsi_h2_w1 * uH(j-1) + (1+EPsi_h2_w2) * uHW(j-1)) ...
            * mCD(13*T+j-1,:)' ;
        mom_wHyW_b(j) = mom_wHyW_b(j) / sum(mCD(13*T+j-1,:)) ;
        j = j + 1 ;
    end


    %   Matrix 37: E[DwW DyW]   
    %   -------------------------------------------------------------------

    %   Intertemporal co-variances:
    j = 2 ;
    while j <= T 
        mom_wWyW_a(j) = (mC(15*T+j-1,:) + merrC(j-1,6) ...
            + EPsi_h2_w1 * uHW(j-1) + (1+EPsi_h2_w2) * uW(j-1)) ...
            * mCD(15*T+j-1,:)' ;
        mom_wWyW_a(j) = mom_wWyW_a(j) / sum(mCD(15*T+j-1,:)) ;
        j = j + 1 ;
    end

    j = start_j ;
    while j <= T 
        mom_wWyW_b(j) = (mC(16*T+j-1,:) + merrC(j-1,6) ...
            + EPsi_h2_w1 * uHW(j-1) + (1+EPsi_h2_w2) * uW(j-1)) ...
            * mCD(16*T+j-1,:)' ;
        mom_wWyW_b(j) = mom_wWyW_b(j) / sum(mCD(16*T+j-1,:)) ;
        j = j + 1 ;
    end


    %   Matrix 19: E[DwH Dc]   
    %   -------------------------------------------------------------------

    %   Intertemporal co-variances:
    j = 2 ;
    while j <= T 
        mom_wHc_a(j) = (mC(45*T+j-1,:) ...
            + EPsi_c_w1 * uH(j-1) + EPsi_c_w2 * uHW(j-1)) ...
            * mCD(45*T+j-1,:)' ;
        mom_wHc_a(j) = mom_wHc_a(j) / sum(mCD(45*T+j-1,:)) ;
        j = j + 1 ;
    end

    j = 3 ;
    while j <= T
        mom_wHc_b(j) = (mC(46*T+j-1,:) ...
            + EPsi_c_w1 * uH(j-1) + EPsi_c_w2 * uHW(j-1)) ...
            * mCD(46*T+j-1,:)' ;
        mom_wHc_b(j) = mom_wHc_b(j) / sum(mCD(46*T+j-1,:)) ;
        j = j + 1 ;
    end


    %   Matrix 39: E[DwW Dc]   
    %   -------------------------------------------------------------------

    %   Intertemporal co-variances:
    j = 2 ;
    while j <= T 
        mom_wWc_a(j) = (mC(48*T+j-1,:) ...
            + EPsi_c_w1 * uHW(j-1) + EPsi_c_w2 * uW(j-1)) ...
            * mCD(48*T+j-1,:)' ;
        mom_wWc_a(j) = mom_wWc_a(j) / sum(mCD(48*T+j-1,:)) ;
        j = j + 1 ;
    end

    j = 3 ;
    while j <= T
        mom_wWc_b(j) = (mC(49*T+j-1,:) ...
            + EPsi_c_w1 * uHW(j-1) + EPsi_c_w2 * uW(j-1)) ...
            * mCD(49*T+j-1,:)' ;
        mom_wWc_b(j) = mom_wWc_b(j) / sum(mCD(49*T+j-1,:)) ;
        j = j + 1 ;
    end


    %$  FIRST MOMENTS PREFERENCES - THIRD MOMENTS WAGES
    %   -------------------------------------------------------------------

    if higher_moments == 1

    %   Matrix 25: E[DwH2 DyH]
    %   -------------------------------------------------------------------

    %   Intertemporal co-variances:
    j = 2 ;
    while j <= T 
        mom_wH2yH_a(j) = (mC(24*T+j-1,:) ...
            + (1+EPsi_h1_w1) * guH(j-1) + EPsi_h1_w2 * guH2W(j-1)) ...
            * mCD(24*T+j-1,:)' ;
        mom_wH2yH_a(j) = mom_wH2yH_a(j) / sum(mCD(24*T+j-1,:)) ;
        j = j + 1 ;
    end

    j = start_j ;
    while j <= T 
        mom_wH2yH_b(j) = (mC(25*T+j-1,:) ...
            - (1+EPsi_h1_w1) * guH(j-1) - EPsi_h1_w2 * guH2W(j-1)) ...
            * mCD(25*T+j-1,:)' ;
        mom_wH2yH_b(j) = mom_wH2yH_b(j) / sum(mCD(25*T+j-1,:)) ;
        j = j + 1 ;
    end


    %   Matrix 45: E[DwW2 DyH]
    %   -------------------------------------------------------------------

    %   Intertemporal co-variances:
    j = 2 ;
    while j <= T 
        mom_wW2yH_a(j) = (mC(26*T+j-1,:) ...
            + (1+EPsi_h1_w1) * guHW2(j-1) + EPsi_h1_w2 * guW(j-1)) ...
            * mCD(26*T+j-1,:)' ;
        mom_wW2yH_a(j) = mom_wW2yH_a(j) / sum(mCD(26*T+j-1,:)) ;
        j = j + 1 ;
    end

    j = start_j ;
    while j <= T
        mom_wW2yH_b(j) = (mC(27*T+j-1,:) ...
            - (1+EPsi_h1_w1) * guHW2(j-1) - EPsi_h1_w2 * guW(j-1)) ...
            * mCD(27*T+j-1,:)' ;
        mom_wW2yH_b(j) = mom_wW2yH_b(j) / sum(mCD(27*T+j-1,:)) ;
        j = j + 1 ;
    end


    %   Matrix 27: E[DwH2 DyW]
    %   -------------------------------------------------------------------

    %   Intertemporal co-variances:
    j = 2 ;
    while j <= T 
        mom_wH2yW_a(j) = (mC(28*T+j-1,:) ...
            + EPsi_h2_w1 * guH(j-1) + (1+EPsi_h2_w2) * guH2W(j-1)) ...
            * mCD(28*T+j-1,:)' ; 
        mom_wH2yW_a(j) = mom_wH2yW_a(j) / sum(mCD(28*T+j-1,:)) ;
        j = j + 1 ;
    end

    j = start_j ;
    while j <= T 
        mom_wH2yW_b(j) = (mC(29*T+j-1,:) ...
            - EPsi_h2_w1 * guH(j-1) - (1+EPsi_h2_w2) * guH2W(j-1)) ...
            * mCD(29*T+j-1,:)' ;
        mom_wH2yW_b(j) = mom_wH2yW_b(j) / sum(mCD(29*T+j-1,:)) ;
        j = j + 1 ;
    end


    %   Matrix 47: E[DwW2 DyW]
    %   -------------------------------------------------------------------

    %   Intertemporal co-variances:
    j = 2 ;
    while j <= T 
        mom_wW2yW_a(j) = (mC(30*T+j-1,:) ...
            + EPsi_h2_w1 * guHW2(j-1) + (1+EPsi_h2_w2) * guW(j-1)) ...
            * mCD(30*T+j-1,:)' ;
        mom_wW2yW_a(j) = mom_wW2yW_a(j) / sum(mCD(30*T+j-1,:)) ;
        j = j + 1 ;
    end

    j = start_j ;
    while j <= T 
        mom_wW2yW_b(j) = (mC(31*T+j-1,:) ...
            - EPsi_h2_w1 * guHW2(j-1) - (1+EPsi_h2_w2) * guW(j-1)) ...
            * mCD(31*T+j-1,:)' ;
        mom_wW2yW_b(j) = mom_wW2yW_b(j) / sum(mCD(31*T+j-1,:)) ;
        j = j + 1 ;
    end


    %   Matrix 29: E[DwH2 Dc]
    %   -------------------------------------------------------------------

    %   Intertemporal co-variances:
    j = 2 ;
    while j <= T 
        mom_wH2c_a(j) = (mC(58*T+j-1,:) ...
            + EPsi_c_w1 * guH(j-1) + EPsi_c_w2 * guH2W(j-1)) ...
            * mCD(58*T+j-1,:)' ;
        mom_wH2c_a(j) = mom_wH2c_a(j) / sum(mCD(58*T+j-1,:)) ;
        j = j + 1 ;
    end

    j = 3 ;
    while j <= T
        mom_wH2c_b(j) = (mC(59*T+j-1,:) ...
            - EPsi_c_w1 * guH(j-1) - EPsi_c_w2 * guH2W(j-1)) ...
            * mCD(59*T+j-1,:)' ;
        mom_wH2c_b(j) = mom_wH2c_b(j) / sum(mCD(59*T+j-1,:)) ;
        j = j + 1 ;
    end


    %   Matrix 49: E[DwW2 Dc] 
    %   -------------------------------------------------------------------

    %   Intertemporal co-variances:
    j = 2 ;
    while j <= T 
        mom_wW2c_a(j) = (mC(60*T+j-1,:) ...
            + EPsi_c_w1 * guHW2(j-1) + EPsi_c_w2 * guW(j-1)) ...
            * mCD(60*T+j-1,:)' ;
        mom_wW2c_a(j) = mom_wW2c_a(j) / sum(mCD(60*T+j-1,:)) ;
        j = j + 1 ;
    end

    j = 3 ;
    while j <= T
        mom_wW2c_b(j) = (mC(61*T+j-1,:) ...
            - EPsi_c_w1 * guHW2(j-1) - EPsi_c_w2 * guW(j-1)) ...
            * mCD(61*T+j-1,:)' ;
        mom_wW2c_b(j) = mom_wW2c_b(j) / sum(mCD(61*T+j-1,:)) ;
        j = j + 1 ;
    end
    end %if higher_moments == 1


    %$  SECOND MOMENTS PREFERENCES - SECOND MOMENTS WAGES
    %   -------------------------------------------------------------------

    %   Matrix 55: E[DyH DyH]   
    %   -------------------------------------------------------------------

    %   Intertemporal co-variances:
    j = start_j ;
    while j <= T 
        mom_yHyH_a(j) = (mC(18*T+j-1,:) + merrC(j-1,3) ...
            + (1 + EPsi_h1_w1_sq + 2*EPsi_h1_w1) * uH(j-1) ...
            + 2*(EPsi_h1_w2 + EPsi_h1_w1_h1_w2) * uHW(j-1) ...
            + EPsi_h1_w2_sq * uW(j-1)) ...
            * mCD(18*T+j-1,:)' ;
        mom_yHyH_a(j) = mom_yHyH_a(j) / sum(mCD(18*T+j-1,:)) ;
        j = j + 1 ;
    end


    %   Matrix 57: E[DyH DyW]   
    %   -------------------------------------------------------------------

    %   Intertemporal co-variances:
    j = start_j ;
    while j <= T
        mom_yHyW_a(j) = (mC(20*T+j-1,:) ...
            + (EPsi_h2_w1 + EPsi_h1_w1_h2_w1) * uH(j-1) ...
            + (1 + EPsi_h1_w1 + EPsi_h2_w2 + EPsi_h1_w1_h2_w2) * uHW(j-1) ...
            + EPsi_h1_w2_h2_w1 * uHW(j-1) ...
            + (EPsi_h1_w2 + EPsi_h1_w2_h2_w2) * uW(j-1)) ...    
            * mCD(20*T+j-1,:)' ; 
        mom_yHyW_a(j) = mom_yHyW_a(j) / sum(mCD(20*T+j-1,:)) ;
        j = j + 1 ;
    end

    j = start_j ;
    while j <= T
        mom_yHyW_b(j) = (mC(21*T+j-1,:) ...
            + (EPsi_h2_w1 + EPsi_h1_w1_h2_w1) * uH(j-1) ...
            + (1 + EPsi_h1_w1 + EPsi_h2_w2 + EPsi_h1_w1_h2_w2) * uHW(j-1) ...
            + EPsi_h1_w2_h2_w1 * uHW(j-1) ...
            + (EPsi_h1_w2 + EPsi_h1_w2_h2_w2) * uW(j-1)) ... 
            * mCD(21*T+j-1,:)' ;
        mom_yHyW_b(j) = mom_yHyW_b(j) / sum(mCD(21*T+j-1,:)) ;
        j = j + 1 ;
    end


    %   Matrix 77: E[DyW DyW]   
    %   -------------------------------------------------------------------

    %   Intertemporal co-variances:
    j = start_j ;
    while j <= T 
        mom_yWyW_a(j) = (mC(23*T+j-1,:) + merrC(j-1,4) ...
            + EPsi_h2_w1_sq * uH(j-1) ...
            + 2*(EPsi_h2_w1 + EPsi_h2_w1_h2_w2) * uHW(j-1) ...
            + (1 + EPsi_h2_w2_sq + 2*EPsi_h2_w2) * uW(j-1)) ...
            * mCD(23*T+j-1,:)' ;
        mom_yWyW_a(j) = mom_yWyW_a(j) / sum(mCD(23*T+j-1,:)) ;
        j = j + 1 ;
    end


    %   Matrix 59: E[DyH Dc]   
    %   -------------------------------------------------------------------

    %   Intertemporal co-variances:
    j = start_j ;
    while j <= T 
        mom_yHc_a(j) = (mC(51*T+j-1,:) ...
            + (EPsi_c_w1 + EPsi_c_w1_h1_w1) * uH(j-1) ...
            + (EPsi_c_w2 + EPsi_c_w2_h1_w1) * uHW(j-1) ...
            + EPsi_c_w1_h1_w2 * uHW(j-1) ...
            + EPsi_c_w2_h1_w2 * uW(j-1)) ...
            * mCD(51*T+j-1,:)' ;
        mom_yHc_a(j) = mom_yHc_a(j) / sum(mCD(51*T+j-1,:)) ;
        j = j + 1 ;
    end

    j = 3 ;
    while j <= T 
        mom_yHc_b(j) = (mC(52*T+j-1,:) ...
            + (EPsi_c_w1 + EPsi_c_w1_h1_w1) * uH(j-1) ...
            + (EPsi_c_w2 + EPsi_c_w2_h1_w1) * uHW(j-1) ...
            + EPsi_c_w1_h1_w2 * uHW(j-1) ...
            + EPsi_c_w2_h1_w2 * uW(j-1)) ...
            * mCD(52*T+j-1,:)' ; 
        mom_yHc_b(j) = mom_yHc_b(j) / sum(mCD(52*T+j-1,:)) ;
        j = j + 1 ;
    end


    %   Matrix 79: E[DyW Dc]   
    %   -------------------------------------------------------------------

    %   Intertemporal co-variances:
    j = start_j ;
    while j <= T 
        mom_yWc_a(j) = (mC(54*T+j-1,:) ...
            + EPsi_c_w1_h2_w1 * uH(j-1) ...
            + EPsi_c_w2_h2_w1 * uHW(j-1) ...
            + (EPsi_c_w1 + EPsi_c_w1_h2_w2) * uHW(j-1) ...
            + (EPsi_c_w2 + EPsi_c_w2_h2_w2) * uW(j-1)) ...      
            * mCD(54*T+j-1,:)' ; 
        mom_yWc_a(j) = mom_yWc_a(j) / sum(mCD(54*T+j-1,:)) ;
        j = j + 1 ;
    end

    j = 3 ;
    while j <= T
        mom_yWc_b(j) = (mC(55*T+j-1,:) ...
            + EPsi_c_w1_h2_w1 * uH(j-1) ...
            + EPsi_c_w2_h2_w1 * uHW(j-1) ...
            + (EPsi_c_w1 + EPsi_c_w1_h2_w2) * uHW(j-1) ...
            + (EPsi_c_w2 + EPsi_c_w2_h2_w2) * uW(j-1)) ... 
            * mCD(55*T+j-1,:)' ; 
        mom_yWc_b(j) = mom_yWc_b(j) / sum(mCD(55*T+j-1,:)) ;
        j = j + 1 ;
    end


    %   Matrix 99: E[Dc Dc]   
    %   -------------------------------------------------------------------

    %   Intertemporal co-variances:
    j = 3 ;
    while j <= T
        mom_cc_a(j) = (mC(57*T+j-1,:) ...
            + EPsi_c_w1_sq * uH(j-1) ...
            + 2*EPsi_c_w1_c_w2 * uHW(j-1) ...
            + EPsi_c_w2_sq * uW(j-1) ...
            + Vcons_err) ...
            * mCD(57*T+j-1,:)' ;
        mom_cc_a(j) = mom_cc_a(j) / sum(mCD(57*T+j-1,:)) ;
        j = j + 1 ;
    end


    %$  SECOND MOMENTS PREFERENCES - THIRD MOMENTS WAGES
    %   -------------------------------------------------------------------

    if higher_moments == 1

    %   Matrix 16: E[DwH DyH2]
    %   -------------------------------------------------------------------

    %   Intertemporal co-variances:
    j = 2 ;
    while j <= T 
        mom_wHyH2_a(j) = (mC(32*T+j-1,:) ...
            - (1 + EPsi_h1_w1_sq + 2*EPsi_h1_w1) * guH(j-1) ...
            - 2*(EPsi_h1_w2 + EPsi_h1_w1_h1_w2) * guH2W(j-1) ...
            - EPsi_h1_w2_sq * guHW2(j-1)) ...
            * mCD(32*T+j-1,:)' ;
        mom_wHyH2_a(j) = mom_wHyH2_a(j) / sum(mCD(32*T+j-1,:)) ;
        j = j + 1 ;
    end

    j = start_j ;
    while j <= T 
        mom_wHyH2_b(j) = (mC(33*T+j-1,:) ...
            + (1 + EPsi_h1_w1_sq + 2*EPsi_h1_w1) * guH(j-1) ...
            + 2*(EPsi_h1_w2 + EPsi_h1_w1_h1_w2) * guH2W(j-1) ...
            + EPsi_h1_w2_sq * guHW2(j-1)) ...
            * mCD(33*T+j-1,:)' ;
        mom_wHyH2_b(j) = mom_wHyH2_b(j) / sum(mCD(33*T+j-1,:)) ;
        j = j + 1 ;
    end


    %   Matrix 36: E[DwW DyH2]
    %   -------------------------------------------------------------------

    %   Intertemporal co-variances:
    j = 2 ;
    while j <= T 
        mom_wWyH2_a(j) = (mC(34*T+j-1,:) ...
            - (1 + EPsi_h1_w1_sq + 2*EPsi_h1_w1) * guH2W(j-1) ...
            - 2*(EPsi_h1_w2 + EPsi_h1_w1_h1_w2) * guHW2(j-1) ...
            - EPsi_h1_w2_sq * guW(j-1)) ...
            * mCD(34*T+j-1,:)' ;
        mom_wWyH2_a(j) = mom_wWyH2_a(j) / sum(mCD(34*T+j-1,:)) ;
        j = j + 1 ;
    end

    j = start_j ;
    while j <= T 
        mom_wWyH2_b(j) = (mC(35*T+j-1,:) ...
            + (1 + EPsi_h1_w1_sq + 2*EPsi_h1_w1) * guH2W(j-1) ...
            + 2*(EPsi_h1_w2 + EPsi_h1_w1_h1_w2) * guHW2(j-1) ...
            + EPsi_h1_w2_sq * guW(j-1)) ...
            * mCD(35*T+j-1,:)' ;
        mom_wWyH2_b(j) = mom_wWyH2_b(j) / sum(mCD(35*T+j-1,:)) ;
        j = j + 1 ;
    end


    %   Matrix 18: E[DwH DyW2]
    %   -------------------------------------------------------------------

    %   Intertemporal co-variances:
    j = 2 ;
    while j <= T 
        mom_wHyW2_a(j) = (mC(36*T+j-1,:) ...
            - EPsi_h2_w1_sq * guH(j-1) ...
            - 2*(EPsi_h2_w1 + EPsi_h2_w1_h2_w2) * guH2W(j-1) ...
            - (1 + EPsi_h2_w2_sq + 2*EPsi_h2_w2) * guHW2(j-1)) ...
            * mCD(36*T+j-1,:)' ;
        mom_wHyW2_a(j) = mom_wHyW2_a(j) / sum(mCD(36*T+j-1,:)) ;
        j = j + 1 ;
    end

    j = start_j ;
    while j <= T 
        mom_wHyW2_b(j) = (mC(37*T+j-1,:) ...
            + EPsi_h2_w1_sq * guH(j-1) ...
            + 2*(EPsi_h2_w1 + EPsi_h2_w1_h2_w2) * guH2W(j-1) ...
            + (1 + EPsi_h2_w2_sq + 2*EPsi_h2_w2) * guHW2(j-1)) ...
            * mCD(37*T+j-1,:)' ;
        mom_wHyW2_b(j) = mom_wHyW2_b(j) / sum(mCD(37*T+j-1,:)) ;
        j = j + 1 ;
    end


    %   Matrix 38: E[DwW DyW2]   
    %   -------------------------------------------------------------------

    %   Intertemporal co-variances:
    j = 2 ;
    while j <= T 
        mom_wWyW2_a(j) = (mC(38*T+j-1,:) ...
            - EPsi_h2_w1_sq * guH2W(j-1) ...
            - 2*(EPsi_h2_w1 + EPsi_h2_w1_h2_w2) * guHW2(j-1) ...
            - (1 + EPsi_h2_w2_sq + 2*EPsi_h2_w2) * guW(j-1)) ...
            * mCD(38*T+j-1,:)' ;
        mom_wWyW2_a(j) = mom_wWyW2_a(j) / sum(mCD(38*T+j-1,:)) ;
        j = j + 1 ;
    end

    j = start_j ;
    while j <= T 
        mom_wWyW2_b(j) = (mC(39*T+j-1,:) ...
            + EPsi_h2_w1_sq * guH2W(j-1) ...
            + 2*(EPsi_h2_w1 + EPsi_h2_w1_h2_w2) * guHW2(j-1) ...
            + (1 + EPsi_h2_w2_sq + 2*EPsi_h2_w2) * guW(j-1)) ...
            * mCD(39*T+j-1,:)' ;
        mom_wWyW2_b(j) = mom_wWyW2_b(j) / sum(mCD(39*T+j-1,:)) ;
        j = j + 1 ;
    end


    %   Matrix 1.10: E[DwH Dc2]
    %   -------------------------------------------------------------------

    %   Intertemporal co-variances:
    j = 2 ;
    while j <= T
        mom_wHc2_a(j) = (mC(62*T+j-1,:) ...
            - EPsi_c_w1_sq * guH(j-1) ...
            - 2*EPsi_c_w1_c_w2 * guH2W(j-1) ...
            - EPsi_c_w2_sq * guHW2(j-1)) ...
            * mCD(62*T+j-1,:)' ;
        mom_wHc2_a(j) = mom_wHc2_a(j) / sum(mCD(62*T+j-1,:)) ;
        j = j + 1 ;
    end

    j = 3 ;
    while j <= T
        mom_wHc2_b(j) = (mC(63*T+j-1,:) ...
            + EPsi_c_w1_sq * guH(j-1) ...
            + 2*EPsi_c_w1_c_w2 * guH2W(j-1) ...
            + EPsi_c_w2_sq * guHW2(j-1)) ...
            * mCD(63*T+j-1,:)' ;
        mom_wHc2_b(j) = mom_wHc2_b(j) / sum(mCD(63*T+j-1,:)) ;
        j = j + 1 ;
    end


    %   Matrix 3.10: E[DwW Dc2] 
    %   -------------------------------------------------------------------

    %   Intertemporal co-variances:
    j = 2 ;
    while j <= T
        mom_wWc2_a(j) = (mC(64*T+j-1,:) ...
            - EPsi_c_w1_sq * guH2W(j-1) ...
            - 2*EPsi_c_w1_c_w2 * guHW2(j-1) ...
            - EPsi_c_w2_sq * guW(j-1)) ...
            * mCD(64*T+j-1,:)' ;
        mom_wWc2_a(j) = mom_wWc2_a(j) / sum(mCD(64*T+j-1,:)) ;
        j = j + 1 ;
    end

    j = 3 ;
    while j <= T
        mom_wWc2_b(j) = (mC(65*T+j-1,:) ...
            + EPsi_c_w1_sq * guH2W(j-1) ...
            + 2*EPsi_c_w1_c_w2 * guHW2(j-1) ...
            + EPsi_c_w2_sq * guW(j-1)) ...
            * mCD(65*T+j-1,:)' ;
        mom_wWc2_b(j) = mom_wWc2_b(j) / sum(mCD(65*T+j-1,:)) ;
        j = j + 1 ;
    end


    %   Matrix 1.11: E[DwH DyH DyW]
    %   -------------------------------------------------------------------

    %   Intertemporal co-variances:
    j = 2 ;
    while j <= T
        mom_wHyHyW_a(j) = (mC(40*T+j-1,:) ...
            - (EPsi_h2_w1 + EPsi_h1_w1_h2_w1) * guH(j-1) ...
            - (1 + EPsi_h1_w1 + EPsi_h2_w2 + EPsi_h1_w1_h2_w2) * guH2W(j-1) ...
            - EPsi_h1_w2_h2_w1 * guH2W(j-1) ...
            - (EPsi_h1_w2 + EPsi_h1_w2_h2_w2) * guHW2(j-1)) ...    
            * mCD(40*T+j-1,:)' ; 
        mom_wHyHyW_a(j) = mom_wHyHyW_a(j) / sum(mCD(40*T+j-1,:)) ;
        j = j + 1 ;
    end

    j = start_j ;
    while j <= T
        mom_wHyHyW_b(j) = (mC(41*T+j-1,:) ...
            + (EPsi_h2_w1 + EPsi_h1_w1_h2_w1) * guH(j-1) ...
            + (1 + EPsi_h1_w1 + EPsi_h2_w2 + EPsi_h1_w1_h2_w2) * guH2W(j-1) ...
            + EPsi_h1_w2_h2_w1 * guH2W(j-1) ...
            + (EPsi_h1_w2 + EPsi_h1_w2_h2_w2) * guHW2(j-1)) ... 
            * mCD(41*T+j-1,:)' ;
        mom_wHyHyW_b(j) = mom_wHyHyW_b(j) / sum(mCD(41*T+j-1,:)) ;
        j = j + 1 ;
    end


    %   Matrix 3.11: E[DwW DyH DyW]    
    %   -------------------------------------------------------------------

    %   Intertemporal co-variances:
    j = 2 ;
    while j <= T
        mom_wWyHyW_a(j) = (mC(42*T+j-1,:) ...
            - (EPsi_h2_w1 + EPsi_h1_w1_h2_w1) * guH2W(j-1) ...
            - (1 + EPsi_h1_w1 + EPsi_h2_w2 + EPsi_h1_w1_h2_w2) * guHW2(j-1) ...
            - EPsi_h1_w2_h2_w1 * guHW2(j-1) ...
            - (EPsi_h1_w2 + EPsi_h1_w2_h2_w2) * guW(j-1)) ...    
            * mCD(42*T+j-1,:)' ; 
        mom_wWyHyW_a(j) = mom_wWyHyW_a(j) / sum(mCD(42*T+j-1,:)) ;
        j = j + 1 ;
    end

    j = start_j ;
    while j <= T
        mom_wWyHyW_b(j) = (mC(43*T+j-1,:) ...
            + (EPsi_h2_w1 + EPsi_h1_w1_h2_w1) * guH2W(j-1) ...
            + (1 + EPsi_h1_w1 + EPsi_h2_w2 + EPsi_h1_w1_h2_w2) * guHW2(j-1) ...
            + EPsi_h1_w2_h2_w1 * guHW2(j-1) ...
            + (EPsi_h1_w2 + EPsi_h1_w2_h2_w2) * guW(j-1)) ... 
            * mCD(43*T+j-1,:)' ;
        mom_wWyHyW_b(j) = mom_wWyHyW_b(j) / sum(mCD(43*T+j-1,:)) ;
        j = j + 1 ;
    end


    %   Matrix 1.12: E[DwH DyH Dc]
    %   -------------------------------------------------------------------

    %   Intertemporal co-variances:
    j = 2 ;
    while j <= T 
        mom_wHyHc_a(j) = (mC(66*T+j-1,:) ...
            - (EPsi_c_w1 + EPsi_c_w1_h1_w1) * guH(j-1) ...
            - (EPsi_c_w2 + EPsi_c_w2_h1_w1) * guH2W(j-1) ...
            - EPsi_c_w1_h1_w2 * guH2W(j-1) ...
            - EPsi_c_w2_h1_w2 * guHW2(j-1)) ...
            * mCD(66*T+j-1,:)' ;
        mom_wHyHc_a(j) = mom_wHyHc_a(j) / sum(mCD(66*T+j-1,:)) ;
        j = j + 1 ;
    end

    j = 3 ;
    while j <= T 
        mom_wHyHc_b(j) = (mC(67*T+j-1,:) ...
            + (EPsi_c_w1 + EPsi_c_w1_h1_w1) * guH(j-1) ...
            + (EPsi_c_w2 + EPsi_c_w2_h1_w1) * guH2W(j-1) ...
            + EPsi_c_w1_h1_w2 * guH2W(j-1) ...
            + EPsi_c_w2_h1_w2 * guHW2(j-1)) ...
            * mCD(67*T+j-1,:)' ; 
        mom_wHyHc_b(j) = mom_wHyHc_b(j) / sum(mCD(67*T+j-1,:)) ;
        j = j + 1 ;
    end


    %   Matrix 3.12: E[DwW DyH Dc] 
    %   -------------------------------------------------------------------

    %   Intertemporal co-variances:
    j = 2 ;
    while j <= T 
        mom_wWyHc_a(j) = (mC(68*T+j-1,:) ...
            - (EPsi_c_w1 + EPsi_c_w1_h1_w1) * guH2W(j-1) ...
            - (EPsi_c_w2 + EPsi_c_w2_h1_w1) * guHW2(j-1) ...
            - EPsi_c_w1_h1_w2 * guHW2(j-1) ...
            - EPsi_c_w2_h1_w2 * guW(j-1)) ...
            * mCD(68*T+j-1,:)' ;
        mom_wWyHc_a(j) = mom_wWyHc_a(j) / sum(mCD(68*T+j-1,:)) ;
        j = j + 1 ;
    end

    j = 3 ;
    while j <= T 
        mom_wWyHc_b(j) = (mC(69*T+j-1,:) ...
            + (EPsi_c_w1 + EPsi_c_w1_h1_w1) * guH2W(j-1) ...
            + (EPsi_c_w2 + EPsi_c_w2_h1_w1) * guHW2(j-1) ...
            + EPsi_c_w1_h1_w2 * guHW2(j-1) ...
            + EPsi_c_w2_h1_w2 * guW(j-1)) ...
            * mCD(69*T+j-1,:)' ; 
        mom_wWyHc_b(j) = mom_wWyHc_b(j) / sum(mCD(69*T+j-1,:)) ;
        j = j + 1 ;
    end


    %   Matrix 1.13: E[DwH DyW Dc]
    %   -------------------------------------------------------------------

    %   Intertemporal co-variances:
    j = 2 ;
    while j <= T 
        mom_wHyWc_a(j) = (mC(70*T+j-1,:) ...
            - EPsi_c_w1_h2_w1 * guH(j-1) ...
            - EPsi_c_w2_h2_w1 * guH2W(j-1) ...
            - (EPsi_c_w1 + EPsi_c_w1_h2_w2) * guH2W(j-1) ...
            - (EPsi_c_w2 + EPsi_c_w2_h2_w2) * guHW2(j-1)) ...      
            * mCD(70*T+j-1,:)' ; 
        mom_wHyWc_a(j) = mom_wHyWc_a(j) / sum(mCD(70*T+j-1,:)) ;
        j = j + 1 ;
    end

    j = 3 ;
    while j <= T
        mom_wHyWc_b(j) = (mC(71*T+j-1,:) ...
            + EPsi_c_w1_h2_w1 * guH(j-1) ...
            + EPsi_c_w2_h2_w1 * guH2W(j-1) ...
            + (EPsi_c_w1 + EPsi_c_w1_h2_w2) * guH2W(j-1) ...
            + (EPsi_c_w2 + EPsi_c_w2_h2_w2) * guHW2(j-1)) ... 
            * mCD(71*T+j-1,:)' ; 
        mom_wHyWc_b(j) = mom_wHyWc_b(j) / sum(mCD(71*T+j-1,:)) ;
        j = j + 1 ;
    end


    %   Matrix 3.13: E[DwW DyW Dc] 
    %   -------------------------------------------------------------------

    %   Intertemporal co-variances:
    j = 2 ;
    while j <= T 
        mom_wWyWc_a(j) = (mC(72*T+j-1,:) ...
            - EPsi_c_w1_h2_w1 * guH2W(j-1) ...
            - EPsi_c_w2_h2_w1 * guHW2(j-1) ...
            - (EPsi_c_w1 + EPsi_c_w1_h2_w2) * guHW2(j-1) ...
            - (EPsi_c_w2 + EPsi_c_w2_h2_w2) * guW(j-1)) ...      
            * mCD(72*T+j-1,:)' ; 
        mom_wWyWc_a(j) = mom_wWyWc_a(j) / sum(mCD(72*T+j-1,:)) ;
        j = j + 1 ;
    end

    j = 3 ;
    while j <= T
        mom_wWyWc_b(j) = (mC(73*T+j-1,:) ...
            + EPsi_c_w1_h2_w1 * guH2W(j-1) ...
            + EPsi_c_w2_h2_w1 * guHW2(j-1) ...
            + (EPsi_c_w1 + EPsi_c_w1_h2_w2) * guHW2(j-1) ...
            + (EPsi_c_w2 + EPsi_c_w2_h2_w2) * guW(j-1)) ... 
            * mCD(73*T+j-1,:)' ; 
        mom_wWyWc_b(j) = mom_wWyWc_b(j) / sum(mCD(73*T+j-1,:)) ;
        j = j + 1 ;
    end
    end %if higher_moments == 1


    %$  DELIVER
    %   Stack vectors of moments together and deliver objective function
    %   criterion
    %   -------------------------------------------------------------------

    %   Stack together (I condition some consumption vectors to 3:T so as 
    %   to remove NaN entries resulting from devision by 0 in years when
    %   consumption is not observed in the data):
    vMoms = [   mean(mom_wHyH_a(2:T))           ; ...
                mean(mom_wHyH_b(start_j:T))     ; ...
                mean(mom_wWyH_a(2:T))           ; ...
                mean(mom_wWyH_b(start_j:T))     ; ...
                mean(mom_wHyW_a(2:T))           ; ...
                mean(mom_wHyW_b(start_j:T))     ; ...
                mean(mom_wWyW_a(2:T))           ; ...
                mean(mom_wWyW_b(start_j:T))     ; ...
                mean(mom_wHc_a(2:T))            ; ...
                mean(mom_wHc_b(3:T))            ; ... 
                mean(mom_wWc_a(2:T))            ; ...
                mean(mom_wWc_b(3:T))            ; ...       
                mean(mom_yHyH_a(start_j:T))     ; ...
                mean(mom_yHyW_a(start_j:T))     ; ...
                mean(mom_yHyW_b(start_j:T))     ; ...
                mean(mom_yWyW_a(start_j:T))     ; ...
                mean(mom_yHc_a(start_j:T))      ; ...
                mean(mom_yHc_b(3:T))            ; ...
                mean(mom_yWc_a(start_j:T))      ; ...
                mean(mom_yWc_b(3:T))            ; ...
                mean(mom_cc_a(3:T)) ]           ;

    if  higher_moments == 1
    v3Moms = [  mean(mom_wH2yH_a(2:T))          ; ...
                mean(mom_wH2yH_b(start_j:T))    ; ...
                mean(mom_wW2yH_a(2:T))          ; ...
                mean(mom_wW2yH_b(start_j:T))    ; ...
                mean(mom_wH2yW_a(2:T))          ; ...
                mean(mom_wH2yW_b(start_j:T))    ; ...
                mean(mom_wW2yW_a(2:T))          ; ... 
                mean(mom_wW2yW_b(start_j:T))    ; ... 
                mean(mom_wH2c_a(2:T))           ; ...
                mean(mom_wH2c_b(3:T))           ; ...
                mean(mom_wW2c_a(2:T))           ; ...
                mean(mom_wW2c_b(3:T))           ; ...
                mean(mom_wHyH2_a(2:T))          ; ...
                mean(mom_wHyH2_b(start_j:T))    ; ...
                mean(mom_wWyH2_a(2:T))          ; ...
                mean(mom_wWyH2_b(start_j:T))    ; ...
                mean(mom_wHyW2_a(2:T))          ; ...
                mean(mom_wHyW2_b(start_j:T))    ; ...
                mean(mom_wWyW2_a(2:T))          ; ...
                mean(mom_wWyW2_b(start_j:T))    ; ...
                mean(mom_wHc2_a(2:T))           ; ...
                mean(mom_wHc2_b(3:T))           ; ...
                mean(mom_wWc2_a(2:T))           ; ...
                mean(mom_wWc2_b(3:T))           ; ...
                mean(mom_wHyHyW_a(2:T))         ; ...
                mean(mom_wHyHyW_b(start_j:T))   ; ...
                mean(mom_wWyHyW_a(2:T))         ; ...
                mean(mom_wWyHyW_b(start_j:T))   ; ...
                mean(mom_wHyHc_a(2:T))          ; ...
                mean(mom_wHyHc_b(3:T))          ; ...
                mean(mom_wWyHc_a(2:T))          ; ...
                mean(mom_wWyHc_b(3:T))          ; ...
                mean(mom_wHyWc_a(2:T))          ; ...
                mean(mom_wHyWc_b(3:T))          ; ...
                mean(mom_wWyWc_a(2:T))          ; ...
                mean(mom_wWyWc_b(3:T)) ]        ;
    vMoms = [vMoms;v3Moms] ;
    end %higher_moments == 1
 
    %   Objective function criterion:
    f = vMoms' * eye(size(vMoms,1)) * vMoms ;
end