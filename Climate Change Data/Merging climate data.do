
/************************/
/***OECD AIR EMISSIONS***/
/************************/

import delimited "DP_LIVE_01082019180609023.csv", clear

rename ïlocation Country_Code
rename time year
keep if year>=1990
keep Country_Code subject year measure value
keep if measure=="TONNE_CAP" | measure=="KG_CAP"
drop if value==.

reshape wide value measure, i(Country_Code year) j(subject, string)
label var valueCO "[OECD] Kilograms per capita of CO air emissions"
label var valueCO2 "[OECD] Tonnes per capita of CO2 air emissions"
label var valueGHG "[OECD] Tonnes per capita of Greenhouse Gas emissions"
label var valueNOX "[OECD] Kilograms per capita of Nitrogen Oxide emissions"
label var valueSOX "[OECD] Kilograms per capita of Sulfur Oxide emissions"
label var valueVOC "[OECD] Kilograms per capita of Volatile Organic Compound emissions"

drop measureCO measureCO2 measureGHG measureNOX measureSOX measureVOC

drop if Country_Code=="WLD" | Country_Code=="EU28" | Country_Code=="OECDE" | ///
 Country_Code=="OECD"

save "Climate Change Dataset.dta", replace

/************************/
/***WDI CLIMATE CHANGE***/
/************************/

import excel "Data_Extract_From_World_Development_Indicators - environment and climate change.xlsx", ///
 sheet("Data") firstrow clear

drop YR1969-YR1989 YR2018
drop SeriesCode

foreach v of varlist YR1990-YR2017 {

	replace `v'="" if `v'==".."
	destring `v', replace

}

drop if CountryCode==""
rename CountryCode Country_Code

reshape long YR, i(CountryName SeriesName) j(year)
rename YR Score

encode SeriesName, gen(seriesnum)
tab seriesnum
drop SeriesName

reshape wide Score, i(CountryName year) j(seriesnum)

label var Score1 "[WDI Climate Change] Agricultural land (% of land area)"
label var Score2 "[WDI Climate Change] Arable land (% of land area)"
label var Score3 "[WDI Climate Change] Average precipitation in depth (mm per year)"
label var Score4 "[WDI Climate Change] Cereal production (metric tons)"
label var Score5 "[WDI Climate Change] Cereal yield (kg per hectare)"
label var Score6 "[WDI Climate Change] Electric power consumption (kWh per capita)"
label var Score7 "[WDI Climate Change] Electricity production from coal sources (% of total)"
label var Score8 "[WDI Climate Change] Electricity production from hydroelectric sources (% of total)"
label var Score9 "[WDI Climate Change] Electricity production from natural gas sources (% of total)"
label var Score10 "[WDI Climate Change] Electricity production from nuclear sources (% of total)"
label var Score11 "[WDI Climate Change] Electricity production from oil, gas and coal sources (% of total)"
label var Score12 "[WDI Climate Change] Forest area (% of land area)"
label var Score13 "[WDI Climate Change] Land area where elevation is below 5 meters (% of total land area)"
label var Score14 "[WDI Climate Change] Renewable electricity output (% of total electricity output)"
label var Score15 "[WDI Climate Change] Rural land area where elevation is below 5 meters (% of total land area)"
label var Score16 "[WDI Climate Change] Total greenhouse gas emissions (% change from 1990)"
label var Score17 "[WDI Climate Change] Total greenhouse gas emissions (kt of CO2 equivalent)"
label var Score18 "[WDI Climate Change] Urban land area where elevation is below 5 meters (% of total land area)"

rename (Score1-Score18 CountryName) (agriculturalland arableland precipitationavg ///
 cerealprod cerealyield elecpowerconsumption elecprodcoal elecprodhydro elecprodnatgas ///
 elecprodnuclear elecprodoilgascoal forestland landbelow5m elecprodrenewable ///
 ruralandbelow5m GHGemissionpctchange GHGemissiontotal urbanlandbelow5m Country)

save "WDI Climate Change.dta", replace

use "Climate Change Dataset.dta", clear
merge m:1 Country_Code year using "WDI Climate Change.dta"
drop _merge

save "Climate Change Dataset.dta", replace

/**********************/
/***GGKP ENVIRONMENT***/
/**********************/

import excel "GGKP_webplatform_data_2016.11.16.xlsx", ///
 sheet("GGKP_Data_November2016") firstrow clear

drop G H unit category

encode indicator, gen(indic)
drop indicator
reshape wide value, i(country year) j(indic)

label var value1 "% of population with access to electricity"
label var value2 "% of population with access to improved sanitation"
label var value3 "% of population with access to improved water source"
label var value4 "Agricultural land, % of land area"
label var value5 "Cubic meters of annual freshwater withdrawals per capita"
label var value6 "% change in average annual deforestation"
label var value7 "metric tons of CO2 emissions per capita"
label var value8 "GDP per kg of CO2 emissions"
label var value9 "Changes in wealth per capita, USD"
label var value10 "% of GDP, envrionmentally-related tax revenue"
label var value11 "Fossil fuel consumption subsidies, USD billions"
label var value12 "GDP per capita, current USD"
label var value13 "Gini Coefficient, 0-100"
label var value14 "Human Development Index"
label var value15 "Population"
label var value16 "Population Density"
label var value17 "Micrograms per cubic meter"
label var value18 "% of electricity from renewable sources"
label var value19 "% of total territorial area, terrestial and marine"
label var value20 "% of total labor force"

foreach v of varlist _all{
	local u: variable label `v'
	local x = "[GGKP] " + "`u'"
	label var `v' "`x'"
}

