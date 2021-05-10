function [Aeq,beq] = model_eqcons_wk(x0, mratios, moments)
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
Aeq1    = zeros(1,length(x0)) ;
Aeq1(5) = 1 ;
Aeq1(4) = -mratios(1) ;

%   2. Frisch symmetry in consumption-wage and hours-price elasticities:
%   eta_h1_p + eta_c_w1 * E[C/W1*H1] = 0
if moments == -1
    Aeq2    = zeros(1,length(x0)) ;
    Aeq2(7) = 1 ;
    Aeq2(1) = mratios(3) ;
end

%   3. Frisch symmetry in consumption-wage and hours-price elasticities:
%   eta_h2_p + eta_c_w2 * E[C/W2*H2] = 0
if moments == -1
    Aeq3    = zeros(1,length(x0)) ;
    Aeq3(8) = 1 ;
    Aeq3(2) = mratios(4) ;
end


%%  2.  DELIVER
%   Stack constraints together
%   -----------------------------------------------------------------------

%   Operates only without preference heterogeneity:
Aeq = Aeq1 ;
beq = zeros(size(Aeq,1),1) ;
if moments == -1
	Aeq = [Aeq1; Aeq2; Aeq3] ;
	beq = zeros(size(Aeq,1),1) ;
end %moments


end