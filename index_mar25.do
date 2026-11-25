/******************************************************************************* 
BEGIN HEADER

Author : Daniele Gasparini
Document Title: index_mar25.do
DocuVersion: 1.0
Stata Version: 17.0
Date: 18.03.2025
Purpose: Construction of the vulnerability index 
		 
	
--------------------------------------------------------------------------------
END HEADER 
********************************************************************************
*******************************************************************************/

clear all
cap log close

	
	
// specify stata specifics
version 17
set more off 
capture log close _all
pause on
clear all
set mem 6g
set maxvar 32767
set matsize 10000
set seed 1234567891
set scheme lean2 //s2color
set graphics on
set linesize 200
set scheme plotplain 


*** set relative paths ***

global path "J:\SBE_ROA\Thesis D. Gasparini\2_regional_vulnerability_to_the_energy_transition_in_the_Netherlands\4_fourth_version\vulnerability_index_fourth_version\"



global data_exp 	"${path}1_data_exported\" 
global data_prep 	"${path}2_final_dataset\" 
global do_files 	"${path}3_dofiles\" 
global output 	    "${path}5_output\" 


 * 1. Standardise the variables in the dataset
*-------------------------------------------------------------------------------

 use "${data_exp}final_dataset_corop.dta", clear
 
 browse
 
 keep Code_8 rel_energy_efficiency_corop rel_renewable_energy_corop patents_by_population_COROP avg_balassa_exp balassa_enerintens_exp share_en_int_corop avg_tax_income_corop

 order Code_8 share_en_int_corop balassa_enerintens_exp avg_balassa_exp rel_energy_efficiency_corop rel_renewable_energy_corop patents_by_population_COROP avg_tax_income_corop    
 
 gen Code_8n = substr(Code_8,3,2)
 drop Code_8
 destring Code_8n, replace
 rename Code_8n Code_8
 
 egen share_en_int_std =std(share_en_int_corop)
 egen balassa_enerintens_exp_std =std(balassa_enerintens_exp)
 egen balassa_exp_std =std(avg_balassa_exp)
 egen rel_energy_efficiency_std =std(rel_energy_efficiency_corop)
 egen rel_renewable_energy_std =std(rel_renewable_energy_corop)
 egen patents_by_population_std =std(patents_by_population_COROP)
 egen avg_tax_income_std =std(avg_tax_income_corop)
 
 drop rel_energy_efficiency_corop rel_renewable_energy_corop patents_by_population_COROP avg_balassa_exp balassa_enerintens_exp share_en_int_corop avg_tax_income_corop
 
   format share_en_int_std %9.3f
   format balassa_enerintens_exp_std %9.3f
   format balassa_exp_std %9.3f
   format rel_energy_efficiency_std %9.3f
   format rel_renewable_energy_std %9.3f
   format patents_by_population_std %9.3f
   format avg_tax_income_std %9.3f

   
   qui compress
   save "${data_prep}final_dataset_corop.dta", replace


  * 2. Import the data on the average educational attainment by COROP region
*-------------------------------------------------------------------------------

   import excel using "${data_exp}education.xlsx", firstrow clear //Source: Bevolking; hoogstbehaald onderwijsniveau en regio (https://opendata.cbs.nl/statline/#/CBS/nl/dataset/85525NED/table?ts=1729514328347)  (download: 21 Oct 2024)
   
   browse
   
   rename Onderwijsniveau3categorieën3 share_high_ed
   
   keep Code_8 share_high_ed
   
  qui compress
  save "${data_prep}education_corop", replace
   
   
* 3. Merge the data on the average educational attainment with the rest of 
*    the variables
*-------------------------------------------------------------------------------
   
    use "${data_prep}final_dataset_corop.dta", clear
 
    merge 1:1 Code_8 using "${data_prep}education_corop", update 
	
	drop _merge
   
    egen share_high_ed_std =std(share_high_ed)
	
	format share_high_ed_std %9.3f
	
	drop share_high_ed
	
	qui compress
    save "${data_prep}final_dataset_corop.dta", replace

	
	
	
* 4. Merge the data on employment rate with the rest of the variables
*-------------------------------------------------------------------------------
	
	use "${data_prep}final_dataset_corop.dta", clear
 
    merge 1:1 Code_8 using "${data_prep}employment_corop", update 
	
	drop _merge
   
	qui compress
    save "${data_prep}final_dataset_corop.dta", replace
	 
 
 * 5. Import the data on regional GDP excluding fossil fuel industry
*-------------------------------------------------------------------------------
	
	import excel using "${data_exp}sectoral_GDP.xlsx", firstrow clear //Source: Productieproces; bedrijfstak en regio, nationale rekeningen (https://opendata.cbs.nl/statline/#/CBS/nl/dataset/84419NED/table?ts=1729521943379)  (download: 21 Oct 2024)
	 
	destring Toegevoegdewaardevanuitproduc, generate(GDP)
    
    drop if missing(GDP)
   
    browse
  
    sort  Regios BedrijfstakkenbranchesSBI200
   
    bysort Regios: egen total_GDP = total (GDP)
	
	keep Regios total_GDP
   
	sort Regios
	quietly by Regios:  gen duplicate = cond(_N==1,0,_n)
	drop if duplicate > 1
	drop duplicate
	
	rename total_GDP GDP_corop
	
	qui compress
    save "${data_prep}gdp.dta", replace
	 
	 
