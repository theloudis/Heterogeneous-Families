
/*******************************************************************************
	
Extracts the PSID family (interview) data by year
________________________________________________________________________________

Filename: 	HF01_extract_psid_interview.do
Author: 	Alexandros Theloudis (a.theloudis@gmail.com)
			LISER Luxembourg
			Tilburg University, Department of Econometrics & Operations Research
Date: 		Spring 2021

This file: 
(1)		Extracts the PSID variables of interest from the yearly family 
		(interview) files. Years extracted: 1997-2011 biennially.
(2)		Appends the yearly files and creates a long cross-year family file.

*******************************************************************************/

*	Initial statements:
clear all
set maxvar 6000
set more off
cap log close


/*******************************************************************************
Family (Interview) File - Year 1997
*******************************************************************************/

cd $PSIDdir
use f1997.dta, clear

*	Keep the following variables:
#delimit;
keep 	ER10002 ER12221 ER10008 ER10012 ER10013 ER11812 ER11731 ER10009 ER10010 
		ER11848 ER10016 ER12222 ER11724 ER10011 ER11760 ER12223 ER11728 ER10081 
		ER10082 ER10083 ER10086 ER10089 ER10090 ER12174 ER10563 ER10564 ER10565 
		ER10568 ER10571 ER10572 ER12185 ER11084 ER12065 ER11088 ER12193 ER12194 
		ER12080 ER11213 ER11214 ER11228 ER11229 ER11243 ER11244 ER11258 ER11259 
		ER11273 ER11274 ER11289 ER11290 ER11304 ER11305 ER11322 ER11323 ER11337 
		ER11338 ER11352 ER11353 ER11367 ER11368 ER11383 ER11384 ER11398 ER11399 
		ER11413 ER11414 ER11428 ER11429 ER11443 ER11444 ER11458 ER11459 ER11473 
		ER11474 ER12214 ER12215 ER12082 ER11524 ER11525 ER11539 ER11540 ER11554 
		ER11555 ER11600 ER11601 ER11585 ER11586 ER11630 ER11631 ER11645 ER11646 
		ER11494 ER11495 ER11509 ER11510 ER11615 ER11616 ER11660 ER11661 ER11675 
		ER11676 ER11690 ER11691 ER12069 ER12071 ER12073 ER12075 ER11705 ER11708 
		ER11715 ER12079 ER11049 ER11050 ER11051 ER11065 ER11068 ER11069 ER11071 
		ER11072 ER11073 ER11074 ER11076 ER11077 ER11079 ER11080 ER11081 ER11082 
		ER11048 ER10035 ER10064 ER10036 ER10037 ER10038 ER10046 ER10054 ER10058 
		ER10059 ER10047 ER10055 ER10060 ER10061	ER10066 ER10067 ER12223A ER10004A 
		ER11849 ER11850 ER11851 ER11761 ER11762 ER11763 ER11046 ER11045 ;
#delimit cr

*	Rename or initialise variables:
*	Demographics:
ren ER10002	id					
ren ER12221 state		
ren ER10008 numfu		
ren ER10012 kids		
ren ER10013 ageK		
ren ER11812 newH		
ren ER11731 newW		
ren	ER10004A newF
ren ER10009 ageH		
ren ER10010 sexH		
ren ER11848 raceH1
ren ER11849 raceH2
ren ER11850 raceH3
ren ER11851 raceH4			
ren ER10016 mstatusH
ren ER12223A maritalH	
ren ER12222 educH		
ren ER10011 ageW		
ren ER11760 raceW1
ren ER11761 raceW2
ren ER11762 raceW3
ren ER11763 raceW4	
ren ER12223 educW
*	Employment and hours:
ren ER11724 limitedH	
ren ER11728 limitedW	
ren ER10081 emplH1
ren ER10082 emplH2
ren ER10083 emplH3
gen	self1H	= .	
gen	self2H	= .
gen	self3H	= .	
gen	self4H	= .	
ren ER10086 selfH		
ren ER10089 unioncH		
ren ER10090 unionizedH	
ren ER12174 hoursH		
ren ER10563 emplW1
ren ER10564 emplW2
ren ER10565 emplW3	
gen	self1W 	= .	
gen	self2W	= .	
gen	self3W	= .	
gen	self4W	= .	
ren ER10568 selfW		
ren ER10571 unioncW		
ren ER10572 unionizedW	
ren ER12185 hoursW
*	Income, tranfers, and earnings:	
ren ER11084 farmerH		
ren ER12065 fincHW		
ren ER11088 business	
ren ER12193 blincH		
ren ER12194 baincH		
ren ER12080 lH			
ren ER11213 rincH		
ren ER11214 turincH		
ren ER11228 divH		
ren ER11229 tudivH		
ren ER11243 intH		
ren ER11244 tuintH		
ren ER11258 trincH		
ren ER11259 tutrincH	
ren ER11273 tanfH		
ren ER11274 tutanfH		
ren ER11289 ssiH		
ren ER11290 tussiH		
ren ER11304 otherwH		
ren ER11305 tuotherwH	
ren ER11322 vapH		
ren ER11323 tuvapH		
ren ER11337 pensH		
ren ER11338 tupensH		
ren ER11352 annuH		
ren ER11353 tuannuH		
ren ER11367 otherrH		
ren ER11368 tuotherrH	
ren ER11383 uncompH		
ren ER11384 tuuncompH	
ren ER11398 wcompH		
ren ER11399 tuwcompH	
ren ER11413 csH			
ren ER11414 tucsH		
ren ER11428 alimH		
ren ER11429 tualimH		
ren ER11443 helpfH		
ren ER11444 tuhelpfH	
ren ER11458 helpoH		
ren ER11459 tuhelpoH	
ren ER11473 miscH		
ren ER11474 tumiscH		
ren ER12214 blincW		
ren ER12215 baincW		
ren ER12082 lW					
gen	rincW		= .	
gen	turincW		= .
ren ER11524 divW		
ren ER11525 tudivW		
ren ER11539 intW		
ren ER11540 tuintW		
ren ER11554 trincW		
ren ER11555 tutrincW	
ren ER11600 tanfW		
ren ER11601 tutanfW		
ren ER11585 ssiW		
ren ER11586 tussiW		
ren ER11630 otherwW		
ren ER11631 tuotherwW	
ren ER11645 pensannuW	
ren ER11646 tupensannuW	
ren ER11494 uncompW		
ren ER11495 tuuncompW	
ren ER11509 wcompW		
ren ER11510 tuwcompW	
ren ER11615 csW			
ren ER11616 tucsW		
ren ER11660 helpfW		
ren ER11661 tuhelpfW	
ren ER11675 helpoW		
ren ER11676 tuhelpoW	
ren ER11690 miscW		
ren ER11691 tumiscW		
ren ER12069 taxincHW	
ren ER12071 tranincHW	
ren ER12073 taxincR		
ren ER12075 tranincR	
ren ER11705 lumpF		
ren ER11708 supportF	
ren ER11715 vsupportF	
ren ER12079 incF
*	Food related and food stamps:	
ren ER11049 fstmpPY		
ren ER11050 vfstmpPY	
ren ER11051 tufstmpPY	
gen	fstmpCY		= .
gen	vstmpCY		= .
gen	tufstmpCY	= .
ren ER11065 numfstmp	
ren ER11068 fhomefst	
ren ER11069 tufhomefst	
ren ER11071 fdelfst		
ren ER11072 tufdelfst	
ren ER11073 foutfst		
ren ER11074 tufoutfst	
ren ER11076 fhome		
ren ER11077 tufhome		
ren ER11079 fdel		
ren ER11080 tufdel		
ren ER11081 fout		
ren ER11082 tufout
*	Household & personal expenses:		
gen	hrepair		= .
gen	tuhrepair	= .
gen	furnish		= .
gen	tufurnish	= .
gen	clothes		= .
gen	tuclothes	= .
gen	holiday		= .
gen	tuholiday	= .
gen	entertain	= .
gen	tuentertain	= .
ren ER10035 hstatus		
ren ER10064 pubhome		
ren ER10036 pvownhome	
ren ER10037 hometax		
ren ER10038 homeinsur	
ren ER10046 mortg1		
ren ER10054 yrsmortg1	
ren ER10058 incltax1	
ren ER10059 inclinsur1	
ren ER10047 mortg2		
ren ER10055 yrsmortg2	
ren ER10060 rent		
ren ER10061 turent
ren ER10066	rentif
ren ER10067	turentif		
gen	combined	= .
gen	hgas		= .
gen	tuhgas		= .
gen	elctr		= .
gen	tuelctr		= .
gen	gaselctr	= .	
gen	tugaselctr	= .
gen	water		= .
gen	tuwater		= .
gen	telecom		= .
gen	tutelecom	= .
gen	otherutil	= .
gen	tuotherutil	= .
gen	ownhealth	= .
gen	nurse		= .
gen	doctor		= .
gen	drugs		= .
gen	totalhealth	= .
*	Car & transport expenses:
gen	vehicle		= .
gen	numvehicle	= .
gen	vinsur		= .
gen	tuvinsur	= .
gen	otherveh	= .
gen	vrepair		= .
gen	vgas		= .
gen	vpark		= .
gen	bustrain	= .
gen	taxicabs	= .
gen	othertrans	= .
*	Schooling & child care:
gen	schoolexp	= .
gen	moreschool	= .
ren ER11048 childcare
*	Assets:
gen	estates		= .
gen	wheels		= .
gen	farm_bus	= .
gen	investm		= .
gen	ira_annu	= .
gen	savings		= .
gen	otherasset	= .
gen	debts		= .
gen wealth 		= .
gen homeequit 	= .
ren ER11046		hpH
ren ER11045		hpW

gen year = 1997
label drop _all
compress
save $outputdir/newf1997.dta, replace 


/*******************************************************************************
Family (Interview) File - Year 1999
*******************************************************************************/

cd $PSIDdir
use f1999.dta, clear

*	Keep the following variables:	
#delimit;
keep 	ER13002 ER13004 ER13009 ER13013 ER13014 ER15890 ER15805 ER13010 ER13011 
		ER15928 ER13021 ER16516 ER15449 ER13012 ER15836 ER16517 ER15557 ER13205 
		ER13206 ER13207 ER13210 ER13213 ER13214 ER16471 ER13717 ER13718 ER13719 
		ER13722 ER13725 ER13726 ER16482 ER14345 ER16448 ER14349 ER16490 ER16491 
		ER16463 ER14479 ER14480 ER14494 ER14495 ER14509 ER14510 ER14524 ER14525 
		ER14539 ER14540 ER14555 ER14556 ER14570 ER14571 ER14588 ER14589 ER14603 
		ER14604 ER14618 ER14619 ER14633 ER14634 ER14649 ER14650 ER14664 ER14665 
		ER14679 ER14680 ER14694 ER14695 ER14709 ER14710 ER14724 ER14725 ER14739 
		ER14740 ER16511 ER16512 ER16465 ER14790 ER14791 ER14805 ER14806 ER14820 
		ER14821 ER14866 ER14867 ER14851 ER14852 ER14896 ER14897 ER14911 ER14912 
		ER14760 ER14761 ER14775 ER14776 ER14881 ER14882 ER14926 ER14927 ER14941 
		ER14942 ER14956 ER14957 ER16452 ER16454 ER16456 ER16458 ER14971 ER14976 
		ER14983 ER16462 ER14255 ER14256 ER14257 ER14270 ER14285 ER14286 ER14284 
		ER14288 ER14289 ER14291 ER14292 ER14293 ER14294 ER14295 ER14296 ER14298 
		ER14299 ER14300 ER14301 ER13099 ER13100 ER13191 ER13192 ER13194 ER13195 
		ER13196 ER13197 ER13198 ER13199 ER13200 ER13202 ER13204 ER14232 ER13040 
		ER13069 ER13041 ER13042 ER13043 ER13048 ER13052 ER13063 ER13064 ER13057 
		ER13061 ER13065 ER13066 ER13088 ER13089 ER13086 ER13087 ER13090 ER13091 
		ER13097 ER13098 ER15780 ER15781 ER15787 ER15793 ER15799 ER13071 ER13072 
		S409 	S413 	S403 	S411 	S419 	S405 	S415 	S407 	S417 	
		S420 	ER16423 ER13008A ER15929 ER15930 ER15931 ER15837 ER15838 ER15839 
		ER14230 ER14229 ;
