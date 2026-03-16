/****************************************************************************************
 02_construct_dsm.do
 Author   : Kevin Kim
 Project  : Young People and Gambling Survey (YPGS) – Paper 1
 Purpose  : Construct DSM-IV-MR-J binary criteria, total score, and category
 Data in  : ypgs_2022_2024_pooled.dta
 Data out : ypgs_2022_2024_pooled.dta

 Notes:
 - DSM items are evaluated only for respondents who gambled in the last 12 months
   with their own money (problem1 == 1).
 - Non-gamblers (problem1 != 1) are kept missing on DSM criteria, DSM total, and DSM category.
 - Headline DSM score uses complete-case scoring: gamblers must have nonmissing values on all
   9 DSM criteria to receive dsm_total and dsm_cat.
****************************************************************************************/

version 18.0
clear
set more off

*---------------------------------------------------------------*
* 0. Confirm input file exists and load data
*---------------------------------------------------------------*
capture confirm file "${processed}/ypgs_2022_2024_pooled.dta"
if _rc != 0 {
    di as error "File not found: ${processed}/ypgs_2022_2024_pooled.dta"
    exit 601
}

use "${processed}/ypgs_2022_2024_pooled.dta", clear

*---------------------------------------------------------------*
* 1. Drop old DSM-derived variables if they already exist
*---------------------------------------------------------------*
capture drop dsm_preocc
capture drop dsm_escape
capture drop dsm_withd
capture drop dsm_toler
capture drop dsm_losscon
capture drop dsm_taken
capture drop dsm_riskrel
capture drop dsm_lying
capture drop dsm_chasing
capture drop dsm_total
capture drop dsm_cat
capture drop dsm_complete9
capture drop dsm_nmiss

*---------------------------------------------------------------*
* 2. Construct 9 binary DSM-IV-MR-J criteria
*    Coding follows the raw response labels.
*    Any "prefer not to say", "not stated", or other non-substantive codes remain missing.
*---------------------------------------------------------------*

* 2-1. Pre-occupation: 1 if "Often"
generate byte dsm_preocc = .
replace dsm_preocc = 1 if preocc == 4
replace dsm_preocc = 0 if inlist(preocc, 1, 2, 3)
label var dsm_preocc "DSM criterion: Pre-occupation (often=1)"

* 2-2. Escape: 1 if "Sometimes" or "Often"
generate byte dsm_escape = .
replace dsm_escape = 1 if inlist(escape, 3, 4)
replace dsm_escape = 0 if inlist(escape, 1, 2)
label var dsm_escape "DSM criterion: Escape (sometimes/often=1)"

* 2-3. Withdrawal: 1 if "Sometimes" or "Often"
* Raw coding also includes a substantive "Never try to cut down" category coded separately.
generate byte dsm_withd = .
replace dsm_withd = 1 if inlist(withd, 3, 4)
replace dsm_withd = 0 if inlist(withd, 1, 2, 5)
label var dsm_withd "DSM criterion: Withdrawal (sometimes/often=1)"

* 2-4. Tolerance: 1 if "Sometimes" or "Often"
generate byte dsm_toler = .
replace dsm_toler = 1 if inlist(tolernce, 3, 4)
replace dsm_toler = 0 if inlist(tolernce, 1, 2)
label var dsm_toler "DSM criterion: Tolerance (sometimes/often=1)"

* 2-5. Loss of control: 1 if "Sometimes" or "Often"
generate byte dsm_losscon = .
replace dsm_losscon = 1 if inlist(losscon, 3, 4)
replace dsm_losscon = 0 if inlist(losscon, 1, 2)
label var dsm_losscon "DSM criterion: Loss of control (sometimes/often=1)"

* 2-6. Taken money illegally or from other sources: 1 if any illegal2-illegal6 = 1
generate byte dsm_taken = .
replace dsm_taken = 1 if illegal2 == 1 | illegal3 == 1 | illegal4 == 1 | illegal5 == 1 | illegal6 == 1
replace dsm_taken = 0 if illegal2 == 0 & illegal3 == 0 & illegal4 == 0 & illegal5 == 0 & illegal6 == 0
label var dsm_taken "DSM criterion: Taken money (any illegal source=1)"

* 2-7. Risked relationships / schoolwork: 1 if once or twice, sometimes, or often
generate byte dsm_riskrel = .
replace dsm_riskrel = 1 if inlist(led_ledriskedfam, 2, 3, 4) | inlist(led_ledriskedschl, 2, 3, 4)
replace dsm_riskrel = 0 if led_ledriskedfam == 1 & led_ledriskedschl == 1
label var dsm_riskrel "DSM criterion: Risked family/school relationships"

* 2-8. Lying: 1 if once or twice, sometimes, or often
generate byte dsm_lying = .
replace dsm_lying = 1 if inlist(led_ledlying, 2, 3, 4)
replace dsm_lying = 0 if led_ledlying == 1
label var dsm_lying "DSM criterion: Lying about gambling"

