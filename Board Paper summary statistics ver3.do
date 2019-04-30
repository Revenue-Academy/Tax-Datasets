clear all
set more off

cd "C:\Users\Joe\Desktop\WB STC\GGOGT\Dataset Compilations\Board Paper\"
use "Master Dataset.dta", clear

/*Input variables of interest: 'region', 'year', & 'year since'*/
global v="EAP"
local y=2016
local z=2005

cd "C:\Users\Joe\Desktop\WB STC\GGOGT\Dataset Compilations\Board Paper/$v"

/*Setting Region Macros*/
global EAP =1
global ECA =2
global LAC =3
global MENA=4
global NAM =5
global SAR =6
global SSA =7

gen EAP =(Reg==$EAP)
gen ECA =(Reg==$ECA)
gen LAC =(Reg==$LAC)
gen MENA=(Reg==$MENA)
gen NAM =(Reg==$NAM)
gen SAR =(Reg==$SAR)
gen SSA =(Reg==$SSA)

cap program drop tteststars
prog define tteststars
	
	cap gen temp=""
	qui replace temp="*" if (r(p)<=0.1)
	qui replace temp="**" if (r(p)<=0.05)
	qui replace temp="***" if (r(p)<=0.01)
	global stars = "`=temp[1]'"
	qui drop temp
	display "$stars"
	
end

/*Histogram comparisons between Reg and RoW in year*/
kdensity ermrating          if $v==1 & year==`y', title("$v: Efficiency of Revenue Mobilization density in `y'") xscale(range(1 6)) xlabel(1(1)6)
graph export ERMRating$v.png, replace
kdensity fispolrating       if $v==1 & year==`y', title("$v: Fiscal Policy Rating density in `y'") xscale(range(1 6)) xlabel(1(1)6)
graph export FisPolRating$v.png, replace
kdensity qualpubadminrating if $v==1 & year==`y', title("$v: Quality of Public Administration Rating density in `y'") xscale(range(1 6)) xlabel(1(1)6)
graph export QualPubAdminRating$v.png, replace
kdensity ermrating          if $v!=1 & year==`y', title("Efficiency of Revenue Mobilization outside of $v in `y'") xscale(range(1 6)) xlabel(1(1)6)
graph export ERMRatingRoWvs$v.png, replace
kdensity fispolrating       if $v!=1 & year==`y', title("Fiscal Policy Rating outside of $v in `y'") xscale(range(1 6)) xlabel(1(1)6)
graph export FisPolRatingRoWvs$v`b'.png, replace
kdensity qualpubadminrating if $v!=1 & year==`y', title("Quality of Public Administration Rating outside of $v in `y'") xscale(range(1 6)) xlabel(1(1)6)
graph export QualPubAdminRatingRoWvs$v`b'.png, replace

/*T-test for statistically different averages across regions, across years*/
cap noisily ttest ermrating,          by($v)
cap noisily ttest ermrating           if year==`y', by($v)
cap noisily ttest fispolrating,       by($v)
cap noisily ttest fispolrating        if year==`y', by($v)
cap noisily ttest qualpubadminrating, by($v)
cap noisily ttest qualpubadminrating  if year==`y', by($v)

