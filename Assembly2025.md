
# Long-reads assembly tutorial

Be sure to launch your VM with -X option, so we can visualize assembly graphs with Bandage.

    ssh -X -A ubuntu@xxx.xxx.xxx.xxx

If this is not the case yet remember to activate the correct conda env:

    conda activate Assembly

We are going to work in the following directory:

```bash
mkdir -p ~/data/mydatalocal/Assembly
cd ~/data/mydatalocal/Assembly
```

Copy the pre-runs folder in your working directory:
```bash
cp -r ~/repos/Ebame/tmp/preruns ~/data/mydatalocal/Assembly
```

## Dataset
There are 3 Zymo mock samples, available at:

    ls -lh $DATA/SRR*fastq.gz

As previously we can use the command seqkit stats to assess these samples.
From the stats, try to guess which one is the Hifi, ONT_R9 and ONT_R10.
<details><summary>Solution</summary>
<p>

```bash
seqkit stats --all $DATA/SRR13128014_subreads.fastq.gz
```

Pre-runs for seqkit are located here: ~/data/mydatalocal/Assembly/preruns/datasets/

</p>
</details>

If DATA is not correctly set you will need to set it:

	export DATA=/ifb/data/public/teachdata/ebame/metagenomics-QR/
	
## Assembly


Mostly 4 software have been developed for assembling long-read metagenomic datasets.

