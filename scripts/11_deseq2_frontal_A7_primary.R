# DESeq2, NYGC frontal A7 primary (PREREG Sec. 4, A5.1, A7, A7b).
# Design: ~ platform + sex + age_at_death + rin + site + group; control = reference; Wald test.
# Count filter (Sec. 4): >=10 counts in >= n samples, n = smallest group size (50 in this set).
# Reads the metadata table built by scripts/10_merge_metadata.R. Saves the full results table;
# prints summary numbers only. No candidate gene is looked up here.
library(DESeq2)
stopifnot(file.exists("PREREG.md"))   # run from the project folder

d   <- readRDS("data/processed/nygc_frontal_primary.rds")
mat <- d$counts
tab <- read.csv("results/nygc_frontal_A7_analysis_table.csv", stringsAsFactors = FALSE)

# Guards: this must be exactly the A7 analysed set (A7.3, A7.5)
stopifnot(nrow(tab) == 204, !anyDuplicated(tab$sample), all(tab$sample %in% colnames(mat)))
stopifnot(sum(tab$group == "ALS") == 154, sum(tab$group == "control") == 50)

mat <- mat[, tab$sample]
cd <- data.frame(row.names = tab$sample,
                 group        = factor(tab$group, levels = c("control", "ALS")),
                 platform     = factor(tab$rna_platform),
                 sex          = factor(tab$sex),
                 age_at_death = tab$age_at_death,
                 rin          = tab$rin,
                 site         = factor(tab$site))
stopifnot(identical(colnames(mat), rownames(cd)), !anyNA(cd))

design <- ~ platform + sex + age_at_death + rin + site + group
X <- model.matrix(design, cd)
cat("Design columns:", ncol(X), "| rank:", qr(X)$rank, "\n")
stopifnot(qr(X)$rank == ncol(X))      # A7.6: stop if not full rank

keep <- rowSums(mat >= 10) >= min(table(cd$group))
cat("Genes after filter:", sum(keep), "of", nrow(mat), "\n")

dds <- DESeqDataSetFromMatrix(countData = mat[keep, ], colData = cd, design = design)
dds <- DESeq(dds)                     # slow step: expect 10 to 30 minutes

cat("\nCoefficients:", resultsNames(dds), "\n")
cat("Size factor range:", round(range(sizeFactors(dds)), 2), "\n")
cat("Genes refit after Cook's outlier handling:", sum(mcols(dds)$replace, na.rm = TRUE), "\n")

res <- results(dds, contrast = c("group", "ALS", "control"), alpha = 0.05)
out <- data.frame(ensembl_id = rownames(res), as.data.frame(res), row.names = NULL)

# Summary only (no individual genes)
sig <- !is.na(out$padj) & out$padj < 0.05
cat("\nGenes tested (non-NA p):", sum(!is.na(out$pvalue)), "\n")
cat("FDR < 0.05:", sum(sig), "  (up in ALS:", sum(sig & out$log2FoldChange > 0),
    " down:", sum(sig & out$log2FoldChange < 0), ")\n")
cat("FDR < 0.05 and |log2FC| >= 0.5:", sum(sig & abs(out$log2FoldChange) >= 0.5), "\n")
cat("Genomic inflation (median Wald^2 / 0.4549):",
    round(median(out$stat^2, na.rm = TRUE) / 0.4549, 2), "\n")

write.csv(out, "results/nygc_frontal_A7_primary_deseq2_all_genes.csv", row.names = FALSE)
saveRDS(dds, "data/processed/nygc_frontal_A7_primary_dds.rds")
cat("\nSaved results/nygc_frontal_A7_primary_deseq2_all_genes.csv\n")