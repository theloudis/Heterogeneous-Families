
/*******************************************************************************
	
Produces descriptive statistics for the paper.
________________________________________________________________________________

Filename: 	HF17_descr_stats.do
Author: 	Alexandros Theloudis (a.theloudis@gmail.com)
			LISER Luxembourg
			Tilburg University, Department of Econometrics & Operations Research
Date: 		Spring 2021

This file: 
(1)		Produces table 2 for volatility and skewness.
(2)		Produces table D.1 for summary statistics in baseline sample and 
		subsamples of wealthy households.
(3)		Produces table D.2 for first-stage regressions on past outcomes.
(4) 	Measure sample depletion when removing extreme observations (table E.2).

*******************************************************************************/

*	Initial statements:
clear
clear matrix
set more off
cap log close

*	Load dataset:
qui cd $STATAdir
use $outputdir/final_sample.dta, clear


/*******************************************************************************
TABLE 2: Volatility and Skewness.
*******************************************************************************/

preserve

*	Keep main years only:
keep if year > 1997

*	Label variables:
label variable DL2_lr_earnH  "~\Delta \log Y_{1it}"
label variable DL2_lr_earnW  "~\Delta \log Y_{2it}"
label variable DL2_lr_wageH  "~\Delta \log W_{1it}"
label variable DL2_lr_wageW  "~\Delta \log W_{2it}"
label variable DL2_lr_cons   "~\Delta \log C_{it}"

*	Distribution summary statistics for entire sample:
eststo: estpost summarize DL2_*, de listwise

*	Distribution summary statistics for subsamples of wealthy:
foreach g in 1 2 3 4 {
	eststo: estpost summarize DL2_lr_* if wealth_r`g'==1, de listwise
}

*	Export distribution summary statistics:
esttab using $xlsdir/table_2.csv, replace cells("sd(fmt(3))") label
esttab using $xlsdir/table_2.csv, append cells("skewness(fmt(3))") label
eststo clear

*	Consumption distribution summary statistics for sample of workers and non-workers:
*	Note 1: This is not part of table 2, instead reference to these numbers is 
*			made in section 4.2 ('Selection into labor market').
*	Note 2: I calculate the distribution of summary statistics removing the 
*			years when a couple experiences a transition in or out of the labor 
*			market, as such year likely exaggerates consumption growth.
use $outputdir/participation_nonconditional.dta, clear
keep if year > 1997
label variable DL2_lr_cons   "~\Delta \log C_{it}"
estpost summarize DL2_lr_cons if transitionH == 0 & transitionW == 0, de listwise

restore


/*******************************************************************************
TABLE D.1: Sample Desctiptive Statistics
*******************************************************************************/

preserve

*	Keep main years only:
keep if year > 1997

*	Generate temporary new variables (levels):
gen rearnH = earnH / annual1
gen rearnW = earnW / annual1
gen rwageH = wageH / annual1
gen rwageW = wageW / annual1
gen collH  = scH == 3
gen collW  = scW == 3
foreach var of varlist coll* {
	qui replace `var' = `var'*100
}
gen rcons 		  = consumption / annual1
gen rfin    	  = fin / annual1
gen rfoodout   	  = foodout / annual1
gen rvehs		  = vehs / annual1
gen rptrans		  = ptrans / annual1
gen rchildcare    = childcare / annual1
gen redu		  = edu / annual1
gen rmedservdrugs = (medserv + drugs + ownhealth) / annual1
gen rutils		  = utils / annual1
gen rhousing	  = (allrents + homeinsur) / annual1
gen rwealth       = wealth / 1000 / annual1
gen rhomeequit    = homeequit / 1000 / annual1
gen rtassets 	  = (estates + wheels + farm_bus + investm + ira_annu + savings + otherasset) / 1000 / annual1
gen restates      = estates / 1000 / annual1
gen rsavings      = savings / 1000 / annual1
gen rinvestm      = investm / 1000 / annual1
gen rdebts        = debts / 1000 / annual1

*	Label variables for appearance in paper tables:
label variable rearnH		 "~Earnings"
label variable rearnW		 "~Earnings"
label variable hoursH		 "~Hours of work"
label variable hoursW		 "~Hours of work"
label variable rwageH		 "~Hourly wage"
label variable rwageW		 "~Hourly wage"
label variable ageH			 "~Age"
label variable ageW			 "~Age"
label variable collH		 "~Some college \%"
label variable collW		 "~Some college \%"
label variable rcons 		 "~Total consumption"	 
label variable rfin    	     "~~~~food at home"
label variable rfoodout   	 "~~~~food away from home"
label variable rvehs		 "~~~~vehicles"
label variable rptrans		 "~~~~public transport"
label variable rchildcare    "~~~~childcare"
label variable redu		     "~~~~education"
label variable rmedservdrugs "~~~~medical expenses" 
label variable rutils		 "~~~~utilities"  
label variable rhousing	     "~~~~housing"
label variable rwealth       "~Total wealth"
label variable rhomeequit    "~Home equity"
label variable rdebts        "~Other debt"
label variable rtassets 	 "~All other assets"
label variable restates      "~~~~other real estate"
label variable rsavings      "~~~~savings accounts"
label variable rinvestm      "~~~~stocks-shares"
label variable kids			 "~\# of children"

