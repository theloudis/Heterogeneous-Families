
%%  Consumption inequality decomposition

%   'Consumption Inequality across Heterogeneous Families'
%   This script simulating preferences and initial conditions under  
%   various alternative specifications; its aim is to decompose  
%   consumption inequality into terms pertaining to:
%       - wage inequality
%       - preference heterogeneity
%       - wealth inequality.
%   It also estimates the consumption substitution elasticity. 
%   Specifically:
%   -part 1: simulates household preferences with and without heterogeneity.
%   -part 2: simulates wealth shares and ratios of outcomes with and
%            without heterogeneity.
%   -part 3: simulates consumption inequality over various values for the
%            consumption substitution elasticity.
%   -part 4: obtain consumption substitution elasticity that matches 
%            simulated and empirical consumption inequality.
%   -part 5: simulates and decomposes inequality under various specifications.
%   -part 6: assembles and exports table of simulation results.
%   -part 7: obtain and plots consumption substitution elasticity over a
%            range of values for consumption measurement error.
%   -part 8: assembles and exports table of simulation results over a
%            range of values for consumption measurement error (0%, 40%).
%
%   Alexandros Theloudis
%   LISER Luxembourg 
%   Tilburg Econometrics & Operations Research 
%   Spring 2021
%
%   =======================================================================

%   Preliminary statements:
global  vModelHat_c1 num_pref_rdraws num_pref_sims sd_trim_pref_draws ...
        do stationary_wage_params T dDir vWageHat cme_estimates_1 ;
   
%   Request data and obtain average partial insurance and human wealth
%   parameters. Note: I condition on pi~=0 and es~=0 to drop zero entries 
%   that appear mechanically because of the inbalanced panel.
%   -request data:
[mc1.Couple, mc1.Ind, mc1.Es, mc1.Pi, mc1.Err, mc1.Avg, ~, mc1.N]  ...
    = handleData('_Cond1/original_PSID_c1.csv', ...
                 '_Cond1/original_PSID_me_c1.csv', ...
                 '_Cond1/avgrat_original_PSID_c1.csv',[]) ;
%   -obtain initial conditions:
pi      = mc1.Pi(2:T,:);
es      = mc1.Es(2:T,:);
AT_Epi  = mean(pi(pi~=0)) ; 
AT_Es   = mean(es(es~=0)) ;

%   Declare consumption substitution elasticity from Blundell et al. (2016):
BPS_eta_c_p = -0.372 ;


%%  1.  PREFERENCE DRAWS
%   Draw preferences for a population of 'num_pref_rdraws' agents 
%   'num_pref_sims' times from different multivariate normal distributions:
%       - degenerate distribution (no heterogeneity)
%       - multivariate normal (MVN) at estimated second moments
%   -----------------------------------------------------------------------

%   Load preferred wage and preference parameters:
vModelHat = vModelHat_c1.PREF ;

%   Declare estimated preference parameters:
eta_c_w1            = vModelHat(1) ;   
eta_c_w2            = vModelHat(2) ;  
eta_h1_w1           = vModelHat(3) ;
eta_h2_w2           = vModelHat(4) ;  
Veta_c_w1           = vModelHat(5) ;
Veta_c_w2           = vModelHat(6) ;
Veta_h1_w1          = vModelHat(7) ;
Veta_h2_w2          = vModelHat(8) ; 
COVeta_c_w1_c_w2    = vModelHat(9)  ;
COVeta_c_w1_h1_w1   = vModelHat(10) ;
COVeta_c_w1_h2_w2   = vModelHat(11) ;
COVeta_c_w2_h1_w1   = vModelHat(12) ;
COVeta_c_w2_h2_w2   = vModelHat(13) ; 
COVeta_h1_w1_h2_w2  = vModelHat(14) ;

%   Declare first moments of preferences:
Mu = [ eta_c_w1 eta_c_w2 eta_h1_w1 eta_h2_w2 ] ;

%   Declare second moments of preferences:
%           eta_c_w1            eta_c_w2            eta_h1_w1           eta_h2_w2
Sigma = [   Veta_c_w1           COVeta_c_w1_c_w2    COVeta_c_w1_h1_w1   COVeta_c_w1_h2_w2   ; % eta_c_w1
            COVeta_c_w1_c_w2    Veta_c_w2           COVeta_c_w2_h1_w1   COVeta_c_w2_h2_w2   ; % eta_c_w2
            COVeta_c_w1_h1_w1   COVeta_c_w2_h1_w1   Veta_h1_w1          COVeta_h1_w1_h2_w2  ; % eta_h1_w1
            COVeta_c_w1_h2_w2   COVeta_c_w2_h2_w2   COVeta_h1_w1_h2_w2  Veta_h2_w2 ] ;        % eta_h2_w2

