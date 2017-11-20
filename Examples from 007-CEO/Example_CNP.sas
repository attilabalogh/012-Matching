/*******************************************************************************/
/*                                                                             */
/*                      Example: Centerpoint Energy (CNP)                      */
/*                                                                             */
/*  Program      : Example_CNP.sas                                             */
/*  Author       : Attila Balogh, School of Banking and Finance                */
/*                 UNSW Business School, UNSW Sydney                           */
/*  Date Created : September 13, 2017                                          */
/*  Last Modified: September 13, 2017                                          */
/*                                                                             */
/*  Description  : Matching example                                            */
/*                                                                             */
/*                 Section titles represent references to                      */
/*                 Balogh, A 2017                                              */
/*                 Data matching for corporate governance research             */
/*                                                                             */
/*******************************************************************************/

/*  CCM reverse lookup example                                                 */

/*  Piper Jaffray Companies matching problem example                           */
/*  Steps:                                                                     */

/*******************************************************************************/
/*  Setting out sample data                                                    */
/*******************************************************************************/

/*  1.-- Obtaining BoardEx CUSIP            */
data X_6271_01;
	set boardex.Na_wrds_company_names;
	where BoardID eq 6271;
run;
data X_6271_02;
	set boardex.Na_dir_profile_emp;
	where (CompanyID eq 6271) and (DirectorID eq 83282);
	if DateEndRole eq .C then DateEndRole = today();
	keep CompanyID CompanyName DirectorID DateStartRole DateEndRole;
run;

/*  2.-- Creating director-year observations   */
data X_6271_03;
	set X_6271_02;
		do i = 0 to intck('year',DatestartRole,DateEndRole);
      		TYear=intnx('year',DatestartRole,i,'b');
      		output;
      	end;
	format TYear year4.;
	drop i;
run;
proc sort data=X_6271_03 nodupkey;
	by CompanyID Tyear;
run;

proc sql;
	create table X_6271_04 as
 		select a.*,	b.BoardID, b.Ticker, b.ISIN, b.CIKCode,
					substr(b.isin,3,9) as COMP_Cusip,
					substr(b.isin,3,8) as CRSP_Cusip
		from X_6271_03 a left join boardex.Na_wrds_company_profile b
		on a.CompanyID = b.BoardID;
quit;
proc sort data=X_6271_04 nodupkey;
	by CompanyID Tyear Ticker ISIN CIKCode;
run;
/*  Extend effective start dates to the first day of the year */
data dsenames;
	format namedty year4.;
	set crsp.dsenames;
	NAMEDTy=mdy(1,1,year(NAMEDT));
run;
data Ccmxpf_lnkhist;
	format LINKDTy year4.;
	set crsp.Ccmxpf_lnkhist;
	LINKDTy=mdy(1,1,year(LINKDT));
run;
/*******************************************************************************/
/*  Sample data step complete                                                  */
/*******************************************************************************/

proc sql;
	create table X_6271_05 as
 		select	a.*, b.*, c.*
		from X_6271_04 (where=(not missing(Ticker))) a left join dsenames (keep=namedt namedty nameendt ticker permno) b
		on a.Ticker = b.ticker and ( (b.NAMEDT <= a.TYear <= b.NAMEENDT) or (a.TYEAR = b.namedty) )
		left join Ccmxpf_lnkhist c
		on b.permno = c.lpermno &andlt &andld;
quit;

/* To aid visual inspection  */
proc sort data=X_6271_05;
	by CompanyName Tyear;
run;

data X_6271_06;
	set X_6271_05;
	if linkprim = 'P' then lpid = 4;
	if linkprim = 'J' then lpid = 3;
	if linkprim = 'C' then lpid = 2;
	if linkprim = 'N' then lpid = 1;
	if linkprim = '' then lpid = 0;
run;

/*******************************************************************************/
/*  The following approach on sorting and eliminating duplicates ensures that  */
/*  the desired observations remain only, with preference for: P > J > C > N   */

proc sort data=X_6271_06;
	by CompanyID Tyear descending lpid;
run;

/* *************************************************************************** */
/* *************************  Attila Balogh, 2017  *************************** */
/* *************************************************************************** */
