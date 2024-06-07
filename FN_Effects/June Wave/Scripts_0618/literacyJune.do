/*make total fake binary and count using D/R fake vars*/
/*add equivalent graphs with 2018 vars as DVs*/

clear

*cd "/Users/bnyhan/Dropbox/GuessNyhanReifler/DART0023/YouGov data/"
*cd "/Users/jasonreifler/Dropbox/GuessNyhanReifler/DART0023/YouGov data/"
*cd "/Users/benlyons/Dropbox/GuessNyhanReifler/DART0023/YouGov data/"
cd "C:/Users/dl0ck/OneDrive/Fall2019/FN/FN_Effects/June Wave/Data_0618"
/*get Pulse data ready*/

clear
import delimited using "pulse_vars_junejuly18_varsfromboth.csv"
save "pulse_vars_junejuly18_varsfromboth-stata13.dta", replace

clear
import delimited using "pulse_vars_junejuly18_varsfromboth_presurvey.csv"
drop weight
foreach var of varlist totalnewsbinary totalnewscount totalnewsfncount2016def totalvisits totalprotrumpfnbinary_ag80 totalproclintonfnbinary_ag80 totalprotrumpfncount_ag80 totalproclintonfncount_ag80 totalfakenewsbinary totalfakenewscount mfb diet_mean count decile totalnewsfncount2018def totalprorepfnbinary totalprodemfnbinary totalprorepfncount totalprodemfncount totalfakebinary18 totalfakecount18 {
capture replace `var'="" if `var'=="NA" | `var'=="NaN"
capture destring `var', replace
rename `var' `var'_pre
}

save "pulse_vars_junejuly18_varsfromboth_presurvey-stata13.dta", replace

/*OPEN AND CODE DATA*/

use "DART0023_OUTPUT_v13.DTA", clear

**add pulse**

*all the Pulse variables
merge 1:1 caseid using "pulse_vars_junejuly18_varsfromboth-stata13.dta"
tab _merge
gen nopulse=(_merge==1)
drop _merge

tab decile

merge 1:1 caseid using "pulse_vars_junejuly18_varsfromboth_presurvey-stata13.dta"
tab _merge
gen nopulsepre=(_merge==1)
drop _merge

tab nopulse nopulsepre /*14 more who had no Pulse pre but had Pulse later in study period*/
	
/*demos*/

gen female = gender
recode female 2=1 1=0

gen nonwhite = race
recode nonwhite 2=1 3=1 4=1 5=1 6=1 7=1 8=1 1=0

gen college = educ
recode college 1=0 2=0 3=0 4=0 5=1 6=1

gen age = 2018-birthyr 
gen agecat=age
/* -age groups (18-29, 30-44, 45-59, 60+)*/
replace agecat=1 if age>17
replace agecat=2 if age>29
replace agecat=3 if age>44
replace agecat=4 if age>59
replace agecat=. if age==.

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

gen polint = pol_interest
recode polint 1=5 2=4 3=3 4=2 5=1 /*recode very interest high*/

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

alpha CRT1 CRT2 /* alpha = .53 */

gen crt1a = crt_1a
gen crt1b = crt_1b
gen crt1c = crt_1c

recode crt1a 1=1 else=0
recode crt1b 3=1 else=0
recode crt1c 3=1 else=0

alpha crt1a crt1b crt1c /* alpha = .46 */

gen crt2a = crt_2a
gen crt2b = crt_2b
gen crt2c = crt_2c
gen crt2d = crt_2d

recode crt2a 2=1 else=0
recode crt2b 2=1 else=0
recode crt2c 2=1 else=0
recode crt2d 2=1 else=0

alpha crt2a crt2b crt2c crt2d /* alpha = .53 */

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

gen fbtrust = fb_trust /* recode high trust high */
recode fbtrust 1=4 2=3 3=2 4=1

gen fb_use = fb_freq
recode fb_use 1=9 2=8 3=7 4=6 5=5 6=4 7=3 8=2 9=1 /* recode high use high */

gen fb_pol_use = fb_political_freq
recode fb_pol_use 1=9 2=8 3=7 4=6 5=5 6=4 7=3 8=2 9=1 /* recode high use high */

gen fb_pol_share = fb_share_freq 
recode fb_pol_share 1=9 2=8 3=7 4=6 5=5 6=4 7=3 8=2 9=1 /* recode high use high */

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

**topical misperceptions**

gen mis_pro_d_true = misinform_melania
gen mis_pro_r_true = misinform_fonda
gen mis_pro_d_false = misinform_cry
gen mis_pro_r_false = misinform_separation

egen mistrue_mean = rowmean(mis_pro_d_true  mis_pro_r_true)
egen misfalse_mean = rowmean(mis_pro_d_false  mis_pro_r_false)

gen topical_accuracy_diff = mistrue_mean - misfalse_mean

**headline task**
**headline codes:
*pro d real: *whsecurity = 10 *whofficial = 8 *trumpangry = 5 *trumpforeign = 9
*pro r real: *goplawmaker = 7 *demworry = 12 *demrunning = 11 *repubvote = 13
*pro d fake: *trumop sister = 1 michgop = 3
*pro r fake: millionsrush = 15 , dickdurbin = 16
*pro d hyper mueller = 6 ndcong = 4
*pro r hyper worldfeels = 14, twoyearstudy = 2

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

gen accuracy_trumpsister = 0
gen accuracy_twoyearstudy = 0
gen accuracy_michgop = 0
gen accuracy_ndcongress = 0
gen accuracy_trumpangry = 0
gen accuracy_mueller = 0
gen accuracy_goplawmaker = 0
gen accuracy_whofficial = 0
gen accuracy_trumpforeign = 0
gen accuracy_whsecurity = 0
gen accuracy_demrunning = 0
gen accuracy_demsworry = 0
gen accuracy_repubsvote = 0
gen accuracy_worldfeels = 0
gen accuracy_millionsrush = 0
gen accuracy_dickdurbin = 0

**accuracy**

forval i=1/8 {
replace accuracy_trumpsister=accuracy`i' if articlename`i'==1
}
recode accuracy_trumpsister 0=.

forval i=1/8 {
replace accuracy_twoyearstudy=accuracy`i' if articlename`i'==2
}
recode accuracy_twoyearstudy 0=.

forval i=1/8 {
replace accuracy_michgop=accuracy`i' if articlename`i'==3
}
recode accuracy_michgop 0=.

forval i=1/8 {
replace accuracy_ndcongress=accuracy`i' if articlename`i'==4
}
recode accuracy_ndcongress 0=.

forval i=1/8 {
replace accuracy_trumpangry=accuracy`i' if articlename`i'==5
}
recode accuracy_trumpangry 0=.

forval i=1/8 {
replace accuracy_mueller=accuracy`i' if articlename`i'==6
}
recode accuracy_mueller 0=.

forval i=1/8 {
replace accuracy_goplawmaker=accuracy`i' if articlename`i'==7
}
recode accuracy_goplawmaker 0=.

forval i=1/8 {
replace accuracy_whofficial=accuracy`i' if articlename`i'==8
}
recode accuracy_whofficial 0=.

forval i=1/8 {
replace accuracy_trumpforeign=accuracy`i' if articlename`i'==9
}
recode accuracy_trumpforeign 0=.

forval i=1/8 {
replace accuracy_whsecurity=accuracy`i' if articlename`i'==10
}
recode accuracy_whsecurity 0=.

forval i=1/8 {
replace accuracy_demrunning=accuracy`i' if articlename`i'==11
}
recode accuracy_demrunning 0=.

forval i=1/8 {
replace accuracy_demsworry=accuracy`i' if articlename`i'==12
}
recode accuracy_demsworry 0=.


forval i=1/8 {
replace accuracy_repubsvote=accuracy`i' if articlename`i'==13
}
recode accuracy_repubsvote 0=.

forval i=1/8 {
replace accuracy_worldfeels=accuracy`i' if articlename`i'==14
}
recode accuracy_worldfeels 0=.

forval i=1/8 {
replace accuracy_millionsrush=accuracy`i' if articlename`i'==15
}
recode accuracy_millionsrush 0=.

forval i=1/8 {
replace accuracy_dickdurbin=accuracy`i' if articlename`i'==16
}
recode accuracy_dickdurbin 0=.

**fake mean
egen accuracy_fake_mean = rowmean(accuracy_trumpsister accuracy_michgop accuracy_millionsrush accuracy_dickdurbin)
**real mean
egen accuracy_real_mean = rowmean(accuracy_trumpangry accuracy_whofficial accuracy_trumpforeign accuracy_whsecurity accuracy_repubsvote accuracy_goplawmaker accuracy_demrunning accuracy_demsworry)
**hyper mean 
egen accuracy_hyper_mean = rowmean(accuracy_worldfeels accuracy_twoyearstudy accuracy_mueller accuracy_ndcongress) 
**all mean
egen accuracy_all_mean = rowmean(accuracy_trumpsister accuracy_michgop accuracy_millionsrush accuracy_dickdurbin accuracy_trumpangry accuracy_whofficial accuracy_trumpforeign accuracy_whsecurity accuracy_repubsvote accuracy_goplawmaker accuracy_demrunning accuracy_demsworry accuracy_worldfeels accuracy_twoyearstudy accuracy_mueller accuracy_ndcongress)

**mean_acc_diff 
gen mean_acc_diff = accuracy_real_mean - accuracy_fake_mean


/*for descriptives*/
gen believe_misinform_separation=(misinform_separation>2 & misinform_separation!=.)
gen believe_misinform_cry=(misinform_cry>2 & misinform_cry!=.)

reg accuracy_trumpsister misinform_cry, robust /*.17 on four-point scale*/
reg accuracy_michgop misinform_cry, robust /*.11*/
reg accuracy_millionsrush believe_misinform_separation, robust /*.68, ~.75 sd*/
reg accuracy_dickdurbin believe_misinform_separation, robust /*.57, ~.65 sd*/



**sharing

gen share1 = headline_share_1
gen share2 = headline_share_2
gen share3 = headline_share_3
gen share4 = headline_share_4
gen share5 = headline_share_5
gen share6 = headline_share_6
gen share7 = headline_share_7
gen share8 = headline_share_8


gen share_trumpsister = 0
gen share_twoyearstudy = 0
gen share_michgop = 0
gen share_ndcongress = 0
gen share_trumpangry = 0
gen share_mueller = 0
gen share_goplawmaker = 0
gen share_whofficial = 0
gen share_trumpforeign = 0
gen share_whsecurity = 0
gen share_demrunning = 0
gen share_demsworry = 0
gen share_repubsvote = 0
gen share_worldfeels = 0
gen share_millionsrush = 0
gen share_dickdurbin = 0


