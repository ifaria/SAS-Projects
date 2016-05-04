* Presentation 3 - Group 10 - AKA The Sassy 10s  

	Ignacio Faria
	Wan Zhang
	Cristina Lozano
	DaLu Chen
	Qun Zhang

/* Document Overview: The code below implements an analysis 
	plan applied to data for citizens who were stopped in 
	New York by the NYPD and were either let free, searched,
	frisked, and or arrested. We wanted to see if race had
	any indication on likeliness of committing a crime.
*/
/*					 List of Variables
City - Location of stop: 1-Manhattan, 2-Brooklyn, 3-Bronx, 
						 4-Queens, 5- Staten Island
sex - Suspect's sex: 0-female, 1-male
race - Suspect's race: 1-Black, 2-Black Hispanic, 
					   3-White Hispanic, 4-White, 
					   5-Asian/Pacific Islander, 6-Am.Indian
age - Suspect's age
build - Suspect's build: 1-heavy, 2- muscular, 3-medium, 4-thin
frisked - Was suspect frisked? 0-no, 1-yes
searched - Was suspect searched? 0-no, 1-yes
timestop - Time of stop: hhmm
arstmade - Was an arrest made? 0-no, 1-yes
crimsusp - Crime suspected
detailcm:
	9-Assault
	10-Auto Stripping
	14-Burglary
	19-CPSP
	20-Criminal Possession of a Weapon
	23-Criminal Mischief
	24-Criminal Possession of Controlled Substance
	26-Criminal Possession of Forged Instrument
	27-Criminal Possession of Marijuana 
	28-Criminal Sale of Controlled Substance
	29-Criminal Sale of Marijuana
	31-Criminal Trespass
	41-Fraudulent Accosting
	45-Grand Larceny
	46-Grand Larceny Auto
	59-Making Graffiti
	62-Murder
	65-Obstructing Govermental Administration
	68-Petit Larceny
	72-Prohibited Use of Weapon
	74-Prostitution
	78-Reckless Endagerment
	85-Robbery
	96-Theft of Services
	100-Unauthorized Use of a Vehicle
	112-Other
	113-Forcible Touching
perobs - Period of observation in minutes
physforce - Was physical force used? 1-4 the sum of 
			different forces used
forceuse - Reason for force: 1-defence of other
		   2-defence of self, 3-overcome resistance
	  	   4-other, 5-suspected flight, 6-suspected weapon

* Data Source & Usage Conventions: The following two
  data files are used:

  (1) STAT6250-01_s15-presentation3-crimedata.csv,
      which contains data for all the people who were 
	  stopped on 12-30-2012, which was downloaded from
	  the NYCLU from an analysis that was done on every
	  person who was stopped in 2012.  It was downloaded as
	  a CSV file, edited for 12-30-2012, and made availalble 
	  for direct download through Dropbox using the following
	  URL:
	  https://www.dropbox.com/s/5cobxdj4hne0v2p/Crimedata.csv?dl=1

  (2) The second dataset represents the personally discriptive
	  variables about those were who stopped by the police. The
	  file was also found on the NYCLU website on 19MAY2015.  The
	  revised data is available for download through Dropbox using
	  the link
	  https://www.dropbox.com/s/ra1e240h14k5djb/Suspectdata.csv?dl=1
;

/* Analysis Plan Step 1: Setup working environment

  Presenter: Ignacio Faria
  Presenter Email: ifaria@horizon.csueastbay.edu

  Step Overview: Aquire the data and format it.

  Step Rationale: 1)Download the data. 2) Assign a working directory.

*/
libname NYPD2014 'C:\Users\Isaac\Desktop\NYPD2014';
filename pdfout 'C:\Users\Isaac\Desktop\NYPD2014.\multipage_example_pdf_output.pdf';
filename excelout 'C:\Users\Isaac\Desktop\NYPD2014.\multitab_example_excel_output.xml';

filename pdprep TEMP;
proc http
        method="get" 
        url="https://www.dropbox.com/s/5cobxdj4hne0v2p/Crimedata.csv?dl=1" 
        out=pdprep;
run;
* the Personal data from the NYCLU website is our secondary dataset,
  is loaded from Dropbox;
