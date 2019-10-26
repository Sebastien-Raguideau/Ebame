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

sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9

sudo add-apt-repository 'deb https://cloud.r-project.org/bin/linux/ubuntu bionic-cran35/'

sudo apt-get update

sudo apt-get install --assume-yes r-base r-base-dev

sudo $APP_DIR/scripts/RPInstall.sh ggplot2
sudo $APP_DIR/scripts/RPInstall.sh reshape
sudo $APP_DIR/scripts/RPInstall.sh reshape2
sudo $APP_DIR/scripts/RPInstall.sh gplots
sudo $APP_DIR/scripts/RPInstall.sh getopt
sudo $APP_DIR/scripts/RPInstall.sh vegan
sudo $APP_DIR/scripts/RPInstall.sh ellipse
sudo $APP_DIR/scripts/RPInstall.sh plyr
sudo $APP_DIR/scripts/RPInstall.sh grid
sudo $APP_DIR/scripts/RPInstall.sh gridExtra
