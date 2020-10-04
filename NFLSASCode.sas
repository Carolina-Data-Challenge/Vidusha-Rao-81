libname cdc 'C:\Users\Vidusha\Documents\MSA\CarolinaDataChallenge';

*read in csv files;
proc import datafile="C:\Users\Vidusha\Documents\MSA\CarolinaDataChallenge\OffensiveStats.csv"
			dbms=csv
			out = cdc.Offense
			replace;
			guessingrows = 2000;
			getnames=yes;
run;

proc import datafile="C:\Users\Vidusha\Documents\MSA\CarolinaDataChallenge\DefensiveStats.csv"
			dbms=csv
			out = cdc.Defense
			replace;
			getnames=yes;
	guessingrows = 2000;
run;

*explore datasets;
proc contents data=cdc.offense order=varnum;
run;
proc contents data=cdc.defense order=varnum;
run;

*Convert values to numeric for off and def;
data cdc.offensev2;
	set cdc.offense;
		so = input(scoreoff, best12.);
		fdo = input(firstdownoff, best12.);
		tdpo = input(thirddownpctoff, best12.);
		ryo = input(rushydsoff, best12.);
		ypro = input(ydsperrushoff, best12.);
		pyo = input(passydsoff, best12.);
		cpo = input(comppctoff, best12.);
		yppo = input(ydsperpassoff, best12.);
		pio = input(passintoff, best12.);
		fo = input(fumblesoff, best12.);
		if win = 'TRUE' then windicator = 1;
		if win = 'FALSE' then windicator = 0;
	keep season teamname so fdo tdpo ryo ypro pyo cpo yppo pio fo windicator;
run;
proc contents data=cdc.offensev2 order=varnum;
run;

data cdc.defensev2;
	set cdc.defense;
		sd = input(scoredef, best12.);
		fdd = input(firstdowndef, best12.);
		tdpd = input(thirddownpctdef, best12.);
		ryd = input(rushydsdef, best12.);
		yprd = input(ydsperrushdef, best12.);
		pyd = input(passydsdef, best12.);
		yppd = input(ydsperpassdef, best12.);
		pid = input(passintdef, best12.);
		fd = input(fumblesdef, best12.);
		if win = 'TRUE' then windicator = 1;
		if win = 'FALSE' then windicator = 0;
	keep season teamname sd fdd tdpd ryd yprd pyd yppd pid fd windicator;
run;
proc contents data=cdc.defensev2 order=varnum;
run;

*Calculate Summary Statistics per team;
proc means data=cdc.offensev2 mean std min max;
	class teamname;
	var _numeric_;
	output out=cdc.DescStatsNFL;
run;


*export to xl;
proc export data=cdc.descstatsnfl
			outfile='C:\Users\Vidusha\Documents\MSA\CarolinaDataChallenge\ByTeamDS.xlsx'
			dbms=xlsx
			replace;
run;

*by season stats;
proc means data=cdc.offensev2 mean;
	class season;
	var _numeric_;
	output out=cdc.seasonds;
run;

*export to xl;
proc export data=cdc.seasonds
			outfile='C:\Users\Vidusha\Documents\MSA\CarolinaDataChallenge\BySeasonDS.xlsx'
			dbms=xlsx
			replace;
run;

*see which variable is the best predictor for winning the game;
*use concordance;

/* START OFFENSE ANALYSIS */


*off score;
proc logistic data=cdc.offensev2 plots(only)=(effect);
	model windicator(event='1') = so / clodds=pl;
	label windicator = 'Win or Loss'
		so = 'Game Score';
	units so = 5;
run;
quit;
*80.8, 0.823;

*off fdo;
proc logistic data=cdc.offensev2 plots(only)=(effect);
	model windicator(event='1') = fdo / clodds=pl;
	*units so = 10;
run;
quit;
*63.2, 0.659;

*off 3rd down percentage;
proc logistic data=cdc.offensev2 plots(only)=(effect);
	model windicator(event='1') = tdpo / clodds=pl;
run;
quit;

*off rush yards;
proc logistic data=cdc.offensev2 plots(only)=(effect);
	model windicator(event='1') = ryo / clodds=pl;
	units ryo = 10;
run;
quit;

*yards per rush;
proc logistic data=cdc.offensev2 plots(only)=(effect);
	model windicator(event='1') = ypro / clodds=pl;
run;
quit;

*pyo;
proc logistic data=cdc.offensev2 plots(only)=(effect);
	model windicator(event='1') = pyo / clodds=pl;
	units pyo = 10;
run;
quit;

*cpo;
proc logistic data=cdc.offensev2 plots(only)=(effect);
	model windicator(event='1') = cpo / clodds=pl;
	units cpo = 5;
run;
quit;

*yppo;
proc logistic data=cdc.offensev2 plots(only)=(effect);
	model windicator(event='1') = yppo / clodds=pl;
run;
quit;

*pio;
proc logistic data=cdc.offensev2 plots(only)=(effect);
	*class pio(param=ref ref='0');
	model windicator(event='1') = pio / clodds=pl;
run;
quit;

*fo;
proc logistic data=cdc.offensev2 plots(only)=(effect);
	model windicator(event='1') = fo / clodds=pl;
	label fo = 'Fumbles';
run;
quit;

