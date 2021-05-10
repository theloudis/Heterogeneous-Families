function f = model_structure(vParams, vWages, mC, mCD, mCes, mCpi, merrC, ...
                    higher_moments, preference_heterogeneity, start_j, v_err_c, labor_xeta, type_wmatrix)
%{  
    This function generates the moments conditions for the estimation of 
    the structural model with and without preference heterogeneity.

    Alexandros Theloudis
    -----------------------------------------------------------------------
%}

%   Initial statements:
global T ;


%%  1.  INITIALIZE OBJECTS
%   Initialize parameters and vectors to hold moments
%   -----------------------------------------------------------------------

%   Vector of pre-estimated wage parameters:
%   Second moments of wage parameters (required for all specifications):
vH  = vWages(1:5)  ;        % variance:    permanent shock HD
uH  = vWages(6:11) ;        % variance:    transitory shock HD
vW  = vWages(12:16) ;       % variance:    permanent shock WF
uW  = vWages(17:22) ;       % variance:    transitory shock WF
vHW = vWages(23:27) ;       % covariance:  permanent shocks
uHW = vWages(28:33) ;       % covariance:  transitory shocks

%   Third moments of wage parameters (required for heterogeneity):
if higher_moments >= 1
    guH   = vWages(50:55) ; % skewness:    transitory shock HD
    guW   = vWages(61:66) ; % skewness:    transitory shock WF
    guH2W = vWages(72:77) ; % third cross moment: E[uH^2 uW]
    guHW2 = vWages(83:88) ; % third cross moment: E[uH uW^2]
end

%   Vector of structural parameters:
%   First moments of parameters (always estimated across all specifications):
eta_c_w1  = vParams(1)  ;               % consumption wrt wage1
eta_c_w2  = vParams(2)  ;               % consumption wrt wage2
eta_h1_w1 = vParams(3)  ;               % hours1 wrt wage1

if isequal(labor_xeta,'off') ~= 1
    
    %   First moments of parameters:
    eta_h1_w2 = vParams(4)  ;           % hours1 wrt wage2
    eta_h2_w1 = vParams(5)  ;           % hours2 wrt wage1
    eta_h2_w2 = vParams(6)  ;           % hours2 wrt wage2

    %   First moments of parameters identified in BPS specification only:
    if      higher_moments == -1   
        eta_c_p             = -0.45 ;   % consumption wrt price (fixed at -0.45) 
        eta_h1_p            = vParams(7);%hours1 wrt price
        eta_h2_p            = vParams(8);%hours2 wrt price
        Vcons_err           = v_err_c ; % variance of consumption measurement error (not identified)
        Veta_c_w1           = 0.0 ;     % consumption wrt wage1
        Veta_c_w2           = 0.0 ;     % consumption wrt wage2
        Veta_h1_w1          = 0.0 ;     % hours1 wrt wage1
        Veta_h1_w2          = 0.0 ;     % hours1 wrt wage2
        Veta_h2_w1          = 0.0 ;     % hours2 wrt wage1
        Veta_h2_w2          = 0.0 ;     % hours2 wrt wage2
        COVeta_c_w1_c_w2    = 0.0 ;     % consumption wrt wage1 ~ consumption wrt wage2
        COVeta_c_w1_h1_w1   = 0.0 ;     % consumption wrt wage1 ~ hours1 wrt wage1
        COVeta_c_w1_h1_w2   = 0.0 ;     % consumption wrt wage1 ~ hours1 wrt wage2
        COVeta_c_w1_h2_w1   = 0.0 ;     % consumption wrt wage1 ~ hours2 wrt wage1
        COVeta_c_w1_h2_w2   = 0.0 ;     % consumption wrt wage1 ~ hours2 wrt wage2
        COVeta_c_w2_h1_w1   = 0.0 ;     % consumption wrt wage2 ~ hours1 wrt wage1
        COVeta_c_w2_h1_w2   = 0.0 ;     % consumption wrt wage2 ~ hours1 wrt wage2
        COVeta_c_w2_h2_w1   = 0.0 ;     % consumption wrt wage2 ~ hours2 wrt wage1
        COVeta_c_w2_h2_w2   = 0.0 ;     % consumption wrt wage2 ~ hours2 wrt wage2
        COVeta_h1_w1_h1_w2  = 0.0 ;     % hours1 wrt wage1 ~ hours1 wrt wage2
        COVeta_h1_w1_h2_w1  = 0.0 ;     % hours1 wrt wage1 ~ hours2 wrt wage1
        COVeta_h1_w1_h2_w2  = 0.0 ;     % hours1 wrt wage1 ~ hours2 wrt wage2
        COVeta_h1_w2_h2_w1  = 0.0 ;     % hours1 wrt wage2 ~ hours2 wrt wage1
        COVeta_h1_w2_h2_w2  = 0.0 ;     % hours1 wrt wage2 ~ hours2 wrt wage2
        COVeta_h2_w1_h2_w2  = 0.0 ;     % hours2 wrt wage1 ~ hours2 wrt wage2 
        
    elseif higher_moments == 0
        Vcons_err           = v_err_c ; % variance of consumption measurement error
        Veta_c_w1           = 0.0 ;     % consumption wrt wage1
        Veta_c_w2           = 0.0 ;     % consumption wrt wage2
        Veta_h1_w1          = 0.0 ;     % hours1 wrt wage1
        Veta_h1_w2          = 0.0 ;     % hours1 wrt wage2
        Veta_h2_w1          = 0.0 ;     % hours2 wrt wage1
        Veta_h2_w2          = 0.0 ;     % hours2 wrt wage2
        COVeta_c_w1_c_w2    = 0.0 ;     % consumption wrt wage1 ~ consumption wrt wage2
        COVeta_c_w1_h1_w1   = 0.0 ;     % consumption wrt wage1 ~ hours1 wrt wage1
        COVeta_c_w1_h1_w2   = 0.0 ;     % consumption wrt wage1 ~ hours1 wrt wage2
        COVeta_c_w1_h2_w1   = 0.0 ;     % consumption wrt wage1 ~ hours2 wrt wage1
        COVeta_c_w1_h2_w2   = 0.0 ;     % consumption wrt wage1 ~ hours2 wrt wage2
        COVeta_c_w2_h1_w1   = 0.0 ;     % consumption wrt wage2 ~ hours1 wrt wage1
        COVeta_c_w2_h1_w2   = 0.0 ;     % consumption wrt wage2 ~ hours1 wrt wage2
        COVeta_c_w2_h2_w1   = 0.0 ;     % consumption wrt wage2 ~ hours2 wrt wage1
        COVeta_c_w2_h2_w2   = 0.0 ;     % consumption wrt wage2 ~ hours2 wrt wage2
        COVeta_h1_w1_h1_w2  = 0.0 ;     % hours1 wrt wage1 ~ hours1 wrt wage2
        COVeta_h1_w1_h2_w1  = 0.0 ;     % hours1 wrt wage1 ~ hours2 wrt wage1
        COVeta_h1_w1_h2_w2  = 0.0 ;     % hours1 wrt wage1 ~ hours2 wrt wage2
        COVeta_h1_w2_h2_w1  = 0.0 ;     % hours1 wrt wage2 ~ hours2 wrt wage1
        COVeta_h1_w2_h2_w2  = 0.0 ;     % hours1 wrt wage2 ~ hours2 wrt wage2
        COVeta_h2_w1_h2_w2  = 0.0 ;     % hours2 wrt wage1 ~ hours2 wrt wage2 
    
    elseif higher_moments == 1
        if      preference_heterogeneity == 0
            Veta_c_w1           = 0.0 ;         % consumption wrt wage1
            Veta_c_w2           = 0.0 ;         % consumption wrt wage2
            Veta_h1_w1          = 0.0 ;         % hours1 wrt wage1
            Veta_h1_w2          = 0.0 ;         % hours1 wrt wage2
            Veta_h2_w1          = 0.0 ;         % hours2 wrt wage1
            Veta_h2_w2          = 0.0 ;         % hours2 wrt wage2
            COVeta_c_w1_c_w2    = 0.0 ;         % consumption wrt wage1 ~ consumption wrt wage2
            COVeta_c_w1_h1_w1   = 0.0 ;         % consumption wrt wage1 ~ hours1 wrt wage1
            COVeta_c_w1_h1_w2   = 0.0 ;         % consumption wrt wage1 ~ hours1 wrt wage2
            COVeta_c_w1_h2_w1   = 0.0 ;         % consumption wrt wage1 ~ hours2 wrt wage1
            COVeta_c_w1_h2_w2   = 0.0 ;         % consumption wrt wage1 ~ hours2 wrt wage2
            COVeta_c_w2_h1_w1   = 0.0 ;         % consumption wrt wage2 ~ hours1 wrt wage1
            COVeta_c_w2_h1_w2   = 0.0 ;         % consumption wrt wage2 ~ hours1 wrt wage2
            COVeta_c_w2_h2_w1   = 0.0 ;         % consumption wrt wage2 ~ hours2 wrt wage1
            COVeta_c_w2_h2_w2   = 0.0 ;         % consumption wrt wage2 ~ hours2 wrt wage2
            COVeta_h1_w1_h1_w2  = 0.0 ;         % hours1 wrt wage1 ~ hours1 wrt wage2
            COVeta_h1_w1_h2_w1  = 0.0 ;         % hours1 wrt wage1 ~ hours2 wrt wage1
            COVeta_h1_w1_h2_w2  = 0.0 ;         % hours1 wrt wage1 ~ hours2 wrt wage2
            COVeta_h1_w2_h2_w1  = 0.0 ;         % hours1 wrt wage2 ~ hours2 wrt wage1
            COVeta_h1_w2_h2_w2  = 0.0 ;         % hours1 wrt wage2 ~ hours2 wrt wage2
            COVeta_h2_w1_h2_w2  = 0.0 ;         % hours2 wrt wage1 ~ hours2 wrt wage2 
        elseif  preference_heterogeneity == 1
            Veta_c_w1           = vParams(7)  ; % consumption wrt wage1
            Veta_c_w2           = vParams(8)  ; % consumption wrt wage2
            Veta_h1_w1          = vParams(9)  ; % hours1 wrt wage1
            Veta_h1_w2          = vParams(10) ; % hours1 wrt wage2
            Veta_h2_w1          = vParams(11) ; % hours2 wrt wage1
            Veta_h2_w2          = vParams(12) ; % hours2 wrt wage2
            COVeta_c_w1_c_w2    = 0.0 ;         % consumption wrt wage1 ~ consumption wrt wage2
            COVeta_c_w1_h1_w1   = 0.0 ;         % consumption wrt wage1 ~ hours1 wrt wage1
            COVeta_c_w1_h1_w2   = 0.0 ;         % consumption wrt wage1 ~ hours1 wrt wage2
            COVeta_c_w1_h2_w1   = 0.0 ;         % consumption wrt wage1 ~ hours2 wrt wage1
            COVeta_c_w1_h2_w2   = 0.0 ;         % consumption wrt wage1 ~ hours2 wrt wage2
            COVeta_c_w2_h1_w1   = 0.0 ;         % consumption wrt wage2 ~ hours1 wrt wage1
            COVeta_c_w2_h1_w2   = 0.0 ;         % consumption wrt wage2 ~ hours1 wrt wage2
            COVeta_c_w2_h2_w1   = 0.0 ;         % consumption wrt wage2 ~ hours2 wrt wage1
            COVeta_c_w2_h2_w2   = 0.0 ;         % consumption wrt wage2 ~ hours2 wrt wage2
            COVeta_h1_w1_h1_w2  = 0.0 ;         % hours1 wrt wage1 ~ hours1 wrt wage2
            COVeta_h1_w1_h2_w1  = 0.0 ;         % hours1 wrt wage1 ~ hours2 wrt wage1
            COVeta_h1_w1_h2_w2  = 0.0 ;         % hours1 wrt wage1 ~ hours2 wrt wage2
            COVeta_h1_w2_h2_w1  = vParams(13) ; % hours1 wrt wage2 ~ hours2 wrt wage1
            COVeta_h1_w2_h2_w2  = 0.0 ;         % hours1 wrt wage2 ~ hours2 wrt wage2
            COVeta_h2_w1_h2_w2  = 0.0 ;         % hours2 wrt wage1 ~ hours2 wrt wage2 
        elseif  preference_heterogeneity == 2
            Veta_c_w1           = vParams(7)  ; % consumption wrt wage1
            Veta_c_w2           = vParams(8)  ; % consumption wrt wage2
            Veta_h1_w1          = vParams(9)  ; % hours1 wrt wage1
            Veta_h1_w2          = vParams(10) ; % hours1 wrt wage2
            Veta_h2_w1          = vParams(11) ; % hours2 wrt wage1
            Veta_h2_w2          = vParams(12) ; % hours2 wrt wage2
            COVeta_c_w1_c_w2    = vParams(13) ; % consumption wrt wage1 ~ consumption wrt wage2
            COVeta_c_w1_h1_w1   = vParams(14) ; % consumption wrt wage1 ~ hours1 wrt wage1
            COVeta_c_w1_h1_w2   = vParams(15) ; % consumption wrt wage1 ~ hours1 wrt wage2
            COVeta_c_w1_h2_w1   = vParams(16) ; % consumption wrt wage1 ~ hours2 wrt wage1
            COVeta_c_w1_h2_w2   = vParams(17) ; % consumption wrt wage1 ~ hours2 wrt wage2
            COVeta_c_w2_h1_w1   = vParams(18) ; % consumption wrt wage2 ~ hours1 wrt wage1
            COVeta_c_w2_h1_w2   = vParams(19) ; % consumption wrt wage2 ~ hours1 wrt wage2
            COVeta_c_w2_h2_w1   = vParams(20) ; % consumption wrt wage2 ~ hours2 wrt wage1
            COVeta_c_w2_h2_w2   = vParams(21) ; % consumption wrt wage2 ~ hours2 wrt wage2
            COVeta_h1_w1_h1_w2  = vParams(22) ; % hours1 wrt wage1 ~ hours1 wrt wage2
            COVeta_h1_w1_h2_w1  = vParams(23) ; % hours1 wrt wage1 ~ hours2 wrt wage1
            COVeta_h1_w1_h2_w2  = vParams(24) ; % hours1 wrt wage1 ~ hours2 wrt wage2
            COVeta_h1_w2_h2_w1  = vParams(25) ; % hours1 wrt wage2 ~ hours2 wrt wage1
            COVeta_h1_w2_h2_w2  = vParams(26) ; % hours1 wrt wage2 ~ hours2 wrt wage2
            COVeta_h2_w1_h2_w2  = vParams(27) ; % hours2 wrt wage1 ~ hours2 wrt wage2
        end %preference_heterogeneity
        Vcons_err = v_err_c ;       % variance of consumption measurement error
    end %higher_moments==-1
    
