/*  -------------------------------------------------------------------------  */
/*                                                                             */
/*               Data matching for corporate governance research               */
/*                                                                             */
/*  Program      : CCM_Link_Tables.sas                                         */
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


ods tagsets.tablesonlylatex file="C:\Users\Attila Balogh\Dropbox\Research\B2017b\x_2355.tex" (notop nobot) newfile=table;

data x_2355;
	set boardex.Na_wrds_company_profile_&dataver.;
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

ods tagsets.tablesonlylatex file="C:\Users\Attila Balogh\Dropbox\Research\B2017b\x_872265.tex" (notop nobot) newfile=table;

data x_872265;
	set boardex.Na_wrds_company_profile_&dataver.;
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


ods tagsets.tablesonlylatex file="C:\Users\Attila Balogh\Dropbox\Research\B2017b\x_15917.tex" (notop nobot) newfile=table;

data x_15917;
	set boardex.Na_wrds_company_profile_&dataver.;
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


ods tagsets.tablesonlylatex file="C:\Users\Attila Balogh\Dropbox\Research\B2017b\x_1710.tex" (notop nobot) newfile=table;

data x_15917;
	set A_1_set_02;
	where BoardID eq 1710;
	Company_Name = propcase(BoardName); label Company_Name  = "Company Name";
	label BoardID = "Board ID";
	label gvkey = "GVKEY";
	label CIKCode = "CIK Code";
run;
proc print data=x_15917 noobs label;
	var BoardID Company_Name CIKCode gvkey;
run;
quit;

ods tagsets.tablesonlylatex close;

ods tagsets.tablesonlylatex file="C:\Users\Attila Balogh\Dropbox\Research\B2017b\x_001045.tex" (notop nobot) newfile=table;

data x_001045;
	set A_2_set_03;
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

ods tagsets.tablesonlylatex file="C:\Users\Attila Balogh\Dropbox\Research\B2017b\x_87054.tex" (notop nobot) newfile=table;

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

ods tagsets.tablesonlylatex file="C:\Users\Attila Balogh\Dropbox\Research\B2017b\x_37045V.tex" (notop nobot) newfile=table;

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

ods tagsets.tablesonlylatex file="C:\Users\Attila Balogh\Dropbox\Research\B2017b\x_088606.tex" (notop nobot) newfile=table;

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
