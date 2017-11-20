/* Reverse from CRSP to GVKEY */

proc sql;
	create table Rev_01 as
 		select	a.*, b.*
		from A_4_set_05 a left join crsp.Ccmxpf_lnkhist b
		on a.permno = b.lpermno
		order by BoardID, permno, gvkey, linkprim, liid, linkdt
	;
quit;

/*  Because out goal is to find a GVKEY match to a BoardID, we can remove */
/*  BoardID - GVKEY duplicates. It may leave us with observations BoardID-PERMNO */
/*  duplicates - they will need to be checed when merging Compustat financial data */

proc sort data=Rev_01 out=Rev_02 nodupkey ;
	by BoardID gvkey;
run;

/*  Lets check if that's the case! */

proc sort data=Rev_02 out=Rev_02_2 nodupkey ;
	by BoardID permno;
run;



/*Find duplicates*/

proc freq data=Rev_01;
	tables BoardID*permno*gvkey / noprint out=Rev_01_dupe;
run;

data Rev_01_dupe;
	set Rev_01_dupe;
	if count < 2 then delete;
run;

proc sql;
create table Rev_03 as
 		select a.*, b.count, c.*
		from Rev_01 (rename=BoardID=BoardID0) a left join Rev_01_dupe (where=(COUNT ne .)) b
		on a.BoardID0 = b.BoardID
		left join comp.names c
		on a.gvkey = c.gvkey
		order by count descending, BoardID, LINKDT;
quit;

data Rev_04;
	set Rev_03;
	if LINKENDDT = .E then LINKENDDT = today();
	if namedt > LINKDT then LINKDT = namedt;
	if namedt > LINKENDDT then delete;
	if LINKDT > LINKENDDT then delete;
run;

proc sort data=Rev_04;
	by BoardID0 ;
run;

proc sort data=Rev_04 nodupkey;
	by BoardID0 permno gvkey namedt;
run;

data names_02_11;
	set comp.names;
	where gvkey in('116004');
run;

data names_02_2;
	set comp.names;
	where gvkey in('001045');
run;


data dsenames_01;
	set crsp.dsenames;
	where permno = 87054;
run;


data funda_02;
	set comp.Funda_20171030;
	where gvkey in('121934');
run;
