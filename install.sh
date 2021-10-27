#!/usr/bin/env bash

# define home
export HOME2=/home/ubuntu

# ----- get all repos ----- 
mkdir -p $HOME2/repos
cd $HOME2/repos

git clone https://github.com/Sebastien-Raguideau/Ebame21-Quince.git
git clone --recurse-submodules https://github.com/chrisquince/STRONG.git
cd $HOME2/repos/STRONG
git submodule foreach git pull origin master

# ----- run strong install --------
sudo apt-get update
sudo apt-get -y install libbz2-dev libreadline-dev cmake g++ zlib1g zlib1g-dev
cd $HOME2/repos/STRONG
./install_STRONG.sh 


# # -----------Rob env --------------
# cd $HOME2/repos

# # --- guppy ---
# wget https://europe.oxfordnanoportal.com/software/analysis/ont-guppy-cpu_5.0.16_linux64.tar.gz
# tar -xvzf ont-guppy-cpu_5.0.16_linux64.tar.gz 
# # guppy install
# echo -e "\n\n #------ guppy path -------">>$HOME2/.bashrc 
# echo -e "export PATH=~/repos/ont-guppy-cpu/bin:$PATH ">>$HOME2/.bashrc

# # --- everything else ---
# mamba install $APP_DIR/conda_env_LongReads.yaml


# # ---------- modify .bashrc ------------------
# # add -h to ll 
# sed -i "s/alias ll='ls -alF'/alias ll='ls -alhF'/g" $HOME2/.bashrc 

# # add multitude of export to .bashrc
# echo -e "\n\n #------ export path to repos/db -------">>$HOME2/.bashrc



# # ------------ fix rigths --------------------
# # fix conda ownership, so that user can create stuffs
# chown -R 1000:1000 /var/lib/miniconda3/*

# # fix HOME2 ownership, so that user can create stuffs
# chown -R 1000:1000 $HOME2/*
