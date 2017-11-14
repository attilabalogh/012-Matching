/*  -------------------------------------------------------------------------  */
/*                                                                             */
/*               Data matching for corporate governance research               */
/*                                                                             */
/*  Program      : BCM_Link.sas                                                */
/*  Author       : Attila Balogh, School of Banking and Finance                */
/*                 UNSW Business School, UNSW Sydney                           */
/*  Date Created : 15 Oct 2017                                                 */
/*  Last Modified: 31 Oct 2017                                                 */
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

dm 'odsresults; clear';
dm 'log;clear';
%let dataver = 20171030;

/*  Identifying the BoardEx Universe                                           */
/*  Please refer to separate code                                              */
/*  _________________________________________________________________________  */


/************************************************************************************/
/*	https://wrds-web.wharton.upenn.edu/wrds/query_forms/navigation.cfm?navId=120	*/
/*	The WRDS-created linking dataset (ccmxpf_linktable) has been deprecated.		*/
/*	It will continue to be created for a transition period of 1 year.				*/
/*	SAS programmers should use the Link History dataset (ccmxpf_lnkhist) from CRSP.	*/
/*	BUT we need CCM_LOOKUP because ccmxpf_lnkhist does not include CUSIP, which is	*/
/*	what we have from BoardEX														*/
/************************************************************************************/

/*  -------------------------------------------------------------------------  */
/*                                                                             */
/*    The BoardEx NA_WRDS_COMPANY_NAMES contains TICKER ISIN and CIK Codes     */
/*  and are linked to BoardID, which is called BoardID in all other Boardex    */
/*  datasets.                                                                  */
/*                                                                             */
/*  _________________________________________________________________________  */

/*  -------------------------------------------------------------------------  */
/*                                ISIN and CUSIP                               */
/*  The CUSIP code can be derived from the ISIN code by removing the country   */
/*  code, the first two characters, and the last two checksum digits           */
/*                                                                             */
/*  In this step, the original dataset A_000_00 is taken, which contains       */
/*  BoardID, BoardName, the start / end dates for the period (DateA DateB)     */
/*  This dataset is then joined on BoardID, the equivalent of BoardID          */
/*  _________________________________________________________________________  */


/*  -------------------------------------------------------------------------  */
/*  Identifying all firms in BoardEx that have an identifier: ISIN, CUSIP, or  */
/*  ticker symbol and the BoardID is not missing                               */
/*                                                                             */
/*      Note that the BoardEx company profile dataset is not comprehensive     */
/*          and is missing entries for firms in other BoardEx datasets         */
/*  _________________________________________________________________________  */

options obs=max;
data A_0_Set_00;
	set Boardex.Na_wrds_company_names boardex.Na_wrds_company_profile;
	where not missing(BoardID) and (not missing(ISIN) or not missing(Ticker) or not missing(CIKCode));
	COMP_Cusip = substr(isin,3,9);
	CRSP_Cusip = substr(isin,3,8);
	SDC_Cusip = substr(isin,3,6);
	label SDC_Cusip = "SDC CUSIP";
	if not missing(SDC_Cusip) then Match_3 = 1;
	keep BoardID BoardName ISIN Ticker CIKCode COMP_Cusip CRSP_Cusip SDC_Cusip;
run;

/*  Remove duplicate entries                                                   */

proc sort data=A_0_Set_00 out=A_0_Set_01;
	by BoardID descending isin descending Ticker descending CIKCode;
run;
proc sort data=A_0_Set_01 out=A_0_Set_02 nodupkey ;
	by BoardID isin Ticker CIKCode;
run;

%let INSET = A_0_Set_02;

/*  -------------------------------------------------------------------------  */
/*    Preparatory Round - ONLY for Rounds 1-7, manual match needs A_1_Input    */
/*  _________________________________________________________________________  */

/*  Change the date in Compustat Names to year format to aid in matching       */

data names_02;
	format StartYear year4.;
	format EndYear year4.;
	set compm.names_&dataver.;
	StartYear = mdy(1, 1, year1);
	EndYear = mdy(1, 1, year2);
	drop year1 year2;
run;

/*  -------------------------------------------------------------------------  */
/*       Matching Round 1 - Compustat matching on the CUSIP identifier         */
/*  _________________________________________________________________________  */

/*  -------------------------------------------------------------------------  */
/*  Merge Compustat GVKEY to Input file                                        */
/*  Takes the input dataset and the COMP.names dataset to find a matching      */
/*  observation for the firm's CUSIP for the specific year of interest         */
/*  _________________________________________________________________________  */

