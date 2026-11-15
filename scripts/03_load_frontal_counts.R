# Load NYGC frontal-cortex counts for the A4 primary samples (154 ALS vs 56 control)
# NOTE: the raw file has an unlabelled row-number column, so data rows have one
# more field than the header. We name that column explicitly ("row_id").
library(readr)

dest <- "data/raw/GSE153960_Gene_counts_matrix_RSEM_Prudencio_et_al_2020.txt.gz"
coldata <- read.csv("results/nygc_frontal_outlier_check.csv")[, c("sample", "group", "platform", "sex")]

con <- gzfile(dest, "rt"); hdr <- strsplit(readLines(con, n = 1), "\t")[[1]]; close(con)
stopifnot(length(hdr) == 1660, hdr[1] == "EnsemblID")

raw <- read_tsv(dest, skip = 1, col_names = c("row_id", hdr),
                col_select = dplyr::all_of(c("EnsemblID", coldata$sample)),
                col_types = cols(.default = col_double(), EnsemblID = col_character()))
stopifnot(nrow(problems(raw)) == 0)

genes <- raw$EnsemblID
mat   <- as.matrix(raw[, coldata$sample])
rownames(mat) <- genes
rm(raw); gc()

cat("Dimensions (genes x samples):", dim(mat), "\n")
cat("Columns in same order as sample table:", identical(colnames(mat), coldata$sample), "\n")
cat("Gene IDs start with ENSG:", all(grepl("^ENSG", genes)), "\n")
cat("Duplicate gene IDs:", sum(duplicated(genes)), "\n")
cat("NAs:", sum(is.na(mat)), " Negatives:", sum(mat < 0), "\n")
cat("Non-integer share:", round(mean(mat != round(mat)), 3), "\n")

mat <- round(mat)                 # A3: round expected counts to integers
storage.mode(mat) <- "integer"

cat("\nGroup x platform:\n"); print(table(coldata$group, coldata$platform))
cat("Library size (millions), range:", round(range(colSums(mat)) / 1e6, 1), "\n")
cat("First gene IDs:", head(genes, 3), "\n")

saveRDS(list(counts = mat, coldata = coldata), "data/processed/nygc_frontal_primary.rds")
cat("Saved data/processed/nygc_frontal_primary.rds\n")