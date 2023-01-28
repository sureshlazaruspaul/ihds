//==============================================================================
// IHDS - 2012 (Individual)
//	- clean and keep selected variables only ...
//==============================================================================
//	Written	by Suresh Paul, Algorithm Basics
//	version: 01/28/2023
//==============================================================================

clear all 
capture log close 
set more off 

//------------------------------------------------------------------------------
// open logfile ... 
//------------------------------------------------------------------------------

log using "C:\ihds\stata_files\36151-0001-Data", replace

//------------------------------------------------------------------------------
// set directory ...
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
// read data ... 
//------------------------------------------------------------------------------

use "C:\data\ICPSR_36151\DS0001\36151-0001-Data.dta", clear


//------------------------------------------------------------------------------
// reassign variables by removing formatting ...
//------------------------------------------------------------------------------
/*
foreach v of var * {
	cap label val `v'
}
*/


do "C:\data\ICPSR_36151\DS0001\36151-0001-Supplemental_syntax.do" // run supplemental file ...

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

rename (IDPERSON URBAN2011)                       (CASEID URBAN)
rename (GROUPS RO3 RO4 RO5 RO6 RO9 RO10)          (GROUPS8X RO3X RO4X AGE RO6X FATHERID MOTHERID)
rename (ED4 ED5 ED6 CS13 CS4 CS5 CS6 TA3 TA4 SM3) (ED3X ED4X ED5X CS11X CS3X CS4X CS5X TA3X TA4X SM2X)
rename (CS10 CS11)                                (CS8X CS9X) 
rename (TA8A TA8B TA9A TA9B TA10A TA10B)          (TA7LANG TA7LVL TA8LANG TA8LVL TA9LANG TA9LVL)
rename (NPERSONS NCHILDREN NTEENS NADULTS ASSETS) (NPERSONS NCHILDREN NTEENS NADULTS HHASSETS)
rename (HHEDUC HHEDUCF HHEDUCM)                   (HHED5ADULT HHED5F HHED5M)
rename (WKANY5 WT)                                (WKANY WEIGHT)

replace FATHERID = . if inlist( FATHERID, 69, 75 ) // Left home OR Deceased
replace MOTHERID = . if inlist( MOTHERID, 69, 75 ) // Left home OR Deceased


********** INDENTIFIER VARIABLES
local indvars CASEID HHID PERSONID IDHH STATEID DISTRICT DISTID PSUID IDPSU HHSPLITID DIST01 URBAN DEFLATOR WKANY WEIGHT

********** FAMILY VARIABLES
local famvars NPERSONS NCHILDREN HHASSETS HHED5ADULT HHED5F HHED5M INCOME INCOMEPC COPC WS14 

********** DEMOGRAPHIC VARIABLES
local demovars GROUPS8X RO3X RO4X AGE RO6X FATHERID MOTHERID ED3X ED4X ED5X CS11X CS3X CS4X CS5X CS8X CS9X TA3X TA4X TA7LANG TA7LVL TA8LANG TA8LVL TA9LANG TA9LVL 

********** OTHER VARIABLES
local othvars NCHILDM NCHILDF NTEENM NTEENF NADULTM NADULTF NTEENS NADULTS SM2X CH6 WKHOURS



********** CHANGE FORMAT OF VARIABLES
destring IDHH CASEID, replace

********** KEEP RELEVANT VARIABLES
keep `indvars' `famvars' `demovars' `othvars'

local outfile "C:\data\ICPSR_36151\DS0001\36151-0001-Data_out.dta" 
save `outfile', replace

//------------------------------------------------------------------------------
// describe variables ... 
//------------------------------------------------------------------------------

describe `r(varlist)'

********** CLOSE OUTPUT
log close
