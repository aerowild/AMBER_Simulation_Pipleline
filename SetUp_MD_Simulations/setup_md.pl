#!/usr/bin/perl -w
use warnings;
use diagnostics;
unlink 'setup_md.log';
unlink 'setup_error.log';
open (STDOUT,  "| tee -ai setup_md.log");
open (STDERR,  "| tee -ai setup_error.log");
#open(STDERR, '>', 'setup_md_error.log') or die "Can't open log";
#______________________________________________________________________________________________________________
#______________________________________________________________________________________________________________
# DO NOT MODIFY EVEN A CHARACTER HERE IN THIS SCRIPT, ITS NOT INTELLIGENT. 
# DO NOT DISTURB A LINKED DIRECTORY NAMED AS '/setup_MD/raw'. IT CONTAINS THE BASIC FILES REQUIRED TO GENERATE MODIFY FILES

#______________________________________________________________________________________________________________
#______________________________________________________________________________________________________________
system('clear');
print "This script is to set up complete MD simulation using AMBER.\n","Please prepared solvated and neutral topolgy files and keep in provided topology folder named as complexsolv.prmtop and complexsolv.inpcrd\n\n";
#copy temporary dabase of files to current directory and create topology folder
system ("cp -R ~/Shashank_scripts/setupMD_FILES/raw raw");
mkdir 'topology';
system ("cp raw/May_I_Help_You.txt topology/May_I_Help_You.txt");
print "Type yes if topology has been prepared correctly\n else hit enter to exit\n (You can even prepare topology leaving me like this, I can wait...)\n";
print "Wait a minute, I can help you in preparing topologies too if you already have protein without hydrogens in protein-ligand complex and/or mol2 file of ligand\nkeep prepared file in topology folder and we are good to go.\nShall I direct ask my friend to prepare topologies for you?\n";
print "Type yes to prepare or else just hit enter:";
$prepare_topol = <>; chomp $prepare_topol;
if ($prepare_topol eq 'yes' or $prepare_topol eq 'YES')
{
chdir 'topology';
while(1)
{
print "Here we go.............\n";
system('xterm -e generate_topology.pl');
chdir '..';
last;
}
}else {print "No problemo, Do it yourself.\nSuggestion: You may want to use generate_topology.pl command to prepare topology\n";}

