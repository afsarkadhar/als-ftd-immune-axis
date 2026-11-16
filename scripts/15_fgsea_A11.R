# fgsea per A11: six registered sets in ten frontal models (A9 labels), specificity control (A7 primary only),
# exploratory: all 50 Hallmark sets in the A7 primary; Reactome cytosolic-DNA-sensor set in all ten models.
suppressPackageStartupMessages({ library(fgsea); library(msigdbr) })
stopifnot(file.exists("PREREG.md"))

models <- c(A7_primary = "results/nygc_frontal_A7_primary_deseq2_all_genes.csv",
            s7a_consortium  = "results/nygc_frontal_A7_sens_7a_consortium_covariates_deseq2_all_genes.csv",
            s7b_no_site     = "results/nygc_frontal_A7_sens_7b_no_site_deseq2_all_genes.csv",
            s7d_outliers    = "results/nygc_frontal_A7_sens_7d_outliers_removed_deseq2_all_genes.csv",
            s7d_novaseq     = "results/nygc_frontal_A7_sens_7d_novaseq_only_deseq2_all_genes.csv",
            s7e_rin55       = "results/nygc_frontal_A7_sens_7e_rin_ge_5p5_deseq2_all_genes.csv",
            s7f_no_discord  = "results/nygc_frontal_A7_sens_7f_drop_discordant_deseq2_all_genes.csv",
            A8_sva          = "results/nygc_frontal_A8_sva_all_SVs_deseq2_all_genes.csv",
            A5_geo_only     = "results/nygc_frontal_primary_deseq2_all_genes.csv",
            A6_composition  = "results/nygc_frontal_composition_deseq2_all_genes.csv")
stopifnot(all(file.exists(models)))
primary <- "A7_primary"
g <- read.csv("results/gene_id_map_msigdbr.csv", stringsAsFactors = FALSE)

# ---- Gene sets (A11.3) ----
reg_h <- c("HALLMARK_INTERFERON_ALPHA_RESPONSE", "HALLMARK_INTERFERON_GAMMA_RESPONSE",
           "HALLMARK_INFLAMMATORY_RESPONSE", "HALLMARK_TNFA_SIGNALING_VIA_NFKB",
           "HALLMARK_IL6_JAK_STAT3_SIGNALING")
kname <- "KEGG_CYTOSOLIC_DNA_SENSING_PATHWAY"
rname <- "REACTOME_CYTOSOLIC_SENSORS_OF_PATHOGEN_ASSOCIATED_DNA"
mname <- "KEGG_MEDICUS_REFERENCE_CGAS_STING_SIGNALING_PATHWAY"
hall <- msigdbr(species = "Homo sapiens", collection = "H")
kegg <- msigdbr(species = "Homo sapiens", collection = "C2", subcollection = "CP:KEGG_LEGACY")
rea  <- msigdbr(species = "Homo sapiens", collection = "C2", subcollection = "CP:REACTOME")
med  <- msigdbr(species = "Homo sapiens", collection = "C2", subcollection = "CP:KEGG_MEDICUS")
hall_sets <- lapply(split(hall$gene_symbol, hall$gs_name), unique)
sets6    <- c(hall_sets[reg_h], setNames(list(unique(kegg$gene_symbol[kegg$gs_name == kname])), kname))
sets_rea <- setNames(list(unique(rea$gene_symbol[rea$gs_name == rname])), rname)
set_med  <- unique(med$gene_symbol[med$gs_name == mname])
stopifnot(identical(as.integer(lengths(sets6)), c(97L, 200L, 200L, 200L, 87L, 55L)),
          length(sets_rea[[1]]) == 64, length(set_med) == 18, length(hall_sets) == 50)
short <- c("IFN_alpha", "IFN_gamma", "Inflammatory", "TNFa_NFKB", "IL6_JAK_STAT3", "KEGG_legacy_DNAsens")
names(short) <- names(sets6)

