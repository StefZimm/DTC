
* * * LOCAL VARIABLES * * *

global MY_PATH_IN   "I:\ORG\SOEPcampus\Veranstaltungen\2017\2017_09_Frankfurt\Daten\SOEP32_core_50\"
global MY_PATH_OUT  "Z:\MA\skara\Webseite\Übungen DTC\"
global MY_FILE_OUT  ${MY_PATH_OUT}Uebung_IV.dta
global MY_LOG_FILE  ${MY_LOG_OUT}Uebung_IV_1_paneldata.log
capture log close
log using "${MY_LOG_FILE}", text replace
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
save "${MY_PATH_OUT}pfad.dta", replace
clear


* * * PHRF (Personen-Hochrechnungsfaktor) ***

use "${MY_PATH_IN}phrf.dta"
sort persnr
save "${MY_PATH_OUT}hrf.dta", replace
clear


* * * CREATE MASTER * * *

use "${MY_PATH_OUT}pfad.dta"
merge 1:1 persnr using "${MY_PATH_OUT}hrf.dta"
drop if _merge == 2
drop _merge
sort persnr
save "${MY_PATH_OUT}master.dta", replace
clear


* * * READ DATA * * *

use hinc06 whhnr using "${MY_PATH_IN}whgen.dta"
sort whhnr
save "${MY_PATH_OUT}whgen.dta", replace
clear


use persnr emplst08 yhhnr using "${MY_PATH_IN}ypgen.dta"
sort persnr
save "${MY_PATH_OUT}ypgen.dta", replace
clear


use hinc08 yhhnr using "${MY_PATH_IN}yhgen.dta"
sort yhhnr
save "${MY_PATH_OUT}yhgen.dta", replace
clear


use hinc07 xhhnr using "${MY_PATH_IN}xhgen.dta"
sort xhhnr
save "${MY_PATH_OUT}xhgen.dta", replace
clear


use xp0101 persnr xhhnr using "${MY_PATH_IN}xp.dta"
sort persnr
save "${MY_PATH_OUT}xp.dta", replace
clear


use persnr emplst06 whhnr using "${MY_PATH_IN}wpgen.dta"
sort persnr
save "${MY_PATH_OUT}wpgen.dta", replace
clear


use persnr wp0101 wp9301 whhnr using "${MY_PATH_IN}wp.dta"
sort persnr
save "${MY_PATH_OUT}wp.dta", replace
clear


use persnr xhhnr emplst07 using "${MY_PATH_IN}xpgen.dta"
sort persnr
save "${MY_PATH_OUT}xpgen.dta", replace
clear


use persnr yp0101 yp10601 yhhnr using "${MY_PATH_IN}yp.dta"
sort persnr
save "${MY_PATH_OUT}yp.dta", replace
clear


* * * MERGE DATA * * *

use   "${MY_PATH_OUT}master.dta"

sort whhnr
merge whhnr using "${MY_PATH_OUT}whgen.dta"
drop if _merge == 2
drop _merge

sort persnr
merge persnr using "${MY_PATH_OUT}ypgen.dta"
drop if _merge == 2
drop _merge

sort yhhnr
merge yhhnr using "${MY_PATH_OUT}yhgen.dta"
drop if _merge == 2
drop _merge

sort xhhnr
merge xhhnr using "${MY_PATH_OUT}xhgen.dta"
drop if _merge == 2
drop _merge

sort persnr
merge persnr using "${MY_PATH_OUT}xp.dta"
drop if _merge == 2
drop _merge

sort persnr
merge persnr using "${MY_PATH_OUT}wpgen.dta"
drop if _merge == 2
drop _merge

sort persnr
merge persnr using "${MY_PATH_OUT}wp.dta"
drop if _merge == 2
drop _merge

sort persnr
merge persnr using "${MY_PATH_OUT}xpgen.dta"
drop if _merge == 2
drop _merge

sort persnr
merge persnr using "${MY_PATH_OUT}yp.dta"
drop if _merge == 2
drop _merge


* * * DONE * * *

label data "SOEPinfo v.2: Magic at work!"
save "${MY_FILE_OUT}", replace
desc

log close
