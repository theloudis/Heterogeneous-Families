function [pool_data, sim_results] = fun_estimate_parameters(sim_arrays, information)
%{ 
    This function obtains the true parameters of the model as well as
    parameters estimates using my baseline estimation method.

    Alexandros Theloudis
    -----------------------------------------------------------------------
%}

    %   Obtain number of simulated populations:
    num_pops = length(sim_arrays) ;
    
    
    %%  A.  Retrieve data from first simulated population; 
    %       obtain simulated moments in homogeneous population
    %   -------------------------------------------------------------------
    
    %   Retrieve data:
    pool_data.C             = sim_arrays{1,1}.C ;
    pool_data.H1            = sim_arrays{1,1}.H1 ;
    pool_data.H2            = sim_arrays{1,1}.H2 ;
    pool_data.dC            = sim_arrays{1,1}.dC;
    pool_data.dY1           = sim_arrays{1,1}.dY1;
    pool_data.dY2           = sim_arrays{1,1}.dY2;
    pool_data.dW1           = sim_arrays{1,1}.dW1;
    pool_data.dW2           = sim_arrays{1,1}.dW2;
    pool_data.v1            = sim_arrays{1,1}.v1;
    pool_data.v2            = sim_arrays{1,1}.v2;
    pool_data.u1            = sim_arrays{1,1}.u1;
    pool_data.u2            = sim_arrays{1,1}.u2;
    pool_data.pi            = sim_arrays{1,1}.pi;
    pool_data.s             = sim_arrays{1,1}.s;
    pool_data.q             = sim_arrays{1,1}.q;
    pool_data.ratios        = sim_arrays{1,1}.ratios;
    pool_data.eta_cw1       = sim_arrays{1,1}.eta_cw1;
    pool_data.eta_cw2       = sim_arrays{1,1}.eta_cw2;
    pool_data.eta_h1w1      = sim_arrays{1,1}.eta_h1w1;
    pool_data.eta_h1w2      = sim_arrays{1,1}.eta_h1w2;
    pool_data.eta_h2w1      = sim_arrays{1,1}.eta_h2w1;
    pool_data.eta_h2w2      = sim_arrays{1,1}.eta_h2w2;
    pool_data.eta_h1p       = sim_arrays{1,1}.eta_h1p;
    pool_data.eta_h2p       = sim_arrays{1,1}.eta_h2p;
    pool_data.eta_cp        = sim_arrays{1,1}.eta_cp;
    
    %   Obtain length of simulated time series, size of first population,
    %   start and end of lifecycle:
    pool_data.sT            = sim_arrays{1,1}.sT ;
    pool_data.simul_size    = sim_arrays{1,1}.N ;
    pool_data.age_start     = sim_arrays{1,1}.age_start ;
    pool_data.age_end       = sim_arrays{1,1}.age_end ;
    
    %   Length of estimation moments:
    sim_T = pool_data.sT - 2 ;
    
    
    %%  B.  Append data from other simulated population; 
    %       obtain simulated moments in entire population
    %   -------------------------------------------------------------------
    
    %   Append data:
    if num_pops>1
        for i=2:num_pops
            pool_data.C         = vertcat(pool_data.C,          sim_arrays{1,i}.C) ;
            pool_data.H1        = vertcat(pool_data.H1,         sim_arrays{1,i}.H1) ;
            pool_data.H2        = vertcat(pool_data.H2,         sim_arrays{1,i}.H2) ;
            pool_data.dC        = vertcat(pool_data.dC,         sim_arrays{1,i}.dC);
            pool_data.dY1       = vertcat(pool_data.dY1,        sim_arrays{1,i}.dY1);
            pool_data.dY2       = vertcat(pool_data.dY2,        sim_arrays{1,i}.dY2);
            pool_data.dW1       = vertcat(pool_data.dW1,        sim_arrays{1,i}.dW1);
            pool_data.dW2       = vertcat(pool_data.dW2,        sim_arrays{1,i}.dW2);
            pool_data.v1        = vertcat(pool_data.v1,         sim_arrays{1,i}.v1);
            pool_data.v2        = vertcat(pool_data.v2,         sim_arrays{1,i}.v2);
            pool_data.u1        = vertcat(pool_data.u1,         sim_arrays{1,i}.u1);
            pool_data.u2        = vertcat(pool_data.u2,         sim_arrays{1,i}.u2);
            pool_data.pi        = vertcat(pool_data.pi,         sim_arrays{1,i}.pi);
            pool_data.s         = vertcat(pool_data.s,          sim_arrays{1,i}.s);
            pool_data.q         = vertcat(pool_data.q,          sim_arrays{1,i}.q);
            pool_data.ratios    = vertcat(pool_data.ratios,     sim_arrays{1,i}.ratios) ; 
            pool_data.eta_cw1   = vertcat(pool_data.eta_cw1,    sim_arrays{1,i}.eta_cw1);
            pool_data.eta_cw2   = vertcat(pool_data.eta_cw2,    sim_arrays{1,i}.eta_cw2);
            pool_data.eta_h1w1  = vertcat(pool_data.eta_h1w1,   sim_arrays{1,i}.eta_h1w1);
            pool_data.eta_h1w2  = vertcat(pool_data.eta_h1w2,   sim_arrays{1,i}.eta_h1w2);
            pool_data.eta_h2w1  = vertcat(pool_data.eta_h2w1,   sim_arrays{1,i}.eta_h2w1);
            pool_data.eta_h2w2  = vertcat(pool_data.eta_h2w2,   sim_arrays{1,i}.eta_h2w2);
            pool_data.eta_h1p   = vertcat(pool_data.eta_h1p,    sim_arrays{1,i}.eta_h1p);
            pool_data.eta_h2p   = vertcat(pool_data.eta_h2p,    sim_arrays{1,i}.eta_h2p);
            pool_data.eta_cp    = vertcat(pool_data.eta_cp,     sim_arrays{1,i}.eta_cp);
        end %for i=2:num_pops
    end %num_pops>1

    %   Update size of population:
    pool_data.simul_size = sim_arrays{1,1}.N ;
    if num_pops>1
        for i=2:num_pops
            pool_data.simul_size = pool_data.simul_size + sim_arrays{1,i}.N ;
        end %for i=2:num_pops
    end %num_pops>1

    %   Carry out first stage regression in entire population:
    [pool_data.res, gmm_data] = fun_first_stage(pool_data) ;
    
    %   Convert simulated data to format that can be read by baseline 
    %   estimation routines; obtain empirical moments:
    [sCouple, sInd, sEs, sPi, sErr, sAvg]   = handleData_wk(gmm_data, pool_data, sim_T) ;
    [sim_MATCHED, sim_BPS]                  = fit_empirical_model_wk(sCouple, sInd, sErr, sim_T) ;
    
    
    %%  C.  Obtain true parameters in entire population
    %   -------------------------------------------------------------------
    
    %   Obtain true moments of Frisch elasticities and wage shocks:
    sim_results             = fun_true_parameters(pool_data) ;
    %   -sample size, and effective length of panel:
    sim_results.N           = pool_data.simul_size;
    sim_results.T           = sim_T ;
    %   -simulated moments:
    sim_results.sim_MATCHED = sim_MATCHED ;
    sim_results.sim_BPS     = sim_BPS ;
    
    
	%%  D.  Estimate parameters using baseline estimation routine
    %   -------------------------------------------------------------------
    
    %   Carry out baseline estimation of parameters of wage process:
    [sim_vWageHat,~,~]          = estm_wages_wk(sim_MATCHED, information) ;
    
    %   Carry out baseline estimation of Frisch elasticities:
    %   -BPS
    [sim_vModelHat_BPS,~,~]     = estm_model_wk(sim_vWageHat, sim_MATCHED, sim_BPS, sim_results.true_eta_cp, sEs, sPi, sAvg, information, -1) ;
    %   -TRANS
    [sim_vModelHat_TRANS,~,~]   = estm_model_wk(sim_vWageHat, sim_MATCHED, sim_BPS, sim_results.true_eta_cp, sEs, sPi, sAvg, information,  0) ;
    
    %   Place estimates into structure:
    sim_results.sim_vWageHat            = sim_vWageHat;
    sim_results.sim_vModelHat_BPS       = sim_vModelHat_BPS;
    sim_results.sim_vModelHat_TRANS     = sim_vModelHat_TRANS;
    
