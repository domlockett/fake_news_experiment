#Analyses Fake News Exposure
library(stargazer)
library(multiwayvcov)
library(lmtest)
library(haven)
library(readstata13)
library(fabricatr)
library(survey)
library(clubSandwich)
library(KRLS)
library(estimatr)
library(dplyr)
library(miceadds)
library(wesanderson)
library(srvyr)
library(ggplot2)
library(texreg)
library(sjPlot)
library(insight)
library(magrittr)
#SET WD AND LOAD DATA
setwd("C:/Users/dl0ck/OneDrive/Fall2019/FN/FN_Effects/June Wave/Data_0618")
june <- read.dta13('june.dta')

june$crt_terc


#Feedback on doc above@Montgomery@Dominique(which is great):
# 1. can we fix NaN problem that is breaking table 6 column 4 ? 



#HA1
############################################################################################################# Observational Covariates: Democrats and Republicans (including leaners), political knowledge (0-8) and interest (1-4), having a four-year college degree (0/1), self-identifying as a female (0/1) or non-white (0/1), and age group dummies (30-44, 45-59, 60+, 18-29 omitted)

#H-A1) People with the strongest overall tendencies toward selective exposure will be the most likely to consume fake news and consume the most on average. 

#For H - A1, the outcome measure is exposure to fake news(binary / count / share of information diet):
#Fake news exposure = [constant] + selective exposure decile indicators + covariates listed above * /
############################################################################################################
#factor certain variables but first as numeric so not to include NAs as factor level
june$decile <- as.numeric(june$decile)
june$decile <- as.factor(june$decile)
june$agecat <- (as.numeric(june$agecat))
june$agecat <- (as.factor(june$agecat))


#share of information diet
june$shareDiet18 <- june$totalfakecount18 / june$totalnewsfncount2018def


#############################################################################################################ANALYZE
#HA1 DV1 JUNE
h1a1June <- extract.lm_robust(lm_robust(totalfakecount18 ~ decile + dem_leaners + repub_leaners + polknow + polint + college + agecat + female + nonwhite, data = june, weights = weight), include.ci = F)

#HA1 DV2 JUNE
h1a2June <- extract.lm_robust(lm_robust(totalfakebinary18 ~ decile + dem_leaners + repub_leaners + polknow + polint + college + agecat + female + nonwhite, data = june, weights = weight), include.ci = F)

#HA1 DV3 JUNE
h1a3June <- extract.lm_robust(lm_robust(shareDiet18 ~ decile + dem_leaners + repub_leaners + polknow + polint + college + agecat + female + nonwhite, data = june, weights = weight), include.ci = F)


#SUMMARY AND TABLE
screenreg(list(h1a1June, h1a2June, h1a3June))

#texreg(list(h1a1June, h1a2June, h1a3June), custom.model.names = c('Total Fake News Count', 'Total Fake News Binary', 'Share of Information Diet'), custom.coef.names = c('(Intercept)', 'Decile 2', 'Decile 3', 'Decile 4', 'Decile 5', 'Decile 6', 'Decile 7', 'Decile 8', 'Decile 9', 'Decile 10', 'Democrat Leaners', 'Republican Leaners', 'Political Knowledge', 'Political Interest', 'College', 'Age 2', 'Age 3', 'Age 4', 'Female', 'Nonwhite'))






#############################################################################################################Kernel using Hainmueller package JUNE
#note: cannot take weights
#June
#DROP all nas
juneClean <- na.omit(june[, c('totalfakebinary18','totalfakecount18', 'shareDiet18', 'decile', 'dem_leaners', 'repub_leaners', 'polknow', 'polint', 'college', 'agecat', 'female', 'nonwhite')])

sd(juneClean$totalfakecount18)

myXjune <- cbind(juneClean$decile, juneClean$dem_leaners, juneClean$repub_leaners, juneClean$polknow, juneClean$polint, juneClean$college, juneClean$agecat, juneClean$female, juneClean$nonwhite)

colnames(myXjune) <- c('Decile', 'x2', 'x3', 'x4', 'x5', 'x6', 'x7', 'x8', 'x9')

#############################################################################################################ANALYZE
#Kernel HA1 DV1
h1a1June_kern <- krls(y = juneClean$totalfakecount18, X = myXjune)

plot(h1a1June_kern, ask = F, probs = c(0, 1))

#Kernel HA1 DV2
h1a2June_kern <- krls(y = juneClean$totalfakebinary18, X = myXjune)

plot(h1a2June_kern, ask = F, probs = c(0, 1))

#Kernel HA1 DV3
h1a3June_kern <- krls(y = juneClean$shareDiet18, X = myXjune)

plot(h1a3June_kern, ask = F, probs = c(0, 1))

################################################################################change wd and load data
setwd("C:/Users/dl0ck/OneDrive/Fall2019/FN/FN_Effects/October Wave/Data_1018")
oct <- read.dta13('oct.dta')
# change to factors but numeric first to not include na as factor
oct$decile <- as.numeric(oct$decile)
oct$decile <- as.factor(oct$decile)
oct$agecat <- (as.numeric(oct$agecat))
oct$agecat <- (as.factor(oct$agecat))
#share of info diet 

#share of information diet
oct$shareDiet18 <- oct$totalfakecount18 / oct$totalnewsfncount2018def


#############################################################################################################ANALYZE
#H-A1 DV1 OCTOBER
h1a1Oct <- extract.lm_robust(lm_robust(totalfakecount18 ~ decile + dem_leaners + repub_leaners + polknow + polint + college + agecat + female + nonwhite, weights = weight, data = oct), include.ci = F)


#H-A1 DV2 OCTOBER
h1a2Oct <- extract.lm_robust(lm_robust(totalfakebinary18 ~ decile + dem_leaners + repub_leaners + polknow + polint + college + agecat + female + nonwhite, data = oct, weights = weight), include.ci = F)


#H-A1 DV3 OCTOBER
h1a3Oct <- extract.lm_robust(lm_robust(shareDiet18 ~ decile + dem_leaners + repub_leaners + polknow + polint + college + agecat + female + nonwhite, data = oct, weights = weight), include.ci = F)

screenreg(list(h1a1Oct, h1a2Oct, h1a3Oct), custom.model.names = c('Total Fake News Count', 'Total Fake News Binary ', 'Share of Information Diet'), custom.coef.names = c('(Intercept)', 'Decile 2', 'Decile 3', 'Decile 4', 'Decile 5', 'Decile 6', 'Decile 7', 'Decile 8', 'Decile 9', 'Decile 10', 'Democrat Leaners', 'Republican Leaners', 'Political Knowledge', 'Political Interest', 'College', 'Age 2', 'Age 3', 'Age 4', 'Female', 'Nonwhite'))
############################################################################################################
#Kernel Regression October

#omit nas
octClean <- na.omit(oct[, c('totalfakecount18', 'totalfakebinary18', 'shareDiet18','decile', 'dem_leaners', 'repub_leaners', 'polknow', 'polint', 'college', 'agecat', 'female' ,'nonwhite')])
#check data
sd(octClean$totalfakecount18)

myXOct <- cbind(octClean$decile, octClean$dem_leaners, octClean$repub_leaners, octClean$polknow, octClean$polint, octClean$college, octClean$agecat, octClean$female, octClean$nonwhite)

colnames(myXOct) <- c('Decile', 'x2', 'x3', 'x4', 'x5', 'x6', 'x7', 'x8', 'x9')
#############################################################################################################ANALYZE
#Kernel Ha1 DV1
h1a1Oct_kern <- krls(y = octClean$totalfakecount18, X = myXOct)

plot(h1a1Oct_kern, ask = F, probs = c(0, 1))

#Kernel Ha1 DV2
h1a2Oct_kern <- krls(y = octClean$totalfakebinary18, X = myXOct)

plot(h1a2Oct_kern, ask = F, probs = c(0, 1))

#Kernel Ha1 DV3
h1a3KOct_kern <- krls(y = octClean$shareDiet18, X = myXOct)

plot(h1a3KOct_kern, ask = F, probs = c(0, 1))


############################################################################################################
# H - A2) People who consume fake news will be more likely to believe it is accurate than those who do not consume fake news(H - A2a) . This relationship will be stronger for pro - attitudinal fake news belief than for counter - attitudinal fake news belief(H - A2b) and for people who are relatively less skilled at analytical reasoning(H - A2c) .

#H - A2a:Fake news accuracy = [constant] + prior fake news exposure + covariates listed above

#H - A2b:Fake news accuracy = [constant] + prior fake news exposure + congenial + prior fake + news exposure * congenial  covariates listed above

#H - A2c:Fake news accuracy = [constant] + prior fake news exposure + CRT score + prior fake + news exposure * CRT score + covariates listed above * /

#For H - A2d, the outcome measure = (mean perceived accuracy of real news headlines - mean perceived accuracy of fake news headlines) . This hypothesis is measured at the respondent-level using a single mean difference that is not ordered and thus we will only test it using OLS with robust standard errors(i.e., no question fixed effects or clustering) . * /
############################################################################################################
# note:prereg ambiguous about whether we need to run for binary version but including since we're doing that when fake news is a DV

# note:can't cluster with survey weights so omitting, might want to do robustness check with weights and no clustering - e.g., with respondent fixed effects or random effects or something * /

############################################################################################################

juneHead <- tidyr::gather(june, headline_df, HL_accuracy, headline_accuracy_1_w2, headline_accuracy_2_w2, headline_accuracy_3_w2, headline_accuracy_4_w2, headline_accuracy_5_w2, headline_accuracy_6_w2, headline_accuracy_7_w2, headline_accuracy_8_w2, headline_accuracy_9_w2, headline_accuracy_10_w2, headline_accuracy_11_w2, headline_accuracy_12_w2, headline_accuracy_13_w2, headline_accuracy_14_w2, headline_accuracy_15_w2, headline_accuracy_16_w2)

juneHead$HL_accuracy <- as.factor(juneHead$HL_accuracy)


# Convert factor to numeric for lm_robust
juneHead$HL_accuracy <- as.character(juneHead$HL_accuracy)
juneHead$HL_accuracy[juneHead$HL_accuracy == 'Not at all accurate'] <- 1
juneHead$HL_accuracy[juneHead$HL_accuracy == 'Not very accurate'] <- 2
juneHead$HL_accuracy[juneHead$HL_accuracy == 'Somewhat accurate'] <- 3
juneHead$HL_accuracy[juneHead$HL_accuracy == 'Very accurate'] <- 4

juneHead$HL_accuracy <- as.numeric(juneHead$HL_accuracy)



#############################################################################################################H-A2a DV1 JUNE
h2aa1 <- extract.lm_robust(lm_robust(formula = HL_accuracy ~ totalfakecount18 + dem_leaners + repub_leaners + polknow + polint + college + agecat + female + nonwhite, weights = weight, clusters = caseid, data = juneHead), include.ci = F)


#H-A2a DV2 JUNE
h2aa2 <- extract.lm_robust(lm_robust(HL_accuracy ~ totalfakebinary18 + dem_leaners + repub_leaners + polknow + polint + college + agecat + female + nonwhite, weights = weight, clusters = caseid, data = juneHead),  include.ci = F)

#H-A2b DV1 JUNE
h2ab1 <- extract.lm_robust(lm_robust(HL_accuracy ~ totalfakecount18 * as.factor(congenial_fn) + dem_leaners + repub_leaners + polknow + polint + college + agecat + female + nonwhite, data = subset(juneHead, june$pid3 != 'Independent'), clusters = caseid, weights = weight), include.ci = F)

#H-A2b DV2 JUNE
h2ab2 <- extract.lm_robust(lm_robust(HL_accuracy ~ totalfakebinary18 * as.factor(congenial_fn) + dem_leaners + repub_leaners + polknow + polint + college + agecat + female + nonwhite, data = subset(juneHead, june$pid3 != 'Independent'), weights = weight, clusters = caseid), include.ci = F)

screenreg(list(h2aa1, h2aa2, h2ab1, h2ab2), custom.coef.names = c('(Intercept)', 'Total Fake News Count', 'Democrat Leaners', 'Republican Leaners', 'Political Knowledge', 'Political Interest', 'College', 'Age 2', 'Age 3', 'Age 4', 'Female', 'Nonwhite', 'Total Fake News Binary', 'FN Congeniality 1', 'Total Fake Count : FN Congeniality 1', 'Total Fake Binary : FN Congeniality 1'), digits = 4)


#texreg(list(h2aa1, h2aa2, h2ab1, h2ab2), custom.coef.names = c('(Intercept)', 'Total Fake News Count', 'Democrat Leaners', 'Republican Leaners', 'Political Knowledge', 'Political Interest', 'College', 'Age 2', 'Age 3', 'Age 4', 'Female', 'Nonwhite', 'Total Fake News Binary', 'FN Congeniality 1', 'Total Fake Count : FN Congeniality 1', 'Total Fake Binary : FN Congeniality 1'), digits = 4)
############################################################################################################

#H-A2c DV1 JUNE
h2ac1 <- extract.lm_robust(lm_robust(HL_accuracy ~ totalfakecount18 * as.factor(crt_terc) + dem_leaners + repub_leaners + polknow + polint + college + agecat + female + nonwhite, data = juneHead, clusters = caseid, weights = weight), include.ci = F)

texreg((h2ac1), digits = 4, custom.coef.names = c('(Intercept)', 'Total Fake News Count', 'CRT 2', 'CRT 3', 'Democrat Leaners ', ' Republican Leaners ', ' Political Knowledge ', ' Political Interest ', ' College ', ' Age 2 ', ' Age 3 ', ' Age 4 ', ' Female ', ' Nonwhite ', 'Total Fake News Count : CRT 2', 'Total Fake News Count : CRT 3'))

#H-A2c DV2 JUNE
h2ac2 <- extract.lm_robust(lm_robust(HL_accuracy ~ totalfakebinary18 * as.factor(crt_terc) + dem_leaners + repub_leaners + polknow + polint + college + agecat + female + nonwhite, data = juneHead, clusters = caseid, weights = weight), include.ci = F)



screenreg((h2ac2), digits = 4, custom.coef.names = c('(Intercept)', 'Total Fake News Count', 'CRT 2', 'CRT 3', 'Democrat Leaners ', ' Republican Leaners ', ' Political Knowledge ', ' Political Interest ', ' College ', ' Age 2 ', ' Age 3 ', ' Age 4 ', ' Female ', ' Nonwhite ', 'Total Fake News Count : CRT 2', 'Total Fake News Count : CRT 3'))
#texreg((h2ac2), digits = 4, custom.coef.names = c('(Intercept)', 'Total Fake News Count', 'CRT 2', 'CRT 3', 'Democrat Leaners ', ' Republican Leaners ', ' Political Knowledge ', ' Political Interest ', ' College ', ' Age 2 ', ' Age 3 ', ' Age 4 ', ' Female ', ' Nonwhite ', 'Total Fake News Count : CRT 2', 'Total Fake News Count : CRT 3'))

############################################################################################################

#H-A2d DV1 JUNE
h2ad1 <- extract.lm_robust(lm_robust(mean_acc_diff ~ totalfakecount18 + dem_leaners + repub_leaners + polknow + polint + college + agecat + female + nonwhite, data = june, weights = weight), include.ci = F)

