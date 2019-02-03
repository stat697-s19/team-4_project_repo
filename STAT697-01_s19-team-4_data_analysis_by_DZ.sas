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
  Question: Will age group affect student get a free meal or eligible free precents? 
    Rationale: Schools may pay attention to the nutrition and food intake of students of different ages.So considering the cost, age may affect the percentage of free meal distribution.
    Note: This compares the column "Percent (%) Eligible Free (K-12),Free meal(k-12),Percent (%) Eligible Free (age5-17),Free meal(5-17)" from frpm1516
  to the column of the same name from frpm1617.
  ;
   
    *******************************************************************************;
  * Research Question Analysis Starting Point;
  *******************************************************************************;
  *
  Question: How many schools have had percent Eligible is increase in 2015-2017?
    Rationale:An analysis of whether the percent Eligible has increased helps to understand whether poverty has improved over the years.  
    Note: Compare the percentages of two years to calculate the number of schools 
  ;
  *******************************************************************************; 
 * Research Question Analysis Starting Point; 
 *******************************************************************************; 
 * 
 Question:Does race have a big impact on dropout rates?  
   Rationale: Because different races have different numbers of students in schools, this may affect the students'groups, some students will be left out of school, thus affecting the dropout rate. 
   Note: Complete the analysis by comparing the dropout rates of different people in different grades
 ;  
