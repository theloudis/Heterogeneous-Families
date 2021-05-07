
%%  Master file for structural estimation
%
%   Matlab code for structural estimation accompanying 
%   'Consumption Inequality across Heterogeneous Families'
%   published at the European Economic Review.
%
%   For updates to this code, please visit my dedicated GitHub page at
%   https://github.com/theloudis/Heterogeneous-Families
%
%   Alexandros Theloudis
%   LISER Luxembourg 
%   Tilburg Econometrics & Operations Research 
%   Spring 2021
%
%   =======================================================================

%%  1.  INITIAL STATEMENTS
%   Set the program switches & attributes.
%   -----------------------------------------------------------------------

clear
clc

global dDir mDir vWageHat vWageHat_diag do ;

%   Set working directories:
dDir = '/Users/atheloudis/Dropbox/Heterogeneous-Families/Matlab_dir' ;
mDir = '/Users/atheloudis/Dropbox/Heterogeneous-Families/Matlab_dir/m_files' ;
cd(mDir) ;
addpath(genpath(dDir)) ;
addpath(genpath(mDir)) ;

%   Set and check program controls:
control_switches ;


%%  2.  OBTAIN DATA
%   Reads moments of married couples 
%   (all applicable moments at average past consumption and hours levels):
%       -1st stage residuals (baseline), 
%       -1st stage residuals net of age of youngest child.
%   -----------------------------------------------------------------------

%   Read data as exported from STATA:
%   -1st stage residuals (baseline):
[mc1.Couple, mc1.Ind, mc1.Es, mc1.Pi, mc1.Err, mc1.Avg, ~, mc1.N]  ...
        = handleData('_Cond1/original_PSID_c1.csv', ...
                     '_Cond1/original_PSID_me_c1.csv', ...
                     '_Cond1/avgrat_original_PSID_c1.csv',[]) ;

%   -1st stage residuals net of age of youngest child:
[mc2.Couple, mc2.Ind, mc2.Es, mc2.Pi, mc2.Err, mc2.Avg, ~, mc2.N]  ...
        = handleData('_Cond2/original_PSID_c2.csv', ...
                     '_Cond2/original_PSID_me_c2.csv', ...
                     '_Cond2/avgrat_original_PSID_c2.csv',[]) ;


%%  3.  OBTAIN EMPIRICAL MOMENTS AND VARIANCE COVARIANCE MATRIX 
%   Estimates the empirical moments targeted in the structural model,
%   as well as their empirical covariance matrix for use in diagonal GMM.
%   -----------------------------------------------------------------------

%   Empirical moments:
[emp_MATCHED_c1, emp_BPS_c1, empse_MATCHED_c1, empse_BPS_c1] = estm_moments(mc1.Couple, mc1.Ind, mc1.Err);

%   Construct covariance matrix of moments for use in diagonally weighted 
%   GMM as the square of the moments' empirical standard errors:
varmoms_c1 = {empse_MATCHED_c1.^2, empse_BPS_c1.^2} ;


%%  4.  ESTIMATION OF WAGE PROCESS AND STRUCTURAL MODEL
%   Implements GMM estimation of wage parameters. All datasets have same
%	data for wages therefore I estimate these parameters once and for all. 
%	Features and switches for the estimation are set inside 'estm_wages'.
%   Carries out the estimation of various versions of the structural model
%   (i.e. various specifications, equally weighted GMM, diagonally 
%   weighted GMM, estimation over selected subsamples).
%   -----------------------------------------------------------------------

%   Wage process estimation:
%   -equally weighted GMM (results that go into table 3):
[vWageHat,      wageFval,       wageFlag]       = estm_wages(mc1.Couple, mc1.Ind, mc1.Err, 'iter', 1, 'eye') ;
%   -diagonally weighted GMM (results needed for tables E.5-E.7):
[vWageHat_diag, wageFval_diag,  wageFlag_diag]  = estm_wages(mc1.Couple, mc1.Ind, mc1.Err, 'iter', 1, cell2mat(varmoms_c1(1))) ;

%   Model estimation:
do_model ;

%   Standard errors and parameter p-values:
do_bootstrap ;


%%  5.  DELIVER RESULTS and MODEL FIT
%   Delivers estimation results and exports tables with empirical and 
%   fitted moments in the preferred specification.
%   -----------------------------------------------------------------------

%   Deliver results tables for: 
%   -wages (table 3)
%   -baseline preferences (tables 4-5)
%   -alternatives to preferred specification (table E.1)
%   -accounting for chores and age of youngest child (tables E.3-E.4)
%   -diagonally weighted GMM (tables E.5-E.7)
%   -summary statistics for pi and es (table D.3)
deliver_estimates ;

%   Model fit in preferred specification (tables D.4-D.6):
fit ;


%%  6.  ADDITIONAL RESULTS POST BASELINE ESTIMATION
%   Implications of consumption error for parameter estimates; parameter
%   estimates conditional on age and time; parameter estimates away from 
%   average outcome levels; estimation of wages and model addressing 
%   neglected time aggregation in the PSID; estimation allowing for
%   progressive joint taxation between spouses.
%   -----------------------------------------------------------------------

%   Consumption error (figure E.1):
consumption_error ;

%   Age and time heterogeneity (figures E.3 and E.4):
heterogeneity_age_time ;

%   Parameters along the entire distribution (fugure 1):
heterogeneity_outcome_distribution ;

%   Addressing neglected time aggregation in the PSID (table G.1):
time_aggregation ;

%   Progressive joint taxation (part of table E.9):
taxes ;


%%  7.  CONSUMPTION INEQUALITY & CONSUMPTION PARTIAL INSURANCE
%   This part quantifies the role of preference heterogeneity in
%   consumption inequality and consumption partial insurance.
%   -----------------------------------------------------------------------
          
%   Carries out the decomposition of consumption inequality (tables 6 & E.8)
%   and estimates the consumption substitution elasticity and how
%   it varies with consumption measurement error (figure E.2):
inequality_sim_decomp ;         

%   Simulates the degree of partial insurance against transitory and
%   permanent wage shocks (table 7-8, figure 2, figure E.5):  
insurance ;


%%  8.  WEALTHY SAMPLES and SAMPLES WITHOUT EXTREME OBSERVATIONS
%   This part estimates the model (wages, preferences) on various
%   samples of wealthy households, and various samples of households
%   after removing extreme observations.
%   -----------------------------------------------------------------------

%   Wealthy households sample (part of table E.9):
wealthy ;

%   Samples without extreme observations (table E.2):
robust ;


%%  9.  SIMULATE QUANTITATIVE MODEL
%   This part simulates the two-earner lifecycle model of Wu & Krueger 2020
%   adjusted for preference heterogeneity.
%   -----------------------------------------------------------------------

%   Solve & simulate model (tables 9, 10, H.1):
if do.wu_krueger == 1
    clearvars vModelHat_* vWageHat* empse_* emp_*
    tic;
    lcmodel ;
    toc;
end

%   Welfare loss of idiosyncratic wage risk (table H.2):
if do.welfare == 1
    clearvars vModelHat_* vWageHat* empse_* emp_* par ind
    tic;
    lcmodel_welfare ;
    toc;
end