***********************************************
* Set some useful commands
***********************************************
version 13
clear all
set more off

***********************************************
* Set relative paths to the working directory
***********************************************
global AVZ 	"H:\material\exercises"
global MY_IN_PATH "\\hume\rdc-prod\complete\soep-core\soep.v33.2\stata_en\"
global MY_DO_FILES "$AVZ\do\"
global MY_LOG_OUT "$AVZ\log\"
global MY_OUT_DATA "$AVZ\output\"
global MY_OUT_TEMP "$AVZ\temp\"


********************************************************************************
*** Exercise 1) ***
********************************************************************************



use "${MY_IN_PATH}ppfad.dta", clear

* a) What gender are they? When were they born and eventually died?
list persnr sex gebjahr todjahr if persnr == 2102 | persnr == 19202

* b) Were these people and their parents born in Germany?
list persnr migback if persnr == 2102 | persnr == 19202

*c) If they have immigrated: In which year and from which country?
list persnr immiyear corigin if persnr  == 2102 | persnr == 19202

*d) Are these people from East or West Germany?
list persnr loc1989 psample if persnr  == 2102 | persnr == 19202

*e) From which sources does the information on the migration background and the year of death come?
list miginfo todinfo if persnr  == 2102 | persnr == 19202


********************************************************************************
*** Exercise 2) ***
* How many people lived in a realised private household in 2016 and answered the 
* personal questionnaire?

********************************************************************************

* informationen from:
* 2016 -> Wave bg
* private household -> bgpop
* Individual questionnaire -> bgnetto

tab bgpop
tab bgnetto
tab bgnetto bgpop if ((bgnetto >= 10 & bgnetto <= 15) | bgnetto==19) & (bgpop==1 | bgpop==2)

/* 
Note: if ado-file "frequencies" is installed, type:
	fre bgpop
	fre bgnetto
(command "frequencies" displays the complete value label).
To find out if it is installed on your computer, type 
	help fre
*/

********************************************************************************
*** Exercise 3) ***
********************************************************************************
* a)How many people who answered the personal questionnaire in 2000 also took 
*   part in the survey in 2014?

* informationen from:
*	2000 -> wave q
*  	2014 -> wave be     
* 	Individual questionnaire -> $netto

tab qnetto benetto  if qnetto>=10 & qnetto<=19 & benetto>=10 & benetto<=19
*or:
//fre qnetto benetto  if qnetto>=10 & qnetto<=19 & benetto>=10 & benetto<=19

/*
##################################################################################################
Please note: As of wave w (2006) the $netto-codes have been modified, in line with a modification 
	of the survey method: 
	
	Up to 2006, young respondents filled out their own personal questionnaire for the first time 
	in the year of their seventeenth birthday, and were assigned the $netto code 16.
	
	Since the survey year 2006, young respondents get a special youth qestionnaire in the year 
	of their seventeenth birthday and their first personal questionnare from the next year on. 
	Respondents having answered the youth qestionnaire are assigned the $netto code 17. 
	$netto code 16 is no more used after wave v (2005).
	
	However, this modification does not affect Exercises 3a and 3b. Why?
##################################################################################################
*/

* b) How many people answered the individual questionnaire every year from 2000 
*    to 2014?

/* to see all the codes */
lab list bgnetto

local v "netto"
local vlist "q`v' r`v' s`v' t`v' u`v' v`v' w`v' x`v' y`v' z`v' ba`v' bb`v' bc`v' bd`v' be`v'"  
/* --> 15 waves */