#delimit cr

*	Rename or initialise variables:
*	Demographics:
ren ER13002	id					
ren ER13004 state		
ren ER13009 numfu		
ren ER13013 kids		
ren ER13014 ageK		
ren ER15890 newH		
ren ER15805 newW		
ren	ER13008A newF
ren ER13010 ageH		
ren ER13011 sexH		
ren ER15928 raceH1
ren ER15929 raceH2
ren ER15930 raceH3
ren ER15931 raceH4		
ren ER13021 mstatusH
ren ER16423 maritalH	
ren ER16516 educH	
ren ER13012 ageW		
ren ER15836 raceW1
ren ER15837 raceW2
ren ER15838 raceW3
ren ER15839 raceW4		
ren ER16517 educW
*	Employment and hours:	
ren ER15449 limitedH	
ren ER15557 limitedW		
ren ER13205 emplH1
ren ER13206 emplH2
ren ER13207 emplH3
gen	self1H	= .	
gen	self2H	= .
gen	self3H	= .	
gen	self4H	= .	
ren ER13210 selfH		
ren ER13213 unioncH		
ren ER13214 unionizedH	
ren ER16471 hoursH		
ren ER13717 emplW1
ren ER13718 emplW2
ren ER13719 emplW3	
gen	self1W	= . 		
gen self2W	= .		
gen self3W	= .		
gen self4W	= .	
ren ER13722 selfW		
ren ER13725 unioncW		
ren ER13726 unionizedW	
ren ER16482 hoursW
*	Income, tranfers, and earnings:	
ren ER14345 farmerH		
ren ER16448 fincHW		
ren ER14349 business	
ren ER16490 blincH		
ren ER16491 baincH		
ren ER16463 lH			
ren ER14479 rincH		
ren ER14480 turincH		
ren ER14494 divH		
ren ER14495 tudivH		
ren ER14509 intH		
ren ER14510 tuintH		
ren ER14524 trincH		
ren ER14525 tutrincH	
ren ER14539 tanfH		
ren ER14540 tutanfH		
ren ER14555 ssiH		
ren ER14556 tussiH		
ren ER14570 otherwH		
ren ER14571 tuotherwH	
ren ER14588 vapH		
ren ER14589 tuvapH		
ren ER14603 pensH		
ren ER14604 tupensH		
ren ER14618 annuH		
ren ER14619 tuannuH		
ren ER14633 otherrH		
ren ER14634 tuotherrH	
ren ER14649 uncompH		
ren ER14650 tuuncompH	
ren ER14664 wcompH		
ren ER14665 tuwcompH	
ren ER14679 csH			
ren ER14680 tucsH		
ren ER14694 alimH		
ren ER14695 tualimH		
ren ER14709 helpfH		
ren ER14710 tuhelpfH	
ren ER14724 helpoH		
ren ER14725 tuhelpoH	
ren ER14739 miscH		
ren ER14740 tumiscH		
ren ER16511 blincW		
ren ER16512 baincW		
ren ER16465 lW			
gen	rincW	= .	
gen turincW	= .		
ren ER14790 divW		
ren ER14791 tudivW		
ren ER14805 intW		
ren ER14806 tuintW			
ren ER14820 trincW		
ren ER14821 tutrincW	
ren ER14866 tanfW		
ren ER14867 tutanfW		
ren ER14851 ssiW		
ren ER14852 tussiW		
ren ER14896 otherwW		
ren ER14897 tuotherwW	
ren ER14911 pensannuW	
ren ER14912 tupensannuW	
ren ER14760 uncompW		
ren ER14761 tuuncompW	
ren ER14775 wcompW		
ren ER14776 tuwcompW	
ren ER14881 csW			
ren ER14882 tucsW		
ren ER14926 helpfW		
ren ER14927 tuhelpfW	
ren ER14941 helpoW		
ren ER14942 tuhelpoW	
ren ER14956 miscW		
ren ER14957 tumiscW		
ren ER16452 taxincHW	
ren ER16454 tranincHW	
ren ER16456 taxincR		
ren ER16458 tranincR	
ren ER14971 lumpF	
ren ER14976 supportF	
ren ER14983 vsupportF	
ren ER16462 incF
*	Food related and food stamps:		
ren ER14255 fstmpPY		
ren ER14256 vfstmpPY	
ren ER14257 tufstmpPY	
ren ER14270 fstmpCY		
ren ER14285 vstmpCY		
ren ER14286 tufstmpCY	
ren ER14284 numfstmp	
ren ER14288 fhomefst	
ren ER14289 tufhomefst	
ren ER14291 fdelfst		
ren ER14292 tufdelfst	
ren ER14293 foutfst		
ren ER14294 tufoutfst	
ren ER14295 fhome		
ren ER14296 tufhome		
ren ER14298 fdel		
ren ER14299 tufdel
ren ER14300 fout		
ren ER14301 tufout
*	Household & personal expenses:		
gen	hrepair		= .	
gen	tuhrepair	= .
gen	furnish		= .
gen	tufurnish	= .
gen	clothes		= .
gen	tuclothes	= .
gen	holiday		= .
gen	tuholiday	= .
gen	entertain	= .
gen	tuentertain	= .
ren ER13040 hstatus		
ren ER13069 pubhome		
ren ER13041 pvownhome	
ren ER13042 hometax		
ren ER13043 homeinsur	
ren ER13048 mortg1		
ren ER13052 yrsmortg1	
ren ER13063 incltax1	
ren ER13064 inclinsur1	
ren ER13057 mortg2		
ren ER13061 yrsmortg2	
ren ER13065 rent		
ren ER13066 turent
ren ER13071 rentif
ren ER13072	turentif
gen	combined	= .
ren ER13088 hgas		
ren ER13089 tuhgas		
ren ER13086 elctr		
ren ER13087 tuelctr		
gen	gaselctr	= .	
gen	tugaselctr	= .
ren ER13090 water		
ren ER13091 tuwater		
gen	telecom		= .
gen	tutelecom	= .
ren ER13097 otherutil	
ren ER13098 tuotherutil	
ren ER15780 ownhealth	
ren ER15781 nurse		
ren ER15787 doctor		
ren ER15793 drugs		
ren ER15799 totalhealth	
*	Car & transport expenses:
ren ER13099 vehicle		
ren ER13100 numvehicle	
ren ER13191 vinsur		
ren ER13192 tuvinsur	
ren ER13194 otherveh	
ren ER13195 vrepair		
ren ER13196 vgas		
ren ER13197 vpark		
ren ER13198 bustrain	
ren ER13199 taxicabs	
ren ER13200 othertrans
*	Schooling & child care:	
ren ER13202 schoolexp	
ren ER13204 moreschool	
ren ER14232 childcare
*	Assets:	
ren S409 	estates		
ren S413 	wheels		
ren S403 	farm_bus	
ren S411 	investm		
ren S419 	ira_annu	
ren S405 	savings		
ren S415 	otherasset	
ren S407 	debts		
ren S417 	wealth
ren S420 	homeequit
ren ER14230	hpH 
ren ER14229	hpW

gen year = 1999
label drop _all
compress
save $outputdir/newf1999.dta, replace 


/*******************************************************************************
Family (Interview) File - Year 2001
*******************************************************************************/

cd $PSIDdir
use f2001.dta, clear

*	Keep the following variables:	
#delimit;
keep 	ER17002	ER17004 ER17012 ER17016 ER17017 ER19951 ER19866 ER17007 ER17013 
		ER17014 ER19989 ER17024 ER20457 ER19614 ER17015 ER19897 ER20458 ER19722 
		ER17216 ER17217 ER17218 ER17221	ER17224 ER17225 ER20399 ER17786 ER17787 
		ER17788 ER17791	ER17794 ER17795 ER20410 ER18484 ER20420 ER18489 ER20422 
		ER20423 ER20443 ER18634 ER18635 ER18650 ER18651 ER18666 ER18667 ER18682 
		ER18683 ER18698 ER18699 ER18715 ER18716 ER18731 ER18732 ER18750 ER18751 
		ER18766 ER18767 ER18782 ER18783 ER18798 ER18799 ER18815 ER18816 ER18831 
		ER18832 ER18847 ER18848 ER18863 ER18864 ER18879 ER18880 ER18895 ER18896 
		ER18911 ER18912 ER20444 ER20445 ER20447 ER18966 ER18967 ER18982 ER18983 
		ER18998 ER18999 ER19047 ER19048 ER19031 ER19032 ER19079 ER19080 ER19095 
		ER19096 ER18934 ER18935 ER18950 ER18951 ER19063 ER19064 ER19111 ER19112 
		ER19127 ER19128 ER19143 ER19144 ER20449 ER20450 ER20453 ER20454 ER19159 
		ER19172 ER19179 ER20456 ER18386 ER18387 ER18388 ER18402 ER18417 ER18418 
		ER18416 ER18421 ER18422 ER18425 ER18426 ER18428 ER18429 ER18431 ER18432 
		ER18435 ER18436 ER18438 ER18439 ER17110 ER17111 ER17202 ER17203 ER17205 
		ER17206 ER17207 ER17208 ER17209 ER17210 ER17211 ER17213 ER17215 ER18362 
		ER17043 ER17079 ER17044 ER17046 ER17048 ER17054 ER17059 ER17072 ER17073 
		ER17065 ER17070 ER17074 ER17075 ER17099 ER17100 ER17097 ER17098 ER17101 
		ER17102 ER17108 ER17109 ER19841 ER19842 ER19848 ER19854 ER19860 ER17081 
		ER17082 S509 	S513 	S503 	S511 	S519 	S505 	S515 	S507 	
		S517 	S520 	ER20369 ER19990 ER19991 ER19992 ER19898 ER19899 ER19900 
		ER18359 ER18357 ;
#delimit cr

