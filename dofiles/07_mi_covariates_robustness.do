/*******************************************************************************
Project: Family, Motivation and Harm
Data: YPGS 2022–2024 pooled from common comparable population
Do file name: 07_mi_covariates_robustness.do
Authors: Kim, Stowasser, Newall
Date created: 18 Mar 2026
Date edited: 19 Mar 2026
Version: 4

Purpose:
- Implement multiple-imputation robustness checks for covariates only
- Do not impute routed variables such as motives, gambling outcomes, or group flags
- Run separate MI workflows for:
    (A) participation models
    (B) harm models
- Try preferred MI on analysis-ready covariates first
- If categorical perfect-prediction still prevents convergence, use simpler
  binary or collapsed covariates where needed

Key principles:
- Restrict to survey_year 2022, 2023, 2024
- Restrict to samp_common == 1
- Impute only partially missing covariates that should be observed in the
  relevant analysis universe
- Do not impute:
    problem1
    g1_any g2_any g3_any
    Motive1 Motive2 Motive3 Motive4 Motive5
    dsm_total dsm_cat
- Inference remains based on pooled equal-wave weights plus clustering
- Main target is robustness, not replacement of the main complete-case analysis
*******************************************************************************/

*-------------------------------------------------------------------------------
* 0. Set up
*-------------------------------------------------------------------------------
version 18
clear all
set more off
set linesize 120

cap mkdir "log"
cap mkdir "out"
cap mkdir "fig"

* Optional log
* log using "log/07_mi_covariates_robustness.log", replace text

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
* 2. Restrict to common comparable sample
*-------------------------------------------------------------------------------
keep if inlist(survey_year, 2022, 2023, 2024)
keep if samp_common == 1

assert inlist(survey_year, 2022, 2023, 2024)
assert samp_common == 1

*-------------------------------------------------------------------------------
* 3. Keep variables needed
*-------------------------------------------------------------------------------
keep survey_year samp_common problem1 schoolid ///
     g1_any g2_any g3_any ///
     dsm_total dsm_cat ///
     Exactage gender Ethnicity imd famgam adultcaresx ///
     Motive1 Motive2 Motive3 Motive4 Motive5 ///
     survey_weight_pool

*-------------------------------------------------------------------------------
* 4. Recode analysis variables exactly as in the main file
*-------------------------------------------------------------------------------
capture label list LB_YN
if _rc != 0 {
    label define LB_YN 0 "No" 1 "Yes"
}

* adultcaresx
recode adultcaresx (6=.) (7=.) (8=.)
label define adultcare_lbl ///
    1 "Strongly agree" ///
    2 "Agree" ///
    3 "Neither agree nor disagree" ///
    4 "Disagree" ///
    5 "Strongly disagree", replace
label values adultcaresx adultcare_lbl
label var adultcaresx "Adult care at home"

* gender
* Keep only male and female categories
recode gender (3=.) (4=.) (5=.)
label define gender_analysis_lbl 1 "Boy/male" 2 "Girl/female", replace
label values gender gender_analysis_lbl
label var gender "Gender (boy/male or girl/female only)"

capture drop female
generate byte female = .
replace female = 1 if gender == 2
replace female = 0 if gender == 1
label define female_lbl 0 "Boy/male" 1 "Girl/female", replace
label values female female_lbl
label var female "Girl/female"

* family gambling exposure
capture drop famgam_yes
generate byte famgam_yes = .
replace famgam_yes = 1 if famgam == 1
replace famgam_yes = 0 if famgam == 2
label values famgam_yes LB_YN
label var famgam_yes "Family gambling exposure"

* Ethnicity
recode Ethnicity (6=.)
label var Ethnicity "Ethnicity"

label var Motive1 "Monetary or quick-fix motive"
label var Motive2 "Entertainment motive"
label var Motive3 "Social-presence motive"
label var Motive4 "Cognitive motive"
label var Motive5 "Boredom motive"

*-------------------------------------------------------------------------------
* 5. Cluster identifier
*-------------------------------------------------------------------------------
capture drop school_cluster
capture drop __school_cluster

generate long school_cluster = .
egen long __school_cluster = group(survey_year schoolid)
replace school_cluster = __school_cluster if !missing(schoolid)
drop __school_cluster

