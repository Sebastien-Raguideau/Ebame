#!/usr/bin/env bash

# define home
# {
export HOME2=/home/ubuntu
export CONDA=/var/lib/miniforge/condabin
export APP_DIR=/ifb/apprepo/Ebame-quince
export PATH=$CONDA:$PATH
unset PYTHONPATH
mamba env create -f /ifb/apprepo/Ebame-quince/conda_env_Trait_inference.yaml


# # for conda install
# ulimit -n 63852

# # ------------------------------
# # ----- get all repos ---------- 
# # ------------------------------

# mkdir -p $HOME2/repos
# cd $HOME2/repos

# git clone https://github.com/Sebastien-Raguideau/Ebame.git
# git clone --recurse-submodules https://github.com/chrisquince/STRONG.git
# git clone https://github.com/chrisquince/genephene.git
# git clone https://github.com/rvicedomini/strainberry.git
# git clone https://github.com/kkpsiren/PlasmidNet.git
# git clone https://github.com/GaetanBenoitDev/metaMDBG.git

# # ------------------------------
# # ----- all sudo installs ------
# # ------------------------------

# sudo apt-get update
# # STRONG compilation
# sudo apt-get -y install libbz2-dev libreadline-dev cmake g++ zlib1g zlib1g-dev
# # bandage and utils
# sudo apt-get -y install qt5-default gzip unzip feh evince

# # ------------------------------
# # ----- Chris tuto -------------
# # ------------------------------
# cd $HOME2/repos/STRONG

# # conda/mamba is not in the path for root, so I need to add it
# export PATH=$CONDA:$PATH
# ./install_STRONG.sh

# # Bandage install
# cd $HOME2/repos/
# wget https://github.com/rrwick/Bandage/releases/download/v0.8.1/Bandage_Ubuntu_dynamic_v0_8_1.zip
# mkdir Bandage && unzip Bandage_Ubuntu_dynamic_v0_8_1.zip -d Bandage && mv Bandage_Ubuntu_dynamic_v0_8_1.zip Bandage

# # trait inference
# mamba env create -f $HOME2/repos/Ebame/conda_env_Trait_inference.yaml

# # Plasmidnet
# mamba create -c bioconda --name plasmidnet python=3.8 prodigal -y
# . $CONDA/activate plasmidnet
# pip install -r $HOME2/repos/PlasmidNet/requirements.txt

# # -------------------------------------
# # -----------LongRead Tuto --------------
# # -------------------------------------
# # --- guppy ---
# cd $HOME2/repos
# wget https://europe.oxfordnanoportal.com/software/analysis/ont-guppy-cpu_5.0.16_linux64.tar.gz
# tar -xvzf ont-guppy-cpu_5.0.16_linux64.tar.gz && mv ont-guppy-cpu_5.0.16_linux64.tar.gz ont-guppy-cpu/

# # --- everything else ---
# mamba env create -f $HOME2/repos/Ebame/conda_env_LongReads.yaml

# # --- download db for LongReads env --
# . $CONDA/deactivate
# . $CONDA/activate LongReads

# # metamdbg
# conda env config vars set CPATH=${CONDA_PREFIX}/include:${CPATH}
# . $CONDA/deactivate
# . $CONDA/activate LongReads

# cd $HOME2/repos/metaMDBG && mkdir build && cd build
# cmake .. && make -j3

# # krona
# rm -rf /var/lib/miniforge/envs/LongReads/opt/krona/taxonomy
# mkdir $HOME2/repos/krona_taxonomy
# ln -s $HOME2/repos/krona_taxonomy /var/lib/miniforge/envs/LongReads/opt/krona/taxonomy
# ktUpdateTaxonomy.sh

# # same with gtdb
# conda env config vars set GTDBTK_DATA_PATH=/ifb/data/public/teachdata/ebame-2022/metagenomics/Datasets/gtdbtk/release207_v2

# # checkm
# checkm data setRoot $HOME2/repos/checkm_data

# # --- Pavian ---
# #source /var/lib/miniconda3/bin/activate LongReads
# #R -e 'if (!require(remotes)) { install.packages("remotes",repos="https://cran.irsn.fr") }
# #remotes::install_github("fbreitwieser/pavian")'

# # -------------------------------------
# # -----------Seb Tuto --------------
# # -------------------------------------

# . $CONDA/deactivate
# . $CONDA/activate STRONG
# mamba install -c bioconda checkm-genome megahit bwa -y

# # add checkm database
# mkdir -p $HOME2/repos/checkm_data
# cd $HOME2/repos/checkm_data
# wget https://data.ace.uq.edu.au/public/CheckM_databases/checkm_data_2015_01_16.tar.gz && tar -xvzf checkm_data_2015_01_16.tar.gz
# checkm data setRoot $HOME2/repos/checkm_data

