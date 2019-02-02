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
