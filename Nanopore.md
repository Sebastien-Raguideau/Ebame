# EBAME 9 2024: Long read metagenomics sequencing workshop

## Long read metagenomics of the human gut microbiome


### Introduction
Today we aim to use real, nanopore derived, long read sequence data to examine the community composition of two mock communities constructed of representative members of the human gut microbiome. The tutorial is designed to act as a reference for processing long reads from raw fast5/pod5 files to an assembled and taxonomically classified metagenome. While example codes for each step are provided, they are only available when revealed by clicking on the drop-down menus. This affords you the opportunity to try and implement code from the linked help pages and manuals of the tools being used. It is important to note that many other metagenomic tools and pipelines are available to assemble and undertake taxonomic classification and can be implemented depending on your sample, aim, time and available computational power.

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
/home/ubuntu/data/public/teachdata/ebame-2022/metagenomics/Quince_datasets/Rob_data/

Kraken2 database is located:
/home/ubuntu/data/public/kraken2/k2_standard_08gb_20220926

## Tutorial
### Basecalling
Nanopore sequencing results in fast5/pod5 files that contain raw signal data termed "squiggles". This signal needs to be processed into the `.fastq` format for onward analysis. This is undertaken through a process called 'basecalling'. The current program released for use by Oxford Nanopore is called `Dorado` (formally Guppy) and can be implemented in both GPU and CPU modes. Three forms of basecalling are available, 'fast', 'high-accuracy' (HAC) and 'super high accuracy' (SUP-HAC). The differing basecalling approaches can be undertaken directly during a sequencing run or in post by using CPU or GPU based clusters. HAC and SUP basecalling algorithms are highly computationally intensive and thus slower than the fast basecalling method. While devices such as the GridION and PromethION can basecall using these algorithms in real time due to their on-board GPU configuration, thus permitting adaptive sequencing (read-until), the MinION device relies on the computational power of the attached system on which it is running. `Dorado demux` is also able to demultiplex barcoded reads both in real time and in post processing.


## Need to activate LongReads environment
```
conda activate LongReads
```

It is important to store all data and outputs in directories contained within the mounted volume in `~/Projects` to insure you do not run out of space on your VMs.

Get the pod5/fast5 reads into the `Projects` dir on our VM:

```
mkdir -p ~/Projects/LongReads
cd ~/Projects/LongReads

cp $DATA/Rob_data/fast5_subset.tar.gz .
cp $DATA/Rob_data/pod5_subset.tar.gz .
tar -xvzf fast5_subset.tar.gz
tar -xvzf pod5_subset.tar.gz
rm pod5_subset.tar.gz
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



Compare the different basecalling methods on the subset of pod5/fast5 files. Only try fast and high quality as SUP is very slow on CPUs. Basecalling will not complete in the time available, examine the fastq.temp files produced. Config files must be specified or kit and flow cell can be specified without a config file. `Dorado basecaller` can also be used to call modified base probibilites, currently 4mC, 5mC and 6mA are supported for bacterial epigenetic modifications. Dorado basecaller can demultiplex during basecalling or in post by using dorado demux. Further information can be found on the github page : [https://github.com/nanoporetech/dorado](https://github.com/nanoporetech/dorado)

NB: When using dorado basecaller, it is possable to resume an interupted run by using the '--resume-from' flag.


```bash
Dorado Usage:

dorado [-h] [--device VAR] [--read-ids VAR] [--resume-from VAR] [--max-reads VAR] [--min-qscore VAR] [--batchsize VAR] [--chunksize VAR] [--overlap VAR] [--recursive] [--modified-bases VAR...] [--modified-bases-models VAR] [--modified-bases-threshold VAR] [--emit-fastq] [--emit-sam] [--emit-moves] [--reference VAR] [--kit-name VAR] [--barcode-both-ends] [--no-trim] [--trim VAR] [--sample-sheet VAR] [--barcode-arrangement VAR] [--barcode-sequences VAR] [--primer-sequences VAR] [--estimate-poly-a] [--poly-a-config VAR] [-k VAR] [-w VAR] [-I VAR] [--secondary VAR] [-N VAR] [-Y] [--bandwidth VAR] [--junc-bed VAR] [--mm2-preset VAR] model data

Positional arguments:
  model                     	model selection {fast,hac,sup}@v{version} for automatic model selection including modbases, or path to existing model directory
  data                      	the data directory or file (POD5/FAST5 format).