forval i=1/8 {
replace share_trumpsister=share`i' if articlename`i'==1
}
recode share_trumpsister 0=.

forval i=1/8 {
replace share_twoyearstudy=share`i' if articlename`i'==2
}
recode share_twoyearstudy 0=.

forval i=1/8 {
replace share_michgop=share`i' if articlename`i'==3
}
recode share_michgop 0=.

forval i=1/8 {
replace share_ndcongress=share`i' if articlename`i'==4
}
recode share_ndcongress 0=.

forval i=1/8 {
replace share_trumpangry=share`i' if articlename`i'==5
}
recode share_trumpangry 0=.

forval i=1/8 {
replace share_mueller=share`i' if articlename`i'==6
}
recode share_mueller 0=.

forval i=1/8 {
replace share_goplawmaker=share`i' if articlename`i'==7
}
recode share_goplawmaker 0=.

forval i=1/8 {
replace share_whofficial=share`i' if articlename`i'==8
}
recode share_whofficial 0=.

forval i=1/8 {
replace share_trumpforeign=share`i' if articlename`i'==9
}
recode share_trumpforeign 0=.

forval i=1/8 {
replace share_whsecurity=share`i' if articlename`i'==10
}
recode share_whsecurity 0=.

forval i=1/8 {
replace share_demrunning=share`i' if articlename`i'==11
}
recode share_demrunning 0=.

forval i=1/8 {
replace share_demsworry=share`i' if articlename`i'==12
}
recode share_demsworry 0=.


forval i=1/8 {
replace share_repubsvote=share`i' if articlename`i'==13
}
recode share_repubsvote 0=.

forval i=1/8 {
replace share_worldfeels=share`i' if articlename`i'==14
}
recode share_worldfeels 0=.

forval i=1/8 {
replace share_millionsrush=share`i' if articlename`i'==15
}
recode share_millionsrush 0=.

forval i=1/8 {
replace share_dickdurbin=share`i' if articlename`i'==16
}
recode share_dickdurbin 0=.


**fake mean
egen share_fake_mean = rowmean(share_trumpsister share_michgop share_millionsrush share_dickdurbin)
**real mean
egen share_real_mean = rowmean(share_trumpangry share_whofficial share_trumpforeign share_whsecurity share_repubsvote share_goplawmaker share_demrunning share_demsworry)
**hyper mean 
egen share_hyper_mean = rowmean(share_worldfeels share_twoyearstudy share_mueller share_ndcongress) 
**all mean
egen share_all_mean = rowmean(share_trumpsister share_michgop share_millionsrush share_dickdurbin share_trumpangry share_whofficial share_trumpforeign share_whsecurity share_repubsvote share_goplawmaker share_demrunning share_demsworry share_worldfeels share_twoyearstudy share_mueller share_ndcongress) 


**mean_share_diff 
gen mean_share_diff = share_real_mean - share_fake_mean



/*W2 IVs & moderators*/

**treatment**
gen w2_treat = article_treat_w2
gen proD_fake = w2_treat
gen proR_fake = w2_treat
gen control_fake = w2_treat

recode proD_fake 1=1 else=0
recode proR_fake 2=1 else=0
recode control_fake 3=1 else=0

gen congenial_fn=.
replace congenial_fn=0 if repub_leaner==1 | dem_leaner==1
replace congenial_fn=1 if (proD_fake==1 & dem_leaner==1) | (proR_fake==1 & repub_leaner==1)

gen uncongenial_fn=.
replace uncongenial_fn=0 if repub_leaner==1 | dem_leaner==1
replace uncongenial_fn=1 if (proD_fake==1 & repub_leaner==1) | (proR_fake==1 & dem_leaner==1)

/* Measures explosure to fake news in Pulse data -- needs to be updated
gen congenial_fn =.
gen uncongenial_fn =. 

replace congenial_fn=1 if proD_fake==1 & dem_leaners ==1
replace congenial_fn=1 if proR_fake==1 & repub_leaners ==1

replace uncongenial_fn=1 if proD_fake==1 & repub_leaners ==1
replace uncongenial_fn=1 if proR_fake==1 & dem_leaners ==1
*/


**trust**
gen massmedia_trustw2 = media_trust_w2 /* recode high trust high */
recode massmedia_trustw2 1=4 2=3 3=2 4=1

gen fbtrustw2 = fb_trust_w2 /* recode high trust high */
recode fbtrustw2 1=4 2=3 3=2 4=1

**affect**
gen FT_black = group_affect_black_w2
gen FT_rich = group_affect_rich_w2
gen FT_white = group_affect_white_w2
gen FT_labor = group_affect_labor_w2

gen FT_white_black = FT_white-FT_black

/*W2 DVs*/

**headline task**
**accuracy**
gen accuracy_muellerw2 = headline_accuracy_1_w2
gen accuracy_ndcongressw2 = headline_accuracy_2_w2
gen accuracy_michgopw2 = headline_accuracy_3_w2
gen accuracy_trumpsisterw2 = headline_accuracy_4_w2
gen accuracy_worldfeelsw2 = headline_accuracy_5_w2
gen accuracy_twoyearstudyw2 = headline_accuracy_6_w2
gen accuracy_millionsrushw2 = headline_accuracy_7_w2
gen accuracy_dickdurbinw2 = headline_accuracy_8_w2
gen accuracy_whofficialw2 = headline_accuracy_9_w2
gen accuracy_trumpforeignw2 = headline_accuracy_10_w2
gen accuracy_whsecurityw2 = headline_accuracy_11_w2
gen accuracy_trumpangryw2 = headline_accuracy_12_w2
gen accuracy_goplawmakerw2 = headline_accuracy_13_w2
gen accuracy_demsworryw2 = headline_accuracy_14_w2
gen accuracy_repubsvotew2 = headline_accuracy_15_w2
gen accuracy_demrunningw2 = headline_accuracy_16_w2

**fake mean
egen accuracy_fake_meanw2 = rowmean(accuracy_trumpsisterw2 accuracy_michgopw2 accuracy_millionsrushw2 accuracy_dickdurbinw2)
**real mean
egen accuracy_real_meanw2 = rowmean(accuracy_trumpangryw2 accuracy_whofficialw2 accuracy_trumpforeignw2 accuracy_whsecurityw2 accuracy_repubsvotew2 accuracy_goplawmakerw2 accuracy_demrunningw2 accuracy_demsworryw2)
**hyper mean 
egen accuracy_hyper_meanw2 = rowmean(accuracy_worldfeelsw2 accuracy_twoyearstudyw2 accuracy_muellerw2 accuracy_ndcongressw2) 
**all mean
egen accuracy_all_meanw2 = rowmean(accuracy_trumpsisterw2 accuracy_michgopw2 accuracy_millionsrushw2 accuracy_dickdurbinw2 accuracy_trumpangryw2 accuracy_whofficialw2 accuracy_trumpforeignw2 accuracy_whsecurityw2 accuracy_repubsvotew2 accuracy_goplawmakerw2 accuracy_demrunningw2 accuracy_demsworryw2 accuracy_worldfeelsw2 accuracy_twoyearstudyw2 accuracy_muellerw2 accuracy_ndcongressw2)

**mean_acc_diff 
gen mean_acc_diffw2 = accuracy_real_meanw2 - accuracy_fake_meanw2

