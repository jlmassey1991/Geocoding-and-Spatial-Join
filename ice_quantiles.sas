
*************************************************

Author:      Jason Massey (JM)
Title:      Creating ICE Quantiles
Last Edited:  04/08/2024

*************************************************;




****************************************

*  Importing Data 

****************************************;

*Import ICE CT data;
proc import datafile="\\cdc.gov\project\CCID_NCPDCID_NHSN_SAS\Data\work\_Projects\LTC\COVID-19\Codes\Jason\Surveillance Branch\SDOH\Geospatial\ICE\ICE_VARS.csv"
        out=ice_vars
        dbms=csv
        replace;
		run;

*Import NHSN CT data;
proc import datafile="\\cdc.gov\project\CCID_NCPDCID_NHSN_SAS\Data\work\_Projects\LTC\COVID-19\Codes\Jason\Surveillance Branch\SDOH\Geospatial\ltc_CTs.csv"
        out=ltc_ct
        dbms=csv
        replace;
		run;

*Import RUCA data;
proc import datafile="\\cdc.gov\project\CCID_NCPDCID_NHSN_SAS\Data\work\_Projects\LTC\COVID-19\Codes\Jason\Surveillance Branch\SDOH\Geospatial\ICE\ruca_codes.csv"
        out=ruca
        dbms=csv
        replace;
		run;



****************************************

*  Create ICE Quantiles

****************************************;

/* generate state quartiles. */

proc sort data = ice_vars;
by STATE;
run;

proc rank data=ice_vars out=outranks groups=4;
    var ice_inc;
    ranks ice_inc_qr;
	by STATE;
run;

proc rank data=outranks out=outranks2 groups=4;
    var ice_black;
    ranks ice_black_qr;
	by STATE;
run;

proc rank data=outranks2 out=outranks3 groups=4;
    var ice_hisp;
    ranks ice_hisp_qr;
	by STATE;
run;

data outranks4; 
set outranks3;
ice_inc_qr = ice_inc_qr+1  ;
ice_black_qr = ice_black_qr+1 ;
ice_hisp_qr = ice_hisp_qr+1 ;

label ice_inc_qr = "ICE income state quartiles";
label ice_black_qr = "ICE black state quartiles";
label ice_hisp_qr = "ICE hispanic state quartiles";
run;



/* generate state tertiles. */
proc rank data=ice_vars out=outranks5 groups=3;
    var ice_inc;
    ranks ice_inc_tr;
	by STATE;
run;

proc rank data=outranks5 out=outranks6 groups=3;
    var ice_black;
    ranks ice_black_tr;
	by STATE;
run;

proc rank data=outranks6 out=outranks7 groups=3;
    var ice_hisp;
    ranks ice_hisp_tr;
	by STATE;
run;

data outranks8; 
set outranks7;
ice_inc_tr = ice_inc_tr+1  ;
ice_black_tr = ice_black_tr+1 ;
ice_hisp_tr = ice_hisp_tr+1 ;

label ice_inc_tr = "ICE income state tertiles";
label ice_black_tr = "ICE black state tertiles";
label ice_hisp_tr = "ICE hispanic state tertiles";
run;






*Quantiles Categorical;
data ice_vars_cat;
set ice_vars;

if ICE_inc <= -0.5 then ICE_inc_c = 1;
if -0.5 < ICE_inc <= 0 then ICE_inc_c = 2;
if 0 < ICE_inc <= 0.5 then ICE_inc_c = 3;
if 0.5 < ICE_inc then ICE_inc_c = 4;

if ice_black <= -0.5 then ice_black_c = 1;
if -0.5 < ice_black <= 0 then ice_black_c = 2;
if 0 < ice_black <= 0.5 then ice_black_c = 3;
if 0.5 < ice_black then ice_black_c = 4;

if ice_hisp <= -0.5 then ice_hisp_c = 1;
if -0.5 < ice_hisp <= 0 then ice_hisp_c = 2;
if 0 < ice_hisp <= 0.5 then ice_hisp_c = 3;
if 0.5 < ice_hisp then ice_hisp_c = 4;

by state;

run;


*Sort and Merge;
proc sort data = outranks4;
by GEO_ID;run;
proc sort data = outranks8;
by GEO_ID;run;
proc sort data = ice_vars_cat;
by GEO_ID;run;

*Complete ICE File;
data ice_final;
    merge  outranks4 outranks8 ice_vars_cat ;
    by GEO_ID;
	rename GEO_ID = GEOID ;
run;



****************************************

*  Join to NHSN Census Tract dataset

****************************************;

*Left join to NHSN data;
proc sql;
	create table ice_analysis as
	select * from ltc_ct as x left join ice_final as y
	on x.GEOID = y.GEOID;
quit;


