/*  -------------------------------------------------------------------------  */
/*  Round 4 Start                                                              */
/*  _________________________________________________________________________  */


/*  Remove duplicate entries                                                   */

proc sort data=&INSET. out=A_4_Set_00;
	by BoardID descending CRSP_Cusip;
run;
proc sort data=A_4_Set_00 out=A_4_Set_01 nodupkey ;
	by BoardID CRSP_Cusip;
run;

/*  Matching step                                                              */

proc sql;
	create table A_4_Set_00 as
 		select	a.BoardID, a.BoardName, a.CRSP_CUSIP,
				b.permno, b.namedt, b.nameendt, b.ncusip, b.comnam
		from A_4_Set_01 (where=(not missing(CRSP_Cusip))) a, crsp.dsenames_&dataver. b
		where a.CRSP_Cusip = b.ncusip
		order by BoardID, permno, namedt, nameendt
	;
quit;


/*  -------------------------------------------------------------------------  */
/*  Step 2                                                                     */
/*  Collapse link table                                                        */

data A_4_Set_01;
    set A_4_Set_00;
    by BoardID permno namedt nameendt;
    format prev_ldt prev_ledt yymmddn8.;
    retain prev_ldt prev_ledt;
    if first.permno then do;
        if last.permno then do;
/*  Keep this obs if it's the first and last matching permno pair              */
            output;           
        end;
        else do;
/*  If it's the first but not the last pair, retain the dates for future use   */
            prev_ldt = namedt;
            prev_ledt = nameendt;
            output;
            end;
        end;   
    else do;
        if namedt=prev_ledt+1 or namedt=prev_ledt then do;
/*  If the date range follows the previous one, assign the previous namedt     */
/*  value to the current - will remove the redundant in later steps.           */
/*  Also retain the link end date value                                        */
            namedt = prev_ldt;
            prev_ledt = nameendt;
            output;
            end;
        else do;
/* If it doesn't fall into any of the above conditions, just keep it and       */
/* retain the link date range for future use                                   */
            output;
            prev_ldt = namedt;
            prev_ledt = nameendt;
            end;
        end;
/*    drop prev_ldt prev_ledt;*/
run;

data A_4_Set_02;
	retain BoardID permno comnam namedt nameendt;
	set A_4_Set_01;
	by BoardID permno namedt;
	if last.namedt;
  /* remove redundant observations with identical namedt (result of the previous data step), so that
     each consecutive pair of observations will have either different GVKEY-IID-PERMNO match, or
     non-consecutive link date range
   */
	label BoardID = "BoardEx Board ID";
	label permno = "CRSP Permno";
	label namedt = "CRSP Names Date";
	label nameendt = "CRSP Names Ending Date";
	drop comnam BoardName CRSP_CUSIP ncusip;
run;

/*  Delete dupliates                                                          */

proc sort data=A_4_Set_02 out=A_4_Set_03 nodupkey ;
	by BoardID permno namedt;
quit;

/*  -------------------------------------------------------------------------  */
/*  Matching round 3 final seteps                                              */
/*  Save dataset of successfully matched observations                          */
/*  Create a Match_21 indicator for observations matched in this round          */

%let keepvars_21 = BoardID permno namedt nameendt Match_21;

data AB_App_21;
	retain &keepvars_21.;
	set A_4_Set_03;
	where not missing(permno);
	Match_21 = 1;
	keep &keepvars_21.;
run;


/*  -------------------------------------------------------------------------  */
/*  Step 3                                                                     */
/*  Create CRSP/Compustat Matched collapsed link table                         */
/*  The CCM Link steps are based on ccm_lnktable.sas by WRDS/M. Duan           */
/*  -------------------------------------------------------------------------  */

/*  Select only desired link types                                             */

%let linktype = %str(LINKTYPE in ('LC' 'LU' 'LX' 'LD' 'LS' 'LN'));
proc sql;
	create table CCM_Link_01 as select *
		from crsp.ccmxpf_lnkhist_&dataver.
		where &linktype.        
		order by gvkey, lpermno, lpermco, linkdt, linkenddt
		;
quit;

/*  -------------------------------------------------------------------------  */
/*  Collapse link table                                                        */

