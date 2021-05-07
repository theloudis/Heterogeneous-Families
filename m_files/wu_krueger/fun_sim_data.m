function sdata = fun_sim_data(data, par, ind)

%{ 
    This function arranges the simulated data into appropriate arrays. It
    also calculates the wealth shares/partial insurance parameters.

    This code is an adaptation to the original code provided by 
    Wu & Krueger (2020), 'Consumption Insurance Against Wage Risk',
    published in AEJ-Macro.

    Alexandros Theloudis
    -----------------------------------------------------------------------
%}
    
    %   Choose applicable age range:
    if      ind.age_range==0 % for comparison with Wu & Krueger's results
        age_start  = 10 ;
        age_end    = 37 ;
    elseif  ind.age_range==1 % for comparison with age range in my baseline results
        age_start  = 10 ;
        age_end    = 40 ;
    end
    
    
    %%  A.  AGE-RANGE OF DATA
    %   -------------------------------------------------------------------
    
    %   Prepare simulated dataset:
    %   -length of time series:
    sT     = age_end - age_start + 1 ;
    %   -hours:
    H1     = data.sim_H1(:,age_start:age_end);
    H2     = data.sim_H2(:,age_start:age_end);
    %   -earnings:
    Y1     = data.sim_Y1(:,age_start:age_end);
    Y2     = data.sim_Y2(:,age_start:age_end);
    Y      = Y1 + Y2 ;
    Y2(Y2==0) = NaN ;
    %   -consumption and assets:
    C      = data.sim_C(:,age_start:age_end);
    A      = data.sim_A(:,age_start:age_end);
    %   -hourly wages:
    W1     = Y1./H1;
    W2     = Y2./H2;
    %   -permanent wage shocks:
    v1     = data.sim_v1(:,age_start:age_end) ; 
    v2     = data.sim_v2(:,age_start:age_end) ;
    %   -transitory wage shocks:
    u1     = data.sim_u1(:,age_start:age_end) ; 
    u2     = data.sim_u2(:,age_start:age_end) ;
    
    
    %%  B.  WEALTH SHARE COEFFICIENTS AND OUTCOME RATIOS
    %   -------------------------------------------------------------------
    
    %   Initialize matrices to hold human wealth data: 
    temp_HWAT   = NaN(par.sim_N,sT);
    temp_HW1    = NaN(par.sim_N,sT);
    temp_HW2    = NaN(par.sim_N,sT);
    
    %   Generate expected earnings at each age, for each spouse separately
    %   and for the household as a whole:
    temp_YAT    = (1-par.chi)*(data.sim_Y1+data.sim_Y2).^(1-par.mu) ;
    temp_eYAT   = mean(temp_YAT,1);
    temp_eY1    = mean(data.sim_Y1,1);
    temp_eY2    = mean(data.sim_Y2,1);
    
    %   Sum up discounted expected future earnings at each age:
    for j=age_start:age_end
        if j<par.R
            temp_HW1(:,j-age_start+1)  = data.sim_Y1(:,j)       + sum(temp_eY1(j+1:par.R).*(1+par.r).^(-1:-1:j-par.R),2);
            temp_HW2(:,j-age_start+1)  = data.sim_Y2(:,j)       + sum(temp_eY2(j+1:par.R).*(1+par.r).^(-1:-1:j-par.R),2);
            temp_HWAT(:,j-age_start+1) = temp_YAT(:,j)          + sum(temp_eYAT(j+1:par.R).*(1+par.r).^(-1:-1:j-par.R),2);
        else
            temp_HW1(:,j-age_start+1)  = data.sim_Y1(:,j);
            temp_HW2(:,j-age_start+1)  = data.sim_Y2(:,j);
            temp_HWAT(:,j-age_start+1) = temp_YAT(:,j);
        end
    end
    
    %   Discounted financial wealth:
    temp_A = (1+par.r)*A ;
    
    %   Assemble partial insurance coefficients:
    pi          = temp_A./(temp_A + temp_HWAT);
    s           = temp_HW1./(temp_HW1+temp_HW2);
    q           = Y1./(Y1 + Y2);

    %   Assemble ratios of outcomes:
	ratio_yH_yW   = nanmean(Y1(:))/nanmean(Y2(:));
	ratio_yW_yH   = nanmean(Y2(:))/nanmean(Y1(:));
	ratio_c_yH 	  = nanmean(C(:))/nanmean(Y1(:));
	ratio_c_yW 	  = nanmean(C(:))/nanmean(Y2(:));
	sqratio_yH_yW = ratio_yH_yW^2 ;    
    ratios = [ratio_yH_yW ratio_yW_yH ratio_c_yH ratio_c_yW sqratio_yH_yW] ;
    
    
    %%  C.  GENERATE GROWTH RATES, PLACE DATA IN ARRAY
    %   -------------------------------------------------------------------
    
    %   Generate first difference in log consumption, earnings, and wage:
    dC  = diff(log(C),  1, 2) ;
    dY1 = diff(log(Y1), 1, 2);
    dY2 = diff(log(Y2), 1, 2);
    dW1 = diff(log(W1), 1, 2);
    dW2 = diff(log(W2), 1, 2);
    dY  = diff(log(Y),  1, 2) ;
  
    %   Place data in arrays:
    %   -original data:
    sdata           = data;
    %   -age range & sample_size:
    sdata.age_start = age_start ;
    sdata.age_end   = age_end ;
    sdata.sT        = sT;
    sdata.N         = par.sim_N ;
    %   -data in specified age range:
    sdata.A         = A;
    sdata.C         = C;
    sdata.H1        = H1;
    sdata.H2        = H2;
    sdata.Y1        = Y1;
    sdata.Y2        = Y2;
    sdata.Y         = Y;
    sdata.W1        = W1;
    sdata.W2        = W2;
    %   -growth rates:
    sdata.dC        = dC;
    sdata.dY1       = dY1;
    sdata.dY2       = dY2;
    sdata.dY        = dY;
    sdata.dW1       = dW1;
    sdata.dW2       = dW2;
    %   -wage shocks:
    sdata.v1        = v1;
    sdata.v2        = v2;
    sdata.u1        = u1;
    sdata.u2        = u2;
    %   -partial insurance parameters:
    sdata.pi        = pi;
    sdata.s         = s;
    sdata.q         = q;
    %   -ratios of outcomes:
    sdata.ratios    = ratios ;
    
    
    %%  D.  OBTAIN MODEL FRISCH ELASTICITIES
    %   Calculate model true Frisch elasticties.
    %   -------------------------------------------------------------------
    
    %   Obtain values of elasticties:
    [eta_cw1, eta_cw2, eta_h1w1, eta_h1w2, eta_h2w1, eta_h2w2, eta_h1p, eta_h2p, eta_cp] = ...
        fun_true_eta(sdata, par, ind.separable) ;
    
    %   Populate in arrays - one elasticity per observation:
    sdata.eta_cw1  = eta_cw1*ones(size(dC)) ;
    sdata.eta_cw2  = eta_cw2*ones(size(dC)) ;
    sdata.eta_h1w1 = eta_h1w1*ones(size(dC)) ;
    sdata.eta_h1w2 = eta_h1w2*ones(size(dC)) ;
    sdata.eta_h2w1 = eta_h2w1*ones(size(dC)) ;
    sdata.eta_h2w2 = eta_h2w2*ones(size(dC)) ;
    sdata.eta_h1p  = eta_h1p*ones(size(dC)) ;
    sdata.eta_h2p  = eta_h2p*ones(size(dC)) ;
    sdata.eta_cp   = eta_cp*ones(size(dC)) ;

