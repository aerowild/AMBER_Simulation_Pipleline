#!/usr/bin/perl -w
use warnings;
use diagnostics;
if (-f 'generate_topology.log'){unlink 'generate_topology.log';}
if (-f 'generate_topology_error.log'){unlink 'generate_topology_error.log';}
open(STDOUT, "| tee -ai generate_topology.log");
open(STDERR, "| tee -ai generate_topology_error.log");

system('clear');
print '-------------------------------READ ME FIRST-------------------------------',"\nThis script is to generate the topology by tleap of AMBER suite, given correct input files (prepared protein, ligand and/or complex).\n >Prepared means protein without hydrogens and ligand with correct connect record and hydrogens added\n >Protein must be a PDB file and ligand a mol2 file\n >mol2 file of ligand must have atom type section defined (antechamber generates correct mol2 file, but frequently mess up with connect records)\n >It is advised to prepared mol2 file using antechamber and then connect record must be correcred using maestro interface\n >To generate the topology of protein-ligand complex, complex file should be in PDB format contaning protein without hydrogen and ligand with correct connect records.\n >mol2 file of ligand must be provided seperatly, generated from the ligand present in protein-ligand complex file\n",'------------------------------***Thank you***------------------------------',"\n\n";
#________________________________________________________________________________________________________________________
#__________________________________________________DEFINING FUNCTIONS____________________________________________________
#defining the function for protein topology generation
sub proteintopol
{
while(1)
{
$i_pdb = $_[0];
chomp $i_pdb;
if (-f $i_pdb)
{
print "Protein file identified\n";
print "Removing hydrogens from protein\n";

#creating pymol script 
open(WRITEPYMOL, '> pymol_protein.pml'); 
print WRITEPYMOL "load $i_pdb","\n",'remove waters',"\n",'remove hydrogens',"\n",'save protein_woh.pdb',"\n",'quit';
system('pymol -c pymol_protein.pml');
system ('clear');
print "Waters and Hydrogens have been removed from $i_pdb and new file name is protein_woh.pdb\n";
last;
}else
{print "No such PDB file exists, Please provide the correct filename\n"; $i_pdb = <>;}
}

#Generating topoly
while(1)
{
system('clear');
print "Now generating the topology for protein, please chhose the force field\n";
print "Choose the force field by typing their respective alphabate (A, B , C...)";
print "\n",'A: leaprc.amoeba	B: leaprc.constph
C: leaprc.ff02pol.r1	D: leaprc.ff02polEP.r1
E: leaprc.ff03.r1	F: leaprc.ff03ua
G: leaprc.ff10		H: leaprc.ff12SB
I: leaprc.ff13		J: leaprc.ff99bsc0
K: leaprc.ff99SB	L: leaprc.ff99SBildn
M: leaprc.ff99SBnmr	N: leaprc.ffAM1
O: leaprc.ffPM3		P: leaprc.gaff
Q: leaprc.GLYCAM_06EPb	R: leaprc.GLYCAM_06h
S: leaprc.GLYCAM_06h-1	T: leaprc.GLYCAM_06h-12SB
U: leaprc.lipid11	V: leaprc.parmCHI_YIL.bsc',"\nSelect the Force Field:";
$selct_ff = <>; chomp $selct_ff;
if($selct_ff eq 'A' or $selct_ff eq 'a'){$force_field = 'leaprc.amoeba';last;}
elsif($selct_ff eq 'B' or $selct_ff eq 'b'){$force_field = 'leaprc.constph';last;}
elsif($selct_ff eq 'C' or $selct_ff eq 'c'){$force_field = 'leaprc.ff02pol.r1';last;}
elsif($selct_ff eq 'D' or $selct_ff eq 'd'){$force_field = 'leaprc.ff02polEP.r1';last;}
elsif($selct_ff eq 'E' or $selct_ff eq 'e'){$force_field = 'leaprc.ff03.r1';last;}
elsif($selct_ff eq 'F' or $selct_ff eq 'f'){$force_field = 'leaprc.ff03ua';last;}
elsif($selct_ff eq 'G' or $selct_ff eq 'g'){$force_field = 'leaprc.ff10';last;}
elsif($selct_ff eq 'H' or $selct_ff eq 'h'){$force_field = 'leaprc.ff12SB';last;}
elsif($selct_ff eq 'I' or $selct_ff eq 'i'){$force_field = 'leaprc.ff13';last;}
elsif($selct_ff eq 'J' or $selct_ff eq 'j'){$force_field = 'leaprc.ff99bsc0';last;}
elsif($selct_ff eq 'K' or $selct_ff eq 'k'){$force_field = 'leaprc.ff99SB';last;}
elsif($selct_ff eq 'L' or $selct_ff eq 'l'){$force_field = 'leaprc.ff99SBildn';last;}
elsif($selct_ff eq 'M' or $selct_ff eq 'm'){$force_field = 'leaprc.ff99SBnmr';last;}
elsif($selct_ff eq 'N' or $selct_ff eq 'n'){$force_field = 'leaprc.ffAM1';last;}
elsif($selct_ff eq 'O' or $selct_ff eq 'o'){$force_field = 'leaprc.ffPM3';last;}
elsif($selct_ff eq 'P' or $selct_ff eq 'p'){$force_field = 'leaprc.gaff';last;}
elsif($selct_ff eq 'Q' or $selct_ff eq 'q'){$force_field = 'leaprc.GLYCAM_06EPb';last;}
elsif($selct_ff eq 'R' or $selct_ff eq 'r'){$force_field = 'leaprc.GLYCAM_06h';last;}
elsif($selct_ff eq 'S' or $selct_ff eq 's'){$force_field = 'leaprc.GLYCAM_06h-1';last;}
elsif($selct_ff eq 'T' or $selct_ff eq 't'){$force_field = 'leaprc.GLYCAM_06h-12SB';last;}
elsif($selct_ff eq 'U' or $selct_ff eq 'u'){$force_field = 'leaprc.lipid11';last;}
elsif($selct_ff eq 'V' or $selct_ff eq 'v'){$force_field = 'leaprc.parmCHI_YIL.bsc';last;}else{print "Wrong choice, try again \n";}
}
system('clear');
print "You have selected $force_field force field\n";
print "Do you want to select second force field to be used during topology generation?\ntype YES or else hit the enter to continue:";
$sencond_ff = <>; chomp $sencond_ff;

if($sencond_ff =~ /yes/i)
{

while(1)
{
system('clear');
print "Please chhose the second force field\n";
print "Choose the force field by typing their respective alphabate (A, B , C...)";
print "\n",'A: leaprc.amoeba	B: leaprc.constph
C: leaprc.ff02pol.r1	D: leaprc.ff02polEP.r1
E: leaprc.ff03.r1	F: leaprc.ff03ua
G: leaprc.ff10		H: leaprc.ff12SB
I: leaprc.ff13		J: leaprc.ff99bsc0
K: leaprc.ff99SB	L: leaprc.ff99SBildn
M: leaprc.ff99SBnmr	N: leaprc.ffAM1
O: leaprc.ffPM3		P: leaprc.gaff
Q: leaprc.GLYCAM_06EPb	R: leaprc.GLYCAM_06h
S: leaprc.GLYCAM_06h-1	T: leaprc.GLYCAM_06h-12SB
U: leaprc.lipid11	V: leaprc.parmCHI_YIL.bsc',"\nSelect the Force Field:";
$selct_ff = <>; chomp $selct_ff;
if($selct_ff eq 'A' or $selct_ff eq 'a'){$force_field2 = 'leaprc.amoeba';last;}
elsif($selct_ff eq 'B' or $selct_ff eq 'b'){$force_field2 = 'leaprc.constph';last;}
elsif($selct_ff eq 'C' or $selct_ff eq 'c'){$force_field2 = 'leaprc.ff02pol.r1';last;}
elsif($selct_ff eq 'D' or $selct_ff eq 'd'){$force_field2 = 'leaprc.ff02polEP.r1';last;}
elsif($selct_ff eq 'E' or $selct_ff eq 'e'){$force_field2 = 'leaprc.ff03.r1';last;}
elsif($selct_ff eq 'F' or $selct_ff eq 'f'){$force_field2 = 'leaprc.ff03ua';last;}
elsif($selct_ff eq 'G' or $selct_ff eq 'g'){$force_field2 = 'leaprc.ff10';last;}
elsif($selct_ff eq 'H' or $selct_ff eq 'h'){$force_field2 = 'leaprc.ff12SB';last;}
elsif($selct_ff eq 'I' or $selct_ff eq 'i'){$force_field2 = 'leaprc.ff13';last;}
elsif($selct_ff eq 'J' or $selct_ff eq 'j'){$force_field2 = 'leaprc.ff99bsc0';last;}
elsif($selct_ff eq 'K' or $selct_ff eq 'k'){$force_field2 = 'leaprc.ff99SB';last;}
elsif($selct_ff eq 'L' or $selct_ff eq 'l'){$force_field2 = 'leaprc.ff99SBildn';last;}
elsif($selct_ff eq 'M' or $selct_ff eq 'm'){$force_field2 = 'leaprc.ff99SBnmr';last;}
elsif($selct_ff eq 'N' or $selct_ff eq 'n'){$force_field2 = 'leaprc.ffAM1';last;}
elsif($selct_ff eq 'O' or $selct_ff eq 'o'){$force_field2 = 'leaprc.ffPM3';last;}
elsif($selct_ff eq 'P' or $selct_ff eq 'p'){$force_field2 = 'leaprc.gaff';last;}
elsif($selct_ff eq 'Q' or $selct_ff eq 'q'){$force_field2 = 'leaprc.GLYCAM_06EPb';last;}
elsif($selct_ff eq 'R' or $selct_ff eq 'r'){$force_field2 = 'leaprc.GLYCAM_06h';last;}
elsif($selct_ff eq 'S' or $selct_ff eq 's'){$force_field2 = 'leaprc.GLYCAM_06h-1';last;}
elsif($selct_ff eq 'T' or $selct_ff eq 't'){$force_field2 = 'leaprc.GLYCAM_06h-12SB';last;}
elsif($selct_ff eq 'U' or $selct_ff eq 'u'){$force_field2 = 'leaprc.lipid11';last;}
elsif($selct_ff eq 'V' or $selct_ff eq 'v'){$force_field2 = 'leaprc.parmCHI_YIL.bsc';last;}else{print "Wrong choice, try again \n";}
}
print "Generating topology with following two force fields:\n$force_field and $force_field2 \n";
}else{print "Generating topology with single force field\n";}

#Generate tleap file
open(WRITETLEAP,'>protein.tleap');
print WRITETLEAP "source $force_field\n","source $force_field2\n",'protein=loadpdb protein_woh.pdb',"\n",'solvateoct protein TIP3PBOX 10.0',"\n",'addions protein Na+ 0',"\n",'addions protein Cl- 0',"\n",'saveamberparm protein complexsolv.prmtop complexsolv.inpcrd',"\n",'savepdb protein complexsolv.pdb',"\n",'quit';
print "tleap input file created \n";
system('clear');
system('tleap -f protein.tleap');

print "*********CONGRATULATIONS! PROTEIN TOPOLOGY HAS BEEN PREPARED*************\n";
}