* 7. Merge the data on regional GDP with the other variables
*-------------------------------------------------------------------------------
	
	use "${data_prep}final_dataset_corop.dta", clear
   
    merge 1:1 Regios using "${data_prep}gdp", update 
   
    drop _merge
   
    qui compress
    save "${data_prep}final_dataset_corop.dta", replace
   
   
* 8. Import the data on COROP population
*-------------------------------------------------------------------------------
  
 import excel using "${data_exp}population.xlsx", firstrow clear //Source: Bevolkingsontwikkeling; regio per maand (https://opendata.cbs.nl/statline/#/CBS/nl/dataset/37230ned/table?ts=1729542820305)  (download: 21 Oct 2024)
 
 keep Regios Populationon31Decembernumbe
 
  qui compress
  save "${data_prep}population_corop.dta", replace
  
  
 * 9. Merge the data on COROP population with the other variables
*-------------------------------------------------------------------------------
  
	use "${data_prep}final_dataset_corop.dta", clear
   
    merge 1:1 Regios using "${data_prep}population_corop.dta", update 
	
	drop _merge
	
	generate GDP_per_capita = GDP_corop / Populationon31Decembernumbe
	
	drop GDP_corop Populationon31Decembernumbe
	
	egen GDP_per_capita_std =std(GDP_per_capita)
	
	format GDP_per_capita_std %9.3f
	
	drop GDP_per_capita
	
   qui compress
   save "${data_prep}final_dataset_corop.dta", replace
   
   
 * 10. Merge share young population with other variables
*-------------------------------------------------------------------------------

   use "${data_exp}second_export.dta", clear
   
   keep Code_8 share_young
   
   gen Code_8n = substr(Code_8,3,2)
   
   destring Code_8n, generate(Code_8nn)
   
   drop Code_8 Code_8n
   
   rename Code_8nn Code_8
	  
   merge 1:1 Code_8 using "${data_prep}final_dataset_corop.dta", update
   
   egen share_young_std =std(share_young)
	
   format share_young_std %9.3f
   
   drop share_young
   
   order Code_8 Regios share_en_int_std balassa_enerintens_exp_std GDP_per_capita_std balassa_exp_std empl_rate_std rel_energy_efficiency_std rel_renewable_energy_std patents_by_population_std share_high_ed_std share_young_std avg_tax_income_std
   
   drop _merge 
   
   qui compress
   save "${data_prep}final_dataset_corop.dta", replace
   
   
  * 11. Merge the data on average firm size with the other variables
*-------------------------------------------------------------------------------
	
   use "${data_exp}third_export.dta", clear
	
   gen Code_8n = substr(Code_8,3,2)
   
   destring Code_8n, generate(Code_8nn)
   
   drop Code_8 Code_8n
   
   rename Code_8n Code_8
	
   merge 1:1 Code_8 using "${data_prep}final_dataset_corop", update 
	
   drop _merge Naam_9
   
   egen average_firm_size_std =std(average_firm_size)
	
   format average_firm_size_std %9.3f
   
   drop average_firm_size
   
  order  Code_8 Regios share_en_int_std balassa_enerintens_exp_std GDP_per_capita_std average_firm_size_std balassa_exp_std empl_rate_std rel_energy_efficiency_std rel_renewable_energy_std patents_by_population_std share_high_ed_std share_young_std avg_tax_income_std
   
   qui compress
   save "${data_prep}final_dataset_corop.dta", replace
   
   
 * 12. Merge the data on average energy cost, average training cost and 
 *     average R&D cost with the other variables
