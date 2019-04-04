clear all
set more off

cd "C:\Users\Joe\Desktop\WB STC\GGOGT\Dataset Compilations\Afrobarometer"

/*Import and convert Afrobarometer's .sav files and make lower case*/
*ssc install usespss
/*Round 2*/
usespss "merged_r2_data.sav"
keep country q42d acrosswt combinwt

qui label list q42a
replace q42d=. if q42d==-1 | q42d==9 | q42d==98
collapse (mean) q42d acrosswt combinwt, by (country)
rename q42d pp_must_pay_tax
*tab pp_must_pay_tax, gen(pp_must_pay_tax_fac)
gen year=2003
gen round=2
rename acrosswt acrosswt2003
rename combinwt combinwt2003

save "merged_r2_data.dta", replace

tempfile r2
save `r2', replace

/*Round 3*/
usespss "merged_r3_data.sav"
keep country q56g acrosswt combinwt
replace q56g=. if q56g==-1 | q56g==9 | q56g==998
collapse (mean) q56g acrosswt combinwt, by (country)
rename q56g corrupt_tax_offic
*tab corrupt_tax_offic, gen(corrupt_tax_offic_fac)
gen year=2006
gen round=3
rename acrosswt acrosswt2006
rename combinwt combinwt2006

save "merged_r3_data.dta", replace

tempfile r3
save `r3', replace

/*Round 4*/
usespss "merged_r4_data.sav"
rename *, lower
keep country q44c q50f q64c acrosswt combinwt
replace q44c=. if q44c==-1 | q44c==9
replace q50f=. if q50f==-1 | q50f==9
replace q64c=. if q64c==-1 | q64c==8 | q64c==9
collapse (mean) q44c q50f q64c acrosswt combinwt, by (country)
rename q44c pp_must_pay_tax
*tab pp_must_pay_tax, gen(pp_must_pay_tax_fac)
rename q50f corrupt_tax_offic
*tab corrupt_tax_offic, gen(corrupt_tax_offic_fac)
rename q64c pay_property_tax
gen year=2009
gen round=4
rename acrosswt acrosswt2009
rename combinwt combinwt2009

save "merged_r4_data.dta", replace

tempfile r4
save `r4', replace

/*Round 5*/
usespss "merged-r5-data-34-countries-2011-2013-last-update-july-2015.sav"
rename *, lower
keep country q26c q48c q50 q51 q56i q59d q60f q73a q73c q73e q77 combinwt
replace q26c=. if q26c==-1 | q26c==9
replace q48c=. if q48c==-1 | q48c==9
replace q50=. if q50==-1 | q50==9 | q50==.a
replace q51=. if q51==-1 | q51==9 | q51==.a
replace q56i=. if q56i==-1 | q56i==9
replace q59d=. if q59d==-1 | q59d==9
replace q60f=. if q60f==-1 | q60f==9
replace q73a=. if q73a==-1 | q73a==9 | q73a==8 | q73a==.a
replace q73c=. if q73c==-1 | q73c==9 | q73c==8 | q73c==.a
replace q73e=. if q73e==-1 | q73e==9 | q73e==7 | q73e==.a
qui label list Q77
replace q77=. if q77==-1 | q77==9995 | q77==9997 | q77==9998 | q77==9999
collapse (mean) q26c q48c q50 q51 q56i q59d q60f q73a q73c q73e q77 combinwt, by (country)
rename q26c refuse_pay_tax
*tab refuse_pay_tax, gen(refuse_pay_tax_fac)
rename q48c pp_must_pay_tax
*tab pp_must_pay_tax, gen(pp_must_pay_tax_fac)
rename q50 must_vs_no_need_tax
*tab must_vs_no_need_tax, gen(must_vs_no_need_tax_fac)
rename q51 hightax_vs_lowtax
*tab hightax_vs_lowtax, gen(hightax_vs_lowtax_fac)
rename q56i often_avoid_tax
*tab often_avoid_tax, gen(often_avoid_tax_fac)
rename q59d trust_tax_dept
*tab trust_tax_dept, gen(trust_tax_dept_fac)
rename q60f corrupt_tax_offic
*tab corrupt_tax_offic, gen(corrupt_tax_offic_fac)
rename q73a pay_gensales_tax
rename q73c pay_property_tax
rename q73e pay_selfemp_tax
rename q77 why_avoid_tax
*tab why_avoid_tax, gen(why_avoid_tax_fac)
gen year=2013
gen round=5
rename combinwt combinwt2013

save "merged_r5_data.dta", replace

tempfile r5
save `r5', replace

