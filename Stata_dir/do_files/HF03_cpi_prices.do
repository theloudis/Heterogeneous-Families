
/*******************************************************************************
	
Extracts CPI & state minimum wages and merges with PSID panel
________________________________________________________________________________

Filename: 	HF03_cpi_prices.do
Author: 	Alexandros Theloudis (a.theloudis@gmail.com)
			LISER Luxembourg
			Tilburg University, Department of Econometrics & Operations Research
Date: 		Spring 2021

This file: 
(1)		Extracts the consumer price index, aligns it with the PSID (whose data 
		is retrospective), and merges it with the dataset.
(2)		Extracts minimum wage data by state and year (file provided here is 
		borrowed from Blundell, Pistaferri, Saporta-Eksten, 2016), and merges 
		it with the dataset.

*******************************************************************************/

*	Initial statements:
clear all
set more off
cap log close


/*******************************************************************************
CPI price data
*******************************************************************************/

cd $STATAdir
use inputs/CPIndex2010.dta, clear

*	Select years to extract CPI data from:
#delimit;
keep if year == 1996 | year == 1998 | year == 2000 | year == 2002 | 
		year == 2004 | year == 2006 | year == 2008 | year == 2010 ;
#delimit cr		
		
*	Shift year forward by 1 as PSID data are retrospective:
qui replace year = year + 1

*	Keep the annual measure of the All Urban Consumers CPI: 
keep year annual1
label variable annual1 "All Urban Consumers CPI All Items"

*	Merge with PSID panel dataset:
merge 1:m year using $outputdir/panel1997_2011.dta
qui sum _merge
if r(mean) != 3 {
	error(1)
}
drop _merge

*	Save temporary dataset:
sort hh_id year
compress
save $outputdir/panel1997_2011_prices_temp.dta, replace


/*******************************************************************************
State minimum wage - data provided by Blundell, Pistaferri, Saporta (2016)
*******************************************************************************/

cd $STATAdir
use inputs/min_wage.dta, clear

*	Merge with numerical state data:
*	Both datasets 'min_wage' and 'psid_states' are from the public distribution 
*	files of Blundell, Pistaferri, Saporta-Eksten (2016, AER); Consumption 
*	Inequality and Family Labor Supply. The dataset does not provide data for
*	year 1996 (PSID year 1997) so I copy the minimum wage data of year 1998
*	to year 1996.
drop if state_st == "FEDERAL (FLSA)"
merge m:1 state_st using inputs/psid_states.dta
qui sum _merge
if r(mean) != 3 {
	error(1)
}
drop _merge

*	Adjust year so as to mimic 'year' in the main files:
replace year = year + 1901
drop if year == 2002 | year == 2004 | year == 2006 | year == 2008 | year == 2010

*	Copy 1999 minimum wage values to year 1997:
reshape wide min_wage, i(state*) j(year)
gen min_wage1997 = min_wage1999
reshape long min_wage, i(state*) j(year)
replace min_wage = round(min_wage, .01)

*	Merge with PSID panel dataset:
*	Observations from 'using' that are not matched is because they date prior
*	to 1997 or have 0/99 state.
merge 1:m state year using $outputdir/panel1997_2011_prices_temp.dta
qui tab state if _merge == 2 & year >= 1997
if r(r) != 2 {
	error(1)
}
qui sum state if _merge == 2 & year >= 1997
if r(min) != 0 | r(max) != 99 {
	error(1)
}
drop _merge

*	Order and sort:
order hh_id year fam68 intv_id newH newW ageH ageW newF numfu kids lH lW emplH* emplW* 
sort hh_id year
drop state_st
label variable state	"STATE OF RESIDENCE"
label variable min_wage	"STATE MINIMUM WAGE (1997 MIMICS 1999)"

*	Save dataset:
compress
save $outputdir/panel1997_2011_prices.dta, replace
erase $outputdir/panel1997_2011_prices_temp.dta

***** End of do file *****
