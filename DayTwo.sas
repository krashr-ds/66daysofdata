/* SAS Program: Day 1
  Compute Measures of Central Tendency, Heart Data Set
  Perform Power Analysis and Hypothesis Testing for:
    1. Pearsons R Correlation of Age vs. Chol with Outliers Removed
    2. Student T-Test of Males vs. Females, Mean BP Readings         */

/* SAVE MEDIAN & IQR FOR OUTLIER REMOVAL */
ods select none;
proc univariate data = WORK.HEART;
var chol;
output out=boxStats median=median qrange = iqr;
run; 

data _null_;
	set boxStats;
	call symput ('median',median);
	call symput ('iqr', iqr);
run; 

%put &median;
%put &iqr;

data HEART_TRIMMED;
set WORK.HEART;
    if (chol le &median + 1.5 * &iqr) and (chol ge &median - 1.5 * &iqr); 
run; 

DATA MALES;
SET HEART;
IF sex = 1;
RUN;

DATA FEMALES;
SET HEART;
IF sex = 0;
RUN;
ods select all;

title 'Age and Cholesterol';
ods select BasicMeasures Quantiles;
proc univariate data=HEART_TRIMMED;
   var age chol;
run;

title 'Males - Resting Blood Pressure (mmHg)';
ods select BasicMeasures Quantiles;
proc univariate data=WORK.MALES;
   var trtbps;
run;

title 'Females - Resting Blood Pressure (mmHg)';
ods select BasicMeasures Quantiles;
proc univariate data=WORK.FEMALES;
   var trtbps;
run;

ods graphics on;
ods select all;
title 'Power for Pearson Correlation - Age vs. Chol';
proc power;
   onecorr dist=fisherz
      npvars = 6
      corr = 0.35
      nullcorr = 0.0
      sides = 1
      ntotal = 289
      power = .;
run;


proc corr data=HEART_TRIMMED nosimple nocorr fisher plots=all;
   var age chol;
run;

/* There is a weak positive significant correlation between age and chol after outlier removal */

title 'Power for Two-Sample T-Test with Different Variances - Males v. Females Mean BP Reading (mmHg)';
proc power;
   twosamplemeans ci = diff
   halfwidth = 3
   stddev = 22
   groupns = (207 96)
   probwidth = .;
run;

proc ttest data=WORK.HEART sides=2 alpha=0.001 h0=0;
 	title "Two Sample T-Test - Males v. Females Mean BP Reading (mmHg)";
 	class sex;
	var trtbps;
run;
ods graphics off;

/* There is no significant difference between males and females in mean BP reading. */