*-------------------------------------------------------------------------------
	
   use "${data_exp}fourth_export.dta", clear
	
   gen Code_8n = substr(Code_8,3,2)
   
   destring Code_8n, generate(Code_8nn)
   
   drop Code_8 Code_8n
   
   rename Code_8n Code_8
	
   merge 1:1 Code_8 using "${data_prep}final_dataset_corop", update 
	
   drop _merge
   
   egen avg_rel_ener_cost_std =std(avg_rel_ener_cost_corop)
   egen rel_res_dev_cost_std =std(avg_rel_rd_cost_corop)
   egen rel_training_cost_std =std(avg_rel_tra_cost_corop)
	
   format avg_rel_ener_cost_std %9.3f
   format rel_res_dev_cost_std %9.3f
   format rel_training_cost_std %9.3f
   
   drop avg_rel_ener_cost_corop avg_rel_rd_cost_corop avg_rel_tra_cost_corop
   
   order Code_8 Regios share_en_int_std balassa_enerintens_exp_std avg_rel_ener_cost_std GDP_per_capita_std average_firm_size_std balassa_exp_std empl_rate_std rel_energy_efficiency_std rel_renewable_energy_std rel_res_dev_cost_std patents_by_population_std rel_training_cost_std share_young_std share_high_ed_std avg_tax_income_std

  
   qui compress
   save "${data_prep}final_dataset_corop.dta", replace
   
 
 
 * 12. Compute the indexes for exposure, sensitivity and adaptive capacity
 *------------------------------------------------------------------------------
 
 use "${data_prep}final_dataset_corop.dta", clear
 
 generate GDP_per_capita_std_i = - GDP_per_capita_std
 generate balassa_exp_std_i = - balassa_exp_std
 generate average_firm_size_std_i = - average_firm_size_std
 generate empl_rate_std_i = - empl_rate_std
 
 drop GDP_per_capita_std balassa_exp_std average_firm_size_std empl_rate_std
 
 rename GDP_per_capita_std_i GDP_per_capita_std
 rename balassa_exp_std_i balassa_exp_std
 rename average_firm_size_std_i average_firm_size_std
 rename empl_rate_std_i empl_rate_std
 
 format GDP_per_capita_std %9.3f
 format balassa_exp_std %9.3f
 format average_firm_size_std %9.3f
 format empl_rate_std %9.3f
 
   order Code_8 Regios share_en_int_std balassa_enerintens_exp_std avg_rel_ener_cost_std GDP_per_capita_std balassa_exp_std average_firm_size_std empl_rate_std rel_energy_efficiency_std rel_renewable_energy_std patents_by_population_std rel_res_dev_cost_std rel_training_cost_std share_high_ed_std share_young_std avg_tax_income_std
 
 generate exposure = (share_en_int_std + balassa_enerintens_exp_std + avg_rel_ener_cost_std) / 3
 generate sensitivity = (GDP_per_capita_std + balassa_exp_std + average_firm_size_std + empl_rate_std) / 4
 generate adaptive_capacity = (rel_energy_efficiency_std + rel_renewable_energy_std + patents_by_population_std + rel_res_dev_cost_std + rel_training_cost_std + share_high_ed_std + share_young_std) / 7
 
 format exposure %9.3f
 format sensitivity %9.3f
 format adaptive_capacity %9.3f
 
 sort exposure
 sort sensitivity
 sort adaptive_capacity
 
 egen min_exposure = min(exposure)
 egen min_sensitivity = min(sensitivity)
 egen min_adaptive_capacity = min(adaptive_capacity)
 
 egen max_exposure = max(exposure)
 egen max_sensitivity = max(sensitivity)
 egen max_adaptive_capacity = max(adaptive_capacity)
 
 gen range_exposure = max_exposure - min_exposure
 gen range_sensitivity = max_sensitivity - min_sensitivity
 gen range_adaptive_capacity = max_adaptive_capacity - min_adaptive_capacity
 
 generate exposure_per = (exposure - min_exposure) / range_exposure
 generate sensitivity_per = (sensitivity - min_sensitivity) / range_sensitivity
 generate adaptive_capacity_per = ( adaptive_capacity - min_adaptive_capacity) / range_adaptive_capacity
 
 drop exposure sensitivity adaptive_capacity min_exposure min_sensitivity min_adaptive_capacity max_exposure max_sensitivity max_adaptive_capacity range_exposure range_sensitivity range_adaptive_capacity
 
 rename exposure_per exposure
 rename sensitivity_per sensitivity
 rename adaptive_capacity_per adaptive_capacity
 
 format exposure %9.3f
 format sensitivity %9.3f
 format adaptive_capacity %9.3f
 
 generate vulnerability = exposure * sensitivity * (1- adaptive_capacity) 
 
 format vulnerability %9.3f
 
 sort vulnerability
 
 egen min_vulnerability = min(vulnerability)
 egen max_vulnerability = max(vulnerability)
 gen range_vulnerability = max_vulnerability - min_vulnerability
 generate vulnerability_per = (vulnerability - min_vulnerability) / range_vulnerability
 
 drop vulnerability min_vulnerability max_vulnerability range_vulnerability
 
 rename vulnerability_per vulnerability
 format vulnerability %9.3f
 
 sort Code_8
 
 tostring Code_8, replace
 gen statcode = cond(length(Code_8) == 1, "CR0" + Code_8, "CR" + Code_8)
	
 sort vulnerability
 
  order statcode Code_8 Regios share_en_int_std balassa_enerintens_exp_std avg_rel_ener_cost_std GDP_per_capita_std balassa_exp_std average_firm_size_std empl_rate_std rel_energy_efficiency_std rel_renewable_energy_std patents_by_population_std rel_res_dev_cost_std rel_training_cost_std share_high_ed_std share_young_std avg_tax_income_std exposure sensitivity adaptive_capacity vulnerability
  

 qui compress
 save "${data_prep}final_dataset_corop.dta", replace
 
 
 * 13. Import the data on COROP population density
*-------------------------------------------------------------------------------
 
 import excel using "${data_exp}population_density.xlsx", firstrow clear //Source: Regionale kerncijfers Nederland 2024 (https://opendata.cbs.nl/statline/#/CBS/nl/dataset/70072NED/table?fromstatweb)  (download: 21 Oct 2024)
 
 browse
 keep Regios BevolkingBevolkingssamenstellin D
 
 rename BevolkingBevolkingssamenstellin population_corop
 rename D pop_density
 
 egen population_corop_std =std(population_corop)
 egen pop_density_std =std(pop_density)

 drop population_corop pop_density
 
 format population_corop_std %9.3f
 format pop_density_std %9.3f

 
 qui compress
 save "${data_prep}population_density.dta", replace
 
 
