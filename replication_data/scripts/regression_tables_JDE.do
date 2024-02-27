

	cd "/Volumes/Samsung_T5/ENOE_long/JDE_data"


	use	   final_data_panel_105, clear
	
	append using final_data_panel_205
	append using final_data_panel_305
	append using final_data_panel_405
	append using final_data_panel_106
	append using final_data_panel_206
	append using final_data_panel_306
	append using final_data_panel_406
	
   
cap drop __*

label var HHnewmember_allperiod  "hh new memb all-period"
label var HHnewmember  "new member joining" 
	
	
	cap drop hh 
	cap drop hhper 
	bys id_h  : g hh = _n==1
	bys id_h PER : g hhper = _n==1
	

********	CONTROLS  ****************************

	egen id_mun = group( ENT MUN )  
	egen id_panelgroup   =group(panel_group  )

	global demo_control  
	local Ncohorts = ((70/5)+1)
         forval x = 1/`Ncohorts' {		
		local a0 = 5*(`x'-1)
		local a1 = 5*`x'-1
		global demo_control   $demo_control nbq1_male_`a0'_`a1' nbq1_fem_`a0'_`a1'
	}
    *
	
	g  nonhhnuclear_q1= hhnuclear_q1==0 
	label var nonhhnuclear_q1 "non-nuclear household q1"
	 global control  $demo_control i.hhmaxedu_q1 	


	
	label var HH_mex_before "Mex mig before"
	label var HHusmig_allperiod  "US mig  entire-period"
	label var HHusmig_fem_allperiod  "US mig female entire-period"

	label var HHmexmig_allperiod "Mex mig  entire-period"
	label var  HHmexmig_fem_allperiod "Mex mig female entire-period"
	
	label var HHnewmemb_nomexmig_allperiod "HH new member excl. US&Mex mig"
	label var HHnewmemb_noleaving_allperiod "HH new member excl. all movingout"
	
	
	global option varlabels  tex plain fragment  bdec(3)  se   starloc(1) starlevels(10 5  1) nocenter



	
