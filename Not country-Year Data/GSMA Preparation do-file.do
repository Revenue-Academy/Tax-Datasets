clear all
set more off

cd "C:\Users\WB542385\OneDrive - WBG\GSMA"
/****************/
/*AFRICA DATASET*/
/****************/
import excel "GSMA Africa overview.xls", sheet("Data") firstrow

drop in 1

sxpose, clear force
rename (_var1 _var3 _var4 _var6 _var9) (year unqsubs unqsubsmobile simspersub unqsubsmobilepct)
rename (_var12 _var13 _var16 _var17 _var20 _var21) (unqsubsnetaddstotal ///
 unqsubsnetaddsmobile unqsubstotalgr unqsubsmobilegr unqsubstotalmktpen unqsubsmobilemktpn)
rename (_var24 _var25 _var26 _var27 _var28 _var29 _var30 _var31 _var32 _var33 ///
 _var34 _var35 _var36 _var37 _var38 _var39 _var40 _var41 _var42 _var43 _var46 ///
 _var47 _var50 _var51 _var52 _var53 _var54 _var55 _var56 _var57 _var58 _var59 ///
 _var60 _var61 _var62 _var63 _var64 _var67 _var68) ///
(connectionstotaliot connectionstotal connectionsprepaid connectionscontract ///
 connections2g connections3g connections4g connectionsmobbrd connectionssmrtphone ///
 connectionsbasic connectionsdataonly connectionscdma2g connectionsgsm connectionscdma2000 ///
 connectionswcdma connectionslte connectionswimax connectionsiot connectionsm2m ///
 connectionslpwa connectionstotalpct connectionsliciotpct connectionsprepaidpct ///
 connectionscontractpct connections2gpct connections3gpct connections4gpct ///
 connectionsmobbrdpct connectionssmrtphonepct connectionsbasicpct connectionsdataonlypct ///
 connectionscdma2gpct connectionsgsmpct connectionscdma200pct connectionswcdmapct ///
 connectionsltepct connectionswimaxpct connectionsm2mpct connectionslpwapct) 
 
rename (_var71 _var72 _var73 _var74 _var75 _var76 _var77 _var78 _var79 _var80 ///
 _var81 _var82 _var83 _var84 _var85 _var86 _var87 _var88 _var89 _var90) ///
 (netaddstotaliot netaddstotal netaddsprepaid netaddscontract netadds2g netadds3g ///
 netadds4g netaddsmobbrd netaddssmrtphone netaddsbasic netaddsdataonly netaddscdma2g ///
 netaddsgsm netaddscdma2000 netaddswcdma netaddslte netaddswimax netaddsliciot ///
 netaddsm2m netaddslpwa)
 
rename (_var93 _var94 _var95 _var96 _var97 _var98 _var99 _var100 _var101 _var102 ///
 _var103 _var104 _var105 _var106 _var107 _var108 _var109 _var110 _var111 _var112) ///
 (netaddstotaliotgr netaddstotalgr netaddsprepaidgr netaddscontractgr netadds2ggr ///
 netadds3ggr netadds4ggr netaddsmobbrdgr netaddssmrtphonegr netaddsbasicgr ///
 netaddsdataonlygr netaddscdma2ggr netaddsgsmgr netaddscdma200gr netaddswcdmagr ///
 netaddsltegr netaddswimaxgr netaddsliciotgr netaddsm2mgr netaddslpwagr)
 rename (_var115 _var116 _var117 _var118 _var119 _var120 _var121 _var122 _var123 ///
 _var124 _var125 _var126 _var127 _var128 _var129 _var130) (mktpentotal mktpenprepaid ///
 mktpencontract mktpen2g mktpen3g mktpen4g mktpenmobbrd mktpensmrtphone mktpenbasic ///
 mktpendataonly mktpencdma2g mktpengsm mktpencdma2000 mktpenwcdma mktpenlte ///
 mktpenwimax)
rename (_var132 _var135) (ARPU_by_sub ARPU_by_connection)
rename (_var138 _var139 _var140) (rev_total rev_recurring rev_nonrecurring)
rename (_var143 _var146 _var147) (capex popcoverage_3g popcoverage_4g)

drop _var2 _var5 _var7 _var8 _var10 _var11 _var14 _var15 _var18 _var19 _var22 ///
 _var23 _var44 _var45 _var48 _var49 _var65 _var66 _var69 _var70 _var91 _var92 ///
 _var113 _var114 _var131 _var133 _var134 _var136 _var137 _var141 _var142 _var144 ///
 _var145 _var148 _var149 _var150 _var151 _var152
 