data CCM_Link_02;
    set CCM_Link_01;
    by gvkey lpermno lpermco linkdt linkenddt;
    format prev_ldt prev_ledt yymmddn8.;
    retain prev_ldt prev_ledt;
    if first.lpermno then do;
        if last.lpermno then do;
/*  Keep this obs if it's the first and last matching permno pair              */
            output;           
        end;
        else do;
/*  If it's the first but not the last pair, retain the dates for future use   */
            prev_ldt = linkdt;
            prev_ledt = linkenddt;
            output;
            end;
        end;   
    else do;
        if linkdt=prev_ledt+1 or linkdt=prev_ledt then do;
/*  If the date range follows the previous one, assign the previous linkdt     */
/*  value to the current - will remove the redundant in later steps.           */
/*  Also retain the link end date value                                        */
            linkdt = prev_ldt;
            prev_ledt = linkenddt;
            output;
            end;
        else do;
/* If it doesn't fall into any of the above conditions, just keep it and       */
/* retain the link date range for future use                                   */
            output;
            prev_ldt = linkdt;
            prev_ledt = linkenddt;
            end;
        end;
    drop prev_ldt prev_ledt;
run;

data CCM_Link_03;
  set CCM_Link_02;
  by gvkey lpermno linkdt;
  if last.linkdt;
  /* remove redundant observations with identical LINKDT (result of the previous data step), so that
     each consecutive pair of observations will have either different GVKEY-IID-PERMNO match, or
     non-consecutive link date range
   */
run;
proc sort data=CCM_Link_03;
	by lpermno;
run;

%let andld = and (LINKDT <= namedt or LINKDT = .B) and (nameendt <= LINKENDDT or LINKENDDT = .E);

proc sql;
create table A_4_Set_03 as
 		select *
		from A_4_Set_02 a left join CCM_Link_03 b
		on a.permno = b.lpermno;
quit;

/*  -------------------------------------------------------------------------  */
/*  Step 4                                                                     */
/*  Match PERMOs to GVKEY based on time intervals                              */



/*	Duplicates due to LINKPRIM C & N for some OBSs					*/
/*	http://www.crsp.com/products/documentation/link-history-data	*/

data A_4_Set_04;
	set A_4_Set_03;
	if linkprim = 'P' then lpid = 4;
	if linkprim = 'J' then lpid = 3;
	if linkprim = 'C' then lpid = 2;
	if linkprim = 'N' then lpid = 1;
	if linkprim = '' then lpid = 0;
run;

/*******************************************************************************/
/*  The following approach on sorting and eliminating duplicates ensures that  */
/*  the desired observations remain only, with preference for: P > J > C > N   */

proc sort data=A_4_Set_03 out=A_4_Set_03 nodupkey;
	by BoardID gvkey;
run;

/*******************************************************************************/
/*  Finalize Branch 4 before merge                                             */
/*  NB: the Branch 4 match is denoted Match_5 to indicate its inferiority to   */
/*      the next step, that will be derived through this step                  */

%let keepvars_47 = BoardID gvkey BoardName linkdt linkenddt;
%let keepvars_05 = &keepvars_47. Match_5;

data AB_App_05;
	retain &keepvars_05.;
	set A_4_Set_03;
	where not missing(gvkey);
	Match_5 = 1;
	keep &keepvars_05.;
run;


/*  Identify duplicates and show number of successful matches                  */

proc sql;
	select
	count(BoardID) as BoardID_count,
	count(gvkey) as CIK_count,
	count(distinct BoardID) as Unique_BoardID_count,
	count(distinct gvkey) as Unique_CIK_count
	from A_4_Set_03;
quit;

proc sort data=A_2_Set_02;
	by gvkey;
quit;

proc sql;
	select
	count(BoardID) as BoardID_count,
	count(gvkey) as GVKEY_count,
	count(distinct BoardID) as Unique_BoardID_count,
	count(distinct gvkey) as Unique_GVKEY_count
	from AB_App_05;
quit;

proc freq data=AB_App_05;
	tables gvkey / noprint out=AB_App_05_dup;
run;
data AB_App_05_dup;
	set AB_App_05_dup;
	where count ne 1;
run;

proc sort data=A_4_Set_03;
	by gvkey;
quit;

proc sort data=Ccm_link_03;
	by gvkey;
quit;


proc sort data=comp.company out=company2;
	by gvkey;
quit;