#defining the function for ligand topology generation
sub ligandtopol
{
	while(1)
	{
	$i_ligand = $_[0];
	chomp $i_ligand;
	#defining file names
	$ligname = substr($i_ligand,0,-5); $ligfrc = $ligname.'.frcmod'; $liglib = $ligname.'.lib'; $ligparam = $ligname.'.prmtop'; $ligcrd = $ligname.'.inpcrd';
	$check_mol2 = substr($i_ligand,-4);
	if($check_mol2 eq 'mol2'){print "Reading ligand $i_ligand\nLooks like a mol2 file\n";last;}
	else
	{
	system('clear');
	print "Not even extenstion of this file is mol2. Please provide ligand in mol2 file, or else I can not help\n";
	print "Generating ligand topology\nPlease provide ligand in mol2 formot\n";
	$i_ligand = <>;
	}
	}
#generate topology for ligand
system("parmchk -i $i_ligand -f mol2 -o $ligfrc");
open(WRITETOPOL, ">ligand.tleap");
print WRITETOPOL 'source leaprc.gaff',"\n","loadamberparams $ligfrc\nUNK=loadmol2 $i_ligand\nsaveoff UNK $liglib\nsaveamberparm UNK $ligparam $ligcrd\nquit";
system('tleap -f ligand.tleap');
system('clear');
print "***************************CONGRATULATIONS! LIGAND TOPOLOGY HAS BEEN PREPARED***************************\n";
}

