/****************************************************************************************
 04_construct_groups.do
 Author   : Kevin Kim
 Project  : Young People and Gambling Survey (YPGS) – Paper 1
 Purpose  : Construct activity flags, overlapping gambling groups, and mutually exclusive
            hierarchical groups for pooled 2022–2024 data
 Data in  : ypgs_2022_2024_pooled.dta
 Data out : ypgs_2022_2024_pooled.dta

 Notes:
 - problem1 == 1 indicates gambled with own money in the last 12 months.
 - gs4y_1-gs4y_17 correspond to substantive gambling activities.
 - gamspend4smc18 is a residual "None of these" summary item and is NOT treated
   as a gambling activity.
 - Non-gamblers (problem1 != 1) remain missing on activity flags and overlapping /
   mutually exclusive gambler-group variables. The exception is ng, which is an
   explicit non-gambler indicator.
 - Activity flags are coded conservatively:
     1 if either source indicates participation
     0 if no source indicates participation and at least one source explicitly indicates no
     . if both sources are missing
****************************************************************************************/

version 18.0
clear
set more off

*--------------------------------------------------------------*
* 0. Confirm input file exists and load data
*--------------------------------------------------------------*
capture confirm file "${processed}/ypgs_2022_2024_pooled.dta"
if _rc != 0 {
    di as error "File not found: ${processed}/ypgs_2022_2024_pooled.dta"
    exit 601
}

use "${processed}/ypgs_2022_2024_pooled.dta", clear

*--------------------------------------------------------------*
* 1. Drop old derived variables if they already exist
*--------------------------------------------------------------*
capture drop gs4y_1
capture drop gs4y_2
capture drop gs4y_3
capture drop gs4y_4
capture drop gs4y_5
capture drop gs4y_6
capture drop gs4y_7
capture drop gs4y_8
capture drop gs4y_9
capture drop gs4y_10
capture drop gs4y_11
capture drop gs4y_12
capture drop gs4y_13
capture drop gs4y_14
capture drop gs4y_15
capture drop gs4y_16
capture drop gs4y_17

capture drop g1_any
capture drop g2_any
capture drop g3_any

capture drop ng
capture drop g0_me
capture drop g1_me
capture drop g2_me
capture drop g3_me
capture drop multi

capture drop group_complete3
capture drop n_any_groups
capture drop any_gs4y
capture drop partition_sum

*--------------------------------------------------------------*
* 2. Recode non-substantive activity values to missing
*--------------------------------------------------------------*
recode gamspend4_1 gamspend4_2 gamspend4_3 gamspend4_4 gamspend4_5 ///
       gamspend4_6 gamspend4_7 gamspend4_8 gamspend4_9 gamspend4_10 ///
       gamspend4_11 gamspend4_12 gamspend4_13 gamspend4_14 gamspend4_15 ///
       gamspend4_16 gamspend4_17 (-99=.)

recode gamspend4smc1 gamspend4smc2 gamspend4smc3 gamspend4smc4 gamspend4smc5 ///
       gamspend4smc6 gamspend4smc7 gamspend4smc8 gamspend4smc9 gamspend4smc10 ///
       gamspend4smc11 gamspend4smc12 gamspend4smc13 gamspend4smc14 gamspend4smc15 ///
       gamspend4smc16 gamspend4smc17 gamspend4smc18 (-99=.)

*--------------------------------------------------------------*
* 3. Last-12m activity flags: gs4y_1 ... gs4y_17
*
* Rule:
*   1 if gamspend4_k in {1,2,3} OR gamspend4smck == 1
*   0 if neither source says yes and at least one source says no
*   . if both sources are missing
*--------------------------------------------------------------*

generate byte gs4y_1 = .
replace gs4y_1 = 1 if inlist(gamspend4_1, 1, 2, 3) | gamspend4smc1 == 1
replace gs4y_1 = 0 if gs4y_1 != 1 & ((!missing(gamspend4_1) & !inlist(gamspend4_1, 1, 2, 3)) | gamspend4smc1 == 0)
replace gs4y_1 = . if problem1 != 1
label var gs4y_1 "Last-12m activity 1: National Lottery draw"

