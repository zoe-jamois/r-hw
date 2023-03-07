cd "/Users/zoejamois/Documents/M1/code_datafolder_applied"
log using "logfile.txt", text replace

ssc install nmissing
ssc install autorename
ssc install gtools
ssc install outreg2

/* 
To clean the 2008 municipal elections dataset we will:

	1) First round of the elections.
		1.1) Tidy the dataset for cities with good format.
		1.2) Tidy the dataset for cities with wrong format:
			1.2.1) Tidy the dataset for cities with problems in the separators (;)
			1.2.2) Tidy the dataset for cities with problems in the name and codedelacommune
		1.3) Append the datasets
			
			
	2) Second round of the elections
		2.1) Tidy the dataset for cities with good format.
		2.2) Tidy the dataset for cities with wrong format:
			2.2.1) Tidy the dataset for cities with problems in the separators (;)
			2.2.2) Tidy the dataset for cities with problems in the name and codedelacommune
		2.3) Append the datasets
	3) Append both datasets

To clean the 2014 municipal elections dataset we will:

	1) Tidy the first round of the elections
	2) Tidy the second round of elections
	3) Append both datasets

Remarks:
The data-cleaning part for 2008 is considerably longer to the 2014 because of the format of the file
There was less data available for 2008 than for 2014
*/

********************************************************************************
/* 2008 */
********************************************************************************


********************* FIRST ROUND*********************
//Section 1.1)
import excel "2008.xls", sheet(Tour 1) firstrow clear
foreach var of varlist * {
  rename `var' `=strlower("`var'")'
}


drop if libellédudépartement=="MAYOTTE" | libellédudépartement=="GUYANE" | libellédudépartement=="LA REUNION" | libellédudépartement=="POLYNESIE FRANCAISE" | libellédudépartement=="NOUVELLE CALEDONIE" | libellédudépartement=="MARTINIQUE" | libellédudépartement=="GUADELOUPE" | libellédudépartement=="SAINT PIERRE ET MIQUELON"  //We drop the départements d'Outre-mer 


drop if codenuance=="NC" //Cities with bad format (see section 1.2.2)

drop if strpos(libellédelacommune,"Section")  //Cities with bad format (see section 1.2.2)


generate id_commune=codedudépartement+"."+codedelacommune // We create a unique identifier for the observations:
drop abstentions inscrits absins votants votins blancsetnuls blnulsins blnulsvot exprimés expins expvot // We drop variables that we will not use:


nmissing, min(2758)  //We delete the empty columns
drop `r(varlist)'

foreach var of varlist codenuance sexe sieges nom prénom liste voix voixins voixexp { 
    rename `var' `var'1
} //We rename the variables so that we can then reshape the dataset from wide format to long format


//Note: intended to rename the following variables using a loop but did not manage:
rename y codenuance2
rename z sexe2
rename aa nom2
rename ab prénom2
rename ac liste2
rename ad sieges2
rename ae voix2
rename af voixins2
rename ag voixexp2

rename ah codenuance3
rename ai sexe3
rename aj nom3
rename ak prénom3
rename al liste3
rename am sieges3
rename an voix3
rename ao voixins3
rename ap voixexp3

rename aq codenuance4
rename ar sexe4
rename as nom4
rename at prénom4
rename au liste4
rename av sieges4
rename aw voix4
rename ax voixins4
rename ay voixexp4

rename az codenuance5
rename ba sexe5
rename bb nom5
rename bc prénom5
rename bd liste5
rename be sieges5
rename bf voix5
rename bg voixins5
rename bh voixexp5

rename bi codenuance6
rename bj sexe6
rename bk nom6
rename bl prénom6
rename bm liste6
rename bn sieges6
rename bo voix6
rename bp voixins6
rename bq voixexp6

rename br codenuance7
rename bs sexe7
rename bt nom7
rename bu prénom7
rename bv liste7
rename bw sieges7
rename bx voix7
rename by voixins7
rename bz voixexp7

rename ca codenuance8
rename cb sexe8
rename cc nom8
rename cd prénom8
rename ce liste8
rename cf sieges8
rename cg voix8
rename ch voixins8
rename ci voixexp8

rename cj codenuance9
rename ck sexe9
rename cl nom9
rename cm prénom9
rename cn liste9
rename co sieges9
rename cp voix9
rename cq voixins9
rename cr voixexp9

rename cs codenuance10
rename ct sexe10
rename cu nom10
rename cv prénom10
rename cw liste10
rename cx sieges10
rename cy voix10
rename cz voixins10
rename da voixexp10

rename db codenuance11
rename dc sexe11
rename dd nom11
rename de prénom11
rename df liste11
rename dg sieges11
rename dh voix11
rename di voixins11
rename dj voixexp11

rename dk codenuance12
rename dl sexe12
rename dm nom12
rename dn prénom12
rename do liste12
rename dp sieges12
rename dq voix12
rename dr voixins12
rename ds voixexp12


drop if sieges8=="LILLE: EMPLOI, SECURITE, " //Observation with wrong format. No winner in the first round so drop not problematic

destring sieges8, replace

reshape long codenuance sexe nom prénom liste sieges voix voixins voixexp, i(id_commune) j(type) // From wide format to long format

drop if codenuance == "" //Empty observations created after the reshape
drop if strlen(liste) > 27 // These observations have wrong format (will fix their format in section 1.2.1)

drop type

format liste %30s 

bys id_commune: gegen maxvote=max(voixexp) //We compute the candidate with the largest percentage of votes per city
bys id_commune: gegen maxsieges=max(sieges) //We compute the candidate that one the largest number of seats in the city

keep if voixexp==maxvote &  sieges==maxsieges //We keep the candidate with the most votes and most seats

keep if voixexp >50 //Since we are in the first round we will only keep candidates that got more than 50% of votes

drop maxsieges maxvote

drop id_commune

replace codedelacommune=substr(codedelacommune, 1, 3) // We fix the format of some observations (so that it is homogeneous throughout the datasets)

generate id_commune=codedudépartement+"."+codedelacommune // We create the unique identifier again


gen tour=1 //First round


save 2008_t1_1.dta , replace

/* WRONG FORMAT: :*/
//Section 1.2.1)

import excel "2008.xls", sheet(Tour 1) firstrow clear
foreach var of varlist * {
  rename `var' `=strlower("`var'")'
}
drop if libellédudépartement=="MAYOTTE" | libellédudépartement=="GUYANE" | libellédudépartement=="LA REUNION" | libellédudépartement=="POLYNESIE FRANCAISE" | libellédudépartement=="NOUVELLE CALEDONIE" | libellédudépartement=="MARTINIQUE" | libellédudépartement=="GUADELOUPE" | libellédudépartement=="SAINT PIERRE ET MIQUELON" //We drop the départements d'Outre-mer 

drop if codenuance=="NC" //Cities with bad format (see section 1.2.2)
drop if strpos(libellédelacommune,"Section") //Cities with bad format (see section 1.2.2)
generate id_commune=codedudépartement+"."+codedelacommune // We create a unique identifier for the observations
drop abstentions inscrits absins votants votins blancsetnuls blnulsins blnulsvot exprimés expins expvot // We drop variables that we will not use


nmissing, min(2758)  //We delete the empty columns
drop `r(varlist)'

foreach var of varlist codenuance sexe sieges nom prénom liste voix voixins voixexp {
    rename `var' `var'1
} //We rename the variables so that we can then reshape the dataset from wide format to long format


//Note: intended to rename the following variables using a loop but did not manage:

rename y codenuance2
rename z sexe2
rename aa nom2
rename ab prénom2
rename ac liste2
rename ad sieges2
rename ae voix2
rename af voixins2
rename ag voixexp2

