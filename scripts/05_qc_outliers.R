# QC: apply the pre-registered outlier rule (PREREG Sec. 3) in R, frontal primary set.
# Rule: sample is flagged if |z| > 3 on PC1 or PC2, z computed within its group.
# PCA settings reproduce the saved Colab run: blind VST, top 500 variable genes, unscaled.
# QC only: no group comparison and no candidate-gene look-up happens here.
library(DESeq2)
library(matrixStats)

d   <- readRDS("data/processed/nygc_frontal_primary.rds")
mat <- d$counts
cd  <- d$coldata

keep <- rowSums(mat >= 10) >= 56            # >=10 counts in >= smallest group (56)
dds  <- DESeqDataSetFromMatrix(mat[keep, ],
                               colData = data.frame(row.names = cd$sample, group = factor(cd$group)),
                               design = ~ 1)
X   <- assay(vst(dds, blind = TRUE))
top <- order(rowVars(X), decreasing = TRUE)[1:500]
p   <- prcomp(t(X[top, ]), scale. = FALSE)

zfun <- function(x) (x - mean(x)) / sd(x)
qc <- data.frame(sample = cd$sample, group = cd$group, platform = cd$platform, sex = cd$sex,
                 PC1 = p$x[, 1], PC2 = p$x[, 2])
qc$zPC1 <- ave(qc$PC1, qc$group, FUN = zfun)
qc$zPC2 <- ave(qc$PC2, qc$group, FUN = zfun)
qc$flag_prereg <- abs(qc$zPC1) > 3 | abs(qc$zPC2) > 3

# Compare with the saved Colab result (flag_A = the pre-registered rule)
saved <- read.csv("results/nygc_frontal_outlier_check.csv")
saved <- saved[match(qc$sample, saved$sample), ]
cat("Flagged in R:", sum(qc$flag_prereg), "\n")
print(qc$sample[qc$flag_prereg])
cat("Same set as saved flag_A:", identical(qc$flag_prereg, saved$flag_A), "\n")
cat("|cor| PC1:", round(abs(cor(qc$PC1, saved$PC1)), 6),
    " PC2:", round(abs(cor(qc$PC2, saved$PC2)), 6), "\n")

write.csv(qc, "results/nygc_frontal_outlier_check_R.csv", row.names = FALSE)
cat("Saved results/nygc_frontal_outlier_check_R.csv\n")