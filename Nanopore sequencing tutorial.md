# EBAME 6 2021: Nanopore sequencing workshop

## Long read metagenomics of the human gut microbiome


### Introduction
Today we aim to use real, nanopore derived, long read sequence data to examen the community composition of two mock communities constructed of representative members of the human gut microbiome. The tutorial is designed to act as a reference for processing long reads from raw fast5 files to an assembled and taxonomically classified metagenome. While example codes for each step are provided, they are only available when revealed by clicking on the drop-down menus. This affords you the opportunity to try and implement code from the linked help pages and manuals of the tools being used. It is important to note that many other metagenomic tools and pipelines are available to assemble and undertake taxonomic classification and can be implemented depending on your sample, aim, time and available computational power.

### Laboratory methods
Bacterial isolates were grown under anerobic conditions in species specific media. Cultures were standardised to 1 x 10^8 cells / ml via species specific calibrated optical density mesurments. Mock communities were constructed by mixing species in known proportions based on cell copy numbers / ml. 

DNA was extracted from two mock communities using a resin based genomic tip (G20) extraction protocol with an enzymatic lysis and moderate bead beating. RNA was degraded using RNAseA. DNA was precipitated using room temp propan-2-ol and spooled on to a glass rod, then dissolved in 100 ul of 1 x TE buffer at 4 degrees overnight. A 1:2 dilution of DNA was quantified on a Qubit 4 using the HS kit and a 1:5 dilution was visulised on a 1% agerose gel with the Quick-Load® 1 kb Extend DNA Ladder (0.5 - 48.5 kb reference).  


