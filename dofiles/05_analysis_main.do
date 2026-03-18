/*******************************************************************************
Project: Family, Motivation and Harm
Data: YPGS 2022–2024 pooled from common comparable population
Do file name: 05_analysis_main.do
Authors: Kim, Stowasser, Newall
Date created: 16 Mar 2026
Date edited: 18 Mar 2026
Version: 8

Purpose:
- Build the 2022–2024 common-sample analytic file
- Define analysis samples for participation and harm models
- Construct sample-specific equal-wave pooled weights
- Cluster standard errors at the wave-specific school level
- Report weighted prevalence of gambling per se and overlap across domains
- Estimate benchmark single-equation participation models
- Estimate harm models among gamblers only
- Estimate pooled and stratified moderation robustness models

Key design choices:
- Restrict to survey_year 2022, 2023, and 2024
- Restrict to samp_common == 1
- Participation models use overlapping group indicators g1_any g2_any g3_any
- Harm models exclude non-gamblers by design
- Use sample-specific renormalized pooled weights derived from survey_weight_pool
- Treat adultcaresx as categorical
- Cluster standard errors at the wave-specific school level
- Full survey-design inference is not implemented here
*******************************************************************************/

*-------------------------------------------------------------------------------
* 0. Set up
*-------------------------------------------------------------------------------
version 18
clear
set more off
set linesize 120

cap mkdir "log"
cap mkdir "out"
cap mkdir "fig"

* Optional log
* log using "log/05_analysis_main.log", replace text

*-------------------------------------------------------------------------------
* 1. Confirm pooled file exists and load data
*-------------------------------------------------------------------------------
capture confirm file "${processed}/ypgs_2022_2024_pooled.dta"
if _rc != 0 {
    di as error "File not found: ${processed}/ypgs_2022_2024_pooled.dta"
    exit 601
}

use "${processed}/ypgs_2022_2024_pooled.dta", clear

*-------------------------------------------------------------------------------
* 2. Restrict to analysis years and common comparable population
*-------------------------------------------------------------------------------
keep if inlist(survey_year, 2022, 2023, 2024)
keep if samp_common == 1

assert inlist(survey_year, 2022, 2023, 2024)
assert samp_common == 1

*-------------------------------------------------------------------------------
* 3. Check pooled weights from construction stage
*-------------------------------------------------------------------------------
assert !missing(survey_weight)
assert !missing(survey_weight_pool)
assert survey_weight > 0 if !missing(survey_weight)
assert survey_weight_pool > 0 if !missing(survey_weight_pool)

bysort survey_year: egen double check_pool = total(survey_weight_pool)
tabstat check_pool, by(survey_year) stat(mean)
drop check_pool

egen double total_pool = total(survey_weight_pool)
summarize total_pool
drop total_pool

*-------------------------------------------------------------------------------
* 4. Keep variables used in main analysis
*-------------------------------------------------------------------------------
keep survey_year samp_common problem1 ///
     schoolid ///
     group_complete3 n_any_groups ///
     g0_me g1_me g2_me g3_me multi ///
     g1_any g2_any g3_any ///
     dsm_total dsm_cat dsm_complete9 ///
     Exactage gender Ethnicity imd ///
     famgam adultcaresx ///
     Motive1 Motive2 Motive3 Motive4 Motive5 ///
     survey_weight survey_weight_pool

*-------------------------------------------------------------------------------
* 5. Recode and relabel covariates for analysis
*-------------------------------------------------------------------------------
capture label list LB_YN
if _rc != 0 {
    label define LB_YN 0 "No" 1 "Yes"
}

* adultcaresx:
* 1 Very well
* 2 Fairly well
* 3 Not very well
* 4 Not at all
* 5 No adult at home
* 6 Don't know
* 7 Prefer not to say
* 8 Not stated
recode adultcaresx (6=.) (7=.) (8=.)
label define adultcare_lbl 1 "Very well" 2 "Fairly well" 3 "Not very well" 4 "Not at all" 5 "No adult at home", replace
label values adultcaresx adultcare_lbl
label var adultcaresx "Perceived adult care at home (higher = less care)"

* gender:
* 1 boy
* 2 girl
* 3 in another way
* 4 prefer not to say
* 5 not stated / not answered
recode gender (4=.) (5=.)
label var gender "Gender"

* family gambling exposure:
* 1 yes
* 2 no
* 3 don't know
* 4 prefer not to say
* 5 not stated
capture drop famgam_yes
generate byte famgam_yes = .
replace famgam_yes = 1 if famgam == 1
replace famgam_yes = 0 if famgam == 2
label values famgam_yes LB_YN
label var famgam_yes "Family gambling exposure"

* Ethnicity:
* keep substantive categories
* drop explicit nonresponse only
recode Ethnicity (6=.)
label var Ethnicity "Ethnicity"

* meaningful motive labels
label var Motive1 "Monetary or quick-fix motive"
label var Motive2 "Entertainment motive"
label var Motive3 "Social-presence motive"
label var Motive4 "Cognitive motive"
label var Motive5 "Boredom motive"

