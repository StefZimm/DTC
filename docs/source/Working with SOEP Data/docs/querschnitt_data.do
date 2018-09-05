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




** * * NOT PROCESSED * * *



* * * PFAD * * *

use hhnr persnr sex gebjahr psample yhhnr ynetto ypop using "${MY_IN_PATH}ppfad.dta"


* * * BALANCED VS UNBALANCED * * *

keep if ( (ynetto >= 10 & ynetto < 20) )


* * * PRIATVE VS ALL HOUSEHOLDS * * *

keep if ( (ypop == 1 | ypop == 2) )


* * * SORT PFAD * * *

sort persnr
save "${MY_OUT_TEMP}ppfad.dta", replace
clear


* * * HRF * * *

use "${MY_IN_PATH}phrf.dta"
sort persnr
save "${MY_OUT_TEMP}hrf.dta", replace
clear


* * * CREATE MASTER * * *

use "${MY_OUT_TEMP}ppfad.dta"
merge 1:1 persnr using "${MY_OUT_TEMP}hrf.dta"
drop if _merge == 2
drop _merge
sort persnr
save "${MY_OUT_TEMP}master.dta", replace
clear


* * * READ DATA * * *

use hinc08 yhhnr using "${MY_IN_PATH}yhgen.dta"
sort yhhnr
save "${MY_OUT_TEMP}yhgen.dta", replace
clear


use yp10601 yhhnr yp0101 persnr using "${MY_IN_PATH}yp.dta"
sort persnr
save "${MY_OUT_TEMP}yp.dta", replace
clear


use emplst08 yhhnr persnr using "${MY_IN_PATH}ypgen.dta"
sort persnr
save "${MY_OUT_TEMP}ypgen.dta", replace
clear


* * * MERGE DATA * * *

use   "${MY_OUT_TEMP}master.dta"

sort yhhnr
merge yhhnr using "${MY_OUT_TEMP}yhgen.dta"
drop if _merge == 2
drop _merge

sort persnr
merge persnr using "${MY_OUT_TEMP}yp.dta"
drop if _merge == 2
drop _merge

sort persnr
merge persnr using "${MY_OUT_TEMP}ypgen.dta"
drop if _merge == 2
drop _merge


* * * DONE * * *

save "${MY_OUT_DATA}my_dataset.dta", replace
desc
