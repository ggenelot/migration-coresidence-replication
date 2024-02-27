*Who is the migrant?

gen relm=rel_head_det if usmigrant_ever==1
bysort id_h: egen z=min(relm)

capture drop rm
gen rm=.
replace rm=. if z==1 & rel_head_det==1
replace rm=2 if z==1 & rel_head_det==2
replace rm=3 if z==1 & rel_head_det==3
replace rm=4 if z==1 & rel_head_det==4
replace rm=5 if z==1 & rel_head_det==5
replace rm=10 if z==1 & rel_head_det==10
replace rm=11 if z==1 & rel_head_det==11
replace rm=13 if z==1 & rel_head_det==13
replace rm=14 if z==1 & rel_head_det==14
replace rm=15 if z==1 & rel_head_det==15
replace rm=16 if z==1 & rel_head_det==16
replace rm=17 if z==1 & rel_head_det==17
replace rm=18 if z==1 & rel_head_det==18
replace rm=19 if z==1 & rel_head_det==19
replace rm=20 if z==1 & rel_head_det==20
replace rm=2 if z==2 & rel_head_det==1
replace rm=. if z==2 & rel_head_det==2
replace rm=3 if z==2 & rel_head_det==3
replace rm=4 if z==2 & rel_head_det==4
replace rm=5 if z==2 & rel_head_det==5
replace rm=16 if z==2 & rel_head_det==10
replace rm=19 if z==2 & rel_head_det==11
replace rm=13 if z==2 & rel_head_det==13
replace rm=14 if z==2 & rel_head_det==14
replace rm=20 if z==2 & rel_head_det==15
replace rm=10 if z==2 & rel_head_det==16
replace rm=17 if z==2 & rel_head_det==17
replace rm=18 if z==2 & rel_head_det==18
replace rm=11 if z==2 & rel_head_det==19
replace rm=20 if z==2 & rel_head_det==20
replace rm=10 if z==3 & rel_head_det==1
replace rm=10 if z==3 & rel_head_det==2
replace rm=11 if z==3 & rel_head_det==3
replace rm=4 if z==3 & rel_head_det==4
replace rm=5 if z==3 & rel_head_det==5
replace rm=21 if z==3 & rel_head_det==10
replace rm=22 if z==3 & rel_head_det==11
replace rm=23 if z==3 & rel_head_det==13
replace rm=15 if z==3 & rel_head_det==14
replace rm=20 if z==3 & rel_head_det==15
replace rm=21 if z==3 & rel_head_det==16
replace rm=16 if z==3 & rel_head_det==17
replace rm=24 if z==3 & rel_head_det==18
replace rm=22 if z==3 & rel_head_det==19
replace rm=20 if z==3 & rel_head_det==20
replace rm=21 if z==13 & rel_head_det==1
replace rm=21 if z==13 & rel_head_det==2
replace rm=25 if z==13 & rel_head_det==3
replace rm=4 if z==13 & rel_head_det==4
replace rm=5 if z==13 & rel_head_det==5
replace rm=20 if z==13 & rel_head_det==10
replace rm=20 if z==13 & rel_head_det==11
replace rm=26 if z==13 & rel_head_det==13
replace rm=20 if z==13 & rel_head_det==14
replace rm=20 if z==13 & rel_head_det==15
replace rm=20 if z==13 & rel_head_det==16
replace rm=27 if z==13 & rel_head_det==17
replace rm=25 if z==13 & rel_head_det==18
replace rm=20 if z==13 & rel_head_det==19
replace rm=20 if z==13 & rel_head_det==20
replace rm=16 if z==18 & rel_head_det==1
replace rm=16 if z==18 & rel_head_det==2
replace rm=24 if z==18 & rel_head_det==3
replace rm=4 if z==18 & rel_head_det==4
replace rm=5 if z==18 & rel_head_det==5
replace rm=20 if z==18 & rel_head_det==10
replace rm=20 if z==18 & rel_head_det==11
replace rm=23 if z==18 & rel_head_det==13
replace rm=20 if z==18 & rel_head_det==14
replace rm=20 if z==18 & rel_head_det==15
replace rm=20 if z==18 & rel_head_det==16
replace rm=28 if z==18 & rel_head_det==17
replace rm=20 if z==18 & rel_head_det==18
replace rm=20 if z==18 & rel_head_det==19
replace rm=20 if z==18 & rel_head_det==20

label define rel 2 "Spouse" 3 "Sons" 4 "Worker domestic" 5 "Not relatives" 10 "Parents, grand-parents or uncle" 11 "Siblings" 13 "Grand-son" 14 "Nephew" 15 "Cousin" 16 "Parents in law" 17 "Son's parents in law" 18 "Sons in law" 19 "Brother in law" 20 "Other" 21 "Grand-parents" 22 "Uncle" 23 "Sons or nephews" 24 "Spouse or brother in law" 25 "Father or uncle" 26 "Siblings or cousins" 27 "Grand-parents or others" 28 "Parents or other", replace
label values rm rel
label variable rm "Relationship with the migrant"

label define relz 1 "Head" 2 "Spouse" 3 "Sons" 4 "Worker domestic" 5 "Not relatives" 10 "Parents, grand-parents or uncle" 11 "Siblings" 13 "Grand-son" 14 "Nephew" 15 "Cousin" 16 "Parents in law" 17 "Son's parents in law" 18 "Sons in law" 19 "Brother in law" 20 "Other" 21 "Grand-parents" 22 "Uncle" 23 "Sons or nephews" 24 "Spouse or brother in law" 25 "Father or uncle" 26 "Siblings or cousins" 27 "Grand-parents or others" 28 "Parents or other", replace
label values z relz
label variable z "Relationship of the migrant with the household head"


