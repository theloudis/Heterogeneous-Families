
/*******************************************************************************
	
Carries out the 1st stage regressions of hours and consumption
________________________________________________________________________________

Filename: 	HF07_first_stage.do
Author: 	Alexandros Theloudis (a.theloudis@gmail.com)
			LISER Luxembourg
			Tilburg University, Department of Econometrics & Operations Research
Date: 		Spring 2021

This file: 
(1)		Declares programmes for the first stage wage regressions (one for 
		household head, another for household wife/"wife").
(2)		Declares programmes for first stage earnings and consumption regressions
			-baseline (ie. netting out past consumption and hours levels),
			-also controlling for chores and age of youngest child.
(3)		Implements the first-stage regressions over entire sample.
(4)     Implements the first-stage regressions over subsamples of wealthy.
(5) 	Implements the first-stage regressions over subsamples after 
		trimming extreme observations.

*******************************************************************************/

*	Initial statements:
clear all
set more off
cap log close


/*******************************************************************************
Declare 1st stage wage regressions
*******************************************************************************/

*	Wage regression for household head:
*	Options include: `1' regressand; `2' name of residuals to be saved under; 
*	`3' quietly or noisily
capture program drop wagerH
program define wagerH
version 13
`3' {

	*	Declaration of left-hand side variable:
	qui gen Dlog = `1'
	
	*	Construction of first-stage regressors:
	#delimit;
	qui xi 	i.year 			/* year dummies 		*/
			i.ageH 			/* age dummies  		*/
			i.edH 			/* education dummies	*/
			i.rcH 			/* race dummy			*/
			i.state 		/* state dummy			*/
			i.year*i.edH 	/* year education intrc	*/
			i.year*i.rcH ;	/* year race intrc		*/
	#delimit cr
	
	*	Run 1st stage wage regression for heads & get residuals:
	reg Dlog _I*
	qui predict residuals if e(sample), res
	qui replace `2' = residuals if e(sample)
	
	*	Drop temporary variables:
	qui drop Dlog _I* residuals
}
end

*	Wage regression for wife:
*	Options include: `1' regressand; `2' name of residuals to be saved under; 
*	`3' quietly or noisily
capture program drop wagerW
program define wagerW
version 13
`3' {

	*	Declaration of left-hand side variable:
	qui gen Dlog = `1'
	
	*	Construction of first-stage regressors:
	#delimit;
	qui xi 	i.year 			/* year dummies 		*/
			i.ageW 			/* age dummies  		*/
			i.edW 			/* education dummies	*/
			i.rcW 			/* race dummy			*/
			i.state 		/* state dummy			*/
			i.year*i.edW 	/* year education intrc	*/
			i.year*i.rcW ;	/* year race intrc		*/
	#delimit cr
	
	*	Run 1st stage wage regression for wives & get residuals:
	reg Dlog _I*
	qui predict residuals if e(sample), res
	qui replace `2' = residuals if e(sample)
	
	*	Drop temporary variables:
	qui drop Dlog _I* residuals
}
end


/*******************************************************************************
Declare 1st stage earnings & consumption regressions 
netting out past levels of consumption and hours.
*******************************************************************************/

