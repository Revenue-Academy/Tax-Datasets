clear all
set more off

cd "C:\Users\WB542385\OneDrive - WBG\GSMA\GSMA Africa"

/*ANGOLA*/
import excel "GSMA Angola data.xls", sheet("Data") firstrow

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
foreach u in Angola Benin Botswana "Burkina Faso" Burundi "Cabo Verde" Cameroon CAR Chad Comoros Congo "Congo, DR" "Cote d'Ivoire" Djibouti "Equatorial Guinea" Eritrea Eswatini Ethiopia Gabon Gambia Ghana Guinea "Guinea-Bissau" Kenya Lesotho Liberia Madagascar Malawi Mali Mauritania Mauritius Mayotte Mozambique Namibia Niger Nigeria Reunion Rwanda "Saint Helena" "Sao Tome and Principe" Senegal Seychelles "Sierra Leone" Somalia "South Africa" "South Sudan" Sudan Tanzania Togo Uganda Zambia {

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
