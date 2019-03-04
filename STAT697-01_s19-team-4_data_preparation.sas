
*******************************************************************************;
**************** 80-character banner for column width reference ***************;
* (set window width to banner width to calibrate line length to 80 characters *;
*******************************************************************************;

*
[Dataset 1 Name] frpm1516

[Dataset Description] Student Poverty Free or Reduced Price Meals (FRPM) Data,
AY2015-16

[Experimental Unit Description] California public K-12 schools in AY2015-16

[Number of Observations] 10,453

[Number of Features] 28

[Data Source] The file http://www.cde.ca.gov/ds/sd/sd/documents/frpm1516.xls
was downloaded and edited to produce file frpm1415-edited.xls by deleting
worksheet "Title Page", deleting row 1 from worksheet "FRPM School-Level Data",
reformatting column headers in "FRPM School-Level Data" to remove characters
disallowed in SAS variable names, and setting all cell values to "Text" format

[Data Dictionary] http://www.cde.ca.gov/ds/sd/sd/fsspfrpm.asp

[Unique ID Schema] The columns "County Code", "District Code", and "School
Code"form a composite key, which together are equivalent to the unique id
column CDS_CODE in dataset dropouts17, and which together are also equivalent
to the unique id column CDS in dataset act17.
;

%let inputDataset1DSN = frpm1516_raw;
%let inputDataset1URL =
https://github.com/stat697/team-4_project_repo/blob/master/data/frpm1516_edited.xls?raw=true
;
%let inputDataset1Type = XLS;


*
[Dataset 2 Name] frpm1617

[Dataset Description] Student Poverty Free or Reduced Price Meals (FRPM) Data,
AY2016-17

[Experimental Unit Description] California public K-12 schools in AY2016-17

[Number of Observations] 10,478

[Number of Features] 28

[Data Source] The file http://www.cde.ca.gov/ds/sd/sd/documents/frpm1617.xls
was downloaded and edited to produce file frpm1415-edited.xls by deleting
worksheet "Title Page", deleting row 1 from worksheet "FRPM School-Level Data",
reformatting column headers in "FRPM School-Level Data" to remove characters
disallowed in SAS variable names, and setting all cell values to "Text" format

[Data Dictionary] http://www.cde.ca.gov/ds/sd/sd/fsspfrpm.asp

[Unique ID Schema] The columns "County Code", "District Code", and "School
Code" form a composite key, which together are equivalent to the unique id
column CDS_CODE in dataset dropouts17, and which together are also equivalent
to the unique id column CDS in dataset act17.
;

%let inputDataset2DSN = frpm1617_raw;
%let inputDataset2URL =
https://github.com/stat697/team-4_project_repo/blob/master/data/frpm1617_edited.xls?raw=true
;
%let inputDataset2Type = XLS;


*
[Dataset 3 Name] dropouts17

[Dataset Description] Grade seven through twelve dropouts and enrollment by
race/ethnic designation and gender by school, AY2016-17

[Experimental Unit Description] California public K-12 schools in AY2016-17

[Number of Observations] 59,599

[Number of Features] 20

[Data Source] The file
http://dq.cde.ca.gov/dataquest/dlfile/dlfile.aspx?cLevel=School&cYear=2016-17&cCat
=Dropouts&cPage=filesdropouts was downloaded and edited to produce file gradaf15.xls
by importing into Excel and setting all cell values to "Text" format

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

%let inputDataset4DSN = act17_raw;
%let inputDataset4URL =
https://github.com/stat697/team-4_project_repo/blob/master/data/act17_edited.xls?raw=true
;
%let inputDataset4Type = XLS;


* set global system options;
options fullstimer;


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


* check frpm1516_raw for bad unique id values, where the columns County_Code,
District_Code, and School_Code are intended to form a composite key;
proc sql;
    /* check for duplicate unique id values; after executing this query, we
       see that frpm1516_raw_dups only has one row, which just happens to
       have all three elements of the componsite key missing, which we can
       mitigate as part of eliminating rows having missing unique id component
       in the next query */
    create table frpm1516_raw_dups as
        select
             County_Code
            ,District_Code
            ,School_Code
            ,count(*) as row_count_for_unique_id_value
        from
            frpm1516_raw
        group by
             County_Code
            ,District_Code
            ,School_Code
        having
            row_count_for_unique_id_value > 1
    ;
    /* remove rows with missing unique id components, or with unique ids that do
	   not correspond to schools; after executing this query, the new dataset
	   frpm1516 will have no duplicate/repeated unique id values,and all unique
	   id values will correspond to our experimenal units of interest, which are
	   California Public K-12 schools; this means the columns County_Code,
	   District_Code, and School_Code in frpm1516 are guaranteed to form a
	   composite key */
    create table frpm1516 as
        select
            *
        from
            frpm1516_raw
        where
            /* remove rows with missing unique id value components */
            not(missing(County_Code))
            and
            not(missing(District_Code))
            and
            not(missing(School_Code))
            and
            /* remove rows for District Offices and non-public schools */
            School_Code not in ("0000000","0000001")
    ;
quit;


* do the same process as frpm1516: first check frpm1617_raw for bad unique id
  values, where the columns County_Code, District_Code, and School_Code are
  intended to form a composite key, then remove rows with missing unique id
  components, or with unique ids that do not correspond to schools;
proc sql;
    create table frpm1617_raw_dups as
        select
             County_Code
            ,District_Code
            ,School_Code
            ,count(*) as row_count_for_unique_id_value
        from
            frpm1617_raw
        group by
             County_Code
            ,District_Code
            ,School_Code
        having
            row_count_for_unique_id_value > 1
	;
    create table frpm1617 as
	    select
		    *
		from
		    frpm1617_raw
		where
		    not(missing(County_Code))
			and
			not(missing(District_Code))
			and
            not(missing(School_Code))
			and
			School_Code not in ("0000000","0000001")
	;
quit;


* Check dropouts17_raw for bad unique id values, where the column CDS_CODE is
  intended to be a primary key;
proc sql;
    /* check for unique id values that are repeated, missing, or correspond to
       non-schools; after executing this query, we see that
       dropouts17_raw_bad_unique_ids only has non-school values of CDS_Code
       that need to be removed */
    create table dropouts17_raw_bad_uqique_ids as
	    select
		    A.*
		from
		    dropouts17_raw as A
			left join
			(
			    select
				    CDS_CODE
					,count(*) as row_count_for_unique_id_value
				from
				    dropouts17_raw
				group by
				    CDS_CODE
			)as B
			on A.CDS_CODE= B.CDS_CODE
		having
		    row_count_for_unique_id_value >1
			or
			missing(CDS_CODE)
			or
			substr(CDS_CODE, 8,7) in ("0000000","0000001")
		;
    create table dropouts17 as
	    select
		    *
		from
		    dropouts17_raw
		where
		    substr(CDS_CODE,8, 7) not in ("0000000","0000001")

	;
quit;
* because the numer of the total enrollment and dropout is not including the
  grade seven and grade eight, also the total number of the enrollment and
  dropout is saprate by ehic and gender, we should edit the dropouts17 first;

* edit dropouts17into distinct CDS_CODE also add the grade seven and grade
  eight into the total enrollment and total drop number individually, then
  name the new work drop17;
proc sql;
    create table drop17_ as
    select CDS_CODE,
           E7+E8+ ETOT as TE,
           D7+D8+ DTOT  as TD
	from dropouts17;

proc sql;
    create table drop17__ as
    select CDS_CODE, sum(TE) as TTE, sum(TD)as TTD
	from drop17_
	group by CDS_CODE;

quit;

proc sql;
    create table __drop17 as
    select CDS_CODE, GENDER, sum(E7) as E7, sum(E8) as E8, sum(E9) as E9, sum(E10) as E10, 
		sum(E11) as E11, sum(E12) as E12, sum(ETOT) as ETOT, sum(D7) as D7, sum(D8) as D8, 
		sum(D9) as D9, sum(D10) as D10, sum(D11) as D11, sum(D12) as D12, sum(DTOT) as DTOT
	from dropouts17
	group by CDS_CODE, GENDER;

quit;
* check act17_raw for bad unique id values, where the column cds is intended to
  be a primary key;
proc sql;
    /* check for unique id values that are repeated, missing, or correspond to
       non-schools; after executing this query, we see that
       act17_raw_bad_unique_ids only has non-school values of cds that need to
       be removed */
    create table act17_raw_bad_uqique_ids as
	    select
		    A.*
		from
		    act17_raw as A
			left join
			(
			    select
				    cds
					,count(*) as row_count_for_unique_id_value
				from
				    act17_raw
				group by
				    cds
			)as B
			on A.cds= B.cds
		having
		    row_count_for_unique_id_value >1
			or
			missing(cds)
			or
			substr(cds, 8,7) in ("0000000","0000001")
		;
    create table act17 as
	    select
		    *
		from
		    act17_raw
		where
		    /* ne means not equal to */
		    substr(cds,8, 7) ne "0000000"

	;
quit;

*converting column from character to numeric;
data act17; set act17;
PctGE= input(PctGE21, ? comma24.);
run;

*creating analytical dataset named "analytical_merged";
proc sql;
    create table analytical_merged as
        select
             coalesce(A.CDS_Code,B.CDS_Code,C.CDS_Code,D.CDS_Code)
             AS CDS_Code
            ,coalesce(A.District,B.District,D.District)
             AS District
            ,A.VAR20 format percent12.2
             label "FRPM Percent Eligible 15-16"
            ,B.VAR20 format percent12.2
             label "FRPM Percent Eligible 16-17"
            ,D.Number_took_ACT
             label "Number of ACT Takers in 2017"
            ,D.Percent_with_ACT_above_21 format best12.
             label "Percentage of ACT takers scoring 21+ 2017"
			,D.School
			,C.GENDER, C.E7, C.E8, C.E9, C.E10, C.E11, C.E12,
			C.ETOT, C.D7, C.D8, C.D9, C.D10, C.D11, C.D12, C.DTOT

        from

            (
                select
                     cats(County_Code,District_Code,School_Code)
                     AS CDS_Code
                     length 14
                    ,District_Name
                     AS
                     District
                    ,VAR20
                from
                    Frpm1516
            ) as A
            full join
            (
                select
                     cats(County_Code,District_Code,School_Code)
                     AS CDS_Code
                     length 14
                    ,District_Name
                     AS District
                    ,VAR20
                from
                    Frpm1617
            ) as B
            on A.CDS_Code = B.CDS_Code
            full join
            (
                select
                    CDS_CODE, GENDER, E7, E8, E9, E10,
					E11, E12, ETOT, D7, D8, D9, D10, D11, D12, DTOT
                from
                    __drop17
            ) as C
            on A.CDS_Code = C.CDS_Code
            full join
            (
                select
                     cds
                     AS CDS_Code
                    ,dname
                     AS
                     District
                    ,NumTstTakr
                     AS Number_took_ACT
                    ,PctGE
                     AS Percent_with_ACT_above_21
					,sname 
					 AS School
                from
                    act17
            ) as D
            on A.CDS_Code = D.CDS_Code
    order by
        CDS_Code
    ;
quit;




* build analytic dataset from raw datasets imported above, including only the
columns and minimal data-cleaning/transformation needed to address each
research questions/objectives in data-analysis files;
proc sql;
    create table cde_analytic_file_raw as
        select
             coalesce(A.CDS_Code,B.CDS_Code,C.CDS_Code,D.CDS_Code)
             AS CDS_Code
            ,coalesce(A.School,B.School,D.School)
             AS School
            ,coalesce(A.District,B.District,D.District)
             AS District
            ,A.Percent_Eligible_FRPM_K12_1516 format percent12.2
             label "FRPM Eligibility Rate in AY2015-16"
            ,B.Percent_Eligible_FRPM_K12_1617 format percent12.2
             label "FRPM Eligibility Rate in AY2016-17"
            ,B.Percent_Eligible_FRPM_K12_1617
             - A.Percent_Eligible_FRPM_K12_1516
             AS FRPM_Percentage_Point_Increase format percent12.2
             label "FRPM Eligibility Rate Percentage Point Increase"
            ,C.Number_of_Total_Enrollment format comma12.
             label "Number_of_Total_Enrollment in AY2016-17"
			,C.Number_of_Total_Dropout format comma12.
             label "Number_of_Total_Dropout in AY2016-17"
			,C.Number_of_Total_Enrollment - C.Number_of_Total_Dropout
             AS Number_of_Total_Remain format comma12.
             label "Number_of_Total_Remain from grade seven to grade twelve"
			,C.Number_of_Total_Dropout / C.Number_of_Total_Enrollment
             AS Rate_of_Dropout format percent12.2
             label "Rate_of_Dropout from grade seven to grade twelve"
            ,calculated Number_of_Total_Remain
             / C.Number_of_Total_Enrollment format percent12.2
             AS Rate_of_Remain
             label "Rate_of_Remain from grade seven to grade twelve"
            ,D.Number_of_ACT_Takers format comma12.
             label "Number of ACT Takers in AY2016-17"
            ,D.Percent_with_ACT_above_21 format comma12.2
             label "Percentage of ACT Takers Scoring 21+ in AY2016-17"
        from
            (
                select
                     cats(County_Code,District_Code,School_Code)
                     AS CDS_Code
                     length 14
                    ,School_Name
                     AS
                     School
                    ,District_Name
                     AS
                     District
                    ,VAR20
                     AS Percent_Eligible_FRPM_K12_1516
                from
                    frpm1516
            ) as A
            full join
            (
                select
                     cats(County_Code,District_Code,School_Code)
                     AS CDS_Code
                     length 14
                    ,School_Name
                     AS
                     School
                    ,District_Name
                     AS
                     District
                    ,VAR20
                     AS Percent_Eligible_FRPM_K12_1617
                from
                    frpm1617
            ) as B
            on A.CDS_Code = B.CDS_Code


            full join
            (
                select
                     CDS_CODE
                     AS CDS_Code
                    ,TTE
                     AS Number_of_Total_Enrollment /* from grade seven to grade twelve*/
                    ,TTD
                     AS Number_of_Total_Dropout
                from
                    drop17__
            ) as C
            on A.CDS_Code = C.CDS_Code
            full join
            (
                select

                     cds
                     AS CDS_Code
                    ,sname
                     AS School
                    ,dname
                     AS
                     District
                    ,input(NumTstTakr, best12.)
                     AS Number_of_ACT_Takers
                    ,input(PctGE21,best12.)
                     AS Percent_with_ACT_above_21
                from
                    act17
            ) as D
            on A.CDS_Code = D.CDS_Code
    order by
        CDS_Code
    ;
quit;



* check cde_analytic_file_raw for rows whose unique id values are repeated,
missing, or correspond to non-schools, where the column CDS_Code is intended
to be a primary key;

* after executing this data step, we see that the full joins used above
introduced duplicates in cde_analytic_file_raw, which need to be mitigated
before proceeding;

data cde_analytic_file_raw_bad_ids;
    set cde_analytic_file_raw;
    by CDS_Code;

    if
        first.CDS_Code*last.CDS_Code = 0
        or
        missing(CDS_Code)
        or
        substr(CDS_Code,8,7) in ("0000000","0000001")
    then
        do;
            output;
        end;
run;
* remove duplicates from cde_analytic_file_raw with respect to CDS_Code;

* after inspecting the rows in cde_analytic_file_raw_bad_ids, we see that
  either of the rows in duplicate-row pairs can be removed without losing
  values for analysis, so we use proc sort to indiscriminately remove
  duplicates, after which column CDS_Code is guaranteed to form a primary key;
proc sort
        nodupkey
        data=cde_analytic_file_raw
        out=cde_analytic_file
    ;
    by
        CDS_Code
    ;
run;
