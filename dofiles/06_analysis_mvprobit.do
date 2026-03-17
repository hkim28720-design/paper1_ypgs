/*******************************************************************************
Project: Family, Motivation and Harm
Data: YPGS 2022–2024 pooled from common comparable population
Do file name: 06_analysis_mvprobit.do
Authors: Kim, Stowasser, Newall
Date created: 17 Mar 2026
Version: 1

Purpose:
- Estimate joint participation models for overlapping gambling groups
- Model g1_any, g2_any, and g3_any simultaneously
- Use the RQ1 sample from the common comparable population
- Treat this as an auxiliary dependence model complementing 05_analysis_main.do

Important notes:
- mvprobit is used here to model correlated participation propensities across
  overlapping gambling groups.
- This joint model is not the main weighted survey-design estimator.
- The main participation results should still be anchored in 05_analysis_main.do.
- This file is best treated as a dependence / robustness appendix model.
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
* log using "log/06_analysis_mvprobit.log", replace text

*-------------------------------------------------------------------------------
* 1. Confirm analysis-ready file exists and load data
*-------------------------------------------------------------------------------
capture confirm file "${processed}/ypgs_2022_2024_common_analysis.dta"
if _rc != 0 {
    di as error "File not found: ${processed}/ypgs_2022_2024_common_analysis.dta"
    exit 601
}

use "${processed}/ypgs_2022_2024_common_analysis.dta", clear

*-------------------------------------------------------------------------------
* 2. Confirm required variables exist
*-------------------------------------------------------------------------------
capture confirm variable samp_rq1
if _rc != 0 {
    di as error "Variable samp_rq1 not found. Run 05_analysis_main.do first."
    exit 111
}

capture confirm variable g1_any
if _rc != 0 {
    di as error "Variable g1_any not found."
    exit 112
}

capture confirm variable g2_any
if _rc != 0 {
    di as error "Variable g2_any not found."
    exit 113
}

capture confirm variable g3_any
if _rc != 0 {
    di as error "Variable g3_any not found."
    exit 114
}

*-------------------------------------------------------------------------------
* 3. Restrict to RQ1 sample
*-------------------------------------------------------------------------------
keep if samp_rq1 == 1

assert problem1 == 1
assert !missing(g1_any, g2_any, g3_any)
assert !missing(Exactage, gender, Ethnicity, imd, famgam_yes, adultcaresx)
assert !missing(Motive1, Motive2, Motive3, Motive4, Motive5)

count
tab survey_year, missing

*-------------------------------------------------------------------------------
* 4. Sample diagnostics
*-------------------------------------------------------------------------------
tab g1_any, missing
tab g2_any, missing
tab g3_any, missing

corr g1_any g2_any g3_any

*-------------------------------------------------------------------------------
* 5. Joint participation model: demographics only
*-------------------------------------------------------------------------------
mvprobit ///
    (g1_any = c.Exactage i.gender i.Ethnicity i.imd i.survey_year) ///
    (g2_any = c.Exactage i.gender i.Ethnicity i.imd i.survey_year) ///
    (g3_any = c.Exactage i.gender i.Ethnicity i.imd i.survey_year), ///
    dr(200)

estimates store mvp_demo

* Marginal effects: demographics-only model
margins, dydx(Exactage) predict(pr eq(#1))
margins, dydx(Exactage) predict(pr eq(#2))
margins, dydx(Exactage) predict(pr eq(#3))

*-------------------------------------------------------------------------------
* 6. Joint participation model: family environment only
*-------------------------------------------------------------------------------
mvprobit ///
    (g1_any = i.famgam_yes i.adultcaresx i.survey_year) ///
    (g2_any = i.famgam_yes i.adultcaresx i.survey_year) ///
    (g3_any = i.famgam_yes i.adultcaresx i.survey_year), ///
    dr(200)

estimates store mvp_family

* Marginal effects: family exposure
margins, dydx(famgam_yes) predict(pr eq(#1))
margins, dydx(famgam_yes) predict(pr eq(#2))
margins, dydx(famgam_yes) predict(pr eq(#3))

*-------------------------------------------------------------------------------
* 7. Joint participation model: motives only
*-------------------------------------------------------------------------------
mvprobit ///
    (g1_any = i.Motive1 i.Motive2 i.Motive3 i.Motive4 i.Motive5 i.survey_year) ///
    (g2_any = i.Motive1 i.Motive2 i.Motive3 i.Motive4 i.Motive5 i.survey_year) ///
    (g3_any = i.Motive1 i.Motive2 i.Motive3 i.Motive4 i.Motive5 i.survey_year), ///
    dr(200)

estimates store mvp_motives

* Marginal effects: motives
margins, dydx(Motive1) predict(pr eq(#1))
margins, dydx(Motive1) predict(pr eq(#2))
margins, dydx(Motive1) predict(pr eq(#3))

margins, dydx(Motive2) predict(pr eq(#1))
margins, dydx(Motive2) predict(pr eq(#2))
margins, dydx(Motive2) predict(pr eq(#3))

margins, dydx(Motive3) predict(pr eq(#1))
margins, dydx(Motive3) predict(pr eq(#2))
margins, dydx(Motive3) predict(pr eq(#3))

margins, dydx(Motive4) predict(pr eq(#1))
margins, dydx(Motive4) predict(pr eq(#2))
margins, dydx(Motive4) predict(pr eq(#3))

margins, dydx(Motive5) predict(pr eq(#1))
margins, dydx(Motive5) predict(pr eq(#2))
margins, dydx(Motive5) predict(pr eq(#3))

*-------------------------------------------------------------------------------
* 8. Joint participation model: full specification
*-------------------------------------------------------------------------------
mvprobit ///
    (g1_any = c.Exactage i.gender i.Ethnicity i.imd ///
              i.famgam_yes i.adultcaresx ///
              i.Motive1 i.Motive2 i.Motive3 i.Motive4 i.Motive5 ///
              i.survey_year) ///
    (g2_any = c.Exactage i.gender i.Ethnicity i.imd ///
              i.famgam_yes i.adultcaresx ///
              i.Motive1 i.Motive2 i.Motive3 i.Motive4 i.Motive5 ///
              i.survey_year) ///
    (g3_any = c.Exactage i.gender i.Ethnicity i.imd ///
              i.famgam_yes i.adultcaresx ///
              i.Motive1 i.Motive2 i.Motive3 i.Motive4 i.Motive5 ///
              i.survey_year), ///
    dr(200)

estimates store mvp_full

*-------------------------------------------------------------------------------
* 9. Marginal effects from full model
*-------------------------------------------------------------------------------

* Age
margins, dydx(Exactage) predict(pr eq(#1))
margins, dydx(Exactage) predict(pr eq(#2))
margins, dydx(Exactage) predict(pr eq(#3))

* Family gambling exposure
margins, dydx(famgam_yes) predict(pr eq(#1))
margins, dydx(famgam_yes) predict(pr eq(#2))
margins, dydx(famgam_yes) predict(pr eq(#3))

* Motives
margins, dydx(Motive1) predict(pr eq(#1))
margins, dydx(Motive1) predict(pr eq(#2))
margins, dydx(Motive1) predict(pr eq(#3))

margins, dydx(Motive2) predict(pr eq(#1))
margins, dydx(Motive2) predict(pr eq(#2))
margins, dydx(Motive2) predict(pr eq(#3))

margins, dydx(Motive3) predict(pr eq(#1))
margins, dydx(Motive3) predict(pr eq(#2))
margins, dydx(Motive3) predict(pr eq(#3))

margins, dydx(Motive4) predict(pr eq(#1))
margins, dydx(Motive4) predict(pr eq(#2))
margins, dydx(Motive4) predict(pr eq(#3))

margins, dydx(Motive5) predict(pr eq(#1))
margins, dydx(Motive5) predict(pr eq(#2))
margins, dydx(Motive5) predict(pr eq(#3))

* Adult care: report predicted probabilities by category
margins adultcaresx, predict(pr eq(#1))
margins adultcaresx, predict(pr eq(#2))
margins adultcaresx, predict(pr eq(#3))

*-------------------------------------------------------------------------------
* 10. Residual correlation diagnostics
*-------------------------------------------------------------------------------
* After mvprobit, Stata reports the cross-equation correlations (rho terms).
* These are central for showing whether participation propensities are correlated.

* Replay full model estimates to inspect rho terms clearly
estimates replay mvp_full

*-------------------------------------------------------------------------------
* 11. Save estimates for later table construction if needed
*-------------------------------------------------------------------------------
* Example only; uncomment if you want to save estimates
* estimates save "${processed}/mvp_full_estimates", replace

* Optional log close
* log close

*===============================================================================
* End of do-file
*===============================================================================