generate byte gs4y_2 = .
replace gs4y_2 = 1 if inlist(gamspend4_2, 1, 2, 3) | gamspend4smc2 == 1
replace gs4y_2 = 0 if gs4y_2 != 1 & ((!missing(gamspend4_2) & !inlist(gamspend4_2, 1, 2, 3)) | gamspend4smc2 == 0)
replace gs4y_2 = . if problem1 != 1
label var gs4y_2 "Last-12m activity 2: Scratchcards"

generate byte gs4y_3 = .
replace gs4y_3 = 1 if inlist(gamspend4_3, 1, 2, 3) | gamspend4smc3 == 1
replace gs4y_3 = 0 if gs4y_3 != 1 & ((!missing(gamspend4_3) & !inlist(gamspend4_3, 1, 2, 3)) | gamspend4smc3 == 0)
replace gs4y_3 = . if problem1 != 1
label var gs4y_3 "Last-12m activity 3: Lottery online"

generate byte gs4y_4 = .
replace gs4y_4 = 1 if inlist(gamspend4_4, 1, 2, 3) | gamspend4smc4 == 1
replace gs4y_4 = 0 if gs4y_4 != 1 & ((!missing(gamspend4_4) & !inlist(gamspend4_4, 1, 2, 3)) | gamspend4smc4 == 0)
replace gs4y_4 = . if problem1 != 1
label var gs4y_4 "Last-12m activity 4: Other lotteries"

generate byte gs4y_5 = .
replace gs4y_5 = 1 if inlist(gamspend4_5, 1, 2, 3) | gamspend4smc5 == 1
replace gs4y_5 = 0 if gs4y_5 != 1 & ((!missing(gamspend4_5) & !inlist(gamspend4_5, 1, 2, 3)) | gamspend4smc5 == 0)
replace gs4y_5 = . if problem1 != 1
label var gs4y_5 "Last-12m activity 5: Arcade gaming machines"

generate byte gs4y_6 = .
replace gs4y_6 = 1 if inlist(gamspend4_6, 1, 2, 3) | gamspend4smc6 == 1
replace gs4y_6 = 0 if gs4y_6 != 1 & ((!missing(gamspend4_6) & !inlist(gamspend4_6, 1, 2, 3)) | gamspend4smc6 == 0)
replace gs4y_6 = . if problem1 != 1
label var gs4y_6 "Last-12m activity 6: Fruit / slot machines"

generate byte gs4y_7 = .
replace gs4y_7 = 1 if inlist(gamspend4_7, 1, 2, 3) | gamspend4smc7 == 1
replace gs4y_7 = 0 if gs4y_7 != 1 & ((!missing(gamspend4_7) & !inlist(gamspend4_7, 1, 2, 3)) | gamspend4smc7 == 0)
replace gs4y_7 = . if problem1 != 1
label var gs4y_7 "Last-12m activity 7: Betting shop"

generate byte gs4y_8 = .
replace gs4y_8 = 1 if inlist(gamspend4_8, 1, 2, 3) | gamspend4smc8 == 1
replace gs4y_8 = 0 if gs4y_8 != 1 & ((!missing(gamspend4_8) & !inlist(gamspend4_8, 1, 2, 3)) | gamspend4smc8 == 0)
replace gs4y_8 = . if problem1 != 1
label var gs4y_8 "Last-12m activity 8: Playing cards for money"

generate byte gs4y_9 = .
replace gs4y_9 = 1 if inlist(gamspend4_9, 1, 2, 3) | gamspend4smc9 == 1
replace gs4y_9 = 0 if gs4y_9 != 1 & ((!missing(gamspend4_9) & !inlist(gamspend4_9, 1, 2, 3)) | gamspend4smc9 == 0)
replace gs4y_9 = . if problem1 != 1
label var gs4y_9 "Last-12m activity 9: Bingo at a bingo club"

generate byte gs4y_10 = .
replace gs4y_10 = 1 if inlist(gamspend4_10, 1, 2, 3) | gamspend4smc10 == 1
replace gs4y_10 = 0 if gs4y_10 != 1 & ((!missing(gamspend4_10) & !inlist(gamspend4_10, 1, 2, 3)) | gamspend4smc10 == 0)
replace gs4y_10 = . if problem1 != 1
label var gs4y_10 "Last-12m activity 10: Bingo elsewhere"

