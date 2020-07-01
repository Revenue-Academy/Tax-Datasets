clear all
set more off

//This dofile assembles and adapts 3rd-party datasets such that
//they merge with ICTD data at the country-year level from 1990-2017
//Last update: May 26 2020.

/*Table of Contents (Ctrl-F the entire phrase)
ICTD & GTT Calculations
World Development Indicators
Enterprise Surveys
CPIA
Tax Incentives
Doing Business
Afrobarometer
Actionaid Tax Treaties
PEFA
Polity IV Dataset
Digital Adoption Index
GSMA (SSA only)
Harmonized List of FCV
WGI
IMF Public Debt
Latinobarometro
MIMIC informality
Worldwide Bureaucracy Indicators
IMF Commodity Prices
WB Income Levels
Cross-Country Database of Fiscal Policy
UNCTAD ICT
WDI Customs
UNCTAD Tariffs
WB FINSTATS 2019
IMF Energy Subsidies
TI Corruption Perceptions index
Financial Secrecy Index
Heritage Foundation freedoms
IDA18 Cycle classifications
UN e-Governance Index
WDI - Human Capital Expenditure
ASPIRE Beneficiary Incidence and Coverage
GFS Social Benefits Expenditure
OECD Tax Wedge
WB Global Findex
CIT Productivity
VAT C Efficiency
USAID Collecting Taxes Database
WEF Infrastructure
WDI Net ODA and Aid
WDI Inflation and CPI
Trimming extra Variables
*/

/**********************************/
/*****ICTD & GTT Calculations******/
/**********************************/

//pull local-currency GDP from the ICTD excel sheet
import excel "ICTD excel.xlsx", clear sheet("GDP Series") firstrow cellrange(A2:AM200)
local yearcounter = 1980
foreach var of varlist B-AM {
	rename `var' GDP_LCU`yearcounter'
	local yearcounter = `yearcounter' + 1
}
reshape long GDP_LCU, i(ISO) j(year)
label var GDP_LCU "Millions of LCU and almost always comes from the IMF's WEO (Apr 2019)"
rename ISO Country_Code
//syncing iso codes to WBG standard
replace Country_Code="XKX" if Country_Code=="KSV"
replace Country_Code="PSE" if Country_Code=="WBG"
tempfile GDPLCU
save `GDPLCU'

//Prepare trade, GDP, and GDP per capita data from the WDI
import excel "WDI Trade GDP GDP_PC.xlsx", clear firstrow cellrange(A1:G13021)
drop CountryName
rename CountryCode Country_Code
rename Time year
drop TimeCode
rename Tradeof Trade
rename GDPconstant GDP_Constant_USD
rename GDPpercapita GDP_PC
tempfile WDIdata
save `WDIdata'

//open and rename variables from new ICTD dataset
use "Merged.dta", clear
rename country Country
rename source gov_data_source
rename iso Country_Code
rename reg Reg
rename (rev_inc_sc rev_ex_sc rev_ex_gr_inc_sc rev_ex_gr_ex_sc tot_res_rev ///
 tot_nres_rev_inc_sc tax_inc_sc tax_ex_sc resourcetaxes nrtax_inc_sc nrtax_ex_sc ///
 direct_inc_sc_inc_rt direct_inc_sc_ex_rt direct_ex_sc_inc_rt direct_ex_sc_ex_rt ///
 tax_income tax_res_income tax_nr_income tax_indiv tax_corp tax_res_corp /// 
 tax_nr_corp tax_payr_workf tax_property tax_indirect res_indirect nr_indirect ///
 tax_g_s tax_gs_general tax_gs_vat tax_gs_excises tax_trade tax_trade_import ///
 tax_trade_export tax_other nontax res_nontax nr_nontax sc grants) (Total_Revenue_incl_SC ///
 Total_Revenue_excl_SC Tot_Rev_excl_grant_incl_SC Tot_Rev_excl_grant_excl_SC ///
 Total_Resource_Revenue Total_Non_Res_Rev_incl_SC Tax_Revenue_incl_SC ///
 Tax_Revenue Resource_Taxes Non_Res_Tax_Rev_incl_SC ///
 Non_Res_Tax_Rev_excl_SC Direct_incl_SC_incl_Res Direct_incl_SC_excl_Res ///
 Direct_excl_SC_incl_Res Direct_excl_SC_excl_Res Income_Taxes ///
 Income_Taxes_Res Income_Taxes_Non_Res PIT CIT CIT_Res CIT_Non_Res ///
 Payroll_Workforce_Tax Property_Tax Indirect_Taxes Indirect_Taxes_Res ///
 Indirect_Taxes_Non_Res Tax_Goods_and_Services Tax_Goods_and_Services_Gen ///
 Value_Added_Tax Excise_Taxes Trade_Taxes Export_Taxes Import_Taxes Other_Taxes ///
 Non_Tax_Revenue Non_Tax_Revenue_Res Non_Tax_Revenue_Non_Res Social_Contributions Grants)


//reformat each tax measurement
foreach v of varlist Total_Revenue_incl_SC ///
 Total_Revenue_excl_SC Tot_Rev_excl_grant_incl_SC Tot_Rev_excl_grant_excl_SC ///
 Total_Resource_Revenue Total_Non_Res_Rev_incl_SC Tax_Revenue_incl_SC ///
 Tax_Revenue Resource_Taxes Non_Res_Tax_Rev_incl_SC ///
 Non_Res_Tax_Rev_excl_SC Direct_incl_SC_incl_Res Direct_incl_SC_excl_Res ///
 Direct_excl_SC_incl_Res Direct_excl_SC_excl_Res Income_Taxes ///
 Income_Taxes_Res Income_Taxes_Non_Res PIT CIT CIT_Res CIT_Non_Res ///
 Payroll_Workforce_Tax Property_Tax Indirect_Taxes Indirect_Taxes_Res ///
 Indirect_Taxes_Non_Res Tax_Goods_and_Services Tax_Goods_and_Services_Gen ///
 Value_Added_Tax Excise_Taxes Trade_Taxes Export_Taxes Import_Taxes Other_Taxes ///
 Non_Tax_Revenue Non_Tax_Revenue_Res Non_Tax_Revenue_Non_Res Social_Contributions Grants {
	format `v' %2.1f
}

drop if year<1990

sort Country_Code year

gen PIT_SC = PIT+Social_Contributions
label var PIT_SC "PIT and Social Contributions"

//syncing iso codes to WBG standard
replace Country_Code="XKX" if Country_Code=="KSV"
replace Country_Code="PSE" if Country_Code=="WBG"

//merge in WDI data (prepared at top of dofile)
merge m:1 Country_Code year using `WDIdata'
drop if _merge !=3
drop _merge

//the rest of this section was first developed by Sebastian James

gen ln_GDP_PC = ln(GDP_PC)
label var ln_GDP_PC "Log of GDP Per Capita"

gen ln_GDP_PC2 = ln_GDP_PC^2
label var ln_GDP_PC2 "Log of GDP Per Capita Squared"

// identifying outliers and removing
foreach u in Total_Revenue_incl_SC ///
 Total_Revenue_excl_SC Tot_Rev_excl_grant_incl_SC Tot_Rev_excl_grant_excl_SC ///
 Total_Resource_Revenue Total_Non_Res_Rev_incl_SC Tax_Revenue_incl_SC ///
 Tax_Revenue Resource_Taxes Non_Res_Tax_Rev_incl_SC ///
 Non_Res_Tax_Rev_excl_SC Direct_incl_SC_incl_Res Direct_incl_SC_excl_Res ///
 Direct_excl_SC_incl_Res Direct_excl_SC_excl_Res Income_Taxes ///
 Income_Taxes_Res Income_Taxes_Non_Res PIT CIT CIT_Res CIT_Non_Res ///
 Payroll_Workforce_Tax Property_Tax Indirect_Taxes Indirect_Taxes_Res ///
 Indirect_Taxes_Non_Res Tax_Goods_and_Services Tax_Goods_and_Services_Gen ///
 Value_Added_Tax Excise_Taxes Trade_Taxes Export_Taxes Import_Taxes Other_Taxes ///
 Non_Tax_Revenue Non_Tax_Revenue_Res Non_Tax_Revenue_Non_Res Social_Contributions Grants PIT_SC { 
	egen `u'_99 = pctile(`u'), p(99)
	egen `u'_01 = pctile(`u'), p(1)
	replace `u'=. if `u' > `u'_99 & `u'!=.
	replace `u'=. if `u' < `u'_01 & `u'!=.
	drop `u'_99 `u'_01
}

gen GDP_PC2 = GDP_PC^2

//merge in GDPLCU data from excel version of ICTD data (prepped at top of this dofile)
merge m:1 Country_Code year using `GDPLCU'
drop if _merge !=3
drop _merge


//calculating Tax buoyancy and efficiency
foreach u in Tax_Revenue_incl_SC Tax_Revenue Income_Taxes PIT CIT Property_Tax Value_Added_Tax Excise_Taxes Trade_Taxes Social_Contributions { 
	gen `u'_lcu=(`u'/100)*GDP_LCU
}

encode Country_Code , gen(cntry)
tsset cntry year
gen delta_GDP=(GDP_LCU-l.GDP_LCU)/l.GDP_LCU

foreach u in Tax_Revenue_incl_SC Tax_Revenue Income_Taxes PIT CIT Property_Tax Value_Added_Tax Excise_Taxes Trade_Taxes Social_Contributions { 
gen delta_`u'=(`u'_lcu-l.`u'_lcu)/l.`u'_lcu
gen `u'_buoyancy=delta_`u'/delta_GDP
local u1=upper(substr("`u'",1,1))+substr("`u'",2,.)+ " Taxes - Buoyancy"
label var `u'_buoyancy "`u1'"
}

label var Tax_Revenue_incl_SC_buoyancy "Tax Revenue incl. SC Buoyancy"
label var Tax_Revenue_buoyancy "Tax Buoyancy"
label var Income_Taxes_buoyancy "Income Taxes Buoyancy"
label var Value_Added_Tax_buoyancy "VAT Buoyancy"
label var Property_Tax_buoyancy "Property Taxes Buoyancy"
label var Trade_Taxes_buoyancy "Trade Taxes Buoyancy"

//tax effort calculations
sort Country_Code year

gen ln_Tax_Revenue = ln(Tax_Revenue)
gen ln_Tax_Revenue_incl_SC = ln(Tax_Revenue_incl_SC)
gen ln_Trade = ln(Trade)

* prep for frontier analysis
egen Country_ID=group(Country_Code), label
xtset Country_ID year

*When doing frontier analysis and the iterations don't converge we need to supply an initial value
//just tax
reg ln_Tax_Revenue ln_GDP_PC ln_GDP_PC2 ln_Trade
matrix b0 = e(b), ln(e(rmse)^2) , .1
matrix list b0

frontier ln_Tax_Revenue ln_GDP_PC ln_GDP_PC2 ln_Trade, dist(hnormal) from(b0, copy)
predict Tax_Effort, te

label var Tax_Effort "Tax Effort"
gen Tax_Capacity = Tax_Revenue/Tax_Effort
label var Tax_Capacity "Tax Capacity (% of GDP)"
gen Tax_Gap = Tax_Capacity - Tax_Revenue
label var Tax_Gap "Tax Gap (% of GDP)"

//tax including SC
reg ln_Tax_Revenue_incl_SC ln_GDP_PC ln_GDP_PC2 ln_Trade
matrix b0 = e(b), ln(e(rmse)^2) , .1
matrix list b0

frontier ln_Tax_Revenue_incl_SC ln_GDP_PC ln_GDP_PC2 ln_Trade, dist(hnormal) from(b0, copy)
predict Tax_Effort_SC, te

label var Tax_Effort_SC "Tax Effort (including SC)"
gen Tax_Capacity_SC = Tax_Revenue_incl_SC/Tax_Effort_SC
label var Tax_Capacity_SC "Tax Capacity including SC (% of GDP)"
gen Tax_Gap_SC = Tax_Capacity_SC - Tax_Revenue_incl_SC
label var Tax_Gap_SC "Tax Gap including SC (% of GDP)"

foreach v of varlist _all{
	local u: variable label `v'
	local x = "[ICTD & GTT] " + "`u'"
	label var `v' "`x'"
}

label var year "year"
label var Country "country"
replace Reg=3 if Country=="Saint Vincent and the Grenadines"

save "Master Dataset.dta", replace

/********************************/
/**World Development Indicators**/
/********************************/

//manufacturing

import excel using "WDI July 1 2020.xlsx", firstrow cellrange(A1:P6511) clear
save "WDI July 1 2020.dta", replace

rename Manufactu manu_share
rename CountryCode Country_Code
rename Time year
label var manu_share "[WDI] Manufacturing, value added (% of GDP)"

keep Country_Code year manu_share

save "Manufacturing VA.dta", replace

use "Master Dataset.dta", clear
merge m:1 Country_Code year using "Manufacturing VA.dta"
drop if _merge==2
drop _merge

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
while `yearcrawl'<=2017 {
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

keep Country_Code year informal

save "WDI Informality.dta", replace

use "Master Dataset.dta", clear
merge m:1 Country_Code year using "WDI Informality.dta"
drop if _merge==2
drop _merge

save "Master Dataset.dta", replace

//Informal Employment - Male and Female

import excel "WDI Informal employment.xlsx", sheet("Data") firstrow clear

rename CountryName Country
rename Time year
rename CountryCode Country_Code
keep Country year Country_Code Informalemploymentfemaleo Informalemploymentmaleof
rename (Informalemploymentfemaleo Informalemploymentmaleof) ///
 (informal_emp_f informal_emp_m)
drop if Country_Code==""
 
foreach v in informal_emp_f informal_emp_m {

	replace `v'="" if `v'==".."
	destring `v', replace

}

gen informal_emp_diff_mf=informal_emp_m-informal_emp_f
lab var informal_emp_diff_mf "Difference in informal employment (Male - Female, %)"

foreach v of varlist _all{
	local u: variable label `v'
	local x = "[WDI] " + "`u'"
	label var `v' "`x'"
}

keep Country_Code year informal_emp_f informal_emp_m informal_emp_diff

tempfile informalemp
save	`informalemp', replace

use "Master dataset.dta", clear

merge 1:1 Country_Code year using `informalemp'
drop if _merge==2
drop _merge

save "Master dataset.dta", replace

//agriculture value added

import excel using "WDI Agriculture VA.xlsx", firstrow cellrange(A1:E12804) clear

rename Agriculture agri_share
rename CountryCode Country_Code
rename Time year
drop TimeCode CountryName
label var agri_share "[WDI] Agriculture, value added (% of GDP)"

keep Country_Code year agri_share

save "Agriculture VA.dta", replace

use "Master Dataset.dta", clear
merge m:1 Country_Code year using "Agriculture VA.dta"
drop if _merge==2
drop _merge

save "Master Dataset.dta", replace

//resource richness

import excel using "Natural Resource Rents WDI.xlsx", firstrow cellrange(A1:D12804) clear

rename Totalnatural resourcerents
rename CountryCode Country_Code
rename Time year
drop CountryName
label var resourcerents "[WDI] Natural resource rents as a percent of GDP"

keep Country_Code year resourcerents

save "Resource Richness.dta", replace

use "Master Dataset.dta", clear
merge m:1 Country_Code year using "Resource Richness.dta"
drop if _merge==2
drop _merge

tsset cntry year
gen resource_tminus1 = l.resourcerents
gen resource_tminus2 = l.resource_tminus1
egen threeyearresource=rowmean(resourcerents resource_tminus1 resource_tminus2)
gen resource_rich=.
replace resource_rich=1 if threeyearresource>=10 & threeyearresource<.
replace resource_rich=0 if threeyearresource<10
drop resource_tminus1 resource_tminus2 threeyearresource

save "Master Dataset.dta", replace

//oil richness

import excel using "Oil Rents WDI.xlsx", firstrow cellrange(A1:D12804) clear

rename Oilrentsof oilrents
rename CountryCode Country_Code
rename Time year
drop CountryName
label var oilrents "[WDI] Oil rents as a percent of GDP"

keep Country_Code year oilrents

save "Oil Richness.dta", replace

use "Master Dataset.dta", clear
merge m:1 Country_Code year using "Oil Richness.dta"
drop if _merge==2
drop _merge

tsset cntry year
gen oil_tminus1 = l.oilrents
gen oil_tminus2 = l.oil_tminus1
egen threeyearoil=rowmean(oilrents oil_tminus1 oil_tminus2)
gen oil_rich=.
replace oil_rich=1 if threeyearoil>=10 & threeyearoil<.
replace oil_rich=0 if threeyearoil<10
drop oil_tminus1 oil_tminus2 threeyearoil

save "Master Dataset.dta", replace

//GINI inequality

import excel "WDI GINI.xlsx", firstrow cellrange(A1:E10851) clear
rename CountryName Country
rename CountryCode Country_Code
rename Time year
drop TimeCode
rename GINI GINI

keep Country_Code year GINI

save "WDI GINI.dta", replace

use "Master Dataset.dta", clear
merge m:1 Country_Code year using "WDI GINI.dta"
drop if _merge==2
drop _merge

save "Master Dataset.dta", replace

//Population

import excel "WDI population.xlsx", sheet("Data") firstrow clear

drop if CountryCode==""
drop TimeCode
rename CountryName Country
rename CountryCode Country_Code
rename Time year
rename Population Population
replace Population="" if Population==".."
destring Population, replace

label var Population "[WDI] Population"

keep Country_Code year Population

tempfile pop
save 	`pop', replace

use "Master dataset.dta", clear

merge 1:1 Country_Code year using `pop'
drop if _merge==2
drop _merge

save "Master dataset.dta", replace

//Government Expense

import excel "WDI govt expense.xlsx", sheet("Data") firstrow clear

drop if CountryCode==""
drop TimeCode
rename CountryName Country
rename CountryCode Country_Code
rename Time year
rename ExpenseofGDPGCXPNTOTL Gov_Exp_GDP
replace Gov_Exp_GDP="" if Gov_Exp_GDP==".."
destring Gov_Exp_GDP, replace

label var Gov_Exp_GDP "[WDI] Expense (% of GDP)"

keep Country_Code year Gov_Exp_GDP

tempfile expense
save 	`expense', replace

use "Master dataset.dta", clear

merge 1:1 Country_Code year using `expense'
drop if _merge==2
drop _merge

save "Master dataset.dta", replace

//Labor Force Participation Ratios

import excel "WDI Female to male labor participation ratio.xlsx", sheet("Data") ///
 firstrow clear
 
rename CountryName Country
rename CountryCode Country_Code
rename Time year
rename Ratiooffemaletomalelaborfo LaborForceFtoM_Natl
rename F LaborForceFtoM_ILO
drop TimeCode
drop if Country_Code==""

foreach v in LaborForceFtoM_Natl LaborForceFtoM_ILO {

	replace `v'="" if `v'==".."
	destring `v', replace

}

label var LaborForceFtoM_Natl "[WDI] Labor Force Participation Female to Male (National Estimate)"
label var LaborForceFtoM_ILO "[WDI] Labor Force Participation Female to Male (ILO Estimate)"

keep Country_Code year LaborForceFtoM_Natl LaborForceFtoM_ILO

tempfile LFFMR
save	`LFFMR', replace

use "Master dataset.dta", clear

merge 1:1 Country_Code year using `LFFMR'
drop if _merge==2
drop _merge

save "Master dataset.dta", replace

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

//conforming the the naming in the country codes file
replace Country="Cote d'Ivoire" if Country=="Côte d'Ivoire"
replace Country="Egypt" if Country=="Egypt, Arab Rep."
replace Country="Guyana" if Country=="Guyana, CR"
replace Country="North Macedonia" if Country=="Macedonia, FYR"
replace Country="Russia" if Country=="Russian Federation"
replace Country="Venezuela, RB" if Country=="Venezuela, R.B."
replace Country="Yemen" if Country=="Yemen, Rep."

//adding country codes for safe merging
merge m:1 Country using "Country Codes.dta"
drop if _merge!=3
drop _merge

save "World Bank Enterprise Surveys.dta", replace

use "Master Dataset.dta", clear
merge m:1 Country_Code year using "World Bank Enterprise Surveys.dta"
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
while `yearcrawl'<=2017 {
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

//bribery

import excel "Enterprise Surveys Bribery Incidence.xlsx", ///
 sheet("Data") firstrow clear

rename (SeriesName CountryName CountryCode) (BriberyIncidence Country Country_Code)

drop SeriesCode
drop in 222
drop in 221
drop in 220
drop in 219
drop in 218

reshape long YR, i(Country) j(year)

drop BriberyIncidence
rename YR BriberyIncidence
lab var BriberyIncidence "[Enterprise Surveys] % of firms experiencing at least one bribe payment request"

replace BriberyIncidence="" if BriberyIncidence==".."
destring BriberyIncidence, replace

save "Enterprise Surveys Bribery Incidence.dta", replace

use "Master Dataset.dta", clear
merge m:1 Country_Code year using "Enterprise Surveys Bribery Incidence.dta"
drop if _merge==2
drop _merge

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

/*************************/
/*****Tax Incentives******/
/*************************/

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

//adjusting some country names
replace Country="Venezuela, RB" if Country=="Venezuela"
replace Country="Bahamas, The" if Country=="Bahamas"
replace Country="Brunei" if Country=="Brunei Darussalam"
replace Country="Cabo Verde" if Country=="Cape Verde"
replace Country="Cayman Islands" if Country=="Cayman Island"
replace Country="Congo, Dem. Rep." if Country=="Congo, Democratic Republic of"
replace Country="Congo, Rep." if Country=="Congo, Republic of"
replace Country="Gambia, The" if Country=="Gambia"
replace Country="Hong Kong SAR, China" if Country=="Hong Kong SAR"
replace Country="Lao PDR" if Country=="Lao"
replace Country="Macao SAR, China" if Country=="Macau"
replace Country="North Macedonia" if Country=="Macedonia"
replace Country="St. Lucia" if Country=="Saint Lucia"
replace Country="Slovak Republic" if Country=="Slovak Rep."
replace Country="Korea, Rep." if Country=="South Korea"
replace Country="Eswatini" if Country=="Swaziland"
replace Country="Gambia, The" if Country=="Gambia"

//adding country codes for safe merging
merge m:1 Country using "Country Codes.dta"
drop if _merge!=3
drop _merge
drop Country

save "Tax incentives and transparency.dta", replace

use "Master Dataset.dta", clear
merge m:m Country_Code year using "Tax incentives and transparency.dta"
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

replace Country="Cote d'Ivoire" if Country=="Côte d'Ivoire"
replace Country="Egypt" if Country=="Egypt, Arab Rep."
replace Country="Iran" if Country=="Iran, Islamic Rep."
replace Country="North Macedonia" if Country=="Macedonia, FYR"
replace Country="Russia" if Country=="Russian Federation"
replace Country="Syria" if Country=="Syrian Arab Republic"
replace Country="Sao Tome and Principe" if Country=="São Tomé and Príncipe"
replace Country="Yemen" if Country=="Yemen, Rep."
//drop a partly Non-ISO code
drop Country_Code

//adding country codes for safe merging
merge m:1 Country using "Country Codes.dta"
drop if _merge!=3
drop _merge
drop Country

save "Doing Business Historical - Paying Taxes.dta", replace

use "Master Dataset.dta", clear
merge m:1 Country_Code year using "Doing Business Historical - Paying Taxes.dta"
drop if _merge==2
drop _merge

save "Master Dataset.dta", replace
/*
//Starting a Business
import excel "DBEXCEL.xlsx", sheet("Data") firstrow clear

drop IndicatorCode E-S
rename T Score

keep if IndicatorName=="Starting a business - Score" | IndicatorName=="Starting a business: Cost - Men (% of income per capita)" ///
 | IndicatorName=="Starting a business: Cost - Women (% of income per capita)" ///
 | IndicatorName=="Starting a business: Minimum capital (% of income per capita)" ///
 | IndicatorName=="Starting a business: Procedures required - Men (number)" ///
 | IndicatorName=="Starting a business: Procedures required - Women (number)" ///
 | IndicatorName=="Starting a business: Time - Men (days)" ///
 | IndicatorName=="Starting a business: Time - Women (days)"
 
encode IndicatorName, gen(indicator)
reshape wide Score IndicatorName, i(CountryName) j(indicator)

lab var Score1 "[DBI-19] Starting a business - Score"
lab var Score2 "[DBI-19] Starting a business: Cost - Men (% of income per capita)"
lab var Score3 "[DBI-19] Starting a business: Cost - Women (% of income per capita)"
lab var Score4 "[DBI-19] Starting a business: Minimum capital (% of income per capita)"
lab var Score5 "[DBI-19] Starting a business: Procedures required - Men (number)"
lab var Score6 "[DBI-19] Starting a business: Procedures required - Women (number)"
lab var Score7 "[DBI-19] Starting a business: Time - Men (days)"
lab var Score8 "[DBI-19] Starting a business: Time - Women (days)"

rename Score1 SB_Score
rename Score2 SB_Cost_M
rename Score3 SB_Cost_F
rename Score4 SB_MinCap
rename Score5 SB_Proc_M
rename Score6 SB_Proc_F
rename Score7 SB_Time_M
rename Score8 SB_Time_F
rename CountryName Country
rename CountryCode Country_Code

drop IndicatorName*

tempfile dbibus
save	`dbibus'

use "Master Dataset.dta", clear
merge m:1 Country_Code using `dbibus'
drop if _merge==2
drop _merge

save "Master Dataset.dta", replace
*/
/*********************/
/*** Afrobarometer ***/
/*********************/

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
replace q50=. if q50==-1 | q50==9 | q50==.a
gen must_vs_no_need_tax=.
replace must_vs_no_need_tax=1 if q50==1
replace must_vs_no_need_tax=2 if q50==2
replace must_vs_no_need_tax=4 if q50==3
replace must_vs_no_need_tax=5 if q50==4
replace must_vs_no_need_tax=3 if q50==5
replace q51=. if q51==-1 | q51==9 | q51==.a
gen hightax_vs_lowtax=q51
replace hightax_vs_lowtax=1 if q51==1
replace hightax_vs_lowtax=2 if q51==2
replace hightax_vs_lowtax=3 if q51==5
replace hightax_vs_lowtax=4 if q51==3
replace hightax_vs_lowtax=5 if q51==4
replace q56i=. if q56i==-1 | q56i==9
replace q59d=. if q59d==-1 | q59d==9
replace q60f=. if q60f==-1 | q60f==9
replace q73a=. if q73a==-1 | q73a==9 | q73a==8 | q73a==.a
replace q73c=. if q73c==-1 | q73c==9 | q73c==8 | q73c==.a
replace q73e=. if q73e==-1 | q73e==9 | q73e==7 | q73e==.a
qui label list Q77
replace q77=. if q77==-1 | q77==9995 | q77==9997 | q77==9998 | q77==9999
rename q26c refuse_pay_tax
tab refuse_pay_tax, gen(refuse_pay_tax_fac)
rename q48c pp_must_pay_tax
tab pp_must_pay_tax, gen(pp_must_pay_tax_fac)
*rename q50 must_vs_no_need_tax
tab must_vs_no_need_tax, gen(must_vs_no_need_tax_fac)
*rename q51 hightax_vs_lowtax
tab hightax_vs_lowtax, gen(hightax_vs_lowtax_fac)
gen often_avoid_tax=q56i+1 
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
gen must_vs_no_need_tax=.
replace must_vs_no_need_tax=1 if q44==1
replace must_vs_no_need_tax=2 if q44==2
replace must_vs_no_need_tax=4 if q44==3
replace must_vs_no_need_tax=5 if q44==4
replace must_vs_no_need_tax=3 if q44==5
replace q52d=. if q52d==-1 | q52d==9
replace q53f=. if q53f==-1 | q53f==9
replace q65c=. if q65c==-1 | q65c==9 | q65c==98
replace q65c=15 if q65c==1
replace q65c=14 if q65c==2
replace q65c=13 if q65c==3
replace q65c=12 if q65c==4
replace q65c=11 if q65c==5
gen hightax_vs_lowtax=.
replace hightax_vs_lowtax=1 if q65c==11
replace hightax_vs_lowtax=2 if q65c==12
replace hightax_vs_lowtax=3 if q65c==13
replace hightax_vs_lowtax=4 if q65c==14
replace hightax_vs_lowtax=5 if q65c==15
/*note for q65c "It depends" was coded as "6", potentially skewing the mean ///
	I have recoded it here as "3" in the "Neither support nor oppose" group*/
replace hightax_vs_lowtax=3 if q65c==6
replace q70b=. if q70b==-1 | q70b==9 | q70b==7
gen often_avoid_tax=q70b
replace often_avoid_tax=1 if q70b==4
replace often_avoid_tax=2 if q70b==3
replace often_avoid_tax=3 if q70b==2
replace often_avoid_tax=4 if q70b==1
rename q27d refuse_pay_tax
tab refuse_pay_tax, gen(refuse_pay_tax_fac)
rename q42c pp_must_pay_tax
tab pp_must_pay_tax, gen(pp_must_pay_tax_fac)
*rename q44 must_vs_no_need_tax
tab must_vs_no_need_tax, gen(must_vs_no_need_tax_fac)
rename q52d trust_tax_dept
tab trust_tax_dept, gen(trust_tax_dept_fac)
rename q53f corrupt_tax_offic
tab corrupt_tax_offic, gen(corrupt_tax_offic_fac)
*rename q65c hightax_vs_lowtax
tab hightax_vs_lowtax, gen(hightax_vs_lowtax_fac)
*rename q70b often_avoid_tax
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
merge m:1 refuse_pay_tax pp_must_pay_tax must_vs_no_need_tax trust_tax_dept ///
 corrupt_tax_offic hightax_vs_lowtax often_avoid_tax country using `r5'
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
lab var corrupt_tax_offic      "How corrupt are tax officials? Mean response (1-4) " 

lab var hightax_vs_lowtax_fac1 "(Strong more services) Higher taxes with more government services vs lower taxes with fewer services  - - % answering  1 (strongly agree with statement 1) "
lab var hightax_vs_lowtax_fac2 "(More services) Higher taxes with more government services vs lower taxes with fewer services  - - % answering  2 (agree with statement 1) "
lab var hightax_vs_lowtax_fac3 "(Neither) Higher taxes with more government services vs lower taxes with fewer services  - - % answering  5 (agree with neither statements)"
lab var hightax_vs_lowtax_fac4 "(Low tax) Higher taxes with more government services vs lower taxes with fewer services  - - % answering  3 (agree with statement 2) "
lab var hightax_vs_lowtax_fac5 "(Strong low tax) Higher taxes with more government services vs lower taxes with fewer services  - - % answering  4 (strongly agree with statement 2) "

lab var must_vs_no_need_tax_fac1 "(Strong must pay) Citizens must pay taxes vs no need to tax the people  - - % answering  1 (strongly agree with statement 1)"
lab var must_vs_no_need_tax_fac2 "(Must pay) Citizens must pay taxes vs no need to tax the people  - - % answering  2 (agree with statement 1)"
lab var must_vs_no_need_tax_fac3 "(Neither) Citizens must pay taxes vs no need to tax the people  - - % answering  5 (agree with neither)"
lab var must_vs_no_need_tax_fac4 "(No need) Citizens must pay taxes vs no need to tax the people  - - % answering  3 (agree with statement 2)"
lab var must_vs_no_need_tax_fac5 "(Strong no need) Citizens must pay taxes vs no need to tax the people  - - % answering  4 (strongly agree with statement 2)"

lab var often_avoid_tax_fac1 "How often do people avoid paying taxes?  - - % answering  1 (never)"
lab var often_avoid_tax_fac2 "How often do people avoid paying taxes?  - - % answering  2 (rarely)"
lab var often_avoid_tax_fac3 "How often do people avoid paying taxes?  - - % answering  3 (often)"
lab var often_avoid_tax_fac4 "How often do people avoid paying taxes?  - - % answering  4 (always)"

lab var pp_must_pay_tax_fac1 "People must pay taxes  - - % answering  1 (strongly disagree)"
lab var pp_must_pay_tax_fac2 "People must pay taxes  - - % answering  2 (disagree)"
lab var pp_must_pay_tax_fac3 "People must pay taxes  - - % answering  3 (neutral)"
lab var pp_must_pay_tax_fac4 "People must pay taxes  - - % answering  4 (agree)"
lab var pp_must_pay_tax_fac5 "People must pay taxes  - - % answering  5 (strongly agree)"
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
	the responses*/

foreach v of varlist _all{
	local u: variable label `v'
	local x = "[Afrobaro] " + "`u'"
	label var `v' "`x'"
}
label var year "year"