rename ah codenuance3
rename ai sexe3
rename aj nom3
rename ak prénom3
rename al liste3
rename am sieges3
rename an voix3
rename ao voixins3
rename ap voixexp3

rename aq codenuance4
rename ar sexe4
rename as nom4
rename at prénom4
rename au liste4
rename av sieges4
rename aw voix4
rename ax voixins4
rename ay voixexp4

rename az codenuance5
rename ba sexe5
rename bb nom5
rename bc prénom5
rename bd liste5
rename be sieges5
rename bf voix5
rename bg voixins5
rename bh voixexp5

rename bi codenuance6
rename bj sexe6
rename bk nom6
rename bl prénom6
rename bm liste6
rename bn sieges6
rename bo voix6
rename bp voixins6
rename bq voixexp6

rename br codenuance7
rename bs sexe7
rename bt nom7
rename bu prénom7
rename bv liste7
rename bw sieges7
rename bx voix7
rename by voixins7
rename bz voixexp7

rename ca codenuance8
rename cb sexe8
rename cc nom8
rename cd prénom8
rename ce liste8
rename cf sieges8
rename cg voix8
rename ch voixins8
rename ci voixexp8

rename cj codenuance9
rename ck sexe9
rename cl nom9
rename cm prénom9
rename cn liste9
rename co sieges9
rename cp voix9
rename cq voixins9
rename cr voixexp9

rename cs codenuance10
rename ct sexe10
rename cu nom10
rename cv prénom10
rename cw liste10
rename cx sieges10
rename cy voix10
rename cz voixins10
rename da voixexp10

rename db codenuance11
rename dc sexe11
rename dd nom11
rename de prénom11
rename df liste11
rename dg sieges11
rename dh voix11
rename di voixins11
rename dj voixexp11

rename dk codenuance12
rename dl sexe12
rename dm nom12
rename dn prénom12
rename do liste12
rename dp sieges12
rename dq voix12
rename dr voixins12
rename ds voixexp12


drop if sieges8=="LILLE: EMPLOI, SECURITE, " //Observation with wrong format. No winner in the first round so drop not problematic

destring sieges8, replace

reshape long codenuance sexe nom prénom liste sieges voix voixins voixexp, i(id_commune) j(type) // From wide format to long format

drop type

drop if codenuance == "" //Empty observations created after the reshape
keep if strlen(liste) > 27 // These observations have wrong format (will fix their format in section 1.2.1)


drop if id_commune=="30.243" | id_commune=="42.218" | id_commune=="42.22" | id_commune=="86.66" | id_commune=="92.24" //We drop the observations with wrong format whose mayor didn't get ellected in the first round (No need to fix their format since we will drop them)

//We manually fix the format of the cities:
replace liste="ENSEMBLE POUR SAINT" if id_commune=="30.294"
replace sieges=21 if id_commune=="30.294"
replace voix=1219 if id_commune=="30.294"
replace voixins=33.06 if id_commune=="30.294"
replace  voixexp=50.48 if id_commune=="30.294"

replace codenuance = "LDVD" if id_commune=="30.344"
replace sexe="M" if id_commune=="30.344"
replace nom="BALANA" if id_commune=="30.344"
replace prénom="René" if id_commune=="30.344"
replace liste="VERGEZE AVENIR" if id_commune=="30.344"
replace sieges=20 if id_commune=="30.344"
replace voix=1031 if id_commune=="30.344"
replace voixins=34.37 if id_commune=="30.344"
replace voixexp=52.04 if id_commune=="30.344"

replace liste="FLOIRAC : UNE PASSION PA" if id_commune=="33.167"
replace sieges=27 if id_commune=="33.167"
replace voix=3273 if id_commune=="33.167"
replace voixins=29.83 if id_commune=="33.167"
replace voixexp=62.67 if id_commune=="33.167"


replace liste="SAINT JEAN D'ILLAC, UNE" if id_commune=="33.422"
replace sieges=22 if id_commune=="33.422"
replace voix=1633 if id_commune=="33.422"
replace voixins=35.54 if id_commune=="33.422"
replace voixexp=50.17 if id_commune=="33.422"

replace liste="MOINGT-MONTBRISON, UNE A" if id_commune=="42.147SN01"
replace sieges=20 if id_commune=="42.147SN01"
replace voix=2261 if id_commune=="42.147SN01"
replace voixins=29.21 if id_commune=="42.147SN01"
replace voixexp=51.4 if id_commune=="42.147SN01"

replace liste="ENSEMBLE POUR LA FOUILLO" if id_commune=="42.97"
replace sieges=21 if id_commune=="42.97"
replace voix=1142 if id_commune=="42.97"
replace voixins=35.33 if id_commune=="42.97"
replace voixexp=51.07 if id_commune=="42.97"

replace codenuance = "LMAJ" if id_commune=="59.299"
replace sexe="M" if id_commune=="59.299"
replace nom="VERCAMER" if id_commune=="59.299"
replace prénom="Francis" if id_commune=="59.299"
replace liste="AVEC FRANCIS VERCAMER" if id_commune=="59.299"
replace sieges=27 if id_commune=="59.299"
replace voix=4200 if id_commune=="59.299"
replace voixins=31.43 if id_commune=="59.299"
replace voixexp=57.31 if id_commune=="59.299"


replace liste="AGIR ENSEMBLE POUR MORLA" if id_commune=="64.405"
replace sieges=27 if id_commune=="64.405"
replace voix=1574 if id_commune=="64.405"
replace voixins=53 if id_commune=="64.405"
replace voixexp=100 if id_commune=="64.405"

replace codenuance = "LMAJ" if id_commune=="86.070SN01"
replace sexe="M" if id_commune=="86.070SN01"
replace nom="HERBERT" if id_commune=="86.070SN01"
replace prénom="Gérard" if id_commune=="86.070SN01"
replace liste="VIVRE ET AGIR AVEC CHAUV" if id_commune=="86.070SN01"

replace liste="ENSEMBLE POUR MONT" if id_commune=="86.165"
replace sieges=23 if id_commune=="86.165"
replace voix=1999 if id_commune=="86.165"
replace voixins=40.03 if id_commune=="86.165"
replace voixexp=53.77 if id_commune=="86.165"

replace liste="POITIERS GRANDEUR NATURE" if id_commune=="86.194"
replace sieges=42 if id_commune=="86.194"
replace voix=14190 if id_commune=="86.194"
replace voixins=30.06 if id_commune=="86.194"
replace voixexp=54.54 if id_commune=="86.194"

replace liste="SAINT-BENOIT, UN CHOIX" if id_commune=="86.214"
replace sieges=24 if id_commune=="86.214"
replace voix=2198 if id_commune=="86.214"
replace voixins=39.64 if id_commune=="86.214"
replace voixexp=64.31 if id_commune=="86.214"

replace codenuance = "LDVD" if id_commune=="86.297"
replace sexe="M" if id_commune=="86.297"
replace nom="TANGUY" if id_commune=="86.297"
replace prénom="Alain" if id_commune=="86.297"
replace liste="AGIR ENSEMBLE POUR VOUNEU" if id_commune=="86.297"
replace sieges=23 if id_commune=="86.297"
replace voix=1658 if id_commune=="86.297"
replace voixins=45.6 if id_commune=="86.297"
replace voixexp=66.5 if id_commune=="86.297"

drop if id_commune=="86.41" //No information about who won

gen tour=1 //First round


format liste %30s 

bys id_commune: gegen maxvote=max(voixexp) //We compute the candidate with the largest percentage of votes per city
bys id_commune: gegen maxsieges=max(sieges) //We compute the candidate that one the largest number of seats in the city

keep if voixexp==maxvote &  sieges==maxsieges //We keep the candidate with the most votes and most seats

