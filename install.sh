#!/usr/bin/env bash

# define home
export HOME2=/home/ubuntu

# ----- get all repos ----- 
mkdir -p $HOME2/repos
cd $HOME2/repos

git clone https://github.com/Sebastien-Raguideau/Ebame19-Quince.git
git clone https://github.com/Sebastien-Raguideau/Metahood.git
git clone https://github.com/chrisquince/Ebame5.git
git clone https://github.com/BinPro/CONCOCT.git
git clone https://github.com/chrisquince/DESMAN.git
git clone https://github.com/chrisquince/MAGAnalysis.git

# conda install 
source /etc/profile.d/conda.sh 

# conda install may fail due to use of metachannel, so rerun it until it works
conda env create -f $APP_DIR/conda_env_MetaHood.yaml 
# while [ $? -ne 0 ]; do
#     conda env create -f $APP_DIR/conda_env_MetaHood.yaml 
# done

# conda install may fail due to use of metachannel, so rerun it until it works
conda env create -f $APP_DIR/conda_env_LongReads.yaml 
# while [ $? -ne 0 ]; do
#     conda env create -f $APP_DIR/conda_env_LongReads.yaml 
# done


# fix concoct install, so that concoct_refine works
sed -i 's/original_data.values()/original_data.values/g' /var/lib/miniconda3/envs/MetaHood/bin/concoct_refine 

# get rpsblast+
apt install ncbi-blast+ --assume-yes

# Make Metahood run with old cod db....
cp $HOME2/repos/CONCOCT/scgs/cdd_to_cog.tsv $HOME2/repos/Metahood/scg_data/cdd_to_cog.tsv


# ---- install R libraries ----
# add repo serverkey
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9

# add repo 
sudo add-apt-repository 'deb https://cloud.r-project.org/bin/linux/ubuntu bionic-cran35/'

# add look for update from repo
sudo apt-get update

# install updates
sudo apt-get install --assume-yes evince
sudo apt-get install --assume-yes r-base r-base-dev

# install R packages
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

# -----------install guppy --------------
cd $HOME2/repos
wget https://mirror.oxfordnanoportal.com/software/analysis/ont-guppy-cpu_3.3.0_linux64.tar.gz
tar -xvzf ont-guppy-cpu_3.3.0_linux64.tar.gz 

export PATH=~/repos/ont-guppy-cpu/bin:$PATH

# ---------- modify .bashrc ------------------
# add -h to ll 
sed -i "s/alias ll='ls -alF'/alias ll='ls -alhF'/g" $HOME2/.bashrc 

# add multitude of export to .bashrc
echo -e "\n\n #------ export path to repos/db -------">>$HOME2/.bashrc 
echo "export CONCOCT=~/repos/CONCOCT">>$HOME2/.bashrc 
echo "export DESMAN=~/repos/DESMAN">>$HOME2/.bashrc 
echo "export EBAME5=~/repos/Ebame5">>$HOME2/.bashrc 
echo "export MAGAnalysis=~/repos/MAGAnalysis">>$HOME2/.bashrc 
echo "export COGSDB_DIR=~/Databases/rpsblast_cog_db">>$HOME2/.bashrc 

# to be able to launch conda 
echo -e "\n\n #------ necessary to use conda -------">>$HOME2/.bashrc 
echo -e "source /etc/profile.d/conda.sh ">>$HOME2/.bashrc

# guppy install
echo -e "\n\n #------ guppy path -------">>$HOME2/.bashrc 
echo -e "export PATH=~/repos/ont-guppy-cpu/bin:$PATH ">>$HOME2/.bashrc


# ------------ fix rigths --------------------
# fix conda ownership, so that user can create stuffs
chown -R 1000:1000 /var/lib/miniconda3/*

# fix HOME2 ownership, so that user can create stuffs
chown -R 1000:1000 $HOME2/*