# ---- Ranking (A11.2) ----
make_stats <- function(f) {
  d <- read.csv(f, stringsAsFactors = FALSE)
  n_all <- nrow(d)
  d$id <- sub("\\.\\d+$", "", d$ensembl_id)
  d$symbol <- g$gene_symbol[match(d$id, g$ensembl_gene)]
  n_nostat <- sum(is.na(d$stat)); d <- d[!is.na(d$stat), ]
  n_unmapped <- sum(is.na(d$symbol)); d <- d[!is.na(d$symbol), ]
  d <- d[order(-d$baseMean), ]
  n_dup <- sum(duplicated(d$symbol)); d <- d[!duplicated(d$symbol), ]
  list(stats = setNames(d$stat, d$symbol),
       log = data.frame(tested_ids = n_all, no_stat = n_nostat, unmapped = n_unmapped,
                        duplicate_symbols_dropped = n_dup, ranked_genes = nrow(d)))
}
# ---- Method (A11.4): set.seed(1) before every call ----
run_fgsea <- function(paths, stats) {
  set.seed(1)
  suppressWarnings(fgseaMultilevel(pathways = paths, stats = stats, minSize = 15, maxSize = 500,
                                   scoreType = "std", BPPARAM = BiocParallel::SerialParam()))
}
le_str <- function(r, i) vapply(i, function(k) if (is.na(k)) NA_character_ else paste(r$leadingEdge[[k]], collapse = ";"), "")

stats_all <- list(); rank_log <- list(); reg <- list(); rea_tab <- list()
for (m in names(models)) {
  cat("Running", m, "...\n")
  s <- make_stats(models[[m]]); stats_all[[m]] <- s$stats; rank_log[[m]] <- cbind(model = m, s$log)
  r <- run_fgsea(sets6, s$stats)
  df <- data.frame(model = m, set = names(sets6), stringsAsFactors = FALSE)
  df$ranked_in_set <- sapply(sets6, function(x) sum(x %in% names(s$stats)))
  i <- match(df$set, r$pathway)
  df$NES <- r$NES[i]; df$pval <- r$pval[i]; df$leading_edge <- le_str(r, i)
  ok <- !is.na(df$pval); df$padj_BH6 <- NA_real_
  df$padj_BH6[ok] <- p.adjust(df$pval[ok], "BH", n = 6)                  # A11.4: family of six
  reg[[m]] <- df
  rr <- run_fgsea(sets_rea, s$stats)                                      # exploratory (A11.8b)
  j <- match(rname, rr$pathway)
  rea_tab[[m]] <- data.frame(model = m, set = rname, ranked_in_set = sum(sets_rea[[1]] %in% names(s$stats)),
                             NES = rr$NES[j], pval = rr$pval[j], leading_edge = le_str(rr, j))
}
reg <- do.call(rbind, reg); rea_tab <- do.call(rbind, rea_tab); rank_log <- do.call(rbind, rank_log)
write.csv(reg, "results/fgsea_A11_registered_long.csv", row.names = FALSE)
write.csv(rea_tab, "results/fgsea_A11_exploratory_reactome_all_models.csv", row.names = FALSE)
write.csv(rank_log, "results/fgsea_A11_gene_ranking_log.csv", row.names = FALSE)

# ---- A9 labels for the six registered sets (A11.6) ----
lab <- do.call(rbind, lapply(names(sets6), function(s) {
  p <- reg[reg$set == s & reg$model == primary, ]; oth <- reg[reg$set == s & reg$model != primary, ]
  use <- function(x) !is.na(x$NES)
  if (!use(p)) { l <- "Not testable"; why <- "fewer than 15 ranked genes in the primary" }
  else if (is.na(p$padj_BH6) || p$padj_BH6 >= 0.05) { l <- "Not significant"; why <- "" }
  else {
    flip <- oth$model[use(oth) & sign(oth$NES) != sign(p$NES)]; miss <- oth$model[!use(oth)]
    if (length(flip)) { l <- "Model-dependent"; why <- paste("direction differs in:", paste(flip, collapse = ", ")) }
    else if (length(miss)) { l <- "Not testable in a model"; why <- paste("absent in:", paste(miss, collapse = ", ")) }
    else { l <- "Robust"; why <- "" }
  }
  data.frame(set = short[[s]], primary_NES = round(p$NES, 2), primary_pval = signif(p$pval, 3),
             primary_FDR_BH6 = signif(p$padj_BH6, 3), label = l, detail = why)
}))
write.csv(lab, "results/fgsea_A11_labels.csv", row.names = FALSE)

# ---- Specificity control (A11.5): A7 primary only, 1000 random size-matched sets per tested set ----
st <- stats_all[[primary]]; gn <- names(st)
obs <- rbind(data.frame(set = names(sets6), NES = reg$NES[reg$model == primary]),
             data.frame(set = rname, NES = rea_tab$NES[rea_tab$model == primary]))
