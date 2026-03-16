/*******************************************************************************
Project: Family, Motivation and Harm
Data: YPGS 2022 and 2023
Do file name: revision
Authors: Kim, Stowasser, Newall
Date created: 10 Feb 2026
Date edited: 10 Feb 2026
Version: 1
Note: 
*******************************************************************************/

*-------------------------------------------------------------------------------
***Set up
*-------------------------------------------------------------------------------

version 18
clear all
set more off
set linesize 120

*-------------------------------------------------------------------------------
***Paths
*-------------------------------------------------------------------------------
*file directory
cd "/Users/kk/Desktop/Paper_1_main/Data/Processed"

*store log file
global log "log"
cap mkdir "log"
cap mkdir "out"
cap mkdir "fig"

*log using "log/revision.log", replace text


*Load 2022–2024 RCS 
use "ypgs_2022_2024_pooled.dta", clear
*trim data for 2022 and 2023
keep if inlist(survey_year, 2022, 2023)



*-------------------------------------------------------------------------------
***keep variables of interest
*-------------------------------------------------------------------------------

keep survey_year problem1 ///
     g1_any g2_any g3_any ///
     g1_me  g2_me  g3_me  ///
     dsm_total dsm_cat ///
	 Exactage gender Ethnicity imd ///
     famgam adultcaresx ///
     Motive1 Motive2 Motive3 Motive4 Motive5 ///
	 survey_weight

*-------------------------------------------------------------------------------
***a bit of coding changes
*-------------------------------------------------------------------------------

*adultcaresx note: 6 "Don't know"; 7 "Prefer not to say" 8 "Not stated"
recode adultcaresx (6=.)(7=.)(8=.) 

*gender note: 3 "In another way"; 4 "Prefer not to say"
recode gender (3=.) (4=.)

*famgam note: 3 "Don't Know"; 4 "Prefer not to say"; 5 "Not stated"
recode famgam (3=.) (4=.) (5=.) 
*famgam note: orginal 1 "Yes"; 2 "No"
recode famgam (1=1) (2=0)

*Ethnicity note: 5 "Other"; 6 "Prefer not to say"
recode Ethnicity (5=.) (6=.)


*-------------------------------------------------------------------------------
*construct samples for analysis: include only gamblers 
*-------------------------------------------------------------------------------

gen byte samp_dsm = (problem1==1) & !missing(dsm_total)
capture label list LB_YN
if _rc label define LB_YN 0 "No" 1 "Yes"
label values samp_dsm LB_YN
label var samp_dsm "DSM-asked sample (problem1==1 & dsm_total observed)"

assert missing(dsm_total) if problem1==0   // routing check 
assert problem1==1 if !missing(dsm_total)


*Sample definitions
gen byte samp_main = samp_dsm==1 ///
  & !missing(Exactage, gender, Ethnicity, imd, famgam, adultcaresx, ///
             Motive1, Motive2, Motive3, Motive4, Motive5, ///
             g1_any, g2_any, g3_any)

label var samp_main "Main analytic sample (DSM-asked; complete-case on covariates + motives)"

/*not conditioning on DSM observed
gen byte samp_rq1 = (problem1==1) ///
  & !missing(Exactage, gender, Ethnicity, imd, famgam, adultcaresx, ///
             Motive1, Motive2, Motive3, Motive4, Motive5, ///
             g1_any, g2_any, g3_any)

label var samp_rq1 "RQ1 sample (gamblers; complete-case covariates+motive; no DSM conditioning)"
*/

*-------------------------------------------------------------------------------
***describe dataset (main analytic sample)
*-------------------------------------------------------------------------------

*2022: continuous/count/binary
summ Exactage adultcaresx dsm_total g1_any g2_any g3_any g1_me g2_me g3_me ///
    if samp_main==1 & survey_year==2022

*2022: categorical distributions
tab gender        if samp_main==1 & survey_year==2022, missing
tab Ethnicity     if samp_main==1 & survey_year==2022, missing
tab imd           if samp_main==1 & survey_year==2022, missing
tab famgam        if samp_main==1 & survey_year==2022, missing
tab adultcaresx   if samp_main==1 & survey_year==2022, missing
tab Motive1       if samp_main==1 & survey_year==2022, missing
tab Motive2       if samp_main==1 & survey_year==2022, missing
tab Motive3       if samp_main==1 & survey_year==2022, missing
tab Motive4       if samp_main==1 & survey_year==2022, missing
tab Motive5       if samp_main==1 & survey_year==2022, missing

