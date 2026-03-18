/*******************************************************************************
Project: Family, Motivation and Harm
Data: YPGS 2022–2024 pooled from common comparable population
Do file name: 06_analysis_mvprobit.do
Authors: Kim, Stowasser, Newall
Date created: 18 Mar 2026
Version: 1

Purpose:
- Estimate joint participation in overlapping gambling domains
- Use a trivariate multivariate probit model for g1_any g2_any g3_any
- Allow unobserved determinants of gambling-domain participation to correlate
- Provide a joint alternative to separate probit models

Important:
- This do-file requires the user-written command mvprobit
- If mvprobit is not installed, the do-file exits with a clear message
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
* 1. Confirm mvprobit is available
*-------------------------------------------------------------------------------
capture which mvprobit
if _rc != 0 {
    di as error "The command mvprobit is not installed."
    di as error "Install it before running this do-file, or switch to a fallback strategy."
    exit 199
}

*-------------------------------------------------------------------------------
* 2. Load analysis-ready file
*-------------------------------------------------------------------------------
capture confirm file "${processed}/ypgs_2022_2024_common_analysis.dta"
if _rc != 0 {
    di as error "File not found: ${processed}/ypgs_2022_2024_common_analysis.dta"
    exit 601
}

use "${processed}/ypgs_2022_2024_common_analysis.dta", clear

*-------------------------------------------------------------------------------
* 3. Confirm required variables exist
*-------------------------------------------------------------------------------
describe g1_any g2_any g3_any ///
         Exactage gender Ethnicity imd famgam_yes adultcaresx ///
         Motive1 Motive2 Motive3 Motive4 Motive5 ///
         survey_year school_cluster w_rq1 samp_rq1

*-------------------------------------------------------------------------------
* 4. Keep participation sample only
*-------------------------------------------------------------------------------
keep if samp_rq1 == 1

assert problem1 == 1
assert !missing(g1_any, g2_any, g3_any)
assert !missing(Exactage, gender, Ethnicity, imd, famgam_yes, adultcaresx)
assert !missing(Motive1, Motive2, Motive3, Motive4, Motive5)
assert !missing(school_cluster)
assert !missing(w_rq1)
assert w_rq1 > 0

tab survey_year, missing

*-------------------------------------------------------------------------------
* 5. Descriptive overlap diagnostics
*-------------------------------------------------------------------------------
mean g1_any g2_any g3_any [pw=w_rq1], over(survey_year)

egen byte overlap_count = rowtotal(g1_any g2_any g3_any)
label var overlap_count "Number of gambling domains participated in"
tab overlap_count, missing

corr g1_any g2_any g3_any

*-------------------------------------------------------------------------------
* 6. Benchmark separate probits for comparison
*-------------------------------------------------------------------------------
probit g1_any c.Exactage i.gender i.Ethnicity i.imd ///
    i.famgam_yes i.adultcaresx ///
    i.Motive1 i.Motive2 i.Motive3 i.Motive4 i.Motive5 ///
    i.survey_year [pw=w_rq1], vce(cluster school_cluster)

probit g2_any c.Exactage i.gender i.Ethnicity i.imd ///
    i.famgam_yes i.adultcaresx ///
    i.Motive1 i.Motive2 i.Motive3 i.Motive4 i.Motive5 ///
    i.survey_year [pw=w_rq1], vce(cluster school_cluster)

probit g3_any c.Exactage i.gender i.Ethnicity i.imd ///
    i.famgam_yes i.adultcaresx ///
    i.Motive1 i.Motive2 i.Motive3 i.Motive4 i.Motive5 ///
    i.survey_year [pw=w_rq1], vce(cluster school_cluster)

*-------------------------------------------------------------------------------
* 7. Trivariate multivariate probit
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
              i.survey_year) ///
    [pw=w_rq1], vce(cluster school_cluster)

*-------------------------------------------------------------------------------
* 8. Key postestimation interpretation
*-------------------------------------------------------------------------------

* Test whether cross-equation correlations are jointly zero
test [atrho21]_cons = 0
test [atrho31]_cons = 0
test [atrho32]_cons = 0
test ([atrho21]_cons = 0) ([atrho31]_cons = 0) ([atrho32]_cons = 0)

* Display estimated latent-error correlations
di as text "Estimated cross-equation correlations:"
di as result "rho21 = " %6.4f tanh(_b[/atrho21])
di as result "rho31 = " %6.4f tanh(_b[/atrho31])
di as result "rho32 = " %6.4f tanh(_b[/atrho32])

*-------------------------------------------------------------------------------
* 9. Test whether cross-equation correlations matter
*-------------------------------------------------------------------------------
* These parameter names may differ slightly by mvprobit version.
* Inspect ereturn list and coefficient names if needed.

matrix list e(b)

* Common hypotheses:
* rho21 = 0
* rho31 = 0
* rho32 = 0
*
* Uncomment and adapt if coefficient names differ in your installed version.
*
* test [athrho21]_cons = 0
* test [athrho31]_cons = 0
* test [athrho32]_cons = 0
* test ([athrho21]_cons = 0) ([athrho31]_cons = 0) ([athrho32]_cons = 0)

*-------------------------------------------------------------------------------
* 10. Save estimation sample
*-------------------------------------------------------------------------------
save "${processed}/ypgs_2022_2024_mvprobit_sample.dta", replace

* Optional log close
* log close

/*******************************************************************************
End of do-file
*******************************************************************************/
