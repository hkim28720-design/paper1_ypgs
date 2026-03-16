/****************************************************************************************
 00_clean_ypgs2023_2.do
 Author   : Kevin Kim
 Project  : Young People and Gambling Survey (YPGS) – Paper 1
 Purpose  : Clean wave 2 (2023) data and harmonise variable names to 2024 standard
 Data in  : ypgs2023.dta
 Data out : ypgs2023_clean.dta
****************************************************************************************/

version 18.0
clear all
set more off

*---------------------------------------------------------------*
* 0. set up
*---------------------------------------------------------------*

cd "/Users/kk/Desktop/Paper_1_main/Data/Processed"

use "ypgs2023.dta", clear


*---------------------------------------------------------------*
* 1. raw variable inspection 
*---------------------------------------------------------------*

* check for all variables in the raw dataset
describe

* check for key demographic raw variables
summarize exage gender2 ethnicity2 region imd famgam

tab gender2, missing
tab ethnicity2, missing
tab region, missing

* confirm key variables exists in the 2023ygps
lookfor exage gender2 ethnicity2 region imd famgam
lookfor gamspend4smc
lookfor preocc escape withd tolernce losscon
lookfor illegal
lookfor led_ chasing
lookfor spendwhya_ spendwhyb_ spendwhyd_ spendwhye_ spendwhyf_
lookfor spendwhyg_ spendwhyh_ spendwhyi_ spendwhyj_ spendwhyk_
lookfor spendwhyl_ spendwhym_ spendwhyn_ spendwhyo_ spendwhyp_ spendwhyq_
lookfor never
lookfor gc_spare
lookfor ga_satis ga_worth ga_happy ga_anxious
lookfor selftryx adultcaresx exphapx expguilx expsadx
lookfor impulsivity
lookfor fruittype fruitwhere
lookfor schoolid
lookfor weight0
lookfor  serial



*---------------------------------------------------------------*
* 2. Rename the variables to match with the 2024ypgs for consistency (cleaning – harmonisation)
*---------------------------------------------------------------*

*-----------------------------*
* 2-1. demographics
*-----------------------------*

* 2023: exage → 2024 standardising Exactage
rename exage      Exactage

* 2023: gender2 → 2024 standardising gender
capture confirm variable gender2
if _rc == 0 {
    rename gender2   gender
}

* 2023: ethnicity2 → 2024 standardising Ethnicity
rename ethnicity2 Ethnicity

* IMD: consistent rename not needed 
* region: consistent rename not needed 


*-----------------------------*
* 2-2. Last 12 months gambling spend variables (gambling formats: gamspend4smc1–18)
*      variable names here are consistent with the 2024
*-----------------------------*

* Just to confirm
describe gamspend4smc1 gamspend4smc2 gamspend4smc3 gamspend4smc4 ///
         gamspend4smc5 gamspend4smc6 gamspend4smc7 gamspend4smc8 ///
         gamspend4smc9 gamspend4smc10 gamspend4smc11 gamspend4smc12 ///
         gamspend4smc13 gamspend4smc14 gamspend4smc15 gamspend4smc16 ///
         gamspend4smc17 gamspend4smc18


*-----------------------------*
* 2-3. DSM-IV-MR-J (preocc–losscon)
*      consistent variable names with the 2024ygps
*-----------------------------*

describe preocc escape withd tolernce losscon


*-----------------------------*
* 2-4. DSM-IV-MR-J (illegal2–illegal6)
*-----------------------------*

describe illegal2 illegal3 illegal4 illegal5 illegal6


*-----------------------------*
* 2-5. DSM-IV-MR-J (led_* + chasing)
*-----------------------------*

describe led_ledriskedfam led_ledriskedschl led_ledlying chasing


*-----------------------------*
* 2-6. gambling motives (spendwhya_ ~ spendwhyq_)
*      consistent variable names with the 2024ygps
*-----------------------------*

