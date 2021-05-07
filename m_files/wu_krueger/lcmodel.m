
%%  Simulation of quantitative model
%
%   'Consumption Inequality across Heterogeneous Families'
%   This script solves and simulates Wu & Krueger (2020)'s lifecycle model
%	for consumption and family labor supply under various configurations 
%   for preferences and heterogeneity.
%	
%	This code is an adaptation to the original code provided by 
%	Wu & Krueger (2020), 'Consumption Insurance Against Wage Risk',
%	published in AEJ-Macro.
%
%   Alexandros Theloudis
%   LISER Luxembourg 
%   Tilburg Econometrics & Operations Research 
%   Spring 2021
%
%   =======================================================================

%   Initial statements:
global dDir unidim_nFgrid unidim_nugrid ;

%   Define model features:
ind.bc              = 0 ; 		% benchmark borrowing constraints (0); zero borrowing constraints (1); non-binding borrowing constraints (2).
ind.faw             = 1;        % 1 for intensive margin only; 0 for extensive and intensive margin.
ind.heterogeneity   = 1; 
ind.age_range       = 1;        % 0 for BPS age range (10-37); 1 for my age range (10-40)


%%	A. DECLARE BASELINE PARAMETER STRUCTURE
%	Initializes model parameters common across all specifications.
%   -----------------------------------------------------------------------

% 	Set baseline parameter values:
%   -simulated population size:
par.sim_N           = 50000 ;                   % number of simulated households
%   -wage grids:
unidim_nFgrid       = 11 ;                      % number of grid points on each dimension for permanent wage component (11)
unidim_nugrid       = 5 ;                       % number of grid points on each dimension for transitory wage component (5)
%	-length of time:
par.R               = 45; 						% length of working life
par.T               = 60; 						% length of life cycle
%	-interest rate:
par.r               = 0.02; 					% interest rate
%	-wage trend:
par.w1              = 0.7120; 					% male wage level
par.gtrend1         = log(importdata('wage_profile_rz2012_interp.mat')); % productivity trend for male
par.gtrend2         = log(importdata('wage_profile_rz2012_interp.mat')); % productivity trend for female
%	-wage process:
par.O_F_initial     = [0,0;0,0];                % covariance matrix of initial permanent component
par.rho1            = 0.99669; 					% persistence of male permanent shocks (targeting joint unit-root process with 11*11 grid).
par.rho2            = 0.99692; 					% persistence of female permanent shocks (targeting joint unit-root process with 11*11 grid).
par.O_v             = [0.02447,0.00218;...      % covariance matrix of permanent shocks
                       0.00218,0.03089];        % targeting [0.0303,0.0027;0.0027,0.0382] with 11*11 grid.
par.O_u             = [0.02327,0.00499;...      % covariance matrix of transitory shocks
                       0.00499,0.01060];        % targeting [0.0290,0.0041;0.0041,0.0132] with 5*5 grid in seperable model; [0.0275,0.0058;0.0058,0.0125] in non-sep.
%   -baseline tax & benefits parameters:
par.mu              = 0.0 ; 					% income tax progressivity (Wu & Krueger: 0.1327)
par.chi             = 0.0 ; 					% income tax level (Wu & Krueger: 0.1575)
par.tau_ss          = 0.0 ; 					% payroll tax rate (Wu & Krueger: 0.0765)
par.rb              = 0.3703; 					% retirement benefit
%	-borrowing constraints:
switch ind.bc
	case 0 % benchmark borrowing constraint
    	par.bc = (-0.126)*(1+par.r).^(0:par.R);
	case 1 % zero borrowing constraint
     	par.bc = 0*ones(1,par.R+1);
end 


%%  B.  SOLVE AND SIMULATE NON-SEPARABLE MODEL OVER VECTOR OF PREFERENCES
%   Simulate populations of households; each population differs in preferences.
%   -----------------------------------------------------------------------

%   Declare model is non-separable:
ind.separable       = 0;        % 1 for separable model; 0 for non-separable.
    
%   Define preference structure specific to nonseparable model, common 
%   across various specifications:
%	-utility parameters:
par.delta           = 0.01006 ;                 % discount rate (discount factor is 1/(1+delta))
par.alpha           = 0.124 ;                   % utility weight of consumption
par.xi              = 0.413 ;                   % utility weight of male labor supply 
par.sigma           = 2.24 ;                    % consumption IES (reciprocal is Frisch elasticity eta_cp; original = 2.24)
if ind.faw==0
	par.f           = 0.0155*ones(par.R,1) ;    % fixed utility cost of female participation
else
    par.f           = zeros(par.R,1) ;          % fixed utility cost of female participation 
end
par.PSI             = 0.695 ;                   % governs consumption level after retirement
%   -female wage gap:
par.w2              = 0.499*par.w1;             % female wage level (gender wage gap in trends)

%   Simulate populations of households, each with different Frisch
%   elasticities if preference heterogeneity is enabled:
fprintf('Starting non-separable lifecycle model.\n')

%   Population I is always simulated:
fprintf('Population I.\n')
par.gamma                   = -3.00 ;               % governs the substitution pattern between consumption and labor supply (original = -3)
par.theta1                  = 3.00 ;                % governs the subsstitution patter between male and femal labor supply (original = 3)
par.theta2                  = par.theta1 ;          % governs the subsstitution patter between male and femal labor supply
[~, ~, sim_array_I]         = lcmodel_nonseparable(par, ind) ;
    
%   Additional populations, if heterogeneity is allowed:
if ind.heterogeneity==1
        
	%   Population II:
	fprintf('Population II.\n')
	par.gamma               = -2.00 ;               % governs the substitution pattern between consumption and labor supply 
	par.theta1              = 4.00 ;                % governs the subsstitution patter between male and femal labor supply
	par.theta2              = par.theta1 ;          % governs the subsstitution patter between male and femal labor supply
	[~, ~, sim_array_II]    = lcmodel_nonseparable(par, ind) ;
        
	%   Population III:
	fprintf('Population III.\n')
	par.gamma               = -3.50 ;               % governs the substitution pattern between consumption and labor supply
	par.theta1              = 2.30 ;                % governs the subsstitution patter between male and femal labor supply
	par.theta2              = par.theta1 ;          % governs the subsstitution patter between male and femal labor supply
	[~, ~, sim_array_III]   = lcmodel_nonseparable(par, ind) ;
        
	%   Population IV:
	fprintf('Population IV.\n')
	par.gamma               = -3.90 ;               % governs the substitution pattern between consumption and labor supply 
	par.theta1              = 3.50 ;                % governs the subsstitution patter between male and femal labor supply 
	par.theta2              = par.theta1 ;          % governs the subsstitution patter between male and femal labor supply
	[~, ~, sim_array_IV]    = lcmodel_nonseparable(par, ind) ;