*-------------------------------------------------------------------------------
* 6. Cluster identifier
*    Missing schoolid stays missing and is excluded from regression samples
*-------------------------------------------------------------------------------
count if missing(schoolid)

capture drop school_cluster
capture drop __school_cluster

generate long school_cluster = .
egen long __school_cluster = group(survey_year schoolid)
replace school_cluster = __school_cluster if !missing(schoolid)
drop __school_cluster

label var school_cluster "Wave-specific school cluster"

count if missing(school_cluster)
tab survey_year if missing(schoolid), missing

*-------------------------------------------------------------------------------
* 7. Weighted descriptive indicators
*-------------------------------------------------------------------------------
capture drop female
capture drop another_gender
generate byte female = .
replace female = 1 if gender == 2
replace female = 0 if inlist(gender, 1, 3)
label var female "Female"

generate byte another_gender = .
replace another_gender = 1 if gender == 3
replace another_gender = 0 if inlist(gender, 1, 2)
label var another_gender "Gender in another way"

capture drop eth_1
capture drop eth_2
capture drop eth_3
capture drop eth_4
capture drop eth_5

generate byte eth_1 = .
replace eth_1 = 1 if Ethnicity == 1
replace eth_1 = 0 if inlist(Ethnicity, 2, 3, 4, 5)
label var eth_1 "Ethnicity category 1"

generate byte eth_2 = .
replace eth_2 = 1 if Ethnicity == 2
replace eth_2 = 0 if inlist(Ethnicity, 1, 3, 4, 5)
label var eth_2 "Ethnicity category 2"

generate byte eth_3 = .
replace eth_3 = 1 if Ethnicity == 3
replace eth_3 = 0 if inlist(Ethnicity, 1, 2, 4, 5)
label var eth_3 "Ethnicity category 3"

generate byte eth_4 = .
replace eth_4 = 1 if Ethnicity == 4
replace eth_4 = 0 if inlist(Ethnicity, 1, 2, 3, 5)
label var eth_4 "Ethnicity category 4"

generate byte eth_5 = .
replace eth_5 = 1 if Ethnicity == 5
replace eth_5 = 0 if inlist(Ethnicity, 1, 2, 3, 4)
label var eth_5 "Ethnicity category 5"

capture drop imd_1
capture drop imd_2
capture drop imd_3
capture drop imd_4
capture drop imd_5

generate byte imd_1 = .
replace imd_1 = 1 if imd == 1
replace imd_1 = 0 if inlist(imd, 2, 3, 4, 5)
label var imd_1 "IMD quintile 1"

generate byte imd_2 = .
replace imd_2 = 1 if imd == 2
replace imd_2 = 0 if inlist(imd, 1, 3, 4, 5)
label var imd_2 "IMD quintile 2"

generate byte imd_3 = .
replace imd_3 = 1 if imd == 3
replace imd_3 = 0 if inlist(imd, 1, 2, 4, 5)
label var imd_3 "IMD quintile 3"

generate byte imd_4 = .
replace imd_4 = 1 if imd == 4
replace imd_4 = 0 if inlist(imd, 1, 2, 3, 5)
label var imd_4 "IMD quintile 4"

generate byte imd_5 = .
replace imd_5 = 1 if imd == 5
replace imd_5 = 0 if inlist(imd, 1, 2, 3, 4)
label var imd_5 "IMD quintile 5"

capture drop care_1
capture drop care_2
capture drop care_3
capture drop care_4
capture drop care_5

generate byte care_1 = .
replace care_1 = 1 if adultcaresx == 1
replace care_1 = 0 if inlist(adultcaresx, 2, 3, 4, 5)
label var care_1 "Adult care very well"

generate byte care_2 = .
replace care_2 = 1 if adultcaresx == 2
replace care_2 = 0 if inlist(adultcaresx, 1, 3, 4, 5)
label var care_2 "Adult care fairly well"

generate byte care_3 = .
replace care_3 = 1 if adultcaresx == 3
replace care_3 = 0 if inlist(adultcaresx, 1, 2, 4, 5)
label var care_3 "Adult care not very well"

generate byte care_4 = .
replace care_4 = 1 if adultcaresx == 4
replace care_4 = 0 if inlist(adultcaresx, 1, 2, 3, 5)
label var care_4 "Adult care not at all"

generate byte care_5 = .
replace care_5 = 1 if adultcaresx == 5
replace care_5 = 0 if inlist(adultcaresx, 1, 2, 3, 4)
label var care_5 "No adult at home"

*-------------------------------------------------------------------------------
* 8. Sample definitions
*-------------------------------------------------------------------------------
capture drop samp_dsm
generate byte samp_dsm = (problem1 == 1) & !missing(dsm_total)
label values samp_dsm LB_YN
label var samp_dsm "Gamblers with observed DSM total"

