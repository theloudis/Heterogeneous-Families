
%%  Importance of consumption measurement error
%
%   'Consumption Inequality across Heterogeneous Families'
%
%   This script estimates the preferred specification of the model
%   for different magnitudes of the variance of consumption measurement
%   error (one can also think of this error as reflecting other stochastic 
%   elements too) and the variance of error in wages and earnings. It then 
%   plots the parameters against the magnitude of the error term.
%
%   Alexandros Theloudis
%   LISER Luxembourg 
%   Tilburg Econometrics & Operations Research 
%   Spring 2021
%
%   =======================================================================

%   Initial statements:
global  dDir vWageHat vModelHat_c1 cme_estimates_1 ;


%%  1.  INITIALIZE OBJECTS
%   Estimate the preferred specification for values for the variance of
%   consumption measurement error spanning between 0% and 50% of the 
%   variance of consumption growth.
%   -----------------------------------------------------------------------

%   Vector for values for variance of consumption error:
cme_vector      = 0.00:0.01:0.50 ;

%   Arrays for model parameters when wage & earnings error remain at 
%   baseline value:
cme_estimates_1 = zeros(length(vModelHat_c1.PREF),length(cme_vector)) ;
cme_fvals_1     = zeros(1,length(cme_vector)) ;
cme_flags_1     = zeros(1,length(cme_vector)) ;

%   Arrays for model parameters when wage & earnings error change 
%   proportionally to consumption error:
%cme_estimates_2 = zeros(length(vModelHat_PREF_c1),length(cme_vector)) ;
%cme_fvals_2     = zeros(1,length(cme_vector)) ;
%cme_flags_2     = zeros(1,length(cme_vector)) ;


%%  2.  REQUEST DATA AND ESTIMATE
%   Request baseline sample and estimate preferred specification for 
%   different values of the variance of consumption measurement error.
%   -----------------------------------------------------------------------

%   Read residuals from 1st stage regressions conditional on average past outcomes:
[mc1.Couple, mc1.Ind, mc1.Es, mc1.Pi, mc1.Err, mc1.Avg, ~, mc1.N]  ...
    = handleData('_Cond1/original_PSID_c1.csv', ...
                 '_Cond1/original_PSID_me_c1.csv', ...
                 '_Cond1/avgrat_original_PSID_c1.csv',[]) ;

%   Estimate over values of the variance of consumption measurement error
%   when wage & earnings error remain at baseline value:
for k=1:1:length(cme_vector)
    %   -estimate model:
    [cme_estimates_1(:,k), cme_fvals_1(1,k), cme_flags_1(1,k)] ...
        = estm_model(vWageHat, mc1.Couple, mc1.Ind, mc1.Es, mc1.Pi, mc1.Err, mc1.Avg, 'notify-detailed', 1, 7, 3, cme_vector(k), 'off', 'eye') ;
    fprintf('Finished Consumption Measurement Error Model Estimation round : %u\n',k)
end

%   Estimate over values of the variance of consumption measurement error
%   when wage & earnings error change proportionally to consumption error:
%for k=1:1:length(cme_vector)
%    %   -request wage and earnings errors:
%    cd(strcat(dDir,'/inputs')) ;
%    merror = importdata(strcat('_Measur_error/me_c1_',num2str(k),'.csv')) ;
%    merror = merror.data(:,2:7) ;
%    cd(mDir) ;
%    %   -estimate wages:
%    [current_wages,~,~] = estm_wages(mCouple_c1, mInd_c1, merror, 'notify-detailed', 1, 'eye') ;
%    %   -estimate model:
%    [cme_estimates_2(:,k), cme_fvals_2(1,k), cme_flags_2(1,k)] ...
%        = estm_model(current_wages, mc1.Couple, mc1.Ind, mc1.Es, mc1.Pi, mc1.Err, mc1.Avg, 'notify-detailed', 1, 7, 3, cme_vector(k), 'off', 'eye') ;
%    fprintf('Finished All Measurement Error Model Estimation round : %u\n',k)
%end