end

%   Place population data into cell:
if ind.heterogeneity==1
	sim_arrays              = {sim_array_I,sim_array_II,sim_array_III,sim_array_IV} ;  % mix populations
else
	sim_arrays              = {sim_array_I} ;
end

%   Run first stage regressions, estimate parameters on entire population:
[~, sim_results_ns]         = fun_estimate_parameters(sim_arrays, 'iter') ;


%%  C.  SMALL SAMPLE ANALYSIS OF NON-SEPARABLE MODEL WITH PREFERENCE HETEROGENEITY
%   Simulate populations of households; each population differs in preferences.
%   -----------------------------------------------------------------------

%   Declare model is non-separable:
ind.separable   = 0;        % 1 for separable model; 0 for non-separable.

%   Here I calculate the parameters of the parameters of the model based on
%   a small sample of 6032 observations (households x periods). This is
%   comparable to the sample of 6071 observations in the PSID. To do so,
%   I draw four samples of 1508 observations from each of the four 
%   underlying heterogeneous populations. Given that the length of panel is
%   29 periods, the number of households I must draw from each population
%   is 52, i.e. 52*29 = 1508.
small_sim_N     = 52 ;

%   I repeat the process 500 times, and calculate the average parameter 
%   estimates across small samples, as well as their standard errors.
small_rounds    = 500 ;

%   Initialize structure that will hold the results:
temp_small_sample_results(small_rounds) = struct() ;
sim_results_small.true_eta_cp           = zeros(1,small_rounds) ;
sim_results_small.true_Frisch           = zeros(12,small_rounds) ;
sim_results_small.true_covarv           = zeros(3,small_rounds) ;
sim_results_small.true_covaru           = zeros(3,small_rounds) ;
sim_results_small.N                     = zeros(1,small_rounds) ;
sim_results_small.T                     = zeros(1,small_rounds) ;
sim_results_small.sim_vWageHat          = zeros(6,small_rounds) ;
sim_results_small.sim_vModelHat_BPS     = zeros(8,small_rounds) ;
sim_results_small.sim_vModelHat_TRANS   = zeros(6,small_rounds) ;

