/*  -------------------------------------------------------------------------  */
/*                                                                             */
/*               Data matching for corporate governance research               */
/*                                                                             */
/*  Program      : Lookup.sas                                                  */
/*  Author       : Attila Balogh, School of Banking and Finance                */
/*                 UNSW Business School, UNSW Sydney                           */
/*  Date Created : 27 Feb 2018                                                 */
/*  Last Modified: 27 Feb 2018                                                 */
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

/*  -------------------------------------------------------------------------  */
/*  Manual matching                                                            */

/*  Enter search term                                                          */
%let str = 'TOSE';

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

%let gvk = '022915';

data Lookup_03;
	set comp.funda;
	where gvkey in(&gvk.);
run;

data Lookup_02;
	set comp.names;
	where upcase(conm) contains &str.;
	where (gvkey in('121934')) or (gvkey in('066465'));
run;



/*  ---|---------------------------------------------------------------------  */
/*  ///\\\                                                                     */
/*  |----|  Program end: Lookup.sas                                            */
/*  \\\///                                                                     */
/*  ___|_____________________________________________________________________  */

/*  -------------------------------------------------------------------------  */
/*       ---------------       Attila Balogh, 2018       ---------------       */
/*  -------------------------------------------------------------------------  */
