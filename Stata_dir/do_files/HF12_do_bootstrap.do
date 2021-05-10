
/*******************************************************************************
	
Implements bootstrap resampling and all stages of the estimation on the resamples
________________________________________________________________________________

Filename: 	HF12_do_bootstrap.do
Author: 	Alexandros Theloudis (a.theloudis@gmail.com)
			LISER Luxembourg
			Tilburg University, Department of Econometrics & Operations Research
Date: 		Spring 2021

This file: 
(1)		Implements block bootstrap resampling on final PSID sample.
(2)		Runs the first stage regressions, measurement error calculation, and 
		endogenous outcomes ratio calculation on each bootstrap resample. 
		Exports bootstrap datasets:
			-for residuals from 1st stage regressions with past levels controls, 
			 after conditioning variables on average outcome levels.
			-for residuals from 1st stage regressions net of age of youngest
			 child, after conditioning variables on average outcome levels.
(3)     Repeats for subsamples of wealthy and those without extreme observations.

*******************************************************************************/

*	Initial statements:
clear
clear matrix
set more off
cap log close
local numboots = 1000


/*******************************************************************************
Implement block bootstrap resampling on 'final_sample.dta'
*******************************************************************************/

cd $STATAdir
use $outputdir/final_sample.dta, clear

*	Block bootstrap (Horowitz (2001) Section 4.1): 
*	Resampling is over block household (i). If a given household is chosen in 
*	the resampling process, then this household appears as a block in the new 
*	sample, i.e. for all periods that is originally obsered.	
set seed 19121949
capture : mkdir "$outputdir/boots_samples"
forv k = 1/`numboots' {
	qui preserve
	
	qui drop wealth_r* robust_r*
	
	bsample, cluster(hh_id) idcluster(hh_id_bs)
	qui drop hh_id
	qui rename hh_id_bs hh_id
	qui order hh_id year
	qui sort hh_id year
	
	* 	Temporarily save bootstrap resample:
	qui save "$outputdir/boots_samples/bs_`k'.dta", replace
	qui restore
}


/*******************************************************************************
Implement all stages of estimation and export:
	- baseline;
	- net of age of youngest child.
*******************************************************************************/

forv k = 1/`numboots' {
	
	*	Use bootstrap resample:
	qui cd $STATAdir
	qui use "$outputdir/boots_samples/bs_`k'.dta", clear
	qui sort hh_id year
	qui tsset hh_id year
	
	*	A. Wage regressions:
	qui gen drwH = .
	qui gen drwW = .
	wagerH DL2_lr_wageH drwH quietly
	wagerW DL2_lr_wageW drwW quietly
	
	*	B. Earnings & consumption regressions, net of past levels:
	qui gen dreH = .
	qui gen dreW = .
	qui gen drcons = .
	earningsr 		DL2_lr_earnH 	dreH 	quietly
	earningsr 		DL2_lr_earnW 	dreW 	quietly	
	consumptionr 	DL2_lr_cons 	drcons 	quietly
	
	*	C. Earnings & consumption regressions, net of past levels, age of child and chores:
	qui gen dreH_agek = .
	qui gen dreW_agek = .
	qui gen drcons_agek = .
	earningsr_agek 		DL2_lr_earnH dreH_agek quietly
	earningsr_agek 		DL2_lr_earnW dreW_agek quietly
	consumptionr_agek 	DL2_lr_cons drcons_agek quietly
	
	*	Label residuals:
	qui label var drwH			"Du WAGE HD"
	qui label var drwW			"Du WAGE WF"
	qui label var dreH			"Du EARNINGS HD"
	qui label var dreW			"Du EARNINGS WF"
	qui label var drcons		"Du CONS"
	qui label var dreH_agek		"Du EARNINGS HD agek"
	qui label var dreW_agek		"Du EARNINGS WF agek"
	qui label var drcons_agek	"Du CONS agek"

	*	Drop unwanted variables:
	qui drop DL2*
	qui sort hh_id year
	
	*	Estimation of partial insurance parameters:
	capture : scalar drop irate
	capture : scalar drop retireT
	qui scalar irate   = 1.02
	qui scalar retireT = 65
	estimate_pi_es 	quietly

	*	Save updated dataset:
	qui sort hh_id year
	qui compress
	qui save 	"$outputdir/boots_samples/bs_ps_`k'.dta", replace
	qui erase 	"$outputdir/boots_samples/bs_`k'.dta"
	
	*	Export bootstrap samples to GMM:
	*	-baseline, net of past levels:
	qui cd $STATAdir
	qui collapse_gmm_c1 "$outputdir/boots_samples/bs_ps_`k'.dta" "_Cond1/bs_`k'.csv" 	quietly	
	*	-net of past levels and age of youngest child:
	qui cd $STATAdir
	qui collapse_gmm_c2 "$outputdir/boots_samples/bs_ps_`k'.dta" "_Cond2/bs_`k'.csv" 	quietly	
	
	*	Calculate second moments of measurement error:
	*	-baseline, net of past levels:
	qui cd $STATAdir
	qui use "$outputdir/boots_samples/bs_ps_`k'.dta", clear
	calculate_me "_Cond1/me_c1_bs_`k'.csv" quietly
	qui cd $STATAdir
	*	-net of past levels and age of youngest child:
	qui cd $STATAdir
	qui use "$outputdir/boots_samples/bs_ps_`k'.dta", clear
	calculate_me "_Cond2/me_c2_bs_`k'.csv" quietly
	qui cd $STATAdir
	
	*	Calculate ratios of endogenous outcomes:
	*	-baseline, net of past levels:
	qui cd $STATAdir
	qui use "$outputdir/boots_samples/bs_ps_`k'.dta", clear
	gen_ratios bs_c1_`k' quietly _Cond1
	qui cd $STATAdir
	*	-net of past levels and age of youngest child:
	qui cd $STATAdir
	qui use "$outputdir/boots_samples/bs_ps_`k'.dta", clear
	gen_ratios bs_c2_`k' quietly _Cond2
	qui cd $STATAdir
	
	*	Erase dta files:
	qui erase "$outputdir/boots_samples/bs_ps_`k'.dta"
	qui clear

	* 	Display progress:
	display "SUCCESS: Passed Bootstrap Round `k' ..."
}
*
/*******************************************************************************
Implement block bootstrap resampling on 'final_sample.dta' conditional on 
each wealth subsample (1-4).
*******************************************************************************/