decode country, gen(Country)
drop country

replace Country="Cabo Verde" if Country=="Cape Verde"
replace Country="Sao Tome and Principe" if Country=="São Tomé and Príncipe"
replace Country="Eswatini" if Country=="Swaziland"

//adding country codes for safe merging
merge m:1 Country using "Country Codes.dta"
drop if _merge!=3
drop _merge
drop Country

save "Afrobaro_merged.dta", replace

use "Master Dataset.dta", clear
merge m:1 Country_Code year using "Afrobaro_merged.dta"
drop if _merge==2
drop _merge

/*merge in Round 7*/
merge 1:1 Country year using "merged_r7_data.dta", update
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

/**************************/
/**Actionaid Tax Treaties**/
/**************************/

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
replace Country = "Cabo Verde" if Country=="Cape Verde"
replace Country = "Eswatini" if Country=="Swaziland"

//adding country codes for safe merging
merge m:1 Country using "Country Codes.dta"
drop if _merge!=3
drop _merge
drop Country

save "Tax Treaties (Country Year Level).dta", replace

use "Master Dataset.dta", clear
merge m:1 Country_Code year using "Tax Treaties (Country Year Level).dta"
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
while `y'<=2017 {
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

//extracting dates from strings in various formats
egen Date2 = sieve(Date), keep(numeric)
//correcting a couple differently formatted entries
replace Date2="1711" if Date2=="172011"
replace Date2="1611" if Date2=="162011"
//adjusting to a standard format
replace Date2=usubstr(Date2,-2,2) if strlen(Date2)==2
replace Date2=usubstr(Date2,-4,2) if strlen(Date2)>2
destring Date2, replace
replace Date2 = Date2 + 2000
drop Date
rename Date2 year

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

drop Lastupdate

foreach v of varlist _all{
	local u: variable label `v'
	local x = "[PEFA 2011] " + "`u'"
	label var `v' "`x'"
}
label var year "year"
label var Country "country"

drop if Country=="Bosnia & Herzegovina-BiH" | Country=="Bosnia & Herzegovina-DB" | Country=="Bosnia & Herzegovina-RS"
replace Country="Bosnia and Herzegovina" if Country=="Bosnia & Herzegovina-FBiH"
replace Country="Cabo Verde" if Country=="Cape Verde"
replace Country="Congo, Dem. Rep." if Country=="Congo, Dem. Rep. of"
replace Country="Antigua and Barbuda" if Country=="Antigua & Barbuda"
replace Country="Aruba" if Country=="Aruba (Neth.)"
replace Country="Bahamas, The" if Country=="Bahamas"
replace Country="Congo, Rep." if Country=="Congo, Republic of"
replace Country="Fiji" if Country=="Fiji Islands"
replace Country="Guinea-Bissau" if Country=="Guinea Bissau"
replace Country="North Macedonia" if Country=="Macedonia" | Country=="Macedonia, FYR"
replace Country="Timor-Leste" if Country=="Timor Leste"
replace Country="Russia" if Country=="Russian Federation"
replace Country="Eswatini" if Country=="Swaziland"
replace Country="Micronesia, Fed. Sts." if Country=="Micronesia"
drop if Country=="Morrocco"

//stripping the variables down to a few key, tax-related variables
keep Country year PI_13_0 PI_13_1 PI_13_2 PI_13_3 PI_14_1 PI_14_2 PI_14_3 PI_15_1 PI_15_2 PI_15_3

//filling out missing years
gen assessmentyear=1
sort Country year

egen cntry=group(Country)
tsset cntry year

tsfill, full

replace assessmentyear=0 if assessmentyear!=1

local yearcounter = 2000
while `yearcounter'<=2018 {
	foreach var of varlist PI* {
		replace `var' = l.`var' if `var'==. & assessmentyear==0 & year==`yearcounter'
	}
	local yearcounter = `yearcounter' + 1
}
local yearcounter = 2000
while `yearcounter'<=2018 {
	by cntry, sort: replace Country = Country[_n-1] if assessmentyear==0 & year==`yearcounter'
	local yearcounter = `yearcounter' + 1
}
drop assessmentyear cntry
keep if Country!=""

//adding country codes for safe merging
merge m:1 Country using "Country Codes.dta"
drop if _merge!=3
drop _merge
drop Country

save "PEFA 2011.dta", replace

use "Master Dataset.dta", clear
merge m:1 Country_Code year using "PEFA 2011.dta"
drop if _merge==2
drop _merge

sort Country year

save "Master Dataset.dta", replace

/*****************************/
/******Polity IV Dataset******/
/*****************************/

/*Import Excel*/
import excel "p4v2018.xlsx", sheet("p4v2017") firstrow clear

drop if year<1990
drop cyear ccode democ autoc scode

rename polity polityscore
rename country Country
gen autocracy=(polityscore<=-6 & polityscore!=.)
replace autocracy=. if polityscore==.
gen anocracy =(polityscore>=-5 & polityscore<=5 & polityscore!=.)
replace anocracy=. if polityscore==.
gen democracy=(polityscore>= 6 & polityscore!=.)
replace democracy=. if polityscore==.

gen politylessfree=(polityscore<=0 & polityscore!=.)
replace politylessfree=. if polityscore==.
gen politymorefree=(polityscore> 0 & polityscore!=.)
replace politymorefree=. if polityscore==.
label var autocracy "-6 or less score"
label var anocracy "-5 to 5 score"
label var democracy "6 or higher score"
label var politylessfree "-10 to 0 score"
label var politymorefree "1 to 10 score"

replace Country="Bosnia and Herzegovina" if Country=="Bosnia"
replace Country="Congo, Democratic Republic of the" if Country=="Congo Kinshasa"
replace Country="Congo, Republic of the" if Country=="Congo Brazzaville"
replace Country="Cote d'Ivoire" if Country=="Cote D'Ivoire" | Country=="Ivory Coast"
replace Country="Czechia" if Country=="Czech Republic"
replace Country="Timor-Leste" if Country=="East Timor" | Country=="Timor Leste"
replace Country="Gambia, The" if Country=="Gambia"
replace Country="Korea, Republic of" if Country=="Korea South"
replace Country="Lao People’s Democratic Republic" if Country=="Laos"
replace Country="North Macedonia" if Country=="Macedonia"
replace Country="Myanmar" if Country=="Myanmar (Burma)"
replace Country="Russian Federation" if Country=="Russia"
replace Country="Slovakia" if Country=="Slovak Republic"
replace Country="Sudan" if Country=="Sudan-North"
replace Country="Eswatini" if Country=="Swaziland"
replace Country="Syrian Arab Republic" if Country=="Syria"
replace Country="United Arab Emirates" if Country=="UAE"

foreach v of varlist _all{

	local u: variable label `v'
	local x = "[Polity IV 2018] " + "`u'"
	label var `v' "`x'"
	
}

duplicates drop Country year, force

tempfile polity
save	`polity', replace

use "Master Dataset.dta", clear
merge m:1 Country year using `polity'

drop if _merge==2
drop _merge

sort Country year
save "Master Dataset.dta", replace

/*tidying up some Region discrepancies*/
replace Reg=3 if Country=="St. Vincent and the Grenadines"

save "Master Dataset.dta", replace


/******************************/
/****Digital Adoption Index****/
/******************************/

/*Import Excel*/
import excel "DAIforweb.xlsx", sheet("Sheet1") firstrow case(lower) clear

rename country Country
replace Country="Brunei" if Country=="Brunei Darussalam"
replace Country="Egypt" if Country=="Egypt, Arab Rep."
replace Country="Iran" if Country=="Iran, Islamic Rep."
replace Country="North Macedonia" if Country=="Macedonia, FYR"
replace Country="Russia" if Country=="Russian Federation"
replace Country="Eswatini" if Country=="Swaziland"
replace Country="Syria" if Country=="Syrian Arab Republic"
replace Country="Yemen" if Country=="Yemen, Rep."

foreach v of varlist daigovernmentsubindex daipeoplesubindex daibusinesssubindex ///
 digitaladoptionindex {
	local u: variable label `v'
	local x = "[DAI 2016] " + "`u'"
	label var `v' "`x'"
}

//adding country codes for safe merging
merge m:1 Country using "Country Codes.dta"
drop if _merge!=3
drop _merge
drop Country

save "DAI dataset.dta", replace

use "Master Dataset.dta", clear
merge m:1 Country_Code year using "DAI dataset.dta"

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

label var connectionstotaliot "Total number of connections, including IoT"
label var connectionstotal "Total number of connections, excluding IoT"
label var connectionsprepaid "Total number of connections - prepaid"
label var connectionscontract "Total number of connections - contract"
label var connections2g "Total number of connections - 2g"
label var connections3g "Total number of connections - 3g"
label var connections4g "Total number of connections - 4g"
label var connectionsmobbrd "Total number of connections - mobile broadband"
label var connectionssmrtphone "Total number of connections - smartphone"
label var connectionsbasic "Total number of connections - basic only"
label var connectionsdataonly "Total number of connections - data only"
label var connectionsgsm "Total number of connections - GSM"
label var connectionswcdma "Total number of connections - WCDMA"
label var connectionslte "Total number of connections - LTE"
label var connectionsliot "Total number of connections - Licensed IoT"
label var connectionsm2m "Total number of connections - Cellular M2M"
label var connectionscdma2g "Total number of connections - CDMA2G"
label var connectionscdma2000 "Total number of connections - CDMA2000"
label var connectionslpwa "Total number of connections - LPWA"

foreach v of varlist _all{
	local u: variable label `v'
	local x = "[GSMA 2018] " + "`u'"
	label var `v' "`x'"
}

lab variable year ""
lab variable Country ""
lab variable gsmaReg ""

replace Country="Central African Republic" if Country=="Central Africa Republic"

//adding country codes for safe merging
merge m:1 Country using "Country Codes.dta"
drop if _merge!=3
drop _merge
drop Country

save "GSMA SSA Dataset.dta", replace

use "Master Dataset.dta", clear
merge m:1 Country_Code year using "GSMA SSA Dataset.dta"
drop if _merge==2
drop _merge

save "Master Dataset.dta", replace

/****************************/
/***Harmonized List of FCV***/
/****************************/

import excel "Historical FCV.xlsx", firstrow cellrange(A1:C530) clear

replace Country="Bosnia and Herzegovina" if Country=="Bosnia & Herzegovina"
replace Country="Guinea-Bissau" if Country=="Guinea Bissau"
replace Country="Lao PDR" if Country=="Lao, PDR"
replace Country="Micronesia, Fed. Sts." if Country=="Micronesia, FS"
replace Country="Micronesia, Fed. Sts." if Country=="Micronesia FS"
replace Country="Venezuela, RB" if Country=="Venezuela"
replace Country="Eswatini" if Country=="Swaziland"

//adding country codes for safe merging
merge m:1 Country using "Country Codes.dta"
drop if _merge!=3
drop _merge
drop Country

save "FCV.dta", replace

use "Master Dataset.dta", clear
merge m:1 Country_Code year using "FCV.dta"
drop if _merge==2
drop _merge

replace FCV=0 if FCV!=1  & year>=2006
label var FCV "[WB Fragile Status] from harmonized list of fragile situations"

save "Master Dataset.dta", replace

/**********************/
/*********WGI**********/
/**********************/

import excel using "WGI July 1 2020.xlsx", firstrow cellrange(A1:J4281) clear

rename CountryCode Country_Code
rename Time year
drop TimeCode
rename ControlofCorruption WGI_Corruption
rename GovernmentEff WGI_Government
rename PoliticalStability WGI_Stability
rename RegulatoryQuality WGI_Regulatory
rename RuleofLaw WGI_Law
rename VoiceandAcc WGI_Voice
label var WGI_Corruption "[WGI] Control of Corruption"
label var WGI_Government "[WGI] Government Effectiveness"
label var WGI_Stability "[WGI] Political Stability and Absence of Violence/Terrorism"
label var WGI_Regulatory "[WGI] Regulatory Quality"
label var WGI_Law "[WGI] Rule of Law"
label var WGI_Voice "[WGI] Voice and Accountability"

tempfile WGI
save `WGI'

use "Master Dataset.dta", clear
merge m:1 Country_Code year using `WGI'
drop if _merge==2
drop _merge

save "Master Dataset.dta", replace

/***********************/
/****IMF Public DEBT****/
/***********************/

import excel "imf-dm-export-20190612.xls", sheet("DEBT1") firstrow clear
rename B publicdebtimf
rename DEBTofGDP Country
drop in 1
gen year=2015

replace Country="China" if Country=="China, People's Republic of"
replace Country="Congo, Dem. Rep." if Country=="Congo, Dem. Rep. of the"
replace Country="Congo, Rep." if Country=="Congo, Republic of "
replace Country="Cote d'Ivoire" if Country=="Côte d'Ivoire"
replace Country="Hong Kong SAR, China" if Country=="Hong Kong SAR"
replace Country="Korea, Rep." if Country=="Korea, Republic of"
replace Country="Lao PDR" if Country=="Lao P.D.R."
replace Country="Micronesia, Fed. Sts." if Country=="Micronesia, Fed. States of"
replace Country="St. Kitts and Nevis" if Country=="Saint Kitts and Nevis"
replace Country="St. Vincent and the Grenadines" if Country=="Saint Vincent and the Grenadines"
replace Country="St. Lucia" if Country=="Saint Lucia"
replace Country="South Sudan" if Country=="South Sudan, Republic of"
replace Country="Sao Tome and Principe" if Country=="São Tomé and Príncipe"
replace Country="Venezuela, RB" if Country=="Venezuela"
replace Country="North Macedonia" if Country=="North Macedonia "
replace Country="Russia" if Country=="Russian Federation"
replace Country="Brunei" if Country=="Brunei Darussalam"

//adding country codes for safe merging
merge m:1 Country using "Country Codes.dta"
drop if _merge!=3
drop _merge
drop Country

save "IMF Central Government Debt.dta", replace

use "Master Dataset.dta", clear
merge m:1 Country_Code year using "IMF Central Government Debt.dta"
drop if _merge==2
drop _merge

label var publicdebtimf "[IMF] Public Debt (% of GDP)"

save "Master Dataset.dta", replace

/*****************/
/*LATINOBAROMETRO*/
/*****************/

clear all
set more off


/*LB 2017*/
use "Latinobarometro_2017.dta", clear
rename idenpa Country

keep Country P1ST P2ST P3STGBS P4STGBS P5STGBS P6STICC1 P10ST S3 wt

foreach v of varlist P1ST P2ST P3STGBS P4STGBS P5STGBS P6STICC1 P10ST S3 {

	replace `v'=. if `v'<0

}

foreach u of varlist P1ST-S3 {
	local l`u' : variable label `u'
		if `"`l`u''"' == "" {
		local l`u' "`u'"
	}
}

local list "P1ST P2ST P3STGBS P4STGBS P5STGBS P6STICC1 P10ST S3"

foreach var of local list {
	levelsof `var', local(`var'_levels)
	foreach val of local `var'_levels {
		local `var'vl`val' : label `var' `val'
	}
}

rename (P1ST P2ST P3ST P4STGBS P5STGBS P6STICC1 P10ST S3) (lifesatisfaction ///
 countryprogress countryproblem econsitnow econsitpast econsitfuture benofpowerful ///
 lackfood)

 
foreach v of varlist lifesatisfaction-lackfood {

	tab `v', gen(`v'_fac)

}

collapse (mean) lifesatisfaction-lackfood_fac4 [pweight=wt], by(Country)

foreach v of varlist lifesatisfaction-lackfood_fac4 {

	label var `v' "[LB]`l`v''"
}

 foreach variable of local list {
	 foreach value of local `var'_levels{
		 label variable `variable'`value' "`l`variable'': `yearvl`value''"
	 }
}

lab var lifesatisfaction_fac1 "[LB] How satisfied are you with your life? % answering  1 (Very) "
lab var lifesatisfaction_fac2 "[LB] How satisfied are you with your life? % answering  2 (Quite) "
lab var lifesatisfaction_fac3 "[LB] How satisfied are you with your life? % answering  3 (Not very) "
lab var lifesatisfaction_fac4 "[LB] How satisfied are you with your life? % answering  4 (Not at all) "

lab var countryprogress_fac1 "[LB] What is the state of progress in [country]? % answering  1 (Progressing) "
lab var countryprogress_fac2 "[LB] What is the state of progress in [country]? % answering  2 (Standstill) "
lab var countryprogress_fac3 "[LB] What is the state of progress in [country]? % answering  3 (Declining) "

lab var econsitnow_fac1 "[LB] What is the country's economic situation? % answering  1 (Very good) "
lab var econsitnow_fac2 "[LB] What is the country's economic situation? % answering  2 (Good) "
lab var econsitnow_fac3 "[LB] What is the country's economic situation? % answering  3 (About average) "
lab var econsitnow_fac4 "[LB] What is the country's economic situation? % answering  4 (Bad) "
lab var econsitnow_fac5 "[LB] What is the country's economic situation? % answering  5 (Very bad) "

lab var econsitpast_fac1 "[LB] What was the country's economic situation a year ago? % answering  1 (Much better) "
lab var econsitpast_fac2 "[LB] What was the country's economic situation a year ago? % answering  2 (A little better) "
lab var econsitpast_fac3 "[LB] What was the country's economic situation a year ago? % answering  3 (The same) "
lab var econsitpast_fac4 "[LB] What was the country's economic situation a year ago? % answering  4 (A little worse) "
lab var econsitpast_fac5 "[LB] What was the country's economic situation a year ago? % answering  5 (Much worse) "

lab var econsitfuture_fac1 "[LB] What will be the country's economic situation in a year? % answering  1 (Much better) "
lab var econsitfuture_fac2 "[LB] What will be the country's economic situation in a year? % answering  2 (A little better) "
lab var econsitfuture_fac3 "[LB] What will be the country's economic situation in a year? % answering  3 (The same) "
lab var econsitfuture_fac4 "[LB] What will be the country's economic situation in a year? % answering  4 (A little worse) "
lab var econsitfuture_fac5 "[LB] What will be the country's economic situation in a year? % answering  5 (Much worse) "

lab var lackfood_fac1 "[LB] Last year, how often have you/family lacked food? 1 (Never)"
lab var lackfood_fac2 "[LB] Last year, how often have you/family lacked food? 2 (Rarely)"
lab var lackfood_fac3 "[LB] Last year, how often have you/family lacked food? 3 (Sometimes)"
lab var lackfood_fac4 "[LB] Last year, how often have you/family lacked food? 4 (Often)"

gen year=2017

tempfile lb17
save `lb17', replace

/*LB 2016*/
use "Latinobarometro_2016.dta", clear
rename idenpa Country

keep Country P1ST P2ST P3STGBS P4STGBS P5STGBS P6STICC1 P7STGBS P10ST P24ST P38STA ///
 P1TIA P2TIB P3TIC P4TID P5TIE P6TIF P7TIG P8TIH P9TII P10TI P11TI P12TI P13TI ///
 P14TI P15TI P16TI P17TI P20TIA P22TIA P44STA P62ST S1 wt

foreach v of varlist P1ST P2ST P4STGBS P5STGBS P6STICC1 P7STGBS P10ST P38STA P1TIA ///
 P2TIB P3TIC P4TID P5TIE P6TIF P7TIG P8TIH P9TII P10TI P20TIA P22TIA P44STA P62ST ///
 S1 {

	replace `v'=. if `v'<1 | `v'==8 | `v'==9
	
}

foreach v of varlist P24ST {

	replace `v'=. if `v'<1

}

foreach v of varlist P1ST-S1 {
	local l`v' : variable label `v'
		if `"`l`v''"' == "" {
		local l`v' "`v'"
	}
}

local list "P1ST P2ST P3STGBS P4STGBS P5STGBS P6STICC1 P7STGBS P10ST P24ST P38STA P1TIA P2TIB P3TIC P4TID P5TIE P6TIF P7TIG P8TIH P9TII P10TI P11TI P12TI P13TI P14TI P15TI P16TI P17TI P20TIA P22TIA P44STA P62ST S1"

foreach var of local list {
	levelsof `var', local(`var'_levels)
	foreach val of local `var'_levels {
		local `var'vl`val' : label `var' `val'
	}
}

rename (P1ST P2ST P3STGBS P4STGBS P5STGBS P6STICC1 P7STGBS P10ST P24ST P38STA P1TIA ///
 P2TIB P3TIC P4TID P5TIE P6TIF P7TIG P8TIH P9TII P10TI P11TI P12TI P13TI P14TI ///
 P15TI P16TI P17TI P20TIA P22TIA P44STA P62ST S1) (lifesatisfaction countryprogress ///
 countryproblem econsitnow econsitpast econsitfuture econsitpersonalnow benofpowerful ///
 scaleavoidtaxes corruptact corruptpres corruptmps corruptgovtoffic corruptlocgovt ///
 corruptpolice corrupttaxoffic corruptjudges corruptrelldrs corruptbusexec ///
 morecorrupt bribepublicschool bribehospital bribeofficdoc bribeservices ///
 bribepolice bribecourts bribereported govtvscorrupt pplvscorrupt corruptionisok ///
 taxesforinfra lackfood)
 
foreach v of varlist lifesatisfaction-lackfood {

	tab `v', gen(`v'_fac)

}

collapse (mean) lifesatisfaction-lackfood_fac4 [pweight=wt], by(Country)

foreach v of varlist lifesatisfaction-lackfood_fac4 {

	label var `v' "[LB]`l`v''"
}

 foreach variable of local list {
	 foreach value of local `var'_levels{
		 label variable `variable'`value' "`l`variable'': `yearvl`value''"
	 }
}

