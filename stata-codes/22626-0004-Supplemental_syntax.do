/*-------------------------------------------------------------------------*
 |                                                                         
 |            STATA SUPPLEMENTAL SYNTAX FILE FOR ICPSR 22626
 |              INDIA HUMAN DEVELOPMENT SURVEY (IHDS), 2005
 |                      (DATASET 0004: NON-RESIDENT)
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

replace IDHNR = . if (IDHNR >= -6 & IDHNR <= -1)
replace NHNR = . if (NHNR >= -6 & NHNR <= -1)
replace STATEID = . if (STATEID >= -6 & STATEID <= -1)
replace DISTID = . if (DISTID >= -6 & DISTID <= -1)
replace PSUID = . if (PSUID >= -6 & PSUID <= -1)
replace HHID = . if (HHID >= -6 & HHID <= -1)
replace HHSPLITID = . if (HHSPLITID >= -6 & HHSPLITID <= -1)
replace NR1 = . if (NR1 >= -6 & NR1 <= -1)
replace NR2 = . if (NR2 >= -6 & NR2 <= -1)
replace NR4 = . if (NR4 >= -6 & NR4 <= -1)
replace NR5 = . if (NR5 >= -6 & NR5 <= -1)
replace NR6 = . if (NR6 >= -6 & NR6 <= -1)
replace NR7 = . if (NR7 >= -6 & NR7 <= -1)
replace NR8 = . if (NR8 == -6)
replace NR9 = . if (NR9 == -6)
replace NR10 = . if (NR10 == -3 | NR10 == -4 | NR10 == -6)
replace NR11 = . if (NR11 == -4 | NR11 == -6)
replace NR12 = . if (NR12 == -1)
replace NR13 = . if (NR13 == -6 | NR13 == -5 | NR13 == -1)
replace PERSONID = . if (PERSONID >= -6 & PERSONID <= -1)
replace NRMPRO3 = . if (NRMPRO3 >= -6 & NRMPRO3 <= -1)
replace NRMPRO4 = . if (NRMPRO4 >= -6 & NRMPRO4 <= -1)
replace NRMPRO5 = . if (NRMPRO5 >= -6 & NRMPRO5 <= -1)
replace NRMPRO6 = . if (NRMPRO6 >= -6 & NRMPRO6 <= -1)
replace NRMPRO7 = . if (NRMPRO7 == -1)