capture drop h1
egen h1 = anycount(`vlist'), values(10 12 13 14 15 16 18 19)

tab h1 if h1 == 15

drop h1			

			
* c) How many people who turned 15 in 2011 and lived as children in a survey 
*    household took part in the survey in 2016?

*   informationen from:
*  	2011 -> wave bb
*	Age  -> 15  
*	Child -> bbnetto   
*	2016 -> wave bg
* 	Individual Questionnaire -> bgnetto

/* People who turned 15 in 2011 and lived in a survey household as a child...*/
capture drop a15kind
gen a15kind = 1 if 2011-gebjahr == 15 & bbnetto >= 20 & bbnetto < 30

/* ... und die in 2016 selbst an der Befragung teilgenommen haben */
// fre bgnetto if a15kind == 1 & bgnetto >= 10 & bgnetto < 20
* oder:
tab bgnetto if a15kind == 1 & bgnetto >= 10 & bgnetto < 20


********************************************************************************
*** Exercise 4) ***
********************************************************************************
* The person with persnr=588010 was born in 1984 in a panel household and was 
* still part of the sample in 2009. The person has changed households twice during
* this time. In which years?

* Information from:
* -> household numbers

list *hhnr if persnr == 588010
/* -> changed household 
 in year d (1987)
 in year y (2008)
 no participation since bb (2011) 
*/

********************************************************************************
*** Aufgabe 5) ***
********************************************************************************

/* ----[ automatically pull PPFAD ]----------------------*/
use hhnr persnr sex gebjahr psample uhhnr zhhnr behhnr unetto znetto benetto using "$MY_IN_PATH\ppfad.dta", clear
save $MY_OUT_TEMP\ppfad.dta, replace

use hhnr persnr prgroup uphrf upbleib zphrf zpbleib bephrf bepbleib using "$MY_IN_PATH\phrf.dta", clear
sort persnr
save $MY_OUT_TEMP\phrf.dta , replace

/* ----[ tips for longitudinal weights ]------------------- */
/* create your own LONGITUDINAL person weights here. */
/* e.g. longitudinal person weight from wave A to wave D. */
/* take the starting wave cross-sectional weight (aphrf) */
/* and multiply through by each FOLLOWING WAVE staying */
/* factor, as in the following example: */
/* gen adphrf=aphrf*bpbleib*cpbleib*dpbleib; */
/* -------------------------------------------------------- */

/* ----[ automatically create PMASTER ]---------- */
use "$MY_OUT_TEMP\ppfad.dta", clear
merge 1:1 hhnr persnr using "$MY_OUT_TEMP\phrf.dta", nogenerate

sort persnr
save $MY_OUT_TEMP\pmaster, replace

/* ----( pull up )---------------------------- */
use hhnr persnr up12006 using "$MY_IN_PATH\up.dta", clear

sort persnr
save $MY_OUT_TEMP\up.dta, replace


/* ----( pull zp )---------------------------- */
use hhnr persnr zp11806 using "$MY_IN_PATH\zp.dta", clear

sort persnr
save $MY_OUT_TEMP\zp.dta, replace

/* ----( pull bep )---------------------------- */
use hhnr persnr bep12506 using "$MY_IN_PATH\bep.dta", clear

sort persnr
save $MY_OUT_TEMP\bep.dta, replace

/* ----( pull uh )---------------------------- */
use hhnr uh69 using "$MY_IN_PATH\uh.dta", clear
sort hhnr
save $MY_OUT_TEMP\uh.dta, replace

/* ----( pull zh )---------------------------- */
use hhnr zh60 using "$MY_IN_PATH\zh.dta", clear
sort hhnr
save $MY_OUT_TEMP\zh.dta, replace

/* ----( pull beh )---------------------------- */
use hhnr beh63 using "$MY_IN_PATH\beh.dta", clear
sort hhnr
save $MY_OUT_TEMP\beh.dta, replace

/* ----( merge together by person: ALL Waves )---------- */
use "$MY_OUT_TEMP\pmaster", clear

/* ----( merge p )------------------------------------- */
sort persnr
merge 1:1 persnr using "$MY_OUT_TEMP\up.dta", nogenerate
merge 1:1 persnr using "$MY_OUT_TEMP\zp.dta", nogenerate
merge 1:1 persnr using "$MY_OUT_TEMP\bep.dta", nogenerate

/* ----( merge h )------------------------------------- */
sort hhnr
joinby hhnr using "$MY_OUT_TEMP\uh.dta"
joinby hhnr using "$MY_OUT_TEMP\zh.dta"
joinby hhnr using "$MY_OUT_TEMP\beh.dta"



