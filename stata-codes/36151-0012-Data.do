//==============================================================================
// IHDS - 2012 (Village)
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

log using "C:\ihds\stata_files\36151-0012-Data", replace

//------------------------------------------------------------------------------
// set directory
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

use "C:\data\ICPSR_36151\DS0012\36151-0012-Data.dta", clear


//------------------------------------------------------------------------------
// reassign variables by removing formatting ...
//------------------------------------------------------------------------------
/*
foreach v of var * {
	cap label val `v'
}
*/


do "C:\data\ICPSR_36151\DS0012\36151-0012-Supplemental_syntax.do" // run supplemental file ...


//------------------------------------------------------------------------------
// transform/calc variables ... 
//------------------------------------------------------------------------------

g IDPSU = STATEID * 10000 + DISTID * 100 + PSUID 

//------------------------------------------------------------------------------
// rename variables ... 
//------------------------------------------------------------------------------

rename (VI4D VI18K VI18L) (VI4CX VI15LX VI15MX)









********** INDENTIFIER VARIABLES
local indvars IDPSU 

********** VILLAGE VARIABLES
local villagevars VI4A VI4B VI4CX VMA1 VI15LX VI15MX 




********** CHANGE FORMAT OF VARIABLES
// destring IDHH, replace

********** KEEP RELEVANT VARIABLES
keep `indvars' `villagevars' 


local outfile "C:\data\ICPSR_36151\DS0012\36151-0012-Data_out.dta" 
save `outfile', replace

//------------------------------------------------------------------------------
// describe variables ... 
//------------------------------------------------------------------------------

describe `r(varlist)'


********** CLOSE OUTPUT
log close
