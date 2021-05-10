function [foc] = fun_foc_HH_ns(x, temp_EV_A_prime, temp_W1, temp_W2, par, ind_fw)
%{ 
    This function solves for the optimal male hours, given arrays for assets,
    using the problem's first order condition in the non-separable specification.

    This code is an adaptation to the original code provided by Wu & Krueger (2020), 
    'Consumption Insurance Against Wage Risk', published in AEJ-Macro.

    Alexandros Theloudis
    -----------------------------------------------------------------------
%}

    % 	Declare array of male hours:
    temp_H1 = exp(x);

    %	Switch with respect to whether female works of not:
    if      ind_fw==1       % female works	
        %	-marginal rate of substitution between male and female hours:
        temp_H2 = (par.theta1*par.xi*temp_W2/(par.theta2*(1-par.xi)*temp_W1))^(1/(par.theta2-1))*temp_H1.^((par.theta1-1)/(par.theta2-1)) ;
    elseif  ind_fw==0       % female does not work
        %	-zero female hours:
        temp_H2 = zeros(size(temp_H1));
    end

    %	Obtain before tax household income at current wages 
    %   and labor supply choices:
    temp_Y      = temp_W1*temp_H1 + temp_W2*temp_H2 ;
    
    %   Assemble hours part of utility:
    temp_GAMMA  = par.xi*temp_H1.^par.theta1 + (1-par.xi)*temp_H2.^par.theta2 ;
    
    %   Obtain consumption using marginal rate of substitution between
    %   male hours and consumption given that 
    %       u'_[C_{R}]   = \lambda
    %       u'_[H_{1R}]  = \lambda x (\partial f(H_{1R}) / \partial H_{1R})
    %   where f(H_{1R}) is the sequential budget constraint
    %       C_{R} + A_{R+1} = Y_{R} - T(Y_{R}) - \tau*Y_{R} + (1+r)*A_{R}.
    temp_C      = ((par.alpha*((1-par.chi)*(1-par.mu)*temp_Y.^(-par.mu)-par.tau_ss)*temp_W1)./...
                    ((1-par.alpha)*temp_GAMMA.^(-par.gamma/par.theta1-1)*par.xi.*temp_H1.^(par.theta1-1))).^(1/(1-par.gamma));
    
    %   Assemble inner part of utility:
    temp_DELTA  = par.alpha*temp_C.^par.gamma + (1-par.alpha)*temp_GAMMA.^(-par.gamma/par.theta1);
    
    %	Assemble first order condition E(X)=0 - this is effectively the
    %   Euler equation for assets using the envelope theorem:
    foc         = temp_EV_A_prime/(1+par.delta) - temp_DELTA.^((1-par.sigma)/par.gamma-1)*par.alpha.*temp_C.^(par.gamma-1);
end