* 	Calculate summary statistics for baseline sample and export:	
cap eststo clear
#delimit;
eststo: estpost summarize rearnH hoursH rwageH ageH collH 
				rearnW hoursW rwageW ageW collW 
				rcons rfin rfoodout rvehs rptrans rchildcare redu rmedservdrugs rutils rhousing 
				rwealth rhomeequit rdebts rtassets restates rsavings rinvestm
				kids, de listwise ;
#delimit cr
esttab using $xlsdir/table_d1.csv, replace cells("mean(fmt(1)) p50(fmt(1)) sd(fmt(1))") label
eststo clear

* 	Calculate summary statistics for subsamples of wealthy households and append:
foreach g in 1 2 3 4 {
	#delimit;
	eststo: estpost summarize rearnH hoursH rwageH ageH collH 
					rearnW hoursW rwageW ageW collW 
					rcons rfin rfoodout rvehs rptrans rchildcare redu rmedservdrugs rutils rhousing 
					rwealth rhomeequit rdebts rtassets restates rsavings rinvestm
					kids if wealth_r`g'==1, de listwise ;
	#delimit cr
	esttab using $xlsdir/table_d1.csv, append cells("mean(fmt(1))") label
	eststo clear
}
restore


/*******************************************************************************
TABLE D.2: First Stage Regressions: Past Levels
*******************************************************************************/

preserve
set matsize 500
sort hh_id year

*	Keep main years only:
keep if year > 1997

*	Label variables:
label variable DL2_lr_earnH  	"\Delta \ln Y_{1it}"
label variable DL2_lr_earnW  	"\Delta \ln Y_{2it}"
label variable DL2_lr_cons   	"\Delta \ln C_{it}"
label variable DL2_l_hoursH  	"\Delta \ln H_{1it}"
label variable DL2_l_hoursW  	"\Delta \ln H_{2it}"
label variable L2hoursH 		"H_{1it-1}"	
label variable L2hoursW 		"H_{2it-1}"
label variable L2r_cons			"C_{it-1}"

*	Generate again all the first-stage regressors for earnings and consumption:
qui gen kid = recode(kids, 0, 1, 2, 3, 4, 5)
qui gen nfm = recode(numfu, 1, 2, 3, 4, 5, 6, 7)
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

*	Run 1st stage regression:
eststo clear
#delimit;
eststo: regress DL2_lr_earnH L2hoursH L2hoursW L2r_cons 
				_Iyear_* _IageH_* _IageW_*	_IedH_* _IedW_* _IrcH_* _IrcW_* 
				_Istate_* _IyeaXedH_* _IyeaXedW_* _IyeaXrcH_* _IyeaXrcW_* _IyeaXwrk_* 
				_IyeaXune_* _IyeaXret_* _IyeaXwrka* _IyeaXunea* _IyeaXreta* kidd* nfmd* 
				outside others wrkngH unemplH retrdH wrkngW unemplW retrdW dkidd* dnfmd* 
				doutside dothers dwrkngH dunemplH dretrdH dwrkngW dunemplW dretrdW ;
eststo: regress DL2_lr_earnW L2hoursH L2hoursW L2r_cons 
				_Iyear_* _IageH_* _IageW_*	_IedH_* _IedW_* _IrcH_* _IrcW_* 
				_Istate_* _IyeaXedH_* _IyeaXedW_* _IyeaXrcH_* _IyeaXrcW_* _IyeaXwrk_* 
				_IyeaXune_* _IyeaXret_* _IyeaXwrka* _IyeaXunea* _IyeaXreta* kidd* nfmd* 
				outside others wrkngH unemplH retrdH wrkngW unemplW retrdW dkidd* dnfmd* 
				doutside dothers dwrkngH dunemplH dretrdH dwrkngW dunemplW dretrdW ;
eststo: regress DL2_lr_cons  L2hoursH L2hoursW L2r_cons 
				_Iyear_* _IageH_* _IageW_*	_IedH_* _IedW_* _IrcH_* _IrcW_* 
				_Istate_* _IyeaXedH_* _IyeaXedW_* _IyeaXrcH_* _IyeaXrcW_* _IyeaXwrk_* 
				_IyeaXune_* _IyeaXret_* _IyeaXwrka* _IyeaXunea* _IyeaXreta* kidd* nfmd* 
				outside others wrkngH unemplH retrdH wrkngW unemplW retrdW dkidd* dnfmd* 
				doutside dothers dwrkngH dunemplH dretrdH dwrkngW dunemplW dretrdW ;
eststo: regress DL2_l_hoursH L2hoursH L2hoursW L2r_cons 
				_Iyear_* _IageH_* _IageW_*	_IedH_* _IedW_* _IrcH_* _IrcW_* 
				_Istate_* _IyeaXedH_* _IyeaXedW_* _IyeaXrcH_* _IyeaXrcW_* _IyeaXwrk_* 
				_IyeaXune_* _IyeaXret_* _IyeaXwrka* _IyeaXunea* _IyeaXreta* kidd* nfmd* 
				outside others wrkngH unemplH retrdH wrkngW unemplW retrdW dkidd* dnfmd* 
				doutside dothers dwrkngH dunemplH dretrdH dwrkngW dunemplW dretrdW ;
eststo: regress DL2_l_hoursW L2hoursH L2hoursW L2r_cons 
				_Iyear_* _IageH_* _IageW_*	_IedH_* _IedW_* _IrcH_* _IrcW_* 
				_Istate_* _IyeaXedH_* _IyeaXedW_* _IyeaXrcH_* _IyeaXrcW_* _IyeaXwrk_* 
				_IyeaXune_* _IyeaXret_* _IyeaXwrka* _IyeaXunea* _IyeaXreta* kidd* nfmd* 
				outside others wrkngH unemplH retrdH wrkngW unemplW retrdW dkidd* dnfmd* 
				doutside dothers dwrkngH dunemplH dretrdH dwrkngW dunemplW dretrdW ;

#delimit cr

*	Export results in excel and tex:
esttab, b(%10.2e) keep(L2hoursH L2hoursW L2r_cons) label nostar
esttab, b(%10.2e) keep(L2hoursH L2hoursW L2r_cons) label nostar 
esttab est1 est2 est3 using $xlsdir/table_d2.csv, replace b(%10.2e) keep(L2hoursH L2hoursW L2r_cons) label nostar
eststo clear

restore


/*******************************************************************************
Sample size for baseline estimation and for wage estimation
*******************************************************************************/

*	Measure the sample sizes:
count if DL2_lr_wageH !=. & year>1999
local N_baseline = r(N)
count if DL2_lr_wageH !=.
local N_baseline_wages = r(N)

di "Baseline sample size is `N_baseline'."
di "Sample size for wage estimation is `N_baseline_wages'."


/*******************************************************************************
Sample size for baseline estimation and for wage estimation when the
first-stage regressions also control for chores & age of youngest child.
*******************************************************************************/

*	Measure the sample sizes:
count if DL2_lr_wageH !=. & year>1999 & hpH !=. & hpW !=. & ageK !=.
local N_baseline = r(N)
count if DL2_lr_wageH !=. & hpH !=. & hpW !=. & ageK !=.
local N_baseline_wages = r(N)

di "Baseline sample size (agek) is `N_baseline'."
di "Sample size for wage estimation (agek) is `N_baseline_wages'."


/*******************************************************************************
Sample depletion: removing extreme observations (table E.2)
*******************************************************************************/

*	Measure the sample depletion when I remove extreme observations; 
*	display as proportion of baseline sample:
count if DL2_lr_wageH !=. & year>1999
local N_baseline = r(N)
count if DL2_lr_wageH !=. & year>1999 & robust_r1==1
local N_R1 = r(N)
count if DL2_lr_wageH !=. & year>1999 & robust_r2==1
local N_R2 = r(N)
count if DL2_lr_wageH !=. & year>1999 & robust_r3==1
local N_R3 = r(N)

di "Robustness 1 drops " round(((`N_baseline'-`N_R1')/`N_baseline')*100,0.01) "% of the baseline sample."
di "Robustness 3 drops " round(((`N_baseline'-`N_R2')/`N_baseline')*100,0.01) "% of the baseline sample."
di "Robustness 5 drops " round(((`N_baseline'-`N_R3')/`N_baseline')*100,0.01) "% of the baseline sample."
di "Baseline sample size is `N_baseline'."
di "Sample size in Robustness 1 is is `N_R1'."
di "Sample size in Robustness 2 is is `N_R2'."
di "Sample size in Robustness 3 is is `N_R3'."

***** End of do file *****