else
    
    %   First moments of parameters:
    eta_h1_w2 = 0.0 ;                   % hours1 wrt wage2
    eta_h2_w1 = 0.0 ;                   % hours2 wrt wage1
    eta_h2_w2 = vParams(4)  ;           % hours2 wrt wage2

    %   First moments of parameters identified in BPS specification only:
    if      higher_moments == -1   
        eta_c_p             = -0.45 ;   % consumption wrt price (fixed at -0.45) 
        eta_h1_p            = vParams(5);%hours1 wrt price
        eta_h2_p            = vParams(6);%hours2 wrt price
        Vcons_err           = v_err_c ; % variance of consumption measurement error (not identified)
        Veta_c_w1           = 0.0 ;     % consumption wrt wage1
        Veta_c_w2           = 0.0 ;     % consumption wrt wage2
        Veta_h1_w1          = 0.0 ;     % hours1 wrt wage1
        Veta_h1_w2          = 0.0 ;     % hours1 wrt wage2
        Veta_h2_w1          = 0.0 ;     % hours2 wrt wage1
        Veta_h2_w2          = 0.0 ;     % hours2 wrt wage2
        COVeta_c_w1_c_w2    = 0.0 ;     % consumption wrt wage1 ~ consumption wrt wage2
        COVeta_c_w1_h1_w1   = 0.0 ;     % consumption wrt wage1 ~ hours1 wrt wage1
        COVeta_c_w1_h1_w2   = 0.0 ;     % consumption wrt wage1 ~ hours1 wrt wage2
        COVeta_c_w1_h2_w1   = 0.0 ;     % consumption wrt wage1 ~ hours2 wrt wage1
        COVeta_c_w1_h2_w2   = 0.0 ;     % consumption wrt wage1 ~ hours2 wrt wage2
        COVeta_c_w2_h1_w1   = 0.0 ;     % consumption wrt wage2 ~ hours1 wrt wage1
        COVeta_c_w2_h1_w2   = 0.0 ;     % consumption wrt wage2 ~ hours1 wrt wage2
        COVeta_c_w2_h2_w1   = 0.0 ;     % consumption wrt wage2 ~ hours2 wrt wage1
        COVeta_c_w2_h2_w2   = 0.0 ;     % consumption wrt wage2 ~ hours2 wrt wage2
        COVeta_h1_w1_h1_w2  = 0.0 ;     % hours1 wrt wage1 ~ hours1 wrt wage2
        COVeta_h1_w1_h2_w1  = 0.0 ;     % hours1 wrt wage1 ~ hours2 wrt wage1
        COVeta_h1_w1_h2_w2  = 0.0 ;     % hours1 wrt wage1 ~ hours2 wrt wage2
        COVeta_h1_w2_h2_w1  = 0.0 ;     % hours1 wrt wage2 ~ hours2 wrt wage1
        COVeta_h1_w2_h2_w2  = 0.0 ;     % hours1 wrt wage2 ~ hours2 wrt wage2
        COVeta_h2_w1_h2_w2  = 0.0 ;     % hours2 wrt wage1 ~ hours2 wrt wage2 
    
    elseif higher_moments == 0
        Vcons_err           = v_err_c ; % variance of consumption measurement error
        Veta_c_w1           = 0.0 ;     % consumption wrt wage1
        Veta_c_w2           = 0.0 ;     % consumption wrt wage2
        Veta_h1_w1          = 0.0 ;     % hours1 wrt wage1
        Veta_h1_w2          = 0.0 ;     % hours1 wrt wage2
        Veta_h2_w1          = 0.0 ;     % hours2 wrt wage1
        Veta_h2_w2          = 0.0 ;     % hours2 wrt wage2
        COVeta_c_w1_c_w2    = 0.0 ;     % consumption wrt wage1 ~ consumption wrt wage2
        COVeta_c_w1_h1_w1   = 0.0 ;     % consumption wrt wage1 ~ hours1 wrt wage1
        COVeta_c_w1_h1_w2   = 0.0 ;     % consumption wrt wage1 ~ hours1 wrt wage2
        COVeta_c_w1_h2_w1   = 0.0 ;     % consumption wrt wage1 ~ hours2 wrt wage1
        COVeta_c_w1_h2_w2   = 0.0 ;     % consumption wrt wage1 ~ hours2 wrt wage2
        COVeta_c_w2_h1_w1   = 0.0 ;     % consumption wrt wage2 ~ hours1 wrt wage1
        COVeta_c_w2_h1_w2   = 0.0 ;     % consumption wrt wage2 ~ hours1 wrt wage2
        COVeta_c_w2_h2_w1   = 0.0 ;     % consumption wrt wage2 ~ hours2 wrt wage1
        COVeta_c_w2_h2_w2   = 0.0 ;     % consumption wrt wage2 ~ hours2 wrt wage2
        COVeta_h1_w1_h1_w2  = 0.0 ;     % hours1 wrt wage1 ~ hours1 wrt wage2
        COVeta_h1_w1_h2_w1  = 0.0 ;     % hours1 wrt wage1 ~ hours2 wrt wage1
        COVeta_h1_w1_h2_w2  = 0.0 ;     % hours1 wrt wage1 ~ hours2 wrt wage2
        COVeta_h1_w2_h2_w1  = 0.0 ;     % hours1 wrt wage2 ~ hours2 wrt wage1
        COVeta_h1_w2_h2_w2  = 0.0 ;     % hours1 wrt wage2 ~ hours2 wrt wage2
        COVeta_h2_w1_h2_w2  = 0.0 ;     % hours2 wrt wage1 ~ hours2 wrt wage2 
    
    elseif higher_moments == 1
        if      preference_heterogeneity == 0
            Veta_c_w1           = 0.0 ;         % consumption wrt wage1
            Veta_c_w2           = 0.0 ;         % consumption wrt wage2
            Veta_h1_w1          = 0.0 ;         % hours1 wrt wage1
            Veta_h1_w2          = 0.0 ;         % hours1 wrt wage2
            Veta_h2_w1          = 0.0 ;         % hours2 wrt wage1
            Veta_h2_w2          = 0.0 ;         % hours2 wrt wage2
            COVeta_c_w1_c_w2    = 0.0 ;         % consumption wrt wage1 ~ consumption wrt wage2
            COVeta_c_w1_h1_w1   = 0.0 ;         % consumption wrt wage1 ~ hours1 wrt wage1
            COVeta_c_w1_h1_w2   = 0.0 ;         % consumption wrt wage1 ~ hours1 wrt wage2
            COVeta_c_w1_h2_w1   = 0.0 ;         % consumption wrt wage1 ~ hours2 wrt wage1
            COVeta_c_w1_h2_w2   = 0.0 ;         % consumption wrt wage1 ~ hours2 wrt wage2
            COVeta_c_w2_h1_w1   = 0.0 ;         % consumption wrt wage2 ~ hours1 wrt wage1
            COVeta_c_w2_h1_w2   = 0.0 ;         % consumption wrt wage2 ~ hours1 wrt wage2
            COVeta_c_w2_h2_w1   = 0.0 ;         % consumption wrt wage2 ~ hours2 wrt wage1
            COVeta_c_w2_h2_w2   = 0.0 ;         % consumption wrt wage2 ~ hours2 wrt wage2
            COVeta_h1_w1_h1_w2  = 0.0 ;         % hours1 wrt wage1 ~ hours1 wrt wage2
            COVeta_h1_w1_h2_w1  = 0.0 ;         % hours1 wrt wage1 ~ hours2 wrt wage1
            COVeta_h1_w1_h2_w2  = 0.0 ;         % hours1 wrt wage1 ~ hours2 wrt wage2
            COVeta_h1_w2_h2_w1  = 0.0 ;         % hours1 wrt wage2 ~ hours2 wrt wage1
            COVeta_h1_w2_h2_w2  = 0.0 ;         % hours1 wrt wage2 ~ hours2 wrt wage2
            COVeta_h2_w1_h2_w2  = 0.0 ;         % hours2 wrt wage1 ~ hours2 wrt wage2 
        elseif  preference_heterogeneity == 1
            Veta_c_w1           = vParams(5)  ; % consumption wrt wage1
            Veta_c_w2           = vParams(6)  ; % consumption wrt wage2
            Veta_h1_w1          = vParams(7)  ; % hours1 wrt wage1
            Veta_h1_w2          = 0.0 ;         % hours1 wrt wage2
            Veta_h2_w1          = 0.0 ;         % hours2 wrt wage1
            Veta_h2_w2          = vParams(8) ;  % hours2 wrt wage2
            COVeta_c_w1_c_w2    = 0.0 ;         % consumption wrt wage1 ~ consumption wrt wage2
            COVeta_c_w1_h1_w1   = 0.0 ;         % consumption wrt wage1 ~ hours1 wrt wage1
            COVeta_c_w1_h1_w2   = 0.0 ;         % consumption wrt wage1 ~ hours1 wrt wage2
            COVeta_c_w1_h2_w1   = 0.0 ;         % consumption wrt wage1 ~ hours2 wrt wage1
            COVeta_c_w1_h2_w2   = 0.0 ;         % consumption wrt wage1 ~ hours2 wrt wage2
            COVeta_c_w2_h1_w1   = 0.0 ;         % consumption wrt wage2 ~ hours1 wrt wage1
            COVeta_c_w2_h1_w2   = 0.0 ;         % consumption wrt wage2 ~ hours1 wrt wage2
            COVeta_c_w2_h2_w1   = 0.0 ;         % consumption wrt wage2 ~ hours2 wrt wage1
            COVeta_c_w2_h2_w2   = 0.0 ;         % consumption wrt wage2 ~ hours2 wrt wage2
            COVeta_h1_w1_h1_w2  = 0.0 ;         % hours1 wrt wage1 ~ hours1 wrt wage2
            COVeta_h1_w1_h2_w1  = 0.0 ;         % hours1 wrt wage1 ~ hours2 wrt wage1
            COVeta_h1_w1_h2_w2  = 0.0 ;         % hours1 wrt wage1 ~ hours2 wrt wage2
            COVeta_h1_w2_h2_w1  = 0.0 ;         % hours1 wrt wage2 ~ hours2 wrt wage1
            COVeta_h1_w2_h2_w2  = 0.0 ;         % hours1 wrt wage2 ~ hours2 wrt wage2
            COVeta_h2_w1_h2_w2  = 0.0 ;         % hours2 wrt wage1 ~ hours2 wrt wage2 
        elseif  preference_heterogeneity >= 2
            Veta_c_w1           = vParams(5)  ; % consumption wrt wage1
            Veta_c_w2           = vParams(6)  ; % consumption wrt wage2
            Veta_h1_w1          = vParams(7)  ; % hours1 wrt wage1
            Veta_h1_w2          = 0.0 ;         % hours1 wrt wage2
            Veta_h2_w1          = 0.0 ;         % hours2 wrt wage1
            Veta_h2_w2          = vParams(8) ;  % hours2 wrt wage2
            COVeta_c_w1_c_w2    = vParams(9) ;  % consumption wrt wage1 ~ consumption wrt wage2
            COVeta_c_w1_h1_w1   = vParams(10);  % consumption wrt wage1 ~ hours1 wrt wage1
            COVeta_c_w1_h1_w2   = 0.0 ;         % consumption wrt wage1 ~ hours1 wrt wage2
            COVeta_c_w1_h2_w1   = 0.0 ;         % consumption wrt wage1 ~ hours2 wrt wage1
            COVeta_c_w1_h2_w2   = vParams(11);  % consumption wrt wage1 ~ hours2 wrt wage2
            COVeta_c_w2_h1_w1   = vParams(12);  % consumption wrt wage2 ~ hours1 wrt wage1
            COVeta_c_w2_h1_w2   = 0.0 ;         % consumption wrt wage2 ~ hours1 wrt wage2
            COVeta_c_w2_h2_w1   = 0.0 ;         % consumption wrt wage2 ~ hours2 wrt wage1
            COVeta_c_w2_h2_w2   = vParams(13);  % consumption wrt wage2 ~ hours2 wrt wage2
            COVeta_h1_w1_h1_w2  = 0.0 ;         % hours1 wrt wage1 ~ hours1 wrt wage2
            COVeta_h1_w1_h2_w1  = 0.0 ;         % hours1 wrt wage1 ~ hours2 wrt wage1
            COVeta_h1_w1_h2_w2  = vParams(14);  % hours1 wrt wage1 ~ hours2 wrt wage2
            COVeta_h1_w2_h2_w1  = 0.0 ;         % hours1 wrt wage2 ~ hours2 wrt wage1
            COVeta_h1_w2_h2_w2  = 0.0 ;         % hours1 wrt wage2 ~ hours2 wrt wage2
            COVeta_h2_w1_h2_w2  = 0.0 ;         % hours2 wrt wage1 ~ hours2 wrt wage2 
        end %preference_heterogeneity
        Vcons_err = v_err_c ;       % variance of consumption measurement error (not identified)
    end %higher_moments==-1
    