*	Rename or initialise variables:
*	Demographics:
ren ER17002	id					
ren ER17004 state		
ren ER17012 numfu		
ren ER17016 kids		
ren ER17017 ageK		
ren ER19951 newH		
ren ER19866 newW		
ren ER17007 newF		
ren ER17013 ageH		
ren ER17014 sexH		
ren ER19989 raceH1
ren ER19990 raceH2
ren ER19991 raceH3
ren ER19992 raceH4			
ren ER17024 mstatusH
ren ER20369 maritalH	
ren ER20457 educH			
ren ER17015 ageW		
ren ER19897 raceW1
ren ER19898 raceW2
ren ER19899 raceW3
ren ER19900 raceW4				
ren ER20458 educW
*	Employment and hours:
ren ER19614 limitedH		
ren ER19722 limitedW			
ren ER17216 emplH1
ren ER17217 emplH2
ren ER17218 emplH3
gen	self1H	= .	
gen	self2H	= .	
gen	self3H	= .	
gen	self4H	= .	
ren ER17221	selfH		
ren ER17224 unioncH		
ren ER17225 unionizedH	
ren ER20399 hoursH		
ren ER17786 emplW1
ren ER17787 emplW2
ren ER17788 emplW3	
gen	self1W 	= .	
gen	self2W	= .	
gen	self3W	= .	
gen	self4W	= .	
ren ER17791	selfW		
ren ER17794 unioncW		
ren ER17795 unionizedW	
ren ER20410 hoursW
*	Income, tranfers, and earnings:	
ren ER18484 farmerH		
ren ER20420 fincHW		
ren ER18489 business	
ren ER20422 blincH		
ren ER20423 baincH		
ren ER20443 lH		
ren ER18634 rincH		
ren ER18635 turincH		
ren ER18650 divH		
ren ER18651 tudivH		
ren ER18666 intH		
ren ER18667 tuintH		
ren ER18682 trincH		
ren ER18683 tutrincH	
ren ER18698 tanfH		
ren ER18699 tutanfH		
ren ER18715 ssiH		
ren ER18716 tussiH		
ren ER18731 otherwH		
ren ER18732 tuotherwH	
ren ER18750 vapH		
ren ER18751 tuvapH		
ren ER18766 pensH		
ren ER18767 tupensH		
ren ER18782 annuH		
ren ER18783 tuannuH		
ren ER18798 otherrH		
ren ER18799 tuotherrH	
ren ER18815 uncompH		
ren ER18816 tuuncompH	
ren ER18831 wcompH		
ren ER18832 tuwcompH	
ren ER18847 csH			
ren ER18848 tucsH		
ren ER18863 alimH		
ren ER18864 tualimH		
ren ER18879 helpfH		
ren ER18880 tuhelpfH	
ren ER18895 helpoH		
ren ER18896 tuhelpoH	
ren ER18911 miscH		
ren ER18912 tumiscH		
ren ER20444 blincW		
ren ER20445 baincW		
ren ER20447 lW			
gen	rincW		= .	
gen	turincW		= .	
ren ER18966 divW		
ren ER18967 tudivW		
ren ER18982 intW		
ren ER18983 tuintW		
ren ER18998 trincW		
ren ER18999 tutrincW	
ren ER19047 tanfW		
ren ER19048 tutanfW		
ren ER19031 ssiW		
ren ER19032 tussiW		
ren ER19079 otherwW		
ren ER19080 tuotherwW	
ren ER19095 pensannuW	
ren ER19096 tupensannuW	
ren ER18934 uncompW		
ren ER18935 tuuncompW	
ren ER18950 wcompW		
ren ER18951 tuwcompW	
ren ER19063 csW			
ren ER19064 tucsW		
ren ER19111 helpfW		
ren ER19112 tuhelpfW	
ren ER19127 helpoW		
ren ER19128 tuhelpoW	
ren ER19143 miscW		
ren ER19144 tumiscW		
ren ER20449 taxincHW	
ren ER20450 tranincHW	
ren ER20453 taxincR		
ren ER20454 tranincR	
ren ER19159 lumpF	
ren ER19172 supportF	
ren ER19179 vsupportF	
ren ER20456 incF
*	Food related and food stamps:		
ren ER18386 fstmpPY		
ren ER18387 vfstmpPY	
ren ER18388 tufstmpPY	
ren ER18402 fstmpCY		
ren ER18417 vstmpCY		
ren ER18418 tufstmpCY	
ren ER18416 numfstmp	
ren ER18421 fhomefst	
ren ER18422 tufhomefst	
ren ER18425 fdelfst		
ren ER18426 tufdelfst	
ren ER18428 foutfst		
ren ER18429 tufoutfst	
ren ER18431 fhome		
ren ER18432 tufhome		
ren ER18435 fdel		
ren ER18436 tufdel		
ren ER18438 fout		
ren ER18439 tufout
*	Household & personal expenses:		
gen	hrepair		= .
gen	tuhrepair	= .
gen	furnish		= .
gen	tufurnish	= .
gen	clothes		= .
gen	tuclothes	= .
gen	holiday		= .
gen	tuholiday	= .
gen	entertain	= .
gen	tuentertain	= .
ren ER17043 hstatus		
ren ER17079 pubhome		
ren ER17044 pvownhome	
ren ER17046 hometax		
ren ER17048 homeinsur	
ren ER17054 mortg1		
ren ER17059 yrsmortg1	
ren ER17072 incltax1	
ren ER17073 inclinsur1	
ren ER17065 mortg2		
ren ER17070 yrsmortg2	
ren ER17074 rent		
ren ER17075 turent	
ren ER17081 rentif
ren ER17082 turentif	
gen	combined	= .	
ren ER17099 hgas		
ren ER17100 tuhgas		
ren ER17097 elctr		
ren ER17098 tuelctr		
gen	gaselctr	= .
gen	tugaselctr	= .
ren ER17101 water		
ren ER17102 tuwater		
gen	telecom		= .
gen	tutelecom	= .
ren ER17108 otherutil	
ren ER17109 tuotherutil	
ren ER19841 ownhealth	
ren ER19842 nurse		
ren ER19848 doctor		
ren ER19854 drugs		
ren ER19860 totalhealth	
*	Car & transport expenses:
ren ER17110 vehicle		
ren ER17111 numvehicle
ren ER17202 vinsur		
ren ER17203 tuvinsur	
ren ER17205 otherveh	
ren ER17206 vrepair		
ren ER17207 vgas		
ren ER17208 vpark		
ren ER17209 bustrain	
ren ER17210 taxicabs	
ren ER17211 othertrans
*	Schooling & child care:	
ren ER17213 schoolexp	
ren ER17215 moreschool	
ren ER18362 childcare
*	Assets:
ren S509 	estates		
ren S513 	wheels		
ren S503 	farm_bus	
ren S511 	investm		
ren S519 	ira_annu	
ren S505 	savings		
ren S515 	otherasset	
ren S507 	debts		
ren S517 	wealth
ren S520 	homeequit
ren ER18359	hpH 
ren ER18357	hpW

gen year = 2001
label drop _all
compress
save $outputdir/newf2001.dta, replace 


/*******************************************************************************
Family (Interview) File - Year 2003
*******************************************************************************/

cd $PSIDdir
use f2003.dta, clear

*	Keep the following variables:
#delimit;
keep 	ER21002 ER21003 ER21016 ER21020 ER21021 ER23388 ER23303 ER21007 ER21017 
		ER21018 ER23426 ER21023 ER24148 ER23014 ER21019 ER23334 ER24149 ER23141 
		ER21123 ER21124 ER21125 ER21147 ER21203 ER21235 ER21267 ER21150 ER21151 
		ER24080 ER21373 ER21374 ER21375 ER21397 ER21453 ER21485 ER21517 ER21400 
		ER21401 ER24091 ER21852 ER24105 ER21857 ER24109 ER24110 ER24116 ER22003 
		ER22004 ER22020 ER22021 ER22037 ER22038 ER22054 ER22055 ER22070 ER22071 
		ER22087 ER22088 ER22103 ER22104 ER22120 ER22121 ER22136 ER22137 ER22152 
		ER22153 ER22168 ER22169 ER22185 ER22186 ER22201 ER22202 ER22217 ER22218 
		ER22233 ER22234 ER22249 ER22250 ER22265 ER22266 ER22281 ER22282 ER24111 
		ER24112 ER24135 ER22336 ER22337 ER22353 ER22354 ER22370 ER22371 ER22387 
		ER22388 ER22420 ER22421 ER22404 ER22405 ER22452 ER22453 ER22468 ER22469 
		ER22304 ER22305 ER22320 ER22321 ER22436 ER22437 ER22484 ER22485 ER22500 
		ER22501 ER22516 ER22517 ER24100 ER24101 ER24102 ER24103 ER22532 ER22537 
		ER22544 ER24099 ER21652 ER21653 ER21654 ER21668 ER21682 ER21683 ER21681 
		ER21686 ER21687 ER21690 ER21691 ER21693 ER21694 ER21696 ER21697 ER21700 
		ER21701 ER21703 ER21704 ER21749 ER21750 ER21838 ER21839 ER21841 ER21842 
		ER21843 ER21844 ER21845 ER21846 ER21847 ER21849 ER21851 ER21628 ER21042 
		ER21077 ER21043 ER21045 ER21047 ER21053 ER21058 ER21070 ER21071 ER21064 
		ER21069 ER21072 ER21073 ER21088 ER21089 ER21086 ER21087 ER21090 ER21091 
		ER21097 ER21098 ER23278 ER23279 ER23285 ER23291 ER23297 ER21079 ER21080 
		S609 	S613 	S603 	S611 	S619 	S605 	S615 	S607	S617 	
		S620 	ER24150 ER23427 ER23428 ER23429 ER23335 ER23336 ER23337 ER21625
		ER21623 ;
#delimit cr

*	Rename or initialise variables:
*	Demographics:	
ren ER21002	id					
ren ER21003 state		
ren ER21016 numfu		
ren ER21020 kids		
ren ER21021 ageK		
ren ER23388 newH		
ren ER23303 newW		
ren ER21007 newF		
ren ER21017 ageH		
ren ER21018 sexH		
ren ER23426 raceH1
ren ER23427 raceH2
ren ER23428 raceH3
ren ER23429 raceH4
ren ER21023 mstatusH
ren ER24150 maritalH
ren ER24148 educH		
ren ER21019 ageW
ren ER23334 raceW1
ren ER23335 raceW2
ren ER23336 raceW3
ren ER23337 raceW4				
ren ER24149 educW
*	Employment and hours:
ren ER23014 limitedH	
ren ER23141 limitedW			
ren ER21123 emplH1
ren ER21124 emplH2
ren ER21125 emplH3
ren ER21147 self1H		
ren ER21203 self2H		
ren ER21235 self3H		
ren ER21267 self4H		
gen	selfH	= .	
ren ER21150 unioncH		
ren ER21151 unionizedH	
ren ER24080 hoursH		
ren ER21373 emplW1
ren ER21374 emplW2
ren ER21375 emplW3
ren ER21397 self1W 		
ren ER21453 self2W		
ren ER21485 self3W		
ren ER21517 self4W		
gen	selfW	= .		
ren ER21400 unioncW		
ren ER21401 unionizedW	
ren ER24091 hoursW
*	Income, tranfers, and earnings:	
ren ER21852 farmerH		
ren ER24105 fincHW		
ren ER21857 business	
ren ER24109 blincH		
ren ER24110 baincH		
ren ER24116 lH	
ren ER22003 rincH		
ren ER22004 turincH		
ren ER22020 divH		
ren ER22021 tudivH		
ren ER22037 intH		
ren ER22038 tuintH		
ren ER22054 trincH		
ren ER22055 tutrincH	
ren ER22070 tanfH		
ren ER22071 tutanfH		
ren ER22087 ssiH		
ren ER22088 tussiH		
ren ER22103 otherwH		
ren ER22104 tuotherwH	
ren ER22120 vapH		
ren ER22121 tuvapH		
ren ER22136 pensH		
ren ER22137 tupensH		
ren ER22152 annuH		
ren ER22153 tuannuH		
ren ER22168 otherrH		
ren ER22169 tuotherrH	
ren ER22185 uncompH		
ren ER22186 tuuncompH	
ren ER22201 wcompH		
ren ER22202 tuwcompH	
ren ER22217 csH			
ren ER22218 tucsH		
ren ER22233 alimH		
ren ER22234 tualimH		
ren ER22249 helpfH		
ren ER22250 tuhelpfH	
ren ER22265 helpoH		
ren ER22266 tuhelpoH	
ren ER22281 miscH		
ren ER22282 tumiscH		
ren ER24111 blincW		
ren ER24112 baincW		
ren ER24135 lW		
ren ER22336 rincW		
ren ER22337 turincW	
ren ER22353 divW		
ren ER22354 tudivW			
ren ER22370 intW		
ren ER22371 tuintW			
ren ER22387 trincW		
ren ER22388 tutrincW	
ren ER22420 tanfW		
ren ER22421 tutanfW		
ren ER22404 ssiW		
ren ER22405 tussiW		
ren ER22452 otherwW		
ren ER22453 tuotherwW	
ren ER22468 pensannuW	
ren ER22469 tupensannuW	
ren ER22304 uncompW		
ren ER22305 tuuncompW	
ren ER22320 wcompW		
ren ER22321 tuwcompW	
ren ER22436 csW			
ren ER22437 tucsW		
ren ER22484 helpfW		
ren ER22485 tuhelpfW	
ren ER22500 helpoW		
ren ER22501 tuhelpoW	
ren ER22516 miscW		
ren ER22517 tumiscW		
ren ER24100 taxincHW	
ren ER24101 tranincHW	
ren ER24102 taxincR		
ren ER24103 tranincR	
ren ER22532 lumpF	
ren ER22537 supportF	
ren ER22544 vsupportF	
ren ER24099 incF
*	Food related and food stamps:			
ren ER21652 fstmpPY		
ren ER21653 vfstmpPY	
ren ER21654 tufstmpPY	
ren ER21668 fstmpCY		
ren ER21682 vstmpCY		
ren ER21683 tufstmpCY	
ren ER21681 numfstmp	
ren ER21686 fhomefst	
ren ER21687 tufhomefst	
ren ER21690 fdelfst		
ren ER21691 tufdelfst	
ren ER21693 foutfst		
ren ER21694 tufoutfst	
ren ER21696 fhome		
ren ER21697 tufhome		
ren ER21700 fdel		
ren ER21701 tufdel		
ren ER21703 fout		
ren ER21704 tufout
*	Household & personal expenses:
gen	hrepair		= .
gen	tuhrepair	= .
gen	furnish		= .
gen	tufurnish	= .
gen	clothes		= .
gen	tuclothes	= .
gen	holiday		= .
gen	tuholiday	= .
gen	entertain	= .
gen	tuentertain	= .
ren ER21042 hstatus		
ren ER21077 pubhome		
ren ER21043 pvownhome	
ren ER21045 hometax		
ren ER21047 homeinsur	
ren ER21053 mortg1		
ren ER21058 yrsmortg1	
ren ER21070 incltax1	
ren ER21071 inclinsur1	
ren ER21064 mortg2		
ren ER21069 yrsmortg2	
ren ER21072 rent		
ren ER21073 turent
ren ER21079 rentif
ren ER21080 turentif		
gen	combined	= .
ren ER21088 hgas		
ren ER21089 tuhgas		
ren ER21086 elctr		
ren ER21087 tuelctr		
gen	gaselctr	= .	
gen	tugaselctr	= .
ren ER21090 water		
ren ER21091 tuwater		
gen	telecom		= .	
gen	tutelecom	= .
ren ER21097 otherutil	
ren ER21098 tuotherutil	
ren ER23278 ownhealth	
ren ER23279 nurse		
ren ER23285 doctor		
ren ER23291 drugs		
ren ER23297 totalhealth
*	Car & transport expenses:
ren ER21749 vehicle		
ren ER21750 numvehicle
ren ER21838 vinsur		
ren ER21839 tuvinsur	
ren ER21841 otherveh	
ren ER21842 vrepair		
ren ER21843 vgas		
ren ER21844 vpark		
ren ER21845 bustrain	
ren ER21846 taxicabs	
ren ER21847 othertrans
*	Schooling & child care:	
ren ER21849 schoolexp	
ren ER21851 moreschool	
ren ER21628 childcare
*	Assets:	
ren S609 	estates		
ren S613 	wheels		
ren S603 	farm_bus	
ren S611 	investm		
ren S619 	ira_annu	
ren S605 	savings		
ren S615 	otherasset	
ren S607 	debts		
ren S617 	wealth
ren S620 	homeequit
ren ER21625	hpH
ren ER21623	hpW

