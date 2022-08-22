library(readr)
library(dplyr)
library(stringr)

#localisation donnees entree
dirin<-"Y:/ANALYSES/results/bwa_isbp/"
setwd(dirin)

genome=c("arianaLrFor", "CDC_Landmark", "CDC_Stanley", "Jagger", "Julius", "LongReach_Lancer",
         "Mace", "Norin61", "SY_Mattis", "spelta")
Genome=c("Arina LrFor", "CDC Landmark", "CDC Stanley", "Jagger", "Julius", "LongReach Lancer",
         "Mace", "Norin 61", "SY Mattis", "PI190962")

D=list()
for (g in 1:length(genome)){
  print(genome[g])
  
  d=read_tsv(paste(dirin, "ISBPS_RENAN_PSEUDOV2_vs_", genome[g], "_input_dotplot.txt", sep=""), col_names=F)
  names(d)<-c("isbp", "chrom_RENAN_v2.0", "start_RENAN_v2.0", "chrom", "start")

  d=d%>%mutate(subgenome=str_extract(chrom_RENAN_v2.0, "[:upper:]"),
             chrom_RENAN_v2.0=gsub("chr", "", chrom_RENAN_v2.0))

  d=data.frame(d)
  D[[g]]=d
}
  #######################################################################
for (g in 1:length(genome)){
  d=D[[g]]
  
  pdf(paste(dirin, "dotplot_isbp_RENAN_v2.0_vs_", genome[g], "_1page_v.pdf", sep=""), width =8, height =16)
  par(mfrow=c(7,3),mar=c(1,0.5,0.5,0), oma=c(2,2,0,0), pty="s", pin=c(2.15,2.15))
  
  chrom=unique(d$chrom_RENAN_v2.0)
  
     for (j in 1:length(chrom)){
        print(chrom[j])
    
        plot(d[d$chrom_RENAN_v2.0==chrom[j],"start_RENAN_v2.0"],
            d[d$chrom_RENAN_v2.0==chrom[j],"start"],
            pch=46, frame.plot=F, xlab="", ylab="", yaxt="n", xaxt="n", asp=1, xlim=c(0,800000000), ylim=c(0,800000000))
        axis(1, at=seq(0, 800000000, by=200000000), labels=F, pos=0)
        text(seq(0, 800000000, by=200000000), 0, labels=c("0","200","400","600","800"),
           cex=0.8, par("usr")[3]-0.2, pos=1, xpd=T)
        axis(2, at=seq(0, 800000000, by=200000000), labels=F, pos=0)
        text(0,seq(0, 800000000, by=200000000), labels=c("0","200","400","600","800"),
          cex=0.8, par("usr")[1]-0.2, pos=2, xpd=T)
        text(75000000, 780000000, labels=chrom[j], cex=1.5)
  }
  mtext("Renan chromosomes (Mb)",1, line=0.5, outer=T)
  mtext(paste(genome[g], "chromosomes (Mb)"),2, line=0, outer=T)
dev.off()
}

#######################################################################
pdf("dotplot_isbp_RENAN_v2.0_vs_10GENOMES_1chrom_per_page.pdf", width = 14.5, height = 5.5)
par(mfrow=c(2,5),mar=c(0.5,1,0.5,0), oma=c(2,2,0,0), pty="s", pin=c(2.25,2.25), mgp=c(1.2,0,0))

for (j in 1:length(chrom)){
  print(chrom[j])
  for (g in 1:length(genome)){
    d1=D[[g]]
    
    if (genome[g]=="arianaLrFor" || genome[g]=="LongReach_Lancer"){
      plot(d1[d1$chrom_RENAN_v2.0==chrom[j],"start_RENAN_v2.0"],
          d1[d1$chrom_RENAN_v2.0==chrom[j],"start"],
          pch=46, frame.plot=F, xlab="", ylab=chrom[j], cex.lab=1.4, yaxt="n", xaxt="n", asp=1, xlim=c(0,800000000), ylim=c(0,800000000))
      axis(1, at=seq(0, 800000000, by=200000000), labels=F, pos=0)
      text(seq(0, 800000000, by=200000000), 0, labels=c("0","200","400","600","800"),
          cex=0.8, par("usr")[3]-0.2, pos=1, xpd=T)
      axis(2, at=seq(0, 800000000, by=200000000), labels=F, pos=0)
      text(0,seq(0, 800000000, by=200000000), labels=c("0","200","400","600","800"),
          cex=0.8, par("usr")[1]-0.2, pos=2, xpd=T)
      text(250000000, 780000000, labels=Genome[g], cex=1.3)
    }
    else {
      plot(d1[d1$chrom_RENAN_v2.0==chrom[j],"start_RENAN_v2.0"],
           d1[d1$chrom_RENAN_v2.0==chrom[j],"start"],
           pch=46, frame.plot=F, xlab="", ylab="", yaxt="n", xaxt="n", asp=1, xlim=c(0,800000000), ylim=c(0,800000000))
      axis(1, at=seq(0, 800000000, by=200000000), labels=F, pos=0)
      text(seq(0, 800000000, by=200000000), 0, labels=c("0","200","400","600","800"),
           cex=0.8, par("usr")[3]-0.2, pos=1, xpd=T)
      axis(2, at=seq(0, 800000000, by=200000000), labels=F, pos=0)
      text(0,seq(0, 800000000, by=200000000), labels=c("0","200","400","600","800"),
           cex=0.8, par("usr")[1]-0.2, pos=2, xpd=T)
      text(250000000, 780000000, labels=Genome[g], cex=1.3)
      
    }
  }
  mtext(paste("Renan chromosome", chrom[j], "(Mb)"), 1, line=0, cex=1.1, outer=T)
}
dev.off()
