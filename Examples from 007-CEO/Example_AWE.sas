/*******************************************************************************/
/*                                                                             */
/*                    Example: AT&T Wireless Services (AWE)                    */
/*                                                                             */
/*  Program      : Example_AWE.sas                                             */
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

/*  AWE counter example is companyid=2885, DirectorID= 36507   */

/*  CCM reverse lookup example                                                 */

/*  Piper Jaffray Companies matching problem example                           */
/*  Steps:                                                                     */

/*******************************************************************************/
/*  Setting out sample data                                                    */
/*******************************************************************************/

/*  1.-- Obtaining BoardEx CUSIP            */
data X_2885_01;
	set boardex.Na_wrds_company_names;
	where BoardID eq 2885;
run;
data X_2885_02;
	set boardex.Na_dir_profile_emp;
	where (CompanyID eq 2885) and (DirectorID eq 36507);
	if DateEndRole eq .C then DateEndRole = today();
	keep CompanyID CompanyName DirectorID DateStartRole DateEndRole;
run;

/*  2.-- Creating director-year observations   */
data X_2885_03;
	set X_2885_02;
		do i = 0 to intck('year',DatestartRole,DateEndRole);
      		TYear=intnx('year',DatestartRole,i,'b');
      		output;
      	end;
	format TYear year4.;
	drop i;
run;
proc sort data=X_2885_03 nodupkey;
	by CompanyID Tyear;
run;

proc sql;
	create table X_2885_04 as
 		select a.*,	b.BoardID, b.Ticker, b.ISIN, b.CIKCode,
					substr(b.isin,3,9) as COMP_Cusip,
					substr(b.isin,3,8) as CRSP_Cusip
		from X_2885_03 a left join boardex.Na_wrds_company_profile b
		on a.CompanyID = b.BoardID;
quit;
proc sort data=X_2885_04 nodupkey;
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
	create table X_2885_05 as
 		select	a.*, b.*
		from X_2885_04 (where=(not missing(CRSP_Cusip))) a left join dsenames (keep=namedt namedty nameendt ncusip permno) b
		on a.CRSP_Cusip = b.ncusip and ( (b.NAMEDT <= a.TYear <= b.NAMEENDT) or (a.TYEAR = b.namedty) );
quit;

/*  Sort to aid visual inspection  */
proc sort data=X_2885_05;
	by CompanyID Tyear;
run;

/*  4.-- Matching GVKEY to PERMNO conditional on CRSP dates  */

proc sql;
	create table X_2885_06 as
 		select	a.*, b.*, c.*
		from X_2885_04 (where=(not missing(CRSP_Cusip))) a left join dsenames (keep=namedt namedty nameendt ncusip permno) b
		on a.CRSP_Cusip = b.ncusip and ( (b.NAMEDT <= a.TYear <= b.NAMEENDT) or (a.TYEAR = b.namedty) )
		left join Ccmxpf_lnkhist c
		on b.permno = c.lpermno &andlt &andld;
quit;

/*  Sort to aid visual inspection  */
proc sort data=X_2885_06;
	by CompanyID Tyear;
run;

/*******************************************************************************/
/*  Looking up the identified GVKEY, it provides a match from 2001 to 2004     */

data X_2885_07;
	set crsp.Ccmxpf_lnkhist;
	where GVKEY in('134845');
run;

/*******************************************************************************/
/*  Examining the resulting GVKEY reveals that it is a valid identifier for  */
/*  the period between 1997 and 2003  */

data X_2885_08;
	set comp.names;
	where GVKEY in('134845');
run;

/*  Conclusion:                                                                */
/*  Employing both approaches may yield financial data from 1997 to 2004       */

/* *************************************************************************** */
/* *************************  Attila Balogh, 2017  *************************** */
/* *************************************************************************** */