Optional arguments:
  -h, --help                	shows help message and exits
  -v, --verbose
  -x, --device              	device string in format "cuda:0,...,N", "cuda:all", "metal", "cpu" etc.. [default: "cuda:all"]
  -l, --read-ids            	A file with a newline-delimited list of reads to basecall. If not provided, all reads will be basecalled [default: ""]
  --resume-from             	Resume basecalling from the given HTS file. Fully written read records are not processed again. [default: ""]
  -n, --max-reads           	[default: 0]
  --min-qscore              	Discard reads with mean Q-score below this threshold. [default: 0]
  -b, --batchsize           	if 0 an optimal batchsize will be selected. batchsizes are rounded to the closest multiple of 64. [default: 0]
  -c, --chunksize           	[default: 10000]
  -o, --overlap             	[default: 500]
  -r, --recursive           	Recursively scan through directories to load FAST5 and POD5 files
  --modified-bases          	[nargs: 1 or more]
  --modified-bases-models   	a comma separated list of modified base models [default: ""]
  --modified-bases-threshold	the minimum predicted methylation probability for a modified base to be emitted in an all-context model, [0, 1] [default: 0.05]
  --emit-fastq              	Output in fastq format.
  --emit-sam                	Output in SAM format.
  --reference               	Path to reference for alignment. [default: ""]
  --kit-name                	Enable barcoding with the provided kit name. Choose from: EXP-NBD103 EXP-NBD104 EXP-NBD114 EXP-NBD196 EXP-PBC001 EXP-PBC096 SQK-16S024 SQK-16S114-24 SQK-LWB001 SQK-MLK111-96-XL SQK-MLK114-96-XL SQK-NBD111-24 SQK-NBD111-96 SQK-NBD114-24 SQK-NBD114-96 SQK-PBK004 SQK-PCB109 SQK-PCB110 SQK-PCB111-24 SQK-PCB114-24 SQK-RAB201 SQK-RAB204 SQK-RBK001 SQK-RBK004 SQK-RBK110-96 SQK-RBK111-24 SQK-RBK111-96 SQK-RBK114-24 SQK-RBK114-96 SQK-RLB001 SQK-RPB004 SQK-RPB114-24 TWIST-16-UDI TWIST-96A-UDI VSK-PTC001 VSK-VMK001 VSK-VMK004 VSK-VPS001. [default: ""]
  --barcode-both-ends       	Require both ends of a read to be barcoded for a double ended barcode.
  --no-trim                 	Skip trimming of barcodes, adapters, and primers. If option is not chosen, trimming of all three is enabled.
  --trim                    	Specify what to trim. Options are 'none', 'all', 'adapters', and 'primers'. Default behaviour is to trim all detected adapters, primers, or barcodes. Choose 'adapters' to just trim adapters. The 'primers' choice will trim adapters and primers, but not barcodes. The 'none' choice is equivelent to using --no-trim. Note that this only applies to DNA. RNA adapters are always trimmed. [default: ""]
  --sample-sheet            	Path to the sample sheet to use. [default: ""]
  --barcode-arrangement     	Path to file with custom barcode arrangement.
  --barcode-sequences       	Path to file with custom barcode sequences.
  --primer-sequences        	Path to file with custom primer sequences. [default: <not representable>]
  --estimate-poly-a         	Estimate poly-A/T tail lengths (beta feature). Primarily meant for cDNA and dRNA use cases.
  --poly-a-config           	Configuration file for PolyA estimation to change default behaviours [default: ""]
  -k                        	minimap2 k-mer size for alignment (maximum 28).
  -w                        	minimap2 minimizer window size for alignment.
  -I                        	minimap2 index batch size.
  --secondary               	minimap2 outputs secondary alignments
  -N                        	minimap2 retains at most INT secondary alignments
  -Y                        	minimap2 uses soft clipping for supplementary alignments
  --bandwidth               	minimap2 chaining/alignment bandwidth and optionally long-join bandwidth specified as NUM,[NUM]
  --junc-bed                	Optional file with gene annotations in the BED12 format (aka 12-column BED), or intron positions in 5-column BED. With this option, minimap2 prefers splicing in annotations.
  --mm2-preset              	minimap2 preset for indexing and mapping. Alias for the -x option in minimap2. [default: "lr:hq"]

Guppy Usage:

# With config file:
guppy_basecaller -r -i <input dir> -s <save path> -c <config file> [options]

#Fast basecalling config file: 
dna_r9.4.1_450bps_fast.cfg
#High accuracy config file:  
dna_r9.4.1_450bps_hac.cfg

#With flowcell and kit name:
guppy_basecaller -i <input path> -s <save path> --flowcell <flowcell name>
    --kit <kit name>

