# Predicting Recidivism applying IRAC method

This project served as the Summative Assessment for module "Statistical	Thinking for Data	Science and	Analytics" of Professional Diploma in Data Science of Lithan Academy.

## Project Overview
In this project, the datasets used for the study were released by ProPublica, a nonprofit organization based in New York City which aimed to produce investigative journalism in the public interest. The datasets for this project consisted of 4 parts (‘compas-scores-two-years.csv’, ‘compas-scores-two-years-violent.csv’, ‘cox-parsed.csv’ and ‘cox-violent-parsed.csv’). Those datasets consisted of more than 10,000 criminal defendants in Broward County, Florida, who had been assessed with the COMPAS (which stands for Correctional Offender Management Profiling for Alternative Sanctions) screening system between 1st January 2013 and 31st December 2014. Based on the screening and assessment, the COMPAS software would generate several scores, which would be used to quantify the risks of recidivism of a particular criminal defendant. There were more than 50 feature variables in the datasets, including the criminal defendants’ race, gender and age. Since these features were present in the datasets, we would examine if any machine bias against certain group of people just because of their skin color or gender.

In addition, we would also focus on the legal and ethical concerns raised due to the usage of these features in the algorithm. Subsequently, we would apply the IRAC method to identify the legal issues and reach the final conclusion.

## Objectives of the Project
The following are the objectives of the project:
1.	To check if any machine bias in the algorithm which against certain group of people.
2.	To apply IRAC method to identify the legal issue of using the algorithm, and conclude if the use of the algorithm shall be permitted.

## Project Outline
To start the project, those required R libraries such as ggplot2, dplyr, and the dataset “compas-scores-two-years.csv” (for risk of non-violent recidivism) were first loaded into the R program, followed by some data pre-processing (removal of some rows based on certain conditions, make some columns as factor etc.) and data visualization. Subsequently, a logistic regression model was built using the pre-processed dataset, and the coefficients of the logistic regression model were studied for checking if any bias. From the coefficients of the logistic regression model, it was found that black, female and young defendants were more likely to receive higher decile scores. Chi-squared test was done to confirm that the logistic regression model was significant.

The same data pre-processing steps were done for another dataset “compas-scores-two-years-violent” (for risk of violent recidivism), and another logistic regression model was built based on it. Again, it was found that both black and young defendants were more likely to receive higher decile scores. Chi-squared test was also done for this logistic regression model to confirm it was significant.

The next step was to read another dataset “cox-parsed.csv” (non-violent) for survival analysis using cox proportional hazard regression model from the survival library. It was found that the cox model was significant and the overall survival rate for all 3 score factor groups were decreasing overtime as expected (defendant was considered “not survived” if they did recidivate).

Again, the same processes for survival analysis were done for another dataset “cox-violent-parsed” (violent). The cox model was found to be significant. However, for this case, it was found that the survival rates for both black and female defendants were not lower than their counterparts (white and male defendants), whereas from the logistic regression model it was found that both black and female defendants were more likely to receive higher decile scores. Hence it was concluded that there were some machine bias in the algorithm of COMPAS software.

Finally, the use of IRAC method for analysing the legal issue of using the algorithm was presented. It was concluded that the algorithm shall not be used since it was a violation of inmate rights and unlawful under the existing laws.

The following documents are provided in this repository:
  1. STD-0322A-Lee Jack Shiang-Project.docx: Word document for the project report
  2. STD-0322A-Lee Jack Shiang-Project.R: R codes for the project
  3. The 4 csv files: Datasets for the project
