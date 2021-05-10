function [policy_V, policy_C, policy_A_prime, policy_H1, policy_H2, policy_VC, policy_VH, policy_VH1, policy_VH2] = ... 
    fun_HH_s(par, ind, nAgrid, Agrid, nFgrid, Fgrid, F_transit_mat, nugrid, ugrid, u_prob)

%{ 
    This function estimates Wu & Kruger's lifecycle model with 
    separable preferences. This code is an adaptation to the 
    original code provided by Wu & Krueger (2020),
    'Consumption Insurance Against Wage Risk', published in AEJ-Macro.

    Alexandros Theloudis
    -----------------------------------------------------------------------
%}

    %   Initial statements:
    options     = optimoptions( 'fsolve', ...
                                'Display','off', ...
                                'FunctionTolerance',1e-6, ...
                                'StepTolerance', 1e-6, ...
                                'MaxFunctionEvaluations',1e5, ...
                                'MaxIterations',1e5, ...
                                'JacobPattern',speye(nAgrid), ...
                                'Algorithm','trust-region');
    options_bc  = optimoptions( 'fsolve', ...
                                'Display','off', ...
                                'FunctionTolerance',1e-6, ...
                                'StepTolerance', 1e-6, ...
                                'MaxFunctionEvaluations',1e5, ...
                                'MaxIterations',1e5);


    %%  1.  INITIALIZE ARRAYS
    %   Initialize arrays to hold results (policy functions). All arrays are
    %   of dimension 'nAgrid' x 'nFgrid*nugrid' x 'R'
    %   -----------------------------------------------------------------------

    %   Policy functions:
    sliced_policy_H1        = NaN(nAgrid, nFgrid*nugrid, par.R);
    sliced_policy_H2        = NaN(nAgrid, nFgrid*nugrid, par.R);
    sliced_policy_C         = NaN(nAgrid, nFgrid*nugrid, par.R);
    sliced_policy_A_prime   = NaN(nAgrid, nFgrid*nugrid, par.R);
    sliced_policy_V         = NaN(nAgrid, nFgrid*nugrid, par.R);
    sliced_policy_V_A       = NaN(nAgrid, nFgrid*nugrid, par.R);
    sliced_policy_VC        = NaN(nAgrid, nFgrid*nugrid, par.R);
    sliced_policy_VH        = NaN(nAgrid, nFgrid*nugrid, par.R);
    sliced_policy_VH1       = NaN(nAgrid, nFgrid*nugrid, par.R);
    sliced_policy_VH2       = NaN(nAgrid, nFgrid*nugrid, par.R);


    %%  2.  OBTAIN POLICY FUNCTIONS IN LAST PERIOD OF WORK LIFE
    %   This reflects an age R household.
    %   -----------------------------------------------------------------------

    %   Declare age:
    it = par.R ;

    %   Asset and future assets grid:
    temp_Agrid_it       = Agrid(:,it);
    temp_A_prime_grid   = Agrid(:,it+1);

    %   Future consumption grid (i.e. at age R+1):           
    %   Note: Here Wu & Krueger calculate the R+1 consumption grid using
    %   1) the sequential budget constraint from R+1 forward until T;
    %   2) the consumption Euler equation u'(C_R) = \beta*(1+r)*u'(C_R+1);
    %   3) the assumption that A_{T+1} (terminal assets) are zero.
    temp_C_prime_grid   = (sum((1/(1+par.r)).^(0:1:(par.T-par.R-1)))*par.rb + (1+par.r)*temp_A_prime_grid) ...
                            / sum((((1+par.r)/(1+par.delta))^(1/par.sigma)/(1+par.r)).^(0:1:par.T-par.R-1)) ;
    
    %   Obtain current consumption grid as function of future consumption
    %   grid using the consumption Euler equation
    %       u'(C_R) = \beta*(1+r)*u'(C_R+1):
    temp_C_grid         = ((1+par.r)/(1+par.delta))^(-1/par.sigma)*temp_C_prime_grid ;

    %   Loop over full grid of all permanent and transitory wage shocks
    %   for both spouses (note: 'iFiu' first loops over the grid of 
    %   permanent shocks for a given transitory shock; then repeats for
    %   all transitpry shocks):
    for iFiu=1:nFgrid*nugrid    % this is a 'parfor' in Wu & Krueger.
    
        %   Obtain indexes of permanent and transitory shocks in this 
        %   realization of the loop:
        [iF,iu] = ind2sub([nFgrid,nugrid], iFiu);
            
        %   Obtain the level of male wage - recall that the wage process is
        %       log(W_{1t}) = g_{1t} + F_{1t} + v_{1t}
        temp_W1 = par.w1*exp(par.gtrend1(it) + Fgrid(1,iF,it) + ugrid(1,iu));

        %   Obtain the level of female wage - recall that the wage process is
        %       log(W_{2t}) = g_{2t} + F_{2t} + v_{2t}
        temp_W2 = par.w2*exp(par.gtrend2(it) + Fgrid(2,iF,it) + ugrid(2,iu));
            

        %%%%%%%%%%%%%%%%
        % Case I: H2>0 %
        %%%%%%%%%%%%%%%%        
        
        %   Solve for H1:
        %   -initialize optimal log male hours per point on the asset grid:
        temp_x0 = zeros(nAgrid,1) ;
        %   -declare first order condition (involves marginal rate of 
        %    substitution between male hours and consumption, considering 
        %    also the marginal rate of substitution between male and female
        %    hours); request root with respect to log male hours:
        f = @(x) fun_foc_HH_s(x, temp_C_grid, temp_W1, temp_W2, par, 1);
        [temp_x_star,~,temp_exitflag] = fsolve(f, temp_x0, options);
        %   -report if there is no solution:
        if temp_exitflag~=1
            disp(['fsolve failed at ', '[',num2str([iF,iu,it]),'],',' exitflag=',num2str(temp_exitflag)])
        end
        temp_H1_grid = exp(temp_x_star);

        %   Solve for H2, given male hours, using marginal rate of 
        %   substitution between male and female hours, i.e.
        %       u'(H2) = u'(H1)*(W2/W1):
        temp_H2_grid = (((par.psi1*temp_W2)/(par.psi2*temp_W1))^par.eta2) * temp_H1_grid.^(par.eta2/par.eta1) ;
        %   -obtain before tax household income given wages and hours:   
        temp_Y_grid = temp_W1*temp_H1_grid + temp_W2*temp_H2_grid;
        %   -use budget constraint to obtain current asset grid:
        temp_A_grid = (temp_C_grid + temp_A_prime_grid - (1-par.chi)*temp_Y_grid.^(1-par.mu) + par.tau_ss*temp_Y_grid) / (1+par.r);
      
        %   Interpolate over current asset grid to obtain policy for 
        %   future assets and male hours:
        %   -obtain interpolation objects:
        temp_fun_A_prime        = griddedInterpolant(temp_A_grid, temp_A_prime_grid);
        temp_fun_H1             = griddedInterpolant(temp_A_grid, temp_H1_grid);
        %   -interpolate over current asset grid:
        temp_policy_A_prime_fw  = temp_fun_A_prime(temp_Agrid_it);
        temp_policy_H1_fw       = temp_fun_H1(temp_Agrid_it);
            
        %   Check whether borrowing constraint is binding - the borrowing
        %   constraint may bind in lower parts of asset grid; specifically
        %   in the first 'sum(temp_ind_binding)' items of the grid:
        temp_ind_binding = (temp_Agrid_it<temp_A_grid(1,1));
        if sum(temp_ind_binding)>0
            %   - generate starting vector of log male hours, of length 
            %     equal to the number of points on the asset grid for which
            %     the borrowing constraint binds, and make it equal to male 
            %     hours at the lowest point of asset grid:
            temp_x0 = log(temp_H1_grid(1,1))*ones(sum(temp_ind_binding),1);
            %   - declare first order condition (involves marginal rate of 
            %     substitution between male hours and consumption, 
            %     considering also the marginal rate of substitution
            %     between male and female hours, and that future assets are 
            %     at lowest point over lowest 'sum(temp_ind_binding)' items
            %     on current asset grid): 
            f = @(x) fun_foc_HH_s_bc(x, temp_Agrid_it(temp_ind_binding), temp_A_prime_grid(1,1), temp_W1, temp_W2, par, 1);
            %   - request root with respect to log male hours:
            [temp_x_star,~,temp_exitflag] = fsolve(f, temp_x0, options_bc);
            if temp_exitflag~=1
                disp(['fsolve failed (BC) at ', '[',num2str([iF,iu,it]),'],',' exitflag=',num2str(temp_exitflag)])
            end
            temp_policy_H1_fw(temp_ind_binding)         = exp(temp_x_star);
            temp_policy_A_prime_fw(temp_ind_binding)    = temp_A_prime_grid(1,1);
        end

        %   Given assesment of binding budget constraint or not, 
        %   assemble policy functions at time R:
        %   -for female hours given marginal rate of substitution with male hours:
        temp_policy_H2_fw   = ((par.psi1*temp_W2)/(par.psi2*temp_W1))^par.eta2 * temp_policy_H1_fw.^(par.eta2/par.eta1);
        %   -pre-tax household income given choice of hours:
        temp_policy_Y_fw    = temp_W1*temp_policy_H1_fw + temp_W2*temp_policy_H2_fw;
        %   -consumption given marginal rate of substitution with male hours:
        temp_policy_C_fw    = (((1-par.chi)*(1-par.mu)*temp_policy_Y_fw.^(-par.mu)-par.tau_ss)*temp_W1 ...
            ./(par.psi1*temp_policy_H1_fw.^(1/par.eta1))).^(1/par.sigma);
        %   -derivative of value with respect to consumption:
        temp_policy_V_A_fw  = (1+par.r)*temp_policy_C_fw.^(-par.sigma);
        %   -future consumption grid (i.e. at age R+1):
        temp_policy_C_prime_fw = (sum((1/(1+par.r)).^(0:1:par.T-par.R-1))*par.rb+(1+par.r)*temp_policy_A_prime_fw) ...
            /sum((((1+par.r)/(1+par.delta))^(1/par.sigma)/(1+par.r)).^(0:1:par.T-par.R-1));
        %   -value function at time R (includes continuation value throughout retirement):
        temp_policy_V_fw    = (temp_policy_C_fw.^(1-par.sigma))/(1-par.sigma) ...
                            - par.psi1*temp_policy_H1_fw.^(1+1/par.eta1)/(1+1/par.eta1) ...
                            - par.psi2*temp_policy_H2_fw.^(1+1/par.eta2)/(1+1/par.eta2) ...
                            - par.f(it) ...
                            + ((temp_policy_C_prime_fw*(((1+par.r)/(1+par.delta))^(1/par.sigma)).^(0:1:par.T-par.R-1)).^(1-par.sigma))/(1-par.sigma)*(1/(1+par.delta)).^(1:1:par.T-par.R)';
        %   -value from consumption:
        temp_policy_VC_fw   = (temp_policy_C_fw.^(1-par.sigma))/(1-par.sigma) ...
                            + ((temp_policy_C_prime_fw*(((1+par.r)/(1+par.delta))^(1/par.sigma)).^(0:1:par.T-par.R-1)).^(1-par.sigma))/(1-par.sigma)*(1/(1+par.delta)).^(1:1:par.T-par.R)';                      
        %   -value from household hours, male hours, female hours:
        temp_policy_VH_fw   = -par.psi1*temp_policy_H1_fw.^(1+1/par.eta1)/(1+1/par.eta1) - par.psi2*temp_policy_H2_fw.^(1+1/par.eta2)/(1+1/par.eta2) - par.f(it);
        temp_policy_VH1_fw  = -par.psi1*temp_policy_H1_fw.^(1+1/par.eta1)/(1+1/par.eta1);
        temp_policy_VH2_fw  = -par.psi2*temp_policy_H2_fw.^(1+1/par.eta2)/(1+1/par.eta2);
                                             
        %%%%%%%%%%%%%%%%%
        % Case II: H2=0 %
        %%%%%%%%%%%%%%%%%
        
        if ind.faw==0
            %   Solve for H1:
            %   -initialize optimal log male hours per point on the asset grid:
            temp_x0 = zeros(nAgrid,1);
            %   -declare first order condition (involves marginal rate of 
            %    substitution between male hours and consumption); 
            %    request root with respect to log male hours:
            f = @(x) fun_foc_HH_s(x, temp_C_grid, temp_W1, temp_W2, par, 0);
            [temp_x_star,~,temp_exitflag] = fsolve(f, temp_x0, options);
            %   -report if there is no solution:
            if temp_exitflag~=1
                disp(['fsolve failed (FNW) at ', '[',num2str([iF,iu,it]),'],',' exitflag=',num2str(temp_exitflag)])
            end
            temp_H1_grid = exp(temp_x_star);
            
            %   Declare zero female hours (female does not work):
            temp_H2_grid = zeros(size(temp_H1_grid)) ;
            %   -obtain before tax household income given wages and choice for hours:
            temp_Y_grid = temp_W1*temp_H1_grid+temp_W2*temp_H2_grid;
            %   -use budget constraint to obtain current asset grid:
            temp_A_grid = (temp_C_grid + temp_A_prime_grid - (1-par.chi)*temp_Y_grid.^(1-par.mu) + par.tau_ss*temp_Y_grid) / (1+par.r);

            %   Interpolate over current asset grid to obtain policy for 
            %   future assets and male hours:
            %   -obtain interpolation objects:
            temp_fun_A_prime        = griddedInterpolant(temp_A_grid, temp_A_prime_grid);
            temp_fun_H1             = griddedInterpolant(temp_A_grid, temp_H1_grid);
            %   -interpolate over current asset grid:    
            temp_policy_A_prime_fnw = temp_fun_A_prime(temp_Agrid_it);
            temp_policy_H1_fnw      = temp_fun_H1(temp_Agrid_it);
        
            %   Check whether borrowing constraint is binding - the borrowing
            %   constraint may bind in lower parts of asset grid; specifically
            %   in the first 'sum(temp_ind_binding)' items of the grid:
            temp_ind_binding = (temp_Agrid_it<temp_A_grid(1,1));
            if sum(temp_ind_binding)>0
                %   - generate starting vector of log male hours, of length 
                %     equal to the number of points on the asset grid for which
                %     the borrowing constraint binds, and make it equal to male 
                %     hours at the lowest point of asset grid:
                temp_x0 = log(temp_H1_grid(1,1))*ones(sum(temp_ind_binding),1);
                %   - declare first order condition (involves marginal rate of 
                %     substitution between male hours and consumption, and that 
                %     future assets are at lowest point over lowest 
                %     'sum(temp_ind_binding)' items on current asset grid):
                f = @(x) fun_foc_HH_s_bc(x, temp_Agrid_it(temp_ind_binding), temp_A_prime_grid(1,1), temp_W1, temp_W2, par, 0);
                [temp_x_star,~,temp_exitflag] = fsolve(f, temp_x0, options_bc);            
                if temp_exitflag~=1
                    disp(['fsolve failed (FNW BC) at ', '[',num2str([iF,iu,it]),'],',' exitflag=',num2str(temp_exitflag)])
                end
                temp_policy_H1_fnw(temp_ind_binding)        = exp(temp_x_star);
                temp_policy_A_prime_fnw(temp_ind_binding)   = temp_A_prime_grid(1,1);
            end
        
            %   Given assesment of binding budget constraint or not, 
            %   assemble policy functions at time R
            %   -for female hours (zero; female does not work):    
            temp_policy_H2_fnw      = zeros(size(temp_policy_H1_fnw));
            %   -pre-tax household income given choice of hours:
            temp_policy_Y_fnw       = temp_W1*temp_policy_H1_fnw + temp_W2*temp_policy_H2_fnw;
            %   -consumption given marginal rate of substitution with male hours:
            temp_policy_C_fnw       = (((1-par.chi)*(1-par.mu)*temp_policy_Y_fnw.^(-par.mu)-par.tau_ss)*temp_W1 ...
                ./(par.psi1*temp_policy_H1_fnw.^(1/par.eta1))).^(1/par.sigma);
            %   -derivative of value with respect to consumption:
            temp_policy_V_A_fnw     = (1+par.r)*temp_policy_C_fnw.^(-par.sigma);
            %   -future consumption grid (i.e. at age R+1):   
            temp_policy_C_prime_fnw = (sum((1/(1+par.r)).^(0:1:par.T-par.R-1))*par.rb+(1+par.r)*temp_policy_A_prime_fnw) ...
                /sum((((1+par.r)/(1+par.delta))^(1/par.sigma)/(1+par.r)).^(0:1:par.T-par.R-1));
            %   -value function at time R:
            temp_policy_V_fnw       = (temp_policy_C_fnw.^(1-par.sigma))/(1-par.sigma) ...
                                    - par.psi1*temp_policy_H1_fnw.^(1+1/par.eta1)/(1+1/par.eta1) ...
                                    - par.psi2*temp_policy_H2_fnw.^(1+1/par.eta2)/(1+1/par.eta2) ...
                                    + ((temp_policy_C_prime_fnw*(((1+par.r)/(1+par.delta))^(1/par.sigma)).^(0:1:par.T-par.R-1)).^(1-par.sigma))/(1-par.sigma)*(1/(1+par.delta)).^(1:1:par.T-par.R)';
            %   -value from consumption:
            temp_policy_VC_fnw      = (temp_policy_C_fnw.^(1-par.sigma))/(1-par.sigma) ...
                                    + ((temp_policy_C_prime_fnw*(((1+par.r)/(1+par.delta))^(1/par.sigma)).^(0:1:par.T-par.R-1)).^(1-par.sigma))/(1-par.sigma)*(1/(1+par.delta)).^(1:1:par.T-par.R)';
            %   -value from household hours, male hours, female hours:
            temp_policy_VH_fnw      = -par.psi1*temp_policy_H1_fnw.^(1+1/par.eta1)/(1+1/par.eta1) - par.psi2*temp_policy_H2_fnw.^(1+1/par.eta2)/(1+1/par.eta2);
            temp_policy_VH1_fnw     = -par.psi1*temp_policy_H1_fnw.^(1+1/par.eta1)/(1+1/par.eta1);
            temp_policy_VH2_fnw     = -par.psi2*temp_policy_H2_fnw.^(1+1/par.eta2)/(1+1/par.eta2);
        end %ind.faw==0
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Compare two cases: female work vs female non-work           %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        if ind.faw==0
            
            %   Obtain indexes for which value while female works is higher 
            %   than value while she does not work:
            temp_ind_H2                     = (temp_policy_V_fw>temp_policy_V_fnw);

            %   Populate value functions given values of female work and not work:   
            sliced_policy_H1(:,iFiu,it)     = temp_ind_H2.*temp_policy_H1_fw        + (1-temp_ind_H2).*temp_policy_H1_fnw;
            sliced_policy_H2(:,iFiu,it)     = temp_ind_H2.*temp_policy_H2_fw        + (1-temp_ind_H2).*temp_policy_H2_fnw;
            sliced_policy_C(:,iFiu,it)      = temp_ind_H2.*temp_policy_C_fw         + (1-temp_ind_H2).*temp_policy_C_fnw;
            sliced_policy_A_prime(:,iFiu,it)= temp_ind_H2.*temp_policy_A_prime_fw   + (1-temp_ind_H2).*temp_policy_A_prime_fnw;
            sliced_policy_V(:,iFiu,it)      = temp_ind_H2.*temp_policy_V_fw         + (1-temp_ind_H2).*temp_policy_V_fnw;
            sliced_policy_V_A(:,iFiu,it)    = temp_ind_H2.*temp_policy_V_A_fw       + (1-temp_ind_H2).*temp_policy_V_A_fnw;
            sliced_policy_VC(:,iFiu,it)     = temp_ind_H2.*temp_policy_VC_fw        + (1-temp_ind_H2).*temp_policy_VC_fnw;
            sliced_policy_VH(:,iFiu,it)     = temp_ind_H2.*temp_policy_VH_fw        + (1-temp_ind_H2).*temp_policy_VH_fnw;    
            sliced_policy_VH1(:,iFiu,it)    = temp_ind_H2.*temp_policy_VH1_fw       + (1-temp_ind_H2).*temp_policy_VH1_fnw;
            sliced_policy_VH2(:,iFiu,it)    = temp_ind_H2.*temp_policy_VH2_fw       + (1-temp_ind_H2).*temp_policy_VH2_fnw;
            
        else
            
            %   Populate value functions:   
            sliced_policy_H1(:,iFiu,it)     = temp_policy_H1_fw        ;
            sliced_policy_H2(:,iFiu,it)     = temp_policy_H2_fw        ;
            sliced_policy_C(:,iFiu,it)      = temp_policy_C_fw         ;
            sliced_policy_A_prime(:,iFiu,it)= temp_policy_A_prime_fw   ;
            sliced_policy_V(:,iFiu,it)      = temp_policy_V_fw         ;
            sliced_policy_V_A(:,iFiu,it)    = temp_policy_V_A_fw       ;
            sliced_policy_VC(:,iFiu,it)     = temp_policy_VC_fw        ;
            sliced_policy_VH(:,iFiu,it)     = temp_policy_VH_fw        ;    
            sliced_policy_VH1(:,iFiu,it)    = temp_policy_VH1_fw       ;
            sliced_policy_VH2(:,iFiu,it)    = temp_policy_VH2_fw       ;
            
        end %ind.faw==0
    end
    
    %   Report progress:
    fprintf('Finished Lifecycle model period: %u\n',it)


    %%  3.  OBTAIN POLICY FUNCTIONS OVER REMAINING WORK LIFE
    %   Backwards induction over ages R-1 to 1:
    %   -----------------------------------------------------------------------

    %   Loop over ages R-1, backward to age 1:
    for it=(par.R-1):-1:1

        %   Asset and future assets grid:
        temp_Agrid_it           = Agrid(:,it);
        temp_A_prime_grid       = Agrid(:,it+1);
        
        %   Obtain relevant slice of future values:
        temp_sliced_policy_V    = sliced_policy_V(:,:,it+1);
        temp_sliced_policy_V_A  = sliced_policy_V_A(:,:,it+1);
        temp_sliced_policy_VC   = sliced_policy_VC(:,:,it+1);
        temp_sliced_policy_VH   = sliced_policy_VH(:,:,it+1);
        temp_sliced_policy_VH1  = sliced_policy_VH1(:,:,it+1);
        temp_sliced_policy_VH2  = sliced_policy_VH2(:,:,it+1);
    
        %   Loop over full grid of all permanent and transitory wage shocks
        %   for both spouses (note: 'iFiu' first loops over the grid of 
        %   permanent shocks for a given transitory shock; then repeats for
        %   all transitpry shocks):
        for iFiu=1:nFgrid*nugrid         % this is a 'parfor' in Wu & Krueger.

            %   Obtain indexes for permanent and transitory shocks in this 
            %   realization of the loop:
            [iF,iu] = ind2sub([nFgrid,nugrid],iFiu);
            
            %   Obtain the level of male wage - recall that the 
            %   wage process is log(W_{1t}) = g_{1t} + F_{1t} + v_{1t}
            temp_W1 = par.w1*exp(par.gtrend1(it) + Fgrid(1,iF,it) + ugrid(1,iu));

            %   Obtain the level of female wage - recall that the 
            %   wage process is log(W_{2t}) = g_{2t} + F_{2t} + v_{2t}
            temp_W2 = par.w2*exp(par.gtrend2(it) + Fgrid(2,iF,it) + ugrid(2,iu));
            
            %   Obtain expected value function at given point in wage grid
            %   and interpolate over future assets grid:
            %   -consumption given current realization of state space:
            temp_EV_A_prime_grid    = temp_sliced_policy_V_A*reshape(F_transit_mat(iF,:,it)'*u_prob, [nFgrid*nugrid,1]);
            temp_C_grid             = (temp_EV_A_prime_grid/(1+par.delta)).^(-1/par.sigma);
            %   -expected value function at time it+1 given current 
            %    realization of state space:
            temp_EV_prime_grid      = temp_sliced_policy_V*reshape(F_transit_mat(iF,:,it)'*u_prob, [nFgrid*nugrid,1]);
            temp_fun_EV_prime       = griddedInterpolant(temp_A_prime_grid, temp_EV_prime_grid);
            %   -expected consumption value at time it+1 given current 
            %    realization of state space:
            temp_EVC_prime_grid     = temp_sliced_policy_VC*reshape(F_transit_mat(iF,:,it)'*u_prob, [nFgrid*nugrid,1]);
            temp_fun_EVC_prime      = griddedInterpolant(temp_A_prime_grid,temp_EVC_prime_grid);
            %   -expected value from hours at time it+1 given current 
            %    realization of state space:
            temp_EVH_prime_grid     = temp_sliced_policy_VH*reshape(F_transit_mat(iF,:,it)'*u_prob, [nFgrid*nugrid,1]);
            temp_fun_EVH_prime      = griddedInterpolant(temp_A_prime_grid, temp_EVH_prime_grid);
            temp_EVH1_prime_grid    = temp_sliced_policy_VH1*reshape(F_transit_mat(iF,:,it)'*u_prob, [nFgrid*nugrid,1]);
            temp_fun_EVH1_prime     = griddedInterpolant(temp_A_prime_grid, temp_EVH1_prime_grid);
            temp_EVH2_prime_grid    = temp_sliced_policy_VH2*reshape(F_transit_mat(iF,:,it)'*u_prob, [nFgrid*nugrid,1]);
            temp_fun_EVH2_prime     = griddedInterpolant(temp_A_prime_grid, temp_EVH2_prime_grid);
            
            %%%%%%%%%%%%%%%%
            % Case I: H2>0 %
            %%%%%%%%%%%%%%%%
        
            %   Solve for H1:  
            %   -initialize optimal log male hours per point on the asset grid:
            temp_x0 = zeros(nAgrid,1);
            %   -declare first order condition (involves marginal rate of 
            %    substitution between male hours and consumption, considering 
            %    also the marginal rate of substitution between male and female
            %    hours); request root with respect to log male hours:
            f = @(x) fun_foc_HH_s(x, temp_C_grid, temp_W1, temp_W2, par, 1);
            [temp_x_star,~,temp_exitflag] = fsolve(f, temp_x0, options);
            %   -report if there is no solution:
            if temp_exitflag~=1
                disp(['fsolve failed at ', '[',num2str([iF,iu,it]),'],',' exitflag=',num2str(temp_exitflag)])
            end
            temp_H1_grid = exp(temp_x_star);

            %   Solve for H2, given male hours, using marginal rate of 
            %   substitution between male and female hours, i.e.
            %       u'(H2) = u'(H1)*(W2/W1):
            temp_H2_grid = ((par.psi1*temp_W2)/(par.psi2*temp_W1))^par.eta2 * temp_H1_grid.^(par.eta2/par.eta1);
            %   -obtain before tax household income given wages and hours:   
            temp_Y_grid = temp_W1*temp_H1_grid + temp_W2*temp_H2_grid;
            %   -use budget constraint to obtain current asset grid:
            temp_A_grid = (temp_C_grid + temp_A_prime_grid - (1-par.chi)*temp_Y_grid.^(1-par.mu) + par.tau_ss*temp_Y_grid) / (1+par.r);
        
            %   Interpolate over current asset grid to obtain policy for 
            %   future assets and male hours:
            %   -obtain interpolation objects - ensuring asset grid is in order:
            [~,temp_ind_order] = sort(temp_A_grid,1);
            temp_fun_A_prime        = griddedInterpolant(temp_A_grid(temp_ind_order), temp_A_prime_grid(temp_ind_order));
            temp_fun_H1             = griddedInterpolant(temp_A_grid(temp_ind_order), temp_H1_grid(temp_ind_order));
            %   -interpolate over current asset grid:
            temp_policy_A_prime_fw  = temp_fun_A_prime(temp_Agrid_it);
            temp_policy_H1_fw       = temp_fun_H1(temp_Agrid_it);
        
            %   Check whether borrowing constraint is binding - the 
            %   borrowing constraint may bind in lower parts of asset grid; 
            %   specifically in the first 'sum(temp_ind_binding)' items 
            %   of the grid:
            temp_ind_binding = (temp_Agrid_it<temp_A_grid(1,1));
            if sum(temp_ind_binding)>0
                %   - generate starting vector of log male hours, of length 
                %     equal to the number of points on the asset grid for 
                %     which the borrowing constraint binds, and make it  
                %     equal to male hours at the lowest point of asset grid:
                temp_x0 = log(temp_H1_grid(1,1))*ones(sum(temp_ind_binding),1);
                %   - declare first order condition (involves marginal rate of 
                %     substitution between male hours and consumption, 
                %     considering also the marginal rate of substitution
                %     between male and female hours, and that future assets are 
                %     at lowest point over lowest 'sum(temp_ind_binding)' items
                %     on current asset grid): 
                f = @(x)fun_foc_HH_s_bc(x, temp_Agrid_it(temp_ind_binding), temp_A_prime_grid(1,1), temp_W1, temp_W2,par, 1);
                %   - request root with respect to log male hours:
                [temp_x_star,~,temp_exitflag]=fsolve(f, temp_x0, options_bc);            
                if temp_exitflag~=1
                    disp(['fsolve failed (BC) at ', '[',num2str([iF,iu,it]),'],',' exitflag=',num2str(temp_exitflag)])
                end
                temp_policy_H1_fw(temp_ind_binding)         = exp(temp_x_star);
                temp_policy_A_prime_fw(temp_ind_binding)    = temp_A_prime_grid(1,1);
            end

            %   Given assesment of binding budget constraint or not, 
            %   assemble policy functions at time it:
            %   -for female hours given marginal rate of substitution with male hours:
            temp_policy_H2_fw   = ((par.psi1*temp_W2)/(par.psi2*temp_W1))^par.eta2 * temp_policy_H1_fw.^(par.eta2/par.eta1);
            %   -pre-tax household income given choice of hours:
            temp_policy_Y_fw    = temp_W1*temp_policy_H1_fw + temp_W2*temp_policy_H2_fw;
            %   -consumption given marginal rate of substitution with male hours:
            temp_policy_C_fw    = (((1-par.chi)*(1-par.mu)*temp_policy_Y_fw.^(-par.mu)-par.tau_ss)*temp_W1./(par.psi1*temp_policy_H1_fw.^(1/par.eta1))).^(1/par.sigma);
            %   -derivative of value with respect to consumption:
            temp_policy_V_A_fw  = (1+par.r)*temp_policy_C_fw.^(-par.sigma);
            %   -value function at time 'it':
            temp_policy_V_fw    = (temp_policy_C_fw.^(1-par.sigma))/(1-par.sigma) ...
                                - par.psi1*temp_policy_H1_fw.^(1+1/par.eta1)/(1+1/par.eta1) ...
                                - par.psi2*temp_policy_H2_fw.^(1+1/par.eta2)/(1+1/par.eta2) ...
                                - par.f(it)...
                                + temp_fun_EV_prime(temp_policy_A_prime_fw)/(1+par.delta) ;
            %   -value from consumption:
            temp_policy_VC_fw   = (temp_policy_C_fw.^(1-par.sigma))/(1-par.sigma) + temp_fun_EVC_prime(temp_policy_A_prime_fw)/(1+par.delta);
            %   -value from household hours, male hours, female hours:
            temp_policy_VH_fw   = -par.psi1*temp_policy_H1_fw.^(1+1/par.eta1)/(1+1/par.eta1) ...
                                - par.psi2*temp_policy_H2_fw.^(1+1/par.eta2)/(1+1/par.eta2) ...
                                - par.f(it)...
                                + temp_fun_EVH_prime(temp_policy_A_prime_fw)/(1+par.delta);
            temp_policy_VH1_fw  = -par.psi1*temp_policy_H1_fw.^(1+1/par.eta1)/(1+1/par.eta1) + temp_fun_EVH1_prime(temp_policy_A_prime_fw)/(1+par.delta);
            temp_policy_VH2_fw  = -par.psi2*temp_policy_H2_fw.^(1+1/par.eta2)/(1+1/par.eta2) + temp_fun_EVH2_prime(temp_policy_A_prime_fw)/(1+par.delta);
        
            %%%%%%%%%%%%%%%%%
            % Case II: H2=0 %
            %%%%%%%%%%%%%%%%%
            
            if ind.faw==0
                %   Solve for H1:
                %   -initialize optimal log male hours per point on the asset grid:
                temp_x0 = zeros(nAgrid,1);
                %   -declare first order condition (involves marginal rate of 
                %    substitution between male hours and consumption); 
                %    request root with respect to log male hours:
                f = @(x) fun_foc_HH_s(x, temp_C_grid, temp_W1, temp_W2, par, 0);
                [temp_x_star,~,temp_exitflag] = fsolve(f, temp_x0, options);
                %   -report if there is no solution:
                if temp_exitflag~=1
                    disp(['fsolve failed (FNW) at ', '[',num2str([iF,iu,it]),'],',' exitflag=',num2str(temp_exitflag)])
                end
                temp_H1_grid = exp(temp_x_star);

                %   Declare zero female hours (female does not work):
                temp_H2_grid = zeros(size(temp_H1_grid));
                %   -obtain before tax household income given wages and hours:
                temp_Y_grid = temp_W1*temp_H1_grid + temp_W2*temp_H2_grid;
                %   -use budget constraint to obtain current asset grid:
                temp_A_grid = (temp_C_grid + temp_A_prime_grid - (1-par.chi)*temp_Y_grid.^(1-par.mu) + par.tau_ss*temp_Y_grid) / (1+par.r);

                %   Interpolate over current asset grid to obtain policy for 
                %   future assets and male hours:
                %   -obtain interpolation objects - ensuring asset grid is in order:
                [~,temp_ind_order]      = sort(temp_A_grid,1);
                temp_fun_A_prime        = griddedInterpolant(temp_A_grid(temp_ind_order), temp_A_prime_grid(temp_ind_order));
                temp_fun_H1             = griddedInterpolant(temp_A_grid(temp_ind_order), temp_H1_grid(temp_ind_order));
                %   -interpolate over current asset grid:
                temp_policy_A_prime_fnw = temp_fun_A_prime(temp_Agrid_it);
                temp_policy_H1_fnw      = temp_fun_H1(temp_Agrid_it);

                %   Check whether borrowing constraint is binding - the borrowing
                %   constraint may bind in lower parts of asset grid; specifically
                %   in the first 'sum(temp_ind_binding)' items of the grid:
                temp_ind_binding = (temp_Agrid_it<temp_A_grid(1,1));
                if sum(temp_ind_binding)>0
                    %   - generate starting vector of log male hours, of length 
                    %     equal to the number of points on the asset grid for which
                    %     which the borrowing constraint binds, and make it 
                    %     equal to male hours at the lowest point of asset grid:
                    temp_x0 = log(temp_H1_grid(1,1))*ones(sum(temp_ind_binding),1);
                    %   - declare first order condition (involves marginal rate of 
                    %     substitution between male hours and consumption, and that 
                    %     future assets are at lowest point over lowest 
                    %     'sum(temp_ind_binding)' items on current asset grid):
                    f = @(x) fun_foc_HH_s_bc(x, temp_Agrid_it(temp_ind_binding), temp_A_prime_grid(1,1), temp_W1, temp_W2, par, 0);
                    [temp_x_star,~,temp_exitflag] = fsolve(f, temp_x0, options_bc);
                    if temp_exitflag~=1
                        disp(['fsolve failed (FNW BC) at ', '[',num2str([iF,iu,it]),'],',' exitflag=',num2str(temp_exitflag)])
                    end
                    temp_policy_H1_fnw(temp_ind_binding)        = exp(temp_x_star);
                    temp_policy_A_prime_fnw(temp_ind_binding)   = temp_A_prime_grid(1,1);
                end

                %   Given assesment of binding budget constraint or not, 
                %   assemble policy functions at time it:
                %   -for female hours (zero; female does not work): 
                temp_policy_H2_fnw  = zeros(size(temp_policy_H1_fnw));
                %   -pre-tax household income given choice of hours:
                temp_policy_Y_fnw   = temp_W1*temp_policy_H1_fnw + temp_W2*temp_policy_H2_fnw;
                %   -consumption given marginal rate of substitution with male hours:
                temp_policy_C_fnw   = (((1-par.chi)*(1-par.mu)*temp_policy_Y_fnw.^(-par.mu)-par.tau_ss)*temp_W1./(par.psi1*temp_policy_H1_fnw.^(1/par.eta1))).^(1/par.sigma);
                %   -derivative of value with respect to consumption:
                temp_policy_V_A_fnw = (1+par.r)*temp_policy_C_fnw.^(-par.sigma);
                %   -value function at time 'it':
                temp_policy_V_fnw   = (temp_policy_C_fnw.^(1-par.sigma))/(1-par.sigma) ...
                                    - par.psi1*temp_policy_H1_fnw.^(1+1/par.eta1)/(1+1/par.eta1) ...
                                    - par.psi2*temp_policy_H2_fnw.^(1+1/par.eta2)/(1+1/par.eta2) ...
                                    + temp_fun_EV_prime(temp_policy_A_prime_fnw)/(1+par.delta);
                %   -value from consumption:
                temp_policy_VC_fnw  = (temp_policy_C_fnw.^(1-par.sigma))/(1-par.sigma) + temp_fun_EVC_prime(temp_policy_A_prime_fnw)/(1+par.delta);
                %   -value from household hours, male hours, female hours:
                temp_policy_VH_fnw  = -par.psi1*temp_policy_H1_fnw.^(1+1/par.eta1)/(1+1/par.eta1) ...
                                    - par.psi2*temp_policy_H2_fnw.^(1+1/par.eta2)/(1+1/par.eta2) ...
                                    + temp_fun_EVH_prime(temp_policy_A_prime_fnw)/(1+par.delta);
                temp_policy_VH1_fnw = -par.psi1*temp_policy_H1_fnw.^(1+1/par.eta1)/(1+1/par.eta1) + temp_fun_EVH1_prime(temp_policy_A_prime_fnw)/(1+par.delta);
                temp_policy_VH2_fnw = -par.psi2*temp_policy_H2_fnw.^(1+1/par.eta2)/(1+1/par.eta2) + temp_fun_EVH2_prime(temp_policy_A_prime_fnw)/(1+par.delta);
            end %ind.faw==0
        
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Compare two cases: female work vs female non-work           %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            if ind.faw==0
                
                %   Obtain indexes for which value while female works is higher 
                %   than value while she does not work:
                temp_ind_H2                     = (temp_policy_V_fw>temp_policy_V_fnw);

                %   Populate value functions given values of female work and not work: 
                sliced_policy_H1(:,iFiu,it)     = temp_ind_H2.*temp_policy_H1_fw        + (1-temp_ind_H2).*temp_policy_H1_fnw;
                sliced_policy_H2(:,iFiu,it)     = temp_ind_H2.*temp_policy_H2_fw        + (1-temp_ind_H2).*temp_policy_H2_fnw;
                sliced_policy_C(:,iFiu,it)      = temp_ind_H2.*temp_policy_C_fw         + (1-temp_ind_H2).*temp_policy_C_fnw;
                sliced_policy_A_prime(:,iFiu,it)= temp_ind_H2.*temp_policy_A_prime_fw   + (1-temp_ind_H2).*temp_policy_A_prime_fnw;
                sliced_policy_V_A(:,iFiu,it)    = temp_ind_H2.*temp_policy_V_A_fw       + (1-temp_ind_H2).*temp_policy_V_A_fnw;
                sliced_policy_V(:,iFiu,it)      = temp_ind_H2.*temp_policy_V_fw         + (1-temp_ind_H2).*temp_policy_V_fnw;
                sliced_policy_VC(:,iFiu,it)     = temp_ind_H2.*temp_policy_VC_fw        + (1-temp_ind_H2).*temp_policy_VC_fnw;
                sliced_policy_VH(:,iFiu,it)     = temp_ind_H2.*temp_policy_VH_fw        + (1-temp_ind_H2).*temp_policy_VH_fnw;
                sliced_policy_VH1(:,iFiu,it)    = temp_ind_H2.*temp_policy_VH1_fw       + (1-temp_ind_H2).*temp_policy_VH1_fnw;
                sliced_policy_VH2(:,iFiu,it)    = temp_ind_H2.*temp_policy_VH2_fw       + (1-temp_ind_H2).*temp_policy_VH2_fnw;
                
            else
                
                %   Populate value functions: 
                sliced_policy_H1(:,iFiu,it)     = temp_policy_H1_fw        ;
                sliced_policy_H2(:,iFiu,it)     = temp_policy_H2_fw        ;
                sliced_policy_C(:,iFiu,it)      = temp_policy_C_fw         ;
                sliced_policy_A_prime(:,iFiu,it)= temp_policy_A_prime_fw   ;
                sliced_policy_V_A(:,iFiu,it)    = temp_policy_V_A_fw       ;
                sliced_policy_V(:,iFiu,it)      = temp_policy_V_fw         ;
                sliced_policy_VC(:,iFiu,it)     = temp_policy_VC_fw        ;
                sliced_policy_VH(:,iFiu,it)     = temp_policy_VH_fw        ;
                sliced_policy_VH1(:,iFiu,it)    = temp_policy_VH1_fw       ;
                sliced_policy_VH2(:,iFiu,it)    = temp_policy_VH2_fw       ;
                
            end %ind.faw
        end
        
        %   Report progress:
        fprintf('Finished Lifecycle model period: %u\n',it)
    end
 
    %%  4.  RESHAPE AND EXPORT POLICY FUNCTIONS
    %   -----------------------------------------------------------------------

    % Policy functions:
    policy_H1       = reshape(sliced_policy_H1,     [nAgrid,nFgrid,nugrid,par.R]);
    policy_H2       = reshape(sliced_policy_H2,     [nAgrid,nFgrid,nugrid,par.R]);
    policy_C        = reshape(sliced_policy_C,      [nAgrid,nFgrid,nugrid,par.R]);
    policy_A_prime  = reshape(sliced_policy_A_prime,[nAgrid,nFgrid,nugrid,par.R]);
    policy_V        = reshape(sliced_policy_V,      [nAgrid,nFgrid,nugrid,par.R]);
    policy_VC       = reshape(sliced_policy_VC,     [nAgrid,nFgrid,nugrid,par.R]);
    policy_VH       = reshape(sliced_policy_VH,     [nAgrid,nFgrid,nugrid,par.R]);
    policy_VH1      = reshape(sliced_policy_VH1,    [nAgrid,nFgrid,nugrid,par.R]);
    policy_VH2      = reshape(sliced_policy_VH2,    [nAgrid,nFgrid,nugrid,par.R]);
end