*	Earnings regression for couples:
*	Options include: `1' regressand; `2' name of residuals to be saved under; 
*	`3' quietly or noisily
capture program drop earningsr
program define earningsr
version 13
`3' {
	*	Set number of variables:
	set matsize 500

	*	Declaration of left-hand side variable:
	qui gen Dlog = `1'
	
	*	Adjustments to right-hand-side variables:
	qui gen kid = recode(kids, 0, 1, 2, 3, 4, 5)
	qui gen nfm = recode(numfu, 1, 2, 3, 4, 5, 6, 7)
	
	*	Construction of first-stage regressors:
	qui tab kid, gen(kidd)
	qui tab nfm, gen(nfmd)
	qui gen outside = (supportF == 1)
	qui gen others  = (taxincR > 0)
	qui gen wrkngH	= emplH == 1
	qui gen unemplH = (emplH == 2 | emplH == 3)
	qui gen retrdH  = emplH == 4
	qui gen wrkngW	= emplW == 1
	qui gen unemplW = (emplW == 2 | emplW == 3)
	qui gen retrdW  = emplW == 4
	
	foreach var of varlist kid nfm outside others wrkngH unemplH retrdH wrkngW unemplW retrdW {
		qby hh_id : gen d`var' = `var' - L2.`var'
	}
	
	qui tab dkid, gen(dkidd)
	qui tab dnfm, gen(dnfmd)
	
	#delimit;
	qui xi 	i.year 				/* year dummies 		*/
			i.ageH 				/* HD age dummies  		*/
			i.ageW 				/* WF age dummies  		*/
			i.edH 				/* HD education dummies	*/
			i.edW 				/* WF education dummies	*/
			i.rcH 				/* HD race dummy		*/
			i.rcW 				/* WF race dummy		*/
			i.state 			/* state dummy			*/
			i.year*i.edH 		/* year education intrc	*/
			i.year*i.edW 		/* year education intrc	*/
			i.year*i.rcH 		/* year race intrc		*/
			i.year*i.rcW 		/* year race intrc		*/
			i.year*i.wrkngH		/* year employment intrc*/
			i.year*i.unemplH	/* year employment intrc*/
			i.year*i.retrdH		/* year employment intrc*/
			i.year*i.wrkngW		/* year employment intrc*/
			i.year*i.unemplW	/* year employment intrc*/
			i.year*i.retrdW	;	/* year employment intrc*/
	#delimit cr
	
	*	Run 1st stage earnings regression & get residuals:
	#delimit;
	reg 	Dlog 	L2hoursH L2hoursW L2r_cons
					_Iyear_* _IageH_* _IageW_*
					_IedH_* _IedW_* _IrcH_* _IrcW_* _Istate_*
					_IyeaXedH_* _IyeaXedW_* _IyeaXrcH_* _IyeaXrcW_*
					_IyeaXwrk_* _IyeaXune_* _IyeaXret_* 
					_IyeaXwrka* _IyeaXunea* _IyeaXreta*
					kidd* nfmd* outside others
					wrkngH unemplH retrdH
					wrkngW unemplW retrdW
					dkidd* dnfmd* doutside dothers 
					dwrkngH dunemplH dretrdH
					dwrkngW dunemplW dretrdW ;
	#delimit cr
	qui predict residuals if e(sample), res
	qui replace `2' = residuals if e(sample)
	
	*	Drop temporary variables:
	#delimit;
	qui drop 	Dlog kid kidd* nfm* _I* outside others dkid* dnfm* doutside dothers 
				wrkng* unempl* retrd* dwrkng* dunempl* dretrd* residuals ;
	#delimit cr
}
end

