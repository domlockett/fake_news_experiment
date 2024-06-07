clear

*cd "/Users/bnyhan/Dropbox/GuessNyhanReifler/DART0023/Fall 2018 materials/MICH0034 redux/"
*cd "/Users/jasonreifler/Dropbox/GuessNyhanReifler/DART0023/Fall 2018 materials/MICH0034 redux/"
cd "/Users/benlyons/Dropbox/GuessNyhanReifler/DART0023/Fall 2018 materials/MICH0034 redux/"

/*get Pulse data ready*/ 


clear
import delimited using "../../Pulse data/pulse_vars_post18_outcomes.csv"

su

foreach var of varlist dec* di* {
capture replace `var'="" if `var'=="NA" | `var'=="NaN"
destring `var', replace
}

save "pulse_vars_post18.dta", replace


/*OPEN AND CODE DATA*/

use "MICH0034_OUTPUT_redux.DTA", clear

**add pulse**
merge 1:1 caseid using "pulse_vars_post18.dta"
tab _merge
gen nopulse=(_merge==1)
tab nopulse

drop _merge

tab decile_all

/*demos*/

gen female = gender
recode female 2=1 1=0
tab female gender, missing

gen nonwhite = race
recode nonwhite 2=1 3=1 4=1 5=1 6=1 7=1 8=1 1=0
tab race nonwhite, missing

gen college = educ
recode college 1=0 2=0 3=0 4=0 5=1 6=1
tab college educ, missing

gen age = 2018-birthyr 
gen agecat=age
/* -age groups (18-29, 30-44, 45-59, 60+)*/
replace agecat=1 if age>17
replace agecat=2 if age>29
replace agecat=3 if age>44
replace agecat=4 if age>59
replace agecat=. if age==.
tab agecat age, missing

gen agecat1=agecat
gen agecat2=agecat
gen agecat3=agecat
gen agecat4=agecat

recode agecat1 1=1 2=0 3=0 4=0
recode agecat2 2=1 1=0 3=0 4=0
recode agecat3 3=1 2=0 1=0 4=0
recode agecat4 4=1 2=0 3=0 1=0

/*W1 IVs & moderators*/

gen ideology=ideo /*lower values = more left*/

gen dem = pid3
recode dem 1=1 else=0
gen repub = pid3
recode repub 2=1 else=0
gen ind3pt = pid3 
recode ind3pt 3=1 4=1 5=1 else=0 /*ind, other, not sure*/

gen dem_leaners = pid7
recode dem_leaners 1=1 2=1 3=1 else=0
gen repub_leaners = pid7
recode repub_leaners 5=1 6=1 7=1 else=0
gen independents = pid7 
recode independents 4=1 8=1 else=0 /*ind, not sure*/

gen pid3_lean=.
replace pid3_lean=1 if dem_leaners==1
replace pid3_lean=2 if independents==1
replace pid3_lean=3 if repub_leaners==1

gen polint = pol_interest
recode polint 1=5 2=4 3=3 4=2 5=1 /*recode very interest high*/
tab polint pol_interest

gen FT_trump = pol_therm_trump
gen FT_rep = pol_therm_rep
gen FT_dem = pol_therm_dem
gen FT_media = pol_therm_media

**affective polarization w1**

gen dem_less_repw1 = FT_dem - FT_rep
gen rep_less_demw1 = FT_rep - FT_dem

gen dem_less_rep_w1 = dem_less_repw1 /*Cross with party*/
gen rep_less_dem_w1 = rep_less_demw1 
replace dem_less_rep_w1 = 0 if repub==1
replace rep_less_dem_w1 = 0 if dem==1

gen affect_mergedw1 = dem_less_rep_w1 + rep_less_dem_w1 

**with leaners 

gen dem_less_rep_w1x = dem_less_repw1 /*Cross with party with leaners*/
gen rep_less_dem_w1x = rep_less_demw1 
replace dem_less_rep_w1x = 0 if repub_leaners==1
replace rep_less_dem_w1x = 0 if dem_leaners==1

gen affect_merged_leanersw1 = dem_less_rep_w1x + rep_less_dem_w1x 

gen polknow = 0
replace polknow=polknow+1 if senator_term==3
replace polknow=polknow+1 if pres_term_limit ==2
replace polknow=polknow+1 if senator_num ==2
replace polknow=polknow+1 if uk_pm ==4
replace polknow=polknow+1 if rep_term==1

tab polknow, missing

gen CRT1 = 0
replace CRT1=CRT1+1 if crt_1a ==1
replace CRT1=CRT1+1 if crt_1b ==3
replace CRT1=CRT1+1 if crt_1c ==3

tab CRT1, missing

gen CRT2 = 0
replace CRT2=CRT2+1 if crt_2a ==2
replace CRT2=CRT2+1 if crt_2b ==2
replace CRT2=CRT2+1 if crt_2c ==2
replace CRT2=CRT2+1 if crt_2d ==2

tab CRT2, missing

alpha CRT1 CRT2 /* alpha = .51 */

gen crt1a = crt_1a
gen crt1b = crt_1b
gen crt1c = crt_1c

recode crt1a 1=1 else=0
recode crt1b 3=1 else=0
recode crt1c 3=1 else=0

alpha crt1a crt1b crt1c /* alpha = .44 */

gen crt2a = crt_2a
gen crt2b = crt_2b
gen crt2c = crt_2c
gen crt2d = crt_2d

recode crt2a 2=1 else=0
recode crt2b 2=1 else=0
recode crt2c 2=1 else=0
recode crt2d 2=1 else=0

alpha crt2a crt2b crt2c crt2d /* alpha = .55 */

alpha crt1a crt1b crt1c crt2a crt2b crt2c crt2d /* alpha = .64 */

gen crt_add = CRT1 + CRT2 
egen crt_average  = rowmean(crt1a  crt1b  crt1c  crt2a  crt2b  crt2c  crt2d)

*tercile split
gen crt_terc=.
replace crt_terc=1 if crt_average<.15
replace crt_terc=2 if crt_av>.143 & crt_av<.57
replace crt_terc=3 if crt_av>.57

gen massmedia_trust = media_trust /* recode high trust high */
recode massmedia_trust 1=4 2=3 3=2 4=1
tab massmedia_trust media_trust, missing

gen fbtrust = fb_trust /* recode high trust high */
recode fbtrust 1=4 2=3 3=2 4=1
tab fbtrust fb_trust, missing

gen fb_use = fb_freq
recode fb_use 1=9 2=8 3=7 4=6 5=5 6=4 7=3 8=2 9=1 /* recode high use high */
tab fb_use fb_freq, missing

gen fb_pol_use = fb_political_freq
recode fb_pol_use 1=9 2=8 3=7 4=6 5=5 6=4 7=3 8=2 9=1 /* recode high use high */
tab fb_pol_use fb_political_freq, missing

gen fb_pol_share = fb_share_freq 
recode fb_pol_share 1=9 2=8 3=7 4=6 5=5 6=4 7=3 8=2 9=1 /* recode high use high */
tab fb_pol_share fb_share_freq, missing

gen consp1=conspiracy_1
gen consp2=conspiracy_2
gen consp3=conspiracy_3
recode consp1 1=5 2=4 3=3 4=2 5=1 /* recode high consp high */
recode consp2 1=5 2=4 3=3 4=2 5=1
recode consp3 1=5 2=4 3=3 4=2 5=1

alpha consp1 consp2 consp3 /* alpha = .74 */, item 

egen conspiracy_mean  = rowmean(consp1  consp2  consp3)


/*W1 DVs*/

**tpp**
gen confidence_self = confidence_fake 
gen confidence_americans = confidence_fake_us

recode confidence_self 1=4 2=3 3=2 4=1 /* recode confidence high */
recode confidence_americans 1=4 2=3 3=2 4=1

gen tpp = confidence_self - confidence_americans


**postelection headline codes
*pro-D hyper 1 = donald_trump_caught_png, 2 = franklin_graham_png
*pro-D fake 3 = vp_mike_pence_png 4 = vice_president_pence_png
*proR hyper 5 = soros_money_behind_png, 6 = kavanaugh_accuser_png
*proR fake 7 = fbi_agent_who_png, 8 = lisa_page_png
*pro d real 9 = a_series_of_suspicious_png, 10 = a_border_patrol_png, 11 = detention_of_migrant__png 12 = and_now_its_the_tallest_png
*proR real 13 = google_employees_png, 14 = feds_said_alleged_png, 15 = small_busisness_optimism_ , 16 = economy_adds_more_png

/*
	donald_trump_caught_png |        195        6.16        6.16
		franklin_graham_png |        184        5.81       11.97
           vp_mike_pence_png |        208        6.57       18.53
    vice_president_pence_png |        193        6.09       24.63
      soros_money_behind_png |        217        6.85       31.48
       kavanaugh_accuser_png |        206        6.50       37.99
           fbi_agent_who_png |        213        6.73       44.71
               lisa_page_png |        173        5.46       50.17
  a_series_of_suspicious_png |        196        6.19       56.36
         a_border_patrol_png |        202        6.38       62.74
   detention_of_migrant__png |        195        6.16       68.90
 and_now_its_the_tallest_png |        224        7.07       75.97
        google_employees_png |        197        6.22       82.19
       feds_said_alleged_png |        179        5.65       87.84
small_busisness_optimism_png |        221        6.98       94.82
       economy_adds_more_png |        164        5.18      100.00
*/

gen accuracy1 = headline_accuracy_1
gen accuracy2 = headline_accuracy_2
gen accuracy3 = headline_accuracy_3
gen accuracy4 = headline_accuracy_4
gen accuracy5 = headline_accuracy_5
gen accuracy6 = headline_accuracy_6
gen accuracy7 = headline_accuracy_7
gen accuracy8 = headline_accuracy_8

gen articlename1 = headline_1_article_name
gen articlename2 = headline_2_article_name
gen articlename3 = headline_3_article_name
gen articlename4 = headline_4_article_name
gen articlename5 = headline_5_article_name
gen articlename6 = headline_6_article_name
gen articlename7 = headline_7_article_name
gen articlename8 = headline_8_article_name

gen accuracy_donald_trump_caught = 0
gen accuracy_franklin_graham = 0
gen accuracy_vp_mike_pence = 0
gen accuracy_vice_president_pence = 0
gen accuracy_soros_money_behind = 0
gen accuracy_kavanaugh_accuser = 0
gen accuracy_fbi_agent_who = 0
gen accuracy_lisa_page = 0
gen accuracy_a_series1 = 0
gen accuracy_a_border_patrol = 0
gen accuracy_detention_of_migrant = 0
gen accuracy_and_now1 = 0
gen accuracy_google_employees = 0
gen accuracy_feds_said_alleged = 0
gen accuracy_small_busisness_opt = 0
gen accuracy_economy_adds_more = 0

**accuracy**

forval i=1/8 {
replace accuracy_donald_trump_caught=accuracy`i' if articlename`i'==1
}
recode accuracy_donald_trump_caught 0=.

forval i=1/8 {
replace accuracy_franklin_graham=accuracy`i' if articlename`i'==2
}
recode accuracy_franklin_graham 0=.

forval i=1/8 {
replace accuracy_vp_mike_pence=accuracy`i' if articlename`i'==3
}
recode accuracy_vp_mike_pence 0=.

forval i=1/8 {
replace accuracy_vice_president_pence=accuracy`i' if articlename`i'==4
}
recode accuracy_vice_president_pence 0=.

forval i=1/8 {
replace accuracy_soros_money_behind=accuracy`i' if articlename`i'==5
}
recode accuracy_soros_money_behind 0=.

forval i=1/8 {
replace accuracy_kavanaugh_accuser=accuracy`i' if articlename`i'==6
}
recode accuracy_kavanaugh_accuser 0=.

forval i=1/8 {
replace accuracy_fbi_agent_who=accuracy`i' if articlename`i'==7
}
recode accuracy_fbi_agent_who 0=.

forval i=1/8 {
replace accuracy_lisa_page=accuracy`i' if articlename`i'==8
}
recode accuracy_lisa_page 0=.

forval i=1/8 {
replace accuracy_a_series1=accuracy`i' if articlename`i'==9
}
recode accuracy_a_series1 0=.

forval i=1/8 {
replace accuracy_a_border_patrol=accuracy`i' if articlename`i'==10
}
recode accuracy_a_border_patrol 0=.

forval i=1/8 {
replace accuracy_detention_of_migrant=accuracy`i' if articlename`i'==11
}
recode accuracy_detention_of_migrant 0=.

forval i=1/8 {
replace accuracy_and_now1=accuracy`i' if articlename`i'==12
}
recode accuracy_and_now1 0=.


forval i=1/8 {
replace accuracy_google_employees=accuracy`i' if articlename`i'==13
}
recode accuracy_google_employees 0=.

forval i=1/8 {
replace accuracy_feds_said_alleged=accuracy`i' if articlename`i'==14
}
recode accuracy_feds_said_alleged 0=.

forval i=1/8 {
replace accuracy_small_busisness_opt=accuracy`i' if articlename`i'==15
}
recode accuracy_small_busisness_opt 0=.

forval i=1/8 {
replace accuracy_economy_adds_more=accuracy`i' if articlename`i'==16
}
recode accuracy_economy_adds_more 0=.

**fake mean
egen accuracy_fake_mean = rowmean(accuracy_vp_mike_pence accuracy_vice_president_pence accuracy_fbi_agent_who accuracy_lisa_page)
**real mean
egen accuracy_real_mean = rowmean(accuracy_a_series1 accuracy_a_border_patrol accuracy_detention_of_migrant accuracy_and_now1 accuracy_google_employees accuracy_feds_said_alleged accuracy_small_busisness_opt accuracy_economy_adds_more)
**hyper mean 
egen accuracy_hyper_mean = rowmean(accuracy_donald_trump_caught accuracy_franklin_graham accuracy_soros_money_behind accuracy_kavanaugh_accuser) 
**all mean
egen accuracy_all_mean = rowmean(accuracy_vp_mike_pence accuracy_vice_president_pence accuracy_fbi_agent_who accuracy_lisa_page accuracy_a_series1 accuracy_a_border_patrol accuracy_detention_of_migrant accuracy_and_now1 accuracy_google_employees accuracy_feds_said_alleged accuracy_small_busisness_opt accuracy_economy_adds_more accuracy_donald_trump_caught accuracy_franklin_graham accuracy_soros_money_behind accuracy_kavanaugh_accuser) 

**mean_acc_diff 
gen mean_acc_diff = accuracy_real_mean - accuracy_fake_mean


**sharing

gen share1 = headline_share_1
gen share2 = headline_share_2
gen share3 = headline_share_3
gen share4 = headline_share_4
gen share5 = headline_share_5
gen share6 = headline_share_6
gen share7 = headline_share_7
gen share8 = headline_share_8


gen share_donald_trump_caught = 0
gen share_franklin_graham = 0
gen share_vp_mike_pence = 0
gen share_vice_president_pence = 0
gen share_soros_money_behind = 0
gen share_kavanaugh_accuser = 0
gen share_fbi_agent_who = 0
gen share_lisa_page = 0
gen share_a_series_of_suspicious = 0
gen share_a_border_patrol = 0
gen share_detention_of_migrant = 0
gen share_and_now1 = 0
gen share_google_employees = 0
gen share_feds_said_alleged = 0
gen share_small_busisness_opt = 0
gen share_economy_adds_more = 0

**share**

forval i=1/8 {
replace share_donald_trump_caught=share`i' if articlename`i'==1
}
recode share_donald_trump_caught 0=.

forval i=1/8 {
replace share_franklin_graham=share`i' if articlename`i'==2
}
recode share_franklin_graham 0=.

forval i=1/8 {
replace share_vp_mike_pence=share`i' if articlename`i'==3
}
recode share_vp_mike_pence 0=.

forval i=1/8 {
replace share_vice_president_pence=share`i' if articlename`i'==4
}
recode share_vice_president_pence 0=.

forval i=1/8 {
replace share_soros_money_behind=share`i' if articlename`i'==5
}
recode share_soros_money_behind 0=.

forval i=1/8 {
replace share_kavanaugh_accuser=share`i' if articlename`i'==6
}
recode share_kavanaugh_accuser 0=.

forval i=1/8 {
replace share_fbi_agent_who=share`i' if articlename`i'==7
}
recode share_fbi_agent_who 0=.

forval i=1/8 {
replace share_lisa_page=share`i' if articlename`i'==8
}
recode share_lisa_page 0=.

forval i=1/8 {
replace share_a_series_of_suspicious=share`i' if articlename`i'==9
}
recode share_a_series_of_suspicious 0=.

forval i=1/8 {
replace share_a_border_patrol=share`i' if articlename`i'==10
}
recode share_a_border_patrol 0=.

forval i=1/8 {
replace share_detention_of_migrant=share`i' if articlename`i'==11
}
recode share_detention_of_migrant 0=.

forval i=1/8 {
replace share_and_now1=share`i' if articlename`i'==12
}
recode share_and_now1 0=.


forval i=1/8 {
replace share_google_employees=share`i' if articlename`i'==13
}
recode share_google_employees 0=.

forval i=1/8 {
replace share_feds_said_alleged=share`i' if articlename`i'==14
}
recode share_feds_said_alleged 0=.

forval i=1/8 {
replace share_small_busisness_opt=share`i' if articlename`i'==15
}
recode share_small_busisness_opt 0=.

forval i=1/8 {
replace share_economy_adds_more=share`i' if articlename`i'==16
}
recode share_economy_adds_more 0=.

**fake mean
egen share_fake_mean = rowmean(share_vp_mike_pence share_vice_president_pence share_fbi_agent_who share_lisa_page)
**real mean
egen share_real_mean = rowmean(share_a_series_of_suspicious share_a_border_patrol share_detention_of_migrant share_and_now1 share_google_employees share_feds_said_alleged share_small_busisness_opt share_economy_adds_more)
**hyper mean 
egen share_hyper_mean = rowmean(share_donald_trump_caught share_franklin_graham share_soros_money_behind share_kavanaugh_accuser) 
**all mean
egen share_all_mean = rowmean(share_vp_mike_pence share_vice_president_pence share_fbi_agent_who share_lisa_page share_a_series_of_suspicious share_a_border_patrol share_detention_of_migrant share_and_now1 share_google_employees share_feds_said_alleged share_small_busisness_opt share_economy_adds_more share_donald_trump_caught share_franklin_graham share_soros_money_behind share_kavanaugh_accuser) 


**mean_share_diff 
gen mean_share_diff = share_real_mean - share_fake_mean

/*W2 IVs & moderators*/

**treatment** UPDATE WITH TWEETS

gen tweet_treat = tweet_treat_w2
gen tweet4 = tweet_treat
gen tweet8= tweet_treat
gen tweetcorrect = tweet_treat
gen tweetcontrol = tweet_treat


recode tweet4 1=1 else=0
recode tweet8 2=1 else=0
recode tweetcorrect 3=1 else=0
recode tweetcontrol 4=1 else=0

*gen congenial_fn=.
*replace congenial_fn=0 if repub_leaner==1 | dem_leaner==1
*replace congenial_fn=1 if (proD_fake==1 & dem_leaner==1) | (proR_fake==1 & repub_leaner==1)

*gen uncongenial_fn=.
*replace uncongenial_fn=0 if repub_leaner==1 | dem_leaner==1
*replace uncongenial_fn=1 if (proD_fake==1 & repub_leaner==1) | (proR_fake==1 & dem_leaner==1)


**trust**
gen massmedia_trustw2 = media_trust_w2 /* recode high trust high */
recode massmedia_trustw2 1=4 2=3 3=2 4=1
tab massmedia_trustw2 media_trust_w2, missing

gen fbtrustw2 = fb_trust_w2 /* recode high trust high */
recode fbtrustw2 1=4 2=3 3=2 4=1
tab fbtrustw2 fb_trust_w2, missing

**affect**
gen FT_muslim = group_affect_muslim_w2
gen FT_christian = group_affect_christian_w2
gen FT_white = group_affect_white_w2
gen FT_black = group_affect_black_w2
gen FT_labor = group_affect_labor_w2
gen FT_rich = group_affect_rich_w2
gen FT_latino = group_affect_latino_w2
gen FT_white_latino = FT_white-FT_latino

gen FT_christian_muslim = FT_christian-FT_muslim


/*W2 DVs*/

**tweet DVs**

gen conf1 = vote_entitled_w2
gen conf2 = plan_vote_certain_w2
gen conf3 = officials_count_w2
gen conf4 = system_works_w2

alpha (conf1 conf2 conf3 conf4) // .79

gen trustelect1 =  trust_elections_w2
gen trustelect2 = secure_ballot_w2
gen trustelect3 = machine_accurate_w2
recode trustelect1  1=7 2=6 3=5 4=4 5=3 6=2 7=1 //reverse code so distrust high to match other items

