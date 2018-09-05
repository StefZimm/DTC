
* * * LOCAL VARIABLES * * *

global MY_PATH_IN   "I:\ORG\SOEPcampus\Veranstaltungen\2017\2017_09_Frankfurt\Daten\SOEP32_core_50\"
global MY_PATH_OUT  "Z:\MA\skara\Webseite\Übungen DTC\"
global MY_FILE_OUT  ${MY_PATH_OUT}Uebung_IV.dta
global MY_LOG_FILE  ${MY_LOG_OUT}Uebung_IV_1_paneldata.log
capture log close
set more off
clear

** * * NOT PROCESSED * * *



* * * PFAD * * *

use hhnr persnr sex gebjahr psample xhhnr xnetto xpop yhhnr ynetto ypop whhnr wnetto wpop using "${MY_PATH_IN}ppfad.dta"


* * * BALANCED VS UNBALANCED * * *

keep if ( (xnetto >= 10 & xnetto < 20) | (ynetto >= 10 & ynetto < 20) | (wnetto >= 10 & wnetto < 20) )


* * * PRIVATE VS ALL HOUSEHOLDS * * *

keep if ( (xpop == 1 | xpop == 2) | (ypop == 1 | ypop == 2) | (wpop == 1 | wpop == 2) )


* * * SORT PPFAD * * *

sort persnr
save "${MY_PATH_OUT}ppfad.dta", replace
clear


* * * PHRF (Person-extrapolation factor) ***

use persnr wphrf xphrf yphrf using "${MY_PATH_IN}phrf.dta"
sort persnr
save "${MY_PATH_OUT}phrf.dta", replace
clear


* * * Persons 2006 * * *
use persnr wp0101 wp9301 using "${MY_PATH_IN}wp.dta"
sort persnr
save "${MY_PATH_OUT}wp.dta", replace
clear

* * * Persons 2007 * * *
use persnr xp0101 using "${MY_PATH_IN}xp.dta"
sort persnr
save "${MY_PATH_OUT}xp.dta", replace
clear

* * * Persons 2008 * * *
use persnr yp0101 yp10601 using "${MY_PATH_IN}yp.dta"
sort persnr
save "${MY_PATH_OUT}yp.dta", replace
clear


* load ppfadl 
use "${MY_PATH_OUT}pfad.dta", clear

merge 1:1 persnr using "${MY_PATH_OUT}phrf.dta", keep(master match) nogen


* merge data from $p.dta 
merge 1:1 persnr using "${MY_PATH_IN}/wp.dta", keepus(wp0101 wp9301)  keep(master match) nogen // health & smoking
merge 1:1 persnr using "${MY_PATH_IN}/xp.dta", keepus(xp0101) 		  keep(master match) nogen // health
merge 1:1 persnr using "${MY_PATH_IN}/yp.dta", keepus(yp0101 yp10601) keep(master match) nogen // health & smoking