keep if voixexp >50 //Since we are in the first round we will only keep candidates that got more than 50% of votes

drop maxsieges maxvote

save 2008_t1_2.dta , replace

/* DEALING WITH CITIES "SECTION": */

//Section 1.2.2)
		
import excel "2008.xls", sheet(Tour 1) firstrow clear
foreach var of varlist * {
  rename `var' `=strlower("`var'")'
}


keep if strpos(libellédelacommune,"Section") | codenuance=="NC"  //We keep the cities with bad format (The cities that contain the word "Section" have uncommon zip codes and the condenuance "NC" does not exist. Cities that have these codenuances have the information misplaced)

replace codedelacommune=substr(codedelacommune, 1, 3) if strpos(libellédelacommune,"Section") //We fix the zip codes

generate id_commune=codedudépartement+"."+codedelacommune  // We create a unique identifier for the observations

drop abstentions absins votants votins blancsetnuls blnulsins blnulsvot exprimés expins expvot // We drop variables that we will not use
save section.dta , replace //We will use this datafile for the merge in this section

keep codedelacommune libellédelacommune codenuance //We prepare the master for the merge
keep if codenuance=="NC" //Cities that have the information misplaced)
rename libellédelacommune libellédelacommune2 //So that it does not have the same names as the dataset "section"
rename codenuance codenuance2
drop if libellédelacommune=="Nogent-le-Roi" //No information

merge 1:m codedelacommune using section, keep(3) //We retrieve the previous dataset

replace libellédelacommune=libellédelacommune2 //We place the information in the correct order


drop libellédelacommune2 codenuance2 _merge

drop if codenuance=="NC" //We drop the problematic observations

replace liste="" if nom=="FAURE" & prénom=="Liliane" //We fix the wrong format

format liste %30s

nmissing, min(33)  //We delete the empty columns
drop `r(varlist)'

//Note: intended to rename the following variables using a loop but did not manage:
rename codenuance codenuance1
rename sexe sexe1
rename nom nom1
rename prénom prénom1
rename liste liste1
rename sieges sieges1
rename voix voix1 
rename voixins voixins1
rename voixexp voixexp1

rename y codenuance2
rename z sexe2
rename aa nom2
rename ab prénom2
rename ac liste2
rename ad sieges2
rename ae voix2
rename af voixins2
rename ag voixexp2

rename ah codenuance3
rename ai sexe3
rename aj nom3
rename ak prénom3
rename al liste3
rename am sieges3
rename an voix3
rename ao voixins3
rename ap voixexp3

rename aq codenuance4
rename ar sexe4
rename as nom4
rename at prénom4
rename au liste4
rename av sieges4
rename aw voix4
rename ax voixins4
rename ay voixexp4

bys id_commune: gegen max_pop=max(inscrits) 
keep if inscrits==max_pop //Since we changed the format we keep the information of the big city (not the sections) i.e., the one with the highest population

drop inscrits max_pop

reshape long codenuance sexe nom prénom liste sieges voix voixins voixexp, i(id_commune) j(type) //wide to long

bys id_commune: gegen maxvote=max(voixexp) //We compute the candidate with the largest percentage of votes per city
bys id_commune: gegen maxsieges=max(sieges) //We compute the candidate that one the largest number of seats in the city

keep if voixexp==maxvote &  sieges==maxsieges //We keep the candidate with the most votes and most seats

keep if voixexp >50 //Since we are in the first round we will only keep candidates that got more than 50% of votes

drop maxsieges maxvote type


format liste %30s


gen tour=1 //First round


save 2008_t1_3.dta , replace

/* APPEND ALL DATASETS:*/
		
//section 1.3)

clear all


use 2008_t1_1.dta
		
append using 2008_t1_2.dta

append using 2008_t1_3.dta

format liste %30s


save 2008_elections_t1.dta, replace //First round 2008

/*SECOND ROUND */

//Section 2.1)

import excel "2008.xls", sheet(Tour 2) firstrow clear
foreach var of varlist * {
  rename `var' `=strlower("`var'")'
}

drop if libellédudépartement=="MAYOTTE" | libellédudépartement=="GUYANE" | libellédudépartement=="LA REUNION" | libellédudépartement=="POLYNESIE FRANCAISE" | libellédudépartement=="NOUVELLE CALEDONIE" | libellédudépartement=="MARTINIQUE" | libellédudépartement=="GUADELOUPE" | libellédudépartement=="SAINT PIERRE ET MIQUELON"  //We drop the départements d'Outre-mer 


drop if codenuance=="NC" //Cities with bad format (see section 2.2.2)

drop if strpos(libellédelacommune,"Section")  //Cities with bad format (see section 1.2.2)
replace codedelacommune=substr(codedelacommune, 1, 3) if strpos(libellédelacommune,"Section")

generate id_commune=codedudépartement+"."+codedelacommune // We create a unique identifier for the observations:
drop abstentions inscrits absins votants votins blancsetnuls blnulsins blnulsvot exprimés expins expvot // We drop variables that we will not use:

nmissing, min(918)  //We delete the empty columns
drop `r(varlist)'

foreach var of varlist codenuance sexe sieges nom prénom liste voix voixins voixexp {
    rename `var' `var'1
} //We rename the variables so that we can then reshape the dataset from wide format to long format

//Note: intended to rename the following variables using a loop but did not manage:
rename y codenuance2
rename z sexe2
rename aa nom2
rename ab prénom2
rename ac liste2
rename ad sieges2
rename ae voix2
rename af voixins2
rename ag voixexp2

rename ah codenuance3
rename ai sexe3
rename aj nom3
rename ak prénom3
rename al liste3
rename am sieges3
rename an voix3
rename ao voixins3
rename ap voixexp3

rename aq codenuance4
rename ar sexe4
rename as nom4
rename at prénom4
rename au liste4
rename av sieges4
rename aw voix4
rename ax voixins4
rename ay voixexp4

rename az codenuance5
rename ba sexe5
rename bb nom5
rename bc prénom5
rename bd liste5
rename be sieges5
rename bf voix5
rename bg voixins5
rename bh voixexp5


reshape long codenuance sexe nom prénom liste sieges voix voixins voixexp, i(id_commune) j(type) // From wide format to long format


drop if codenuance == "" //Empty observations created after the reshape
drop if strlen(liste) > 27 // These observations have wrong format (will fix their format in section 2.2.2)

drop type

format liste %30s


bys id_commune: gegen maxvote=max(voixexp) //We compute the candidate with the largest percentage of votes per city
bys id_commune: gegen maxsieges=max(sieges) //We compute the candidate that one the largest number of seats in the city

keep if voixexp==maxvote &  sieges==maxsieges //We keep the candidate with the most votes and most seats

drop maxsieges maxvote

gen tour=2 //Second round 


save 2008_t2_1.dta , replace

/* WRONG FORMAT; */

//Section 2.1.1)

import excel "2008.xls", sheet(Tour 2) firstrow clear
foreach var of varlist * {
  rename `var' `=strlower("`var'")'
}



drop if libellédudépartement=="MAYOTTE" | libellédudépartement=="GUYANE" | libellédudépartement=="LA REUNION" | libellédudépartement=="POLYNESIE FRANCAISE" | libellédudépartement=="NOUVELLE CALEDONIE" | libellédudépartement=="MARTINIQUE" | libellédudépartement=="GUADELOUPE" | libellédudépartement=="SAINT PIERRE ET MIQUELON" //We drop the départements d'Outre-mer

drop if codenuance=="NC" //Cities with bad format (see section 2.2.2)

drop if strpos(libellédelacommune,"Section")  //Cities with bad format (see section 1.2.2)
replace codedelacommune=substr(codedelacommune, 1, 3) if strpos(libellédelacommune,"Section")

