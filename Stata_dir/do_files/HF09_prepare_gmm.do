
/*******************************************************************************
	
Prepares the data for the GMM estimation
________________________________________________________________________________

Filename: 	HF09_prepare_gmm.do
Author: 	Alexandros Theloudis (a.theloudis@gmail.com)
			LISER Luxembourg
			Tilburg University, Department of Econometrics & Operations Research
Date: 		Spring 2021

This file: 
(1)		Places variables in variable lists for easier use in the programs. 
(2)		Declares programs that collapse the data to suitable forms for export 
		to Matlab.
(3)		Exports baseline sample to Matlab for use in the structural estimation:
			-residuals from 1st stage regressions with past levels controls, 
			 after conditioning variables on average outcome levels.
			-for residuals from 1st stage regressions net of age of youngest
			 child, after conditioning variables on average outcome levels.
(4)		Exports subsamples of 'wealthy'
(5)		Exports subsamples after trimming extreme observations.

*******************************************************************************/

*	Initial statements:
clear
clear matrix
set more off
cap log close


/*******************************************************************************
Creat variable lists.
*******************************************************************************/

*	Variables for which I generate panel indicators:
#delimit;
global genindictrs  drwH_FdreH FdrwH_dreH drwW_FdreH FdrwW_dreH drwH_FdreW 
					FdrwH_dreW drwW_FdreW FdrwW_dreW dreH_FdreH dreH_FdreW 
					FdreH_dreW dreW_FdreW drwH2_FdreH FdrwH2_dreH drwW2_FdreH 
					FdrwW2_dreH drwH2_FdreW FdrwH2_dreW drwW2_FdreW FdrwW2_dreW 
					drwH_FdreH2 FdrwH_dreH2 drwW_FdreH2 FdrwW_dreH2 drwH_FdreW2 
					FdrwH_dreW2 drwW_FdreW2 FdrwW_dreW2 drwH_FdreH_FdreW 
					FdrwH_dreH_dreW drwW_FdreH_FdreW FdrwW_dreH_dreW
					drwH_Fdrcons FdrwH_drcons drwW_Fdrcons FdrwW_drcons 
					dreH_Fdrcons FdreH_drcons dreW_Fdrcons FdreW_drcons 
					drcons_Fdrcons drwH2_Fdrcons FdrwH2_drcons drwW2_Fdrcons 
					FdrwW2_drcons drwH_Fdrcons2 FdrwH_drcons2 drwW_Fdrcons2 
					FdrwW_drcons2 drwH_FdreH_Fdrcons FdrwH_dreH_drcons 
					drwW_FdreH_Fdrcons FdrwW_dreH_drcons drwH_FdreW_Fdrcons 
					FdrwH_dreW_drcons drwW_FdreW_Fdrcons FdrwW_dreW_drcons 
					drwH_dreH drwW_dreH drwH_dreW drwW_dreW 
					drwH_drcons drwW_drcons dreH_dreH dreH_dreW dreW_dreW 
					dreH_drcons dreW_drcons drcons_drcons ;
#delimit cr

