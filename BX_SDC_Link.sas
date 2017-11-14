/*  -------------------------------------------------------------------------  */
/*                                                                             */
/*               Data matching for corporate governance research               */
/*                                                                             */
/*  Program      : BX_SDC_Link.sas                                             */
/*  Author       : Attila Balogh, School of Banking and Finance                */
/*                 UNSW Business School, UNSW Sydney                           */
/*  Date Created : 14 Nov 2017                                                 */
/*  Last Modified: 14 Nov 2017                                                 */
/*                                                                             */
/*  Description  : BoardEx to SDC Matching                                     */
/*                                                                             */
/*  Notes        : Please reference the following paper when using this code   */
/*                 Balogh, A 2017                                              */
/*                 Data matching for corporate governance research             */
/*                 Available at SSRN: https://ssrn.com/abstract=3053405        */
/*                                                                             */
/*  _________________________________________________________________________  */

/*  Step 1: Establish that the GVKEY-CUSIP match is unique                     */

proc freq data=comp.names;
	tables cusip / noprint out=cusip_duplicates_00;
run;

data cusip_duplicates_00;
	set cusip_duplicates_00;
	where not missing(CUSIP);
	if count < 2 then delete;
run;

/*  An empty cusip_duplicates_00 dataset confirms                             */

/*  Step 2: Find 6-digit CUSIP with multiple GVKEY matches                    */

data cusip6;
	set comp.names;
	SDC_Cusip = substr(cusip,1,6);
run;

proc freq data=cusip6;
	tables SDC_Cusip / noprint out=cusip_duplicates_01;
run;

data cusip_duplicates_01;
	set cusip_duplicates_01;
	if count < 2 then delete;
run;

proc sql;
create table cusip_duplicates_02 as
 		select a.*, b.count
		from cusip6 (rename=SDC_Cusip=SDC_Cusip0) a, cusip_duplicates_01 (where=(COUNT ne .)) b
		where a.SDC_Cusip0 = b.SDC_Cusip
		order by count descending, SDC_Cusip;
quit;


data petro;
	set comp.names;
/*	where gvkey in('121934');*/
	where cik in('0001059324');
run;

data dsenames;
	set crsp.dsenames;
/*	keep permno namedt nameendt cusip comnam ncusip SDC_Cusip;*/
	SDC_Cusip = substr(cusip,1,6);
run;

data test;
	set comp.names;
	where upcase(conm) contains 'petrohawk';
run;

data test3;
	set dsenames;
/*  General Motors*/
where SDC_Cusip in('37045V');
/*  BHP Petro*/
/*	where SDC_Cusip in('088606');*/
/*	where permno eq 87054;*/
/*	where upcase(comnam) contains 'ABEX';*/
run;

data test2;
	set crsp.Ccmxpf_lnkhist;
	where gvkey in('121934');
run;


/*  -------------------------------------------------------------------------  */
/* *************************  Attila Balogh, 2017  *************************** */
/*  -------------------------------------------------------------------------  */
