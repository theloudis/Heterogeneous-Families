
/*******************************************************************************
	
Exports conditional moments over the distribution of outcome levels.
________________________________________________________________________________

Filename: 	HF15_outcome_distribs.do
Author: 	Alexandros Theloudis (a.theloudis@gmail.com)
			LISER Luxembourg
			Tilburg University, Department of Econometrics & Operations Research
Date: 		Spring 2021

This file: 
(1)		Declares programs that export data after conditionining on
		outcomes at given standard deviation away from the outcome mean. 
(2)		Exports data conditional on outcomes.

*******************************************************************************/

*	Initial statements:
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
Declare programs.
*******************************************************************************/

*	Collapse data to pass to GMM conditioning moments/variables on specific 
*	values in the joint distribution of outcome levels. Options include: 
*	`1' name of using dataset; 
*	`2' name of exporting dataset; 
*	`3' quietly/noisily; 
*	`4' applicable lower bound of male hours measured in s.d. away from mean; 
*	`5' applicable lower bound of female hours measured in s.d. away from mean;
*	`6' applicable lower bound of consumption measured in s.d. away from mean;
*	`7' applicable upper bound of outcome distribution measured in s.d. above 
*	    the applicable lower bound.
*	`8'-`10': indexes of outcome loops
capture program drop collapse_gmm_distribution
program define collapse_gmm_distribution
`3' {
	
	*	Load dataset:
	qui cd $STATAdir
	qui use `1', clear
	qui preserve
	keep hh_id year drwH drwW dreH dreW drcons es pi hoursH hoursW r_cons L2hoursH L2hoursW L2r_cons
		
	*	Keep only survey years in (biennial) and declare panel: 
	*   1997 must be dropped before 'tsfill' further down otherwise 'tsfill' 
	*	adds obs that will not be used (eg. obs that are only observed in 1997).	
	qui keep if year > 1997
	qui sort hh_id year
	qui tsset hh_id year
	
	*	Collapse data:
	prepare_data `3' 
	
	*	Condition on given range of past outcomes:
	condition_past_distribution `3' `4' `5' `6' `7' `8' `9' `10'
	
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

