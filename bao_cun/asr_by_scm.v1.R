#! /bin/env Rscript


# v1
# many tests to ensure that the make.simmap func works correctly


################################################
#options(warn=-1)
suppressMessages(library(phytools))

library(ape)
library(phytools)
library(getopt)


################################################
node_names = list()
treefile = NULL
statefile = NULL
nsim <- 1000
model <- "ARD"


################################################
command=matrix(c( 
	'help', 'h', 0, 'loical',
	'nsim', 'nsim', 2, 'integer',
	'model', 'm', 2, 'character',
	'node', 'n', 2, 'character',
	'tree', 't', 2, 'character',
	'state', 's', 2, 'character'
	), byrow=T, ncol=4
)
args=getopt(command)

if(! is.null(args$nsim)){
	nsim = args$nsim
}
if(! is.null(args$model)){
	model = args$model
}
if(! is.null(args[['node']])){
	node_strings <- strsplit(args$node, ',')[[1]] # c("a_b", "a_d")
	node_names <- sapply(node_strings, strsplit, split='_')
}
if(! is.null(args$tree)){
	treefile <- args$tree
}
if(! is.null(args$state)){
	statefile <- args$state
}


################################################
getEdgeTrait <- function(x, m){
	#x: edge
	names(m$maps[[x]])[1]
}

detectEdge<-function(tree, node){
	which(t$edge[,1] == node)[1]
}

f<-function(m, edges){
	#traits.named <- c(m$maps[[edge]], m$maps[[6]])
	traits <- sapply(edges, getEdgeTrait, m=m)
	traits <- paste(traits, collapse='_')
	return(traits)
}


################################################
t <- read.tree(treefile)
states.df <- read.table(statefile)
states <- as.character(states.df$V2)
names(states) <- states.df$V1

#states <- c("1", "1", "2")
#states = sim.character(t, pars=c(0.1,0.2), x0=0, model="mk2"); write.table(states, "rphylo.states", sep="\t", quote=F)
#t <- rphylo(50, 1, 0)
#states <- rbinom(t$Nnode+1, 1, 0.8); names(states) <- t$tip.label

nodes <- sapply(node_names, getMRCA, phy=t)
print(nodes)

edges <- sapply(nodes, detectEdge, tree=t)

ans <- ace(states, t, type='discrete', model=model, marginal=T)
#ans <- rerootingMethod(t, states, model=model)
#ans <- fitMk(t, states, model="ARD")
#print(ans$rates); print(ans$lik.anc)
#print(c(ans$lik.anc[nodes[1]-t$Nnode-1,], ans$lik.anc[nodes[2]-t$Nnode-1,]))
print(nodes[1]-t$Nnode-1)
#print(c(ans$marginal.anc[nodes[1]-t$Nnode-1,], ans$marginal.anc[nodes[2]-t$Nnode-1,]))


################################################
mtrees <- make.simmap(t, states, model=model, nsim=nsim, Q='empirical') #, use.empirical=T, burnin=1000, samplefreq=2)

summary(mtrees)$ace


################################################
print(edges)
table(sapply(mtrees, f, edges=edges))


