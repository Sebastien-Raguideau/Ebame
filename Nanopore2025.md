# EBAME 10 2025: Long read metagenomics sequencing workshop

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
/ifb/data/public/teachdata/ebame/metagenomics-QR/fast5_subset.tar.gz


## Tutorial
### Basecalling
Nanopore sequencing results in fast5/pod5 files that contain raw signal data termed "squiggles". This signal needs to be processed into the `.fastq` format for onward analysis. This is undertaken through a process called 'basecalling'. The current program released for use by Oxford Nanopore is called `Dorado` (formally Guppy) and can be implemented in both GPU and CPU modes. Three forms of basecalling are available, 'fast', 'high-accuracy' (HAC) and 'super high accuracy' (SUP-HAC). The differing basecalling approaches can be undertaken directly during a sequencing run or in post by using CPU or GPU based clusters. HAC and SUP basecalling algorithms are highly computationally intensive and thus slower than the fast basecalling method. While devices such as the GridION and PromethION can basecall using these algorithms in real time due to their on-board GPU configuration, thus permitting adaptive sequencing (read-until), the MinION device relies on the computational power of the attached system on which it is running. `Dorado demux` is also able to demultiplex barcoded reads both in real time and in post processing.


## Need to activate LongReads environment
```
conda activate LongReads
export DATA=/ifb/data/public/teachdata/ebame/metagenomics-QR/
```
Navigate to repos/Ebame and pull the most recent repo via

```
git pull
```

Check $DATA points at:
```
/ifb/data/public/teachdata/ebame/metagenomics-QR/
```

It is important to store all data and outputs in directories contained within the mounted volume in `~/Projects` to insure you do not run out of space on your VMs.

Get the pod5/fast5 reads into the `Projects` dir on our VM:

```
mkdir -p ~/Projects/LongReads
cd ~/Projects/LongReads

cp $DATA/fast5_subset.tar.gz .
cp ~/repos/Ebame/tmp/preruns/datasets/pod5_downsample.pod5 .
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



Compare the different basecalling methods (Dorado fast, hac and sup and/or Guppy - depreciated) on the subset of pod5/fast5 files. SUP is very slow on CPUs. Basecalling will not complete in the time available, examine the fastq files produced using more or head. `Dorado basecaller` can also be used to call modified base probibilites, currently 4mC, 5mC and 6mA are supported for bacterial epigenetic modifications. Dorado basecaller can demultiplex during basecalling or in post by using dorado demux. Further information can be found on the github page : [https://github.com/nanoporetech/dorado](https://github.com/nanoporetech/dorado)

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

 

```

### Dorado basecalling output in fastq (sup V.5 transformer model - very slow 

Try running the with the sup setting, use the option to create fastq!

<details><summary>SPOILER: search first please :)</summary>
<p>

```bash
dorado basecaller sup --emit-fastq --min-qscore 10 path/to/pod5s > path/to/output.fastq
```

|Flag / command            | Description               | 
| -------------------------|:-------------------------:| 
| `dorado`                 |call dorado                | 
| `basecaller`             |call basecaller            | 
| `--emit-fastq`           |fastq output               |
| `--min-qscore`           |minimum qscore filter      |

</details>

### Dorado modified basecalling (unaligned bam file output)

Try running the with the hac setting and metylation calling

<details><summary>SPOILER: search first please :) </summary>
<p>

```bash
dorado basecaller --min-qscore 10 hac,6mA pod5_downsample.pod5 > calls.bam
```

|Flag / command            | Description               | 
| -------------------------|:-------------------------:| 
| `dorado`                 |call dorado                | 
| `basecaller`             |call basecaller            | 
| `hac`                    |high accuracy              |
| `--min-qscore`           |minimum qscore filter      |
| `6mA`                    |modified bases flag        |

 
View bam file structure with modified bases.

```
samtools view calls.bam | head
```
Modified bases can be further processed with MODKIT. Additional information on SAM tags cab be found in the samtools [documentation] (https://samtools.github.io/hts-specs/SAMtags.pdf)for MM and ML tags.

</details>

## Remove raw fast5 files from Longreads/ before continuing. 

## Read preparation

Before starting any analysis, it is often advised to check the number of reads and quality of your run. 
```
echo $(cat *.fastq | wc -l)/4|bc
  or
cat *.fastq | echo $(wc -l)/4 | bc
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