*	Variables exported to Matlab: 
#delimit;
global exportvars 	drwH i_drwH drwH2 i_drwH2 drwW i_drwW drwW2				
					i_drwW2 drcons i_drcons drwH_dreH i_drwH_dreH drwH_FdreH 			
					i_drwH_FdreH FdrwH_dreH i_FdrwH_dreH drwW_dreH i_drwW_dreH
					drwW_FdreH i_drwW_FdreH FdrwW_dreH i_FdrwW_dreH drwH_dreW    		
					i_drwH_dreW drwH_FdreW i_drwH_FdreW FdrwH_dreW i_FdrwH_dreW 
					drwW_dreW i_drwW_dreW drwW_FdreW i_drwW_FdreW FdrwW_dreW 			
					i_FdrwW_dreW dreH_dreH i_dreH_dreH dreH_FdreH i_dreH_FdreH 
					dreH_dreW i_dreH_dreW dreH_FdreW i_dreH_FdreW FdreH_dreW 			
					i_FdreH_dreW dreW_dreW i_dreW_dreW dreW_FdreW i_dreW_FdreW 		 
					drwH2_FdreH i_drwH2_FdreH FdrwH2_dreH i_FdrwH2_dreH 				
					drwW2_FdreH i_drwW2_FdreH FdrwW2_dreH i_FdrwW2_dreH 				
					drwH2_FdreW i_drwH2_FdreW FdrwH2_dreW i_FdrwH2_dreW 
					drwW2_FdreW i_drwW2_FdreW FdrwW2_dreW i_FdrwW2_dreW 		   	 	 	 			   	 	 	 	
					drwH_FdreH2 i_drwH_FdreH2 FdrwH_dreH2 i_FdrwH_dreH2 		   	 	 	 			   	 	 	 	
					drwW_FdreH2 i_drwW_FdreH2 FdrwW_dreH2 i_FdrwW_dreH2
					drwH_FdreW2 i_drwH_FdreW2 FdrwH_dreW2 i_FdrwH_dreW2
					drwW_FdreW2 i_drwW_FdreW2 FdrwW_dreW2 i_FdrwW_dreW2
					drwH_FdreH_FdreW i_drwH_FdreH_FdreW FdrwH_dreH_dreW 	
					i_FdrwH_dreH_dreW drwW_FdreH_FdreW i_drwW_FdreH_FdreW 	
					FdrwW_dreH_dreW i_FdrwW_dreH_dreW drwH_drcons i_drwH_drcons 
					drwH_Fdrcons i_drwH_Fdrcons FdrwH_drcons i_FdrwH_drcons
					drwW_drcons i_drwW_drcons drwW_Fdrcons i_drwW_Fdrcons     	    	
					FdrwW_drcons i_FdrwW_drcons dreH_drcons i_dreH_drcons
					dreH_Fdrcons i_dreH_Fdrcons FdreH_drcons i_FdreH_drcons
					dreW_drcons i_dreW_drcons dreW_Fdrcons i_dreW_Fdrcons     	   	
					FdreW_drcons i_FdreW_drcons drcons_drcons i_drcons_drcons
					drcons_Fdrcons i_drcons_Fdrcons	drwH2_Fdrcons i_drwH2_Fdrcons    	  	
					FdrwH2_drcons i_FdrwH2_drcons drwW2_Fdrcons i_drwW2_Fdrcons    	  	
					FdrwW2_drcons i_FdrwW2_drcons drwH_Fdrcons2 i_drwH_Fdrcons2    	  	
					FdrwH_drcons2 i_FdrwH_drcons2 drwW_Fdrcons2 i_drwW_Fdrcons2    	  	
					FdrwW_drcons2 i_FdrwW_drcons2 drwH_FdreH_Fdrcons i_drwH_FdreH_Fdrcons 	
					FdrwH_dreH_drcons i_FdrwH_dreH_drcons drwW_FdreH_Fdrcons 	
					i_drwW_FdreH_Fdrcons FdrwW_dreH_drcons i_FdrwW_dreH_drcons 
					drwH_FdreW_Fdrcons i_drwH_FdreW_Fdrcons FdrwH_dreW_drcons 	
					i_FdrwH_dreW_drcons drwW_FdreW_Fdrcons i_drwW_FdreW_Fdrcons
					FdrwW_dreW_drcons i_FdrwW_dreW_drcons ;
#delimit cr


/*******************************************************************************
Declare wrapper programs.
*******************************************************************************/