*2023: continuous/count/binary 
summ Exactage adultcaresx dsm_total g1_any g2_any g3_any g1_me g2_me g3_me ///
    if samp_main==1 & survey_year==2023

*2023: categorical distributions
tab gender        if samp_main==1 & survey_year==2023, missing
tab Ethnicity     if samp_main==1 & survey_year==2023, missing
tab imd           if samp_main==1 & survey_year==2023, missing
tab famgam        if samp_main==1 & survey_year==2023, missing
tab adultcaresx   if samp_main==1 & survey_year==2023, missing
tab Motive1       if samp_main==1 & survey_year==2023, missing
tab Motive2       if samp_main==1 & survey_year==2023, missing
tab Motive3       if samp_main==1 & survey_year==2023, missing
tab Motive4       if samp_main==1 & survey_year==2023, missing
tab Motive5       if samp_main==1 & survey_year==2023, missing

*distribution for the outcome variable: DSM-IV-MR-J
tab dsm_total if samp_main==1, missing
summ dsm_total if samp_main==1, detail

*-------------------------------------------------------------------------------
***RQ1 "who becomes which gambler"
*-------------------------------------------------------------------------------

**Arcade group
*spec (I): controlling for demographics 
probit g1_any c.Exactage i.gender i.Ethnicity i.imd i.survey_year if samp_main==1, vce(robust)
margins, dydx(Exactage gender Ethnicity imd)

*spec (II): controlling for enviroment 
probit g1_any i.famgam c.adultcaresx i.survey_year if samp_main==1, vce(robust)
margins, dydx(famgam adultcaresx )

*spec (III): controlling for motives
probit g1_any i.(Motive1 Motive2 Motive3 Motive4 Motive5) i.survey_year if samp_main==1, vce(robust)
margins, dydx(Motive1 Motive2 Motive3 Motive4 Motive5)

*spec (IV): controlling all
probit g1_any c.Exactage i.gender i.Ethnicity i.imd i.famgam c.adultcaresx i.(Motive1 Motive2 Motive3 Motive4 Motive5) i.survey_year if samp_main==1, vce(robust)
margins, dydx(Exactage famgam adultcaresx Motive1 Motive2 Motive3 Motive4 Motive5)
*-------------------

**Informal-setting gambler group
*spec (I): controlling for demographics 
probit g2_any c.Exactage i.gender i.Ethnicity i.imd i.survey_year if samp_main==1, vce(robust)
margins, dydx(Exactage gender Ethnicity imd)

*spec (II): controlling for enviroment 
probit g2_any i.famgam c.adultcaresx i.survey_year if samp_main==1, vce(robust)
margins, dydx(famgam adultcaresx )

*spec (III): controlling for motives
probit g2_any i.(Motive1 Motive2 Motive3 Motive4 Motive5) i.survey_year if samp_main==1, vce(robust)
margins, dydx(Motive1 Motive2 Motive3 Motive4 Motive5)

*spec (IV): controlling all
probit g2_any c.Exactage i.gender i.Ethnicity i.imd i.famgam c.adultcaresx i.(Motive1 Motive2 Motive3 Motive4 Motive5) i.survey_year if samp_main==1, vce(robust)
margins, dydx(Exactage famgam adultcaresx Motive1 Motive2 Motive3 Motive4 Motive5)
*-------------------

**regulated-setting gambler group
*spec (I): controlling for demographics 
probit g3_any c.Exactage i.gender i.Ethnicity i.imd i.survey_year if samp_main==1, vce(robust)
margins, dydx(Exactage gender Ethnicity imd)

*spec (II): controlling for enviroment 
probit g3_any i.famgam c.adultcaresx i.survey_year if samp_main==1, vce(robust)
margins, dydx(famgam adultcaresx )

*spec (III): controlling for motives
probit g3_any i.(Motive1 Motive2 Motive3 Motive4 Motive5) i.survey_year if samp_main==1, vce(robust)
margins, dydx(Motive1 Motive2 Motive3 Motive4 Motive5)

*spec (IV): controlling all
probit g3_any c.Exactage i.gender i.Ethnicity i.imd i.famgam c.adultcaresx i.(Motive1 Motive2 Motive3 Motive4 Motive5) i.survey_year if samp_main==1, vce(robust)
margins, dydx(Exactage famgam adultcaresx Motive1 Motive2 Motive3 Motive4 Motive5)


