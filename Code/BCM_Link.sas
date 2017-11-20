
/*  -------------------------------------------------------------------------  */
/*       Matching Round 1 - Compustat matching on the CUSIP identifier         */
/*  _________________________________________________________________________  */

/*  -------------------------------------------------------------------------  */
/*  Merge Compustat GVKEY to Input file                                        */
/*  Takes the input dataset and the COMP.names dataset to find a matching      */
/*  observation for the firm's CUSIP for the specific year of interest         */
/*  _________________________________________________________________________  */

/*  Remove duplicate entries                                                   */

proc sort data=&INSET. out=A_1_Set_00;
    by BoardID descending COMP_Cusip;
run;
proc sort data=A_1_Set_00 out=A_1_Set_01 nodupkey ;
    by BoardID COMP_Cusip;
run;

/*  Matching step                                                              */

proc sql;
    create table A_1_Set_02 as
        select a.*, b.*
        from A_1_Set_01 (where=(not missing(COMP_Cusip))) a left join comp.names b
        on a.COMP_Cusip = b.cusip
        order by BoardName
    ;
quit;

/*  Delete dupliates                                                          */

proc sort data=A_1_Set_02 out=A_1_Set_03 nodupkey ;
    by BoardID gvkey;
quit;

/*  -------------------------------------------------------------------------  */
/*  Matching round 1 final seteps                                              */
/*  Save dataset of successfully matched observations                          */
/*  Create a Match_1 indicator for observations matched in this round          */

%let keepvars = BoardID gvkey BoardName;
%let keepvars_11 = &keepvars. Match_11;

data AB_App_11;
    retain &keepvars_11.;
    set A_1_Set_03;
    where not missing(gvkey);
    Match_11 = 1;
    keep &keepvars_11.;
run;
/*  -------------------------------------------------------------------------  */
/*                                                                             */
/*               Data matching for corporate governance research               */
/*                                                                             */
/*  Program      : BCM_Link.sas                                                */
/*  Author       : Attila Balogh, School of Banking and Finance                */
/*                 UNSW Business School, UNSW Sydney                           */
/*  Date Created : 15 Oct 2017                                                 */
/*  Last Modified:  7 Nov 2017                                                 */
/*                                                                             */
/*  Description  : Link BoardEx data to Comustat GVKEY and CRSP PERMNO         */
/*                                                                             */
/*  Notes        : Please reference the following paper when using this code   */
/*                 Balogh, A 2017                                              */
/*                 Data matching for corporate governance research             */
/*                 Available at SSRN: https://ssrn.com/abstract=3053405        */
/*                                                                             */
/*  _________________________________________________________________________  */

/*  -------------------------------------------------------------------------  */
/*  Set dataset version to use                                                 */

dm 'log;clear';


/*  Identifying the BoardEx Universe                                           */
/*  Please refer to separate code                                              */
/*  _________________________________________________________________________  */


/*  -------------------------------------------------------------------------  */
/*                                                                             */
/*    The BoardEx NA_WRDS_COMPANY_NAMES contains TICKER ISIN and CIK Codes     */
/*  and are linked to BoardID, which is called CompanyID in many other         */
/*  Boardex datasets.                                                          */
/*                                                                             */
/*  _________________________________________________________________________  */

/*  -------------------------------------------------------------------------  */
/*                                ISIN and CUSIP                               */
/*  The CUSIP code can be derived from the ISIN code by removing the country   */
/*  code, the first two characters, and the last two checksum digits           */
/*                                                                             */
/*  _________________________________________________________________________  */


/*  -------------------------------------------------------------------------  */
/*  Identifying all firms in BoardEx that have an identifier: ISIN, CUSIP, or  */
/*  ticker symbol and the BoardID is not missing                               */
/*                                                                             */
/*      Note that the BoardEx company profile dataset is not comprehensive     */
/*          and is missing entries for firms in other BoardEx datasets         */
/*  _________________________________________________________________________  */

/*  options obs=max;  */
data A_0_Set_00;
	set Boardex.Na_wrds_company_names boardex.Na_wrds_company_profile;
	where not missing(BoardID) and (not missing(ISIN) or not missing(Ticker) or not missing(CIKCode));
	COMP_Cusip = substr(isin,3,9);
	CRSP_Cusip = substr(isin,3,8);
	SDC_Cusip = substr(isin,3,6);
	label SDC_Cusip = "SDC CUSIP";
	if not missing(SDC_Cusip) then Match_31 = 1;
	keep BoardID BoardName ISIN Ticker CIKCode COMP_Cusip CRSP_Cusip SDC_Cusip Match_31;
