
/* Same as above, but only prints out tables (no titles, notes, etc.) */
/* Also, prints each table to a separate file */
ods tagsets.tablesonlylatex file="C:\Users\Attila Balogh\Dropbox\Research\B2017b\tablesonly.tex" (notop nobot) newfile=table;

proc print data=A_4_set_00;
	where BoardID eq 14722;
	var BoardID BoardName permno namedt nameendt;
   title 'Monthly Price Per Unit and Sale Type for Each Country';
run;
quit;

ods tagsets.tablesonlylatex close;