*-------------------------------------------------------------------------------
*RQ2: HARM REGRESSIONS (DSM-asked sample): dsm_total
*     Specs I–V; OLS (robust) + NBREG (robust)
*-------------------------------------------------------------------------------

**OLS
*spec (I): no controls
reg dsm_total i.g1_any i.g2_any i.g3_any i.survey_year if samp_main==1, vce(robust)

*spec (II): controlling for demographics 
reg dsm_total i.g1_any i.g2_any i.g3_any c.Exactage i.gender i.Ethnicity i.imd i.survey_year if samp_main==1, vce(robust)

*spec (II): controlling for enviroment 
reg dsm_total i.g1_any i.g2_any i.g3_any i.famgam c.adultcaresx i.survey_year if samp_main==1, vce(robust)

*spec (III): controlling for motives 
reg dsm_total i.g1_any i.g2_any i.g3_any i.(Motive1 Motive2 Motive3 Motive4 Motive5) i.survey_year if samp_main==1, vce(robust)

*spec (IV): controlling for all 
reg dsm_total i.g1_any i.g2_any i.g3_any c.Exactage i.gender i.Ethnicity i.imd ///
    i.famgam c.adultcaresx i.(Motive1 Motive2 Motive3 Motive4 Motive5) ///
    i.survey_year if samp_main==1, vce(robust)
*-------------------


**count data model
*spec (I): no controls
 nbreg dsm_total i.g1_any i.g2_any i.g3_any i.survey_year if samp_main==1, vce(robust)
margins, dydx(g1_any g2_any g3_any)

*spec (II): controlling for demographics 
 nbreg dsm_total i.g1_any i.g2_any i.g3_any c.Exactage i.gender i.Ethnicity i.imd i.survey_year if samp_main==1, vce(robust)
margins, dydx(g1_any g2_any g3_any)

*spec (II): controlling for enviroment 
 nbreg dsm_total i.g1_any i.g2_any i.g3_any i.famgam c.adultcaresx i.survey_year if samp_main==1, vce(robust)
margins, dydx(g1_any g2_any g3_any)

*spec (III): controlling for motives 
 nbreg dsm_total i.g1_any i.g2_any i.g3_any i.(Motive1 Motive2 Motive3 Motive4 Motive5) i.survey_year if samp_main==1, vce(robust)
margins, dydx(g1_any g2_any g3_any)

*spec (IV): controlling for all 
 nbreg dsm_total i.g1_any i.g2_any i.g3_any c.Exactage i.gender i.Ethnicity i.imd i.famgam c.adultcaresx i.(Motive1 Motive2 Motive3 Motive4 Motive5) i.survey_year if samp_main==1, vce(robust)
margins, dydx(g1_any g2_any g3_any)


*-------------------------------------------------------------------------------
*RQ3: MODERATION: (g1/g2/g3) × FAMILY GAMBLING EXPOSURE (famgam_yes)
*     Specs I–III; OLS (robust) + NBREG (robust)
*-------------------------------------------------------------------------------
**OLS
*spec (I): Arcade
reg dsm_total i.g1_any##i.famgam  c.Exactage i.gender i.Ethnicity i.imd c.adultcaresx i.(Motive1 Motive2 Motive3 Motive4 Motive5) i.survey_year if samp_main==1, vce(robust)

*spec (II): Informal-setting 
reg dsm_total i.g2_any##i.famgam  c.Exactage i.gender i.Ethnicity i.imd c.adultcaresx i.(Motive1 Motive2 Motive3 Motive4 Motive5) i.survey_year if samp_main==1, vce(robust)

*spec (III): regulated-setting 
reg dsm_total i.g3_any##i.famgam  c.Exactage i.gender i.Ethnicity i.imd c.adultcaresx i.(Motive1 Motive2 Motive3 Motive4 Motive5) i.survey_year if samp_main==1, vce(robust)
*-------------------

**NBREG
*spec (I): Arcade × famgam
nbreg dsm_total i.g1_any##i.famgam c.Exactage i.gender i.Ethnicity i.imd c.adultcaresx ///
    i.(Motive1 Motive2 Motive3 Motive4 Motive5) i.survey_year if samp_main==1, vce(robust)
margins famgam, dydx(g1_any)
marginsplot


