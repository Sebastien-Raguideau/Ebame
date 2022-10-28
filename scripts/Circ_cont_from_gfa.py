#!/usr/bin/env python3
from Bio.SeqIO.FastaIO import SimpleFastaParser as sfp
from collections import Counter, defaultdict
import argparse
import os


parser = argparse.ArgumentParser()
parser.add_argument("gfa", help="Assembly in .gfa format")
parser.add_argument("dir_out", help="output dir to store circular contigs files")
args = parser.parse_args()

ASSEMBLY_GRAPH = args.gfa
DIRECTORY_OUTPUT = args.dir_out

# first pass over the file: 
#  - look at line describing linkages
#  - select node linked to itself
circ = set()
for line in open(ASSEMBLY_GRAPH):
    if line[0]=="L":
        L,node1,s1,node2,s2,cigar,*_ = line.rstrip().split("\t")
        if (node1==node2)&(s1==s2):
            circ.add(node1)

# secon pass over the file: 
#  - look at nodes definition line
#  - if node name is in circ, write it as file
os.system("mkdir -p %s"%DIRECTORY_OUTPUT)
for line in open(ASSEMBLY_GRAPH):
	if line[0]=="S":
		S,node,seq,*_ = line.rstrip().split("\t")
		if node in circ:
			with open("%s/%s.fa"%(DIRECTORY_OUTPUT,node),"w") as handle:
				handle.write(">%s\n%s\n"%(node,seq))