*	Collapse data to pass to GMM conditioning moments/variables on average past outcomes. 
*	Options include: 
*		`1' name of using dataset; 
*		`2' name of exporting dataset; 
*		`3' quietly or noisily.
capture program drop collapse_gmm_c1
program define collapse_gmm_c1
`3' {
	
	*	Load dataset:
	qui cd $STATAdir
	qui use `1', clear
	qui preserve
	keep  hh_id year drwH drwW dreH dreW drcons es pi hoursH hoursW r_cons L2hoursH L2hoursW L2r_cons
	
	*	Keep only survey years in (biennial) and declare panel: 
	*   1997 must be dropped before 'tsfill' further down otherwise 'tsfill' 
	*	adds obs that will not be used (eg. obs that are only observed in 1997).	
	qui keep if year > 1997
	qui sort hh_id year
	qui tsset hh_id year
	
	*	Collapse data:
	prepare_data `3'
	
	*	Condition on average past outcomes:
	condition_avg_past `3'
	
	*	Fill in missing gaps in time: 
	qui sort hh_id year
	qui tsset hh_id year
	tsfill, full
	qui drop if year == 2000 | year == 2002 | year == 2004 | year == 2006 | year == 2008 | year == 2010
	
	*	Create indicators i_ for the treatment of missing values from the panel:
	foreach var of varlist drwH drwW drwH2 drwW2 drcons es pi $genindictrs {
		qui gen i_`var' = `var' != .
		qui replace `var' = 0 if i_`var' == 0
	}
	drop i_es i_pi
	
	*	Order variables:
	order hh_id year es pi $exportvars
	
	*	Export couples and restore:
	qui compress
	qui cd $MATLABdir
	qui export delimited using `2', replace
	qui restore
}
end

*	Collapse data (net of past levels and age of youngest child) to pass to GMM 
*	conditioning moments/variables on average past outcomes. 
*	Options include: 
*		`1' name of using dataset; 
*		`2' name of exporting dataset; 
*		`3' quietly or noisily.
capture program drop collapse_gmm_c2
program define collapse_gmm_c2
`3' {
	
	*	Load dataset:
	qui cd $STATAdir
	qui use `1', clear
	qui preserve
	keep  hh_id year drwH drwW dreH_agek dreW_agek drcons_agek es pi hoursH hoursW r_cons L2hoursH L2hoursW L2r_cons
	
	*	Rename earnings and consumption residuals:
	qui rename dreH_agek 	dreH
	qui rename dreW_agek 	dreW
	qui rename drcons_agek 	drcons
	
	*	Keep only survey years in (biennial) and declare panel: 
	*   1997 must be dropped before 'tsfill' further down otherwise 'tsfill' 
	*	adds obs that will not be used (eg. obs that are only observed in 1997).	
	qui keep if year > 1997
	qui sort hh_id year
	qui tsset hh_id year
	
	*	Collapse data:
	prepare_data `3'
	
	*	Condition on average past outcomes:
	condition_avg_past `3'
	
	*	Fill in missing gaps in time: 
	qui sort hh_id year
	qui tsset hh_id year
	tsfill, full
	qui drop if year == 2000 | year == 2002 | year == 2004 | year == 2006 | year == 2008 | year == 2010
	
	*	Create indicators i_ for the treatment of missing values from the panel:
	foreach var of varlist drwH drwW drwH2 drwW2 drcons es pi $genindictrs {
		qui gen i_`var' = `var' != .
		qui replace `var' = 0 if i_`var' == 0
	}
	qui drop i_es i_pi
	
	*	Order variables:
	order hh_id year es pi $exportvars

	*	Export couples and restore:
	qui compress
	qui cd $MATLABdir
	qui export delimited using `2', replace
	qui restore
}
end


/*******************************************************************************
Declare program for collapsing data to GMM.
*******************************************************************************/

capture program drop prepare_data
program define prepare_data
`1' {
		
	*	Generate squared residuals:
	qui gen drwH2 		= drwH^2
	qui gen drwW2 		= drwW^2
	qui gen dreH2 		= dreH^2
	qui gen dreW2 		= dreW^2
	qui gen drcons2  	= drcons^2
		
	* 	Generate forward lead of residuals / squared residuals:
	qui gen F2drwH    = F2.drwH
	qui gen F2drwH2   = F2.drwH2
	qui gen F2drwW    = F2.drwW
	qui gen F2drwW2   = F2.drwW2
	qui gen F2dreH    = F2.dreH
	qui gen F2dreH2   = F2.dreH2
	qui gen F2dreW 	  = F2.dreW
	qui gen F2dreW2   = F2.dreW2
	qui gen F2drcons  = F2.drcons
	qui gen F2drcons2 = F2.drcons2
	
	*	Generate earnings and consumption variables whose moments are macthed in 
	*	the structural estimation.
	*	-targeted earnings moments:
	qui gen drwH_FdreH    	 	= drwH*F2dreH			/* A1	*/
	qui gen FdrwH_dreH    	 	= F2drwH*dreH			/* A2	*/
	qui gen drwW_FdreH    	 	= drwW*F2dreH			/* A3	*/
	qui gen FdrwW_dreH    	 	= F2drwW*dreH			/* A4	*/
	qui gen drwH_FdreW    	 	= drwH*F2dreW			/* A5	*/
	qui gen FdrwH_dreW    	 	= F2drwH*dreW			/* A6	*/
	qui gen drwW_FdreW    	 	= drwW*F2dreW			/* A7	*/
	qui gen FdrwW_dreW    	 	= F2drwW*dreW			/* A8	*/
	qui gen dreH_FdreH    	 	= dreH*F2dreH			/* A9	*/
	qui gen dreH_FdreW    	 	= dreH*F2dreW			/* A10	*/
	qui gen FdreH_dreW    	 	= F2dreH*dreW			/* A11	*/
	qui gen dreW_FdreW    	 	= dreW*F2dreW			/* A12	*/
	qui gen drwH2_FdreH   	 	= drwH2*F2dreH 			/* A13	*/
	qui gen FdrwH2_dreH   	 	= F2drwH2*dreH 			/* A14	*/
	qui gen drwW2_FdreH   	 	= drwW2*F2dreH 			/* A15	*/
	qui gen FdrwW2_dreH   	 	= F2drwW2*dreH 			/* A16	*/
	qui gen drwH2_FdreW   	 	= drwH2*F2dreW 			/* A17	*/
	qui gen FdrwH2_dreW   	 	= F2drwH2*dreW 			/* A18	*/
	qui gen drwW2_FdreW   	 	= drwW2*F2dreW 			/* A19	*/
	qui gen FdrwW2_dreW   	 	= F2drwW2*dreW 			/* A20	*/
	qui gen drwH_FdreH2   	 	= drwH*F2dreH2 			/* A21	*/
	qui gen FdrwH_dreH2   	 	= F2drwH*dreH2 			/* A22	*/
	qui gen drwW_FdreH2   	 	= drwW*F2dreH2 			/* A23	*/
	qui gen FdrwW_dreH2   	 	= F2drwW*dreH2 			/* A24	*/
	qui gen drwH_FdreW2   	 	= drwH*F2dreW2 			/* A25	*/
	qui gen FdrwH_dreW2   	 	= F2drwH*dreW2 			/* A26	*/
	qui gen drwW_FdreW2   	 	= drwW*F2dreW2 			/* A27	*/
	qui gen FdrwW_dreW2   	 	= F2drwW*dreW2 			/* A28	*/
	qui gen drwH_FdreH_FdreW 	= drwH*F2dreH*F2dreW   	/* A29	*/
	qui gen FdrwH_dreH_dreW  	= F2drwH*dreH*dreW 		/* A30	*/
	qui gen drwW_FdreH_FdreW 	= drwW*F2dreH*F2dreW 	/* A31	*/
	qui gen FdrwW_dreH_dreW  	= F2drwW*dreH*dreW 		/* A32	*/
	*	-targeted consumption moments:
	qui gen drwH_Fdrcons     	= drwH*F2drcons			/* B1	*/
	qui gen FdrwH_drcons     	= F2drwH*drcons			/* B2	*/ 
	qui gen drwW_Fdrcons     	= drwW*F2drcons			/* B3	*/
	qui gen FdrwW_drcons     	= F2drwW*drcons			/* B4	*/ 
	qui gen dreH_Fdrcons     	= dreH*F2drcons			/* B5	*/
	qui gen FdreH_drcons     	= F2dreH*drcons			/* B6	*/ 
	qui gen dreW_Fdrcons     	= dreW*F2drcons			/* B7	*/
	qui gen FdreW_drcons     	= F2dreW*drcons			/* B8	*/ 
	qui gen drcons_Fdrcons 	 	= drcons*F2drcons 		/* B9	*/ 
	qui gen drwH2_Fdrcons    	= drwH2*F2drcons 		/* B10	*/
	qui gen FdrwH2_drcons    	= F2drwH2*drcons 		/* B11	*/
	qui gen drwW2_Fdrcons    	= drwW2*F2drcons 		/* B12	*/
	qui gen FdrwW2_drcons    	= F2drwW2*drcons 		/* B13	*/
	qui gen drwH_Fdrcons2    	= drwH*F2drcons2 		/* B14	*/
	qui gen FdrwH_drcons2    	= F2drwH*drcons2 		/* B15	*/
	qui gen drwW_Fdrcons2    	= drwW*F2drcons2 		/* B16	*/
	qui gen FdrwW_drcons2    	= F2drwW*drcons2 		/* B17	*/
	qui gen drwH_FdreH_Fdrcons 	= drwH*F2dreH*F2drcons 	/* B18	*/
	qui gen FdrwH_dreH_drcons 	= F2drwH*dreH*drcons 	/* B19	*/
	qui gen drwW_FdreH_Fdrcons 	= drwW*F2dreH*F2drcons 	/* B20	*/
	qui gen FdrwW_dreH_drcons 	= F2drwW*dreH*drcons 	/* B21	*/
	qui gen drwH_FdreW_Fdrcons 	= drwH*F2dreW*F2drcons 	/* B22	*/
	qui gen FdrwH_dreW_drcons 	= F2drwH*dreW*drcons 	/* B23	*/
	qui gen drwW_FdreW_Fdrcons 	= drwW*F2dreW*F2drcons 	/* B24	*/
	qui gen FdrwW_dreW_drcons 	= F2drwW*dreW*drcons 	/* B25	*/
	*	-targeted BPS moments:
	qui gen drwH_dreH    	 	= drwH*dreH				/* C1	*/
	qui gen drwW_dreH    	 	= drwW*dreH				/* C2	*/
	qui gen drwH_dreW    	 	= drwH*dreW				/* C3	*/
	qui gen drwW_dreW    	 	= drwW*dreW				/* C4	*/
	qui gen drwH_drcons     	= drwH*drcons			/* C5	*/
	qui gen drwW_drcons     	= drwW*drcons			/* C6	*/
	qui gen dreH_dreH    	 	= dreH*dreH				/* C7	*/
	qui gen dreH_dreW    	 	= dreH*dreW				/* C8	*/
	qui gen dreW_dreW    	 	= dreW*dreW				/* C9	*/
	qui gen dreH_drcons     	= dreH*drcons			/* C10	*/
	qui gen dreW_drcons     	= dreW*drcons			/* C11	*/
	qui gen drcons_drcons 	 	= drcons*drcons 		/* C12	*/ 

	*	Drop unnecessary variables:
	#delimit;
	qui drop 	dreH dreW dreH2 dreW2 drcons2 F2drwH F2drwH2 
				F2drwW F2drwW2 F2dreH F2dreH2 F2dreW F2dreW2 F2drcons F2drcons2 ;
	#delimit cr
}
end


