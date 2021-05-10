function [Aeq,beq] = model_eqcons(x0, mratios, moments, preference_heterogeneity, labor_xeta)
%{  
    This function constructs the equality constraints implied by 
    symmetry of the Frisch substitution matrix.
   
    It delivers matrix Aeq and vector beq which are used as 
    linear equality constraints in the knitromatlab / fmincon procedures.

    The equality constraint is of the form 
    Aeq * x = beq
    where Aeq is an MxN matrix (M linear equality constraints, N
    parameters) and beq is an Mx1 vector.
    
    Alexandros Theloudis

    -----------------------------------------------------------------------
%}


%%  1.  SYMMETRY OF FRISCH SUBSTITUTION MATRIX AND OTHER RESTRICTIONS
%   Define constraints
%   -----------------------------------------------------------------------

%   1. Frisch symmetry in labor supply cross-elasticities: 
%   eta_h2_w1 - eta_h1_w2 * E[W1*H1/W2*H2] = 0
if isequal(labor_xeta,'off') ~= 1
    Aeq1    = zeros(1,length(x0)) ;
    Aeq1(5) = 1 ;
    Aeq1(4) = -mratios(1) ;
end

%   2. Frisch symmetry in consumption-wage and hours-price elasticities:
%   eta_h1_p + eta_c_w1 * E[C/W1*H1] = 0
if      (moments == -1) && (isequal(labor_xeta,'off') ~= 1)
    Aeq2    = zeros(1,length(x0)) ;
    Aeq2(7) = 1 ;
    Aeq2(1) = mratios(3) ;
elseif  (moments == -1) && (isequal(labor_xeta,'off') == 1)
    Aeq2    = zeros(1,length(x0)) ;
    Aeq2(5) = 1 ;
    Aeq2(1) = mratios(3) ;
end

%   3. Frisch symmetry in consumption-wage and hours-price elasticities:
%   eta_h2_p + eta_c_w2 * E[C/W2*H2] = 0
if      (moments == -1) && (isequal(labor_xeta,'off') ~= 1)
    Aeq3    = zeros(1,length(x0)) ;
    Aeq3(8) = 1 ;
    Aeq3(2) = mratios(4) ;
elseif  (moments == -1) && (isequal(labor_xeta,'off') == 1)
    Aeq3    = zeros(1,length(x0)) ;
    Aeq3(6) = 1 ;
    Aeq3(2) = mratios(4) ;
end

%   4. Covariance between cross-labor elasticities: 
%   COVeta_h1_w2_h2_w1 - E[W1*H1/W2*H2] * Veta_h1_w2 = 0
if isequal(labor_xeta,'off') ~= 1 && preference_heterogeneity >= 1
    Aeq4     = zeros(1,length(x0)) ;
    Aeq4(13) = 1 ;
    Aeq4(10) = -mratios(1) ;
end

if isequal(labor_xeta,'off') ~= 1 && preference_heterogeneity == 2
%   5. Covariances between consumption-male wage and cross-labor elasticities: 
%   COVeta_c_w1_h2_w1 - E[W1*H1/W2*H2] * COVeta_c_w1_h1_w2 = 0
Aeq5     = zeros(1,length(x0)) ;
Aeq5(16) = 1 ;
Aeq5(15) = -mratios(1) ;

%   6. Covariances between consumption-female wage and cross-labor elasticities: 
%   COVeta_c_w2_h2_w1 - E[W1*H1/W2*H2] * COVeta_c_w2_h1_w2 = 0
Aeq6     = zeros(1,length(x0)) ;
Aeq6(20) = 1 ;
Aeq6(19) = -mratios(1) ;

%   7. Covariances between male labor elasticity and cross-labor elasticities: 
%   COVeta_h1_w1_h2_w1 - E[W1*H1/W2*H2] * COVeta_h1_w1_h1_w2 = 0
Aeq7     = zeros(1,length(x0)) ;
Aeq7(23) = 1 ;
Aeq7(22) = -mratios(1) ;

