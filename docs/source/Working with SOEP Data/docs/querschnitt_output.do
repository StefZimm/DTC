capture log close
log using "$MY_LOG_OUT\Uebung_III_2_3.log", replace

**********************************
*Uebungsblatt III: Querschnitt
*Beispielloesungen
*SOEP September 2017
**********************************




use "$MY_OUT_DATA\my_dataset.dta", clear


********************************************************************************
*** Exercise 2) ***
* Encode missing values into missing values in system missings (STATA)!
********************************************************************************

* mvdecode = Change missing values to numeric values and vice versa
	mvdecode _all, mv(-1=. \ -2=.t \ -3=.x \ -5=.y \ -8=.z)
 
 
********************************************************************************
*** Exercise 3) ***
*  How does average satisfaction with health differ by Sex, job status, age, 
*  income and smoking?
********************************************************************************

*a) by sex:
	*unweighted*
	tabstat yp0101, by(sex)
	*weighted* 
	tabstat yp0101 [aw=yphrf], by(sex)		
	
*b) by job status:
	*unweighted*
	tabstat yp0101, by(emplst08)
	*weighted*
	tabstat yp0101 [aw=yphrf], by(emplst08)

*c) by age in 2008 (<30, 30-64, 65+)
	
	gen age=2008-gebjahr
	gen age_3=age
	recode age_3 (17/29=1) (30/64=2) (65/120=3)
	label define age_3 1 "17-29" 2 "30-64" 3 "65+"
	label values age_3 age_3
	
	*unweighted*
	tabstat yp0101, by(age_3)
	*weighted*
	tabstat yp0101 [aw=yphrf], by(age_3) 

*d) by monthly houshold net income (-1.999, 2.000-3.999, 4000+ Euro)
	gen hinc08_3 = hinc08
	recode hinc08_3 (0/1999=1) (2000/3999=2) (4000/99999=3)
	label define hinc08_3 1 "<2000 Euro" 2 "2000-<4000 Euro" 3 "4000+ Euro"
	label values hinc08_3 hinc08_3
	
	*unweighted*
	tabstat yp0101, by(hinc08_3)
	*weighted*
	tabstat yp0101 [aw=yphrf], by(hinc08_3)

*e) by smoking yes/no

	*unweighted*
	tabstat yp0101, by(yp10601)
	
	*weighted*
	tabstat yp0101 [aw=yphrf], by(yp10601)  
 

log close
