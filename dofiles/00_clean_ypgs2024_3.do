/****************************************************************************************
 00_clean_ypgs2024_3.do
 Author   : Kevin Kim
 Project  : Young People and Gambling Survey (YPGS) – Paper 1
 Purpose  : Clean wave 3 (2024) data and confirm alignment with 2022/2023 standard
 Data in  : ypgs2024.dta
 Data out : ypgs2024_clean.dta
****************************************************************************************/

version 18.0
clear all
set more off

*---------------------------------------------------------------*
* 0. set up
*---------------------------------------------------------------*

cd "/Users/kk/Desktop/Paper_1_main/Data/Processed"

use "ypgs2024.dta", clear


*---------------------------------------------------------------*
* 1. raw variable inspection 
*---------------------------------------------------------------*

* check for all variables in the raw dataset
describe

* check for key demographic raw variables
summarize Exactage gender Ethnicity region imd famgam

tab gender, missing
tab Ethnicity, missing
tab region, missing

* confirm key variables exists in the 2024ygps
lookfor Exactage gender Ethnicity region imd famgam
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
lookfor School_ID
lookfor weight0
lookfor serial


*---------------------------------------------------------------*
* 2. cleaning – we standardised the other survey wave variables to the 2024ygps
*---------------------------------------------------------------*

* 2-1. Last 12 months gambling spend variables (gamspend4smc1–18)
describe gamspend4smc1 gamspend4smc2 gamspend4smc3 gamspend4smc4 ///
         gamspend4smc5 gamspend4smc6 gamspend4smc7 gamspend4smc8 ///
         gamspend4smc9 gamspend4smc10 gamspend4smc11 gamspend4smc12 ///
         gamspend4smc13 gamspend4smc14 gamspend4smc15 gamspend4smc16 ///
         gamspend4smc17 gamspend4smc18

* 2-2. DSM-IV-MR-J / illegal / led_* / chasing
describe preocc escape withd tolernce losscon
describe illegal2 illegal3 illegal4 illegal5 illegal6
describe led_ledriskedfam led_ledriskedschl led_ledlying chasing

* 2-3. gambling motives, never, spare time, well being, self control·gambling feelings
describe spendwhya_1 spendwhya_4 spendwhya_15 spendwhya_16
describe spendwhyq_1 spendwhyq_4 spendwhyq_15 spendwhyq_16

describe never1 never2 never3 never4 never5 ///
         never6 never7 never8 never9 never10

describe gc_spare2 gc_spare3 gc_spare4 gc_spare5 gc_spare6 ///
         gc_spare7 gc_spare9 gc_spare10 gc_spare11 gc_spare12 ///
         gc_spare13 gc_spare14 gc_spare15 gc_spare16 gc_spare17 ///
         gc_spare18 gc_spare19 gc_spare20

describe ga_satis ga_worth ga_happy ga_anxious
describe selftryx adultcaresx exphapx expguilx expsadx

* 2-4. impulsive act (impulsivity) 
capture confirm variable impulsivity
if _rc != 0 {
    generate impulsivity = .
    label var impulsivity "Impulsivity scale (2024 – created as missing; check spec)"
}

* 2-5. arcade/ fruit machine gamblers (fruittype1–9, 15–18, fruitwhere)
describe fruittype1 fruittype2 fruittype3 fruittype4 ///
         fruittype5 fruittype6 fruittype7 fruittype8 fruittype9 ///
         fruittype15 fruittype16 fruittype17 fruittype18 ///
         fruitwhere

* 2-6. Rename variables match with 2022 2023
rename School_ID schoolid


* 2-7. rename sample weight
rename weight0			survey_weight


*---------------------------------------------------------------*
* 3. Generate survey year dummy and save data for pooling
*---------------------------------------------------------------*

generate survey_year = 2024
label var survey_year "YPGS survey year (2024 wave)"

save "ypgs2024_clean.dta", replace

****************************************************************************************
* End of 00_clean_ypgs2024.do
****************************************************************************************