gen year = 2003
label drop _all
compress
save $outputdir/newf2003.dta, replace


/*******************************************************************************
Family (Interview) File - Year 2005
*******************************************************************************/

cd $PSIDdir
use f2005.dta, clear

*	Keep the following variables:
#delimit;
keep 	ER25002 ER25003 ER25016 ER25020 ER25021 ER27352 ER27263 ER25007 ER25017 
		ER25018 ER27393 ER25023 ER28047 ER26995 ER25019 ER27297 ER28048 ER27118 
		ER25104 ER25105 ER25106 ER25129 ER25192 ER25224 ER25256 ER25138 ER25139 
		ER27886 ER25362 ER25363 ER25364 ER25387 ER25450 ER25482 ER25514 ER25396 
		ER25397 ER27897 ER25833 ER27908 ER25838 ER27910 ER27911 ER27931 ER25984 
		ER25985 ER26001 ER26002 ER26018 ER26019 ER26035 ER26036 ER26051 ER26052 
		ER26068 ER26069 ER26084 ER26085 ER26101 ER26102 ER26117 ER26118 ER26133 
		ER26134 ER26149 ER26150 ER26166 ER26167 ER26182 ER26183 ER26198 ER26199 
		ER26214 ER26215 ER26230 ER26231 ER26246 ER26247 ER26262 ER26263 ER27940 
		ER27941 ER27943 ER26317 ER26318 ER26334 ER26335 ER26351 ER26352 ER26368 
		ER26369 ER26401 ER26402 ER26385 ER26386 ER26433 ER26434 ER26449 ER26450 
		ER26285 ER26286 ER26301 ER26302 ER26417 ER26418 ER26465 ER26466 ER26481 
		ER26482 ER26497 ER26498 ER27953 ER28002 ER28009 ER28030 ER26513 ER26518 
		ER26525 ER28037 ER25654 ER25655 ER25656 ER25670 ER25684 ER25685 ER25683 
		ER25688 ER25689 ER25692 ER25693 ER25695 ER25696 ER25698 ER25699 ER25702 
		ER25703 ER25705 ER25706 ER25808 ER25809 ER25813 ER25814 ER25818 ER25819 
		ER25823 ER25824 ER25828 ER25829 ER25708 ER25709 ER25794 ER25795 ER25797 
		ER25798 ER25799 ER25800 ER25801 ER25802 ER25803 ER25805 ER25807 ER25628 
		ER25028 ER25068 ER25029 ER25036 ER25038 ER25044 ER25049 ER25061 ER25062 
		ER25055 ER25060 ER25063 ER25064 ER25080 ER25081 ER25082 ER25083 ER25084 
		ER25085 ER25086 ER25087 ER25090 ER25091 ER27238 ER27239 ER27245 ER27251 
		ER27257 ER25070 ER25071 S709 	S713 	S703 	S711 	S719 	S705 	
		S715 	S707 	S717 	S720 	ER28049 ER27394 ER27395 ER27396 ER27298 
		ER27299 ER27300 ER25622 ER25620 ;
#delimit cr

*	Rename or initialise variables:
*	Demographics:
ren ER25002 id				
ren ER25003 state		
ren ER25016 numfu		
ren ER25020 kids		
ren ER25021 ageK		
ren ER27352 newH		
ren ER27263 newW		
ren ER25007 newF		
ren ER25017 ageH		
ren ER25018 sexH		
ren ER27393 raceH1
ren ER27394 raceH2
ren ER27395 raceH3
ren ER27396 raceH4
ren ER25023 mstatusH
ren ER28049 maritalH
ren ER28047 educH			
ren ER25019 ageW		
ren ER27297 raceW1
ren ER27298 raceW2
ren ER27299 raceW3
ren ER27300 raceW4				
ren ER28048 educW	
*	Employment and hours:
ren ER26995 limitedH		
ren ER27118 limitedW
ren ER25104 emplH1
ren ER25105 emplH2
ren ER25106 emplH3
ren ER25129 self1H		
ren ER25192 self2H		
ren ER25224 self3H		
ren ER25256 self4H		
gen	selfH	= .		
ren ER25138 unioncH		
ren ER25139 unionizedH	
ren ER27886 hoursH		
ren ER25362 emplW1
ren ER25363 emplW2
ren ER25364 emplW3
ren ER25387 self1W 		
ren ER25450 self2W		
ren ER25482 self3W		
ren ER25514 self4W		
gen	selfW	= .	
ren ER25396 unioncW		
ren ER25397 unionizedW	
ren ER27897 hoursW
*	Income, tranfers, and earnings:	
ren ER25833 farmerH		
ren ER27908 fincHW		
ren ER25838 business	
ren ER27910 blincH		
ren ER27911 baincH		
ren ER27931 lH		
ren ER25984 rincH		
ren ER25985 turincH		
ren ER26001 divH		
ren ER26002 tudivH		
ren ER26018 intH		
ren ER26019 tuintH		
ren ER26035 trincH		
ren ER26036 tutrincH	
ren ER26051 tanfH		
ren ER26052 tutanfH		
ren ER26068 ssiH		
ren ER26069 tussiH		
ren ER26084 otherwH		
ren ER26085 tuotherwH	
ren ER26101 vapH		
ren ER26102 tuvapH		
ren ER26117 pensH		
ren ER26118 tupensH		
ren ER26133 annuH		
ren ER26134 tuannuH		
ren ER26149 otherrH		
ren ER26150 tuotherrH	
ren ER26166 uncompH		
ren ER26167 tuuncompH	
ren ER26182 wcompH		
ren ER26183 tuwcompH	
ren ER26198 csH			
ren ER26199 tucsH		
ren ER26214 alimH		
ren ER26215 tualimH		
ren ER26230 helpfH		
ren ER26231 tuhelpfH	
ren ER26246 helpoH		
ren ER26247 tuhelpoH	
ren ER26262 miscH		
ren ER26263 tumiscH		
ren ER27940 blincW		
ren ER27941 baincW		
ren ER27943 lW		
ren ER26317 rincW		
ren ER26318 turincW		
ren ER26334 divW		
ren ER26335 tudivW			
ren ER26351 intW		
ren ER26352 tuintW			
ren ER26368 trincW		
ren ER26369 tutrincW	
ren ER26401 tanfW		
ren ER26402 tutanfW		
ren ER26385 ssiW		
ren ER26386 tussiW		
ren ER26433 otherwW		
ren ER26434 tuotherwW	
ren ER26449 pensannuW	
ren ER26450 tupensannuW	
ren ER26285 uncompW		
ren ER26286 tuuncompW	
ren ER26301 wcompW		
ren ER26302 tuwcompW	
ren ER26417 csW			
ren ER26418 tucsW		
ren ER26465 helpfW		
ren ER26466 tuhelpfW	
ren ER26481 helpoW		
ren ER26482 tuhelpoW	
ren ER26497 miscW		
ren ER26498 tumiscW		
ren ER27953 taxincHW	
ren ER28002 tranincHW	
ren ER28009 taxincR		
ren ER28030 tranincR	
ren ER26513 lumpF	
ren ER26518 supportF	
ren ER26525 vsupportF	
ren ER28037 incF
*	Food related and food stamps:	
ren ER25654 fstmpPY		
ren ER25655 vfstmpPY	
ren ER25656 tufstmpPY	
ren ER25670 fstmpCY		
ren ER25684 vstmpCY		
ren ER25685 tufstmpCY	
ren ER25683 numfstmp	
ren ER25688 fhomefst	
ren ER25689 tufhomefst	
ren ER25692 fdelfst		
ren ER25693 tufdelfst	
ren ER25695 foutfst		
ren ER25696 tufoutfst	
ren ER25698 fhome		
ren ER25699 tufhome		
ren ER25702 fdel		
ren ER25703 tufdel		
ren ER25705 fout		
ren ER25706 tufout
*	Household & personal expenses:	
ren ER25808 hrepair		
ren ER25809 tuhrepair	
ren ER25813 furnish		
ren ER25814 tufurnish	
ren ER25818 clothes		
ren ER25819 tuclothes	
ren ER25823 holiday		
ren ER25824 tuholiday	
ren ER25828 entertain	
ren ER25829 tuentertain
ren ER25028 hstatus		
ren ER25068 pubhome		
ren ER25029 pvownhome	
ren ER25036 hometax		
ren ER25038 homeinsur	
ren ER25044 mortg1		
ren ER25049 yrsmortg1	
ren ER25061 incltax1	
ren ER25062 inclinsur1	
ren ER25055 mortg2		
ren ER25060 yrsmortg2	
ren ER25063 rent		
ren ER25064 turent
ren ER25070 rentif
ren ER25071 turentif		
gen	combined	= .
ren ER25080 hgas		
ren ER25081 tuhgas		
ren ER25082 elctr		
ren ER25083 tuelctr		
gen	gaselctr	= .
gen	tugaselctr	= .
ren ER25084 water		
ren ER25085 tuwater		
ren ER25086 telecom		
ren ER25087 tutelecom	
ren ER25090 otherutil	
ren ER25091 tuotherutil	
ren ER27238 ownhealth	
ren ER27239 nurse		
ren ER27245 doctor		
ren ER27251 drugs		
ren ER27257 totalhealth
*	Car & transport expenses:
ren ER25708 vehicle		
ren ER25709 numvehicle
ren ER25794 vinsur		
ren ER25795 tuvinsur	
ren ER25797 otherveh	
ren ER25798 vrepair		
ren ER25799 vgas		
ren ER25800 vpark		
ren ER25801 bustrain	
ren ER25802 taxicabs	
ren ER25803 othertrans
*	Schooling & child care:		
ren ER25805 schoolexp	
ren ER25807 moreschool	
ren ER25628 childcare
*	Assets:	
ren S709 	estates		
ren S713 	wheels		
ren S703 	farm_bus	
ren S711 	investm		
ren S719 	ira_annu	
ren S705 	savings		
ren S715 	otherasset	
ren S707 	debts		
ren S717 	wealth
ren S720 	homeequit
ren ER25622	hpH 
ren ER25620	hpW

