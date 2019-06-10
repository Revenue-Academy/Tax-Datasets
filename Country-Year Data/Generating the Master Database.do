clear all
set more off

//cd "D:\WB Tax Consultancy"

//This dofile assembles and adapts the datasets created by Eric Lacey and Joseph Massad
//such that they fit into the dataset already created by Sebastian James, which
//contains UNU-WIDER data, WDI data, and other data already. We start by labeling
//Sebastian's data.

//Table of Contents
//ICTD....................27
//WDI.....................58
//WB Enterprise Surveys...138
//CPIA....................271
//Tax Incentives..........372
//Doing Business..........444
//Afrobarometer...........600
//Tax Treaties............919
//PEFA....................1020
//Polity IV Dataset.......1118
//Digital Adoption Index..1177
//GSMA (SSA only).........1204
//FCVs....................2824

/**********************************/
/*****ICTD & GTT Calculations******/
/**********************************/

//add source data to Sebastian's work
import excel "Gov Rev Dataset.xlsx", sheet("work") firstrow cellrange(A1:H7251) clear

rename Source gov_data_source
rename ISO Country_Code
rename Year year
drop Identifier Country Reg Inc
destring year, replace

save "ICTD metadata.dta", replace

use "Augmented Tax Dataset after Sebastian's dofiles.dta", clear
merge m:1 Country_Code year using "ICTD metadata.dta"
drop if _merge==2
drop _merge

foreach v of varlist _all{
	local u: variable label `v'
	local x = "[ICTD & GTT Data] " + "`u'"
	label var `v' "`x'"
}

label var year "year"
label var Country "country"

save "Master Dataset.dta", replace

/***********************/
/**********WDI**********/
/***********************/

//manufacturing

import excel using "Manufacturing Value Added.xlsx", firstrow cellrange(A1:E12804) clear

rename Manufactu manu_share
rename CountryCode Country_Code
rename Time year
label var manu_share "[WDI] Manufacturing, value added (% of GDP)"

save "Manufacturing VA.dta", replace

use "Master Dataset.dta", clear
merge m:1 Country_Code year using "Manufacturing VA.dta"
drop if _merge==2
drop _merge TimeCode

save "Master Dataset.dta", replace

//informality

//data are sparse, so we assume the latest available figures are still valid
//and apply them to later years
import excel "WDI Informality.xlsx", firstrow cellrange(A1:E12370) clear

rename Informal informal
rename CountryCode Country_Code
rename Time year
label var informal "[WDI] Informal employment (% of total non-ag emp.) (miss. data given latest vals)"

gen hasdata=.
replace hasdata=1 if informal<.
format informal %9.2f

local yearcrawl = 1990
gen currentdata=.
gen useornot=.
while `yearcrawl'<=2016 {
	replace currentdata=informal if year==`yearcrawl' & hasdata==1
	replace currentdata=. if year!=`yearcrawl'
	cap drop currentall
	bysort CountryName: egen currentall=max(currentdata)
	replace useornot=currentall if currentall<.
	replace informal=useornot if year==`yearcrawl'
	local yearcrawl = `yearcrawl' + 1
}
sort CountryName year
drop currentdata useornot TimeCode hasdata currentall

save "WDI Informality.dta", replace

use "Master Dataset.dta", clear
merge m:1 Country_Code year using "WDI Informality.dta"
drop if _merge==2
drop _merge

save "Master Dataset.dta", replace

//agriculture value added

import excel using "WDI Agriculture VA.xlsx", firstrow cellrange(A1:E12804) clear

rename Agriculture agri_share
rename CountryCode Country_Code
rename Time year
drop TimeCode CountryName
label var agri_share "[WDI] Agriculture, value added (% of GDP)"

save "Agriculture VA.dta", replace

use "Master Dataset.dta", clear
merge m:1 Country_Code year using "Agriculture VA.dta"
drop if _merge==2
drop _merge

save "Master Dataset.dta", replace

/*****************************/
/*****Enterprise Surveys******/
/*****************************/

//Informality

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

save "WBES informality.dta", replace

//Tax

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

save "WBES tax.dta", replace

//Merging

merge 1:1 _n using "WBES informality.dta"
drop _merge

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

use "Master Dataset.dta", clear
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

import excel "CPIAEXCEL.xlsx", sheet("Data") firstrow case(lower) clear

/*Clean excel sheet*/
rename countrycode country_code
rename countryname country
rename e yr2005
rename f yr2006
rename g yr2007
rename h yr2008
rename i yr2009
rename j yr2010
rename k yr2011
rename l yr2012
rename m yr2013
rename n yr2014
rename o yr2015
rename p yr2016
rename q yr2017

/*Reshape data from wide to long*/
reshape long yr, i(country indicatorname) j(year)
rename yr score

/*Separate out each indicators' score*/
gen bhrrating=score if indicatorname=="CPIA building human resources rating (1=low to 6=high)"
gen brerating=score if indicatorname=="CPIA business regulatory environment rating (1=low to 6=high)"
gen dprating=score if indicatorname=="CPIA debt policy rating (1=low to 6=high)"
gen emcaverage=score if indicatorname=="CPIA economic management cluster average (1=low to 6=high)"
gen ermrating=score if indicatorname=="CPIA efficiency of revenue mobilization rating (1=low to 6=high)"
gen eqprurating=score if indicatorname=="CPIA equity of public resource use rating (1=low to 6=high)"
gen finsecrating=score if indicatorname=="CPIA financial sector rating (1=low to 6=high)"
gen fispolrating=score if indicatorname=="CPIA fiscal policy rating (1=low to 6=high)"
gen geneqrating=score if indicatorname=="CPIA gender equality rating (1=low to 6=high)"
gen macromgmtrating=score if indicatorname=="CPIA macroeconomic management rating (1=low to 6=high)"
gen polsieqcluster=score if indicatorname=="CPIA policies for social inclusion/equity cluster average (1=low to 6=high)"
gen polinstenvsusrating=score if indicatorname=="CPIA policy and institutions for environmental sustainability rating (1=low to 6=high)"
gen prrbgovrating=score if indicatorname=="CPIA property rights and rule-based governance rating (1=low to 6=high)"
gen pubsecmgmtinstclusteravg=score if indicatorname=="CPIA public sector management and institutions cluster average (1=low to 6=high)"
gen qualbfmrating=score if indicatorname=="CPIA quality of budgetary and financial management rating (1=low to 6=high)"
gen qualpubadminrating=score if indicatorname=="CPIA quality of public administration rating (1=low to 6=high)"
gen sprating=score if indicatorname=="CPIA social protection rating (1=low to 6=high)"
gen strpolclusteravg=score if indicatorname=="CPIA structural policies cluster average (1=low to 6=high)"
gen traderating=score if indicatorname=="CPIA trade rating (1=low to 6=high)"
gen transacctcorrpsrating=score if indicatorname=="CPIA transparency, accountability, and corruption in the public sector rating (1=low to 6=high)"
gen idaresallocindex=score if indicatorname=="IDA resource allocation index (1=low to 6=high)"
drop score

collapse (firstnm) bhrrating brerating dprating emcaverage ermrating eqprurating finsecrating fispolrating geneqrating macromgmtrating polsieqcluster polinstenvsusrating prrbgovrating pubsecmgmtinstclusteravg qualbfmrating qualpubadminrating sprating strpolclusteravg traderating transacctcorrpsrating idaresallocindex, by (country year country_code)

/*label variables*/
label var bhrrating "[CPIA] Building human resources rating (1=low to 6=high)"
label var brerating "[CPIA] Business regulatory environment rating (1=low to 6=high)"
label var dprating "[CPIA] Debt policy rating (1=low to 6=high)"
label var emcaverage "[CPIA] Economic management cluster average (1=low to 6=high)"
label var ermrating "[CPIA] Efficiency of revenue mobilization rating (1=low to 6=high)"
label var eqprurating "[CPIA] Equity of public resource use rating (1=low to 6=high)"
label var finsecrating "[CPIA] Financial sector rating (1=low to 6=high)"
label var fispolrating "[CPIA] Fiscal policy rating (1=low to 6=high)"
label var geneqrating "[CPIA] Gender equality rating (1=low to 6=high)"
label var macromgmtrating "[CPIA] Macroeconomic management rating (1=low to 6=high)"
label var polsieqcluster "[CPIA] Policies for social inclusion/equity cluster average (1=low to 6=high)"
label var polinstenvsusrating "[CPIA] Policy and institutions for environmental sustainability rating (1=low to 6=high)"
label var prrbgovrating "[CPIA] Property rights and rule-based governance rating (1=low to 6=high)"
label var pubsecmgmtinstclusteravg "[CPIA] Public sector management and institutions cluster average (1=low to 6=high)"
label var qualbfmrating "[CPIA] Quality of budgetary and financial management rating (1=low to 6=high)"
label var qualpubadminrating "[CPIA] Quality of public administration rating (1=low to 6=high)"
label var sprating "[CPIA] Social protection rating (1=low to 6=high)"
label var strpolclusteravg "[CPIA] Structural policies cluster average (1=low to 6=high)"
label var traderating "[CPIA] Trade rating (1=low to 6=high)"
label var transacctcorrpsrating "[CPIA] Transparency, accountability, and corruption in the public sector rating (1=low to 6=high)"
label var idaresallocindex "[CPIA] IDA resource allocation index (1=low to 6=high)"

rename country_code Country_Code
save "CPIA Indicators.dta", replace

use "Master Dataset.dta", clear
merge m:1 Country_Code year using "CPIA Indicators.dta"
drop if _merge==2
drop _merge

/*Sort and save database*/
sort Country_Code year

/*Expand CPIA data to subsequent years*/
tsset cntry year

foreach var in bhrrating brerating dprating emcaverage ermrating eqprurating ///
 finsecrating fispolrating geneqrating macromgmtrating polsieqcluster ///
 polinstenvsusrating prrbgovrating pubsecmgmtinstclusteravg qualbfmrating ///
 qualpubadminrating sprating strpolclusteravg traderating transacctcorrpsrating {
 
	replace `var'=l.`var' if `var'==.
 
 }

save "Master Dataset.dta", replace

/****************************************/
/*****Tax Incentives & Transparency******/
/****************************************/

//this dataset is at the sector-year level and will have to be summarized
//to be merged with the country-year level master dataset.
//a more granular version of this dataset can be found in the "not country-year"
//folder on Github.

//this dataset comes from 
//http://www.worldbank.org/en/topic/competitiveness/publication/global-investment-competitiveness-report
//and came in a .dta format
use "2_incentives_database.dta", clear

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

/*Import excel sheet*/
import excel "Historical-data---complete-data-with-scores.xlsx", sheet("All Data") ///
 firstrow case(lower) clear

/*Clean excel sheet*/
drop in 1
rename a country_code
rename b country
replace c="1" if c=="East Asia & Pacific"
replace c="2" if c=="Europe & Central Asia"
replace c="3" if c=="Latin America & Caribbean"
replace c="4" if c=="Middle East & North Africa"
replace c="5" if c=="South Asia"
replace c="6" if c=="Sub-Saharan Africa"
replace c="7" if c=="High income: OECD"
label define regions 1 "East Asia & Pacific" 2 "Europe & Central Asia" ///
 3 "Latin America & Caribbean" 4 "Middle East & North Africa" 5 "South Asia" ///
 6 "Sub-Saharan Africa" 7 "High income: OECD"
destring c, replace
label values c regions
rename c region
replace d="1" if d=="Low income"
replace d="2" if d=="Lower middle income"
replace d="3" if d=="Upper middle income"
replace d="4" if d=="High income"
label define income_groups 1 "Low income" 2 "Lower middle income" ///
 3 "Upper middle income" 4 "High income"
destring d, replace
label values d income_groups
rename d income_group
destring e, replace
rename e year

/*Only keep 'Paying Taxes' variables*/
keep payingtaxes country_code country region income_group year dq dr ds dt du ///
 dv dw dx dy dz ea eb ec ed ee ef eg eh ei ej

/*Clean 'Paying Taxes' variables*/
destring payingtaxes, replace
label var payingtaxes "Rank - Paying Taxes DB 2019"
rename payingtaxes ranktaxes19
destring dq, replace
label var dq "Score - Paying Taxes (DB 17-19 methodology)"
rename dq scoretaxes1719
destring dr, replace
label var dr "Score - Paying Taxes (DB 06-16 methodology)"
rename dr scoretaxes0616
replace ds = "-9" if ds == "No Practice"
destring ds, replace
label var ds "Payments (number per year)"
rename ds npayments
replace dt = "-9" if dt == "No Practice"
destring dt, replace
label var dt "Time (hours per year)"
rename dt timepayments
replace du = "-9" if du== "No Practice"
destring du, replace
label var du "Total tax and contribution rate (% of profit)"
rename du ttr
replace dv = "-9" if dv== "No Practice"
destring dv, replace
label var dv "Profit tax (% of profit)"
rename dv profittax
replace dw = "-9" if dw== "No Practice"
destring dw, replace
label var dw "Labor tax and contributions (% of profit)"
rename dw labortax
replace dx = "-9" if dx== "No Practice"
destring dx, replace
label var dx "Other taxes (% of profit)"
rename dx othertax
replace dy = "-9" if dy== "No Practice"
replace dy = "-8" if dy== "No VAT"
replace dy = "-7" if dy== "No VAT refund per case study scenario"
destring dy, replace
label var dy "Time to comply with VAT refund (hours) (DB 17-19 methodology)"
rename dy timevat
replace dz = "-9" if dz== "No Practice"
replace dz = "-8" if dz== "No VAT"
replace dz = "-7" if dz== "No VAT refund per case study scenario"
destring dz, replace
label var dz "Time to obtain VAT refund (weeks) (DB 17-19 methodology)"
rename dz timevatrefund
replace ea = "-9" if ea== "No Practice"
replace ea = "-6" if ea== "No corporate income tax"
destring ea, replace
label var ea "Time to comply with a corporate income tax correction (hours) (DB 17-19 methodology)"
rename ea corpcompliancetime
replace eb = "-9" if eb== "No Practice"
replace eb = "-6" if eb== "No corporate income tax"
destring eb, replace
label var eb "Time to complete a corporate income tax correction (weeks) (DB 17-19 methodology)"
rename eb corpcompletiontime
destring ec, replace
label var ec "Score - Postfiling index (0-100) (DB 17-19 methodology)"
rename ec scorepostfiling
destring ed, replace
label var ed "Score - Payments (number per year)"
rename ed scorepayments
destring ee, replace
label var ee "Score - Time (hours per year)"
rename ee scoretime
destring ef, replace
label var ef "Score - Total tax and contribution rate (% of profit)"
rename ef scorettr
replace eg = "-8" if eg== "No VAT"
destring eg, replace
label var eg "Score - Time to comply with VAT refund (hours) (DB 17-19 methodology)"
rename eg scoretimevatrefundcomply
replace eh = "-8" if eh== "No VAT"
destring eh, replace
label var eh "Score - Time to obtain VAT refund (weeks) (DB 17-19 methodology)"
rename eh scoretimevatrefundobtain
replace ei="-6" if ei== "No corporate income tax"
destring ei, replace
label var ei "Score - Time to comply with a corporate income tax correction (hours) (DB 17-19 methodology)"
rename ei scorecorpcompliancetime
replace ej="-6" if ej== "No corporate income tax"
destring ej, replace
label var ej "Score - Time to complete a corporate income tax correction (weeks) (DB 17-19 methodology)"
rename ej scorecorpcompletiontime

/*One country, France has a value of -0.2 for profittax, however the rest are 
various kinds of missing values*/
foreach var of varlist ranktaxes19-scorecorpcompletiontime {

	replace `var'=. if `var'<-1

}

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