filename pd2prep TEMP;
proc http
        method="get" 
        url="https://www.dropbox.com/s/ra1e240h14k5djb/Suspectdata.csv?dl=1" 
        out=pd2prep
    ;
run;
* Analysis Plan Step 2: Convert primary data
                        in raw text format
                        to a SAS dataset

  Presenter: [Qun Zhang]
  Presenter Email: [qzhang46@horizon.csueastbay.edu]

  Step Overview: [primary dataset cleaning]

  Step Rationale: [remove nonsignificant variable]

*first, the CSV file with pdprep data is read into a 
 SAS dataset, with all data treated as text;
data NYPD2014.pdprep_raw;
    /* only necessary variables and observations are
       read in using modified list input */;
    infile pdprep dsd dlm="," firstobs=2;
    input
            PKEY: $4.
            timestop: $4.
            arstmade: $1.
            arstoffn: $1.
            crimsusp: $12.
            detailcm: $3.
            perobs: $2.
            PHYSFORCE: $1.
            forceuse: $1.
    ;
run;

* The raw data is then cleaned by subsetting to only
  necessary variables, translating numeric data stored in
  character variabnles into actual numeric data, and
  deleting rows not  necessary for analysis;
data NYPD2014.pdprep_raw_cleaned;
    /* below is a list of the desired final variables in
       the correct order; a parallel keep statement is also
       used to remove all other variables from output */;
    retain
            PKEY
            timestop
            arstmade
			detailcm
            reason_for_force
    ;
    keep
            PKEY 
            timestop
            arstmade
			detailcm
            reason_for_force
    ;
    /* below are length statements designed to create
       desired variable widths */;
    length
            PKEY $4.
            timestop  $4.
            arstmade  $1.
			detailcm  $3.
            reason_for_force $20.     ;
    /* read all rows and columns from the raw dataset
       created above */;
    set nypd2014.pdprep_raw;

    /* translate forceuse to reason_for_force explaining 
	   why police officer take further action */;
    if forceuse="1" then reason_for_force="defence of other";
    else if forceuse="2" then reason_for_force="defence of self";
    else if forceuse="3" then reason_for_force="overcome resistence";
    else if forceuse="4" then reason_for_force="other";
    else if forceuse="5" then reason_for_force="suspected flight";
	else if forceuse="6" then reason_for_force="suspeted weapon";
	else if missing(forceuse)then reason_for_force="no force used";
	else delete;
run;

* then, the data is sorted by CDS_Code in order to
  facilitate by-group processing below;
proc sort data=nypd2014.pdprep_raw_cleaned;
    by PKEY;
run;

* Analysis Plan Step 3: Convert secondary data
                        in raw text format
                        to a SAS dataset

  Presenter: Wan Zhang
  Presenter Email: wzhang53@horizon.csueastbay.edu

Step Overview: secondary dataset cleaning, choose at 
least 50 observations and 6 variable which include PKEY
  Step Rationale:remove nonsignificant variable

* first, the csv file with the persondata is read into a
  SAS dataset,with all data treated as text;
data NYPD2014.persondata_raw;
    /* only necessary variables and observations are
       read in using modified list input */;
    infile pd2prep
           dsd dlm="," firstobs=2;
    input
            PKEY: $4.
            city: $1.
            sex: $1.
            race: $1.
            age: $3.
            build: $1.
		    frisked: $1.
    ;
run;

* Then, the raw data is cleaned by subsetting to only
  necessary variables, translating numeric data stored in
  character variabnles into actual numeric data, and
  deleting rows not necessary for analysis;

data nypd2014.persondata_cleaned;
    /* below is a list of the desired final variables in
       order; a parallel keep statement is again used to 
	   remove all other variables from output */
;
    retain
            PKEY
			city
			sex
			race
			age
			build
    ;
    keep
            PKEY
			city
			sex
			race
			age
			build
   ;
    /* below are length statements designed to create
       desired variable widths */;
	 length
		PKEY					$4
		city				    $1
		sex						$1
		race				    $30
		age				        $3
		build				    $1
    ;
set nypd2014.persondata_raw;
if race="1" then race="black";
else if race="2" then race="black hispanic";
else if race="3" then race="white hispanic";
else if race="4" then race="white";
else if race="5" then race="asian/pacific islander";
else if race="6" then race="Am.Indian";
else delete;
run;