capture drop samp_rq1
generate byte samp_rq1 = (problem1 == 1) ///
    & !missing(Exactage, gender, Ethnicity, imd, famgam_yes, adultcaresx, ///
               Motive1, Motive2, Motive3, Motive4, Motive5, ///
               g1_any, g2_any, g3_any, school_cluster, survey_weight_pool)
label values samp_rq1 LB_YN
label var samp_rq1 "Participation sample"

capture drop samp_main
generate byte samp_main = (problem1 == 1) & !missing(dsm_total, dsm_cat) ///
    & !missing(Exactage, gender, Ethnicity, imd, famgam_yes, adultcaresx, ///
               Motive1, Motive2, Motive3, Motive4, Motive5, ///
               g1_any, g2_any, g3_any, school_cluster, survey_weight_pool)
label values samp_main LB_YN
label var samp_main "Main harm sample"

capture drop samp_ord
generate byte samp_ord = samp_main == 1
label values samp_ord LB_YN
label var samp_ord "Ordered-outcome sample"

* stratified domain-specific harm samples
capture drop samp_g1_harm
capture drop samp_g2_harm
capture drop samp_g3_harm

generate byte samp_g1_harm = samp_main == 1 & g1_any == 1
generate byte samp_g2_harm = samp_main == 1 & g2_any == 1
generate byte samp_g3_harm = samp_main == 1 & g3_any == 1

label values samp_g1_harm LB_YN
label values samp_g2_harm LB_YN
label values samp_g3_harm LB_YN

label var samp_g1_harm "Harm sample among arcade gamblers"
label var samp_g2_harm "Harm sample among informal gamblers"
label var samp_g3_harm "Harm sample among regulated gamblers"

* routing checks
assert missing(dsm_total) if problem1 == 0
assert missing(dsm_cat)   if problem1 == 0
assert problem1 == 1 if !missing(dsm_total)
assert problem1 == 1 if !missing(dsm_cat)

count
count if problem1 == 1
count if samp_rq1 == 1
count if samp_main == 1
count if samp_ord == 1
count if samp_g1_harm == 1
count if samp_g2_harm == 1
count if samp_g3_harm == 1

tab survey_year if samp_rq1 == 1, missing
tab survey_year if samp_main == 1, missing

levelsof survey_year if samp_rq1 == 1, local(years_rq1)
local n_rq1 : word count `years_rq1'
assert `n_rq1' == 3

levelsof survey_year if samp_main == 1, local(years_main)
local n_main : word count `years_main'
assert `n_main' == 3

levelsof survey_year if samp_ord == 1, local(years_ord)
local n_ord : word count `years_ord'
assert `n_ord' == 3

*-------------------------------------------------------------------------------
* 9. Construct sample-specific equal-wave pooled weights
*-------------------------------------------------------------------------------
capture drop w_rq1
capture drop w_main
capture drop w_ord
capture drop w_g1
capture drop w_g2
capture drop w_g3

bysort survey_year: egen double sum_wp_rq1  = total(survey_weight_pool) if samp_rq1  == 1
bysort survey_year: egen double sum_wp_main = total(survey_weight_pool) if samp_main == 1
bysort survey_year: egen double sum_wp_ord  = total(survey_weight_pool) if samp_ord  == 1
bysort survey_year: egen double sum_wp_g1   = total(survey_weight_pool) if samp_g1_harm == 1
bysort survey_year: egen double sum_wp_g2   = total(survey_weight_pool) if samp_g2_harm == 1
bysort survey_year: egen double sum_wp_g3   = total(survey_weight_pool) if samp_g3_harm == 1

generate double w_rq1 = .
replace w_rq1 = survey_weight_pool / sum_wp_rq1 * (1/3) if samp_rq1 == 1
label var w_rq1 "Equal-wave pooled weight in participation sample"

generate double w_main = .
replace w_main = survey_weight_pool / sum_wp_main * (1/3) if samp_main == 1
label var w_main "Equal-wave pooled weight in main harm sample"

generate double w_ord = .
replace w_ord = survey_weight_pool / sum_wp_ord * (1/3) if samp_ord == 1
label var w_ord "Equal-wave pooled weight in ordered-outcome sample"

generate double w_g1 = .
replace w_g1 = survey_weight_pool / sum_wp_g1 * (1/3) if samp_g1_harm == 1
label var w_g1 "Equal-wave pooled weight among arcade gamblers"

generate double w_g2 = .
replace w_g2 = survey_weight_pool / sum_wp_g2 * (1/3) if samp_g2_harm == 1
label var w_g2 "Equal-wave pooled weight among informal gamblers"

generate double w_g3 = .
replace w_g3 = survey_weight_pool / sum_wp_g3 * (1/3) if samp_g3_harm == 1
label var w_g3 "Equal-wave pooled weight among regulated gamblers"

drop sum_wp_rq1 sum_wp_main sum_wp_ord sum_wp_g1 sum_wp_g2 sum_wp_g3

assert w_rq1  > 0 if samp_rq1 == 1
assert w_main > 0 if samp_main == 1
assert w_ord  > 0 if samp_ord == 1
assert w_g1   > 0 if samp_g1_harm == 1
assert w_g2   > 0 if samp_g2_harm == 1
assert w_g3   > 0 if samp_g3_harm == 1

