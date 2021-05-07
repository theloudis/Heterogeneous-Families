function [residuals, gmm_data] = fun_first_stage(pooldata)

%{ 
    This function implements the first stage regressions of consumption,
    earnings, and wages. 

    This code is an adaptation to the original code provided by 
    Wu & Krueger (2020), 'Consumption Insurance Against Wage Risk',
    published in AEJ-Macro.

    Alexandros Theloudis
    -----------------------------------------------------------------------
%}
    
    %   Length of time series and number of households:
    sT          = pooldata.sT ;
    simul_size  = pooldata.simul_size ;
    
    %   Generate first-stage regressors (age dummies):
    regressors  = kron(eye(sT-1), ones(simul_size,1));
    
    
    %%  A.  CARRY OUT FIRST-STAGE REGRESSIONS
    %   -------------------------------------------------------------------
    
    %   Regress wages on age dummies; regress outcomes on age dummies
    %   past levels of consumption and hours: 
    %   -log consumption growth:
    [~,~,temp_reg_r] = regress(reshape(pooldata.dC,     simul_size*(sT-1),  1), regressors);
    dc  = reshape(temp_reg_r, simul_size, sT-1);
    %   -log earnings growth:
    [~,~,temp_reg_r] = regress(reshape(pooldata.dY1,    simul_size*(sT-1),  1), regressors);
    dy1 = reshape(temp_reg_r, simul_size, sT-1);
    [~,~,temp_reg_r] = regress(reshape(pooldata.dY2,    simul_size*(sT-1),  1), regressors);
    dy2 = reshape(temp_reg_r, simul_size, sT-1);
    %   -log wage growth:
    [~,~,temp_reg_r] = regress(reshape(pooldata.dW1,    simul_size*(sT-1),  1), regressors);
    dw1 = reshape(temp_reg_r, simul_size, sT-1);
    [~,~,temp_reg_r] = regress(reshape(pooldata.dW2,    simul_size*(sT-1),  1), regressors);
    dw2 = reshape(temp_reg_r, simul_size, sT-1);
    
    %   Residual growth rates:
    residuals.dc    = dc;
    residuals.dy1 	= dy1;
    residuals.dy2  	= dy2;
    residuals.dw1  	= dw1;
    residuals.dw2 	= dw2;
    
    
    %%  B.  PREPARE DATA FOR FORMAT APPROPROATE FOR GMM ESTIMATION
    %   -------------------------------------------------------------------
    
    %   Generate household id and age in simulated population; given the
    %   products between current and past/future growth rates, the panel 
    %   which will be estimated has length sT-2.
    sim_hh_id   = kron((1:1:simul_size)',ones(sT-2,1)) ;
    sim_year    = repmat(((pooldata.age_start+1):(pooldata.age_end-1))',[simul_size,1]) ;
 
    %   Recast residual names into names consistent with Stata:
    %   -residuals are 'sim_N x (sT-1)'
    drwH        = dw1 ;
    drwW        = dw2 ;
    dreH        = dy1 ;
    dreW        = dy2 ;
    drcons      = dc ;
       
    %	Generate squared residuals:
    %   -squared residuals are 'sim_N x (sT-1)'
	drwH2 		= drwH.^2  ;
	drwW2 		= drwW.^2  ;
	dreH2 		= dreH.^2  ;
	dreW2 		= dreW.^2  ;
	drcons2  	= drcons.^2 ;
    
    % 	Generate forward lead of residuals & squared residuals:
    %   -forward leads are 'sim_N x (sT-2)'
	F2.drwH     = drwH(:,2:end)    ;
	F2.drwH2    = drwH2(:,2:end)   ;
	F2.drwW     = drwW(:,2:end)    ;
	F2.drwW2    = drwW2(:,2:end)   ;
	F2.dreH     = dreH(:,2:end)    ;
	F2.dreH2    = dreH2(:,2:end)   ;
	F2.dreW     = dreW(:,2:end)    ;
	F2.dreW2    = dreW2(:,2:end)   ;
	F2.drcons   = drcons(:,2:end)  ;
	F2.drcons2  = drcons2(:,2:end) ;
    
    %   Obtain part of residual matrices that will be cell-wise multiplied
    %   with forward leads:
    %   -residuals are now 'sim_N x (sT-2)'
    drwH        = drwH(:,1:(end-1))     ;
    drwH2       = drwH2(:,1:(end-1))    ;
    drwW        = drwW(:,1:(end-1))     ;
    drwW2       = drwW2(:,1:(end-1))    ;
    dreH        = dreH(:,1:(end-1))     ;
    dreH2       = dreH2(:,1:(end-1))    ;
    dreW        = dreW(:,1:(end-1))     ;
    dreW2       = dreW2(:,1:(end-1))    ;
    drcons      = drcons(:,1:(end-1))   ;
    drcons2     = drcons2(:,1:(end-1))  ;

    %	Generate earnings and consumption moments matched in the structural 
    %   estimation. All moment matrices are "sim_N x (sT-2)" and they are
    %   appropriately vectorized. Generate indicators for missing values.
	%	-targeted earnings moments:
    %   1
	drwH_FdreH    	 	= drwH.*F2.dreH ;
    drwH_FdreH          = reshape(drwH_FdreH',simul_size*(sT-2),1) ;
    i_drwH_FdreH        = ones(size(drwH_FdreH)) ;
    i_drwH_FdreH(isnan(drwH_FdreH)==1)      = 0 ;
    drwH_FdreH(i_drwH_FdreH==0)             = 0 ;
	%   2
    FdrwH_dreH    	 	= F2.drwH.*dreH ;
    FdrwH_dreH          = reshape(FdrwH_dreH',simul_size*(sT-2),1) ;
    i_FdrwH_dreH        = ones(size(FdrwH_dreH)) ;
    i_FdrwH_dreH(isnan(FdrwH_dreH)==1)      = 0 ;
    FdrwH_dreH(i_FdrwH_dreH==0)             = 0 ;
    %   3
	drwW_FdreH    	 	= drwW.*F2.dreH ;		
    drwW_FdreH          = reshape(drwW_FdreH',simul_size*(sT-2),1) ;
	i_drwW_FdreH        = ones(size(drwW_FdreH)) ;
    i_drwW_FdreH(isnan(drwW_FdreH)==1)      = 0 ;
    drwW_FdreH(i_drwW_FdreH==0)             = 0 ;
    %   4
    FdrwW_dreH    	 	= F2.drwW.*dreH ;
    FdrwW_dreH = reshape(FdrwW_dreH',simul_size*(sT-2),1) ;
	i_FdrwW_dreH        = ones(size(FdrwW_dreH)) ;
    i_FdrwW_dreH(isnan(FdrwW_dreH)==1)      = 0 ;
    FdrwW_dreH(i_FdrwW_dreH==0)             = 0 ;
    %   5
    drwH_FdreW    	 	= drwH.*F2.dreW ;
    drwH_FdreW          = reshape(drwH_FdreW',simul_size*(sT-2),1) ;
	i_drwH_FdreW        = ones(size(drwH_FdreW)) ;
    i_drwH_FdreW(isnan(drwH_FdreW)==1)      = 0 ;
    drwH_FdreW(i_drwH_FdreW==0)             = 0 ;
    %   6
    FdrwH_dreW    	 	= F2.drwH.*dreW ;	
    FdrwH_dreW          = reshape(FdrwH_dreW',simul_size*(sT-2),1) ;
	i_FdrwH_dreW        = ones(size(FdrwH_dreW)) ;
    i_FdrwH_dreW(isnan(FdrwH_dreW)==1)      = 0 ;
    FdrwH_dreW(i_FdrwH_dreW==0)             = 0 ;
    %   7
    drwW_FdreW    	 	= drwW.*F2.dreW ;
    drwW_FdreW          = reshape(drwW_FdreW',simul_size*(sT-2),1) ;
	i_drwW_FdreW        = ones(size(drwW_FdreW)) ;
    i_drwW_FdreW(isnan(drwW_FdreW)==1)      = 0 ;
    drwW_FdreW(i_drwW_FdreW==0)             = 0 ;
    %   8
    FdrwW_dreW    	 	= F2.drwW.*dreW ;
    FdrwW_dreW          = reshape(FdrwW_dreW',simul_size*(sT-2),1) ;
	i_FdrwW_dreW        = ones(size(FdrwW_dreW)) ;
    i_FdrwW_dreW(isnan(FdrwW_dreW)==1)      = 0 ;
    FdrwW_dreW(i_FdrwW_dreW==0)             = 0 ;
    %   9
    dreH_FdreH    	 	= dreH.*F2.dreH ;
    dreH_FdreH          = reshape(dreH_FdreH',simul_size*(sT-2),1) ;
	i_dreH_FdreH        = ones(size(dreH_FdreH)) ;
    i_dreH_FdreH(isnan(dreH_FdreH)==1)      = 0 ;
    dreH_FdreH(i_dreH_FdreH==0)             = 0 ;
    %   10
    dreH_FdreW    	 	= dreH.*F2.dreW ;
    dreH_FdreW          = reshape(dreH_FdreW',simul_size*(sT-2),1) ;
	i_dreH_FdreW        = ones(size(dreH_FdreW)) ;
    i_dreH_FdreW(isnan(dreH_FdreW)==1)      = 0 ;
    dreH_FdreW(i_dreH_FdreW==0)             = 0 ;
    %   11
    FdreH_dreW    	 	= F2.dreH.*dreW ;
    FdreH_dreW          = reshape(FdreH_dreW',simul_size*(sT-2),1) ;
	i_FdreH_dreW        = ones(size(FdreH_dreW)) ;
    i_FdreH_dreW(isnan(FdreH_dreW)==1)      = 0 ;
    FdreH_dreW(i_FdreH_dreW==0)             = 0 ;
    %   12
    dreW_FdreW    	 	= dreW.*F2.dreW ;
    dreW_FdreW          = reshape(dreW_FdreW',simul_size*(sT-2),1) ;
	i_dreW_FdreW        = ones(size(dreW_FdreW)) ;
    i_dreW_FdreW(isnan(dreW_FdreW)==1)      = 0 ;
    dreW_FdreW(i_dreW_FdreW==0)             = 0 ;
    %   13
    drwH2_FdreH   	 	= drwH2.*F2.dreH ; 
    drwH2_FdreH         = reshape(drwH2_FdreH',simul_size*(sT-2),1) ;
	i_drwH2_FdreH       = ones(size(drwH2_FdreH)) ;
    i_drwH2_FdreH(isnan(drwH2_FdreH)==1)    = 0 ;
    drwH2_FdreH(i_drwH2_FdreH==0)           = 0 ;
    %   14
    FdrwH2_dreH   	 	= F2.drwH2.*dreH ;
    FdrwH2_dreH         = reshape(FdrwH2_dreH',simul_size*(sT-2),1) ;
	i_FdrwH2_dreH       = ones(size(FdrwH2_dreH)) ;
    i_FdrwH2_dreH(isnan(FdrwH2_dreH)==1)    = 0 ;
    FdrwH2_dreH(i_FdrwH2_dreH==0)           = 0 ;
    %   15
    drwW2_FdreH   	 	= drwW2.*F2.dreH ; 
    drwW2_FdreH         = reshape(drwW2_FdreH',simul_size*(sT-2),1) ;
	i_drwW2_FdreH       = ones(size(drwW2_FdreH)) ;
    i_drwW2_FdreH(isnan(drwW2_FdreH)==1)    = 0 ;
    drwW2_FdreH(i_drwW2_FdreH==0)           = 0 ;
    %   16
    FdrwW2_dreH   	 	= F2.drwW2.*dreH ; 
    FdrwW2_dreH         = reshape(FdrwW2_dreH',simul_size*(sT-2),1) ;
	i_FdrwW2_dreH       = ones(size(FdrwW2_dreH)) ;
    i_FdrwW2_dreH(isnan(FdrwW2_dreH)==1)    = 0 ;
    FdrwW2_dreH(i_FdrwW2_dreH==0)           = 0 ;
    %   17
    drwH2_FdreW   	 	= drwH2.*F2.dreW ; 
    drwH2_FdreW         = reshape(drwH2_FdreW',simul_size*(sT-2),1) ;
	i_drwH2_FdreW       = ones(size(drwH2_FdreW)) ;
    i_drwH2_FdreW(isnan(drwH2_FdreW)==1)    = 0 ;
    drwH2_FdreW(i_drwH2_FdreW==0)           = 0 ;
    %   18
    FdrwH2_dreW   	 	= F2.drwH2.*dreW ;
    FdrwH2_dreW         = reshape(FdrwH2_dreW',simul_size*(sT-2),1) ;
	i_FdrwH2_dreW       = ones(size(FdrwH2_dreW)) ;
    i_FdrwH2_dreW(isnan(FdrwH2_dreW)==1)    = 0 ;
    FdrwH2_dreW(i_FdrwH2_dreW==0)           = 0 ;
    %   19
    drwW2_FdreW   	 	= drwW2.*F2.dreW ; 
    drwW2_FdreW         = reshape(drwW2_FdreW',simul_size*(sT-2),1) ;
	i_drwW2_FdreW       = ones(size(drwW2_FdreW)) ;
    i_drwW2_FdreW(isnan(drwW2_FdreW)==1)    = 0 ;
    drwW2_FdreW(i_drwW2_FdreW==0)           = 0 ;
    %   20
    FdrwW2_dreW   	 	= F2.drwW2.*dreW ;
    FdrwW2_dreW         = reshape(FdrwW2_dreW',simul_size*(sT-2),1) ;
	i_FdrwW2_dreW       = ones(size(FdrwW2_dreW)) ;
    i_FdrwW2_dreW(isnan(FdrwW2_dreW)==1)    = 0 ;
    FdrwW2_dreW(i_FdrwW2_dreW==0)           = 0 ;
    %   21
    drwH_FdreH2   	 	= drwH.*F2.dreH2 ;
    drwH_FdreH2         = reshape(drwH_FdreH2',simul_size*(sT-2),1) ;
	i_drwH_FdreH2       = ones(size(drwH_FdreH2)) ;
    i_drwH_FdreH2(isnan(drwH_FdreH2)==1)    = 0 ;
    drwH_FdreH2(i_drwH_FdreH2==0)           = 0 ;
    %   22
    FdrwH_dreH2   	 	= F2.drwH.*dreH2 ; 
    FdrwH_dreH2         = reshape(FdrwH_dreH2',simul_size*(sT-2),1) ;
	i_FdrwH_dreH2       = ones(size(FdrwH_dreH2)) ;
    i_FdrwH_dreH2(isnan(FdrwH_dreH2)==1)    = 0 ;
    FdrwH_dreH2(i_FdrwH_dreH2==0)           = 0 ;
    %   23
    drwW_FdreH2   	 	= drwW.*F2.dreH2 ; 
    drwW_FdreH2         = reshape(drwW_FdreH2',simul_size*(sT-2),1) ;
	i_drwW_FdreH2       = ones(size(drwW_FdreH2)) ;
    i_drwW_FdreH2(isnan(drwW_FdreH2)==1)    = 0 ;
    drwW_FdreH2(i_drwW_FdreH2==0)           = 0 ;
    %   24
    FdrwW_dreH2   	 	= F2.drwW.*dreH2 ; 
    FdrwW_dreH2         = reshape(FdrwW_dreH2',simul_size*(sT-2),1) ;
	i_FdrwW_dreH2       = ones(size(FdrwW_dreH2)) ;
    i_FdrwW_dreH2(isnan(FdrwW_dreH2)==1)    = 0 ;
    FdrwW_dreH2(i_FdrwW_dreH2==0)           = 0 ;
    %   25
    drwH_FdreW2   	 	= drwH.*F2.dreW2 ; 
    drwH_FdreW2         = reshape(drwH_FdreW2',simul_size*(sT-2),1) ;
	i_drwH_FdreW2       = ones(size(drwH_FdreW2)) ;
    i_drwH_FdreW2(isnan(drwH_FdreW2)==1)    = 0 ;
    drwH_FdreW2(i_drwH_FdreW2==0)           = 0 ;
    %   26
    FdrwH_dreW2   	 	= F2.drwH.*dreW2 ;
    FdrwH_dreW2         = reshape(FdrwH_dreW2',simul_size*(sT-2),1) ;
	i_FdrwH_dreW2       = ones(size(FdrwH_dreW2)) ;
    i_FdrwH_dreW2(isnan(FdrwH_dreW2)==1)    = 0 ;
    FdrwH_dreW2(i_FdrwH_dreW2==0)           = 0 ;
    %   27
    drwW_FdreW2   	 	= drwW.*F2.dreW2 ; 
    drwW_FdreW2         = reshape(drwW_FdreW2',simul_size*(sT-2),1) ;
	i_drwW_FdreW2       = ones(size(drwW_FdreW2)) ;
    i_drwW_FdreW2(isnan(drwW_FdreW2)==1)    = 0 ;
    drwW_FdreW2(i_drwW_FdreW2==0)           = 0 ;
    %   28
    FdrwW_dreW2   	 	= F2.drwW.*dreW2 ; 
    FdrwW_dreW2         = reshape(FdrwW_dreW2',simul_size*(sT-2),1) ;
	i_FdrwW_dreW2       = ones(size(FdrwW_dreW2)) ;
    i_FdrwW_dreW2(isnan(FdrwW_dreW2)==1)    = 0 ;
    FdrwW_dreW2(i_FdrwW_dreW2==0)           = 0 ;
    %   29
    drwH_FdreH_FdreW 	= drwH.*F2.dreH.*F2.dreW  ;
    drwH_FdreH_FdreW    = reshape(drwH_FdreH_FdreW',simul_size*(sT-2),1) ;
	i_drwH_FdreH_FdreW  = ones(size(drwH_FdreH_FdreW)) ;
    i_drwH_FdreH_FdreW(isnan(drwH_FdreH_FdreW)==1)  = 0 ;
    drwH_FdreH_FdreW(i_drwH_FdreH_FdreW==0)         = 0 ;
    %   30
    FdrwH_dreH_dreW  	= F2.drwH.*dreH.*dreW  ;
    FdrwH_dreH_dreW     = reshape(FdrwH_dreH_dreW',simul_size*(sT-2),1) ;
	i_FdrwH_dreH_dreW   = ones(size(FdrwH_dreH_dreW)) ;
    i_FdrwH_dreH_dreW(isnan(FdrwH_dreH_dreW)==1)    = 0 ;
    FdrwH_dreH_dreW(i_FdrwH_dreH_dreW==0)           = 0 ;
    %   31
    drwW_FdreH_FdreW 	= drwW.*F2.dreH.*F2.dreW  ; 
    drwW_FdreH_FdreW    = reshape(drwW_FdreH_FdreW',simul_size*(sT-2),1) ;
	i_drwW_FdreH_FdreW  = ones(size(drwW_FdreH_FdreW)) ;
    i_drwW_FdreH_FdreW(isnan(drwW_FdreH_FdreW)==1)  = 0 ;
    drwW_FdreH_FdreW(i_drwW_FdreH_FdreW==0)         = 0 ;
    %   32
    FdrwW_dreH_dreW  	= F2.drwW.*dreH.*dreW ;
    FdrwW_dreH_dreW     = reshape(FdrwW_dreH_dreW',simul_size*(sT-2),1) ;
	i_FdrwW_dreH_dreW   = ones(size(FdrwW_dreH_dreW)) ;
    i_FdrwW_dreH_dreW(isnan(FdrwW_dreH_dreW)==1)    = 0 ;
    FdrwW_dreH_dreW(i_FdrwW_dreH_dreW==0)           = 0 ;
    
    %	-targeted consumption moments:
    %   33
	drwH_Fdrcons     	= drwH.*F2.drcons  ;
    drwH_Fdrcons        = reshape(drwH_Fdrcons',simul_size*(sT-2),1) ;
    i_drwH_Fdrcons      = ones(size(drwH_Fdrcons)) ;
    i_drwH_Fdrcons(isnan(drwH_Fdrcons)==1)      = 0 ;
    drwH_Fdrcons(i_drwH_Fdrcons==0)             = 0 ;
    %   34
	FdrwH_drcons     	= F2.drwH.*drcons  ;
    FdrwH_drcons        = reshape(FdrwH_drcons',simul_size*(sT-2),1) ;
	i_FdrwH_drcons      = ones(size(FdrwH_drcons)) ;
    i_FdrwH_drcons(isnan(FdrwH_drcons)==1)      = 0 ;
    FdrwH_drcons(i_FdrwH_drcons==0)             = 0 ;
    %   35
    drwW_Fdrcons     	= drwW.*F2.drcons  ;
    drwW_Fdrcons        = reshape(drwW_Fdrcons',simul_size*(sT-2),1) ;
	i_drwW_Fdrcons      = ones(size(drwW_Fdrcons)) ;
    i_drwW_Fdrcons(isnan(drwW_Fdrcons)==1)      = 0 ;
    drwW_Fdrcons(i_drwW_Fdrcons==0)             = 0 ;
    %   36
    FdrwW_drcons     	= F2.drwW.*drcons  ;
    FdrwW_drcons        = reshape(FdrwW_drcons',simul_size*(sT-2),1) ;
	i_FdrwW_drcons      = ones(size(FdrwW_drcons)) ;
    i_FdrwW_drcons(isnan(FdrwW_drcons)==1)      = 0 ;
    FdrwW_drcons(i_FdrwW_drcons==0)             = 0 ;
    %   37
    dreH_Fdrcons     	= dreH.*F2.drcons  ;
    dreH_Fdrcons        = reshape(dreH_Fdrcons',simul_size*(sT-2),1) ;
	i_dreH_Fdrcons      = ones(size(dreH_Fdrcons)) ;
    i_dreH_Fdrcons(isnan(dreH_Fdrcons)==1)      = 0 ;
    dreH_Fdrcons(i_dreH_Fdrcons==0)             = 0 ;
    %   38
    FdreH_drcons     	= F2.dreH.*drcons  ;
    FdreH_drcons        = reshape(FdreH_drcons',simul_size*(sT-2),1) ;
	i_FdreH_drcons      = ones(size(FdreH_drcons)) ;
    i_FdreH_drcons(isnan(FdreH_drcons)==1)      = 0 ;
    FdreH_drcons(i_FdreH_drcons==0)             = 0 ;
    %   39
    dreW_Fdrcons     	= dreW.*F2.drcons  ;
    dreW_Fdrcons        = reshape(dreW_Fdrcons',simul_size*(sT-2),1) ;
	i_dreW_Fdrcons      = ones(size(dreW_Fdrcons)) ;
    i_dreW_Fdrcons(isnan(dreW_Fdrcons)==1)      = 0 ;
    dreW_Fdrcons(i_dreW_Fdrcons==0)             = 0 ;
    %   40
    FdreW_drcons     	= F2.dreW.*drcons  ;
    FdreW_drcons        = reshape(FdreW_drcons',simul_size*(sT-2),1) ;
	i_FdreW_drcons      = ones(size(FdreW_drcons)) ;
    i_FdreW_drcons(isnan(FdreW_drcons)==1)      = 0 ;
    FdreW_drcons(i_FdreW_drcons==0)             = 0 ;
    %   41
    drcons_Fdrcons 	 	= drcons.*F2.drcons ;
    drcons_Fdrcons      = reshape(drcons_Fdrcons',simul_size*(sT-2),1) ;
	i_drcons_Fdrcons    = ones(size(drcons_Fdrcons)) ;
    i_drcons_Fdrcons(isnan(drcons_Fdrcons)==1)  = 0 ;
    drcons_Fdrcons(i_drcons_Fdrcons==0)         = 0 ;
    %   42
    drwH2_Fdrcons    	= drwH2.*F2.drcons  ;
    drwH2_Fdrcons       = reshape(drwH2_Fdrcons',simul_size*(sT-2),1) ;
	i_drwH2_Fdrcons     = ones(size(drwH2_Fdrcons)) ;
    i_drwH2_Fdrcons(isnan(drwH2_Fdrcons)==1)    = 0 ;
    drwH2_Fdrcons(i_drwH2_Fdrcons==0)           = 0 ;
    %   43
    FdrwH2_drcons    	= F2.drwH2.*drcons  ;
    FdrwH2_drcons       = reshape(FdrwH2_drcons',simul_size*(sT-2),1) ;
	i_FdrwH2_drcons     = ones(size(FdrwH2_drcons)) ;
    i_FdrwH2_drcons(isnan(FdrwH2_drcons)==1)    = 0 ;
    FdrwH2_drcons(i_FdrwH2_drcons==0)           = 0 ;
    %   44
    drwW2_Fdrcons    	= drwW2.*F2.drcons  ;
    drwW2_Fdrcons       = reshape(drwW2_Fdrcons',simul_size*(sT-2),1) ;
	i_drwW2_Fdrcons     = ones(size(drwW2_Fdrcons)) ;
    i_drwW2_Fdrcons(isnan(drwW2_Fdrcons)==1)    = 0 ;
    drwW2_Fdrcons(i_drwW2_Fdrcons==0)           = 0 ;
    %   45
    FdrwW2_drcons    	= F2.drwW2.*drcons ;
    FdrwW2_drcons       = reshape(FdrwW2_drcons',simul_size*(sT-2),1) ;
	i_FdrwW2_drcons     = ones(size(FdrwW2_drcons)) ;
    i_FdrwW2_drcons(isnan(FdrwW2_drcons)==1)    = 0 ;
    FdrwW2_drcons(i_FdrwW2_drcons==0)           = 0 ;
    %   46
    drwH_Fdrcons2    	= drwH.*F2.drcons2  ;
    drwH_Fdrcons2       = reshape(drwH_Fdrcons2',simul_size*(sT-2),1) ;
	i_drwH_Fdrcons2     = ones(size(drwH_Fdrcons2)) ;
    i_drwH_Fdrcons2(isnan(drwH_Fdrcons2)==1)    = 0 ;
    drwH_Fdrcons2(i_drwH_Fdrcons2==0)           = 0 ;
    %   47
    FdrwH_drcons2    	= F2.drwH.*drcons2  ;
    FdrwH_drcons2       = reshape(FdrwH_drcons2',simul_size*(sT-2),1) ;
	i_FdrwH_drcons2     = ones(size(FdrwH_drcons2)) ;
    i_FdrwH_drcons2(isnan(FdrwH_drcons2)==1)    = 0 ;
    FdrwH_drcons2(i_FdrwH_drcons2==0)           = 0 ;
    %   48
    drwW_Fdrcons2    	= drwW.*F2.drcons2  ;
    drwW_Fdrcons2       = reshape(drwW_Fdrcons2',simul_size*(sT-2),1) ;
	i_drwW_Fdrcons2     = ones(size(drwW_Fdrcons2)) ;
    i_drwW_Fdrcons2(isnan(drwW_Fdrcons2)==1)    = 0 ;
    drwW_Fdrcons2(i_drwW_Fdrcons2==0)           = 0 ;
    %   49
    FdrwW_drcons2    	= F2.drwW.*drcons2 ;
    FdrwW_drcons2       = reshape(FdrwW_drcons2',simul_size*(sT-2),1) ;
	i_FdrwW_drcons2     = ones(size(FdrwW_drcons2)) ;
    i_FdrwW_drcons2(isnan(FdrwW_drcons2)==1)    = 0 ;
    FdrwW_drcons2(i_FdrwW_drcons2==0)           = 0 ;
    %   50
    drwH_FdreH_Fdrcons 	= drwH.*F2.dreH.*F2.drcons  ;
    drwH_FdreH_Fdrcons  = reshape(drwH_FdreH_Fdrcons',simul_size*(sT-2),1) ;
	i_drwH_FdreH_Fdrcons= ones(size(drwH_FdreH_Fdrcons)) ;
    i_drwH_FdreH_Fdrcons(isnan(drwH_FdreH_Fdrcons)==1)  = 0 ;
    drwH_FdreH_Fdrcons(i_drwH_FdreH_Fdrcons==0)         = 0 ;
    %   51
    FdrwH_dreH_drcons 	= F2.drwH.*dreH.*drcons;
    FdrwH_dreH_drcons   = reshape(FdrwH_dreH_drcons',simul_size*(sT-2),1) ;
	i_FdrwH_dreH_drcons = ones(size(FdrwH_dreH_drcons)) ;
    i_FdrwH_dreH_drcons(isnan(FdrwH_dreH_drcons)==1)    = 0 ;
    FdrwH_dreH_drcons(i_FdrwH_dreH_drcons==0)           = 0 ;
    %   52
    drwW_FdreH_Fdrcons 	= drwW.*F2.dreH.*F2.drcons  ;
    drwW_FdreH_Fdrcons  = reshape(drwW_FdreH_Fdrcons',simul_size*(sT-2),1) ;
	i_drwW_FdreH_Fdrcons= ones(size(drwW_FdreH_Fdrcons)) ;
    i_drwW_FdreH_Fdrcons(isnan(drwW_FdreH_Fdrcons)==1)  = 0 ;
    drwW_FdreH_Fdrcons(i_drwW_FdreH_Fdrcons==0)         = 0 ;
    %   53
    FdrwW_dreH_drcons 	= F2.drwW.*dreH.*drcons ;
    FdrwW_dreH_drcons   = reshape(FdrwW_dreH_drcons',simul_size*(sT-2),1) ;
	i_FdrwW_dreH_drcons = ones(size(FdrwW_dreH_drcons)) ;
    i_FdrwW_dreH_drcons(isnan(FdrwW_dreH_drcons)==1)    = 0 ;
    FdrwW_dreH_drcons(i_FdrwW_dreH_drcons==0)           = 0 ;
    %   54
    drwH_FdreW_Fdrcons 	= drwH.*F2.dreW.*F2.drcons  ;
    drwH_FdreW_Fdrcons  = reshape(drwH_FdreW_Fdrcons',simul_size*(sT-2),1) ;
	i_drwH_FdreW_Fdrcons= ones(size(drwH_FdreW_Fdrcons)) ;
    i_drwH_FdreW_Fdrcons(isnan(drwH_FdreW_Fdrcons)==1)  = 0 ;
    drwH_FdreW_Fdrcons(i_drwH_FdreW_Fdrcons==0)         = 0 ;
    %   55
    FdrwH_dreW_drcons 	= F2.drwH.*dreW.*drcons ;
    FdrwH_dreW_drcons   = reshape(FdrwH_dreW_drcons',simul_size*(sT-2),1) ;
	i_FdrwH_dreW_drcons = ones(size(FdrwH_dreW_drcons)) ;
    i_FdrwH_dreW_drcons(isnan(FdrwH_dreW_drcons)==1)    = 0 ;
    FdrwH_dreW_drcons(i_FdrwH_dreW_drcons==0)           = 0 ;
    %   56
    drwW_FdreW_Fdrcons 	= drwW.*F2.dreW.*F2.drcons  ;
    drwW_FdreW_Fdrcons  = reshape(drwW_FdreW_Fdrcons',simul_size*(sT-2),1) ;
	i_drwW_FdreW_Fdrcons= ones(size(drwW_FdreW_Fdrcons)) ;
    i_drwW_FdreW_Fdrcons(isnan(drwW_FdreW_Fdrcons)==1)  = 0 ;
    drwW_FdreW_Fdrcons(i_drwW_FdreW_Fdrcons==0)         = 0 ;
    %   57
    FdrwW_dreW_drcons 	= F2.drwW.*dreW.*drcons ;
    FdrwW_dreW_drcons   = reshape(FdrwW_dreW_drcons',simul_size*(sT-2),1) ;
	i_FdrwW_dreW_drcons = ones(size(FdrwW_dreW_drcons)) ;
    i_FdrwW_dreW_drcons(isnan(FdrwW_dreW_drcons)==1)    = 0 ;
    FdrwW_dreW_drcons(i_FdrwW_dreW_drcons==0)           = 0 ;
    
    %	-targeted BPS moments:
    %   58
	drwH_dreH    	 	= drwH.*dreH  ;
    drwH_dreH           = reshape(drwH_dreH',simul_size*(sT-2),1) ;
	i_drwH_dreH         = ones(size(drwH_dreH)) ;
    i_drwH_dreH(isnan(drwH_dreH)==1)        = 0 ;
    drwH_dreH(i_drwH_dreH==0)               = 0 ;
    %   59
    drwW_dreH    	 	= drwW.*dreH  ;
    drwW_dreH           = reshape(drwW_dreH',simul_size*(sT-2),1) ;
	i_drwW_dreH         = ones(size(drwW_dreH)) ;
    i_drwW_dreH(isnan(drwW_dreH)==1)        = 0 ;
    drwW_dreH(i_drwW_dreH==0)               = 0 ;
    %   60
    drwH_dreW    	 	= drwH.*dreW  ;
    drwH_dreW           = reshape(drwH_dreW',simul_size*(sT-2),1) ;
	i_drwH_dreW         = ones(size(drwH_dreW)) ;
    i_drwH_dreW(isnan(drwH_dreW)==1)        = 0 ;
    drwH_dreW(i_drwH_dreW==0)               = 0 ;
    %   61
    drwW_dreW    	 	= drwW.*dreW  ;
    drwW_dreW           = reshape(drwW_dreW',simul_size*(sT-2),1) ;
	i_drwW_dreW         = ones(size(drwW_dreW)) ;
    i_drwW_dreW(isnan(drwW_dreW)==1)        = 0 ;
    drwW_dreW(i_drwW_dreW==0)               = 0 ;
    %   62
    drwH_drcons     	= drwH.*drcons;
    drwH_drcons         = reshape(drwH_drcons',simul_size*(sT-2),1) ;
	i_drwH_drcons       = ones(size(drwH_drcons)) ;
    i_drwH_drcons(isnan(drwH_drcons)==1)    = 0 ;
    drwH_drcons(i_drwH_drcons==0)           = 0 ;
    %   63
    drwW_drcons     	= drwW.*drcons;
    drwW_drcons         = reshape(drwW_drcons',simul_size*(sT-2),1) ;
	i_drwW_drcons       = ones(size(drwW_drcons)) ;
    i_drwW_drcons(isnan(drwW_drcons)==1)    = 0 ;
    drwW_drcons(i_drwW_drcons==0)           = 0 ;
    %   64
    dreH_dreH    	 	= dreH.*dreH  ;
    dreH_dreH           = reshape(dreH_dreH',simul_size*(sT-2),1) ;
	i_dreH_dreH         = ones(size(dreH_dreH)) ;
    i_dreH_dreH(isnan(dreH_dreH)==1)        = 0 ;
    dreH_dreH(i_dreH_dreH==0)               = 0 ;
    %   65
    dreH_dreW    	 	= dreH.*dreW  ;
    dreH_dreW           = reshape(dreH_dreW',simul_size*(sT-2),1) ;
	i_dreH_dreW         = ones(size(dreH_dreW)) ;
    i_dreH_dreW(isnan(dreH_dreW)==1)        = 0 ;
    dreH_dreW(i_dreH_dreW==0)               = 0 ;
    %   66
    dreW_dreW    	 	= dreW.*dreW  ;
    dreW_dreW           = reshape(dreW_dreW',simul_size*(sT-2),1) ;
	i_dreW_dreW         = ones(size(dreW_dreW)) ;
    i_dreW_dreW(isnan(dreW_dreW)==1)        = 0 ;
    dreW_dreW(i_dreW_dreW==0)               = 0 ;
    %   67
    dreH_drcons     	= dreH.*drcons;
    dreH_drcons         = reshape(dreH_drcons',simul_size*(sT-2),1) ;
	i_dreH_drcons       = ones(size(dreH_drcons)) ;
    i_dreH_drcons(isnan(dreH_drcons)==1)    = 0 ;
    dreH_drcons(i_dreH_drcons==0)           = 0 ;
    %   68
    dreW_drcons     	= dreW.*drcons;
    dreW_drcons         = reshape(dreW_drcons',simul_size*(sT-2),1) ;
	i_dreW_drcons       = ones(size(dreW_drcons)) ;
    i_dreW_drcons(isnan(dreW_drcons)==1)    = 0 ;
    dreW_drcons(i_dreW_drcons==0)           = 0 ;
    %   69
    drcons_drcons 	 	= drcons.*drcons;
    drcons_drcons       = reshape(drcons_drcons',simul_size*(sT-2),1) ;
    i_drcons_drcons     = ones(size(drcons_drcons)) ;
    i_drcons_drcons(isnan(drcons_drcons)==1)= 0 ;
    drcons_drcons(i_drcons_drcons==0)       = 0 ;

    %   Vectorize original residuals and their squares, generate indicators
    %   for missing values:
    drwH        = reshape(drwH',simul_size*(sT-2),1) ;
    i_drwH      = ones(size(drwH))      ;
    i_drwH(isnan(drwH)==1)      = 0     ;
    drwH(i_drwH==0)             = 0     ;
    drwH2       = reshape(drwH2',simul_size*(sT-2),1) ;
    i_drwH2     = ones(size(drwH2))     ;
    i_drwH2(isnan(drwH2)==1)    = 0     ;
    drwH2(i_drwH2==0)           = 0     ;
    drwW        = reshape(drwW',simul_size*(sT-2),1) ;
    i_drwW      = ones(size(drwW))      ;
    i_drwW(isnan(drwW)==1)      = 0     ;
    drwW(i_drwW==0)             = 0     ;
    drwW2       = reshape(drwW2',simul_size*(sT-2),1) ;
    i_drwW2     = ones(size(drwW2))     ;
    i_drwW2(isnan(drwW2)==1)    = 0     ;
    drwW2(i_drwW2==0)           = 0     ;
    drcons      = reshape(drcons',simul_size*(sT-2),1) ;
    i_drcons    = ones(size(drcons))    ;
    i_drcons(isnan(drcons)==1)  = 0     ;
    drcons(i_drcons==0)         = 0     ;
    
    %   Vectorize partial insurance parameters:
    s   = reshape(pooldata.s(:,2:end-1)', simul_size*(sT-2),1) ;
    pi  = reshape(pooldata.pi(:,2:end-1)',simul_size*(sT-2),1) ;
    s(i_drwH==0)                = 0     ;
    pi(i_drwH==0)               = 0     ;
                
    %   Stack all moments together in a way that resembles the 
    %   same operation in Stata: 
    gmm_data = [sim_hh_id sim_year s pi ...
                drwH i_drwH drwH2 i_drwH2 drwW i_drwW drwW2 i_drwW2 drcons i_drcons ...
                drwH_dreH i_drwH_dreH drwH_FdreH ...		
				i_drwH_FdreH FdrwH_dreH i_FdrwH_dreH drwW_dreH i_drwW_dreH ...
				drwW_FdreH i_drwW_FdreH FdrwW_dreH i_FdrwW_dreH drwH_dreW  ...		
				i_drwH_dreW drwH_FdreW i_drwH_FdreW FdrwH_dreW i_FdrwH_dreW  ...
				drwW_dreW i_drwW_dreW drwW_FdreW i_drwW_FdreW FdrwW_dreW  ...
				i_FdrwW_dreW dreH_dreH i_dreH_dreH dreH_FdreH i_dreH_FdreH  ...
				dreH_dreW i_dreH_dreW dreH_FdreW i_dreH_FdreW FdreH_dreW  ...	
				i_FdreH_dreW dreW_dreW i_dreW_dreW dreW_FdreW i_dreW_FdreW  ...	 
				drwH2_FdreH i_drwH2_FdreH FdrwH2_dreH i_FdrwH2_dreH  ...
				drwW2_FdreH i_drwW2_FdreH FdrwW2_dreH i_FdrwW2_dreH  ...
				drwH2_FdreW i_drwH2_FdreW FdrwH2_dreW i_FdrwH2_dreW  ...
				drwW2_FdreW i_drwW2_FdreW FdrwW2_dreW i_FdrwW2_dreW  ...
				drwH_FdreH2 i_drwH_FdreH2 FdrwH_dreH2 i_FdrwH_dreH2  ... 
				drwW_FdreH2 i_drwW_FdreH2 FdrwW_dreH2 i_FdrwW_dreH2  ...
				drwH_FdreW2 i_drwH_FdreW2 FdrwH_dreW2 i_FdrwH_dreW2  ...
				drwW_FdreW2 i_drwW_FdreW2 FdrwW_dreW2 i_FdrwW_dreW2  ...
				drwH_FdreH_FdreW i_drwH_FdreH_FdreW FdrwH_dreH_dreW  ...
				i_FdrwH_dreH_dreW drwW_FdreH_FdreW i_drwW_FdreH_FdreW ...
				FdrwW_dreH_dreW i_FdrwW_dreH_dreW drwH_drcons i_drwH_drcons  ...
				drwH_Fdrcons i_drwH_Fdrcons FdrwH_drcons i_FdrwH_drcons  ...
				drwW_drcons i_drwW_drcons drwW_Fdrcons i_drwW_Fdrcons  ...      	
				FdrwW_drcons i_FdrwW_drcons dreH_drcons i_dreH_drcons   ...
				dreH_Fdrcons i_dreH_Fdrcons FdreH_drcons i_FdreH_drcons  ...
				dreW_drcons i_dreW_drcons dreW_Fdrcons i_dreW_Fdrcons    ...  	   	
				FdreW_drcons i_FdreW_drcons drcons_drcons i_drcons_drcons ...
				drcons_Fdrcons i_drcons_Fdrcons	drwH2_Fdrcons i_drwH2_Fdrcons  ...   	  	
				FdrwH2_drcons i_FdrwH2_drcons drwW2_Fdrcons i_drwW2_Fdrcons    ... 	  	
				FdrwW2_drcons i_FdrwW2_drcons drwH_Fdrcons2 i_drwH_Fdrcons2    ... 	  	
				FdrwH_drcons2 i_FdrwH_drcons2 drwW_Fdrcons2 i_drwW_Fdrcons2    ... 	  	
				FdrwW_drcons2 i_FdrwW_drcons2 drwH_FdreH_Fdrcons i_drwH_FdreH_Fdrcons 	 ...
				FdrwH_dreH_drcons i_FdrwH_dreH_drcons drwW_FdreH_Fdrcons  ...
				i_drwW_FdreH_Fdrcons FdrwW_dreH_drcons i_FdrwW_dreH_drcons  ...
				drwH_FdreW_Fdrcons i_drwH_FdreW_Fdrcons FdrwH_dreW_drcons  ...
				i_FdrwH_dreW_drcons drwW_FdreW_Fdrcons i_drwW_FdreW_Fdrcons  ...
				FdrwW_dreW_drcons i_FdrwW_dreW_drcons] ;

end