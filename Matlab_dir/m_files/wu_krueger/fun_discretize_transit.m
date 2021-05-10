function [ ugrid, u_prob ] = fun_discretize_transit(sqrt_nugrid, O_u)

%{ 
    This function creates grids for the transitory wage components. 

    This code is an adaptation to the original code provided by 
    Wu & Krueger (2020), 'Consumption Insurance Against Wage Risk',
    published in AEJ-Macro.

    Alexandros Theloudis
    -----------------------------------------------------------------------
%}

	%	Obtain standard deviation of transitory shocks:
	O.u     = O_u;
    temp.P  = O.u^0.5;

	%	Declare total number of points on grid counting both spouses:
	nugrid  = sqrt_nugrid^2;

	%	Obtain grid points and probabilities of one-dimensional 
    %   standard normal grid:
	[temp.zzgrid, temp.zzprob] = fun_tauchen_1d(0, 1, sqrt_nugrid);

	%	Replicates marginal grid to produce two 2-dimensional grids and 
    %   their indices (one replicates grids vertically, the other horizonatlly):
	[temp.y1, temp.y2] 				= ndgrid(temp.zzgrid, temp.zzgrid);
	[temp.y1_index,temp.y2_index]	= ndgrid((1:sqrt_nugrid)',(1:sqrt_nugrid)');
	
	%	Vectorizes 2-dimensional grids - puts them side by side in tuple, 
    %   one for male spouse, another for female spouse:
	ygrid 	= [reshape(temp.y1,nugrid,1), reshape(temp.y2,nugrid,1)]';
    
    %   Calculates joint probability of each tuple - i.e. joint grid point,
    %   assuming independence of spousal transitory components:
	y_prob  = reshape(temp.zzprob(temp.y1_index).*temp.zzprob(temp.y2_index), 1, nugrid);
	
	% 	Adjust grid of standard normal by standard deviation of transitory 
    %   shocks; returns probabilities and adjusted grid: 
	ugrid 	= temp.P*ygrid;
	u_prob  = y_prob;
end