gen year = 2005
label drop _all
compress
save $outputdir/newf2005.dta, replace


/*******************************************************************************
Family (Interview) File - Year 2007
*******************************************************************************/

cd $PSIDdir
use f2007.dta, clear

*	Keep the following variables:
#delimit;
keep 	ER36002	ER36003 ER36016 ER36020 ER36021 ER40527 ER40438 ER36007 ER36017 
		ER36018 ER40565 ER36023 ER41037 ER38206 ER36019 ER40472 ER41038 ER39303 
		ER36109 ER36110 ER36111 ER36134 ER36197 ER36229 ER36261 ER36143 ER36144 
		ER40876 ER36367 ER36368 ER36369 ER36392 ER36455 ER36487 ER36519 ER36401 
		ER36402 ER40887 ER36851 ER40898 ER36856 ER40900 ER40901 ER40921 ER37002 
		ER37003 ER37019 ER37020 ER37036 ER37037 ER37053 ER37054 ER37069 ER37070 
		ER37086 ER37087 ER37102 ER37103 ER37119 ER37120 ER37135 ER37136 ER37151 
		ER37152 ER37167 ER37168 ER37184 ER37185 ER37200 ER37201 ER37216 ER37217 
		ER37232 ER37233 ER37248 ER37249 ER37264 ER37265 ER37280 ER37281 ER40930 
		ER40931 ER40933 ER37335 ER37336 ER37352 ER37353 ER37369 ER37370 ER37386 
		ER37387 ER37419 ER37420 ER37403 ER37404 ER37451 ER37452 ER37467 ER37468 
		ER37303 ER37304 ER37319 ER37320 ER37435 ER37436 ER37483 ER37484 ER37499 
		ER37500 ER37515 ER37516 ER40943 ER40992 ER40999 ER41020 ER37531 ER37536 
		ER37543 ER41027 ER36672 ER36673 ER36674 ER36688	ER36702	ER36703	ER36701 
		ER36706 ER36707 ER36710 ER36711 ER36713 ER36714 ER36716 ER36717 ER36720 
		ER36721 ER36723 ER36724 ER36826 ER36827 ER36831 ER36832 ER36836 ER36837 
		ER36841 ER36842 ER36846 ER36847 ER36726 ER36727 ER36812 ER36813 ER36815 
		ER36816 ER36817 ER36818 ER36819 ER36820 ER36821 ER36823 ER36825 ER36633 
		ER36028 ER36070 ER36029 ER36036 ER36038 ER36044 ER36050 ER36063 ER36064 
		ER36056 ER36062 ER36065 ER36066 ER36082 ER36083 ER36084 ER36085 ER36086 
		ER36087 ER36088 ER36089 ER36090 ER36091 ER36092 ER36095 ER36096 ER40410	
		ER40414 ER40420 ER40426 ER40432 ER36072 ER36073 S809 	S813 	S803 	
		S811 	S819 	S805 	S815 	S807 	S817 	S820 	ER41039 ER40566 
		ER40567 ER40568 ER40473 ER40474 ER40475 ER36627 ER36625 ;
#delimit cr

*	Rename or initialise variables:
*	Demographics:
ren ER36002	id				
ren ER36003 state		
ren ER36016 numfu		
ren ER36020 kids		
ren ER36021 ageK		
ren ER40527 newH		
ren ER40438 newW		
ren ER36007 newF		
ren ER36017 ageH		
ren ER36018 sexH		
ren ER40565 raceH1
ren ER40566 raceH2
ren ER40567 raceH3
ren ER40568 raceH4	
ren ER36023 mstatusH
ren ER41039 maritalH
ren ER41037 educH			
ren ER36019 ageW		
ren ER40472 raceW1
ren ER40473 raceW2
ren ER40474 raceW3
ren ER40475 raceW4				
ren ER41038 educW
*	Employment and hours:
ren ER38206 limitedH		
ren ER39303 limitedW			
ren ER36109 emplH1
ren ER36110 emplH2
ren ER36111 emplH3
ren ER36134 self1H		
ren ER36197 self2H		
ren ER36229 self3H		
ren ER36261 self4H		
gen	selfH	= .	
ren ER36143 unioncH		
ren ER36144 unionizedH	
ren ER40876 hoursH		
ren ER36367 emplW1
ren ER36368 emplW2
ren ER36369 emplW3	
ren ER36392 self1W 		
ren ER36455 self2W		
ren ER36487 self3W		
ren ER36519 self4W		
gen	selfW	= .	
ren ER36401 unioncW		
ren ER36402 unionizedW	
ren ER40887 hoursW
*	Income, tranfers, and earnings:
ren ER36851 farmerH		
ren ER40898 fincHW		
ren ER36856 business	
ren ER40900 blincH		
ren ER40901 baincH		
ren ER40921 lH		
ren ER37002 rincH		
ren ER37003 turincH		
ren ER37019 divH		
ren ER37020 tudivH		
ren ER37036 intH		
ren ER37037 tuintH		
ren ER37053 trincH		
ren ER37054 tutrincH	
ren ER37069 tanfH		
ren ER37070 tutanfH		
ren ER37086 ssiH		
ren ER37087 tussiH		
ren ER37102 otherwH		
ren ER37103 tuotherwH	
ren ER37119 vapH		
ren ER37120 tuvapH		
ren ER37135 pensH		
ren ER37136 tupensH		
ren ER37151 annuH		
ren ER37152 tuannuH		
ren ER37167 otherrH		
ren ER37168 tuotherrH	
ren ER37184 uncompH		
ren ER37185 tuuncompH	
ren ER37200 wcompH		
ren ER37201 tuwcompH	
ren ER37216 csH			
ren ER37217 tucsH		
ren ER37232 alimH		
ren ER37233 tualimH		
ren ER37248 helpfH		
ren ER37249 tuhelpfH	
ren ER37264 helpoH		
ren ER37265 tuhelpoH	
ren ER37280 miscH		
ren ER37281 tumiscH		
ren ER40930 blincW		
ren ER40931 baincW		
ren ER40933 lW		
ren ER37335 rincW		
ren ER37336 turincW		
ren ER37352 divW		
ren ER37353 tudivW			
ren ER37369 intW		
ren ER37370 tuintW			
ren ER37386 trincW		
ren ER37387 tutrincW	
ren ER37419 tanfW		
ren ER37420 tutanfW		
ren ER37403 ssiW		
ren ER37404 tussiW		
ren ER37451 otherwW		
ren ER37452 tuotherwW	
ren ER37467 pensannuW	
ren ER37468 tupensannuW	
ren ER37303 uncompW		
ren ER37304 tuuncompW	
ren ER37319 wcompW		
ren ER37320 tuwcompW	
ren ER37435 csW			
ren ER37436 tucsW		
ren ER37483 helpfW		
ren ER37484 tuhelpfW	
ren ER37499 helpoW		
ren ER37500 tuhelpoW	
ren ER37515 miscW		
ren ER37516 tumiscW		
ren ER40943 taxincHW	
ren ER40992 tranincHW	
ren ER40999 taxincR		
ren ER41020 tranincR	
ren ER37531 lumpF	
ren ER37536 supportF	
ren ER37543 vsupportF	
ren ER41027 incF
*	Food related and food stamps:	
ren ER36672 fstmpPY		
ren ER36673 vfstmpPY	
ren ER36674 tufstmpPY	
ren ER36688	fstmpCY		
ren ER36702	vstmpCY		
ren ER36703	tufstmpCY	
ren ER36701 numfstmp	
ren ER36706 fhomefst	
ren ER36707 tufhomefst	
ren ER36710 fdelfst		
ren ER36711 tufdelfst	
ren ER36713 foutfst		
ren ER36714 tufoutfst	
ren ER36716 fhome		
ren ER36717 tufhome		
ren ER36720 fdel		
ren ER36721 tufdel		
ren ER36723 fout		
ren ER36724 tufout
*	Household & personal expenses:	
ren ER36826 hrepair		
ren ER36827 tuhrepair	
ren ER36831 furnish		
ren ER36832 tufurnish	
ren ER36836 clothes		
ren ER36837 tuclothes	
ren ER36841 holiday		
ren ER36842 tuholiday	
ren ER36846 entertain	
ren ER36847 tuentertain
ren ER36028 hstatus		
ren ER36070 pubhome		
ren ER36029 pvownhome	
ren ER36036 hometax		
ren ER36038 homeinsur	
ren ER36044 mortg1		
ren ER36050 yrsmortg1	
ren ER36063 incltax1	
ren ER36064 inclinsur1	
ren ER36056 mortg2		
ren ER36062 yrsmortg2	
ren ER36065 rent		
ren ER36066 turent
ren ER36072 rentif
ren ER36073 turentif	
ren ER36082 combined	
ren ER36083 hgas		
ren ER36084 tuhgas		
ren ER36085 elctr		
ren ER36086 tuelctr		
ren ER36087 gaselctr	
ren ER36088 tugaselctr	
ren ER36089 water		
ren ER36090 tuwater		
ren ER36091 telecom		
ren ER36092 tutelecom	
ren ER36095 otherutil	
ren ER36096 tuotherutil	
ren ER40410	ownhealth	
ren ER40414 nurse		
ren ER40420 doctor		
ren ER40426 drugs		
ren ER40432 totalhealth
*	Car & transport expenses:	
ren ER36726 vehicle		
ren ER36727 numvehicle	
ren ER36812 vinsur		
ren ER36813 tuvinsur	
ren ER36815 otherveh	
ren ER36816 vrepair		
ren ER36817 vgas		
ren ER36818 vpark		
ren ER36819 bustrain	
ren ER36820 taxicabs	
ren ER36821 othertrans
*	Schooling & child care:		
ren ER36823 schoolexp	
ren ER36825 moreschool	
ren ER36633 childcare
*	Assets:	
ren S809 	estates		
ren S813 	wheels		
ren S803 	farm_bus	
ren S811 	investm		
ren S819 	ira_annu	
ren S805 	savings		
ren S815 	otherasset	
ren S807 	debts		
ren S817 	wealth
ren S820 	homeequit
ren ER36627	hpH 
ren ER36625	hpW

