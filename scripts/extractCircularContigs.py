#!/usr/bin/env python3

import os, sys, argparse, shutil, gzip
from Bio.SeqIO.FastaIO import SimpleFastaParser

def main(argv):
    
    parser = argparse.ArgumentParser()

    parser.add_argument("contigFilename", help="contig filename (.fasta or .fasta.gz)")
    parser.add_argument("dataFilename", help="Info filename")
    parser.add_argument("assembler", help="metaMDBG or metaflye")
    #parser.add_argument("minLength", help="minimum length of extracted contigs")
    parser.add_argument("outputDir", help="output directory for extracted circular contigs")
    
    #parser.add_argument("csv", help="output unitig coverage file (.csv)")
    
    args = parser.parse_args()

    contigFilename = args.contigFilename
    dataFilename = args.dataFilename
    minContigLength = 0 #int(args.minLength)
    assembler = args.assembler

    outputDir = args.outputDir
    if not os.path.exists(outputDir):
        os.makedirs(outputDir)
    
    extractCircularContigs(contigFilename, dataFilename, assembler, minContigLength, outputDir)


def extractCircularContigs(inputFilename, dataFilename, assembler, minContigLength, outputDir):

    isLongContig, isCircularContig = loadCircularContigs(dataFilename, assembler, minContigLength, True)

    nbCircularContigs = 0
    fileHandle = None

    if(".gz" in inputFilename):
        fileHandle = gzip.open(inputFilename, "rt")
    else:
        fileHandle = open(inputFilename)

    for header, seq in SimpleFastaParser(fileHandle):
        if len(seq) < minContigLength: continue

        header = header.split(" ")[0]

        if assembler == "myloasm":
            header = header.split(" ")[0].split("_")[0]

        if header in isCircularContig:
            nbCircularContigs += 1

            filename = outputDir + "/" + assembler + "_" + header + ".fa"

            binFile = open(filename, "w")
            binFile.write(">" + assembler + "_" + header + "\n")
            binFile.write(seq + "\n")
            binFile.close()


    print("Nb circular contigs: ", nbCircularContigs) 

def loadCircularContigs(inputFilename, assembler, minContigLength, collectCircularContigs):

    isCircularContig = set()
    isLongContig = set()

    fileHandle = None

    if(".gz" in inputFilename):
        fileHandle = gzip.open(inputFilename, "rt")
    else:
        fileHandle = open(inputFilename)

    if "metaMDBG" in assembler or "nanoMDBG" in assembler:

        for header, seq in SimpleFastaParser(fileHandle):

            contigName, lengthStr, coverageStr, circularStr = header.split(" ")
            
            if circularStr.split("=")[1] == "yes":
                isCircularContig.add(contigName)

            if len(seq) >= minContigLength:
                isLongContig.add(contigName)

    elif "hifiasm" in assembler:
        
        for header, seq in SimpleFastaParser(fileHandle):

            contigName = header.split(" ")[0]

            if header.endswith("c"):
                isCircularContig.add(contigName)

            if len(seq) >= minContigLength:
                isLongContig.add(contigName)

    elif "metaflye" in assembler:
        fileHandle.readline() #skip header

        for line in fileHandle:
            line = line.rstrip()
            if len(line) == 0: continue
            fields = line.split("\t")

            contigName = fields[0]

            isCircular = fields[3] == "Y"
            if isCircular:
                isCircularContig.add(contigName)

            contigLength = int(fields[1])
            if contigLength >= minContigLength:
                isLongContig.add(contigName)
    elif "myloasm" in assembler:

        for header, seq in SimpleFastaParser(fileHandle):

            
            contigName, lengthStr, circularStr, coverageStr, duplicatedStr = header.split(" ")[0].split("_")
            #contigName = header.split(" ")[0]

            #print(circularStr.split("-"), circularStr.split("-")[1] == "yes")

            if circularStr.split("-")[1] == "yes":
                isCircularContig.add(contigName)

            if len(seq) >= minContigLength:
                isLongContig.add(contigName)

    if collectCircularContigs:
        return isLongContig, isCircularContig
    else:
        return isLongContig, None
    
if __name__ == "__main__":
    main(sys.argv[1:])  
