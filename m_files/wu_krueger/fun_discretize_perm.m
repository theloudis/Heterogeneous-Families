function [ Fgrid, F_transit_mat, F_initial_prob ] = fun_discretize_perm(R, sqrt_nFgrid, F_initial, v, A)

%{ 
    This function creates grids and transition matrices for the permanent 
    wage components over working life. 

    This code is an adaptation to the original code provided by 
    Wu & Krueger (2020), 'Consumption Insurance Against Wage Risk',
    published in AEJ-Macro.

    Alexandros Theloudis
    -----------------------------------------------------------------------
%}


    %   Obtain initial and overall covariance matrix of permanent shocks:
    O.F_initial     = F_initial;
    O.v             = v;

    %   Initialize array to hold age-specific covariance matrix:
    O.F             = ones(size(O.F_initial,1), size(O.F_initial,2), R)*(-99);
    O.F(:,:,1)      = O.F_initial;

    %   Initialize array to hold age-specific grid and transition matrix 
    %   for two spouses:
    nFgrid          = sqrt_nFgrid^2;
    Fgrid           = ones(size(O.F_initial,1), nFgrid, R)*(-99);
    F_transit_mat   = ones(nFgrid, nFgrid, R-1)*(-99);

    %   Start of life.
    %   -------------------------------------------------------------------
    
    %	Obtain grid points and probabilities of one-dimensional 
    %   standard normal grid:
    [temp.zzgrid, temp.zzprob] = fun_tauchen_1d(0, 1, sqrt_nFgrid);

    %	Replicates marginal grid to produce two 2-dimensional grids and 
    %   their indices (one replicates grids vertically, the other horizonatlly):
    [temp.y1, temp.y2]              = ndgrid(temp.zzgrid, temp.zzgrid);
    [temp.y1_index, temp.y2_index]  = ndgrid((1:sqrt_nFgrid)', (1:sqrt_nFgrid)');

    %	Vectorizes 2-dimensional grids - puts them side by side in tuple, 
    %   one for male spouse, another for female spouse:
    ygrid           = [reshape(temp.y1,nFgrid,1), reshape(temp.y2,nFgrid,1)]';
    
    %   Calculates initial joint probability of each tuple - i.e. joint grid point:
    y_initial_prob  = reshape(temp.zzprob(temp.y1_index).*temp.zzprob(temp.y2_index), 1, nFgrid);

    %   Populate start-of-life grid with either zeros (if initial covariance
    %   is zero) or according to standard normal one-dimensional grid, 
    %   adjusted by the initial standard deviation of permanent shocks:
    if sum(sum(O.F(:,:,1)))==0
        Fgrid(:,:,1) = zeros(size(O.F_initial,1), nFgrid);
    else
        Fgrid(:,:,1) = (O.F(:,:,1)^0.5*ygrid);
    end

    %   Marginal probabilities:
    F_initial_prob = y_initial_prob;
    %   -distance between points on grid:
    temp.d = (temp.zzgrid(sqrt_nFgrid,1) - temp.zzgrid(1,1))/(sqrt_nFgrid-1);
    %   -calculates mid-point of grid segments, then places mid-points into
    %    vectors whose bounds are +- infinity, then replicates vectors to 
    %    produce two 2-dimensional grids (one replicates grids vertically,
    %    the other horizonatlly):
    [temp.y1_cutpoint, temp.y2_cutpoint] = ndgrid(  [-inf; temp.zzgrid(1:sqrt_nFgrid-1)+temp.d/2; inf], ...
                                                    [-inf; temp.zzgrid(1:sqrt_nFgrid-1)+temp.d/2; inf]);
    %   -grid segment bounds for two dimensional standard normal, with
    %    number of grids segments equal to 'nFgrid' (this will be used to
    %    calculate joint probability to be in each grid segment):
    y_cutgrid = [   reshape(temp.y1_cutpoint,(sqrt_nFgrid+1)^2,1), ...
                    reshape(temp.y2_cutpoint,(sqrt_nFgrid+1)^2,1)]' ;
    
    %   Remaining working life.
    %   -------------------------------------------------------------------
    
    %   Loop over work life:
    for i=1:(R-1)

        %   Obtain next period's covariance matrix of permanent component - 
        %   multiplication by 'A' ensures stationarity of the covariance:
        O.F(:,:,i+1)    = A*O.F(:,:,i)*A' + O.v;
        %   -obtain standard deviation of permanent components:
        temp.P          = O.F(:,:,i+1)^0.5;
        %   -Sigma matrix of multivariate standard normal cdf:
        temp.Oz         = temp.P\O.v/(temp.P');

        %   Populate next period's grid - adjust joint standard normal by 
        %   current standard deviation of permanent component:
        Fgrid(:,:,i+1)=temp.P*ygrid;
        
        %   Populate transition matrix:
        for j=1:nFgrid
            % -given point on current grid, generate future grid endpoints
            %  so that they reflect the probability of transitioning from
            %  current grid point to next one; calculate probability by
            %  means of differencing multivariate normal cdf:
            temp.yy_cutgrid         = y_cutgrid-(temp.P\A*Fgrid(:,j,i))*ones(1,size(y_cutgrid,2));
            F_transit_mat(j,:,i)    = reshape(diff(diff(reshape( ...
                                        mvncdf(temp.yy_cutgrid',zeros(1,size(temp.Oz,1)),temp.Oz), ...
                                        sqrt_nFgrid+1, sqrt_nFgrid+1),1,1),1,2),1,nFgrid);
            
            %   Replace with zero if transition probability slightly lower than zero:
            F_transit_mat(j,F_transit_mat(j,:,i)<0,i) = 0;
        end %j=1:nFgrid
    end %i=1:(R-1)

end