#List supported flowcells and kits:
guppy_basecaller --print_workflows
 

```
Guppy can be run by specifiying kit and flowcell OR config file.

NB: Try `guppy_basecaller -h` for help. 

Samples for guppy basecalling were sequenced with **LSK-109 kit** (ligation sequencing kit) with **flow MIN 106** flowcell.

### Code Example
<details><summary>SPOILER: Click for basecalling code reveal</summary>
<p>

### Dorado basecalling output in fastq (sup V.5 transformer model - very slow)

dorado basecaller --emit-fastq --min-qscore 10 -r path/to/model/dna_r10.4.1_e8.2_400bps_sup\@v5.0.0/ path/to/pod5s > path/to/output.fastq

|Flag / command            | Description               | 
| -------------------------|:-------------------------:| 
| `dorado`                 |call dorado                | 
| `basecaller`             |call basecaller            | 
| `--emit-fastq`           |fastq output               |
| `--min-qscore`           |minimum qscore filter      |

### Dorado modified basecalling (unaligned bam file output)

dorado basecaller --min-qscore 10 -r --modified-bases-models path/to/modfile1/dna_r10.4.1_e8.2_400bps_sup\@v5.0.0_4mC_5mC\@v1/,path/to/modfile2/dna_r10.4.1_e8.2_400bps_sup\@v5.0.0_6mA\@v1/ path/to/basecallingmodel/dna_r10.4.1_e8.2_400bps_sup\@v5.0.0/ path/to/pod5s > path/to/output/dir/out.bam

|Flag / command            | Description               | 
| -------------------------|:-------------------------:| 
| `dorado`                 |call dorado                | 
| `basecaller`             |call basecaller            | 
| `-r`                     |recursive flag             |
| `--min-qscore`           |minimum qscore filter      |
| `--modified-bases-models`|modified bases flag        |

 
View bam file structure with modified bases
```
samtools view output_file.bam | head
```


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


When working with post processing basecalling it is usefull to use the `screen` command. This allows you to run the command in the background by detaching from the current process (TMUX also available). To detach from a screen, us `ctrl + A D`. To resume a screen, use the command `screen -r`. To close a screen use `exit` within the screen environment. `conda init` may be required to run `conda LongReads` in screen for the first use.

(optional) Once detached from a screen running 'guppy_basecaller', you can count the total number of reads being written in real time by changing to the `pass` directory in the raw_fastq dir where the fastq files are being written and implementing the following bash one-liner. Use `Ctr c` to exit `watch`.

```
watch -n 5 'find . -name "*.fastq.temp" -exec grep 'read=' -c {} \; | paste -sd+ | bc'
```

Cancel the Guppy_basecaller and / or dorado basecaller commands in screen before continuing with this tutorial.

### Observations

How do the base calling methods compare in terms of speed?   

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

cd ~/Projects/LongReads

cp  $DATA/Rob_data/GutMock1.fastq.gz .

gzip -d GutMock1.fastq.gz

```

Count the reads in the two fastq files using grep or wc as before. Use the command `more GutMock1.fastq` to familiarize yourself with nanopore fastq format.

### Read down sampling

A number of programs are available to down-sample reads for onward analysis. Commonly used tool to downsample reads is [Filtlong](https://github.com/rrwick/Filtlong/blob/main/README.md) and to QC is [seqkit](https://bioinf.shenwei.me/seqkit/) . 

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


### Seqkit statistics

```
seqkit stats <infile> -a
```

### Seqkit seq

seqkit seq -m 1000 <infile> > <outfile>

</details>

### Observations
Examen the number of reads in each file and use seqkit to generate simple discriptive statistics for your read files. 

[Seqkit stats](https://bioinf.shenwei.me/seqkit/usage/#stats) can also be used to generate simple statistics for fasta/q files.

```
seqkit stats 

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

Kraken2 database is located: 
/home/ubuntu/data/public/kraken2/k2_standard_08gb_20220926


Kraken2 requires an `--output` flag to redirect output from STDOUT.


## Code Example
<details><summary>SPOILER: Click for Kraken2 code </summary>
<p>

```
export KDBPATH=/home/ubuntu/data/public/kraken2/k2_standard_08gb_20220926  
kraken2 --db $KDBPATH --threads 8 --use-names --report kraken_report --output kraken_gut GutMock1.fastq 

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

```
cd ~/Projects/LongReads

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
scp ubuntu@VMIPADDRESS:~/Projects/LongReads/kraken_krona_report.html .

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
