function [c,ceq]=model_nlcons(x, mratios, preference_heterogeneity, labor_xeta)
%{  
    This function constructs the nonlinear equality constraints for the
    parameters of the strcutural model when the added-worker elasticities
    are activated. 
   
    It delivers array c (a vector of nonlinear inequalities such that 
    c(x)<=0) and array ceq (a vector of nonlinear equalities ceq(x)=0).

    Alexandros Theloudis
    -----------------------------------------------------------------------
%}

%   Declare selected parameters:
if isequal(labor_xeta,'off') ~= 1 && preference_heterogeneity == 1

    %   Selected first moments:
    eta_h1_w2  = x(4)  ; % hours1 wrt wage2
    
    %   Selected variances:
    Veta_h1_w2 = x(10) ; % hours1 wrt wage2
    Veta_h2_w1 = x(11) ; % hours2 wrt wage1
        
elseif isequal(labor_xeta,'off') ~= 1 && preference_heterogeneity == 2
    
    %   Selected first moments:
    eta_h1_w2  = x(4)  ; % hours1 wrt wage2
    
    %   All variances:
    Veta_c_w1  = x(7)  ; % consumption wrt wage1
    Veta_c_w2  = x(8)  ; % consumption wrt wage2
    Veta_h1_w1 = x(9)  ; % hours1 wrt wage1
    Veta_h1_w2 = x(10) ; % hours1 wrt wage2
    Veta_h2_w1 = x(11) ; % hours2 wrt wage1
    Veta_h2_w2 = x(12) ; % hours2 wrt wage2
    
    %   All covariances:
    COVeta_c_w1_c_w2   = x(13) ; % consumption wrt wage1 ~ consumption wrt wage2
    COVeta_c_w1_h1_w1  = x(14) ; % consumption wrt wage1 ~ hours1 wrt wage1
    COVeta_c_w1_h1_w2  = x(15) ; % consumption wrt wage1 ~ hours1 wrt wage2
    COVeta_c_w1_h2_w1  = x(16) ; % consumption wrt wage1 ~ hours2 wrt wage1
    COVeta_c_w1_h2_w2  = x(17) ; % consumption wrt wage1 ~ hours2 wrt wage2
    COVeta_c_w2_h1_w1  = x(18) ; % consumption wrt wage2 ~ hours1 wrt wage1
    COVeta_c_w2_h1_w2  = x(19) ; % consumption wrt wage2 ~ hours1 wrt wage2
    COVeta_c_w2_h2_w1  = x(20) ; % consumption wrt wage2 ~ hours2 wrt wage1
    COVeta_c_w2_h2_w2  = x(21) ; % consumption wrt wage2 ~ hours2 wrt wage2
    COVeta_h1_w1_h1_w2 = x(22) ; % hours1 wrt wage1 ~ hours1 wrt wage2
    COVeta_h1_w1_h2_w1 = x(23) ; % hours1 wrt wage1 ~ hours2 wrt wage1
    COVeta_h1_w1_h2_w2 = x(24) ; % hours1 wrt wage1 ~ hours2 wrt wage2
    COVeta_h1_w2_h2_w1 = x(25) ; % hours1 wrt wage2 ~ hours2 wrt wage1
    COVeta_h1_w2_h2_w2 = x(26) ; % hours1 wrt wage2 ~ hours2 wrt wage2
    COVeta_h2_w1_h2_w2 = x(27) ; % hours2 wrt wage1 ~ hours2 wrt wage2

elseif isequal(labor_xeta,'off') == 1 && preference_heterogeneity >= 2
    
    %   Selected averages:
    eta_c_w1 = x(1) ;   % consumption wrt wage1
    eta_c_w2 = x(2) ;   % consumption wrt wage2
    
    %   Selected variances:
    Veta_c_w1  = x(5) ; % consumption wrt wage1
    Veta_c_w2  = x(6) ; % consumption wrt wage2
    Veta_h1_w1 = x(7) ; % hours1 wrt wage1
    Veta_h2_w2 = x(8) ; % hours2 wrt wage2
    
    %   Selected covariances:
    COVeta_c_w1_c_w2   = x(9)  ; % consumption wrt wage1 ~ consumption wrt wage2
    COVeta_c_w1_h1_w1  = x(10) ; % consumption wrt wage1 ~ hours1 wrt wage1
    COVeta_c_w1_h2_w2  = x(11) ; % consumption wrt wage1 ~ hours2 wrt wage2
    COVeta_c_w2_h1_w1  = x(12) ; % consumption wrt wage2 ~ hours1 wrt wage1
    COVeta_c_w2_h2_w2  = x(13) ; % consumption wrt wage2 ~ hours2 wrt wage2
    COVeta_h1_w1_h2_w2 = x(14) ; % hours1 wrt wage1 ~ hours2 wrt wage2

    %   Constant proportion consumption elasticities:
    if (preference_heterogeneity >= 5 && preference_heterogeneity <= 8) || preference_heterogeneity == 10
        propc = x(15) ;
    end
