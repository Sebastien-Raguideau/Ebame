
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

## Dataset
There are 3 Zymo mock samples, available at:

    ~/data/public/teachdata/ebame/metagenomics-assembly/

As previously we can use the command seqkit stats to assess these samples.
From the stats, try to guess which one is the Hifi, ONT_R9 and ONT_R10.
<details><summary>Solution</summary>
<p>

```bash
seqkit stats --all ~/data/public/teachdata/ebame/metagenomics-assembly/SRR13128014_subreads.fastq.gz
```

Pre-runs for seqkit are located here: ~/repos/Ebame/tmp/datasets/
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
flye --nano-hq ~/data/public/teachdata/ebame/metagenomics-assembly/SRR17913199_1.fastq.gz --out-dir ~/data/mydatalocal/LongReads/metaflye_asm --threads 4 --meta

Hifi:
flye --pacbio-hifi ~/data/public/teachdata/ebame/metagenomics-assembly/SRR13128014_subreads.fastq.gz --out-dir ~/data/mydatalocal/LongReads/metaflye_asm --threads 4 --meta
```
</p>
</details>

Assembly takes a lot of time, so instead lets comment on the pre-run version.

```bash
#Copy hifiasm human assembly in your local folder
ln -s ~/data/public/teachdata/ebame-2022/metagenomics/HIFI_datasets/HumanReal_asm ~/data/mydatalocal/HiFi/hifiasm-meta_human

#Copy hifiasm zymo assembly in your local folder
ln -s ~/data/public/teachdata/ebame-2022/metagenomics/HIFI_datasets/Zymo_asm/ ~/data/mydatalocal/HiFi/hifiasm-meta_zymo

#Print hifiasm output files
ls -lh ~/data/mydatalocal/HiFi/hifiasm-meta_human/
```

-->  look at assembly statistics

-->  look at actual size of longer contigs

Use Bandage to compare the Human and Zymo assemblies.
```bash
Bandage load ~/data/mydatalocal/HiFi/hifiasm-meta_human/asm.p_ctg.gfa
Bandage load ~/data/mydatalocal/HiFi/hifiasm-meta_zymo/asm.p_ctg.gfa
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

The Zymo is a bit more exciting than the HumanReal in terms of circular components, however some of those long contigs even if not circular are could already satisfy medium or high MAGs criterion for quality.

#### Run metaMDBG

Now, let's try to run metaMDBG on the zymo mock communities.

```bash
metaMDBG asm -h
```

<details><summary>Solution</summary>
<p>

```bash

ONT:
metaMDBG asm --in-ont ~/data/public/teachdata/ebame/metagenomics-assembly/SRR17913199_1.fastq.gz --out-dir ~/data/mydatalocal/LongReads/metaMDBG_asm --threads 4

Hifi:
metaMDBG asm --in-hifi ~/data/public/teachdata/ebame/metagenomics-assembly/SRR13128014_subreads.fastq.gz --out-dir ~/data/mydatalocal/LongReads/metaMDBG_asm --threads 4

```
</p>
</details>

Let's wait for metaMDBG to finish a few multi-k iterations.

With the command "metaMDBG gfa", we can generate the assembly graph corresponding to each multi-k iteration. Lower-k graph will have more connectivity, while higher-k graph will have more repeats solved but also more fragmentation. It is interesting to work on lower-k graph if you have external source of data that could solve long repeat (for instance, HiC, ultra long reads, binning metrics). 

Let' try to generate an assembly graph with a low k value. The following command shows the available values for k and their corresponding size in bps. 

```bash
metaMDBG gfa ~/data/mydatalocal/HiFi/metaMDBG_asm 0
```

Choose a value for k and wait for metaMDBG to generate the graph.


<details><summary>Solution</summary>
<p>

```bash
metaMDBG gfa ~/data/mydatalocal/HiFi/metaMDBG_asm 10
```
</p>
</details>

