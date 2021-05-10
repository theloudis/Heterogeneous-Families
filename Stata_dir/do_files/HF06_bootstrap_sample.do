
/*******************************************************************************
	
Generates new variables and carries out final sample selection
________________________________________________________________________________

Filename: 	HF06_bootstrap_sample.do
Author: 	Alexandros Theloudis (a.theloudis@gmail.com)
			LISER Luxembourg
			Tilburg University, Department of Econometrics & Operations Research
Date: 		Spring 2021

This file: 
(1)		Generates earnings and wage variables.
(2) 	Generates log of real income and consumption.
(3)  	Keeps in only those couples who participate in the labor market. 
(4) 	Drops observations with wage half the level of the state minimum wage, 
		wealth higher than $20M, for which earnings, wages, or consumption 
		exhibit extreme jumps, and observations with missing/zero consumption. 
(5)		Generates subsamples of wealthy households under alternative definitions.
(6)		Generates subsamples trimming extreme observations.

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


/*******************************************************************************
Labor market participation
*******************************************************************************/

*	Define labor market participation:
gen pH = (earnH > 0 & hoursH > 0)
gen pW = (earnW > 0 & hoursW > 0)

*	Summarize participation rates:
sum pH pW

*	Drop those who do not participate:
drop if pH == 0 | pW == 0
drop pH pW


/*******************************************************************************
Minimum wages, top values, and extreme jumps
*******************************************************************************/

*	Drop if wage is below half the state minimum wage & count:
drop if wageH < 0.5*min_wage | wageW < 0.5*min_wage

*	Tag those with real wealth > $20M:
gen todrop = (r_wealth > 20000000 & wealth != .)

*	Generate 'extreme jump' variable:
*	I define as 'extreme jump' the product between two consecutive first 
*	differences in log wage, earnings, consumpion for a given household. If 
*	'extreme jump' is negative and large, then it implies a big positive (neg) 
*	change in one period followed by a big neg (pos) change in the following 
*	one. This can be due to measurement error or a severe transitory shock.
sort hh_id year
tsset hh_id year		/* declare dataset to be a panel */
foreach var of varlist lr_* {
	by hh_id : gen DL2_`var' = `var' - L2.`var'
	by hh_id : gen DF2_`var' = F2.`var' - `var'
	gen jump_`var' = DL2_`var'*DF2_`var'
	drop DL2* DF2* 
}
*	Tag extreme bottom jumps:
foreach var of varlist jump_lr_* {
	egen pc_`var' = pctile(`var'), by(year) p(0.25)
	replace todrop = 1 if `var' <= pc_`var' & `var' != .
}
*	Tag missing or 0 consumption:
replace todrop = 1 if (consumption == 0 | consumption == .) & year >= 1999

*	Drop extreme top values + extreme bottom jumps:
drop if todrop == 1
drop todrop pc_* jump_*


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
drop todrop DF2*

*	Drop unwanted variables:
#delimit;
drop 	tu* new* lH lW min_wage mortg* numfstmp vfstmpPY fincHW blinc* bainc* 
		rinc* div* int* intW trinc* alimH taxincHW tanf* ssi* otherw* vapH pens*
		annuH otherrH uncomp* wcomp* cs* help* miscH miscW traninc* yrsmortg* 
		incltax1 inclinsur1 fam68 hometax pvownhome vsupportF lumpF fstmp* 
		vstmpCY combined hgas elctr gaselctr vehicle telecom otherutil
		totalhealth sexH self* union* ;
#delimit cr


/*******************************************************************************
Define wealthy households.
*******************************************************************************/

*	Define categories of 'rich' people, that is people who have some wealth. 
*	The last part of the paper re-estimates the model on 'rich' households only,
* 	so this categorization will be used there. I define 'rich' by comparing
*	different definitions of wealth to mean consumption per year. In 
*	certain cases I require that the households hold very little real debt. 

*	Generate mean consumption by year:	
bys year : egen meancons = mean(consumption)
sort hh_id year

*	Generate wealth indicator 1: 
*	wealth > mean consumption
gen wr = 0
replace wr = 1 if wealth > meancons
gen wealth_r1 = 1 if wr == 1 & wr[_n-1] == 1 & hh_id == hh_id[_n-1]
replace wealth_r1 = 1 if wr == 1 & year == 1999
label variable wealth_r1 "wealth > avg consumption"
drop wr

*	Generate wealth indicator 2: 
*	wealth > double mean consumption
gen wr = 0
replace wr = 1 if wealth > 2*meancons
gen wealth_r2 = 1 if wr == 1 & wr[_n-1] == 1 & hh_id == hh_id[_n-1]
replace wealth_r2 = 1 if wr == 1 & year == 1999
label variable wealth_r2 "wealth > 2 avg consumption"
drop wr

*	Generate wealth indicator 3: 
*	wealth > mean consumption & real debt < $2000 
gen wr = 0
gen rdebt = debt / annual1
replace wr = 1 if wealth > meancons & rdebt < 2000
gen wealth_r3 = 1 if wr == 1 & wr[_n-1] == 1 & hh_id == hh_id[_n-1]
replace wealth_r3 = 1 if wr == 1 & year == 1999
label variable wealth_r3 "wealth > avg cons & rdebt < $2000"
drop wr 

