//==============================================================================
//	READ 2011 MERGED DATA 
//==============================================================================
//  Instructions:
//------------------------------------------------------------------------------
//  (1) Download all codes to <C:\ihds> folder and run from there.
//  (2) This program uses the STATA SUPPLEMENTAL SYNTAX FILE FOR ICPSR 
//  	  provided by https://www.icpsr.umich.edu/ to read the IHDS-I Survey on
//  	  Individuals, Households, and Villages; and treat missing values.
//==============================================================================
//	Written	by Suresh Paul, Algorithm Basics LLC, sureshlazaruspaul@gmail.com
//	version: 06/04/2023
//==============================================================================


clear all 
capture log close 
set more off 


//------------------------------------------------------------------------------
// set dir for data
//------------------------------------------------------------------------------

local dirpath "C:\ihds"

cd `dirpath'



//------------------------------------------------------------------------------
// Some Macros: 
//	Program append2empty: append to an empty dataset 
//	Program pe: Print Execute with loops
//------------------------------------------------------------------------------

capture program drop append2empty
program define append2empty
	tempvar qwerty // create tempvars 
		gen `qwerty' = 1
	append using `1' // append all datasets  
end 
/*------------------------------------------------------------------------------
clear
append_empty somedataset
------------------------------------------------------------------------------*/

program define pe
	if `"`0'"' != " " {
		display as text `"`0'"'
		`0'
		display("")
	}
end



//------------------------------------------------------------------------------
// Github url
//------------------------------------------------------------------------------

local giturl = "https://raw.githubusercontent.com/sureshlazaruspaul/ihds/main" 



//------------------------------------------------------------------------------
// run 2011 files (individuals, households, village, school) ... 
//------------------------------------------------------------------------------

do "`giturl'/stata-codes/36151-0001-Data.do" // individual file ...

do "`giturl'/stata-codes/36151-0002-Data.do" // household file ...

do "`giturl'/stata-codes/36151-0009-Data.do" // school file ...

do "`giturl'/stata-codes/36151-0012-Data.do" // village file ...

do "`giturl'/stata-codes/22626-0007-Data.do" // 2005 village file ...

//------------------------------------------------------------------------------
// open logfile ... 
//------------------------------------------------------------------------------

log using "C:\ihds\36151", replace


//------------------------------------------------------------------------------
// calc Father's Education ... 
//------------------------------------------------------------------------------

use "`dirpath'\36151-0001-Data_out.dta" , clear 

keep idhh personid ed5x
drop if missing( personid ) | missing( ed5x )

rename (personid ed5x) (fatherid feduc) 

sort idhh fatherid feduc // remove duplicates by all 
	qui by idhh fatherid feduc: gen dup = cond(_n==1, 0, _n) 
	drop if dup > 0
	drop dup 

sort idhh fatherid feduc // remove duplicates by idhh fatherid 
	quietly by idhh fatherid: gen dup = cond(_n==1, 0, _n) 
	drop if dup > 0
	drop dup 

sort idhh fatherid feduc

save feduc, replace

//------------------------------------------------------------------------------
// calc Mother's Education ... 
//------------------------------------------------------------------------------

use "`dirpath'\36151-0001-Data_out.dta" , clear 

keep idhh personid ed5x
drop if missing( personid ) | missing( ed5x )

rename (personid ed5x) (motherid meduc) 

sort idhh motherid meduc // remove duplicates by all 
	qui by idhh motherid meduc: gen dup = cond(_n==1, 0, _n) 
	drop if dup > 0
	drop dup 

sort idhh motherid meduc // remove duplicates by idhh motherid  
	quietly by idhh motherid: gen dup = cond(_n==1, 0, _n) 
	drop if dup > 0
	drop dup 

sort idhh motherid meduc

save meduc, replace



//------------------------------------------------------------------------------
// Open INDIVIDUAL FILE
//------------------------------------------------------------------------------

