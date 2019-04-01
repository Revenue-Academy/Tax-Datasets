clear all
set more off

cd "C:\Users\Joe\Desktop\WB STC\GGOGT\Dataset Compilations"

/*Import excel sheet*/

import excel "C:\Users\Joe\Desktop\WB STC\GGOGT\Dataset Compilations\Historical-data---complete-data-with-scores.xlsx", sheet("All Data") firstrow case(lower) clear

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
label define regions 1 "East Asia & Pacific" 2 "Europe & Central Asia" 3 "Latin America & Caribbean" 4 "Middle East & North Africa" 5 "South Asia" 6 "Sub-Saharan Africa" 7 "High income: OECD"
destring c, replace
label values c regions
rename c region
replace d="1" if d=="Low income"
replace d="2" if d=="Lower middle income"
replace d="3" if d=="Upper middle income"
replace d="4" if d=="High income"
label define income_groups 1 "Low income" 2 "Lower middle income" 3 "Upper middle income" 4 "High income"
destring d, replace
label values d income_groups
rename d income_group
destring e, replace
rename e year

/*Only keep 'Paying Taxes' variables*/
keep payingtaxes country_code country region income_group year dq dr ds dt du dv dw dx dy dz ea eb ec ed ee ef eg eh ei ej

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
*replace ds = "." if ds == "No Practice"
destring ds, replace
label var ds "Payments (number per year)"
rename ds npayments
replace dt = "-9" if dt == "No Practice"
*replace dt = "." if dt == "No Practice"
destring dt, replace
label var dt "Time (hours per year)"
rename dt timepayments
replace du = "-9" if du== "No Practice"
*replace du = "*" if du== "No Practice"
destring du, replace
label var du "Total tax and contribution rate (% of profit)"
rename du ttr
replace dv = "-9" if dv== "No Practice"
*replace dv = "." if dv== "No Practice"
destring dv, replace
label var dv "Profit tax (% of profit)"
rename dv profittax
replace dw = "-9" if dw== "No Practice"
*replace dw = "." if dw== "No Practice"
destring dw, replace
label var dw "Labor tax and contributions (% of profit)"
rename dw labortax
replace dx = "-9" if dx== "No Practice"
*replace dx = "." if dx== "No Practice"
destring dx, replace
label var dx "Other taxes (% of profit)"
rename dx othertax
replace dy = "-9" if dy== "No Practice"
replace dy = "-8" if dy== "No VAT"
replace dy = "-7" if dy== "No VAT refund per case study scenario"
*replace dy = "." if dy== "No Practice"
*replace dy = "." if dy== "No VAT"
*replace dy = "." if dy== "No VAT refund per case study scenario"
destring dy, replace
label var dy "Time to comply with VAT refund (hours) (DB 17-19 methodology)"
rename dy timevat
replace dz = "-9" if dz== "No Practice"
replace dz = "-8" if dz== "No VAT"
replace dz = "-7" if dz== "No VAT refund per case study scenario"
*replace dz = "." if dz== "No Practice"
*replace dz = "." if dz== "No VAT"
*replace dz = "." if dz== "No VAT refund per case study scenario"
destring dz, replace
label var dz "Time to obtain VAT refund (weeks) (DB 17-19 methodology)"
rename dz timevatrefund
replace ea = "-9" if ea== "No Practice"
replace ea = "-6" if ea== "No corporate income tax"
*replace ea = "." if ea== "No Practice"
*replace ea = "." if ea== "No corporate income tax"
destring ea, replace
label var ea "Time to comply with a corporate income tax correction (hours) (DB 17-19 methodology)"
rename ea corpcompliancetime
replace eb = "-9" if eb== "No Practice"
replace eb = "-6" if eb== "No corporate income tax"
*replace eb = "." if eb== "No Practice"
*replace eb = "." if eb== "No corporate income tax"
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
*replace eg = "." if eg== "No VAT"
destring eg, replace
label var eg "Score - Time to comply with VAT refund (hours) (DB 17-19 methodology)"
rename eg scoretimevatrefundcomply
replace eh = "-8" if eh== "No VAT"
*replace eh = "." if eh== "No VAT"
destring eh, replace
label var eh "Score - Time to obtain VAT refund (weeks) (DB 17-19 methodology)"
rename eh scoretimevatrefundobtain
replace ei="-6" if ei== "No corporate income tax"
*replace ei="." if ei== "No corporate income tax"
destring ei, replace
label var ei "Score - Time to comply with a corporate income tax correction (hours) (DB 17-19 methodology)"
rename ei scorecorpcompliancetime
replace ej="-6" if ej== "No corporate income tax"
*replace ej="." if ej== "No corporate income tax"
destring ej, replace
label var ej "Score - Time to complete a corporate income tax correction (weeks) (DB 17-19 methodology)"
rename ej scorecorpcompletiontime

sort country_code year
save "Doing Business Historical - Paying Taxes", replace

/*Drop ttr */

/*Summary Statistics*/

foreach v of varlist ranktaxes19 scoretaxes1719 npayments timepayments ttr profittax labortax othertax {

    tabstat `v' if `v'>=0 & `v'<. & region==6 /*for SSA*/, s(n mean sd min max p25 p50 p75) c(s)
  } 
  
/*Visualizations*/

twoway(scatter scoretaxes1719 year) (lfit scoretaxes1719 year) if region==6 & scoretaxes1719!=.

twoway(scatter scoretaxes0616 year) (lfit scoretaxes0616 year) if region==6 & scoretaxes0616!=.

twoway (scatter scoretaxes0616 year) (lfit scoretaxes0616 year) (scatter scoretaxes1719 year) (lfit scoretaxes1719 year) if region==6

