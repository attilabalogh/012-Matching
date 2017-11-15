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


ods tagsets.tablesonlylatex file="C:\Users\Attila Balogh\Dropbox\Research\012-Matching\Paper\Tables\x_2355.tex" (notop nobot) newfile=table;

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
proc print data=x_2355 noobs label;
	where BoardID eq 2355;
	var BoardID Company_Name AdvisorName AdvTypeDesc;
/*	Title 'Title goes here';*/
run;
quit;

ods tagsets.tablesonlylatex close;

ods tagsets.tablesonlylatex file="C:\Users\Attila Balogh\Dropbox\Research\012-Matching\Paper\Tables\x_872265.tex" (notop nobot) newfile=table;

data x_872265;
	set boardex.Na_wrds_company_profile;
	where BoardID eq 872265;
	if BoardID eq 872265 then BoardName = 'LEGACYTEXAS FINANCIAL GROUP INC';
	if AdvisorName in('Computershare Investor Services LLC') then AdvisorName = "Computershare Investor Services";
	if AdvisorName in('Computershare Trust Co NA (Formerly Known as EquiServe Trust Company NA)') then AdvisorName = "Computershare Trust Co NA";
	Company_Name = propcase(BoardName); label Company_Name  = "Company Name";
	label BoardID = "Board ID";
run;
proc print data=x_872265 noobs label;
	where BoardID eq 872265;
	var BoardID Company_Name ISIN;
run;
quit;

ods tagsets.tablesonlylatex close;


ods tagsets.tablesonlylatex file="C:\Users\Attila Balogh\Dropbox\Research\012-Matching\Paper\Tables\x_15917.tex" (notop nobot) newfile=table;

data x_15917;
	set boardex.Na_wrds_company_profile;
	where BoardID eq 15917;
	Company_Name = propcase(BoardName); label Company_Name  = "Company Name";
	label BoardID = "Board ID";
run;
proc print data=x_15917 noobs label;
	where BoardID eq 15917;
	var BoardID Company_Name ISIN;
run;
quit;

ods tagsets.tablesonlylatex close;

data examples;
	array examples[3] (2107, 1748237, 2021732);
	set boardex.Na_wrds_company_names boardex.Na_wrds_company_profile;;
	if BoardID in examples then output;
run;

ods tagsets.tablesonlylatex file="C:\Users\Attila Balogh\Dropbox\Research\012-Matching\Paper\Tables\x_1710.tex" (notop nobot) newfile=table;

data x_15917_1;
	set boardex.Na_wrds_company_names;
	where BoardID eq 1710;
	Company_Name = propcase(BoardName); label Company_Name  = "Company Name";
	COMP_Cusip = substr(isin,3,9);
	label BoardID = "Board ID";
/*	label gvkey = "GVKEY";*/
	label CIKCode = "CIK Code";
run;
proc sql;
	create table x_15917_2 as
 		select a.BoardID, propcase(BoardName) as Company_Name, a.CIKCode, cats(b.gvkey) as GVKEY
		from x_15917_1 (where=(BoardID eq 1710)) a left join comp.names b
		on a.COMP_Cusip = b.cusip
		order by BoardName
	;
quit;
proc print data=x_15917 noobs label;
run;
quit;

ods tagsets.tablesonlylatex close;

ods tagsets.tablesonlylatex file="C:\Users\Attila Balogh\Dropbox\Research\012-Matching\Paper\Tables\x_001045.tex" (notop nobot) newfile=table;

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
/*  Remove duplicate entries                                                   */
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
data x_001045;
	set x_A_2_Set_03;
	where GVKEY in('001045');
	if BoardID eq 2021732 then BoardName = 'AMERICAN AIRLINES GROUP INC ';
	Company_Name = propcase(BoardName); label Company_Name  = "Company Name";
	label BoardID = "Board ID";
	label gvkey = "GVKEY";
	label CIKCode = "CIK Code";
run;
proc print data=x_001045 noobs label;
	var BoardID Company_Name CIKCode gvkey;
run;
quit;

ods tagsets.tablesonlylatex close;

ods tagsets.tablesonlylatex file="C:\Users\Attila Balogh\Dropbox\Research\012-Matching\Paper\Tables\x_87054.tex" (notop nobot) newfile=table;

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
proc print data=x_87054 noobs label;
	run;
quit;

ods tagsets.tablesonlylatex close;

/*  BX_SDC_Link.sas */

ods tagsets.tablesonlylatex file="C:\Users\Attila Balogh\Dropbox\Research\012-Matching\Paper\Tables\x_37045V.tex" (notop nobot) newfile=table;

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
proc print data=x_37045V noobs label;
run;
quit;

ods tagsets.tablesonlylatex close;

ods tagsets.tablesonlylatex file="C:\Users\Attila Balogh\Dropbox\Research\012-Matching\Paper\Tables\x_088606.tex" (notop nobot) newfile=table;

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
proc print data=x_088606 noobs label;
	Title 'Compustat Names Table';
run;
quit;

ods tagsets.tablesonlylatex close;



/*  -------------------------------------------------------------------------  */
/* *************************  Attila Balogh, 2017  *************************** */
/*  -------------------------------------------------------------------------  */
