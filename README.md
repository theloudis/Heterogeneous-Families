# Heterogeneous-Families
This repository contains the code that allows replication of my paper **Consumption Inequality across Heterogeneous Families**, 
published at the [_European Economic Review_](https://doi.org/10.1016/j.euroecorev.2021.103765). The paper uses consumption and wage data in the PSID in order to:
* estimate consumption and labor supply preference heterogeneity across households in the US;
* quantify the implications of preference heterogeneity for consumption inequality;
* quantify the implications of preference heterogeneity for consumption partial insurance against permanent and transitory wage shocks.

Apart from the purpose of replicating the paper, the code posted here may also be useful to researchers who want to operationalise and use the rich consumption data in the PSID after 1999.

The journal website of the paper is here: https://doi.org/10.1016/j.euroecorev.2021.103765.

# Replication package details


The replication package has two main parts, the ```STATA``` part and the ```MATLAB``` part, corresponding to data management & preparation (```STATA```) and structural estimation (```MATLAB```) respectively. To run the code, download the replication folder to your computer and update the directories to reflect this folder as I illustrate below.

## Data management & preparation

The code is organized as follows:
* ```HF00_masterfile.do``` sets the computer directories and calls all other do files sequentially. Researchers who want to run the ```STATA``` part of the code need only update the directories to reflect the replication folder on their computer and then run this file. The code runs in a couple of minutes if ```HF12_do_bootstrap.do``` (which obtains the bootstrap samples) is commented out. The rest of the code, including the structural estimation, should run without issues but without estimating standard errors / p-values. The code takes several hours and uses about ```60GB``` of memory if ```HF12_do_bootstrap.do``` is commented in.
* ```HF01_extract_psid_interview.do``` and ```HF02_extract_psid_individual.do``` extract the PSID yearly family files and the cross-year individual file respectively and assemble the panel data. I do not include the raw data files but researchers who want to replicate this part of the code can download them free of charge from the [PSID website](http://psidonline.isr.umich.edu).
* ```HF03_cpi_prices.do``` and ```HF04_selection.do``` merge the panel data with the consumer price index, minimum wages, and US state codes data and carry out baseline data cleaning and selection.
* ```HF05_consumption_assets.do``` harmonizes the consumption and wealth data and produces ```consumption_assets.dta```. ```HF06_bootstrap_sample.do``` carries out the final sample selection and produces ```final_sample.dta```. Data files ```consumption_assets.dta``` and ```final_sample.dta``` are subsequently used in the rest of the program, so I provide these files to assist those researchers who may not want to download the raw data required earlier in the code.
* ```HF07_first_stage.do``` performs the first stage regressions of wages, earnings, consumption on observables; ```HF08_pi_es.do``` estimates &pi;<sub>it</sub> and s<sub>jit</sub>; ```HF09_prepare_gmm.do``` exports the baseline conditional moments used in the structural estimation; ```HF10_m_error.do``` estimates the baseline wage, hours, and earnings measurement error; ```HF11_ratios.do``` estimates the ratios of outcomes used for symmetry of the Frisch elasticities.
* ```HF12_do_bootstrap.do``` carries out block bootstrap on ```final_sample.dta``` and repeats all subsequent steps of the estimation for each bootstrap sample.
* ```HF13_other_m_error.do``` varies the amount of wage, hours, earnings measurement error; ```HF14_age_time.do``` exports moments conditional on age or time; ```HF15_outcome_distribs.do``` exports conditional moments along the distributions of consumption and hours; labor market participation rates are estimated in ```HF16_participation_unconditional.do```; ```HF17_descr_stats.do``` exports table 2 (volatility and skewness) and appendix tables D.1 (descriptive statistics) and D.2 (first stage regressions).

## Structural estimation

The code is organized as follows (researchers who want to replicate this part must first follow the steps in the ```STATA``` part above):
* ```HF_MASTERFIILE.m``` sets the computer directories and calls all other programs sequentially. ```control_switches.m``` sets the program switches and attributes, such as ```do.inference``` (calculation of bootstrap standard errors and p-values) or ```do.wu_krueger``` (simulation of the quantitative model). If these switches are on, the code will likely take several days to complete; if they are off, it should take a few hours depending on the computer specifications. Below I describe how ```HF_MASTERFIILE.m``` proceeds.
* Section 2 of ```HF_MASTERFIILE.m``` reads the data previously created by ```STATA```. It does so twice, first for the baseline data (e.g. tables 4-5 in the paper), then for the data conditional on chores and the age of the youngest child (appendix tables E.3-E.4). For convenience, I provide the baseline data exported by ```STATA``` (named ```X_original_PSID_Y_c1.csv```); for the code to run fully, however, one needs to follow the steps in the ```STATA``` part fully and create all necessary data files.
* Section 3 estimates the empirical moments targeted in the various model specifications and their empirical covariance matrix used in diagonally weighted GMM.
* Section 4 estimates the parameters of the wage process (table 3). It then calls ```do_model.m``` which estimates the model parameters for all specifications that use the baseline data or the data conditional on chores and the age of the youngest child (tables 4-5, appendix tables E.1, E.3-E.7). Finally, it calls ```do_bootstrap.m``` which estimates the standard errors or p-values. If switch ```do.inference==1``` (set inside ```control_switches.m```), ```do_bootstrap.m``` carries out inference over the bootstrap samples created by ```STATA```. If ```do.inference==0```, ```do_bootstrap.m``` reads stored inference results from ```Matlab_dir/exports/results```.
* Section 5 organizes and delivers the previous results (tables 3-5, appendix tables E.1, E.3-E.7), the summary statistics for wealth shares &pi;<sub>it</sub> and s<sub>jit</sub> (appendix table D.3), and the model fit (appendix tables D.4-D.6).
* Section 6 obtains a number of post-estimation results, such as parameter estimates over consumption measurement error, age, time (appendix figures E.1, E.3-E.4), and over the distribution of outcomes (figure 1). It estimates the model addressing time aggregation in the PSID (table G.1) and progressive joint taxation (part of table E.9).
* Section 7 carries out the accounting decomposition of consumption inequality (tables 6 and E.8), estimates the consumption substitution elasticity &eta;<sub>c,p</sub> and how it varies with consumption measurement error (figure E.2), and obtains the distributions of consumption partial insurance (tables 7-8, figure 2, figure E.5).
* Section 8 estimates the model over the samples of wealthy households (part of table E.9) and the sample without extreme observations (appendix table E.2).
* Section 9 solves and simulates the quantitative model of consumption and family labor supply (tables 9-10, appendix table H.1), and calculates the welfare loss of idiosyncratic wage risk (table H.2).
