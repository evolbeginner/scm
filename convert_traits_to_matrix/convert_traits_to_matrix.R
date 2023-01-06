get_tip_prior <- function(x, traits){
	a=vector()
	for(i in traits){if(i %in% unlist(strsplit(x,""))){a[i]=1}else{a[i]=0}}; return(a/sum(a))
}

from_traits_to_states <- function(df){
	# traits: traits.txt formatted file
	traits <- unique(unlist(sapply(as.vector(df$V2), strsplit, "")))
	states <- t(sapply(as.vector(df$V2), get_tip_prior, traits))
	rownames(states) <- df$V1
	return(states)
}

