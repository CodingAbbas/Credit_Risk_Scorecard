/* Project: Predicting Credit Default Risk Using Statistical Modelling */
/* Script: Credit_Risk_Scorecard.SAS */
/* Tools: SAS Studio */
/* Data: Kaggle (Give Me Some Credit) */


/* STEP 1: LOAD THE DATA */
/* Upload the CSV file */
/* Assign short variable names to avoid character limit */

DATA work.raw_data;

    INFILE "/home/u64174377/credit_risk/cs-training.csv"
    DELIMITER = ','
    MISSOVER
    DSD
    FIRSTOBS = 2;

    INPUT
    id
    default
    revutil
    age
    late30
    debtratio
    income
    opencredit
    late90
    loans
    late60
    dependents;

RUN;



/* STEP 2: EXPLORE THE DATA */
/* Identify missing values and error values */

PROC MEANS DATA = work.raw_data
    N
    NMISS
    MEAN
    MEDIAN
    MIN
    MAX
    STDDEV;

    VAR default revutil age late30 debtratio income
        opencredit late90 loans late60 dependents;

RUN;



/* Check default rate with 1 meaning Default and 0 meaning Non-Default */

PROC FREQ DATA = work.raw_data;
    TABLES default;
RUN;



/* STEP 3: CLEAN THE DATA */
/* Replace missing values with median and fix data errors */

DATA work.clean_data;
    SET work.raw_data;

    IF revutil    = . THEN revutil    = 0.1451232;
    IF debtratio  = . THEN debtratio  = 0.3513847;
    IF income     = . THEN income     = 5400.00;
    IF dependents = . THEN dependents = 0;

    IF age = 0 THEN DELETE;
    IF revutil > 1 THEN revutil = 1;

RUN;



/* Verify data has been cleaned */

PROC MEANS DATA = work.clean_data
    N
    NMISS
    MEAN
    MEDIAN
    MIN
    MAX
    STDDEV;

    VAR default revutil age late30 debtratio income
        opencredit late90 loans late60 dependents;

RUN;



/* STEP 4: SPLIT THE DATA */
/* Use the industry standard split of 70% training and 30% testing */

PROC SURVEYSELECT
    DATA     = work.clean_data
    OUT      = work.sampled_data
    METHOD   = srs
    SAMPRATE = 0.7
    OUTALL
    SEED     = 42;

RUN;



/* Split data into training and test datasets */

DATA work.train_data work.test_data;

    SET work.sampled_data;
    IF selected = 1 THEN OUTPUT work.train_data;
    ELSE OUTPUT work.test_data;

RUN;



/* Verify default rate is around 6.5% to confirm random split */

PROC FREQ DATA = work.train_data;
    TABLES default;
RUN;

/* Verify default rate is around 6.5% to confirm random split */

PROC FREQ DATA = work.test_data;
    TABLES default;
RUN;



/* STEP 5: COMPARE DEFAULT AND NON-DEFAULT */
/* Compare the average values between the two groups */

PROC MEANS DATA = work.train_data MEAN;

    CLASS default;
    VAR age income debtratio revutil late30 late90;

RUN;



/* STEP 6: BUILD PREDICTIVE MODELS */
/* Compare two different approaches to show which works best */

/* LOGISTIC REGRESSION MODEL */
/* STEPWISE selection chooses the most important variables to predict default */

PROC LOGISTIC DATA = work.train_data
    OUTMODEL = work.logistic_model
    PLOTS(ONLY) = roc;

    MODEL default (EVENT = '1') =
    revutil age late30 debtratio income
    opencredit late90 loans late60 dependents

    / SELECTION = stepwise
    SLENTRY = 0.05
    SLSTAY  = 0.05
    LACKFIT;

    OUTPUT OUT = work.logistic_train_pred
    PREDICTED = logistic_prob;

RUN;



/* RANDOM FOREST MODEL */
/* Collection of decision trees that handles non-linear relationships */

PROC HPFOREST DATA = work.train_data SEED = 42;

    TARGET default /
    LEVEL = nominal;

    INPUT
    revutil
    age
    late30
    debtratio
    income
    opencredit
    late90
    loans
    late60
    dependents /
    LEVEL = interval;

    SAVE FILE = "/home/u64174377/credit_risk/forest_model.bin";