*-------------------------------------------------------------------------------
* 10. Save analysis-ready subset
*-------------------------------------------------------------------------------
save "${processed}/ypgs_2022_2024_common_analysis.dta", replace

*-------------------------------------------------------------------------------
* 11. Descriptive statistics
*-------------------------------------------------------------------------------

* prevalence of gambling per se
proportion problem1 [pw=survey_weight_pool], over(survey_year)
proportion problem1 [pw=survey_weight_pool], over(Exactage)

* gambling domain prevalence among gamblers
mean g1_any g2_any g3_any [pw=w_rq1] if samp_rq1 == 1, over(survey_year)

* overlap structure among gamblers with complete group information
tab n_any_groups if problem1 == 1 & group_complete3 == 1, missing

* weighted means in main harm sample by year
mean Exactage dsm_total g1_any g2_any g3_any ///
     g0_me g1_me g2_me g3_me multi ///
     female another_gender ///
     eth_1 eth_2 eth_3 eth_4 eth_5 ///
     imd_1 imd_2 imd_3 imd_4 imd_5 ///
     famgam_yes ///
     care_1 care_2 care_3 care_4 care_5 ///
     Motive1 Motive2 Motive3 Motive4 Motive5 ///
     [pw=w_main] if samp_main == 1, over(survey_year)

tab dsm_total if samp_main == 1, missing
summarize dsm_total if samp_main == 1, detail
mean dsm_total [pw=w_main] if samp_main == 1
tab dsm_cat if samp_ord == 1, missing

* QA only
tab gender survey_year if samp_main == 1, missing col
tab Ethnicity survey_year if samp_main == 1, missing col
tab imd survey_year if samp_main == 1, missing col
tab adultcaresx survey_year if samp_main == 1, missing col

*-------------------------------------------------------------------------------
* 12. RQ1: Benchmark single-equation participation models
*-------------------------------------------------------------------------------

* Arcade
probit g1_any c.Exactage i.gender i.Ethnicity i.imd i.survey_year ///
    [pw=w_rq1] if samp_rq1 == 1, vce(cluster school_cluster)
margins, dydx(Exactage gender Ethnicity imd)

probit g1_any i.famgam_yes i.adultcaresx i.survey_year ///
    [pw=w_rq1] if samp_rq1 == 1, vce(cluster school_cluster)
margins, dydx(famgam_yes)
margins adultcaresx

probit g1_any i.Motive1 i.Motive2 i.Motive3 i.Motive4 i.Motive5 i.survey_year ///
    [pw=w_rq1] if samp_rq1 == 1, vce(cluster school_cluster)
margins, dydx(Motive1 Motive2 Motive3 Motive4 Motive5)

probit g1_any c.Exactage i.gender i.Ethnicity i.imd ///
    i.famgam_yes i.adultcaresx ///
    i.Motive1 i.Motive2 i.Motive3 i.Motive4 i.Motive5 ///
    i.survey_year [pw=w_rq1] if samp_rq1 == 1, vce(cluster school_cluster)
margins, dydx(Exactage famgam_yes Motive1 Motive2 Motive3 Motive4 Motive5)
margins adultcaresx

* Informal
probit g2_any c.Exactage i.gender i.Ethnicity i.imd i.survey_year ///
    [pw=w_rq1] if samp_rq1 == 1, vce(cluster school_cluster)
margins, dydx(Exactage gender Ethnicity imd)

probit g2_any i.famgam_yes i.adultcaresx i.survey_year ///
    [pw=w_rq1] if samp_rq1 == 1, vce(cluster school_cluster)
margins, dydx(famgam_yes)
margins adultcaresx

probit g2_any i.Motive1 i.Motive2 i.Motive3 i.Motive4 i.Motive5 i.survey_year ///
    [pw=w_rq1] if samp_rq1 == 1, vce(cluster school_cluster)
margins, dydx(Motive1 Motive2 Motive3 Motive4 Motive5)

probit g2_any c.Exactage i.gender i.Ethnicity i.imd ///
    i.famgam_yes i.adultcaresx ///
    i.Motive1 i.Motive2 i.Motive3 i.Motive4 i.Motive5 ///
    i.survey_year [pw=w_rq1] if samp_rq1 == 1, vce(cluster school_cluster)
margins, dydx(Exactage famgam_yes Motive1 Motive2 Motive3 Motive4 Motive5)
margins adultcaresx

* Regulated
probit g3_any c.Exactage i.gender i.Ethnicity i.imd i.survey_year ///
    [pw=w_rq1] if samp_rq1 == 1, vce(cluster school_cluster)
margins, dydx(Exactage gender Ethnicity imd)

probit g3_any i.famgam_yes i.adultcaresx i.survey_year ///
    [pw=w_rq1] if samp_rq1 == 1, vce(cluster school_cluster)
margins, dydx(famgam_yes)
margins adultcaresx