end %isequal

%   Initialize vectors to hold first moments preferences 
%   & second moments wages:
%   matrix 15: E[DwH DyH]
if higher_moments == -1
mom_wHyH = zeros(T,1) ;
end   
mom_wHyH_a = zeros(T,1) ;
mom_wHyH_b = zeros(T,1) ;
%   matrix 35: E[DwW DyH]
if higher_moments == -1
mom_wWyH = zeros(T,1) ;
end  
mom_wWyH_a = zeros(T,1) ;
mom_wWyH_b = zeros(T,1) ;
%   matrix 17: E[DwH DyW]
if higher_moments == -1
mom_wHyW = zeros(T,1) ;
end  
mom_wHyW_a = zeros(T,1) ;
mom_wHyW_b = zeros(T,1) ;
%   matrix 37: E[DwW DyW]
if higher_moments == -1
mom_wWyW = zeros(T,1) ; 
end         
mom_wWyW_a = zeros(T,1) ; 
mom_wWyW_b = zeros(T,1) ; 
%   matrix 19: E[DwH Dc]
if higher_moments == -1
mom_wHc  = zeros(T,1) ;
end  
mom_wHc_a  = zeros(T,1) ;
mom_wHc_b  = zeros(T,1) ;
%   matrix 39: E[DwW Dc]
if higher_moments == -1
mom_wWc  = zeros(T,1) ;
end  
mom_wWc_a  = zeros(T,1) ;
mom_wWc_b  = zeros(T,1) ; 

%   Initialize vectors to hold second moments preferences:
%   matrix 55: E[DyH DyH]
if higher_moments == -1
mom_yHyH  = zeros(T,1) ;
end  
mom_yHyH_a  = zeros(T,1) ;
%   matrix 57: E[DyH DyW]
if higher_moments == -1
mom_yHyW  = zeros(T,1) ;
end  
mom_yHyW_a  = zeros(T,1) ;
mom_yHyW_b  = zeros(T,1) ;
%   matrix 77: E[DyW DyW]
if higher_moments == -1
mom_yWyW  = zeros(T,1) ;
end  
mom_yWyW_a  = zeros(T,1) ;
%   matrix 59: E[DyH Dc]
if higher_moments == -1
mom_yHc  = zeros(T,1) ;
end  
mom_yHc_a  = zeros(T,1) ;
mom_yHc_b  = zeros(T,1) ;
%   matrix 79: E[DyW Dc]
if higher_moments == -1
mom_yWc  = zeros(T,1) ;
end   
mom_yWc_a  = zeros(T,1) ;
mom_yWc_b  = zeros(T,1) ;
%   matrix 99: E[Dc Dc]
if higher_moments == -1
mom_cc   = zeros(T,1) ;
end  
mom_cc_a   = zeros(T,1) ;

%   Initialize vectors to hold first moments preferences 
%   & third moments wages:
if higher_moments >= 1
%   matrix 25: E[DwH2 DyH]      
mom_wH2yH_a = zeros(T,1) ;
mom_wH2yH_b = zeros(T,1) ;
%   matrix 45: E[DwW2 DyH]
mom_wW2yH_a = zeros(T,1) ;
mom_wW2yH_b = zeros(T,1) ;
%   matrix 27: E[DwH2 DyW]
mom_wH2yW_a = zeros(T,1) ;
mom_wH2yW_b = zeros(T,1) ;
%   matrix 47: E[DwW2 DyW]       
mom_wW2yW_a = zeros(T,1) ; 
mom_wW2yW_b = zeros(T,1) ; 
%   matrix 29: E[DwH2 Dc]
mom_wH2c_a  = zeros(T,1) ;
mom_wH2c_b  = zeros(T,1) ;
%   matrix 49: E[DwW2 Dc] 
mom_wW2c_a  = zeros(T,1) ;
mom_wW2c_b  = zeros(T,1) ;
end

%   Initialize vectors to hold second moments preferences 
%   & third moments wages:
if higher_moments >= 1
%   matrix 16: E[DwH DyH2]      
mom_wHyH2_a = zeros(T,1) ;
mom_wHyH2_b = zeros(T,1) ;
%   matrix 36: E[DwW DyH2]
mom_wWyH2_a = zeros(T,1) ;
mom_wWyH2_b = zeros(T,1) ;
%   matrix 18: E[DwH DyW2]
mom_wHyW2_a = zeros(T,1) ;
mom_wHyW2_b = zeros(T,1) ;
%   matrix 38: E[DwW DyW2]       
mom_wWyW2_a = zeros(T,1) ; 
mom_wWyW2_b = zeros(T,1) ; 
%   matrix 1.10: E[DwH Dc2]
mom_wHc2_a  = zeros(T,1) ;
mom_wHc2_b  = zeros(T,1) ;
%   matrix 3.10: E[DwW Dc2] 
mom_wWc2_a  = zeros(T,1) ;
mom_wWc2_b  = zeros(T,1) ;
%   matrix 1.11: E[DwH DyH DyW]
mom_wHyHyW_a = zeros(T,1) ;
mom_wHyHyW_b = zeros(T,1) ;
%   matrix 3.11: E[DwW DyH DyW]       
mom_wWyHyW_a = zeros(T,1) ; 
mom_wWyHyW_b = zeros(T,1) ; 
%   matrix 1.12: E[DwH DyH Dc]
mom_wHyHc_a  = zeros(T,1) ;
mom_wHyHc_b  = zeros(T,1) ;
%   matrix 3.12: E[DwW DyH Dc] 
mom_wWyHc_a  = zeros(T,1) ;
mom_wWyHc_b  = zeros(T,1) ;
%   matrix 1.13: E[DwH DyW Dc]
mom_wHyWc_a  = zeros(T,1) ;
mom_wHyWc_b  = zeros(T,1) ;
%   matrix 3.13: E[DwW DyW Dc] 
mom_wWyWc_a  = zeros(T,1) ;
mom_wWyWc_b  = zeros(T,1) ;
end


%%  2.  DECLARE STRUCTURE
%   Initialize structural items
%   -----------------------------------------------------------------------

%   Declare items that transmit permanent wage shocks into earnings and
%   consumption; these items are used only when I estimate the BPS model
%   specification. Matrices 'e1' and 'e2' have size TxN: 
if higher_moments == -1

    %   Sum of average earnings & consumption Frish elasticities (scalars):
    eta_c_bar  = eta_c_w1 + eta_c_w2 + eta_c_p ;
    eta_h1_bar = eta_h1_w1 + eta_h1_w2 + eta_h1_p ;
    eta_h2_bar = eta_h2_w1 + eta_h2_w2 + eta_h2_p ;

    %   Denominator of 'epsilon':
    denom = eta_c_bar - (1-mCpi) .* (mCes*eta_h1_bar + (1-mCes)*eta_h2_bar) ;

    %   Construct 'epsilon' matrices:
    e1 = ((1-mCpi) .* (mCes*(1+eta_h1_w1) + (1-mCes)*eta_h2_w1) - eta_c_w1) ./ denom ;
    e2 = ((1-mCpi) .* (mCes*eta_h1_w2 + (1-mCes)*(1+eta_h2_w2)) - eta_c_w2) ./ denom ;
end %higher_moments == -1


%%  3.  FIRST MOMENTS PREFERENCES - SECOND MOMENTS WAGES
%   Construct vector of moments E(data_moment_i - model_moment_i) = 0
%   -----------------------------------------------------------------------

%   Matrix 15: E[DwH DyH]   
%   -----------------------------------------------------------------------

