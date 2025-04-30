/************************************************************************************
| Project name : Charlson Score for Marketscan
| Date (update): Apr 2025
| Task Purpose : 
|      1. Setting (USER MUST MODIFY)  
|      2. Creation of format library for Charlson Comorbidity Groups 
|      3. Created a cohort of patients with patient_id and index_date
|      4. First macro - restrain data to within n-month prior of the index_date and tranpose the data
|      5. Second macro - stack all files produced from the first macro and produce final comorbidity scores
| Final dataset : 
|      1. library.ch_fmt | Format library for Charlson Comorbidity Groups
|      2. library.comorb_mscan | stack all files produced from the first macro and produce final comorbidity scores
************************************************************************************/

/************************************************************************************
   1. Set up the environment (USER MUST MODIFY)   
************************************************************************************/

* 1.1. Access to Server;

ssh -X mkim@jhpce01.jhsph.edu

srun --pty --x11 --partition sas bash
module load sas
sas -helpbrowser SAS -xrm "SAS.webBrowser:'/usr/bin/chromium-browser'" -xrm "SAS.helpBrowser:'/usr/bin/chromium-browser'"

* 1.2. Access to dataset;

* directory; 
/dcl02/alexande/data/MARKETSCAN2024/

*Inpatient data; 
/dcl02/alexande/data/MARKETSCAN2024/ccae_s.sas7bdat
 
* Outpatient data; 
/dcl02/alexande/data/MARKETSCAN2024/ccae_o.sas7bdat
 
* Pharmacy data; 
/dcl02/alexande/data/MARKETSCAN2024/ccae_d.sas7bdat


* 1.3. Set library;
libname mscan "/dcl02/alexande/data/MARKETSCAN2024";
libname library "/users/mkim/mscan";

/************************************************************************************
   2. Creation of format library for Charlson Comorbidity Groups : 
      ICD-10-CM and ICD-9-CM Comorbidity Software, 2021 version
************************************************************************************/

Proc format lib=library cntlout=library.ch_fmt;
   Value $ch_comfmt

