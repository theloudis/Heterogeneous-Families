
%%  Heterogeneity across outcome distribution
%
%   'Consumption Inequality across Heterogeneous Families'
%
%   This script estimates the preferred specification of the structural 
%   model along the entire distribution of outcomes, and plots the 
%   parameters against the value of conditioning outcomes.
%
%   Alexandros Theloudis
%   LISER Luxembourg 
%   Tilburg Econometrics & Operations Research 
%   Spring 2021
%
%   =======================================================================

%   Initial statements:
global  dDir vWageHat vModelHat_c1 ;

%   Number of points in the marginal distribution of each outcome: 
fineness_param = 10 ;


%%  1.  INITIALIZE OBJECTS
%   Estimate the preferred specification over entire distribution of
%   conditioning outcomes.
%   -----------------------------------------------------------------------

%   Matrices for parameter estimates & estimation output:
distr_estimates  = zeros(length(vModelHat_c1.PREF),fineness_param,fineness_param,fineness_param) ;
distr_fvals      = zeros(1,fineness_param,fineness_param,fineness_param) ;
distr_flags      = zeros(1,fineness_param,fineness_param,fineness_param) ;


%%  2.  REQUEST OUTCOME-CONDITIONAL DATA AND ESTIMATE
%   Request outcome-conditional data and estimate model over points on the 
%   marginal distributions that I intend to visualize in the next part.
%   -----------------------------------------------------------------------

%   A.  Loop over points in the marginal distributions of male hours / 
%       female hours, given consumption index 6 (just above average consumption):
%cc = 6;
%for hh=1:1:fineness_param               % loop over conditioning male hours
%    for hw=1:1:fineness_param           % loop over conditioning female hours
%    
%        %   Read residuals:
%       	[mCouple_distr, mInd_distr, mEs_distr, mPi_distr, mErr_distr, ~, ~, ~]  ...
%            = handleData(strcat('_Distribution/PSID_hh',string(hh),'_hw',string(hw),'_cc',string(cc),'.csv'), ...
%                         strcat('_Distribution/PSID_me_hh',string(hh),'_hw',string(hw),'_cc',string(cc),'.csv'),[],[]) ;
%             
%    	%   Run estimation & collect results:
%    	[distr_estimates(:,hh,hw,cc), distr_fvals(1,hh,hw,cc), distr_flags(1,hh,hw,cc)] ...
%            = estm_model(vWageHat, mCouple_distr, mInd_distr, mEs_distr, mPi_distr, mErr_distr, [], ...
%                                'notify-detailed', 1, 7, 3, 0.15, 'off', 'eye') ;
%      	fprintf('Finished Outcome-Conditional Model Estimation round : hh=%1$u, hw=%2$u, cc=%3$u\n',hh,hw,cc)
%    end
%end

%   B.  Loop over points in the marginal distributions of male hours / 
%       consumption, given female hours index 6 (just above average female hours):
%hw = 6;
%for hh=1:1:fineness_param               % loop over conditioning male hours
%    for cc=1:1:fineness_param           % loop over conditioning consumption
%    
%        %   Read residuals:
%       	[mCouple_distr, mInd_distr, mEs_distr, mPi_distr, mErr_distr, ~, ~, ~]  ...
%            = handleData(strcat('_Distribution/PSID_hh',string(hh),'_hw',string(hw),'_cc',string(cc),'.csv'), ...
%                         strcat('_Distribution/PSID_me_hh',string(hh),'_hw',string(hw),'_cc',string(cc),'.csv'),[],[]) ;
%             
%    	%   Run estimation & collect results:
%    	[distr_estimates(:,hh,hw,cc), distr_fvals(1,hh,hw,cc), distr_flags(1,hh,hw,cc)] ...
%            = estm_model(vWageHat, mCouple_distr, mInd_distr, mEs_distr, mPi_distr, mErr_distr, [], ...
%                                'notify-detailed', 1, 7, 3, 0.15, 'off', 'eye') ;
%      	fprintf('Finished Outcome-Conditional Model Estimation round : hh=%1$u, hw=%2$u, cc=%3$u\n',hh,hw,cc)
%    end
%end