/*Import and convert Afrobarometer's .sav files and make lower case*/
*ssc install usespss
/*Round 2*/
/*Convert Afrobarometer data from .sav to .dta
usespss "merged_r2_data.sav"
save "merged_r2_data.dta", replace
keep country q42d withinwt
save "Afrobaro_r2_data.dta", replace
*/
use "Afrobaro_r2_data.dta", clear
qui label list q42a
replace q42d=. if q42d==-1 | q42d==9 | q42d==98
rename q42d pp_must_pay_tax
tab pp_must_pay_tax, gen(pp_must_pay_tax_fac)
collapse (mean) pp_must_pay_tax pp_must_pay_tax_fac1 pp_must_pay_tax_fac2 ///
 pp_must_pay_tax_fac3 pp_must_pay_tax_fac4 pp_must_pay_tax_fac5 ///
 [pweight=withinwt], by (country)
gen year=2003
gen round=2

tempfile r2
save `r2', replace

/*Round 3*/
/*Convert Afrobarometere data from .sav to .dta
usespss "merged_r3_data.sav"
save "merged_r3_data.dta", replace
rename *, lower
keep country q56g withinwt
save "Afrobaro_r3_data.dta",replace
*/
use "Afrobaro_r3_data.dta", clear
replace q56g=. if q56g==-1 | q56g==9 | q56g==998
rename q56g corrupt_tax_offic
tab corrupt_tax_offic, gen(corrupt_tax_offic_fac)
collapse (mean) corrupt_tax_offic corrupt_tax_offic_fac1 corrupt_tax_offic_fac2 ///
 corrupt_tax_offic_fac3 corrupt_tax_offic_fac4 [pweight=withinwt], by (country)
gen year=2006
gen round=3

tempfile r3
save `r3', replace

/*Round 4*/
/*Convert Afrobarometer data from .sav to .dta
usespss "merged_r4_data.sav"
save "merged_r4_data.dta", replace
rename *, lower
keep country q44c q50f q64c withinwt
save "Afrobaro_r4_data.dta", replace
*/
use "Afrobaro_r4_data.dta", clear
replace q44c=. if q44c==-1 | q44c==9
replace q50f=. if q50f==-1 | q50f==9
replace q64c=. if q64c==-1 | q64c==8 | q64c==9
rename q44c pp_must_pay_tax
tab pp_must_pay_tax, gen(pp_must_pay_tax_fac)
rename q50f corrupt_tax_offic
tab corrupt_tax_offic, gen(corrupt_tax_offic_fac)
rename q64c pay_property_tax
collapse (mean) pp_must_pay_tax corrupt_tax_offic pay_property_tax ///
 pp_must_pay_tax_fac1 pp_must_pay_tax_fac2 pp_must_pay_tax_fac3 ///
 pp_must_pay_tax_fac4 pp_must_pay_tax_fac5 corrupt_tax_offic_fac1 ///
 corrupt_tax_offic_fac2 corrupt_tax_offic_fac3 corrupt_tax_offic_fac4 ///
 [pweight=withinwt], by (country)
gen year=2009
gen round=4

tempfile r4
save `r4', replace

/*Round 5*/
/*Convert Afrobarometer data from .sav to .dta
usespss "merged-r5-data-34-countries-2011-2013-last-update-july-2015.sav"
save "merged_r5_data.dta", replace
rename *, lower
keep country q26c q48c q50 q51 q56i q59d q60f q73a q73c q73e q77 withinwt
save "Afrobaro_r5_data.dta", replace
*/
use "Afrobaro_r5_data.dta", clear
replace q26c=. if q26c==-1 | q26c==9
replace q48c=. if q48c==-1 | q48c==9
replace q50=.  if q50==-1  | q50==9  | q50==.a
replace q51=.  if q51==-1  | q51==9  | q51==.a
replace q56i=. if q56i==-1 | q56i==9
replace q59d=. if q59d==-1 | q59d==9
replace q60f=. if q60f==-1 | q60f==9
replace q73a=. if q73a==-1 | q73a==9 | q73a==8 | q73a==.a
replace q73c=. if q73c==-1 | q73c==9 | q73c==8 | q73c==.a
replace q73e=. if q73e==-1 | q73e==9 | q73e==7 | q73e==.a
qui label list Q77
replace q77=.  if q77==-1  | q77==9995 | q77==9997 | q77==9998 | q77==9999
rename q26c refuse_pay_tax
tab refuse_pay_tax, gen(refuse_pay_tax_fac)
rename q48c pp_must_pay_tax
tab pp_must_pay_tax, gen(pp_must_pay_tax_fac)
rename q50 must_vs_no_need_tax
tab must_vs_no_need_tax, gen(must_vs_no_need_tax_fac)
rename q51 hightax_vs_lowtax
tab hightax_vs_lowtax, gen(hightax_vs_lowtax_fac)
rename q56i often_avoid_tax
tab often_avoid_tax, gen(often_avoid_tax_fac)
rename q59d trust_tax_dept
tab trust_tax_dept, gen(trust_tax_dept_fac)
rename q60f corrupt_tax_offic
tab corrupt_tax_offic, gen(corrupt_tax_offic_fac)
rename q73a pay_gensales_tax
rename q73c pay_property_tax
rename q73e pay_selfemp_tax
format q77 %9.2g
rename q77 why_avoid_tax
tab why_avoid_tax, gen(why_avoid_tax_fac)
collapse (mean) refuse_pay_tax pp_must_pay_tax must_vs_no_need_tax ///
 hightax_vs_lowtax often_avoid_tax trust_tax_dept corrupt_tax_offic ///
 why_avoid_tax corrupt_tax_offic_fac1 corrupt_tax_offic_fac2 ///
 corrupt_tax_offic_fac3 corrupt_tax_offic_fac4 hightax_vs_lowtax_fac1 ///
 hightax_vs_lowtax_fac2 hightax_vs_lowtax_fac3 hightax_vs_lowtax_fac4 ///
 hightax_vs_lowtax_fac5 must_vs_no_need_tax_fac1 must_vs_no_need_tax_fac2 ///
 must_vs_no_need_tax_fac3 must_vs_no_need_tax_fac4 must_vs_no_need_tax_fac5 ///
 often_avoid_tax_fac1 often_avoid_tax_fac2 often_avoid_tax_fac3 ///
 often_avoid_tax_fac4 pay_gensales_tax pay_property_tax pay_selfemp_tax ///
 pp_must_pay_tax_fac1 pp_must_pay_tax_fac2 pp_must_pay_tax_fac3 ///
 pp_must_pay_tax_fac4 pp_must_pay_tax_fac5 refuse_pay_tax_fac1 ///
 refuse_pay_tax_fac2 refuse_pay_tax_fac3 refuse_pay_tax_fac4 refuse_pay_tax_fac5 ///
 trust_tax_dept_fac1 trust_tax_dept_fac2 trust_tax_dept_fac3 trust_tax_dept_fac4 ///
 why_avoid_tax_fac1 why_avoid_tax_fac10 why_avoid_tax_fac11 why_avoid_tax_fac12 ///
 why_avoid_tax_fac13 why_avoid_tax_fac14 why_avoid_tax_fac2 why_avoid_tax_fac3 ///
 why_avoid_tax_fac4 why_avoid_tax_fac5 why_avoid_tax_fac7 why_avoid_tax_fac6 ///
 why_avoid_tax_fac8 why_avoid_tax_fac9 [pweight=withinwt], by(country)
gen year=2013
gen round=5

tempfile r5
save `r5', replace

