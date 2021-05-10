
%%  Consumption partial insurance against wage shocks
%
%   'Consumption Inequality across Heterogeneous Families'
%   This script draws preferences -in the baseline and with family labor 
%   supply inactive- and wealth shares (parts 1 & 2) and:
%   -part 3: builds transmission parameters of permanent and transitory 
%            shocks for the population as well as for the average household.
%   -part 4: exports table of transmission parameters of transitory shocks.
%   -part 5: exports table of transmission parameters of permanent shocks.
%   -part 6: visualizes distrubution of transmission parameters using a
%            kernel density (baseline).
%   -part 7: visualizes distrubution of transmission parameters using a
%            kernel density for different amounts of consumption error.
%
%   Alexandros Theloudis
%   LISER Luxembourg 
%   Tilburg Econometrics & Operations Research 
%   Spring 2021
%
%   =======================================================================

%   Preliminary statements:
global  vModelHat_c1 T num_pref_rdraws num_pref_sims sd_trim_pref_draws dDir cme_estimates_1 ;

%   Declare estimated consumption substitution elasticity (namely the
%   estimates from 'inequality_sim_decomp.m'):
eta_c_p_hat_ph = -0.6 ;
eta_c_p_hat_me = [-0.52 -5175] ;

%   Request data and obtain average partial insurance and human wealth
%   parameters. Note: I condition on pi~=0 and es~=0 to drop zero entries 
%   that appear mechanically because of the inbalanced panel.
%   -request data:
[mc1.Couple, mc1.Ind, mc1.Es, mc1.Pi, mc1.Err, mc1.Avg, ~, mc1.N]  ...
    = handleData('_Cond1/original_PSID_c1.csv', ...
                 '_Cond1/original_PSID_me_c1.csv', ...
                 '_Cond1/avgrat_original_PSID_c1.csv',[]) ;
%   -obtain wealth shares:
pi      = mc1.Pi(2:T,:);
es      = mc1.Es(2:T,:);
AT_Epi  = mean(pi(pi~=0)) ; 
AT_Es   = mean(es(es~=0)) ;


%%  1.  BASELINE PREFERENCE DRAWS
%   Draw preferences for a population of 'num_pref_rdraws' agents 
%   'num_pref_sims' times from the multivariate normal distribution.
%   -----------------------------------------------------------------------

%   Load preferred preference parameters:
vModelHat = vModelHat_c1.PREF ;

%   Declare baseline preference parameters:
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

%   Redeclare first and second moments of preferences shutting down the
%   labor supply responses of the male spouse:
%   Note: this also shuts down the complementarity between consumption and
%   male hours as male hours no longer respond to wages.
MuNLS_H         = [ 0 eta_c_w2 0 eta_h2_w2 ] ;   
SigmaNLS_H      = Sigma ;
SigmaNLS_H(1,:) = 0;
SigmaNLS_H(:,1) = 0; 
SigmaNLS_H(3,:) = 0;
SigmaNLS_H(:,3) = 0; 
      
%   Redeclare first and second moments of preferences shutting down the
%   labor supply responses of the female spouse:
%   Note: this also shuts down the complementarity between consumption and
%   female hours as female hours no longer respond to wages.
MuNLS_W         = [ eta_c_w1 0 eta_h1_w1 0 ] ;      
SigmaNLS_W      = Sigma ;
SigmaNLS_W(2,:) = 0;
SigmaNLS_W(:,2) = 0; 
SigmaNLS_W(4,:) = 0;
SigmaNLS_W(:,4) = 0; 

%   Redeclare first and second moments of preferences shutting down the
%   labor supply responses of both spouses:
MuNLS_all = zeros(1,4) ;

%   Check that 'Sigma' is positive semi-definite. If  not (that shows up as 
%   a first eigenvalue < 0), it is due to the perfect correlation between
%   consumption-wage elasticities. Adjust the correlation slightly:
eigv = eig(Sigma) ;
if eigv(1) < 0
    Sigma(1,2) = Sigma(1,2)-1e-3 ;
    Sigma(2,1) = Sigma(2,1)-1e-3 ;
end

