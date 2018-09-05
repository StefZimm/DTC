/* ----(automatically pull PPFAD)-----------------------------------*/
use hhnr persnr sex gebjahr psample uhhnr zhhnr behhnr unetto znetto benetto using "$MY_IN_PATH\ppfad.dta", clear
save $My_OUT_TEMP\ppfad.dta, replace


use hhnr persnr prgroup uphrf upbleib zphrf zpbleib bephrf bepbleib using "$MY_IN_PATH\phrf.dta"
sort persnr
save $MY_OUT_TEMP\phrf.dta, replace

/* ----(create master)----------------------------------------------*/
use "$MY_OUT_TEMP\ppfad.dta", clear
merge 1:1 hhnr persnr using "$MY_OUT_TEMP\phrf.dta", nogenerate
sort persnr
save $MY_OUT_TEMP\pmaster.dta, replace

/* ----(pull up)----------------------------------------------------*/
use hhnr persnr up12006 using "$MY_IN_PATH\up.dta", clear
sort persnr
save $MY_OUT_TEMP\up.dta, replace

/* ----(pull zp)----------------------------------------------------*/
use hhnr persnr zp11806 using "$MY_IN_PATH\zp.dta", clear
sort persnr
save save $MY_OUT_TEMP\zp.dta, replace

/* ----(pull bep)---------------------------------------------------*/
use hhnr persnr bep12506 using "$MY_IN_PATH\bep.dta", clear
sort persnr
save save $MY_OUT_TEMP\bep.dta, replace

/* ----(pull uh)----------------------------------------------------*/
use hhnr uh69 using "$MY_IN_PATH\uh.dta", clear
sort hhnr
save save $MY_OUT_TEMP\uh.dta, replace

/* ----(pull zh)----------------------------------------------------*/
use hhnr zh60 using uh69 using "$MY_IN_PATH\zh.dta", clear
sort hhnr
save save $MY_OUT_TEMP\zh.dta, replace

/* ----(pull beh)---------------------------------------------------*/
use hhnr zh60 using uh69 using "$MY_IN_PATH\beh.dta", clear
sort hhnr
save save $MY_OUT_TEMP\beh.dta, replace

/* ----(merge together by person: ALL Waves)------------------------*/
use "$MY_OUT_TEMP\pmaster.dta", clear

sort persnr
merge 1:1 persnr using "$MY_OUT_TEMP\up.dta", nogenerate
merge 1:1 persnr using "$MY_OUT_TEMP\zp.dta", nogenerate
merge 1:1 persnr using "$MY_OUT_TEMP\bep.dta", nogenerate

/* ----(merge together by houshold: ALL Waves)----------------------*/
sort hhnr
joinby hhnr using "$MY_OUT_TEMP\uh.dta"
joinby hhnr using "$MY_OUT_TEMP\zh.dta"
joinby hhnr using "$MY_OUT_TEMP\beh.dta"

