//==============================================================================
//	READ 2005 HOUSEHOLD DATA 
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

log using "C:\ihds\22626-0002-Data", replace

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

use "https://www.dropbox.com/s/cb2k345kmi5cp8k/22626-0002-Data.dta?dl=1" , clear


//------------------------------------------------------------------------------
// reassign variables by removing formatting ...
//------------------------------------------------------------------------------
/*
foreach v of var * {
	cap label val `v'
}
*/

do "`giturl'/supp-codes/22626-0002-Supplemental_syntax.do" // run supplemental file ...


// CHANGE FORMAT OF VARIABLES
destring IDHH, replace 
	format IDHH %19.0f 

// rename variables 
ren FM9B  FMA 
ren FM9C  FMB 
ren WA1   WSA
ren CG4   CGA 
ren FU11B WALKFUEL_FADU 
ren FU11D WALKFUEL_F 
ren FU11E WALKFUEL_M 
ren WA9A  WATERTIME_FADU
ren WA9C  WATERTIME_F
ren WA9D  WATERTIME_M 
ren CG5   CG5X
ren CG16  CG16X
ren CG20  CG20X
ren CG11  CG11X
ren CG9   CG9X
ren CG19  CG19X
ren CG21  CG21X
ren CG15  CG15X
ren CG7   CG7X
ren CG8   CG8X
ren MM4B  MM4W
ren MM1B  MM1W
ren MM2B  MM2W

replace FU1  = . if (FU1  >= -7 & FU1  <= -1)
replace FU1A = . if (FU1A >= -7 & FU1A <= -1)
replace FU1B = . if (FU1B >= -7 & FU1B <= -1)
replace FU1C = . if (FU1C >= -7 & FU1C <= -1) 
replace CGA  = . if CGA < 0 
replace FMA  = . if FMA < 0 
replace FMB  = . if FMB < 0 
replace WSA  = . if (WSA  >= 12 & WSA  <= -1)

gen GW = inlist( FMA, 1, 2, 3 ) | inlist( FMB, 1, 2, 3 ) 
	replace GW = . if mi( FMA ) & mi( FMB ) 
	label define yesno 0 "0 no" 1 "1 yes" 
	label values GW yesno  

local keepvars IDHH FU1 FU1A FU1B FU1C POOR FMA FMB GW WSA CGA WALKFUEL_FADU WALKFUEL_F WALKFUEL_M WATERTIME_FADU WATERTIME_F WATERTIME_M CG5X CG16X CG20X CG11X CG9X CG19X CG21X CG15X CG7X CG8X MM4W MM4C MM1W MM1C MM2W MM2C SA4 

keep `keepvars'

// rename all variables ... 
ds IDHH , not
rename (`r(varlist)') (=2005) 
rename * , lower 


// order variables alphabetically ... 
order _all, alphabetic

// describe the data & missings ... 
ds idhh , not
describe `r(varlist)'
mdesc 

//------------------------------------------------------------------------------
// check if there are duplicates 
//------------------------------------------------------------------------------
qui bys idhh : gen dup = cond(_N==1,0,_n)
	keep if dup == 0
	drop dup 

save 22626-0002-Data-out, replace



********** CLOSE OUTPUT
log close