Visualize the assembly graph with Bandage

<details><summary>Solution</summary>
<p>

```bash
Bandage load /home/ubuntu/data/mydatalocal/HiFi/metaMDBG_asm/assemblyGraph_k10_1813bps.gfa
```
</p>
</details>

Now let's check the final metaMDBG assembly results:

```bash
#Copy metaMDBG prerun in your local folder
ln -s ~/repos/Ebame/tmp/metaMDBG_zymo/ ~/data/mydatalocal/HiFi/metaMDBG_zymo

#Print metaMDBG output files
ls -lh ~/data/mydatalocal/HiFi/metaMDBG_zymo/
```

-->  look at assembly statistics

-->  visualize the final assembly graph with Bandage

## MAGs?
Let's focus here only on circular contigs. 

#### Extract circular contigs

We can check if a contig is circular by looking at the contig headers in the fasta files.
If a header ends with a "c", it means that the contig is circular, otherwise it is linear. You can check this info with the following command:

```bash
grep ">" ~/data/mydatalocal/HiFi/hifiasm-meta_zymo_asm.p_ctg.fasta
```

Let's create folders for the circular contigs:
```bash
mkdir -p ~/data/mydatalocal/HiFi/circularContigs/
mkdir -p ~/data/mydatalocal/HiFi/circularContigs/hifiasm_meta/
mkdir -p ~/data/mydatalocal/HiFi/circularContigs/metaMDBG/
```

Now, try to run the following homemade script to extract the circular contigs:

    ~/repos/Ebame/scripts/extractCircularContigs.py 

It should not be too hard if you use the -h.

<details><summary>Solution</summary>
<p>

```bash
~/repos/Ebame/scripts/extractCircularContigs.py ~/data/mydatalocal/HiFi/hifiasm-meta_zymo_asm.p_ctg.fasta ~/data/mydatalocal/HiFi/circularContigs/hifiasm-meta/
~/repos/Ebame/scripts/extractCircularContigs.py ~/data/mydatalocal/HiFi/metaMDBG_zymo/contigs.fasta.gz ~/data/mydatalocal/HiFi/circularContigs/metaMDBG/
```

</p>
</details>

#### Assembly reconciliation

We are now going to merge the results of metaMDBG and hifiasm-meta. The idea is to compute the similarity (ANI) between the circular contigs, and to choose only one representative if two contigs are duplicated (ANI > 0.95 by default).

For this task, we are going to use the software dRep. dRep has a lot of options, let's craft the command together, first display de-replicate options:

```bash
dRep dereplicate -h
```

dRep takes a list of genomes as input (option -g), let's add all circular contig paths in a single file:

<details><summary>Solution</summary>
<p>

```bash
#Collect circular contig paths
ls ~/data/mydatalocal/HiFi/circularContigs/hifiasm-meta/*.fa > ~/data/mydatalocal/HiFi/circularContigs/allCircularContigs.txt
ls ~/data/mydatalocal/HiFi/circularContigs/metaMDBG/*.fa >> ~/data/mydatalocal/HiFi/circularContigs/allCircularContigs.txt

#Check input file
cat ~/data/mydatalocal/HiFi/circularContigs/allCircularContigs.txt
```

</p>
</details>

Let's run dRep in a fast fashion, first disable quality check with option --ignoreGenomeQuality (we'll do it after dereplication), and try to select the "fastANI" method for comparing the circular contigs:

<details><summary>Solution</summary>
<p>

```bash
dRep dereplicate ~/data/mydatalocal/HiFi/circularContigs/drep/ -p 4 -g ~/data/mydatalocal/HiFi/circularContigs/allCircularContigs.txt --S_algorithm fastANI --ignoreGenomeQuality
```

</p>
</details>


Read dRep output information and try to list the folder containing dereplicated contigs.

<details><summary>Solution</summary>
<p>

```bash
ls -lh ~/data/mydatalocal/HiFi/circularContigs/drep/dereplicated_genomes/
```

