
/*******************************************************************************
	
Harmonizes consumption and assets variables
________________________________________________________________________________

Filename: 	HF05_consumption_assets.do
Author: 	Alexandros Theloudis (a.theloudis@gmail.com)
			LISER Luxembourg
			Tilburg University, Department of Econometrics & Operations Research
Date: 		Spring 2021

This file: 
(1)		Converts detailed household expenditure to annual equivalent amounts.
(2)		Adds up low level expenditures to generate a Hicksian consumption 
		aggregate as well as medium-level aggregates.
(3)		Performs checks on the asset variable 'wealth'.

*******************************************************************************/

*	Initial statements:
clear all
set more off
cap log close

*	Load data:
cd $STATAdir
use $outputdir/starting_sample.dta, clear


/*******************************************************************************
Food expenditure
*******************************************************************************/

*	For this and any following expenditure item, I do not use observations with 
*	censored values. On the contrary, I treat any missing consumption values 
*	as 0. Expenditure is reported on a daily, weekly, bi-weekly, monthly, 
*	quarterly, annual, or biennial basis; a different set of time options is 
*	given to the respondents depending on the consumption item under question 
*	each time. I convert all these expenses into annual equivalent amounts. In 
*	any case in which reported consumption is non-0 but I lack the time unit 
* 	of that expense, I drop that observation (with the exception of vehicle 
*	insurance and water & sewage costs).

*	Food at home for those with food stamps:
replace fhomefst = . if fhomefst == 99997 & year >= 1999									/* Censored			*/
replace fhomefst = 0 if (fhomefst == 99998 | fhomefst == 99999) & year >= 1999				/* Missing			*/
replace fhomefst = fhomefst * 52.18 if year >= 1999 & tufhomefst == 3						/* Period: week		*/
replace fhomefst = fhomefst * 26.09 if year >= 1999 & tufhomefst == 4						/* Period: 2 weeks	*/
replace fhomefst = fhomefst * 12    if year >= 1999 & tufhomefst == 5						/* Period: month	*/	
replace fhomefst = . if fhomefst != 0 & year >= 1999 & tufhomefst >= 7 & tufhomefst <= 9	/* Not good period	*/

*	Food at home for those without food stamps:
replace fhome = . if fhome == 99997 & year >= 1999											/* Censored			*/
replace fhome = 0 if (fhome == 99998 | fhome == 99999) & year >= 1999						/* Missing			*/
replace fhome = fhome * 52.18 if year >= 1999 & tufhome == 3								/* Period: week		*/
replace fhome = fhome * 26.09 if year >= 1999 & tufhome == 4								/* Period: 2 weeks	*/
replace fhome = fhome * 12    if year >= 1999 & tufhome == 5								/* Period: month	*/
replace fhome = . if fhome != 0 & year >= 1999 & tufhome >= 7 & tufhome <= 9				/* Not good period	*/

* 	Food delivered at home for those with food stamps:
replace fdelfst = . if fdelfst == 99997 & year >= 1999										/* Censored			*/
replace fdelfst = 0 if (fdelfst == 99998 | fdelfst == 99999) & year >= 1999					/* Missing			*/
replace fdelfst = fdelfst * 52.18 if year >= 1999 & tufdelfst == 3							/* Period: week		*/
replace fdelfst = fdelfst * 26.09 if year >= 1999 & tufdelfst == 4							/* Period: 2 weeks	*/
replace fdelfst = fdelfst * 12    if year >= 1999 & tufdelfst == 5							/* Period: month	*/
replace fdelfst = . if fdelfst != 0 & year >= 1999 & tufdelfst >= 7 & tufdelfst <= 9		/* Not good period	*/

* 	Food delivered at home for those without food stamps:
replace fdel = . if fdel == 99997 & year >= 1999											/* Censored			*/
replace fdel = 0 if (fdel == 99998 | fdel == 99999) & year >= 1999							/* Missing			*/
replace fdel = fdel * 52.18 if year >= 1999 & tufdel == 3									/* Period: week		*/
replace fdel = fdel * 26.09 if year >= 1999 & tufdel == 4									/* Period: 2 weeks	*/
replace fdel = fdel * 12    if year >= 1999 & tufdel == 5									/* Period: month	*/
replace fdel = . if fdel != 0 & year >= 1999 & tufdel >= 7 & tufdel <= 9					/* Not good period	*/

