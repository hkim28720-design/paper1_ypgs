/****************************************************************************************
 01_pool_ypgs_2022_2024_3.do
 Project  : Young People and Gambling Survey (Paper 1)
 Author   : Kevin Kim
 Purpose  : Pool waves, recode GC_SPENDWHY, construct F1–F13 and Motive1–Motive5
 Notes    : - Respondents NOT ASKED motives remain missing (.) to avoid bias
****************************************************************************************/



*-------------------------------------------------------------------------------
* 0. Set up
*-------------------------------------------------------------------------------
cd "/Users/kk/Desktop/Paper_1_main/Data/Processed"
version 18.0
clear all
set more off

*-------------------------------------------------------------------------------
* 1. Import Pool 2022–2024 repeated cross-sections
*-------------------------------------------------------------------------------
use "ypgs_2022_2024_pooled.dta", clear

* quick QA: wave sizes
tab survey_year


*********************************************************
*
***Create variables for gambling motivational factors 
*
*********************************************************

*GC_SPENDWHY
recode spendwhya_1 (-99=.) //  National Lottery draw
recode spendwhya_4 (-99=.) 
recode spendwhya_5 (-99=.) 
recode spendwhya_6 (-99=.) 
recode spendwhya_7  (-99=.) 
recode spendwhya_9 (-99=.) 
recode spendwhya_10 (-99=.) 
recode spendwhya_11 (-99=.) 
recode spendwhya_12 (-99=.) 
recode spendwhya_13 (-99=.) 
recode spendwhya_14 (-99=.) 
recode spendwhya_15 (-99=.) 
recode spendwhya_16 (-99=.) 

recode spendwhyb_1 (-99=.) // Scratchcards
recode spendwhyb_4 (-99=.) 
recode spendwhyb_5 (-99=.) 
recode spendwhyb_6 (-99=.) 
recode spendwhyb_7 (-99=.) 
recode spendwhyb_9 (-99=.) 
recode spendwhyb_10 (-99=.) 
recode spendwhyb_11 (-99=.) 
recode spendwhyb_12 (-99=.) 
recode spendwhyb_13 (-99=.) 
recode spendwhyb_14 (-99=.) 
recode spendwhyb_15 (-99=.) 
recode spendwhyb_16 (-99=.) 

recode spendwhyc_1  (-99=.) // Lottery online 
recode spendwhyc_4 (-99=.) 
recode spendwhyc_5 (-99=.) 
recode spendwhyc_6 (-99=.) 
recode spendwhyc_7  (-99=.) 
recode spendwhyc_9 (-99=.) 
recode spendwhyc_10 (-99=.) 
recode spendwhyc_11 (-99=.) 
recode spendwhyc_12 (-99=.) 
recode spendwhyc_13 (-99=.) 
recode spendwhyc_14 (-99=.) 
recode spendwhyc_15 (-99=.) 
recode spendwhyc_16 (-99=.)

recode spendwhyd_1 (-99=.) //  Other Lotteries  
recode spendwhyd_4 (-99=.) 
recode spendwhyd_5 (-99=.) 
recode spendwhyd_6 (-99=.) 
recode spendwhyd_7  (-99=.) 
recode spendwhyd_9 (-99=.) 
recode spendwhyd_10 (-99=.) 
recode spendwhyd_11 (-99=.) 
recode spendwhyd_12 (-99=.) 
recode spendwhyd_13 (-99=.) 
recode spendwhyd_14 (-99=.) 
recode spendwhyd_15 (-99=.) 
recode spendwhyd_16 (-99=.)

recode spendwhye_1 (-99=.) // arcade gaming machines 
recode spendwhye_4 (-99=.) 
recode spendwhye_5 (-99=.) 
recode spendwhye_6 (-99=.) 
recode spendwhye_7  (-99=.) 
recode spendwhye_9 (-99=.) 
recode spendwhye_10 (-99=.) 
recode spendwhye_11 (-99=.) 
recode spendwhye_12 (-99=.) 
recode spendwhye_13 (-99=.) 
recode spendwhye_14 (-99=.) 
recode spendwhye_15 (-99=.) 
recode spendwhye_16 (-99=.) 