end 


%%  1.  DEFINE NONLINEAR EQUALITY CONSTRAINT
%   Define constraints by preference heterogeneity regime.
%   -----------------------------------------------------------------------

if isequal(labor_xeta,'off') ~= 1 && preference_heterogeneity > 0
    
    %   Nonlinear constraint 1:
    %   Veta_h2_w1 = beta*Veta_h1_w2 + (beta-alpha)*(eta_h1_w2)^2
    %   where: beta = E[(W1*H1/W2*H2)^2], alpha = (E[W1*H1/W2*H2])^2
    ceq = Veta_h2_w1 - mratios(5)*Veta_h1_w2 - (mratios(5)-mratios(1)^2)*(eta_h1_w2)^2 ;

elseif isequal(labor_xeta,'off') == 1 && ((preference_heterogeneity >= 5 && preference_heterogeneity <= 8) || preference_heterogeneity == 10)

    %   Initialize vector of nonlinear equality constraints:
    ceq = zeros(5,1) ;
    
    %   Nonlinear constraint 1:
    %   eta_c_w2 = c*eta_c_w1
    ceq(1) = eta_c_w2 - propc*eta_c_w1 ;

    %   Nonlinear constraint 2:
    %   Veta_c_w2 = c^2*Veta_c_w1
    ceq(2) = Veta_c_w2 - propc^2*Veta_c_w1 ;

    %   Nonlinear constraint 3:
    %   COVeta_c_w1_c_w2 = c*Veta_c_w1
    ceq(3) = COVeta_c_w1_c_w2/sqrt(Veta_c_w1*Veta_c_w2) - sign(propc) ;

    %   Nonlinear constraint 4:
    %   COVeta_c_w2_h1_w1 = c*COVeta_c_w1_h1_w1
    ceq(4) = COVeta_c_w2_h1_w1 - propc*COVeta_c_w1_h1_w1 ;

    %   Nonlinear constraint 5:
    %   COVeta_c_w2_h2_w2 = c*COVeta_c_w1_h2_w2
    ceq(5) = COVeta_c_w2_h2_w2 - propc*COVeta_c_w1_h2_w2 ;
    
     %   Regimes where labor supply elasticities are equal:
    if preference_heterogeneity == 5
        ceq = ceq(1:4) ;
    end %preference_heterogeneity
    
    %   Regimes where covariance of labor supply elasticities is shut down:
    if preference_heterogeneity == 8 || preference_heterogeneity == 10
        ceq = ceq(1:3) ;
    end %preference_heterogeneity

elseif isequal(labor_xeta,'off') == 1 && preference_heterogeneity == 11
    
    %   Nonlinear constraint 1:
    %   COVeta_c_w1_c_w2 = sqrt(Veta_c_w1*Veta_c_w2)
    ceq = COVeta_c_w1_c_w2/sqrt(Veta_c_w1*Veta_c_w2) - 1 ;
    
else
    
    ceq = [] ;

end


%%  2.  NONLINEAR INEQUALITY CONSTRAINTS
%   Define constraints by preference heterogeneity regime.
%   -----------------------------------------------------------------------

