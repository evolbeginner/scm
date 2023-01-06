#! /bin/env Rscript


###################################
# remove newick-formatted trees with a semicolon
remove_bad_nwk <- function(file){
	lines <- readLines(file)
	lines[-grepl(';', lines)]
}