recode spendwhyf_1   (-99=.) // fruit or slot machines
recode spendwhyf_4 (-99=.) 
recode spendwhyf_5 (-99=.) 
recode spendwhyf_6 (-99=.) 
recode spendwhyf_7  (-99=.) 
recode spendwhyf_9 (-99=.) 
recode spendwhyf_10 (-99=.) 
recode spendwhyf_11 (-99=.) 
recode spendwhyf_12 (-99=.) 
recode spendwhyf_13 (-99=.) 
recode spendwhyf_14 (-99=.) 
recode spendwhyf_15 (-99=.) 
recode spendwhyf_16 (-99=.) 

recode spendwhyg_1 (-99=.) // betting shop
recode spendwhyg_4 (-99=.) 
recode spendwhyg_5 (-99=.) 
recode spendwhyg_6 (-99=.) 
recode spendwhyg_7  (-99=.) 
recode spendwhyg_9 (-99=.) 
recode spendwhyg_10 (-99=.) 
recode spendwhyg_11 (-99=.) 
recode spendwhyg_12 (-99=.) 
recode spendwhyg_13 (-99=.) 
recode spendwhyg_14 (-99=.) 
recode spendwhyg_15 (-99=.) 
recode spendwhyg_16 (-99=.) 

recode spendwhyh_1   (-99=.) // Playing cards for money w/ fam
recode spendwhyh_4 (-99=.) 
recode spendwhyh_5 (-99=.)  
recode spendwhyh_6 (-99=.) 
recode spendwhyh_7  (-99=.) 
recode spendwhyh_9 (-99=.) 
recode spendwhyh_10 (-99=.) 
recode spendwhyh_11 (-99=.) 
recode spendwhyh_12 (-99=.) 
recode spendwhyh_13 (-99=.) 
recode spendwhyh_14 (-99=.) 
recode spendwhyh_15 (-99=.) 
recode spendwhyh_16 (-99=.)

recode spendwhyi_1   (-99=.) // bingo at a bingo club
recode spendwhyi_4 (-99=.) 
recode spendwhyi_5 (-99=.) 
recode spendwhyi_6 (-99=.) 
recode spendwhyi_7  (-99=.) 
recode spendwhyi_9 (-99=.) 
recode spendwhyi_10 (-99=.) 
recode spendwhyi_11 (-99=.) 
recode spendwhyi_12 (-99=.) 
recode spendwhyi_13 (-99=.) 
recode spendwhyi_14 (-99=.) 
recode spendwhyi_15 (-99=.) 
recode spendwhyi_16 (-99=.)

recode spendwhyj_1    (-99=.) // bingo at somewhere 
recode spendwhyj_4  (-99=.) 
recode spendwhyj_5  (-99=.) 
recode spendwhyj_6  (-99=.) 
recode spendwhyj_7   (-99=.) 
recode spendwhyj_9  (-99=.) 
recode spendwhyj_10  (-99=.) 
recode spendwhyj_11  (-99=.) 
recode spendwhyj_12  (-99=.) 
recode spendwhyj_13  (-99=.) 
recode spendwhyj_14  (-99=.) 
recode spendwhyj_15  (-99=.) 
recode spendwhyj_16  (-99=.) 

recode spendwhyk_1   (-99=.) // bingo online 
recode spendwhyk_4 (-99=.) 
recode spendwhyk_5 (-99=.) 
recode spendwhyk_6 (-99=.) 
recode spendwhyk_7  (-99=.) 
recode spendwhyk_9 (-99=.) 
recode spendwhyk_10 (-99=.) 
recode spendwhyk_11 (-99=.) 
recode spendwhyk_12 (-99=.) 
recode spendwhyk_13 (-99=.) 
recode spendwhyk_14 (-99=.) 
recode spendwhyk_15 (-99=.) 
recode spendwhyk_16 (-99=.) 

recode spendwhyl_1  (-99=.) // betting w/ friends or family
recode spendwhyl_4 (-99=.)
recode spendwhyl_5 (-99=.)
recode spendwhyl_6 (-99=.)
recode spendwhyl_7  (-99=.)
recode spendwhyl_9 (-99=.)
recode spendwhyl_10 (-99=.)
recode spendwhyl_11 (-99=.)
recode spendwhyl_12 (-99=.)
recode spendwhyl_13 (-99=.)
recode spendwhyl_14 (-99=.)
recode spendwhyl_15 (-99=.)
recode spendwhyl_16 (-99=.)

