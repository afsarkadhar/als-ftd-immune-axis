# A8: surrogate variable analysis on the A7 set (154 ALS vs 50 control), group protected.
# Order (A8.5): estimate SVs, save diagnostics, only then fit DESeq2. Summary numbers only; no gene is looked up.
library(DESeq2)
suppressPackageStartupMessages(library(sva))
stopifnot(file.exists("PREREG.md"))

d    <- readRDS("data/processed/nygc_frontal_primary.rds")
tab  <- read.csv("results/nygc_frontal_A7_analysis_table.csv", stringsAsFactors = FALSE)
stopifnot(nrow(tab) == 204, sum(tab$group == "ALS") == 154, sum(tab$group == "control") == 50,
          all(tab$sample %in% colnames(d$counts)))
mat0 <- d$counts[, tab$sample]
cd <- data.frame(row.names = tab$sample,
                 group = factor(tab$group, levels = c("control", "ALS")),
                 platform = factor(tab$rna_platform), sex = factor(tab$sex),
                 age_at_death = tab$age_at_death, rin = tab$rin, site = factor(tab$site))
stopifnot(!anyNA(cd))

# A8.2: same filter as the A7 primary (>= 10 counts in >= 50 samples)
keep <- rowSums(mat0 >= 10) >= min(table(cd$group))
cat("Genes after filter:", sum(keep), "(the A7 primary had 19902)\n")
stopifnot(sum(keep) == 19902)
dat <- mat0[keep, ]; storage.mode(dat) <- "double"

# A8.3: models (known covariates in both, so SVs capture only what they do not explain)
mod  <- model.matrix(~ platform + sex + age_at_death + rin + site + group, data = cd)
mod0 <- model.matrix(~ platform + sex + age_at_death + rin + site, data = cd)

# A8.4: number of SVs, cap 10, set.seed(1) before every sva call
set.seed(1)
n.est <- num.sv(dat, mod, method = "be", seed = 1)
n.sv  <- min(n.est, 10)
cat("num.sv (be) estimate:", n.est, "| SVs used:", n.sv, "\n")
if (n.sv == 0) stop("num.sv returned 0: per A8.4 no sva model is fitted; report this.", call. = FALSE)

set.seed(1)
sv <- svaseq(dat, n.sv = n.sv, mod = mod, mod0 = mod0)
S <- sv$sv; colnames(S) <- paste0("SV", seq_len(n.sv)); rownames(S) <- colnames(dat)
stopifnot(identical(rownames(S), rownames(cd)))

# A8.5: diagnostics, saved before any DESeq2 run that uses the SVs
loglib <- log(colSums(mat0))
bin <- function(f) as.numeric(f == levels(f)[2])
diag <- data.frame(SV = colnames(S),
                   r_group    = sapply(seq_len(n.sv), function(k) cor(S[, k], bin(cd$group))),
                   r_platform = sapply(seq_len(n.sv), function(k) cor(S[, k], bin(cd$platform))),
                   r_sex      = sapply(seq_len(n.sv), function(k) cor(S[, k], bin(cd$sex))),
                   r_age      = sapply(seq_len(n.sv), function(k) cor(S[, k], cd$age_at_death)),
                   r_rin      = sapply(seq_len(n.sv), function(k) cor(S[, k], cd$rin)),
                   r_loglib   = sapply(seq_len(n.sv), function(k) cor(S[, k], loglib)),
                   R2_site    = sapply(seq_len(n.sv), function(k) summary(lm(S[, k] ~ cd$site))$r.squared))
diag$flag_group <- abs(diag$r_group) > 0.5
write.csv(diag, "results/nygc_frontal_A8_sva_diagnostics.csv", row.names = FALSE)
write.csv(data.frame(sample = rownames(S), S), "results/nygc_frontal_A8_svs.csv", row.names = FALSE)
cat("\nSV DIAGNOSTICS (saved before any DESeq2 fit)\n")
print(cbind(SV = diag$SV, round(diag[, -c(1, 9)], 2), flag_group = diag$flag_group), row.names = FALSE)
flagged <- diag$SV[diag$flag_group]
cat("\nSVs flagged (|r| > 0.5 with group):", if (length(flagged)) paste(flagged, collapse = ", ") else "none", "\n")

# A8.6: DESeq2 with SVs (A7 design + SVs; Wald test; control = reference)
fit_one <- function(svcols, label) {
  cdf <- cd; for (v in svcols) cdf[[v]] <- S[, v]
  f <- reformulate(c("platform", "sex", "age_at_death", "rin", "site", svcols, "group"))
  X <- model.matrix(f, cdf)
  cat("\n=== Fitting", label, "| design columns:", ncol(X), "| rank:", qr(X)$rank, "\n")
  stopifnot(qr(X)$rank == ncol(X))      # A7.6: stop if not full rank
  dds <- DESeqDataSetFromMatrix(countData = mat0[keep, ], colData = cdf, design = f)
  dds <- DESeq(dds, quiet = TRUE)
  res <- results(dds, contrast = c("group", "ALS", "control"), alpha = 0.05)
  out <- data.frame(ensembl_id = rownames(res), as.data.frame(res), row.names = NULL)
  sig <- !is.na(out$padj) & out$padj < 0.05
  s <- data.frame(model = label, n_SV = length(svcols), genes_after_filter = sum(keep),
                  genes_tested = sum(!is.na(out$pvalue)), fdr05 = sum(sig),
                  up = sum(sig & out$log2FoldChange > 0), down = sum(sig & out$log2FoldChange < 0),
                  fdr05_lfc05 = sum(sig & abs(out$log2FoldChange) >= 0.5),
                  inflation = round(median(out$stat^2, na.rm = TRUE) / 0.4549, 2),
                  cook_refit = sum(mcols(dds)$replace, na.rm = TRUE))
  write.csv(out, paste0("results/nygc_frontal_A8_sva_", label, "_deseq2_all_genes.csv"), row.names = FALSE)
  print(s, row.names = FALSE)
  s
}
summ <- list(fit_one(diag$SV, "all_SVs"))
if (length(flagged) > 0 && length(flagged) < n.sv) {
  summ[[2]] <- fit_one(setdiff(diag$SV, flagged), "without_flagged_SVs")
} else if (length(flagged) == n.sv) {
  cat("\nAll SVs are flagged; the version without them equals the A7 primary, so it is not refitted.\n")
}
all_s <- do.call(rbind, summ)
write.csv(all_s, "results/nygc_frontal_A8_sva_summary.csv", row.names = FALSE)
cat("\nA8 SUMMARY (A7 primary for comparison: 6206 FDR genes, inflation 6.24)\n"); print(all_s, row.names = FALSE)