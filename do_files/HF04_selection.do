
/*******************************************************************************
	
Carries out baseline sample selection as described in the paper
________________________________________________________________________________

Filename: 	HF04_selection.do
Author: 	Alexandros Theloudis (a.theloudis@gmail.com)
			LISER Luxembourg
			Tilburg University, Department of Econometrics & Operations Research
Date: 		Spring 2021

This file: 
(1)		Keeps in married/cohabiting spouses.
(2)		Drops unstable married couples.
(3)		Keeps in ages 30-60. Performs adjustments to make age, race, education 
		consistent over time for any same individual in the sample.
(4)		Adjusts household id for intermittent households.

*******************************************************************************/

*	Initial statements:
clear all
set more off
cap log close

*	Load data:
cd $STATAdir
use $outputdir/panel1997_2011_prices.dta, clear


/*******************************************************************************
Benchmark sample selection: marital status, age
*******************************************************************************/

*	Initial sample size count:
*estpost tabstat hh_id, by(year) statistics(count) 
*estout e(count) using "$xlsdir\SampleSelection.xls", replace varlabels(count All)

*	Select only couples that are formally married:
gen married = (ageW != 0 & mstatusH == 1) /* married == 1: spouse exists and couple is married */
drop if married == 0
drop married

*	Drop weird ages:
drop if ageH == 999 | ageW == 999

* 	Retrospective ages as income/consumption information is retrospective:
replace ageH = ageH-1
replace ageW = ageW-1

*	Check that all household heads are males:
qui sum sexH
	if r(mean) != 1 {
		error(1)
	}	
*
/*******************************************************************************
Stable married households
*******************************************************************************/

*	Tag couples experiencing compositional changes in the head-wife couple:
sort hh_id year
by hh_id : egen miny = min(year)
gen break_hh = newF > 1
replace break_hh = 0 if year == miny & break_hh == 1

*	Generate a new temporary panel identifier, 'temp_hh_id', that uniquely 
*	describes stable households (i.e. no changes in the head-wife couple).
*	'temp_hh_id' will be used to make the demographics information consistent
*	for each family over time:
gen newCouple = 0 if year == miny
by hh_id : replace newCouple = newCouple[_n-1] + break_hh if year != miny
gen temp_hh_id = hh_id + .1*newCouple
recast double temp_hh_id

*	Drop households when they exhibit compositional changes:
drop if break_hh == 1
drop break_hh miny newCouple
order hh_id temp_hh_id year


/*******************************************************************************
Consistency of age, race, education by household; region of residence; employment
*******************************************************************************/

*	Remove jumps from the age variable over the years. 
*	I use the first year a household is observed in the data to calculate each 
*	spouse's year of birth. I use the year of birth to remove jumps in the age 
*	variable over time:
sort temp_hh_id year
by temp_hh_id : egen miny = min(year)
gen minybH = year - ageH if year == miny
gen minybW = year - ageW if year == miny
by temp_hh_id : egen ybH = max(minybH)
by temp_hh_id : egen ybW = max(minybW)

replace ageH = year - ybH
replace ageW = year - ybW
drop miny minybH minybW
label var ybH "BIRTH YEAR HD"
label var ybW "BIRTH YEAR WF"

*	Drop those < 30 or > 60: 
drop if ageH < 30 | ageH > 60
drop if ageW < 30 | ageW > 60 

*	Harmonize the race variables across different mentions so that race =1 is 
*	white, =2 is black, =3 is other, =9/0 is wild/DK/DA/absent:
forv i = 1/4 {
	replace raceH`i' = 3 if raceH`i' >= 3 & raceH`i' <= 7
	replace raceW`i' = 3 if raceW`i' >= 3 & raceW`i' <= 7
}
*	Collapse different race mentions to one variable 
*	(=9 appears only in first mention, =0 appears only in subsequent mentions 
*	indicating no additional mentions were made):
gen raceH = raceH1 
gen raceW = raceW1
replace raceH = 3 if raceH2 != 0 | raceH3 != 0 | raceH4 != 0
replace raceW = 3 if raceW2 != 0 | raceW3 != 0 | raceW4 != 0
drop raceH1 raceH2 raceH3 raceH4 raceW1 raceW2 raceW3 raceW4

*	Make race consistent across time for any given spouse. Race switches 
*	across panel years can occur because one is given the option to mention 
*	more than one race and the order of such mentions may be reversed. This is 
*	especially true when there is a slight change in the offered race 
*	categories. In the 2005 survey for example, the 3rd category was changed 
*	from "Native American" to "American Indian or Alaska Native" and more 
*	detailed race mentions were offered.
*
*	To deal with this inconsistency I check that all spouses (men and
*	women) declare their race consistently over time. I use household 
*	identifier 'temp_hh_id' and exploit information within stable households:
sort temp_hh_id year
by temp_hh_id : egen sd_raceH = sd(raceH) /* missing values are generated if a household is only observed once */
by temp_hh_id : egen sd_raceW = sd(raceW)
replace sd_raceH = 0 if sd_raceH == .
replace sd_raceW = 0 if sd_raceW == .
by temp_hh_id : egen maxrcH = max(raceH)
by temp_hh_id : egen maxrcW = max(raceW)
gen rcH = maxrcH if sd_raceH == 0
gen rcW = maxrcW if sd_raceW == 0
replace rcH = 3 if sd_raceH > 0
replace rcW = 3 if sd_raceW > 0

