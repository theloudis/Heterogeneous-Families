
/*******************************************************************************
	
Carries out the estimation of wealth shares 'pi' and 'es'
________________________________________________________________________________

Filename: 	HF08_pi_es.do
Author: 	Alexandros Theloudis (a.theloudis@gmail.com)
			LISER Luxembourg
			Tilburg University, Department of Econometrics & Operations Research
Date: 		Spring 2021

This file: 
(1)		Declares program for the projection of head's and wife's future
		earnings and the estimation of 'es' - the head's share of lifetime 
		earnings - and 'pi' - the assets part of total household wealth.
(2)		Estimates 'es' and 'pi' over entire sample.
(3)     Fills in 'es' and 'pi' in 'wealthy' subsamples.
(4)     Fills in 'es' and 'pi' in subsamples after trimming extreme observations.

*******************************************************************************/

*	Initial statements:
clear
set more off
cap log close

*	Set scalars:
scalar irate   = 1.02
scalar retireT = 65


/*******************************************************************************
Declare program for estimation of lifetime earnings and of `pi' and 'es'
*******************************************************************************/

capture program drop estimate_pi_es
program define estimate_pi_es
version 13
`1' {
	
	*	Generate regressors for projection of head's human wealth:
	qui capture drop _I*
	qui gen ageH2 = ageH^2
	qui gen ageH3 = ageH^3
	qui tab ybH, gen(ybHd)
	qui xi i.edH*ageH i.edH*ageH2 i.edH*ageH3 i.rcH*ageH i.rcH*ageH2 i.rcH*ageH3
	
	*	Run head's earnings regression:
	qui reg lr_earnH ageH ageH2 ageH3 ybHd* _I*
	qui drop ageH2 ageH3 _I* 
	
	*	Generate 'realageH' to hold age data for head:
	qui rename ageH realageH
	
	*	Project head's future earnings:
	forv t = 1/35 {
	
		*	Generate head's future variables (polynomial in age) and name
		*	'ageH' to 'cheat' Stata's last saved regression coeffs:
		qui gen ageH = realageH + `t' if realageH <= (retireT-`t')
		qui gen ageH2 = ageH^2
		qui gen ageH3 = ageH^3
		qui xi i.edH*ageH i.edH*ageH2 i.edH*ageH3 i.rcH*ageH i.rcH*ageH2 i.rcH*ageH3
		
		*	Predict fitted values using future variables:		
		qui predict Elr_earnH_`t' if e(sample), xb
		
		*	Remove some few extremely high (positive) values:
		qui sum Elr_earnH_`t' if Elr_earnH_`t' > 17
		if r(N) != 0 {
			qui replace Elr_earnH_`t' = . if Elr_earnH_`t' > 17 & Elr_earnH_`t' != .
		}
		*	Discount future earnings and convert to levels:
		qui gen EearnH_`t' = exp(Elr_earnH_`t' - `t'*log(irate))
		qui drop ageH* _I* Elr_earnH_`t'
	}
	*	Generate head's human wealth by summing up current and expected 
	*	discounted future earnings:
	qui gen rearnH = earnH/annual1	/* note that I use 'lr_earnH' for the projection of future earnings which is already deflated */
	qui egen hwH = rsum(rearnH EearnH_*), missing
	qui drop ybHd* rearnH EearnH_*
	qui rename realageH ageH
	
	*	Generate regressors for projection of wife's human wealth:
	qui capture drop _I*
	qui gen ageW2 = ageW^2 
	qui gen ageW3 = ageW^3 
	qui tab ybW, gen(ybWd)
	qui xi i.edW*ageW i.edW*ageW2 i.edW*ageW3 i.rcW*ageW i.rcW*ageW2 i.rcW*ageW3
	
	*	Run wife's earnings regression:
	qui reg lr_earnW ageW ageW2 ageW3 ybWd* _I*
	qui drop ageW2 ageW3 _I*
	
	*	Generate 'realageW' to hold age data for wife:
	qui rename ageW realageW
	
	*	Project wife's future earnings:
	forv t = 1/35 {

		*	Generate wife's future variables (polynomial in age) and name
		*	'ageW' to 'cheat' Stata's last saved regression coeffs:
		qui gen ageW = realageW + `t' if realageW <= (retireT-`t')
		qui gen ageW2 = ageW^2
		qui gen ageW3 = ageW^3
		qui xi i.edW*ageW i.edW*ageW2 i.edW*ageW3 i.rcW*ageW i.rcW*ageW2 i.rcW*ageW3
		
		*	Predict fitted values using future variables:		
		qui predict Elr_earnW_`t' if e(sample), xb

		*	Remove some few extremely high (positive) values:
		qui sum Elr_earnW_`t' if Elr_earnW_`t' > 17
		if r(N) != 0 {
			qui replace Elr_earnW_`t' = . if Elr_earnW_`t' > 17 & Elr_earnW_`t' != .
		}
		*	Discount future earnings and convert to levels:
		qui gen EearnW_`t' = exp(Elr_earnW_`t' - `t'*log(irate))
		qui drop ageW* _I* Elr_earnW_`t'
	}
	*	Generate wife's human wealth by summing up current and expected 
	*	discounted future earnings:
	qui gen rearnW = earnW/annual1
	qui egen hwW = rsum(rearnW EearnW_*), missing
	qui drop ybWd* rearnW EearnW_*
	rename realageW ageW
	
	*	Generate 'es' - share of head's lifetime earnings in the household:
	qui gen es = hwH / (hwH + hwW)
	qui label variable es "HD LIFETIME EARNINGS SHARE"
	
	*	Generate 'pi' - share of financial wealth in household's total wealth:
	qui gen pi = (wealth/annual1) / ((wealth/annual1) + hwH + hwW) if wealth>=0
	qui label variable pi "PARTIAL INSURANCE PARAM."
	qui drop hwH hwW
	
	*	Adjust 'pi' for if wealth is negative:
	qui replace pi = 0 if wealth < 0 & pi == .
}
end


/*******************************************************************************
Estimation of wealth shares over entire sample.
*******************************************************************************/

*	Dataset with residuals:
cd $STATAdir
use $outputdir/residuals.dta, clear
*	-estimation of 'es' and 'pi':
estimate_pi_es noisily
*	-save dataset:
sort hh_id year
compress
save $outputdir/partial_insurance.dta, replace


/*******************************************************************************
Fill in empty wealth shares for subsamples of wealthy households.
Information not used. This is done for consistency with original dataset.
*******************************************************************************/

*	Loop over subsamples of 'wealthy':
forvalues i=1/4 {

	cd $STATAdir
	use $outputdir/residuals_wr`i'.dta, clear
	
	*	Fill in empty 'es' and 'pi':
	gen es = .
	gen pi = .
	
	*	Save dataset:
	sort hh_id year
	compress
	save $outputdir/partial_insurance_wr`i'.dta, replace
}
*

/*******************************************************************************
Fill in empty wealth shares for subsamples after trimming extreme observations.
Information not used. This is done for consistency with original dataset.
*******************************************************************************/

*	Loop over subsamples without extreme observations:
forvalues i=1/3 {

	cd $STATAdir
	use $outputdir/residuals_rr`i'.dta, clear
	
	*	Fill in empty 'es' and 'pi':
	gen es = .
	gen pi = .
	
	*	Save dataset:
	sort hh_id year
	compress
	save $outputdir/partial_insurance_rr`i'.dta, replace
}
*
***** End of do file *****