gen year = 2007
label drop _all
compress
save $outputdir/newf2007.dta, replace


/*******************************************************************************
Family (Interview) File - Year 2009
*******************************************************************************/

cd $PSIDdir
use f2009.dta, clear

*	Keep the following variables:	
#delimit;
keep 	ER42002 ER42003 ER42016 ER42020 ER42021 ER46504 ER46410 ER42007 ER42017 
		ER42018 ER46543 ER42023 ER46981 ER44179 ER42019 ER46449 ER46982 ER45276 
		ER42140 ER42141 ER42142 ER42169 ER42230 ER42260 ER42290 ER42178 ER42179 
		ER46767 ER42392 ER42393 ER42394 ER42421 ER42482 ER42512 ER42542 ER42430 
		ER42431 ER46788 ER42842 ER46806 ER42847 ER46808 ER46809 ER46829 ER42993 
		ER42994 ER43010 ER43011 ER43027 ER43028 ER43044 ER43045 ER43060 ER43061 
		ER43077 ER43078 ER43093 ER43094 ER43110 ER43111 ER43126 ER43127 ER43142 
		ER43143 ER43158 ER43159 ER43175 ER43176 ER43191 ER43192 ER43207 ER43208 
		ER43223 ER43224 ER43239 ER43240 ER43255 ER43256 ER43271 ER43272 ER46838 
		ER46839 ER46841 ER43326 ER43327 ER43343 ER43344 ER43360 ER43361 ER43377 
		ER43378 ER43410 ER43411 ER43394 ER43395 ER43442 ER43443 ER43458 ER43459 
		ER43294 ER43295 ER43310 ER43311 ER43426 ER43427 ER43474 ER43475 ER43490 
		ER43491 ER43506 ER43507 ER46851 ER46900 ER46907 ER46928 ER43522 ER43527 
		ER43534 ER46935 ER42691 ER42692 ER42693 ER42708 ER42712 ER42713 ER42716 
		ER42717 ER42719 ER42720 ER42722 ER42723 ER42726 ER42727 ER42729 ER42730 
		ER42817 ER42818 ER42822 ER42823 ER42827 ER42828 ER42832 ER42833 ER42837 
		ER42838 ER42732 ER42733 ER42803 ER42804 ER42806 ER42807 ER42808 ER42809 
		ER42810 ER42811 ER42812 ER42814 ER42816 ER42652 ER42029 ER42085 ER42030 
		ER42037 ER42039 ER42045 ER42051 ER42078 ER42079 ER42064 ER42070 ER42080 
		ER42081 ER42111 ER42112 ER42113 ER42114 ER42115 ER42116 ER42117 ER42118 
		ER42119 ER42120 ER42121 ER42124 ER42125 ER46383 ER46387 ER46393 ER46399 
		ER46404 ER46950 ER46956 ER46938 ER46954 ER46964 ER46942 ER46960 ER46946	
		ER46970 ER46966 ER42087 ER42088 ER46983 ER46544 ER46545 ER46546 ER46450 
		ER46451 ER46452 ER42646	ER42644 ;
#delimit cr

*	Rename or initialise variables:
*	Demographics:
ren ER42002 id					
ren ER42003 state		
ren ER42016 numfu		
ren ER42020 kids		
ren ER42021 ageK		
ren ER46504 newH		
ren ER46410 newW		
ren ER42007 newF		
ren ER42017 ageH		
ren ER42018 sexH		
ren ER46543 raceH1
ren ER46544 raceH2
ren ER46545 raceH3
ren ER46546 raceH4			
ren ER42023 mstatusH
ren ER46983 maritalH
ren ER46981 educH		
ren ER42019 ageW		
ren ER46449 raceW1
ren ER46450 raceW2
ren ER46451 raceW3
ren ER46452 raceW4				
ren ER46982 educW	
*	Employment and hours:
ren ER44179 limitedH			
ren ER45276 limitedW
ren ER42140 emplH1
ren ER42141 emplH2
ren ER42142 emplH3
ren ER42169 self1H		
ren ER42230 self2H		
ren ER42260 self3H		
ren ER42290 self4H		
gen	selfH	= .	
ren ER42178 unioncH		
ren ER42179 unionizedH	
ren ER46767 hoursH		
ren ER42392 emplW1
ren ER42393 emplW2
ren ER42394 emplW3
ren ER42421 self1W 		
ren ER42482 self2W		
ren ER42512 self3W		
ren ER42542 self4W		
gen	selfW	= .	
ren ER42430 unioncW		
ren ER42431 unionizedW	
ren ER46788 hoursW	
*	Income, tranfers, and earnings:
ren ER42842 farmerH		
ren ER46806 fincHW		
ren ER42847 business	
ren ER46808 blincH		
ren ER46809 baincH		
ren ER46829 lH			
ren ER42993 rincH		
ren ER42994 turincH		
ren ER43010 divH		
ren ER43011 tudivH		
ren ER43027 intH		
ren ER43028 tuintH		
ren ER43044 trincH		
ren ER43045 tutrincH	
ren ER43060 tanfH		
ren ER43061 tutanfH		
ren ER43077 ssiH		
ren ER43078 tussiH		
ren ER43093 otherwH		
ren ER43094 tuotherwH	
ren ER43110 vapH		
ren ER43111 tuvapH		
ren ER43126 pensH		
ren ER43127 tupensH		
ren ER43142 annuH		
ren ER43143 tuannuH		
ren ER43158 otherrH		
ren ER43159 tuotherrH	
ren ER43175 uncompH		
ren ER43176 tuuncompH	
ren ER43191 wcompH		
ren ER43192 tuwcompH	
ren ER43207 csH			
ren ER43208 tucsH		
ren ER43223 alimH		
ren ER43224 tualimH		
ren ER43239 helpfH		
ren ER43240 tuhelpfH	
ren ER43255 helpoH		
ren ER43256 tuhelpoH	
ren ER43271 miscH		
ren ER43272 tumiscH		
ren ER46838 blincW		
ren ER46839 baincW		
ren ER46841 lW		
ren ER43326 rincW		
ren ER43327 turincW			
ren ER43343 divW		
ren ER43344 tudivW			
ren ER43360 intW		
ren ER43361 tuintW			
ren ER43377 trincW		
ren ER43378 tutrincW	
ren ER43410 tanfW		
ren ER43411 tutanfW		
ren ER43394 ssiW		
ren ER43395 tussiW		
ren ER43442 otherwW		
ren ER43443 tuotherwW	
ren ER43458 pensannuW	
ren ER43459 tupensannuW	
ren ER43294 uncompW		
ren ER43295 tuuncompW	
ren ER43310 wcompW		
ren ER43311 tuwcompW	
ren ER43426 csW			
ren ER43427 tucsW		
ren ER43474 helpfW		
ren ER43475 tuhelpfW	
ren ER43490 helpoW		
ren ER43491 tuhelpoW	
ren ER43506 miscW		
ren ER43507 tumiscW		
ren ER46851 taxincHW	
ren ER46900 tranincHW	
ren ER46907 taxincR		
ren ER46928 tranincR	
ren ER43522 lumpF	
ren ER43527 supportF	
ren ER43534 vsupportF	
ren ER46935 incF
*	Food related and food stamps:	
ren ER42691 fstmpPY		
ren ER42692 vfstmpPY	
ren ER42693 tufstmpPY	
gen	fstmpCY		= .	
gen	vstmpCY		= .
gen	tufstmpCY	= .	
ren ER42708 numfstmp	
ren ER42712 fhomefst	
ren ER42713 tufhomefst	
ren ER42716 fdelfst		
ren ER42717 tufdelfst	
ren ER42719 foutfst		
ren ER42720 tufoutfst	
ren ER42722 fhome		
ren ER42723 tufhome		
ren ER42726 fdel		
ren ER42727 tufdel		
ren ER42729 fout		
ren ER42730 tufout
*	Household & personal expenses:
ren ER42817 hrepair		
ren ER42818 tuhrepair	
ren ER42822 furnish		
ren ER42823 tufurnish	
ren ER42827 clothes		
ren ER42828 tuclothes	
ren ER42832 holiday		
ren ER42833 tuholiday	
ren ER42837 entertain	
ren ER42838 tuentertain	
ren ER42029 hstatus		
ren ER42085 pubhome		
ren ER42030 pvownhome	
ren ER42037 hometax		
ren ER42039 homeinsur	
ren ER42045 mortg1		
ren ER42051 yrsmortg1	
ren ER42078 incltax1	
ren ER42079 inclinsur1	
ren ER42064 mortg2		
ren ER42070 yrsmortg2	
ren ER42080 rent		
ren ER42081 turent
ren ER42087 rentif
ren ER42088 turentif	
ren ER42111 combined	
ren ER42112 hgas		
ren ER42113 tuhgas		
ren ER42114 elctr		
ren ER42115 tuelctr		
ren ER42116 gaselctr	
ren ER42117 tugaselctr	
ren ER42118 water		
ren ER42119 tuwater		
ren ER42120 telecom		
ren ER42121 tutelecom	
ren ER42124 otherutil	
ren ER42125 tuotherutil	
ren ER46383 ownhealth	
ren ER46387 nurse		
ren ER46393 doctor		
ren ER46399 drugs		
ren ER46404 totalhealth	
*	Car & transport expenses:
ren ER42732 vehicle		
ren ER42733 numvehicle
ren ER42803 vinsur		
ren ER42804 tuvinsur	
ren ER42806 otherveh	
ren ER42807 vrepair		
ren ER42808 vgas		
ren ER42809 vpark		
ren ER42810 bustrain	
ren ER42811 taxicabs	
ren ER42812 othertrans
*	Schooling & child care:
ren ER42814 schoolexp	
ren ER42816 moreschool	
ren ER42652 childcare
*	Assets:	
ren ER46950 estates		
ren ER46956 wheels		
ren ER46938 farm_bus	
ren ER46954 investm		
ren ER46964 ira_annu	
ren ER46942 savings		
ren ER46960 otherasset
ren ER46946	debts		
ren ER46970 wealth	
ren ER46966 homeequit
ren ER42646	hpH	
ren ER42644	hpW

gen year = 2009
label drop _all
compress
save $outputdir/newf2009.dta, replace


/*******************************************************************************
Family (Interview) File - Year 2011
*******************************************************************************/

cd $PSIDdir
use f2011.dta, clear

*	Keep the following variables:
#delimit;
keep 	ER47302 ER47303	ER47316 ER47320 ER47321	ER51865	ER51771	ER47307	ER47317 
		ER47318 ER51904 ER47323 ER52405 ER49498 ER47319 ER51810	ER52406	ER50616	
		ER47448	ER47449 ER47450 ER47482	ER47543	ER47573	ER47603	ER47491	ER47492 
		ER52175	ER47705	ER47706 ER47707 ER47739	ER47800	ER47830	ER47860	ER47748	
		ER47749	ER52196	ER48164	ER52214	ER48169	ER52216	ER52217	ER52237 ER48315	
		ER48316	ER48332	ER48333	ER48349	ER48350	ER48366	ER48367	ER48382	ER48383	
		ER48399	ER48400	ER48415	ER48416	ER48435	ER48436	ER48451 ER48452	ER48467	
		ER48468	ER48483	ER48484	ER48500	ER48501	ER48516	ER48517	ER48532	ER48533	
		ER48548	ER48549	ER48564	ER48565	ER48580	ER48581 ER48596	ER48597	ER52246	
		ER52247	ER52249	ER48651	ER48652	ER48668	ER48669	ER48685	ER48686	ER48702 
		ER48703	ER48735	ER48736	ER48719	ER48720	ER48767	ER48768	ER48783	ER48784	
		ER48619	ER48620	ER48635	ER48636	ER48751	ER48752	ER48799 ER48800 ER48815	
		ER48816	ER48831	ER48832	ER52259	ER52308	ER52315	ER52336	ER48847	ER48852	
		ER48859	ER52343 ER48007	ER48008	ER48009	ER48024	ER48028	ER48029	ER48032	
		ER48033	ER48035	ER48036	ER48038	ER48039	ER48042	ER48043	ER48045 ER48046	
		ER48139	ER48140	ER48144	ER48145	ER48149	ER48150	ER48154	ER48155	ER48159	
		ER48160	ER48048	ER48049	ER48125	ER48126	ER48128	ER48129	ER48130	ER48131	
		ER48132	ER48133	ER48134	ER48136	ER48138	ER47970 ER47329	ER47393 ER47330	
		ER47342	ER47344	ER47350	ER47358	ER47352	ER47353	ER47371	ER47379	ER47387	
		ER47388	ER47414 ER47415 ER47416	ER47417 ER47418	ER47419	ER47420	ER47421	
		ER47422	ER47423	ER47424	ER47427	ER47428	ER51744	ER51748	ER51754	ER51760	
		ER51765	ER52354	ER52360	ER52346	ER52358	ER52368 ER52350 ER52364	ER52372 
		ER52376	ER52380	ER52384	ER52388	ER52394	ER52390	ER47395 ER47396 ER52407 
		ER51905 ER51906 ER51907 ER51811 ER51812 ER51813 ER47964	ER47962 ;