* 	Food away from home for those with food stamps:
replace foutfst = . if foutfst == 99997 & year >= 1999										/* Censored			*/
replace foutfst = 0 if (foutfst == 99998 | foutfst == 99999) & year >= 1999					/* Mising			*/
replace foutfst = foutfst * 365   if year >= 1999 & tufoutfst == 2							/* Period: day		*/
replace foutfst = foutfst * 52.18 if year >= 1999 & tufoutfst == 3							/* Period: week		*/
replace foutfst = foutfst * 26.09 if year >= 1999 & tufoutfst == 4							/* Period: 2 weeks	*/
replace foutfst = foutfst * 12    if year >= 1999 & tufoutfst == 5							/* Period: month	*/
replace foutfst = . if foutfst != 0 & year >= 1999 & tufoutfst >= 7 & tufoutfst <= 9		/* Not good period	*/

* 	Food away from home for those without food stamps:
replace fout = . if fout == 99997 & year >= 1999											/* Censored			*/
replace fout = 0 if (fout == 99998 | fout == 99999) & year >= 1999							/* Mising			*/
replace fout = fout * 365   if year >= 1999 & tufout == 2									/* Period: day		*/
replace fout = fout * 52.18 if year >= 1999 & tufout == 3									/* Period: week		*/
replace fout = fout * 26.09 if year >= 1999 & tufout == 4									/* Period: 2 weeks	*/
replace fout = fout * 12    if year >= 1999 & tufout == 5									/* Period: month	*/
replace fout = . if fout != 0 & year >= 1999 & tufout >= 7 & tufout <= 9					/* Not good period	*/


/*******************************************************************************
Car expenditure and transportation
*******************************************************************************/

* 	Repairs and maintenance:
replace vrepair = . if  vrepair == 99997 & year >= 1999										/* Censored			*/
replace vrepair = 0 if (vrepair == 99998 | vrepair == 99999) & year >= 1999					/* Mising			*/
replace vrepair = vrepair * 12 if year >= 1999												/* Period: month	*/

* 	Gasoline:
replace vgas = . if  vgas == 99997 & year >= 1999											/* Censored			*/
replace vgas = 0 if (vgas == 99998 | vgas == 99999) & year >= 1999							/* Mising			*/
replace vgas = vgas * 12 if year >= 1999													/* Period: month	*/

* 	Parking expenses:
replace vpark = . if  vpark == 99997 & year >= 1999											/* Censored			*/
replace vpark = 0 if (vpark == 99998 | vpark == 99999) & year >= 1999						/* Mising			*/
replace vpark = vpark * 12 if year >= 1999													/* Period: month	*/

*	Car insurance: 
*	Note that I change 'vinsur' to 0 if tuvinsur == 7 ('other') because a big 
*	fraction of the sample (~5%) reports 'other' and I do not want to drop it.
replace vinsur = . if  vinsur == 999997 & year >=1999										/* Censored			*/
replace vinsur = 0 if (vinsur == 999998 | vinsur == 999999) & year >= 1999					/* Mising			*/
replace vinsur = vinsur * 12 if year >= 1999 & tuvinsur == 5								/* Period: month	*/
replace vinsur = 0 if year >= 1999 & vinsur != . & tuvinsur == 7							/* Period: other	*/
replace vinsur = . if vinsur != 0 & year >= 1999 & tuvinsur >= 8 & tuvinsur <= 9			/* Not good period	*/

* 	Bus and train:
replace bustrain = . if  bustrain == 99997 & year >= 1999									/* Censored			*/
replace bustrain = 0 if (bustrain == 99998 | bustrain == 99999) & year >= 1999				/* Mising			*/
replace bustrain = bustrain * 12 if year >= 1999											/* Period: month	*/

* 	Taxicabs:
replace taxicabs = . if  taxicabs == 99997 & year >= 1999									/* Censored			*/
replace taxicabs = 0 if (taxicabs == 99998 | taxicabs == 99999) & year >= 1999				/* Mising			*/
replace taxicabs = taxicabs * 12 if year >= 1999											/* Period: month	*/

* 	Other transportation expenses:
replace othertrans = . if  othertrans == 99997 & year >= 1999								/* Censored			*/
replace othertrans = 0 if (othertrans == 99998 | othertrans == 99999) & year >= 1999		/* Mising			*/
replace othertrans = othertrans * 12 if year >= 1999										/* Period: month	*/


