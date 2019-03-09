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
;

data analytical_merged;
    set analytical_merged;
    droprate = DTOT / ETOT;
run;

/*
This code finds the averages of male and female dropout rates per school. The 
standard deviation is also taken to check for differents in variance.
*/

title4 'Female Average Dropout Rate by School'; footnote '';
proc sql;
	select 
		avg(droprate) as Average,	
		std(droprate) as SD
	from 
		analytical_merged
	where 
		gender = 'F'
	;
title;
footnote;

title 'Male Average Dropout Rate by School';
footnote 'Males have a slightly higher dropout rate on average, but females have a much higher variance between schools.';
proc sql;
	select 
		avg(droprate) as Average,	
		std(droprate) as SD
	from 
		analytical_merged
	where 
		gender = 'M'
	;

title 'Top Schools for Female Dropout';
footnote 'These are the top 3 schools (in order) contributing most to female dropout';
proc sql outobs = 3;
	select
		School
	from 
		analytical_merged
	where 
		gender = 'F' 
		and droprate <1
	order by 
		droprate desc
	;
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
;

/*
The code creates dropout rates for different grade levels in a new table by 
making calculated columns. The data is then tranposed in order to be graphed.
*/

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
;

/* 
In order to compare the different percentages of students who get good ACT 
scores, we can make two levels: schools that have zero and non-zero dropout
rates. The means of students with good ACT scores are found for these levels.
*/

title4 'Average for Schools Having Zero Dropouts';
proc sql;
    select
		 avg(Percent_with_ACT_above_21) as avg,
		 std(Percent_with_ACT_above_21) as sd
    from
        analytical_merged
	where 
		droprate = 0
    ;
quit;
title;

title 'Average for Schools Having Dropouts';
footnote 'Percent of ACT scores above 21 are lower in schools reporting dropouts';
proc sql;
    select
		 avg(Percent_with_ACT_above_21) as avg,
		 std(Percent_with_ACT_above_21) as sd
    from
        analytical_merged
	where 
		droprate > 0.00001
    ;
quit;
footnote;
title;

/*
Regression is done to compare the dropout rate with the percent of students 
who have an ACT score above 21 at each school.
*/

footnote 'The regression results in a negative coefficient, which is significant. This confirms the stratification of Yes vs No dropouts result: higher rates of ACT scores greater than 21 will result in fewer dropouts. However, this model should not be used for prediction because the r-squared value is very low, meaning that most of the variance is not explained by this model. It also would assume that the data is distributed normally';
proc reg 
    data = analytical_merged;
    model droprate = Percent_with_ACT_above_21;
run;
footnote;
title;

title'Mean Dropout - Schools Not Reporting ACT'; footnote'';
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

title'Mean Dropout - Schools Reporting ACT';
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
