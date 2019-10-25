#!/usr/bin/Rscript

#load libraries
library(ggplot2)
library(ellipse)
library(getopt)
library(grid)

spec = matrix(c('verbose','v',0,"logical",'help','h',0,"logical",'cfile','c',1,"character",'pcafile','p',1,"character",'ofile','o',1,"character"),byrow=TRUE,ncol=4)

opt=getopt(spec)

# if help was asked for print a friendly message 
# and exit with a non-zero error code 
if( !is.null(opt$help)) {
	cat(getopt(spec, usage=TRUE)); 
	q(status=1);
}

clusterFile <- opt$cfile
pcaFile <- opt$pcafile


PCA <- read.csv(pcaFile,header=TRUE,row.names=1)
Clusters <- read.csv(clusterFile,header=TRUE,row.names=1)
colnames(Clusters) <- c("Cluster")

PCA.df <- data.frame(x=PCA[,1],y=PCA[,2],c=Clusters$Cluster)
PCA.df$c <- factor(PCA.df$c)

colours <- c("#F0A3FF", "#0075DC", "#993F00","#4C005C","#2BCE48","#FFCC99","#808080","#94FFB5","#8F7C00","#9DCC00","#C20088","#003380","#FFA405","#FFA8BB","#426600","#FF0010","#5EF1F2","#00998F","#740AFF","#990000","#FFFF00");

shapes <- c(15,16,17,18)

nC <- length(colours);
nS <- length(shapes);

nClust <- length(levels(PCA.df$c))

valuesC <- vector()
valuesS <- rep(16,nClust);

for(i in 1:nClust){
	valuesC[i] <- colours[i %% nC + 1] 
	valuesS[i] <- 15 + i %/% nC
}

print(valuesC);
print(valuesS);

# Order the factor levels
valuesS <- valuesS[as.integer(factor(PCA.df$c, levels = sort(unique(PCA.df$c))))]

pdf(opt$ofile)
theme_set(theme_bw(20))
head(PCA.df)
p <- ggplot(data=PCA.df, aes(x=x, y=y,colour=c)) + geom_point(size=1.0, alpha=.3) + xlab("PCA1") + ylab("PCA2") + scale_colour_manual(values=valuesC) + scale_shape_manual(values=valuesS) 

#if( !is.null(opt$legend)){ p + theme(legend.key.size = unit(0.3, "cm")) + guides(col = guide_legend(ncol = 2,override.aes = list(alpha = 1)))+ theme(legend.text=element_text(size=4));}else{p + theme(legend.position="none");}
p <- p + theme(legend.key.size = unit(0.3, "cm")) + guides(col = guide_legend(ncol = 2,override.aes = list(alpha = 1)))
plot(p)

dev.off()
