//==============================================================================
// IHDS - 2012 (Individual + Household + School + Village + 2005 HH Electricity)
// - merge all files ...
// - merge census data ...
// - merge transmission line data ...
//==============================================================================
//	Written	by Suresh Paul, Algorithm Basics
//	version: 05/05/2023
//==============================================================================

clear all 
capture log close 
set more off 

//------------------------------------------------------------------------------
// open logfile ... 
//------------------------------------------------------------------------------

log using "C:\ihds\stata_files\36151", replace

//------------------------------------------------------------------------------
// set dir for data
//------------------------------------------------------------------------------

local dirpath "C:\ihds\stata_files"

cd `dirpath'


//------------------------------------------------------------------------------
// Some Macros: 
//	Program pe: Print Execute with loops
//------------------------------------------------------------------------------

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

local giturl = "https://raw.githubusercontent.com/sureshlazaruspaul/ihds/main/stata-codes" 


//------------------------------------------------------------------------------
// calc Father's Education ... 
//------------------------------------------------------------------------------

use "https://www.dropbox.com/s/f1b8sxtjq0shqyn/36151-0001-Data_out.dta?dl=1", clear

keep IDHH PERSONID ED5X
drop if missing( PERSONID ) | missing( ED5X )

rename (PERSONID ED5X) (FATHERID FEDUC) 

sort IDHH FATHERID FEDUC // remove duplicates by all 
	quietly by IDHH FATHERID FEDUC: gen dup = cond(_N==1, 0, _n) 
	drop if dup > 0
	drop dup 

sort IDHH FATHERID FEDUC // remove duplicates by IDHH FATHERID 
	quietly by IDHH FATHERID: gen dup = cond(_N==1, 0, _n) 
	drop if dup > 0
	drop dup 

sort IDHH FATHERID FEDUC

save FEDUC, replace

//------------------------------------------------------------------------------
// calc Mother's Education ... 
//------------------------------------------------------------------------------

use "https://www.dropbox.com/s/f1b8sxtjq0shqyn/36151-0001-Data_out.dta?dl=1", clear

keep IDHH PERSONID ED5X
drop if missing( PERSONID ) | missing( ED5X )

rename (PERSONID ED5X) (MOTHERID MEDUC) 

sort IDHH MOTHERID MEDUC // remove duplicates by all 
	quietly by IDHH MOTHERID MEDUC: gen dup = cond(_N==1, 0, _n) 
	drop if dup > 0
	drop dup 

sort IDHH MOTHERID MEDUC // remove duplicates by IDHH MOTHERID  
	quietly by IDHH MOTHERID: gen dup = cond(_N==1, 0, _n) 
	drop if dup > 0
	drop dup 

sort IDHH MOTHERID MEDUC

save MEDUC, replace


//------------------------------------------------------------------------------
// read data ... 
//------------------------------------------------------------------------------

use "https://www.dropbox.com/s/f1b8sxtjq0shqyn/36151-0001-Data_out.dta?dl=1", clear

sort IDHH FATHERID

merge m:1 IDHH FATHERID using FEDUC
drop if _merge == 2 // left join 
drop _merge 


capture confirm file FEDUC.dta

** .. if it does, delete program
if _rc == 0 {
    di "File exists, deleting ..."
    erase FEDUC.dta
}

** .. else, show error code (but continue)
else {
    capture noisily error _rc
    di "File keeps running though..."
}

sort IDHH MOTHERID

merge m:1 IDHH MOTHERID using MEDUC
drop if _merge == 2 // left join 
drop _merge 

capture confirm file MEDUC.dta

** .. if it does, delete program
if _rc == 0 {
    di "File exists, deleting ..."
    erase MEDUC.dta
}

** .. else, show error code (but continue)
else {
    capture noisily error _rc
    di "File keeps running though..."
}


//------------------------------------------------------------------------------

sort IDHH

merge m:1 IDHH using "https://www.dropbox.com/s/h5b3bhuo1tqmbo2/36151-0002-Data_out.dta?dl=1" 
	drop if _merge == 2 // left join Household file
	rename _merge _merge_IH 

sort IDPSU 

merge m:1 IDPSU using "https://www.dropbox.com/s/uzeowr6s5kkeocw/36151-0009-Data_out.dta?dl=1" 
	drop if _merge == 2 // left join School Facilities file
	rename _merge _merge_IHS 

sort IDPSU 

merge m:1 IDPSU using "https://www.dropbox.com/s/1ov3pxcko9er3md/36151-0012-Data_out.dta?dl=1" 
	drop if _merge == 2 // left join Village file
	rename _merge _merge_IHSV 

//------------------------------------------------------------------------------


g HHID12 = HHID 
g HHSPLITID12 = HHSPLITID

sort STATEID DISTID PSUID HHID12 HHSPLITID12 

merge m:1 STATEID DISTID PSUID HHID12 HHSPLITID12 using "https://github.com/sureshlazaruspaul/ihds/blob/main/stata-codes/electricity2005.dta?raw=true"
	drop if _merge == 2 // left join 2005 Electricity file
	drop _merge HHID12 HHSPLITID12 

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
g elecqual2 = cond(missing(fu1a), ., (fu1a > vi4cx)) 
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
	tab adolescents , missing

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

// transmission line density: number of transmission lines per square kilometer
gen nlines_sqkm = nlines / area_sq_km 
	replace nlines_sqkm = . if missing( nlines ) | missing( area_sq_km )
	sum nlines_sqkm , detail
	nmissing nlines_sqkm 

// transmission line density: standardized number of lines per square kilometer
// number of lines per square kilometer - national average (=0.234289560297319)
gen nlines_sqkm_sd = nlines_sqkm - 0.234289560297319 
	replace nlines_sqkm_sd = . if missing( nlines_sqkm ) 
	sum nlines_sqkm_sd , detail
	nmissing nlines_sqkm_sd 

// transmission line density: dummy variable 
gen nlines_sqkm_dummy = ( nlines_sqkm_sd > 0 ) 
	replace nlines_sqkm_dummy = . if missing( nlines_sqkm_sd )
	tab nlines_sqkm_dummy , missing

//------------------------------------------------------------------------------

// transmission length density: length of transmission lines per square kilometer
gen lenlines_sqkm = lengthlines / area_sq_km 
	replace lenlines_sqkm = . if missing( lengthlines ) | missing( area_sq_km )
	sum lenlines_sqkm , detail
	nmissing lenlines_sqkm 

// transmission length density: standardized length per square kilometer
// length per square kilometer - national average (=380.20990222825)
gen lenlines_sqkm_sd = lenlines_sqkm - 380.20990222825 
	replace lenlines_sqkm_sd = . if missing( lenlines_sqkm ) 
	sum lenlines_sqkm_sd , detail
	nmissing lenlines_sqkm_sd 

// transmission length density: dummy variable 
gen lenlines_sqkm_dummy = ( lenlines_sqkm_sd > 0 ) 
	replace lenlines_sqkm_dummy = . if missing( lenlines_sqkm_sd )
	tab lenlines_sqkm_dummy , missing


//------------------------------------------------------------------------------
// label values ... 
//------------------------------------------------------------------------------

label define yesno 0 "NO" 1 "YES" 

local yesnovars adivasi adolescents agematch_ed5x agematch_cs5x brahmin csj dalit elecfree elecoth elecpay elecqual1 elecqual2 female forward fu1 fu12005 hhfemale hhhead lenlines_sqkm_dummy male married muslim nlines_sqkm_dummy othback rural teacher_absence wkany1 

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
label variable elecqual2           "Electricity: quality (fu1a > vi4cx)"
label variable feduc               "Father's education" 
label variable female              "Female dummy (Yes/No)" 
label variable forward             "Forward caste (Yes/No)" 
label variable fu1                 "2012 Electricity (Yes/No)" 
label variable fu12005             "2005 Electricity (Yes/No)" 
label variable fu1a                "Electricity: N hours" 
label variable fu1c                "Electricity: Rupees" 
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
label variable lenlines_sqkm       "Trasmission line length density" 
label variable lenlines_sqkm_sd    "Trasmission line length density (standardized)" 
label variable lenlines_sqkm_dummy "Standardized line length density > national average (YES/NO)" 
label variable male                "Male dummy (Yes/No)" 
label variable married             "Marital Status (Yes/No)" 
label variable mdm                 "Prop of schools w/ midday meals in village" 
label variable meduc               "Mother's education" 
label variable muslim              "Muslim (Yes/No)" 
label variable nadults             "N adults in HH" 
label variable nchildren           "N children in HH" 
label variable npersons            "N in HH" 
label variable nlines_sqkm         "Trasmission lines density" 
label variable nlines_sqkm_sd      "Trasmission lines density (standardized)" 
label variable nlines_sqkm_dummy   "Standardized line density > national average (YES/NO)" 
label variable nteens              "N teens in HH" 
label variable othback             "Oth background caste (Yes/No)" 
label variable poor                "Poverty" 
label variable privsch             "Private School dummy" 
label variable privsch_mdm         "Prop of priv. schools w/ midday meals in village" 
label variable rural               "RuraL dummy (Yes/No)" 
label variable teacher_absence     "Teacher absence (Sometimes/Often = 1, else = 0) (Yes/No)" 
label variable urban               "Urban dummy (Yes/No)" 
label variable vi4a                "Proportion of households with electricity in the village" 
label variable wkany               "Working status (any)" 
label variable wkany1              "Working status (any), redefined (Yes/No)" 

label variable _merge_IH           "merge summary: individual + household files" 
label variable _merge_IHS          "merge summary: individual + household + school files" 
label variable _merge_IHSV         "merge summary: individual + household + school + village files" 
label variable _merge_census       "merge summary: with census + transmission line data files" 

format mdm govtsch_mdm privsch_mdm %9.6f
format idhh caseid %20.0f

//------------------------------------------------------------------------------
// house cleaning ... 
//------------------------------------------------------------------------------

local dropvars ro3x ro4x ro6x fatherid motherid nadultm nadultf nchildm nchildf nteenm nteenf hhed5adult hhed5m hhed5f nteens nadults area_sq_km nlines lengthlines

drop `dropvars'

local outfile 36151
save `outfile', replace

mi erase temp // delete temp file 

//------------------------------------------------------------------------------
// describe variables ... 
//------------------------------------------------------------------------------

describe `r(varlist)'

tab _merge_IH     , missing // diagnostics 
tab _merge_IHS    , missing // diagnostics 
tab _merge_IHSV   , missing // diagnostics 
tab _merge_census , missing // diagnostics 

********** CLOSE OUTPUT
log close