use "`dirpath'\36151-0001-Data_out.dta" , clear 

sort idhh fatherid

merge m:1 idhh fatherid using feduc
drop if _merge == 2 // left join 
drop _merge 


capture confirm file feduc.dta

** .. if it does, delete program
if _rc == 0 {
    di "file exists, deleting ..."
    erase feduc.dta
}

** .. else, show error code (but continue)
else {
    capture noisily error _rc
    di "file keeps running though..."
}

sort idhh motherid

merge m:1 idhh motherid using meduc
drop if _merge == 2 // left join 
drop _merge 

capture confirm file meduc.dta

** .. if it does, delete program
if _rc == 0 {
    di "file exists, deleting ..."
    erase meduc.dta
}

** .. else, show error code (but continue)
else {
    capture noisily error _rc
    di "file keeps running though..."
}


//------------------------------------------------------------------------------

sort idhh

merge m:1 idhh using "`dirpath'/36151-0002-data_out.dta" 
	drop if _merge == 2 // left join household file
	rename _merge _merge_ih 

sort idpsu 

merge m:1 idpsu using "`dirpath'/36151-0009-data_out.dta" 
	drop if _merge == 2 // left join school facilities file
	rename _merge _merge_ihs 

sort idvillage 

merge m:1 idvillage using "`dirpath'/36151-0012-data_out.dta" 
	drop if _merge == 2 // left join village file
	rename _merge _merge_ihsv

sort idvillage 

merge m:1 idvillage using "`dirpath'/22626-0007-Data_out.dta" 
	drop if _merge == 2 // left join village file
	drop _merge // firewood_prc2005 fyrelec2005 healthsubcenter2005 kerosene_prc2005 safewater2005 sanitation2005



//------------------------------------------------------------------------------

g hhid12 = hhid 
g hhsplitid12 = hhsplitid

sort stateid distid psuid hhid12 hhsplitid12 

merge m:1 stateid distid psuid hhid12 hhsplitid12 using "`giturl'/stata-codes/electricity2005.dta?raw=true"
	drop if _merge == 2 // left join 2005 electricity file
	drop _merge hhid12 hhsplitid12


g baseyear = 2012

rename *, lower


//------------------------------------------------------------------------------

sort stateid distid

merge m:1 stateid distid using "https://github.com/sureshlazaruspaul/ihds/blob/main/stata-codes/census_elec.dta?raw=true"
	drop if _merge == 2 // left join census and electricity data
	rename _merge _merge_census 

//------------------------------------------------------------------------------

tab fu1 fu12005 , missing // diagnostics 

//------------------------------------------------------------------------------
// transform/calculate variables ... 
//------------------------------------------------------------------------------
/*
replace ed3x = 1 - ed3x // Attend School
*/

g byte perfectat = inlist( cs11x, 0 ) 
	replace perfectat = . if missing( cs11x )
	tab perfectat , missing 

g byte goodat = inrange( cs11x, 0, 2 ) 
	replace goodat = . if missing( cs11x )
	tab goodat , missing 

g hhassets1 = ln(hhassets) 
g income1 = ln(income) 
g incomepc1 = ln(incomepc) 
g copc1 = ln(copc) 


g wkany1 = 0 
replace wkany1 = 1 if inlist( wkany , 3, 4 )  
replace wkany1 = . if inlist( wkany , 1 ) | missing( wkany )

tab wkany1 wkany , missing // diagnostics 
 

g byte female = inlist( ro3x , 2 )
replace female = . if missing( ro3x )

tab female ro3x , missing // diagnostics 


g byte hhhead = inlist( ro4x , 1 )
replace hhhead = . if missing( ro4x )

tab hhhead ro4x , missing // diagnostics 


g byte married = inlist( ro6x , 1 )
replace married = . if missing( ro6x )

tab married ro6x , missing // diagnostics 


//------------------------------------------------------------------------------
********** caste and religion definitions
//------------------------------------------------------------------------------