%   Retrieve data and estimate the parameters:
for i=1:1:small_rounds
    
    %   Retrieve arrays within each population:
    %   Population I:    
    small_sim_array_I.C             = sim_array_I.C(((i-1)*small_sim_N+1):(i*small_sim_N),:);
    small_sim_array_I.H1            = sim_array_I.H1(((i-1)*small_sim_N+1):(i*small_sim_N),:);
    small_sim_array_I.H2            = sim_array_I.H2(((i-1)*small_sim_N+1):(i*small_sim_N),:);
    small_sim_array_I.dC            = sim_array_I.dC(((i-1)*small_sim_N+1):(i*small_sim_N),:);
    small_sim_array_I.dY1           = sim_array_I.dY1(((i-1)*small_sim_N+1):(i*small_sim_N),:);
    small_sim_array_I.dY2           = sim_array_I.dY2(((i-1)*small_sim_N+1):(i*small_sim_N),:);
    small_sim_array_I.dW1           = sim_array_I.dW1(((i-1)*small_sim_N+1):(i*small_sim_N),:);
    small_sim_array_I.dW2           = sim_array_I.dW2(((i-1)*small_sim_N+1):(i*small_sim_N),:);
    small_sim_array_I.v1            = sim_array_I.v1(((i-1)*small_sim_N+1):(i*small_sim_N),:);
    small_sim_array_I.v2            = sim_array_I.v2(((i-1)*small_sim_N+1):(i*small_sim_N),:);
    small_sim_array_I.u1            = sim_array_I.u1(((i-1)*small_sim_N+1):(i*small_sim_N),:);
    small_sim_array_I.u2            = sim_array_I.u2(((i-1)*small_sim_N+1):(i*small_sim_N),:);
    small_sim_array_I.pi            = sim_array_I.pi(((i-1)*small_sim_N+1):(i*small_sim_N),:);
    small_sim_array_I.s             = sim_array_I.s(((i-1)*small_sim_N+1):(i*small_sim_N),:);
    small_sim_array_I.q             = sim_array_I.q(((i-1)*small_sim_N+1):(i*small_sim_N),:);
    small_sim_array_I.ratios        = sim_array_I.ratios;
    small_sim_array_I.eta_cw1       = sim_array_I.eta_cw1(((i-1)*small_sim_N+1):(i*small_sim_N),:);
    small_sim_array_I.eta_cw2       = sim_array_I.eta_cw2(((i-1)*small_sim_N+1):(i*small_sim_N),:);
    small_sim_array_I.eta_h1w1      = sim_array_I.eta_h1w1(((i-1)*small_sim_N+1):(i*small_sim_N),:);
    small_sim_array_I.eta_h1w2      = sim_array_I.eta_h1w2(((i-1)*small_sim_N+1):(i*small_sim_N),:);
    small_sim_array_I.eta_h2w1      = sim_array_I.eta_h2w1(((i-1)*small_sim_N+1):(i*small_sim_N),:);
    small_sim_array_I.eta_h2w2      = sim_array_I.eta_h2w2(((i-1)*small_sim_N+1):(i*small_sim_N),:);
    small_sim_array_I.eta_h1p       = sim_array_I.eta_h1p(((i-1)*small_sim_N+1):(i*small_sim_N),:);
    small_sim_array_I.eta_h2p       = sim_array_I.eta_h2p(((i-1)*small_sim_N+1):(i*small_sim_N),:);
    small_sim_array_I.eta_cp        = sim_array_I.eta_cp(((i-1)*small_sim_N+1):(i*small_sim_N),:);
    small_sim_array_I.sT            = sim_array_I.sT ;
    small_sim_array_I.N             = small_sim_N ;
    small_sim_array_I.age_start     = sim_array_I.age_start ;
    small_sim_array_I.age_end       = sim_array_I.age_end ;
    
    %   Population II:
    small_sim_array_II.C            = sim_array_II.C(((i-1)*small_sim_N+1):(i*small_sim_N),:);
    small_sim_array_II.H1           = sim_array_II.H1(((i-1)*small_sim_N+1):(i*small_sim_N),:);
    small_sim_array_II.H2           = sim_array_II.H2(((i-1)*small_sim_N+1):(i*small_sim_N),:);
    small_sim_array_II.dC           = sim_array_II.dC(((i-1)*small_sim_N+1):(i*small_sim_N),:);
    small_sim_array_II.dY1          = sim_array_II.dY1(((i-1)*small_sim_N+1):(i*small_sim_N),:);
    small_sim_array_II.dY2          = sim_array_II.dY2(((i-1)*small_sim_N+1):(i*small_sim_N),:);
    small_sim_array_II.dW1          = sim_array_II.dW1(((i-1)*small_sim_N+1):(i*small_sim_N),:);
    small_sim_array_II.dW2          = sim_array_II.dW2(((i-1)*small_sim_N+1):(i*small_sim_N),:);
    small_sim_array_II.v1           = sim_array_II.v1(((i-1)*small_sim_N+1):(i*small_sim_N),:);
    small_sim_array_II.v2           = sim_array_II.v2(((i-1)*small_sim_N+1):(i*small_sim_N),:);
    small_sim_array_II.u1           = sim_array_II.u1(((i-1)*small_sim_N+1):(i*small_sim_N),:);
    small_sim_array_II.u2           = sim_array_II.u2(((i-1)*small_sim_N+1):(i*small_sim_N),:);
    small_sim_array_II.pi           = sim_array_II.pi(((i-1)*small_sim_N+1):(i*small_sim_N),:);
    small_sim_array_II.s            = sim_array_II.s(((i-1)*small_sim_N+1):(i*small_sim_N),:);
    small_sim_array_II.q            = sim_array_II.q(((i-1)*small_sim_N+1):(i*small_sim_N),:);
    small_sim_array_II.ratios       = sim_array_II.ratios;
    small_sim_array_II.eta_cw1      = sim_array_II.eta_cw1(((i-1)*small_sim_N+1):(i*small_sim_N),:);
    small_sim_array_II.eta_cw2      = sim_array_II.eta_cw2(((i-1)*small_sim_N+1):(i*small_sim_N),:);
    small_sim_array_II.eta_h1w1     = sim_array_II.eta_h1w1(((i-1)*small_sim_N+1):(i*small_sim_N),:);
    small_sim_array_II.eta_h1w2     = sim_array_II.eta_h1w2(((i-1)*small_sim_N+1):(i*small_sim_N),:);
    small_sim_array_II.eta_h2w1     = sim_array_II.eta_h2w1(((i-1)*small_sim_N+1):(i*small_sim_N),:);
    small_sim_array_II.eta_h2w2     = sim_array_II.eta_h2w2(((i-1)*small_sim_N+1):(i*small_sim_N),:);
    small_sim_array_II.eta_h1p      = sim_array_II.eta_h1p(((i-1)*small_sim_N+1):(i*small_sim_N),:);
    small_sim_array_II.eta_h2p      = sim_array_II.eta_h2p(((i-1)*small_sim_N+1):(i*small_sim_N),:);
    small_sim_array_II.eta_cp       = sim_array_II.eta_cp(((i-1)*small_sim_N+1):(i*small_sim_N),:);
    small_sim_array_II.sT           = sim_array_II.sT ;
    small_sim_array_II.N            = small_sim_N ;
    small_sim_array_II.age_start    = sim_array_II.age_start ;
    small_sim_array_II.age_end      = sim_array_II.age_end ;
    
    %   Population III:
    small_sim_array_III.C           = sim_array_III.C(((i-1)*small_sim_N+1):(i*small_sim_N),:);
    small_sim_array_III.H1          = sim_array_III.H1(((i-1)*small_sim_N+1):(i*small_sim_N),:);
    small_sim_array_III.H2          = sim_array_III.H2(((i-1)*small_sim_N+1):(i*small_sim_N),:);
    small_sim_array_III.dC          = sim_array_III.dC(((i-1)*small_sim_N+1):(i*small_sim_N),:);
    small_sim_array_III.dY1         = sim_array_III.dY1(((i-1)*small_sim_N+1):(i*small_sim_N),:);
    small_sim_array_III.dY2         = sim_array_III.dY2(((i-1)*small_sim_N+1):(i*small_sim_N),:);
    small_sim_array_III.dW1         = sim_array_III.dW1(((i-1)*small_sim_N+1):(i*small_sim_N),:);
    small_sim_array_III.dW2         = sim_array_III.dW2(((i-1)*small_sim_N+1):(i*small_sim_N),:);
    small_sim_array_III.v1          = sim_array_III.v1(((i-1)*small_sim_N+1):(i*small_sim_N),:);
    small_sim_array_III.v2          = sim_array_III.v2(((i-1)*small_sim_N+1):(i*small_sim_N),:);
    small_sim_array_III.u1          = sim_array_III.u1(((i-1)*small_sim_N+1):(i*small_sim_N),:);
    small_sim_array_III.u2          = sim_array_III.u2(((i-1)*small_sim_N+1):(i*small_sim_N),:);
    small_sim_array_III.pi          = sim_array_III.pi(((i-1)*small_sim_N+1):(i*small_sim_N),:);
    small_sim_array_III.s           = sim_array_III.s(((i-1)*small_sim_N+1):(i*small_sim_N),:);
    small_sim_array_III.q           = sim_array_III.q(((i-1)*small_sim_N+1):(i*small_sim_N),:);
    small_sim_array_III.ratios      = sim_array_III.ratios;
    small_sim_array_III.eta_cw1     = sim_array_III.eta_cw1(((i-1)*small_sim_N+1):(i*small_sim_N),:);
    small_sim_array_III.eta_cw2     = sim_array_III.eta_cw2(((i-1)*small_sim_N+1):(i*small_sim_N),:);
    small_sim_array_III.eta_h1w1    = sim_array_III.eta_h1w1(((i-1)*small_sim_N+1):(i*small_sim_N),:);
    small_sim_array_III.eta_h1w2    = sim_array_III.eta_h1w2(((i-1)*small_sim_N+1):(i*small_sim_N),:);
    small_sim_array_III.eta_h2w1    = sim_array_III.eta_h2w1(((i-1)*small_sim_N+1):(i*small_sim_N),:);
    small_sim_array_III.eta_h2w2    = sim_array_III.eta_h2w2(((i-1)*small_sim_N+1):(i*small_sim_N),:);
    small_sim_array_III.eta_h1p     = sim_array_III.eta_h1p(((i-1)*small_sim_N+1):(i*small_sim_N),:);
    small_sim_array_III.eta_h2p     = sim_array_III.eta_h2p(((i-1)*small_sim_N+1):(i*small_sim_N),:);
    small_sim_array_III.eta_cp      = sim_array_III.eta_cp(((i-1)*small_sim_N+1):(i*small_sim_N),:);
    small_sim_array_III.sT          = sim_array_III.sT ;
    small_sim_array_III.N           = small_sim_N ;
    small_sim_array_III.age_start   = sim_array_III.age_start ;
    small_sim_array_III.age_end     = sim_array_III.age_end ;
    
    %   Population IV:
    small_sim_array_IV.C            = sim_array_IV.C(((i-1)*small_sim_N+1):(i*small_sim_N),:);
    small_sim_array_IV.H1           = sim_array_IV.H1(((i-1)*small_sim_N+1):(i*small_sim_N),:);
    small_sim_array_IV.H2           = sim_array_IV.H2(((i-1)*small_sim_N+1):(i*small_sim_N),:);
    small_sim_array_IV.dC           = sim_array_IV.dC(((i-1)*small_sim_N+1):(i*small_sim_N),:);
    small_sim_array_IV.dY1          = sim_array_IV.dY1(((i-1)*small_sim_N+1):(i*small_sim_N),:);
    small_sim_array_IV.dY2          = sim_array_IV.dY2(((i-1)*small_sim_N+1):(i*small_sim_N),:);
    small_sim_array_IV.dW1          = sim_array_IV.dW1(((i-1)*small_sim_N+1):(i*small_sim_N),:);
    small_sim_array_IV.dW2          = sim_array_IV.dW2(((i-1)*small_sim_N+1):(i*small_sim_N),:);
    small_sim_array_IV.v1           = sim_array_IV.v1(((i-1)*small_sim_N+1):(i*small_sim_N),:);
    small_sim_array_IV.v2           = sim_array_IV.v2(((i-1)*small_sim_N+1):(i*small_sim_N),:);
    small_sim_array_IV.u1           = sim_array_IV.u1(((i-1)*small_sim_N+1):(i*small_sim_N),:);
    small_sim_array_IV.u2           = sim_array_IV.u2(((i-1)*small_sim_N+1):(i*small_sim_N),:);
    small_sim_array_IV.pi           = sim_array_IV.pi(((i-1)*small_sim_N+1):(i*small_sim_N),:);
    small_sim_array_IV.s            = sim_array_IV.s(((i-1)*small_sim_N+1):(i*small_sim_N),:);
    small_sim_array_IV.q            = sim_array_IV.q(((i-1)*small_sim_N+1):(i*small_sim_N),:);
    small_sim_array_IV.ratios       = sim_array_IV.ratios;
    small_sim_array_IV.eta_cw1      = sim_array_IV.eta_cw1(((i-1)*small_sim_N+1):(i*small_sim_N),:);
    small_sim_array_IV.eta_cw2      = sim_array_IV.eta_cw2(((i-1)*small_sim_N+1):(i*small_sim_N),:);
    small_sim_array_IV.eta_h1w1     = sim_array_IV.eta_h1w1(((i-1)*small_sim_N+1):(i*small_sim_N),:);
    small_sim_array_IV.eta_h1w2     = sim_array_IV.eta_h1w2(((i-1)*small_sim_N+1):(i*small_sim_N),:);
    small_sim_array_IV.eta_h2w1     = sim_array_IV.eta_h2w1(((i-1)*small_sim_N+1):(i*small_sim_N),:);
    small_sim_array_IV.eta_h2w2     = sim_array_IV.eta_h2w2(((i-1)*small_sim_N+1):(i*small_sim_N),:);
    small_sim_array_IV.eta_h1p      = sim_array_IV.eta_h1p(((i-1)*small_sim_N+1):(i*small_sim_N),:);
    small_sim_array_IV.eta_h2p      = sim_array_IV.eta_h2p(((i-1)*small_sim_N+1):(i*small_sim_N),:);
    small_sim_array_IV.eta_cp       = sim_array_IV.eta_cp(((i-1)*small_sim_N+1):(i*small_sim_N),:);
    small_sim_array_IV.sT           = sim_array_IV.sT ;
    small_sim_array_IV.N            = small_sim_N ;
    small_sim_array_IV.age_start    = sim_array_IV.age_start ;
    small_sim_array_IV.age_end      = sim_array_IV.age_end ;

    %   Pool sample data into cell:
    small_sim_arrays = {small_sim_array_I,small_sim_array_II,small_sim_array_III,small_sim_array_IV} ;  % mix samples
    
    %   Run first stage regressions, estimate parameters on entire sample:
    [~, temp_small_sample_results(i).sim_results] = fun_estimate_parameters(small_sim_arrays, 'notify-detailed') ;
    
    %   Place results into arrays:
    sim_results_small.true_eta_cp(:,i)          = temp_small_sample_results(i).sim_results.true_eta_cp ;
    sim_results_small.true_Frisch(:,i)          = temp_small_sample_results(i).sim_results.true_Frisch ;
    sim_results_small.true_covarv(:,i)          = temp_small_sample_results(i).sim_results.true_covarv ;
    sim_results_small.true_covaru(:,i)          = temp_small_sample_results(i).sim_results.true_covaru ;
    sim_results_small.N(:,i)                    = temp_small_sample_results(i).sim_results.N ;
    sim_results_small.T(:,i)                    = temp_small_sample_results(i).sim_results.T ;
    sim_results_small.sim_vWageHat(:,i)         = temp_small_sample_results(i).sim_results.sim_vWageHat ;
    sim_results_small.sim_vModelHat_BPS(:,i)    = temp_small_sample_results(i).sim_results.sim_vModelHat_BPS ;
    sim_results_small.sim_vModelHat_TRANS(:,i)  = temp_small_sample_results(i).sim_results.sim_vModelHat_TRANS ;
    
    %   Report progress:
    fprintf('Finished small sample quant_model round : %u\n',i)