/*Charlson*/
  "I2101", "I2102", "I2109", "I2111", "I2119", "I2121", "I2129", "I213", "I214", "I219", "I21A1", "I21A9", "I220", "I221", "I222", "I228", "I229", 
  "410  "-"41092" = "NCI_CH1_ACUTE_MI"

  "I252", "412" = "NCI_CH2_HISTORY_MI"
  
  "I099", "I110", "I130", "I132", "I255", "I420", "I43", "I50  "-"I509 ", "P290", "I425"-"I429", 
  "39891", "40201", "40211", "40291", "40401", "40403", "40411", "40413", "40491", "40493", "4254"-"4259", "428  "-"4289 " = "NCI_CH3_CHF"

  /* Note, ICD-9 437.3 is not included here for PVD, even though it is listed in the Quan paper. */
  "I70   "-"I719  ", "I731", "I738 "-"I739 ", "I771", "I790", "I792", "K551", "K558", "K559", "Z958  "-"Z959  ",
  "0930", "440  "-"4419 ", "4431 "-"4439 ", "4471", "5571", "5579", "V434"= "NCI_CH4_PVD"

  "G45 "-"G468", "H340 "-"H3403", "I60   "-"I69998", "36234", "430  "-"4389 " = "NCI_CH5_CVD"

  "I278 "-"I279 ", "J684", "J701", "J703", "J40   "-"J479  ", "J60 "-"J679", "4168", "4169", "490  "-"505  ", "5064", "5081", "5088" = "NCI_CH6_COPD"

  "F051", "G30 "-"G309", "G311", "F00   "-"F0394 ", "F03A1 "-"F03A4", "F03B0 "-"F03B4 ", "F03C0 "-"F03C4 ", "290  "-"2909 ", "2941", "3312" = "NCI_CH7_DEMENTIA"

  "G041", "G114", "G801", "G802", "G81  "-"G8194", "G82  "-"G8254", "G839", "G830 "-"G834 ", "3341", "342  "-"3439 ", "3440 "-"34461", "3449" = "NCI_CH8_PARALYSIS"

  "E100 "-"E1011", "E106  "-"E1069 ", "E108", "E109", "E110 "-"E1111", "E116  "-"E1169 ", "E118", "E119", "E130 "-"E1311", "E136  "-"E1369 ", "E138", "E139", 
  "250 "- "25033", "2508 "-"25093" = "NCI_CH9_DIABETES"

  "E102   "-"E1059  ", "E107", "E112   "-"E1159  ", "E117", "E132   "-"E1359  ", "E137", "2504 "-"25073" = "NCI_CH10_DIABETES_COMP"
  /* Note, ICD-10 E12 and E14 are not included here for diabetes, even though they are listed in the Quan paper. */

  "I120", "I131 "-"I1311", "N18 "-"N189 ", "N19", "N250", "Z940", "Z992", "N032  "-"N037  ", "N052  "-"N057  ", "Z490  "-"Z492  ", "40301", "40311", "40391", 
  "40402", "40403", "40412", "40413", "40492", "40493", "582  "-"5829 ", "5830"-"5837", "585 "-"5859", "586", "5880", "V420", "V451 "-"V4512", "V56  "-"V568 "= "NCI_CH11_RENAL_DISEASE"

  "B18 "-"B189", "K709", "K717", "K73 "-"K739", "K74  "-"K7469", "K760", "K768 "-"K769 ", "Z944", "K700 "-"K7031", "K713 "-"K7151", "K762"-"K764",
  "07022", "07023", "07032", "07033", "07044", "07054", "0706", "0709", "570  "-"5719 ", "5733", "5734", "5738", "5739", "V427" = "NCI_CH12_MILD_LIVER_DISEASE"

  "I850 "-"I8501", "I859", "I864", "I982", "K704 "-"K7041", "K711 "-"K7111", "K721 "-"K7211", "K729 "-"K7291", "K765", "K766", "K767", 
  "4560 "-"45621", "5722"-"5728" = "NCI_CH13_LIVER_DISEASE"

  "K25 "-"K289", "531  "-"53491" = "NCI_CH14_ULCERS"

  "M05   "-"M059  ", "M06   "-"M069  ", "M315", "M32  "-"M349 ", "M351", "M353", "M360", "4465", "7100"-"7104", "7140"-"7142", "7148 "-"71489", "725" = "NCI_CH15_RHEUM_DISEASE"

  "B20 "-"B222", "B24", "042"-"044" = "NCI_CH16_AIDS"

  "C00  "-"C269 ", "C30  "-"C3492", "C37  "-"C419 ", "C43   "-"C439  ", "C45   "-"C58   ", "C60  "-"C768 ", "C81  "-"C8599", "C88 "-"C889", "C90  "-"C97  ",
  "140 "-"1729", "174 "-"1958", "200  "-"20892", "2386" = "NCI_CH17_CANCER"

  "C77  "-"C802 ", "196  "-"1992 " = "NCI_CH18_METS"

  other = " "
  ;

   ;
run;


/************************************************************************************
   3. Created a cohort of patients with patient_id and index_date
************************************************************************************/

data cohort;
	set library.cohort;
	keep enrolid index_date;
run;
proc sort data=cohort; by enrolid; run;


/************************************************************************************
   4. First macro - restrain data to within n-month prior of the index_date and tranpose the data
************************************************************************************/