generate id_commune=codedudépartement+"."+codedelacommune // We create a unique identifier for the observations:
drop abstentions inscrits absins votants votins blancsetnuls blnulsins blnulsvot exprimés expins expvot // We drop variables that we will not use:


nmissing, min(918)  //We delete the empty columns
drop `r(varlist)'

foreach var of varlist codenuance sexe sieges nom prénom liste voix voixins voixexp {
    rename `var' `var'1
} //We rename the variables so that we can then reshape the dataset from wide format to long format

//Note: intended to rename the following variables using a loop but did not manage:
rename y codenuance2
rename z sexe2
rename aa nom2
rename ab prénom2
rename ac liste2
rename ad sieges2
rename ae voix2
rename af voixins2
rename ag voixexp2

rename ah codenuance3
rename ai sexe3
rename aj nom3
rename ak prénom3
rename al liste3
rename am sieges3
rename an voix3
rename ao voixins3
rename ap voixexp3

rename aq codenuance4
rename ar sexe4
rename as nom4
rename at prénom4
rename au liste4
rename av sieges4
rename aw voix4
rename ax voixins4
rename ay voixexp4

rename az codenuance5
rename ba sexe5
rename bb nom5
rename bc prénom5
rename bd liste5
rename be sieges5
rename bf voix5
rename bg voixins5
rename bh voixexp5


reshape long codenuance sexe nom prénom liste sieges voix voixins voixexp, i(id_commune) j(type)  // From wide format to long format


drop if codenuance == "" //Empty observations created after the reshape
keep if strlen(liste) > 27 // These observations have wrong format (will fix their format in section 2.2.2)


nmissing, min(4)  
drop `r(varlist)'

//We manually fix the format of the cities:
replace codenuance = "LDVG" if id_commune=="30.243"
replace nom="ROUX" if id_commune=="30.243"
replace prénom="Philippe" if id_commune=="30.243"
replace liste="CLARTE ET DEMOCRATIE" if id_commune=="30.243"
gen sieges=22 if id_commune=="30.243"
gen voix=1690 if id_commune=="30.243"
gen voixins=33.41 if id_commune=="30.243"
gen  voixexp=46.12 if id_commune=="30.243"


replace liste="VIVRE MIEUX A ST ETIENNE" if id_commune=="42.218"
replace sieges=12 if id_commune=="42.218"
replace voix=24662 if id_commune=="42.218"
replace voixins=23.9 if id_commune=="42.218"
replace voixexp=41.63 if id_commune=="42.218"

replace codenuance = "LCMD" if id_commune=="42.22"
replace sexe="M" if id_commune=="42.22"
replace nom="DEVILLE" if id_commune=="42.22"
replace prénom="Joseph" if id_commune=="42.22"
replace liste="BONSON : LE RENOUVEAU" if id_commune=="42.22"
replace sieges=20 if id_commune=="42.22"
replace voix=800 if id_commune=="42.22"
replace voixins=28.1 if id_commune=="42.22"
replace voixexp=43.69 if id_commune=="42.22"

replace liste="REUSSIR LOUDUN AVEC VOUS" if id_commune=="86.137SN01"
replace sieges=5 if id_commune=="86.137SN01"
replace voix=1225 if id_commune=="86.137SN01"
replace voixins=23.23 if id_commune=="86.137SN01"
replace voixexp=34.03 if id_commune=="86.137SN01"

replace codenuance = "LDVD" if id_commune=="92.24"
replace sexe="M" if id_commune=="92.24"
replace nom="MUZEAU" if id_commune=="92.24"
replace prénom="Remi" if id_commune=="92.24"
replace liste=";MIEUX VIVRE ENSEMBLE" if id_commune=="92.24"
replace sieges=9 if id_commune=="92.24"
replace voix=6568 if id_commune=="92.24"
replace voixins=22.18 if id_commune=="92.24"
replace voixexp=40.59 if id_commune=="92.24"

drop type
format liste %40s

bys id_commune: gegen maxvote=max(voixexp)
bys id_commune: gegen maxsieges=max(sieges)

keep if voixexp==maxvote &  sieges==maxsieges 

drop maxsieges maxvote

gen tour=2 //Second round 
save 2008_t2_2.dta , replace

/* DEALING WITH CITIES "SECTION": */

//Section 2.2.2)

import excel "2008.xls",sheet(Tour 2) firstrow clear
foreach var of varlist * {
  rename `var' `=strlower("`var'")'
}

keep if strpos(libellédelacommune,"Section") | codenuance=="NC"  //We keep the cities with bad format (The cities that contain the word "Section" have uncommon zip codes and the condenuance "NC" does not exist. Cities that have these codenuances have the information misplaced)

replace codedelacommune=substr(codedelacommune, 1, 3) if strpos(libellédelacommune,"Section") //We fix the zip codes

generate id_commune=codedudépartement+"."+codedelacommune  // We create a unique identifier for the observations

drop abstentions absins votants votins blancsetnuls blnulsins blnulsvot exprimés expins expvot // We drop variables that we will not use
save section.dta , replace //We will use this datafile for the merge in this section

keep codedelacommune libellédelacommune codenuance //We prepare the master for the merge
keep if codenuance=="NC" //Cities that have the information misplaced)
rename libellédelacommune libellédelacommune2 //So that it does not have the same names as the dataset "section"
rename codenuance codenuance2

merge 1:m codedelacommune using section, keep(3) //We retrieve the previous dataset

replace libellédelacommune=libellédelacommune2 //We place the information in the correct order

drop libellédelacommune2 codenuance2 _merge

drop if codenuance=="NC" //We drop the problematic observations


format liste %30s

foreach var of varlist codenuance sexe sieges nom prénom liste voix voixins voixexp {
    rename `var' `var'1
} //We rename the variables so that we can then reshape the dataset from wide format to long format
//Note: intended to rename the following variables using a loop but did not manage:
rename y codenuance2
rename z sexe2
rename aa nom2
rename ab prénom2
rename ac liste2
rename ad sieges2
rename ae voix2
rename af voixins2
rename ag voixexp2

rename ah codenuance3
rename ai sexe3
rename aj nom3
rename ak prénom3
rename al liste3
rename am sieges3
rename an voix3
rename ao voixins3
rename ap voixexp3

rename aq codenuance4
rename ar sexe4
rename as nom4
rename at prénom4
rename au liste4
rename av sieges4
rename aw voix4
rename ax voixins4
rename ay voixexp4

rename az codenuance5
rename ba sexe5
rename bb nom5
rename bc prénom5
rename bd liste5
rename be sieges5
rename bf voix5
rename bg voixins5
rename bh voixexp5

rename bi codenuance6
rename bj sexe6
rename bk nom6
rename bl prénom6
rename bm liste6
rename bn sieges6
rename bo voix6
rename bp voixins6
rename bq voixexp6

rename br codenuance7
rename bs sexe7
rename bt nom7
rename bu prénom7
rename bv liste7
rename bw sieges7
rename bx voix7
rename by voixins7
rename bz voixexp7

rename ca codenuance8
rename cb sexe8
rename cc nom8
rename cd prénom8
rename ce liste8
rename cf sieges8
rename cg voix8
rename ch voixins8
rename ci voixexp8

rename cj codenuance9
rename ck sexe9
rename cl nom9
rename cm prénom9
rename cn liste9
rename co sieges9
rename cp voix9
rename cq voixins9
rename cr voixexp9

rename cs codenuance10
rename ct sexe10
rename cu nom10
rename cv prénom10
rename cw liste10
rename cx sieges10
rename cy voix10
rename cz voixins10
rename da voixexp10

