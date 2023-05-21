//==============================================================================
// Mapping electricity in 2005 HHs to 2012 HHs using Link File
//	- Which Households in 2012 had electricity in 2005?
//==============================================================================
//  Instructions:
//------------------------------------------------------------------------------
//  (1) Download all codes to <C:\ihds> folder and run from there.
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

log using "C:\ihds\electricity2005", replace

//------------------------------------------------------------------------------
// set directory ...
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
// get 2005 HH electricity ... 
//------------------------------------------------------------------------------

use "https://www.dropbox.com/s/cb2k345kmi5cp8k/22626-0002-Data.dta?dl=1" , clear 


do "`giturl'/supp-codes/22626-0002-Supplemental_syntax.do"

rename (HHID HHSPLITID FU1) (HHID05 HHSPLITID05 FU12005)

keep STATEID DISTID PSUID HHID05 HHSPLITID05 FU12005 

save el2005 , replace 




//------------------------------------------------------------------------------
// merge with linkedfile ... 
//------------------------------------------------------------------------------

use "`giturl'/stata-codes/IHDS_HH_linkfile.dta", clear

sort STATEID DISTID PSUID HHID05 HHSPLITID05

merge m:1 STATEID DISTID PSUID HHID05 HHSPLITID05 using el2005 
	drop if _merge == 2 | missing( FU12005 ) // left join 
	drop _merge HHID05 HHSPLITID05 
	mi erase el2005


// rename all variables ... 
rename *, lower 

// order variables alphabetically ... 
order _all, alphabetic


local outfile "`dirpath'\electricity2005.dta" 
save `outfile', replace

//------------------------------------------------------------------------------
// describe variables ... 
//------------------------------------------------------------------------------

describe `r(varlist)'

********** CLOSE OUTPUT
log close