foreach var of varlist accuracy_trumpsister accuracy_michgop accuracy_millionsrush accuracy_dickdurbin accuracy_trumpangry accuracy_whofficial accuracy_trumpforeign accuracy_whsecurity accuracy_repubsvote accuracy_goplawmaker accuracy_demrunning accuracy_demsworry accuracy_worldfeels accuracy_twoyearstudy accuracy_mueller accuracy_ndcongress accuracy_trumpsisterw2 accuracy_michgopw2 accuracy_millionsrushw2 accuracy_dickdurbinw2 accuracy_trumpangryw2 accuracy_whofficialw2 accuracy_trumpforeignw2 accuracy_whsecurityw2 accuracy_repubsvotew2 accuracy_goplawmakerw2 accuracy_demrunningw2 accuracy_demsworryw2 accuracy_worldfeelsw2 accuracy_twoyearstudyw2 accuracy_muellerw2 accuracy_ndcongressw2 {
gen binary_`var'=(`var'>2 & `var'<5) if `var'!=.
}

**sharing**
gen share_muellerw2 = headline_share_1_w2
gen share_ndcongressw2 = headline_share_2_w2
gen share_michgopw2 = headline_share_3_w2
gen share_trumpsisterw2 = headline_share_4_w2
gen share_worldfeelsw2 = headline_share_5_w2
gen share_twoyearstudyw2 = headline_share_6_w2
gen share_millionsrushw2 = headline_share_7_w2
gen share_dickdurbinw2 = headline_share_8_w2
gen share_whofficialw2 = headline_share_9_w2
gen share_trumpforeignw2 = headline_share_10_w2
gen share_whsecurityw2 = headline_share_11_w2
gen share_trumpangryw2 = headline_share_12_w2
gen share_goplawmakerw2 = headline_share_13_w2
gen share_demsworryw2 = headline_share_14_w2
gen share_repubsvotew2 = headline_share_15_w2
gen share_demrunningw2 = headline_share_16_w2



**fake mean
egen share_fake_meanw2 = rowmean(share_trumpsisterw2 share_michgopw2 share_millionsrushw2 share_dickdurbinw2)
**real mean
egen share_real_meanw2 = rowmean(share_trumpangryw2 share_whofficialw2 share_trumpforeignw2 share_whsecurityw2 share_repubsvotew2 share_goplawmakerw2 share_demrunningw2 share_demsworryw2)
**hyper mean 
egen share_hyper_meanw2 = rowmean(share_worldfeelsw2 share_twoyearstudyw2 share_muellerw2 share_ndcongressw2) 
**all mean
egen share_all_meanw2 = rowmean(share_trumpsisterw2 share_michgopw2 share_millionsrushw2 share_dickdurbinw2 share_trumpangryw2 share_whofficialw2 share_trumpforeignw2 share_whsecurityw2 share_repubsvotew2 share_goplawmakerw2 share_demrunningw2 share_demsworryw2 share_worldfeelsw2 share_twoyearstudyw2 share_muellerw2 share_ndcongressw2) 

**mean_acc_diff 
gen mean_share_diffw2 = share_real_meanw2 - share_fake_meanw2




**FTs**
gen FT_dem_w2 = pol_therm_dem_w2 
gen FT_rep_w2 = pol_therm_rep_w2 
gen FT_trump_w2 = pol_therm_trump_w2 
gen FT_media_w2 = pol_therm_media_w2 

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


**pol behavior 

gen vote = plan_vote_w2
gen vote_certain = plan_vote_certain_w2
recode vote 1=0 2=1 3=2 else=0
recode vote_certain 1=4 2=3 3=2 else=0
gen vote_combined = vote + vote_certain 
gen vote_binary = vote_combined
recode vote_binary 4=1 3=1 else=0

gen action1 = pol_action_button_w2
gen action2 = pol_action_volunteer_w2
gen action3 = pol_action_rally_w2
gen action4 = pol_action_talk_w2
gen action5 = pol_action_donate_w2

recode action1 1=5 2=4 3=3 4=2 5=1 /* recode likely high */
recode action2 1=5 2=4 3=3 4=2 5=1 
recode action3 1=5 2=4 3=3 4=2 5=1 
recode action4 1=5 2=4 3=3 4=2 5=1 
recode action5 1=5 2=4 3=3 4=2 5=1 

egen polact_mean =rowmean (action1  action2   action3   action4   action5)

**topical misperceptions**

gen mis_pro_d_truew2 = misinform_meddle_w2
gen mis_pro_r_truew2 = misinform_unemploy_w2
gen mis_pro_d_falsew2 = misinform_kennedy_w2
gen mis_pro_r_falsew2 = misinform_crime_w2

egen mistrue_meanw2 = rowmean(mis_pro_d_truew2  mis_pro_r_truew2)
egen misfalse_meanw2 = rowmean(mis_pro_d_falsew2  mis_pro_r_falsew2)

gen topical_accuracy_diff_w2 = mistrue_meanw2 - misfalse_meanw2


/*PREREGISTERED ANALYSIS*/

/*A. OBSERVATIONAL HYPOTHESES*/

*NOTE: If making multi-column tables, beware cross-column inconsistency in use of survey weights. Can't use for clustered models; see below.

/*Observational covariates: Democrats and Republicans (including leaners), political knowledge (0-8) and interest (1-4), having a four-year college degree (0/1), self-identifying as a female (0/1) or non-white (0/1), and age group dummies (30-44, 45-59, 60+, 18-29 omitted).*/

/*H-A1) People with the strongest overall tendencies toward selective exposure will be the most likely to consume fake news and consume the most on average. (This hypothesis tests if the Guess et al. results replicate in this sample.)

Observational hypotheses
For H-A1, the outcome measure is exposure to fake news (binary/count/share of information diet):
Fake news exposure = [constant] + selective exposure decile indicators + covariates listed above*/

replace decile="" if decile=="NA"
destring decile, replace

svyset [pweight=weight]

*2016 def
svy: reg totalprotrumpfnbinary_ag80 i.decile dem_leaners repub_leaners polknow polint college female nonwhite ib1.agecat
est store A

svy: reg totalproclintonfnbinary_ag80 i.decile dem_leaners repub_leaners polknow polint college female nonwhite ib1.agecat
est store B

svy: reg totalprotrumpfncount_ag80 i.decile dem_leaners repub_leaners polknow polint college female nonwhite ib1.agecat
est store C

svy: reg totalproclintonfncount_ag80 i.decile dem_leaners repub_leaners polknow polint college female nonwhite ib1.agecat
est store D

estout A C B D using "decile-table-june18-2016def.tex", replace varwidth(25) collabels("") cells(b(star fmt(%9.3f)) se(par fmt(%9.3f))) stats(r2 N, fmt(%9.2f %9.0f) labels("R^2" "N")) starlevels(* 0.05 ** 0.01) style(tex)

gen proTfrac=totalprotrumpfncount_ag80/totalnewsfncount2016def
gen proCfrac=totalproclintonfncount_ag80/totalnewsfncount2016def

svy: reg proTfrac i.decile dem_leaners repub_leaners polknow polint college female nonwhite ib1.agecat
est store C
svy: reg proCfrac i.decile dem_leaners repub_leaners polknow polint college female nonwhite ib1.agecat
est store D

estout A C B D using "decile-table-share-june18-2016def.tex", replace varwidth(25) collabels("") cells(b(star fmt(%9.4f)) se(par fmt(%9.4f))) stats(r2 N, fmt(%9.2f %9.0f) labels("R^2" "N")) starlevels(* 0.05 ** 0.01) style(tex)

gen totalfakenewsbinary_new=(totalprorepfnbinary==1 | totalprodemfnbinary==1) if nopulse==0
gen totalfakenewscount_new=(totalprorepfncount+totalprodemfncount) if nopulse==0

svy: reg totalfakenewscount_new i.decile dem_leaners repub_leaners polknow polint college female nonwhite ib1.agecat
estimates store fakecountJune, title(fakecountJune) 
svy: reg totalfakenewsbinary_new i.decile dem_leaners repub_leaners polknow polint college female nonwhite ib1.agecat
estimates store fakebinaryJune, title(fakebinaryJune) 

**new T1 mpsa
svy: reg totalprodemfncount crt_average dem_leaners repub_leaners polknow polint college female nonwhite ib1.agecat
estimates store demfakecountJune, title(demfakecountJune) 
lincom repub_leaners - dem_leaners
svy: reg totalprorepfncount crt_average dem_leaners repub_leaners polknow polint college female nonwhite ib1.agecat
estimates store repfakecountJune, title(repfakecountJune) 
lincom repub_leaners - dem_leaners

gen proDfrac=totalprodemfncount/totalnewsfncount2018def
gen proRfrac=totalprorepfncount/totalnewsfncount2018def

svy: reg totalprorepfnbinary i.decile dem_leaners repub_leaners polknow polint college female nonwhite ib1.agecat
est store A
svy: reg totalprodemfnbinary i.decile dem_leaners repub_leaners polknow polint college female nonwhite ib1.agecat
est store B
svy: reg proRfrac i.decile dem_leaners repub_leaners polknow polint college female nonwhite ib1.agecat
est store C
svy: reg proDfrac i.decile dem_leaners repub_leaners polknow polint college female nonwhite ib1.agecat
est store D

estout A C B D using "decile-table-share-june18-2018def.tex", replace varwidth(25) collabels("") cells(b(star fmt(%9.4f)) se(par fmt(%9.4f))) stats(r2 N, fmt(%9.2f %9.0f) labels("R^2" "N")) starlevels(* 0.05 ** 0.01) style(tex)

*not preregistered, same table with no party controls

svy: reg totalprotrumpfnbinary_ag80 i.decile polknow polint college female nonwhite ib1.agecat
est store A
svy: reg totalproclintonfnbinary_ag80 i.decile polknow polint college female nonwhite ib1.agecat
est store B
svy: reg proTfrac i.decile polknow polint college female nonwhite ib1.agecat
est store C
svy: reg proCfrac i.decile polknow polint college female nonwhite ib1.agecat
est store D

estout A C B D using "decile-table-share-no-party-june18-2016def.tex", replace varwidth(25) collabels("") cells(b(star fmt(%9.4f)) se(par fmt(%9.4f))) stats(r2 N, fmt(%9.2f %9.0f) labels("R^2" "N")) starlevels(* 0.05 ** 0.01) style(tex)
/*
*replication graphs

label def replab2 1 "Republicans" 0 "Democrats"
label val repub_leaners replab2

preserve

rename totalproclintonfnbinary_ag80 view1 
rename totalprotrumpfnbinary_ag80 view2
reshape long view, i(caseid) j(type)
label def foxfake 1 "Pro-Clinton fake news (2016)" 2 "Pro-Trump fake news (2016)"
label val type foxfake

cibar view if (dem_leaners==1 | repub_leaners==1) [pweight=weight], over1(type) over2(repub_leaners) bargap(8) gap(35) graphopts(graphregion(fcolor(white) ifcolor(none)) plotregion(fcolor(none) lcolor(white) ifcolor(none) ilcolor(none)) legend(row(1) pos(6) region(lpattern(solid) lcolor(black))) yscale(r(0 .51)) ytitle("") scheme(lean1) ylab(0 "0%" .1 "10%" .2 "20%" .3 "30%" .4 "40%" .5 "50%",angle(0) grid glcolor(gs3)))
graph export "fnbinary-nk-ci-4bar-june18.pdf",replace

cibar view if (dem_leaners==1 | repub_leaners==1) [pweight=weight], over1(type) over2(repub_leaners) bargap(8) gap(35) graphopts(graphregion(fcolor(white) ifcolor(none)) plotregion(fcolor(none) lcolor(white) ifcolor(none) ilcolor(none)) legend(row(1) pos(6) region(lpattern(solid) lcolor(black)))  ytitle("") scheme(lean1) yscale(r(0 .31))  ylab(0 "0%" .1 "10%" .2 "20%" .3 "30%",angle(0) grid glcolor(gs3)))
graph export "fnbinary-nk-ci-4bar-june18-scale.pdf",replace

restore

preserve

rename totalprodemfnbinary view1 
rename totalprorepfnbinary view2
reshape long view, i(caseid) j(type)
label def foxfake 1 "Pro-Democrat fake news" 2 "Pro-Republican fake news"
label val type foxfake

cibar view if (dem_leaners==1 | repub_leaners==1) [pweight=weight], over1(type) over2(repub_leaners) bargap(8) gap(35) graphopts(graphregion(fcolor(white) ifcolor(none)) plotregion(fcolor(none) lcolor(white) ifcolor(none) ilcolor(none)) legend(row(1) pos(6) region(lpattern(solid) lcolor(black)))  ytitle("") scheme(lean1) yscale(r(0 .51)) ylab(0 "0%" .1 "10%" .2 "20%" .3 "30%" .4 "40%" .5 "50%",angle(0) grid glcolor(gs3)))
graph export "fnbinary-nk-ci-4bar-june18-newdvs.pdf",replace

restore

preserve

rename proCfrac view1 
rename proTfrac view2
reshape long view, i(caseid) j(type)
label def foxfake 1 "Pro-Clinton fake news (2016)" 2 "Pro-Trump fake news (2016)"
label val type foxfake

cibar view if (dem_leaners==1 | repub_leaners==1) [pweight=weight], over1(type) over2(repub_leaners) bargap(8) gap(35) graphopts(graphregion(fcolor(white) ifcolor(none)) plotregion(fcolor(none) lcolor(white) ifcolor(none) ilcolor(none)) legend(row(1) pos(6) region(lpattern(solid) lcolor(black)))  ytitle("") scheme(lean1) yscale(r(0 0.061)) ylab(0 "0%" .01 "1%" .02 "2%" .03 "3%" .04 "4%" .05 "5%" .06 "6%",angle(0) grid glcolor(gs3)))

graph export "fnprop-nk-ci-4bar-june18.pdf",replace

cibar view if (dem_leaners==1 | repub_leaners==1) [pweight=weight], over1(type) over2(repub_leaners) bargap(8) gap(35) graphopts(graphregion(fcolor(white) ifcolor(none)) plotregion(fcolor(none) lcolor(white) ifcolor(none) ilcolor(none)) legend(row(1) pos(6) region(lpattern(solid) lcolor(black)))  ytitle("") scheme(lean1) yscale(r(0 .03)) ylab(0 "0%" .01 "1%" .02 "2%" .03 "3%",angle(0) grid glcolor(gs3)))

graph export "fnprop-nk-ci-4bar-june18-scale.pdf",replace

restore


preserve

rename proDfrac view1 
rename proRfrac view2
reshape long view, i(caseid) j(type)
label def foxfake 1 "Pro-Democrat fake news" 2 "Pro-Republican fake news"
label val type foxfake

cibar view if (dem_leaners==1 | repub_leaners==1) [pweight=weight], over1(type) over2(repub_leaners) bargap(8) gap(35) graphopts(graphregion(fcolor(white) ifcolor(none)) plotregion(fcolor(none) lcolor(white) ifcolor(none) ilcolor(none)) legend(row(1) pos(6) region(lpattern(solid) lcolor(black)))  ytitle("") scheme(lean1) yscale(r(0 .071)) ylab(0 "0%" .01 "1%" .02 "2%" .03 "3%" .04 "4%" .05 "5%" .06 "6%" .07 "7%",angle(0) grid glcolor(gs3)))

graph export "fnprop-nk-ci-4bar-june18-newdvs.pdf",replace

restore

preserve

matrix points=(1,1,.,.,.,0 \ 1,2,.,.,.,1 \ 2,4,.,.,.,0 \ 2,5,.,.,.,1 \ 3,7,.,.,.,0 \ 3,8,.,.,.,1 \ 4,10,.,.,.,0 \ 4,11,.,.,.,1 \ 5,13,.,.,.,0 \ 5,14,.,.,.,1 \ 6,16,.,.,.,0 \ 6,17,.,.,.,1 \ 7,19,.,.,.,0 \ 7,20,.,.,.,1 \ 8,22,.,.,.,0 \ 8,23,.,.,.,1 \ 9,25,.,.,.,0 \ 9,26,.,.,.,1 \ 10,28,.,.,.,0 \ 10,29,.,.,.,1)

forval i=1/10 {
svy,subpop(if decile==`i'): mean totalproclintonfnbinary_ag80
return list
local j=1+(2*(`i'-1))
matrix table=r(table)
matrix points[`j',3]=table[1,1]
matrix points[`j',4]=table[5,1]
matrix points[`j',5]=table[6,1]
display `i' `j'
}

forval i=1/10 {
svy,subpop(if decile==`i'): mean totalprotrumpfnbinary_ag80
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

graph twoway (bar mean fakenum if type==0) (bar mean fakenum if type==1) (rspike ll ul fakenum if type==0) (rspike ll ul fakenum if type==1, scheme(lean1) xlab(1.5 "1" 4.5 "2" 7.5 "3" 10.5 "4" 13.5 "5" 16.5 "6" 19.5 "7" 22.5 "8" 25.5 "9" 28.5 "10") yscale(r(0.01 .81)) ylab(0 "0%" .2 "20%" .4 "40%" .6 "60%" .8 "80%", grid glcolor(gs3)) graphregion(fcolor(white) ifcolor(none)) plotregion(fcolor(none) lcolor(white) ifcolor(none) ilcolor(none)) ytitle("") legend(row(1) pos(6) region(lpattern(solid) lcolor(black)) order (1 "Pro-Clinton (2016)" 2 "Pro-Trump (2016)")) xtitle("Average media diet slant decile (liberal to conservative)"))  
graph export "decileslantbinary-june18.pdf", replace

list decilenum fakenum mean ll ul type if _n<21

restore

preserve

matrix points=(1,1,.,.,.,0 \ 1,2,.,.,.,1 \ 2,4,.,.,.,0 \ 2,5,.,.,.,1 \ 3,7,.,.,.,0 \ 3,8,.,.,.,1 \ 4,10,.,.,.,0 \ 4,11,.,.,.,1 \ 5,13,.,.,.,0 \ 5,14,.,.,.,1 \ 6,16,.,.,.,0 \ 6,17,.,.,.,1 \ 7,19,.,.,.,0 \ 7,20,.,.,.,1 \ 8,22,.,.,.,0 \ 8,23,.,.,.,1 \ 9,25,.,.,.,0 \ 9,26,.,.,.,1 \ 10,28,.,.,.,0 \ 10,29,.,.,.,1)

forval i=1/10 {
svy,subpop(if decile==`i'): mean totalprodemfnbinary 
return list
local j=1+(2*(`i'-1))
matrix table=r(table)
matrix points[`j',3]=table[1,1]
matrix points[`j',4]=table[5,1]
matrix points[`j',5]=table[6,1]
display `i' `j'
}

forval i=1/10 {
svy,subpop(if decile==`i'): mean totalprorepfnbinary
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
graph export "decileslantbinary-june18-newdvs.pdf", replace

list decilenum fakenum mean ll ul type if _n<21

restore


preserve

matrix points=(1,1,.,.,.,0 \ 1,2,.,.,.,1 \ 2,4,.,.,.,0 \ 2,5,.,.,.,1 \ 3,7,.,.,.,0 \ 3,8,.,.,.,1 \ 4,10,.,.,.,0 \ 4,11,.,.,.,1 \ 5,13,.,.,.,0 \ 5,14,.,.,.,1 \ 6,16,.,.,.,0 \ 6,17,.,.,.,1 \ 7,19,.,.,.,0 \ 7,20,.,.,.,1 \ 8,22,.,.,.,0 \ 8,23,.,.,.,1 \ 9,25,.,.,.,0 \ 9,26,.,.,.,1 \ 10,28,.,.,.,0 \ 10,29,.,.,.,1)

forval i=1/10 {
svy,subpop(if decile==`i'): mean proCfrac 
return list
local j=1+(2*(`i'-1))
matrix table=r(table)
matrix points[`j',3]=table[1,1]
matrix points[`j',4]=table[5,1]
matrix points[`j',5]=table[6,1]
display `i' `j'
}

forval i=1/10 {
svy,subpop(if decile==`i'): mean proTfrac
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

graph twoway (bar mean fakenum if type==0) (bar mean fakenum if type==1) (rspike ll ul fakenum if type==0) (rspike ll ul fakenum if type==1, scheme(lean1) xlab(1.5 "1" 4.5 "2" 7.5 "3" 10.5 "4" 13.5 "5" 16.5 "6" 19.5 "7" 22.5 "8" 25.5 "9" 28.5 "10") yscale(r(0 .101)) ylab(0 "0%" .02 "2%" .04 "4%" .06 "6%" .08 "8%" .1 "10%", grid glcolor(gs3)) graphregion(fcolor(white) ifcolor(none)) plotregion(fcolor(none) lcolor(white) ifcolor(none) ilcolor(none)) ytitle("") legend(row(1) pos(6) region(lpattern(solid) lcolor(black)) order (1 "Pro-Clinton (2016)" 2 "Pro-Trump (2016)")) xtitle("Average media diet slant decile (liberal to conservative)"))  
graph export "decileslantdiet-june18.pdf", replace

list decilenum fakenum mean ll ul type if _n<21

restore

preserve

matrix points=(1,1,.,.,.,0 \ 1,2,.,.,.,1 \ 2,4,.,.,.,0 \ 2,5,.,.,.,1 \ 3,7,.,.,.,0 \ 3,8,.,.,.,1 \ 4,10,.,.,.,0 \ 4,11,.,.,.,1 \ 5,13,.,.,.,0 \ 5,14,.,.,.,1 \ 6,16,.,.,.,0 \ 6,17,.,.,.,1 \ 7,19,.,.,.,0 \ 7,20,.,.,.,1 \ 8,22,.,.,.,0 \ 8,23,.,.,.,1 \ 9,25,.,.,.,0 \ 9,26,.,.,.,1 \ 10,28,.,.,.,0 \ 10,29,.,.,.,1)

forval i=1/10 {
svy,subpop(if decile==`i'): mean proDfrac 
return list
local j=1+(2*(`i'-1))
matrix table=r(table)
matrix points[`j',3]=table[1,1]
matrix points[`j',4]=table[5,1]
matrix points[`j',5]=table[6,1]
display `i' `j'
}

forval i=1/10 {
svy,subpop(if decile==`i'): mean proRfrac
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
graph export "decileslantdiet-june18-newDVs.pdf", replace

list decilenum fakenum mean ll ul type if _n<21

restore

preserve

matrix points=(1,1,.,.,.,0 \ 1,2,.,.,.,1 \ 2,4,.,.,.,0 \ 2,5,.,.,.,1 \ 3,7,.,.,.,0 \ 3,8,.,.,.,1 \ 4,10,.,.,.,0 \ 4,11,.,.,.,1 \ 5,13,.,.,.,0 \ 5,14,.,.,.,1 \ 6,16,.,.,.,0 \ 6,17,.,.,.,1 \ 7,19,.,.,.,0 \ 7,20,.,.,.,1 \ 8,22,.,.,.,0 \ 8,23,.,.,.,1 \ 9,25,.,.,.,0 \ 9,26,.,.,.,1 \ 10,28,.,.,.,0 \ 10,29,.,.,.,1)

forval i=1/10 {
svy,subpop(if decile==`i'): mean totalproclintonfncount_ag80 
return list
local j=1+(2*(`i'-1))
matrix table=r(table)
matrix points[`j',3]=table[1,1]
matrix points[`j',4]=table[5,1]
matrix points[`j',5]=table[6,1]
display `i' `j'
}

forval i=1/10 {
svy,subpop(if decile==`i'): mean totalprotrumpfncount_ag80
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

graph twoway (bar mean fakenum if type==0) (bar mean fakenum if type==1) (rspike ll ul fakenum if type==0) (rspike ll ul fakenum if type==1, scheme(lean1) xlab(1.5 "1" 4.5 "2" 7.5 "3" 10.5 "4" 13.5 "5" 16.5 "6" 19.5 "7" 22.5 "8" 25.5 "9" 28.5 "10") yscale(r(0 20.5)) ylab(0(5)20, grid glcolor(gs3)) graphregion(fcolor(white) ifcolor(none)) plotregion(fcolor(none) lcolor(white) ifcolor(none) ilcolor(none)) ytitle("") legend(row(1) pos(6) region(lpattern(solid) lcolor(black)) order (1 "Pro-Clinton (2016)" 2 "Pro-Trump (2016)")) xtitle("Average media diet slant decile (liberal to conservative)"))  
graph export "decileslantcount-june18.pdf", replace

list decilenum fakenum mean ll ul type if _n<21

restore

preserve

matrix points=(1,1,.,.,.,0 \ 1,2,.,.,.,1 \ 2,4,.,.,.,0 \ 2,5,.,.,.,1 \ 3,7,.,.,.,0 \ 3,8,.,.,.,1 \ 4,10,.,.,.,0 \ 4,11,.,.,.,1 \ 5,13,.,.,.,0 \ 5,14,.,.,.,1 \ 6,16,.,.,.,0 \ 6,17,.,.,.,1 \ 7,19,.,.,.,0 \ 7,20,.,.,.,1 \ 8,22,.,.,.,0 \ 8,23,.,.,.,1 \ 9,25,.,.,.,0 \ 9,26,.,.,.,1 \ 10,28,.,.,.,0 \ 10,29,.,.,.,1)

forval i=1/10 {
svy,subpop(if decile==`i'): mean totalprodemfncount 
return list
local j=1+(2*(`i'-1))
matrix table=r(table)
matrix points[`j',3]=table[1,1]
matrix points[`j',4]=table[5,1]
matrix points[`j',5]=table[6,1]
display `i' `j'
}

forval i=1/10 {
svy,subpop(if decile==`i'): mean totalprorepfncount
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
graph export "decileslantcount-june18-newdvs.pdf", replace

list decilenum fakenum mean ll ul type if _n<21

restore
*/

/*code intervention*/
gen dynamic=(instructions_treat==2)

foreach var of varlist tips_check* {
tab `var' dynamic, chi col
}

/*how many saw*/
gen miss_tips_binary=(tips_check1b!=. | tips_check2b!=. | tips_check3b!=.)
tab miss_tips_binary

gen miss_tips_total=(tips_check1b!=.)+(tips_check2b!=.)+(tips_check3b!=.)
tab miss_tips_total

/*w1 reshape*/

forval i=1/8 {
rename accuracy`i' accuracy_shown_`i'
}

preserve

*accuracy reshape
rename accuracy_trumpsister accuracy1
rename accuracy_michgop accuracy2
rename accuracy_millionsrush accuracy3
rename accuracy_dickdurbin accuracy4
rename accuracy_trumpangry accuracy5 
rename accuracy_whofficial accuracy6 
rename accuracy_trumpforeign accuracy7
rename accuracy_whsecurity accuracy8
rename accuracy_repubsvote accuracy9
rename accuracy_goplawmaker accuracy10 
rename accuracy_demrunning accuracy11 
rename accuracy_demsworry accuracy12
rename accuracy_worldfeels accuracy13
rename accuracy_twoyearstudy accuracy14
rename accuracy_mueller accuracy15 
rename accuracy_ndcongress accuracy16

forval i=1/16 {
svy: tab accuracy`i'
}

reshape long accuracy,i(caseid) j(dv)

gen fake=(dv<5)
gen real=(dv>4 & dv<13)
gen hyper=(dv>12 & dv!=.)

/*congeniality coding has to be here*/

*pro d real: *whsecurity = 10 *whofficial = 8 *trumpangry = 5 *trumpforeign = 9
*pro r real: *goplawmaker = 7 *demworry = 12 *demrunning = 11 *repubvote = 13
*pro d fake: *trump sister = 1 michgop = 3
*pro r fake: millionsrush = 15 , dickdurbin = 16
*pro d hyper mueller = 6 ndcong = 4
*pro r hyper worldfeels = 14, twoyearstudy = 2

gen pro_d=(dv==8 | dv==6 | dv==5 | dv==7 | dv==1 | dv==2 | dv==15 | dv==16)
gen pro_r=(dv==10 | dv==12 | dv==11 | dv==9 | dv==3 | dv==4 | dv==13 | dv==14)
gen congenial=(pro_d==1 & dem_leaner==1) | (pro_r==1 & repub_leaner==1)
gen uncongenial=(pro_r==1 & dem_leaner==1) | (pro_d==1 & repub_leaner==1)

gen binary_accuracy=(accuracy>2 & accuracy<5)

reg accuracy congenial uncongenial crt_average polknow polint college female nonwhite ib1.agecat i.dv if fake==1, robust cluster(caseid)
estimates store acc_corrw1June, title(acc_corrJune1) 

*preserve
*collapse (mean) accuracy binary_accuracy [pweight=weight],by(fake real hyper)
*sort fake real hyper
*list
*restore

gen type=.
replace type=1 if fake==1
replace type=2 if hyper==1
replace type=3 if real==1

label def typelab 1 "Fake news" 2 "Hyper-partisan news" 3 "Real news"
label val type typelab

/*
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

/*checking instructions effect*/

reg accuracy dynamic i.dv if fake==1, robust cluster(caseid)
reg accuracy dynamic##miss_tips_binary i.dv if fake==1, robust cluster(caseid) /*exploratory*/
reg accuracy dynamic i.dv if real==1, robust cluster(caseid)
reg accuracy dynamic##miss_tips_binary i.dv if real==1, robust cluster(caseid) /*exploratory*/
reg accuracy dynamic i.dv if hyper==1, robust cluster(caseid)
reg accuracy dynamic##miss_tips_binary i.dv if hyper==1, robust cluster(caseid) /*exploratory*/

/*H-A2) People who consume fake news will be more likely to believe it is accurate than those who do not consume fake news (H-A2a). This relationship will be stronger for pro-attitudinal fake news belief than for counter-attitudinal fake news belief (H-A2b) and for people who are relatively less skilled at analytical reasoning (H-A2c). 

H-A2a: Fake news accuracy = [constant] + prior fake news exposure + covariates listed above
H-A2b: Fake news accuracy = [constant] + prior fake news exposure + congenial + prior fake + news exposure * congenial + covariates listed above
H-A2c: Fake news accuracy = [constant] + prior fake news exposure + CRT score + prior fake + news exposure * CRT score + covariates listed above*/

/*note: prereg ambiguous about whether we need to run for binary version but including since we’re doing that when fake news is a DV*/

/*note: can’t cluster with survey weights so omitting, might want to do robustness check with weights and no clustering - e.g., with respondent fixed effects or random effects or something*/

*2018 defs
reg accuracy totalfakecount18_pre dem_leaners repub_leaners polknow polint college female nonwhite ib1.agecat i.dv if fake==1, robust cluster(caseid)
reg accuracy totalfakebinary18_pre dem_leaners repub_leaners polknow polint college female nonwhite ib1.agecat i.dv if fake==1, robust cluster(caseid)

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
reg accuracy c.totalfakecount18_pre##i.congenial repub_leaners polknow polint college female nonwhite ib1.agecat if fake==1 & independent==0, robust cluster(caseid)
estimates store acc_correlatesjune_count, title(acc_correlatesjune_count) 
reg accuracy totalfakebinary18_pre##i.congenial repub_leaners polknow polint college female nonwhite ib1.agecat if fake==1 & independent==0, robust cluster(caseid)
estimates store acc_correlatesjune_binary, title(acc_correlatesjune_binary) 

*2016 defs
reg accuracy c.totalfakenewscount_pre##i.congenial repub_leaners polknow polint college female nonwhite ib1.agecat if fake==1 & independent==0, robust cluster(caseid)
reg accuracy totalfakenewsbinary_pre##i.congenial repub_leaners polknow polint college female nonwhite ib1.agecat if fake==1 & independent==0, robust cluster(caseid)
*to avoid sample changing within multi-column table, have to run other models on this group too FWIW. (or we code congeniality as 0 for independents but that's ill-defined and exploratory.)*/

*2018 defs
reg accuracy c.totalfakecount18_pre##i.crt_terc dem_leaners repub_leaners polknow polint college female nonwhite ib1.agecat if fake==1, robust cluster(caseid)
reg accuracy c.totalfakebinary18_pre##i.crt_terc dem_leaners repub_leaners polknow polint college female nonwhite ib1.agecat if fake==1, robust cluster(caseid)

*2016 defs
reg accuracy c.totalfakenewscount_pre##i.crt_terc dem_leaners repub_leaners polknow polint college female nonwhite ib1.agecat if fake==1, robust cluster(caseid)
reg accuracy c.totalfakenewsbinary_pre##i.crt_terc dem_leaners repub_leaners polknow polint college female nonwhite ib1.agecat if fake==1, robust cluster(caseid)

*descriptive graphs

label def fndef 0 "No fake news" 1 "Fake news"
label val totalfakenewsbinary_pre fndef
label val totalfakebinary18_pre fndef

gen bs=1

/*
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

*separate reshape for w2 accuracy ratings

preserve

/*w2 reshape*/

*accuracy reshape
rename accuracy_trumpsisterw2 accuracyw21
rename accuracy_michgopw2 accuracyw22
rename accuracy_millionsrushw2 accuracyw23
rename accuracy_dickdurbinw2 accuracyw24
rename accuracy_trumpangryw2 accuracyw25 
rename accuracy_whofficialw2 accuracyw26 
rename accuracy_trumpforeignw2 accuracyw27
rename accuracy_whsecurityw2 accuracyw28
rename accuracy_repubsvotew2 accuracyw29
rename accuracy_goplawmakerw2 accuracyw210 
rename accuracy_demrunningw2 accuracyw211 
rename accuracy_demsworryw2 accuracyw212
rename accuracy_worldfeelsw2 accuracyw213
rename accuracy_twoyearstudyw2 accuracyw214
rename accuracy_muellerw2 accuracyw215 
rename accuracy_ndcongressw2 accuracyw216

forval i=1/16 {
svy: tab accuracyw2`i'
}

reshape long accuracyw2,i(caseid) j(dv)

gen fake=(dv<5)
gen real=(dv>4 & dv<13)
gen hyper=(dv>12 & dv!=.)

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

*2018 defs
reg accuracyw2 c.totalfakecount18_pre##i.crt_terc dem_leaners repub_leaners polknow polint college female nonwhite ib1.agecat if fake==1, robust cluster(caseid)
reg accuracyw2 c.totalfakebinary18_pre##i.crt_terc dem_leaners repub_leaners polknow polint college female nonwhite ib1.agecat if fake==1, robust cluster(caseid)

*2016 defs
reg accuracyw2 c.totalfakenewscount_pre##i.crt_terc dem_leaners repub_leaners polknow polint college female nonwhite ib1.agecat if fake==1, robust cluster(caseid)
reg accuracyw2 c.totalfakenewsbinary_pre##i.crt_terc dem_leaners repub_leaners polknow polint college female nonwhite ib1.agecat if fake==1, robust cluster(caseid)

foreach var of varlist accuracy_trumpsister accuracy_michgop accuracy_millionsrush accuracy_dickdurbin accuracy_trumpangry accuracy_whofficial accuracy_trumpforeign accuracy_whsecurity accuracy_repubsvote accuracy_goplawmaker accuracy_demrunning accuracy_demsworry accuracy_worldfeels accuracy_twoyearstudy accuracy_mueller accuracy_ndcongress {
gen saw_`var'=(`var'!=.)
}

gen saw=0
replace saw=1 if (dv==1 & saw_accuracy_trumpsister==1) | (dv==2 & saw_accuracy_michgop==1) | (dv==3 & saw_accuracy_millions==1) | (dv==4 & saw_accuracy_dickdurb==1) | (dv==5 & saw_accuracy_trumpang==1) | (dv==6 & saw_accuracy_whoffic==1) | (dv==7 & saw_accuracy_trumpf==1) | (dv==8 & saw_accuracy_whsec==1) | (dv==9 & saw_accuracy_repubsvote==1) | (dv==10 & saw_accuracy_goplaw==1) | (dv==11 & saw_accuracy_demrun==1) | (dv==12 & saw_accuracy_demsw==1) | (dv==13 & saw_accuracy_worldf==1) | (dv==14 & saw_accuracy_twoy==1) | (dv==15 & saw_accuracy_muell==1) | (dv==16 & saw_accuracy_ndc==1)

/*congeniality coding has to be here*/

*pro d real: *whsecurity = 10 *whofficial = 8 *trumpangry = 5 *trumpforeign = 9
*pro r real: *goplawmaker = 7 *demworry = 12 *demrunning = 11 *repubvote = 13
*pro d fake: *trump sister = 1 michgop = 3
*pro r fake: millionsrush = 15 , dickdurbin = 16
*pro d hyper mueller = 6 ndcong = 4
*pro r hyper worldfeels = 14, twoyearstudy = 2

gen pro_d=(dv==8 | dv==6 | dv==5 | dv==7 | dv==1 | dv==2 | dv==15 | dv==16)
gen pro_r=(dv==10 | dv==12 | dv==11 | dv==9 | dv==3 | dv==4 | dv==13 | dv==14)
gen congenial=(pro_d==1 & dem_leaner==1) | (pro_r==1 & repub_leaner==1)
gen uncongenial=(pro_r==1 & dem_leaner==1) | (pro_d==1 & repub_leaner==1)

gen binary_accuracyw2=(accuracyw2>2 & accuracyw2<5)

reg accuracyw2 congenial uncongenial crt_average saw polknow polint college female nonwhite ib1.agecat i.dv if fake==1, robust cluster(caseid)
estimates store acc_corrw2June, title(acc_corrJune2) 

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

/*
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
*/

reg accuracyw2 saw i.dv, robust cluster(caseid)

**prior exposure 
reg accuracyw2 saw i.dv if fake==1, robust cluster(caseid)
estimates store t3c1, title(prior exposure effect on fake news) 
reg accuracyw2 saw i.dv if hyper==1, robust cluster(caseid)
reg accuracyw2 saw i.dv if real==1, robust cluster(caseid)
estimates store t3c2, title(prior exposure effect on real news) 

**prior exposure with LASSO
reg accuracyw2 saw polknow polint FT_trump  affect_merged_leanersw1 conspiracy_mean i.dv if fake==1, robust cluster(caseid)
estimates store tA3c1, title(prior exposure effect on fake news) 
reg accuracyw2 saw polknow polint FT_trump  affect_merged_leanersw1 conspiracy_mean i.dv if hyper==1, robust cluster(caseid)
reg accuracyw2 saw polknow polint FT_trump  affect_merged_leanersw1 conspiracy_mean i.dv if real==1, robust cluster(caseid)
estimates store tA3c2, title(prior exposure effect on real news) 

*preserve
*collapse (mean) accuracyw2 binary_accuracyw2 [pweight=weight] if independents==0,by(fake real hyper congenial uncongenial)
*sort fake real hyper congenial
*list
*restore

restore

*2018 defs
svy: reg mean_acc_diffw2 totalfakecount18_pre dem_leaners repub_leaners polknow polint college female nonwhite ib1.agecat 
svy: reg mean_acc_diffw2 totalfakebinary18_pre dem_leaners repub_leaners polknow polint college female nonwhite ib1.agecat 

*2016 defs
svy: reg mean_acc_diffw2 totalfakenewscount_pre dem_leaners repub_leaners polknow polint college female nonwhite ib1.agecat 
svy: reg mean_acc_diffw2 totalfakenewsbinary_pre dem_leaners repub_leaners polknow polint college female nonwhite ib1.agecat 

preserve

*new reshape

*accuracy reshape
rename misinform_melania topical_accuracy1
rename misinform_fonda topical_accuracy2
rename misinform_cry topical_accuracy3
rename misinform_separation topical_accuracy4

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

***W2 topical misperceptions here

*accuracy reshape
rename misinform_kennedy_w2 topical_accuracy1
rename misinform_meddle_w2 topical_accuracy2
rename misinform_unemploy_w2 topical_accuracy3
rename misinform_crime_w2 topical_accuracy4

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

*****WAITING FOR MEASUREMENT
/*THESE MODELS BELOW ARE CONFUSINGLY SPECIFIED GIVEN THAT EXPOSURE IS MEASURED AT THE DV LEVEL - wouldn’t expect it to affect all beliefs. Let’s revisit once we know if enough people are exposed per discussion in prereg*/

/*H-A4) People who are exposed to topical misinformation will be more likely to indicate believing in it (H-A4a). This relationship will be stronger for pro-attitudinal claims than for counter-attitudinal claims (H-A4b) and for people who are relatively less skilled at analytical reasoning (H-A4c). People who are exposed to topical misinformation will be less likely to successfully distinguish between true and false topical statements (H-A4d).

For H-A4a, H-A4b, and H-A4c, the outcome measure is the perceived accuracy of true and false topical statements. For each of these types of statements, we will estimate the following model using a measure of prior topical misinformation exposure that is specific to the claim in question:
H-A4a: Accuracy = [constant] + prior topical misinformation exposure + prior fake news exposure + covariates listed above
H-A4b: Accuracy = [constant] + prior topical misinformation exposure + congenial + prior topical misinformation exposure * congenial + prior fake news exposure + covariates listed above
H-A4c: Accuracy = [constant] + prior topical misinformation exposure + CRT score + prior topical misinformation exposure * CRT score + prior fake news exposure + covariates listed above*/

/*For H-A4d, the outcome measure = (mean perceived accuracy of true statements - mean perceived accuracy of false statements). This hypothesis is measured at the respondent level using a single mean difference that is not ordered and thus we will only test it using OLS with robust standard errors (i.e., no question fixed effects or clustering).
Outcome = [constant] + prior topical misinformation exposure + fake news exposure + prior fake news exposure + covariates listed above*/

/*threshold to clear:

These models will only be estimated if topical misinformation exposure is sufficiently widespread. A minimum of 394 people are needed per group to have 80% power to detect an effect of Cohen’s d=.2 at p<.05 (two-tailed). The topical misinformation models for each false statement will thus only be estimated if more than 394 people were exposed; otherwise they will be excluded from the manuscript except for a footnote indicating we did not have sufficient power to estimate them.*/

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

foreach var of varlist accuracy_trumpsister accuracy_michgop accuracy_millionsrush accuracy_dickdurbin accuracy_trumpangry accuracy_whofficial accuracy_trumpforeign accuracy_whsecurity accuracy_repubsvote accuracy_goplawmaker accuracy_demrunning accuracy_demsworry accuracy_worldfeels accuracy_twoyearstudy accuracy_mueller accuracy_ndcongress {
gen saw_`var'=(`var'!=.)
}

*fake
foreach var of varlist accuracy_trumpsister accuracy_michgop accuracy_millionsrush accuracy_dickdurbin {
reg `var'w2 saw_`var', robust
}

*real
foreach var of varlist accuracy_trumpangry accuracy_whofficial accuracy_trumpforeign accuracy_whsecurity accuracy_repubsvote accuracy_goplawmaker accuracy_demrunning accuracy_demsworry accuracy_worldfeels {
reg `var'w2 saw_`var', robust
}

*hyper
foreach var of varlist accuracy_twoyearstudy accuracy_mueller accuracy_ndcongress {
reg `var'w2 saw_`var', robust
}

/*Main effects of fake news exposure*/

/*H-E1a. Exposure to pro-attitudinal fake news will increase affective polarization. (Exposure to online criticism of the other party has been found to increase affective polarization (Suhay et al. 2017). Related evidence finds that partisan media can potentially also increase ideological polarization, although the extent of these effects and the groups that are affected remains an ongoing area of research (e.g., Arceneaux and Johnson 2013; Levendusky 2013; see Iyengar et al. N.d. and Prior 2013 for reviews).)

H-E1b. Exposure to pro-attitudinal fake news will increase negative feelings toward the media. (Ladd 2011 finds that exposure to elite media criticism and tabloid-style news increase media distrust, as does talk radio exposure among conservatives. During the 2016 election, fake news often amplified attacks on the mainstream media and used tabloid- and talk radio-style approaches.)

H-E2/E3. Exposure to pro-attitudinal fake news will increase intent to vote (H-E2) and intent to take political action (H-E3). (Negative affect toward the other party, which much fake news promotes, is increasingly associated with political participation (Iyengar and Krupenkin 2018). Similarly, though advertising does not seem to affect net turnout levels, changes in the partisan
balance of advertising affect partisan vote shares (Spenkuch and Toniatti, 2018). Finally, exposure to Fox News was found to particularly increase vote intention among Republicans and independents (Hopkins and Ladd 2014).*/

/* Notes: These analyses require bringing in Pulse data. Pre-reg does not explicitly state how we calculate exposure to congenial fake news or uncongenial fake news for these models (binary vs. count vs. proportion of media diet). Reading section on how we code “congeniality” and separate section on how we define “fake news” to me implies implies binary measure at least as first harbor (but isn’t clear)*/

/*H-E1a. Exposure to pro-attitudinal fake news will increase affective polarization
RQ-F1 What effect does counter-attitudinal fake news exposure have on affective polarization?*/

*drop independents! 

/*For H-E1a and RQ-F1, the outcome measure is affective polarization.
For H-E1b and RQ-F2, the outcome measure is affect toward the media.
For H-E2 and RQ-F3, the outcome measure is intent to vote.
For H-E3 and RQ-F4, the outcome measure is the intent to take political action scale.
Outcome = [constant] + congenial fake news exposure + uncongenial fake news exposure*/

reg affect_polar_lean congenial_fn uncongenial_fn if independents==0, robust
lincom congenial_fn-uncongenial_fn /*didn't preregister differences but natural to test*/

*exploratory
bysort dem_lean repub_lean: reg affect_polar_lean congenial_fn uncongenial_fn if independents==0, robust

*H-E1b. Exposure to pro-attitudinal fake news will increase negative feelings toward the media
*RQ-F2 What effect does counter-attitudinal fake news exposure have on affect toward the media 

reg FT_media_w2 congenial_fn uncongenial_fn if independents==0, robust
lincom congenial_fn-uncongenial_fn

*exploratory
bysort dem_lean repub_lean: reg FT_media_w2 congenial_fn uncongenial_fn if independents==0, robust

*H-E2: Exposure to pro-attitudinal fake news will increase intent to vote 
*RQ-F3: What effect does counter-attitudinal fake news exposure have on intent to vote 

reg vote_combined congenial_fn uncongenial_fn if independents==0, robust
lincom congenial_fn-uncongenial_fn
reg vote_binary congenial_fn uncongenial_fn if independents==0, robust
lincom congenial_fn-uncongenial_fn

*H-E3: Exposure to pro-attitudinal fake news will increase intent to take political action
*RQ-F4:What effect does counter-attitudinal fake news exposure have on intent to take political action?

reg polact_mean congenial_fn uncongenial_fn if independents==0, robust
lincom congenial_fn-uncongenial_fn

*vote choice generic ballot - exploratory
gen generic_d=(district_vote_w2==1 | district_vote_lean==1)
gen generic_r=(district_vote_w2==2 | district_vote_lean==2)
replace generic_r=. if district_vote_w2==.
gen generic_ballot=1 if generic_d==1
replace generic_ballot=3 if generic_r==1
replace generic_ballot=2 if generic_d==0 & generic_r==0 & district_vote_w2!=.

reg generic_ballot ib3.article_treat_w2, robust
reg generic_ballot ib3.article_treat_w2##dem_leaners##repub_leaners, robust

/*We will also conduct exploratory analyses of potential moderators of the effect of pro-attitudinal fake news on affective polarization, intent to vote, or intent to take political action: trust in and feelings toward the media, feelings toward Trump (entered as a linear term and with indicators for terciles or quartiles), conspiracy predispositions, political interest and knowledge, and pre-treatment visits to fake news sites and fact-checking sites. In addition, we will conduct an exploratory analysis of black-white differences in feeling thermometer scores as a moderator of pro-attitudinal fake news exposure effects given that Rep. Maxine Waters, an African American member of Congress, is the target of the fake news stimuli to which participants are randomized in wave 2. As we describe above for wave 1, we will control the false discovery rate with the Benjamini-Hochberg procedure given the risk of false positives. These analyses will be limited to the appendix or supplementary materials, but if any positive findings replicate in future studies, we may then use these data and analyses in the main text of a paper.

For the exploratory analyses of possible moderators of the effects of congenial fake news exposure, the outcome measures are affective polarization, intent to vote, intent to take political action, trust in and feelings toward the media, feelings toward Trump (entered as a linear term and with indicators for terciles or quartiles), conspiracy predispositions, political interest and knowledge, pre-treatment visits to fake news sites and fact-checking sites, and black-white differences in feeling thermometer scores. Due to likely collinearity between the predictors, we will estimate separate models for each potential moderator for each outcome measure.
E.g.:
Outcome = [constant] + congenial fake news exposure + feelings toward Trump + congenial fake news exposure * feelings toward Trump + uncongenial fake news exposure*/

*add terciles

xtile trumpft3 = FT_trump if FT_trump!=., nquantiles(3)
xtile mediaft3 = FT_media if FT_media!=., nquantiles(3)
*black-white FT difference score (FT_white_black)
xtile whiteblackft3 = FT_white_black if FT_white_black!=., nquantiles(3)
*prior fact check visit

*VOTE DVs

reg vote_combined congenial_fn##massmedia_trust  uncongenial_fn if independents==0, robust
reg vote_binary congenial_fn##massmedia_trust uncongenial_fn if independents==0, robust

reg vote_combined congenial_fn##fbtrust   uncongenial_fn if independents==0, robust
reg vote_binary congenial_fn##fbtrust  uncongenial_fn if independents==0, robust

reg vote_combined congenial_fn##c.conspiracy_mean  uncongenial_fn if independents==0, robust
reg vote_binary congenial_fn##c.conspiracy_mean uncongenial_fn if independents==0, robust

reg vote_combined congenial_fn##polint  uncongenial_fn if independents==0, robust
reg vote_binary congenial_fn##polint uncongenial_fn if independents==0, robust

reg vote_combined congenial_fn##polknow  uncongenial_fn if independents==0, robust
reg vote_binary congenial_fn##polknow uncongenial_fn if independents==0, robust
**polknow decreases effect of congenial fn on vote

reg vote_combined congenial_fn##trumpft3  uncongenial_fn if independents==0, robust
reg vote_binary congenial_fn##trumpft3 uncongenial_fn if independents==0, robust

reg vote_combined congenial_fn##mediaft3  uncongenial_fn if independents==0, robust
reg vote_binary congenial_fn##mediaft3 uncongenial_fn if independents==0, robust

reg vote_combined congenial_fn##whiteblackft3  uncongenial_fn if independents==0, robust
reg vote_binary congenial_fn##whiteblackft3 uncongenial_fn if independents==0, robust
**white_black diff increases effect of congenial fn on vote 

**pretreatment fn visits

*2017 defs
reg vote_combined congenial_fn##c.totalfakecount18_pre  uncongenial_fn if independents==0, robust
reg vote_binary congenial_fn##c.totalfakecount18_pre uncongenial_fn if independents==0, robust

reg vote_combined congenial_fn##c.totalfakebinary18_pre  uncongenial_fn if independents==0, robust
reg vote_binary congenial_fn##c.totalfakebinary18_pre uncongenial_fn if independents==0, robust

*2016 defs
reg vote_combined congenial_fn##c.totalfakenewscount_pre  uncongenial_fn if independents==0, robust
reg vote_binary congenial_fn##c.totalfakenewscount_pre uncongenial_fn if independents==0, robust

reg vote_combined congenial_fn##c.totalfakenewsbinary_pre  uncongenial_fn if independents==0, robust
reg vote_binary congenial_fn##c.totalfakenewsbinary_pre uncongenial_fn if independents==0, robust

*AFFECTIVE POLARIZATION

reg affect_polar_lean congenial_fn##massmedia_trust  uncongenial_fn if independents==0, robust

reg affect_polar_lean congenial_fn##fbtrust   uncongenial_fn if independents==0, robust

reg affect_polar_lean congenial_fn##c.conspiracy_mean  uncongenial_fn if independents==0, robust

reg affect_polar_lean congenial_fn##polint  uncongenial_fn if independents==0, robust

reg affect_polar_lean congenial_fn##polknow  uncongenial_fn if independents==0, robust

reg affect_polar_lean congenial_fn##trumpft3  uncongenial_fn if independents==0, robust

reg affect_polar_lean congenial_fn##mediaft3  uncongenial_fn if independents==0, robust

reg affect_polar_lean congenial_fn##whiteblackft3  uncongenial_fn if independents==0, robust

*2018 defs
reg affect_polar_lean congenial_fn##c.totalfakecount18_pre  uncongenial_fn if independents==0, robust
reg affect_polar_lean congenial_fn##c.totalfakebinary18_pre  uncongenial_fn if independents==0, robust

*2016 defs
reg affect_polar_lean congenial_fn##c.totalfakenewscount_pre  uncongenial_fn if independents==0, robust
reg affect_polar_lean congenial_fn##c.totalfakenewsbinary_pre  uncongenial_fn if independents==0, robust

**pretreatment fc visits
*STILL MISSING

*INTENT TO TAKE POLITICAL ACTION

reg polact_mean congenial_fn##massmedia_trust  uncongenial_fn if independents==0, robust

reg polact_mean congenial_fn##fbtrust   uncongenial_fn if independents==0, robust

reg polact_mean congenial_fn##c.conspiracy_mean  uncongenial_fn if independents==0, robust

reg polact_mean congenial_fn##polint  uncongenial_fn if independents==0, robust

reg polact_mean congenial_fn##polknow  uncongenial_fn if independents==0, robust

reg polact_mean congenial_fn##trumpft3  uncongenial_fn if independents==0, robust

reg polact_mean congenial_fn##mediaft3  uncongenial_fn if independents==0, robust

reg polact_mean congenial_fn##whiteblackft3  uncongenial_fn if independents==0, robust

*2018 defs
reg polact_mean congenial_fn##c.totalfakecount18_pre  uncongenial_fn if independents==0, robust
reg polact_mean congenial_fn##c.totalfakebinary18_pre  uncongenial_fn if independents==0, robust

*2016 defs
reg polact_mean congenial_fn##c.totalfakenewscount_pre  uncongenial_fn if independents==0, robust
reg polact_mean congenial_fn##c.totalfakenewsbinary_pre  uncongenial_fn if independents==0, robust

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
-scores on standard political knowledge and interest scales -Trump feeling thermometer
-Media feeling thermometer
-Trust in the media in wave 1
-Affective polarization in wave 1 (in-party feelings - out-party feelings) -Conspiracy predispositions scale (average response in wave 1)

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



/*ADD DUNNING KRUGER STUFF HERE*/
tab confidence_self confidence_americans

gen more_confident_self=(tpp>0 & tpp<4)
gen less_confident_self=(tpp<0)

tab accuracy_fake_meanw2
gen above_average_fake=(accuracy_fake_meanw2<=2) /*check prereg to verify not real-fake*/

svy: tab above_average_fake more_confident_self, col
svy: tab more_confident_self above_average_fake, col

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






label def tpp3lab 1 "Less confident in self" 2 "Equally confident" 3 "More confident in self"
label val tpp3 tpp3lab

label def tpp2lab 0 "Less/equally confident in self" 1 "More confident in self"
label val tpp2 tpp2lab

label def above_average_fake_lab 0 "Below average" 1 "Above average"
label val above_average_fake above_average_fake_lab

gen fake=1

cibar above_average_fake [pweight=weight],over1(fake) bargap(8) gap(35) over2(tpp3) graphopts(graphregion(fcolor(white) ifcolor(none)) plotregion(fcolor(none) lcolor(white) ifcolor(none) ilcolor(none)) ytitle("") scheme(lean1) yscale(r(0 .61)) ylab(0 "0%" .1 "10%" .2 "20%" .3 "30%" .4 "40%" .5 "50%" .6 "60%",angle(0) labsize(*.8)) ytitle("") legend(off))
graph export "dkgraph1.pdf", replace

cibar above_average_fake [pweight=weight],over1(fake) bargap(8) gap(35) over2(tpp2) graphopts(graphregion(fcolor(white) ifcolor(none)) plotregion(fcolor(none) lcolor(white) ifcolor(none) ilcolor(none)) ytitle("") scheme(lean1) yscale(r(0 .61)) ylab(0 "0%" .1 "10%" .2 "20%" .3 "30%" .4 "40%" .5 "50%" .6 "60%",angle(0) labsize(*.8)) ytitle("") legend(off))
graph export "dkgraph2.pdf", replace

cibar tpp2 [pweight=weight],over1(fake) over2(above_average_fake) bargap(8) gap(35) graphopts(graphregion(fcolor(white) ifcolor(none)) plotregion(fcolor(none) lcolor(white) ifcolor(none) ilcolor(none)) ytitle("") scheme(lean1) yscale(r(0 .61)) ylab(0 "0%" .2 "20%" .4 "40%" .6 "60%" .8 "80%" 1 "100%",angle(0) labsize(*.8)) ytitle("") legend(off))
graph export "dkgraph3.pdf", replace


****BL-new TPP ttest
****BL-new TPP ttest
ttest tpp==0
ttest confidence_self == confidence_americans 
est store tpp_june1
*ttest madeup_recognize_study_w2==50
*est store tpp_june2

****BL-new DK/TPP Political/cognitive/demographic correlates

*RQ3. Are fake news exposure and partisan selective exposure associated with overconfidence in one’s ability to distinguish real from fake news and/or TPPFN?
*Overconfidence  = [constant] + exposure to fake news (binary/count/share of information diet) + selective exposure decile indicators + [mean(real news)-mean(fake news)] + covariates listed above
*TPPFN  = [constant] + exposure to fake news (binary/count/share of information diet) + selective exposure decile indicators + [mean(real news)-mean(fake news)] + covariates listed above

* using pre-survey measures
/*
*2018 def
reg tpp3 mean_acc_diff i.decile totalfakecount18_pre agecat college nonwhite female dem repub polknow polint
reg more_confident_self above_average_fake i.decile totalfakecount18_pre agecat college nonwhite female dem repub polknow polint
reg tpp3 mean_acc_diff i.decile totalfakebinary18_pre agecat college nonwhite female dem repub polknow polint
reg more_confident_self above_average_fake i.decile totalfakebinary18_pre agecat college nonwhite female dem repub polknow polint

*2016 def
reg tpp3 mean_acc_diff i.decile totalfakenewscount_pre agecat college nonwhite female dem repub polknow polint
reg more_confident_self above_average_fake i.decile totalfakenewscount_pre agecat college nonwhite female dem repub polknow polint
reg tpp3 mean_acc_diff i.decile totalfakenewsbinary_pre agecat college nonwhite female dem repub polknow polint
reg more_confident_self above_average_fake i.decile totalfakenewsbinary_pre agecat college nonwhite female dem repub polknow polint

*H3. Political interest, knowledge, and performance in distinguishing real from fake news (i.e., lower perceived accuracy for fake news, higher perceived accuracy for real news) will be positively associated with TPPFN. 
reg tpp3 polint polknow mean_acc_diff agecat college nonwhite female

*RQ4. How does TPPFN vary by party identification and political knowledge?
reg tpp3 dem#polknow repub#polknow agecat college nonwhite female dem repub polknow polint

*RQ5. How do TPPFN and overconfidence in one’s ability to distinguish real from fake news vary by age?
*TPPFN = [constant] + age + other covariates
*Overconfidence = [constant] + age + other covariates
reg tpp3 agecat college nonwhite female dem repub polknow polint
reg more_confident_self above_average_fake agecat college nonwhite female dem repub polknow polint

*H4. Negative feelings toward the media (mass media trust, Facebook trust, media feelings) will be positively associated with TPPFN (see Tsfati and Cohen 2013, p. 12).
*TPPFN = [constant]  + mass media trust + FB trust + media FT + covariates listed above (separately and in omnibus)

reg tpp3 massmedia_trust fbtrust mediaft3 agecat college nonwhite female dem repub polknow polint
*/



*H3. Political interest, knowledge, and performance in distinguishing real from fake news (i.e., lower perceived accuracy for fake news, higher perceived accuracy for real news) will be positively associated with TPPFN. 
svy: reg tpp mean_acc_diff polint dem_leaners repub_leaners polknow college female nonwhite ib1.agecat
est store tpp_poljune1

/*
*RQ4. How does TPPFN vary by party identification and political knowledge?
svy: reg tpp dem##polknow repub##polknow dem_leaners repub_leaners polint college female nonwhite ib1.agecat // kowledgeable Ds
est store tpp_asymjune1
*/

gen demXpolknow = polknow*dem_leaners
gen repXpolknow = polknow*repub_leaners

svy: reg tpp  dem_leaners repub_leaners polknow demXpolknow repXpolknow polint college female nonwhite ib1.agecat // kowledgeable Ds
est store tpp_asymjune1



*RQ5. How do TPPFN and overconfidence in one’s ability to distinguish real from fake news vary by age?
*TPPFN = [constant] + age + other covariates
*Overconfidence = [constant] + age + other covariates
svy: reg tpp dem_leaners repub_leaners polknow polint college female nonwhite ib1.agecat
est store tpp_agejune1

svy: reg overconfidencew1 dem_leaners repub_leaners polknow polint college female nonwhite ib1.agecat
est store over_agejune1


**age as linear term
svy: reg tpp dem_leaners repub_leaners polknow polint college female nonwhite age // sig -
svy: reg overconfidencew1 dem_leaners repub_leaners polknow polint college female nonwhite age // sig -




*H4. Negative feelings toward the media (mass media trust, Facebook trust, media feelings) will be positively associated with TPPFN (see Tsfati and Cohen 2013, p. 12).
*TPPFN = [constant]  + mass media trust + FB trust + media FT + covariates listed above (separately and in omnibus)

svy: reg tpp massmedia_trust fbtrust FT_media dem_leaners repub_leaners polknow polint college female nonwhite ib1.agecat
est store tppmedia_june1


**media single item models

svy: reg tpp massmedia_trust  dem_leaners repub_leaners polknow polint college female nonwhite ib1.agecat // sig -
svy: reg tpp fbtrust  dem_leaners repub_leaners polknow polint college female nonwhite ib1.agecat // sig -
svy: reg tpp  FT_media dem_leaners repub_leaners polknow polint college female nonwhite ib1.agecat // sig -
















/*make data for over-time plot*/
preserve
rename totalfakenewsbinary_new totalfakenewsbinary_18def
gen fnfrac=(totalproclintonfncount_ag80+totalprotrumpfncount_ag80)/(totalproclintonfncount_ag80+totalprotrumpfncount_ag80+totalnewscount)
gen fnfrac_18def=(totalprorepfncount+totalprodemfncount)/(totalprorepfncount+totalprodemfncount+totalnewscount)

collapse (mean) totalfakenewsbinary totalfakenewsbinary_18def fnfrac fnfrac_18def [pweight=weight] 
gen date=td(25june2018)
format date %td
list
save "summer18-summary.dta", replace
restore


/*Referrals here*/
/*
*these are with 2018 definitions
use "andy-referrer-stats.dta", clear /*BJN pasted from Slack*/
drop var1
rename var2 infotype
rename var3 var1
rename var4 var2
rename var5 var3
*rename var6 var4

reshape long var, i(infotype) j(source)
label def newlab 1 "Facebook" 2 "Google" 3 "Twitter" /*4 "Webmail"*/
label val source newlab

label def fakelab 0 "Fake news" 1 "Hard news" 2 "Neither"
label val infotype fakelab

graph bar (mean) var, over(infotype, gap(*.25) label(labsize(*.8))) over(source, gap(*1) relabel(1 "Facebook" 2 "Google" 3 "Twitter" 4 "Webmail") label(labsize(*1))) asy outergap(0) bargap(.25) ylab(,nogrid) graphregion(fcolor(white) ifcolor(none)) plotregion(fcolor(none) lcolor(white) ifcolor(none) ilcolor(none)) ytitle("") scheme(lean1) ylab(0 "0%" .1 "10%" .2 "20%" .3 "30%",angle(0) labsize(*.8)) legend(row(1) pos(6) region(lpattern(solid) lcolor(black)))
graph export "referrers30hn-2018defs.pdf", replace

*these are with 2016 definitions
use "andy-referrer-stats2.dta", clear /*BJN pasted from Slack*/
drop var1
rename var2 infotype
rename var3 var1
rename var4 var2
rename var5 var3
*rename var6 var4

reshape long var, i(infotype) j(source)
label def newlab 1 "Facebook" 2 "Google" 3 "Twitter" /*4 "Webmail"*/
label val source newlab

label def fakelab 0 "Fake news" 1 "Hard news" 2 "Neither"
label val infotype fakelab

graph bar (mean) var, over(infotype, gap(*.25) label(labsize(*.8))) over(source, gap(*1) relabel(1 "Facebook" 2 "Google" 3 "Twitter" 4 "Webmail") label(labsize(*1))) asy outergap(0) bargap(.25) ylab(,nogrid) graphregion(fcolor(white) ifcolor(none)) plotregion(fcolor(none) lcolor(white) ifcolor(none) ilcolor(none)) ytitle("") scheme(lean1) ylab(0 "0%" .1 "10%" .2 "20%" .3 "30%",angle(0) labsize(*.8)) legend(row(1) pos(6) region(lpattern(solid) lcolor(black)))
graph export "referrers30hn-2016defs.pdf", replace*/
