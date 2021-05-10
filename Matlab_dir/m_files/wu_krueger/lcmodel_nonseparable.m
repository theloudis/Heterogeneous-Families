function [arrays_policy_ns, arrays_simulation_ns, sim_data_ns] = lcmodel_nonseparable(par, ind)
%{  
    'Consumption Inequality across Heterogeneous Families'
    This function solves and simulates Wu & Krueger (2020)'s lifecycle model
	for consumption and family labor supply with nonseparable preferences. 
	
	This code is an adaptation to the original code provided by 
	Wu & Krueger (2020), 'Consumption Insurance Against Wage Risk',
	published in AEJ-Macro.

    Alexandros Theloudis
    -----------------------------------------------------------------------
%}

    %   Initial statements and switches:
    global unidim_nFgrid unidim_nugrid ;

    %	Declare program switches and fundamental parameters:
    ind_refined_grid    = 1 ;       % use refined upper bound for asset grids based on simulation (1) or not (0).
    

    %%	A. INITIALIZE GRIDS.
    %	Initializes model grids.
    %   -----------------------------------------------------------------------

    %   Discretize the permanent component of wages:
    nFgrid  = unidim_nFgrid^2;
    [Fgrid, F_transit_mat, F_initial_prob]  = fun_discretize_perm(par.R, unidim_nFgrid, par.O_F_initial, par.O_v, [par.rho1,0; 0,par.rho2]);

    %   Discretize the transitory component of wages:
    nugrid  = unidim_nugrid^2;                                      
    [ugrid, u_prob]                         = fun_discretize_transit(unidim_nugrid, par.O_u);
    
    % 	Initialize asset grid:
    nAgrid              = 100 ;     % number of grid points for asset (100)
    Agrid_lim           = ones(2,par.R+1)*NaN ;
    %	-obtain assets lower bound:
    Agrid_lim(1,:)      = par.bc;
    %	-obtain assets upper bound:
    if      ind_refined_grid==0
        Agrid_lim(2,:)  = Agrid_lim(1,:)+60;         % arbitrary presumed upper bound of assets
    elseif  ind_refined_grid==1
        load('sim_Alim_ns.mat','sim_Alim')
        Agrid_lim(2,:)  = sim_Alim(2,1:par.R+1);     % refined upper bound of assets based on Wu & Krueger's simulations
    end
    %	-populate asset grid; denser grid when assets closer to lower bound:
    Agrid_gamma = 20^(1/(nAgrid-2)) ;
    Agrid_range = Agrid_lim(2,:)-Agrid_lim(1,:);
    Agrid = ones(nAgrid,1)*Agrid_lim(1,:) + (1-Agrid_gamma.^((1:nAgrid)'-1))/(1-Agrid_gamma^(nAgrid-1))*Agrid_range ;


    %%	B. SOLVE LIFECYCLE MODEL - NON-SEPARABLE PREFERENCES.
    %	Solves lifecycle model for consumption and hours.
    %   -------------------------------------------------------------------

    % 	Solve the household problem:
    [policy_V, policy_C, policy_A_prime, policy_H1, policy_H2] = ...
        fun_HH_ns(par, ind, nAgrid, Agrid, nFgrid, Fgrid, F_transit_mat, nugrid, ugrid, u_prob);
    
    %   Place policy arrays into structure:
    arrays_policy_ns.policy_V          = policy_V ; 
    arrays_policy_ns.policy_C          = policy_C ;
    arrays_policy_ns.policy_A_prime    = policy_A_prime ;
    arrays_policy_ns.policy_H1         = policy_H1 ;
    arrays_policy_ns.policy_H2         = policy_H2 ;


    %%	C. SIMULATE LIFECYCLE MODEL - NON-SEPARABLE PREFERENCES.
    %	Simulates random populations of households.
    %   -------------------------------------------------------------------

    % 	Simulate population:
    sim = lcmodel_simulation(par, ind, nugrid, nFgrid, Agrid, ugrid, u_prob, Fgrid, F_transit_mat, F_initial_prob, ...
                             policy_C, policy_H1, policy_H2, policy_A_prime, policy_V);

    %   Place simulation arrays into structure:
    arrays_simulation_ns.sim_A         = sim.A ; 
    arrays_simulation_ns.sim_C         = sim.C ; 
    arrays_simulation_ns.sim_H1        = sim.H1 ;
    arrays_simulation_ns.sim_H2        = sim.H2 ; 
    arrays_simulation_ns.sim_v1        = sim.v1 ;
    arrays_simulation_ns.sim_v2        = sim.v2 ;
    arrays_simulation_ns.sim_u1        = sim.u1 ; 
    arrays_simulation_ns.sim_u2        = sim.u2 ;
    arrays_simulation_ns.sim_W1        = sim.W1 ;
    arrays_simulation_ns.sim_W2        = sim.W2 ; 
    arrays_simulation_ns.sim_Y         = sim.Y ;
    arrays_simulation_ns.sim_Y1        = sim.Y1 ;
    arrays_simulation_ns.sim_Y2        = sim.Y2 ;
    arrays_simulation_ns.sim_V         = sim.V ;
    
    
    %%	D. AGE RANGE, WEALTH SHARES, MODEL FRISCH ELASTICTIES.
    %	Place simulated data into arrays, conditioning on appropriate age 
    %   range. Calculate wealth shares and true Frisch elastcities.
    %   -------------------------------------------------------------------
    
    %   Condition data on appropriate age range; obtain wealth shares
    %   and outcome variables ratios; obtain model Frisch elasticties: 
    sim_data_ns = fun_sim_data(arrays_simulation_ns, par, ind) ; 
end