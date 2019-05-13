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


//The following routine takes data from a survey year and applies it to years in which
//no survey was conducted, since findings from enterprise surveys are likely still
//valid in the few years following a survey, and otherwise we would have a giant
//dataset filled with missing values.
gen surveyyear=.
replace surveyyear=1 if managementtime<. | firmsvisited<. | numbervisits<. | operatinglicensedays<. ///
	| constructionpermitdays<. | importlicensedays<. | taxrateconstraint<. | taxadminconstraint<. ///
	| licenseconstraint<. | percentcompeting<. | percentregistered<. | yearsinformal<. ///
	| informalconstraint<.

local yearcrawl = 2006
gen yearcount = 0
gen keepyear = 0
while `yearcrawl'<=2016 {
	replace yearcount=1 if year==`yearcrawl'
	cap drop howmanysurveys
	bysort Country yearcount: egen howmanysurveys=count(surveyyear)
	replace keepyear = howmanysurveys if year==`yearcrawl'
	local yearcrawl = `yearcrawl' + 1
}
sort Country year
drop yearcount howmanysurveys

bysort Country keepyear: egen temp1 = mean(managementtime)
bysort Country keepyear: egen temp2 = mean(firmsvisited)
bysort Country keepyear: egen temp3 = mean(numbervisits)
bysort Country keepyear: egen temp4 = mean(operatinglicensedays)
bysort Country keepyear: egen temp5 = mean(constructionpermitdays)
bysort Country keepyear: egen temp6 = mean(importlicensedays)
bysort Country keepyear: egen temp7 = mean(taxrateconstraint)
bysort Country keepyear: egen temp8 = mean(taxadminconstraint)
bysort Country keepyear: egen temp9 = mean(licenseconstraint)
bysort Country keepyear: egen temp10 = mean(percentcompeting)
bysort Country keepyear: egen temp11 = mean(percentregistered)
bysort Country keepyear: egen temp12 = mean(yearsinformal)
bysort Country keepyear: egen temp13 = mean(informalconstraint)

replace managementtime=temp1
replace firmsvisited=temp2
replace numbervisits=temp3
replace operatinglicensedays=temp4
replace constructionpermitdays=temp5
replace importlicensedays=temp6
replace taxrateconstraint=temp7
replace taxadminconstraint=temp8
replace licenseconstraint=temp9
replace percentcompeting=temp10
replace percentregistered=temp11
replace yearsinformal=temp12
replace informalconstraint=temp13
drop temp1 temp2 temp3 temp4 temp5 temp6 temp7 temp8 temp9 temp10 temp11 temp12 temp13 keepyear surveyyear

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

