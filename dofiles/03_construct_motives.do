/****************************************************************************************
 03_construct_motives.do
 Project  : Young People and Gambling Survey (Paper 1)
 Author   : Kevin Kim
 Purpose  : Recode GC_SPENDWHY, construct F1–F13 and Motive1–Motive5
 Data in  : ypgs_2022_2024_pooled.dta
 Data out : ypgs_2022_2024_pooled.dta

 Notes:
 - Respondents not asked motive questions remain missing (.) on F1-F13 and Motive1-Motive5.
 - Headline motive variables are defined for last-12-month gamblers only (problem1 == 1).
 - Binary coding uses rowmax so that all-missing rows stay missing rather than being forced to zero.
****************************************************************************************/

version 18.0
clear
set more off

*-------------------------------------------------------------------------------
* 0. Confirm input file exists and load data
*-------------------------------------------------------------------------------
capture confirm file "${processed}/ypgs_2022_2024_pooled.dta"
if _rc != 0 {
    di as error "File not found: ${processed}/ypgs_2022_2024_pooled.dta"
    exit 601
}

use "${processed}/ypgs_2022_2024_pooled.dta", clear

*-------------------------------------------------------------------------------
* 1. Drop old motive-derived variables if they already exist
*-------------------------------------------------------------------------------
capture drop F1
capture drop F2
capture drop F3
capture drop F4
capture drop F5
capture drop F6
capture drop F7
capture drop F8
capture drop F9
capture drop F10
capture drop F11
capture drop F12
capture drop F13

capture drop Motive1
capture drop Motive2
capture drop Motive3
capture drop Motive4
capture drop Motive5

capture drop motive_nnonmiss
capture drop motive_any_asked

*-------------------------------------------------------------------------------
* 2. Recode non-substantive motive responses
*    Raw files use -99 for not asked / non-substantive responses in these items.
*-------------------------------------------------------------------------------

recode spendwhya_1 spendwhyb_1 spendwhyc_1 spendwhyd_1 spendwhye_1 spendwhyf_1 ///
       spendwhyg_1 spendwhyh_1 spendwhyi_1 spendwhyj_1 spendwhyk_1 spendwhyl_1 ///
       spendwhym_1 spendwhyn_1 spendwhyo_1 spendwhyp_1 spendwhyq_1 (-99=.)

recode spendwhya_4 spendwhyb_4 spendwhyc_4 spendwhyd_4 spendwhye_4 spendwhyf_4 ///
       spendwhyg_4 spendwhyh_4 spendwhyi_4 spendwhyj_4 spendwhyk_4 spendwhyl_4 ///
       spendwhym_4 spendwhyn_4 spendwhyo_4 spendwhyp_4 spendwhyq_4 (-99=.)

recode spendwhya_5 spendwhyb_5 spendwhyc_5 spendwhyd_5 spendwhye_5 spendwhyf_5 ///
       spendwhyg_5 spendwhyh_5 spendwhyi_5 spendwhyj_5 spendwhyk_5 spendwhyl_5 ///
       spendwhym_5 spendwhyn_5 spendwhyo_5 spendwhyp_5 spendwhyq_5 (-99=.)

recode spendwhya_6 spendwhyb_6 spendwhyc_6 spendwhyd_6 spendwhye_6 spendwhyf_6 ///
       spendwhyg_6 spendwhyh_6 spendwhyi_6 spendwhyj_6 spendwhyk_6 spendwhyl_6 ///
       spendwhym_6 spendwhyn_6 spendwhyo_6 spendwhyp_6 spendwhyq_6 (-99=.)

recode spendwhya_7 spendwhyb_7 spendwhyc_7 spendwhyd_7 spendwhye_7 spendwhyf_7 ///
       spendwhyg_7 spendwhyh_7 spendwhyi_7 spendwhyj_7 spendwhyk_7 spendwhyl_7 ///
       spendwhym_7 spendwhyn_7 spendwhyo_7 spendwhyp_7 spendwhyq_7 (-99=.)

recode spendwhya_9 spendwhyb_9 spendwhyc_9 spendwhyd_9 spendwhye_9 spendwhyf_9 ///
       spendwhyg_9 spendwhyh_9 spendwhyi_9 spendwhyj_9 spendwhyk_9 spendwhyl_9 ///
       spendwhym_9 spendwhyn_9 spendwhyo_9 spendwhyp_9 spendwhyq_9 (-99=.)

recode spendwhya_10 spendwhyb_10 spendwhyc_10 spendwhyd_10 spendwhye_10 spendwhyf_10 ///
       spendwhyg_10 spendwhyh_10 spendwhyi_10 spendwhyj_10 spendwhyk_10 spendwhyl_10 ///
       spendwhym_10 spendwhyn_10 spendwhyo_10 spendwhyp_10 spendwhyq_10 (-99=.)

