/* Developer: Xianglin Wu (xianglin3092@gmail.com) */

PROC import datafile=" `file path` \gdp_data.xlsx"
out=data1  
dbms=xlsx replace;
sheet="sheet1";
getnames=YES;

/*Basic Info*/
PROC MEANS DATA=data1 MAXDEC=4 N MEAN STDDEV MEDIAN MIN MAX;
VAR y x1 x2 x3;

/*Model One*/
PROC SGSCATTER DATA=data1;
MATRIX y x1 x2 x3 ;
PROC REG DATA=data1 CORR;
	MODEL y=x1 x2 x3  /  P CLM SS1 SS2 PCORR2 STB;
	OUTPUT OUT=outdata H=h;
	test1: TEST  x1-x2;
	test2: TEST  x1-x3;
	test3: TEST  x2-x3;
PROC PRINT DATA=outdata;

/*Model Two*/
DATA data2;
set data1;
a=log(y);
b=100*(x1**2);
c=x2;
d=10*x3;
PROC SGSCATTER DATA=data2;
MATRIX a b c d  ;
PROC REG DATA=data2 CORR;
	MODEL a=b c d  /  P R CLM CLI VIF  SS1 SS2 PCORR2 STB 
		INFLUENCE SELECTION=RSQUARE ADJRSQ CP AIC SBC;
	PLOT CP.*NP./ CMALLOWS=blue;
	PLOT STUDENT.*NQQ.;
	PLOT STUDENT.*OBS.;
	OUTPUT OUT=outdata2 STUDENT=istudent H=h;
	test1: TEST b;
	test2: TEST c;
	test3: TEST d;
	test4: TEST b-c;
	test5: TEST b-d;
	test6: TEST c-d;
PROC  PRINT  DATA=outdata2;
PROC RANK NORMAL=BLOM DATA=outdata2 OUT=newdata;
	VAR istudent;
	RANKS nscores;
PROC PLOT DATA=newdata;
	PLOT istudent*nscores='*';
PROC CORR DATA=newdata;
	VAR istudent nscores;
RUN;
