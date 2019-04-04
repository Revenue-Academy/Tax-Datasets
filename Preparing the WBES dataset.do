*This file imports country-level averages on 3 WBES indicators from an excel
*file created using the enterprisesurveys website


cd "D:\WB Tax Consultancy"


/**********************/
/*****Informality******/
/**********************/

clear all
set more off

import excel "Enterprise Surveys.xlsx", sheet("Informality") firstrow case(lower)

drop subgroup topsub subgroupl average percentoffirmsc percentoffirmsf number
replace percent="" if percent=="..."
destring percent, replace

label var percent "Percent of firms identifying informal competition as a major constraint"
rename percent informalityconstraint
rename economy country

save "WBES informality", replace

/**********************/
/*********Tax**********/
/**********************/

clear all
set more off

import excel "Enterprise Surveys.xlsx", sheet("Regulations and Taxes") firstrow case(lower)

drop subgroup topsub subgroupl average senior numberof percentoffirmsvisit ifthere days* percentoffirmsidentifyingbus
replace o="" if o=="..."
destring o, replace

rename o taxadminconstraint
rename economy country
rename percent taxrateconstraint

save "WBES tax", replace

/**********************/
/*******Merging********/
/**********************/

merge 1:1 _n using "WBES informality"
drop _merge

save "World Bank Enterprise Surveys", replace