*	Wealth subsample 1:
cd $STATAdir
use $outputdir/final_sample.dta, clear
keep if wealth_r1 == 1 | year == 1997

*	Block bootstrap (Horowitz (2001) Section 4.1): 	
set seed 0630 
capture : mkdir "$outputdir/boots_samples/wr1"
forv k = 1/`numboots' {
	qui preserve
	
	qui drop wealth_r* robust_r* 
	
	bsample, cluster(hh_id) idcluster(hh_id_bs)
	qui drop hh_id
	qui rename hh_id_bs hh_id
	qui order hh_id year
	qui sort hh_id year
	
	* 	Temporarily save bootstrap resample:
	qui save "$outputdir/boots_samples/wr1/bs_`k'.dta", replace
	qui restore
}
*	Wealth subsample 2:
cd $STATAdir
use $outputdir/final_sample.dta, clear
keep if wealth_r2 == 1 | year == 1997

*	Block bootstrap (Horowitz (2001) Section 4.1): 	
set seed 0630 		/* keep the same seed: thus variability not due to seed */
capture : mkdir "$outputdir/boots_samples/wr2"
forv k = 1/`numboots' {
	qui preserve
	
	qui drop wealth_r* robust_r* 
	
	bsample, cluster(hh_id) idcluster(hh_id_bs)
	qui drop hh_id
	qui rename hh_id_bs hh_id
	qui order hh_id year
	qui sort hh_id year
	
	* 	Temporarily save bootstrap resample:
	qui save "$outputdir/boots_samples/wr2/bs_`k'.dta", replace
	qui restore
}
*	Wealth subsample 3:
cd $STATAdir
use $outputdir/final_sample.dta, clear
keep if wealth_r3 == 1 | year == 1997

*	Block bootstrap (Horowitz (2001) Section 4.1): 	
set seed 0630 		/* keep the same seed: thus variability not due to seed */
capture : mkdir "$outputdir/boots_samples/wr3"
forv k = 1/`numboots' {
	qui preserve
	
	qui drop wealth_r* robust_r* 
	
	bsample, cluster(hh_id) idcluster(hh_id_bs)
	qui drop hh_id
	qui rename hh_id_bs hh_id
	qui order hh_id year
	qui sort hh_id year
	
	* 	Temporarily save bootstrap resample:
	qui save "$outputdir/boots_samples/wr3/bs_`k'.dta", replace
	qui restore
}
*	Wealth subsample 4:
cd $STATAdir
use $outputdir/final_sample.dta, clear
keep if wealth_r4 == 1 | year == 1997