#delimit cr

*	Rename or initialise variables:
*	Demographics:
ren ER47302	id					
ren ER47303	state		
ren ER47316	numfu		
ren ER47320	kids		
ren ER47321	ageK		
ren ER51865	newH		
ren ER51771	newW		
ren ER47307	newF		
ren ER47317	ageH		
ren ER47318	sexH		
ren ER51904	raceH1
ren ER51905 raceH2
ren ER51906 raceH3
ren ER51907 raceH4	
ren ER47323	mstatusH
ren ER52407 maritalH	
ren ER52405	educH			
ren ER47319	ageW		
ren ER51810	raceW1
ren ER51811 raceW2
ren ER51812 raceW3
ren ER51813 raceW4		
ren ER52406	educW
*	Employment and hours:	
ren ER49498	limitedH	
ren ER50616	limitedW
ren ER47448	emplH1
ren ER47449 emplH2
ren ER47450 emplH3
ren ER47482	self1H		
ren ER47543	self2H		
ren ER47573	self3H		
ren ER47603	self4H		
gen	selfH	= .	
ren ER47491	unioncH		
ren ER47492	unionizedH	
ren ER52175	hoursH		
ren ER47705	emplW1
ren ER47706 emplW2
ren ER47707 emplW3
ren ER47739	self1W 		
ren ER47800	self2W		
ren ER47830	self3W		
ren ER47860	self4W		
gen	selfW	= .	
ren ER47748	unioncW		
ren ER47749	unionizedW	
ren ER52196	hoursW
*	Income, tranfers, and earnings:	
ren ER48164	farmerH		
ren ER52214	fincHW		
ren ER48169	business	
ren ER52216	blincH		
ren ER52217	baincH		
ren ER52237	lH			
ren ER48315	rincH		
ren ER48316	turincH		
ren ER48332	divH		
ren ER48333	tudivH		
ren ER48349	intH		
ren ER48350	tuintH		
ren ER48366	trincH		
ren ER48367	tutrincH	
ren ER48382	tanfH		
ren ER48383	tutanfH		
ren ER48399	ssiH		
ren ER48400	tussiH		
ren ER48415	otherwH		
ren ER48416	tuotherwH	
ren ER48435	vapH		
ren ER48436	tuvapH		
ren ER48451	pensH		
ren ER48452	tupensH		
ren ER48467	annuH		
ren ER48468	tuannuH		
ren ER48483	otherrH		
ren ER48484	tuotherrH	
ren ER48500	uncompH		
ren ER48501	tuuncompH	
ren ER48516	wcompH		
ren ER48517	tuwcompH	
ren ER48532	csH			
ren ER48533	tucsH		
ren ER48548	alimH		
ren ER48549	tualimH		
ren ER48564	helpfH		
ren ER48565	tuhelpfH	
ren ER48580	helpoH		
ren ER48581	tuhelpoH	
ren ER48596	miscH		
ren ER48597	tumiscH		
ren ER52246	blincW		
ren ER52247	baincW		
ren ER52249	lW			
ren ER48651	rincW		
ren ER48652	turincW		
ren ER48668	divW		
ren ER48669	tudivW			
ren ER48685	intW		
ren ER48686	tuintW			
ren ER48702	trincW		
ren ER48703	tutrincW	
ren ER48735	tanfW		
ren ER48736	tutanfW		
ren ER48719	ssiW		
ren ER48720	tussiW		
ren ER48767	otherwW		
ren ER48768	tuotherwW	
ren ER48783	pensannuW	
ren ER48784	tupensannuW	
ren ER48619	uncompW		
ren ER48620	tuuncompW	
ren ER48635	wcompW		
ren ER48636	tuwcompW	
ren ER48751	csW			
ren ER48752	tucsW		
ren ER48799	helpfW		
ren ER48800	tuhelpfW	
ren ER48815	helpoW		
ren ER48816	tuhelpoW	
ren ER48831	miscW		
ren ER48832	tumiscW		
ren ER52259	taxincHW	
ren ER52308	tranincHW	
ren ER52315	taxincR		
ren ER52336	tranincR	
ren ER48847	lumpF	
ren ER48852	supportF	
ren ER48859	vsupportF	
ren ER52343	incF
*	Food related and food stamps:	
ren ER48007	fstmpPY		
ren ER48008	vfstmpPY	
ren ER48009	tufstmpPY	
gen	fstmpCY		= .	
gen	vstmpCY		= .
gen	tufstmpCY	= .	
ren ER48024	numfstmp	
ren ER48028	fhomefst	
ren ER48029	tufhomefst	
ren ER48032	fdelfst		
ren ER48033	tufdelfst	
ren ER48035	foutfst		
ren ER48036	tufoutfst	
ren ER48038	fhome		
ren ER48039	tufhome		
ren ER48042	fdel		
ren ER48043	tufdel		
ren ER48045	fout		
ren ER48046	tufout
*	Household & personal expenses:	
ren ER48139	hrepair		
ren ER48140	tuhrepair	
ren ER48144	furnish		
ren ER48145	tufurnish	
ren ER48149	clothes		
ren ER48150	tuclothes	
ren ER48154	holiday		
ren ER48155	tuholiday	
ren ER48159	entertain	
ren ER48160	tuentertain	
ren ER47329	hstatus		
ren ER47393	pubhome		
ren ER47330	pvownhome	
ren ER47342	hometax		
ren ER47344	homeinsur	
ren ER47350	mortg1		
ren ER47358	yrsmortg1	
ren ER47352	incltax1	
ren ER47353	inclinsur1	
ren ER47371	mortg2		
ren ER47379	yrsmortg2	
ren ER47387	rent
ren ER47395 rentif
ren ER47396 turentif		
ren ER47388	turent		
ren ER47414	combined	
ren ER47415	hgas		
ren ER47416	tuhgas		
ren ER47417	elctr		
ren ER47418	tuelctr		
ren ER47419	gaselctr	
ren ER47420	tugaselctr	
ren ER47421	water		
ren ER47422	tuwater		
ren ER47423	telecom		
ren ER47424	tutelecom	
ren ER47427	otherutil	
ren ER47428	tuotherutil	
ren ER51744	ownhealth	
ren ER51748	nurse		
ren ER51754	doctor		
ren ER51760	drugs		
ren ER51765	totalhealth	
*	Car & transport expenses:
ren ER48048	vehicle		
ren ER48049	numvehicle
ren ER48125	vinsur		
ren ER48126	tuvinsur	
ren ER48128	otherveh	
ren ER48129	vrepair		
ren ER48130	vgas		
ren ER48131	vpark		
ren ER48132	bustrain	
ren ER48133	taxicabs	
ren ER48134	othertrans
*	Schooling & child care:
ren ER48136	schoolexp	
ren ER48138	moreschool	
ren ER47970	childcare
*	Assets:	
ren ER52354	estates		
ren ER52360	wheels		
ren ER52346	farm_bus	
ren ER52358	investm		
ren ER52368	ira_annu	
ren ER52350	savings		
ren ER52364	otherasset
ren ER52394	wealth
ren ER52390	homeequit
egen debts	= rsum(ER52372 ER52376 ER52380 ER52384 ER52388), missing	/*	Here I generate 'debts' as the sum of credit card debts, medical and legal debts, student loans, loans from */
drop ER52372 ER52376 ER52380 ER52384 ER52388							/*	relatives. In previous years this variable came as a single unique variable incorporating all these debts.	*/
ren ER47964	hpH	
ren ER47962	hpW

gen year = 2011
label drop _all
compress
save $outputdir/newf2011.dta, replace


/*******************************************************************************
Append Family (Interview) Files across Years 1997-2011 (Biennially)
*******************************************************************************/

cd $PSIDdir
use "$outputdir/newf1997.dta", clear

*	Implement append:
#delimit;
append using 	"$outputdir/newf1999.dta" "$outputdir/newf2001.dta" 
				"$outputdir/newf2003.dta" "$outputdir/newf2005.dta" 
				"$outputdir/newf2007.dta" "$outputdir/newf2009.dta" 
				"$outputdir/newf2011.dta", nonotes ;
#delimit cr
rename id intv_id
sort year intv_id

