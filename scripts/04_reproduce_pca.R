# Does the new R pipeline reproduce the saved Colab PCA (frontal, 210 samples)?
# QC only: no group comparison is run here.
library(DESeq2)
library(matrixStats)

d   <- readRDS("data/processed/nygc_frontal_primary.rds")
mat <- d$counts
cd  <- d$coldata

saved <- read.csv("results/nygc_frontal_outlier_check.csv")
saved <- saved[match(cd$sample, saved$sample), ]
stopifnot(identical(saved$sample, cd$sample))

# Gene filter from the pre-registration: >=10 counts in >= n samples, n = smallest group (56)
keep <- rowSums(mat >= 10) >= 56
cat("Genes kept:", sum(keep), "of", nrow(mat), "\n")
m <- mat[keep, ]

dds <- DESeqDataSetFromMatrix(
  countData = m,
  colData   = data.frame(row.names = cd$sample, group = factor(cd$group), platform = factor(cd$platform)),
  design    = ~ 1)
vst_mat  <- assay(vst(dds, blind = TRUE))
lcpm_mat <- log2(t(t(m) / colSums(m) * 1e6) + 1)

res <- NULL
for (norm in c("vst", "log2CPM")) {
  X <- if (norm == "vst") vst_mat else lcpm_mat
  v <- rowVars(X)
  for (n in c(500, 1000, 2000, 5000, nrow(X))) {
    top <- order(v, decreasing = TRUE)[seq_len(n)]
    for (sc in c(FALSE, TRUE)) {
      p <- prcomp(t(X[top, ]), scale. = sc)
      res <- rbind(res, data.frame(norm = norm, top_genes = n, scaled = sc,
                                   abs_cor_PC1 = round(abs(cor(p$x[, 1], saved$PC1)), 4),
                                   abs_cor_PC2 = round(abs(cor(p$x[, 2], saved$PC2)), 4)))
    }
  }
}
print(res, row.names = FALSE)