%macro claims (out_file, 	 /* This is the output file from this macro. It will have patient_ids with diagnosis dates and diagnosis codes in long format.
								If you have multiple raw files that you need to process, you need to run this macro multiple times,
								and you MUST name them with the SAME prefix. */
			   in_file,  	 /* This is the raw data (i.e. claim file) with diagnosis codes */
			   dx_code,  	 /* This is the variable names of your diagnosis codes */
			   cohort,   	 /* This is your cohort data */
			   patient_id,   /* This is your patient id variable */
			   claim_date,   /* This is your diagnosis date variable */
			   index_date,   /* This is your index date variable */
			   time_period,  /* This is the number of months prior to the index date that you want to restrain the diagnosis codes in */
			   data_type);   /* This is a user input indicator for the raw data type. Please put "I" for inpatient files and "O" for outpatient files */

	/* step 1 : Identify target files with diagnosis codes in 1-yr prior to the index date */
	data temp1;
		merge &in_file(in=in1 keep=&patient_id &claim_date &dx_code)
			  &cohort(in=in2 keep=&patient_id &index_date);		
		by &patient_id;
		if in1 and in2 and intnx('month',&index_date,-&time_period,"sameday") <= &claim_date < &index_date;
	run;
	
	/* step 2 - transpose data */
	data &out_file;
	  set temp1(keep=&patient_id &claim_date &dx_code);
	  array dgns_cd(*) &dx_code;
	  do i = 1 to dim(dgns_cd);
	  	if not missing(dgns_cd(i)) then do;
	    DGN_CD = upcase(dgns_cd(i)) ; OUTPUT ;
		end;
	  end;
	  drop &dx_code i;
	run;

	data &out_file;
	  set &out_file;
	  data_type = "&data_type";
	  rename &claim_date = claim_date;
	run;

%mend claims;
%claims(mscan1, mscan.ccae_f, DX1-DX9, cohort, enrolid, /* pddate or svcdate */, index_date, 12, I);
%claims(mscan2, mscan.ccae_i, DX1-DX15, cohort, enrolid, /* admdate or disdate */, index_date, 12, I);
%claims(mscan3, mscan.ccae_o, DX1-DX4, cohort, enrolid, /* pddate or svcdate */, index_date, 12, O);
%claims(mscan4, mscan.ccae_r, DX1, cohort, enrolid, /* pddate or svcdate */, index_date, 12, O);
%claims(mscan5, mscan.ccae_r, DX1, cohort, enrolid, /* pddate or svcdate */, index_date, 12, I);
%claims(mscan6, mscan.ccae_s, DX1-DX4, cohort, enrolid, /* admdate or disdate or pddate or svcdate */, index_date, 12, I);


/************************************************************************************
   5. Second macro - stack all files produced from the first macro and produce final comorbidity scores
************************************************************************************/

%macro comorb(in_file,
			  out_file,
			  patient_id);

	/* step 3 - Combine all data files and Create indicator variable for comorbidity */
	data temp1;
		set &in_file:;	

		ch_com=Put(dgn_cd, CH_COMFMT.); 

		if cmiss(of _all_) then delete; 
		drop dgn_cd; 
	run;

/* step 4: Remove duplicates by bene_id and elix_comorb comorbidity for inpatient records 
			If patient has at least one record in inpatient, we will consider it as a comorbidity	*/
	data inpatient_final;
		set temp1;
		if data_type = "I";
		drop claim_date data_type;
	run;
	proc sort data=inpatient_final nodup; by &patient_id com; run;

/* step 5: Keep comorbidity records from outpatient files which are 30 days apart 
			If patient has two claims which are 30 day apart, we will consider it as a comorbidity */
	data outpatient;
		set temp1;
		if data_type ne "I";
		drop data_type;
	run;
	
	proc sql;
		create table temp2 as
		select distinct &patient_id, com, max(claim_date) as max_date format=mmddyy10., min(claim_date) as min_date format=mmddyy10.
		from outpatient
		group by patient_id, com;
	quit;
	
	data outpatient_final;
		set temp2;
		if max_date - min_date >30;
		keep patient_id com;
	run;

/* step 6. Stack data from steps 4 and 5 and create comorbidities */
	data com; 
		set inpatient_final outpatient_final; 
		_Y=0;
	run;

	proc glmselect data=com noprint outdesign(addinputvars)=dum(drop=_Y com);
		class com;
		model _Y = com/noint selection=none;
	run;
	proc sort data=dum; by &patient_id; run;
	
	proc datasets lib=work nolist;
		modify dum;
		attrib _all_ label='';
	run;

