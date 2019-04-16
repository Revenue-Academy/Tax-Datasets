clear all
set more off

/* This dofile turns data at the case level to the country-year level, which involves some generalizing.
Sources indices and witholding rates are averaged both by year (for each country) and overall for each country.
Many categorical variables that vary from treaty to treaty were omitted.*/

cd "D:\WB Tax Consultancy"

import excel "ActionAid_treaties_dataset_feb_2016.xlsx", sheet("Indices") cellrange(A1:S538) firstrow clear

//treaties before 1990 will be treaty as initial conditions in 1990 in order to merge this dataset with the
//UNU-WIDER data set (which only goes back to 1990)
replace Signedyear=1990 if Signedyear<1990

by C1 Signedyear, sort: gen treatycounter = _n
bysort C1 Signedyear, egen numberoftreaties=max(treatycounter)

keep if C1_Region=="Africa"
keep C1 C2 C2_BEPS Signedyear Sourceindex WHTrates
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

save "Tax Treaties (Country Year Level).dta", replace
