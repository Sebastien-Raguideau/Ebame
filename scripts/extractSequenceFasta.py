
import os, sys, argparse, shutil, glob, gzip
from Bio.SeqIO.FastaIO import SimpleFastaParser



def main(argv):

    parser = argparse.ArgumentParser()

    parser.add_argument("fastaFile", help="fasta file")
    parser.add_argument("headerName", help="")
    parser.add_argument("outFile", help="")
    parser.add_argument("--startPos", help="")
    parser.add_argument("--endPos", help="")
    
    args = parser.parse_args()
    headerName = args.headerName
    outputFile = open(args.outFile, "w")

    if args.fastaFile == args.outFile: exit(1)

    startPos = None
    endPos = None
    if args.startPos:
        startPos = int(args.startPos)
    if args.endPos:
        endPos = int(args.endPos)

    fileHandle = None

    if(".gz" in args.fastaFile):
        fileHandle = gzip.open(args.fastaFile, "rt")
    else:
        fileHandle = open(args.fastaFile)

    for header, seq in SimpleFastaParser(fileHandle):
        if headerName in header:
            
            print("Found contig: ", header, len(seq))
            outputFile.write(">" + header + "\n")

            if startPos is not None:
                seq = seq[startPos:endPos]
                
            outputFile.write(seq + "\n")
            break


    outputFile.close()




if __name__ == "__main__":
    main(sys.argv[1:])  