drop sd_* maxrc* raceH raceW
label variable rcH "RACE HD CONSISTENT"
label variable rcW "RACE WF CONSISTENT" 

*	Make education consistent across panel years for any given spouse by
*	assigning him/her the highest reported educational attainment.
*
*	I use household identifier 'temp_hh_id' and exploit information 
*	within stable households:
sort temp_hh_id year

replace educH = . if educH == 99
replace educW = . if educW == 99
by temp_hh_id : egen maxedH = max(educH)
by temp_hh_id : egen maxedW = max(educW)
generate edH = maxedH
generate edW = maxedW

drop educ* maxed*
label variable edH "EDUC HD CONSISTENT"
label variable edW "EDUC WF CONSISTENT" 

*	Generate three schooling levels:
gen scH = 1 if edH >= 0 & edH < 12
replace scH = 2 if edH == 12
replace scH = 3 if edH > 12 & edH <= 17 
gen scW = 1 if edW >= 0 & edW < 12
replace scW = 2 if edW == 12
replace scW = 3 if edW > 12 & edW <= 17 
label variable scH "SCHOOLING HD CONSISTENT"
label variable scW "SCHOOLING WF CONSISTENT"

sort temp_hh_id year

*	Generate categorical variable for region of residence:
gen region = .
			
#delimit;
replace region = 1 if state == 6	/* Connecticut 	*/ 	| state == 18	/* Maine 		*/	| state == 20	/* Massachusetts*/ 
					| state == 28 	/* N Hampshire 	*/	| state == 29 	/* N Jersey 	*/	| state == 31 	/* N York		*/ 
					| state == 37 	/* Pennsylvania	*/	| state == 38 	/* Rhode Island */	| state == 44	/* Vermont 		*/ ;
replace region = 2 if state == 12 	/* Illinois		*/	| state == 13 	/* Indiana  	*/	| state == 14 	/* Iowa 		*/ 
					| state == 15 	/* Kansas 		*/	| state == 21 	/* Michigan 	*/	| state == 22	/* Minnesota 	*/ 
                    | state == 24 	/* Missouri 	*/	| state == 26 	/* Nebraska 	*/  | state == 33 	/* N Dakota 	*/ 
					| state == 34 	/* Ohio 		*/  | state == 40 	/* S Dakota 	*/	| state == 48	/* Wisconsin 	*/ ;
replace region = 3 if state == 1  	/* Alabama 		*/	| state == 3  	/* Arkansas 	*/	| state == 7  	/* Delaware 	*/ 
					| state == 8  	/* D Columbia 	*/	| state == 9  	/* Florida 		*/	| state == 10 	/* Georgia 		*/ 
					| state == 16 	/* Kentucky 	*/	| state == 17 	/* Louisiana 	*/	| state == 19 	/* Maryland 	*/ 
					| state == 23 	/* Mississippi 	*/	| state == 32 	/* N Carolina 	*/	| state == 35	/* Oklahoma 	*/
					| state == 39 	/* S Carolina 	*/	| state == 41 	/* Tennessee 	*/	| state == 42 	/* Texas 		*/ 
					| state == 45 	/* Virginia		*/	| state == 47	/* W Virginia 	*/  ;
replace region = 4 if state == 2 	/* Arizona 		*/ 	| state == 4  	/* California 	*/	| state == 5  	/* Colorado 	*/
					| state == 11 	/* Idaho 		*/  | state == 25 	/* Montana 		*/ 	| state == 27 	/* Nevada 		*/
					| state == 30	/* N Mexico 	*/  | state == 36 	/* Oregon 		*/	| state == 43 	/* Utah 		*/
					| state == 46 	/* Washington 	*/	| state == 49 	/* Wyoming 		*/	| state == 50 	/* Alaska 		*/
					| state == 51	/* Hawaii 		*/	;                             
#delimit cr
label variable region 	"US REGION"