**************************************************************************	
* TABLE 4, 5, 6 	
***************************************************************************			
	
 foreach place in all urb rur {
 	outreg, clear(newmember_`place') 
	
	tempvar samplee
	if "`place'"=="all"{
		g `samplee'=  present_N_ENT_12345 ==1 & hh==1 
	}
	if "`place'"=="rur"{
		g `samplee'= present_N_ENT_12345 ==1  &  hh==1  & ruralarea==1  
	}
	if "`place'"=="urb"{
		g `samplee'= present_N_ENT_12345 ==1  & hh==1 &  ruralarea==0 
	}
	 qui su  HHnewmember_allperiod    if `samplee'==1  & HHusmig_allperiod==0  
	local av1= round(r(mean),.001)
	
	global m1 HHusmig_allperiod   
	global m2 HHusmig_allperiod   HHusmig_fem_allperiod 
	
	foreach i in 1 2 {
	qui  reg HHnewmember_allperiod ${m`i'}  i.id_panelgroup  if  `samplee'==1 ,  vce(cluster id_h)   
	outreg, merge(newmember_`place')   	 nod keep( ${m`i'}) ctitle(" ", "")  ${option} ///
	addrows(  "Household controls", "" \ "Municipality FE", "" \"Average non-migrant", "`av1'" \ "F-test controls",  "" )  	
	
	qui  reg HHnewmember_allperiod ${m`i'} ${control} i.id_panelgroup  if  `samplee'==1 ,  vce(cluster id_h)   
	qui testparm ${control} 	
	local F= round(r(F),.001)
	outreg, merge(newmember_`place')   	 nod keep( ${m`i'}) ctitle(" ", "")  ${option} ///
	addrows(  "Household controls", "X" \ "Municipality FE", "" \"Average non-migrant", "`av1'" \ "F-test controls",    "`F'" )  	
	
	qui  areg HHnewmember_allperiod ${m`i'} ${control} i.id_panelgroup  if  `samplee'==1 , absorb(id_mun)  vce(cluster id_h)   
	qui testparm ${control} 	
	local F= round(r(F),.001)
	outreg, merge(newmember_`place')   	 nod keep( ${m`i'}) ctitle(" ", "")  ${option} ///
	addrows(  "Household controls", "X" \ "Municipality FE", "X" \"Average non-migrant", "`av1'" \ "F-test controls",    "`F'" )  	
	}
	
	}
	*
	
	*TABLE 4
	nois outreg    ,  replace  replay(newmember_all) title("Table 4: Migrant households and new members - All areas")   ${option}  
	
	*TABLE 5
	nois outreg    ,  replace  replay(newmember_urb) title("Table 5: Migrant households and new members- Urban areas")   ${option}  
	
	*TABLE 6
	nois outreg    ,  replace  replay(newmember_rur) title("Table 6: Migrant households and new members- Rural areas")   ${option}  
	
	
	
	
**************************************************************************	
* TABLE A.4 	
***************************************************************************			
		
	outreg, clear(tableA4) 
	
	tempvar samplee 
	g `samplee'=  present_N_ENT_12345 ==1 & HHnewmember_returnUS_allperiod ==0 &  hh==1 
	  
	su  HHnewmember_allperiod    if `samplee'==1  & HHusmig_allperiod==0  
	local av1= round(r(mean),.001)
	
	global m1 HHusmig_allperiod   
	global m2 HHusmig_allperiod   HHusmig_fem_allperiod 
	
	foreach i in 1 2 {
	qui  reg HHnewmember_allperiod ${m`i'} i.id_panelgroup  if  `samplee'==1 ,  vce(cluster id_h)   
	outreg, merge(tableA4)   	 nod keep( ${m`i'}) ctitle(" ", "")  ${option} ///
	addrows(  "Household controls", "" \ "Municipality FE", "" \"Average non-migrant", "`av1'" \ "F-test controls",  "" )  	
	
	qui  reg HHnewmember_allperiod ${m`i'} ${control} i.id_panelgroup  if  `samplee'==1 ,  vce(cluster id_h)   
	qui testparm ${control} 	
	local F= round(r(F),.001)
	outreg, merge(tableA4)     	 nod keep( ${m`i'}) ctitle(" ", "")  ${option} ///
	addrows(  "Household controls", "X" \ "Municipality FE", "" \"Average non-migrant", "`av1'" \ "F-test controls",    "`F'" )  	
	
	qui  areg HHnewmember_allperiod ${m`i'} ${control} i.id_panelgroup  if  `samplee'==1 , absorb(id_mun)  vce(cluster id_h)   
	qui testparm ${control} 	
	local F= round(r(F),.001)
	outreg, merge(tableA4)     	 nod keep( ${m`i'}) ctitle(" ", "")  ${option} ///
	addrows(  "Household controls", "X" \ "Municipality FE", "X" \"Average non-migrant", "`av1'" \ "F-test controls",    "`F'" )  	
	}
	*
	*TABLE A4
	nois outreg    ,  replace  replay(tableA4)   title("Table A.4 : Migrant households and new members - Excluding US returnees")   ${option}  
	
**************************************************************************	
* TABLE A.5	
***************************************************************************			
		
	
	global usmig_timing  HHusmig_befq3  HHusmig_befq2  HHusmig_befq1 HHusmig_simul  HHusmig_aftq1 HHusmig_aftq2 HHusmig_aftq3
	
	tempvar samplee
	g `samplee'= present_N_ENT_12345 ==1 &  hhper==1 & N_ENT>1
		
	qui su   HHnewmember   if `samplee'==1  & HHusmig_allperiod==0  
	local av= round(r(mean),.001)

	outreg , clear(tableA5)
	
	qui reg  HHnewmember  $usmig_timing    i.N_ENT#i.id_panelgroup if  `samplee'==1 ,  vce(cluster id_h)
	outreg, merge(tableA5) nod keep( $usmig_timing )   ${option} addrows( "Household controls", ""\ "Municipality FE", "" \ "F-test controls", "") 
	
	qui reg  HHnewmember  $usmig_timing   ${control}   i.N_ENT#i.id_panelgroup if   `samplee'==1  ,  vce(cluster id_h)
	qui testparm ${control} 
	local F= round(r(F),.001)
	outreg, merge(tableA5)  nod keep( $usmig_timing )   ${option} addrows( "Household controls", "X"\ "Municipality FE", "" \ "F-test controls", "`F'" ) 
	
	qui areg  HHnewmember  $usmig_timing   ${control}   i.N_ENT#i.id_panelgroup if   `samplee'==1  , absorb(id_mun) vce(cluster id_h)
	qui testparm ${control} 
	local F= round(r(F),.001)
	outreg, merge(tableA5)  nod keep( $usmig_timing )  ${option} addrows( "Household controls", "X"\ "Municipality FE", "X" \ "F-test controls", "`F'") 
	
	*TABLE A5
	nois outreg    ,  replace  replay(tableA5)   title("Table A.5 Relative timing of migration and of the arrival of new members")   ${option}  
	
	
	
**************************************************************************	
* TABLE 7 
***************************************************************************			
	
	outreg, clear(table7) 
	
	tempvar samplee 
	g `samplee'=  present_N_ENT_12345 ==1 &  hh==1 
	  
	su HH_OUTleave_allperiod   if `samplee'==1  & HHusmig_allperiod==0  
	local av1= round(r(mean),.001)
	
	global m1 HHusmig_allperiod   
	global m2 HHusmig_allperiod   HHusmig_fem_allperiod 
	
	foreach i in 1 2 {
	qui  reg HH_OUTleave_allperiod ${m`i'}  i.id_panelgroup  if  `samplee'==1 ,  vce(cluster id_h)   
	outreg, merge(table7)   	 nod keep( ${m`i'}) ctitle(" ", "")  ${option} ///
	addrows(  "Household controls", "" \ "Municipality FE", "" \"Average non-migrant", "`av1'" \ "F-test controls",  "" )  	
	
	qui  reg HH_OUTleave_allperiod ${m`i'} ${control} i.id_panelgroup  if  `samplee'==1 ,  vce(cluster id_h)   
	qui testparm ${control} 	
	local F= round(r(F),.001)
	outreg, merge(table7)     	 nod keep( ${m`i'}) ctitle(" ", "")  ${option} ///
	addrows(  "Household controls", "X" \ "Municipality FE", "" \"Average non-migrant", "`av1'" \ "F-test controls",    "`F'" )  	
	
	qui  areg HH_OUTleave_allperiod ${m`i'} ${control} i.id_panelgroup  if  `samplee'==1 , absorb(id_mun)  vce(cluster id_h)   
	qui testparm ${control} 	
	local F= round(r(F),.001)
	outreg, merge(table7)     	 nod keep( ${m`i'}) ctitle(" ", "")  ${option} ///
	addrows(  "Household controls", "X" \ "Municipality FE", "X" \"Average non-migrant", "`av1'" \ "F-test controls",    "`F'" )  	
	}
	*
	*TABLE 7
	nois outreg    ,  replace  replay(table7)   title("Table 7 : Migrant households and leaving members")   ${option}  
	
	
	
*************************************************************************	
* Table 8, Table A.6 and A.7 
***************************************************************************			
		
	g attrition_a  = 0  
	foreach q in 1 2 3 4 {
	local j = `q' +1 
	replace  attrition_a  = 1 if N_ENT==`q' &  hh_interview`j'==0 
	}
	replace   attrition_a= . if N_ENT==5 
	

	foreach place in all urb  rur  {

	outreg, clear(attrit_`place') 

	tempvar samplee
	if "`place'"=="all"{
		g `samplee'=  hhper==1 & (N_ENT==2 |N_ENT==3| N_ENT==4)   & max_HH_ent>=2 
	}
	if "`place'"=="rur"{
		g `samplee'= ruralarea==1 & hhper==1 & (N_ENT==2 |N_ENT==3| N_ENT==4)   & max_HH_ent>=2  
	}
	if "`place'"=="urb"{
		g `samplee'=ruralarea==0 & hhper==1 & (N_ENT==2 |N_ENT==3| N_ENT==4)   & max_HH_ent>=2 
	}
		
	qui su  attrition_a  if  HHusmig_allperiod==0 & `samplee'==1 
	  local av= round(r(mean),.001)

	  
	** BASELINE 	   

	global m1   HH_us_before 
	global m2   HH_us_before  HH_us_female_before

	foreach i in 1 2  {

	qui reg attrition_a   ${m`i'}  	 i.N_ENT#i.id_panelgroup  if   `samplee'==1 ,  vce(cluster id_h)     
	outreg, merge(attrit_`place') nod keep(${m`i'})  ${option} addrows("Household controls","" \ "Municipality FE", "" \"Average non-migrant", "`av'" \ "F-test controls","" )  	

	qui reg attrition_a   ${m`i'}  ${control}	 i.N_ENT#i.id_panelgroup  if   `samplee'==1 ,  vce(cluster id_h)     
	qui testparm ${control} 
	local F= round(r(F),.001)
	outreg, merge(attrit_`place') nod keep(${m`i'})  ${option} addrows("Household controls","X" \ "Municipality FE", "" \"Average non-migrant", "`av'" \ "F-test controls", "`F'" )  	

	qui areg attrition_a   ${m`i'}  ${control}	 i.N_ENT#i.id_panelgroup  if   `samplee'==1 ,  absorb(id_mun)  vce(cluster id_h)     
	qui testparm ${control} 
	local F= round(r(F),.001)
	outreg, merge(attrit_`place') nod keep(${m`i'})  ${option} addrows("Household controls","X" \ "Municipality FE", "X" \"Average non-migrant", "`av'" \ "F-test controls", "`F'" )  	
	}

	}
	*
	
	*Table 8
	nois outreg    ,  replace  replay(attrit_all) ${option}    title("Table 8: Migration and attrition")  ctitle(" ", "")  

	*Table A.6
	nois outreg    ,  replace  replay(attrit_urb) ${option}    title("Table A.6: Migration and attrition - Urban areas ")  ctitle(" ", "")  

	*Table A.7
	nois outreg    ,  replace  replay(attrit_rur) ${option}    title("Table A.7: Migration and attrition- Rural areas ")  ctitle(" ", "")  

*************************************************************************	
* Table A.8 
***************************************************************************			

	outreg, clear(tableA8) 

	tempvar samplee
	g `samplee'=hhper==1 & (N_ENT==2 |N_ENT==3| N_ENT==4)   & max_HH_ent>=2 
	
	global m1  HHusmig_befq2  HHusmig_befq1  HHusmig_simul

	qui reg attrition_a   ${m1}  	 i.N_ENT#i.id_panelgroup  if   `samplee'==1 ,  vce(cluster id_h)     
	outreg, merge(tableA8) nod keep(${m1})  ${option} addrows("Household controls","" \ "Municipality FE", "" \"Average non-migrant", "`av'" \ "F-test controls","" )  	

	qui reg attrition_a   ${m1}  ${control}	 i.N_ENT#i.id_panelgroup  if   `samplee'==1 ,  vce(cluster id_h)     
	qui testparm ${control} 
	local F= round(r(F),.001)
	outreg, merge(tableA8) nod keep(${m1})  ${option} addrows("Household controls","X" \ "Municipality FE", "" \"Average non-migrant", "`av'" \ "F-test controls", "`F'" )  	

	qui areg attrition_a   ${m1}  ${control}	 i.N_ENT#i.id_panelgroup  if   `samplee'==1 ,  absorb(id_mun)  vce(cluster id_h)     
	qui testparm ${control} 
	local F= round(r(F),.001)
	outreg, merge(tableA8) nod keep(${m1})  ${option} addrows("Household controls","X" \ "Municipality FE", "X" \"Average non-migrant", "`av'" \ "F-test controls", "`F'" )  	
	
	*Table A.8
	nois outreg    ,  replace  replay(tableA8) ${option}    title("Table A.8: Relative timing of migration and attrition ") ctitle(" ", "")  


*************************************************************************	
* Table 9, A.9 and A.10 
***************************************************************************			
	
	
	g sample_remi =  hhper==1 & present_N_ENT_12345 ==1 & HHusmig_allperiod==0  & rateUS_2000 !=.
	
	*definition high-migration municipality 
	xtile  highmig_2000_all  = rateUS_2000 if sample_remi==1   ,nq(2)
	xtile  highmig_2000_rur  = rateUS_2000 if ruralarea==1 &  sample_remi==1   ,nq(2)
	xtile  highmig_2000_urb  = rateUS_2000 if ruralarea==0 &  sample_remi==1   ,nq(2)
	
	foreach v of varlist highmig_2000_* {
	replace `v'= 0 if `v'==1
	replace  `v'= 1 if `v'==2
	}
	*
	
	*interaction New member and high-migration municipality 
	foreach v in HH_newmemb_before {
	local l :  variable label   `v'
	g `v'_higUS_all =   highmig_2000_all * `v'
	g `v'_higUS_rur =  highmig_2000_rur * `v'
	g `v'_higUS_urb =  highmig_2000_urb * `v'
	label var `v'_higUS_all " `l'* High US-mig munip 2000"
	label var `v'_higUS_urb  " `l'* High US-mig munip 2000"
	label var `v'_higUS_rur  " `l'* High US-mig munip 2000"
	}
	*	
	label var highmig_2000_all "High US-mig munip 2000 (rural)"
	label var highmig_2000_rur "High US-mig munip 2000 (rural)"
	label var highmig_2000_urb "High US-mig munip 2000 (urban)"
	

	global option varlabels  tex plain fragment  bdec(4)  se   starloc(1) starlevels(10 5  1) 
	
	
foreach place in all urb rur {
	outreg, clear(remi_`place') 	

	tempvar sample
	g `sample' =  sample_remi== 1 & N_ENT>=2  & HHnewmember_returnUS_allperiod ==0 
	
	local area="all"
	if "`place'"=="rur" {
	replace `sample'=  `sample'==1 & ruralarea==1
	local area="rur"
	}	
	if "`place'"=="urb" {
	replace `sample'= `sample'==1 & ruralarea==0
	local area="urb"
	}
	qui su  HH_remittances   if `sample'==1  &  HH_newmemb_before  ==0  
		local av= round(r(mean),.001)	
	qui su  HH_remittances  if `sample'==1  &  HH_newmemb_before  ==0  & highmig_2000_`area'==1
		local av_h= round(r(mean),.001)
		
	global m1	   HH_newmemb_before
	global m2      HH_newmemb_before HH_newmemb_before_higUS_`area' highmig_2000_`area' 
	global m2_b    HH_newmemb_before HH_newmemb_before_higUS_`area'  
	
	qui  reg  HH_remittances   ${m1}    i.N_ENT#i.id_panelgroup  if   `sample'==1 ,  vce(cluster id_h)   
	outreg, merge(remi_`place')  nod keep( ${m1}  )   ${option} addrows("Household controls", "" \ "Municipality FE","" \ "Av. hh without new memb", "`av'" \ "Av. no new in high-munip", "`av_h'"  \ "F-test controls",  "" )  	
	
	qui  reg  HH_remittances   ${m2}   i.N_ENT#i.id_panelgroup  if   `sample'==1 ,  vce(cluster id_h)   
	outreg, merge(remi_`place')  nod keep(${m2_b})   ${option} addrows("Household controls", "" \ "Municipality FE","" \ "Av. hh without new memb", "`av'" \ "Av. no new in high-munip", "`av_h'"  \ "F-test controls",  "" )  	
	
	qui  reg  HH_remittances   ${m1} ${control}   i.N_ENT#i.id_panelgroup  if   `sample'==1 ,  vce(cluster id_h)   
	qui testparm ${control} 
	local F= round(r(F),.001)
	outreg, merge(remi_`place')  nod keep( ${m1}  )   ${option} addrows("Household controls", "X" \ "Municipality FE","" \ "Av. hh without new memb", "`av'" \ "Av. no new in high-munip", "`av_h'"  \ "F-test controls",   "`F'" )  	
	
	qui  reg  HH_remittances   ${m2} ${control}   i.N_ENT#i.id_panelgroup  if   `sample'==1 ,  vce(cluster id_h)   
	qui testparm ${control} 
	local F= round(r(F),.001)
	outreg, merge(remi_`place')  nod keep(${m2_b})   ${option} addrows("Household controls", "X" \ "Municipality FE","" \ "Av. hh without new memb", "`av'" \ "Av. no new in high-munip", "`av_h'"  \ "F-test controls",   "`F'" )  	
	
	qui  areg  HH_remittances  ${m1} ${control}  i.N_ENT#i.id_panelgroup  if  `sample'==1 , absorb(id_mun)  vce(cluster id_h)   
	qui testparm ${control} 
	local F= round(r(F),.001)
	outreg, merge(remi_`place')  nod keep( ${m1}  )   ${option} addrows("Household controls", "X" \ "Municipality FE","X" \ "Av. hh without new memb", "`av'" \ "Av. no new in high-munip", "`av_h'"  \ "F-test controls",   "`F'" )  	
	
	qui  areg  HH_remittances  ${m2_b} ${control}  i.N_ENT#i.id_panelgroup  if  `sample'==1 , absorb(id_mun)  vce(cluster id_h)   
	qui testparm ${control} 
	local F= round(r(F),.001)
	outreg, merge(remi_`place')  nod keep( ${m2_b}  )   ${option} addrows("Household controls", "X" \ "Municipality FE","X" \ "Av. hh without new memb", "`av'" \ "Av. no new in high-munip", "`av_h'"  \ "F-test controls",   "`F'" )  	
			
	}
	*
	
	*Table 9
	nois outreg    ,  replace  replay(remi_all) ${option}    title("Table 9: Receipt of remittances by non-migrant households") ctitle(" ", "")  

	*Table A.9
	nois outreg    ,  replace  replay(remi_urb) ${option}    title("Table A.9: Receipt of remittances by non-migrant households - Urban areas") ctitle(" ", "")  
	
	*Table A.10
	nois outreg    ,  replace  replay(remi_rur) ${option}    title("Table A.10: Receipt of remittances by non-migrant households- Rural areas") ctitle(" ", "")  

	
*************************************************************************	
* Table 10, A.11 and A.12 
***************************************************************************			
		
	foreach place in all urb rur {
	outreg, clear(placebo_`place') 	

	tempvar sample
	g `sample' =  sample_remi== 1 & N_ENT>=2  & HHnewmember_returnUS_allperiod ==0 
	
	local area="all"
	if "`place'"=="rur" {
	replace `sample'=  `sample'==1 & ruralarea==1
	local area="rur"
	}	
	if "`place'"=="urb" {
	replace `sample'= `sample'==1 & ruralarea==0
	local area="urb"
	}
	qui su  HH_remittances_no_newever2   if `sample'==1  &  HH_newmemb_before  ==0  
		local av= round(r(mean),.001)	
	qui su  HH_remittances_no_newever2  if `sample'==1  &  HH_newmemb_before  ==0  & highmig_2000_`area'==1
		local av_h= round(r(mean),.001)
		
	global m1	   HH_newmemb_before
	global m2      HH_newmemb_before HH_newmemb_before_higUS_`area' highmig_2000_`area' 
	global m2_b    HH_newmemb_before HH_newmemb_before_higUS_`area'  
	
	qui  reg  HH_remittances_no_newever2   ${m1}    i.N_ENT#i.id_panelgroup  if   `sample'==1 ,  vce(cluster id_h)   
	outreg, merge(placebo_`place')   nod keep( ${m1}  )   ${option} addrows("Household controls", "" \ "Municipality FE","" \ "Av. hh without new memb", "`av'" \ "Av. no new in high-munip", "`av_h'"  \ "F-test controls",  "" )  	
	
	qui  reg HH_remittances_no_newever2   ${m2}   i.N_ENT#i.id_panelgroup  if   `sample'==1 ,  vce(cluster id_h)   
	outreg, merge(placebo_`place')  nod keep(${m2_b})   ${option} addrows("Household controls", "" \ "Municipality FE","" \ "Av. hh without new memb", "`av'" \ "Av. no new in high-munip", "`av_h'"  \ "F-test controls",  "" )  	
	
	qui  reg  HH_remittances_no_newever2   ${m1} ${control}   i.N_ENT#i.id_panelgroup  if   `sample'==1 ,  vce(cluster id_h)   
	qui testparm ${control} 
	local F= round(r(F),.001)
	outreg, merge(placebo_`place')  nod keep( ${m1}  )   ${option} addrows("Household controls", "X" \ "Municipality FE","" \ "Av. hh without new memb", "`av'" \ "Av. no new in high-munip", "`av_h'"  \ "F-test controls",   "`F'" )  	
	
	qui  reg  HH_remittances_no_newever2    ${m2} ${control}   i.N_ENT#i.id_panelgroup  if   `sample'==1 ,  vce(cluster id_h)   
	qui testparm ${control} 
	local F= round(r(F),.001)
	outreg, merge(placebo_`place')  nod keep(${m2_b})   ${option} addrows("Household controls", "X" \ "Municipality FE","" \ "Av. hh without new memb", "`av'" \ "Av. no new in high-munip", "`av_h'"  \ "F-test controls",   "`F'" )  	
	
	qui  areg  HH_remittances_no_newever2   ${m1} ${control}  i.N_ENT#i.id_panelgroup  if  `sample'==1 , absorb(id_mun)  vce(cluster id_h)   
	qui testparm ${control} 
	local F= round(r(F),.001)
	outreg, merge(placebo_`place')   nod keep( ${m1}  )   ${option} addrows("Household controls", "X" \ "Municipality FE","X" \ "Av. hh without new memb", "`av'" \ "Av. no new in high-munip", "`av_h'"  \ "F-test controls",   "`F'" )  	
	
	qui  areg  HH_remittances_no_newever2   ${m2_b} ${control}  i.N_ENT#i.id_panelgroup  if  `sample'==1 , absorb(id_mun)  vce(cluster id_h)   
	qui testparm ${control} 
	local F= round(r(F),.001)
	outreg, merge(placebo_`place')  nod keep( ${m2_b}  )   ${option} addrows("Household controls", "X" \ "Municipality FE","X" \ "Av. hh without new memb", "`av'" \ "Av. no new in high-munip", "`av_h'"  \ "F-test controls",   "`F'" )  	
			
	}
	*
	
	*Table 10
	nois outreg    ,  replace  replay(placebo_all)  ${option}    title("Table 10: Placebo test on the receipt of remittances by non-migrant households") ctitle(" ", "")  

	*Table A.11
	nois outreg    ,  replace  replay(placebo_urb) ${option}    title("Table A.11: Placebo test on the receipt of remittances by non-migrant households - Urban areas") ctitle(" ", "")  
	
	*Table A.12
	nois outreg    ,  replace  replay(placebo_rur) ${option}    title("Table A.12: Placebo test on the receipt of  remittances by non-migrant households- Rural areas") ctitle(" ", "")  

	
	
	