%   Contemporaneous covariance 2001-2009:
if higher_moments == -1
j = 2 ;
while j <= (T-1)
    mom_wHyH(j) = (mC(5*T+j,:) - merrC(j,5) - merrC(j-1,5) ...
        - (1+eta_h1_w1) * (uH(j) + uH(j-1)) ...
        - eta_h1_w2 * (uHW(j) + uHW(j-1)) ...
        - (1+eta_h1_w1 + eta_h1_bar*e1(j,:)) * vH(j-1) ...
        - (eta_h1_w2 + eta_h1_bar*e2(j,:)) * vHW(j-1)) ...
        * mCD(5*T+j,:)' ;
    mom_wHyH(j) = mom_wHyH(j) / sum(mCD(5*T+j,:)) ;
    j = j + 1 ;
end
end %higher_moments == -1

%   Intertemporal covariances 1999-2011:
j = 2 ;
while j <= T 
	mom_wHyH_a(j) = (mC(6*T+j-1,:) + merrC(j-1,5) ...
        + (1+eta_h1_w1) * uH(j-1) + eta_h1_w2 * uHW(j-1)) ...
        * mCD(6*T+j-1,:)' ;
    mom_wHyH_a(j) = mom_wHyH_a(j) / sum(mCD(6*T+j-1,:)) ;
	j = j + 1 ;
end

j = start_j ;
while j <= T 
    mom_wHyH_b(j) = (mC(7*T+j-1,:) + merrC(j-1,5) ...
        + (1+eta_h1_w1) * uH(j-1) + eta_h1_w2 * uHW(j-1)) ...
        * mCD(7*T+j-1,:)' ;
    mom_wHyH_b(j) = mom_wHyH_b(j) / sum(mCD(7*T+j-1,:)) ;
	j = j + 1 ;
end


%   Matrix 35: E[DwW DyH]   
%   -----------------------------------------------------------------------

%   Contemporaneous covariance 2001-2009:
if higher_moments == -1
j = 2 ;
while j <= (T-1) 
    mom_wWyH(j) = (mC(8*T+j,:) ...
        - (1+eta_h1_w1) * (uHW(j) + uHW(j-1)) ...
        - eta_h1_w2 * (uW(j) + uW(j-1)) ...
        - (1+eta_h1_w1 + eta_h1_bar*e1(j,:)) * vHW(j-1) ...
        - (eta_h1_w2 + eta_h1_bar*e2(j,:)) * vW(j-1)) ...
        * mCD(8*T+j,:)' ;
    mom_wWyH(j) = mom_wWyH(j) / sum(mCD(8*T+j,:)) ;
    j = j + 1 ;
end
end %higher_moments == -1

%   Intertemporal co-variances 1999-2011:
j = 2 ;
while j <= T 
	mom_wWyH_a(j) = (mC(9*T+j-1,:) ...
        + (1+eta_h1_w1) * uHW(j-1) + eta_h1_w2 * uW(j-1)) ...
        * mCD(9*T+j-1,:)' ;
    mom_wWyH_a(j) = mom_wWyH_a(j) / sum(mCD(9*T+j-1,:)) ;
	j = j + 1 ;
end

j = start_j ;
while j <= T
    mom_wWyH_b(j) = (mC(10*T+j-1,:) ...
        + (1+eta_h1_w1) * uHW(j-1) + eta_h1_w2 * uW(j-1)) ...
        * mCD(10*T+j-1,:)' ;
    mom_wWyH_b(j) = mom_wWyH_b(j) / sum(mCD(10*T+j-1,:)) ;
	j = j + 1 ;
end


%   Matrix 17: E[DwH DyW]   
%   -----------------------------------------------------------------------

%   Contemporaneous covariance 2001-2009:
if higher_moments == -1
j = 2 ;
while j <= (T-1) 
    mom_wHyW(j) = (mC(11*T+j,:) ...
        - eta_h2_w1 * (uH(j) + uH(j-1)) ...
        - (1+eta_h2_w2) * (uHW(j) + uHW(j-1)) ...
        - (eta_h2_w1 + eta_h2_bar*e1(j,:)) * vH(j-1) ...
        - (1+eta_h2_w2 + eta_h2_bar*e2(j,:)) * vHW(j-1)) ...
        * mCD(11*T+j,:)' ; 
    mom_wHyW(j) = mom_wHyW(j) / sum(mCD(11*T+j,:)) ;
    j = j + 1 ;
end
end %higher_moments == -1

%   Intertemporal co-variances 1999-2011:
j = 2 ;
while j <= T 
	mom_wHyW_a(j) = (mC(12*T+j-1,:) ...
        + eta_h2_w1 * uH(j-1) + (1+eta_h2_w2) * uHW(j-1)) ...
        * mCD(12*T+j-1,:)' ; 
    mom_wHyW_a(j) = mom_wHyW_a(j) / sum(mCD(12*T+j-1,:)) ;
	j = j + 1 ;
end

j = start_j ;
while j <= T 
	mom_wHyW_b(j) = (mC(13*T+j-1,:) ...
        + eta_h2_w1 * uH(j-1) + (1+eta_h2_w2) * uHW(j-1)) ...
        * mCD(13*T+j-1,:)' ;
    mom_wHyW_b(j) = mom_wHyW_b(j) / sum(mCD(13*T+j-1,:)) ;
	j = j + 1 ;
end


%   Matrix 37: E[DwW DyW]   
%   -----------------------------------------------------------------------

%   Contemporaneous covariance 2001-2009:
if higher_moments == -1
j = 2 ;
while j <= (T-1) 
    mom_wWyW(j) = (mC(14*T+j,:) - merrC(j,6) - merrC(j-1,6) ...
        - eta_h2_w1 * (uHW(j) + uHW(j-1)) ...
        - (1+eta_h2_w2) * (uW(j) + uW(j-1)) ...
        - (eta_h2_w1 + eta_h2_bar*e1(j,:)) * vHW(j-1) ...
        - (1+eta_h2_w2 + eta_h2_bar*e2(j,:)) * vW(j-1)) ...
        * mCD(14*T+j,:)' ;
    mom_wWyW(j) = mom_wWyW(j) / sum(mCD(14*T+j,:)) ;
    j = j + 1 ;
end
end %higher_moments == -1

%   Intertemporal co-variances 1999-2011:
j = 2 ;
while j <= T 
	mom_wWyW_a(j) = (mC(15*T+j-1,:) + merrC(j-1,6) ...
        + eta_h2_w1 * uHW(j-1) + (1+eta_h2_w2) * uW(j-1)) ...
        * mCD(15*T+j-1,:)' ;
    mom_wWyW_a(j) = mom_wWyW_a(j) / sum(mCD(15*T+j-1,:)) ;
	j = j + 1 ;
end

j = start_j ;
while j <= T 
	mom_wWyW_b(j) = (mC(16*T+j-1,:) + merrC(j-1,6) ...
        + eta_h2_w1 * uHW(j-1) + (1+eta_h2_w2) * uW(j-1)) ...
        * mCD(16*T+j-1,:)' ;
    mom_wWyW_b(j) = mom_wWyW_b(j) / sum(mCD(16*T+j-1,:)) ;
	j = j + 1 ;
end


%   Matrix 19: E[DwH Dc]   
%   -----------------------------------------------------------------------

%   Contemporaneous covariance 2001-2009:
if higher_moments == -1
j = 2 ;
while j <= (T-1)
    mom_wHc(j) = (mC(44*T+j,:) ...
        - eta_c_w1 * (uH(j) + uH(j-1)) ...
        - eta_c_w2 * (uHW(j) + uHW(j-1)) ...
        - (eta_c_w1 + eta_c_bar*e1(j,:)) * vH(j-1) ...
        - (eta_c_w2 + eta_c_bar*e2(j,:)) * vHW(j-1)) ...
        * mCD(44*T+j,:)' ;
    mom_wHc(j) = mom_wHc(j) / sum(mCD(44*T+j,:)) ;
    j = j + 1 ;
end
end %higher_moments == -1

%   Intertemporal co-variances 2001-2011:
j = 2 ;
while j <= T 
	mom_wHc_a(j) = (mC(45*T+j-1,:) ...
        + eta_c_w1 * uH(j-1) + eta_c_w2 * uHW(j-1)) ...
        * mCD(45*T+j-1,:)' ;
    mom_wHc_a(j) = mom_wHc_a(j) / sum(mCD(45*T+j-1,:)) ;
	j = j + 1 ;
end

j = 3 ;
while j <= T
	mom_wHc_b(j) = (mC(46*T+j-1,:) ...
        + eta_c_w1 * uH(j-1) + eta_c_w2 * uHW(j-1)) ...
        * mCD(46*T+j-1,:)' ;
    mom_wHc_b(j) = mom_wHc_b(j) / sum(mCD(46*T+j-1,:)) ;
	j = j + 1 ;
end


%   Matrix 39: E[DwW Dc]   
%   -----------------------------------------------------------------------

%   Contemporaneous covariance 2001-2009:
if higher_moments == -1
j = 2 ;
while j <= (T-1) 
    mom_wWc(j) = (mC(47*T+j,:) ...
        - eta_c_w1 * (uHW(j) + uHW(j-1)) ...
        - eta_c_w2 * (uW(j) + uW(j-1)) ...
        - (eta_c_w1 + eta_c_bar*e1(j,:)) * vHW(j-1) ...
        - (eta_c_w2 + eta_c_bar*e2(j,:)) * vW(j-1)) ...
        * mCD(47*T+j,:)' ;
    mom_wWc(j) = mom_wWc(j) / sum(mCD(47*T+j,:)) ;
    j = j + 1 ;
end
end %higher_moments == -1

%   Intertemporal co-variances 2001-2011:
j = 2 ;
while j <= T 
	mom_wWc_a(j) = (mC(48*T+j-1,:) ...
        + eta_c_w1 * uHW(j-1) + eta_c_w2 * uW(j-1)) ...
        * mCD(48*T+j-1,:)' ;
    mom_wWc_a(j) = mom_wWc_a(j) / sum(mCD(48*T+j-1,:)) ;
	j = j + 1 ;
end

j = 3 ;
while j <= T
	mom_wWc_b(j) = (mC(49*T+j-1,:) ...
        + eta_c_w1 * uHW(j-1) + eta_c_w2 * uW(j-1)) ...
        * mCD(49*T+j-1,:)' ;
    mom_wWc_b(j) = mom_wWc_b(j) / sum(mCD(49*T+j-1,:)) ;
	j = j + 1 ;
end


%%  4.  FIRST MOMENTS PREFERENCES - THIRD MOMENTS WAGES
%   Construct vector of moments E(data_moment_i - model_moment_i) = 0
%   -----------------------------------------------------------------------

if higher_moments >= 1
    
%   Matrix 25: E[DwH2 DyH]
%   -----------------------------------------------------------------------

%   Intertemporal covariances 1999-2011:
j = 2 ;
while j <= T 
	mom_wH2yH_a(j) = (mC(24*T+j-1,:) ...
        + (1+eta_h1_w1) * guH(j-1) + eta_h1_w2 * guH2W(j-1)) ...
        * mCD(24*T+j-1,:)' ;
    mom_wH2yH_a(j) = mom_wH2yH_a(j) / sum(mCD(24*T+j-1,:)) ;
	j = j + 1 ;
end

j = start_j ;
while j <= T 
    mom_wH2yH_b(j) = (mC(25*T+j-1,:) ...
        - (1+eta_h1_w1) * guH(j-1) - eta_h1_w2 * guH2W(j-1)) ...
        * mCD(25*T+j-1,:)' ;
    mom_wH2yH_b(j) = mom_wH2yH_b(j) / sum(mCD(25*T+j-1,:)) ;
	j = j + 1 ;
end


%   Matrix 45: E[DwW2 DyH]
%   -----------------------------------------------------------------------

%   Intertemporal co-variances 1999-2011:
j = 2 ;
while j <= T 
	mom_wW2yH_a(j) = (mC(26*T+j-1,:) ...
        + (1+eta_h1_w1) * guHW2(j-1) + eta_h1_w2 * guW(j-1)) ...
        * mCD(26*T+j-1,:)' ;
    mom_wW2yH_a(j) = mom_wW2yH_a(j) / sum(mCD(26*T+j-1,:)) ;
	j = j + 1 ;
