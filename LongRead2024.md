
# PacBio HiFi assembly tutorial

Be sure to launch your VM with -X option, so we can visualize assembly graphs with Bandage.

    ssh -X -A ubuntu@xxx.xxx.xxx.xxx

If this is not the case yet remember to activate the correct conda env:

    conda activate LongReads

We are going to work in the following directory:

```bash
mkdir -p ~/data/mydatalocal/LongReads
cd ~/data/mydatalocal/LongReads
```

Copy the pre-runs folder in your working directory:
```bash
cp -r ~/repos/Ebame/tmp/preruns ~/data/mydatalocal/LongReads
```

## Dataset
There are 3 Zymo mock samples, available at:

    ls -lh ~/data/public/teachdata/ebame/metagenomics-assembly/

As previously we can use the command seqkit stats to assess these samples.
From the stats, try to guess which one is the Hifi, ONT_R9 and ONT_R10.
<details><summary>Solution</summary>
<p>

```bash
seqkit stats --all ~/data/public/teachdata/ebame/metagenomics-assembly/SRR13128014_subreads.fastq.gz
```

Pre-runs for seqkit are located here: ~/data/mydatalocal/LongReads/preruns/datasets/

</p>
</details>

## Assembly


Mostly 3 software have been developed for assembling long-read metagenomic datasets.

