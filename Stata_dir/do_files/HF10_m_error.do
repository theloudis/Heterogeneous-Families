
/*******************************************************************************
	
Estimates measurement error in the PSID.
________________________________________________________________________________

Filename: 	HF10_m_error.do
Author: 	Alexandros Theloudis (a.theloudis@gmail.com)
			LISER Luxembourg
			Tilburg University, Department of Econometrics & Operations Research
Date: 		Spring 2021

This file: 
(1)		Declares scalars and a program to calculate the second moments of 
		measurement error in the PSID.
(2)		Calculates measurement error over entire sample and exports it to Matlab:
			-for residuals from 1st stage regressions, 
			 after conditioning variables on average outcome levels.
			-for residuals from 1st stage regressions net of age of youngest
			 child, after conditioning variables on average outcome levels.
(3)		Calculates measurement error over subsamples of wealthty.
(4)		Calculates measurement error over subsamples without extreme observations.

*******************************************************************************/

*	Initial statements:
clear
clear matrix
set more off
cap log close


/*******************************************************************************
Declare scalars from validation studies.
*******************************************************************************/

*	I follow the validation study of Bound, Brown, Duncan, and Rodgers (1994). 
*	Variable X_tilde is the measured logarithm of head's earnings (or wages or 
*	hours). Let X be the true log variable if there was no measurement error.
*
*	X_tilde = X + error
*	and under classical measurement error:
*	Var(X_tilde) = Var(X) + Var(error)
*	
*	Bound, Brown, Duncan, and Rodgers (1994) estimate that 
*	Var(error) = alpha * Var(X_tilde), where
*
*	alpha = 0.04 for log earnings
*	alpha = 0.13 for log hourly wages (Blundell, Pistaferri, Saporta-Eksten 2012)
*	alpha = 0.23 for log annual hours (Blundell, Pistaferri, Saporta-Eksten 2012)

global a_wage 		= 0.13
global a_earnings 	= 0.04
global a_hours 		= 0.23


/*******************************************************************************
Declare program that calculates second moments of measurement error. 
*******************************************************************************/

*	Declare program:
*	Options include: `1' name of exporting dataset; `2' quietly or noisily
capture program drop calculate_me
program define calculate_me
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
	replace Vlr_wageH = $a_wage * Vlr_wageH
	rename Vlr_wageH mevar_wH
	replace Vlr_wageW = $a_wage * Vlr_wageW
	rename Vlr_wageW mevar_wW

	replace Vlr_earnH = $a_earnings * Vlr_earnH
	rename Vlr_earnH mevar_yH
	replace Vlr_earnW = $a_earnings * Vlr_earnW
	rename Vlr_earnW mevar_yW

	replace Vl_hoursH = $a_hours * Vl_hoursH
	rename Vl_hoursH mevar_hH
	replace Vl_hoursW = $a_hours * Vl_hoursW
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
Calculate second moments of measurement error over entire sample. 
*******************************************************************************/

*	Baseline:
cd $STATAdir
use $outputdir/partial_insurance.dta, clear
calculate_me "_Cond1/original_PSID_me_c1.csv" noisily
cd $STATAdir

*	Net of past levels and age of youngest child:
cd $STATAdir
use $outputdir/partial_insurance.dta, clear
calculate_me "_Cond2/original_PSID_me_c2.csv" noisily
cd $STATAdir


/*******************************************************************************
Calculate second moments of measurement error over subsamples of wealthy. 
*******************************************************************************/

*	Loop over subsamples of wealthy:
forvalues i=1/4 {
	cd $STATAdir
	use $outputdir/partial_insurance_wr`i'.dta, clear
	calculate_me "_Cond_wr`i'/wr`i'_PSID_me.csv" noisily
	cd $STATAdir
}
*

/*******************************************************************************
Calculate second moments of measurement error over subsamples 
without extreme observations.
*******************************************************************************/

*	Loop over subsamplessubsamples:
forvalues i=1/3 {
	cd $STATAdir
	use $outputdir/partial_insurance_rr`i'.dta, clear
	calculate_me "_Cond_rr`i'/rr`i'_PSID_me.csv" noisily
	cd $STATAdir
}
*

***** End of do file *****
