
********************************************************************************************************************************

********				 STAT DESC      *********

********************************************************************************************************************************



	cd "/Volumes/Samsung_T5/ENOE_long/JDE_data"
		
	

	use	   final_data_panel_105, clear
	
	append using final_data_panel_205
	append using final_data_panel_305
	append using final_data_panel_405
	append using final_data_panel_106
	append using final_data_panel_206
	append using final_data_panel_306
	append using final_data_panel_406
	
	cap drop hh 
	cap drop hhper 
	
	g PER_label=.
	local i=1
	foreach y in 2005 2006 2007 {
	foreach q in 1 2 3 4 {
	 replace PER_label = `i' if year==`y' & quarter==`q'		
	if `i'==1{
	  label def perrr  `i' "`y' - Q`q' ", replace
		}
		else{
		  label def perrr  `i' "`y' - Q`q' ", modify
		}
			local i=`i' + 1
	}
	}
	label values  PER_label  perrr 
	label def inter 1 "1st" 2 "2nd" 3 "3rd" 4 "4th" 5 "5th", replace
	label values  N_ENT   inter 
		
	bys id_h  : g hh=  _n==1
	bys id_h PER : g hhper=  _n==1
	
*******************************
* TABLE A.1 and TABLE A.2 
*******************************


	
	
	ta  PER_label  N_ENT if hhper==1 
	ta  PER_label  N_ENT  if hhper==1 & present_N_ENT_12345 ==1 & HH_remittances!=.  
	
	
	