generate byte gs4y_11 = .
replace gs4y_11 = 1 if inlist(gamspend4_11, 1, 2, 3) | gamspend4smc11 == 1
replace gs4y_11 = 0 if gs4y_11 != 1 & ((!missing(gamspend4_11) & !inlist(gamspend4_11, 1, 2, 3)) | gamspend4smc11 == 0)
replace gs4y_11 = . if problem1 != 1
label var gs4y_11 "Last-12m activity 11: Bingo online"

generate byte gs4y_12 = .
replace gs4y_12 = 1 if inlist(gamspend4_12, 1, 2, 3) | gamspend4smc12 == 1
replace gs4y_12 = 0 if gs4y_12 != 1 & ((!missing(gamspend4_12) & !inlist(gamspend4_12, 1, 2, 3)) | gamspend4smc12 == 0)
replace gs4y_12 = . if problem1 != 1
label var gs4y_12 "Last-12m activity 12: Betting with friends/family"

generate byte gs4y_13 = .
replace gs4y_13 = 1 if inlist(gamspend4_13, 1, 2, 3) | gamspend4smc13 == 1
replace gs4y_13 = 0 if gs4y_13 != 1 & ((!missing(gamspend4_13) & !inlist(gamspend4_13, 1, 2, 3)) | gamspend4smc13 == 0)
replace gs4y_13 = . if problem1 != 1
label var gs4y_13 "Last-12m activity 13: Betting on eSports"

generate byte gs4y_14 = .
replace gs4y_14 = 1 if inlist(gamspend4_14, 1, 2, 3) | gamspend4smc14 == 1
replace gs4y_14 = 0 if gs4y_14 != 1 & ((!missing(gamspend4_14) & !inlist(gamspend4_14, 1, 2, 3)) | gamspend4smc14 == 0)
replace gs4y_14 = . if problem1 != 1
label var gs4y_14 "Last-12m activity 14: Betting shop / bookies offline"

generate byte gs4y_15 = .
replace gs4y_15 = 1 if inlist(gamspend4_15, 1, 2, 3) | gamspend4smc15 == 1
replace gs4y_15 = 0 if gs4y_15 != 1 & ((!missing(gamspend4_15) & !inlist(gamspend4_15, 1, 2, 3)) | gamspend4smc15 == 0)
replace gs4y_15 = . if problem1 != 1
label var gs4y_15 "Last-12m activity 15: Betting website/app"

generate byte gs4y_16 = .
replace gs4y_16 = 1 if inlist(gamspend4_16, 1, 2, 3) | gamspend4smc16 == 1
replace gs4y_16 = 0 if gs4y_16 != 1 & ((!missing(gamspend4_16) & !inlist(gamspend4_16, 1, 2, 3)) | gamspend4smc16 == 0)
replace gs4y_16 = . if problem1 != 1
label var gs4y_16 "Last-12m activity 16: Casino venue"

generate byte gs4y_17 = .
replace gs4y_17 = 1 if inlist(gamspend4_17, 1, 2, 3) | gamspend4smc17 == 1
replace gs4y_17 = 0 if gs4y_17 != 1 & ((!missing(gamspend4_17) & !inlist(gamspend4_17, 1, 2, 3)) | gamspend4smc17 == 0)
replace gs4y_17 = . if problem1 != 1
label var gs4y_17 "Last-12m activity 17: Casino online"

*--------------------------------------------------------------*
* 4. Overlapping groups (ANY)
*
* Group definitions:
*   g1_any = {5}
*   g2_any = {8,10,12}
*   g3_any = {1,2,3,4,6,7,9,11,13,14,15,16,17}
*
* Coding:
*   1 if any constituent activity == 1
*   0 if all constituent activities == 0
*   . otherwise
*--------------------------------------------------------------*

generate byte g1_any = .
replace g1_any = 1 if gs4y_5 == 1
replace g1_any = 0 if gs4y_5 == 0
replace g1_any = . if problem1 != 1
label define g1_any_lb 0 "No arcade gambling" 1 "Arcade gambling (any)", replace
label values g1_any g1_any_lb
label var g1_any "Arcade gambling (overlapping)"

generate byte g2_any = .
replace g2_any = 1 if gs4y_8 == 1 | gs4y_10 == 1 | gs4y_12 == 1
replace g2_any = 0 if gs4y_8 == 0 & gs4y_10 == 0 & gs4y_12 == 0
replace g2_any = . if problem1 != 1
label define g2_any_lb 0 "No informal gambling" 1 "Informal gambling (any)", replace
label values g2_any g2_any_lb
label var g2_any "Informal / non-age-restricted gambling (overlapping)"

