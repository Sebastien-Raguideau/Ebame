#!/usr/bin/env bash

rm /home/ubuntu/Datasets
rm /home/ubuntu/Datasets

mkdir -p /home/ubuntu/Datasets && cd /home/ubuntu/Datasets

# BINNING + STRONG
curl -LJO "https://biosphere-s3.france-bioinformatique.fr/public/ebame/metagenomics-QR/AD_small.tar.gz" && tar -xvf AD_small.tar.gz && rm AD_small.tar.gz
curl -LJO "https://biosphere-s3.france-bioinformatique.fr/public/ebame/metagenomics-QR/rpsblast_cog_db.tar.gz" && tar -xvf rpsblast_cog_db.tar.gz && rpsblast_cog_db.tar.gz

# LONGREAD Gaetan
curl -LJO "https://biosphere-s3.france-bioinformatique.fr/public/ebame/metagenomics-QR/SRR13128014_subreads.fastq.gz"
curl -LJO "https://biosphere-s3.france-bioinformatique.fr/public/ebame/metagenomics-QR/SRR17913199_1.fastq.gz"
curl -LJO "https://biosphere-s3.france-bioinformatique.fr/public/ebame/metagenomics-QR/SRR17913200_1.fastq.gz"

# LONGREAD rob tut
curl -LJO "https://biosphere-s3.france-bioinformatique.fr/public/ebame/metagenomics-QR/GutMock1.fastq.gz"
curl -LJO "https://biosphere-s3.france-bioinformatique.fr/public/ebame/metagenomics-QR/fast5_subset.tar.gz"