*	Collapse condition variables/moments on specific range of past outcomes:
capture program drop condition_past_distribution
program define condition_past_distribution
`1' {

	*	Declare upper bound of range of conditionining variables, measured 
	*	in s.d. away from mean:
	local endhh = `2'+`5'
	local endhw = `3'+`5'
	local endcc = `4'+`5'
	
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
	
	*	Carry out linear regressions of variables on outcomes levels:
	*	-calculate the average outcome level in the specifc outcome bracket.
	*	-obtain the fitted value of the variable in the specifc outcome bracket.
	
	*	-variables conditional on O_{it-1}:
	foreach lhsvar of varlist `varlist1' {
	
		*	-regress, obtain p-values:
		qui reg `lhsvar' L2hoursH L2hoursW L2r_cons
		matrix define A = r(table)
		local pv_L2hoursH = A[4,1]
		local pv_L2hoursW = A[4,2]
		local pv_L2r_cons = A[4,3]
		
		*	-summarize conditioning outcome levels, obtain applicable lower
		*	 and upper bounds of range on which I condition:
		qui sum L2hoursH if e(sample)
		local lb_L2hoursH = r(mean)+`2'*r(sd)
		local ub_L2hoursH = r(mean)+`endhh'*r(sd)
		
		qui sum L2hoursW if e(sample)
		local lb_L2hoursW = r(mean)+`3'*r(sd)
		local ub_L2hoursW = r(mean)+`endhw'*r(sd)
		
		qui sum L2r_cons if e(sample)
		local lb_L2r_cons = r(mean)+`4'*r(sd)
		local ub_L2r_cons = r(mean)+`endcc'*r(sd)
		
		*	-obtain average conditioning outcome within applicable range:
		foreach outcomelevel of varlist L2hoursH L2hoursW L2r_cons {	
			qui sum `outcomelevel' if e(sample) & `outcomelevel'>=`lb_`outcomelevel'' & `outcomelevel'<=`ub_`outcomelevel''
			local Einrange`outcomelevel' = r(mean)
			qui sum `outcomelevel' if e(sample)
			local E`outcomelevel' = r(mean)
		}
		
		*	-construct terms for fitted moment using coefficient estimates and 
		*	 average conditioning outcomes within applicable range:
		foreach outcome of varlist L2hoursH L2hoursW L2r_cons {
				local term_`outcome' = _b[`outcome']*`Einrange`outcome''
		}
		
		*	-obtain fitted moment:
		qui replace `lhsvar' = _b[_cons] + `term_L2hoursH' + `term_L2hoursW' + `term_L2r_cons' if e(sample)
	}

	*	-variables conditional on O_{it}:
	foreach lhsvar of varlist `varlist2' {
	
		*	-regress, obtain p-values:
		qui reg `lhsvar' hoursH hoursW r_cons
		matrix define A = r(table)
		local pv_hoursH = A[4,1]
		local pv_hoursW = A[4,2]
		local pv_r_cons = A[4,3]
		
		*	-summarize conditioning outcome levels, obtain applicable lower
		*	 and upper bounds of range on which I condition:
		qui sum hoursH if e(sample)
		local lb_hoursH = r(mean)+`2'*r(sd)
		local ub_hoursH = r(mean)+`endhh'*r(sd)
		
		qui sum hoursW if e(sample)
		local lb_hoursW = r(mean)+`3'*r(sd)
		local ub_hoursW = r(mean)+`endhw'*r(sd)
		
		qui sum r_cons if e(sample)
		local lb_r_cons = r(mean)+`4'*r(sd)
		local ub_r_cons = r(mean)+`endcc'*r(sd)
		
		*	-obtain average conditioning outcome within applicable range:
		foreach outcomelevel of varlist hoursH hoursW r_cons {	
			qui sum `outcomelevel' if e(sample) & `outcomelevel'>=`lb_`outcomelevel'' & `outcomelevel'<=`ub_`outcomelevel''
			local Einrange`outcomelevel' = r(mean)
			qui sum `outcomelevel' if e(sample)
			local E`outcomelevel' = r(mean)
		}
		
		*	-construct terms for fitted moment using coefficient estimates and 
		*	 average conditioning outcomes within applicable range:
		foreach outcome of varlist hoursH hoursW r_cons {
				local term_`outcome' = _b[`outcome']*`Einrange`outcome''
		}
		
		*	-obtain fitted moment:
		qui replace `lhsvar' = _b[_cons] + `term_hoursH' + `term_hoursW' + `term_r_cons' if e(sample)
	}
	
	*	-variables conditional on O_{it-1} and O_{it}:
	*	Note: Given that hours and consumption are highly persistent, I condition
	*	past and current levels on the same range measured by same s.d. distance 
	*	away from each variable's mean.
	
	foreach lhsvar of varlist `varlist3' {
	
		*	-regress, obtain p-values:
		qui reg `lhsvar' hoursH hoursW r_cons L2hoursH L2hoursW L2r_cons
		matrix define A = r(table)
		local pv_hoursH = A[4,1]
		local pv_hoursW = A[4,2]
		local pv_r_cons = A[4,3]
		local pv_L2hoursH = A[4,4]
		local pv_L2hoursW = A[4,5]
		local pv_L2r_cons = A[4,6]
		
		*	-summarize conditioning outcome levels, obtain applicable lower
		*	 and upper bounds of range on which I condition:
		qui sum hoursH if e(sample)
		local lb_hoursH = r(mean)+`2'*r(sd)
		local ub_hoursH = r(mean)+`endhh'*r(sd)
		
		qui sum hoursW if e(sample)
		local lb_hoursW = r(mean)+`3'*r(sd)
		local ub_hoursW = r(mean)+`endhw'*r(sd)
		
		qui sum r_cons if e(sample)
		local lb_r_cons = r(mean)+`4'*r(sd)
		local ub_r_cons = r(mean)+`endcc'*r(sd)
		
		qui sum L2hoursH if e(sample)
		local lb_L2hoursH = r(mean)+`2'*r(sd)
		local ub_L2hoursH = r(mean)+`endhh'*r(sd)
		
		qui sum L2hoursW if e(sample)
		local lb_L2hoursW = r(mean)+`3'*r(sd)
		local ub_L2hoursW = r(mean)+`endhw'*r(sd)
		
		qui sum L2r_cons if e(sample)
		local lb_L2r_cons = r(mean)+`4'*r(sd)
		local ub_L2r_cons = r(mean)+`endcc'*r(sd)
		
		*	-obtain average conditioning outcome within applicable range:
		foreach outcomelevel of varlist hoursH hoursW r_cons L2hoursH L2hoursW L2r_cons {
			qui sum `outcomelevel' if e(sample) & `outcomelevel'>=`lb_`outcomelevel'' & `outcomelevel'<=`ub_`outcomelevel''
			local Einrange`outcomelevel' = r(mean)
			qui sum `outcomelevel' if e(sample)
			local E`outcomelevel' = r(mean)
		}
		
		*	-construct terms for fitted moment using coefficient estimates and 
		*	 average conditioning outcomes within applicable range:
		foreach outcome of varlist hoursH hoursW r_cons L2hoursH L2hoursW L2r_cons {
				local term_`outcome' = _b[`outcome']*`Einrange`outcome''
		}
		
		*	-obtain fitted moment:
		#delimit;
		qui replace `lhsvar' = _b[_cons] 
							 + `term_hoursH' 
							 + `term_hoursW' 
							 + `term_r_cons'
							 + `term_L2hoursH' 
							 + `term_L2hoursW' 
							 + `term_L2r_cons' if e(sample) ;
		#delimit cr
	}
	
	*	Place locals for range bounds and average into dataset:
	preserve
	*	-clear variables:
	clear
	qui insobs 1
	*	-male hours:
	qui gen lb_hh = `lb_L2hoursH'
	qui gen ub_hh  = `ub_L2hoursH'
	qui gen avg_hh = `EinrangeL2hoursH'
	*	-female hours:	
	qui gen lb_hw  = `lb_L2hoursW'
	qui gen ub_hw  = `ub_L2hoursW'
	qui gen avg_hw = `EinrangeL2hoursW'
	*	-consumption:		
	qui gen lb_cc  = `lb_L2r_cons'
	qui gen ub_cc  = `ub_L2r_cons'
	qui gen avg_cc = `EinrangeL2r_cons'
	*	-temporarily save the dataset:
	qui cd $MATLABdir/_Distribution
	qui save file_hh`6'hw`7'cc`8'.dta, replace
	qui cd $STATAdir
	restore
	
	*	Drop outcome levels:
	drop hoursH hoursW r_cons L2hoursH L2hoursW L2r_cons
}
end

