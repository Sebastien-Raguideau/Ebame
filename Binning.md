# Manual versus automatic metagenomic workflow.

The aim of this tutorial is to go from paired reads to Mags placed in a phylogenetic tree, at first using command line and in a second time using a workflow management system, that is [snakemake](https://snakemake.readthedocs.io/en/stable/). 

The workflow is quite typical and involve

1. [Coassembly](#coassembly)

2. [Read mapping](#readmapping)

3. [Contig binning](#binning)

4. [Bin quality ](#checkm)
5. [Phylogenetic tree placement](#gtedb)
 


We are now going to perform a basic assembly based metagenomics analysis of these same samples. 
This will involve a collection of different software programs:

1. [megahit](https://github.com/voutcn/megahit): A highly efficient metagenomics assembler currently our default for most studies

2. [bwa](http://bio-bwa.sourceforge.net/bwa.shtml): Necessary for mapping reads onto contigs

3. [samtools](http://www.htslib.org/download/): Utilities for processing mapped files

4. [Metabat2](https://github.com/BinPro/CONCOCT): an automatic binning algorithm
5. [checkm](https://ecogenomics.github.io/CheckM/#:~:text=CheckM%20provides%20a%20set%20of,copy%20within%20a%20phylogenetic%20lineage.): Tools to assess bin quality
6. [gtdb-tk](https://github.com/Ecogenomics/GTDBTk): Toolkit to place MAG on reference phylogenetic tree and use placement for taxonomy classification. 



<a name="coassembly"/>

## Getting started (VM, ssh & env)

For this tutorial we will use a VM with 8-core 32G ram (take this configuration M4.2XL 32G RAM 8CPU) from the appliance [EBAME-Quince](https://biosphere.france-bioinformatique.fr/catalogue/appliance/127/)

**Please be  sure to use the ifb-core-cloudbis domain when launching** 



Please ssh to your vm using the -Y option so that X forwarding can be done. 

    ssh -Y ubuntu@xxx.xxx.xxx.xxx 

#### Conda Envs
We use a [conda](https://docs.conda.io/projects/conda/en/4.6.0/_downloads/52a95608c49671267e40c689e0bc00ca/conda-cheatsheet.pdf) env to install all dependencies, you don't need to install anything and all dependencies are available but only inside that environment.   

Try to check the command line help of megahit

    megahit -h
<details><summary>not working?</summary>
<p>
Conda environment are created as independant environment to everything else, you need to "activate" an environment to be able to access the sets of tools installed inside.

    conda env list
    conda activate STRONG
    megahit -h

</p>
</details>

## Quick terminal fix
.bashrc is a "hidden" file in your home directory. Any new terminal will first execute this script and set environment variable, alias and other general setting. 

For simplification sake, we are going to create a global variable:

Use nano to edit your bashrc file:
```bash
nano ~/.bashrc
export DATA=/ifb/data/public/teachdata/ebame/metagenomics-QR/
```

Also, each VM has been generated with a random name instead of the hostname which is a md5 string. You can alter it and rename your VM
:

    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@somename_you_would_rather_have\[\033[00m\]:\[\033[01;34m\]\w\[\033[>

To quit use `ctrl+x`  and type yes
# Manual bioinformatic
Let's create a Projects directory and work inside:

    mkdir -p Projects/AD_binning

## Assembly

All datasets for this tutorial can be found at: 

    ~/Datasets/metagenomics-QR

Or equivalently here:

    /ifb/data/public/teachdata/ebame/metagenomics-QR/
    

We have here different dataset subsampled so they can run in real time during the workshop.
We are going to use reads from the AD_small folder. They come from an industrial anaerobic digester study we realised but correspond to only a few MAGs.


We are going to use megahit for assembly. It is a fast memory efficient metagenomic assembler and particularly usefull for handling large coassembly.

Megahit is installed, reads are at 

    $DATA/AD_small

Bioinformatic is mostly about reading documentation, and looking on the internet how to do things. 
Use the -h flag on megahit and try to craft a command line to launch the assembly on 8 cores.

<details><summary>spoiler (click on me if you're desperate)</summary>
<p>

```bash
cd ~/Projects/AD_binning
ls $DATA/AD_small/*/*R1.fastq | grep -v Filtered | tr "\n" "," | sed 's/,$//' > R1.csv
ls $DATA/AD_small/*/*R2.fastq | grep -v Filtered | tr "\n" "," | sed 's/,$//' > R2.csv
megahit -1 $(<R1.csv) -2 $(<R2.csv) -t 8 -o Assembly
```
It should take about 782.40 seconds
</p>
</details>

What is the output of an assembler?
Why would you want to to assembly or coassembly?
How good is the assembly? 
How would we go for estimating the number of organisms in the assembly?
What do we do with an assembly?

<a name="readmapping"/>

## Read mapping

What informations can be used to bins contigs?

We use bwa mem to map reads to the assembly.
As preliminary step we need to index the assembly

```bash
cd ~/Projects/AD_binning/Assembly
bwa index final.contigs.fa
```

Then I want you to try mapping the reads from the first sample contigs using 'bwa mem' inside a subdirectory Map to 
produce a sam file 'Map/sample1.sam':

<details><summary>the correct command is:</summary>
<p>

```bash
cd ~/Projects/AD_binning
mkdir Map
bwa mem -t 4 Assembly/final.contigs.fa $DATA/AD_small/sample1/sample1_R1.fastq $DATA/AD_small/sample1/sample1_R2.fastq > Map/sample1.sam
```
</p>
</details>

You can look at the sam:
```
tail Map/sample1.sam
```

It is quite a complex [format](https://en.wikipedia.org/wiki/SAM_(file_format))

The sam file is a bit bulky so we never store alignments in this format instead we would convert it into bam. Can you convert this file using 
'samtools view':


<details><summary> Convert sam to bam command</summary>
<p>

```bash
cd ~/Projects/AD_binning/Map
samtools view -h -b -S sample1.sam > sample1.bam
```
</p>
</details>

Using samtool we can filter only those reads which are mapped to the assembly.
```bash
samtools view -b -F 4 sample1.bam > sample1.mapped.bam
```

For downstream analysis we needs the bam file to be sorted:
```
samtools sort sample1.mapped.bam -o sample1.mapped.sorted.bam 
```

To run all samples we would place these steps in a shell script:

```bash
cd ~/Projects/AD_binning

# please remove previous work, so to not cause issue with  
# downstream jgi_summarize_bam_contig_depths script
rm ~/Projects/AD_binning/Map/*

for file in $DATA/AD_small/*/*R1.fastq
do 
   
   stub=${file%_R1.fastq}
   name=${stub##*/}
   
   echo $name

   file2=${stub}_R2.fastq

   bwa mem -t 8 Assembly/final.contigs.fa $file $file2 | samtools view -b -F 4 - | samtools sort - > Map/$name.mapped.sorted.bam
done
```

<a name="binning"/>

## Contig binning

The first step is to derive coverage from bam files. For this we can use metabat2 script. It takes bam files as inpute produce a table of mean coverage depth and std for each contigs in each sample.

```bash
cd ~/Projects/AD_binning/Map
jgi_summarize_bam_contig_depths --outputDepth depth.txt *.bam
```

Make a new subfolder Binning. Move the Coverage file into this and look into crafting the metabat2 command line. Either use the help flag or a quick google search.

<details><summary> Solution</summary>
<p>

```bash
cd ~/Projects/AD_binning
mkdir Binning
mv Map/depth.txt Binning/depth.txt
metabat2 -i Assembly/final.contigs.fa -a Binning/depth.txt -t 4 -o Binning/Bins/Bin
```
</p>
</details>

How many contigs were clustered? 
```bash
grep -c ">" Binning/Bins/*.fa | awk -F: '{ s+=$2 } END { print s }'
```
How many nucleotide were clustered?
```bash
grep -v ">" Binning/Bins/*.fa | cut -f2 -d":" |wc -m
```
 
## Which bins are Metagenome assembled genomes (MAGs)?

A bin is a group of contigs put together from looking at coverage/composition. How do you assess bin quality?

Checkm is an handy automated pipeline which will use marker set specifics to bacteria/Archea to assess contamination/completion.
```bash
cd ~/Projects/AD_binning/Binning
checkm lineage_wf Bins/ checkm -x .fa -r
```

<details><summary>After launching checkm, are you having an issue?</summary>
<p>

Unfortunately the vm are a bit short on ram and pplacer, used by checkm to identify SCG taxonomy, is extremely ram greedy. 
Instead you will need to import output pre-generated for this tutorial. 

```bash
rm -r checkm
ln -s ~/repos/Ebame/checkm.out .
```
</p>
</details>

What does each column mean? 

## A better idea of MAG identity

When doing metagenomic, it happens often that the MAGs you obtain are not in database, or just distantly related to references. Using single copy core genes we can place these MAGs in a phylogenetic tree full with known species representatives. 
The gtdb toolkit does that for you:

```bash
GTDBTK_DATA_PATH=/ifb/data/public/teachdata/ebame/metagenomics-bining/gtdb/release220 # change the db path to the correct dir 
cd ~/Projects/AD_binning/Binning
mkdir -p gtdb/scratch
gtdbtk classify_wf --cpus 8 --genome_dir Bins --out_dir gtdb --extension .fa --scratch_dir gtdb/scratch --skip_ani_screen
```
That will take at least, 1h20 min, instead lets use the pre-processed results

```bash
cd ~/Projects/AD_binning/Binning
rm -r gtdb
ln -s /home/ubuntu/repos/Ebame/gtdb .
```

We obtain multiple files what are they?
Look at summary files what information can we obtain.
What is the RED, from gtdb?

![alt tag](https://github.com/Sebastien-Raguideau/Ebame/blob/master/Figures/gtdb.jpg)


# Workflow bioinformatic

## Snakemake

The Snakemake workflow management system is a tool to create **reproducible and scalable** data analyses. Workflows are described via a human readable, Python based language. They can be seamlessly scaled to server, cluster, grid and cloud environments, without the need to modify the workflow definition. Finally, Snakemake workflows can entail a description of required software, which will be automatically deployed to any execution environment.

Alternatives: 
 - [nextflow](https://www.nextflow.io/)
 - Common workflow language and it's implementations : [CWL](https://www.commonwl.org/#Implementations)

### Principle

The user define :

-   a set of rules, which are scripts/command line, encapsuled in a way snakemake can make sense of.
-   an expected results : a file or a list of files
-   an amount of ressources : number of cpu, memory

Snakemake then devise the succession of rules (script/command) needed to generate the output. If the results cannot be generated from the rules inputed and the files already present in the execution folder, snakemake will let you know and fail.

Snakemake will schedule rules execution optimising ressources allocations (threads/memory/custom ressource).

![alt tag](https://github.com/Sebastien-Raguideau/Ebame/blob/master/Figures/snakemake_rules.png)

### Features

-   It is possible to write and use python code inside snakemake
-   snakemake keep track of all files, input input in your workflow. If the input of a rule has been updated, snakemake will rerun all depending rules.
- If the rule has changed, it will rerun the rule and depending rules.
-   snakemake keep track of completion of tasks and can deal with unplanned interuption.
-   snakemake can be easily deployed to clusters without changing any code
-  It is possible to specify ad hoc environment for each step of the pipeline and have each step executed in it's own environment, singularity/conda
- benchmarking

## Hello world
The minimum rule is :

-   an input
-   an output
-   a shell command/or python code

Example :
```bash
rule Hello_world:
    input: "/home/ubuntu/requirement.txt"
    output: "/home/ubuntu/snakemake.txt"
    shell: "echo HELLO WORLD > {output}"
```

Write that command in a file for instance with nano.
```bash
mkdir -p ~/Projects/AD_snakemake
cd ~/Projects/AD_snakemake
nano hello.smk
```
**Debuging:**
    - don't forget the colons
    - don't forget the indentations


Then ask snakemake to generate that file:
```bash
snakemake -s hello.smk ~/snakemake.txt -c1
```
<details><summary>What happens? </summary>
<p>
    
By specifying a results, for instance ~/snakemake.txt, snakemake will look at all available rules in your snakemake file (hello.smk) and look for any a  output matching your requirement. It check then for correponding required input. If the input is there, only 1 rule need to be run, if it is not, then snakemake look for another rule to generate that output and if it doesn't exist, it will stop.

</p>
</details>

Let's create an empty file 
```bash
touch ~/requirement.txt
```
Now try again with the previous snakemake command.

###  Wildcards
 Wildcards are keywords between {} used to make rule more general and applicable to multiple situations.
Here we could apply it to make it possible to create a file anywhere on the vm:

```bash
rule Hello_world:
    input: "/home/ubuntu/requirement.txt"
    output: "{path}/snakemake.txt"
    shell: "echo HELLO WORLD > {output}"
```
Let's try this new version:

```bash
snakemake -s hello.smk ~/Projects/snakemake.txt -c1
``` 
### Additional rule entries
-   threads : number of threads the rule needs, default = 1
-   log file
-   params : additional parameters
-   singularity/conda : specify rule specific environment
-   report : report automatically generated by snakemake
-   message : message printed during execution
-   priority : allow to encourage execution of certain task before others
-  benchmark: store runtime information in a file
- run: replacing "shell", when you want snakemake to execute some python code instead of some bash script

Example:
```bash
rule Hello_world:
    input: "/home/ubuntu/requirement.txt"
    output: "{path}/snakemake.txt"
    threads: 100
    log: "{path}/log_hello.txt"
    message: "generating a hello world message"
    shell: "echo HELLO WORLD > {output} 2>{log}"
```
What does happen if threads is bigger than available cores on the vm? 

## Hand on snakemake
### desiging a rule
For a set task, identify files you want snakemake to keep track of

- as input: 
    -  files you absolutely need to have before starting the task
- as output: 
    -  files you will need for other rules
    -  files you want snakemake to check for completion
    - files you may want to ask snakemake to generate.

If you ever want to use wildcards be sure that all wildcards in input cat be derived from wildcards in output. Snakemake need to be able to identify input from looking at ouput.

### Assembly

We are now good to go with translating previous commands into a snakemake file. Let's start with the creation of files for megahit. The best way to proceed is to copy and paste previous command lines and build around it. First let's have a go at creating the R1.csv and R2.csv.
Start from 
```bash
ls $DATA/AD_small/*/*R1.fastq | tr "\n" "," | sed 's/,$//' > R1.csv
ls $DATA/AD_small/*/*R2.fastq | tr "\n" "," | sed 's/,$//' > R2.csv
```
Let's all agree on working on a file called: "binning.smk"
<details><summary>Try for yourself for 5 min before looking here. (Clue, try to write it without input) </summary>
<p>

```bash
rule create megahit_files:
    output: R1 = "{path}/R1.csv",
            R2 = "{path}/R2.csv"
    params: data = "/ifb/data/public/teachdata/ebame/metagenomics-bining/Quince_datasets/AD_small"
    shell:"""
        ls {params.data}/*/*R1.fastq | tr "\n" "," | sed 's/,$//' > {output.R1}
        ls {params.data}/*/*R2.fastq | tr "\n" "," | sed 's/,$//' > {output.R2}
         """
``` 

To note:
 - I use param to store the path info, it makes things clearer. 
 - I don't need to place the R1.csv to any particular place, snakemake will guess what {path} needs to be from when it will need to generate that file

</p>
</details>

#### Megahit
Let's do the same with megahit.
Please translate that command line:
```bash
megahit -1 $(<R1.csv) -2 $(<R2.csv) -t 4 -o Assembly
```

<details><summary>Try for yourself for 5 min before looking here. </summary>
<p>

```bash
rule megahit:
    input: R1 = "{path}/R1.csv",
           R2 = "{path}/R2.csv"
    output: "{path}/Assembly/final.contigs.fa"
    params: "{path}/Assembly"
    threads: 4
    shell: "rm -r {params} && megahit -1 $(<{input.R1}) -2 $(<{input.R1}) -t {threads} -o {params}"
```

To note

- I don't want to keep track of path so I use a wildcard {path}
-  wildcards defined in input output can also be used in the params
- If there is multiple input you can name them and refers to them.
- snakemake will create the directory Assembly by itself, this is a problem as megahit throws an error when the directory already exist.
- we specify the number of threads for megahit
</p>
</details>

#### Read mapping
Same as before please translate the following:
```bash
bwa index final.contigs.fa
bwa mem -t 4 Assembly/final.contigs.fa $file $file2 | samtools view -b -F 4 - | samtools sort - > ${stub}.mapped.sorted.bam
```
<details><summary>Clue: do not write loop, try to write it for a unique sample. Snakemake will loop for you.</summary>
<p>

```bash
rule index_assembly:
    input: "{path}/final.contigs.fa"
    output: "{path}/index.done"
    shell:"""
          bwa index {input}
          touch {output}
          """
```
To note:

- here we use a bogus file for snakemake to track completion of index, if file exist, snakemake know index is done: you don't always need to let snakemake keep track of all your files. 
- Another option is to use {path}/final.contigs.fa.sa  for instance as it is one of the output of the indexing

```bash
rule map_reads:
    input: R1 = "/ifb/data/public/teachdata/ebame/metagenomics-bining/Quince_datasets/AD_small/{sample}/{sample}_R1.fastq",
           R2 = "/ifb/data/public/teachdata/ebame/metagenomics-bining/Quince_datasets/{sample}/{sample}_R1.fastq",
           index = "{path}/Assembly/index.done",
           assembly = "{path}/Assembly/final.contigs.fa"
    output: "{path}/Map/{sample}.mapped.sorted.bam"
    threads: 4
    shell: "bwa mem -t {threads} {input.assembly} {input.R1} {input.R2} | samtools view -b -F 4 - | samtools sort  - > {output}"
```
To note:

- there are way to use python in snakemake to reduce the length of input.R1. Asks if you are not already confused by everything else :)
- here we have 2 wildcards at the same time, sample and path. The critical part is for both to be present in output. If they are in input but not output, snakemake can't replace. 
- this rule will be called once per sample, you can chose to use threads: 4, in this case only 1 map_reads task will be run at the time, or you can use threads: 1, and in this case there will be no parallelisation within bwa. But instead snakemake will launch 4 of them.

</p>
</details>

### Sanity check
Have a try at running current snakemake. 
Let's generate 1 sample .bam file

```bash
snakemake -s binning.smk ~/Projects/AD_snakemake/Map/sample1.mapped.sorted.bam --cores 4 --dry-run
```
If you are not under attack of multiple errors message, snakemake will have listed the series of task it plan to execute. That is the point of the "dry-run" option.

Please add the errors messages you observe on slack so we can try to explain what they mean.

<details><summary>If you are late, or you can't debug your snakemake </summary>
<p>
Use the file stored at:

    ~/repos/Ebame/binning.smk

</p>
</details>

### Coverage
The next command line is a bit troublesome to translate into snakemake since we will need some python coding skill.
```bash
jgi_summarize_bam_contig_depths --outputDepth depth.txt *.bam
```
We need to list all .bam file, one for each sample as input. 

**LEVEL -1:** why not just use some bash pattern mattching? (don't do that)

```bash
 rule generate_coverage:
    input: "{path}/Map/*.sample1.mapped.sorted.bam"
    output: "{path}/Binning/depth.txt"
    shell: "jgi_summarize_bam_contig_depths --outputDepth {output} {input}"
 ```

**LEVEL 0:** 
Just write all samples names, that works! Don't forget the commas

```bash
rule generate_coverage:
    input:'{path}/Map/sample1.mapped.sorted.bam',
          '{path}/Map/sample2.mapped.sorted.bam',
          '{path}/Map/sample3.mapped.sorted.bam',
          '{path}/Map/sample4.mapped.sorted.bam',
          '{path}/Map/sample5.mapped.sorted.bam',
          '{path}/Map/sample6.mapped.sorted.bam',
          '{path}/Map/sample7.mapped.sorted.bam',
          '{path}/Map/sample8.mapped.sorted.bam',
          '{path}/Map/sample9.mapped.sorted.bam',
          '{path}/Map/sample10.mapped.sorted.bam'
    output: "{path}/Binning/depth.txt"
    shell: "jgi_summarize_bam_contig_depths --outputDepth {output} {input}"
```
**LEVEL 1**

First let's list all sample name with a python one-liner. Please copy these lines in the binning.smk file. 


```python
# import functions from basic python library
import glob 
from os.path import basename,dirname

# create a string variable to store path
DATA="/home/ubuntu/data/public/teachdata/ebame/metagenomics-bining/Quince_datasets/AD_small"
# use the glob function to find all R1.fastq file in each folder of DATA
# then only keep the directory name wich is also the sample name
SAMPLES = list()
for file in glob.glob(f"{DATA}/*/*_R1.fastq"):
  # get the path for the parent folder
  p_fold = dirname(file)
  # remove the full path to keep just the folder name
  sample_name = basename(p_fold)
  SAMPLES.append(sample_name)

# the same but using python idiomatic "list comprehension"
SAMPLES = [basename(dirname(file)) for file in glob.glob(f"DATA/*/*_R1.fastq")]
INPUT_FOR_GENERATE_COVERAGE = ["{path}/Map/%s.mapped.sorted.bam"%sample for sample in SAMPLES)]
```
This create a list named SAMPLES, containing the name of each sample. 
We create the snakemake rule:

```bash
rule generate_coverage:
    input: INPUT_FOR_GENERATE_COVERAGE
    output: "{path}/Binning/depth.txt"
    shell: "jgi_summarize_bam_contig_depths --outputDepth {output} {input}"
```
**LEVEL 2**: do the same but with snakemake custom commands **expand**

```bash
rule generate_coverage:
    input: expand("{{path}}/Map/{sample}.mapped.sorted.bam", sample=SAMPLES)
    output: "{path}/Binning/depth.txt"
    shell: "jgi_summarize_bam_contig_depths --outputDepth {output} {input}"
```

To note:

- we use the function expand, it allows to create a list of element. Here {sample} will be replaced by element of SAMPLES. We need to use double {{}} on path, so that expand doesn't try to replace it.
- Instead of using python oneliner, you could store the list of sample in a config file and replace SAMPLES by config["sample"] for instance.
- you may want to use bash pattern matching here as in *.bam, but that won't work. Snakemake run that command before any task is run and before any .bam exist. Thus no bam file will be detected

### Binning
This one is comparatively easy to translate and use tricks we've went through before, try having a go:
```bash
metabat2 -i Assembly/final.contigs.fa -a Binning/depth.txt -t 4 -o Binning/Bins/Bin
```

<details><summary>solution </summary>
<p>

```bash
rule metabat2:
    input: asmbl = "{path}/Assembly/final.contigs.fa",
           cov = "{path}/Binning/depth.txt"
    params: "{path}/Binning/Bins/bin"
    output: "{path}/Binning/metabat2.done"
    threads: 4
    shell: """
    metabat2 -i {input.asmbl} -a {input.cov} -t {threads} -o {params}
    touch {output}
    """
```
</p>
</details>

### Test your snakemake:

    snakemake -s binning.smk ~/Projects/AD_snakemake/Binning/metabat2.done --cores 4 --dry-run

### To go further/summary

-   Snakemake works in reverse, it start from the specified output and looks for rules/recipes able to generate it. It try also multiple wildcards values until it find a way to generate the output.
-   As a snakemake grow bigger, ambiguity in rules may pop up : 2 rules with the same output. And thus, 2 rules/recipe to create the same input. To solve this issue, you need to restrict your rules making them less universal, either a specific path (prodigal/{genome.gff}), or a specific filename {genome}_prodigal.gff. You can also constrain wildcards or specify a priority of rules.
-   Snakemake only keep track of files specified in "input" and "output". A bad way to do snakemake is to have rules generating untracked files and just outputing a flag.
- Snakemake start to have issues when the workflows needs more than 10000 tasks. Some tasks can be grouped together in a unique rule to reduce the number of tasks.
-   Snakemake will resolve the sequence of rules execution before starting --> if you don't know beforehand the number of files generated, it makes things more complicated. You can: 
    - Split your snakemake in multiple independant pipeline, so that at the start of the subsequent snakemake the first one is done and the number of file is known.
    - Use a more complex snakemake concept: checkpoints. 
    - Stop using snakemake to monitors theses files. Don't refers to them explicitely in input/output. Instead create emtpy "flag" at the end of a rule execution and have snakemake take that as input/output. You loose however restarts/incomplete perks of snakemake and flag file do not mesh well with restart/touch mechanisms.