proc sort data=&INSET. out=A_1_Set_00;
	by COMP_Cusip;
run;
proc sort data=A_1_Set_00 out=A_1_Set_00 nodupkey ;
	by COMP_Cusip;
run;

proc sql;
	create table A_1_Set_01 as
 		select a.*, b.*
		from A_1_Set_00 (where=(not missing(COMP_Cusip))) a left join names_02 b
		on a.COMP_Cusip = b.cusip
		order by BoardName
	;
quit;

/*  Only delete dupliates on what is specifically being matched on            */

proc sort data=A_1_Set_01 out=A_1_Set_02 nodupkey ;
	by BoardID cusip;
quit;

/*  -------------------------------------------------------------------------  */
/*  Matching round 1 final seteps                                              */
/*  Save dataset of successfully matched observations                          */
/*  Create a Match_1 indicator for observations matched in this round          */

%let keepvars = BoardID gvkey BoardName StartYear EndYear;
%let keepvars_01 = &keepvars. Match_1;

data AB_App_01;
	retain &keepvars_01.;
	set A_1_Set_02;
	where not missing(gvkey);
	Match_1 = 1;
	keep &keepvars_01.;
run;

/*  Identify duplicates and show number of successful matches                  */

proc sql;
	select
	count(BoardID) as BoardID_count,
	count(gvkey) as GVKEY_count,
	count(distinct BoardID) as Unique_BoardID_count,
	count(distinct gvkey) as Unique_GVKEY_count
	from AB_App_01;
quit;

proc freq data=AB_App_01;
	tables BoardID / noprint out=AB_App_01_dup;
run;
data AB_App_01_dup;
	set AB_App_01_dup;
	where count ne 1;
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

proc sql;
	create table A_2_Set_01 as
 		select	a.*, b.*
		from A_2_Set_00 a left join names_02 b
		on a.FullCIK = b.cik
		order by BoardID
	;
quit;

/*  Only ever delete dupliates on what is specifically being matched on        */

proc sort data=A_2_Set_01 out=A_2_Set_02 nodupkey ;
	by BoardID cik;
quit;

/*  Create a Match_2 indicator for observations matched in this round          */

%let keepvars_02 = &keepvars. Match_2;

data AB_App_02;
	retain &keepvars_02.;
	set A_2_Set_02;
	where not missing(gvkey);
	Match_2 = 1;
	keep &keepvars_02.;
run;

proc sql;
	select
	count(BoardID) as BoardID_count,
	count(distinct BoardID) as Unique_BoardID_count,
	count(distinct gvkey) as GVKEY_count
	from AB_App_02;
quit;


/*  Identify duplicates and show number of successful matches                  */

proc sql;
	select
	count(BoardID) as BoardID_count,
	count(CIKCode) as CIK_count,
	count(distinct BoardID) as Unique_BoardID_count,
	count(distinct CIKCode) as Unique_CIK_count
	from A_2_Set_02;
quit;

proc sort data=A_2_Set_02;
	by gvkey;
quit;

proc sql;
	select
	count(BoardID) as BoardID_count,
	count(gvkey) as GVKEY_count,
	count(distinct BoardID) as Unique_BoardID_count,
	count(distinct gvkey) as Unique_GVKEY_count
	from AB_App_02;
quit;

proc freq data=AB_App_02;
	tables gvkey / noprint out=AB_App_02_dup;
run;
data AB_App_02_dup;
	set AB_App_02_dup;
	where count ne 1;
run;

/*******************************************************************************/
/*         Matching Round 3 - Compustat matching on the Ticker symbol          */
/*******************************************************************************/

proc sql;
	create table A_3_Set_00 as
 		select	a.*, b.*
		from &INSET. (where=(not missing(Ticker))) a left join names_02 b
		on a.Ticker = b.tic;
quit;

/*  Set up dataset for manual verificaition */

data A_3_Set_01;
	retain BoardName conm;
	format NewCIK $10.;
	format FullCIK $10.;
	set A_3_Set_00;
	where not missing(GVKEY);
	if length(CIKCode) lt 10 then newCIK = cats(repeat('0',10-1-length(CIKCode)),CIKCode);
	FullCIK = coalescec(NewCIK,CIKCode);
	if cik = fullCIK then KKMatch = 1;
	if COMP_CUSIP = cusip then CCMatch = 1;
	drop CRSP_Cusip isin sic naics NewCIK;
