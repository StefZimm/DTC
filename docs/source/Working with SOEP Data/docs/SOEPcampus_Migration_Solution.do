*******************************************
* SOEPcampus - Working with Migration Data
* Example Exercises
* February 2018
*******************************************

** Automatische Weiterscrollen aktiviert
set more off

***********************************************
* Set relative paths to the working directory
***********************************************
global AVZ 						"H:\material"
global MY_IN_PATH		        "Z:\DATA\soep33.1_de\stata" 
global MY_IN_PATH_long          "$AVZ\Daten\SOEP32_long_10\"
global MY_DO_FILES				"$AVZ\do\"
global MY_LOG_OUT				"$AVZ\log\"
global MY_OUT_DATA  			"$AVZ\output\"
global MY_OUT_TEMP				"$AVZ\temp\"


*** Exercise 1 ******************************************************************

/*
a)	In which variable can you find information about the status of each person when they immigrated to Germany?
*/

* Immigration status is stored in the variable biimgrp.

use $MY_IN_PATH\bioimmig.dta, clear

/*
b)	Identify this variable in the BIOIMMIG data set and load it from the data set, together with the person number and the survey year.
*/

use persnr syear biimgrp using $MY_IN_PATH\bioimmig.dta, clear

/*
c)	What are the values of this variable? 
*/

tab biimgrp, m //Characteristics of the variable are examined.

/*
                  BI: Immigration Group |      Freq.     Percent        Cum.
----------------------------------------+-----------------------------------
[-5] Not included in this version of th |         96        0.15        0.15
                    [-2] Does not apply |     40,795       63.99       64.14
                         [-1] No Answer |        484        0.76       64.90
[1] East German (last time asked in 199 |      1,595        2.50       67.40
                      [2] Ethnic German |      9,082       14.25       81.64
               [3] German, Lived Abroad |        503        0.79       82.43
          [4] EU-Member (up to 2009 EG) |      2,815        4.42       86.85
                      [5] Asylum Seeker |      2,238        3.51       90.36
          [6] Other Foreign Nationality |      6,147        9.64      100.00
----------------------------------------+-----------------------------------
                                  Total |     63,755      100.00
*/

/*
d)	On the basis of this variable, generate the variable "Escape", which only distinguishes between three groups:
    0 = Cases where no information is available
    1 = All persons without escape background 
    2 = Asylum seekers / refugees
*/

recode biimgrp (-5 -2 -1 = 0 "No Answer") (1 2 3 4 6 = 1 "no Escape") (5 = 2 "Escape"), gen(Escape)
tab biimgrp Escape, m // biimgrp and escape are compared.

/*
                      |      RECODE of biimgrp (BI:
                      |        Immigration Group)
BI: Immigration Group | Keine Ang  Keine Flu     Flucht |     Total
----------------------+---------------------------------+----------
[-5] Not included in  |        96          0          0 |        96 
  [-2] Does not apply |    40,795          0          0 |    40,795 
       [-1] No Answer |       484          0          0 |       484 
[1] East German (last |         0      1,595          0 |     1,595 
    [2] Ethnic German |         0      9,082          0 |     9,082 
[3] German, Lived Abr |         0        503          0 |       503 
[4] EU-Member (up to  |         0      2,815          0 |     2,815 
    [5] Asylum Seeker |         0          0      2,238 |     2,238 
[6] Other Foreign Nat |         0      6,147          0 |     6,147 
----------------------+---------------------------------+----------
                Total |    41,375     20,142      2,238 |    63,755 

*/

/*
e)	It may happen that tinitially there is no information on the status of 
*   immigration, but this will change in a later year. Limit the data record to 
*   the last observation that is available for the respective person, since this 
*   way the specification with the most information content is used. 
*/

bysort persnr: egen syear_max = max(syear) //A variable is created, which shows the last existing yearly observation
keep if syear_max == syear //Annual observations which are not the last observation are deleted.


/*
f)	Save the generated data record on your personal drive temporarily 
*/

save $MY_OUT_TEMP\biimgrp.dta, replace

*** Aufgabe 2 ******************************************************************

/*
a)	Use the following information from PPFAD: 
  - Never changing Person ID „persnr“
  - Household number "hhnr" and the current household number "bghhnr". 
  - the net variable with information about the interview type "bgnetto".
  - the sex of the person "sex"
  - the year of birth "semester"
  - Variables on the migration background "migback", "germborn" "corigin" "immiyear"
  - Information about the survey status: "bgnetto" and "psample".
*/

use persnr hhnr bghhnr bgnetto psample sex gebjahr germborn corigin immiyear migback  using $MY_IN_PATH\ppfad.dta, clear

/*
b)	Merge the previously generated data record using the person number.
*/

merge 1:1 persnr using $MY_OUT_TEMP\biimgrp.dta, nogen

