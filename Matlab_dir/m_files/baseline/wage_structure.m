function f = wage_structure(vParams,mC,mCD,merrC,do_higher_moments,type_wmatrix)
%{
    This function generates the moment conditions for the estimation of 
    the second and higher moments of the wage process.

    Alexandros Theloudis

    -----------------------------------------------------------------------
%}

%   Initial statements:
global T ;


%%  1.  INITIALIZE OBJECTS
%   Initialize parameters and vectors to hold moments
%   -----------------------------------------------------------------------

%   Vectors of second moments of shocks:
vH  = vParams(1:5)   ;   % variance:    permanent shock HD
uH  = vParams(6:11)  ;   % variance:    transitory shock HD
vW  = vParams(12:16) ;   % variance:    permanent shock WF
uW  = vParams(17:22) ;   % variance:    transitory shock WF
vHW = vParams(23:27) ;   % covariance:  permanent shocks
uHW = vParams(28:33) ;   % covariance:  transitory shocks

%   Vectors of third moments of shocks:
if do_higher_moments >= 1
gvH   = vParams(45:49) ; % skewness:    permanent shock HD
guH   = vParams(50:55) ; % skewness:    transitory shock HD
gvW   = vParams(56:60) ; % skewness:    permanent shock WF
guW   = vParams(61:66) ; % skewness:    transitory shock WF
gvH2W = vParams(67:71) ; % third cross moment: E[vH^2 vW]
guH2W = vParams(72:77) ; % third cross moment: E[uH^2 uW]
gvHW2 = vParams(78:82) ; % third cross moment: E[vH vW^2]
guHW2 = vParams(83:88) ; % third cross moment: E[uH uW^2]
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