label var school_cluster "Wave-specific school cluster"

*-------------------------------------------------------------------------------
* 6. Define analysis universes
*-------------------------------------------------------------------------------

* Participation universe
capture drop mi_rq1
generate byte mi_rq1 = (problem1 == 1) ///
    & !missing(g1_any, g2_any, g3_any) ///
    & !missing(Motive1, Motive2, Motive3, Motive4, Motive5) ///
    & !missing(Exactage, survey_year, survey_weight_pool, school_cluster)
label values mi_rq1 LB_YN
label var mi_rq1 "MI participation universe"

* Harm universe
capture drop mi_main
generate byte mi_main = (problem1 == 1) ///
    & !missing(dsm_total, dsm_cat) ///
    & !missing(g1_any, g2_any, g3_any) ///
    & !missing(Motive1, Motive2, Motive3, Motive4, Motive5) ///
    & !missing(Exactage, survey_year, survey_weight_pool, school_cluster)
label values mi_main LB_YN
label var mi_main "MI harm universe"

count if mi_rq1 == 1
count if mi_main == 1

*-------------------------------------------------------------------------------
* 7. Construct universe-specific weights from survey_weight_pool
*-------------------------------------------------------------------------------
capture drop w_mi_rq1
capture drop w_mi_main

bysort survey_year: egen double sum_wp_mi_rq1  = total(survey_weight_pool) if mi_rq1  == 1
bysort survey_year: egen double sum_wp_mi_main = total(survey_weight_pool) if mi_main == 1

generate double w_mi_rq1 = .
replace w_mi_rq1 = survey_weight_pool / sum_wp_mi_rq1 * (1/3) if mi_rq1 == 1
label var w_mi_rq1 "Equal-wave pooled weight in MI participation universe"

generate double w_mi_main = .
replace w_mi_main = survey_weight_pool / sum_wp_mi_main * (1/3) if mi_main == 1
label var w_mi_main "Equal-wave pooled weight in MI harm universe"

drop sum_wp_mi_rq1 sum_wp_mi_main

assert w_mi_rq1 > 0 if mi_rq1 == 1
assert w_mi_main > 0 if mi_main == 1

*===============================================================================
* PART A. MI FOR PARTICIPATION MODELS
*===============================================================================
preserve

keep if mi_rq1 == 1

misstable summarize female Ethnicity imd famgam_yes adultcaresx

*-------------------------------------------------------------------------------
* A1. Preferred MI on analysis-ready covariates
*-------------------------------------------------------------------------------
mi set mlong

mi register imputed female Ethnicity famgam_yes adultcaresx
mi register regular survey_year schoolid school_cluster ///
    problem1 g1_any g2_any g3_any ///
    Exactage imd ///
    Motive1 Motive2 Motive3 Motive4 Motive5 ///
    survey_weight_pool w_mi_rq1 mi_rq1

capture noisily mi impute chained ///
    (logit,  augment) female ///
    (mlogit, augment) Ethnicity ///
    (logit,  augment) famgam_yes ///
    (mlogit, augment) adultcaresx ///
    = Exactage i.imd i.survey_year ///
      i.g1_any i.g2_any i.g3_any ///
      i.Motive1 i.Motive2 i.Motive3 i.Motive4 i.Motive5, ///
      add(20) rseed(20260319) burnin(10) dots

local mi_part_ok = 1
if _rc != 0 {
    local mi_part_ok = 0
}

