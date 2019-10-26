#!/usr/bin/env bash

# conda install 
source /etc/profile.d/conda.sh 

# conda install may fail due to use of metachannel, so rerun it until it works
conda env create -f $APP_DIR/conda_env_MetaHood.yaml 
while [ $? -ne 0 ]; do
    conda env create -f $APP_DIR/conda_env_MetaHood.yaml 
done

# conda install may fail due to use of metachannel, so rerun it until it works
conda env create -f $APP_DIR/conda_env_LongReads.yaml 
while [ $? -ne 0 ]; do
    conda env create -f $APP_DIR/conda_env_LongReads.yaml 
done

# fix conda ownership, so that user can create stuffs
chown -R 1000:1000 /var/lib/miniconda3/*

# fix concoct install, so that concoct_refine works
sed -i 's/original_data.values()/original_data.values/g' /var/lib/miniconda3/envs/MetaHood/bin/concoct_refine 

mkdir ~/repos

cd ~/repos

git clone https://github.com/BinPro/CONCOCT.git

git clone https://github.com/chrisquince/DESMAN.git

export CONCOCT=~/repos/CONCOCT
export DESMAN=~/repos/DESMAN

export PATH=$APP_DIR/scripts:$PATH

mkdir ~/Databases

cd ~/Databases

wget https://desmandatabases.s3.climb.ac.uk/rpsblast_cog_db.tar.gz

tar -xvzf rpsblast_cog_db.tar.gz

export COGSDB_DIR=~/Databases/rpsblast_cog_db
