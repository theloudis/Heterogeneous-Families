function [foc] = fun_foc_HH_s_bc(x, temp_A, temp_A_prime, temp_W1, temp_W2, par, ind_fw)
%{ 
    This function solves for the optimal male hours, given arrays for 
    assets, using the problem's first order condition with binding 
    borrowing constraint in the separable specification.

    This code is an adaptation to the original code provided by Wu & Krueger (2020), 
    'Consumption Insurance Against Wage Risk', published in AEJ-Macro.

    Alexandros Theloudis
    -----------------------------------------------------------------------
%}

	% 	Declare array of male hours:
	temp_H1 = exp(x);

	%	Switch with respect to whether female works of not:
	if 		ind_fw==1	% female works	
		%	-marginal rate of substitution between male and female hours:
	    temp_H2 = ((par.psi1*temp_W2)/(par.psi2*temp_W1))^par.eta2 * temp_H1.^(par.eta2/par.eta1);
	elseif 	ind_fw==0	% female does not work
		%	Zero female hours:
	    temp_H2 = zeros(size(temp_H1));
	end

	%	Obtain before tax household income at current wages 
    %   and labor supply choices:
	temp_Y = temp_W1*temp_H1 + temp_W2*temp_H2;

	%	Obtain household consumption at current wages 
    %   and labor supply choices, using marginal rate of substitution
    %   between consumption and male hours:
	temp_C = (((1-par.chi)*(1-par.mu)*temp_Y.^(-par.mu)-par.tau_ss)*temp_W1./(par.psi1*temp_H1.^(1/par.eta1))).^(1/par.sigma);

	%	Assemble first order condition E(X)=0 (request budget constraint holds):
	foc = temp_A - (temp_C + temp_A_prime - (1-par.chi)*temp_Y.^(1-par.mu) + par.tau_ss*temp_Y)/(1+par.r);
end