#H-A2d DV2 JUNE
h2ad2 <- extract.lm_robust(lm_robust(mean_acc_diff ~ totalfakebinary18 + dem_leaners + repub_leaners + polknow + polint + college + agecat + female + nonwhite, data = june, weights = weight), include.ci = F)

screenreg(list(h2ad1, h2ad2), digits = 4, custom.coef.names = c('(Intercept)','Total Fake News Count', 'Democrat Leaners ', ' Republican Leaners ', ' Political Knowledge ', ' Political Interest ', ' College ', ' Age 2 ', ' Age 3 ', ' Age 4 ', ' Female ', ' Nonwhite ', 'Total Fake News Binary '))


#texreg(list(h2ad1, h2ad2), digits = 4, custom.coef.names = c('(Intercept)','Total Fake News Count', 'Democrat Leaners ', ' Republican Leaners ', ' Political Knowledge ', ' Political Interest ', ' College ', ' Age 2 ', ' Age 3 ', ' Age 4 ', ' Female ', ' Nonwhite ', 'Total Fake News Binary '))
############################################################################################################

octHead <- tidyr::gather(oct, headline_df, HL_accuracy, headline_accuracy_1_w2, headline_accuracy_2_w2, headline_accuracy_3_w2, headline_accuracy_4_w2, headline_accuracy_5_w2, headline_accuracy_6_w2, headline_accuracy_7_w2, headline_accuracy_8_w2, headline_accuracy_9_w2, headline_accuracy_10_w2, headline_accuracy_11_w2, headline_accuracy_12_w2, headline_accuracy_13_w2, headline_accuracy_14_w2, headline_accuracy_15_w2, headline_accuracy_16_w2)

octHead$HL_accuracy <- as.factor(octHead$HL_accuracy)
#juneHead$caseid <- as.numeric(juneHead$caseid)


# Convert to factor to for lm_robust
octHead$HL_accuracy <- as.character(octHead$HL_accuracy)
octHead$HL_accuracy[octHead$HL_accuracy == 'Not at all accurate'] <- 1
octHead$HL_accuracy[octHead$HL_accuracy == 'Not very accurate'] <- 2
octHead$HL_accuracy[octHead$HL_accuracy == 'Somewhat accurate'] <- 3
octHead$HL_accuracy[octHead$HL_accuracy == 'Very accurate'] <- 4

octHead$HL_accuracy <- as.numeric(octHead$HL_accuracy)




#############################################################################################################H-A2a DV1 OCTOBER
h2aa1O <- extract.lm_robust(lm_robust(formula = HL_accuracy ~ totalfakecount18 + dem_leaners + repub_leaners + polknow + polint + college + agecat + female + nonwhite, data = octHead, weights = weight, clusters = caseid), include.ci = F)

#H-A2a DV2 OCTOBER
h2aa2O <- extract.lm_robust(lm_robust(HL_accuracy ~ totalfakebinary18 + dem_leaners + repub_leaners + polknow + polint + college + agecat + female + nonwhite, weights = weight, data = octHead, clusters = caseid), include.ci = F)


#H-A2b DV1 OCTOBER
h2ab1O <- extract.lm_robust(lm_robust(HL_accuracy ~ totalfakecount18 * as.factor(congenial_fn) + dem_leaners + repub_leaners + polknow + polint + college + agecat + female + nonwhite, data = subset(octHead, octHead$pid3 != 'Independent'), clusters = caseid, weights = weight), include.ci = F)

#H-A2b DV2 OCTOBER
h2ab2O <- extract.lm_robust(lm_robust(HL_accuracy ~ totalfakebinary18 * as.factor(congenial_fn) + dem_leaners + repub_leaners + polknow + polint + college + agecat + female + nonwhite, data = subset(octHead, octHead$pid3 != 'Independent'), weights = weight, clusters = caseid), include.ci = F)

screenreg(list(h2aa1O, h2aa2O, h2ab1O, h2ab2O), custom.coef.names = c('(Intercept)', 'Total Fake News Count', 'Democrat Leaners', 'Republican Leaners', 'Political Knowledge', 'Political Interest', 'College', 'Age 2', 'Age 3', 'Age 4', 'Female', 'Nonwhite', 'Total Fake News Binary', 'FN Congeniality 1', 'Total Fake Count : FN Congeniality 1', 'Total Fake Binary : FN Congeniality 1'))

#texreg(list(h2aa1O, h2aa2O, h2ab1O, h2ab2O), custom.coef.names = c('(Intercept)', 'Total Fake News Count', 'Democrat Leaners', 'Republican Leaners', 'Political Knowledge', 'Political Interest', 'College', 'Age 2', 'Age 3', 'Age 4', 'Female', 'Nonwhite', 'Total Fake News Binary', 'FN Congeniality 1', 'Total Fake Count : FN Congeniality 1', 'Total Fake Binary : FN Congeniality 1'))
##
###############################################################################################

#H-A2c DV1 OCTOBER
h2ac1O <- extract.lm_robust(lm_robust(HL_accuracy ~ totalfakecount18 * as.factor(crt_terc) + dem_leaners + repub_leaners + polknow + polint + college + agecat + female + nonwhite, data = octHead, clusters = caseid, weights = weight), include.ci = F)

screenreg((h2ac1O), digits = 3, custom.coef.names = c('(Intercept)', 'Total Fake News Count', 'CRT 2', 'CRT 3', 'Democrat Leaners ', ' Republican Leaners ', ' Political Knowledge ', ' Political Interest ', ' College ', ' Age 2 ', ' Age 3 ', ' Age 4 ', ' Female ', ' Nonwhite ', 'Total Fake News Count : CRT 2', 'Total Fake News Count : CRT 3'))

#texreg((h2ac1O), digits = 3, custom.coef.names = c('(Intercept)', 'Total Fake News Count', 'CRT 2', 'CRT 3', 'Democrat Leaners ', ' Republican Leaners ', ' Political Knowledge ', ' Political Interest ', ' College ', ' Age 2 ', ' Age 3 ', ' Age 4 ', ' Female ', ' Nonwhite ', 'Total Fake News Count : CRT 2', 'Total Fake News Count : CRT 3'))
###############################################################################################

#H-A2c DV2 OCTOBER
h2ac2O <- extract.lm_robust(lm_robust(HL_accuracy ~ totalfakebinary18 * as.factor(crt_terc) + dem_leaners + repub_leaners + polknow + polint + college + agecat + female + nonwhite, data = octHead, clusters = caseid, weights = weight), include.ci = F)

screenreg((h2ac2O), digits = 4, custom.coef.names = c('(Intercept)', 'Total Fake News Count', 'CRT 2', 'CRT 3', 'Democrat Leaners ', ' Republican Leaners ', ' Political Knowledge ', ' Political Interest ', ' College ', ' Age 2 ', ' Age 3 ', ' Age 4 ', ' Female ', ' Nonwhite ', 'Total Fake News Count : CRT 2', 'Total Fake News Count : CRT 3'))

#texreg((h2ac2O), digits = 4, custom.coef.names = c('(Intercept)', 'Total Fake News Count', 'CRT 2', 'CRT 3', 'Democrat Leaners ', ' Republican Leaners ', ' Political Knowledge ', ' Political Interest ', ' College ', ' Age 2 ', ' Age 3 ', ' Age 4 ', ' Female ', ' Nonwhite ', 'Total Fake News Count : CRT 2', 'Total Fake News Count : CRT 3'))
###############################################################################################

#H-A2d DV1 OCTOBER

h2ad1O <- extract.lm_robust(lm_robust(mean_acc_diff ~ totalfakecount18 + dem_leaners + repub_leaners + polknow + polint + college + agecat + female + nonwhite, data = oct, weights = weight), include.ci = F)


#H-A2d DV2 OCTOBER

h2ad2O <- extract.lm_robust(lm_robust(mean_acc_diff ~ totalfakebinary18 + dem_leaners + repub_leaners + polknow + polint + college + agecat + female + nonwhite, data = oct, weights = weight), include.ci = F)


screenreg(list(h2ad1O, h2ad2O), digits = 4, custom.coef.names = c('(Intercept)','Total Fake News Count', 'Democrat Leaners ', ' Republican Leaners ', ' Political Knowledge ', ' Political Interest ', ' College ', ' Age 2 ', ' Age 3 ', ' Age 4 ', ' Female ', ' Nonwhite ', 'Total Fake News Binary '))

#texreg(list(h2ad1O, h2ad2O), digits = 4, custom.coef.names = c('(Intercept)','Total Fake News Count', 'Democrat Leaners ', ' Republican Leaners ', ' Political Knowledge ', ' Political Interest ', ' College ', ' Age 2 ', ' Age 3 ', ' Age 4 ', ' Female ', ' Nonwhite ', 'Total Fake News Binary '))
############################################################################################################

#H - A3) People who consume fake news will be more likely to hold topical misperceptions than those who do not consume fake news(H - A3a) This relationship will be stronger for pro - attitudinal misperceptions than for counter - attitudinal misperceptions(H - A3b) and for  people who are relatively less skilled at analytical reasoning(H - A3c) . People who consume fake news will be less likely to successfully distinguish between true and false topical statements(H - A3d) .

#For H - A3a, H - A3b, and H - A3c, the outcome measure is the perceived accuracy of true and false topical statements. These models will be estimated separately for  wave 1 and wave 2 topical misperceptions. For each of these types of statements in wave 1, we will estimate the following models:

# H - A3a:Accuracy = [constant] + prior fake news exposure + covariates listed above
# H - A3b:Accuracy = [constant] + prior fake news exposure + congenial + prior fake news exposure * congenial + covariates listed above
# H - A3c:Accuracy = [constant] + prior fake news exposure + CRT score + prior fake news exposure * CRT score + covariates listed above * /

#For H - A3d, the outcome measure = (mean perceived accuracy of true statements - mean perceived accuracy of false statements) . This Hypothesis is measured at the respondent level using a single mean difference that is not ordered and thus we will only test it using OLS with robust standard errors(i.e., no question fixed effects or clustering) .
# H - A3c: Topical Accuracy Difference = [constant] + prior fake news exposure + covariates listed above

#  H-A3a-H-A3c -- USE ONLY FALSE JUNE
############################################################################################################

juneTopicalFw1 <- tidyr::gather(june, mis_DF, misPerception, mis_pro_d_false, mis_pro_r_false)

#H-A3a JUNE W1 COUNT
ha3a1w1J <- extract.lm_robust(lm_robust(misPerception ~ totalfakecount18 + +dem_leaners + repub_leaners + polknow + polint + college + agecat + female + nonwhite, data = juneTopicalFw1, clusters = caseid, weights = weight), include.ci = F)


#H-A3a JUNE W1 BINARY   
ha3a2w1J <- extract.lm_robust(lm_robust(misPerception ~ totalfakebinary18 + +dem_leaners + repub_leaners + polknow + polint + college + agecat + female + nonwhite, data = juneTopicalFw1, clusters = caseid, weights = weight), include.ci = F)


#H-A3b JUNE W1 COUNT

ha3b1w1J <- extract.lm_robust(lm_robust(misPerception ~ totalfakecount18 * as.factor(congenial_fn) + dem_leaners + repub_leaners + polknow + polint + college + agecat + female + nonwhite, data = subset(juneTopicalFw1, juneTopicalFw1$pid3 != 'Independent'), clusters = caseid, weights = weight), include.ci = F)


#H-A3b JUNE W1 BINARY
ha3b2w1J <- extract.lm_robust(lm_robust(misPerception ~ totalfakebinary18 * as.factor(congenial_fn) + dem_leaners + repub_leaners + polknow + polint + college + agecat + female + nonwhite, data = subset(juneTopicalFw1, juneTopicalFw1$pid3 != 'Independent'), clusters = caseid, weights = weight), include.ci = F)

screenreg(list(ha3a1w1J, ha3a2w1J, ha3b1w1J, ha3b2w1J), digits = 4, custom.coef.names = c('(Intercept)', 'Total Fake News Count', 'Democrat Leaners', 'Republican Leaners', 'Political Knowledge', 'Political Interest', 'College', 'Age 2', 'Age 3', 'Age 4', 'Female', 'Nonwhite', 'Total Fake News Binary', 'FN Congeniality 1', 'Total Fake Count : FN Congeniality 1', 'Total Fake Binary : FN Congeniality 1'))
#texreg(list(ha3a1w1J, ha3a2w1J, ha3b1w1J, ha3b2w1J), digits = 4, custom.coef.names = c('(Intercept)', 'Total Fake News Count', 'Democrat Leaners', 'Republican Leaners', 'Political Knowledge', 'Political Interest', 'College', 'Age 2', 'Age 3', 'Age 4', 'Female', 'Nonwhite', 'Total Fake News Binary', 'FN Congeniality 1', 'Total Fake Count : FN Congeniality 1', 'Total Fake Binary : FN Congeniality 1'))
############################################################################################################

#H-A3c JUNE W1 COUNT
ha3c1w1J <- extract.lm_robust(lm_robust(misPerception ~ totalfakecount18 * as.factor(crt_terc) + dem_leaners + repub_leaners + polknow + polint + college + agecat + female + nonwhite, data = juneTopicalFw1, clusters = caseid, weights = weight), include.ci = F)


screenreg((ha3c1w1J), digits = 4, custom.coef.names = c('(Intercept)', 'Total Fake News Count', 'CRT 2', 'CRT 3', 'Democrat Leaners ', ' Republican Leaners ', ' Political Knowledge ', ' Political Interest ', ' College ', ' Age 2 ', ' Age 3 ', ' Age 4 ', ' Female ', ' Nonwhite ', 'Total Fake News Count : CRT 2', 'Total Fake News Count : CRT 3'))
#texreg((ha3c1w1J), digits = 4, custom.coef.names = c('(Intercept)', 'Total Fake News Count', 'CRT 2', 'CRT 3', 'Democrat Leaners ', ' Republican Leaners ', ' Political Knowledge ', ' Political Interest ', ' College ', ' Age 2 ', ' Age 3 ', ' Age 4 ', ' Female ', ' Nonwhite ', 'Total Fake News Count : CRT 2', 'Total Fake News Count : CRT 3'))
#H-A3c JUNE W1 BINARY
############################################################################################################

ha3c2w1J <- extract.lm_robust(lm_robust(misPerception ~ totalfakebinary18 * as.factor(crt_terc) + dem_leaners + repub_leaners + polknow + polint + college + agecat + female + nonwhite, data = juneTopicalFw1, clusters = caseid, weights = weight), include.ci = F)

screenreg((ha3c2w1J), digits = 4, custom.coef.names = c('(Intercept)', 'Total Fake News Binary', 'CRT 2', 'CRT 3', 'Democrat Leaners ', ' Republican Leaners ', ' Political Knowledge ', ' Political Interest ', ' College ', ' Age 2 ', ' Age 3 ', ' Age 4 ', ' Female ', ' Nonwhite ', 'Total Fake News Binary : CRT 2', 'Total Fake News Binary : CRT 3'))
#texreg((ha3c2w1J), digits = 4, custom.coef.names = c('(Intercept)', 'Total Fake News Binary', 'CRT 2', 'CRT 3', 'Democrat Leaners ', ' Republican Leaners ', ' Political Knowledge ', ' Political Interest ', ' College ', ' Age 2 ', ' Age 3 ', ' Age 4 ', ' Female ', ' Nonwhite ', 'Total Fake News Binary : CRT 2', 'Total Fake News Binary : CRT 3'))
############################################################################################################

