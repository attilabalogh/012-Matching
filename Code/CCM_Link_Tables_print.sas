/*  -------------------------------------------------------------------------  */
/*                                                                             */
/*               Data matching for corporate governance research               */
/*                                                                             */
/*  Program      : CCM_Link_Tables_print.sas                                   */
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

%let texpath = C:\Users\Attila Balogh\Dropbox\Research\012-Matching\Paper\Tables;

ods tagsets.tablesonlylatex file="&texpath.\x_1720679_1.tex" (notop nobot) newfile=table;
proc print data=x_1720679_1 noobs label; run; quit;
ods tagsets.tablesonlylatex close;

ods tagsets.tablesonlylatex file="&texpath.\x_1720679_2.tex" (notop nobot) newfile=table;
proc print data=x_1720679_2 noobs label; run; quit;
ods tagsets.tablesonlylatex close;


ods tagsets.tablesonlylatex file="&texpath.\x_2355.tex" (notop nobot) newfile=table;
proc print data=x_2355 noobs label;
	where BoardID eq 2355;
	var BoardID Company_Name AdvisorName AdvTypeDesc;
/*	Title 'Title goes here';*/
run;
quit;
ods tagsets.tablesonlylatex close;

ods tagsets.tablesonlylatex file="&texpath.\x_872265.tex" (notop nobot) newfile=table;
proc print data=x_872265 noobs label;
	where BoardID eq 872265;
	var BoardID Company_Name ISIN;
run;
quit;
ods tagsets.tablesonlylatex close;


ods tagsets.tablesonlylatex file="&texpath.\x_15917.tex" (notop nobot) newfile=table;
proc print data=x_15917 noobs label;
	where BoardID eq 15917;
	var BoardID Company_Name ISIN;
run;
quit;
ods tagsets.tablesonlylatex close;

ods tagsets.tablesonlylatex file="&texpath.\x_1710.tex" (notop nobot) newfile=table;
proc print data=x_1710 noobs label;
run;
quit;
ods tagsets.tablesonlylatex close;

ods tagsets.tablesonlylatex file="&texpath.\x_001045.tex" (notop nobot) newfile=table;
proc print data=x_001045 noobs label;run;quit;
ods tagsets.tablesonlylatex close;

ods tagsets.tablesonlylatex file="&texpath.\x_87054.tex" (notop nobot) newfile=table;
proc print data=x_87054 noobs label;
	run;
quit;
ods tagsets.tablesonlylatex close;

ods tagsets.tablesonlylatex file="&texpath.\x_37045V.tex" (notop nobot) newfile=table;
proc print data=x_37045V noobs label;
run;
quit;
ods tagsets.tablesonlylatex close;

ods tagsets.tablesonlylatex file="&texpath.\x_088606.tex" (notop nobot) newfile=table;
proc print data=x_088606 noobs label;
run;
quit;
ods tagsets.tablesonlylatex close;

ods tagsets.tablesonlylatex file="&texpath.\x_88148.tex" (notop nobot) newfile=table;
proc print data=x_88148 noobs label;run;quit;
ods tagsets.tablesonlylatex close;

ods tagsets.tablesonlylatex file="&texpath.\x_109823.tex" (notop nobot) newfile=table;
proc print data=x_109823 noobs label;run;quit;
ods tagsets.tablesonlylatex close;

ods tagsets.tablesonlylatex file="&texpath.\x_003226.tex" (notop nobot) newfile=table;
proc print data=x_003226 noobs label;run;quit;
ods tagsets.tablesonlylatex close;

ods tagsets.tablesonlylatex file="&texpath.\x_stats.tex" (notop nobot) newfile=table;
proc print data=x_stats noobs label;run;quit;
ods tagsets.tablesonlylatex close;




/*  -------------------------------------------------------------------------  */
/* *************************  Attila Balogh, 2017  *************************** */
/*  -------------------------------------------------------------------------  */