%   Variances 2001-2009:
j = 2 ;
while j <= T-1  
    mom_wHwH(j) = ((mC(j,:).*mC(j,:)) - merrC(j,1) - merrC(j-1,1) ...
        - vH(j-1) - uH(j) - uH(j-1)) * mCD(j,:)' ;
    mom_wHwH(j) = mom_wHwH(j) / (mCD(j,:)*mCD(j,:)') ;
    j = j + 1 ;
end 
    
%   Intertemporal covariances 1999-2009:
j = 2 ;
while j <= T
    mom_wHwH_a(j) = ((mC(j,:).*mC(j-1,:)) + merrC(j-1,1) ...
        + uH(j-1)) * (mCD(j,:).*mCD(j-1,:))' ;
    mom_wHwH_a(j) = mom_wHwH_a(j) / (mCD(j,:)*mCD(j-1,:)') ;
    j = j + 1 ;
end

%   Matrix 13: E[DwH DwW]   
%   -----------------------------------------------------------------------

%   Auto-covariances 2001-2009:
j = 2 ;
while j <= T-1
	mom_wHwW(j) = ((mC(j,:).*mC(2*T+j,:)) ...
        - vHW(j-1) - uHW(j) - uHW(j-1)) * (mCD(j,:).*mCD(2*T+j,:))' ;
    mom_wHwW(j) = mom_wHwW(j) / (mCD(j,:)*mCD(2*T+j,:)') ;
	j = j + 1 ;
end
    
%   Intertemporal covariances 1999-2009:
j = 2 ;
while j <= T 
    mom_wHwW_a(j) = ((mC(j-1,:).*mC(2*T+j,:)) + uHW(j-1)) * (mCD(j-1,:).*mCD(2*T+j,:))' ;
    mom_wHwW_a(j) = mom_wHwW_a(j) / (mCD(j-1,:)*mCD(2*T+j,:)') ;
	j = j + 1 ;
end

j = 2 ;
while j <= T 
	mom_wHwW_b(j) = ((mC(j,:).*mC(2*T+j-1,:)) + uHW(j-1)) * (mCD(j,:).*mCD(2*T+j-1,:))' ; 
    mom_wHwW_b(j) = mom_wHwW_b(j) / (mCD(j,:)*mCD(2*T+j-1,:)') ;
	j = j + 1 ;
end

%   Matrix 33: E[DwW DwW]   
%   -----------------------------------------------------------------------

%   Variances 2001-2009:
j = 2 ;
while j <= T-1
    mom_wWwW(j) = ((mC(2*T+j,:).*mC(2*T+j,:)) - merrC(j,2) - merrC(j-1,2) ...
        - vW(j-1) - uW(j) - uW(j-1)) * mCD(2*T+j,:)' ;
    mom_wWwW(j) = mom_wWwW(j) / (mCD(2*T+j,:)*mCD(2*T+j,:)') ;
    j = j + 1 ;
end 
    
%   Intertemporal covariances 1999-2009:
j = 2 ;
while j <= T
    mom_wWwW_a(j) = ((mC(2*T+j,:).*mC(2*T+j-1,:)) + merrC(j-1,2) ...
        + uW(j-1)) * (mCD(2*T+j,:).*mCD(2*T+j-1,:))' ;
    mom_wWwW_a(j) = mom_wWwW_a(j) / (mCD(2*T+j,:)*mCD(2*T+j-1,:)') ;
    j = j + 1 ;
end


%%  3.  THIRD MOMENTS OF WAGES
%   Construct vector of moments E(data_moment_i - model_moment_i) = 0
%   -----------------------------------------------------------------------

if do_higher_moments >= 1
    
%   Matrix 12: E[DwH DwH2]   
%   -----------------------------------------------------------------------

%   Variances 2001-2009:
j = 2 ;
while j <= T-1  
    mom_wHwH2(j) = ((mC(j,:).*mC(T+j,:)) ...
        - gvH(j-1) - guH(j) + guH(j-1)) * (mCD(j,:).*mCD(T+j,:))' ;
    mom_wHwH2(j) = mom_wHwH2(j) / (mCD(j,:)*mCD(T+j,:)') ;
    j = j + 1 ;
end 
    
%   Intertemporal covariances 1999-2009:
j = 2 ;
while j <= T 
    mom_wHwH2_a(j) = ((mC(j-1,:).*mC(T+j,:)) - guH(j-1)) * (mCD(j-1,:).*mCD(T+j,:))' ;
    mom_wHwH2_a(j) = mom_wHwH2_a(j) / (mCD(j-1,:)*mCD(T+j,:)') ;
	j = j + 1 ;
end

j = 2 ;
while j <= T 
	mom_wHwH2_b(j) = ((mC(j,:).*mC(T+j-1,:)) + guH(j-1)) * (mCD(j,:).*mCD(T+j-1,:))' ; 
    mom_wHwH2_b(j) = mom_wHwH2_b(j) / (mCD(j,:)*mCD(T+j-1,:)') ;
	j = j + 1 ;
end

%   Matrix 23: E[DwH2 DwW]   
%   -----------------------------------------------------------------------

%   Variances 2001-2009:
j = 2 ;
while j <= T-1  
    mom_wH2wW(j) = ((mC(T+j,:).*mC(2*T+j,:)) ...
        - gvH2W(j-1) - guH2W(j) + guH2W(j-1)) * (mCD(T+j,:).*mCD(2*T+j,:))' ;
    mom_wH2wW(j) = mom_wH2wW(j) / (mCD(T+j,:)*mCD(2*T+j,:)') ;
    j = j + 1 ;
end 
    
%   Intertemporal covariances 1999-2009:
j = 2 ;
while j <= T 
    mom_wH2wW_a(j) = ((mC(T+j-1,:).*mC(2*T+j,:)) + guH2W(j-1)) * (mCD(T+j-1,:).*mCD(2*T+j,:))' ;
    mom_wH2wW_a(j) = mom_wH2wW_a(j) / (mCD(T+j-1,:)*mCD(2*T+j,:)') ;
	j = j + 1 ;
end

j = 2 ;
while j <= T 
	mom_wH2wW_b(j) = ((mC(T+j,:).*mC(2*T+j-1,:)) - guH2W(j-1)) * (mCD(T+j,:).*mCD(2*T+j-1,:))' ; 
    mom_wH2wW_b(j) = mom_wH2wW_b(j) / (mCD(T+j,:)*mCD(2*T+j-1,:)') ;
	j = j + 1 ;
end

%   Matrix 14: E[DwH DwW2]   
%   -----------------------------------------------------------------------

%   Variances 2001-2009:
j = 2 ;
while j <= T-1  
    mom_wHwW2(j) = ((mC(j,:).*mC(3*T+j,:)) ...
        - gvHW2(j-1) - guHW2(j) + guHW2(j-1)) * (mCD(j,:).*mCD(3*T+j,:))' ;
    mom_wHwW2(j) = mom_wHwW2(j) / (mCD(j,:)*mCD(3*T+j,:)') ;
    j = j + 1 ;
end 

%   Intertemporal covariances 1999-2009:
j = 2 ;
while j <= T 
    mom_wHwW2_a(j) = ((mC(j-1,:).*mC(3*T+j,:)) - guHW2(j-1)) * (mCD(j-1,:).*mCD(3*T+j,:))' ;
    mom_wHwW2_a(j) = mom_wHwW2_a(j) / (mCD(j-1,:)*mCD(3*T+j,:)') ;
	j = j + 1 ;
end

j = 2 ;
while j <= T 
	mom_wHwW2_b(j) = ((mC(j,:).*mC(3*T+j-1,:)) + guHW2(j-1)) * (mCD(j,:).*mCD(3*T+j-1,:))' ; 
    mom_wHwW2_b(j) = mom_wHwW2_b(j) / (mCD(j,:)*mCD(3*T+j-1,:)') ;
	j = j + 1 ;
end

%   Matrix 34: E[DwW DwW2]
%   -----------------------------------------------------------------------

%   Variances 2001-2009:
j = 2 ;
while j <= T-1  
    mom_wWwW2(j) = ((mC(2*T+j,:).*mC(3*T+j,:)) ...
        - gvW(j-1) - guW(j) + guW(j-1)) * (mCD(2*T+j,:).*mCD(3*T+j,:))' ;
    mom_wWwW2(j) = mom_wWwW2(j) / (mCD(2*T+j,:)*mCD(3*T+j,:)') ;
    j = j + 1 ;
end 
    
%   Intertemporal covariances 1999-2009:
j = 2 ;
while j <= T 
    mom_wWwW2_a(j) = ((mC(2*T+j-1,:).*mC(3*T+j,:)) - guW(j-1)) * (mCD(2*T+j-1,:).*mCD(3*T+j,:))' ;
    mom_wWwW2_a(j) = mom_wWwW2_a(j) / (mCD(2*T+j-1,:)*mCD(3*T+j,:)') ;
	j = j + 1 ;
end

j = 2 ;
while j <= T 
	mom_wWwW2_b(j) = ((mC(2*T+j,:).*mC(3*T+j-1,:)) + guW(j-1)) * (mCD(2*T+j,:).*mCD(3*T+j-1,:))' ; 
    mom_wWwW2_b(j) = mom_wWwW2_b(j) / (mCD(2*T+j,:)*mCD(3*T+j-1,:)') ;
	j = j + 1 ;
end

%   Matrix X.31: E[DwW DwH DwH']
%   -----------------------------------------------------------------------

%   Intertemporal covariances 1999-2011:
j = 2 ;
while j <= T 
    mom_wWwHwHt(j) = ((mC(2*T+j-1,:).*mC(j-1,:).*mC(j,:)) ...
        + guH2W(j-1)) * (mCD(2*T+j-1,:).*mCD(j-1,:).*mCD(j,:))' ;
    mom_wWwHwHt(j) = mom_wWwHwHt(j) / ((mCD(2*T+j-1,:).*mCD(j-1,:))*mCD(j,:)') ;
	j = j + 1 ;
end

j = 2 ;
while j <= T 
	mom_wWwHwHt_b(j) = ((mC(2*T+j,:).*mC(j-1,:).*mC(j,:)) ...
        - guH2W(j-1)) * (mCD(2*T+j,:).*mCD(j-1,:).*mCD(j,:))' ;
    mom_wWwHwHt_b(j) = mom_wWwHwHt_b(j) / ((mCD(2*T+j,:).*mCD(j-1,:))*mCD(j,:)') ;
	j = j + 1 ;
end

%   Matrix X.13: E[DwH DwW DwW']
%   -----------------------------------------------------------------------
    
%   Intertemporal covariances 1999-2011:
j = 2 ;
while j <= T 
    mom_wHwWwWt(j) = ((mC(j-1,:).*mC(2*T+j-1,:).*mC(2*T+j,:)) ...
        + guHW2(j-1)) * (mCD(j-1,:).*mCD(2*T+j-1,:).*mCD(2*T+j,:))' ;
    mom_wHwWwWt(j) = mom_wHwWwWt(j) / ((mCD(j-1,:).*mCD(2*T+j-1,:))*mCD(2*T+j,:)') ;
	j = j + 1 ;
end

j = 2 ;
while j <= T 
	mom_wHwWwWt_b(j) = ((mC(j,:).*mC(2*T+j-1,:).*mC(2*T+j,:)) ...
        - guHW2(j-1)) * (mCD(j,:).*mCD(2*T+j-1,:).*mCD(2*T+j,:))' ;
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
    vMoms = [   mom_wHwH(2:T-1)  ; ...      
                mom_wHwH_a(2:T)  ; ...
                mom_wHwW(2:T-1)  ; ...
                mom_wHwW_a(2:T)  ; ...
                mom_wHwW_b(2:T)  ; ...
                mom_wWwW(2:T-1)  ; ...
                mom_wWwW_a(2:T)] ;
    if do_higher_moments >= 1
    v3Moms = [  mom_wHwH2(2:T-1)    ; ...    
                mom_wHwH2_a(2:T)    ; ...
                mom_wHwH2_b(2:T)    ; ...
                mom_wH2wW(2:T-1)    ; ... 
                mom_wH2wW_a(2:T)    ; ...
                mom_wH2wW_b(2:T)    ; ...
                mom_wHwW2(2:T-1)    ; ... 
                mom_wHwW2_a(2:T)    ; ...
                mom_wHwW2_b(2:T)    ; ...
                mom_wWwW2(2:T-1)    ; ...
                mom_wWwW2_a(2:T)    ; ...
                mom_wWwW2_b(2:T)    ; ...
                mom_wWwHwHt(2:T)    ; ...  
                mom_wWwHwHt_b(2:T)  ; ... 
                mom_wHwWwWt(2:T)    ; ...   
                mom_wHwWwWt_b(2:T) ];
    vMoms = [vMoms;v3Moms] ;
    end
    
    %   Declare matrix:
    wmatrix = eye(size(vMoms,1)) ;

%   B. Diagonally weighted GMM:
else
    
    %   Stack moments together:
    %   Note: the use here of the average of the moments over time does not
    %   affect the results but it facilitates the operationalization of
    %   the weighting matrix.
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