rename db codenuance11
rename dc sexe11
rename dd nom11
rename de prénom11
rename df liste11
rename dg sieges11
rename dh voix11
rename di voixins11
rename dj voixexp11

rename dk codenuance12
rename dl sexe12
rename dm nom12
rename dn prénom12
rename do liste12
rename dp sieges12
rename dq voix12
rename dr voixins12
rename ds voixexp12

rename dt codenuance13
rename du sexe13
rename dv nom13
rename dw prénom13
rename dx liste13
rename dy sieges13
rename dz voix13
rename ea voixins13
rename eb voixexp13

rename ec codenuance14
rename ed sexe14
rename ee nom14
rename ef prénom14
rename eg liste14
rename eh sieges14
rename ei voix14
rename ej voixins14
rename ek voixexp14

rename el codenuance15
rename em sexe15
rename en nom15
rename eo prénom15
rename ep liste15
rename eq sieges15
rename er voix15
rename es voixins15
rename et voixexp15

rename eu codenuance16
rename ev sexe16
rename ew nom16
rename ex prénom16
rename ey liste16
rename ez sieges16
rename fa voix16
rename fb voixins16
rename fc voixexp16


nmissing, min(10) //We delete the empty columns
drop `r(varlist)'


bys id_commune: gegen max_pop=max(inscrits) 
keep if inscrits==max_pop //Since we changed the format we keep the information of the big city (not the sections) i.e., the one with the highest population

drop inscrits  max_pop
reshape long codenuance sexe nom prénom liste sieges voix voixins voixexp, i(id_commune) j(type)
drop type 
drop if codenuance == "" //Empty observations created after the reshape

bys id_commune: gegen maxvote=max(voixexp)
bys id_commune: gegen maxsieges=max(sieges)

keep if voixexp==maxvote &  sieges==maxsieges 

drop maxsieges maxvote

gen tour=2 //Second round
save 2008_t2_3.dta,replace

/* APPEND ALL DATASETS:*/
//Section 2.3:

clear all

use 2008_t2_1.dta //
		
append using 2008_t2_2.dta

append using 2008_t2_3.dta

bys id_commune: gegen maxvote=max(voixexp)
bys id_commune: gegen maxsieges=max(sieges)

keep if voixexp==maxvote &  sieges==maxsieges 

drop maxsieges maxvote

isid id_commune

save 2008_elections_t2.dta, replace

/* 2008 RESULTS */

//Section 3)

clear all

use 2008_elections_t1.dta

append using 2008_elections_t2.dta

format liste %40s

rename codenuance codenuance08
rename sexe sexe08
rename nom nom08
rename prénom prénom08
rename liste liste08
rename sieges sieges08
rename voix voix08
rename tour tour08
rename voixins voixins08
rename voixexp voixexp08


drop if strpos(libellédelacommune,"arrondissement") | strpos(libellédelacommune,"secteur") | strpos(libellédelacommune,"Secteur") // The observations that contain the words "arrondissement, secteur or Secteur" wiil not be considered

drop if (id_commune=="16.287" | id_commune=="22.282") & (tour==1) //Did not win in the first round


drop if libellédelacommune=="Lamballe - Maroué" //This city was merged with Lamballe-Ville. It does not exist in 2014

replace libellédelacommune="Lamballe" if libellédelacommune=="Lamballe - Ville" // Fusion of Lamballe - Maroué and Lamballe - Ville
replace id_commune="22.93" if id_commune=="22.093" //We manually fix a problematic id_commune
replace id_commune="35.68" if id_commune=="35.068" //We manually fix a problematic id_commune

replace libellédelacommune="Châteaubourg" if libellédelacommune=="Chateaubourg Centre" // We homogeneize names across datasets
replace id_commune="79.49" if id_commune=="79.049" //We manually fix a problematic id_commune

replace libellédelacommune="Bressuire" if id_commune=="79.49"  // We homogeneize names across datasets
drop if (id_commune=="28.279" & nom08=="") | (id_commune=="41.149" & nom08=="") //No information


drop if libellédelacommune=="Fort-Mardyck" | libellédelacommune=="Saint-Pol-sur-Mer" //The cities don't exist anymore, they joined Dunkerque

isid id_commune //Observations uiquely identified

save 2008_elections_complete.dta, replace

 ********************************************************************************
/* 2014 */
********************************************************************************
*********************FIRST ROUND*********************
 
 //Section 1)
 import delimited "2014-t1.txt",clear 
 

drop if libellédudépartement=="MAYOTTE" | libellédudépartement=="GUYANE" | libellédudépartement=="LA REUNION" | libellédudépartement=="POLYNESIE FRANCAISE" | libellédudépartement=="NOUVELLE CALEDONIE" | libellédudépartement=="MARTINIQUE" | libellédudépartement=="GUADELOUPE" | libellédudépartement=="SAINT PIERRE ET MIQUELON"  //We drop the départements d'Outre-mer
 
 
drop if inscrits<1000  // We drop the cities that don't meet our population criteria

generate id_commune=codedudépartement+"."+codedelacommune // We create a unique identifier for the observations:


drop datedelexpor abstentions inscrits absins votants votins blancsetnuls blnulsins blnulsvot exprimés expins expvot typedescrutin // We drop variables that we will not use

nmissing, min(7505)  //We delete the empty columns
drop `r(varlist)'
foreach var of varlist codenuance sexe nom prénom liste siègeselu siègessecteur siègescc voix voixins voixexp {
    rename `var' `var'1
} //We rename the variables so that we can then reshape the dataset from wide format to long format

//We rename the following variables using a loop:
forvalues i = 29(11)139 {
    if inlist(`i', 29, 40, 51, 62, 73, 84, 95, 106, 117, 128) {
        rename v`i' codenuance`=`i'-27'
        rename v`=`i'+1' sexe`=`i'-27'
        rename v`=`i'+2' nom`=`i'-27'
        rename v`=`i'+3' prénom`=`i'-27'
        rename v`=`i'+4' liste`=`i'-27'
        rename v`=`i'+5' siègeselu`=`i'-27'
        rename v`=`i'+6' siègessecteur`=`i'-27'
        rename v`=`i'+7' siègescc`=`i'-27'
        rename v`=`i'+8' voix`=`i'-27'
        rename v`=`i'+9' voixins`=`i'-27'
        rename v`=`i'+10' voixexp`=`i'-27'
    }
}


reshape long codenuance sexe nom prénom liste siègeselu siègessecteur siègescc voix voixins voixexp, i(id_commune) j(type) //From wide to long format 

drop if codenuance == "" //Empty observations created after the reshape
drop if voixexp == "" // 2 problematic obervations without information

drop type


destring voixexp, replace dpcomma //Same format across datasets
destring siègeselu, replace  //Same format across datasets
destring voixins, replace dpcomma //Same format across datasets


bys id_commune: gegen maxvote=max(voixexp) //We compute the candidate with the largest percentage of votes per city
bys id_commune: gegen maxsieges=max(siègeselu) //We compute the candidate that one the largest number of seats in the city

keep if voixexp==maxvote &  siègeselu==maxsieges //We keep the candidate with the most votes and most seats

keep if voixexp >50 //Since we are in the first round we will only keep candidates that got more than 50% of votes
gen tour=1 //First round



save 2014_t1.dta , replace

*********************SECOND ROUND********************
//Section 2)

import delimited "2014-t2.txt",clear

drop if libellédudépartement=="MAYOTTE" | libellédudépartement=="GUYANE" | libellédudépartement=="LA REUNION" | libellédudépartement=="POLYNESIE FRANCAISE" | libellédudépartement=="NOUVELLE CALEDONIE" | libellédudépartement=="MARTINIQUE" | libellédudépartement=="GUADELOUPE" | libellédudépartement=="SAINT PIERRE ET MIQUELON" //We drop the départements d'Outre-mer


 
drop if inscrits<1000  // We drop the cities that don't meet our population criteria


