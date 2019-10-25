#!/usr/bin/env bash

# conda install 
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh
bash ~/miniconda.sh -b -p $HOME/miniconda

# get repos
mkdir -p $HOME/repos
git clone https://github.com/Sebastien-Raguideau/Ebame19-Quince.git $HOME/repos/

# conda install everything else
conda env create -f $HOME/repos/Ebame19-Quince/conda_env.yaml 