![alt text](https://github.com/RobSJames/EBAME6/blob/main/hmw%20mock.jpg)  
_Qiagen genomic tip extraction of HMW DNA from a mock metagenome_ 

Nanopore library preperation was undertaken using the NEB ultra II end prep and FFPE repair process followed by SPRI clean up and then the ligation sequencing kit (LSK109). DNA was eluted from SPRI beads using EB at 32 degrees C for 30 min.


![alt text](https://github.com/RobSJames/EBAME6/blob/main/hmw%20spri%20recovery%20AMX.jpg)  
_Library recovery from SPRI beads following Ultra II end prep and FFPE repair_ 

Sequencing was undertaken on a single flow cell position on the GridION platform. Basecalling was undertaken in real time using the Super High Accuracy base caller from guppy5. Sequencing progressed for 24 h. 

### Set up

The tools required to undertake this tutorial are supplied in the LongReads conda environment.

### Data 

Sequencing data is located:
~/data/public/teachdata/ebame/Quince-data-2021/Quince_datasets/Rob_data/

Kraken2 database is located:
~/data/public/teachdata/ebame/Quince-data-2021/minikraken2_v1_8GB

## Tutorial
### Basecalling
Nanopore sequencing results in fast5 files that contain raw signal data termed "squiggles". This signal needs to be processed into the `.fastq` format for onward analysis. This is undertaken through a process called 'basecalling'. The current program released for use by Oxford Nanopore is called `Guppy` and can be implemented in both GPU and CPU modes. Three forms of basecalling are available, 'fast', 'high-accuracy' (HAC) and 'super high accuracy' (SUP-HAC). The differing basecalling approaches can be undertaken directly during a sequencing run or in post by using CPU or GPU based clusters. HAC and SUP-HAC basecalling algorithms are highly computationally intensive and thus slower than the fast basecalling method. While devices such as the GridION and PromethION can basecall using these algorithms in real time due to their on-board GPU configuration, thus permitting adaptive sequencing (read-until), the MinION device relies on the computational power of the attached system on which it is running. Guppy basecaller is also able to demultiplex barcoded reads both in real time and in post processing.


## Need to activate LongReads environment
```
conda activate LongReads
```

It is important to store all data and outputs in directories contained within the mounted volume in `~/mydatalocal` to insure you do not run out of space on your VMs.

Get the fast5 reads into the `mydatalocal` dir on our VM:

```
cd ~/mydatalocal

mkdir LongReads

cd LongReads

cp ~/data/public/teachdata/ebame/Quince-data-2021/Quince_datasets/Rob_data/fast5_subset.tar.gz .

tar -xvzf fast5_subset.tar.gz

rm fast5_subset.tar.gz
```

|Flag / command            | Description               | 
| -------------------------|:-------------------------:| 
| `mkdir`                  |make a new directory       | 
| `cd`                     |change directory           |
| `cp`                     |copy                       |
| `tar`                    |tar and un-compress        |
| `-x`                     |un-compress archive        |
| `-v`                     |verbose progress           |
| `-z`                     |using gzip                 |
| `-f`                     |file name                  |
| `rm`                     |remove                     |



Compare the different basecalling methods on the subset of fast5 files. Only try fast and high quality, SUP-HAC is very slow on CPUs. Basecalling will not complete in the time available, examine the fastq.temp files produced. Config files must be specified or kit and flow cell can be specified without a config file.

```
Usage:

With config file:
  guppy_basecaller -r -i <input dir> -s <save path> -c <config file> [options]

Fast basecalling config file: dna_r9.4.1_450bps_fast.cfg
High accuracy config file:  dna_r9.4.1_450bps_hac.cfg

With flowcell and kit name:
  guppy_basecaller -i <input path> -s <save path> --flowcell <flowcell name>
    --kit <kit name>

List supported flowcells and kits:
  guppy_basecaller --print_workflows
 

```
Guppy can be run by specifiying kit and flowcell OR config file.

Try `guppy_basecaller -h` for help. 

Samples were sequenced with LSK-109 kit (ligation sequencing kit) with flow MIN 106 flowcell.

### Code Example
<details><summary>SPOILER: Click for basecalling code reveal</summary>
<p>

### Guppy fast basecalling

```
guppy_basecaller -r --input_path fast5_raw --save_path raw_fastq --min_qscore 7 --cpu_threads_per_caller 4 --num_callers 2 --config dna_r9.4.1_450bps_fast.cfg -q 10 
```
|Flag / command            | Description               | 
| -------------------------|:-------------------------:| 
| `guppy_basecaller`       |call guppy.                | 
| `-r`                     |recursive                  | 
| `-input_path`            |path/to/fast5/dir          |
| `--save_path`            |path/to/fastq/output/dir   |
| `--min_qscore`           |mean min quality score     |
| `-cpu_threads_per_caller`|cpu threads                |
| `-num_callers`           |parallisation              |
| `--config`               |Fast config file           |
| `-q 10`                  |10 reads per fastq file    |
  
### Guppy high accuracy basecalling
  
```
guppy_basecaller -r --input_path fast5_raw --save_path raw_fastq_HQ --config dna_r9.4.1_450bps_hac.cfg --min_qscore 7 --cpu_threads_per_caller 4 --num_callers 2 -q 10 
```
|Flag / command            | Description               | 
| -------------------------|:-------------------------:| 
| `--config`               |High accuracy config file  |
  
  
</p>
</details>


When working with post processing basecalling it is usefull to use the `screen` command. This allows you to run the command in the background by detaching from the current process. To detach from a screen, us `ctrl + A D`. To resume a screen, use the command `screen -r`. To close a screen use `exit` within the screen environment. `conda init` may be required to run `conda LongReads` in screen for the first use.

(optional) Once detached from a screen running 'guppy_basecaller', you can count the total number of reads being written in real time by changing to the `pass` directory in the raw_fastq dir where the fastq files are being written and implementing the following bash one-liner. Use `Ctr c` to exit `watch`.

```
watch -n 5 'find . -name "*.fastq.temp" -exec grep 'read=' -c {} \; | paste -sd+ | bc'
```

Cancel the Guppy_basecaller command before continuing.

### Observations

How do the base calling methods compare?  

## Remove raw fast5 files from Longreads/ before continuing. 

```
rm -r fast5_raw 

```

## Read preparation

Before starting any analysis, it is often advised to check the number of reads and quality of your run. You can start by using a simple bash one liner to count all reads in `pass/`.

Count the number of fastq reads in the Guppy pass dir.

### Code Example
<details><summary>SPOILER: Click for read counting code reveal </summary>
<p>

```
cat pass/*.fastq.temp | grep 'read=' - -c
```
|Flag                         | Description                                                            | 
| ----------------------------|:----------------------------------------------------------------------:| 
| `cat`                       |display content                                                         | 
| `pass/*.fastq`              |of all files in `pass` dir ending in .fastq                             | 
| `\|`                        |pipe output of cat to grep                                              |
| `grep`                      |call grep search                                                        |
| `"read="`                   |look for lines with the unique pattern "read=" in header                |
| `-`                         |target the output from `cat`                                            |
| `-c`                        |count                                                                   |

or

```
echo $(cat pass/*.fastq.temp | wc -l)/4|bc
  or
cat pass/*.fastq.temp | echo $(wc -l)/4 | bc
```

|Flag                         | Description                                                            | 
| ----------------------------|:----------------------------------------------------------------------:| 
| `echo`                      |write to standard output (the screen)                                   | 
| `$(cat pass/*.fastq.temp`   |of all files in `pass` dir ending in .fastq.temp                        | 
| `\|`                        |pipe output of cat to wc                                                |
| `wc`                        |word count.                                                             |
| `-l`.                       |lines                                                                   |
| `/4`                        |devide number of lines by 4 (4 lines per fastq read)                    |
| `bc`                        |output via basic calculator                                             |

</details>


Due to the time constraints with basecalling, we have prepared a set of down sampled fastq files for onward analysis. These reads have been pre basecalled using the super high accuracy basecaller using `Guppy5`.

Copy one of the two GutMock fastq files into the LongReads dir and decompress:

```
cd LongReads

cp  ~/data/public/teachdata/ebame/Quince-data-2021/Quince_datasets/Rob_data/GutMock1.fastq.gz .

gzip -d GutMock1.fastq.gz

```

Count the reads in the two fastq files using grep or wc as before. Use the command `more GutMock1.fastq` to familiarize yourself with nanopore fastq format.

### Read down sampling

A number of programs are available to down-sample reads for onward analysis. A commonly used tool to downsample reads is [Filtlong](https://github.com/rrwick/Filtlong/blob/main/README.md). 

Try and resample 10000000 bp  no shorter than 1000bp using Filtlong with a mean quality score of 10. Filtlong outputs to STDOUT by default. Use `>` to redirect output to a file.


### Code Example
<details><summary>SPOILER: Click for read down-sample code reveal </summary>
<p>
  

### FiltLong

Filtlong allows greater control over read length and average read quality weightings.

```

filtlong -t 10000000 --min_length 1000 --length_weight 3  --min_mean_q 10 GutMock1.fastq > GutMock1_reads_downsample_FL.fastq
  
```

|Flag                         | Description                                                            | 
| ----------------------------|:----------------------------------------------------------------------:| 
| `-t`                        |target bp                                                               | 
| `-min_length`               |minimum read length                                                     | 
| `--length_weight 3`         |weighting towards read length                                           |
| `--min_mean_q 10`           |minimum mean read q score                                               |



</details>

### Observations
Examen the number of reads in each file and use seqkit to generate simple discriptive statistics for your read files. 

[Seqkit stats](https://bioinf.shenwei.me/seqkit/usage/#stats) can also be used to generate simple statistics for fasta/q files.

For reference, [Poretools](https://poretools.readthedocs.io/en/latest/content/examples.html) can be used to examine read length distribution and associated statistics but is not provided today. 


## Fixing broken fastq files with Seqkit sana

Sometimes errors can occur when preparing a `.fastq` file for analysis. This can cause problems in down-stream processing. [Seqkit](https://github.com/shenwei356/seqkit) `sana` is designed to help identify errors and salvage broken `.fastq` files.

```
seqkit sana  GutMock1.fastq -o rescued_GutMock1.fastq

```

## Read based taxonomic identification using Kraken2.

Kraken2 provide a means to rapidly assign taxonomic identification to reads using a k-mer based indexing against a reference database. We provide a small reference database compiled for this workshop. (ftp://ftp.ccb.jhu.edu/pub/data/kraken2_dbs/minikraken2_v2_8GB_201904_UPDATE.tgz) Other databases such as the Loman labs [microbial-fat-free](https://lomanlab.github.io/mockcommunity/mc_databases.html) and [maxikraken](https://lomanlab.github.io/mockcommunity/mc_databases.html) are also available. Two major limitations of Kraken2 is the completeness of the database approach and the inability to accuratly derrive and estimate species abundance. Tools such as [Bracken](https://github.com/jenniferlu717/Bracken) have been developed to more accuratly estimate species abundance from kraken.

### Optional extra information

Custom reference databases can be created using `kraken2-build --download-library`, `--download-taxonomy` and `--build` [commands](https://ccb.jhu.edu/software/kraken2/index.shtml?t=manual#custom-databases). Mick Wattson has written [Perl scripts](https://github.com/mw55309/Kraken_db_install_scripts) to aid in customisation. An example of the creation of custom databases by the Loman lab can be found [here](http://porecamp.github.io/2017/metagenomics.html).

Run [kraken2](https://github.com/DerrickWood/kraken2/wiki/Manual) on one of the two `GutMock1.fastq` files provided in this tutorial using the minikraken2_v1_8GB database. 

Kraken2 database is located: ~/data/public/teachdata/ebame/Quince-data-2021/minikraken2_v1_8GB/

Kraken2 requires an `--output` flag to redirect output from STDOUT.


## Code Example
<details><summary>SPOILER: Click for Kraken2 code </summary>
<p>

```
  
kraken2 --db ~/data/public/teachdata/ebame/Quince-data-2021/minikraken2_v1_8GB/ --threads 8 --use-names --report kraken_report --output kraken_gut GutMock1.fastq 

```

|Flag                         | Description                                                            | 
| ----------------------------|:----------------------------------------------------------------------:| 
| `kraken2`                   |call kraken2                                                            | 
| `--db`                      |database name flag                                                      | 
| `--threads`                 |number of threads to use                                                |
| `--report`                  |generate a user friendly report.txt of taxonomy                         |
| `GutMock1.fastq`            |reads                                                                   |


</details>

Examine the Kraken report using the `more` function.

```
more kraken_report 

```

### Observations

Is there anything odd in the sample?  
Why do you think this has had false positives hits in the kraken2 databases? 

You may wish to try running kraken2 again later using a larger or more specific database and see how your database can affect your results. 

### Krona read based visualization

Krona produces an interactive `.html` file based on your `--report` file. While not fully integrated with kraken2, the use of the report file gives an overall approximation of your sample diversity based on individual reads. 

Need to update taxonomy first, this should take 3-5 min:

```
cd /var/lib/miniconda3/envs/LongReads/opt/krona
./updateTaxonomy.sh

```

```
cd ~/data/mydatalocal/LongReads

ktImportTaxonomy -q 1 -t 5 kraken_report -o kraken_krona_report.html

```

|Flag                         | Description                                                            | 
| ----------------------------|:----------------------------------------------------------------------:| 
| `ktImportTaxonomy`          |call  KronaTools Import taxonomy                                        | 
| `q 1 -t 5`                  |for compatibility with kraken2 output abundance and taxa ID             | 
| `report.txt.`               |Kraken2 report.txt file                                                 |
| `-o`                        |HTML output                                                             |


Copy the html files to your local machine and open in your preferred browser (tested in firefox). To do this, open a new terminal on your machine and use the following command. Replace VMIPADDRESS with your own VM IP.

```
scp ubuntu@VMIPADDRESS:~/data/mydatalocal/LongReads/kraken_krona_report.html Desktop/

```

An example Krona output:  
![alt text](https://github.com/RobSJames/EBAME6/blob/main/Raw_read_kraken.png "Raw read krona report") 

## Pavian
[Pavian](https://github.com/fbreitwieser/pavian) is an R based program that is useful to produce Sankey plots and much more. Detailed instruction to run Pavian on your local machine are included at the end of this tutorial, however an online interface is also available at https://fbreitwieser.shinyapps.io/pavian/.

Use `scp` to copy your Kraken2 report file to your local machine and upload your kraken report to Pavian, then explore the tabs available.

![alt text](https://github.com/RobSJames/EBAME6/blob/main/Pavian_gut.png "Raw read sansky plot")

## Assembly and taxonomic classification via minimap2/miniasm and Kraken2

### Minimap2  

[Minimap2](https://github.com/lh3/minimap2) is a program that has been developed to deal with mapping long and noisy raw nanopore reads. Two modes are used in the following assembly, `minimap2 -x ava-ont` and `minimap2 -x map-ont`. The former performs an exhaustive "All v ALL" pairwise alignments on the read sets to find and map overlaps between reads. The latter maps long noisy read to a reference sequence. Minimap2 was developed to replace BWA for mapping long noisy reads from both nanopore and Pac-Bio sequencing runs. 

Undertake an all v all alignment using minimap2.

### Code Example
<details><summary>SPOILER: Click for Minimap2 code </summary>
<p>


```
minimap2 -x ava-ont -t 8 GutMock1.fastq GutMock1.fastq | gzip -1 > GutMock1.paf.gz

```
  

|Flag                         | Description                                                            | 
| ----------------------------|:----------------------------------------------------------------------:| 
| `minimap2`                  |call minimap2                                                           | 
| `-x`.                       |choose pre-tuned conditions flag                                        | 
| `ava-ont`                   |All v All nanopore error pre-set                                       |
| `-t`                        |number of threads                                                       |
| `GutMock1.fastq`            |reads in                                                                  |

  
Note: The output of this file is piped to gzip for a compressed pairwise alignment format (.paf.gz). 
  
</details>

### Miniasm  

[Miniasm](https://github.com/lh3/miniasm) is then used to perform an assembly using the identified overlaps in the `.paf` file. No error correction is undertaken thus the assembled contigs will have the approximate error structure of raw reads.

<details><summary>SPOILER: Click for Miniasm code </summary>
<p>
  
```
miniasm -f GutMock1.fastq GutMock1.paf.gz > GutMock1.contigs.gfa

```
</details>  

Miniasm produces a graphical fragment assembly (`.gfa`) file containing assembled contigs and contig overlaps. This file type can be viewed in the program `bandage` to give a visual representation of a metagenome. However, due to the error associated with this approach, read polishing can be undertaken to increase sequence accuracy. Contigs can be extracted from a `.gfa` file and stored in a `.fasta` format using the following awk command.

```

awk '/^S/{print ">"$2"\n"$3}' GutMock1.contigs.gfa | fold > GutMock1.contigs.fasta

```

## Kraken2 contig identification

kraken2 can be run on the assembled contigs in the same way as before using the contigs as input.

### Observations

What has happened to the number of taxa in the kraken2 report?   


## Flye assembly 

The assemblers [Flye](https://github.com/fenderglass/Flye) and [Canu](https://github.com/marbl/canu) are available to perform assemblies which include error correction steps. Canu was primarily designed to assemble whole genomes from sequenced isolates and is more computationally intensive that Flye. Flye has a --meta flag with designed parameters to assemble long read metagenomes. Here we will run Flye on our raw reads, you will need to down sample your reads for flye to complete an assembly within the time constraints of this tutorial.

```

flye --nano-hq GutMock1.fastq --meta -o flye_workshop/ -t 8

```

|Flag                         | Description                                                            | 
| ----------------------------|:----------------------------------------------------------------------:| 
| `flye`                      |call  Flye                                                              | 
| `--nano-hq`                 |using nanopore high quality raw reads as input                          | 
| `-o`                        |output dir                                                              |
| `-t`                        |number of threads                                                       |
| `--meta`                    |metagenome assembly rules                                               |


Undertake a kraken2 report with the assembled contigs as before

### Observations

How does the fly assembly differ from the minimap2/miniasm assembly?  
How does it differ from the raw read Kraken2 report? 

## Summary

Long read sequencing provides a means to assemble metagenomes. Due to the length of reads, assemblies of larger complete contigs are possible relative to short, high accuracy reads. This often permits a greater understanding of community composition, genetic diversity as well as a greater resolution of the genetic context of genes of interest. Assembly and polishing reduces the false positive hit rates in a database classification approach.

## Real gut microbiome dataset

You are now able to use the real human gut microbiome sample to udertake some of this tutorial at your own pace. The data set will be available for the remainder of the workshop. This data set is much more complex than the data sets provided today and has been downsampled for convenience. The data set is located in: ~/data/public/teachdata/ebame/Quince-data-2021/Quince_datasets/Rob_data/real_gutDS.gz


## Extra visualisations using sansky plots in Pavian and polishing with Racon

<details><summary>SPOILER: Click for visualisation examples </summary>
<p>

### Pavian  

[Pavian](https://github.com/fbreitwieser/pavian) is an R based program that is useful to produce Sankey plots and much more. It can be run on your local machine if you have R [installed](https://a-little-book-of-r-for-bioinformatics.readthedocs.io/en/latest/src/installr.html) or can be run online at https://fbreitwieser.shinyapps.io/pavian/. Upload your kraken2 reports to interact with them.
  
You may need to install `r-base-dev` To set up Pavian in R on your local machine, open an R terminal and enter the following.  

```
sudo R

>if (!require(remotes)) { install.packages("remotes") }
>remotes::install_github("fbreitwieser/pavian")

```

To run Pavian enter into R terminal:  

```

>pavian::runApp(port=5000)

```
You can now access Pavian at http://127.0.0.1:5000 in a web browser if it does not load automatically.  

Alternatively a shiny route is available.

```

shiny::runGitHub("fbreitwieser/pavian", subdir = "inst/shinyapp")

```

You should now be presented with a user interface to which you can browse for your report files on your local machine.  

![alt text](https://github.com/BadgerRob/Staging/blob/master/pavin_snap.png "Pavian input")

Once you have loaded your file, navigate to the "sample" tab and try interacting with the plot. This is an example of an assembled metagenome from a lambic style beer:  

![alt text](https://github.com/BadgerRob/Staging/blob/master/kraken.png)
  
## Polishing with racon

Polishing a sequence refers to the process of identifying and correcting errors in a sequence based on a consensus or raw reads. Some methods use raw signal data from the fast5 files to aid in the identification and correction. A number of polishing programs are in circulation which include the gold standard [Nanopolish](https://github.com/jts/nanopolish), the ONT release [Medaka](https://github.com/nanoporetech/medaka) and the ultra-fast [Racon](https://github.com/isovic/racon). Each approach has advantages and disadvantages to their use. Nanopolish is computationally intensive but uses raw signal data contained in fast5 files to aid error correction. This also relies on the retention of the large `.fast5` files from a sequencing run. Medaka is reliable and relatively fast and racon is ultra fast but does not use raw squiggle data.  

The first step in polishing an assembly with Racon is to remap the raw reads back to the assembled contigs. This is done using `minimap2 -x map-ont`.  

```
minimap2 [options] <target.fa>|<target.idx> [query.fa] [...]


minimap2 -t 8 -ax map-ont GutMock1.contigs.fasta GutMock1.fastq > GutMock1_reads_to_polish.sam

```

[Racon](https://github.com/isovic/racon) is then used to polish the assembled contigs using the mapped raw reads. 

```
usage: racon [options ...] <sequences> <overlaps> <target sequences>

racon -t 8 GutMock1.fastq GutMock1_reads_to_polish.sam GutMock1.contigs.fasta > GutMock1.contigs.racon.fasta

```

</details>