%   Ensure that estimated variances and covariances produce meaningful
%   Pearson product-moment correlation coefficients, i.e. [-1,1].
if isequal(labor_xeta,'off') ~= 1 && preference_heterogeneity == 2
    
    %   Declare vector of constraints:
    c = zeros(34,1) ;

    %   C[eta_c_w1,eta_c_w2] / sqrt(V[eta_c_w1]*V[eta_c_w2])
    c(1)  = COVeta_c_w1_c_w2 / sqrt(Veta_c_w1*Veta_c_w2) -1      ;
    c(2)  = -1 - COVeta_c_w1_c_w2 / sqrt(Veta_c_w1*Veta_c_w2)    ;

    %   C[eta_c_w1,eta_h1_w1] / sqrt(V[eta_c_w1]*V[eta_h1_w1])
    c(3)  = COVeta_c_w1_h1_w1 / sqrt(Veta_c_w1*Veta_h1_w1) -1    ;
    c(4)  = -1 - COVeta_c_w1_h1_w1 / sqrt(Veta_c_w1*Veta_h1_w1)  ;

    %   C[eta_c_w1,eta_h1_w2] / sqrt(V[eta_c_w1]*V[eta_h1_w2])
    c(5)  = COVeta_c_w1_h1_w2 / sqrt(Veta_c_w1*Veta_h1_w2) -1    ;
    c(6)  = -1 - COVeta_c_w1_h1_w2 / sqrt(Veta_c_w1*Veta_h1_w2)  ;

    %   C[eta_c_w1,eta_h2_w1] / sqrt(V[eta_c_w1]*V[eta_h2_w1])
    c(7)  = COVeta_c_w1_h2_w1 / sqrt(Veta_c_w1*Veta_h2_w1) -1    ;
    c(8)  = -1 - COVeta_c_w1_h2_w1 / sqrt(Veta_c_w1*Veta_h2_w1)  ;

    %   C[eta_c_w1,eta_h2_w2] / sqrt(V[eta_c_w1]*V[eta_h2_w2])
    c(9)  = COVeta_c_w1_h2_w2 / sqrt(Veta_c_w1*Veta_h2_w2) -1    ;
    c(10) = -1 - COVeta_c_w1_h2_w2 / sqrt(Veta_c_w1*Veta_h2_w2)  ;

    %   C[eta_c_w2,eta_h1_w1] / sqrt(V[eta_c_w2]*V[eta_h1_w1])
    c(11) = COVeta_c_w2_h1_w1 / sqrt(Veta_c_w2*Veta_h1_w1) -1    ;
    c(12) = -1 - COVeta_c_w2_h1_w1 / sqrt(Veta_c_w2*Veta_h1_w1)  ;

    %   C[eta_c_w2,eta_h1_w2] / sqrt(V[eta_c_w2]*V[eta_h1_w2])
    c(13) = COVeta_c_w2_h1_w2 / sqrt(Veta_c_w2*Veta_h1_w2) -1    ;
    c(14) = -1 - COVeta_c_w2_h1_w2 / sqrt(Veta_c_w2*Veta_h1_w2)  ;

    %   C[eta_c_w2,eta_h2_w1] / sqrt(V[eta_c_w2]*V[eta_h2_w1])
    c(15) = COVeta_c_w2_h2_w1 / sqrt(Veta_c_w2*Veta_h2_w1) -1    ;
    c(16) = -1 - COVeta_c_w2_h2_w1 / sqrt(Veta_c_w2*Veta_h2_w1)  ;

    %   C[eta_c_w2,eta_h2_w2] / sqrt(V[eta_c_w2]*V[eta_h2_w2])
    c(17)  = COVeta_c_w2_h2_w2 / sqrt(Veta_c_w2*Veta_h2_w2) -1    ;
    c(18) = -1 - COVeta_c_w2_h2_w2 / sqrt(Veta_c_w2*Veta_h2_w2)  ;

    %   C[eta_h1_w1,eta_h1_w2] / sqrt(V[eta_h1_w1]*V[eta_h1_w2])
    c(19) = COVeta_h1_w1_h1_w2 / sqrt(Veta_h1_w1*Veta_h1_w2) -1  ;
    c(20) = -1 - COVeta_h1_w1_h1_w2 / sqrt(Veta_h1_w1*Veta_h1_w2);

    %   C[eta_h1_w1,eta_h2_w1] / sqrt(V[eta_h1_w1]*V[eta_h2_w1])
    c(21) = COVeta_h1_w1_h2_w1 / sqrt(Veta_h1_w1*Veta_h2_w1) -1  ;
    c(22) = -1 - COVeta_h1_w1_h2_w1 / sqrt(Veta_h1_w1*Veta_h2_w1);

    %   C[eta_h1_w1,eta_h2_w2] / sqrt(V[eta_h1_w1]*V[eta_h2_w2])
    c(23) = COVeta_h1_w1_h2_w2 / sqrt(Veta_h1_w1*Veta_h2_w2) -1  ;
    c(24) = -1 - COVeta_h1_w1_h2_w2 / sqrt(Veta_h1_w1*Veta_h2_w2);

    %   C[eta_h1_w2,eta_h2_w2] / sqrt(V[eta_h1_w2]*V[eta_h2_w2])
    c(25) = COVeta_h1_w2_h2_w2 / sqrt(Veta_h1_w2*Veta_h2_w2) -1  ;
    c(26) = -1 - COVeta_h1_w2_h2_w2 / sqrt(Veta_h1_w2*Veta_h2_w2);

    %   C[eta_h2_w1,eta_h2_w2] / sqrt(V[eta_h2_w1]*V[eta_h2_w2])
    c(27) = COVeta_h2_w1_h2_w2 / sqrt(Veta_h2_w1*Veta_h2_w2) -1  ;
    c(28) = -1 - COVeta_h2_w1_h2_w2 / sqrt(Veta_h2_w1*Veta_h2_w2);

    %   Declare preference covariance matrix and check it is symmetrix:
    %           eta_c_w1            eta_c_w2            eta_h1_w1           eta_h1_w2           eta_h2_w1           eta_h2_w2
    covar = [   Veta_c_w1           COVeta_c_w1_c_w2    COVeta_c_w1_h1_w1   COVeta_c_w1_h1_w2   COVeta_c_w1_h2_w1   COVeta_c_w1_h2_w2   ;
                COVeta_c_w1_c_w2    Veta_c_w2           COVeta_c_w2_h1_w1   COVeta_c_w2_h1_w2   COVeta_c_w2_h2_w1   COVeta_c_w2_h2_w2   ;
                COVeta_c_w1_h1_w1   COVeta_c_w2_h1_w1   Veta_h1_w1          COVeta_h1_w1_h1_w2  COVeta_h1_w1_h2_w1  COVeta_h1_w1_h2_w2  ;
                COVeta_c_w1_h1_w2   COVeta_c_w2_h1_w2   COVeta_h1_w1_h1_w2  Veta_h1_w2          COVeta_h1_w2_h2_w1  COVeta_h1_w2_h2_w2  ;
                COVeta_c_w1_h2_w1   COVeta_c_w2_h2_w1   COVeta_h1_w1_h2_w1  COVeta_h1_w2_h2_w1  Veta_h2_w1          COVeta_h2_w1_h2_w2  ;
                COVeta_c_w1_h2_w2   COVeta_c_w2_h2_w2   COVeta_h1_w1_h2_w2  COVeta_h1_w2_h2_w2  COVeta_h2_w1_h2_w2  Veta_h2_w2 ] ;
    
    % Obtain eigenvalues of preference covariance matrix, impose positive
    % semi-definiteness. All eigenvaluess must be strictly non-negative:
    c(29:34) = -eig(covar) ;
    
