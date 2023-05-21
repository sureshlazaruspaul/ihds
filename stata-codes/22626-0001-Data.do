//==============================================================================
//	READ 2005 INDIVIDUAL DATA 
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
// open logfile ... 
//------------------------------------------------------------------------------

log using "C:\ihds\22626-0001-Data", replace

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
// read data ... 
//------------------------------------------------------------------------------

use "https://www.dropbox.com/s/9uiavggchrs4vis/22626-0001-Data.dta?dl=1" , clear


//------------------------------------------------------------------------------
// reassign variables by removing formatting ...
//------------------------------------------------------------------------------
/*
foreach v of var * {
	cap label val `v'
}
*/

do "`giturl'/supp-codes/22626-0001-Supplemental_syntax.do" // run supplemental file ...


// rename variables 
ren GROUPS8 GROUPS8X 
ren RO3     RO3X 
ren RO4     RO4X 
ren RO5     AGE 
ren RO6     RO6X 
ren RO8     FATHERID 
ren RO9     MOTHERID 
ren ED3     ED3X 
ren ED4     ED4X 
ren ED5     ED5X 
ren CS8     CS8X 
ren CS9     CS9X 
ren CS10    CS10X 
ren CS11    CS11X 
ren CS12    CS12X 
ren CS3     CS3X 
ren CS4     CS4X 
ren CS5     CS5X 
ren TA3     TA3X 
ren TA4     TA4X 
ren TA6     TA6X 
ren SWEIGHT WEIGHT
ren SM2     SM30
ren SM3     SMF
ren SM4     SMC
ren SM5     SMCB
ren SM6     SMD
ren WS6YEAR WKHRS 





// create empty variables to facilitate append to 2012
gen CH6X = .
	label variable CH6X  "Is Teacher absent?"
	label variable CS12X "Receive Mid-day meals in School?"

gen CH22X = . 
	label variable CH22X "School ID" 

gen WS14 = .
	label variable WS14 "MGNREGA - missing for 2005"

gen RO7X = .
	label variable RO7X "Primary activity status - missing for 2005"

gen DEFLATOR = 1 
	label variable DEFLATOR "Deflator (CPI-based)" 

gen FUELFREQ_FADU = . 
	label variable FUELFREQ_FADU "Walking freq to get fuel - Female Adult" 

gen FUELFREQ_F    = . 
	label variable FUELFREQ_F "Walking freq to get fuel - Female Child" 

gen FUELFREQ_M    = .
	label variable FUELFREQ_M "Walking freq to get fuel - Male Child" 


// CHANGE FORMAT OF VARIABLES
destring IDHH CASEID, replace 
	format IDHH CASEID %19.0f 

// Create an ID variable that unites STATEID DISTID PSUID 
gen idvillage = (100+STATEID)*10000 + DISTID*100 + PSUID  
	label variable idvillage "Village ID" 

gen baseyear = 2005 
	label variable baseyear "Survey year = 2005"

// keep variables 
local keepvars CASEID HHID PERSONID IDHH idvillage IDPSU HHSPLITID DIST01 URBAN DEFLATOR WKANY WEIGHT HHASSETS HHED5ADULT HHED5F HHED5M COPC WS14 GROUPS8X RO3X RO4X RO7X AGE RO6X FATHERID MOTHERID ED3X ED4X ED5X CH6X CH22X CS3X CS4X CS5X CS8X CS9X CS10X CS11X CS12X TA3X TA4X TA6X TA7LANG TA7LVL TA8LANG TA8LVL TA9LANG TA9LVL SM30 SMF SMC SMCB SMD FUELFREQ_FADU FUELFREQ_F FUELFREQ_M WKHRS 

keep `keepvars'

// rename all variables ... 
ds IDHH idvillage , not
rename (`r(varlist)') (=2005) 
rename * , lower 


// order variables alphabetically ... 
order _all, alphabetic

// describe the data & missings ... 
ds idhh idvillage caseid hhid personid idpsu hhsplitid dist01 , not
describe `r(varlist)'
mdesc 

save 22626-0001-Data-out, replace



********** CLOSE OUTPUT
log close





