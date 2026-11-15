# DESeq2, NYGC frontal primary (PREREG Sec. 4, A2, A4, A5).
# Design: ~ platform + sex + group; control = reference; Wald test; filter >=10 counts in >=56 samples.
# Saves the full results table. No candidate gene is looked up here.
library(DESeq2)

d   <- readRDS("data/processed/nygc_frontal_primary.rds")
mat <- d$counts
cd  <- d$coldata
cd$group    <- factor(cd$group, levels = c("Non-Neurological Control", "ALS Spectrum MND"))
cd$platform <- factor(cd$platform)
cd$sex      <- factor(cd$sex)
rownames(cd) <- cd$sample
stopifnot(identical(colnames(mat), rownames(cd)))

keep <- rowSums(mat >= 10) >= min(table(cd$group))
cat("Genes after filter:", sum(keep), "\n")

dds <- DESeqDataSetFromMatrix(countData = mat[keep, ], colData = cd,
                              design = ~ platform + sex + group)
dds <- DESeq(dds)                       # this is the slow step (several minutes)

cat("\nCoefficients:", resultsNames(dds), "\n")
cat("Size factor range:", round(range(sizeFactors(dds)), 2), "\n")

res <- results(dds, contrast = c("group", "ALS Spectrum MND", "Non-Neurological Control"),
               alpha = 0.05)
out <- data.frame(ensembl_id = rownames(res), as.data.frame(res), row.names = NULL)

# Summary only (no individual genes)
sig <- !is.na(out$padj) & out$padj < 0.05
cat("\nGenes tested (non-NA p):", sum(!is.na(out$pvalue)), "\n")
cat("FDR < 0.05:", sum(sig), "  (up in ALS:", sum(sig & out$log2FoldChange > 0),
    " down:", sum(sig & out$log2FoldChange < 0), ")\n")
cat("FDR < 0.05 and |log2FC| >= 0.5:", sum(sig & abs(out$log2FoldChange) >= 0.5), "\n")
cat("Genomic inflation (median Wald^2 / 0.4549):",
    round(median(out$stat^2, na.rm = TRUE) / 0.4549, 2), "\n")

write.csv(out, "results/nygc_frontal_primary_deseq2_all_genes.csv", row.names = FALSE)
saveRDS(dds, "data/processed/nygc_frontal_primary_dds.rds")
cat("\nSaved results/nygc_frontal_primary_deseq2_all_genes.csv\n")