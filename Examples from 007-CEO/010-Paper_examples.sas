proc sql;
    create table A_4_Set_00_x1 as
        select  a.*, b.*
        from A_1_Set_02_00 (where=(not missing(CRSP_Cusip))) a left join dsenames (keep=namedt namedty nameendt ncusip permno) b
        on a.CRSP_Cusip = b.ncusip and ( (b.NAMEDT <= a.TYear <= b.NAMEENDT) or (a.TYEAR = b.namedty) );
quit;

proc sql;
    create table A_4_Set_00_x2 as
        select  a.*, b.*, c.*
        from A_1_Set_02_00 (where=(not missing(CRSP_Cusip))) a left join dsenames (keep=namedt namedty nameendt ncusip permno) b
        on a.CRSP_Cusip = b.ncusip and ( (b.NAMEDT <= a.TYear <= b.NAMEENDT) or (a.TYEAR = b.namedty) )
        left join Ccmxpf_lnkhist c
        on b.permno = c.lpermno &andlt &andld;
quit;

%let keepvars = CompanyID DirectorID DateStartRole DateEndRole;

data B_00 (keep=&keepvars.);
	retain &keepvars.;
	set CEO_21;
	where CompanyID eq 746836;
	years = year(DateEndRole) - year(DateStartRole);
run;

data B_01;
set B_00;
  do i = 0 to intck('year',DatestartRole,DateEndRole);
      TYear=intnx('year',DatestartRole,i,'b');
      output;
      end;
   format TYear year4.;
   drop i;
run;

proc export 
  data=B_01 
  dbms=xlsx 
  outfile="&path.\knight2.xlsx" 
  replace;
run;

data CEO_00_xx; /*(keep=&keepvars.);
	retain &keepvars.;*/
	set ceo.CEOreturns_00;
	where DirectorID eq 1097153;
	drop ClientDirectorID ClientCompanyID COUNT;
run;

proc export 
  data=CEO_00_xx 
  dbms=xlsx 
  outfile="&path.\knight.xlsx" 
  replace;
run;

data B_01;
set B_00;
  do i = 0 to intck('year',DatestartRole,DateEndRole);
      TYear=intnx('year',DatestartRole,i,'b');
      output;
      end;
   format TYear year4.;
   drop i;
run;


/*  Centerpoint Energy Inc matching problem example  */

data X_6271_01;
	set A_4_Set_00__x;
	where CompanyID eq 6271;
run;

data X_6271_02;
	set A_4_Set_00;
	where CompanyID eq 6271;
run;