%%  3.  VISUALIZE ESTIMATES AGAINST VARIANCE OF MEASUREMENT ERROR (FIGURE E.1)
%   Plot figure per parameter with value of estimate against the variance
%   (as a fraction) of consumption measurement error.
%   -----------------------------------------------------------------------

%   Initialize parameters:
figtitles = {'\eta_{c,w1}','\eta_{c,w2}','\eta_{h1,w1}','\eta_{h2,w2}', ...
             'Var(\eta_{c,w1})','Var(\eta_{c,w2})','Var(\eta_{h1,w1})','Var(\eta_{h2,w2})', ...
             'Cov(\eta_{c,w1},\eta_{c,w2})','Cov(\eta_{c,w1},\eta_{h1,w1})','Cov(\eta_{c,w1},\eta_{h2,w2})', ...
             'Cov(\eta_{c,w2},\eta_{h1,w1})','Cov(\eta_{c,w2},\eta_{h2,w2})','Cov(\eta_{h1,w1},\eta_{h2,w2})'} ;

%   Loop over parameters when wage & earnings error remain at baseline value:
for param = 1:1:(length(vModelHat_c1.PREF)-7)

    %   Produce figure:
    figure;
    Y = cme_estimates_1(param,:);
    h = plot(cme_vector,Y);
    %   -line color and width;
    h.Color = 'red';
    h.LineWidth = 2.0;
    %   -axis:
    ax = gca;
    ax.YLim = [-0.2 0.8];
    ax.FontSize = 22;
    xlabel('fraction of Var(\Deltac) attributed to consumption error');
    ylabel(figtitles(param));
    %   -marker for baseline parameter estimate:
    hold on
    g = plot(0.15,vModelHat_c1.PREF(param),'b*') ;
    g.MarkerSize = 20;

    %   Save figure and close:
    fig=gcf;
    set(fig,'PaperOrientation','landscape');
    print(fig,strcat(dDir,'/figures/figure_e1_',num2str(param),'.pdf'),'-dpdf','-bestfit') ;
    close all
end

%   Loop over parameters when wage & earnings error change proportionally 
%   to consumption error:
%for param = 1:1:(length(vModelHat_c1.PREF)-1)
%
%    %   Produce figure:
%    figure;
%    Y1 = cme_estimates_1(param,:);
%    Y2 = cme_estimates_2(param,:);
%    plot(cme_vector,Y1,'DisplayName','as in baseline','Color','red','LineWidth',2.0);
%    hold on
%    h = plot(cme_vector,Y2,'DisplayName','proportional to consumption error','Color','blue','LineWidth',2.0);
%    hold off
%    %   -axis:
%    ax = gca;
%    ax.YLim = [-0.2 0.8];
%    ax.FontSize = 22;
%    xlabel('fraction of Var(\Deltac) attributed to consumption error');
%    ylabel(figtitles(param));
%    %   -marker for baseline parameter estimate:
%    hold on
%    g = plot(0.15,vModelHat_c1.PREF(param),'b*') ;
%    g.DisplayName = 'baseline estimate' ;
%    g.MarkerSize = 20 ;
%    hold off
%    %  -draw legend:
%    lgd = legend;
%    lgd.Title.String = 'wage & earnings error';
%    lgd.Location = 'northwest' ;
%    lgd.FontSize = 22;
%    
%    %   Save figure and close:
%    fig=gcf;
%    set(fig,'PaperOrientation','landscape');
%    print(fig,strcat(dDir,'/figures/figure_e1_',num2str(param),'_extra.pdf'),'-dpdf','-bestfit') ;
%    close all
%end
             
%   Clear workspace:
clearvars X Y k param figtitles fignames cme_vector cme_fvals* cme_flags* g h ax fig lgd
