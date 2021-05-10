function [econ_permCIneq, num_replacements, econ_transCIneq] = ...
    inequality_fit(simprefs, simpi, simes, simcyratios, vwages, e_c_p)
%{  
    This function calculates permanent consumption inequality and 
    consumption instability cross populations of households accepting arguments: 
        -simprefs:      preference parameters of #num_pref_rdraws households in
                        #num_pref_sims populations
        -simpi:         partial insurance parameters 'pi' for those households
        -simes:         human wealth parameters 'es' for those households
        -simcyratios:   consumption/earnings ratios
        -vwages:        estimated second moments of wages
        -e_c_p:         consumption substitution elasticity eta_c_p
    
    The function returns permanent consumption inequality and consumption 
    instability across #num_pref_sims populations. It also returns the
    number of households with extreme permanent inequality as a result of
    dividing by zero (this happens mechanically in a few cases; I replace
    these households with NaN).

    Alexandros Theloudis
    -----------------------------------------------------------------------
%}

%   Initial statements:
global num_pref_rdraws min_abs_denom_epsilon num_pref_sims



%%  1.  DECLARE PARAMETERS
%   Dclare wage, preference, and partial insurance parameters.
%   -----------------------------------------------------------------------

%   Declare estimated wage parameters:
vH  = vwages(1)   ;
uH  = vwages(6)  ;
vW  = vwages(12) ;
uW  = vwages(17) ;
vHW = vwages(23) ;   
uHW = vwages(28) ;

%   Note: All following matrices of parameters are 
%       1 x num_pref_rdraws x num_pref_sims
%   Declare preference draws by parameter name:
e_c_w1   = simprefs(1,:,:) ;   
e_c_w2   = simprefs(2,:,:) ;  
e_h1_w1  = simprefs(3,:,:) ;
e_h2_w2  = simprefs(4,:,:) ; 

%   Declare human-wealth parameters:
es1 = simes ;
es2 = 1-simes ;

%   Declare reciprocal elasticities:
%   Symmetry of the Frisch matrix of substitution effects implies that
%       e_h1_p = - e_c_w1 * (PC/Y1)
%       e_h2_p = - e_c_w2 * (PC/Y2)
pcy1 = simcyratios(1) ;
pcy2 = simcyratios(2) ;
e_h1_p = -e_c_w1 * pcy1 ;
e_h2_p = -e_c_w2 * pcy2 ;

%   Declare sums of elasticities:
e_h1_w2 = 0.0 ;
e_h2_w1 = 0.0 ;
e_c   = e_c_w1 + e_c_w2 + e_c_p ;
e_h1  = e_h1_w1 + e_h1_w2 + e_h1_p ;
e_h2  = e_h2_w1 + e_h2_w2 + e_h2_p ;

%   Construct quasi-reduced-form parameters 'epsilon':
denom     = e_c - (1-simpi).*(es1.*e_h1 + es2.*e_h2) ;
epsilon_1 = ((1-simpi).*(es1.*(1+e_h1_w1) + es2.*e_h2_w1) - e_c_w1) ./ denom ;
epsilon_2 = ((1-simpi).*(es1.*e_h1_w2 + es2.*(1+e_h2_w2)) - e_c_w2) ./ denom ;

%   Verify that all matrices have the right dimension:
matrices = {e_c_w1 e_c_w2 e_h1_w1 e_h2_w2 ...
            es1 es2 e_h1_p e_h2_p e_c e_h1 e_h2 ...
            denom epsilon_1 epsilon_2} ;
for i=1:1:length(matrices)
    if size(matrices{i},1) ~= 1 || size(matrices{i},2) ~= num_pref_rdraws || size(matrices{i},3) ~= num_pref_sims
        error('Error with the size of parameter matrices in the perm_inequality function.')
    end
end


%%  2.  CALCULATE PERMANENT INEQUALITY
%   Assemble permanent inequality across households and populations.
%   -----------------------------------------------------------------------

%   Initialize matrix to collect results:
indi_permCIneq = zeros(1,num_pref_rdraws,num_pref_sims) ;

%   Calculate 'individual' permanent consumption inequality, i.e. the 
%   square consumption growth per period/household/population:
indi_permCIneq(1,:,:) = (e_c_w1 + e_c.*epsilon_1).^2 * vH ...
                      + (e_c_w2 + e_c.*epsilon_2).^2 * vW ...
                      + 2*(e_c_w1 + e_c.*epsilon_1).*(e_c_w2 + e_c.*epsilon_2) * vHW ;

%   For some households square consumption growth is mechanically very 
%   large because 'epsilon' = Inf due to 'denom' being near zero. 
%   I replace these entries by NaN as I consider them to not reflect true
%   behavior, and I count the number of such replacements:
indi_permCIneq(denom>-min_abs_denom_epsilon&denom<min_abs_denom_epsilon) = NaN ;
num_replacements = reshape(sum(isnan(indi_permCIneq),2),num_pref_sims,1) ;

%   Obtain permanent inequality in each population by calculating the
%   average permanent inequality across households in each population:
econ_permCIneq = reshape(nanmean(indi_permCIneq,2),num_pref_sims,1);


%%  3.  CALCULATE CONSUMPTION INSTABILITY
%   Assemble consumption instability across households and populations.
%   -----------------------------------------------------------------------

%   Allow non-stationary variances/covariances of shocks:
indi_transCIneq = zeros(1,num_pref_rdraws,num_pref_sims) ;

%   Calculate 'individual' consumption instability:
indi_transCIneq(1,:,:) = e_c_w1.^2 * (2*uH) ...
                       + e_c_w2.^2 * (2*uW) ...
                       + 2*e_c_w1.*e_c_w2 * (2*uHW) ;

%   Obtain consumption instability in each population by calculating the
%   average instability across households in each population:
econ_transCIneq = reshape(mean(indi_transCIneq,2),num_pref_sims,1);

end