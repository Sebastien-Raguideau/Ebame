#!/usr/bin/env bash

mkdir -p ~/repos

cd ~/repos

git clone https://github.com/BinPro/CONCOCT.git

git clone https://github.com/chrisquince/DESMAN.git

git clone https://github.com/chrisquince/Ebame5.git

git clone https://github.com/chrisquince/MAGAnalysis.git

export CONCOCT=~/repos/CONCOCT
export DESMAN=~/repos/DESMAN
export EBAME5=~/repos/Ebame5
export MAGAnalysis=~/repos/MAGAnalysis

mkdir ~/Databases

cd ~/Databases

wget https://desmandatabases.s3.climb.ac.uk/rpsblast_cog_db.tar.gz

tar -xvzf rpsblast_cog_db.tar.gz

export COGSDB_DIR=~/Databases/rpsblast_cog_db

wget https://mirror.oxfordnanoportal.com/software/analysis/ont-guppy-cpu_3.3.0_linux64.tar.gz

tar -xvzf ont-guppy-cpu_3.3.0_linux64.tar.gz 

export PATH=~/ont-guppy-cpu/bin:$PATH