generate id_commune=codedudépartement+"."+codedelacommune // We create a unique identifier for the observations

drop datedelexpor abstentions inscrits absins votants votins blancsetnuls blnulsins blnulsvot exprimés expins expvot typedescrutin // We drop variables that we will not use

nmissing, min(1568)  
drop `r(varlist)'

foreach var of varlist codenuance sexe nom prénom liste siègeselu siègessecteur siègescc voix voixins voixexp {
    rename `var' `var'1
} //We rename the variables so that we can then reshape the dataset from wide format to long format

//We rename the following variables using a loop:
forvalues i = 29(11)139 {
    if inlist(`i', 29, 40, 51, 62) {
        rename v`i' codenuance`=`i'-27'
        rename v`=`i'+1' sexe`=`i'-27'
        rename v`=`i'+2' nom`=`i'-27'
        rename v`=`i'+3' prénom`=`i'-27'
        rename v`=`i'+4' liste`=`i'-27'
        rename v`=`i'+5' siègeselu`=`i'-27'
        rename v`=`i'+6' siègessecteur`=`i'-27'
        rename v`=`i'+7' siègescc`=`i'-27'
        rename v`=`i'+8' voix`=`i'-27'
        rename v`=`i'+9' voixins`=`i'-27'
        rename v`=`i'+10' voixexp`=`i'-27'
    }
}

reshape long codenuance sexe nom prénom liste siègeselu siègessecteur siègescc voix voixins voixexp, i(id_commune) j(type) //From wide to long format 

drop if codenuance == "" //Empty observations created after the reshape

drop type
destring siègeselu, replace //Same format across datasets
destring voixins, replace dpcomma //Same format across datasets
destring voixexp, replace dpcomma //Same format across datasets

bys id_commune: gegen maxvote=max(voixexp) //We compute the candidate with the largest percentage of votes per city
bys id_commune: gegen maxsieges=max(siègeselu) //We compute the candidate that one the largest number of seats in the city

keep if voixexp==maxvote &  siègeselu==maxsieges //We keep the candidate with the most votes and most seats

gen tour=2 // Second round
save 2014_t2.dta , replace

/* APPEND BOTH: */

//Section 3)

clear all

use 2014_t1 

append using 2014_t2

drop siègessecteur siègescc maxvote maxsieges

replace codedelacommune="283" if codedelacommune=="283SN01"	 //We manually fix a problematic id_commune
replace libellédelacommune="Oyonnax" if libellédelacommune=="Section 01 Oyonnax" //We manually fix a problematic city name

rename codenuance codenuance14
rename sexe sexe14
rename nom nom14
rename prénom prénom14
rename liste liste14
rename siègeselu sieges14
rename voix voix14
rename voixins voixins14
rename tour tour14
rename voixexp voixexp14

drop id_commune

replace codedelacommune = ustrregexrf(codedelacommune,"^0+","") //We modify codedelacommune so that is has the same format as in the 2008 dataset

replace codedudépartement = ustrregexrf(codedudépartement,"^0+","") //We modify codedudépartement so that is has the same format as in the 2008 dataset

gen id_commune=codedudépartement+"."+codedelacommune

save 2014_elections_complete.dta, replace

/*MERGING ALL ELECTION DATASETS: */

clear all

use 2008_elections_complete.dta

merge 1:1 id_commune using 2014_elections_complete, keep(3) //All cities from 2008 matched (the dataset with less data available)

//We edit codedudépartement et codedelacommune so that they follow the same format across our dataset
replace codedudépartement="0"+codedudépartement if (strlen(codedudépartement) <=1 ) 

replace codedelacommune="00"+codedelacommune if (strlen(codedelacommune) <=1 ) 
replace codedelacommune="0"+codedelacommune if (strlen(codedelacommune) <=2 &  strlen(codedelacommune) >1 )


generate code_insee=codedudépartement+codedelacommune // We create code_insee to merge with the other datasets

drop libellédudépartement codedudépartement codedelacommune nom08 prénom08 liste08 sieges08 voix08 voixins08 nom14 prénom14 liste14 sieges14 voix14 voixins14 _merge id_commune //We drop unnecessary variables

order code_insee, before(libellédelacommune)

xi i.sexe08 i.sexe14 i.tour08 i.tour14, noomit //We create the dummy variables for sex and round

rename (_Isexe08_1 _Isexe14_1 _Itour08_1 _Itour14_1) (femme_08 femme_14 tour_08 tour_14) // We rename the variables
 
drop _Isexe08_2 _Isexe14_2 _Itour08_2 _Itour14_2


// We create the political colors for 2008:

/*
Left-wing parties:
	LCOM: Communiste 
	LDVG: Divers gauche 
	LGC: gauche-centristes
	LSOC: Parti Socialiste (LEFT)
	LUG: union de la gauche (LEFT)
	LVEC:  Verts (LEFT)


Right-wing parties
	LDVD: Divers droite
	LMAJ: LUMP

Center parties:
	LMC: majorité-centristes
	LCMD: Mouvement démocrate

Other parties:
	LAUT: Autre liste (AUTRE)
	LREG:  régionaliste 
*/


gen color08="LEFT" if codenuance08=="LCOM" | codenuance08=="LDVG" | codenuance08=="LGC" | codenuance08=="LSOC" | codenuance08=="LUG" | codenuance08=="LVEC"
replace color08="RIGHT" if codenuance08=="LDVD" | codenuance08=="LMAJ"
replace color08="OTHER" if codenuance08=="LAUT" | codenuance08=="LREG"
replace color08="CENTER" if codenuance08=="LCMD"  | codenuance08=="LMC"

xi i.color08 //We create the dummies
drop _Icolor08_3  // We will only focus on right/left

rename (_Icolor08_2 _Icolor08_4) (left08 right08)




/*
We create the political colors for 2014:

Left-wing parties:
	LCOM: Communiste 
	LDVG: Divers gauche
	LFG: Front de Gauche
	LPG: Parti gauche
	LSOC: Parti Socialiste 
	LVEC : Verts 
	LUG: union de la gauche


Right-wing parties:
	LDVD: Divers droite
	LEXD: extreme droite
	LFN: Front National 
	LUD: Union de la droite
	LUDI: Union des Démocrates et des Indépendants
	LUMP: Union pour un Mouvement Populaire
Center parties:
	LMDM: Mouvement Démocrate
	LUC: Union du centre
	
Other parties:
	LDIV: Divers
*/


gen color14="LEFT" if codenuance14=="LCOM" | codenuance14=="LDVG" | codenuance14=="LPG" | codenuance14=="LSOC" | codenuance14=="LUG" | codenuance14=="LVEC" | codenuance14=="LFG"

replace color14="RIGHT" if codenuance14=="LDVD" | codenuance14=="LEXD" | codenuance14=="LFN"  | codenuance14=="LUD" | codenuance14=="LUDI"| codenuance14=="LUMP"
replace color14="OTHER" if codenuance14=="LDIV" 

replace color14="CENTER" if codenuance14=="LMDM"  | codenuance14=="LUC"

xi i.color14 //We create the dummies

drop _Icolor14_3  // We will only focus on right/left
rename (_Icolor14_2 _Icolor14_4 ) (left14 right14)

order color08 color14, after(right14)


save elections_checked, replace // Election data cleaned!

************************************************************************************************************
*****************************IMPORTING AND CLEANING REMAINING DATASETS *************************************
************************************************************************************************************


