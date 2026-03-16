/****************************************************************************************
 01_pool_append.do
 Author   : Kevin Kim
 Project  : Young People and Gambling Survey (YPGS) – Paper 1
 Purpose  : Pool YPGS 2022–2024 repeated cross-sections into a single dataset
 Data in  : ypgs2022_clean.dta, ypgs2023_clean.dta, ypgs2024_clean.dta
 Data out : ypgs_2022_2024_pooled.dta
****************************************************************************************/

version 18.0
clear
set more off

*---------------------------------------------------------------*
* 0. Confirm input files exist
*---------------------------------------------------------------*
capture confirm file "${processed}/ypgs2022_clean.dta"
if _rc != 0 {
    di as error "File not found: ${processed}/ypgs2022_clean.dta"
    exit 601
}

capture confirm file "${processed}/ypgs2023_clean.dta"
if _rc != 0 {
    di as error "File not found: ${processed}/ypgs2023_clean.dta"
    exit 602
}

capture confirm file "${processed}/ypgs2024_clean.dta"
if _rc != 0 {
    di as error "File not found: ${processed}/ypgs2024_clean.dta"
    exit 603
}

*---------------------------------------------------------------*
* 1. Load 2022 and append 2023–2024
*---------------------------------------------------------------*
use "${processed}/ypgs2022_clean.dta", clear
append using "${processed}/ypgs2023_clean.dta"
append using "${processed}/ypgs2024_clean.dta"


*---------------------------------------------------------------*
* 2. Define common comparable population across all waves
*---------------------------------------------------------------*
generate byte samp_common_year = !missing(yearq) & inlist(yearq, 1, 2, 3, 4, 5)
label var samp_common_year "Year 7/S1 to Year 11/S5"

generate byte samp_common_age = !missing(Exactage) & inrange(Exactage, 11, 16)
label var samp_common_age "Age 11 to 16"

generate byte samp_common = samp_common_year & samp_common_age
label var samp_common "Common comparable population across pooled waves"

*---------------------------------------------------------------*
* 3. Create pooled-wave weight for the common sample only
*---------------------------------------------------------------*
levelsof survey_year if samp_common == 1, local(years)
local n_waves : word count `years'

bysort survey_year: egen double sum_w_year_common = total(survey_weight) if samp_common == 1

generate double survey_weight_pool = .
replace survey_weight_pool = survey_weight / sum_w_year_common * (1/`n_waves') if samp_common == 1

label var survey_weight_pool "Equal-wave pooled weight within common sample (Years 7–11, ages 11–16)"

drop sum_w_year_common


*---------------------------------------------------------------*
* 4. QA for pooled dataset
*---------------------------------------------------------------*
tab survey_year, missing
tab survey_year if samp_common == 1
tab survey_year if samp_common == 0


describe yearq
tab yearq, missing
tab yearq survey_year, missing

count if missing(survey_weight)
count if samp_common == 1 & missing(survey_weight_pool)
count if samp_common == 1 & missing(schoolid)
count if samp_common == 1 & survey_weight_pool <= 0
count if samp_common == 1 & missing(survey_weight)
count if samp_common == 1 & missing(yearq)
count if samp_common == 1 & missing(Exactage)
tabstat survey_weight_pool if samp_common == 1, by(survey_year) stat(sum min max)
count if samp_common == 1
count if samp_common == 0

describe Exactage gender Ethnicity region imd famgam ///
         gamspend4smc1 gamspend4smc2 gamspend4smc3 gamspend4smc4 ///
         preocc escape withd tolernce losscon ///
         illegal2 illegal3 illegal4 illegal5 illegal6 ///
         led_ledriskedfam led_ledriskedschl led_ledlying chasing ///
         never1 never2 never3 never4 never5 ///
         never6 never7 never8 never9 never10 ///
         ga_satis ga_worth ga_happy ga_anxious ///
         selftryx adultcaresx exphapx expguilx expsadx ///
         impulsivity ///
         fruittype1 fruittype2 fruittype3 fruittype4 ///
         fruittype5 fruittype6 fruittype7 fruittype8 fruittype9 ///
         fruittype15 fruittype16 fruittype17 fruittype18 ///
         fruitwhere survey_year survey_weight survey_weight_pool schoolid yearq

bysort survey_year: egen double check_pool = total(survey_weight_pool)
tabstat check_pool if samp_common == 1, by(survey_year) stat(mean)
drop check_pool

di as text "Check: total pooled weight should be approximately 1 in the common sample"
egen double total_pool = total(survey_weight_pool)
summarize total_pool
drop total_pool

count if missing(Exactage)
count if missing(gender)
count if missing(Ethnicity)
count if missing(survey_year)

tab survey_year if missing(survey_weight)
tab survey_year if samp_common == 1 & missing(schoolid)

summarize survey_weight survey_weight_pool, detail


*---------------------------------------------------------------*
* 5. Save pooled dataset
*---------------------------------------------------------------*
save "${processed}/ypgs_2022_2024_pooled.dta", replace

****************************************************************************************
* End of 01_pool_append.do
****************************************************************************************/
