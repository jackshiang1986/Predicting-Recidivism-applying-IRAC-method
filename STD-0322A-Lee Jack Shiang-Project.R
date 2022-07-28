############
# Task	1: #
############
# Analyse	the	Requirements related to	the	Scenario and justify why IRAC	is a suitable solution	
# Explain in a single	page how IRAC meets	the	objective	of this	Project.
# Please refer project report

#############################################################
# Task	2: Read	and	prepare	the	data for Risk	of Recidivism #
#############################################################
# Question 1
# - Import modules needed	to implement predictive	maintenance, R is	used (ggplot and dplyr)	
library(ggplot2)
library(dplyr)
library(grid)
library(gridExtra)
library(survival)
library(ggfortify)

# Question 2
# - Read the non violent dataset to	read the number	of rows
raw_data<-read.csv("compas-scores-two-years.csv")
nrow(raw_data)

# Check the head of the dataset
head(raw_data)

# Check the structure of the dataset
str(raw_data)

# Check the descriptive statistics of the dataset
summary(raw_data)

# Question 3
# - Remove rows	based	on following conditions	
#   o If the charge	date of	a	defendants Compas	scored crime was not within	30 days	from	
#     when the	person	was	arrested,	we	assume	that	because	of	data	quality	reasons,	that	we	
#     do	not	have	the	right	offense.
#   o We	coded	the	recidivist	flag	-- is_recid -- to	be	-1	if	we	could	not	find	a	compas	case	at	all.
#   o In	a	similar	vein,	ordinary	traffic	offenses	-- those	with	a c_charge_degree of	'O'	-- will	not	
# 	  in	Jail	time	are	removed	(only	two	of	them).
#   o We	filtered	the	underlying	data	from	Broward	county	to	include	only	those	rows	
#     representing	people	who	had	either	recidivated	in	two	years,	or	had	at	least	two	years	
#     outside	of	a	correctional	facility.

df <- dplyr::select(raw_data, age, c_charge_degree, race, age_cat, score_text, sex, priors_count, 
                    days_b_screening_arrest, decile_score, is_recid, two_year_recid, c_jail_in, c_jail_out) %>% 
              filter(days_b_screening_arrest <= 30) %>%
              filter(days_b_screening_arrest >= -30) %>%
              filter(is_recid != -1) %>%
              filter(c_charge_degree != "O") %>%
              filter(score_text != 'N/A')
nrow(df)

# Check the structure and descriptive statistics of the new df
str(df)
summary(df)

# Question 4
# - Get	new	filed	longer	length	of	stay	
df$length_of_stay <- as.numeric(as.Date(df$c_jail_out) - as.Date(df$c_jail_in))
cor(df$length_of_stay, df$decile_score)
# Such low correlation may be due to the rehabilitation center and may reduce the length of stay in jail

# Question 5
# - Get	the	summary	of	race,	gender,	age,	xtabs	by	sex	and	race	
# Summary tables for race, gender and age
table(df$race)  
table(df$age_cat) 
table(df$sex)   

round((table(df$race)/nrow(df))*100,2) 
# African-American and Caucasian make up the majority

round((table(df$age_cat)/nrow(df))*100,2) 
# 25 - 45 make up majority

round((table(df$sex)/nrow(df))*100,2) 
# Male make up majority

# Crosstable for sex vs race
xtabs(~ sex + race, data=df)

# Question 6
# - Plot	the	data	with	race	and	decile	score
pblack <- ggplot(data=filter(df, race =="African-American"), aes(ordered(decile_score))) + 
          geom_bar() + xlab("Decile Score") +
          ylim(0, 650) + ggtitle("Black Defendant's Decile Scores")
pwhite <- ggplot(data=filter(df, race =="Caucasian"), aes(ordered(decile_score))) + 
          geom_bar() + xlab("Decile Score") +
          ylim(0, 650) + ggtitle("White Defendant's Decile Scores")
grid.arrange(pblack, pwhite,  nrow = 2)
grid.arrange(pblack, pwhite,  ncol = 2)
# Judges are often presented with two sets of scores from the Compas system -- 
# one that classifies people into High, Medium and Low risk, and a corresponding 
# decile score. There is a clear downward trend in the decile scores as those scores increase 
# for white defendants, whereas for black defendants the decile scores are more or less
# uniformly distributed across all scores.


####################################
# Task	3:		Predict	racial	Bias #
####################################
# - Change some	 variables(age,	 race,	 gender) into	 factors,	 and	 run	 a	 logistic	 regression,
# comparing	 low	scores	to	high	scores.

