#!/usr/bin/python
import re
'''opening the mdcrd file with read only mode'''
mdcrd = raw_input("Please provide the name of mdcrd: ")
ifile = open(mdcrd,'r')

#reading the opened file
read_ifile = ifile.read()
#split file by new line character
file_byline = read_ifile.split('\n')

#print "file read %s" %read_ifile
#print file_byline[-2]
#print "Length of array is:%d" %len(file_byline)

#write the corrected file
ofilename = ifile.name[0:-6]+'_cor.mdcrd' #define the name of output file based on input file
ofile = open(ofilename,'w')

counter = -1
pattern = raw_input("I will need the box information string, please provide the exact string, try to use copy and paste: ")
for linenum in range(len(file_byline)):
    if pattern in file_byline[counter]:
        corrected_file = file_byline[0:counter+1]
        for line in corrected_file:
            ofile.write("%s\n" %line,)
        #print corrected_file
        break
    else:
        counter -= 1

ifile.close()
ofile.close()
