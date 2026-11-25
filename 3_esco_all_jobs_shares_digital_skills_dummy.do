/******************************************************************************* 
BEGIN HEADER

Author : Daniele Gasparini
Document Title: 3_esco_all_jobs_shares_digital_skills_dummy.do
DocuVersion: 1.0
Stata Version: 17.0
Date: 06.09.2023
Purpose: Analysis of all the occupations in the Netherlands
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




* 1. Merge the shares of ESCO digital skills by BRC2014 code (dummy variable)
 *    (from "${data_prep}74g_merged_digital_skills_shares_brc_dummy_p7")
 *    with the level of employment by BRC2014 code
 *    (from "${data_prep}98_employment_by_brc")
 *    via the BRC2014 code
*-------------------------------------------------------------------------------	
   
   
    use "${data_prep}74g_merged_digital_skills_shares_brc_dummy_p7", clear
	
	browse
	
	drop merge7 Share_ess_dig_isco Share_opt_dig_isco Share_dig_isco Share_skco_dig_isco Share_kno_dig_isco Share_skco_ess_dig_isco Share_skco_opt_dig_isco Share_kno_ess_dig_isco Share_kno_opt_dig_isco level_ISCO08 merge0 employment percentage_employment total_lev_occup merge2 label_ISCO08_crosswalk merge3 
	
	joinby BRC2014 using "${data_prep}98_employment_by_brc", update unmatched(both)
	
	
	qui compress
    save "${data_prep}106_all_occupations_shares_esco_digital_skills_employment_by_brc", replace
	


*   2. Analysis of all the occupations in the Dutch economy
 *-------------------------------------------------------------------------------
 
 *   2.1 Analysis of the shares of ESCO digital skills (dummy measure) 
 *       across all the occupations according to the BRC2014 classification
*-------------------------------------------------------------------------------

	
	use "${data_prep}106_all_occupations_shares_esco_digital_skills_employment_by_brc", clear
	
	****************************************************************************	

	*** Shares of essential digital skills (skills/competences + knowledge) 
	*** out of the overall essential ESCO skills 
	*** in all the occupations in the Netherlands
	
	generate intensity_essential_dig = Share_ess_dig_brc * employment
	generate intensity_non_essential_dig = (1 - Share_ess_dig_brc) * employment
	
	***  (a)  Comparison of shares (total = total employment)
	
	graph hbar (sum) intensity_essential_dig intensity_non_essential_dig, stack nofill scheme(s1color) legend(label(1 "Digital essential skills") label(2 "Non-digital essential skills") size(vsmall)) blabel(bar, position(inside) format(%9.2f) size(tiny) color(white))
	graph export "${graphs}ESCOskillsDIG_dummy_share_essential_digital_skills_all_jobs_actual.pdf", replace
	
	
	***  (b) Comparison of shares 
    ***     (total = 100%)
	
	graph hbar (sum) intensity_essential_dig intensity_non_essential_dig, stack percent nofill scheme(s1color) legend(label(1 "Digital essential skills") label(2 "Non-digital essential skills") size(vsmall)) blabel(bar, position(inside) format(%9.2f) size(tiny) color(white))
	graph export "${graphs}ESCOskillsDIG_dummy_share_essential_digital_skills_all_jobs_100.pdf", replace
	
	

	****************************************************************************
	
	*** Shares of optional digital skills (skills/competences + knowledge) 
	*** out of the overall optional ESCO skills 
	*** in all the occupations in the Netherlands
	
	generate intensity_optional_dig = Share_opt_dig_brc * employment
	generate intensity_non_optional_dig = (1 - Share_opt_dig_brc) * employment
	
	***  (a)  Comparison of shares (total = actual labour demand increase due to 
    ***       investment in the energy transition)
	
	graph hbar (sum) intensity_optional_dig intensity_non_optional_dig, stack nofill scheme(s1color) legend(label(1 "Digital optional skills") label(2 "Non-digital optional skills") size(vsmall)) blabel(bar, position(inside) format(%9.2f) size(tiny) color(white))
	graph export "${graphs}ESCOskillsDIG_dummy_share_optional_digital_skills_all_jobs_actual.pdf", replace
	
	***  (b) Comparison of shares 
    ***     (total = 100%)
	
	graph hbar (sum) intensity_optional_dig intensity_non_optional_dig, stack percent nofill scheme(s1color) legend(label(1 "Digital optional skills") label(2 "Non-digital optional skills") size(vsmall)) blabel(bar, position(inside) format(%9.2f) size(tiny) color(white))
	graph export "${graphs}ESCOskillsDIG_dummy_share_optional_digital_skills_all_jobs_100.pdf", replace
	

	****************************************************************************
	
	*** Shares of digital skills (skills/competences + knowledge) 
	*** out of the overall ESCO skills 
	*** in all the occupations in the Netherlands
	
	
	generate intensity_dig = Share_dig_brc * employment
	generate intensity_non_dig = (1 - Share_dig_brc ) * employment
	
	***  (a)  Comparison of shares (total = total employment)
	
	graph hbar (sum) intensity_dig intensity_non_dig, stack nofill scheme(s1color) legend(label(1 "Digital skills") label(2 "Other") size(vsmall)) blabel(bar, position(inside) format(%9.2f) size(tiny) color(white))
	graph export "${graphs}ESCOskillsDIG_dummy_share_digital_skills_all_jobs_actual.pdf", replace
	
	***  (b) Comparison of shares 
    ***     (total = 100%)
	
	graph hbar (sum) intensity_dig intensity_non_dig, stack percent nofill scheme(s1color) legend(label(1 "Digital skills") label(2 "Other") size(vsmall)) blabel(bar, position(inside) format(%9.2f) size(tiny) color(white))
	graph export "${graphs}ESCOskillsDIG_dummy_share_digital_skills_all_jobs_100.pdf", replace
	

	****************************************************************************
	
	*** Shares of digital skills/competences
	*** out of the overall ESCO skills/competences 
	*** in all the occupations in the Netherlands
	
	
	generate intensity_dig_sk_comp = Share_skco_dig_brc * employment
	generate intensity_non_dig_sk_comp = (1 - Share_skco_dig_brc ) * employment
	
	***  (a)  Comparison of shares (total = total employment)
	
	graph hbar (sum) intensity_dig_sk_comp intensity_non_dig_sk_comp, stack nofill scheme(s1color) legend(label(1 "Digital skills & competences") label(2 "Non-digital skills & competences") size(vsmall)) blabel(bar, position(inside) format(%9.2f) size(tiny) color(white))
	graph export "${graphs}ESCOskillsDIG_dummy_share_digital_skco_all_jobs_actual.pdf", replace
	
	***  (b) Comparison of shares 
    ***     (total = 100%)
	
	graph hbar (sum) intensity_dig_sk_comp intensity_non_dig_sk_comp, stack percent nofill scheme(s1color) legend(label(1 "Digital skills & competences") label(2 "Non-digital skills & competences") size(vsmall)) blabel(bar, position(inside) format(%9.2f) size(tiny) color(white))
	graph export "${graphs}ESCOskillsDIG_dummy_share_digital_skco_all_jobs_100.pdf", replace
	

	***************************************************************************
	 
	*** Shares of digital knowledge concepts
	*** out of the overall ESCO knowledge concepts 
	*** in all the occupations in the Netherlands
	
	generate intensity_dig_know = Share_kno_dig_brc * employment
	generate intensity_non_dig_know = (1 - Share_kno_dig_brc ) * employment
	
	***  (a)  Comparison of shares (total = total employment)
	
	graph hbar (sum) intensity_dig_know intensity_non_dig_know, stack nofill scheme(s1color) legend(label(1 "Digital knowledge concepts") label(2 "Non-digital knowledge concepts") size(vsmall)) blabel(bar, position(inside) format(%9.2f) size(tiny) color(white))
	graph export "${graphs}ESCOskillsDIG_dummy_share_digital_kno_all_jobs_actual.pdf", replace
	
	***  (b) Comparison of shares 
    ***     (total = 100%)
	
	graph hbar (sum) intensity_dig_know intensity_non_dig_know, stack percent nofill scheme(s1color) legend(label(1 "Digital knowledge concepts") label(2 "Non-digital knowledge concepts") size(vsmall)) blabel(bar, position(inside) format(%9.2f) size(tiny) color(white))
	graph export "${graphs}ESCOskillsDIG_dummy_share_digital_kno_all_jobs_100.pdf", replace
	
	
	****************************************************************************
	
	*** Shares of digital essential skills/competences
	*** out of the overall ESCO essential skills/competences 
	*** in all the occupations in the Netherlands
	
	
	generate intensity_dig_ess_sk_comp = Share_skco_ess_dig_brc * employment
	generate intensity_non_dig_ess_sk_comp = (1 - Share_skco_ess_dig_brc ) * employment
	
	***  (a)  Comparison of shares (total = total employment)
	
	graph hbar (sum) intensity_dig_ess_sk_comp intensity_non_dig_ess_sk_comp, stack nofill scheme(s1color) legend(label(1 "Digital essential skills & competences") label(2 "Non-digital essential skills & competences") size(vsmall)) blabel(bar, position(inside) format(%9.2f) size(tiny) color(white))
	graph export "${graphs}ESCOskillsDIG_dummy_share_digital_essential_skco_all_jobs_actual.pdf", replace
	
	***  (b) Comparison of shares 
    ***     (total = 100%)
	
	graph hbar (sum) intensity_dig_ess_sk_comp intensity_non_dig_ess_sk_comp, stack percent nofill scheme(s1color) legend(label(1 "Digital essential skills & competences") label(2 "Non-digital essential skills & competences") size(vsmall)) blabel(bar, position(inside) format(%9.2f) size(tiny) color(white))
	graph export "${graphs}ESCOskillsDIG_dummy_share_digital_essential_skco_all_jobs_100.pdf", replace

	
	****************************************************************************
	
	*** Shares of digital optional skills/competences
	*** out of the overall ESCO optional skills/competences 
	*** in all the occupations in the Netherlands
	
	
	generate intensity_dig_opt_sk_comp = Share_skco_opt_dig_brc * employment
	generate intensity_non_dig_opt_sk_comp = (1 - Share_skco_opt_dig_brc ) * employment
	
	***  (a)  Comparison of shares (total = total employment)
	
	graph hbar (sum) intensity_dig_opt_sk_comp intensity_non_dig_opt_sk_comp, stack nofill scheme(s1color) blabel(bar, position(inside) format(%9.2f) size(tiny) color(white))
	graph export "${graphs}ESCOskillsDIG_dummy_share_digital_optional_skco_all_jobs_actual.pdf", replace
	
	***  (b) Comparison of shares 
    ***     (total = 100%)
	
	graph hbar (sum) intensity_dig_opt_sk_comp intensity_non_dig_opt_sk_comp, stack percent nofill scheme(s1color) legend(label(1 "Digital optional skills & competences") label(2 "Non-digital optional skills & competences") size(vsmall)) blabel(bar, position(inside) format(%9.2f) size(tiny) color(white))
	graph export "${graphs}ESCOskillsDIG_dummy_share_digital_optional_skco_all_jobs_100.pdf", replace
	
	
	***************************************************************************
	 
	*** Shares of digital essential knowledge concepts
	*** out of the overall ESCO essential knowledge concepts 
	*** in all the occupations in the Netherlands
	
	
	generate intensity_dig_ess_know =  Share_kno_ess_dig_brc * employment
	generate intensity_non_dig_ess_know = (1 - Share_kno_ess_dig_brc) * employment
	
	***  (a)  Comparison of shares (total = total employment)
	
	graph hbar (sum) intensity_dig_ess_know intensity_non_dig_ess_know, stack nofill scheme(s1color) legend(label(1 "Digital essential knowledge concepts") label(2 "Non-digital essential knowledge concepts") size(vsmall)) blabel(bar, position(inside) format(%9.2f) size(tiny) color(white))
	graph export "${graphs}ESCOskillsDIG_dummy_share_digital_essential_kno_all_jobs_actual.pdf", replace
	
	***  (b) Comparison of shares 
    ***     (total = 100%)
	
	graph hbar (sum) intensity_dig_ess_know intensity_non_dig_ess_know, stack percent nofill scheme(s1color) legend(label(1 "Digital essential knowledge concepts") label(2 "Non-digital essential knowledge concepts") size(vsmall)) blabel(bar, position(inside) format(%9.2f) size(tiny) color(white))
	graph export "${graphs}ESCOskillsDIG_dummy_share_digital_essential_kno_all_jobs_100.pdf", replace
	
	
    ****************************************************************************
	 
	*** Shares of digital optional knowledge concepts
	*** out of the overall ESCO optional knowledge concepts 
	*** in all the occupations in the Netherlands

	generate intensity_dig_opt_know =  Share_kno_opt_dig_brc * employment
	generate intensity_non_dig_opt_know = (1 -  Share_kno_opt_dig_brc ) * employment
	
	***  (a)  Comparison of shares (total = total employment)
	
	graph hbar (sum) intensity_dig_opt_know intensity_non_dig_opt_know, stack nofill scheme(s1color) legend(label(1 "Digital optional knowledge concepts") label(2 "Non-digital optional knowledge concepts") size(vsmall)) blabel(bar, position(inside) format(%9.2f) size(tiny) color(white))
	graph export "${graphs}ESCOskillsDIG_dummy_share_digital_essential_kno_all_jobs_actual.pdf", replace
	
	***  (b) Comparison of shares 
    ***     (total = 100%)
	
	graph hbar (sum) intensity_dig_opt_know intensity_non_dig_opt_know, stack percent nofill scheme(s1color) legend(label(1 "Digital optional knowledge concepts") label(2 "Non-digital optional knowledge concepts") size(vsmall)) blabel(bar, position(inside) format(%9.2f) size(tiny) color(white))
	graph export "${graphs}ESCOskillsDIG_dummy_share_digital_essential_kno_all_jobs_100.pdf", replace
	
	
	

    ****************************************************************************
	
***  2.2  Correlation between shares of digital skills and
***       the number of people employed

     
	 use "${data_prep}106_all_occupations_shares_esco_digital_skills_employment_by_brc", clear
	 
	 ***
	
	 spearman employment Share_ess_dig_brc, star(.05)
     correlate employment Share_ess_dig_brc, means 
	 reg employment Share_ess_dig_brc
	
     twoway (scatter employment Share_ess_dig_brc, xscale(range(0 1)) mcolor(gold))(lfit employment Share_ess_dig_brc, xscale(range(0 1)))
	 graph export "${graphs}ESCOskillsDIG_dummy_correlation_essential_digital_skills_all_jobs_all.pdf", replace
	 
	
	 ***
	 
	 spearman employment Share_opt_dig_brc, star(.05)
     correlate employment Share_opt_dig_brc, means 
	 reg employment Share_opt_dig_brc
	
     twoway (scatter employment Share_opt_dig_brc, xscale(range(0 1)) mcolor(gold))(lfit employment Share_opt_dig_brc, xscale(range(0 1)))
	 graph export "${graphs}ESCOskillsDIG_dummy_correlation_optional_digital_skills_all_jobs_all.pdf", replace
	 
	
	 ***
	 
	 spearman employment Share_dig_brc, star(.05)
     correlate employment Share_dig_brc, means 
	 reg employment Share_dig_brc
	
     twoway (scatter employment Share_dig_brc, xscale(range(0 1)) mcolor(gold))(lfit employment Share_dig_brc, xscale(range(0 1)))
	 graph export "${graphs}ESCOskillsDIG_dummy_correlation_digital_skills_all_jobs_all.pdf", replace
	 
	
	 ***
	 
	 spearman  employment Share_skco_dig_brc, star(.05)
     correlate employment  Share_skco_dig_brc, means 
	 reg employment  Share_skco_dig_brc
	
     twoway (scatter employment Share_skco_dig_brc, xscale(range(0 1)) mcolor(gold))(lfit employment Share_skco_dig_brc, xscale(range(0 1)))
	 graph export "${graphs}ESCOskillsDIG_dummy_correlation_skco_digital_skills_all_jobs_all.pdf", replace
	 
	 ***
	 
	 spearman  employment Share_kno_dig_brc, star(.05)
     correlate  employment Share_kno_dig_brc, means 
	 reg employment Share_kno_dig_brc
	
     twoway (scatter employment Share_kno_dig_brc, xscale(range(0 1)) mcolor(gold))(lfit employment Share_kno_dig_brc, xscale(range(0 1)))
	 graph export "${graphs}ESCOskillsDIG_dummy_correlation_kno_digital_skills_all_jobs_all.pdf", replace
	   
	 
	 ***
	 
	 spearman  employment Share_skco_ess_dig_brc, star(.05)
     correlate employment Share_skco_ess_dig_brc, means 
	 reg employment Share_skco_ess_dig_brc
	
     twoway (scatter employment Share_skco_ess_dig_brc, xscale(range(0 1)) mcolor(gold))(lfit employment Share_skco_ess_dig_brc, xscale(range(0 1)))
	 graph export "${graphs}ESCOskillsDIG_dummy_correlation_skco_essential_digital_skills_all_jobs_all.pdf", replace
	 
	 
	 ***
	 
	 spearman employment Share_skco_opt_dig_brc, star(.05)
     correlate employment Share_skco_opt_dig_brc, means 
	 reg employment Share_skco_opt_dig_brc
	
     twoway (scatter employment Share_skco_opt_dig_brc, xscale(range(0 1)) mcolor(gold))(lfit employment Share_skco_opt_dig_brc, xscale(range(0 1)))
	 graph export "${graphs}ESCOskillsDIG_dummy_correlation_skco_optional_digital_skills_all_jobs_all.pdf", replace
	 
	 ***
	 
	 spearman employment Share_kno_ess_dig_brc, star(.05)
     correlate employment Share_kno_ess_dig_brc, means 
	 reg employment Share_kno_ess_dig_brc
	
     twoway (scatter employment Share_kno_ess_dig_brc, xscale(range(0 1)) mcolor(gold))(lfit employment Share_kno_ess_dig_brc, xscale(range(0 1)))
	 graph export "${graphs}ESCOskillsDIG_dummy_correlation_kno_essential_digital_skills_all_jobs_all.pdf", replace
	 
	 
	 ***
	 
	 spearman employment Share_kno_opt_dig_brc, star(.05)
     correlate employment Share_kno_opt_dig_brc, means 
	 reg employment Share_kno_opt_dig_brc
	
     twoway (scatter employment Share_kno_opt_dig_brc, xscale(range(0 1)) mcolor(gold))(lfit employment Share_kno_opt_dig_brc, xscale(range(0 1)))
	 graph export "${graphs}ESCOskillsDIG_dummy_correlation_kno_optional_digital_skills_all_jobs_all.pdf", replace
	 
	 ***
	    
	 
***  2.3  Distribution of the shares of digital skills
***       in all the occupations in the Netherlands
	

	
	
	use "${data_prep}106_all_occupations_shares_esco_digital_skills_employment_by_brc", clear
	
	***
	
	histogram Share_ess_dig_brc [freq=round(employment)], width(0.1) xscale(range(0 1)) scheme(s2color)
	
	graph export "${graphs}ESCOskillsDIG_dummy_distribution_essential_digital_skills_all_jobs_all.pdf", replace
	
	***
	
	histogram Share_opt_dig_brc [freq=round(employment)], width(0.1) xscale(range(0 1)) scheme(s2color)
	
	graph export "${graphs}ESCOskillsDIG_dummy_distribution_optional_digital_skills_all_jobs_all.pdf", replace
	
	***
	
	histogram Share_dig_brc [freq=round(employment)], width(0.1) xscale(range(0 1)) scheme(s2color)
	
	graph export "${graphs}ESCOskillsDIG_dummy_distribution_digital_skills_all_jobs_all.pdf", replace
	
	***
	
	histogram Share_skco_dig_brc [freq=round(employment)], width(0.1) xscale(range(0 1)) scheme(s2color)
	
	graph export "${graphs}ESCOskillsDIG_dummy_distribution_skco_digital_skills_all_jobs_all.pdf", replace
	
	***
	
	histogram Share_kno_dig_brc [freq=round(employment)], width(0.1) xscale(range(0 1)) scheme(s2color)
	
	graph export "${graphs}ESCOskillsDIG_dummy_distribution_kno_digital_skills_all_jobs_all.pdf", replace
	
	***
	
	histogram Share_skco_ess_dig_brc [freq=round(employment)], width(0.1) xscale(range(0 1)) scheme(s2color)
	
	graph export "${graphs}ESCOskillsDIG_dummy_distribution_skco_essential_digital_skills_all_jobs_all.pdf", replace
	
	***
	
	histogram Share_skco_opt_dig_brc [freq=round(employment)], width(0.1) xscale(range(0 1)) scheme(s2color)
	
	graph export "${graphs}ESCOskillsDIG_dummy_distribution_skco_optional_digital_skills_all_jobs_all.pdf", replace
	
	***
	
	histogram Share_kno_ess_dig_brc [freq=round(employment)], width(0.1) xscale(range(0 1)) scheme(s2color)
	
	graph export "${graphs}ESCOskillsDIG_dummy_distribution_kno_essential_digital_skills_all_jobs_all.pdf", replace
	
	***
	
	histogram Share_kno_opt_dig_brc [freq=round(employment)], width(0.1) xscale(range(0 1)) scheme(s2color)
	
	graph export "${graphs}ESCOskillsDIG_dummy_distribution_kno_optional_digital_skills_all_jobs_all.pdf", replace
	
	***
	
	
	****************************************************************************


	 
	 
cap log close 
	
exit	
	
	
	