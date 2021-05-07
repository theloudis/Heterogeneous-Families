
%%  Welfare loss of idiosyncratic wage risk
%
%   'Consumption Inequality across Heterogeneous Families'
%   This script solves and simulates Wu & Krueger (2020)'s lifecycle model
%	for consumption and family labor supply (adjusted for heterogeneity).
%   It then calculates the welfare loss from idiosyncratic wage risk as 
%   when family labor supply is less effective at providing insurance (i.e. 
%   when the labor supply elasticities are 'low' as in my baseline).
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
global unidim_nFgrid unidim_nugrid dDir ;

%   Define model features:
ind.faw             = 1;        % 1 for intensive margin only; 0 for extensive and intensive margin.
ind.separable       = 1;        % 1 for separable model; 0 for non-separable.
ind.welfare         = 1;        % 1 for welfare calculation; 0 otherwise.


%%	A. DECLARE BASELINE PARAMETER STRUCTURE
%	Initializes model parameters common across all specifications.
%   -----------------------------------------------------------------------

%   Wage grids:
unidim_nFgrid       = 11 ;                      % number of grid points on each dimension for permanent wage component (11)
unidim_nugrid       = 5 ;                       % number of grid points on each dimension for transitory wage component (5)

% 	Set baseline parameter values:
%   -simulated population size:
par.sim_N           = 50000 ;                   % number of simulated households
%	-length of time:
par.R               = 45; 						% length of working life
par.T               = 60; 						% length of life cycle
%	-interest rate and discount factor:
par.r               = 0.02; 					% interest rate
par.delta           = 0.00469 ;                 % discount rate (original: 0.00469)
%	-wage trend:
par.w1              = 0.7120; 					% male wage level
par.w2              = 0.485*par.w1; 			% female wage level (gender wage gap in trends)
%	-wage process:
par.O_F_initial     = [0,0;0,0];                % covariance matrix of initial permanent component
par.rho1            = 0.99669; 					% persistence of male permanent shocks (targeting joint unit-root process with 11*11 grid).
par.rho2            = 0.99692; 					% persistence of female permanent shocks (targeting joint unit-root process with 11*11 grid).
%   -baseline tax & benefits parameters:
par.mu              = 0.1327; 					% income tax progressivity
par.chi             = 0.1575; 					% income tax level
par.tau_ss          = 0.0765; 					% payroll tax rate
par.rb              = 0.3703; 					% retirement benefit
%   -baseline utility parameters:
par.psi1            = 2.538; 					% disutility of male labor supply
par.psi2            = 1.953; 					% disutility of female labor supply
%	-borrowing constraints & fixed costs of female work:
par.bc              = (-0.126)*(1+par.r).^(0:par.R); 
if ind.faw==0
 	par.f           = 0.0306*ones(par.R,1); 	% fixed utility cost of female participation
else
    par.f           = zeros(par.R,1);           % fixed utility cost of female participation
end


%%  B.  SOLVE AND SIMULATE SEPARABLE MODEL WITHOUT WAGE RISK
%   Simulate populations of households with average preferences.
%   -----------------------------------------------------------------------

%   Simulate two populations of households, each one with Frisch 
%   elasticities taken from baseline estimation when: 
%       (1.) up to 2nd moments (specification: BPS) is fit, 
%       (2.) 3rd moments also introduced (specification: PREF).
fprintf('Starting separable lifecycle model without wage risk.\n')

%   Second moments of permanent and transitory shocks & wage trend:
par.O_v                 = [1e-12,0; 0,1e-12];
par.O_u                 = [1e-12,0; 0,1e-12];
load('expected_wage_trend')
par.gtrend1             = log(expected_W1_trend);
par.gtrend2             = log(expected_W2_trend);

%   Population I has parameters when up to 2nd moments (BPS) are fitted:
fprintf('Population I.\n')
par.sigma               = 1/0.578;                  % consumption IES (reciprocal is Frisch elasticity eta_cp)
par.eta1                = 0.589;                    % Frisch elasticity of male labor supply
par.eta2                = 0.776;                    % Frisch elasticity of female labor supply
[before_BPS_policy, before_BPS, ~]      = lcmodel_separable(par, ind) ;

%   Population II has parameters when up to 3rd moments (PREF) are fitted:
fprintf('Population II.\n')
par.sigma               = 1/0.598;                  % consumption IES (reciprocal is Frisch elasticity eta_cp)
par.eta1                = 0.276;                    % Frisch elasticity of male labor supply 
par.eta2                = 0.247;                    % Frisch elasticity of female labor supply
[before_PREF_policy, before_PREF, ~]    = lcmodel_separable(par, ind) ;


%%  C.  SOLVE AND SIMULATE SEPARABLE MODEL WITH WAGE RISK
%   Simulate populations of households with average preferences.
%   -----------------------------------------------------------------------

%   Simulate two populations of households, each one with Frisch 
%   elasticities taken from baseline estimation when: 
%       (1.) up to 2nd moments (specification: BPS) is fit, 
%       (2.) 3rd moments also introduced (specification: PREF).
fprintf('Starting separable lifecycle model with wage risk.\n')

%   Second moments of permanent and transitory shocks & wage trend:
par.O_v                 = [0.02447,0.00218;...      % covariance matrix of permanent shocks
                           0.00218,0.03089];        % targeting [0.0303,0.0027;0.0027,0.0382] with 11*11 grid.