end
%   -----------------------------------------------------------------------
function [eta_cw1,eta_cw2,eta_h1w1,eta_h1w2,eta_h2w1,eta_h2w2,eta_h1p,eta_h2p,eta_cp] = ... 
    fun_true_eta(sdata, par, ind_separable)
%{
    This function calculates the true Frisch elasticities depending on
    the model specification (separable/nonseparable). 
    
    For the non-separable specification, I calculate the Frisch 
    elasticities at the sample average of consumption and hours.

    This code is an adaptation to the original code provided by 
    Wu & Krueger (2020), 'Consumption Insurance Against Wage Risk',
    published in AEJ-Macro.

    Alexandros Theloudis
    -----------------------------------------------------------------------
%}

    %   Obtain model Frisch elasticties.
    if      ind_separable==1     %separable model
        
        eta_cw1  = 0; 
        eta_cw2  = 0; 
        eta_h1w1 = par.eta1; 
        eta_h1w2 = 0; 
        eta_h2w1 = 0; 
        eta_h2w2 = par.eta2; 
        eta_h1p  = 0; 
        eta_h2p  = 0; 
        eta_cp   = 1/par.sigma;                      
    
    elseif  ind_separable==0     %non-separable model
                
        %   Construct matrix of partial effects:
        GAMMA   = par.xi*(sdata.H1).^par.theta1 + (1-par.xi)*(sdata.H2).^par.theta2 ;
        DELTA   = par.alpha*(sdata.C).^par.gamma + (1-par.alpha)*GAMMA.^(-par.gamma/par.theta1) ;
        A       = par.alpha*(sdata.C).^par.gamma ./DELTA ;
        B       = par.xi*(sdata.H1).^par.theta1  ./GAMMA ;
        
        %   Populate matrix of partial effects:
        %   -first column:
        G(1,1) = nanmean(reshape((1-par.gamma-par.sigma)*A + (par.gamma-1),[],1)) ;
        G(2,1) = nanmean(reshape((1-par.gamma-par.sigma)*A,[],1)) ;
        G(3,1) = nanmean(reshape((1-par.gamma-par.sigma)*A,[],1)) ;
        %   -middle column:
        G(1,2) = nanmean(reshape((par.gamma+par.sigma-1)*(1-A).*B,[],1)) ;
        G(2,2) = nanmean(reshape(((par.gamma+par.sigma-1)*(1-A) - (par.gamma+par.theta1)).*B + (par.theta1-1),[],1)) ;
        G(3,2) = nanmean(reshape(((par.gamma+par.sigma-1)*(1-A) - (par.gamma+par.theta1)).*B,[],1)) ;
        %   -last column:
        G(1,3) = nanmean(reshape((par.gamma+par.sigma-1)*(par.theta2/par.theta1)*(1-A).*(1-B),[],1)) ;
        G(2,3) = nanmean(reshape(((par.gamma+par.sigma-1)*(par.theta2/par.theta1)*(1-A) - ((par.theta2/par.theta1)*par.gamma+par.theta2)).*(1-B),[],1)) ;
        G(3,3) = nanmean(reshape(((par.gamma+par.sigma-1)*(par.theta2/par.theta1)*(1-A) - ((par.theta2/par.theta1)*par.gamma+par.theta2)).*(1-B) + (par.theta2-1),[],1)) ;

        %   Invert matrix:
        model_eta = G^(-1);
        %   -change sign of consumption substitution elasticity:
        model_eta(1,1) = -model_eta(1,1);
        %   -deliver in appropriate format:
        eta_cw1  = model_eta(1,2); 
        eta_cw2  = model_eta(1,3); 
        eta_h1w1 = model_eta(2,2); 
        eta_h1w2 = model_eta(2,3);
        eta_h2w1 = model_eta(3,2); 
        eta_h2w2 = model_eta(3,3);
        eta_h1p  = model_eta(2,1); 
        eta_h2p  = model_eta(3,1); 
        eta_cp   = model_eta(1,1); 
    end
end