* The data is checked to make sure there are no
  duplicate values of PKEY;
proc sort
        nodupkey
        data=nypd2014.persondata_cleaned
        dupout=nypd2014.persondata_cleaned_dup
    ;
    by PKEY;
run;

* Finally, the data is sorted one last time to facilitate
  merging by PKEY below;
proc sort
        data=nypd2014.persondata_cleaned
        out=nypd2014.persondata_cleaned_sorted
    ;
    by PKEY;
run;

* Step 4: merge two datasets together
  presentator: Dalu Chen
  E-mail: dchen39@horizon.csueastbay.edu;
data nypd2014.pdprep_merged;
    /* match-merge by PKEY, and create the in=
       variable pprc for pdpprep data so that the
       resulting dataset can be filtered just to matches
       generated by the FRPM data */;
    merge
        nypd2014.pdprep_raw_cleaned(in=pprc)
        nypd2014.persondata_cleaned_sorted
    ;
    by PKEY;
    if reason_for_force="no force used" then
        do;
           delete;
        end;
	if missing(city) then
	do;
	    delete;
	end;
	if missing(sex) then
	do;
	   delete;
	end;
    if pprc=1 then
        do;
            output;
        end;

run;
data nypd2014.pdprep_merged2;
     merge 
	      nypd2014.pdprep_raw_cleaned(in=pprc)
        nypd2014.persondata_cleaned_sorted
    ;
    by PKEY; 
if pprc=1 then
do;
     output;
end;
run;

* Step 5: Create a macro variable for the main title of the
  reports to generate, which allows the main title to be
  reused several times while only needing to be changed
  in a single location;
%let pageTitle1=
   Ny police records
    ;
* "open" an ODS Sandwich by declaring that an Excel file
  will be created;
ods tagsets.ExcelXP
    file=excelout
    style=printer
    options(embedded_titles = 'yes')
    ;
* create another macro variable with a subtitle that will
  be reused;
%let pageTitle2=
    All NY records
    ;

* set the worksheet name for the first worksheet to be
  output in the Excel file being created;
ods tagsets.ExcelXP
    options(
            sheet_interval="none"
            sheet_name="&pageTitle2."
           )
;

* populate the first worksheet of the Excel file being
  created by outputing two titles and proc print output;
title1 "&pageTitle1.";
title2 "&pageTitle2.";
proc print noobs data=nypd2014.pdprep_merged;
    var
        PKEY					
		timestop
        detailcm
        reason_for_force
		city
		sex
 		race				    			       
				    
    ;
run;

* reset all titles;
title;

* create another macro variable with a subtitle that will
  be reused;
%let pageTitle2=
   black hispanic vs. black vs. white hispanic vs. white vs. asian/pacific islander
    ;

* set the worksheet name for the second worksheet to be
  output in the Excel file being created;
ods tagsets.ExcelXP
    options(
            sheet_interval="none"
            sheet_name="&pageTitle2."
           )
;

* populate the second worksheet of the Excel file being
  created by outputing two titles and proc freq output;
title1 "&pageTitle1.";
title2 "&pageTitle2.";
proc freq data=nypd2014.pdprep_merged2;
    table race*detailcm
          / nocol nopercent nocum
    ;
    format race;
  
run;
proc freq data=nypd2014.pdprep_merged2;
    table race*reason_for_force
          / nocol nopercent nocum
    ;
    format reason_for_force ;
  
run;

* reset all titles;
title;

* "close" the ODS Sandwich by declaring that an Excel file
  being created should be closed and written to disk;
ods tagsets.ExcelXP close;

/* Extra */
title1 "&pageTitle1.";
title2 "&pageTitle2.";
proc freq data=nypd2014.pdprep_merged;
    table race*arstmade
          / nocol nopercent nocum
    ;
    format arstmade;
  
run;

title1 "&pageTitle1.";
title2 "&pageTitle2.";
proc freq data=nypd2014.pdprep_merged2;
    table race*arstmade
          / nocol nopercent nocum
    ;
    format arstmade;
  
run;

proc sort data=nypd2014.pdprep_merged2 out=nypd2014.pdprep_merged2_sorted;
	by 

proc means data
	var race
	class reason_for_force city arstmade
run;
