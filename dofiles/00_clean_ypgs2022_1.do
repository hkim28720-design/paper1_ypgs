/****************************************************************************************
 00_clean_ypgs2022_1.do
 Author   : Kevin Kim
 Project  : Young People and Gambling Survey (YPGS) – Paper 1
 Purpose  : Clean wave 1 (2022) data and harmonise variable names to 2024 standard
 Data in  : ypgs2022.dta
 Data out : ypgs2022_clean.dta
****************************************************************************************/

version 18.0
clear all
set more off

*---------------------------------------------------------------*
* 0. set up
*---------------------------------------------------------------*

use "${raw}/ypgs2022.dta", clear

*---------------------------------------------------------------*
* 1. raw variable inspection 
*---------------------------------------------------------------*

* check for all variables in the raw dataset
describe


* check for key demographic raw variables
summarize exage gender ethgroup region imd gc_famgam

tab gender, missing
tab ethgroup, missing
tab region, missing

* check for the gambling spend DSM variables
lookfor exage gender ethgroup region imd gc_famgam
lookfor gc_gamspend4smc
lookfor gc_preocc gc_escape gc_withd gc_tolernce gc_losscon
lookfor gc_illegal
lookfor gc_led_ gc_chasing
lookfor spendwhya_ spendwhyb_ spendwhyd_ spendwhye_ spendwhyf_
lookfor spendwhyg_ spendwhyh_ spendwhyi_ spendwhyj_ spendwhyk_
lookfor spendwhyl_ spendwhym_ spendwhyn_ spendwhyo_ spendwhyp_ spendwhyq_
lookfor gc_never
lookfor gc_spare
lookfor ga_satis ga_worth ga_happy ga_anxious
lookfor gc_selftryx gc_adultcaresx gc_exphapx gc_expguilx gc_expsadx
lookfor gc_fruittype gc_fruitwhere
lookfor schoolid
lookfor weight0
lookfor  serial


*---------------------------------------------------------------*
* 2. Rename the variables to match with the 2024ypgs for consistency (cleaning – harmonisation)
*---------------------------------------------------------------*

*-----------------------------*
* 2-1. demographics
*-----------------------------*

* age: 2022 exage → standardising Exactage
rename exage      Exactage

* gender: 2022 gender → standardising gender (이 변수는 이름 유지)
* -> rename 필요 없음 (이미 gender)

* ethinicity: 2022 ethgroup → standardising Ethnicity
rename ethgroup   Ethnicity

* IMD: consistent rename not needed 
* region: consistent rename not needed 

* family gamblers: 2022 gc_famgam → standardising famgam
rename gc_famgam  famgam


*-----------------------------*
* 2-2. Last 12 months gambling spend variables (gambling formats: gamspend4smc1–18)
*      2022ypgs has the gc_ prefix
*-----------------------------*

rename gc_gamspend4smc1   gamspend4smc1
rename gc_gamspend4smc2   gamspend4smc2
rename gc_gamspend4smc3   gamspend4smc3
rename gc_gamspend4smc4   gamspend4smc4
rename gc_gamspend4smc5   gamspend4smc5
rename gc_gamspend4smc6   gamspend4smc6
rename gc_gamspend4smc7   gamspend4smc7
rename gc_gamspend4smc8   gamspend4smc8
rename gc_gamspend4smc9   gamspend4smc9
rename gc_gamspend4smc10  gamspend4smc10
rename gc_gamspend4smc11  gamspend4smc11
rename gc_gamspend4smc12  gamspend4smc12
rename gc_gamspend4smc13  gamspend4smc13
rename gc_gamspend4smc14  gamspend4smc14
rename gc_gamspend4smc15  gamspend4smc15
rename gc_gamspend4smc16  gamspend4smc16
rename gc_gamspend4smc17  gamspend4smc17
rename gc_gamspend4smc18  gamspend4smc18


*-----------------------------*
* 2-3. DSM-IV-MR-J (preocc–losscon)
*-----------------------------*

rename gc_preocc     preocc
rename gc_escape     escape
rename gc_withd      withd
rename gc_tolernce   tolernce
rename gc_losscon    losscon


*-----------------------------*
* 2-4. DSM-IV-MR-J (illegal2–illegal6)
*-----------------------------*

rename gc_illegal2   illegal2
rename gc_illegal3   illegal3
rename gc_illegal4   illegal4
rename gc_illegal5   illegal5
rename gc_illegal6   illegal6