/*Round 6*/
usespss "merged_r6_data_2016_36countries2.sav"
rename *, lower
keep country q27d q42c q44 q52d q53f q65c q70b combinwt
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
gen year=2015
gen round=6
rename combinwt combinwt2015
collapse (mean) q27d q42c q44 q52d q53f q65c q70b combinwt2015, by(country round year)
rename q27d refuse_pay_tax
*tab refuse_pay_tax, gen(refuse_pay_tax_fac)
rename q42c pp_must_pay_tax
*tab pp_must_pay_tax, gen(pp_must_pay_tax_fac)
rename q44 must_vs_no_need_tax
*tab must_vs_no_need_tax, gen(must_vs_no_need_tax_fac)
rename q52d trust_tax_dept
*tab trust_tax_dept, gen(trust_tax_dept_fac)
rename q53f corrupt_tax_offic
*tab corrupt_tax_offic, gen(corrupt_tax_offic_fac)
rename q65c hightax_vs_lowtax
*tab hightax_vs_lowtax, gen(hightax_vs_lowtax_fac)
rename q70b often_avoid_tax
*tab often_avoid_tax, gen(often_avoid_tax_fac)

save "merged_r6_data.dta", replace

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
*format %16.6f pp_must_pay_tax refuse_pay_tax must_vs_no_need_tax trust_tax_dept corrupt_tax_offic hightax_vs_lowtax often_avoid_tax pay_gensales_tax pay_property_tax pay_selfemp_tax why_avoid_tax

sort country year