lab var lifesatisfaction_fac1 "[LB] How satisfied are you with your life? % answering  1 (Very) "
lab var lifesatisfaction_fac2 "[LB] How satisfied are you with your life? % answering  2 (Quite) "
lab var lifesatisfaction_fac3 "[LB] How satisfied are you with your life? % answering  3 (Not very) "
lab var lifesatisfaction_fac4 "[LB] How satisfied are you with your life? % answering  4 (Not at all) "

lab var countryprogress_fac1 "[LB] What is the state of progress in [country]? % answering  1 (Progressing) "
lab var countryprogress_fac2 "[LB] What is the state of progress in [country]? % answering  2 (Standstill) "
lab var countryprogress_fac3 "[LB] What is the state of progress in [country]? % answering  3 (Declining) "

lab var econsitnow_fac1 "[LB] What is the country's economic situation? % answering  1 (Very good) "
lab var econsitnow_fac2 "[LB] What is the country's economic situation? % answering  2 (Good) "
lab var econsitnow_fac3 "[LB] What is the country's economic situation? % answering  3 (About average) "
lab var econsitnow_fac4 "[LB] What is the country's economic situation? % answering  4 (Bad) "
lab var econsitnow_fac5 "[LB] What is the country's economic situation? % answering  5 (Very bad) "

lab var econsitpast_fac1 "[LB] What was the country's economic situation a year ago? % answering  1 (Much better) "
lab var econsitpast_fac2 "[LB] What was the country's economic situation a year ago? % answering  2 (A little better) "
lab var econsitpast_fac3 "[LB] What was the country's economic situation a year ago? % answering  3 (The same) "
lab var econsitpast_fac4 "[LB] What was the country's economic situation a year ago? % answering  4 (A little worse) "
lab var econsitpast_fac5 "[LB] What was the country's economic situation a year ago? % answering  5 (Much worse) "

lab var econsitfuture_fac1 "[LB] What will be the country's economic situation in a year? % answering  1 (Much better) "
lab var econsitfuture_fac2 "[LB] What will be the country's economic situation in a year? % answering  2 (A little better) "
lab var econsitfuture_fac3 "[LB] What will be the country's economic situation in a year? % answering  3 (The same) "
lab var econsitfuture_fac4 "[LB] What will be the country's economic situation in a year? % answering  4 (A little worse) "
lab var econsitfuture_fac5 "[LB] What will be the country's economic situation in a year? % answering  5 (Much worse) "

lab var scaleavoidtaxes_fac1  "[LB] How justified is tax evasion? % answering 1 (not at all justified) "
lab var scaleavoidtaxes_fac2  "[LB] How justified is tax evasion? % answering 2 "
lab var scaleavoidtaxes_fac3  "[LB] How justified is tax evasion? % answering 3 "
lab var scaleavoidtaxes_fac4  "[LB] How justified is tax evasion? % answering 4 "
lab var scaleavoidtaxes_fac5  "[LB] How justified is tax evasion? % answering 5 "
lab var scaleavoidtaxes_fac6  "[LB] How justified is tax evasion? % answering 6 "
lab var scaleavoidtaxes_fac7  "[LB] How justified is tax evasion? % answering 7 "
lab var scaleavoidtaxes_fac8  "[LB] How justified is tax evasion? % answering 8 "
lab var scaleavoidtaxes_fac9  "[LB] How justified is tax evasion? % answering 9 "
lab var scaleavoidtaxes_fac10 "[LB] How justified is tax evasion? % answering 10 (totally justified) "

lab var lackfood_fac1 "[LB] Last year, how often have you/family lacked food? 1 (Never)"
lab var lackfood_fac2 "[LB] Last year, how often have you/family lacked food? 2 (Rarely)"
lab var lackfood_fac3 "[LB] Last year, how often have you/family lacked food? 3 (Sometimes)"
lab var lackfood_fac4 "[LB] Last year, how often have you/family lacked food? 4 (Often)"

gen year=2016

tempfile lb16
save `lb16', replace

/*LB 2015*/
use "Latinobarometro_2015.dta", clear
rename idenpa Country

keep Country P1ST P2ST P3STGBS P4STGBS P5STICC1 P6STGBS P12TG_B P14ST P18ST ///
 P21TGB_F P47N P51ST_B P56ST S1 wt

foreach v of varlist P1ST P2ST P3STGBS P4STGBS P5STICC1 P6STGBS P12TG_B P14ST ///
 P18ST P21TGB_F S1 {

	replace `v'=. if `v'<1 | `v'==8

}

foreach v of varlist P47N P56ST {

	replace `v'=. if `v'==98 | `v'==99 | `v'<1

}

foreach v of varlist P1ST-S1 {
	local l`v' : variable label `v'
		if `"`l`v''"' == "" {
		local l`v' "`v'"
	}
}

local list "Country P1ST P2ST P3STGBS P4STGBS P5STICC1 P6STGBS P12TG_B P14ST P18ST P21TGB_F P47N P51ST_B P56ST S1"

foreach var of local list {
	levelsof `var', local(`var'_levels)
	foreach val of local `var'_levels {
		local `var'vl`val' : label `var' `val'
	}
}

rename (P1ST P2ST P3STGBS P4STGBS P5STICC1 P6STGBS P12TG_B P14ST P18ST P21TGB_F ///
 P47N P51ST_B P56ST S1) (lifesatisfaction countryprogress econsitnow econsitpast ///
 econsitfuture econsitpersonalnow econfunction benofpowerful incdisfair refusetaxes ///
 taxesforinfra citizenspaytaxes scaleavoidtaxes lackfood)
 
replace refusetaxes=1 if refusetaxes==2

foreach v of varlist lifesatisfaction-lackfood {

	tab `v', gen(`v'_fac)

} 

collapse (mean) lifesatisfaction-lackfood_fac4 [pweight=wt], by (Country)

foreach v of varlist lifesatisfaction-lackfood_fac4 {

	label var `v' "[LB] `l`v''"
}

 foreach variable of local list {
	 foreach value of local `var'_levels{
		 label variable `variable'`value' "`l`variable'': `yearvl`value''"
	 }
}

lab var lifesatisfaction_fac1 "[LB] How satisfied are you with your life? % answering  1 (Very) "
lab var lifesatisfaction_fac2 "[LB] How satisfied are you with your life? % answering  2 (Quite) "
lab var lifesatisfaction_fac3 "[LB] How satisfied are you with your life? % answering  3 (Not very) "
lab var lifesatisfaction_fac4 "[LB] How satisfied are you with your life? % answering  4 (Not at all) "

lab var countryprogress_fac1 "[LB] What is the state of progress in [country]? % answering  1 (Progressing) "
lab var countryprogress_fac2 "[LB] What is the state of progress in [country]? % answering  2 (Standstill) "
lab var countryprogress_fac3 "[LB] What is the state of progress in [country]? % answering  3 (Declining) "

lab var econsitnow_fac1 "[LB] What is the country's economic situation? % answering  1 (Very good) "
lab var econsitnow_fac2 "[LB] What is the country's economic situation? % answering  2 (Good) "
lab var econsitnow_fac3 "[LB] What is the country's economic situation? % answering  3 (About average) "
lab var econsitnow_fac4 "[LB] What is the country's economic situation? % answering  4 (Bad) "
lab var econsitnow_fac5 "[LB] What is the country's economic situation? % answering  5 (Very bad) "

lab var econsitpast_fac1 "[LB] What was the country's economic situation a year ago? % answering  1 (Much better) "
lab var econsitpast_fac2 "[LB] What was the country's economic situation a year ago? % answering  2 (A little better) "
lab var econsitpast_fac3 "[LB] What was the country's economic situation a year ago? % answering  3 (The same) "
lab var econsitpast_fac4 "[LB] What was the country's economic situation a year ago? % answering  4 (A little worse) "
lab var econsitpast_fac5 "[LB] What was the country's economic situation a year ago? % answering  5 (Much worse) "

lab var econsitfuture_fac1 "[LB] What will be the country's economic situation in a year? % answering  1 (Much better) "
lab var econsitfuture_fac2 "[LB] What will be the country's economic situation in a year? % answering  2 (A little better) "
lab var econsitfuture_fac3 "[LB] What will be the country's economic situation in a year? % answering  3 (The same) "
lab var econsitfuture_fac4 "[LB] What will be the country's economic situation in a year? % answering  4 (A little worse) "
lab var econsitfuture_fac5 "[LB] What will be the country's economic situation in a year? % answering  5 (Much worse) "

lab var scaleavoidtaxes_fac1  "[LB] How justified is tax evasion? % answering 1 (not at all justified) "
lab var scaleavoidtaxes_fac2  "[LB] How justified is tax evasion? % answering 2 "
lab var scaleavoidtaxes_fac3  "[LB] How justified is tax evasion? % answering 3 "
lab var scaleavoidtaxes_fac4  "[LB] How justified is tax evasion? % answering 4 "
lab var scaleavoidtaxes_fac5  "[LB] How justified is tax evasion? % answering 5 "
lab var scaleavoidtaxes_fac6  "[LB] How justified is tax evasion? % answering 6 "
lab var scaleavoidtaxes_fac7  "[LB] How justified is tax evasion? % answering 7 "
lab var scaleavoidtaxes_fac8  "[LB] How justified is tax evasion? % answering 8 "
lab var scaleavoidtaxes_fac9  "[LB] How justified is tax evasion? % answering 9 "
lab var scaleavoidtaxes_fac10 "[LB] How justified is tax evasion? % answering 10 (totally justified) "

lab var lackfood_fac1 "[LB] Last year, how often have you/family lacked food? % answering 1 (Never)"
lab var lackfood_fac2 "[LB] Last year, how often have you/family lacked food? % answering 2 (Rarely)"
lab var lackfood_fac3 "[LB] Last year, how often have you/family lacked food? % answering 3 (Sometimes)"
lab var lackfood_fac4 "[LB] Last year, how often have you/family lacked food? % answering 4 (Often)"

lab var econfunction_fac1 "[LB] How satisfied are you with the country's economy? % answering 1 (Very) "
lab var econfunction_fac2 "[LB] How satisfied are you with the country's economy? % answering 2 (Quite) "
lab var econfunction_fac3 "[LB] How satisfied are you with the country's economy? % answering 3 (Not very) "
lab var econfunction_fac4 "[LB] How satisfied are you with the country's economy? % answering 4 (Not at all) "

lab var incdisfair_fac1 "[LB] How fair is the income distribution? % answering 1 (Very fair) "
lab var incdisfair_fac2 "[LB] How fair is the income distribution? % answering 2 (Fair) "
lab var incdisfair_fac3 "[LB] How fair is the income distribution? % answering 3 (Unfair) "
lab var incdisfair_fac4 "[LB] How fair is the income distribution? % answering 4 (Very unfair) "

lab var refusetaxes_fac1 "[LB] Have you ever refused to pay taxes to the government? % answering 1 (At least once) "
lab var refusetaxes_fac2 "[LB] Have you ever refused to pay taxes to the government? % answering 2 (Never) "

gen year=2015

tempfile lb15
save `lb15', replace

/*LB 2013*/
use "Latinobarometro_2013.dta", clear
rename idenpa Country

keep Country P1ST P2ST P3STGBS P4STGBS P5STGBS P6STGBS P11ST_A P11ST_B P11ST_C ///
 P13TGB_B P14ST P27ST P34GBS P58ST P61BD P64GBSM P65GBS P69ST P72ST_C P72ST_D S1 ///
 S3 wt

foreach v of varlist P1ST P2ST P3STGBS P4STGBS P5STGBS P6STGBS P13TGB_B P14ST ///
 P27ST P34GBS P61BD P64GBSM P65GBS P69ST P72ST_C P72ST_D S1 S3 {

	replace `v'=. if `v'<1 | `v'==8

}

foreach v of varlist P11ST_A P11ST_B P11ST_C P58ST {

	replace `v'=. if `v'<1 | `v'==98 | `v'==00
	
} 

foreach v of varlist P1ST-S3 {
	local l`v' : variable label `v'
		if `"`l`v''"' == "" {
		local l`v' "`v'"
	}
}

local list "P1ST P2ST P3STGBS P4STGBS P5STGBS P6STGBS P11ST_A P11ST_B P11ST_C P13TGB_B P14ST P27ST P34GBS P58ST P61BD P64GBSM P65GBS P69ST P72ST_C P72ST_D S1 S3"

foreach var of local list {
	levelsof `var', local(`var'_levels)
	foreach val of local `var'_levels {
		local `var'vl`val' : label `var' `val'
	}
}

rename (P1ST P2ST P3STGBS P4STGBS P5STGBS P6STGBS P11ST_A P11ST_B P11ST_C ///
 P13TGB_B P14ST P27ST P34GBS P58ST P61BD P64GBSM P65GBS P69ST P72ST_C P72ST_D S1 ///
 S3) (lifesatisfaction countryprogress econsitnow econsitpast econsitfuture ///
 econsitpersonalnow scalepoorrichnow scalepoorrichpast scalepoorrichfuture ///
 econfunction benofpowerful incdisfair refusetaxes scaleavoidtaxes corruptinpvtsec ///
 corruptinlocgovt corruptinnatlgovt corruptprogress stsolvecorrupt stsolvepoverty ///
 pricerise lackfood)

replace refusetaxes=1 if refusetaxes==2
 
foreach v of varlist lifesatisfaction-lackfood {

	tab `v', gen(`v'_fac)

}

collapse (mean) lifesatisfaction-lackfood_fac4 [pweight=wt], by (Country)

foreach v of varlist lifesatisfaction-lackfood_fac4 {

	label var `v' "[LB] `l`v''"
}


 foreach variable of local list {
	 foreach value of local `var'_levels{
		 label variable `variable'`value' "`l`variable'': `yearvl`value''"
	 }
}

lab var lifesatisfaction_fac1 "[LB] How satisfied are you with your life? % answering  1 (Very) "
lab var lifesatisfaction_fac2 "[LB] How satisfied are you with your life? % answering  2 (Quite) "
lab var lifesatisfaction_fac3 "[LB] How satisfied are you with your life? % answering  3 (Not very) "
lab var lifesatisfaction_fac4 "[LB] How satisfied are you with your life? % answering  4 (Not at all) "

lab var countryprogress_fac1 "[LB] What is the state of progress in [country]? % answering  1 (Progressing) "
lab var countryprogress_fac2 "[LB] What is the state of progress in [country]? % answering  2 (Standstill) "
lab var countryprogress_fac3 "[LB] What is the state of progress in [country]? % answering  3 (Declining) "

lab var econsitnow_fac1 "[LB] What is the country's economic situation? % answering  1 (Very good) "
lab var econsitnow_fac2 "[LB] What is the country's economic situation? % answering  2 (Good) "
lab var econsitnow_fac3 "[LB] What is the country's economic situation? % answering  3 (About average) "
lab var econsitnow_fac4 "[LB] What is the country's economic situation? % answering  4 (Bad) "
lab var econsitnow_fac5 "[LB] What is the country's economic situation? % answering  5 (Very bad) "

lab var econsitpast_fac1 "[LB] What was the country's economic situation a year ago? % answering  1 (Much better) "
lab var econsitpast_fac2 "[LB] What was the country's economic situation a year ago? % answering  2 (A little better) "
lab var econsitpast_fac3 "[LB] What was the country's economic situation a year ago? % answering  3 (The same) "
lab var econsitpast_fac4 "[LB] What was the country's economic situation a year ago? % answering  4 (A little worse) "
lab var econsitpast_fac5 "[LB] What was the country's economic situation a year ago? % answering  5 (Much worse) "

lab var econsitfuture_fac1 "[LB] What will be the country's economic situation in a year? % answering  1 (Much better) "
lab var econsitfuture_fac2 "[LB] What will be the country's economic situation in a year? % answering  2 (A little better) "
lab var econsitfuture_fac3 "[LB] What will be the country's economic situation in a year? % answering  3 (The same) "
lab var econsitfuture_fac4 "[LB] What will be the country's economic situation in a year? % answering  4 (A little worse) "
lab var econsitfuture_fac5 "[LB] What will be the country's economic situation in a year? % answering  5 (Much worse) "

lab var scaleavoidtaxes_fac1  "[LB] How justified is tax evasion? % answering 1 (not at all justified) "
lab var scaleavoidtaxes_fac2  "[LB] How justified is tax evasion? % answering 2 "
lab var scaleavoidtaxes_fac3  "[LB] How justified is tax evasion? % answering 3 "
lab var scaleavoidtaxes_fac4  "[LB] How justified is tax evasion? % answering 4 "
lab var scaleavoidtaxes_fac5  "[LB] How justified is tax evasion? % answering 5 "
lab var scaleavoidtaxes_fac6  "[LB] How justified is tax evasion? % answering 6 "
lab var scaleavoidtaxes_fac7  "[LB] How justified is tax evasion? % answering 7 "
lab var scaleavoidtaxes_fac8  "[LB] How justified is tax evasion? % answering 8 "
lab var scaleavoidtaxes_fac9  "[LB] How justified is tax evasion? % answering 9 "
lab var scaleavoidtaxes_fac10 "[LB] How justified is tax evasion? % answering 10 (totally justified) "

lab var lackfood_fac1 "[LB] Last year, how often have you/family lacked food? % answering 1 (Never)"
lab var lackfood_fac2 "[LB] Last year, how often have you/family lacked food? % answering 2 (Rarely)"
lab var lackfood_fac3 "[LB] Last year, how often have you/family lacked food? % answering 3 (Sometimes)"
lab var lackfood_fac4 "[LB] Last year, how often have you/family lacked food? % answering 4 (Often)"

lab var econfunction_fac1 "[LB] How satisfied are you with the country's economy? % answering 1 (Very) "
lab var econfunction_fac2 "[LB] How satisfied are you with the country's economy? % answering 2 (Quite) "
lab var econfunction_fac3 "[LB] How satisfied are you with the country's economy? % answering 3 (Not very) "
lab var econfunction_fac4 "[LB] How satisfied are you with the country's economy? % answering 4 (Not at all) "

lab var incdisfair_fac1 "[LB] How fair is the income distribution? % answering 1 (Very fair) "
lab var incdisfair_fac2 "[LB] How fair is the income distribution? % answering 2 (Fair) "
lab var incdisfair_fac3 "[LB] How fair is the income distribution? % answering 3 (Unfair) "
lab var incdisfair_fac4 "[LB] How fair is the income distribution? % answering 4 (Very unfair) "

lab var refusetaxes_fac1 "[LB] Have you ever refused to pay taxes to the government? % answering 1 (At least once) "
lab var refusetaxes_fac2 "[LB] Have you ever refused to pay taxes to the government? % answering 2 (Never) "

lab var scalepoorrichnow_fac1  "[LB] Scale of where you see yourself on income distribution. % answering 1 (Bottom) "
lab var scalepoorrichnow_fac2  "[LB] Scale of where you see yourself on income distribution. % answering 2 "
lab var scalepoorrichnow_fac3  "[LB] Scale of where you see yourself on income distribution. % answering 3 "
lab var scalepoorrichnow_fac4  "[LB] Scale of where you see yourself on income distribution. % answering 4 "
lab var scalepoorrichnow_fac5  "[LB] Scale of where you see yourself on income distribution. % answering 5 "
lab var scalepoorrichnow_fac6  "[LB] Scale of where you see yourself on income distribution. % answering 6 "
lab var scalepoorrichnow_fac7  "[LB] Scale of where you see yourself on income distribution. % answering 7 "
lab var scalepoorrichnow_fac8  "[LB] Scale of where you see yourself on income distribution. % answering 8 "
lab var scalepoorrichnow_fac9  "[LB] Scale of where you see yourself on income distribution. % answering 9 "
lab var scalepoorrichnow_fac10 "[LB] Scale of where you see yourself on income distribution. % answering 10 (Top) "

gen year=2013

tempfile lb13
save `lb13', replace

/*LB 2011*/
use "Latinobarometro_2011.dta", clear
rename idenpa Country

keep Country P1ST P2ST P3ST_A P3ST_B P4ST P5STIC1A P6ST P12ST P14ST_B P16ST_E ///
 P17NE P17NF P19ST P21STB P57N_A P57N_B P58N_C P65ST P69ST_A P69ST_B P69ST_C ///
 P71ST_A P72ST P73ST P74ST P80ST_F P81ST S1NICC7 S6A S7N wt

foreach v of varlist P1ST P2ST P3ST_A P3ST_B P4ST P5STIC1A P6ST P12ST P14ST_B ///
 P16ST_E P17NE P17NF P19ST P21STB P57N_A P57N_B P65ST P69ST_A P69ST_B P69ST_C ///
 P73ST P74ST P80ST_F P81ST S1NICC7 S6A S7N {

	replace `v'=. if `v'<1 | `v'==8

}

foreach v of varlist P71ST_A P72ST {

	replace `v'=. if `v'==998 | `v'==000 | `v'==98 | `v'==00 | `v'<1

}
 
foreach v of varlist P1ST-S7N {
	local l`v' : variable label `v'
		if `"`l`v''"' == "" {
		local l`v' "`v'"
	}
}

local list "P1ST P2ST P3ST_A P3ST_B P4ST P4ST P5STIC1A P6ST P12ST P14ST_B P16ST_E P17NE P17NF P19ST P21STB P57N_A P57N_B P58N_C P65ST P69ST_A P69ST_B P69ST_C P71ST_A P72ST P73ST P74ST P80ST_F P81ST S1NICC7 S6A S7N"

foreach var of local list {
	levelsof `var', local(`var'_levels)
	foreach val of local `var'_levels {
		local `var'vl`val' : label `var' `val'
	}
}

rename (P1ST P2ST P3ST_A P3ST_B P4ST P5STIC1A P6ST P12ST P14ST_B P16ST_E P17NE ///
 P17NF P19ST P21STB P57N_A P57N_B P58N_C P65ST P69ST_A P69ST_B P69ST_C P71ST_A ///
 P72ST P73ST P74ST P80ST_F P81ST S1NICC7 S6A S7N) (lifesatisfaction ///
 countryproblem econsitnow polsitnow econsitpast econsitfuture econsitpersonalnow ///
 incdisfair econfunction bribesjustified demlesscorruption demmoretransparency ///
 benofpowerful citizenspaytaxes statehelp statedevelop corruptionproblem ///
 stsolvecorrupt developpvtent mkteconnecessary privatizationbensrich ///
 scaleavoidtaxes scalepplpaytaxes taxlevel taxfaircollect corruptact ///
 corruptprogress pricerise lackutilities lackfood)
 
foreach v of varlist lifesatisfaction-lackfood {

	tab `v', gen(`v'_fac)

}

collapse lifesatisfaction-lackfood_fac4 [pweight=wt], by(Country)

foreach v of varlist lifesatisfaction-lackfood_fac4 {

	label var `v' "[LB] `l`v''"
}

 foreach variable of local list {
	 foreach value of local `var'_levels{
		 label variable `variable'`value' "`l`variable'': `yearvl`value''"
	 }
}

lab var lifesatisfaction_fac1 "[LB] How satisfied are you with your life? % answering  1 (Very) "
lab var lifesatisfaction_fac2 "[LB] How satisfied are you with your life? % answering  2 (Quite) "
lab var lifesatisfaction_fac3 "[LB] How satisfied are you with your life? % answering  3 (Not very) "
lab var lifesatisfaction_fac4 "[LB] How satisfied are you with your life? % answering  4 (Not at all) "

lab var econsitnow_fac1 "[LB] What is the country's economic situation? % answering  1 (Very good) "
lab var econsitnow_fac2 "[LB] What is the country's economic situation? % answering  2 (Good) "
lab var econsitnow_fac3 "[LB] What is the country's economic situation? % answering  3 (About average) "
lab var econsitnow_fac4 "[LB] What is the country's economic situation? % answering  4 (Bad) "
lab var econsitnow_fac5 "[LB] What is the country's economic situation? % answering  5 (Very bad) "

lab var econsitpast_fac1 "[LB] What was the country's economic situation a year ago? % answering  1 (Much better) "
lab var econsitpast_fac2 "[LB] What was the country's economic situation a year ago? % answering  2 (A little better) "
lab var econsitpast_fac3 "[LB] What was the country's economic situation a year ago? % answering  3 (The same) "
lab var econsitpast_fac4 "[LB] What was the country's economic situation a year ago? % answering  4 (A little worse) "
lab var econsitpast_fac5 "[LB] What was the country's economic situation a year ago? % answering  5 (Much worse) "

lab var econsitfuture_fac1 "[LB] What will be the country's economic situation in a year? % answering  1 (Much better) "
lab var econsitfuture_fac2 "[LB] What will be the country's economic situation in a year? % answering  2 (A little better) "
lab var econsitfuture_fac3 "[LB] What will be the country's economic situation in a year? % answering  3 (The same) "
lab var econsitfuture_fac4 "[LB] What will be the country's economic situation in a year? % answering  4 (A little worse) "
lab var econsitfuture_fac5 "[LB] What will be the country's economic situation in a year? % answering  5 (Much worse) "

lab var scaleavoidtaxes_fac1  "[LB] How justified is tax evasion? % answering 1 (not at all justified) "
lab var scaleavoidtaxes_fac2  "[LB] How justified is tax evasion? % answering 2 "
lab var scaleavoidtaxes_fac3  "[LB] How justified is tax evasion? % answering 3 "
lab var scaleavoidtaxes_fac4  "[LB] How justified is tax evasion? % answering 4 "
lab var scaleavoidtaxes_fac5  "[LB] How justified is tax evasion? % answering 5 "
lab var scaleavoidtaxes_fac6  "[LB] How justified is tax evasion? % answering 6 "
lab var scaleavoidtaxes_fac7  "[LB] How justified is tax evasion? % answering 7 "
lab var scaleavoidtaxes_fac8  "[LB] How justified is tax evasion? % answering 8 "
lab var scaleavoidtaxes_fac9  "[LB] How justified is tax evasion? % answering 9 "
lab var scaleavoidtaxes_fac10 "[LB] How justified is tax evasion? % answering 10 (totally justified) "

lab var lackfood_fac1 "[LB] Last year, how often have you/family lacked food? % answering 1 (Never)"
lab var lackfood_fac2 "[LB] Last year, how often have you/family lacked food? % answering 2 (Rarely)"
lab var lackfood_fac3 "[LB] Last year, how often have you/family lacked food? % answering 3 (Sometimes)"
lab var lackfood_fac4 "[LB] Last year, how often have you/family lacked food? % answering 4 (Often)"

lab var econfunction_fac1 "[LB] How satisfied are you with the country's economy? % answering 1 (Very) "
lab var econfunction_fac2 "[LB] How satisfied are you with the country's economy? % answering 2 (Quite) "
lab var econfunction_fac3 "[LB] How satisfied are you with the country's economy? % answering 3 (Not very) "
lab var econfunction_fac4 "[LB] How satisfied are you with the country's economy? % answering 4 (Not at all) "

lab var incdisfair_fac1 "[LB] How fair is the income distribution? % answering 1 (Very fair) "
lab var incdisfair_fac2 "[LB] How fair is the income distribution? % answering 2 (Fair) "
lab var incdisfair_fac3 "[LB] How fair is the income distribution? % answering 3 (Unfair) "
lab var incdisfair_fac4 "[LB] How fair is the income distribution? % answering 4 (Very unfair) "
 
