clear all
set more off

//cd "D:\WB Tax Consultancy"

//This dofile assembles and adapts the datasets created by Eric Lacey and Joseph Massad
//such that they fit into the dataset already created by Sebastian James, which
//contains UNU-WIDER data, WDI data, and other data already.

/*****************************/
/*****Enterprise Surveys******/
/*****************************/

use "World Bank Enterprise Surveys.dta", clear

foreach v of varlist _all{
	local u: variable label `v'
	local x = "[Enterprise Surveys] " + "`u'"
	label var `v' "`x'"
}
label var country "Economy"
label var year "Year"
rename country Country
replace Country="Cape Verde" if Country=="Cabo Verde"
replace Country="Cote d'Ivoire" if Country=="Côte d'Ivoire"
replace Country="Guyana" if Country=="Guyana, CR"
replace Country="Venezuela, RB" if Country=="Venezuela, R.B."

save "World Bank Enterprise Surveys.dta", replace

use "Augmented Tax Dataset after Sebastian's dofiles.dta", clear
merge m:1 Country year using "World Bank Enterprise Surveys.dta"
drop if _merge==2
drop _merge

save "Master Dataset.dta",replace

/**************************/
/*****CPIA Indicators******/
/**************************/

use "CPIA Indicators.dta", clear

rename country Country
rename country_code Country_Code

save "CPIA Indicators.dta", replace

use "Master Dataset.dta", clear
merge m:1 Country_Code year using "CPIA Indicators.dta"
drop if _merge==2
drop _merge

save "Master Dataset.dta", replace

/****************************************/
/*****Tax Incentives & Transparency******/
/****************************************/

use "Tax incentives and transparency.dta", clear

rename country Country
drop region incomelevel

bysort Country year: egen highestholiday=max(holiday_u)
bysort Country year: egen highestconcession=max(concession_u)

label var highestholiday "longest income tax holiday in given year (unconditional)"
label var highestconcession "greatest concessionary tax rate in given year (unconditional)"

foreach v of varlist _all{
	local u: variable label `v'
	local x = "[Tax Incentives] " + "`u'"
	label var `v' "`x'"
}
label var year "year"
label var Country "country"

foreach v of var cit holiday* concession* allowance* highest* {
	local l`v' : variable label `v'
}
collapse cit holiday* concession* allowance* highest*, by(Country year)
foreach v of var cit holiday* concession* allowance* highest* {
	label var `v' "`l`v''"
}

replace Country="Congo, Dem. Rep." if Country=="Congo, Democratic Republic of"
replace Country="Congo, Rep." if Country=="Congo, Republic of"
replace Country="Egypt, Arab Rep." if Country== "Egypt"
replace Country="Gambia, The" if Country=="Gambia"
replace Country="Lao PDR" if Country=="Lao"
replace Country="Macao SAR, China" if Country=="Macau"
replace Country="Slovak Republic" if Country=="Slovak Rep."
replace Country="Korea, Rep." if Country=="South Korea"
replace Country="Venezuela, RB" if Country=="Venezuela"

save "Tax incentives and transparency.dta", replace

use "Master Dataset.dta", clear
merge m:m Country year using "Tax incentives and transparency.dta"
drop if _merge==2
drop _merge

save "Master Dataset.dta", replace

/*************************/
/*****Doing Business******/
/*************************/

use "Doing Business Historical - Paying Taxes.dta", clear

rename country Country
rename country_code Country_Code
drop region income_group
foreach v of varlist _all{
	local u: variable label `v'
	local x = "[Doing Business] " + "`u'"
	label var `v' "`x'"
}
label var year "year"
label var Country "country"
label var Country_Code "code"

save "Doing Business Historical - Paying Taxes.dta", replace

use "Master Dataset.dta", clear
merge m:1 Country_Code year using "Doing Business Historical - Paying Taxes.dta"
drop if _merge==2
drop _merge

save "Master Dataset.dta", replace

/************************/
/*****Afrobarometer******/
/************************/

use "afrobaro.dta", clear

foreach v of varlist _all{
	local u: variable label `v'
	local x = "[Afrobaro] " + "`u'"
	label var `v' "`x'"
}
label var year "year"

decode country, gen(Country)
drop country
replace Country="Egypt, Arab Rep." if Country=="Egypt"

save "afrobaro.dta", replace

use "Master Dataset.dta", clear
merge m:1 Country year using "afrobaro.dta"
drop if _merge==2
drop _merge

save "Master Dataset.dta", replace


/*********************/
/*****Tax Treaty******/
/*********************/

use "Tax Treaties (Country Year Level).dta", clear

foreach v of varlist _all{
	local u: variable label `v'
	local x = "[Tax Treaty] " + "`u'"
	label var `v' "`x'"
}
label var year "year"
rename C1 Country
label var Country "country"

replace Country = "Congo, Dem. Rep." if Country=="Congo (Dem. Rep.)"
replace Country = "Congo, Rep." if Country=="Congo (Rep.)"
replace Country = "Gambia, The" if Country=="Gambia"
replace Country = "Cote d'Ivoire" if Country=="Ivory Coast"

save "Tax Treaties (Country Year Level).dta", replace

use "Master Dataset.dta", clear
merge m:1 Country year using "Tax Treaties (Country Year Level).dta"
drop _merge
label var numberoftreaties "[Tax Treaty] Number of tax treaties for this country for this year"

save "Master Dataset.dta", replace


/***************/
/*****PEFA******/
/***************/

use "PEFA 2011.dta", clear

gen year=2011

drop Date Lastupdate

foreach v of varlist _all{
	local u: variable label `v'
	local x = "[PEFA 2011] " + "`u'"
	label var `v' "`x'"
}
label var year "year"
label var Country "country"

replace Country="Bosnia and Herzegovina" if Country=="Bosnia & Herzegovina-BiH" | Country=="Bosnia & Herzegovina-DB" | Country=="Bosnia & Herzegovina-FBiH" | Country=="Bosnia & Herzegovina-RS"
replace Country="Cape Verde" if Country=="Cabo Verde"
replace Country="Congo, Dem. Rep." if Country=="Congo, Dem. Rep. of"
replace Country="Congo, Republic of" if Country=="Congo, Rep."
replace Country="Egypt, Arab Rep." if Country=="Egypt"

//the PEFA dataset must be "collapsed" to produce average scores for countries
//with more than one observation per year
//the collapse command deletes variable labels, so they must be reapplied
foreach v of var PI* D* {
	local l`v' : variable label `v'
}
collapse PI* D*, by(Country year)
foreach v of var PI* D* {
	label var `v' "`l`v''"
}

save "PEFA 2011.dta", replace

use "Master Dataset.dta", clear
merge m:1 Country year using "PEFA 2011.dta"
drop if _merge==2
drop _merge

save "Master Dataset.dta", replace

