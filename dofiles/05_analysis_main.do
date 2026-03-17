/*******************************************************************************
Project: Family, Motivation and Harm
Data: YPGS 2022–2024 pooled from common comparable population
Do file name: 05_analysis_main.do
Authors: Kim, Stowasser, Newall
Date created: 16 Mar 2026
Date edited: 17 Mar 2026
Version: 3

Purpose:
- Build the 2022–2024 common-sample analytic file
- Define analysis samples for participation and harm models
- Construct sample-specific equal-wave pooled weights
- Cluster standard errors at the wave-specific school level
- Run main descriptive statistics and regression models

Key design choices:
- Restrict to survey_year 2022, 2023, and 2024
- Restrict to samp_common == 1
- RQ1 uses gamblers with complete covariates, motives, and group flags
- RQ2–RQ5 use gamblers with observed DSM outcomes plus complete covariates
- Use sample-specific renormalized pooled weights:
    w_rq1  for participation models
    w_main for harm models
    w_ord  for ordered-outcome models
- In nonlinear models, interpret interactions via margins, not raw coefficients
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
* 3. Check existing pooled weights from construction stage
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
* 5. Recode / relabel covariates for analysis
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
label var adultcaresx "Adult care category"

* gender:
* 1 boy, 2 girl, 3 in another way, 4 prefer not to say
recode gender (4=.)
label var gender "Gender"

* family gambling exposure:
* 1 yes, 2 no, 3 don't know, 4 prefer not to say, 5 not stated
capture drop famgam_yes
generate byte famgam_yes = .
replace famgam_yes = 1 if famgam == 1
replace famgam_yes = 0 if famgam == 2
label values famgam_yes LB_YN
label var famgam_yes "Family gambling exposure"

* Ethnicity:
* keep substantive categories; drop explicit nonresponse only
recode Ethnicity (6=.)
label var Ethnicity "Ethnicity"

*-------------------------------------------------------------------------------
* 6. Cluster identifier
*-------------------------------------------------------------------------------
count if missing(schoolid)
assert !missing(schoolid)

capture drop school_cluster
egen long school_cluster = group(survey_year schoolid)
label var school_cluster "Wave-specific school cluster"

*-------------------------------------------------------------------------------
* 7. Sample definitions
*-------------------------------------------------------------------------------

* DSM-observed gambler sample
capture drop samp_dsm
generate byte samp_dsm = (problem1 == 1) & !missing(dsm_total)
label values samp_dsm LB_YN
label var samp_dsm "Gamblers with observed DSM total"

* RQ1 sample:
* gamblers only, no conditioning on DSM observability
capture drop samp_rq1
generate byte samp_rq1 = (problem1 == 1) ///
    & !missing(Exactage, gender, Ethnicity, imd, famgam_yes, adultcaresx, ///
               Motive1, Motive2, Motive3, Motive4, Motive5, ///
               g1_any, g2_any, g3_any, school_cluster, survey_weight)
label values samp_rq1 LB_YN
label var samp_rq1 "RQ1 sample: gamblers with complete covariates, motives, and group flags"

* Main harm-regression sample:
* DSM-complete gamblers only
capture drop samp_main
generate byte samp_main = (problem1 == 1) & !missing(dsm_total, dsm_cat) ///
    & !missing(Exactage, gender, Ethnicity, imd, famgam_yes, adultcaresx, ///
               Motive1, Motive2, Motive3, Motive4, Motive5, ///
               g1_any, g2_any, g3_any, school_cluster, survey_weight)
label values samp_main LB_YN
label var samp_main "Main analytic sample: DSM-complete gamblers with complete covariates"

* Ordered-outcome sample
capture drop samp_ord
generate byte samp_ord = samp_main == 1
label values samp_ord LB_YN
label var samp_ord "Ordered-outcome sample"

* Routing checks
assert missing(dsm_total) if problem1 == 0
assert missing(dsm_cat)   if problem1 == 0
assert problem1 == 1 if !missing(dsm_total)
assert problem1 == 1 if !missing(dsm_cat)

* Sample counts
count
count if problem1 == 1
count if samp_rq1 == 1
count if samp_main == 1
count if samp_ord == 1

tab survey_year if samp_rq1 == 1, missing
tab survey_year if samp_main == 1, missing

* Verify all three waves survive in each analysis sample
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
* 8. Construct sample-specific equal-wave pooled weights
*-------------------------------------------------------------------------------
capture drop w_rq1
capture drop w_main
capture drop w_ord

bysort survey_year: egen double sum_w_rq1  = total(survey_weight) if samp_rq1  == 1
bysort survey_year: egen double sum_w_main = total(survey_weight) if samp_main == 1
bysort survey_year: egen double sum_w_ord  = total(survey_weight) if samp_ord  == 1

generate double w_rq1 = .
replace w_rq1 = survey_weight / sum_w_rq1 * (1/3) if samp_rq1 == 1
label var w_rq1 "Equal-wave pooled weight in RQ1 sample"

generate double w_main = .
replace w_main = survey_weight / sum_w_main * (1/3) if samp_main == 1
label var w_main "Equal-wave pooled weight in main harm sample"

generate double w_ord = .
replace w_ord = survey_weight / sum_w_ord * (1/3) if samp_ord == 1
label var w_ord "Equal-wave pooled weight in ordered-outcome sample"

drop sum_w_rq1 sum_w_main sum_w_ord

* QA: within-sample weights should sum to about 1/3 by wave and 1 overall
bysort survey_year: egen double check_rq1 = total(w_rq1)
tabstat check_rq1 if samp_rq1 == 1, by(survey_year) stat(mean)
drop check_rq1

bysort survey_year: egen double check_main = total(w_main)
tabstat check_main if samp_main == 1, by(survey_year) stat(mean)
drop check_main

bysort survey_year: egen double check_ord = total(w_ord)
tabstat check_ord if samp_ord == 1, by(survey_year) stat(mean)
drop check_ord

egen double total_rq1 = total(w_rq1)
summarize total_rq1
drop total_rq1

egen double total_main = total(w_main)
summarize total_main
drop total_main

egen double total_ord = total(w_ord)
summarize total_ord
drop total_ord

assert w_rq1  > 0 if samp_rq1  == 1
assert w_main > 0 if samp_main == 1
assert w_ord  > 0 if samp_ord  == 1

*-------------------------------------------------------------------------------
* 9. Save analysis-ready subset
*-------------------------------------------------------------------------------
save "${processed}/ypgs_2022_2024_common_analysis.dta", replace

*-------------------------------------------------------------------------------
* 10. Descriptive statistics
*-------------------------------------------------------------------------------

* Overall prevalence of own-money gambling by year
proportion problem1 [pw=survey_weight_pool], over(survey_year)

* Overall prevalence of own-money gambling by age
proportion problem1 [pw=survey_weight_pool], over(Exactage)

* Overlapping-group prevalence among gamblers in RQ1 sample
mean g1_any g2_any g3_any [pw=w_rq1] if samp_rq1 == 1, over(survey_year)

* Overlap count among gamblers with complete group information
tab n_any_groups if problem1 == 1 & group_complete3 == 1, missing

* Year-specific weighted means in main sample
mean Exactage dsm_total g1_any g2_any g3_any ///
     g0_me g1_me g2_me g3_me multi ///
     [pw=w_main] if samp_main == 1, over(survey_year)

* Weighted proportions for key covariates by year
proportion gender if samp_main == 1 [pw=w_main], over(survey_year)
proportion Ethnicity if samp_main == 1 [pw=w_main], over(survey_year)
proportion imd if samp_main == 1 [pw=w_main], over(survey_year)
proportion famgam_yes if samp_main == 1 [pw=w_main], over(survey_year)
proportion adultcaresx if samp_main == 1 [pw=w_main], over(survey_year)
proportion Motive1 if samp_main == 1 [pw=w_main], over(survey_year)
proportion Motive2 if samp_main == 1 [pw=w_main], over(survey_year)
proportion Motive3 if samp_main == 1 [pw=w_main], over(survey_year)
proportion Motive4 if samp_main == 1 [pw=w_main], over(survey_year)
proportion Motive5 if samp_main == 1 [pw=w_main], over(survey_year)

* Outcome distributions
tab dsm_total if samp_main == 1, missing
summarize dsm_total if samp_main == 1, detail
mean dsm_total [pw=w_main] if samp_main == 1

tab dsm_cat if samp_ord == 1, missing

*-------------------------------------------------------------------------------
* 11. RQ1: Who becomes which gambler? (single-equation participation models)
*-------------------------------------------------------------------------------

*-------------------
* Arcade group
*-------------------

* Spec I: demographics
probit g1_any c.Exactage i.gender i.Ethnicity i.imd i.survey_year ///
    [pw=w_rq1] if samp_rq1 == 1, vce(cluster school_cluster)
margins, dydx(Exactage gender Ethnicity imd)

* Spec II: family environment
probit g1_any i.famgam_yes i.adultcaresx i.survey_year ///
    [pw=w_rq1] if samp_rq1 == 1, vce(cluster school_cluster)
margins, dydx(famgam_yes)
margins adultcaresx

* Spec III: motives
probit g1_any i.(Motive1 Motive2 Motive3 Motive4 Motive5) i.survey_year ///
    [pw=w_rq1] if samp_rq1 == 1, vce(cluster school_cluster)
margins, dydx(Motive1 Motive2 Motive3 Motive4 Motive5)

* Spec IV: full model
probit g1_any c.Exactage i.gender i.Ethnicity i.imd ///
    i.famgam_yes i.adultcaresx ///
    i.(Motive1 Motive2 Motive3 Motive4 Motive5) ///
    i.survey_year [pw=w_rq1] if samp_rq1 == 1, vce(cluster school_cluster)
margins, dydx(Exactage famgam_yes Motive1 Motive2 Motive3 Motive4 Motive5)
margins adultcaresx

*-------------------
* Informal-setting group
*-------------------

* Spec I: demographics
probit g2_any c.Exactage i.gender i.Ethnicity i.imd i.survey_year ///
    [pw=w_rq1] if samp_rq1 == 1, vce(cluster school_cluster)
margins, dydx(Exactage gender Ethnicity imd)

* Spec II: family environment
probit g2_any i.famgam_yes i.adultcaresx i.survey_year ///
    [pw=w_rq1] if samp_rq1 == 1, vce(cluster school_cluster)
margins, dydx(famgam_yes)
margins adultcaresx

* Spec III: motives
probit g2_any i.(Motive1 Motive2 Motive3 Motive4 Motive5) i.survey_year ///
    [pw=w_rq1] if samp_rq1 == 1, vce(cluster school_cluster)
margins, dydx(Motive1 Motive2 Motive3 Motive4 Motive5)

* Spec IV: full model
probit g2_any c.Exactage i.gender i.Ethnicity i.imd ///
    i.famgam_yes i.adultcaresx ///
    i.(Motive1 Motive2 Motive3 Motive4 Motive5) ///
    i.survey_year [pw=w_rq1] if samp_rq1 == 1, vce(cluster school_cluster)
margins, dydx(Exactage famgam_yes Motive1 Motive2 Motive3 Motive4 Motive5)
margins adultcaresx

*-------------------
* Regulated-setting group
*-------------------

* Spec I: demographics
probit g3_any c.Exactage i.gender i.Ethnicity i.imd i.survey_year ///
    [pw=w_rq1] if samp_rq1 == 1, vce(cluster school_cluster)
margins, dydx(Exactage gender Ethnicity imd)

* Spec II: family environment
probit g3_any i.famgam_yes i.adultcaresx i.survey_year ///
    [pw=w_rq1] if samp_rq1 == 1, vce(cluster school_cluster)
margins, dydx(famgam_yes)
margins adultcaresx

* Spec III: motives
probit g3_any i.(Motive1 Motive2 Motive3 Motive4 Motive5) i.survey_year ///
    [pw=w_rq1] if samp_rq1 == 1, vce(cluster school_cluster)
margins, dydx(Motive1 Motive2 Motive3 Motive4 Motive5)

* Spec IV: full model
probit g3_any c.Exactage i.gender i.Ethnicity i.imd ///
    i.famgam_yes i.adultcaresx ///
    i.(Motive1 Motive2 Motive3 Motive4 Motive5) ///
    i.survey_year [pw=w_rq1] if samp_rq1 == 1, vce(cluster school_cluster)
margins, dydx(Exactage famgam_yes Motive1 Motive2 Motive3 Motive4 Motive5)
margins adultcaresx

*-------------------------------------------------------------------------------
* 12. RQ2: Harm regressions (DSM-complete gambler sample)
*      Outcome: dsm_total
*      Models: OLS and NBREG
*-------------------------------------------------------------------------------

*-------------------
* OLS
*-------------------

* Spec I: no controls
reg dsm_total i.g1_any i.g2_any i.g3_any i.survey_year ///
    [pw=w_main] if samp_main == 1, vce(cluster school_cluster)

* Spec II: demographics
reg dsm_total i.g1_any i.g2_any i.g3_any ///
    c.Exactage i.gender i.Ethnicity i.imd i.survey_year ///
    [pw=w_main] if samp_main == 1, vce(cluster school_cluster)

* Spec III: family environment
reg dsm_total i.g1_any i.g2_any i.g3_any ///
    i.famgam_yes i.adultcaresx i.survey_year ///
    [pw=w_main] if samp_main == 1, vce(cluster school_cluster)

* Spec IV: motives
reg dsm_total i.g1_any i.g2_any i.g3_any ///
    i.(Motive1 Motive2 Motive3 Motive4 Motive5) i.survey_year ///
    [pw=w_main] if samp_main == 1, vce(cluster school_cluster)

* Spec V: full model
reg dsm_total i.g1_any i.g2_any i.g3_any ///
    c.Exactage i.gender i.Ethnicity i.imd ///
    i.famgam_yes i.adultcaresx ///
    i.(Motive1 Motive2 Motive3 Motive4 Motive5) ///
    i.survey_year [pw=w_main] if samp_main == 1, vce(cluster school_cluster)

*-------------------
* Negative binomial
*-------------------

* Spec I: no controls
nbreg dsm_total i.g1_any i.g2_any i.g3_any i.survey_year ///
    [pw=w_main] if samp_main == 1, vce(cluster school_cluster)
margins, dydx(g1_any g2_any g3_any)

* Spec II: demographics
nbreg dsm_total i.g1_any i.g2_any i.g3_any ///
    c.Exactage i.gender i.Ethnicity i.imd i.survey_year ///
    [pw=w_main] if samp_main == 1, vce(cluster school_cluster)
margins, dydx(g1_any g2_any g3_any)

* Spec III: family environment
nbreg dsm_total i.g1_any i.g2_any i.g3_any ///
    i.famgam_yes i.adultcaresx i.survey_year ///
    [pw=w_main] if samp_main == 1, vce(cluster school_cluster)
margins, dydx(g1_any g2_any g3_any)

* Spec IV: motives
nbreg dsm_total i.g1_any i.g2_any i.g3_any ///
    i.(Motive1 Motive2 Motive3 Motive4 Motive5) i.survey_year ///
    [pw=w_main] if samp_main == 1, vce(cluster school_cluster)
margins, dydx(g1_any g2_any g3_any)

* Spec V: full model
nbreg dsm_total i.g1_any i.g2_any i.g3_any ///
    c.Exactage i.gender i.Ethnicity i.imd ///
    i.famgam_yes i.adultcaresx ///
    i.(Motive1 Motive2 Motive3 Motive4 Motive5) ///
    i.survey_year [pw=w_main] if samp_main == 1, vce(cluster school_cluster)
margins, dydx(g1_any g2_any g3_any)

*-------------------------------------------------------------------------------
* 13. RQ3: Moderation by family gambling exposure
*-------------------------------------------------------------------------------

*-------------------
* OLS
*-------------------

* Arcade x family gambling
reg dsm_total i.g1_any##i.famgam_yes ///
    c.Exactage i.gender i.Ethnicity i.imd i.adultcaresx ///
    i.(Motive1 Motive2 Motive3 Motive4 Motive5) i.survey_year ///
    [pw=w_main] if samp_main == 1, vce(cluster school_cluster)

* Informal x family gambling
reg dsm_total i.g2_any##i.famgam_yes ///
    c.Exactage i.gender i.Ethnicity i.imd i.adultcaresx ///
    i.(Motive1 Motive2 Motive3 Motive4 Motive5) i.survey_year ///
    [pw=w_main] if samp_main == 1, vce(cluster school_cluster)

* Regulated x family gambling
reg dsm_total i.g3_any##i.famgam_yes ///
    c.Exactage i.gender i.Ethnicity i.imd i.adultcaresx ///
    i.(Motive1 Motive2 Motive3 Motive4 Motive5) i.survey_year ///
    [pw=w_main] if samp_main == 1, vce(cluster school_cluster)

*-------------------
* Negative binomial
*-------------------

* Arcade x family gambling
nbreg dsm_total i.g1_any##i.famgam_yes ///
    c.Exactage i.gender i.Ethnicity i.imd i.adultcaresx ///
    i.(Motive1 Motive2 Motive3 Motive4 Motive5) i.survey_year ///
    [pw=w_main] if samp_main == 1, vce(cluster school_cluster)
margins famgam_yes, dydx(g1_any)

* Informal x family gambling
nbreg dsm_total i.g2_any##i.famgam_yes ///
    c.Exactage i.gender i.Ethnicity i.imd i.adultcaresx ///
    i.(Motive1 Motive2 Motive3 Motive4 Motive5) i.survey_year ///
    [pw=w_main] if samp_main == 1, vce(cluster school_cluster)
margins famgam_yes, dydx(g2_any)

* Regulated x family gambling
nbreg dsm_total i.g3_any##i.famgam_yes ///
    c.Exactage i.gender i.Ethnicity i.imd i.adultcaresx ///
    i.(Motive1 Motive2 Motive3 Motive4 Motive5) i.survey_year ///
    [pw=w_main] if samp_main == 1, vce(cluster school_cluster)
margins famgam_yes, dydx(g3_any)

*-------------------------------------------------------------------------------
* 14. RQ4: Moderation by adult care
*-------------------------------------------------------------------------------

*-------------------
* OLS
*-------------------

* Arcade x adult care
reg dsm_total i.g1_any##i.adultcaresx ///
    c.Exactage i.gender i.Ethnicity i.imd i.famgam_yes ///
    i.(Motive1 Motive2 Motive3 Motive4 Motive5) i.survey_year ///
    [pw=w_main] if samp_main == 1, vce(cluster school_cluster)

* Informal x adult care
reg dsm_total i.g2_any##i.adultcaresx ///
    c.Exactage i.gender i.Ethnicity i.imd i.famgam_yes ///
    i.(Motive1 Motive2 Motive3 Motive4 Motive5) i.survey_year ///
    [pw=w_main] if samp_main == 1, vce(cluster school_cluster)

* Regulated x adult care
reg dsm_total i.g3_any##i.adultcaresx ///
    c.Exactage i.gender i.Ethnicity i.imd i.famgam_yes ///
    i.(Motive1 Motive2 Motive3 Motive4 Motive5) i.survey_year ///
    [pw=w_main] if samp_main == 1, vce(cluster school_cluster)

*-------------------
* Negative binomial
*-------------------

* Arcade x adult care
nbreg dsm_total i.g1_any##i.adultcaresx ///
    c.Exactage i.gender i.Ethnicity i.imd i.famgam_yes ///
    i.(Motive1 Motive2 Motive3 Motive4 Motive5) i.survey_year ///
    [pw=w_main] if samp_main == 1, vce(cluster school_cluster)
margins adultcaresx, dydx(g1_any)

* Informal x adult care
nbreg dsm_total i.g2_any##i.adultcaresx ///
    c.Exactage i.gender i.Ethnicity i.imd i.famgam_yes ///
    i.(Motive1 Motive2 Motive3 Motive4 Motive5) i.survey_year ///
    [pw=w_main] if samp_main == 1, vce(cluster school_cluster)
margins adultcaresx, dydx(g2_any)

* Regulated x adult care
nbreg dsm_total i.g3_any##i.adultcaresx ///
    c.Exactage i.gender i.Ethnicity i.imd i.famgam_yes ///
    i.(Motive1 Motive2 Motive3 Motive4 Motive5) i.survey_year ///
    [pw=w_main] if samp_main == 1, vce(cluster school_cluster)
margins adultcaresx, dydx(g3_any)

*-------------------------------------------------------------------------------
* 15. RQ5: Moderation by motives on DSM total
*-------------------------------------------------------------------------------

*-------------------
* OLS
*-------------------

* Arcade x motives
reg dsm_total i.g1_any##i.(Motive1 Motive2 Motive3 Motive4 Motive5) ///
    c.Exactage i.gender i.Ethnicity i.imd i.famgam_yes i.adultcaresx i.survey_year ///
    [pw=w_main] if samp_main == 1, vce(cluster school_cluster)

* Informal x motives
reg dsm_total i.g2_any##i.(Motive1 Motive2 Motive3 Motive4 Motive5) ///
    c.Exactage i.gender i.Ethnicity i.imd i.famgam_yes i.adultcaresx i.survey_year ///
    [pw=w_main] if samp_main == 1, vce(cluster school_cluster)

* Regulated x motives
reg dsm_total i.g3_any##i.(Motive1 Motive2 Motive3 Motive4 Motive5) ///
    c.Exactage i.gender i.Ethnicity i.imd i.famgam_yes i.adultcaresx i.survey_year ///
    [pw=w_main] if samp_main == 1, vce(cluster school_cluster)

*-------------------
* Negative binomial
*-------------------

* Arcade x Motive1
nbreg dsm_total i.g1_any##i.Motive1 i.Motive2 i.Motive3 i.Motive4 i.Motive5 ///
    c.Exactage i.gender i.Ethnicity i.imd i.famgam_yes i.adultcaresx i.survey_year ///
    [pw=w_main] if samp_main == 1, vce(cluster school_cluster)
margins Motive1, dydx(g1_any)

* Informal x Motive1
nbreg dsm_total i.g2_any##i.Motive1 i.Motive2 i.Motive3 i.Motive4 i.Motive5 ///
    c.Exactage i.gender i.Ethnicity i.imd i.famgam_yes i.adultcaresx i.survey_year ///
    [pw=w_main] if samp_main == 1, vce(cluster school_cluster)
margins Motive1, dydx(g2_any)

* Regulated x Motive1
nbreg dsm_total i.g3_any##i.Motive1 i.Motive2 i.Motive3 i.Motive4 i.Motive5 ///
    c.Exactage i.gender i.Ethnicity i.imd i.famgam_yes i.adultcaresx i.survey_year ///
    [pw=w_main] if samp_main == 1, vce(cluster school_cluster)
margins Motive1, dydx(g3_any)

* Arcade x Motive2
nbreg dsm_total i.g1_any##i.Motive2 i.Motive1 i.Motive3 i.Motive4 i.Motive5 ///
    c.Exactage i.gender i.Ethnicity i.imd i.famgam_yes i.adultcaresx i.survey_year ///
    [pw=w_main] if samp_main == 1, vce(cluster school_cluster)
margins Motive2, dydx(g1_any)

* Informal x Motive2
nbreg dsm_total i.g2_any##i.Motive2 i.Motive1 i.Motive3 i.Motive4 i.Motive5 ///
    c.Exactage i.gender i.Ethnicity i.imd i.famgam_yes i.adultcaresx i.survey_year ///
    [pw=w_main] if samp_main == 1, vce(cluster school_cluster)
margins Motive2, dydx(g2_any)

* Regulated x Motive2
nbreg dsm_total i.g3_any##i.Motive2 i.Motive1 i.Motive3 i.Motive4 i.Motive5 ///
    c.Exactage i.gender i.Ethnicity i.imd i.famgam_yes i.adultcaresx i.survey_year ///
    [pw=w_main] if samp_main == 1, vce(cluster school_cluster)
margins Motive2, dydx(g3_any)

* Arcade x Motive3
nbreg dsm_total i.g1_any##i.Motive3 i.Motive1 i.Motive2 i.Motive4 i.Motive5 ///
    c.Exactage i.gender i.Ethnicity i.imd i.famgam_yes i.adultcaresx i.survey_year ///
    [pw=w_main] if samp_main == 1, vce(cluster school_cluster)
margins Motive3, dydx(g1_any)

* Informal x Motive3
nbreg dsm_total i.g2_any##i.Motive3 i.Motive1 i.Motive2 i.Motive4 i.Motive5 ///
    c.Exactage i.gender i.Ethnicity i.imd i.famgam_yes i.adultcaresx i.survey_year ///
    [pw=w_main] if samp_main == 1, vce(cluster school_cluster)
margins Motive3, dydx(g2_any)

* Regulated x Motive3
nbreg dsm_total i.g3_any##i.Motive3 i.Motive1 i.Motive2 i.Motive4 i.Motive5 ///
    c.Exactage i.gender i.Ethnicity i.imd i.famgam_yes i.adultcaresx i.survey_year ///
    [pw=w_main] if samp_main == 1, vce(cluster school_cluster)
margins Motive3, dydx(g3_any)

* Arcade x Motive4
nbreg dsm_total i.g1_any##i.Motive4 i.Motive1 i.Motive2 i.Motive3 i.Motive5 ///
    c.Exactage i.gender i.Ethnicity i.imd i.famgam_yes i.adultcaresx i.survey_year ///
    [pw=w_main] if samp_main == 1, vce(cluster school_cluster)
margins Motive4, dydx(g1_any)

* Informal x Motive4
nbreg dsm_total i.g2_any##i.Motive4 i.Motive1 i.Motive2 i.Motive3 i.Motive5 ///
    c.Exactage i.gender i.Ethnicity i.imd i.famgam_yes i.adultcaresx i.survey_year ///
    [pw=w_main] if samp_main == 1, vce(cluster school_cluster)
margins Motive4, dydx(g2_any)

* Regulated x Motive4
nbreg dsm_total i.g3_any##i.Motive4 i.Motive1 i.Motive2 i.Motive3 i.Motive5 ///
    c.Exactage i.gender i.Ethnicity i.imd i.famgam_yes i.adultcaresx i.survey_year ///
    [pw=w_main] if samp_main == 1, vce(cluster school_cluster)
margins Motive4, dydx(g3_any)

* Arcade x Motive5
nbreg dsm_total i.g1_any##i.Motive5 i.Motive1 i.Motive2 i.Motive3 i.Motive4 ///
    c.Exactage i.gender i.Ethnicity i.imd i.famgam_yes i.adultcaresx i.survey_year ///
    [pw=w_main] if samp_main == 1, vce(cluster school_cluster)
margins Motive5, dydx(g1_any)

* Informal x Motive5
nbreg dsm_total i.g2_any##i.Motive5 i.Motive1 i.Motive2 i.Motive3 i.Motive4 ///
    c.Exactage i.gender i.Ethnicity i.imd i.famgam_yes i.adultcaresx i.survey_year ///
    [pw=w_main] if samp_main == 1, vce(cluster school_cluster)
margins Motive5, dydx(g2_any)

* Regulated x Motive5
nbreg dsm_total i.g3_any##i.Motive5 i.Motive1 i.Motive2 i.Motive3 i.Motive4 ///
    c.Exactage i.gender i.Ethnicity i.imd i.famgam_yes i.adultcaresx i.survey_year ///
    [pw=w_main] if samp_main == 1, vce(cluster school_cluster)
margins Motive5, dydx(g3_any)

*-------------------------------------------------------------------------------
* 16. Alternative outcome: ordered DSM category
*-------------------------------------------------------------------------------

tab dsm_cat if samp_ord == 1, missing

*-------------------
* Ordered probit
*-------------------

* Spec I: no controls
oprobit dsm_cat i.g1_any i.g2_any i.g3_any i.survey_year ///
    [pw=w_ord] if samp_ord == 1, vce(cluster school_cluster)
margins, dydx(g1_any g2_any g3_any) predict(outcome(0))
margins, dydx(g1_any g2_any g3_any) predict(outcome(1))
margins, dydx(g1_any g2_any g3_any) predict(outcome(2))

* Spec II: demographics
oprobit dsm_cat i.g1_any i.g2_any i.g3_any ///
    c.Exactage i.gender i.Ethnicity i.imd i.survey_year ///
    [pw=w_ord] if samp_ord == 1, vce(cluster school_cluster)
margins, dydx(g1_any g2_any g3_any) predict(outcome(0))
margins, dydx(g1_any g2_any g3_any) predict(outcome(1))
margins, dydx(g1_any g2_any g3_any) predict(outcome(2))

* Spec III: family environment
oprobit dsm_cat i.g1_any i.g2_any i.g3_any ///
    i.famgam_yes i.adultcaresx i.survey_year ///
    [pw=w_ord] if samp_ord == 1, vce(cluster school_cluster)
margins, dydx(g1_any g2_any g3_any) predict(outcome(0))
margins, dydx(g1_any g2_any g3_any) predict(outcome(1))
margins, dydx(g1_any g2_any g3_any) predict(outcome(2))

* Spec IV: motives
oprobit dsm_cat i.g1_any i.g2_any i.g3_any ///
    i.(Motive1 Motive2 Motive3 Motive4 Motive5) i.survey_year ///
    [pw=w_ord] if samp_ord == 1, vce(cluster school_cluster)
margins, dydx(g1_any g2_any g3_any) predict(outcome(0))
margins, dydx(g1_any g2_any g3_any) predict(outcome(1))
margins, dydx(g1_any g2_any g3_any) predict(outcome(2))

* Spec V: full model
oprobit dsm_cat i.g1_any i.g2_any i.g3_any ///
    c.Exactage i.gender i.Ethnicity i.imd ///
    i.famgam_yes i.adultcaresx ///
    i.(Motive1 Motive2 Motive3 Motive4 Motive5) ///
    i.survey_year [pw=w_ord] if samp_ord == 1, vce(cluster school_cluster)
margins, dydx(g1_any g2_any g3_any) predict(outcome(0))
margins, dydx(g1_any g2_any g3_any) predict(outcome(1))
margins, dydx(g1_any g2_any g3_any) predict(outcome(2))

*-------------------------------------------------------------------------------
* 17. Alternative ordered outcome: moderation by adult care
*-------------------------------------------------------------------------------

* Spec I: no controls
oprobit dsm_cat i.adultcaresx##(i.g1_any i.g2_any i.g3_any) i.survey_year ///
    [pw=w_ord] if samp_ord == 1, vce(cluster school_cluster)
margins adultcaresx, dydx(g1_any g2_any g3_any) predict(outcome(0))
margins adultcaresx, dydx(g1_any g2_any g3_any) predict(outcome(1))
margins adultcaresx, dydx(g1_any g2_any g3_any) predict(outcome(2))

* Spec II: demographics
oprobit dsm_cat i.adultcaresx##(i.g1_any i.g2_any i.g3_any) ///
    c.Exactage i.gender i.Ethnicity i.imd i.survey_year ///
    [pw=w_ord] if samp_ord == 1, vce(cluster school_cluster)
margins adultcaresx, dydx(g1_any g2_any g3_any) predict(outcome(0))
margins adultcaresx, dydx(g1_any g2_any g3_any) predict(outcome(1))
margins adultcaresx, dydx(g1_any g2_any g3_any) predict(outcome(2))

* Spec III: family environment
oprobit dsm_cat i.adultcaresx##(i.g1_any i.g2_any i.g3_any) ///
    i.famgam_yes i.survey_year ///
    [pw=w_ord] if samp_ord == 1, vce(cluster school_cluster)
margins adultcaresx, dydx(g1_any g2_any g3_any) predict(outcome(0))
margins adultcaresx, dydx(g1_any g2_any g3_any) predict(outcome(1))
margins adultcaresx, dydx(g1_any g2_any g3_any) predict(outcome(2))

* Spec IV: motives
oprobit dsm_cat i.adultcaresx##(i.g1_any i.g2_any i.g3_any) ///
    i.(Motive1 Motive2 Motive3 Motive4 Motive5) i.survey_year ///
    [pw=w_ord] if samp_ord == 1, vce(cluster school_cluster)
margins adultcaresx, dydx(g1_any g2_any g3_any) predict(outcome(0))
margins adultcaresx, dydx(g1_any g2_any g3_any) predict(outcome(1))
margins adultcaresx, dydx(g1_any g2_any g3_any) predict(outcome(2))

* Spec V: full model
oprobit dsm_cat i.adultcaresx##(i.g1_any i.g2_any i.g3_any) ///
    c.Exactage i.gender i.Ethnicity i.imd i.famgam_yes ///
    i.(Motive1 Motive2 Motive3 Motive4 Motive5) i.survey_year ///
    [pw=w_ord] if samp_ord == 1, vce(cluster school_cluster)
margins adultcaresx, dydx(g1_any g2_any g3_any) predict(outcome(0))
margins adultcaresx, dydx(g1_any g2_any g3_any) predict(outcome(1))
margins adultcaresx, dydx(g1_any g2_any g3_any) predict(outcome(2))

*-------------------------------------------------------------------------------
* 18. Save final analysis dataset
*-------------------------------------------------------------------------------
save "${processed}/ypgs_2022_2024_common_analysis.dta", replace

* Optional log close
* log close

*===============================================================================
* End of do-file
*===============================================================================
