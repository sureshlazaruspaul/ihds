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

g GOVTSCH = ( SQGOVT == 1 ) // GOVT SCHOOL DUMMY
g PRIVSCH = ( SQGOVT == 2 ) // PRIV SCHOOL DUMMY 

g GOVTSCH_MIDDAYMEAL = ( SQGOVT == 1 & PS10 == 1 ) // GOVT SCHOOL w/ MIDDAY MEAL DUMMY
g PRIVSCH_MIDDAYMEAL = ( SQGOVT == 2 & PS10 == 1 ) // PRIV SCHOOL w/ MIDDAY MEAL DUMMY

collapse (sum) GOVTSCH PRIVSCH GOVTSCH_MIDDAYMEAL PRIVSCH_MIDDAYMEAL , by( STATEID DISTID PSUID )

g PROPGOVTMEAL = GOVTSCH_MIDDAYMEAL / GOVTSCH 
g PROPPRIVMEAL = PRIVSCH_MIDDAYMEAL / PRIVSCH 

g IDPSU = STATEID * 10000 + DISTID * 100 + PSUID 

//------------------------------------------------------------------------------
// rename variables ... 
//------------------------------------------------------------------------------

* none

********** INDENTIFIER VARIABLES
local indvars IDPSU 

********** SCHOOL VARIABLES
local schoolvars GOVTSCH_MIDDAYMEAL PRIVSCH_MIDDAYMEAL PROPGOVTMEAL PROPPRIVMEAL 



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