</p>
</details>

dRep provides a lot of useful information, for instance, we can look at the similarity between the pair of circular contigs:
```bash
column -s, -t < ~/data/mydatalocal/HiFi/circularContigs/drep/data_tables/Ndb.csv
```

Are there any circular contigs which are only found by one assembler?
```bash
column -s, -t < ~/data/mydatalocal/HiFi/circularContigs/drep/data_tables/Cdb.csv
```

#### Assess quality of circular contigs 
Clearly some of these are not genomes, let's run checkm on the dereplicated contigs:

```bash
checkm lineage_wf ~/data/mydatalocal/HiFi/circularContigs/drep/dereplicated_genomes/ ~/data/mydatalocal/HiFi/circularContigs/drep/dereplicated_genomes/checkm/ -r -x .fa -t 4 --pplacer_threads 4 --tab_table -f ~/data/mydatalocal/HiFi/circularContigs/drep/dereplicated_genomes/checkm/results.tsv
```

CheckM is a bit slow, so let's check the prerun results

```bash
ln -s ~/repos/Ebame/tmp/checkm_drepCircularContigs/ ~/data/mydatalocal/HiFi/circularContigs/drep/dereplicated_genomes/checkm_prerun
```

Print columns corresponding to completeness and contamination:

```bash
awk -F"\t" '{ print $1, "\t", $12, "\t", $13 }' ~/data/mydatalocal/HiFi/circularContigs/drep/dereplicated_genomes/checkm_prerun/results.tsv
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
cat ~/data/mydatalocal/HiFi/circularContigs/drep/dereplicated_genomes/*.fa > ~/data/mydatalocal/HiFi/circularContigs/allCircularContigs.fasta

#Concatenante only small circular contigs
find ~/data/mydatalocal/HiFi/circularContigs/drep/dereplicated_genomes/*.fa -size -500k | xargs cat > ~/data/mydatalocal/HiFi/circularContigs/allSmallCircularContigs.fasta
```

</p>
</details> 

The genomad database is located here:

    ~/data/public/teachdata/ebame-2023/virome/db/genomad_db

Let's run genomad (you can use option --sensitivity 1.0 to speed-up prediction, use only for this tutorial):
<details><summary>Solution</summary>
<p>

```bash
genomad end-to-end ~/data/mydatalocal/HiFi/circularContigs/allSmallCircularContigs.fasta ~/data/mydatalocal/HiFi/circularContigs/genomad/ ~/data/public/teachdata/ebame-2023/virome/db/genomad_db --threads 4 --sensitivity 1.0
```

</p>
</details> 

Read genomad logs and try to print plasmids and virus summaries:

<details><summary>Solution</summary>
<p>

```bash
cat ~/data/mydatalocal/HiFi/circularContigs/genomad/allSmallCircularContigs_summary/allSmallCircularContigs_plasmid_summary.tsv
cat ~/data/mydatalocal/HiFi/circularContigs/genomad/allSmallCircularContigs_summary/allSmallCircularContigs_virus_summary.tsv
```

</p>
</details> 

## Other contigs

#### But wait what if I want to look at one of the non circular contigs?
Retry to use checkm on a contigs you chose and saved with Bandage.

--> find a long contigs from Bandage. Then click on "Output" menu -> "Save selected node sequence to FASTA"

Or from the command line, use the following command line replacing \<NODE\>:

```bash
Bandage reduce ~/data/mydatalocal/HiFi/hifiasm-meta_zymo/asm.p_ctg.gfa ~/data/mydatalocal/HiFi/<Node>.gfa  --scope aroundnodes --nodes <NODE> --distance 0
```
--> use a bash online to extract, name and sequence from that gfa graph:
```bash
cd ~/data/mydatalocal/HiFi/linear_contigs
awk '/^S/{print ">"$2"\n"$3}' <Node>.gfa > <Node>.fasta

```
--> use checkm 