/*Round 6*/
/*Convert Afrobarometer data from .sav to .dta
usespss "merged_r6_data_2016_36countries2.sav"
save "merged_r6_data.dta", replace
rename *, lower
keep country q27d q42c q44 q52d q53f q65c q70b withinwt
save "Afrobaro_r6_data.dta", replace
*/
use "Afrobaro_r6_data.dta", replace
/*note for Round 6, q65c specifically asks about increasing taxes to pay for ///
	more health services*/
replace q27d=. if q27d==-1 | q27d==9
replace q42c=. if q42c==-1 | q42c==9 | q42c==98
replace q44=. if q44==-1 | q44==9
replace q52d=. if q52d==-1 | q52d==9
replace q53f=. if q53f==-1 | q53f==9
replace q65c=. if q65c==-1 | q65c==9 | q65c==98
/*note for q65c "It depends" was coded as "6", potentially skewing the mean ///
	I have recoded it here as "3" in the "Neither support nor oppose" group*/
replace q65c=3 if q65c==6
replace q70b=. if q70b==-1 | q70b==9 | q70b==7
rename q27d refuse_pay_tax
tab refuse_pay_tax, gen(refuse_pay_tax_fac)
rename q42c pp_must_pay_tax
tab pp_must_pay_tax, gen(pp_must_pay_tax_fac)
rename q44 must_vs_no_need_tax
tab must_vs_no_need_tax, gen(must_vs_no_need_tax_fac)
rename q52d trust_tax_dept
tab trust_tax_dept, gen(trust_tax_dept_fac)
rename q53f corrupt_tax_offic
tab corrupt_tax_offic, gen(corrupt_tax_offic_fac)
rename q65c hightax_vs_lowtax
tab hightax_vs_lowtax, gen(hightax_vs_lowtax_fac)
rename q70b often_avoid_tax
tab often_avoid_tax, gen(often_avoid_tax_fac)
collapse (mean) refuse_pay_tax pp_must_pay_tax must_vs_no_need_tax trust_tax_dept ///
 corrupt_tax_offic hightax_vs_lowtax often_avoid_tax corrupt_tax_offic_fac1 ///
 corrupt_tax_offic_fac2 corrupt_tax_offic_fac3 corrupt_tax_offic_fac4 ///
 hightax_vs_lowtax_fac1 hightax_vs_lowtax_fac2 hightax_vs_lowtax_fac3 ///
 hightax_vs_lowtax_fac4 hightax_vs_lowtax_fac5 must_vs_no_need_tax_fac1 ///
 must_vs_no_need_tax_fac2 must_vs_no_need_tax_fac3 must_vs_no_need_tax_fac4 ///
 must_vs_no_need_tax_fac5 often_avoid_tax_fac1 often_avoid_tax_fac2 ///
 often_avoid_tax_fac3 often_avoid_tax_fac4 pp_must_pay_tax_fac1 ///
 pp_must_pay_tax_fac2 pp_must_pay_tax_fac3 pp_must_pay_tax_fac4 ///
 pp_must_pay_tax_fac5 refuse_pay_tax_fac1 refuse_pay_tax_fac2 refuse_pay_tax_fac3 ///
 refuse_pay_tax_fac4 refuse_pay_tax_fac5 trust_tax_dept_fac1 trust_tax_dept_fac2 ///
 trust_tax_dept_fac3 trust_tax_dept_fac4 [pweight=withinwt], by(country)
gen year=2015
gen round=6

/*Merge in data from other rounds*/
merge m:1 refuse_pay_tax pp_must_pay_tax must_vs_no_need_tax trust_tax_dept corrupt_tax_offic hightax_vs_lowtax often_avoid_tax country using `r5'
drop _merge
merge m:1 corrupt_tax_offic pay_property_tax country pp_must_pay_tax using `r4'
drop _merge
merge m:1 corrupt_tax_offic using `r3'
drop _merge
merge m:1 pp_must_pay_tax using `r2'
drop _merge

*recast double pp_must_pay_tax refuse_pay_tax must_vs_no_need_tax trust_tax_dept corrupt_tax_offic hightax_vs_lowtax often_avoid_tax pay_gensales_tax pay_property_tax pay_selfemp_tax why_avoid_tax
*format %16.6g pp_must_pay_tax refuse_pay_tax must_vs_no_need_tax trust_tax_dept corrupt_tax_offic hightax_vs_lowtax often_avoid_tax pay_gensales_tax pay_property_tax pay_selfemp_tax why_avoid_tax

order year round, before (refuse_pay_tax)
sort country year

/*Adding labels to variables*/

lab var corrupt_tax_offic_fac1 "How corrupt are tax officials?  - - % answering  1 (none) "
lab var corrupt_tax_offic_fac2 "How corrupt are tax officials?  - - % answering  2 (some of them) "
lab var corrupt_tax_offic_fac3 "How corrupt are tax officials?  - - % answering  3 (a lot of them) "
lab var corrupt_tax_offic_fac4 "How corrupt are tax officials?  - - % answering  4 (all of them) "
lab var corrupt_tax_offic      "How corrupt are tax officials? Mean response (1-5) " 

lab var hightax_vs_lowtax_fac1 "Higher taxes with more government services vs lower taxes with fewer services  - - % answering  1 (strongly agree with statement 1) "
lab var hightax_vs_lowtax_fac2 "Higher taxes with more government services vs lower taxes with fewer services  - - % answering  2 (agree with statement 1) "
lab var hightax_vs_lowtax_fac3 "Higher taxes with more government services vs lower taxes with fewer services  - - % answering  3 (agree with statement 2) "
lab var hightax_vs_lowtax_fac4 "Higher taxes with more government services vs lower taxes with fewer services  - - % answering  4 (strongly agree with statement 2) "
lab var hightax_vs_lowtax_fac5 "Higher taxes with more government services vs lower taxes with fewer services  - - % answering  5 (agree with neither statements)"

lab var must_vs_no_need_tax_fac1 "Citizens must pay taxes vs no need to tax the people  - - % answering  1 (strongly agree with statement 1) "
lab var must_vs_no_need_tax_fac2 "Citizens must pay taxes vs no need to tax the people  - - % answering  2 (agree with statement 1) "
lab var must_vs_no_need_tax_fac3 "Citizens must pay taxes vs no need to tax the people  - - % answering  3 (agree with statement 2) "
lab var must_vs_no_need_tax_fac4 "Citizens must pay taxes vs no need to tax the people  - - % answering  4 (strongly agree with statement 2) "
lab var must_vs_no_need_tax_fac5 "Citizens must pay taxes vs no need to tax the people  - - % answering  5 (agree with neither) "

lab var often_avoid_tax_fac1 "How often do people avoid paying taxes?  - - % answering  1 (never) "
lab var often_avoid_tax_fac2 "How often do people avoid paying taxes?  - - % answering  2 (rarely) "
lab var often_avoid_tax_fac3 "How often do people avoid paying taxes?  - - % answering  3 (often) "
lab var often_avoid_tax_fac4 "How often do people avoid paying taxes?  - - % answering  4 (always) "

lab var pp_must_pay_tax_fac1 "People must pay taxes  - - % answering  1 (strongly disagree) "
lab var pp_must_pay_tax_fac2 "People must pay taxes  - - % answering  2 (disagree) "
lab var pp_must_pay_tax_fac3 "People must pay taxes  - - % answering  3 (neutral) "
lab var pp_must_pay_tax_fac4 "People must pay taxes  - - % answering  4 (agree) "
lab var pp_must_pay_tax_fac5 "People must pay taxes  - - % answering  5 (strongly agree) "
lab var pp_must_pay_tax      "People must pay tax (mean response), 1-5 "

lab var refuse_pay_tax_fac1 "Refused to pay tax or fee to government?  - - % answering  1 (no, would never do that) "
lab var refuse_pay_tax_fac2 "Refused to pay tax or fee to government?  - - % answering  2 (No, but would do if had the chance) "
lab var refuse_pay_tax_fac3 "Refused to pay tax or fee to government?  - - % answering  3 (yes, once or twice) "
lab var refuse_pay_tax_fac4 "Refused to pay tax or fee to government?  - - % answering  4 (yes, several times) "
lab var refuse_pay_tax_fac5 "Refused to pay tax or fee to government?  - - % answering  5 (yes, always) "

lab var trust_tax_dept_fac1 "Trust tax department?  - - % answering  1 (not at all) "
lab var trust_tax_dept_fac2 "Trust tax department?  - - % answering  2 (just a little)  "
lab var trust_tax_dept_fac3 "Trust tax department?  - - % answering  3 (somewhat) "
lab var trust_tax_dept_fac4 "Trust tax department?  - - % answering  4 (a lot) "

lab var pay_gensales_tax "Do you have to pay a general sales tax?"
lab var pay_property_tax "Do you have to pay a property tax?"
lab var pay_selfemp_tax  "Do you have to pay a self-employment tax?"

