
/****************************************************************************************
 01_pool_ypgs_2022_2024_4.do
 Author   : Kevin Kim
 Project  : Young People and Gambling Survey (YPGS) – Paper 1
 Purpose  : Generate mutually exclusive (non-overlapping) and overlapping gambling groups
 Purpose  : Build gs4y_1–gs4y_17 (routing-safe), overlapping groups (g1/g2/g3)_any,
            and mutually exclusive groups ng, g1_me, g2_me, g3_me, multi
 Notes    : - problem1==1 -> gambled with own money in last 12 months
            - gs4y_k = 1 if GAMSPEND4_k => 1,2,3 or gamspend4smc(k)==1
            - Non-gamblers (problem1==0) remain missing (.) on gs4y_k and group vars

****************************************************************************************/



version 18.0
clear all
set more off

*--------------------------------------------------------------*
* 0) Setup
*--------------------------------------------------------------*
use "${processed}/ypgs_2022_2024_pooled.dta", clear

*--------------------------------------------------------------*
* 1) Last-12m per-activity flags: gs4y_1 ... gs4y_17
*     - Start missing
*     - Set 1 if inlist(gamspend4_k,1,2,3) or smc==1
*     - For asked group (problem1==1), set residual 0
*--------------------------------------------------------------*
capture drop gs4y_1
gen gs4y_1 = .
replace gs4y_1 = 1 if inlist(gamspend4_1,1,2,3) | gamspend4smc1==1
replace gs4y_1 = 0 if problem1==1 & gs4y_1!=1
label var gs4y_1 "Last-12m: Activity 1 (NatLotto)"

capture drop gs4y_2
gen gs4y_2 = .
replace gs4y_2 = 1 if inlist(gamspend4_2,1,2,3) | gamspend4smc2==1
replace gs4y_2 = 0 if problem1==1 & gs4y_2!=1
label var gs4y_2 "Last-12m: Activity 2 (Scratch)"

capture drop gs4y_3
gen gs4y_3 = .
replace gs4y_3 = 1 if inlist(gamspend4_3,1,2,3) | gamspend4smc3==1
replace gs4y_3 = 0 if problem1==1 & gs4y_3!=1
label var gs4y_3 "Last-12m: Activity 3 (Lotto online)"

capture drop gs4y_4
gen gs4y_4 = .
replace gs4y_4 = 1 if inlist(gamspend4_4,1,2,3) | gamspend4smc4==1
replace gs4y_4 = 0 if problem1==1 & gs4y_4!=1
label var gs4y_4 "Last-12m: Activity 4 (Other lotto)"

capture drop gs4y_5
gen gs4y_5 = .
replace gs4y_5 = 1 if inlist(gamspend4_5,1,2,3) | gamspend4smc5==1
replace gs4y_5 = 0 if problem1==1 & gs4y_5!=1
label var gs4y_5 "Last-12m: Activity 5 (Arcade)"

capture drop gs4y_6
gen gs4y_6 = .
replace gs4y_6 = 1 if inlist(gamspend4_6,1,2,3) | gamspend4smc6==1
replace gs4y_6 = 0 if problem1==1 & gs4y_6!=1
label var gs4y_6 "Last-12m: Activity 6 (Fruit/slot)"

capture drop gs4y_7
gen gs4y_7 = .
replace gs4y_7 = 1 if inlist(gamspend4_7,1,2,3) | gamspend4smc7==1
replace gs4y_7 = 0 if problem1==1 & gs4y_7!=1
label var gs4y_7 "Last-12m: Activity 7 (Betting shop)"

capture drop gs4y_8
gen gs4y_8 = .
replace gs4y_8 = 1 if inlist(gamspend4_8,1,2,3) | gamspend4smc8==1
replace gs4y_8 = 0 if problem1==1 & gs4y_8!=1
label var gs4y_8 "Last-12m: Activity 8 (Cards w/ family/friends)"