cap noisily ttest ermrating          if (year==`y' | year==`z') & $v==1, by(year)
cap noisily ttest fispolrating       if (year==`y' | year==`z') & $v==1, by(year)
cap noisily ttest qualpubadminrating if (year==`y' | year==`z') & $v==1, by(year)

twoway (scatter ermrating          year if $v==1 & year>=`z', jitter(3))(lfitci ermrating          year if $v==1 & year>=`z') (lfit ermrating          year if $v!=1 & year>=`z'), ytitle("Efficiency of Revenue Mobilization (CPIA)") note("Each marker represents a different country.""The fitline shows a 95% confidence interval around the mean.") legend(off) title("Efficiency of Revenue Mobilization in $v vs RoW") ylabel(1(1)5) scheme(sj)
graph export ERMinRoWvs$v.png, replace
twoway (scatter fispolrating       year if $v==1 & year>=`z', jitter(3))(lfitci fispolrating       year if $v==1 & year>=`z') (lfit fispolrating       year if $v!=1 & year>=`z'), ytitle("Fiscal Policy (CPIA)")                      note("Each marker represents a different country.""The fitline shows a 95% confidence interval around the mean.") legend(off) title("Fiscal Policy in $v vs RoW")                      ylabel(1(1)5) scheme(sj)
graph export FisPolRatinginRoWvs$v.png, replace
twoway (scatter qualpubadminrating year if $v==1 & year>=`z', jitter(3))(lfitci qualpubadminrating year if $v==1 & year>=`z') (lfit qualpubadminrating year if $v!=1 & year>=`z'), ytitle("Quality of Public Administration (CPIA)")   note("Each marker represents a different country.""The fitline shows a 95% confidence interval around the mean.") legend(off) title("Quality of Public Administration in $v vs RoW")   ylabel(1(1)5) scheme(sj)
graph export QualPubAdminRatinginRoWvs$v.png, replace

/*T-test for statistically different averages across regions over years for oil & gas rich countries*/
ttest ermrating if oil_gas_dum==1 & (year==`z' | year==`y'), by(year)
cap noisily ttest ermrating if oil_gas_dum==1 & (year==`z' | year==`y') & Reg==$v, by(year)
ttest ermrating if oil_gas_dum==0 & (year==`z' | year==`y'), by(year)
cap noisily ttest ermrating if oil_gas_dum==0 & (year==`z' | year==`y') & Reg==$v, by(year)

ttest fispolrating if oil_gas_dum==1 & (year==`z' | year==`y'), by(year)
cap noisily ttest fispolrating if oil_gas_dum==1 & (year==`z' | year==`y') & Reg==$v, by(year)
ttest fispolrating if oil_gas_dum==0 & (year==`z' | year==`y'), by(year)
cap noisily ttest fispolrating if oil_gas_dum==0 & (year==`z' | year==`y') & Reg==$v, by(year)

ttest qualpubadminrating if oil_gas_dum==1 & (year==`z' | year==`y'), by(year)
cap noisily ttest qualpubadminrating if oil_gas_dum==1 & (year==`z' | year==`y') & Reg==$v, by(year)
ttest qualpubadminrating if oil_gas_dum==0 & (year==`z' | year==`y'), by(year)
cap noisily ttest qualpubadminrating if oil_gas_dum==0 & (year==`z' | year==`y') & Reg==$v, by(year)

/*Country graphs*/
sort year
local w="India"
local x="IND" 
*twoway (connected meantaxindv meantaxcorp meantaxpropr meantaxvat meantaxexcises meantaxtrade meantaxother_tax year if year<=2016, yaxis(1) msymbol(Oh S T + - x) ytitle("% of GDP") title("Performance of Different Tax Types (World)"))
twoway (connected Tax_Revenue Direct_taxes Indirect_Taxes Income_Taxes Value_Added_Tax Trade_Taxes Tax_on_Goods_and_Services Export_Taxes Excise_Taxes Property_Tax Other_Taxes CIT PIT year if year<=`y' & Country=="`w'", yaxis(1) msymbol(O Oh S T + | x Dh v Sh Th D S O) ytitle("% of GDP") title("Performance of Different Tax Types (`w')"))
*twoway (connected Tax_Revenue_incl_SC Tax_Revenue Total_Non_Tax_Revenue Social_Contributions year if year<=`y' & Country=="`w'", yaxis(1) msymbol(Oh S T + | x Dh v Sh Th O) ytitle("% of GDP") title("Performance of Different Tax Types (`w')"))

/*PEFA 2011 summary statistics, by Region average, then in contrast with RoW*/
tabstat PI_1_0 PI_8_0 PI_9_0 PI_10_0 PI_12_0 PI_13_0 PI_14_0 PI_15_0 PI_19_0 PI_27_0 D3_0 if Reg==$$v, c(s) s(mean n min max sd p25 p75)
local b=1
foreach a of varlist PI_1_0 PI_8_0 PI_9_0 PI_10_0 PI_12_0 PI_13_0 PI_14_0 PI_15_0 PI_19_0 PI_27_0 D3_0 {

display "T-test for `a', by $v"
ttest `a', by($v)
tteststars

graph bar `a', over($v) note("P-value: $stars") title("`a' in $v vs. RoW")
graph export PEFAttests`b'.png, replace
local b=`b'+1

}

/*Tax Treaties ttestss*/
*Global Graphs
cap gen SSAntreaties=numberoftreaties if Reg==7
cap gen SARntreaties=numberoftreaties if Reg==6
cap gen EAPntreaties=numberoftreaties if Reg==1

graph bar (sum) SSAntreaties SARntreaties EAPntreaties, over(year, ///
	label(angle(45))) title("Number of treaties by region by year") ///
	note("Note: 1990 includes all previous years' treaties") ylabel(,nogrid) ///
	graphregion(color(white)) blabel(bar, position(outside) ///
	color(black) size(vsmall)) legend(label(1 "SSA") label(2 "SAR") label(3 "EAP")) ///
	legend(position(12) ring(0))
*graph export NofTaxTratiesyear.png, replace	
	
local b=1
foreach a of varlist Sourceindex_country_min WHTrates_country_min partner_BEPS_country_share partner_BEPS_year_share numberoftreaties {

display "T-test for `a', by $v"
cap noisily ttest `a', by($v)
tteststars

graph bar `a', over($v) note("P-value: $stars") title("`a' in $v vs. RoW")
graph export TaxTreatiesttests`b'.png, replace
local b=`b'+1

}

/*Polity ttests Region vs RoW*/
bysort Reg: ttest Tax_Effort if year>=2000 & Reg!=5, by(politymorefree)
local b=1
foreach a of varlist autocracy anocracy democracy politymorefree {

display "T-test for `a', by ($v)"
ttest `a', by($v)
tteststars

graph bar `a', over($v) note("P-value: $stars") title("`a' in $v vs. RoW")
graph export Polityttests`b'.png, replace
local b=`b'+1

}

cap noisily ttest Tax_Revenue if $v==1, by(democracy)
tteststars
graph bar Tax_Revenue, over(democracy) note("P-value: $stars") title("Tax_Revenue by democracy in $v vs. RoW")
graph export Polityttests`b'.png, replace
local b=`b'+1

cap noisily ttest Tax_Revenue if $v==1, by(politymorefree)
tteststars
graph bar Tax_Revenue, over(politymorefree) note("P-value: $stars") title("Tax_Revenue by politymorefree in $v vs. RoW")
graph export Polityttests`b'.png, replace
local b=`b'+1

cap noisily ttest Tax_Effort  if $v==1, by(democracy)
tteststars
graph bar Tax_Effort, over(democracy) note("P-value: $stars") title("Tax_Effort by democracy in $v vs. RoW")
graph export Polityttests`b'.png, replace
local b=`b'+1

cap noisily ttest Tax_Effort  if $v==1, by(politymorefree)
tteststars
graph bar Tax_Effort, over(politymorefree) note("P-value: $stars") title("Tax_Effort by politymorefree in $v vs. RoW")
graph export Polityttests`b'.png, replace
local b=`b'+1

cap noisily ttest ermrating   if $v==1, by(democracy)
tteststars
graph bar ermrating, over(democracy) note("P-value: $stars") title("ermrating by democracy in $v vs. RoW")
graph export Polityttests`b'.png, replace
local b=`b'+1

cap noisily ttest ermrating   if $v==1, by(politymorefree)
tteststars
graph bar ermrating, over(politymorefree) note("P-value: $stars") title("ermrating by politymorefree in $v vs. RoW")
graph export Polityttests`b'.png, replace

/*WBES ttests - Region vs RoW*/
local b=1
foreach a of varlist managementtime firmsvisited operatinglicensedays constructionpermitdays importlicensedays taxadminconstraint licenseconstraint percentcompeting percentregistered yearsinformal informalconstraint {

display "T-test for `a', by ($v)"
ttest `a', by($v)
tteststars

graph bar `a', over($v) note("P-value: $stars") title("`a' in $v vs. RoW")
graph export WBESttests`b'.png, replace
local b=`b'+1

}

/*DBI ttest - Region vs RoW*/
local b=1
foreach a of varlist npayments timepayments profittax labortax othertax corpcompliancetime corpcompletiontime scorepostfiling {

display "T-test for `a', by ($v)"
ttest `a', by($v)
tteststars

graph bar `a', over($v) note("P-value: $stars") title("`a' in $v vs. RoW")
graph export DBIttests`b'.png, replace
local b=`b'+1

}

/*Afrobaro summary statistics*/
//See the Visualizations-for-Jan folder on Revenue Academy for 
//Afrobarometer visualizations

