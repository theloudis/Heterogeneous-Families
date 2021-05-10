
/*******************************************************************************
	
Calculates ratios of outcomes in the PSID.
________________________________________________________________________________

Filename: 	HF11_ratios.do
Author: 	Alexandros Theloudis (a.theloudis@gmail.com)
			LISER Luxembourg
			Tilburg University, Department of Econometrics & Operations Research
Date: 		Spring 2021

This file: 
(1)		Declares program that calculates ratios of outcomes,
		obtains mean outcomes, and exports results.
(2)		Implements the ratio calculation over entire subsample:
			-for residuals from 1st stage regressions, 
			 after conditioning variables on average outcome levels.
			-for residuals from 1st stage regressions net of age of youngest
			 child, after conditioning variables on average outcome levels.
(3)		Implements the ratio calculation on subsamples of wealthy.
(4)		Implements the ratio calculation on subsamples without extreme observations.

*******************************************************************************/

*	Initial statements:
clear
clear matrix
set more off
cap log close


/*******************************************************************************
Declare program that calculates ratios of outcomes. 
*******************************************************************************/

*	Declare program:
*	Options include: 	`1' name of exporting dataset; 
*						`2' quietly or noisily; 
*					 	`3' target location of exporting dataset
capture program drop gen_ratios
program define gen_ratios
`2' {

	*	Generate ratios of endogenous outcomes:
	gen ratio_yH_yW   = earnH / earnW
	gen ratio_yW_yH   = earnW / earnH
	gen ratio_c_yH 	  = consumption / earnH
	gen ratio_c_yW 	  = consumption / earnW
	gen sqratio_yH_yW = ratio_yH_yW^2

	*	Discard observations for which dreH is missing:
	*	Note: I use non-missing dreH instead of drwH because the former accounts
	* 	for the missing residuals conditional on past levels in year 1999. 
	drop if dreH == .
	
	*	Generate 10th and 90th percentiles of ratios:
	foreach var of varlist ratio_* sqratio_* {
		egen pc10_`var' = pctile(`var'), p(10)
		egen pc90_`var' = pctile(`var'), p(90)
	}
	*	Summarize ratios:
	foreach var of varlist ratio_* sqratio_* {
		egen avg_`var' = mean(`var') if `var' > pc10_`var' & `var' < pc90_`var'
	}

	*	Export means couples:
	preserve
	collapse avg_*
	cd $MATLABdir
	export delimited using "`3'/avgrat_`1'.csv", replace
	restore
	
	*	Drop ratios:
	drop ratio_* avg_*
}
end


/*******************************************************************************
Calculate ratios over entire sample. 
*******************************************************************************/

*	Baseline:
qui cd $STATAdir
use $outputdir/partial_insurance.dta, clear
gen_ratios original_PSID_c1 noisily _Cond1
cd $STATAdir

*	Residuals net of age of youngest child:
qui cd $STATAdir
use $outputdir/partial_insurance.dta, clear
gen_ratios original_PSID_c2 noisily _Cond2
cd $STATAdir


/*******************************************************************************
Calculate ratios over subsamples of wealthy. 
*******************************************************************************/

*	Loop over subsamples of wealthy:
forvalues i=1/4 {
	qui cd $STATAdir
	use $outputdir/partial_insurance_wr`i'.dta, clear
	gen_ratios wr`i' noisily _Cond_wr`i'
	*sleep 1000
	!rename "$MATLABdir/_Cond_wr`i'/avgrat_wr`i'.csv" "$MATLABdir/_Cond_wr`i'/wr`i'_avgrat.csv"
	cd $STATAdir
}
*

/*******************************************************************************
Calculate ratios over subsamples after removing extreme observations. 
*******************************************************************************/

*	Loop over subsamples:
forvalues i=1/3 {
	qui cd $STATAdir
	use $outputdir/partial_insurance_rr`i'.dta, clear
	gen_ratios rr`i' noisily _Cond_rr`i'
	*sleep 1000
	!rename "$MATLABdir/_Cond_rr`i'/avgrat_rr`i'.csv" "$MATLABdir/_Cond_rr`i'/rr`i'_avgrat.csv"
	cd $STATAdir
}
*
***** End of do file *****