generate byte g3_any = .
replace g3_any = 1 if gs4y_1 == 1 | gs4y_2 == 1 | gs4y_3 == 1 | gs4y_4 == 1 | ///
                     gs4y_6 == 1 | gs4y_7 == 1 | gs4y_9 == 1 | gs4y_11 == 1 | ///
                     gs4y_13 == 1 | gs4y_14 == 1 | gs4y_15 == 1 | gs4y_16 == 1 | ///
                     gs4y_17 == 1
replace g3_any = 0 if gs4y_1 == 0 & gs4y_2 == 0 & gs4y_3 == 0 & gs4y_4 == 0 & ///
                     gs4y_6 == 0 & gs4y_7 == 0 & gs4y_9 == 0 & gs4y_11 == 0 & ///
                     gs4y_13 == 0 & gs4y_14 == 0 & gs4y_15 == 0 & gs4y_16 == 0 & ///
                     gs4y_17 == 0
replace g3_any = . if problem1 != 1
label define g3_any_lb 0 "No age-restricted gambling" 1 "Age-restricted gambling (any)", replace
label values g3_any g3_any_lb
label var g3_any "Age-restricted / regulated gambling (overlapping)"

*--------------------------------------------------------------*
* 5. Auxiliary completeness and overlap summaries
*--------------------------------------------------------------*

generate byte group_complete3 = .
replace group_complete3 = 1 if problem1 == 1 & !missing(g1_any) & !missing(g2_any) & !missing(g3_any)
replace group_complete3 = 0 if problem1 == 1 & (missing(g1_any) | missing(g2_any) | missing(g3_any))
label var group_complete3 "Complete information on g1_any, g2_any, g3_any (gamblers only)"

egen byte n_any_groups = rowtotal(g1_any g2_any g3_any)
replace n_any_groups = . if problem1 != 1 | group_complete3 != 1
label var n_any_groups "Number of overlapping gambling groups (complete gamblers only)"

egen byte any_gs4y = rowmax(gs4y_1 gs4y_2 gs4y_3 gs4y_4 gs4y_5 gs4y_6 gs4y_7 ///
                            gs4y_8 gs4y_9 gs4y_10 gs4y_11 gs4y_12 gs4y_13 gs4y_14 ///
                            gs4y_15 gs4y_16 gs4y_17)
replace any_gs4y = . if problem1 != 1
label var any_gs4y "Any mapped gambling activity in last 12 months"

generate byte multi = .
replace multi = 1 if problem1 == 1 & group_complete3 == 1 & n_any_groups >= 2
replace multi = 0 if problem1 == 1 & group_complete3 == 1 & n_any_groups < 2
label define multi_lb 0 "Single / none" 1 "Multiple group overlap", replace
label values multi multi_lb
label var multi "Multiple overlapping gambling groups (complete gamblers only)"

*--------------------------------------------------------------*
* 6. Mutually exclusive hierarchical partition
*
* Hierarchy:
*   ng    = non-gambler
*   g0_me = gambler with no mapped group
*   g1_me = arcade only
*   g2_me = informal (with or without arcade), but no regulated gambling
*   g3_me = any regulated gambling
*
* This partition is exhaustive among:
*   - non-gamblers with problem1 == 0
*   - gamblers with complete group information
*--------------------------------------------------------------*

generate byte ng = .
replace ng = 1 if problem1 == 0
replace ng = 0 if problem1 == 1
label define ng_lb 0 "Gambled last 12m" 1 "Non-gambler", replace
label values ng ng_lb
label var ng "Non-gambler indicator"

generate byte g0_me = .
replace g0_me = 1 if problem1 == 1 & group_complete3 == 1 & n_any_groups == 0
replace g0_me = 0 if problem1 == 1 & group_complete3 == 1 & g0_me != 1
label define g0_me_lb 0 "Otherwise" 1 "Gambler with no mapped activity group", replace
label values g0_me g0_me_lb
label var g0_me "Gambler with no mapped activity group (ME diagnostic)"

