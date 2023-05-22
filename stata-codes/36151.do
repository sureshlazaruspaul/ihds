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
//	version: 05/21/2023
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

g perfectat = inlist( cs11x, 0 ) 
	replace perfectat = . if missing( cs11x )
	tab perfectat , missing 

g goodat = inrange( cs11x, 0, 2 ) 
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
 

g female = inlist( ro3x , 2 )
replace female = . if missing( ro3x )

tab female ro3x , missing // diagnostics 


g hhhead = inlist( ro4x , 1 )
replace hhhead = . if missing( ro4x )

tab hhhead ro4x , missing // diagnostics 


g married = inlist( ro6x , 1 )
replace married = . if missing( ro6x )

tab married ro6x , missing // diagnostics 


//------------------------------------------------------------------------------
********** caste and religion definitions
//------------------------------------------------------------------------------

g brahmin = 0 
replace brahmin = 1 if groups8x == 1 
replace brahmin = . if missing( groups8x )

g forward = 0 
replace forward = 1 if groups8x == 2 
replace forward = . if missing( groups8x )

g othback = 0 
replace othback = 1 if groups8x == 3 
replace othback = . if missing( groups8x )

g dalit = 0 
replace dalit = 1 if groups8x == 4 
replace dalit = . if missing( groups8x )

g adivasi = 0 
replace adivasi = 1 if groups8x == 5 
replace adivasi = . if missing( groups8x )

g muslim = 0 
replace muslim = 1 if groups8x == 6 
replace muslim = . if missing( groups8x )

g csj = 0 
replace csj = 1 if groups8x == 7 
replace csj = . if missing( groups8x )

//------------------------------------------------------------------------------
********** electricity & electricity payment method 
//------------------------------------------------------------------------------

g elecfree = 0 
replace elecfree = 1 if inlist( fu1b , 1 )
replace elecfree = . if missing( fu1b )

tab fu1b elecfree , missing // diagnostics 


g elecpay = 0 
replace elecpay = 1 if inlist( fu1b , 2, 3, 4 )  
replace elecpay = . if missing( fu1b )

tab fu1b elecpay , missing // diagnostics 


g elecoth = 0 
replace elecoth = 1 if inlist( fu1b , 5, 6, 7, 8 )  
replace elecoth = . if missing( fu1b )

tab fu1b elecoth , missing // diagnostics 


egen median_fu1a = median(fu1a) 
g elecqual1 = cond(missing(fu1a), ., (fu1a > median_fu1a)) 
g elecqual2 = cond(missing(fu1a), ., (fu1a > hourselec)) 
	drop median_fu1a

tab elecqual1 , missing // diagnostics 
tab elecqual2 , missing // diagnostics 
tab elecqual1 elecqual2 , missing // diagnostics 


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



g privsch = inlist( cs3x, 4 )
replace privsch = . if missing( cs3x )

tab cs3x privsch, missing // diagnostics 



g teacher_absence = inlist( ch6 , 2, 3 ) 
replace teacher_absence = . if missing( ch6 )

tab ch6 teacher_absence , missing // diagnostics 



gen adolescents = inrange( age, 8, 11 ) // adolescents
	replace adolescents = . if missing( age ) 
	tab adolescents , missing

gen read = inlist( ta7lvl, 3, 4 )
	replace read = . if missing( ta7lvl ) 
	tab read ta7lvl , missing 

gen write = inlist( ta9lvl, 1, 2 )
	replace write = . if missing( ta9lvl ) 
	tab write ta9lvl , missing 

gen math = inlist( ta8lvl, 2, 3 )
	replace math = . if missing( ta8lvl ) 
	tab math ta8lvl , missing 


gen agematch_ed5x = 1 // age-grade match using ed5x 
	replace agematch_ed5x = 0 if !missing( ed5x ) & age - ed5x > 6
	replace agematch_ed5x = . if  missing( ed5x ) | age - ed5x < 4 

gen agematch_cs5x = 1 // age-grade match using cs5x 
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
