
/*******************************************************************************
	
Calculates measurement error in wages & earnings the PSID, this time for a
range of measurement error values.
________________________________________________________________________________

Filename: 	HF13_other_m_error.do
Author: 	Alexandros Theloudis (a.theloudis@gmail.com)
			LISER Luxembourg
			Tilburg University, Department of Econometrics & Operations Research
Date: 		Spring 2021

In the baseline, consumption measurement error is about 15% of the variance of 
consumption. In the consumption measurement error robustness exercise, I try 51
alternative values for this error, ranging from 0% to 50% of the variance of
consumption. At first I try these values without also changing the values for 
the variance of the wage or earnings errors. 

In a second robustness check, I want to also change the variance of the wage or 
earnings errors in a way that mimics the range of values for the error in 
consumption. So I generate a 51-point grid for wage, earnings, and hours errors 
such that 1) the relative proportionality of all errors in the PSID is 
maintained; 2) the 16th point on the grid corresponds to the the baseline values 
for all errors (in the baseline has consumption error at 15% of the variance of 
consumption, and this is coupled with: wage error at 13% of the variance of 
wages, earnings error at 4% of the variance of earnings, and hours error at 
23% of the variance of hours).

To maintain relative proportionality, though arguably in an ad hoc way, 
the range for the variance of: 
	- wage error is between [0.05 and 0.2] 
	 (the 27th element on a 51-point grid is then equal to a_wage = 0.13)
	- earnings error is between [0.02 and 0.06]
	 (the 27th element on a 51-point grid is then equal to a_earnings = 0.04)
	- hours error is between [0.1 and 0.36] 
	 (the 26th element on a 51-point grid is then equal to a_hours = 0.23)

Note that the data generated in this script are used on Matlab to assess how 
the parameter estimates change with a different amount of wage & earnings error; 
these results do not explicitly appear in the paper; only reference to them is 
in section 5.2 ('Robustness') and Appendix E ('Consumption measurement error').

This file: 
(1)		Declares program to calculate the second moments of measurement error 
		in the PSID data, given a range for the error parameters.
(2)		Calculates measurement error and exports files for each different value.

*******************************************************************************/

*	Initial statements:
clear
clear matrix
set more off
cap log close


/*******************************************************************************
Declare program that calculates second moments of measurement error. 
*******************************************************************************/

*	Declare program:
*	Options include: 
*	`1' name of exporting dataset; 
*	`2' quietly or noisily;
*	`3' % that the wage error variance is of the log wage variance;
*	`4' % that the earnings error variance is of the log earnings variance;
*	`5' % that the hours error variance is of the log hours variance.
capture program drop calculate_other_me
program define calculate_other_me
`2' {

	preserve
	
	*	Select appropriate sample and variables:
	keep if year > 1997		/* I am only using obs. for whom drwH is non missing */
	keep hh_id year lr_earnH lr_earnW lr_wageH lr_wageW l_hoursH l_hoursW drwH
	
	*	Get the variance of logX (X: earnings, wages, hours) if logX contributes
	*	to the residual first differences used in the structural estimation:
	collapse (sd) l* if drwH != ., by(year)
	foreach var of varlist l* {
		qui gen V`var' = `var'^2
	}
	drop l*

	*	Calculate error variances and covariances:
	replace Vlr_wageH = `3' * Vlr_wageH
	rename Vlr_wageH mevar_wH
	replace Vlr_wageW = `3' * Vlr_wageW
	rename Vlr_wageW mevar_wW

	replace Vlr_earnH = `4' * Vlr_earnH
	rename Vlr_earnH mevar_yH
	replace Vlr_earnW = `4' * Vlr_earnW
	rename Vlr_earnW mevar_yW

	replace Vl_hoursH = `5' * Vl_hoursH
	rename Vl_hoursH mevar_hH
	replace Vl_hoursW = `5' * Vl_hoursW
	rename Vl_hoursW mevar_hW

	gen mecov_wyH = mevar_yH - 0.5*(mevar_yH + mevar_hH - mevar_wH)
	gen mecov_wyW = mevar_yW - 0.5*(mevar_yW + mevar_hW - mevar_wW)

	drop mevar_h*
	
	order year mevar_w* mevar_y* mecov_wy*
	
	*	Export measurement error variances and restore:
	compress
	cd $MATLABdir
	export delimited using `1', replace
	
	restore
}
end


/*******************************************************************************
Calculate second moments of measurement error in original PSID dataset. 
*******************************************************************************/

*	Loop over error variance values:
forvalues i = 1/51 {
	local wer = 0.05 + (`i'-1)*(0.15/50)
	local eer = 0.02 + (`i'-1)*(0.04/50)
	local her = 0.10 + (`i'-1)*(0.26/50)
	
	*	Calculate and export measurement error:
	cd $STATAdir
	use $outputdir/partial_insurance.dta, clear 
	calculate_other_me "_Measur_error/me_c1_`i'.csv" quietly `wer' `eer' `her'

}
cd $STATAdir

***** End of do file *****
