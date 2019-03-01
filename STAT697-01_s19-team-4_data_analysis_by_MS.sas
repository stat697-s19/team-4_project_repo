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

*
Question: Does gender or ethnic category change the dropout rate?

Rationale:  There may be hidden biases that instructor and the administration 
needs to address with groups that have a higher dropout rate.

Note: A column for dropout rate (for each ethnicity) would be created with the 
ETOT(for each ethnicity) column and the DTOT (for each grade/ethnicity) column 
for each grade level from the dropouts17_raw dataset. 

Limitations: Values of 0 are common and some ethnic backgrounds have small 
values. Therefore, inferences on these small samples should be carefully 
applied. 
;

/*
This code finds the averages of male and female dropout rates per school. The 
standard deviation is also taken to check for differents in variance.
*/

title 'Female Average Dropout Rate by School';
proc sql;
	select 
		avg(droprate) as Average,	
		std(droprate) as SD
	from 
		analytical_merged
	where 
		gender = 'F'
	;run;

title 'Male Average Dropout Rate by School';
proc sql;
	select 
		avg(droprate) as Average,	
		std(droprate) as SD
	from 
		analytical_merged
	where 
		gender = 'M'
	;run;
title;
*Note that these are from school averages. In order to get the averages from
the total student population, the totals need to be summed up before rate is
calculated;


*******************************************************************************;
* Research Question Analysis Starting Point;
*******************************************************************************;

*
Question: Which grade has the highest rate of dropouts?
Rationale: By comparing the dropout rate, we can find see which grades are most 
vulnerable to dropping out, and direct more experienced teachers and resources 
to those grades.
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
	;run;

proc transpose 
	data = grade_levels
	out = grade_levels;
run;

title 'Mean Dropout by Grade';
proc gplot data = grade_levels;
	plot _name_*Col1;     
run;                                                                                                                                    
quit;
title;

*******************************************************************************;
* Research Question Analysis Starting Point;
*******************************************************************************;

*
Question: How does the rate of dropout compare to the rate of people with a
passing score on the act?

Rationale: This explores whether dropout is related to lack of understanding of
academic content, or if it is due to other factors. Performance on ACT can be 
a measure of a school's ability to drill certian skills, and without those, 
students may dropout.

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
	proc sql;
	    create table act_dropout as
	        select
	        coalesce(A.CDS,B.CDS_Code) as CDS_Code
			,coalesce(A.PctGE) as ActAvg
	        ,coalesce(B.droprate) as DropoutRate
			,coalesce(A.sname) as School
	        ,coalesce(A.dname) as District
	        from
	            act17 as A
	            full join
	            dropouts17 as B
	            on A.CDS=B.CDS_Code
			where droprate is not missing and pctge is not missing
		
	        order by
	            CDS_Code
	    ;
	quit;
	*/

	/*title 'Average for Schools Having Zero Dropouts';
	proc sql outobs=10;
	    select
			 avg(ActAvg) as avg,
			 std(ActAvg) as sd
	    from
	        act_dropout
		where DropoutRate =0
	  
	    ;
	quit;

	title 'Average for Schools Having Dropouts';
	proc sql outobs=10;
	    select
			 avg(ActAvg) as avg,
			 std(ActAvg) as sd
	    from
	        act_dropout
		where DropoutRate > 0.00001

	    ;
	quit;
	title;
	*/

*from using the analytical file, the same analysis is done as above;

data analytical_merged;
   set analytical_merged;
   droprate = DTOT / ETOT;
run;

/* 
In order to compare the different percentages of students who get good ACT 
scores, we can make two levels: schools that have zero and non-zero dropout
rates. The means of students with good ACT scores are found for these levels.
*/

title 'Average for Schools Having Zero Dropouts';
proc sql;
    select
		 avg(Percent_with_ACT_above_21) as avg,
		 std(Percent_with_ACT_above_21) as sd
    from
        analytical_merged
	where 
		droprate =0
    ;
quit;

title 'Average for Schools Having Dropouts';
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
title;

/*
Regression is done to compare the dropout rate with the percent of students 
who have an ACT score above 21 at each school.
*/

proc reg data = analytical_merged;
      model droprate = Percent_with_ACT_above_21;
   run;

/*
The regression results in a negative coefficient, that is significant. 
This confirms the stratification of Yes vs No dropouts result that higher
rates of ACT scores higher than 21 will result in less dropouts.

There are many schools that have not reported PctGE - the column 
that has the percent of students getting a score above 21 on the ACT
These queries show that the dopout rates are 0.133 for schools that
do not report pctGE and 0.010 for schools that do.
*/

proc sql;
    select
        mean(droprate) as Mean_for_missing_pctge
    from
        act17 as A
    full join
        dropouts17 as B
        on A.CDS=B.CDS_Code
	where 
		droprate is not missing and pctge is missing
;
quit;

proc sql;
    select
    	mean(droprate) as Mean_for_reported_pctge
    from
        act17 as A
    full join
        dropouts17 as B
        on A.CDS=B.CDS_Code
	where 
		droprate is not missing and pctge is not missing
    ;
quit; *try with proc means later;