lab var why_avoid_tax_fac1  "Why do people avoid paying taxes? -- % answer = People don't avoid paying "
lab var why_avoid_tax_fac2  "Why do people avoid paying taxes? -- % answer = The tax system is unfair "
lab var why_avoid_tax_fac3  "Why do people avoid paying taxes? -- % answer = The taxes are too high "
lab var why_avoid_tax_fac4  "Why do people avoid paying taxes? -- % answer = People cannot afford to pay "
lab var why_avoid_tax_fac5  "Why do people avoid paying taxes? -- % answer = The poor services they receive from government "
lab var why_avoid_tax_fac6  "Why do people avoid paying taxes? -- % answer = Government does not listen to them "
lab var why_avoid_tax_fac7  "Why do people avoid paying taxes? -- % answer = Government wastes tax money "
lab var why_avoid_tax_fac8  "Why do people avoid paying taxes? -- % answer = Government officials steal tax money "
lab var why_avoid_tax_fac9  "Why do people avoid paying taxes? -- % answer = They know they will not be caught "
lab var why_avoid_tax_fac10 "Why do people avoid paying taxes? -- % answer = Greed / selfishness "
lab var why_avoid_tax_fac11 "Why do people avoid paying taxes? -- % answer = Ignorance, don't know how to pay or don’t understand need to pay "
lab var why_avoid_tax_fac12 "Why do people avoid paying taxes? -- % answer = Negligence "
lab var why_avoid_tax_fac13 "Why do people avoid paying taxes? -- % answer = Government stopped people from paying the tax(s) "
lab var why_avoid_tax_fac14 "Why do people avoid paying taxes? -- % answer = Employers don't deduct or don't give to government "
/*Note: due to the Stata command 'collapse' for an nominal variable, one ///
	should not use the why_avoid_tax as it does not accurately reflect ///
	the average answer*/

/*Saving file*/
save "Afrobaro_merged.dta", replace

foreach v of varlist _all{
	local u: variable label `v'
	local x = "[Afrobaro] " + "`u'"
	label var `v' "`x'"
}
label var year "year"

decode country, gen(Country)
drop country
replace Country="Egypt, Arab Rep." if Country=="Egypt"

save "Afrobaro_merged.dta", replace

use "Master Dataset.dta", clear
merge m:1 Country year using "Afrobaro_merged.dta"
drop if _merge==2
drop _merge

/*Expanding Afrobarometer to subsequent years*/
tsset cntry year
foreach v in round refuse_pay_tax pp_must_pay_tax must_vs_no_need_tax ///
 trust_tax_dept corrupt_tax_offic hightax_vs_lowtax often_avoid_tax ///
 corrupt_tax_offic_fac1 corrupt_tax_offic_fac2 corrupt_tax_offic_fac3 ///
 corrupt_tax_offic_fac4 hightax_vs_lowtax_fac1 hightax_vs_lowtax_fac2 ///
 hightax_vs_lowtax_fac3 hightax_vs_lowtax_fac4 hightax_vs_lowtax_fac5 ///
 must_vs_no_need_tax_fac1 must_vs_no_need_tax_fac2 must_vs_no_need_tax_fac3 ///
 must_vs_no_need_tax_fac4 must_vs_no_need_tax_fac5 often_avoid_tax_fac1 ///
 often_avoid_tax_fac2 often_avoid_tax_fac3 often_avoid_tax_fac4 ///
 pp_must_pay_tax_fac1 pp_must_pay_tax_fac2 pp_must_pay_tax_fac3 ///
 pp_must_pay_tax_fac4 pp_must_pay_tax_fac5 refuse_pay_tax_fac1 ///
 refuse_pay_tax_fac2 refuse_pay_tax_fac3 refuse_pay_tax_fac4 refuse_pay_tax_fac5 ///
 trust_tax_dept_fac1 trust_tax_dept_fac2 trust_tax_dept_fac3 trust_tax_dept_fac4 ///
 why_avoid_tax pay_gensales_tax pay_property_tax pay_selfemp_tax ///
 why_avoid_tax_fac1 why_avoid_tax_fac10 why_avoid_tax_fac11 why_avoid_tax_fac12 ///
 why_avoid_tax_fac13 why_avoid_tax_fac14 why_avoid_tax_fac2 why_avoid_tax_fac3 ///
 why_avoid_tax_fac4 why_avoid_tax_fac5 why_avoid_tax_fac7 why_avoid_tax_fac6 ///
 why_avoid_tax_fac8 why_avoid_tax_fac9 { 

	bysort cntry: replace `v'=l.`v' if l.`v'!=. & `v'==.

} 

sort Country year

save "Master Dataset.dta", replace

/*********************/
/*****Tax Treaty******/
/*********************/

//this dataset is at the treaty-year level and will have to be summarized
//to be merged with the country-year level master dataset.
//a more granular version of this dataset can be found in the "not country-year"
//folder on Github.
import excel "ActionAid_treaties_dataset_feb_2016.xlsx", sheet("Indices") cellrange(A1:S538) firstrow clear

//treaties before 1990 will be treaty as initial conditions in 1990 in order to merge this dataset with the
//master data set (which only goes back to 1990)
replace Signedyear=1990 if Signedyear<1990

by C1 Signedyear, sort: gen treatycounter = _n
bysort C1 Signedyear: egen numberoftreaties=max(treatycounter)

keep C1 C2 C2_BEPS Signedyear Sourceindex WHTrates numberoftreaties
bysort C1 Signedyear: egen Sourceindex_year_min = min(Sourceindex)
bysort C1 Signedyear: egen Sourceindex_year_mean = mean(Sourceindex)
bysort C1 Signedyear: egen WHTrates_year_min = min(WHTrates)
bysort C1 Signedyear: egen WHTrates_year_mean = mean(WHTrates)
bysort C1 Signedyear: egen partner_BEPS_year_share = mean(C2_BEPS)
bysort C1: egen Sourceindex_country_min = min(Sourceindex)
bysort C1: egen Sourceindex_country_mean = mean(Sourceindex)
bysort C1: egen WHTrates_country_min = min(WHTrates)
bysort C1: egen WHTrates_country_mean = mean(WHTrates)
bysort C1: egen partner_BEPS_country_share = mean(C2_BEPS)
drop Sourceindex WHTrates C2_BEPS

collapse numberoftreaties Source* WHT* partner*, by (C1 Signedyear)

label var Sourceindex_year_min "Lowest source index of any treaty for this country in this year"
label var Sourceindex_year_mean "Average source index of any treaty for this country in this year"
label var WHTrates_year_min "Lowest withholding rates of any treaty for this country in this year"
label var WHTrates_year_mean "Average withholding rates of any treaty for this country in this year"
label var partner_BEPS_year_share "Share of treaty partners who were BEPS for this country in this year"

label var Sourceindex_country_min "Lowest source index of any treaty for this country for all years"
label var Sourceindex_country_mean "Average source index of any treaty for this country for all years"
label var WHTrates_country_min "Lowest withholding rates of any treaty for this country for all years"
label var WHTrates_country_mean "Average withholding rates of any treaty for this country for all years"
label var partner_BEPS_country_share "Share of treaty partners who were BEPS for this country for all years"

gen year = Signedyear

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
drop if _merge==2
drop _merge
label var numberoftreaties "[Tax Treaty] Number of tax treaties for this country for this year"

//This routine calculates cumulative country-level summaries of all treaties that have
//happened so far for each year. This means the source index and WHT rates for each
//country in each year are the weighted average (weighted by number of treaties) of all
//source indices and WHT rates the country has seen up to each given year. Simply
//taking an average of all source indices and WHT rates for each country had the
//problem of giving each country values that were averages of both past and future
//rates (which were not yet relevant).

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

clear all
set more off

import excel "PEFA Scores with Numeric values-Dec18-N-ALL-PEFA2011.xlsx", sheet("Numeric Values") cellrange(A2:LV105) clear

*the PEFA database is organized such that variables are rows and countries are columns. sxpose switches them for use in Stata.
sxpose, firstnames clear

*Variable names were incomplete, and a full description of each variable was included as the*
*first cell under each variable. This command borrows descriptions as a label, and*
*subsequently deletes the now irrelevant row.*
foreach var of varlist _var5-_var104 {
	label variable `var' "`=`var'[1]'"
}
drop if _var5=="Aggregate expenditure out-turn compared to original approved budget"

*Turn values coded as string into numeric*
destring _var5-_var104, replace

*This section systematically renames variables to reflect PEFA categories.*
local z = 5
forvalues i = 1/28 {
	qui cap gen temp = 0
	qui replace temp = 2 if `i'==2 | `i'==4 | `i'==7 | `i'==9 | `i'==22
	qui replace temp = 3 if `i'==8 | `i'==11 | `i'==13 | `i'==14 | `i'==15 | `i'==16 | `i'==17 | `i'==20 | `i'==21 | `i'==24 | `i'==25 | `i'==26 | `i'==28
	qui replace temp = 4 if `i'==12 | `i'==18 | `i'==19 | `i'==27
	local y = temp
	qui drop temp
	forvalues x = 0/`y'{
		rename _var`z' PI_`i'_`x'
		local z = `z' + 1
	}
}
rename _var1 Country
rename _var4 Lastupdate
rename _var98 D1_0
rename _var99 D1_1
rename _var100 D1_2
rename _var101 D2_0
rename _var102 D2_1
rename _var103 D2_2
rename _var104 D3_0

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

//stripping the variables down to a few key, tax-related variables
keep Country year PI_13_1 PI_13_2 PI_13_3 PI_14_1 PI_14_2 PI_14_3 PI_15_1 PI_15_2 PI_15_3

save "PEFA 2011.dta", replace

use "Master Dataset.dta", clear
merge m:1 Country year using "PEFA 2011.dta"
drop if _merge==2
drop _merge

/*Expanding PEFA to subsequent years*/
tsset cntry year
foreach v in PI_13_1 PI_13_2 PI_13_3 PI_14_1 PI_14_2 PI_14_3 PI_15_1 PI_15_2 PI_15_3{ 

bysort cntry: replace `v'=l.`v' if l.`v'!=. & `v'==.

} 

sort Country year

save "Master Dataset.dta", replace

/*****************************/
/******Polity IV Dataset******/
/*****************************/

/*Import Excel*/
import excel "Polity Dataset Democracy.xls", sheet("Sheet1") firstrow clear

drop if year<1990
drop scode country

rename democracy score
gen autocracy=(score<=-6 & score!=.)
replace autocracy=. if score==.
gen anocracy =(score>=-5 & score<=5 & score!=.)
replace anocracy=. if score==.
gen democracy=(score>= 6 & score!=.)
replace democracy=. if score==.

gen politylessfree=(score<=0 & score!=.)
replace politylessfree=. if score==.
gen politymorefree=(score> 0 & score!=.)
replace politymorefree=. if score==.
label var autocracy "-6 or less score"
label var anocracy "-5 to 5 score"
label var democracy "6 or higher score"
label var politylessfree "-10 to 0 score"
label var politymorefree "1 to 10 score"

rename score polityscore

replace Country_Code="MKD" if Country_Code=="MAC"

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

replace politylessfree=(polityscore<=0 & polityscore!=.) if Country=="Macao SAR, China"
replace politymorefree=(polityscore> 0 & polityscore!=.) if Country=="Macao SAR, China"

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

/******************************/
/****Digital Adoption Index****/
/******************************/

/*Import Excel*/
import excel "DAIforweb.xlsx", sheet("Sheet1") firstrow case(lower) clear
 
replace country="Cape Verde" if country=="Cabo Verde"

rename country Country

foreach v of varlist daigovernmentsubindex daipeoplesubindex daibusinesssubindex ///
 digitaladoptionindex {
	local u: variable label `v'
	local x = "[DAI 2016] " + "`u'"
	label var `v' "`x'"
}

