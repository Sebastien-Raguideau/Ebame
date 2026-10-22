# Eukaryotic binning tutorial

## Background

Washed-rind cheeses (Morbier, Reblochon) are washed with brine during ripening. The salty, moist surface selects for a microbial community that forms the sticky, often orange rind, and is responsible for much of the strong aroma of these cheeses.

Early in the process, the curd surface is acidic and salty, and few bacteria can grow on it. Salt- and acid-tolerant yeasts colonise it first: they consume lactate and break down proteins, releasing ammonia, which raises the surface pH. This deacidification allows salt-tolerant bacteria to take over.

## Dataset

In this tutorial we will work with long-read metagenomic data from a washed-rind cheese, taken from [Saak et al. 2023, *mSystems*](https://doi.org/10.1128/msystems.00701-22) (run [SRR18495441](https://www.ncbi.nlm.nih.gov/sra/SRR18495441), BioProject [PRJNA778418](https://www.ncbi.nlm.nih.gov/bioproject/PRJNA778418)). The community was sequenced with PacBio HiFi. To keep run times short and to focus on eukaryotes, we built a smaller subset of the original run ([Zenodo](https://doi.org/10.5281/zenodo.23511123)). Reads from fungal species were sampled to give each species a similar depth (~16x). A random set of background reads was then added.

![Rinds of the three washed-rind cheeses during ripening](Figures/cheese_rinds.jpg)

_Rinds of the three washed-rind cheeses during ripening. Our reads come from Cheese B at week 2. Figure 1A from [Saak et al. 2023](https://doi.org/10.1128/msystems.00701-22), [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/)._

The goal of this tutorial is to demonstrate how to bin eukaryotic genomes from metagenomic data starting from the raw reads. We will use two different binning tools, MetaBAT2 and REMAG, and compare their results. We will also assess the quality of the bins with BUSCO and EukCC. Finally, we will compare the bins to a set of reference genomes to see how well they match and assign taxonomy.

## Download the dataset

Let's start by creating a project folder (`~/Projects/Cheese_Tuto`) with a `data` subfolder, and downloading the raw reads there. Note that as it is PacBio HiFi data, the reads are unpaired and stored in a single fastq.gz file.

```bash
mkdir -p ~/Projects/Cheese_Tuto/data
cd ~/Projects/Cheese_Tuto/data

wget -c https://zenodo.org/records/23511123/files/cheese_balanced_reads.fastq.gz

cd ..
```

Your project folder now looks like this:

```text
~/Projects/Cheese_Tuto
└── data/
    └── cheese_balanced_reads.fastq.gz
```

Let's have a first look at the reads with seqkit, which is in the `Assembly` environment.

```bash
cd ~/Projects/Cheese_Tuto
conda activate Assembly
seqkit stats -a data/cheese_balanced_reads.fastq.gz
```

> **Questions**
>
> - How many reads are there, and how long are they?
> - What do the Q20(%) and Q30(%) columns tell you about HiFi reads?

## From reads to bins

Now, for the next 15 minutes, please try to use what you learned in the previous sessions to do the following steps. A solution is given below each step, but please try first.

### 1. Assembly with metaMDBG (env Assembly)

_Run time on a 16-core VM: about 6 minutes._

<details><summary>Solution</summary>
<p>

Activate the environment which will be used for assembly. It contains metaMDBG and seqkit for quality control.

```bash
conda info --envs

conda activate Assembly
```

We will now assemble the reads with [metaMDBG](https://github.com/GaetanBenoitDev/metaMDBG) ([paper](https://www.nature.com/articles/s41587-023-01983-6)) using the appropriate preset for PacBio HiFi reads.

```bash
cd ~/Projects/Cheese_Tuto
metaMDBG asm --in-hifi data/cheese_balanced_reads.fastq.gz --out-dir metamdbg --threads 16
```

Your project folder now looks like this:

```text
~/Projects/Cheese_Tuto
├── data/
└── metamdbg/                 # new
    ├── contigs.fasta.gz      # the assembly
    ├── metaMDBG.log
    └── tmp/
```

</p>
</details>

### 2. Check the assembly with seqkit stats (env Assembly)

<details><summary>Solution</summary>
<p>

Let's inspect the assembly quality with seqkit ([GitHub](https://github.com/shenwei356/seqkit), [documentation](https://bioinf.shenwei.me/seqkit/usage/)). The result will be printed to the terminal.

```bash
cd ~/Projects/Cheese_Tuto
seqkit stats -a metamdbg/contigs.fasta.gz
```

</p>
</details>

> **Questions**
>
> - What are the more informative columns?
> - How's the quality of the assembly looking?

### 3. Use the course assembly

```bash
cd ~/Projects/Cheese_Tuto
wget -O metamdbg/contigs.fasta.gz https://zenodo.org/records/23511123/files/cheese_metamdbg_assembly.fasta.gz
seqkit stats -a metamdbg/contigs.fasta.gz
```

> **Questions**
>
> - How does this assembly compare to yours?

### 4. Mapping with minimap2 (env LongReads)

<details><summary>Solution</summary>
<p>

Next, we need to determine the coverage of each contig by mapping the reads back to the assembly. This will be used for binning.

First, we activate the environment which contains minimap2 ([GitHub](https://github.com/lh3/minimap2), [manual](https://lh3.github.io/minimap2/minimap2.html)) and samtools ([GitHub](https://github.com/samtools/samtools), [documentation](https://www.htslib.org/doc/samtools.html)).

```bash
cd ~/Projects/Cheese_Tuto
conda activate LongReads

mkdir mapping
```

While for short reads bwa-mem is often used, for long reads minimap2 is the preferred mapper. We will use the `map-hifi` preset, which is optimized for PacBio HiFi reads.

```bash
cd ~/Projects/Cheese_Tuto
minimap2 -t 16 -ax map-hifi metamdbg/contigs.fasta.gz data/cheese_balanced_reads.fastq.gz > mapping/reads.sam
```

</p>
</details>

### 5. Use samtools to get a bam file, sort it and index it (env LongReads)

<details><summary>Solution</summary>
<p>

```bash
cd ~/Projects/Cheese_Tuto
samtools view -@ 16 -b -o mapping/reads.unsorted.bam mapping/reads.sam

samtools sort -@ 16 -o mapping/reads.bam mapping/reads.unsorted.bam

samtools index mapping/reads.bam
```

Your project folder now looks like this:

```text
~/Projects/Cheese_Tuto
├── data/
├── metamdbg/
└── mapping/                  # new
    ├── reads.sam
    ├── reads.unsorted.bam
    ├── reads.bam             # sorted
    └── reads.bam.bai         # index
```

</p>
</details>

### 6. Run MetaBAT2 and check the bins with seqkit stats (env binning)

The `binning` environment contains MetaBAT2, REMAG and BUSCO, but not seqkit. Install it first:

```bash
conda activate binning
mamba install -y bioconda::seqkit
```

<details><summary>Solution</summary>
<p>

[MetaBAT2](https://bitbucket.org/berkeleylab/metabat) is a widely used binning tool. It uses the coverage of contigs across samples and the tetranucleotide frequencies of contigs to cluster them into bins. We need to calculate the coverage of each contig first, which is done with the `jgi_summarize_bam_contig_depths` script from MetaBAT2.

```bash
cd ~/Projects/Cheese_Tuto
jgi_summarize_bam_contig_depths --outputDepth mapping/depth.tsv mapping/reads.bam

metabat2 -i metamdbg/contigs.fasta.gz -a mapping/depth.tsv -o metabat2/bin -t 16 --seed 42

seqkit stats -a metabat2/*.fa
```

Your project folder now looks like this:

```text
~/Projects/Cheese_Tuto
├── data/
├── metamdbg/
├── mapping/
│   ├── ...
│   └── depth.tsv             # new
└── metabat2/                 # new
    ├── bin.1.fa
    ├── bin.2.fa
    └── ...
```

</p>
</details>

## REMAG

[REMAG](https://github.com/danielzmbp/remag) is a tool we've developed for automated binning of eukaryotic MAGs.

### Exercise: build the REMAG command

Use the help page of REMAG to build the command yourself. It is in the `binning` environment.

```bash
remag --help
```

Your command should:

1. Use the metaMDBG assembly (`metamdbg/contigs.fasta.gz`) as input
2. Use the sorted BAM file (`mapping/reads.bam`) for coverage
3. Write the results to a folder called `remag`
4. Only bin contigs of at least 10,000 bp
5. Train the model for 20 epochs
6. Use 42 as the random seed, so that the training is reproducible
7. Use 16 threads
8. Keep the intermediate files, which we will inspect afterwards

Then check the resulting bins with `seqkit stats`, like you did for MetaBAT2.

<details><summary>Solution</summary>
<p>

```bash
cd ~/Projects/Cheese_Tuto
remag metamdbg/contigs.fasta.gz -c mapping/reads.bam -o remag --min-contig-length 10000 --epochs 20 --random-seed 42 --threads 16 -k

seqkit stats -a remag/bins/*
```

Your project folder now looks like this:

```text
~/Projects/Cheese_Tuto
├── data/
├── metamdbg/
├── mapping/
├── metabat2/
└── remag/                    # new
    ├── bins/
    │   ├── bin_0.fa
    │   └── ...
    └── ...                   # see "Inspecting REMAG output" below
```

</p>
</details>

_Run time on a 16-core VM: about 15 minutes, of which about 5 for the eukaryotic filtering._

### Download the EukCC database (in parallel)

REMAG takes about 15 minutes. In the meantime, open a second terminal on your VM and download the database for EukCC, which we will use later to check the quality of the bins.

```bash
cd ~/Projects/Cheese_Tuto
mkdir -p databases/eukccdb
cd databases/eukccdb
wget -c http://ftp.ebi.ac.uk/pub/databases/metagenomics/eukcc/eukcc2_db_ver_1.2.tar.gz
tar -xzvf eukcc2_db_ver_1.2.tar.gz
export EUKCC2_DB=$(realpath eukcc2_db_ver_1.2)
echo "export EUKCC2_DB=$EUKCC2_DB" >> ~/.bashrc
cd ../..
```

Your project folder now looks like this:

```text
~/Projects/Cheese_Tuto
├── ...
└── databases/                # new
    └── eukccdb/
        ├── eukcc2_db_ver_1.2.tar.gz
        └── eukcc2_db_ver_1.2/
```

_Run time: about 20 minutes to download and extract the 6.5 GB archive (18 GB once extracted)._

While REMAG is running, let's have a look at how it works.

![REMAG workflow](Figures/remag_fig1.jpg)

_REMAG workflow. Figure 1 from the [REMAG preprint](https://doi.org/10.64898/2026.03.05.709928)._

### Inspecting REMAG output

Because we used `-k`, REMAG kept its intermediate files. The groups below follow the steps in the figure above.

```text
remag/
├── bins/                                       # final bins, one FASTA file per bin
│   ├── bin_0.fa
│   └── bin_1.fa
├── bins.csv                                    # contig -> bin assignment
├── remag.log                                   # log of the run
├── params.json                                 # settings used for the run
│
│   # Step 1: eukaryotic filtering
├── contigs.fasta_hyenadna_classification.tsv   # eukaryote / non-eukaryote prediction per contig
├── contigs.fasta_eukaryotic_filtered.fasta     # contigs kept by the filter
│
│   # Steps 2-4: features and training
├── fragments.pkl                               # contigs and their random fragments
├── features.csv                                # k-mer frequencies and coverage per fragment
├── siamese_model.pt                            # trained neural network
├── kmer_embeddings.csv                         # output of the composition encoder per contig
├── coverage_embeddings.csv                     # output of the abundance encoder per contig
├── embeddings.csv                              # final embedding per contig (used for the UMAP below)
│
│   # Steps 5-7: markers, graph and clustering
├── temp_gene_mapping/                          # miniprot mapping of the marker genes
├── gene_contig_mappings.json                   # marker genes found on each contig
├── knn_graph_contigs.csv                       # contigs in the k-nearest neighbour graph
├── knn_graph_edges.csv                         # graph edges and their weights
├── knn_graph_stats.json                        # graph statistics
├── pre_rescue.csv                              # bin assignments before the rescue step
├── rescue_assignments.csv                      # bin assignments after the rescue step
├── core_gene_duplication_results.json          # marker summary for the final bins
│
├── training_provenance.json                    # details of the training, for reproducibility
└── clustering_provenance.json                  # details of the clustering, for reproducibility
```

From this extended output we can see several things. The filtered eukaryotic sequences are stored in `remag/contigs.fasta_eukaryotic_filtered.fasta`.

```bash
cd ~/Projects/Cheese_Tuto
seqkit stats -a remag/contigs.fasta_eukaryotic_filtered.fasta
```

We can also see a summary of the eukaryotic single-copy core genes (markers) found in each bin. REMAG maps these markers to the contigs with miniprot and uses them to guide the clustering (steps 5 and 6 in the figure above). The marker statistics for the final bins are stored in `remag/core_gene_duplication_results.json`.

```bash
cd ~/Projects/Cheese_Tuto
python -m json.tool remag/core_gene_duplication_results.json
```

> **Questions**
>
> - How many markers were found in each bin (`total_genes_found`), and how many of them are single-copy?
> - Are any markers duplicated? What could a duplicated marker indicate?
> - Some duplications are found within a single contig (`within_contig_duplications`). Can these be explained by contamination?

Finally, REMAG stores the learned embedding of each contig in `remag/embeddings.csv`. Contigs from the same genome should be close to each other in this embedding space. Below, the embeddings were projected to two dimensions with UMAP and coloured by the bin REMAG assigned them to.

![UMAP of REMAG contig embeddings](Figures/remag_umap.png)

_UMAP of the REMAG contig embeddings from an example run, coloured by bin. Point size is proportional to contig length._

> **Questions**
>
> - How well separated are the bins?
> - One bin is much more spread out than the other. What could explain that?

For comparison, here are the same contigs in the feature space MetaBAT2 uses (tetranucleotide frequencies and coverage), projected with UMAP and coloured by their REMAG bin.

![UMAP of MetaBAT2 features](Figures/metabat2_umap.png)

_UMAP of tetranucleotide frequencies and coverage for all contigs ≥2.5 kb from the same example run, zoomed in on the contigs binned by REMAG. Grey contigs were removed by REMAG's eukaryotic filter. Point size is proportional to contig length._

> **Questions**
>
> - Are the two REMAG bins also separated in the MetaBAT2 feature space?
> - Compare this plot with the REMAG embeddings above. Which one separates the genomes more clearly?
> - Compare it with your MetaBAT2 bins. Which REMAG bin did MetaBAT2 split into several bins?

## Bin quality

To assess the quality of the eukaryotic bins, we will use two tools: EukCC and BUSCO. Both look for conserved single-copy marker genes.

### EukCC

Let's start with EukCC ([GitHub](https://github.com/EBI-Metagenomics/EukCC), [documentation](https://eukcc.readthedocs.io/)). EukCC uses a set of eukaryotic single-copy core genes to assess the completeness and contamination of eukaryotic genomes. It also reports the lineage of the marker set it used for each bin (`ncbi_lng`, as NCBI taxonomy IDs), which gives a rough taxonomic placement.

We already downloaded the EukCC database while REMAG was running.

#### Run EukCC

```bash
cd ~/Projects/Cheese_Tuto
conda activate eukcc
export EUKCC2_DB=~/Projects/Cheese_Tuto/databases/eukccdb/eukcc2_db_ver_1.2
eukcc folder --threads 16 --n_combine 0 -o eukcc_metabat2 metabat2
eukcc folder --threads 16 --n_combine 0 -o eukcc_remag remag/bins
```

Your project folder now looks like this:

```text
~/Projects/Cheese_Tuto
├── ...
├── eukcc_metabat2/           # new
│   ├── eukcc.tsv
│   └── ...
└── eukcc_remag/              # new
    ├── eukcc.tsv
    └── ...
```

_Run time on a 16-core VM: about 9 minutes for the MetaBAT2 bins and 7 minutes for the REMAG bins._

> **Questions**
>
> - What does `--n_combine 0` do?

#### Results
Inspect the EukCC results. The output is a tab-separated file (`eukcc.tsv`) with the completeness and contamination estimates for each bin, including the taxonomy IDs of the reference markers used for the assessment.
```bash
cd ~/Projects/Cheese_Tuto
cat eukcc_remag/eukcc.tsv
cat eukcc_metabat2/eukcc.tsv
```

> **Questions**
>
> - Compare completeness and contamination of the REMAG and MetaBAT2 bins for each genome. Which bins would you keep?
> - What taxonomy did EukCC assign to the bins? 

### BUSCO

Let's also run BUSCO ([GitLab](https://gitlab.com/ezlab/busco), [user guide](https://busco.ezlab.org/busco_userguide.html)) on the REMAG bins and on the two largest MetaBAT2 bins. BUSCO is in the `binning` environment.

#### Exercise: run BUSCO

1. Find the two largest MetaBAT2 bins. Hint: look at the `sum_len` column of `seqkit stats`.
2. Use `busco --help` to build the commands. Each run should:
   - analyse a genome (not proteins or a transcriptome)
   - use the `eukaryota_odb10` lineage dataset
   - use 16 threads
   - have its own output name (`-o`), so the runs don't overwrite each other
3. Run BUSCO on the whole `remag/bins` folder, and separately on each of the two MetaBAT2 bins.

<details><summary>Solution</summary>
<p>

```bash
cd ~/Projects/Cheese_Tuto
conda activate binning

seqkit stats metabat2/*.fa
```

In our example run, the two largest MetaBAT2 bins were `bin.4.fa` and `bin.8.fa`. Your bin numbers may differ.

```bash
busco -i remag/bins -o busco_remag -m genome -l eukaryota_odb10 -c 16

busco -i metabat2/bin.4.fa -o busco_metabat2_bin.4 -m genome -l eukaryota_odb10 -c 16
busco -i metabat2/bin.8.fa -o busco_metabat2_bin.8 -m genome -l eukaryota_odb10 -c 16
```

Your project folder now looks like this:

```text
~/Projects/Cheese_Tuto
├── data/
├── metamdbg/
├── mapping/
├── metabat2/
├── remag/
├── busco_downloads/          # new: the eukaryota lineage dataset
├── busco_remag/              # new
│   ├── batch_summary.txt
│   ├── bin_0.fa/
│   └── ...
├── busco_metabat2_bin.4/     # new
│   ├── short_summary.specific.eukaryota_odb10.busco_metabat2_bin.4.txt
│   └── ...
└── busco_metabat2_bin.8/     # new
```

_Run time on a 16-core VM: about 3 to 5 minutes per large bin, so about 15 minutes for all three runs._

Look at the results. For a folder of bins, BUSCO writes a `batch_summary.txt`; for a single bin, a `short_summary` file.

```bash
cat busco_remag/batch_summary.txt
grep "C:" busco_metabat2_bin.*/short_summary*.txt
```

</p>
</details>

> **Questions**
>
> - How complete are the bins? How many BUSCO genes are duplicated?
> - Do the REMAG bins and the two MetaBAT2 bins give similar results?

## Comparison to references

Finally, let's identify the bins by comparing them to the reference genomes with skani ([GitHub](https://github.com/bluenote-1577/skani)). Average Nucleotide Identity (ANI) tells us which species a bin belongs to (≥95% is generally considered same species), and the aligned fractions give a reference-based estimate of completeness (`Align_fraction_ref`) and contamination (1 - `Align_fraction_query`).


### Download the references

```bash
cd ~/Projects/Cheese_Tuto
mkdir ref
cd ref

wget -c https://zenodo.org/records/23511123/files/cheese_fungal_references.fna.gz

cd ..
```

### Split the references into one file per genome
We need to split the reference fasta file into one file per genome, as skani requires a single genome per file. We will use seqkit for this.

```bash
cd ~/Projects/Cheese_Tuto
conda activate Assembly

gunzip ref/cheese_fungal_references.fna.gz

seqkit split -i --id-regexp '^([^|]+)\|' -O ref/genomes ref/cheese_fungal_references.fna

ls ref/genomes
```

Your project folder now looks like this:

```text
~/Projects/Cheese_Tuto
├── ...
└── ref/                      # new
    ├── cheese_fungal_references.fna
    └── genomes/              # one .fna file per reference genome (9 files)
```

### Run skani

```bash
cd ~/Projects/Cheese_Tuto
skani dist -t 16 -q metabat2/*.fa remag/bins/* -r ref/genomes/*.fna -o skani_bins.tsv
```

Your project folder now looks like this:

```text
~/Projects/Cheese_Tuto
├── ...
├── ref/
└── skani_bins.tsv            # new
```

### Inspect the skani results

For each bin, skani lists the references it matches, with the ANI and the aligned fractions. The last column (`Ref_name`) contains the species and strain of the reference.

```bash
cd ~/Projects/Cheese_Tuto
cut -f2-6 skani_bins.tsv | column -t -s $'\t'
```

> **Questions**
>
> - Which species did you recover? Do MetaBAT2 and REMAG agree?
> - Does any bin match more than one reference above 95% ANI? What does that tell you about these species?
> - How do the reference-based completeness and contamination compare to the EukCC and BUSCO estimates?
> - Why might a bin have a low aligned fraction even if it is not contaminated?