* 14. Merge the data on COROP population density with the other variables
*-------------------------------------------------------------------------------

   use "${data_prep}population_density.dta", clear
	  
   merge 1:1 Regios using "${data_prep}final_dataset_corop.dta", update
   
   order Code_8 Regios share_en_int_std balassa_enerintens_exp_std avg_rel_ener_cost_std GDP_per_capita_std balassa_exp_std average_firm_size_std empl_rate_std rel_energy_efficiency_std rel_renewable_energy_std patents_by_population_std rel_res_dev_cost_std rel_training_cost_std share_high_ed_std share_young_std population_corop_std pop_density_std avg_tax_income_std
   
   drop _merge
   
replace Regios = "Agglomeratie 's-Gravenhage" if Regios == "Agglomeratie 's-Gravenhage (CR)"
replace Regios = "Groot Amsterdam" if Regios == "Groot-Amsterdam (CR)"
replace Regios = "Zuidoost Noord Brabant" if Regios == "Zuidoost-Noord-Brabant (CR)"
replace Regios = "Agglomeratie Haarlem" if Regios == "Agglomeratie Haarlem (CR)"
replace Regios = "Delft en Westland" if Regios == "Delft en Westland (CR)"
replace Regios = "Het Gooi en Vechtstreek" if Regios == "Het Gooi en Vechtstreek (CR)"
replace Regios = "Utrecht" if Regios == "Utrecht (CR)"
replace Regios = "Agglomeratie Leiden en Bollenstreek" if Regios == "Agglomeratie Leiden en Bollenstreek (CR)"
replace Regios = "Oost Zuid Holland" if Regios == "Oost-Zuid-Holland (CR)"
replace Regios = "Midden Noord Brabant" if Regios == "Midden-Noord-Brabant (CR)"
replace Regios = "Noord Overijssel" if Regios == "Noord-Overijssel (CR)"
replace Regios = "Noordoost Noord Brabant" if Regios == "Noordoost-Noord-Brabant (CR)"
replace Regios = "Groot Rijnmond" if Regios == "Groot-Rijnmond (CR)"
replace Regios = "Zuidoost Zuid Holland" if Regios == "Zuidoost-Zuid-Holland (CR)"
replace Regios = "Zuidwest Overijssel" if Regios == "Zuidwest-Overijssel (CR)"
replace Regios = "Veluwe" if Regios == "Veluwe (CR)"
replace Regios = "Zaanstreek" if Regios == "Zaanstreek (CR)"
replace Regios = "Alkmaar en omgeving" if Regios == "Alkmaar en omgeving (CR)"
replace Regios = "Zuid Limburg" if Regios == "Zuid-Limburg (CR)"
replace Regios = "Twente" if Regios == "Twente (CR)"
replace Regios = "Arnhem/Nijmegen" if Regios == "Arnhem/Nijmegen (CR)"
replace Regios = "Noord Drenthe" if Regios == "Noord-Drenthe (CR)"
replace Regios = "Noord Limburg" if Regios == "Noord-Limburg (CR)"
replace Regios = "Zuidoost Friesland" if Regios == "Zuidoost-Friesland (CR)"
replace Regios = "Kop van Noord Holland" if Regios == "Kop van Noord-Holland (CR)"
replace Regios = "Zuidwest Gelderland" if Regios == "Zuidwest-Gelderland (CR)"
replace Regios = "West-Noord-Brabant" if Regios == "West-Noord-Brabant (CR)"
replace Regios = "Overig Groningen" if Regios == "Overig Groningen (CR)"
replace Regios = "Flevoland" if Regios == "Flevoland (CR)"
replace Regios = "Zuidwest Drenthe" if Regios == "Zuidwest-Drenthe (CR)"
replace Regios = "Overig Zeeland" if Regios == "Overig Zeeland (CR)"
replace Regios = "Noord Friesland" if Regios == "Noord-Friesland (CR)"
replace Regios = "Zuidoost Drenthe" if Regios == "Zuidoost-Drenthe (CR)"
replace Regios = "Midden Limburg" if Regios == "Midden-Limburg (CR)"
replace Regios = "Achterhoek" if Regios == "Achterhoek (CR)"
replace Regios = "Zuidwest Friesland" if Regios == "Zuidwest-Friesland (CR)"
replace Regios = "Oost Groningen" if Regios == "Oost-Groningen (CR)"
replace Regios = "IJmond" if Regios == "IJmond (CR)"
replace Regios = "Delfzijl en omgeving" if Regios == "Delfzijl en omgeving (CR)"
replace Regios = "Zeeuws Vlaanderen" if Regios == "Zeeuwsch-Vlaanderen (CR)"


   
   qui compress
   save "${data_prep}final_dataset_corop.dta", replace
   
 
 * 15. Correlation table
 *------------------------------------------------------------------------------
 
 pwcorr vulnerability exposure sensitivity adaptive_capacity population_corop_std pop_density_std avg_tax_income_std, sig star(.05)
 
 sort vulnerability

 
 * 16. Correlation between exposure and vulnerability
 *------------------------------------------------------------------------------


use "${data_prep}final_dataset_corop.dta", clear


gsort -vulnerability
gen order = _n

forval i = 1/`=_N' {
    local label = Regios[`i']
    label def order `i' "`label'", add
}

