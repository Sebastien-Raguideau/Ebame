#!/usr/bin/env python3

import os, sys, argparse, shutil, gzip
from Bio.SeqIO.FastaIO import SimpleFastaParser

def main(argv):
    
    parser = argparse.ArgumentParser()

    parser.add_argument("contigFilename", help="contig filename (.fasta or .fasta.gz)")
    #parser.add_argument("minLength", help="minimum length of extracted contigs")
    parser.add_argument("outputDir", help="output directory for extracted circular contigs")
    
    #parser.add_argument("csv", help="output unitig coverage file (.csv)")
    
    args = parser.parse_args()

    contigFilename = args.contigFilename
    minContigLength = 0 #int(args.minLength)
    
    outputDir = args.outputDir
    if not os.path.exists(outputDir):
        os.makedirs(outputDir)
    
    extractCircularContigs(contigFilename, minContigLength, outputDir)


def extractCircularContigs(inputFilename, minContigLength, outputDir):

    nbCircularContigs = 0
    fileHandle = None

    if(".gz" in inputFilename):
        fileHandle = gzip.open(inputFilename, "rt")
    else:
        fileHandle = open(inputFilename)

    for header, seq in SimpleFastaParser(fileHandle):
        if len(seq) < minContigLength: continue

        if header.endswith("c"):
            nbCircularContigs += 1

            filename = outputDir + "/" + header + ".fa"

            binFile = open(filename, "w")
            binFile.write(">" + header + "\n")
            binFile.write(seq + "\n")
            binFile.close()


    print("Nb circular contigs: ", nbCircularContigs) 


if __name__ == "__main__":
    main(sys.argv[1:])  