*Create resident to bed ratio;
data ice_analysis2;
set ice_analysis;
res_bed_ratio = Average_Number_of_Residents_per/Number_of_Certified_Beds ;
staff_turnover = Total_nursing_staff_turnover*1;
staff_per_res = Adjusted_Total_Nurse_Staffing_H*1;
run;




* Tertiles;

*Produce res to bed ratio averages among ICE ;
*Black and hispanic natural tertile cutoffs;


*Res-bed Ratio;

*BLACK;
proc means data = ice_analysis2;
var res_bed_ratio  ;
where ice_black < -.6 ;
run;

proc means data = ice_analysis2;
var res_bed_ratio  ;
where -.6 < ice_black < .6 ;
run;

proc means data = ice_analysis2;
var res_bed_ratio  ;
where .6 < ice_black  ;
run;

*HISP;
proc means data = ice_analysis2;
var res_bed_ratio  ;
where ice_hisp < -.6 ;
run;

proc means data = ice_analysis2;
var res_bed_ratio  ;
where -.6 < ice_hisp < .6 ;
run;

proc means data = ice_analysis2;
var res_bed_ratio  ;
where .6 < ice_hisp  ;
run;



*Nurse Turnover;

*BLACK;
proc means data = ice_analysis2;
var staff_turnover  ;
where ice_black < -.6 ;
run;

proc means data = ice_analysis2;
var staff_turnover  ;
where -.6 < ice_black < .6 ;
run;

proc means data = ice_analysis2;
var staff_turnover  ;
where .6 < ice_black  ;
run;

*HISP;
proc means data = ice_analysis2;
var staff_turnover  ;
where ice_hisp < -.6 ;
run;

proc means data = ice_analysis2;
var staff_turnover  ;
where -.6 < ice_hisp < .6 ;
run;

proc means data = ice_analysis2;
var staff_turnover  ;
where .6 < ice_hisp  ;
run;



*staff_per_res;

*BLACK;
proc means data = ice_analysis2;
var staff_per_res  ;
where ice_black < -.6 ;
run;

proc means data = ice_analysis2;
var staff_per_res  ;
where -.6 < ice_black < .6 ;
run;

proc means data = ice_analysis2;
var staff_per_res  ;
where .6 < ice_black  ;
run;

*HISP;
proc means data = ice_analysis2;
var staff_per_res  ;
where ice_hisp < -.6 ;
run;

proc means data = ice_analysis2;
var staff_per_res  ;
where -.6 < ice_hisp < .6 ;
run;

proc means data = ice_analysis2;
var staff_per_res  ;
where .6 < ice_hisp  ;
run;




*RUCA try;
proc sql;
	create table ice_ruca as
	select * from ice_analysis2 as x left join ruca as y
	on x.GEOID = y.GEOID;
quit;


proc means data = ice_ruca;
var res_bed_ratio  ;
where ruca_2= "rural" ;
run;

proc means data = ice_ruca;
var res_bed_ratio  ;
where ruca_2 = "micro" ;
run;

proc means data = ice_ruca;
var res_bed_ratio  ;
where ruca_2 = "metro" ;
run;


*Staff Turnover;
proc means data = ice_ruca;
var staff_turnover  ;
where ruca_2= "rural" ;
run;

proc means data = ice_ruca;
var staff_turnover  ;
where ruca_2 = "micro" ;
run;

proc means data = ice_ruca;
var staff_turnover  ;
where ruca_2 = "metro" ;
run;

* staff_per_res;
proc means data = ice_ruca;
var staff_per_res  ;
where ruca_2= "rural" ;
run;

proc means data = ice_ruca;
var staff_per_res  ;
where ruca_2 = "micro" ;
run;

proc means data = ice_ruca;
var staff_per_res  ;
where ruca_2 = "metro" ;
run;





data ltc_sdoh_pre;
set ice_ruca;
  keep 
    orgid geoid 
    ruca_1 ruca_2
    ice_inc ice_black ice_hisp 
    ice_inc_qr ice_black_qr ice_hisp_qr
    ice_inc_tr ice_black_tr ice_hisp_tr
    ice_inc_c ice_black_c ice_hisp_c 
  ;

run;





****************************************

*  Exporting Data

****************************************;



*Exporting ICE dataset as csv file;
PROC EXPORT DATA= ice_maps2
            OUTFILE= "\\cdc.gov\project\CCID_NCPDCID_NHSN_SAS\Data\work\_Projects\LTC\COVID-19\Codes\Jason\Surveillance Branch\SDOH\Geospatial\ICE\ice_maps.csv"
            DBMS=csv replace;
RUN;

*Export SDOH dataset;
PROC EXPORT DATA= ltc_sdoh_pre
            OUTFILE= "\\cdc.gov\project\CCID_NCPDCID_NHSN_SAS\Data\work\_Projects\LTC\COVID-19\Codes\Jason\Surveillance Branch\SDOH\Geospatial\ICE\ltc_sdoh_dataset.csv"
            DBMS=csv replace;
RUN;

*/