run;

data BX_SDC_00;
	set A_0_Set_00;
	where not missing(SDC_Cusip);
	LinkType = 'LC';
	keep BoardID SDC_Cusip LinkType;
	rename SDC_Cusip = BXcusip;
run;

proc sort data=BX_SDC_00 out=BX_SDC_Link nodupkey ;
	by BoardID BXcusip;
run;

/*  Final input dataset for matching                                          */

%let INSET = A_0_Set_00;

/*  -------------------------------------------------------------------------  */
/*       Matching Round 1 - Compustat matching on the CUSIP identifier         */
/*  _________________________________________________________________________  */

/*  -------------------------------------------------------------------------  */
/*  Merge Compustat GVKEY to Input file                                        */
/*  Takes the input dataset and the COMP.names dataset to find a matching      */
/*  observation for the firm's CUSIP for the specific year of interest         */
/*  _________________________________________________________________________  */

/*  Remove duplicate entries                                                   */

proc sort data=&INSET. out=A_1_Set_00;
	by BoardID descending COMP_Cusip;
run;
proc sort data=A_1_Set_00 out=A_1_Set_01 nodupkey ;
	by BoardID COMP_Cusip;
run;

/*  Matching step                                                              */

proc sql;
	create table A_1_Set_02 as
 		select a.*, b.*
		from A_1_Set_01 (where=(not missing(COMP_Cusip))) a left join comp.names b
		on a.COMP_Cusip = b.cusip
		order by BoardName
	;
quit;

/*  Delete dupliates                                                          */

proc sort data=A_1_Set_02 out=A_1_Set_03 nodupkey ;
	by BoardID gvkey;
quit;

/*  -------------------------------------------------------------------------  */
/*  Matching round 1 final seteps                                              */
/*  Save dataset of successfully matched observations                          */
/*  Create a Match_1 indicator for observations matched in this round          */

%let keepvars = BoardID gvkey BoardName;
%let keepvars_11 = &keepvars. Match_11;

data AB_App_11;
	retain &keepvars_11.;
	set A_1_Set_03;
	where not missing(gvkey);
	Match_11 = 1;
	keep &keepvars_11.;
run;

/*  -------------------------------------------------------------------------  */
/*           Matching Round 2 - Compustat matching on the CIK Code             */
/*  _________________________________________________________________________  */


/*  FIRST: backfill non ten-digit CIK codes in the BoardEx names file          */

data A_2_Set_00;
	format NewCIK $10.;
	format FullCIK $10.;
	set &INSET.;
	where not missing(CIKCode);
	if length(CIKCode) lt 10 then newCIK = cats(repeat('0',10-1-length(CIKCode)),CIKCode);
	FullCIK = coalescec(NewCIK,CIKCode);
	drop NewCIK;
run;

/*  Remove duplicate entries                                                   */

proc sort data=A_2_Set_00 out=A_2_Set_01;
	by BoardID descending FullCIK;
run;
proc sort data=A_2_Set_01 out=A_2_Set_02 nodupkey ;
	by BoardID FullCIK;
run;

/*  Matching step                                                              */

proc sql;
	create table A_2_Set_03 as
 		select	a.*, b.*
		from A_2_Set_02 a left join comp.names b
		on a.FullCIK = b.cik
		order by BoardID
	;
quit;

/*  Delete dupliates                                                          */

proc sort data=A_2_Set_03 out=A_2_Set_04 nodupkey ;
	by BoardID gvkey;
quit;

/*  Create a Match_2 indicator for observations matched in this round          */

%let keepvars_12 = &keepvars. Match_12;

data AB_App_12;
	retain &keepvars_12.;
	set A_2_Set_04;
	where not missing(gvkey);
	Match_12 = 1;
	keep &keepvars_12.;
run;

/*  -------------------------------------------------------------------------  */
/*                 Matching Round 3 - Manual Compustat matching                */
/*  _________________________________________________________________________  */

%include "BCM_Link_MA.sas" ;

/*  -------------------------------------------------------------------------  */
/*                  Matching Round 4 - CRSP matching on CUSIP                  */
/*  _________________________________________________________________________  */


/*  Remove duplicate entries                                                   */

proc sort data=&INSET. out=A_4_Set_00;
	by BoardID descending CRSP_Cusip;
run;
proc sort data=A_4_Set_00 out=A_4_Set_01 nodupkey ;
	by BoardID CRSP_Cusip;
run;

/*  Matching step                                                              */

