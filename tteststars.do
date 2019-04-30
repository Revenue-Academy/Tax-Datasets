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

/*Examples: ***, **, *, _ */
ttest Tax_Revenue if Reg==2, by(democracy)
tteststars
ttest ermrating if Reg==2, by(democracy)
tteststars
ttest WHTrates_country_min, by(SSA)
tteststars
ttest WHTrates_country_min, by(EAP)
tteststars

