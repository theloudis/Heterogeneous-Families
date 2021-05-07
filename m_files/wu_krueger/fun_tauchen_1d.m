function [ zgrid, zprob ] = fun_tauchen_1d( mu, sigma, n )
%{
    Discretize a 1-d normal distribution with Tauchen method.
%}	
	
    %	Grid of standard normal 'z' distribution:
	zgrid = linspace(-3*sigma,3*sigma,n)'+mu;
	
	%   Distance between points on grid:
	d = 6*sigma/(n-1);
	
	%   Mid-point of grid segments:
	prob_cut_point = zgrid(1:n-1) + d/2;
	
	%   Probability that a standard normal draw has a value lower or equal
    %   to relevant mid-point - then difference of that probability from
    %   probability of previous mid-point gives the probability of the 
    %   the grid segment:
	zprob = diff([0; cdf('Normal', prob_cut_point, mu, sigma); 1]);
end