/*Adding labels to variables
tab corrupt_tax_offic, gen(corrupt_tax_offic_fac)
lab var corrupt_tax_offic_fac1 "How corrupt are tax officials?  - - % answering  1 (none) "
lab var corrupt_tax_offic_fac2 "How corrupt are tax officials?  - - % answering  2 (some of them) "
lab var corrupt_tax_offic_fac3 "How corrupt are tax officials?  - - % answering  3 (a lot of them) "
lab var corrupt_tax_offic_fac4 "How corrupt are tax officials?  - - % answering  4 (all of them) "
lab var corrupt_tax_offic      "How corrupt are tax officials? Mean response (1-5) " 

tab hightax_vs_lowtax, gen(hightax_vs_lowtax_fac)
lab var hightax_vs_lowtax_fac1 "Higher taxes with more government services vs lower taxes with fewer services  - - % answering  1 (strongly agree with statement 1) "
lab var hightax_vs_lowtax_fac2 "Higher taxes with more government services vs lower taxes with fewer services  - - % answering  2 (agree with statement 1) "
lab var hightax_vs_lowtax_fac3 "Higher taxes with more government services vs lower taxes with fewer services  - - % answering  3 (agree with statement 2) "
lab var hightax_vs_lowtax_fac4 "Higher taxes with more government services vs lower taxes with fewer services  - - % answering  4 (strongly agree with statement 2) "
lab var hightax_vs_lowtax_fac5 "Higher taxes with more government services vs lower taxes with fewer services  - - % answering  5 (agree with neither statements)"

tab must_vs_no_need_tax, gen(must_vs_no_need_tax_fac)
lab var must_vs_no_need_tax_fac1 "Citizens must pay taxes vs no need to tax the people  - - % answering  1 (strongly agree with statement 1) "
lab var must_vs_no_need_tax_fac2 "Citizens must pay taxes vs no need to tax the people  - - % answering  2 (agree with statement 1) "
lab var must_vs_no_need_tax_fac3 "Citizens must pay taxes vs no need to tax the people  - - % answering  3 (agree with statement 2) "
lab var must_vs_no_need_tax_fac4 "Citizens must pay taxes vs no need to tax the people  - - % answering  4 (strongly agree with statement 2) "
lab var must_vs_no_need_tax_fac5 "Citizens must pay taxes vs no need to tax the people  - - % answering  5 (agree with neither) "

tab often_avoid_tax, gen(often_avoid_tax_fac)
lab var often_avoid_tax_fac1 "How often do people avoid paying taxes?  - - % answering  1 (never) "
lab var often_avoid_tax_fac2 "How often do people avoid paying taxes?  - - % answering  2 (rarely) "
lab var often_avoid_tax_fac3 "How often do people avoid paying taxes?  - - % answering  3 (often) "
lab var often_avoid_tax_fac4 "How often do people avoid paying taxes?  - - % answering  4 (always) "
lab var often_avoid_tax_fac5 "How often do people avoid paying taxes?  - - % answering  5 (Don’t have to pay taxes) "

tab pp_must_pay_tax, gen(pp_must_pay_tax_fac)
lab var pp_must_pay_tax_fac1 "People must pay taxes  - - % answering  1 (strongly disagree) "
lab var pp_must_pay_tax_fac2 "People must pay taxes  - - % answering  2 (disagree) "
lab var pp_must_pay_tax_fac3 "People must pay taxes  - - % answering  3 (neutral) "
lab var pp_must_pay_tax_fac4 "People must pay taxes  - - % answering  4 (agree) "
lab var pp_must_pay_tax_fac5 "People must pay taxes  - - % answering  5 (strongly agree) "
lab var pp_must_pay_tax      "People must pay tax (mean response), 1-5 "

tab refuse_pay_tax, gen(refuse_pay_tax_fac)
lab var refuse_pay_tax_fac1 "Refused to pay tax or fee to government?  - - % answering  1 (no, would never do that) "
lab var refuse_pay_tax_fac2 "Refused to pay tax or fee to government?  - - % answering  2 (No, but would do if had the chance) "
lab var refuse_pay_tax_fac3 "Refused to pay tax or fee to government?  - - % answering  3 (yes, once or twice) "
lab var refuse_pay_tax_fac4 "Refused to pay tax or fee to government?  - - % answering  4 (yes, several times) "
lab var refuse_pay_tax_fac5 "Refused to pay tax or fee to government?  - - % answering  5 (yes, always) "

tab trust_tax_dept, gen(trust_tax_dept_fac)
lab var trust_tax_dept_fac1 "Trust tax department?  - - % answering  1 (not at all) "
lab var trust_tax_dept_fac2 "Trust tax department?  - - % answering  2 (just a little)  "
lab var trust_tax_dept_fac3 "Trust tax department?  - - % answering  3 (somewhat) "
lab var trust_tax_dept_fac4 "Trust tax department?  - - % answering  4 (a lot) "

lab var pay_gensales_tax "Do you have to pay a general sales tax?"
lab var pay_property_tax "Do you have to pay a property tax?"
lab var pay_selfemp_tax "Do you have to pay a self-employment tax?"

tab why_avoid_tax, gen(why_avoid_tax_fac)
lab var why_avoid_tax_fac1 "Why do people avoid paying taxes? -- % answer = People don't avoid paying "
lab var why_avoid_tax_fac2 "Why do people avoid paying taxes? -- % answer = The tax system is unfair "
lab var why_avoid_tax_fac3 "Why do people avoid paying taxes? -- % answer = The taxes are too high "
lab var why_avoid_tax_fac4 "Why do people avoid paying taxes? -- % answer = People cannot afford to pay "
lab var why_avoid_tax_fac5 "Why do people avoid paying taxes? -- % answer = The poor services they receive from government "
lab var why_avoid_tax_fac6 "Why do people avoid paying taxes? -- % answer = Government does not listen to them "
lab var why_avoid_tax_fac7 "Why do people avoid paying taxes? -- % answer = Government wastes tax money "
lab var why_avoid_tax_fac8 "Why do people avoid paying taxes? -- % answer = Government officials steal tax money "
lab var why_avoid_tax_fac9 "Why do people avoid paying taxes? -- % answer = They know they will not be caught "
lab var why_avoid_tax_fac10 "Why do people avoid paying taxes? -- % answer = Greed / selfishness "
lab var why_avoid_tax_fac11 "Why do people avoid paying taxes? -- % answer = Ignorance, don't know how to pay or don’t understand need to pay "
lab var why_avoid_tax_fac12 "Why do people avoid paying taxes? -- % answer = Negligence "
lab var why_avoid_tax_fac13 "Why do people avoid paying taxes? -- % answer = Government stopped people from paying the tax(s) "
lab var why_avoid_tax_fac14 "Why do people avoid paying taxes? -- % answer = Employers don't deduct or don't give to government "
lab var why_avoid_tax_fac15 "Why do people avoid paying taxes? -- % answer = Other "
/*Note: due to the Stata command 'collapse' for an nominal variable, one ///
	should not use the why_avoid_tax as it does not accurately reflect ///
	the average answer*/
*/

/*Saving file*/
save "afrobaro.dta", replace
