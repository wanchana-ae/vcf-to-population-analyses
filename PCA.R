#if (!require("BiocManager", quietly = TRUE))
#  install.packages("BiocManager")
#BiocManager::install("SNPRelate")

library("ggplot2")
library("SNPRelate")
library("ggrepel")

vcf.fn<-"snp_filter.sort.vcf"
snpgdsVCF2GDS(vcf.fn, "ccm.gds",  method="biallelic.only")
genofile <- openfn.gds("ccm.gds")
pca<-snpgdsPCA(genofile,autosome.only=FALSE)
pc.percent <- pca$varprop*100
head(round(pc.percent, 2)) #check Percent PC
tab <- data.frame(sample.id = pca$sample.id,
                  EV1 = pca$eigenvect[,1],    # the first eigenvector
                  EV2 = pca$eigenvect[,2],    # the second eigenvector
                  stringsAsFactors = FALSE)
head(tab)
plot(tab$EV2, tab$EV1, xlab="eigenvector 2", ylab="eigenvector 1")
write.csv(tab,"PCA.csv")
##########
theme_set(theme_bw())
options(ggrepel.max.overlaps = Inf) #For label overlaps

gg<-ggplot(tab,aes(x=EV1,y=EV2))+
  geom_point(size=2,shape=16,col="blue")+
  labs(subtitle="", 
       x= paste("PC1:",sprintf("%.2f%%",pc.percent[1])),
       y= paste("PC2:",sprintf("%.2f%%",pc.percent[2])),
       title="Principal Component Analysis (PCA)")
plot(gg)
gg + geom_label_repel(aes(label = sample.id),
                      box.padding   = 0.1, 
                      point.padding = 0.1,
                      segment.color = 'grey50')