run;
proc sort data=A_3_Set_01;
	by KKMatch CCMatch;
quit;

proc export 
  data=A_3_Set_01 
  dbms=xlsx 
  outfile="C:\Users\Attila Balogh\Dropbox\1-University\__toread\Manual_match-20171101.xlsx" 
  replace;
run;

data A_3_Set_01;
	set A_3_Set_00;
	where not missing(GVKEY);
	drop CRSP_Cusip isin sic naics;
run;

/*  Create a Match_3 indicator for observations matched in this round         */

%let keepvars_03 = &keepvars. Match_3;

data AB_App_03;
	retain &keepvars_03.;
	set A_3_Set_01;
	where not missing(gvkey);
	Match_3 = 1;
	keep &keepvars_03.;
run;

/*******************************************************************************/
/*                      Matching Rounds 4-7 Prerequisites                      */
/*******************************************************************************/

/*  Extend effective start dates to the first day of the year */
data dsenames;
	set crsp.dsenames_&dataver.;
run;
data Ccmxpf_lnkhist;
	set crsp.Ccmxpf_lnkhist_&dataver.;
run;

/*  -------------------------------------------------------------------------  */
/*               Matching Round 4 - BoardEx -> CRSP -> Compustat               */
/*                         using CUSIP and CRSP dates                          */
/*  _________________________________________________________________________  */

/*  -------------------------------------------------------------------------  */
/*  Matching Round 4 - Matching on:*/
/*  1./ BoardEx CUSIP -> to CRSP CUSIP (crsp.dsenames) - with date range match */
/*  2./ CRSP CUSIP -> CRSP PERMNO (crsp.Ccmxpf_lnkhist)                        */
/*  3./ CRSP PERMNO -> Compustat GVKEY                                         */
/*  ---> Conditional on LINKHIST date ranges                                   */
/*  _________________________________________________________________________  */



/*  -------------------------------------------------------------------------  */
/*  Obtain CUSIP - PERMNO combinations                                         */
/*  Here we are not interested in a temporal element in matching, only in      */
/*  identifying combinations. The time interval element will come in later     */

/*  NCUSIP is the appropriate variable to use, not CUSIP , which is historical */

%include "BCM_Link_4.sas" ;


/*******************************************************************************/
/*               Matching Round 5 - BoardEx -> CRSP -> Compustat               */
/*                       using CUSIP and Compustat dates                       */
/*******************************************************************************/

/*******************************************************************************/
/*  CCM reverse lookup step for CUSIP                                          */
/*******************************************************************************/

/*  This needs to be a separate branch, because it knocked out the 2004 match for AT&T */

/*  Obtain list of unique BoardID-GVKEY combinations identified in Branch 4    */

proc sort data=A_4_Set_03 out=A_5_Set_00 nodupkey ;
	by BoardID gvkey;
run;
data A_5_Set_00;
	set A_5_Set_00;
	where not missing(gvkey);
	keep BoardID gvkey linkprim LIID;
run;

/*******************************************************************************/
/*  Match resulting set to the COMP.NAMES dataset, a modified version of which */
/*  is names_02, where the StartYear and EndYear variables were created      */

proc sql;
	create table A_5_Set_01 as
 		select	a.*,  b.*
		from A_5_Set_00 (rename=gvkey=gvkeyA) a left join names_02 (keep=gvkey StartYear EndYear) b
		on a.gvkeyA = b.gvkey;
quit;

/*******************************************************************************/
/*  Original dataset that needs matching (A_1_input) matched to newly acquired */
/*  GVKEYs and their validity date: this time form COMP instead of CRSP        */

proc sql;
	create table A_5_Set_02 as
 		select	a.*, b.*
		from &INSET. a, A_5_Set_01 b
		where a.BoardID = b.BoardID
		order by BoardName
	;
quit;

/*	Duplicates due to LINKPRIM C & N for some OBSs					*/
/*	http://www.crsp.com/products/documentation/link-history-data	*/

data A_5_Set_03;
	set A_5_Set_02;
	if linkprim = 'P' then lpid = 4;
	if linkprim = 'J' then lpid = 3;
	if linkprim = 'C' then lpid = 2;
	if linkprim = 'N' then lpid = 1;
	if linkprim = '' then lpid = 0;
run;

/*******************************************************************************/
/*  The following approach on sorting and eliminating duplicates ensures that  */
/*  the desired observations remain only, with preference for: P > J > C > N   */