capture drop gs4y_9
gen gs4y_9 = .
replace gs4y_9 = 1 if inlist(gamspend4_9,1,2,3) | gamspend4smc9==1
replace gs4y_9 = 0 if problem1==1 & gs4y_9!=1
label var gs4y_9 "Last-12m: Activity 9 (Bingo club)"

capture drop gs4y_10
gen gs4y_10 = .
replace gs4y_10 = 1 if inlist(gamspend4_10,1,2,3) | gamspend4smc10==1
replace gs4y_10 = 0 if problem1==1 & gs4y_10!=1
label var gs4y_10 "Last-12m: Activity 10 (Bingo elsewhere)"

capture drop gs4y_11
gen gs4y_11 = .
replace gs4y_11 = 1 if inlist(gamspend4_11,1,2,3) | gamspend4smc11==1
replace gs4y_11 = 0 if problem1==1 & gs4y_11!=1
label var gs4y_11 "Last-12m: Activity 11 (Bingo online)"

capture drop gs4y_12
gen gs4y_12 = .
replace gs4y_12 = 1 if inlist(gamspend4_12,1,2,3) | gamspend4smc12==1
replace gs4y_12 = 0 if problem1==1 & gs4y_12!=1
label var gs4y_12 "Last-12m: Activity 12 (Bet w/ friends/family)"

capture drop gs4y_13
gen gs4y_13 = .
replace gs4y_13 = 1 if inlist(gamspend4_13,1,2,3) | gamspend4smc13==1
replace gs4y_13 = 0 if problem1==1 & gs4y_13!=1
label var gs4y_13 "Last-12m: Activity 13 (eSports betting)"

capture drop gs4y_14
gen gs4y_14 = .
replace gs4y_14 = 1 if inlist(gamspend4_14,1,2,3) | gamspend4smc14==1
replace gs4y_14 = 0 if problem1==1 & gs4y_14!=1
label var gs4y_14 "Last-12m: Activity 14 (Bookies offline)"

capture drop gs4y_15
gen gs4y_15 = .
replace gs4y_15 = 1 if inlist(gamspend4_15,1,2,3) | gamspend4smc15==1
replace gs4y_15 = 0 if problem1==1 & gs4y_15!=1
label var gs4y_15 "Last-12m: Activity 15 (Bet website/app)"

capture drop gs4y_16
gen gs4y_16 = .
replace gs4y_16 = 1 if inlist(gamspend4_16,1,2,3) | gamspend4smc16==1
replace gs4y_16 = 0 if problem1==1 & gs4y_16!=1
label var gs4y_16 "Last-12m: Activity 16 (Casino venue)"

capture drop gs4y_17
gen gs4y_17 = .
replace gs4y_17 = 1 if inlist(gamspend4_17,1,2,3) | gamspend4smc17==1
replace gs4y_17 = 0 if problem1==1 & gs4y_17!=1
label var gs4y_17 "Last-12m: Activity 17 (Casino online)"

*--------------------------------------------------------------*
* 2) Overlapping groups (ANY)
*     g1_any = {5}
*     g2_any = {8,10,12}
*     g3_any = {1,2,3,4,6,7,9,11,13,14,15,16,17}
*     - Missing for non-gamblers
*--------------------------------------------------------------*
capture drop g1_any
gen g1_any = .
replace g1_any = 1 if gs4y_5==1
replace g1_any = 0 if problem1==1 & gs4y_5==0
label define g1_any_lb 0 "No arcade gambling" 1 "Arcade gambler (any)" ,replace
label values g1_any g1_any_lb
label var g1_any "Arcade gambler (any use, overlapping)"

capture drop g2_any
gen g2_any = .
replace g2_any = 1 if (gs4y_8==1 | gs4y_10==1 | gs4y_12==1)
replace g2_any = 0 if problem1==1 & (gs4y_8==0 & gs4y_10==0 & gs4y_12==0)
label define g2_any_lb 0 "No informal/non-age-restricted" 1 "Informal/non-age-restricted (any)", replace
label values g2_any g2_any_lb
label var g2_any "Informal/non-age-restricted gambler (any, overlapping)"