recode spendwhya_11 spendwhyb_11 spendwhyc_11 spendwhyd_11 spendwhye_11 spendwhyf_11 ///
       spendwhyg_11 spendwhyh_11 spendwhyi_11 spendwhyj_11 spendwhyk_11 spendwhyl_11 ///
       spendwhym_11 spendwhyn_11 spendwhyo_11 spendwhyp_11 spendwhyq_11 (-99=.)

recode spendwhya_12 spendwhyb_12 spendwhyc_12 spendwhyd_12 spendwhye_12 spendwhyf_12 ///
       spendwhyg_12 spendwhyh_12 spendwhyi_12 spendwhyj_12 spendwhyk_12 spendwhyl_12 ///
       spendwhym_12 spendwhyn_12 spendwhyo_12 spendwhyp_12 spendwhyq_12 (-99=.)

recode spendwhya_13 spendwhyb_13 spendwhyc_13 spendwhyd_13 spendwhye_13 spendwhyf_13 ///
       spendwhyg_13 spendwhyh_13 spendwhyi_13 spendwhyj_13 spendwhyk_13 spendwhyl_13 ///
       spendwhym_13 spendwhyn_13 spendwhyo_13 spendwhyp_13 spendwhyq_13 (-99=.)

recode spendwhya_14 spendwhyb_14 spendwhyc_14 spendwhyd_14 spendwhye_14 spendwhyf_14 ///
       spendwhyg_14 spendwhyh_14 spendwhyi_14 spendwhyj_14 spendwhyk_14 spendwhyl_14 ///
       spendwhym_14 spendwhyn_14 spendwhyo_14 spendwhyp_14 spendwhyq_14 (-99=.)

recode spendwhya_15 spendwhyb_15 spendwhyc_15 spendwhyd_15 spendwhye_15 spendwhyf_15 ///
       spendwhyg_15 spendwhyh_15 spendwhyi_15 spendwhyj_15 spendwhyk_15 spendwhyl_15 ///
       spendwhym_15 spendwhyn_15 spendwhyo_15 spendwhyp_15 spendwhyq_15 (-99=.)

recode spendwhya_16 spendwhyb_16 spendwhyc_16 spendwhyd_16 spendwhye_16 spendwhyf_16 ///
       spendwhyg_16 spendwhyh_16 spendwhyi_16 spendwhyj_16 spendwhyk_16 spendwhyl_16 ///
       spendwhym_16 spendwhyn_16 spendwhyo_16 spendwhyp_16 spendwhyq_16 (-99=.)

*-------------------------------------------------------------------------------
* 3. Construct 13 motive factors
*    rowmax() returns:
*      1 if any component item = 1
*      0 if at least one component item is observed and all observed items = 0
*      . if all component items are missing
*-------------------------------------------------------------------------------

egen byte F1 = rowmax(spendwhya_1 spendwhyb_1 spendwhyc_1 spendwhyd_1 spendwhye_1 ///
                      spendwhyf_1 spendwhyg_1 spendwhyh_1 spendwhyi_1 spendwhyj_1 ///
                      spendwhyk_1 spendwhyl_1 spendwhym_1 spendwhyn_1 spendwhyo_1 ///
                      spendwhyp_1 spendwhyq_1)
label var F1 "Motive factor 1"

egen byte F2 = rowmax(spendwhya_4 spendwhyb_4 spendwhyc_4 spendwhyd_4 spendwhye_4 ///
                      spendwhyf_4 spendwhyg_4 spendwhyh_4 spendwhyi_4 spendwhyj_4 ///
                      spendwhyk_4 spendwhyl_4 spendwhym_4 spendwhyn_4 spendwhyo_4 ///
                      spendwhyp_4 spendwhyq_4)
label var F2 "Motive factor 2"

egen byte F3 = rowmax(spendwhya_5 spendwhyb_5 spendwhyc_5 spendwhyd_5 spendwhye_5 ///
                      spendwhyf_5 spendwhyg_5 spendwhyh_5 spendwhyi_5 spendwhyj_5 ///
                      spendwhyk_5 spendwhyl_5 spendwhym_5 spendwhyn_5 spendwhyo_5 ///
                      spendwhyp_5 spendwhyq_5)
label var F3 "Motive factor 3"

egen byte F4 = rowmax(spendwhya_6 spendwhyb_6 spendwhyc_6 spendwhyd_6 spendwhye_6 ///
                      spendwhyf_6 spendwhyg_6 spendwhyh_6 spendwhyi_6 spendwhyj_6 ///
                      spendwhyk_6 spendwhyl_6 spendwhym_6 spendwhyn_6 spendwhyo_6 ///
                      spendwhyp_6 spendwhyq_6)
