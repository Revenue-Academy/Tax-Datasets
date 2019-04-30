clear all
set more off

cd "C:\Users\WB542385\OneDrive - WBG\GSMA"
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
rename (_var71 _var72 _var73 _var75 _var76 _var77 _var78 _var79 _var80 _var81 ///
 _var82 _var83 _var84 _var85 _var86 _var87 _var88 _var89 _var90) (netaddstotaliot ///
 netaddstotal netaddsprepaid netaddscontract netadds2g netadds3g netadds4g ///
 netaddsmobbrd netaddssmrtphone netaddsbasic netaddsdataonly netaddscdma2g netaddsgsm ///
 netaddscdma2000 netaddswcdma netaddslte netaddswimax netaddsliciot netaddsm2m ///
 netaddslpwa)
rename (_var93 _var94 _var95 _var96 _var97 _var98 _var99 _var100 _var101 _var102 ///
 _var103 _var104 _var105 _var106 _var107 _var108 _var109 _var110 _var111 _var112) ///
 (netaddstotaliotgr netaddstotalgr netaddsprepaidgr netaddscontractgr netadds2ggr ///
 netadds3ggr netadds4ggr netaddsmobbrdgr netaddssmrtphonegr netaddsbasicgr ///
 netaddsdataonlygr netaddscdma2ggr netadddsgsmgr netaddscdma200gr netaddswcdmagr ///
 netaddsltegr netaddswimaxgr netaddsliciotgr netaddsm2mgr netaddslpwagr)
 rename (_var115 _var116 _var117 _var118 _var119 _var120 _var121 _var122 _var123 ///
 _var124 _var125 _var126 _var127 _var128 _var129 _var130) (mktpentotal mktpenprepaid ///
 mktpencontract mktpen2g mktpen3g mktpen4g mktpenmobbrd mktpensmrtphone mktpenbasic ///
 mktpendataonly mktpencdma2g mktpengsm mktpencdma2000 mktpenwcdma mktpenlte ///
 mktpenwimax)
rename (_var132 _var135) (ARPU_by_sub APRU_by_connection)
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

save "GSMA Africa Dataset.dta", replace