*	Consumption regression for couples:
*	Options include: `1' regressand; `2' name of residuals to be saved under; 
*	`3' quietly or noisily
capture program drop consumptionr
program define consumptionr
version 13
`3' {
	*	Set number of variables:
	set matsize 500

	*	Declaration of left-hand side variable:
	qui gen Dlog = `1'
	
	*	Adjustments to right-hand-side variables:
	qui gen kid = recode(kids, 0, 1, 2, 3, 4, 5)
	qui gen nfm = recode(numfu, 1, 2, 3, 4, 5, 6, 7)
	
	*	Construction of first-stage regressors:
	qui tab kid, gen(kidd)
	qui tab nfm, gen(nfmd)
	qui gen outside = (supportF == 1)
	qui gen others  = (taxincR > 0)
	qui gen wrkngH	= emplH == 1
	qui gen unemplH = (emplH == 2 | emplH == 3)
	qui gen retrdH  = emplH == 4
	qui gen wrkngW	= emplW == 1
	qui gen unemplW = (emplW == 2 | emplW == 3)
	qui gen retrdW  = emplW == 4
	
	foreach var of varlist kid nfm outside others wrkngH unemplH retrdH wrkngW unemplW retrdW {
		qby hh_id : gen d`var' = `var' - L2.`var'
	}
	
	qui tab dkid, gen(dkidd)
	qui tab dnfm, gen(dnfmd)
	
	#delimit;
	qui xi 	i.year 				/* year dummies 		*/
			i.ageH 				/* HD age dummies  		*/
			i.ageW 				/* WF age dummies  		*/
			i.edH 				/* HD education dummies	*/
			i.edW 				/* WF education dummies	*/
			i.rcH 				/* HD race dummy		*/
			i.rcW 				/* WF race dummy		*/
			i.state 			/* state dummy			*/
			i.year*i.edH 		/* year education intrc	*/
			i.year*i.edW 		/* year education intrc	*/
			i.year*i.rcH 		/* year race intrc		*/
			i.year*i.rcW 		/* year race intrc		*/
			i.year*i.wrkngH		/* year employment intrc*/
			i.year*i.unemplH	/* year employment intrc*/
			i.year*i.retrdH		/* year employment intrc*/
			i.year*i.wrkngW		/* year employment intrc*/
			i.year*i.unemplW	/* year employment intrc*/
			i.year*i.retrdW	;	/* year employment intrc*/
	#delimit cr
	
	*	Run 1st stage consumption regression & get residuals:
	#delimit;
	reg 	Dlog 	L2hoursH L2hoursW L2r_cons
					_Iyear_* _IageH_* _IageW_*
					_IedH_* _IedW_* _IrcH_* _IrcW_* _Istate_*
					_IyeaXedH_* _IyeaXedW_* _IyeaXrcH_* _IyeaXrcW_*
					_IyeaXwrk_* _IyeaXune_* _IyeaXret_* 
					_IyeaXwrka* _IyeaXunea* _IyeaXreta*
					kidd* nfmd* outside others
					wrkngH unemplH retrdH
					wrkngW unemplW retrdW
					dkidd* dnfmd* doutside dothers 
					dwrkngH dunemplH dretrdH
					dwrkngW dunemplW dretrdW
					if year >= 1999 ;
	#delimit cr
	qui predict residuals if e(sample), res
	qui replace `2' = residuals if e(sample)
	
	*	Drop temporary variables:
	#delimit;
	qui drop 	Dlog kid kidd* nfm* _I* outside others dkid* dnfm* doutside dothers 
				wrkng* unempl* retrd* dwrkng* dunempl* dretrd* residuals ;
	#delimit cr
}
end


/*******************************************************************************
Declare 1st stage earnings & consumption regressions, 
netting out past levels of consumption and hours, 
age of youngest child and household chores.
*******************************************************************************/

