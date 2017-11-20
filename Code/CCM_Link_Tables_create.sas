/*  -------------------------------------------------------------------------  */
/*                                                                             */
/*               Data matching for corporate governance research               */
/*                                                                             */
/*  Program      : CCM_Link_Tables_create.sas                                  */
/*  Author       : Attila Balogh, School of Banking and Finance                */
/*                 UNSW Business School, UNSW Sydney                           */
/*  Date Created :  1 Nov 2017                                                 */
/*  Last Modified:  7 Nov 2017                                                 */
/*                                                                             */
/*  Description  : BX Link Exaple tables                                       */
/*                                                                             */
/*  Notes        : Please reference the following paper when using this code   */
/*                 Balogh, A 2017                                              */
/*                 Data matching for corporate governance research             */
/*                 Available at SSRN: https://ssrn.com/abstract=3053405        */
/*                                                                             */
/*  _________________________________________________________________________  */

/*  Petrohawk multiple BoardIDs*/

%let keep = BoardID Company_Name CIKCode COMP_Cusip OrgType;
data x_1720679_1;
	retain &keep.;
	set boardex.Na_wrds_company_profile;
	where (BoardID = 1720679) or (BoardID = 637778);
	if BoardID eq 872265 then BoardName = 'LEGACYTEXAS FINANCIAL GROUP INC';
	Company_Name = propcase(BoardName); label Company_Name  = "Board Name";
	if Company_Name in('Petrohawk Energy Corp (Beta Oil & Gas Prior To 07/2004) (De-Listed 08/2011)') then Company_Name = "Petrohawk Energy (De-Listed 08/2011)";
	if Company_Name in('Petrohawk Energy Corp') then Company_Name = "Petrohawk Energy";
	label BoardID = "Board ID";
	COMP_Cusip = substr(isin,3,9);
	label COMP_Cusip = "CUSIP";
	label CIKCode = "CIK";
	label OrgType = "Type";
	keep &keep.;
run;

%let keep = gvkey comnam2 cik cusip year1 year2;
data x_1720679_2;
	retain &keep.;
	set comp.names;
	where gvkey in('121934');
	comnam2 = propcase(conm);
	label comnam2 = "Company Name";
	label year1 = "Start";
	label year2 = "End";
	label gvkey = "GKEY";
	label CIK = "CIK";
	label tic = "Ticker";
	keep &keep.;
run;

/*  CRSP Collapse example */

data x_001045_20;
	set crsp.Ccmxpf_lnkhist ;
/*	where gvkey in('001045');*/
	label lpermno = "PERMNO";
	label lpermco = "PERMCO";
	label gvkey = "GVKEY";
	label linkdt = "Link Start";
	label linkenddt = "Link End";
	label linkprim = "Primary";
	label liid = "Link ID";
	label linktype = "Type";
run;
proc sort data=x_001045_20;
	by gvkey lpermno lpermco linkdt linkenddt;
run;

/**/

data x_2355;
	set boardex.Na_wrds_company_profile;
	where BoardID eq 2355;
	if BoardID eq 2355 then BoardName = 'APPLE INC';
	if AdvisorName in('Computershare Investor Services LLC') then AdvisorName = "Computershare Investor Services";
	if AdvisorName in('Computershare Trust Co NA (Formerly Known as EquiServe Trust Company NA)') then AdvisorName = "Computershare Trust Co NA";
	Company_Name = propcase(BoardName);
	label BoardID = "Board ID";
	label Company_Name  = "Company Name";
	label AdvisorName = "Advisor Name";
	label AdvTypeDesc = "Advisor Type";
run;

/**/

data x_872265;
	set boardex.Na_wrds_company_profile;
	where BoardID eq 872265;
	if BoardID eq 872265 then BoardName = 'LEGACYTEXAS FINANCIAL GROUP INC';
	if AdvisorName in('Computershare Investor Services LLC') then AdvisorName = "Computershare Investor Services";
	if AdvisorName in('Computershare Trust Co NA (Formerly Known as EquiServe Trust Company NA)') then AdvisorName = "Computershare Trust Co NA";
	Company_Name = propcase(BoardName); label Company_Name  = "Company Name";
	label BoardID = "Board ID";
