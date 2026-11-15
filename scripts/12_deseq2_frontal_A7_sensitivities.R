# Pre-specified sensitivities to the A7 primary (PREREG A7.7 and A7b). Summary numbers only; no gene is looked up.
# Set PREFLIGHT_ONLY <- TRUE before source() to check designs and counts without fitting anything.
library(DESeq2)
stopifnot(file.exists("PREREG.md"))
if (!exists("PREFLIGHT_ONLY")) PREFLIGHT_ONLY <- FALSE

d    <- readRDS("data/processed/nygc_frontal_primary.rds")
mat0 <- d$counts
tab  <- read.csv("results/nygc_frontal_A7_analysis_table.csv", stringsAsFactors = FALSE)
o    <- read.csv("results/nygc_frontal_outlier_check_R.csv", stringsAsFactors = FALSE)

stopifnot(nrow(tab) == 204, sum(tab$group == "ALS") == 154, sum(tab$group == "control") == 50,
          all(tab$sample %in% colnames(mat0)))
stopifnot(!anyNA(tab[, c("rna_platform", "rna_prep", "sex", "age_at_death", "rin", "site",
                         "MEAN_READ_LENGTH", "PCT_CHIMERAS")]))
flag_ids <- o$sample[which(as.logical(o$flag_prereg))]          # pre-registered flag_A (A5.2)
stopifnot(setequal(flag_ids, c("CGND-HRA-01908", "CGND-HRA-01913", "CGND-HRA-01918")))
discordant <- c("CGND-HRA-02161", "CGND-HRA-02168")             # A7b
stopifnot(all(discordant %in% tab$sample))

A7 <- ~ platform + sex + age_at_death + rin + site + group
runs <- list(
  list(name = "7a_consortium_covariates", select = function(t) rep(TRUE, nrow(t)),
       design = ~ prep + MEAN_READ_LENGTH + PCT_CHIMERAS + group,
       scale = c("MEAN_READ_LENGTH", "PCT_CHIMERAS")),   # centred and scaled: same model, better numerical conditioning
  list(name = "7b_no_site", select = function(t) rep(TRUE, nrow(t)),
       design = ~ platform + sex + age_at_death + rin + group),
  list(name = "7d_outliers_removed", select = function(t) !(t$sample %in% flag_ids), design = A7),
  list(name = "7d_novaseq_only", select = function(t) grepl("NovaSeq", t$rna_platform),
       design = ~ sex + age_at_death + rin + site + group),   # platform has one level here
  list(name = "7e_rin_ge_5p5", select = function(t) t$rin >= 5.5, design = A7),
  list(name = "7f_drop_discordant", select = function(t) !(t$sample %in% discordant), design = A7)
)

make_cd <- function(t, r) {
  cd <- data.frame(row.names = t$sample,
                   group = factor(t$group, levels = c("control", "ALS")),
                   platform = factor(t$rna_platform), prep = factor(t$rna_prep), sex = factor(t$sex),
                   age_at_death = t$age_at_death, rin = t$rin, site = factor(t$site),
                   MEAN_READ_LENGTH = t$MEAN_READ_LENGTH, PCT_CHIMERAS = t$PCT_CHIMERAS)
  cd <- droplevels(cd)
  for (v in r$scale) cd[[v]] <- as.numeric(scale(cd[[v]]))
  cd
}

# ---- Pre-flight: counts and full rank for every design (A7.6) ----
pf <- do.call(rbind, lapply(runs, function(r) {
  t <- tab[r$select(tab), ]; cd <- make_cd(t, r); X <- model.matrix(r$design, cd)
  data.frame(run = r$name, n_ALS = sum(cd$group == "ALS"), n_control = sum(cd$group == "control"),
             filter_n = min(table(cd$group)), design_cols = ncol(X), rank = qr(X)$rank)
}))
pf$full_rank <- pf$design_cols == pf$rank
cat("PRE-FLIGHT\n"); print(pf, row.names = FALSE)
if (!all(pf$full_rank)) stop("A design is not full rank. Per A7.6, stop and write a further amendment.")
if (PREFLIGHT_ONLY) stop("Pre-flight only: nothing was fitted.", call. = FALSE)

# ---- Fit each run (skips runs that already have a summary file) ----
for (r in runs) {
  sfile <- paste0("results/nygc_frontal_A7_sens_", r$name, "_summary.csv")
  if (file.exists(sfile)) { cat("\nSkipping (already done):", r$name, "\n"); next }
  cat("\n=== Running", r$name, "===\n")
  t <- tab[r$select(tab), ]; cd <- make_cd(t, r); m <- mat0[, t$sample]
  stopifnot(identical(colnames(m), rownames(cd)))
  keep <- rowSums(m >= 10) >= min(table(cd$group))
  dds  <- DESeqDataSetFromMatrix(countData = m[keep, ], colData = cd, design = r$design)
  dds  <- DESeq(dds, quiet = TRUE)
  res  <- results(dds, contrast = c("group", "ALS", "control"), alpha = 0.05)
  out  <- data.frame(ensembl_id = rownames(res), as.data.frame(res), row.names = NULL)
  sig  <- !is.na(out$padj) & out$padj < 0.05
  s <- data.frame(run = r$name, n_ALS = sum(cd$group == "ALS"), n_control = sum(cd$group == "control"),
                  genes_after_filter = sum(keep), genes_tested = sum(!is.na(out$pvalue)),
                  fdr05 = sum(sig), up = sum(sig & out$log2FoldChange > 0),
                  down = sum(sig & out$log2FoldChange < 0),
                  fdr05_lfc05 = sum(sig & abs(out$log2FoldChange) >= 0.5),
                  inflation = round(median(out$stat^2, na.rm = TRUE) / 0.4549, 2),
                  cook_refit = sum(mcols(dds)$replace, na.rm = TRUE))
  write.csv(out, paste0("results/nygc_frontal_A7_sens_", r$name, "_deseq2_all_genes.csv"), row.names = FALSE)
  write.csv(s, sfile, row.names = FALSE)
  print(s, row.names = FALSE)
  rm(dds, res, out, m); gc()
}

# ---- Combined summary ----
files <- paste0("results/nygc_frontal_A7_sens_", sapply(runs, `[[`, "name"), "_summary.csv")
all_s <- do.call(rbind, lapply(files, read.csv))
write.csv(all_s, "results/nygc_frontal_A7_sensitivity_summary.csv", row.names = FALSE)
cat("\nSUMMARY OF ALL SENSITIVITY RUNS\n"); print(all_s, row.names = FALSE)