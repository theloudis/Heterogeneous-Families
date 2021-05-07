
%%  Heterogeneity across age and calendar time brackets
%
%   'Consumption Inequality across Heterogeneous Families'
%
%   This script estimates the preferred specification of the structural 
%   model along the distribution of age and (separately) calendar time, 
%   and plots the parameters against the value of age/time.
%
%   Alexandros Theloudis
%   LISER Luxembourg 
%   Tilburg Econometrics & Operations Research 
%   Spring 2021
%
%   =======================================================================

%   Initial statements:
global  dDir vWageHat vModelHat_c1 ;


%%  1.  INITIALIZE OBJECTS
%   Estimate the preferred specification over 6 age bands and 3 calendar
%   time bands. These bands are for:
%       -age household head 30-35, 35-40, 40-45, 45-50, 50-55, 55-60;
%   and separately for:
%       -calendar years 1999-2003, 2005-2007, 2009-2011.
%   -----------------------------------------------------------------------

%   Matrices for parameter estimates & estimation output:
%   -age heterogeneity:
age_values     = ["3035";"3540";"4045";"4550";"5055";"5560"] ;
age_legend     = ["30-35";"35-40";"40-45";"45-50";"50-55";"55-60"] ;
age_estimates  = zeros(length(vModelHat_c1.PREF),6) ;
age_fvals      = zeros(1,6) ;
age_flags      = zeros(1,6) ;
%   -calendar time heterogeneity:
time_values    = ["2003";"2007";"2011"] ;
time_legend    = ["1999-2003";"2005-2007";"2009-2011"] ;
time_estimates = zeros(length(vModelHat_c1.PREF),3) ;
time_fvals     = zeros(1,3) ;
time_flags     = zeros(1,3) ;


%%  2.  REQUEST AGE-CONDITIONAL DATA AND ESTIMATE
%   Request age-conditional PSID data and estimate preferred specification.
%   -----------------------------------------------------------------------

%   Loop over 6 age bands.
for k=1:1:length(age_values)
    
    %   Read residuals from 1st stage regressions conditional on age and 
    %   age-specific past outcomes:
    [mCouple_age, mInd_age, mEs_age, mPi_age, mErr_age, ~, ~, N_age]  ...
    = handleData(strcat('_Age/original_PSID_c1_',age_values(k),'.csv'), ...
                 strcat('_Age/original_PSID_me_c1_',age_values(k),'.csv'),[],[]) ;
             
    %   Run estimation:
    [age_estimates(:,k), age_fvals(1,k), age_flags(1,k)] ...
        = estm_model(vWageHat, mCouple_age, mInd_age, mEs_age, mPi_age, mErr_age, [], 'notify-detailed', 1, 7, 3, 0.15, 'off', 'eye') ;
    clearvars mCouple_age mInd_age mEs_age mPi_age mErr_age N_age
    fprintf('Finished Age-Conditional Model Estimation round : %u\n',k)
end

%   Loop over 3 time bands.
for k=1:1:length(time_values)
    
    %   Read residuals from 1st stage regressions conditional on calendar 
    %   time and time-specific past outcomes:
    [mCouple_time, mInd_time, mEs_time, mPi_time, mErr_time, ~, ~, N_time]  ...
    = handleData(strcat('_Time/original_PSID_c1_',time_values(k),'.csv'), ...
                 strcat('_Time/original_PSID_me_c1_',time_values(k),'.csv'),[],[]) ;
             
    %   Run estimation:
    [time_estimates(:,k), time_fvals(1,k), time_flags(1,k)] ...
        = estm_model(vWageHat, mCouple_time, mInd_time, mEs_time, mPi_time, mErr_time, [], 'notify-detailed', 1, 7, 3, 0.15, 'off', 'eye') ;
    clearvars mCouple_time mInd_time mEs_time mPi_time mErr_time N_time
    fprintf('Finished Time-Conditional Model Estimation round : %u\n',k)
end


%%  3.  VISUALIZE ESTIMATES AGAINST VALUES OF AGE or TIME (figures E.3 and E.4)
%   Plot figure per parameter with value of estimate against the
%   corresponding value for age or calendar time.
%   -----------------------------------------------------------------------

%   Initialize parameters:
figtitles = {'\eta_{c,w1}','\eta_{c,w2}','\eta_{h1,w1}','\eta_{h2,w2}', ...
             'Var(\eta_{c,w1})','Var(\eta_{c,w2})','Var(\eta_{h1,w1})','Var(\eta_{h2,w2})', ...
             'Cov(\eta_{c,w1},\eta_{c,w2})','Cov(\eta_{c,w1},\eta_{h1,w1})','Cov(\eta_{c,w1},\eta_{h2,w2})', ...
             'Cov(\eta_{c,w2},\eta_{h1,w1})','Cov(\eta_{c,w2},\eta_{h2,w2})','Cov(\eta_{h1,w1},\eta_{h2,w2})'} ;
fignames  = {'eta_c_w1','eta_c_w2','eta_h1_w1','eta_h2_w2','Vc_w1','Vc_w2','Vh1_w1','Vh2_w2', ...
             'Cc_w1_c_w2','Cc_w1_h1_w1','Cc_w1_h2_w2','Cc_w2_h1_w1','Cc_w2_h2_w2','Ch1_w1_h2_w2'} ;

%   Loop over age-specific parameters:
for param = 1:1:(length(vModelHat_c1.PREF)-7)

    %   Produce figure:
    figure;
    Y = age_estimates(param,:);
    h = plot(1:numel(age_values),Y);
    %   -line color and width;
    h.Color = 'red';
    h.LineWidth = 2.0;
    %   -axis:
    ax = gca;
    ax.YLim = [-0.8 1.0];
    ax.FontSize = 32;
    ax.XTick = 1:numel(age_values);
    ax.XTickLabel = age_legend;
    %   -marker for baseline parameter estimate:
    hold on
    g = plot(mean(1:numel(age_values)),vModelHat_c1.PREF(param),'b*') ;
    g.MarkerSize = 20;

    %   Save figure and close:
    fig=gcf;
    set(fig,'PaperOrientation','landscape');
    print(fig,strcat(dDir,'/figures/figure_e3_',num2str(param),'.pdf'),'-dpdf','-bestfit') ;
    close all
end

%   Loop over time-specific parameters:
for param = 1:1:(length(vModelHat_c1.PREF)-7)

    %   Produce figure:
    figure;
    Y = time_estimates(param,:);
    h = plot(1:numel(time_values),Y);
    %   -line color and width;
    h.Color = 'red';
    h.LineWidth = 2.0;
    %   -axis:
    ax = gca;
    ax.YLim = [-0.8 1.0];
    ax.FontSize = 32;
    ax.XTick = 1:numel(time_values);
    ax.XTickLabel = time_legend;
    %   -marker for baseline parameter estimate:
    hold on
    g = plot(mean(1:numel(time_values)),vModelHat_c1.PREF(param),'b*') ;
    g.MarkerSize = 20;

    %   Save figure and close:
    fig=gcf;
    set(fig,'PaperOrientation','landscape');
    print(fig,strcat(dDir,'/figures/figure_e4_',num2str(param),'.pdf'),'-dpdf','-bestfit') ;
    close all
end

%   Clear workspace:
clearvars X Y k param figtitles fignames g h ax fig
clearvars age_estimates age_fvals age_flags age_values age_legend
clearvars time_estimates time_fvals time_flags time_values time_legend