/*******************************************************************************
Education and child care
*******************************************************************************/

* 	School:
replace schoolexp = . if  schoolexp == 999997 & year >= 1999								/* Censored			*/
replace schoolexp = 0 if (schoolexp == 999998 | schoolexp == 999999) & year >= 1999			/* Mising			*/

* 	Other school expenses:
replace moreschool = . if  moreschool == 999997 & year >= 1999								/* Censored			*/
replace moreschool = 0 if (moreschool == 999998 | moreschool == 999999) & year >= 1999		/* Mising			*/

* 	Child care:
replace childcare = . if  childcare == 999997 & year >= 1999								/* Censored			*/
replace childcare = 0 if (childcare == 999998 | childcare == 999999) & year >= 1999			/* Mising			*/


/*******************************************************************************
Health related expenses
*******************************************************************************/

*	Health insurance and health premiums:
replace ownhealth = . if  ownhealth == 999997 & year >= 1999								/* Censored			*/
replace ownhealth = 0 if (ownhealth == 999998 | ownhealth == 999999) & year >= 1999			/* Missing			*/
replace ownhealth = ownhealth *(1/2) if year >= 1999										/* Period: 2 years	*/

*	Nursing homes and hospital bills:
replace nurse = . if  nurse == 999997 & year >= 1999										/* Censored			*/
replace nurse = 0 if (nurse == 999998 | nurse == 999999) & year >= 1999						/* Missing			*/
replace nurse = nurse *(1/2) if year >= 1999												/* Period: 2 years	*/

*	Doctor, surgery, dentist:
replace doctor = . if  doctor == 9999997 & year >= 1999 & year <= 2003						/* Censored			*/
replace doctor = . if  doctor == 999997  & year >= 2005										/* Censored			*/
replace doctor = 0 if (doctor == 9999998 | doctor == 9999999) & year >= 1999 & year <= 2003	/* Missing			*/
replace doctor = 0 if (doctor == 999998  | doctor == 999999)  & year >= 2005				/* Missing			*/
replace doctor = doctor *(1/2) if year >= 1999												/* Period: 2 years	*/

*	Prescriptions:
replace drugs = . if  drugs == 9999997 & year >= 1999 & year <= 2003						/* Censored			*/
replace drugs = . if  drugs == 999997  & year >= 2005										/* Censored			*/
replace drugs = 0 if (drugs == 9999998 | drugs == 9999999) & year >= 1999 & year <= 2003	/* Missing			*/
replace drugs = 0 if (drugs == 999998  | drugs == 999999)  & year >= 2005					/* Missing			*/
replace drugs = drugs *(1/2) if year >= 1999												/* Period: 2 years	*/


/*******************************************************************************
Household utilities
*******************************************************************************/

* 	Household power supply - gas, electricity, or combined:
*	I create a 'hpower' which adds up gas and electricity expenditure and also 
*	accounts for the fact that the two may not be reported separately after 2007.
replace hgas = . if  hgas == 9997 & year >= 1999											/* Censored			*/
replace hgas = 0 if (hgas == 9998 | hgas == 9999) & year >= 1999							/* Missing			*/
replace hgas = 0 if year >= 1999 & tuhgas == 0												/* No expenditure	*/
replace hgas = hgas * 52.18  if year >= 1999 & tuhgas == 3									/* Period: week		*/
replace hgas = hgas * 12     if year >= 1999 & tuhgas == 5									/* Period: month	*/
replace hgas = . if hgas != 0 & year >= 1999 & ((tuhgas >= 7 & tuhgas <= 9) | tuhgas == 1)	/* Not good period	*/ 	

replace elctr = . if  elctr == 9997 & year >= 1999											/* Censored			*/
replace elctr = 0 if (elctr == 9998 | elctr == 9999) & year >= 1999							/* Missing			*/
replace elctr = elctr * 12 if year >= 1999 & tuelctr == 5									/* Period: month	*/
replace elctr = . if elctr != 0 & year >= 1999 & tuelctr >= 7 & tuelctr <= 9 				/* Not good period	*/

replace gaselctr = . if  gaselctr == 9997 & year >= 2007									/* Censored			*/
replace gaselctr = 0 if (gaselctr == 9998 | gaselctr == 9999) & year >= 2007				/* Missing			*/
replace gaselctr = gaselctr * 12 if year >= 2007 & tugaselctr == 5							/* Period: month	*/
replace gaselctr = . if gaselctr != 0 & year >= 2007 & tugaselctr >= 7 & tugaselctr <= 9 	/* Not good period	*/