recode spendwhym_1   (-99=.)  // bet on esports
recode spendwhym_4  (-99=.) 
recode spendwhym_5  (-99=.) 
recode spendwhym_6  (-99=.) 
recode spendwhym_7   (-99=.) 
recode spendwhym_9  (-99=.) 
recode spendwhym_10  (-99=.) 
recode spendwhym_11  (-99=.) 
recode spendwhym_12  (-99=.) 
recode spendwhym_13  (-99=.) 
recode spendwhym_14  (-99=.) 
recode spendwhym_15  (-99=.) 
recode spendwhym_16 (-99=.)

recode spendwhyn_1   (-99=.) // betting shop or bookies 
recode spendwhyn_4 (-99=.)
recode spendwhyn_5 (-99=.)
recode spendwhyn_6 (-99=.)
recode spendwhyn_7  (-99=.)
recode spendwhyn_9 (-99=.)
recode spendwhyn_10 (-99=.)
recode spendwhyn_11 (-99=.)
recode spendwhyn_12 (-99=.)
recode spendwhyn_13 (-99=.)
recode spendwhyn_14 (-99=.)
recode spendwhyn_15 (-99=.)
recode spendwhyn_16 (-99=.)

recode spendwhyo_1  (-99=.)  //  betting website/app 
recode spendwhyo_4  (-99=.)
recode spendwhyo_5  (-99=.)
recode spendwhyo_6  (-99=.)
recode spendwhyo_7   (-99=.)
recode spendwhyo_9  (-99=.)
recode spendwhyo_10  (-99=.)
recode spendwhyo_11  (-99=.)
recode spendwhyo_12  (-99=.)
recode spendwhyo_13  (-99=.)
recode spendwhyo_14  (-99=.)
recode spendwhyo_15  (-99=.)
recode spendwhyo_16 (-99=.)

recode spendwhyp_1   (-99=.) // Playing a game inside a casino
recode spendwhyp_4 (-99=.)
recode spendwhyp_5 (-99=.)
recode spendwhyp_6 (-99=.)
recode spendwhyp_7  (-99=.)
recode spendwhyp_9 (-99=.)
recode spendwhyp_10 (-99=.)
recode spendwhyp_11 (-99=.)
recode spendwhyp_12 (-99=.)
recode spendwhyp_13 (-99=.)
recode spendwhyp_14 (-99=.)
recode spendwhyp_15 (-99=.)
recode spendwhyp_16 (-99=.)

recode spendwhyq_1    (-99=.) // Playing casino games online 
recode spendwhyq_4  (-99=.) 
recode spendwhyq_5  (-99=.) 
recode spendwhyq_6  (-99=.) 
recode spendwhyq_7   (-99=.) 
recode spendwhyq_9  (-99=.) 
recode spendwhyq_10  (-99=.) 
recode spendwhyq_11  (-99=.) 
recode spendwhyq_12  (-99=.) 
recode spendwhyq_13  (-99=.) 
recode spendwhyq_14  (-99=.) 
recode spendwhyq_15  (-99=.) 
recode spendwhyq_16  (-99=.) 

gen F1 = 0
replace F1 = 1 if spendwhya_1==1 | spendwhyb_1==1 | spendwhyc_1==1 | spendwhyd_1==1 | spendwhye_1==1 | spendwhyf_1==1 | spendwhyg_1==1 | spendwhyh_1==1 | spendwhyi_1==1 | spendwhyj_1==1 | spendwhyk_1==1 | spendwhyl_1==1 | spendwhym_1==1 | spendwhyn_1==1| spendwhyo_1==1 | spendwhyp_1==1 | spendwhyq_1==1

gen F2 = 0
replace F2 = 1 if spendwhya_4==1 | spendwhyb_4==1 | spendwhyc_4==1 | spendwhyd_4==1 | spendwhye_4==1 | spendwhyf_4==1 | spendwhyg_4==1 | spendwhyh_4==1 | spendwhyi_4==1 | spendwhyj_4==1 | spendwhyk_4==1 | spendwhyl_4==1 | spendwhym_4==1 | spendwhyn_4==1| spendwhyo_4==1 | spendwhyp_4==1 | spendwhyq_4==1