%   Check that 'Sigma' is positive semi-definite. If  not (that shows up as 
%   a first eigenvalue < 0), it is due to the perfect correlation between
%   consumption-wage elasticities. Adjust the correlation slightly:
eigv = eig(Sigma) ;
if eigv(1) < 0
    Sigma(1,2) = Sigma(1,2)-1e-3 ;
    Sigma(2,1) = Sigma(2,1)-1e-3 ;
end
clearvars eigv

%   Pseudo-draw population of preferences in the absence of heterogeneity
%   (therefore everyone has the mean preferences):
simPrefDrawsNoHet = repmat(Mu',1,num_pref_rdraws,num_pref_sims);    
        
%   Draw preferences from multivariate normal (MVN) at original levels of  
%   heterogeneity. Random draws are sequential over the # of populations:   
rng(0);     % Set a starting seed
simPrefDrawsMVN = zeros(length(Mu),num_pref_rdraws,num_pref_sims);
for s = 1:1:num_pref_sims
    mR = mvnrnd(Mu,Sigma,num_pref_rdraws) ;
    simPrefDrawsMVN(:,:,s) = mR' ;
end

%   Replace preference draws that fall outside 'sd_trim_pref_draws' s.d.   
%   of the marginal distributions of the respective parameters in order to
%   minimize the effect of a few extreme preference draws:
parambounds         = [Mu'-sd_trim_pref_draws*sqrt(diag(Sigma)) , Mu'+sd_trim_pref_draws*sqrt(diag(Sigma))] ;
for pp = 1:1:length(Mu)
    simPrefDrawsMVN(pp,simPrefDrawsMVN(pp,:)<parambounds(pp,1)) = parambounds(pp,1) ;
    simPrefDrawsMVN(pp,simPrefDrawsMVN(pp,:)>parambounds(pp,2)) = parambounds(pp,2) ;
end    

%   Clear unneeded variables:
clearvars s pp mR eta_* Veta_* COVeta_* parambounds Mu Sigma ;


%%  2.  WEALTH SHARES AND RATIOS OF OUTCOMES
%   Draw wealth shares (pi, es) and ratio of outcomes (c/y1,c/y2) for 
%   a population of 'num_pref_rdraws' agents 'num_pref_sims' times under 
%   different specifications:
%       - degenerate distribution (no heterogeneity)
%       - random draws from empirical distribution
%   -----------------------------------------------------------------------

%   Pseudo-draw from degenerate distribution (no heterogeneity):
%   -Partial insurance parameters (pi, es)
PiDrawsNoHet_AT = AT_Epi*ones(1,num_pref_rdraws,num_pref_sims);
EsDrawsNoHet_AT = AT_Es*ones(1,num_pref_rdraws,num_pref_sims);
%   -Ratios of outcomes (c/y1, c/y2)
CYDrawsNoHet(1) = mc1.Avg(3);
CYDrawsNoHet(2) = mc1.Avg(4);

%   Draw with replacement from empirical distributions of pi & es, 
%   excluding zeros from both distributions (zeros appear mechanically 
%   because of the inbalanced panel):
rng(21061985);     % Set a starting seed
PiDrawsEmp = zeros(1,num_pref_rdraws,num_pref_sims);
EsDrawsEmp = zeros(1,num_pref_rdraws,num_pref_sims);
for s = 1:1:num_pref_sims
    PiDrawsEmp(1,:,s) = datasample(pi(pi~=0),num_pref_rdraws) ;
    EsDrawsEmp(1,:,s) = datasample(es(es~=0),num_pref_rdraws) ;
end
clearvars s


%%  3.  SIMULATE CONSUMPTION INEQUALITY FOR VARIOUS CONSUMPTION SUBSTITUTION ELASTICITIES
%   Simulates consumption inequality over various plausible values for
%   the consumption substitution elasticity.
%   -----------------------------------------------------------------------

%   To understand how permanent inequality changes with the elasticity of 
%   consumption substitution 'eta_c_p', I calculate consumption 
%   inequality over a range of possible values for 'eta_c_p'.

%   Declare range for 'eta_c_p'; consistent with intuition, I restrict 
%   the elasticity to non-positive values:
ineq_vls_eta_c_p = -1.25:.0025:0 ;

%   Simulate inequality over range for 'eta_c_p':
if do.ineq_sim_against_etacp == 1 
    
    %   For simplicity and speed, this part of the code runs only when the
    %   wage second moments are stationary:
    if stationary_wage_params ~= 1
        error("Inequality fit cannot run unless wages are stationary.")
    end

    %   Evaluate functions over range of eta_c_p:
    ineq_vls_ph   = zeros(num_pref_sims,length(ineq_vls_eta_c_p),3);
    ineq_vls_noph = zeros(num_pref_sims,length(ineq_vls_eta_c_p),3);
    for ss=1:1:length(ineq_vls_eta_c_p)
        [ineq_vls_ph(:,ss,1), ineq_vls_ph(:,ss,2), ineq_vls_ph(:,ss,3)] = ...
            inequality_fit(simPrefDrawsMVN, PiDrawsEmp, EsDrawsEmp, CYDrawsNoHet, vWageHat, ineq_vls_eta_c_p(ss));
        [ineq_vls_noph(:,ss,1), ineq_vls_noph(:,ss,2), ineq_vls_noph(:,ss,3)] = ...
            inequality_fit(simPrefDrawsNoHet, PiDrawsEmp, EsDrawsEmp, CYDrawsNoHet, vWageHat, ineq_vls_eta_c_p(ss));
        fprintf('Finished inequality simulation over eta_c_p value : %u\n',ss)
    end
    clearvars ss

else
    
    load(strcat(dDir,'/exports/results/ineq_values'));
    ineq_vls_ph     = ineq_vls(:,1:length(ineq_vls_eta_c_p),:);
    ineq_vls_noph   = ineq_vls(:,(length(ineq_vls_eta_c_p)+1):2*length(ineq_vls_eta_c_p),:);
    clearvars ineq_vls
end

%   Generate total simulated inequality as the sum of consumption
%   instability and permanent inequality. These matrices are of dimension 
%   'num_pref_sims x length(ineq_vls_eta_c_p)':
sim_ineq_ph     = ineq_vls_ph(:,:,1) + ineq_vls_ph(:,:,3);
sim_ineq_noph   = ineq_vls_noph(:,:,1) + ineq_vls_noph(:,:,3);

%   Obtain mean inequality across populations, for each value of 'eta_c_p':
sim_ineq_ph     = mean(sim_ineq_ph,1);
sim_ineq_noph   = mean(sim_ineq_noph,1);


%%  4.  OBTAIN BEST CONSUMPTION SUBSTITUTION ELASTICITY
%   Obtain consumption substitution elasticity that matches simulated
%   consumption inequality to the empirical variance of consumption growth.
%   -----------------------------------------------------------------------

%   Retrieve baseline variance of consumption growth from empirical moments; 
%   moment and standard error are net of baseline measurement error:
vardcHat_c1 = emp_BPS_c1(12) ;
seVardc_c1  = empse_BPS_c1(12) ;

%   Find value of eta_c_p that minimises squared distance between 
%   simulated and empirical consumption inequality:
[~,i]           = min((sim_ineq_ph-vardcHat_c1).^2) ;
eta_c_p_hat_ph  = ineq_vls_eta_c_p(i) ;


%%  5.  SIMULATE AND DECOMPOSE INEQUALITY UNDER DIFFERENT REGIMES
%   Calculate consumption instability and permanent inequality under 
%   different specifications for preferences and initial conditions pi,es.
%   -----------------------------------------------------------------------

%   A: Consumption Instability:
%   How much consumption instability with preference heterogeneity:
sim_cIntsability_ph             = mean(ineq_vls_ph(:,i,3)) ;
%   How much consumption instability without preference heterogeneity:
sim_cIntsability_noph           = mean(ineq_vls_noph(:,i,3)) ;
%   How much preference-heterogeneity-induced consumption instability:
sim_cIntsability_ph_induced     = sim_cIntsability_ph - sim_cIntsability_noph ;

%   B: Permanent Inequality:
%   How much permanent inequality with full heterogeneity (preferences and initial conditions):
sim_cPermanent_ph               = mean(ineq_vls_ph(:,i,1)) ;
%   How much permanent inequality without heterogeneity:
sim_cPermanent_noph             = mean(ineq_vls_noph(:,i,1)) ;
%   How much permanent inequality with heterogeneity in pi & es only:
[simPI_NoHet_EmpPiEs,]          = inequality_fit(simPrefDrawsNoHet,PiDrawsEmp,EsDrawsEmp,CYDrawsNoHet,vWageHat,eta_c_p_hat_ph);
sim_cPermanent_NoHet_EmpPiEs	= mean(simPI_NoHet_EmpPiEs);
%   How much permanent inequality with heterogeneity in preferences only:
[simPI_PrefMVN,]                = inequality_fit(simPrefDrawsMVN,PiDrawsNoHet_AT,EsDrawsNoHet_AT,CYDrawsNoHet,vWageHat,eta_c_p_hat_ph);
sim_cPermanent_PrefMVN          = mean(simPI_PrefMVN);

%   C: Permanent Inequality at BPS consumption substitution elasticity:
%   How much permanent inequality with full heterogeneity (preferences and initial conditions):   
simPI_BPSeta                    = mean(inequality_fit(simPrefDrawsMVN,PiDrawsEmp,EsDrawsEmp,CYDrawsNoHet,vWageHat,BPS_eta_c_p));
%   How much permanent inequality without heterogeneity:
simPI_BPSeta_NoHet              = mean(inequality_fit(simPrefDrawsNoHet,PiDrawsNoHet_AT,EsDrawsNoHet_AT,CYDrawsNoHet,vWageHat,BPS_eta_c_p));
%   How much permanent inequality with heterogeneity in pi & es only:
simPI_BPSeta_NoHet_EmpPiEs      = mean(inequality_fit(simPrefDrawsNoHet,PiDrawsEmp,EsDrawsEmp,CYDrawsNoHet,vWageHat,BPS_eta_c_p));
%   How much permanent inequality with heterogeneity in preferences only:
simPI_BPSeta_PrefMVN            = mean(inequality_fit(simPrefDrawsMVN,PiDrawsNoHet_AT,EsDrawsNoHet_AT,CYDrawsNoHet,vWageHat,BPS_eta_c_p));

%   Clear unneeded variables:
clearvars i simPI_NoHet_EmpPiEs simPI_PrefMVN BPS_Epi BPS_Es BPS_eta_c_p ;


%%  6.  CONSUMPTION INEQUALITY TABLE (Table 6)
%   Construct and save consumption inequality decomposition table. 
%   -----------------------------------------------------------------------

%   Assemble consumption inequality decomposition table and round:
cons_decomp_table = [   vardcHat_c1                 (vardcHat_c1/vardcHat_c1)*100           NaN                                                     NaN                                             ; ...
                        seVardc_c1                   NaN                                    NaN                                                     NaN                                             ; ...
                        sim_cIntsability_ph         (sim_cIntsability_ph/vardcHat_c1)*100   (sim_cIntsability_ph/sim_cIntsability_ph)*100           NaN                                             ; ...
                        sim_cIntsability_noph        NaN                                    (sim_cIntsability_noph/sim_cIntsability_ph)*100         NaN                                             ; ...
                        sim_cIntsability_ph_induced  NaN                                    (sim_cIntsability_ph_induced/sim_cIntsability_ph)*100   NaN                                             ; ...
                        sim_cPermanent_ph           (sim_cPermanent_ph/vardcHat_c1)*100     NaN                                                     (sim_cPermanent_ph/sim_cPermanent_ph)*100       ; ...
                        sim_cPermanent_noph          NaN                                    NaN                                                     (sim_cPermanent_noph/sim_cPermanent_ph)*100     ; ...
                        sim_cPermanent_PrefMVN       NaN                                    NaN                                                     (sim_cPermanent_PrefMVN/sim_cPermanent_ph)*100  ; ...
                        sim_cPermanent_ph            NaN                                    NaN                                                     (sim_cPermanent_ph/sim_cPermanent_ph)*100     ] ;
cons_decomp_table = [round(cons_decomp_table(:,1),3) round(cons_decomp_table(:,2),1) round(cons_decomp_table(:,3),1) round(cons_decomp_table(:,4),1) ] ;

%   Write table:
xlswrite(strcat(dDir,'/tables/table_6.csv'),cons_decomp_table,1)
clearvars cons_decomp_table ineq_vls_ph ineq_vls_noph sim*;


%%  7.  CONSUMPTION SUBSTITUTION ELASTICITY OVER CONSUMPTION MEASUREMENT ERROR
%   Obtain consumption substitution elasticity that matches simulated
%   consumption inequality to the empirical variance of consumption growth,
%   varying the degree of consumption measurement error. 

%   Note that this operation requires the use of preference parameters 
%   that account for the varying degree of consumption error. These
%   parameters are available in 'cme_estimates_1' from consumption_error.m
%   -----------------------------------------------------------------------

%   To understand how the consumption substitution elasticity changes with
%   the amount of consumption measurement error, I look for the elasticity
%   that matches the empirical variance of consumption growth over a range 
%   of values for the variance of consumption error:
%   -vector for values for variance of consumption error:
cme_vector      = 0.00:0.01:0.50 ;
%   -variance of consumption growth without error:
vdc = zeros(T,1);
j = 2 ;
while j <= (T-1) 
    vdc(j) = (mc1.Couple(4*T+j,:).*mc1.Couple(4*T+j,:)) * (mc1.Ind(4*T+j,:).*mc1.Ind(4*T+j,:))' ;
    vdc(j) = vdc(j) / (mc1.Ind(4*T+j,:)*mc1.Ind(4*T+j,:)') ;
    j = j + 1 ;
end
mvdc = mean(vdc(2:T-1)) ;
%   -variance of consumption growth over range of error:
vardcHat_c1_error = zeros(length(cme_vector),1) ;
for rr = 1:1:length(cme_vector)
    vardcHat_c1_error(rr) = mvdc - 2*(cme_vector(rr)/2)*mvdc ;
end
clearvars j rr mvdc vdc

%   Declare arrays for 'eta_c_p' and simulated inequality that will 
%   collect the results:
eta_c_p_hat_error   = zeros(1,length(cme_vector)) ;
sim_Dc_error        = zeros(1,length(cme_vector)) ;

%   Loop over extent of consumption measurement error:
for kk=1:1:length(cme_vector)
    
    %   -retrieve corresponding preference parameters:
    eta_c_w1            = cme_estimates_1(1,kk) ;   
    eta_c_w2            = cme_estimates_1(2,kk) ;  
    eta_h1_w1           = cme_estimates_1(3,kk) ;
    eta_h2_w2           = cme_estimates_1(4,kk) ;  
    Veta_c_w1           = cme_estimates_1(5,kk) ;
    Veta_c_w2           = cme_estimates_1(6,kk) ;
    Veta_h1_w1          = cme_estimates_1(7,kk) ;
    Veta_h2_w2          = cme_estimates_1(8,kk) ; 
    COVeta_c_w1_c_w2    = cme_estimates_1(9,kk)  ;
    COVeta_c_w1_h1_w1   = cme_estimates_1(10,kk) ;
    COVeta_c_w1_h2_w2   = cme_estimates_1(11,kk) ;
    COVeta_c_w2_h1_w1   = cme_estimates_1(12,kk) ;
    COVeta_c_w2_h2_w2   = cme_estimates_1(13,kk) ; 
    COVeta_h1_w1_h2_w2  = cme_estimates_1(14,kk) ;
    
    %   -declare first  and second moments of error-conditional preferences:
    Mu = [ eta_c_w1 eta_c_w2 eta_h1_w1 eta_h2_w2 ] ;
    %           eta_c_w1            eta_c_w2            eta_h1_w1           eta_h2_w2
    Sigma = [   Veta_c_w1           COVeta_c_w1_c_w2    COVeta_c_w1_h1_w1   COVeta_c_w1_h2_w2   ; % eta_c_w1
                COVeta_c_w1_c_w2    Veta_c_w2           COVeta_c_w2_h1_w1   COVeta_c_w2_h2_w2   ; % eta_c_w2
                COVeta_c_w1_h1_w1   COVeta_c_w2_h1_w1   Veta_h1_w1          COVeta_h1_w1_h2_w2  ; % eta_h1_w1
                COVeta_c_w1_h2_w2   COVeta_c_w2_h2_w2   COVeta_h1_w1_h2_w2  Veta_h2_w2 ] ;        % eta_h2_w2
    eigv = eig(Sigma) ;
    if eigv(1) < 0
        Sigma(1,2) = Sigma(1,2)-1e-3 ;
        Sigma(2,1) = Sigma(2,1)-1e-3 ;
    end
    
    %   -draw preferences from multivariate normal
    rng(0);     % Set a starting seed
    simPrefDraws_me = zeros(length(Mu),num_pref_rdraws,num_pref_sims);
    for s = 1:1:num_pref_sims
        mR = mvnrnd(Mu,Sigma,num_pref_rdraws) ;
        simPrefDraws_me(:,:,s) = mR' ;
    end
    parambounds         = [Mu'-sd_trim_pref_draws*sqrt(diag(Sigma)) , Mu'+sd_trim_pref_draws*sqrt(diag(Sigma))] ;
    for pp = 1:1:length(Mu)
        simPrefDraws_me(pp,simPrefDraws_me(pp,:)<parambounds(pp,1)) = parambounds(pp,1) ;
        simPrefDraws_me(pp,simPrefDraws_me(pp,:)>parambounds(pp,2)) = parambounds(pp,2) ;
    end    
    clearvars s pp mR eta_c_w* eta_h* Veta_* COVeta_* parambounds Mu Sigma eigv ;
    
    %   Note that, because of lack of cross-sectional variation in the
    %   price of consumption, the consumption substitution elasticity is
    %   noy identified very well. The model can typically reproduce the 
    %   empirical variance of consumption growth with multiple values of
    %   the consumption substitution elasticty (see e.g. footnote 27). 
    %   To avoid the problem of multiple 'best' values, I restrict 
    %   attention to smaller (in magnitude) values for eta_cp, that is, 
    %   values in the second half of vector 'ineq_vls_eta_c_p'.
    ineq_vls_eta_c_p_res = ineq_vls_eta_c_p(226:end) ; 
        
    %   -evaluate functions over range of eta_c_p:
    ineq_vls_ph_me   = zeros(num_pref_sims,length(ineq_vls_eta_c_p_res),3);
    for ss=1:1:length(ineq_vls_eta_c_p_res)
        [ineq_vls_ph_me(:,ss,1), ~, ineq_vls_ph_me(:,ss,3)] = ...
            inequality_fit(simPrefDraws_me, PiDrawsEmp, EsDrawsEmp, CYDrawsNoHet, vWageHat, ineq_vls_eta_c_p_res(ss));
        if mod(ss,10)==0 
            fprintf('.') 
        end
    end
    
    %   -total simulated inequality:
    sim_ineq_ph_me = ineq_vls_ph_me(:,:,1) + ineq_vls_ph_me(:,:,3);
    sim_ineq_ph_me = mean(sim_ineq_ph_me,1);
    
    %   -obtain best consumption substitution elasticity given value of
    %   consumption measurement error:
    [fval_k,xx]             = min((sim_ineq_ph_me-vardcHat_c1_error(kk)).^2) ;
    eta_c_p_hat_error(kk)   = ineq_vls_eta_c_p_res(xx) ;
    sim_Dc_error(kk)        = sim_ineq_ph_me(xx) ;
    fprintf('Finished measurement error round = %u\n',kk)
    clearvars ss fval_k xx sim_ineq_ph_me simPrefDraws_me
end
clearvars kk ineq_vls_ph_me ineq_vls_eta_c_p_res

%   Produce figure for how the consumption substitution elasticity varies 
%   with the amount of consumption error:
figure;
Y = eta_c_p_hat_error;
h = plot(cme_vector,Y);
%   -line color and width;
h.Color = 'red';
h.LineWidth = 2.0;
%   -axis:
ax = gca;
ax.YLim = [-1.2 0.0];
ax.FontSize = 22;
xlabel('fraction of Var(\Deltac) attributed to consumption error');
ylabel('\eta_{c,p}');
%   -marker for baseline parameter estimate:
hold on
g = plot(0.15,eta_c_p_hat_ph,'b*') ;
g.MarkerSize = 20;
%	-save figure and close:
fig=gcf;
set(fig,'PaperOrientation','landscape');
print(fig,strcat(dDir,'/figures/figure_e2.pdf'),'-dpdf','-bestfit') ;
close all 
clearvars Y fig g h ax


%%  8.  DECOMPOSE INEQUALITY WITHOUT CONSUMPTION ERROR and WITH CONSUMPTION ERROR = 40%*VAR(DC)
%   Calculate consumption instability and permanent inequality under 
%   different amounts of consumption error.
%   -----------------------------------------------------------------------

%   Initialize arrays to hold results:
c_error = [1 40];
sim_cIntsability_ph_me          = zeros(2,1);
sim_cIntsability_noph_me        = zeros(2,1);
sim_cIntsability_ph_induced_me  = zeros(2,1);
sim_cPermanent_ph_me            = zeros(2,1);
sim_cPermanent_noph_me          = zeros(2,1);
sim_cPermanent_PrefMVN_me       = zeros(2,1);

%   Loop over 0% and 40% consumption error:
for i=1:1:2
    
    %   -retrieve amount of consumption error:
    kk = c_error(i) ;

    %   -retrieve corresponding preference parameters:
    eta_c_w1            = cme_estimates_1(1,kk) ;   
    eta_c_w2            = cme_estimates_1(2,kk) ;  
    eta_h1_w1           = cme_estimates_1(3,kk) ;
    eta_h2_w2           = cme_estimates_1(4,kk) ;  
    Veta_c_w1           = cme_estimates_1(5,kk) ;
    Veta_c_w2           = cme_estimates_1(6,kk) ;
    Veta_h1_w1          = cme_estimates_1(7,kk) ;
    Veta_h2_w2          = cme_estimates_1(8,kk) ; 
    COVeta_c_w1_c_w2    = cme_estimates_1(9,kk)  ;
    COVeta_c_w1_h1_w1   = cme_estimates_1(10,kk) ;
    COVeta_c_w1_h2_w2   = cme_estimates_1(11,kk) ;
    COVeta_c_w2_h1_w1   = cme_estimates_1(12,kk) ;
    COVeta_c_w2_h2_w2   = cme_estimates_1(13,kk) ; 
    COVeta_h1_w1_h2_w2  = cme_estimates_1(14,kk) ;
    
    %   -declare first  and second moments of error-conditional preferences:
    Mu = [ eta_c_w1 eta_c_w2 eta_h1_w1 eta_h2_w2 ] ;
    %           eta_c_w1            eta_c_w2            eta_h1_w1           eta_h2_w2
    Sigma = [   Veta_c_w1           COVeta_c_w1_c_w2    COVeta_c_w1_h1_w1   COVeta_c_w1_h2_w2   ; % eta_c_w1
                COVeta_c_w1_c_w2    Veta_c_w2           COVeta_c_w2_h1_w1   COVeta_c_w2_h2_w2   ; % eta_c_w2
                COVeta_c_w1_h1_w1   COVeta_c_w2_h1_w1   Veta_h1_w1          COVeta_h1_w1_h2_w2  ; % eta_h1_w1
                COVeta_c_w1_h2_w2   COVeta_c_w2_h2_w2   COVeta_h1_w1_h2_w2  Veta_h2_w2 ] ;        % eta_h2_w2
    eigv = eig(Sigma) ;
    if eigv(1) < 0
        Sigma(1,2) = Sigma(1,2)-1e-3 ;
        Sigma(2,1) = Sigma(2,1)-1e-3 ;
    end
    %   -draw preferences from multivariate normal
    rng(0);     % Set a starting seed
    simPrefDraws = zeros(length(Mu),num_pref_rdraws,num_pref_sims);
    for s = 1:1:num_pref_sims
        mR = mvnrnd(Mu,Sigma,num_pref_rdraws) ;
        simPrefDraws(:,:,s) = mR' ;
    end
    parambounds = [Mu'-sd_trim_pref_draws*sqrt(diag(Sigma)) , Mu'+sd_trim_pref_draws*sqrt(diag(Sigma))] ;
    for pp = 1:1:length(Mu)
        simPrefDraws(pp,simPrefDraws(pp,:)<parambounds(pp,1)) = parambounds(pp,1) ;
        simPrefDraws(pp,simPrefDraws(pp,:)>parambounds(pp,2)) = parambounds(pp,2) ;
    end    
    %   -pseudo-draw population of preferences in the absence of heterogeneity:
    simPrefDrawsNoHet = repmat(Mu',1,num_pref_rdraws,num_pref_sims); 
    clearvars s pp mR eta_c_w* eta_h* Veta_* COVeta_* parambounds Mu Sigma eigv ;

    %   Simulate inequality with preference heterogeneity:
    [perm_ph, ~, temp_ph] = ...
                inequality_fit(simPrefDraws, PiDrawsEmp, EsDrawsEmp, CYDrawsNoHet, vWageHat, eta_c_p_hat_error(kk));

    %   Simulate inequality without preference heterogeneity:
    [perm_noph, ~, temp_noph] = ...
                inequality_fit(simPrefDrawsNoHet, PiDrawsEmp, EsDrawsEmp, CYDrawsNoHet, vWageHat, eta_c_p_hat_error(kk));
        
    %   Consumption Instability:
    %   How much consumption instability with preference heterogeneity:
    sim_cIntsability_ph_me(i)           = mean(temp_ph) ;
    %   How much consumption instability without preference heterogeneity:
    sim_cIntsability_noph_me(i)         = mean(temp_noph) ;
    %   How much preference-heterogeneity-induced consumption instability:
    sim_cIntsability_ph_induced_me(i)   = mean(temp_ph) - mean(temp_noph) ;

    %   Permanent Inequality:
    %   How much permanent inequality with full heterogeneity (preferences and initial conditions):
    sim_cPermanent_ph_me(i)             = mean(perm_ph) ;
    %   How much permanent inequality without heterogeneity:
    sim_cPermanent_noph_me(i)           = mean(perm_noph) ;
    %   How much permanent inequality with heterogeneity in preferences only:
    [simPI_PrefMVN,]                    = inequality_fit(simPrefDraws, PiDrawsNoHet_AT, EsDrawsNoHet_AT, CYDrawsNoHet, vWageHat, eta_c_p_hat_error(kk));
    sim_cPermanent_PrefMVN_me(i)       	= mean(simPI_PrefMVN);
    clearvars perm_* temp_*
end

%   Assemble consumption inequality decomposition table, round, save:
cons_decomp_error = [   vardcHat_c1_error(1)                (vardcHat_c1_error(1)/vardcHat_c1_error(1))*100         NaN                                                                 NaN                                                         ; ...
                        sim_cIntsability_ph_me(1)           (sim_cIntsability_ph_me(1)/vardcHat_c1_error(1))*100    (sim_cIntsability_ph_me(1)/sim_cIntsability_ph_me(1))*100           NaN                                                         ; ...
                        sim_cIntsability_noph_me(1)         NaN                                                     (sim_cIntsability_noph_me(1)/sim_cIntsability_ph_me(1))*100       	NaN                                                         ; ...
                        sim_cIntsability_ph_induced_me(1)   NaN                                                     (sim_cIntsability_ph_induced_me(1)/sim_cIntsability_ph_me(1))*100  	NaN                                                         ; ...
                        sim_cPermanent_ph_me(1)             (sim_cPermanent_ph_me(1)/vardcHat_c1_error(1))*100      NaN                                                                 (sim_cPermanent_ph_me(1)/sim_cPermanent_ph_me(1))*100   	; ...
                        sim_cPermanent_noph_me(1)       	NaN                                                     NaN                                                                 (sim_cPermanent_noph_me(1)/sim_cPermanent_ph_me(1))*100     ; ...
                        sim_cPermanent_PrefMVN_me(1)      	NaN                                                     NaN                                                                 (sim_cPermanent_PrefMVN_me(1)/sim_cPermanent_ph_me(1))*100  ; ...
                        sim_cPermanent_ph_me(1)             NaN                                                     NaN                                                                 (sim_cPermanent_ph_me(1)/sim_cPermanent_ph_me(1))*100       ; ...
                        NaN                                 NaN                                                     NaN                                                                 NaN                                                         ; ...
                        vardcHat_c1_error(40)               (vardcHat_c1_error(40)/vardcHat_c1_error(40))*100       NaN                                                                 NaN                                                         ; ...
                        sim_cIntsability_ph_me(2)           (sim_cIntsability_ph_me(2)/vardcHat_c1_error(40))*100   (sim_cIntsability_ph_me(2)/sim_cIntsability_ph_me(2))*100           NaN                                                         ; ...
                        sim_cIntsability_noph_me(2)         NaN                                                     (sim_cIntsability_noph_me(2)/sim_cIntsability_ph_me(2))*100       	NaN                                                         ; ...
                        sim_cIntsability_ph_induced_me(2)   NaN                                                     (sim_cIntsability_ph_induced_me(2)/sim_cIntsability_ph_me(2))*100  	NaN                                                         ; ...
                        sim_cPermanent_ph_me(2)             (sim_cPermanent_ph_me(2)/vardcHat_c1_error(40))*100     NaN                                                                 (sim_cPermanent_ph_me(2)/sim_cPermanent_ph_me(2))*100   	; ...
                        sim_cPermanent_noph_me(2)       	NaN                                                     NaN                                                                 (sim_cPermanent_noph_me(2)/sim_cPermanent_ph_me(2))*100     ; ...
                        sim_cPermanent_PrefMVN_me(2)      	NaN                                                     NaN                                                                 (sim_cPermanent_PrefMVN_me(2)/sim_cPermanent_ph_me(2))*100  ; ...
                        sim_cPermanent_ph_me(2)             NaN                                                     NaN                                                                 (sim_cPermanent_ph_me(2)/sim_cPermanent_ph_me(2))*100 ]     ;
cons_decomp_error = [round(cons_decomp_error(:,1),3) round(cons_decomp_error(:,2),1) round(cons_decomp_error(:,3),1) round(cons_decomp_error(:,4),1) ] ;
xlswrite(strcat(dDir,'/tables/table_e8.csv'),cons_decomp_error,1)
clearvars i cons_decomp_error ineq_* sim* CYDrawsNoHet EsDraws* PiDraws* AT_* kk c_error;
clearvars vardcHat_c1* seVardc_c1;