*spec (II): Informal × famgam
nbreg dsm_total i.g2_any##i.famgam c.Exactage i.gender i.Ethnicity i.imd c.adultcaresx ///
    i.(Motive1 Motive2 Motive3 Motive4 Motive5) i.survey_year if samp_main==1, vce(robust)
margins famgam, dydx(g2_any)
marginsplot

*spec (III): regulated × famgam
nbreg dsm_total i.g3_any##i.famgam c.Exactage i.gender i.Ethnicity i.imd c.adultcaresx ///
    i.(Motive1 Motive2 Motive3 Motive4 Motive5) i.survey_year if samp_main==1, vce(robust)
margins famgam, dydx(g3_any)
marginsplot


*-------------------------------------------------------------------------------
*RQ3: MODERATION: (g1/g2/g3) × ADULT CARE (adultcare_continuous)
*     Specs I–III; OLS (robust) + NBREG (robust)
*-------------------------------------------------------------------------------
**OLS
*spec (I): Arcade
reg dsm_total i.g1_any##c.adultcaresx c.Exactage i.gender i.Ethnicity i.imd i.famgam i.(Motive1 Motive2 Motive3 Motive4 Motive5) i.survey_year if samp_main==1, vce(robust)

*spec (II): Informal-setting 
reg dsm_total i.g2_any##c.adultcaresx c.Exactage i.gender i.Ethnicity i.imd i.famgam i.(Motive1 Motive2 Motive3 Motive4 Motive5) i.survey_year if samp_main==1, vce(robust)

*spec (III): regulated-setting 
reg dsm_total i.g3_any##c.adultcaresx c.Exactage i.gender i.Ethnicity i.imd i.famgam i.(Motive1 Motive2 Motive3 Motive4 Motive5) i.survey_year if samp_main==1, vce(robust)
*-------------------


**NBREG
*spec (I): Arcade
nbreg dsm_total i.g1_any##c.adultcaresx c.Exactage i.gender i.Ethnicity i.imd i.famgam i.(Motive1 Motive2 Motive3 Motive4 Motive5) i.survey_year if samp_main==1, vce(robust)
margins, dydx(g1_any) at(adultcaresx=(1 2 3 4 5))

*spec (II): Informal-setting 
nbreg dsm_total i.g2_any##c.adultcaresx c.Exactage i.gender i.Ethnicity i.imd i.famgam i.(Motive1 Motive2 Motive3 Motive4 Motive5) i.survey_year if samp_main==1, vce(robust)
margins, dydx(g2_any) at(adultcaresx=(1 2 3 4 5))

*spec (III): regulated-setting 
nbreg dsm_total i.g3_any##c.adultcaresx c.Exactage i.gender i.Ethnicity i.imd i.famgam i.(Motive1 Motive2 Motive3 Motive4 Motive5) i.survey_year if samp_main==1, vce(robust)
margins, dydx(g3_any) at(adultcaresx=(1 2 3 4 5))

*-------------------------------------------------------------------------------
*RQ4: MODERATION: (g1/g2/g3) × MOTIVES on DSM TOTAL
*-------------------------------------------------------------------------------
**OLS
*spec (I): Arcade
reg dsm_total i.g1_any##i.(Motive1 Motive2 Motive3 Motive4 Motive5) ///
    c.Exactage i.gender i.Ethnicity i.imd i.famgam c.adultcaresx i.survey_year ///
    if samp_main==1, vce(robust)

*spec (II): Informal-setting 
reg dsm_total i.g2_any##i.(Motive1 Motive2 Motive3 Motive4 Motive5) ///
    c.Exactage i.gender i.Ethnicity i.imd i.famgam c.adultcaresx i.survey_year ///
    if samp_main==1, vce(robust)

*spec (III): regulated-setting 
reg dsm_total i.g3_any##i.(Motive1 Motive2 Motive3 Motive4 Motive5) ///
    c.Exactage i.gender i.Ethnicity i.imd i.famgam c.adultcaresx i.survey_year ///
    if samp_main==1, vce(robust)

*-------------------
*-------------------

**NBREG
*spec (I): Arcade × Motive1

nbreg dsm_total i.g1_any##i.Motive1 i.Motive2 i.Motive3 i.Motive4 i.Motive5 ///
    c.Exactage i.gender i.Ethnicity i.imd i.famgam c.adultcaresx i.survey_year ///
    if samp_main==1, vce(robust)

