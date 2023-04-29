//==============================================================================
// Merge Transmission Lines data with District Demographics Data
//==============================================================================
//	Written	by Suresh Paul, Algorithm Basics
//	version: 04/29/2023
//==============================================================================

clear all 
capture log close 
set more off 

//------------------------------------------------------------------------------
// open logfile ... 
//------------------------------------------------------------------------------

log using "C:\ihds\stata_files\districtinfo", replace

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
// get District Demographics data ... 
//------------------------------------------------------------------------------
// Github url
local giturl = "https://raw.githubusercontent.com/sureshlazaruspaul/ihds/main/stata-codes" 

import delimited "`giturl'/districtdata.csv" , clear

rename name districtname

save districtdata , replace 


//------------------------------------------------------------------------------
// get Transmission Line data ... 
//------------------------------------------------------------------------------

import delimited "`giturl'/tlines.csv" , clear

rename district districtname 

sort districtname

merge m:1 districtname using districtdata 
	drop if _merge == 2 // left join 
	drop _merge  
	mi erase districtdata

local varlist nlines lengthlines nvillages_inhabited nvillages_uninhabited ntowns nhhs nmales nfemales area_sq_km 

foreach k of local varlist {
	replace `k' = . if inlist( `k' , -1 ) 
}

gen population = nmales + nfemales if !missing( nmales ) & !missing( nfemales )

gen population_sq_km = population / area_sq_km if !missing( population ) & !missing( area_sq_km )

egen nmiss = rowmiss( `varlist' population population_sq_km )
	drop if nmiss > 0
	drop nmiss 

local dropvars nvillages_inhabited nvillages_uninhabited ntowns nhhs nmales nfemales 
drop `dropvars'

sort districtname

label variable districtname       "District Name" 
label variable stateid            "State ID" 
label variable distid             "District ID" 
label variable nlines             "Number of transmission lines (district-wise)" 
label variable lengthlines        "Total transmission line length (district-wise)" 
label variable area_sq_km         "Area (sq-km, district-wise)" 
label variable population         "Population (district-wise)" 
label variable population_sq_km   "Population density (district-wise)" 

export delimited using "C:\ihds\stata_files\data\census_elec.csv", replace

local outfile census_elec
save `outfile', replace

//--------------i--------------------------------------------------------------

describe `r(varlist)'

********** CLOSE OUTPUT
log close