par.O_u                 = [0.02327,0.00499;...      % covariance matrix of transitory shocks
                           0.00499,0.01060];        % targeting [0.0290,0.0041;0.0041,0.0132] with 5*5 grid..
par.gtrend1             = log(importdata('wage_profile_rz2012_interp.mat')); % productivity trend for male
par.gtrend2             = log(importdata('wage_profile_rz2012_interp.mat')); % productivity trend for female

%   Population I has parameters when up to 2nd moments (BPS) are fitted:
fprintf('Population I.\n')
par.sigma               = 1/0.578;                  % consumption IES (reciprocal is Frisch elasticity eta_cp)
par.eta1                = 0.589;                    % Frisch elasticity of male labor supply
par.eta2                = 0.776;                    % Frisch elasticity of female labor supply
[after_BPS_policy, after_BPS, ~]       = lcmodel_separable(par, ind) ;

%   Population II has parameters when up to 3rd moments (PREF) are fitted:
fprintf('Population II.\n')
par.sigma               = 1/0.598;                  % consumption IES (reciprocal is Frisch elasticity eta_cp)
par.eta1                = 0.276;                    % Frisch elasticity of male labor supply 
par.eta2                = 0.247;                    % Frisch elasticity of female labor supply
[after_PREF_policy, after_PREF, ~]     = lcmodel_separable(par, ind) ;


%%  D.  CALCULATE WELFARE LOSS FROM IDIOSYNCRATIC WAGE RISK (TABLE H.2)
%   Comparing welfare loss in BPS and in my setting
%   -----------------------------------------------------------------------

%   I. Welfare loss from wage risk with BPS parameter estimates:
%   -declare applicable Frisch elasticities:
par.sigma   = 1/0.578; 
par.eta1    = 0.589;
par.eta2    = 0.776;
%   -obtain averages of 'before' values & outcomes from simulations: 
before.V    = mean(before_BPS.sim_V);
before.VC   = mean(before_BPS.sim_VC);
before.VH   = mean(before_BPS.sim_VH);
before.VH1  = mean(before_BPS.sim_VH1);
before.VH2  = mean(before_BPS.sim_VH2);
before.C    = mean(reshape(before_BPS.sim_C,[],1));
before.H1   = mean(reshape(before_BPS.sim_H1,[],1));
before.H2   = mean(reshape(before_BPS.sim_H2,[],1));
%   -obtain averages of 'after' values & outcomes from simulations: 
after.V     = mean(after_BPS.sim_V);
after.VC    = mean(after_BPS.sim_VC);
after.VH    = mean(after_BPS.sim_VH);
after.VH1   = mean(after_BPS.sim_VH1);
after.VH2   = mean(after_BPS.sim_VH2);
after.C     = mean(reshape(after_BPS.sim_C,[],1));
after.H1    = mean(reshape(after_BPS.sim_H1,[],1));
after.H2    = mean(reshape(after_BPS.sim_H2,[],1));
%   -calculate welfare loss in consumption equivalent variation terms:
CEV_BPS     = welfareloss(par, before, after);
clearvars before after

%   II. Welfare loss from wage risk with PREF parameter estimates:
%   -declare applicable Frisch elasticities:
par.sigma   = 1/0.598;
par.eta1    = 0.276;
par.eta2    = 0.247;
%   -obtain averages of 'before' values & outcomes from simulations: 
before.V    = mean(before_PREF.sim_V);
before.VC   = mean(before_PREF.sim_VC);
before.VH   = mean(before_PREF.sim_VH);
before.VH1  = mean(before_PREF.sim_VH1);
before.VH2  = mean(before_PREF.sim_VH2);
before.C    = mean(reshape(before_PREF.sim_C,[],1));
before.H1   = mean(reshape(before_PREF.sim_H1,[],1));
before.H2   = mean(reshape(before_PREF.sim_H2,[],1));
%   -obtain averages of 'after' values & outcomes from simulations: 
after.V     = mean(after_PREF.sim_V);
after.VC    = mean(after_PREF.sim_VC);
after.VH    = mean(after_PREF.sim_VH);
after.VH1   = mean(after_PREF.sim_VH1);
after.VH2   = mean(after_PREF.sim_VH2);
after.C     = mean(reshape(after_PREF.sim_C,[],1));
after.H1    = mean(reshape(after_PREF.sim_H1,[],1));
after.H2    = mean(reshape(after_PREF.sim_H2,[],1));
%   -calculate welfare loss in consumption equivalent variation terms:
CEV_PREF    = welfareloss(par, before, after);
clearvars before after  

%   Place welfare numbers into table:
welfare_table =[CEV_PREF.total,     NaN,                NaN,					CEV_BPS.total,          NaN,                NaN            ;
                CEV_PREF.C,         CEV_PREF.C_level,   CEV_PREF.C_dist,		CEV_BPS.C,              CEV_BPS.C_level,    CEV_BPS.C_dist ;
                CEV_PREF.H1,        CEV_PREF.H1_level,  CEV_PREF.H1_dist,		CEV_BPS.H1,             CEV_BPS.H1_level,   CEV_BPS.H1_dist;
                CEV_PREF.H2,        CEV_PREF.H2_level,  CEV_PREF.H2_dist,		CEV_BPS.H2,             CEV_BPS.H2_level,   CEV_BPS.H2_dist];
welfare_table = round(welfare_table,3) ;
xlswrite(strcat(dDir,'/tables/table_h2.csv'),welfare_table,1)