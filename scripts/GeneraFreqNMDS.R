library(vegan)
library(ggplot2)
library(grid)
library(plyr)

ClusterK <- read.csv("GeneraKraken.csv",header=TRUE,row.names=1)
ClusterK <- t(ClusterK)
ClusterP <- ClusterK/rowSums(ClusterK)
Meta <- read.csv("~/Data/InfantGut/Meta.csv",header=TRUE,row.names=1)

ClusterP <- ClusterP[rownames(Meta),]
ClusterP.nmds <- metaMDS(ClusterP)


nmds_df<-scores(ClusterP.nmds,display=c("sites"))

nmds_df<-data.frame(nmds_df)

meta_nmds.df <- data.frame(x=nmds_df$NMDS1,y=nmds_df$NMDS2,Day=Meta$Day)


p<-ggplot(data=meta_nmds.df,aes(x,y,colour=Day,group=1)) + geom_point() 

png("GeneraNMDS.png")
plot(p + geom_path(arrow=arrow(length=unit(0.3,"cm")),alpha=0.5) + theme_bw())
dev.off()
