/*******************************************************************************/
/*                                                                             */
/*                    Example: Piper Jaffray Companies (PJC)                   */
/*                                                                             */
/*  Program      : Example_PJC.sas                                             */
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
data X_24515_01;
	set boardex.Na_wrds_company_names;
	where BoardID eq 24515;
run;
data X_24515_02;
	set boardex.Na_dir_profile_emp;
	where (CompanyID eq 24515) and (DirectorID eq 34171);
	if DateEndRole eq .C then DateEndRole = today();
	keep CompanyID CompanyName DirectorID DateStartRole DateEndRole;
run;

/*  2.-- Creating director-year observations   */
data X_24515_03;
	set X_24515_02;
		do i = 0 to intck('year',DatestartRole,DateEndRole);
      		TYear=intnx('year',DatestartRole,i,'b');
      		output;
      	end;
	format TYear year4.;
	drop i;
run;
proc sort data=X_24515_03 nodupkey;
	by CompanyID Tyear;
run;

proc sql;
	create table X_24515_04 as
 		select a.*,	b.BoardID, b.Ticker, b.ISIN, b.CIKCode,
					substr(b.isin,3,9) as COMP_Cusip,
					substr(b.isin,3,8) as CRSP_Cusip
		from X_24515_03 a left join boardex.Na_wrds_company_profile b
		on a.CompanyID = b.BoardID;
quit;
proc sort data=X_24515_04 nodupkey;
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
	create table X_24515_05 as
 		select	a.*, b.*
		from X_24515_04 (where=(not missing(CRSP_Cusip))) a left join dsenames (keep=namedt namedty nameendt ncusip permno) b
		on a.CRSP_Cusip = b.ncusip and ( (b.NAMEDT <= a.TYear <= b.NAMEENDT) or (a.TYEAR = b.namedty) );
quit;

/*  Sort to aid visual inspection  */
proc sort data=X_24515_05;
	by CompanyID Tyear;
run;

/*  ...It is apparent that multiple PERMNOs are matched to the same CUSIP in various years... */

/*  4.-- Matching GVKEY to PERMNO conditional on CRSP dates  */

proc sql;
	create table X_24515_06 as
 		select	a.*, b.*, c.*
		from X_24515_04 (where=(not missing(CRSP_Cusip))) a left join dsenames (keep=namedt namedty nameendt ncusip permno) b
		on a.CRSP_Cusip = b.ncusip and ( (b.NAMEDT <= a.TYear <= b.NAMEENDT) or (a.TYEAR = b.namedty) )
		left join Ccmxpf_lnkhist c
		on b.permno = c.lpermno &andlt &andld;
quit;

/*  Sort to aid visual inspection  */
proc sort data=X_24515_06;
	by CompanyID Tyear;
run;

/*  However, lookingup the identified GVKEY, it belongs to multiple PERMNOs   */
/*  Two of them are confirmed and the other, non-matched PERMNO is identified */
/*  as the primary PERMN for the firm */

data X_24515_07;
	set crsp.Ccmxpf_lnkhist;
	where GVKEY in('008605');
run;

/*  Examining the resulting GVKEY reveals that it is a valid identifier for  */
/*  the period between 1974 and 2016  */

data X_24515_08;
	set comp.names;
	where GVKEY in('008605');
run;

/* *************************************************************************** */
/* *************************  Attila Balogh, 2017  *************************** */
/* *************************************************************************** */
