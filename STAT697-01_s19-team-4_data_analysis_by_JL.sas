*******************************************************************************;
**************** 80-character banner for column width reference ***************;
* (set window width to banner width to calibrate line length to 80 characters *;
*******************************************************************************;

* set relative file import path to current directory (using standard SAS trick);
X "cd ""%substr(%sysget(SAS_EXECFILEPATH),1,%eval(%length(%sysget
(SAS_EXECFILEPATH))-%length(%sysget(SAS_EXECFILENAME))))""";

* load external file that will generate "analytic file"dataset code_anlytic_file,
from which all data analyses below begin;
%include '.\STAT697-01_s19-team-4_data_preparation.sas';


*******************************************************************************;
* Research Question Analysis Starting Point;
*******************************************************************************;

title1 justify= left
'Question: What are the top ten school that experienced the biggest increase in "Percent (%) Eligible Free (K-12)" between AY2015-16 and AY2016-17?'
;
title2 justify= left
'Rationale: This should help identify school districts to consider for new outreach based upon increasing and decreasing child-poverty levels.'
;
footnote1 justify= left
'From the table, we can find that the range of the FRPM Eligibility Rate Percentage Point increase is 91.67%-62.5%.'
;
footnote2 justify= left
'We could easily find that the first one Camp Glenwood school had a very lower FRPM Eligibility Rate in AY2015-16, which caused the fast increase of FRPM Eligibility Rate.'
;
footnote3 justify= left
'We discover that the 6th school even has 68.89% increase Rate, while the factor is that the FRPM Eligibility of Rate of both AY2015 and AY 2016 are lower than other school.'
;
footnote4 justify= left
'Based on above analysis, we had better to consider if we should include the Camp Glenwood school and Rising Sun school or consider them as outliers in our further study.'
;

proc sql outobs=10;
	select 
		 School
		,District
		,Percent_Eligible_FRPM_K12_1516
		,Percent_Eligible_FRPM_K12_1617
		,FRPM_Percentage_Point_Increase
	from
		cde_analytic_file
	where 
	    Percent_Eligible_FRPM_K12_1516 >0
		and
		Percent_Eligible_FRPM_K12_1617 >0
	order by
		FRPM_Percentage_Point_Increase desc
	;
quit;


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

title1 justify= left
'Question: Can "Percent (%) Eligible FRPM (K-12)" be used to predict the number of students dropout? What’s the top ten schools were the number of high dropout?'
;
title2 justify= left
'Rationale: This would help identify whether child-poverty levels are associated with the number of high dropout students, if so, providing a strong indicator for the types of schools most in need of more help with the FRPM.'
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

*******************************************************************************;
* Research Question Analysis Starting Point;
*******************************************************************************;
title1 justify= left
'Question: What’s the top ten schools were the number of high dropout? and the corresponding number of ACT takers'?
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
	
*
Question: What’s the top ten schools were the number of high dropout? and 
the corresponding number of ACT takers'?

Rationale: This would help identify whether ACT are associated with the number 
of high dropout students, if so, providing a strong conformation for the 
negative relationship between the number of ACT taker and dropput students.

Note: This compares the column NUMTSTTAKR from act17 to the column TTD and TTE 
from drop17.

Limitations: Values of NUMTSTTAKR and TOTAL(DTOT) equal to zero should be excluded
from this analysis, since they are potentially missing data values.
;