g byte brahmin = 0 
replace brahmin = 1 if groups8x == 1 
replace brahmin = . if missing( groups8x )

g byte forward = 0 
replace forward = 1 if groups8x == 2 
replace forward = . if missing( groups8x )

g byte othback = 0 
replace othback = 1 if groups8x == 3 
replace othback = . if missing( groups8x )

g byte dalit = 0 
replace dalit = 1 if groups8x == 4 
replace dalit = . if missing( groups8x )

g byte adivasi = 0 
replace adivasi = 1 if groups8x == 5 
replace adivasi = . if missing( groups8x )

g byte muslim = 0 
replace muslim = 1 if groups8x == 6 
replace muslim = . if missing( groups8x )

g byte csj = 0 
replace csj = 1 if groups8x == 7 
replace csj = . if missing( groups8x )

//------------------------------------------------------------------------------
********** electricity & electricity payment method 
//------------------------------------------------------------------------------

g byte elecfree = 0 
replace elecfree = 1 if inlist( fu1b , 1 )
replace elecfree = . if missing( fu1b )

tab fu1b elecfree , missing // diagnostics 


g byte elecpay = 0 
replace elecpay = 1 if inlist( fu1b , 2, 3, 4 )  
replace elecpay = . if missing( fu1b )

tab fu1b elecpay , missing // diagnostics 


g byte elecoth = 0 
replace elecoth = 1 if inlist( fu1b , 5, 6, 7, 8 )  
replace elecoth = . if missing( fu1b )

tab fu1b elecoth , missing // diagnostics 


egen median_fu1a = median(fu1a) 
g byte elecqual1 = cond(missing(fu1a), ., (fu1a > median_fu1a)) 
g byte elecqual2 = cond(missing(fu1a), ., (fu1a > hourselec)) 
	drop median_fu1a

tab elecqual1 , missing // diagnostics 
tab elecqual2 , missing // diagnostics 
tab elecqual1 elecqual2 , missing // diagnostics 


g byte elecqual3 = inlist(fu1, 1) 
	replace elecqual3 = 2 if inlist(fu1, 1) & inrange(fu1a, 19, 24) 
	replace elecqual3 = . if missing(fu1) 

tab elecqual3 , missing // diagnostics 
tab fu1  elecqual3 , missing // diagnostics 
tab fu1a elecqual3 , missing // diagnostics 


g byte elecqual4 = inlist(fu1, 1) 
	replace elecqual4 = 2 if inlist(fu1, 1) & inrange(fu1a, 17, 24) 
	replace elecqual4 = . if missing(fu1) 

tab elecqual4 , missing // diagnostics 
tab fu1  elecqual4 , missing // diagnostics 
tab fu1a elecqual4 , missing // diagnostics 


g byte elecqual5 = inlist(fu1, 1) 
	replace elecqual5 = 2 if inlist(fu1, 1) & (fu1a > hourselec) 
	replace elecqual5 = . if missing(fu1) 

tab elecqual5 , missing // diagnostics 
tab fu1  elecqual5 , missing // diagnostics 
tab fu1a elecqual5 , missing // diagnostics 


save temp , replace 


//------------------------------------------------------------------------------
// calc HHHead's Education ... 
//------------------------------------------------------------------------------

use temp, clear

keep if inlist( hhhead, 1 )

keep idhh ed5x female age

sort idhh ed5x female age // remove duplicates by all 
	quietly by idhh ed5x female age: gen dup = cond(_N==1, 0, _n) 
	drop if dup > 0
	drop dup 

gsort idhh -age // remove duplicates by IDHH   
	quietly by idhh : gen dup = cond(_N==1, 0, _n) 
	drop if dup > 1 // keep the older HHHead 
	drop dup 

sort idhh // remove duplicates by IDHH   
	quietly by idhh : gen dup = cond(_N==1, 0, _n) 
	drop if dup > 0
	drop dup 