alpha (trustelect1 trustelect2  trustelect3) // .80

gen democ_imp = importance_democracy_w2

gen polsys1 =  polsystem_w2_1
gen polsys2 =  polsystem_w2_2
gen polsys3 =  polsystem_w2_3
gen polsys4 =  polsystem_w2_4

factor conf1 conf2 conf3 conf4 trustelect1 trustelect2  trustelect3 democ_imp polsys1 polsys2 polsys3 polsys4

**standardize trust and conf items w diff scales
egen zconf1 = std(conf1)
egen zconf2 = std(conf2)
egen zconf3 = std(conf3)
egen zconf4 = std(conf4)
egen ztrustelect1 = std(trustelect1)
egen ztrustelect2  = std(trustelect2)
egen ztrustelect3 = std(trustelect3)

egen zconf_trust = rowmean ( zconf1 zconf2 zconf3 zconf4 ztrustelect1 ztrustelect2  ztrustelect3) // high = distrust 


**headline task**
**accuracy**
gen accuracy_donald_trump_caughtw2 = headline_accuracy_1_w2
gen accuracy_franklin_grahamw2 = headline_accuracy_2_w2
gen accuracy_vp_mike_pencew2 = headline_accuracy_3_w2
gen accuracy_vice_president_pencew2 = headline_accuracy_4_w2
gen accuracy_soros_money_behindw2 = headline_accuracy_5_w2
gen accuracy_kavanaugh_accuserw2 = headline_accuracy_6_w2
gen accuracy_fbi_agent_whow2 = headline_accuracy_7_w2
gen accuracy_lisa_pagew2 = headline_accuracy_8_w2
gen accuracy_a_series1w2 = headline_accuracy_9_w2
gen accuracy_a_border_patrolw2 = headline_accuracy_10_w2
gen accuracy_detention_of_migrantw2 = headline_accuracy_11_w2
gen accuracy_and_now1w2 = headline_accuracy_12_w2
gen accuracy_google_employeesw2 = headline_accuracy_13_w2
gen accuracy_feds_said_allegedw2 = headline_accuracy_14_w2
gen accuracy_small_busisness_optw2 = headline_accuracy_15_w2
gen accuracy_economy_adds_morew2 = headline_accuracy_16_w2


**fake mean
egen accuracy_fake_meanw2 = rowmean(accuracy_vp_mike_pencew2 accuracy_vice_president_pencew2 accuracy_fbi_agent_whow2 accuracy_lisa_pagew2)
**real mean
egen accuracy_real_meanw2 = rowmean(accuracy_a_series1w2 accuracy_a_border_patrolw2 accuracy_detention_of_migrantw2 accuracy_and_now1w2 accuracy_google_employeesw2 accuracy_feds_said_allegedw2 accuracy_small_busisness_optw2 accuracy_economy_adds_morew2)
**hyper mean 
egen accuracy_hyper_meanw2 = rowmean(accuracy_donald_trump_caughtw2 accuracy_franklin_grahamw2 accuracy_soros_money_behindw2 accuracy_kavanaugh_accuserw2) 
**all mean
egen accuracy_all_meanw2 = rowmean(accuracy_vp_mike_pencew2 accuracy_vice_president_pencew2 accuracy_fbi_agent_whow2 accuracy_lisa_pagew2 accuracy_a_series1w2 accuracy_a_border_patrolw2 accuracy_detention_of_migrantw2 accuracy_and_now1w2 accuracy_google_employeesw2 accuracy_feds_said_allegedw2 accuracy_small_busisness_optw2 accuracy_economy_adds_morew2 accuracy_donald_trump_caughtw2 accuracy_franklin_grahamw2 accuracy_soros_money_behindw2 accuracy_kavanaugh_accuserw2) 
**mean_acc_diff 
gen mean_acc_diffw2 = accuracy_real_meanw2 - accuracy_fake_meanw2

**descriptives on consumption + belief

egen accuracy_fake_mean_proD=rowmean(accuracy_vp_mike_pencew2 accuracy_vice_president_pencew2)
egen accuracy_fake_mean_proR=rowmean(accuracy_fbi_agent_whow2 accuracy_lisa_pagew2)

svyset [pweight=weight]

*gen exposed16=(repub_leaner==1 & accuracy_fake_mean_proR>=2.5 & accuracy_fake_mean_proR<=4 & totalprotrumpfnbinary_ag80==1) | (dem_leaner==1 & accuracy_fake_mean_proD>=2.5 & accuracy_fake_mean_proD<=4 & totalproclintonfnbinary_ag80==1)

gen exposed18=(repub_leaner==1 & accuracy_fake_mean_proR>=2.5 & accuracy_fake_mean_proR<=4 & totalprorepfnbinary==1) | (dem_leaner==1 & accuracy_fake_mean_proD>=2.5 & accuracy_fake_mean_proD<=4 & totalprodemfnbinary==1)

*svy: tab exposed16
svy: tab exposed18

*gen exposedall16=(accuracy_fake_mean>=2.5 & accuracy_fake_mean<=4 & (totalprotrumpfnbinary_ag80==1 | totalproclintonfnbinary_ag80))
gen exposedall18=(accuracy_fake_mean>=2.5 & accuracy_fake_mean<=4 & (totalprorepfnbinary==1 | totalprodemfnbinary==1))

*svy: tab exposedall16
svy: tab exposedall18

*gen believe=(accuracy_fake_mean>=2.5 & accuracy_fake_mean<=4)
*gen believestrict=(accuracy_fake_mean>=3 & accuracy_fake_mean<=4)
*gen consume16=(totalprotrumpfnbinary_ag80==1 | totalproclintonfnbinary_ag80)
gen consume18=(totalprorepfnbinary==1 | totalprodemfnbinary==1)

*svy: tab believe consume16
*svy: tab believe consume18

*svy: tab believestrict consume16
*svy: tab believestrict consume18