/* step 7. Create comorbidities, bring file to patient level */
	proc summary data=dum;
		by &patient_id;
		var _numeric_;
		output out=dum_max(drop=_type_ _freq_) max= /autoname;
	run;

	data _NULL_;
		call execute('data dum_final; set dum_max; rename');
		do until(fend);
			set sashelp.vcolumn end=fend;
			where libname="WORK" and memname="DUM_MAX" and NAME like 'com%';
			call execute(cats(NAME, "=", substr(NAME,5, length(NAME)-8)));
		end;
	call execute('; run;');
	stop;
	run;

* Store comorbidities not in data as a 0 column;
	%let comorbs = 'NCI_CH1_ACUTE_MI' 'NCI_CH2_HISTORY_MI' 'NCI_CH3_CHF' 'NCI_CH4_PVD' 'NCI_CH5_CVD' 'NCI_CH6_COPD' 'NCI_CH7_DEMENTIA' 'NCI_CH8_PARALYSIS' 'NCI_CH9_DIABETES' 
				   'NCI_CH10_DIABETES_COMP' 'NCI_CH11_RENAL_DISEASE' 'NCI_CH12_MILD_LIVER_DISEASE' 'NCI_CH13_LIVER_DISEASE' 'NCI_CH14_ULCERS' 'NCI_CH15_RHEUM_DISEASE' 
				   'NCI_CH16_AIDS' 'NCI_CH17_CANCER' 'NCI_CH18_METS' ;

%let comorbs_noquo = %sysfunc(translate(%bquote(&comorbs), ' ', "'"));

	proc sql noprint; select "'"||STRIP(NAME)||"'" into: cols separated by ',' from dictionary.columns where libname = "WORK" and memname = "DUM_FINAL"; quit;
	%put &cols;

	%macro do_branch;
	%local i;
		data &out_file;
			set dum_final;
			%do i = 1 %to %sysfunc(countw(&comorbs));
				if %scan(&comorbs, &i, %str( )) not in (&cols) then %scan(&comorbs_noquo, &i, %str( )) = 0;
			%end;
		run;
	%mend do_branch;
	%do_branch;

 /* step 8. Create Charlson Comorbidity Index */

 data &out_file;
			set &out_file;

		Charlson = 
		1 * (NCI_CH1_ACUTE_MI or NCI_CH2_HISTORY_MI) +
		1 * (NCI_CH3_CHF) +
		1 * (NCI_CH4_PVD) +
		1 * (NCI_CH5_CVD) +
		1 * (NCI_CH6_COPD) +
		1 * (NCI_CH7_DEMENTIA) +
		2 * (NCI_CH8_PARALYSIS) +
		1 * (NCI_CH9_DIABETES and not NCI_CH10_DIABETES_COMP) +
		2 * (NCI_CH10_DIABETES_COMP) +
		2 * (NCI_CH11_RENAL_DISEASE) +
		1 * (NCI_CH12_MILD_LIVER_DISEASE and not NCI_CH13_LIVER_DISEASE) +
		3 * (NCI_CH13_LIVER_DISEASE) +
		1 * (NCI_CH14_ULCERS) +
		1 * (NCI_CH15_RHEUM_DISEASE) +
		6 * (NCI_CH16_AIDS) +
		2 * (NCI_CH17_CANCER) +
		6 * (NCI_CH18_METS)
		;


%mend comorb;
%comorb(mscan1, library.comorb_mscan, enrolid);  
%comorb(mscan2, library.comorb_mscan, enrolid);  
%comorb(mscan3, library.comorb_mscan, enrolid);  
%comorb(mscan4, library.comorb_mscan, enrolid);  
%comorb(mscan5, library.comorb_mscan, enrolid);  
%comorb(mscan6, library.comorb_mscan, enrolid);  











       
