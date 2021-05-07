
/*******************************************************************************
	
Carries out all selection steps as in baseline, without conditioning on participation
________________________________________________________________________________

Filename: 	HF16_participation_unconditional.do
Author: 	Alexandros Theloudis (a.theloudis@gmail.com)
			LISER Luxembourg
			Tilburg University, Department of Econometrics & Operations Research
Date: 		Spring 2021

This file: 
(1)		Reads 'consumption_assets.dta' which contains the data immediately 
		before the selection on labor market participation.
(2)		Generates earnings and wage variables and the log of the real income 
		and consumption measures. Generates labor participation indicator.
(3) 	Drops observations with wage half the level of the state minimum wage, 
		wealth higher than $20M, for which earnings, wages, or consumption are
		on the top 0.25% of the relevant distributions or exhibit extreme jumps, 
		and observations with missing or zero consumption. 
(4)		Generates indicators for households that are transitioning in and out
		of the labor market. Generates first differences.
		
Note 1:	The resulting dataset is meant to replicate as much of the selection 
		criteria in the baseline sample as possible with the exception of labor
		market participaton. However, conditioning here on pH==1 and pW==1 
		(participation for both spouses) does not result in	the baseline sample, 
		but in a sample quite close to it. To see why, when I drop extreme 
		values in consumption below, I trim away the top 0.25% of the 
		consumption distribution among couples with working	and non-working 
		spouses. By contrast, in the baseline sample I trim away the top 0.25% 
		of the consumption distribution among working spouses only. Although the 
		set of selection criteria applied here are the same as in the baseline 
		sample (with the exception of labor market participation) the different 
		base sample size will result in small differences between the baseline 
		sample and this one if I now condition on participation.

Note 2: This non-baseline sample is only used in 'HF17_descr_stats.do' to
		calculate distribution statistics for the larger sample of those who do 
		not necessarily work in the market (mentioned in Section 4.2).

*******************************************************************************/

*	Initial statements:
clear all
set more off
cap log close

*	Load data:
cd $STATAdir
use $outputdir/consumption_assets.dta, clear


/*******************************************************************************
Earnings, wage, hours, consumption, wealth variables
*******************************************************************************/

*	Earnings variables:
*	I define earnings as the sum of earnings from labor and the labor part of 
*	business income from unincorporated businesses. This definition excludes
*	the labor part of farm income as this is not clearly measured. All measures
*	have been checked against the PSID codebook and they do not contain 
*	censored values:
gen earnH = lH + blincH
gen earnW = lW + blincW
label variable earnH	"EARNINGS ANNUAL HD"
label variable earnW	"EARNINGS ANNUAL WF"

*	Wage variables:
gen wageH = earnH / hoursH
gen wageW = earnW / hoursW
label variable wageH	"HOURLY WAGE HD"
label variable wageW	"HOURLY WAGE WF"

*	Real consumption:
gen r_cons = consumption/annual1
label variable r_cons	"REAL CONSUMPTION"

*	Real wealth:
gen r_wealth = wealth/annual1
label variable r_wealth	"REAL WEALTH"

* 	Lag levels of hours and consumption:
sort hh_id year
tsset hh_id year		/* declare dataset to be a panel */
gen L2hoursH = L2.hoursH
gen L2hoursW = L2.hoursW
gen L2r_cons = L2.r_cons
label variable L2hoursH	"LAG HOURS HD"
label variable L2hoursW	"LAG HOURS WF"
label variable L2r_cons	"LAG REAL CONSUMPTION"

* 	Log of (real) earnings, wages, hours, consumption:
gen lr_earnH 	= ln(earnH/annual1)
gen lr_earnW 	= ln(earnW/annual1)
gen lr_wageH 	= ln(wageH/annual1)
gen lr_wageW 	= ln(wageW/annual1)
gen l_hoursH    = ln(hoursH)
gen l_hoursW    = ln(hoursW)
gen lr_cons 	= ln(consumption/annual1)
label variable lr_earnH	"LOG REAL EARNINGS HD"
label variable lr_earnW	"LOG REAL EARNINGS WF"
label variable lr_wageH	"LOG REAL WAGE HD"
label variable lr_wageW	"LOG REAL WAGE WF"
label variable l_hoursH	"LOG HOURS HD"
label variable l_hoursW	"LOG HOURS WF"
label variable lr_cons	"LOG REAL CONSUMPTION"

