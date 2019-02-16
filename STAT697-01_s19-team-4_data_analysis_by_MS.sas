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
Question: Does gender or ethnic category change this?

Rationale:  There may be hidden biases that instructor and the administration 
needs to address with groups that have a higher dropout rate.

Note: A column for dropout rate (for each gender/ethnicity) would be created 
with the E(for each grade/ethnicity) column and the D
(for each grade/ethnicity) column for each grade level from the dropouts17_raw
dataset. 
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
;