gen hpower = .
replace hpower = hgas + elctr if year >= 1999 & year <= 2005		
replace hpower = hgas + elctr if year >= 2007 & combined != 2
replace hpower = gaselctr     if year >= 2007 & combined == 2

* 	Water and sewage:
*	Note that I change 'water' to 0 if tuwater == 7 ('other') because a big 
*	fraction of the sample (~1.1%) reports 'other' and I do not want to drop it.
replace water = . if  water == 9997 & year >= 1999											/* Censored			*/
replace water = 0 if (water == 9998 | water == 9999) & year >= 1999							/* Missing			*/
replace water = 0 if year >= 1999 & tuwater == 0											/* No expenditure	*/
replace water = water * 4  if year >= 1999 & tuwater == 4 									/* Period: quarter	*/
replace water = water * 12 if year >= 1999 & tuwater == 5									/* Period: month	*/
replace water = 0 if year >= 1999 & water != . & tuwater == 7								/* Period: other	*/
replace water = . if water != 0 & year >= 1999 & tuwater >= 8 & tuwater <= 9				/* Not good period	*/ 

* 	Miscellaneous household utilities:
*	I create 'miscu' which is equal to 'otherutil' up until 2003 ('otherutil'
*	includes telecommunication expenses until then). Since 2005 it is
*	equal to 'otherutil' (excludes telecommunication) and 'telecom'.
replace otherutil = . if  otherutil == 997 & year >= 1999									/* Censored			*/
replace otherutil = 0 if (otherutil == 998 | otherutil == 999) & year >= 1999				/* Missing			*/
replace otherutil = otherutil * 12 if year >= 1999 & tuotherutil == 5						/* Period: month	*/
replace otherutil = . if otherutil != 0 & year >= 1999 & tuotherutil >= 7 & tuotherutil <= 9/* Not good period	*/ 

replace telecom = . if  telecom == 9997 & year >= 2005										/* Censored			*/
replace telecom = 0 if (telecom == 9998 | telecom == 9999) & year >= 2005					/* Missing			*/
replace telecom = telecom * 12 if year >= 2005 & tutelecom == 5								/* Period: month	*/
replace telecom = . if telecom != 0 & year >= 2005 & tutelecom >= 7 & tutelecom <= 9		/* Not good period	*/

gen miscu = .
replace miscu = otherutil if year >= 1999 & year < 2005
replace miscu = otherutil + telecom if year >= 2005


/*******************************************************************************
Housing costs & services
*******************************************************************************/

* 	Rent for renters:
replace rent = . if rent == 99997 & year >= 1999											/* Censored			*/
replace rent = 0 if (rent == 99998 | rent == 99999) & year >= 1999							/* Mising			*/
replace rent = 0 if year >= 1999 & turent == 0												/* No expenditure	*/
replace rent = rent * 365   if year >= 1999 & turent == 2									/* Period: day		*/
replace rent = rent * 52.18 if year >= 1999 & turent == 3									/* Period: week		*/
replace rent = rent * 26.09 if year >= 1999 & turent == 4									/* Period: 2 weeks	*/
replace rent = rent * 12    if year >= 1999 & turent == 5									/* Period: month	*/
replace rent = . if rent != 0 & year >= 1999 & turent >= 7 & turent <= 9					/* Not good period	*/

* 	Housing services for homeowners:
gen renteq = 0 if (pvownhome == 9999998 | pvownhome == 9999999) & year >= 1999				/* Missing			*/ 
replace renteq = .06 * pvownhome if year >= 1999 & renteq != 0								/* Impute value 6%	*/

*	Housing services for non-renters, non-owners:
replace rentif = . if  rentif == 9997 & year >= 1999										/* Censored			*/
replace rentif = 0 if (rentif == 9998 | rentif == 9999) & year >= 1999						/* Mising			*/
replace rentif = 0 if year >= 1999 & turentif == 0											/* No expenditure	*/
replace rentif = rentif * 52.18 if year >= 1999 & turentif == 3								/* Period: week		*/
replace rentif = rentif * 26.09 if year >= 1999 & turentif == 4								/* Period: 2 weeks	*/
replace rentif = rentif * 12    if year >= 1999 & turentif == 5								/* Period: month	*/
replace rentif = . if rentif != 0 & year >= 1999 & turentif >= 7 & turentif <= 9			/* Not good period	*/ 