*	Earnings regression for couples:
*	Options include: `1' regressand; `2' name of residuals to be saved under; 
*	`3' quietly or noisily
capture program drop earningsr_agek
program define earningsr_agek
version 13
`3' {
	*	Set number of variables:
	set matsize 500

	*	Declaration of left-hand side variable:
	qui gen Dlog = `1'
	
	*	Adjustments to right-hand-side variables:
	qui gen kid = recode(kids, 0, 1, 2, 3, 4, 5)
	qui gen nfm = recode(numfu, 1, 2, 3, 4, 5, 6, 7)
	qui recode ageK (0 = 0) (1/2 = 1) (3/6 = 2) (7/12 = 3) (13/17 = 4), gen(agey)
	
	*	Construction of first-stage regressors:
	qui tab kid, gen(kidd)
	qui tab nfm, gen(nfmd)
	qui tab agey, gen(ageyy)
	qui drop ageyy1 /* this is for children's age 0, i.e. no children */
	qui gen outside = (supportF == 1)
	qui gen others  = (taxincR > 0)
	qui gen wrkngH	= emplH == 1
	qui gen unemplH = (emplH == 2 | emplH == 3)
	qui gen retrdH  = emplH == 4
	qui gen wrkngW	= emplW == 1
	qui gen unemplW = (emplW == 2 | emplW == 3)
	qui gen retrdW  = emplW == 4
	
	foreach var of varlist kid nfm agey outside others wrkngH unemplH retrdH wrkngW unemplW retrdW {
		qby hh_id : gen d`var' = `var' - L2.`var'
	}
	
	qui tab dkid, gen(dkidd)
	qui tab dnfm, gen(dnfmd)
	qui recode dagey (-10/-1 = -1) (0 = 0) (1/10 = 1), gen(dageyy)
	qui tab dageyy, gen(dageyyd)
	
	#delimit;
	qui xi 	i.year 				/* year dummies 		*/
			i.ageH 				/* HD age dummies  		*/
			i.ageW 				/* WF age dummies  		*/
			i.edH 				/* HD education dummies	*/
			i.edW 				/* WF education dummies	*/
			i.rcH 				/* HD race dummy		*/
			i.rcW 				/* WF race dummy		*/
			i.state 			/* state dummy			*/
			i.year*i.edH 		/* year education intrc	*/
			i.year*i.edW 		/* year education intrc	*/
			i.year*i.rcH 		/* year race intrc		*/
			i.year*i.rcW 		/* year race intrc		*/
			i.year*i.wrkngH		/* year employment intrc*/
			i.year*i.unemplH	/* year employment intrc*/
			i.year*i.retrdH		/* year employment intrc*/
			i.year*i.wrkngW		/* year employment intrc*/
			i.year*i.unemplW	/* year employment intrc*/
			i.year*i.retrdW	;	/* year employment intrc*/
	#delimit cr
	
	*	Run 1st stage earnings regression & get residuals:
	#delimit;
	reg 	Dlog 	L2hoursH L2hoursW L2r_cons
					hpH hpW L2hpH L2hpW
					_Iyear_* _IageH_* _IageW_*
					_IedH_* _IedW_* _IrcH_* _IrcW_* _Istate_*
					_IyeaXedH_* _IyeaXedW_* _IyeaXrcH_* _IyeaXrcW_*
					_IyeaXwrk_* _IyeaXune_* _IyeaXret_* 
					_IyeaXwrka* _IyeaXunea* _IyeaXreta*
					kidd* nfmd* ageyy* outside others
					wrkngH unemplH retrdH
					wrkngW unemplW retrdW
					dkidd* dnfmd* dageyyd* doutside dothers 
					dwrkngH dunemplH dretrdH
					dwrkngW dunemplW dretrdW ;
	#delimit cr
	qui predict residuals if e(sample), res
	qui replace `2' = residuals if e(sample)
	
	*	Drop temporary variables:
	#delimit;
	qui drop 	Dlog kid kidd* nfm* agey* _I* outside others dkid* dnfm* dagey* 
				doutside dothers wrkng* unempl* retrd* dwrkng* dunempl* dretrd* residuals ;
	#delimit cr
}
end