*	Block bootstrap (Horowitz (2001) Section 4.1): 	
set seed 0630 		/* keep the same seed: thus variability not due to seed */
capture : mkdir "$outputdir/boots_samples/wr4"
forv k = 1/`numboots' {
	qui preserve
	
	qui drop wealth_r* robust_r* 
	
	bsample, cluster(hh_id) idcluster(hh_id_bs)
	qui drop hh_id
	qui rename hh_id_bs hh_id
	qui order hh_id year
	qui sort hh_id year
	
	* 	Temporarily save bootstrap resample:
	qui save "$outputdir/boots_samples/wr4/bs_`k'.dta", replace
	qui restore
}
*

/*******************************************************************************
Implement first stage for each bootstrap resample of wealthy and export.
*******************************************************************************/

*	Loop over wealth categories and, within each category, loop over resamples:
forv g = 1/4 {
	forv k = 1/`numboots' {
		
		*	Use bootstrap resample:
		qui cd $STATAdir
		qui use "$outputdir/boots_samples/wr`g'/bs_`k'.dta", clear
		qui sort hh_id year
		qui tsset hh_id year
		
		*	A. Wage regressions:
		qui gen drwH = .
		qui gen drwW = .
		wagerH DL2_lr_wageH drwH quietly
		wagerW DL2_lr_wageW drwW quietly
		
		*	B. Earnings & consumption regressions:
		qui gen dreH = .
		qui gen dreW = .
		qui gen drcons = .
		earningsr DL2_lr_earnH dreH quietly
		earningsr DL2_lr_earnW dreW quietly		
		consumptionr DL2_lr_cons drcons quietly
		
		*	Label residuals:
		qui label var drwH		"Du WAGE HD"
		qui label var drwW		"Du WAGE WF"
		qui label var dreH		"Du EARNINGS HD"
		qui label var dreW		"Du EARNINGS WF"
		qui label var drcons	"Du CONS"
		
		*	Drop unwanted variables:
		qui drop DL2*
		qui sort hh_id year
		
		*	Fill in partial insurance parameters:
		qui gen es = .
		qui gen pi = .

		*	Save updated dataset & erase old:
		qui sort hh_id year
		qui compress
		qui save "$outputdir/boots_samples/wr`g'/bs_ps_`k'.dta", replace
		qui erase "$outputdir/boots_samples/wr`g'/bs_`k'.dta"
		
		*	Export bootstrap sample to GMM:
		qui cd $STATAdir
		qui collapse_gmm_c1 "$outputdir/boots_samples/wr`g'/bs_ps_`k'.dta" "_Cond_wr`g'/wr`g'_bs_`k'.csv" quietly
		
		*	Calculate second moments of measurement error:
		qui cd $STATAdir
		qui use "$outputdir/boots_samples/wr`g'/bs_ps_`k'.dta", clear
		calculate_me "_Cond_wr`g'/wr`g'_me_bs_`k'.csv" quietly
		qui cd $STATAdir
		
		*	Calculate ratios of endogenous outcomes:
		qui cd $STATAdir
		qui use "$outputdir/boots_samples/wr`g'/bs_ps_`k'.dta", clear
		gen_ratios wr`g'_bs_`k' quietly _Cond_wr`g'
		qui cd $STATAdir
		
		*	Erase dta files:
		qui erase "$outputdir/boots_samples/wr`g'/bs_ps_`k'.dta"
		qui clear

		* 	Display progress:
		display "SUCCESS: Passed Bootstrap Round `k' in wealth subsample `g' ..."
	}
}


/*******************************************************************************
Implement block bootstrap resampling on 'final_sample.dta' conditional on 
each subsample that excludes extreme observations (1-3).
*******************************************************************************/

*	Subsample 1:
cd $STATAdir
use $outputdir/final_sample.dta, clear
keep if robust_r1 == 1 | year == 1997

*	Block bootstrap (Horowitz (2001) Section 4.1): 	
set seed 19121949 		/* keep seed same as baseline; variation not due to seed */
capture : mkdir "$outputdir/boots_samples/rr1"
forv k = 1/`numboots' {
	qui preserve
	
	qui drop wealth_r* robust_r* 
	
	bsample, cluster(hh_id) idcluster(hh_id_bs)
	qui drop hh_id
	qui rename hh_id_bs hh_id
	qui order hh_id year
	qui sort hh_id year
	
	* 	Temporarily save bootstrap resample:
	qui save "$outputdir/boots_samples/rr1/bs_`k'.dta", replace
	qui restore
}