#H-A3d JUNE W1 COUNT
ha3d1w1J <- extract.lm_robust(lm_robust(topical_accuracy_diff ~ totalfakecount18 + dem_leaners + repub_leaners + polknow + polint + college + agecat + female + nonwhite, data = june, weights = weight), include.ci = F)

#H-A3d JUNE W1 BINARY

ha3d2w1J <- extract.lm_robust(lm_robust(topical_accuracy_diff ~ totalfakebinary18 + dem_leaners + repub_leaners + polknow + polint + college + agecat + female + nonwhite, data = june, weights = weight), include.ci = F)

screenreg(list(ha3d1w1J, ha3d2w1J), custom.coef.names = c('(Intercept)', 'Total Fake News Count', 'Democrat Leaners', 'Republican Leaners', 'Political Knowledge', 'Political Interest', 'College', 'Age 2', 'Age 3', 'Age 4', 'Female', 'Nonwhite', 'Total Fake Binary'))
#texreg(list(ha3d1w1J, ha3d2w1J), custom.coef.names = c('(Intercept)', 'Total Fake News Count', 'Democrat Leaners', 'Republican Leaners', 'Political Knowledge', 'Political Interest', 'College', 'Age 2', 'Age 3', 'Age 4', 'Female', 'Nonwhite', 'Total Fake Binary'))



############################################################################################################
#WAVE 2

juneTopicalFw2 <- tidyr::gather(june, mis_DF, misPerception, mis_pro_d_falsew2, mis_pro_r_falsew2)

#H-A3a JUNE W2 COUNT
ha3a1w2J <- extract.lm_robust(lm_robust(misPerception ~ totalfakecount18 + +dem_leaners + repub_leaners + polknow + polint + college + agecat + female + nonwhite, data = juneTopicalFw2, clusters = caseid, weights = weight), include.ci = F)

#H-A3a JUNE W2 BINARY   
ha3a2w2J <- extract.lm_robust(lm_robust(misPerception ~ totalfakebinary18 + +dem_leaners + repub_leaners + polknow + polint + college + agecat + female + nonwhite, data = juneTopicalFw2, clusters = caseid, weights = weight), include.ci = F)

#H-A3b JUNE W2 COUNT

ha3b1w2J <- extract.lm_robust(lm_robust(misPerception ~ totalfakecount18 * as.factor(congenial_fn) + dem_leaners + repub_leaners + polknow + polint + college + agecat + female + nonwhite, data = subset(juneTopicalFw2, juneTopicalFw2$pid3 != 'Independent'), clusters = caseid, weights = weight), include.ci = F)

#H-A3b JUNE W2 BINARY
ha3b2w2J <- extract.lm_robust(lm_robust(misPerception ~ totalfakebinary18 * as.factor(congenial_fn) + dem_leaners + repub_leaners + polknow + polint + college + agecat + female + nonwhite, data = subset(juneTopicalFw2, juneTopicalFw2$pid3 != 'Independent'), clusters = caseid, weights = weight), include.ci = F)


screenreg(list(ha3a1w2J, ha3a2w2J, ha3b1w2J, ha3b2w2J), digits = 4, custom.coef.names = c('(Intercept)', 'Total Fake News Count', 'Democrat Leaners', 'Republican Leaners', 'Political Knowledge', 'Political Interest', 'College', 'Age 2', 'Age 3', 'Age 4', 'Female', 'Nonwhite', 'Total Fake News Binary', 'FN Congeniality 1', 'Total Fake Count : FN Congeniality 1', 'Total Fake Binary : FN Congeniality 1'))

#texreg(list(ha3a1w2J, ha3a2w2J, ha3b1w2J, ha3b2w2J), digits = 4, custom.coef.names = c('(Intercept)', 'Total Fake News Count', 'Democrat Leaners', 'Republican Leaners', 'Political Knowledge', 'Political Interest', 'College', 'Age 2', 'Age 3', 'Age 4', 'Female', 'Nonwhite', 'Total Fake News Binary', 'FN Congeniality 1', 'Total Fake Count : FN Congeniality 1', 'Total Fake Binary : FN Congeniality 1'))
############################################################################################################



#H-A3c JUNE W2 COUNT
ha3c1w2J <- extract.lm_robust(lm_robust(misPerception ~ totalfakecount18 * as.factor(crt_terc) + dem_leaners + repub_leaners + polknow + polint + college + agecat + female + nonwhite, data = juneTopicalFw2, clusters = caseid, weights = weight), include.ci = F)

screenreg((ha3c1w2J), digits = 4, custom.coef.names = c('(Intercept)', 'Total Fake News Count', 'CRT 2', 'CRT 3', 'Democrat Leaners ', ' Republican Leaners ', ' Political Knowledge ', ' Political Interest ', ' College ', ' Age 2 ', ' Age 3 ', ' Age 4 ', ' Female ', ' Nonwhite ', 'Total Fake News Count : CRT 2', 'Total Fake News Count : CRT 3'))

#texreg((ha3c1w2J), digits = 4, custom.coef.names = c('(Intercept)', 'Total Fake News Count', 'CRT 2', 'CRT 3', 'Democrat Leaners ', ' Republican Leaners ', ' Political Knowledge ', ' Political Interest ', ' College ', ' Age 2 ', ' Age 3 ', ' Age 4 ', ' Female ', ' Nonwhite ', 'Total Fake News Count : CRT 2', 'Total Fake News Count : CRT 3'))
############################################################################################################


#H-A3c JUNE W2 BINARY

ha3c2w2J <- extract.lm_robust(lm_robust(misPerception ~ totalfakebinary18 * as.factor(crt_terc) + dem_leaners + repub_leaners + polknow + polint + college + agecat + female + nonwhite, data = juneTopicalFw2, clusters = caseid, weights = weight), include.ci = F)


screenreg((ha3c2w2J), digits = 4, custom.coef.names = c('(Intercept)', 'Total Fake News Binary', 'CRT 2', 'CRT 3', 'Democrat Leaners ', ' Republican Leaners ', ' Political Knowledge ', ' Political Interest ', ' College ', ' Age 2 ', ' Age 3 ', ' Age 4 ', ' Female ', ' Nonwhite ', 'Total Fake News Binary : CRT 2', 'Total Fake News Binary : CRT 3'))
#texreg((ha3c2w2J), digits = 4, custom.coef.names = c('(Intercept)', 'Total Fake News Binary', 'CRT 2', 'CRT 3', 'Democrat Leaners ', ' Republican Leaners ', ' Political Knowledge ', ' Political Interest ', ' College ', ' Age 2 ', ' Age 3 ', ' Age 4 ', ' Female ', ' Nonwhite ', 'Total Fake News Binary : CRT 2', 'Total Fake News Binary : CRT 3'))
############################################################################################################

#H-A3d 

#H-A3d JUNE W2 COUNT

ha3d1w2J <- extract.lm_robust(lm_robust(topical_accuracy_diff_w2 ~ totalfakecount18 + dem_leaners + repub_leaners + polknow + polint + college + agecat + female + nonwhite, data = june, clusters = caseid, weights = weight), include.ci = F)

#H-A3d JUNE W2 BINARY

ha3d2w2J <- extract.lm_robust(lm_robust(topical_accuracy_diff_w2 ~ totalfakebinary18 + dem_leaners + repub_leaners + polknow + polint + college + agecat + female + nonwhite, data = june, clusters = caseid, weights = weight), include.ci = F)


screenreg(list(ha3d1w2J, ha3d2w2J), custom.coef.names = c('(Intercept)', 'Total Fake News Count', 'Democrat Leaners', 'Republican Leaners', 'Political Knowledge', 'Political Interest', 'College', 'Age 2', 'Age 3', 'Age 4', 'Female', 'Nonwhite', 'Total Fake Binary'))
#texreg(list(ha3d1w2J, ha3d2w2J), custom.coef.names = c('(Intercept)', 'Total Fake News Count', 'Democrat Leaners', 'Republican Leaners', 'Political Knowledge', 'Political Interest', 'College', 'Age 2', 'Age 3', 'Age 4', 'Female', 'Nonwhite', 'Total Fake Binary'), digit =4)

############################################################################################################ 
#H-A3a-H-A3c -- USE ONLY FALSE OCTOBER

octTopicalFw1 <- tidyr:: gather(oct, mis_DF, misPerception,mis_pro_d_false, mis_pro_r_false )

#H-A3a OCTOBER W1 COUNT
ha3a1w1O <- extract.lm_robust(lm_robust(misPerception ~ totalfakecount18 + +dem_leaners + repub_leaners + polknow + polint + college + agecat + female + nonwhite, data = octTopicalFw1, clusters = caseid, weights = weight), include.ci = F)


#H-A3a OCTOBER W1 BINARY   
ha3a2w1O <- extract.lm_robust(lm_robust(misPerception ~ totalfakebinary18 + +dem_leaners + repub_leaners + polknow + polint + college + agecat + female + nonwhite, data = octTopicalFw1, clusters = caseid, weights = weight), include.ci = F)


#H-A3b OCTOBER W1 COUNT

ha3b1w1O <- extract.lm_robust(lm_robust(misPerception ~ totalfakecount18 * as.factor(congenial_fn) + dem_leaners + repub_leaners + polknow + polint + college + agecat + female + nonwhite, data = subset(octTopicalFw1, octTopicalFw1$pid3 != 'Independent'), clusters = caseid, weights = weight), include.ci = F)


#H-A3b OCTOBER W1 BINARY
ha3b2w1O <- extract.lm_robust(lm_robust(misPerception ~ totalfakebinary18 * as.factor(congenial_fn) + dem_leaners + repub_leaners + polknow + polint + college + agecat + female + nonwhite, data = subset(octTopicalFw1, octTopicalFw1$pid3 != 'Independent'), clusters = caseid, weights = weight), include.ci = F)

screenreg(list(ha3a2w1O, ha3a2w1O, ha3b1w1O, ha3b2w1O), digits = 4, custom.coef.names = c('(Intercept)', 'Total Fake News Count', 'Democrat Leaners', 'Republican Leaners', 'Political Knowledge', 'Political Interest', 'College', 'Age 2', 'Age 3', 'Age 4', 'Female', 'Nonwhite', 'Total Fake News Binary', 'FN Congeniality 1', 'Total Fake Count : FN Congeniality 1', 'Total Fake Binary : FN Congeniality 1'))
#texreg(list(ha3a2w1O, ha3a2w1O, ha3b1w1O, ha3b2w1O), digits = 4, custom.coef.names = c('(Intercept)', 'Total Fake News Count', 'Democrat Leaners', 'Republican Leaners', 'Political Knowledge', 'Political Interest', 'College', 'Age 2', 'Age 3', 'Age 4', 'Female', 'Nonwhite', 'Total Fake News Binary', 'FN Congeniality 1', 'Total Fake Count : FN Congeniality 1', 'Total Fake Binary : FN Congeniality 1'))
############################################################################################################

#H-A3c OCTOBER W1 COUNT
ha3c1w1O <- extract.lm_robust(lm_robust(misPerception ~ totalfakecount18 * as.factor(crt_terc) + dem_leaners + repub_leaners + polknow + polint + college + agecat + female + nonwhite, data = octTopicalFw1, clusters = caseid, weights = weight), include.ci = F)

screenreg((ha3c1w1O), digits = 4, custom.coef.names = c('(Intercept)', 'Total Fake News Count', 'CRT 2', 'CRT 3', 'Democrat Leaners ', ' Republican Leaners ', ' Political Knowledge ', ' Political Interest ', ' College ', ' Age 2 ', ' Age 3 ', ' Age 4 ', ' Female ', ' Nonwhite ', 'Total Fake News Count : CRT 2', 'Total Fake News Count : CRT 3'))
#texreg((ha3c1w1O), digits = 4, custom.coef.names = c('(Intercept)', 'Total Fake News Count', 'CRT 2', 'CRT 3', 'Democrat Leaners ', ' Republican Leaners ', ' Political Knowledge ', ' Political Interest ', ' College ', ' Age 2 ', ' Age 3 ', ' Age 4 ', ' Female ', ' Nonwhite ', 'Total Fake News Count : CRT 2', 'Total Fake News Count : CRT 3'))
############################################################################################################

#H-A3c OCTOBER W1 BINARY

ha3c2w1O <- extract.lm_robust(lm_robust(misPerception ~ totalfakebinary18 * as.factor(crt_terc) + dem_leaners + repub_leaners + polknow + polint + college + agecat + female + nonwhite, data = octTopicalFw1, clusters = caseid, weights = weight), include.ci = F)

screenreg((ha3c2w1O), digits = 4, custom.coef.names = c('(Intercept)', 'Total Fake News Binary', 'CRT 2', 'CRT 3', 'Democrat Leaners ', ' Republican Leaners ', ' Political Knowledge ', ' Political Interest ', ' College ', ' Age 2 ', ' Age 3 ', ' Age 4 ', ' Female ', ' Nonwhite ', 'Total Fake News Binary : CRT 2', 'Total Fake News Binary : CRT 3'))
#texreg((ha3c2w1O), digits = 4, custom.coef.names = c('(Intercept)', 'Total Fake News Binary', 'CRT 2', 'CRT 3', 'Democrat Leaners ', ' Republican Leaners ', ' Political Knowledge ', ' Political Interest ', ' College ', ' Age 2 ', ' Age 3 ', ' Age 4 ', ' Female ', ' Nonwhite ', 'Total Fake News Binary : CRT 2', 'Total Fake News Binary : CRT 3'))
############################################################################################################

#H-A3d OCTOBER W1 COUNT
ha3d1w1O <- extract.lm_robust(lm_robust(topical_accuracy_diff ~ totalfakecount18 + dem_leaners + repub_leaners + polknow + polint + college + as.factor(agecat) + female + nonwhite, data = oct, weights = weight), include.ci = F)

#H-A3d OCTOBER W1 BINARY

ha3d2w1O <- extract.lm_robust(lm_robust(topical_accuracy_diff ~ totalfakebinary18 + dem_leaners + repub_leaners + polknow + polint + college + as.factor(agecat) + female + nonwhite, data = oct, clusters = caseid, weights = weight), include.ci = F)

screenreg(list(ha3d1w1O, ha3d2w1O), custom.coef.names = c('(Intercept)', 'Total Fake News Count', 'Democrat Leaners', 'Republican Leaners', 'Political Knowledge', 'Political Interest', 'College', 'Age 2', 'Age 3', 'Age 4', 'Female', 'Nonwhite', 'Total Fake News Binary'), digit = 3)
#texreg(list(ha3d1w1O, ha3d2w10), custom.coef.names = c('(Intercept)', 'Total Fake News Count', 'Democrat Leaners', 'Republican Leaners', 'Political Knowledge', 'Political Interest', 'College', 'Age 2', 'Age 3', 'Age 4', 'Female', 'Nonwhite', 'Total Fake News Binary'), digit = 3)
############################################################################################################

#WAVE 2
octTopicalFw2 <- tidyr::gather(oct, mis_DF, misPerception, misinform_soros_w2, misinform_jamal_w2)

octTopicalFw2$misPerception <- as.factor(octTopicalFw2$misPerception)
#juneHead$caseid <- as.numeric(juneHead$caseid)