save "DAI dataset.dta", replace

use "Master Dataset.dta", clear
merge m:1 Country year using "DAI dataset.dta"

drop if _merge==2
drop _merge

save "Master Dataset.dta", replace

/***************************/
/******GSMA (SSA only)******/
/***************************/

/*ANGOLA*/
import excel "GSMA Angola data.xls", sheet("Data") firstrow clear

drop in 1

sxpose, clear force

drop in 1

keep _var1 _var24-_var67

rename (_var1) (year)

drop in 5
drop in 4
drop in 3
drop in 2
drop in 1

destring _all, replace

gen connectionstotaliot = _var24
gen connectionstotal = _var27
gen connectionsprepaid = _var30
gen connectionscontract = _var33
gen connections2g = _var36
gen connections3g = _var39
gen connections4g = _var42
gen connectionsmobbrd = _var45
gen connectionssmrtphone = _var48
gen connectionsbasic = _var49
gen connectionsdataonly = _var50
gen connectionscdma2g = _var51
gen connectionsgsm = _var53
gen connectionscdma2000 = _var56
gen connectionswcdma = _var58
gen connectionslte = _var61
gen connectionsliot = _var64
gen connectionsm2m = _var66

drop _var*

foreach v of varlist _all {

replace `v'=. if `v'==0

}

gen gsmaReg="Africa"
gen Country="Angola"

save "GSMA Angola Dataset.dta", replace

/*BENIN*/
clear all
import excel "GSMA Benin data.xls", sheet("Data") firstrow

drop in 1

sxpose, clear force

keep _var1 _var24-_var100

drop in 1

rename (_var1) (year)

drop in 5
drop in 4
drop in 3
drop in 2
drop in 1

destring _all, replace

gen connectionstotaliot = _var24
gen connectionstotal = _var30
gen connectionsprepaid = _var36
gen connectionscontract = _var42
gen connections2g = _var47
gen connections3g = _var53
gen connections4g = _var56
gen connectionsmobbrd = _var60
gen connectionssmrtphone = _var64
gen connectionsbasic = _var70
gen connectionsdataonly = _var76
gen connectionsgsm = _var80
gen connectionswcdma = _var86
gen connectionslte = _var89
gen connectionsliot = _var93
gen connectionsm2m = _var97

drop _var*

foreach v of varlist _all {

replace `v'=. if `v'==0

}

gen gsmaReg="Africa"
gen Country="Benin"

save "GSMA Benin Dataset.dta", replace

/*BOTSWANA*/
clear all
import excel "GSMA Botswana data.xls", sheet("Data") firstrow

drop in 1

sxpose, clear force

keep _var1 _var24-_var78

drop in 1

rename (_var1) (year)

drop in 5
drop in 4
drop in 3
drop in 2
drop in 1

destring _all, replace

gen connectionstotaliot = _var24
gen connectionstotal = _var28
gen connectionsprepaid = _var32
gen connectionscontract = _var36
gen connections2g = _var40
gen connections3g = _var44
gen connections4g = _var48
gen connectionsmobbrd = _var52
gen connectionssmrtphone = _var56
gen connectionsbasic = _var57
gen connectionsdataonly = _var58
gen connectionsgsm = _var59
gen connectionswcdma = _var63
gen connectionslte = _var67
gen connectionsliot = _var71
gen connectionsm2m = _var75

drop _var*

foreach v of varlist _all {

replace `v'=. if `v'==0

}

gen gsmaReg="Africa"
gen Country="Botswana"

save "GSMA Botswana Dataset.dta", replace

/*BURKINA FASO*/
clear all
import excel "GSMA Burkina Faso data.xls", sheet("Data") firstrow

drop in 1

sxpose, clear force

rename _var1 year

keep year _var24-_var70

drop in 1

gen connectionstotaliot = _var24
gen connectionstotal = _var28
gen connectionsprepaid = _var32
gen connectionscontract = _var36
gen connections2g = _var40
gen connections3g = _var44
gen connections4g = _var48
gen connectionsmobbrd = _var50
gen connectionssmrtphone = _var54
gen connectionsbasic = _var55
gen connectionsdataonly = _var56
gen connectionsgsm = _var57
gen connectionswcdma = _var61
gen connectionslte = _var65
gen connectionsliot = _var67
gen connectionsm2m = _var69

drop _var*

drop in 5
drop in 4
drop in 3
drop in 2
drop in 1

destring _all, replace

foreach v of varlist _all {

replace `v'=. if `v'==0

}

gen gsmaReg="Africa"
gen Country="Burkina Faso"

save "GSMA Burkina Faso Dataset.dta", replace

/*BURUNDI*/
clear all
import excel "GSMA Burundi data.xls", sheet("Data") firstrow

drop in 1

sxpose, clear force

rename _var1 year

keep year _var24-_var89

drop in 1

gen connectionstotaliot = _var24
gen connectionstotal = _var31
gen connectionsprepaid = _var38
gen connectionscontract = _var45
gen connections2g = _var52
gen connections3g = _var59
gen connections4g = _var64
gen connectionsmobbrd = _var67
gen connectionssmrtphone = _var72
gen connectionsbasic = _var73
gen connectionsdataonly = _var74
gen connectionsgsm = _var75
gen connectionswcdma = _var82
gen connectionslte = _var87

drop _var*

drop in 5
drop in 4
drop in 3
drop in 2
drop in 1

destring _all, replace

foreach v of varlist _all {

replace `v'=. if `v'==0

}

gen gsmaReg="Africa"
gen Country="Burundi"

save "GSMA Burundi Dataset.dta", replace

/*Cabo Verde*/
clear all
import excel "GSMA Cabo Verde data.xls", sheet("Data") firstrow

drop in 1

sxpose, clear force

rename _var1 year

keep year _var24-_var53

drop in 1

gen connectionstotaliot = _var24
gen connectionstotal = _var27
gen connectionsprepaid = _var30
gen connectionscontract = _var33
gen connections2g = _var36
gen connections3g = _var39
gen connectionsmobbrd = _var42
gen connectionssmrtphone = _var45
gen connectionsbasic = _var46
gen connectionsdataonly = _var47
gen connectionsgsm = _var48
gen connectionswcdma = _var51

drop _var*

drop in 5
drop in 4
drop in 3
drop in 2
drop in 1

destring _all, replace

foreach v of varlist _all {

replace `v'=. if `v'==0

}

gen gsmaReg="Africa"
gen Country="Cabo Verde"

save "GSMA Cabo Verde Dataset.dta", replace

/*CAMEROON*/
clear all
import excel "GSMA Cameroon data.xls", sheet("Data") firstrow

drop in 1

sxpose, clear force

rename _var1 year

keep year _var24-_var104

drop in 1

gen connectionstotaliot = _var24
gen connectionstotal = _var30
gen connectionsprepaid = _var36
gen connectionscontract = _var42
gen connections2g = _var46
gen connections3g = _var50
gen connections4g = _var55
gen connectionsmobbrd = _var60
gen connectionssmrtphone = _var66
gen connectionsbasic = _var72
gen connectionsdataonly = _var78
gen connectionsgsm = _var84
gen connectionscdma2000 = _var88
gen connectionslte = _var94
gen connectionsliot = _var99
gen connectionsm2m = _var102

drop _var*

drop in 5
drop in 4
drop in 3
drop in 2
drop in 1

destring _all, replace

foreach v of varlist _all {

replace `v'=. if `v'==0

}

gen gsmaReg="Africa"
gen Country="Cameroon"

save "GSMA Cameroon Dataset.dta", replace

/*CENTAL AFRICAN REPUBLIC*/
clear all
import excel "GSMA CAR data.xls", sheet("Data") firstrow

drop in 1

sxpose, clear force

rename _var1 year

keep year _var24-_var78

drop in 1

gen connectionstotaliot = _var24
gen connectionstotal = _var29
gen connectionsprepaid = _var34
gen connectionscontract = _var39
gen connections2g = _var44
gen connections3g = _var49
gen connections4g = _var53
gen connectionsmobbrd = _var55
gen connectionssmrtphone = _var59
gen connectionsbasic = _var60
gen connectionsdataonly = _var61
gen connectionsgsm = _var62
gen connectionswcdma = _var67
gen connectionslte = _var71
gen connectionsm2m = _var78

drop _var*

drop in 5
drop in 4
drop in 3
drop in 2
drop in 1

destring _all, replace

foreach v of varlist _all {

replace `v'=. if `v'==0

}

gen gsmaReg="Africa"
gen Country="Central Africa Republic"

save "GSMA CAR Dataset.dta", replace

/*CHAD*/
clear all
import excel "GSMA Chad data.xls", sheet("Data") firstrow

drop in 1

sxpose, clear force

rename _var1 year

keep year _var24-_var62

drop in 1

gen connectionstotaliot = _var24
gen connectionstotal = _var28
gen connectionsprepaid = _var32
gen connectionscontract = _var36
gen connections2g = _var39
gen connections3g = _var43
gen connections4g = _var46
gen connectionsmobbrd = _var48
gen connectionssmrtphone = _var51
gen connectionsbasic = _var52
gen connectionsdataonly = _var53
gen connectionsgsm = _var54
gen connectionswcdma = _var58
gen connectionslte = _var61

drop _var*

drop in 5
drop in 4
drop in 3
drop in 2
drop in 1

destring _all, replace

foreach v of varlist _all {

replace `v'=. if `v'==0

}

gen gsmaReg="Africa"
gen Country="Chad"

save "GSMA Chad Dataset.dta", replace

/*COMOROS*/
clear all
import excel "GSMA Comoros data.xls", sheet("Data") firstrow

drop in 1

sxpose, clear force

rename _var1 year

keep year _var24-_var54

drop in 1

sxpose, clear force

keep if _var5=="Comoros"

foreach v of varlist _all {

rename `v' `v'a

}

sxpose, clear force

gen year=_n+2003
drop if year<2009
rename (_var1 _var2 _var3 _var4 _var5 _var6 _var7 _var8 _var9 _var10 _var11 ///
 _var12 _var13 _var14) (connectionstotaliot connectionstotal connectionsprepaid ///
 connectionscontract connections2g connections3g connections4g connectionsmobbrd ///
 connectionssmrtphone connectionsbasic connectionsdataonly connectionsgsm ///
 connectionswcdma connectionslte)