- [metaFlye](https://www.nature.com/articles/s41592-020-00971-x) 

- [hifiasm-meta](https://www.nature.com/articles/s41592-022-01478-3)

- [metaMDBG](https://www.nature.com/articles/s41587-023-01983-6)

In this tutorial, we are going to run metaflye and metaMDBG separatly, then use a method to merge their results.

As usual, try to craft your own command line to run the software. 


#### Run metaflye

Let's run metaflye first.

Use the following commands to see usage information for metaflye:

```bash
flye -h
```

<details><summary>Solution</summary>
<p>

```bash

ONT:
flye --nano-hq ~/data/public/teachdata/ebame/metagenomics-assembly/SRR17913199_1.fastq.gz --out-dir ~/data/mydatalocal/LongReads/metaflye_asm_ont --threads 4 --meta

Hifi:
flye --pacbio-hifi ~/data/public/teachdata/ebame/metagenomics-assembly/SRR13128014_subreads.fastq.gz --out-dir ~/data/mydatalocal/LongReads/metaflye_asm_hifi --threads 4 --meta
```
</p>
</details>

Assembly takes a lot of time, so instead lets comment on the pre-run version.

```bash
#Metaflye results on ONT
ls ~/data/mydatalocal/LongReads/preruns/assembly/SRR17913199_ONT_Q20/metaflye/

#Metaflye results on HiFi
ls ~/data/mydatalocal/LongReads/preruns/assembly/SRR13128014_hifi/metaflye/
```

-->  look at assembly statistics

-->  look at actual size of longer contigs

Use Bandage to compare the Zymo ONT and HiFi assemblies.
```bash

#Decompress gfa file first, then run Bandage
gzip -d ~/data/mydatalocal/LongReads/preruns/assembly/SRR17913199_ONT_Q20/metaflye/assembly_graph.gfa.gz
Bandage load ~/data/mydatalocal/LongReads/preruns/assembly/SRR17913199_ONT_Q20/metaflye/assembly_graph.gfa

#Hifi graph
gzip -d ~/data/mydatalocal/LongReads/preruns/assembly/SRR13128014_hifi/metaflye/assembly_graph.gfa.gz
Bandage load ~/data/mydatalocal/LongReads/preruns/assembly/SRR13128014_hifi/metaflye/assembly_graph.gfa
```

<details><summary> If you have issues with Bandage </summary>
<p>

#### Fix1
Did you use -X or -Y when connecting to the VM? If not, please disconect and retype ssh with that flag:

    ssh -X ubuntu@xxx.xxx.xxx.xxx

#### Fix2
If you have Bandage on your laptop, use the scp command to download the gfa file on your laptop:

    scp ubuntu@xxx.xxx.xxx.xxx:~/data/mydatalocal/HiFi/prerun_asm/asm.p_ctg.gfa	.

This will copy the file to the directory you executed that command from. Also to be clear this command should not be run on the vm. This is a command for your laptop to request that file from the distant server. So it should be run on a terminal before you connect to the vm.

#### Fix3
Try and follow explanation on how to forward display from this google doc:
https://docs.google.com/document/d/1VPnL-5mXXQimkXQNiQagPhgzRn8j1JBHCLV42r8-Wqc/edit#


</p>
</details>

This Zymo mock community contains 5 ecoli strains, let's try to find them using the blast feature.
* Click "Create/view Blast search" button
* Click "Build Blast database"
* Click "Load from fasta file" -> Select a reference genome in ~/data/mydatalocal/LongReads/references/
* Click "Run blast search"
* Recommanded: try to tune the blast filter (alignment length and identity)

#### Run metaMDBG

Now, let's try to run metaMDBG on the zymo mock communities.

```bash
metaMDBG asm -h
```

<details><summary>Solution</summary>
<p>

```bash

Hifi:
metaMDBG asm --in-hifi ~/data/public/teachdata/ebame/metagenomics-assembly/SRR13128014_subreads.fastq.gz --out-dir ~/data/mydatalocal/LongReads/metaMDBG_asm_hifi --threads 4

ONT:
metaMDBG asm --in-ont ~/data/public/teachdata/ebame/metagenomics-assembly/SRR17913199_1.fastq.gz --out-dir ~/data/mydatalocal/LongReads/metaMDBG_asm_ont --threads 4

```
</p>
</details>

Let's wait for metaMDBG to finish a few multi-k iterations.

With the command "metaMDBG gfa", we can generate the assembly graph corresponding to each multi-k iteration. Lower-k graph will have more connectivity, while higher-k graph will have more repeats solved but also more fragmentation. It is interesting to work on lower-k graph if you have external source of data that could solve long repeat (for instance, HiC, ultra long reads, binning metrics). 

Let' try to generate an assembly graph with a low k value. The following command shows the available values for k and their corresponding size in bps. 

```bash
metaMDBG gfa --assembly-dir ~/data/mydatalocal/LongReads/metaMDBG_asm_ont --k 0
```

Choose a value for k and wait for metaMDBG to generate the graph.


<details><summary>Solution</summary>
<p>

```bash
metaMDBG gfa ~/data/mydatalocal/LongReads/metaMDBG_asm_ont/ --k 10
```
</p>
</details>

Visualize the assembly graph with Bandage

<details><summary>Solution</summary>
<p>

```bash
Bandage load ~/data/mydatalocal/LongReads/metaMDBG_asm_ont/assemblyGraph_k10_1813bps.gfa
```
</p>
</details>

Now let's check the final metaMDBG assembly results:

```bash
#Show metaMDBG output files
ls -lh ~/data/mydatalocal/LongReads/preruns/assembly/SRR13128014_hifi/metaMDBG/
```

Let's run Bandage and check how metaMDBG handles the ecoli strains:

```bash

#Decompress gfa file first, then run Bandage
gzip -d ~/data/mydatalocal/LongReads/preruns/assembly/SRR13128014_hifi/metaMDBG/assemblyGraph_k105_20813bps.gfa.gz
Bandage load ~/data/mydatalocal/LongReads/preruns/assembly/SRR13128014_hifi/metaMDBG/assemblyGraph_k105_20813bps.gfa

```


## MAGs?
Let's focus here only on circular contigs. 

#### Extract circular contigs

For metaMDBG, we can check if a contig is circular by looking at the contig headers in the fasta files.
If a header contains the field "circular=yes", it means that the contig is circular, otherwise it is linear. You can check this info with the following command:

```bash

#Show all headers
zcat ~/data/mydatalocal/LongReads/preruns/assembly/SRR13128014_hifi/metaMDBG/assembly.fasta.gz | grep ">"

#Show header with the circular flag = "yes"
zcat ~/data/mydatalocal/LongReads/preruns/assembly/SRR13128014_hifi/metaMDBG/assembly.fasta.gz | grep ">" | grep "circular=yes"
```

Metaflye uses an extra metadata file for contig information
```bash

#Show contig metadata
cat ~/data/mydatalocal/LongReads/preruns/assembly/SRR13128014_hifi/metaflye/assembly_info.txt
```


Let's create folders for the circular contigs:
```bash
mkdir -p ~/data/mydatalocal/HiFi/circularContigs/
mkdir -p ~/data/mydatalocal/HiFi/circularContigs/metaflye/
mkdir -p ~/data/mydatalocal/HiFi/circularContigs/metaMDBG/
```

We use a custom script to extract all circular contigs:

```bash
#Extract metaflye circular contigs (HiFi)
python3 ~/repos/Ebame/scripts/extractCircularContigs.py ~/data/mydatalocal/LongReads/preruns/assembly/SRR13128014_hifi/metaflye/assembly.fasta.gz ~/data/mydatalocal/LongReads/preruns/assembly/SRR13128014_hifi/metaflye/assembly_info.txt metaflye ~/data/mydatalocal/LongReads/circularContigs/metaflye/

#Extract metaMDBG circular contigs (HiFi)
python3 ~/repos/Ebame/scripts/extractCircularContigs.py ~/data/mydatalocal/LongReads/preruns/assembly/SRR13128014_hifi/metaMDBG/assembly.fasta.gz ~/data/mydatalocal/LongReads/preruns/assembly/SRR13128014_hifi/metaMDBG/assembly.fasta.gz metaMDBG ~/data/mydatalocal/LongReads/circularContigs/metaMDBG/
```


#### Assembly reconciliation

We are now going to merge the results of metaMDBG and metaflye. The idea is to compute the similarity (ANI) between the circular contigs, and to choose only one representative if two contigs are duplicated (ANI > 0.95 by default).

For this task, we are going to use the software dRep. dRep has a lot of options, let's craft the command together, first display de-replicate options:

```bash
dRep dereplicate -h
```

* First choose a output folder
* dRep takes a list of genomes as input (option -g), try to provide all the fasta file with regex
    * Metaflye circular contigs are here: ~/data/mydatalocal/LongReads/circularContigs/metaflye/
    * MetaMDBG circular contigs are here: ~/data/mydatalocal/LongReads/circularContigs/metaMDBG/
* Disable quality check with option --ignoreGenomeQuality (we'll do it after dereplication)
* Disable plotting with --skip_plots
* Try to select the "skani" method for comparing the circular contigs quickly

<details><summary>Solution</summary>
<p>

```bash
dRep dereplicate ~/data/mydatalocal/LongReads/drep_circular/ -p 4 -g ~/data/mydatalocal/LongReads/circularContigs/metaflye/*.fa ~/data/mydatalocal/LongReads/circularContigs/metaMDBG/*.fa --S_algorithm skani --ignoreGenomeQuality --skip_plots
```

</p>
</details>


Read dRep output information and try to list the folder containing dereplicated contigs.

<details><summary>Solution</summary>
<p>

```bash
ls -lh ~/data/mydatalocal/LongReads/drep_circular/dereplicated_genomes/
```

</p>
</details>

dRep provides a lot of useful information, for instance, we can look at the similarity between the pair of circular contigs:
```bash
column -s, -t < ~/data/mydatalocal/LongReads/drep_circular/data_tables/Ndb.csv
```

Are there any circular contigs which are only found by one assembler?
```bash
column -s, -t < ~/data/mydatalocal/LongReads/drep_circular/data_tables/Cdb.csv
```

#### Assess quality of circular contigs 
Clearly some of these are not genomes, let's run checkm on the dereplicated contigs:
(by the way, sorry, there is a checkm2 version now which is way faster and user-friendly)

```bash
checkm lineage_wf  ~/data/mydatalocal/LongReads/drep_circular/dereplicated_genomes/ ~/data/mydatalocal/LongReads/checkm_output/ -t 4 --pplacer_threads 4  -r -x .fa --tab_table -f ~/data/mydatalocal/LongReads/checkm_results.tsv
```

CheckM is a bit slow, so let's check the prerun results
```bash
cat ~/data/mydatalocal/LongReads/checkm_results.tsv
```

Print columns corresponding to completeness and contamination:

```bash
awk -F"\t" '{ print $1, "\t", $12, "\t", $13 }' ~/data/mydatalocal/LongReads/checkm_results.tsv
```

## Plasmids and virus?

Some of the smaller circular contigs are likely to be plasmids or virus. Let's use [genomad](https://github.com/apcamargo/genomad), a machine learning approach to verify this.

As usual, let's check the software usage information:
```bash
genomad -h
genomad end-to-end -h
```

Genomad takes as input a single fasta file. It will then process the contigs one by one and determine how likely they are to be plasmids or virus. Let's concatenate the small dereplicated circular contigs in a single fasta file.
<details><summary>Solution</summary>
<p>

```bash
#Concatenate all circular contigs in a single fasta file
cat ~/data/mydatalocal/LongReads/drep_circular/dereplicated_genomes/*.fa > ~/data/mydatalocal/LongReads/allCircularContigs.fasta

#Concatenante only small circular contigs
find ~/data/mydatalocal/LongReads/drep_circular/dereplicated_genomes/*.fa -size -500k | xargs cat > ~/data/mydatalocal/LongReads/allSmallCircularContigs.fasta
```

</p>
</details> 

The genomad database is located here:

    ~/data/public/teachdata/ebame-2023/virome/db/genomad_db

Let's run try to run genomad now.

<details><summary>Solution</summary>
<p>

```bash
genomad end-to-end ~/data/mydatalocal/LongReads/allSmallCircularContigs.fasta ~/data/mydatalocal/LongReads/genomad/ ~/appa/data/genomad/genomad_db/ --conservative --threads 4
```

</p>
</details> 

Read genomad logs and try to print plasmids and virus summaries:

<details><summary>Solution</summary>
<p>

```bash
cat ~/data/mydatalocal/LongReads/genomad/allSmallCircularContigs_summary/allSmallCircularContigs_plasmid_summary.tsv
cat ~/data/mydatalocal/LongReads/genomad/allSmallCircularContigs_summary/allSmallCircularContigs_virus_summary.tsv
```

</p>
</details> 

## Other contigs

#### But wait what if I want to look at one of the non circular contigs?
Retry to use checkm on a contigs you chose and saved with Bandage.

--> find a long contigs from Bandage. Then click on "Output" menu -> "Save selected node sequence to FASTA"

Or from the command line, use the following command line replacing \<NODE\>:

```bash
Bandage reduce ~/data/mydatalocal/LongReads/preruns/assembly/SRR13128014_hifi/metaflye/assembly_graph.gfa ~/data/mydatalocal/LongReads/<Node>.gfa  --scope aroundnodes --nodes <NODE> --distance 0
```
--> use a bash online to extract, name and sequence from that gfa graph:
```bash
awk '/^S/{print ">"$2"\n"$3}' ~/data/mydatalocal/LongReads/<Node>.gfa > ~/data/mydatalocal/LongReads/<Node>.fasta

```
--> use checkm 
