# Do the 210 frontal sample IDs match the counts file's column names exactly?
dest <- "data/raw/GSE153960_Gene_counts_matrix_RSEM_Prudencio_et_al_2020.txt.gz"

con <- gzfile(dest, "rt")
hdr <- strsplit(readLines(con, n = 1), "\t")[[1]]
close(con)
counts_cols <- hdr[-1]                      # drop the gene ID column

ids <- read.csv("results/nygc_frontal_outlier_check.csv")$sample

cat("IDs in frontal table:", length(ids), "\n")
cat("Found in counts header:", sum(ids %in% counts_cols), "\n")
cat("Not found:", sum(!ids %in% counts_cols), "\n")
if (any(!ids %in% counts_cols)) print(ids[!ids %in% counts_cols])
cat("Duplicate IDs in header:", sum(duplicated(counts_cols)), "\n")