end

%   Calculate true and estimated parameters:
%   -eta_c_p
sim_results_small.true_eta_cp_avg               = mean(sim_results_small.true_eta_cp(1,:)) ;
%   -true Frisch elasticities:
sim_results_small.true_Frisch_avg               = mean(sim_results_small.true_Frisch,2) ;
%   -true wage moments:
sim_results_small.true_covarv_avg               = mean(sim_results_small.true_covarv,2) ;
sim_results_small.true_covaru_avg               = mean(sim_results_small.true_covaru,2) ;
%   -estimated wage moments (point estimates and standard error):
sim_results_small.sim_vWageHat_avg              = mean(sim_results_small.sim_vWageHat,2) ;
sim_results_small.sim_vWageHat_std              = std(sim_results_small.sim_vWageHat,1,2) ;
%   -estimated model parameters / BPS (point estimates and standard error):
sim_results_small.sim_vModelHat_BPS_avg         = mean(sim_results_small.sim_vModelHat_BPS,2) ;
sim_results_small.sim_vModelHat_BPS_std         = std(sim_results_small.sim_vModelHat_BPS,1,2) ;
%   -estimated model parameters / TRANS (point estimates and standard error):
sim_results_small.sim_vModelHat_TRANS_avg       = mean(sim_results_small.sim_vModelHat_TRANS,2) ;
sim_results_small.sim_vModelHat_TRANS_std       = std(sim_results_small.sim_vModelHat_TRANS,1,2) ;
clearvars small_sim_array_* temp_small_sample_results


