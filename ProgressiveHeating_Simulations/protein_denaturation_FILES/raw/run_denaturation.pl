#!/usr/bin/perl -w
#This script is written to set_up and run Simulation for protein denauration (by progressive heating). This script utilizes another perl script, which creates windows and input files for progressive heating simulations.
#Once windows are created from the other script, this script will use output coordinate of previous "equilibration" step and will run simulation.

print "This is an automated script to run protein denaturation (by progressive heating) using AMBER12. It will take prepared topology and parameter files as input and try to successfully run Minimization, Heating, Equilibration and Multi-step heating MDs. It is highly reccomonded to check all input files (*.in )before using this script.\n Successfull completion of this script does not guarantee the successfull completion of MD, so better you check the data before blaming me\n";

#########################MINIMIZATION STARTS#############################################################
print "Coordiante files for minimization are being transferred...\n" if(system ("cp topology/complexsolv.prmtop minimization/complexsolv.prmtop"));
print "Topology files are being transferred for Minimization...\n" if(system ("cp topology/complexsolv.inpcrd minimization/complexsolv.inpcrd"));

chdir "minimization";

while(1)
{
print "Now running restrained Minimization (min1)\n";
system ("mpiexec -n 12 sander.MPI -O -i min.in -o min.out -p complexsolv.prmtop -c complexsolv.inpcrd -r min.rst -x min_out.mdcrd -ref complexsolv.inpcrd");
#system('clear');
#print "Now tracking the progress of min1 in new window:\n";
#system('xterm -e tail -f min.out');
sleep (10);
last;
}

while(1)
{
print "Now running full Minimization (min2)\n";
system ("mpiexec -n 12 sander.MPI -O -i min2.in -o min2.out -p complexsolv.prmtop -c min.rst -r heat0.rst -x min2_out.mdcrd");
#system('clear');
#print "Now tracking the progress of min2 in new window:\n";
#system('xterm -e tail -f min2.out');
sleep (10);
last;
}

chdir "..";
#########################MINIMIZATION ENDS###############################################################

print "Minimization COMPLETED!\nNow Preparing for Heating\n";
print "Simulation topology files are being transferred from Minimization to heating...\n" if(system ("cp topology/complexsolv.prmtop heating/complexsolv.prmtop"));
print "Minimized systems are being transferred for heating...\n" if(system ("cp minimization/heat0.rst heating/heat0.rst"));

#########################HEATING#############################################################
print "Heating system...This might consume some time...:P\n";

chdir "heating";
@mdinfile = <*.in>;
print @mdinfile;

$n=1;
foreach (@mdinfile)
{
$get_heatstep = substr($_,0,-3);
print "Running $get_heatstep\n";
$c_file="heat".$n;

$m=$n-1;
$rstin ="heat".$m; 
print "Running MD for $c_file file \n";

while(1)
{
$m=$n-1;
$rstin ="heat".$m; 
system ("pmemd.cuda -O -i $_ -o $c_file.out -p complexsolv.prmtop -c $rstin.rst -r $c_file.rst -x $c_file.mdcrd -ref $rstin.rst");
system ("ambpdb -p complexsolv.prmtop <$c_file.rst> $c_file.pdb");

last;
}
$n= $n+1;
}
print "System has been heated 0-300 K.\n";
chdir "..";
#########################HEATING ENDS#############################################################

#########################Preparion Start#############################################################
print "Heating COMPLETED!\nNow Preparing for equilibration\n";
print "Simulation topology files are being transferred fro equlibration...\n" if(system("cp topology/complexsolv.prmtop equilibration/complexsolv.prmtop"));
print "Heated system is being transferred for equilibration...\n" if(system ("cp heating/heat6.rst equilibration/eql0.rst"));
#########################Preparation Ends#############################################################

#########################Equilibration#############################################################
chdir "equilibration";

@eqlinfile = <eql_*.in>;
print @eqlinfile;

$x=1;
foreach (@eqlinfile)
{

print "Running Equillibration stage:",$x," using file",$_,"\n";

$c_file="eql".$x;

$y=$x-1;
$rstin ="eql".$y; 
print "Running MD for $c_file file \n";

while(1)
{
$y=$x-1;
$rstin ="eql".$y; 
system ("pmemd.cuda -O -i $_ -o $c_file.out -p complexsolv.prmtop -c $rstin.rst -r $c_file.rst -x $c_file.mdcrd -ref $rstin.rst");
system ("ambpdb -p complexsolv.prmtop <$c_file.rst> $c_file.pdb");

last;
}
$x= $x+1;
}

print "An output pdb has been saved for your reference. It is highly reccomonded to check the structure before proceeding further\n" if(system ("ambpdb -p complexsolv.prmtop <eql4.rst> eql_md_out.pdb"));


chdir "..";

#########################Preparion Start#############################################################
print "Equilibration COMPLETED!\nNow Preparing for Progressive heating (**ns Default)\n";
print "\n" if(system ("cp topology/complexsolv.prmtop productionMD/complexsolv.prmtop"));
print "Equillibrated system is being transferred for productionMD...\n" if(system ("cp equilibration/eql4.rst productionMD/laststep_coordinates_heat0.rst"));
#sleep(2);
#########################Preparion Ends#############################################################


#########################Production MD Starts#############################################################
chdir "productionMD";
#print "Generating windows and necessary input files to heat system progressively\n";
#system('progressive_heating_creator.pl');
#print "Done\n";
print "Necessary input files generated, going hot now\n";

$count = 0;
$window_number = 1;
@get_windows = <Heating_win*>;
foreach(@get_windows)
{
$window_num = 'Heating_win'.$window_number;
$last_coord = 'laststep_coordinates_heat'.$count.'.rst';
chomp $window_num;
system ("cp complexsolv.prmtop $window_num/complexsolv.prmtop");
system ("cp $last_coord $window_num/laststep_coordinates.rst");
chdir "$window_num";
$in_file=$window_num.'.in';

#Note: The line below is a special code which will open already generated file (from perl) in VI editor and will 'save and exit'. That's it? You might be wondering why would someone do that? Well, because sicnce last night, I stuck on a strange bug. The bug was that I could generate an input file for AMBER using perl, but until I open generated file in text editor (like gedit or VI) and save it again, AMBER will not accept it (Damn it!). I tried to rewrite the whole scipt with complete new approach but none worked. At last, this simple line (searching this line was even more difficult task) saved my life from frustation.
system("vi $in_file -c wq");
$out_file=$window_num.'.out';
$rst = $window_num.'_out.rst';
$mdcrd = $window_num.'_out.mdcrd';
system ("pmemd.cuda -O -i $in_file -o $out_file -p complexsolv.prmtop -c laststep_coordinates.rst -r $rst -x $mdcrd");
$count = $count+1;
$current_coord = 'laststep_coordinates_heat'.$count.'.rst';
system("cp $rst ../$current_coord");
chdir '..';
$window_number = $window_number + 1;
}
print "Protein denaturaion MD has been finished, do not be lazy to review the output files to check everything has been run correctly...:P\n";
chdir "..";

#########################Production MD Ends#############################################################
system('clear');
print "Please wait for a while, I am generating single trajectory for analysis of this simulation\n";
system('ptraj complexsolv.prmtop < ptraj.in');
print "\nI GUESS MY JOB IS DONE HERE\n";
