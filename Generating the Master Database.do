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

save "Master Dataset.dta", replace

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

cd "D:\WB Tax Consultancy\tax incentives\WBG_incentivesdatabase"
use "2_incentives_database.dta", clear
cd "D:\WB Tax Consultancy"

rename country Country
drop region incomelevel

//concession rates
bysort Country year: egen averageconcession_u=mean(concession_u)
egen lowestconcessionbyline=rowmin(concession_u concession_l concession_o concession_x concession_n)
bysort Country year: egen lowestconcession=min(lowestconcessionbyline)

//holidays
egen holidaybyline=rowmean(holiday_u holiday_l holiday_o holiday_x holiday_n)
bysort Country year: egen averageholiday=mean(holiday_u)
egen longestholidaybyline=rowmax(holiday_u holiday_l holiday_o holiday_x holiday_n)
bysort Country year: egen longestholiday=max(longestholidaybyline)

keep Country year cit averageconcession lowestconcession averageholiday longestholiday
rename cit citRATE

foreach v of var citRATE average* lowest longest {
	local l`v' : variable label `v'
}
collapse citRATE average* lowest longest, by(Country year)
foreach v of var citRATE average* lowest longest {
	label var `v' "`l`v''"
}

label var citRATE "Official Corporate Income Tax Rate"
label var averageconcession "Unconditional concessionary rate (flat average across sectors)"
label var lowestconcession "Lowest concessionary rate (given any condition or sector)"
label var averageholiday "Unconditional tax holiday in years (flat average across sectors)"
label var longestholiday "Longest tax holiday (given any condition or sector)"
foreach v of varlist _all{
	local u: variable label `v'
	local x = "[Tax Incentives] " + "`u'"
	label var `v' "`x'"
}
label var year "year"
label var Country "country"

replace Country="Congo, Dem. Rep." if Country=="Congo, Democratic Republic of"
replace Country="Congo, Rep." if Country=="Congo, Republic of"
replace Country="Egypt, Arab Rep." if Country== "Egypt"
replace Country="Gambia, The" if Country=="Gambia"
replace Country="Lao PDR" if Country=="Lao"
replace Country="Macao SAR, China" if Country=="Macau"
replace Country="Slovak Republic" if Country=="Slovak Rep."
replace Country="Korea, Rep." if Country=="South Korea"
replace Country="Venezuela, RB" if Country=="Venezuela"
replace Country="Macedonia, FYR" if Country=="Macedonia"

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
replace Country = "Lao PDR" if Country=="Laos"

save "Tax Treaties (Country Year Level).dta", replace

use "Master Dataset.dta", clear
merge m:1 Country year using "Tax Treaties (Country Year Level).dta"
drop _merge
drop if _merge==2
label var numberoftreaties "[Tax Treaty] Number of tax treaties for this country for this year"

//This routine calculates cumulative country-level summaries of all treaties that have
//happened so far for each year. This means the source index and WHT rates for each
//country in each year are the weighted average (weighted by number of treaties) of all
//source indices and WHT rates the country has seen up to each given year. Simply
//taking an average of all source indices and WHT rates for each country had the
//problem of giving each country values years past that were averages of rates
//from teaties in the future.
cap gen weighted_mean_source = Sourceindex_year_mean * numberoftreaties
cap gen weighted_mean_WHT = WHTrates_year_mean * numberoftreaties
local y = 1990
cap gen yearcounted = 0
while `y'<=2016 {
	replace yearcounted = 1 if year==`y'
	cap drop running_mean_source running_mean_WHT running_min_source running_min_WHT treatiessofar
	bysort Country yearcounted: egen running_mean_source = sum(weighted_mean_source)
	bysort Country yearcounted: egen treatiessofar = sum(numberoftreaties)
	bysort Country yearcounted: egen running_mean_WHT = sum(weighted_mean_WHT)
	bysort Country yearcounted: egen running_min_source = min(Sourceindex_year_min)
	bysort Country yearcounted: egen running_min_WHT = min(WHTrates_year_min)
	replace WHTrates_country_min = running_min_WHT if year==`y'
	replace WHTrates_country_mean = running_mean_WHT/treatiessofar if year==`y'
	replace Sourceindex_country_min = running_min_source if year==`y'
	replace Sourceindex_country_mean = running_mean_source/treatiessofar if year==`y'		
	local y = `y' + 1
}
cap drop running_mean_source running_mean_WHT running_min_source running_min_WHT ///
	yearcounted treatiessofar weighted_mean_source weighted_mean_WHT
	
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
replace Country="Congo, Rep." if Country=="Congo, Rep."
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