proc sort data=A_5_Set_03;
	by BoardID gvkey descending lpid;
run;

proc sort data=A_5_Set_03 out=A_5_Set_04 nodupkey;
	by BoardID gvkey;
run;

/*******************************************************************************/
/*  Finalize Branch 5 before merge                                             */
/*  NB: the Branch 5 match is denoted Match_4 to indicate its superiority to   */
/*      the previous step                                                      */


%let keepvars_04 = &keepvars. Match_4;

data AB_App_04;
	retain &keepvars_04.;
	set A_5_Set_04;
	where not missing(gvkey);
	Match_4 = 1;
	keep &keepvars_04.;
run;

/*******************************************************************************/
/*  Branches 6 and 7 are analogous to branches 4 and 5, but match on Ticker    */
/*******************************************************************************/

/*******************************************************************************/
/*               Matching Round 6 - BoardEx -> CRSP -> Compustat               */
/*                         using TICKER and CRSP dates                         */
/*******************************************************************************/

proc sql;
	create table A_6_Set_00 as
 		select	a.*, b.*
		from &INSET. (where=(not missing(Ticker))) a, dsenames (keep=comnam namedt nameendt ticker permno rename=ticker=tickerB) b
		where a.Ticker = b.tickerB
		order by BoardName
	;
quit;

proc sort data=A_6_Set_00 out=A_6_Set_01 nodupkey;
	by BoardID permno;
run;



/* To aid visual inspection  */
proc sort data=A_6_Set_00;
	by BoardName Tyear;
run;

data A_6_Set_01;
	set A_6_Set_00;
	if linkprim = 'P' then lpid = 4;
	if linkprim = 'J' then lpid = 3;
	if linkprim = 'C' then lpid = 2;
	if linkprim = 'N' then lpid = 1;
	if linkprim = '' then lpid = 0;
run;

/*******************************************************************************/
/*  The following approach on sorting and eliminating duplicates ensures that  */
/*  the desired observations remain only, with preference for: P > J > C > N   */

proc sort data=A_6_Set_01;
	by BoardID Tyear descending lpid;
run;

proc sort data=A_6_Set_01 out=A_6_Set_02 nodupkey;
	by BoardID Tyear;
run;


/*******************************************************************************/
/*  Finalize Branch 6 before merge                                             */
/*  NB: the Branch 6 match is denoted Match_7 to indicate its inferiority to   */
/*      the next step, that will be derived through this step                  */

%let keepvars_07 = &keepvars_47. Match_7;

data AB_App_07;
	retain &keepvars_07.;
	set A_6_Set_02;
	where not missing(gvkey);
	Match_7 = 1;
	keep &keepvars_07.;
run;

/*******************************************************************************/
/*               Matching Round 7 - BoardEx -> CRSP -> Compustat               */
/*                       using TICKER and Compustat dates                      */
/*******************************************************************************/

/*******************************************************************************/
/*  CCM reverse lookup step for CUSIP                                          */
/*******************************************************************************/

/*  Obtain list of unique BoardID-GVKEY combinations identified in Branch 6    */

proc sort data=A_6_Set_00 out=A_7_Set_00 nodupkey ;
	by BoardID gvkey;
run;
data A_7_Set_00;
	set A_7_Set_00;
	where not missing(gvkey);
	keep BoardID gvkey linkprim LIID;
run;

/*******************************************************************************/
/*  Match resulting set to the COMP.NAMES dataset, a modified version of which */
/*  is names_02, where the StartYear and EndYear variables were created      */

proc sql;
	create table A_7_Set_01 as
 		select	a.*,  b.*
		from A_7_Set_00 (rename=gvkey=gvkeyA) a left join names_02 (keep=gvkey StartYear EndYear) b
		on a.gvkeyA = b.gvkey;
quit;

/*******************************************************************************/
/*  Original dataset that needs matching (A_1_input) matched to newly acquired */
/*  GVKEYs and their validity date: this time form COMP instead of CRSP        */

proc sql;
	create table A_7_Set_02 as
 		select	a.*, b.*
		from &INSET. (keep=BoardID BoardName DateStartRole DateEndRole Tyear) a left join A_7_Set_01 b
		on a.BoardID = b.BoardID and b.StartYear <= a.TYear <= b.EndYear;
quit;

/*	Duplicates due to LINKPRIM C & N for some OBSs					*/
/*	http://www.crsp.com/products/documentation/link-history-data	*/

