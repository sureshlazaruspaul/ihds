//==============================================================================
// IHDS - 2012 (Household)
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

log using "C:\ihds\stata_files\36151-0002-Data", replace

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

use "C:\data\ICPSR_36151\DS0002\36151-0002-Data.dta", clear


//------------------------------------------------------------------------------
// reassign variables by removing formatting ...
//------------------------------------------------------------------------------
/*
foreach v of var * {
	cap label val `v'
}
*/


********** CHANGE FORMAT OF VARIABLES
destring IDHH, replace


********** format electricity variables 
replace FU1  = . if (FU1  >= -7 & FU1  <= -1)
replace FU1A = . if (FU1A >= -7 & FU1A <= -1)
replace FU1B = . if (FU1B >= -7 & FU1B <= -1)
replace FU1C = . if (FU1C >= -7 & FU1C <= -1)


rename (FU14A2 FU14C2 FU14D2 WA6A WA6C WA6D) (FU11BX FU11DX FU11EX WA9AX WA9CX WA9DX)



********** KEEP RELEVANT VARIABLES
keep IDHH FU1 FU1A FU1B FU1C POOR SA4 FU11BX FU11DX FU11EX WA9AX WA9CX WA9DX 



local outfile "C:\data\ICPSR_36151\DS0002\36151-0002-Data_out.dta" 
save `outfile', replace

//------------------------------------------------------------------------------
// describe variables ...  
//------------------------------------------------------------------------------

describe `r(varlist)'


********** CLOSE OUTPUT
log close
