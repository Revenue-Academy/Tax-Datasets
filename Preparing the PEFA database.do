clear all
set more off

*cd "D:\WB Tax Consultancy\PEFA scores"

//******************************//
//*****Importing 2011 data******//
//******************************//
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

*A quick summary of the dataset*
describe

save "PEFA 2011", replace

//******************************//
//*****Importing 2016 data******//
//******************************//
import excel "PEFA Scores with Numeric values-Dec18-N-ALL-PEFA2016.xlsx", sheet("Numeric Values") cellrange(A2:AY126) clear

*the PEFA database is organized such that variables are rows and countries are columns. sxpose switches them for use in Stata.
sxpose, firstnames clear

*Variable names were incomplete, and a full description of each variable was included as the*
*first cell under each variable. This command borrows descriptions as a label, and*
*subsequently deletes the now irrelevant row.*
foreach var of varlist _var5-_var125 {
	label variable `var' "`=`var'[1]'"
}
drop if _var5=="Aggregate expenditure out-turn"

*correcting miscoded variables
replace _var32="" if _var32=="NU"
replace _var33="" if _var33=="NU"
replace _var34="" if _var34=="NU"
replace _var35="" if _var35=="NU"
replace _var36="" if _var36=="NU"
replace _var102="" if _var102=="NU"

*Turn values coded as string into numeric*
destring _var5-_var125, replace

*This section systematically renames variables to reflect PEFA categories.*
local z = 5
forvalues i = 1/31 {
	qui cap gen temp = 3
	qui replace temp = 2 if `i'==3 | `i'==7 | `i'==22
	qui replace temp = 0 if `i'==1 | `i'==4 | `i'==5 | `i'==9
	qui replace temp = 4 if `i'==8 | `i'==11 | `i'==16 | `i'==18 | `i'==19 | `i'==21 | `i'==23 | `i'==24 | `i'==26 | `i'==27 | `i'==30 | `i'==31
	local y = temp
	qui drop temp
	forvalues x = 0/`y'{
		rename _var`z' PI_`i'_`x'
		local z = `z' + 1
	}
}
rename _var1 Country
rename _var4 Lastupdate

*A quick summary of the dataset*
describe

save "PEFA 2016", replace

//************************************//
//*****Importing 2011 local data******//
//************************************//
import excel "PEFA Scores with Numeric values-Dec18-SN-ALL-PEFA2011.xlsx", sheet("Numeric Values") cellrange(A2:HD109) clear

*the PEFA database is organized such that variables are rows and countries are columns. sxpose switches them for use in Stata.
sxpose, firstnames clear

*Variable names were incomplete, and a full description of each variable was included as the*
*first cell under each variable. This command borrows descriptions as a label, and*
*subsequently deletes the now irrelevant row.*
foreach var of varlist _var5-_var108 {
	label variable `var' "`=`var'[1]'"
}
drop if _var5=="Aggregate expenditure out-turn compared to original approved budget"

*correcting a miscoded variable
replace _var65="1" if _var65=="1+"

*Turn values coded as string into numeric*
destring _var5-_var108, replace

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
rename _var105 HLG_1_0
rename _var106 HLG_1_1
rename _var107 HLG_1_2
rename _var108 HLG_1_3

*A quick summary of the dataset*
describe

save "PEFA 2011 Local", replace

//************************************//
//*****Importing 2016 local data******//
//************************************//
import excel "PEFA Scores with Numeric values-Dec18-SN-ALL-PEFA2016.xlsx", sheet("Numeric Values") cellrange(A2:AH130) clear

*the PEFA database is organized such that variables are rows and countries are columns. sxpose switches them for use in Stata.
sxpose, firstnames clear

*Variable names were incomplete, and a full description of each variable was included as the*
*first cell under each variable. This command borrows descriptions as a label, and*
*subsequently deletes the now irrelevant row.*
foreach var of varlist _var5-_var129 {
	label variable `var' "`=`var'[1]'"
}
drop if _var5=="Aggregate expenditure out-turn"

*correcting a miscoded variable
replace _var105="" if _var105=="N4"

*Turn values coded as string into numeric*
destring _var5-_var129, replace

*This section systematically renames variables to reflect PEFA categories.*
local z = 5
forvalues i = 1/31 {
	qui cap gen temp = 3
	qui replace temp = 2 if `i'==3 | `i'==7 | `i'==22
	qui replace temp = 0 if `i'==1 | `i'==4 | `i'==5 | `i'==9
	qui replace temp = 4 if `i'==8 | `i'==11 | `i'==16 | `i'==18 | `i'==19 | `i'==21 | `i'==23 | `i'==24 | `i'==26 | `i'==27 | `i'==30 | `i'==31
	local y = temp
	qui drop temp
	forvalues x = 0/`y'{
		rename _var`z' PI_`i'_`x'
		local z = `z' + 1
	}
}
rename _var1 Country
rename _var4 Lastupdate
rename _var126 HLG_1_0
rename _var127 HLG_1_1
rename _var128 HLG_1_2
rename _var129 HLG_1_3


*A quick summary of the dataset*
describe

save "PEFA 2016 Local", replace
