/***********************************************************************
 master.do
 Project : YPGS Paper 1 — Family, Motivation and Harm
 Author  : Kevin Kim
 Purpose : Set globals and run all do-files in sequence
 Note    : ONLY edit the root path below. Everything else is relative.
***********************************************************************/

version 18.0
clear all
set more off

*--------------------------------------------------------------
* 1. ROOT PATH — edit this line only
*--------------------------------------------------------------
* GitHub Desktop default clone location on macOS:
global root "/Users/kk/Desktop/ypgs"

* Co-author or referee would change to their own path, e.g.:
* global root "/Users/newall/Projects/paper1_ypgs"
* global root "C:/Users/stowasser/paper1_ypgs"

*--------------------------------------------------------------
* 2. RELATIVE PATHS — never edit these
*--------------------------------------------------------------
global raw       "${root}/data/raw"
global processed "${root}/data/processed"
global dofiles   "${root}/dofiles"
global output    "${root}/output"
global tables    "${root}/output/tables"
global figures   "${root}/output/figures"
global logs      "${root}/log"

* Create output directories if they don't exist
cap mkdir "${processed}"
cap mkdir "${output}"
cap mkdir "${tables}"
cap mkdir "${figures}"
cap mkdir "${logs}"

*--------------------------------------------------------------
* 3. RUN PIPELINE
*--------------------------------------------------------------
do "${dofiles}/00_clean_ypgs2022_1.do"
do "${dofiles}/00_clean_ypgs2023_2.do"
do "${dofiles}/00_clean_ypgs2024_3.do"
do "${dofiles}/01_pool_ypgs_2022_2024_1.do"
do "${dofiles}/01_pool_ypgs_2022_2024_2.do"
do "${dofiles}/01_pool_ypgs_2022_2024_3.do"
do "${dofiles}/01_pool_ypgs_2022_2024_4.do"
do "${dofiles}/Analysis_main.do"