*-----------------------------*
* 2-5. DSM-IV-MR-J (led_* + chasing)
*-----------------------------*

rename gc_led_ledriskedfam   led_ledriskedfam
rename gc_led_ledriskedschl  led_ledriskedschl
rename gc_led_ledlying       led_ledlying
rename gc_chasing            chasing


*-----------------------------*
* 2-6. gambling motives (spendwhya_ ~ spendwhyq_)
*      rename not needed. consistent variable names 2022ygps to 2023/2024
*-----------------------------*


*-----------------------------*
* 2-7. "why never gamble" variables (never1–never10)
*-----------------------------*

rename gc_never1   never1
rename gc_never2   never2
rename gc_never3   never3
rename gc_never4   never4
rename gc_never5   never5
rename gc_never6   never6
rename gc_never7   never7
rename gc_never8   never8
rename gc_never9   never9
rename gc_never10  never10


*-----------------------------*
* 2-8. spare time (gc_spare2–gc_spare18)
*      all variable names are consistent variable names 2022ygps to 2023/2024
*-----------------------------*


*-----------------------------*
* 2-9. well being measures  (ga_satis, ga_worth, ga_happy, ga_anxious)
*-----------------------------*

* rename not needed


*-----------------------------*
* 2-10. self control; adultcare; gambling feelings (selftryx )
*-----------------------------*

rename gc_selftryx     selftryx
rename gc_adultcaresx  adultcaresx
rename gc_exphapx      exphapx
rename gc_expguilx     expguilx
rename gc_expsadx      expsadx


*-----------------------------*
* 2-11. impuslive act (impulsivity)
*      2022ypgs does not have this variable in the raw dataset 
*      generate this variable as missing for later pooling 
*-----------------------------*

capture confirm variable impulsivity
if _rc != 0 {
    generate impulsivity = .
    label var impulsivity "Impulsivity scale (not asked in 2022 wave – always missing)"
}


*-----------------------------*
* 2-12. arcade games (fruittype*, fruitwhere)
*      - fruittype1–9 : are consisent with 2023 and 2024 
*      - 2024 fruittype15–18 ↔ 2022 gc_fruittype10–13
*-----------------------------*

rename gc_fruittype1   fruittype1
rename gc_fruittype2   fruittype2
rename gc_fruittype3   fruittype3
rename gc_fruittype4   fruittype4
rename gc_fruittype5   fruittype5
rename gc_fruittype6   fruittype6
rename gc_fruittype7   fruittype7
rename gc_fruittype8   fruittype8
rename gc_fruittype9   fruittype9

rename gc_fruittype10  fruittype15
rename gc_fruittype11  fruittype16
rename gc_fruittype12  fruittype17
rename gc_fruittype13  fruittype18

rename gc_fruitwhere   fruitwhere


*-----------------------------*
* 2-13. rename sample weight
*-----------------------------*

rename weight0			survey_weight

*---------------------------------------------------------------*
* 3. QA – quality check
*---------------------------------------------------------------*

describe Exactage gender Ethnicity region imd famgam

describe gamspend4smc1 gamspend4smc2 gamspend4smc3 gamspend4smc4 ///
         gamspend4smc5 gamspend4smc6 gamspend4smc7 gamspend4smc8 ///
         gamspend4smc9 gamspend4smc10 gamspend4smc11 gamspend4smc12 ///
         gamspend4smc13 gamspend4smc14 gamspend4smc15 gamspend4smc16 ///
         gamspend4smc17 gamspend4smc18

describe preocc escape withd tolernce losscon
describe illegal2 illegal3 illegal4 illegal5 illegal6
describe led_ledriskedfam led_ledriskedschl led_ledlying chasing

describe never1 never2 never3 never4 never5 ///
         never6 never7 never8 never9 never10

describe ga_satis ga_worth ga_happy ga_anxious
describe selftryx adultcaresx exphapx expguilx expsadx
describe impulsivity

describe fruittype1 fruittype2 fruittype3 fruittype4 ///
         fruittype5 fruittype6 fruittype7 fruittype8 fruittype9 ///
         fruittype15 fruittype16 fruittype17 fruittype18 ///
         fruitwhere


*---------------------------------------------------------------*
* 4. Generate survey year dummy and save data for pooling
*---------------------------------------------------------------*

generate survey_year = 2022
label var survey_year "YPGS survey year (2022 wave)"

* save cleaned dataset
save "${processed}/ypgs2022_clean.dta", replace

****************************************************************************************
* End of 00_clean_ypgs2022.do
****************************************************************************************