* 2-9. Chasing: 1 if more than half the time or every time
generate byte dsm_chasing = .
replace dsm_chasing = 1 if inlist(chasing, 3, 4)
replace dsm_chasing = 0 if inlist(chasing, 1, 2)
label var dsm_chasing "DSM criterion: Chasing losses"

*---------------------------------------------------------------*
* 3. Safety rule: DSM criteria apply only to last-12-month gamblers
*---------------------------------------------------------------*
replace dsm_preocc   = . if problem1 != 1
replace dsm_escape   = . if problem1 != 1
replace dsm_withd    = . if problem1 != 1
replace dsm_toler    = . if problem1 != 1
replace dsm_losscon  = . if problem1 != 1
replace dsm_taken    = . if problem1 != 1
replace dsm_riskrel  = . if problem1 != 1
replace dsm_lying    = . if problem1 != 1
replace dsm_chasing  = . if problem1 != 1

*---------------------------------------------------------------*
* 4. Complete-case DSM scoring among gamblers
*---------------------------------------------------------------*

* Count missing DSM criteria among gamblers
egen dsm_nmiss = rowmiss(dsm_preocc dsm_escape dsm_withd dsm_toler dsm_losscon ///
                         dsm_taken dsm_riskrel dsm_lying dsm_chasing)
replace dsm_nmiss = . if problem1 != 1
label var dsm_nmiss "Number of missing DSM criteria"

* Indicator for complete DSM information among gamblers
generate byte dsm_complete9 = .
replace dsm_complete9 = 1 if problem1 == 1 & dsm_nmiss == 0
replace dsm_complete9 = 0 if problem1 == 1 & dsm_nmiss > 0
label var dsm_complete9 "Complete DSM information on all 9 criteria (gamblers only)"

* Sum binary criteria
egen dsm_total = rowtotal(dsm_preocc dsm_escape dsm_withd dsm_toler dsm_losscon ///
                          dsm_taken dsm_riskrel dsm_lying dsm_chasing)

* Keep DSM total only for gamblers with complete DSM information
replace dsm_total = . if problem1 != 1
replace dsm_total = . if problem1 == 1 & dsm_nmiss > 0
label var dsm_total "DSM-IV-MR-J total score (0-9, complete-case gamblers only)"

*---------------------------------------------------------------*
* 5. DSM category
*---------------------------------------------------------------*
generate byte dsm_cat = .
replace dsm_cat = 0 if problem1 == 1 & dsm_nmiss == 0 & inrange(dsm_total, 0, 1)
replace dsm_cat = 1 if problem1 == 1 & dsm_nmiss == 0 & inrange(dsm_total, 2, 3)
replace dsm_cat = 2 if problem1 == 1 & dsm_nmiss == 0 & dsm_total >= 4 & dsm_total < .

label define dsm_cat_lbl 0 "Non-problem (0-1)" 1 "At-risk (2-3)" 2 "Problem (4+)", replace
label values dsm_cat dsm_cat_lbl
label var dsm_cat "DSM category (complete-case gamblers only)"

*---------------------------------------------------------------*
* 6. QA checks
*---------------------------------------------------------------*

* Distribution among gamblers
tab dsm_total if problem1 == 1, missing
tab dsm_cat   if problem1 == 1, missing
tab dsm_complete9 if problem1 == 1, missing

* DSM variables must be missing for non-gamblers and missing problem1
assert missing(dsm_preocc)   if problem1 != 1
assert missing(dsm_escape)   if problem1 != 1
assert missing(dsm_withd)    if problem1 != 1
assert missing(dsm_toler)    if problem1 != 1
assert missing(dsm_losscon)  if problem1 != 1
assert missing(dsm_taken)    if problem1 != 1
assert missing(dsm_riskrel)  if problem1 != 1
assert missing(dsm_lying)    if problem1 != 1
assert missing(dsm_chasing)  if problem1 != 1
assert missing(dsm_total)    if problem1 != 1
assert missing(dsm_cat)      if problem1 != 1

* Complete-case scoring checks
assert !missing(dsm_total) if problem1 == 1 & dsm_complete9 == 1
assert missing(dsm_total)  if problem1 == 1 & dsm_complete9 == 0
assert inrange(dsm_total, 0, 9) if !missing(dsm_total)

* Category must exist whenever complete-case total exists
assert !missing(dsm_cat) if !missing(dsm_total)
assert !missing(dsm_cat) if problem1 == 1 & dsm_complete9 == 1
assert missing(dsm_cat)  if problem1 == 1 & dsm_complete9 == 0

tab dsm_total if problem1 == 1 & samp_common == 1, missing
tab dsm_cat   if problem1 == 1 & samp_common == 1, missing



*---------------------------------------------------------------*
* 7. Save data
*---------------------------------------------------------------*
save "${processed}/ypgs_2022_2024_pooled.dta", replace

****************************************************************************************
* End of 02_construct_dsm.do
****************************************************************************************/