/*******************************************************************************
Declare program for conditioning variables on average past outcomes.
*******************************************************************************/

*	Collapse condition variables/moments on average past outcomes:
capture program drop condition_avg_past
program define condition_avg_past
`1' {
	
	*	Place moment variables in variable lists, separate with respect to 
	*	whether corresponding moment is conditional on:
	*	-varlist1: O_{it-1} only (36 variables),
	*	-varlist2: O_{it} only (24 variables),
	*	-varlist3: O_{it-1} and O_{it} (9 variables).
	#delimit;
	local varlist1 	FdrwH_dreH FdrwW_dreH FdrwH_dreW FdrwW_dreW  
					FdrwH2_dreH FdrwW2_dreH FdrwH2_dreW FdrwW2_dreW 
					FdrwH_dreH2 FdrwW_dreH2 FdrwH_dreW2 FdrwW_dreW2 
					FdrwH_dreH_dreW FdrwW_dreH_dreW FdrwH_drcons FdrwW_drcons  
					FdrwH2_drcons FdrwW2_drcons FdrwH_drcons2 FdrwW_drcons2 
					FdrwH_dreH_drcons FdrwW_dreH_drcons FdrwH_dreW_drcons 
					FdrwW_dreW_drcons drwH_dreH drwW_dreH drwH_dreW drwW_dreW 
					drwH_drcons drwW_drcons dreH_dreH dreH_dreW dreW_dreW 
					dreH_drcons dreW_drcons drcons_drcons ;
	local varlist2 	drwH_FdreH drwW_FdreH drwH_FdreW drwW_FdreW drwH2_FdreH 
					drwW2_FdreH drwH2_FdreW drwW2_FdreW drwH_FdreH2 drwW_FdreH2 
					drwH_FdreW2 drwW_FdreW2 drwH_FdreH_FdreW drwW_FdreH_FdreW
					drwH_Fdrcons drwW_Fdrcons drwH2_Fdrcons drwW2_Fdrcons 
					drwH_Fdrcons2 drwW_Fdrcons2 drwH_FdreH_Fdrcons 
					drwW_FdreH_Fdrcons drwH_FdreW_Fdrcons drwW_FdreW_Fdrcons ;
	local varlist3  drcons_Fdrcons dreH_FdreH dreH_FdreW FdreH_dreW dreW_FdreW 
					dreH_Fdrcons FdreH_drcons dreW_Fdrcons FdreW_drcons ;
	#delimit cr
	
	*	Declare panel:
	qui sort hh_id year
	qui tsset hh_id year
	
	*	Carry out linear regressions of variables on outcomes levels and:
	*	-calculate the average outcome level in the estimation sample.
	*	-obtain the fitted value of the variable at the outcome average.
	
	*	Note: 	the last step delivers the unconditional moment in each case
	*			because, as per the law of iterated expectations, a conditional
	*			moment evaluated at the average of the conditioning variable
	*			is equal to the unconditional moment. Therefore, the functional
	*			form for the dependence of the conditional moments on outcome
	*			levels (and in fact these very regressions) does not matter
	*			when evaluating the monents at average outcomes. Obviously
	*			the functional form does matter further away from the average.
	
	*	-variables conditional on O_{it-1}:
	foreach lhsvar of varlist `varlist1' {
		qui reg `lhsvar' L2hoursH L2hoursW L2r_cons
		foreach outcomelevel of varlist L2hoursH L2hoursW L2r_cons {
			qui sum `outcomelevel' if e(sample)
			local E`outcomelevel' = r(mean)
		}
		#delimit;
		qui replace `lhsvar' = _b[_cons] 
							 + _b[L2hoursH]*`EL2hoursH' 
							 + _b[L2hoursW]*`EL2hoursW' 
							 + _b[L2r_cons]*`EL2r_cons' if e(sample) ;
		#delimit cr
	}
	
	*	-variables conditional on O_{it}:
	foreach lhsvar of varlist `varlist2' {
		qui reg `lhsvar' hoursH hoursW r_cons
		foreach outcomelevel of varlist hoursH hoursW r_cons {
			qui sum `outcomelevel' if e(sample)
			local E`outcomelevel' = r(mean)
		}
		#delimit;
		qui replace `lhsvar' = _b[_cons] 
							 + _b[hoursH]*`EhoursH' 
							 + _b[hoursW]*`EhoursW' 
							 + _b[r_cons]*`Er_cons' if e(sample) ;
		#delimit cr
	}
	
	*	-variables conditional on O_{it-1} and O_{it}:
	foreach lhsvar of varlist `varlist3' {
		qui reg `lhsvar' hoursH hoursW r_cons L2hoursH L2hoursW L2r_cons
		foreach outcomelevel of varlist hoursH hoursW r_cons L2hoursH L2hoursW L2r_cons {
			qui sum `outcomelevel' if e(sample)
			local E`outcomelevel' = r(mean)
		}
		#delimit;
		qui replace `lhsvar' = _b[_cons] 
							 + _b[hoursH]*`EhoursH' 
							 + _b[hoursW]*`EhoursW' 
							 + _b[r_cons]*`Er_cons' 
							 + _b[L2hoursH]*`EL2hoursH' 
							 + _b[L2hoursW]*`EL2hoursW' 
							 + _b[L2r_cons]*`EL2r_cons' if e(sample) ;
		#delimit cr
	}
	
	*	Drop outcome levels:
	drop hoursH hoursW r_cons L2hoursH L2hoursW L2r_cons
}
end