**need to shorten some varnmaes to make this work
foreach var of varlist accuracy_vp_mike_pence accuracy_vice_president_pence accuracy_fbi_agent_who accuracy_lisa_page accuracy_a_series1 accuracy_a_border_patrol accuracy_detention_of_migrant accuracy_and_now1 accuracy_google_employees accuracy_feds_said_alleged accuracy_small_busisness_opt accuracy_economy_adds_more accuracy_donald_trump_caught accuracy_franklin_graham accuracy_soros_money_behind accuracy_kavanaugh_accuser accuracy_vp_mike_pencew2 accuracy_vice_president_pencew2 accuracy_fbi_agent_whow2 accuracy_lisa_pagew2 accuracy_a_series1w2 accuracy_a_border_patrolw2 accuracy_detention_of_migrantw2 accuracy_and_now1w2 accuracy_google_employeesw2 accuracy_feds_said_allegedw2 accuracy_small_busisness_optw2 accuracy_economy_adds_morew2 accuracy_donald_trump_caughtw2 accuracy_franklin_grahamw2 accuracy_soros_money_behindw2 accuracy_kavanaugh_accuserw2 { 
gen b`var'=(`var'>2 & `var'<5) if `var'!=.
}

**sharing**
gen share_donald_trump_caughtw2 = headline_share_1_w2
gen share_franklin_grahamw2 = headline_share_2_w2
gen share_vp_mike_pencew2 = headline_share_3_w2
gen share_vice_president_pencew2 = headline_share_4_w2
gen share_soros_money_behindw2 = headline_share_5_w2
gen share_kavanaugh_accuserw2 = headline_share_6_w2
gen share_fbi_agent_whow2 = headline_share_7_w2
gen share_lisa_pagew2 = headline_share_8_w2
gen share_a_series1w2 = headline_share_9_w2
gen share_a_border_patrolw2 = headline_share_10_w2
gen share_detention_of_migrantw2 = headline_share_11_w2
gen share_and_now1w2 = headline_share_12_w2
gen share_google_employeesw2 = headline_share_13_w2
gen share_feds_said_allegedw2 = headline_share_14_w2
gen share_small_busisness_optw2 = headline_share_15_w2
gen share_economy_adds_morew2 = headline_share_16_w2


**fake mean
egen share_fake_meanw2 = rowmean(share_vp_mike_pencew2 share_vice_president_pencew2 share_fbi_agent_whow2 share_lisa_pagew2)
**real mean
egen share_real_meanw2 = rowmean(share_a_series1w2 share_a_border_patrolw2 share_detention_of_migrantw2 share_and_now1w2 share_google_employeesw2 share_feds_said_allegedw2 share_small_busisness_optw2 share_economy_adds_morew2)
**hyper mean 
egen share_hyper_meanw2 = rowmean(share_donald_trump_caughtw2 share_franklin_grahamw2 share_soros_money_behindw2 share_kavanaugh_accuserw2) 
**all mean
egen share_all_meanw2 = rowmean(share_vp_mike_pencew2 share_vice_president_pencew2 share_fbi_agent_whow2 share_lisa_pagew2 share_a_series1w2 share_a_border_patrolw2 share_detention_of_migrantw2 share_and_now1w2 share_google_employeesw2 share_feds_said_allegedw2 share_small_busisness_optw2 share_economy_adds_morew2 share_donald_trump_caughtw2 share_franklin_grahamw2 share_soros_money_behindw2 share_kavanaugh_accuserw2) 

**mean_share_diff 
gen mean_share_diffw2 = share_real_meanw2 - share_fake_meanw2


**beliefs**

/*First, we measure beliefs in the claims promoted in the two fake news stimulus articles:

The international financier and philanthropist George Soros has helped to support the caravan of more than 7,000 Central American migrants that is currently moving through Mexico toward the U.S. border.
-Not at all accurate (1)
-Not very accurate (2)
-Somewhat accurate (3)
-Very accurate (4)

The Trump administration helped Saudi Arabia to target Jamal Khashoggi, the writer for The Washington Post who was recently killed by Saudi agents.
-Not at all accurate (1)
-Not very accurate (2)
-Somewhat accurate (3)
-Very accurate (4)*/

su misinform_soros
su misinform_khashoggi

*distracters
su misinform_nuketreaty
su misinform_sexstatus


**FTs**
gen FT_dem_w2 = pol_therm_dem_w2 
gen FT_rep_w2 = pol_therm_rep_w2 
gen FT_trump_w2 = pol_therm_trump_w2 
gen FT_media_w2 = pol_therm_media_w2 
gen FT_jew_w2 = pol_therm_jew_w2 

**affective polarization**
gen dem_less_rep = FT_dem_w2 - FT_rep_w2
gen rep_less_dem = FT_rep_w2 - FT_dem_w2

gen dem_less_rep_x = dem_less_rep /*Cross with party*/
gen rep_less_dem_x = rep_less_dem 
replace dem_less_rep_x = 0 if repub==1
replace rep_less_dem_x = 0 if dem==1

gen affect_merged = dem_less_rep_x + rep_less_dem_x 

**with leaners 
gen dem_less_rep_y = dem_less_rep /*Cross with party with leaners*/
gen rep_less_dem_y = rep_less_dem 
replace dem_less_rep_y = 0 if repub_leaners==1
replace rep_less_dem_y = 0 if dem_leaners==1

gen affect_merged_leaners = dem_less_rep_y + rep_less_dem_y 

gen affect_polar=.
replace affect_polar=FT_dem_w2 - FT_rep_w2 if dem==1
replace affect_polar=FT_rep_w2 - FT_dem_w2 if repub==1

gen affect_polar_lean=.
replace affect_polar_lean=FT_dem_w2 - FT_rep_w2 if dem_leaners==1
replace affect_polar_lean=FT_rep_w2 - FT_dem_w2 if repub_leaners==1

/*PREREGISTERED ANALYSIS*/

/*A. OBSERVATIONAL HYPOTHESES*/

*NOTE: If making multi-column tables, beware cross-column inconsistency in use of survey weights. Can't use for clustered models; see below.

/*Observational covariates: Democrats and Republicans (including leaners), political knowledge (0-8) and interest (1-4), having a four-year college degree (0/1), self-identifying as a female (0/1) or non-white (0/1), and age group dummies (30-44, 45-59, 60+, 18-29 omitted).*/

/*H-A1) People with the strongest overall tendencies toward selective exposure will be the most likely to consume fake news and consume the most on average. (This hypothesis tests if the Guess et al. results replicate in this sample.)

Observational hypotheses
For H-A1, the outcome measure is exposure to fake news (binary/count/share of information diet):
Fake news exposure = [constant] + selective exposure decile indicators + covariates listed above*/

gen totalfakenewsbinary_new=(totalprorepfnbinary==1 | totalprodemfnbinary==1) if nopulse==0
gen totalfakenewscount_new=(totalprorepfncount+totalprodemfncount) if nopulse==0

*preregistered
svy: reg totalfakenewsbinary_new i.decile_prev dem_leaners repub_leaners polknow polint college female nonwhite ib1.agecat
estimates store fakebinarypost, title(fakebinarypost) 

svy: reg totalfakenewscount_new i.decile_prev dem_leaners repub_leaners polknow polint college female nonwhite ib1.agecat
estimates store fakecountpost, title(fakecountpost) 

**scrapped corrlates of pro-D and R consumption table
svy: reg totalprodemfncount crt_average dem_leaners repub_leaners polknow polint college female nonwhite ib1.agecat
estimates store demfakecountpost, title(demfakecountpost) 
lincom repub_leaners - dem_leaners
svy: reg totalprorepfncount crt_average dem_leaners repub_leaners polknow polint college female nonwhite ib1.agecat
estimates store repfakecountpost, title(repfakecountpost) 
lincom repub_leaners - dem_leaners
svy: reg totalfakenewscount_new crt_average dem_leaners repub_leaners polknow polint college female nonwhite ib1.agecat

lincom repub_leaners - dem_leaners

*estout A B using "fake-post-table.tex", replace varwidth(25) collabels("") cells(b(star fmt(%9.4f)) se(par fmt(%9.4f))) stats(r2 N, fmt(%9.2f %9.0f) labels("R^2" "N")) starlevels(* 0.05 ** 0.01 *** 0.005) style(tex) 

gen proDfrac=totalprodemfncount/totalnewsfncount
gen proRfrac=totalprorepfncount/totalnewsfncount

*replicating prior table
svy: reg totalprorepfnbinary i.decile_all dem_leaners repub_leaners polknow polint college female nonwhite ib1.agecat
est store A
svy: reg totalprodemfnbinary i.decile_all dem_leaners repub_leaners polknow polint college female nonwhite ib1.agecat
est store B
svy: reg proRfrac i.decile_all dem_leaners repub_leaners polknow polint college female nonwhite ib1.agecat
est store C
svy: reg proDfrac i.decile_all dem_leaners repub_leaners polknow polint college female nonwhite ib1.agecat
est store D

estout A C B D using "decile-table-share-post18-2018def.tex", replace varwidth(25) collabels("") cells(b(star fmt(%9.4f)) se(par fmt(%9.4f))) stats(r2 N, fmt(%9.2f %9.0f) labels("R^2" "N")) starlevels(* 0.05 ** 0.01 *** 0.005) style(tex) 

*replication graphs

label def replab2 1 "Republicans" 0 "Democrats"
label val repub_leaners replab2

preserve

rename totalprodemfnbinary view1 
rename totalprorepfnbinary view2
reshape long view, i(caseid) j(type)
label def foxfake 1 "Pro-Democrat fake news" 2 "Pro-Republican fake news"
label val type foxfake

cibar view if (dem_leaners==1 | repub_leaners==1) [pweight=weight], over1(type) over2(repub_leaners) bargap(8) gap(35) graphopts(graphregion(fcolor(white) ifcolor(none)) plotregion(fcolor(none) lcolor(white) ifcolor(none) ilcolor(none)) legend(row(1) pos(6) region(lpattern(solid) lcolor(black)))  ytitle("") scheme(lean1) yscale(r(0 .51)) ylab(0 "0%" .1 "10%" .2 "20%" .3 "30%" .4 "40%" .5 "50%",angle(0) grid glcolor(gs3)))
graph export "fnbinary-nk-ci-4bar-post18-newdvs.pdf",replace

restore

preserve

rename proDfrac view1 
rename proRfrac view2
reshape long view, i(caseid) j(type)
label def foxfake 1 "Pro-Democrat fake news" 2 "Pro-Republican fake news"
label val type foxfake

cibar view if (dem_leaners==1 | repub_leaners==1) [pweight=weight], over1(type) over2(repub_leaners) bargap(8) gap(35) graphopts(graphregion(fcolor(white) ifcolor(none)) plotregion(fcolor(none) lcolor(white) ifcolor(none) ilcolor(none)) legend(row(1) pos(6) region(lpattern(solid) lcolor(black)))  ytitle("") scheme(lean1) yscale(r(0 .071)) ylab(0 "0%" .01 "1%" .02 "2%" .03 "3%" .04 "4%" .05 "5%" .06 "6%" .07 "7%",angle(0) grid glcolor(gs3)))

graph export "fnprop-nk-ci-4bar-fall18-newdvs.pdf",replace

restore

preserve

matrix points=(1,1,.,.,.,0 \ 1,2,.,.,.,1 \ 2,4,.,.,.,0 \ 2,5,.,.,.,1 \ 3,7,.,.,.,0 \ 3,8,.,.,.,1 \ 4,10,.,.,.,0 \ 4,11,.,.,.,1 \ 5,13,.,.,.,0 \ 5,14,.,.,.,1 \ 6,16,.,.,.,0 \ 6,17,.,.,.,1 \ 7,19,.,.,.,0 \ 7,20,.,.,.,1 \ 8,22,.,.,.,0 \ 8,23,.,.,.,1 \ 9,25,.,.,.,0 \ 9,26,.,.,.,1 \ 10,28,.,.,.,0 \ 10,29,.,.,.,1)

forval i=1/10 {
svy,subpop(if decile_all==`i'): mean totalprodemfnbinary 
return list
local j=1+(2*(`i'-1))
matrix table=r(table)
matrix points[`j',3]=table[1,1]
matrix points[`j',4]=table[5,1]
matrix points[`j',5]=table[6,1]
display `i' `j'
}

forval i=1/10 {
svy,subpop(if decile_all==`i'): mean totalprorepfnbinary
return list
local j=2+(2*(`i'-1))
matrix table=r(table)
matrix points[`j',3]=table[1,1]
matrix points[`j',4]=table[5,1]
matrix points[`j',5]=table[6,1]
}

svmat points
rename points1 decilenum
rename points2 fakenum
rename points3 mean 
rename points4 ll
rename points5 ul
rename points6 type

graph twoway (bar mean fakenum if type==0) (bar mean fakenum if type==1) (rspike ll ul fakenum if type==0) (rspike ll ul fakenum if type==1, scheme(lean1) xlab(1.5 "1" 4.5 "2" 7.5 "3" 10.5 "4" 13.5 "5" 16.5 "6" 19.5 "7" 22.5 "8" 25.5 "9" 28.5 "10") yscale(r(0.01 .81)) ylab(0 "0%" .2 "20%" .4 "40%" .6 "60%" .8 "80%", grid glcolor(gs3)) graphregion(fcolor(white) ifcolor(none)) plotregion(fcolor(none) lcolor(white) ifcolor(none) ilcolor(none)) ytitle("") legend(row(1) pos(6) region(lpattern(solid) lcolor(black)) order (1 "Pro-Democrat" 2 "Pro-Republican")) xtitle("Average media diet slant decile (liberal to conservative)"))  
graph export "decileslantbinary-post18-newdvs.pdf", replace

list decilenum fakenum mean ll ul type if _n<21

restore

preserve

matrix points=(1,1,.,.,.,0 \ 1,2,.,.,.,1 \ 2,4,.,.,.,0 \ 2,5,.,.,.,1 \ 3,7,.,.,.,0 \ 3,8,.,.,.,1 \ 4,10,.,.,.,0 \ 4,11,.,.,.,1 \ 5,13,.,.,.,0 \ 5,14,.,.,.,1 \ 6,16,.,.,.,0 \ 6,17,.,.,.,1 \ 7,19,.,.,.,0 \ 7,20,.,.,.,1 \ 8,22,.,.,.,0 \ 8,23,.,.,.,1 \ 9,25,.,.,.,0 \ 9,26,.,.,.,1 \ 10,28,.,.,.,0 \ 10,29,.,.,.,1)

forval i=1/10 {
svy,subpop(if decile_all==`i'): mean proDfrac 
return list
local j=1+(2*(`i'-1))
matrix table=r(table)
matrix points[`j',3]=table[1,1]
matrix points[`j',4]=table[5,1]
matrix points[`j',5]=table[6,1]
display `i' `j'
}

forval i=1/10 {
svy,subpop(if decile_all==`i'): mean proRfrac
return list
local j=2+(2*(`i'-1))
matrix table=r(table)
matrix points[`j',3]=table[1,1]
matrix points[`j',4]=table[5,1]
matrix points[`j',5]=table[6,1]
}

svmat points
rename points1 decilenum
rename points2 fakenum
rename points3 mean 
rename points4 ll
rename points5 ul
rename points6 type

graph twoway (bar mean fakenum if type==0) (bar mean fakenum if type==1) (rspike ll ul fakenum if type==0) (rspike ll ul fakenum if type==1, scheme(lean1) xlab(1.5 "1" 4.5 "2" 7.5 "3" 10.5 "4" 13.5 "5" 16.5 "6" 19.5 "7" 22.5 "8" 25.5 "9" 28.5 "10") yscale(r(0 .16)) ylab(0 "0%" .05 "5%" .1 "10%" .15 "15%", grid glcolor(gs3)) graphregion(fcolor(white) ifcolor(none)) plotregion(fcolor(none) lcolor(white) ifcolor(none) ilcolor(none)) ytitle("") legend(row(1) pos(6) region(lpattern(solid) lcolor(black)) order (1 "Pro-Democrat" 2 "Pro-Republican")) xtitle("Average media diet slant decile (liberal to conservative)"))  
graph export "decileslantdiet-post18-newDVs.pdf", replace

list decilenum fakenum mean ll ul type if _n<21

restore

preserve

matrix points=(1,1,.,.,.,0 \ 1,2,.,.,.,1 \ 2,4,.,.,.,0 \ 2,5,.,.,.,1 \ 3,7,.,.,.,0 \ 3,8,.,.,.,1 \ 4,10,.,.,.,0 \ 4,11,.,.,.,1 \ 5,13,.,.,.,0 \ 5,14,.,.,.,1 \ 6,16,.,.,.,0 \ 6,17,.,.,.,1 \ 7,19,.,.,.,0 \ 7,20,.,.,.,1 \ 8,22,.,.,.,0 \ 8,23,.,.,.,1 \ 9,25,.,.,.,0 \ 9,26,.,.,.,1 \ 10,28,.,.,.,0 \ 10,29,.,.,.,1)

forval i=1/10 {
svy,subpop(if decile_all==`i'): mean totalprodemfncount 
return list
local j=1+(2*(`i'-1))
matrix table=r(table)
matrix points[`j',3]=table[1,1]
matrix points[`j',4]=table[5,1]
matrix points[`j',5]=table[6,1]
display `i' `j'
}

forval i=1/10 {
svy,subpop(if decile_all==`i'): mean totalprorepfncount
return list
local j=2+(2*(`i'-1))
matrix table=r(table)
matrix points[`j',3]=table[1,1]
matrix points[`j',4]=table[5,1]
matrix points[`j',5]=table[6,1]
}

svmat points
rename points1 decilenum
rename points2 fakenum
rename points3 mean 
rename points4 ll
rename points5 ul
rename points6 type

graph twoway (bar mean fakenum if type==0) (bar mean fakenum if type==1) (rspike ll ul fakenum if type==0) (rspike ll ul fakenum if type==1, scheme(lean1) xlab(1.5 "1" 4.5 "2" 7.5 "3" 10.5 "4" 13.5 "5" 16.5 "6" 19.5 "7" 22.5 "8" 25.5 "9" 28.5 "10") yscale(r(0 100.1)) ylab(0(10)100, grid glcolor(gs3)) graphregion(fcolor(white) ifcolor(none)) plotregion(fcolor(none) lcolor(white) ifcolor(none) ilcolor(none)) ytitle("") legend(row(1) pos(6) region(lpattern(solid) lcolor(black)) order (1 "Pro-Democrat" 2 "Pro-Republican")) xtitle("Average media diet slant decile (liberal to conservative)"))  
graph export "decileslantcount-post18-newdvs.pdf", replace

list decilenum fakenum mean ll ul type if _n<21

restore

*/

*svyset [pweight=weight]

/*code intervention*/
gen tips=(instructions_treat==2)

**balance check
xtile trump_terc = FT_trump, nquantiles(3)
xtile consp_terc = conspiracy_mean, nquantiles(3)
xtile media_terc = FT_media, nquantiles(3)
xtile fbtrust_terc = fb_trust, nquantiles(3)
xtile fbuse_terc = fb_use, nquantiles(3)
xtile fbpol_terc = fb_pol_use, nquantiles(3)

reg tips agecat
reg tips female
reg tips dem
reg tips repub
reg tips nonwhite
reg tips polint
reg tips polknow
reg tips crt_terc
reg tips fb_use
reg tips fb_trust
reg tips fb_pol_use
reg tips consp_terc
reg tips massmedia_trust // unbalanced 
reg tips media_terc
reg tips trump_terc

**tips effects on pulse
reg totalfakebinary18 tips if nopulse==0, robust
est store A
reg totalfakecount18 tips if nopulse==0, robust
est store B

reg totalfcbinary tips if nopulse==0, robust
est store C
reg totalfccount tips if nopulse==0, robust
est store D

reg totalmsbinary tips if nopulse==0, robust
est store E
reg totalmscount tips if nopulse==0, robust
est store F

estout A B C D E F using "tips-behavior-null.tex", replace varwidth(25) collabels("") cells(b(star fmt(%9.4f)) se(par fmt(%9.4f))) stats(r2 N, fmt(%9.2f %9.0f) labels("R^2" "N")) starlevels(* 0.05 ** 0.01 *** 0.005) style(tex) 

**tips effects on pulse with LASSO
reg totalfakebinary18 tips polknow polint FT_trump  affect_merged_leanersw1 conspiracy_mean if nopulse==0, robust
reg totalfakecount18 tips polknow polint FT_trump  affect_merged_leanersw1 conspiracy_mean if nopulse==0, robust

reg totalfcbinary tips polknow polint FT_trump  affect_merged_leanersw1 conspiracy_mean if nopulse==0, robust
reg totalfccount tips polknow polint FT_trump  affect_merged_leanersw1 conspiracy_mean if nopulse==0, robust

reg totalmsbinary tips polknow polint FT_trump  affect_merged_leanersw1 conspiracy_mean if nopulse==0, robust
reg totalmscount tips polknow polint FT_trump  affect_merged_leanersw1 conspiracy_mean if nopulse==0, robust

**probit/poisson robust
probit totalfakebinary18 tips if nopulse==0
est store A
poisson totalfakecount18 tips if nopulse==0, robust
est store B

probit totalfcbinary tips if nopulse==0
est store C
poisson totalfccount tips if nopulse==0, robust
est store D

probit totalmsbinary tips if nopulse==0
est store E
poisson totalmscount tips if nopulse==0, robust
est store F

estout A B C D E F, replace varwidth(25) collabels("") cells(b(star fmt(%9.4f)) se(par fmt(%9.4f))) stats(r2 N, fmt(%9.2f %9.0f) labels("R^2" "N")) starlevels(* 0.05 ** 0.01 *** 0.005) style(tex) 

**probit/nbreg robust
probit totalfakebinary18 tips if nopulse==0
est store A
nbreg totalfakecount18 tips if nopulse==0, robust
est store B

probit totalfcbinary tips if nopulse==0
est store C
nbreg totalfccount tips if nopulse==0, robust
est store D

probit totalmsbinary tips if nopulse==0
est store E
nbreg totalmscount tips if nopulse==0, robust
est store F

estout A B C D E F, replace varwidth(25) collabels("") cells(b(star fmt(%9.4f)) se(par fmt(%9.4f))) stats(r2 N, fmt(%9.2f %9.0f) labels("R^2" "N")) starlevels(* 0.05 ** 0.01 *** 0.005) style(tex) 

**probit/zip robust
probit totalfakebinary18 tips if nopulse==0
est store A
zip totalfakecount18 tips if nopulse==0, inflate(tips) robust
est store B

probit totalfcbinary tips if nopulse==0
est store C
zip totalfccount tips if nopulse==0, inflate(tips) robust
est store D

probit totalmsbinary tips if nopulse==0
est store E
zip totalmscount tips if nopulse==0, inflate(tips) robust
est store F

estout A B C D E F, replace varwidth(25) collabels("") cells(b(star fmt(%9.4f)) se(par fmt(%9.4f))) stats(r2 N, fmt(%9.2f %9.0f) labels("R^2" "N")) starlevels(* 0.05 ** 0.01 *** 0.005) style(tex) 

**probit/zip robust
probit totalfakebinary18 tips if nopulse==0
est store A
zinb totalfakecount18 tips if nopulse==0, inflate(tips) robust
est store B

probit totalfcbinary tips if nopulse==0
est store C
zinb totalfccount tips if nopulse==0, inflate(tips) robust
est store D

probit totalmsbinary tips if nopulse==0
est store E
zinb totalmscount tips if nopulse==0, inflate(tips) robust
est store F

estout A B C D E F, replace varwidth(25) collabels("") cells(b(star fmt(%9.4f)) se(par fmt(%9.4f))) stats(r2 N, fmt(%9.2f %9.0f) labels("R^2" "N")) starlevels(* 0.05 ** 0.01 *** 0.005) style(tex) 


foreach var of varlist tips_check* {
tab `var' tips, chi col
}

/*how many saw*/
gen miss_tips_binary=(tips_check1b!=. | tips_check2b!=. | tips_check3b!=.)
tab miss_tips_binary

gen miss_tips_total=(tips_check1b!=.)+(tips_check2b!=.)+(tips_check3b!=.)
tab miss_tips_total


**pre-reshape real-fake mean acc models

reg mean_acc_diff tips, robust cluster(caseid)
estimates store t4c5, title(Tips effect on fake-real w1)

reg mean_acc_diff tips polknow polint FT_trump  affect_merged_leanersw1 conspiracy_mean, robust cluster(caseid)
estimates store tA4c5, title(Tips effect on fake-real w1)



/*w1 reshape*/

forval i=1/8 {
rename accuracy`i' accuracy_shown_`i'
}

preserve

*accuracy reshape

rename accuracy_donald_trump_caught accuracy1
rename accuracy_franklin_graham accuracy2
rename accuracy_vp_mike_pence accuracy3
rename accuracy_vice_president_pence accuracy4
rename accuracy_soros_money_behind accuracy5
rename accuracy_kavanaugh_accuser accuracy6
rename accuracy_fbi_agent_who accuracy7
rename accuracy_lisa_page accuracy8
rename accuracy_a_series1 accuracy9
rename accuracy_a_border_patrol accuracy10
rename accuracy_detention_of_migrant accuracy11
rename accuracy_and_now1 accuracy12
rename accuracy_google_employees accuracy13
rename accuracy_feds_said_alleged accuracy14
rename accuracy_small_busisness_opt accuracy15
rename accuracy_economy_adds_more accuracy16



forval i=1/16 {
svy: tab accuracy`i'
}

reshape long accuracy,i(caseid) j(dv)

gen fake=(dv==3 | dv==4 | dv==7 | dv==8)
gen real=(dv>8 & dv<17)
gen hyper=(dv==1 | dv==2 | dv==5 | dv==6)






/*congeniality coding has to be here*/

**october headline codes
*pro-D hyper 1 = donald_trump_caught_png, 2 = franklin_graham_png
*pro-D fake 3 = vp_mike_pence_png 4 = vice_president_pence_png
*proR hyper 5 = soros_money_behind_png, 6 = kavanaugh_accuser_png
*proR fake 7 = fbi_agent_who_png, 8 = lisa_page_png
*pro d real 9 = a_series_of_suspicious_png, 10 = a_border_patrol_png, 11 = detention_of_migrant__png 12 = and_now_its_the_tallest_png
*proR real 13 = google_employees_png, 14 = feds_said_alleged_png, 15 = small_busisness_optimism_ , 16 = economy_adds_more_png

gen pro_d=(dv==1 | dv==2 | dv==3 | dv==4 | dv==9 | dv==10 | dv==11 | dv==12)
gen pro_r=(dv==5 | dv==6 | dv==7 | dv==8 | dv==13 | dv==14 | dv==15 | dv==16)
gen congenial=(pro_d==1 & dem_leaner==1) | (pro_r==1 & repub_leaner==1)
gen uncongenial=(pro_r==1 & dem_leaner==1) | (pro_d==1 & repub_leaner==1)

gen binary_accuracy=(accuracy>2 & accuracy<5)

**t1 mpsa
reg accuracy congenial uncongenial crt_average tips polknow polint college female nonwhite ib1.agecat i.dv if fake==1, robust cluster(caseid)
estimates store acc_corrw1post, title(acc_corrpost1) 

lincom congenial-uncongenial

reg accuracy congenial uncongenial crt_average tips polknow polint college female nonwhite ib1.agecat i.dv i.dem_leaner i.repub_leaner if fake==1, robust cluster(caseid)

su accuracy

*preserve
*collapse (mean) accuracy binary_accuracy [pweight=weight],by(fake real hyper)
*sort fake real hyper
*list
*restore

/*

gen type=.
replace type=1 if fake==1
replace type=2 if hyper==1
replace type=3 if real==1

label def typelab 1 "Fake news" 2 "Hyper-partisan news" 3 "Real news"
label val type typelab

cibar binary_accuracy [pweight=weight], over1(type) bargap(8) gap(35) graphopts(graphregion(fcolor(white) ifcolor(none)) plotregion(fcolor(none) lcolor(white) ifcolor(none) ilcolor(none)) legend(row(1) pos(6) region(lpattern(solid) lcolor(black)))  ytitle("") scheme(lean1) yscale(r(0 .51)) ylab(0 "0%" .1 "10%" .2 "20%" .3 "30%" .4 "40%" .5 "50%",angle(0) grid glcolor(gs3)))
graph export "accuracy-type-binary.pdf",replace

cibar accuracy [pweight=weight], over1(type) bargap(8) gap(35) graphopts(graphregion(fcolor(white) ifcolor(none)) plotregion(fcolor(none) lcolor(white) ifcolor(none) ilcolor(none)) legend(row(1) pos(6) region(lpattern(solid) lcolor(black)))  ytitle("") scheme(lean1) yscale(r(0 4.1)) ylab(1 "Not at all accurate" 2 "Not very accurate" 3 "Somewhat accurate" 4 "Very accurate",angle(0) grid glcolor(gs3)))
graph export "accuracy-type.pdf",replace

label def conglab 0 "Uncongenial" 1 "Congenial"
label val congenial conglab


*preserve
*collapse (mean) accuracy binary_accuracy [pweight=weight] if independents==0,by(fake real hyper)
*sort fake real hyper 
*list
*restore


cibar accuracy [pweight=weight] if independents==0, over1(congenial) over2(type) bargap(8) gap(35) graphopts(graphregion(fcolor(white) ifcolor(none)) plotregion(fcolor(none) lcolor(white) ifcolor(none) ilcolor(none)) legend(row(1) pos(6) region(lpattern(solid) lcolor(black))) yscale(r(1 4.1)) ytitle("") scheme(lean1) ylab(1 "Not at all accurate" 2 "Not very accurate" 3 "Somewhat accurate" 4 "Very accurate",angle(0) grid glcolor(gs3)))
graph export "accuracy-type-congenial.pdf",replace

cibar binary_accuracy [pweight=weight] if independents==0, over1(congenial) over2(type) bargap(8) gap(35) graphopts(graphregion(fcolor(white) ifcolor(none)) plotregion(fcolor(none) lcolor(white) ifcolor(none) ilcolor(none)) legend(row(1) pos(6) region(lpattern(solid) lcolor(black))) yscale(r(0 .51)) ytitle("") scheme(lean1) ylab(0 "0%" .1 "10%" .2 "20%" .3 "30%" .4 "40%" .5 "50%",angle(0) grid glcolor(gs3)))
graph export "accuracy-type-congenial-binary.pdf",replace

cibar binary_accuracy [pweight=weight] if independents==0 & dem_lean==1, over1(congenial) over2(type) bargap(8) gap(35) graphopts(graphregion(fcolor(white) ifcolor(none)) plotregion(fcolor(none) lcolor(white) ifcolor(none) ilcolor(none)) legend(row(1) pos(6) region(lpattern(solid) lcolor(black))) yscale(r(0 .51)) ytitle("") scheme(lean1) ylab(0 "0%" .1 "10%" .2 "20%" .3 "30%" .4 "40%" .5 "50%",angle(0) grid glcolor(gs3)))
graph export "accuracy-type-congenial-binary-dem.pdf",replace

cibar binary_accuracy [pweight=weight] if independents==0 & repub_lean==1, over1(congenial) over2(type) bargap(8) gap(35) graphopts(graphregion(fcolor(white) ifcolor(none)) plotregion(fcolor(none) lcolor(white) ifcolor(none) ilcolor(none)) legend(row(1) pos(6) region(lpattern(solid) lcolor(black))) yscale(r(0 .51)) ytitle("") scheme(lean1) ylab(0 "0%" .1 "10%" .2 "20%" .3 "30%" .4 "40%" .5 "50%",angle(0) grid glcolor(gs3)))
graph export "accuracy-type-congenial-binary-rep.pdf",replace

*fake decile *
*cibar binary_accuracy [pweight=weight] if independents==0 & fake==1, over1(congenial) over2(decile) bargap(8) gap(35) graphopts(graphregion(fcolor(white) ifcolor(none)) plotregion(fcolor(none) lcolor(white) ifcolor(none) ilcolor(none)) legend(row(1) pos(6) region(lpattern(solid) lcolor(black))) yscale(r(0 .51)) ytitle("") scheme(lean1) ylab(0 "0%" .1 "10%" .2 "20%" .3 "30%" .4 "40%" .5 "50%",angle(0) grid glcolor(gs3)))
*graph export "accuracy-type-congenial-decile binary.pdf",replace /

*crt graphs (descriptive)

label def crtlabel2 1 "Low CRT" 2 "Medium CRT" 3 "High CRT"
label val crt_terc crtlabel2

cibar accuracy [pweight=weight],over1(type) bargap(8) gap(35) over2(crt_terc) graphopts(graphregion(fcolor(white) ifcolor(none)) plotregion(fcolor(none) lcolor(white) ifcolor(none) ilcolor(none)) ytitle("") scheme(lean1) yscale(r(1 4.1)) ylab(1 "Not at all accurate" 2 "Not very accurate" 3 "Somewhat accurate" 4 "Very accurate",angle(0) grid glcolor(gs3)) legend(row(1) pos(6) region(lpattern(solid) lcolor(black))) )
graph export "accuracy-type-crt.pdf", replace

cibar accuracy [pweight=weight],over1(crt_terc) bargap(8) gap(35) over2(type) graphopts(graphregion(fcolor(white) ifcolor(none)) plotregion(fcolor(none) lcolor(white) ifcolor(none) ilcolor(none)) ytitle("") scheme(lean1) yscale(r(1 4.1)) ylab(1 "Not at all accurate" 2 "Not very accurate" 3 "Somewhat accurate" 4 "Very accurate",angle(0) grid glcolor(gs3)) legend(row(1) pos(6) region(lpattern(solid) lcolor(black))) )
graph export "accuracy-type-crt2.pdf", replace

cibar accuracy [pweight=weight] if uncongenial==1,over1(crt_terc) bargap(8) gap(35) over2(type) graphopts(graphregion(fcolor(white) ifcolor(none)) plotregion(fcolor(none) lcolor(white) ifcolor(none) ilcolor(none)) ytitle("") scheme(lean1) yscale(r(1 4.1)) ylab(1 "Not at all accurate" 2 "Not very accurate" 3 "Somewhat accurate" 4 "Very accurate",angle(0) grid glcolor(gs3)) legend(row(1) pos(6) region(lpattern(solid) lcolor(black))) )
graph export "accuracy-type-crt2-uncongenial.pdf", replace

cibar accuracy [pweight=weight] if congenial==1,over1(crt_terc) bargap(8) gap(35) over2(type) graphopts(graphregion(fcolor(white) ifcolor(none)) plotregion(fcolor(none) lcolor(white) ifcolor(none) ilcolor(none)) ytitle("") scheme(lean1) yscale(r(1 4.1)) ylab(1 "Not at all accurate" 2 "Not very accurate" 3 "Somewhat accurate" 4 "Very accurate",angle(0) grid glcolor(gs3)) legend(row(1) pos(6) region(lpattern(solid) lcolor(black))) )
graph export "accuracy-type-crt2-congenial.pdf", replace

cibar accuracy [pweight=weight] if fake==1,over1(crt_terc) bargap(8) gap(35) over2(congenial) graphopts(graphregion(fcolor(white) ifcolor(none)) plotregion(fcolor(none) lcolor(white) ifcolor(none) ilcolor(none)) ytitle("") scheme(lean1) yscale(r(1 4.1)) ylab(1 "Not at all accurate" 2 "Not very accurate" 3 "Somewhat accurate" 4 "Very accurate",angle(0) grid glcolor(gs3)) legend(row(1) pos(6) region(lpattern(solid) lcolor(black))) )
graph export "accuracy-type-crt2-fake-congenial.pdf", replace

cibar binary_accuracy [pweight=weight] if fake==1,over1(crt_terc) bargap(8) gap(35) over2(congenial) graphopts(graphregion(fcolor(white) ifcolor(none)) plotregion(fcolor(none) lcolor(white) ifcolor(none) ilcolor(none)) ytitle("") scheme(lean1) yscale(r(0 .51)) ylab(0 "0%" .1 "10%" .2 "20%" .3 "30%" .4 "40%" .5 "50%",angle(0) grid glcolor(gs3)) legend(row(1) pos(6) region(lpattern(solid) lcolor(black))) )
graph export "accuracy-type-crt2-fake-congenial-binary.pdf", replace

*/

*preserve
*collapse (mean) accuracy binary_accuracy [pweight=weight] if independents==0,by(fake real hyper congenial uncongenial)
*sort fake real hyper congenial
*list
*restore


/*tips main effect*/
reg accuracy tips i.dv if fake==1, robust cluster(caseid)
estimates store t4c1, title(Tips effect on fake news accuracy w1)
reg accuracy tips##miss_tips_binary i.dv if fake==1, robust cluster(caseid) /*exploratory*/
reg accuracy tips i.dv if real==1, robust cluster(caseid)
estimates store t4c3, title(Tips effect on real news accuracy w1)
reg accuracy tips##miss_tips_binary i.dv if real==1, robust cluster(caseid) /*exploratory*/
reg accuracy tips i.dv if hyper==1, robust cluster(caseid)
estimates store tips_hyperw1, title(Tips effect on hyper accuracy w1)
reg accuracy tips##miss_tips_binary i.dv if hyper==1, robust cluster(caseid) /*exploratory*/

*reg mean_acc_diff tips i.dv, robust cluster(caseid)
*estimates store t4c5, title(Tips effect on fake-real w1)
reg mean_acc_diff tips##miss_tips_binary i.dv, robust cluster(caseid)/*exploratory*/


**tips main effects LASSO**
reg accuracy tips polknow polint FT_trump  affect_merged_leanersw1 conspiracy_mean i.dv if fake==1, robust cluster(caseid)
estimates store tA4c1, title(Tips effect on fake news accuracy w1)
reg accuracy tips polknow polint FT_trump  affect_merged_leanersw1 conspiracy_mean i.dv if real==1, robust cluster(caseid)
estimates store tA4c3, title(Tips effect on real news accuracy w1)
reg accuracy tips polknow polint FT_trump  affect_merged_leanersw1 conspiracy_mean i.dv if hyper==1, robust cluster(caseid)
*reg mean_acc_diff tips polknow polint FT_trump  affect_merged_leanersw1 conspiracy_mean i.dv, robust cluster(caseid)
*estimates store tA4c5, title(Tips effect on fake-real w1)



/* moderations H-C1) The effect of the news tips intervention will be reduced for pro-attitudinal content compared to counter-attitudinal content. (Based on prior findings showing greater vulnerability to pro-attitudinal misinformation (e.g., Nyhan and Reifler 2010), we expect that respondents will improve less at distinguishing false from real news in response to the intervention when the content in question is consistent with their predispositions; see also, e.g., Metzger, Hartsell, and Flanagin 2015.)
In addition, we will also conduct exploratory analysis of other potential moderators of the effect 
of news tips on the perceived accuracy of real and fake news: Cognitive Reflection Test scores (
per Pennycook and Rand 2018, but see Kahan 2018), trust in and feelings toward the media, 
feelings toward Trump, conspiracy predispositions, political interest and knowledge, and 
pre-treatment visits to fake news sites and fact-checking sites. 
*/

**congenial
reg mean_acc_diff congenial##tips i.dv, robust cluster(caseid)
estimates store congenial_diff, title(congenial diff) 
reg accuracy congenial##tips i.dv, robust cluster(caseid)
reg accuracy congenial##tips i.dv  if fake==1, robust cluster(caseid) // maybe something here
estimates store congenial_fake, title(congenial fake) 
reg accuracy congenial##tips i.dv  if hyper==1, robust cluster(caseid)
reg accuracy congenial##tips i.dv  if real==1, robust cluster(caseid)
estimates store congenial_real, title(congenial real) 

cibar accuracy, over1(tips) over2(congenial) over3(fake) 

**congenial with LASSO
reg mean_acc_diff congenial##tips polknow polint FT_trump  affect_merged_leanersw1 conspiracy_mean i.dv, robust cluster(caseid)
estimates store congenial_diffcv, title(congenial diffcv) 
reg accuracy congenial##tips polknow polint FT_trump  affect_merged_leanersw1 conspiracy_mean i.dv, robust cluster(caseid)
reg accuracy congenial##tips polknow polint FT_trump  affect_merged_leanersw1 conspiracy_mean i.dv  if fake==1, robust cluster(caseid) // maybe something here
estimates store congenial_fakecv, title(congenial fakecv) 
reg accuracy congenial##tips polknow polint FT_trump  affect_merged_leanersw1 conspiracy_mean i.dv  if hyper==1, robust cluster(caseid)
reg accuracy congenial##tips polknow polint FT_trump  affect_merged_leanersw1 conspiracy_mean i.dv  if real==1, robust cluster(caseid)
estimates store congenial_realcv, title(congenial realcv) 

**congenial diff
reg mean_acc_diff congenial##tips, robust cluster(caseid)
estimates store congenial_diff, title(congenial diff) 

**congenial diff with LASSO
reg mean_acc_diff congenial##tips polknow polint FT_trump  affect_merged_leanersw1 conspiracy_mean, robust cluster(caseid)
estimates store congenial_diffcv, title(congenial diffcv) 

**crt diff
reg mean_acc_diff c.crt_average##tips, robust cluster(caseid)
estimates store crt_diff, title(crt diff) 

**crt diff + LASSO
reg mean_acc_diff c.crt_average##tips polknow polint FT_trump  affect_merged_leanersw1 conspiracy_mean, robust cluster(caseid)
estimates store crt_diffcv, title(crt diff cv) 

**crt
reg mean_acc_diff c.crt_average##tips i.dv, robust cluster(caseid)
reg accuracy c.crt_average##tips i.dv, robust cluster(caseid)
reg accuracy c.crt_average##tips i.dv  if fake==1, robust cluster(caseid)
estimates store crt_fake, title(crt fake) 
reg accuracy c.crt_average##tips i.dv  if hyper==1, robust cluster(caseid)
reg accuracy c.crt_average##tips i.dv  if real==1, robust cluster(caseid)
estimates store crt_real, title(crt real) 

**crt + LASSO
reg mean_acc_diff c.crt_average##tips polknow polint FT_trump  affect_merged_leanersw1 conspiracy_mean i.dv, robust cluster(caseid)
reg accuracy c.crt_average##tips polknow polint FT_trump  affect_merged_leanersw1 conspiracy_mean i.dv, robust cluster(caseid)
reg accuracy c.crt_average##tips polknow polint FT_trump affect_merged_leanersw1 conspiracy_mean i.dv  if fake==1, robust cluster(caseid)
reg accuracy c.crt_average##tips polknow polint FT_trump  affect_merged_leanersw1 conspiracy_mean i.dv  if hyper==1, robust cluster(caseid)
reg accuracy c.crt_average##tips polknow polint FT_trump  affect_merged_leanersw1 conspiracy_mean i.dv  if real==1, robust cluster(caseid)

*media trust 
reg mean_acc_diff massmedia_trust##tips i.dv, robust cluster(caseid)
reg accuracy massmedia_trust##tips i.dv, robust cluster(caseid)
reg accuracy massmedia_trust##tips i.dv  if fake==1, robust cluster(caseid)
reg accuracy massmedia_trust##tips i.dv  if hyper==1, robust cluster(caseid)
reg accuracy massmedia_trust##tips i.dv  if real==1, robust cluster(caseid)

*media FT
reg mean_acc_diff media_terc##tips i.dv, robust cluster(caseid)
reg accuracy media_terc##tips i.dv, robust cluster(caseid)
reg accuracy media_terc##tips i.dv  if fake==1, robust cluster(caseid)
reg accuracy media_terc##tips i.dv  if hyper==1, robust cluster(caseid)
reg accuracy media_terc##tips i.dv  if real==1, robust cluster(caseid)

*feelings toward Trump, 
reg mean_acc_diff trump_terc##tips i.dv, robust cluster(caseid)
reg accuracy trump_terc##tips i.dv, robust cluster(caseid)
reg accuracy trump_terc##tips i.dv  if fake==1, robust cluster(caseid)
reg accuracy trump_terc##tips i.dv  if hyper==1, robust cluster(caseid)
reg accuracy trump_terc##tips i.dv  if real==1, robust cluster(caseid)

*conspiracy predispositions, 
reg mean_acc_diff consp_terc##tips i.dv, robust cluster(caseid)
reg accuracy consp_terc##tips i.dv, robust cluster(caseid)
reg accuracy consp_terc##tips i.dv  if fake==1, robust cluster(caseid)
reg accuracy consp_terc##tips i.dv  if hyper==1, robust cluster(caseid)
reg accuracy consp_terc##tips i.dv  if real==1, robust cluster(caseid)

*political interest 
reg mean_acc_diff polint##tips i.dv, robust cluster(caseid)
reg accuracy polint##tips i.dv, robust cluster(caseid)
reg accuracy polint##tips i.dv  if fake==1, robust cluster(caseid)
reg accuracy polint##tips i.dv  if hyper==1, robust cluster(caseid)
reg accuracy polint##tips i.dv  if real==1, robust cluster(caseid)

*knowledge
reg mean_acc_diff polknow##tips i.dv, robust cluster(caseid)
reg accuracy polknow##tips i.dv, robust cluster(caseid)
reg accuracy polknow##tips i.dv  if fake==1, robust cluster(caseid)
reg accuracy polknow##tips i.dv  if hyper==1, robust cluster(caseid)
reg accuracy polknow##tips i.dv  if real==1, robust cluster(caseid)

*age 
reg mean_acc_diff agecat##tips i.dv, robust cluster(caseid)
reg accuracy agecat##tips i.dv, robust cluster(caseid)
reg accuracy agecat##tips i.dv  if fake==1, robust cluster(caseid)
reg accuracy agecat##tips i.dv  if hyper==1, robust cluster(caseid)
reg accuracy agecat##tips i.dv  if real==1, robust cluster(caseid)

label def tipslab 0 "Control" 1 "Fake news tips"
label val tips tips tipslab

cibar accuracy if fake==1, over1(tips) bargap(8) gap(35) graphopts(graphregion(fcolor(white) ifcolor(none)) plotregion(fcolor(none) lcolor(white) ifcolor(none) ilcolor(none)) ytitle("") scheme(lean1) yscale(r(1 4.1)) ylab(1 "Not at all accurate" 2 "Not very accurate" 3 "Somewhat accurate" 4 "Very accurate",angle(0) grid glcolor(gs3)) legend(row(1) pos(6) region(lpattern(solid) lcolor(black))))


graph export "accuracy-fake-tips.pdf",replace
cibar accuracy if hyper==1, over1(tips) bargap(8) gap(35) graphopts(graphregion(fcolor(white) ifcolor(none)) plotregion(fcolor(none) lcolor(white) ifcolor(none) ilcolor(none)) ytitle("") scheme(lean1) yscale(r(1 4.1)) ylab(1 "Not at all accurate" 2 "Not very accurate" 3 "Somewhat accurate" 4 "Very accurate",angle(0) grid glcolor(gs3)) legend(row(1) pos(6) region(lpattern(solid) lcolor(black))))
graph export "accuracy-hyper-tips.pdf",replace
cibar accuracy if real==1, over1(tips) bargap(8) gap(35) graphopts(graphregion(fcolor(white) ifcolor(none)) plotregion(fcolor(none) lcolor(white) ifcolor(none) ilcolor(none)) ytitle("") scheme(lean1) yscale(r(1 4.1)) ylab(1 "Not at all accurate" 2 "Not very accurate" 3 "Somewhat accurate" 4 "Very accurate",angle(0) grid glcolor(gs3)) legend(row(1) pos(6) region(lpattern(solid) lcolor(black))))
graph export "accuracy-real-tips.pdf",replace

gen type=.
replace type=1 if fake==1
replace type=2 if hyper==1
replace type=3 if real==1

label def typelab 1 "Fake news" 2 "Hyper-partisan news" 3 "Real news"
label val type typelab

cibar accuracy, over1(tips) over2(type) bargap(8) gap(35) graphopts(graphregion(fcolor(white) ifcolor(none)) plotregion(fcolor(none) lcolor(white) ifcolor(none) ilcolor(none)) ytitle("") scheme(lean1) yscale(r(1 4.1)) ylab(1 "Not at all accurate" 2 "Not very accurate" 3 "Somewhat accurate" 4 "Very accurate",angle(0) grid glcolor(gs3)) legend(row(1) pos(6) region(lpattern(solid) lcolor(black))))
graph export "accuracy-all-tips.pdf",replace

cibar binary_accuracy, over1(tips) over2(type) bargap(8) gap(35) graphopts(graphregion(fcolor(white) ifcolor(none)) plotregion(fcolor(none) lcolor(white) ifcolor(none) ilcolor(none)) legend(row(1) pos(6) region(lpattern(solid) lcolor(black)))  ytitle("") scheme(lean1) yscale(r(0 .51)) ylab(0 "0%" .1 "10%" .2 "20%" .3 "30%" .4 "40%" .5 "50%",angle(0) grid glcolor(gs3)))
graph export "accuracy-all-tips-binary.pdf",replace

cibar accuracy if fake==1, over1(tips) over2(agecat) 
graph export "accuracy-fake-age.pdf",replace
cibar accuracy if hyper==1, over1(tips) over2(agecat)
graph export "accuracy-hyper-age.pdf",replace
cibar accuracy if real==1, over1(tips) over2(agecat)
graph export "accuracy-real-age.pdf",replace

label def crtlabel2 1 "Low CRT" 2 "Medium CRT" 3 "High CRT"
label val crt_terc crtlabel2

cibar accuracy if fake==1, over1(tips) bargap(8) gap(35) graphopts(graphregion(fcolor(white) ifcolor(none)) plotregion(fcolor(none) lcolor(white) ifcolor(none) ilcolor(none)) ytitle("") scheme(lean1) yscale(r(1 4.1)) ylab(1 "Not at all accurate" 2 "Not very accurate" 3 "Somewhat accurate" 4 "Very accurate",angle(0) grid glcolor(gs3)) legend(row(1) pos(6) region(lpattern(solid) lcolor(black))))
graph export "accuracy-fake-tips.pdf",replace
cibar accuracy if hyper==1, over1(tips) bargap(8) gap(35) graphopts(graphregion(fcolor(white) ifcolor(none)) plotregion(fcolor(none) lcolor(white) ifcolor(none) ilcolor(none)) ytitle("") scheme(lean1) yscale(r(1 4.1)) ylab(1 "Not at all accurate" 2 "Not very accurate" 3 "Somewhat accurate" 4 "Very accurate",angle(0) grid glcolor(gs3)) legend(row(1) pos(6) region(lpattern(solid) lcolor(black))))
graph export "accuracy-hyper-tips.pdf",replace
cibar accuracy if real==1, over1(tips) bargap(8) gap(35) graphopts(graphregion(fcolor(white) ifcolor(none)) plotregion(fcolor(none) lcolor(white) ifcolor(none) ilcolor(none)) ytitle("") scheme(lean1) yscale(r(1 4.1)) ylab(1 "Not at all accurate" 2 "Not very accurate" 3 "Somewhat accurate" 4 "Very accurate",angle(0) grid glcolor(gs3)) legend(row(1) pos(6) region(lpattern(solid) lcolor(black))))
graph export "accuracy-real-tips.pdf",replace

cibar accuracy, over1(tips) over2(type) bargap(8) gap(35) graphopts(graphregion(fcolor(white) ifcolor(none)) plotregion(fcolor(none) lcolor(white) ifcolor(none) ilcolor(none)) ytitle("") scheme(lean1) yscale(r(1 4.1)) ylab(1 "Not at all accurate" 2 "Not very accurate" 3 "Somewhat accurate" 4 "Very accurate",angle(0) grid glcolor(gs3)) legend(row(1) pos(6) region(lpattern(solid) lcolor(black))))
graph export "accuracy-all-tips.pdf",replace

cibar binary_accuracy, over1(tips) over2(type) bargap(8) gap(35) graphopts(graphregion(fcolor(white) ifcolor(none)) plotregion(fcolor(none) lcolor(white) ifcolor(none) ilcolor(none)) legend(row(1) pos(6) region(lpattern(solid) lcolor(black)))  ytitle("") scheme(lean1) yscale(r(0 .51)) ylab(0 "0%" .1 "10%" .2 "20%" .3 "30%" .4 "40%" .5 "50%",angle(0) grid glcolor(gs3)))
graph export "accuracy-all-tips-binary-.pdf",replace

cibar accuracy if fake==1, over1(tips) over2(crt_terc) bargap(8) gap(35) graphopts(graphregion(fcolor(white) ifcolor(none)) plotregion(fcolor(none) lcolor(white) ifcolor(none) ilcolor(none)) ytitle("") scheme(lean1) yscale(r(1 4.1)) ylab(1 "Not at all accurate" 2 "Not very accurate" 3 "Somewhat accurate" 4 "Very accurate",angle(0) grid glcolor(gs3)) legend(row(1) pos(6) region(lpattern(solid) lcolor(black))))
graph export "accuracy-fake-tips-crt.pdf",replace

label def conglab 0 "Uncongenial" 1 "Congenial"
label val congenial conglab

cibar accuracy if fake==1 & (dem_leaners==1 | repub_leaners==1), over1(tips) over2(congenial) bargap(8) gap(35) graphopts(graphregion(fcolor(white) ifcolor(none)) plotregion(fcolor(none) lcolor(white) ifcolor(none) ilcolor(none)) ytitle("") scheme(lean1) yscale(r(1 4.1)) ylab(1 "Not at all accurate" 2 "Not very accurate" 3 "Somewhat accurate" 4 "Very accurate",angle(0) grid glcolor(gs3)) legend(row(1) pos(6) region(lpattern(solid) lcolor(black))))
graph export "accuracy-fake-tips-congenial.pdf",replace

label def dvlab 3 "Pence 1" 4 "Pence 2" 7 "FBI agent" 8 "Lisa Page"
label val dv dvlab

cibar accuracy if fake==1 & (dem_leaners==1 | repub_leaners==1), over1(tips) over2(dv) bargap(8) gap(35) graphopts(graphregion(fcolor(white) ifcolor(none)) plotregion(fcolor(none) lcolor(white) ifcolor(none) ilcolor(none)) ytitle("") scheme(lean1) yscale(r(1 4.1)) ylab(1 "Not at all accurate" 2 "Not very accurate" 3 "Somewhat accurate" 4 "Very accurate",angle(0) grid glcolor(gs3)) legend(row(1) pos(6) region(lpattern(solid) lcolor(black))))
graph export "accuracy-fake-tips-dv.pdf",replace

outsheet caseid accuracy fake hyper real dem_leaners repub_leaners tips congenial crt_terc dv using "andy-wave1.csv", comma replace

*fb_use
reg mean_acc_diff fbuse_terc##tips i.dv, robust cluster(caseid)
reg accuracy fbuse_terc##tips i.dv, robust cluster(caseid)
reg accuracy fbuse_terc##tips i.dv  if fake==1, robust cluster(caseid)
reg accuracy fbuse_terc##tips i.dv  if hyper==1, robust cluster(caseid)
reg accuracy fbuse_terc##tips i.dv  if real==1, robust cluster(caseid)

*fb_trust
reg mean_acc_diff fbtrust_terc##tips i.dv, robust cluster(caseid)
reg accuracy fbtrust_terc##tips i.dv, robust cluster(caseid)
reg accuracy fbtrust_terc##tips i.dv  if fake==1, robust cluster(caseid)
reg accuracy fbtrust_terc##tips i.dv  if hyper==1, robust cluster(caseid)
reg accuracy fbtrust_terc##tips i.dv  if real==1, robust cluster(caseid)

*fb_pol_use
reg mean_acc_diff fbpol_terc##tips i.dv, robust cluster(caseid)
reg accuracy fbpol_terc##tips i.dv, robust cluster(caseid)
reg accuracy fbpol_terc##tips i.dv  if fake==1, robust cluster(caseid)
reg accuracy fbpol_terc##tips i.dv  if hyper==1, robust cluster(caseid)
reg accuracy fbpol_terc##tips i.dv  if real==1, robust cluster(caseid)

*fN consumption FC consumption**

**unbalanced on media trust
reg media_trust tips, robust 
*control for mediatrust// all good
reg mean_acc_diff tips massmedia_trust, robust cluster(caseid)
reg accuracy tips i.dv massmedia_trust if fake==1, robust cluster(caseid)
reg accuracy tips i.dv massmedia_trust if real==1, robust cluster(caseid)
reg accuracy tips i.dv massmedia_trust if hyper==1, robust cluster(caseid)


**check source fam interaction 
/*pro d real 
9 = a_series_of_suspicious_png, 	LOW
10 = a_border_patrol_png, 			LOW
11 = detention_of_migrant__png 		HIGH
12 = and_now_its_the_tallest_png	HIGH
*proR real 
13 = google_employees_png, 			LOW
14 = feds_said_alleged_png, 		LOW
15 = small_busisness_optimism_ , 	HIGH
16 = economy_adds_more_png			HIGH */

gen lowfam = (dv==13 | dv==24 | dv==9 | dv==10 )
gen highfam = (dv==11 | dv==12 | dv==15 | dv==16)

reg accuracy tips##lowfam i.dv if real==1, robust cluster(caseid)
cibar accuracy, over1(tips) over2(lowfam) graphopts(title("Accuracy over 'tips' over 'lowfam'") name(graph_1, replace))


**tips  effect on sharing w1 (needs moved somewhere)
reg share_all_mean tips i.dv if fake==1, robust cluster(caseid)
estimates store sharefakew1, title(Tips effect on sharing fake news w1) 
reg share_all_mean tips i.dv if real==1, robust cluster(caseid)
estimates store sharerealw1, title(Tips effect on sharing real news w1) 
reg share_fake_mean tips i.dv, robust cluster(caseid)
reg share_real_mean tips i.dv, robust cluster(caseid)

/*H-A2) People who consume fake news will be more likely to believe it is accurate than those who do not consume fake news (H-A2a). This relationship will be stronger for pro-attitudinal fake news belief than for counter-attitudinal fake news belief (H-A2b) and for people who are relatively less skilled at analytical reasoning (H-A2c). 

H-A2a: Fake news accuracy = [constant] + prior fake news exposure + covariates listed above
H-A2b: Fake news accuracy = [constant] + prior fake news exposure + congenial + prior fake + news exposure * congenial + covariates listed above
H-A2c: Fake news accuracy = [constant] + prior fake news exposure + CRT score + prior fake + news exposure * CRT score + covariates listed above*/

/*note: prereg ambiguous about whether we need to run for binary version but including since we’re doing that when fake news is a DV*/

/*note: can’t cluster with survey weights so omitting, might want to do robustness check with weights and no clustering - e.g., with respondent fixed effects or random effects or something*/

*2018 defs
reg accuracy totalfakecount18 dem_leaners repub_leaners polknow polint college female nonwhite ib1.agecat i.dv if fake==1, robust cluster(caseid)
reg accuracy totalfakebinary18 dem_leaners repub_leaners polknow polint college female nonwhite ib1.agecat i.dv if fake==1, robust cluster(caseid)
/*
*2016 defs
reg accuracy totalfakenewscount_pre dem_leaners repub_leaners polknow polint college female nonwhite ib1.agecat i.dv if fake==1, robust cluster(caseid)
reg accuracy totalfakenewsbinary_pre dem_leaners repub_leaners polknow polint college female nonwhite ib1.agecat i.dv if fake==1, robust cluster(caseid)

*exploratory with decile
reg accuracy i.decile_pre dem_leaners repub_leaners polknow polint college female nonwhite ib1.agecat i.dv if fake==1, robust cluster(caseid)
reg accuracy i.decile_pre dem_leaners repub_leaners polknow polint college female nonwhite ib1.agecat i.dv if fake==1, robust cluster(caseid)

*exploratory real
reg accuracy totalfakenewscount_pre dem_leaners repub_leaners polknow polint college female nonwhite ib1.agecat i.dv if real==1, robust cluster(caseid)
reg accuracy totalfakenewsbinary_pre dem_leaners repub_leaners polknow polint college female nonwhite ib1.agecat i.dv if real==1, robust cluster(caseid)

/*what we say about congeniality:
Congeniality: We coded news content as pro-Republican or pro-Democrat; we cross this coding with a measure of respondent partisanship to determine if content is congenial (1) or uncongenial (0). (Models including measures of whether content is congenial will omit pure independents for whom this variable is undefined. To provide a strict comparison, we will sometimes estimate main effects models for the set of partisans included in these models.)*/

/*note: can’t cluster with survey weights so omitting, might want to do robustness check with weights and no clustering - e.g., with respondent fixed effects or random effects or something*/

*2018 defs
reg accuracy c.totalfakecount18##i.congenial repub_leaners polknow polint college female nonwhite ib1.agecat if fake==1 & independent==0, robust cluster(caseid)
estimates store acc_correlatespost_count, title(acc_correlatespost_count) 
reg accuracy totalfakebinary18##i.congenial repub_leaners polknow polint college female nonwhite ib1.agecat if fake==1 & independent==0, robust cluster(caseid)
estimates store acc_correlatespost_binary, title(acc_correlatespost_binary) 

/*
*2016 defs
reg accuracy c.totalfakenewscount_pre##i.congenial repub_leaners polknow polint college female nonwhite ib1.agecat if fake==1 & independent==0, robust cluster(caseid)
reg accuracy totalfakenewsbinary_pre##i.congenial repub_leaners polknow polint college female nonwhite ib1.agecat if fake==1 & independent==0, robust cluster(caseid)
*to avoid sample changing within multi-column table, have to run other models on this group too FWIW. (or we code congeniality as 0 for independents but that's ill-defined and exploratory.)*/

*2018 defs
reg accuracy c.totalfakecount18##i.crt_terc dem_leaners repub_leaners polknow polint college female nonwhite ib1.agecat if fake==1, robust cluster(caseid)
reg accuracy c.totalfakebinary18##i.crt_terc dem_leaners repub_leaners polknow polint college female nonwhite ib1.agecat if fake==1, robust cluster(caseid)
/*
*2016 defs
reg accuracy c.totalfakenewscount_pre##i.crt_terc dem_leaners repub_leaners polknow polint college female nonwhite ib1.agecat if fake==1, robust cluster(caseid)
reg accuracy c.totalfakenewsbinary_pre##i.crt_terc dem_leaners repub_leaners polknow polint college female nonwhite ib1.agecat if fake==1, robust cluster(caseid)
*/
/*
*descriptive graphs

label def fndef 0 "No fake news" 1 "Fake news"
label val totalfakenewsbinary_pre fndef
label val totalfakebinary18_pre fndef

gen bs=1

cibar accuracy [pweight=weight] if fake==1,over1(totalfakenewsbinary_pre) bargap(8) gap(35) graphopts(graphregion(fcolor(white) ifcolor(none)) plotregion(fcolor(none) lcolor(white) ifcolor(none) ilcolor(none)) ytitle("") scheme(lean1) yscale(r(1 4.1)) ylab(1 "Not at all accurate" 2 "Not very accurate" 3 "Somewhat accurate" 4 "Very accurate",angle(0) grid glcolor(gs3)) legend(row(1) pos(6) region(lpattern(solid) lcolor(black))) )
graph export "accuracy-priorfake.pdf", replace

cibar accuracy [pweight=weight] if fake==1,over1(totalfakenewsbinary_pre) bargap(8) gap(35) over2(congenial) graphopts(graphregion(fcolor(white) ifcolor(none)) plotregion(fcolor(none) lcolor(white) ifcolor(none) ilcolor(none)) ytitle("") scheme(lean1) yscale(r(1 4.1)) ylab(1 "Not at all accurate" 2 "Not very accurate" 3 "Somewhat accurate" 4 "Very accurate",angle(0) grid glcolor(gs3)) legend(row(1) pos(6) region(lpattern(solid) lcolor(black))) )
graph export "accuracy-priorfake-congenial.pdf", replace

cibar accuracy [pweight=weight] if fake==1,over1(totalfakebinary18_pre) bargap(8) gap(35) graphopts(graphregion(fcolor(white) ifcolor(none)) plotregion(fcolor(none) lcolor(white) ifcolor(none) ilcolor(none)) ytitle("") scheme(lean1) yscale(r(1 4.1)) ylab(1 "Not at all accurate" 2 "Not very accurate" 3 "Somewhat accurate" 4 "Very accurate",angle(0) grid glcolor(gs3)) legend(row(1) pos(6) region(lpattern(solid) lcolor(black))) )
graph export "accuracy-priorfake-newdvs.pdf", replace

cibar accuracy [pweight=weight] if fake==1,over1(totalfakebinary18_pre) bargap(8) gap(35) over2(congenial) graphopts(graphregion(fcolor(white) ifcolor(none)) plotregion(fcolor(none) lcolor(white) ifcolor(none) ilcolor(none)) ytitle("") scheme(lean1) yscale(r(1 4.1)) ylab(1 "Not at all accurate" 2 "Not very accurate" 3 "Somewhat accurate" 4 "Very accurate",angle(0) grid glcolor(gs3)) legend(row(1) pos(6) region(lpattern(solid) lcolor(black))) )
graph export "accuracy-priorfake-congenial-newdvs.pdf", replace
*/

restore


/*We also expect that people who consume fake news will be less likely to successfully distinguish between true and false headlines (H-A2d).
For H-A2d, the outcome measure = (mean perceived accuracy of real news headlines - mean perceived accuracy of fake news headlines). This hypothesis is measured at the respondent
level using a single mean difference that is not ordered and thus we will only test it using OLS with robust standard errors (i.e., no question fixed effects or clustering).*/

*2018 defs
svy: reg mean_acc_diff totalfakecount18_pre dem_leaners repub_leaners polknow polint college female nonwhite ib1.agecat 
svy: reg mean_acc_diff totalfakebinary18_pre dem_leaners repub_leaners polknow polint college female nonwhite ib1.agecat 

*2016 defs
svy: reg mean_acc_diff totalfakenewscount_pre dem_leaners repub_leaners polknow polint college female nonwhite ib1.agecat 
svy: reg mean_acc_diff totalfakenewsbinary_pre dem_leaners repub_leaners polknow polint college female nonwhite ib1.agecat 

*exploratory
reg mean_acc_diff totalfakenewscount_pre dem_leaners repub_leaners polknow polint college female nonwhite ib1.agecat, robust
reg mean_acc_diff totalfakenewsbinary_pre dem_leaners repub_leaners polknow polint college female nonwhite ib1.agecat, robust

svy: reg accuracy_real_mean totalfakenewscount_pre dem_leaners repub_leaners polknow polint college female nonwhite ib1.agecat 
svy: reg accuracy_real_mean totalfakenewsbinary_pre dem_leaners repub_leaners polknow polint college female nonwhite ib1.agecat 

*depends on survey weights or not
svy: reg accuracy_fake_mean totalfakenewscount_pre dem_leaners repub_leaners polknow polint college female nonwhite ib1.agecat 
svy: reg accuracy_fake_mean totalfakenewsbinary_pre dem_leaners repub_leaners polknow polint college female nonwhite ib1.agecat 

reg accuracy_fake_mean totalfakenewscount_pre dem_leaners repub_leaners polknow polint college female nonwhite ib1.agecat, robust
reg accuracy_fake_mean totalfakenewsbinary_pre dem_leaners repub_leaners polknow polint college female nonwhite ib1.agecat, robust
*/
*separate reshape for w2 accuracy ratings

restore

preserve

*tips on diff pre-reshape
reg mean_acc_diffw2 tips, robust 
estimates store t4c6, title(Tips effect on fake-real w2) 

**tips effects at w2 (without saw) with LASSO

reg mean_acc_diffw2 tips polknow polint FT_trump  affect_merged_leanersw1 conspiracy_mean, robust 
estimates store tA4c6, title(Tips effect on fake-real w2) 

/*w2 reshape*/

*accuracy reshape
rename accuracy_donald_trump_caughtw2 accuracyw21
rename accuracy_franklin_grahamw2 accuracyw22
rename accuracy_vp_mike_pencew2 accuracyw23
rename accuracy_vice_president_pencew2 accuracyw24
rename accuracy_soros_money_behindw2 accuracyw25
rename accuracy_kavanaugh_accuserw2 accuracyw26
rename accuracy_fbi_agent_whow2 accuracyw27
rename accuracy_lisa_pagew2 accuracyw28
rename accuracy_a_series1w2 accuracyw29
rename accuracy_a_border_patrolw2 accuracyw210
rename accuracy_detention_of_migrantw2 accuracyw211
rename accuracy_and_now1w2 accuracyw212
rename accuracy_google_employeesw2 accuracyw213
rename accuracy_feds_said_allegedw2 accuracyw214
rename accuracy_small_busisness_optw2 accuracyw215
rename accuracy_economy_adds_morew2 accuracyw216

svyset [pweight=weight]

forval i=1/16 {
svy: tab accuracyw2`i'
}

reshape long accuracyw2,i(caseid) j(dv)

gen fake=(dv==3 | dv==4 | dv==7 | dv==8)
gen real=(dv>8 & dv<17)
gen hyper=(dv==1 | dv==2 | dv==5 | dv==6)

/*
*2018 defs
reg accuracyw2 totalfakecount18_pre dem_leaners repub_leaners polknow polint college female nonwhite ib1.agecat i.dv if fake==1, robust cluster(caseid)
reg accuracyw2 totalfakebinary18_pre dem_leaners repub_leaners polknow polint college female nonwhite ib1.agecat i.dv if fake==1, robust cluster(caseid)

*2016 defs
reg accuracyw2 totalfakenewscount_pre dem_leaners repub_leaners polknow polint college female nonwhite ib1.agecat i.dv if fake==1, robust cluster(caseid)
reg accuracyw2 totalfakenewsbinary_pre dem_leaners repub_leaners polknow polint college female nonwhite ib1.agecat i.dv if fake==1, robust cluster(caseid)

*exploratory with decile
reg accuracyw2 i.decile_pre dem_leaners repub_leaners polknow polint college female nonwhite ib1.agecat i.dv if fake==1, robust cluster(caseid)
reg accuracyw2 i.decile_pre dem_leaners repub_leaners polknow polint college female nonwhite ib1.agecat i.dv if fake==1, robust cluster(caseid)

/*what we say about congeniality:
Congeniality: We coded news content as pro-Republican or pro-Democrat; we cross this coding with a measure of respondent partisanship to determine if content is congenial (1) or uncongenial (0). (Models including measures of whether content is congenial will omit pure independents for whom this variable is undefined. To provide a strict comparison, we will sometimes estimate main effects models for the set of partisans included in these models.)*/

/*note: can’t cluster with survey weights so omitting, might want to do robustness check with weights and no clustering - e.g., with respondent fixed effects or random effects or something*/

*2018 defs
reg accuracyw2 c.totalfakecount18_pre##i.congenial repub_leaners polknow polint college female nonwhite ib1.agecat if fake==1 & independent==0, robust cluster(caseid)
reg accuracyw2 totalfakebinary18_pre##i.congenial repub_leaners polknow polint college female nonwhite ib1.agecat if fake==1 & independent==0, robust cluster(caseid)

*2016 defs
reg accuracyw2 c.totalfakenewscount_pre##i.congenial repub_leaners polknow polint college female nonwhite ib1.agecat if fake==1 & independent==0, robust cluster(caseid)
reg accuracyw2 totalfakenewsbinary_pre##i.congenial repub_leaners polknow polint college female nonwhite ib1.agecat if fake==1 & independent==0, robust cluster(caseid)

*to avoid sample changing within multi-column table, have to run other models on this group too FWIW. (or we code congeniality as 0 for independents but that's ill-defined and exploratory.)*/
/*
*2018 defs
reg accuracyw2 c.totalfakecount18_pre##i.crt_terc dem_leaners repub_leaners polknow polint college female nonwhite ib1.agecat if fake==1, robust cluster(caseid)
reg accuracyw2 c.totalfakebinary18_pre##i.crt_terc dem_leaners repub_leaners polknow polint college female nonwhite ib1.agecat if fake==1, robust cluster(caseid)

*2016 defs
reg accuracyw2 c.totalfakenewscount_pre##i.crt_terc dem_leaners repub_leaners polknow polint college female nonwhite ib1.agecat if fake==1, robust cluster(caseid)
reg accuracyw2 c.totalfakenewsbinary_pre##i.crt_terc dem_leaners repub_leaners polknow polint college female nonwhite ib1.agecat if fake==1, robust cluster(caseid)
*/

gen accuracy_donald_caught = accuracy_donald_trump_caught
gen accuracy_small_bus = accuracy_small_busisness_opt
gen accuracy_soros_money = accuracy_soros_money_behind


foreach var of varlist accuracy_vp_mike_pence accuracy_fbi_agent_who accuracy_lisa_page accuracy_a_series1 accuracy_a_border_patrol accuracy_and_now1 accuracy_google_employees accuracy_feds_said_alleged accuracy_small_busisness_opt accuracy_economy_adds_more accuracy_donald_caught accuracy_franklin_graham accuracy_soros_money accuracy_kavanaugh_accuser {
gen saw_`var'=(`var'!=.)
}

gen saw_acc_vice_president_pence=(accuracy_vice_president_pence!=.)
gen saw_acc_detention_of_migrant=(accuracy_detention_of_migrant!=.)

gen saw=0
replace saw=1 if (dv==1 & saw_accuracy_donald_caught==1) | (dv==2 & saw_accuracy_franklin_graham==1) | (dv==3 & saw_accuracy_vp_mike_pence==1) | (dv==4 & saw_acc_vice_president_pence==1) | (dv==5 & saw_accuracy_soros_money==1) | (dv==6 & saw_accuracy_kavanaugh_accuser==1) | (dv==7 & saw_accuracy_fbi_agent_who==1) | (dv==8 & saw_accuracy_lisa_page==1) |  (dv==9 & saw_accuracy_a_series==1) | (dv==10 & saw_accuracy_a_border_patrol==1) | (dv==11 & saw_acc_detention_of_migrant==1) | (dv==12 & saw_accuracy_and_now1==1) | (dv==13 & saw_accuracy_google_employees==1) | (dv==14 & saw_accuracy_feds_said_alleged==1) | (dv==15 & saw_accuracy_small_bus==1) | (dv==16 & saw_accuracy_economy_adds_more==1)

/*congeniality coding has to be here*/

**october headline codes
*pro-D hyper 1 = donald_trump_caught_png, 2 = franklin_graham_png
*pro-D fake 3 = vp_mike_pence_png 4 = vice_president_pence_png
*proR hyper 5 = soros_money_behind_png, 6 = kavanaugh_accuser_png
*proR fake 7 = fbi_agent_who_png, 8 = lisa_page_png
*pro d real 9 = a_series_of_suspicious_png, 10 = a_border_patrol_png, 11 = detention_of_migrant__png 12 = and_now_its_the_tallest_png
*proR real 13 = google_employees_png, 14 = feds_said_alleged_png, 15 = small_busisness_optimism_ , 16 = economy_adds_more_png

gen pro_d=(dv==1 | dv==2 | dv==3 | dv==4 | dv==9 | dv==10 | dv==11 | dv==12)
gen pro_r=(dv==5 | dv==6 | dv==7 | dv==8 | dv==13 | dv==14 | dv==15 | dv==16)
gen congenial=(pro_d==1 & dem_leaner==1) | (pro_r==1 & repub_leaner==1)
gen uncongenial=(pro_r==1 & dem_leaner==1) | (pro_d==1 & repub_leaner==1)

gen binary_accuracyw2=(accuracyw2>2 & accuracyw2<5)

**t1 mpsa
reg accuracyw2 congenial uncongenial crt_average saw tips polknow polint college female nonwhite ib1.agecat i.dv if fake==1, robust cluster(caseid)
estimates store acc_corrw2post, title(acc_corrpost2) 

lincom congenial-uncongenial

*preserve
*collapse (mean) accuracyw2 binary_accuracyw2 [pweight=weight],by(fake real hyper)
*sort fake real hyper
*list
*restore

gen type=.
replace type=1 if fake==1
replace type=2 if hyper==1
replace type=3 if real==1

label def typelab 1 "Fake news" 2 "Hyper-partisan news" 3 "Real news"
label val type typelab

cibar binary_accuracyw2 [pweight=weight], over1(type) bargap(8) gap(35) graphopts(graphregion(fcolor(white) ifcolor(none)) plotregion(fcolor(none) lcolor(white) ifcolor(none) ilcolor(none)) legend(row(1) pos(6) region(lpattern(solid) lcolor(black)))  ytitle("") scheme(lean1) yscale(r(0 .61)) ylab(0 "0%" .1 "10%" .2 "20%" .3 "30%" .4 "40%" .5 "50%" .6 "60%",angle(0) grid glcolor(gs3)))
graph export "accuracyw2-type-binary.pdf",replace

cibar accuracyw2 [pweight=weight], over1(type) bargap(8) gap(35) graphopts(graphregion(fcolor(white) ifcolor(none)) plotregion(fcolor(none) lcolor(white) ifcolor(none) ilcolor(none)) legend(row(1) pos(6) region(lpattern(solid) lcolor(black)))  ytitle("") scheme(lean1) yscale(r(1 4.1)) ylab(1 "Not at all accurate" 2 "Not very accurate" 3 "Somewhat accurate" 4 "Very accurate",angle(0) grid glcolor(gs3)))
graph export "accuracyw2-type.pdf",replace

label def conglab 0 "Uncongenial" 1 "Congenial"
label val congenial conglab

*preserve
*collapse (mean) accuracy binary_accuracy [pweight=weight] if independents==0,by(fake real hyper)
*sort fake real hyper 
*list
*restore

cibar accuracyw2 [pweight=weight] if independents==0, over1(congenial) over2(type) bargap(8) gap(35) graphopts(graphregion(fcolor(white) ifcolor(none)) plotregion(fcolor(none) lcolor(white) ifcolor(none) ilcolor(none)) legend(row(1) pos(6) region(lpattern(solid) lcolor(black))) yscale(r(1 4.1)) ytitle("") scheme(lean1) ylab(1 "Not at all accurate" 2 "Not very accurate" 3 "Somewhat accurate" 4 "Very accurate",angle(0) grid glcolor(gs3)))
graph export "accuracyw2-type-congenial.pdf",replace

cibar binary_accuracyw2 [pweight=weight] if independents==0, over1(congenial) over2(type) bargap(8) gap(35) graphopts(graphregion(fcolor(white) ifcolor(none)) plotregion(fcolor(none) lcolor(white) ifcolor(none) ilcolor(none)) legend(row(1) pos(6) region(lpattern(solid) lcolor(black))) yscale(r(0 .51)) ytitle("") yscale(r(0 .71)) scheme(lean1) ylab(0 "0%" .1 "10%" .2 "20%" .3 "30%" .4 "40%" .5 "50%" .5 "50%" .6 "60%" .7 "70%",angle(0) grid glcolor(gs3)))
graph export "accuracyw2-type-congenial-binary.pdf",replace

cibar binary_accuracyw2 [pweight=weight] if independents==0 & dem_lean==1, over1(congenial) over2(type) bargap(8) gap(35) graphopts(graphregion(fcolor(white) ifcolor(none)) plotregion(fcolor(none) lcolor(white) ifcolor(none) ilcolor(none)) legend(row(1) pos(6) region(lpattern(solid) lcolor(black))) yscale(r(0 .51)) ytitle("") yscale(r(0 .71)) scheme(lean1) ylab(0 "0%" .1 "10%" .2 "20%" .3 "30%" .4 "40%" .5 "50%" .5 "50%" .6 "60%" .7 "70%",angle(0) grid glcolor(gs3)))
graph export "accuracyw2-type-congenial-binary-dem.pdf",replace

cibar binary_accuracyw2 [pweight=weight] if independents==0 & repub_lean==1, over1(congenial) over2(type) bargap(8) gap(35) graphopts(graphregion(fcolor(white) ifcolor(none)) plotregion(fcolor(none) lcolor(white) ifcolor(none) ilcolor(none)) legend(row(1) pos(6) region(lpattern(solid) lcolor(black))) yscale(r(0 .51)) ytitle("") yscale(r(0 .71)) scheme(lean1) ylab(0 "0%" .1 "10%" .2 "20%" .3 "30%" .4 "40%" .5 "50%" .6 "60%" .7 "70%",angle(0) grid glcolor(gs3)))
graph export "accuracyw2-type-congenial-binary-rep.pdf",replace

label def sawlab 0 "Not seen" 1 "Previously seen"
label val saw sawlab

cibar accuracyw2 [pweight=weight], over1(saw) over2(type) bargap(8) gap(35) graphopts(graphregion(fcolor(white) ifcolor(none)) plotregion(fcolor(none) lcolor(white) ifcolor(none) ilcolor(none)) legend(row(1) pos(6) region(lpattern(solid) lcolor(black))) yscale(r(1 4.1)) ytitle("") scheme(lean1) ylab(1 "Not at all accurate" 2 "Not very accurate" 3 "Somewhat accurate" 4 "Very accurate",angle(0) grid glcolor(gs3)))
graph export "accuracyw2-type-saw.pdf",replace

cibar binary_accuracyw2 [pweight=weight], over1(saw) over2(type) bargap(8) gap(35) graphopts(graphregion(fcolor(white) ifcolor(none)) plotregion(fcolor(none) lcolor(white) ifcolor(none) ilcolor(none)) legend(row(1) pos(6) region(lpattern(solid) lcolor(black))) yscale(r(0 .51)) ytitle("") yscale(r(0 .71)) scheme(lean1) ylab(0 "0%" .1 "10%" .2 "20%" .3 "30%" .4 "40%" .5 "50%" .5 "50%" .6 "60%" .7 "70%",angle(0) grid glcolor(gs3)))
graph export "accuracyw2-type-saw-binary.pdf",replace


**prior exposure effect
reg accuracyw2 saw i.dv, robust cluster(caseid)
reg accuracyw2 saw i.dv if fake==1, robust cluster(caseid)
estimates store t3c5, title(prior exposure effect on fake news) 
reg accuracyw2 saw i.dv if hyper==1, robust cluster(caseid)
reg accuracyw2 saw i.dv if real==1, robust cluster(caseid)
estimates store t3c6, title(prior exposure effect on real news) 

**prior exposure with LASSO
reg accuracyw2 saw polknow polint FT_trump  affect_merged_leanersw1 conspiracy_mean i.dv, robust cluster(caseid)
reg accuracyw2 saw polknow polint FT_trump  affect_merged_leanersw1 conspiracy_mean i.dv if fake==1, robust cluster(caseid)
estimates store tA3c5, title(prior exposure effect on fake news) 
reg accuracyw2 saw polknow polint FT_trump  affect_merged_leanersw1 conspiracy_mean i.dv if hyper==1, robust cluster(caseid)
reg accuracyw2 saw polknow polint FT_trump  affect_merged_leanersw1 conspiracy_mean i.dv if real==1, robust cluster(caseid)
estimates store tA3c6, title(prior exposure effect on real news) 



/*
RQ-D1. Does exposure to the news tips intervention affect perceived accuracy of fake news story repeated in Wave 2? 
RQ-D2-D5. Are any main effects of the news tips intervention on belief in real news (RQ-D2), fake news (RQ-D3), the ability of people to distinguish between real and fake news (RQ-D4), and on belief in hyperpartisan news (RQ-D5) measurable in wave 2?

For H-D1, RQ-D1, and RQ-D2, the outcome measure is the perceived accuracy of fake headlines in Wave 2.  
For H-D2 and RQ-D3, the outcome measure is the perceived accuracy of real headlines
For H-D3 and RQ-D4, the outcome measure is the perceived accuracy of hyper-partisan headlines.
To test the effects of wave 1 exposure (H-D1-H-D3)
Outcome = [constant] + wave 1 exposure 
For RQ-D1, the the outcome measure is the perceived accuracy of fake headlines in Wave 2, but we will test if the treatment is moderated by exposure to the news tips in Wave 1.
Outcome = [constant] + wave 1 exposure + News tips + wave 1*News tips
For the question-level hypotheses RQ-D2, RQ-D3, and RQ-D5, we will estimate the following model using OLS regression (with robustness checks using ordered probit as appropriate):
Outcome = [constant] + News tips
For RQ-D4, the outcome measure = (mean perceived accuracy of real news - mean perceived accuracy of fake news). This hypothesis is measured at the respondent level using a single mean difference that is not ordered and thus we will only test it using OLS with robust standard errors (i.e., no question fixed effects or clustering).
Outcome = [constant] + News tips */

**saw x tips
reg accuracyw2 saw##tips i.dv, robust cluster(caseid)
reg accuracyw2 saw##tips i.dv  if fake==1, robust cluster(caseid)
estimates store tips_prior_fake, title(tips prior exposure effect on fake news) 
reg accuracyw2 saw##tips i.dv  if hyper==1, robust cluster(caseid)
reg accuracyw2 saw##tips i.dv  if real==1, robust cluster(caseid)
estimates store tips_prior_real, title(tips prior exposure effect on real news) 

**t1 mpsa
reg accuracyw2 congenial uncongenial crt_average saw tips polknow polint college female nonwhite ib1.agecat i.dv if fake==1, robust cluster(caseid)
estimates store acc_corrw2post, title(acc_corr2post)

**saw x tips with LASSO
reg accuracyw2 saw##tips polknow polint FT_trump  affect_merged_leanersw1 conspiracy_mean i.dv, robust cluster(caseid)
reg accuracyw2 saw##tips polknow polint FT_trump  affect_merged_leanersw1 conspiracy_mean i.dv  if fake==1, robust cluster(caseid)
reg accuracyw2 saw##tips polknow polint FT_trump  affect_merged_leanersw1 conspiracy_mean i.dv  if hyper==1, robust cluster(caseid)
reg accuracyw2 saw##tips polknow polint FT_trump  affect_merged_leanersw1 conspiracy_mean i.dv  if real==1, robust cluster(caseid)


**tips effects at w2 (without saw)
reg accuracyw2 tips i.dv, robust cluster(caseid)
reg accuracyw2 tips i.dv  if fake==1, robust cluster(caseid)
estimates store t4c2, title(Tips effect on fake news w2) 
reg accuracyw2 tips i.dv  if hyper==1, robust cluster(caseid)
estimates store tips_hyperw2, title(Tips effect on hyper accuracy w2)
reg accuracyw2 tips i.dv  if real==1, robust cluster(caseid)
estimates store t4c4, title(Tips effect on real news w2) 
*reg mean_acc_diffw2 tips i.dv, robust cluster(caseid)
*estimates store t4c6, title(Tips effect on fake-real w2) 

**tips effects at w2 (without saw) with LASSO
reg accuracyw2 tips polknow polint FT_trump  affect_merged_leanersw1 conspiracy_mean i.dv, robust cluster(caseid)
reg accuracyw2 tips polknow polint FT_trump  affect_merged_leanersw1 conspiracy_mean i.dv  if fake==1, robust cluster(caseid)
estimates store tA4c2, title(Tips effect on fake news w2) 
reg accuracyw2 tips polknow polint FT_trump  affect_merged_leanersw1 conspiracy_mean i.dv  if hyper==1, robust cluster(caseid)
reg accuracyw2 tips polknow polint FT_trump affect_merged_leanersw1 conspiracy_mean i.dv  if real==1, robust cluster(caseid)
estimates store tA4c4, title(Tips effect on real news w2) 
*reg mean_acc_diffw2 tips polknow polint FT_trump  affect_merged_leanersw1 conspiracy_mean i.dv, robust cluster(caseid)
*estimates store tA4c6, title(Tips effect on fake-real w2) 

reg accuracyw2 tips##type saw i.dv if real==1 | fake==1 | hyper==1, robust cluster(caseid)

**tips x congeial at w2
reg mean_acc_diffw2  congenial##tips i.dv, robust cluster(caseid)
reg accuracyw2 congenial##tips i.dv, robust cluster(caseid)
reg accuracyw2 congenial##tips i.dv  if fake==1, robust cluster(caseid)
estimates store congenial_fakew2, title(Tipsxcong effect on fake w2) 
reg accuracyw2 congenial##tips i.dv  if hyper==1, robust cluster(caseid)
reg accuracyw2 congenial##tips i.dv  if real==1, robust cluster(caseid)
estimates store congenial_realw2, title(Tipsxcong effect on real w2) 

**tips x congeial at w2 with LASSO
reg mean_acc_diffw2  congenial##tips polknow polint FT_trump  affect_merged_leanersw1 conspiracy_mean i.dv, robust cluster(caseid)
reg accuracyw2 congenial##tips polknow polint FT_trump  affect_merged_leanersw1 conspiracy_mean i.dv, robust cluster(caseid)
reg accuracyw2 congenial##tips polknow polint FT_trump  affect_merged_leanersw1 conspiracy_mean i.dv  if fake==1, robust cluster(caseid)
reg accuracyw2 congenial##tips polknow polint FT_trump affect_merged_leanersw1 conspiracy_mean i.dv  if hyper==1, robust cluster(caseid)
reg accuracyw2 congenial##tips polknow polint FT_trump  affect_merged_leanersw1 conspiracy_mean i.dv  if real==1, robust cluster(caseid)

**tips x CRT at w2

reg mean_acc_diffw2 c.crt_average##tips i.dv, robust cluster(caseid)
reg accuracyw2 c.crt_average##tips i.dv, robust cluster(caseid)
reg accuracyw2 c.crt_average##tips i.dv  if fake==1, robust cluster(caseid)
estimates store crt_fakew2, title(crt fakew2) 
reg accuracyw2 c.crt_average##tips i.dv  if hyper==1, robust cluster(caseid)
reg accuracyw2 c.crt_average##tips i.dv  if real==1, robust cluster(caseid)
estimates store crt_realw2, title(crt realw2) 

**tips x CRT at w2 with LASSO
reg mean_acc_diffw2  c.crt_average##tips polknow polint FT_trump  affect_merged_leanersw1 conspiracy_mean i.dv, robust cluster(caseid)
reg accuracyw2 c.crt_average##tips polknow polint FT_trump  affect_merged_leanersw1 conspiracy_mean i.dv, robust cluster(caseid)
reg accuracyw2 c.crt_average##tips polknow polint FT_trump  affect_merged_leanersw1 conspiracy_mean i.dv  if fake==1, robust cluster(caseid)
reg accuracyw2 c.crt_average##tips polknow polint FT_trump  affect_merged_leanersw1 conspiracy_mean i.dv  if hyper==1, robust cluster(caseid)
reg accuracyw2 c.crt_average##tips polknow polint FT_trump  affect_merged_leanersw1 conspiracy_mean i.dv  if real==1, robust cluster(caseid)


**tips effect on sharing w2 (needs moved somewhere)
reg share_all_meanw2 tips i.dv if fake==1, robust cluster(caseid)
estimates store sharefakew2, title(Tips effect on sharing fake news w2) 
reg share_all_meanw2 tips i.dv if real==1, robust cluster(caseid)
estimates store sharerealw2, title(Tips effect on sharing real news w2) 
reg share_fake_meanw2 tips i.dv, robust cluster(caseid)
reg share_real_meanw2 tips i.dv, robust cluster(caseid)


**sharing diff w2
reg mean_share_diffw2 tips i.dv, robust cluster(caseid)
reg mean_share_diffw2 tips i.dv, robust cluster(caseid)
reg mean_share_diffw2 saw##tips i.dv, robust cluster(caseid)

**tips and prior exposure effect on sharing w2, control for media trust
reg mean_share_diff tips massmedia_trust i.dv, robust cluster(caseid)
reg mean_share_diffw2 tips massmedia_trust i.dv, robust cluster(caseid)
reg mean_share_diffw2 saw##tips massmedia_trust i.dv, robust cluster(caseid)

label def tipslab 0 "Control" 1 "Fake news tips"
label val tips tipslab

label def crtlabel2 1 "Low CRT" 2 "Medium CRT" 3 "High CRT"
label val crt_terc crtlabel2

cibar accuracyw2 if fake==1, over1(tips) bargap(8) gap(35) graphopts(graphregion(fcolor(white) ifcolor(none)) plotregion(fcolor(none) lcolor(white) ifcolor(none) ilcolor(none)) ytitle("") scheme(lean1) yscale(r(1 4.1)) ylab(1 "Not at all accurate" 2 "Not very accurate" 3 "Somewhat accurate" 4 "Very accurate",angle(0) grid glcolor(gs3)) legend(row(1) pos(6) region(lpattern(solid) lcolor(black))))
graph export "accuracy-fake-tips-w2.pdf",replace
cibar accuracyw2 if hyper==1, over1(tips) bargap(8) gap(35) graphopts(graphregion(fcolor(white) ifcolor(none)) plotregion(fcolor(none) lcolor(white) ifcolor(none) ilcolor(none)) ytitle("") scheme(lean1) yscale(r(1 4.1)) ylab(1 "Not at all accurate" 2 "Not very accurate" 3 "Somewhat accurate" 4 "Very accurate",angle(0) grid glcolor(gs3)) legend(row(1) pos(6) region(lpattern(solid) lcolor(black))))
graph export "accuracy-hyper-tips-w2.pdf",replace
cibar accuracyw2 if real==1, over1(tips) bargap(8) gap(35) graphopts(graphregion(fcolor(white) ifcolor(none)) plotregion(fcolor(none) lcolor(white) ifcolor(none) ilcolor(none)) ytitle("") scheme(lean1) yscale(r(1 4.1)) ylab(1 "Not at all accurate" 2 "Not very accurate" 3 "Somewhat accurate" 4 "Very accurate",angle(0) grid glcolor(gs3)) legend(row(1) pos(6) region(lpattern(solid) lcolor(black))))
graph export "accuracy-real-tips-w2.pdf",replace

cibar accuracyw2, over1(tips) over2(type) bargap(8) gap(35) graphopts(graphregion(fcolor(white) ifcolor(none)) plotregion(fcolor(none) lcolor(white) ifcolor(none) ilcolor(none)) ytitle("") scheme(lean1) yscale(r(1 4.1)) ylab(1 "Not at all accurate" 2 "Not very accurate" 3 "Somewhat accurate" 4 "Very accurate",angle(0) grid glcolor(gs3)) legend(row(1) pos(6) region(lpattern(solid) lcolor(black))))
graph export "accuracy-all-tips-w2.pdf",replace

cibar binary_accuracyw2, over1(tips) over2(type) bargap(8) gap(35) graphopts(graphregion(fcolor(white) ifcolor(none)) plotregion(fcolor(none) lcolor(white) ifcolor(none) ilcolor(none)) legend(row(1) pos(6) region(lpattern(solid) lcolor(black)))  ytitle("") scheme(lean1) yscale(r(0 .51)) ylab(0 "0%" .1 "10%" .2 "20%" .3 "30%" .4 "40%" .5 "50%",angle(0) grid glcolor(gs3)))
graph export "accuracy-all-tips-binary-w2.pdf",replace

cibar accuracyw2 if fake==1, over1(tips) over2(crt_terc) bargap(8) gap(35) graphopts(graphregion(fcolor(white) ifcolor(none)) plotregion(fcolor(none) lcolor(white) ifcolor(none) ilcolor(none)) ytitle("") scheme(lean1) yscale(r(1 4.1)) ylab(1 "Not at all accurate" 2 "Not very accurate" 3 "Somewhat accurate" 4 "Very accurate",angle(0) grid glcolor(gs3)) legend(row(1) pos(6) region(lpattern(solid) lcolor(black))))
graph export "accuracy-fake-tips-crt-w2.pdf",replace

cibar accuracyw2 if fake==1 & (dem_leaners==1 | repub_leaners==1), over1(tips) over2(congenial) bargap(8) gap(35) graphopts(graphregion(fcolor(white) ifcolor(none)) plotregion(fcolor(none) lcolor(white) ifcolor(none) ilcolor(none)) ytitle("") scheme(lean1) yscale(r(1 4.1)) ylab(1 "Not at all accurate" 2 "Not very accurate" 3 "Somewhat accurate" 4 "Very accurate",angle(0) grid glcolor(gs3)) legend(row(1) pos(6) region(lpattern(solid) lcolor(black))))
graph export "accuracy-fake-tips-congenial-w2.pdf",replace

cibar accuracyw2 if fake==1, over1(tips) over2(saw) bargap(8) gap(35) graphopts(graphregion(fcolor(white) ifcolor(none)) plotregion(fcolor(none) lcolor(white) ifcolor(none) ilcolor(none)) ytitle("") scheme(lean1) yscale(r(1 4.1)) ylab(1 "Not at all accurate" 2 "Not very accurate" 3 "Somewhat accurate" 4 "Very accurate",angle(0) grid glcolor(gs3)) legend(row(1) pos(6) region(lpattern(solid) lcolor(black))))
graph export "accuracy-fake-tips-saw-w2.pdf",replace

outsheet caseid accuracyw2 fake hyper real dem_leaners repub_leaners tips congenial saw crt_terc dv using "andy-wave2.csv", comma replace

*preserve
*collapse (mean) accuracyw2 binary_accuracyw2 [pweight=weight] if independents==0,by(fake real hyper congenial uncongenial)
*sort fake real hyper congenial
*list
*restore

/*
restore

*2018 defs
svy: reg mean_acc_diffw2 totalfakecount18_pre dem_leaners repub_leaners polknow polint college female nonwhite ib1.agecat 
svy: reg mean_acc_diffw2 totalfakebinary18_pre dem_leaners repub_leaners polknow polint college female nonwhite ib1.agecat 

*2016 defs
svy: reg mean_acc_diffw2 totalfakenewscount_pre dem_leaners repub_leaners polknow polint college female nonwhite ib1.agecat 
svy: reg mean_acc_diffw2 totalfakenewsbinary_pre dem_leaners repub_leaners polknow polint college female nonwhite ib1.agecat
 
preserve

*new reshape


*******topical misperception analyses****swap in climate BL**

*accuracy reshape
rename misinform_laugh topical_accuracy1
rename misinform_questioned topical_accuracy2
rename misinform_classmates topical_accuracy3
rename misinform_refuted topical_accuracy4

forval i=1/4 {
svy: tab topical_accuracy`i'
}

reshape long topical_accuracy,i(caseid) j(dv)

gen topical_false=(dv==3 | dv==4)
gen topical_pro_d=(dv==1 | dv==3)
gen topical_pro_r=(dv==2 | dv==4)

/*H-A3) People who consume fake news will be more likely to hold topical misperceptions than those who do not consume fake news (H-A3a). This relationship will be stronger for pro-attitudinal misperceptions than for counter-attitudinal misperceptions (H-A3b) and for people who are relatively less skilled at analytical reasoning (H-A3c). People who consume fake news will be less likely to successfully distinguish between true and false topical statements (H-A3d).

For H-A3a, H-A3b, and H-A3c, the outcome measure is the perceived accuracy of true and false topical statements. These models will be estimated separately for wave 1 and wave 2 topical misperceptions. For each of these types of statements in wave 1, we will estimate the following models:
H-A3a: Accuracy = [constant] + prior fake news exposure + covariates listed above
H-A3b: Accuracy = [constant] + prior fake news exposure + congenial + prior fake news exposure * congenial + covariates listed above
H-A3c: Accuracy = [constant] + prior fake news exposure + CRT score + prior fake news exposure * CRT score + covariates listed above*/

/*note: can’t cluster with survey weights so omitting, might want to do robustness check with weights and no clustering - e.g., with respondent fixed effects or random effects or something*/

*2018 defs
reg topical_accuracy totalfakecount18_pre dem_leaners repub_leaners polknow polint college female nonwhite ib1.agecat i.dv if topical_false==1, robust cluster(caseid)
reg topical_accuracy totalfakebinary18_pre dem_leaners repub_leaners polknow polint college female nonwhite ib1.agecat i.dv if topical_false==1, robust cluster(caseid)

*2016 defs
reg topical_accuracy totalfakenewscount_pre dem_leaners repub_leaners polknow polint college female nonwhite ib1.agecat i.dv if topical_false==1, robust cluster(caseid)
reg topical_accuracy totalfakenewsbinary_pre dem_leaners repub_leaners polknow polint college female nonwhite ib1.agecat i.dv if topical_false==1, robust cluster(caseid)

*omits independents again, see above

*2018 defs
reg topical_accuracy c.totalfakecount18_pre##i.congenial repub_leaners polknow polint college female nonwhite ib1.agecat if topical_false==1 & independents==0, robust cluster(caseid)
reg topical_accuracy totalfakebinary18_pre##i.congenial repub_leaners polknow polint college female nonwhite ib1.agecat if topical_false==1 & independents==0, robust cluster(caseid)

*2016 defs
reg topical_accuracy c.totalfakenewscount_pre##i.congenial repub_leaners polknow polint college female nonwhite ib1.agecat if topical_false==1 & independents==0, robust cluster(caseid)
reg topical_accuracy totalfakenewsbinary_pre##i.congenial repub_leaners polknow polint college female nonwhite ib1.agecat if topical_false==1 & independents==0, robust cluster(caseid)

*2018 defs
reg topical_accuracy c.totalfakecount18_pre##i.crt_terc dem_leaners repub_leaners polknow polint college female nonwhite ib1.agecat if topical_false==1, robust cluster(caseid)
reg topical_accuracy c.totalfakebinary18_pre##i.crt_terc dem_leaners repub_leaners polknow polint college female nonwhite ib1.agecat if topical_false==1, robust cluster(caseid)

*2016 defs
reg topical_accuracy c.totalfakenewscount_pre##i.crt_terc dem_leaners repub_leaners polknow polint college female nonwhite ib1.agecat if topical_false==1, robust cluster(caseid)
reg topical_accuracy c.totalfakenewsbinary_pre##i.crt_terc dem_leaners repub_leaners polknow polint college female nonwhite ib1.agecat if topical_false==1, robust cluster(caseid)

restore

*redo for w2 topical misperceptions here with separate reshape

preserve

***W2 topical misperceptions here **update with climate bl

**soros proR false
**jamal proD false
**see also alt question formats for soros and jamal: misinform_caravan_w2, misinform_killing_w2

*accuracy reshape
rename misinform_mock_w2 topical_accuracy1 /*direction ambiguous*/
rename misinform_police_w2 topical_accuracy2 
rename misinform_recall_w2 topical_accuracy3
rename misinform_refute_w2 topical_accuracy4

forval i=1/4 {
svy: tab topical_accuracy`i'
}

reshape long topical_accuracy,i(caseid) j(dv)

gen topical_false=(dv==3 | dv==4)
gen topical_pro_d=(dv==1 | dv==2 | dv==3) /*direction ambiguous*/
gen topical_pro_r=(dv==4)

/*H-A3) People who consume fake news will be more likely to hold topical misperceptions than those who do not consume fake news (H-A3a). This relationship will be stronger for pro-attitudinal misperceptions than for counter-attitudinal misperceptions (H-A3b) and for people who are relatively less skilled at analytical reasoning (H-A3c). People who consume fake news will be less likely to successfully distinguish between true and false topical statements (H-A3d).

For H-A3a, H-A3b, and H-A3c, the outcome measure is the perceived accuracy of true and false topical statements. These models will be estimated separately for wave 1 and wave 2 topical misperceptions. For each of these types of statements in wave 1, we will estimate the following models:
H-A3a: Accuracy = [constant] + prior fake news exposure + covariates listed above
H-A3b: Accuracy = [constant] + prior fake news exposure + congenial + prior fake news exposure * congenial + covariates listed above
H-A3c: Accuracy = [constant] + prior fake news exposure + CRT score + prior fake news exposure * CRT score + covariates listed above*/

/*note: can’t cluster with survey weights so omitting, might want to do robustness check with weights and no clustering - e.g., with respondent fixed effects or random effects or something*/

/*note: commented out w2 misperception battery based on dummies*/

*2018 defs
reg topical_accuracy totalfakecount18_pre dem_leaners repub_leaners polknow polint college female nonwhite ib1.agecat i.dv if topical_false==1, robust cluster(caseid)
reg topical_accuracy totalfakebinary18_pre dem_leaners repub_leaners polknow polint college female nonwhite ib1.agecat i.dv if topical_false==1, robust cluster(caseid)

*2016 defs
reg topical_accuracy totalfakenewscount_pre dem_leaners repub_leaners polknow polint college female nonwhite ib1.agecat i.dv if topical_false==1, robust cluster(caseid)
reg topical_accuracy totalfakenewsbinary_pre dem_leaners repub_leaners polknow polint college female nonwhite ib1.agecat i.dv if topical_false==1, robust cluster(caseid)

*omits independents again, see above

*2018 defs
reg topical_accuracy c.totalfakecount18_pre##i.congenial repub_leaners polknow polint college female nonwhite ib1.agecat if topical_false==1 & independents==0, robust cluster(caseid)
reg topical_accuracy totalfakebinary18_pre##i.congenial repub_leaners polknow polint college female nonwhite ib1.agecat if topical_false==1 & independents==0, robust cluster(caseid)

*2016 defs
reg topical_accuracy c.totalfakenewscount_pre##i.congenial repub_leaners polknow polint college female nonwhite ib1.agecat if topical_false==1 & independents==0, robust cluster(caseid)
reg topical_accuracy totalfakenewsbinary_pre##i.congenial repub_leaners polknow polint college female nonwhite ib1.agecat if topical_false==1 & independents==0, robust cluster(caseid)

*2018 defs
reg topical_accuracy c.totalfakecount18_pre##i.crt_terc dem_leaners repub_leaners polknow polint college female nonwhite ib1.agecat if topical_false==1, robust cluster(caseid)
reg topical_accuracy c.totalfakebinary18_pre##i.crt_terc dem_leaners repub_leaners polknow polint college female nonwhite ib1.agecat if topical_false==1, robust cluster(caseid)

*2016 defs
reg topical_accuracy c.totalfakenewscount_pre##i.crt_terc dem_leaners repub_leaners polknow polint college female nonwhite ib1.agecat if topical_false==1, robust cluster(caseid)
reg topical_accuracy c.totalfakenewsbinary_pre##i.crt_terc dem_leaners repub_leaners polknow polint college female nonwhite ib1.agecat if topical_false==1, robust cluster(caseid)

restore

egen mistrue_meanw2 = rowmean(misinform_mock_w2  misinform_police_w2)
egen misfalse_meanw2 = rowmean(misinform_recall_w2  misinform_refute_w2)

gen topical_accuracy_diff_w2 = mistrue_meanw2 - misfalse_meanw2

/*For H-A3d, the outcome measure = (mean perceived accuracy of true statements - mean perceived accuracy of false statements). This hypothesis is measured at the respondent level using a single mean difference that is not ordered and thus we will only test it using OLS with robust standard errors (i.e., no question fixed effects or clustering).
Outcome = [constant] + prior fake news exposure + covariates listed above*/

*2018 defs
svy: reg topical_accuracy_diff totalfakecount18_pre dem_leaners repub_leaners polknow polint college female nonwhite ib1.agecat 
svy: reg topical_accuracy_diff totalfakebinary18_pre dem_leaners repub_leaners polknow polint college female nonwhite ib1.agecat 

*2016 defs
svy: reg topical_accuracy_diff totalfakenewscount_pre dem_leaners repub_leaners polknow polint college female nonwhite ib1.agecat 
svy: reg topical_accuracy_diff totalfakenewsbinary_pre dem_leaners repub_leaners polknow polint college female nonwhite ib1.agecat 

/*can’t do this: For wave 2, we will control for treatment assignment in the models described above:*/
*do we want to control for stupid differences in instructions? should discuss

*2018 defs
svy: reg topical_accuracy_diff_w2 totalfakecount18_pre dem_leaners repub_leaners polknow polint college female nonwhite ib1.agecat 
svy: reg topical_accuracy_diff_w2 totalfakebinary18_pre dem_leaners repub_leaners polknow polint college female nonwhite ib1.agecat 

*2016 defs
svy: reg topical_accuracy_diff_w2 totalfakenewscount_pre dem_leaners repub_leaners polknow polint college female nonwhite ib1.agecat 
svy: reg topical_accuracy_diff_w2 totalfakenewsbinary_pre dem_leaners repub_leaners polknow polint college female nonwhite ib1.agecat 

*/


*topical misinfo exposure tests deleted here

/*RQ-A1: Is there a relationship between respondent age and perceived accuracy of fake news?

RQ-A1: Accuracy = [constant] + age [as defined above] + other covariates listed above.*/

/*note: same as H-A2, see above for results*/

/*add robustness checks if age significant:  If one or more of our age dummy variables is significant, we will test for robustness using alternate codings of age including age as a linear variable, age as linear variable plus an age-squared term, and alternate dummy codings of age.*/

/*D. Effects of prior exposure to fake news*/

/*H-D1) Randomized exposure to a fake news story in Wave 1 increases the perceived accuracy of those stories in Wave 2.

H-D2) Randomized exposure to a real news story in Wave 1 increases the perceived accuracy of those stories in Wave 2.

H-D3) Randomized exposure to a hyper-partisan news story in Wave 1 increases the perceived accuracy of those stories in Wave 2.

For H-D1, RQ-D1, and RQ-D2, the outcome measure is the perceived accuracy of fake headlines in Wave 2.
For H-D2 and RQ-D3, the outcome measure is the perceived accuracy of real headlines
For H-D3 and RQ-D4, the outcome measure is the perceived accuracy of hyper-partisan headlines.
To test the effects of wave 1 exposure (H-D1-H-D3) Outcome = [constant] + wave 1 exposure
*/

*see above for pooled measure OR MOVE THIS UP THERE

**october headline codes
*pro-D hyper 1 = donald_trump_caught_png, 2 = franklin_graham_png
*pro-D fake 3 = vp_mike_pence_png 4 = vice_president_pence_png
*proR hyper 5 = soros_money_behind_png, 6 = kavanaugh_accuser_png
*proR fake 7 = fbi_agent_who_png, 8 = lisa_page_png
*pro d real 9 = a_series_of_suspicious_png, 10 = a_border_patrol_png, 11 = detention_of_migrant__png 12 = and_now_its_the_tallest_png
*proR real 13 = google_employees_png, 14 = feds_said_alleged_png, 15 = small_busisness_optimism_ , 16 = economy_adds_more_png

**shorten varname(s) 
/*
gen accuracy_small_busw2 = accuracy_small_busisness_optw2
gen accuracy_donald_caughtw2 = accuracy_donald_trump_caughtw2
gen accuracy_soros_moneyw2 = accuracy_soros_money_behindw2*/




restore
preserve 

foreach var of varlist accuracy_vp_mike_pence accuracy_vice_president_pence accuracy_fbi_agent_who accuracy_lisa_page accuracy_a_series1 accuracy_a_border_patrol accuracy_detention_of_migrant accuracy_and_now1 accuracy_google_employees accuracy_feds_said_alleged accuracy_small_busisness_opt accuracy_economy_adds_more accuracy_donald_trump_caught accuracy_franklin_graham accuracy_soros_money_behind accuracy_kavanaugh_accuser{
gen s_`var'=(`var'!=.)
}

*fake
foreach var of varlist accuracy_vp_mike_pence accuracy_vice_president_pence accuracy_fbi_agent_who accuracy_lisa_page{
reg `var'w2 s_`var', robust
}

*real
foreach var of varlist accuracy_a_series1 accuracy_a_border_patrol accuracy_detention_of_migrant accuracy_and_now1 accuracy_google_employees accuracy_feds_said_alleged accuracy_small_busisness_opt accuracy_economy_adds_more{
reg `var'w2 s_`var', robust
}

*hyper
foreach var of varlist accuracy_donald_trump_caught accuracy_franklin_graham accuracy_soros_money_behind accuracy_kavanaugh_accuser{
reg `var'w2 s_`var', robust
}




**pretreatment fc visits
*STILL MISSING

*As we describe above for wave 1, we will control the false discovery rate with the Benjamini-Hochberg procedure given the risk of false positives. 

*STILL MISSING

/*PROMISED AUXILIARY ANALYSES*/

/*-For interaction terms, scales, and moderators, if results are consistent using a median/tercile split or indicators rather than a continuous scale, we may present the latter in the main text for ease of exposition and include the continuous scale results in an appendix. We will also use tercile indicators to test whether a linearity assumption holds for any interactions with continuous moderators per Hainmueller et al (forthcoming) and replace any continuous interactions in our models with them if it does not.*/

*code here
*STILL MISSING

/*-We will compute and report summary statistics for our sample. We will also collect and may report response timing data as a proxy for respondent attention.*/
/*-We will also compute and report descriptive statistics for our data to summarize sample characteristics, response variable distributions, etc.*/

*code here
*STILL MISSING

/*-Where applicable, regression results for binary dependent variables will be verified for robustness using probit. Regression results for individual ordered or count dependent variables will be verified for robustness using ordered probit or Poisson regression with standard errors, respectively.*/

*code here
*STILL MISSING

/*
-We may estimate the experimental models described above with a standard set of covariates if including those has a substantively important effect on the precision of our treatment effect estimates. We will select covariates from the list below using the lasso before estimating the model using OLS per the procedures described in Bloniarz et al. 2016.
Candidate covariates for all models:
-average media slant value from the period prior to wave 1 (measured per Guess et al. N.d.)
-decile indicators for average media slant from the period prior to wave 1 (measured per Guess et al. N.d.)
-indicators for Democrats and Republicans (including leaners)
-gender
-age groups (30-44, 45-59, 60+) 
-non-white respondents
-respondents with a four-year college degree
-scores on standard political knowledge and interest scales
-Trump feeling thermometer from wave 1
-Media feeling thermometer from wave 1
-Trust in the media in wave 1
-Affective polarization in wave 1 (in-party feelings - out-party feelings)
-Conspiracy predispositions scale (average response in wave 1)

Added covariate for wave 2 belief accuracy outcome models:
-lagged average belief accuracy from wave 1 for each type of outcome measure (e.g., average accuracy of pro-Republican fake news in wave 1 for analysis of perceived accuracy of pro-Republican fake news in wave 2; applies to all real/fake/hyperpartisan news types)*/

*code here
*STILL MISSING

/*-We will test for differential attrition between survey waves by examining the relationship between completion of wave 2 and wave 1 treatment assignment. This is our primary measure of attrition. If we observe significant differential attrition based on condition, we will use a strategy such as the one proposed by Aronow et al. to account for missing outcome variables in a randomized experiment (http://papers.ssrn.com/sol3/papers.cfm?abstract_id=2305788).*/

*code here
*STILL MISSING

/*We will also test for attrition based on the following observable characteristics:
-media trust, media feelings, and average fake news belief in wave 1
-political characteristics (partisanship and political knowledge)
-demographic characteristics (race, sex, and age)
Due to the large number of characteristics on which we will assess imbalance, we will use a correction for multiple comparisons. Attrition that is unrelated to random assignment should not confound our treatment effect estimates but is worth noting for the reader and potentially addressing in any observational data analyses.*/

*code here
*STILL MISSING

/*-In addition to OLS with robust standard errors and question fixed effects, we will also fit a non-nested hierarchical model with the same covariates.*/

*code here
*STILL MISSING


/*TO BE ADDED ALL THE STUFF ON THESE VARS:

su fb_political_ads fb_political_ad_num fb_political_ads_support fb_ad_sponsor fb_ad_content fb_ad_device fb_ad_share fb_recent_share fb_ad_saturation fb_ad_informative fb_ad_vs_tv fb_ad_label election_enthus election_anxiety election_anger senate_vote_w2 senate_vote_lean_w2 fb_political_ads_w2 fb_political_ad_num_w2 fb_political_ads_support_w2 fb_ad_sponsor_w2 fb_ad_content_w2 fb_ad_device_w2 fb_ad_share_w2 fb_recent_share_w2 fb_ad_saturation_w2 fb_ad_informative_w2 fb_ad_vs_tv_w2 fb_ad_label_w2 election_enthus_w2 election_anxiety_w2 election_anger_w2

*/


/*ADD DUNNING KRUGER STUFF HERE*/
tab confidence_self confidence_americans

gen more_confident_self=(tpp>0 & tpp<4)
gen less_confident_self=(tpp<0)

tab accuracy_fake_meanw2
gen above_average_fake=(accuracy_fake_meanw2<=1.75) /*check prereg to verify not real-fake*/

*new DK stuff

/*
We also ask two questions in wave 2 that directly measure differences in perceived ability to detect fake news compared to the public using a Dunning-Kruger-style approach:

How do you think you compare to other Americans in your general ability to recognize news that is made up? Please respond using the scale below, where 1 means you're at the very bottom (worse than 99% of people) and 100 means you're at the very top (better than 99% of people).
[1-100 slider]

How do you think you compare to other Americans in how well you performed in this study at recognizing news that is made up? Please again respond using the scale below, where 1 means you're at the very bottom (worse than 99% of people) and 100 means you're at the very top (better than 99% of the people).
[1-100 slider]

If these measures are highly correlated as we expect, the variable TPPFN_W2 will take their average. (Otherwise, we will analyze them separately.) 
*/

svy: tab above_average_fake more_confident_self, col
svy: tab more_confident_self above_average_fake, col

/*
Our measure of the accuracy of people’s perceptions of relative ability is calculated by first calculating people’s ability to distinguish real from fake news (see below) as mean(real news accuracy) - mean(fake news accuracy) in each wave. Respondents will be ordered by how well they distinguish real from fake news. We will then create the outcome variable overconfidence_w1 using responses from wave 1:

1=more confident in themselves than in Americans’ ability to recognize news that is made up, below median on mean(real)-mean(fake) accuracy
0=equally confident in themselves and in Americans + those who accurately identify themselves as above or below the median
-1=less confident in themselves than in Americans’ ability to recognize news that is made up, above median on mean(real)-mean(fake) accuracy
*/

gen tpp3=.
replace tpp3=1 if tpp<0
replace tpp3=2 if tpp==0
replace tpp3=3 if tpp>0 & tpp<4

gen tpp2=.
replace tpp2=0 if tpp<=0
replace tpp2=1 if tpp>0 & tpp<4


**gen overconfidencew1 

/*
Our measure of the accuracy of people's perceptions of relative ability is calculated by first calculating people's ability to distinguish real from fake news as 
mean(real news accuracy) - mean(fake news accuracy) in each wave. Respondents are ordered by how well they distinguish real from fake news. 
We then create the outcome variable \emph{overconfidence (w1)} using responses from wave 1, where 
1 = more confident in themselves than in Americans' ability to recognize news that is made up, below median on mean(real)-mean(fake) accuracy; 
0 = equally confident in themselves and in Americans, plus those who accurately identify themselves as above or below the median; 
-1 = less confident in themselves than in Americans' ability to recognize news that is made up, above median on mean(real)-mean(fake) accuracy. 
*/

*more_confident_self 1= more confident 0 = not
*above_average_fake 1= above 0 = below


gen overconfidencew1 = 0
replace overconfidencew1 = 1 if (tpp3 == 3 & above_average_fake == 0)
replace overconfidencew1 = 0 if (tpp3 == 2) |(tpp3 ==3  & above_average_fake == 1) | (tpp3 == 1 & above_average_fake == 0)
replace overconfidencew1 = -1 if (tpp3 == 1 & above_average_fake == 1)



/*
We will also create the outcome variable overconfidence_w2 using responses from wave 2:

Percentile_estimated_in_this_study - percentile_actual 

where percentile_estimated equals their answer to the question above about perceived performance in this study and percentile_actual equals their actual estimated ranking on the mean(real)-mean(fake) measure in our sample in wave 2. 
*/

*NOTE: not survey weighted (not compatible, may have to do by hand but ill-defined)

*note not 1-100 because of lots of ties
xtile percentile_actual =  mean_acc_diffw2 if mean_acc_diffw2!=., nq(100)

gen overconfidence_w2 = madeup_recognize_study_w2 - percentile_actual

label def tpp3lab 1 "Less confident in self" 2 "Equally confident" 3 "More confident in self"
label val tpp3 tpp3lab

label def tpp2lab 0 "Less/equally confident in self" 1 "More confident in self"
label val tpp2 tpp2lab

label def above_average_fake_lab 0 "Below average" 1 "Above average"
label val above_average_fake above_average_fake_lab

gen fake=1

/*RQ1: We will make two Dunning-Kruger-style graphs. The first will have quartiles of performance in distinguishing real from fake news in wave 1 (i.e., lower perceived accuracy for fake news, higher perceived accuracy for real news) on the x-axis and mean TPPFN_W1 by group on the y-axis. The second graph will more closely approximate Dunning-Kruger by presenting quartiles of performance in distinguishing real from fake news (i.e., lower perceived accuracy for fake news, higher perceived accuracy for real news) in wave 2 on the x-axis and perceived quartile of performance on the y-axis.*/

cibar above_average_fake [pweight=weight],over1(fake) bargap(8) gap(35) over2(tpp3) graphopts(graphregion(fcolor(white) ifcolor(none)) plotregion(fcolor(none) lcolor(white) ifcolor(none) ilcolor(none)) ytitle("") scheme(lean1) yscale(r(0 .61)) ylab(0 "0%" .1 "10%" .2 "20%" .3 "30%" .4 "40%" .5 "50%" .6 "60%",angle(0) labsize(*.8)) ytitle("") legend(off))
graph export "dkgraph1.pdf", replace

cibar above_average_fake [pweight=weight],over1(fake) bargap(8) gap(35) over2(tpp2) graphopts(graphregion(fcolor(white) ifcolor(none)) plotregion(fcolor(none) lcolor(white) ifcolor(none) ilcolor(none)) ytitle("") scheme(lean1) yscale(r(0 .61)) ylab(0 "0%" .1 "10%" .2 "20%" .3 "30%" .4 "40%" .5 "50%" .6 "60%",angle(0) labsize(*.8)) ytitle("") legend(off))
graph export "dkgraph2.pdf", replace

cibar tpp2 [pweight=weight],over1(fake) over2(above_average_fake) bargap(8) gap(35) graphopts(graphregion(fcolor(white) ifcolor(none)) plotregion(fcolor(none) lcolor(white) ifcolor(none) ilcolor(none)) ytitle("") scheme(lean1) yscale(r(0 .61)) ylab(0 "0%" .2 "20%" .4 "40%" .6 "60%" .8 "80%" 1 "100%",angle(0) labsize(*.8)) ytitle("") legend(off))
graph export "dkgraph3.pdf", replace


*real DK graph
/*
gen perceived_quartile=(floor((madeup_recognize_study_w2-1)/25))+1

preserve
collapse (mean) madeup_recognize_study_w2 percentile_actual [pweight=weight], by(perceived_quartile)

gen true=.
replace true=12.5 if perceived_quartile==1
replace true=37.5 if perceived_quartile==2
replace true=62.5 if perceived_quartile==3
replace true=87.5 if perceived_quartile==4

*needs legends and labels
twoway (connected true perceived_quartile) (connected percentile_actual perceived_quartile, xlabel(1 `" "Bottom"  "quartile" "' 2 `" "2nd"  "quartile" "' 3 `" "3rd"  "quartile" "' 4 `" "4th"  "quartile" "') graphregion(fcolor(white) ifcolor(none)) plotregion(fcolor(none) lcolor(white) ifcolor(none) ilcolor(none)) ytitle("") scheme(lean1) xtitle("") yscale(r(0 101)) xscale(r(0.75 4.25)) ylab(0(10)100, labsize(*.8)) ytitle("Percentile") legend(lab(2 "Perceived ability") lab(1 "Actual performance") order(2 1) ring(0) position(5) bmargin(large) region(lpattern(solid) lcolor(black))))
graph export "dkgraph-real.pdf", replace
restore

hist madeup_recognize_study_w2,scheme(lean1) xtitle("Self-assessed percentile of fake news detection ability") percent ytitle("") ylabel(0 "0%" 5 "5%" 10 "10%" 15 "15%") xlabel(0(10)100)
graph export "ability.pdf", replace
*/

****BL-new TPP ttest

corr tpp madeup_recognize_study_w2 // .23
corr madeup_recognize_study_w2 madeup_recognize_overall_w2 // .73
egen madeup_avg = rowmean(madeup_recognize_study_w2 madeup_recognize_overall_w2)


ttest tpp==0
ttest confidence_self == confidence_americans 
ttest madeup_recognize_study_w2==50
ttest madeup_avg ==50



****BL-new DK/TPP Political/cognitive/demographic correlates



**tips

reg tpp tips dem_leaners repub_leaners polknow polint college female nonwhite ib1.agecat, robust
est store tips_tpp
reg madeup_avg tips dem_leaners repub_leaners polknow polint college female nonwhite ib1.agecat, robust
est store tips_percentile
reg overconfidence_w2 tips dem_leaners repub_leaners polknow polint college female nonwhite ib1.agecat, robust
est store tips_overconfidence
reg overconfidencew1 tips dem_leaners repub_leaners polknow polint college female nonwhite ib1.agecat, robust // *add overconfidencew1
est store tips_overw1
esttab tips_tpp tips_percentile tips_overw1 tips_overconfidence using tpp-tips.tex, replace varwidth(25) collabels("") cells(b(star fmt(%9.3f)) se(par fmt(%9.3f))) stats(r2 N, fmt(%9.2f %9.0f) labels("R^2" "N")) starlevels(* 0.05 ** 0.01 *** 0.005) style(tex)




*RQ3. Are fake news exposure and partisan selective exposure associated with overconfidence in one’s ability to distinguish real from fake news and/or TPPFN?
*Overconfidence  = [constant] + exposure to fake news (binary/count/share of information diet) + selective exposure decile indicators + [mean(real news)-mean(fake news)] + covariates listed above
*TPPFN  = [constant] + exposure to fake news (binary/count/share of information diet) + selective exposure decile indicators + [mean(real news)-mean(fake news)] + covariates listed above

* using pre-survey measures //took pre out-BL--check this 
/*
*2018 def
svy: reg tpp mean_acc_diff i.decile_all totalfakecount18_pre dem_leaners repub_leaners polknow polint college female nonwhite ib1.agecat
est store tpp_fakecount_post
svy: reg tpp mean_acc_diff i.decile_all totalfakebinary18_pre dem_leaners repub_leaners polknow polint college female nonwhite ib1.agecat
est store tpp_fakebin_post
svy: reg madeup_avg mean_acc_diff i.decile_all totalfakecount18_pre dem_leaners repub_leaners polknow polint college female nonwhite ib1.agecat
est store tpp2_fakecount_post
svy: reg madeup_avg mean_acc_diff i.decile_all totalfakebinary18_pre dem_leaners repub_leaners polknow polint college female nonwhite ib1.agecat
est store tpp2_fakebin_post
svy: reg overconfidencew1  i.decile_all totalfakecount18_pre dem_leaners repub_leaners polknow polint college female nonwhite ib1.agecat
est store over_fakecount_post
svy: reg overconfidencew1 i.decile_all totalfakebinary18_pre dem_leaners repub_leaners polknow polint college female nonwhite ib1.agecat
est store over_fakebin_post
svy: reg overconfidence_w2 i.decile_all totalfakecount18_pre dem_leaners repub_leaners polknow polint college female nonwhite ib1.agecat
est store over2_fakecount_post
svy: reg overconfidence_w2 i.decile_all totalfakebinary18_pre dem_leaners repub_leaners polknow polint college female nonwhite ib1.agecat
est store over2_fakebin_post

*/

/*
*2016 def
reg tpp3 mean_acc_diff i.decile_all totalfakenewscount dem_leaners repub_leaners polknow polint college female nonwhite ib1.agecat, robust
reg more_confident_self above_average_fake i.decile_all totalfakenewscount dem_leaners repub_leaners polknow polint college female nonwhite ib1.agecat, robust
reg tpp3 mean_acc_diff i.decile_all totalfakenewsbinary  dem_leaners repub_leaners polknow polint college female nonwhite ib1.agecat, robust
reg more_confident_self above_average_fake i.decile_all totalfakenewsbinary dem_leaners repub_leaners polknow polint college female nonwhite ib1.agecat, robust
*/

*H3. Political interest, knowledge, and performance in distinguishing real from fake news (i.e., lower perceived accuracy for fake news, higher perceived accuracy for real news) will be positively associated with TPPFN. 
svy: reg tpp mean_acc_diff polint dem_leaners repub_leaners polknow college female nonwhite ib1.agecat
est store tpp_polpost1
svy: reg madeup_avg mean_acc_diff polint dem_leaners repub_leaners polknow college female nonwhite ib1.agecat
est store tpp_polpost2

*RQ4. How does TPPFN vary by party identification and political knowledge? 
/*
svy: reg tpp dem_leaners##polknow repub##polknow dem_leaners repub_leaners polint college female nonwhite ib1.agecat // kowledgeable Ds
est store tpp_asympost1
svy: reg madeup_avg dem##polknow repub##polknow dem_leaners repub_leaners polint college female nonwhite ib1.agecat // kowledgeable Ds
est store tpp_asympost2 
*/

gen demXpolknow = polknow*dem_leaners
gen repXpolknow = polknow*repub_leaners

svy: reg tpp  dem_leaners repub_leaners polknow demXpolknow repXpolknow polint college female nonwhite ib1.agecat // kowledgeable Ds
est store tpp_asympost1
svy: reg madeup_avg dem_leaners repub_leaners polknow demXpolknow repXpolknow polint college female nonwhite ib1.agecat // kowledgeable Ds
est store tpp_asympost2




*RQ5. How do TPPFN and overconfidence in one’s ability to distinguish real from fake news vary by age?
*TPPFN = [constant] + age + other covariates
*Overconfidence = [constant] + age + other covariates
svy: reg tpp dem_leaners repub_leaners polknow polint college female nonwhite ib1.agecat
est store tpp_agepost1
svy: reg madeup_avg dem_leaners repub_leaners polknow polint college female nonwhite ib1.agecat
est store tpp_agepost2
svy: reg overconfidencew1 dem_leaners repub_leaners polknow polint college female nonwhite ib1.agecat
est store over_agepost1
svy: reg overconfidence_w2 dem_leaners repub_leaners polknow polint college female nonwhite ib1.agecat
est store over_agepost2

**age as linear term
svy: reg tpp dem_leaners repub_leaners polknow polint college female nonwhite age // sig -
svy: reg madeup_avg dem_leaners repub_leaners polknow polint college female nonwhite age // sig +
svy: reg overconfidencew1 dem_leaners repub_leaners polknow polint college female nonwhite age // sig -
svy: reg overconfidence_w2 dem_leaners repub_leaners polknow polint college female nonwhite age // ns



*H4. Negative feelings toward the media (mass media trust, Facebook trust, media feelings) will be positively associated with TPPFN (see Tsfati and Cohen 2013, p. 12).
*TPPFN = [constant]  + mass media trust + FB trust + media FT + covariates listed above (separately and in omnibus)

svy: reg tpp massmedia_trust fbtrust FT_media dem_leaners repub_leaners polknow polint college female nonwhite ib1.agecat
est store tppmedia_post1
svy: reg madeup_avg massmedia_trust fbtrust FT_media dem_leaners repub_leaners polknow polint college female nonwhite ib1.agecat
est store tppmedia_post2


**media single item models

svy: reg tpp massmedia_trust  dem_leaners repub_leaners polknow polint college female nonwhite ib1.agecat // sig -
svy: reg tpp fbtrust  dem_leaners repub_leaners polknow polint college female nonwhite ib1.agecat // sig -
svy: reg tpp  FT_media dem_leaners repub_leaners polknow polint college female nonwhite ib1.agecat // sig -
svy: reg madeup_avg massmedia_trust dem_leaners repub_leaners polknow polint college female nonwhite ib1.agecat // sig +
svy: reg madeup_avg  fbtrust dem_leaners repub_leaners polknow polint college female nonwhite ib1.agecat // sig +
svy: reg madeup_avg  FT_media dem_leaners repub_leaners polknow polint college female nonwhite ib1.agecat // sig +



*NEW DK ANALYSIS HERE



/*Ben to add:

Political/cognitive/demographic correlates
RQ3. Are fake news exposure and partisan selective exposure associated with overconfidence in one’s ability to distinguish real from fake news and/or TPPFN?

Overconfidence_w1  = [constant] + exposure to fake news (binary/count/share of information diet) + selective exposure decile indicators + [mean(real news w1)-mean(fake news w1)] + covariates listed above
Overconfidence_w2  = [constant] + exposure to fake news (binary/count/share of information diet) + selective exposure decile indicators + [mean(real news w2)-mean(fake news w2)] + covariates listed above
TPPFN_W1  = [constant] + exposure to fake news (binary/count/share of information diet) + selective exposure decile indicators + [mean(real news w1)-mean(fake news w1)] + covariates listed above
TPPFN_W2  = [constant] + exposure to fake news (binary/count/share of information diet) + selective exposure decile indicators + [mean(real news w2)-mean(fake news w2)] + covariates listed above
H3. Political interest, knowledge, and performance in distinguishing real from fake news (i.e., lower perceived accuracy for fake news, higher perceived accuracy for real news) will be positively associated with TPPFN. 
TPPFN_W1 = [constant] + political interest + political knowledge + [mean(real news w1)-mean(fake news w1)] + covariates listed above (separately and in omnibus)
TPPFN_W2 = [constant] + political interest + political knowledge + [mean(real news w2)-mean(fake news w2)] + covariates listed above (separately and in omnibus)
RQ4. How does TPPFN vary by party identification and political knowledge?
TPPFN_W1 = [constant] + Democrat + Republican + knowledge + Democrat X knowledge + Republican X knowledge
TPPFN_W2 = [constant] + Democrat + Republican + knowledge + Democrat X knowledge + Republican X knowledge
RQ5. How do TPPFN and overconfidence in one’s ability to distinguish real from fake news vary by age?
TPPFN_W1 = [constant] + age + other covariates
TPPFN_W2 = [constant] + age + other covariates
Overconfidence_W1 = [constant] + age + other covariates
Overconfidence_W2 = [constant] + age + other covariates
(If one or more of our age dummy variables is significant, we will test for robustness using alternate codings of age including age as linear variable, age as linear variable plus an age-squared term, and alternate dummy codings of age.)
H4. Negative feelings toward the media (mass media trust, Facebook trust, media feelings) will be positively associated with TPPFN (see Tsfati and Cohen 2013, p. 12).
TPPFN_W1 = [constant]  + mass media trust + FB trust + media FT + covariates listed above (separately and in omnibus)
TPPFN_W2 = [constant]  + mass media trust + FB trust + media FT + covariates listed above (separately and in omnibus)
*/


**exploratory combo table: all but tips 

*fake count
svy: reg tpp mean_acc_diff  totalfakecount18  i.decile_all massmedia_trust fbtrust FT_media dem_leaners repub_leaners polknow college female nonwhite ib1.agecat
svy: reg madeup_recognize_study_w2 mean_acc_diff totalfakecount18  i.decile_all massmedia_trust fbtrust FT_media dem_leaners repub_leaners polknow college female nonwhite ib1.agecat
svy: reg more_confident_self above_average_fake mean_acc_diff massmedia_trust fbtrust FT_media totalfakecount18  i.decile_all dem_leaners repub_leaners polknow polint college female nonwhite ib1.agecat


*fake binary
svy: reg tpp mean_acc_diff   totalfakebinary18 i.decile_all massmedia_trust fbtrust FT_media dem_leaners repub_leaners polknow college female nonwhite ib1.agecat
svy: reg madeup_recognize_study_w2 mean_acc_diff  totalfakebinary18 i.decile_all massmedia_trust fbtrust FT_media dem_leaners repub_leaners polknow college female nonwhite ib1.agecat
svy: reg more_confident_self above_average_fake mean_acc_diff massmedia_trust fbtrust FT_media  totalfakebinary18 i.decile_all dem_leaners repub_leaners polknow polint college female nonwhite ib1.agecat


**tweets effects

**main effects - trust/conf
reg zconf_trust tweet4 tweet8 tweetcorrect, robust // increase distrust 
lincom tweet8 - tweet4 //ns
lincom tweet4 - tweetcorrect // correction reduces

**party
reg zconf_trust tweet4##repub tweet8##repub tweetcorrect##repub, robust  // no interactions


**other dvs - democ imp, polsys // no effects on these
reg democ_imp tweet4 tweet8 tweetcorrect, robust 
lincom tweet8 - tweet4 //ns
lincom tweet4 - tweetcorrect // ns

reg polsys1 tweet4 tweet8 tweetcorrect, robust 
lincom tweet8 - tweet4 //ns
lincom tweet4 - tweetcorrect // ns

reg polsys2 tweet4 tweet8 tweetcorrect, robust 
lincom tweet8 - tweet4 //ns
lincom tweet4 - tweetcorrect // ns

reg polsys3 tweet4 tweet8 tweetcorrect, robust 
lincom tweet8 - tweet4 //ns
lincom tweet4 - tweetcorrect // ns

reg polsys4 tweet4 tweet8 tweetcorrect, robust 
lincom tweet8 - tweet4 //ns
lincom tweet4 - tweetcorrect // ns

/*
Heterogeneous treatment effects
For the exploratory analyses of possible moderators of the effects of fraud message exposure,
the outcome measures are election confidence and support for democracy. Moderators are trust
in and feelings toward the media, feelings toward Trump (entered as a linear term and with
indicators for terciles or quartiles), conspiracy predispositions, political interest and knowledge,
and pre-treatment visits to fake news sites and fact-checking sites. Due to likely collinearity
between the predictors, we will estimate separate models for each potential moderator for each
outcome measure.
E.g.:
Outcome = [constant] + 4 fraud tweet exposure + 8 fraud tweet exposure + 4 fraud/4 fact-check
tweet exposure + feelings toward Trump + 4 fraud tweet exposure*feelings toward Trump + 8
fraud tweet exposure*feelings toward Trump + 4 fraud/4 fact-check tweet exposure*feelings
toward Trump */


*trust in and feelings toward the media, 
reg zconf_trust tweet4##massmedia_trust tweet8##massmedia_trust tweetcorrect##massmedia_trust, robust // no X (main effect tho)
reg zconf_trust tweet4##media_terc tweet8##media_terc tweetcorrect##media_terc, robust // tweet8 weaker for high media FT

*feelings toward Trump (entered as a linear term and with indicators for terciles or quartiles), 
reg zconf_trust tweet4##trump_terc tweet8##trump_terc tweetcorrect##trump_terc, robust // tweet8 stronger for high Trump terc

*conspiracy predispositions, 
reg zconf_trust tweet4##consp_terc tweet8##consp_terc tweetcorrect##consp_terc, robust // no X (main effect tho)

*political interest 
reg zconf_trust tweet4##polint tweet8##polint tweetcorrect##polint, robust // polint decreases effect for tweet4 

*pol knowledge,
reg zconf_trust tweet4##polknow tweet8##polknow tweetcorrect##polknow, robust // no X (main effect tho)

*pre-treatment visits to fake news sites 
*reg zconf_trust tweet4##totalfakenewscount_pre  tweet8##ptotalfakenewscount_pre  tweetcorrect##totalfakenewscount_pre , robust 
*reg zconf_trust tweet4##totalfakenewsbinary_pre tweet8##totalfakenewsbinary_pre  tweetcorrect##totalfakenewsbinary_pre , robust 
*fact-checking sites?