run;

/**/

data x_15917;
	set boardex.Na_wrds_company_profile;
	where BoardID eq 15917;
	Company_Name = propcase(BoardName); label Company_Name  = "Company Name";
	label BoardID = "Board ID";
run;

/**/

data x_1710_1;
	set boardex.Na_wrds_company_names;
	where BoardID eq 1710;
	Company_Name = propcase(BoardName); label Company_Name  = "Company Name";
	COMP_Cusip = substr(isin,3,9);
	label BoardID = "Board ID";
/*	label gvkey = "GVKEY";*/
	label CIKCode = "CIK Code";
run;
proc sql;
	create table x_1710 as
 		select a.BoardID, propcase(BoardName) as Company_Name, a.CIKCode, cats(b.gvkey) as GVKEY
		from x_1710_1 (where=(BoardID eq 1710)) a left join comp.names b
		on a.COMP_Cusip = b.cusip
		order by BoardName
	;
quit;

/**/

data x_A_0_Set_00;
	set Boardex.Na_wrds_company_names boardex.Na_wrds_company_profile;
	where not missing(BoardID) and (not missing(ISIN) or not missing(Ticker) or not missing(CIKCode));
	COMP_Cusip = substr(isin,3,9);
	CRSP_Cusip = substr(isin,3,8);
	SDC_Cusip = substr(isin,3,6);
	label SDC_Cusip = "SDC CUSIP";
	if not missing(SDC_Cusip) then Match_31 = 1;
	keep BoardID BoardName ISIN Ticker CIKCode COMP_Cusip CRSP_Cusip SDC_Cusip Match_31;
run;
data x_A_2_Set_00;
	format NewCIK $10.;
	format FullCIK $10.;
	set x_A_0_Set_00;
	where not missing(CIKCode);
	if length(CIKCode) lt 10 then newCIK = cats(repeat('0',10-1-length(CIKCode)),CIKCode);
	FullCIK = coalescec(NewCIK,CIKCode);
	drop NewCIK;
run;
proc sort data=x_A_2_Set_00 out=x_A_2_Set_01;
	by BoardID descending FullCIK;
run;
proc sort data=x_A_2_Set_01 out=x_A_2_Set_02 nodupkey ;
	by BoardID FullCIK;
run;
proc sql;
	create table x_A_2_Set_03 as
 		select	a.*, b.*
		from x_A_2_Set_02 a left join comp.names b
		on a.FullCIK = b.cik
		order by BoardID
	;
quit;

%let keep = BoardID Company_Name CIKCode gvkey;
data x_001045;
	retain &keep.;
	set x_A_2_Set_03;
	where GVKEY in('001045');
	if BoardID eq 2021732 then BoardName = 'AMERICAN AIRLINES GROUP INC ';
	Company_Name = propcase(BoardName); label Company_Name  = "Company Name";
	label BoardID = "Board ID";
	label gvkey = "GVKEY";
	label CIKCode = "CIK";
	keep &keep.;
run;

/**/

data x_87054;
	retain permno comnam2 namedt nameendt ncusip naics;
	format namedt MMDDYY10.;
	format nameendt MMDDYY10.;
	set crsp.dsenames;
	where permno eq 87054;
	comnam2 = propcase(comnam);
	label comnam2 = "Company Name";
	label namedt = "Start Date";
	label nameendt = "End Date";
	label naics = "NAICS";
	keep permno namedt nameendt comnam2 ncusip naics ;
run;

/*  Axonyx one permno multiple gvkey */