gen year=2011

tempfile lb11
save `lb11', replace

/*LB 2010*/
use "Latinobarometro_2010.dta", clear
rename idenpa Country

keep Country P1ST P2ST P3ST_A P3ST_B P4ST P5ST_A P6ST P9ST P11ST_B P12ST P13ST_A ///
 P13ST_B P13ST_C P14ST_D P19ST_B P27ST_A P56ST P57ST_A P58ST P62N P68ST P70ST_E ///
 P75ST_A P75ST_B P75ST_C S6A S6B wt

foreach v of varlist P1ST P2ST P3ST_A P3ST_B P4ST P5ST_A P6ST P9ST P11ST_B P12ST ///
 P14ST_D P19ST_B P27ST_A P56ST P62N P68ST P70ST_E P75ST_A P75ST_B P75ST_C S6A S6B {

	replace `v'=. if `v'<1 | `v'==8

}

foreach v of varlist P13ST_A P13ST_B P13ST_C P57ST_A P58ST {

	replace `v'=. if `v'==98 | `v'==00 | `v'==998 | `v'==000 | `v'<1

}
 
 foreach v of varlist P1ST-S6B {
	local l`v' : variable label `v'
		if `"`l`v''"' == "" {
		local l`v' "`v'"
	}
}

local list "P1ST P2ST P3ST_A P3ST_B P4ST P5ST_A P6ST P9ST P11ST_B P12ST P13ST_A P13ST_B P13ST_C P14ST_D P19ST_B P27ST_A P56ST P57ST_A P58ST P62N P68ST P70ST_E P75ST_A P75ST_B P75ST_C S6A S6B"

foreach var of local list {
	levelsof `var', local(`var'_levels)
	foreach val of local `var'_levels {
		local `var'vl`val' : label `var' `val'
	}
}

rename (P1ST P2ST P3ST_A P3ST_B P4ST P5ST_A P6ST P9ST P11ST_B P12ST P13ST_A ///
 P13ST_B P13ST_C P14ST_D P19ST_B P27ST_A P56ST P57ST_A P58ST P62N P68ST P70ST_E P75ST_A ///
 P75ST_B P75ST_C S6A) (lifesatisfaction countryproblem econsitnow polsitnow ///
 econsitpast econsitfuture econsitpersonalnow countryprogress econfunction ///
 incdisfair scalepoorrichnow scalepoorrichpast scalepoorrichfuture benofpowerful ///
 citizenspaytaxes richpoorconflict refusetaxes scaleavoidtaxes scalepplpaytaxes ///
 pplpaytaxes stsolveproblems corruptprogress developpvtent mkteconnecessary ///
 privatizationbensrich lackutilities)

replace benofpowerful=1 if benofpowerful==2
replace benofpowerful=2 if benofpowerful==3 | benofpowerful==4
 
foreach v of varlist lifesatisfaction-scaleavoidtaxes {

	tab `v', gen(`v'_fac)

}

collapse lifesatisfaction-scaleavoidtaxes_fac10 [pweight=wt], by(Country)

foreach v of varlist lifesatisfaction-scaleavoidtaxes_fac10 {

	label var `v' "[LB] `l`v''"
}

 foreach variable of local list {
	 foreach value of local `var'_levels{
		 label variable `variable'`value' "`l`variable'': `yearvl`value''"
	 }
}

lab var lifesatisfaction_fac1 "[LB] How satisfied are you with your life? % answering  1 (Very) "
lab var lifesatisfaction_fac2 "[LB] How satisfied are you with your life? % answering  2 (Quite) "
lab var lifesatisfaction_fac3 "[LB] How satisfied are you with your life? % answering  3 (Not very) "
lab var lifesatisfaction_fac4 "[LB] How satisfied are you with your life? % answering  4 (Not at all) "

lab var countryprogress_fac1 "[LB] What is the state of progress in [country]? % answering  1 (Progressing) "
lab var countryprogress_fac2 "[LB] What is the state of progress in [country]? % answering  2 (Standstill) "
lab var countryprogress_fac3 "[LB] What is the state of progress in [country]? % answering  3 (Declining) "

lab var econsitnow_fac1 "[LB] What is the country's economic situation? % answering  1 (Very good) "
lab var econsitnow_fac2 "[LB] What is the country's economic situation? % answering  2 (Good) "
lab var econsitnow_fac3 "[LB] What is the country's economic situation? % answering  3 (About average) "
lab var econsitnow_fac4 "[LB] What is the country's economic situation? % answering  4 (Bad) "
lab var econsitnow_fac5 "[LB] What is the country's economic situation? % answering  5 (Very bad) "

lab var econsitpast_fac1 "[LB] What was the country's economic situation a year ago? % answering  1 (Much better) "
lab var econsitpast_fac2 "[LB] What was the country's economic situation a year ago? % answering  2 (A little better) "
lab var econsitpast_fac3 "[LB] What was the country's economic situation a year ago? % answering  3 (The same) "
lab var econsitpast_fac4 "[LB] What was the country's economic situation a year ago? % answering  4 (A little worse) "
lab var econsitpast_fac5 "[LB] What was the country's economic situation a year ago? % answering  5 (Much worse) "

lab var econsitfuture_fac1 "[LB] What will be the country's economic situation in a year? % answering  1 (Much better) "
lab var econsitfuture_fac2 "[LB] What will be the country's economic situation in a year? % answering  2 (A little better) "
lab var econsitfuture_fac3 "[LB] What will be the country's economic situation in a year? % answering  3 (The same) "
lab var econsitfuture_fac4 "[LB] What will be the country's economic situation in a year? % answering  4 (A little worse) "
lab var econsitfuture_fac5 "[LB] What will be the country's economic situation in a year? % answering  5 (Much worse) "

lab var scaleavoidtaxes_fac1  "[LB] How justified is tax evasion? % answering 1 (not at all justified) "
lab var scaleavoidtaxes_fac2  "[LB] How justified is tax evasion? % answering 2 "
lab var scaleavoidtaxes_fac3  "[LB] How justified is tax evasion? % answering 3 "
lab var scaleavoidtaxes_fac4  "[LB] How justified is tax evasion? % answering 4 "
lab var scaleavoidtaxes_fac5  "[LB] How justified is tax evasion? % answering 5 "
lab var scaleavoidtaxes_fac6  "[LB] How justified is tax evasion? % answering 6 "
lab var scaleavoidtaxes_fac7  "[LB] How justified is tax evasion? % answering 7 "
lab var scaleavoidtaxes_fac8  "[LB] How justified is tax evasion? % answering 8 "
lab var scaleavoidtaxes_fac9  "[LB] How justified is tax evasion? % answering 9 "
lab var scaleavoidtaxes_fac10 "[LB] How justified is tax evasion? % answering 10 (totally justified) "

lab var econfunction_fac1 "[LB] How satisfied are you with the country's economy? % answering 1 (Very) "
lab var econfunction_fac2 "[LB] How satisfied are you with the country's economy? % answering 2 (Quite) "
lab var econfunction_fac3 "[LB] How satisfied are you with the country's economy? % answering 3 (Not very) "
lab var econfunction_fac4 "[LB] How satisfied are you with the country's economy? % answering 4 (Not at all) "

lab var incdisfair_fac1 "[LB] How fair is the income distribution? % answering 1 (Very fair) "
lab var incdisfair_fac2 "[LB] How fair is the income distribution? % answering 2 (Fair) "
lab var incdisfair_fac3 "[LB] How fair is the income distribution? % answering 3 (Unfair) "
lab var incdisfair_fac4 "[LB] How fair is the income distribution? % answering 4 (Very unfair) "

lab var refusetaxes_fac1 "[LB] Have you ever refused to pay taxes to the government? % answering 1 (At least once) "
lab var refusetaxes_fac2 "[LB] Have you ever refused to pay taxes to the government? % answering 2 (Never) "

lab var scalepoorrichnow_fac1  "[LB] Scale of where you see yourself on income distribution. % answering 1 (Bottom) "
lab var scalepoorrichnow_fac2  "[LB] Scale of where you see yourself on income distribution. % answering 2 "
lab var scalepoorrichnow_fac3  "[LB] Scale of where you see yourself on income distribution. % answering 3 "
lab var scalepoorrichnow_fac4  "[LB] Scale of where you see yourself on income distribution. % answering 4 "
lab var scalepoorrichnow_fac5  "[LB] Scale of where you see yourself on income distribution. % answering 5 "
lab var scalepoorrichnow_fac6  "[LB] Scale of where you see yourself on income distribution. % answering 6 "
lab var scalepoorrichnow_fac7  "[LB] Scale of where you see yourself on income distribution. % answering 7 "
lab var scalepoorrichnow_fac8  "[LB] Scale of where you see yourself on income distribution. % answering 8 "
lab var scalepoorrichnow_fac9  "[LB] Scale of where you see yourself on income distribution. % answering 9 "
lab var scalepoorrichnow_fac10 "[LB] Scale of where you see yourself on income distribution. % answering 10 (Top) " 
 
gen year=2010
 
tempfile lb10
save `lb10', replace

/*LB 2009*/
use "Latinobarometro_2009.dta", clear
rename idenpa Country

keep Country p1st p2st p3st_a p3st_b p4st p5st p6st p9st p12st_b p14st p17st_a p17st_b ///
 p17st_c p25st_b p60st_b p61st p73st_d p74st p81st_a p81st_b p81st_c s4a s4b wt

foreach v of varlist p1st p2st p3st_a p3st_b p4st p5st p6st p9st p12st_b p14st ///
 p25st_b p60st_b p73st_d p74st p81st_a p81st_b p81st_c s4a s4b {

	replace `v'=. if `v'<1 | `v'==8

}
 
foreach v of varlist p17st_a p17st_b p17st_c p61st {

	replace `v'=. if `v'==98 | `v'==00 | `v'==97 | `v'<1
	
}
 
 foreach v of varlist p1st-s4b {
	local l`v' : variable label `v'
		if `"`l`v''"' == "" {
		local l`v' "`v'"
	}
}

local list "p1st p2st p3st_a p3st_b p4st p5st p6st p9st p12st_b p14st p17st_a p17st_b p17st_c p25st_b p60st_b p61st p73st_d p74st p81st_a p81st_b p81st_c s4a s4b"

foreach var of local list {
	levelsof `var', local(`var'_levels)
	foreach val of local `var'_levels {
		local `var'vl`val' : label `var' `val'
	}
}

rename (p1st p2st p3st_a p3st_b p4st p5st p6st p9st p12st_b p14st p17st_a ///
 p17st_b p17st_c p25st_b p60st_b p61st p73st_d p74st p81st_a p81st_b p81st_c ///
 s4a) (lifesatisfaction countryproblem econsitnow polsitnow econsitpast ///
 econsitfuture econsitpersonalnow countryprogress econfunction incdisfair ///
 scalepoorrichnow scalepoorrichpast scalepoorrichfuture citizenspaytaxes ///
 avoidtaxes scaleavoidtaxes corruptact corruptprogress mkteconisbest ///
 developpvtent mkteconnecessary lackutilities)
 
foreach v of varlist lifesatisfaction-scaleavoidtaxes {

	tab `v', gen(`v'_fac)

}

collapse lifesatisfaction-scaleavoidtaxes_fac10 [pweight=wt], by(Country)

foreach v of varlist lifesatisfaction-scaleavoidtaxes_fac10 {

	label var `v' "[LB] `l`v''"
}

 foreach variable of local list {
	 foreach value of local `var'_levels{
		 label variable `variable'`value' "`l`variable'': `yearvl`value''"
	 }
}

lab var lifesatisfaction_fac1 "[LB] How satisfied are you with your life? % answering  1 (Very) "
lab var lifesatisfaction_fac2 "[LB] How satisfied are you with your life? % answering  2 (Quite) "
lab var lifesatisfaction_fac3 "[LB] How satisfied are you with your life? % answering  3 (Not very) "
lab var lifesatisfaction_fac4 "[LB] How satisfied are you with your life? % answering  4 (Not at all) "

lab var countryprogress_fac1 "[LB] What is the state of progress in [country]? % answering  1 (Progressing) "
lab var countryprogress_fac2 "[LB] What is the state of progress in [country]? % answering  2 (Standstill) "
lab var countryprogress_fac3 "[LB] What is the state of progress in [country]? % answering  3 (Declining) "

lab var econsitnow_fac1 "[LB] What is the country's economic situation? % answering  1 (Very good) "
lab var econsitnow_fac2 "[LB] What is the country's economic situation? % answering  2 (Good) "
lab var econsitnow_fac3 "[LB] What is the country's economic situation? % answering  3 (About average) "
lab var econsitnow_fac4 "[LB] What is the country's economic situation? % answering  4 (Bad) "
lab var econsitnow_fac5 "[LB] What is the country's economic situation? % answering  5 (Very bad) "

lab var econsitpast_fac1 "[LB] What was the country's economic situation a year ago? % answering  1 (Much better) "
lab var econsitpast_fac2 "[LB] What was the country's economic situation a year ago? % answering  2 (A little better) "
lab var econsitpast_fac3 "[LB] What was the country's economic situation a year ago? % answering  3 (The same) "
lab var econsitpast_fac4 "[LB] What was the country's economic situation a year ago? % answering  4 (A little worse) "
lab var econsitpast_fac5 "[LB] What was the country's economic situation a year ago? % answering  5 (Much worse) "

lab var econsitfuture_fac1 "[LB] What will be the country's economic situation in a year? % answering  1 (Much better) "
lab var econsitfuture_fac2 "[LB] What will be the country's economic situation in a year? % answering  2 (A little better) "
lab var econsitfuture_fac3 "[LB] What will be the country's economic situation in a year? % answering  3 (The same) "
lab var econsitfuture_fac4 "[LB] What will be the country's economic situation in a year? % answering  4 (A little worse) "
lab var econsitfuture_fac5 "[LB] What will be the country's economic situation in a year? % answering  5 (Much worse) "

lab var scaleavoidtaxes_fac1  "[LB] How justified is tax evasion? % answering 1 (not at all justified) "
lab var scaleavoidtaxes_fac2  "[LB] How justified is tax evasion? % answering 2 "
lab var scaleavoidtaxes_fac3  "[LB] How justified is tax evasion? % answering 3 "
lab var scaleavoidtaxes_fac4  "[LB] How justified is tax evasion? % answering 4 "
lab var scaleavoidtaxes_fac5  "[LB] How justified is tax evasion? % answering 5 "
lab var scaleavoidtaxes_fac6  "[LB] How justified is tax evasion? % answering 6 "
lab var scaleavoidtaxes_fac7  "[LB] How justified is tax evasion? % answering 7 "
lab var scaleavoidtaxes_fac8  "[LB] How justified is tax evasion? % answering 8 "
lab var scaleavoidtaxes_fac9  "[LB] How justified is tax evasion? % answering 9 "
lab var scaleavoidtaxes_fac10 "[LB] How justified is tax evasion? % answering 10 (totally justified) "

lab var econfunction_fac1 "[LB] How satisfied are you with the country's economy? % answering 1 (Very) "
lab var econfunction_fac2 "[LB] How satisfied are you with the country's economy? % answering 2 (Quite) "
lab var econfunction_fac3 "[LB] How satisfied are you with the country's economy? % answering 3 (Not very) "
lab var econfunction_fac4 "[LB] How satisfied are you with the country's economy? % answering 4 (Not at all) "

lab var incdisfair_fac1 "[LB] How fair is the income distribution? % answering 1 (Very fair) "
lab var incdisfair_fac2 "[LB] How fair is the income distribution? % answering 2 (Fair) "
lab var incdisfair_fac3 "[LB] How fair is the income distribution? % answering 3 (Unfair) "
lab var incdisfair_fac4 "[LB] How fair is the income distribution? % answering 4 (Very unfair) "

lab var scalepoorrichnow_fac1  "[LB] Scale of where you see yourself on income distribution. % answering 1 (Bottom) "
lab var scalepoorrichnow_fac2  "[LB] Scale of where you see yourself on income distribution. % answering 2 "
lab var scalepoorrichnow_fac3  "[LB] Scale of where you see yourself on income distribution. % answering 3 "
lab var scalepoorrichnow_fac4  "[LB] Scale of where you see yourself on income distribution. % answering 4 "
lab var scalepoorrichnow_fac5  "[LB] Scale of where you see yourself on income distribution. % answering 5 "
lab var scalepoorrichnow_fac6  "[LB] Scale of where you see yourself on income distribution. % answering 6 "
lab var scalepoorrichnow_fac7  "[LB] Scale of where you see yourself on income distribution. % answering 7 "
lab var scalepoorrichnow_fac8  "[LB] Scale of where you see yourself on income distribution. % answering 8 "
lab var scalepoorrichnow_fac9  "[LB] Scale of where you see yourself on income distribution. % answering 9 "
lab var scalepoorrichnow_fac10 "[LB] Scale of where you see yourself on income distribution. % answering 10 (Top) "

gen year=2009
 
tempfile lb09
save `lb09', replace

/*LB 2008*/
use "Latinobarometro_2008.dta", clear
rename idenpa Country
 
keep Country p2st p3st p4st p5st p6st p7st p9st p12st_a p12st_b p12st_c P20STB ///
  p22st_b p25st p27st p72st_d p73st p75n s4a s4b wt

foreach v of varlist p3st p4st p5st p6st p7st P20STB p22st_b p25st p27st p72st_d ///
 p73st p75n s4a s4b {

	replace `v'=. if `v'<1 | `v'==8

}

foreach v of varlist p12st_a p12st_b p12st_c {

	replace `v'=. if `v'==98 | `v'==00 | `v'<1
	
}

foreach v of varlist p3st-s4b {
	local l`v' : variable label `v'
		if `"`l`v''"' == "" {
		local l`v' "`v'"
	}
}

local list "p3st p4st p5st p6st p7st p9st p12st_a p12st_b p12st_c P20STB p22st_b p25st p27st p72st_d p73st p75n  s4a s4b"

foreach var of local list {
	levelsof `var', local(`var'_levels)
	foreach val of local `var'_levels {
		local `var'vl`val' : label `var' `val'
	}
}

rename (p3st p4st p5st p6st p7st p9st p12st_a p12st_b p12st_c P20STB p22st_b ///
 p25st p27st p72st_d p73st p75n  s4a) (countryprogress econsitnow econsitpast ///
 econsitfuture econsitpersonalnow countryproblem scalepoorrichnow scalepoorrichpast ///
 scalepoorrichfuture citizenspaytaxes econfunction benofpowerful lifesatisfaction ///
 corruptact corruptprogress polofficcorrupt lackutilities)
 
foreach v of varlist countryprogress-lackutilities {

	tab `v', gen(`v'_fac)

}

collapse countryprogress-lackutilities_fac2 [pweight=wt], by(Country)

foreach v of varlist countryprogress-lackutilities_fac2 {

	label var `v' "[LB] `l`v''"
}

 foreach variable of local list {
	 foreach value of local `var'_levels{
		 label variable `variable'`value' "`l`variable'': `yearvl`value''"
	 }
}

lab var lifesatisfaction_fac1 "[LB] How satisfied are you with your life? % answering  1 (Very) "
lab var lifesatisfaction_fac2 "[LB] How satisfied are you with your life? % answering  2 (Quite) "
lab var lifesatisfaction_fac3 "[LB] How satisfied are you with your life? % answering  3 (Not very) "
lab var lifesatisfaction_fac4 "[LB] How satisfied are you with your life? % answering  4 (Not at all) "

lab var countryprogress_fac1 "[LB] What is the state of progress in [country]? % answering  1 (Progressing) "
lab var countryprogress_fac2 "[LB] What is the state of progress in [country]? % answering  2 (Standstill) "
lab var countryprogress_fac3 "[LB] What is the state of progress in [country]? % answering  3 (Declining) "

lab var econsitnow_fac1 "[LB] What is the country's economic situation? % answering  1 (Very good) "
lab var econsitnow_fac2 "[LB] What is the country's economic situation? % answering  2 (Good) "
lab var econsitnow_fac3 "[LB] What is the country's economic situation? % answering  3 (About average) "
lab var econsitnow_fac4 "[LB] What is the country's economic situation? % answering  4 (Bad) "
lab var econsitnow_fac5 "[LB] What is the country's economic situation? % answering  5 (Very bad) "

lab var econsitpast_fac1 "[LB] What was the country's economic situation a year ago? % answering  1 (Much better) "
lab var econsitpast_fac2 "[LB] What was the country's economic situation a year ago? % answering  2 (A little better) "
lab var econsitpast_fac3 "[LB] What was the country's economic situation a year ago? % answering  3 (The same) "
lab var econsitpast_fac4 "[LB] What was the country's economic situation a year ago? % answering  4 (A little worse) "
lab var econsitpast_fac5 "[LB] What was the country's economic situation a year ago? % answering  5 (Much worse) "

lab var econsitfuture_fac1 "[LB] What will be the country's economic situation in a year? % answering  1 (Much better) "
lab var econsitfuture_fac2 "[LB] What will be the country's economic situation in a year? % answering  2 (A little better) "
lab var econsitfuture_fac3 "[LB] What will be the country's economic situation in a year? % answering  3 (The same) "
lab var econsitfuture_fac4 "[LB] What will be the country's economic situation in a year? % answering  4 (A little worse) "
lab var econsitfuture_fac5 "[LB] What will be the country's economic situation in a year? % answering  5 (Much worse) "

lab var econfunction_fac1 "[LB] How satisfied are you with the country's economy? % answering 1 (Very) "
lab var econfunction_fac2 "[LB] How satisfied are you with the country's economy? % answering 2 (Quite) "
lab var econfunction_fac3 "[LB] How satisfied are you with the country's economy? % answering 3 (Not very) "
lab var econfunction_fac4 "[LB] How satisfied are you with the country's economy? % answering 4 (Not at all) "

lab var scalepoorrichnow_fac1  "[LB] Scale of where you see yourself on income distribution. % answering 1 (Bottom) "
lab var scalepoorrichnow_fac2  "[LB] Scale of where you see yourself on income distribution. % answering 2 "
lab var scalepoorrichnow_fac3  "[LB] Scale of where you see yourself on income distribution. % answering 3 "
lab var scalepoorrichnow_fac4  "[LB] Scale of where you see yourself on income distribution. % answering 4 "
lab var scalepoorrichnow_fac5  "[LB] Scale of where you see yourself on income distribution. % answering 5 "
lab var scalepoorrichnow_fac6  "[LB] Scale of where you see yourself on income distribution. % answering 6 "
lab var scalepoorrichnow_fac7  "[LB] Scale of where you see yourself on income distribution. % answering 7 "
lab var scalepoorrichnow_fac8  "[LB] Scale of where you see yourself on income distribution. % answering 8 "
lab var scalepoorrichnow_fac9  "[LB] Scale of where you see yourself on income distribution. % answering 9 "
lab var scalepoorrichnow_fac10 "[LB] Scale of where you see yourself on income distribution. % answering 10 (Top) "
 
gen year=2008
 
tempfile lb08
save `lb08', replace

/*LB 2007*/
use "Latinobarometro_2007.dta", clear
rename idenpa Country

keep Country p1st p2st p3st p6stma p6stmb p6stmc p7st p13stb p17st P19NB p32ncc ///
 p54sta p54stb p54stc p54std p71st_b p90na p92stb p93st p94st p95st_a p97n p100st ///
 s3na s3nb wt

foreach v of varlist p1st p2st p3st p13stb p17st P19NB p32ncc p54sta p54stb ///
  p54stc p54std p71st_b p90na p92stb p93st p94st s3na s3nb p97n p100st {

	replace `v'=. if `v'<1 | `v'==8

}

foreach v of varlist p6stma p6stmb p6stmc p93st p95st_a {

	replace `v'=. if `v'==98 | `v'==00 | `v'==101 | `v'==102 | `v'==103 | `v'<1

}
 
  foreach v of varlist p1st-s3nb {
	local l`v' : variable label `v'
		if `"`l`v''"' == "" {
		local l`v' "`v'"
	}
}

local list "p1st p2st p3st p6stma p6stmb p6stmc p7st p13stb p17st P19NB p32ncc p54sta p54stb p54stc p54std  p71st_b p90na p92stb p93st p94st p95st_a p97n p100st s3na s3nb"

foreach var of local list {
	levelsof `var', local(`var'_levels)
	foreach val of local `var'_levels {
		local `var'vl`val' : label `var' `val'
	}
}

rename (p1st p2st p3st p6stma p6stmb p6stmc p7st p13stb p17st P19NB p32ncc ///
 p54sta p54stb p54stc p54std  p71st_b p90na p92stb p93st p94st p95st_a p97n p100st ///
 s3na) (lifesatisfaction econsitfuture econfunction scalepoorrichnow ///
 scalepoorrichpast scalepoorrichfuture countryproblem govtpromwelfare incdisfair ///
 citizenspaytaxes fightpoverty privatizationben mkteconnecessary mkteconbest ///
 developpvtent corruptact richpoorconflict avoidtaxes scalepplpaytaxes taxlevel ///
 bribejustified pubadminforppl econsitnow lackutilities)
 
foreach v of varlist lifesatisfaction-lackutilities {

	tab `v', gen(`v'_fac)

}

collapse lifesatisfaction-lackutilities_fac2 [pweight=wt], by(Country)

foreach v of varlist lifesatisfaction-lackutilities_fac2 {

	label var `v' "[LB] `l`v''"
}

 foreach variable of local list {
	 foreach value of local `var'_levels{
		 label variable `variable'`value' "`l`variable'': `yearvl`value''"
	 }
}

lab var lifesatisfaction_fac1 "[LB] How satisfied are you with your life? % answering  1 (Very) "
lab var lifesatisfaction_fac2 "[LB] How satisfied are you with your life? % answering  2 (Quite) "
lab var lifesatisfaction_fac3 "[LB] How satisfied are you with your life? % answering  3 (Not very) "
lab var lifesatisfaction_fac4 "[LB] How satisfied are you with your life? % answering  4 (Not at all) "

lab var econsitnow_fac1 "[LB] What is the country's economic situation? % answering  1 (Very good) "
lab var econsitnow_fac2 "[LB] What is the country's economic situation? % answering  2 (Good) "
lab var econsitnow_fac3 "[LB] What is the country's economic situation? % answering  3 (About average) "
lab var econsitnow_fac4 "[LB] What is the country's economic situation? % answering  4 (Bad) "
lab var econsitnow_fac5 "[LB] What is the country's economic situation? % answering  5 (Very bad) "

lab var econsitfuture_fac1 "[LB] What will be the country's economic situation in a year? % answering  1 (Much better) "
lab var econsitfuture_fac2 "[LB] What will be the country's economic situation in a year? % answering  2 (A little better) "
lab var econsitfuture_fac3 "[LB] What will be the country's economic situation in a year? % answering  3 (The same) "
lab var econsitfuture_fac4 "[LB] What will be the country's economic situation in a year? % answering  4 (A little worse) "
lab var econsitfuture_fac5 "[LB] What will be the country's economic situation in a year? % answering  5 (Much worse) "