end

j = start_j ;
while j <= T
    mom_wW2yH_b(j) = (mC(27*T+j-1,:) ...
        - (1+eta_h1_w1) * guHW2(j-1) - eta_h1_w2 * guW(j-1)) ...
        * mCD(27*T+j-1,:)' ;
    mom_wW2yH_b(j) = mom_wW2yH_b(j) / sum(mCD(27*T+j-1,:)) ;
	j = j + 1 ;
end


%   Matrix 27: E[DwH2 DyW]
%   -----------------------------------------------------------------------

%   Intertemporal co-variances 1999-2011:
j = 2 ;
while j <= T 
	mom_wH2yW_a(j) = (mC(28*T+j-1,:) ...
        + eta_h2_w1 * guH(j-1) + (1+eta_h2_w2) * guH2W(j-1)) ...
        * mCD(28*T+j-1,:)' ; 
    mom_wH2yW_a(j) = mom_wH2yW_a(j) / sum(mCD(28*T+j-1,:)) ;
	j = j + 1 ;
end

j = start_j ;
while j <= T 
	mom_wH2yW_b(j) = (mC(29*T+j-1,:) ...
        - eta_h2_w1 * guH(j-1) - (1+eta_h2_w2) * guH2W(j-1)) ...
        * mCD(29*T+j-1,:)' ;
    mom_wH2yW_b(j) = mom_wH2yW_b(j) / sum(mCD(29*T+j-1,:)) ;
	j = j + 1 ;
end


%   Matrix 47: E[DwW2 DyW]
%   -----------------------------------------------------------------------

%   Intertemporal co-variances 1999-2011:
j = 2 ;
while j <= T 
	mom_wW2yW_a(j) = (mC(30*T+j-1,:) ...
        + eta_h2_w1 * guHW2(j-1) + (1+eta_h2_w2) * guW(j-1)) ...
        * mCD(30*T+j-1,:)' ;
    mom_wW2yW_a(j) = mom_wW2yW_a(j) / sum(mCD(30*T+j-1,:)) ;
	j = j + 1 ;
end

j = start_j ;
while j <= T 
	mom_wW2yW_b(j) = (mC(31*T+j-1,:) ...
        - eta_h2_w1 * guHW2(j-1) - (1+eta_h2_w2) * guW(j-1)) ...
        * mCD(31*T+j-1,:)' ;
    mom_wW2yW_b(j) = mom_wW2yW_b(j) / sum(mCD(31*T+j-1,:)) ;
	j = j + 1 ;
end


%   Matrix 29: E[DwH2 Dc]
%   -----------------------------------------------------------------------

%   Intertemporal co-variances 1999-2011:
j = 2 ;
while j <= T 
	mom_wH2c_a(j) = (mC(58*T+j-1,:) ...
        + eta_c_w1 * guH(j-1) + eta_c_w2 * guH2W(j-1)) ...
        * mCD(58*T+j-1,:)' ;
    mom_wH2c_a(j) = mom_wH2c_a(j) / sum(mCD(58*T+j-1,:)) ;
	j = j + 1 ;
end

j = 3 ;
while j <= T
	mom_wH2c_b(j) = (mC(59*T+j-1,:) ...
        - eta_c_w1 * guH(j-1) - eta_c_w2 * guH2W(j-1)) ...
        * mCD(59*T+j-1,:)' ;
    mom_wH2c_b(j) = mom_wH2c_b(j) / sum(mCD(59*T+j-1,:)) ;
	j = j + 1 ;
end


%   Matrix 49: E[DwW2 Dc] 
%   -----------------------------------------------------------------------

%   Intertemporal co-variances 1999-2011:
j = 2 ;
while j <= T 
	mom_wW2c_a(j) = (mC(60*T+j-1,:) ...
        + eta_c_w1 * guHW2(j-1) + eta_c_w2 * guW(j-1)) ...
        * mCD(60*T+j-1,:)' ;
    mom_wW2c_a(j) = mom_wW2c_a(j) / sum(mCD(60*T+j-1,:)) ;
	j = j + 1 ;
end

j = 3 ;
while j <= T
	mom_wW2c_b(j) = (mC(61*T+j-1,:) ...
        - eta_c_w1 * guHW2(j-1) - eta_c_w2 * guW(j-1)) ...
        * mCD(61*T+j-1,:)' ;
    mom_wW2c_b(j) = mom_wW2c_b(j) / sum(mCD(61*T+j-1,:)) ;
	j = j + 1 ;
end
end %if higher_moments >= 1


%%  5.  SECOND MOMENTS PREFERENCES - SECOND MOMENTS WAGES
%   Construct vector of moments E(data_moment_i - model_moment_i) = 0
%   -----------------------------------------------------------------------

%   Matrix 55: E[DyH DyH]   
%   -----------------------------------------------------------------------

%   Contemporaneous covariance 2001-2009:
if higher_moments == -1
j = 2 ;
while j <= (T-1) 
    mom_yHyH(j) = (mC(17*T+j,:) - merrC(j,3) - merrC(j-1,3) ...
        - (1 + eta_h1_w1)^2 * (uH(j) + uH(j-1)) ...
        - 2*(1 + eta_h1_w1) * eta_h1_w2 * (uHW(j) + uHW(j-1)) ...
        - eta_h1_w2^2 * (uW(j) + uW(j-1)) ...
        - (1 + eta_h1_w1 + eta_h1_bar*e1(j,:)).^2 * vH(j-1) ...
        - 2*(1 + eta_h1_w1 + eta_h1_bar*e1(j,:)).*(eta_h1_w2 + eta_h1_bar*e2(j,:)) * vHW(j-1) ...
        - (eta_h1_w2 + eta_h1_bar*e2(j,:)).^2 * vW(j-1)) ...
        * mCD(17*T+j,:)' ;
    mom_yHyH(j) = mom_yHyH(j) / sum(mCD(17*T+j,:)) ;
    j = j + 1 ;
end
end %higher_moments == -1

%   Intertemporal co-variances 1999-2011:
j = start_j ;
while j <= T 
	mom_yHyH_a(j) = (mC(18*T+j-1,:) + merrC(j-1,3) ...
        + (1 + Veta_h1_w1 + eta_h1_w1^2 + 2*eta_h1_w1) * uH(j-1) ...
        + 2*(eta_h1_w2 + COVeta_h1_w1_h1_w2 + eta_h1_w1*eta_h1_w2) * uHW(j-1) ...
        + (Veta_h1_w2 + eta_h1_w2^2) * uW(j-1)) ...
        * mCD(18*T+j-1,:)' ;
    mom_yHyH_a(j) = mom_yHyH_a(j) / sum(mCD(18*T+j-1,:)) ;
	j = j + 1 ;
end


%   Matrix 57: E[DyH DyW]   
%   -----------------------------------------------------------------------

%   Contemporaneous covariance 2001-2009:
if higher_moments == -1
j = 2 ;
while j <= (T-1) 
    mom_yHyW(j) = (mC(19*T+j,:) ...
        - (1 + eta_h1_w1) * eta_h2_w1 * (uH(j) + uH(j-1)) ...
        - (1 + eta_h1_w1) * (1 + eta_h2_w2) * (uHW(j) + uHW(j-1)) ...
        - eta_h1_w2*eta_h2_w1 * (uHW(j) + uHW(j-1)) ...
        - eta_h1_w2*(1 + eta_h2_w2) * (uW(j) + uW(j-1)) ...
        - (1 + eta_h1_w1 + eta_h1_bar*e1(j,:)) .* (eta_h2_w1 + eta_h2_bar*e1(j,:)) * vH(j-1) ...
        - (1 + eta_h1_w1 + eta_h1_bar*e1(j,:)) .* (1 + eta_h2_w2 + eta_h2_bar*e2(j,:)) * vHW(j-1) ...
        - (eta_h1_w2 + eta_h1_bar*e2(j,:)) .* (eta_h2_w1 + eta_h2_bar*e1(j,:)) * vHW(j-1) ...
        - (eta_h1_w2 + eta_h1_bar*e2(j,:)) .* (1 + eta_h2_w2 + eta_h2_bar*e2(j,:)) * vW(j-1)) ...    
        * mCD(19*T+j,:)' ; 
    mom_yHyW(j) = mom_yHyW(j) / sum(mCD(19*T+j,:)) ;
    j = j + 1 ;
end
end %higher_moments == -1

%   Intertemporal co-variances 1999-2011:
j = start_j ;
while j <= T
	mom_yHyW_a(j) = (mC(20*T+j-1,:) ...
        + (eta_h2_w1 + COVeta_h1_w1_h2_w1 + eta_h1_w1*eta_h2_w1) * uH(j-1) ...
        + (1 + eta_h1_w1 + eta_h2_w2 + COVeta_h1_w1_h2_w2 + eta_h1_w1*eta_h2_w2) * uHW(j-1) ...
        + (COVeta_h1_w2_h2_w1 + eta_h1_w2*eta_h2_w1) * uHW(j-1) ...
        + (eta_h1_w2 + COVeta_h1_w2_h2_w2 + eta_h1_w2*eta_h2_w2) * uW(j-1)) ...    
        * mCD(20*T+j-1,:)' ; 
    mom_yHyW_a(j) = mom_yHyW_a(j) / sum(mCD(20*T+j-1,:)) ;
	j = j + 1 ;
end

j = start_j ;
while j <= T
	mom_yHyW_b(j) = (mC(21*T+j-1,:) ...
        + (eta_h2_w1 + COVeta_h1_w1_h2_w1 + eta_h1_w1*eta_h2_w1) * uH(j-1) ...
        + (1 + eta_h1_w1 + eta_h2_w2 + COVeta_h1_w1_h2_w2 + eta_h1_w1*eta_h2_w2) * uHW(j-1) ...
        + (COVeta_h1_w2_h2_w1 + eta_h1_w2*eta_h2_w1) * uHW(j-1) ...
        + (eta_h1_w2 + COVeta_h1_w2_h2_w2 + eta_h1_w2*eta_h2_w2) * uW(j-1)) ... 
        * mCD(21*T+j-1,:)' ;
    mom_yHyW_b(j) = mom_yHyW_b(j) / sum(mCD(21*T+j-1,:)) ;
	j = j + 1 ;
end


%   Matrix 77: E[DyW DyW]   
%   -----------------------------------------------------------------------

%   Contemporaneous covariance 2001-2009:
if higher_moments == -1
j = 2 ;
while j <= (T-1) 
    mom_yWyW(j) = (mC(22*T+j,:) - merrC(j,4) - merrC(j-1,4) ...
        - eta_h2_w1^2 * (uH(j) + uH(j-1)) ...
        - 2*eta_h2_w1*(1+eta_h2_w2) * (uHW(j) + uHW(j-1)) ...
        - (1 + eta_h2_w2)^2 * (uW(j) + uW(j-1)) ...
        - (eta_h2_w1 + eta_h2_bar*e1(j,:)).^2 * vH(j-1) ...
        - 2*(eta_h2_w1 + eta_h2_bar*e1(j,:)).*(1 + eta_h2_w2 + eta_h2_bar*e2(j,:)) * vHW(j-1) ...
        - (1 + eta_h2_w2 + eta_h2_bar*e2(j,:)).^2 * vW(j-1)) ...
        * mCD(22*T+j,:)' ;
    mom_yWyW(j) = mom_yWyW(j) / sum(mCD(22*T+j,:)) ;
    j = j + 1 ;
end
end %higher_moments == -1