rename (value1-value20) (Accesstoelectricity Accesstoimprovedsanitation ///
 Accesstoimprovedwater AgLand Freshwaterwithdrawals Deforestation CO2emissions ///
 CarbonProductivity WealthPCchange Env_Tax_Revenue fossilfuelsubsidies GDP_percapita ////
 Gini HDI Population PopDensity Popexposuretoairpollution renewableelectricity ///
 protectedareas Unemployment)
 
rename country Country
drop if year<1990

replace Country="Bahamas, The" if Country=="Bahamas"
replace Country="Brunei" if Country=="Brunei Darussalam"
replace Country="Bolivia" if Country=="Bolivia (Plurinational State of)"
replace Country="Congo, Rep." if Country=="Congo"
replace Country="Congo, Dem. Rep." if Country=="Democratic Republic of the Congo"
replace Country="Gambia, The" if Country=="Gambia"
replace Country="Iran" if Country=="Iran (Islamic Republic of)"
replace Country="Kyrgyz Republic" if Country=="Kyrgyzstan"
replace Country="Lao PDR" if Country=="Lao People's Democratic Republic"
replace Country="Micronesia, Fed. Sts." if Country=="Micronesia (Federated States of)"
replace Country="Korea, Rep." if Country=="Republic of Korea"
replace Country="Korea, Dem. People’s Rep." if Country=="Democratic People's Republic of Korea"
replace Country="Moldova" if Country=="Republic of Moldova"
replace Country="Russia" if Country=="Russian Federation"
replace Country="St. Kitts and Nevis" if Country=="Saint Kitts and Nevis"
replace Country="St. Lucia" if Country=="Saint Lucia"
replace Country="St. Vincent and the Grenadines" if Country=="Saint Vincent and the Grenadines"
replace Country="Slovak Republic" if Country=="Slovakia"
replace Country="Eswatini" if Country=="Swaziland"
replace Country="Syria" if Country=="Syrian Arab Republic"
replace Country="North Macedonia" if Country=="The former Yugoslav Republic of Macedonia"
replace Country="United Kingdom" if Country=="United Kingdom of Great Britain and Northern Ireland"
replace Country="Tanzania" if Country=="United Republic of Tanzania"
replace Country="United States" if Country=="United States of America"
replace Country="Venezuela, RB" if Country=="Venezuela (Bolivarian Republic of)"
replace Country="Vietnam" if Country=="Viet Nam"

merge m:1 Country using "Country Codes.dta"
drop if _merge!=3
drop _merge

save "GGKP Dataset.dta", replace

use "Climate Change Dataset.dta", clear
merge m:1 Country_Code year using "GGKP Dataset.dta"
drop _merge

save "Climate Change Dataset.dta", replace

/*************************************/
/***OUR WORLD IN DATA PLASTIC WASTE***/
/*************************************/

import delimited plastic-waste-per-capita.csv, clear

tempfile pwpc
save `pwpc', replace

import delimited plastic-waste-littered.csv, clear

tempfile pwl
save `pwl', replace

import delimited plastic-waste-generation-total.csv, clear

tempfile pwgt
save `pwgt', replace

import delimited inadequately-managed-plastic.csv, clear

merge 1:1 entity using `pwpc'
drop _merge
merge 1:1 entity using `pwl'
drop _merge
merge 1:1 entity using `pwgt'
drop _merge

rename (entity shareofplasticinadequatelymanage percapitaplasticwastekilogramspe ///
 plasticwastelitteredtonnesperyea plasticwastegenerationtonnestota) (Country ///
 inad_mgmt_plastic_share plastic_waste_pc plastic_waste_litter plastic_waste_generated)
 
lab var Country "" 
lab var inad_mgmt_plastic_share "[OWiD 2010] Inadequate management of Plastic, share"
lab var plastic_waste_pc "[OWiD 2010] Per capita plastic waste (kg per person per day)"
lab var plastic_waste_litter "[OWiD 2010] Plastic waste littered (tons per year)"
lab var plastic_waste_generated "[OWiD 2010] Plastic waste generation (tons per year, total)"

replace Country="Bahamas, The" if Country=="Bahamas"
replace Country="Cabo Verde" if Country=="Cape Verde"
replace Country="Congo, Rep." if Country=="Congo"
replace Country="Congo, Dem. Rep." if Country=="Democratic Republic of Congo"
replace Country="Gambia, The" if Country=="Gambia"
replace Country="Hong Kong SAR, China" if Country=="Hong Kong"
replace Country="Macao SAR, China" if Country=="Macao"
replace Country="Micronesia, Fed. Sts." if Country=="Micronesia (country)"
replace Country="Korea, Dem. People’s Rep." if Country=="North Korea"
replace Country="West Bank and Gaza" if Country=="Palestine"
replace Country="St. Kitts and Nevis" if Country=="Saint Kitts and Nevis"
replace Country="St. Lucia" if Country=="Saint Lucia"
replace Country="St. Vincent and the Grenadines" if Country=="Saint Vincent and the Grenadines"
replace Country="Korea, Rep." if Country=="South Korea"
replace Country="Venezuela, RB" if Country=="Venezuela"

merge m:1 Country using "Country Codes.dta"
replace Country_Code="PRK" if Country=="Korea, Dem. People's Rep."
drop if _merge!=3
drop _merge 

save "OWiD 2010 data.dta", replace

use "Climate Change Dataset.dta", clear
merge m:1 Country_Code year using "OWiD 2010 data.dta"
drop _merge

save "Climate Change Dataset.dta", replace