# CONVERT FACTOR TO NUMBER IF YOU WANT THIS SHIT TO RUN
octTopicalFw2$misPerception <- as.character(octTopicalFw2$misPerception)
octTopicalFw2$misPerception[octTopicalFw2$misPerception == 'Not at all accurate'] <- 1
octTopicalFw2$misPerception[octTopicalFw2$misPerception == 'Not very accurate'] <- 2
octTopicalFw2$misPerception[octTopicalFw2$misPerception == 'Somewhat accurate'] <- 3
octTopicalFw2$misPerception[octTopicalFw2$misPerception == 'Very accurate'] <- 4

octTopicalFw2$misPerception <- as.numeric(octTopicalFw2$misPerception)
############################################################################################################


#H-A3a OCTOBER W2 COUNT
ha3a1O <- extract.lm_robust(lm_robust(misPerception ~ totalfakecount18 + +dem_leaners + repub_leaners + polknow + polint + college + agecat + female + nonwhite, data = octTopicalFw2, clusters = caseid, weights = weight), include.ci = F)


#H-A3a OCTOBER W2 BINARY   
ha3a2O <- extract.lm_robust(lm_robust(misPerception ~ totalfakebinary18 + +dem_leaners + repub_leaners + polknow + polint + college + agecat + female + nonwhite, data = octTopicalFw2, clusters = caseid, weights = weight), include.ci = F)

#H-A3b OCTOBER W2 COUNT

ha3b1O <- extract.lm_robust(lm_robust(misPerception ~ totalfakecount18 * as.factor(congenial_fn) + dem_leaners + repub_leaners + polknow + polint + college + agecat + female + nonwhite, data = subset(octTopicalFw2, octTopicalFw2$pid3 != 'Independent'), clusters = caseid, weights = weight), include.ci = F)

#H-A3b OCTOBER W2 BINARY
ha3b2O <- extract.lm_robust(lm_robust(misPerception ~ totalfakebinary18 * as.factor(congenial_fn) + dem_leaners + repub_leaners + polknow + polint + college + agecat + female + nonwhite, data = subset(octTopicalFw2, octTopicalFw2$pid3 != 'Independent'), clusters = caseid, weights = weight), include.ci = F)


screenreg(list(ha3a1O, ha3a2O, ha3b1O, ha3b2O), digits = 4, custom.coef.names = c('(Intercept)', 'Total Fake News Count', 'Democrat Leaners', 'Republican Leaners', 'Political Knowledge', 'Political Interest', 'College', 'Age 2', 'Age 3', 'Age 4', 'Female', 'Nonwhite', 'Total Fake News Binary', 'FN Congeniality 1', 'Total Fake Count : FN Congeniality 1', 'Total Fake Binary : FN Congeniality 1'))
#texreg(list(ha3a1O, ha3a2O, ha3b1O, ha3b2O), digits = 4, custom.coef.names = c('(Intercept)', 'Total Fake News Count', 'Democrat Leaners', 'Republican Leaners', 'Political Knowledge', 'Political Interest', 'College', 'Age 2', 'Age 3', 'Age 4', 'Female', 'Nonwhite', 'Total Fake News Binary', 'FN Congeniality 1', 'Total Fake Count : FN Congeniality 1', 'Total Fake Binary : FN Congeniality 1'))
############################################################################################################



#H-A3c OCTOBER W2 COUNT
ha3c1O <- extract.lm_robust(lm_robust(misPerception ~ totalfakecount18 * as.factor(crt_terc) + dem_leaners + repub_leaners + polknow + polint + college + agecat + female + nonwhite, data = octTopicalFw2, clusters = caseid, weights = weight), include.ci = F)

screenreg((ha3c1O), digits = 4, custom.coef.names = c('(Intercept)', 'Total Fake News Count', 'CRT 2', 'CRT 3', 'Democrat Leaners ', ' Republican Leaners ', ' Political Knowledge ', ' Political Interest ', ' College ', ' Age 2 ', ' Age 3 ', ' Age 4 ', ' Female ', ' Nonwhite ', 'Total Fake News Count : CRT 2', 'Total Fake News Count : CRT 3'))
#texreg((ha3c1O), digits = 4, custom.coef.names = c('(Intercept)', 'Total Fake News Count', 'CRT 2', 'CRT 3', 'Democrat Leaners ', ' Republican Leaners ', ' Political Knowledge ', ' Political Interest ', ' College ', ' Age 2 ', ' Age 3 ', ' Age 4 ', ' Female ', ' Nonwhite ', 'Total Fake News Count : CRT 2', 'Total Fake News Count : CRT 3'))
############################################################################################################

#H-A3c OCTOBER W2 BINARY

ha3c2O <- extract.lm_robust(lm_robust(misPerception ~ totalfakebinary18 * as.factor(crt_terc) + dem_leaners + repub_leaners + polknow + polint + college + agecat + female + nonwhite, data = octTopicalFw2, clusters = caseid, weights = weight), include.ci = F)

screenreg((ha3c2O), digits = 4, custom.coef.names = c('(Intercept)', 'Total Fake News Binary', 'CRT 2', 'CRT 3', 'Democrat Leaners ', ' Republican Leaners ', ' Political Knowledge ', ' Political Interest ', ' College ', ' Age 2 ', ' Age 3 ', ' Age 4 ', ' Female ', ' Nonwhite ', 'Total Fake News Binary : CRT 2', 'Total Fake News Binary : CRT 3'))
#texreg((ha3c2O), digits = 4, custom.coef.names = c('(Intercept)', 'Total Fake News Binary', 'CRT 2', 'CRT 3', 'Democrat Leaners ', ' Republican Leaners ', ' Political Knowledge ', ' Political Interest ', ' College ', ' Age 2 ', ' Age 3 ', ' Age 4 ', ' Female ', ' Nonwhite ', 'Total Fake News Binary : CRT 2', 'Total Fake News Binary : CRT 3'))
############################################################################################################

#H-A3d OCTOBER W2 COUNT

ha3d1w2O <- extract.lm_robust(lm_robust(topical_accuracy_diff_w2 ~ totalfakecount18 + dem_leaners + repub_leaners + polknow + polint + college + agecat + female + nonwhite, data = oct, clusters = caseid, weights = weight), include.ci = F)


#H-A3d OCTOBER W2 BINARY

ha3d2w2O <- extract.lm_robust(lm_robust(topical_accuracy_diff_w2 ~ totalfakebinary18 + dem_leaners + repub_leaners + polknow + polint + college + agecat + female + nonwhite, data = oct, clusters = caseid, weights = weight), include.ci = F)

screenreg(list(ha3d1w2O, ha3d2w2O), custom.coef.names = c('(Intercept)', 'Total Fake News Count', 'Democrat Leaners', 'Republican Leaners', 'Political Knowledge', 'Political Interest', 'College', 'Age 2', 'Age 3', 'Age 4', 'Female', 'Nonwhite', 'Total Fake News Binary'), digit = 3)
#texreg(list(ha3d1w2O, ha3d2w2O), custom.coef.names = c('(Intercept)', 'Total Fake News Count', 'Democrat Leaners', 'Republican Leaners', 'Political Knowledge', 'Political Interest', 'College', 'Age 2', 'Age 3', 'Age 4', 'Female', 'Nonwhite', 'Total Fake News Binary'), digit = 3)
############################################################################################################


#For H - E1a and RQ - F1, the outcome measure is affective polarization. For H - E1b and RQ - F2, the outcome measure is affect toward the media. For H - E2 and RQ - F3, the outcome measure is intent to vote. For H - E3 and RQ - F4, the outcome measure is the intent to take political action scale.
#For each of these hypotheses, we will estimate the following model using OLS regression(with robustness checks using ordered probit where appropriate):
#  Outcome = [constant] + congenial fake news exposure + uncongenial fake news exposure
############################################################################################################
#Force Binary
june$plan_vote_w2 <- as.character(june$plan_vote_w2)
june$plan_vote_w2[june$plan_vote_w2 == 'Yes'] <- 1
june$plan_vote_w2[june$plan_vote_w2 == 'No'] <- 0
june$plan_vote_w2[june$plan_vote_w2 == "Don't Know"] <- NA
june$plan_vote_w2[june$plan_vote_w2 == 'skipped'] <- NA
june$plan_vote_w2[june$plan_vote_w2 == 'not asked'] <- NA

june$plan_vote_w2 <- as.numeric(june$plan_vote_w2)
############################################################################################################

#H-E1A
#Affective Polarization
he1aJ <- extract.lm_robust(lm_robust(formula = affect_merged_leaners ~ congenial_fn + uncongenial_fn, weights = weight, data = subset(june, june$pid3 != 'Independent')), include.ci = F)

#H-E1b
#Political Thermometer
he1bJ <- extract.lm_robust(lm_robust(formula = pol_therm_media_w2 ~ congenial_fn + uncongenial_fn, weights = weight, data = subset(june, june$pid3 != 'Independent')), include.ci = F)

#H-E2
#Vote Intent
he2J <- extract.lm_robust(lm_robust(formula = plan_vote_w2 ~ congenial_fn + uncongenial_fn, weights = weight, data = subset(june, june$pid3 != 'Independent')), include.ci = F)

#H-E3
#Political Action
he3J <- extract.lm_robust(lm_robust(formula = polact_mean ~ congenial_fn + uncongenial_fn, weights = weight, data = subset(june, june$pid3 != 'Independent')), include.ci = F)


screenreg(list(he1aJ, he1bJ, he2J, he3J), custom.coef.names = c('(Intercept)','Congenial Fake News', 'Uncongenial Fake News'))
#texreg(list(he1aJ, he1bJ, he2J, he3J), custom.coef.names = c('(Intercept)','Congenial Fake News', 'Uncongenial Fake News'))
############################################################################################################




oct$plan_vote_w2 <- as.character(oct$plan_vote_w2)
oct$plan_vote_w2[oct$plan_vote_w2 == 'Yes'] <- 1
oct$plan_vote_w2[oct$plan_vote_w2 == 'No'] <- 0
oct$plan_vote_w2[oct$plan_vote_w2 == "Don't Know"] <- NA
oct$plan_vote_w2[oct$plan_vote_w2 == 'skipped'] <- NA
oct$plan_vote_w2[oct$plan_vote_w2 == 'not asked'] <- NA

oct$plan_vote_w2 <- as.numeric(oct$plan_vote_w2)
############################################################################################################

#H-E1A
#Affective Polarization
he1aO <- extract.lm_robust(lm_robust(formula = affect_merged_leaners ~ congenial_fn + uncongenial_fn, data = subset(oct, oct$pid3 != 'Independent')), include.ci = F)

#H-E1b
#Political Thermometer
he1bO <- extract.lm_robust(lm_robust(formula = pol_therm_media_w2 ~ congenial_fn + uncongenial_fn, weights = weight, data = subset(oct, oct$pid3 != 'Independent')), include.ci = F)


#H-E2
he2O <- extract.lm_robust(lm_robust(formula = plan_vote_w2 ~ congenial_fn + uncongenial_fn, weights = weight, data = subset(oct, oct$pid3 != 'Independent')), include.ci = F)

#H-E3
he3O <- extract.lm_robust(lm_robust(formula = polact_mean ~ congenial_fn + uncongenial_fn, weights = weight, data = subset(oct, oct$pid3 != 'Independent')), include.ci = F)

screenreg(list(he1aO, he1bO, he2O, he2O), custom.coef.names = c('(Intercept)', 'Congenial Fake News', 'Uncongenial Fake News'))
#texreg(list(he1aO, he1bO, he2O, he2O), custom.coef.names = c('(Intercept)', 'Congenial Fake News', 'Uncongenial Fake News'))



#################################################################################################################
#Jacob's Hypotheses

june$totalfakecount18_pre = june$totalfakecount18_pre + 1
june$lean_Dem <- NA
for (i in 1:nrow(june)) {
    if (is.na(june$dem_leaners[i]) == F & june$dem_leaners[i] == 1) {
        june$lean_Dem[i] <- 1
    }
}
for (i in 1:nrow(june)) {
    if (is.na(june$dem_leaners[i]) == F & june$repub_leaners[i] == 1) {
        june$lean_Dem[i] <- 0
    }
}
for (i in 1:nrow(june)) {
    if (is.na(june$independents[i]) == F & june$independents[i] == 1) {
        june$lean_Dem[i] <- NA
    }
}

oct$lean_Dem <- NA
for (i in 1:nrow(oct)) {
    if (is.na(oct$dem_leaners[i]) == F & oct$dem_leaners[i] == 1) {
        oct$lean_Dem[i] <- 1
    }
}
for (i in 1:nrow(oct)) {
    if (is.na(oct$dem_leaners[i]) == F & oct$repub_leaners[i] == 1) {
        oct$lean_Dem[i] <- 0
    }
}
for (i in 1:nrow(oct)) {
    if (is.na(oct$independents[i]) == F & oct$independents[i] == 1) {
        oct$lean_Dem[i] <- NA
    }
}



#Political Thermometer
d1a <- extract.lm_robust(lm_robust(formula = pol_therm_media ~ log(totalfakecount18_pre) + lean_Dem + ideology + polknow + pol_therm_trump + agecat + nonwhite + college, weights = weight, data = (june)), include.ci = F)


d1b <- extract.lm_robust(lm_robust(formula = pol_therm_media ~ totalfakebinary18_pre + lean_Dem + ideology + polknow + pol_therm_trump + agecat + nonwhite + college, weights = weight, data = (june)), include.ci = F)
########################################################################################


#Trust in Media
d2a <- extract.lm_robust(lm_robust(formula = massmedia_trust ~ log(totalfakecount18_pre) + lean_Dem + ideology + polknow + pol_therm_trump + agecat + nonwhite + college, weights = weight, data = (june)), include.ci = F)

d2b <- extract.lm_robust(lm_robust(formula = massmedia_trust ~ totalfakebinary18_pre + lean_Dem + ideology + polknow + pol_therm_trump + agecat + nonwhite + college, weights = weight, data = (june)), include.ci = F)
########################################################################################

#Affective Polarization
d3a <- extract.lm_robust(lm_robust(formula = affect_merged_leanersw1 ~ log(totalfakecount18_pre) + lean_Dem + ideology + polknow + pol_therm_trump + agecat + nonwhite + college, weights = weight, data = (june)), include.ci = F)


d3b <- extract.lm_robust(lm_robust(formula = affect_merged_leanersw1 ~ totalfakebinary18_pre + lean_Dem + ideology + polknow + pol_therm_trump + agecat + nonwhite + college, weights = weight, data = (june)), include.ci = F)
########################################################################################

#Share political news on fb
d4a <- extract.lm_robust(lm_robust(formula = fb_pol_share ~ log(totalfakecount18_pre) + lean_Dem + ideology + polknow + pol_therm_trump + agecat + nonwhite + college, weights = weight, data = (june)), include.ci = F)

d4b <- extract.lm_robust(lm_robust(formula = fb_pol_share ~ totalfakebinary18_pre + lean_Dem + ideology + polknow + pol_therm_trump + agecat + nonwhite + college, weights = weight, data = (june)), include.ci = F)
########################################################################################

#use fb to look at political news
d5a <- extract.lm_robust(lm_robust(formula = fb_pol_use ~ log(totalfakecount18_pre) + lean_Dem + ideology + polknow + pol_therm_trump + agecat + nonwhite + college, weights = weight, data = (june)), include.ci = F)

d5b <- extract.lm_robust(lm_robust(formula = fb_pol_use ~ totalfakebinary18_pre + lean_Dem + ideology + polknow + pol_therm_trump + agecat + nonwhite + college, weights = weight, data = (june)), include.ci = F)

