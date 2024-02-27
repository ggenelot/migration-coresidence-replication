








cd "/Volumes/Samsung_T5/ENOE_long/"

**************************************************************
* POINT 1: Import and assemble datasets 
**************************************************************
		
* COMBINE ALL DATASET IN ONE QUARTER INTO ONE DATASET (households-individuals-quarter) 

	matrix quarters = [105, 205, 305, 405, 106, 206, 306, 406 , 107, 207 ,307, 407   ]
	
	forvalues k  = 1/12 {
	
	    local q1 = string(quarters[1,`k'])
		local y1= "20"+substr("`q1'",2,3) 
		local t1= substr("`q1'",1,1) 
			
		use  "`y1'trim`t1'_dta/HOGT`q1'.dta", clear 
		
		merge 1:m  cd_a ent con v_sel  n_hog h_mud using  "`y1'trim`t1'_dta/SDEMT`q1'.dta"
		keep if _m==3
		drop _m
		
		merge 1:1  cd_a ent con v_sel  n_hog h_mud n_ren using "`y1'trim`t1'_dta/COE2T`q1'.dta"
		drop _m
	 
		foreach var of varlist * {
		local name = upper("`var'")
		qui rename `var' `name'  
		}
		*
	#delimit ;
	local masterlist "D_SEM CON CD_A ENT CON V_SEL  N_HOG H_MUD N_REN  MUN LOC  ENT N_PRO_VIV  N_REN FAC  N_ENT D_DIA D_MES PER T_LOC MUN 
				CD_A ENT SEX EDA NAC_DIA  NAC_MES NAC_ANIO C_RES L_NAC_C CS_AD_DES CS_AD_MOT  CS_NR_MOT  CS_NR_ORI 
				CS_P12 CS_P12 CS_P13_1 CS_P13_2 CS_P14_C CS_P15 CS_P16 CS_P17  N_HIJ PAR_C E_CON P10A1 P10A2 P10A3 P10A4" ;
	#delimit cr
	local keeplist = ""
	foreach i of local masterlist  {
		capture confirm variable `i'
			if !_rc {
					local keeplist "`keeplist' `i'"
				}
		}
	keep `keeplist' 
	foreach var of varlist * {	
	 qui tostring `var', replace force 
	 }
	 
	 save enoe_`q1', replace 
	}
	*
	
* PANEL STRUCTURE : FIRST TO FITH INTERVIEW 
	
	forvalues qq = 1/8 {
		
		local q1 = string(quarters[1,`qq'])
		local q2 = string(quarters[1,`qq'+1])
		local q3 = string(quarters[1,`qq'+2])
		local q4 = string(quarters[1,`qq'+3])
		local q5 = string(quarters[1,`qq'+4])
		
		tempfile temp1 temp2 temp3 temp4 temp5 
		
		use  enoe_`q1', clear 
		keep if real(N_ENT) == 1
		save `temp1' , replace
		
		use  enoe_`q2', clear 
		keep if  real(N_ENT) == 2
		save `temp2' , replace
		
		use  enoe_`q3', clear 
		keep if  real(N_ENT) == 3
		save `temp3' , replace
		
		use  enoe_`q4', clear 
		keep if  real(N_ENT) == 4
		save `temp4' , replace
		
		use  enoe_`q5', clear 
		keep if  real(N_ENT) == 5
		save `temp5' , replace
			
		append using `temp1' 
		append using `temp2' 	
		append using `temp3' 
		append using `temp4' 
		
		
		gen PAN= substr(D_SEM,1,1) 
		
		g id_h =  CD_A + "_" +  MUN + "_" + LOC +  "_" + ENT + "_" +  CON +  "_" + ///
				  N_PRO_VIV + "_" +  V_SEL + "_" +  N_HOG + "_" +  H_MUD  + "_" + PAN
		g id = id_h + "_" + N_REN 
		
		replace id_h = id_h +  "_" + "`q1'"
		replace id   = id   +  "_" + "`q1'"
		
		* Panel group defined by the quarter in which they first entered the survey
		g panel_group ="G`q1'"
	
		cap drop __*
	
		
		/* Information on absent members between q and q+1*/ 
		
		g C_RES_next = C_RES
	
		foreach v in C_RES_next  CS_AD_DES  CS_AD_MOT  {
			tempvar t
			sort id N_ENT 
			by id : g `t' = `v'[_n+1]
			replace `v' = `t'
			label var `v' "NEXT QUARTER `v' "
			}
		
	/* DROP absentee that leaves bewteen  q-1 and q and present in the data at q */ 
	
		drop if C_RES =="2" 
	
		
	/* YEAR , quarter, month, day of interview*/
	
		g year = substr(PER, 2, 3)
		g quarter = substr(PER, 1, 1)
		
		destring N_ENT D_DIA D_MES year quarter, replace
		
		replace year = 2000+ year 
		
	
	/* Location interview */ 
	 
		destring T_LOC, replace
		label def loca 1 "Localidades mayores de 100 000 habitantes" ///
					   2 "Localidades de 15 000 a 99 999 habitantes" ///
					   3 "Localidades de 2 500 a 14 999 habitantes" ///
					    4 "Localidades menores de 2 500 habitante"
		label values T_LOC loca			 
	 
			
	/* INDIV SOCIO DEMO  */ 
				
			
		* invariant socio-demo * 
		destring SEX EDA NAC_DIA  NAC_MES NAC_ANIO L_NAC_C  , replace
		foreach v in SEX  NAC_DIA  NAC_MES NAC_ANIO L_NAC_C {
			tempvar t t1
			bys id: egen `t' = mode( `v') , minmode 
			replace `v'= `t' 
		}
		*
				
		g age = EDA if EDA!= 98 & 	EDA!= 99 
		g age2= year - NAC_ANIO  if NAC_ANIO  !=9999
		replace age =age2 if age==.
		drop age2 
	
		g male= SEX==1 
			
	/*EDUCATION LEVEL*/ 	
			
		destring CS_P12 CS_P13* CS_P17 , replace
			
		label define edu 0  "Ninguno" 1 "Preescolar"2 "Primaria"3 "Secundaria" 4 "bachillerato" 5 "Normal" 6 "Carrera tÈcnica" 7 "Profesional" 8 "MaestrÌa"9 "Doctorado"
		g literate=  CS_P12==1
			
		g edu_level= CS_P13_1 if CS_P13_1!=99
		label values edu_level edu 
		g grade = CS_P13_2 
		replace grade=min(grade,6) if grade!=.
		g attend_school = CS_P17 if  CS_P17!=9
		
		g yedu=. 
		replace yedu=0 if edu_level ==0 | edu_level ==1 
		replace yedu= grade if edu_level==2    	  /* elementary: 6 grades max */
		replace yedu = 6 + grade if edu_level==3   	 /* secondary : 3 grades max */
		replace yedu=  9 + grade if edu_level==4 	 /*high school general*/
		replace yedu=  9 + grade if edu_level==6 	 /*high school technica*/
		replace yedu=  12 + grade if edu_level==5 	 /*college normal*/
		replace yedu=  12 + grade if edu_level==7 	 /*college professional */
		replace yedu=  17 + grade if edu_level==8 |  edu_level==9	 /*master and doctorant */
				
		* RELATION TO THE HEAD, MARITAL STATUS * 
		
		 g rel_head =substr(PAR_C,1,1)
		 destring rel_head,replace	
		 replace rel_head= 5  if rel_head==7 | rel_head==6 
		 label def rela 1 " head" 2 "spouse" 3 "sons" 4 "worker domes" 5 "others",replace
		 label values rel_head rela
			
		
			
		g rel_head_det = rel_head if rel_head<=4 
		replace rel_head_det = 5 if substr(PAR_C,1,1)=="5" /*NO PARIENTE DEL JEFE*/
		
		*parents or grand-parents (or uncles or step-parents)
		replace	rel_head_det=10	if PAR_C=="601" 
		replace	rel_head_det=10	if PAR_C=="602"
		replace	rel_head_det=10	if PAR_C=="611"
		replace	rel_head_det=10	if PAR_C=="605"
		replace	rel_head_det=10	if PAR_C=="606"
		replace	rel_head_det=10	if PAR_C=="607"
		*brothers & sister
		replace	rel_head_det=11	if PAR_C=="603"
		replace	rel_head_det=11	if PAR_C=="604"
		*grand-sons (or grand-grand-dons)
		replace	rel_head_det=13	if PAR_C=="608" 
		replace	rel_head_det=13	if PAR_C=="609"
		replace	rel_head_det=13	if PAR_C=="610"
		*nephews
		replace	rel_head_det=14	if PAR_C=="612"
		*cousin
		replace	rel_head_det=15	if PAR_C=="613"
		*spouse's parent (parents in law)
		replace	rel_head_det=16	if PAR_C=="614"
		*sons's parent in law 
		replace	rel_head_det=17	if PAR_C=="615"
		*son or dauther in law 
		replace	rel_head_det=18	if PAR_C=="616"
		*brother in law (or spouse of brother in law)
		replace	rel_head_det=19	if PAR_C=="617"
		replace	rel_head_det=19	if PAR_C=="618"
	
		replace	rel_head_det=20	if PAR_C!="" & rel_head_det==.
		
		#delimit ; 
		label define parentesco_d
		1 " head" 2 "spouse" 3 "sons" 4 "worker domes" 5 "no parent of jefe"
		10	"parents,grand-parents or uncle" 
		11	"siblings"
		13	"grand-son"
		14	"nephew"
		15 "cousin"
		16 "spouse's parent" 
		17 "sons's parent " 
		18 "son or dauther in law" 
		19 "brother in law (or sibling of spouse)" 
		20 "other" , replace
		; 
		#delimit cr
		
		label values rel_head_det parentesco_d  
		
		* Marital status 
		
		destring E_CON, replace
		g marital_status = 1 if E_CON ==1 | E_CON ==5 
		replace marital_status =2 if E_CON ==2  | E_CON ==3
		replace marital_status =3 if E_CON ==4
		replace marital_status =4 if E_CON ==6
		label def mari 1 "married" 2 "separated" 3" widow" 4"single" 
		label values marital_status mari 		
	
	

***  PLACE OF RESIDENCE ****

		cap drop _*
		destring ENT, replace
	
		#delimit ; 	
	 label define states
	1		"Aguascalientes"
	2		"Baja California"
	3		"Baja California Sur"
	4		"Campeche"
	5		"Coahuila de Zaragoza"
	6		"Colima"
	7		"Chiapas"
	8		"Chihuahua"
	9		"Distrito Federal"
	10		"Durango"
	11		"Guanajuato"
	12		"Guerrero"
	13		"Hidalgo"
	14		"Jalisco"
	15		"México"
	16		"Michoacán de Ocampo"
	17		"Morelos"
	18		"Nayarit"
	19		"Nuevo León"
	20		"Oaxaca"
	21		"Puebla"
	22		"Querétaro"
	23		"Quintana Roo"
	24		"San Luís Potosí"
	25		"Sinaloa"
	26		"Sonora"
	27		"Tabasco"
	28		"Tamaulipas"
	29		"Tlaxcala"
	30		"Veracruz de Ignacio de la Llave"
	31		"Yucatán"
	32		"Zacatecas", replace ;

	label values ENT states ;	
	#delimit cr

	save "JDE_data/SOCIO_PANEL_`q1'.dta", replace 
		}
		*
		*
		
		
* PANEL STRUCTURE : BUILD DATA	
		

	local i =1 
	
	foreach q1 in 105 205 305 405 106 206 306 406 {
	
		use "JDE_data/SOCIO_PANEL_`q1'.dta",clear
	if `i'==1 {
	save "JDE_data/panel_enoe0507.dta" , replace
	}
	else{
	append using "JDE_data/panel_enoe0507.dta" 
	save "JDE_data/panel_enoe0507.dta"  , replace
	}
	
	local i= `i' +1 
	     
	
	}
	*

	
		
		

**************************************************************
* POINT 2: Building final dataset
**************************************************************
		

cd "/Volumes/Samsung_T5/ENOE_long/JDE_data"
	
use panel_enoe0507, clear 	

		  
	* Numeric identifiers for speed processing 
	
	g id_h_original= id_h
	g id_original = id
	drop id_h
	drop id
	egen id_h= group(id_h_original)
	egen id = group(id_original)
		
	 *birthyear 	 
	g birthyear= NAC_ANIO 
	replace birthyear = year - age if NAC_ANIO ==9999
		
		
**** SAMPLE   *******
	
	* Keep only HH with successfull interviews at first visit 
	
	bys id_h: egen min_HH_ent= min(N_ENT)  
	keep if min_HH_ent==1
	
	* keep households with all non-missing birth year
	
	bys id_h: egen e= max( birthyear ==. )
	drop if e== 1 /* 3700 households*/
	drop e
 	g time= year+ quarter /10 
		
	* 
	drop if rel_head==9 /* = 1 observation*/ 
	
	 
	bys id_h: egen max_HH_ent= max(N_ENT) 
	
	* some households are present at the 1st and 5th interview, but NOT at the 2nd, 3rd or 4th
	
	foreach i in 1 2 3 4 5 {
	bys id_h: egen hh_interview`i' = max( N_ENT==`i' ) 
	}
	egen present_N_ENT_1234= rowmin( hh_interview1  hh_interview2 hh_interview3 hh_interview4 )
	egen present_N_ENT_12345= rowmin( hh_interview1  hh_interview2 hh_interview3 hh_interview4 hh_interview5 )
	



**** CORRECTION OF INDIVIDUALS IDENTIFIERS 

		* construct individual ID based on household id_h, sex, birthday
		* adjust ENOE individual ID when new member was present in the roster before joining 
		
		egen ID_ind = group(id_h SEX birthyear NAC_MES NAC_DIA )
		
		bys ID_ind: egen  minENT = min( N_ENT)
		bys ID_ind: egen  new_ever = max(  C_RES== "3" )
		tempvar t t2 t3
		g `t'= N_ENT if C_RES== "3"
		bys ID_ind: egen  date_arrive= min(  `t' )
		g `t3' = id if N_ENT==minENT 
		bys ID_ind: egen trueid = max(`t3')

		replace id= trueid if new_ever ==1 & (  date_arrive> minENT )  &  date_arrive!=.
		
		drop  minENT  new_ever date_arrive trueid
		
		
		
	
*** 	MIGRATION from q to q +1  ***		
		
		
	/* Define MIGRANTS */
		
		destring CS_AD_DES  CS_NR_ORI, replace
		label values  CS_AD_DES geo 
		label values  CS_NR_ORI geo 
	
	
		g  usmigrant     =  CS_AD_DES ==3
		g  mexmigrant    =  CS_AD_DES ==2  /*other State */ 
		g munipmigrant =  C_RES_next=="2" & CS_AD_DES ==1  /*same State */ 
		
		label define geo 1 "same state" 2 "other state" 3 "other country", replace
		g typemig=0
		replace typemig= 1 if  munipmigrant ==1 
		replace typemig= 2 if  mexmigrant ==1 
		replace typemig= 3 if  usmigrant ==1
		label def typ 0 "no mig" 1 "mig same state" 2 "mig other state" 3 "U.S."
		label values  typemig typ
		
	  *  Household with max age of US migrant is below 13 in the entire period
		tempvar t 
		g `t' = age if CS_AD_DES ==3
		bys id_h : egen maxage_us= max(`t')
		g hh_US_maxage_13 = 1 if  maxage_us<14 & maxage_us!=. 
		
		*** Sample selection : drop US-migrant sending housholds with no migrant older than 13  
		drop if  hh_US_maxage_13 ==1 
		drop hh_US_maxage_13  /* there are 85 households */
		
		
	    * Household migration status 
		bys id_h PER : egen HHusmig = max( usmigrant)
		bys id_h PER : egen HHmexmig  = max( mexmigrant)
		bys id_h : egen HHusmig_allperiod = max( HHusmig )
		bys id_h  : egen HHmexmig_allperiod = max( HHmexmig )
		bys id_h  : egen HHoutmig_allperiod = max( (munipmigrant==1|  mexmigrant==1 ))
		
		* US migrant individual 
		bys id: egen usmigrant_ever= max(usmigrant) 
		
		* Mex migrant individual 
		bys id: egen mexmigrant_ever= max(mexmigrant) 
		bys id: egen outmig_ever= max( typemig!= 0)
		bys id: egen max_indiv_ent= max(N_ENT) 


/* DYNAMIC US  MIGRATION TREATMENT */ 
		
		g HH_us_before = .  
		foreach q in  2 3 4 5 {
		tempvar t t2
		g `t' = HHusmig  if N_ENT < `q'
		bys id_h : egen `t2' = max(`t')
		replace HH_us_before=  `t2' if N_ENT == `q'

		}
		*
		
		* no  migrant before first interview by definition
		replace HH_us_before= 0 if N_ENT ==1

	
		bys id_h PER : egen HHusmig_fem = max( usmigrant==1 & male==0 )
		bys id_h : egen HHusmig_fem_allperiod = max( HHusmig_fem)

		g HH_us_female_before = .  
		foreach q in  2 3 4 5 {
		tempvar t t2 
		g `t' = HHusmig_fem  if N_ENT < `q'
		bys id_h : egen `t2' = max(`t')
		replace HH_us_female_before=  `t2' if N_ENT == `q'
		}
		replace HH_us_female_before= 0 if N_ENT ==1
	
		label var HH_us_before   "US mig before" 
		label var HH_us_female_before "US mig female before"		
		label var   HHusmig_allperiod  "U.S mig"
		label var  HHusmig_fem_allperiod "U.S.mig female"
		
				
		foreach q in 1 2 3 4  {
			local j = `q' +1
			tempvar t
			g `t' = HHusmig if N_ENT==`q'
			bys id_h  : egen  HHUSMIG_N`j'= max(`t')
		}
		
		*	
		g HHusmig_simul= 0 
		g HHusmig_befq1= 0 
		g HHusmig_befq2= 0
		g HHusmig_befq3= 0 
		g HHusmig_aftq1= 0 
		g HHusmig_aftq2= 0
		g HHusmig_aftq3= 0 
		
		foreach q in  2 3 4 5 {
		replace HHusmig_simul =  HHUSMIG_N`q' if N_ENT==`q'
		}	
		foreach q in 3 4 5 {
		local j = `q'-1
		replace HHusmig_befq1 =  HHUSMIG_N`j' if N_ENT==`q'
		}
		foreach q in 4 5 {
		local j = `q'-2
		replace HHusmig_befq2 =  HHUSMIG_N`j' if N_ENT==`q'
		}
		foreach q in  5 {
		local j = `q'-3
		replace HHusmig_befq3 =  HHUSMIG_N`j' if N_ENT==`q'
		}
		foreach q in  2 3 4 {
		local k = `q'+1
		replace HHusmig_aftq1 =  HHUSMIG_N`k' if N_ENT==`q'
		}
		foreach q in  2 3  {
		local k = `q'+ 2
		replace HHusmig_aftq2 =  HHUSMIG_N`k' if N_ENT==`q'
		}
		foreach q in  2 {
		local k = `q'+ 3
		replace HHusmig_aftq3 =  HHUSMIG_N`k' if N_ENT==`q'
		}
		*
		label var HHusmig_simul "US mig same quarter"
		label var HHusmig_befq1 "US mig 1 quarter before"
		label var HHusmig_befq2 "US mig 2 quarter before"
		label var HHusmig_befq3 "US mig 3 quarter before"
		label var HHusmig_aftq1 "US mig 1 quarter after"
		label var HHusmig_aftq2 "US mig 2 quarter after"
		label var HHusmig_aftq3 "US mig 3 quarter after"
	
	
		
/* DYNAMIC MEXICAN INTERNAL MIGRATION TREATMENT */ 
		
		g HH_mex_before = .  
		foreach q in  2 3 4 5 {
		tempvar t t2
		g `t' = HHmexmig  if N_ENT < `q'
		bys id_h : egen `t2' = max(`t')
		replace HH_mex_before=  `t2' if N_ENT == `q'
		}
		replace  HH_mex_before= 0 if N_ENT ==1

	
		bys id_h PER : egen HHmexmig_fem = max( mexmigrant==1 & male==0 )
		bys id_h : egen HHmexmig_fem_allperiod = max( HHmexmig_fem)

		g HH_mex_female_before = .  
		foreach q in  2 3 4 5 {
		tempvar t t2 
		g `t' = HHmexmig_fem  if N_ENT < `q'
		bys id_h : egen `t2' = max(`t')
		replace HH_mex_female_before=  `t2' if N_ENT == `q'
		}
		replace HH_mex_female_before= 0 if N_ENT ==1
	
		
		label var HH_mex_female_before "Mex mig female before"		
		label var   HHmexmig_allperiod  "Mex mig"
		label var  HHmexmig_fem_allperiod "Mex mig female"
		
			
*** NEW MEMBER ARRIVING IN HOUSEHOLD 
		
		
		* NEW MEMBERS 
		 g newmember =  C_RES== "3" 
		 
		*Excluding domestic servants
		 replace newmember= 0 if rel_head==4
		 
		 *Exclude newborne babies
		 replace newmember= 0 if CS_NR_MOT=="8"
		 *Exclude individuals that were omitted in previous wave
		 replace newmember= 0 if CS_NR_MOT=="9"
		
		* Exclude new members if they  migrate to the U.S. AFTER  joining the household
		* Exclude new members if they migrate to the U.S.  BEFORE  joining the household
		
		 replace newmember= 0 if  usmigrant_ever==1
		
		** RETURNEES U.S. migrants  
			 
		 g newmember_noUS= newmemb
		 replace newmember_noUS= 0 if CS_NR_ORI==3 
			
		bys id_h PER : egen HHnewmember = max(newmember)
		bys id_h : egen HHnewmember_allperiod = max(HHnewmember)

		bys id_h PER : egen HHnewmember_noUS = max(newmember_noUS)
		bys id_h : egen HHnewmember_noUS_allperiod = max(HHnewmember_noUS)
		
		g HHnewmember_returnUS_allperiod =	HHnewmember_allperiod==1 & HHnewmember_noUS_allperiod ==0
	
	
		* Define new member excluding MexMigrant and all moving persons
		
		tempvar new_nomex_mig 
		g `new_nomex_mig'=  newmember==1 & mexmigrant_ever==0
		bys id_h: egen HHnewmemb_nomexmig_allperiod = max(`new_nomex_mig') 
		
		tempvar new_noallleave 
		g `new_noallleave' =  newmember==1 & outmig_ever==0 
		bys id_h: egen HHnewmemb_noleaving_allperiod=  max( `new_noallleave') 
		
		
		* Define new member from same State - or from of other state 
		
		bys id_h : egen HHnewmem_sameSTATE_allperiod = max(newmember==1 & CS_NR_ORI==1 )
		bys id_h : egen HHnewmem_otherSTATE_allperiod = max(newmember==1 & CS_NR_ORI==2 )
	
	

****** NEW MEMBERS - DYNAMIC  TREATMENT ****  

	foreach y in HHnewmember   {
	foreach q in 1 2 3 4 5 {
		tempvar t`q'
		g `t`q''= `y'  if N_ENT==`q'
		bys id_h  : egen `y'_N`q'= max(`t`q'')
	}
	}
	*	
	g HH_newmemb_before = .

	foreach q in  2 3 4 5 {
			tempvar t t2
			g `t' =  HHnewmember if N_ENT <= `q'
			bys id_h : egen `t2' = max(`t')
			replace HH_newmemb_before=  `t2' if N_ENT == `q'	
		}
		*	
	    replace HH_newmemb_before= 0 if N_ENT ==1

		
		label var     HH_newmemb_before  "New member before"
		g HHnewmember_simul=0
		g HHnewmember_befq1  =0
		g HHnewmember_befq2 =0
		g HHnewmember_befq3  =0
		
		foreach q in  2 3 4 5 {
		replace HHnewmember_simul =  HHnewmember_N`q'  if N_ENT==`q'
		}	
		foreach q in 3 4 5 {
		local j = `q'-1
		replace  HHnewmember_befq1 =  HHnewmember_N`j' if N_ENT==`q'
		}	
		foreach q in 4 5 {
		local j = `q'-2
		replace  HHnewmember_befq2 =   HHnewmember_N`j' if N_ENT==`q'
		}
		foreach q in  5 {
		local j = `q'-3
		replace HHnewmember_befq3 =   HHnewmember_N`j' if N_ENT==`q'
		}
		
		
		label var HHnewmember_simul "New member same quarter"
		label var HHnewmember_befq1 "New member 1 quarter before"
		label var HHnewmember_befq2 "New member 2 quarter before"
		label var HHnewmember_befq3 "New member 3 quarter before"
	

	
*** LEAVING FAMILY MEMBERS WHO ARE NOT US. MIGRANT 
		
		
		*Define movers leaving the household as those who are not U.S. migrant 
		* exclude domestic workers
		* exclude death
		
		g leaving_noUS = C_RES_next=="2"   & CS_AD_DES !=3  & usmigrant==0 ///
						 & rel_head!=4 	&  CS_AD_MOT!= "8"
				
		bys id_h PER : egen HH_OUTleave = max( leaving_noUS )
		bys id_h: egen HH_OUTleave_allperiod= max(leaving_noUS)
	
		
		* Define leaving within same State - or from of other state 
			
		bys id_h: egen HH_leaving_sameSTATE_allperiod= max(leaving_noUS==1 & CS_AD_DES==1 )
		bys id_h: egen HH_leaving_otherSTATE_allperiod= max(leaving_noUS==1 & CS_AD_DES==2 )
	
			
		  
* MULTIPLE US MIG SPELL OR NEW MEMBER PER HOUSEHOLDS
		cap drop hhper	
		bys id_h PER : g hhper = _n==1
		bys id_h: egen totspell_HHnew =total(  HHnewmember & hhper==1)
	
*MULTIPLE MEMBERS JOINING OR LEAVING 
		
		bys id_h : egen HHnb_newmem_allperiod =total( newmember)
		bys id_h : egen HHnb_leave_allperiod = total( leaving_noUS )
		bys id_h : egen HHnb_usmig_allperiod =total( usmigrant)
		

		
	
*** Remittances and transfers ***

	
		g receive_remittance= P10A1== "1" if (P10A1== "1"| P10A2== "2"  | P10A3== "3" | P10A4== "4")  
		g receive_transfer_mex =( P10A2== "2"  | P10A3== "3" ) if  (P10A1== "1"| P10A2== "2"  | P10A3== "3" | P10A4== "4")  
		
		label var  receive_transfer_mex "receive or send transfers in Mexico"
		label var receive_remittance  "receive or send US remittances"
		
		bys id_h PER : egen HH_remittances = max(receive_remittance)
		bys id_h PER : egen HH_transter_mex = max(receive_transfer_mex)
		

	   
**** OUTCOME REMITTANCES PLACEBOS
	
	bys id_h PER : egen HH_remittances_no_newmember = max(receive_remittance*(newmember==0) )
		
	bys id : egen newmember_ever = max(newmember)
	tempvar t 
	g `t'= N_ENT if newmember==1
	bys id : egen minENTnew= min( `t')
	
	tempvar tnew 
	g tnew = newmember_ever* ( N_ENT>=minENTnew) 
	bys id_h PER : egen HH_remittances_newmember = max(receive_remittance*(newmember_ever==1) )	
	bys id_h PER : egen HH_remittances_no_newever = max(receive_remittance*(newmember_ever==0) )
	bys id_h PER : egen HH_remittances_no_newever2 = max(receive_remittance*(tnew ==0) )
	
    label var  HH_remittances_no_newever2  "HH receive remittances (excluding new members)"
	label var  HH_remittances_no_newever  "HH receive remittances (excluding new members)"
		
			
	**** REMITTANCES - DYNAMIC  OUTCOME  **** 
	
		bys id_h: egen HH_remit_allperiod= max(  HH_remittances) 
		
		foreach y in HH_remittances HH_transter_mex {
		foreach q in 1 2 3 4 5 {
			tempvar t`q'
			g `t`q''= `y'  if N_ENT==`q'
			bys id_h  : egen `y'_N`q'= max(`t`q'')
		}
		}
	*


*********************************************  
/* Household characteritics */ 
*********************************************


	* RURAL AREA :  "Localidades de 2 500 a 14 999 habitantes or menores de 2 500 habitante"
		g ruralarea      = T_LOC == 4 | T_LOC == 3 
		tempvar t
		g `t'= ruralarea if N_ENT==1
		bys id_h : egen rurper1 = max(`t')

	* correction of relation to head: BROTHER IN LAW & SON IN LAW
		*some brother in law are too young relative to head and are actually son in law
		*replace brother in law with son in law if difference age too big
		
		tempvar t 
		g `t'= age if rel_head==1 
		bys id_h PER : egen agehead= max(`t')
		g diage= age- agehead 
		su diage if rel_head_det==19 ,d
	
		replace rel_head_det =18 if rel_head_det==19 & diage <= -28 & diage!=. 
		
	*correction of  nephew & cousin 
		*replace cousin with nephew in law if difference age too big
		replace rel_head_det =14 if rel_head_det==15 & diage <= -28 & diage!=. 
		
		drop diage
		
		
		destring ENT, gen(state) 			
		bys id_h PER : egen hhsize =total(1)
		bys id_h PER : egen nb_child5 =total( age<=5)  
		bys id_h PER : egen nb_child614=total( age>=6 & age<=14 )  
		bys id_h PER : egen nb_adu=total( age>=14 ) 
		bys id_h PER : egen nb_65plus =total( age>=66)  
		bys id_h PER :egen hh_maxyedu = max( yedu) 
		
		bys id_h : egen hhsize_q1 = max(hhsize*(N_ENT==1) )
		bys id_h : egen nbchild_q1 = max((nb_child5+ nb_child614) *(N_ENT==1) )
		bys id_h : egen nbold_q1 =max((nb_65plus) *(N_ENT==1) ) 
		bys id_h : egen hhmaxedu_q1 =max( hh_maxyedu  *(N_ENT==1) ) 
		bys id_h  :egen nb_adu_q1=total( age>=14 *(N_ENT==1) )  
		
		* Three generation households
		
		bys id_h PER : egen minage= min( age)
		bys id_h PER :egen maxage= max( age)
		g di_run = age- minage if age!=maxage & age!=minage
		bys id_h PER : egen maxDIage= max(  di_run)
		g c1= maxage - minage>=50   if maxage!=. & minage!=.
		g c2= maxDIage>=25 if maxDIage!=.
		g three_gen=  c1==1 & c2==1	
	
		* def: (parents or grand-son) & and (son or son-in law or nephew)
		bys id_h PER : egen p1= max( rel_head_det==10|rel_head_det==   13 | rel_head_det== 16)
		bys id_h PER :egen s1= max( rel_head_det== 3| rel_head_det==  18 |rel_head_det== 14) 
		g three_gen_v2=  p1==1 & s1==1	
		
		drop p1 s1 c1 c2 maxage  maxDIage  di_run minage
		
		cap drop __*

		
****   Demograhic composition controls FIRST INTERVIEW  

 	replace hhmaxedu_q1 = min(hhmaxedu_q1 , 17) 
	replace  hhmaxedu_q1= 0 if  inrange( hhmaxedu_q1,0,6)
	replace  hhmaxedu_q1= 1 if  inrange( hhmaxedu_q1,7,9)
	replace  hhmaxedu_q1= 2 if  inrange( hhmaxedu_q1,10,12)
	replace  hhmaxedu_q1= 3 if  inrange( hhmaxedu_q1,13,16)
	replace  hhmaxedu_q1= 4 if  inrange( hhmaxedu_q1,17,17)
	
	*nuclear household
	g nuc_mem= inlist(rel_head,1,2,3)
	bys id_h PER : egen nuclear_household = min(nuc_mem )
	bys id_h : egen hhnuclear_q1 = max( nuclear_household *(N_ENT==1))
	
	** detailed demographics 	
	qui gen agroup=.
    local Ncohorts = ((70/5)+1)
         forval x = 1/`Ncohorts' {
				replace agroup=`x' if age >=5*(`x'-1) & age <= ((5*`x')-1)
				if `x'==`Ncohorts' {
				replace agroup=`x' if age > 5*(`x'-1) & age != .
				}		
		}
	*
	
	local Ncohorts = ((70/5)+1)
         forval x = 1/`Ncohorts' {	
		
		local a0 = 5*(`x'-1)
		local a1 = 5*`x'-1
		
		bys id_h : egen nbq1_male_`a0'_`a1' = total( (agroup==`x')*(male==1)*(N_ENT==1) )
	    bys id_h : egen nbq1_fem_`a0'_`a1' = total( (agroup==`x')*(male==0)*(N_ENT==1) )
	
	label var nbq1_fem_`a0'_`a1' "nb fem `a0' - `a1'"
	label var nbq1_male_`a0'_`a1'  "nb male `a0' - `a1'"	
	}
    *
	
	*Bilateral relationship migrant and new members
	
	do "/Users/eliemurard/Dropbox/ENOE Bertoli_Murard/dofiles Bertoli Murard/bilateral relationships.do"

	* SPOUSE PRESENT OR NOT 
	
	sort  id_h PER 
	foreach i in 1 2 3   10  11   16  18  19 {
			cap drop HH_reldet__`i'_m 
			cap drop HH_reldet__`i'_f
			by id_h PER : egen  HH_reldet__`i'_m  = max( rel_head_det ==`i' & male==1 ) 
			by id_h PER : egen  HH_reldet__`i'_f  = max( rel_head_det ==`i' & male==0 ) 
			
		}
		*
	capture drop spouse_present
	gen spouse_present =0 
	replace  spouse_present = 1 if  rel_head_det==2 &  HH_reldet__1_m==1 & male==0 /*head -spouse*/
	replace  spouse_present = 1 if  rel_head_det==2 &  HH_reldet__1_f==1 & male==1
	replace  spouse_present = 1 if  rel_head_det==1 &  HH_reldet__2_m==1 & male==0 /*head -spouse*/
	replace  spouse_present = 1 if  rel_head_det==1 &  HH_reldet__2_f==1 & male==1 /*head -spouse*/
	replace  spouse_present = 1 if  rel_head_det==3 &  HH_reldet__18_m==1 & male==0 /*sons- sons in law*/
	replace  spouse_present = 1 if  rel_head_det==3 &  HH_reldet__18_f==1 & male==1
	replace  spouse_present = 1 if  rel_head_det==10 &  HH_reldet__10_m==1 & male==0 /*parents of the head*/
	replace  spouse_present = 1 if  rel_head_det==10 &  HH_reldet__10_f==1 & male==1
	replace  spouse_present = 1 if  rel_head_det==11 &  HH_reldet__19_m==1 & male==0 /*siblings and brother in law*/
	replace  spouse_present = 1 if  rel_head_det==11 &  HH_reldet__19_f==1 & male==1
	replace  spouse_present = 1 if  rel_head_det==16 &  HH_reldet__16_m==1 & male==0 /*parents of the spouse of the head*/
	replace  spouse_present = 1 if  rel_head_det==16 &  HH_reldet__16_f==1 & male==1
	replace  spouse_present = 1 if  rel_head_det==18 &  HH_reldet__3_m==1 & male==0 /*sons- sons in law*/
	replace  spouse_present = 1 if  rel_head_det==18 &  HH_reldet__3_f==1 & male==1
	replace  spouse_present = 1 if  rel_head_det==19 &  HH_reldet__11_m==1 & male==0 /*siblings and brother in law*/
	replace  spouse_present = 1 if  rel_head_det==19 &  HH_reldet__11_f==1 & male==1
	replace  spouse_present = 0 if  marital_status==4 /*single*/

	

		

****    Include 2000 census municipal US emigration rate 

	destring MUN, gen(cve_mun) force 
	g cve_ent= EN

	merge m:1 cve_ent cve_mun using  "/Users/eliemurard/Dropbox/ENOE Bertoli_Murard/census 2000/mydata/CENSUS2000_MUNIP_MIGRUS.dta" 
	drop if _m==2
	drop _m

 
 egen stockUS_2000= rsum( migUS_male1535 migUS_female1535 migUS_male36more migUS_female36more)
 egen Popcensus2000= rsum(male1535_95 female1535_95 male36more_95 female36more_95 )
 
 foreach v in migUS_male1535 migUS_female1535 migUS_male36more migUS_female36more male1535_95 female1535_95 male36more_95 female36more_95  {
 rename  `v' census2000_`v'
 }
 g rateUS_2000= 100* ( stockUS_2000)/ Popcensus2000
 
 
 
 
 ** Drop observations of households at interviews s that drop out of the sample before s and then reappear in interview s 
	* (We consider these exiting-reentering households as attriters)
 	
 	g toberemove = 0 
	replace toberemove= 1 if hh_interview2==0 & N_ENT>=2 
	replace toberemove= 1 if hh_interview3==0 & N_ENT>=3 
	replace toberemove= 1 if hh_interview4==0 & N_ENT>=4 
	replace toberemove= 1 if hh_interview5==0 & N_ENT>=5 
	
	drop if toberemove ==1
	drop toberemove  
	
 
 save final_ready_data_JDE, replace
 
 
 ****  Create 8 files corresponding to 8 panel group of households that are defined
 *	   by the quarter in which they first entered the survey

matrix ENOE_enter= [105, 205, 305, 405, 106, 206, 306, 406]
    
	forvalues k  = 1/8 {
	    local q1 = string(ENOE_enter[1,`k'])
		
	use final_ready_data_JDE, clear
		 
	keep if  panel_group =="G`q1'"
	save final_data_panel_`q1', replace
		
		}
		*

		
		
  

	
 