%   Obtain 'num_pref_rdraws' random draws sequentially over 
%   'num_pref_sims' populations:   
rng(0);     % Set a starting seed
simPrefDraws = zeros(length(Mu),num_pref_rdraws,num_pref_sims);
for s = 1:1:num_pref_sims
    mR = mvnrnd(Mu,Sigma,num_pref_rdraws) ;
    simPrefDraws(:,:,s) = mR' ;
end

%   Replace preference draws that fall outside 'sd_trim_pref_draws' s.d.   
%   of the marginal distributions of the respective parameters in order to
%   minimize the effect of extreme preference draws. 
parambounds = [Mu'-sd_trim_pref_draws*sqrt(diag(Sigma)) , Mu'+sd_trim_pref_draws*sqrt(diag(Sigma))] ;
for pp = 1:1:length(Mu)
    simPrefDraws(pp,simPrefDraws(pp,:)<parambounds(pp,1)) = parambounds(pp,1) ;
    simPrefDraws(pp,simPrefDraws(pp,:)>parambounds(pp,2)) = parambounds(pp,2) ;
end 

%   Repeat for when the male spouse's labor supply is shut:
rng(0);     % Set same seed
simPrefDrawsNLS_H = zeros(length(MuNLS_H),num_pref_rdraws,num_pref_sims);
for s = 1:1:num_pref_sims
    mR = mvnrnd(MuNLS_H,SigmaNLS_H,num_pref_rdraws) ;
    simPrefDrawsNLS_H(:,:,s) = mR' ;
end
parambounds = [MuNLS_H'-sd_trim_pref_draws*sqrt(diag(SigmaNLS_H)) , MuNLS_H'+sd_trim_pref_draws*sqrt(diag(SigmaNLS_H))] ;
for pp = 1:1:length(MuNLS_H)
    simPrefDrawsNLS_H(pp,simPrefDrawsNLS_H(pp,:)<parambounds(pp,1)) = parambounds(pp,1) ;
    simPrefDrawsNLS_H(pp,simPrefDrawsNLS_H(pp,:)>parambounds(pp,2)) = parambounds(pp,2) ;
end

%   Repeat when the female spouse's labor supply is shut:
rng(0);     % Set same seed
simPrefDrawsNLS_W = zeros(length(MuNLS_W),num_pref_rdraws,num_pref_sims);
for s = 1:1:num_pref_sims
    mR = mvnrnd(MuNLS_W,SigmaNLS_W,num_pref_rdraws) ;
    simPrefDrawsNLS_W(:,:,s) = mR' ;
end
parambounds = [MuNLS_W'-sd_trim_pref_draws*sqrt(diag(SigmaNLS_W)) , MuNLS_W'+sd_trim_pref_draws*sqrt(diag(SigmaNLS_W))] ;
for pp = 1:1:length(MuNLS_W)
    simPrefDrawsNLS_W(pp,simPrefDrawsNLS_W(pp,:)<parambounds(pp,1)) = parambounds(pp,1) ;
    simPrefDrawsNLS_W(pp,simPrefDrawsNLS_W(pp,:)>parambounds(pp,2)) = parambounds(pp,2) ;
end

%   Clear redundant variables:
clearvars eigv s mR parambounds pp


%%  2.  WEALTH SHARES AND RATIOS OF OUTCOMES
%   Draw initial conditions (pi, es) and ratio of outcomes (c/y1, c/y2) 
%   for a population of 'num_pref_rdraws' agents 'num_pref_sims' times.
%   -----------------------------------------------------------------------

%   Pseudo-draw from degenerate distribution (no heterogeneity):
%   -Ratios of outcomes (c/y1, c/y2)
simCYDrawsNoHet(1) = mc1.Avg(3);
simCYDrawsNoHet(2) = mc1.Avg(4);

%   Draw with replacement from empirical distributions of pi & es, 
%   excluding zeros from both distributions (zeros appear mechanically 
%   because of the inbalanced panel):
rng(21061985);     % Set a starting seed
simPiDrawsEmp = zeros(1,num_pref_rdraws,num_pref_sims);
simEsDrawsEmp = zeros(1,num_pref_rdraws,num_pref_sims);
for s = 1:1:num_pref_sims
    simPiDrawsEmp(1,:,s) = datasample(pi(pi~=0),num_pref_rdraws) ;
    simEsDrawsEmp(1,:,s) = datasample(es(es~=0),num_pref_rdraws) ;