rename (ed5x female age) (hheduc hhfemale hhage)

sort idhh 

save hheduc , replace

//------------------------------------------------------------------------------
// merge back to temp data ... 
//------------------------------------------------------------------------------

use temp , clear

sort idhh 

merge m:1 idhh using hheduc
	drop if _merge == 2 // left join 
	drop _merge 


capture confirm file hheduc.dta

** .. if it does, delete program
if _rc == 0 {
    di "File exists, deleting ..."
    erase hheduc.dta
}

** .. else, show error code (but continue)
else {
    capture noisily error _rc
    di "File keeps running though..."
}

tab hhfemale , missing // diagnostics 
tab hhhead , missing // diagnostics 



g byte privsch = inlist( cs3x, 4 )
replace privsch = . if missing( cs3x )

tab cs3x privsch, missing // diagnostics 



g byte teacher_absence = inlist( ch6 , 2, 3 ) 
replace teacher_absence = . if missing( ch6 )

tab ch6 teacher_absence , missing // diagnostics 



gen byte adolescents = inrange( age, 8, 11 ) // adolescents
	replace adolescents = . if missing( age ) 
	tab adolescents , missing

gen byte read = inlist( ta7lvl, 3, 4 )
	replace read = . if missing( ta7lvl ) 
	tab read ta7lvl , missing 

gen byte write = inlist( ta9lvl, 1, 2 )
	replace write = . if missing( ta9lvl ) 
	tab write ta9lvl , missing 

gen byte math = inlist( ta8lvl, 2, 3 )
	replace math = . if missing( ta8lvl ) 
	tab math ta8lvl , missing 


gen byte agematch_ed5x = 1 // age-grade match using ed5x 
	replace agematch_ed5x = 0 if !missing( ed5x ) & age - ed5x > 6
	replace agematch_ed5x = . if  missing( ed5x ) | age - ed5x < 4 

gen byte agematch_cs5x = 1 // age-grade match using cs5x 
	replace agematch_cs5x = 0 if !missing( cs5x ) & age - cs5x > 6
	replace agematch_cs5x = . if  missing( cs5x ) | age - cs5x < 4 

recode urban (0 = 1) (1 = 0), gen( rural ) // rural dummy
	tab rural urban , missing

recode female (0 = 1) (1 = 0), gen( male ) // male dummy 
	tab male female , missing 

//------------------------------------------------------------------------------

// transmission length density: length of transmission lines per square kilometer
gen tlinesdensity1 = lengthlines / area_sqkm 
	replace tlinesdensity1 = . if missing( lengthlines ) | missing( area_sqkm )
	sum tlinesdensity1 , detail
	nmissing tlinesdensity1 

// transmission length density: length of transmission lines per capita
gen tlinesdensity2 = lengthlines / pop 
	replace tlinesdensity2 = . if missing( lengthlines ) | missing( pop )
	sum tlinesdensity2 , detail
	nmissing tlinesdensity2 

//------------------------------------------------------------------------------
// combining states ... 
//		- to few sample between
//------------------------------------------------------------------------------

clonevar stid = stateid // make orginal copy ... 

tabulate stid // before combining states ... 

// 1. combine all northeast states 
// Arunachal, Meghalaya, Manipur, Nagaland, Tripura, Sikkim, & Mizoram ---> with Assam 

replace stid = 18 if inlist( stid, 12, 17, 14, 13, 16, 11, 15 ) 

// 2. combine Dadra Nagar Haveli & Goa ---> with Maharastra

replace stid = 27 if inlist( stid, 26, 30 ) 

// 3. combine Daman Diu ---> with Gujarat

replace stid = 24 if inlist( stid, 25 ) 

// 4. combine Pondicherry ---> with Tamil Nadu

replace stid = 33 if inlist( stid, 34 ) 

tabulate stid // after combining states ... 




