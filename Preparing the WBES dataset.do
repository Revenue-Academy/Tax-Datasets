*This file imports country-level averages on 3 WBES indicators from an excel
*file created using the enterprisesurveys website


cd "D:\WB Tax Consultancy"


/**********************/
/*****Informality******/
/**********************/

clear all
set more off

import excel "Enterprise Surveys.xlsx", sheet("Informality") firstrow case(lower)

drop subgroup topsub subgroupl average 
rename percentoffirmsc percentcompeting
rename percentoffirmsf percentregistered
rename number yearsinformal
rename percentoffirmsi informalconstraint
replace percentc="" if percentc=="..."
replace percentr="" if percentr=="..."
replace years="" if years=="..."
replace informal="" if informal=="..."
destring percentc percentr years informal, replace

rename economy country

save "WBES informality", replace

/**********************/
/*********Tax**********/
/**********************/

clear all

import excel "Enterprise Surveys.xlsx", sheet("Regulations and Taxes") firstrow case(lower)

drop subgroup topsub subgroupl average numberof

rename senior managementtime
rename percentoffirmsvi firmsvisited
rename daystoobtainano operatinglicensedays
rename ifthere numbervisits
rename daystoobtainac constructionpermitdays
rename days importlicensedays
rename o taxadminconstraint
rename percentoffirmsidentifyingbus licenseconstraint
rename percent taxrateconstraint
replace operating="" if operating=="..." | operating=="n.a."
replace constr="" if constr=="..." | constr=="n.a."
replace impo="" if impo=="..." | impo=="n.a."
replace taxa="" if taxa=="..."
destring operating constr impo taxa, replace

rename economy country

save "WBES tax", replace

/**********************/
/*******Merging********/
/**********************/

merge 1:1 _n using "WBES informality"
drop _merge

save "World Bank Enterprise Surveys", replace