%%  D.  NON-SEPARABLE MODEL: HETEROGENEITY in the DISCOUNT FACTOR
%   Heterogeneity in discount factor: 4 heterogeneous populations, 4 discount factors
%   -----------------------------------------------------------------------

%   Declare model is non-separable:
ind.separable       = 0;        % 1 for separable model; 0 for non-separable.
    
%   Define preference structure specific to nonseparable model, common 
%   across various specifications:
%	-utility parameters:
par.alpha           = 0.124 ;                   % utility weight of consumption
par.xi              = 0.413 ;                   % utility weight of male labor supply 
par.sigma           = 2.24 ;                    % consumption IES (reciprocal is Frisch elasticity eta_cp; original = 2.24)
if ind.faw==0
	par.f           = 0.0155*ones(par.R,1) ;    % fixed utility cost of female participation
else
 	par.f           = zeros(par.R,1) ;          % fixed utility cost of female participation 
end
par.PSI             = 0.695 ;                   % governs consumption level after retirement
%   -female wage gap:
par.w2              = 0.499*par.w1;             % female wage level (gender wage gap in trends)

%   Simulate populations of households, each with different Frisch
%   elasticities if preference heterogeneity is enabled:
fprintf('Starting non-separable lifecycle model; heterogeneity in discount factor (4).\n')

%   Population I:
fprintf('Population I.\n')
par.delta               = 0.01006 ;             % discount rate (discount factor is 1/(1+delta))
par.gamma               = -3.00 ;               % governs the substitution pattern between consumption and labor supply (original = -3)
par.theta1              = 3.00 ;                % governs the subsstitution patter between male and femal labor supply (original = 3)
par.theta2              = par.theta1 ;          % governs the subsstitution patter between male and femal labor supply
[~, ~, sim_array_I]     = lcmodel_nonseparable(par, ind) ;
    
%   Population II:
fprintf('Population II.\n')
par.delta               = 0.02 ;                % discount rate (discount factor is 1/(1+delta))
par.gamma               = -2.00 ;               % governs the substitution pattern between consumption and labor supply 
par.theta1              = 4.00 ;                % governs the subsstitution patter between male and femal labor supply
par.theta2              = par.theta1 ;          % governs the subsstitution patter between male and femal labor supply
[~, ~, sim_array_II]    = lcmodel_nonseparable(par, ind) ;
        
%   Population III:
fprintf('Population III.\n')
par.delta               = 0.03 ;                % discount rate (discount factor is 1/(1+delta))
par.gamma               = -3.50 ;               % governs the substitution pattern between consumption and labor supply
par.theta1              = 2.30 ;                % governs the subsstitution patter between male and femal labor supply
par.theta2              = par.theta1 ;          % governs the subsstitution patter between male and femal labor supply
[~, ~, sim_array_III]   = lcmodel_nonseparable(par, ind) ;
        
%   Population IV:
fprintf('Population IV.\n')
par.delta               = 0.05 ;                % discount rate (discount factor is 1/(1+delta))
par.gamma               = -3.90 ;               % governs the substitution pattern between consumption and labor supply 
par.theta1              = 3.50 ;                % governs the subsstitution patter between male and femal labor supply 
par.theta2              = par.theta1 ;          % governs the subsstitution patter between male and femal labor supply
[~, ~, sim_array_IV]    = lcmodel_nonseparable(par, ind) ;

%   Place population data into cell - mix populations:
sim_arrays              = {sim_array_I,sim_array_II,sim_array_III,sim_array_IV} ; 

%   Run first stage regressions, estimate parameters on entire population:
[~, sim_results_ns_delta4]    = fun_estimate_parameters(sim_arrays, 'iter') ;


%%  E.  NON-SEPARABLE MODEL: HETEROGENEITY in the INTERTEMPORAL ELASTICITY OF SUBSTITUTION
%   Heterogeneity in discount factor: 4 heterogeneous populations, 4 ies
%   -----------------------------------------------------------------------

%   Declare model is non-separable:
ind.separable       = 0;        % 1 for separable model; 0 for non-separable.
    
%   Define preference structure specific to nonseparable model, common 
%   across various specifications:
%	-utility parameters:
par.delta           = 0.01006 ;                 % discount rate (discount factor is 1/(1+delta))
par.alpha           = 0.124 ;                   % utility weight of consumption
par.xi              = 0.413 ;                   % utility weight of male labor supply 
if ind.faw==0
	par.f           = 0.0155*ones(par.R,1) ;    % fixed utility cost of female participation
else
 	par.f           = zeros(par.R,1) ;          % fixed utility cost of female participation 
end
par.PSI             = 0.695 ;                   % governs consumption level after retirement
%   -female wage gap:
par.w2              = 0.499*par.w1;             % female wage level (gender wage gap in trends)

%   Simulate populations of households, each with different Frisch
%   elasticities if preference heterogeneity is enabled:
fprintf('Starting non-separable lifecycle model; heterogeneity in ies (4).\n')

%   Population I:
fprintf('Population I.\n')
par.sigma               = 2.24 ;                % consumption IES (reciprocal is Frisch elasticity eta_cp)
par.gamma               = -3.00 ;               % governs the substitution pattern between consumption and labor supply (original = -3)
par.theta1              = 3.00 ;                % governs the subsstitution patter between male and femal labor supply (original = 3)
par.theta2              = par.theta1 ;          % governs the subsstitution patter between male and femal labor supply
[~, ~, sim_array_I]     = lcmodel_nonseparable(par, ind) ;
    