elseif isequal(labor_xeta,'off') == 1 && (preference_heterogeneity == 2)
    
    %   Declare vector of constraints:
    c = zeros(16,1) ;

    %   C[eta_c_w1,eta_c_w2] / sqrt(V[eta_c_w1]*V[eta_c_w2])
    c(1)  = COVeta_c_w1_c_w2 / sqrt(Veta_c_w1*Veta_c_w2) -1      ;
    c(2)  = -1 - COVeta_c_w1_c_w2 / sqrt(Veta_c_w1*Veta_c_w2)    ;

    %   C[eta_c_w1,eta_h1_w1] / sqrt(V[eta_c_w1]*V[eta_h1_w1])
    c(3)  = COVeta_c_w1_h1_w1 / sqrt(Veta_c_w1*Veta_h1_w1) -1    ;
    c(4)  = -1 - COVeta_c_w1_h1_w1 / sqrt(Veta_c_w1*Veta_h1_w1)  ;

    %   C[eta_c_w1,eta_h2_w2] / sqrt(V[eta_c_w1]*V[eta_h2_w2])
    c(5)  = COVeta_c_w1_h2_w2 / sqrt(Veta_c_w1*Veta_h2_w2) -1    ;
    c(6)  = -1 - COVeta_c_w1_h2_w2 / sqrt(Veta_c_w1*Veta_h2_w2)  ;

    %   C[eta_c_w2,eta_h1_w1] / sqrt(V[eta_c_w2]*V[eta_h1_w1])
    c(7)  = COVeta_c_w2_h1_w1 / sqrt(Veta_c_w2*Veta_h1_w1) -1    ;      
    c(8)  = -1 - COVeta_c_w2_h1_w1 / sqrt(Veta_c_w2*Veta_h1_w1)  ;  

    %   C[eta_c_w2,eta_h2_w2] / sqrt(V[eta_c_w2]*V[eta_h2_w2])
    c(9)  = COVeta_c_w2_h2_w2 / sqrt(Veta_c_w2*Veta_h2_w2) -1    ;    
    c(10) = -1 - COVeta_c_w2_h2_w2 / sqrt(Veta_c_w2*Veta_h2_w2)  ;  

    %   C[eta_h1_w1,eta_h2_w2] / sqrt(V[eta_h1_w1]*V[eta_h2_w2])
    c(11) = COVeta_h1_w1_h2_w2 / sqrt(Veta_h1_w1*Veta_h2_w2) -1  ;      
    c(12) = -1 - COVeta_h1_w1_h2_w2 / sqrt(Veta_h1_w1*Veta_h2_w2);      

    %   Declare preference covariance matrix and check it is symmetrix:
    %           eta_c_w1            eta_c_w2            eta_h1_w1           eta_h2_w2
    covar = [   Veta_c_w1           COVeta_c_w1_c_w2    COVeta_c_w1_h1_w1   COVeta_c_w1_h2_w2   ;
                COVeta_c_w1_c_w2    Veta_c_w2           COVeta_c_w2_h1_w1   COVeta_c_w2_h2_w2   ;
                COVeta_c_w1_h1_w1   COVeta_c_w2_h1_w1   Veta_h1_w1          COVeta_h1_w1_h2_w2  ;
                COVeta_c_w1_h2_w2   COVeta_c_w2_h2_w2   COVeta_h1_w1_h2_w2  Veta_h2_w2        ] ;
    
    % Obtain eigenvalues of preference covariance matrix, impose positive
    % semi-definiteness. All eigenvaluess must be strictly non-negative:
    c(13:16) = -eig(covar) ;
    