* just to confirm 
describe spendwhya_1 spendwhya_4 spendwhya_15 spendwhya_16
describe spendwhyq_1 spendwhyq_4 spendwhyq_15 spendwhyq_16


*-----------------------------*
* 2-7. "why never gamble" variables (never1–never10)
*-----------------------------*

describe never1 never2 never3 never4 never5 ///
         never6 never7 never8 never9 never10


*-----------------------------*
* 2-8. spare time (gc_spare2–gc_spare20)
*-----------------------------*

describe gc_spare2 gc_spare3 gc_spare4 gc_spare5 gc_spare6 ///
         gc_spare7 gc_spare9 gc_spare10 gc_spare11 gc_spare12 ///
         gc_spare13 gc_spare14 gc_spare15 gc_spare16 gc_spare17 ///
         gc_spare18 gc_spare19 gc_spare20


*-----------------------------*
* 2-9. well being measures (ga_satis, ga_worth, ga_happy, ga_anxious)
*      consistent variable names between the 3 waves 
*-----------------------------*

describe ga_satis ga_worth ga_happy ga_anxious


*-----------------------------*
* 2-10. self control; adultcare; gambling feelings  (selftryx)
*      consistent with the 2024ygps 
*-----------------------------*

describe selftryx adultcaresx exphapx expguilx expsadx


*-----------------------------*
* 2-11. impuslive act  (impulsivity)
*      this question first introduced from the 2023ypgs wave
*-----------------------------*

capture confirm variable impulsivity
if _rc != 0 {
    generate impulsivity = .
    label var impulsivity "Impulsivity scale (missing in 2023 if not originally asked)"
}

tab impulsivity, missing

*-----------------------------*
* 2-12. arcade fruit machine gamblers (fruittype*, fruitwhere)
*
*  consistent for:
*   - fruittype1–9 
*       2022 : gc_fruittype10–13
*       2023 : fruittype13–16
*       2024 : fruittype15–18
*
*  mapping:
*   - 2023 fruittype13 (Other)           → 2024 fruittype15
*   - 2023 fruittype14 (Don't know)      → 2024 fruittype16
*   - 2023 fruittype15 (Prefer not)      → 2024 fruittype17
*   - 2023 fruittype16 (Not stated)      → 2024 fruittype18
*-----------------------------*

* 1) keep variable names for (1–9) 
describe fruittype1 fruittype2 fruittype3 fruittype4 ///
         fruittype5 fruittype6 fruittype7 fruittype8 fruittype9

* 2) generate temp var names for 13–16 due to overlapping names 
capture confirm variable fruittype13
if _rc == 0 {
    clonevar fr_tmp15 = fruittype13
}

capture confirm variable fruittype14
if _rc == 0 {
    clonevar fr_tmp16 = fruittype14
}

capture confirm variable fruittype15
if _rc == 0 {
    clonevar fr_tmp17 = fruittype15
}

capture confirm variable fruittype16
if _rc == 0 {
    clonevar fr_tmp18 = fruittype16
}

* 3) drop 13–16 
capture drop fruittype13 fruittype14 fruittype15 fruittype16

* 4) recover and rename the temp var names to match with the 2024 
capture confirm variable fr_tmp15
if _rc == 0 {
    rename fr_tmp15 fruittype15
}

capture confirm variable fr_tmp16
if _rc == 0 {
    rename fr_tmp16 fruittype16
}

capture confirm variable fr_tmp17
if _rc == 0 {
    rename fr_tmp17 fruittype17
}

capture confirm variable fr_tmp18
if _rc == 0 {
    rename fr_tmp18 fruittype18
}

* 5) consistent
describe fruitwhere


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

generate survey_year = 2023
label var survey_year "YPGS survey year (2023 wave)"

save "ypgs2023_clean.dta", replace

****************************************************************************************
* End of 00_clean_ypgs2023.do
****************************************************************************************
