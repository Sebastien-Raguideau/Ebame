# Pacbio HiFi

In this tutorial we will look at some metagenomic HiFi datasets.
We motivate why HiFi data are useful and how they differs from what we saw with shorts reads.

If this is not the case yet remember to activate the correct conda env:

    conda activate LongReads

## Dataset
There are 2 sample, available at:

    ~/data/public/teachdata/ebame-2022/metagenomics/HIFI_datasets/samples/
- HumanReal: -------------- chris what are these again? ----------
- Zymo: ---------------------- chris what are these again? ----------

Chose either for the rest of the tutorial.

As previously we can use the command seqkit stats to assess these samples.
<details><summary>Solution</summary>
<p>

```bash
seqkit stats ~/data/public/teachdata/ebame-2022/metagenomics/HIFI_datasets/samples/HumanReal_sample1e5.fastq.gz
```

</p>
</details>


 ## Assembly

Mostly 2 pipeline have been developed for assembling HiFi reads for metagenomic datasets.
	- [metaFlye](https://www.nature.com/articles/s41592-020-00971-x) 
	- [hifiasm-meta](https://www.nature.com/articles/s41592-022-01478-3)

Which one is the best?

In this tutorial we are going to use hifiasm-meta. As usual, try to craft your own command line to do so. But first be sure to work in this directory:

```bash
mkdir -p ~/data/mydatalocal/HiFi
cd ~/data/mydatalocal/HiFi
```

<details><summary>Solution</summary>
<p>

```bash
cd ~/data/mydatalocal/HiFi
hifiasm_meta -o asm ~/data/public/teachdata/ebame-2022/metagenomics/HIFI_datasets/samples/HumanReal_sample1e5.fastq.gz -t 4
```
</p>
</details>

This should take about 4858.465 seconds

So instead lets comment on the pre-run version.
```bash
cd ~/data/mydatalocal/HiFi
ln -s ~/data/public/teachdata/ebame-2022/metagenomics/HIFI_datasets/HumanReal_asm prerun_asm
```

Here assembly is also available in the form of a .gfa. Hifiasm uses the GFA1  [format](http://gfa-spec.github.io/GFA-spec/GFA1.html). but also adds on entry relative to reads (line starting by A). 

There is a quite a diversity of output file, what are they? What is a unitig a contig? Let's check the [documentation](https://hifiasm.readthedocs.io/en/latest/interpreting-output.html)

Let's use Bandage to assess this assembly.
```bash
Bandage load asm.p_ctg.gfa
```

-->  look at assembly statistics
-->  look at actual size of smaller size contigs
--> What are the circular components?

The Zymo is a bit more exciting than the HumanReal in terms of circular components, however some of those long contigs even if not circular are could already satisfy medium or high MAGs criterion for quality.

 ## MAGs?
Let's focus here only on circular contigs. 

#### Extract circular contigs
Here, no command will help you, you need to learn about the .gfa format and write a script in your favourite scripting language.  

Here is the path to homemade script, try to run it:

    ~/repos/Ebame/scripts/Circ_cont_from_gfa.py 

<details><summary>It should not be too hard if you use the -h</summary>
<p>

```bash
cd ~/data/mydatalocal/HiFi
~/repos/Ebame/scripts/Circ_cont_from_gfa.py prerun_asm/asm.p_ctg.gfa circ_contigs
```

</p>
</details>

#### Check circular contigs
Clearly some of these are not genomes, we can still launch checkm on everything:

```bash
conda activate STRONG
cd ~/data/mydatalocal/HiFi
checkm lineage_wf circ_contigs checkm -x .fa -t 4 --tab_table > checkm.out
```
currently won't run from lack of memeory because a gtdb run is already ongoing.


#### But wait what if I want to look at one of the non circular contigs?
Retry to use checkm on a contigs you chose and saved with Bandage.

## Plasmids?

Some of these smaller contigs are likely to be plasmids. Let use a machine learning [approach](https://github.com/kkpsiren/PlasmidNet) to verify this.
Try to use a bash loop to apply this command to all files in circ_contigs:
```bash
mkdir plasmidnet
prodigal -i circ_contigs/s1123.ctg001147c.fa -a plasmidnet/s1123.ctg001147c.faa -p meta
conda activate plasmidnet
plasmidnet.py -f plasmidnet/s1123.ctg001147c.faa  -o plasmidnet -m ~/repos/PlasmidNet/model.zip -j 4
```
