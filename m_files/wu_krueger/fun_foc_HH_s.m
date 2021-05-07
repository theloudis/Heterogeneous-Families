function [foc] = fun_foc_HH_s(x, temp_C, temp_W1, temp_W2, par, ind_fw)
%{ 
    This function solves for the optimal male hours, given arrays for assets,
    using the problem's first order condition in the separable specification.

    This code is an adaptation to the original code provided by Wu & Krueger (2020), 
    'Consumption Insurance Against Wage Risk', published in AEJ-Macro.

    Alexandros Theloudis
    -----------------------------------------------------------------------
%}

	% 	Declare array of male hours:
	temp_H1 = exp(x);

	%	Switch with respect to whether female works of not:
	if 		ind_fw==1		% female works	
		%	-marginal rate of substitution between male and female hours:
	    temp_H2 = ((par.psi1*temp_W2)/(par.psi2*temp_W1))^par.eta2 * temp_H1.^(par.eta2/par.eta1);
	elseif 	ind_fw==0 		% female does not work
		%	-zero female hours:
	    temp_H2 = zeros(size(temp_H1));
	end

	%	Obtain before tax household income at current wages 
    %   and labor supply choices:
	temp_Y = temp_W1*temp_H1 + temp_W2*temp_H2 ;

	%	Assemble first order condition E(X)=0 - this is effectively the
    %   marginal rate of substitution between consumption and male hours
    %   given that 
    %       u'(C_{R})   = \lambda
    %       u'(H_{1R})  = \lambda x (\partial f(H_{1R}) / \partial H_{1R})
    %   where f(H_{1R}) is the sequential budget constraint
    %       C_{R} + A_{R+1} = Y_{R} - T(Y_{R}) - \tau*Y_{R} + (1+r)*A_{R}.
	foc = (temp_C.^par.sigma).*(par.psi1*temp_H1.^(1/par.eta1)) ... 
        - ((1-par.chi)*(1-par.mu)*temp_Y.^(-par.mu)-par.tau_ss)*temp_W1 ;
end