/*IMPORTING THE RPLS DATASET*/
import excel "resultats_rpls_2021_0.xlsx", sheet (Commune) clear

rename B pre_commune 
rename C code_insee
rename AB ensemble_parc_social_19
rename AH ensemble_parc_social_13
rename CG PLAI 
rename CH PLUS
rename CI PLS
rename CJ PLI 
rename DW avg_rent

drop in 1/4 // Droping first 4 lines 

/*Homogenizing cities' names with respect to other datasets */
replace pre_commune = substr(pre_commune,1, strpos(pre_commune, "(") - 1) if strpos(pre_commune, "(") > 0
gen commune = rtrim(pre_commune) 

keep commune code_insee ensemble_parc_social_19 ensemble_parc_social_13 PLAI PLUS PLS PLI avg_rent

destring ensemble_parc_social_19 ensemble_parc_social_13 PLAI PLUS PLS PLI avg_rent, replace 

duplicates drop code_insee, force //2 observations deleted 

label variable ensemble_parc_social_19 "Ensemble du parc social en 2019"
label variable ensemble_parc_social_13 "Ensemble du parc social en 2013"
label variable PLAI "Number of PLAI built in the last 5 years"
label variable PLUS "Number of PLUS built in the last 5 years"
label variable PLS "Number of PLS built in the last 5 years"
label variable PLI "Number of PLI built in the last 5 years"
label variable avg_rent "Average rent in overall housing in 2013"

save rpls2021clean.dta, replace 

/*résidences princpales*/ 
import excel "insee_rp_hist_1968.xlsx", clear

drop in 1/4
autorename  // autorename package allows to change first row of observations to variable names.

rename an année 
rename codgeo code_insee
rename libgeo commune

/*keep only observations for years 2013 and 2019*/
keep if année==2013 | année==2019

/* Reshape the data to wide format*/
reshape wide p_rp, i(code_insee) j(année)

/* Rename the variables to indicate the year*/
rename p_rp2013 logement_2013
rename p_rp2019 logement_2019

isid code_insee

save logementsnew.dta, replace 

/*base de recensement*/
use "bdcom20.dta", clear 

keep NCC COM TUU2010_RP17 PTOT13

rename COM code_insee
rename NCC commune 
rename TUU2010_RP17 size_agglomeration
rename PTOT13 pop13


drop if size_agglomeration =="Z" //4 observations deleted 
destring size_agglomeration, replace

save "census13.dta", replace 

/*Import the data for the cities budgets including results for the operative and invetment budgets*/
import delimited "comptes-individuels-des-communes-fichier-global-a-compter-de-2000.csv", clear

/*Format the department and commune codes so that the match the code_insee that we use to merge data with.*/
gen department = substr(dep, 2, .)
gen insee = string(icom, "%03.0f")
gen code_insee = department+insee

keep inom pop1 fres1 fres2 code_insee

duplicates drop code_insee, force

rename pop1 population
rename fres1 f_resultat_comptable
rename fres2 f_resultat_ensemble

label variable population "Population 2014"
label variable f_resultat_comptable "Operating Budget Result"
label variable f_resultat_ensemble "Investment Budget Result"

save budget.dta, replace

/*FILOSOFI 2013*/
/*Importing the Filosfi dataset that includes our varaibles for income based demographics.*/
import excel "filo-revenu-pauvrete-menage-2013.xls", clear

drop in 1/5 
autorename 

rename rd13 rd
rename codgeo code_insee
rename tp6013 povertyrate

label variable rd "D9/D1 ratio, the gap between the top (9th decile) and the bottom of the distribution (1st decile)"
label variable povertyrate "Poverty rate in the municipality, as defined by France Gouvernment"

keep code_insee povertyrate rd

save filosofi13, replace


/* Importing demographics data set, subset from the population census data. */
import excel "base-ic-couples-familles-menages-2013.xls", clear

drop in 1/5 
autorename

rename com code_insee

keep c13_fammono p13_pop1524 code_insee

label var c13_fammono "number of single-parent families"
label var p13_pop1524 "number of people aged 15 to 24"

duplicates drop code_insee, force

save demographics1.dta, replace


/*UNEMPLOYMENT*/

import excel "BTX_TD_IMG2A_2013.xls", clear

drop in 1/10

autorename

/*Keeping the varaibles that have tactr12 (indicatior for being unemployed)*/
keep sexe1_age4_a15_immi1_tactr12 sexe1_age4_a15_immi2_tactr12 sexe1_age4_a25_immi1_tactr12 sexe1_age4_a25_immi2_tactr12 sexe1_age4_a55_immi1_tactr12 sexe1_age4_a55_immi2_tactr12 sexe2_age4_a15_immi1_tactr12 sexe2_age4_a15_immi2_tactr12 sexe2_age4_a25_immi1_tactr12 sexe2_age4_a25_immi2_tactr12 sexe2_age4_a55_immi1_tactr12 sexe2_age4_a55_immi2_tactr12 codgeo

/*Creating variable for amount of unemployed persons above 15 in each municipality*/
egen unemployed = rowtotal(sexe1_age4_a15_immi1_tactr12 sexe1_age4_a15_immi2_tactr12 sexe1_age4_a25_immi1_tactr12 sexe1_age4_a25_immi2_tactr12 sexe1_age4_a55_immi1_tactr12 sexe1_age4_a55_immi2_tactr12 sexe2_age4_a15_immi1_tactr12 sexe2_age4_a15_immi2_tactr12 sexe2_age4_a25_immi1_tactr12 sexe2_age4_a25_immi2_tactr12 sexe2_age4_a55_immi1_tactr12 sexe2_age4_a55_immi2_tactr12)

/*Dropping the remaining varaibles as we only want to keep number of unemployed.*/
drop sexe1_age4_a15_immi1_tactr12 sexe1_age4_a15_immi2_tactr12 sexe1_age4_a25_immi1_tactr12 sexe1_age4_a25_immi2_tactr12 sexe1_age4_a55_immi1_tactr12 sexe1_age4_a55_immi2_tactr12 sexe2_age4_a15_immi1_tactr12 sexe2_age4_a15_immi2_tactr12 sexe2_age4_a25_immi1_tactr12 sexe2_age4_a25_immi2_tactr12 sexe2_age4_a55_immi1_tactr12 sexe2_age4_a55_immi2_tactr12
rename codgeo code_insee

duplicates drop code_insee, force // note how many observations were dropped, what where they, justification for dropping them?

save demographics2.dta, replace

// SRU DATA
import delimited "transparence-sru-sans-doublon.csv", clear // we might have to get rid of this one, do it the "zoe way"
		
rename code code_insee
rename info comply

keep comply code_insee

label variable comply "Indication if municipality is complying, not complying, exempted or not concerned"

save sru_comply.dta, replace


************************************************************************************************************
************************************ MERGING ALL DASASETS **************************************************
************************************************************************************************************


use rpls2021clean.dta, clear

merge 1:1 code_insee using filosofi13

drop _merge

merge 1:1 code_insee using census13 

drop _merge

merge 1:1 code_insee using elections_checked.dta

drop _merge

merge 1:1 code_insee using logementsnew.dta

drop _merge

merge 1:1 code_insee using budget 

drop _merge

merge 1:1 code_insee using demographics1 

drop _merge

merge 1:1 code_insee using demographics2 

drop _merge

merge 1:1 code_insee using sru_comply

drop _merge

/*Filtering out municipalites who are not concerned or exempted by the SRU Law.*/
keep if comply == "Ma commune remplit en 2020 ses obligations en matière de logements sociaux." | comply == "Ma commune ne remplit pas en 2020 ses obligations en matière de logements sociaux." 


