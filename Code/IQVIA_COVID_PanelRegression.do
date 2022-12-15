* COVID-19 and Antibiotic Prescibing
* Panel regression aand Descriptive Statistics
* Created by Alisa Hamilton

clear all
set more off

// Import data
cd "[Main file path]/Data"
import delimited using "IQVIA_2017_2020_byCounty_forRegression", clear

// EducationWeek make school status factor variables
replace school_edu = "hybrid/remote/trad" if school_edu == "no order"
replace school_edu = "1" if school_edu == "" // July summer vacation
replace school_edu = "1" if school_edu == "closed"
replace school_edu = "2" if school_edu == "partially closed"
replace school_edu = "2" if school_edu == "hybrid/remote/trad"
replace school_edu = "3" if school_edu == "open"
encode school_edu, gen(school)
drop school_edu

// MCH make school status factor variables
replace teachingmethod = "1" if teachingmethod == "Closed" // July summer vacation
replace teachingmethod = "2" if teachingmethod == "Hybrid/Other"
replace teachingmethod = "3" if teachingmethod == "Open"
encode teachingmethod, gen(school_mch)
drop teachingmethod

// recode NPIs. binary or 1/3
replace movement_restrictions = 0 if movement_restrictions == 1 // 0 = No restrictions or recommended
replace movement_restrictions = 1 if movement_restrictions == 2 // 1 = Restrictions in place
replace face_coverings = 0 if face_coverings == 1 // No policy or recommended
replace face_coverings = 0 if face_coverings == 2 // Recommended
replace face_coverings = 0 if face_coverings == 3 // Required in all public spaces where distancing isn't possible
replace face_coverings = 1 if face_coverings == 4 // 2 = Required in all situations outside home

// generate squared variables for non-linear poverty and minority status
gen povertysquared = povertypercent^2
gen minoritysquared = minoritypercent^2

//create logs
gen log_ddd2020_per100k = log(ddd2020_per100k)
gen log_ddd2019_per100k = log(ddd2019_per100k)
gen log_ddd17_19avg_per100k = log(ddd17_19avg_per100k)
gen log_cases = log(monthly_cases_per100k)
gen log_child_ddd2020_per100k = log(child_ddd2020per100k)
gen log_child_ddd2019_per100k = log(child_ddd2019per100k)
gen log_child_ddd17_19avg_per100k = log(childddd17_19avg_per100k)
gen log_tests_per100k = log(tests_per100k)

gen log_trx2020_per100k = log(trx2020_per100k)
gen log_trx17_19avg_per100k = log(trx17_19avg_per100k)
gen log_child_2020trxper100k = log(child_trx2020per100k)
gen log_childtrx17_19avg_per100k = log(childtrx17_19avg_per100k)

gen log_hcworkers_per100k = log(hcworkers_per100k)
gen log_nursingcare_per100k = log(nursingcare_per100k)
gen log_assistedliving_per100k = log(assistedliving_per100k)

gen log_physician_off_per100k = log(physician_off_per100k)
replace log_physician_off_per100k = 0 if log_physician_off_per100k == .
gen log_kidneydialysis_per100k = log(kidneydialysis_per100k)
gen log_hospitals_per100k = log(hospitals_per100k)
gen log_ltcfs_per100k = log(ltcfs_per100k)

// label variables
label variable movement_restrictions "Internal movement restrictions"
label variable face_coverings "Facial coverings"
label variable school "State School Status"
label variable school_mch "County School Status"
label variable state "State"
label variable urcode "Urbanization Level"
label variable povertysquared "Percent of Population in Poverty Squared"
label variable povertypercent "Percent of Population in Poverty"
label variable tests_per100k "Monthly Tests per 100,000 Population"
label variable monthly_cases_per100k "Monthly COVID-19 Cases per 100,000 Population"
label variable month "Month"
label variable minoritysquared "Percent of Population of Ethnic Minority Squared"
label variable minoritypercent "Percent of Population of People of Color"
label variable fips "FIPS Code"
label variable ddd2020_per100k "2020 Monthly DDDs per 100,000 Population"
label variable ddd17_19avg_per100k "2017-2019 Average Monthly DDDs per 100,000 Population"
label variable log_cases "Log of Monthly COVID-19 Cases per 100,000 Population"
label variable log_ddd2020_per100k "Log of 2020 Monthly DDDs per 100,000 Population"
label variable log_ddd17_19avg_per100k "Log of 2017-2019 Average Monthly DDDs per 100,000 Population"
label variable log_ddd2019_per100k "Log of 2019 Monthly DDDs per 100,000 Population"
label variable child_ddd2020per100k "2020 Monthly DDDs per 100,000 Children 0-9"
label variable log_child_ddd2020_per100k "Log of 2020 Monthly DDDs per 100,000 Children 0-9"
label variable log_child_ddd17_19avg_per100k "Log of 2017-2019 Average Monthly DDDs per 100,000 Children 0-9"
label variable log_child_ddd2019_per100k "Log of 2019 Monthly DDDs per 100,000 Children 0-9"
label variable log_tests_per100k "Log of Monthly COVID-19 Tests per 100,000 Population"
label variable log_trx2020_per100k "Log of 2020 Monthly Number of Prescriptions per 100,000 Population"
label variable log_trx17_19avg_per100k "Log of 2017-2019 Monthly Number of Prescriptions per 100,000 Population"
label variable log_child_2020trxper100k "Log of 2020 Monthly Number of Prescriptions per 100,000 Children 0-9"
label variable log_childtrx17_19avg_per100k "Log of 2017-2019 Monthly Number of Prescriptions per 100,000 Children 0-9"
label variable log_hcworkers_per100k "Log of Healthcare Workers per 100,000 Population"
label variable log_nursingcare_per100k "Log of Nursing Care Facilities per 100,000 Population"
label variable log_assistedliving_per100k "Log of Assisted Living Facilities per 100,000 Population"
label variable log_physician_off_per100k "Log of Physicians' Offices per 100,000 Population"
label variable log_kidneydialysis_per100k "Log of Kidney Dialysis Centers per 100,000 Population"
label variable log_hospitals_per100k "Log of Hospitals per 100,000 Population"
label variable log_ltcfs_per100k "Log of Long-term Care Facilities per 100,000 Population"

