clear all
set more off

/*Set Directory*/
cd "C:\Users\Joe\Desktop\WB STC\GGOGT\Dataset Compilations\Tax treaty Database"

/*Use Tax Treaty Dataset*/
use "taxtreaties_raw.dta"

sort C1 Signedyear

/*Destring Variables and switch labels to represent new values*/
destring AgmtID Unique, replace
qui tab C1_Region
*Region 1=Africa, Region 2=Asia*
encode C1_Region, gen(c1_region)
qui tab C1_Region c1_region
drop C1_Region
destring C1_LDC C2_OECD C2_G20 C2_BEPS, replace
destring Signedyear, replace
replace Effectiveyear="" if Effectiveyear=="NA"
destring Effectiveyear, replace
gen newtreaty=(Type=="New treaty")
drop Type
gen ratified=(Ratified=="Yes")
drop Ratified
gen terminated=(Terminated=="Yes")
drop Terminated
destring UNmodelarticle53alength, replace
encode UNmodelarticle53asupervi, gen(unmodelarticle53asupervi)
replace unmodelarticle53asupervi=unmodelarticle53asupervi-1
label define unmodelarticle53asupervi 0 "NO" 1 "YES", modify
drop UNmodelarticle53asupervi
replace UNmodelarticle53b="" if UNmodelarticle53b=="NO"
destring UNmodelarticle53b, gen(unmodelarticle53b)
drop UNmodelarticle53b
encode UNmodelarticle54a, gen(unmodelarticle54a)
replace unmodelarticle54a=unmodelarticle54a-1
label define unmodelarticle54a 0 "NO" 1 "YES", modify
drop UNmodelarticle54a
*There was one value of "6", which I interpreted as a mistype instead of "y" for Yes*
replace UNmodelarticle54b="YES" if UNmodelarticle54b=="6"
encode UNmodelarticle54b, gen(unmodelarticle54b)
replace unmodelarticle54b=unmodelarticle54b-1
label define unmodelarticle54b 0 "NO" 1 "YES", modify
drop UNmodelarticle54b
encode UNmodelarticle55b, gen(unmodelarticle55b)
replace unmodelarticle55b=unmodelarticle55b-1
label define unmodelarticle55b 0 "NO" 1 "YES", modify
drop UNmodelarticle55b
encode UNmodelarticle56, gen(unmodelarticle56)
replace unmodelarticle56=unmodelarticle56-1
label define unmodelarticle56 0 "NO" 1 "YES", modify
drop UNmodelarticle56
encode UNmodelarticle57, gen(unmodelarticle57)
replace unmodelarticle57=unmodelarticle57-1
label define unmodelarticle57 0 "NO" 1 "YES", modify
drop UNmodelarticle57
encode UNmodelarticle71bc, gen(unmodelarticle71bc)
replace unmodelarticle71bc=unmodelarticle71bc-1
label define unmodelarticle71bc 0 "NO" 1 "YES", modify
drop UNmodelarticle71bc
encode UNmodelarticle73, gen(unmodelarticle73)
replace unmodelarticle73=unmodelarticle73-1
label define unmodelarticle73 0 "NO" 1 "YES", modify
drop UNmodelarticle73
replace UNmodelarticle82="" if UNmodelarticle82=="NA"
encode UNmodelarticle82, gen(unmodelarticle82)
replace unmodelarticle82=unmodelarticle82-1
label define unmodelarticle82 0 "NO" 1 "YES", modify
drop UNmodelarticle82
replace UNmodelarticle102aFDIdi="" if UNmodelarticle102aFDIdi=="NA"
replace UNmodelarticle102aFDIdi="100" if UNmodelarticle102aFDIdi=="NO LIMIT"
destring UNmodelarticle102aFDIdi, replace
replace UNmodelarticle102athresh="" if UNmodelarticle102athresh=="NA"
destring UNmodelarticle102athresh, replace
replace UNmodelarticle102bportfo="" if UNmodelarticle102bportfo=="NA"
replace UNmodelarticle102bportfo="100" if UNmodelarticle102bportfo=="NO LIMIT"
destring UNmodelarticle102bportfo, replace
replace UNmodelarticle112interest="" if UNmodelarticle112interest=="NA"
replace UNmodelarticle112interest="100" if UNmodelarticle112interest=="NO LIMIT"
destring UNmodelarticle112interest, replace
replace UNmodelarticle122royalties="100" if UNmodelarticle122royalties=="NO LIMIT"
destring UNmodelarticle122royalties, replace
encode UNmodelarticle123televisio, gen(unmodelarticle123televisio)
replace unmodelarticle123televisio=unmodelarticle123televisio-1
label define unmodelarticle123televisio 0 "NO" 1 "YES", modify
drop UNmodelarticle123televisio
encode UNmodelarticle123equipment, gen(unmodelarticle123equipment)
replace unmodelarticle123equipment=unmodelarticle123equipment-1
label define unmodelarticle123equipment 0 "NO" 1 "YES", modify
drop UNmodelarticle123equipment
replace ServicesWHT="" if ServicesWHT=="NA"
destring ServicesWHT, replace
replace UNmodelarticle134="" if UNmodelarticle134=="NA"
encode UNmodelarticle134, gen(unmodelarticle134)
replace unmodelarticle134=unmodelarticle134-1
label define unmodelarticle134 0 "NO" 1 "YES", modify
drop UNmodelarticle134
replace UNmodelarticle135="" if UNmodelarticle135=="NA"
encode UNmodelarticle135, gen(unmodelarticle135)
replace unmodelarticle135=unmodelarticle135-1
label define unmodelarticle135 0 "NO" 1 "YES", modify
drop UNmodelarticle135
replace UNmodelarticle162="" if UNmodelarticle162=="NA"
encode UNmodelarticle162, gen(unmodelarticle162)
replace unmodelarticle162=unmodelarticle162-1
label define unmodelarticle162 0 "NO" 1 "YES", modify
drop UNmodelarticle162
replace UNmodelarticle182="" if UNmodelarticle182=="NA"
encode UNmodelarticle182, gen(unmodelarticle182)
replace unmodelarticle182=unmodelarticle182-1
label define unmodelarticle182 0 "NO" 1 "YES", modify
drop UNmodelarticle182
replace UNmodelarticle1823="" if UNmodelarticle1823=="NA"
encode UNmodelarticle1823, gen(unmodelarticle1823)
replace unmodelarticle1823=unmodelarticle1823-1
label define unmodelarticle1823 0 "NO" 1 "YES", modify
drop UNmodelarticle1823
replace UNmodelarticle213="" if UNmodelarticle213=="NA"
encode UNmodelarticle213, gen(unmodelarticle213)
replace unmodelarticle213=unmodelarticle213-1
label define unmodelarticle213 0 "NO" 1 "YES", modify
drop UNmodelarticle213
replace UNmodelarticle27="0" if UNmodelarticle27=="No"
replace UNmodelarticle27="0" if UNmodelarticle27=="no"
replace UNmodelarticle27="1" if UNmodelarticle27=="YEs"
replace UNmodelarticle27="1" if UNmodelarticle27=="Yes"
replace UNmodelarticle27="1" if UNmodelarticle27=="yes"
destring UNmodelarticle27, replace

rename *, lower
rename iso3c_c1 Country_Code

/*Add some labels that were dropped*/
lab var newtreaty "Type of negotiations: renegotiations (0) of existing treaties and new treaties (1) (Source: ActionAid tax treaties)"
lab var ratified "Ratified by both partners (1) (Source: ActionAid tax treaties)"
lab var terminated "Treaty terminated (1) (Source: ActionAid tax treaties)"

/*Re-order*/
order Country_Code iso3c_c2, last
order signedyear effectiveyear c1_region newtreaty ratified terminated, after(c2)
order unmodelarticle53asupervi, after(unmodelarticle53alength)
order unmodelarticle54b unmodelarticle55b unmodelarticle56 unmodelarticle57 unmodelarticle71bc unmodelarticle73 unmodelarticle82, before(unmodelarticle102afdidi)

/*Save database*/
save "taxtreaty.dta", replace