// region names ... 
gen     region = "N"  if stateid == 1
replace region = "N"  if stateid == 2
replace region = "N"  if stateid == 3
replace region = "N"  if stateid == 4
replace region = "N"  if stateid == 5
replace region = "N"  if stateid == 6
replace region = "N"  if stateid == 7
replace region = "N"  if stateid == 8
replace region = "N"  if stateid == 9
replace region = "E"  if stateid == 10
replace region = "E"  if stateid == 11
replace region = "NE" if stateid == 12
replace region = "NE" if stateid == 13
replace region = "NE" if stateid == 14
replace region = "NE" if stateid == 15
replace region = "NE" if stateid == 16
replace region = "NE" if stateid == 17
replace region = "NE" if stateid == 18
replace region = "E"  if stateid == 19
replace region = "E"  if stateid == 20
replace region = "E"  if stateid == 21
replace region = "W"  if stateid == 22
replace region = "W"  if stateid == 23
replace region = "W"  if stateid == 24
replace region = "W"  if stateid == 25
replace region = "W"  if stateid == 26
replace region = "W"  if stateid == 27
replace region = "S"  if stateid == 28
replace region = "S"  if stateid == 29
replace region = "W"  if stateid == 30
replace region = "S"  if stateid == 31
replace region = "S"  if stateid == 32
replace region = "S"  if stateid == 33
replace region = "S"  if stateid == 34
replace region = "S"  if stateid == 35
	label variable region "region names" 

gen byte regid = . 
replace regid = 1 if inlist( region , "N" )
replace regid = 2 if inlist( region , "W" )
replace regid = 3 if inlist( region , "E" )
replace regid = 4 if inlist( region , "NE" )
replace regid = 5 if inlist( region , "S" )
	label variable regid "region dummy" 




// literacy rate from census ... 
gen     litrate = . 
replace litrate = 67.2 if inlist( stateid ,  1 ) 
replace litrate = 82.8 if inlist( stateid ,  2 ) 
replace litrate = 75.8 if inlist( stateid ,  3 ) 
replace litrate = 78.8 if inlist( stateid ,  5 ) 
replace litrate = 75.6 if inlist( stateid ,  6 ) 
replace litrate = 86.2 if inlist( stateid ,  7 ) 
replace litrate = 66.1 if inlist( stateid ,  8 ) 
replace litrate = 67.7 if inlist( stateid ,  9 ) 
replace litrate = 61.8 if inlist( stateid , 10 ) 
replace litrate = 81.4 if inlist( stateid , 11 ) 
replace litrate = 65.4 if inlist( stateid , 12 ) 
replace litrate = 79.6 if inlist( stateid , 13 ) 
replace litrate = 79.2 if inlist( stateid , 14 ) 
replace litrate = 91.3 if inlist( stateid , 15 ) 
replace litrate = 87.2 if inlist( stateid , 16 ) 
replace litrate = 74.4 if inlist( stateid , 17 ) 
replace litrate = 72.2 if inlist( stateid , 18 ) 
replace litrate = 76.3 if inlist( stateid , 19 ) 
replace litrate = 66.4 if inlist( stateid , 20 ) 
replace litrate = 72.9 if inlist( stateid , 21 ) 
replace litrate = 70.3 if inlist( stateid , 22 ) 
replace litrate = 69.3 if inlist( stateid , 23 ) 
replace litrate = 78.0 if inlist( stateid , 24 ) 
replace litrate = 87.1 if inlist( stateid , 25 ) 
replace litrate = 76.2 if inlist( stateid , 26 ) 
replace litrate = 82.3 if inlist( stateid , 27 ) 
replace litrate = 67.0 if inlist( stateid , 28 ) 
replace litrate = 75.4 if inlist( stateid , 29 ) 
replace litrate = 88.7 if inlist( stateid , 30 ) 
replace litrate = 94.0 if inlist( stateid , 32 ) 
replace litrate = 80.1 if inlist( stateid , 33 ) 
replace litrate = 85.8 if inlist( stateid , 34 ) 
	format  litrate %29.2fc 
	label variable litrate "census literacy rate (2001/2011)" 