%   C.  Loop over points in the marginal distributions of female hours / 
%       consumption, given male hours index 6 (just above average male hours):
hh = 6;
for hw=1:1:fineness_param               % loop over conditioning female hours
    for cc=1:1:fineness_param           % loop over conditioning consumption
    
        %   Read residuals:
       	[mCouple_distr, mInd_distr, mEs_distr, mPi_distr, mErr_distr, ~, ~, ~]  ...
            = handleData(strcat('_Distribution/PSID_hh',string(hh),'_hw',string(hw),'_cc',string(cc),'.csv'), ...
                         strcat('_Distribution/PSID_me_hh',string(hh),'_hw',string(hw),'_cc',string(cc),'.csv'),[],[]) ;
             
    	%   Run estimation & collect results:
    	[distr_estimates(:,hh,hw,cc), distr_fvals(1,hh,hw,cc), distr_flags(1,hh,hw,cc)] ...
            = estm_model(vWageHat, mCouple_distr, mInd_distr, mEs_distr, mPi_distr, mErr_distr, [], ...
                                'notify-detailed', 1, 7, 3, 0.15, 'off', 'eye') ;
      	fprintf('Finished Outcome-Conditional Model Estimation round : hh=%1$u, hw=%2$u, cc=%3$u\n',hh,hw,cc)
    end
end


%%  3.  VISUALIZE ESTIMATES AGAINST VALUES OF OUTCOMES (FIGIRE 1)
%   Plot surface figure per parameter with value of estimate against the
%   corresponding values of tuples of outcomes.
%   -----------------------------------------------------------------------

%   Initialize parameters:
figtitles = {'\eta_{c,w1}','\eta_{c,w2}','\eta_{h1,w1}','\eta_{h2,w2}', ...
             'Var(\eta_{c,w1})','Var(\eta_{c,w2})','Var(\eta_{h1,w1})','Var(\eta_{h2,w2})', ...
             'Cov(\eta_{c,w1},\eta_{c,w2})','Cov(\eta_{c,w1},\eta_{h1,w1})','Cov(\eta_{c,w1},\eta_{h2,w2})', ...
             'Cov(\eta_{c,w2},\eta_{h1,w1})','Cov(\eta_{c,w2},\eta_{h2,w2})','Cov(\eta_{h1,w1},\eta_{h2,w2})'} ;
fignames  = {'eta_c_w1','eta_c_w2','eta_h1_w1','eta_h2_w2','Vc_w1','Vc_w2','Vh1_w1','Vh2_w2', ...
             'Cc_w1_c_w2','Cc_w1_h1_w1','Cc_w1_h2_w2','Cc_w2_h1_w1','Cc_w2_h2_w2','Ch1_w1_h2_w2'} ;

%   A. Loop over outcome-specific parameters at consumption mean:
%for param = 1:1:(length(vModelHat_c1.PREF)-7)
%
%    %   Produce figure:
%    figure;
%    %   -obtain parameter-specific matrix at consumption mean:
%    Z = reshape(distr_estimates(param,:,:,ceil((fineness_param+1)/2)),fineness_param,fineness_param);
%    h = surf(Z);
%    %   -axis:
%    ax = gca;
%    if      param==1 || param==2
%        ax.ZLim = [-0.3 0.3];
%    elseif  param==3 || param==4
%        ax.ZLim = [-0.6 1.0];
%    elseif  param==5 || param==6
%        ax.ZLim = [0.0 0.9];
%    elseif  param==7 || param==8
%        ax.ZLim = [0.0 1.5];
%    else
%        ax.ZLim = [-0.4 0.6];
%    end
%    ax.FontSize = 16;
%    ax.XTick = [1:1:(fineness_param/2) (fineness_param+1)/2 (fineness_param/2+1):1:fineness_param] ;
%    ax.YTick = [1:1:(fineness_param/2) (fineness_param+1)/2 (fineness_param/2+1):1:fineness_param] ;
%    ax.XTickLabel = ["" "-1.2\sigma" "" "" "" "mean" "" "" "" "1.2\sigma" "" ];
%    ax.YTickLabel = ["" "-1.2\sigma" "" "" "" "mean" "" "" "" "1.2\sigma" "" ];
%    xlabel('male hours');
%    ylabel('female hours')
%    zlabel(figtitles(param));
%    %   -marker for baseline parameter estimate:
%    hold on
%    g = plot3(5.5,5.5,vModelHat_c1.PREF(param),'r*') ;
%    g.MarkerSize = 20;
%
%    %   Save figure and close:
%    fig=gcf;
%    set(fig,'PaperOrientation','landscape');
%    print(fig,strcat(dDir,'/figures/figure_1_/',num2str(param),'.pdf'),'-dpdf','-bestfit') ;
%    close all
%end