########################################################################################

#Trust in fb
d6a <- extract.lm_robust(lm_robust(formula = fbtrust ~ log(totalfakecount18_pre) + lean_Dem + ideology + polknow + pol_therm_trump + agecat + nonwhite + college, weights = weight, data = (june)), include.ci = F)

d6b <- extract.lm_robust(lm_robust(formula = fbtrust ~ totalfakebinary18_pre + lean_Dem + ideology + polknow + pol_therm_trump + agecat + nonwhite + college, weights = weight, data = (june)), include.ci = F)
########################################################################################

#Average CRT score
d7a <- extract.lm_robust(lm_robust(formula = crt_average ~ log(totalfakecount18_pre) + lean_Dem + ideology + polknow + pol_therm_trump + agecat + nonwhite + college, weights = weight, data = (june)), include.ci = F)

d7b <- extract.lm_robust(lm_robust(formula = crt_average ~ totalfakebinary18_pre + lean_Dem + ideology + polknow + pol_therm_trump + agecat + nonwhite + college, weights = weight, data = (june)), include.ci = F)
########################################## #############################################

#Average consipracy score 
d8a <- extract.lm_robust(lm_robust(formula = conspiracy_mean ~ log(totalfakecount18_pre) + lean_Dem + ideology + polknow + pol_therm_trump + agecat + nonwhite + college, weights = weight, data = (june)), include.ci = F)

d8b <- extract.lm_robust(lm_robust(formula = conspiracy_mean ~ totalfakebinary18_pre + lean_Dem + ideology + polknow + pol_therm_trump + agecat + nonwhite + college, weights = weight, data = (june)), include.ci = F)
########################################################################################
#Accuracy of all news questions
d9a <- extract.lm_robust(lm_robust(formula = topical_accuracy_diff ~ log(totalfakecount18_pre) + lean_Dem + ideology + polknow + pol_therm_trump + agecat + nonwhite + college, weights = weight, data = (june)), include.ci = F)

d9b <- extract.lm_robust(lm_robust(formula = topical_accuracy_diff ~ totalfakebinary18_pre + lean_Dem + ideology + polknow + pol_therm_trump + agecat + nonwhite + college, weights = weight, data = (june)), include.ci = F)

#Separate news questions accuracy
d9c <- extract.lm_robust(lm_robust(formula = mis_pro_d_false ~ log(totalfakecount18_pre) * lean_Dem + ideology + polknow + pol_therm_trump + agecat + nonwhite + college, weights = weight, data = (june)), include.ci = F)

d9d <- extract.lm_robust(lm_robust(formula = mis_pro_d_false ~ totalfakebinary18_pre * lean_Dem + ideology + polknow + pol_therm_trump + agecat + nonwhite + college, weights = weight, data = (june)), include.ci = F)

d9e <- extract.lm_robust(lm_robust(formula = mis_pro_r_false ~ log(totalfakecount18_pre) * lean_Dem + ideology + polknow + pol_therm_trump + agecat + nonwhite + college, weights = weight, data = (june)), include.ci = F)

d9f <- extract.lm_robust(lm_robust(formula = mis_pro_r_false ~ totalfakebinary18_pre * lean_Dem + ideology + polknow + pol_therm_trump + agecat + nonwhite + college, weights = weight, data = (june)), include.ci = F)

d9g <- extract.lm_robust(lm_robust(formula = mis_pro_d_true ~ log(totalfakecount18_pre) * lean_Dem + ideology + polknow + pol_therm_trump + agecat + nonwhite + college, weights = weight, data = (june)), include.ci = F)

d9h <- extract.lm_robust(lm_robust(formula = mis_pro_d_true ~ totalfakebinary18_pre * lean_Dem + ideology + polknow + pol_therm_trump + agecat + nonwhite + college, weights = weight, data = (june)), include.ci = F)

d9i <- extract.lm_robust(lm_robust(formula = mis_pro_r_true ~ log(totalfakecount18_pre) * lean_Dem + ideology + polknow + pol_therm_trump + agecat + nonwhite + college, weights = weight, data = (june)), include.ci = F)

d9j <- extract.lm_robust(lm_robust(formula = mis_pro_r_true ~ totalfakebinary18_pre * lean_Dem + ideology + polknow + pol_therm_trump + agecat + nonwhite + college, weights = weight, data = (june)), include.ci = F)

########################################################################################

colnames(june)
screenreg(list(d1a, d1b, d2a, d2b))
texreg(list(d1a, d1b, d2a, d2b), custom.coef.names =  c('(Intercept)', 'Total Fake Count log', 'Democrat  Leaners', 'Ideology', 'Political Knowledge' ,'Political Thermometer Trump', 'Age 2', 'Age 3', 'Age 4', 'Nonwhite', 'College', 'Total Fake News Binary'))

screenreg(list(d3a, d3b, d4a, d4b))
texreg(list(d3a, d3b, d4a, d4b), custom.coef.names =  c('(Intercept)', 'Total Fake Count log', 'Democrat  Leaners', 'Ideology', 'Political Knowledge' ,'Political Thermometer Trump', 'Age 2', 'Age 3', 'Age 4', 'Nonwhite', 'College', 'Total Fake News Binary'))

screenreg(list(d5a, d5b, d6a, d6b))
texreg(list(d5a, d5b, d6a, d6b), custom.coef.names =  c('(Intercept)', 'Total Fake Count log', 'Democrat  Leaners', 'Ideology', 'Political Knowledge' ,'Political Thermometer Trump', 'Age 2', 'Age 3', 'Age 4', 'Nonwhite', 'College', 'Total Fake News Binary'))

screenreg(list(d7a, d7b, d8a, d8b))
texreg(list(d7a, d7b, d8a, d8b), custom.coef.names =  c('(Intercept)', 'Total Fake Count log', 'Democrat  Leaners', 'Ideology', 'Political Knowledge' ,'Political Thermometer  Trump', 'Age 2', 'Age 3', 'Age 4', 'Nonwhite', 'College', 'Total Fake News Binary'))

screenreg(list(d9a, d9b))
texreg(list(d9a, d9b), custom.coef.names =  c('(Intercept)', 'Total Fake Count log', 'Democrat  Leaners', 'Ideology', 'Political Knowledge' ,'Political Thermometer Trump', 'Age 2', 'Age 3', 'Age 4', 'Nonwhite', 'College', 'Total Fake News Binary'))

screenreg(list(d9c, d9d, d9e, d9f))
texreg(list(d9c, d9d, d9e, d9f), custom.coef.names = c('(Intercept)', 'Total Fake Count log', 'Democrat  Leaners', 'Ideology', 'Political Knowledge', 'Political Thermometer Trump', 'Age 2', 'Age 3', 'Age 4', 'Nonwhite', 'College', 'Total Fake Count log : Democrat Leaners', 'Total Fake News Binary ',' Total Fake News Binary:Democrat Leaners '))

screenreg(list(d9g, d9h, d9i, d9j))
texreg(list(d9g, d9h, d9i, d9j), custom.coef.names = c('(Intercept)', 'Total Fake Count log', 'Democrat  Leaners', 'Ideology', 'Political Knowledge', 'Political Thermometer Trump', 'Age 2', 'Age 3', 'Age 4', 'Nonwhite', 'College', 'Total Fake Count log : Democrat Leaners', 'Total Fake News Binary ', ' Total Fake News Binary:Democrat Leaners '))






oct$totalfakecount18_pre = oct$totalfakecount18_pre + 1
#Political Thermometer
d1a1 <- extract.lm_robust(lm_robust(formula = pol_therm_media ~ log(totalfakecount18_pre) + lean_Dem + ideology + polknow + pol_therm_trump + agecat + nonwhite + college, weights = weight, data = (june)), include.ci = F)


d1b1 <- extract.lm_robust(lm_robust(formula = pol_therm_media ~ totalfakebinary18_pre + lean_Dem + ideology + polknow + pol_therm_trump + agecat + nonwhite + college, weights = weight, data = (oct)), include.ci = F)
########################################################################################


#Trust in Media
d2a1 <- extract.lm_robust(lm_robust(formula = massmedia_trust ~ log(totalfakecount18_pre) + lean_Dem + ideology + polknow + pol_therm_trump + agecat + nonwhite + college, weights = weight, data = (oct)), include.ci = F)

d2b1 <- extract.lm_robust(lm_robust(formula = massmedia_trust ~ totalfakebinary18_pre + lean_Dem + ideology + polknow + pol_therm_trump + agecat + nonwhite + college, weights = weight, data = (oct)), include.ci = F)
########################################################################################

#Affective Polarization
d3a1 <- extract.lm_robust(lm_robust(formula = affect_merged_leanersw1 ~ log(totalfakecount18_pre) + lean_Dem + ideology + polknow + pol_therm_trump + agecat + nonwhite + college, weights = weight, data = (oct)), include.ci = F)

d3b1 <- extract.lm_robust(lm_robust(formula = affect_merged_leanersw1 ~ totalfakebinary18_pre + lean_Dem + ideology + polknow + pol_therm_trump + agecat + nonwhite + college, weights = weight, data = (oct)), include.ci = F)
########################################################################################

#Share political news on fb
d4a1 <- extract.lm_robust(lm_robust(formula = fb_pol_share ~ log(totalfakecount18_pre) + lean_Dem + ideology + polknow + pol_therm_trump + agecat + nonwhite + college, weights = weight, data = (oct)), include.ci = F)
d4b1 <- extract.lm_robust(lm_robust(formula = fb_pol_share ~ totalfakebinary18_pre + lean_Dem + ideology + polknow + pol_therm_trump + agecat + nonwhite + college, weights = weight, data = (oct)), include.ci = F)
########################################################################################

#use fb to look at political news
d5a1 <- extract.lm_robust(lm_robust(formula = fb_pol_use ~ log(totalfakecount18_pre) + lean_Dem + ideology + polknow + pol_therm_trump + agecat + nonwhite + college, weights = weight, data = (oct)), include.ci = F)

d5b1 <- extract.lm_robust(lm_robust(formula = fb_pol_use ~ totalfakebinary18_pre + lean_Dem + ideology + polknow + pol_therm_trump + agecat + nonwhite + college, weights = weight, data = (oct)), include.ci = F)
########################################################################################

#Trust in fb
d6a1 <- extract.lm_robust(lm_robust(formula = fbtrust ~ log(totalfakecount18_pre) + lean_Dem + ideology + polknow + pol_therm_trump + agecat + nonwhite + college, weights = weight, data = (oct)), include.ci = F)

d6b1 <- extract.lm_robust(lm_robust(formula = fbtrust ~ totalfakebinary18_pre + lean_Dem + ideology + polknow + pol_therm_trump + agecat + nonwhite + college, weights = weight, data = (oct)), include.ci = F)
########################################################################################

#Average CRT score
d7a1 <- extract.lm_robust(lm_robust(formula = crt_average ~ log(totalfakecount18_pre) + lean_Dem + ideology + polknow + pol_therm_trump + agecat + nonwhite + college, weights = weight, data = (oct)), include.ci = F)

d7b1 <- extract.lm_robust(lm_robust(formula = crt_average ~ totalfakebinary18_pre + lean_Dem + ideology + polknow + pol_therm_trump + agecat + nonwhite + college, weights = weight, data = (oct)), include.ci = F)
########################################## #############################################

#Average consipracy score 
d8a1 <- extract.lm_robust(lm_robust(formula = conspiracy_mean ~ log(totalfakecount18_pre) + lean_Dem + ideology + polknow + pol_therm_trump + agecat + nonwhite + college, weights = weight, data = (oct)), include.ci = F)


d8b1 <- extract.lm_robust(lm_robust(formula = conspiracy_mean ~ totalfakebinary18_pre + lean_Dem + ideology + polknow + pol_therm_trump + agecat + nonwhite + college, weights = weight, data = (oct)), include.ci = F)
########################################################################################

#Accuracy of all news questions
d9a1 <- extract.lm_robust(lm_robust(formula = topical_accuracy_diff_w2 ~ log(totalfakecount18_pre) + lean_Dem + ideology + polknow + pol_therm_trump + agecat + nonwhite + college, weights = weight, data = (oct)), include.ci = F)


d9b1 <- extract.lm_robust(lm_robust(formula = topical_accuracy_diff_w2 ~ totalfakebinary18_pre + lean_Dem + ideology + polknow + pol_therm_trump + agecat + nonwhite + college, weights = weight, data = (oct)), include.ci = F)


#Separate news questions accuracy
d9c1 <- extract.lm_robust(lm_robust(formula = mis_pro_d_false ~ log(totalfakecount18_pre) * lean_Dem + ideology + polknow + pol_therm_trump + agecat + nonwhite + college, weights = weight, data = (oct)), include.ci = F)

d9d1 <- extract.lm_robust(lm_robust(formula = mis_pro_d_false ~ totalfakebinary18_pre * lean_Dem + ideology + polknow + pol_therm_trump + agecat + nonwhite + college, weights = weight, data = (oct)), include.ci = F)

d9e1 <- extract.lm_robust(lm_robust(formula = mis_pro_r_false ~ log(totalfakecount18_pre) * lean_Dem + ideology + polknow + pol_therm_trump + agecat + nonwhite + college, weights = weight, data = (oct)), include.ci = F)

d9f1 <- extract.lm_robust(lm_robust(formula = mis_pro_r_false ~ totalfakebinary18_pre * lean_Dem + ideology + polknow + pol_therm_trump + agecat + nonwhite + college, weights = weight, data = (oct)), include.ci = F)

d9g1 <- extract.lm_robust(lm_robust(formula = mis_pro_d_true ~ log(totalfakecount18_pre) * lean_Dem + ideology + polknow + pol_therm_trump + agecat + nonwhite + college, weights = weight, data = (oct)), include.ci = F)


d9h1 <- extract.lm_robust(lm_robust(formula = mis_pro_d_true ~ totalfakebinary18_pre * lean_Dem + ideology + polknow + pol_therm_trump + agecat + nonwhite + college, weights = weight, data = (oct)), include.ci = F)

d9i1 <- extract.lm_robust(lm_robust(formula = mis_pro_r_true ~ log(totalfakecount18_pre) * lean_Dem + ideology + polknow + pol_therm_trump + agecat + nonwhite + college, weights = weight, data = (oct)), include.ci = F)


d9j1 <- extract.lm_robust(lm_robust(formula = mis_pro_r_true ~ totalfakebinary18_pre * lean_Dem + ideology + polknow + pol_therm_trump + agecat + nonwhite + college, weights = weight, data = (oct)), include.ci = F)
screenreg(d9j)
########################################################################################
screenreg(list(d1a1, d1b1, d2a1, d2b1))
texreg(list(d1a1, d1b1, d2a1, d2b1), custom.coef.names = c('(Intercept)', 'Total Fake Count log', 'Democrat  Leaners', 'Ideology', 'Political Knowledge' ,'Political Thermometer Trump', 'Age 2', 'Age 3', 'Age 4', 'Nonwhite', 'College', 'Total Fake News Binary'))

screenreg(list(d3a1, d3b1, d4a1, d4b1))
texreg(list(d3a1, d3b1, d4a1, d4b1), custom.coef.names = c('(Intercept)', 'Total Fake Count log', 'Democrat  Leaners', 'Ideology', 'Political Knowledge', 'Political Thermometer Trump', 'Age 2', 'Age 3', 'Age 4', 'Nonwhite', 'College', 'Total Fake News Binary'))

