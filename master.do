/*******************************************************************************
master.do
Project : YPGS Paper 1 — Family, Motivation and Harm
Author  : Kevin Kim
Purpose : Run the full replication pipeline from raw data to final outputs

Instructions:
1. Edit ONLY the global root line below.
2. Place raw source files in data/raw.
3. Run this file from Stata.
*******************************************************************************/

version 18.0
clear all
set more off

*--------------------------------------------------------------*
* 1. Root path: edit this line only
*--------------------------------------------------------------*
global root "/Users/kk/Desktop/GitHub/paper1_ypgs"

*--------------------------------------------------------------*
* 2. Relative paths: do not edit
*--------------------------------------------------------------*
global raw       "${root}/data/raw"
global processed "${root}/data/processed"
global dofiles   "${root}/dofiles"
global docs      "${root}/docs"
global output    "${root}/output"
global tables    "${output}/tables"
global figures   "${output}/figures"
global logs      "${root}/log"

cap mkdir "${processed}"
cap mkdir "${output}"
cap mkdir "${tables}"
cap mkdir "${figures}"
cap mkdir "${logs}"

log using "${logs}/master.log", replace text

*--------------------------------------------------------------*
* 3. Run cleaning
*--------------------------------------------------------------*
do "${dofiles}/00_clean_ypgs2022.do"
do "${dofiles}/00_clean_ypgs2023.do"
do "${dofiles}/00_clean_ypgs2024.do"

*--------------------------------------------------------------*
* 4. Run pooled construction
*--------------------------------------------------------------*
do "${dofiles}/01_pool_append.do"
do "${dofiles}/02_construct_dsm.do"
do "${dofiles}/03_construct_motives.do"
do "${dofiles}/04_construct_groups.do"

*--------------------------------------------------------------*
* 5. Main analysis
*--------------------------------------------------------------*
do "${dofiles}/05_analysis_main.do"
do "${dofiles}/06_analysis_mvprobit.do"
do "${dofiles}/07_mi_covariates_robustness.do"


log close
display "Pipeline completed successfully."
