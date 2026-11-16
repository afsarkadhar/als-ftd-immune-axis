# DESeq2, NYGC frontal cortex, C9orf72 carriers (PREREG A10, with A5.1, A7, A9).
# Carrier label (A10.1): ExpansionHunter max repeat >= 30 OR repeat-primed PCR "Yes"; else non-carrier.
# Comparisons (A10.4): C9_vs_control (27 vs 50) and C9_vs_nonC9_ALS (27 vs 127).
# Design: ~ platform + sex + age_at_death + rin + site + c9 ; reference = control / non-carrier ALS; Wald test.
# Sensitivities (A10.5): a no site; b without flag_prereg outliers; c NovaSeq-only (platform term dropped);
#   d A7 design + SV1 from results/nygc_frontal_A8_svs.csv (not re-estimated). RIN >= 5.5 is NOT run.
# Count filter (Sec. 4): >= 10 counts in >= n samples, n = smallest group IN THAT RUN (27 in both primaries).
# Full-rank check (A7.6 / A10.4): stop if not full rank, then write a further amendment.
# Summary numbers only; no gene or node is looked up here (that is script 17, after this is committed).
# Set PREFLIGHT_ONLY <- TRUE before source() to check labels, designs and counts without fitting anything.
library(DESeq2)
library(readxl)
stopifnot(file.exists("PREREG.md"))
if (!exists("PREFLIGHT_ONLY")) PREFLIGHT_ONLY <- FALSE

d    <- readRDS("data/processed/nygc_frontal_primary.rds")
mat0 <- d$counts
tab  <- read.csv("results/nygc_frontal_A7_analysis_table.csv", stringsAsFactors = FALSE)
o    <- read.csv("results/nygc_frontal_outlier_check_R.csv", stringsAsFactors = FALSE)

stopifnot(nrow(tab) == 204, !anyDuplicated(tab$sample), !anyDuplicated(tab$donor_id),
          sum(tab$group == "ALS") == 154, sum(tab$group == "control") == 50,
          all(tab$sample %in% colnames(mat0)))
stopifnot(!anyNA(tab[, c("rna_platform", "sex", "age_at_death", "rin", "site")]))
flag_ids <- o$sample[which(as.logical(o$flag_prereg))]          # pre-registered flag_A (A5.2)
stopifnot(setequal(flag_ids, c("CGND-HRA-01908", "CGND-HRA-01913", "CGND-HRA-01918")))

# ---- Carrier label (A10.1), rebuilt from flagship ST1 ----
f   <- "data/raw/NYGC_Flagship_ST_1_3_Metadata.xlsx"
st1 <- read_excel(f, sheet = "ST1", skip = 1)
stopifnot(all(c("donor_id", "c9orf72_max_call", "c9orf72_rp_pcr") %in% names(st1)))
stopifnot(sum(st1$donor_id %in% tab$donor_id) == nrow(tab))      # every donor found exactly once
i   <- match(tab$donor_id, st1$donor_id)
stopifnot(!anyNA(i))
rep_len <- suppressWarnings(as.numeric(st1$c9orf72_max_call[i]))
stopifnot(!any(is.na(rep_len) & !is.na(st1$c9orf72_max_call[i])))   # no text values
rp <- st1$c9orf72_rp_pcr[i]
tab$carrier <- (!is.na(rep_len) & rep_len >= 30) | (!is.na(rp) & rp == "Yes")
stopifnot(sum(tab$carrier & tab$group == "ALS") == 27,           # A10.2 guard
          sum(!tab$carrier & tab$group == "ALS") == 127,
          sum(tab$carrier & tab$group == "control") == 0,
          sum(tab$group == "control") == 50)
cat("Carrier label OK: ALS 27 carriers / 127 non-carriers; 50 controls, none carriers.\n")
cat("Carriers that RIN >= 5.5 would leave (A10.5, not run):", sum(tab$carrier & tab$rin >= 5.5),
    "of 27\n")

# ---- SV1 from the A8 file (not re-estimated) ----
sv  <- read.csv("results/nygc_frontal_A8_svs.csv", stringsAsFactors = FALSE)
sc  <- names(sv)[sapply(sv, function(z) is.character(z) && all(tab$sample %in% z))]
svc <- grep("^SV1$", names(sv), ignore.case = TRUE, value = TRUE)
if (length(sc) < 1 || length(svc) != 1)
  stop("Cannot find the sample column or SV1 in the A8 SV file. Columns are: ", paste(names(sv), collapse = ", "))
tab$SV1 <- sv[[svc]][match(tab$sample, sv[[sc[1]]])]
stopifnot(!anyNA(tab$SV1))

