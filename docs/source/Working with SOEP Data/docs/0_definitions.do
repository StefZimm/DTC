***********************************************
* Set some useful commands
***********************************************
version 13
clear all
set more off

***********************************************
* Set relative paths to the working directory
***********************************************
global AVZ 						"H:\material"
global MY_IN_PATH		        "Z:\DATA\soep33.1_de\stata" 
global MY_IN_PATH_long          "$AVZ\Daten\SOEP32_long_10\"
global MY_DO_FILES				"$AVZ\Übungen\do\"
global MY_LOG_OUT				"$AVZ\Übungen\log\"
global MY_OUT_DATA  			"$AVZ\Übungen\output\"
global MY_OUT_TEMP				"$AVZ\Übungen\temp\"

***********************************************
* Execute do-files
***********************************************
** Day 1
do "$MY_DO_FILES\Uebung_II.do"

do "$MY_DO_FILES\Uebung_III_2_3.do"

do "$MY_DO_FILES\Uebung_V.do"

* Day 2
do "$MY_DO_FILES\Uebung_IV_erzeugt_mit_paneldata.do"
do "$MY_DO_FILES\Uebung_IV_2_4.do" 