drop in 6
drop in 5
drop in 4
drop in 3
drop in 2
drop in 1

destring _all, replace
gen gsmaReg="Africa"

save "GSMA Africa Dataset.dta", replace

/******************/
/*AMERICAS DATASET*/
/******************/
import excel "GSMA Americas overview.xls", sheet("Data") firstrow clear
drop in 1

sxpose, clear force

rename (_var1 _var3 _var4 _var6 _var9) (year unqsubs unqsubsmobile simspersub unqsubsmobilepct)
rename (_var12 _var13 _var16 _var17 _var20 _var21) (unqsubsnetaddstotal ///
 unqsubsnetaddsmobile unqsubstotalgr unqsubsmobilegr unqsubstotalmktpen unqsubsmobilemktpn)
rename (_var24 _var25 _var26 _var27 _var28 _var29 _var30 _var31 _var32 _var33 ///
 _var34 _var35 _var36 _var37 _var38 _var39 _var40 _var41 _var42 _var43 _var44 ///
 _var46 _var47 _var48 _var49 _var50) ///
 (connectionstotaliot connectionstotal connectionsprepaid connectionscontract ///
 connections1g connections2g connections3g connections4g connections5g connectionsmobbrd connectionssmrtphone ///
 connectionsbasic connectionsdataonly connectionsanalog connectionscdma2g connectionsgsm connectionsiden connectionstdma connectionscdma2000 ///
 connectionstdscdma connectionswcdma connectionslte connectionswimax connectionsiot connectionsm2m ///
 connectionslpwa)
 
rename (_var53 _var54 _var57 _var58 _var59 _var60 _var61 _var62 _var63 _var64 ///
 _var65 _var66 _var67 _var68 _var69 _var70 _var71 _var72 _var73 _var74 _var75 ///
 _var76 _var77 _var81 _var82) (connectionstotalpct connectionsliciotpct ///
 connectionsprepaidpct connectionscontractpct connections1gpct connections2gpct ///
 connections3gpct connections4gpct connections5gpct connectionsmobbrdpct ///
 connectionssmrtphonepct connectionsbasicpct connectionsdataonlypct connectionsanalogpct ///
 connectionscdma2gpct connectionsgsmpct connectionsidenpct connectionstdmapct connectionscdma2000pct connectionstdscdmapct connectionswcdmapct ///
 connectionsltepct connectionswimaxpct connectionsm2mpct connectionslpwapct)
 
 
rename (_var85 _var86 _var87 _var88 _var89 _var90 _var91 _var92 _var93 _var94 ///
 _var95 _var96 _var97 _var98 _var99 _var100 _var101 _var102 _var103 _var104 ///
 _var105 _var106 _var107 _var108 _var109) (netaddstotaliot ///
 netaddstotal netaddsprepaid netaddscontract netadds1g netadds2g netadds3g netadds4g ///
 netaddsmobbrd netaddssmrtphone netaddsbasic netaddsdataonly netaddsanalog netaddscdma2g netaddsgsm netaddsiden ///
 netaddstdma netaddscdma2000 netaddstdscdma netaddswcdma netaddslte netaddswimax netaddsliciot netaddsm2m ///
 netaddslpwa)

rename (_var112 _var113 _var114 _var115 _var116 _var117 _var118 _var119 _var120 _var121 ///
 _var122 _var123 _var124 _var125 _var126 _var127 _var128 _var129 _var130 _var131 ///
 _var132 _var133 _var134 _var135 _var136) ///
 (netaddstotaliotgr netaddstotalgr netaddsprepaidgr netaddscontractgr netadds1ggr netadds2ggr ///
 netadds3ggr netadds4ggr netaddsmobbrdgr netaddssmrtphonegr netaddsbasicgr ///
 netaddsdataonlygr netaddsanaloggr netaddscdma2ggr netaddsgsmgr netaddsidengr netaddstdmagr netaddscdma2000gr netaddstdscdmagr netaddswcdmagr ///
 netaddsltegr netaddswimaxgr netaddsliciotgr netaddsm2mgr netaddslpwagr)

