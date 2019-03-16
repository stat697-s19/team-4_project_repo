*******************************************************************************;
**************** 80-character banner for column width reference ***************;
* (set window width to banner width to calibrate line length to 80 characters *;
*******************************************************************************;

* set relative file import path to current directory (using standard SAS trick);
X "cd ""%substr(%sysget(SAS_EXECFILEPATH),1,%eval(%length(%sysget(SAS_EXECFILEPATH))-%length(%sysget(SAS_EXECFILENAME))))""";

* load external file that will generate "analytic file"dataset code_anlytic_file,
from which all data analyses below begin;
%include '.\STAT697-01_s19-team-4_data_preparation.sas';


*******************************************************************************;
* Research Question Analysis Starting Point;
*******************************************************************************;

title1 justify= left
'Question: What are the top ten schools that experienced the biggest increase in "Percent (%) Eligible Free (K-12)" between AY2015-16 and AY2016-17?'
;
title2 justify= left
'Rationale: This should help identify school districts to consider for new outreach based upon increasing and decreasing child-poverty levels.'
;
footnote1 justify= left
'From the table, we can find that the range of the FRPM Eligibility Rate Percentage Point increase is 62.5%-91.67%.'
;
footnote2 justify= left
'We could easily find that the top one, Camp Glenwood school, has a lower FRPM Eligibility Rate in AY2015-16, which caused the fast increase of FRPM Eligibility Rate.'
;
footnote3 justify= left
'We discover that the 6th school even has 68.89% increase Rate, while the factor is that the FRPM Eligibility of Rate of both AY2015-16 and AY2016-17 are lower than other schools.'
;
footnote4 justify= left
'Based on above analysis, it is better to consider if we should include the Camp Glenwood school and Rising Sun school in our further study and consider them as outliers.'
;


*
Note: This compares the column "Percent (%) Eligible Free (K-12)" from frpm1516
to the column of the same name from frpm1617.

Limitations: Values of "Percent (%) Eligible Free (K-12)" equal to zero should
be excluded from this analysis, since they are potentially missing data values

Methodology: Use proc sort to create a temporary sorted table in descending
order by FRPM_Percentage_Point_Increase, with ties broken by school name. Then
use proc report to print the first ten rows of the sorted dataset.

Followup Steps: More carefully clean values in order to filter out any possible
illegal values, and better handle missing data and outliers, e.g., by using a
previous year's data or a rolling average of previous years' data as a proxy.
;


*sort by increase in FRPM Eligibility Rate, removing all schools with missing
or invalid values for FRPM Eligibility Rates in AY2015 and AY2016;
proc sort
    data =cde_analytic_file
    out=cde_anlytic_file_by_FRPM_Incr
    ;
    by
        descending FRPM_Percentage_point_Increase
        School
    ;
    where
        Percent_Eligible_FRPM_K12_1516 >0
        and
        Percent_Eligible_FRPM_K12_1617 >0
    ;
run;
* output first ten rows of resulting sorted data, addressing research question;
proc report data=cde_anlytic_file_by_FRPM_Incr(obs=10);
    columns
        School
        District
        Percent_Eligible_FRPM_K12_1516
        Percent_Eligible_FRPM_K12_1617
        FRPM_Percentage_point_Increase
    ;
run;

* clear titles/footnotes;
title;
footnote;

title1
'Plot top ten schools that experienced the biggest increase in "Percent (%) Eligible Free (K-12)" between AY2015-16 and AY2016-17'
;

footnote1
"In the above plot, we can see the top 1 school is much higher than other 9 schools, and we should consider if treat it as outliers."
;

proc sgplot data=cde_anlytic_file_by_FRPM_Incr(obs=10);
    vbar School/ RESPONSE= FRPM_Percentage_point_Increase
    CATEGORYORDER=RESPDESC 
    ;
run;

* clear titles/footnotes;
title;
footnote;


*******************************************************************************;
* Research Question Analysis Starting Point;
*******************************************************************************;

title1 justify= left
'Question: Can "Percent (%) Eligible FRPM (K-12)" be used to predict the number of students dropout? What is the top ten schools were the number of high dropout?'
;
title2 justify= left
'Rationale: This would help identify whether child-poverty levels are associated with the number of high dropout students, if so, providing a strong indicator for the types of schools are most in need of more help with the FRPM.'
;
footnote1 justify= left
'Actually, we can find the the p-value of the regression is <0.0001, which is significant to draw the conclusion that there is a correlation between the two vaiables, and it is negative relationship which is -0.866'
;
footnote2 justify= left
'The meaning of the relationship is that the good performance of student in ACT and the good of the economy condition of the student.'
;
footnote3 justify= left
'It show that the economy factor would play a crucial role in study performance of students.'
;

*
Note: This compares the column "Percent (%) Eligible Free (K-12)" from frpm1617
to the column PCTGE21 from act17.

Limitations: Values of "Percent (%) Eligible Free (K-12)" equal to zero should
be excluded from this analysis, since they are potentially missing data values,
and missing values of PctGE21 should also be excluded.

Methodology: Use proc corr to perform a correlation analysis, and then use proc
sgplot to output a scatterplot, illustrating the correlation present.

Followup Steps: A possible follow-up to this approach could use a more formal
inferential technique like linear regression, which could be used to determine
more than the existence of a linear relationship.
;

proc corr
    data = cde_analytic_file
    nosimple
    ;
    var
        Percent_Eligible_FRPM_K12_1617
        Percent_with_ACT_above_21
    ;
    where
        not(missing(Percent_Eligible_FRPM_K12_1617))
        and
        not(missing(Percent_with_ACT_above_21))
    ;
run;

* clear titles/footnotes;
title;
footnote;



title1
'Plot illustrating the negative correlation between Percent_Eligible_FRPM_K12_1617 and Percent_with_ACT_above_21'
;

footnote1
"In the above plot, we can see how values of Percent_with_ACT_above_21 tend to decrease as values of Percent_Eligible_FRPM_K12_1617."
;

proc sgplot data=cde_analytic_file;
    scatter
        x=Percent_Eligible_FRPM_K12_1617
        y=Percent_with_ACT_above_21
    ;
run;

* clear titles/footnotes;
title;
footnote;



*******************************************************************************;
* Research Question Analysis Starting Point;
*******************************************************************************;
title1 justify= left
'Question: Can "Percent (%) Eligible FRPM (K-12)" be used to predict the number of students dropout?'
;
title2 justify= left
'Rationale: This would help identify whether child-poverty levels are associated with the number of high dropout students, if so, providing a strong indicator for the types of schools most in need of more help with the FRPM.'
;
footnote1 justify= left
'Actually, we can find the the p-value of the regression is <0.0001, which is significant to draw the conclusion that there is a correlation between the two vaiables, and it is positive relationship which is 0.17033'
;
footnote2 justify= left
'The meaning of the relationship is that students would have more possible to drop out school when the student is in poor economy condition .'
;
footnote3 justify= left
'Above two researcher questions show that the economy factor would play a crucial role in study performance of students and even in dropout possible.'
;


*
Note: This compares the column NUMTSTTAKR from act17 to the column TTD and TTE
from drop17.

Limitations: Values of NUMTSTTAKR and TOTAL(DTOT) equal to zero should be excluded
from this analysis, since they are potentially missing data values.

Methodology: Use proc corr to perform a correlation analysis, and then use proc
sgplot to output a scatterplot, illustrating the correlation present.

Followup Steps: Unlike above relationship, from the plot we find the relationship is
not so strong as the we expected. A possible follow-up to this approach could use is
a detailed technique such as R square to check if the relationship is actually
existed, and if it is linear regression.
;


proc corr
    data = cde_analytic_file
    nosimple
    ;
    var
        Percent_Eligible_FRPM_K12_1617
        Rate_of_Dropout
    ;
    where
        not(missing(Percent_Eligible_FRPM_K12_1617))
        and
        not(missing(Rate_of_Dropout))
;
run;
* clear titles/footnotes;
title;
footnote;


title1
'Plot illustrating the positive correlation between Percent_Eligible_FRPM_K12_1617 and Rate_of_Dropout'
;

footnote1
"In the above plot, we can see there is not very strong increase Rate_of_Dropout with Percent_Eligible_FRPM_K12_1617 increase as above plot, maybe because of the correlation is 0.17"
;

proc sgplot data=cde_analytic_file;
    scatter
        x=Percent_Eligible_FRPM_K12_1617
        y=Rate_of_Dropout
    ;
run;
* clear titles/footnotes;
title;
footnote;


*
Question: Can "Percent (%) Eligible FRPM (K-12)" be used to predict the number
of students dropout? What’s the top ten schools were the number of high dropout?

Rationale: This would help identify whether child-poverty levels are associated
with the number of high dropout students, if so, providing a strong indicator
for the types of schools most in need of more help with the FRPM.

Note: This compares the column NUMTSTTAKR from act17 to the column TTD and TTE
from drop17.

Limitations: Values of NUMTSTTAKR and TOTAL(DTOT) equal to zero should be excluded
from this analysis, since they are potentially missing data values.

Methodology: Use proc corr to perform a correlation analysis, and then use proc
sgplot to output a scatterplot, illustrating the correlation present.

Followup Steps: Unlike above relationship, from the plot we find the relationship is
not so strong as the we expected. A possible follow-up to this approach could use is
a detailed technique such as R square to check if the relationship is actually
existed, and if it is linear regression.
;


* clear titles/footnotes;
title;
footnote;


*******************************************************************************;
* Research Question Analysis Starting Point;
*******************************************************************************;
title1 justify= left
'Question: What is the top ten schools were the number of high dropout? and the corresponding number of ACT takers?'
;
title2 justify= left
'Rationale: This would help identify whether ACT are associated with the number of high dropout students, if so, providing a strong conformation for the negative relationship between the number of ACT taker and dropput students.'
;
footnote1 justify= left
'From the table, we can find that there is no students taking ACT for the top 10 schools which were high dropout rate'
;
footnote2 justify= left
'This information strongly proof that the more students dropout from school the less number of students taking ACT test, the result is the same with our common sense.'
;
footnote3 justify= left
'This table also indicates that maybe there is threshold line such as once the droprate reaches a point then no student would take the ACT, then it makes sense why the above plot does not show strong increase trend.'
;

*
Question: What is the top ten schools were the number of high dropout? and
the corresponding number of ACT takers'?

Rationale: This would help identify whether ACT are associated with the number
of high dropout students, if so, providing a strong conformation for the
negative relationship between the number of ACT taker and dropput students.

Note: This compares the column NUMTSTTAKR from act17 to the column TTD and TTE
from drop17.There is maybe a warning message:"WARNING: Statement terminated early 
due to OUTOBS=10 option." in log because of outobs= 10 code, you do not need to 
worry about it.

Limitations: Values of NUMTSTTAKR and TOTAL(DTOT) equal to zero should be excluded
from this analysis, since they are potentially missing data values.

Methodology: Use proc sort to create a temporary sorted table in descending
order by Course_Completers_Gap_Count, with ties broken by school name. Then
use proc report to print the first ten rows of the sorted dataset.

Followup Steps: More carefully clean values in order to filter out any possible
illegal values, and better handle missing data, e.g., by using a previous year's
data or a rolling average of previous years' data as a proxy.
;

* calculate the first 10 school that the drop rate is lowest;

proc sql outobs=10;
    select
         School
        ,District
        ,Number_of_ACT_Takers/* NumTstTakr from act17 */
        ,Number_of_Total_Dropout /* TTD from drop17 */
        ,Number_of_Total_Enrollment/* TTE from drop17*/
        ,Number_of_Total_Remain
        ,Rate_of_Remain
        ,Rate_of_Dropout
    from
        cde_analytic_file
    where
        Number_of_Total_Enrollment > 0
        and
        Number_of_Total_Dropout > 0
        and
        Number_of_Total_Remain >0
     order by
        Rate_of_Dropout desc
    ;
quit;

* clear titles/footnotes;
title;
footnote;