label var F4 "Motive factor 4"

egen byte F5 = rowmax(spendwhya_7 spendwhyb_7 spendwhyc_7 spendwhyd_7 spendwhye_7 ///
                      spendwhyf_7 spendwhyg_7 spendwhyh_7 spendwhyi_7 spendwhyj_7 ///
                      spendwhyk_7 spendwhyl_7 spendwhym_7 spendwhyn_7 spendwhyo_7 ///
                      spendwhyp_7 spendwhyq_7)
label var F5 "Motive factor 5"

egen byte F6 = rowmax(spendwhya_9 spendwhyb_9 spendwhyc_9 spendwhyd_9 spendwhye_9 ///
                      spendwhyf_9 spendwhyg_9 spendwhyh_9 spendwhyi_9 spendwhyj_9 ///
                      spendwhyk_9 spendwhyl_9 spendwhym_9 spendwhyn_9 spendwhyo_9 ///
                      spendwhyp_9 spendwhyq_9)
label var F6 "Motive factor 6"

egen byte F7 = rowmax(spendwhya_10 spendwhyb_10 spendwhyc_10 spendwhyd_10 spendwhye_10 ///
                      spendwhyf_10 spendwhyg_10 spendwhyh_10 spendwhyi_10 spendwhyj_10 ///
                      spendwhyk_10 spendwhyl_10 spendwhym_10 spendwhyn_10 spendwhyo_10 ///
                      spendwhyp_10 spendwhyq_10)
label var F7 "Motive factor 7"

egen byte F8 = rowmax(spendwhya_11 spendwhyb_11 spendwhyc_11 spendwhyd_11 spendwhye_11 ///
                      spendwhyf_11 spendwhyg_11 spendwhyh_11 spendwhyi_11 spendwhyj_11 ///
                      spendwhyk_11 spendwhyl_11 spendwhym_11 spendwhyn_11 spendwhyo_11 ///
                      spendwhyp_11 spendwhyq_11)
label var F8 "Motive factor 8"

egen byte F9 = rowmax(spendwhya_12 spendwhyb_12 spendwhyc_12 spendwhyd_12 spendwhye_12 ///
                      spendwhyf_12 spendwhyg_12 spendwhyh_12 spendwhyi_12 spendwhyj_12 ///
                      spendwhyk_12 spendwhyl_12 spendwhym_12 spendwhyn_12 spendwhyo_12 ///
                      spendwhyp_12 spendwhyq_12)
label var F9 "Motive factor 9"

egen byte F10 = rowmax(spendwhya_13 spendwhyb_13 spendwhyc_13 spendwhyd_13 spendwhye_13 ///
                       spendwhyf_13 spendwhyg_13 spendwhyh_13 spendwhyi_13 spendwhyj_13 ///
                       spendwhyk_13 spendwhyl_13 spendwhym_13 spendwhyn_13 spendwhyo_13 ///
                       spendwhyp_13 spendwhyq_13)
label var F10 "Motive factor 10"

egen byte F11 = rowmax(spendwhya_14 spendwhyb_14 spendwhyc_14 spendwhyd_14 spendwhye_14 ///
                       spendwhyf_14 spendwhyg_14 spendwhyh_14 spendwhyi_14 spendwhyj_14 ///
                       spendwhyk_14 spendwhyl_14 spendwhym_14 spendwhyn_14 spendwhyo_14 ///
                       spendwhyp_14 spendwhyq_14)
label var F11 "Motive factor 11"

egen byte F12 = rowmax(spendwhya_15 spendwhyb_15 spendwhyc_15 spendwhyd_15 spendwhye_15 ///
                       spendwhyf_15 spendwhyg_15 spendwhyh_15 spendwhyi_15 spendwhyj_15 ///
                       spendwhyk_15 spendwhyl_15 spendwhym_15 spendwhyn_15 spendwhyo_15 ///
                       spendwhyp_15 spendwhyq_15)
label var F12 "Motive factor 12"

egen byte F13 = rowmax(spendwhya_16 spendwhyb_16 spendwhyc_16 spendwhyd_16 spendwhye_16 ///
                       spendwhyf_16 spendwhyg_16 spendwhyh_16 spendwhyi_16 spendwhyj_16 ///
                       spendwhyk_16 spendwhyl_16 spendwhym_16 spendwhyn_16 spendwhyo_16 ///
                       spendwhyp_16 spendwhyq_16)
label var F13 "Motive factor 13"