// gross enrollment ratio for higher education, 2011 ... 
gen     gerhe11 = . 
replace gerhe11 = 16.8 if inlist( stateid ,  1 ) 
replace gerhe11 = 26.0 if inlist( stateid ,  2 ) 
replace gerhe11 = 19.4 if inlist( stateid ,  3 ) 
replace gerhe11 = 27.8 if inlist( stateid ,  5 ) 
replace gerhe11 = 24.1 if inlist( stateid ,  6 ) 
replace gerhe11 = 32.5 if inlist( stateid ,  7 ) 
replace gerhe11 = 18.2 if inlist( stateid ,  8 ) 
replace gerhe11 = 16.3 if inlist( stateid ,  9 ) 
replace gerhe11 = 10.5 if inlist( stateid , 10 ) 
replace gerhe11 = 24.2 if inlist( stateid , 11 ) 
replace gerhe11 = 26.9 if inlist( stateid , 12 ) 
replace gerhe11 = 21.5 if inlist( stateid , 13 ) 
replace gerhe11 = 35.9 if inlist( stateid , 14 ) 
replace gerhe11 = 21.6 if inlist( stateid , 15 ) 
replace gerhe11 = 13.6 if inlist( stateid , 16 ) 
replace gerhe11 = 17.5 if inlist( stateid , 17 ) 
replace gerhe11 = 13.4 if inlist( stateid , 18 ) 
replace gerhe11 = 12.4 if inlist( stateid , 19 ) 
replace gerhe11 = 08.1 if inlist( stateid , 20 ) 
replace gerhe11 = 16.1 if inlist( stateid , 21 ) 
replace gerhe11 = 13.6 if inlist( stateid , 22 ) 
replace gerhe11 = 13.6 if inlist( stateid , 23 ) 
replace gerhe11 = 21.3 if inlist( stateid , 24 ) 
replace gerhe11 = 03.5 if inlist( stateid , 25 ) 
replace gerhe11 = 03.6 if inlist( stateid , 26 ) 
replace gerhe11 = 27.6 if inlist( stateid , 27 ) 
replace gerhe11 = 28.4 if inlist( stateid , 28 ) 
replace gerhe11 = 25.5 if inlist( stateid , 29 ) 
replace gerhe11 = 33.2 if inlist( stateid , 30 ) 
replace gerhe11 = 21.9 if inlist( stateid , 32 ) 
replace gerhe11 = 32.9 if inlist( stateid , 33 ) 
replace gerhe11 = 31.2 if inlist( stateid , 34 ) 
	format  gerhe11 %29.2fc 
	label variable gerhe11 "gross enrollment ratio for higher education, 2011" 