%   Intertemporal co-variances 1999-2011:
j = start_j ;
while j <= T 
	mom_yWyW_a(j) = (mC(23*T+j-1,:) + merrC(j-1,4) ...
        + (Veta_h2_w1 + eta_h2_w1^2) * uH(j-1) ...
        + 2*(eta_h2_w1 + COVeta_h2_w1_h2_w2 + eta_h2_w1*eta_h2_w2) * uHW(j-1) ...
        + (1 + Veta_h2_w2 + eta_h2_w2^2 + 2*eta_h2_w2) * uW(j-1)) ...
        * mCD(23*T+j-1,:)' ;
    mom_yWyW_a(j) = mom_yWyW_a(j) / sum(mCD(23*T+j-1,:)) ;
	j = j + 1 ;
end


%   Matrix 59: E[DyH Dc]   
%   -----------------------------------------------------------------------

%   Contemporaneous covariance 2001-2009:
if higher_moments == -1
j = 2 ;
while j <= (T-1) 
    mom_yHc(j) = (mC(50*T+j,:) ...
        - (1 + eta_h1_w1) * eta_c_w1 * (uH(j) + uH(j-1)) ...
        - (1 + eta_h1_w1) * eta_c_w2 * (uHW(j) + uHW(j-1)) ...
        - eta_h1_w2 * eta_c_w1 * (uHW(j) + uHW(j-1)) ...
        - eta_h1_w2 * eta_c_w2 * (uW(j) + uW(j-1)) ...
        - (1 + eta_h1_w1 + eta_h1_bar*e1(j,:)) .* (eta_c_w1 + eta_c_bar*e1(j,:)) * vH(j-1) ...
        - (1 + eta_h1_w1 + eta_h1_bar*e1(j,:)) .* (eta_c_w2 + eta_c_bar*e2(j,:)) * vHW(j-1) ...
        - (eta_h1_w2 + eta_h1_bar*e2(j,:)) .* (eta_c_w1 + eta_c_bar*e1(j,:)) * vHW(j-1) ...
        - (eta_h1_w2 + eta_h1_bar*e2(j,:)) .* (eta_c_w2 + eta_c_bar*e2(j,:)) * vW(j-1)) ...
        * mCD(50*T+j,:)' ;
    mom_yHc(j) = mom_yHc(j) / sum(mCD(50*T+j,:)) ;
    j = j + 1 ;
end
end %higher_moments == -1

%   Intertemporal co-variances 1999-2011:
j = start_j ;
while j <= T 
	mom_yHc_a(j) = (mC(51*T+j-1,:) ...
        + (eta_c_w1 + COVeta_c_w1_h1_w1 + eta_c_w1*eta_h1_w1) * uH(j-1) ...
        + (eta_c_w2 + COVeta_c_w2_h1_w1 + eta_c_w2*eta_h1_w1) * uHW(j-1) ...
        + (COVeta_c_w1_h1_w2 + eta_c_w1*eta_h1_w2) * uHW(j-1) ...
        + (COVeta_c_w2_h1_w2 + eta_c_w2*eta_h1_w2) * uW(j-1)) ...
        * mCD(51*T+j-1,:)' ;
    mom_yHc_a(j) = mom_yHc_a(j) / sum(mCD(51*T+j-1,:)) ;
	j = j + 1 ;
end

j = 3 ;
while j <= T 
	mom_yHc_b(j) = (mC(52*T+j-1,:) ...
        + (eta_c_w1 + COVeta_c_w1_h1_w1 + eta_c_w1*eta_h1_w1) * uH(j-1) ...
        + (eta_c_w2 + COVeta_c_w2_h1_w1 + eta_c_w2*eta_h1_w1) * uHW(j-1) ...
        + (COVeta_c_w1_h1_w2 + eta_c_w1*eta_h1_w2) * uHW(j-1) ...
        + (COVeta_c_w2_h1_w2 + eta_c_w2*eta_h1_w2) * uW(j-1)) ...
        * mCD(52*T+j-1,:)' ; 
    mom_yHc_b(j) = mom_yHc_b(j) / sum(mCD(52*T+j-1,:)) ;
	j = j + 1 ;
end


%   Matrix 79: E[DyW Dc]   
%   -----------------------------------------------------------------------

%   Contemporaneous covariance 2001-2009:
if higher_moments == -1
j = 2 ;
while j <= (T-1) 
    mom_yWc(j) = (mC(53*T+j,:) ...
        - eta_h2_w1 * eta_c_w1 * (uH(j) + uH(j-1)) ...
        - eta_h2_w1 * eta_c_w2 * (uHW(j) + uHW(j-1)) ...
        - (1 + eta_h2_w2) * eta_c_w1 * (uHW(j) + uHW(j-1)) ...
        - (1 + eta_h2_w2) * eta_c_w2 * (uW(j) + uW(j-1)) ...
        - (eta_h2_w1 + eta_h2_bar*e1(j,:)) .* (eta_c_w1 + eta_c_bar*e1(j,:)) * vH(j-1) ...
        - (eta_h2_w1 + eta_h2_bar*e1(j,:)) .* (eta_c_w2 + eta_c_bar*e2(j,:)) * vHW(j-1) ...
        - (1 + eta_h2_w2 + eta_h2_bar*e2(j,:)) .* (eta_c_w1 + eta_c_bar*e1(j,:)) * vHW(j-1) ...
        - (1 + eta_h2_w2 + eta_h2_bar*e2(j,:)) .* (eta_c_w2 + eta_c_bar*e2(j,:)) * vW(j-1)) ...      
        * mCD(53*T+j,:)' ; 
    mom_yWc(j) = mom_yWc(j) / sum(mCD(53*T+j,:)) ;
    j = j + 1 ;
end
end %higher_moments == -1

%   Intertemporal co-variances 1999-2011:
j = start_j ;
while j <= T 
	mom_yWc_a(j) = (mC(54*T+j-1,:) ...
        + (COVeta_c_w1_h2_w1 + eta_c_w1*eta_h2_w1) * uH(j-1) ...
        + (COVeta_c_w2_h2_w1 + eta_c_w2*eta_h2_w1) * uHW(j-1) ...
        + (eta_c_w1 + COVeta_c_w1_h2_w2 + eta_c_w1*eta_h2_w2) * uHW(j-1) ...
        + (eta_c_w2 + COVeta_c_w2_h2_w2 + eta_c_w2*eta_h2_w2) * uW(j-1)) ...      
        * mCD(54*T+j-1,:)' ; 
    mom_yWc_a(j) = mom_yWc_a(j) / sum(mCD(54*T+j-1,:)) ;
	j = j + 1 ;
end

j = 3 ;
while j <= T
	mom_yWc_b(j) = (mC(55*T+j-1,:) ...
        + (COVeta_c_w1_h2_w1 + eta_c_w1*eta_h2_w1) * uH(j-1) ...
        + (COVeta_c_w2_h2_w1 + eta_c_w2*eta_h2_w1) * uHW(j-1) ...
        + (eta_c_w1 + COVeta_c_w1_h2_w2 + eta_c_w1*eta_h2_w2) * uHW(j-1) ...
        + (eta_c_w2 + COVeta_c_w2_h2_w2 + eta_c_w2*eta_h2_w2) * uW(j-1)) ... 
        * mCD(55*T+j-1,:)' ; 
    mom_yWc_b(j) = mom_yWc_b(j) / sum(mCD(55*T+j-1,:)) ;
	j = j + 1 ;
end


%   Matrix 99: E[Dc Dc]   
%   -----------------------------------------------------------------------

%   Contemporaneous covariance 2001-2009:
if higher_moments == -1
j = 2 ;
while j <= (T-1) 
    mom_cc(j) = (mC(56*T+j,:) - 2*Vcons_err ...
        - eta_c_w1^2 * (uH(j) + uH(j-1)) ...
        - 2*eta_c_w1*eta_c_w2 * (uHW(j) + uHW(j-1)) ...
        - eta_c_w2^2 * (uW(j) + uW(j-1)) ...
        - (eta_c_w1 + eta_c_bar*e1(j,:)).^2 * vH(j-1) ...
        - 2*(eta_c_w1 + eta_c_bar*e1(j,:)) .* (eta_c_w2 + eta_c_bar*e2(j,:)) * vHW(j-1) ...
        - (eta_c_w2 + eta_c_bar*e2(j,:)).^2 * vW(j-1)) ...
        * mCD(56*T+j,:)' ;
    mom_cc(j) = mom_cc(j) / sum(mCD(56*T+j,:)) ;
    j = j + 1 ;
end
end %higher_moments == -1

%   Intertemporal co-variances 2001-2011:
j = 3 ;
while j <= T
	mom_cc_a(j) = (mC(57*T+j-1,:) ...
        + (Veta_c_w1 + eta_c_w1^2) * uH(j-1) ...
        + 2*(COVeta_c_w1_c_w2 + eta_c_w1*eta_c_w2) * uHW(j-1) ...
        + (Veta_c_w2 + eta_c_w2^2) * uW(j-1) ...
        + Vcons_err) ...
        * mCD(57*T+j-1,:)' ;
    mom_cc_a(j) = mom_cc_a(j) / sum(mCD(57*T+j-1,:)) ;
	j = j + 1 ;
end


%%  6.  SECOND MOMENTS PREFERENCES - THIRD MOMENTS WAGES
%   Construct vector of moments E(data_moment_i - model_moment_i) = 0
%   -----------------------------------------------------------------------

if higher_moments >= 1
    
%   Matrix 16: E[DwH DyH2]
%   -----------------------------------------------------------------------

%   Intertemporal co-variances 1999-2009:
j = 2 ;
while j <= T 
	mom_wHyH2_a(j) = (mC(32*T+j-1,:) ...
        - (1 + Veta_h1_w1 + eta_h1_w1^2 + 2*eta_h1_w1) * guH(j-1) ...
        - 2*(eta_h1_w2 + COVeta_h1_w1_h1_w2 + eta_h1_w1*eta_h1_w2) * guH2W(j-1) ...
        - (Veta_h1_w2 + eta_h1_w2^2) * guHW2(j-1)) ...
        * mCD(32*T+j-1,:)' ;
    mom_wHyH2_a(j) = mom_wHyH2_a(j) / sum(mCD(32*T+j-1,:)) ;
	j = j + 1 ;
end

j = start_j ;
while j <= T 
	mom_wHyH2_b(j) = (mC(33*T+j-1,:) ...
        + (1 + Veta_h1_w1 + eta_h1_w1^2 + 2*eta_h1_w1) * guH(j-1) ...
        + 2*(eta_h1_w2 + COVeta_h1_w1_h1_w2 + eta_h1_w1*eta_h1_w2) * guH2W(j-1) ...
        + (Veta_h1_w2 + eta_h1_w2^2) * guHW2(j-1)) ...
        * mCD(33*T+j-1,:)' ;
    mom_wHyH2_b(j) = mom_wHyH2_b(j) / sum(mCD(33*T+j-1,:)) ;
	j = j + 1 ;
end


%   Matrix 36: E[DwW DyH2]
%   -----------------------------------------------------------------------

%   Intertemporal co-variances 1999-2009:
j = 2 ;
while j <= T 
	mom_wWyH2_a(j) = (mC(34*T+j-1,:) ...
        - (1 + Veta_h1_w1 + eta_h1_w1^2 + 2*eta_h1_w1) * guH2W(j-1) ...
        - 2*(eta_h1_w2 + COVeta_h1_w1_h1_w2 + eta_h1_w1*eta_h1_w2) * guHW2(j-1) ...
        - (Veta_h1_w2 + eta_h1_w2^2) * guW(j-1)) ...
        * mCD(34*T+j-1,:)' ;
    mom_wWyH2_a(j) = mom_wWyH2_a(j) / sum(mCD(34*T+j-1,:)) ;
	j = j + 1 ;
end

