function f = wage_structure_timeaggr(vParams,mC,mCD,merrC,do_higher_moments,type_wmatrix,M)
%{
    This function generates the moment conditions for the estimation of 
    the second and higher moments of the wage process addressing
    neglected time aggregation in the PSID.

    Alexandros Theloudis
    -----------------------------------------------------------------------
%}

%   Initial statements:
global T ;


%%  1.  INITIALIZE OBJECTS
%   Initialize parameters and vectors to hold moments
%   -----------------------------------------------------------------------

%   Vectors of second moments of shocks:
vH  = vParams(1) ;   % variance:    permanent shock HD
uH  = vParams(2) ;   % variance:    transitory shock HD
vW  = vParams(3) ;   % variance:    permanent shock WF
uW  = vParams(4) ;   % variance:    transitory shock WF
vHW = vParams(5) ;   % covariance:  permanent shocks
uHW = vParams(6) ;   % covariance:  transitory shocks

%   Vectors of third moments of shocks:
if do_higher_moments >= 1
gvH   = vParams(9)  ; % skewness:    permanent shock HD
guH   = vParams(10) ; % skewness:    transitory shock HD
gvW   = vParams(11) ; % skewness:    permanent shock WF
guW   = vParams(12) ; % skewness:    transitory shock WF
gvH2W = vParams(13) ; % third cross moment: E[vH^2 vW]
guH2W = vParams(14) ; % third cross moment: E[uH^2 uW]
gvHW2 = vParams(15) ; % third cross moment: E[vH vW^2]
guHW2 = vParams(16) ; % third cross moment: E[uH uW^2]
end

%   Vectors to hold second wage moments:
%   matrix 11: E[DwH DwH]
mom_wHwH    = zeros(T,1) ;     
mom_wHwH_a  = zeros(T,1) ;
%   matrix 13: E[DwH DwW] 
mom_wHwW    = zeros(T,1) ;
mom_wHwW_a  = zeros(T,1) ;
mom_wHwW_b  = zeros(T,1) ;
%   matrix 33: E[DwW DwW]   
mom_wWwW    = zeros(T,1) ;
mom_wWwW_a  = zeros(T,1) ;