proc sql;
	create table A_4_Set_02 as
 		select	a.BoardID, a.BoardName, a.CRSP_CUSIP,
				b.permno, b.namedt, b.nameendt, b.ncusip, b.comnam
		from A_4_Set_01 (where=(not missing(CRSP_Cusip))) a, crsp.dsenames b
		where a.CRSP_Cusip = b.ncusip
		order by BoardID, permno, namedt, nameendt
	;
quit;


/*  -------------------------------------------------------------------------  */
/*  Step 2                                                                     */
/*  Collapse link table                                                        */

data A_4_Set_03;
    set A_4_Set_02;
    by BoardID permno namedt nameendt;
    format prev_ldt prev_ledt yymmddn8.;
    retain prev_ldt prev_ledt;
    if first.permno then do;
        if last.permno then do;
/*  Keep this obs if it's the first and last matching permno pair              */
            output;           
        end;
        else do;
/*  If it's the first but not the last pair, retain the dates for future use   */
            prev_ldt = namedt;
            prev_ledt = nameendt;
            output;
            end;
        end;   
    else do;
        if namedt=prev_ledt+1 or namedt=prev_ledt then do;
/*  If the date range follows the previous one, assign the previous namedt     */
/*  value to the current - will remove the redundant in later steps.           */
/*  Also retain the link end date value                                        */
            namedt = prev_ldt;
            prev_ledt = nameendt;
            output;
            end;
        else do;
/* If it doesn't fall into any of the above conditions, just keep it and       */
/* retain the link date range for future use                                   */
            output;
            prev_ldt = namedt;
            prev_ledt = nameendt;
            end;
        end;
    drop prev_ldt prev_ledt;
run;

data A_4_Set_04;
	retain BoardID permno comnam namedt nameendt;
	set A_4_Set_03;
	by BoardID permno namedt;
	if last.namedt;
  /* remove redundant observations with identical namedt (result of the previous data step), so that
     each consecutive pair of observations will have either different GVKEY-IID-PERMNO match, or
     non-consecutive link date range
   */
	label BoardID = "BoardEx Board ID";
	label permno = "CRSP Permno";
	label namedt = "CRSP Names Date";
	label nameendt = "CRSP Names Ending Date";
/*	drop comnam BoardName CRSP_CUSIP ncusip;*/
run;

/*  Delete dupliates                                                          */

proc sort data=A_4_Set_04 out=A_4_Set_05 nodupkey ;
	by BoardID permno namedt nameendt;
quit;

/*  -------------------------------------------------------------------------  */
/*  Matching round 3 final seteps                                              */
/*  Save dataset of successfully matched observations                          */
/*  Create a Match_21 indicator for observations matched in this round          */

%let keepvars_21 = BoardID permno namedt nameendt Match_21 LinkType;

data AB_App_21;
	retain &keepvars_21.;
	set A_4_Set_05;
	where not missing(permno);
	Match_21 = 1;
	LinkType = 'LC';
	keep &keepvars_21.;
	rename permno=BXpermno namedt=BXnamedt nameendt=BXnameendt;
run;

/*  -------------------------------------------------------------------------  */
/*  The final BX CRSP Link dataset                                             */

data BX_CRSP_Link;
	set AB_App_21;
	keep BoardID BXpermno BXnamedt BXnameendt LinkType;
run;

/*  -------------------------------------------------------------------------  */
/*           Matching Round 5 - CUSIP-based Permno link to Compustat           */
/*  _________________________________________________________________________  */

/* Reverse from CRSP to GVKEY */

proc sql;
	create table A_5_set_00 as
 		select	a.*, b.*
		from A_4_set_05 a left join crsp.Ccmxpf_lnkhist b
		on a.permno = b.lpermno
		order by BoardID, permno, gvkey, linkprim, liid, linkdt
	;
quit;

/*  Because out goal is to find a GVKEY match to a BoardID, we can remove */
/*  BoardID - GVKEY duplicates. It may leave us with observations BoardID-PERMNO */
/*  duplicates - they will need to be checed when merging Compustat financial data */

proc sort data=A_5_set_00 out=A_5_set_01 nodupkey ;
	by BoardID gvkey;
run;

/*  Create a Match_15 indicator for observations matched in this round          */

%let keepvars_15 = BoardID GVKEY Match_15;

data AB_App_15;
	retain &keepvars_15.;
	set A_5_set_01;
	where not missing(gvkey);
	Match_15 = 1;
	keep &keepvars_15.;
run;

/*  -------------------------------------------------------------------------  */
/*        This code consolidates the result of multiple matching steps         */
/*  _________________________________________________________________________  */