screenreg(list(d5a1, d5b1, d6a1, d6b1))

texreg(list(d5a1, d5b1, d6a1, d6b1), custom.coef.names = c('(Intercept)', 'Total Fake Count log', 'Democrat  Leaners', 'Ideology', 'Political Knowledge', 'Political Thermometer Trump', 'Age 2', 'Age 3', 'Age 4', 'Nonwhite', 'College', 'Total Fake News Binary'))

screenreg(list(d7a1, d7b1, d8a1, d8b1))
texreg(list(d7a1, d7b1, d8a1, d8b1), custom.coef.names = c('(Intercept)', 'Total Fake Count log', 'Democrat  Leaners', 'Ideology', 'Political Knowledge', 'Political Thermometer Trump', 'Age 2', 'Age 3', 'Age 4', 'Nonwhite', 'College', 'Total Fake News Binary'))

screenreg(list(d9a1, d9b1))
texreg(list(d9a1, d9b1), custom.coef.names = c('(Intercept)', 'Total Fake Count log', 'Democrat  Leaners', 'Ideology', 'Political Knowledge' ,'Political Thermometer Trump', 'Age 2', 'Age 3', 'Age 4', 'Nonwhite', 'College', 'Total Fake News Binary'))

screenreg(list(d9c1, d9d1, d9e1, d9f1))
texreg(list(d9c1, d9d1, d9e1, d9f1), custom.coef.names = c('(Intercept)', 'Total Fake Count log', 'Democrat  Leaners', 'Ideology', 'Political Knowledge', 'Political Thermometer Trump', 'Age 2', 'Age 3', 'Age 4', 'Nonwhite', 'College', 'Total Fake Count log : Democrat Leaners', 'Total Fake News Binary ', ' Total Fake News Binary:Democrat Leaners '))

screenreg(list(d9g1, d9h1, d9i1, d9j1))
texreg(list(d9g1, d9h1, d9i1, d9j1), custom.coef.names = c('(Intercept)', 'Total Fake Count log', 'Democrat  Leaners', 'Ideology', 'Political Knowledge', 'Political Thermometer Trump', 'Age 2', 'Age 3', 'Age 4', 'Nonwhite', 'College', 'Total Fake Count log : Democrat Leaners', 'Total Fake News Binary ', ' Total Fake News Binary:Democrat Leaners '))




##################################################################################
#F) Heterogeneous treatment effects 
#RQ - F1 - 4. What effect does counter - attitudinal fake news exposure have on affective polarization(RQ - F1), 
#affect toward the media(RQ - F2),
#intent to vote(RQ - F3), 
#or intent to take political action(RQ - F4) ? 

#We will also conduct exploratory analyses of 
#potential moderators of the effect of pro - attitudinal fake news on 
#affective polarization, intent to vote, or intent to take political action:trust in and feelings toward the media, feelings toward Trump(entered as a linear term and with indicators for terciles or quartiles), conspiracy predispositions, political interest and knowledge, and pre - treatment visits to fake news sites and fact - checking sites. In addition, we will conduct an exploratory analysis of black - white differences in feeling thermometer scores as a moderator of pro - attitudinal fake news exposure effects given that Rep. Maxine Waters, an African American member of Congress, is the target of the fake news stimuli to which participants are randomized in wave 2. As we describe above for wave 1, we will control the false discovery rate with the Benjamini - Hochberg procedure given the risk of false positives. These analyses will be limited to the appendix or supplementary materials, but if any positive findings replicate in futurestudies, we may then use these data and analyses in the main text of a paper.
##################################################################################

#June W2

# Variable for treatment or not
#change the factor so that the control baselin compare# Trump feelings Quartile
june$trump_feel_Quart <- NA
for (i in 1:length(june)) {
    if (june$pol_therm_trump[i] < 25 & is.na(june$pol_therm_trump[i]) == F) {
        june$trump_feel_Quart[i] <- 1
    } else if (june$pol_therm_trump[i] < 50 & june$pol_therm_trump[i] > 24 & is.na(june$pol_therm_trump[i]) == F) {
        june$trump_feel_Quart[i] <- 2
    } else if (june$pol_therm_trump[i] < 75 & june$pol_therm_trump[i] > 49 & is.na(june$pol_therm_trump[i]) == F) {
        june$trump_feel_Quart[i] <- 3
    } else if (june$pol_therm_trump[i] <= 100 & june$pol_therm_trump[i] > 74 & is.na(june$pol_therm_trump[i]) == F) {
        june$trump_feel_Quart[i] <- 4
    }
}
june$trump_feel_Quart <- as.factor(june$trump_feel_Quart)

table(june$trump_feel_Quart)
##################################################################################

#Feelings thermometer media
mediathermFit1 <- extract.lm_robust(lm_robust(pol_therm_media_w2 ~ as.factor(congenial_fn) * conspiracy_mean + as.factor(uncongenial_fn) * conspiracy_mean, data = subset(june, june$independents == 0)), include.ci = F)

mediathermFit2 <- extract.lm_robust(lm_robust(pol_therm_media_w2 ~ as.factor(congenial_fn) * polknow + as.factor(uncongenial_fn) * polknow, data = subset(june, june$independents == 0)), include.ci = F)

mediathermFit3 <- extract.lm_robust(lm_robust(pol_therm_media_w2 ~ as.factor(congenial_fn) * pol_interest + as.factor(uncongenial_fn) * pol_interest, data = subset(june, june$independents == 0)), include.ci = F)

mediathermFit4 <- extract.lm_robust(lm_robust(pol_therm_media_w2 ~ as.factor(congenial_fn) * totalfakenewscount_pre + as.factor(uncongenial_fn) * totalfakenewscount_pre, data = subset(june, june$independents == 0)), include.ci = F)

mediathermFit5 <- extract.lm_robust(lm_robust(pol_therm_media_w2 ~ as.factor(congenial_fn) * massmedia_trustw2 + as.factor(uncongenial_fn) * massmedia_trustw2, data = subset(june, june$independents == 0)), include.ci = F)

mediathermFit6 <- extract.lm_robust(lm_robust(pol_therm_media_w2 ~ as.factor(congenial_fn) * pol_therm_trump_w2 + as.factor(uncongenial_fn) * pol_therm_trump_w2, data = subset(june, june$independents == 0)), include.ci = F)

mediathermFit7 <- extract.lm_robust(lm_robust(pol_therm_media_w2 ~ as.factor(congenial_fn) * trump_feel_Quart + as.factor(uncongenial_fn) * trump_feel_Quart, data = subset(june, june$independents == 0)), include.ci = F)




screenreg(list(mediathermFit1, mediathermFit2, mediathermFit3, mediathermFit4))
texreg(list(mediathermFit1, mediathermFit2, mediathermFit3, mediathermFit4))

texreg(list(mediathermFit5, mediathermFit6, mediathermFit7), include.ci = F)
##################################################################################



#Media trust

mediatrustFit1 <- extract.lm_robust(lm_robust(massmedia_trustw2 ~ as.factor(congenial_fn) * conspiracy_mean + as.factor(uncongenial_fn) * conspiracy_mean, data = subset(june, june$independents == 0)), include.ci = F)
mediatrustFit2 <- extract.lm_robust(lm_robust(massmedia_trustw2 ~ as.factor(congenial_fn) * polknow + as.factor(uncongenial_fn) * polknow, data = subset(june, june$independents == 0)), include.ci = F)
mediatrustFit3 <- extract.lm_robust(lm_robust(massmedia_trustw2 ~ as.factor(congenial_fn) * pol_interest + as.factor(uncongenial_fn) * pol_interest, data = subset(june, june$independents == 0)), include.ci = F)
mediatrustFit4 <- extract.lm_robust(lm_robust(massmedia_trustw2 ~ as.factor(congenial_fn) * totalfakenewscount_pre + as.factor(uncongenial_fn) * totalfakenewscount_pre, data = subset(june, june$independents == 0)), include.ci = F)
mediatrustFit5 <- extract.lm_robust(lm_robust(massmedia_trustw2 ~ as.factor(congenial_fn) * pol_therm_media_w2 + as.factor(uncongenial_fn) * pol_therm_media_w2, data = subset(june, june$independents == 0)), include.ci = F)
mediatrustFit6 <- extract.lm_robust(lm_robust(massmedia_trustw2 ~ as.factor(congenial_fn) * pol_therm_trump_w2 + as.factor(uncongenial_fn) * pol_therm_trump_w2, data = subset(june, june$independents == 0)), include.ci = F)
mediatrustFit7 <- extract.lm_robust(lm_robust(massmedia_trustw2 ~ as.factor(congenial_fn) * trump_feel_Quart + as.factor(uncongenial_fn) * trump_feel_Quart, data = subset(june, june$independents == 0)), include.ci = F)

texreg(list(mediatrustFit1, mediatrustFit2, mediatrustFit3, mediatrustFit4), include.ci=F)

texreg(list(mediatrustFit5, mediatrustFit6, mediatrustFit7), include.ci = F)
##################################################################################

#Affective Polarization
polarFit1 <- extract.lm_robust(lm_robust(affect_merged_leaners ~ congenial_fn * conspiracy_mean, data = subset(june, june$independents == 0)), include.ci = F)
polarFit2 <- extract.lm_robust(lm_robust(affect_merged_leaners ~ congenial_fn * polknow, data = subset(june, june$independents == 0)), include.ci = F)
polarFit3 <- extract.lm_robust(lm_robust(affect_merged_leaners ~ congenial_fn * pol_interest, data = subset(june, june$independents == 0)), include.ci = F)
polarFit4 <- extract.lm_robust(lm_robust(affect_merged_leaners ~ congenial_fn * totalfakenewscount_pre, data = subset(june, june$independents == 0)), include.ci = F)
polarFit5 <- extract.lm_robust(lm_robust(affect_merged_leaners ~ congenial_fn * massmedia_trustw2, data = subset(june, june$independents == 0)), include.ci = F)
polarFit6 <- extract.lm_robust(lm_robust(affect_merged_leaners ~ congenial_fn * pol_therm_media_w2, data = subset(june, june$independents == 0)), include.ci = F)
polarFit7 <- extract.lm_robust(lm_robust(affect_merged_leaners ~ congenial_fn * pol_therm_trump_w2, data = subset(june, june$independents == 0)), include.ci = F)
polarFit8 <- extract.lm_robust(lm_robust(affect_merged_leaners ~ congenial_fn * trump_feel_Quart, data = subset(june, june$independents == 0)), include.ci = F)


texreg(list(polarFit1, polarFit2, polarFit3, polarFit4), include.ci = F)
texreg(list(polarFit5, polarFit6, polarFit7, polarFit8), include.ci = F)
##################################################################################

#Plans to vote
planvoteFit <- extract.lm_robust(lm_robust(plan_vote_w2 ~ congenial_fn, data = subset(june, june$independents == 0)), include.ci = F)

planvoteFit1 <- extract.lm_robust(lm_robust(plan_vote_w2 ~ congenial_fn * conspiracy_mean, data = subset(june, june$independents == 0)), include.ci = F)
planvoteFit2 <- extract.lm_robust(lm_robust(plan_vote_w2 ~ congenial_fn * polknow, data = subset(june, june$independents == 0)), include.ci = F)
planvoteFit3 <- extract.lm_robust(lm_robust(plan_vote_w2 ~ congenial_fn * pol_interest, data = subset(june, june$independents == 0)), include.ci = F)
planvoteFit4 <- extract.lm_robust(lm_robust(plan_vote_w2 ~ congenial_fn * totalfakenewscount_pre, data = subset(june, june$independents == 0)), include.ci = F)
planvoteFit5 <- extract.lm_robust(lm_robust(plan_vote_w2 ~ congenial_fn * massmedia_trustw2, data = subset(june, june$independents == 0)), include.ci = F)
planvoteFit6 <- extract.lm_robust(lm_robust(plan_vote_w2 ~ congenial_fn * pol_therm_media_w2, data = subset(june, june$independents == 0)), include.ci = F)
planvoteFit7 <- extract.lm_robust(lm_robust(plan_vote_w2 ~ congenial_fn * pol_therm_trump_w2, data = subset(june, june$independents == 0)), include.ci = F)
planvoteFit8 <- extract.lm_robust(lm_robust(plan_vote_w2 ~ congenial_fn * trump_feel_Quart, data = subset(june, june$independents == 0)), include.ci = F)


texreg(list(planvoteFit1, planvoteFit2, planvoteFit3, planvoteFit4), include.ci = F)

texreg(list(planvoteFit5, planvoteFit6, planvoteFit7, planvoteFit8), include.ci = F)

##################################################################################


#Political action
polactFit1 <- extract.lm_robust(lm_robust(polact_mean ~ congenial_fn * conspiracy_mean, data = subset(june, june$independents == 0)), include.ci = F)
polactFit2 <- extract.lm_robust(lm_robust(polact_mean ~ congenial_fn * polknow, data = subset(june, june$independents == 0)), include.ci = F)
polactFit3 <- extract.lm_robust(lm_robust(polact_mean ~ congenial_fn * pol_interest, data = subset(june, june$independents == 0)), include.ci = F)
polactFit4 <- extract.lm_robust(lm_robust(polact_mean ~ congenial_fn * totalfakenewscount_pre, data = subset(june, june$independents == 0)), include.ci = F)
polactFit5 <- extract.lm_robust(lm_robust(polact_mean ~ congenial_fn * massmedia_trustw2, data = subset(june, june$independents == 0)), include.ci = F)
polactFit6 <- extract.lm_robust(lm_robust(polact_mean ~ congenial_fn * pol_therm_media_w2, data = subset(june, june$independents == 0)), include.ci = F)
polactFit7 <- extract.lm_robust(lm_robust(polact_mean ~ congenial_fn * pol_therm_trump_w2, data = subset(june, june$independents == 0)), include.ci = F)
polactFit8 <- extract.lm_robust(lm_robust(polact_mean ~ congenial_fn * trump_feel_Quart, data = subset(june, june$independents == 0)), include.ci = F)


texreg(list(polactFit1, polactFit2, polactFit3, polactFit4), include.ci = F)

texreg(list(polactFit5, polactFit6, polactFit7, polactFit8), include.ci = F)


#District vote

# Convert to factor to for lm_robust
june$district_vote_lean_w2 <- as.character(june$district_vote_lean_w2)
june$district_vote_lean_w2[june$district_vote_lean_w2 == "Republican Party's candidate"] <- 0
june$district_vote_lean_w2[june$district_vote_lean_w2 == "Democratic Party's candidate"] <- 1
june$district_vote_lean_w2[june$district_vote_lean_w2 == "Don't know" ] <- NA
june$district_vote_lean_w2[june$district_vote_lean_w2 == "skipped"] <- NA
june$district_vote_lean_w2[june$district_vote_lean_w2 == "not asked"] <- NA

june$district_vote_lean_w2 <- as.numeric(june$district_vote_lean_w2)