%   Population II:
fprintf('Population II.\n')
par.sigma               = 3 ;                   % consumption IES (reciprocal is Frisch elasticity eta_cp)
par.gamma               = -2.00 ;               % governs the substitution pattern between consumption and labor supply 
par.theta1              = 4.00 ;                % governs the subsstitution patter between male and femal labor supply
par.theta2              = par.theta1 ;          % governs the subsstitution patter between male and femal labor supply
[~, ~, sim_array_II]    = lcmodel_nonseparable(par, ind) ;
        
%   Population III:
fprintf('Population III.\n')
par.sigma               = 2.1 ;                   % consumption IES (reciprocal is Frisch elasticity eta_cp)
par.gamma               = -3.50 ;               % governs the substitution pattern between consumption and labor supply
par.theta1              = 2.30 ;                % governs the subsstitution patter between male and femal labor supply
par.theta2              = par.theta1 ;          % governs the subsstitution patter between male and femal labor supply
[~, ~, sim_array_III]   = lcmodel_nonseparable(par, ind) ;
        
%   Population IV:
fprintf('Population IV.\n')
par.sigma               = 2.8 ;                 % consumption IES (reciprocal is Frisch elasticity eta_cp)
par.gamma               = -3.90 ;               % governs the substitution pattern between consumption and labor supply 
par.theta1              = 3.50 ;                % governs the subsstitution patter between male and femal labor supply 
par.theta2              = par.theta1 ;          % governs the subsstitution patter between male and femal labor supply
[~, ~, sim_array_IV]    = lcmodel_nonseparable(par, ind) ;

%   Place population data into cell - mix populations:
sim_arrays              = {sim_array_I,sim_array_II,sim_array_III,sim_array_IV} ; 

%   Run first stage regressions, estimate parameters on entire population:
[~, sim_results_ns_ies4]    = fun_estimate_parameters(sim_arrays, 'iter') ;


%%  F.  NON-SEPARABLE MODEL: HETEROGENEITY IN delta AND sigma
%   Heterogeneity in discount factor: 4 heterogeneous populations, 
%   4 discount factos and 4 intertemporal elasticities of substitution.
%   -----------------------------------------------------------------------

%   Declare model is non-separable:
ind.separable       = 0;        % 1 for separable model; 0 for non-separable.
    
%   Define preference structure specific to nonseparable model, common 
%   across various specifications:
%	-utility parameters:
par.alpha           = 0.124 ;                   % utility weight of consumption
par.xi              = 0.413 ;                   % utility weight of male labor supply 
if ind.faw==0
	par.f           = 0.0155*ones(par.R,1) ;    % fixed utility cost of female participation
else
 	par.f           = zeros(par.R,1) ;          % fixed utility cost of female participation 
end
par.PSI             = 0.695 ;                   % governs consumption level after retirement
%   -female wage gap:
par.w2              = 0.499*par.w1;             % female wage level (gender wage gap in trends)

%   Simulate populations of households, each with different Frisch
%   elasticities if preference heterogeneity is enabled:
fprintf('Starting non-separable lifecycle model; heterogeneity in discount factor & ies.\n')

%   Population I:
fprintf('Population I.\n')
par.delta               = 0.01006 ;             % discount rate (discount factor is 1/(1+delta))
par.sigma               = 2.24 ;                % consumption IES (reciprocal is Frisch elasticity eta_cp)
par.gamma               = -3.00 ;               % governs the substitution pattern between consumption and labor supply (original = -3)
par.theta1              = 3.00 ;                % governs the subsstitution patter between male and femal labor supply (original = 3)
par.theta2              = par.theta1 ;          % governs the subsstitution patter between male and femal labor supply
[~, ~, sim_array_I]     = lcmodel_nonseparable(par, ind) ;
    
%   Population II:
fprintf('Population II.\n')
par.delta               = 0.01006 ;             % discount rate (discount factor is 1/(1+delta))
par.sigma               = 3.0 ;                 % consumption IES (reciprocal is Frisch elasticity eta_cp)
par.gamma               = -2.00 ;               % governs the substitution pattern between consumption and labor supply 
par.theta1              = 4.00 ;                % governs the subsstitution patter between male and femal labor supply
par.theta2              = par.theta1 ;          % governs the subsstitution patter between male and femal labor supply
[~, ~, sim_array_II]    = lcmodel_nonseparable(par, ind) ;
        
%   Population III:
fprintf('Population III.\n')
par.delta               = 0.02 ;                % discount rate (discount factor is 1/(1+delta))
par.sigma               = 2.24 ;                % consumption IES (reciprocal is Frisch elasticity eta_cp)
par.gamma               = -3.50 ;               % governs the substitution pattern between consumption and labor supply
par.theta1              = 2.30 ;                % governs the subsstitution patter between male and femal labor supply
par.theta2              = par.theta1 ;          % governs the subsstitution patter between male and femal labor supply
[~, ~, sim_array_III]   = lcmodel_nonseparable(par, ind) ;
        
%   Population IV:
fprintf('Population IV.\n')
par.delta               = 0.02 ;                % discount rate (discount factor is 1/(1+delta))
par.sigma               = 3.0 ;                 % consumption IES (reciprocal is Frisch elasticity eta_cp)
par.gamma               = -3.90 ;               % governs the substitution pattern between consumption and labor supply 
par.theta1              = 3.50 ;                % governs the subsstitution patter between male and femal labor supply 
par.theta2              = par.theta1 ;          % governs the subsstitution patter between male and femal labor supply
[~, ~, sim_array_IV]    = lcmodel_nonseparable(par, ind) ;

%   Place population data into cell - mix populations:
sim_arrays              = {sim_array_I,sim_array_II,sim_array_III,sim_array_IV} ; 

%   Run first stage regressions, estimate parameters on entire population:
[~, sim_results_ns_delta_ies]    = fun_estimate_parameters(sim_arrays, 'iter') ;


%%  G.  LIQUIDITY CONSTRAINTS: severe
%   One third of households across populations don't have access to credit
%   and must repay debt in the first 10 years of life.
%   -----------------------------------------------------------------------

%   Declare model is non-separable:
ind.separable       = 0;        % 1 for separable model; 0 for non-separable.
    
