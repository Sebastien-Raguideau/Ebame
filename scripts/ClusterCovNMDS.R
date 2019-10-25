library(vegan)
library(ggplot2)
library(grid)
library(plyr)

ClusterK <- read.csv("clustering_gt1000_covR.csv",header=TRUE,row.names=1)
ClusterK <- t(ClusterK)
ClusterP <- ClusterK/rowSums(ClusterK)
Meta <- read.table("~/Data/InfantGut/sharon_mappingR.txt",sep='\t',header=TRUE)
rownames(Meta) <- Meta$Sample


#SRR492183       74-1/1      15a     900 sample1

ClusterP <- ClusterP[rownames(Meta),]
ClusterP.nmds <- metaMDS(ClusterP)


nmds_df<-scores(ClusterP.nmds,display=c("sites"))

nmds_df<-data.frame(nmds_df)

meta_nmds.df <- data.frame(x=nmds_df$NMDS1,y=nmds_df$NMDS2,Day=Meta$Day)


p<-ggplot(data=meta_nmds.df,aes(x,y,colour=Day,group=123)) + geom_point() 

pdf("ClusterNMDS.pdf")
plot(p + geom_path(arrow=arrow(length=unit(0.3,"cm")),alpha=0.5) + theme_bw())
dev.off()
