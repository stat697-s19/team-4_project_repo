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
Limitations: There are many null values in the PctGE21 in the act17 table. These 
values correspond with schools that may not perform well. An additional analysis 
should be done on schools that have null values in this column. They won't be 
done in the primary analysis because they need to be filtered out. 
;

*here, I made a column that has the total dropout rate;
data dropouts17;
   set dropouts17;
   droprate = DTOT / ETOT;
run;

/*the data preparation file is repeated in order to include the new column for 
the dropout rate in the analysis*/

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

/* Now that the data is merged, we can look at the results. We can make levels 
of  performance, starting with schools that have no dropouts */

*no dropouts;

title 'Average for Schools Having Zero Dropouts';
proc sql outobs=10;
    select
		 avg(ActAvg) as avg,
		 std(ActAvg) as sd
    from
        act_dropout
	where DropoutRate =0
  
    ;
quit;


*yes dropouts;
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
/*we see that there is, on average,4 more percent of students that pass get 
higher than 21 on the ACT in schools that have no students dropping out. 
Also, the variances are very close in value*/


/* In order to better understand the relationship between dropout rate and 
act average scores, a regression analysis can be done with droupout rate 
as the response variable and act average as the predictor */



proc reg data = act_dropout;
      model DropoutRate = ActAvg;
   run;

/*The regression results in a negative coefficient, that is significant. 
This confirms the stratification of Yes vs No dropouts result that higher
rates of ACT scores higher than 21 will result in less dropouts.*/

/*There are many schools that have not reported PctGE - the column 
that has the percent of students getting a score above 21 on the ACT
These queries show that the dopout rates are 0.133 for schools that
do not report pctGE and 0.010 for schools that do.*/

proc sql;
        select
        mean(droprate) as Mean_for_missing_pctge
        from
            act17 as A
            full join
            dropouts17 as B
            on A.CDS=B.CDS_Code
		where droprate is not missing and pctge is missing
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
		where droprate is not missing and pctge is not missing
    ;
quit;
