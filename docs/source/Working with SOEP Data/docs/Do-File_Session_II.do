*************************************
* SOEPcampus - Working with SOEPlong 
* Example Exercises
* February 2018
*************************************

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


***preparations
**increase buffer size
clear
set scrollbufsize 2000000
**now restart stata!

**enable automatic scrolling
set more off

*** set the inpath and outpath
global inpath "I:\ORG\SOEPcampus\Daten\Schulungsdaten\SOEP32_long_10"
global outpath "H:" 

*-------------------------------------------------------------------------------
*** Step 1) Start with basic information from PPFADL ***

use pid hid syear netto phrf migback sex using $inpath\ppfadl 



*-------------------------------------------------------------------------------
*** Step 2) Add the relavant variables: here: family status and life satisfaction ***
merge 1:1 pid syear using $inpath\pgen, keepusing(pgfamst) keep(1 3) nogen	

		// merges family status from pgen
		// Documentation for PGEN can be found here
		// http://panel.gsoep.de/soep-docs/surveypapers/diw_ssp0307.pdf)

		
*describe using pl
		// for checking out variable names without opening the dataset
		
merge 1:1 pid syear using $inpath\pl, keepusing(plh0182) keep(1 3) nogen
		// merges life satisfaction from pl 

save $outpath\long.dta, replace

*-------------------------------------------------------------------------------
*** Step 3) Clean and inspect the data
mvdecode _all, mv(-8/-1)

tab netto
drop if netto>19

**define the data set as panel data
xtset pid syear
xtdes


*-------------------------------------------------------------------------------
*** Step 4) univariate inspection & analysis
table syear, content (mean plh0182)
tab1 pgfamstd migback if syear==2014
tab pgfamstd [aw=phrf] if syear==2014
tab migback [aw=phrf] if syear==2014
xttrans plh0182
xttrans pgfamstd


*-------------------------------------------------------------------------------
*** Step 5)simple cross sectional analyses
table pgfamstd if syear==2010, content (mean plh0182)

***perform longitudinal analysis
**define event: transition to widowhood	<--- Hier ist sicherlich marriage gemeint, oder?
generate to_mar=1 if pgfamstd==1 & l.pgfamstd==3
tab to_mar

**standard way of life-event analysis
sum plh0182 if to_mar==1
sum l.plh0182 if to_mar==1


**alternative way
generate dif_sat= plh0182- l.plh0182
mean dif_sat if to_mar==1

**test on group differences
ttest dif_sat if to_mar==1, by(sex)

**preparing illustration of trajectory
generate t=0 if to_mar==1 & l.to_mar~=1 &l2.to_mar~=1 & l3.to_mar~=1 & l4.to_mar~=1 & l5.to_mar~=1 & l6.to_mar~=1 & l7.to_mar~=1 & l8.to_mar~=1 & l9.to_mar~=1 & l10.to_mar~=1 & l11.to_mar~=1 & l12.to_mar~=1 & l13.to_mar~=1 & l14.to_mar~=1
replace t=1 if l.t==0
replace t=2 if l2.t==0
replace t=3 if l3.t==0
replace t=-1 if f.t==0
replace t=-2 if f2.t==0
replace t=-3 if f3.t==0

table t, content (mean plh0182 n plh0182)



** Preparing graph of event analysis												<--- Das ist eine graphische Illustration
sort t
cap drop meanplh0182
by t: egen meanplh0182 = mean(plh0182)

cap drop upper
gen upper = .
forval i = -3/3{ 
	su plh0182 if t == `i'
	replace upper = r(mean) + 1.96 * r(sd)/sqrt(r(N)) if t == `i'
}

cap drop lower
gen lower = .
forval i = -3/3{ 
	su plh0182 if t == `i'
	replace lower = r(mean) - 1.96 * r(sd)/sqrt(r(N)) if t == `i'
}

twoway (line meanplh0182 t) (rcap upper lower t, lcolor("red")) , title("Satisfaction with life relative to year of marriage") legend(label(1 "Avg. life satisfaction") label(2 "95% Conf. interval")) scheme(s1mono) xtitle("Years relative to marriage") ytitle("Avg. life satisfaction")