destring _all, replace

gen gsmaReg="Africa"
gen Country="Comoros"

save "GSMA Comoros Dataset.dta", replace

/*CONGO, REP.*/
clear all
import excel "GSMA Congo data.xls", sheet("Data") firstrow

drop in 1

keep if H=="Congo"

sxpose, clear force

drop in 1

rename (_var11-_var26) (connectionstotaliot connectionstotal connectionsprepaid ///
 connectionscontract connections2g connections3g connections4g connectionsmobbrd ///
 connectionssmrtphone connectionsbasic connectionsdataonly connectionsgsm ///
 connectionswcdma connectionslte connectionsliot connectionsm2m)

drop _var*
gen year=_n+2003
drop if year<2009

destring _all, replace

gen gsmaReg="Africa"
gen Country="Congo, Rep."

save "GSMA Congo Dataset.dta", replace

/*CONGO, DEM. REP.*/
clear all
import excel "GSMA Congo, DR data.xls", sheet("Data") firstrow

drop in 1

keep if H=="Congo, Democratic Republic"

sxpose, clear force

drop in 1

rename (_var11-_var28) (connectionstotaliot connectionstotal connectionsprepaid ///
 connectionscontract connections2g connections3g connections4g connectionsmobbrd ///
 connectionssmrtphone connectionsbasic connectionsdataonly connectionscdma2g ///
 connectionsgsm connectionscdma2000 connectionswcdma connectionslte connectionsliot ///
 connectionsm2m)
 
drop _var*
gen year=_n+2003
drop if year<2009

destring _all, replace

gen gsmaReg="Africa"
gen Country="Congo, Dem. Rep."

save "GSMA Congo, DR Dataset.dta", replace

/*COTE D'IVOIRE*/
clear all
import excel "GSMA Cote d'Ivoire data.xls", sheet("Data") firstrow

drop in 1

keep if H=="Cote d'Ivoire"

sxpose, clear force

drop in 1

rename (_var11-_var26) (connectionstotaliot connectionstotal connectionsprepaid ///
 connectionscontract connections2g connections3g connections4g connectionsmobbrd ///
 connectionssmrtphone connectionsbasic connectionsdataonly connectionsgsm ///
 connectionswcdma connectionslte connectionsliot connectionsm2m)
 
drop _var*
gen year=_n+2003
drop if year<2009

destring _all, replace

gen gsmaReg="Africa"
gen Country="Cote d'Ivoire"

save "GSMA Cote d'Ivoire Dataset.dta", replace

/*DJIBOUTI*/
clear all
import excel "GSMA Djibouti data.xls", sheet("Data") firstrow

drop in 1

keep if H=="Djibouti"

sxpose, clear force

drop in 1

rename (_var11-_var25) (connectionstotaliot connectionstotal connectionsprepaid ///
 connections2g connections3g connections4g connectionsmobbrd connectionssmrtphone ///
 connectionsbasic connectionsdataonly connectionsgsm connectionswcdma ///
 connectionslte connectionsliot connectionsm2m)
 
drop _var*
gen year=_n+2003
drop if year<2009

destring _all, replace

gen gsmaReg="Africa"
gen Country="Djibouti"

save "GSMA Djibouti Dataset.dta", replace

/*Equatorial Guinea*/
clear all
import excel "GSMA Equatorial Guinea data.xls", sheet("Data") firstrow

drop in 1

keep if H=="Equatorial Guinea"

sxpose, clear force

drop in 1

rename (_var11-_var24) (connectionstotaliot connectionstotal connectionsprepaid ///
 connectionscontract connections2g connections3g connectionsmobbrd connectionssmrtphone ///
 connectionsbasic connectionsdataonly connectionsgsm connectionswcdma connectionsliot ///
 connectionsm2m)
 
drop _var*
gen year=_n+2003
drop if year<2009

destring _all, replace

gen gsmaReg="Africa"
gen Country="Equatorial Guinea"
save "GSMA Equatorial Guinea Dataset.dta", replace

/*ERITREA*/
clear all
import excel "GSMA Eritrea data.xls", sheet("Data") firstrow

drop in 1

keep if H=="Eritrea"

sxpose, clear force

drop in 1

rename (_var11-_var18) (connectionstotaliot connectionstotal connectionsprepaid ///
 connectionscontract connections2g connectionssmrtphone connectionsbasic ///
 connectionsgsm)
 
drop _var*
gen year=_n+2003
drop if year<2009

destring _all, replace

gen gsmaReg="Africa"
gen Country="Eritrea"
save "GSMA Eritrea Dataset.dta", replace

/*ESWATINI*/
clear all
import excel "GSMA Eswatini data.xls", sheet("Data") firstrow

drop in 1

keep if H=="Eswatini"

sxpose, clear force

drop in 1

rename (_var11-_var26) (connectionstotaliot connectionstotal connectionsprepaid ///
 connectionscontract connections2g connections3g connections4g connectionsmobbrd ///
 connectionssmrtphone connectionsbasic connectionsdataonly connectionsgsm ///
 connectionswcdma connectionslte connectionsliot connectionsm2m)
 
drop _var*
gen year=_n+2003
drop if year<2009

destring _all, replace

gen gsmaReg="Africa"
gen Country="Eswatini"
save "GSMA Eswatini Dataset.dta", replace

/*ETHIOPIA*/
clear all
import excel "GSMA Ethiopia data.xls", sheet("Data") firstrow

keep if H=="Ethiopia"

sxpose, clear force

drop in 1

rename (_var11-_var28) (connectionstotaliot connectionstotal connectionsprepaid ///
 connectionscontract connections2g connections3g connections4g connectionsmobbrd ///
 connectionssmrtphone connectionsbasic connectionsdataonly connectionscdma2g ///
 connectionsgsm connectionscdma2000 connectionswcdma connectionslte connectionsliot ///
 connectionsm2m)
 
drop _var*
gen year=_n+2003
drop if year<2009

destring _all, replace

gen gsmaReg="Africa"
gen Country="Ethiopia"
save "GSMA Ethiopia Dataset.dta", replace

/*GABON*/
clear all
import excel "GSMA Gabon data.xls", sheet("Data") firstrow

keep if H=="Gabon"

sxpose, clear force

drop in 1

rename (_var11-_var26) (connectionstotaliot connectionstotal connectionsprepaid ///
 connectionscontract connections2g connections3g connections4g connectionsmobbrd ///
 connectionssmrtphone connectionsbasic connectionsdataonly connectionsgsm ///
 connectionswcdma connectionslte connectionsliot connectionsm2m)
 
drop _var*
gen year=_n+2003
drop if year<2009

destring _all, replace

gen gsmaReg="Africa"
gen Country="Gabon"
save "GSMA Gabon Dataset.dta", replace

/*GAMBIA*/
clear all
import excel "GSMA Gambia data.xls", sheet("Data") firstrow

keep if H=="Gambia"

sxpose, clear force

drop in 1

rename (_var11-_var26) (connectionstotaliot connectionstotal connectionsprepaid ///
 connectionscontract connections2g connections3g connections4g connectionsmobbrd ///
 connectionssmrtphone connectionsbasic connectionsdataonly connectionsgsm ///
 connectionswcdma connectionslte connectionsliot connectionsm2m)
 
drop _var*
gen year=_n+2003
drop if year<2009

destring _all, replace

gen gsmaReg="Africa"
gen Country="Gambia, The"
save "GSMA Gambia Dataset.dta", replace

/*GHANA*/
clear all
import excel "GSMA Ghana data.xls", sheet("Data") firstrow

keep if H=="Ghana"

sxpose, clear force

drop in 1

rename (_var11-_var28) (connectionstotaliot connectionstotal connectionsprepaid ///
 connectionscontract connections2g connections3g connections4g connectionsmobbrd ///
 connectionssmrtphone connectionsbasic connectionsdataonly connectionscdma2g ///
 connectionsgsm connectionscdma2000 connectionswcdma connectionslte connectionsliot ///
 connectionsm2m)
 
drop _var*
gen year=_n+2003
drop if year<2009

destring _all, replace

gen gsmaReg="Africa"
gen Country="Ghana"
save "GSMA Ghana Dataset.dta", replace

/*GUINEA*/
clear all
import excel "GSMA Guinea data.xls", sheet("Data") firstrow

keep if H=="Guinea"

sxpose, clear force

drop in 1

rename (_var11-_var26) (connectionstotaliot connectionstotal connectionsprepaid ///
 connectionscontract connections2g connections3g connections4g connectionsmobbrd ///
 connectionssmrtphone connectionsbasic connectionsdataonly connectionsgsm ///
 connectionswcdma connectionslte connectionsliot connectionsm2m)
 
drop _var*
gen year=_n+2003
drop if year<2009 | year>2019

destring _all, replace

gen gsmaReg="Africa"
gen Country="Guinea"
save "GSMA Guinea Dataset.dta", replace

/*GUINEA-BISSAU*/
clear all
import excel "GSMA Guinea-Bissau data.xls", sheet("Data") firstrow

keep if H=="Guinea-Bissau"

sxpose, clear force

drop in 1

rename (_var11-_var26) (connectionstotaliot connectionstotal connectionsprepaid ///
 connectionscontract connections2g connections3g connections4g connectionsmobbrd ///
 connectionssmrtphone connectionsbasic connectionsdataonly connectionsgsm ///
 connectionswcdma connectionslte connectionsliot connectionsm2m)
 
drop _var*
gen year=_n+2003
drop if year<2009

destring _all, replace

gen gsmaReg="Africa"
gen Country="Guinea-Bissau"
save "GSMA Guinea-Bissau Dataset.dta", replace

/*KENYA*/
clear all
import excel "GSMA Kenya data.xls", sheet("Data") firstrow

keep if H=="Kenya"

sxpose, clear force

drop in 1

rename (_var11-_var26) (connectionstotaliot connectionstotal connectionsprepaid ///
 connectionscontract connections2g connections3g connections4g connectionsmobbrd ///
 connectionssmrtphone connectionsbasic connectionsdataonly connectionsgsm ///
 connectionswcdma connectionslte connectionsliot connectionsm2m)
 
drop _var*
gen year=_n+2003
drop if year<2009

destring _all, replace

gen gsmaReg="Africa"
gen Country="Kenya"
save "GSMA Kenya Dataset.dta", replace

/*LESOTHO*/
clear all
import excel "GSMA Lesotho data.xls", sheet("Data") firstrow

keep if H=="Lesotho"

sxpose, clear force

drop in 1

rename (_var11-_var26) (connectionstotaliot connectionstotal connectionsprepaid ///
 connectionscontract connections2g connections3g connections4g connectionsmobbrd ///
 connectionssmrtphone connectionsbasic connectionsdataonly connectionsgsm ///
 connectionswcdma connectionslte connectionsliot connectionsm2m)
 
