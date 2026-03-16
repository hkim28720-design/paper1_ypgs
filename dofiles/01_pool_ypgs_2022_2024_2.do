/****************************************************************************************
 01_pool_ypgs_2022_2024_2.do
 Author   : Kevin Kim
 Project  : Young People and Gambling Survey (YPGS) – Paper 1
 Purpose  : DSM-IV-MR-J score computation 
 Data in  : ypgs_2022_2024_pooled.dta
 Data out : ypgs_2022_2024_pooled.dta
 Notes    : DSM items are considered only for last-12m gamblers (problem1==1).
            Non-gamblers (problem1==0) remain missing on DSM items and totals.

****************************************************************************************/



version 18.0
clear all
set more off

* Set up
cd "/Users/kk/Desktop/Paper_1_main/Data/Processed"
use "ypgs_2022_2024_pooled.dta", clear

*-------------------------------*
* 0) recode '-99' to missing 
*-------------------------------*
foreach v in preocc escape withd tolernce losscon ///
            illegal2 illegal3 illegal4 illegal5 illegal6 ///
            led_ledriskedfam led_ledriskedschl led_ledlying chasing {
    capture confirm variable `v'
    if _rc==0 {
        recode `v' (-99 = .)
    }
}


*-------------------------------*
* 1) Binarise the DSM questionnairs ( Y_j)
*-------------------------------*
capture drop dsm_preocc dsm_escape dsm_withd dsm_toler dsm_losscon ///
             dsm_taken dsm_riskrel dsm_lying dsm_chasing

gen dsm_preocc = .
replace dsm_preocc = 1 if preocc == 4 // `Often'
replace dsm_preocc = 0 if inlist(preocc,1,2,3)
label var dsm_preocc "DSM: Pre-occupation (often=1)"

gen dsm_escape = .
replace dsm_escape = 1 if inlist(escape,3,4) // `Sometimes' or `often'
replace dsm_escape = 0 if inlist(escape,1,2)
label var dsm_escape "DSM: Escape (sometimes/often=1)"

gen dsm_withd = .
replace dsm_withd = 1 if inlist(withd,3,4) // `Sometimes' or `often'
replace dsm_withd = 0 if inlist(withd,1,2,5)
label var dsm_withd "DSM: Withdrawal (sometimes/often=1)"

gen dsm_toler = .
replace dsm_toler = 1 if inlist(tolernce,3,4) // `Sometimes' or `often'
replace dsm_toler = 0 if inlist(tolernce,1,2)
label var dsm_toler "DSM: Tolerance (sometimes/often=1)"

gen dsm_losscon = .
replace dsm_losscon = 1 if inlist(losscon,3,4) // `Sometimes' or `often'
replace dsm_losscon = 0 if inlist(losscon,1,2)
label var dsm_losscon "DSM: Loss of control (sometimes/often=1)"

gen dsm_taken = .
replace dsm_taken = 1 if illegal2==1 | illegal3==1 | illegal4==1 | illegal5==1 | illegal6==1 // If any one or more of these options are ticked, then qualifies for one point in total
replace dsm_taken = 0 if inlist(illegal2,0) & inlist(illegal3,0) & inlist(illegal4,0) & inlist(illegal5,0) & inlist(illegal6,0)
label var dsm_taken "DSM: Taken money (any of illegal2..6=1)"

gen dsm_riskrel = .
replace dsm_riskrel = 1 if inlist(led_ledriskedfam,2,3,4) | inlist(led_ledriskedschl,2,3,4) // If any of the following are ticked, then qualifies for one point in total: `once or twice', `sometimes' or `often'
replace dsm_riskrel = 0 if inlist(led_ledriskedfam,1) & inlist(led_ledriskedschl,1)
label var dsm_riskrel "DSM: Risked relationships (fam/school)"

gen dsm_lying = .
replace dsm_lying = 1 if inlist(led_ledlying,2,3,4) // `Once or twice' `sometimes' or `often'	
replace dsm_lying = 0 if inlist(led_ledlying,1)
label var dsm_lying "DSM: Lying (>= Once or twice, sometimes or often )"

gen dsm_chasing = .
replace dsm_chasing = 1 if inlist(chasing,3,4)   // `More than half the time' or `every time'
replace dsm_chasing = 0 if inlist(chasing,1,2)
label var dsm_chasing "DSM: Chasing (>= More than half the time or every time)"

*-------------------------------*
* 2) Safety: exlcude the respondent never gambled in the last 12m to missing
*-------------------------------*
foreach v in dsm_preocc dsm_escape dsm_withd dsm_toler dsm_losscon dsm_taken dsm_riskrel dsm_lying dsm_chasing {
    replace `v' = . if problem1==0
}

*-------------------------------*
* 3) Aggregate the DSM score 
*-------------------------------*
capture drop dsm_total
egen dsm_total = rowtotal(dsm_preocc dsm_escape dsm_withd dsm_toler dsm_losscon ///
                          dsm_taken dsm_riskrel dsm_lying dsm_chasing)

* Exlcude the respondent never gambled in the last 12m to missing
replace dsm_total = . if problem1==0

* Recode the respondents gambled within the last 12m and answered in the 9 DSM questionnairs: 'PNS', 'NS' as missing 
capture drop __dsm_nmiss
egen __dsm_nmiss = rowmiss(dsm_preocc dsm_escape dsm_withd dsm_toler dsm_losscon ///
                           dsm_taken dsm_riskrel dsm_lying dsm_chasing)
replace dsm_total = . if problem1==1 & __dsm_nmiss==9
drop __dsm_nmiss

* Generate the DSM-IV-MR-J Classification variable 
capture drop dsm_cat
gen dsm_cat = .
replace dsm_cat = 0 if problem1==1 & inrange(dsm_total,0,1)
replace dsm_cat = 1 if problem1==1 & inrange(dsm_total,2,3)
replace dsm_cat = 2 if problem1==1 & dsm_total>=4 & dsm_total<.

label define dsm_cat 0 "Non-problem (0–1)" 1 "At-risk (2–3)" 2 "Problem (4+)", replace
label values dsm_cat dsm_cat
label var dsm_cat "DSM category (gamblers only)"

* QA
tab dsm_total if problem1==1, missing
tab dsm_cat   if problem1==1, missing
assert missing(dsm_total) if problem1==0
assert missing(dsm_cat)   if problem1==0

*-------------------------------*
* 4) Save data
*-------------------------------*
save "ypgs_2022_2024_pooled.dta", replace


****************************************************************************************
* End
****************************************************************************************
