
# Assembly
rule create megahit_files:
    output: R1 = "{path}/R1.csv",
            R2 = "{path}/R2.csv"
    params: data = "/home/ubuntu/data/public/teachdata/ebame-2022/metagenomics/Quince_datasets/AD_small"
    shell:"""
        ls {params.data}/*/*R1.fastq | tr "\n" "," | sed 's/,$//' > {output.R1}
        ls {params.data}/*/*R2.fastq | tr "\n" "," | sed 's/,$//' > {output.R2}
         """

rule megahit:
    input: R1 = "{path}/R1.csv",
           R2 = "{path}/R2.csv"
    output: "{path}/Assembly/final.contigs.fa"
    params: "{path}/Assembly"
    threads: 50
    shell: "rm -r {params} && megahit -1 $(<{input.R1}) -2 $(<{input.R1}) -t {threads} -o {params}"

# Read mapping
rule index_assembly:
    input: "{path}/final.contigs.fa"
    output: "{path}/index.done"
    shell:"""
          bwa index {input}
          touch {output}
          """

rule map_reads:
    input: R1 = "/home/ubuntu/data/public/teachdata/ebame-2022/metagenomics/Quince_datasets/AD_small/{sample}/{sample}_R1.fastq",
           R2 = "/home/ubuntu/data/public/teachdata/ebame-2022/metagenomics/Quince_datasets/AD_small/{sample}/{sample}_R1.fastq",
           index = "{path}/Assembly/index.done",
           assembly = "{path}/Assembly/final.contigs.fa"
    output: "{path}/Map/{sample}.mapped.sorted.bam"
    threads: 4
    shell: "bwa mem -t {threads} {input.assembly} {input.R1} {input.R2} | samtools view -b -F 4 - | samtools sort - > {output}"

# coverage

import glob 
from os.path import basename,dirname

# create a string variable to store path
DATA="/home/ubuntu/data/public/teachdata/ebame-2022/metagenomics/Quince_datasets/AD_small"
# use the glob function to find all R1.fastq file in each folder of DATA
# then only keep the directory name wich is also the sample name
SAMPLES = [basename(dirname(file)) for file in glob.glob("%s/*/*_R1.fastq"%DATA)]

rule generate_coverage:
    input: expand("{{path}}/Map/{sample}.mapped.sorted.bam",sample=SAMPLES)
    output: "{path}/Binning/depth.txt"
    shell: "jgi_summarize_bam_contig_depths --outputDepth {output} {input}"

# binning
rule metabat2:
    input: asmbl = "{path}/Assembly/final.contigs.fa",
           cov = "{path}/Binning/depth.txt"
    params: "{path}/Binning/Bins/Bin"
    output: "{path}/Binning/metabat2.done"
    threads: 4
    shell: "metabat2 -i {input.asmbl} -a {input.cov} -t {threads} -o {params} && touch {output}"





