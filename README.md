# Predicting Recidivism applying IRAC method

## Project Overview
In this project, we will study the datasets released by ProPublica, a nonprofit organization based in New York City which aims to produce investigative journalism in the public interest. The datasets for this project consist of 4 parts (‘compas-scores-two-years.csv’, ‘compas-scores-two-years-violent.csv’, ‘cox-parsed.csv’ and ‘cox-violent-parsed.csv’). Those datasets consist of more than 10,000 criminal defendants in Broward County, Florida, who had been assessed with the COMPAS (which stands for Correctional Offender Management Profiling for Alternative Sanctions) screening system between 1st January 2013 and 31st December 2014. Based on the screening and assessment, the COMPAS software will generate several scores, which are used to quantify the risks of recidivism of a particular criminal defendant. There are more than 50 feature variables in the datasets, including the criminal defendants’ race, gender and age. Since these features are present in the datasets, we will examine if any machine bias in the algorithm, that is, any bias against certain group of people just because of their skin color or gender.

In addition, we will also focus on the legal and ethical concerns raised due to the usage of these features in the algorithm. Subsequently, we will apply the IRAC method to identify the legal issue which we think arises out of these facts, and any rule or policy we think is on point. Finally, we will apply the rule or policy to reach the final conclusion.

## Objectives of the Project
The following are the objectives of the project:
1.	To check if any machine bias in the algorithm which against certain group of people.
2.	To apply IRAC method to identify the legal issue of using the algorithm, and conclude if the algorithm shall be permitted to use.

## Project Outline
To start the project, those required R libraries such as ggplot2, dplyr, and the dataset “compas-scores-two-years.csv” (for risk of non-violent recidivism) are first loaded into the R program, followed by some data pre-processing (removal of some rows based on certain conditions, make some columns as factor etc.) and data visualization. Subsequently, a logistic regression model is built using the pre-processed dataset, and the coefficients of the logistic regression model are studied for checking if any bias. From the coefficients of the logistic regression model, it is found that black, female and young defendants are more likely to receive higher decile scores. Chi-squared test is done to confirm that the logistic regression model is significant.

The same data pre-processing steps are done for another dataset “compas-scores-two-years-violent” (for risk of violent recidivism), and another logistic regression model is built based on it. Again, it is found that both black and young defendants are more likely to receive higher decile scores. Chi-squared test is also done for this logistic regression model to confirm its significance.

The next step is to read another dataset “cox-parsed.csv” (non-violent) for survival analysis using cox proportional hazard regression model from the survival library. It is found that the cox model is significant and the overall survival rate for all 3 score factor groups are decreasing overtime as expected (defendant is considered “not survived” if they did recidivate).

Again, the same processes for survival analysis are done for another dataset “cox-violent-parsed” (violent). The cox model is found to be significant. However, for this case, it is found that the survival rates for both black and female defendants are not lower than their counterparts (white and male defendants), whereas from the logistic regression model it is found that both black and female defendants are more likely to receive higher decile scores. Hence it is concluded that there are some machine bias in the algorithm of COMPAS software.

Finally, the use of IRAC method for analysing the legal issue of using the algorithm is presented. It is concluded that the algorithm shall not be used since it is a violation of inmate rights and unlawful under the existing laws.

The following documents are provided in this repository:
  1. STD-0322A-Lee Jack Shiang-Project.docx: Word document for the project report
  2. STD-0322A-Lee Jack Shiang-Project.R: R codes for the project
  3. The 4 csv files: Datasets for the project