* merge data from $pgen.dta 
local y = 6
foreach wave in w x y {
	merge 1:1 persnr using "${MY_PATH_IN}/`wave'pgen.dta", keepus(emplst0`y')nogen keep(master match) 
	local y = `y' + 1
}

* merge data from $hgen.dta 
local y = 6
foreach wave in w x y {
	merge m:1 `wave'hhnr using "${MY_PATH_IN}/`wave'hgen.dta", keepus(hinc0`y') nogen keep(master match) 
	local y = `y' + 1
}


*capture log close
set more off



********************************************************************************
*** Task 2) ***
* Encode missing values in system failings (STATA)!
********************************************************************************

	mvdecode _all, mv(-1=. \ -2=.t \ -3=.x \ -5=.y \ -8=.z)

	
********************************************************************************
*** Task 3) ***
*  Convert the data set to long format using the STATA command reshape! 
********************************************************************************

*Check if original variable have changed over time
	tab1 wp0101 xp0101 yp0101
	tab1 wp9301 yp10601
	/*additionally check questionaires for exact wording*/

*rename time-variant variables
*with examples how to use loops (but can also be done "manually")
	rename wp9301 smoke2006
	rename yp10601 smoke2008
	rename wp0101 health2006
	rename xp0101 health2007
	rename yp0101 health2008
	...
	
		
	foreach  x in 6 7 8 {
		rename hinc0`x' hinc200`x'
		rename emplst0`x' emplst200`x'
		}

		
	local y=2006
	foreach w in w x y {
		rename `w'hhnr hhnrakt`y'
		rename `w'netto netto`y'
		rename `w'pop pop`y'
		rename `w'phrf phrf`y'
		local y=`y'+1
		}
		
		
		
*reshape dataset to long-format
	reshape long health smoke emplst hinc netto pop hhnrakt phrf, i(persnr) j(year)
	bys persnr: gen waves=_N		/*additional information: count number of waves per person*/
	tab waves
	
	
********************************************************************************
*** Task 4) ***
*  Perform analyses based on the data. Try to answer the following questions!
 
 
********************************************************************************

*a) Has the average satisfaction with men's health and women changed 
*   over the three years?

	  mean health [pw=phrf], over(sex year)
		
	*alternativ
     reg health year sex c.year#i.sex

		 
*b) What is the proportion of people for whom health satisfaction has increased 
*   from 2006 to 2007?? 
	sort persnr year
	gen diff=health-health[_n-1] if persnr==persnr[_n-1] & year==year[_n-1]+1
	tab diff if year==2007				/*unweighted*/
	
	tab diff if year==2007 [aw=phrf]	/*weighted*/
	
		*alternativ
		xtset persnr year
		generate mob=0 if year==2007 & l.health==health & health~=. & l.health ~=.
		replace mob=1 if year==2007 & l.health<health & health~=. & l.health ~=.
		replace mob=-1 if year==2007 & l.health>health & health~=. & l.health ~=. 
		tab mob
	
	
	
*c) In what direction and how much has satisfaction with the health of 
*   people who quit smoking after 2006 changed from 2006 to 2008?

	gen diff2=health-health[_n-2] if persnr==persnr[_n-2] & year==year[_n-2]+2 & year==2008
	gen quit=.
	replace quit=0 if smoke==1 & smoke[_n-2]==1 & persnr==persnr[_n-2] & year==year[_n-2]+2 & year==2008
	replace quit=1 if smoke==2 & smoke[_n-2]==1 & persnr==persnr[_n-2] & year==year[_n-2]+2 & year==2008
	replace quit=2 if smoke==2 & smoke[_n-2]==2 & persnr==persnr[_n-2] & year==year[_n-2]+2 & year==2008
	replace quit=3 if smoke==1 & smoke[_n-2]==2 & persnr==persnr[_n-2] & year==year[_n-2]+2 & year==2008
	label define quit 0 "smoker" 1 "quit" 2 "non-smoker" 3 "begin"
	label values quit quit
	tabstat diff2, by(quit)
	tabstat diff2 [aw=phrf], by(quit)	/*weighted*/

	
		*alternative 1
		generate smokestop=1 if smoke==2 & ll.smoke==1 
		sum health if smokestop==1 & ll.health~=.
		sum ll.health if smokestop==1 & health~=.

		*alternative 2
		generate diff3=health-ll.health if year==2008
		gen quit2=0 if smoke==1 & ll.smoke==1 & year==2008
		replace quit2=1 if smoke==2 & ll.smoke==1 & year==2008
		replace quit2=2 if smoke==2 & ll.smoke==2 & year==2008
		replace quit2=3 if smoke==1 & ll.smoke==2 & year==2008
		label define quit2 0 "smoker" 1 "quit" 2 "non-smoker" 3 "begin"
		label values quit2 quit2
		tabstat diff3, by(quit2)
		mean diff3, over(quit2)
			
	
*d) Does quitting smoking make your health worse? To what extent can the 
*   result of the analysis "Stop smoking" be distorted?
	
	* Notes: So far we have not tested whether the difference is statistically significant
		ttest diff2==0 if quit==1 		
		reg diff2 i.quit if year==2008, robust 
		
		
		
** ADDENDUM
*** SOEPlong
*use syear pid hid plh0171 ple0081 using "${MY_IN_PATH_long}\pl.dta" if (syear==2006 | syear==2007 | syear==2008), clear
*merge m:1 pid using "${MY_IN_PATH_long}\ppfad.dta", keepus(sex gebjahr)
*drop if _merge!=3
*drop _merge
*merge 1:1 syear pid using "${MY_IN_PATH_long}\pgen.dta", keepus(pgemplst)
*drop if _merge!=3
*drop _merge
*merge m:1 syear hid using "${MY_IN_PATH_long}\hgen.dta", keepus(hghinc)
*drop if _merge!=3
*drop _merge	
*log close	