distvoteFit1 <- extract.lm_robust(lm_robust(district_vote_lean_w2 ~ congenial_fn * conspiracy_mean, data = subset(june, june$independents == 0)), include.ci = F)
distvoteFit2 <- extract.lm_robust(lm_robust(district_vote_lean_w2 ~ congenial_fn * polknow, data = subset(june, june$independents == 0)), include.ci = F)
distvoteFit3 <- extract.lm_robust(lm_robust(district_vote_lean_w2 ~ congenial_fn * pol_interest, data = subset(june, june$independents == 0)), include.ci = F)
distvoteFit4 <- extract.lm_robust(lm_robust(district_vote_lean_w2 ~ congenial_fn * totalfakenewscount_pre, data = subset(june, june$independents == 0)), include.ci = F)
distvoteFit5 <- extract.lm_robust(lm_robust(district_vote_lean_w2 ~ congenial_fn * massmedia_trustw2, data = subset(june, june$independents == 0)), include.ci = F)
distvoteFit6 <- extract.lm_robust(lm_robust(district_vote_lean_w2 ~ congenial_fn * pol_therm_media_w2, data = subset(june, june$independents == 0)), include.ci = F)
distvoteFit7 <- extract.lm_robust(lm_robust(district_vote_lean_w2 ~ congenial_fn * pol_therm_trump_w2, data = subset(june, june$independents == 0)), include.ci = F)
distvoteFit8 <- extract.lm_robust(lm_robust(district_vote_lean_w2 ~ congenial_fn * trump_feel_Quart, data = subset(june, june$independents == 0)), include.ci =F)

texreg(list(distvoteFit1, distvoteFit2, distvoteFit3, distvoteFit4), include.ci = F)

texreg(list(distvoteFit5, distvoteFit6, distvoteFit7, distvoteFit8), include.ci = F)


# make a new variable that is the difference between affects between feelings black - feelings white higher values == more racists; subset down to control and maxine waters treatment proR and control. Interact subseted values with new feelings. For all three dv affective pol. intent to vote. political action. 

#racial animous
june$feelDiff <- june$FT_white - june$FT_black

# I wrote down 'with new feelings above' and don't know what feelings I ought to be 


planvoteMax <- extract.lm_robust(lm_robust(plan_vote_w2 ~ feelDiff * as.factor(article_treat_w2), data = subset(june, june$independents == 0 & june$article_treat_w2 != 1)), include.ci = F)

polarMax <- extract.lm_robust(lm_robust(affect_merged_leaners ~ feelDiff * as.factor(article_treat_w2), data = subset(june, june$independents == 0 & june$article_treat_w2 != 1)), include.ci = F)

polactMax <- extract.lm_robust(lm_robust(polact_mean ~ feelDiff * as.factor(article_treat_w2), data = subset(june, june$independents == 0 & june$article_treat_w2 != 1)), include.ci = F)

texreg(list(planvoteMax, polarMax, polactMax), include.ci = F)


















#October W2

# Variable for treatment or not
#change the factor so that the control baselin compare# Trump feelings Quartile
oct$trump_feel_Quart <- NA
for (i in 1:length(oct)) {
    if (oct$pol_therm_trump[i] < 25 & is.na(oct$pol_therm_trump[i]) == F) {
        oct$trump_feel_Quart[i] <- 1
    } else if (oct$pol_therm_trump[i] < 50 & oct$pol_therm_trump[i] > 24 & is.na(oct$pol_therm_trump[i]) == F) {
        oct$trump_feel_Quart[i] <- 2
    } else if (oct$pol_therm_trump[i] < 75 & oct$pol_therm_trump[i] > 49 & is.na(oct$pol_therm_trump[i]) == F) {
        oct$trump_feel_Quart[i] <- 3
    } else if (oct$pol_therm_trump[i] <= 100 & oct$pol_therm_trump[i] > 74 & is.na(oct$pol_therm_trump[i]) == F) {
        oct$trump_feel_Quart[i] <- 4
    }
}
oct$trump_feel_Quart <- as.factor(oct$trump_feel_Quart)

table(oct$trump_feel_Quart)
##################################################################################

#Feelings thermometer media
mediathermFit11 <- extract.lm_robust(lm_robust(pol_therm_media_w2 ~ congenial_fn * conspiracy_mean, data = subset(oct, oct$independents == 0)), include.ci = F)

mediathermFit21 <- extract.lm_robust(lm_robust(pol_therm_media_w2 ~ congenial_fn * polknow, data = subset(oct, oct$independents == 0)), include.ci = F)

mediathermFit31 <- extract.lm_robust(lm_robust(pol_therm_media_w2 ~ congenial_fn * pol_interest, data = subset(oct, oct$independents == 0)), include.ci = F)

mediathermFit41 <- extract.lm_robust(lm_robust(pol_therm_media_w2 ~ congenial_fn * totalfakenewscount_pre, data = subset(oct, oct$independents == 0)), include.ci = F)

mediathermFit51 <- extract.lm_robust(lm_robust(pol_therm_media_w2 ~ congenial_fn * massmedia_trustw2, data = subset(oct, oct$independents == 0)), include.ci = F)

mediathermFit61 <- extract.lm_robust(lm_robust(pol_therm_media_w2 ~ congenial_fn * pol_therm_trump_w2, data = subset(oct, oct$independents == 0)), include.ci = F)

mediathermFit71 <- extract.lm_robust(lm_robust(pol_therm_media_w2 ~ congenial_fn * trump_feel_Quart, data = subset(oct, oct$independents == 0)), include.ci = F)




screenreg(list(mediathermFit11, mediathermFit21, mediathermFit31, mediathermFit41))


texreg(list(mediathermFit11, mediathermFit21, mediathermFit31, mediathermFit41), custom.coef.names = c('(Intercept)', 'Congeniality', 'Conspiracy Average', 'Congenial : Conspiracy', 'Political Knowledge', 'Congenial : Political Knowledge', 'Political Interest - Very', 'Political Interest - Somewhat', 'Political Interest - Not Very', 'Political Interest -Not at All', 'Congenial : Political Interest - Very', 'Congenial : Political Interest - Somewhat', ' Congenial : Political Interest - Not Very', 'Congenial :  Political Interest -Not at All', 'Total Fake News Count', 'Congenial : Total Fake News Count'))

texreg(list(mediathermFit51, mediathermFit61, mediathermFit71), include.ci = F)
##################################################################################



#Media trust

mediatrustFit11 <- extract.lm_robust(lm_robust(massmedia_trustw2 ~ congenial_fn * conspiracy_mean, data = subset(oct, oct$independents == 0)), include.ci = F)

mediatrustFit21 <- extract.lm_robust(lm_robust(massmedia_trustw2 ~ congenial_fn * polknow, data = subset(oct, oct$independents == 0)), include.ci = F)

mediatrustFit31 <- extract.lm_robust(lm_robust(massmedia_trustw2 ~ congenial_fn * pol_interest, data = subset(oct, oct$independents == 0)), include.ci = F)

mediatrustFit41 <- extract.lm_robust(lm_robust(massmedia_trustw2 ~ congenial_fn * totalfakenewscount_pre, data = subset(oct, oct$independents == 0)), include.ci = F)

mediatrustFit51 <- extract.lm_robust(lm_robust(massmedia_trustw2 ~ congenial_fn * pol_therm_media_w2, data = subset(oct, oct$independents == 0)), include.ci = F)

mediatrustFit61 <- extract.lm_robust(lm_robust(massmedia_trustw2 ~ congenial_fn * pol_therm_trump_w2, data = subset(oct, oct$independents == 0)), include.ci = F)

mediatrustFit71 <- extract.lm_robust(lm_robust(massmedia_trustw2 ~ congenial_fn * trump_feel_Quart, data = subset(oct, oct$independents == 0)), include.ci = F)

texreg(list(mediatrustFit11, mediatrustFit21, mediatrustFit31, mediatrustFit41), include.ci = F)

texreg(list(mediatrustFit51, mediatrustFit61, mediatrustFit71), include.ci = F)
##################################################################################

#Affective Polarization
polarFit11 <- extract.lm_robust(lm_robust(affect_merged_leaners ~ congenial_fn * conspiracy_mean, data = subset(oct, oct$independents == 0)), include.ci = F)

polarFit21 <- extract.lm_robust(lm_robust(affect_merged_leaners ~ congenial_fn * polknow, data = subset(oct, oct$independents == 0)), include.ci = F)

polarFit31 <- extract.lm_robust(lm_robust(affect_merged_leaners ~ congenial_fn * pol_interest, data = subset(oct, oct$independents == 0)), include.ci = F)

polarFit41 <- extract.lm_robust(lm_robust(affect_merged_leaners ~ congenial_fn * totalfakenewscount_pre, data = subset(oct, oct$independents == 0)), include.ci = F)

polarFit51 <- extract.lm_robust(lm_robust(affect_merged_leaners ~ congenial_fn * massmedia_trustw2, data = subset(oct, oct$independents == 0)), include.ci = F)

polarFit61 <- extract.lm_robust(lm_robust(affect_merged_leaners ~ congenial_fn * pol_therm_media_w2, data = subset(oct, oct$independents == 0)), include.ci = F)

polarFit71 <- extract.lm_robust(lm_robust(affect_merged_leaners ~ congenial_fn * pol_therm_trump_w2, data = subset(oct, oct$independents == 0)), include.ci = F)

polarFit81 <- extract.lm_robust(lm_robust(affect_merged_leaners ~ congenial_fn * trump_feel_Quart, data = subset(oct, oct$independents == 0)), include.ci = F)


texreg(list(polarFit11, polarFit21, polarFit31, polarFit41), include.ci = F)
texreg(list(polarFit51, polarFit61, polarFit71, polarFit81), include.ci = F)
##################################################################################

#Plans to vote

planvoteFit11 <- extract.lm_robust(lm_robust(plan_vote_w2 ~ congenial_fn * conspiracy_mean, data = subset(oct, oct$independents == 0)), include.ci = F)

planvoteFit21 <- extract.lm_robust(lm_robust(plan_vote_w2 ~ congenial_fn * polknow, data = subset(oct, oct$independents == 0)), include.ci = F)

planvoteFit31 <- extract.lm_robust(lm_robust(plan_vote_w2 ~ congenial_fn * pol_interest, data = subset(oct, oct$independents == 0)), include.ci = F)

planvoteFit41 <- extract.lm_robust(lm_robust(plan_vote_w2 ~ congenial_fn * totalfakenewscount_pre, data = subset(oct, oct$independents == 0)), include.ci = F)

planvoteFit51 <- extract.lm_robust(lm_robust(plan_vote_w2 ~ congenial_fn * massmedia_trustw2, data = subset(oct, oct$independents == 0)), include.ci = F)

planvoteFit61 <- extract.lm_robust(lm_robust(plan_vote_w2 ~ congenial_fn * pol_therm_media_w2, data = subset(oct, oct$independents == 0)), include.ci = F)

planvoteFit71 <- extract.lm_robust(lm_robust(plan_vote_w2 ~ congenial_fn * pol_therm_trump_w2, data = subset(oct, oct$independents == 0)), include.ci = F)

planvoteFit81 <- extract.lm_robust(lm_robust(plan_vote_w2 ~ congenial_fn * trump_feel_Quart, data = subset(oct, oct$independents == 0)), include.ci = F)


texreg(list(planvoteFit11, planvoteFit21, planvoteFit31, planvoteFit41), include.ci = F)

texreg(list(planvoteFit51, planvoteFit61, planvoteFit71, planvoteFit81), include.ci = F)

##################################################################################


#Political action
polactFit11 <- extract.lm_robust(lm_robust(polact_mean ~ congenial_fn * conspiracy_mean, data = subset(oct, oct$independents == 0)), include.ci = F)

polactFit21 <- extract.lm_robust(lm_robust(polact_mean ~ congenial_fn * polknow, data = subset(oct, oct$independents == 0)), include.ci = F)

polactFit31 <- extract.lm_robust(lm_robust(polact_mean ~ congenial_fn * pol_interest, data = subset(oct, oct$independents == 0)), include.ci = F)

polactFit41 <- extract.lm_robust(lm_robust(polact_mean ~ congenial_fn * totalfakenewscount_pre, data = subset(oct, oct$independents == 0)), include.ci = F)

polactFit51 <- extract.lm_robust(lm_robust(polact_mean ~ congenial_fn * massmedia_trustw2, data = subset(oct, oct$independents == 0)), include.ci = F)

polactFit61 <- extract.lm_robust(lm_robust(polact_mean ~ congenial_fn * pol_therm_media_w2, data = subset(oct, oct$independents == 0)), include.ci = F)

polactFit71 <- extract.lm_robust(lm_robust(polact_mean ~ congenial_fn * pol_therm_trump_w2, data = subset(oct, oct$independents == 0)), include.ci = F)

polactFit81 <- extract.lm_robust(lm_robust(polact_mean ~ congenial_fn * trump_feel_Quart, data = subset(oct, oct$independents == 0)), include.ci = F)


texreg(list(polactFit11, polactFit21, polactFit31, polactFit41), include.ci = F)

texreg(list(polactFit51, polactFit61, polactFit71, polactFit81), include.ci = F)


#District vote

# Convert to factor to for lm_robust
oct$district_vote_lean_w2 <- as.character(oct$district_vote_lean_w2)
oct$district_vote_lean_w2[oct$district_vote_lean_w2 == "Republican Party's candidate"] <- 0
oct$district_vote_lean_w2[oct$district_vote_lean_w2 == "Democratic Party's candidate"] <- 1
oct$district_vote_lean_w2[oct$district_vote_lean_w2 == "Don't know"] <- NA
oct$district_vote_lean_w2[oct$district_vote_lean_w2 == "skipped"] <- NA
oct$district_vote_lean_w2[oct$district_vote_lean_w2 == "not asked"] <- NA

oct$district_vote_lean_w2 <- as.numeric(oct$district_vote_lean_w2)

distvoteFit11 <- extract.lm_robust(lm_robust(district_vote_lean_w2 ~ congenial_fn * conspiracy_mean, data = subset(oct, oct$independents == 0)), include.ci = F)

distvoteFit21 <- extract.lm_robust(lm_robust(district_vote_lean_w2 ~ congenial_fn * polknow, data = subset(oct, oct$independents == 0)), include.ci = F)

distvoteFit31 <- extract.lm_robust(lm_robust(district_vote_lean_w2 ~ congenial_fn * pol_interest, data = subset(oct, oct$independents == 0)), include.ci = F)

distvoteFit41 <- extract.lm_robust(lm_robust(district_vote_lean_w2 ~ congenial_fn * totalfakenewscount_pre, data = subset(oct, oct$independents == 0)), include.ci = F)

distvoteFit51 <- extract.lm_robust(lm_robust(district_vote_lean_w2 ~ congenial_fn * massmedia_trustw2, data = subset(oct, oct$independents == 0)), include.ci = F)

distvoteFit61 <- extract.lm_robust(lm_robust(district_vote_lean_w2 ~ congenial_fn * pol_therm_media_w2, data = subset(oct, oct$independents == 0)), include.ci = F)

distvoteFit71 <- extract.lm_robust(lm_robust(district_vote_lean_w2 ~ congenial_fn * pol_therm_trump_w2, data = subset(oct, oct$independents == 0)), include.ci = F)

distvoteFit81 <- extract.lm_robust(lm_robust(district_vote_lean_w2 ~ congenial_fn * trump_feel_Quart, data = subset(oct, oct$independents == 0)), include.ci = F)

texreg(list(distvoteFit11, distvoteFit21, distvoteFit31, distvoteFit41), include.ci = F)

texreg(list(distvoteFit51, distvoteFit61, distvoteFit71), include.ci = F)

