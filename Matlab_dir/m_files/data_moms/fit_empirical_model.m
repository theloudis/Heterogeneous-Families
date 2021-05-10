function [mMATCHED,mBPS] = fit_empirical_model(mC, mCD, merrC, start_j, cme)
%{  
    This function estimates the empirical moments 
    (adjusted for measurement error) 
    used in the estimation of the various 
    specifications of the model.

    Alexandros Theloudis
    -----------------------------------------------------------------------
%}

%   Initial statements:
global T ;


%%  1.  INITIALIZE OBJECTS
%   Initialize vectors to hold empirical moments
%   -----------------------------------------------------------------------

%   Vectors to hold matched empirical moments under preferred specification:

%   Wages second moments:
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

%   Wages third moments:
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

%   Wage-earnings/consumption second moments:
%   matrix 15: E[DwH DyH]      
mom_wHyH_a = NaN(T,1) ;
mom_wHyH_b = NaN(T,1) ;
%   matrix 35: E[DwW DyH]
mom_wWyH_a = NaN(T,1) ;
mom_wWyH_b = NaN(T,1) ;
%   matrix 17: E[DwH DyW]
mom_wHyW_a = NaN(T,1) ;
mom_wHyW_b = NaN(T,1) ;
%   matrix 37: E[DwW DyW]       
mom_wWyW_a = NaN(T,1) ; 
mom_wWyW_b = NaN(T,1) ; 
%   matrix 19: E[DwH Dc]
mom_wHc_a  = NaN(T,1) ;
mom_wHc_b  = NaN(T,1) ;
%   matrix 39: E[DwW Dc] 
mom_wWc_a  = NaN(T,1) ;
mom_wWc_b  = NaN(T,1) ; 

%   Earnings & consumption second moments:
%   matrix 55: E[DyH DyH]
mom_yHyH_a  = NaN(T,1) ;
%   matrix 57: E[DyH DyW]
mom_yHyW_a  = NaN(T,1) ;
mom_yHyW_b  = NaN(T,1) ;
%   matrix 77: E[DyW DyW]  
mom_yWyW_a  = NaN(T,1) ;
%   matrix 59: E[DyH Dc] 	
mom_yHc_a  = NaN(T,1) ;
mom_yHc_b  = NaN(T,1) ;
%   matrix 79: E[DyW Dc]   
mom_yWc_a  = NaN(T,1) ;
mom_yWc_b  = NaN(T,1) ;
%   matrix 99: E[Dc Dc]	
mom_cc_a   = NaN(T,1) ;

%   Wage-earnings/consumption third moments:
%   matrix 25: E[DwH2 DyH]      
mom_wH2yH_a = NaN(T,1) ;
mom_wH2yH_b = NaN(T,1) ;
%   matrix 45: E[DwW2 DyH]
mom_wW2yH_a = NaN(T,1) ;
mom_wW2yH_b = NaN(T,1) ;
%   matrix 27: E[DwH2 DyW]
mom_wH2yW_a = NaN(T,1) ;
mom_wH2yW_b = NaN(T,1) ;
%   matrix 47: E[DwW2 DyW]       
mom_wW2yW_a = NaN(T,1) ; 
mom_wW2yW_b = NaN(T,1) ; 
%   matrix 29: E[DwH2 Dc]
mom_wH2c_a  = NaN(T,1) ;
mom_wH2c_b  = NaN(T,1) ;
%   matrix 49: E[DwW2 Dc] 
mom_wW2c_a  = NaN(T,1) ;
mom_wW2c_b  = NaN(T,1) ;
%   matrix 16: E[DwH DyH2]      
mom_wHyH2_a = NaN(T,1) ;
mom_wHyH2_b = NaN(T,1) ;
%   matrix 36: E[DwW DyH2]
mom_wWyH2_a = NaN(T,1) ;
mom_wWyH2_b = NaN(T,1) ;
%   matrix 18: E[DwH DyW2]
mom_wHyW2_a = NaN(T,1) ;
mom_wHyW2_b = NaN(T,1) ;
%   matrix 38: E[DwW DyW2]       
mom_wWyW2_a = NaN(T,1) ; 
mom_wWyW2_b = NaN(T,1) ; 
%   matrix 1.10: E[DwH Dc2]
mom_wHc2_a  = NaN(T,1) ;
mom_wHc2_b  = NaN(T,1) ;
%   matrix 3.10: E[DwW Dc2] 
mom_wWc2_a  = NaN(T,1) ;
mom_wWc2_b  = NaN(T,1) ;
%   matrix 1.11: E[DwH DyH DyW]
mom_wHyHyW_a = NaN(T,1) ;
mom_wHyHyW_b = NaN(T,1) ;
%   matrix 3.11: E[DwW DyH DyW]       
mom_wWyHyW_a = NaN(T,1) ; 
mom_wWyHyW_b = NaN(T,1) ; 
%   matrix 1.12: E[DwH DyH Dc]
mom_wHyHc_a  = NaN(T,1) ;
mom_wHyHc_b  = NaN(T,1) ;
%   matrix 3.12: E[DwW DyH Dc] 
mom_wWyHc_a  = NaN(T,1) ;
mom_wWyHc_b  = NaN(T,1) ;
%   matrix 1.13: E[DwH DyW Dc]
mom_wHyWc_a  = NaN(T,1) ;
mom_wHyWc_b  = NaN(T,1) ;
%   matrix 3.13: E[DwW DyW Dc] 
mom_wWyWc_a  = NaN(T,1) ;
mom_wWyWc_b  = NaN(T,1) ;

%   Vectors to hold BPS empirical moments (contemporaneous covariances):
mom_wHyH = NaN(T,1) ;
%   matrix 35: E[DwW DyH]
mom_wWyH = NaN(T,1) ;  
%   matrix 17: E[DwH DyW]
mom_wHyW = NaN(T,1) ;
%   matrix 37: E[DwW DyW]
mom_wWyW = NaN(T,1) ; 
%   matrix 19: E[DwH Dc]
mom_wHc  = NaN(T,1) ;
%   matrix 39: E[DwW Dc]
mom_wWc  = NaN(T,1) ;
 %   matrix 55: E[DyH DyH]