// label NPI variables
//label define movementlabel 0 "No measures" 1 "Recommend not to travel between regions/cities" 2 "Internal movement restrictions in place"
label define movementlabel 0 "No restrictions/Recommended" 1 "Restrictions in place"
label values movement_restrictions movementlabel

// label define facelabel 0 "No policy" 0 "Recommended" 0 "Required in some situations/public spaces" 0 "Required in all public spaces where distancing not possible" 4 "Required outside the home at all times"
label define facelabel 0 "No policy/Recommended/Required in some places" 1 "Required in all places outside the home"
label values face_coverings facelabel

// EducationWeek label values for schools, urbanization level, month, and state
label define schoollabel 1 "Closed" 2 "Hybrid/Partially Closed/No Order" 3 "Ordered Open" 
label values school schoollabel

// MCH school label values for schools, urbanization level, month, and state
label define schoolmch_label 1 "Closed" 2 "Hybrid/Other/Unknown" 3 "Open"
label values school_mch schoolmch_label

label define urcodelabel 1 "Large Central Metro" 2 "Large Fringe Metro" 3 "Medium Metro" 4 "Small Metro" 5 "Micropolitan" 6 "Noncore"
label values urcode urcodelabel

label define monthlabel 1 "January" 2 "February" 3 "March" 4 "April" 5 "May" 6 "June" 7 "July" 8 "August" 9 "September" 10 "October" 11 "November" 12 "December"
label values month monthlabel

label define statelabel 1 "Alabama" 2 "Alaska" 4 "Arizona" 5 "Arkansas" 6 "California" 8 "Colorado" 9 "Connecticut" 10 "Delaware" 11 "District of Columbia" 12 "Florida" 13 "Georgia" 15 "Hawaii" 16 "Idaho" 17 "Illinois" 18 "Indiana" 19 "Iowa" 20 "Kansas" 21 "Kentucky" 22 "Louisiana" 23 "Maine" 24 "Maryland" 25 "Massachusetts" 26 "Michigan" 27 "Minnesota" 28 "Mississippi" 29 "Missouri" 30 "Montana" 31 "Nebraska" 32 "Nevada" 33 "New Hampshire" 34 "New Jersey" 35 "New Mexico" 36 "New York" 37 "North Carolina" 38 "North Dakota" 39 "Ohio" 40 "Oklahoma" 41 "Oregon" 42 "Pennsylvania" 44 "Rhode Island" 45 "South Carolina" 46 "South Dakota" 47 "Tennessee" 48 "Texas" 49 "Utah" 50 "Vermont" 51 "Virginia" 53 "Washington" 54 "West Virginia" 55 "Wisconsin" 56 "Wyoming" 
label values state statelabel

// Save and export
xtset fips month
save finaldataset, replace
export delimited using "IQVIA_2017_2020_byCounty_forFigures.csv", replace

*************************** final model ****************************************

cd "[Main file path]/Data"

use finaldataset, clear
//drop if month < 3
xtset fips month

cd "[Main file path]/Results"

//trx all ages MCH
xtreg log_trx2020_per100k log_cases log_tests_per100k log_trx17_19avg_per100k log_physician_off_per100k povertypercent minoritypercent i.school_mch i.movement_restrictions i.face_coverings i.urcode i.month i.state, re
outreg2 using "iqvia_covid_regression_trx_mch.xls", replace excel ci sideway label dec(3) noobs