*	Declare program that generates the moments that I match in the structural model:
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
Export moments conditional on the distribution of outcome levels.
*******************************************************************************/

*	Note: 	in exporting data by age bracket, I use measurement error estimates 
*			taken from the baseline data. The underlying assumption is that 
*			error is classical, thus independent of the regressors. This is 
*			internally consistent with the model assumptions.

*	Declare 'fineness' parameter: this determines the width of the range of
*	outcomes (namely the distance from the applicable lower bound in each case)
*	over which I condition the moments. It is measured in s.d. of each 
*	outcome's respective distribution.
local fineness_param = 0.3

*	Loop over ranges:
forvalues hh = -1.5(`fineness_param')1.201 {			/* loop over male hours 	*/
	forvalues hw = -1.5(`fineness_param')1.201 { 		/* loop over female hours 	*/
		forvalues cc = -1.5(`fineness_param')1.201 { 	/* loop over consumption 	*/
		
			*	Index for loop over male hours:
			if round(`hh',0.01)==-1.5 {
				local i = 1 
			}
			else if round(`hh',0.01)==-1.2 {
				local i = 2
			}
			else if round(`hh',0.01)==-0.9 {
				local i = 3
			}
			else if round(`hh',0.01)==-0.6 {
				local i = 4
			}
			else if round(`hh',0.01)==-0.3 {
				local i = 5
			}
			else if round(`hh',0.01)==0.0 {
				local i = 6
			}
			else if round(`hh',0.01)==0.3 {
				local i = 7
			}
			else if round(`hh',0.01)==0.6 {
				local i = 8
			}
			else if round(`hh',0.01)==0.9 {
				local i = 9
			}
			else {
				local i = 10
			}
			
			*	Index for loop over female hours:
			if round(`hw',0.01)==-1.5 {
				local j = 1 
			}
			else if round(`hw',0.01)==-1.2 {
				local j = 2
			}
			else if round(`hw',0.01)==-0.9 {
				local j = 3
			}
			else if round(`hw',0.01)==-0.6 {
				local j = 4
			}
			else if round(`hw',0.01)==-0.3 {
				local j = 5
			}
			else if round(`hw',0.01)==0.0 {
				local j = 6
			}
			else if round(`hw',0.01)==0.3 {
				local j = 7
			}
			else if round(`hw',0.01)==0.6 {
				local j = 8
			}
			else if round(`hw',0.01)==0.9 {
				local j = 9
			}
			else {
				local j = 10
			}
			
			*	Index for loop over consumption:
			if round(`cc',0.01)==-1.5 {
				local k = 1 
			}
			else if round(`cc',0.01)==-1.2 {
				local k = 2
			}
			else if round(`cc',0.01)==-0.9 {
				local k = 3
			}
			else if round(`cc',0.01)==-0.6 {
				local k = 4
			}
			else if round(`cc',0.01)==-0.3 {
				local k = 5
			}
			else if round(`cc',0.01)==0.0 {
				local k = 6
			}
			else if round(`cc',0.01)==0.3 {
				local k = 7
			}
			else if round(`cc',0.01)==0.6 {
				local k = 8
			}
			else if round(`cc',0.01)==0.9 {
				local k = 9
			}
			else {
				local k = 10
			}
			
			*	Residuals conditional on outcome levels:
			qui cd $STATAdir
			collapse_gmm_distribution $outputdir/partial_insurance.dta "_Distribution/PSID_hh`i'_hw`j'_cc`k'.csv" noisily `hh' `hw' `cc' `fineness_param' `i' `j' `k'

			*	Measurement error:
			qui cd $STATAdir
			use $outputdir/partial_insurance.dta, clear
			calculate_me "_Distribution/PSID_me_hh`i'_hw`j'_cc`k'.csv" quietly
			
			* 	Display progress:
			display "SUCCESS: Done distribution sample for HH=`i', HW=`j', and CC=`k' ..."
		}
	}
}
*

/*******************************************************************************
Export table with bounds and average of outcome ranges over which 
conditioninal moments are calculated bove.
*******************************************************************************/

*	Generate variables to hold bounds and averages:
clear all
qui gen lb_hh  = .
qui gen ub_hh  = .
qui gen avg_hh = .
qui gen lb_hw  = .
qui gen ub_hw  = .
qui gen avg_hw = .
qui gen lb_cc  = .
qui gen ub_cc  = .
qui gen avg_cc = .
insobs 1

*	Declare 'fineness' parameter: this determines the width of the range of
*	outcomes (namely the distance from the applicable lower bound in each case)
*	over which I condition the moments. It is measured in s.d. of each 
*	outcome's respective distribution.
local fineness_param = 0.3

*	Loop over ranges:
forvalues hh = -1.5(`fineness_param')1.201 {			/* loop over male hours 	*/
	forvalues hw = -1.5(`fineness_param')1.201 { 		/* loop over female hours 	*/
		forvalues cc = -1.5(`fineness_param')1.201 { 	/* loop over consumption 	*/
			
			*	Index for loop over male hours:
			if round(`hh',0.01)==-1.5 {
				local i = 1 
			}
			else if round(`hh',0.01)==-1.2 {
				local i = 2
			}
			else if round(`hh',0.01)==-0.9 {
				local i = 3
			}
			else if round(`hh',0.01)==-0.6 {
				local i = 4
			}
			else if round(`hh',0.01)==-0.3 {
				local i = 5
			}
			else if round(`hh',0.01)==0.0 {
				local i = 6
			}
			else if round(`hh',0.01)==0.3 {
				local i = 7
			}
			else if round(`hh',0.01)==0.6 {
				local i = 8
			}
			else if round(`hh',0.01)==0.9 {
				local i = 9
			}
			else {
				local i = 10
			}
			
			*	Index for loop over female hours:
			if round(`hw',0.01)==-1.5 {
				local j = 1 
			}
			else if round(`hw',0.01)==-1.2 {
				local j = 2
			}
			else if round(`hw',0.01)==-0.9 {
				local j = 3
			}
			else if round(`hw',0.01)==-0.6 {
				local j = 4
			}
			else if round(`hw',0.01)==-0.3 {
				local j = 5
			}
			else if round(`hw',0.01)==0.0 {
				local j = 6
			}
			else if round(`hw',0.01)==0.3 {
				local j = 7
			}
			else if round(`hw',0.01)==0.6 {
				local j = 8
			}
			else if round(`hw',0.01)==0.9 {
				local j = 9
			}
			else {
				local j = 10
			}
			
			*	Index for loop over consumption:
			if round(`cc',0.01)==-1.5 {
				local k = 1 
			}
			else if round(`cc',0.01)==-1.2 {
				local k = 2
			}
			else if round(`cc',0.01)==-0.9 {
				local k = 3
			}
			else if round(`cc',0.01)==-0.6 {
				local k = 4
			}
			else if round(`cc',0.01)==-0.3 {
				local k = 5
			}
			else if round(`cc',0.01)==0.0 {
				local k = 6
			}
			else if round(`cc',0.01)==0.3 {
				local k = 7
			}
			else if round(`cc',0.01)==0.6 {
				local k = 8
			}
			else if round(`cc',0.01)==0.9 {
				local k = 9
			}
			else {
				local k = 10
			}
			
			*	Substitute values for bounds and averages:
			qui cd $MATLABdir/_Distribution
			append using file_hh`i'hw`j'cc`k'.dta
			qui erase file_hh`i'hw`j'cc`k'.dta
		}
	}
}
*	Export file:
qui cd $STATAdir
qui export excel using $MATLABdir/_Distribution/avg_bounds_outcomes.xls, replace

***** End of do file *****