/*Expanding Afrobarometer to subsequent years*/
tsset cntry year
foreach v in round refuse_pay_tax pp_must_pay_tax must_vs_no_need_tax trust_tax_dept corrupt_tax_offic hightax_vs_lowtax often_avoid_tax corrupt_tax_offic_fac1 corrupt_tax_offic_fac2 corrupt_tax_offic_fac3 corrupt_tax_offic_fac4 hightax_vs_lowtax_fac1 hightax_vs_lowtax_fac2 hightax_vs_lowtax_fac3 hightax_vs_lowtax_fac4 hightax_vs_lowtax_fac5 must_vs_no_need_tax_fac1 must_vs_no_need_tax_fac2 must_vs_no_need_tax_fac3 must_vs_no_need_tax_fac4 must_vs_no_need_tax_fac5 often_avoid_tax_fac1 often_avoid_tax_fac2 often_avoid_tax_fac3 often_avoid_tax_fac4 pp_must_pay_tax_fac1 pp_must_pay_tax_fac2 pp_must_pay_tax_fac3 pp_must_pay_tax_fac4 pp_must_pay_tax_fac5 refuse_pay_tax_fac1 refuse_pay_tax_fac2 refuse_pay_tax_fac3 refuse_pay_tax_fac4 refuse_pay_tax_fac5 trust_tax_dept_fac1 trust_tax_dept_fac2 trust_tax_dept_fac3 trust_tax_dept_fac4 combinwt2015 why_avoid_tax pay_gensales_tax pay_property_tax pay_selfemp_tax why_avoid_tax_fac1 why_avoid_tax_fac10 why_avoid_tax_fac11 why_avoid_tax_fac12 why_avoid_tax_fac13 why_avoid_tax_fac14 why_avoid_tax_fac2 why_avoid_tax_fac3 why_avoid_tax_fac4 why_avoid_tax_fac5 why_avoid_tax_fac7 why_avoid_tax_fac6 why_avoid_tax_fac8 why_avoid_tax_fac9 acrosswt2009 combinwt2009 acrosswt2006 combinwt2006 acrosswt2003 combinwt2003 { 

bysort cntry: replace `v'=l.`v' if l.`v'!=. & `v'==.

} 
sort Country year

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

/*Expanding PEFA to subsequent years*/
foreach v in PI_1_0 PI_2_0 PI_2_1 PI_2_2 PI_3_0 PI_4_0 PI_4_1 PI_4_2 PI_5_0 PI_6_0 PI_7_0 PI_7_1 PI_7_2 PI_8_0 PI_8_1 PI_8_2 PI_8_3 PI_9_0 PI_9_1 PI_9_2 PI_10_0 PI_11_0 PI_11_1 PI_11_2 PI_11_3 PI_12_0 PI_12_1 PI_12_2 PI_12_3 PI_12_4 PI_13_0 PI_13_1 PI_13_2 PI_13_3 PI_14_0 PI_14_1 PI_14_2 PI_14_3 PI_15_0 PI_15_1 PI_15_2 PI_15_3 PI_16_0 PI_16_1 PI_16_2 PI_16_3 PI_17_0 PI_17_1 PI_17_2 PI_17_3 PI_18_0 PI_18_1 PI_18_2 PI_18_3 PI_18_4 PI_19_0 PI_19_1 PI_19_2 PI_19_3 PI_19_4 PI_20_0 PI_20_1 PI_20_2 PI_20_3 PI_21_0 PI_21_1 PI_21_2 PI_21_3 PI_22_0 PI_22_1 PI_22_2 PI_23_0 PI_24_0 PI_24_1 PI_24_2 PI_24_3 PI_25_0 PI_25_1 PI_25_2 PI_25_3 PI_26_0 PI_26_1 PI_26_2 PI_26_3 PI_27_0 PI_27_1 PI_27_2 PI_27_3 PI_27_4 PI_28_0 PI_28_1 PI_28_2 PI_28_3 D1_0 D1_1 D1_2 D2_0 D2_1 D2_2 D3_0 { 

bysort cntry: replace `v'=l.`v' if l.`v'!=. & `v'==.

} 

sort Country year

save "Master Dataset.dta", replace

/*GSMA Dataset*/
///Please note that GSMA data used reigonal averages, not country-level data
gen gsmaReg=""
replace gsmaReg="Americas" if Reg==3
replace gsmaReg="Americas" if Reg==5
replace gsmaReg="Europe" if Reg==2
foreach v in Armenia Azerbaijan Cyprus Georgia Kazakhstan Tajikistan Turkey ///
 Turkmenistan Uzbekistan "Kyrgyz Republic" {
replace gsmaReg="Asia" if Country=="`v'"
}
replace gsmaReg="Asia" if Reg==1
foreach v in Australia Fiji Kiribati Palau Samoa Tonga Tuvalu Vanuatu ///
 "Marshall Islands" "Micronesia, Fed. Sts." "New Zealand" "Papua New Guinea" ///
 "Solomon Islands" {
replace gsmaReg="Oceania" if Country=="`v'"
}
replace gsmaReg="Asia" if Reg==6
replace gsmaReg="Asia" if Reg==4
foreach v in Algeria Djibouti "Egypt, Arab Rep." Libya Morocco Tunisia {
replace gsmaReg="Africa" if Country=="`v'"
}
replace gsmaReg="Africa" if Reg==7

merge m:m gsmaReg year using "GSMA World Dataset.dta"
drop if year>=2017

sort Country year

save "Master Dataset - full GSMA.dta", replace

drop netadds* unqsubs* *pct mktpen* capex rev_total rev_recurring rev_nonrecurring ///
 _merge popcoverage*

save "Master Dataset.dta", replace
