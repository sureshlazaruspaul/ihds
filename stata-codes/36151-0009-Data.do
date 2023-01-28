//==============================================================================
// IHDS - 2012 (School)
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

log using "C:\ihds\stata_files\36151-0009-Data", replace

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
// read data ... 
//------------------------------------------------------------------------------

use "C:\data\ICPSR_36151\DS0009\36151-0009-Data.dta", clear


//------------------------------------------------------------------------------
// reassign variables by removing formatting ...
//------------------------------------------------------------------------------
/*
foreach v of var * {
	cap label val `v'
}
*/


do "C:\data\ICPSR_36151\DS0009\36151-0009-Supplemental_syntax.do" // run supplemental file ...


//------------------------------------------------------------------------------
// transform/calc variables ... 
//------------------------------------------------------------------------------

// VILLAGE IDENTIFIER
g IDPSU = STATEID * 10000 + DISTID * 100 + PSUID 

// DATA RESTRICTION
//	- drop if midday meal information is missing
drop if missing( PS10 )

// GOVT SCHOOL DUMMY
g GOVTSCH = ( SQGOVT == 1 )
*replace GOVTSCH = . if missing( SQGOVT )
tab SQGOVT GOVTSCH , missing

// PRIV SCHOOL DUMMY 
g PRIVSCH = ( SQGOVT == 2 )
*replace PRIVSCH = . if missing( SQGOVT )
tab SQGOVT PRIVSCH , missing

// MIDDAY MEAL DUMMY
g MDM = ( PS10 == 1 ) 
*replace MDM = . if missing( PS10 )
tab PS10 MDM , missing

// GOVT SCHOOL w/ MIDDAY MEAL DUMMY
g GOVTSCH_MDM = ( SQGOVT == 1 & PS10 == 1 )
*replace GOVTSCH_MDM = . if missing( SQGOVT ) | missing( PS10 )
tab SQGOVT GOVTSCH_MDM , missing
tab PS10 GOVTSCH_MDM , missing

// PRIV SCHOOL w/ MIDDAY MEAL DUMMY
g PRIVSCH_MDM = ( SQGOVT == 2 & PS10 == 1 )
*replace PRIVSCH_MDM = . if missing( SQGOVT ) | missing( PS10 )
tab SQGOVT PRIVSCH_MDM , missing
tab PS10 PRIVSCH_MDM , missing

//------------------------------------------------------------------------------

// sum by village 
collapse (sum) GOVTSCH PRIVSCH MDM GOVTSCH_MDM PRIVSCH_MDM , by( IDPSU )

// TOTAL NUMBER OF SCHOOLS in VILLAGE
g TOTSCH = GOVTSCH + PRIVSCH

// PROP OF SCHOOLS in VILLAGE OFFERING MIDDAY MEALS
replace MDM = MDM / TOTSCH
replace GOVTSCH_MDM = GOVTSCH_MDM / GOVTSCH 
replace PRIVSCH_MDM = PRIVSCH_MDM / PRIVSCH

local miss2zero MDM GOVTSCH_MDM PRIVSCH_MDM

foreach k of local miss2zero {
	replace `k' = 0 if missing( `k' )
		format `k' %9.4f 
}


//------------------------------------------------------------------------------
// rename variables ... 
//------------------------------------------------------------------------------

* none

********** INDENTIFIER VARIABLES
local indvars IDPSU 

********** SCHOOL VARIABLES
local schoolvars MDM GOVTSCH_MDM PRIVSCH_MDM 



********** CHANGE FORMAT OF VARIABLES
// destring IDHH, replace

********** KEEP RELEVANT VARIABLES
keep `indvars' `schoolvars' 


local outfile "C:\data\ICPSR_36151\DS0009\36151-0009-Data_out.dta" 
save `outfile', replace

//------------------------------------------------------------------------------
// describe variables ... 
//------------------------------------------------------------------------------

describe `r(varlist)'

********** CLOSE OUTPUT
log close