lab var econfunction_fac1 "[LB] How satisfied are you with the country's economy? % answering 1 (Very) "
lab var econfunction_fac2 "[LB] How satisfied are you with the country's economy? % answering 2 (Quite) "
lab var econfunction_fac3 "[LB] How satisfied are you with the country's economy? % answering 3 (Not very) "
lab var econfunction_fac4 "[LB] How satisfied are you with the country's economy? % answering 4 (Not at all) "

lab var incdisfair_fac1 "[LB] How fair is the income distribution? % answering 1 (Very fair) "
lab var incdisfair_fac2 "[LB] How fair is the income distribution? % answering 2 (Fair) "
lab var incdisfair_fac3 "[LB] How fair is the income distribution? % answering 3 (Unfair) "
lab var incdisfair_fac4 "[LB] How fair is the income distribution? % answering 4 (Very unfair) "

lab var scalepoorrichnow_fac1  "[LB] Scale of where you see yourself on income distribution. % answering 1 (Bottom) "
lab var scalepoorrichnow_fac2  "[LB] Scale of where you see yourself on income distribution. % answering 2 "
lab var scalepoorrichnow_fac3  "[LB] Scale of where you see yourself on income distribution. % answering 3 "
lab var scalepoorrichnow_fac4  "[LB] Scale of where you see yourself on income distribution. % answering 4 "
lab var scalepoorrichnow_fac5  "[LB] Scale of where you see yourself on income distribution. % answering 5 "
lab var scalepoorrichnow_fac6  "[LB] Scale of where you see yourself on income distribution. % answering 6 "
lab var scalepoorrichnow_fac7  "[LB] Scale of where you see yourself on income distribution. % answering 7 "
lab var scalepoorrichnow_fac8  "[LB] Scale of where you see yourself on income distribution. % answering 8 "
lab var scalepoorrichnow_fac9  "[LB] Scale of where you see yourself on income distribution. % answering 9 "
lab var scalepoorrichnow_fac10 "[LB] Scale of where you see yourself on income distribution. % answering 10 (Top) " 
 
gen year=2007
 
tempfile lb07
save `lb07', replace

/*LB 2006*/
use "Latinobarometro_2006.dta", clear
rename idenpa Country

keep Country p1st_a p2st p3st p4st p5st p10st p11st p13st_a p13st_b p13st_c p16n ///
 p20stm p22st_b p31stm p33st p42st wt

foreach v of varlist p1st_a p2st p3st p4st p5st p11st p42st {

	replace `v'=. if `v'<1 | `v'==8

}

foreach v of varlist p13st_a p13st_b p13st_c p16n p20stm p22st_b p31stm p33st {


	replace `v'=. if `v'<1

}
 
 
  foreach v of varlist p1st_a-p42st {
	local l`v' : variable label `v'
		if `"`l`v''"' == "" {
		local l`v' "`v'"
	}
}

local list "p1st_a p2st p3st p4st p5st p10st p11st p13st_a p13st_b p13st_c p16n p20stm p22st_b p31stm p33st p42st"

foreach var of local list {
	levelsof `var', local(`var'_levels)
	foreach val of local `var'_levels {
		local `var'vl`val' : label `var' `val'
	}
}

rename (p1st_a-p42st) (lifesatisfaction econsitnow econsitpast econsitfuture ///
 econsitpersonalnow countryproblem timetodevelop scalepoorrichnow scalepoorrichpast ///
 scalepoorrichfuture scalestvspvt benofpowerful govtpromwelfare econfunction ///
 corruptprogress bribeinpreselection)
 
foreach v of varlist lifesatisfaction-bribeinpreselection {

	tab `v', gen(`v'_fac)

}

collapse lifesatisfaction-bribeinpreselection_fac2 [pweight=wt], by(Country)

foreach v of varlist lifesatisfaction-bribeinpreselection {

	label var `v' "[LB] `l`v''"
}

 foreach variable of local list {
	 foreach value of local `var'_levels{
		 label variable `variable'`value' "`l`variable'': `yearvl`value''"
	 }
}
 
lab var lifesatisfaction_fac1 "[LB] How satisfied are you with your life? % answering  1 (Very) "
lab var lifesatisfaction_fac2 "[LB] How satisfied are you with your life? % answering  2 (Quite) "
lab var lifesatisfaction_fac3 "[LB] How satisfied are you with your life? % answering  3 (Not very) "
lab var lifesatisfaction_fac4 "[LB] How satisfied are you with your life? % answering  4 (Not at all) "

lab var econsitnow_fac1 "[LB] What is the country's economic situation? % answering  1 (Very good) "
lab var econsitnow_fac2 "[LB] What is the country's economic situation? % answering  2 (Good) "
lab var econsitnow_fac3 "[LB] What is the country's economic situation? % answering  3 (About average) "
lab var econsitnow_fac4 "[LB] What is the country's economic situation? % answering  4 (Bad) "
lab var econsitnow_fac5 "[LB] What is the country's economic situation? % answering  5 (Very bad) "

lab var econsitpast_fac1 "[LB] What was the country's economic situation a year ago? % answering  1 (Much better) "
lab var econsitpast_fac2 "[LB] What was the country's economic situation a year ago? % answering  2 (A little better) "
lab var econsitpast_fac3 "[LB] What was the country's economic situation a year ago? % answering  3 (The same) "
lab var econsitpast_fac4 "[LB] What was the country's economic situation a year ago? % answering  4 (A little worse) "
lab var econsitpast_fac5 "[LB] What was the country's economic situation a year ago? % answering  5 (Much worse) "

lab var econsitfuture_fac1 "[LB] What will be the country's economic situation in a year? % answering  1 (Much better) "
lab var econsitfuture_fac2 "[LB] What will be the country's economic situation in a year? % answering  2 (A little better) "
lab var econsitfuture_fac3 "[LB] What will be the country's economic situation in a year? % answering  3 (The same) "
lab var econsitfuture_fac4 "[LB] What will be the country's economic situation in a year? % answering  4 (A little worse) "
lab var econsitfuture_fac5 "[LB] What will be the country's economic situation in a year? % answering  5 (Much worse) "

lab var econfunction_fac1 "[LB] How satisfied are you with the country's economy? % answering 1 (Very) "
lab var econfunction_fac2 "[LB] How satisfied are you with the country's economy? % answering 2 (Quite) "
lab var econfunction_fac3 "[LB] How satisfied are you with the country's economy? % answering 3 (Not very) "
lab var econfunction_fac4 "[LB] How satisfied are you with the country's economy? % answering 4 (Not at all) "

lab var scalepoorrichnow_fac1  "[LB] Scale of where you see yourself on income distribution. % answering 1 (Bottom) "
lab var scalepoorrichnow_fac2  "[LB] Scale of where you see yourself on income distribution. % answering 2 "
lab var scalepoorrichnow_fac3  "[LB] Scale of where you see yourself on income distribution. % answering 3 "
lab var scalepoorrichnow_fac4  "[LB] Scale of where you see yourself on income distribution. % answering 4 "
lab var scalepoorrichnow_fac5  "[LB] Scale of where you see yourself on income distribution. % answering 5 "
lab var scalepoorrichnow_fac6  "[LB] Scale of where you see yourself on income distribution. % answering 6 "
lab var scalepoorrichnow_fac7  "[LB] Scale of where you see yourself on income distribution. % answering 7 "
lab var scalepoorrichnow_fac8  "[LB] Scale of where you see yourself on income distribution. % answering 8 "
lab var scalepoorrichnow_fac9  "[LB] Scale of where you see yourself on income distribution. % answering 9 "
lab var scalepoorrichnow_fac10 "[LB] Scale of where you see yourself on income distribution. % answering 10 (Top) "
 
gen year=2006
 
tempfile lb06
save `lb06', replace

/*LB 2005*/
use "Latinobarometro_2005.dta", clear
rename idenpa Country

keep Country p1st p2st p3st p4st p5st p8st p10st p11st p25sta p30st p40std ///
 p40ste p53st p77st p78st p79st p80st p82stb p83st p95st wt

foreach v of varlist p1st p2st p3st p4st p5st p10st p11st p25sta p30st p40std ///
 p40ste p53st p77st p78st p79st p80st p82stb p83st p95st {

	replace `v'=. if `v'<1

}
 
   foreach v of varlist p1st-p95st {
	local l`v' : variable label `v'
		if `"`l`v''"' == "" {
		local l`v' "`v'"
	}
}

local list "p1st p2st p3st p4st p5st p8st p10st p11st p25sta p30st p40std p40ste p53st p77st p78st p79st p80st p82stb p83st p95st"

foreach var of local list {
	levelsof `var', local(`var'_levels)
	foreach val of local `var'_levels {
		local `var'vl`val' : label `var' `val'
	}
}

rename (p1st-p95st) (lifesatisfaction econsitnow econsitpast econsitfuture ///
 econsitpersonalnow countryproblem timetodevelop countryprogress mkteconnecessary ///
 pubinstfunction trustgovt developpvtent econfunction taxlevel VATfrequency ///
 taxfaircollect scaleavoidtaxes corruptact corruptprogress scalepoorrichpast)
 
foreach v of varlist lifesatisfaction-scalepoorrichpast {

	tab `v', gen(`v'_fac)

}

collapse lifesatisfaction-scalepoorrichpast_fac10 [pweight=wt], by(Country)

foreach v of varlist lifesatisfaction-scalepoorrichpast_fac10 {

	label var `v' "[LB] `l`v''"
}

 foreach variable of local list {
	 foreach value of local `var'_levels{
		 label variable `variable'`value' "`l`variable'': `yearvl`value''"
	 }
}

lab var lifesatisfaction_fac1 "[LB] How satisfied are you with your life? % answering  1 (Very) "
lab var lifesatisfaction_fac2 "[LB] How satisfied are you with your life? % answering  2 (Quite) "
lab var lifesatisfaction_fac3 "[LB] How satisfied are you with your life? % answering  3 (Not very) "
lab var lifesatisfaction_fac4 "[LB] How satisfied are you with your life? % answering  4 (Not at all) "

lab var countryprogress_fac1 "[LB] What is the state of progress in [country]? % answering  1 (Progressing) "
lab var countryprogress_fac2 "[LB] What is the state of progress in [country]? % answering  2 (Standstill) "
lab var countryprogress_fac3 "[LB] What is the state of progress in [country]? % answering  3 (Declining) "

lab var econsitnow_fac1 "[LB] What is the country's economic situation? % answering  1 (Very good) "
lab var econsitnow_fac2 "[LB] What is the country's economic situation? % answering  2 (Good) "
lab var econsitnow_fac3 "[LB] What is the country's economic situation? % answering  3 (About average) "
lab var econsitnow_fac4 "[LB] What is the country's economic situation? % answering  4 (Bad) "
lab var econsitnow_fac5 "[LB] What is the country's economic situation? % answering  5 (Very bad) "

lab var econsitpast_fac1 "[LB] What was the country's economic situation a year ago? % answering  1 (Much better) "
lab var econsitpast_fac2 "[LB] What was the country's economic situation a year ago? % answering  2 (A little better) "
lab var econsitpast_fac3 "[LB] What was the country's economic situation a year ago? % answering  3 (The same) "
lab var econsitpast_fac4 "[LB] What was the country's economic situation a year ago? % answering  4 (A little worse) "
lab var econsitpast_fac5 "[LB] What was the country's economic situation a year ago? % answering  5 (Much worse) "

lab var econsitfuture_fac1 "[LB] What will be the country's economic situation in a year? % answering  1 (Much better) "
lab var econsitfuture_fac2 "[LB] What will be the country's economic situation in a year? % answering  2 (A little better) "
lab var econsitfuture_fac3 "[LB] What will be the country's economic situation in a year? % answering  3 (The same) "
lab var econsitfuture_fac4 "[LB] What will be the country's economic situation in a year? % answering  4 (A little worse) "
lab var econsitfuture_fac5 "[LB] What will be the country's economic situation in a year? % answering  5 (Much worse) "

lab var scaleavoidtaxes_fac1  "[LB] How justified is tax evasion? % answering 1 (not at all justified) "
lab var scaleavoidtaxes_fac2  "[LB] How justified is tax evasion? % answering 2 "
lab var scaleavoidtaxes_fac3  "[LB] How justified is tax evasion? % answering 3 "
lab var scaleavoidtaxes_fac4  "[LB] How justified is tax evasion? % answering 4 "
lab var scaleavoidtaxes_fac5  "[LB] How justified is tax evasion? % answering 5 "
lab var scaleavoidtaxes_fac6  "[LB] How justified is tax evasion? % answering 6 "
lab var scaleavoidtaxes_fac7  "[LB] How justified is tax evasion? % answering 7 "
lab var scaleavoidtaxes_fac8  "[LB] How justified is tax evasion? % answering 8 "
lab var scaleavoidtaxes_fac9  "[LB] How justified is tax evasion? % answering 9 "
lab var scaleavoidtaxes_fac10 "[LB] How justified is tax evasion? % answering 10 (totally justified) "

lab var econfunction_fac1 "[LB] How satisfied are you with the country's economy? % answering 1 (Very) "
lab var econfunction_fac2 "[LB] How satisfied are you with the country's economy? % answering 2 (Quite) "
lab var econfunction_fac3 "[LB] How satisfied are you with the country's economy? % answering 3 (Not very) "
lab var econfunction_fac4 "[LB] How satisfied are you with the country's economy? % answering 4 (Not at all) "

gen year=2005

tempfile lb05
save `lb05', replace

/*LB 2004*/
use "Latinobarometro_2004.dta"
rename idenpa Country

keep Country p1st p2st p3st p4st p5st p9sta p9stb p9stc p10st p24wvs p27nd p49st ///
 p50sta-p50sti p51stb p54st p55n p56na p56nb p56nc p58st wt

foreach v of varlist p1st p2st p3st p4st p5st p9sta p9stb p9stc p24wvs p27nd ///
 p49st p51stb p54st p55n p56na p56nb p56nc p58st {

	replace `v'=. if `v'<1

}
 
foreach v of varlist p50sta-p50sti {

	replace `v'=. if `v'<0

} 

    foreach v of varlist p1st-p58st {
	local l`v' : variable label `v'
		if `"`l`v''"' == "" {
		local l`v' "`v'"
	}
}

local list "p1st p2st p3st p4st p5st p9sta p9stb p9stc p10st p24wvs p27nd p49st p50sta p50stb p50stc p50std p50ste p50stf p50stg p50sth p50sti p51stb p54st p55n p56na p56nb p56nc p58st"

foreach var of local list {
	levelsof `var', local(`var'_levels)
	foreach val of local `var'_levels {
		local `var'vl`val' : label `var' `val'
	}
}

rename (p1st-p58st) (lifesatisfaction econsitnow econsitpast econsitfuture ///
 econsitpersonalnow scalepoorrichnow scalepoorrichpast scalepoorrichfuture ///
 countryproblem benofpowerful developpvtent VATfrequency rnopaydishonesty ///
 rnopaysly rnopaynopt rnopaylackcivic rnopaynomeans rnopayillspent rnopaytoohigh ///
 rnopaycorrupt rnopayother corruptact corruptprogress endcorrupttime prbribepolice ///
 prbribejudge prbribeminister econfunction)
 
foreach v of varlist lifesatisfaction-econfunction {

	tab `v', gen(`v'_fac)

}

collapse lifesatisfaction-econfunction_fac4 [pweight=wt], by(Country)

foreach v of varlist lifesatisfaction-econfunction_fac4 {

	label var `v' "[LB] `l`v''"
}

 foreach variable of local list {
	 foreach value of local `var'_levels{
		 label variable `variable'`value' "`l`variable'': `yearvl`value''"
	 }
}

lab var lifesatisfaction_fac1 "[LB] How satisfied are you with your life? % answering  1 (Very) "
lab var lifesatisfaction_fac2 "[LB] How satisfied are you with your life? % answering  2 (Quite) "
lab var lifesatisfaction_fac3 "[LB] How satisfied are you with your life? % answering  3 (Not very) "
lab var lifesatisfaction_fac4 "[LB] How satisfied are you with your life? % answering  4 (Not at all) "

lab var econsitnow_fac1 "[LB] What is the country's economic situation? % answering  1 (Very good) "
lab var econsitnow_fac2 "[LB] What is the country's economic situation? % answering  2 (Good) "
lab var econsitnow_fac3 "[LB] What is the country's economic situation? % answering  3 (About average) "
lab var econsitnow_fac4 "[LB] What is the country's economic situation? % answering  4 (Bad) "
lab var econsitnow_fac5 "[LB] What is the country's economic situation? % answering  5 (Very bad) "

lab var econsitpast_fac1 "[LB] What was the country's economic situation a year ago? % answering  1 (Much better) "
lab var econsitpast_fac2 "[LB] What was the country's economic situation a year ago? % answering  2 (A little better) "
lab var econsitpast_fac3 "[LB] What was the country's economic situation a year ago? % answering  3 (The same) "
lab var econsitpast_fac4 "[LB] What was the country's economic situation a year ago? % answering  4 (A little worse) "
lab var econsitpast_fac5 "[LB] What was the country's economic situation a year ago? % answering  5 (Much worse) "

lab var econsitfuture_fac1 "[LB] What will be the country's economic situation in a year? % answering  1 (Much better) "
lab var econsitfuture_fac2 "[LB] What will be the country's economic situation in a year? % answering  2 (A little better) "
lab var econsitfuture_fac3 "[LB] What will be the country's economic situation in a year? % answering  3 (The same) "
lab var econsitfuture_fac4 "[LB] What will be the country's economic situation in a year? % answering  4 (A little worse) "
lab var econsitfuture_fac5 "[LB] What will be the country's economic situation in a year? % answering  5 (Much worse) "

lab var econfunction_fac1 "[LB] How satisfied are you with the country's economy? % answering 1 (Very) "
lab var econfunction_fac2 "[LB] How satisfied are you with the country's economy? % answering 2 (Quite) "
lab var econfunction_fac3 "[LB] How satisfied are you with the country's economy? % answering 3 (Not very) "
lab var econfunction_fac4 "[LB] How satisfied are you with the country's economy? % answering 4 (Not at all) "

lab var scalepoorrichnow_fac1  "[LB] Scale of where you see yourself on income distribution. % answering 1 (Bottom) "
lab var scalepoorrichnow_fac2  "[LB] Scale of where you see yourself on income distribution. % answering 2 "
lab var scalepoorrichnow_fac3  "[LB] Scale of where you see yourself on income distribution. % answering 3 "
lab var scalepoorrichnow_fac4  "[LB] Scale of where you see yourself on income distribution. % answering 4 "
lab var scalepoorrichnow_fac5  "[LB] Scale of where you see yourself on income distribution. % answering 5 "
lab var scalepoorrichnow_fac6  "[LB] Scale of where you see yourself on income distribution. % answering 6 "
lab var scalepoorrichnow_fac7  "[LB] Scale of where you see yourself on income distribution. % answering 7 "
lab var scalepoorrichnow_fac8  "[LB] Scale of where you see yourself on income distribution. % answering 8 "
lab var scalepoorrichnow_fac9  "[LB] Scale of where you see yourself on income distribution. % answering 9 "
lab var scalepoorrichnow_fac10 "[LB] Scale of where you see yourself on income distribution. % answering 10 (Top) "

gen year=2004
 
tempfile lb04
save `lb04', replace

/*LB 2003*/
use "Latinobarometro_2003.dta"
rename idenpa Country

keep Country p1st p2st p3st p4st p8st p11st p19st p22n_f p28n p29n p30na p30nb ///
 p66stb p75stb p77n wt

foreach v of varlist p1st p2st p3st p4st p11st p19st p22n_f p28n p29n p30na ///
 p30nb p66stb p75stb p77n {

	replace `v'=. if `v'<1

} 
 
    foreach v of varlist p1st-p77n {
	local l`v' : variable label `v'
		if `"`l`v''"' == "" {
		local l`v' "`v'"
	}
}

local list "p1st p2st p3st p4st p8st p11st p19st p22n_f p28n p29n p30na p30nb p66stb p75stb p77n"

foreach var of local list {
	levelsof `var', local(`var'_levels)
	foreach val of local `var'_levels {
		local `var'vl`val' : label `var' `val'
	}
}

rename (p1st-p77n) (econsitnow econsitpast econsitfuture econsitpersonalnow ///
 countryproblem econfunction lifesatisfaction mkteconnecessary taxlevel ///
 VATfrequency taxfaircollect taxesspentwell scaleavoidtaxes corruptact ///
 corruptprogress)
 
foreach v of varlist econsitnow-corruptprogress {

	tab `v', gen(`v'_fac)

}

collapse econsitnow-corruptprogress_fac4 [pweight=wt], by(Country)

foreach v of varlist econsitnow-corruptprogress_fac4 {

	label var `v' "[LB] `l`v''"
}

 foreach variable of local list {
	 foreach value of local `var'_levels{
		 label variable `variable'`value' "`l`variable'': `yearvl`value''"
	 }
}

lab var lifesatisfaction_fac1 "[LB] How satisfied are you with your life? % answering  1 (Very) "
lab var lifesatisfaction_fac2 "[LB] How satisfied are you with your life? % answering  2 (Quite) "
lab var lifesatisfaction_fac3 "[LB] How satisfied are you with your life? % answering  3 (Not very) "
lab var lifesatisfaction_fac4 "[LB] How satisfied are you with your life? % answering  4 (Not at all) "

lab var econsitnow_fac1 "[LB] What is the country's economic situation? % answering  1 (Very good) "
lab var econsitnow_fac2 "[LB] What is the country's economic situation? % answering  2 (Good) "
lab var econsitnow_fac3 "[LB] What is the country's economic situation? % answering  3 (About average) "
lab var econsitnow_fac4 "[LB] What is the country's economic situation? % answering  4 (Bad) "
lab var econsitnow_fac5 "[LB] What is the country's economic situation? % answering  5 (Very bad) "

lab var econsitpast_fac1 "[LB] What was the country's economic situation a year ago? % answering  1 (Much better) "
lab var econsitpast_fac2 "[LB] What was the country's economic situation a year ago? % answering  2 (A little better) "
lab var econsitpast_fac3 "[LB] What was the country's economic situation a year ago? % answering  3 (The same) "
lab var econsitpast_fac4 "[LB] What was the country's economic situation a year ago? % answering  4 (A little worse) "
lab var econsitpast_fac5 "[LB] What was the country's economic situation a year ago? % answering  5 (Much worse) "

lab var econsitfuture_fac1 "[LB] What will be the country's economic situation in a year? % answering  1 (Much better) "
lab var econsitfuture_fac2 "[LB] What will be the country's economic situation in a year? % answering  2 (A little better) "
lab var econsitfuture_fac3 "[LB] What will be the country's economic situation in a year? % answering  3 (The same) "
lab var econsitfuture_fac4 "[LB] What will be the country's economic situation in a year? % answering  4 (A little worse) "
lab var econsitfuture_fac5 "[LB] What will be the country's economic situation in a year? % answering  5 (Much worse) "

lab var scaleavoidtaxes_fac1  "[LB] How justified is tax evasion? % answering 1 (not at all justified) "
lab var scaleavoidtaxes_fac2  "[LB] How justified is tax evasion? % answering 2 "
lab var scaleavoidtaxes_fac3  "[LB] How justified is tax evasion? % answering 3 "
lab var scaleavoidtaxes_fac4  "[LB] How justified is tax evasion? % answering 4 "
lab var scaleavoidtaxes_fac5  "[LB] How justified is tax evasion? % answering 5 "
lab var scaleavoidtaxes_fac6  "[LB] How justified is tax evasion? % answering 6 "
lab var scaleavoidtaxes_fac7  "[LB] How justified is tax evasion? % answering 7 "
lab var scaleavoidtaxes_fac8  "[LB] How justified is tax evasion? % answering 8 "
lab var scaleavoidtaxes_fac9  "[LB] How justified is tax evasion? % answering 9 "
lab var scaleavoidtaxes_fac10 "[LB] How justified is tax evasion? % answering 10 (totally justified) "

lab var econfunction_fac1 "[LB] How satisfied are you with the country's economy? % answering 1 (Very) "
lab var econfunction_fac2 "[LB] How satisfied are you with the country's economy? % answering 2 (Quite) "
lab var econfunction_fac3 "[LB] How satisfied are you with the country's economy? % answering 3 (Not very) "
lab var econfunction_fac4 "[LB] How satisfied are you with the country's economy? % answering 4 (Not at all) "

gen year=2003
 
tempfile lb03
save `lb03', replace

/*LB 2002*/
use "Latinobarometro_2002.dta", clear
rename idenpa Country

keep Country p1wvs p2sta p2stb p2stc p2std p4st p6stc p8stb p16st p20no2 p22essf ///
 p23st p49stb p52wvsb wt

foreach v of varlist p1wvs p2sta p2stb p2stc p2std p6stc p8stb p16st p20no2 ///
 p22essf p23st p49stb p52wvsb  {
	replace `v'=. if `v'<1
} 
 
foreach v of varlist p1wvs-p52wvsb {
	local l`v' : variable label `v'
		if `"`l`v''"' == "" {
		local l`v' "`v'"
	}
}
 
local list "p1wvs p2sta p2stb p2stc p2std p4st p6stc p8stb p16st p20no2 p22essf p23st p49stb p52wvsb"
 
foreach var of local list {
	levelsof `var', local(`var'_levels)
	foreach val of local `var'_levels {
		local `var'vl`val' : label `var' `val'
	}
}

/*Question p1wvs about happiness is recoded as lifesatisfaction*/
rename (p1wvs-p52wvsb) (lifesatisfaction econsitnow econsitpast econsitfuture ///
 econsitpersonalnow countryproblem corruptionchange corruptact incdisfair ///
 timetodevelop taxesvswelfare econfunction avoidtaxes bribejustified)

foreach v of varlist lifesatisfaction-bribejustified {

	tab `v', gen(`v'_fac)

}

collapse lifesatisfaction-bribejustified_fac10 [pweight=wt], by(Country)

foreach v of varlist lifesatisfaction-bribejustified_fac10 {

	label var `v' "[LB] `l`v''"
}

 foreach variable of local list {
	 foreach value of local `var'_levels{
		 label variable `variable'`value' "`l`variable'': `yearvl`value''"
	 }
}

lab var lifesatisfaction_fac1 "[LB] How satisfied are you with your life? % answering  1 (Very) "
lab var lifesatisfaction_fac2 "[LB] How satisfied are you with your life? % answering  2 (Quite) "
lab var lifesatisfaction_fac3 "[LB] How satisfied are you with your life? % answering  3 (Not very) "
lab var lifesatisfaction_fac4 "[LB] How satisfied are you with your life? % answering  4 (Not at all) "

lab var econsitnow_fac1 "[LB] What is the country's economic situation? % answering  1 (Very good) "
lab var econsitnow_fac2 "[LB] What is the country's economic situation? % answering  2 (Good) "
lab var econsitnow_fac3 "[LB] What is the country's economic situation? % answering  3 (About average) "
lab var econsitnow_fac4 "[LB] What is the country's economic situation? % answering  4 (Bad) "
lab var econsitnow_fac5 "[LB] What is the country's economic situation? % answering  5 (Very bad) "