%   B. Loop over outcome-specific parameters at female hour mean:
%for param = 1:1:(length(vModelHat_c1.PREF)-7)
%
%    %   Produce figure:
%    figure;
%    %   -obtain parameter-specific matrix at female hour mean:
%    Z = reshape(distr_estimates(param,:,ceil((fineness_param+1)/2),:),fineness_param,fineness_param);
%    h = surf(Z);
%    %   -axis:
%    ax = gca;
%    if      param==1 || param==2
%        ax.ZLim = [-0.3 0.3];
%    elseif  param==3 || param==4
%        ax.ZLim = [-0.6 1.0];
%    elseif  param==5 || param==6
%        ax.ZLim = [0.0 0.9];
%    elseif  param==7 || param==8
%        ax.ZLim = [0.0 1.5];
%    else
%        ax.ZLim = [-0.4 0.6];
%    end
%    ax.FontSize = 16;
%    ax.XTick = [1:1:(fineness_param/2) (fineness_param+1)/2 (fineness_param/2+1):1:fineness_param] ;
%    ax.YTick = [1:1:(fineness_param/2) (fineness_param+1)/2 (fineness_param/2+1):1:fineness_param] ;
%    ax.XTickLabel = ["" "-1.2\sigma" "" "" "" "mean" "" "" "" "1.2\sigma" "" ];
%    ax.YTickLabel = ["" "-1.2\sigma" "" "" "" "mean" "" "" "" "1.2\sigma" "" ];
%    xlabel('male hours');
%    ylabel('consumption')
%    zlabel(figtitles(param));
%    %   -marker for baseline parameter estimate:
%    hold on
%    g = plot3(5.5,5.5,vModelHat_c1.PREF(param),'r*') ;
%    g.MarkerSize = 20;
%
%    %   Save figure and close:
%    fig=gcf;
%    set(fig,'PaperOrientation','landscape');
%    print(fig,strcat(dDir,'/figures/figure_1_/',num2str(param),'.pdf'),'-dpdf','-bestfit') ;
%    close all
%end

%   C. Loop over outcome-specific parameters at male hour mean:
for param = 1:1:(length(vModelHat_c1.PREF)-7)

    %   Produce figure:
    figure;
    %   -obtain parameter-specific matrix at female hour mean:
    Z = reshape(distr_estimates(param,ceil((fineness_param+1)/2),:,:),fineness_param,fineness_param);
    h = surf(Z);
    %   -axis:
    ax = gca;
    if      param==1 || param==2
        ax.ZLim = [-0.3 0.3];
    elseif  param==3 || param==4
        ax.ZLim = [-0.6 1.0];
    elseif  param==5 || param==6
        ax.ZLim = [0.0 0.9];
    elseif  param==7 || param==8
        ax.ZLim = [0.0 1.5];
    else
        ax.ZLim = [-0.4 0.6];
    end
    ax.FontSize = 32;
    ax.XTick = [1:1:(fineness_param/2) (fineness_param+1)/2 (fineness_param/2+1):1:fineness_param] ;
    ax.YTick = [1:1:(fineness_param/2) (fineness_param+1)/2 (fineness_param/2+1):1:fineness_param] ;
    ax.XTickLabel = ["" "-1.2\sigma" "" "" "" "mean" "" "" "" "1.2\sigma" "" ];
    ax.YTickLabel = ["" "-1.2\sigma" "" "" "" "mean" "" "" "" "1.2\sigma" "" ];
    xlabel('H2');
    ylabel('Cons.')
    %   -marker for baseline parameter estimate:
    hold on
    g = plot3(5.5,5.5,vModelHat_c1.PREF(param),'r*') ;
    g.MarkerSize = 20;

    %   Save figure and close:
    fig=gcf;
    set(fig,'PaperOrientation','landscape');
    print(fig,strcat(dDir,'/figures/figure_1_',num2str(param),'.pdf'),'-dpdf','-bestfit') ;
    close all
end

%   Clear workspace:
clearvars X Y Z hh hw cc param figtitles fignames g h ax fig fineness_param