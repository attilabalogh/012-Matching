/*  -------------------------------------------------------------------------  */
/*                                                                             */
/*               Data matching for corporate governance research               */
/*                                                                             */
/*  Program      : Lookup.sas                                                  */
/*  Author       : Attila Balogh, School of Banking and Finance                */
/*                 UNSW Business School, UNSW Sydney                           */
/*  Date Created : 27 Feb 2018                                                 */
/*  Last Modified: 22 Mar 2018                                                 */
/*                                                                             */
/*  Description  : Lookup to for manual matching between BoardEx and Comustat  */
/*                                                                             */
/*  Notes        : Please reference the following paper when using this code   */
/*                 Balogh, A 2017                                              */
/*                 Data matching for corporate governance research             */
/*                 Available at SSRN: https://ssrn.com/abstract=3053405        */
/*                                                                             */
/*  _________________________________________________________________________  */

data Na_wrds_company_profile;
	set boardex.Na_wrds_company_profile;
run;

data funda;
	set comp.funda;
run;

/*  -------------------------------------------------------------------------  */
/*  Manual matching                                                            */

/*  Enter search term                                                          */
%let str = 'COLOMBO';

data Lookup_01;
	set Na_wrds_company_profile;
	where upcase(BoardName) contains &str.;
run;
proc sort data=Lookup_01;
	by BoardName;
run;
data Lookup_02;
	set comp.company;
	where upcase(conm) contains &str.;
run;
proc sort data=Lookup_02;
	by conm;
run;

%let gvk = '023062';
%let gvk = '016791';

data Lookup_03;
	set funda;
	where gvkey in(&gvk.);
	keep gvkey datadate fyear oancf ivncf fincf;
run;

data Lookup_02;
	set comp.names;
	where upcase(conm) contains &str.;
/*	where (gvkey in('121934')) or (gvkey in('066465'));*/
run;

data Lookup_04;
	set crsp.dsenames;
/*	where upcase(COMNAM) contains &str.;*/
	where ticker in('IFSB');
run;

data Lookup_04;
	set crsp.dsenames;
	where permno in(87404);
run;

data Lookup_05;
	set CCM_Link;
	where gvkey in('111629');
run;

data x_Lookup_04;
	set ceo.Firm_descriptives_20180219;
	where gvkey in('026863');
run;

/*  ---|---------------------------------------------------------------------  */
/*  ///\\\                                                                     */
/*  |----|  Program end: Lookup.sas                                            */
/*  \\\///                                                                     */
/*  ___|_____________________________________________________________________  */

/*  -------------------------------------------------------------------------  */
/*       ---------------       Attila Balogh, 2018       ---------------       */
/*  -------------------------------------------------------------------------  */
