/*  -------------------------------------------------------------------------  */
/*                                                                             */
/*               Data matching for corporate governance research               */
/*                                                                             */
/*  Program      : BCM_Link.sas                                                */
/*  Author       : Attila Balogh, School of Banking and Finance                */
/*                 UNSW Business School, UNSW Sydney                           */
/*  Date Created : 15 Oct 2017                                                 */
/*  Last Modified: 31 Oct 2017                                                 */
/*                                                                             */
/*  Description  : CRSP Compustat Matching link                                */
/*                                                                             */
/*  Notes        : Please reference the following paper when using this code   */
/*                 Balogh, A 2017                                              */
/*                 Data matching for corporate governance research             */
/*                 Available at SSRN: https://ssrn.com/abstract=3053405        */
/*                                                                             */
/*  _________________________________________________________________________  */

/**********************************************************************************
* Program         :   ccm_lnktable.sas                                            *
* Author          :   WRDS/M. Duan                                                *
* Date Created    :   April 2009                                                  *
* Last Modified   :   January 2014                                                *
*                                                                                 *
* Usage           :                                                               *
*   This program shows the main processing part of the CCM web queries.           *
* XpressFeed version CCM product provides more detailed information on linking    *
* history, in the meanwhile it also populates much more observations than the old *
* version, among which there are some consecutive records (consecutive linking    *
* date range). This program will collapse such consecutive rows and combine them  *
* into one.                                                                       *
* An example might be helpful:                                                    *
* Two records can be found in the link table (ccmxpf_lnkhist):                    *
* GVKEY   LINKPRIM  LIID  LINKTYPE    LPERMNO    LPERMCO   LINKDT      LINKENDDT  *
* 001043    C        00X    LC        18980      20009     19501230    19620130   *
* 001043    C        01     LC        18980      20009     19620131    19820427   *
* After this program, there is only one line left:                                *
* 001043    C        01     LC        18980      20009     19501230    19820427   *
*                                                                                 *
* Notes:                                                                          *
*   Include LIID in all the BY statements ONLY IF the LNK table is to be used     *
* to merge with Security Monthly table. Otherwise, LIID should be removed from    *
* the BY statements.                                                              *
***********************************************************************************/

 
/* ---------------------------------------------------------------- */
/* create the "andlu" macro variable that indicates if the linktype */
/* in ("LC", "LS", "LU")links will be used exclusively or not.      */
/* ---------------------------------------------------------------- */
 
%let andlu = %str(linktype in ("LC", "LS", "LU"));
 
/* ---------------------------------------------------------------- */
/* create the "andlt" macro variable that will keep only the        */
/*  desired linktypes.                                              */
/* ---------------------------------------------------------------- */
 
%let andlt = %str(linktype in ("LC" "LN" "LU" "LX" "LD" "LS"));
 
/* ---------------------------------------------------------------- */
/* List of GVKEYs                                                   */
/* ---------------------------------------------------------------- */
 %let glist = '001043' '006066' '012141'  '014489';               
 
/* ---------------------------------------------------------------- */
/* Create LNK table by selecting rows with desired GVKEYs and date  */
/* range.                                                           */
/* ---------------------------------------------------------------- */

/*  Original code */
proc sql;
	create table lnk1 as select *
		from crsp.ccmxpf_lnkhist_&dataver.
		where &andlt        
		order by gvkey, lpermno, lpermco, linkdt, linkenddt
		;
quit;


/* ---------------------------------------------------------------- */
/* Processing LNK table to collapse                                 */
/* ---------------------------------------------------------------- */
 
data lnk2;
    set lnk1;
    by gvkey lpermno lpermco linkdt linkenddt;
    format prev_ldt prev_ledt yymmddn8.;
    retain prev_ldt prev_ledt;
    if first.lpermno then do;
        if last.lpermno then do;
            /* Keep this obs if it's the first and last matching permno pair */
            output;           
        end;
        else do;
            /* If it's the first but not the last pair, retain the dates for future use */
            prev_ldt = linkdt;
            prev_ledt = linkenddt;
            output;
            end;
        end;   
    else do;
        if linkdt=prev_ledt+1 or linkdt=prev_ledt then do;
            /* If the date range follows the previous one, assign the previous linkdt value
                       to the current - will remove the redundant in later steps. Also retain the
                       link end date value */
            linkdt = prev_ldt;
            prev_ledt = linkenddt;
            output;
            end;
        else do;
            /* If it doesn't fall into any of the above conditions, just keep it and retain the
                       link date range for future use*/
            output;
            prev_ldt = linkdt;
            prev_ledt = linkenddt;
            end;
        end;
    drop prev_ldt prev_ledt;
run;
 
data lnk3;
  set lnk2;
  by gvkey lpermno linkdt;
  if last.linkdt;
  /* remove redundant observations with identical LINKDT (result of the previous data step), so that
     each consecutive pair of observations will have either different GVKEY-IID-PERMNO match, or
     non-consecutive link date range
   */
run;


/* *************************************************************************** */
/* *************************  Attila Balogh, 2017  *************************** */
/* *************************************************************************** */