spec_sets <- c(sets6, sets_rea)
spec <- do.call(rbind, lapply(names(spec_sets), function(nm) {
  k <- sum(spec_sets[[nm]] %in% gn); o <- obs$NES[obs$set == nm]
  set.seed(1); rnd <- lapply(1:1000, function(i) sample(gn, k)); names(rnd) <- paste0("rand", 1:1000)
  rr <- run_fgsea(rnd, st); nes_r <- rr$NES[match(names(rnd), rr$pathway)]
  data.frame(set = nm, ranked_in_set = k, observed_NES = round(o, 2), random_scored = sum(!is.na(nes_r)),
             p_specificity = if (is.na(o)) NA else (1 + sum(abs(nes_r) >= abs(o), na.rm = TRUE)) / 1001)
}))
write.csv(spec, "results/fgsea_A11_specificity_primary.csv", row.names = FALSE)

# ---- Exploratory (A11.8a): all 50 Hallmark sets in the A7 primary, BH across 50 ----
hh <- run_fgsea(hall_sets, st); hh$padj_BH50 <- p.adjust(hh$pval, "BH")
hh$leading_edge <- vapply(hh$leadingEdge, paste, "", collapse = ";"); hh$leadingEdge <- NULL
hh <- hh[order(-abs(hh$NES)), ]; hh$rank_by_absNES <- seq_len(nrow(hh))
write.csv(hh, "results/fgsea_A11_exploratory_hallmark_primary.csv", row.names = FALSE)

# ---- Print ----
cat("\nRANKING LOG (A11.2):\n"); print(rank_log, row.names = FALSE)
cat("\nChecks against the numbers recorded in A11 (A7 primary):\n")
cat(" ranked genes:", length(st), "| A11 recorded tested universe 13611 ->", ifelse(length(st) == 13611, "MATCHES", "DIFFERS (tell Claude; do not edit)"), "\n")
exp_t <- c(92, 180, 160, 180, 66, 35)
got_t <- unname(reg$ranked_in_set[reg$model == primary])
cat(" ranked genes per registered set:", got_t, "| recorded:", exp_t, "->", ifelse(identical(as.numeric(got_t), exp_t), "MATCHES", "DIFFERS (tell Claude; do not edit)"), "\n")
cat(" Reactome set ranked genes:", rea_tab$ranked_in_set[rea_tab$model == primary], "| recorded: 61\n")
cat(" KEGG Medicus cGAS-STING set:", length(set_med), "genes,", sum(set_med %in% gn), "ranked in the A7 primary; minimum size 15 ->",
    ifelse(sum(set_med %in% gn) < 15, "NOT TESTABLE", "testable"), "\n")
wide <- function(col, dig) { m <- sapply(names(models), function(k) reg[[col]][reg$model == k]); rownames(m) <- short[names(sets6)]; round(m, dig) }
cat("\nNES by model (positive = higher in ALS):\n"); print(wide("NES", 2))
cat("\nFDR (BH across the six sets) by model:\n"); print(signif(wide("padj_BH6", 3), 3))
cat("\nA9 LABELS (registered sets):\n"); print(lab, row.names = FALSE)
cat("\nSPECIFICITY CONTROL (A7 primary; 1000 random size-matched sets per set):\n"); print(spec, row.names = FALSE)
cat("\nEXPLORATORY: Reactome cytosolic sensors of DNA (all ten models; no A9 label):\n")
print(data.frame(model = rea_tab$model, ranked = rea_tab$ranked_in_set, NES = round(rea_tab$NES, 2), pval = signif(rea_tab$pval, 3)), row.names = FALSE)
cat("\nEXPLORATORY: all 50 Hallmark sets in the A7 primary (BH across 50):\n")
cat(" FDR < 0.05:", sum(hh$padj_BH50 < 0.05), "of 50 | up in ALS:", sum(hh$padj_BH50 < 0.05 & hh$NES > 0),
    "| down:", sum(hh$padj_BH50 < 0.05 & hh$NES < 0), "\n")
cat(" Rank by |NES| of the five registered Hallmark sets (1 = largest):\n")
print(hh[hh$pathway %in% reg_h, c("pathway", "NES", "padj_BH50", "rank_by_absNES")], row.names = FALSE)
cat("\nDONE: tables saved in results/fgsea_A11_*.csv\n")