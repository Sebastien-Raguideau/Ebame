# Metahood / snakemake tutorial

## Metahood
Metahood is a pipeline entirely based on snakemake. 

**What the pipline do :**
 - sample qualitycheck/trimming
- assemblies / co-assemblies
- binning (Concoct/Metabat2)
- de novo tree construction for mags
- diamond annotation and profiles
- output annotated orf graphs (derived from assembly graph)
- Strain resolution (Desman)

 **What we want to add :**
 - human Dna/contamination removal 
 - taxonomy profiling (CAT, kraken, ...)
 - other options for  binning, e.g. maxbins2  
 - other bins assessment tools, e.g CheckM, Busco 
 - mags annotation and profiles
 - documentation
 
 **Overview of the rules workflows**
![alt tag](./Binning.png)

###  How to run Metahood:
    ~/repos/Metahood/start.py <output folder> --config <config file> -t <nb threads> -s <snakemake options> 

 **Configuration file**
 The apparent lack of parameter is 
[https://github.com/Sebastien-Raguideau/Metahood/blob/master/config.yaml](https://github.com/Sebastien-Raguideau/Metahood/blob/master/config.yaml)

 **Samples Setup**
Metahood will look into the data folder for, samples folders containing only 2 fastq files (.fastq or .fastq.gz). This folder structure can be made beforehand, or it can be build with the sample setup step of metahood. It then require a .csv file with filename,R1_or_R2,sample name.
Example : [https://github.com/Sebastien-Raguideau/Metahood/blob/master/Samples.csv](https://github.com/Sebastien-Raguideau/Metahood/blob/master/Samples.csv)

###  Let's Run MetaHood:
#### Last Minute fix

    cd ~/repos/Metahood/
    git pull
    cd ~/repos/Ebame19-Quince/
    git pull


<details><summary>Do we need to setup samples? </summary>
<p>
Yes, the file is at  

`~/repos/Ebame19-Quince/Samples.csv` 

</p>
</details>

Hardest step is to generate the configuration file :

    cd ~/Projects
    mkdir -p InfantGut_Metahood
    cd InfantGut_Metahood
    cp ~/repos/Metahood/config.yaml .
    nano  config.yaml

<details><summary>Alternative </summary>
<p>

    cp ~/repos/Metahood/config.yaml ~/Projects/InfantGut_Metahood/

</p>
</details>


#### Dependencies
We handle  all dependencies installation though miniconda,  you can have a look at  ~/repos/Ebame19-Quince/conda_env_MetaHood.yaml for more details

Creating the env you need is a command line away :
##### Don't run this

    conda env create -f conda_env_MetaHood.yaml
As it was already created you need just to activate the MetaHood conda env :

    conda activate MetaHood


#### Finally launch Metahood
First with the --dryrun option, what is the output?

    ./start.py ~/Projects/InfantGut_Metahood/ --config ~/Projects/InfantGut_Metahood/config.yaml -t <nb> -s --dryrun        


