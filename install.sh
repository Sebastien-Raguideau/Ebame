#!/usr/bin/env bash

# conda install 
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh
bash ~/miniconda.sh -b -p $HOME/miniconda

# conda install everything else
mkdir $HOME/repos

conda env create -f conda_env.yaml