*******************************
* TABLE 1 and TABLE 3 
*******************************
	

	
	* Attrition	
    g attrit_drop = hh_interview5==0 |  hh_interview4==0 | hh_interview3==0 | hh_interview2==0 
	label var attrit_drop "Attrition" 
	
	* sample of households at first-interview
	g samplee_at =   hhper ==1 & N_ENT ==1 	
	* sample of non-attriter households at first-interview
	g samplee =      present_N_ENT_12345 ==1 & hhper ==1 & N_ENT ==1 
	
	* MULTIPLE MEMBERS JOINING OR LEAVING 
	bys id_h : egen nb_HHnewmem =total( newmember)
	bys id_h : egen nb_HHleave = total( leaving_noUS )	 
	g cond_nb_HHnewmem =  nb_HHnewmem if nb_HHnewmem>=1 
	g cond_nb_HHleave =  nb_HHleave if nb_HHleave>=1 
	g cond_nb1_HHnewmem =  nb_HHnewmem ==1 if nb_HHnewmem>=1 
	g cond_nb1_HHleave =  nb_HHleave==1 if nb_HHleave>=1 
	
	egen HH_inout_allperiod= rmax( HH_OUTleave_allperiod  HHnewmember_allperiod )
	egen HH_inout_noUS_allperiod= rmax( HH_OUTleave_allperiod  	HHnewmember_noUS_allperiod)
	
	 
	label var hhsize "hhsize"
	label var hh_maxyedu   "maximum years education"
	label var three_gen_v2  "Three generation households"
	label var HH_remittances "Remittances receipt "
	label var HH_transter_mex  "Extended family transfers receipt (in Mexico) "
	label var HH_remittances_N1 "Remittances(1st interview)"
	label var HH_remittances_N5 "Remittances(5th interview)"
	label var  nuclear_household  "nuclear household"	
	
	label var HHnewmember_allperiod "HH with new members"
	label var HHnewmember_noUS_allperiod   "HH with new members (no US returnees) "
	label var HH_inout_allperiod "HH with eaving or new members" 
	label var HH_inout_noUS_allperiod "HH with leaving or new members (no US returnees)" 
	label var HH_OUTleave_allperiod "HH with leaving members "
	label var cond_nb_HHnewmem "nb new members (conditional)" 
	label var cond_nb_HHleave  "nb leaving members (conditional)" 
	label var cond_nb1_HHnewmem "only one new member (conditional)" 
	label var cond_nb1_HHleave  "only one leaving member (conditional)" 
	 
  
	 global table1  hhsize	hh_maxyedu nuclear_household three_gen_v2   HH_remittances_N5 HH_remittances_N1 	
					
	global table3   HHnewmember_allperiod  cond_nb_HHnewmem cond_nb1_HHnewmem HHnewmember_noUS_allperiod 	///	
					HH_OUTleave_allperiod cond_nb_HHleave cond_nb1_HHleave	///
					HH_inout_allperiod		HH_inout_noUS_allperiod  
			
				
	 eststo clear 
	 foreach M in 1 0 {
	 qui eststo  table1_HH_us`M'  : estpost tabstat  ${table1}    if  samplee==1 & HHusmig_allperiod==`M', statistics(n mean  sd   ) columns(statistics) 	
	 qui eststo  attri_HH_us`M'  : estpost tabstat   attrit_drop if  samplee_at==1 & HHusmig_allperiod==`M', statistics(n mean  sd   ) columns(statistics) 	
	 qui eststo  table3_us`M'  : estpost tabstat  ${table3}    if  samplee==1 & HHusmig_allperiod==`M', statistics(n mean  sd   ) columns(statistics) 	
	 }
	qui eststo  table1_HH  : estpost tabstat  ${table1}   if  samplee==1 , statistics(n mean  sd   ) columns(statistics) 	
	qui eststo  table3_HH  : estpost tabstat  ${table3}   if  samplee==1 , statistics(n mean  sd   ) columns(statistics) 	
	qui eststo  attri_HH   : estpost tabstat  attrit_drop       if  samplee_at==1 , statistics(n mean  sd   ) columns(statistics) 	
	
	 foreach  R in 1 0 {
	 foreach M in 1 0 {
	 qui eststo  table1_rural`R'__us`M'  : estpost tabstat  ${table1}     if   samplee==1    & ruralarea== `R'  & HHusmig_allperiod==`M', statistics(n mean  sd   ) columns(statistics) 	
     qui eststo  table3_rural`R'__us`M'  : estpost tabstat  ${table3}     if   samplee==1    & ruralarea== `R'  & HHusmig_allperiod==`M', statistics(n mean  sd   ) columns(statistics) 	
	 qui eststo  attri_rural`R'__us`M' : estpost tabstat attrit_drop   if  samplee_at==1  & ruralarea== `R'  & HHusmig_allperiod==`M', statistics(n mean  sd   ) columns(statistics) 	
	
	 }
	 qui eststo   table1_rural`R'  : estpost tabstat  ${table1}       if   samplee==1      &  ruralarea== `R'  , statistics(n mean  sd   ) columns(statistics) 	
	 qui eststo  table3_rural`R'  : estpost tabstat  ${table3}       if   samplee==1      &  ruralarea== `R'  , statistics(n mean  sd   ) columns(statistics) 	
	 qui eststo  attri_rural`R'  : estpost tabstat   attrit_drop   if   samplee_at==1  &  ruralarea== `R' , statistics(n mean  sd   ) columns(statistics) 	

	}
	*
	 
	 *Table 1
			 
	nois esttab    attri_HH    attri_HH_us0 attri_HH_us1  attri_rural1  attri_rural1__us0 attri_rural1__us1 /// 
			       attri_rural0   attri_rural0__us0 attri_rural0__us1 ///
			      , title("Table 1: Descriptive statistics")   mtitle ( "ALL" "Non-migrant" "Migrant"  "RURAL" "Non-migrant" "Migrant" ///
					  "URBAN" "Non-migrant" "Migrant" ) label  cells( `"mean( fmt(3) pattern(1 1 ) )"' ) ///
			   varwidth(30) nonumbers nogaps noeqlines compress	nodepvars   nonotes   
 
	nois esttab     table1_HH table1_HH_us0  table1_HH_us1   table1_rural1 table1_rural1__us0  table1_rural1__us1 /// 
			        table1_rural0 table1_rural0__us0  table1_rural0__us1 ///
					, title("Table 1: Descriptive statistics")  ///
			       mtitle ( "ALL" "Non-migrant" "Migrant"  "RURAL" "Non-migrant" "Migrant"  "URBAN" "Non-migrant" "Migrant" ) ///
					 label  cells( `"mean( fmt(3) pattern(1 1 ) )"' ) ///
			     varwidth(30) nonumbers nogaps noeqlines compress	nodepvars   nonotes   

	*Table 3 
	
	nois esttab     table3_HH table3_us0  table3_us1   table3_rural1 table3_rural1__us0  table3_rural1__us1 /// 
			        table3_rural0 table3_rural0__us0  table3_rural0__us1 ///
					,title("Table 3: Migration and variations in co-residence choices") /// 
			        mtitle ( "ALL" "Non-migrant" "Migrant"  "RURAL" "Non-migrant" "Migrant"  "URBAN" "Non-migrant" "Migrant" ) ///
				  label replace cells( `"mean( fmt(3) pattern(1 1 ) )"' ) ///
			     varwidth(30) nonumbers nogaps noeqlines compress	nodepvars   nonotes   
	
	

	
	
*******************************
* TABLE 2 and TABLE A.3 
*******************************

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
	
	* Relation to the head
	foreach i in 1 2 3 4 5 10 11 13 14 15 16 17 18 19 20  {
		local l : label(rel_head_det) `i'
		di "`l'"
		g rel_head_det__`i' = rel_head_det ==`i' if rel_head_det !=.
		label variable rel_head_det__`i' "`l'"
		}
		*
	*Age, sex and eduction of 15+ 
	g age_adu = age if age >=15
	g female_adu= male==0 if age >=15
	g yedu_adu = yedu if age >=15
	 
	label var age_adu    "age (15+)"
	label var female_adu "female (15+)"
	label var yedu_adu   "years education(15+)"
	 
	 
	global vardesc  age_adu female_adu yedu_adu  rel_head_det__1 rel_head_det__2 rel_head_det__3 rel_head_det__10 ///
					rel_head_det__11 rel_head_det__13 rel_head_det__14 rel_head_det__15 rel_head_det__16 rel_head_det__17 ///
					rel_head_det__18 rel_head_det__19 rel_head_det__20 rel_head_det__5 rel_head_det__4 
	
	label var rel_head_det__1 "Head"
	label var rel_head_det__2 "Spouse"
	label var rel_head_det__3 "Son or Daughter"
	label var rel_head_det__10 "Parent"
	label var rel_head_det__11 "Sibling"
	label var rel_head_det__13 "Grandchild"
	label var rel_head_det__14 "Nephew or niece"
	label var rel_head_det__15  "Cousin"
	label var rel_head_det__16 "Spouse's parent"
	label var rel_head_det__17 "Sons's parent  in law"
	label var rel_head_det__18  "Son or daughter in law"
	label var rel_head_det__19 "Brother or sister in law"
	label var rel_head_det__20 "Other relative"
	label var rel_head_det__5 "Non relative"
	label var rel_head_det__4 "Domestic worker"
	
	*Initial, new, leaving and migrant members: 
	g initial = 1   if N_ENT==1 
	g joining  = 1  if newmember==1 & usmigrant_ever==0  
	g mig = 1       if usmigrant==1 & newmember_ever==0  
	g leaving  = 1  if leaving_noUS==1  &  usmigrant_ever==0   /*& newmember_ever==0 */ 
	
	eststo clear	 
	qui eststo  D1 : estpost tabstat  ${vardesc}   if initial==1  , statistics(n mean) columns(statistics) 	
	qui eststo  D2 : estpost tabstat  ${vardesc}   if joining==1  , statistics(n mean) columns(statistics) 	
	qui eststo  D3 : estpost tabstat  ${vardesc}   if leaving==1  , statistics(n mean) columns(statistics) 	
	qui eststo  D4 : estpost tabstat  ${vardesc}   if mig==1      , statistics(n mean) columns(statistics) 	 
	
	*duplicate obervations when invidual is both initial and leaving member (or migrant) 
	expand 2 if initial==1 & leaving==1 , gen (dupli_leaving)
	expand 2 if initial==1 & mig==1 , gen (dupli_mig) 
	tempvar d1 d2 d3 
	g `d1' =1        if initial ==1 & dupli_mig==0 & dupli_leaving==0
	replace `d1'=0   if joining==1  & dupli_mig==0 & dupli_leaving==0
	g `d2' = 1       if initial==1  & dupli_mig ==0 
	replace `d2'= 0  if  ( (initial !=1 & leaving ==1) | dupli_leaving ==1)  &  dupli_mig==0
	g `d3' = 1       if initial==1  & dupli_leaving ==0 
	replace `d3'= 0  if  ( (initial !=1 & mig==1) | dupli_mig ==1)  &  dupli_leaving==0
	qui eststo test_1 : estpost ttest  ${vardesc}   , by(`d1') 
	qui eststo test_2 : estpost ttest  ${vardesc}  , by(`d2') 
	qui eststo test_3 : estpost ttest  ${vardesc}  , by(`d3') 
	
	*TABLE 2
	nois esttab  D1 D2 D3 D4 test_1  test_2 test_3  ,replace  /// 
	title ("Table 2 : Initial, new, leaving and migrant members (all households)") label ///
	cells( `"mean( fmt(3) pattern(1 1 1 1 0 0 0   ) ) b( star fmt(3) pattern(0 0 0 0 1 1 1  ))"' ) ///
	mtitle( "present at s1" "new memb"  "leaving memb" "US mig"  "Diff (1)-(2)"  "Diff (1)-(3)"   "Diff (1)-(4)"  ) ///
	nonumbers nogaps noeqlines compress	nodepvars   nonotes   
	
	
	drop if dupli_mig==1  |  dupli_leaving==1
	drop dupli_mig dupli_leaving
	keep if HHusmig_allperiod==1  

	
	qui eststo  D1_us : estpost tabstat  ${vardesc}   if initial==1  , statistics(n mean) columns(statistics) 	
	qui eststo  D2_us : estpost tabstat  ${vardesc}   if joining==1  , statistics(n mean) columns(statistics) 	
	qui eststo  D3_us : estpost tabstat  ${vardesc}   if leaving==1  , statistics(n mean) columns(statistics) 	
	qui eststo  D4_us : estpost tabstat  ${vardesc}   if mig==1      , statistics(n mean) columns(statistics) 	 
	
	expand 2 if initial==1 & leaving==1 , gen (dupli_leaving)
	expand 2 if initial==1 & mig==1 , gen (dupli_mig) 
	tempvar d1 d2 d3 
	g `d1' =1        if initial ==1 & dupli_mig==0 & dupli_leaving==0
	replace `d1'=0   if joining==1  & dupli_mig==0 & dupli_leaving==0
	g `d2' = 1       if initial==1  & dupli_mig ==0 
	replace `d2'= 0  if  ( (initial !=1 & leaving ==1) | dupli_leaving ==1)  &  dupli_mig==0
	g `d3' = 1       if initial==1  & dupli_leaving ==0
	replace `d3'= 0  if  ( (initial !=1 & mig==1) | dupli_mig ==1)  &  dupli_leaving==0
	qui eststo test_1_us : estpost ttest  ${vardesc}   , by(`d1') 
	qui eststo test_2_us : estpost ttest  ${vardesc}  , by(`d2') 
	qui eststo test_3_us : estpost ttest  ${vardesc}  , by(`d3') 
	
	*TABLE A.3
	nois esttab  D1_us D2_us D3_us D4_us test_1_us  test_2_us test_3_us  ,replace ///
	title ("TABLE A.3 Characteristics of initial, new, leaving and migrant members (migrant households)") label ///
	cells( `"mean( fmt(3) pattern(1 1 1 1 0 0 0   ) ) b( star fmt(3) pattern(0 0 0 0 1 1 1  ))"' ) ///
	mtitle( "present at s1" "new memb"  "leaving memb" "US mig"  "Diff (1)-(2)"  "Diff (1)-(3)"   "Diff (1)-(4)"  ) ///
	nonumbers nogaps noeqlines compress	nodepvars   nonotes   




	
	
*******************************
* Table A.13: 
*******************************
	
	
	
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
	
	bys id_h  : g hh=  _n==1
		
	sort id_h 
	by id_h  : egen HH_remit_ever = max(receive_remittance)	
	by id_h  : egen HH_new_remit_ever = max(receive_remittance*(newmember_ever==1) )	
	by id_h: egen hh_tot_new =total( newmember)
	bys id_h: egen tot_leaving= total(leaving_noUS==1 ) 
	
	
	* Household migration status, type of members and direct receipt of remittances 
	
	* Household
	g  G1_h = HH_new_remit_ever ==1   & HHusmig_allperiod==0   & HHnewmember_returnUS_allperiod ==0  & hh==1 
	g  G2_h = HHusmig_allperiod ==1   & tot_leaving>0     & hh==1  
	g  G3_h =  HHnewmember_allperiod ==1 & HH_new_remit_ever ==0  & HHusmig_allperiod==0   & HHnewmember_returnUS_allperiod ==0   & hh==1  
	g Ga_h=  G1_h ==1 if G1_h ==1 |G2_h ==1
	g Gb_h=  G1_h ==1 if G1_h ==1 |G3_h ==1
	
		
	* Indidvidual 
	g  G1_i = HH_new_remit_ever ==1 & newmember==1  & HHusmig_allperiod==0   & HHnewmember_returnUS_allperiod ==0  
	g  G2_i = HHusmig_allperiod ==1  & leaving_noUS==1 
	g  G3_i =  HHnewmember_allperiod ==1 & HH_new_remit_ever ==0 & newmember==1   & HHusmig_allperiod==0   & HHnewmember_returnUS_allperiod ==0  
	g Ga_i=   G1_i ==1 if G1_i ==1 |G2_i ==1
	g Gb_i=  G1_i ==1 if G1_i ==1 |G3_i ==1
	

	* Household and individual characetritics 
	
	g age0_14= age<=14 
	g age60more= age>=60 
	g adu_fem= age >=15 & male==0
	g adu_mal= age >=15 & male==1	
	g female_adu= male==0 if  age >=15 
	g single_adu_male = marital_status==4 if age  >=15  & marital_status!=.  & male==1 
	g single_adu_fem = marital_status==4 if age  >=15  & marital_status!=.  & male==0 
	g age_adu_fem = age if male==0 & age >=15 
	g age_adu_mal = age if male==1 & age >=15 
	
	label var female_adu "female among adult "
	label var  age0_14 "children 0-14"
	label var age60more "adult 60 more"
	label var adu_fem  "adult female (>15)"
	label var age_adu_fem  "age of adu female (>15)"
	label var age_adu_mal   "age of adu male (>15)"
	label var single_adu_male  "single among male adult(>15)"
	label var single_adu_fem   "single among fem adult(>15)"
	
	
	bys id_h : egen HH_new_adufem = max( newmember*(adu_fem) )
	by id_h  : egen HH_new_age014 = max( newmember*(age0_14) )
	by id_h  : egen HH_new_age60more = max( newmember*(age60more ) )
	by id_h  : egen HH_leave_adufem = max( leaving_noUS*(adu_fem) ) 
	by id_h  : egen HH_leave_age014 = max( leaving_noUS*(age0_14) )
	by id_h  : egen HH_leave_age60more = max( leaving_noUS*(age60more) )
	
	g total_newleav = hh_tot_new 
	replace  total_newleav = tot_leaving  if  G2_h==1 	
	g two_memb_ormore = hh_tot_new >=2 
	replace two_memb_ormore = total_newleav>=2 if G2_h==1 
	
	g 		newleav_adufem = HH_new_adufem  
	replace newleav_adufem = HH_leave_adufem  if G2_h==1 
	g 		newleav_child  = HH_new_age014   
	replace newleav_child  = HH_leave_age014 if G2_h==1 
	g 		newleav_old    = HH_new_age60more  
	replace newleav_child  = HH_leave_age60more if G2_h==1 
	
	label var total_newleav "nb of members joining,leaving"
	label var two_memb_ormore "at least two members joining,leaving"
	label var  newleav_adufem "at least one adult fem joining,leaving"
	label var  newleav_child "at least one child joining, leaving"
	label var  newleav_old "at least one elder joining, leaving"
	
	
	global varliste_hh  total_newleav two_memb_ormore  newleav_adufem newleav_child newleav_old 
	global varliste    age0_14 age60more female_adu  age_adu_fem age_adu_mal  single_adu_male single_adu_fem 

	qui eststo  DEShh_1  : estpost tabstat  ${varliste_hh}   if  G1_h==1 , statistics(n mean  sd   ) columns(statistics) 	
	qui eststo  DEShh_2  : estpost tabstat  ${varliste_hh}   if  G2_h==1 , statistics(n mean  sd   ) columns(statistics) 	
	qui eststo  DEShh_3  : estpost tabstat  ${varliste_hh}   if  G3_h==1 , statistics(n mean  sd   ) columns(statistics) 	
	qui eststo  test1_hh : estpost ttest    ${varliste_hh}  , by(Ga_h) 
	qui eststo  test2_hh : estpost ttest    ${varliste_hh}  , by(Gb_h) 

	qui eststo DESC_1 : estpost tabstat  ${varliste}   if  G1_i==1 , statistics(n mean  sd   ) columns(statistics) 	
	qui eststo DESC_2 : estpost tabstat  ${varliste}   if  G2_i==1 , statistics(n mean  sd   ) columns(statistics) 	
	qui eststo DESC_3 : estpost tabstat  ${varliste}   if  G3_i==1 , statistics(n mean  sd   ) columns(statistics) 	
	qui eststo test1  : estpost ttest    ${varliste}  , by(Ga_i) 
	qui eststo test2  : estpost ttest    ${varliste}  , by(Gb_i) 

	
	*Table A.13 
	
	*Panel A
	nois esttab    DEShh_1 DEShh_2 DEShh_3 test1_hh  test2_hh , title("Table A.13: New and leaving members in migrant and non-migrant households") ///
					cells( `"mean( fmt(3) pattern(1 1 1 0 0 ) ) b( star fmt(3) pattern(0 0 0 1 1  )) "' ) ///
					mtitle("(1)" "(2)" "(3)"  "(2)-(1)"  "(3)-(1)" ) label varwidth(30) nonumbers nogaps noeqlines compress	nodepvars   nonotes   
	*Panel B
	nois esttab    DESC_1 DESC_2 DESC_3 test1 test2  ,  title("Table A.13: New and leaving members in migrant and non-migrant households") /// 
				   cells( `"mean( fmt(3) pattern(1 1 1 0 0 ) ) b( star fmt(3) pattern(0 0 0 1 1  )) "' ) ///
					mtitle("(1)" "(2)" "(3)"  "(2)-(1)"  "(3)-(1)" ) label varwidth(30) nonumbers nogaps noeqlines compress	nodepvars   nonotes   
	
		
	
	
