/*******************************************************************************/
/*                                                                             */
/*                    Example: Tiffany & Co (TIF)                              */
/*                                                                             */
/*  Program      : Example_TIF.sas                                             */
/*  Author       : Attila Balogh, School of Banking and Finance                */
/*                 UNSW Business School, UNSW Sydney                           */
/*  Date Created : September 15, 2017                                          */
/*  Last Modified: September 15, 2017                                          */
/*                                                                             */
/*  Description  : Matching example                                            */
/*                                                                             */
/*                 Section titles represent references to                      */
/*                 Balogh, A 2017                                              */
/*                 Data matching for corporate governance research             */
/*                                                                             */
/*******************************************************************************/

/*  AWE counter example is companyid=2885, DirectorID= 36507   */

/*  CCM reverse lookup example                                                 */

/*  Piper Jaffray Companies matching problem example                           */
/*  Steps:                                                                     */

/*******************************************************************************/
/*  Setting out sample data                                                    */
/*******************************************************************************/

%let BoardID = 30723;
%let DirectorID = 42901;
%let GVKEY = '013646';

/*  1.-- Obtaining BoardEx CUSIP            */
data X_&BoardID._01;
	set boardex.Na_wrds_company_names;
	where BoardID eq &BoardID.;
run;
data X_&BoardID._02;
	set boardex.Na_dir_profile_emp;
	where (CompanyID eq &BoardID.) and (DirectorID eq &DirectorID.);
	if DateEndRole eq .C then DateEndRole = today();
	keep CompanyID CompanyName DirectorID DateStartRole DateEndRole;
run;

/*  2.-- Creating director-year observations   */
data X_&BoardID._03;
	set X_&BoardID._02;
		do i = 0 to intck('year',DatestartRole,DateEndRole);
      		TYear=intnx('year',DatestartRole,i,'b');
      		output;
      	end;
	format TYear year4.;
	drop i;
run;
proc sort data=X_&BoardID._03 nodupkey;
	by CompanyID Tyear;
run;

proc sql;
	create table X_&BoardID._04 as
 		select a.*,	b.BoardID, b.Ticker, b.ISIN, b.CIKCode,
					substr(b.isin,3,9) as COMP_Cusip,
					substr(b.isin,3,8) as CRSP_Cusip
		from X_&BoardID._03 a left join boardex.Na_wrds_company_profile b
		on a.CompanyID = b.BoardID;
quit;
proc sort data=X_&BoardID._04 nodupkey;
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

/*  3.-- Matches to CRSP CUSIP    */

/*  Select only desired link types  */
%let andlt = %str(and LINKTYPE in ('LC' 'LU' 'LX' 'LD' 'LS' 'LN'));
/*	Match on data range            */
%let andld = and (LINKDT <= TYear or LINKDT = .B or LINKDTy = TYear) and (TYear <= LINKENDDT or LINKENDDT = .E);

proc sql;
	create table X_&BoardID._05 as
 		select	a.*, b.*
		from X_&BoardID._04 (where=(not missing(CRSP_Cusip))) a left join dsenames (keep=namedt namedty nameendt ncusip permno) b
		on a.CRSP_Cusip = b.ncusip and ( (b.NAMEDT <= a.TYear <= b.NAMEENDT) or (a.TYEAR = b.namedty) );
quit;

/*  Sort to aid visual inspection  */
proc sort data=X_&BoardID._05;
	by CompanyID Tyear;
run;

/*  4.-- Matching GVKEY to PERMNO conditional on CRSP dates  */

proc sql;
	create table X_&BoardID._06 as
 		select	a.*, b.*, c.*
		from X_&BoardID._04 (where=(not missing(CRSP_Cusip))) a left join dsenames (keep=namedt namedty nameendt ncusip permno) b
		on a.CRSP_Cusip = b.ncusip and ( (b.NAMEDT <= a.TYear <= b.NAMEENDT) or (a.TYEAR = b.namedty) )
		left join Ccmxpf_lnkhist c
		on b.permno = c.lpermno &andlt &andld;
quit;

/*  Sort to aid visual inspection  */
proc sort data=X_&BoardID._06;
	by CompanyID Tyear;
run;

/*******************************************************************************/
/*  Looking up the identified GVKEY, it provides a match from 2001 to 2004     */

data X_&BoardID._07;
	set crsp.Ccmxpf_lnkhist;
	where GVKEY in(&GVKEY.);
run;

/*******************************************************************************/
/*  Examining the resulting GVKEY reveals that it is a valid identifier for  */
/*  the period between 1997 and 2003  */

data X_&BoardID._08;
	set comp.names;
	where GVKEY in(&GVKEY.);
run;

/*  Conclusion:                                                                */
/*  Employing both approaches may yield financial data from 1997 to 2004       */

/* *************************************************************************** */
/* *************************  Attila Balogh, 2017  *************************** */
/* *************************************************************************** */