// number of colleges per lakh population, 2011 ... 
gen     ncoll11 = . 
replace ncoll11 = 14 if inlist( stateid ,  1 ) 
replace ncoll11 = 38 if inlist( stateid ,  2 ) 
replace ncoll11 = 29 if inlist( stateid ,  3 ) 
replace ncoll11 = 28 if inlist( stateid ,  5 ) 
replace ncoll11 = 33 if inlist( stateid ,  6 ) 
replace ncoll11 = 08 if inlist( stateid ,  7 ) 
replace ncoll11 = 29 if inlist( stateid ,  8 ) 
replace ncoll11 = 17 if inlist( stateid ,  9 ) 
replace ncoll11 = 05 if inlist( stateid , 10 ) 
replace ncoll11 = 14 if inlist( stateid , 11 ) 
replace ncoll11 = 11 if inlist( stateid , 12 ) 
replace ncoll11 = 20 if inlist( stateid , 13 ) 
replace ncoll11 = 23 if inlist( stateid , 14 ) 
replace ncoll11 = 21 if inlist( stateid , 15 ) 
replace ncoll11 = 08 if inlist( stateid , 16 ) 
replace ncoll11 = 16 if inlist( stateid , 17 ) 
replace ncoll11 = 13 if inlist( stateid , 18 ) 
replace ncoll11 = 08 if inlist( stateid , 19 ) 
replace ncoll11 = 05 if inlist( stateid , 20 ) 
replace ncoll11 = 23 if inlist( stateid , 21 ) 
replace ncoll11 = 20 if inlist( stateid , 22 ) 
replace ncoll11 = 23 if inlist( stateid , 23 ) 
replace ncoll11 = 27 if inlist( stateid , 24 ) 
replace ncoll11 = 07 if inlist( stateid , 25 ) 
replace ncoll11 = 09 if inlist( stateid , 26 ) 
replace ncoll11 = 35 if inlist( stateid , 27 ) 
replace ncoll11 = 48 if inlist( stateid , 28 ) 
replace ncoll11 = 44 if inlist( stateid , 29 ) 
replace ncoll11 = 25 if inlist( stateid , 30 ) 
replace ncoll11 = 29 if inlist( stateid , 32 ) 
replace ncoll11 = 27 if inlist( stateid , 33 ) 
replace ncoll11 = 54 if inlist( stateid , 34 ) 
	format  ncoll11 %29.2fc 
	label variable ncoll11 "number of colleges per lakh population, 2011" 



// ranking for states ... 

gen sno = -ncoll11 // based on number of colleges per lakh population, 2011
	sort sno

egen rank_ncolleges = group( sno )
	label variable rank_ncolleges "ranking - number of colleges per lakh eligible population, 2011" 

gen byte top5states_ncolleges = inlist( rank_ncolleges , 1 , 2 , 3 , 4 , 5 )  
	label variable top5states_ncolleges "top 5 states - number of colleges per lakh eligible population, 2011" 


//------------------------------------------------------------------------------
// label values ... 
//------------------------------------------------------------------------------

label define yesno 0 "NO" 1 "YES" , replace

local yesnovars adivasi adolescents agematch_ed5x agematch_cs5x brahmin csj dalit elecfree elecoth elecpay elecqual1 elecqual2 female forward fu1 fu12005 goodat hhfemale hhhead male married math muslim othback perfectat read rural teacher_absence wkany1 write 

