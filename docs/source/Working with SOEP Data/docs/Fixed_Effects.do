*******************************************************************************
* Fixed Effects Estimation
******************************************************************************

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
global MY_IN_PATH "\\hume\rdc-prod\distribution\soep-long\soep.v33.1\stata_en\"
global MY_DO_FILES "$AVZ\do\"
global MY_LOG_OUT "$AVZ\log\"
global MY_OUT_DATA "$AVZ\output\"
global MY_OUT_TEMP "$AVZ\temp\"

use pid syear sex gebjahr netto pop phrf using "${MY_IN_PATH}/ppfadl.dta", clear

merge 1:1 pid syear using "${MY_IN_PATH}/pl.dta", keepus(plb0022) keep(master match) nogen
merge 1:1 pid syear using "${MY_IN_PATH}/pgen.dta", keepus(pglabgro pgtatzeit pgexpft pgbilzeit pgfamstd) keep(master match) nogen

* Only select people with completed interviews
keep if inrange(netto, 10, 19)

* Only private households
keep if pop==1 | pop==2

* Period from 2012 to 2016
keep if syear>=2012 & syear<=2016

save "${MY_OUT_DATA}/SOEPWage.dta", replace

*** Exercise 1: Prepare your data set
* a) Load data set
use "${MY_OUT_DATA}/SOEPWage.dta", clear

* b) Recode Missings
mvdecode _all, mv(-8/-1 = .)

* c) Generate Variables
gen wage = pglabgro/(4.33*pgtatzeit) if pglabgro>=1 & pgtatzeit>=1

gen married = 1 if pgfamstd==1 | pgfamstd==6 | pgfamstd==7 | pgfamstd==8
replace married = 0 if inrange(pgfamstd, 2, 5)

gen age = syear - gebjahr

* d) Adjust wage variable
sum wage, detail
replace wage = 1/3*r(p1) if wage<1/3*r(p1)
replace wage = 3*r(p99) if wage>3*r(p99) & wage<.

gen lwage = log(wage)
label variable lwage "Log hourly wage"

save "${MY_OUT_DATA}/SOEPWage_temp.dta", replace

*** Exercise 2: Descriptive statistics
* a)
xtset pid syear // Declaring data as panel data

* b)
xtdescribe, patterns(16) // -> unbalanced panel

* c) 
* Stability of the relationship status
xttab married 
* 40,72 Prozent der Personen-Jahr-Beobachtungen mit Verheiratet==Nein
* 8703 Personen haben mindestens ein Mal Verheiratet==Nein
* 11282 Personen haben mindestens ein Mal Verheiratet==Ja
* Diejenigen, die mindestens in einem Jahr nicht verheiratet waren, haben
* durchschnittlich 96,02 der Beobachtungen mit Verheiratet==Nein
* Diejenigen, die mindestens ein Mal verheiratet waren, haben
* durchschnittlich 96,87 Prozent der Beobachtungen mit Verheiratet==Ja
* -> Sehr stabiles Verhalten

* Transition probabilities
xttrans married, freq
* 97,06 Prozent der Personenjahr-Beobachtungen mit Verheiratet==Nein, sind noch in
* der nächsten Periode nicht verheiratet
* 98,81 Prozent der Personenjahr-Beobachtungen mit Verheiratet==Ja, sind noch in
* der nächsten Periode verheiratet -> sehr stabiles Verhalten

* Individual sequences of "wage"
xtline wage if pid==30320901 | pid==30932501 | pid==3101602 | pid==3101801, overlay 

*** Exercise 3: Pooled OLS Regression
* a) Pooled OLS
reg lwage married sex pgexpft pgbilzeit

* a) Interpretation Koeffizienten
* Die Variablen married, sex und bilzeit korrelieren sehr wahrscheinlich mit 
* anderen unberücksichtigten/unbeobachteten Variablen, die einen Effekt auf den Lohn haben.
* Bspw. arbeiten Frauen häufiger in Berufen mit niedrigeren Löhnen  

* b) Pooled OLS with cluster standard errors
reg lwage married sex pgexpft pgbilzeit, vce(cluster pid)
* Die Standardfehler werden größer

*** Exercise 4: Fixed Effects
* a) Subtract person-specific averages

gen sample = 1
foreach var in lwage married sex pgexpft pgbilzeit {

	bysort pid: egen `var'Mean = mean(`var')
	replace `var'Mean = . if `var'==.
	gen `var'Demeaned =  `var' - `var'Mean
	replace sample = 0 if `var'==.
}
bysort pid (sample): replace sample = sample[1]


* b) Fixed Effects Modell
reg lwageDemeaned marriedDemeaned sexDemeaned pgexpftDemeaned pgbilzeitDemeaned, vce(cluster pid) nocons
* Geschlecht ist für alle Beobachtungen konstant über die Zeit	

* b) Interpretation Koeffizienten
* Koeffizient von married nicht signifikant auf 5% Level!
* Schock e_it korreliert möglicherweise immer noch mit married.

*** Exercise 5: xtreg, fe
* c) xtreg, fe
xtreg lwage married pgexpft pgbilzeit, fe vce(cluster pid)
* Koeffizienten sollten mit 4 b) identisch sein. Unklar warum nicht.
* Standardfehler sind größer, da in Modell b) die Schätzung der Mittelwerte nicht
* in den Standardfehlern berücksichtigt wird.


* d) xtreg with dummy
xtreg lwage married pgexpft pgbilzeit i.syear, fe vce(cluster pid)
* Effekt von expft wird insignifikant. Modell eventuell fall spezifiziert.
* Mincer Gleichung sieht (potentielle) Arbeitsmarkterfahrung im Quadrat vor.

* e) expft squared
xtreg lwage married c.pgexpft##c.pgexpft pgbilzeit i.syear, fe vce(cluster pid)
graph twoway (func y = _b[pgexpft]*x + _b[c.pgexpft#c.pgexpft]*x*x, range(0 40))
* Abnehmende Effekte von Arbeitsmarkterfahrung ab ca. 10 Jahren Erfahrung

* f) Fixed Effects weighted
global MY_IN_PATH2 "\\hume\rdc-prod\complete\soep-core\soep.v33.2\stata_en\"
rename pid persnr
merge m:1 persnr using "${MY_IN_PATH2}/phrf.dta", nogen keep(master match) keepus(bcphrf bdpbleib bepbleib bfpbleib bgpbleib)
gen wlong = bcphrf*bdpbleib*bepbleib*bfpbleib*bgpbleib
label variable wlong "Weighting BC-BG"
rename persnr pid

xtreg lwage married c.pgexpft##c.pgexpft pgbilzeit i.syear [pw=wlong], fe vce(cluster pid)
* Anzahl der Beobachtungen deutlich kleiner. Effekt von bilzeit stärker.
* bilzeit hat einen niedrigeren Effekt in der Gruppe wlong==0. In dieser Gruppe ist
* der Return für jedes zusätzliche Bildungsjahr unterschiedlich. 
* Eventuell erhalten Personen der Gruppe wlong==0 auf dem lokalen Arbeitsmarkt
* nicht den Return für ihre zusätzliche Bildung, den sie erwartet haben und 
* ziehen deswegen um -> Höhere Wahrscheinlichkeit für Dropout



***