# Changing age, race and gender into factors for better understanding of the biasness
df <- mutate(df, crime_factor = factor(c_charge_degree)) %>%
  
      mutate(age_factor = as.factor(age_cat)) %>%
      within(age_factor <- relevel(age_factor, ref = 1)) %>%
      # levels re-ordered so that "25 - 45" become the first and the others are moved down
  
      mutate(race_factor = factor(race)) %>%
      within(race_factor <- relevel(race_factor, ref = 3)) %>%     
      # levels re-ordered so that "Caucasian" become the first and the others are moved down
  
      mutate(gender_factor = factor(sex, labels= c("Female","Male"))) %>%
      within(gender_factor <- relevel(gender_factor, ref = 2)) %>%    
      # levels re-ordered so that "Male" become the first and the others are moved down
  
      mutate(score_factor = factor(score_text != "Low", labels = c("LowScore","HighScore")))

# Check the structure of the new df
str(df)

# Build a logistic regression model based on risk of recidivism dataset
# Here we are building model to compares low score and high score to understand whether there is racial bias or not
# glm(general linear model) which is multiple linear regression for both continuous and discrete variables
model <- glm(score_factor ~ gender_factor + age_factor + race_factor +
               priors_count + crime_factor + two_year_recid, family="binomial", data=df)
summary(model)
# Interpretations
# 1. Coefficients for female, African-American and age less than 25 groups are positive, meaning they have higher odds
#    of getting high decile scores
# 2. p-values for the above 3 groups, as well as for the intercept term are much less than 0.05, meaning they are
#    statistically significant

# Compare the score factors between groups of interest
# Set up the control parameter
control <- exp(-1.52554) / (1 + exp(-1.52554))
control

# Compare black defendants against white defendants 
exp(0.47721) / (1 - control + (control * exp(0.47721)))
# Black defendants are about 1.45 times more likely to get high decile scores than white defendants do

# Compare female defendants against male defendants
exp(0.22127) / (1 - control + (control * exp(0.22127)))
# Female defendants are about 1.19 times more likely to get high decile scores than male defendants do

# Compare younger (less than 25) defendants against middle-age (25 - 45) defendants
exp(1.30839) / (1 - control + (control * exp(1.30839)))
# Younger (less than 25) defendants are about 2.50 times more likely to get high decile scores than
# middle-age (25 - 45) defendants do

# Checking model significance
# X2 statistic of the model:
# X2 = Null deviance - Residual deviance
X2_model = model$null.deviance - model$deviance
X2_model

# Calculate p-value of X2_model
# df = number of features of the model = 11
# lower.tail = FALSE to get the required probability (p-value) on the right tail of the X2 distribution chart
pchisq(X2_model, df = 11, lower.tail = FALSE)
# Since the p-value is much less than 0.05, it is concluded that the model is statistically significant

# Null deviance
qchisq(0.05, model$null.deviance)
# 8483.3 > 8270.224, hence model with just the intercept term is significant

# Residual deviance
qchisq(0.05, model$deviance)
# 6168.4 > 5986.85, hence model with feature variables is significant


##############################################################################
# Task	4:		Read	and	prepare	the	data	 for	Risk	of	Violent	Recidivism #
##############################################################################

# Question 1
# - Read	the	violent	dataset	 to	read	the	number	of	rows
raw_data_1<-read.csv("compas-scores-two-years-violent.csv")
nrow(raw_data_1)

# Question 2
# - Remove	rows	based	on	following	conditions	
#     o If	the	charge	date	of	a	defendants	Compas	scored	crime	was	not	within	30	days	from	
#       when	the	person	was	arrested,	we	assume	that	because	of	data	quality	reasons,	that	we	
#       do	not	have	the	right	offense.
#     o We	coded	the	recidivist	flag	-- is_recid -- to	be	-1	if	we	could	not	find	a	compas	case	at	all.
#     o In	a	similar	vein,	ordinary	traffic	offenses	-- those	with	a c_charge_degree of	'O'	-- will	not	
#       result	in	Jail	time	are	removed	(only	two	of	them).
#       We	filtered	the	underlying	data	from	Broward	county	to	include	only	those	rows	
#       representing	people	who	had	either	recidivated	in	two	years,	or	had	at	least	two	years	
#       outside	of	a	correctional	facility.

df2 <- dplyr::select(raw_data_1, age, c_charge_degree, race, age_cat, v_score_text, sex, priors_count, 
                     days_b_screening_arrest, v_decile_score, is_violent_recid, two_year_recid, c_jail_in, c_jail_out) %>% 
              filter(days_b_screening_arrest <= 30) %>%
              filter(days_b_screening_arrest >= -30) %>% 
              filter(is_violent_recid != -1) %>%
              filter(c_charge_degree != "O") %>%
              filter(v_score_text != 'N/A')