rename (_var139 _var140 _var141 _var142 _var143 _var144 _var145 _var146 _var147 ///
 _var148 _var149 _var150 _var151 _var152 _var153 _var154 _var155 _var156 _var157 ///
 _var158 _var159 _var160) (mktpentotal mktpenprepaid mktpencontract ///
 mktpen1g mktpen2g mktpen3g mktpen4g mktpen5g mktpenmobbrd mktpensmrtphone mktpenbasic ///
 mktpendataonly mktpenanalog mktpencdma2g mktpengsm mktpeniden mktpentdma mktpencdma2000 mktpentdscdma mktpenwcdma mktpenlte ///
 mktpenwimax)

rename (_var163 _var166) (ARPU_by_sub ARPU_by_connection)
rename (_var169 _var170 _var171) (rev_total rev_recurring rev_nonrecurring)
rename (_var174 _var177 _var178 _var179) (capex popcoverage_3g popcoverage_4g popcoverage_5g)

drop _var2 _var5 _var7 _var8 _var10 _var11 _var14 _var15 _var18 _var19 _var22 ///
 _var23 _var45 _var51 _var52 _var55 _var56 _var78 _var79 _var80 _var83 _var84 ///
 _var110 _var111 _var137 _var138 _var161 _var162 _var164 _var165 _var167 _var168 ///
 _var172 _var173 _var175 _var176 _var180 _var181 _var182 _var183 _var184

drop in 6
drop in 5
drop in 4
drop in 3
drop in 2
drop in 1

destring _all, replace
gen gsmaReg="Americas"

save "GSMA Americas Dataset.dta", replace

/**************/
/*ASIA DATASET*/
/**************/
import excel "GSMA Asia overview.xls", sheet("Data") firstrow clear
drop in 1

sxpose, clear force

rename (_var1 _var3 _var4 _var6 _var9) (year unqsubs unqsubsmobile simspersub unqsubsmobilepct)
rename (_var12 _var13 _var16 _var17 _var20 _var21) (unqsubsnetaddstotal ///
 unqsubsnetaddsmobile unqsubstotalgr unqsubsmobilegr unqsubstotalmktpen unqsubsmobilemktpn)

rename (_var24 _var25 _var26 _var27 _var28 _var29 _var30 _var31 _var32 _var33 ///
 _var34 _var35 _var36 _var37 _var38 _var39 _var40 _var41 _var42 _var43 _var44 ///
 _var45 _var46 _var47 _var48 _var50 _var51 _var52) ///
 (connectionstotaliot connectionstotal connectionsprepaid connectionscontract ///
 connections1g connections2g connections3g connections4g connections5g connectionsmobbrd ///
 connectionssmrtphone connectionsbasic connectionsdataonly connectionsanalog ///
 connectionscdma2g connectionsgsm connectionsiden connectionpdc connectionphs ///
 connectionstdma connectionscdma2000 connectionstdscdma connectionswcdma ///
 connectionslte connectionswimax connectionsiot connectionsm2m connectionslpwa)

rename (_var55 _var56 _var59 _var60 _var61 _var62 _var63 _var64 _var65 _var66 ///
 _var67 _var68 _var69 _var70 _var71 _var72 _var73 _var74 _var75 _var76 _var77 ///
 _var78 _var79 _var80 _var81 _var85 _var86) (connectionstotalpct ///
 connectionsliciotpct connectionsprepaidpct connectionscontractpct connections1gpct ///
 connections2gpct connections3gpct connections4gpct connections5gpct connectionsmobbrdpct ///
 connectionssmrtphonepct connectionsbasicpct connectionsdataonlypct connectionsanalogpct ///
 connectionscdma2gpct connectionsgsmpct connectionsidenpct connectionpdcpct connectionphspct ///
 connectionstdmapct connectionscdma2000pct connectionstdscdmapct connectionswcdmapct ///
 connectionsltepct connectionswimaxpct connectionsm2mpct connectionslpwapct)
 
 rename (_var89 _var90 _var91 _var92 _var93 _var94 _var95 _var96 _var97 _var98 ///
  _var99 _var100 _var101 _var102 _var103 _var104 _var105 _var106 _var107 ///
 _var108 _var109 _var110 _var111 _var112 _var113 _var115 _var116 _var117) ///
 (netaddstotaliot netaddstotal netaddsprepaid netaddscontract netadds1g ///
 netadds2g netadds3g netadds4g netadds5g netaddsmobbrd netaddssmrtphone ///
 netaddsbasic netaddsdataonly netaddsanalog netaddscdma2g netaddsgsm netaddsiden ///
 netaddspdc netaddsphs netaddstdma netaddscdma2000 netaddstdscdma netaddswcdma ///
 netaddslte netaddswimax netaddsliciot netaddsm2m netaddslpwa)
 