*	Label variables in the dataset:				
label variable 	intv_id		"INTERVIEW #"		
label variable 	state		"STATE RESIDENCE"
label variable 	numfu		"# OF FU MEMBERS"
label variable 	kids		"# OF KIDS"
label variable 	ageK		"AGE YOUNGEST KID"
label variable 	newH		"NEW HD"
label variable 	newW		"NEW WF"
label variable 	newF		"FAMILY BREAK"
label variable 	ageH		"AGE HD"
label variable 	sexH		"SEX HD"
label variable 	raceH1		"RACE HD 1"
label variable 	raceH2		"RACE HD 2"
label variable 	raceH3		"RACE HD 3"
label variable 	raceH4		"RACE HD 4"
label variable 	mstatusH	"MARITAL STATUS HD"
label variable  maritalH 	"MARITAL STATUS - GEN"
label variable 	educH		"EDUCATION HD"
label variable 	ageW		"AGE WF"
label variable 	raceW1		"RACE WF 1"
label variable 	raceW2		"RACE WF 2"
label variable 	raceW3		"RACE WF 3"
label variable 	raceW4		"RACE WF 4"
label variable 	educW		"EDUCATION WF"
label variable 	limitedH	"LIMITATIONS HD"
label variable 	limitedW	"LIMITATIONS WF"
label variable 	emplH1		"EMPLOYM HD 1"
label variable 	emplH2		"EMPLOYM HD 2"
label variable 	emplH3		"EMPLOYM HD 3"
label variable 	self1H		"SELF EMPL HD CurrMJ-MostRecMJ"
label variable 	self2H		"SELF EMPL HD 2Job"
label variable 	self3H		"SELF EMPL HD 3Job"
label variable 	self4H		"SELF EMPL HD 4Job"
label variable 	selfH		"SELF EMPL HD MainJ"
label variable 	unioncH		"UNION CONTRACT HD"
label variable 	unionizedH	"BELONGS 2 UNION HD"
label variable 	hoursH		"HOURS ANNUAL HD"
label variable 	emplW1		"EMPLOYM WF 1"
label variable 	emplW2		"EMPLOYM WF 2"
label variable 	emplW3		"EMPLOYM WF 3"
label variable 	self1W 		"SELF EMPL WF CurrMJ-MostRecMJ"
label variable 	self2W		"SELF EMPL WF 2Job"
label variable 	self3W		"SELF EMPL WF 3Job"
label variable 	self4W		"SELF EMPL WF 4Job"
label variable 	selfW		"SELF EMPL WF MainJ"
label variable 	unioncW		"UNION CONTRACT WF"
label variable 	unionizedW	"BELONGS 2 UNION WF"
label variable 	hoursW		"HOURS ANNUAL WF"
label variable 	farmerH		"FARMER/RANCHER CMJ HD"
label variable 	fincHW		"FARM INC HD+WF"
label variable 	business	"BUSINESS OWNING?"
label variable 	blincH		"LABOR INC BUSINESS HD"
label variable 	baincH		"ASSET INC BUSINESS HD"
label variable 	lH			"EARNINGS ANNUAL HD"
label variable 	rincH		"RENT INC HD"
label variable 	turincH		"TU RENT INC HD"
label variable 	divH		"DIVIDEND INC HD"
label variable 	tudivH		"TU DIVIDEND INC HD"
label variable 	intH		"INTEREST INC HD"
label variable 	tuintH		"TU INTEREST INC HD"
label variable 	trincH		"TRUST-ROYALTIES INC HD"
label variable 	tutrincH	"TU TRUST-ROYALTIES INC HD"
label variable 	tanfH		"TANF INC HD"
label variable 	tutanfH		"TU TANF INC HD"
label variable 	ssiH		"SOCIAL SEC INC HD"
label variable 	tussiH		"TU SOCIAL SEC INC HD"
label variable 	otherwH		"OTHER WELFARE INC HD"
label variable 	tuotherwH	"TU OTHER WELFARE INC HD"
label variable 	vapH		"VETERAN PENSION INC HD"
label variable 	tuvapH		"TU VETERAN PENSION INC HD"
label variable 	pensH		"PENSIONS HD"
label variable 	tupensH		"TU PENSIONS HD"
label variable 	annuH		"ANNUITIES HD"
label variable 	tuannuH		"TU ANNUITIES HD"
label variable 	otherrH		"OTHER RETIREMENT INC HD"
label variable 	tuotherrH	"TU OTHER RETIREMENT INC HD"
label variable 	uncompH		"UNEMPLOYM COMPENSATION HD"
label variable 	tuuncompH	"TU UNEMPLOYM COMPENSATION HD"
label variable 	wcompH		"WORKERS COMPENSATION HD"
label variable 	tuwcompH	"TU WORKERS COMPENSATION HD"
label variable 	csH			"CHILD SUPPORT HD"
label variable 	tucsH		"TU CHILD SUPPORT HD"
label variable 	alimH		"ALIMONY HD"
label variable 	tualimH		"TU ALIMONY HD"
label variable 	helpfH		"HELP FAMILY HD"
label variable 	tuhelpfH	"TU HELP FAMILY HD"
label variable 	helpoH		"HELP OTHERS HD"
label variable 	tuhelpoH	"TU HELP OTHERS HD"
label variable 	miscH		"MISCELLANEOUS INC HD"
label variable 	tumiscH		"TU MISCELLANEOUS INC HD"
label variable 	blincW		"LABOR INC BUSINESS WF"
label variable 	baincW		"ASSET INC BUSINESS HD"
label variable 	lW			"EARNINGS ANNUAL WF"
label variable 	rincW		"RENT INC WF"
label variable 	turincW		"TU RENT INC WF"
label variable 	divW		"DIVIDEND INC WF"
label variable 	tudivW		"TU DIVIDEND INC WF"
label variable 	intW		"INTEREST INC WF"
label variable 	tuintW		"TU INTEREST INC WF"
label variable 	trincW		"TRUST-ROYALTIES INC WF"
label variable 	tutrincW	"TU TRUST-ROYALTIES INC WF"
label variable 	tanfW		"TANF INC WF"
label variable 	tutanfW		"TU TANF INC WF"
label variable 	ssiW		"SOCIAL SEC INC WF"
label variable 	tussiW		"TU SOCIAL SEC INC WF"
label variable 	otherwW		"OTHER WELFARE INC WF"
label variable 	tuotherwW	"TU OTHER WELFARE INC WF"
label variable 	pensannuW	"PENSIONS-ANNUITIES WF"
label variable 	tupensannuW	"TU PENSIONS-ANNUITIES WF"
label variable 	uncompW		"UNEMPLOYM COMPENSATION WF"
label variable 	tuuncompW	"TU UNEMPLOYM COMPENSATION WF"
label variable 	wcompW		"WORKERS COMPENSATION WF"
label variable 	tuwcompW	"TU WORKERS COMPENSATION WF"
label variable 	csW			"CHILD SUPPORT WF"
label variable 	tucsW		"TU CHILD SUPPORT WF"
label variable 	helpfW		"HELP FAMILY WF"
label variable 	tuhelpfW	"TU HELP FAMILY WF"
label variable 	helpoW		"HELP OTHERS WF"
label variable 	tuhelpoW	"TU HELP OTHERS WF"
label variable 	miscW		"MISCELLANEOUS INC WF"
label variable 	tumiscW		"TU MISCELLANEOUS INC WF"
label variable 	taxincHW	"TAXABLE ANNUAL INCOME HD+WF"
label variable 	tranincHW	"TRANSFER ANNUAL INCOME HD+WF"
label variable 	taxincR		"TAXABLE ANNUAL INCOME OTEHRS"
label variable 	tranincR	"TRANSFER ANNUAL INCOME OTHERS"
label variable 	lumpF		"LUMP SUM PAYMENTS FAMILY"
label variable 	supportF	"HH SUPPORTED OTHERS?"
label variable 	vsupportF	"VALUE SUPPORT OTHERS"
label variable 	incF		"TOTAL ANNUAL INCOME FAMILY"
label variable 	fstmpPY		"RECEIVED FOOD STAMPS PY?"
label variable 	vfstmpPY	"VALUE FOOD STAMPS PY"
label variable 	tufstmpPY	"TU VALUE FOOD STAMPS PY"
label variable 	fstmpCY		"RECEIVED FOOD STAMPS CY?"
label variable 	vstmpCY		"VALUE FOOD STAMPS CY"
label variable 	tufstmpCY	"TU VALUE FOOD STAMPS CY"
label variable 	numfstmp	"# PERSONS ON FOOD STAMPS"
label variable 	fhomefst	"FOOD HOME when FSTAMPS CY"
label variable 	tufhomefst	"TU FOOD HOME when FSTAMPS"
label variable 	fdelfst		"FOOD DEL when FSTAMPS CY"
label variable 	tufdelfst	"TU FOOD DEL when FSTAMPS"
label variable 	foutfst		"FOOD OUT when FSTAMPS CY"
label variable 	tufoutfst	"TU FOOD OUT when FSTAMPS"
label variable 	fhome		"FOOD HOME CY"
label variable 	tufhome		"TU FOOD HOME"
label variable 	fdel		"FOOD DEL CY"
label variable 	tufdel		"TU FOOD DEL"
label variable 	fout		"FOOD OUT CY"
label variable 	tufout		"TU FOOD OUT"
label variable 	hrepair		"HOUSE REPAIRS PY"
label variable 	tuhrepair	"TU HOUSE REPAIRS"
label variable 	furnish		"FURNITURE-EQUIPMENT PY"
label variable 	tufurnish	"TU FURNITURE-EQUIPMENT"
label variable 	clothes		"CLOTHING-APPAREL PY"
label variable 	tuclothes	"TU CLOTHING-APPAREL"
label variable 	holiday		"HOLIDAY EXPENSES PY"
label variable 	tuholiday	"TU HOLIDAY EXPENSES"
label variable 	entertain	"RECREATION-ENTERTAINMENT PY"
label variable 	tuentertain	"TU RECREATION-ENTERTAINMENT"
label variable 	hstatus		"HOUSING STATUS"
label variable 	pubhome		"IN PUBLCI HOUSE?"
label variable 	pvownhome	"PV OWN HOUSE CY"
label variable 	hometax		"PROPERTY TAXES ANNUAL CY"
label variable 	homeinsur	"HOMEOWNERS INSURANCE ANNUAL CY"
label variable 	mortg1		"MONTHLY PAYMENTS 1st MORTGAGE"
label variable 	yrsmortg1	"YEARS TO GO ON 1st MORTGAGE"
label variable 	incltax1	"1st MORTGAGE INCLUDES PROPERTY TAX?"
label variable 	inclinsur1	"1st MORTGAGE INCLUDES HOME INSURANCE?"
label variable 	mortg2		"MONTHLY PAYMENTS 2nd MORTGAGE"
label variable 	yrsmortg2	"YEARS TO GO ON 2nd MORTGAGE"
label variable 	rent		"RENT RENTERS CY"
label variable 	turent		"TU RENT RENTERS"
label variable 	rentif		"RENT IF RENTED CY"
label variable 	turentif	"TU RENT IF RENTED"
label variable 	combined	"COMBINED BILLS? CY"
label variable 	hgas		"HOUSING FUEL/GAS CY"
label variable 	tuhgas		"TU HOUSING FUEL/GAS"
label variable 	elctr		"ELECTRICITY CY"
label variable 	tuelctr		"TU ELECTRICITY"
label variable 	gaselctr	"COMBINED HOUSING FUEL ELECTRICITY CY"
label variable 	tugaselctr	"TU COMBINED HOUSING FUEL ELECTRICITY"
label variable 	water		"WATER SEWER CY"
label variable 	tuwater		"TU WATER SEWER"
label variable 	telecom		"TELECOMMUNICATIONS CY"
label variable 	tutelecom	"TU TELECOMMUNICATIONS"
label variable 	otherutil	"OTHER UTILITIES CY"
label variable 	tuotherutil	"TU OTEHR UTILITIES"
label variable 	ownhealth	"HEALTH INSURANCE P2YPY"
label variable 	nurse		"NURSES-HOSPITALS P2YPY"
label variable 	doctor		"DOCTORS P2YPY"
label variable 	drugs		"PRESCRIPTIONS P2YPY"
label variable 	totalhealth	"TOTAL COST HEALTH (OWN+GVRNMT) P2YPY"
label variable 	vehicle		"VEHICLES OWN OR LEASED?"
label variable 	numvehicle	"# VEHICLES OWN OR LEASED"
label variable 	vinsur		"VEHICLE INSURANCE CY"
label variable 	tuvinsur	"TU VEHICLE INSURANCE"
label variable 	otherveh	"PAYMENTS FOR OLDER VEHICLES"
label variable 	vrepair		"VEHCILE REPAIRS PMonth"
label variable 	vgas		"GASOLINE PMonth"
label variable 	vpark		"PARKING PMonth"
label variable 	bustrain	"BUSES-TRAINS PMonth"
label variable 	taxicabs	"TAXICABS PMonth"
label variable 	othertrans	"OTHER TRANSPORT PMonth"
label variable 	schoolexp	"SCHOOL EXPENSES PY"
label variable 	moreschool	"ADDITIONAL SCHOOL EXPENSES PY"
label variable 	childcare	"CHILDCARE PY"
label variable 	estates		"ASST: OTHER ESTATES CY"
label variable 	wheels		"ASST: VEHICLES CY"
label variable 	farm_bus	"ASST: FARM BUSINESS CY"
label variable 	investm		"ASST: SHARES STOCKS CY"
label variable 	ira_annu	"ASST: IRA ANNUITIES CY"
label variable 	savings		"ASST: SAVINGS CY"
label variable 	otherasset	"ASST: OTHER CY"
label variable 	debts		"DEBTS CY"
label variable  wealth		"NET WEALTH CY"
label variable 	homeequit	"HOME EQUITY CY"
label variable 	year		"YEAR"
label variable 	hpH			"CHORES HD"
label variable 	hpW			"CHORES WF" 	

*	Format variables that facilitate their display in the Data Editor: 
format %10.0g *

*	Save dataset:
compress
save $outputdir/newf1997_2011.dta, replace

***** End of do file *****