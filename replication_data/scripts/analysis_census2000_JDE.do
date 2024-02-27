

*1. Append the individual files
clear all
cd "/Volumes/Samsung_T5/ENOE_long/JDE_data"



	use PER_F_ent1_10.dta, clear
	
	append using PER_F_ent11_18
	append using PER_F_ent19_32
	
	save PER_F.dta,replace 

	
*Age difference between spouses
	use PER_F.dta, replace

	replace edad=. if edad==999
	gen age_mhead=edad if otropare_c==100 & sexo==1
	gen age_whead=edad if otropare_c==200 & sexo==2
	bys ent mun loc numviv numhog: egen age_h=max(age_mhead)
	bys ent mun loc numviv numhog: egen age_w=max(age_whead)
	gen difference=age_h-age_w
	sum difference if otropare_c==100, det

*2. Identify married women without spouse
	
use PER_F.dta, clear

	gen mw=((estcon==5 | estcon==6 | estcon==7) & sexo==2)
	replace mw=. if sexo==1
	label var mw "Married woman"

	gen i100=0
	replace i100=1 if sexo==1 & otropare_c==100 & (estcon==5 | estcon==6 | estcon==7)
	gen i200=0
	replace i200=1 if sexo==1 & otropare_c==200 & (estcon==5 | estcon==6 | estcon==7)
	gen i300=0
	replace i300=1 if sexo==1 & otropare_c==300 & (estcon==5 | estcon==6 | estcon==7)
	forvalues i=1(1)3 {
	gen i50`i'=0
	replace i50`i'=1 if sexo==1 & otropare_c==50`i' & (estcon==5 | estcon==6 | estcon==7)
	}
	forvalues i=601(1)624 {
	gen i`i'=0
	replace i`i'=1 if sexo==1 & otropare_c==`i' & (estcon==5 | estcon==6 | estcon==7)
	}

	bys ent mun loc numviv numhog: egen h100=max(i100)
	bys ent mun loc numviv numhog: egen h200=max(i200)
	bys ent mun loc numviv numhog: egen h300=max(i300)
	forvalues i=501(1)503 {
	bys ent mun loc numviv numhog: egen h`i'=max(i`i')
	}
	forvalues i=601(1)624 {
	bys ent mun loc numviv numhog: egen h`i'=max(i`i')
	}

*Identify married woman whose spouse is present
	gen mw_present=0 if mw==1
	replace mw_present=1 if otropare_c==100 & h200==1
	replace mw_present=1 if otropare_c==200 & h100==1
	replace mw_present=1 if otropare_c==300 & h616==1
	replace mw_present=1 if otropare_c==501 & h501==1
	replace mw_present=1 if otropare_c==502 & h502==1
	replace mw_present=1 if otropare_c==503 & h100==1
	replace mw_present=1 if otropare_c==601 & h601==1
	replace mw_present=1 if otropare_c==602 & h601==1
	replace mw_present=1 if otropare_c==603 & (h617==1 | h618==1)
	replace mw_present=1 if otropare_c==604 & (h617==1 | h624==1)
	replace mw_present=1 if otropare_c==605 & h605==1
	replace mw_present=1 if otropare_c==606 & h606==1
	replace mw_present=1 if otropare_c==607 & h607==1
	replace mw_present=1 if otropare_c==608 & h624==1
	replace mw_present=1 if otropare_c==609 & h624==1
	replace mw_present=1 if otropare_c==610 & h624==1
	replace mw_present=1 if otropare_c==611 & h611==1
	replace mw_present=1 if otropare_c==612 & h624==1
	replace mw_present=1 if otropare_c==613 & (h613==1 | h624==1)
	replace mw_present=1 if otropare_c==614 & h615==1
	replace mw_present=1 if otropare_c==615 & h615==1
	replace mw_present=1 if otropare_c==616 & h300==1
	replace mw_present=1 if otropare_c==617 & (h617==1 | h603==1 | h618==1)
	replace mw_present=1 if otropare_c==618 & h618==1
	replace mw_present=1 if otropare_c==619 & h501==1
	replace mw_present=1 if otropare_c==620 & h501==1
	replace mw_present=1 if otropare_c==621 & h501==1
	replace mw_present=1 if otropare_c==622 & h501==1
	replace mw_present=1 if otropare_c==623 & h501==1
	replace mw_present=1 if otropare_c==624 & h624==1

	replace mw_present=. if mw==0
	gen mw_abs=mw
	replace mw_abs=0 if mw_present==1
	label var mw_abs "Married woman with absent spouse"

	label define brel 100 "Household head" 300 "Daughter" 616 "Daughter in law" 999 "Other"
	gen rel=otropare_c
	replace rel=999 if rel!=100 & rel!=300 & rel!=616
	label values rel brel

*5. Internal migration

	gen internal_migrant=0
	replace internal_migrant=1 if (res95edo_c<=32 & (res95edo_c!=ent | mun95otr_c!=mun))
	replace internal_migrant=2 if res95edo_c>32

	label var internal_migrant "Residence in January 1995"
	label define stat 0 "No move" 1 "Internal migrant" 2 "Returnee"
	label values internal_migrant stat

*Age range of the potential migrant husband
	
	gen range_l=.
	replace range_l=edad-3 if mw_abs==1
	gen range_u=.
	replace range_u=edad+14 if mw_abs==1
	
	save PER_Fmw_abs.dta, replace


*Use migrant files

*Identify current male migrants
*No information on marital staus or on the relationship with the household head
	
	use MIN_F.dta, clear
	
	gen male_noret=(msexo==1 & mfecreta==.)
	bys ent mun loc numviv numhog: egen hmale_noret=max(male_noret)
	keep if male_noret==1
	tab mper

	replace mfecemia=1995 if mfecemia==9999

	forvalues i=1(1)18 {
	gen x_m`i'=medad+(2000-mfecemia) if mper==`i'
	bys ent mun loc numviv numhog: egen age_m`i'=max(x_m`i')
	drop x_m`i'
	}

	keep if mper==1
	gen hmigrant=1

	keep ent mun loc numviv numhog hmale_noret hmigrant age_m1-age_m18

	save rMIN_F.dta, replace


*Combine the 2  datasets
	
	clear
	use PER_Fmw_abs.dta
	merge m:1 ent mun loc numviv numhog using rMIN_F.dta
	drop _merge

*Sample selection

*Keep only women with an absent spouse
	keep if mw_abs==1
*Keep only those who receive directly remittances
	keep if ayufaopr==3
*Keep only those who were residing in Mexico in January 1995
	drop if internal_migrant==2
	count

	gen head=(rel==100)

*Identify whether there is a potential husband among the migrants
	gen migrant_husband=0
	forvalues i=1(1)18 {
	replace migrant_husband=1 if range_l<=age_m`i' & range_u>=age_m`i'
	}
	*  	

	*TABLE 11 

	outreg, clear(table11) 
	global option   nod  ctitle(" ", "") varlabels  tex plain fragment  bdec(4)  se  starloc(1) starlevels(10 5  1) nocenter 
	
	qui reg migrant_husband head [aw=factor]
	outreg, merge(table11) keep(head) addrows(  "Dummies for age", "No" )  $option	
	qui areg migrant_husband head [aw=factor], absorb(edad)
	outreg, merge(table11)  keep(head)  addrows(  "Dummies for age", "Yes" ) $option

	nois outreg    ,  replace replay(table11) title("Table 11: Married women with an absent spouse")  
	
	
