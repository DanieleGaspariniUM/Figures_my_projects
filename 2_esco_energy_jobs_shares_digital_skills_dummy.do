/******************************************************************************* 
BEGIN HEADER

Author : Daniele Gasparini
Document Title: 2_esco_energy_jobs_shares_digital_skills_dummy.do
DocuVersion: 1.0
Stata Version: 17.0
Date: 28.08.2023
Purpose: Analysis of the occupations needed for the energy transition
         in terms of their digital skill content, according to the ESCO dataset

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
	
	drop ESCO_ISCO regulated_profession type_relation skill type_skill reusability title_skill type_digital n_skills
	
	
	qui compress
    save "${data_prep}72_digital_skills_shares_esco_dummy", replace

	
	
* 2. indicators of prevalence of digital skills by ISCO08 occupation
*-------------------------------------------------------------------------------	
	
	use "${data_prep}72_digital_skills_shares_esco_dummy", clear
	
	bysort ISCO08: gen total_isco_occup= _N
	
	bysort ISCO08: egen total_ess_dig_isco = total (d_Essential_dig)
	bysort ISCO08: egen total_opt_dig_isco = total (d_Optional_dig)
	bysort ISCO08: egen total_dig_isco = total (d_dig)
	
	bysort ISCO08: egen total_skco_dig_isco = total (d_Skill_Competence_dig)
	bysort ISCO08: egen total_kno_dig_isco = total (d_Knowledge_dig)
	
	bysort ISCO08: egen total_skco_ess_dig_isco = total (d_Skill_Competence_Ess_dig)
	bysort ISCO08: egen total_skco_opt_dig_isco = total (d_Skill_Competence_Opt_dig)
	bysort ISCO08: egen total_kno_ess_dig_isco = total (d_Knowledge_Ess_dig)
	bysort ISCO08: egen total_kno_opt_dig_isco = total (d_Knowledge_Opt_dig)
	
	
	gen Share_ess_dig_isco = total_ess_dig_isco / total_isco_occup
	gen Share_opt_dig_isco = total_opt_dig_isco / total_isco_occup
	gen Share_dig_isco = total_dig_isco / total_isco_occup
	
	gen Share_skco_dig_isco = total_skco_dig_isco / total_isco_occup
	gen Share_kno_dig_isco = total_kno_dig_isco / total_isco_occup
	
	gen Share_skco_ess_dig_isco = total_skco_ess_dig_isco / total_isco_occup
	gen Share_skco_opt_dig_isco = total_skco_opt_dig_isco / total_isco_occup
	gen Share_kno_ess_dig_isco = total_kno_ess_dig_isco / total_isco_occup
	gen Share_kno_opt_dig_isco = total_kno_opt_dig_isco / total_isco_occup
	
	format Share_ess_dig_isco %9.2f
	format Share_opt_dig_isco %9.2f
	format Share_dig_isco %9.2f
    format Share_skco_dig_isco %9.2f
	format Share_kno_dig_isco %9.2f
	format Share_skco_ess_dig_isco %9.2f
	format Share_skco_opt_dig_isco %9.2f
	format Share_kno_ess_dig_isco %9.2f
	format Share_kno_opt_dig_isco %9.2f
	
	drop total_ess_dig_isco total_opt_dig_isco total_dig_isco total_skco_dig_isco total_kno_dig_isco total_skco_ess_dig_isco total_skco_opt_dig_isco total_kno_ess_dig_isco total_kno_opt_dig_isco total_isco_occup d_Essential_dig d_Optional_dig d_dig d_Skill_Competence_dig d_Knowledge_dig d_Skill_Competence_Ess_dig d_Skill_Competence_Opt_dig d_Knowledge_Ess_dig d_Knowledge_Opt_dig 
	
	
	browse
	
	qui compress
    save "${data_prep}73_digital_skills_shares_isco_dummy", replace	
		
		
		
*  3. Merge the digital shares of ISCO08 occupations,
*     based on ESCO skills,
*     (from "${data_prep}73_digital_skills_shares_isco_dummy")
*     with BRC 2014 Codes 
*     (from "${data_prep}3_brc_isco.dta")
*     through ISCO08 Codes
*-------------------------------------------------------------------------------  

   use "${data_prep}73_digital_skills_shares_isco_dummy", clear
   
   joinby ISCO08 using "${data_prep}3b_brc_isco_employment_shares.dta", update unmatched(using)

   rename _merge merge2
   
   sort merge2 BRC2014 level_ISCO08 ISCO08 
 
   
   qui compress
   save "${data_prep}74_merged_digital_skills_shares_brc_dummy_p0", replace
   

   /// Shares of digital skills by BRC2014 for available ISCO08 codes
	
	use "${data_prep}74_merged_digital_skills_shares_brc_dummy_p0", clear
	
	bysort merge2 BRC2014: gen total_brc_occup= _N
	
	bysort merge2 BRC2014: egen total_ess_dig_brc = total (Share_ess_dig_isco)
	bysort merge2 BRC2014: egen total_opt_dig_brc = total (Share_opt_dig_isco)
	bysort merge2 BRC2014: egen total_dig_brc = total (Share_dig_isco)
	
	bysort merge2 BRC2014: egen total_skco_dig_brc = total (Share_skco_dig_isco)
	bysort merge2 BRC2014: egen total_kno_dig_brc = total (Share_kno_dig_isco)
	
	bysort merge2 BRC2014: egen total_skco_ess_dig_brc = total (Share_skco_ess_dig_isco)
	bysort merge2 BRC2014: egen total_skco_opt_dig_brc = total (Share_skco_opt_dig_isco)
	bysort merge2 BRC2014: egen total_kno_ess_dig_brc = total (Share_kno_ess_dig_isco)
	bysort merge2 BRC2014: egen total_kno_opt_dig_brc = total (Share_kno_opt_dig_isco)
	
	
	gen Share_ess_dig_brc = total_ess_dig_brc / total_brc_occup
	gen Share_opt_dig_brc = total_opt_dig_brc / total_brc_occup
	gen Share_dig_brc = total_dig_brc / total_brc_occup
	
	gen Share_skco_dig_brc = total_skco_dig_brc / total_brc_occup
	gen Share_kno_dig_brc = total_kno_dig_brc / total_brc_occup
	
	gen Share_skco_ess_dig_brc = total_skco_ess_dig_brc / total_brc_occup
	gen Share_skco_opt_dig_brc = total_skco_opt_dig_brc / total_brc_occup
	gen Share_kno_ess_dig_brc = total_kno_ess_dig_brc / total_brc_occup
	gen Share_kno_opt_dig_brc = total_kno_opt_dig_brc / total_brc_occup
	
	format Share_ess_dig_brc %9.2f
	format Share_opt_dig_brc %9.2f
	format Share_dig_brc %9.2f
    format Share_skco_dig_brc %9.2f
	format Share_kno_dig_brc %9.2f
	format Share_skco_ess_dig_brc %9.2f
	format Share_skco_opt_dig_brc %9.2f
	format Share_kno_ess_dig_brc %9.2f
	format Share_kno_opt_dig_brc %9.2f
	
	drop total_ess_dig_brc total_opt_dig_brc total_dig_brc total_skco_dig_brc total_kno_dig_brc total_skco_ess_dig_brc total_skco_opt_dig_brc total_kno_ess_dig_brc total_kno_opt_dig_brc total_brc_occup
	
	
	browse
	
	qui compress
    save "${data_prep}74a_merged_digital_skills_shares_brc_dummy_p1", replace
	
	
	
    /// Shares of digital skills by level of ISCO08
	
	use "${data_prep}74a_merged_digital_skills_shares_brc_dummy_p1", clear
	
    drop Share_ess_dig_brc Share_opt_dig_brc Share_dig_brc Share_skco_dig_brc Share_kno_dig_brc Share_skco_ess_dig_brc Share_skco_opt_dig_brc Share_kno_ess_dig_brc Share_kno_opt_dig_brc
   
   	bysort merge2 level_ISCO08: gen total_lev_occup= _N
	
	bysort merge2 level_ISCO08: egen total_ess_dig_lev = total (Share_ess_dig_isco)
	bysort merge2 level_ISCO08: egen total_opt_dig_lev = total (Share_opt_dig_isco)
	bysort merge2 level_ISCO08: egen total_dig_lev = total (Share_dig_isco)
	
	bysort merge2 level_ISCO08: egen total_skco_dig_lev = total (Share_skco_dig_isco)
	bysort merge2 level_ISCO08: egen total_kno_dig_lev = total (Share_kno_dig_isco)

	bysort merge2 level_ISCO08: egen total_skco_ess_dig_lev = total (Share_skco_ess_dig_isco)
	bysort merge2 level_ISCO08: egen total_skco_opt_dig_lev = total (Share_skco_opt_dig_isco)
	bysort merge2 level_ISCO08: egen total_kno_ess_dig_lev = total (Share_kno_ess_dig_isco)
	bysort merge2 level_ISCO08: egen total_kno_opt_dig_lev = total (Share_kno_opt_dig_isco)
	
	gen Share_ess_dig_lev = total_ess_dig_lev / total_lev_occup
	gen Share_opt_dig_lev = total_opt_dig_lev / total_lev_occup
	gen Share_dig_lev = total_dig_lev / total_lev_occup
	
	gen Share_skco_dig_lev = total_skco_dig_lev / total_lev_occup
	gen Share_kno_dig_lev = total_kno_dig_lev / total_lev_occup
	
	gen Share_skco_ess_dig_lev = total_skco_ess_dig_lev / total_lev_occup
	gen Share_skco_opt_dig_lev = total_skco_opt_dig_lev / total_lev_occup
	gen Share_kno_ess_dig_lev = total_kno_ess_dig_lev / total_lev_occup
	gen Share_kno_opt_dig_lev = total_kno_opt_dig_lev / total_lev_occup
	
	format Share_ess_dig_lev %9.2f
	format Share_opt_dig_lev %9.2f
	format Share_dig_lev %9.2f
    format Share_skco_dig_lev %9.2f
	format Share_kno_dig_lev %9.2f
	format Share_skco_ess_dig_lev %9.2f
	format Share_skco_opt_dig_lev %9.2f
	format Share_kno_ess_dig_lev %9.2f
	format Share_kno_opt_dig_lev %9.2f
	
	
	drop total_ess_dig_lev total_opt_dig_lev total_dig_lev total_skco_dig_lev total_kno_dig_lev total_skco_ess_dig_lev total_skco_opt_dig_lev total_kno_ess_dig_lev total_kno_opt_dig_lev 
	
	browse
	
	qui compress
    save "${data_prep}74b_merged_digital_skills_shares_brc_dummy_p2", replace
	
   
	
	/// Shares of digital skills by BRC2014: reduced dataset
	
	use "${data_prep}74a_merged_digital_skills_shares_brc_dummy_p1", clear
	
	drop Share_ess_dig_isco Share_opt_dig_isco Share_dig_isco Share_skco_dig_isco Share_kno_dig_isco Share_skco_ess_dig_isco Share_skco_opt_dig_isco Share_kno_ess_dig_isco Share_kno_opt_dig_isco
	
	sort merge2 BRC2014
	
	drop if merge2 == 2
	drop merge2 ISCO08 label_ISCO08_crosswalk title_BRC2014 level_ISCO08
	
	browse
	
    rename (Share_ess_dig_brc Share_opt_dig_brc Share_dig_brc Share_skco_dig_brc Share_kno_dig_brc Share_skco_ess_dig_brc Share_skco_opt_dig_brc Share_kno_ess_dig_brc Share_kno_opt_dig_brc) (Share_ess_dig_brc1 Share_opt_dig_brc1 Share_dig_brc1 Share_skco_dig_brc1 Share_kno_dig_brc1 Share_skco_ess_dig_brc1 Share_skco_opt_dig_brc1 Share_kno_ess_dig_brc1 Share_kno_opt_dig_brc1)
	
	sort BRC2014
	quietly by BRC2014:  gen duplicate = cond(_N==1,0,_n)
	drop if duplicate > 1
	drop duplicate

	qui compress
    save "${data_prep}74c_merged_digital_skills_shares_brc_dummy_p3", replace
   
    
	///  Shares of digital skills by level of ISCO08: reduced dataset
	
	use "${data_prep}74b_merged_digital_skills_shares_brc_dummy_p2", clear
	
	sort merge2 level_ISCO08
	
	drop if merge2 == 2
	drop merge2 ISCO08 label_ISCO08_crosswalk title_BRC2014 BRC2014
	
	
	 rename (Share_ess_dig_lev Share_opt_dig_lev Share_dig_lev Share_skco_dig_lev Share_kno_dig_lev Share_skco_ess_dig_lev Share_skco_opt_dig_lev Share_kno_ess_dig_lev Share_kno_opt_dig_lev) (Share_ess_dig_brc2 Share_opt_dig_brc2 Share_dig_brc2 Share_skco_dig_brc2 Share_kno_dig_brc2 Share_skco_ess_dig_brc2 Share_skco_opt_dig_brc2 Share_kno_ess_dig_brc2 Share_kno_opt_dig_brc2)
   
   
    sort level_ISCO08
	quietly by level_ISCO08:  gen duplicate = cond(_N==1,0,_n)
	drop if duplicate > 1
	drop duplicate

	qui compress
    save "${data_prep}74d_merged_digital_skills_shares_brc_dummy_p4", replace
	
	
   	/// substituting values for missing ISCO08 codes (managers)
    /// based on the level of ISCO08
  
   
	
	use "${data_prep}74c_merged_digital_skills_shares_brc_dummy_p3", clear
	
	merge 1:m BRC2014 using "${data_prep}74a_merged_digital_skills_shares_brc_dummy_p1", update
	
	rename _merge merge3
	
	browse
	
	drop Share_ess_dig_isco Share_opt_dig_isco Share_dig_isco Share_skco_dig_isco Share_kno_dig_isco Share_skco_ess_dig_isco Share_skco_opt_dig_isco Share_kno_ess_dig_isco Share_kno_opt_dig_isco
	
    replace merge2 = 7 if BRC2014 == "0551"
	
	
    drop if merge2 == 2
	
	sort merge2 merge3 BRC2014
	
	drop Share_ess_dig_brc1 Share_opt_dig_brc1 Share_dig_brc1 Share_skco_dig_brc1 Share_kno_dig_brc1 Share_skco_ess_dig_brc1 Share_skco_opt_dig_brc1 Share_kno_ess_dig_brc1 Share_kno_opt_dig_brc1
   
   
    qui compress
    save "${data_prep}74e_merged_digital_skills_shares_brc_dummy_p5", replace
	
	
	***
	
	
    use "${data_prep}74d_merged_digital_skills_shares_brc_dummy_p4", clear
	
	merge 1:m level_ISCO08 using "${data_prep}74e_merged_digital_skills_shares_brc_dummy_p5", update
	
	rename _merge merge4
	
	sort merge4 BRC2014
   
    replace Share_ess_dig_brc = Share_ess_dig_brc2 if BRC2014 == "0551"
	replace Share_opt_dig_brc = Share_opt_dig_brc2 if BRC2014 == "0551"
	replace Share_dig_brc = Share_dig_brc2 if BRC2014 == "0551"
	
	replace Share_skco_dig_brc = Share_skco_dig_brc2 if BRC2014 == "0551"
	replace Share_kno_dig_brc = Share_kno_dig_brc2 if BRC2014 == "0551"
	
	replace Share_skco_ess_dig_brc = Share_skco_ess_dig_brc2 if BRC2014 == "0551"
	replace Share_skco_opt_dig_brc = Share_skco_opt_dig_brc2 if BRC2014 == "0551"
	replace Share_kno_ess_dig_brc = Share_kno_ess_dig_brc2 if BRC2014 == "0551"
	replace Share_kno_opt_dig_brc = Share_kno_opt_dig_brc2 if BRC2014 == "0551"
	
	drop if level_ISCO08 == "ISCO-niveau 0"
	
	drop Share_ess_dig_brc2 Share_opt_dig_brc2 Share_dig_brc2 Share_skco_dig_brc2 Share_kno_dig_brc2 Share_skco_ess_dig_brc2 Share_skco_opt_dig_brc2 Share_kno_ess_dig_brc2 Share_kno_opt_dig_brc2
	
	drop merge4
	
	qui compress
    save "${data_prep}74f_merged_digital_skills_shares_brc_dummy_p6", replace
	
	
	/// Shares of digital skills by BRC2014: final estimates (avgs by BRC2014 
	*** after having estimated the shares of digital skills for missing ISCO08
	*** codes)
	
	use "${data_prep}74f_merged_digital_skills_shares_brc_dummy_p6", clear
	
    sort BRC2014
	
	browse
	
	bysort BRC2014: gen total_brcf_occup= _N
	
	bysort BRC2014: egen total_ess_dig_brcf = total (Share_ess_dig_brc)
	bysort BRC2014: egen total_opt_dig_brcf = total (Share_opt_dig_brc)
	bysort BRC2014: egen total_dig_brcf = total (Share_dig_brc)
	
	bysort BRC2014: egen total_skco_dig_brcf = total (Share_skco_dig_brc)
	bysort BRC2014: egen total_kno_dig_brcf = total (Share_kno_dig_brc)
	
	bysort BRC2014: egen total_skco_ess_dig_brcf = total (Share_skco_ess_dig_brc)
	bysort BRC2014: egen total_skco_opt_dig_brcf = total (Share_skco_opt_dig_brc)
	bysort BRC2014: egen total_kno_ess_dig_brcf = total (Share_kno_ess_dig_brc)
	bysort BRC2014: egen total_kno_opt_dig_brcf = total (Share_kno_opt_dig_brc)
	
	gen Share_ess_dig_brcf = total_ess_dig_brcf / total_brcf_occup
	gen Share_opt_dig_brcf = total_opt_dig_brcf / total_brcf_occup
	gen Share_dig_brcf = total_dig_brcf / total_brcf_occup
	
	gen Share_skco_dig_brcf = total_skco_dig_brcf / total_brcf_occup
	gen Share_kno_dig_brcf = total_kno_dig_brcf / total_brcf_occup
	
	gen Share_skco_ess_dig_brcf = total_skco_ess_dig_brcf / total_brcf_occup
	gen Share_skco_opt_dig_brcf = total_skco_opt_dig_brcf / total_brcf_occup
	gen Share_kno_ess_dig_brcf = total_kno_ess_dig_brcf / total_brcf_occup
	gen Share_kno_opt_dig_brcf = total_kno_opt_dig_brcf / total_brcf_occup
	
	format Share_ess_dig_brcf %9.2f
	format Share_opt_dig_brcf %9.2f
	format Share_dig_brcf %9.2f
    format Share_skco_dig_brcf %9.2f
	format Share_kno_dig_brcf %9.2f
	format Share_skco_ess_dig_brcf %9.2f
	format Share_skco_opt_dig_brcf %9.2f
	format Share_kno_ess_dig_brcf %9.2f
	format Share_kno_opt_dig_brcf %9.2f
	
	drop Share_ess_dig_brc Share_opt_dig_brc Share_dig_brc Share_skco_dig_brc Share_kno_dig_brc Share_skco_ess_dig_brc Share_skco_opt_dig_brc Share_kno_ess_dig_brc Share_kno_opt_dig_brc ISCO08
	
	drop total_ess_dig_brcf total_opt_dig_brcf total_dig_brcf total_skco_dig_brcf total_kno_dig_brcf total_skco_ess_dig_brcf total_skco_opt_dig_brcf total_kno_ess_dig_brcf total_kno_opt_dig_brcf total_brcf_occup
	
	rename (Share_ess_dig_brcf Share_opt_dig_brcf Share_dig_brcf Share_skco_dig_brcf Share_kno_dig_brcf Share_skco_ess_dig_brcf Share_skco_opt_dig_brcf Share_kno_ess_dig_brcf Share_kno_opt_dig_brcf)(Share_ess_dig_brc Share_opt_dig_brc Share_dig_brc Share_skco_dig_brc Share_kno_dig_brc Share_skco_ess_dig_brc Share_skco_opt_dig_brc Share_kno_ess_dig_brc Share_kno_opt_dig_brc)

	sort BRC2014
	quietly by BRC2014:  gen duplicate = cond(_N==1,0,_n)
	drop if duplicate > 1
	drop duplicate
	

	qui compress
    save "${data_prep}74g_merged_digital_skills_shares_brc_dummy_p7", replace
	
	
*    3. Merge mean percentages of ESCO digital skills by BRC2014 code
*       (from "${data_prep}56g_merged_digital_skills_shares_brc_p7")
*        with the PBL-ROA list of occupation groups needed for the energy 
*        transition
*       (from "${data_prep}7_jobs_energy_transition.dta")
*       through the BRC2014 code
*-------------------------------------------------------------------------------

    use "${data_prep}74g_merged_digital_skills_shares_brc_dummy_p7", clear
	
	joinby BRC2014 using "${data_prep}7_jobs_energy_transition.dta", update unmatched(master)

	rename _merge merge6

	replace type_investment = "n/a" if missing(type_investment)
	replace number_workers = 0 if missing(number_workers)
	replace total_per_investment = 0 if missing(total_per_investment)
	
	drop if type_investment == "n/a"
	drop if type_investment == "fossil_other"
	
	browse
	
	sort BRC2014  type_investment
	
	qui compress
	save "${data_prep}75_jobs_energy_transition_shares_digital_skills_dummy", replace

	


***  4.  Analysis of occupations needed for the energy transition
*-------------------------------------------------------------------------------

***  4.1  Shares of digital skills in occupations 
***       needed for the energy transition 

    
    use "${data_prep}75_jobs_energy_transition_shares_digital_skills_dummy", clear
	
	drop merge6 total_per_investment
	
	sort BRC2014 type_investment 
	quietly by BRC2014 type_investment:  gen duplicate = cond(_N==1,0,_n)
	drop if duplicate > 1
	drop duplicate
	
	drop if type_investment == "n/a"
	drop if type_investment == "fossil_other"
	
	browse
	
	qui compress
	save "${data_prep}76_jobs_energy_transition_shares_digital_skills_red_dummy", replace
	

	****************************************************************************
	
	use "${data_prep}76_jobs_energy_transition_shares_digital_skills_red_dummy", clear
	

	*** Shares of essential digital skills (skills/competences + knowledge) 
	*** out of the overall essential ESCO skills 
	*** in occupations needed for the energy transition
	
	generate intensity_essential_dig = Share_ess_dig_brc * number_workers
	generate intensity_non_essential_dig = (1 - Share_ess_dig_brc) * number_workers
	
	***  (a)  Comparison of shares (total = actual labour demand increase due to 
    ***       investment in the energy transition)
	
	graph hbar (sum) intensity_essential_dig intensity_non_essential_dig, over(type_investment, sort(number_workers) relabel( 1 "Other renewable energy sources" 2 "Electric road transport" 3 "Other road transport" 4 "Energy savings in industry" 5 "Energy savings in the fossil industry" 6 "Geothermal energy in agriculture" 7 "Electric grid" 8 "Heat pumps in agricolture" 9 "Energy savings in houses" 10 "Energy savings in petroleum refining" 11 "Solar energy" 12 "Wind energy") descending label(labsize(vsmall))) ylabel(,labsize(vsmall)) stack nofill scheme(s1color) legend(label(1 "Digital essential skills") label(2 "Non-digital essential skills") size(vsmall)) blabel(bar, position(inside) format(%9.2f) size(tiny) color(white))
	graph export "${graphs}ESCOskillsDIG_dummy_share_essential_digital_skills_energy_jobs_actual.pdf", replace
	
	
	
	***  (b) Comparison of shares 
    ***     (total = 100%)
	
	graph hbar (sum) intensity_essential_dig intensity_non_essential_dig, over(type_investment, sort(number_workers) relabel( 1 "Other renewable energy sources" 2 "Electric road transport" 3 "Other road transport" 4 "Energy savings in industry" 5 "Energy savings in the fossil industry" 6 "Geothermal energy in agriculture" 7 "Electric grid" 8 "Heat pumps in agricolture" 9 "Energy savings in houses" 10 "Energy savings in petroleum refining" 11 "Solar energy" 12 "Wind energy") descending label(labsize(vsmall))) ylabel(,labsize(vsmall)) stack percent nofill scheme(s1color) legend(label(1 "Digital essential skills") label(2 "Non-digital essential skills") size(vsmall)) blabel(bar, position(inside) format(%9.2f) size(tiny) color(white))
	graph export "${graphs}ESCOskillsDIG_dummy_share_essential_digital_skills_energy_jobs_100.pdf", replace
	
	

	****************************************************************************
	
	*** Shares of optional digital skills (skills/competences + knowledge) 
	*** out of the overall optional ESCO skills 
	*** in occupations needed for the energy transition
	
	generate intensity_optional_dig = Share_opt_dig_brc * number_workers
	generate intensity_non_optional_dig = (1 - Share_opt_dig_brc) * number_workers
	
	***  (a)  Comparison of shares (total = actual labour demand increase due to 
    ***       investment in the energy transition)
	
	graph hbar (sum) intensity_optional_dig intensity_non_optional_dig, over(type_investment, sort(number_workers) relabel( 1 "Other renewable energy sources" 2 "Electric road transport" 3 "Other road transport" 4 "Energy savings in industry" 5 "Energy savings in the fossil industry" 6 "Geothermal energy in agriculture" 7 "Electric grid" 8 "Heat pumps in agricolture" 9 "Energy savings in houses" 10 "Energy savings in petroleum refining" 11 "Solar energy" 12 "Wind energy") descending label(labsize(vsmall))) ylabel(,labsize(vsmall)) stack nofill scheme(s1color) legend(label(1 "Digital optional skills") label(2 "Non-digital optional skills") size(vsmall)) blabel(bar, position(inside) format(%9.2f) size(tiny) color(white))
	graph export "${graphs}ESCOskillsDIG_dummy_share_optional_digital_skills_energy_jobs_actual.pdf", replace
	
	***  (b) Comparison of shares 
    ***     (total = 100%)
	
	graph hbar (sum) intensity_optional_dig intensity_non_optional_dig, over(type_investment, sort(number_workers) relabel( 1 "Other renewable energy sources" 2 "Electric road transport" 3 "Other road transport" 4 "Energy savings in industry" 5 "Energy savings in the fossil industry" 6 "Geothermal energy in agriculture" 7 "Electric grid" 8 "Heat pumps in agricolture" 9 "Energy savings in houses" 10 "Energy savings in petroleum refining" 11 "Solar energy" 12 "Wind energy") descending label(labsize(vsmall))) ylabel(,labsize(vsmall)) stack percent nofill scheme(s1color) legend(label(1 "Digital optional skills") label(2 "Non-digital optional skills") size(vsmall)) blabel(bar, position(inside) format(%9.2f) size(tiny) color(white))
	graph export "${graphs}ESCOskillsDIG_dummy_share_optional_digital_skills_energy_jobs_100.pdf", replace
	

	****************************************************************************
	
	*** Shares of digital skills (skills/competences + knowledge) 
	*** out of the overall ESCO skills 
	*** in occupations needed for the energy transition
	
	
	generate intensity_dig = Share_dig_brc * number_workers
	generate intensity_non_dig = (1 - Share_dig_brc ) * number_workers
	
	***  (a)  Comparison of shares (total = actual labour demand increase due to 
    ***       investment in the energy transition)
	
	graph hbar (sum) intensity_dig intensity_non_dig, over(type_investment, sort(number_workers) relabel( 1 "Other renewable energy sources" 2 "Electric road transport" 3 "Other road transport" 4 "Energy savings in industry" 5 "Energy savings in the fossil industry" 6 "Geothermal energy in agriculture" 7 "Electric grid" 8 "Heat pumps in agricolture" 9 "Energy savings in houses" 10 "Energy savings in petroleum refining" 11 "Solar energy" 12 "Wind energy") descending label(labsize(vsmall))) ylabel(,labsize(vsmall)) stack nofill scheme(s1color) legend(label(1 "Digital skills") label(2 "Other") size(vsmall)) blabel(bar, position(inside) format(%9.2f) size(tiny) color(white))
	graph export "${graphs}ESCOskillsDIG_dummy_share_digital_skills_energy_jobs_actual.pdf", replace
	
	***  (b) Comparison of shares 
    ***     (total = 100%)
	
	graph hbar (sum) intensity_dig intensity_non_dig, over(type_investment, sort(number_workers) relabel( 1 "Other renewable energy sources" 2 "Electric road transport" 3 "Other road transport" 4 "Energy savings in industry" 5 "Energy savings in the fossil industry" 6 "Geothermal energy in agriculture" 7 "Electric grid" 8 "Heat pumps in agricolture" 9 "Energy savings in houses" 10 "Energy savings in petroleum refining" 11 "Solar energy" 12 "Wind energy") descending label(labsize(vsmall))) ylabel(,labsize(vsmall)) stack percent nofill scheme(s1color) legend(label(1 "Digital skills") label(2 "Other") size(vsmall)) blabel(bar, position(inside) format(%9.2f) size(tiny) color(white))
	graph export "${graphs}ESCOskillsDIG_dummy_share_digital_skills_energy_jobs_100.pdf", replace
	

	****************************************************************************
	
	*** Shares of digital skills/competences
	*** out of the overall ESCO skills/competences 
	*** in occupations needed for the energy transition
	
	
	generate intensity_dig_sk_comp = Share_skco_dig_brc * number_workers
	generate intensity_non_dig_sk_comp = (1 - Share_skco_dig_brc ) * number_workers
	
	***  (a)  Comparison of shares (total = actual labour demand increase due to 
    ***       investment in the energy transition)
	
	graph hbar (sum) intensity_dig_sk_comp intensity_non_dig_sk_comp, over(type_investment, sort(number_workers) relabel( 1 "Other renewable energy sources" 2 "Electric road transport" 3 "Other road transport" 4 "Energy savings in industry" 5 "Energy savings in the fossil industry" 6 "Geothermal energy in agriculture" 7 "Electric grid" 8 "Heat pumps in agricolture" 9 "Energy savings in houses" 10 "Energy savings in petroleum refining" 11 "Solar energy" 12 "Wind energy") descending label(labsize(vsmall))) ylabel(,labsize(vsmall)) stack nofill scheme(s1color) legend(label(1 "Digital skills & competences") label(2 "Non-digital skills & competences") size(vsmall)) blabel(bar, position(inside) format(%9.2f) size(tiny) color(white))
	graph export "${graphs}ESCOskillsDIG_dummy_share_digital_skco_energy_jobs_actual.pdf", replace
	
	***  (b) Comparison of shares 
    ***     (total = 100%)
	
	graph hbar (sum) intensity_dig_sk_comp intensity_non_dig_sk_comp, over(type_investment, sort(number_workers) relabel( 1 "Other renewable energy sources" 2 "Electric road transport" 3 "Other road transport" 4 "Energy savings in industry" 5 "Energy savings in the fossil industry" 6 "Geothermal energy in agriculture" 7 "Electric grid" 8 "Heat pumps in agricolture" 9 "Energy savings in houses" 10 "Energy savings in petroleum refining" 11 "Solar energy" 12 "Wind energy") descending label(labsize(vsmall))) ylabel(,labsize(vsmall)) stack percent nofill scheme(s1color) legend(label(1 "Digital skills & competences") label(2 "Non-digital skills & competences") size(vsmall)) blabel(bar, position(inside) format(%9.2f) size(tiny) color(white))
	graph export "${graphs}ESCOskillsDIG_dummy_share_digital_skco_energy_jobs_100.pdf", replace
	

	***************************************************************************
	 
	*** Shares of digital knowledge concepts
	*** out of the overall ESCO knowledge concepts 
	*** in occupations needed for the energy transition
	
	generate intensity_dig_know = Share_kno_dig_brc * number_workers
	generate intensity_non_dig_know = (1 - Share_kno_dig_brc ) * number_workers
	
	***  (a)  Comparison of shares (total = actual labour demand increase due to 
    ***       investment in the energy transition)
	
	graph hbar (sum) intensity_dig_know intensity_non_dig_know, over(type_investment, sort(number_workers) relabel( 1 "Other renewable energy sources" 2 "Electric road transport" 3 "Other road transport" 4 "Energy savings in industry" 5 "Energy savings in the fossil industry" 6 "Geothermal energy in agriculture" 7 "Electric grid" 8 "Heat pumps in agricolture" 9 "Energy savings in houses" 10 "Energy savings in petroleum refining" 11 "Solar energy" 12 "Wind energy") descending label(labsize(vsmall))) ylabel(,labsize(vsmall)) stack nofill scheme(s1color) legend(label(1 "Digital knowledge concepts") label(2 "Non-digital knowledge concepts") size(vsmall)) blabel(bar, position(inside) format(%9.2f) size(tiny) color(white))
	graph export "${graphs}ESCOskillsDIG_dummy_share_digital_kno_energy_jobs_actual.pdf", replace
	
	***  (b) Comparison of shares 
    ***     (total = 100%)
	
	graph hbar (sum) intensity_dig_know intensity_non_dig_know, over(type_investment, sort(number_workers) relabel( 1 "Other renewable energy sources" 2 "Electric road transport" 3 "Other road transport" 4 "Energy savings in industry" 5 "Energy savings in the fossil industry" 6 "Geothermal energy in agriculture" 7 "Electric grid" 8 "Heat pumps in agricolture" 9 "Energy savings in houses" 10 "Energy savings in petroleum refining" 11 "Solar energy" 12 "Wind energy") descending label(labsize(vsmall))) ylabel(,labsize(vsmall)) stack percent nofill scheme(s1color) legend(label(1 "Digital knowledge concepts") label(2 "Non-digital knowledge concepts") size(vsmall)) blabel(bar, position(inside) format(%9.2f) size(tiny) color(white))
	graph export "${graphs}ESCOskillsDIG_dummy_share_digital_kno_energy_jobs_100.pdf", replace
	
	
	****************************************************************************
	
	*** Shares of digital essential skills/competences
	*** out of the overall ESCO essential skills/competences 
	*** in occupations needed for the energy transition
	
	
	generate intensity_dig_ess_sk_comp = Share_skco_ess_dig_brc * number_workers
	generate intensity_non_dig_ess_sk_comp = (1 - Share_skco_ess_dig_brc ) * number_workers
	
	***  (a)  Comparison of shares (total = actual labour demand increase due to 
    ***       investment in the energy transition)
	
	graph hbar (sum) intensity_dig_ess_sk_comp intensity_non_dig_ess_sk_comp, over(type_investment, sort(number_workers) relabel( 1 "Other renewable energy sources" 2 "Electric road transport" 3 "Other road transport" 4 "Energy savings in industry" 5 "Energy savings in the fossil industry" 6 "Geothermal energy in agriculture" 7 "Electric grid" 8 "Heat pumps in agricolture" 9 "Energy savings in houses" 10 "Energy savings in petroleum refining" 11 "Solar energy" 12 "Wind energy") descending label(labsize(vsmall))) ylabel(,labsize(vsmall)) stack nofill scheme(s1color) legend(label(1 "Digital essential skills & competences") label(2 "Non-digital essential skills & competences") size(vsmall)) blabel(bar, position(inside) format(%9.2f) size(tiny) color(white))
	graph export "${graphs}ESCOskillsDIG_dummy_share_digital_essential_skco_energy_jobs_actual.pdf", replace
	
	***  (b) Comparison of shares 
    ***     (total = 100%)
	
	graph hbar (sum) intensity_dig_ess_sk_comp intensity_non_dig_ess_sk_comp, over(type_investment, sort(number_workers) relabel( 1 "Other renewable energy sources" 2 "Electric road transport" 3 "Other road transport" 4 "Energy savings in industry" 5 "Energy savings in the fossil industry" 6 "Geothermal energy in agriculture" 7 "Electric grid" 8 "Heat pumps in agricolture" 9 "Energy savings in houses" 10 "Energy savings in petroleum refining" 11 "Solar energy" 12 "Wind energy") descending label(labsize(vsmall))) ylabel(,labsize(vsmall)) stack percent nofill scheme(s1color) legend(label(1 "Digital essential skills & competences") label(2 "Non-digital essential skills & competences") size(vsmall)) blabel(bar, position(inside) format(%9.2f) size(tiny) color(white))
	graph export "${graphs}ESCOskillsDIG_dummy_share_digital_essential_skco_energy_jobs_100.pdf", replace

	
	****************************************************************************
	
	*** Shares of digital optional skills/competences
	*** out of the overall ESCO optional skills/competences 
	*** in occupations needed for the energy transition
	
	
	generate intensity_dig_opt_sk_comp = Share_skco_opt_dig_brc * number_workers
	generate intensity_non_dig_opt_sk_comp = (1 - Share_skco_opt_dig_brc ) * number_workers
	
	***  (a)  Comparison of shares (total = actual labour demand increase due to 
    ***       investment in the energy transition)
	
	graph hbar (sum) intensity_dig_opt_sk_comp intensity_non_dig_opt_sk_comp, over(type_investment, sort(number_workers) relabel( 1 "Other renewable energy sources" 2 "Electric road transport" 3 "Other road transport" 4 "Energy savings in industry" 5 "Energy savings in the fossil industry" 6 "Geothermal energy in agriculture" 7 "Electric grid" 8 "Heat pumps in agricolture" 9 "Energy savings in houses" 10 "Energy savings in petroleum refining" 11 "Solar energy" 12 "Wind energy") descending label(labsize(vsmall))) ylabel(,labsize(vsmall)) stack nofill scheme(s1color) blabel(bar, position(inside) format(%9.2f) size(tiny) color(white))
	graph export "${graphs}ESCOskillsDIG_dummy_share_digital_optional_skco_energy_jobs_actual.pdf", replace
	
	***  (b) Comparison of shares 
    ***     (total = 100%)
	
	graph hbar (sum) intensity_dig_opt_sk_comp intensity_non_dig_opt_sk_comp, over(type_investment, sort(number_workers) relabel( 1 "Other renewable energy sources" 2 "Electric road transport" 3 "Other road transport" 4 "Energy savings in industry" 5 "Energy savings in the fossil industry" 6 "Geothermal energy in agriculture" 7 "Electric grid" 8 "Heat pumps in agricolture" 9 "Energy savings in houses" 10 "Energy savings in petroleum refining" 11 "Solar energy" 12 "Wind energy") descending label(labsize(vsmall))) ylabel(,labsize(vsmall)) stack percent nofill scheme(s1color) legend(label(1 "Digital optional skills & competences") label(2 "Non-digital optional skills & competences") size(vsmall)) blabel(bar, position(inside) format(%9.2f) size(tiny) color(white))
	graph export "${graphs}ESCOskillsDIG_dummy_share_digital_optional_skco_energy_jobs_100.pdf", replace
	
	
	***************************************************************************
	 
	*** Shares of digital essential knowledge concepts
	*** out of the overall ESCO essential knowledge concepts 
	*** in occupations needed for the energy transition
	
	
	generate intensity_dig_ess_know =  Share_kno_ess_dig_brc * number_workers
	generate intensity_non_dig_ess_know = (1 - Share_kno_ess_dig_brc) * number_workers
	
	***  (a)  Comparison of shares (total = actual labour demand increase due to 
    ***       investment in the energy transition)
	
	graph hbar (sum) intensity_dig_ess_know intensity_non_dig_ess_know, over(type_investment, sort(number_workers) relabel( 1 "Other renewable energy sources" 2 "Electric road transport" 3 "Other road transport" 4 "Energy savings in industry" 5 "Energy savings in the fossil industry" 6 "Geothermal energy in agriculture" 7 "Electric grid" 8 "Heat pumps in agricolture" 9 "Energy savings in houses" 10 "Energy savings in petroleum refining" 11 "Solar energy" 12 "Wind energy") descending label(labsize(vsmall))) ylabel(,labsize(vsmall)) stack nofill scheme(s1color) legend(label(1 "Digital essential knowledge concepts") label(2 "Non-digital essential knowledge concepts") size(vsmall)) blabel(bar, position(inside) format(%9.2f) size(tiny) color(white))
	graph export "${graphs}ESCOskillsDIG_dummy_share_digital_essential_kno_energy_jobs_actual.pdf", replace
	
	***  (b) Comparison of shares 
    ***     (total = 100%)
	
	graph hbar (sum) intensity_dig_ess_know intensity_non_dig_ess_know, over(type_investment, sort(number_workers) relabel( 1 "Other renewable energy sources" 2 "Electric road transport" 3 "Other road transport" 4 "Energy savings in industry" 5 "Energy savings in the fossil industry" 6 "Geothermal energy in agriculture" 7 "Electric grid" 8 "Heat pumps in agricolture" 9 "Energy savings in houses" 10 "Energy savings in petroleum refining" 11 "Solar energy" 12 "Wind energy") descending label(labsize(vsmall))) ylabel(,labsize(vsmall)) stack percent nofill scheme(s1color) legend(label(1 "Digital essential knowledge concepts") label(2 "Non-digital essential knowledge concepts") size(vsmall)) blabel(bar, position(inside) format(%9.2f) size(tiny) color(white))
	graph export "${graphs}ESCOskillsDIG_dummy_share_digital_essential_kno_energy_jobs_100.pdf", replace
	
	
    ****************************************************************************
	 
	*** Shares of digital optional knowledge concepts
	*** out of the overall ESCO optional knowledge concepts 
	*** in occupations needed for the energy transition
	

	generate intensity_dig_opt_know =  Share_kno_opt_dig_brc * number_workers
	generate intensity_non_dig_opt_know = (1 -  Share_kno_opt_dig_brc ) * number_workers
	
	***  (a)  Comparison of shares (total = actual labour demand increase due to 
    ***       investment in the energy transition)
	
	graph hbar (sum) intensity_dig_opt_know intensity_non_dig_opt_know, over(type_investment, sort(number_workers) relabel( 1 "Other renewable energy sources" 2 "Electric road transport" 3 "Other road transport" 4 "Energy savings in industry" 5 "Energy savings in the fossil industry" 6 "Geothermal energy in agriculture" 7 "Electric grid" 8 "Heat pumps in agricolture" 9 "Energy savings in houses" 10 "Energy savings in petroleum refining" 11 "Solar energy" 12 "Wind energy") descending label(labsize(vsmall))) ylabel(,labsize(vsmall)) stack nofill scheme(s1color) legend(label(1 "Digital optional knowledge concepts") label(2 "Non-digital optional knowledge concepts") size(vsmall)) blabel(bar, position(inside) format(%9.2f) size(tiny) color(white))
	graph export "${graphs}ESCOskillsDIG_dummy_share_digital_essential_kno_energy_jobs_actual.pdf", replace
	
	***  (b) Comparison of shares 
    ***     (total = 100%)
	
	graph hbar (sum) intensity_dig_opt_know intensity_non_dig_opt_know, over(type_investment, sort(number_workers) relabel( 1 "Other renewable energy sources" 2 "Electric road transport" 3 "Other road transport" 4 "Energy savings in industry" 5 "Energy savings in the fossil industry" 6 "Geothermal energy in agriculture" 7 "Electric grid" 8 "Heat pumps in agricolture" 9 "Energy savings in houses" 10 "Energy savings in petroleum refining" 11 "Solar energy" 12 "Wind energy") descending label(labsize(vsmall))) ylabel(,labsize(vsmall)) stack percent nofill scheme(s1color) legend(label(1 "Digital optional knowledge concepts") label(2 "Non-digital optional knowledge concepts") size(vsmall)) blabel(bar, position(inside) format(%9.2f) size(tiny) color(white))
	graph export "${graphs}ESCOskillsDIG_dummy_share_digital_essential_kno_energy_jobs_100.pdf", replace
	
	
	

    ****************************************************************************
	
***  4.2  Correlation between shares of digital skills and need for investment 
***       in the energy transition

	
	 use "${data_prep}76_jobs_energy_transition_shares_digital_skills_red_dummy", clear
	
	 drop if type_investment == "n/a"
	 drop if type_investment == "fossil_other"
	
	 browse

	 bysort BRC2014: egen tot_number_workers = total (number_workers)
	
	
	 qui compress
     save "${data_prep}77_correlations_digital_skills_esco_dummy", replace
	 
	
	//   Correlations for all the observations
     
	 use "${data_prep}77_correlations_digital_skills_esco_dummy", clear
	 
	 ***
	
	 spearman tot_number_workers Share_ess_dig_brc, star(.05)
     correlate tot_number_workers Share_ess_dig_brc, means 
	 reg tot_number_workers Share_ess_dig_brc
	
     twoway (scatter tot_number_workers Share_ess_dig_brc, xscale(range(0 1)) mcolor(gold))(lfit tot_number_workers Share_ess_dig_brc, xscale(range(0 1)))
	 graph export "${graphs}ESCOskillsDIG_dummy_correlation_essential_digital_skills_energy_jobs_all.pdf", replace
	 
	
	 ***
	 
	 spearman tot_number_workers Share_opt_dig_brc, star(.05)
     correlate tot_number_workers Share_opt_dig_brc, means 
	 reg tot_number_workers Share_opt_dig_brc
	
     twoway (scatter tot_number_workers Share_opt_dig_brc, xscale(range(0 1)) mcolor(gold))(lfit tot_number_workers Share_opt_dig_brc, xscale(range(0 1)))
	 graph export "${graphs}ESCOskillsDIG_dummy_correlation_optional_digital_skills_energy_jobs_all.pdf", replace
	 
	
	 ***
	 
	 spearman tot_number_workers Share_dig_brc, star(.05)
     correlate tot_number_workers Share_dig_brc, means 
	 reg tot_number_workers Share_dig_brc
	
     twoway (scatter tot_number_workers Share_dig_brc, xscale(range(0 1)) mcolor(gold))(lfit tot_number_workers Share_dig_brc, xscale(range(0 1)))
	 graph export "${graphs}ESCOskillsDIG_dummy_correlation_digital_skills_energy_jobs_all.pdf", replace
	 
	
	 ***
	 
	 spearman tot_number_workers  Share_skco_dig_brc, star(.05)
     correlate tot_number_workers  Share_skco_dig_brc, means 
	 reg tot_number_workers  Share_skco_dig_brc
	
     twoway (scatter tot_number_workers  Share_skco_dig_brc, xscale(range(0 1)) mcolor(gold))(lfit tot_number_workers  Share_skco_dig_brc, xscale(range(0 1)))
	 graph export "${graphs}ESCOskillsDIG_dummy_correlation_skco_digital_skills_energy_jobs_all.pdf", replace
	 
	 ***
	 
	 spearman tot_number_workers  Share_kno_dig_brc, star(.05)
     correlate tot_number_workers  Share_kno_dig_brc, means 
	 reg tot_number_workers Share_kno_dig_brc
	
     twoway (scatter tot_number_workers Share_kno_dig_brc, xscale(range(0 1)) mcolor(gold))(lfit tot_number_workers Share_kno_dig_brc, xscale(range(0 1)))
	 graph export "${graphs}ESCOskillsDIG_dummy_correlation_kno_digital_skills_energy_jobs_all.pdf", replace
	   
	 
	 ***
	 
	 spearman tot_number_workers  Share_skco_ess_dig_brc, star(.05)
     correlate tot_number_workers  Share_skco_ess_dig_brc, means 
	 reg tot_number_workers Share_skco_ess_dig_brc
	
     twoway (scatter tot_number_workers Share_skco_ess_dig_brc, xscale(range(0 1)) mcolor(gold))(lfit tot_number_workers Share_skco_ess_dig_brc, xscale(range(0 1)))
	 graph export "${graphs}ESCOskillsDIG_dummy_correlation_skco_essential_digital_skills_energy_jobs_all.pdf", replace
	 
	 
	 ***
	 
	 spearman tot_number_workers Share_skco_opt_dig_brc, star(.05)
     correlate tot_number_workers Share_skco_opt_dig_brc, means 
	 reg tot_number_workers Share_skco_opt_dig_brc
	
     twoway (scatter tot_number_workers Share_skco_opt_dig_brc, xscale(range(0 1)) mcolor(gold))(lfit tot_number_workers Share_skco_opt_dig_brc, xscale(range(0 1)))
	 graph export "${graphs}ESCOskillsDIG_dummy_correlation_skco_optional_digital_skills_energy_jobs_all.pdf", replace
	 
	 ***
	 
	 spearman tot_number_workers Share_kno_ess_dig_brc, star(.05)
     correlate tot_number_workers Share_kno_ess_dig_brc, means 
	 reg tot_number_workers Share_kno_ess_dig_brc
	
     twoway (scatter tot_number_workers Share_kno_ess_dig_brc, xscale(range(0 1)) mcolor(gold))(lfit tot_number_workers Share_kno_ess_dig_brc, xscale(range(0 1)))
	 graph export "${graphs}ESCOskillsDIG_dummy_correlation_kno_essential_digital_skills_energy_jobs_all.pdf", replace
	 
	 
	 ***
	 
	 spearman tot_number_workers Share_kno_opt_dig_brc, star(.05)
     correlate tot_number_workers Share_kno_opt_dig_brc, means 
	 reg tot_number_workers Share_kno_opt_dig_brc
	
     twoway (scatter tot_number_workers Share_kno_opt_dig_brc, xscale(range(0 1)) mcolor(gold))(lfit tot_number_workers Share_kno_opt_dig_brc, xscale(range(0 1)))
	 graph export "${graphs}ESCOskillsDIG_dummy_correlation_kno_optional_digital_skills_energy_jobs_all.pdf", replace
	 
	 ***
	        

	 
	 
	
	 
***  20.3  Distribution of the shares of digital skills
***       in occupations needed for the energy transition 
	
	
	//   Distribution of shares for all the types of investment
	
	
	use "${data_prep}77_correlations_digital_skills_esco_dummy", clear
	
	***
	
	histogram Share_ess_dig_brc [freq=round(employment)], width(0.1) xscale(range(0 1)) scheme(s2color)
	
	graph export "${graphs}ESCOskillsDIG_dummy_distribution_essential_digital_skills_energy_jobs_all.pdf", replace
	
	***
	
	histogram Share_opt_dig_brc [freq=round(employment)], width(0.1) xscale(range(0 1)) scheme(s2color)
	
	graph export "${graphs}ESCOskillsDIG_dummy_distribution_optional_digital_skills_energy_jobs_all.pdf", replace
	
	***
	
	histogram Share_dig_brc [freq=round(employment)], width(0.1) xscale(range(0 1)) scheme(s2color)
	
	graph export "${graphs}ESCOskillsDIG_dummy_distribution_digital_skills_energy_jobs_all.pdf", replace
	
	***
	
	histogram Share_skco_dig_brc [freq=round(employment)], width(0.1) xscale(range(0 1)) scheme(s2color)
	
	graph export "${graphs}ESCOskillsDIG_dummy_distribution_skco_digital_skills_energy_jobs_all.pdf", replace
	
	***
	
	histogram Share_kno_dig_brc [freq=round(employment)], width(0.1) xscale(range(0 1)) scheme(s2color)
	
	graph export "${graphs}ESCOskillsDIG_dummy_distribution_kno_digital_skills_energy_jobs_all.pdf", replace
	
	***
	
	histogram Share_skco_ess_dig_brc [freq=round(employment)], width(0.1) xscale(range(0 1)) scheme(s2color)
	
	graph export "${graphs}ESCOskillsDIG_dummy_distribution_skco_essential_digital_skills_energy_jobs_all.pdf", replace
	
	***
	
	histogram Share_skco_opt_dig_brc [freq=round(employment)], width(0.1) xscale(range(0 1)) scheme(s2color)
	
	graph export "${graphs}ESCOskillsDIG_dummy_distribution_skco_optional_digital_skills_energy_jobs_all.pdf", replace
	
	***
	
	histogram Share_kno_ess_dig_brc [freq=round(employment)], width(0.1) xscale(range(0 1)) scheme(s2color)
	
	graph export "${graphs}ESCOskillsDIG_dummy_distribution_kno_essential_digital_skills_energy_jobs_all.pdf", replace
	
	***
	
	histogram Share_kno_opt_dig_brc [freq=round(employment)], width(0.1) xscale(range(0 1)) scheme(s2color)
	
	graph export "${graphs}ESCOskillsDIG_dummy_distribution_kno_optional_digital_skills_energy_jobs_all.pdf", replace
	
	***
	
	
	****************************************************************************


	 
	 
cap log close 
	
exit	
	
	
	