probit g3_any i.Motive1 i.Motive2 i.Motive3 i.Motive4 i.Motive5 i.survey_year ///
    [pw=w_rq1] if samp_rq1 == 1, vce(cluster school_cluster)
margins, dydx(Motive1 Motive2 Motive3 Motive4 Motive5)

probit g3_any c.Exactage i.gender i.Ethnicity i.imd ///
    i.famgam_yes i.adultcaresx ///
    i.Motive1 i.Motive2 i.Motive3 i.Motive4 i.Motive5 ///
    i.survey_year [pw=w_rq1] if samp_rq1 == 1, vce(cluster school_cluster)
margins, dydx(Exactage famgam_yes Motive1 Motive2 Motive3 Motive4 Motive5)
margins adultcaresx

*-------------------------------------------------------------------------------
* 13. RQ2: Harm models among gamblers only
*-------------------------------------------------------------------------------

* OLS
reg dsm_total i.g1_any i.g2_any i.g3_any i.survey_year ///
    [pw=w_main] if samp_main == 1, vce(cluster school_cluster)

reg dsm_total i.g1_any i.g2_any i.g3_any ///
    c.Exactage i.gender i.Ethnicity i.imd i.survey_year ///
    [pw=w_main] if samp_main == 1, vce(cluster school_cluster)

reg dsm_total i.g1_any i.g2_any i.g3_any ///
    i.famgam_yes i.adultcaresx i.survey_year ///
    [pw=w_main] if samp_main == 1, vce(cluster school_cluster)

reg dsm_total i.g1_any i.g2_any i.g3_any ///
    i.Motive1 i.Motive2 i.Motive3 i.Motive4 i.Motive5 i.survey_year ///
    [pw=w_main] if samp_main == 1, vce(cluster school_cluster)

reg dsm_total i.g1_any i.g2_any i.g3_any ///
    c.Exactage i.gender i.Ethnicity i.imd ///
    i.famgam_yes i.adultcaresx ///
    i.Motive1 i.Motive2 i.Motive3 i.Motive4 i.Motive5 ///
    i.survey_year [pw=w_main] if samp_main == 1, vce(cluster school_cluster)

* Negative binomial
nbreg dsm_total i.g1_any i.g2_any i.g3_any i.survey_year ///
    [pw=w_main] if samp_main == 1, vce(cluster school_cluster)
margins, dydx(g1_any g2_any g3_any)

nbreg dsm_total i.g1_any i.g2_any i.g3_any ///
    c.Exactage i.gender i.Ethnicity i.imd i.survey_year ///
    [pw=w_main] if samp_main == 1, vce(cluster school_cluster)
margins, dydx(g1_any g2_any g3_any)

nbreg dsm_total i.g1_any i.g2_any i.g3_any ///
    i.famgam_yes i.adultcaresx i.survey_year ///
    [pw=w_main] if samp_main == 1, vce(cluster school_cluster)
margins, dydx(g1_any g2_any g3_any)

nbreg dsm_total i.g1_any i.g2_any i.g3_any ///
    i.Motive1 i.Motive2 i.Motive3 i.Motive4 i.Motive5 i.survey_year ///
    [pw=w_main] if samp_main == 1, vce(cluster school_cluster)
margins, dydx(g1_any g2_any g3_any)

nbreg dsm_total i.g1_any i.g2_any i.g3_any ///
    c.Exactage i.gender i.Ethnicity i.imd ///
    i.famgam_yes i.adultcaresx ///
    i.Motive1 i.Motive2 i.Motive3 i.Motive4 i.Motive5 ///
    i.survey_year [pw=w_main] if samp_main == 1, vce(cluster school_cluster)
margins, dydx(g1_any g2_any g3_any)

*-------------------------------------------------------------------------------
* 14. RQ3: Moderation by family gambling exposure
*-------------------------------------------------------------------------------
reg dsm_total i.g1_any##i.famgam_yes ///
    c.Exactage i.gender i.Ethnicity i.imd i.adultcaresx ///
    i.Motive1 i.Motive2 i.Motive3 i.Motive4 i.Motive5 i.survey_year ///
    [pw=w_main] if samp_main == 1, vce(cluster school_cluster)

reg dsm_total i.g2_any##i.famgam_yes ///
    c.Exactage i.gender i.Ethnicity i.imd i.adultcaresx ///
    i.Motive1 i.Motive2 i.Motive3 i.Motive4 i.Motive5 i.survey_year ///
    [pw=w_main] if samp_main == 1, vce(cluster school_cluster)

reg dsm_total i.g3_any##i.famgam_yes ///
    c.Exactage i.gender i.Ethnicity i.imd i.adultcaresx ///
    i.Motive1 i.Motive2 i.Motive3 i.Motive4 i.Motive5 i.survey_year ///
    [pw=w_main] if samp_main == 1, vce(cluster school_cluster)

