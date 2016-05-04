* Presentation 2 - Group 10 - AKA The Sassy 10s  

	Ignacio Faria
	Wan Zhang
	Cristina Lozano
	DaLu Chen
	Qun Zhang

* Document Overview: The code below implements an 
  analysis plan applied to data collected from the
  City and County Data Book for the 1992 presidential
  election. The Data was shortened to only Include
  counties in CA and TX, and the candiates voted for
  within their respective counties. 
;

* Data Source & Usage Conventions: The following file 
  has been downloaded from the Vanderbilt University
  Department of Biostatistics website
  and processed as follows:

  (1) counties.zip has been downloadable from
     c
      to a flash drive labelled drive "E:" with path
      "E:/stat6250/countiesxls.zip." For the sake of the
	  assignment, the file was split into 3 different files:
	  cadata (denoting Californian data), txdata (denoting
	  Texan data), and vdata (denoting the partisanship of
	  each county). The primary key is a concatonated of 
	  the state and county of each observation.
	  

   The code below was used to create a SAS Transport
   file with path
   "E:/STAT6250-presentation2.xpt",
   following instructions at the following URL:
   http://support.sas.com/documentation/cdl/en/movefile/67439/HTML/default/viewer.htm#p1vuzzjna78uoon1vobn8odochpo.htm

   In particular, each Excel file was first converted to a
   SAS dataset in the library dataout using proc import,
   and then a SAS Transport comprising the three datasets
   is created suing proc cport.
;
/*
 Code to create SAS Transport file:

    libname dataout "C:\Users\Isaac\Dropbox\Sas_Presentations";
    filename tranfile "c:\Users\Isaac\Dropbox\SAS_Presentations\presentation2_code.xpt";
   proc import
            file="E:\stats6250\countiesxls\cadata.xlsx"
            out=dataout.cadata
            dbms=xlsx
        ;
    run;
   proc import
            file="E:\stats6250\countiesxls\txdata.xlsx"
            out=dataout.txdata
            dbms=xlsx
        ;
    run;
   proc import
            file="E:\stats6250\countiesxls\vdata.xlsx"
            out=dataout.vdata
            dbms=xlsx
        ;
        sheet="voterdata";
    run;
    proc cport
            library=dataout
            file=tranfile
            memtype=data
        ;
    run;
*/

* Finally, the SAS transport file was then uploaded to
  Dropbox and a file-sharing link was obtained so that all
  three datasets can be loaded into the Word library using
  proc http and proc cimport, following the technique at
  the following URL:
  http://blogs.sas.com/content/sasdummy/2012/12/18/using-sas-to-access-data-stored-on-dropbox/
;

* Analysis Plan Step 1: Load multiple existing SAS datasets

  Presenter: Cristina Lozano
  Presenter Email: clozano26@horizon.csueastbay.edu
  Step Rationale: Upload the data
;

filename _inbox TEMP;
proc http
        method="get" 
        url="https://www.dropbox.com/s/qlvki2tasy2r8mk/presentation2_code.xpt?dl=1" 
        out=_inbox
    ;
run;
proc cimport
        library=work
        infile=_inbox
    ;
run;
filename _inbox clear;

;
* Analysis Plan Step 2: Clean the data.

  Presenter: Ignacio Faria
  Presenter Email: ifaria@horizon.csueastbay.edu
  Step Rationale: Now that the data have been imported,
  we must prepare and clean the datasets. 

  The first step will be to create a new dataset with only the desired 
  variables. We must then create a length statement
  that determines the length and character type
  of the observations within the respective columns.
; 
 
data CaliforniaVoters;
   
    retain
            STCCODE
            County
            State
            Pop
            Age6574
            Age75
            Crime
            College
            Income
			Turnout
    ;
    keep
            STCCODE
            County
            State
            Pop
            Age6574
            Age75
            Crime
            College
            Income
			Turnout
    ;
/* Below are length statements designed to create
   desired variable widths and charatcter type.
*/
    length
            STCCODE       $30
            County        $25
            State	      $2
            Pop           8
            Age6574       8
            Age75         8
            Crime         8
            College	  	  8
            Income	  	  8
			Turnout	  	  8
;
    set Cadata
(
            keep=
                    STCCODE
                    County
                    State
                    Pop
                    Age6574
                    Age75
                    Crime
                    College
			  		Income
			 		Turnout
)
;
run;