*	Define labor market participation:
gen pH = (earnH > 0 & hoursH > 0)
gen pW = (earnW > 0 & hoursW > 0)


/*******************************************************************************
Minimum wages, top values, and extreme jumps
*******************************************************************************/

*	Drop if wage of those working is below half the state minimum wage:
*	Note: this selection criterions applies to those working, but the 
*	conditionality does not mimic the baseline sample as it does not require 
*	that the spouse is also working.
drop if wageH < 0.5*min_wage & pH == 1
drop if wageW < 0.5*min_wage & pW == 1

*	Tag those with real wealth > $20M:
gen todrop = (r_wealth > 20000000 & wealth != .)

*	Tag missing or 0 consumption:
replace todrop = 1 if (consumption == 0 | consumption == .) & year >= 1999

*	Declare dataset to be a panel:
sort hh_id year
tsset hh_id year		/* declare dataset to be a panel */

*	Generate indicators for transitions in and out of the labor market:
by hh_id : gen transitionH = (pH != L2.pH)
by hh_id : gen transitionW = (pW != L2.pW)

*	Generate extreme jump variables:
*  	--wages and earnings for those working (conditionality mimics baseline sample):
foreach var of varlist lr_wage* lr_earn* {
	by hh_id : gen DL2_`var' = `var' - L2.`var' if pH == 1 & pW == 1 & L2.pH == 1 & L2.pW == 1
	by hh_id : gen DF2_`var' = F2.`var' - `var' if pH == 1 & pW == 1 & F2.pH == 1 & F2.pW == 1
	gen jump_`var' = DL2_`var'*DF2_`var'
	drop DL2* DF2* 
}
*	--consumption for everyone:
by hh_id : gen DL2_lr_cons = lr_cons - L2.lr_cons
by hh_id : gen DF2_lr_cons = F2.lr_cons - lr_cons
gen jump_lr_cons = DL2_lr_cons*DF2_lr_cons
drop DL2* DF2* 

*	Tag extreme bottom jumps:
foreach var of varlist jump_lr_* {
	egen pc_`var' = pctile(`var'), by(year) p(0.25)
	replace todrop = 1 if `var' <= pc_`var' & `var' != .
}
*	Drop extreme top values, missing consumption, and extreme bottom jumps:
drop if todrop == 1
drop todrop pc* jump*


/*******************************************************************************
Household chores
*******************************************************************************/

*	Standardize home production inputs of spouses:
replace hpH = . if (hpH==998 | hpH==999)
replace hpW = . if (hpW==998 | hpW==999)

* 	Lag levels of chores:
sort hh_id year
tsset hh_id year		/* declare dataset to be a panel */
gen L2hpH = L2.hpH
gen L2hpW = L2.hpW
label variable L2hpH	"LAG CHORES HD"
label variable L2hpW	"LAG CHORES WF"


/*******************************************************************************
First differences in wages, earnings, hours, consumption.
*******************************************************************************/

*	Generate the first differences:
sort hh_id year
tsset hh_id year		/* declare dataset to be a panel */
foreach var of varlist lr_* l_* {
	by hh_id : gen DL2_`var' = `var' - L2.`var'
	by hh_id : gen DF2_`var' = F2.`var' - `var'
}
*	Drop observations that do not contribute to first differences & count:
*	These are observations at t or t-1 that do not contribute to the 
*	construction of log var_{t} - log var_{t-1}, which is the backbone of the 
*	estimation of the structural model. These are households that appear, for 
*	example, only once or only in years too far apart. I drop such observations 
*	because I do not want to use them for the estimation of the partial 
*	insurance parameters or in the bootstrap resampling. I only select on
*	(DL2_lr_wageH == . & DF2_lr_wageH == .) as this condition also reflects, 
*	given the selection criteria above, observations that do not contribute to
*	the wife's first difference or to consumption's first diff. 
gen todrop = 1 if DL2_lr_wageH == . & DF2_lr_wageH == .
drop if todrop == 1

*	Keep subset of variables:
keep hh_id year ageH ageW DL2* pH pW transition*

*	Save dataset:
compress
save $outputdir/participation_nonconditional.dta, replace

***** End of do file *****
