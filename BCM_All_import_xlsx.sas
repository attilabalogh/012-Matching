/*  -------------------------------------------------------------------------  */
/*                                                                             */
/*               Data matching for corporate governance research               */
/*                                                                             */
/*  Program      : BXRow_Import.sas                                            */
/*  Author       : Attila Balogh, School of Banking and Finance                */
/*                 UNSW Business School, UNSW Sydney                           */
/*  Date Created :  8 Nov 2017                                                 */
/*  Last Modified:  8 Nov 2017                                                 */
/*                                                                             */
/*  Description  : Import non-US BoardEx data to SAS                           */
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
libname bxrow "G:\Dropbox\Datasets\BoardEx\20171108-ROW" ;

%let rpath = C:\Users\Attila Balogh\Dropbox\1-University\Dataset\BCM_Link\ROW\ ;
%let bxrow_1=ROW - Board Summary.xlsx;
%let bxrow_2=ROW - Company Details.xlsx;
%let bxrow_3=ROW - Org Analysis Averages.xlsx;
%let bxrow_4=ROW - SMDEs Org Summary.xlsx;
%let bxrow_5=UK - Board Summary.xlsx;
%let bxrow_6=UK - Company Details.xlsx;
%let bxrow_7=UK - Org Analysis Averages.xlsx;
%let bxrow_8=UK - SMDEs Org Summary.xlsx;
%let bxrow_9=Europe - Board Summary.xlsx;
%let bxrow_10=Europe - Company Details.xlsx;
%let bxrow_11=Europe - Org Analysis Averages.xlsx;
%let bxrow_12=Europe - SMDEs Org Summary.xlsx;


/*
proc import out = bxrow_1
	datafile="C:\Users\Attila Balogh\Dropbox\1-University\Dataset\BCM_Link\ROW\ROW - Company Details.xlsx" dbms=xlsx replace ;
	run;


proc import	out = A_test (keep=CompanyID_ Company_Name ISIN)
			datafile = "&rpath.&bxrow_1."
			dbms=xlsx replace;
			getnames = yes;
run;

data A_test_1;
	format CompanyID 12.;
	set A_test;
	CompanyID = CompanyID_;
	keep CompanyID ISIN;
run;
*/
%macro BXdl();
		%do i=1 %to 12 %by 1;

proc import	out = bxrow_&i._00
			datafile = "&rpath.&&bxrow_&i"
			dbms=xlsx replace;
			getnames = yes;
run;
data bxrow_&i._01;
	format CompanyID 12.;
	set bxrow_&i._00;
	CompanyID = CompanyID_;
	keep CompanyID ISIN;
run;

proc sort data=bxrow_&i._01 nodupkey;
	by CompanyID ISIN;
quit;

proc sql noprint;
	select max(countw(ISIN,',')) into : n from bxrow_&i._01;
quit;
data bxrow_&i._02;
 set bxrow_&i._01;
 where not missing(ISIN);
 array ISIN_{&n} $ 40;
 do i=1 to countw(ISIN,',');
  ISIN_{i}=scan(ISIN,i,',');
 end;
 drop i ISIN ;
run;

proc sort data=bxrow_&i._02 nodupkey;
	by CompanyID;
quit;

proc transpose data=bxrow_&i._02 out=bxrow_&i._03;
   by CompanyID;
   var ISIN_: ;
run;

data bxrow_&i._04;
 set bxrow_&i._03;
 where not missing(col1);
 ISIN = cats(col1);
 drop _NAME_ col1;
run;

proc sort data=bxrow_&i._04 out=bxrowF_&i. nodupkey;
	by CompanyID ISIN;
quit;

	%end;
%mend;%BXdl;

data bxrowX_00;
	format CompanyID 12.;
	set bxrowF_: ;
run;

proc sort data=bxrowX_00 out=bxrowX_01 nodupkey;
	by CompanyID ISIN;
quit;

data BCM_Link.BoardID_ROW;
	set bxrowX_01 ;
run;
