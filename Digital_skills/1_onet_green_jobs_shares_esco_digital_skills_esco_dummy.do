/******************************************************************************* 
BEGIN HEADER

Author : Daniele Gasparini
Document Title: 1_onet_green_jobs_shares_digital_skills_dummy.do
DocuVersion: 1.0
Stata Version: 17.0
Date: 11.09.2023
Purpose: Analysis of the shares of occupations having at least one digital skill
         in green occupations (as defined by O*NET), 
		 according to the ESCO classification 
		 
	
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

global path "J:\SBE_ROA\Thesis D. Gasparini\1_how green are jobs for the energy transition\1_data_analysis\"

global data_orig 	"${path}1_data_orig\" 
global data_prep 	"${path}2_data_prep\" 
global do_files 	"${path}3_do_files\" 
global log_files 	"${path}4_log_files\" 
global graphs 		"${path}5_graphs\"
global tables 		"${path}6_tables\"


  

 * 1. indicators of prevalence of digital skills by ESCO_ISCO occupation
*-------------------------------------------------------------------------------	

     use "${data_prep}49_merged_isco_occupations_categories_skills.dta", clear
	
	drop type_green type_transversal type_research type_language
	
	sort ESCO_ISCO ISCO08 type_relation type_digital type_skill skill
	
	****************************************************************************
	
	generate Non_digital = (type_digital == "Non digital")
	generate Digital = (type_digital == "Digital")
	
	generate Essential = (type_relation == "essential")
	generate Optional = (type_relation == "optional")
	
	generate Skill_Competence = (type_skill == "skill/competence")
	generate Knowledge = (type_skill == "knowledge")
	
	generate Skill_Competence_Essential = (Skill_Competence == 1 & Essential == 1 )
	generate Skill_Competence_Optional = (Skill_Competence == 1 & Optional == 1 )
	
	generate Knowledge_Essential = (Knowledge == 1 & Essential == 1 )
	generate Knowledge_Optional = (Knowledge == 1 & Optional == 1 )
	
	****************************************************************************
	
	sort ESCO_ISCO ISCO08 type_relation type_digital type_skill skill
	
	bysort ESCO_ISCO: egen n_Essential = total (Essential)
	bysort ESCO_ISCO: egen n_Optional = total (Optional)
	bysort ESCO_ISCO: gen n_skills = _N
	
	generate Essential_dig = (Essential == 1 & Digital == 1)
	generate Optional_dig = (Optional == 1 & Digital == 1)
	
	sort ESCO_ISCO ISCO08 type_relation type_digital type_skill skill
	
	bysort ESCO_ISCO: egen n_Essential_dig = total (Essential_dig)
	bysort ESCO_ISCO: egen n_Optional_dig = total (Optional_dig)
	bysort ESCO_ISCO: egen n_dig = total (Digital)
	
	generate d_Essential_dig = (n_Essential_dig > 0)
	generate d_Optional_dig = (n_Optional_dig > 0)
	generate d_dig = (n_dig > 0)
	
	****************************************************************************
	
	sort ESCO_ISCO ISCO08 type_skill type_digital type_relation skill
	
	bysort ESCO_ISCO: egen n_Skill_Competence = total (Skill_Competence)
	bysort ESCO_ISCO: egen n_Knowledge = total (Knowledge)
	
	sort ISCO08 ESCO_ISCO type_skill type_digital type_relation skill
	
	generate Skill_Competence_dig = (Skill_Competence == 1 & Digital == 1)
	generate Knowledge_dig = (Knowledge == 1 & Digital == 1)
	
	bysort ESCO_ISCO: egen n_Skill_Competence_dig = total (Skill_Competence_dig)
	bysort ESCO_ISCO: egen n_Knowledge_dig = total (Knowledge_dig)
	
	sort ESCO_ISCO ISCO08 type_skill type_digital type_relation skill
	
	generate d_Skill_Competence_dig = (n_Skill_Competence_dig > 0)
	generate d_Knowledge_dig = (n_Knowledge_dig > 0)

	
	****************************************************************************
	
	sort ESCO_ISCO ISCO08 type_skill type_relation type_digital skill
	
	bysort ESCO_ISCO: egen n_Skill_Competence_Essential = total (Skill_Competence_Essential)
	bysort ESCO_ISCO: egen n_Skill_Competence_Optional = total (Skill_Competence_Optional)
	
	bysort ESCO_ISCO: egen n_Knowledge_Essential = total (Knowledge_Essential)
	bysort ESCO_ISCO: egen n_Knowledge_Optional = total (Knowledge_Optional)
	
	sort ESCO_ISCO ISCO08 type_skill type_relation type_digital skill
	
	generate Skill_Competence_Essential_dig = (Skill_Competence == 1 & Essential == 1 & Digital == 1)
	generate Skill_Competence_Optional_dig = (Skill_Competence == 1 & Optional == 1 & Digital == 1)
	
	generate Knowledge_Essential_dig = (Knowledge == 1 & Essential == 1 & Digital == 1)
	generate Knowledge_Optional_dig = (Knowledge == 1 & Optional == 1 & Digital == 1)
	
	sort ESCO_ISCO ISCO08 type_skill type_relation type_digital skill
	
	bysort ESCO_ISCO: egen n_Skill_Competence_Ess_dig = total (Skill_Competence_Essential_dig)
	bysort ESCO_ISCO: egen n_Skill_Competence_Opt_dig = total (Skill_Competence_Optional_dig)
	
	bysort ESCO_ISCO: egen n_Knowledge_Ess_dig = total (Knowledge_Essential_dig)
	bysort ESCO_ISCO: egen n_Knowledge_Opt_dig = total (Knowledge_Optional_dig)
	
	sort ESCO_ISCO ISCO08 type_skill type_relation type_digital skill
	
	generate d_Skill_Competence_Ess_dig = ( n_Skill_Competence_Ess_dig > 0)
	generate d_Skill_Competence_Opt_dig = ( n_Skill_Competence_Opt_dig > 0)
	
	generate d_Knowledge_Ess_dig = ( n_Knowledge_Ess_dig > 0)
	generate d_Knowledge_Opt_dig = ( n_Knowledge_Opt_dig > 0)

	
	drop Non_digital Digital Essential Optional Skill_Competence Knowledge Skill_Competence_Essential Skill_Competence_Optional Knowledge_Essential Knowledge_Optional Essential_dig Optional_dig Skill_Competence_dig Knowledge_dig Skill_Competence_Essential_dig  Skill_Competence_Optional_dig Knowledge_Essential_dig Knowledge_Optional_dig n_dig n_Essential n_Optional n_Skill_Competence n_Knowledge n_Skill_Competence_Essential n_Skill_Competence_Optional n_Knowledge_Essential n_Knowledge_Optional n_Essential_dig n_Optional_dig n_Skill_Competence_dig n_Knowledge_dig n_Skill_Competence_Ess_dig  n_Skill_Competence_Opt_dig n_Knowledge_Ess_dig n_Knowledge_Opt_dig

	browse
	
	sort ESCO_ISCO
	quietly by ESCO_ISCO:  gen duplicate = cond(_N==1,0,_n)
	drop if duplicate > 1
	drop duplicate
	
	drop regulated_profession type_relation skill type_skill reusability title_skill type_digital n_skills merge7
	
	drop if missing(ISCO08)
	
	
	qui compress
    save "${data_prep}115_digital_skills_shares_esco_dummy", replace
	
	
	
* 3. Merge indicators of prevalence of digital skills by ESCO_ISCO occupation
*    (from "${data_prep}115_digital_skills_shares_esco_dummy")
*    with ONETSOC2019 codes
*    (from "${data_prep}87_crosswalk_esco_onet.dta")
*    though ESCO/ISCO codes
*-------------------------------------------------------------------------------	

   use "${data_prep}115_digital_skills_shares_esco_dummy", clear
   
   joinby ESCO_ISCO using "${data_prep}87_crosswalk_esco_onet.dta", update unmatched(master)
   
   rename _merge merge1
   
   browse
   
   sort merge1
   
   drop if missing(ONETSOC2019)
   
   sort ONETSOC2019
   
   browse
  
   qui compress
   save "${data_prep}116_onet_jobs_shares_digital_skills_esco_dummy", replace
	
 
 
  
* 4. indicators of prevalence of digital skills by ONET 2019 occupation
*-------------------------------------------------------------------------------	

   use "${data_prep}116_onet_jobs_shares_digital_skills_esco_dummy", clear
   
   browse
   
    bysort ONETSOC2019: gen total_isco_occup= _N
	
	bysort ONETSOC2019: egen total_ess_dig = total (d_Essential_dig)
	bysort ONETSOC2019: egen total_opt_dig = total (d_Optional_dig)
	bysort ONETSOC2019: egen total_dig = total (d_dig)
	
	bysort ONETSOC2019: egen total_skco_dig = total (d_Skill_Competence_dig)
	bysort ONETSOC2019: egen total_kno_dig = total (d_Knowledge_dig)
	
	bysort ONETSOC2019: egen total_skco_ess_dig = total (d_Skill_Competence_Ess_dig)
	bysort ONETSOC2019: egen total_skco_opt_dig = total (d_Skill_Competence_Opt_dig)
	bysort ONETSOC2019: egen total_kno_ess_dig = total (d_Knowledge_Ess_dig)
	bysort ONETSOC2019: egen total_kno_opt_dig = total (d_Knowledge_Opt_dig)
	
	
	gen Share_ess_dig = total_ess_dig / total_isco_occup
	gen Share_opt_dig = total_opt_dig / total_isco_occup
	gen Share_dig = total_dig / total_isco_occup
	
	gen Share_skco_dig = total_skco_dig / total_isco_occup
	gen Share_kno_dig = total_kno_dig / total_isco_occup
	
	gen Share_skco_ess_dig = total_skco_ess_dig / total_isco_occup
	gen Share_skco_opt_dig = total_skco_opt_dig / total_isco_occup
	gen Share_kno_ess_dig = total_kno_ess_dig / total_isco_occup
	gen Share_kno_opt_dig = total_kno_opt_dig / total_isco_occup
	
	format Share_ess_dig %9.2f
	format Share_opt_dig %9.2f
	format Share_dig %9.2f
    format Share_skco_dig %9.2f
	format Share_kno_dig %9.2f
	format Share_skco_ess_dig %9.2f
	format Share_skco_opt_dig %9.2f
	format Share_kno_ess_dig %9.2f
	format Share_kno_opt_dig %9.2f
	
	drop total_ess_dig total_opt_dig total_dig total_skco_dig total_kno_dig total_skco_ess_dig total_skco_opt_dig total_kno_ess_dig total_kno_opt_dig total_isco_occup d_Essential_dig d_Optional_dig d_dig d_Skill_Competence_dig d_Knowledge_dig d_Skill_Competence_Ess_dig d_Skill_Competence_Opt_dig d_Knowledge_Ess_dig d_Knowledge_Opt_dig 
	
	
   sort ONETSOC2019
   quietly by ONETSOC2019:  gen duplicate = cond(_N==1,0,_n)
   drop if duplicate > 1
   drop duplicate
   
   drop ESCO_ISCO
    
   browse
	
   qui compress
   save "${data_prep}117_onet_green_jobs_shares_digital_skills_esco_red_dummy", replace	
		
   
   
   
 * 5.  Merge O*NET green jobs
*     (from "${data_prep}117_onet_green_jobs_shares_digital_skills_esco_red_dummy")
*     with the levels of employment for each BRC2014 codes
*     (from "${data_prep}92_green_jobs_brc_employment_shares_red")
*     though the O*NET 2019 code
*-------------------------------------------------------------------------------	  
   
    use "${data_prep}117_onet_green_jobs_shares_digital_skills_esco_red_dummy", clear
	
	joinby ONETSOC2019 using "${data_prep}92_green_jobs_brc_employment_shares_red", update unmatched(both)
	
	browse
	
	sort _merge
	
	keep if _merge == 3
	
	drop _merge
	
	drop title_ONETSOC2019 title_ESCO_ISCO 
	
	sort BRC2014 ONETSOC2019
	
	sort BRC2014 ONETSOC2019
    quietly by BRC2014 ONETSOC2019:  gen duplicate = cond(_N==1,0,_n)
    drop if duplicate > 1
    drop duplicate
	
	sort BRC2014
	
	bysort BRC2014: egen sum_employment_brc = total (employment)
	quietly by BRC2014:  gen number_onet_per_brc = _N
	
	gen avg_employment_brc = sum_employment_brc / number_onet_per_brc
	
	bysort ONETSOC2019: egen tot_employment_onet = total(avg_employment_brc)
	

	drop BRC2014 employment sum_employment_brc number_onet_per_brc avg_employment_brc
	
	
    sort ONETSOC2019
    quietly by ONETSOC2019:  gen duplicate = cond(_N==1,0,_n)
    drop if duplicate > 1
    drop duplicate
	
	
	egen tot_sum_employment = total(tot_employment_onet)
	
	bysort ONETSOC2019: gen share_employment = tot_employment_onet / tot_sum_employment
   
	drop tot_sum_employment 
	
	rename tot_employment_onet employment
	
	qui compress
    save "${data_prep}118_green_jobs_digital_skills_brc_employment_shares_red", replace
	
	
	
*  6. Analysis of the shares of digital skills in green occupations 
*     (as defined by O*NET), according to the ESCO classification
*-------------------------------------------------------------------------------


  ** 6.1 Shares of digital skills in green occupations
	 

	use "${data_prep}118_green_jobs_digital_skills_brc_employment_shares_red", clear
	
	browse

	generate intensity_ess_dig = Share_ess_dig * employment
	generate intensity_non_ess_dig = (1 - Share_ess_dig) * employment
	
	generate intensity_opt_dig = Share_opt_dig * employment
	generate intensity_non_opt_dig = (1 - Share_opt_dig ) * employment
	
	generate intensity_dig = Share_dig * employment
	generate intensity_non_dig = (1 - Share_dig) * employment
	
	generate intensity_skco_dig = Share_skco_dig * employment
	generate intensity_non_skco_dig = (1 - Share_skco_dig) * employment
	
	generate intensity_kno_dig = Share_kno_dig * employment
	generate intensity_non_kno_dig = (1 - Share_kno_dig) * employment
	
	generate intensity_skco_ess_dig = Share_skco_ess_dig * employment
	generate intensity_non_skco_ess_dig = (1 - Share_skco_ess_dig) * employment
	
	generate intensity_skco_opt_dig = Share_skco_opt_dig * employment
	generate intensity_non_skco_opt_dig = (1 - Share_skco_opt_dig ) * employment
	
	generate intensity_kno_ess_dig = Share_kno_ess_dig * employment
	generate intensity_non_kno_ess_dig = (1 - Share_kno_ess_dig ) * employment
	
	generate intensity_kno_opt_dig = Share_kno_opt_dig * employment
	generate intensity_non_kno_opt_dig = (1 - Share_kno_opt_dig) * employment
	
	
    bysort Green_occupational_category: egen total_employment = total (employment)

	
	****************************************************************************
	
	*** Shares of digital skills out in green occupations
	
	
	graph hbar (sum) intensity_dig intensity_non_dig, over(Green_occupational_category, label(labsize(vsmall))) ylabel(,labsize(vsmall)) stack  percent nofill scheme(s1color) legend( label(1 "At least one digital skills") label(2 "No digital skills")) title("Green occupations (O*NET)") subtitle("Shares of occupations that have at least one digital skill")   blabel(bar, position(inside) format(%9.2f) color(white))
	graph export "${graphs}ONETjobsESCOskills_shares_onet_digital_skills_green_jobs_actual_dummy.pdf", replace	
	


	
	
	
	