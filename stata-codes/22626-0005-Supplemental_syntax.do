/*-------------------------------------------------------------------------*
 |                                                                         
 |            STATA SUPPLEMENTAL SYNTAX FILE FOR ICPSR 22626
 |              INDIA HUMAN DEVELOPMENT SURVEY (IHDS), 2005
 |                     (DATASET 0005: PRIMARY SCHOOL)
 |
 |
 | This Stata missing value recode program is provided for optional use with
 | the Stata system version of this data file as distributed by ICPSR.
 | The program replaces user-defined numeric missing values (e.g., -9)
 | with generic system missing "."  Note that Stata allows you to specify
 | up to 27 unique missing value codes.  Only variables with user-defined
 | missing values are included in this program.
 |
 | To apply the missing value recodes, users need to first open the
 | Stata data file on their system, apply the missing value recodes if
 | desired, then save a new copy of the data file with the missing values
 | applied.  Users are strongly advised to use a different filename when
 | saving the new file.
 |
 *------------------------------------------------------------------------*/

replace SC1 = . if (SC1 == -1)
replace SCDATE = . if (SCDATE == -1)
replace SC11 = . if (SC11 == -1)
replace PSSCH = . if (PSSCH == -1)
replace PS1 = . if (PS1 == -1)
replace PS2 = . if (PS2 == -1)
replace PS3A = . if (PS3A == -1)
replace PS4 = . if (PS4 == -1)
replace PS5 = . if (PS5 >= -7 & PS5 <= -1)
replace PS6 = . if (PS6 >= -7 & PS6 <= -1)
replace PS6A = . if (PS6A >= -7 & PS6A <= -1)
replace PS6B = . if (PS6B >= -7 & PS6B <= -1)
replace PS9 = . if (PS9 >= -7 & PS9 <= -1)
replace PS11A = . if (PS11A == -1)
replace PS11B = . if (PS11B == -1)
replace PS11C = . if (PS11C == -1)
replace PS11D = . if (PS11D == -1)
replace PS12 = . if (PS12 == -1)
replace PS13A = . if (PS13A == -1)
replace PS13B = . if (PS13B == -1)
replace PS13C = . if (PS13C == -1)
replace PS14B = . if (PS14B >= -7 & PS14B <= -1)
replace PS15A = . if (PS15A >= -7 & PS15A <= -1)
replace PS15B = . if (PS15B >= -7 & PS15B <= -1)
replace PS15C = . if (PS15C >= -7 & PS15C <= -1)
replace PS16A = . if (PS16A >= -7 & PS16A <= -1)
replace PS16B = . if (PS16B >= -7 & PS16B <= -1)
replace PS16C1 = . if (PS16C1 >= -7 & PS16C1 <= -1)
replace PS16C2 = . if (PS16C2 >= -7 & PS16C2 <= -1)
replace PS16D1 = . if (PS16D1 >= -7 & PS16D1 <= -1)
replace PS16D2 = . if (PS16D2 >= -7 & PS16D2 <= -1)
replace PS17A = . if (PS17A >= -7 & PS17A <= -1)
replace PS17B = . if (PS17B >= -7 & PS17B <= -1)
replace PS17C = . if (PS17C >= -7 & PS17C <= -1)
replace PS17D = . if (PS17D >= -7 & PS17D <= -1)
replace PS17E = . if (PS17E >= -7 & PS17E <= -1)
replace PS17F = . if (PS17F >= -7 & PS17F <= -1)
replace PS17G = . if (PS17G >= -7 & PS17G <= -1)
replace PS17H = . if (PS17H >= -7 & PS17H <= -1)
replace PS17I = . if (PS17I >= -7 & PS17I <= -1)
replace PS17J = . if (PS17J >= -7 & PS17J <= -1)
replace PS19GA = . if (PS19GA == -1)
replace PS19GB = . if (PS19GB == -1)
replace PS19GC = . if (PS19GC == -1)
replace PS19SA = . if (PS19SA == -1)
replace PS19SB = . if (PS19SB == -1)
replace PS19SC = . if (PS19SC == -1)
replace PS20A = . if (PS20A >= -7 & PS20A <= -1)
replace PS20B = . if (PS20B >= -7 & PS20B <= -1)
replace PS20C = . if (PS20C >= -7 & PS20C <= -1)
replace PS21A = . if (PS21A >= -7 & PS21A <= -1)
replace PS21B = . if (PS21B >= -7 & PS21B <= -1)
replace PS21C = . if (PS21C >= -7 & PS21C <= -1)
replace PS22A = . if (PS22A >= -7 & PS22A <= -1)
replace PS22B = . if (PS22B >= -7 & PS22B <= -1)
replace PS22C = . if (PS22C >= -7 & PS22C <= -1)
replace PS23A = . if (PS23A >= -7 & PS23A <= -1)
replace PS23B = . if (PS23B >= -7 & PS23B <= -1)
replace PS23C = . if (PS23C >= -7 & PS23C <= -1)
replace PS24 = . if (PS24 >= -7 & PS24 <= -1)
replace PS25 = . if (PS25 >= -7 & PS25 <= -1)
replace PS26 = . if (PS26 >= -7 & PS26 <= -1)
replace PS27 = . if (PS27 >= -7 & PS27 <= -1)
replace PS28A = . if (PS28A >= -7 & PS28A <= -1)
replace PS28B = . if (PS28B >= -7 & PS28B <= -1)
replace PS28C = . if (PS28C >= -7 & PS28C <= -1)
replace PS29A = . if (PS29A >= -7 & PS29A <= -1)
replace PS29B = . if (PS29B >= -7 & PS29B <= -1)
replace PS29C = . if (PS29C >= -7 & PS29C <= -1)
replace PS29D = . if (PS29D >= -7 & PS29D <= -1)
replace PS29E = . if (PS29E >= -7 & PS29E <= -1)
replace SO31 = . if (SO31 >= -7 & SO31 <= -1)
replace SO32A = . if (SO32A >= -7 & SO32A <= -1)
replace SO32M = . if (SO32M >= -7 & SO32M <= -1)
replace SO32B = . if (SO32B >= -7 & SO32B <= -1)
replace SO32C = . if (SO32C >= -7 & SO32C <= -1)
replace SO32D = . if (SO32D >= -7 & SO32D <= -1)
replace SO33A = . if (SO33A >= -7 & SO33A <= -1)
replace SO33B = . if (SO33B >= -7 & SO33B <= -1)
replace SO34 = . if (SO34 >= -7 & SO34 <= -1)


