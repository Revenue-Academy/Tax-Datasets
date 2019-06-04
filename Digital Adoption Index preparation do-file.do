clear all
set more off

cd "C:\Users\WB542385\OneDrive - WBG"

/*DIGITAL ADOPTION INDEX*/

import excel "C:\Users\WB542385\OneDrive - WBG\DAIforweb.xlsx", sheet("Sheet1") ///
 firstrow case(lower)
 
replace country="Cape Verde" if country=="Cabo Verde"

rename country Country

foreach v of varlist daigovernmentsubindex daipeoplesubindex daibusinesssubindex ///
 digitaladoptionindex {
	local u: variable label `v'
	local x = "[DAI 2016] " + "`u'"
	label var `v' "`x'"
}

save "DAI dataset.dta", replace