# ---- Comparisons and variants ----
comps <- list(
  list(name = "C9_vs_control",   select = function(t) t$carrier | t$group == "control"),
  list(name = "C9_vs_nonC9_ALS", select = function(t) t$group == "ALS")
)
all_rows <- function(t) rep(TRUE, nrow(t))
A7c9 <- ~ platform + sex + age_at_death + rin + site + c9
variants <- list(
  list(name = "primary",            select = all_rows, design = A7c9),
  list(name = "a_no_site",          select = all_rows, design = ~ platform + sex + age_at_death + rin + c9),
  list(name = "b_outliers_removed", select = function(t) !(t$sample %in% flag_ids), design = A7c9),
  list(name = "c_novaseq_only",     select = function(t) grepl("NovaSeq", t$rna_platform),
       design = ~ sex + age_at_death + rin + site + c9),             # platform has one level here
  list(name = "d_plus_SV1",         select = all_rows,
       design = ~ platform + sex + age_at_death + rin + site + SV1 + c9)
)
runs <- do.call(c, lapply(comps, function(cp) lapply(variants, function(v)
  list(name = paste0(cp$name, "_", v$name),
       select = function(t) cp$select(t) & v$select(t), design = v$design))))

make_cd <- function(t) {
  cd <- data.frame(row.names = t$sample,
                   c9 = factor(ifelse(t$carrier, "C9", "ref"), levels = c("ref", "C9")),
                   platform = factor(t$rna_platform), sex = factor(t$sex),
                   age_at_death = t$age_at_death, rin = t$rin, site = factor(t$site), SV1 = t$SV1)
  droplevels(cd)                                                   # empty site levels would break the rank check
}

# ---- Pre-flight: counts and full rank for every design ----
pf <- do.call(rbind, lapply(runs, function(r) {
  t <- tab[r$select(tab), ]; cd <- make_cd(t); X <- model.matrix(r$design, cd)
  data.frame(run = r$name, n_C9 = sum(cd$c9 == "C9"), n_ref = sum(cd$c9 == "ref"),
             filter_n = min(table(cd$c9)), design_cols = ncol(X), rank = qr(X)$rank)
}))
pf$full_rank <- pf$design_cols == pf$rank
cat("\nPRE-FLIGHT\n"); print(pf, row.names = FALSE)
if (!all(pf$full_rank)) stop("A design is not full rank. Per A10.4, stop and write a further amendment.")
if (PREFLIGHT_ONLY) stop("Pre-flight only: nothing was fitted.", call. = FALSE)

write.csv(tab[, c("sample", "donor_id", "group", "carrier")],
          "results/nygc_frontal_A10_carrier_labels.csv", row.names = FALSE)

# ---- Fit each run (skips runs that already have a summary file) ----
for (r in runs) {
  sfile <- paste0("results/nygc_frontal_A10_", r$name, "_summary.csv")
  if (file.exists(sfile)) { cat("\nSkipping (already done):", r$name, "\n"); next }
  cat("\n=== Running", r$name, "===\n")
  t <- tab[r$select(tab), ]; cd <- make_cd(t); m <- mat0[, t$sample]
  stopifnot(identical(colnames(m), rownames(cd)))
  keep <- rowSums(m >= 10) >= min(table(cd$c9))
  dds  <- DESeqDataSetFromMatrix(countData = m[keep, ], colData = cd, design = r$design)
  dds  <- DESeq(dds, quiet = TRUE)
  res  <- results(dds, contrast = c("c9", "C9", "ref"), alpha = 0.05)   # positive log2FC = higher in carriers
  out  <- data.frame(ensembl_id = rownames(res), as.data.frame(res), row.names = NULL)
  sig  <- !is.na(out$padj) & out$padj < 0.05
  s <- data.frame(run = r$name, n_C9 = sum(cd$c9 == "C9"), n_ref = sum(cd$c9 == "ref"),
                  genes_after_filter = sum(keep), genes_tested = sum(!is.na(out$pvalue)),
                  fdr05 = sum(sig), up = sum(sig & out$log2FoldChange > 0),
                  down = sum(sig & out$log2FoldChange < 0),
                  fdr05_lfc05 = sum(sig & abs(out$log2FoldChange) >= 0.5),
                  inflation = round(median(out$stat^2, na.rm = TRUE) / 0.4549, 2),
                  cook_refit = sum(mcols(dds)$replace, na.rm = TRUE))
  write.csv(out, paste0("results/nygc_frontal_A10_", r$name, "_deseq2_all_genes.csv"), row.names = FALSE)
  write.csv(s, sfile, row.names = FALSE)
  print(s, row.names = FALSE)
  rm(dds, res, out, m); gc()
}

# ---- Combined summary ----
files <- paste0("results/nygc_frontal_A10_", sapply(runs, `[[`, "name"), "_summary.csv")
all_s <- do.call(rbind, lapply(files, read.csv))
write.csv(all_s, "results/nygc_frontal_A10_summary.csv", row.names = FALSE)
cat("\nSUMMARY OF ALL A10 RUNS\n"); print(all_s, row.names = FALSE)