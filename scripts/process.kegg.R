#!/usr/bin/env Rscript



# get command line arguments as an array
# should be:
# args[1] - the KEGG counts table
# args[2] - the ko_names table
# args[3] - output stub
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

# load XLSX library
options(java.parameters = "- Xmx2048m")
suppressMessages(library(xlsx))


fx <- paste(args[3], ".xlsx", sep="")

# read in the data table
d <- read.table(fn, header=TRUE, sep="\t")
d[is.na(d)] <- 0

colnames(d)[1] <- "KO"

colnames(d) <- gsub("kocounts.", "S_", colnames(d))
colnames(d) <- gsub(".out", "", colnames(d))

d <- d[, sort(colnames(d))]

# make a copy
td <- d

# read in gene names
gn <- read.table(args[2], sep="\t", quote="", comment.char="")
colnames(gn) <- c("KO","ID","GENE","DESC")

# join counts and names
td <- merge(td, gn, by="KO", all.x=TRUE, sort=FALSE)

# order by first counts column
td <- td[order(td[,2], decreasing=TRUE),]

# re-order columns
ncols <- ncol(td)
ctscols <- 2:(ncols-3)
td <- td[,c(1,ncols-2,ncols-1,ncols,ctscols)]

# write out table
write.table(td, paste(args[3], ".counts.txt", sep=""), row.names=FALSE, col.names=TRUE, sep="\t", quote=FALSE)
write.xlsx(x = td, file = fx,
        sheetName = "kegg.counts", row.names = TRUE)


# calculate proportions
cs <- colSums(d[2:ncol(d)])

# take a copy and calculate
tp <- d
for (i in 2:ncol(tp)) {
        tp[,i] <- tp[,i] / cs[i-1] * 100
}

# join with gene names
tp <- merge(tp, gn, by="KO", all.x=TRUE, sort=FALSE)

# order by first counts column
tp <- tp[order(tp[,2], decreasing=TRUE),]

# re-order columns
ncols <- ncol(tp)
ctscols <- 2:(ncols-3)
tp <- tp[,c(1,ncols-2,ncols-1,ncols,ctscols)]

# write out table
write.table(tp, paste(args[3], ".percentage.txt", sep=""), row.names=FALSE, col.names=TRUE, sep="\t", quote=FALSE)
write.xlsx(x = tp, file = fx,
        sheetName = "kegg.percentage", row.names = TRUE, append=TRUE)


