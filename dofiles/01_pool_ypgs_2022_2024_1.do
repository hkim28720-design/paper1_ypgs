/****************************************************************************************
 01_pool_ypgs_2022_2024_1.do
 Author   : Kevin Kim
 Project  : Young People and Gambling Survey (YPGS) – Paper 1
 Purpose  : Pool YPGS 2022–2024 repeated cross-sections into a single dataset
 Data in  : ypgs2022_clean.dta, ypgs2023_clean.dta, ypgs2024_clean.dta
 Data out : ypgs_2022_2024_pooled.dta
****************************************************************************************/

version 18.0
clear all
set more off

*---------------------------------------------------------------*
* 0. set up
*---------------------------------------------------------------*

cd "/Users/kk/Desktop/Paper_1_main/Data/Processed"


*---------------------------------------------------------------*
* 1. importing 2022 
*---------------------------------------------------------------*

use "ypgs2022_clean.dta", clear

describe Exactage gender Ethnicity region imd famgam ///
         survey_year


*---------------------------------------------------------------*
* 2. append 2023, 2024
*---------------------------------------------------------------*

append using "ypgs2023_clean.dta"

append using "ypgs2024_clean.dta"

*---------------------------------------------------------------*
* 3. Rescale weights so each wave contributes equally to the pooled sample
*---------------------------------------------------------------*

bysort survey_year: egen sum_w_year = sum(survey_weight)
gen survey_weight_pool = survey_weight / sum_w_year * (1/3)
drop sum_w_year
label var survey_weight_pool "Survey weight rescaled for equal wave contribution (pooled)"

*---------------------------------------------------------------*
* 4. QA for pooled dataset 
*---------------------------------------------------------------*

* check for the year dummy
tab survey_year

* check for the key variables
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
         fruitwhere survey_year survey_weight schoolid




*---------------------------------------------------------------*
* 5. save dataset
*---------------------------------------------------------------*

save "ypgs_2022_2024_pooled.dta", replace

****************************************************************************************
* End of 01_pool_ypgs_2022_2024.do
****************************************************************************************
