#!/usr/bin/env bash

# get repos
mkdir -p $HOME/repos
git clone https://github.com/Sebastien-Raguideau/Ebame19-Quince.git $HOME/repos/Ebame19-Quince

# conda install everything else
conda env create -f $HOME/repos/Ebame19-Quince/conda_env.yaml 

