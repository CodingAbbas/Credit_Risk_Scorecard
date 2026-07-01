# Predicting Credit Default Risk Using Statistical Modelling

## Overview
This project builds an end-to-end credit risk scorecard to predict the probability of borrowers defaulting using logistic regression and random forest models. Developed in SAS, it replicates probability of default modelling practices used by credit risk teams to assess lending decisions across 150,000 borrower records. 

The objective was to compare two modelling approaches, evaluate their performance using AUC, KS statistic and Gini coefficient, and convert predicted probabilities into a standardised credit score range. Borrowers are segmented into five risk bands to support credit decision making, with the full pipeline covering data cleaning, model training, performance evaluation and scorecard scaling. 


&nbsp;

## Why This Project Matters
Credit risk modelling is a core function in financial services. Lenders rely on probability of default models to decide who to lend to, how much to lend, and at what interest rate. Without a model like this, there is no systematic way to distinguish between a borrower likely to repay and one likely to default. 

This project was built to demonstrate the full modelling pipeline from raw data to a deployable scorecard. The skills include data cleaning, statistical modelling, model evaluation and output interpretation, reflecting the same workflow used by credit risk analysts working across risk, strategy and data functions in financial services.


&nbsp;

## Dataset
Data was sourced from the Kaggle (Give me some credit) containing 150,000 borrower records across ten input features including revolving utilisation, age, debt ratio, monthly income, number of open credit, and late payment history across 30, 60 and 90 days. The scale and range of variables make it well suited for building a credit scorecard, with enough complexity to reflect the type of data encountered in a real lending environment. 

The dataset presented several data quality challenges, with missing values across monthly income, revolving utilisation, debt ratio and dependents, each requiring imputation. Incorrect values were also present, including age recorded as 0 and utilisation exceeding 1, both of which would have distorted the results. These inconsistencies reflected the kind of messy, real-world data an analyst would typically encounter before building any predictive model.


&nbsp;

## Methodology

**1) Load the Data:**
The raw dataset was loaded into SAS and variable names were shortened to work within character limits. 
This established the working dataset that all subsequent steps build upon.


**2) Explore the Data:**
Before making any changes, the data was explored to understand its structure, identify missing values, spot any errors, and confirm the overall default rate. This step informed every cleaning decision that followed. 

**3) Clean the Data:**
Missing values were filled using the median of each variable to preserve as many records as possible. Records with an age of zero were removed as these are not valid, and revolving utilisation was capped at 1 to remove unrealistic values. The data was checked again after cleaning to confirm all issues were resolved. 


**4) Split the Data:**
The cleaned dataset was divided into a 70% training set and a 30% test set. The default rate was verified in both splits to confirm the division was representative before any model was built. 


**5) Compare Default and Non-Default Borrowers:**
Average values across key variables were compared between borrowers who defaulted and those who did not. This helped identify which variables were likely to carry the most predictive power before modelling began. 


**6) Build the Logistic Regression Model:**
 A logistic regression model was built to predict the probability of default. Stepwise variable selection was applied to automatically identify and retain only the most statistically significant predictors from the available variables. 


**7) Build the Random Forest Model:**
A random forest model was built as a second approach to compare against logistic regression. Random forest was chosen because it can capture more complex relationships between variables that a linear model may not detect. 


**8) Test Both Models:**
Both models were applied to the test set to evaluate how well they performed on data they had not seen during training. This step produced the performance metrics used to compare the two approaches. 


**9) Calculate the KS Statistic:**
Calculate the KS Statistic: The KS statistic was calculated to measure how well the model separates borrowers who defaulted from those who did not. The higher the KS, the better the model is at distinguishing between the two groups.


**10) Build the Credit Scorecard:**
Predicted probabilities were converted into credit scores and borrowers were segmented into five risk bands. 
The final scorecard was exported to CSV for further analysis.


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
| Very Low Risk | 750 and above | 0% | Borrower has a strong repayment history with very low probability of default | Approve lending, offer competitive rates |
| Low Risk | 650 to 749 | 0% | Borrower is likely to repay with minor risk indicators present | Approve lending, standard rates apply |
| Medium Risk | 550 to 649 | 0% | Borrower shows some signs of financial stress or irregular payment behaviour | Consider lending with conditions or higher rate |
| High Risk | 450 to 549 | 0% | Borrower has notable delinquency history or high debt burden | Decline or require additional security |
| Very High Risk | Below 450 | 0% | Borrower has a significant probability of default within 24 months | Decline lending |


&nbsp;

## Limitations
**1) Dataset Context:** The dataset originates from a US consumer lending context, meaning borrower behaviour patterns, income levels and definitions of default may not directly reflect a UK lending environment. 

**2) Missing Variables:** Several variables commonly used in real scorecard development are absent from this dataset which limits how closely this model replicates a production-ready scorecard, including employment status and time at address.

**3) Late Payment Detail:** The dataset only captures late payments at 30, 60 and 90 day intervals. Having visibility of earlier missed payments such as 10 or 20 days would provide a more complete picture and could influence lending decisions. 

**4) Missing Value Treatment:** Missing values were filled using the median of each variable. While this avoids losing records, it introduces inaccuracies into the dataset, particularly for monthly income where a significant number of values were missing. 

**5) Static Dataset:** The model was trained and tested on a single snapshot of borrower data. It does not account for how borrower behaviour or conditions change over time.