%let keep = permno comnam2 namedt nameendt ticker;
data x_88148;
	retain &keep.;
	format namedt MMDDYY10.;
	format nameendt MMDDYY10.;
	set crsp.dsenames;
	where permno eq 88148;
	comnam2 = propcase(comnam);
	label comnam2 = "Company Name";
	label namedt = "Start Date";
	label nameendt = "End Date";
	label naics = "NAICS";
	keep &keep.;
run;

%let keep = gvkey PERMNO comnam2 tic cusip year1 year2;
data x_109823;
	retain &keep.;
	set comp.names;
	where gvkey in('109823','161088','175660');
	comnam2 = propcase(conm);
	PERMNO = 88148;
	label comnam2 = "Company Name";
	label year1 = "Start";
	label year2 = "End";
	label gvkey = "GKEY";
	label tic = "Ticker";
	keep &keep.;
run;
proc sort data=x_109823;
	by year1;
run;


/*  Comcast one gvkey multiple permno */

%let keep = permno comnam2 namedt nameendt ticker cusip;
data x_003226;
	retain &keep.;
	format namedt MMDDYY10.;
	format nameendt MMDDYY10.;
	set crsp.dsenames;
	where permno in(11997,25022,89525);
	comnam2 = propcase(comnam);
	label comnam2 = "Company Name";
	label namedt = "Start Date";
	label nameendt = "End Date";
	label naics = "NAICS";
	keep &keep.;
run;
proc sort data=x_003226;
	by permno namedt;
run;

/**/

data x_37045V;
	retain gvkey comnam2 tic cusip SDC_Cusip cik year1 year2;
	set comp.names;
	SDC_Cusip = substr(cusip,1,6);
	where substr(cusip,1,6) in('37045V');
	comnam2 = propcase(conm);
	label comnam2 = "Company Name";
/*	label year1 = "Start";*/
/*	label year2 = "End";*/
	label gvkey = "GKEY";
	label tic = "Ticker";
	label SDC_Cusip = "SDC Cusip";
	keep gvkey comnam2 tic cusip SDC_Cusip cik;
run;

/**/

data x_088606;
	retain gvkey comnam2 tic cusip SDC_Cusip cik year1 year2;
	set comp.names;
	SDC_Cusip = substr(cusip,1,6);
	where substr(cusip,1,6) in('088606');
	comnam2 = propcase(conm);
	if comnam2 in('Bhp Billiton Group (Aus)') then comnam2 = "BHP Billiton Group (Aus)";
	label comnam2 = "Company Name";
/*	label year1 = "Start";*/
/*	label year2 = "End";*/
	label gvkey = "GKEY";
	label tic = "Ticker";
	label SDC_Cusip = "SDC Cusip";
	keep gvkey comnam2 tic cusip SDC_Cusip cik;
run;

/*  Final Stats*/


proc freq data=BX_Link.Bx_Comp_Link;
	tables LinkType /noprint out=x_stats_00;
run;
%let keep = linktype Desc count;
data x_stats;
	retain &keep.;
	format count comma12.;
	format Desc $50.;
	set x_stats_00;
	label count = "Matches";
	label Desc = "Description";
	if Linktype in('LC') then Desc = "Link based on the CUSIP identifier";
	if Linktype in('LK') then Desc = "Link established based on the CIK Code";
	if Linktype in('LM') then Desc = "Manually researched match";
	if Linktype in('LN') then Desc = "No available link, confirmed by research";
	if Linktype in('LR') then Desc = "Match through CRSP Permno";
	if Linktype in('LX') then Desc = "Link established based on both CUSIP and CIK Code";
	if Linktype in('LY') then Desc = "CUSIP or CIK confirmed by manual research";
	keep &keep.;
run;

/**/

Proc datasets memtype=data nolist;
	delete x_a: X_15917_1 X_15917_2;
quit;
proc copy in=work out=BX_Link;
      select x_: ;
run;

/*  -------------------------------------------------------------------------  */
/* *************************  Attila Balogh, 2017  *************************** */
/*  -------------------------------------------------------------------------  */