j = start_j ;
while j <= T 
	mom_wWyH2_b(j) = (mC(35*T+j-1,:) ...
        + (1 + Veta_h1_w1 + eta_h1_w1^2 + 2*eta_h1_w1) * guH2W(j-1) ...
        + 2*(eta_h1_w2 + COVeta_h1_w1_h1_w2 + eta_h1_w1*eta_h1_w2) * guHW2(j-1) ...
        + (Veta_h1_w2 + eta_h1_w2^2) * guW(j-1)) ...
        * mCD(35*T+j-1,:)' ;
    mom_wWyH2_b(j) = mom_wWyH2_b(j) / sum(mCD(35*T+j-1,:)) ;
	j = j + 1 ;
end


%   Matrix 18: E[DwH DyW2]
%   -----------------------------------------------------------------------

%   Intertemporal co-variances 1999-2009:
j = 2 ;
while j <= T 
	mom_wHyW2_a(j) = (mC(36*T+j-1,:) ...
        - (Veta_h2_w1 + eta_h2_w1^2) * guH(j-1) ...
        - 2*(eta_h2_w1 + COVeta_h2_w1_h2_w2 + eta_h2_w1*eta_h2_w2) * guH2W(j-1) ...
        - (1 + Veta_h2_w2 + eta_h2_w2^2 + 2*eta_h2_w2) * guHW2(j-1)) ...
        * mCD(36*T+j-1,:)' ;
    mom_wHyW2_a(j) = mom_wHyW2_a(j) / sum(mCD(36*T+j-1,:)) ;
	j = j + 1 ;
end

j = start_j ;
while j <= T 
	mom_wHyW2_b(j) = (mC(37*T+j-1,:) ...
        + (Veta_h2_w1 + eta_h2_w1^2) * guH(j-1) ...
        + 2*(eta_h2_w1 + COVeta_h2_w1_h2_w2 + eta_h2_w1*eta_h2_w2) * guH2W(j-1) ...
        + (1 + Veta_h2_w2 + eta_h2_w2^2 + 2*eta_h2_w2) * guHW2(j-1)) ...
        * mCD(37*T+j-1,:)' ;
    mom_wHyW2_b(j) = mom_wHyW2_b(j) / sum(mCD(37*T+j-1,:)) ;
	j = j + 1 ;
end


%   Matrix 38: E[DwW DyW2]   
%   -----------------------------------------------------------------------

%   Intertemporal co-variances 1999-2009:
j = 2 ;
while j <= T 
	mom_wWyW2_a(j) = (mC(38*T+j-1,:) ...
        - (Veta_h2_w1 + eta_h2_w1^2) * guH2W(j-1) ...
        - 2*(eta_h2_w1 + COVeta_h2_w1_h2_w2 + eta_h2_w1*eta_h2_w2) * guHW2(j-1) ...
        - (1 + Veta_h2_w2 + eta_h2_w2^2 + 2*eta_h2_w2) * guW(j-1)) ...
        * mCD(38*T+j-1,:)' ;
    mom_wWyW2_a(j) = mom_wWyW2_a(j) / sum(mCD(38*T+j-1,:)) ;
	j = j + 1 ;
end

j = start_j ;
while j <= T 
	mom_wWyW2_b(j) = (mC(39*T+j-1,:) ...
        + (Veta_h2_w1 + eta_h2_w1^2) * guH2W(j-1) ...
        + 2*(eta_h2_w1 + COVeta_h2_w1_h2_w2 + eta_h2_w1*eta_h2_w2) * guHW2(j-1) ...
        + (1 + Veta_h2_w2 + eta_h2_w2^2 + 2*eta_h2_w2) * guW(j-1)) ...
        * mCD(39*T+j-1,:)' ;
    mom_wWyW2_b(j) = mom_wWyW2_b(j) / sum(mCD(39*T+j-1,:)) ;
	j = j + 1 ;
end


%   Matrix 1.10: E[DwH Dc2]
%   -----------------------------------------------------------------------

%   Intertemporal co-variances 1999-2009:
j = 2 ;
while j <= T
	mom_wHc2_a(j) = (mC(62*T+j-1,:) ...
        - (Veta_c_w1 + eta_c_w1^2) * guH(j-1) ...
        - 2*(COVeta_c_w1_c_w2 + eta_c_w1*eta_c_w2) * guH2W(j-1) ...
        - (Veta_c_w2 + eta_c_w2^2) * guHW2(j-1)) ...
        * mCD(62*T+j-1,:)' ;
    mom_wHc2_a(j) = mom_wHc2_a(j) / sum(mCD(62*T+j-1,:)) ;
	j = j + 1 ;
end

j = 3 ;
while j <= T
	mom_wHc2_b(j) = (mC(63*T+j-1,:) ...
        + (Veta_c_w1 + eta_c_w1^2) * guH(j-1) ...
        + 2*(COVeta_c_w1_c_w2 + eta_c_w1*eta_c_w2) * guH2W(j-1) ...
        + (Veta_c_w2 + eta_c_w2^2) * guHW2(j-1)) ...
        * mCD(63*T+j-1,:)' ;
    mom_wHc2_b(j) = mom_wHc2_b(j) / sum(mCD(63*T+j-1,:)) ;
	j = j + 1 ;
end


%   Matrix 3.10: E[DwW Dc2] 
%   -----------------------------------------------------------------------

%   Intertemporal co-variances 1999-2009:
j = 2 ;
while j <= T
	mom_wWc2_a(j) = (mC(64*T+j-1,:) ...
        - (Veta_c_w1 + eta_c_w1^2) * guH2W(j-1) ...
        - 2*(COVeta_c_w1_c_w2 + eta_c_w1*eta_c_w2) * guHW2(j-1) ...
        - (Veta_c_w2 + eta_c_w2^2) * guW(j-1)) ...
        * mCD(64*T+j-1,:)' ;
    mom_wWc2_a(j) = mom_wWc2_a(j) / sum(mCD(64*T+j-1,:)) ;
	j = j + 1 ;
end

j = 3 ;
while j <= T
	mom_wWc2_b(j) = (mC(65*T+j-1,:) ...
        + (Veta_c_w1 + eta_c_w1^2) * guH2W(j-1) ...
        + 2*(COVeta_c_w1_c_w2 + eta_c_w1*eta_c_w2) * guHW2(j-1) ...
        + (Veta_c_w2 + eta_c_w2^2) * guW(j-1)) ...
        * mCD(65*T+j-1,:)' ;
    mom_wWc2_b(j) = mom_wWc2_b(j) / sum(mCD(65*T+j-1,:)) ;
	j = j + 1 ;
end


%   Matrix 1.11: E[DwH DyH DyW]
%   -----------------------------------------------------------------------

%   Intertemporal co-variances:
j = 2 ;
while j <= T
	mom_wHyHyW_a(j) = (mC(40*T+j-1,:) ...
        - (eta_h2_w1 + COVeta_h1_w1_h2_w1 + eta_h1_w1*eta_h2_w1) * guH(j-1) ...
        - (1 + eta_h1_w1 + eta_h2_w2 + COVeta_h1_w1_h2_w2 + eta_h1_w1*eta_h2_w2) * guH2W(j-1) ...
        - (COVeta_h1_w2_h2_w1 + eta_h1_w2*eta_h2_w1) * guH2W(j-1) ...
        - (eta_h1_w2 + COVeta_h1_w2_h2_w2 + eta_h1_w2*eta_h2_w2) * guHW2(j-1)) ...    
        * mCD(40*T+j-1,:)' ; 
    mom_wHyHyW_a(j) = mom_wHyHyW_a(j) / sum(mCD(40*T+j-1,:)) ;
	j = j + 1 ;
end

j = start_j ;
while j <= T
	mom_wHyHyW_b(j) = (mC(41*T+j-1,:) ...
        + (eta_h2_w1 + COVeta_h1_w1_h2_w1 + eta_h1_w1*eta_h2_w1) * guH(j-1) ...
        + (1 + eta_h1_w1 + eta_h2_w2 + COVeta_h1_w1_h2_w2 + eta_h1_w1*eta_h2_w2) * guH2W(j-1) ...
        + (COVeta_h1_w2_h2_w1 + eta_h1_w2*eta_h2_w1) * guH2W(j-1) ...
        + (eta_h1_w2 + COVeta_h1_w2_h2_w2 + eta_h1_w2*eta_h2_w2) * guHW2(j-1)) ... 
        * mCD(41*T+j-1,:)' ;
    mom_wHyHyW_b(j) = mom_wHyHyW_b(j) / sum(mCD(41*T+j-1,:)) ;
	j = j + 1 ;
end


%   Matrix 3.11: E[DwW DyH DyW]    
%   -----------------------------------------------------------------------

%   Intertemporal co-variances:
j = 2 ;
while j <= T
	mom_wWyHyW_a(j) = (mC(42*T+j-1,:) ...
        - (eta_h2_w1 + COVeta_h1_w1_h2_w1 + eta_h1_w1*eta_h2_w1) * guH2W(j-1) ...
        - (1 + eta_h1_w1 + eta_h2_w2 + COVeta_h1_w1_h2_w2 + eta_h1_w1*eta_h2_w2) * guHW2(j-1) ...
        - (COVeta_h1_w2_h2_w1 + eta_h1_w2*eta_h2_w1) * guHW2(j-1) ...
        - (eta_h1_w2 + COVeta_h1_w2_h2_w2 + eta_h1_w2*eta_h2_w2) * guW(j-1)) ...    
        * mCD(42*T+j-1,:)' ; 
    mom_wWyHyW_a(j) = mom_wWyHyW_a(j) / sum(mCD(42*T+j-1,:)) ;
	j = j + 1 ;
end

j = start_j ;
while j <= T
	mom_wWyHyW_b(j) = (mC(43*T+j-1,:) ...
        + (eta_h2_w1 + COVeta_h1_w1_h2_w1 + eta_h1_w1*eta_h2_w1) * guH2W(j-1) ...
        + (1 + eta_h1_w1 + eta_h2_w2 + COVeta_h1_w1_h2_w2 + eta_h1_w1*eta_h2_w2) * guHW2(j-1) ...
        + (COVeta_h1_w2_h2_w1 + eta_h1_w2*eta_h2_w1) * guHW2(j-1) ...
        + (eta_h1_w2 + COVeta_h1_w2_h2_w2 + eta_h1_w2*eta_h2_w2) * guW(j-1)) ... 
        * mCD(43*T+j-1,:)' ;
    mom_wWyHyW_b(j) = mom_wWyHyW_b(j) / sum(mCD(43*T+j-1,:)) ;
	j = j + 1 ;
end


%   Matrix 1.12: E[DwH DyH Dc]
%   -----------------------------------------------------------------------

%   Intertemporal co-variances 1999-2009:
j = 2 ;
while j <= T 
	mom_wHyHc_a(j) = (mC(66*T+j-1,:) ...
        - (eta_c_w1 + COVeta_c_w1_h1_w1 + eta_c_w1*eta_h1_w1) * guH(j-1) ...
        - (eta_c_w2 + COVeta_c_w2_h1_w1 + eta_c_w2*eta_h1_w1) * guH2W(j-1) ...
        - (COVeta_c_w1_h1_w2 + eta_c_w1*eta_h1_w2) * guH2W(j-1) ...
        - (COVeta_c_w2_h1_w2 + eta_c_w2*eta_h1_w2) * guHW2(j-1)) ...
        * mCD(66*T+j-1,:)' ;
    mom_wHyHc_a(j) = mom_wHyHc_a(j) / sum(mCD(66*T+j-1,:)) ;
	j = j + 1 ;
end

j = 3 ;
while j <= T 
	mom_wHyHc_b(j) = (mC(67*T+j-1,:) ...
        + (eta_c_w1 + COVeta_c_w1_h1_w1 + eta_c_w1*eta_h1_w1) * guH(j-1) ...
        + (eta_c_w2 + COVeta_c_w2_h1_w1 + eta_c_w2*eta_h1_w1) * guH2W(j-1) ...
        + (COVeta_c_w1_h1_w2 + eta_c_w1*eta_h1_w2) * guH2W(j-1) ...
        + (COVeta_c_w2_h1_w2 + eta_c_w2*eta_h1_w2) * guHW2(j-1)) ...
        * mCD(67*T+j-1,:)' ; 
    mom_wHyHc_b(j) = mom_wHyHc_b(j) / sum(mCD(67*T+j-1,:)) ;
	j = j + 1 ;
