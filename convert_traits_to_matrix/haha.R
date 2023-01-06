library(phytools)

df <- read.table("1.traits")

traits <- unique(unlist(sapply(as.vector(df$V2), strsplit, "")))

f<-function(x, traits){a=vector(); for(i in traits){if(i %in% unlist(strsplit(x,""))){a[i]=1}else{a[i]=0}}; return(a/sum(a))}

states <- t(sapply(as.vector(df$V2), f, traits))
rownames(states) <- df$V1

tree <- read.tree("1.tre")

make.simmap(tree, states)