/*******************************************************************************
Export datasets to GMM.
*******************************************************************************/

*	Residuals conditional on average outcome levels:
qui cd $STATAdir
collapse_gmm_c1 $outputdir/partial_insurance.dta "_Cond1/original_PSID_c1.csv" noisily

*	Residuals net of age of youngest child, conditional on average outcome levels:
qui cd $STATAdir
collapse_gmm_c2 $outputdir/partial_insurance.dta "_Cond2/original_PSID_c2.csv" noisily


/*******************************************************************************
Export subsamples of wealthy households.
*******************************************************************************/

*	Loop over subsamples of wealthy, residuals conditional on average outcome levels:
forvalues i=1/4 {
	qui cd $STATAdir
	collapse_gmm_c1 $outputdir/partial_insurance_wr`i'.dta "_Cond_wr`i'/wr`i'_PSID.csv" noisily
}
*

/*******************************************************************************
Export subsamples after trimming extreme observations.
*******************************************************************************/

*	Loop over subsamples, residuals conditional on average outcome levels:
forvalues i=1/3 {
	qui cd $STATAdir
	collapse_gmm_c1 $outputdir/partial_insurance_rr`i'.dta "_Cond_rr`i'/rr`i'_PSID.csv" noisily
}
*
***** End of do file *****
