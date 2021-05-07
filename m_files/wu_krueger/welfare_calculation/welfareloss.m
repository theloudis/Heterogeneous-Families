function CEV = welfareloss(par, before, after)

%{ 
    This function calculates the welfare loss of idiosyncratic wage risk
    in terms of consumption equivalent variation. 

    This code is an adaptation to the original code provided by 
    Wu & Krueger (2020), 'Consumption Insurance Against Wage Risk',
    published in AEJ-Macro.

    Alexandros Theloudis
    -----------------------------------------------------------------------
%}
    
    % Structure 'before' has information on households when there is 
    % no wage risk; structure 'after' has information with wage risk.
    
    % Total welfare loss from wage risk:
    CEV.total       = (1+(after.V-before.V)/before.VC)^(1/(1-par.sigma))-1;

    % Welfare loss from consumption:
    CEV.C           = (1+(after.VC-before.VC)/before.VC)^(1/(1-par.sigma))-1;
    CEV.C_level     = (after.C/before.C)-1;
    CEV.C_dist      = (1+(after.VC-(after.C/before.C)^(1-par.sigma)*before.VC)...
                        /((after.C/before.C)^(1-par.sigma)*before.VC))^(1/(1-par.sigma))-1;
    
    % Welfare loss from hours:
    CEV.H           = (1+(after.VH-before.VH)/after.VC)^(1/(1-par.sigma))-1;
    
    % Welfare loss from male hours:
    CEV.H1          = (1+(after.VH1-before.VH1)/after.VC)^(1/(1-par.sigma))-1;
    CEV.H1_level    = (1+((after.H1/before.H1)^(1+1/par.eta1)-1)*before.VH1/after.VC)^(1/(1-par.sigma))-1;
    CEV.H1_dist     = (1+(after.VH1-(after.H1/before.H1)^(1+1/par.eta1)*before.VH1)/((1+CEV.H1_level)^(1-par.sigma)*after.VC))^(1/(1-par.sigma))-1;
    
    % Welfare loss from female hours:
    CEV.H2          = (1+(after.VH-after.VH1-before.VH+before.VH1)/((1+CEV.H1)^(1-par.sigma)*after.VC))^(1/(1-par.sigma))-1;
    CEV.H2_level    = (1+((after.H2/before.H2)^(1+1/par.eta2)-1)*before.VH2/((1+CEV.H1)^(1-par.sigma)*after.VC))^(1/(1-par.sigma))-1;
    CEV.H2_dist     = (1+(after.VH-after.VH1-((after.H2/before.H2)^(1+1/par.eta2)*before.VH2+before.VH-before.VH1-before.VH2))...
                        /(((1+CEV.H1)*(1+CEV.H2_level))^(1-par.sigma)*after.VC))^(1/(1-par.sigma))-1;
end