* 	Home insurance for homeowners:
replace homeinsur = . if  homeinsur == 9997 & year >= 1999									/* Censored			*/
replace homeinsur = 0 if (homeinsur == 9998 | homeinsur == 9999) & year >= 1999				/* Mising			*/

*	Each observation must be either renter ('rent'), owner ('renteq'), or
*	resident in a public house ('renteq'):
replace renteq = 0 if rent > 0 & year >= 1999
replace rent = 0 if rentif > 0 & year >= 1999
qui sum rent if rentif > 0 & year >= 1999
if r(mean) != 0 {
	error(1)
}
qui sum rent if renteq > 0 & year >= 1999
if r(mean) != 0 {
	error(1)
}
qui sum rentif if renteq > 0 & year >= 1999
if r(mean) != 0 {
	error(1)
}
*
/*******************************************************************************
Aggregate consumption items
*******************************************************************************/

*	Top level consumption aggregates:
#delimit;
gen consumption = 	fhomefst + fdelfst + foutfst + fhome + fdel + fout +
					bustrain + taxicabs + othertrans + nurse + doctor + drugs +
					hpower + water + miscu + childcare + schoolexp + moreschool + 
					vinsur + vrepair + vgas + vpark + rent + renteq + rentif + 
					homeinsur + ownhealth ;
#delimit cr

*	Lower level consumption aggregates:
gen fin	    		=   fhome + fhomefst + fdel + fdelfst
gen finat   		=   fhome + fhomefst
gen findel  		=   fdel + fdelfst
gen foodout    		=   fout + foutfst
gen ptrans			=   bustrain + taxicabs + othertrans
gen allothertrans 	=   taxicabs + othertrans
gen medserv 		=   nurse + doctor
gen allrents		=   rent + rentif + renteq
gen utils			=   hpower + water + miscu
gen edu				= 	schoolexp + moreschool
gen vehs			=   vinsur + vrepair + vgas + vpark

*	Label consumption variables & aggregates:
label variable consumption	"Total HH Consumption"
label variable fin			"Food at Home"
label variable finat		"~~~prepared at home"
label variable findel		"~~~delivered at home"
label variable foodout		"Food Out"
label variable ptrans		"Public Transport"
label variable bustrain		"~~~buses and trains"
label variable allothertrans"~~~all other means"
label variable medserv		"Medical Services"
label variable nurse		"~~~nurses-hospitals"
label variable doctor		"~~~professionals"
label variable drugs		"Prescriptions"
label variable allrents		"Housing Services"
label variable rent			"~~~renters"
label variable renteq		"~~~owners"
label variable homeinsur	"Home Insurance"
label variable ownhealth	"Health Insurance"
label variable utils		"Utilities"
label variable hpower		"~~~heating-electricity"
label variable water		"~~~water and sewer"
label variable miscu 		"~~~miscellaneous utilities"
label variable edu			"Children's Education"
label variable childcare	"Child Care"
label variable vehs			"Vehicles' costs"
label variable vinsur		"~~~insurance"
label variable vrepair		"~~~repairs"
label variable vgas			"~~~motor fuel"
label variable vpark		"~~~parking fees"

*	Drop time units & unnecessary consumption items:
#delimit;
drop 	turent turentif tufhome* tufdel* tufout* hrepair *hrepair   
		tuhgas tuelctr tugaselctr tuwater tutelecom tuotherutil 
		tuvinsur *clothes *holiday *entertain *furnish ;
#delimit cr


/*******************************************************************************
Assets
*******************************************************************************/

*	I use 'wealth' (imputed variable provided by PSID after 1999) as the 
*	benchmark variable for the net asset position of the household. 'Wealth' is 
*	the sum of seven asset categories: 
*		-real estate other than main home
*		-savings
*		-IRA or annuities
*		-vehicles
*		-farms or businesses
*		-investment in stocks and shares
*		-other assets,
*	plus home equity (present value of home net of any outstanding mortgage 
*	payments), net of any debts such as: 
*		-credit card debts
*		-loans from relatives
*		-student loans
*		-medical or legal bills, 
*	but not loans to buy vehicles.
replace wealth = . if wealth > 999999996 	/* 	censored above 999999996 */

*	Save dataset:
sort hh_id year
compress
save $outputdir/consumption_assets.dta, replace

***** End of do file *****