foreach k of local yesnovars {
	label values `k' yesno
}


//------------------------------------------------------------------------------
// label variables ... 
//------------------------------------------------------------------------------

label variable adivasi             "Adivasi (Yes/No)" 
label variable adolescents         "Adolescents (Yes/No)" 
label variable age                 "Age" 
label variable agematch_ed5x       "Age-grade match ED5X (Yes/No)" 
label variable agematch_cs5x       "Age-grade match CS5X (Yes/No)" 
label variable baseyear            "Baseyear" 
label variable brahmin             "Brahmin (Yes/No)" 
label variable copc                "Consumption per capita" 
label variable copc1               "Log Consumption per capita" 
label variable cs11x               "Days/month absent" 
label variable cs5x                "Standard (yrs)" 
label variable csj                 "Christian, Sikh, Jain (Yes/No)" 
label variable dalit               "Dalit (Yes/No)" 
label variable ed3x                "Attended school" 
label variable ed4x                "Enrolled now" 
label variable ed5x                "Completed Years" 
label variable elecfree            "Electricity: Free (Yes/No)" 
label variable elecoth             "Electricity: Other (Yes/No)" 
label variable elecpay             "Electricity: Paid (Yes/No)" 
label variable elecqual1           "Electricity: quality (fu1a > median)" 
label variable elecqual2           "Electricity: quality (fu1a > hourselec)" 
label variable elecqual3           "Electricity: quality (using fu1, fu1a > 18)" 
label variable elecqual4           "Electricity: quality (using fu1, fu1a > 16)" 
label variable elecqual5           "Electricity: quality (using fu1, fu1a > hourselec)" 
label variable feduc               "Father's education" 
label variable female              "Female dummy (Yes/No)" 
label variable forward             "Forward caste (Yes/No)" 
label variable fu1                 "2012 Electricity (Yes/No)" 
label variable fu12005             "2005 Electricity (Yes/No)" 
label variable fu1a                "Electricity: N hours" 
label variable fu1c                "Electricity: Rupees" 
label variable goodat              "Good Attendance (Yes/No)" 
label variable govtsch_mdm         "Prop of govt. schools w/ midday meals in village" 
label variable hhage               "Age of HH head" 
label variable hhassets            "HH goods and housing" 
label variable hhassets1           "Log HH Assets" 
label variable hhed5adu            "Highest educ adult" 
label variable hhed5f              "Highest educ female" 
label variable hhed5m              "Highest educ male" 
label variable hheduc              "Education of HH head" 
label variable hhfemale            "Female HH head (Yes/No)" 
label variable hhhead              "HH head (Yes/No)" 
label variable income              "Total income" 
label variable income1             "Log Total income" 
label variable incomepc            "Total income-per-capita" 
label variable incomepc1           "Log Total income-per-capita" 
label variable tlinesdensity1      "Trasmission line length density - per sqkm" 
label variable tlinesdensity2      "Trasmission line length density - per capita" 
label variable male                "Male dummy (Yes/No)" 
label variable married             "Marital Status (Yes/No)" 
label variable math                "Numeracy skill (Yes/No)" 
label variable mdm                 "Prop of schools w/ midday meals in village" 
label variable meduc               "Mother's education" 
label variable muslim              "Muslim (Yes/No)" 
label variable nadults             "N adults in HH" 
label variable nchildren           "N children in HH" 
label variable npersons            "N in HH" 
label variable nteens              "N teens in HH" 
label variable othback             "Oth background caste (Yes/No)" 
label variable perfectat           "Perfect Attendance (Yes/No)" 
label variable poor                "Poverty" 
label variable privsch             "Private School dummy" 
label variable privsch_mdm         "Prop of priv. schools w/ midday meals in village" 
label variable read                "Reading skill (Yes/No)" 
label variable rural               "RuraL dummy (Yes/No)" 
label variable teacher_absence     "Teacher absence (Sometimes/Often = 1, else = 0) (Yes/No)" 
label variable urban               "Urban dummy (Yes/No)" 
label variable vi4a                "Proportion of households with electricity in the village" 
label variable wkany               "Working status (any)" 
label variable wkany1              "Working status (any), redefined (Yes/No)" 
label variable write               "Writing skill (Yes/No)" 

label variable _merge_ih           "merge summary: individual + household files" 
label variable _merge_ihs          "merge summary: individual + household + school files" 
label variable _merge_ihsv         "merge summary: individual + household + school + village files" 
label variable _merge_census       "merge summary: with census + transmission line data files" 

format mdm govtsch_mdm privsch_mdm %9.6f
format idhh caseid %20.0f

//------------------------------------------------------------------------------
// house cleaning ... 
//------------------------------------------------------------------------------

local dropvars ro3x ro4x ro6x fatherid motherid nadultm nadultf nchildm nchildf nteenm nteenf hhed5adult hhed5m hhed5f nteens nadults area_sqkm nlines lengthlines

drop `dropvars'

local outfile 36151
save `outfile', replace

local list : dir . files "*Data_out.dta"
foreach f of local list {
    capture noisily erase "`f'"
}

mi erase temp // delete temp file 

//------------------------------------------------------------------------------
// describe variables ... 
//------------------------------------------------------------------------------

describe `r(varlist)'

tab _merge_ih     , missing // diagnostics 
tab _merge_ihs    , missing // diagnostics 
tab _merge_ihsv   , missing // diagnostics 
tab _merge_census , missing // diagnostics 

********** CLOSE OUTPUT
log close