end

%   Clear unneeded variables:
clearvars s


%%  3.  BUILD TRANSMISSION PARAMETERS OF SHOCKS
%   Build a population of transmission parameters of permanent and 
%   transitory shocks; calculate moments.
%   -----------------------------------------------------------------------

%   Obtain transmission parameters of 'num_pref_rdraws' agents across 
%   'num_pref_sims' populations in baseline specification:
[tpv_ph, tpu_ph] = ...
    insurance_tparams(simPrefDraws, simPiDrawsEmp, simEsDrawsEmp, mc1.Avg(3:4), eta_c_p_hat_ph);

%   Repeat for regime of no labor supply response from the male spouse:
[tpv_NLS_H, ~] = ...
    insurance_tparams(simPrefDrawsNLS_H, simPiDrawsEmp, simEsDrawsEmp, mc1.Avg(3:4), eta_c_p_hat_ph);

%   Repeat for regime of no labor supply response from the female spouse:
[tpv_NLS_W, ~] = ...
    insurance_tparams(simPrefDrawsNLS_W, simPiDrawsEmp, simEsDrawsEmp, mc1.Avg(3:4), eta_c_p_hat_ph) ;

%   Repeat for regime of no labor supply responses from either spouse (no heterogeneity regime):
[tpv_NLS_all, ~] = ...
    insurance_tparams(MuNLS_all', simPiDrawsEmp, simEsDrawsEmp, mc1.Avg(3:4), eta_c_p_hat_ph) ;

%   Average transmission parameters in the population: 
%   -- E[\partial Dc / \partial v_j] 
tpv_ph_mean      = [mean(nanmean(squeeze(tpv_ph{1}),1))         mean(nanmean(squeeze(tpv_ph{2}),1))];
tpv_NLS_H_mean   = [mean(nanmean(squeeze(tpv_NLS_H{1}),1))      mean(nanmean(squeeze(tpv_NLS_H{2}),1))];
tpv_NLS_W_mean   = [mean(nanmean(squeeze(tpv_NLS_W{1}),1))      mean(nanmean(squeeze(tpv_NLS_W{2}),1))];
tpv_NLS_all_mean = [mean(nanmean(squeeze(tpv_NLS_all{1}),1))    mean(nanmean(squeeze(tpv_NLS_all{2}),1))];
%   -- E[\partial Dc / \partial u_j]
tpu_ph_mean      = [mean(mean(squeeze(tpu_ph{1}),1))            mean(mean(squeeze(tpu_ph{2}),1))];

%   Transmission parameters in the average household: 
%   -- \partial Dc / \partial v_j and \partial Dc / \partial u_j 
[tpv_avghh, tpu_avghh] = ...
    insurance_tparams(Mu', AT_Epi, AT_Es, mc1.Avg(3:4), eta_c_p_hat_ph);
[tpv_NLS_H_avghh, ~] = insurance_tparams(MuNLS_H', AT_Epi, AT_Es, mc1.Avg(3:4), eta_c_p_hat_ph);
[tpv_NLS_W_avghh, ~] = insurance_tparams(MuNLS_W', AT_Epi, AT_Es, mc1.Avg(3:4), eta_c_p_hat_ph);

%   Standard deviations of within population average transmission parameters 
%   E[\partial Dc / \partial v_j] and E[\partial Dc / \partial u_j] across
%   populations:
%tpv_ph_std     = [std(nanmean(squeeze(tpv_ph{1}),1))       std(nanmean(squeeze(tpv_ph{2}),1))];
%tpv_NLS_H_std  = [std(nanmean(squeeze(tpv_NLS_H{1}),1))    std(nanmean(squeeze(tpv_NLS_H{2}),1))];
%tpv_NLS_W_std  = [std(nanmean(squeeze(tpv_NLS_W{1}),1))    std(nanmean(squeeze(tpv_NLS_W{2}),1))];


%%  4.  EXPORT TABLE OF TRANSMISSION PARAMETERS OF TRANSITORY SHOCKS (TABLE 7)
%   Assemble and export table.
%   -----------------------------------------------------------------------

%   By construction, the average transmission parameter of transitory 
%   shocks is equal to the transmission parameter of the average person, 
%   i.e. E[\partial Dc / \partial u_j] = E[\eta_c_w_j]. In addition, the
%   distribution of \partial Dc / \partial u_j is the distribution of \eta_c_w_j.

%   Assemble table:
tp_trans = [ eta_c_w1, eta_c_w1, eta_c_w1+0.5*sqrt(Veta_c_w1), eta_c_w1+1.5*sqrt(Veta_c_w1), eta_c_w1-0.5*sqrt(Veta_c_w1), eta_c_w1-1.5*sqrt(Veta_c_w1);
             eta_c_w2, eta_c_w2, eta_c_w2+0.5*sqrt(Veta_c_w2), eta_c_w2+1.5*sqrt(Veta_c_w2), eta_c_w2-0.5*sqrt(Veta_c_w2), eta_c_w2-1.5*sqrt(Veta_c_w2)];
tp_trans = round(tp_trans,3) ;

%   Export table:
xlswrite(strcat(dDir,'/tables/table_7.csv'),tp_trans,1)


%%  5.  EXPORT TABLE OF TRANSMISSION PARAMETERS OF PERMANENT SHOCKS (TABLE 8)
%   Assemble and export table.
%   -----------------------------------------------------------------------

%   Assemble table:
tp_perm = [ tpv_ph_mean(1), tpv_avghh{1}, tpv_NLS_H_mean(1), tpv_NLS_H_avghh{1}, tpv_NLS_W_mean(1), tpv_NLS_W_avghh{1}, tpv_NLS_all_mean(1)  ;
            tpv_ph_mean(2), tpv_avghh{2}, tpv_NLS_H_mean(2), tpv_NLS_H_avghh{2}, tpv_NLS_W_mean(2), tpv_NLS_W_avghh{2}, tpv_NLS_all_mean(2)] ;
tp_perm = round(tp_perm,3) ;

%   Export table:
xlswrite(strcat(dDir,'/tables/table_8.csv'),tp_perm,1)

%   Clear redundant variables:
clearvars AT_* COV* Mu* replacements* Sigma* Veta* ;


%%  6.  PLOT TRANSMISSION PARAMETERS OF SHOCKS (FIGURE 2)
%   Plot the transmission parameters of permanent and transitory shocks 
%   in the population. 
%   -----------------------------------------------------------------------

%   A. Nonparametric kernel density of partial insurance against permanent shocks.

%   Declare domain:
domain_dens = -.05:.005:1.05;

%   Estimate nonparametric densities. I choose a moderate bandwidth so as 
%   to illustrate main features of distribution without exaggerating details.
tpv1                = tpv_ph{1};
tpv2                = tpv_ph{2};
nonparampdf_tpv1    = pdf(fitdist(tpv1(:),'kernel','Kernel','epanechnikov','BandWidth',0.08),domain_dens);
nonparampdf_tpv2    = pdf(fitdist(tpv2(:),'kernel','Kernel','epanechnikov','BandWidth',0.08),domain_dens);

%   Plot nonparametric densities:
p = plot(   domain_dens,nonparampdf_tpv1,'k-', ...  % distribution of partial insurance against male shock
            domain_dens,nonparampdf_tpv2,'r--');    % distribution of partial insurance against female shock
p(1).LineWidth = 2;
p(2).LineWidth = 2;
ax = gca ;             % request axes
ax.XLim = [-.05 1.05]; % shrink x axis
%   -plot mean of transmission parameters:
hold on
pmean = plot([tpv_ph_mean(1),tpv_ph_mean(1)],[0,nonparampdf_tpv1(find(domain_dens>tpv_ph_mean(1)-3e-3&domain_dens<tpv_ph_mean(1)+3e-3,1))],'k:',...
             [tpv_ph_mean(2),tpv_ph_mean(2)],[0,nonparampdf_tpv2(find(domain_dens>tpv_ph_mean(2)-3e-3&domain_dens<tpv_ph_mean(2)+3e-3,1))],'r:');
pmean(1).LineWidth = 1.5;       % vertical line thickness
pmean(2).LineWidth = 1.5;       % vertical line thickness
hold off
%   -type legend:
legend( '\partial \Delta c / \partial v_{1}',   '\partial \Delta c / \partial v_{2}',...
        'E[\partial \Delta c / \partial v_{1}]','E[\partial \Delta c / \partial v_{2}]');
ylabel('kernel density (epanechnikov)');

%   Save figure:
fig=gcf;
set(fig,'PaperOrientation','landscape');
print(fig,strcat(dDir,'/figures/figure_2b.pdf'),'-dpdf','-bestfit') ;
close all

%   B. Parametric density of partial insurance against transitory shocks.

%   Declare domain:
domain_dens = -1.2:.005:1.2;

%   Estimate parametric densities:
%   Note: I choose parametric (normal) over non-parametric density here
%   because the data are drawn from the joint normal.
tpu1                = tpu_ph{1};
tpu2                = tpu_ph{2};
nonparampdf_tpu1    = pdf(fitdist(tpu1(:),'normal'),domain_dens);
nonparampdf_tpu2    = pdf(fitdist(tpu2(:),'normal'),domain_dens);

%   Plot parametric densities:
p = plot(domain_dens,nonparampdf_tpu1,'k-',domain_dens,nonparampdf_tpu2,'r--');
p(1).LineWidth = 2;
p(2).LineWidth = 2;
ax = gca ;             % request axes
ax.XLim = [-1.1 1.1];  % shrink x axis

%   Plot mean of transmission parameters:
hold on
pmean = plot([eta_c_w1,eta_c_w1],[0,nonparampdf_tpu1(find(domain_dens>eta_c_w1-3e-3&domain_dens<eta_c_w1+3e-3,1))],'k:',...
             [eta_c_w2,eta_c_w2],[0,nonparampdf_tpu2(find(domain_dens>eta_c_w2-3e-3&domain_dens<eta_c_w2+3e-3,1))],'r:');
pmean(1).LineWidth = 1.5;       % vertical line thickness
pmean(2).LineWidth = 1.5;       % vertical line thickness
hold off

%   Type legend:
legend( '\partial \Delta c / \partial u_{1}','\partial \Delta c / \partial u_{2}',...
        'E[\eta_{c,w_{1}}]','E[\eta_{c,w_{2}}]');
ylabel('normal density');

%   Save figure:
fig=gcf;
set(fig,'PaperOrientation','landscape');
print(fig,strcat(dDir,'/figures/figure_2a.pdf'),'-dpdf','-bestfit') ;
close all


%%  7.  PLOT TRANSMISSION PARAMETERS OF SHOCKS WITHOUT CONSUMPTION ERROR and WITH CONSUMPTION ERROR = 40%*VAR(DC) (FIGURE E.5)
%   Plot the transmission parameters of permanent and transitory shocks 
%   under different amounts of consumption error.
%   -----------------------------------------------------------------------

%   Consumption error array:
c_error = [1 40];

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
    eta_c_p             = eta_c_p_hat_me(i) ;
    
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
    clearvars s pp mR eta_h* Veta_* COVeta_* parambounds Mu Sigma eigv ;
    
    %   -obtain transmission parameters of 'num_pref_rdraws' agents across 
    %   'num_pref_sims' populations:
    [tpv_ph, tpu_ph] = ...
        insurance_tparams(simPrefDraws, simPiDrawsEmp, simEsDrawsEmp, mc1.Avg(3:4), eta_c_p);
    tpv_ph_mean      = [mean(nanmean(squeeze(tpv_ph{1}),1)) mean(nanmean(squeeze(tpv_ph{2}),1))];
    
    %   A. Nonparametric kernel density of partial insurance against permanent shocks.
    %   -declare domain:
    domain_dens = -.05:.005:1.05;

    %   -estimate nonparametric densities:
    tpv1                = tpv_ph{1};
    tpv2                = tpv_ph{2};
    nonparampdf_tpv1    = pdf(fitdist(tpv1(:),'kernel','Kernel','epanechnikov','BandWidth',0.08),domain_dens);
    nonparampdf_tpv2    = pdf(fitdist(tpv2(:),'kernel','Kernel','epanechnikov','BandWidth',0.08),domain_dens);

    %   -plot nonparametric densities:
    p = plot(   domain_dens,nonparampdf_tpv1,'k-', ...  % distribution of partial insurance against male shock
                domain_dens,nonparampdf_tpv2,'r--');    % distribution of partial insurance against female shock
    p(1).LineWidth = 2;
    p(2).LineWidth = 2;
    ax = gca ;             % request axes
    ax.XLim = [-.05 1.05]; % shrink x axis
    %   -plot mean of transmission parameters:
    hold on
    pmean = plot([tpv_ph_mean(1),tpv_ph_mean(1)],[0,nonparampdf_tpv1(find(domain_dens>tpv_ph_mean(1)-3e-3&domain_dens<tpv_ph_mean(1)+3e-3,1))],'k:',...
                 [tpv_ph_mean(2),tpv_ph_mean(2)],[0,nonparampdf_tpv2(find(domain_dens>tpv_ph_mean(2)-3e-3&domain_dens<tpv_ph_mean(2)+3e-3,1))],'r:');
    pmean(1).LineWidth = 1.5;       % vertical line thickness
    pmean(2).LineWidth = 1.5;       % vertical line thickness
    hold off
    %   -type legend:
    legend( '\partial \Delta c / \partial v_{1}',   '\partial \Delta c / \partial v_{2}',...
            'E[\partial \Delta c / \partial v_{1}]','E[\partial \Delta c / \partial v_{2}]');
    ylabel('kernel density (epanechnikov)');
    %   -save figure:
    fig=gcf;
    set(fig,'PaperOrientation','landscape');
    print(fig,strcat(dDir,'/figures/figure_e5b_',num2str(i),'.pdf'),'-dpdf','-bestfit') ;
    close all

    %   B. Parametric density of partial insurance against transitory shocks.
    %   -declare domain:
    domain_dens = -1.2:.005:1.2;
    %   -estimate parametric densities:
    tpu1                = tpu_ph{1};
    tpu2                = tpu_ph{2};
    nonparampdf_tpu1    = pdf(fitdist(tpu1(:),'normal'),domain_dens);
    nonparampdf_tpu2    = pdf(fitdist(tpu2(:),'normal'),domain_dens);
    %   -plot parametric densities:
    p = plot(domain_dens,nonparampdf_tpu1,'k-',domain_dens,nonparampdf_tpu2,'r--');
    p(1).LineWidth = 2;
    p(2).LineWidth = 2;
    ax = gca ;             % request axes
    ax.XLim = [-1.1 1.1];  % shrink x axis
    %   -plot mean of transmission parameters:
    hold on
    pmean = plot([eta_c_w1,eta_c_w1],[0,nonparampdf_tpu1(find(domain_dens>eta_c_w1-3e-3&domain_dens<eta_c_w1+3e-3,1))],'k:',...
                 [eta_c_w2,eta_c_w2],[0,nonparampdf_tpu2(find(domain_dens>eta_c_w2-3e-3&domain_dens<eta_c_w2+3e-3,1))],'r:');
    pmean(1).LineWidth = 1.5;       % vertical line thickness
    pmean(2).LineWidth = 1.5;       % vertical line thickness
    hold off
    %   -type legend:
    legend( '\partial \Delta c / \partial u_{1}','\partial \Delta c / \partial u_{2}',...
            'E[\eta_{c,w_{1}}]','E[\eta_{c,w_{2}}]');
    ylabel('normal density');
    %   -save figure:
    fig=gcf;
    set(fig,'PaperOrientation','landscape');
    print(fig,strcat(dDir,'/figures/figure_e5a_',num2str(i),'.pdf'),'-dpdf','-bestfit') ;
    close all
end

%   Clear all redundant variables:
clearvars domain_dens ax nonparampdf_* tpv* tpu* p pmean AT_* BPS_* COVeta* eta_* Veta* 
clearvars tp_perm tp_trans i sim* pi es kk c_error fig