*******************************************************************************;
**************** 80-character banner for column width reference ***************;
* (set window width to banner width to calibrate line length to 80 characters *;
*******************************************************************************;

* set relative file import path to current directory (using standard SAS trick);
X "cd ""%substr(%sysget(SAS_EXECFILEPATH),1,%eval(%length(%sysget(SAS_EXECFILEPATH))-%length(%sysget(SAS_EXECFILENAME))))""";

* load external file that will generate final analytic file;
%include '.\STAT697-01_s19-team-4_data_preparation.sas';


*******************************************************************************;
* Research Question Analysis Starting Point;
*******************************************************************************;
*
Question: What are the top ten districts that experienced the biggest increase 
and decrease in "Percent (%) Eligible Free (K-12)" between AY2015-16 and AY2016-17? 

Rationale: This should help identify school districts to consider for new 
outreach based upon increasing and decreasing child-poverty levels.

Note: This compares the column "Percent (%) Eligible Free (K-12)" from frpm1516 
to the column of the same name from frpm1617.

Limitations: Values of "Percent (%) Eligible Free (K-12)" equal to zero should
be excluded from this analysis, since they are potentially missing data values 
;


*******************************************************************************;
* Research Question Analysis Starting Point;
*******************************************************************************;
*
Question: Can "Percent (%) Eligible FRPM (K-12)" be used to predict the proportion 
of high school graduates earning a combined score of at least 1500 on the ACT? 

Rationale: This would help inform whether child-poverty levels are associated 
with students performance, and the policy could actually help those who are poverty 
and also want to pursue further study.

Note: This compares the column "Percent (%) Eligible Free (K-12)" from frpm1617 
to the column PCTGE1500 from act17.

Limitations: Values of "Percent (%) Eligible Free (K-12)" equal to zero should
be excluded from this analysis, since they are potentially missing data values,
and missing values of PctGE21 should also be excluded.
;


*******************************************************************************;
* Research Question Analysis Starting Point;
*******************************************************************************;
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
;

* calculate the first 10 school that the drop rate is lowest;
proc sql outobs=10;
    select
         School
        ,District
        ,Number_of_ACT_Takers /* NumTstTakr from act17 */
        ,Number_Dropout /* TTD from drop17 */
		,Number_Erollment/* TTE from drop17*/
        ,Number_Erollment - Number_Dropout
         AS Difference
        ,(calculated Difference)/Number_Erollment
         AS Percent_Difference format percent12.1
    from
        act_and_drop17_v2
    where
        Number_Erollment > 0
        and
        Number_Dropout > 0
    order by
        Difference desc
    ;
quit;
* calculate the first 10 school that the taking ACT rate is hight;
proc sql outobs=10;
    select
         School
        ,District
        ,Number_of_ACT_Takers /* NumTstTakr from act17 */
        ,Number_Dropout /* TTD from drop17 */
		,Number_Erollment/* TTE from drop17*/
        ,Number_Erollment - Number_of_ACT_Takers
         AS Difference
        ,(calculated Difference)/Number_Erollment
         AS Percent_Difference format percent12.1
    from
        act_and_drop17_v2
    where
        Number_Erollment > 0
        and
        Number_Dropout > 0
		and
        Number_of_ACT_Takers >0
    order by
        Difference desc
    ;
quit;