* Keep factor variables missing for non-gamblers
replace F1  = . if problem1 != 1
replace F2  = . if problem1 != 1
replace F3  = . if problem1 != 1
replace F4  = . if problem1 != 1
replace F5  = . if problem1 != 1
replace F6  = . if problem1 != 1
replace F7  = . if problem1 != 1
replace F8  = . if problem1 != 1
replace F9  = . if problem1 != 1
replace F10 = . if problem1 != 1
replace F11 = . if problem1 != 1
replace F12 = . if problem1 != 1
replace F13 = . if problem1 != 1

*-------------------------------------------------------------------------------
* 4. Indicator for whether motive information is observed at all
*-------------------------------------------------------------------------------
egen motive_nnonmiss = rownonmiss(F1 F2 F3 F4 F5 F6 F7 F8 F9 F10 F11 F12 F13)
generate byte motive_any_asked = .
replace motive_any_asked = 1 if problem1 == 1 & motive_nnonmiss > 0
replace motive_any_asked = 0 if problem1 == 1 & motive_nnonmiss == 0
label var motive_any_asked "Any motive information observed (gamblers only)"

replace motive_nnonmiss = . if problem1 != 1
label var motive_nnonmiss "Number of nonmissing motive factors (gamblers only)"

*-------------------------------------------------------------------------------
* 5. Construct 5 motive domains
*    rowmax preserves missing for not-asked respondents
*-------------------------------------------------------------------------------

egen byte Motive1 = rowmax(F1 F2 F10)
label var Motive1 "Monetary / quick fix motive"

egen byte Motive2 = rowmax(F3 F6 F7)
label var Motive2 "Entertainment motive"

egen byte Motive3 = rowmax(F4 F5)
label var Motive3 "Loneliness / social presence motive"

egen byte Motive4 = rowmax(F9 F11 F12 F13)
label var Motive4 "Cognitive motive"

generate byte Motive5 = F8
label var Motive5 "Boredom motive"

* Keep motive variables missing for non-gamblers
replace Motive1 = . if problem1 != 1
replace Motive2 = . if problem1 != 1
replace Motive3 = . if problem1 != 1
replace Motive4 = . if problem1 != 1
replace Motive5 = . if problem1 != 1

*-------------------------------------------------------------------------------
* 6. QA checks
*-------------------------------------------------------------------------------

* Wave sizes
tab survey_year

* Motive information observed among gamblers
tab motive_any_asked if problem1 == 1, missing
tab motive_any_asked if problem1 == 1 & samp_common == 1, missing

* Main motive distributions among gamblers
tab Motive1 if problem1 == 1, missing
tab Motive2 if problem1 == 1, missing
tab Motive3 if problem1 == 1, missing
tab Motive4 if problem1 == 1, missing
tab Motive5 if problem1 == 1, missing

* Main motive distributions in common sample
tab Motive1 if problem1 == 1 & samp_common == 1, missing
tab Motive2 if problem1 == 1 & samp_common == 1, missing
tab Motive3 if problem1 == 1 & samp_common == 1, missing
tab Motive4 if problem1 == 1 & samp_common == 1, missing
tab Motive5 if problem1 == 1 & samp_common == 1, missing

* Non-gamblers should be missing on motive variables
assert missing(F1)  if problem1 != 1
assert missing(F2)  if problem1 != 1
assert missing(F3)  if problem1 != 1
assert missing(F4)  if problem1 != 1
assert missing(F5)  if problem1 != 1
assert missing(F6)  if problem1 != 1
assert missing(F7)  if problem1 != 1
assert missing(F8)  if problem1 != 1
assert missing(F9)  if problem1 != 1
assert missing(F10) if problem1 != 1
assert missing(F11) if problem1 != 1
assert missing(F12) if problem1 != 1
assert missing(F13) if problem1 != 1

assert missing(Motive1) if problem1 != 1
assert missing(Motive2) if problem1 != 1
assert missing(Motive3) if problem1 != 1
assert missing(Motive4) if problem1 != 1
assert missing(Motive5) if problem1 != 1

* Respondents with no motive information should stay missing on motive domains
assert missing(Motive1) if problem1 == 1 & motive_any_asked == 0
assert missing(Motive2) if problem1 == 1 & motive_any_asked == 0
assert missing(Motive3) if problem1 == 1 & motive_any_asked == 0
assert missing(Motive4) if problem1 == 1 & motive_any_asked == 0
assert missing(Motive5) if problem1 == 1 & motive_any_asked == 0

*-------------------------------------------------------------------------------
* 7. Save pooled dataset
*-------------------------------------------------------------------------------
save "${processed}/ypgs_2022_2024_pooled.dta", replace

****************************************************************************************
* End of 03_construct_motives.do
****************************************************************************************/
