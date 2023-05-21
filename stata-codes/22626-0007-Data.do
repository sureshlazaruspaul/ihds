//==============================================================================
//	READ 2005 VILLAGE DATA 
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

log using "C:\ihds\22626-0007-Data", replace

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

use "https://www.dropbox.com/s/k9pwpwb0pb49miy/22626-0007-Data.dta?dl=1" , clear


//------------------------------------------------------------------------------
// reassign variables by removing formatting ...
//------------------------------------------------------------------------------
/*
foreach v of var * {
	cap label val `v'
}
*/

do "`giturl'/supp-codes/22626-0007-Supplemental_syntax.do" // run supplemental file ...

// Compute first year of electricity
gen VI4B05 = 2005 - VI4B if VI4B >= 0 // e.g., if VI4B=25, then the village has electricity since 1980 (2005-25). 
	drop VI4B 

// Create an ID variable that unites STATEID DISTID PSUID 
gen idvillage = (100+STATEID)*10000 + DISTID*100 + PSUID 

// Price of Firewood in Rupees
gen firewood_prc = VP5 / VP5A 
	format firewood_prc %9.2f 

// Price of Kerosene (per liter) in Rupees
gen kerosene_prc = VP6 
	format kerosene_prc %9.2f 

label variable idvillage    "Village ID" 
label variable firewood_prc "2005 Firewood price (Rs.)"  
label variable kerosene_prc "2005 Kerosene price (Rs.)"  
label variable VI4A         "2005 Pct hh with Electricity" 
label variable VI4B05       "2005 Electricity since YYYY" 
label variable VI4C         "2005 Hours Per Day Electricity" 

// rename variables 
ren VI4A         pcthhelec
ren VI4B05       fyrelec
ren VI4C         hourselec
ren VMA1         healthsubcenter
ren VI15L        safewater
ren VI15M        sanitation

local keepvars idvillage pcthhelec fyrelec hourselec firewood_prc kerosene_prc healthsubcenter safewater sanitation

keep `keepvars'

// rename all variables ... 
ds idvillage , not
rename (`r(varlist)') (=2005) 
rename * , lower 

// order variables alphabetically ... 
order _all, alphabetic

// describe the data & missings ... 
describe `r(varlist)'
mdesc 


//------------------------------------------------------------------------------
// check if there are duplicates 
//------------------------------------------------------------------------------
qui bys idvillage : gen dup = cond(_N==1,0,_n)
	keep if dup == 0
	drop dup 

save 22626-0007-Data_out, replace

********** CLOSE OUTPUT
log close