label val order order

tw (bar vulnerability order, barwidth(0.8) color(blue)) /// 
   (scatter exposure order, mcolor(orange) msymbol(square)), ///
xlabel(1/40, valuelabel angle(90) labs(vsmall)) ///
legend(pos(6) rows(1) lab(1 "REVIET") lab(2 "Exposure")) ///
ylabel(0(0.2)1, labs(small) angle(0)) xtitle("Comparison between exposure and vulnerability")

 graph export "${output}bar1.png", replace


 * 17. Vulnerability index without firm-specific variables
 *------------------------------------------------------------------------------

use "${data_prep}final_dataset_corop.dta", clear

 
 generate exposure_n = (share_en_int_std + balassa_enerintens_exp_std) / 2
 generate sensitivity_n = (GDP_per_capita_std + balassa_exp_std + average_firm_size_std + empl_rate_std) / 4
 generate adaptive_capacity_n = (patents_by_population_std + share_high_ed_std + share_young_std) / 3
 
 format exposure_n %9.3f
 format sensitivity_n %9.3f
 format adaptive_capacity_n %9.3f
 
 sort exposure_n
 sort sensitivity_n
 sort adaptive_capacity_n
 
 egen min_exposure_n = min(exposure_n)
 egen min_sensitivity_n = min(sensitivity_n)
 egen min_adaptive_capacity_n = min(adaptive_capacity_n)
 
 egen max_exposure_n = max(exposure_n)
 egen max_sensitivity_n = max(sensitivity_n)
 egen max_adaptive_capacity_n = max(adaptive_capacity_n)
 
 gen range_exposure_n = max_exposure_n - min_exposure_n
 gen range_sensitivity_n = max_sensitivity_n - min_sensitivity_n
 gen range_adaptive_capacity_n = max_adaptive_capacity_n - min_adaptive_capacity_n
 
 generate exposure_per_n = (exposure_n - min_exposure_n) / range_exposure_n
 generate sensitivity_per_n = (sensitivity_n - min_sensitivity_n) / range_sensitivity_n
 generate adaptive_capacity_per_n = ( adaptive_capacity_n - min_adaptive_capacity_n) / range_adaptive_capacity_n
 
 drop exposure_n sensitivity_n adaptive_capacity_n min_exposure_n min_sensitivity_n min_adaptive_capacity_n max_exposure_n max_sensitivity_n max_adaptive_capacity_n range_exposure_n range_sensitivity_n range_adaptive_capacity_n
 
 rename exposure_per_n exposure_n
 rename sensitivity_per_n sensitivity_n
 rename adaptive_capacity_per_n adaptive_capacity_n
 
 format exposure_n %9.3f
 format sensitivity_n %9.3f
 format adaptive_capacity_n %9.3f
 
 generate vulnerability_n = exposure_n * sensitivity_n * (1- adaptive_capacity_n) 
 
 format vulnerability_n %9.3f
 
 sort vulnerability_n
 
 egen min_vulnerability_n = min(vulnerability_n)
 egen max_vulnerability_n = max(vulnerability_n)
 gen range_vulnerability_n = max_vulnerability_n - min_vulnerability_n
 generate vulnerability_per_n = (vulnerability_n - min_vulnerability_n) / range_vulnerability_n
 
 drop vulnerability_n min_vulnerability_n max_vulnerability_n range_vulnerability_n
 
 rename vulnerability_per_n vulnerability_n
 format vulnerability_n %9.3f
 
 browse
 
 qui compress
 save "${data_prep}final_dataset_corop.dta", replace


* 18. Changes in the vulnerability scores, with and without including 
*     firm-level variables
 *------------------------------------------------------------------------------


use "${data_prep}final_dataset_corop.dta", clear

gsort -vulnerability
gen order = _n

forval i = 1/`=_N' {
    local label = Regios[`i']
    label def order `i' "`label'", add
}

label val order order

tw (bar vulnerability order, barwidth(0.8) color(blue)) /// 
   (scatter vulnerability_n order, mcolor(orange) msymbol(square)), ///
xlabel(1/40, valuelabel angle(90) labs(vsmall)) ///
legend(pos(6) rows(1) lab(1 "Vulnerability with firm-specific variables") lab(2 "Vulnerability without firm-specific variables")) ///
ylabel(0(0.2)1, labs(small) angle(0)) xtitle("Changes in the vulnerability scores, with and without including firm-level variables")

  graph export "${output}bar2.png", replace


* 19. Changes in the exposure scores, with and without including 
*     firm-level variables
 *------------------------------------------------------------------------------


use "${data_prep}final_dataset_corop.dta", clear

gsort -exposure
gen order = _n

forval i = 1/`=_N' {
    local label = Regios[`i']
    label def order `i' "`label'", add
}

label val order order

tw (bar exposure order, barwidth(0.8) color(blue)) /// 
   (scatter exposure_n order, mcolor(orange) msymbol(square)), ///
xlabel(1/40, valuelabel angle(90) labs(vsmall)) ///
legend(pos(6) rows(1) lab(1 "Exposure with firm-specific variables") lab(2 "Exposure without firm-specific variables")) ///
ylabel(0(0.2)1, labs(small) angle(0)) xtitle("Changes in the exposure scores, with and without including firm-level variables")

 graph export "${output}bar3.png", replace