margins Motive1, dydx(g1_any)


*spec (II): Informal-setting 
nbreg dsm_total i.g2_any##i.Motive1 i.Motive2 i.Motive3 i.Motive4 i.Motive5 ///
    c.Exactage i.gender i.Ethnicity i.imd i.famgam c.adultcaresx i.survey_year ///
    if samp_main==1, vce(robust)

margins Motive1, dydx(g2_any)

*spec (III): regulated-setting 
nbreg dsm_total i.g3_any##i.Motive1 i.Motive2 i.Motive3 i.Motive4 i.Motive5 ///
    c.Exactage i.gender i.Ethnicity i.imd i.famgam c.adultcaresx i.survey_year ///
    if samp_main==1, vce(robust)

margins Motive1, dydx(g3_any)
*-------------------

**NBREG
*spec (I): Arcade × Motive2
nbreg dsm_total i.g1_any##i.Motive2 i.Motive1 i.Motive3 i.Motive4 i.Motive5 ///
    c.Exactage i.gender i.Ethnicity i.imd i.famgam c.adultcaresx i.survey_year ///
    if samp_main==1, vce(robust)

margins Motive2, dydx(g1_any)


*spec (II): Informal-setting 
nbreg dsm_total i.g2_any##i.Motive2 i.Motive1 i.Motive3 i.Motive4 i.Motive5 ///
    c.Exactage i.gender i.Ethnicity i.imd i.famgam c.adultcaresx i.survey_year ///
    if samp_main==1, vce(robust)

margins Motive2, dydx(g2_any)

*spec (III): regulated-setting 
nbreg dsm_total i.g3_any##i.Motive2 i.Motive1 i.Motive3 i.Motive4 i.Motive5 ///
    c.Exactage i.gender i.Ethnicity i.imd i.famgam c.adultcaresx i.survey_year ///
    if samp_main==1, vce(robust)

margins Motive2, dydx(g3_any)
*-------------------

**NBREG
*spec (I): Arcade × Motive3
nbreg dsm_total i.g1_any##i.Motive3 i.Motive1 i.Motive2 i.Motive4 i.Motive5 ///
    c.Exactage i.gender i.Ethnicity i.imd i.famgam c.adultcaresx i.survey_year ///
    if samp_main==1, vce(robust)

margins Motive3, dydx(g1_any)


*spec (II): Informal-setting 
nbreg dsm_total i.g2_any##i.Motive3 i.Motive1 i.Motive2 i.Motive4 i.Motive5 ///
    c.Exactage i.gender i.Ethnicity i.imd i.famgam c.adultcaresx i.survey_year ///
    if samp_main==1, vce(robust)

margins Motive3, dydx(g2_any)

*spec (III): regulated-setting 
nbreg dsm_total i.g3_any##i.Motive3 i.Motive1 i.Motive2 i.Motive4 i.Motive5 ///
    c.Exactage i.gender i.Ethnicity i.imd i.famgam c.adultcaresx i.survey_year ///
    if samp_main==1, vce(robust)

margins Motive3, dydx(g3_any)
*-------------------

**NBREG
*spec (I): Arcade × Motive4
nbreg dsm_total i.g1_any##i.Motive4 i.Motive1 i.Motive2 i.Motive3 i.Motive5 ///
    c.Exactage i.gender i.Ethnicity i.imd i.famgam c.adultcaresx i.survey_year ///
    if samp_main==1, vce(robust)

margins Motive4, dydx(g1_any)


*spec (II): Informal-setting 
nbreg dsm_total i.g2_any##i.Motive4 i.Motive1 i.Motive2 i.Motive3 i.Motive5 ///
    c.Exactage i.gender i.Ethnicity i.imd i.famgam c.adultcaresx i.survey_year ///
    if samp_main==1, vce(robust)

margins Motive4, dydx(g2_any)

*spec (III): regulated-setting 
nbreg dsm_total i.g3_any##i.Motive4 i.Motive1 i.Motive2 i.Motive3 i.Motive5 ///
    c.Exactage i.gender i.Ethnicity i.imd i.famgam c.adultcaresx i.survey_year ///
    if samp_main==1, vce(robust)

margins Motive4, dydx(g3_any)
*-------------------

**NBREG
*spec (I): Arcade × Motive5
nbreg dsm_total i.g1_any##i.Motive5 i.Motive1 i.Motive2 i.Motive3 i.Motive4 ///
    c.Exactage i.gender i.Ethnicity i.imd i.famgam c.adultcaresx i.survey_year ///
    if samp_main==1, vce(robust)

