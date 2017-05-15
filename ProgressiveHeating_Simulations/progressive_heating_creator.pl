#!/usr/bin/perl
#This script is written to create various windows of input files of different temperature, duration and timesteps simulations. By default, this script will create 10 windows as per follwoing scheme:
#1)	300K -> 320K	timestep:2fs	duration: 400ps
#2)	320K -> 340K	timestep:2fs	duration: 400ps
#3)	340K -> 360K	timestep:2fs	duration: 400ps
#4)	360K -> 380K	timestep:2fs	duration: 400ps
#5)	380K -> 400K	timestep:2fs	duration: 400ps
#6)	400K -> 420K	timestep:1.5fs	duration: 300ps
#7)	420K -> 440K	timestep:1.5fs	duration: 240ps
#8)	440K -> 460K	timestep:1fs	duration: 180ps
#9)	460K -> 480K	timestep:1fs	duration: 1000ps
#10)	480K -> 500K	timestep:1fs	duration: 60ns

$params = 'PROTWIN: Progressive Heating
&cntrl
imin = 0,
irest = 1,
ntx = 5,
ig = -1,
ntc = 2,
ntf = 2,
cut = 10.0,
ntb = 2,
ntp = 1,
pres0 = 1.0,
taup = 2.0,
ntr = 0,
iwrap = 1,
tempi = 300,
temp0 = 320,
ntt = 3,
gamma_ln = 10.0,
nstlim=200000,
dt = 0.002,
ntwe = 2000,
ntpr = 2000,
ntwx = 2000,
ntwr = 10000
/';



$tempi = 300;
$temp0 = 320;

$window = 1;
while($window <= 10)
{
mkdir "Heating_win$window";
chdir "Heating_win$window";

#To write an input file
$write_infile = "Heating_win$window".'.in';
open(WRITEIN, ">:encoding(UTF-8)", "$write_infile");

#Writing .in files
if($window <= 5 )
{
$dt = 0.002;
$nstlim = 200000;
$new_params = $params;
$new_params =~ s/0.002/$dt/; #change time step
$new_params =~ s/300/$tempi/; #change initial temerature
$new_params =~ s/320/$temp0/; #change final temperature
$new_params =~ s/200000/$nstlim/; #change number of steps

print WRITEIN $new_params;
}elsif($window == 6 ){
$dt = 0.0015;
$nstlim = 200000;
$new_params = $params;
$new_params =~ s/0.002/$dt/; #change time step
$new_params =~ s/300/$tempi/; #change initial temerature
$new_params =~ s/320/$temp0/; #change final temperature
$new_params =~ s/200000/$nstlim/; #change number of steps

print WRITEIN $new_params;
}elsif($window == 7 ){
$dt = 0.0015;
$nstlim = 160000;
$new_params = $params;
$new_params =~ s/0.002/$dt/; #change time step
$new_params =~ s/300/$tempi/; #change initial temerature
$new_params =~ s/320/$temp0/; #change final temperature
$new_params =~ s/200000/$nstlim/; #change number of steps

print WRITEIN $new_params;
}elsif($window == 8 ){
$dt = 0.0015;
$nstlim = 120000;
$new_params = $params;
$new_params =~ s/0.002/$dt/; #change time step
$new_params =~ s/300/$tempi/; #change initial temerature
$new_params =~ s/320/$temp0/; #change final temperature
$new_params =~ s/200000/$nstlim/; #change number of steps

print WRITEIN $new_params;
}elsif($window >= 9 ){
$dt = 0.001;
$nstlim = 60000000; #1ns MD at 500K temperature
$new_params = $params;
$new_params =~ s/0.002/$dt/; #change time step
$new_params =~ s/300/$tempi/; #change initial temerature
$new_params =~ s/320/$temp0/; #change final temperature
$new_params =~ s/200000/$nstlim/; #change number of steps

print WRITEIN $new_params;
}else {print "Something extraordinary happened, which we don't want at this moment\n"}

chdir '..';
$window = $window + 1;
$tempi = $tempi + 20;
$temp0 = $temp0 + 20;
}