if `mi_part_ok' == 1 {

    di as result "Participation MI succeeded using preferred covariates."

    mi estimate, dots vceok post: ///
        probit g1_any c.Exactage i.female i.Ethnicity i.imd ///
        i.famgam_yes i.adultcaresx ///
        i.Motive1 i.Motive2 i.Motive3 i.Motive4 i.Motive5 ///
        i.survey_year [pw=w_mi_rq1], vce(cluster school_cluster)

    mi estimate, dots vceok post: ///
        probit g2_any c.Exactage i.female i.Ethnicity i.imd ///
        i.famgam_yes i.adultcaresx ///
        i.Motive1 i.Motive2 i.Motive3 i.Motive4 i.Motive5 ///
        i.survey_year [pw=w_mi_rq1], vce(cluster school_cluster)

    mi estimate, dots vceok post: ///
        probit g3_any c.Exactage i.female i.Ethnicity i.imd ///
        i.famgam_yes i.adultcaresx ///
        i.Motive1 i.Motive2 i.Motive3 i.Motive4 i.Motive5 ///
        i.survey_year [pw=w_mi_rq1], vce(cluster school_cluster)
}

if `mi_part_ok' == 0 {

    di as error "Preferred participation MI failed."
    di as error "Switching to fallback collapsed covariates."

    restore
    preserve

    use "${processed}/ypgs_2022_2024_pooled.dta", clear
    keep if inlist(survey_year, 2022, 2023, 2024)
    keep if samp_common == 1

    keep survey_year samp_common problem1 schoolid ///
         g1_any g2_any g3_any ///
         Exactage gender Ethnicity imd famgam adultcaresx ///
         Motive1 Motive2 Motive3 Motive4 Motive5 ///
         survey_weight_pool

    recode adultcaresx (6=.) (7=.) (8=.)
    recode gender (3=.) (4=.) (5=.)
    recode Ethnicity (6=.)

    capture drop female
    generate byte female = .
    replace female = 1 if gender == 2
    replace female = 0 if gender == 1

    capture drop famgam_yes
    generate byte famgam_yes = .
    replace famgam_yes = 1 if famgam == 1
    replace famgam_yes = 0 if famgam == 2

    capture drop school_cluster
    capture drop __school_cluster
    generate long school_cluster = .
    egen long __school_cluster = group(survey_year schoolid)
    replace school_cluster = __school_cluster if !missing(schoolid)
    drop __school_cluster

    capture drop mi_rq1
    generate byte mi_rq1 = (problem1 == 1) ///
        & !missing(g1_any, g2_any, g3_any) ///
        & !missing(Motive1, Motive2, Motive3, Motive4, Motive5) ///
        & !missing(Exactage, survey_year, survey_weight_pool, school_cluster)

    bysort survey_year: egen double sum_wp_mi_rq1 = total(survey_weight_pool) if mi_rq1 == 1
    capture drop w_mi_rq1
    generate double w_mi_rq1 = .
    replace w_mi_rq1 = survey_weight_pool / sum_wp_mi_rq1 * (1/3) if mi_rq1 == 1
    drop sum_wp_mi_rq1

    keep if mi_rq1 == 1

    * fallback collapsed ethnicity
    capture drop eth_mi
    generate byte eth_mi = .
    replace eth_mi = 1 if Ethnicity == 1
    replace eth_mi = 2 if Ethnicity == 2
    replace eth_mi = 3 if Ethnicity == 3
    replace eth_mi = 4 if inlist(Ethnicity, 4, 5)
    label define eth_mi_lbl 1 "White" 2 "Black" 3 "Asian" 4 "Mixed/Other", replace
    label values eth_mi eth_mi_lbl

    * fallback collapsed adult care
    capture drop adultcare_mi
    generate byte adultcare_mi = .
    replace adultcare_mi = 1 if adultcaresx == 1
    replace adultcare_mi = 2 if adultcaresx == 2
    replace adultcare_mi = 3 if inlist(adultcaresx, 3, 4, 5)
    label define adultcare_mi_lbl 1 "Strongly agree" 2 "Agree" 3 "Other responses", replace
    label values adultcare_mi adultcare_mi_lbl

    misstable summarize female eth_mi imd famgam_yes adultcare_mi

    mi set mlong

    mi register imputed female eth_mi famgam_yes adultcare_mi
    mi register regular survey_year schoolid school_cluster ///
        problem1 g1_any g2_any g3_any ///
        Exactage imd ///
        Motive1 Motive2 Motive3 Motive4 Motive5 ///
        survey_weight_pool w_mi_rq1 mi_rq1

    mi impute chained ///
        (logit,  augment) female ///
        (mlogit, augment) eth_mi ///
        (logit,  augment) famgam_yes ///
        (mlogit, augment) adultcare_mi ///
        = Exactage i.imd i.survey_year ///
          i.g1_any i.g2_any i.g3_any ///
          i.Motive1 i.Motive2 i.Motive3 i.Motive4 i.Motive5, ///
          add(20) rseed(20260319) burnin(10) dots

    di as result "Participation MI succeeded using fallback collapsed covariates."

    mi estimate, dots vceok post: ///
        probit g1_any c.Exactage i.female i.eth_mi i.imd ///
        i.famgam_yes i.adultcare_mi ///
        i.Motive1 i.Motive2 i.Motive3 i.Motive4 i.Motive5 ///
        i.survey_year [pw=w_mi_rq1], vce(cluster school_cluster)

    mi estimate, dots vceok post: ///
        probit g2_any c.Exactage i.female i.eth_mi i.imd ///
        i.famgam_yes i.adultcare_mi ///
        i.Motive1 i.Motive2 i.Motive3 i.Motive4 i.Motive5 ///
        i.survey_year [pw=w_mi_rq1], vce(cluster school_cluster)

    mi estimate, dots vceok post: ///
        probit g3_any c.Exactage i.female i.eth_mi i.imd ///
        i.famgam_yes i.adultcare_mi ///
        i.Motive1 i.Motive2 i.Motive3 i.Motive4 i.Motive5 ///
        i.survey_year [pw=w_mi_rq1], vce(cluster school_cluster)
}