data A0_Matched_00;
	set A_13_set_00 Boardex.Na_wrds_company_names boardex.Na_wrds_company_profile;
	keep BoardID;
run;

proc sort data=A0_Matched_00 out=A0_Matched_00 nodupkey ;
	by BoardID;
run;

data BxComp_00;
	set AB_App_11 AB_App_12 AB_App_13 AB_App_15;
run;
proc sort data=BxComp_00;
	by BoardID descending Match_11-Match_15;
run;

proc sql;
	create table BxComp_01 as
select	BoardID, GVKEY,
		max(Match_11) as Match_11,
		max(Match_12) as Match_12,
		max(Match_13) as Match_13,
		max(Match_14) as Match_14,
		max(Match_15) as Match_15
	from BxComp_00
	group by BoardID, GVKEY;
quit;

data BxComp_02;
	set BxComp_01;
	if Match_15=1 and Match_11 ne 1 then Match_N = 1;
	if Match_15=1 and Match_12 ne 1 then Match_C = 1;
	if Match_11=1 or Match_12=1 or Match_13=1 then Match_0 = 1;
	if Match_0 ne 1 and Match_N = 1 then Match_W = 1;
run;

proc freq data=BxComp_02 ;
	tables Match_: /out=BxComp_022;
run;

proc freq data=BxComp_02;
	tables Breakdown /nocum nofreq nopercent;
run;

proc sql;
	select
		count(Match_13) as Manual_match,
		count(Match_12) as CIK_match
	from BxComp_01;
quit;

%let A0_Matched_02 = BoardID gvkey Linktype Matchpattern Match_1: ;

data BxComp_02;
	retain &A0_Matched_02. ;
	set BxComp_01;
	Matchpattern = cats(Match_11,Match_12,Match_13,Match_14,Match_15);
	if Matchpattern in('1....') or Matchpattern in('1...1') then Linktype = 'LC';
	if Matchpattern in('.1...') or Matchpattern in('.1..1') then Linktype = 'LK';
	if Matchpattern in('11...') or Matchpattern in('11..1') then Linktype = 'LX';
	if Matchpattern in('1.1..') or Matchpattern in('.11..') or Matchpattern in('111..')
		or Matchpattern in('1.1.1') or Matchpattern in('.11.1') or Matchpattern in('111.1')
		then Linktype = 'LY';
	if Matchpattern in('.....') then Linktype = '';
	if Matchpattern in('..1..') then Linktype = 'LM';
	if Matchpattern in('...1.') then Linktype = 'LN';
	if Matchpattern in('....1') then Linktype = 'LR';
	if Matchpattern in('.....') then delete;
	label LinkType = "Link Type";
	label BoardID = "BoardEx BoardID";
	label GVKEY = "Compustat GVKEY";
	keep &A0_Matched_02.;
	rename GVKEY = BXgvkey;
run;

proc sort data=BxComp_02;
	by BoardID;
run;

data Bx_Comp_Link;
	set BxComp_02;
	keep BoardID BXgvkey LinkType;
run;

%let dd = %sysfunc(today(), yymmddn8.);
%put &dd.;
options dlcreatedir;
libname BXtoday "C:\Users\Attila Balogh\Dropbox\1-University\Dataset\012-Matching\&dd." ;

data BX_Link.Bx_Comp_Link BXtoday.Bx_Comp_Link;
	set Bx_Comp_Link;
run;

data BX_Link.Bx_crsp_link BXtoday.Bx_crsp_link;
	set Bx_crsp_link;
run;

data BX_Link.Bx_sdc_link BXtoday.Bx_sdc_link;
	set Bx_sdc_link;
run;

/*  -------------------------------------------------------------------------  */
/*                            Obtain key statistics                            */
/*  _________________________________________________________________________  */

dm 'odsresults; clear';

/*  -------------------------------------------------------------------------  */
/*  BX Compustat Link                                                          */

proc freq data=Bx_Comp_Link;
	tables LinkType / nopercent ;
	title 'BX Link: Compustat GVKEY Matching';
run;

/*  BX CRSP Link                                                               */

proc freq data=Bx_crsp_link;
	tables LinkType / nopercent ;
	title 'BX Link: CRSP PERMNO Matching';
run;

/*  BX SDC Platinum Link                                                       */

proc freq data=Bx_sdc_link;
	tables LinkType / nopercent ;
	title 'BX Link: SDC CUSIP6 Matching';
run;


/*  -------------------------------------------------------------------------  */
/* *************************  Attila Balogh, 2017  *************************** */
/*  -------------------------------------------------------------------------  */
