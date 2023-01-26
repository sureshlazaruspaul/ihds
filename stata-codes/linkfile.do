//==============================================================================
// LINK FILE 2005 - 2012
//==============================================================================
//	Written	by Suresh Paul, Algorithm Basics
//	version: 01/26/2023
//==============================================================================

clear all 
capture log close 
set more off 

//------------------------------------------------------------------------------
// open logfile ... 
//------------------------------------------------------------------------------

log using "C:\ICPSR_37382\DS0011\37382-0011-Data", replace

//------------------------------------------------------------------------------
// set dir for data
//------------------------------------------------------------------------------

local dirpath "C:\ICPSR_37382\DS0011"

cd `dirpath'


//------------------------------------------------------------------------------
// append to an empty dataset 
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

//------------------------------------------------------------------------------
// Program pe: Print Execute
//------------------------------------------------------------------------------

program define pe
	if `"`0'"' != " " {
		display as text `"`0'"'
		`0'
		display("")
	}
end





//------------------------------------------------------------------------------
// 2012 HH file : get all identifiers 
//------------------------------------------------------------------------------

use "C:\ICPSR_36151\DS0002\36151-0002-Data.dta" , clear 

rename (HHID HHSPLITID) (HHID12 HHSPLITID12)

keep STATEID DISTID PSUID HHID12 HHSPLITID12 

sort STATEID DISTID PSUID HHID12 HHSPLITID12 // remove duplicates by all 
	quietly by STATEID DISTID PSUID HHID12 HHSPLITID12 : gen dup = cond(_N==1, 0, _n) 
	drop if dup > 0
	drop dup 

save file2012 , replace 

//------------------------------------------------------------------------------
// 2005 HH file : get all identifiers  
//------------------------------------------------------------------------------

use "C:\ICPSR_22626\DS0002\22626-0002-Data.dta" , clear 

rename (HHID HHSPLITID) (HHID05 HHSPLITID05)

keep STATEID DISTID PSUID HHID05 HHSPLITID05 

sort STATEID DISTID PSUID HHID05 HHSPLITID05 // remove duplicates by all 
	quietly by STATEID DISTID PSUID HHID05 HHSPLITID05 : gen dup = cond(_N==1, 0, _n) 
	drop if dup > 0
	drop dup 

save file2005 , replace 

//------------------------------------------------------------------------------
// Construct linkedfile 
//------------------------------------------------------------------------------
//		- gives HHID in 2005 that corresponds with HHID in 2012
//		- gives HHSPLITID in 2005 that corresponds with HHSPLITID in 2012
//------------------------------------------------------------------------------

sysuse 37382-0011-Data , clear

do 37382-0011-Supplemental_syntax.do // run supplemental file ...


keep STATEID DISTID PSUID HHID HHID2005 HHID2012 HHSPLITID HHSPLITID2005 HHSPLITID2012

g HHID12 = HHID 
g HHSPLITID12 = HHSPLITID

sort STATEID DISTID PSUID HHID12 HHSPLITID12 

merge m:1 STATEID DISTID PSUID HHID12 HHSPLITID12 using file2012
	drop if _merge == 2 // left join
	drop _merge 

g HHID05 = HHID2005
g HHSPLITID05 = HHSPLITID2005

sort STATEID DISTID PSUID HHID05 HHSPLITID05 

merge m:1 STATEID DISTID PSUID HHID05 HHSPLITID05 using file2005
	drop if _merge == 2 // left join
	drop _merge HHID HHID2005 HHID2012 HHSPLITID HHSPLITID2005 HHSPLITID2012

sort STATEID DISTID PSUID HHID05 HHSPLITID05 HHID12 HHSPLITID12 // remove duplicates by all 
	quietly by STATEID DISTID PSUID HHID05 HHSPLITID05 HHID12 HHSPLITID12 : gen dup = cond(_N==1, 0, _n) 
	drop if dup > 1
	drop dup 

// check again for duplicates ... must be zero 
sort STATEID DISTID PSUID HHID05 HHSPLITID05 HHID12 HHSPLITID12 // remove duplicates by all 
	quietly by STATEID DISTID PSUID HHID05 HHSPLITID05 HHID12 HHSPLITID12 : gen dup = cond(_N==1, 0, _n) 
	drop if dup > 0
	drop dup 

local filelist : dir . files "file*.dta" 
foreach f of local filelist {
	pe erase "`f'" 
}  

//------------------------------------------------------------------------------
// label variables ... 
//------------------------------------------------------------------------------

label variable HHID05       "HHID (2005)" 
label variable HHID12       "HHID (2012)" 
label variable HHSPLITID05  "HHSPLITID (2005)" 
label variable HHSPLITID12  "HHSPLITID (2012)" 


local outfile IHDS_HH_linkfile
save `outfile', replace


//------------------------------------------------------------------------------
// describe variables ... 
//------------------------------------------------------------------------------

describe `r(varlist)'
     


********** CLOSE OUTPUT
log close
