//==============================================================================
//	READ 2011 HOUSEHOLD DATA 
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

log using "C:\ihds\36151-0002-Data", replace

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
// read data ... 
//------------------------------------------------------------------------------

use "https://www.dropbox.com/s/yb0msszqzea1qf3/36151-0002-Data.dta?dl=1", clear


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
	
// rename variables 
ren FM13A    FMA 
ren FM13B    FMB 
ren DISTRICT DISTNAME 
ren WA1A     WSA 
ren FU14A2   WALKFUEL_FADU 
ren FU14B2   WALKFUEL_MADU 
ren FU14C2   WALKFUEL_F 
ren FU14D2   WALKFUEL_M 
ren FU14A1   FUELFREQ_FADU 
ren FU14B1   FUELFREQ_MADU 
ren FU14C1   FUELFREQ_F 
ren FU14D1   FUELFREQ_M
ren WA6A     WATERTIME_FADU  
ren WA6B     WATERTIME_MADU  
ren WA6C     WATERTIME_F 
ren WA6D     WATERTIME_M 
ren CG6      CGA
ren CG7      CG5X
ren CG9      CG7X
ren CG10     CG8X
ren CG11     CG9X
ren CG13     CG11X
ren CG17     CG15X
ren CG18     CG16X
ren CG22     CG19X
ren CG23     CG20X
ren CG24     CG21X

replace CGA  = . if CGA < 0 
replace FMA  = . if FMA < 0 
replace FMB  = . if FMB < 0 
replace WSA  = . if (WSA  >= 12 & WSA  <= -1)

gen GW = inlist( FMA, 1, 2, 3 ) | inlist( FMB, 1, 2, 3 ) 
	replace GW = . if mi( FMA ) & mi( FMB ) 
	label variable GW "Ground Water available (Yes/No)"
	label define yesno 0 "0 no" 1 "1 yes" 
	label values GW yesno  

********** KEEP RELEVANT VARIABLES
keep IDHH FU1 FU1A FU1B FU1C POOR FMA FMB GW WSA CGA WALKFUEL_FADU WALKFUEL_MADU WALKFUEL_F WALKFUEL_M FUELFREQ_FADU FUELFREQ_MADU FUELFREQ_F FUELFREQ_M WATERTIME_FADU WATERTIME_MADU WATERTIME_F WATERTIME_M CG5X CG16X CG20X CG11X CG9X CG19X CG21X CG15X CG7X CG8X CGCOOLING MM4W MM4C MM1W MM1C MM2W MM2C SA4 


// rename all variables ... 
rename *, lower 

// order variables alphabetically ... 
order _all, alphabetic


local outfile "`dirpath'\36151-0002-Data_out.dta" 
save `outfile', replace

//------------------------------------------------------------------------------
// describe variables ...  
//------------------------------------------------------------------------------

describe `r(varlist)'


********** CLOSE OUTPUT
log close