elseif isequal(labor_xeta,'off') == 1 && ((preference_heterogeneity >= 6 && preference_heterogeneity < 8) || preference_heterogeneity == 11)
    
    %   Declare vector of constraints:
    c = zeros(9,1) ;

    %   C[eta_c_w1,eta_h1_w1] / sqrt(V[eta_c_w1]*V[eta_h1_w1])
    c(1)  = COVeta_c_w1_h1_w1 / sqrt(Veta_c_w1*Veta_h1_w1) -1    ;
    c(2)  = -1 - COVeta_c_w1_h1_w1 / sqrt(Veta_c_w1*Veta_h1_w1)  ;

    %   C[eta_c_w1,eta_h2_w2] / sqrt(V[eta_c_w1]*V[eta_h2_w2])
    c(3)  = COVeta_c_w1_h2_w2 / sqrt(Veta_c_w1*Veta_h2_w2) -1    ;
    c(4)  = -1 - COVeta_c_w1_h2_w2 / sqrt(Veta_c_w1*Veta_h2_w2)  ;

    %   C[eta_h1_w1,eta_h2_w2] / sqrt(V[eta_h1_w1]*V[eta_h2_w2])
    c(5) = COVeta_h1_w1_h2_w2 / sqrt(Veta_h1_w1*Veta_h2_w2) -1  ;
    c(6) = -1 - COVeta_h1_w1_h2_w2 / sqrt(Veta_h1_w1*Veta_h2_w2);

    %   Declare preference covariance matrix and check it is symmetrix:
    %         eta_c_w2            eta_h1_w1           eta_h2_w2
    covar = [ Veta_c_w2           COVeta_c_w2_h1_w1   COVeta_c_w2_h2_w2   ;
              COVeta_c_w2_h1_w1   Veta_h1_w1          COVeta_h1_w1_h2_w2  ;
              COVeta_c_w2_h2_w2   COVeta_h1_w1_h2_w2  Veta_h2_w2        ] ;
    
    % Obtain eigenvalues of preference covariance matrix, impose positive
    % semi-definiteness. All eigenvaluess must be strictly non-negative:
    c(7:9) = -eig(covar) ;
    
elseif isequal(labor_xeta,'off') == 1 && preference_heterogeneity == 9
    
    %   Declare vector of constraints:
    c = zeros(2,1) ;

    %   C[eta_c_w1,eta_c_w2] / sqrt(V[eta_c_w1]*V[eta_c_w2])
    c(1)  = COVeta_c_w1_c_w2 / sqrt(Veta_c_w1*Veta_c_w2) -1      ;
    c(2)  = -1 - COVeta_c_w1_c_w2 / sqrt(Veta_c_w1*Veta_c_w2)    ;
    
else
    
    %   No nonlinear inequality contraints:
    c = [] ;
        
end

end