%   Define preference structure specific to nonseparable model, common 
%   across various specifications:
%	-utility parameters:
par.delta           = 0.01006 ;                 % discount rate (discount factor is 1/(1+delta))
par.alpha           = 0.124 ;                   % utility weight of consumption
par.xi              = 0.413 ;                   % utility weight of male labor supply 
par.sigma           = 2.24 ;                    % consumption IES (reciprocal is Frisch elasticity eta_cp; original = 2.24)
if ind.faw==0
	par.f           = 0.0155*ones(par.R,1) ;    % fixed utility cost of female participation
else
    par.f           = zeros(par.R,1) ;          % fixed utility cost of female participation 
end
par.PSI             = 0.695 ;                   % governs consumption level after retirement
%   -female wage gap:
par.w2              = 0.499*par.w1;             % female wage level (gender wage gap in trends)

%   Simulate populations of households, each with different Frisch
%   elasticities if preference heterogeneity is enabled:
fprintf('Starting non-separable lifecycle model with severe borrowing constraints.\n')

%   First 65% of households are not constrained:
par.sim_N           = 32500 ;                   % number of simulated households

%   Population I:
fprintf('Population I - not constrained.\n')
par.gamma               = -3.00 ;               % governs the substitution pattern between consumption and labor supply (original = -3)
par.theta1              = 3.00 ;                % governs the subsstitution patter between male and femal labor supply (original = 3)
par.theta2              = par.theta1 ;          % governs the subsstitution patter between male and femal labor supply
[~, ~, sim_array_Inc]   = lcmodel_nonseparable(par, ind) ;
    
%   Population II:
fprintf('Population II - not constrained.\n')
par.gamma               = -2.00 ;               % governs the substitution pattern between consumption and labor supply 
par.theta1              = 4.00 ;                % governs the subsstitution patter between male and femal labor supply
par.theta2              = par.theta1 ;          % governs the subsstitution patter between male and femal labor supply
[~, ~, sim_array_IInc]  = lcmodel_nonseparable(par, ind) ;
        
%   Population III:
fprintf('Population III - not constrained.\n')
par.gamma               = -3.50 ;               % governs the substitution pattern between consumption and labor supply
par.theta1              = 2.30 ;                % governs the subsstitution patter between male and femal labor supply
par.theta2              = par.theta1 ;          % governs the subsstitution patter between male and femal labor supply
[~, ~, sim_array_IIInc] = lcmodel_nonseparable(par, ind) ;
        
%   Population IV:
fprintf('Population IV - not constrained.\n')
par.gamma               = -3.90 ;               % governs the substitution pattern between consumption and labor supply 
par.theta1              = 3.50 ;                % governs the subsstitution patter between male and femal labor supply 
par.theta2              = par.theta1 ;          % governs the subsstitution patter between male and femal labor supply
[~, ~, sim_array_IVnc]  = lcmodel_nonseparable(par, ind) ;

%   Other 35% of households are constrained:
par.sim_N           = 17500 ;                   % number of simulated households
ind.bc              = 3 ;                       % benchmark borrowing constraints (0); zero borrowing constraints (1); severe constraints (3).
%	-borrowing constraints:
switch ind.bc
	case 0 % benchmark borrowing constraint
    	par.bc = (-0.126)*(1+par.r).^(0:par.R);
	case 1 % zero borrowing constraint
     	par.bc = 0*ones(1,par.R+1);
	case 3  % zero borrowing constraint over life but debt in first ten 
            % years of life equal to 25% of average full-time earnings of
            % males upon entry in the labor market.Average wage upon entry 
            % is mean(par.w1*exp(par.gtrend1(1) + Fgrid(1,:,1))).
     	par.bc          = 0*ones(1,par.R+1);
        par.bc(1:10)    = 0.0974 ;
end 

%   Population I:
fprintf('Population I - constrained.\n')
par.gamma               = -3.00 ;               % governs the substitution pattern between consumption and labor supply (original = -3)
par.theta1              = 3.00 ;                % governs the subsstitution patter between male and femal labor supply (original = 3)
par.theta2              = par.theta1 ;          % governs the subsstitution patter between male and femal labor supply
[~, ~, sim_array_Ic]    = lcmodel_nonseparable(par, ind) ;
    
%   Population II:
fprintf('Population II - constrained.\n')
par.gamma               = -2.00 ;               % governs the substitution pattern between consumption and labor supply 
par.theta1              = 4.00 ;                % governs the subsstitution patter between male and femal labor supply
par.theta2              = par.theta1 ;          % governs the subsstitution patter between male and femal labor supply
[~, ~, sim_array_IIc]   = lcmodel_nonseparable(par, ind) ;
        
%   Population III:
fprintf('Population III - constrained.\n')
par.gamma               = -3.50 ;               % governs the substitution pattern between consumption and labor supply
par.theta1              = 2.30 ;                % governs the subsstitution patter between male and femal labor supply
par.theta2              = par.theta1 ;          % governs the subsstitution patter between male and femal labor supply
[~, ~, sim_array_IIIc]  = lcmodel_nonseparable(par, ind) ;
        
%   Population IV:
fprintf('Population IV - constrained.\n')
par.gamma               = -3.90 ;               % governs the substitution pattern between consumption and labor supply 
par.theta1              = 3.50 ;                % governs the subsstitution patter between male and femal labor supply 
par.theta2              = par.theta1 ;          % governs the subsstitution patter between male and femal labor supply
[~, ~, sim_array_IVc]   = lcmodel_nonseparable(par, ind) ;

%   Place population data into cell - mix populations:
sim_arrays              = { sim_array_Inc,sim_array_IInc,sim_array_IIInc,sim_array_IVnc, ...  % mix populations
                            sim_array_Ic,sim_array_IIc,sim_array_IIIc,sim_array_IVc} ;
%   Run first stage regressions, estimate parameters on entire population:
[~, sim_results_liqdty_severe] = fun_estimate_parameters(sim_arrays, 'iter') ;


%%  H.  EXPORT TABLES OF RESULTS (TABLES 9, 10, and H.1)
%   Results appropriate for the tables in the paper.
%   -----------------------------------------------------------------------

%   Table 9: recovery of average preferences in large and small samples.
quant_table_1 = horzcat(sim_results_ns.true_Frisch(1:6),... 
                        sim_results_ns.sim_vModelHat_BPS(1:6),... 
                        sim_results_ns.sim_vModelHat_TRANS(1:6),...
                        sim_results_small.sim_vModelHat_BPS_avg(1:6),...
                        sim_results_small.sim_vModelHat_BPS_std(1:6),...
                        sim_results_small.sim_vModelHat_TRANS_avg(1:6),...
                        sim_results_small.sim_vModelHat_TRANS_std(1:6));