*	Consumption regression for couples:
*	Options include: `1' regressand; `2' name of residuals to be saved under; 
*	`3' quietly or noisily
capture program drop consumptionr_agek
program define consumptionr_agek
version 13
`3' {
	*	Set number of variables:
	set matsize 500

	*	Declaration of left-hand side variable:
	qui gen Dlog = `1'
	
	*	Adjustments to right-hand-side variables:
	qui gen kid = recode(kids, 0, 1, 2, 3, 4, 5)
	qui gen nfm = recode(numfu, 1, 2, 3, 4, 5, 6, 7)
	qui recode ageK (0 = 0) (1/2 = 1) (3/6 = 2) (7/12 = 3) (13/17 = 4), gen(agey)
	
	*	Construction of first-stage regressors:
	qui tab kid, gen(kidd)
	qui tab nfm, gen(nfmd)
	qui tab agey, gen(ageyy)
	qui drop ageyy1 /* this is for children's age 0, i.e. no children */
	qui gen outside = (supportF == 1)
	qui gen others  = (taxincR > 0)
	qui gen wrkngH	= emplH == 1
	qui gen unemplH = (emplH == 2 | emplH == 3)
	qui gen retrdH  = emplH == 4
	qui gen wrkngW	= emplW == 1
	qui gen unemplW = (emplW == 2 | emplW == 3)
	qui gen retrdW  = emplW == 4
	
	foreach var of varlist kid nfm agey outside others wrkngH unemplH retrdH wrkngW unemplW retrdW {
		qby hh_id : gen d`var' = `var' - L2.`var'
	}
	
	qui tab dkid, gen(dkidd)
	qui tab dnfm, gen(dnfmd)
	qui recode dagey (-10/-1 = -1) (0 = 0) (1/10 = 1), gen(dageyy)
	qui tab dageyy, gen(dageyyd)
	
	#delimit;
	qui xi 	i.year 				/* year dummies 		*/
			i.ageH 				/* HD age dummies  		*/
			i.ageW 				/* WF age dummies  		*/
			i.edH 				/* HD education dummies	*/
			i.edW 				/* WF education dummies	*/
			i.rcH 				/* HD race dummy		*/
			i.rcW 				/* WF race dummy		*/
			i.state 			/* state dummy			*/
			i.year*i.edH 		/* year education intrc	*/
			i.year*i.edW 		/* year education intrc	*/
			i.year*i.rcH 		/* year race intrc		*/
			i.year*i.rcW 		/* year race intrc		*/
			i.year*i.wrkngH		/* year employment intrc*/
			i.year*i.unemplH	/* year employment intrc*/
			i.year*i.retrdH		/* year employment intrc*/
			i.year*i.wrkngW		/* year employment intrc*/
			i.year*i.unemplW	/* year employment intrc*/
			i.year*i.retrdW	;	/* year employment intrc*/
	#delimit cr
	
	*	Run 1st stage consumption regression & get residuals:
	#delimit;
	reg 	Dlog 	L2hoursH L2hoursW L2r_cons
					hpH hpW L2hpH L2hpW
					_Iyear_* _IageH_* _IageW_*
					_IedH_* _IedW_* _IrcH_* _IrcW_* _Istate_*
					_IyeaXedH_* _IyeaXedW_* _IyeaXrcH_* _IyeaXrcW_*
					_IyeaXwrk_* _IyeaXune_* _IyeaXret_* 
					_IyeaXwrka* _IyeaXunea* _IyeaXreta*
					kidd* nfmd* ageyy* outside others
					wrkngH unemplH retrdH
					wrkngW unemplW retrdW
					dkidd* dnfmd* dageyyd* doutside dothers 
					dwrkngH dunemplH dretrdH
					dwrkngW dunemplW dretrdW
					if year >= 1999 ;
	#delimit cr
	qui predict residuals if e(sample), res
	qui replace `2' = residuals if e(sample)
	
	*	Drop temporary variables:
	#delimit;
	qui drop 	Dlog kid kidd* nfm* agey* _I* outside others dkid* dnfm* dagey* 
				doutside dothers wrkng* unempl* retrd* dwrkng* dunempl* 
				dretrd* residuals ;
	#delimit cr
}
end


/*******************************************************************************
Run 1st stage regressions over entire sample
- A. wage regressions
- B. earnings & consumption regressions
- C. earnings & consumption regressions, controlling for
	 age of youngest child and household chores.
*******************************************************************************/

*	Load data and declare panel:
cd $STATAdir
use $outputdir/final_sample.dta, clear
sort hh_id year
tsset hh_id year

*	A. Wage regressions:
gen drwH = .
gen drwW = .
wagerH DL2_lr_wageH drwH noisily
wagerW DL2_lr_wageW drwW noisily

*	B. Earnings & consumption regressions, net of past levels:
gen dreH = .
gen dreW = .
gen drcons = .
earningsr 		DL2_lr_earnH 	dreH 	noisily
earningsr 		DL2_lr_earnW 	dreW 	noisily
consumptionr 	DL2_lr_cons 	drcons 	noisily

*	C. Earnings & consumption regressions, net of past levels, age of child and chores:
gen dreH_agek = .
gen dreW_agek = .
gen drcons_agek = .
earningsr_agek 		DL2_lr_earnH 	dreH_agek 	noisily
earningsr_agek 		DL2_lr_earnW 	dreW_agek 	noisily
consumptionr_agek 	DL2_lr_cons 	drcons_agek noisily