%   Vectors to hold third wage moments:
if do_higher_moments >= 1
%   matrix 12: E[DwH DwH2]
mom_wHwH2   = zeros(T,1) ;     
mom_wHwH2_a = zeros(T,1) ;
mom_wHwH2_b = zeros(T,1) ;
%   matrix 23: E[DwH2 DwW]
mom_wH2wW   = zeros(T,1) ;     
mom_wH2wW_a = zeros(T,1) ;
mom_wH2wW_b = zeros(T,1) ;
%   matrix 14: E[DwH DwW2]
mom_wHwW2   = zeros(T,1) ;     
mom_wHwW2_a = zeros(T,1) ;
mom_wHwW2_b = zeros(T,1) ;
%   matrix 34: E[DwW DwW2]
mom_wWwW2   = zeros(T,1) ;
mom_wWwW2_a = zeros(T,1) ;
mom_wWwW2_b = zeros(T,1) ;
%   matrix X.31: E[DwW DwH DwH']
mom_wWwHwHt   = zeros(T,1) ;
mom_wWwHwHt_b = zeros(T,1) ;
%   matrix X.13: E[DwH DwW DwW']
mom_wHwWwWt   = zeros(T,1) ;
mom_wHwWwWt_b = zeros(T,1) ;
end


%%  2.  SECOND MOMENTS OF WAGES
%   Construct vector of moments E(data_moment_i - model_moment_i) = 0
%   -----------------------------------------------------------------------

%   Matrix 11: E[DwH DwH]   
%   -----------------------------------------------------------------------

%   Variances:
j = 2 ;
while j <= T-1  
    mom_wHwH(j) = ((mC(j,:).*mC(j,:)) - merrC(j,1) - merrC(j-1,1) ...
        - (1/3)*(5*M^3 + M)*vH - 2*M*uH) * mCD(j,:)' ;
    mom_wHwH(j) = mom_wHwH(j) / (mCD(j,:)*mCD(j,:)') ;
    j = j + 1 ;
end 
    
%   Intertemporal covariances:
j = 2 ;
while j <= T
    mom_wHwH_a(j) = ((mC(j,:).*mC(j-1,:)) + merrC(j-1,1) ...
        - (1/6)*(M^3 - M)*vH + M*uH) * (mCD(j,:).*mCD(j-1,:))' ;
    mom_wHwH_a(j) = mom_wHwH_a(j) / (mCD(j,:)*mCD(j-1,:)') ;
    j = j + 1 ;
end

%   Matrix 13: E[DwH DwW]   
%   -----------------------------------------------------------------------

%   Auto-coVariances:
j = 2 ;
while j <= T-1
	mom_wHwW(j) = ((mC(j,:).*mC(2*T+j,:)) ...
        - (1/3)*(5*M^3 + M)*vHW - 2*M*uHW) * (mCD(j,:).*mCD(2*T+j,:))' ;
    mom_wHwW(j) = mom_wHwW(j) / (mCD(j,:)*mCD(2*T+j,:)') ;
	j = j + 1 ;
end
    
%   Intertemporal covariances:
j = 2 ;
while j <= T 
    mom_wHwW_a(j) = ((mC(j-1,:).*mC(2*T+j,:)) ...
        - (1/6)*(M^3 - M)*vHW + M*uHW) * (mCD(j-1,:).*mCD(2*T+j,:))' ;
    mom_wHwW_a(j) = mom_wHwW_a(j) / (mCD(j-1,:)*mCD(2*T+j,:)') ;
	j = j + 1 ;
end

j = 2 ;
while j <= T 
	mom_wHwW_b(j) = ((mC(j,:).*mC(2*T+j-1,:)) ...
        - (1/6)*(M^3 - M)*vHW + M*uHW) * (mCD(j,:).*mCD(2*T+j-1,:))' ; 
    mom_wHwW_b(j) = mom_wHwW_b(j) / (mCD(j,:)*mCD(2*T+j-1,:)') ;
	j = j + 1 ;
end

%   Matrix 33: E[DwW DwW]   
%   -----------------------------------------------------------------------

%   Variances:
j = 2 ;
while j <= T-1
    mom_wWwW(j) = ((mC(2*T+j,:).*mC(2*T+j,:)) - merrC(j,2) - merrC(j-1,2) ...
        - (1/3)*(5*M^3 + M)*vW - 2*M*uW) * mCD(2*T+j,:)' ;
    mom_wWwW(j) = mom_wWwW(j) / (mCD(2*T+j,:)*mCD(2*T+j,:)') ;
    j = j + 1 ;
end 
    
%   Intertemporal covariances:
j = 2 ;
while j <= T
    mom_wWwW_a(j) = ((mC(2*T+j,:).*mC(2*T+j-1,:)) + merrC(j-1,2) ...
        - (1/6)*(M^3 - M)*vW + M*uW) * (mCD(2*T+j,:).*mCD(2*T+j-1,:))' ;
    mom_wWwW_a(j) = mom_wWwW_a(j) / (mCD(2*T+j,:)*mCD(2*T+j-1,:)') ;
    j = j + 1 ;
end


%%  3.  THIRD MOMENTS OF WAGES
%   Construct vector of moments E(data_moment_i - model_moment_i) = 0
%   -----------------------------------------------------------------------

if do_higher_moments >= 1
    
%   Matrix 12: E[DwH DwH2]   
%   -----------------------------------------------------------------------

%   Variances:
j = 2 ;
while j <= T-1  
    mom_wHwH2(j) = ((mC(j,:).*mC(T+j,:)) ...
        - (1/2)*(M^2)*(3*M^2 + 1)*gvH) * (mCD(j,:).*mCD(T+j,:))' ;
    mom_wHwH2(j) = mom_wHwH2(j) / (mCD(j,:)*mCD(T+j,:)') ;
    j = j + 1 ;
end 
    
%   Intertemporal covariances:
j = 2 ;
while j <= T 
    mom_wHwH2_a(j) = ((mC(j-1,:).*mC(T+j,:)) ...
        - (1/12)*(M^4 - M^2)*gvH - M*guH) * (mCD(j-1,:).*mCD(T+j,:))' ;
    mom_wHwH2_a(j) = mom_wHwH2_a(j) / (mCD(j-1,:)*mCD(T+j,:)') ;
	j = j + 1 ;
end

j = 2 ;
while j <= T 
	mom_wHwH2_b(j) = ((mC(j,:).*mC(T+j-1,:)) ...
        - (1/12)*(M^4 - M^2)*gvH + M*guH) * (mCD(j,:).*mCD(T+j-1,:))' ; 
    mom_wHwH2_b(j) = mom_wHwH2_b(j) / (mCD(j,:)*mCD(T+j-1,:)') ;
	j = j + 1 ;
end

%   Matrix 23: E[DwH2 DwW]   
%   -----------------------------------------------------------------------

%   Variances:
j = 2 ;
while j <= T-1  
    mom_wH2wW(j) = ((mC(T+j,:).*mC(2*T+j,:)) ...
        - (1/2)*(M^2)*(3*M^2 + 1)*gvH2W) * (mCD(T+j,:).*mCD(2*T+j,:))' ;
    mom_wH2wW(j) = mom_wH2wW(j) / (mCD(T+j,:)*mCD(2*T+j,:)') ;
    j = j + 1 ;
end 
    
%   Intertemporal covariances:
j = 2 ;
while j <= T 
    mom_wH2wW_a(j) = ((mC(T+j-1,:).*mC(2*T+j,:)) ...
        - (1/12)*(M^4 - M^2)*gvH2W + M*guH2W) * (mCD(T+j-1,:).*mCD(2*T+j,:))' ;
    mom_wH2wW_a(j) = mom_wH2wW_a(j) / (mCD(T+j-1,:)*mCD(2*T+j,:)') ;
	j = j + 1 ;
end

j = 2 ;
while j <= T 
	mom_wH2wW_b(j) = ((mC(T+j,:).*mC(2*T+j-1,:)) ...
        - (1/12)*(M^4 - M^2)*gvH2W - M*guH2W) * (mCD(T+j,:).*mCD(2*T+j-1,:))' ; 
    mom_wH2wW_b(j) = mom_wH2wW_b(j) / (mCD(T+j,:)*mCD(2*T+j-1,:)') ;
	j = j + 1 ;
end

%   Matrix 14: E[DwH DwW2]   
%   -----------------------------------------------------------------------

%   Variances:
j = 2 ;
while j <= T-1  
    mom_wHwW2(j) = ((mC(j,:).*mC(3*T+j,:)) ...
        - (1/2)*(M^2)*(3*M^2 + 1)*gvHW2) * (mCD(j,:).*mCD(3*T+j,:))' ;
    mom_wHwW2(j) = mom_wHwW2(j) / (mCD(j,:)*mCD(3*T+j,:)') ;
    j = j + 1 ;
end 

%   Intertemporal covariances:
j = 2 ;
while j <= T 
    mom_wHwW2_a(j) = ((mC(j-1,:).*mC(3*T+j,:)) ...
        - (1/12)*(M^4 - M^2)*gvHW2 - M*guHW2) * (mCD(j-1,:).*mCD(3*T+j,:))' ;
    mom_wHwW2_a(j) = mom_wHwW2_a(j) / (mCD(j-1,:)*mCD(3*T+j,:)') ;
	j = j + 1 ;
end

j = 2 ;
while j <= T 
	mom_wHwW2_b(j) = ((mC(j,:).*mC(3*T+j-1,:)) ...
        - (1/12)*(M^4 - M^2)*gvHW2 + M*guHW2) * (mCD(j,:).*mCD(3*T+j-1,:))' ; 
    mom_wHwW2_b(j) = mom_wHwW2_b(j) / (mCD(j,:)*mCD(3*T+j-1,:)') ;
	j = j + 1 ;
end

%   Matrix 34: E[DwW DwW2]
%   -----------------------------------------------------------------------

%   Variances:
j = 2 ;
while j <= T-1  
    mom_wWwW2(j) = ((mC(2*T+j,:).*mC(3*T+j,:)) ...
        - (1/2)*(M^2)*(3*M^2 + 1)*gvW) * (mCD(2*T+j,:).*mCD(3*T+j,:))' ;
    mom_wWwW2(j) = mom_wWwW2(j) / (mCD(2*T+j,:)*mCD(3*T+j,:)') ;
    j = j + 1 ;
end 
    
%   Intertemporal covariances:
j = 2 ;
while j <= T 
    mom_wWwW2_a(j) = ((mC(2*T+j-1,:).*mC(3*T+j,:)) ...
        - (1/12)*(M^4 - M^2)*gvW - M*guW) * (mCD(2*T+j-1,:).*mCD(3*T+j,:))' ;
    mom_wWwW2_a(j) = mom_wWwW2_a(j) / (mCD(2*T+j-1,:)*mCD(3*T+j,:)') ;
	j = j + 1 ;
end

j = 2 ;
while j <= T 
	mom_wWwW2_b(j) = ((mC(2*T+j,:).*mC(3*T+j-1,:)) ...
        - (1/12)*(M^4 - M^2)*gvW + M*guW) * (mCD(2*T+j,:).*mCD(3*T+j-1,:))' ; 
    mom_wWwW2_b(j) = mom_wWwW2_b(j) / (mCD(2*T+j,:)*mCD(3*T+j-1,:)') ;
	j = j + 1 ;
end

%   Matrix X.31: E[DwW DwH DwH']
%   -----------------------------------------------------------------------

%   Intertemporal covariances:
j = 2 ;
while j <= T 
    mom_wWwHwHt(j) = ((mC(2*T+j-1,:).*mC(j-1,:).*mC(j,:)) ...
        - (1/12)*(M^4 - M^2)*gvH2W + M*guH2W) * (mCD(2*T+j-1,:).*mCD(j-1,:).*mCD(j,:))' ;
    mom_wWwHwHt(j) = mom_wWwHwHt(j) / ((mCD(2*T+j-1,:).*mCD(j-1,:))*mCD(j,:)') ;
	j = j + 1 ;
end

j = 2 ;
while j <= T 
	mom_wWwHwHt_b(j) = ((mC(2*T+j,:).*mC(j-1,:).*mC(j,:)) ...
        - (1/12)*(M^4 - M^2)*gvH2W - M*guH2W) * (mCD(2*T+j,:).*mCD(j-1,:).*mCD(j,:))' ;
    mom_wWwHwHt_b(j) = mom_wWwHwHt_b(j) / ((mCD(2*T+j,:).*mCD(j-1,:))*mCD(j,:)') ;
	j = j + 1 ;
end

%   Matrix X.13: E[DwH DwW DwW']
%   -----------------------------------------------------------------------
    
%   Intertemporal covariances:
j = 2 ;
while j <= T 
    mom_wHwWwWt(j) = ((mC(j-1,:).*mC(2*T+j-1,:).*mC(2*T+j,:)) ...
        - (1/12)*(M^4 - M^2)*gvHW2 + M*guHW2) * (mCD(j-1,:).*mCD(2*T+j-1,:).*mCD(2*T+j,:))' ;
    mom_wHwWwWt(j) = mom_wHwWwWt(j) / ((mCD(j-1,:).*mCD(2*T+j-1,:))*mCD(2*T+j,:)') ;
	j = j + 1 ;
end

j = 2 ;
while j <= T 
	mom_wHwWwWt_b(j) = ((mC(j,:).*mC(2*T+j-1,:).*mC(2*T+j,:)) ...
        - (1/12)*(M^4 - M^2)*gvHW2 - M*guHW2) * (mCD(j,:).*mCD(2*T+j-1,:).*mCD(2*T+j,:))' ;
    mom_wHwWwWt_b(j) = mom_wHwWwWt_b(j) / ((mCD(j,:).*mCD(2*T+j-1,:))*mCD(2*T+j,:)') ;
	j = j + 1 ;
end
end %if do_higher_moments == 1


%%  4.  CHOOSE WEIGHTING MATRIX AND STACK MOMENTS TOGETHER
%   Choose GMM weighting matrix; stack vectors of moments together.
%   -----------------------------------------------------------------------

%   Declare appropriate weighting matrix:
%   A. Equally weighted GMM:
if isequal(type_wmatrix,'eye') 
    
    %   Stack moments together:
    vMoms = [   mean(mom_wHwH(2:T-1))  ; ...      
                mean(mom_wHwH_a(2:T))  ; ...
                mean(mom_wHwW(2:T-1))  ; ...
                mean(mom_wHwW_a(2:T))  ; ...
                mean(mom_wHwW_b(2:T))  ; ...
                mean(mom_wWwW(2:T-1))  ; ...
                mean(mom_wWwW_a(2:T))] ;
    if do_higher_moments >= 1
    v3Moms = [  mean(mom_wHwH2(2:T-1))    ; ...    
                mean(mom_wHwH2_a(2:T))    ; ...
                mean(mom_wHwH2_b(2:T))    ; ...
                mean(mom_wH2wW(2:T-1))    ; ... 
                mean(mom_wH2wW_a(2:T))    ; ...
                mean(mom_wH2wW_b(2:T))    ; ...
                mean(mom_wHwW2(2:T-1))    ; ... 
                mean(mom_wHwW2_a(2:T))    ; ...
                mean(mom_wHwW2_b(2:T))    ; ...
                mean(mom_wWwW2(2:T-1))    ; ...
                mean(mom_wWwW2_a(2:T))    ; ...
                mean(mom_wWwW2_b(2:T))    ; ...
                mean(mom_wWwHwHt(2:T))    ; ...  
                mean(mom_wWwHwHt_b(2:T))  ; ... 
                mean(mom_wHwWwWt(2:T))    ; ...   
                mean(mom_wHwWwWt_b(2:T)) ];
    vMoms = [vMoms;v3Moms] ;
    end
    
    %   Declare matrix:
    wmatrix = eye(size(vMoms,1)) ;

%   B. Diagonally weighted GMM:
else
    
    %   Stack moments together:
    vMoms = [   mean(mom_wHwH(2:T-1))  ; ...      
                mean(mom_wHwH_a(2:T))  ; ...
                mean(mom_wHwW(2:T-1))  ; ...
                mean(mom_wHwW_a(2:T))  ; ...
                mean(mom_wHwW_b(2:T))  ; ...
                mean(mom_wWwW(2:T-1))  ; ...
                mean(mom_wWwW_a(2:T))] ;
    if do_higher_moments >= 1
    v3Moms = [  mean(mom_wHwH2(2:T-1))    ; ...    
                mean(mom_wHwH2_a(2:T))    ; ...
                mean(mom_wHwH2_b(2:T))    ; ...
                mean(mom_wH2wW(2:T-1))    ; ... 
                mean(mom_wH2wW_a(2:T))    ; ...
                mean(mom_wH2wW_b(2:T))    ; ...
                mean(mom_wHwW2(2:T-1))    ; ... 
                mean(mom_wHwW2_a(2:T))    ; ...
                mean(mom_wHwW2_b(2:T))    ; ...
                mean(mom_wWwW2(2:T-1))    ; ...
                mean(mom_wWwW2_a(2:T))    ; ...
                mean(mom_wWwW2_b(2:T))    ; ...
                mean(mom_wWwHwHt(2:T))    ; ...  
                mean(mom_wWwHwHt_b(2:T))  ; ... 
                mean(mom_wHwWwWt(2:T))    ; ...   
                mean(mom_wHwWwWt_b(2:T)) ];
    vMoms = [vMoms;v3Moms] ;
    end
    
    %   Declare matrix:
    %   Note: I normalize the weighting matrix by 1e-4.
    if do_higher_moments >= 1           
        wmatrix = diag(type_wmatrix(1:23).^(-1))./1e+4 ;
    else
        wmatrix = diag(type_wmatrix(1:7).^(-1))./1e+4 ;
    end 
end


%%  5.  DELIVER CRITERION OBJECTIVE FUNCTION
%   -----------------------------------------------------------------------

%   Objective function criterion:
f = vMoms' * wmatrix * vMoms ;