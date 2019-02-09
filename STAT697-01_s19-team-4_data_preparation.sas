*******************************************************************************;
**************** 80-character banner for column width reference ***************;
* (set window width to banner width to calibrate line length to 80 characters *;
*******************************************************************************;

* 
[Dataset 1 Name] frpm1516

[Dataset Description] Student Poverty Free or Reduced Price Meals (FRPM) Data, AY2015-16

[Experimental Unit Description] California public K-12 schools in AY2015-16

[Number of Observations] 10,453
                    
[Number of Features] 28

[Data Source] The file http://www.cde.ca.gov/ds/sd/sd/documents/frpm1516.xls
was downloaded and edited to produce file frpm1415-edited.xls by deleting
worksheet "Title Page", deleting row 1 from worksheet "FRPM School-Level Data",
reformatting column headers in "FRPM School-Level Data" to remove characters
disallowed in SAS variable names, and setting all cell values to "Text" format


[Data Dictionary] http://www.cde.ca.gov/ds/sd/sd/fsspfrpm.asp

[Unique ID Schema] The columns "County Code", "District Code", and "School Code"
form a composite key, which together are equivalent to the unique id column CDS_CODE 
in dataset dropouts17, and which together are also equivalent to the unique id 
column CDS in dataset act17.



;
%let inputDataset1DSN = frpm1516_raw;
%let inputDataset1URL =
https://github.com/stat697/team-4_project_repo/blob/master/data/frpm1516_edited.xls?raw=true
;
%let inputDataset1Type = XLS;


*
[Dataset 2 Name] frpm1617

[Dataset Description] Student Poverty Free or Reduced Price Meals (FRPM) Data, AY2016-17

[Experimental Unit Description] California public K-12 schools in AY2016-17

[Number of Observations] 10,478
                    
[Number of Features] 28

[Data Source] The file http://www.cde.ca.gov/ds/sd/sd/documents/frpm1617.xls
was downloaded and edited to produce file frpm1415-edited.xls by deleting
worksheet "Title Page", deleting row 1 from worksheet "FRPM School-Level Data",
reformatting column headers in "FRPM School-Level Data" to remove characters
disallowed in SAS variable names, and setting all cell values to "Text" format
[Data Dictionary] http://www.cde.ca.gov/ds/sd/sd/fsspfrpm.asp

[Unique ID Schema] The columns "County Code", "District Code", and "School Code" form 
a composite key, which together are equivalent to the unique id column CDS_CODE in dataset 
dropouts17, and which together are also equivalent to the unique id column CDS in dataset 
act17.


;
%let inputDataset2DSN = frpm1617_raw;
%let inputDataset2URL =
https://github.com/stat697/team-4_project_repo/blob/master/data/frpm1617_edited.xls?raw=true
;
%let inputDataset2Type = XLS;


*
[Dataset 3 Name] dropouts17

[Dataset Description] Grade seven through twelve dropouts and enrollment by race/ethnic 
designation and gender by school, AY2016-17

[Experimental Unit Description] California public K-12 schools in AY2016-17

[Number of Observations] 59,599                    
[Number of Features] 20

[Data Source] The file
http://dq.cde.ca.gov/dataquest/dlfile/dlfile.aspx?cLevel=School&cYear=2016-17&cCat=Dropouts&cPage=filesdropouts
was downloaded and edited to produce file gradaf15.xls by importing into Excel
and setting all cell values to "Text" format

[Data Dictionary] https://www.cde.ca.gov/ds/sd/sd/fsdropouts.asp
[Unique ID Schema] The column CDS_CODE is a unique id.

;
%let inputDataset3DSN = dropouts17_raw;
%let inputDataset3URL =
https://github.com/stat697/team-4_project_repo/blob/master/data/dropouts17.xls?raw=true
;
%let inputDataset3Type = XLS;


*
[Dataset 4 Name] act17

[Dataset Description] ACT Test Results, AY2016-17

[Experimental Unit Description] California public K-12 schools in AY2016-17

[Number of Observations] 2,252                    
[Number of Features] 16

[Data Source] The file http://www3.cde.ca.gov/researchfiles/satactap/act17.xls
was downloaded and edited to produce file act17-edited.xls by opening in Excel
and setting all cell values to "Text" format

[Data Dictionary] https://www.cde.ca.gov/ds/sp/ai/reclayoutact17.asp
[Unique ID Schema] The column CDS is a unique id.

;
%let inputDataset4DSN = sat15_raw;
%let inputDataset4URL =
https://github.com/stat697/team-4_project_repo/blob/master/data/act17_edited.xls?raw=true
;
%let inputDataset4Type = XLS;


* load raw datasets over the wire, if they doesn't already exist;
%macro loadDataIfNotAlreadyAvailable(dsn,url,filetype);
    %put &=dsn;
    %put &=url;
    %put &=filetype;
    %if
        %sysfunc(exist(&dsn.)) = 0
    %then
        %do;
            %put Loading dataset &dsn. over the wire now...;
            filename
                tempfile
                "%sysfunc(getoption(work))/tempfile.&filetype."
            ;
            proc http
                method="get"
                url="&url."
                out=tempfile
                ;
            run;
            proc import
                file=tempfile
                out=&dsn.
                dbms=&filetype.;
            run;
            filename tempfile clear;
        %end;
    %else
        %do;
            %put Dataset &dsn. already exists. Please delete and try again.;
        %end;
%mend;
%macro loadDatasets;
    %do i = 1 %to 4;
        %loadDataIfNotAlreadyAvailable(
            &&inputDataset&i.DSN.,
            &&inputDataset&i.URL.,
            &&inputDataset&i.Type.
        )
    %end;
%mend;
%loadDatasets


*******************************************************************************;
**************DATA CLEANING AND EDA FOR ACT17_RAW DATASET**********************;
*******************************************************************************;
*the columns in this dataset are: cds, ccode, cdcode, scode, rtype, sname, 
dname, cname, Enroll12, NumTstTakr, AvgScrEng, AvgScrRead, AvgScrMath, 
AvgScrSci, NumGE21, PctGE21;
*check what datatype the columns are in and then convert to numeric for 
the relevant columns;
proc contents data = act17_raw;
run;
data act17_raw; set act17_raw;
    NumEnroll = input(Enroll12, best8.); * Convert character to numeric;
	NumTak = input(NumTstTakr, best12.);
	AvgEng = input(AvgScrEng, best12.);
	AvgRead = input(AvgScrRead, best12.);
    AvgMath = input(AvgScrMath, best12.);
	AvgSci = input(AvgScrSci, best12.);
	NumGE = input(NumGE21, best12.);
	PctGE = input(PctGE21, best12.);
run;
proc contents data=act17_raw;
run;

* check act17_raw for bad unique id values, where the column CDS is intended
to be a primary key;
proc sql;
    /* check for unique id values that are repeated, missing, or correspond to
       non-schools;
        */
proc sql;
select count(distinct cds) as cds_count_id
    from act17_raw;
/*here we see that the amount of unique id's are equal to the number of rows, 
(both equal 2252)so the all the cds values are unique*/

    create table act17_unusual_ids as
        select
            ACT.*
        from
            act17_raw as ACT
            left join
            (
                select
                     cds
                    ,count(*) as row_count_id
                from
                    act17_raw
                group by
                    cds
            ) as B
            on ACT.cds=B.cds
        having
            /* capture rows corresponding to repeated primary key values */
            row_count_id > 1
            or
            /* capture rows corresponding to missing primary key values */
            missing(cds)
            or
            /* capture rows corresponding to non-school primary key values */
            substr(CDS,8,7) in ("00000000000000","01000000000000")
		order by cds
    ;

	/*from visual inspection of this table, there are some values of 
	enrollment that are far beyond the limit of most schools*/



    /* removing rows in which schools are too large(greater than 10000 people).
	we can be sure the new dataset act17 will have no made up schools, and all 
	unique id values can serve as a primary key as schools */
    create table act17 as
        select
            *
        from
	    act17_raw
	where NumEnroll <10000
	   
    ;
quit;

*This is a table with means, standard deviations, n, min, and max for 
the numeric variables;
title "Inspect Means of Numerical Variables in act17";
proc means data = act17_raw;
var NumEnroll NumTak AvgEng AvgRead AvgMath AvgSci NumGE PctGE;
run;
title;

*here is a table that gets the average math scores from schools in each;
title "Inspect Average Math Scores per County in act17";
proc sql;
	select ccode, avg(AvgMath) as avgmath
	from act17_raw
	group by ccode;
  title;
