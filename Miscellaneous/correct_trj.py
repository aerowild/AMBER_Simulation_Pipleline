#!/usr/bin/python
import re
'''opening the mdcrd file with read only mode'''
#mdcrd = raw_input("Please provide the name of mdcrd: ")
mdcrd = 'heat3.mdcrd'
ifile = open(mdcrd,'r',0)
#write the corrected file
ofilename = ifile.name[0:-6]+'_cor.mdcrd' #define the name of output file based on input file
ofile = open(ofilename,'a')
#pattern = raw_input("I will need the box information string, please provide the exact string, try to use copy and paste: ")
pattern = '71.633  71.633  71.633'

#This will read the whole file in blocks. The number of blocks depends on the total size of the file. e.g. 48 MB file is being read in 48 iterations
for num in range(1,48):
    print num
    if num <= 46:
        print "Working in block %d\n" %num
        read_ifile = ifile.read(1000000)
        #split file by new line character
        file_byline = read_ifile.split('\n')
        for line in file_byline:
            ofile.write("%s\n" %line,)
        num += 1
    elif num == 47:
        print "Working in last block\n"
        read_ifile = ifile.read()    
        #split file by new line character
        file_byline = read_ifile.split('\n')
        counter = -1
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
