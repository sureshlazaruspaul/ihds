//==============================================================================
// LINK FILE 2005 HH - 2012 HH
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

log using "C:\ihds\37382-0011-Data", replace

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
// 2012 HH file - keep HH identifiers only ...
//------------------------------------------------------------------------------

use "https://www.dropbox.com/s/yb0msszqzea1qf3/36151-0002-Data.dta?dl=1" , clear 

rename (HHID HHSPLITID) (HHID12 HHSPLITID12)

keep STATEID DISTID PSUID HHID12 HHSPLITID12 

sort STATEID DISTID PSUID HHID12 HHSPLITID12 // remove duplicates by all 
	quietly by STATEID DISTID PSUID HHID12 HHSPLITID12 : gen dup = cond(_N==1, 0, _n) 
	drop if dup > 0
	drop dup 

save file2012 , replace 

//------------------------------------------------------------------------------





//------------------------------------------------------------------------------
// 2005 HH file - keep HH identifiers only ...
//------------------------------------------------------------------------------

use "https://www.dropbox.com/s/cb2k345kmi5cp8k/22626-0002-Data.dta?dl=1" , clear 

rename (HHID HHSPLITID) (HHID05 HHSPLITID05)

keep STATEID DISTID PSUID HHID05 HHSPLITID05 

sort STATEID DISTID PSUID HHID05 HHSPLITID05 // remove duplicates by all 
	quietly by STATEID DISTID PSUID HHID05 HHSPLITID05 : gen dup = cond(_N==1, 0, _n) 
	drop if dup > 0
	drop dup 

save file2005 , replace 

//------------------------------------------------------------------------------






use "https://www.dropbox.com/s/493t3gvsh1ekfxe/37382-0011-Data.dta?dl=1" , clear

do "`giturl'/supp-codes/37382-0011-Supplemental_syntax.do" // run supplemental file ...

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

local filelist : dir . files "file*.dta" 
foreach f of local filelist {
	pe erase "`f'" 
}  

// Create an ID variable that unites STATEID DISTID PSUID 
gen idvillage = (100+STATEID)*10000 + DISTID*100 + PSUID  
	label variable idvillage "Village ID" 
	drop STATEID DISTID PSUID 

//------------------------------------------------------------------------------
// label variables ... 
//------------------------------------------------------------------------------

label variable HHID05       "HHID (2005)" 
label variable HHID12       "HHID (2012)" 
label variable HHSPLITID05  "HHSPLITID (2005)" 
label variable HHSPLITID12  "HHSPLITID (2012)" 

rename *, lower

local outfile "`dirpath'\IHDS_HH_linkfile.dta"
save `outfile', replace

* export delimited using "`dirpath'\IHDS_HH_linkfile.csv", replace

//------------------------------------------------------------------------------
// describe variables ... 
//------------------------------------------------------------------------------

describe `r(varlist)'
     


********** CLOSE OUTPUT
log close