nbreg dsm_total i.g1_any##i.famgam_yes ///
    c.Exactage i.gender i.Ethnicity i.imd i.adultcaresx ///
    i.Motive1 i.Motive2 i.Motive3 i.Motive4 i.Motive5 i.survey_year ///
    [pw=w_main] if samp_main == 1, vce(cluster school_cluster)
margins famgam_yes, dydx(g1_any)

nbreg dsm_total i.g2_any##i.famgam_yes ///
    c.Exactage i.gender i.Ethnicity i.imd i.adultcaresx ///
    i.Motive1 i.Motive2 i.Motive3 i.Motive4 i.Motive5 i.survey_year ///
    [pw=w_main] if samp_main == 1, vce(cluster school_cluster)
margins famgam_yes, dydx(g2_any)

nbreg dsm_total i.g3_any##i.famgam_yes ///
    c.Exactage i.gender i.Ethnicity i.imd i.adultcaresx ///
    i.Motive1 i.Motive2 i.Motive3 i.Motive4 i.Motive5 i.survey_year ///
    [pw=w_main] if samp_main == 1, vce(cluster school_cluster)
margins famgam_yes, dydx(g3_any)

*-------------------------------------------------------------------------------
* 15. RQ4: Moderation by adult care
*-------------------------------------------------------------------------------
reg dsm_total i.g1_any##i.adultcaresx ///
    c.Exactage i.gender i.Ethnicity i.imd i.famgam_yes ///
    i.Motive1 i.Motive2 i.Motive3 i.Motive4 i.Motive5 i.survey_year ///
    [pw=w_main] if samp_main == 1, vce(cluster school_cluster)

reg dsm_total i.g2_any##i.adultcaresx ///
    c.Exactage i.gender i.Ethnicity i.imd i.famgam_yes ///
    i.Motive1 i.Motive2 i.Motive3 i.Motive4 i.Motive5 i.survey_year ///
    [pw=w_main] if samp_main == 1, vce(cluster school_cluster)

reg dsm_total i.g3_any##i.adultcaresx ///
    c.Exactage i.gender i.Ethnicity i.imd i.famgam_yes ///
    i.Motive1 i.Motive2 i.Motive3 i.Motive4 i.Motive5 i.survey_year ///
    [pw=w_main] if samp_main == 1, vce(cluster school_cluster)

nbreg dsm_total i.g1_any##i.adultcaresx ///
    c.Exactage i.gender i.Ethnicity i.imd i.famgam_yes ///
    i.Motive1 i.Motive2 i.Motive3 i.Motive4 i.Motive5 i.survey_year ///
    [pw=w_main] if samp_main == 1, vce(cluster school_cluster)
margins adultcaresx, dydx(g1_any)

nbreg dsm_total i.g2_any##i.adultcaresx ///
    c.Exactage i.gender i.Ethnicity i.imd i.famgam_yes ///
    i.Motive1 i.Motive2 i.Motive3 i.Motive4 i.Motive5 i.survey_year ///
    [pw=w_main] if samp_main == 1, vce(cluster school_cluster)
margins adultcaresx, dydx(g2_any)

nbreg dsm_total i.g3_any##i.adultcaresx ///
    c.Exactage i.gender i.Ethnicity i.imd i.famgam_yes ///
    i.Motive1 i.Motive2 i.Motive3 i.Motive4 i.Motive5 i.survey_year ///
    [pw=w_main] if samp_main == 1, vce(cluster school_cluster)
margins adultcaresx, dydx(g3_any)

*-------------------------------------------------------------------------------
* 16. RQ5: Moderation by motives on DSM total
*-------------------------------------------------------------------------------
reg dsm_total i.g1_any##i.Motive1 i.g1_any##i.Motive2 i.g1_any##i.Motive3 i.g1_any##i.Motive4 i.g1_any##i.Motive5 ///
    c.Exactage i.gender i.Ethnicity i.imd i.famgam_yes i.adultcaresx i.survey_year ///
    [pw=w_main] if samp_main == 1, vce(cluster school_cluster)

reg dsm_total i.g2_any##i.Motive1 i.g2_any##i.Motive2 i.g2_any##i.Motive3 i.g2_any##i.Motive4 i.g2_any##i.Motive5 ///
    c.Exactage i.gender i.Ethnicity i.imd i.famgam_yes i.adultcaresx i.survey_year ///
    [pw=w_main] if samp_main == 1, vce(cluster school_cluster)

reg dsm_total i.g3_any##i.Motive1 i.g3_any##i.Motive2 i.g3_any##i.Motive3 i.g3_any##i.Motive4 i.g3_any##i.Motive5 ///
    c.Exactage i.gender i.Ethnicity i.imd i.famgam_yes i.adultcaresx i.survey_year ///
    [pw=w_main] if samp_main == 1, vce(cluster school_cluster)

* one interacted motive at a time in nbreg for interpretability
nbreg dsm_total i.g1_any##i.Motive1 i.Motive2 i.Motive3 i.Motive4 i.Motive5 ///
    c.Exactage i.gender i.Ethnicity i.imd i.famgam_yes i.adultcaresx i.survey_year ///
    [pw=w_main] if samp_main == 1, vce(cluster school_cluster)