quant_table_1 = round(quant_table_1,3) ;                    
%   -export:
xlswrite(strcat(dDir,'/tables/table_9.csv'),quant_table_1,1)

%   Table 10: recovery of average preferences when there is heterogeneity 
%   in the discount factor, the consumption substitution elasticity, and 
%   severely binding liquidity constraints.
quant_table_2 = horzcat(sim_results_ns_delta4.true_Frisch(1:6),... 
                        sim_results_ns_delta4.sim_vModelHat_TRANS(1:6),... 
                        sim_results_ns_ies4.true_Frisch(1:6),...
                        sim_results_ns_ies4.sim_vModelHat_TRANS(1:6),...
                        sim_results_liqdty_severe.true_Frisch(1:6),...
                        sim_results_liqdty_severe.sim_vModelHat_TRANS(1:6));
quant_table_2 = round(quant_table_2,3) ; 
%   -export:
xlswrite(strcat(dDir,'/tables/table_10.csv'),quant_table_2,1)

%   Appendix Table H.1: recovery of average preferences when there is
%   heterogeneity in both the discount factor and the consumption 
%   substitution elasticity.
quant_table_3 = horzcat(sim_results_ns_delta_ies.true_Frisch(1:6),... 
                        sim_results_ns_delta_ies.sim_vModelHat_TRANS(1:6));
quant_table_3 = round(quant_table_3,3) ;
%   -export:
xlswrite(strcat(dDir,'/tables/table_h1.csv'),quant_table_3,1)


%%  I.  INEQUALITY WITH AND WITHOUT PREFERENCE HETEROGENEITY
%   Earnings & consumption inequality with & without heterogeneity.
%   -----------------------------------------------------------------------

%   Simulate three sub-populations: the middle sub-population is one that
%   represents the average households, i.e. has the average preferences.
%   The other two sub-populations have preferences that are differ from 
%   those in the middle by +- same number.

%   Declare model is non-separable:
ind.separable       = 0;        % 1 for separable model; 0 for non-separable.
    
%   Define preference structure specific to nonseparable model, common 
%   across various specifications:
%	-utility parameters:
par.alpha           = 0.124 ;                   % utility weight of consumption
par.xi              = 0.413 ;                   % utility weight of male labor supply 
if ind.faw==0
	par.f           = 0.0155*ones(par.R,1) ;    % fixed utility cost of female participation
else
    par.f           = zeros(par.R,1) ;          % fixed utility cost of female participation 
end
par.PSI             = 0.695 ;                   % governs consumption level after retirement
%   -female wage gap:
par.w2              = 0.499*par.w1;             % female wage level (gender wage gap in trends)

%   Population I ('middle' population, average preferences):
fprintf('Population I (middle).\n')
par.delta               = 0.02 ;                % discount rate (discount factor is 1/(1+delta))
par.sigma               = 2.5 ;                 % consumption IES (reciprocal is Frisch elasticity eta_cp; original = 2.24)
par.gamma               = -3.00 ;               % governs the substitution pattern between consumption and labor supply (original = -3)
par.theta1              = 3.00 ;                % governs the subsstitution patter between male and femal labor supply (original = 3)
par.theta2              = par.theta1 ;          % governs the subsstitution patter between male and femal labor supply
[~, ~, sim_array_I]     = lcmodel_nonseparable(par, ind) ;

%   Population II:
fprintf('Population II.\n')
par.delta               = 0.01006 ;             % discount rate (discount factor is 1/(1+delta))
par.sigma               = 2.8 ;                 % consumption IES (reciprocal is Frisch elasticity eta_cp; original = 2.24)
par.gamma               = -2.50 ;               % governs the substitution pattern between consumption and labor supply (original = -3)
par.theta1              = 2.50 ;                % governs the subsstitution patter between male and femal labor supply (original = 3)
par.theta2              = par.theta1 ;          % governs the subsstitution patter between male and femal labor supply
[~, ~, sim_array_II]    = lcmodel_nonseparable(par, ind) ;

%   Population III:
fprintf('Population III.\n')
par.delta               = 0.03 ;                % discount rate (discount factor is 1/(1+delta))
par.sigma               = 2.1 ;                 % consumption IES (reciprocal is Frisch elasticity eta_cp; original = 2.24)
par.gamma               = -3.50 ;               % governs the substitution pattern between consumption and labor supply (original = -3)
par.theta1              = 3.50 ;                % governs the subsstitution patter between male and femal labor supply (original = 3)
par.theta2              = par.theta1 ;          % governs the subsstitution patter between male and femal labor supply
[~, ~, sim_array_III]   = lcmodel_nonseparable(par, ind) ;

%   Calculate the variance of consumption growth with preference 
%   heterogeneity (pooling all sub-populations together), and without (at
%   the 'average' preferences of the 'middle' population):
%   -variance of consumption growth with heterogeneity, ages 31, 40, 59:
var_dc_heterog_31   = std([sim_array_I.dC(:,1); sim_array_II.dC(:,1); sim_array_III.dC(:,1)])^2;
var_dc_heterog_40   = std([sim_array_I.dC(:,10);sim_array_II.dC(:,10);sim_array_III.dC(:,10)])^2;
var_dc_heterog_59   = std([sim_array_I.dC(:,29);sim_array_II.dC(:,29);sim_array_III.dC(:,29)])^2;
%   -variance of consumption growth at average preferences, ages 31, 40, 59:
var_dc_homog_31     = std(sim_array_I.dC(:,1))^2;
var_dc_homog_40     = std(sim_array_I.dC(:,10))^2;
var_dc_homog_59     = std(sim_array_I.dC(:,29))^2;
%   -contribution of heterogeneity to variance of consumption growth:
fprintf('At age 31, the contribution of heterogeneity to Var(Dc) is %u percent.\n',100-100*var_dc_homog_31/var_dc_heterog_31)
fprintf('At age 40, the contribution of heterogeneity to Var(Dc) is %u percent.\n',100-100*var_dc_homog_40/var_dc_heterog_40)
fprintf('At age 59, the contribution of heterogeneity to Var(Dc) is %u percent.\n',100-100*var_dc_homog_59/var_dc_heterog_59)