restore

*===============================================================================
* PART B. MI FOR HARM MODELS
*===============================================================================
preserve

keep if mi_main == 1

misstable summarize female Ethnicity imd famgam_yes adultcaresx

*-------------------------------------------------------------------------------
* B1. Preferred MI on analysis-ready covariates
*-------------------------------------------------------------------------------
mi set mlong

mi register imputed female Ethnicity famgam_yes adultcaresx
mi register regular survey_year schoolid school_cluster ///
    problem1 g1_any g2_any g3_any dsm_total dsm_cat ///
    Exactage imd ///
    Motive1 Motive2 Motive3 Motive4 Motive5 ///
    survey_weight_pool w_mi_main mi_main

capture noisily mi impute chained ///
    (logit,  augment) female ///
    (mlogit, augment) Ethnicity ///
    (logit,  augment) famgam_yes ///
    (mlogit, augment) adultcaresx ///
    = Exactage i.imd i.survey_year ///
      i.g1_any i.g2_any i.g3_any ///
      c.dsm_total i.dsm_cat ///
      i.Motive1 i.Motive2 i.Motive3 i.Motive4 i.Motive5, ///
      add(20) rseed(20260319) burnin(10) dots

local mi_harm_ok = 1
if _rc != 0 {
    local mi_harm_ok = 0
}

