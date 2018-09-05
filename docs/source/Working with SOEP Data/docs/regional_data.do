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
global region "\\hume\soep-region\DATA\soep33_de\"
global MY_DO_FILES "$AVZ\do\"
global MY_LOG_OUT "$AVZ\log\"
global MY_OUT_DATA "$AVZ\output\"
global MY_OUT_TEMP "$AVZ\temp\"

use hhnr persnr bghhnr sex gebjahr bgnetto bgpop using ${MY_IN_PATH}\ppfad.dta, clear

* Keep people who completed a questionnaire in 2016 and live in a private household
keep if bghhnr>0 & inrange(bgnetto, 10, 29) & inlist(bgpop, 1, 2)
keep hhnr persnr bghhnr sex gebjahr bgnetto bgpop
merge 1:1  persnr using ${MY_IN_PATH}\phrf.dta, keep(match master) keepusing (bgphrf) nogenerate
tempfile ppfad
save `ppfad'

* Prepare data set bgp
use ${MY_IN_PATH}\bgp.dta, replace
keep persnr hhnr bghhnr bgp01* bgp143
tempfile bgp
save `bgp'

* Prepare data set bghbrutto
use ${MY_IN_PATH}\bghbrutto.dta, replace
keep hhnr bghhnr bgsampreg bgbula bgregtyp
tempfile bghbrutto
save `bghbrutto'

* Prepare data set regionl
use ${region}\regionl_v33.dta, replace
keep if syear==2016
keep syear hhnr hhnrakt ggk
rename hhnrakt bghhnr
tempfile regionl
save `regionl'

* Merge all data sets
use `ppfad'
merge 1:1 persnr using `bgp', keep(match master) nogenerate
merge m:1 bghhnr hhnr using `regionl', keep(match master) nogenerate
merge m:1 bghhnr hhnr using `bghbrutto', keep(match master) nogenerate

* Recode negative values into missings
mvdecode sex gebjahr bgp01* bgp143,mv(-5/-1)

* Categorize community class size
gen ggk_cat=.
replace ggk_cat=-1 if ggk==-1
replace ggk_cat=1 if ggk==1 | ggk==2
replace ggk_cat=2 if ggk==3
replace ggk_cat=3 if ggk==4 | ggk==5
replace ggk_cat=4 if ggk>5 & ggk<=7

lab var ggk_cat "Community Size categorised"
lab def ggk_cat -1 "No information" 1 "<=5000" 2 "5001 - 20000" 3 "20001 - 100000" /// 
4 ">100000"
lab val ggk_cat ggk_cat

* Generate age variable
gen alter= 2016-gebjahr if gebjahr > 0
gen alter_cat=1 if alter<=20
replace alter_cat=2 if alter>20 & alter<=30
replace alter_cat=3 if alter>30 & alter<=65
replace alter_cat=4 if alter>65 & alter<=120

lab var alter "age"
lab var alter_cat "age categorized"
lab def alter_cat 1 "<=20" 2 "21-30" 3 "31-65" 4 ">65"
lab val alter_cat alter_cat 

* Categorize federal states
gen bgbula_cat=.
* Schleswig-Holstein + Hamburg
replace bgbula_cat=1 if bgbula==1 | bgbula==2
* Lower Saxony + Bremen
replace bgbula_cat=2 if bgbula==3 | bgbula==4
* Mecklenburg Western Pomerania + Brandenburg
replace bgbula_cat=3 if bgbula==13 | bgbula==12
* Saarland + Rhineland Palatinate
replace bgbula_cat=4 if bgbula==7 | bgbula==10
* Northrhine-Westphalia
replace bgbula_cat=5 if bgbula==5
* Hesse
replace bgbula_cat=6 if bgbula==6
* Baden-Württemberg
replace bgbula_cat=7 if bgbula==8
* Bavaria
replace bgbula_cat=8 if bgbula==9
* Berlin
replace bgbula_cat=9 if bgbula==11
* Saxony
replace bgbula_cat=10 if bgbula==14
* Saxony-Anhalt
replace bgbula_cat=11 if bgbula==15
* Thuringia
replace bgbula_cat=12 if bgbula==16

lab var bgbula_cat "Federal states categorized"
lab def bgbula_cat 1 "Schleswig-Holstein/Hamburg" 2 "Lower Saxony/Bremen" 3 "Mecklenburg Western Pomerania/Brandenburg" /// 
4 "Saarland/Rhineland Palatinate" 5 "Northrhine-Westphalia" 6 "Hesse" /// 
7 "Baden-Wuerttenberg" 8 "Bavaria" 9 "Berlin" 10 "Saxony" 11 "Saxony-Anhalt" 12 "Thuringia"
lab val bgbula_cat bgbula_cat
drop bgbula
rename bgbula_cat bgbula

* Order demography and identifiers first
order persnr hhnr bghhnr syear sex gebjahr alter alter_cat bgsampreg bgbula ggk /// 
ggk_cat bgregtyp  

save ${MY_OUT_DATA}\zeit_online.dta, replace


********************************************************************************
capture log close
log using "${MY_LOG_OUT}\satisfaction.log", replace

* Life satisfaction

local varlist bgp0101 bgp0102 bgp0103 bgp0104 bgp0105 bgp0106 bgp0107 bgp0108 /// 
bgp0109 bgp0110 bgp0111 bgp0112
foreach x of local varlist {
tab bgsampreg `x' [aw= bgphrf] , row
}

foreach x of local varlist {
* Tabulation of satisfaction by size of community and federal state
table `x' sex alter_cat, by(bgbula ggk_cat) contents(freq) column row stubwidth(20) cellwidth(8) csepwidth(2) nomissing
* Tabulation of satisfaction by size of community
table `x' sex alter_cat, by(ggk_cat) contents(freq) column row stubwidth(20) cellwidth(8) csepwidth(2) nomissing
* Tabulation of satisfaction by federal state
table `x' sex alter_cat, by(bgbula) contents(freq) column row stubwidth(20) cellwidth (8) csepwidth(2) nomissing 
}

********************************************************************************
capture log close
log using "${MY_LOG_OUT}\political_interest.log", replace

* Political interest
* Tabulation of political interest by size of community for Bavaria
table bgp143 sex alter_cat if bgbula==8, by(ggk_cat) contents(freq) column row stubwidth(20) cellwidth (8) csepwidth(2) nomissing
// Tabulation of political interest by size of community
table bgp143 sex alter_cat [aw=bgphrf], by(ggk_cat) contents(freq) column row stubwidth(20) cellwidth (8) csepwidth(2) nomissing
// Tabulation of political interest by federal state
table bgp143 sex alter_cat [aw=bgphrf], by(bgbula) contents(freq) column row stubwidth(20) cellwidth (8) csepwidth(2) nomissing
 
********************************************************************************