%   8. Covariances between female labor elasticity and cross-labor elasticities: 
%   COVeta_h2_w2_h2_w1 - E[W1*H1/W2*H2] * COVeta_h2_w2_h1_w2 = 0
Aeq8     = zeros(1,length(x0)) ;
Aeq8(27) = 1 ;
Aeq8(26) = -mratios(1) ;
end

if preference_heterogeneity >= 3
%   9.  First moments of hours elasticities E[eta_h1_w1] = E[eta_h2_w2]:
Aeq9     = zeros(1,length(x0)) ;
Aeq9(3) = 1 ;
Aeq9(4) = -1 ;
%   10. Second moments of hours elasticities Veta_h1_w1 = Veta_h2_w2:
Aeq10     = zeros(1,length(x0)) ;
Aeq10(7) = 1 ;
Aeq10(8) = -1 ;
%   11. Covariance of eta_h1_w1 with consumption elasticities:
Aeq11     = zeros(1,length(x0)) ;
Aeq11(10) = 1 ;
Aeq11(12) = -1 ;
%   12. Covariance of eta_h2_w2 with consumption elasticities:
Aeq12     = zeros(1,length(x0)) ;
Aeq12(11) = 1 ;
Aeq12(13) = -1 ;
%   13. Second moments of consumption elasticities Veta_c_w1 = Veta_c_w2:
Aeq13     = zeros(1,length(x0)) ;
Aeq13(5) = 1 ;
Aeq13(6) = -1 ;
%   14. First moments of consumption elasticities Eeta_c_w1 = Eeta_c_w2:
Aeq14     = zeros(1,length(x0)) ;
Aeq14(1) = 1 ;
Aeq14(2) = -1 ;
%   15. Covariance of eta_c_w1 with hours elasticities:
Aeq15     = zeros(1,length(x0)) ;
Aeq15(10) = 1 ;
Aeq15(11) = -1 ;
%   16. Covariance of eta_c_w2 with hours elasticities:
Aeq16     = zeros(1,length(x0)) ;
Aeq16(12) = 1 ;
Aeq16(13) = -1 ;
%   17. Covariance of between hours elasticities:
Aeq17     = zeros(1,length(x0)) ;
Aeq17(14) = 1 ;
Aeq17(7)  = -1 ;
end


%%  2.  DELIVER
%   Stack constraints together
%   -----------------------------------------------------------------------

if      isequal(labor_xeta,'off') ~= 1 && preference_heterogeneity == 0
    Aeq = Aeq1 ;
    beq = zeros(size(Aeq,1),1) ;
    if moments == -1
        Aeq = [Aeq1; Aeq2; Aeq3] ;
        beq = zeros(size(Aeq,1),1) ;
    end %moments
elseif  isequal(labor_xeta,'off') == 1 && preference_heterogeneity == 0
    if moments ~= -1
        Aeq = [] ;
        beq = [] ;
    else
        Aeq = [Aeq2; Aeq3] ;
        beq = zeros(size(Aeq,1),1) ;
    end %moments
elseif  isequal(labor_xeta,'off') ~= 1 && preference_heterogeneity == 1
    Aeq = [Aeq1; Aeq4] ;
    beq = zeros(size(Aeq,1),1) ;
elseif  isequal(labor_xeta,'off') == 1 && preference_heterogeneity == 1
    Aeq = [] ;
    beq = [] ;
elseif  isequal(labor_xeta,'off') ~= 1 && preference_heterogeneity == 2
    Aeq = [Aeq1; Aeq4; Aeq5; Aeq6; Aeq7; Aeq8] ;
    beq = zeros(size(Aeq,1),1) ;
elseif  isequal(labor_xeta,'off') == 1 && preference_heterogeneity == 2
    Aeq = [] ;
    beq = [] ;
elseif  preference_heterogeneity == 5
    Aeq = [Aeq9; Aeq10; Aeq15; Aeq16; Aeq17] ;
    beq = zeros(size(Aeq,1),1) ;
elseif  preference_heterogeneity == 11
    Aeq = [Aeq11; Aeq12; Aeq13; Aeq14] ;
    beq = zeros(size(Aeq,1),1) ;
else
    Aeq = [] ;
    beq = [] ;
end

end