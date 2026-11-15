# Design check for NYGC frontal primary (PREREG A2/A4): ~ platform + sex + group
# No model is fitted and no gene-level result is looked at.
library(DESeq2)

d   <- readRDS("data/processed/nygc_frontal_primary.rds")
cd  <- d$coldata
mat <- d$counts

cd$group    <- factor(cd$group, levels = c("Non-Neurological Control", "ALS Spectrum MND"))  # control = reference
cd$platform <- factor(cd$platform)
cd$sex      <- factor(cd$sex)
rownames(cd) <- cd$sample

cat("Levels of group (first = reference):", levels(cd$group), "\n\n")

cat("Group x platform:\n");  print(table(cd$group, cd$platform))
cat("\nGroup x sex:\n");     print(table(cd$group, cd$sex))
cat("\nPlatform x sex:\n");  print(table(cd$platform, cd$sex))

# Is group associated with platform / sex? (descriptive; small p = imbalance to be aware of)
cat("\nFisher p, group vs platform:", signif(fisher.test(table(cd$group, cd$platform))$p.value, 3), "\n")
cat("Fisher p, group vs sex:     ", signif(fisher.test(table(cd$group, cd$sex))$p.value, 3), "\n")

# Design matrix: full rank?
mm <- model.matrix(~ platform + sex + group, data = cd)
cat("\nDesign matrix columns:", colnames(mm), "\n")
cat("Rank:", qr(mm)$rank, "of", ncol(mm), "columns -> full rank:", qr(mm)$rank == ncol(mm), "\n")

# Pre-registered gene filter: >=10 counts in >= smallest group size (56)
keep <- rowSums(mat >= 10) >= min(table(cd$group))
cat("\nGenes passing filter:", sum(keep), "of", nrow(mat), "\n")
cat("Samples:", ncol(mat), " (", sum(cd$group == "ALS Spectrum MND"), "ALS /",
    sum(cd$group == "Non-Neurological Control"), "controls )\n")