// check residuals and rule out poisson or negative binomial regression
histogram log_trx2020_per100k, normal
predict Fitted, xb
predict Epsilon, e
twoway (scatter Epsilon Fitted), ytitle(Epsilon residuals) xtitle(Fitted values)

// trx children
xtreg log_child_2020trxper100k log_cases log_tests_per100k log_childtrx17_19avg_per100k log_physician_off_per100k povertypercent minoritypercent i.school_mch i.movement_restrictions i.face_coverings i.urcode i.month i.state, re
outreg2 using "iqvia_covid_regression_children_trx_mch.xls", replace excel ci sideway label dec(3) noobs

//trx all ages EDU
xtreg log_trx2020_per100k log_cases log_tests_per100k log_trx17_19avg_per100k log_physician_off_per100k povertypercent minoritypercent i.school i.movement_restrictions i.face_coverings i.urcode i.month i.state, re
outreg2 using "iqvia_covid_regression_trx_edu.xls", replace excel ci sideway label dec(3) noobs

//trx children EDU
xtreg log_child_2020trxper100k log_cases log_tests_per100k log_childtrx17_19avg_per100k log_physician_off_per100k povertypercent minoritypercent i.school i.movement_restrictions i.face_coverings i.urcode i.month i.state, re
outreg2 using "iqvia_covid_regression_children_trx_edu.xls", replace excel ci sideway label dec(3) noobs

// ddd all ages
xtreg log_ddd2020_per100k log_cases log_tests_per100k log_ddd17_19avg_per100k log_physician_off_per100k povertypercent minoritypercent i.school_mch i.movement_restrictions i.face_coverings i.urcode i.month i.state, re
outreg2 using "iqvia_covid_regression_ddd_mch.xls", replace excel ci sideway label dec(3) noobs

**************** Descriptives ***************************************************

cd "[Main file path]/Data"
use finaldataset, clear
drop v1

*** Continuous variables ***
ci means monthly_cases_per100k
ci means tests_per100k
ci means trx2020_per100k
ci means trx17_19avg_per100k
ci means child_trx2020per100k
ci means childtrx17_19avg_per100k
ci means physician_off_per100k
ci means povertypercent
ci means minoritypercent

summarize monthly_cases_per100k
summarize trx2020_per100k
summarize trx17_19avg_per100k
summarize child_2020trxper100k
summarize childtrx17_19avg_per100k

*** Categorical variables ***
// frequency and percent
tab school_mch
tab movement_restrictions
tab face_coverings
tab urcode
tab month
tab state

// CIs by categorical variable
// all ages trx
sort school_mch
by school_mch: ci means trx2020_per100k
sort movement_restrictions
by movement_restrictions: ci means trx2020_per100k
sort face_coverings
by face_coverings: ci means trx2020_per100k
sort urcode
by urcode: ci means trx2020_per100k
sort month
by month: ci means trx2020_per100k
sort state
by state: ci means trx2020_per100k

//children trx
sort school_mch
by school_mch: ci means child_trx2020per100k
sort movement_restrictions
by movement_restrictions: ci means child_trx2020per100k
sort face_coverings
by face_coverings: ci means child_trx2020per100k
sort urcode
by urcode: ci means child_trx2020per100k
sort month
by month: ci means child_trx2020per100k
sort state
by state: ci means child_trx2020per100k

//cases per 100k
sort school_mch
by school_mch: ci means monthly_cases_per100k
sort movement_restrictions
by movement_restrictions: ci means monthly_cases_per100k
sort face_coverings
by face_coverings: ci means monthly_cases_per100k
sort urcode
by urcode: ci means monthly_cases_per100k
sort month
by month: ci means monthly_cases_per100k
sort state
by state: ci means monthly_cases_per100k

*** ANOVA ***
//TRX all ages
oneway trx2020_per100k school_mch, tabulate
oneway trx2020_per100k movement_restrictions, tabulate
oneway trx2020_per100k face_coverings, tabulate
oneway trx2020_per100k urcode, tabulate
oneway trx2020_per100k month, tabulate
oneway trx2020_per100k state, tabulate
//TRX children
oneway child_2020trxper100k school, tabulate
oneway child_2020trxper100k movement_restrictions, tabulate
oneway child_2020trxper100k face_coverings, tabulate
oneway child_2020trxper100k urcode, tabulate
oneway child_2020trxper100k month, tabulate
oneway child_2020trxper100k state, tabulate
//Cases
oneway monthly_cases_per100k school, tabulate
oneway monthly_cases_per100k movement_restrictions, tabulate
oneway monthly_cases_per100k face_coverings, tabulate
oneway monthly_cases_per100k urcode, tabulate
oneway monthly_cases_per100k month, tabulate
oneway monthly_cases_per100k state, tabulate