data A_7_Set_03;
	set A_7_Set_02;
	if linkprim = 'P' then lpid = 4;
	if linkprim = 'J' then lpid = 3;
	if linkprim = 'C' then lpid = 2;
	if linkprim = 'N' then lpid = 1;
	if linkprim = '' then lpid = 0;
run;

/*******************************************************************************/
/*  The following approach on sorting and eliminating duplicates ensures that  */
/*  the desired observations remain only, with preference for: P > J > C > N   */

proc sort data=A_7_Set_03;
	by BoardID Tyear descending lpid;
run;

proc sort data=A_7_Set_03 out=A_7_Set_04 nodupkey;
	by BoardID Tyear;
run;

/*******************************************************************************/
/*  Finalize Branch 7 before merge                                             */
/*  NB: the Branch 7 match is denoted Match_6 to indicate its superiority to   */
/*      the previous step                                                      */


%let keepvars_06 = &keepvars_47. Match_6;

data AB_App_06;
	retain &keepvars_06.;
	set A_7_Set_04;
	where not missing(gvkey);
	Match_6 = 1;
	keep &keepvars_06.;
run;

/*******************************************************************************/
/*                     Matching Round 8 - Manual matching                      */
/*******************************************************************************/

/*******************************************************************************/
/*  Identify firms that we lost such early in the process and save them for    */
/*  manual identification in Round 8                                           */
/*******************************************************************************/

data A_8_Set_00;
	retain BoardID BoardName;
	set boardex.Na_wrds_company_profile;
	where missing(ISIN) and missing(Ticker) and missing(CIKCode) and OrgType in('Quoted');
	keep BoardID BoardName;
run;

proc sort data=A_8_Set_00 out=A_8_Set_01 nodupkey ;
	by BoardID BoardName;
run;

/*
%include "&path\003-Comp-BoardEx_Manual.sas" ;
*/

/*******************************************************************************/
/*  It is important that this file uses the original Input file not the one    */
/*  that had been prepared for matching rounds 1-7 and noted as INSET          */
/*******************************************************************************/

/*  Identify missing firms with an impossible macth were identified above as    */
/*  A_8_Set_01 and another dataset will be generated once the full match has    */
/*  been completed: dataset name: */

proc sql;
	create table A_8_Set_02 as
 		select	a.*, b.*
		from &input. a left join MMatch_01 (rename=BoardID=BoardID_B drop=BoardName) b
		on a.BoardID = b.BoardID_B;
quit;
proc sort data=A_8_Set_02;
	by BoardName TYear;
run;
data A_8_Set_03;
	set A_8_Set_02;
	where not missing(gvkey);
run;

/*******************************************************************************/
/*  Restrict matches to years where Compustat has data for GVKEY. This is not  */
/*  a strict condition, but provides a better indication of the quality of the */
/*  final match                                                                */
/*******************************************************************************/

proc sql;
	create table A_8_Set_04 as
 		select	a.DirectorID, a.BoardID, a.DateStartRole, a.DateEndRole, a.TYear, a.BoardName, a.NR, a.gvkey as gvkeyA, b.*
		from A_8_Set_03 (where=(not missing(gvkey)))  a left join names_02 (keep=gvkey StartYear EndYear)  b
		on a.gvkey = b.gvkey
			and b.StartYear <= a.TYear <= b.EndYear
		;
quit;
proc sort data=A_8_Set_04;
	by BoardName TYear;
run;

%let keepvars_08 = &keepvars_47. Match_8;

data AB_App_08;
	retain &keepvars_08.;
	set A_8_Set_02;
	where not missing(gvkey);
	Match_8 = 1;
	keep &keepvars_08.;
run;

/*******************************************************************************/
/*        This code consolidates the result of multiple matching steps         */
/*******************************************************************************/

/*  Not al elegant solution, temporary  */

data A_0_set_03;
	set &inset. A_8_set_10;
run;
proc sort data=A_0_set_03 out=A_0_set_04 nodupkey ;
	by BoardID;
run;

/*  Back to normal */