nrow(df2)

# Question 3
# - Get	new	filed	longer	length	of	stay	
df2$v_length_of_stay <- as.numeric(as.Date(df2$c_jail_out) - as.Date(df2$c_jail_in))
cor(df2$v_length_of_stay, df2$v_decile_score)
# Such low correlation may be due to the rehabilitation center and may reduce the length of stay in jail

# Question 4
# - Get	the	summary	of	race,	age	category	
table(df2$race)
table(df2$age_cat)
table(df2$sex)

round((table(df2$race)/nrow(df2))*100,2)
# African-American and Caucasian make up the majority

round((table(df2$age_cat)/nrow(df2))*100,2)
# 25 - 45 make up majority

round((table(df2$sex)/nrow(df2))*100,2)
# Male make up majority

# Question 5
# - Plot	the	data	with	race	and	decile	score
pblack <- ggplot(data=filter(df2, race =="African-American"), aes(ordered(v_decile_score))) + 
          geom_bar() + xlab("Violent Decile Score") +
          ylim(0, 700) + ggtitle("Black Defendant's Violent Decile Scores")
pwhite <- ggplot(data=filter(df2, race =="Caucasian"), aes(ordered(v_decile_score))) + 
          geom_bar() + xlab("Violent Decile Score") +
          ylim(0, 700) + ggtitle("White Defendant's Violent Decile Scores")
grid.arrange(pblack, pwhite,  ncol = 2)
# Based on the plots, it is found that the violent decile score charts for both black and
# white defendants are right skewed. In addition, there is an unusual spike for violent decile score at 1
# for white defendants

# Build another logistic regression model based on risk of violent recidivism dataset
df2 <- mutate(df2, crime_factor = factor(c_charge_degree)) %>%
  
       mutate(age_factor = as.factor(age_cat)) %>%
       within(age_factor <- relevel(age_factor, ref = 1)) %>%
       # levels re-ordered so that "25 - 45" become the first and the others are moved down
  
       mutate(race_factor = factor(race,
                                   labels = c("African-American", 
                                              "Asian",
                                              "Caucasian", 
                                              "Hispanic", 
                                              "Native American",
                                              "Other"))) %>%
       within(race_factor <- relevel(race_factor, ref = 3)) %>%
       # levels re-ordered so that "Caucasian" become the first and the others are moved down
  
       mutate(gender_factor = factor(sex, labels= c("Female","Male"))) %>%
       within(gender_factor <- relevel(gender_factor, ref = 2)) %>%
       # levels re-ordered so that "Male" become the first and the others are moved down
  
       mutate(score_factor = factor(v_score_text != "Low", labels = c("LowScore","HighScore")))

str(df2)

model_2 <- glm(score_factor ~ gender_factor + age_factor + race_factor +
                 priors_count + crime_factor + two_year_recid, family="binomial", data=df2)

summary(model_2)
# Interpretations
# 1. Coefficients for African-American and age less than 25 groups are positive, meaning they have higher odds
#    of getting high decile scores
# 2. p-values for the above 2 groups, as well as for the intercept term are much less than 0.05, meaning they are
#    statistically significant

# Compare the score factors between groups of interest
# Set up the control parameter
control_2 <- exp(-2.24274) / (1 + exp(-2.24274))
control_2

# Compare black defendants against white defendants
exp(0.65893) / (1 - control_2 + (control_2 * exp(0.65893)))
# Black defendants are about 1.77 times more likely to get high decile scores than white defendants do

# Compare younger (less than 25) defendants against middle-age (25 - 45) defendants
exp(3.14591) / (1 - control_2 + (control_2 * exp(3.14591)))
# Younger (less than 25) defendants are about 7.41 times more likely to get high decile scores than
# middle-age (25 - 45) defendants do

# Checking model significance
# X2 statistic of model_2:
# X2 = Null deviance - Residual deviance
X2_model_2 = model_2$null.deviance - model_2$deviance
X2_model_2

# Calculate p-value of X2_model_2
# df = number of features of the model = 11
# lower.tail = FALSE to get the required probability (p-value) on the right tail of the X2 distribution chart
pchisq(X2_model_2, df = 11, lower.tail = FALSE)
# Since the p-value is much less than 0.05, it is concluded that the model is statistically significant

# Null deviance
qchisq(0.05, model_2$null.deviance)
# 4731.8 > 4572.915, hence model with just the intercept term is significant

# Residual deviance
qchisq(0.05, model_2$deviance)
# 2998.8 > 2872.543, hence model with feature variables is significant


