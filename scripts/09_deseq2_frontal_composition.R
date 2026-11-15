# Composition-adjusted DESeq2, NYGC frontal primary (A5.4, A6). Saves the full table.
# No individual gene is printed.
library(DESeq2)
library(dplyr)

d   <- readRDS("data/processed/nygc_frontal_primary.rds")
mat <- d$counts; cd <- d$coldata
cd$group    <- factor(cd$group, levels = c("Non-Neurological Control", "ALS Spectrum MND"))
cd$platform <- factor(cd$platform); cd$sex <- factor(cd$sex)
rownames(cd) <- cd$sample
stopifnot(identical(colnames(mat), rownames(cd)))

keep <- rowSums(mat >= 10) >= min(table(cd$group))
map  <- read.csv("results/gene_id_map_msigdbr.csv")
sets <- list(neuron = c("RBFOX3", "SNAP25", "SYT1"), astrocyte = c("GFAP", "AQP4", "SLC1A2"),
             microglia = c("CX3CR1", "P2RY12", "TMEM119"), oligodendrocyte = c("MBP", "PLP1", "MOG"))

# Blind VST for marker scores (A5.4)
dds0 <- DESeqDataSetFromMatrix(mat[keep, ], colData = cd, design = ~ 1)
vsd  <- assay(vst(dds0, blind = TRUE))
rownames(vsd) <- sub("\\.[0-9]+$", "", rownames(vsd))

score <- sapply(sets, function(g) {
  ids <- unique(map$ensembl_gene[map$gene_symbol %in% g])
  stopifnot(length(ids) == length(g), all(ids %in% rownames(vsd)))
  colMeans(vsd[ids, , drop = FALSE])
})
pc <- prcomp(score, center = TRUE, scale. = TRUE)
cat("Variance explained by composition PCs:", round(summary(pc)$importance[2, ], 3), "\n")
cd$compPC1 <- pc$x[, 1]; cd$compPC2 <- pc$x[, 2]; cd$compPC3 <- pc$x[, 3]

dds <- DESeqDataSetFromMatrix(mat[keep, ], colData = cd,
                              design = ~ platform + sex + compPC1 + compPC2 + compPC3 + group)
dds <- DESeq(dds)
cat("Coefficients:", resultsNames(dds), "\n")

res <- results(dds, contrast = c("group", "ALS Spectrum MND", "Non-Neurological Control"), alpha = 0.05)
out <- data.frame(ensembl_id = rownames(res), as.data.frame(res), row.names = NULL)
sig <- !is.na(out$padj) & out$padj < 0.05
cat("FDR < 0.05:", sum(sig), " (up:", sum(sig & out$log2FoldChange > 0),
    " down:", sum(sig & out$log2FoldChange < 0), ")\n")
cat("FDR < 0.05 and |log2FC| >= 0.5:", sum(sig & abs(out$log2FoldChange) >= 0.5), "\n")
cat("Genomic inflation:", round(median(out$stat^2, na.rm = TRUE) / 0.4549, 2), "\n")

write.csv(out, "results/nygc_frontal_composition_deseq2_all_genes.csv", row.names = FALSE)
write.csv(cd[, c("sample", "compPC1", "compPC2", "compPC3")], "results/nygc_frontal_composition_covariates.csv", row.names = FALSE)
cat("Saved.\n")