clear all
set more off

cd "C:\Users\Joe\Desktop\WB STC\GGOGT\Tax Revenue Analysis"
import excel "Polity Dataset Democracy.xls", sheet("Sheet1") firstrow clear

drop if year<1990
drop scode country

rename democracy score
gen autocracy=(score<=-6 & score!=.)
gen anocracy =(score>=-5 & score<=5 & score!=.)
gen democracy=(score>= 6 & score!=.)

gen politylessfree=(score<=0 & score!=.)
gen politymorefree=(score> 0 & score!=.)

label var autocracy "-6 or less score"
label var anocracy "-5 to 5 score"
label var democracy "6 or higher score"
label var politylessfree "-10 to 0 score"
label var politymorefree "1 to 10 score"

rename score polityscore

foreach v of varlist _all{

	local u: variable label `v'
	local x = "[Polity 2017] " + "`u'"
	label var `v' "`x'"
	
}

save "Polity Dataset Democracy.dta", replace

use "Master Dataset.dta", clear
merge m:1 Country_Code year using "Polity Dataset Democracy.dta"

drop if _merge==2
drop _merge

cap drop if Country=="Laos"
cap drop if Country=="Timor-Leste"

sort Country year
save "Master Dataset.dta", replace

/*tidying up some Region discrepancies*/
tab Reg Region_Code
replace Reg=3 if Country=="St. Vincent and the Grenadines"
replace Region_Code="ECA" if Country=="Turkey"
replace Region_Code="MENA" if Country=="Djibouti"
replace Region_Code="SSA" if Country=="Mauritania"
tab Reg Region_Code

save "Master Dataset.dta", replace

