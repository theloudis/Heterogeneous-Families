
/*******************************************************************************
	
Masterfile for data management and production in
'Consumption Inequality across Heterogeneous Families'
published at the European Economic Review

For updates to this code, please visit my dedicated GitHub page at
https://github.com/theloudis/Heterogeneous-Families
________________________________________________________________________________

Filename: 	HF00_masterfile.do
Author: 	Alexandros Theloudis (a.theloudis@gmail.com)
			LISER Luxembourg
			Tilburg University, Department of Econometrics & Operations Research
Date: 		Spring 2021

This file calls and executes all the .do files of the data management and
production stages of the paper. The .do files extract and prepare the PSID 
data for the structural estimation in the next stage.

*******************************************************************************/

*	Initial statements:
clear all
set more off
cap log close
macro drop _all

*	Set the path of the raw PSID data. Please change the directory below 
*	to one which your computer can access the raw PSID data from.
global PSIDdir 		= "/Users/atheloudis/Dropbox/_Archive/_Data-Codes-Software/PSID/PSID_dta"

*	Set master directory for code, inputs (except PSID raw data), and output.
*	Please change the directory below to the replication folder on your computer.
global MASTERdir 	= "/Users/atheloudis/Dropbox/Heterogeneous-Families"

*	Set the directory STATA will read from or and save files in:
global STATAdir 	= "$MASTERdir/Stata_dir"

*	Set the directory where the STATA code is:
global DOdir 		= "$STATAdir/do_files"

*	Set the directory STATA will write output data into:
global outputdir 	= "$STATAdir/output"

*	Set the directory STATA will write excel files into:
capture : mkdir "$STATAdir/tables"
global xlsdir 		= "$STATAdir/tables"

*	Set the directory STATA will export data to for use in GMM estimation using Matlab: 
global MATLABdir 	= "$MASTERdir/Matlab_dir/inputs"

*	Generate folders that will hold relevant data 
*	for each model specification/robustness check:
*	-directory where baseline data will be saved (e.g. for tables 3-5, E.1, E.5-E.7):
capture : mkdir "$MATLABdir/_Cond1"
*	-directory where data for tables E.3-E.4 will be saved:
capture : mkdir "$MATLABdir/_Cond2"
*	-directory where data for table E.2 will be saved:
capture : mkdir "$MATLABdir/_Cond_rr1"
capture : mkdir "$MATLABdir/_Cond_rr2"
capture : mkdir "$MATLABdir/_Cond_rr3"
*	-directory where data for table E.8 will be saved:
capture : mkdir "$MATLABdir/_Cond_wr1"
capture : mkdir "$MATLABdir/_Cond_wr2"
capture : mkdir "$MATLABdir/_Cond_wr3"
capture : mkdir "$MATLABdir/_Cond_wr4"
*	-directory for data about measurement error (Appendix E, discussion):
capture : mkdir "$MATLABdir/_Measur_error"
*	-directory where data for figures E.2-E.3 will be saved:
capture : mkdir "$MATLABdir/_Age"
capture : mkdir "$MATLABdir/_Time"
*	-directory where data for figure 1 will be saved:
capture : mkdir "$MATLABdir/_Distribution"

*	Call consecutive '.do' files:
cd $DOdir
do "HF01_extract_psid_interview.do"
cd $DOdir
do "HF02_extract_psid_individual.do"
cd $DOdir
do "HF03_cpi_prices.do"
cd $DOdir
do "HF04_selection.do"
cd $DOdir
do "HF05_consumption_assets.do"
cd $DOdir
do "HF06_bootstrap_sample.do"
cd $DOdir
do "HF07_first_stage.do"
cd $DOdir
do "HF08_pi_es.do"
cd $DOdir
do "HF09_prepare_gmm.do"
cd $DOdir
do "HF10_m_error.do"
cd $DOdir
do "HF11_ratios.do"
cd $DOdir
do "HF12_do_bootstrap.do"
cd $DOdir
do "HF13_other_m_error.do"
cd $DOdir
do "HF14_age_time.do"
cd $DOdir
do "HF15_outcome_distribs.do"
cd $DOdir
do "HF16_participation_unconditional.do"
cd $DOdir
do "HF17_descr_stats.do"
cd $DOdir

***** End of do file *****