margins Motive5, dydx(g1_any)


*spec (II): Informal-setting 
nbreg dsm_total i.g2_any##i.Motive5 i.Motive1 i.Motive2 i.Motive3 i.Motive4 ///
    c.Exactage i.gender i.Ethnicity i.imd i.famgam c.adultcaresx i.survey_year ///
    if samp_main==1, vce(robust)

margins Motive5, dydx(g2_any)

*spec (III): regulated-setting 
nbreg dsm_total i.g3_any##i.Motive5 i.Motive1 i.Motive2 i.Motive3 i.Motive4 ///
    c.Exactage i.gender i.Ethnicity i.imd i.famgam c.adultcaresx i.survey_year ///
    if samp_main==1, vce(robust)

margins Motive5, dydx(g3_any)
*-------------------




*-------------------------------------------------------------------------------
*-------------------------------------------------------------------------------
*Alternative outcome variable: g1/g2/g3 on DSM category
*-------------------------------------------------------------------------------
*-------------------------------------------------------------------------------


tab dsm_cat, missing


*spec (I): no controls
 oprobit dsm_cat i.g1_any i.g2_any i.g3_any i.survey_year if samp_main==1, vce(robust)
margins, dydx(g1_any g2_any g3_any) predict(outcome(0))
margins, dydx(g1_any g2_any g3_any) predict(outcome(1))
margins, dydx(g1_any g2_any g3_any) predict(outcome(2))

*spec (II): controlling for demographics 
 oprobit dsm_cat i.g1_any i.g2_any i.g3_any c.Exactage i.gender i.Ethnicity i.imd i.survey_year if samp_main==1, vce(robust)
margins, dydx(g1_any g2_any g3_any) predict(outcome(0))
margins, dydx(g1_any g2_any g3_any) predict(outcome(1))
margins, dydx(g1_any g2_any g3_any) predict(outcome(2))

*spec (II): controlling for enviroment 
 oprobit dsm_cat i.g1_any i.g2_any i.g3_any i.famgam c.adultcaresx i.survey_year if samp_main==1, vce(robust)
margins, dydx(g1_any g2_any g3_any) predict(outcome(0))
margins, dydx(g1_any g2_any g3_any) predict(outcome(1))
margins, dydx(g1_any g2_any g3_any) predict(outcome(2))

*spec (III): controlling for motives 
 oprobit dsm_cat i.g1_any i.g2_any i.g3_any i.(Motive1 Motive2 Motive3 Motive4 Motive5) i.survey_year if samp_main==1, vce(robust)
margins, dydx(g1_any g2_any g3_any) predict(outcome(0))
margins, dydx(g1_any g2_any g3_any) predict(outcome(1))
margins, dydx(g1_any g2_any g3_any) predict(outcome(2))

*spec (IV): controlling for all 
 oprobit dsm_cat i.g1_any i.g2_any i.g3_any c.Exactage i.gender i.Ethnicity i.imd i.famgam c.adultcaresx i.(Motive1 Motive2 Motive3 Motive4 Motive5) i.survey_year if samp_main==1, vce(robust)
margins, dydx(g1_any g2_any g3_any) predict(outcome(0))
margins, dydx(g1_any g2_any g3_any) predict(outcome(1))
margins, dydx(g1_any g2_any g3_any) predict(outcome(2))


*-------------------------------------------------------------------------------
*-------------------------------------------------------------------------------
*Alternative outcome variable: Moderation effects g1/g2/g3 * c.adultcaresx on DSM category
*-------------------------------------------------------------------------------
*-------------------------------------------------------------------------------

*spec (I): no controls
oprobit dsm_cat c.adultcaresx##(i.g1_any i.g2_any i.g3_any) i.survey_year if samp_main==1, vce(robust)

margins, dydx(g1_any g2_any g3_any) at(adultcaresx=(1 2 3 4 5)) predict(outcome(0))
margins, dydx(g1_any g2_any g3_any) at(adultcaresx=(1 2 3 4 5)) predict(outcome(1))
margins, dydx(g1_any g2_any g3_any) at(adultcaresx=(1 2 3 4 5)) predict(outcome(2))