lab var econsitpast_fac1 "[LB] What was the country's economic situation a year ago? % answering  1 (Much better) "
lab var econsitpast_fac2 "[LB] What was the country's economic situation a year ago? % answering  2 (A little better) "
lab var econsitpast_fac3 "[LB] What was the country's economic situation a year ago? % answering  3 (The same) "
lab var econsitpast_fac4 "[LB] What was the country's economic situation a year ago? % answering  4 (A little worse) "
lab var econsitpast_fac5 "[LB] What was the country's economic situation a year ago? % answering  5 (Much worse) "

lab var econsitfuture_fac1 "[LB] What will be the country's economic situation in a year? % answering  1 (Much better) "
lab var econsitfuture_fac2 "[LB] What will be the country's economic situation in a year? % answering  2 (A little better) "
lab var econsitfuture_fac3 "[LB] What will be the country's economic situation in a year? % answering  3 (The same) "
lab var econsitfuture_fac4 "[LB] What will be the country's economic situation in a year? % answering  4 (A little worse) "
lab var econsitfuture_fac5 "[LB] What will be the country's economic situation in a year? % answering  5 (Much worse) "

lab var econfunction_fac1 "[LB] How satisfied are you with the country's economy? % answering 1 (Very) "
lab var econfunction_fac2 "[LB] How satisfied are you with the country's economy? % answering 2 (Quite) "
lab var econfunction_fac3 "[LB] How satisfied are you with the country's economy? % answering 3 (Not very) "
lab var econfunction_fac4 "[LB] How satisfied are you with the country's economy? % answering 4 (Not at all) "

lab var incdisfair_fac1 "[LB] How fair is the income distribution? % answering 1 (Very fair) "
lab var incdisfair_fac2 "[LB] How fair is the income distribution? % answering 2 (Fair) "
lab var incdisfair_fac3 "[LB] How fair is the income distribution? % answering 3 (Unfair) "
lab var incdisfair_fac4 "[LB] How fair is the income distribution? % answering 4 (Very unfair) "
 
gen year=2002
 
tempfile lb02
save `lb02', replace

/*LB 2001*/
use "Latinobarometro_2001.dta", clear
rename idenpa Country

keep Country p1st p2st p3st p4st p11st p13st p16stc p18nb p41st p49nasa wt

foreach v of varlist p1st p2st p3st p4st p11st p16stc p18nb p41st p49nasa {

	replace `v'=. if `v'<1

}

foreach v of varlist p1st-p49nasa {
	local l`v' : variable label `v'
		if `"`l`v''"' == "" {
		local l`v' "`v'"
	}
}
 
local list "p1st p2st p3st p4st p11st p13st p16stc p18nb p41st p49nasa"
 
foreach var of local list {
	levelsof `var', local(`var'_levels)
	foreach val of local `var'_levels {
		local `var'vl`val' : label `var' `val'
	}
}

rename (p1st-p49nasa) (econsitnow econsitpast econsitfuture econsitpersonalnow ///
 incdisfair countryproblem corruptionchange corruptact lifesatisfaction bribepubemp)
 
foreach v of varlist econsitnow-bribepubemp {

	tab `v', gen(`v'_fac)

}

collapse econsitnow-bribepubemp_fac4 [pweight=wt], by(Country)

foreach v of varlist econsitnow-bribepubemp_fac4 {

	label var `v' "[LB] `l`v''"
}

 foreach variable of local list {
	 foreach value of local `var'_levels{
		 label variable `variable'`value' "`l`variable'': `yearvl`value''"
	 }
}

lab var lifesatisfaction_fac1 "[LB] How satisfied are you with your life? % answering  1 (Very) "
lab var lifesatisfaction_fac2 "[LB] How satisfied are you with your life? % answering  2 (Quite) "
lab var lifesatisfaction_fac3 "[LB] How satisfied are you with your life? % answering  3 (Not very) "
lab var lifesatisfaction_fac4 "[LB] How satisfied are you with your life? % answering  4 (Not at all) "

lab var econsitnow_fac1 "[LB] What is the country's economic situation? % answering  1 (Very good) "
lab var econsitnow_fac2 "[LB] What is the country's economic situation? % answering  2 (Good) "
lab var econsitnow_fac3 "[LB] What is the country's economic situation? % answering  3 (About average) "
lab var econsitnow_fac4 "[LB] What is the country's economic situation? % answering  4 (Bad) "
lab var econsitnow_fac5 "[LB] What is the country's economic situation? % answering  5 (Very bad) "

lab var econsitpast_fac1 "[LB] What was the country's economic situation a year ago? % answering  1 (Much better) "
lab var econsitpast_fac2 "[LB] What was the country's economic situation a year ago? % answering  2 (A little better) "
lab var econsitpast_fac3 "[LB] What was the country's economic situation a year ago? % answering  3 (The same) "
lab var econsitpast_fac4 "[LB] What was the country's economic situation a year ago? % answering  4 (A little worse) "
lab var econsitpast_fac5 "[LB] What was the country's economic situation a year ago? % answering  5 (Much worse) "

lab var econsitfuture_fac1 "[LB] What will be the country's economic situation in a year? % answering  1 (Much better) "
lab var econsitfuture_fac2 "[LB] What will be the country's economic situation in a year? % answering  2 (A little better) "
lab var econsitfuture_fac3 "[LB] What will be the country's economic situation in a year? % answering  3 (The same) "
lab var econsitfuture_fac4 "[LB] What will be the country's economic situation in a year? % answering  4 (A little worse) "
lab var econsitfuture_fac5 "[LB] What will be the country's economic situation in a year? % answering  5 (Much worse) "

lab var incdisfair_fac1 "[LB] How fair is the income distribution? % answering 1 (Very fair) "
lab var incdisfair_fac2 "[LB] How fair is the income distribution? % answering 2 (Fair) "
lab var incdisfair_fac3 "[LB] How fair is the income distribution? % answering 3 (Unfair) "
lab var incdisfair_fac4 "[LB] How fair is the income distribution? % answering 4 (Very unfair) "
 
gen year=2001
 
tempfile lb01
save `lb01', replace

/*LB 2000*/
use "Latinobarometro_2000.dta", clear
rename idenpa Country

keep Country P1ST P2ST P3ST P4ST P7ST P8ST P12ST P14CG_A P14CG_B P14CG_C P21ST_E ///
 P24ST_A wt

foreach v of varlist P1ST P2ST P3ST P4ST P7ST P8ST P14CG_A P14CG_B P14CG_C ///
 P21ST_E P24ST_A {

	replace `v'=. if `v'<1

} 
 
foreach v of varlist P1ST-P24ST_A {
	local l`v' : variable label `v'
		if `"`l`v''"' == "" {
		local l`v' "`v'"
	}
}
 
local list "P1ST P2ST P3ST P4ST P7ST P8ST P12ST P14CG_A P14CG_B P14CG_C P21ST_E P24ST_A"
 
foreach var of local list {
	levelsof `var', local(`var'_levels)
	foreach val of local `var'_levels {
		local `var'vl`val' : label `var' `val'
	}
}

rename (P1ST-P24ST_A) (econsitnow econsitpast econsitfuture econsitpersonalnow ///
 countryprogress lifesatisfaction countryproblem scalepoorrichnow scalepoorrichpast ///
 scalepoorrichfuture corruptionchange corruptionproblem)
 
foreach v of varlist econsitnow-corruptionproblem {

	tab `v', gen(`v'_fac)

}

collapse econsitnow-corruptionproblem_fac4 [pweight=wt], by(Country)

foreach v of varlist econsitnow-corruptionproblem_fac4 {

	label var `v' "[LB] `l`v''"
}

 foreach variable of local list {
	 foreach value of local `var'_levels{
		 label variable `variable'`value' "`l`variable'': `yearvl`value''"
	 }
}

lab var lifesatisfaction_fac1 "[LB] How satisfied are you with your life? % answering  1 (Very) "
lab var lifesatisfaction_fac2 "[LB] How satisfied are you with your life? % answering  2 (Quite) "
lab var lifesatisfaction_fac3 "[LB] How satisfied are you with your life? % answering  3 (Not very) "
lab var lifesatisfaction_fac4 "[LB] How satisfied are you with your life? % answering  4 (Not at all) "

lab var countryprogress_fac1 "[LB] What is the state of progress in [country]? % answering  1 (Progressing) "
lab var countryprogress_fac2 "[LB] What is the state of progress in [country]? % answering  2 (Standstill) "
lab var countryprogress_fac3 "[LB] What is the state of progress in [country]? % answering  3 (Declining) "

lab var econsitnow_fac1 "[LB] What is the country's economic situation? % answering  1 (Very good) "
lab var econsitnow_fac2 "[LB] What is the country's economic situation? % answering  2 (Good) "
lab var econsitnow_fac3 "[LB] What is the country's economic situation? % answering  3 (About average) "
lab var econsitnow_fac4 "[LB] What is the country's economic situation? % answering  4 (Bad) "
lab var econsitnow_fac5 "[LB] What is the country's economic situation? % answering  5 (Very bad) "

lab var econsitpast_fac1 "[LB] What was the country's economic situation a year ago? % answering  1 (Better) "
lab var econsitpast_fac2 "[LB] What was the country's economic situation a year ago? % answering  2 (Same) "
lab var econsitpast_fac3 "[LB] What was the country's economic situation a year ago? % answering  3 (Worse) "

lab var econsitfuture_fac1 "[LB] What will be the country's economic situation in a year? % answering  1 (Better) "
lab var econsitfuture_fac2 "[LB] What will be the country's economic situation in a year? % answering  2 (Same) "
lab var econsitfuture_fac3 "[LB] What will be the country's economic situation in a year? % answering  3 (Worse) "

lab var scalepoorrichnow_fac1  "[LB] Scale of where you see yourself on income distribution. % answering 1 (Bottom) "
lab var scalepoorrichnow_fac2  "[LB] Scale of where you see yourself on income distribution. % answering 2 "
lab var scalepoorrichnow_fac3  "[LB] Scale of where you see yourself on income distribution. % answering 3 "
lab var scalepoorrichnow_fac4  "[LB] Scale of where you see yourself on income distribution. % answering 4 "
lab var scalepoorrichnow_fac5  "[LB] Scale of where you see yourself on income distribution. % answering 5 "
lab var scalepoorrichnow_fac6  "[LB] Scale of where you see yourself on income distribution. % answering 6 "
lab var scalepoorrichnow_fac7  "[LB] Scale of where you see yourself on income distribution. % answering 7 "
lab var scalepoorrichnow_fac8  "[LB] Scale of where you see yourself on income distribution. % answering 8 "
lab var scalepoorrichnow_fac9  "[LB] Scale of where you see yourself on income distribution. % answering 9 "
lab var scalepoorrichnow_fac10 "[LB] Scale of where you see yourself on income distribution. % answering 10 (Top) "
 
gen year=2000
 
tempfile lb00
save `lb00', replace

/***************************************/
/*Append Latinobarometro files together*/
/***************************************/

use `lb16', clear
append using `lb15'
append using `lb13'
append using `lb11'
append using `lb10'
append using `lb09'
append using `lb08'
append using `lb07'
append using `lb06'
append using `lb05'
append using `lb04'
append using `lb03'
append using `lb02'
append using `lb01'
append using `lb00'
append using `lb17'

order Country year, first
sort Country year

/*Consolidate variables*/
keep Country year lifesatisfaction* countryprogress* econsitnow* econsitpast* ///
 econsitfuture* scaleavoidtaxes* benofpowerful* lackfood* econfunction* ///
 incdisfair* scalepoorrichnow* refusetaxes*

lab var lifesatisfaction "[LB] How satisfied are you with your life? (Mean) "
lab var countryprogress "[LB] What is the state of progress in [country]? (Mean) "
lab var econsitnow "[LB] What is the country's economic situation? (Mean) "
lab var econsitpast "[LB] What was the country's economic situation a year ago? (Mean) "
lab var econsitfuture "[LB] What will be the country's economic situation in a year? (Mean) "
lab var benofpowerful "[LB] Do you agree or disagree that [country] is run for the benefit of the powerful? "
lab var scaleavoidtaxes  "[LB] How justified is tax evasion? (Mean) "
lab var econfunction "[LB] How satisfied are you with the country's economy? (Mean)"
lab var incdisfair "[LB] How fair is the income distribution? (Mean) "
lab var refusetaxes "[LB] Have you ever refused to pay taxes to the government? (Mean) "
lab var scalepoorrichnow "[LB] Scale of where you see yourself on income distribution. (Mean) "
lab var lackfood "[LB] Last year, how often have you/family lacked food? (Mean)"

lab var benofpowerful_fac1 "[LB] [Country] is run for the benefit of the powerful. % answering Strongly agree or Agree "
lab var benofpowerful_fac2 "[LB] [Country] is run for the benefit of the powerful. % answering Disagree or Strongly disagree "

decode Country, gen(country)
replace country="Venezuela, RB" if country=="Venezuela"
replace country="Dominican Republic" if country=="Dominican Rep."
drop Country
rename country Country

//adding country codes for safe merging
merge m:1 Country using "Country Codes.dta"
drop if _merge!=3
drop _merge
drop Country

save "Latinobarometro_dataset_combined.dta", replace

/*Merge with Master Dataset*/

use "Master Dataset.dta", clear
merge m:1 Country_Code year using "Latinobarometro_dataset_combined.dta"
drop if _merge==2
drop _merge

save "Master Dataset.dta", replace


/****************************/
/*****MIMIC Informality******/
/****************************/

import excel "MIMIC shadow economy figures 1991-2015 (scraped from IMF working paper, link inside).xlsx", firstrow cellrange(C1:AB159) clear

rename D Shadow_Economy1991
rename E Shadow_Economy1992
rename F Shadow_Economy1993
rename G Shadow_Economy1994
rename H Shadow_Economy1995
rename I Shadow_Economy1996
rename J Shadow_Economy1997
rename K Shadow_Economy1998
rename L Shadow_Economy1999
rename M Shadow_Economy2000
rename N Shadow_Economy2001
rename O Shadow_Economy2002
rename P Shadow_Economy2003
rename Q Shadow_Economy2004
rename R Shadow_Economy2005
rename S Shadow_Economy2006
rename T Shadow_Economy2007
rename U Shadow_Economy2008
rename V Shadow_Economy2009
rename W Shadow_Economy2010
rename X Shadow_Economy2011
rename Y Shadow_Economy2012
rename Z Shadow_Economy2013
rename AA Shadow_Economy2014
rename AB Shadow_Economy2015

reshape long Shadow_Economy, i(Country) j(year)

replace Country="Cote d'Ivoire" if Country=="Côte d'Ivoire"
replace Country="Egypt" if Country=="Egypt, Arab. Rep."
replace Country="Iran" if Country=="Iran, Islam Rep."
replace Country="Lao PDR" if Country=="Laos"
replace Country="Netherlands" if Country=="Netherlands, The"
replace Country="Syria" if Country=="Syrian Arab. Rep."
replace Country="Brunei" if Country=="Brunei Darussalam"
replace Country="Russia" if Country=="Russian Federation"
replace Country="Eswatini" if Country=="Swaziland"
replace Country="Yemen" if Country=="Yemen, Rep."

label var Shadow_Economy "[MIMIC] Informality calculations by IMF's Leandro Medina and Friedrich Schneider"

//adding country codes for safe merging
merge m:1 Country using "Country Codes.dta"
drop if _merge!=3
drop _merge
drop Country

save "MIMIC Informality.dta", replace

use "Master Dataset.dta", clear
merge m:1 Country_Code year using "MIMIC Informality.dta"
drop if _merge==2
drop _merge

save "Master Dataset.dta", replace

/**************************************/
/***Worldwide Bureaucracy Indicators***/
/**************************************/

import excel "WWBIEXCEL.xlsx", sheet("Data") firstrow clear

rename (E-U) (yr2000 yr2001 yr2002 yr2003 yr2004 yr2005 yr2006 yr2007 yr2008 ///
  yr2009 yr2010 yr2011 yr2012 yr2013 yr2014 yr2015 yr2016)
  
reshape long yr, i(CountryName IndicatorName) j(year)

rename yr value
keep if IndicatorName=="Wage bill as a percentage of Public Expenditure" | ///
 IndicatorName=="Wage bill as a percentage of GDP"
 
drop if value==.
gen value2=value if IndicatorName=="Wage bill as a percentage of GDP"
replace value=. if IndicatorName=="Wage bill as a percentage of GDP"

rename value2 WageBill_GDP
rename value WageBill_PubExp

collapse (firstnm) WageBill_PubExp WageBill_GDP, by(CountryName year)

rename CountryName Country

foreach v of varlist WageBill_PubExp WageBill_GDP{

	local x = "[WWBI] " + "`v'"
	label var `v' "`x'"
	
}
replace Country="Sao Tome and Principe" if Country=="São Tomé and Principe"
replace Country="Egypt" if Country=="Egypt, Arab Rep."
replace Country="Russia" if Country=="Russian Federation"

//adding country codes for safe merging
merge m:1 Country using "Country Codes.dta"
drop if _merge!=3
drop _merge
drop Country

save "WWBI public sector wage bill.dta", replace

use "Master Dataset.dta", clear
merge m:1 Country_Code year using "WWBI public sector wage bill.dta"
drop if _merge==2
drop _merge

save "Master Dataset.dta", replace

/**************************/
/***IMF Commodity Prices***/
/**************************/

import delimited "PCPS_07-02-2019 14-49-20-61_panel.csv", clear 
drop countrycode unitname unitcode ïcountryname

//We will remove the quarterly and monthly data to merge with the
//country-year level Master Dataset, but in order to do this we have
//to select the rows that are just year-level summaries, which has
//to be done the following way, since the year variable is a string.
local yearcounter=1990
gen keepthisrow=0
while `yearcounter'<=2017 {
	replace keepthisrow=1 if year=="`yearcounter'"
	local yearcounter = `yearcounter' + 1
}
keep if keepthisrow==1
drop keepthisrow
//Now that those pesky Q's and M's are out of the way...
destring year, replace

//label the variables to show where they came from
foreach v of varlist _all{
	local u: variable label `v'
	local x = "[Primary Commodity Price System] " + "`u'"
	label var `v' "`x'"
}

//trimming unused commodities
keep year apspcrudeoilbblpoilapsp brentcrudepoilbre dubaicrudepoildub wticrudepoilwti ///
	naturalgasindexpngas allindexpallfnf aluminumpalum coalindexpcoal coalaustraliapcoalau ///
	coalsouthafricapcoalsa cobaltpcoba copperpcopp energyindexpnrg goldpgold ///
	ironorepiorecr leadplead lngasiapngasjp metalindexpmeta molybdenumplmmody ///
	nickelpnick palladiumppalla platinumpplat preciousmetalspriceindexppmeta ///
	propaneppropane silverpsilver tinptin uraniumpuran zincpzinc

save "Commodity Prices.dta", replace

use "Master Dataset.dta", clear
merge m:1 year using "Commodity Prices.dta"
sort Country year
drop _merge

save "Master Dataset.dta", replace

/****************************/
/******WB Income Levels******/
/****************************/

import excel "OGHIST.xls", sheet("Country Analytical History") cellrange(A6:AG229) clear
drop B C D E

foreach var of varlist _all {
	replace `var'="" if `var'==".."
}
drop if F=="<= 610" | F=="611-2,465" | F=="2,466-7,620" | F=="> 7,620" | ///
	(A=="" & F=="")
foreach var of varlist _all {
	rename `var' Incomelevel`=`var'[1]'
}
drop if Incomelevel==""
rename Incomelevel Country_Code
reshape long Incomelevel, i(Country_Code) j(year)
replace Incomelevel="Low Income" if Incomelevel=="L"
replace Incomelevel="Lower Middle Income" if Incomelevel=="LM"
replace Incomelevel="Upper Middle Income" if Incomelevel=="UM"
replace Incomelevel="High Income" if Incomelevel=="H"

save "Income Classifications.dta", replace

use "Master Dataset.dta", clear
merge m:1 Country_Code year using "Income Classifications.dta"
drop if _merge==2
drop _merge

sort Country year
save "Master Dataset.dta", replace


/*********************************************/
/***Cross-Country Database of Fiscal Policy***/
/*********************************************/

use "fs_data_pub.dta", clear

rename country Country
keep Country year ggdy pby cby fby dfggd dffb fxsovsh secnres fordebtsh concggd ///
 avglife debtduey xtdebty fxdebtall prdebty pscy stdebtall stdebtres xtdebtres ///
 xtdebtrxg cds5y sovrate

foreach v of varlist _all{
	local u: variable label `v'
	local x = "[Fiscal Space] " + "`u'"
	label var `v' "`x'"
}

replace Country="Antigua and Barbuda" if Country=="Antigua & Barbuda"
replace Country="Bosnia and Herzegovina" if Country=="Bosnia & Herzegovina"
replace Country="Central African Republic" if Country=="Central African Rep."
replace Country="Micronesia, Fed. Sts." if Country=="Micronesia, Fed. States"
replace Country="Sao Tome and Principe" if Country=="Sao Tome & Principe"
replace Country="St. Kitts and Nevis" if Country=="St. Kitts & Nevis"
replace Country="St. Vincent and the Grenadines" if Country=="St. Vincent & the Grenadines"
replace Country="Trinidad and Tobago" if Country=="Trinidad & Tobago"
replace Country="West Bank and Gaza" if Country=="West Bank & Gaza"
replace Country="Brunei" if Country=="Brunei Darussalam"
replace Country="Egypt" if Country=="Egypt, Arab Rep."
replace Country="Iran" if Country=="Iran, Islamic Rep."
replace Country="Russia" if Country=="Russian Federation"
replace Country="Syria" if Country=="Syrian Arab Republic"
replace Country="Yemen" if Country=="Yemen, Rep."

//adding country codes for safe merging
merge m:1 Country using "Country Codes.dta"
drop if _merge!=3
drop _merge
drop Country

save "Fiscal Space Data.dta", replace

use "Master Dataset.dta", clear
merge m:1 Country_Code year using "Fiscal Space Data.dta"
drop if _merge==2
drop _merge

save "Master Dataset.dta", replace

/************************/
/*******UNCTAD ICT*******/
/************************/

import delimited us_ictproductionsector_06320563693489.csv, clear

foreach v of varlist v3-v13 {

	replace `v'="" if `v'==".."
	destring `v', replace

}

rename (v1-v13) (Country indicator yr2002 yr2003 yr2004 yr2005 yr2006 yr2007 ///
 yr2008 yr2009 yr2010 yr2011 yr2012)
 
drop in 1
drop in 1

reshape long yr, i(Country indicator) j(year)
rename yr score

encode indicator, gen(indic)
drop indicator
reshape wide score, i(Country year) j(indic)

rename (score1 score2) (PrWorkforceinICT ValueAddedICTPctBusSecVA)
label var PrWorkforceinICT "[UNCTAD ICT] Proportion of total business sector workforce involved in the ICT sector"
label var ValueAddedICTPctBusSecVA "[UNCTAD ICT] Valued added in the ICT sector as % of total business sector value added"

drop if PrWorkforceinICT==. & ValueAddedICTPctBusSecVA==.

replace Country="Korea, Rep." if Country=="Korea, Republic of"
replace Country="West Bank and Gaza" if Country=="State of Palestine"
replace Country="North Macedonia" if Country=="TFYR of Macedonia"
replace Country="Slovak Republic" if Country=="Slovakia"
replace Country="Hong Kong SAR, China" if Country=="China, Hong Kong SAR"
replace Country="Russia" if Country=="Russian Federation"

//adding country codes for safe merging
merge m:1 Country using "Country Codes.dta"
drop if _merge!=3
drop _merge
drop Country

save "UNCTAD ICT.dta", replace

use "Master Dataset.dta", clear
merge m:1 Country_Code year using "UNCTAD ICT.dta"
drop if _merge==2
drop _merge

save "Master Dataset.dta", replace

/*****************/
/***WDI CUSTOMS***/
/*****************/

import excel "WDI Customs data.xlsx", sheet("3908d76d-d7c5-4e3d-b2f4-4593976") ///
 cellrange(A1:I6077) firstrow clear

rename (CountryName CountryCode Time H) (Country Country_Code year Customs_LCU)
drop TimeCode

foreach v of varlist Averagetimetoclearexportsth BurdenofcustomsprocedureWEF ///
 Customsandotherimportduties Customs_LCU LogisticsperformanceindexEff {
 
	replace `v'="" if `v'==".."
	destring `v', replace
 
 }

foreach v of varlist _all{
	local u: variable label `v'
	local x = "[WDI Customs] " + "`u'"
	label var `v' "`x'"
}
 
save "WDI Customs.dta", replace

use "Master Dataset.dta", clear
merge m:1 Country_Code year using "WDI Customs.dta"
drop if _merge==2
drop _merge

save "Master Dataset.dta", replace

/********************/
/***UNCTAD TARIFFS***/
/********************/

import delimited us_tariff_06356461732761.csv, clear 

rename (v1 v2) (Country Tariff)
drop in 1
drop in 1
drop in 1
drop in 1
drop in 1