capture drop g3_any
gen g3_any = .
replace g3_any = 1 if ( ///
    gs4y_1==1 | gs4y_2==1 | gs4y_3==1 | gs4y_4==1 | gs4y_6==1 | gs4y_7==1 | ///
    gs4y_9==1 | gs4y_11==1 | gs4y_13==1 | gs4y_14==1 | gs4y_15==1 | ///
    gs4y_16==1 | gs4y_17==1 )
replace g3_any = 0 if problem1==1 & ( ///
    gs4y_1==0 & gs4y_2==0 & gs4y_3==0 & gs4y_4==0 & gs4y_6==0 & gs4y_7==0 & ///
    gs4y_9==0 & gs4y_11==0 & gs4y_13==0 & gs4y_14==0 & gs4y_15==0 & ///
    gs4y_16==0 & gs4y_17==0 )
label define g3_any_lb 0 "No age-restricted/regulated" 1 "Age-restricted/regulated (any)", replace
label values g3_any g3_any_lb
label var g3_any "Age-restricted/regulated gambler (any, overlapping)"



*--------------------------------------------------------------*
* 3) Hierarchical risk-tier partition groups
*--------------------------------------------------------------*
capture drop ng
gen ng = .
replace ng = 1 if problem1==0
replace ng = 0 if problem1==1
label define ng_lb 0 "Gambled last 12m" 1 "Non-gambler (last 12m)", replace
label values ng ng_lb
label var ng "Non-gambler (no own-money gambling in last 12m)"

capture drop g1_me
gen g1_me = .
replace g1_me = 1 if problem1==1 & g1_any==1 & g2_any==0 & g3_any==0
replace g1_me = 0 if problem1==1 & g1_me!=1
label define g1_me_lb 0 "Otherwise" 1 "Arcade-only gambler", replace
label values g1_me g1_me_lb
label var g1_me "Arcade-only gambler (hierarchical risk-tier partition)"

capture drop g2_me
gen g2_me = .
replace g2_me = 1 if problem1==1 & g1_any==1 & g2_any==1 & g3_any==0
replace g2_me = 1 if problem1==1 & g1_any==0 & g2_any==1 & g3_any==0
replace g2_me = 0 if problem1==1 & g2_me!=1 
label define g2_me_lb 0 "Otherwise" 1 "Informal/non-age-restricted (ME)", replace
label values g2_me g2_me_lb
label var g2_me "Informal/non-age-restricted gambler (hierarchical risk-tier partition)"

capture drop g3_me
gen g3_me = .
replace g3_me = 1 if problem1==1 & g3_any==1
replace g3_me = 0 if problem1==1 & g3_me!=1
label define g3_me_lb 0 "Otherwise" 1 "Age-restricted/regulated (ME)", replace
label values g3_me g3_me_lb
label var g3_me "Age-restricted/regulated gambler (hierarchical risk-tier partition)"



*--------------------------------------------------------------*
* 4) Quality check
*--------------------------------------------------------------*
tab problem1
tab g1_any if problem1==1
tab g2_any if problem1==1
tab g3_any if problem1==1
tab g1_me  if problem1==1
tab g2_me  if problem1==1
tab g3_me  if problem1==1


* Partition check (should be exactly one for everyone)
capture drop check_sum
gen check_sum = (ng==1) + (g1_me==1) + (g2_me==1) + (g3_me==1)
tab check_sum, m
* Optional strict assertion:
* assert check_sum==1 if inlist(problem1,0,1)

* If you prefer a catch-all rather than assertion:
* capture drop me_other
* gen me_other = .
* replace me_other = 1 if problem1==1 & g1_me==0 & g2_me==0 & g3_me==0
* label var me_other "Unclassified gambler (no mapped activities)"


*--------------------------------------------------------------*
* 5) Save
*--------------------------------------------------------------*
save "${processed}/ypgs_2022_2024_pooled.dta", replace

/****************************************************************************************
 End of do-file
*****************************************************************************************/