drop _var*
gen year=_n+2003
drop if year<2009

destring _all, replace

gen gsmaReg="Africa"
gen Country="Lesotho"
save "GSMA Lesotho Dataset.dta", replace

/*LIBERIA*/
clear all
import excel "GSMA Liberia data.xls", sheet("Data") firstrow

keep if H=="Liberia"

sxpose, clear force

drop in 1

rename (_var11-_var23) (connectionstotaliot connectionstotal connectionsprepaid ///
 connectionscontract connections2g connections3g connections4g connectionsmobbrd ///
 connectionssmrtphone connectionsgsm connectionscdma2000 connectionswcdma ///
 connectionslte)
 
drop _var*
gen year=_n+2003
drop if year<2009

destring _all, replace

gen gsmaReg="Africa"
gen Country="Liberia"
save "GSMA Liberia Dataset.dta", replace

/*MADAGASCAR*/
clear all
import excel "GSMA Madagascar data.xls", sheet("Data") firstrow

keep if H=="Madagascar"

sxpose, clear force

drop in 1

rename (_var11-_var28) (connectionstotaliot connectionstotal connectionsprepaid ///
 connectionscontract connections2g connections3g connections4g connectionsmobbrd ///
 connectionssmrtphone connectionsbasic connectionsdataonly connectionscdma2g ///
 connectionsgsm connectionscdma2000 connectionswcdma connectionslte connectionsliot ///
 connectionsm2m)
 
drop _var*
gen year=_n+2003
drop if year<2009

destring _all, replace

gen gsmaReg="Africa"
gen Country="Madagascar"
save "GSMA Madagascar Dataset.dta", replace

/*MALAWI*/
clear all
import excel "GSMA Malawi data.xls", sheet("Data") firstrow

keep if H=="Malawi"

sxpose, clear force

drop in 1

rename (_var11-_var28) (connectionstotaliot connectionstotal connectionsprepaid ///
 connectionscontract connections2g connections3g connections4g connectionsmobbrd ///
 connectionssmrtphone connectionsbasic connectionsdataonly connectionscdma2g ///
 connectionsgsm connectionscdma2000 connectionswcdma connectionslte connectionsliot ///
 connectionsm2m)
 
drop _var*
gen year=_n+2003
drop if year<2009

destring _all, replace

gen gsmaReg="Africa"
gen Country="Malawi"
save "GSMA Malawi Dataset.dta", replace

/*MALI*/
clear all
import excel "GSMA Mali data.xls", sheet("Data") firstrow

keep if H=="Mali"

sxpose, clear force

drop in 1

rename (_var11-_var26) (connectionstotaliot connectionstotal connectionsprepaid ///
 connectionscontract connections2g connections3g connections4g connectionsmobbrd ///
 connectionssmrtphone connectionsbasic connectionsdataonly connectionsgsm ///
 connectionswcdma connectionslte connectionsliot connectionsm2m)
 
drop _var*
gen year=_n+2003
drop if year<2009

destring _all, replace

gen gsmaReg="Africa"
gen Country="Mali"
save "GSMA Mali Dataset.dta", replace

/*MAURITANIA*/
clear all
import excel "GSMA Mauritania data.xls", sheet("Data") firstrow

keep if H=="Mauritania"

sxpose, clear force

drop in 1

rename (_var11-_var24) (connectionstotaliot connectionstotal connectionsprepaid ///
 connectionscontract connections2g connections3g connectionsmobbrd connectionssmrtphone ///
 connectionsbasic connectionsdataonly connectionscdma2g connectionsgsm ///
 connectionscdma2000 connectionswcdma)

drop _var*
gen year=_n+2003
drop if year<2009

destring _all, replace

gen gsmaReg="Africa"
gen Country="Mauritania"
save "GSMA Mauritania Dataset.dta", replace

/*MAURITIUS*/
clear all
import excel "GSMA Mauritius data.xls", sheet("Data") firstrow

keep if H=="Mauritius"

sxpose, clear force

drop in 1

rename (_var11-_var28) (connectionstotaliot connectionstotal connectionsprepaid ///
 connectionscontract connections2g connections3g connections4g connectionsmobbrd ///
 connectionssmrtphone connectionsbasic connectionsdataonly connectionscdma2g ///
 connectionsgsm connectionscdma2000 connectionswcdma connectionslte connectionsliot ///
 connectionsm2m)
 
drop _var*
gen year=_n+2003
drop if year<2009

destring _all, replace

gen gsmaReg="Africa"
gen Country="Mauritius"
save "GSMA Mauritius Dataset.dta", replace

/*MAYOTTE*/
clear all
import excel "GSMA Mayotte data.xls", sheet("Data") firstrow

keep if H=="Mayotte"

sxpose, clear force

drop in 1

rename (_var11-_var24) (connectionstotaliot connectionstotal connectionsprepaid ///
 connectionscontract connections2g connections3g connections4g connectionsmobbrd ///
 connectionssmrtphone connectionsbasic connectionsdataonly connectionsgsm ///
 connectionswcdma connectionslte)
 
drop _var*
gen year=_n+2003
drop if year<2009

destring _all, replace

gen gsmaReg="Africa"
gen Country="Mayotte"
save "GSMA Mayotte Dataset.dta", replace

/*MOZAMBIQUE*/
clear all
import excel "GSMA Mozambique data.xls", sheet("Data") firstrow

keep if H=="Mozambique"

sxpose, clear force

drop in 1

rename (_var11-_var26) (connectionstotaliot connectionstotal connectionsprepaid ///
 connectionscontract connections2g connections3g connections4g connectionsmobbrd ///
 connectionssmrtphone connectionsbasic connectionsdataonly connectionsgsm ///
 connectionswcdma connectionslte connectionsliot connectionsm2m)

drop _var*
gen year=_n+2003
drop if year<2009

destring _all, replace

gen gsmaReg="Africa"
gen Country="Mozambique"
save "GSMA Mozambique Dataset.dta", replace

/*NAMIBIA*/
clear all
import excel "GSMA Namibia data.xls", sheet("Data") firstrow

keep if H=="Namibia"

sxpose, clear force

drop in 1

rename (_var11-_var28) (connectionstotaliot connectionstotal connectionsprepaid ///
 connectionscontract connections2g connections3g connections4g connectionsmobbrd ///
 connectionssmrtphone connectionsbasic connectionsdataonly connectionscdma2g ///
 connectionsgsm connectionscdma2000 connectionswcdma connectionslte connectionsliot ///
 connectionsm2m)
 
drop _var*
gen year=_n+2003
drop if year<2009

destring _all, replace

gen gsmaReg="Africa"
gen Country="Namibia"
save "GSMA Namibia Dataset.dta", replace

/*NIGER*/
clear all
import excel "GSMA Niger data.xls", sheet("Data") firstrow

keep if H=="Niger"

sxpose, clear force

drop in 1

rename (_var11-_var26) (connectionstotaliot connectionstotal connectionsprepaid ///
 connectionscontract connections2g connections3g connections4g connectionsmobbrd ///
 connectionssmrtphone connectionsbasic connectionsdataonly connectionsgsm ///
 connectionswcdma connectionslte connectionsliot connectionsm2m)
 
drop _var*
gen year=_n+2003
drop if year<2009

destring _all, replace

gen gsmaReg="Africa"
gen Country="Niger"
save "GSMA Niger Dataset.dta", replace

/*NIGERIA*/
clear all
import excel "GSMA Nigeria data.xls", sheet("Data") firstrow

keep if H=="Nigeria"

sxpose, clear force

drop in 1

rename (_var11-_var29) (connectionstotaliot connectionstotal connectionsprepaid ///
 connectionscontract connections2g connections3g connections4g connectionsmobbrd ///
 connectionssmrtphone connectionsbasic connectionsdataonly connectionscdma2g ///
 connectionsgsm connectionscdma2000 connectionswcdma connectionslte connectionsliot ///
 connectionsm2m connectionslpwa)
 
drop _var*
gen year=_n+2003
drop if year<2009

destring _all, replace

gen gsmaReg="Africa"
gen Country="Nigeria"
save "GSMA Nigeria Dataset.dta", replace

/*REUNION*/
clear all
import excel "GSMA Reunion data.xls", sheet("Data") firstrow

keep if H=="Reunion"

sxpose, clear force

drop in 1

rename (_var11-_var26) (connectionstotaliot connectionstotal connectionsprepaid ///
 connectionscontract connections2g connections3g connections4g connectionsmobbrd ///
 connectionssmrtphone connectionsbasic connectionsdataonly connectionsgsm ///
 connectionswcdma connectionslte connectionsliot connectionsm2m)
 
drop _var*
gen year=_n+2003
drop if year<2009

destring _all, replace

gen gsmaReg="Africa"
gen Country="Reunion"
save "GSMA Reunion Dataset.dta", replace

/*RWANDA*/
clear all
import excel "GSMA Rwanda data.xls", sheet("Data") firstrow

keep if H=="Rwanda"

sxpose, clear force

drop in 1

rename (_var11-_var26) (connectionstotaliot connectionstotal connectionsprepaid ///
 connectionscontract connections2g connections3g connections4g connectionsmobbrd ///
 connectionssmrtphone connectionsbasic connectionsdataonly connectionsgsm ///
 connectionswcdma connectionslte connectionsliot connectionsm2m)
 
drop _var*
gen year=_n+2003
drop if year<2009

destring _all, replace

gen gsmaReg="Africa"
gen Country="Rwanda"
save "GSMA Rwanda Dataset.dta", replace

/*SAINT HELENA*/
clear all
import excel "GSMA Saint Helena data.xls", sheet("Data") firstrow

keep if H=="Saint Helena, Ascension and Tristan da Cunha"

sxpose, clear force

drop in 1

rename (_var11-_var22) (connectionstotaliot connectionstotal connectionsprepaid ///
 connectionscontract connections2g connections4g connectionsmobbrd connectionssmrtphone ///
 connectionsbasic connectionsdataonly connectionsgsm connectionslte)
 
drop _var*
gen year=_n+2003
drop if year<2009

destring _all, replace

gen gsmaReg="Africa"
gen Country="Saint Helena"
save "GSMA Saint Helena Dataset.dta", replace

/*SAO TOME AND PRINCIPE*/
clear all
import excel "GSMA Sao Tome and Principe data.xls", sheet("Data") firstrow

keep if H=="Sao Tome and Principe"

sxpose, clear force

drop in 1

rename (_var11-_var22) (connectionstotaliot connectionstotal connectionsprepaid ///
 connectionscontract connections2g connections3g connectionsmobbrd connectionssmrtphone ///
 connectionsbasic connectionsdataonly connectionsgsm connectionswcdma)

drop _var*
gen year=_n+2003
drop if year<2009

destring _all, replace

gen gsmaReg="Africa"
gen Country="Sao Tome and Principe"
save "GSMA Sao Tome and Principe Dataset.dta", replace