proc sql;
	create table A0_Matched_01 as
 		select	a.*,
				b.BoardID as BoardID_b, 
				b.Match_1, b.gvkey as gvkey_1,
				c.Match_2, c.gvkey as gvkey_2,
				d.Match_3, d.permno, d.namedt, d.nameendt,
				e.Match_4, e.gvkey as gvkey_4,
				f.Match_5, f.gvkey as gvkey_5,
				i.Match_8, i.Match_10, i.gvkey as gvkey_8,
			coalesce(gvkey_1,gvkey_2,gvkey_4,gvkey_5,gvkey_8) as gvkey,
			sum(Match_1,Match_2,Match_4,Match_5,Match_8) as Match
		from A_0_set_04 a left join AB_App_01 b
		on a.BoardID = b.BoardID
		left join AB_App_02 c
		on a.BoardID = c.BoardID
		left join A_4_Set_02 d
		on a.BoardID = d.BoardID
		left join AB_App_04 e
		on a.BoardID = e.BoardID
		left join AB_App_05 f
		on a.BoardID = f.BoardID
		left join AB_App_08 i
		on a.BoardID = i.BoardID
		order by BoardName
		;
quit;



proc sort data=A0_Matched_01 out=A0_Matched_02 nodupkey;
	by BoardID gvkey;
run;
data A0_Matched_03;
	set A0_Matched_01;
	Matchpattern = cats(Match_1,Match_2,Match_3,Match_4,Match_5);
	if Matchpattern in('1...') then Linktype = 'CC';
	if Matchpattern in('.1..') then Linktype = 'CK';
	if Matchpattern in('11..') then Linktype = 'CX';

	if Matchpattern in('..1.') then Linktype = 'CR';
	if Matchpattern in('...1') then Linktype = 'CS';
	if Matchpattern in('..11') then Linktype = 'BB';
	if Matchpattern in('1.11') then Linktype = 'BC';
	if Matchpattern in('.111') then Linktype = 'BD';
	if Matchpattern in('1111') then Linktype = 'BE';
	if Matchpattern in('11111') then Linktype = 'BF';
	if Match_8 = 1 then Linktype = 'MA';
	if Match_10 = 1 then Linktype = 'MN';
	label LinkType = "Link Type";
	label BoardID = "BoardEx BoardID";
	label GVKEY = "Compustat GVKEY";
	keep BoardID gvkey permno namedt nameendt SDC_CUSIP Linktype Matchpattern Match;
run;
proc sort data=A0_Matched_03;
	by LinkType;
run;

%let finalvars = BoardID Linktype gvkey SDC_CUSIP permno namedt nameendt;

data Bcm_link_&dd. /* BCM_Link.Bcm_link Bcm_link.Bcm_link_&dd. */;
	retain &finalvars.;
	set A0_Matched_03;
	where (not missing(Linktype) or not missing(permno));
	keep &finalvars.;
run;
proc sort data=Bcm_link_&dd. out=Bcm_link_&dd. nodupkey;
	by &finalvars.;
run;

data BCM_Link.Bcm_link Bcm_link.Bcm_link_&dd.;
	set Bcm_link_&dd.;
run;

proc sort data=Bcm_link_&dd. out=Bcm_link_&dd.;
	by SDC_CUSIP permno gvkey;
run;

proc freq data=Bcm_link_&dd.;
	tables LinkType ;
run;

/* Additional benefit of CRSP */
proc freq data=A0_Matched_01;
	tables Match_: ;
run;

data A0_Matched_01_00;
	set A0_Matched_01;
	if ((Match_1=1) or (Match_2=1)) then CX = 1;
	if (Match_1=1) and (Match_2=1) and (Match_4=1) and (Match_5=1) then Direct_2 = 1;
	if (Match_1 ne 1) and (Match_2 ne 1) and (Match_4=1) and (Match_5=1) then Direct_3 = 1;
	if (Match_1=1) and (Match_2=1) and (Match_4 ne 1) and (Match_5 ne 1) then Direct_4 = 1;
	if (Match_4 = 1) and (Match_5 = 1) then Direct_CRSP = 1;
	if (Match_4 = 1) then Direct_CRSP_1 = 1;
	if (Match_5 = 1) then Direct_CRSP_2 = 1;
	if (Match_4 = 1) and (Match_5 ne 1) then Direct_CRSP_1not2 = 1;
	if (Match_4 ne 1) and (Match_5 = 1) then Direct_CRSP_2not1 = 1;
run;

proc freq data=A0_Matched_01_00;
	tables Direct: ;
run;

/* END Additional benefit of CRSP */


proc freq data=BCM_Link.Bcm_link_20171030;
	tables LinkType ;
run;



proc freq data=Boardex.Na_wrds_company_profile;
	tables OrgType ;
run;

proc sort data=Boardex.Na_wrds_company_profile out=profile nodupkey;
	by BoardID;