############
# Task	5: #
############
# Read	the	cox-parsed.csv	dataset		to	read	the	number	of	rows
df3 = read.csv("cox-parsed.csv")
nrow(df3)

# Perform data cleaning
data <- filter(filter(df3 , score_text != "N/A"), end > start) %>%
  
        mutate(race_factor = factor(race,
                                    labels = c("African-American", 
                                               "Asian",
                                               "Caucasian", 
                                               "Hispanic", 
                                               "Native American",
                                               "Other"))) %>%
        within(race_factor <- relevel(race_factor, ref = 3)) %>%
        # levels re-ordered so that "Caucasian" become the first and the others are moved down
  
        mutate(score_factor = factor(score_text)) %>%
        within(score_factor <- relevel(score_factor, ref=2))
        # levels re-ordered so that "Low" become the first and the others are moved down

nrow(data)

# Remove those rows with duplicated id
grp <- data[!duplicated(data$id),]

# Check the row number and structure of grp
nrow(grp)
str(grp)

# Get	summary	of	score	factor	and	race	factor
summary(grp$score_factor)
summary(grp$race_factor)

# Create a survival object based on score_factor using Surv()
f <- Surv(start, end, event, type="counting") ~ score_factor
summary(f)

# The function coxph()[in survival package] can be used to compute the Cox proportional hazard regression model in R
model <- coxph(f, data=grp)
summary(model)
# Findings:
# 1. Both score_factorHigh and score_factorMedium are statistically significant since their p-values are < 0.05
# 2. Coefficients are both positive, meaning that the hazard (risk of recidivate) is higher for both 
#    score_factorHigh and score_factorMedium
# 3. Model is significant based on the 3 tests (Likelihood ratio test, Wald test and Score (logrank) test)
# 4. Concordance= 0.635

# Get	summary	of	fit,	white	fit	and	black	fit
# The function survfit() [in survival package] can be used to compute Kaplan-Meier survival estimate
# Create the overall Kaplan-Meier survival estimate based on the 3 score_factor groups (Low, Medium, High)
fit <- survfit(f, data=grp)
summary(fit)

# Plot the overall Kaplan-Meier survival curves for the 3 score_factor groups (Low, Medium, High)
plotty <- function(fit, title) {
  return(autoplot(fit, conf.int=T, censor=F) + ggtitle(title) + ylim(0,1))
}
plotty(fit, "Overall")
# Overall survival rates for all 3 score_factor groups are decreasing over time as expected (criminal defendant is 
# considered 'not survived' if they did recidivate)

# Create the Kaplan-Meier survival estimate for white people based on the 3 score_factor groups (Low, Medium, High)
white <- filter(grp, race == "Caucasian")
white_fit <- survfit(f, data=white)

# Create the Kaplan-Meier survival estimate for black people based on the 3 score_factor groups (Low, Medium, High)
black <- filter(grp, race == "African-American")
black_fit <- survfit(f, data=black)

# Plot the Kaplan-Meier survival curves for both white and black defendants based on the 3 score_factor groups (Low, Medium, High)
grid.arrange(plotty(white_fit, "White defendants"), 
             plotty(black_fit, "Black defendants"), ncol=2)
# Findings:
# 1. Survival rates for both white and black defendants decrease overtime as expected.
# 2. White defendants have higher survival rates compared to black defendants.

# Summary	of	fit,	white	fit	and	black	fit based on the 3 score_factor groups (Low, Medium, High)
summary(fit, times=c(730))
summary(white_fit, times=c(730))
summary(black_fit, times=c(730))

# Get	summary	of	coxph	for	white	and	black	data
summary(coxph(f, data=white))
summary(coxph(f, data=black))
# Findings:
# 1. p-values for both score_factorHigh and score_factorMedium are much less than 0.05, hence they are
#    statistically significant
# 2. p-values for all 3 tests (Likelihood ratio test, Wald test and Score (logrank) test ) are much less than 0.05,
#    hence the cox models are statistically significant
# 3. Concordances are similar to both white and black people (0.624 vs 0.621)


############
# Task	6: #  
############
# Read	the	cox-violent-parsed.csv dataset to	read	the	number	of	rows
df4 = read.csv("cox-violent-parsed.csv")
nrow(df4)

# Perform data cleaning
violent_data <- filter(filter(df4, score_text != "N/A"), end > start) %>%
  mutate(race_factor = factor(race,
                              labels = c("African-American", 
                                         "Asian",
                                         "Caucasian", 
                                         "Hispanic", 
                                         "Native American",
                                         "Other"))) %>%
  within(race_factor <- relevel(race_factor, ref = 3)) %>%
  # levels re-ordered so that "Caucasian" become the first and the others are moved down
  
  mutate(score_factor = factor(score_text)) %>%
  within(score_factor <- relevel(score_factor, ref=2))
  # levels re-ordered so that "Low" become the first and the others are moved down

