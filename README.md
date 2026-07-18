# Predicting Credit Default Risk Using Statistical Modelling

## Overview
This project developed in SAS and builds an end-to-end credit risk scorecard to predict the probability of borrowers defaulting using logistic regression and random forest models. 
It applies risk modeling practices to evaluate lending decisions across 150,000 borrower records. The objective was to compare two modeling approaches by evaluating their performance using AUC and the KS statistic, and then convert predicted probabilities into a standardized credit score range. The process includes data cleaning, model training, performance evaluation, and scorecard scaling, which segments borrowers into five risk bands to support credit decision-making.

&nbsp;

## Why This Project Matters
Credit risk modelling is a core function in financial services. 
Lenders rely on probability of default models to decide who to lend to, how much to lend, and at what interest rate. 
The model allows lenders to distinguish between a borrower likely to repay and one likely to default. 

This project demonstrates an full modeling framework, transforming raw data into a deployable credit scorecard. 
By covering data cleaning, statistical modeling, model evaluation, and output interpretation, it reflects the exact workflow used by credit risk analysts.

&nbsp;

## Dataset
Data was sourced from the Kaggle (Give me some credit) containing 150,000 borrower records across ten input features including revolving utilisation, age, debt ratio, monthly income, number of open credit, and late payment history across 30, 60 and 90 days. 

The scale and diverse range of these variables mirror the complexity of data in a real-world lending environment. 
The dataset presented several data quality challenges, including missing values, and anomalies like an age of 0 and utilization rates exceeding 1. 
The preprocessing resolved these inconsistencies through targeted data imputation and outlier treatment, addressing the exact type of messy data an analyst encounters in production.

&nbsp;

## Methodology

**1) Load the Data:**
The raw dataset was loaded into SAS and variable names were shortened to work within character limits. 

**2) Explore the Data:**
The data was then explored to understand its structure, identify missing values, spot any errors, and confirm the default rate.

**3) Clean the Data:**
Records with an age of zero were removed as these are not valid, missing values were filled using the median of each variable, and revolving utilisation was capped at 1. The data was checked again after cleaning to confirm all issues were resolved. 

**4) Split the Data:**
The cleaned dataset was divided into a 70% training set and a 30% test set. The default rate was verified in both splits to confirm the division in each dataset.

**5) Compare Default and Non-Default Borrowers:**
Average values across key variables were compared between borrowers who defaulted and those who did not. This helped identify which variables were likely to carry the most predictive power.

**6) Build the Logistic Regression Model:**
 A logistic regression model was built to predict the probability of default. Stepwise variable selection was applied to automatically identify and retain only the most statistically significant predictors from the available variables. 

**7) Build the Random Forest Model:**
A random forest model was built to compare against logistic regression. Random forest was chosen because it can capture more complex relationships between variables that a linear model may not detect. 

**8) Test Both Models:**
Both models were applied to the test set to evaluate how well they performed on data they had not seen during training.

**9) Calculate the KS Statistic:**
The KS statistic was calculated to measure how well the model separates borrowers who defaulted from those who did not. The higher the KS, the better the model is at distinguishing between the two groups.

**10) Build the Credit Scorecard:**
Predicted probabilities were converted into credit scores and borrowers were segmented into five risk bands.

&nbsp;

## Outcomes

| Metric | Value | Description |
|--------|-------|-------------|
| AUC | 0.768 | Strong ability to distinguish defaulters from non-defaulters |
| KS Statistic | 0.404 | Good separation between bad and good accounts |
| Gini Coefficient | 0.536 | Consistent with AUC, confirming model discriminatory power |
| Score Range | 300 to 850 | Aligned with industry standard consumer credit score ranges |
| PDO | 20 | Score increases 20 points each time good odds double |
| Default Rate | 6.5% | Consistent across both splits confirming representative sample |


&nbsp;

| Risk Band | Score | Share | Description | Action |
|-----------|-------|-------|-------------|--------|
| Very Low Risk | 750 and above | 0.03% | Borrower has a strong repayment history with very low probability of default | Approve lending, offer competitive rates |
| Low Risk | 650 to 749 | 0.10% | Borrower is likely to repay with minor risk indicators present | Approve lending, standard rates apply |
| Medium Risk | 550 to 649 | 81.33% | Borrower shows some signs of financial stress or irregular payment behaviour | Consider lending with conditions or higher rate |
| High Risk | 450 to 549 | 18.50% | Borrower has notable delinquency history or high debt burden | Decline or require additional security |
| Very High Risk | Below 450 | 0.05% | Borrower has a significant probability of default within 24 months | Decline lending |


&nbsp;

## Limitations
**1) Dataset Context:** 
The dataset originates from the US, meaning borrower behaviour patterns, income levels and definitions of default may not directly reflect a UK environment. 

**2) Missing Variables:** 
Several variables commonly used in a real scorecard are absent from the dataset which limits thr accuracy of the credit scorecard, including employment status.

**3) Late Payment Detail:** 
The dataset only captures late payments at 30, 60 and 90 day intervals. Knowing earlier missed payments such as 10 or 20 days would provide a more complete picture and could influence lending decisions. 

**4) Missing Value Treatment:** 
Missing values were filled using the median of each variable which introduces inaccuracies into the dataset, particularly for monthly income where a significant number of values were missing. 

**5) Static Dataset:** 
The model was trained and tested on a single snapshot of borrower data. It does not account for how borrower behaviour or conditions change over time.