*spec (II): controlling for demographics 
oprobit dsm_cat c.adultcaresx##(i.g1_any i.g2_any i.g3_any) c.Exactage i.gender i.Ethnicity i.imd i.survey_year if samp_main==1, vce(robust)
margins, dydx(g1_any g2_any g3_any) at(adultcaresx=(1 2 3 4 5)) predict(outcome(0))
margins, dydx(g1_any g2_any g3_any) at(adultcaresx=(1 2 3 4 5)) predict(outcome(1))
margins, dydx(g1_any g2_any g3_any) at(adultcaresx=(1 2 3 4 5)) predict(outcome(2))

*spec (II): controlling for enviroment 
oprobit dsm_cat c.adultcaresx##(i.g1_any i.g2_any i.g3_any) i.famgam  i.survey_year if samp_main==1, vce(robust)
margins, dydx(g1_any g2_any g3_any) at(adultcaresx=(1 2 3 4 5)) predict(outcome(0))
margins, dydx(g1_any g2_any g3_any) at(adultcaresx=(1 2 3 4 5)) predict(outcome(1))
margins, dydx(g1_any g2_any g3_any) at(adultcaresx=(1 2 3 4 5)) predict(outcome(2))

*spec (III): controlling for motives 
oprobit dsm_cat c.adultcaresx##(i.g1_any i.g2_any i.g3_any) i.(Motive1 Motive2 Motive3 Motive4 Motive5) i.survey_year if samp_main==1, vce(robust)
margins, dydx(g1_any g2_any g3_any) at(adultcaresx=(1 2 3 4 5)) predict(outcome(0))
margins, dydx(g1_any g2_any g3_any) at(adultcaresx=(1 2 3 4 5)) predict(outcome(1))
margins, dydx(g1_any g2_any g3_any) at(adultcaresx=(1 2 3 4 5)) predict(outcome(2))

*spec (IV): controlling for all 
oprobit dsm_cat c.adultcaresx##(i.g1_any i.g2_any i.g3_any) c.Exactage i.gender i.Ethnicity i.imd i.famgam i.(Motive1 Motive2 Motive3 Motive4 Motive5) i.survey_year if samp_main==1, vce(robust)
margins, dydx(g1_any g2_any g3_any) at(adultcaresx=(1 2 3 4 5)) predict(outcome(0))
margins, dydx(g1_any g2_any g3_any) at(adultcaresx=(1 2 3 4 5)) predict(outcome(1))
margins, dydx(g1_any g2_any g3_any) at(adultcaresx=(1 2 3 4 5)) predict(outcome(2))


/*
*------------------------------------------------------------
* Make sure missing flags don't silently drop observations
* (safe if missings are only non-asked routing)
*------------------------------------------------------------
replace g1_any = 0 if missing(g1_any) & samp_main==1
replace g2_any = 0 if missing(g2_any) & samp_main==1
replace g3_any = 0 if missing(g3_any) & samp_main==1

*------------------------------------------------------------
* Create 0–7 combo categories (overlapping structure preserved)
*------------------------------------------------------------
gen byte g_combo = .
replace g_combo = 0 if g1_any==0 & g2_any==0 & g3_any==0
replace g_combo = 1 if g1_any==1 & g2_any==0 & g3_any==0   // Arcade only  (THIS will be base)
replace g_combo = 2 if g1_any==0 & g2_any==1 & g3_any==0   // Informal only
replace g_combo = 3 if g1_any==0 & g2_any==0 & g3_any==1   // Regulated only
replace g_combo = 4 if g1_any==1 & g2_any==1 & g3_any==0   // Arcade + Informal
replace g_combo = 5 if g1_any==1 & g2_any==0 & g3_any==1   // Arcade + Regulated
replace g_combo = 6 if g1_any==0 & g2_any==1 & g3_any==1   // Informal + Regulated
replace g_combo = 7 if g1_any==1 & g2_any==1 & g3_any==1   // All three

label define g_combo 0 "None" 1 "Arcade only (g1)" 2 "Informal only (g2)" 3 "Regulated only (g3)" ///
                    4 "g1+g2" 5 "g1+g3" 6 "g2+g3" 7 "g1+g2+g3", replace
label values g_combo g_combo

*------------------------------------------------------------
* Regression with Arcade-only as the omitted (base) category
*------------------------------------------------------------
reg dsm_total ib1.g_combo i.survey_year if samp_main==1, vce(robust)
*/


*log close 
*===============================================================================
*end of do file
*===============================================================================
