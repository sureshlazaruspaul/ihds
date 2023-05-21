//==============================================================================
//	READ 2011 VILLAGE DATA 
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

log using "C:\ihds\36151-0012-Data", replace

//------------------------------------------------------------------------------
// set directory
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

use "https://www.dropbox.com/s/hjeslyjump3vfe6/36151-0012-Data.dta?dl=1", clear


//------------------------------------------------------------------------------
// reassign variables by removing formatting ...
//------------------------------------------------------------------------------
/*
foreach v of var * {
	cap label val `v'
}
*/


do "`giturl'/supp-codes/36151-0012-Supplemental_syntax.do" // run supplemental file ...


//------------------------------------------------------------------------------
// transform/calc variables ... 
//------------------------------------------------------------------------------

destring VI4B, replace
	replace VI4B   = .           if VI4B < 1900 
	replace VI4B   = .           if VI4B > 2012 

// Compute first year of electricity 
gen VI4B12 = VI4B if VI4B > 0 
	replace VI4B12 = 2012 - VI4C if mi( VI4B12 )  
		drop VI4B VI4C 

// Create an ID variable that unites STATEID DISTID PSUID 
gen idvillage = (100+STATEID)*10000 + DISTID*100 + PSUID 

// Price of Firewood in Rupees
gen firewood_prc = VP7B 
	format firewood_prc %9.2f 

// Price of Kerosene (per liter) in Rupees
gen kerosene_prc = VP8A  
	format kerosene_prc %9.2f 
	
//------------------------------------------------------------------------------
// rename variables ... 
//------------------------------------------------------------------------------

ren VI4B12 fyrelec
ren VI4D   hourselec 
ren VMA1   healthsubcenter
ren VI18K  safewater 
ren VI18L  sanitation 

// rename all variables ... 
rename *, lower 

********** INDENTIFIER VARIABLES
local indvars idvillage 

********** VILLAGE VARIABLES
local villagevars vi4a fyrelec hourselec firewood_prc kerosene_prc healthsubcenter safewater sanitation 

********** CHANGE FORMAT OF VARIABLES
// destring IDHH, replace

********** KEEP RELEVANT VARIABLES
keep `indvars' `villagevars' 

// order variables alphabetically ... 
order _all, alphabetic

label variable idvillage    "Village ID" 
label variable firewood_prc "Firewood price (Rs.)"  
label variable kerosene_prc "Kerosene price (Rs.)"  
label variable vi4a         "Pct hh with Electricity" 
label variable fyrelec      "Electricity since YYYY" 
label variable hourselec    "Hours Per Day Electricity" 


//------------------------------------------------------------------------------
// check if there are duplicates 
//------------------------------------------------------------------------------
qui bys idvillage : gen dup = cond(_N==1,0,_n)
	keep if dup == 0
	drop dup 

local outfile "`dirpath'\36151-0012-Data_out.dta" 
save `outfile', replace

//------------------------------------------------------------------------------
// describe variables ... 
//------------------------------------------------------------------------------

describe `r(varlist)'


********** CLOSE OUTPUT
log close
