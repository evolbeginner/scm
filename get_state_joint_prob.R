#! /bin/env Rscript


##############################
library(getopt)
library(parallel)
library(phytools)
library(this.path)

DIR <- dirname(this.path())
source(paste(DIR, "phytools_acc.R", sep='/'))


##############################
treefile <- NULL
constraint_file <- NULL
skip <- 0
cpu <- 2


##############################
command = matrix(c( 
	'tree', 't', 2, 'character',
	'constraint', 'c', 2, 'character',
	'skip', 's', 2, 'integer',
	'cpu', '', 2, 'integer' 
	), ncol=4, byrow=T
)

args=getopt(command)

if(! is.null(args$constraint)){
	constraint_file <- args$constraint
}else{
	stop("constraint file not given! Exiting")
}

if(! is.null(args$tree)){
	treefile <- args$tree
}else{
	stop("tree file not given! Exiting")
}

if(! is.null(args$skip)){
	skip <- args$skip
}


##############################
if(treefile == '-'){
	trees <- read_tree_from_stdin(skip=skip)
}else if(file.exists(treefile)){
	trees <- read.tree(treefile, skip=skip)
}else{
	stop(past("treefile", treefile, "does not exist! Exiting ......"))
}

df <- read.table(constraint_file)
constraint_tips <- t(as.matrix(df))


##############################
get_mcra_of_tips <- function(tree){
	nodes <- sapply(1:ncol(constraint_tips), FUN=function(x){findMRCA(tree, tips=constraint_tips[,x])} )
}


#table(sapply(trees, function(x){get_mcra_of_tips(x)}))
#a <- sapply(trees, function(t){nodes <- get_mcra_of_tips(t);
a <- mclapply(trees, function(t){nodes <- get_mcra_of_tips(t);
			traits <- sapply(nodes, FUN=function(x){t$node.label[x-t$Nnode-1]});
			paste(traits, collapse='_')
		}, mc.cores=cpu
	)

table(unlist(a))

#table(sapply(trees, function(x){paste(x$node.label[4], x$node.label[12])}))