gen F3 = 0
replace F3 = 1 if spendwhya_5==1 | spendwhyb_5==1 | spendwhyc_5==1 | spendwhyd_5==1 | spendwhye_5==1 | spendwhyf_5==1 | spendwhyg_5==1 | spendwhyh_5==1 | spendwhyi_5==1 | spendwhyj_5==1 | spendwhyk_5==1 | spendwhyl_5==1 | spendwhym_5==1 | spendwhyn_5==1| spendwhyo_5==1 | spendwhyp_5==1 | spendwhyq_5==1

gen F4 = 0
replace F4 = 1 if spendwhya_6==1 | spendwhyb_6==1 | spendwhyc_6==1 | spendwhyd_6==1 | spendwhye_6==1 | spendwhyf_6==1 | spendwhyg_6==1 | spendwhyh_6==1 | spendwhyi_6==1 | spendwhyj_6==1 | spendwhyk_6==1 | spendwhyl_6==1 | spendwhym_6==1 | spendwhyn_6==1| spendwhyo_6==1 | spendwhyp_6==1 | spendwhyq_6==1

gen F5 = 0
replace F5 = 1 if spendwhya_7==1 | spendwhyb_7==1 | spendwhyc_7==1 | spendwhyd_7==1 | spendwhye_7==1 | spendwhyf_7==1 | spendwhyg_7==1 | spendwhyh_7==1 | spendwhyi_7==1 | spendwhyj_7==1 | spendwhyk_7==1 | spendwhyl_7==1 | spendwhym_7==1 | spendwhyn_7==1| spendwhyo_7==1 | spendwhyp_7==1 | spendwhyq_7==1

gen F6 = 0
replace F6 = 1 if spendwhya_9==1 | spendwhyb_9==1 | spendwhyc_9==1 | spendwhyd_9==1 | spendwhye_9==1 | spendwhyf_9==1 | spendwhyg_9==1 | spendwhyh_9==1 | spendwhyi_9==1 | spendwhyj_9==1 | spendwhyk_9==1 | spendwhyl_9==1 | spendwhym_9==1 | spendwhyn_9==1| spendwhyo_9==1 | spendwhyp_9==1 | spendwhyq_9==1

gen F7 = 0
replace F7 = 1 if spendwhya_10==1 | spendwhyb_10==1 | spendwhyc_10==1 | spendwhyd_10==1 | spendwhye_10==1 | spendwhyf_10==1 | spendwhyg_10==1 | spendwhyh_10==1 | spendwhyi_10==1 | spendwhyj_10==1 | spendwhyk_10==1 | spendwhyl_10==1 | spendwhym_10==1 | spendwhyn_10==1| spendwhyo_10==1 | spendwhyp_10==1 | spendwhyq_10==1

gen F8 = 0
replace F8 = 1 if spendwhya_11==1 | spendwhyb_11==1 | spendwhyc_11==1 | spendwhyd_11==1 | spendwhye_11==1 | spendwhyf_11==1 | spendwhyg_11==1 | spendwhyh_11==1 | spendwhyi_11==1 | spendwhyj_11==1 | spendwhyk_11==1 | spendwhyl_11==1 | spendwhym_11==1 | spendwhyn_11==1| spendwhyo_11==1 | spendwhyp_11==1 | spendwhyq_11==1

gen F9 = 0
replace F9 = 1 if spendwhya_12==1 | spendwhyb_12==1 | spendwhyc_12==1 | spendwhyd_12==1 | spendwhye_12==1 | spendwhyf_12==1 | spendwhyg_12==1 | spendwhyh_12==1 | spendwhyi_12==1 | spendwhyj_12==1 | spendwhyk_12==1 | spendwhyl_12==1 | spendwhym_12==1 | spendwhyn_12==1| spendwhyo_12==1 | spendwhyp_12==1 | spendwhyq_12==1

gen F10 = 0
replace F10 = 1 if spendwhya_13==1 | spendwhyb_13==1 | spendwhyc_13==1 | spendwhyd_13==1 | spendwhye_13==1 | spendwhyf_13==1 | spendwhyg_13==1 | spendwhyh_13==1 | spendwhyi_13==1 | spendwhyj_13==1 | spendwhyk_13==1 | spendwhyl_13==1 | spendwhym_13==1 | spendwhyn_13==1| spendwhyo_13==1 | spendwhyp_13==1 | spendwhyq_13==1