- [metaFlye](https://www.nature.com/articles/s41592-020-00971-x) 

- [hifiasm-meta](https://www.nature.com/articles/s41592-022-01478-3) (HiFi only)

- [metaMDBG](https://www.nature.com/articles/s41587-023-01983-6)

- [myloasm](https://www.biorxiv.org/content/10.1101/2025.09.05.674543v1)

In this tutorial, we are going to run metaflye, metaMDBG and myloasm separatly, then use a method to merge their results.

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
flye --nano-hq ~/data/public/teachdata/ebame/metagenomics-assembly/SRR17913199_1.fastq.gz --out-dir ~/data/mydatalocal/Assembly/metaflye_asm_ont --threads 4 --meta

Hifi:
flye --pacbio-hifi ~/data/public/teachdata/ebame/metagenomics-assembly/SRR13128014_subreads.fastq.gz --out-dir ~/data/mydatalocal/Assembly/metaflye_asm_hifi --threads 4 --meta
```
</p>
</details>








#### Run metaMDBG

Now, let's try to run metaMDBG on the zymo mock communities.

```bash
metaMDBG asm -h
```

<details><summary>Solution</summary>
<p>

```bash

Hifi:
metaMDBG asm --in-hifi ~/data/public/teachdata/ebame/metagenomics-assembly/SRR13128014_subreads.fastq.gz --out-dir ~/data/mydatalocal/Assembly/metaMDBG_asm_hifi --threads 4

ONT:
metaMDBG asm --in-ont ~/data/public/teachdata/ebame/metagenomics-assembly/SRR17913199_1.fastq.gz --out-dir ~/data/mydatalocal/Assembly/metaMDBG_asm_ont --threads 4

```
</p>
</details>








#### Run myloasm

Use the following commands to see usage information for myloasm:

```bash
myloasm -h
```

<details><summary>Solution</summary>
<p>

```bash

ONT:
myloasm --threads 4 --nano-r10 ~/data/public/teachdata/ebame/metagenomics-assembly/SRR17913199_1.fastq.gz --output-dir ~/data/mydatalocal/Assembly/myloasm_asm_ont

Hifi:
myloasm --threads 4  --hifi ~/data/public/teachdata/ebame/metagenomics-assembly/SRR13128014_subreads.fastq.gz --output-dir ~/data/mydatalocal/Assembly/myloasm_asm_hifi
```
</p>
</details>



#### Assembly stats

Assembly takes a lot of time, so instead lets comment on the pre-run version.

```bash
#Metaflye results on ONT
ls ~/data/mydatalocal/Assembly/preruns/assembly/SRR17913199_ONT_Q20/metaflye/

#Metaflye results on HiFi
ls ~/data/mydatalocal/Assembly/preruns/assembly/SRR13128014_hifi/metaflye/
```

-->  look at assembly statistics

-->  look at actual size of longer contigs

Use Bandage to compare the Zymo ONT and HiFi assemblies.
```bash

#Decompress gfa file first, then run Bandage
gzip -d ~/data/mydatalocal/Assembly/preruns/assembly/SRR17913199_ONT_Q20/metaflye/assembly_graph.gfa.gz
gzip -d ~/data/mydatalocal/Assembly/preruns/assembly/SRR13128014_hifi/metaflye/assembly_graph.gfa.gz

#ONT graph
Bandage load ~/data/mydatalocal/Assembly/preruns/assembly/SRR17913199_ONT_Q20/metaflye/assembly_graph.gfa

#Hifi graph
Bandage load ~/data/mydatalocal/Assembly/preruns/assembly/SRR13128014_hifi/metaflye/assembly_graph.gfa
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
* Click "Load from fasta file" -> Select a reference genome in ~/data/mydatalocal/Assembly/references/
* Click "Run blast search"
* Recommanded: try to tune the blast filter (alignment length and identity)



Now let's check metaMDBG and myloasm graphs:

```bash
#Show output files
ls -lh ~/data/mydatalocal/Assembly/preruns/assembly/SRR13128014_hifi/metaMDBG/
ls -lh ~/data/mydatalocal/Assembly/preruns/assembly/SRR13128014_hifi/myloasm/
```

Let's run Bandage and check how metaMDBG and myloasm handle the ecoli strains:

```bash

#Decompress gfa file first, then run Bandage

#metaMDBG
gzip -d ~/data/mydatalocal/Assembly/preruns/assembly/SRR13128014_hifi/metaMDBG/assemblyGraph_k105_20813bps.gfa.gz
Bandage load ~/data/mydatalocal/Assembly/preruns/assembly/SRR13128014_hifi/metaMDBG/assemblyGraph_k105_20813bps.gfa

#myloasm
gzip -d ~/data/mydatalocal/Assembly/preruns/assembly/SRR13128014_hifi/myloasm/final_contig_graph.gfa.gz
Bandage load ~/data/mydatalocal/Assembly/preruns/assembly/SRR13128014_hifi/myloasm/final_contig_graph.gfa

```


## MAGs?
Let's focus here only on circular contigs. 

#### Extract circular contigs

For metaMDBG, we can check if a contig is circular by looking at the contig headers in the fasta files.
If a header contains the field "circular=yes", it means that the contig is circular, otherwise it is linear. You can check this info with the following command:

```bash

#Show all headers
zcat ~/data/mydatalocal/Assembly/preruns/assembly/SRR13128014_hifi/metaMDBG/contigs.fasta.gz | grep ">"

#Show header with the circular flag = "yes"
zcat ~/data/mydatalocal/Assembly/preruns/assembly/SRR13128014_hifi/metaMDBG/contigs.fasta.gz | grep ">" | grep "circular=yes"
```

Metaflye uses an extra metadata file for contig information
```bash

#Show contig metadata
head -n 30 ~/data/mydatalocal/Assembly/preruns/assembly/SRR13128014_hifi/metaflye/assembly_info.txt
```

Myloasm uses similar format as metaMDBG
```bash

#Show contig metadata
zcat ~/data/mydatalocal/Assembly/preruns/assembly/SRR13128014_hifi/myloasm/assembly_primary.fa.gz | grep ">" | grep "circular-yes"
```

Let's create folders for the circular contigs:
```bash
mkdir -p ~/data/mydatalocal/HiFi/circularContigs/
mkdir -p ~/data/mydatalocal/HiFi/circularContigs/metaflye/
mkdir -p ~/data/mydatalocal/HiFi/circularContigs/metaMDBG/
mkdir -p ~/data/mydatalocal/HiFi/circularContigs/myloasm/
```

We use a custom script to extract all circular contigs:

```bash
#Extract metaflye circular contigs (HiFi)
python3 ~/repos/Ebame/scripts/extractCircularContigs.py ~/data/mydatalocal/Assembly/preruns/assembly/SRR13128014_hifi/metaflye/assembly.fasta.gz ~/data/mydatalocal/Assembly/preruns/assembly/SRR13128014_hifi/metaflye/assembly_info.txt metaflye ~/data/mydatalocal/Assembly/circularContigs/metaflye/

#Extract metaMDBG circular contigs (HiFi)
python3 ~/repos/Ebame/scripts/extractCircularContigs.py ~/data/mydatalocal/Assembly/preruns/assembly/SRR13128014_hifi/metaMDBG/contigs.fasta.gz ~/data/mydatalocal/Assembly/preruns/assembly/SRR13128014_hifi/metaMDBG/contigs.fasta.gz metaMDBG ~/data/mydatalocal/Assembly/circularContigs/metaMDBG/

#Extract myloasm circular contigs (HiFi)
python3 ~/repos/Ebame/scripts/extractCircularContigs.py ~/data/mydatalocal/Assembly/preruns/assembly/SRR13128014_hifi/myloasm/assembly_primary.fa.gz ~/data/mydatalocal/Assembly/preruns/assembly/SRR13128014_hifi/myloasm/assembly_primary.fa.gz myloasm ~/data/mydatalocal/Assembly/circularContigs/myloasm/
```

List the extracted circular contigs:
```bash
ls -lh ~/data/mydatalocal/Assembly/circularContigs/metaflye/
ls -lh ~/data/mydatalocal/Assembly/circularContigs/metaMDBG/
ls -lh ~/data/mydatalocal/Assembly/circularContigs/myloasm/
```

#### Assembly reconciliation

We are now going to merge the results of metaMDBG, metaflye and myloasm. The idea is to compute the similarity (ANI) between the circular contigs, and to choose only one representative if two contigs are duplicated (ANI > 0.95 by default).

For this task, we are going to use the software dRep. dRep has a lot of options, let's craft the command together, first display de-replicate options:

```bash
dRep dereplicate -h
```

* First choose a output folder
* dRep takes a list of genomes as input (option -g), try to provide all the fasta file with regex
    * Metaflye circular contigs are here: ~/data/mydatalocal/Assembly/circularContigs/metaflye/
    * MetaMDBG circular contigs are here: ~/data/mydatalocal/Assembly/circularContigs/metaMDBG/
* Disable quality check with option --ignoreGenomeQuality (we'll do it after dereplication)
* Disable plotting with --skip_plots
* Try to select the "skani" method for comparing the circular contigs quickly

<details><summary>Solution</summary>
<p>

```bash
dRep dereplicate ~/data/mydatalocal/Assembly/drep_circular/ -p 4 -g ~/data/mydatalocal/Assembly/circularContigs/metaflye/*.fa ~/data/mydatalocal/Assembly/circularContigs/metaMDBG/*.fa ~/data/mydatalocal/Assembly/circularContigs/myloasm/*.fa --S_algorithm skani --ignoreGenomeQuality --skip_plots
```

</p>
</details>


Read dRep output information and try to list the folder containing dereplicated contigs.

<details><summary>Solution</summary>
<p>

```bash
ls -lh ~/data/mydatalocal/Assembly/drep_circular/dereplicated_genomes/
```

</p>
</details>

dRep provides a lot of useful information, for instance, we can look at the similarity between the pair of circular contigs:
```bash
column -s, -t < ~/data/mydatalocal/Assembly/drep_circular/data_tables/Ndb.csv
```

Are there any circular contigs which are only found by one assembler?
```bash
column -s, -t < ~/data/mydatalocal/Assembly/drep_circular/data_tables/Cdb.csv
```

#### Assess quality of circular contigs 
Clearly some of these are not genomes, let's run checkm on the dereplicated contigs:

```bash
#checkm lineage_wf  ~/data/mydatalocal/Assembly/drep_circular/dereplicated_genomes/ ~/data/mydatalocal/Assembly/checkm_output/ -t 4 --pplacer_threads 4  -r -x .fa --tab_table -f ~/data/mydatalocal/Assembly/checkm_results.tsv

checkm2 predict --force --threads 4 -x fa -i ~/data/mydatalocal/Assembly/drep_circular/dereplicated_genomes/ -o ~/data/mydatalocal/Assembly/checkm_output/
```

CheckM2 is a bit slow, so let's check the prerun results
```bash
cat ~/data/mydatalocal/Assembly/preruns/checkm2_results.tsv
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
cat ~/data/mydatalocal/Assembly/drep_circular/dereplicated_genomes/*.fa > ~/data/mydatalocal/Assembly/allCircularContigs.fasta

#Concatenante only small circular contigs
find ~/data/mydatalocal/Assembly/drep_circular/dereplicated_genomes/*.fa -size -500k | xargs cat > ~/data/mydatalocal/Assembly/allSmallCircularContigs.fasta
```

</p>
</details> 

The genomad database is located here:

    ~/data/public/teachdata/ebame/viral-metagenomics/genomad_db/

Let's run try to run genomad now.

<details><summary>Solution</summary>
<p>

```bash
genomad end-to-end ~/data/mydatalocal/Assembly/allSmallCircularContigs.fasta ~/data/mydatalocal/Assembly/genomad/ ~/data/public/teachdata/ebame/viral-metagenomics/genomad_db/ --conservative --threads 4
```

</p>
</details> 

Read genomad logs and try to print plasmids and virus summaries:
(pre-runs are located here: ~/data/mydatalocal/Assembly/preruns/genomad/)

<details><summary>Solution</summary>
<p>

```bash
cat ~/data/mydatalocal/Assembly/preruns/genomad/allSmallCircularContigs_summary/allSmallCircularContigs_plasmid_summary.tsv
cat ~/data/mydatalocal/Assembly/preruns/genomad/allSmallCircularContigs_summary/allSmallCircularContigs_virus_summary.tsv
```

</p>
</details> 

By the way, there is a software called [checkv](https://www.nature.com/articles/s41587-020-00774-7) to assess the quality of viral contigs.

## Other contigs

#### But wait what if I want to look at one of the non circular contigs?
Retry to use checkm on a contigs you chose and saved with Bandage.

--> find a long contigs from Bandage. Then click on "Output" menu -> "Save selected node sequence to FASTA"

Or from the command line, use the following command line replacing \<NODE\>:

```bash
Bandage reduce ~/data/mydatalocal/Assembly/preruns/assembly/SRR13128014_hifi/metaflye/assembly_graph.gfa ~/data/mydatalocal/Assembly/<Node>.gfa  --scope aroundnodes --nodes <NODE> --distance 0
```
--> use a bash online to extract, name and sequence from that gfa graph:
```bash
awk '/^S/{print ">"$2"\n"$3}' ~/data/mydatalocal/Assembly/<Node>.gfa > ~/data/mydatalocal/Assembly/<Node>.fasta

```

--> For myloasm: another script to extract contig by name from a fasta file:
```bash
mkdir ~/data/mydatalocal/Assembly/mycontigs/
python3 ~/repos/Ebame/scripts/extractSequenceFasta.py ~/data/mydatalocal/Assembly/preruns/assembly/SRR13128014_hifi/myloasm/assembly_primary.fa.gz u[ID]ctg ~/data/mydatalocal/Assembly/mycontigs/contig.fa
```

--> use checkm 