###################################################
#Focused work

#Percieved Accuracy of and Likelihood to share experimental FN articles
# [Construction of Variables are down below in script] JUNE W2



june$Perceived_Accuracy <- NA
for (i in 1:nrow(june)) {
    if (is.na(june$article_accuracy_w2R[i]) == F) {
        june$Perceived_Accuracy[i] <- june$article_accuracy_w2R[i]
    }
}
for (i in 1:nrow(june)) {
    if (is.na(june$article_accuracy_w2D[i]) == F) {
        june$Perceived_Accuracy[i] <- june$article_accuracy_w2D[i]
    }
}
for (i in 1:nrow(june)) {
    if (is.na(june$article_accuracy_w2[i]) == F) {
        june$Perceived_Accuracy[i] <- june$article_accuracy_w2[i]
    }
}



june$Likelihood_Share <- NA
for (i in 1:nrow(june)) {
    if (is.na(june$article_share_w2R[i]) == F) {
        june$Likelihood_Share[i] <- june$article_share_w2R[i]
    }
}
for (i in 1:nrow(june)) {
    if (is.na(june$article_share_w2D[i]) == F) {
        june$Likelihood_Share[i] <- june$article_share_w2D[i]
    }
}
for (i in 1:nrow(june)) {
    if (is.na(june$article_share_w2[i]) == F) {
        june$Likelihood_Share[i] <- june$article_share_w2[i]
    }
}

#confirm new variable is correct
(sum(is.na(june$article_accuracy_w2R) == F) + sum(is.na(june$article_accuracy_w2D) == F) + sum(is.na(june$article_accuracy_w2) == F)) == (sum(is.na(june$Perceived_Accuracy) == F))


(sum(is.na(june$article_share_w2R) == F) + sum(is.na(june$article_share_w2D) == F) + sum(is.na(june$article_share_w2) == F)) == (sum(is.na(june$Likelihood_Share) == F))




###########################################################
#Percieved Accuracy of and Likelihood to share experimental FN articles


oct$article_accuracy_w2R[361:369]
oct$XP_acc[361:369]

oct$Perceived_Accuracy <- NA
for (i in 1:nrow(oct)) {
    if (is.na(oct$article_accuracy_w2R[i]) == F) {
        oct$Perceived_Accuracy[i] <- oct$article_accuracy_w2R[i]
    }
}
for (i in 1:nrow(oct)) {
    if (is.na(oct$article_accuracy_w2D[i]) == F) {
        oct$Perceived_Accuracy[i] <- oct$article_accuracy_w2D[i]
    }
}
for (i in 1:nrow(oct)) {
    if (is.na(oct$article_accuracy_w2[i]) == F) {
        oct$Perceived_Accuracy[i] <- oct$article_accuracy_w2[i]
    }
}





oct$Likelihood_Share <- NA
for (i in 1:nrow(oct)) {
    if (is.na(oct$article_share_w2R[i]) == F) {
        oct$Likelihood_Share[i] <- oct$article_share_w2R[i]
    }
}
for (i in 1:nrow(oct)) {
    if (is.na(oct$article_share_w2D[i]) == F) {
        oct$Likelihood_Share[i] <- oct$article_share_w2D[i]
    }
}
for (i in 1:nrow(oct)) {
    if (is.na(oct$article_share_w2[i]) == F) {
        oct$Likelihood_Share[i] <- oct$article_share_w2[i]
    }
}



# Convert factor to numeric for lm_robust
oct$misinform_soros_w2 <- as.character(oct$misinform_soros_w2)
oct$misinform_soros_w2[oct$misinform_soros_w2 == 'Not at all accurate'] <- 1
oct$misinform_soros_w2[oct$misinform_soros_w2 == 'Not very accurate'] <- 2
oct$misinform_soros_w2[oct$misinform_soros_w2 == 'Somewhat accurate'] <- 3
oct$misinform_soros_w2[oct$misinform_soros_w2 == 'Very accurate'] <- 4
oct$misinform_soros_w2[oct$misinform_soros_w2 == 'not asked'] <- NA
oct$misinform_soros_w2[oct$misinform_soros_w2 == 'skipped'] <- NA

oct$misinform_soros_w2 <- as.numeric(oct$misinform_soros_w2)

# Convert factor to numeric for lm_robust
oct$misinform_jamal_w2 <- as.character(oct$misinform_jamal_w2)
oct$misinform_jamal_w2[oct$misinform_jamal_w2 == 'Not at all accurate'] <- 1
oct$misinform_jamal_w2[oct$misinform_jamal_w2 == 'Not very accurate'] <- 2
oct$misinform_jamal_w2[oct$misinform_jamal_w2 == 'Somewhat accurate'] <- 3
oct$misinform_jamal_w2[oct$misinform_jamal_w2 == 'Very accurate'] <- 4
oct$misinform_jamal_w2[oct$misinform_jamal_w2 == 'not asked'] <- NA
oct$misinform_jamal_w2[oct$misinform_jamal_w2 == 'skipped'] <- NA

oct$misinform_jamal_w2 <- as.numeric(oct$misinform_jamal_w2)



(sum(is.na(oct$article_accuracy_w2R) == F) + sum(is.na(oct$article_accuracy_w2D) == F) + sum(is.na(oct$article_accuracy_w2) == F)) == (sum(is.na(oct$Perceived_Accuracy) == F))


(sum(is.na(oct$article_share_w2R) == F) + sum(is.na(oct$article_share_w2D) == F) + sum(is.na(oct$article_share_w2) == F)) == (sum(is.na(oct$Likelihood_Share) == F))

XPm1 <- extract.lm_robust(lm_robust(Perceived_Accuracy ~ (proD_fake * lean_Dem) + (proR_fake * lean_Dem) + ideology + nonwhite + polknow + agecat + college + pol_therm_trump, june), include.ci = F)



XPm2 <- extract.lm_robust(lm_robust(Likelihood_Share ~ (proD_fake * lean_Dem) + (proR_fake * lean_Dem) + +ideology + nonwhite + polknow + agecat + college + pol_therm_trump, june), include.ci = F)


XPm3 <- extract.lm_robust(lm_robust(misinform_soros_w2 ~ proD_fake * lean_Dem + proR_fake * lean_Dem + +ideology + nonwhite + polknow + agecat + college + pol_therm_trump, data = oct), include.ci = F)


XPm4 <- extract.lm_robust(lm_robust(misinform_jamal_w2 ~ proD_fake * lean_Dem + (proR_fake * lean_Dem) + ideology + nonwhite + polknow + agecat + college + pol_therm_trump, data = oct), include.ci = F)







screenreg(list(XPm1, XPm2))

BottleRocket1
texreg(list(XPm1, XPm2), custom.coef.names = c('(Intercept)', 'ProD_Fake', 'Democrat Leaners', 'ProR_Fake', 'Ideology', 'Nonwhite', 'Political Knowledge', 'Age 2', 'Age 3', 'Age 4', 'College', 'Political Thermometer Trump', 'ProD_Fake : Democrat Leaners', 'ProR_Fake : Democrat Leaners'))

screenreg(list(XPm3, XPm4))
texreg(list(XPm3, XPm4), custom.coef.names = c('(Intercept)', 'ProD_Fake', 'Democrat Leaners', 'ProR_Fake', 'Ideology', 'Nonwhite', 'Political Knowledge', 'Age 2', 'Age 3', 'Age 4', 'College', 'Political Thermometer Trump', 'ProD_Fake : Democrat Leaners', 'ProR_Fake : Democrat Leaners'))




massmediaFit <- extract.lm_robust(lm_robust(massmedia_trustw2 ~ (proD_fake * lean_Dem) + (proR_fake * lean_Dem) + ideology + nonwhite + polknow + agecat + college + pol_therm_trump, june), include.ci = F)

polarFit <- extract.lm_robust(lm_robust(affect_merged_leaners ~ (proD_fake * lean_Dem) + (proR_fake * lean_Dem) + ideology + nonwhite + polknow + agecat + college + pol_therm_trump, june), include.ci = F)

pol_thermFit <- extract.lm_robust(lm_robust(pol_therm_media_w2 ~ (proD_fake * lean_Dem) + (proR_fake * lean_Dem) + +ideology + nonwhite + polknow + agecat + college + pol_therm_trump, june), include.ci = F)

voteFit <- extract.lm_robust(lm_robust(plan_vote_w2 ~ proD_fake * lean_Dem + proR_fake * lean_Dem + +ideology + nonwhite + polknow + agecat + college + pol_therm_trump, data = june), include.ci = F)


polactFit <- extract.lm_robust(lm_robust(polact_mean ~ proD_fake * lean_Dem + (proR_fake * lean_Dem) + ideology + nonwhite + polknow + agecat + college + pol_therm_trump, data = june), include.ci = F)




massmediaFit1 <- extract.lm_robust(lm_robust(massmedia_trustw2 ~ (proD_fake * lean_Dem) + (proR_fake * lean_Dem) + ideology + nonwhite + polknow + agecat + college + pol_therm_trump, oct), include.ci = F)

polarFit1 <- extract.lm_robust(lm_robust(affect_merged_leaners ~ (proD_fake * lean_Dem) + (proR_fake * lean_Dem) + ideology + nonwhite + polknow + agecat + college + pol_therm_trump, oct), include.ci = F)

pol_thermFit1 <- extract.lm_robust(lm_robust(pol_therm_media_w2 ~ (proD_fake * lean_Dem) + (proR_fake * lean_Dem) + +ideology + nonwhite + polknow + agecat + college + pol_therm_trump, oct), include.ci = F)

voteFit1 <- extract.lm_robust(lm_robust(plan_vote_w2 ~ proD_fake * lean_Dem + proR_fake * lean_Dem + +ideology + nonwhite + polknow + agecat + college + pol_therm_trump, data = oct), include.ci = F)


polactFit1 <- extract.lm_robust(lm_robust(polact_mean ~ proD_fake * lean_Dem + (proR_fake * lean_Dem) + ideology + nonwhite + polknow + agecat + college + pol_therm_trump, data = oct), include.ci=F)



screenreg(list(massmediaFit, pol_thermFit, voteFit, polactFit))
texreg(list(massmediaFit, pol_thermFit, voteFit, polactFit), custom.coef.names = c('(Intercept)', 'ProD_Fake', 'Democrat Leaners', 'ProR_Fake', 'Ideology', 'Nonwhite', 'Political Knowledge', 'Age 2', 'Age 3', 'Age 4', 'College', 'Political Thermometer Trump', 'ProD_Fake : Democrat Leaners', 'ProR_Fake : Democrat Leaners'))
texreg(list(polarFit), custom.coef.names = c('(Intercept)', 'ProD_Fake', 'Democrat Leaners', 'ProR_Fake', 'Ideology', 'Nonwhite', 'Political Knowledge', 'Age 2', 'Age 3', 'Age 4', 'College', 'Political Thermometer Trump', 'ProD_Fake : Democrat Leaners', 'ProR_Fake : Democrat Leaners'))


screenreg(list(massmediaFit1, pol_thermFit1, voteFit1, polactFit1), include.ci=F)
texreg(list(massmediaFit1, pol_thermFit1, voteFit1, polactFit1), custom.coef.names = c('(Intercept)', 'ProD_Fake', 'Democrat Leaners', 'ProR_Fake', 'Ideology', 'Nonwhite', 'Political Knowledge', 'Age 2', 'Age 3', 'Age 4', 'College', 'Political Thermometer Trump', 'ProD_Fake : Democrat Leaners', 'ProR_Fake : Democrat Leaners'))

texreg(list(polarFit1), custom.coef.names = c('(Intercept)', 'ProD_Fake', 'Democrat Leaners', 'ProR_Fake', 'Ideology', 'Nonwhite', 'Political Knowledge', 'Age 2', 'Age 3', 'Age 4', 'College', 'Political Thermometer Trump', 'ProD_Fake : Democrat Leaners', 'ProR_Fake : Democrat Leaners'))


################################################################
#False Topical Misperceptions analyses and plots



june$Topical_Misperception_ProD_False <- june$mis_pro_d_false
june$Topical_Misperception_ProR_False <- june$mis_pro_r_false

june$Total_Fake_News_Binary_18pre <- as.numeric(june$totalfakebinary18_pre)
june$Total_Fake_News_Binary_18pre <- as.factor(june$Total_Fake_News_Binary_18pre)



misJP1 <- lm_robust(formula = Topical_Misperception_ProD_False ~ Total_Fake_News_Binary_18pre * lean_Dem + ideology + polknow + pol_therm_trump + agecat + nonwhite + college, weights = weight, data = (june))



misJP2 <- lm_robust(formula = Topical_Misperception_ProR_False ~ Total_Fake_News_Binary_18pre * lean_Dem + ideology + polknow + pol_therm_trump + agecat + nonwhite + college, weights = weight, data = (june))

plot_model(misJP1, type = 'int', color = wes_palette("Darjeeling2", 2))

plot_model(misJP2, type = 'int', color = wes_palette("Darjeeling2", 2))


oct$Topical_Misperception_ProD_False <- oct$mis_pro_d_false
oct$Topical_Misperception_ProR_False <- oct$mis_pro_r_false

oct$Total_Fake_News_Binary_18pre <- as.factor(oct$totalfakebinary18_pre)

misOP1 <- lm_robust(formula = Topical_Misperception_ProD_False ~ Total_Fake_News_Binary_18pre * lean_Dem + ideology + polknow + pol_therm_trump + agecat + nonwhite + college, weights = weight, data = (oct))


misOP2 <- lm_robust(formula = Topical_Misperception_ProR_False ~ Total_Fake_News_Binary_18pre * lean_Dem + ideology + polknow + pol_therm_trump + agecat + nonwhite + college, weights = weight, data = (oct))


################################################################
#Experiment effects on accuracy and sharing plots

june$proD_fake <- as.factor(june$proD_fake)
june$proR_fake <- as.factor(june$proR_fake)
june$lean_Dem1 <- as.factor(june$lean_Dem)



oct$proD_fake <- as.factor(oct$proD_fake)
oct$proR_fake <- as.factor(oct$proR_fake)
oct$lean_Dem1 <- as.factor(oct$lean_Dem)



XPm1p <- lm_robust(Perceived_Accuracy ~ proD_fake * lean_Dem + proR_fake * lean_Dem + ideology + nonwhite + polknow + agecat + college + pol_therm_trump, data = june)


XPm2p <- lm_robust(Likelihood_Share ~ proD_fake * lean_Dem + proR_fake * lean_Dem + +ideology + nonwhite + polknow + agecat + college + pol_therm_trump, june)

XPm3p <- lm_robust(misinform_soros_w2 ~ proD_fake * lean_Dem + proR_fake * lean_Dem + +ideology + nonwhite + polknow + agecat + college + pol_therm_trump, data = oct)


XPm4p <- lm_robust(misinform_jamal_w2 ~ proD_fake * lean_Dem + proR_fake * lean_Dem + ideology + nonwhite + polknow + agecat + college + pol_therm_trump, data = oct)

plot_model(XPm1p, type = 'int', color = wes_palette("Darjeeling2", 2))
plot_model(XPm2p, type = 'int', color = wes_palette("Darjeeling2", 2))
plot_model(XPm3p, type = 'int', color = wes_palette("Darjeeling2", 2))
plot_model(XPm4p, type = 'int', color = wes_palette("Darjeeling2", 2))