gen F11 = 0
replace F11 = 1 if spendwhya_14==1 | spendwhyb_14==1 | spendwhyc_14==1 | spendwhyd_14==1 | spendwhye_14==1 | spendwhyf_14==1 | spendwhyg_14==1 | spendwhyh_14==1 | spendwhyi_14==1 | spendwhyj_14==1 | spendwhyk_14==1 | spendwhyl_14==1 | spendwhym_14==1 | spendwhyn_14==1| spendwhyo_14==1 | spendwhyp_14==1 | spendwhyq_14==1

gen F12 = 0
replace F12 = 1 if spendwhya_15==1 | spendwhyb_15==1 | spendwhyc_15==1 | spendwhyd_15==1 | spendwhye_15==1 | spendwhyf_15==1 | spendwhyg_15==1 | spendwhyh_15==1 | spendwhyi_15==1 | spendwhyj_15==1 | spendwhyk_15==1 | spendwhyl_15==1 | spendwhym_15==1 | spendwhyn_15==1| spendwhyo_15==1 | spendwhyp_15==1 | spendwhyq_15==1

gen F13 = 0
replace F13 = 1 if spendwhya_16==1 | spendwhyb_16==1 | spendwhyc_16==1 | spendwhyd_16==1 | spendwhye_16==1 | spendwhyf_16==1 | spendwhyg_16==1 | spendwhyh_16==1 | spendwhyi_16==1 | spendwhyj_16==1 | spendwhyk_16==1 | spendwhyl_16==1 | spendwhym_16==1 | spendwhyn_16==1| spendwhyo_16==1 | spendwhyp_16==1 | spendwhyq_16==1



gen Motive1 = .
replace Motive1 = 1 if (F1==1 | F2==1 | F10==1) & problem1==1
replace Motive1 = 0 if Motive1==. & problem1==1   // only for asked respondents
label var Motive1 "Monetary factor and quick fix to problem factor"

*gen Motive1 = 0
*replace Motive1 = 1 if F1==1 | F2==1 | F10==1
*label var Motive1 "Monetary factor and quick fix to problem factor"


gen Motive2 = .
replace Motive2 = 1 if (F3==1 | F6==1 | F7==1) & problem1==1
replace Motive2 = 0 if Motive2==. & problem1==1   // only for asked respondents

*gen Motive2 = 0
*replace Motive2 = 1 if F3==1 | F6==1 | F7==1 
*label var Motive2 "Entertainment factor (seeking pleasure, fun or excitment)"


gen Motive3 = .
replace Motive3 = 1 if (F4==1 | F5==1) & problem1==1
replace Motive3 = 0 if Motive3==. & problem1==1   // only for asked respondents
label var Motive3 "Lonelines (gambling to be in the presence of others) factor" 

*gen Motive3 = 0
*replace Motive3 = 1 if F4==1 | F5==1
*label var Motive3 "Lonelines (gambling to be in the presence of others) factor" 

gen Motive4 = .
replace Motive4 = 1 if (F9==1 | F11==1 | F12==1 | F13==1) & problem1==1
replace Motive4 = 0 if Motive4==. & problem1==1   // only for asked respondents
label var Motive4 "Cognitive factor (coping or testing one's ability to beat the odds)" 

*gen Motive4 = 0
*replace Motive4 = 1 if F9==1 | F11==1 | F12==1 | F13==1
*label var Motive4 "Cognitive factor (coping or testing one's ability to beat the odds)" 

gen Motive5 = .
replace Motive5 = 1 if (F8==1) & problem1==1
replace Motive5 = 0 if Motive5==. & problem1==1   // only for asked respondents
label var Motive5 "Boredom (gambling as a means to esccape the monotomy of one's lifestyle)" 

*gen Motive5 = 0
*replace Motive5 = 1 if F8==1
*label var Motive5 "Boredom (gambling as a means to esccape the monotomy of one's lifestyle)" 


*-------------------------------------------------------------------------------
* 7. Save pooled dataset
*-------------------------------------------------------------------------------
save "ypgs_2022_2024_pooled.dta", replace


****************************************************************************************
* End of 03_pool_ypgs_2022_2024.do
****************************************************************************************



	   
	   