run;
proc freq data=profile;
	tables CountryOfQuote;
run;

proc sort data=Boardex.Na_wrds_company_names out=names nodupkey;
	by BoardID;
run;
data names2;
	set names;
	if find(ISIN,'US','i') ge 1 then US = 1;
	if US ne 1 then delete;
run;
data names2;
	set names;
	if find(ISIN,'US','i') ge 1 then US = 1;
	if US ne 1 then delete;
run;

proc freq data=names2;
	tables US;
run;

/*
proc sql;
	create table A0_Matched_01 as
 		select	a.BoardName, a.BoardID, a.DirectorID, a.DateStartRole, a.DateEndRole, a.TYear,
				a.caliper_0, a.caliper_1, a.caliper_2,
				a.Event_0, a.Event_1, a.Event_2, a.Appt_Seq, a.i,
				b.BoardID as BoardID_b, 
				b.Match_1, b.gvkey as gvkey_1,
				c.Match_2, c.gvkey as gvkey_2,
				d.Match_3, d.gvkey as gvkey_3,
				e.Match_4, e.gvkey as gvkey_4,
				f.Match_5, f.gvkey as gvkey_5,
				g.Match_6, g.gvkey as gvkey_6,
				h.Match_7, h.gvkey as gvkey_7,
				i.Match_8, i.gvkey as gvkey_8,
			coalesce(gvkey_1,gvkey_2,gvkey_3,gvkey_4,gvkey_5,gvkey_6,gvkey_7,gvkey_8) as gvkey,
			sum(Match_1,Match_2,Match_3,Match_4,Match_5,Match_6,Match_7,Match_8) as Match
		from &input. a left join AB_App_01 b
		on a.BoardID = b.BoardID and a.TYear = b.TYear
		left join AB_App_02 c
		on a.BoardID = c.BoardID and a.TYear = c.TYear
		left join AB_App_03 d
		on a.BoardID = d.BoardID and a.TYear = d.TYear
		left join AB_App_04 e
		on a.BoardID = e.BoardID and a.TYear = e.TYear
		left join AB_App_05 f
		on a.BoardID = f.BoardID and a.TYear = f.TYear
		left join AB_App_06 g
		on a.BoardID = g.BoardID and a.TYear = g.TYear
		left join AB_App_07 h
		on a.BoardID = h.BoardID and a.TYear = h.TYear
		left join AB_App_08 i
		on a.BoardID = i.BoardID and a.TYear = i.TYear;
quit;

*/
/*  Cleaning up the dataset */
proc sort data=A0_Matched_01;
	by BoardName TYear;
run;

/*******************************************************************************/
/*                             Matching diagnostics                            */
/*                             --------------------                            */
/*******************************************************************************/

/*                         Data probing and statistics                         */

proc freq data = A0_Matched_01; 
	tables Match ; 
run;

/*  Sort by BoardID and TYear for easier visual inspection                   */
proc sort data=A0_Matched_01;
	by BoardID TYear;
run;

proc sql;
	select
		count(BoardID) as Entry_count,
		count(distinct BoardID) as Firm_count,
		count(distinct DirectorID) as DIR_count
	from A0_Matched_01 where (not missing(gvkey) and (caliper_2 eq 1));
quit;

/*******************************************************************************/
/*	Creating a dummy for Matched observations will allow removing firms that   */
/*  do not have GVKEY observations for any of the time periods                 */
/*******************************************************************************/

data A0_Matched_01_01;
	set A0_Matched_01;
/*	Match dummmy*/
	if not missing(Match) then Match_d = 1; else Match_d = 0;
	drop Match_1-Match_8 gvkey_1-gvkey_8 BoardID_b;
run;

/*  Adding back GVKEY availability periods */
proc sql;
	create table A0_Matched_02 as
 		select	a.*, b.gvkey as gvkey_9, b.StartYear, b.EndYear
		from A0_Matched_01_01 a left join Names_02 b
		on a.gvkey = b.gvkey;
quit;

/*  Cleaning up the dataset */
proc sort data=A0_Matched_02;
	by BoardName TYear;
run;

/*******************************************************************************/
/*  Int_d is a different take on matching diagnostic as it looks for a real    */
/*  match: it captures observations where there is a GVKEY, but no firm-year   */
/*  match                                                                      */
/*******************************************************************************/
/*  Match_d adds nothing */


/*******************************************************************************/

