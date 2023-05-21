//==============================================================================
//	READ 2011 INDIVIDUAL DATA 
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

log using "C:\ihds\36151-0001-Data", replace

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

use "https://www.dropbox.com/s/yutqdd2i5v7yfng/36151-0001-Data.dta?dl=1" , clear


//------------------------------------------------------------------------------
// reassign variables by removing formatting ...
//------------------------------------------------------------------------------
/*
foreach v of var * {
	cap label val `v'
}
*/

do "`giturl'/supp-codes/36151-0001-Supplemental_syntax.do" // run supplemental file ...

//------------------------------------------------------------------------------
// clean/transform/calculate variables ... 
//------------------------------------------------------------------------------

replace NCHILDM = 0 if missing( NCHILDM )
replace NCHILDF = 0 if missing( NCHILDF )
replace NTEENM  = 0 if missing( NTEENM )
replace NTEENF  = 0 if missing( NTEENF )
replace NADULTM = 0 if missing( NADULTM )
replace NADULTF = 0 if missing( NADULTF )

gen NCHILDREN = NCHILDM + NCHILDF 
gen NTEENS    = NTEENM  + NTEENF 
gen NADULTS   = NADULTM + NADULTF



//------------------------------------------------------------------------------
// rename variables ... 
//------------------------------------------------------------------------------

ren IDPERSON  CASEID 
ren URBAN2011 URBAN 
ren GROUPS    GROUPS8X 
ren RO3       RO3X 
ren RO4       RO4X 
ren RO5       AGE 
ren RO6       RO6X 
ren RO9       FATHERID 
ren RO10      MOTHERID 
ren ED4       ED3X 
ren ED5       ED4X 
ren ED6       ED5X 
ren CH6       CH6X 
ren CH22      CH22X 
ren CS10      CS8X 
ren CS11      CS9X 
ren CS12      CS10X 
ren CS13      CS11X 
ren CS4       CS3X 
ren CS5       CS4X 
ren CS6       CS5X 
ren TA3       TA3X 
ren TA4       TA4X 
ren TA6       TA6X 
ren TA8A      TA7LANG 
ren TA8B      TA7LVL 
ren TA9A      TA8LANG 
ren TA9B      TA8LVL 
ren TA10A     TA9LANG 
ren TA10B     TA9LVL 
ren ASSETS    HHASSETS 
ren HHEDUC    HHED5ADULT 
ren HHEDUCF   HHED5F 
ren HHEDUCM   HHED5M 
ren WT        WEIGHT 
ren RO7       RO7X
ren SM3       SM2X
ren SM4       SMF
ren SM5       SMC
ren SM6       SMCB
ren SM7       SMD
ren WKANY5    WKANY
ren WS8YEAR   WKHRS


replace FATHERID = . if inlist( FATHERID, 69, 75 ) // Left home OR Deceased
replace MOTHERID = . if inlist( MOTHERID, 69, 75 ) // Left home OR Deceased


********** INDENTIFIER VARIABLES
local indvars CASEID HHID PERSONID IDHH STATEID DISTRICT DISTID PSUID IDPSU HHSPLITID DIST01 URBAN DEFLATOR WKANY WEIGHT

********** FAMILY VARIABLES
local famvars NPERSONS NCHILDREN HHASSETS HHED5ADULT HHED5F HHED5M INCOME INCOMEPC COPC WS14 

********** DEMOGRAPHIC VARIABLES
local demovars GROUPS8X RO3X RO4X AGE RO6X RO7X FATHERID MOTHERID ED3X ED4X ED5X CS11X CS3X CS4X CS5X CS8X CS9X TA3X TA4X TA6X TA7LANG TA7LVL TA8LANG TA8LVL TA9LANG TA9LVL 

********** OTHER VARIABLES
local othvars NCHILDM NCHILDF NTEENM NTEENF NADULTM NADULTF NTEENS NADULTS SM2X SMF SMC SMCB SMD CH6X CH22X CS10X WKHOURS WKHRS

********** CHANGE FORMAT OF VARIABLES
destring IDHH CASEID, replace

********** KEEP RELEVANT VARIABLES
keep `indvars' `famvars' `demovars' `othvars'

	label variable CH6X "Is Teacher absent?"
	label variable CH22X "School ID" 

// Create an ID variable that unites STATEID DISTID PSUID 
gen idvillage = (100+STATEID)*10000 + DISTID*100 + PSUID  
	label variable idvillage "Village ID" 


// rename all variables ... 
rename *, lower 

// order variables alphabetically ... 
order _all, alphabetic


local outfile "`dirpath'\36151-0001-Data_out.dta" 
save `outfile', replace

//------------------------------------------------------------------------------
// describe variables ... 
//------------------------------------------------------------------------------

describe `r(varlist)'

mdesc 

********** CLOSE OUTPUT
log close