*	Generate wealth indicator 4: 
*	wealth net of home equity > mean consumption & real debt < $2000 
gen wr = 0
gen wealth_net_house = wealth - homeequit
replace wr = 1 if wealth_net_house > meancons & rdebt < 2000
gen wealth_r4 = 1 if wr == 1 & wr[_n-1] == 1 & hh_id == hh_id[_n-1]
replace wealth_r4 = 1 if wr == 1 & year == 1999
label variable wealth_r4 "non-home wealth > avg cons & rdebt < $2000"
drop wr wealth_net_house rdebt meancons


/*******************************************************************************
Define subsamples that drop extreme observations.
*******************************************************************************/

*	Define subsamples where I trim some of the most extreme observations in 
*	wages, earnings, and consumption. The appendix of the paper re-estimates the 
*	model on these subsamples only, so this categorization will be used there. 

*	Generate quantiles of the distribution of wages by year:
sort year
local pctvals 0.5 1.0 2.0
foreach var of varlist lr_wageH lr_wageW {
	foreach pp of local pctvals {
		if `pp'==0.5 local p = 105
		if `pp'==1.0 local p = 110
		if `pp'==2.0 local p = 120
		local ppp = 100-`pp'
		by year : egen pctdn_`var'_`p' = pctile(`var'), p(`pp')
		by year : egen pctup_`var'_`p' = pctile(`var'), p(`ppp')
	}
}
*
*	Generate quantiles of the distribution of earnings and consumption by year:
foreach var of varlist lr_earnH lr_earnW lr_cons {
	by year : egen pctdn_`var'_105 = pctile(`var'), p(0.5)
	by year : egen pctup_`var'_105 = pctile(`var'), p(99.5)
}
sort hh_id year

*	Generate robust subsample 1:
*	Trim bottom and top 0.5% of distribution of wages.
gen rr = .
#delimit;
replace rr = 1 if 	lr_wageH > pctdn_lr_wageH_105 & 
					lr_wageH < pctup_lr_wageH_105 & 
					lr_wageW > pctdn_lr_wageW_105 & 
					lr_wageW < pctup_lr_wageW_105 ;
#delimit cr
gen robust_r1 = 1 if rr == 1 & rr[_n-1] == 1 & hh_id == hh_id[_n-1]
replace robust_r1 = 1 if rr == 1 & year == 1997
label variable robust_r1 "Trim top bottom 0.5% wages"
drop rr

*	Generate robust subsample 2:
*	Trim bottom and top 2.0% of distribution of wages.
gen rr = .
#delimit;
replace rr = 1 if 	lr_wageH > pctdn_lr_wageH_120 & 
					lr_wageH < pctup_lr_wageH_120 & 
					lr_wageW > pctdn_lr_wageW_120 & 
					lr_wageW < pctup_lr_wageW_120 ;
#delimit cr
gen robust_r2 = 1 if rr == 1 & rr[_n-1] == 1 & hh_id == hh_id[_n-1]
replace robust_r2 = 1 if rr == 1 & year == 1997
label variable robust_r2 "Trim top bottom 2.0% wages"
drop rr

*	Generate robust subsample 3:
*	Trim bottom and top 0.5% of all variables.
gen rr = .
#delimit;
replace rr = 1 if 	lr_wageH > pctdn_lr_wageH_105 & 
					lr_wageH < pctup_lr_wageH_105 & 
					lr_wageW > pctdn_lr_wageW_105 & 
					lr_wageW < pctup_lr_wageW_105 &
					lr_earnH > pctdn_lr_earnH_105 & 
					lr_earnH < pctup_lr_earnH_105 & 
					lr_earnW > pctdn_lr_earnW_105 & 
					lr_earnW < pctup_lr_earnW_105 ;
replace rr = . if   lr_cons < pctdn_lr_cons_105   &
					lr_cons > pctup_lr_cons_105   &
					lr_cons != . & year>=1999 ;
#delimit cr
gen robust_r3 = 1 if rr == 1 & rr[_n-1] == 1 & hh_id == hh_id[_n-1]
replace robust_r3 = 1 if rr == 1 & (year == 1997 | year == 1999)
label variable robust_r3 "Trim top bottom 0.5% all variables"
drop rr


/*******************************************************************************
Keep relevant variables and save.
*******************************************************************************/

*	Keep variables:
drop pctdn* pctup*
#delimit;
keep 	hh_id year ageH ageW numfu kids state annual1 ageK hpW hpH supportF 
		hoursH hoursW rcH rcW edH edW incF taxincR emplH emplW consumption scH scW
		earnH earnW wageH wageW r_cons ybH ybW wealth
		L2* lr_* l_* DL2_l* wealth_r* robust_r* 
		fin foodout vehs ptrans childcare edu medserv drugs ownhealth utils 
		allrents homeinsur wealth homeequit estates wheels farm_bus 
		investm ira_annu savings otherasset estates savings investm debts ;
#delimit cr

*	Save dataset:
compress
save $outputdir/final_sample.dta, replace

***** End of do file *****