%let mvars =	BoardName BoardID DirectorID apptID gvkey
				DateStartRole DateEndRole StartYear EndYear TYear
				/*Match_d*/ Int_d
				Caliper_0 Caliper_1 Caliper_2
				Caliper_0_d Caliper_1_d Caliper_2_d
				Event_0 Event_1 Event_2 Appt_Seq i;

data A0_Matched_03;
	retain &mvars.;
	set A0_Matched_02;
/*	Interval dummy*/
	if (EndYear >= TYear >= StartYear) then Int_d = 1; else Int_d = 0;
/*	Availability for Caliper_0*/
	Caliper_0_d = (Int_d * Caliper_0);
/*	Availability for Caliper_1*/
	Caliper_1_d = (Int_d * Caliper_1);
/*	Availability for Caliper_1*/
	Caliper_2_d = (Int_d * Caliper_2);
	apptID = catx('-',BoardID,DirectorID);
	keep &mvars.;
run;

/*  Identify firms with either zero GVKEY match, or with a match but missing   */
/*  overlap in firm-year and gvkey-year combinations                           */

proc sql;
	create table A0_Matched_04
	as select *,	/*mean(Match_d) format=8.2 as Match_DMean, */
					mean(Int_d) format=8.2 as Int_DMean,
					mean(Caliper_0_d) format=8.2 as Caliper_0_dMean,
					mean(Caliper_1_d) format=8.2 as Caliper_1_dMean,
					mean(Caliper_2_d) format=8.2 as Caliper_2_dMean
	from A0_Matched_03
	group by apptID
	order by BoardName, TYear;
quit;
proc sort data=A0_Matched_04;
	by BoardName TYear;
quit;
/*******************************************************************************/
/*                              Save final dataset                             */
/*                              ~~~~~~~~~~~~~~~~~~                             */
/*******************************************************************************/
proc sql;
	select
		count(BoardID) as Entry_count,
		count(distinct BoardID) as Firm_count,
		count(distinct DirectorID) as DIR_count
	from A0_Matched_04 where (Caliper_0_dMean eq 1);
quit;
proc sql;
	select
		count(BoardID) as Entry_count,
		count(distinct BoardID) as Firm_count,
		count(distinct DirectorID) as DIR_count
	from A0_Matched_04 where (Caliper_1_dMean eq 1);
quit;
proc sql;
	select
		count(BoardID) as Entry_count,
		count(distinct BoardID) as Firm_count,
		count(distinct DirectorID) as DIR_count
	from A0_Matched_04 where (Caliper_2_dMean eq 1);
quit;

data A0_Matched_05 &dset._Matched;
	set A0_Matched_04;
	ned_31 = .;
	CEO_21 = .;
	&dset. = 1;
	if ned_31 eq 1 then NED = 1;
	else if CEO_21 eq 1 then NED = 0;
	else NED = .;
run;

/*******************************************************************************/
/*                            Identify missing firms                           */
/*******************************************************************************/

/*  First use the original input dataset and join the matched dataset         */
proc sql;
	create table A1_Matched_01 as
 		select	a.*, b.*
		from &INSET. a left join A0_Matched_03 b
		on a.BoardID = b.BoardID and a.TYear = b.TYear;
quit;

/*  Second: keep only firms with no GVKEY in any of the TYear period, which   */
/*  means an unidentified firm                                                */

proc sort data=A1_Matched_01;
	by BoardName descending gvkey;
run;
proc sort data=A1_Matched_01 out=A1_Matched_02 nodupkey;
	by BoardID;
run;
data A1_Matched_03;
	set A1_Matched_02;
	where missing(gvkey);
run;

/*  The following dataset provides the list of unmatched firms               */
proc sort data=A1_Matched_03;
	by BoardName;
run;

/*  The REV dummy confirms that the enry has been manually added and the NR */
/*  indicator confirms that there is no match for the BoardEx firm in COMP  */
proc sql;
	create table A1_Matched_04 as
 		select	a.*, b.*
		from A1_Matched_03  a left join  MMatch_01 b
		on a.BoardID = b.BoardID;
quit;
proc sort data=A1_Matched_04;
	by BoardName;
run;

/*  Finally, this should yield and empty dataset */
data A1_Matched_05;
	set A1_Matched_04;
	where missing(REV);
run;

/*  Housecleaning  */

/*

Proc datasets memtype=data nolist;
	delete A: ;
	delete X: ;
quit;

*/


/* *************************************************************************** */
/* *************************  Attila Balogh, 2017  *************************** */
/* *************************************************************************** */