rename (_var120 _var121 _var122 _var123 _var124 _var125 _var126 _var127 _var128 ///
 _var129 _var130 _var131 _var132 _var133 _var134 _var135 _var136 _var137 _var138 ///
 _var139 _var140 _var141 _var142 _var143 _var144 _var146 _var147 _var148) ///
 (netaddstotaliotgr netaddstotalgr netaddsprepaidgr netaddscontractgr netadds1ggr ///
 netadds2ggr netadds3ggr netadds4ggr netadds5ggr netaddsmobbrdgr netaddssmrtphonegr ///
 netaddsbasicgr netaddsdataonlygr netaddsanaloggr netaddscdma2ggr netaddsgsmgr ///
 netaddsidengr netaddspdcgr netaddsphsgr netaddstdmagr netaddscdma2000gr ///
 netaddstdscdmagr netaddswcdmagr netaddsltegr netaddswimaxgr netaddsliciotgr ///
 netaddsm2mgr netaddslpwagr)
 
rename (_var151 _var152 _var153 _var154 _var155 _var156 _var157 _var158 _var159 ///
_var160 _var161  _var162 _var163 _var164 _var165 _var166 _var167 _var168 _var169 ///
_var170 _var171 _var172 _var173 _var174) (mktpentotal mktpenprepaid mktpencontract ///
 mktpen1g mktpen2g mktpen3g mktpen4g mktpen5g mktpenmobbrd mktpensmrtphone mktpenbasic ///
 mktpendataonly mktpenanalog mktpencdma2g mktpengsm mktpeniden mktpenpdc mktpenphs ///
 mktpentdma mktpencdma2000 mktpentdscdma mktpenwcdma mktpenlte mktpenwimax)
 
rename (_var177 _var180) (ARPU_by_sub ARPU_by_connection)
rename (_var183 _var184 _var185) (rev_total rev_recurring rev_nonrecurring)
rename (_var188 _var191 _var192 _var193) (capex popcoverage_3g popcoverage_4g ///
 popcoverage_5g)

drop _var2 _var5 _var7 _var8 _var10 _var11 _var14 _var15 _var18 _var19 _var22 ///
 _var23 _var49 _var53 _var54 _var57 _var58 _var82 _var83 _var84 _var87 _var88 ///
 _var114 _var118 _var119 _var145 _var149 _var150 _var175 _var176 _var178 _var179 ///
 _var181 _var182 _var186 _var187 _var189 _var190 _var194 _var195 _var196 _var197 ///
 _var198

drop in 6
drop in 5
drop in 4
drop in 3
drop in 2
drop in 1

destring _all, replace
gen gsmaReg="Asia"

save "GSMA Asia Dataset.dta", replace

/****************/
/*EUROPE DATASET*/
/****************/
import excel "GSMA Europe overview.xls", sheet("Data") firstrow clear
drop in 1

sxpose, clear force

rename (_var1 _var3 _var4 _var6 _var9) (year unqsubs unqsubsmobile simspersub unqsubsmobilepct)
rename (_var12 _var13 _var16 _var17 _var20 _var21) (unqsubsnetaddstotal ///
 unqsubsnetaddsmobile unqsubstotalgr unqsubsmobilegr unqsubstotalmktpen unqsubsmobilemktpn)
rename (_var24 _var25 _var26 _var27 _var28 _var29 _var30 _var31 _var32 _var33 ///
 _var34 _var35 _var36 _var37 _var38 _var39 _var40 _var41 _var42 _var43 _var45 ///
 _var46 _var47) ///
 (connectionstotaliot connectionstotal connectionsprepaid connectionscontract ///
 connections1g connections2g connections3g connections4g connections5g connectionsmobbrd connectionssmrtphone ///
 connectionsbasic connectionsdataonly connectionsanalog connectionscdma2g connectionsgsm connectionscdma2000 ///
 connectionswcdma connectionslte connectionswimax connectionsiot connectionsm2m ///
 connectionslpwa)
 