end


%   Matrix 3.12: E[DwW DyH Dc] 
%   -----------------------------------------------------------------------

%   Intertemporal co-variances 1999-2009:
j = 2 ;
while j <= T 
	mom_wWyHc_a(j) = (mC(68*T+j-1,:) ...
        - (eta_c_w1 + COVeta_c_w1_h1_w1 + eta_c_w1*eta_h1_w1) * guH2W(j-1) ...
        - (eta_c_w2 + COVeta_c_w2_h1_w1 + eta_c_w2*eta_h1_w1) * guHW2(j-1) ...
        - (COVeta_c_w1_h1_w2 + eta_c_w1*eta_h1_w2) * guHW2(j-1) ...
        - (COVeta_c_w2_h1_w2 + eta_c_w2*eta_h1_w2) * guW(j-1)) ...
        * mCD(68*T+j-1,:)' ;
    mom_wWyHc_a(j) = mom_wWyHc_a(j) / sum(mCD(68*T+j-1,:)) ;
	j = j + 1 ;
end

j = 3 ;
while j <= T 
	mom_wWyHc_b(j) = (mC(69*T+j-1,:) ...
        + (eta_c_w1 + COVeta_c_w1_h1_w1 + eta_c_w1*eta_h1_w1) * guH2W(j-1) ...
        + (eta_c_w2 + COVeta_c_w2_h1_w1 + eta_c_w2*eta_h1_w1) * guHW2(j-1) ...
        + (COVeta_c_w1_h1_w2 + eta_c_w1*eta_h1_w2) * guHW2(j-1) ...
        + (COVeta_c_w2_h1_w2 + eta_c_w2*eta_h1_w2) * guW(j-1)) ...
        * mCD(69*T+j-1,:)' ; 
    mom_wWyHc_b(j) = mom_wWyHc_b(j) / sum(mCD(69*T+j-1,:)) ;
	j = j + 1 ;
end


%   Matrix 1.13: E[DwH DyW Dc]
%   -----------------------------------------------------------------------

%   Intertemporal co-variances:
j = 2 ;
while j <= T 
	mom_wHyWc_a(j) = (mC(70*T+j-1,:) ...
        - (COVeta_c_w1_h2_w1 + eta_c_w1*eta_h2_w1) * guH(j-1) ...
        - (COVeta_c_w2_h2_w1 + eta_c_w2*eta_h2_w1) * guH2W(j-1) ...
        - (eta_c_w1 + COVeta_c_w1_h2_w2 + eta_c_w1*eta_h2_w2) * guH2W(j-1) ...
        - (eta_c_w2 + COVeta_c_w2_h2_w2 + eta_c_w2*eta_h2_w2) * guHW2(j-1)) ...      
        * mCD(70*T+j-1,:)' ; 
    mom_wHyWc_a(j) = mom_wHyWc_a(j) / sum(mCD(70*T+j-1,:)) ;
	j = j + 1 ;
end

j = 3 ;
while j <= T
	mom_wHyWc_b(j) = (mC(71*T+j-1,:) ...
        + (COVeta_c_w1_h2_w1 + eta_c_w1*eta_h2_w1) * guH(j-1) ...
        + (COVeta_c_w2_h2_w1 + eta_c_w2*eta_h2_w1) * guH2W(j-1) ...
        + (eta_c_w1 + COVeta_c_w1_h2_w2 + eta_c_w1*eta_h2_w2) * guH2W(j-1) ...
        + (eta_c_w2 + COVeta_c_w2_h2_w2 + eta_c_w2*eta_h2_w2) * guHW2(j-1)) ... 
        * mCD(71*T+j-1,:)' ; 
    mom_wHyWc_b(j) = mom_wHyWc_b(j) / sum(mCD(71*T+j-1,:)) ;
	j = j + 1 ;
end


%   Matrix 3.13: E[DwW DyW Dc] 
%   -----------------------------------------------------------------------

%   Intertemporal co-variances:
j = 2 ;
while j <= T 
	mom_wWyWc_a(j) = (mC(72*T+j-1,:) ...
        - (COVeta_c_w1_h2_w1 + eta_c_w1*eta_h2_w1) * guH2W(j-1) ...
        - (COVeta_c_w2_h2_w1 + eta_c_w2*eta_h2_w1) * guHW2(j-1) ...
        - (eta_c_w1 + COVeta_c_w1_h2_w2 + eta_c_w1*eta_h2_w2) * guHW2(j-1) ...
        - (eta_c_w2 + COVeta_c_w2_h2_w2 + eta_c_w2*eta_h2_w2) * guW(j-1)) ...      
        * mCD(72*T+j-1,:)' ; 
    mom_wWyWc_a(j) = mom_wWyWc_a(j) / sum(mCD(72*T+j-1,:)) ;
	j = j + 1 ;
end

j = 3 ;
while j <= T
	mom_wWyWc_b(j) = (mC(73*T+j-1,:) ...
        + (COVeta_c_w1_h2_w1 + eta_c_w1*eta_h2_w1) * guH2W(j-1) ...
        + (COVeta_c_w2_h2_w1 + eta_c_w2*eta_h2_w1) * guHW2(j-1) ...
        + (eta_c_w1 + COVeta_c_w1_h2_w2 + eta_c_w1*eta_h2_w2) * guHW2(j-1) ...
        + (eta_c_w2 + COVeta_c_w2_h2_w2 + eta_c_w2*eta_h2_w2) * guW(j-1)) ... 
        * mCD(73*T+j-1,:)' ; 
    mom_wWyWc_b(j) = mom_wWyWc_b(j) / sum(mCD(73*T+j-1,:)) ;
	j = j + 1 ;
end
end %if higher_moments >= 1


%%  7.  STACK MOMENTS TOGETHER; CHOOSE WEIGHTING MATRIX
%   Stack vectors of moments together; choose GMM weighting matrix
%   -----------------------------------------------------------------------

%   Stack together (I condition some consumption vectors to 3:T so as to 
%   remove NaN entries resulting from devision by 0 in years when
%   consumption is not observed in the data):
    
vMoms = [       mean(mom_wHyH_a(2:T))           ; ...
                mean(mom_wHyH_b(start_j:T))     ; ...
                mean(mom_wWyH_a(2:T))           ; ...
                mean(mom_wWyH_b(start_j:T))     ; ...
                mean(mom_wHyW_a(2:T))           ; ...
                mean(mom_wHyW_b(start_j:T))     ; ...
                mean(mom_wWyW_a(2:T))           ; ...
                mean(mom_wWyW_b(start_j:T))     ; ...
                mean(mom_wHc_a(2:T))            ; ...
                mean(mom_wHc_b(3:T))            ; ... 
                mean(mom_wWc_a(2:T))            ; ...
                mean(mom_wWc_b(3:T))            ; ...       
                mean(mom_yHyH_a(start_j:T))     ; ...
                mean(mom_yHyW_a(start_j:T))     ; ...
                mean(mom_yHyW_b(start_j:T))     ; ...
                mean(mom_yWyW_a(start_j:T))     ; ...
                mean(mom_yHc_a(start_j:T))      ; ...
                mean(mom_yHc_b(3:T))            ; ...
                mean(mom_yWc_a(start_j:T))      ; ...
                mean(mom_yWc_b(3:T))            ; ...
                mean(mom_cc_a(3:T)) ]           ;
    
if      higher_moments == -1
    vtMoms = [  mean(mom_wHyH(2:T-1))           ; ...
                mean(mom_wWyH(2:T-1))           ; ...
                mean(mom_wHyW(2:T-1))           ; ...
                mean(mom_wWyW(2:T-1))           ; ...
                mean(mom_wHc(2:T-1))            ; ...
                mean(mom_wWc(2:T-1))            ; ... 
                mean(mom_yHyH(2:T-1))           ; ...
                mean(mom_yHyW(2:T-1))           ; ...
                mean(mom_yWyW(2:T-1))           ; ...
                mean(mom_yHc(2:T-1))            ; ...
                mean(mom_yWc(2:T-1))            ; ...
                mean(mom_cc(2:T-1)) ]           ;
    vMoms = [vMoms;vtMoms] ;
elseif  higher_moments == 1
    v3Moms = [  mean(mom_wH2yH_a(2:T))          ; ...
                mean(mom_wH2yH_b(start_j:T))    ; ...
                mean(mom_wW2yH_a(2:T))          ; ...
                mean(mom_wW2yH_b(start_j:T))    ; ...
                mean(mom_wH2yW_a(2:T))          ; ...
                mean(mom_wH2yW_b(start_j:T))    ; ...
                mean(mom_wW2yW_a(2:T))          ; ... 
                mean(mom_wW2yW_b(start_j:T))    ; ... 
                mean(mom_wH2c_a(2:T))           ; ...
                mean(mom_wH2c_b(3:T))           ; ...
                mean(mom_wW2c_a(2:T))           ; ...
                mean(mom_wW2c_b(3:T))           ; ...
                mean(mom_wHyH2_a(2:T))          ; ...
                mean(mom_wHyH2_b(start_j:T))    ; ...
                mean(mom_wWyH2_a(2:T))          ; ...
                mean(mom_wWyH2_b(start_j:T))    ; ...
                mean(mom_wHyW2_a(2:T))          ; ...
                mean(mom_wHyW2_b(start_j:T))    ; ...
                mean(mom_wWyW2_a(2:T))          ; ...
                mean(mom_wWyW2_b(start_j:T))    ; ...
                mean(mom_wHc2_a(2:T))           ; ...
                mean(mom_wHc2_b(3:T))           ; ...
                mean(mom_wWc2_a(2:T))           ; ...
                mean(mom_wWc2_b(3:T))           ; ...
                mean(mom_wHyHyW_a(2:T))         ; ...
                mean(mom_wHyHyW_b(start_j:T))   ; ...
                mean(mom_wWyHyW_a(2:T))         ; ...
                mean(mom_wWyHyW_b(start_j:T))   ; ...
                mean(mom_wHyHc_a(2:T))          ; ...
                mean(mom_wHyHc_b(3:T))          ; ...
                mean(mom_wWyHc_a(2:T))          ; ...
                mean(mom_wWyHc_b(3:T))          ; ...
                mean(mom_wHyWc_a(2:T))          ; ...
                mean(mom_wHyWc_b(3:T))          ; ...
                mean(mom_wWyWc_a(2:T))          ; ...
                mean(mom_wWyWc_b(3:T)) ]        ;
    vMoms = [vMoms;v3Moms] ;
end %higher_moments == -1

%   Declare appropriate weighting matrix:

%   A. Equally weighted GMM:
if isequal(type_wmatrix,'eye')
    wmatrix = eye(size(vMoms,1)) ;
    
%   B. Diagonally weighted GMM:
%   Note: I normalize the weighting matrix by 1e-4.
else                                    
    if      higher_moments == -1
        wtrans = cell2mat(type_wmatrix(1)) ;
        wbps   = cell2mat(type_wmatrix(2)) ;
        wmatrix = diag([wtrans(24:44);wbps].^(-1))./1e+4 ;
    elseif  higher_moments == 0
        wmatrix = diag(type_wmatrix(24:44).^(-1))./1e+4 ;
    elseif  higher_moments == 1
        wmatrix = diag(type_wmatrix(24:80).^(-1))./1e+4 ;
    else
    end 
    
end


%%  9.  DELIVER CRITERION OBJECTIVE FUNCTION
%   -----------------------------------------------------------------------

%   Objective function criterion:
f = vMoms' * wmatrix * vMoms ;