# # same but with gtdb
# conda env config vars set GTDBTK_DATA_PATH=/ifb/data/public/teachdata/ebame-2022/metagenomics/Datasets/gtdbtk/release207_v2

# # -------------------------------------
# # ---------- modify .bashrc -----------
# # -------------------------------------

# # add -h to ll 
# sed -i "s/alias ll='ls -alF'/alias ll='ls -alhF'/g" $HOME2/.bashrc 

# # add multitude of export to .bashrc
# echo -e "\n\n#--------------------------------------\n#------ export path to repos/db -------\n#--------------------------------------">>$HOME2/.bashrc

# # ---------- add things in path --------------
# # guppy install
# echo -e "\n\n #------ guppy path -------">>$HOME2/.bashrc 
# echo -e 'export PATH=~/repos/ont-guppy-cpu/bin:$PATH'>>$HOME2/.bashrc

# # STRONG install
# echo -e "\n\n #------ STRONG path -------">>$HOME2/.bashrc 
# echo -e 'export PATH=~/repos/STRONG/bin:$PATH '>>$HOME2/.bashrc

# # Bandage install
# echo -e "\n\n #------ guppy path -------">>$HOME2/.bashrc 
# echo -e 'export PATH=~/repos/Bandage:$PATH'>>$HOME2/.bashrc

# #  add repos scripts 
# echo -e "\n\n #------ Ebame -------">>$HOME2/.bashrc
# echo -e 'export PATH=~/repos/Ebame/scripts:$PATH'>>$HOME2/.bashrc

# # add strainberry
# echo -e "\n\n #------ strainberry -------">>$HOME2/.bashrc 
# echo -e 'export PATH=/home/ubuntu/repos/strainberry:$PATH'>>$HOME2/.bashrc

# # add strainberry
# echo -e "\n\n #------ plasmidnet -------">>$HOME2/.bashrc 
# echo -e 'export PATH=/home/ubuntu/repos/PlasmidNet/bin:$PATH'>>$HOME2/.bashrc

# # guppy install
# echo -e "\n\n #------ guppy path -------">>$HOME2/.bashrc 
# echo -e 'export PATH=~/repos/ont-guppy-cpu/bin:$PATH'>>$HOME2/.bashrc

# # metaMDBG install
# echo -e "\n\n #------ MetaMDBG path -------">>$HOME2/.bashrc 
# echo -e 'export PATH=~/repos/metaMDBG/build/bin:$PATH'>>$HOME2/.bashrc


# # --------------------------------------------
# # -------- make the home better --------------
# # --------------------------------------------
# # create a project folder corresponding to 
# ln -s /ifb/data/mydatalocal $HOME2/Projects
# ln -s /ifb/data/public/teachdata/ebame-2022/metagenomics $HOME2/Datasets

# # --------------------------------------------
# # ------------ fix rigths --------------------
# # --------------------------------------------
# # fix HOME2 ownership, so that user can create stuffs
# chown -R 1000:1000 $HOME2/repos
# chown -R 1000:1000 $HOME2/Projects

# # fix that otherwise unable to add/change envs
# chown -R 1000:1000 /var/lib/miniforge
# # --------------------------------------------
# # -------- sily hostname ---------------------
# # --------------------------------------------

# hostnames=("lili" "lala" "lulu" "saperlipopette" "sacrebleu" "mouhahaha" "prepare_for_AI_uprising" "this_is_the_bestest_tuto" "chubbybunny" "sillygoose" "badger_badger_badger_mushroom" "ebame_forever" "church_of_anvio" "zippydoodah" "metagnomonique" "bubblesnuggle" "flibbertigibbet" "whatchamacallit" "gobbleggidillygook" "wobbledeewoodoo" "tigglewaggle" "zapyzippity" "make_iufm_great_again" "Mr_Tux_president" "bamboozle_bop" "squigglywomp" "flapdoodle" "fuzzyfizzle" "wigglewhomp" "snickerdoodle" "boopityboo" "gobbledygump" "oodlesofnoodles" "flibberflabber" "supercalifragiawesome" "jitterbugger" "froggystomper" "wigglewiggle" "quackityquack" "doohickeywhizz" "beepboopbop" "lollygagging_legion" "spiffytastic" "scrimblescromble")

# # Select a random index from the array
# random_index=$((RANDOM % ${#hostnames[@]}))
# # Get the random hostname
# random_hostname="${hostnames[random_index]}"
echo $random_hostname

# Set the PS1 prompt with the random hostname
new_PS1="${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@$random_hostname\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ "
echo "PS1='$new_PS1'">>$HOME2/.bashrc

# }&>"$APP_DIR/vm_install.log"
