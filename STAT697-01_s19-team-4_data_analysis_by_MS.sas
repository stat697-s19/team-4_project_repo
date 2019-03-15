*******************************************************************************;
**************** 80-character banner for column width reference ***************;
* (set window width to banner width to calibrate line length to 80 characters *;
*******************************************************************************;

* set relative file import path to current directory (using standard SAS trick);
X "cd ""%substr(%sysget(SAS_EXECFILEPATH),1,%eval(%length(%sysget
(SAS_EXECFILEPATH))-%length(%sysget(SAS_EXECFILENAME))))""";

* load external file that will generate final analytic file;
%include '.\STAT697-01_s19_team_4_data_preparation.sas';

*******************************************************************************;
* Research Question Analysis Starting Point;
*******************************************************************************;

title1 justify=left 'Question: Does gender change the dropout rate?';

title2 justify=left 'Rationale:  There may be hidden biases that instructor and the administration needs to address with groups that have a higher dropout rate.';

title3;

*
Note: A column for dropout rate (for each ethnicity) would be created with the 
ETOT(for each ethnicity) column and the DTOT (for each ethnicity) column 
for each grade level from the dropouts17_raw dataset.

Limitations: Values of 0 are common and some ethnic backgrounds have small 
values. Therefore, inferences on these small samples should be carefully 
applied. These are from school averages. In order to get the averages from
the total student population, the totals need to be summed up before rate is
calculated

Methodology: Use proc report to show the average and standard deviation of the 
dropout rate by gender and then list the three schools with the highest dropout
rate using proc sql with outobs = 3.

Followup Steps: Compare the top schools from subsequent and following years to 
determine if performance is changing or if interventions are effective/needed.
;

data analytical_merged;
    set analytical_merged;
    droprate = DTOT / ETOT;
run;

title4 'Dropout Rate by Gender'; 
footnote '';
proc report 
    data=analytical_merged
    (keep=droprate gender);
    column droprate gender;
    define gender / group width=13
        'Gender';
    define droprate / mean format=best8.7
        'Average Dropout Rate' width=11;
run;
title;
footnote;

title 'Standard Deviation by Gender';
footnote 'Males have a higher dropout rate on average, and variances between schools are similar.';
proc report 
    data=analytical_merged
    (keep=droprate gender);
    column droprate gender;
    define gender / group width=10
        'Gender';
    define droprate / analysis std format=best8.7
        'Standard Deviation' width =11;
run;
title;
footnote;

title 'Top Schools for Overall Dropout';
footnote 'These are the top 3 schools (in order) having the highest dropout rate';
proc sql outobs = 3;
    select
        School label 'Schools With Highest Dropout'
    from 
        analytical_merged
    where 
        droprate <1
    order by 
        droprate desc
;
quit;
title;
footnote;


*******************************************************************************;
* Research Question Analysis Starting Point;
*******************************************************************************;

title1 justify=left 'Question: Which grade has the highest rate of dropouts?';

title2 justify=left 'Rationale: By comparing the dropout rate, we can find see which grades are most vulnerable to dropping out, and direct more experienced teachers, counseling and resources to those grades.';

title3;

*
Note: A column for dropout rate (for each grade level) would be created by with 
the E(grade) column and the D(grade) column for each grade level from the 
dropouts17_raw dataset. 

Limitations: If any values of enrollment are zero where dropout is not zero, 
there will be an error in calculating dropout rate, so all rows that have 
greater dropout than enrollment would need to be deleted.

Methodology: Use proc sql and proc transpose to create a dataset that contains
the dropout rate and grade of students. This format is needed in order to use
proc sgplot, which compares the dropout rate of different schools.

Followup Steps: Replace the data step with calculated proc sql steps in order
to call the data more efficiently and free up memory.
;

data analytical_merged;
    set analytical_merged;
        drop7 = D7 / E7;
        drop8 = D8 / E8;
        drop9 = D9 / E9;
        drop10 = D10 / E10;
        drop11 = D11 / E11;
        drop12 = D12 / E12;
run;

proc sql;
create table grade_levels as 
    select 
        avg(drop7) as Seventh,
        avg(drop8) as Eighth,
        avg(drop9) as Ninth,
        avg(drop10) as Tenth,
        avg(drop11) as Eleventh,
        avg(drop12) as Twelfth
    from 
        analytical_merged
;
quit;

proc transpose 
    data = grade_levels
    out = grade_levels;
run;

title4 'Mean Dropout by Grade';
footnote 'Dropout rate is highest at later years of students education.';
proc sgplot 
    data = grade_levels;
    scatter 
        x=_name_ 
        y=Col1;
    xaxis label = 'Grade Level';
    yaxis label = 'Dropout Rate';
run;
footnote;
title;

*******************************************************************************;
* Research Question Analysis Starting Point;
*******************************************************************************;


title1 justify=left 'Question: How does the rate of dropout compare to the rate of people with a passing score on the act?';

title2 justify=left "Rationale: This explores whether dropout is related to lack of understanding of academic content, or if it is due to other factors. Performance on ACT can be a measure of a school's ability to drill certian skills, and without those, students may dropout.";

title3;

*
Note: The columns used will D7-D12(summed), E7-E12(summed) from the 
dropouts17_raw table and the PctGE21 column on the act17_raw table. This 
association can also be looked at in the top and bottom performing schools, 
which are very important because they can serve as good and models.

Limitations: There are many null values in the PctGE21 in the act17 table. 
These values correspond with schools that may not perform well. An additional 
analysis should be done on schools that have null values in this column. They 
won't be done in the primary analysis because they need to be filtered out. 

Methodology: In order to compare the different percentages of students who get 
good ACT scores, two levels are made, each with a proc sql statement with a 
different where clause: schools that have zero and non-zero dropout rates. The 
means and standard deviations of students with good ACT scores are found for 
these levels. Regression is done with proc reg to compare the dropout rate with
the percent of students who have an ACT score above 21 at each school. Use
proc sql to compare mean dropout rate from schools who do not have values for
Percent_with_ACT_above_21 reported.

Followup steps: Attempt to transform the data to be more normal in order to 
make an accurate regression model that can be used to do more than describe the
trend, but can make predictions. 
;

title4 'Average for Schools Having Zero Dropouts';
proc sql;
    select
        avg(Percent_with_ACT_above_21) as Average,
        std(Percent_with_ACT_above_21) as SD
    from
        analytical_merged
    where 
        droprate = 0
;
quit;
footnote;
title;

title 'Average for Schools Having Dropouts';
footnote 'Percent of ACT scores above 21 are lower in schools reporting dropouts';
proc sql;
    select
        avg(Percent_with_ACT_above_21) as Average,
        std(Percent_with_ACT_above_21) as SD
    from
        analytical_merged
    where 
        droprate > 0.00001
;
quit;
footnote;
title;

/*
Regression analysis
*/

footnote 'The regression results in a negative coefficient, which is significant. This confirms the stratification of Yes vs No dropouts result: higher rates of ACT scores greater than 21 will result in fewer dropouts. However, this model should not be used for prediction because the r-squared value is very low, meaning that most of the variance is not explained by this model. It also would assume that the data is distributed normally';
proc reg
    data = analytical_merged;
    model droprate = Percent_with_ACT_above_21;
run;
footnote;

title 'Mean Dropout - Schools Not Reporting ACT'; 
footnote'';
proc sql;
    select
        mean(droprate) as Mean_for_missing_pctge
    from
        analytical_merged
    where 
        droprate is not missing 
        and Percent_with_ACT_above_21 is missing
;
quit;
title;

title 'Mean Dropout - Schools Reporting ACT';
footnote'There are many schools that have not reported PctGE - the column that has the percent of students getting a score above 21 on the ACT. These queries show that the dropout rates are 0.133 for schools that do not report pctGE and 0.010 for schools that do.';
proc sql;
    select
        mean(droprate) as Mean_for_reported_pctge
    from
        analytical_merged
    where 
        droprate is not missing 
        and Percent_with_ACT_above_21 is not missing
;
quit;
title;
footnote;