foreach v of varlist v3-v32 {

	replace `v'="" if `v'==".."
	replace `v'="" if `v'=="_"
	destring `v', replace

}

rename (v3-v32) (yr1988 yr1989 yr1990 yr1991 yr1992 yr1993 yr1994 yr1995 yr1996 ///
 yr1997 yr1998 yr1999 yr2000 yr2001 yr2002 yr2003 yr2004 yr2005 yr2006 yr2007 ///
 yr2008 yr2009 yr2010 yr2011 yr2012 yr2013 yr2014 yr2015 yr2016 yr2017)
 
reshape long yr, i(Country Tariff) j(year)
rename yr tariffrate

encode Tariff, gen(tariff)
drop Tariff
reshape wide tariffrate, i(Country year) j(tariff)

label var tariffrate1 "Manufactured goods, ores and metals"
label var tariffrate2 "Ores and metals"
label var tariffrate3 "Manufactured goods"
label var tariffrate4 "Chemical products"
label var tariffrate5 "Machinery and transport equipment"
label var tariffrate6 "Other manufactured goods"

rename (tariffrate1-tariffrate6) (tariffmanuf_and_ores tarifforeandmetals ///
 tariffmanufactures tariffchemicals tariffmachinery tariffothermanuf)
 
drop if year<1990

drop if Country=="Indonesia" & year<=2002
drop if Country=="Indonesia (...2002)" & year>2002
drop if Country=="Sudan" & year>=2011
drop if Country=="Sudan (...2011)" & year<2011
drop if Country=="Serbia" & year<=2006
drop if Country=="Serbia and Montenegro" & year>2006

replace Country="Bahams, The" if Country=="Bahamas"
replace Country="Bolivia" if Country=="Bolivia (Plurinational State of)"
replace Country="Brunei" if Country=="Brunei Darussalam"
replace Country="Hong Kong SAR, China" if Country=="China, Hong Kong SAR"
replace Country="Macao SAR, China" if Country=="China, Macao SAR"
replace Country="Czech Republic" if Country=="Czechia"
replace Country="Slovak Republic" if Country=="Slovakia"
replace Country="Cote d'Ivoire" if Country=="Côte d'Ivoire"
replace Country="Congo, Dem. Rep." if Country=="Dem. Rep. of the Congo"
replace Country="Gambia, The" if Country=="Gambia"
replace Country="Iran" if Country=="Iran (Islamic Republic of)"
replace Country="Indonesia" if Country=="Indonesia (...2002)"
replace Country="Korea, Rep." if Country=="Korea, Republic of"
replace Country="Kyrgyz Republic" if Country=="Kyrgyzstan"
replace Country="Lao PDR" if Country=="Lao People's Dem. Rep."
replace Country="North Macedonia" if Country=="TFYR of Macedonia"
replace Country="Moldova" if Country=="Republic of Moldova"
replace Country="Russia" if Country=="Russian Federation"
replace Country="St. Kitts and Nevis" if Country=="Saint Kitts and Nevis"
replace Country="St. Lucia" if Country=="Saint Lucia"
replace Country="St. Vincent and the Grenadines" if Country=="Saint Vincent and the Grenadines"
replace Country="West Bank and Gaza" if Country=="State of Palestine"
replace Country="Syria" if Country=="Syrian Arab Republic"
replace Country="Tanzania" if Country=="United Republic of Tanzania"
replace Country="Venezuela, RB" if Country=="Venezuela (Bolivarian Rep. of)"
replace Country="Vietnam" if Country=="Viet Nam"
replace Country="Switzerland" if Country=="Switzerland, Liechtenstein"
replace Country="Sudan" if Country=="Sudan (...2011)"
replace Country="United States" if Country=="United States of America"
replace Country="Congo, Rep." if Country=="Congo"
replace Country="Serbia" if Country=="Serbia and Montenegro"

foreach v of varlist _all{

	local u: variable label `v'
	local x = "[UNCTAD Tariff] " + "`u'"
	label var `v' "`x'"
}

merge m:1 Country using "Country Codes.dta"
drop if _merge!=3
drop _merge

save "UNCTAD Tariff data.dta", replace

use "Master Dataset.dta", clear
merge m:1 Country_Code year using "UNCTAD Tariff data.dta"
drop if _merge==2
drop _merge

save "Master Dataset.dta", replace

/**********************/
/***WB FINSTATS 2019***/
/**********************/

use "Master Dataset.dta", clear
merge m:1 Country_Code year using "FinStats 2019 data.dta"
drop if _merge==2
drop _merge

save "Master Dataset.dta", replace


/**************************/
/***IMF Energy subsidies***/
/**************************/

import excel "IMF fuel tax gap database.xlsx", sheet("By product (2015)") ///
 cellrange(A1:R210) firstrow clear
drop A-C
drop NominalGDP-M

rename (country N O P Q R) (Country petroleumposttaxsubsidy coalposttaxsubsidy ///
 naturalgasposttaxsubsidy electricityposttaxsubsidy totalposttaxsubsidy)
 
drop in 1/4
drop if Country==""

destring petroleumposttaxsubsidy-totalposttaxsubsidy, replace
gen year=2015

tempfile y2015
save `y2015', replace

import excel "IMF fuel tax gap database.xlsx", sheet("By product (2017)") ///
 cellrange(A1:R210) firstrow clear
drop A-C
drop NominalGDP-M

rename (country N O P Q R) (Country petroleumposttaxsubsidy coalposttaxsubsidy ///
 naturalgasposttaxsubsidy electricityposttaxsubsidy totalposttaxsubsidy)
 
drop in 1/4
drop if Country==""

destring petroleumposttaxsubsidy-totalposttaxsubsidy, replace
gen year=2017

append using `y2015'

lab var petroleumposttaxsubsidy "[IMF Fuel Subsidy] Post-Tax Subsidy of Petroleum (% of GDP)"
lab var coalposttaxsubsidy "[IMF Fuel Subsidy] Post-Tax Subsidy of Coal (% of GDP)"
lab var naturalgasposttaxsubsidy "[IMF Fuel Subsidy] Post-Tax Subsidy of Natural Gas (% of GDP)"
lab var electricityposttaxsubsidy "[IMF Fuel Subsidy] Post-Tax Subsidy of Electricity (% of GDP)"
lab var totalposttaxsubsidy "[IMF Fuel Subsidy] Post-Tax Subsidy Total (% of GDP)"

replace Country="Brunei" if Country=="Brunei Darussalam"
replace Country="Congo, Dem. Rep." if Country=="Congo, Democratic Republic of the"
replace Country="Congo, Rep." if Country=="Congo, Republic of"
replace Country="Cote d'Ivoire" if Country=="Côte d'Ivoire"
replace Country="North Macedonia" if Country=="FYR Macedonia"
replace Country="Hong Kong SAR, China" if Country=="Hong Kong SAR"
replace Country="Korea, Rep." if Country=="Korea"
replace Country="Lao PDR" if Country=="Lao P.D.R."
replace Country="Macao SAR, China" if Country=="Macao SAR"
replace Country="Micronesia, Fed. Sts." if Country=="Micronesia"
replace Country="Montenegro" if Country=="Montenegro, Rep. of"
replace Country="Sao Tome and Principe" if Country=="São Tomé and Príncipe"
replace Country="Eswatini" if Country=="Swaziland"
replace Country="Timor-Leste" if Country=="Timor-Leste, Dem. Rep. of"
replace Country="Venezuela, RB" if Country=="Venezuela"

merge m:1 Country using "Country Codes.dta"
drop if _merge!=3
drop _merge

save "IMF fuel tax gap data.dta", replace

use "Master Dataset.dta", clear

merge m:1 Country_Code year using "IMF fuel tax gap data"
drop if _merge==2
drop _merge

/*************************************/
/***TI CORRUPTION PERCEPTIONS INDEX***/
/*************************************/

import excel "2018_CPI_FullDataSet.xlsx", sheet("CPI Timeseries 2012 - 2018") ///
 firstrow clear
 
rename (CorruptionPer D H L O R U X) (Country CPI2018 CPI2017 CPI2016 CPI2015 ///
 CPI2014 CPI2013 CPI2012)
 
drop B C E F G I J K M N P Q S T V W Y Z
drop in 1/2

destring CPI2018-CPI2012, replace

reshape long CPI, i(Country) j(year)

rename CPI TI_CPI

lab var TI_CPI "[TI] Corruption Perceptions Index"

replace Country="Bahamas, The" if Country=="Bahamas"
replace Country="Brunei" if Country=="Brunei Darussalam"
replace Country="Congo, Dem. Rep." if Country=="Democratic Republic of the Congo"
replace Country="Congo, Rep." if Country=="Congo"
replace Country="Gambia, The" if Country=="Gambia"
replace Country="Guinea-Bissau" if Country=="Guinea Bissau"
replace Country="Hong Kong SAR, China" if Country=="Hong Kong"
replace Country="Korea, Rep." if Country=="Korea, South"
replace Country="Korea, Dem. People’s Rep." if Country=="Korea, North"
replace Country="Kyrgyz Republic" if Country=="Kyrgyzstan"
replace Country="Lao PDR" if Country=="Laos"
replace Country="North Macedonia" if Country=="Macedonia"
replace Country="St. Lucia" if Country=="Saint Lucia"
replace Country="St. Vincent and the Grenadines" if Country=="Saint Vincent and the Grenadines"
replace Country="Slovak Republic" if Country=="Slovakia"
replace Country="Eswatini" if Country=="Swaziland"
replace Country="United States" if Country=="United States of America"
replace Country="Venezuela, RB" if Country=="Venezuela"

merge m:1 Country using "Country Codes.dta"
drop if _merge!=3
drop _merge

save "TI Corruption data.dta", replace

use "Master Dataset.dta", clear
merge m:1 Country_Code year using "TI Corruption data.dta"
drop if _merge==2
drop _merge

save "Master Dataset.dta", replace

/*****************************/
/***FINANCIAL SECRECY INDEX***/
/*****************************/

import excel "FSI Rankings 2018.xlsx", firstrow sheet("SS") cellrange(A1:V114) clear
drop if Jurisdiction==""
destring KI*, replace
rename Final FinalSS
rename Jurisdiction Country

local counter = 1
while `counter'<=20 {
	rename KI`counter' FSI_`counter'
	local counter = `counter' + 1
}

label var FSI_1 "[FSI 2018] Banking Secrecy"
label var FSI_2 "[FSI 2018] Trusts & Private Foundations"
label var FSI_3 "[FSI 2018] Company Ownership Registration"
label var FSI_4 "[FSI 2018] Freeport & Real Estate"
label var FSI_5 "[FSI 2018] Limited Partnership Transparency"
label var FSI_6 "[FSI 2018] Company Ownership Publication"
label var FSI_7 "[FSI 2018] Company Accounts Publication"
label var FSI_8 "[FSI 2018] Country-by-Country Reporting"
label var FSI_9 "[FSI 2018] Corporate Tax Disclosure"
label var FSI_10 "[FSI 2018] Legal Entity Identifier"
label var FSI_11 "[FSI 2018] Tax Administration Capacity"
label var FSI_12 "[FSI 2018] Consistent Personal Income Tax"
label var FSI_13 "[FSI 2018] Promotion of Tax Evasion"
label var FSI_14 "[FSI 2018] Tax Court Secrecy"
label var FSI_15 "[FSI 2018] Harmful Structures"
label var FSI_16 "[FSI 2018] Public Statistics"
label var FSI_17 "[FSI 2018] Anti-Money Laundering"
label var FSI_18 "[FSI 2018] Automatic Exchange of Information"
label var FSI_19 "[FSI 2018] Bilateral Treaties"
label var FSI_20 "[FSI 2018] International Legal Cooperation"
label var FinalSS "[FSI 2018] Final Secrecy Score (average of 20)"

replace Country="Bahamas, The" if Country=="Bahamas"
replace Country="Gambia, The" if Country=="Gambia"
replace Country="Hong Kong SAR, China" if Country=="Hong Kong"
replace Country="Macao SAR, China" if Country=="Macao"
replace Country="North Macedonia" if Country=="Macedonia"
replace Country="Slovak Republic" if Country=="Slovakia"
replace Country="Korea, Rep." if Country=="South Korea"
replace Country="United States" if Country=="USA"
replace Country="Venezuela, RB" if Country=="Venezuela"
replace Country="United Arab Emirates" if Country=="United Arab Emirates (Dubai)"
replace Country="Portugal" if Country=="Portugal (Madeira)"
replace Country="Malaysia" if Country=="Malaysia (Labuan)"

merge m:1 Country using "Country Codes.dta"
drop if _merge!=3
drop _merge

tempfile secrecy
save `secrecy'

use "Master Dataset.dta", clear
merge m:1 Country_Code using `secrecy'
drop if _merge==2
drop _merge

save "Master Dataset.dta", replace

/**********************************/
/***HERITAGE FOUNDATION FREEDOMS***/
/**********************************/

import excel "index2019_data.xls", sheet("Sheet1") firstrow clear

keep CountryName PropertyRights TaxBurden BusinessFreedom-FinancialFreedom ///
 TaxBurdenofGDP
rename CountryName Country
drop if Country==""

foreach v of varlist _all {
	replace `v'="" if `v'=="N/A"
}

destring PropertyRights-TaxBurdenofGDP, replace
gen year=2019

tempfile i19
save `i19', replace

import excel "index2018_data.xls", sheet("Sheet1") firstrow clear

keep CountryName PropertyRights TaxBurden BusinessFreedom-FinancialFreedom ///
 TaxBurdenofGDP
rename CountryName Country
drop if Country==""

foreach v of varlist _all {
	replace `v'="" if `v'=="N/A"
}

destring PropertyRights-TaxBurdenofGDP, replace
gen year=2018

tempfile i18
save `i18', replace

import excel "index2017_data.xls", sheet("Sheet1") firstrow clear
 
keep CountryName PropertyRights TaxBurden BusinessFreedom-FinancialFreedom ///
 TaxBurdenofGDP
rename CountryName Country
drop if Country==""

foreach v of varlist Property TaxBurden Monetary Trade Investment Financial ///
 TaxBurdenofGDP {
	replace `v'="" if `v'=="N/A" | `v'=="n/a"
}

destring PropertyRights-TaxBurdenofGDP, replace
gen year=2017

tempfile i17
save `i17', replace

import excel "index2016_data.xls", sheet("Sheet1") firstrow clear
 
keep CountryName PropertyRights FiscalFreedom BusinessFreedom LaborFreedom ///
 MonetaryFreedom TradeFreedom InvestmentFreedom FinancialFreedom TaxBurdenofGDP
rename CountryName Country
drop if Country==""

foreach v of varlist _all {
	replace `v'="" if `v'=="N/A" | `v'=="n/a"
}

destring PropertyRights-TaxBurdenofGDP, replace
gen year=2016

tempfile i16
save `i16', replace

import excel "index2015_data.xls", sheet("2014") firstrow clear
 
keep CountryName PropertyRights BusinessFreedom LaborFreedom MonetaryFreedom ///
 TradeFreedom InvestmentFreedom FinancialFreedom TaxBurdenofGDP
rename CountryName Country
drop if Country==""

foreach v of varlist _all {
	replace `v'="" if `v'=="N/A" | `v'=="n/a"
}

destring PropertyRights-TaxBurdenofGDP, replace
gen year=2015

tempfile i15
save `i15', replace

import excel "index2014_data.xls", sheet("2014") firstrow clear
 
keep CountryName PropertyRights FiscalFreedom BusinessFreedom LaborFreedom ///
 MonetaryFreedom TradeFreedom InvestmentFreedom FinancialFreedom TaxBurdenofGDP
rename CountryName Country
drop if Country==""

foreach v of varlist _all {
	replace `v'="" if `v'=="N/A" | `v'=="n/a"
}

destring PropertyRights-TaxBurdenofGDP, replace
gen year=2014

tempfile i14
save `i14', replace

import excel "index2013_data.xls", sheet("2010") firstrow clear

keep CountryName PropertyRights FiscalFreedom BusinessFreedom LaborFreedom ///
 MonetaryFreedom TradeFreedom InvestmentFreedom FinancialFreedom TaxBurdenofGDP
rename CountryName Country
drop if Country==""

foreach v of varlist _all {
	replace `v'="" if `v'=="N/A" | `v'=="n/a"
}

destring PropertyRights-TaxBurdenofGDP, replace
gen year=2013

order Country year, first

append using `i14'
append using `i15'
append using `i16'
append using `i17'
append using `i18', force
append using `i19'

sort Country year

replace Country="Bahamas, The" if Country=="Bahamas"
replace Country="Brunei" if Country=="Brunei Darussalam"
replace Country="Cabo Verde" if Country=="Cape Verde"
replace Country="Myanmar" if Country=="Burma"
replace Country="Congo, Dem. Rep." if Country=="Congo, Democratic Republic of" | ///
 Country=="Congo, Democratic Republic of the Congo"
replace Country="Congo, Rep." if Country=="Congo, Republic of"
replace Country="Cote d'Ivoire" if Country=="Côte d'Ivoire"
replace Country="Eswatini" if Country=="Swaziland"
replace Country="Gambia, The" if Country=="Gambia"
replace Country="Hong Kong SAR, China" if Country=="Hong Kong" | Country=="Hong Kong SAR"
replace Country="Korea, Dem. People’s Rep." if Country=="Korea, North" | Country=="Korea, North "
replace Country="Korea, Rep." if Country=="Korea, South"
replace Country="Lao PDR" if Country=="Lao P.D.R." | Country=="Laos"
replace Country="Macao SAR, China" if Country=="Macau"
replace Country="North Macedonia" if Country=="Macedonia"
replace Country="Micronesia, Fed. Sts." if Country=="Micronesia"
replace Country="St. Kitts and Nevis" if Country=="Saint Kitts and Nevis"
replace Country="St. Lucia" if Country=="Saint Lucia" | Country=="Saint. Lucia"
replace Country="St. Vincent and the Grenadines" if Country=="Saint Vincent and the Grenadines" ///
 | Country=="Saint Vincent and The Grenadines" | Country=="Saint. Vincent and the Grenadines"
replace Country="Sao Tome and Principe" if Country=="São Tomé and Príncipe"
replace Country="Slovak Republic" if Country=="Slovakia"
replace Country="Taiwan" if Country=="Taiwan "
replace Country="Venezuela, RB" if Country=="Venezuela"


foreach v of varlist Property-TaxBurden {
	local u: variable label `v'
	local x = "[Heritage] " + "`u'"
	label var `v' "`x'"
}

merge m:1 Country using "Country Codes.dta"
replace Country_Code="PRK" if Country=="Korea, Dem. People's Rep."
drop if year==.
drop _merge

tempfile heritage
save `heritage', replace

use "Master Dataset.dta", clear
merge m:1 Country_Code year using `heritage'
drop if _merge==2
drop _merge

save "Master Dataset.dta", replace

/*********************************/
/***IDA18 Cycle classifications***/
/*********************************/

import excel "MPO_SM19_TotalTax_GDP.xlsx", sheet("List of economies") firstrow cellrange(D5:I224) clear
drop if Code=="x"
drop Economy
rename Code Country_Code
replace Lending="" if Lending==".."
gen IDA = (Lending=="IDA" | Lending=="Blend")
gen IBRD = (Lending=="IBRD")

drop Region X Incomegroup

tempfile IDAlist
save `IDAlist'

use "Master Dataset.dta", clear
merge m:1 Country_Code using `IDAlist'
drop if _merge==2
drop _merge

save "Master Dataset.dta", replace

/***************************/
/***UN e-Governance Index***/
/***************************/

clear all