margins Motive1, dydx(g1_any)

nbreg dsm_total i.g2_any##i.Motive1 i.Motive2 i.Motive3 i.Motive4 i.Motive5 ///
    c.Exactage i.gender i.Ethnicity i.imd i.famgam_yes i.adultcaresx i.survey_year ///
    [pw=w_main] if samp_main == 1, vce(cluster school_cluster)
margins Motive1, dydx(g2_any)

nbreg dsm_total i.g3_any##i.Motive1 i.Motive2 i.Motive3 i.Motive4 i.Motive5 ///
    c.Exactage i.gender i.Ethnicity i.imd i.famgam_yes i.adultcaresx i.survey_year ///
    [pw=w_main] if samp_main == 1, vce(cluster school_cluster)
margins Motive1, dydx(g3_any)

nbreg dsm_total i.g1_any##i.Motive2 i.Motive1 i.Motive3 i.Motive4 i.Motive5 ///
    c.Exactage i.gender i.Ethnicity i.imd i.famgam_yes i.adultcaresx i.survey_year ///
    [pw=w_main] if samp_main == 1, vce(cluster school_cluster)
margins Motive2, dydx(g1_any)

nbreg dsm_total i.g2_any##i.Motive2 i.Motive1 i.Motive3 i.Motive4 i.Motive5 ///
    c.Exactage i.gender i.Ethnicity i.imd i.famgam_yes i.adultcaresx i.survey_year ///
    [pw=w_main] if samp_main == 1, vce(cluster school_cluster)
margins Motive2, dydx(g2_any)

nbreg dsm_total i.g3_any##i.Motive2 i.Motive1 i.Motive3 i.Motive4 i.Motive5 ///
    c.Exactage i.gender i.Ethnicity i.imd i.famgam_yes i.adultcaresx i.survey_year ///
    [pw=w_main] if samp_main == 1, vce(cluster school_cluster)
margins Motive2, dydx(g3_any)

nbreg dsm_total i.g1_any##i.Motive3 i.Motive1 i.Motive2 i.Motive4 i.Motive5 ///
    c.Exactage i.gender i.Ethnicity i.imd i.famgam_yes i.adultcaresx i.survey_year ///
    [pw=w_main] if samp_main == 1, vce(cluster school_cluster)
margins Motive3, dydx(g1_any)

nbreg dsm_total i.g2_any##i.Motive3 i.Motive1 i.Motive2 i.Motive4 i.Motive5 ///
    c.Exactage i.gender i.Ethnicity i.imd i.famgam_yes i.adultcaresx i.survey_year ///
    [pw=w_main] if samp_main == 1, vce(cluster school_cluster)
margins Motive3, dydx(g2_any)

nbreg dsm_total i.g3_any##i.Motive3 i.Motive1 i.Motive2 i.Motive4 i.Motive5 ///
    c.Exactage i.gender i.Ethnicity i.imd i.famgam_yes i.adultcaresx i.survey_year ///
    [pw=w_main] if samp_main == 1, vce(cluster school_cluster)
margins Motive3, dydx(g3_any)

nbreg dsm_total i.g1_any##i.Motive4 i.Motive1 i.Motive2 i.Motive3 i.Motive5 ///
    c.Exactage i.gender i.Ethnicity i.imd i.famgam_yes i.adultcaresx i.survey_year ///
    [pw=w_main] if samp_main == 1, vce(cluster school_cluster)
margins Motive4, dydx(g1_any)

nbreg dsm_total i.g2_any##i.Motive4 i.Motive1 i.Motive2 i.Motive3 i.Motive5 ///
    c.Exactage i.gender i.Ethnicity i.imd i.famgam_yes i.adultcaresx i.survey_year ///
    [pw=w_main] if samp_main == 1, vce(cluster school_cluster)
margins Motive4, dydx(g2_any)

nbreg dsm_total i.g3_any##i.Motive4 i.Motive1 i.Motive2 i.Motive3 i.Motive5 ///
    c.Exactage i.gender i.Ethnicity i.imd i.famgam_yes i.adultcaresx i.survey_year ///
    [pw=w_main] if samp_main == 1, vce(cluster school_cluster)
margins Motive4, dydx(g3_any)

nbreg dsm_total i.g1_any##i.Motive5 i.Motive1 i.Motive2 i.Motive3 i.Motive4 ///
    c.Exactage i.gender i.Ethnicity i.imd i.famgam_yes i.adultcaresx i.survey_year ///
    [pw=w_main] if samp_main == 1, vce(cluster school_cluster)
margins Motive5, dydx(g1_any)

nbreg dsm_total i.g2_any##i.Motive5 i.Motive1 i.Motive2 i.Motive3 i.Motive4 ///
    c.Exactage i.gender i.Ethnicity i.imd i.famgam_yes i.adultcaresx i.survey_year ///
    [pw=w_main] if samp_main == 1, vce(cluster school_cluster)
margins Motive5, dydx(g2_any)

