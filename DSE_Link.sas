/*  -------------------------------------------------------------------------  */
/*  It is important to order this dataset by NCUSIP and not PERMNO in order    */
/*  to ensure that PERMNOs will multiple CUSIPs over time are retained         */

%let var1 = cusip;
%let var2 = ncusip;

%macro dse();
		%do i=1 %to 2 %by 1;

proc sql;
	create table DSE_Link_01_&i. as select *
		from crsp.dsenames_&dataver.
		order by &&var&i., namedt, nameendt, ticker, permno
		;
quit;

/*  -------------------------------------------------------------------------  */
/*  Collapse link table                                                        */

data DSE_Link_02_&i.;
	retain &&var&i. namedt nameendt prev_ldt prev_ledt;
    set DSE_Link_01_&i.;
    by &&var&i. namedt nameendt;
    format prev_ldt prev_ledt yymmddn8.;
/*    retain prev_ldt prev_ledt;*/
    if first.&&var&i. then do;
        if last.&&var&i. then do;
/*  Keep this obs if it's the first and last matching &&var&i. pair              */
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
/*  If the date range follows the previous one, assign the previous linkdt     */
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
    drop prev_ldt prev_ledt;
run;

data DSE_Link_03_&i. (keep=DSE_CUSIP permno namedt nameendt);
  set DSE_Link_02_&i.;
  by &&var&i. namedt;
  if last.namedt;
  /* remove redundant observations with identical LINKDT (result of the previous data step), so that
     each consecutive pair of observations will have either different &&var&i.-IID-PERMNO match, or
     non-consecutive link date range
   */
  rename &&var&i. = DSE_CUSIP;
  label DSE_CUSIP = "";
run;

		%end;
%mend;%dse;


data Dse_link_04;
	set Dse_link_03_1 Dse_link_03_2;
	where not missing(DSE_CUSIP);
	label DSE_CUSIP = ;
run;
proc sort data=Dse_link_04 nodupkey ;
	by DSE_CUSIP permno;
run;

