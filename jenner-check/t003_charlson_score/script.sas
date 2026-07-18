/************************************************************************************
   Charlson Comorbidity Index scoring (step 8 of the comorb macro)
   From "Charlson Score for Marketscan.sas". The 18 binary comorbidity indicators
   are the output of the comorb macro's proc glmselect/summary steps, which need
   external MarketScan data; here a small dataset of patient-level 0/1 indicators
   replaces them so the weighted-sum scoring arithmetic runs standalone.
   The Charlson = ... weighting expression is upstream's, unchanged.
************************************************************************************/

/* Patient-level 0/1 comorbidity indicators (what comorb produces before step 8) */
data comorb_ind;
  input enrolid $
        NCI_CH1_ACUTE_MI NCI_CH2_HISTORY_MI NCI_CH3_CHF NCI_CH4_PVD
        NCI_CH5_CVD NCI_CH6_COPD NCI_CH7_DEMENTIA NCI_CH8_PARALYSIS
        NCI_CH9_DIABETES NCI_CH10_DIABETES_COMP NCI_CH11_RENAL_DISEASE
        NCI_CH12_MILD_LIVER_DISEASE NCI_CH13_LIVER_DISEASE NCI_CH14_ULCERS
        NCI_CH15_RHEUM_DISEASE NCI_CH16_AIDS NCI_CH17_CANCER NCI_CH18_METS;
  datalines;
P01 1 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0
P02 0 0 1 0 0 0 0 0 1 1 1 0 0 0 0 0 0 0
P03 0 0 0 0 0 0 0 1 0 0 0 1 1 0 0 0 1 0
P04 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 1
P05 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
;
run;

/* step 8. Create Charlson Comorbidity Index — upstream's exact weighting */
data scored;
  set comorb_ind;

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
run;

proc print data=scored noobs;
  var enrolid Charlson;
  title "Charlson Comorbidity Index per patient";
run;

proc means data=scored n mean min max maxdec=2;
  var Charlson;
  title "Charlson score distribution";
run;