data TexasVoters;
/*  Below is a list of the same variables, analagous
	from the previous code on Californian voters. This
	list is about the Texan voters data.
*/
    retain
            STCCODE
            County
            State
            Pop
            Age6574
            Age75
            Crime
            College
            Income
			Turnout
    ;
    keep
            STCCODE
            County
            State
            Pop
            Age6574
            Age75
            Crime
            College
            Income
			Turnout
    ;
/* The stame length statements are reused.
*/
    length
            STCCODE       $30
            County        $25
            State	      $2
            Pop           8
            Age6574       8
            Age75         8
            Crime         8
            College	  	  8
            Income	  	  8
			Turnout	  	  8
    ;
    set Txdata
  	(
            keep=
                    STCCODE
                    County
                    State
                    Pop
                    Age6574
                    Age75
                    Crime
                    College
				    Income
					Turnout
      )
     ;
run;
data VoterPE;
/* Below is a list of the political parties that the 
   voters identify as and the presidential candidates 
   that were voted for. The variables are in their 
   desired order and a keep statement is used for the 
   respective variables.;
*/
    retain
            STCCODE
            Democrat
            Republican
            Perot
            White
            Black
;
    keep
            STCCODE
            Democrat
            Republican
            Perot
            White
            Black
;
/* These are the length and character statements.
*/
    length
            STCCODE       $30
            Democrat      8
            Republican    8
            Perot         8
            White         8
            Black         8
;
    set Vdata
(
            keep=
                    STCCODE
                    Democrat
                    Republican
                    Perot
                    White
                    Black

)
;
run;

proc sql;
    create table Combo_CA_TX as
        select
            STCCODE,
            County,
            State,
            Pop,
            Age6574,
            Crime,
            College,
            Income,
			Turnout
        from Californiavoters 
		where STCCODE is not null
		union all corr
        select
            STCCODE,
            County,
            State,
            Pop,
            Age6574,
            Crime,
            College,
            Income,
			Turnout
        from Txdata where STCCODE is not null
       order by STCCODE
;
quit;



* Analysis Plan Step 4: Merge two datasets horizontally
  (basic, data-step programming version)
 
  Presenter: Qun Zhang
  Presenter Email: Qzhang46@horizon.csueastbay.edu
 
  Notes/Additional Assignment Instructions: Because of the
  work done above to clean and conform county data, we need
  only apply two simple follow steps to combine and validate
  schools data. In particular, the business logic implemented
  is as follows:
 
  (1) Combine the TexasVoters data horizontally with the
  VoterPE data, meaning to create a new dataset that
  combined the same observations as sql_Combo_CA_TX but with
  additional variables from VoterPE added based upon
  matching values of the key variable STCCODE. Note that the
  match-merge process relies on both datasets having already
  been sorted by the key variable STCCODE used for by-group
  processing and results in a dataset that is already sorted
  by STCCODE.
 
  (2) Validate the resulting data to make sure there are no
  "bad" values of the key variable STCCODE, meaning duplicate
  or missing values using the same by-group processing trick
  as in Step 3.
;
proc sql;
    create table sql_Combo_CA_TX as
        select
                 coalesce(A.STCCODE,B.STCCODE)
                 AS STCCODE
                ,A.County
                ,A.State
                ,A.Pop
                ,A.Age6574
                ,A.Crime
                ,A.College
                ,A.Income
				,A.Turnout
				,B.Democrat
				,B.Republican
				,B.Perot
                ,B.White
                ,B.Black
        from
            Combo_CA_TX  as A
            full join
            VoterPE as B
            on A.STCCODE=B.STCCODE
        order by STCCODE
;
quit;

proc means data=Sql_combo_CA_tx 
mean range std sum;
run;
proc means data=Californiavoters
mean range std sum;
run;
proc means data=Texasvoters
mean range std sum;
run;
proc univariate normal plot data=Sql_combo_ca_tx;
var perot;
run;
quit;
proc univariate normal plot data=Californiavoters;
var perot;
run;
quit;
proc univariate normal plot data=Texasvoters;
var perot;
run;
quit;

proc glm data=Sql_combo_ca_tx;
class state perot
model 
/*not sure what to do with this*/

data californiavoters(drop=i sampleSize);
    retain sampleSize 50;
    do i = 1 to sampleSize;
        samplePoint=ceil(dataSetSize*ranuni(0));
        set
            Texasvoters
            point=samplePoint
            nobs=dataSetSize
        ;
        output;
    end;
    stop;
run;
proc sort data=californiavoters;
    by crime;
run;
data californiavoters_dups;
    set californiavoters;
    by crime;

    if income>20000 then
        do;
            output;
        end;
	run;

