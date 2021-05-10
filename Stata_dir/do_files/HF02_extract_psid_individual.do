
/*******************************************************************************
	
Extracts PSID individual data across years and merges with family files
________________________________________________________________________________

Filename: 	HF02_extract_psid_individual.do
Author: 	Alexandros Theloudis (a.theloudis@gmail.com)
			LISER Luxembourg
			Tilburg University, Department of Econometrics & Operations Research
Date: 		Spring 2021

This file: 
(1)		Extracts the PSID individual data across years, labels different types
		of sample membership, generates a unique person identifier.
(2)		Merges individual data with family (interview) data and verifies that
		the merging is successful.
(3)		Drops low-income sample, immigrant sample, and Latino sample.

*******************************************************************************/

*	Initial statements:
clear all
set more off
cap log close


/*******************************************************************************
Individual File - Years 1997-2011 biennially
*******************************************************************************/

cd $PSIDdir
use i1968_2013.dta, clear

*	Keep annual interview number (in order to merge with interview files), 
*	relationship to head (I require HH heads to create panel), 
*	and sequence number (I require the true heads per year):
#delimit;
/*		1997	1999	2001	2003	2005	2007	2009	2011		*/
keep 	ER33401 ER33501 ER33601 ER33701 ER33801 ER33901 ER34001 ER34101		/* interview number  */
		ER33402 ER33502 ER33602 ER33702 ER33802 ER33902 ER34002 ER34102		/* sequence number 	 */
		ER33403 ER33503 ER33603 ER33703 ER33803 ER33903 ER34003	ER34103		/* relationship head */		
		ER32000 	/* sex of individual*/
		ER30001;	/* 1968 interview 	*/
#delimit cr     

*	Name variables consistently across years:
ren ER30001 fam68
ren ER32000 sex

ren ER33401 intv_id1997
ren ER33501 intv_id1999
ren ER33601 intv_id2001
ren ER33701 intv_id2003
ren ER33801 intv_id2005
ren ER33901 intv_id2007
ren ER34001	intv_id2009
ren ER34101 intv_id2011

ren ER33402 seq1997
ren ER33502 seq1999
ren ER33602 seq2001
ren ER33702 seq2003
ren ER33802 seq2005
ren ER33902 seq2007
ren ER34002 seq2009
ren ER34102 seq2011

ren ER33403 rel1997
ren ER33503 rel1999
ren ER33603 rel2001
ren ER33703 rel2003
ren ER33803 rel2005
ren ER33903 rel2007
ren ER34003 rel2009
ren ER34103 rel2011

*	Label different samples within PSID. I will only use the core sample:
gen sample = 1											/* core src family 		*/
replace sample = 2 if fam68 >= 5001 & fam68 <= 6872		/* low income seo family*/
replace sample = 3 if fam68 >= 3001 & fam68 <= 3511		/* immigrant family		*/
replace sample = 4 if fam68 >= 7001						/* Latino family		*/ 
label define samplel 1 "core" 2 "low_income" 3 "immigrants" 4 "Latino"
label values sample samplel 

*	Generate unique id for each person in the dataset & convert to long.
* 	'person_id' uniquely describes an individual in the dataset:
gen person_id = 1
replace person_id = sum(person_id)
reshape long intv_id seq rel, i(person_id fam68 sample sex) j(year)
sort person_id year
order intv_id year person_id
drop if intv_id == 0	/* I drop person-years that have intv_id == 0 (no interview) */

*	Drop all those who aren't HH heads in any given year: 
gen head = 1 if rel == 10 & seq >= 1 & seq <= 20
drop if head != 1
sort person_id year	
drop sex seq rel head

*	Verify that there aren't any duplicate 'intv_id's to avoid problems when
*	merging with the family (interview) files:
forvalues i = 1997 1999 to 2011 {						
duplicates tag intv_id if year == `i', gen(dup_intv)
qui sum dup_intv if year == `i'
	if r(mean) != 0 {
		error(1)
	}					
drop dup_intv	
}
*

/*******************************************************************************
Merge Family (Interview) and Individual Files - Years 1997-2011 biennially
*******************************************************************************/

sort year intv_id
cd $STATAdir
merge 1:1 intv_id year using $outputdir/newf1997_2011.dta

*	Interrupt if merge was not perfect:
qui sum _merge
if r(mean) != 3 {
	error(1)
}
drop _merge

*	Drop low-income, immigrant, Latino samples:
keep if sample == 1
drop sample		

*	Order, label variables, sort:
rename person_id hh_id
order hh_id year fam68 intv_id newH newW ageH ageW newF numfu kids lH lW emplH* emplW*
label variable hh_id	"HH ID" 
label variable year		"YEAR"
label variable intv_id	"INTEVRIEW #"
sort hh_id year

*	Save panel dataset:
compress
save $outputdir/panel1997_2011.dta, replace

***** End of do file *****