nbreg dsm_total i.g3_any##i.Motive5 i.Motive1 i.Motive2 i.Motive3 i.Motive4 ///
    c.Exactage i.gender i.Ethnicity i.imd i.famgam_yes i.adultcaresx i.survey_year ///
    [pw=w_main] if samp_main == 1, vce(cluster school_cluster)
margins Motive5, dydx(g3_any)

*-------------------------------------------------------------------------------
* 17. Stratified robustness by gambling category
*-------------------------------------------------------------------------------

* Arcade gamblers only
nbreg dsm_total c.Exactage i.gender i.Ethnicity i.imd ///
    i.famgam_yes i.adultcaresx ///
    i.Motive1 i.Motive2 i.Motive3 i.Motive4 i.Motive5 ///
    i.survey_year [pw=w_g1] if samp_g1_harm == 1, vce(cluster school_cluster)

* Informal gamblers only
nbreg dsm_total c.Exactage i.gender i.Ethnicity i.imd ///
    i.famgam_yes i.adultcaresx ///
    i.Motive1 i.Motive2 i.Motive3 i.Motive4 i.Motive5 ///
    i.survey_year [pw=w_g2] if samp_g2_harm == 1, vce(cluster school_cluster)

* Regulated gamblers only
nbreg dsm_total c.Exactage i.gender i.Ethnicity i.imd ///
    i.famgam_yes i.adultcaresx ///
    i.Motive1 i.Motive2 i.Motive3 i.Motive4 i.Motive5 ///
    i.survey_year [pw=w_g3] if samp_g3_harm == 1, vce(cluster school_cluster)

*-------------------------------------------------------------------------------
* 18. Alternative outcome: ordered DSM category
*-------------------------------------------------------------------------------
tab dsm_cat if samp_ord == 1, missing

oprobit dsm_cat i.g1_any i.g2_any i.g3_any i.survey_year ///
    [pw=w_ord] if samp_ord == 1, vce(cluster school_cluster)
margins, dydx(g1_any g2_any g3_any) predict(outcome(0))
margins, dydx(g1_any g2_any g3_any) predict(outcome(1))
margins, dydx(g1_any g2_any g3_any) predict(outcome(2))

oprobit dsm_cat i.g1_any i.g2_any i.g3_any ///
    c.Exactage i.gender i.Ethnicity i.imd i.survey_year ///
    [pw=w_ord] if samp_ord == 1, vce(cluster school_cluster)
margins, dydx(g1_any g2_any g3_any) predict(outcome(0))
margins, dydx(g1_any g2_any g3_any) predict(outcome(1))
margins, dydx(g1_any g2_any g3_any) predict(outcome(2))

oprobit dsm_cat i.g1_any i.g2_any i.g3_any ///
    i.famgam_yes i.adultcaresx i.survey_year ///
    [pw=w_ord] if samp_ord == 1, vce(cluster school_cluster)
margins, dydx(g1_any g2_any g3_any) predict(outcome(0))
margins, dydx(g1_any g2_any g3_any) predict(outcome(1))
margins, dydx(g1_any g2_any g3_any) predict(outcome(2))

oprobit dsm_cat i.g1_any i.g2_any i.g3_any ///
    i.Motive1 i.Motive2 i.Motive3 i.Motive4 i.Motive5 i.survey_year ///
    [pw=w_ord] if samp_ord == 1, vce(cluster school_cluster)
margins, dydx(g1_any g2_any g3_any) predict(outcome(0))
margins, dydx(g1_any g2_any g3_any) predict(outcome(1))
margins, dydx(g1_any g2_any g3_any) predict(outcome(2))

oprobit dsm_cat i.g1_any i.g2_any i.g3_any ///
    c.Exactage i.gender i.Ethnicity i.imd ///
    i.famgam_yes i.adultcaresx ///
    i.Motive1 i.Motive2 i.Motive3 i.Motive4 i.Motive5 ///
    i.survey_year [pw=w_ord] if samp_ord == 1, vce(cluster school_cluster)
margins, dydx(g1_any g2_any g3_any) predict(outcome(0))
margins, dydx(g1_any g2_any g3_any) predict(outcome(1))
margins, dydx(g1_any g2_any g3_any) predict(outcome(2))

* adult care moderation in ordered outcome
oprobit dsm_cat i.adultcaresx##(i.g1_any i.g2_any i.g3_any) i.survey_year ///
    [pw=w_ord] if samp_ord == 1, vce(cluster school_cluster)
margins adultcaresx, dydx(g1_any g2_any g3_any) predict(outcome(0))
margins adultcaresx, dydx(g1_any g2_any g3_any) predict(outcome(1))
margins adultcaresx, dydx(g1_any g2_any g3_any) predict(outcome(2))

*-------------------------------------------------------------------------------
* 19. Save final analysis dataset
*-------------------------------------------------------------------------------
save "${processed}/ypgs_2022_2024_common_analysis.dta", replace

* Optional log close
* log close

/*******************************************************************************
End of do-file
*******************************************************************************/