RUN;



/* STEP 7: TEST THE MODELS */
/* Apply both models to the test data and compare performance */

/* LOGISTIC REGRESSION TEST */

PROC LOGISTIC INMODEL = work.logistic_model;

    SCORE DATA = work.test_data
    OUT         = work.logistic_test_pred
    FITSTAT;

RUN;



/* RANDOM FOREST TEST */

PROC HPFOREST;
    RESTORE FILE = "/home/u64174377/credit_risk/forest_model.bin";
    SCORE DATA   = work.test_data
    OUT          = work.forest_test_pred;
RUN;



/* Logistic Regression Confusion Matrix */
/* Compare predicted class against actual default */

PROC FREQ DATA = work.logistic_test_pred;

    TABLES default * I_default / NOCOL NOROW NOPERCENT;
    TITLE "Logistic Regression Confusion Matrix";

RUN;



/* Compare average predicted probabilities for each model */

PROC MEANS DATA = work.logistic_test_pred MEAN;

    VAR P_1;
    TITLE "Logistic Regression Predictions";

RUN;



PROC MEANS DATA = work.forest_test_pred MEAN;

    VAR P_1;
    TITLE "Random Forest Predictions";

RUN;



/* STEP 8: CALCULATE KS STATISTIC */
/* Measures how well the model separates Defaulters from Non-Defaulters */

/* Higher KS means better separation and better model */
/* Sort predictions by predicted probability highest to lowest */

PROC SORT DATA = work.logistic_test_pred;
    BY DESCENDING P_1;
RUN;



/* Calculate cumulative percentages for defaulters and non-defaulters */

DATA work.ks_data;

    SET work.logistic_test_pred;
    RETAIN cum_bad 0 cum_good 0;

    total_bad  = 3008;
    total_good = 41992;

    IF default = 1 THEN cum_bad  + 1;
    ELSE                cum_good + 1;

    pct_bad  = cum_bad  / total_bad;
    pct_good = cum_good / total_good;

    ks = ABS(pct_bad - pct_good);

RUN;



/* Show the maximum KS value */
/* This is your headline model performance metric */

PROC MEANS DATA = work.ks_data MAX;

    VAR ks;
    TITLE "KS Statistic - Maximum Separation Between Defaulters and Non-Defaulters";

RUN;



/* STEP 9: BUILD THE CREDIT SCORECARD */
/* Convert predicted probabilities into credit scores */

/* Standard scorecard scaling formula */
/* PDO = 20 means the score increases by 20 points */
/* Every time the odds of being a good borrower double */
/* Base score of 600 at odds of 50:1 */

DATA work.scorecard;
    SET work.logistic_test_pred;

    LENGTH risk_band $ 15;

    pdo    = 20;
    factor = pdo / LOG(2);
    offset = 600 - factor * LOG(50);

    IF P_1 > 0 AND P_1 < 1 THEN
    credit_score = offset - factor * LOG(P_1 / (1 - P_1));

    IF credit_score < 300 THEN credit_score = 300;
    IF credit_score > 850 THEN credit_score = 850;

    IF      credit_score >= 750 THEN risk_band = "Very Low Risk";
    ELSE IF credit_score >= 650 THEN risk_band = "Low Risk";
    ELSE IF credit_score >= 550 THEN risk_band = "Medium Risk";
    ELSE IF credit_score >= 450 THEN risk_band = "High Risk";
    ELSE                             risk_band = "Very High Risk";

RUN;



/* View how many people fall into each risk band */

PROC FREQ DATA = work.scorecard;

    TABLES risk_band;
    TITLE "Distribution of Customers Across Risk Bands";

RUN;



/* View average credit score and default rate per risk band */
/* Default rate should increase as risk band gets worse */

PROC MEANS DATA = work.scorecard MEAN;

    CLASS risk_band;
    VAR credit_score default;
    TITLE "Average Credit Score and Default Rate by Risk Band";

RUN;



/* STEP 10: EXPORT RESULTS */
/* Save final scorecard to CSV for presentation in Excel */

PROC EXPORT
    DATA    = work.scorecard
    OUTFILE = "/home/u64174377/credit_risk/scorecard_results.csv"
    DBMS    = csv
    REPLACE;

RUN;