rename (_var50 _var51 _var54 _var55 _var56 _var57 _var58 _var59 _var60 _var61 ///
 _var62 _var63 _var64 _var65 _var66 _var67 _var68 _var69 _var70 _var71 _var75 ///
 _var76) (connectionstotalpct connectionsliciotpct connectionsprepaidpct ///
 connectionscontractpct connections1gpct connections2gpct connections3gpct connections4gpct connections5gpct ///
 connectionsmobbrdpct connectionssmrtphonepct connectionsbasicpct connectionsdataonlypct connectionsanalogpct ///
 connectionscdma2gpct connectionsgsmpct connectionscdma2000pct connectionswcdmapct ///
 connectionsltepct connectionswimaxpct connectionsm2mpct connectionslpwapct)
 
 
rename (_var79 _var80 _var81 _var82 _var83 _var84 _var85 _var86 _var87 _var88 _var89 _var90 _var91 _var92 _var93 _var94 ///
 _var95 _var96 _var97 _var98 _var99 _var100) (netaddstotaliot ///
 netaddstotal netaddsprepaid netaddscontract netadds1g netadds2g netadds3g netadds4g ///
 netaddsmobbrd netaddssmrtphone netaddsbasic netaddsdataonly netaddsanalog netaddscdma2g netaddsgsm ///
 netaddscdma2000 netaddswcdma netaddslte netaddswimax netaddsliciot netaddsm2m ///
 netaddslpwa)

rename (_var103 _var104 _var105 _var106 _var107 _var108 _var109 _var110 _var111 _var112 ///
 _var113 _var114 _var115 _var116 _var117 _var118 _var119 _var120 _var121 _var122 ///
 _var123 _var124) ///
 (netaddstotaliotgr netaddstotalgr netaddsprepaidgr netaddscontractgr netadds1ggr netadds2ggr ///
 netadds3ggr netadds4ggr netaddsmobbrdgr netaddssmrtphonegr netaddsbasicgr ///
 netaddsdataonlygr netaddsanaloggr netaddscdma2ggr netaddsgsmgr netaddscdma2000gr netaddswcdmagr ///
 netaddsltegr netaddswimaxgr netaddsliciotgr netaddsm2mgr netaddslpwagr)

rename (_var127 _var128 _var129 _var130 _var131 _var132 _var133 _var134 _var135 ///
 _var136 _var137 _var138 _var139 _var140 _var141 _var142 _var143 _var144 _var145) ///
 (mktpentotal mktpenprepaid mktpencontract ///
 mktpen1g mktpen2g mktpen3g mktpen4g mktpen5g mktpenmobbrd mktpensmrtphone mktpenbasic ///
 mktpendataonly mktpenanalog mktpencdma2g mktpengsm mktpencdma2000 mktpenwcdma mktpenlte ///
 mktpenwimax)

rename (_var148 _var151) (ARPU_by_sub ARPU_by_connection)
rename (_var154 _var155 _var156) (rev_total rev_recurring rev_nonrecurring)
rename (_var159 _var162 _var163 _var164) (capex popcoverage_3g popcoverage_4g popcoverage_5g)

drop _var2 _var5 _var7 _var8 _var10 _var11 _var14 _var15 _var18 _var19 _var22 ///
 _var23 _var44 _var48 _var49 _var52 _var53 _var72 _var73 _var74 _var77 _var78 ///
 _var101 _var102 _var125 _var126 _var146 _var147 _var149 _var150 _var152 _var153 ///
 _var157 _var158 _var160 _var161 _var165 _var166 _var167 _var168 _var169 ///
 
drop in 6
drop in 5
drop in 4
drop in 3
drop in 2
drop in 1

destring _all, replace
gen gsmaReg="Europe"

save "GSMA Europe Dataset.dta", replace

/*****************/
/*OCEANIA DATASET*/
/*****************/
import excel "GSMA Oceania overview.xls", sheet("Data") firstrow clear
drop in 1

sxpose, clear force

rename (_var1 _var3 _var4 _var6 _var9) (year unqsubs unqsubsmobile simspersub unqsubsmobilepct)
rename (_var12 _var13 _var16 _var17 _var20 _var21) (unqsubsnetaddstotal ///
 unqsubsnetaddsmobile unqsubstotalgr unqsubsmobilegr unqsubstotalmktpen unqsubsmobilemktpn)
 
