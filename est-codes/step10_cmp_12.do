//==============================================================================
//	STEP 10: CMP BIVARIATE PROBIT REGRESSIONS -WEIGHTED (2012) 
//==============================================================================
//  Instructions:
//------------------------------------------------------------------------------
//  (1) Download all codes to <C:\ihds> folder and run from there.
//==============================================================================
//	Written	by Suresh Paul, Algorithm Basics LLC, sureshlazaruspaul@gmail.com
//	version: 05/22/2023
//==============================================================================



clear all 
capture log close 
set more off 

//------------------------------------------------------------------------------
// open logfile ... 
//------------------------------------------------------------------------------

log using "C:\ihds\step10_cmp_12", replace

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



/*------------------------------------------------------------------------------
 control variables used 
--------------------------------------------------------------------------------
 copc1               // ln(copc) 
 cs4x                // Distance to School (kms) 
 nchildren           // Number of children in HH
 hheduc              // Education of HH Head
 hhfemale            // Female HH head dummy 
 hhage               // Age of HH head
 mdm                 // midday meals? 
 female              // Female dummy 
 age                 // Age of child (8, 9, 10, 11) 
 brahmin forward othback dalit adivasi mcsj // caste & religion dummies
--------------------------------------------------------------------------------
 Instruments:
--------------------------------------------------------------------------------
vi4a                 // Proportion of HHs electrified in a village
tlinesdensity1       // Trasmission line length density (Line length per sqkm)
------------------------------------------------------------------------------*/



/*------------------------------------------------------------------------------
 define local macros ...
------------------------------------------------------------------------------*/

local depvars `" "agematch_ed5x" "read" "math" "write" "' // dependent variables ... 

local cvars  age i.female copc1 nchildren hheduc i.hhfemale hhage cs4x mdm i.privsch 
local cvars1 age   female copc1 nchildren hheduc   hhfemale hhage cs4x mdm   privsch 

local ovars  i.stateid i.groups8x // state, caste, religion, year dummies 

local instr `" "vi4a tlinesdensity1" "' // instruments used

global sex = 0 // 0 = male, 1 = female 







timer on 1 

foreach m of local depvars { 

	pe use 36151 , clear 

        //--------------------------------------------------------------------------
        // 1. data restrictions .. 
        //--------------------------------------------------------------------------

		pe gen sample = inlist(adolescents, 1)     & /// age between 8 and 11 
						inlist(rural      , 1)     & /// urban = 0
						inlist(ed4x       , 1)       //  currently enrolled in school

			pe tab sample, missing 
        //--------------------------------------------------------------------------




        //--------------------------------------------------------------------------
        // 2. drop missing obervations of all study variables ..
        //--------------------------------------------------------------------------
		local n_instr : word count `instr'

        local inst // instruments array 
		forval i = 1 / `n_instr' {
			local inst `inst' `: word `i' of `instr''
		} 

		gen missing = 0

        local x
        local x  `m' `cvars1' fu1 `inst'
        foreach l of local x {
			pe replace missing = 1 if mi( `l' )
		} 

		pe replace sample = 0 if inlist(sample, 1) & inlist(missing, 1) 
			pe drop missing 
			pe tab sample, missing 
        //--------------------------------------------------------------------------





        //--------------------------------------------------------------------------
        // 3. multicollinearity check: states with 100% electrification 
        //--------------------------------------------------------------------------
        pe tabulate stateid 
        pe bys stateid: egen meanfu1 = mean( fu1 ) if inlist( sample, 1 )
        pe tabulate stateid if meanfu1 == 1 // which states will be dropped?

		pe replace sample = 0 if inlist(sample, 1) & inlist(meanfu1, 1) 
			pe drop meanfu1 
			pe tab sample, missing 
        //--------------------------------------------------------------------------






        //--------------------------------------------------------------------------
        // 4. calculate no. of PSUs in each STRATA 
        //--------------------------------------------------------------------------
		pe bys stateid distid psuid : gen uniqpsu = _n == 1 
			pe bys stateid distid : replace uniqpsu = sum(uniqpsu) 
			pe bys stateid distid : replace uniqpsu = uniqpsu[_N] 

		// must be more than one PSU in each STRATA 
		pe replace sample = 0 if inlist(sample, 1) & uniqpsu <= 1
			pe drop uniqpsu 
			pe tab sample, missing 
        //--------------------------------------------------------------------------




        //--------------------------------------------------------------------------
        // 5. describe variables ... 
        //--------------------------------------------------------------------------
        pe mdesc `x' 
        //--------------------------------------------------------------------------





        //--------------------------------------------------------------------------
        // 6. recalibrating sample ... 
        //--------------------------------------------------------------------------
        local k  `x' stateid groups8x 
        foreach f of local k {
			pe replace sample = . if inlist(sample, 1) & mi( `f' ) 
		} 

		* adolescents rural ed4x
		pe g cond1 = inlist(adolescents, 1, .) & inlist(rural, 1, .) & inlist(ed4x, 1, .)
			pe replace sample = . if !inlist(sample, 1) & cond1 

		pe tab sample, missing 
        //--------------------------------------------------------------------------




        di _n "-----------------------------------------------------------------" 
		di    "{title:BIVARIATE PROBIT REGRESSIONS}"
        di    "-----------------------------------------------------------------" 
        di    "Education variable: `m'" 
        di    "-----------------------------------------------------------------"

		svyset, clear

		// set survey
		pe egen newstrat = group( stateid distid )  

		pe svyset psuid [pw = weight] , strata(newstrat) singleunit(scaled) 

		pe cmp setup

		pe svy, subpop(sample) : cmp ( `m' = fu1 `cvars' `ovars' ) ( fu1 = `cvars' `ovars' `inst') , ind($cmp_probit $cmp_probit) qui 

		pe replace `m' = 1 

		// marginal effect on probability of (1) 
		pe eststo: margins, dydx(fu1) force subpop(if sample==1) // marginal effects

} 

	
// output coefficients to Latex
esttab using step10_cmp_12.tex , b(a6) se(6) starlevels("\sym{*}" 0.100 "\sym{**}" 0.050 "\sym{***}" 0.010) replace 

esttab, cells(_sigsign) nogap starlevels("+/-" 0.10 "++/--" 0.05 "+++/---" 0.01)
	eststo clear


timer off 1 
timer list 1 

local min = int(r(t1)/60)  
local sec = mod(r(t1),60)

//------------------------------------------------------------------------------
// total runtime for this program : 
//------------------------------------------------------------------------------
di "total runtime for this program : `min' minutes `sec' seconds"  

timer clear 

	
// CLOSE OUTPUT
log close