if `mi_harm_ok' == 1 {

    di as result "Harm MI succeeded using preferred covariates."

    mi estimate, dots vceok post: ///
        reg dsm_total i.g1_any i.g2_any i.g3_any ///
        c.Exactage i.female i.Ethnicity i.imd ///
        i.famgam_yes i.adultcaresx ///
        i.Motive1 i.Motive2 i.Motive3 i.Motive4 i.Motive5 ///
        i.survey_year [pw=w_mi_main], vce(cluster school_cluster)

    mi estimate, dots vceok post: ///
        nbreg dsm_total i.g1_any i.g2_any i.g3_any ///
        c.Exactage i.female i.Ethnicity i.imd ///
        i.famgam_yes i.adultcaresx ///
        i.Motive1 i.Motive2 i.Motive3 i.Motive4 i.Motive5 ///
        i.survey_year [pw=w_mi_main], vce(cluster school_cluster)
}

if `mi_harm_ok' == 0 {

    di as error "Preferred harm MI failed."
    di as error "Switching to fallback collapsed covariates."

    restore
    preserve

    use "${processed}/ypgs_2022_2024_pooled.dta", clear
    keep if inlist(survey_year, 2022, 2023, 2024)
    keep if samp_common == 1

    keep survey_year samp_common problem1 schoolid ///
         g1_any g2_any g3_any dsm_total dsm_cat ///
         Exactage gender Ethnicity imd famgam adultcaresx ///
         Motive1 Motive2 Motive3 Motive4 Motive5 ///
         survey_weight_pool

    recode adultcaresx (6=.) (7=.) (8=.)
    recode gender (3=.) (4=.) (5=.)
    recode Ethnicity (6=.)

    capture drop female
    generate byte female = .
    replace female = 1 if gender == 2
    replace female = 0 if gender == 1

    capture drop famgam_yes
    generate byte famgam_yes = .
    replace famgam_yes = 1 if famgam == 1
    replace famgam_yes = 0 if famgam == 2

    capture drop school_cluster
    capture drop __school_cluster
    generate long school_cluster = .
    egen long __school_cluster = group(survey_year schoolid)
    replace school_cluster = __school_cluster if !missing(schoolid)
    drop __school_cluster

    capture drop mi_main
    generate byte mi_main = (problem1 == 1) ///
        & !missing(dsm_total, dsm_cat) ///
        & !missing(g1_any, g2_any, g3_any) ///
        & !missing(Motive1, Motive2, Motive3, Motive4, Motive5) ///
        & !missing(Exactage, survey_year, survey_weight_pool, school_cluster)

    bysort survey_year: egen double sum_wp_mi_main = total(survey_weight_pool) if mi_main == 1
    capture drop w_mi_main
    generate double w_mi_main = .
    replace w_mi_main = survey_weight_pool / sum_wp_mi_main * (1/3) if mi_main == 1
    drop sum_wp_mi_main

    keep if mi_main == 1

    capture drop eth_mi
    generate byte eth_mi = .
    replace eth_mi = 1 if Ethnicity == 1
    replace eth_mi = 2 if Ethnicity == 2
    replace eth_mi = 3 if Ethnicity == 3
    replace eth_mi = 4 if inlist(Ethnicity, 4, 5)
    label define eth_mi_lbl 1 "White" 2 "Black" 3 "Asian" 4 "Mixed/Other", replace
    label values eth_mi eth_mi_lbl

    capture drop adultcare_mi
    generate byte adultcare_mi = .
    replace adultcare_mi = 1 if adultcaresx == 1
    replace adultcare_mi = 2 if adultcaresx == 2
    replace adultcare_mi = 3 if inlist(adultcaresx, 3, 4, 5)
    label define adultcare_mi_lbl 1 "Strongly agree" 2 "Agree" 3 "Other responses", replace
    label values adultcare_mi adultcare_mi_lbl

    misstable summarize female eth_mi imd famgam_yes adultcare_mi

    mi set mlong

    mi register imputed female eth_mi famgam_yes adultcare_mi
    mi register regular survey_year schoolid school_cluster ///
        problem1 g1_any g2_any g3_any dsm_total dsm_cat ///
        Exactage imd ///
        Motive1 Motive2 Motive3 Motive4 Motive5 ///
        survey_weight_pool w_mi_main mi_main

    mi impute chained ///
        (logit,  augment) female ///
        (mlogit, augment) eth_mi ///
        (logit,  augment) famgam_yes ///
        (mlogit, augment) adultcare_mi ///
        = Exactage i.imd i.survey_year ///
          i.g1_any i.g2_any i.g3_any ///
          c.dsm_total i.dsm_cat ///
          i.Motive1 i.Motive2 i.Motive3 i.Motive4 i.Motive5, ///
          add(20) rseed(20260319) burnin(10) dots

    di as result "Harm MI succeeded using fallback collapsed covariates."

    mi estimate, dots vceok post: ///
        reg dsm_total i.g1_any i.g2_any i.g3_any ///
        c.Exactage i.female i.eth_mi i.imd ///
        i.famgam_yes i.adultcare_mi ///
        i.Motive1 i.Motive2 i.Motive3 i.Motive4 i.Motive5 ///
        i.survey_year [pw=w_mi_main], vce(cluster school_cluster)

    mi estimate, dots vceok post: ///
        nbreg dsm_total i.g1_any i.g2_any i.g3_any ///
        c.Exactage i.female i.eth_mi i.imd ///
        i.famgam_yes i.adultcare_mi ///
        i.Motive1 i.Motive2 i.Motive3 i.Motive4 i.Motive5 ///
        i.survey_year [pw=w_mi_main], vce(cluster school_cluster)
}

restore

* Optional log close
* log close

*===============================================================================
* End of do-file
*===============================================================================