rename (_var24 _var25 _var26 _var27 _var28 _var29 _var30 _var31 _var32 _var33 ///
 _var34 _var35 _var36 _var37 _var38 _var39 _var40 _var41 _var43 _var44 _var45) ///
 (connectionstotaliot connectionstotal connectionsprepaid connectionscontract ///
 connections2g connections3g connections4g connections5g connectionsmobbrd connectionssmrtphone ///
 connectionsbasic connectionsdataonly connectionscdma2g connectionsgsm connectionsiden connectionscdma2000 ///
 connectionswcdma connectionslte connectionsiot connectionsm2m connectionslpwa)

rename (_var48 _var49 _var52 _var53 _var54 _var55 _var56 _var57 _var58 _var59 ///
 _var60 _var61 _var62 _var63 _var64 _var65 _var66 _var67 _var71 _var72) (connectionstotalpct ///
 connectionsliciotpct connectionsprepaidpct connectionscontractpct connections2gpct ///
 connections3gpct connections4gpct connections5gpct connectionsmobbrdpct ///
 connectionssmrtphonepct connectionsbasicpct connectionsdataonlypct ///
 connectionscdma2gpct connectionsgsmpct connectionsidenpct connectionscdma2000pct ///
 connectionswcdmapct connectionsltepct connectionsm2mpct connectionslpwapct)
 
rename (_var75 _var76 _var77 _var78 _var79 _var80 _var81 _var82 _var83 _var84 ///
 _var85 _var86 _var87 _var88 _var89 _var90 _var91 _var92 _var93 _var94) ///
 (netaddstotaliot netaddstotal netaddsprepaid netaddscontract netadds2g netadds3g ///
 netadds4g netaddsmobbrd netaddssmrtphone netaddsbasic netaddsdataonly netaddscdma2g ///
 netaddsgsm netaddsiden netaddscdma2000 netaddswcdma netaddslte netaddsliciot ///
 netaddsm2m netaddslpwa)
 
rename (_var97 _var98 _var99 _var100 _var101 _var102 _var103 _var104 _var105 _var106 ///
 _var107 _var108 _var109 _var110 _var111 _var112 _var113 _var114 _var115 _var116) ///
 (netaddstotaliotgr netaddstotalgr netaddsprepaidgr netaddscontractgr netadds2ggr ///
 netadds3ggr netadds4ggr netaddsmobbrdgr netaddssmrtphonegr netaddsbasicgr ///
 netaddsdataonlygr netaddscdma2ggr netaddsgsmgr netaddsidengr netaddscdma2000gr ///
 netaddswcdmagr netaddsltegr netaddsliciotgr netaddsm2mgr netaddslpwagr)
 
rename (_var119 _var120 _var121 _var122 _var123 _var124 _var125 _var126 _var127 ///
 _var128 _var129 _var130 _var131 _var132 _var133 _var134 _var135) (mktpentotal ///
 mktpenprepaid mktpencontract mktpen2g mktpen3g mktpen4g mktpen5g mktpenmobbrd ///
 mktpensmrtphone mktpenbasic mktpendataonly mktpencdma2g mktpengsm mktpeniden ///
 mktpencdma2000 mktpenwcdma mktpenlte)
 
rename (_var138 _var141) (ARPU_by_sub ARPU_by_connection)
rename (_var144 _var145 _var146) (rev_total rev_recurring rev_nonrecurring)
rename (_var149 _var152 _var153 _var154) (capex popcoverage_3g popcoverage_4g popcoverage_5g)
 
drop _var2 _var5 _var7 _var8 _var10 _var11 _var14 _var15 _var18 _var19 _var22 ///
 _var23 _var42 _var46 _var47 _var50 _var51 _var68 _var69 _var70 _var73 _var74 ///
 _var95 _var96 _var117 _var118 _var136 _var137 _var139 _var140 _var142 _var143 ///
 _var147 _var148 _var150 _var151 _var155 _var156 _var157 _var158 _var159
 
drop in 6
drop in 5
drop in 4
drop in 3
drop in 2
drop in 1

destring _all, replace
gen gsmaReg="Oceania"

save "GSMA Oceania Dataset.dta", replace

/*MERGE DATASETS TOGETHER*/
append using "GSMA Africa Dataset.dta" "GSMA Americas Dataset.dta" ///
 "GSMA Asia Dataset.dta" "GSMA Europe Dataset.dta"
 
sort gsmaReg year

foreach v of varlist _all{
	local u: variable label `v'
	local x = "[GSMA 2018] " + "`u'"
	label var `v' "`x'"
}

order gsmaReg, first

save "GSMA World Dataset.dta", replace