# Remove those rows with duplicated id
vgrp <- violent_data[!duplicated(violent_data$id),]
print(nrow(vgrp))

# Create a survival object based on score_factor using Surv()
vf <- Surv(start, end, event, type="counting") ~ score_factor

# The function coxph()[in survival package] can be used to compute the Cox proportional hazard regression model in R
vmodel <- coxph(vf, data=vgrp)
summary(vmodel)
# Findings:
# 1. Both score_factorHigh and score_factorMedium are statistically significant since their p-values are < 0.05
# 2. Coefficients are both positive, meaning that the hazard (risk of recidivate) is higher for both 
#    score_factorHigh and score_factorMedium
# 3. Model is significant based on the 3 tests (Likelihood ratio test, Wald test and Score (logrank) test)
# 4. Concordance= 0.648

# Get	summary	of	coxph	for	white	and	black	data
summary(coxph(vf, data=filter(vgrp, race == "Caucasian")))
summary(coxph(vf, data=filter(vgrp, race == "African-American")))
# Findings:
# 1. p-values for both score_factorHigh and score_factorMedium are much less than 0.05, hence they are
#    statistically significant
# 2. p-values for all 3 tests (Likelihood ratio test, Wald test and Score (logrank) test ) are much less than 0.05,
#    hence the cox models are statistically significant
# 3. Concordances are similar to both white and black people (0.611 vs 0.635)

# Plot the Kaplan-Meier survival curves for both white and black defendants based on the 3 score_factor groups (Low, Medium, High)
plotty <- function(fit, title) {
  return(autoplot(fit, conf.int=T, censor=F) + ggtitle(title) + ylim(0,1))
}

white <- filter(vgrp, race == "Caucasian")
white_fit <- survfit(vf, data=white)

black <- filter(vgrp ,race == "African-American")
black_fit <- survfit(vf, data=black)

grid.arrange(plotty(white_fit, "White defendants"), 
             plotty(black_fit, "Black defendants"), ncol=2)
# Findings:
# 1. Survival rates for both white and black defendants decrease overtime as expected.
# 2. No clear differences for survival rates between white and black defendants.
# 3. It should be noted that from Task 4, it is found that black defendants are about 1.77 times more likely to get
#    high decile scores than white defendants do. However, this is hardly justifiable based on finding from point 2 above
#    and the algorithm is clearly biased against black defendants.


############
# Task	7: #  
############
# Survival analysis for cox-parsed.csv dataset (Non-violent) based on gender
# Plot the Kaplan-Meier survival curves for both male and female defendants based on the 3 score_factor groups (Low, Medium, High)
female <- filter(grp, sex == "Female")
male   <- filter(grp, sex == "Male")
f <- Surv(start, end, event, type="counting") ~ score_factor
male_fit <- survfit(f, data=male)
female_fit <- survfit(f, data=female)

summary(male_fit, times=c(730))

summary(female_fit, times=c(730))

grid.arrange(plotty(female_fit, "Female"), plotty(male_fit, "Male"),ncol=2)
# Findings:
# 1. Survival rates for both male and female defendants decrease overtime as expected.
# 2. The survival curves are significantly different between male and female. Survival rates for male are significantly lower,
#    especially for those from high score factor group.
# 3. It should be noted that from Task 3, it is found that female are about 1.19 times more likely to get
#    high decile scores than male defendants do. However, this is hardly justifiable based on finding from point 2 above
#    and the algorithm is clearly biased against female.

# Survival analysis for cox-violent-parsed.csv dataset (Violent) based on gender
# Plot the Kaplan-Meier survival curves for both male and female defendants based on the 3 score_factor groups (Low, Medium, High)
vfemale <- filter(vgrp, sex == "Female")
vmale   <- filter(vgrp, sex == "Male")
vf <- Surv(start, end, event, type="counting") ~ score_factor
v_male_fit <- survfit(vf, data=vmale)
v_female_fit <- survfit(vf, data=vfemale)

summary(v_male_fit, times=c(730))

summary(v_female_fit, times=c(730))

grid.arrange(plotty(v_female_fit, "Female"), plotty(v_male_fit, "Male"),ncol=2)
# Findings:
# 1. Survival rates for both male and female defendants decrease overtime as expected.
# 2. The survival curves are not as significantly different as compared to the non-violent data. However the survival rates for male
#    are still lower than female, especially for those from high score factor group.