end

%   -----------------------------------------------------------------------

function model_params = fun_true_parameters(pdata)
%{ 
    This function calculates the moments of the true Frisch elasticities 
    and the moments of permanent and transitory wage shocks. 

    This code is an adaptation to the original code provided by 
    Wu & Krueger (2020), 'Consumption Insurance Against Wage Risk',
    published in AEJ-Macro.

   (C) Alexandros Theloudis, LISER & UCL, 2016-20
    -----------------------------------------------------------------------
%}

    %   A. Frisch elasticties:
    %   ----------------------
    
    %   Average elasticties:
    avg_Frisch = [  nanmean(pdata.eta_cw1(:));
                    nanmean(pdata.eta_cw2(:));
                    nanmean(pdata.eta_h1w1(:));
                    nanmean(pdata.eta_h1w2(:));
                    nanmean(pdata.eta_h2w1(:));
                    nanmean(pdata.eta_h2w2(:))];
    
    %   Variance of elasticties:
    var_Frisch = [  nanmean(pdata.eta_cw1(:).^2) - nanmean(pdata.eta_cw1(:))^2;
                    nanmean(pdata.eta_cw2(:).^2) - nanmean(pdata.eta_cw2(:))^2;
                    nanmean(pdata.eta_h1w1(:).^2) - nanmean(pdata.eta_h1w1(:))^2;
                    nanmean(pdata.eta_h1w2(:).^2) - nanmean(pdata.eta_h1w2(:))^2;
                    nanmean(pdata.eta_h2w1(:).^2) - nanmean(pdata.eta_h2w1(:))^2;
                    nanmean(pdata.eta_h2w2(:).^2) - nanmean(pdata.eta_h2w2(:))^2];            
                
    %   Place together:
    model_params.true_eta_cp = nanmean(pdata.eta_cp(:));
    model_params.true_Frisch = [avg_Frisch;var_Frisch] ;
    
    
    %   B. Covariance matrix of shocks:
    %   -------------------------------
    
    %   Variance of male shocks:    
    var_v1 = nanmean((pdata.v1(:) - nanmean(pdata.v1(:))).^2) ;
    var_u1 = nanmean((pdata.u1(:) - nanmean(pdata.u1(:))).^2) ;
    
    %   Variance of female shocks:    
    var_v2 = nanmean((pdata.v2(:) - nanmean(pdata.v2(:))).^2) ;
    var_u2 = nanmean((pdata.u2(:) - nanmean(pdata.u2(:))).^2) ;
    
    %   Covariance of shocks:
    cov_v = nanmean((pdata.v1(:) - nanmean(pdata.v1(:))).*(pdata.v2(:) - nanmean(pdata.v2(:)))) ;
    cov_u = nanmean((pdata.u1(:) - nanmean(pdata.u1(:))).*(pdata.u2(:) - nanmean(pdata.u2(:)))) ;
    
    %   Place in structure:
    model_params.true_covarv = [var_v1 ; var_v2 ; cov_v] ;
    model_params.true_covaru = [var_u1 ; var_u2 ; cov_u] ;
end