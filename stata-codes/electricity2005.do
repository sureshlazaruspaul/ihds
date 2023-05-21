//==============================================================================
// Mapping electricity in 2005 HHs to 2012 HHs using Link File
//	- Which Households in 2012 had electricity in 2005?
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

log using "C:\ihds\stata_files\electricity2005", replace

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
// get 2005 HH electricity ... 
//------------------------------------------------------------------------------

use "C:\data\ICPSR_22626\DS0002\22626-0002-Data.dta", clear

do "C:\data\ICPSR_22626\DS0002\22626-0002-Supplemental_syntax.do"

rename (HHID HHSPLITID FU1) (HHID05 HHSPLITID05 FU12005)

keep STATEID DISTID PSUID HHID05 HHSPLITID05 FU12005 

save el2005 , replace 

//------------------------------------------------------------------------------
// merge with linkedfile ... 
//------------------------------------------------------------------------------

use "C:\data\ICPSR_37382\DS0011\IHDS_HH_linkfile.dta", clear

sort STATEID DISTID PSUID HHID05 HHSPLITID05

merge m:1 STATEID DISTID PSUID HHID05 HHSPLITID05 using el2005 
	drop if _merge == 2 | missing( FU12005 ) // left join 
	drop _merge HHID05 HHSPLITID05 
	mi erase el2005

local outfile electricity2005
save `outfile', replace

//------------------------------------------------------------------------------
// describe variables ... 
//------------------------------------------------------------------------------

describe `r(varlist)'

********** CLOSE OUTPUT
log close