generate byte g1_me = .
replace g1_me = 1 if problem1 == 1 & group_complete3 == 1 & g1_any == 1 & g2_any == 0 & g3_any == 0
replace g1_me = 0 if problem1 == 1 & group_complete3 == 1 & g1_me != 1
label define g1_me_lb 0 "Otherwise" 1 "Arcade-only", replace
label values g1_me g1_me_lb
label var g1_me "Arcade-only gambler (mutually exclusive)"

generate byte g2_me = .
replace g2_me = 1 if problem1 == 1 & group_complete3 == 1 & g3_any == 0 & g2_any == 1
replace g2_me = 0 if problem1 == 1 & group_complete3 == 1 & g2_me != 1
label define g2_me_lb 0 "Otherwise" 1 "Informal/non-age-restricted", replace
label values g2_me g2_me_lb
label var g2_me "Informal / non-age-restricted gambler (mutually exclusive)"

generate byte g3_me = .
replace g3_me = 1 if problem1 == 1 & group_complete3 == 1 & g3_any == 1
replace g3_me = 0 if problem1 == 1 & group_complete3 == 1 & g3_me != 1
label define g3_me_lb 0 "Otherwise" 1 "Age-restricted/regulated", replace
label values g3_me g3_me_lb
label var g3_me "Age-restricted / regulated gambler (mutually exclusive)"

*--------------------------------------------------------------*
* 7. Quality checks
*--------------------------------------------------------------*

tab problem1, missing

tab g1_any if problem1 == 1, missing
tab g2_any if problem1 == 1, missing
tab g3_any if problem1 == 1, missing

tab group_complete3 if problem1 == 1, missing
tab multi if problem1 == 1, missing

tab g0_me if problem1 == 1, missing
tab g1_me if problem1 == 1, missing
tab g2_me if problem1 == 1, missing
tab g3_me if problem1 == 1, missing

tab g1_any if problem1 == 1 & samp_common == 1, missing
tab g2_any if problem1 == 1 & samp_common == 1, missing
tab g3_any if problem1 == 1 & samp_common == 1, missing

tab g1_me if problem1 == 1 & samp_common == 1, missing
tab g2_me if problem1 == 1 & samp_common == 1, missing
tab g3_me if problem1 == 1 & samp_common == 1, missing

* Partition check
generate byte partition_sum = (ng == 1) + (g0_me == 1) + (g1_me == 1) + (g2_me == 1) + (g3_me == 1)
tab partition_sum, missing

* Exhaustive partition among non-gamblers and gamblers with complete group information
assert partition_sum == 1 if problem1 == 0
assert partition_sum == 1 if problem1 == 1 & group_complete3 == 1

* Non-gamblers should be missing on gambler-group variables
assert missing(gs4y_1)  if problem1 != 1
assert missing(gs4y_2)  if problem1 != 1
assert missing(gs4y_3)  if problem1 != 1
assert missing(gs4y_4)  if problem1 != 1
assert missing(gs4y_5)  if problem1 != 1
assert missing(gs4y_6)  if problem1 != 1
assert missing(gs4y_7)  if problem1 != 1
assert missing(gs4y_8)  if problem1 != 1
assert missing(gs4y_9)  if problem1 != 1
assert missing(gs4y_10) if problem1 != 1
assert missing(gs4y_11) if problem1 != 1
assert missing(gs4y_12) if problem1 != 1
assert missing(gs4y_13) if problem1 != 1
assert missing(gs4y_14) if problem1 != 1
assert missing(gs4y_15) if problem1 != 1
assert missing(gs4y_16) if problem1 != 1
assert missing(gs4y_17) if problem1 != 1

assert missing(g1_any) if problem1 != 1
assert missing(g2_any) if problem1 != 1
assert missing(g3_any) if problem1 != 1
assert missing(g0_me)  if problem1 != 1
assert missing(g1_me)  if problem1 != 1
assert missing(g2_me)  if problem1 != 1
assert missing(g3_me)  if problem1 != 1
assert missing(multi)  if problem1 != 1

* Relationship between residual "none of these" flag and mapped activities
tab gamspend4smc18 if problem1 == 1, missing
tab gamspend4smc18 any_gs4y if problem1 == 1, missing

*--------------------------------------------------------------*
* 8. Save
*--------------------------------------------------------------*
save "${processed}/ypgs_2022_2024_pooled.dta", replace

/****************************************************************************************
 End of 04_construct_groups.do
****************************************************************************************/
