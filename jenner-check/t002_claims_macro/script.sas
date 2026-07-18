/************************************************************************************
   Caller for the %claims macro from "Charlson Score for Marketscan.sas"
   The macro definition is upstream's, verbatim. Upstream calls it against external
   MarketScan libname datasets (mscan.ccae_f etc.); here we supply a small mock
   claim file and cohort with the same column shape (patient id, claim date, DX1-DXn)
   so the merge / date-window filter / array transpose logic runs standalone.
************************************************************************************/

/* --- mock cohort: enrolid + index_date (replaces library.cohort) --- */
data cohort;
  input enrolid $ index_date :mmddyy10.;
  format index_date mmddyy10.;
  datalines;
1001 06/15/2023
1002 03/01/2023
1003 09/30/2023
;
run;
proc sort data=cohort; by enrolid; run;

/* --- mock inpatient claim file: enrolid + svcdate + DX1-DX4 --- */
/* Shape mirrors mscan.ccae_s / ccae_f: patient id, a service date, several DX slots */
data ccae_mock;
  input enrolid $ svcdate :mmddyy10. DX1 $ DX2 $ DX3 $ DX4 $;
  format svcdate mmddyy10.;
  datalines;
1001 01/10/2023 I2109 E119 .     .
1001 02/20/2023 I509  .     .     .
1002 12/05/2022 C509  N185  .     .
1002 08/01/2021 K7030 .     .     .
1003 05/15/2023 G8194 B20   .     .
1003 09/01/2023 .     .     .     .
;
run;
proc sort data=ccae_mock; by enrolid; run;

/* --- upstream %claims macro, unmodified --- */
%macro claims (out_file,
			   in_file,
			   dx_code,
			   cohort,
			   patient_id,
			   claim_date,
			   index_date,
			   time_period,
			   data_type);

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

/* Restrain to the 12 months prior to each patient's index_date and transpose */
%claims(mscan1, ccae_mock, DX1-DX4, cohort, enrolid, svcdate, index_date, 12, I);

proc print data=mscan1 noobs;
  title "claims macro output: long-format diagnosis rows within 12 months of index_date";
run;