mom_yHyH = NaN(T,1) ;
%   matrix 57: E[DyH DyW]
mom_yHyW = NaN(T,1) ;
%   matrix 77: E[DyW DyW]
mom_yWyW = NaN(T,1) ;
%   matrix 59: E[DyH Dc]
mom_yHc  = NaN(T,1) ;
%   matrix 79: E[DyW Dc]
mom_yWc  = NaN(T,1) ;
%   matrix 99: E[Dc Dc]
mom_cc   = NaN(T,1) ;

%   Consumption measurement error:
vdc = zeros(T,1);
j = 2 ;
while j <= (T-1) 
    vdc(j) = (mC(4*T+j,:).*mC(4*T+j,:)) * (mCD(4*T+j,:).*mCD(4*T+j,:))' ;
    vdc(j) = vdc(j) / (mCD(4*T+j,:)*mCD(4*T+j,:)') ;
    j = j + 1 ;
end
v_err_c = (cme/2)*mean(vdc(2:T-1)) ;


%%  2.  MATCHED EMPIRICAL MOMENTS
%   Construct vector of moments E(data_moment_i)
%   -----------------------------------------------------------------------

%   Matrix 11: E[DwH DwH]   
%   -----------------------------------------------------------------------

%   Variances:
j = 2 ;
while j <= T-1  
    mom_wHwH(j) = ((mC(j,:).*mC(j,:)) - merrC(j,1) - merrC(j-1,1)) * mCD(j,:)' ;
    mom_wHwH(j) = mom_wHwH(j) / (mCD(j,:)*mCD(j,:)') ;
    j = j + 1 ;
end 

%   Intertemporal covariances :
j = 2 ;
while j <= T
    mom_wHwH_a(j) = ((mC(j,:).*mC(j-1,:)) + merrC(j-1,1)) * (mCD(j,:).*mCD(j-1,:))' ;
    mom_wHwH_a(j) = mom_wHwH_a(j) / (mCD(j,:)*mCD(j-1,:)') ;
    j = j + 1 ;
end

%   Matrix 13: E[DwH DwW]   
%   -----------------------------------------------------------------------

%   Auto-covariances:
j = 2 ;
while j <= T-1
	mom_wHwW(j) = ((mC(j,:).*mC(2*T+j,:))) * (mCD(j,:).*mCD(2*T+j,:))' ;
    mom_wHwW(j) = mom_wHwW(j) / (mCD(j,:)*mCD(2*T+j,:)') ;
	j = j + 1 ;
end
    
%   Intertemporal covariances :
j = 2 ;
while j <= T 
    mom_wHwW_a(j) = ((mC(j-1,:).*mC(2*T+j,:))) * (mCD(j-1,:).*mCD(2*T+j,:))' ;
    mom_wHwW_a(j) = mom_wHwW_a(j) / (mCD(j-1,:)*mCD(2*T+j,:)') ;
	j = j + 1 ;
end

j = 2 ;
while j <= T 
	mom_wHwW_b(j) = ((mC(j,:).*mC(2*T+j-1,:))) * (mCD(j,:).*mCD(2*T+j-1,:))' ; 
    mom_wHwW_b(j) = mom_wHwW_b(j) / (mCD(j,:)*mCD(2*T+j-1,:)') ;
	j = j + 1 ;
end

%   Matrix 33: E[DwW DwW]   
%   -----------------------------------------------------------------------

%   Variances:
j = 2 ;
while j <= T-1
    mom_wWwW(j) = ((mC(2*T+j,:).*mC(2*T+j,:)) - merrC(j,2) - merrC(j-1,2)) * mCD(2*T+j,:)' ;
    mom_wWwW(j) = mom_wWwW(j) / (mCD(2*T+j,:)*mCD(2*T+j,:)') ;
    j = j + 1 ;
end 
    
%   Intertemporal covariances :
j = 2 ;
while j <= T
    mom_wWwW_a(j) = ((mC(2*T+j,:).*mC(2*T+j-1,:)) + merrC(j-1,2)) * (mCD(2*T+j,:).*mCD(2*T+j-1,:))' ;
    mom_wWwW_a(j) = mom_wWwW_a(j) / (mCD(2*T+j,:)*mCD(2*T+j-1,:)') ;
    j = j + 1 ;
end
    
%   Matrix 12: E[DwH DwH2]   
%   -----------------------------------------------------------------------

%   Variances:
j = 2 ;
while j <= T-1  
    mom_wHwH2(j) = ((mC(j,:).*mC(T+j,:))) * (mCD(j,:).*mCD(T+j,:))' ;
    mom_wHwH2(j) = mom_wHwH2(j) / (mCD(j,:)*mCD(T+j,:)') ;
    j = j + 1 ;
end
    
%   Intertemporal covariances :
j = 2 ;
while j <= T 
    mom_wHwH2_a(j) = ((mC(j-1,:).*mC(T+j,:))) * (mCD(j-1,:).*mCD(T+j,:))' ;
    mom_wHwH2_a(j) = mom_wHwH2_a(j) / (mCD(j-1,:)*mCD(T+j,:)') ;
	j = j + 1 ;
end

j = 2 ;
while j <= T 
	mom_wHwH2_b(j) = ((mC(j,:).*mC(T+j-1,:))) * (mCD(j,:).*mCD(T+j-1,:))' ; 
    mom_wHwH2_b(j) = mom_wHwH2_b(j) / (mCD(j,:)*mCD(T+j-1,:)') ;
	j = j + 1 ;
end

%   Matrix 23: E[DwH2 DwW]   
%   -----------------------------------------------------------------------

%   Variances:
j = 2 ;
while j <= T-1  
    mom_wH2wW(j) = ((mC(T+j,:).*mC(2*T+j,:))) * (mCD(T+j,:).*mCD(2*T+j,:))' ;
    mom_wH2wW(j) = mom_wH2wW(j) / (mCD(T+j,:)*mCD(2*T+j,:)') ;
    j = j + 1 ;
end
    
%   Intertemporal covariances :
j = 2 ;
while j <= T 
    mom_wH2wW_a(j) = ((mC(T+j-1,:).*mC(2*T+j,:))) * (mCD(T+j-1,:).*mCD(2*T+j,:))' ;
    mom_wH2wW_a(j) = mom_wH2wW_a(j) / (mCD(T+j-1,:)*mCD(2*T+j,:)') ;
	j = j + 1 ;
end

j = 2 ;
while j <= T 
	mom_wH2wW_b(j) = ((mC(T+j,:).*mC(2*T+j-1,:))) * (mCD(T+j,:).*mCD(2*T+j-1,:))' ; 
    mom_wH2wW_b(j) = mom_wH2wW_b(j) / (mCD(T+j,:)*mCD(2*T+j-1,:)') ;
	j = j + 1 ;
end

%   Matrix 14: E[DwH DwW2]   
%   -----------------------------------------------------------------------

%   Variances:
j = 2 ;
while j <= T-1  
    mom_wHwW2(j) = ((mC(j,:).*mC(3*T+j,:))) * (mCD(j,:).*mCD(3*T+j,:))' ;
    mom_wHwW2(j) = mom_wHwW2(j) / (mCD(j,:)*mCD(3*T+j,:)') ;
    j = j + 1 ;
end

%   Intertemporal covariances :
j = 2 ;
while j <= T 
    mom_wHwW2_a(j) = ((mC(j-1,:).*mC(3*T+j,:))) * (mCD(j-1,:).*mCD(3*T+j,:))' ;
    mom_wHwW2_a(j) = mom_wHwW2_a(j) / (mCD(j-1,:)*mCD(3*T+j,:)') ;
	j = j + 1 ;
end

j = 2 ;
while j <= T 
	mom_wHwW2_b(j) = ((mC(j,:).*mC(3*T+j-1,:))) * (mCD(j,:).*mCD(3*T+j-1,:))' ; 
    mom_wHwW2_b(j) = mom_wHwW2_b(j) / (mCD(j,:)*mCD(3*T+j-1,:)') ;
	j = j + 1 ;
end

%   Matrix 34: E[DwW DwW2]
%   -----------------------------------------------------------------------

%   Variances:
j = 2 ;
while j <= T-1  
    mom_wWwW2(j) = ((mC(2*T+j,:).*mC(3*T+j,:))) * (mCD(2*T+j,:).*mCD(3*T+j,:))' ;
    mom_wWwW2(j) = mom_wWwW2(j) / (mCD(2*T+j,:)*mCD(3*T+j,:)') ;
    j = j + 1 ;
end
    
%   Intertemporal covariances :
j = 2 ;
while j <= T 
    mom_wWwW2_a(j) = ((mC(2*T+j-1,:).*mC(3*T+j,:))) * (mCD(2*T+j-1,:).*mCD(3*T+j,:))' ;
    mom_wWwW2_a(j) = mom_wWwW2_a(j) / (mCD(2*T+j-1,:)*mCD(3*T+j,:)') ;
	j = j + 1 ;
end

j = 2 ;
while j <= T 
	mom_wWwW2_b(j) = ((mC(2*T+j,:).*mC(3*T+j-1,:))) * (mCD(2*T+j,:).*mCD(3*T+j-1,:))' ; 
    mom_wWwW2_b(j) = mom_wWwW2_b(j) / (mCD(2*T+j,:)*mCD(3*T+j-1,:)') ;
	j = j + 1 ;
end

%   Matrix X.31: E[DwW DwH DwH']
%   -----------------------------------------------------------------------

%   Intertemporal covariances 1999-2011:
j = 2 ;
while j <= T 
    mom_wWwHwHt(j) = ((mC(2*T+j-1,:).*mC(j-1,:).*mC(j,:))) * (mCD(2*T+j-1,:).*mCD(j-1,:).*mCD(j,:))' ;
    mom_wWwHwHt(j) = mom_wWwHwHt(j) / ((mCD(2*T+j-1,:).*mCD(j-1,:))*mCD(j,:)') ;
	j = j + 1 ;
end

j = 2 ;
while j <= T 
	mom_wWwHwHt_b(j) = ((mC(2*T+j,:).*mC(j-1,:).*mC(j,:))) * (mCD(2*T+j,:).*mCD(j-1,:).*mCD(j,:))' ;
    mom_wWwHwHt_b(j) = mom_wWwHwHt_b(j) / ((mCD(2*T+j,:).*mCD(j-1,:))*mCD(j,:)') ;
	j = j + 1 ;
end

%   Matrix X.13: E[DwH DwW DwW']
%   -----------------------------------------------------------------------
    
%   Intertemporal covariances 1999-2011:
j = 2 ;
while j <= T 
    mom_wHwWwWt(j) = ((mC(j-1,:).*mC(2*T+j-1,:).*mC(2*T+j,:))) * (mCD(j-1,:).*mCD(2*T+j-1,:).*mCD(2*T+j,:))' ;
    mom_wHwWwWt(j) = mom_wHwWwWt(j) / ((mCD(j-1,:).*mCD(2*T+j-1,:))*mCD(2*T+j,:)') ;
	j = j + 1 ;
end

j = 2 ;
while j <= T 
	mom_wHwWwWt_b(j) = ((mC(j,:).*mC(2*T+j-1,:).*mC(2*T+j,:))) * (mCD(j,:).*mCD(2*T+j-1,:).*mCD(2*T+j,:))' ;
    mom_wHwWwWt_b(j) = mom_wHwWwWt_b(j) / ((mCD(j,:).*mCD(2*T+j-1,:))*mCD(2*T+j,:)') ;
	j = j + 1 ;
end

%   Matrix 15: E[DwH DyH]   
%   -----------------------------------------------------------------------

%   Contemporaneous covariance:
j = 2 ;
while j <= (T-1) 
    mom_wHyH(j) = (mC(5*T+j,:) - merrC(j,5) - merrC(j-1,5)) * mCD(5*T+j,:)' ;
    mom_wHyH(j) = mom_wHyH(j) / sum(mCD(5*T+j,:)) ;
    j = j + 1 ;
end

%   Intertemporal co-variances:
j = 2 ;
while j <= T
    mom_wHyH_a(j) = (mC(6*T+j-1,:) + merrC(j-1,5)) * mCD(6*T+j-1,:)' ;
    mom_wHyH_a(j) = mom_wHyH_a(j) / sum(mCD(6*T+j-1,:)) ;
	j = j + 1 ;
end

j = start_j ;
while j <= T 
    mom_wHyH_b(j) = (mC(7*T+j-1,:) + merrC(j-1,5)) * mCD(7*T+j-1,:)' ;
    mom_wHyH_b(j) = mom_wHyH_b(j) / sum(mCD(7*T+j-1,:)) ;
	j = j + 1 ;
end

%   Matrix 35: E[DwW DyH]   
%   -----------------------------------------------------------------------

%   Contemporaneous covariance:
j = 2 ;
while j <= (T-1) 
    mom_wWyH(j) = mC(8*T+j,:) * mCD(8*T+j,:)' ;
    mom_wWyH(j) = mom_wWyH(j) / sum(mCD(8*T+j,:)) ;
    j = j + 1 ;
end

%   Intertemporal co-variances:
j = 2 ;
while j <= T 
    mom_wWyH_a(j) = mC(9*T+j-1,:) * mCD(9*T+j-1,:)' ;
    mom_wWyH_a(j) = mom_wWyH_a(j) / sum(mCD(9*T+j-1,:)) ;
	j = j + 1 ;
end

j = start_j ;
while j <= T
    mom_wWyH_b(j) = mC(10*T+j-1,:) * mCD(10*T+j-1,:)' ;
    mom_wWyH_b(j) = mom_wWyH_b(j) / sum(mCD(10*T+j-1,:)) ;
	j = j + 1 ;
end

%   Matrix 17: E[DwH DyW]   
%   -----------------------------------------------------------------------

%   Contemporaneous covariance:
j = 2 ;
while j <= (T-1) 
    mom_wHyW(j) = mC(11*T+j,:) * mCD(11*T+j,:)' ; 
    mom_wHyW(j) = mom_wHyW(j) / sum(mCD(11*T+j,:)) ;
    j = j + 1 ;
end

%   Intertemporal co-variances:
j = 2 ;
while j <= T 
	mom_wHyW_a(j) = mC(12*T+j-1,:) * mCD(12*T+j-1,:)' ; 
    mom_wHyW_a(j) = mom_wHyW_a(j) / sum(mCD(12*T+j-1,:)) ;
	j = j + 1 ;
end

j = start_j ;
while j <= T 
    mom_wHyW_b(j) = mC(13*T+j-1,:) * mCD(13*T+j-1,:)' ;
    mom_wHyW_b(j) = mom_wHyW_b(j) / sum(mCD(13*T+j-1,:)) ;
	j = j + 1 ;
end

%   Matrix 37: E[DwW DyW]   
%   -----------------------------------------------------------------------

%   Contemporaneous covariance:
j = 2 ;
while j <= (T-1) 
    mom_wWyW(j) = (mC(14*T+j,:) - merrC(j,6) - merrC(j-1,6)) * mCD(14*T+j,:)' ;
    mom_wWyW(j) = mom_wWyW(j) / sum(mCD(14*T+j,:)) ;
    j = j + 1 ;
end

%   Intertemporal co-variances:
j = 2 ;
while j <= T 
	mom_wWyW_a(j) = (mC(15*T+j-1,:) + merrC(j-1,6)) * mCD(15*T+j-1,:)' ;
    mom_wWyW_a(j) = mom_wWyW_a(j) / sum(mCD(15*T+j-1,:)) ;
	j = j + 1 ;
end

j = start_j ;
while j <= T 
	mom_wWyW_b(j) = (mC(16*T+j-1,:) + merrC(j-1,6)) * mCD(16*T+j-1,:)' ;
    mom_wWyW_b(j) = mom_wWyW_b(j) / sum(mCD(16*T+j-1,:)) ;
	j = j + 1 ;
end

%   Matrix 19: E[DwH Dc]   
%   -----------------------------------------------------------------------

%   Contemporaneous covariance:
j = 2 ;
while j <= (T-1)
    mom_wHc(j) = mC(44*T+j,:) * mCD(44*T+j,:)' ;
    mom_wHc(j) = mom_wHc(j) / sum(mCD(44*T+j,:)) ;
    j = j + 1 ;
end

%   Intertemporal co-variances:
j = 2 ;
while j <= T 
	mom_wHc_a(j) = mC(45*T+j-1,:) * mCD(45*T+j-1,:)' ;
    mom_wHc_a(j) = mom_wHc_a(j) / sum(mCD(45*T+j-1,:)) ;
	j = j + 1 ;
end

j = 3 ;
while j <= T
	mom_wHc_b(j) = mC(46*T+j-1,:) * mCD(46*T+j-1,:)' ;
    mom_wHc_b(j) = mom_wHc_b(j) / sum(mCD(46*T+j-1,:)) ;
	j = j + 1 ;
end

%   Matrix 39: E[DwW Dc]   
%   -----------------------------------------------------------------------

%   Contemporaneous covariance:
j = 2 ;
while j <= (T-1) 
    mom_wWc(j) = mC(47*T+j,:) * mCD(47*T+j,:)' ;
    mom_wWc(j) = mom_wWc(j) / sum(mCD(47*T+j,:)) ;
    j = j + 1 ;
end

%   Intertemporal co-variances:
j = 2 ;
while j <= T 
	mom_wWc_a(j) = mC(48*T+j-1,:) * mCD(48*T+j-1,:)' ;
    mom_wWc_a(j) = mom_wWc_a(j) / sum(mCD(48*T+j-1,:)) ;
	j = j + 1 ;
end

j = 3 ;
while j <= T
	mom_wWc_b(j) = mC(49*T+j-1,:) * mCD(49*T+j-1,:)' ;
    mom_wWc_b(j) = mom_wWc_b(j) / sum(mCD(49*T+j-1,:)) ;
	j = j + 1 ;
end

%   Matrix 25: E[DwH2 DyH]
%   -----------------------------------------------------------------------

%   Intertemporal covariances :
j = 2 ;
while j <= T 
	mom_wH2yH_a(j) = mC(24*T+j-1,:) * mCD(24*T+j-1,:)' ;
    mom_wH2yH_a(j) = mom_wH2yH_a(j) / sum(mCD(24*T+j-1,:)) ;
	j = j + 1 ;
end

j = start_j ;
while j <= T 
    mom_wH2yH_b(j) = mC(25*T+j-1,:) * mCD(25*T+j-1,:)' ;
    mom_wH2yH_b(j) = mom_wH2yH_b(j) / sum(mCD(25*T+j-1,:)) ;
	j = j + 1 ;
end

%   Matrix 45: E[DwW2 DyH]
%   -----------------------------------------------------------------------

%   Intertemporal co-variances:
j = 2 ;
while j <= T 
	mom_wW2yH_a(j) = mC(26*T+j-1,:) * mCD(26*T+j-1,:)' ;
    mom_wW2yH_a(j) = mom_wW2yH_a(j) / sum(mCD(26*T+j-1,:)) ;
	j = j + 1 ;
end

j = start_j ;
while j <= T
    mom_wW2yH_b(j) = mC(27*T+j-1,:) * mCD(27*T+j-1,:)' ;
    mom_wW2yH_b(j) = mom_wW2yH_b(j) / sum(mCD(27*T+j-1,:)) ;
	j = j + 1 ;
end

%   Matrix 27: E[DwH2 DyW]
%   -----------------------------------------------------------------------

%   Intertemporal co-variances:
j = 2 ;
while j <= T 
	mom_wH2yW_a(j) = mC(28*T+j-1,:) * mCD(28*T+j-1,:)' ; 
    mom_wH2yW_a(j) = mom_wH2yW_a(j) / sum(mCD(28*T+j-1,:)) ;
	j = j + 1 ;
end

j = start_j ;
while j <= T 
	mom_wH2yW_b(j) = mC(29*T+j-1,:) * mCD(29*T+j-1,:)' ;
    mom_wH2yW_b(j) = mom_wH2yW_b(j) / sum(mCD(29*T+j-1,:)) ;
	j = j + 1 ;
end

%   Matrix 47: E[DwW2 DyW]
%   -----------------------------------------------------------------------

%   Intertemporal co-variances:
j = 2 ;
while j <= T 
	mom_wW2yW_a(j) = mC(30*T+j-1,:) * mCD(30*T+j-1,:)' ;
    mom_wW2yW_a(j) = mom_wW2yW_a(j) / sum(mCD(30*T+j-1,:)) ;
	j = j + 1 ;
end

j = start_j ;
while j <= T 
	mom_wW2yW_b(j) = mC(31*T+j-1,:) * mCD(31*T+j-1,:)' ;
    mom_wW2yW_b(j) = mom_wW2yW_b(j) / sum(mCD(31*T+j-1,:)) ;
	j = j + 1 ;
end

%   Matrix 29: E[DwH2 Dc]
%   -----------------------------------------------------------------------

%   Intertemporal co-variances:
j = 2 ;
while j <= T 
	mom_wH2c_a(j) = mC(58*T+j-1,:) * mCD(58*T+j-1,:)' ;
    mom_wH2c_a(j) = mom_wH2c_a(j) / sum(mCD(58*T+j-1,:)) ;
	j = j + 1 ;
end

j = 3 ;
while j <= T
	mom_wH2c_b(j) = mC(59*T+j-1,:) * mCD(59*T+j-1,:)' ;
    mom_wH2c_b(j) = mom_wH2c_b(j) / sum(mCD(59*T+j-1,:)) ;
	j = j + 1 ;
end

%   Matrix 49: E[DwW2 Dc] 
%   -----------------------------------------------------------------------

%   Intertemporal co-variances:
j = 2 ;
while j <= T 
	mom_wW2c_a(j) = mC(60*T+j-1,:) * mCD(60*T+j-1,:)' ;
    mom_wW2c_a(j) = mom_wW2c_a(j) / sum(mCD(60*T+j-1,:)) ;
	j = j + 1 ;
end

j = 3 ;
while j <= T
	mom_wW2c_b(j) = mC(61*T+j-1,:) * mCD(61*T+j-1,:)' ;
    mom_wW2c_b(j) = mom_wW2c_b(j) / sum(mCD(61*T+j-1,:)) ;
	j = j + 1 ;
end

%   Matrix 55: E[DyH DyH]   
%   -----------------------------------------------------------------------

%   Contemporaneous covariance:
j = 2 ;
while j <= (T-1) 
    mom_yHyH(j) = (mC(17*T+j,:) - merrC(j,3) - merrC(j-1,3)) * mCD(17*T+j,:)' ;
    mom_yHyH(j) = mom_yHyH(j) / sum(mCD(17*T+j,:)) ;
    j = j + 1 ;
end

%   Intertemporal co-variances:
j = start_j ;
while j <= T 
	mom_yHyH_a(j) = (mC(18*T+j-1,:) + merrC(j-1,3)) * mCD(18*T+j-1,:)' ;
    mom_yHyH_a(j) = mom_yHyH_a(j) / sum(mCD(18*T+j-1,:)) ;
	j = j + 1 ;
end

%   Matrix 57: E[DyH DyW]   
%   -----------------------------------------------------------------------

%   Contemporaneous covariance:
j = 2 ;
while j <= (T-1) 
    mom_yHyW(j) = mC(19*T+j,:) * mCD(19*T+j,:)' ; 
    mom_yHyW(j) = mom_yHyW(j) / sum(mCD(19*T+j,:)) ;
    j = j + 1 ;
end

%   Intertemporal co-variances:
j = start_j ;
while j <= T
	mom_yHyW_a(j) = mC(20*T+j-1,:) * mCD(20*T+j-1,:)' ; 
    mom_yHyW_a(j) = mom_yHyW_a(j) / sum(mCD(20*T+j-1,:)) ;
	j = j + 1 ;
end

j = start_j ;
while j <= T
	mom_yHyW_b(j) = mC(21*T+j-1,:) * mCD(21*T+j-1,:)' ;
    mom_yHyW_b(j) = mom_yHyW_b(j) / sum(mCD(21*T+j-1,:)) ;
	j = j + 1 ;
end


%   Matrix 77: E[DyW DyW]   
%   -----------------------------------------------------------------------

%   Contemporaneous covariance:
j = 2 ;
while j <= (T-1) 
    mom_yWyW(j) = (mC(22*T+j,:) - merrC(j,4) - merrC(j-1,4)) * mCD(22*T+j,:)' ;
    mom_yWyW(j) = mom_yWyW(j) / sum(mCD(22*T+j,:)) ;
    j = j + 1 ;
end

%   Intertemporal co-variances:
j = start_j ;
while j <= T 
	mom_yWyW_a(j) = (mC(23*T+j-1,:) + merrC(j-1,4))* mCD(23*T+j-1,:)' ;
    mom_yWyW_a(j) = mom_yWyW_a(j) / sum(mCD(23*T+j-1,:)) ;
	j = j + 1 ;
end

%   Matrix 59: E[DyH Dc]   
%   -----------------------------------------------------------------------

%   Contemporaneous covariance:
j = 2 ;
while j <= (T-1) 
    mom_yHc(j) = mC(50*T+j,:) * mCD(50*T+j,:)' ;
    mom_yHc(j) = mom_yHc(j) / sum(mCD(50*T+j,:)) ;
    j = j + 1 ;
end

%   Intertemporal co-variances:
j = start_j ;
while j <= T 
	mom_yHc_a(j) = mC(51*T+j-1,:) * mCD(51*T+j-1,:)' ;
    mom_yHc_a(j) = mom_yHc_a(j) / sum(mCD(51*T+j-1,:)) ;
	j = j + 1 ;
end

j = 3 ;
while j <= T 
	mom_yHc_b(j) = mC(52*T+j-1,:) * mCD(52*T+j-1,:)' ; 
    mom_yHc_b(j) = mom_yHc_b(j) / sum(mCD(52*T+j-1,:)) ;
	j = j + 1 ;
end

%   Matrix 79: E[DyW Dc]   
%   -----------------------------------------------------------------------

%   Contemporaneous covariance:
j = 2 ;
while j <= (T-1) 
    mom_yWc(j) = mC(53*T+j,:) * mCD(53*T+j,:)' ; 
    mom_yWc(j) = mom_yWc(j) / sum(mCD(53*T+j,:)) ;
    j = j + 1 ;
end

%   Intertemporal co-variances:
j = start_j ;
while j <= T 
	mom_yWc_a(j) = mC(54*T+j-1,:) * mCD(54*T+j-1,:)' ; 
    mom_yWc_a(j) = mom_yWc_a(j) / sum(mCD(54*T+j-1,:)) ;
	j = j + 1 ;
end

j = 3 ;
while j <= T
	mom_yWc_b(j) = mC(55*T+j-1,:) * mCD(55*T+j-1,:)' ; 
    mom_yWc_b(j) = mom_yWc_b(j) / sum(mCD(55*T+j-1,:)) ;
	j = j + 1 ;
end

%   Matrix 99: E[Dc Dc]   
%   -----------------------------------------------------------------------

%   Contemporaneous covariance:
j = 2 ;
while j <= (T-1) 
    mom_cc(j) = (mC(56*T+j,:) - 2*v_err_c) * mCD(56*T+j,:)' ;
    mom_cc(j) = mom_cc(j) / sum(mCD(56*T+j,:)) ;
    j = j + 1 ;
end

%   Intertemporal co-variances:
j = 3 ;
while j <= T
	mom_cc_a(j) = (mC(57*T+j-1,:) + v_err_c) * mCD(57*T+j-1,:)' ;
    mom_cc_a(j) = mom_cc_a(j) / sum(mCD(57*T+j-1,:)) ;
	j = j + 1 ;
end

%   Matrix 16: E[DwH DyH2]
%   -----------------------------------------------------------------------

%   Intertemporal co-variances:
j = 2 ;
while j <= T 
	mom_wHyH2_a(j) = mC(32*T+j-1,:) * mCD(32*T+j-1,:)' ;
    mom_wHyH2_a(j) = mom_wHyH2_a(j) / sum(mCD(32*T+j-1,:)) ;
	j = j + 1 ;
end

j = start_j ;
while j <= T 
	mom_wHyH2_b(j) = mC(33*T+j-1,:) * mCD(33*T+j-1,:)' ;
    mom_wHyH2_b(j) = mom_wHyH2_b(j) / sum(mCD(33*T+j-1,:)) ;
	j = j + 1 ;
end

%   Matrix 36: E[DwW DyH2]
%   -----------------------------------------------------------------------

%   Intertemporal co-variances:
j = 2 ;
while j <= T 
	mom_wWyH2_a(j) = mC(34*T+j-1,:)  * mCD(34*T+j-1,:)' ;
    mom_wWyH2_a(j) = mom_wWyH2_a(j) / sum(mCD(34*T+j-1,:)) ;
	j = j + 1 ;
end

j = start_j ;
while j <= T 
	mom_wWyH2_b(j) = mC(35*T+j-1,:) * mCD(35*T+j-1,:)' ;
    mom_wWyH2_b(j) = mom_wWyH2_b(j) / sum(mCD(35*T+j-1,:)) ;
	j = j + 1 ;
end

%   Matrix 18: E[DwH DyW2]
%   -----------------------------------------------------------------------

%   Intertemporal co-variances:
j = 2 ;
while j <= T 
	mom_wHyW2_a(j) = mC(36*T+j-1,:) * mCD(36*T+j-1,:)' ;
    mom_wHyW2_a(j) = mom_wHyW2_a(j) / sum(mCD(36*T+j-1,:)) ;
	j = j + 1 ;
end

j = start_j ;
while j <= T 
	mom_wHyW2_b(j) = mC(37*T+j-1,:) * mCD(37*T+j-1,:)' ;
    mom_wHyW2_b(j) = mom_wHyW2_b(j) / sum(mCD(37*T+j-1,:)) ;
	j = j + 1 ;
end

%   Matrix 38: E[DwW DyW2]   
%   -----------------------------------------------------------------------

%   Intertemporal co-variances:
j = 2 ;
while j <= T 
	mom_wWyW2_a(j) = mC(38*T+j-1,:) * mCD(38*T+j-1,:)' ;
    mom_wWyW2_a(j) = mom_wWyW2_a(j) / sum(mCD(38*T+j-1,:)) ;
	j = j + 1 ;
end

j = start_j ;
while j <= T 
	mom_wWyW2_b(j) = mC(39*T+j-1,:) * mCD(39*T+j-1,:)' ;
    mom_wWyW2_b(j) = mom_wWyW2_b(j) / sum(mCD(39*T+j-1,:)) ;
	j = j + 1 ;
end

%   Matrix 1.10: E[DwH Dc2]
%   -----------------------------------------------------------------------

%   Intertemporal co-variances:
j = 2 ;
while j <= T
	mom_wHc2_a(j) = mC(62*T+j-1,:) * mCD(62*T+j-1,:)' ;
    mom_wHc2_a(j) = mom_wHc2_a(j) / sum(mCD(62*T+j-1,:)) ;
	j = j + 1 ;
end

j = 3 ;
while j <= T
	mom_wHc2_b(j) = mC(63*T+j-1,:) * mCD(63*T+j-1,:)' ;
    mom_wHc2_b(j) = mom_wHc2_b(j) / sum(mCD(63*T+j-1,:)) ;
	j = j + 1 ;
end

%   Matrix 3.10: E[DwW Dc2] 
%   -----------------------------------------------------------------------

%   Intertemporal co-variances:
j = 2 ;
while j <= T
	mom_wWc2_a(j) = mC(64*T+j-1,:) * mCD(64*T+j-1,:)' ;
    mom_wWc2_a(j) = mom_wWc2_a(j) / sum(mCD(64*T+j-1,:)) ;
	j = j + 1 ;
end

j = 3 ;
while j <= T
	mom_wWc2_b(j) = mC(65*T+j-1,:) * mCD(65*T+j-1,:)' ;
    mom_wWc2_b(j) = mom_wWc2_b(j) / sum(mCD(65*T+j-1,:)) ;
	j = j + 1 ;
end

%   Matrix 1.11: E[DwH DyH DyW]
%   -----------------------------------------------------------------------

%   Intertemporal co-variances:
j = 2 ;
while j <= T
	mom_wHyHyW_a(j) = mC(40*T+j-1,:) * mCD(40*T+j-1,:)' ; 
    mom_wHyHyW_a(j) = mom_wHyHyW_a(j) / sum(mCD(40*T+j-1,:)) ;
	j = j + 1 ;
end

j = start_j ;
while j <= T
	mom_wHyHyW_b(j) = mC(41*T+j-1,:) * mCD(41*T+j-1,:)' ;
    mom_wHyHyW_b(j) = mom_wHyHyW_b(j) / sum(mCD(41*T+j-1,:)) ;
	j = j + 1 ;
end

%   Matrix 3.11: E[DwW DyH DyW]    
%   -----------------------------------------------------------------------

%   Intertemporal co-variances:
j = 2 ;
while j <= T
	mom_wWyHyW_a(j) = mC(42*T+j-1,:) * mCD(42*T+j-1,:)' ; 
    mom_wWyHyW_a(j) = mom_wWyHyW_a(j) / sum(mCD(42*T+j-1,:)) ;
	j = j + 1 ;
end

j = start_j ;
while j <= T
	mom_wWyHyW_b(j) = mC(43*T+j-1,:) * mCD(43*T+j-1,:)' ;
    mom_wWyHyW_b(j) = mom_wWyHyW_b(j) / sum(mCD(43*T+j-1,:)) ;
	j = j + 1 ;
end

%   Matrix 1.12: E[DwH DyH Dc]
%   -----------------------------------------------------------------------

%   Intertemporal co-variances:
j = 2 ;
while j <= T 
	mom_wHyHc_a(j) = mC(66*T+j-1,:) * mCD(66*T+j-1,:)' ;
    mom_wHyHc_a(j) = mom_wHyHc_a(j) / sum(mCD(66*T+j-1,:)) ;
	j = j + 1 ;
end

j = 3 ;
while j <= T 
	mom_wHyHc_b(j) = mC(67*T+j-1,:) * mCD(67*T+j-1,:)' ; 
    mom_wHyHc_b(j) = mom_wHyHc_b(j) / sum(mCD(67*T+j-1,:)) ;
	j = j + 1 ;
end

%   Matrix 3.12: E[DwW DyH Dc] 
%   -----------------------------------------------------------------------

%   Intertemporal co-variances:
j = 2 ;
while j <= T 
	mom_wWyHc_a(j) = mC(68*T+j-1,:) * mCD(68*T+j-1,:)' ;
    mom_wWyHc_a(j) = mom_wWyHc_a(j) / sum(mCD(68*T+j-1,:)) ;
	j = j + 1 ;
end

j = 3 ;
while j <= T 
	mom_wWyHc_b(j) = mC(69*T+j-1,:) * mCD(69*T+j-1,:)' ; 
    mom_wWyHc_b(j) = mom_wWyHc_b(j) / sum(mCD(69*T+j-1,:)) ;
	j = j + 1 ;
end

%   Matrix 1.13: E[DwH DyW Dc]
%   -----------------------------------------------------------------------

%   Intertemporal co-variances:
j = 2 ;
while j <= T 
	mom_wHyWc_a(j) = mC(70*T+j-1,:) * mCD(70*T+j-1,:)' ; 
    mom_wHyWc_a(j) = mom_wHyWc_a(j) / sum(mCD(70*T+j-1,:)) ;
	j = j + 1 ;
end

j = 3 ;
while j <= T
	mom_wHyWc_b(j) = mC(71*T+j-1,:) * mCD(71*T+j-1,:)' ; 
    mom_wHyWc_b(j) = mom_wHyWc_b(j) / sum(mCD(71*T+j-1,:)) ;
	j = j + 1 ;
end

%   Matrix 3.13: E[DwW DyW Dc] 
%   -----------------------------------------------------------------------

%   Intertemporal co-variances:
j = 2 ;
while j <= T 
	mom_wWyWc_a(j) = mC(72*T+j-1,:) * mCD(72*T+j-1,:)' ; 
    mom_wWyWc_a(j) = mom_wWyWc_a(j) / sum(mCD(72*T+j-1,:)) ;
	j = j + 1 ;
end

j = 3 ;
while j <= T
	mom_wWyWc_b(j) = mC(73*T+j-1,:) * mCD(73*T+j-1,:)' ; 
    mom_wWyWc_b(j) = mom_wWyWc_b(j) / sum(mCD(73*T+j-1,:)) ;
	j = j + 1 ;
end


%%  3.  DELIVER VECTORS OF EMPIRICAL MOMENTS
%   Stack and deliver vectors of moments
%   -----------------------------------------------------------------------

%   Stack moments together. I condition some consumption vectors to 3:T so 
%   as to remove NaN entries resulting from devision by 0 in years when
%   consumption is not observed in the data. I take the average over time:
mMATCHED = [mean(mom_wHwH(2:T-1))           ; ...  % 1        
            mean(mom_wHwH_a(2:T))           ; ...  % 2  
            mean(mom_wHwW(2:T-1))           ; ...  % 3    
            mean(mom_wHwW_a(2:T))           ; ...  % 4  
            mean(mom_wHwW_b(2:T))           ; ...  % 5  
            mean(mom_wWwW(2:T-1))           ; ...  % 6    
            mean(mom_wWwW_a(2:T))           ; ...  % 7  
            mean(mom_wHwH2(2:T-1))          ; ...  % 8       
            mean(mom_wHwH2_a(2:T))          ; ...  % 9 
            mean(mom_wHwH2_b(2:T))          ; ...  % 10 
            mean(mom_wH2wW(2:T-1))          ; ...  % 11       
            mean(mom_wH2wW_a(2:T))          ; ...  % 12 
            mean(mom_wH2wW_b(2:T))          ; ...  % 13 
            mean(mom_wHwW2(2:T-1))          ; ...  % 14       
            mean(mom_wHwW2_a(2:T))          ; ...  % 15
            mean(mom_wHwW2_b(2:T))          ; ...  % 16
            mean(mom_wWwW2(2:T-1))          ; ...  % 17  
            mean(mom_wWwW2_a(2:T))          ; ...  % 18 
            mean(mom_wWwW2_b(2:T))          ; ...  % 19 
            mean(mom_wWwHwHt(2:T))          ; ...  % 20  
            mean(mom_wWwHwHt_b(2:T))        ; ...  % 21 
            mean(mom_wHwWwWt(2:T))          ; ...  % 22  
            mean(mom_wHwWwWt_b(2:T))        ; ...  % 23       
            mean(mom_wHyH_a(2:T))           ; ...  % 24
            mean(mom_wHyH_b(start_j:T))     ; ...  % 25
            mean(mom_wWyH_a(2:T))           ; ...  % 26
            mean(mom_wWyH_b(start_j:T))     ; ...  % 27
            mean(mom_wHyW_a(2:T))           ; ...  % 28
            mean(mom_wHyW_b(start_j:T))     ; ...  % 29
            mean(mom_wWyW_a(2:T))           ; ...  % 30
            mean(mom_wWyW_b(start_j:T))     ; ...  % 31
            mean(mom_wHc_a(2:T))            ; ...  % 32
            mean(mom_wHc_b(3:T))            ; ...  % 33
            mean(mom_wWc_a(2:T))            ; ...  % 34
            mean(mom_wWc_b(3:T))            ; ...  % 35 
            mean(mom_yHyH_a(start_j:T))     ; ...  % 36
            mean(mom_yHyW_a(start_j:T))     ; ...  % 37
            mean(mom_yHyW_b(start_j:T))     ; ...  % 38
            mean(mom_yWyW_a(start_j:T))     ; ...  % 39
            mean(mom_yHc_a(start_j:T))      ; ...  % 40
            mean(mom_yHc_b(3:T))            ; ...  % 41
            mean(mom_yWc_a(start_j:T))      ; ...  % 42
            mean(mom_yWc_b(3:T))            ; ...  % 43
            mean(mom_cc_a(3:T))             ; ...  % 44
            mean(mom_wH2yH_a(2:T))          ; ...  % 45
            mean(mom_wH2yH_b(start_j:T))    ; ...  % 46
            mean(mom_wW2yH_a(2:T))          ; ...  % 47
            mean(mom_wW2yH_b(start_j:T))    ; ...  % 48
            mean(mom_wH2yW_a(2:T))          ; ...  % 49
            mean(mom_wH2yW_b(start_j:T))    ; ...  % 50
            mean(mom_wW2yW_a(2:T))          ; ...  % 51
            mean(mom_wW2yW_b(start_j:T))    ; ...  % 52
            mean(mom_wH2c_a(2:T))           ; ...  % 53
            mean(mom_wH2c_b(3:T))           ; ...  % 54
            mean(mom_wW2c_a(2:T))           ; ...  % 55
            mean(mom_wW2c_b(3:T))           ; ...  % 56
            mean(mom_wHyH2_a(2:T))          ; ...  % 57
            mean(mom_wHyH2_b(start_j:T))    ; ...  % 58
            mean(mom_wWyH2_a(2:T))          ; ...  % 59
            mean(mom_wWyH2_b(start_j:T))    ; ...  % 60
            mean(mom_wHyW2_a(2:T))          ; ...  % 61
            mean(mom_wHyW2_b(start_j:T))    ; ...  % 62
            mean(mom_wWyW2_a(2:T))          ; ...  % 63
            mean(mom_wWyW2_b(start_j:T))    ; ...  % 64
            mean(mom_wHc2_a(2:T))           ; ...  % 65
            mean(mom_wHc2_b(3:T))           ; ...  % 66
            mean(mom_wWc2_a(2:T))           ; ...  % 67
            mean(mom_wWc2_b(3:T))           ; ...  % 68
            mean(mom_wHyHyW_a(2:T))         ; ...  % 69
            mean(mom_wHyHyW_b(start_j:T))   ; ...  % 70
            mean(mom_wWyHyW_a(2:T))         ; ...  % 71
            mean(mom_wWyHyW_b(start_j:T))   ; ...  % 72
            mean(mom_wHyHc_a(2:T))          ; ...  % 73
            mean(mom_wHyHc_b(3:T))          ; ...  % 74
            mean(mom_wWyHc_a(2:T))          ; ...  % 75
            mean(mom_wWyHc_b(3:T))          ; ...  % 76
            mean(mom_wHyWc_a(2:T))          ; ...  % 77
            mean(mom_wHyWc_b(3:T))          ; ...  % 78
            mean(mom_wWyWc_a(2:T))          ; ...  % 79
            mean(mom_wWyWc_b(3:T))]         ;      % 80
mBPS =  [   mean(mom_wHyH(2:T-1))           ; ...  % 1
            mean(mom_wWyH(2:T-1))           ; ...  % 2
            mean(mom_wHyW(2:T-1))           ; ...  % 3
            mean(mom_wWyW(2:T-1))           ; ...  % 4
            mean(mom_wHc(2:T-1))            ; ...  % 5
            mean(mom_wWc(2:T-1))            ; ...  % 6
            mean(mom_yHyH(2:T-1))           ; ...  % 7
            mean(mom_yHyW(2:T-1))           ; ...  % 8
            mean(mom_yWyW(2:T-1))           ; ...  % 9
            mean(mom_yHc(2:T-1))            ; ...  % 10
            mean(mom_yWc(2:T-1))            ; ...  % 11
            mean(mom_cc(2:T-1))]            ;      % 12
end