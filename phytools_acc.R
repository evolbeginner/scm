library(phytools)


########################################
#auto_fsize <- function(tree, k=36){
#    fsize <- k * par()$pin[2]/par()$pin[1]/Ntip(tree)
#}

auto_fsize <- function(tree){
	fsize <- 1
	diff <- Ntip(tree) - 30
	if(diff > 0){
		fsize <- fsize + (-0.002*diff)
	}
	return(fsize)
}


auto_height <- function(tree){
	height <- 10
	diff <- Ntip(tree) - 30
	if(diff > 0){
		height <- height + 0.025*diff
	}
	return(height)
}


auto_cex <- function(tree){
	cex <- 10
	diff <- Ntip(tree) - 30
	if(diff > 0){
		cex <- cex/(0.15*diff+10) # increase the value would result in smaller pie, default 0.07
	}else{
		cex <- cex/10
	}
	return(cex)
}


########################################
# read trees as phylo or multiphylo object directly from stdin
read_tree_from_stdin <- function(skip=0){
	lines <- vector()
	count <- 0

	f <- file("stdin")
	open(f)
}

########################################
# read trees as phylo or multiphylo object directly from stdin
read_tree_from_stdin <- function(skip=0){
	lines <- vector()
	count <- 0

	f <- file("stdin")
	open(f)

	while(length(line <- readLines(f,n=1)) > 0) {
		count = count + 1
		if (count > skip){
			lines <- append(lines, line)
		}
	}
	t <- read.tree(text = as.character(lines))
}



