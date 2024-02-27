
		
	
	cd "/Volumes/Samsung_T5/ENOE_long/JDE_data"

	

*******************************
* FIGURE 1 
*******************************
		  
	*Generate the age pyramid for migrant and non-migrant households
	*Use data of the first interview
	*Only non-attrited households

	*Initial age distribution for migrant and non-migrant households
	
	
	use	   final_data_panel_105, clear
	
	append using final_data_panel_205
	append using final_data_panel_305
	append using final_data_panel_405
	append using final_data_panel_106
	append using final_data_panel_206
	append using final_data_panel_306
	append using final_data_panel_406
	
	*** SAMPLE SELECTION : non-attriter 
	keep if present_N_ENT_12345 ==1 
	
	forvalues i=1(1)15 {
		gen age_`i'=0
		replace age_`i'=1 if agroup==`i'
	}
	keep if N_ENT==1
	gen x=1
	collapse (sum) age_*, by(HHusmig_allperiod SEX)
	reshape long age_ , i(SEX HHusmig_allperiod) j(agegroup)	
	rename age_  value
	reshape wide value , i(agegroup HHusmig_allperiod) j(SEX)
	rename value1 value_male
	rename value2 value_fem 
	bys HHusmig_allperiod: egen tot_male= total(value_male)
	bys HHusmig_allperiod: egen tot_fem= total(value_fem)
	g sh_male= 100* value_male/tot_male
	g sh_fem= 100* value_fem/tot_fem
	replace sh_male = -sh_male
	
	label define agegrp  1 "0-4" 2 "5-9" 3 "10-14" 4 "15-19" 5 "20-24" 6 "25-29" 7 "30-34" 8 "35-39" 9 "40-44" ///
				 10 "45-49" 11 "50-54" 12 "55-59" 13 "60-64" 14 "65-69" 15 "70+", replace
	label values  agegroup  agegrp 
	
	gen zero = 0	
	
	#delimit ;
	twoway
			bar sh_male  agegroup if HHusmig_allperiod==0 , horizontal bfc(gs12)  ||
		   bar sh_fem agegroup if HHusmig_allperiod==0  , horizontal bfc(gs12)  ||
		   bar sh_male  agegroup if HHusmig_allperiod==1 , horizontal  fcolor(none)  lcolor(black) color(black)   lwidth(medium) lpattern(solid) ||
		   bar sh_fem agegroup if HHusmig_allperiod==1  , horizontal  fcolor(none)  lcolor(black) color(black) lwidth(medium) lpattern(solid)   ||	   
	scatter  agegroup zero, mlabel(agegroup) mlabcolor(black) msymbol(none) || , 
	title( "Figure 1: Age pyramid in migrant and non-migrant households")
	note("Notes: the black solid (shaded gray) line represents the age structure of migrant (non-migrant)" "households observed in the first interview."
	 "Source: Authors’ elaboration on ENOE 2005Q1-2006Q4.")
	xtitle("Share (precent)") ytitle("Age")
	xlabel( -16 "16" -14 "14" -12 "12" -10 "10" -8 "8" -6 "6" -4 "4" -2 "2"  0(2)16 )
	legend(off) text(12 -8 "Male") text(12 8 "Female")
	;
	#delimit cr

		