*	Subsample 2:
cd $STATAdir
use $outputdir/final_sample.dta, clear
keep if robust_r2 == 1 | year == 1997

*	Block bootstrap (Horowitz (2001) Section 4.1): 	
set seed 19121949 		/* keep seed same as baseline; variation not due to seed */
capture : mkdir "$outputdir/boots_samples/rr2"
forv k = 1/`numboots' {
	qui preserve
	
	qui drop wealth_r* robust_r* 
	
	bsample, cluster(hh_id) idcluster(hh_id_bs)
	qui drop hh_id
	qui rename hh_id_bs hh_id
	qui order hh_id year
	qui sort hh_id year
	
	* 	Temporarily save bootstrap resample:
	qui save "$outputdir/boots_samples/rr2/bs_`k'.dta", replace
	qui restore
}

*	Subsample 3:
cd $STATAdir
use $outputdir/final_sample.dta, clear
keep if robust_r3 == 1 | year == 1997

*	Block bootstrap (Horowitz (2001) Section 4.1): 	
set seed 19121949 		/* keep seed same as baseline; variation not due to seed */
capture : mkdir "$outputdir/boots_samples/rr3"
forv k = 1/`numboots' {
	qui preserve
	
	qui drop wealth_r* robust_r* 
	
	bsample, cluster(hh_id) idcluster(hh_id_bs)
	qui drop hh_id
	qui rename hh_id_bs hh_id
	qui order hh_id year
	qui sort hh_id year
	
	* 	Temporarily save bootstrap resample:
	qui save "$outputdir/boots_samples/rr3/bs_`k'.dta", replace
	qui restore
}
*

/*******************************************************************************
Implement first stage for each bootstrap resample 
that excludes extreme observations and export.
*******************************************************************************/

*	Loop over resamples and, within each category, loop over resamples:
forv g = 1/3 {
	forv k = 1/`numboots' {
		
		*	Use bootstrap resample:
		qui cd $STATAdir
		qui use "$outputdir/boots_samples/rr`g'/bs_`k'.dta", clear
		qui sort hh_id year
		qui tsset hh_id year
		
		*	A. Wage regressions:
		qui gen drwH = .
		qui gen drwW = .
		wagerH DL2_lr_wageH drwH quietly
		wagerW DL2_lr_wageW drwW quietly
		
		*	B. Earnings & consumption regressions:
		qui gen dreH = .
		qui gen dreW = .
		qui gen drcons = .
		earningsr 		DL2_lr_earnH 	dreH 	quietly
		earningsr 		DL2_lr_earnW 	dreW 	quietly
		consumptionr 	DL2_lr_cons 	drcons 	quietly
		
		*	Label first stage residuals:
		qui label var drwH		"Du WAGE HD"
		qui label var drwW		"Du WAGE WF"
		qui label var dreH		"Du EARNINGS HD"
		qui label var dreW		"Du EARNINGS WF"
		qui label var drcons	"Du CONS"
		
		*	Drop unwanted variables:
		qui drop DL2*
		qui sort hh_id year
		
		*	Fill in partial insurance parameters:
		qui gen es = .
		qui gen pi = .

		*	Save updated dataset & erase old:
		qui sort hh_id year
		qui compress
		qui save "$outputdir/boots_samples/rr`g'/bs_ps_`k'.dta", replace
		qui erase "$outputdir/boots_samples/rr`g'/bs_`k'.dta"
		
		*	Export bootstrap sample to GMM:
		qui cd $STATAdir
		qui collapse_gmm_c1 "$outputdir/boots_samples/rr`g'/bs_ps_`k'.dta" "_Cond_rr`g'/rr`g'_bs_`k'.csv" quietly
		
		*	Calculate second moments of measurement error:
		qui cd $STATAdir
		qui use "$outputdir/boots_samples/rr`g'/bs_ps_`k'.dta", clear
		calculate_me "_Cond_rr`g'/rr`g'_me_bs_`k'.csv" quietly
		qui cd $STATAdir
		
		*	Calculate ratios of endogenous outcomes:
		qui cd $STATAdir
		qui use "$outputdir/boots_samples/rr`g'/bs_ps_`k'.dta", clear
		gen_ratios rr`g'_bs_`k' quietly _Cond_rr`g'
		qui cd $STATAdir
		
		*	Erase dta files:
		qui erase "$outputdir/boots_samples/rr`g'/bs_ps_`k'.dta"
		qui clear

		* 	Display progress:
		display "SUCCESS: Passed Bootstrap Round `k' in robust subsample `g' ..."
	}
}
*
***** End of do file *****
