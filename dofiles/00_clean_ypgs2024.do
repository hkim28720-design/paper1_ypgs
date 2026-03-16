/****************************************************************************************
 00_clean_ypgs2024.do
 Author   : Kevin Kim
 Project  : Young People and Gambling Survey (YPGS) – Paper 1
 Purpose  : Clean wave 3 (2024) data and confirm alignment with 2022/2023 standard
 Data in  : ypgs2024.dta
 Data out : ypgs2024_clean.dta
****************************************************************************************/

*---------------------------------------------------------------*
* 0. set up
*---------------------------------------------------------------*

version 18.0
clear
set more off

capture confirm file "${raw}/ypgs2024.dta"
if _rc != 0 {
    di as error "File not found: ${raw}/ypgs2024.dta"
    exit 601
}

use "${raw}/ypgs2024.dta", clear

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

* inspect whether key variables are present in the 2024 YPGS

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
lookfor yearq


*---------------------------------------------------------------*
* 2. confirm and harmonise 2024 variables to the common pooled schema
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

* 2-6. Harmonise identifier names to the common pooled schema
capture confirm variable schoolid
local has_schoolid = (_rc == 0)

capture confirm variable School_ID
local has_School_ID = (_rc == 0)

if `has_School_ID' & !`has_schoolid' {
    rename School_ID schoolid
}

if `has_School_ID' & `has_schoolid' {
    di as error "Both School_ID and schoolid exist. Resolve duplicate identifier names before continuing."
    exit 111
}

capture confirm variable schoolid
if _rc != 0 {
    di as error "No school identifier found: neither School_ID nor schoolid exists"
    exit 112
}

* 2-7. Harmonise sample weight name to common pooled schema
capture confirm variable survey_weight
local has_survey_weight = (_rc == 0)

capture confirm variable weight0
local has_weight0 = (_rc == 0)

if `has_weight0' & !`has_survey_weight' {
    rename weight0 survey_weight
}

if `has_weight0' & `has_survey_weight' {
    di as error "Both weight0 and survey_weight exist. Resolve duplicate weight names before continuing."
    exit 113
}

capture confirm variable survey_weight
if _rc != 0 {
    di as error "No survey weight found: neither weight0 nor survey_weight exists"
    exit 114
}

*---------------------------------------------------------------*
* 3. QA
*---------------------------------------------------------------*

describe Exactage gender Ethnicity region imd famgam
describe schoolid survey_weight
describe fruittype1 fruittype2 fruittype3 fruittype4 ///
         fruittype5 fruittype6 fruittype7 fruittype8 fruittype9 ///
         fruittype15 fruittype16 fruittype17 fruittype18 ///
         fruitwhere

summarize Exactage survey_weight
tab gender, missing
tab Ethnicity, missing
tab famgam, missing
tab impulsivity, missing
tab fruitwhere, missing

count if missing(schoolid)
count if missing(survey_weight)
summarize survey_weight, detail

*---------------------------------------------------------------*
* 4. Generate survey year dummy and save data for pooling
*---------------------------------------------------------------*

generate int survey_year = 2024
label var survey_year "YPGS survey year"

save "${processed}/ypgs2024_clean.dta", replace

****************************************************************************************
* End of 00_clean_ypgs2024.do
****************************************************************************************
