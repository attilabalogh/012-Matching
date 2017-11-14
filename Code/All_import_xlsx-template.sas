%let subdir=C:\Tmp_Dataset\lkj\;
filename dir pipe "dir &subdir.*.xlsx /B";
data new;
infile dir truncover end=last;
input filename $100.;
filename=cats("&subdir",filename);
call symputx(cats('path',_n_),filename);
call symputx(cats('dsn',_n_),scan(scan(filename,6,'\'),1,'.'));
if last then call symputx('nobs',_n_);
run;
%put _user_;
%macro import;
%do i=1 %to &nobs;

proc import out = &&dsn&i datafile="&&path&i" dbms=xlsx replace; run;

%end;
%mend import;

%import



data delete;
set sashelp.vmacro;
where scope eq: 'G' and name ne: 'SYS';
run;
data _null_;
set delete;
call symdel(name);
run;