* 20. Changes in the adaptive capacity scores, with and without including 
*     firm-level variables
 *------------------------------------------------------------------------------


use "${data_prep}final_dataset_corop.dta", clear

gsort -adaptive_capacity
gen order = _n

forval i = 1/`=_N' {
    local label = Regios[`i']
    label def order `i' "`label'", add
}

label val order order

tw (bar adaptive_capacity order, barwidth(0.8) color(blue)) /// 
   (scatter adaptive_capacity_n order, mcolor(orange) msymbol(square)), ///
xlabel(1/40, valuelabel angle(90) labs(vsmall)) ///
legend(pos(6) rows(1) lab(1 "Adaptive capacity with firm-specific variables") lab(2 "Adaptive capacity without firm-specific variables")) ///
ylabel(0(0.2)1, labs(small) angle(0)) xtitle("Changes in the adaptive capacity scores, with and without including firm-level variables")

   graph export "${output}bar4.png", replace

 
 * 21. Correlation between vulnerability and population density 
 *------------------------------------------------------------------------------

  use "${data_prep}final_dataset_corop.dta", clear


  spearman vulnerability pop_density_std, star(.05)
  correlate vulnerability pop_density_std, means 
  reg vulnerability pop_density_std
	  
  
  twoway (scatter vulnerability pop_density_std, xscale(range(0 0.6)) mcolor(dkgreen)  mlab(Code_8) ) (lfit vulnerability pop_density_std, xscale(range(0 0.6))), xtitle("Population density") ytitle("Vulnerability") legend(order(1 "Vulnerability" 2 "Population density"))

  graph export "${output}corr1.png", replace
  
  qui compress
 save "${data_prep}final_dataset_corop.dta", replace
  
  
  
  * 22. Correlation between the difference between exposure and short-run 
  *     resilience and population density 
 *------------------------------------------------------------------------------

  use "${data_prep}final_dataset_corop.dta", clear

  gen diff_exp_shortrunres = exposure - (1 - sensitivity)
  
  
  spearman diff_exp_shortrunres pop_density_std, star(.05)
  correlate diff_exp_shortrunres pop_density_std, means 
  reg diff_exp_shortrunres pop_density_std
	  

  twoway (scatter diff_exp_shortrunres pop_density_std, xscale(range(0 0.6)) mcolor(dkgreen)  mlab(Code_8) ) (lfit diff_exp_shortrunres pop_density_std, xscale(range(0 0.6))), xtitle("Population density") ytitle("EXP - (1 - SEN)") legend(order(1 "EXP - (1 - SEN)" 2 "Population density"))

  graph export "${output}corr2.png", replace
  
  qui compress
 save "${data_prep}final_dataset_corop.dta", replace
  
  

 
 * 23. Correlation between the difference between exposure and long-run 
 *     resilience and population density 
 *------------------------------------------------------------------------------

  use "${data_prep}final_dataset_corop.dta", clear

  gen diff_exp_longrunres = exposure - adaptive_capacity
  
  spearman diff_exp_longrunres pop_density_std, star(.05)
  correlate diff_exp_longrunres pop_density_std, means 
  reg diff_exp_longrunres pop_density_std
	  
  
  twoway (scatter diff_exp_longrunres pop_density_std, xscale(range(0 0.6)) mcolor(dkgreen)  mlab(Code_8) ) (lfit diff_exp_longrunres pop_density_std, xscale(range(0 0.6))), xtitle("Population density") ytitle("EXP - ADP") legend(order(1 "EXP - ADP" 2 "Population density"))

  graph export "${output}corr3.png", replace
  
  qui compress
 save "${data_prep}final_dataset_corop.dta", replace

 
 * 24. Correlation between the difference between short-run resilience and 
 *     long-run resilience and population density 
 *------------------------------------------------------------------------------

  use "${data_prep}final_dataset_corop.dta", clear

  gen difference_shortrunres_adapt = exposure*((1 - sensitivity) - (adaptive_capacity))
  
  spearman difference_shortrunres_adapt pop_density_std, star(.05)
  correlate difference_shortrunres_adapt pop_density_std, means 
  reg difference_shortrunres_adapt pop_density_std
	 
  
    twoway (scatter difference_shortrunres_adapt pop_density_std, xscale(range(0 0.6)) mcolor(dkgreen)  mlab(Code_8) ) (lfit difference_shortrunres_adapt pop_density_std, xscale(range(0 0.6))), xtitle("Population density") ytitle("(1 - SEN) - ADP") legend(order(1 "(1 - SEN) - ADP" 2 "Population density"))

  graph export "${output}corr4.png", replace
  
  qui compress
 save "${data_prep}final_dataset_corop.dta", replace
  
 
  * 25. Other variants of the vulnerability index 
  *     (different weights: 60% - 20% - 20%)
 *------------------------------------------------------------------------------

 use "${data_prep}final_dataset_corop.dta", clear
 
 
 generate vulnerability_w1 = exposure^(.6) * sensitivity^(.2) * (1- adaptive_capacity)^(.2) 
 
 format vulnerability_w1 %9.3f
 
 sort vulnerability_w1
 
 egen min_vulnerability_w1 = min(vulnerability_w1)
 egen max_vulnerability_w1 = max(vulnerability_w1)
 gen range_vulnerability_w1 = max_vulnerability_w1 - min_vulnerability_w1
 generate vulnerability_per_w1 = (vulnerability_w1 - min_vulnerability_w1) / range_vulnerability_w1
 
 drop vulnerability_w1 min_vulnerability_w1 max_vulnerability_w1 range_vulnerability_w1
 
 rename vulnerability_per_w1 vulnerability_w1
 format vulnerability_w1 %9.3f
 
 sort Code_8

 
 qui compress
 save "${data_prep}final_dataset_corop.dta", replace
 
 
 * 26. Other variants of the vulnerability index 
 *     (different weights: 40% - 30% - 30%)
 *------------------------------------------------------------------------------

 use "${data_prep}final_dataset_corop.dta", clear
 
 
 generate vulnerability_w2 = exposure^(.4) * sensitivity^(.3) * (1- adaptive_capacity)^(.3) 
 
 format vulnerability_w2 %9.3f
 
 sort vulnerability_w2
 
 egen min_vulnerability_w2 = min(vulnerability_w2)
 egen max_vulnerability_w2 = max(vulnerability_w2)
 gen range_vulnerability_w2 = max_vulnerability_w2 - min_vulnerability_w2
 generate vulnerability_per_w2 = (vulnerability_w2 - min_vulnerability_w2) / range_vulnerability_w2
 
 drop vulnerability_w2 min_vulnerability_w2 max_vulnerability_w2 range_vulnerability_w2
 
 rename vulnerability_per_w2 vulnerability_w2
 format vulnerability_w2 %9.3f
 
 sort vulnerability_w2

 
 qui compress
 save "${data_prep}final_dataset_corop.dta", replace

 
 * 27. Correlation between vulnerability and taxable income
 *------------------------------------------------------------------------------

  use "${data_prep}final_dataset_corop.dta", clear


  spearman vulnerability avg_tax_income_std, star(.05)
  correlate vulnerability avg_tax_income_std, means 
  reg vulnerability avg_tax_income_std
	  
  
  twoway (scatter vulnerability avg_tax_income_std, xscale(range(0 0.6)) mcolor(dkgreen)  mlab(Code_8) ) (lfit vulnerability avg_tax_income_std, xscale(range(0 0.6))), xtitle("Average taxable income") ytitle("Vulnerability") legend(order(1 "Vulnerability" 2 "Average taxable income"))

  graph export "${output}corr5.png", replace
  
  qui compress
 save "${data_prep}final_dataset_corop.dta", replace
  
  
  
  * 28. Correlation between the difference between exposure and short-run 
  *     resilience and taxable income 
 *------------------------------------------------------------------------------

  use "${data_prep}final_dataset_corop.dta", clear

  
  spearman diff_exp_shortrunres avg_tax_income_std, star(.05)
  correlate diff_exp_shortrunres avg_tax_income_std, means 
  reg diff_exp_shortrunres avg_tax_income_std
	  

  twoway (scatter diff_exp_shortrunres avg_tax_income_std, xscale(range(0 0.6)) mcolor(dkgreen)  mlab(Code_8) ) (lfit diff_exp_shortrunres avg_tax_income_std, xscale(range(0 0.6))), xtitle("Average taxable income") ytitle("EXP - (1 - SEN)") legend(order(1 "EXP - (1 - SEN)" 2 "Average taxable income"))

  graph export "${output}corr6.png", replace
  
  qui compress
 save "${data_prep}final_dataset_corop.dta", replace
  
  

 
 * 29. Correlation between the difference between exposure and long-run 
 *     resilience and taxable income 
 *------------------------------------------------------------------------------

  use "${data_prep}final_dataset_corop.dta", clear


  spearman diff_exp_longrunres avg_tax_income_std, star(.05)
  correlate diff_exp_longrunres avg_tax_income_std, means 
  reg diff_exp_longrunres avg_tax_income_std
	  
  
  twoway (scatter diff_exp_longrunres avg_tax_income_std, xscale(range(0 0.6)) mcolor(dkgreen)  mlab(Code_8) ) (lfit diff_exp_longrunres avg_tax_income_std, xscale(range(0 0.6))), xtitle("Average taxable income") ytitle("EXP - ADP") legend(order(1 "EXP - ADP" 2 "Average taxable income"))

  graph export "${output}corr7.png", replace
  
  qui compress
 save "${data_prep}final_dataset_corop.dta", replace

 
 * 30. Correlation between the difference between short-run resilience and 
 *     adaptive capacity and taxable income 
 *------------------------------------------------------------------------------

  use "${data_prep}final_dataset_corop.dta", clear

  
  spearman difference_shortrunres_adapt avg_tax_income_std, star(.05)
  correlate difference_shortrunres_adapt avg_tax_income_std, means 
  reg difference_shortrunres_adapt avg_tax_income_std
  
    twoway (scatter difference_shortrunres_adapt avg_tax_income_std, xscale(range(0 0.6)) mcolor(dkgreen)  mlab(Code_8) ) (lfit difference_shortrunres_adapt avg_tax_income_std, xscale(range(0 0.6))), xtitle("Average taxable income") ytitle("(1 - SEN) - ADP") legend(order(1 "(1 - SEN) - ADP" 2 "Average taxable income"))

  graph export "${output}corr8.png", replace
  
  qui compress
 save "${data_prep}final_dataset_corop.dta", replace
 
 
 * 31. Information about the distribution of the variable 'vulnerability' 
 *------------------------------------------------------------------------------
 
 use "${data_prep}final_dataset_corop.dta", clear
 
 summarize vulnerability, detail
 
 qui compress
 save "${data_prep}final_dataset_corop.dta", replace
 
 
 * 32. Contributions of the subcomponets to 'vulnerability' 
 *------------------------------------------------------------------------------
 
  use "${data_prep}final_dataset_corop.dta", clear
  
  reg vulnerability exposure sensitivity adaptive_capacity
  
  reg vulnerability share_en_int_std balassa_enerintens_exp_std avg_rel_ener_cost_std GDP_per_capita_std balassa_exp_std average_firm_size_std empl_rate_std rel_energy_efficiency_std rel_renewable_energy_std patents_by_population_std rel_res_dev_cost_std rel_training_cost_std share_high_ed_std share_young_std
   
  qui compress
  save "${data_prep}final_dataset_corop.dta", replace
 
 hist vulnerability, frequency title("Distribution of REVIET") xtitle("REVIET") ytitle("Absolute frequency")
 hist exposure, frequency title("Distribution of Exposure") xtitle("REVIET") ytitle("Absolute frequency")
 hist sensitivity, frequency title("Distribution of Sensitivity") xtitle("REVIET") ytitle("Absolute frequency")
 hist adaptive_capacity, frequency title("Distribution of Adaptive capacity") xtitle("REVIET") ytitle("Absolute frequency")
  
 summarize vulnerability, detail
 summarize exposure, detail
 
 
 * 33. Other variants of the vulnerability index 
  *     (different weights: 50% - 25% - 25%)
 *------------------------------------------------------------------------------

 use "${data_prep}final_dataset_corop.dta", clear
 
 
 generate vulnerability_w4 = exposure^(.5) * sensitivity^(.25) * (1- adaptive_capacity)^(.25) 
 
 format vulnerability_w4 %9.3f
 
 sort vulnerability_w4
 
 egen min_vulnerability_w4 = min(vulnerability_w4)
 egen max_vulnerability_w4 = max(vulnerability_w4)
 gen range_vulnerability_w4 = max_vulnerability_w4 - min_vulnerability_w4
 generate vulnerability_per_w4 = (vulnerability_w4 - min_vulnerability_w4) / range_vulnerability_w4
 
 drop vulnerability_w4 min_vulnerability_w4 max_vulnerability_w4 range_vulnerability_w4
 
 rename vulnerability_per_w4 vulnerability_w4
 format vulnerability_w4 %9.3f
 
 sort Code_8

 
 qui compress
 save "${data_prep}final_dataset_corop.dta", replace
 
 
 * 34. Other variants of the vulnerability index 
 *     (different weights: 25% - 50% - 25%)
 *------------------------------------------------------------------------------

 use "${data_prep}final_dataset_corop.dta", clear
 
 
 generate vulnerability_w5 = exposure^(.25) * sensitivity^(.50) * (1- adaptive_capacity)^(.25) 
 
 format vulnerability_w5 %9.3f
 
 sort vulnerability_w5
 
 egen min_vulnerability_w5 = min(vulnerability_w5)
 egen max_vulnerability_w5 = max(vulnerability_w5)
 gen range_vulnerability_w5 = max_vulnerability_w5 - min_vulnerability_w5
 generate vulnerability_per_w5 = (vulnerability_w5 - min_vulnerability_w5) / range_vulnerability_w5
 
 drop vulnerability_w5 min_vulnerability_w5 max_vulnerability_w5 range_vulnerability_w5
 
 rename vulnerability_per_w5 vulnerability_w5
 format vulnerability_w5 %9.3f
 
 sort vulnerability_w5

 
 qui compress
 save "${data_prep}final_dataset_corop.dta", replace

 
  
 * 35. Other variants of the vulnerability index 
 *     (different weights: 25% - 25% - 50%)
 *------------------------------------------------------------------------------

 use "${data_prep}final_dataset_corop.dta", clear
 
 
 generate vulnerability_w6 = exposure^(.25) * sensitivity^(.25) * (1- adaptive_capacity)^(.50) 
 
 format vulnerability_w6 %9.3f
 
 sort vulnerability_w6
 
 egen min_vulnerability_w6 = min(vulnerability_w6)
 egen max_vulnerability_w6 = max(vulnerability_w6)
 gen range_vulnerability_w6 = max_vulnerability_w6 - min_vulnerability_w6
 generate vulnerability_per_w6 = (vulnerability_w6 - min_vulnerability_w6) / range_vulnerability_w6
 
 drop vulnerability_w6 min_vulnerability_w6 max_vulnerability_w6 range_vulnerability_w6
 
 rename vulnerability_per_w6 vulnerability_w6
 format vulnerability_w6 %9.3f
 
 sort vulnerability_w6

 
 qui compress
 save "${data_prep}final_dataset_corop.dta", replace

  
 