//==============================================================================
//	READ 2011 SCHOOL DATA 
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

log using "C:\ihds\36151-0009-Data", replace

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

use "https://www.dropbox.com/s/aevp3m69m80yi1z/36151-0009-Data.dta?dl=1", clear


//------------------------------------------------------------------------------
// reassign variables by removing formatting ...
//------------------------------------------------------------------------------
/*
foreach v of var * {
	cap label val `v'
}
*/


do "`giturl'/supp-codes/36151-0009-Supplemental_syntax.do" // run supplemental file ...


//------------------------------------------------------------------------------
// transform/calc variables ... 
//------------------------------------------------------------------------------

// VILLAGE IDENTIFIER
g IDPSU = STATEID * 10000 + DISTID * 100 + PSUID 

// DATA RESTRICTION
//	- drop if midday meal information is missing
drop if missing( PS10 )

// GOVT SCHOOL DUMMY
g GOVTSCH = ( SQGOVT == 1 )
*replace GOVTSCH = . if missing( SQGOVT )
tab SQGOVT GOVTSCH , missing

// PRIV SCHOOL DUMMY 
g PRIVSCH = ( SQGOVT == 2 )
*replace PRIVSCH = . if missing( SQGOVT )
tab SQGOVT PRIVSCH , missing

// MIDDAY MEAL DUMMY
g MDM = ( PS10 == 1 ) 
*replace MDM = . if missing( PS10 )
tab PS10 MDM , missing

// GOVT SCHOOL w/ MIDDAY MEAL DUMMY
g GOVTSCH_MDM = ( SQGOVT == 1 & PS10 == 1 )
*replace GOVTSCH_MDM = . if missing( SQGOVT ) | missing( PS10 )
tab SQGOVT GOVTSCH_MDM , missing
tab PS10 GOVTSCH_MDM , missing

// PRIV SCHOOL w/ MIDDAY MEAL DUMMY
g PRIVSCH_MDM = ( SQGOVT == 2 & PS10 == 1 )
*replace PRIVSCH_MDM = . if missing( SQGOVT ) | missing( PS10 )
tab SQGOVT PRIVSCH_MDM , missing
tab PS10 PRIVSCH_MDM , missing

//------------------------------------------------------------------------------

// sum by village 
collapse (sum) GOVTSCH PRIVSCH MDM GOVTSCH_MDM PRIVSCH_MDM , by( IDPSU )

// TOTAL NUMBER OF SCHOOLS in VILLAGE
g TOTSCH = GOVTSCH + PRIVSCH

// PROP OF SCHOOLS in VILLAGE OFFERING MIDDAY MEALS
replace MDM = MDM / TOTSCH
replace GOVTSCH_MDM = GOVTSCH_MDM / GOVTSCH 
replace PRIVSCH_MDM = PRIVSCH_MDM / PRIVSCH

local miss2zero MDM GOVTSCH_MDM PRIVSCH_MDM

foreach k of local miss2zero {
	replace `k' = 0 if missing( `k' )
		format `k' %9.4f 
}


//------------------------------------------------------------------------------
// rename variables ... 
//------------------------------------------------------------------------------

* none

********** INDENTIFIER VARIABLES
local indvars IDPSU 

********** SCHOOL VARIABLES
local schoolvars MDM GOVTSCH_MDM PRIVSCH_MDM 



********** CHANGE FORMAT OF VARIABLES
// destring IDHH, replace

********** KEEP RELEVANT VARIABLES
keep `indvars' `schoolvars' 


// rename all variables ... 
rename *, lower 

// order variables alphabetically ... 
order _all, alphabetic

local outfile "`dirpath'\36151-0009-Data_out.dta" 
save `outfile', replace

//------------------------------------------------------------------------------
// describe variables ... 
//------------------------------------------------------------------------------

describe `r(varlist)'

********** CLOSE OUTPUT
log close
