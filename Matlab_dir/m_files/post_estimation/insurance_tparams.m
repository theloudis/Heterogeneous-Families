function [tpv, tpu] = insurance_tparams(prefs, pi, es, cyratios, e_c_p)
%{  
    This function calculates the consumption partial insurance parameters 
    against permanent and transitory wage shocks accepting arguments:
 
        -prefs:     preference parameters; may be the estimated parameter 
                    vector or an array of #num_pref_rdraws agents across 
                    #num_pref_sims populations
        -pi:        partial insurance parameter 'pi'
        -es:        human wealth parameter 'es'
        -cyratios:  consumption/earnings ratios
        -e_c_p:     consumption substitution elasticity eta_c_p

    Alexandros Theloudis
    -----------------------------------------------------------------------
%}

%   Initial statements:
global num_pref_rdraws num_pref_sims min_abs_denom_epsilon ;


%%  1.  DECLARE PARAMETERS
%   Dclare preference and partial insurance parameters.
%   -----------------------------------------------------------------------

%   Declare preference draws by parameter name:
e_c_w1   = prefs(1,:,:) ;   
e_c_w2   = prefs(2,:,:) ;  
e_h1_w1  = prefs(3,:,:) ;
e_h2_w2  = prefs(4,:,:) ; 

%   Declare human-wealth parameters:
es1 = es ;
es2 = 1-es ;

%   Declare reciprocal elasticities:
%   Symmetry of the Frisch matrix of substitution effects implies that
%       e_h1_p = - e_c_w1 * (PC/Y1)
%       e_h2_p = - e_c_w2 * (PC/Y2)
e_h1_p = -e_c_w1 * cyratios(1) ;
e_h2_p = -e_c_w2 * cyratios(2) ;

%   Declare sums of elasticities:
e_h1_w2     = 0.0 ;
e_h2_w1     = 0.0 ;
e_c         = e_c_w1 + e_c_w2 + e_c_p ;
e_h1        = e_h1_w1 + e_h1_w2 + e_h1_p ;
e_h2        = e_h2_w1 + e_h2_w2 + e_h2_p ;

%   Construct quasi-reduced-form parameters 'epsilon':
denom       = e_c - (1-pi).*(es1.*e_h1 + es2.*e_h2) ;
epsilon_1   = ((1-pi).*(es1.*(1+e_h1_w1) + es2.*e_h2_w1) - e_c_w1) ./ denom ;
epsilon_2   = ((1-pi).*(es1.*e_h1_w2 + es2.*(1+e_h2_w2)) - e_c_w2) ./ denom ;

%   Verify that if inputs and outputs are arrays, then they all have the 
%   right dimensions:
matrices = {e_c_w1 e_c_w2 e_h1_w1 e_h2_w2 ...
            es1 es2 pi e_h1_p e_h2_p e_c e_h1 e_h2 ...
            denom epsilon_1 epsilon_2} ;
for i=1:1:length(matrices)
    if length(matrices{i})>1 && (size(matrices{i},1)~=1 || size(matrices{i},2)~=num_pref_rdraws || size(matrices{i},3)~=num_pref_sims)
        error('Error with the size of parameter matrices in the perm_inequality function.')
    end
end


%%  2.  BUILD CONSUMPTION PARTIAL DERIVATIVE WRT PERMANENT SHOCKS
%   Build the partial derivative of consumption growth with respect to 
%   male and female permanent shocks.
%   -----------------------------------------------------------------------

%   Construct partial derivatives (i.e. transmission parameters) of 
%   permanent shocks dDc/dv1 and dDc/dv2:
tpv1 = e_c_w1 + e_c.*epsilon_1 ;
tpv2 = e_c_w2 + e_c.*epsilon_2 ;

%   For some households the partial derivatives may be mechanically very
%   large as 'epsilon' = Inf due to 'denom' being near zero. I replace such 
%   entries by NaN as I consider them to not reflect true behavior. 
%   Note: I put the threshold at global variable 'min_abs_denom_epsilon' 
%   but the results are unchanged if I shrink further the window around 0.
tpv1(denom>-min_abs_denom_epsilon&denom<min_abs_denom_epsilon) = NaN ;
tpv2(denom>-min_abs_denom_epsilon&denom<min_abs_denom_epsilon) = NaN ;

%   Place transmission parameters into a single array:
tpv = {tpv1,tpv2} ;


%%  3.  BUILD CONSUMPTION PARTIAL DERIVATIVE WRT TRANSITORY SHOCKS
%   Build the partial derivative of consumption growth with respect to 
%   male and female transitory shocks.
%   -----------------------------------------------------------------------

%   Construct partial derivatives (i.e. transmission parameters) of 
%   transitory shocks dDc/du1 and dDc/du2:
tpu1 = e_c_w1 ;
tpu2 = e_c_w2 ;

%   Place transmission parameters into a single array:
tpu = {tpu1,tpu2} ;

end