/*
c)	Add the corresponding person extrapolation factors to the data record.
*/

merge 1:1 persnr using $MY_IN_PATH\phrf.dta, keepus(bgphrf) nogen

/*
d)	Only keep individuals for whom a youth or personal questionnaire was realized in 2016.
*/

tab bgnetto, m //Variable values are displayed

keep if inrange(bgnetto, 10, 19) // People who have a code between 10 and 19 will be kept.

*** Exercise 3 ******************************************************************

/*
Generate a status variable with the following categories:
*/

tab migback

tab germborn

gen Status = 0 // All persons will first receive the missing code for "no info".
replace Status = 1 if migback == 1 & germborn == 1 // "no migback"
replace Status = 2 if migback == 3                 // "2nd generation" (2nd generation migrants born by definition in Germany, therefore "& germborn == 1" here unnecessary
replace Status = 3 if germborn == 2 & Escape == 0  // "Immigrants without information" 
replace Status = 4 if germborn == 2 & Escape == 1  // "Immigrants, no escape"
replace Status = 5 if germborn == 2 & Escape == 2  // "Immigrant, escape"

label def Statuslbl 0"no info" 1"no migback" 2"2. Generation" 3"Immigrants without information"  4"Immigrants, no escape" 5"Immigrant, escape"
label val Status Statuslbl // Values of the status veriable receive label

*** Exercise 4 ******************************************************************

/*
a)	How many refugees (foreign-born with refugee/asylum titles) are now in your record?
*/

tab Status, m //Display Generated Status Variable

/*

                Statuslbl |      Freq.     Percent        Cum.
--------------------------+-----------------------------------
              keine Infos |         33        0.24        0.24
             kein migback |      9,374       67.51       67.75
            2. Generation |      1,533       11.04       78.79
    Einwanderer ohne Info |        346        2.49       81.28
Einwanderer, keine Flucht |      2,322       16.72       98.01
      Einwanderer, Flucht |        277        1.99      100.00
--------------------------+-----------------------------------
                    Total |     13,885      100.00


* Es befinden sich 277 Geflüchtete im Datensatz
*/

/*
b)	How many are there if you take the person extrapolation factors into account? Interpret the results.
*/

tab Status [aw=bgphrf], m  //Display generated status variable weighted with analytic weights


/*
                Statuslbl |      Freq.     Percent        Cum.
--------------------------+-----------------------------------
              keine Infos |  16.756886        0.12        0.12
             kein migback | 10,383.403       75.35       75.47
            2. Generation | 1,387.9283       10.07       85.54
    Einwanderer ohne Info | 242.478347        1.76       87.30
Einwanderer, keine Flucht | 1,578.7662       11.46       98.76
      Einwanderer, Flucht | 170.667748        1.24      100.00
--------------------------+-----------------------------------
                    Total |     13,780      100.00
*/

* Es befinden sich nach der Gewichtung nur noch rund 171 Geflüchtete im Datensatz.
* Durch die Gewichtung wurde die Anzahl der Geflüchteten also nach unten korrigiert.

/*
c)	How many persons are represented by the sample taking the extrapolation factors into account?
*/

gen fweight = round(bgphrf) //Frequency weights for stata require integer weight
tab Status [fw=fweight], m  //Display generated status variable weighted with frequency weights

/*

                Statuslbl |      Freq.     Percent        Cum.
--------------------------+-----------------------------------
              keine Infos |     41,939        0.12        0.12
             kein migback | 25,989,147       75.35       75.47
            2. Generation |  3,473,904       10.07       85.54
    Einwanderer ohne Info |    606,904        1.76       87.30
Einwanderer, keine Flucht |  3,951,570       11.46       98.76
      Einwanderer, Flucht |    427,177        1.24      100.00
--------------------------+-----------------------------------
                    Total | 34,490,641      100.00
*/

* Es werden rund 427-Tausend Personen repräsentiert.

/*
d)	What is the proportion of people over 40 years of age among the fugitives?
*/

gen ue_40 = 0
replace ue_40 = 1 if gebjahr <= 1976 // Persons receive proficiency 1 if they were born before 1975.

tab Status ue_40 [aw=bgphrf], m row nofreq

/*

                      |         ue_40
               Status |         0          1 |     Total
----------------------+----------------------+----------
          keine Infos |     56.69      43.31 |    100.00 
         kein migback |     27.62      72.38 |    100.00 
        2. Generation |     42.49      57.51 |    100.00 
Einwanderer ohne Info |     25.58      74.42 |    100.00 
Einwanderer, keine Fl |     44.34      55.66 |    100.00 
  Einwanderer, Flucht |     38.29      61.71 |    100.00 
----------------------+----------------------+----------
                Total |     31.16      68.84 |    100.00 

*/

* Der Anteil ist ebwa 62%.