foreach egovyr in 18 16 14 12 10 08 05 04 03 {

import delimited "EGOV_DATA_20`egovyr'.csv", clear

rename surveyyear year
rename countryname Country

replace Country="Albania" if Country=="Albania "
replace Country="Algeria" if Country=="Algeria "
replace Country="Andorra" if Country=="Andorra "
replace Country="Angola" if Country=="Angola "
replace Country="Antigua and Barbuda" if Country=="Antigua and Barbuda "
replace Country="Argentina" if Country=="Argentina "
replace Country="Armenia" if Country=="Armenia "
replace Country="Australia" if Country=="Australia "
replace Country="Azerbaijan" if Country=="Azerbaijan "
replace Country="Bahamas, The" if Country=="Bahamas "
replace Country="Bahrain" if Country=="Bahrain "
replace Country="Bangladesh" if Country=="Bangladesh "
replace Country="Barbados" if Country=="Barbados "
replace Country="Belarus" if Country=="Belarus "
replace Country="Belgium" if Country=="Belgium "
replace Country="Belize" if Country=="Belize "
replace Country="Benin" if Country=="Benin "
replace Country="Bhutan" if Country=="Bhutan "
replace Country="Bolivia" if Country=="Bolivia "
replace Country="Bosnia and Herzegovina" if Country=="Bosnia and Herzegovina "
replace Country="Botswana" if Country=="Botswana "
replace Country="Brazil" if Country=="Brazil "
replace Country="Brunei" if Country=="Brunei Darussalam "
replace Country="Bulgaria" if Country=="Bulgaria "
replace Country="Burkina Faso" if Country=="Burkina Faso "
replace Country="Burundi" if Country=="Burundi "
replace Country="Cabo Verde" if Country=="Cabo Verde "
replace Country="Cambodia" if Country=="Cambodia "
replace Country="Cameroon" if Country=="Cameroon "
replace Country="Canada" if Country=="Canada "
replace Country="Central African Republic" if Country=="Central African Republic "
replace Country="Chad" if Country=="Chad "
replace Country="Chile" if Country=="Chile "
replace Country="China" if Country=="China "
replace Country="Colombia" if Country=="Colombia "
replace Country="Comoros" if Country=="Comoros "
replace Country="Congo, Rep." if Country=="Congo "
replace Country="Costa Rica" if Country=="Costa Rica "
replace Country="Croatia" if Country=="Croatia "
replace Country="Cuba" if Country=="Cuba "
replace Country="Cyprus" if Country=="Cyprus "
replace Country="Czech Republic" if Country=="Czech Republic "
replace Country="Korea, Dem. People’s Rep." if Country=="Democratic People's Republic of Korea "
replace Country="Cote d'Ivoire" if Country=="CÃ´te d'Ivoire "
replace Country="Congo, Dem. Rep." if Country=="Democratic Republic of the Congo "
replace Country="Denmark" if Country=="Denmark "
replace Country="Djibouti" if Country=="Djibouti "
replace Country="Dominica" if Country=="Dominica "
replace Country="Dominican Republic" if Country=="Dominican Republic "
replace Country="Ecuador" if Country=="Ecuador "
replace Country="Egypt" if Country=="Egypt "
replace Country="El Salvador" if Country=="El Salvador "
replace Country="Equatorial Guinea" if Country=="Equatorial Guinea "
replace Country="Eritrea" if Country=="Eritrea "
replace Country="Estonia" if Country=="Estonia "
replace Country="Ethiopia" if Country=="Ethiopia "
replace Country="Fiji" if Country=="Fiji "
replace Country="Finland" if Country=="Finland "
replace Country="Gabon" if Country=="Gabon "
replace Country="Gambia, The" if Country=="Gambia "
replace Country="Georgia" if Country=="Georgia (Country)"
replace Country="Germany" if Country=="Germany "
replace Country="Ghana" if Country=="Ghana "
replace Country="Greece" if Country=="Greece "
replace Country="Grenada" if Country=="Grenada "
replace Country="Guatemala" if Country=="Guatemala "
replace Country="Guinea" if Country=="Guinea "
replace Country="Guinea-Bissau" if Country=="Guinea-Bissau "
replace Country="Guyana" if Country=="Guyana "
replace Country="Haiti" if Country=="Haiti "
replace Country="Honduras" if Country=="Honduras "
replace Country="Hungary" if Country=="Hungary "
replace Country="Iceland" if Country=="Iceland "
replace Country="India" if Country=="India "
replace Country="Indonesia" if Country=="Indonesia "
replace Country="Iran" if Country=="Iran (Islamic Republic of) "
replace Country="Iraq" if Country=="Iraq "
replace Country="Ireland" if Country=="Ireland "
replace Country="Israel" if Country=="Israel "
replace Country="Italy" if Country=="Italy "
replace Country="Jamaica" if Country=="Jamaica "
replace Country="Japan" if Country=="Japan "
replace Country="Jordan" if Country=="Jordan "
replace Country="Kazakhstan" if Country=="Kazakhstan "
replace Country="Kenya" if Country=="Kenya "
replace Country="Kiribati" if Country=="Kiribati "
replace Country="Kuwait" if Country=="Kuwait "
replace Country="Kyrgyz Republic" if Country=="Kyrgyzstan "
replace Country="Lao PDR" if Country=="Lao People's Democratic Republic "
replace Country="Latvia" if Country=="Latvia "
replace Country="Lebanon" if Country=="Lebanon "
replace Country="Lesotho" if Country=="Lesotho "
replace Country="Liberia" if Country=="Liberia "
replace Country="Libya" if Country=="Libya "
replace Country="Lithuania" if Country=="Lithuania "
replace Country="Luxembourg" if Country=="Luxmebourg "
replace Country="Madagascar" if Country=="Madagascar "
replace Country="Malawi" if Country=="Malawi "
replace Country="Mali" if Country=="Mali "
replace Country="Malta" if Country=="Malta "
replace Country="Marshall Islands" if Country=="Marshall Islands "
replace Country="Mauritania" if Country=="Mauritania "
replace Country="Mauritius" if Country=="Mauritius "
replace Country="Mexico" if Country=="Mexico "
replace Country="Micronesia, Fed. Sts." if Country=="Micronesia (Federated States of) "
replace Country="Monaco" if Country=="Monaco "
replace Country="Mongolia" if Country=="Mongolia "
replace Country="Morocco" if Country=="Morocco "
replace Country="Mozambique" if Country=="Mozambique "
replace Country="Myanmar" if Country=="Myanmar "
replace Country="Namibia" if Country=="Namibia "
replace Country="Nauru" if Country=="Nauru "
replace Country="Nepal" if Country=="Nepal "
replace Country="Netherlands" if Country=="Netherlands "
replace Country="New Zealand" if Country=="New Zealand "
replace Country="Nicaragua" if Country=="Nicaragua "
replace Country="Niger" if Country=="Niger "
replace Country="Nigeria" if Country=="Nigeria "
replace Country="Norway" if Country=="Norway "
replace Country="Oman" if Country=="Oman "
replace Country="Pakistan" if Country=="Pakistan "
replace Country="Palau" if Country=="Palau "
replace Country="Panama" if Country=="Panama "
replace Country="Papua New Guinea" if Country=="Papua New Guinea "
replace Country="Paraguay" if Country=="Paraguay "
replace Country="Peru" if Country=="Peru "
replace Country="Philippines" if Country=="Philippines "
replace Country="Poland" if Country=="Poland "
replace Country="Portugal" if Country=="Portugal "
replace Country="Qatar" if Country=="Qatar "
replace Country="Korea, Rep." if Country=="Republic of Korea "
replace Country="Moldova" if Country=="Republic of Moldova "
replace Country="Romania" if Country=="Romania "
replace Country="Russia" if Country=="Russian Federation "
replace Country="Rwanda" if Country=="Rwanda "
replace Country="St. Kitts and Nevis" if Country=="Saint Kitts and Nevis "
replace Country="St. Lucia" if Country=="Saint Lucia "
replace Country="St. Vincent and the Grenadines" if Country=="Saint Vincent and the Grenadines "
replace Country="Samoa" if Country=="Samoa "
replace Country="San Marino" if Country=="San Marino "
replace Country="Sao Tome and Principe" if Country=="Sao Tome and Principe "
replace Country="Saudi Arabia" if Country=="Saudi Arabia "
replace Country="Senegal" if Country=="Senegal "
replace Country="Seychelles" if Country=="Seychelles "
replace Country="Sierra Leone" if Country=="Sierra Leone "
replace Country="Singapore" if Country=="Singapore "
replace Country="Slovak Republic" if Country=="Slovakia "
replace Country="Slovenia" if Country=="Slovenia "
replace Country="Solomon Islands" if Country=="Solomon Islands "
replace Country="Somalia" if Country=="Somalia "
replace Country="South Africa" if Country=="South Africa "
replace Country="Spain" if Country=="Spain "
replace Country="Sri Lanka" if Country=="Sri Lanka "
replace Country="Sudan" if Country=="Sudan "
replace Country="Suriname" if Country=="Suriname "
replace Country="Sweden" if Country=="Sweden "
replace Country="Switzerland" if Country=="Switzerland "
replace Country="Syria" if Country=="Syrian Arab Republic "
replace Country="Tajikistan" if Country=="Tajikistan "
replace Country="Thailand" if Country=="Thailand "
replace Country="North Macedonia" if Country=="The former Yugoslav Republic of Macedonia "
replace Country="Togo" if Country=="Togo "
replace Country="Tonga" if Country=="Tonga "
replace Country="Trinidad and Tobago" if Country=="Trinidad and Tobago "
replace Country="Tunisia" if Country=="Tunisia "
replace Country="Turkey" if Country=="Turkey "
replace Country="Turkmenistan" if Country=="Turkmenistan "
replace Country="Tuvalu" if Country=="Tuvalu "
replace Country="Uganda" if Country=="Uganda "
replace Country="United Arab Emirates" if Country=="United Arab Emirates "
replace Country="United Kingdom" if Country=="United Kingdom of Great Britain and Northern Ireland"
replace Country="Tanzania" if Country=="United Republic of Tanzania "
replace Country="United States" if Country=="United States of America "
replace Country="Uruguay" if Country=="Uruguay "
replace Country="Uzbekistan" if Country=="Uzbekistan "
replace Country="Vanuatu" if Country=="Vanuatu "
replace Country="Venezuela, RB" if Country=="Venezuela "
replace Country="Vietnam" if Country=="Viet Nam "
replace Country="Yemen" if Country=="Yemen "
replace Country="Zambia" if Country=="Zambia "
replace Country="Zimbabwe" if Country=="Zimbabwe "

merge 1:1 Country using "Country Codes.dta"

drop if _merge==2
drop _merge

tempfile  egov`egovyr'
save	 `egov`egovyr'', replace

}

use `egov03', clear
foreach egovyr in 18 16 14 12 10 08 05 04 {

	append using `egov`egovyr''

}

rename (egovernmentrank egovernmentindex humancapitalindex ///
 telecommunicationinfrastructurei) (egovrank egovindex humcapindex telecommindex)

foreach v of varlist egovrank-telecommindex {
	local u: variable label `v'
	local x = "[UN e-Governance] " + "`u'"
	label var `v' "`x'"
}

format Country %32s
format egovrank-telecommindex %5.0g
sort Country year

tempfile UNegov
save	`UNegov'

use "Master Dataset.dta", clear
merge 1:1 Country_Code year using `UNegov'
drop if _merge==2
drop _merge

save "Master Dataset.dta", replace

/*************************************/
/***WDI - Human Capital Expenditure***/
/*************************************/

import excel "WDIs Health and Education expenditures 2000-2018.xlsx", sheet("Data") ///
 firstrow clear

rename (CountryName CountryCode Time) (Country Country_Code year)
drop TimeCode
drop if year==.

foreach v in Currenthealthexpenditureof Expenditureonprimaryeducation ///
 Expenditureonsecondaryeducati Expenditureontertiaryeducatio /// 
 Governmentexpenditureoneducat J {

	replace `v'="" if `v'==".."
	destring `v', replace

}

rename (Currenthealthexpenditureof Expenditureonprimaryeducation ///
 Expenditureonsecondaryeducati Expenditureontertiaryeducatio ///
 Governmentexpenditureoneducat J) (HealthExp_GDP Pri_Edu_GovExp Sec_Edu_GovExp ///
 Ter_Edu_GovExp Edu_Exp_Gov_GDP Edu_Exp_Gov_GovExp)
 
foreach v of varlist _all{
	local u: variable label `v'
	local x = "[WDI] " + "`u'"
	label var `v' "`x'"
}

tempfile WDIhumancap
save	`WDIhumancap'

use "Master Dataset.dta", clear
merge m:1 Country_Code year using `WDIhumancap'
drop if _merge==2
drop _merge

save "Master Dataset.dta", replace

/***********************************************/
/***ASPIRE Benficiary Inicidence and Coverage***/
/***********************************************/

import excel "ASPIRE beneficiary incidence and coverage 1999-2016.xlsx", sheet("Data") ///
 firstrow clear
 
 rename (CountryName CountryCode Time) (Country Country_Code year)
drop TimeCode I
drop if year==.

foreach v in Beneficiaryincidencein1stqui F G H J K L ///
 Beneficiaryincidencein2ndqui N O P Beneficiaryincidencein3rdqui R S ///
 Beneficiaryincidencein4thqui U V Beneficiaryincidencein5thqui X Y Z AA AB ///
 CoverageAllSocialAssist AD AE CoverageAllSocialProtect AG AH ///
 Coveragein1stquintilepoores AJ AK AL Coveragein2ndquintileA ///
 Coveragein2ndquintileAl AO AP Coveragein3rdquintileA Coveragein3rdquintileAl ///
 AS AT Coveragein4thquintileA Coveragein4thquintileAl AW AX ///
 Coveragein5thquintileriches AZ BA BB {

	replace `v'="" if `v'==".."
	destring `v', replace

}

rename (Beneficiaryincidencein1stqui F G H J K L Beneficiaryincidencein2ndqui ///
 N O P Beneficiaryincidencein3rdqui R S Beneficiaryincidencein4thqui U V ///
 Beneficiaryincidencein5thqui X Y Z AA AB CoverageAllSocialAssist AD AE ///
 CoverageAllSocialProtect AG AH Coveragein1stquintilepoores AJ AK AL ///
 Coveragein2ndquintileA Coveragein2ndquintileAl AO AP Coveragein3rdquintileA ///
 Coveragein3rdquintileAl AS AT Coveragein4thquintileA Coveragein4thquintileAl AW ///
 AX Coveragein5thquintileriches AZ BA BB) (AllSA_BenInc_1st AllSI_BenInc_1st ///
 AllSA_Urb_BenInc_1st AllSA_Rur_BenInc_1st SPL_BenInc_1st SPL_Rur_BenInc_1st ///
 SPL_Urb_BenInc_1st AllSA_BenInc_2nd SPL_Urb_BenInc_2nd SPL_Rur_BenInc_2nd ///
 SPL_BenInc_2nd SPL_BenInc_3rd SPL_Rur_BenInc_3rd SPL_Urb_BenInc_3rd SPL_BenInc_4th ///
 SPL_Rur_BenInc_4th SPL_Urb_BenInc_4th AllSA_BenInc_5th AllSA_BenInc_4th ///
 AllSA_BenInc_3rd SPL_BenInc_5th SPL_Rur_BenInc_5th SPL_Urb_BenInc_5th Cov_AllSA ///
 Cov_Rur_AllSA Cov_Urb_AllSA Cov_SPL Cov_Rur_SPL Cov_Urb_SPL Cov_AllSA_1st ///
 Cov_SPL_1st Cov_Rur_SPL_1st Cov_Urb_SPL_1st Cov_AllSA_2nd Cov_SPL_2nd ///
 Cov_Rur_SPL_2nd Cov_Urb_SPL_2nd Cov_AllSA_3rd Cov_SPL_3rd Cov_Rur_SPL_3rd ///
 Cov_Urb_SPL_3rd Cov_AllSA_4th Cov_SPL_4th Cov_Rur_SPL_4th Cov_Urb_SPL_4th ///
 Cov_AllSA_5th Cov_SPL_5th Cov_Rur_SPL_5th Cov_Urb_SPL_5th)
 
format Country %36s

foreach v of varlist _all{
	local u: variable label `v'
	local x = "[ASPIRE] " + "`u'"
	label var `v' "`x'"
}

tempfile ASPIREBenIncandCov
save	`ASPIREBenIncandCov', replace

use "Master Dataset.dta", clear
merge m:1 Country_Code year using `ASPIREBenIncandCov'
drop if _merge==2
drop _merge

save "Master Dataset.dta", replace

/*************************************/
/***GFS Social Benefits Expenditure***/
/*************************************/

use "GFS Social Benefits Expenditure.dta", clear

replace Country="Afghanistan" if Country=="Afghanistan, Islamic Republic of"
replace Country="Armenia" if Country=="Armenia, Republic of"
replace Country="Azerbaijan" if Country=="Azerbaijan, Republic of"
replace Country="Hong Kong SAR, China" if Country=="China, P.R.: Hong Kong"
replace Country="Congo, Rep." if Country=="Congo, Republic of"
replace Country="Iran" if Country=="Iran, Islamic Republic of"
replace Country="Korea, Rep." if Country=="Korea, Republic of"
replace Country="Kosovo" if Country=="Kosovo, Republic of"
replace Country="North Macedonia" if Country=="North Macedonia, Republic of"
replace Country="Russia" if Country=="Russian Federation"
replace Country="Serbia" if Country=="Serbia, Republic of"
replace Country="Timor-Leste" if Country=="Timor-Leste, Dem. Rep. of"
replace Country="Yemen" if Country=="Yemen, Republic of"
replace Country="Macao SAR, China" if Country=="China, P.R.: Macao"

merge m:1 Country using "Country Codes.dta"
drop _merge

tempfile GFS_SB_Expenditure
save `GFS_SB_Expenditure'

use "Master Dataset.dta", clear
merge m:1 Country_Code year using `GFS_SB_Expenditure'
drop if _merge==2
drop _merge

save "Master Dataset.dta", replace

/********************/
/***OECD Tax Wedge***/
/********************/

import excel "OECD tax wedge.xlsx", sheet("OECD.Stat export") clear

keep A B K

rename A Country
rename B year
rename K TaxWedge

drop in 1/5
drop if year==""

destring TaxWedge, replace
destring year, replace

replace Country="Korea, Rep." if Country=="Korea"

merge m:1 Country using "Country Codes.dta"
drop if _merge==2
drop _merge

lab var TaxWedge "[OECD] Average Tax Wedge (% labour costs)"

tempfile taxwedge
save	`taxwedge', replace

use "Master dataset.dta", clear

merge 1:1 Country_Code year using `taxwedge'
drop if _merge==2
drop _merge

save "Master dataset.dta", replace

/**********************/
/***WB GLOBAL FINDEX***/
/**********************/

import excel "WB Global Findex Database.xlsx", sheet("Data") clear

keep A B F G J M-R AW BI CI CU DG DS EE EQ FC FO GA GM GY HK HW IU JG JS KE KQ ///
 NW OI QQ RK RW SI SU TI US WI WM XI YC ZG ABF ACP
 
drop in 1
 
foreach v in F G J M-R AW BI CI CU DG DS EE EQ FC FO GA GM GY HK HW IU JG JS KE ///
 KQ  NW OI QQ RK RW SI SU TI US WI WM XI YC ZG ABF ACP {

	destring `v', replace
 
}

lab var F   "[Findex] Account (% age 15+)"
lab var G   "[Findex] Account, male (% age 15+)"
lab var J   "[Findex] Account, female (% age 15+)"
lab var M   "[Findex] Account, primary education or less (% age 15+)"
lab var N   "[Findex] Account, secondary education or more (% age 15+)"
lab var O   "[Findex] Account, income, poorest 40% (% age 15+)"
lab var P   "[Findex] Account, income, richest 60% (% age 15+)"
lab var Q   "[Findex] Account, rural (% age 15+)"
lab var R   "[Findex] Financial Institution Account (% age 15+)"
lab var AW  "[Findex] Used the internet to pay bills in the past year (% age 15+)"
lab var BI  "[Findex] Used the internet to pay bills or buy something in the past year (% age 15+)"
lab var CI  "[Findex] Saved to start, operate, or expand a farm or business (% age 15+)"
lab var CU  "[Findex] Saved for old age (% age 15+)"
lab var DG  "[Findex] Saved at a financial institution (% age 15+)"
lab var DS  "[Findex] Saved using a savings club or a person outside the family (% age 15+)"
lab var EE  "[Findex] Saved for education or school fees (% age 15+)"
lab var EQ  "[Findex] Saved any money in the past year (% age 15+)"
lab var FC  "[Findex] Outstanding housing loan (% age 15+)"
lab var FO  "[Findex] Debit card ownership (% age 15+)"
lab var GA  "[Findex] Borrowed for health or medical purposes (% age 15+)"
lab var GM  "[Findex] Borrowed to start, operate, or expand a farm or business (% age 15+)"
lab var GY  "[Findex] Borrowed from a store by buying on credit (% age 15+)"
lab var HK  "[Findex] Borrowed for education or school fees (% age 15+)"
lab var HW  "[Findex] Borrowed from a financial institution (% age 15+)"
lab var IU  "[Findex] Borrowed from family or friends (% age 15+)"
lab var JG  "[Findex] Borrowed from a savings club (% age 15+)"
lab var JS  "[Findex] Borrwed any money in the past year (% age 15+)"
lab var KE  "[Findex] Coming up with emergency funds: possible (% age 15+)"
lab var KQ  "[Findex] Coming up with emergency funds: not possible (% age 15+)"
lab var NW  "[Findex] Sent or received domestic remittances in the past year (% age 15+)"
lab var OI  "[Findex] Received domestic remittances in the past year (% age 15+)"
lab var QQ  "[Findex] Paid utility bills in the past year (% age 15+)"
lab var RK  "[Findex] Received wages in the past year (% age 15+)"
lab var RW  "[Findex] Paid school fees in the past year (% age 15+)"
lab var SI  "[Findex] Received private sector wages in the past year (% age 15+)"
lab var SU  "[Findex] Received public sector wages in the past year (% age 15+)"
lab var TI  "[Findex] Received wages: into a financial institution account (% age 15+)"
lab var US  "[Findex] Received government transfers in the past year (% age 15+)"
lab var WI  "[Findex] Debit card used to make a purchase in the past year (% age 15+)"
lab var WM  "[Findex] Received payments for agricultural products in the past year (% age 15+)"
lab var XI  "[Findex] Received payments for self-employment in the past year (% age 15+)"
lab var YC  "[Findex] Has a national identity card (% age 15+)"
lab var ZG  "[Findex] Credit card ownership (% age 15+)"
lab var ABF "[Findex] Made or received digital payments in the past year (% age 15+)"
lab var ACP "[Findex] Mobile money account (% age 15+)"

rename (A B F G J M-R AW BI CI CU DG DS EE EQ FC FO GA GM GY HK HW IU JG JS KE ///
 KQ NW OI QQ RK RW SI SU TI US WI WM XI YC ZG ABF ACP) (year Country_Code ///
 Account Account_m Account_f Account_pri Account_sec Account_bot40 Account_top60 ///
 Account_rural FinInstAccount InternetBillPay InternetBillorPurchase ///
 SavedforFarmorBusiness SavedforOldAge SavedatFinInst SavedatROSCA SavedforEduc ///
 SavedAny OutstandingLoanHome DebitCard BorrowedMedical BorrowedforFarmorBusiness ///
 BorrowedfromStore BorrowedforEduc BorrowedfromFinInst BorrowedfromFamily ///
 BorrwedfromROSCA BorrwedAny EmergencyFunds EmergencyFunds_impossible ///
 Remittances_Dom_SentorReceived Remittances_Dom_Rec UtilityBill_Paid Wages_Rec ///
 SchoolFees_Paid Wages_Private_Rec Wages_Public_Rec Wages_Rec_FinInst Transfer_Rec ///
 DebitCard_Used PaymentforAg PaymentforSelfEmp HasID CreditCard DigitalPayment ///
 MobileMoneyAccount)
 
tempfile findex
save	`findex', replace

use "Master dataset.dta", clear
merge 1:1 Country_Code year using `findex'
drop if _merge==2
drop _merge

save "Master dataset.dta", replace


/****************************/
/******CIT Productivity******/
/****************************/

import excel "KPMG tax rates.xlsx", firstrow clear


reshape long CIT_rate, i(Country) j(year)

replace Country="Bahamas, The" if Country=="Bahamas"
replace Country="Brunei" if Country=="Brunei Darussalam"
replace Country="Gambia, The" if Country=="Gambia"
replace Country="Hong Kong SAR, China" if Country=="Hong Kong SAR"
replace Country="Cote d'Ivoire" if Country=="Ivory Coast"
replace Country="Korea, Rep." if Country=="Korea, Republic of"
replace Country="Kyrgyz Republic" if Country=="Kyrgyzstan"
replace Country="Macao SAR, China" if Country=="Macau"
replace Country="North Macedonia" if Country=="Macedonia"
replace Country="West Bank and Gaza" if Country=="Palestinian Territory"
replace Country="St. Kitts and Nevis" if Country=="Saint Kitts and Nevis"
replace Country="St. Lucia" if Country=="Saint Lucia"
replace Country="St. Vincent and the Grenadines" if Country=="Saint Vincent and the Grenadines"
replace Country="Slovak Republic" if Country=="Slovakia"
replace Country="Eswatini" if Country=="Swaziland"
replace Country="Venezuela, RB" if Country=="Venezuela"
replace Country="Congo, Dem. Rep." if Country=="Congo (Democratic Republic of the)"

//adding country codes for safe merging
merge m:1 Country using "Country Codes.dta"
drop if _merge!=3
drop _merge
drop Country

tempfile CIT_rates
save `CIT_rates'


use "Master Dataset.dta"
merge m:1 Country_Code year using `CIT_rates'
drop if _merge==2
drop _merge


//CIT Productivity
gen CIT_Productivity = (CIT/CIT_rate) * 100

save "Master Dataset.dta", replace


/****************************/
/******VAT C Efficiency******/
/****************************/

//Consumption
import excel "VAT C-efficiency expenditure data.xlsx", sheet("Data") firstrow clear
drop TimeCode
rename (Time CountryCode) (year Country_Code)
rename CountryName Country
rename Finalconsumptionexpenditure FCE_GDP 
keep Country year Country_Code FCE_GDP

tempfile Consumption
save `Consumption'

use "Master Dataset.dta", clear
merge m:1 Country_Code year using `Consumption'
drop if _merge==2
drop _merge

save "Master Dataset.dta", replace

//VAT rates
import excel "Historic VAT statutory rates.xlsx", sheet("Sheet1") firstrow clear
rename (B-L) (VAT_rate2007 VAT_rate2008 VAT_rate2009 VAT_rate2010 VAT_rate2011 VAT_rate2012 VAT_rate2013 VAT_rate2014 VAT_rate2015 ///
 VAT_rate2016 VAT_rate2017)
drop FOOTNOTES
rename LOCATION Country

reshape long VAT_rate, i(Country) j(year)

replace Country="Bahamas, The" if Country=="Bahamas"
replace Country="Hong Kong SAR, China" if Country=="Hong Kong SAR"
replace Country="Korea, Rep." if Country=="Korea, Republic of"
replace Country="Macao SAR, China" if Country=="Macau"
replace Country="North Macedonia" if Country=="Macedonia"
replace Country="St. Kitts and Nevis" if Country=="Saint Kitts and Nevis"
replace Country="St. Lucia" if Country=="Saint Lucia"
replace Country="St. Vincent and the Grenadines" if Country=="Saint Vincent and the Grenadines"
replace Country="Slovak Republic" if Country=="Slovakia"
replace Country="St. Martin (French part)" if Country=="St Maarten"
replace Country="Venezuela, RB" if Country=="Venezuela"
replace Country="Eswatini" if Country=="Swaziland"

//adding country codes for safe merging
merge m:1 Country using "Country Codes.dta"
drop if _merge!=3
drop _merge

tempfile VATrates
save `VATrates'

use "Master Dataset.dta", clear
merge m:1 Country_Code year using `VATrates'
drop if _merge==2
drop _merge

//C Efficiency
gen C_Efficiency = (Value_Added_Tax) / (FCE_GDP * VAT_rate / 100)

save "Master Dataset.dta", replace

/*************************************/
/***USAID Collecting Taxes Database***/
/*************************************/

import excel "CTD_MASTER_2017-18_-_Admin_and_Performance.xlsx", sheet("Admin") ///
 firstrow clear

keep country code year cost payertostaff poptostaff labortostaff e_*

foreach v in e_reg e_file e_pay {

	replace `v'="" if `v'=="n/d" | `v'=="n/a"
	destring `v', replace
	
}

tempfile usaid_admin
save	`usaid_admin', replace

import excel "CTD_MASTER_2017-18_-_Admin_and_Performance.xlsx", sheet("Performance") ///
 firstrow clear
 
keep country code year tax_capacity-vat_gcr

foreach v in tax_capacity tax_effort tax_buoy vat_buoy cit_buoy pit_buoy vat_eff ///
 vat_c_eff vat_gcr {

	replace `v'="" if `v'=="N/d" | `v'=="N/a"
	destring `v', replace
	
}

merge 1:1 code year using `usaid_admin'
drop _merge

rename country Country
rename code Country_Code

lab var vat_eff "actual to potential VAT revenue (standard rate) to GDP"
lab var vat_c_eff "actual to potential VAT revenue (standard rate) to Total Consumption Expenditure"
lab var vat_gcr "actual to potential VAT revenue (standard rate) to Private Consumption Expenditure"

foreach v of varlist _all{
	local u: variable label `v'
	local x = "[USAID CTD] " + "`u'"
	label var `v' "`x'"
}

replace Country_Code="COD" if Country=="Congo, Dem. Rep."
replace Country_Code="XKX" if Country=="Kosovo"
replace Country_Code="PSE" if Country=="West Bank and Gaza"
replace Country_Code="TLS" if Country=="Timor-Leste"
replace Country_Code="ROU" if Country=="Romania"

tempfile usaid_ctd
save	`usaid_ctd', replace

use "Master dataset.dta", clear
merge 1:1 Country_Code year using `usaid_ctd'
drop if _merge==2
drop _merge

save "Master dataset.dta", replace

/**************************/
/*** WEF Infrastructure ***/
/**************************/

import excel "WEF_data_2018.xlsx", sheet("data") firstrow clear
 
keep if Indicator=="2nd pillar Infrastructure" | ///
 Indicator=="GCI 4.0: 2.A Transport infrastructure" | ///
 Indicator=="GCI 4.0: 2.B Utility infrastructure" | ///
 Indicator=="GCI 4.0: Electricity infrastructure" | ///
 Indicator=="GCI 4.0: Pillar 2: Infrastructure" | ///
 Indicator=="GCI 4.0: Water infrastructure" | ///
 Indicator=="Quality of air transport infrastructure" | ///
 Indicator=="Quality of overall infrastructure" | ///
 Indicator=="Quality of port infrastructure" | ///
 Indicator=="Quality of railroad infrastructure"
drop IndicatorId

keep if SubindicatorType=="Score" 
drop SubindicatorType
drop F-O Q
rename (CountryISO3 P R) (Country_Code yr2017 yr2018)

reshape long yr, i(Country_Code Indicator) j(year)
rename yr Score
encode Indicator, gen(indicator)
drop Indicator CountryName
reshape wide Score, i(Country_Code year) j(indicator)
rename Score1 Transport_Infrastrcture
rename Score2 Utility_Infrastructure
rename Score3 Electricity_Infrastructure
rename Score4 Overall_Infrastructure
rename Score5 Water_Infrastructure

tempfile WEF_infrastructure_1718
save	`WEF_infrastructure_1718', replace

import excel "WEF_data_2018.xlsx", sheet("data") firstrow clear
 
keep if Indicator=="2nd pillar Infrastructure" | ///
 Indicator=="GCI 4.0: 2.A Transport infrastructure" | ///
 Indicator=="GCI 4.0: 2.B Utility infrastructure" | ///
 Indicator=="GCI 4.0: Electricity infrastructure" | ///
 Indicator=="GCI 4.0: Pillar 2: Infrastructure" | ///
 Indicator=="GCI 4.0: Water infrastructure" | ///
 Indicator=="Quality of air transport infrastructure" | ///
 Indicator=="Quality of overall infrastructure" | ///
 Indicator=="Quality of port infrastructure" | ///
 Indicator=="Quality of railroad infrastructure"
drop IndicatorId

keep if SubindicatorType=="1-7 Best"
drop SubindicatorType CountryName
drop P R
rename (CountryISO3 F G H I J K L M N O Q) (Country_Code yr2008 yr2009 yr2010 ///
 yr2011 yr2012 yr2013 yr2014 yr2015 yr2016 yr2017 yr2018)

reshape long yr, i(Country_Code Indicator) j(year)
encode Indicator, gen(indicator)
drop Indicator
rename yr Score
reshape wide Score, i(Country_Code year) j(indicator)
rename Score1 Air_Transport_Infrastructure_of7
rename Score2 Overall_Infrastructure_of7
rename Score3 Port_Infrastructure_of7
rename Score4 Railroad_Infrastructure_of7

merge 1:1 Country_Code year using `WEF_infrastructure_1718'
drop _merge
sort Country_Code year

foreach v of varlist _all{
	local u: variable label `v'
	local x = "[WEF Infrastructure] " + "`u'"
	label var `v' "`x'"
}

tempfile WEF_infrastructure
save	`WEF_infrastructure', replace

use "Master dataset.dta", clear
merge 1:1 Country_Code year using `WEF_infrastructure'
drop if _merge==2
drop _merge

save "Master dataset.dta", replace

/**************************/
/*** IMF Infrastructure ***/
/**************************/

import excel "Investment stock - IMF.xlsx", sheet("Database") firstrow clear

foreach v in igov_rppp kgov_rppp ipriv_rppp kpriv_rppp ippp_rppp kppp_rppp ///
 GDP_rppp kgov_n kpriv_n kppp_n GDP_n {

	replace `v'="" if `v'=="-"
	destring `v', replace
 
}

gen public_capital_stock=kgov_rppp/GDP_rppp
gen public_capital_stock_inv=igov_rppp/GDP_rppp

foreach v of varlist _all{
	local u: variable label `v'
	local x = "[IMF Infrastructure] " + "`u'"
	label var `v' "`x'"
}

drop ifscode
rename isocode Country_Code

tempfile IMF_infrastructure
save	`IMF_infrastructure', replace

use "Master dataset.dta", clear
merge 1:1 Country_Code year using `IMF_infrastructure'
drop if _merge==2
drop _merge

save "Master dataset.dta", replace

/***************************/
/*** WDI Net ODA and Aid ***/
/***************************/

import excel "Net ODA and Aid, WDIs.xlsx", sheet("Data") firstrow clear

rename CountryCode Country_Code
rename Time year
rename NetODA Net_ODA
lab var Net_ODA "[WDI] Net ODA and official aid received (% of GDP) (Current USD)"

keep Country_Code year Net_ODA
drop if Country_Code==""

tempfile ODA
save	`ODA', replace

use "Master dataset.dta", clear
merge 1:1 Country_Code year using `ODA'
drop if _merge==2
drop _merge

save "Master Dataset.dta", replace

/*****************************/
/*** WDI Inflation and CPI ***/
/*****************************/

import excel "WDI Inflation and CPI.xlsx", sheet("Data") firstrow clear

drop TimeCode CountryName
drop if CountryCode==""
rename (CountryCode Time Inflationconsumerpricesannu Consumerpriceindex2010100) ///
 (Country_Code year inflation CPI_2010)
 
replace inflation="" if inflation==".."
replace CPI="" if CPI==".."

destring inflation, replace
destring CPI, replace

foreach v of varlist inflation CPI_2010 {
	local u: variable label `v'
	local x = "[WDI] " + "`u'"
	label var `v' "`x'"
}

tempfile inflation
save	`inflation', replace

use "Master dataset.dta", clear
merge 1:1 Country_Code year using `inflation'
drop if _merge==2
drop _merge

save "Master Dataset.dta", replace

/********************************/
/*** TRIMMING EXTRA VARIABLES ***/
/********************************/

drop country resourcerevenuenotes socialcontributionsnotes inc generalnotes ///
  cautionnotes CountryName
replace Country="Lao People's Democratic Republic" if Country=="Lao People’s Democratic Republic"
sort Country year

compress

save "Master Dataset.dta", replace
