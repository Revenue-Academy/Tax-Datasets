clear all
set more off

cd "C:\Users\WB542385\Downloads"

import excel "SSA social safety nets benefit incidence, poorest quintile.xlsx", ///
 sheet("Data") firstrow case(lower)

drop seriescode
drop countrycode

foreach u of varlist yr1998-yr2018 {

	replace `u'="" if `u'==".."

}

rename countryname Country
destring yr1998-yr2018, replace

reshape long yr, i(Country) j(year)

save "SSA social safety nets benefit incidence, poorest quintile.dta", replace

clear all

import excel "SSA social safety nets coverage, poorest quintile.xlsx", ///
 sheet("Data") firstrow case(lower)

drop seriescode
drop countrycode

foreach u of varlist yr1998-yr2018 {

	replace `u'="" if `u'==".."

}

rename countryname Country
destring yr1998-yr2018, replace

reshape long yr, i(Country) j(year)

save "SSA social safety nets coverage, poorest quintile.dta", replace

merge m:1 Country year using "C:\Users\WB542385\Downloads\SSA social safety nets benefit incidence, poorest quintile.dta"

save "SSA social safety nets coverage and benefit incidence, poorest quintile.dta", replace