*	Harmonize employment status mentions:
*	The rule I follow across multiple employment mentions is that lower values
*	(eg. '1 Working now', 2, '3 retired') have priority over higher ones (eg, 
*	'6 Keeping house', 7 'student'). For example, any combination of '1 Working 
*	now' with anything else across mentions is treated as '1 Working now'. 
*	However '2 Only temporarily laid off, sick leave or maternity leave' has
*	priority over '1 Working now'.
forvalues i = 1(1)3 {
	gen emplH`i'_temp =. 		
	replace emplH`i'_temp = 11 if emplH`i' == 2		/* priority category */
	replace emplH`i'_temp = 12 if emplH`i' == 1
	replace emplH`i'_temp = 13 if emplH`i' == 3
	replace emplH`i'_temp = 14 if emplH`i' == 4
	replace emplH`i'_temp = 15 if emplH`i' == 5
	replace emplH`i'_temp = 16 if emplH`i' == 6
	replace emplH`i'_temp = 17 if emplH`i' == 7
	replace emplH`i'_temp = 18 if emplH`i' == 8
	replace emplH`i'_temp = 19 if emplH`i' == 9
	gen emplW`i'_temp =.
	replace emplW`i'_temp = 11 if emplW`i' == 2 	/* priority category */
	replace emplW`i'_temp = 12 if emplW`i' == 1
	replace emplW`i'_temp = 13 if emplW`i' == 3
	replace emplW`i'_temp = 14 if emplW`i' == 4
	replace emplW`i'_temp = 15 if emplW`i' == 5
	replace emplW`i'_temp = 16 if emplW`i' == 6
	replace emplW`i'_temp = 17 if emplW`i' == 7
	replace emplW`i'_temp = 18 if emplW`i' == 8
	replace emplW`i'_temp = 19 if emplW`i' == 9
}
gen emplH_temp = min(emplH1_temp, emplH2_temp, emplH3_temp)
gen emplW_temp = min(emplW1_temp, emplW2_temp, emplW3_temp)

gen emplH = .
replace emplH = 2 if emplH_temp == 11
replace emplH = 1 if emplH_temp == 12
replace emplH = 3 if emplH_temp == 13
replace emplH = 4 if emplH_temp == 14
replace emplH = 5 if emplH_temp == 15
replace emplH = 6 if emplH_temp == 16
replace emplH = 7 if emplH_temp == 17
replace emplH = 8 if emplH_temp == 18
replace emplH = 9 if emplH_temp == 19

gen emplW = .
replace emplW = 2 if emplW_temp == 11
replace emplW = 1 if emplW_temp == 12
replace emplW = 3 if emplW_temp == 13
replace emplW = 4 if emplW_temp == 14
replace emplW = 5 if emplW_temp == 15
replace emplW = 6 if emplW_temp == 16
replace emplW = 7 if emplW_temp == 17
replace emplW = 8 if emplW_temp == 18
replace emplW = 9 if emplW_temp == 19

drop emplH*_temp emplW*_temp emplH1-emplH3 emplW1-emplW3
label variable emplH "HARMNZD EMPLOYMENT ST HD"
label variable emplW "HARMNZD EMPLOYMENT ST WF"


/*******************************************************************************
Clean dataset of unusable race, education, state, sex of head, employment status
*******************************************************************************/

*	Unusable (harmonized) race & verify race is either 1/2/3:
drop if rcH == 9 | rcH == .
drop if rcW == 9 | rcW == .
qui sum rcH
if r(min) < 1 | r(max) > 3 {
	error(1)
}
qui sum rcW
if r(min) < 1 | r(max) > 3 {
	error(1)
}
*	Missing (harmonized) education & verify education is between 1-17:
drop if edH == .
drop if edW == . 
qui sum edH
if r(min) < 1 | r(max) > 17 {
	error(1)
}
qui sum edW
if r(min) < 1 | r(max) > 17 {
	error(1)
}
*	Unusable state of residence & verify state is between 1-51::
drop if state == 0 | state == 99
qui sum state
if r(min) < 1 | r(max) > 51 {
	error(1)
}
*	Drop female head of married couple (this will be redundant):
drop if sexH == 2
qui sum sexH
if r(mean) != 1 {
	error(1)
}
*	Missing (harmonized) employment status & verify employment is between 1-8:
drop if emplH == . | emplW == .
qui sum emplH
if r(min) != 1 & r(max) != 8 {
	error(1)
}
qui sum emplW 
if r(min) != 1 & r(max) != 8 {
	error(1)
}


/*******************************************************************************
Reinstate households with intermittent headships
*******************************************************************************/

*	I treat households that experience intermittent presence in the panel, 
*	possibly due to compositional changes, as different households and, thus,
*	I change their panel identifier 'hh_id'. Once 'hh_id' is changed, I drop
* 	the temporary identifier 'temp_hh_id'.
sort hh_id year	
by hh_id : gen dyear = year - year[_n-1]
gen break_d = (dyear > 2 & dyear != .) 	/* dyear == . is in first year only */ 
by hh_id : egen miny = min(year)
by hh_id : replace hh_id = hh_id[_n-1] + break_d*.1 if year != miny
recast double hh_id
drop dyear break_d miny temp_hh_id
sort hh_id year

*	Save dataset:
compress
save $outputdir/starting_sample.dta, replace

***** End of do file *****