/*SENEGAL*/
clear all
import excel "GSMA Senegal data.xls", sheet("Data") firstrow

keep if H=="Senegal"

sxpose, clear force

drop in 1 

rename (_var11-_var28) (connectionstotaliot connectionstotal connectionsprepaid ///
 connectionscontract connections2g connections3g connections4g connectionsmobbrd ///
 connectionssmrtphone connectionsbasic connectionsdataonly connectionscdma2g ///
 connectionsgsm connectionscdma2000 connectionswcdma connectionslte connectionsliot ///
 connectionsm2m)
 
drop _var*
gen year=_n+2003
drop if year<2009

destring _all, replace

gen gsmaReg="Africa"
gen Country="Senegal"
save "GSMA Senegal Dataset.dta", replace

/*SEYCHELLES*/
clear all
import excel "GSMA Seychelles data.xls", sheet("Data") firstrow

keep if H=="Seychelles"

sxpose, clear force

drop in 1

rename (_var11-_var24) (connectionstotaliot connectionstotal connectionsprepaid ///
 connectionscontract connections2g connections3g connections4g connectionsmobbrd ///
 connectionssmrtphone connectionsbasic connectionsdataonly connectionsgsm ///
 connectionswcdma connectionslte)
 
drop _var*
gen year=_n+2003
drop if year<2009

destring _all, replace

gen gsmaReg="Africa"
gen Country="Seychelles"
save "GSMA Seychelles Dataset.dta", replace

/*SIERRA LEONE*/
clear all
import excel "GSMA Sierra Leone data.xls", sheet("Data") firstrow

keep if H=="Sierra Leone"

sxpose, clear force

drop in 1

rename (_var11-_var26) (connectionstotaliot connectionstotal connectionsprepaid ///
 connectionscontract connections2g connections3g connections4g connectionsmobbrd ///
 connectionssmrtphone connectionsbasic connectionsdataonly connectionscdma2g ///
 connectionsgsm connectionscdma2000 connectionswcdma connectionslte)
 
drop _var*
gen year=_n+2003
drop if year<2009

destring _all, replace

gen gsmaReg="Africa"
gen Country="Sierra Leone"
save "GSMA Sierra Leone Dataset.dta", replace

/*SOMALIA*/
clear all
import excel "GSMA Somalia data.xls", sheet("Data") firstrow

keep if H=="Somalia"

sxpose, clear force

drop in 1

rename (_var11-_var26) (connectionstotaliot connectionstotal connectionsprepaid ///
 connectionscontract connections2g connections3g connections4g connectionsmobbrd ///
 connectionssmrtphone connectionsbasic connectionsdataonly connectionsgsm ///
 connectionswcdma connectionslte connectionsliot connectionsm2m)
 
drop _var*
gen year=_n+2003
drop if year<2009

destring _all, replace

gen gsmaReg="Africa"
gen Country="Somalia"
save "GSMA Somalia Dataset.dta", replace

/*SOUTH AFRICA*/
clear all
import excel "GSMA South Africa data.xls", sheet("Data") firstrow

keep if H=="South Africa"

sxpose, clear force

drop in 1

rename (_var11-_var27) (connectionstotaliot connectionstotal connectionsprepaid ///
 connectionscontract connections2g connections3g connections4g connectionsmobbrd ///
 connectionssmrtphone connectionsbasic connectionsdataonly connectionsgsm ///
 connectionswcdma connectionslte connectionsliot connectionsm2m connectionslpwa)
 
drop _var*
gen year=_n+2003
drop if year<2009

destring _all, replace

gen gsmaReg="Africa"
gen Country="South Africa"
save "GSMA South Africa Dataset.dta", replace

/*SOUTH SUDAN*/
clear all
import excel "GSMA South Sudan data.xls", sheet("Data") firstrow

keep if H=="South Sudan"

sxpose, clear force

drop in 1

rename (_var11-_var22) (connectionstotaliot connectionstotal connectionsprepaid ///
 connectionscontract connections2g connections3g connectionsmobbrd connectionssmrtphone ///
 connectionsbasic connectionsdataonly connectionsgsm connectionswcdma)
 
drop _var*
gen year=_n+2003
drop if year<2009

destring _all, replace

gen gsmaReg="Africa"
gen Country="South Sudan"
save "GSMA South Sudan Dataset.dta", replace

/*SUDAN*/
clear all
import excel "GSMA Sudan data.xls", sheet("Data") firstrow

keep if H=="Sudan"

sxpose, clear force

drop in 1

rename (_var11-_var27) (connectionstotaliot connectionstotal connectionsprepaid ///
 connectionscontract connections2g connections3g connections4g connectionsmobbrd ///
 connectionssmrtphone connectionsbasic connectionsdataonly connectionscdma2g ///
 connectionsgsm connectionswcdma connectionslte connectionsliot connectionsm2m)
 
drop _var*
gen year=_n+2003
drop if year<2009

destring _all, replace

gen gsmaReg="Africa"
gen Country="Sudan"
save "GSMA Sudan Dataset.dta", replace

/*TANZANIA*/
clear all
import excel "GSMA Tanzania data.xls", sheet("Data") firstrow

keep if H=="Tanzania"

sxpose, clear force

drop in 1

rename (_var11-_var28) (connectionstotaliot connectionstotal connectionsprepaid ///
 connectionscontract connections2g connections3g connections4g connectionsmobbrd ///
 connectionssmrtphone connectionsbasic connectionsdataonly connectionscdma2g ///
 connectionsgsm connectionscdma2000 connectionswcdma connectionslte connectionsliot ///
 connectionsm2m)
 
drop _var*
gen year=_n+2003
drop if year<2009

destring _all, replace

gen gsmaReg="Africa"
gen Country="Tanzania"
save "GSMA Tanzania Dataset.dta", replace

/*TOGO*/
clear all
import excel "GSMA Togo data.xls", sheet("Data") firstrow

keep if H=="Togo"

sxpose, clear force

drop in 1

rename (_var11-_var26) (connectionstotaliot connectionstotal connectionsprepaid ///
 connectionscontract connections2g connections3g connections4g connectionsmobbrd ///
 connectionssmrtphone connectionsbasic connectionsdataonly connectionsgsm ///
 connectionswcdma connectionslte connectionsliot connectionsm2m)
 
drop _var*
gen year=_n+2003
drop if year<2009

destring _all, replace

gen gsmaReg="Africa"
gen Country="Togo"
save "GSMA Togo Dataset.dta", replace

/*UGANDA*/
clear all
import excel "GSMA Uganda data.xls", sheet("Data") firstrow

keep if H=="Uganda"

sxpose, clear force

drop in 1

rename (_var11-_var28) (connectionstotaliot connectionstotal connectionsprepaid ///
 connectionscontract connections2g connections3g connections4g connectionsmobbrd ///
 connectionssmrtphone connectionsbasic connectionsdataonly connectionscdma2g ///
 connectionsgsm connectionscdma2000 connectionswcdma connectionslte connectionsliot ///
 connectionsm2m)
 
drop _var*
gen year=_n+2003
drop if year<2009

destring _all, replace

gen gsmaReg="Africa"
gen Country="Uganda"
save "GSMA Uganda Dataset.dta", replace

/*ZAMBIA*/
clear all
import excel "GSMA Zambia data.xls", sheet("Data") firstrow

keep if H=="Zambia"

sxpose, clear force

drop in 1

rename (_var11-_var26) (connectionstotaliot connectionstotal connectionsprepaid ///
 connectionscontract connections2g connections3g connections4g connectionsmobbrd ///
 connectionssmrtphone connectionsbasic connectionsdataonly connectionsgsm ///
 connectionswcdma connectionslte connectionsliot connectionsm2m)
 
drop _var*
gen year=_n+2003
drop if year<2009

destring _all, replace

gen gsmaReg="Africa"
gen Country="Zambia"
save "GSMA Zambia Dataset.dta", replace
*/
/*ZIMBABWE*/
clear all
import excel "GSMA Zimbabwe data.xls", sheet("Data") firstrow

keep if H=="Zimbabwe"

sxpose, clear force

drop in 1

rename (_var11-_var26) (connectionstotaliot connectionstotal connectionsprepaid ///
 connectionscontract connections2g connections3g connections4g connectionsmobbrd ///
 connectionssmrtphone connectionsbasic connectionsdataonly connectionsgsm ///
 connectionswcdma connectionslte connectionsliot connectionsm2m)
 
drop _var*
gen year=_n+2003
drop if year<2009

destring _all, replace

gen gsmaReg="Africa"
gen Country="Zimbabwe"
save "GSMA Zimbabwe Dataset.dta", replace

/*APPEND DATASETS TOGETHER*/
foreach u in Angola Benin Botswana "Burkina Faso" Burundi "Cabo Verde" Cameroon ///
 CAR Chad Comoros Congo "Congo, DR" "Cote d'Ivoire" Djibouti "Equatorial Guinea" ///
 Eritrea Eswatini Ethiopia Gabon Gambia Ghana Guinea "Guinea-Bissau" Kenya ///
 Lesotho Liberia Madagascar Malawi Mali Mauritania Mauritius Mayotte Mozambique ///
 Namibia Niger Nigeria Reunion Rwanda "Saint Helena" "Sao Tome and Principe" ///
 Senegal Seychelles "Sierra Leone" Somalia "South Africa" "South Sudan" Sudan ///
 Tanzania Togo Uganda Zambia {

append using "GSMA `u' Dataset.dta" 
 
}

order Country year gsmaReg, first
sort Country year

foreach v of varlist _all{
	local u: variable label `v'
	local x = "[GSMA 2018] " + "`u'"
	label var `v' "`x'"
}

lab variable year ""
lab variable Country ""
lab variable gsmaReg ""

save "GSMA SSA Dataset.dta", replace

use "Master Dataset.dta", clear
merge m:1 Country year using "GSMA SSA Dataset.dta"
drop if _merge==2
drop _merge

save "Master Dataset.dta", replace

/***********************/
/*********FCVs**********/
/***********************/

import excel "Historical FCV.xlsx", firstrow cellrange(A1:C489) clear

replace Country="Bosnia and Herzegovina" if Country=="Bosnia & Herzegovina"
replace Country="Guinea-Bissau" if Country=="Guinea Bissau"
replace Country="Lao PDR" if Country=="Lao, PDR"
replace Country="Micronesia, Fed. Sts." if Country=="Micronesia, FS"
replace Country="Syrian Arab Republic" if Country=="Syria"
replace Country="Yemen, Rep." if Country=="Yemen"

save "FCV.dta", replace

use "Master Dataset.dta", clear
merge m:1 Country year using "FCV.dta"
drop if _merge==2
drop _merge

replace FCV=0 if FCV!=1
label var FCV "[WB Fragile Status] from harmonized list of fragile situations"

save "Master Dataset.dta", replace
