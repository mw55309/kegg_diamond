#!/usr/bin/env Rscript

# get command line arguments as an array
args <- commandArgs(trailingOnly = TRUE)

# if we don't have any command line arguments
# print out usage
if (length(args) == 0) {
        stop("Please provide a file as the first (and only) argument")
}

# the first argument is the file, stop if it doesn't exist
fn <- args[1]
if (! file.exists(fn)) {
        stop(paste(fn, " does not exist"))
}

options( java.parameters = "-Xmx8g" )
suppressMessages(library(xlsx))

fx <- gsub(".txt",".xlsx", fn)

d <- read.table(fn, header=TRUE, sep="\t", row.names=1)
d <- d[,-1]

d[is.na(d)] <- 0

d <- d[sort(rownames(d)),]
td <- t(d)

td <- td[order(td[,1], decreasing=TRUE),]

library(xlsx)
write.xlsx(x = td, file = fx,
        sheetName = "kraken.counts", row.names = TRUE)


cs <- colSums(td)

tp <- td
for (i in 1:ncol(tp)) {
	tp[,i] <- tp[,i] / cs[i] * 100
}

write.xlsx(x = tp, file = fx,
        sheetName = "kraken.proportions", row.names = TRUE, append=TRUE)