*******************************
* FIGURE 2 
*******************************
	
	tempfile temp1 temp2 temp3
	

	use	   final_data_panel_105, clear
	append using final_data_panel_205
	append using final_data_panel_305
	append using final_data_panel_405
	append using final_data_panel_106
	append using final_data_panel_206
	append using final_data_panel_306
	append using final_data_panel_406

	keep if present_N_ENT_12345 ==1 
	keep if N_ENT==1
	
	*Stayers (no distinction by migrant status)
	
	forvalues i=1(1)15 {
	gen age_`i'=0
	replace age_`i'=1 if agroup==`i'
	}
	gen x=1
	collapse (sum) age_*, by(SEX)
	reshape long age_ , i(SEX) j(agegroup)	
	rename age_  value
	reshape wide value , i(agegroup) j(SEX)
	rename value1 stayer_male
	rename value2  stayer_fem 
	egen tot_male= total(stayer_male)
	egen tot_fem= total(stayer_fem)
	replace stayer_male = 100* stayer_male/tot_male
	replace stayer_fem = 100* stayer_fem/tot_fem
	save `temp1', replace
	
	*New members
	use	   final_data_panel_105, clear
	append using final_data_panel_205
	append using final_data_panel_305
	append using final_data_panel_405
	append using final_data_panel_106
	append using final_data_panel_206
	append using final_data_panel_306
	append using final_data_panel_406
	
	keep if present_N_ENT_12345 ==1 
	
	keep if newmember==1
	forvalues i=1(1)15 {
	gen age_`i'=0
	replace age_`i'=1 if agroup==`i'
	}
	gen x=1
	collapse (sum) age_*, by(SEX)
	reshape long age_ , i(SEX) j(agegroup)	
	rename age_  value
	reshape wide value , i(agegroup) j(SEX)
	rename value1 new_male
	rename value2 new_fem 
	egen tot_male= total(new_male)
	egen tot_fem= total(new_fem)
	replace new_male = 100*  new_male/tot_male
	replace new_fem = 100*  new_fem/tot_fem
	save `temp2', replace
	

	*Leaving members	
		use	   final_data_panel_105, clear
	append using final_data_panel_205
	append using final_data_panel_305
	append using final_data_panel_405
	append using final_data_panel_106
	append using final_data_panel_206
	append using final_data_panel_306
	append using final_data_panel_406
	
	keep if present_N_ENT_12345 ==1 
	keep if leaving_noUS==1
	forvalues i=1(1)15 {
	gen age_`i'=0
	replace age_`i'=1 if agroup==`i'
	}
	gen x=1
	collapse (sum) age_*, by(SEX)
	reshape long age_ , i(SEX) j(agegroup)	
	rename age_  value
	reshape wide value , i(agegroup) j(SEX)
	rename value1 leaving_male
	rename value2 leaving_fem 
	egen tot_male= total(leaving_male)
	egen tot_fem= total(leaving_fem)
	replace leaving_male = 100* leaving_male/tot_male
	replace leaving_fem = 100* leaving_fem/tot_fem
	save `temp3', replace
	
	merge 1:1 agegroup  using `temp1'
	drop _m
	merge 1:1 agegroup using `temp2'
	drop _m
	
	foreach v in leaving_male stayer_male new_male {
	replace `v'= -`v'
	}
	label define agegrp  1 "0-4" 2 "5-9" 3 "10-14" 4 "15-19" 5 "20-24" 6 "25-29" 7 "30-34" 8 "35-39" 9 "40-44" ///
				 10 "45-49" 11 "50-54" 12 "55-59" 13 "60-64" 14 "65-69" 15 "70+", replace
	label values  agegroup  agegrp 
	
	#delimit ;
	twoway  bar stayer_male  agegroup , horizontal   bfc(gs14) ||
		   bar  stayer_fem agegroup , horizontal   bfc(gs14)    ||
		   bar  new_male agegroup  , horizontal  fcolor(none)  lcolor(gs9)   lwidth(thick ) ||
		   bar  new_fem agegroup  , horizontal  fcolor(none)  lcolor(gs9)   lwidth(thick ) ||
		   bar leaving_male  agegroup , horizontal  fcolor(none)  lcolor(black)   lwidth(vthin )  ||
		   bar  leaving_fem agegroup , horizontal  fcolor(none)  lcolor(black)   lwidth(vthin ) || ,
		 title("Figure 2: Age pyramid for initial, new and" "leaving household members")
		 xtitle("Share (precent)") ytitle("Age")
		xlabel( -22 "22" -20 "20" -18 "18" -16 "16" -14 "14" -12 "12" -10 "10" -8 "8" -6 "6" -4 "4" -2 "2"  0(2)22 )
		legend(off) text(12 -8 "Male") text(12 8 "Female") ylabel(1 "0-4" 2 "5-9" 3 "10-14" 4 "15-19" 5 "20-24" 6 "25-29" 7 "30-34" 8 "35-39" 9 "40-44" 
				 10 "45-49" 11 "50-54" 12 "55-59" 13 "60-64" 14 "65-69" 15 "70+", angle(horizontal))
		note("Notes: the shaded grey area represents the age structure of individuals in the household roster in the first interview."
		"The thin black line  represents the age structure of leaving members."
		"The thick grey line  represents the age structure of new members."
		"The sample is restricted to households successfully interviewed for five quarters."
		"Source: Authors’ elaboration on ENOE 2005Q1-2006Q4.", span)
		 ;
	#delimit cr
	
  

