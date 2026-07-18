/************************************************************************************
   Charlson Comorbidity format ($ch_comfmt) + classification step
   Adapted from "Charlson Score for Marketscan.sas":
     - PROC FORMAT $ch_comfmt built into WORK (upstream targets an external
       format library via lib=/cntlout=; here it lands in WORK so the run is
       self-contained)
     - the classification step is the comorb macro's core: ch_com = put(dgn_cd, CH_COMFMT.)
   The ICD-10-CM / ICD-9-CM ranges and comorbidity labels are unchanged.
************************************************************************************/

Proc format;
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
run;

/* A small sample of diagnosis codes (enrolid + dgn_cd), the shape the comorb macro
   consumes. Each maps to a Charlson comorbidity group via the format above. */
data dx;
  input enrolid $ dgn_cd $12.;
  datalines;
1001 I2109
1001 E119
1002 I509
1002 N185
1003 C509
1004 K7030
1005 B20
1006 250
1006 M0590
1007 G8194
1008 99999
;
run;

/* This is the classification step from the comorb macro (step 3):
   ch_com = put(dgn_cd, CH_COMFMT.);  */
data classified;
  set dx;
  length ch_com $ 24;
  ch_com = put(dgn_cd, $CH_COMFMT.);
run;

proc print data=classified noobs;
  title "Diagnosis codes classified into Charlson comorbidity groups";
run;

proc freq data=classified;
  where ch_com ne " ";
  tables ch_com / nocum;
  title "Comorbidity group frequencies";
run;