/*As the muncipalites variy in size we standarzie the amount of single parent families, population between 15-24 and unemployed people and divide by the total for their municipality population*/  
generate single_parent_family = c13_fammono/pop13
generate pop_15_24 = p13_pop1524/pop13
generate unemploymentrate = unemployed/pop13
generate populationgrowth = (population-pop13)/pop13

/*Creating share of housing variables by dividing with total housing types.*/
gen total_types_logements = PLAI + PLUS + PLS + PLI 
gen share_PLAI = PLAI / total_types_logements
gen share_PLUS = PLUS / total_types_logements
gen share_PLS = PLS / total_types_logements
gen share_PLI = PLI / total_types_logements


/*Creating our dependent variable: evolution of social housing between 2013 and 2019, in percentage point */
gen percSH13 = ensemble_parc_social_13 / logement_2013
gen percSH19 = ensemble_parc_social_19 / logement_2019
gen evolSH = percSH19 - percSH13

/*CREATING REQUIRED DUMMIES*/

/*Dummy for non compliance in 2013*/
gen nc13 = 0 
replace nc13 = 1 if percSH13 < 0.2

/*Dummies for interaction term: political color and compliance in 2013*/
gen leftnc = nc13*left14
gen rightnc = nc13*right14

label variable nc13 "The city doesn't comply in 2013"
label variable leftnc "Interaction term, non compliance in 2013 x Left wing mayor in 2014"
label variable rightnc "Interaction term, non compliance in 2013 x Right wing mayor in 2014"

/*Dummy representing a switch in political color*/
generate change=0
replace change=1 if color08!=color14

generate left_right=0
replace left_right=1 if left08==1 & right14==1

generate right_left=0
replace right_left=1 if left14==1 & right08==1

 
/*dummies for political leverage associated to political color : i'll use this one for the follwoing stat: does having more political leverage accentuate mayors' decision on socila housing, conditonning on their political color*/
gen leftlev = voixexp14*left14 
gen rightlev = voixexp14*right14


/*saving the fininshed version of our dataset*/

save sru_database_final, replace
summarize

************************************************************************************************************
************************************DESCRIPTIVE STATISTICS**************************************************
************************************************************************************************************

/*Getting a first overview of our research question */


/*Evolution of the percentage of social housing in cities that did not comply at baseline (2013)*/
twoway (histogram evolSH if left14==1 & nc13==1, color(red%30)) ///        
       (histogram evolSH if right14==1 & nc13==1, color(blue%30)), ///   
       legend(order(1 "Left" 2 "Right" ) title (Evolution (in %) in non complier cities))
	   
/*Evolution of the percentage of social housing in cities that did comply at baseline (2013)*/
twoway (histogram evolSH if left14==1 & nc13==0, color(red%30)) ///        
       (histogram evolSH if right14==1 & nc13==0, color(blue%30)), ///   
       legend(order(1 "Left" 2 "Right" ) title (Evolution (in %) in complier cities))   
/*The difference in evolution of percentage of social housing is mainly observable among complier cities at baseline.*/

/*Correlation tables: evolution of the percentage of social housing / right14*/
pwcorr evolSH right14, sig
pwcorr evolSH right14 if evolSH > 0
/*Interpretation: among cities who increased their percentage of socil housing in the tim eperiod, there is negative correlation between the evolution of this percentage and being a right wing mayor. Among cities who increased their percentage of social housing, the mayor is more likely to be left wing*/


/*We want to check the hypothesis according to which right wing mayors tend to increase PLS social housing in priority, offering social housing to higher income households than if they would invest in PLAI, PLI and PLUS housing.*/
graph pie share_PLS share_PLUS share_PLI share_PLAI if right14==1
graph pie share_PLS share_PLUS share_PLI share_PLAI if right14==0

pwcorr share_PLS right14, sig


/*Is poverty rate correlated with the evolution of the percentage in social housing?*/
twoway scatter povertyrate evolSH if right14==1 || lfit povertyrate evolSH
twoway scatter povertyrate evolSH if left14==1 || lfit povertyrate evolSH


/*We hyppothesize that for the higher the political leverage, the stronger are the decisions of a mayor. Therefore, for left wing cities, the evolution in the percentage of social housing should be higher when the mayor has a greater share of seats in the council.*/
twoway scatter leftlev evolSH || lfit leftlev evolSH


************************************************************************************************************
***************************************REGRESSION ANALYSIS**************************************************
************************************************************************************************************


// Our regression, starting with a naive one and then sequentially adding controls.
summarize
reg evolSH right14 rightnc nc13, vce(robust)

reg evolSH right14 rightnc nc13 left_right right_left, vce(robust) 

reg evolSH right14 rightnc nc13 left_right right_left rightlev, vce(robust) 

reg evolSH right14 rightnc nc13 left_right right_left rightlev povertyrate rd, vce(robust) 

reg evolSH right14 rightnc nc13 left_right right_left rightlev povertyrate rd unemploymentrate pop_15_24 single_parent_family, vce(robust)

reg evolSH right14 rightnc nc13 left_right right_left rightlev povertyrate rd unemploymentrate pop_15_24 single_parent_family avg_rent, vce(robust)

reg evolSH right14 rightnc nc13 left_right right_left rightlev povertyrate rd unemploymentrate pop_15_24 single_parent_family avg_rent f_resultat_comptable f_resultat_ensemble, vce(robust)

reg evolSH right14 rightnc nc13 left_right right_left rightlev povertyrate rd unemploymentrate pop_15_24 single_parent_family avg_rent f_resultat_comptable f_resultat_ensemble populationgrowth, vce(robust)

/* We end up not controlling for share_PLS as we lose 100+ observations and with our small sample size we prefer to keep as many observations as possible.
reg evolSH right14 rightnc nc13 left_right right_left rightlev povertyrate rd unemploymentrate pop_15_24 single_parent_family avg_rent f_resultat_comptable f_resultat_ensemble populationgrowth share_PLS, vce(robust)
*/


//// Exporting our regression table.
reg evolSH right14 rightnc nc13, vce(robust)
outreg2 using reg1, tex

reg evolSH right14 rightnc nc13 left_right right_left, vce(robust) 
outreg2 using reg1, tex append

reg evolSH right14 rightnc nc13 left_right right_left rightlev, vce(robust) 
outreg2 using reg1, tex append

reg evolSH right14 rightnc nc13 left_right right_left rightlev povertyrate rd, vce(robust) 
outreg2 using reg1, tex append

reg evolSH right14 rightnc nc13 left_right right_left rightlev povertyrate rd unemploymentrate pop_15_24 single_parent_family, vce(robust)
outreg2 using reg1, tex append

reg evolSH right14 rightnc nc13 left_right right_left rightlev povertyrate rd unemploymentrate pop_15_24 single_parent_family avg_rent, vce(robust)
outreg2 using reg1, tex append

reg evolSH right14 rightnc nc13 left_right right_left rightlev povertyrate rd unemploymentrate pop_15_24 single_parent_family avg_rent f_resultat_comptable f_resultat_ensemble, vce(robust)
outreg2 using reg1, tex append

reg evolSH right14 rightnc nc13 left_right right_left rightlev povertyrate rd unemploymentrate pop_15_24 single_parent_family avg_rent f_resultat_comptable f_resultat_ensemble populationgrowth, vce(robust)
outreg2 using reg1, tex append

/* We end up not controlling for share_PLS as we lose 100+ observations and with our small sample size we prefer to keep as many observations as possible.
reg evolSH right14 rightnc nc13 left_right right_left rightlev povertyrate rd unemploymentrate pop_15_24 single_parent_family avg_rent f_resultat_comptable f_resultat_ensemble populationgrowth share_PLS, vce(robust)
outreg2 using reg1, tex append
*/




log close // LAST LINE