#This is a gatekeeper to check that user want to continue or not
system ('clear');
print "Type yes if topology has been prepared correctly\n else hit enter to exit\n (You can even prepare topology leaving me like this, I can wait...)\n";
$confirm = <>;
if ($confirm =~ q/yes/ or $confirm =~ q/YES/)
{
#Main programme goes here

#Create necessary folders first
print "Generating folders\n";
print "minimization folder created \n" if(mkdir 'minimization'); 
print "heating folder created \n" if(mkdir 'heating'); 
print "equilibration folder created \n" if(mkdir 'equilibration'); 
print "productionMD folder created \n" if(mkdir 'productionMD');



while (1)
	{
	#Ask user to input parameters
	system('clear');
	print "ATTENTION USER: I am now gonna ask you few 	basic questions about the MD I should set up. Please provide correct information, I 		will not be responsible for your irresponsible responses.\n 			remember GARBAGE IN >> GARBAGE OUT\n";
	print "Please provide duration of MD in ns:\n";
	$md_duration = <>; chomp $md_duration;

	print "Please provide the time-step for MD (0.0005 (extreamly slow), 0.001 (moderate), 0.002 (fast))\n";
	$md_ts = <>; chomp $md_ts;

	print 'Please provide the range of solute (residue number of protein and ligand) so that those can be constrained in some cases (eg. 1 100)',"\n";
	$md_constrain_range = <>; chomp $md_constrain_range;

	print 'That is all for basic set up. Do you want to explore advanced options like temperature controle, collision frequency, pressure and many more?',"\nType advance to explore advance options OR \nhit enter to continue\n";

	#DEFINE THE ADVANCE OPTIONS
	$explore_advance = <>;  
		if ($explore_advance =~ q/advance/ or $explore_advance =~ q/ADVANCE/) 
		{
		system('clear');
		print "Only few extra options have been implemented...:P\n will do it latter sometimes, modify those manually\n";
		print 'Please provide the number of steps after which frames will be added to the trajectory(eg. 5000, default is 2000)',"\n";
	        $md_frameSave = <>; chomp $md_frameSave;
		}

	#Reviewing the user input
	system('clear');
	print 'Your choices are following:-', "\n";
	print "  \n>Duration of MD (ns): $md_duration  \n>Time-Step (fs): $md_ts  \n>Solute (number of residues): $md_constrain_range\n";
	print "Are these choices correct? (Type no if you want to redefine the parameters, else hit enter to continue)\n";
	$rechoice = <>;
	if ($rechoice =~ q/no/ or $rechoice =~ q/NO/) {print "Ohk, here you go again\n";}else{last;}
	}

####################modify the parameter files######################
#Enter into temporary raw folder
chdir 'raw';

#Modify productionMD.in
#calculate the number of steps required to run given ns MD
$md_steps = ($md_duration * 1000) / $md_ts;
$production_file = 'productionMD.in'; open (READPRODUCTION, "$production_file");
@productionMD = <READPRODUCTION>; $productionMD = "@productionMD"; 
$old_duration = 'nstlim = 15000000'; $new_duration = 'nstlim = '.$md_steps;
$productionMD =~ s/$old_duration/$new_duration/;
$old_ts = 'dt = 0.002'; $new_ts = 'dt = '.$md_ts;
$productionMD =~ s/$old_ts/$new_ts/;
#change the value of frames to save
$old_frameSave = 'ntwx = 2000'; $new_frameSave = 'ntwx = '.$md_frameSave;
$productionMD =~ s/$old_frameSave/$new_frameSave/;

$productionMD =~ s/\n\s/\n/g;
open(WRITEPRODUCTION, ">$production_file");
print WRITEPRODUCTION $productionMD;

#Modifying min1 file
$min1_file = 'min1.in'; open(READMIN1, "$min1_file");
@min1 = <READMIN1>; $min1 = "@min1";
$old_constrain = 'RES 1 301'; $new_constrain = 'RES '.$md_constrain_range;
$min1 =~ s/$old_constrain/$new_constrain/;
$min1 =~ s/\n\s/\n/g;
open(WRITEMIN1, ">$min1_file");
print WRITEMIN1 $min1;


#Modifying heat1 file
$eql_file = 'heat1.in'; open(READMIN1, "$eql_file");
@min1 = <READMIN1>; $min1 = "@min1";
$old_constrain = 'RES 1 301'; $new_constrain = 'RES '.$md_constrain_range;
$min1 =~ s/$old_constrain/$new_constrain/;
$min1 =~ s/\n\s/\n/g;
open(WRITEMIN1, ">$eql_file");
print WRITEMIN1 $min1;

#Modifying heat2 file
$eql_file = 'heat2.in'; open(READMIN1, "$eql_file");
@min1 = <READMIN1>; $min1 = "@min1";
$old_constrain = 'RES 1 301'; $new_constrain = 'RES '.$md_constrain_range;
$min1 =~ s/$old_constrain/$new_constrain/;
$min1 =~ s/\n\s/\n/g;
open(WRITEMIN1, ">$eql_file");
print WRITEMIN1 $min1;

#Modifying heat3 file
$eql_file = 'heat3.in'; open(READMIN1, "$eql_file");
@min1 = <READMIN1>; $min1 = "@min1";
$old_constrain = 'RES 1 301'; $new_constrain = 'RES '.$md_constrain_range;
$min1 =~ s/$old_constrain/$new_constrain/;
$min1 =~ s/\n\s/\n/g;
open(WRITEMIN1, ">$eql_file");
print WRITEMIN1 $min1;

#Modifying heat4 file
$eql_file = 'heat4.in'; open(READMIN1, "$eql_file");
@min1 = <READMIN1>; $min1 = "@min1";
$old_constrain = 'RES 1 301'; $new_constrain = 'RES '.$md_constrain_range;
$min1 =~ s/$old_constrain/$new_constrain/;
$min1 =~ s/\n\s/\n/g;
open(WRITEMIN1, ">$eql_file");
print WRITEMIN1 $min1;

#Modifying heat5 file
$eql_file = 'heat5.in'; open(READMIN1, "$eql_file");
@min1 = <READMIN1>; $min1 = "@min1";
$old_constrain = 'RES 1 301'; $new_constrain = 'RES '.$md_constrain_range;
$min1 =~ s/$old_constrain/$new_constrain/;
$min1 =~ s/\n\s/\n/g;
open(WRITEMIN1, ">$eql_file");
print WRITEMIN1 $min1;

#Modifying heat6 file
$eql_file = 'heat6.in'; open(READMIN1, "$eql_file");
@min1 = <READMIN1>; $min1 = "@min1";
$old_constrain = 'RES 1 301'; $new_constrain = 'RES '.$md_constrain_range;
$min1 =~ s/$old_constrain/$new_constrain/;
$min1 =~ s/\n\s/\n/g;
open(WRITEMIN1, ">$eql_file");
print WRITEMIN1 $min1;

#Modifying eql1 file
$eql_file = 'eql_1.in'; open(READMIN1, "$eql_file");
@min1 = <READMIN1>; $min1 = "@min1";
$old_constrain = 'RES 1 301'; $new_constrain = 'RES '.$md_constrain_range;
$min1 =~ s/$old_constrain/$new_constrain/;
$min1 =~ s/\n\s/\n/g;
open(WRITEMIN1, ">$eql_file");
print WRITEMIN1 $min1;

#Modifying eql2 file
$eql_file = 'eql_2.in'; open(READMIN1, "$eql_file");
@min1 = <READMIN1>; $min1 = "@min1";
$old_constrain = 'RES 1 301'; $new_constrain = 'RES '.$md_constrain_range;
$min1 =~ s/$old_constrain/$new_constrain/;
$min1 =~ s/\n\s/\n/g;
open(WRITEMIN1, ">$eql_file");
print WRITEMIN1 $min1;

#Modifying eql3 file
$eql_file = 'eql_3.in'; open(READMIN1, "$eql_file");
@min1 = <READMIN1>; $min1 = "@min1";
$old_constrain = 'RES 1 301'; $new_constrain = 'RES '.$md_constrain_range;
$min1 =~ s/$old_constrain/$new_constrain/;
$min1 =~ s/\n\s/\n/g;
open(WRITEMIN1, ">$eql_file");
print WRITEMIN1 $min1;


#Modifying runMD.pl file
$i_runMD = 'runMD.pl'; open(READRUNMD, "$i_runMD");
@runMD = <READRUNMD>; $runMD = "@runMD";
$old_constrain = 'ns MD has been finished'; $new_constrain = "$md_duration ns MD has been finished";
$runMD =~ s/$old_constrain/$new_constrain/;
$runMD =~ s/\n\s/\n/g;
open(WRITEMIN1, ">$i_runMD");
print WRITEMIN1 $runMD;

#leaving temporary raw directory
chdir '..';

#Transfer the files to their respected locations
system("cp raw/min1.in minimization/min.in");
system("cp raw/min2.in minimization/min2.in");

system("cp raw/heat1.in heating/heat1.in");
system("cp raw/heat2.in heating/heat2.in");
system("cp raw/heat3.in heating/heat3.in");
system("cp raw/heat4.in heating/heat4.in");
system("cp raw/heat5.in heating/heat5.in");
system("cp raw/heat6.in heating/heat6.in");

system("cp raw/eql_1.in equilibration/eql_1.in");
system("cp raw/eql_2.in equilibration/eql_2.in");
system("cp raw/eql_3.in equilibration/eql_3.in");
system("cp raw/eql_4.in equilibration/eql_4.in");

system("cp raw/productionMD.in productionMD/productionMD.in");

system("cp raw/runMD.pl runMD.pl");
system("rm -R raw");
system('clear');
print 'Whoopee...Your system is ready to run ',$md_duration,'ns MD', "\n", 'Now I am ready to pull the trigger, I mean to run runMD.pl...shall I?'. "\n";
print "Type run to execute runMD.pl, else hit enter if you want to run it manually\n";
$runMD = <>;
if ($runMD =~ q/run/ or $runMD =~ q/RUN/) {system('perl runMD.pl');}else {print "Very well, looks like you plan to revolutionise the MD...Good Luck\n Suggestion: DO NOT RUN ME AGAIN IF EVERYTHING IS READY, I WILL CLEAR THE HISTORY AND START NEW BEGENING. JUST RUN runMD.pl\n";}
}else {print "Please prepare the topology first \n"; system ("rm -R raw");}