#___________________________________________ALL FUNCTIONS DEFINED______________________________________________________
#______________________________________________________________________________________________________________________

print 'Prepare topology for A)protein, B)ligand, C) Protein-ligand complex ???',"\n",'Please type-',"\n",'	A for protein',"\n",'	B for ligand',"\n",'	C for protein-ligand complex',"\n";
$selection = <>; $selection = "$selection";chomp $selection;
if($selection eq 'A' or $selection eq 'a')
{
####################################TOPOLOGY OF PROTEIN#################################
#Input PDB and use function proteintopol
system ('clear');
print 'Please provide the protein PDB file (either keep PDB file in current directory or give complete path of PDB)',"\n";
$i_pdb = <>; 
&proteintopol($i_pdb);
}elsif($selection eq 'B' or $selection eq 'b')
{
####################################TOPOLOGY OF LIGAND#################################
system('clear');
print "Generating ligand topology\nPlease provide ligand in mol2 formot\n";
#Import mol2 and verify mol2 extension
$i_ligand = <>;
&ligandtopol($i_ligand);
}elsif($selection eq 'C' or $selection eq 'c')
{
####################################TOPOLOGY OF PROTEIN-LIGAND COMPLEX#################################
system('clear');
print "ATTENTION: Protein in this protein-ligand complex must not have hydrogens added otherwise you may encounter errors\nKeeping this simple idea in mind, now give me protein-ligand complex.\nHURRY! HURRY!...just kidding, No Hurry, take your time:\n";
$i_complex = <>; chomp $i_complex;
print "Got $i_complex complex.\n";
print "Generating protein-ligand complex topology but before I proceed further, you have to provide mol2 file of same ligand which is present in complex...and by same I mean exact same.\n";
#Demand user to give mol2 file of ligand and generate its library files
print "mol2 file please: ";
$i_ligand = <>;
&ligandtopol($i_ligand);

#Choose force field
while(1)
{
system('clear');
print "Now generating the topology for protein, please chhose the force field\n";
print "Choose the force field by typing their respective alphabate (A, B , C...)";
print "\n",'A: leaprc.amoeba	B: leaprc.constph
C: leaprc.ff02pol.r1	D: leaprc.ff02polEP.r1
E: leaprc.ff03.r1	F: leaprc.ff03ua
G: leaprc.ff10		H: leaprc.ff12SB
I: leaprc.ff13		J: leaprc.ff99bsc0
K: leaprc.ff99SB	L: leaprc.ff99SBildn
M: leaprc.ff99SBnmr	N: leaprc.ffAM1
O: leaprc.ffPM3		P: leaprc.gaff
Q: leaprc.GLYCAM_06EPb	R: leaprc.GLYCAM_06h
S: leaprc.GLYCAM_06h-1	T: leaprc.GLYCAM_06h-12SB
U: leaprc.lipid11	V: leaprc.parmCHI_YIL.bsc',"\nSelect the Force Field:";
$selct_ff = <>; chomp $selct_ff;
if($selct_ff eq 'A' or $selct_ff eq 'a'){$force_field = 'leaprc.amoeba';last;}
elsif($selct_ff eq 'B' or $selct_ff eq 'b'){$force_field = 'leaprc.constph';last;}
elsif($selct_ff eq 'C' or $selct_ff eq 'c'){$force_field = 'leaprc.ff02pol.r1';last;}
elsif($selct_ff eq 'D' or $selct_ff eq 'd'){$force_field = 'leaprc.ff02polEP.r1';last;}
elsif($selct_ff eq 'E' or $selct_ff eq 'e'){$force_field = 'leaprc.ff03.r1';last;}
elsif($selct_ff eq 'F' or $selct_ff eq 'f'){$force_field = 'leaprc.ff03ua';last;}
elsif($selct_ff eq 'G' or $selct_ff eq 'g'){$force_field = 'leaprc.ff10';last;}
elsif($selct_ff eq 'H' or $selct_ff eq 'h'){$force_field = 'leaprc.ff12SB';last;}
elsif($selct_ff eq 'I' or $selct_ff eq 'i'){$force_field = 'leaprc.ff13';last;}
elsif($selct_ff eq 'J' or $selct_ff eq 'j'){$force_field = 'leaprc.ff99bsc0';last;}
elsif($selct_ff eq 'K' or $selct_ff eq 'k'){$force_field = 'leaprc.ff99SB';last;}
elsif($selct_ff eq 'L' or $selct_ff eq 'l'){$force_field = 'leaprc.ff99SBildn';last;}
elsif($selct_ff eq 'M' or $selct_ff eq 'm'){$force_field = 'leaprc.ff99SBnmr';last;}
elsif($selct_ff eq 'N' or $selct_ff eq 'n'){$force_field = 'leaprc.ffAM1';last;}
elsif($selct_ff eq 'O' or $selct_ff eq 'o'){$force_field = 'leaprc.ffPM3';last;}
elsif($selct_ff eq 'P' or $selct_ff eq 'p'){$force_field = 'leaprc.gaff';last;}
elsif($selct_ff eq 'Q' or $selct_ff eq 'q'){$force_field = 'leaprc.GLYCAM_06EPb';last;}
elsif($selct_ff eq 'R' or $selct_ff eq 'r'){$force_field = 'leaprc.GLYCAM_06h';last;}
elsif($selct_ff eq 'S' or $selct_ff eq 's'){$force_field = 'leaprc.GLYCAM_06h-1';last;}
elsif($selct_ff eq 'T' or $selct_ff eq 't'){$force_field = 'leaprc.GLYCAM_06h-12SB';last;}
elsif($selct_ff eq 'U' or $selct_ff eq 'u'){$force_field = 'leaprc.lipid11';last;}
elsif($selct_ff eq 'V' or $selct_ff eq 'v'){$force_field = 'leaprc.parmCHI_YIL.bsc';last;}else{print "Wrong choice, try again \n";}
}
system('clear');
print "You have selected $force_field force field\n";
print "Do you want to select second force field to be used during topology generation?\ntype YES or else hit the enter to continue:";
$sencond_ff = <>; chomp $sencond_ff;

if($sencond_ff =~ /yes/i)
{

while(1)
{
system('clear');
print "Please chhose the second force field\n";
print "Choose the force field by typing their respective alphabate (A, B , C...)";
print "\n",'A: leaprc.amoeba	B: leaprc.constph
C: leaprc.ff02pol.r1	D: leaprc.ff02polEP.r1
E: leaprc.ff03.r1	F: leaprc.ff03ua
G: leaprc.ff10		H: leaprc.ff12SB
I: leaprc.ff13		J: leaprc.ff99bsc0
K: leaprc.ff99SB	L: leaprc.ff99SBildn
M: leaprc.ff99SBnmr	N: leaprc.ffAM1
O: leaprc.ffPM3		P: leaprc.gaff
Q: leaprc.GLYCAM_06EPb	R: leaprc.GLYCAM_06h
S: leaprc.GLYCAM_06h-1	T: leaprc.GLYCAM_06h-12SB
U: leaprc.lipid11	V: leaprc.parmCHI_YIL.bsc',"\nSelect the Force Field:";
$selct_ff = <>; chomp $selct_ff;
if($selct_ff eq 'A' or $selct_ff eq 'a'){$force_field2 = 'leaprc.amoeba';last;}
elsif($selct_ff eq 'B' or $selct_ff eq 'b'){$force_field2 = 'leaprc.constph';last;}
elsif($selct_ff eq 'C' or $selct_ff eq 'c'){$force_field2 = 'leaprc.ff02pol.r1';last;}
elsif($selct_ff eq 'D' or $selct_ff eq 'd'){$force_field2 = 'leaprc.ff02polEP.r1';last;}
elsif($selct_ff eq 'E' or $selct_ff eq 'e'){$force_field2 = 'leaprc.ff03.r1';last;}
elsif($selct_ff eq 'F' or $selct_ff eq 'f'){$force_field2 = 'leaprc.ff03ua';last;}
elsif($selct_ff eq 'G' or $selct_ff eq 'g'){$force_field2 = 'leaprc.ff10';last;}
elsif($selct_ff eq 'H' or $selct_ff eq 'h'){$force_field2 = 'leaprc.ff12SB';last;}
elsif($selct_ff eq 'I' or $selct_ff eq 'i'){$force_field2 = 'leaprc.ff13';last;}
elsif($selct_ff eq 'J' or $selct_ff eq 'j'){$force_field2 = 'leaprc.ff99bsc0';last;}
elsif($selct_ff eq 'K' or $selct_ff eq 'k'){$force_field2 = 'leaprc.ff99SB';last;}
elsif($selct_ff eq 'L' or $selct_ff eq 'l'){$force_field2 = 'leaprc.ff99SBildn';last;}
elsif($selct_ff eq 'M' or $selct_ff eq 'm'){$force_field2 = 'leaprc.ff99SBnmr';last;}
elsif($selct_ff eq 'N' or $selct_ff eq 'n'){$force_field2 = 'leaprc.ffAM1';last;}
elsif($selct_ff eq 'O' or $selct_ff eq 'o'){$force_field2 = 'leaprc.ffPM3';last;}
elsif($selct_ff eq 'P' or $selct_ff eq 'p'){$force_field2 = 'leaprc.gaff';last;}
elsif($selct_ff eq 'Q' or $selct_ff eq 'q'){$force_field2 = 'leaprc.GLYCAM_06EPb';last;}
elsif($selct_ff eq 'R' or $selct_ff eq 'r'){$force_field2 = 'leaprc.GLYCAM_06h';last;}
elsif($selct_ff eq 'S' or $selct_ff eq 's'){$force_field2 = 'leaprc.GLYCAM_06h-1';last;}
elsif($selct_ff eq 'T' or $selct_ff eq 't'){$force_field2 = 'leaprc.GLYCAM_06h-12SB';last;}
elsif($selct_ff eq 'U' or $selct_ff eq 'u'){$force_field2 = 'leaprc.lipid11';last;}
elsif($selct_ff eq 'V' or $selct_ff eq 'v'){$force_field2 = 'leaprc.parmCHI_YIL.bsc';last;}else{print "Wrong choice, try again \n";}
}
print "Generating topology with following two force fields:\n$force_field and $force_field2 \n";
}else{print "Generating topology with single force field\n";}
#Define the box size
$boxSize = 10.0;
print 'Default box size is 10.0, do you want to modify it?',"\n";
$modifyBox = <>; chomp $modifyBox;
if($modifyBox == 'Y' or $modifyBox == 'y')
    {
    print "\nPlease enter the new box size (minLimit = 8, maxLimit=30)\n";
    $boxSize = <>; chomp $boxSize;
    while($boxSize <= 8 or $boxSize >= 30)
        {
        print "Please enter the box size between 8 to 30 and please enter only numbers\n";
        $boxSize = <>; chomp $boxSize;
        }
    }else{print "Default box size 10.0 will be used";}

#generate topology files
open(WRITETOPOLCOM, ">complex.tleap");
print WRITETOPOLCOM "source $force_field\nsource $force_field2\nloadamberparams $ligfrc\nloadoff $liglib\ncomplex=loadpdb $i_complex\n","solvateoct complex TIP3PBOX $boxSize","\n",'addions complex Na+ 0',"\n",'addions complex Cl- 0',"\n",'saveamberparm complex complexsolv.prmtop complexsolv.inpcrd',"\n",'savepdb complex complexsolv.pdb',"\n",'quit';
print "tleap input file created \n";
system('clear');
system('tleap -f complex.tleap');

print "***************************CONGRATULATIONS! PROTEIN-Liagand complex TOPOLOGY HAS BEEN PREPARED***************************\n";

}else{print "\n",'Sorry, I am very stupid script. I can not generate topology for any other kind of molecule type',"\n",'Choose among A, B or C';}
