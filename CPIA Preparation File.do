clear all
set more off

*cd "C:\Users\Joe\Desktop\WB STC\GGOGT\Dataset Compilations"

/*Import excel sheet*/

import excel "CPIAEXCEL.xlsx", sheet("Data") firstrow case(lower)

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

/*label vars*/
label var bhrrating "CPIA building human resources rating (1=low to 6=high)"
label var brerating "CPIA business regulatory environment rating (1=low to 6=high)"
label var dprating "CPIA debt policy rating (1=low to 6=high)"
label var emcaverage "CPIA economic management cluster average (1=low to 6=high)"
label var ermrating "CPIA efficiency of revenue mobilization rating (1=low to 6=high)"
label var eqprurating "CPIA equity of public resource use rating (1=low to 6=high)"
label var finsecrating "CPIA financial sector rating (1=low to 6=high)"
label var fispolrating "CPIA fiscal policy rating (1=low to 6=high)"
label var geneqrating "CPIA gender equality rating (1=low to 6=high)"
label var macromgmtrating "CPIA macroeconomic management rating (1=low to 6=high)"
label var polsieqcluster "CPIA policies for social inclusion/equity cluster average (1=low to 6=high)"
label var polinstenvsusrating "CPIA policy and institutions for environmental sustainability rating (1=low to 6=high)"
label var prrbgovrating "CPIA property rights and rule-based governance rating (1=low to 6=high)"
label var pubsecmgmtinstclusteravg "CPIA public sector management and institutions cluster average (1=low to 6=high)"
label var qualbfmrating "CPIA quality of budgetary and financial management rating (1=low to 6=high)"
label var qualpubadminrating "CPIA quality of public administration rating (1=low to 6=high)"
label var sprating "CPIA social protection rating (1=low to 6=high)"
label var strpolclusteravg "CPIA structural policies cluster average (1=low to 6=high)"
label var traderating "CPIA trade rating (1=low to 6=high)"
label var transacctcorrpsrating "CPIA transparency, accountability, and corruption in the public sector rating (1=low to 6=high)"
label var idaresallocindex "IDA resource allocation index (1=low to 6=high)"

/*Sort and save database*/

sort country_code year
save "CPIA Indicators", replace

/*Summary statistics*/

foreach v of varlist emcaverage polsieqcluster pubsecmgmtinstclusteravg strpolclusteravg {

    tabstat `v' if `v'>=0 & `v'<., s(n mean sd min max p25 p50 p75) c(s)
  }

