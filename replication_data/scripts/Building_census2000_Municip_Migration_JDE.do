



	cd "/Volumes/Samsung_T5/ENOE_long/JDE_data"
	
	

foreach entidad in  1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 {
		
		
/* POINT 1: COUNT MIGRANTS AND THEIR MUNICIPALITY OF ORIGIN IN  1995 */ 
	
			
		/* POINT 1 A : LOCATION OF SENDING HOUSEHOLD IN 1995 */  
		 
			use PER_F`entidad'.dta, clear

			drop if   res95edo_c==999  | res95edo_c==.    /* drop less than 5 five years old*/ 
			drop if   mun95otr_c ==999 | mun95otr_c ==.
			 
			foreach v of varlist  ent mun loc upm   numviv  numhog {
			tostring `v', replace
			}
			 
			g id_h = ent + "_" +  mun + "_" + loc + "_" + upm + "_" +  numviv + "_" +  numhog
			/*       Entidad federativa , Municipio, Localidad, N˙mero de vivienda , N˙mero de hogar */
			
			tostring otropare_c, replace
			
			g state = res95edo_c  if otropare_c=="100" | otropare_c=="200" | otropare_c=="300" /* Residence of family of migrant */ 
			g state2=  res95edo_c if otropare_c=="100" 
			bys id_h : egen hhent95  = mode( state )
			bys id_h : egen hhent95_2 = mode( state2 )
			replace hhent95 = hhent95_2  if hhent95==.
			drop state state2  hhent95_2
			
			g muni = mun95otr_c if otropare_c=="100" | otropare_c=="200" | otropare_c=="300"
			g muni2=  mun95otr_c if otropare_c=="100" 
			bys id_h : egen hhmuni95 = mode( muni )
			bys id_h : egen hhmuni95_2 = mode( muni2 )
			replace hhmuni95 = hhmuni95_2  if hhmuni95==.
			drop  muni muni2 hhmuni95_2
			
			bys id_h: keep if _n==1 
			keep id_h   hhent95 hhmuni95

			sort id_h 

			save hhloc95, replace

	/* POINT 1 B : COUNT MIGRANTS BY FAMILY'S MUNICIPALITY OF ORIGIN IN 1995  */  
	
	
		clear 
		use min_F`entidad'.dta, clear

			foreach v of varlist  ent mun loc upm   numviv  numhog {
			tostring `v', replace
			}
	 
			g id_h = ent + "_" +  mun + "_" + loc + "_" + upm + "_" +  numviv + "_" +  numhog
			
			sort id_h
			merge m:1 id_h using hhloc95 
			drop if _m==2 
			
			rename hhent95  ent95
			rename hhmuni95 muni95
			
			destring  msexo ,replace
			destring medad, replace
			
			g migUS =  mpdesotr_c  ==221 /* MIGRANTS TO THE USA*/ 
			
			g migUS_male1535     =  migUS==1 &  msexo==1  & medad >14 &  medad<36  &  medad!=999
			g migUS_female1535   =  migUS==1 &  msexo==2  & medad >14 &  medad<36  &   medad!=999
			g migUS_male36more   =  migUS==1 &  msexo==1 & medad >35 &     medad!=999
			g migUS_female36more =  migUS==1 &  msexo==2 & medad >35 &      medad!=999
			
			
			destring factor , replace			
			collapse (sum) migUS  migUS_male1535 migUS_female1535 migUS_male36more migUS_female36more  [fweight = factor], by(  ent95 muni95 )
			
			sort  ent95 muni95
			save mig , replace
			
			
/* POINT 2: COUNT POPULATION (>5 five years old) BY PLACE OF RESIDENCE IN  1995 */ 			
			
		use PER_F`entidad'.dta, clear

			drop if   res95edo_c==999  | res95edo_c==.    /* drop less than 5 five years old*/ 
			drop if   mun95otr_c ==999 | mun95otr_c ==.
			
			rename res95edo_c  ent95
			rename mun95otr_c  muni95
			
			destring edad, replace
			destring  sexo ,replace
			
			g pop_95 = 1 
			g male1535_95       =  sexo==1 & edad >14 &  edad<36  &  edad!=999
			g female1535_95     =  sexo==2 & edad >14 &  edad<36  &   edad!=999
			g male36more_95     =  sexo==1 & edad >35 &     edad!=999
			g female36more_95   =  sexo==2 & edad >35 &     edad!=999
			
			
			destring factor , replace	
			collapse (sum) pop_95 male1535_95 female1535_95 male36more_95 female36more_95  [fweight = factor], by(  ent95 muni95 )
			
			sort  ent95 muni95
			
/* POINT 3 : MERGE AND SAVE DATA  */ 	
			
			merge 1:1 ent95 muni95 using mig
			drop if _merge ==2
			drop _m
				
			save temp_MIG`entidad', replace
			
	}
	*
	
	
		use temp_MIG1,clear 
			
		foreach entidad in  1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 {	
			append using temp_MIG`entidad' 
			}
			
			
			collapse (sum)  pop_95  male1535_95 female1535_95 male36more_95 female36more_95  migUS  migUS_male1535 migUS_female1535 migUS_male36more migUS_female36more   , by(  ent95 muni95 )
			
			rename ent95 cve_ent 
			rename  muni95 cve_mun
			label var pop_95    "pop 1995"
			label var migUS  "Nb migrant 1995-2000" 
		
		
			
			save  CENSUS2000_MUNIP_MIGRUS, replace
			