*	Label residuals:
label var drwH			"Du WAGE HD"
label var drwW			"Du WAGE WF"
label var dreH			"Du EARNINGS HD"
label var dreW			"Du EARNINGS WF"
label var drcons		"Du CONS"
label var dreH_agek		"Du EARNINGS HD agek"
label var dreW_agek		"Du EARNINGS WF agek"
label var drcons_agek	"Du CONS agek"

*	Drop unwanted variables and save dataset:
drop DL2*
sort hh_id year
compress
save $outputdir/residuals.dta, replace


/*******************************************************************************
Run 1st stage regressions over subset of wealthy.
- A. wage regressions
- B. earnings & consumption regressions.
*******************************************************************************/

*	Load data:
cd $STATAdir
use $outputdir/final_sample.dta, clear

*	Loop over 'wealthy' samples:
forvalues i=1/4 {

	*   Preserve, keep relevant subsample, declare panel:
	*	Note: The earnings regressions use regressors that require information 
	*	from previous year (for example, doutside). If I don't keep year 1997 
	*	in, then I won't be using earnings growth from year 1999 either. 
	*	Therefore I opt to keep year 1997 in even though there is no  
	*	information on household wealth in that year.
	preserve
	keep if wealth_r`i'==1 | year==1997
	sort hh_id year
	tsset hh_id year

	*	A. Wage regressions:
	gen drwH = .
	gen drwW = .
	wagerH DL2_lr_wageH drwH noisily
	wagerW DL2_lr_wageW drwW noisily

	*	B. Earnings & consumption regressions:
	gen dreH = .
	gen dreW = .
	gen drcons = .
	earningsr DL2_lr_earnH dreH noisily
	earningsr DL2_lr_earnW dreW noisily
	consumptionr DL2_lr_cons drcons noisily

	*	Label residuals:
	label var drwH		"Du WAGE HD"
	label var drwW		"Du WAGE WF"
	label var dreH		"Du EARNINGS HD"
	label var dreW		"Du EARNINGS WF"
	label var drcons	"Du CONS"

	*	Drop unwanted variables, save dataset, restore:
	drop DL2*
	sort hh_id year
	compress
	save $outputdir/residuals_wr`i'.dta, replace
	restore
}


/*******************************************************************************
Run 1st stage regressions over subsamples that trim extreme observations.
- A. wage regressions
- B. earnings & consumption regressions.
*******************************************************************************/

*	Load data:
cd $STATAdir
use $outputdir/final_sample.dta, clear

*	Loop over 'robust' samples:
forvalues i=1/3 {

	*   Preserve, keep relevant subsample, declare panel:
	*	Note: The earnings regressions use regressors that require information 
	*	from previous year (for example, doutside). If I don't keep year 1997 
	*	in, then I won't be using earnings growth from year 1999 either. 
	*	Therefore I opt to keep year 1997 in even though there is no  
	*	information on household wealth in that year.
	preserve
	keep if robust_r`i' == 1 | year == 1997
	sort hh_id year
	tsset hh_id year
	
	*	A. Wage regressions:
	gen drwH = .
	gen drwW = .
	wagerH DL2_lr_wageH drwH noisily
	wagerW DL2_lr_wageW drwW noisily

	*	B. Earnings & consumption regressions:
	gen dreH = .
	gen dreW = .
	gen drcons = .
	earningsr DL2_lr_earnH dreH noisily
	earningsr DL2_lr_earnW dreW noisily
	consumptionr DL2_lr_cons drcons noisily

	*	Label residuals:
	label var drwH		"Du WAGE HD"
	label var drwW		"Du WAGE WF"
	label var dreH		"Du EARNINGS HD"
	label var dreW		"Du EARNINGS WF"
	label var drcons	"Du CONS"

	*	Drop unwanted variables, save dataset, restore:
	drop DL2*
	sort hh_id year
	compress
	save $outputdir/residuals_rr`i'.dta, replace
	restore
}

***** End of do file *****
