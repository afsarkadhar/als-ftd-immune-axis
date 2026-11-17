# Node and pathway look for the two C9 comparisons (PREREG A12; A9, A10.6 and A11 settings unchanged).
# Reference model of each comparison = its "primary" run; the other four runs (a to d, A10.5) are the sensitivity set.
# Positive statistics = higher in C9 carriers. Nodes (script 14 logic) first, then pathways (script 15 logic).
suppressPackageStartupMessages({ library(fgsea); library(msigdbr) })
stopifnot(file.exists("PREREG.md"))
stopifnot(any(grepl("AMENDMENT A12", readLines("PREREG.md", warn = FALSE))))   # A12 must be in the file

comps    <- c("C9_vs_control", "C9_vs_nonC9_ALS")
variants <- c(primary = "primary", s_a_no_site = "a_no_site", s_b_outliers = "b_outliers_removed",
              s_c_novaseq = "c_novaseq_only", s_d_SV1 = "d_plus_SV1")
model_files <- function(cp) setNames(sprintf("results/nygc_frontal_A10_%s_%s_deseq2_all_genes.csv", cp, variants),
                                     names(variants))
for (cp in comps) stopifnot(all(file.exists(model_files(cp))))
reading <- c(C9_vs_control   = "contains the ALS-vs-control effect; a significant result here is 'not resolved between ALS in general and C9' (A12.4)",
             C9_vs_nonC9_ALS = "the C9-specific comparison (A12.4)")
g <- read.csv("results/gene_id_map_msigdbr.csv", stringsAsFactors = FALSE)

# =============================== NODES (A12.2, A9) ===============================
nodes    <- c("CGAS", "STING1", "JAK1", "JAK2", "IRF3", "TBK1")                 # A2.6
expected <- c(CGAS = "ENSG00000164430", STING1 = "ENSG00000184584", JAK1 = "ENSG00000162434",
              JAK2 = "ENSG00000096968", IRF3 = "ENSG00000126456", TBK1 = "ENSG00000183735")
stopifnot(all(sapply(nodes, function(s) sum(g$gene_symbol == s) == 1)))
ids <- setNames(g$ensembl_gene[match(nodes, g$gene_symbol)], nodes)
stopifnot(identical(ids, expected[nodes]))                                      # mapping check (A5.3)
role <- c(CGAS = "screen", STING1 = "screen", JAK1 = "screen", JAK2 = "screen",
          IRF3 = "expression only", TBK1 = "expression + flag (G3)")

read_nodes <- function(f, label) {
  d <- read.csv(f, stringsAsFactors = FALSE)
  d$id <- sub("\\.\\d+$", "", d$ensembl_id)
  stopifnot(!anyDuplicated(d$id))
  i <- match(ids, d$id)
  o <- data.frame(model = label, symbol = nodes, ensembl = ids, baseMean = d$baseMean[i],
                  log2FC = d$log2FoldChange[i], stat = d$stat[i], pvalue = d$pvalue[i],
                  genomewide_FDR = d$padj[i], in_table = !is.na(i))
  ok <- !is.na(o$pvalue)
  o$family_BH <- NA_real_
  o$family_BH[ok] <- p.adjust(o$pvalue[ok], "BH", n = 6)                       # family of 6 genes (A2.6)
  o
}

node_long <- list(); node_lab <- list()
for (cp in comps) {
  models <- model_files(cp)
  res <- do.call(rbind, Map(read_nodes, models, names(models)))
  res <- cbind(comparison = cp, res)
  node_long[[cp]] <- res
  lab <- do.call(rbind, lapply(nodes, function(s) {
    p   <- res[res$symbol == s & res$model == "primary", ]
    oth <- res[res$symbol == s & res$model != "primary", ]
    usable <- function(x) !is.na(x$stat)
    if (!usable(p)) { l <- "Not testable"; why <- "removed by the count filter or no Wald statistic in the primary" }
    else if (is.na(p$family_BH) || p$family_BH >= 0.05) { l <- "Not significant"; why <- "" }
    else {
      flip <- oth$model[usable(oth) & sign(oth$stat) != sign(p$stat)]
      miss <- oth$model[!usable(oth)]
      if (length(flip)) { l <- "Model-dependent"; why <- paste("direction differs in:", paste(flip, collapse = ", ")) }
      else if (length(miss)) { l <- "Not testable in a model"; why <- paste("absent in:", paste(miss, collapse = ", ")) }
      else { l <- "Robust"; why <- "" }
    }
    data.frame(comparison = cp, symbol = s, role = role[[s]], primary_stat = round(p$stat, 2),
               primary_log2FC = round(p$log2FC, 3), primary_genomewide_FDR = signif(p$genomewide_FDR, 3),
               primary_family_BH = signif(p$family_BH, 3), label = l, detail = why, reading = reading[[cp]])
  }))
  node_lab[[cp]] <- lab
}
write.csv(do.call(rbind, node_long), "results/nodes_A12_C9_all_models_long.csv", row.names = FALSE)
write.csv(do.call(rbind, node_lab),  "results/nodes_A12_C9_labels.csv", row.names = FALSE)

wide_n <- function(res, v, dig) { m <- sapply(unique(res$model), function(k) res[[v]][res$model == k])
rownames(m) <- nodes; round(m, dig) }
for (cp in comps) {
  res <- node_long[[cp]]
  cat("\n\n================ NODES:", cp, "(positive = higher in C9 carriers) ================\n")
  cat("Reading:", reading[[cp]], "\n")
  cat("\nWald statistic by model:\n");                 print(wide_n(res, "stat", 2))
  cat("\nlog2 fold change by model:\n");               print(wide_n(res, "log2FC", 3))
  cat("\nSix-gene family BH p-value by model:\n");     print(signif(wide_n(res, "family_BH", 3), 3))
  cat("\nGenome-wide FDR by model:\n");                print(signif(wide_n(res, "genomewide_FDR", 3), 3))
  cat("\nA9 LABELS:\n"); print(node_lab[[cp]][, c("symbol", "role", "primary_stat", "primary_log2FC",
                                                  "primary_genomewide_FDR", "primary_family_BH", "label", "detail")],
                               row.names = FALSE)
}

# ============================ PATHWAYS (A12.3, A11) ============================
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
          length(sets_rea[[1]]) == 64, length(set_med) == 18, length(hall_sets) == 50)   # same sets as A11
short <- c("IFN_alpha", "IFN_gamma", "Inflammatory", "TNFa_NFKB", "IL6_JAK_STAT3", "KEGG_legacy_DNAsens")
names(short) <- names(sets6)

make_stats <- function(f) {                                                    # A11.2
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
run_fgsea <- function(paths, stats) {                                          # A11.4; seed before every call
  set.seed(1)
  suppressWarnings(fgseaMultilevel(pathways = paths, stats = stats, minSize = 15, maxSize = 500,
                                   scoreType = "std", BPPARAM = BiocParallel::SerialParam()))
}
le_str <- function(r, i) vapply(i, function(k) if (is.na(k)) NA_character_ else paste(r$leadingEdge[[k]], collapse = ";"), "")

reg_all <- list(); rea_all <- list(); log_all <- list(); lab_all <- list(); spec_all <- list()
for (cp in comps) {
  models <- model_files(cp); stats_cp <- list(); reg <- list(); rea_tab <- list(); rlog <- list()
  for (m in names(models)) {
    cat("Running", cp, m, "...\n")
    s <- make_stats(models[[m]]); stats_cp[[m]] <- s$stats; rlog[[m]] <- cbind(comparison = cp, model = m, s$log)
    r <- run_fgsea(sets6, s$stats)
    df <- data.frame(comparison = cp, model = m, set = names(sets6), stringsAsFactors = FALSE)
    df$ranked_in_set <- sapply(sets6, function(x) sum(x %in% names(s$stats)))
    i <- match(df$set, r$pathway)
    df$NES <- r$NES[i]; df$pval <- r$pval[i]; df$leading_edge <- le_str(r, i)
    ok <- !is.na(df$pval); df$padj_BH6 <- NA_real_
    df$padj_BH6[ok] <- p.adjust(df$pval[ok], "BH", n = 6)                      # family of six within the model
    reg[[m]] <- df
    rr <- run_fgsea(sets_rea, s$stats); j <- match(rname, rr$pathway)           # exploratory, all models, no label
    rea_tab[[m]] <- data.frame(comparison = cp, model = m, set = rname,
                               ranked_in_set = sum(sets_rea[[1]] %in% names(s$stats)),
                               NES = rr$NES[j], pval = rr$pval[j], leading_edge = le_str(rr, j))
  }
  reg <- do.call(rbind, reg); rea_tab <- do.call(rbind, rea_tab)
  reg_all[[cp]] <- reg; rea_all[[cp]] <- rea_tab; log_all[[cp]] <- do.call(rbind, rlog)
  
  lab <- do.call(rbind, lapply(names(sets6), function(s) {                     # A9 labels (A11.6), registered sets only
    p <- reg[reg$set == s & reg$model == "primary", ]; oth <- reg[reg$set == s & reg$model != "primary", ]
    use <- function(x) !is.na(x$NES)
    if (!use(p)) { l <- "Not testable"; why <- "fewer than 15 ranked genes in the primary" }
    else if (is.na(p$padj_BH6) || p$padj_BH6 >= 0.05) { l <- "Not significant"; why <- "" }
    else {
      flip <- oth$model[use(oth) & sign(oth$NES) != sign(p$NES)]; miss <- oth$model[!use(oth)]
      if (length(flip)) { l <- "Model-dependent"; why <- paste("direction differs in:", paste(flip, collapse = ", ")) }
      else if (length(miss)) { l <- "Not testable in a model"; why <- paste("absent in:", paste(miss, collapse = ", ")) }
      else { l <- "Robust"; why <- "" }
    }
    data.frame(comparison = cp, set = short[[s]], primary_NES = round(p$NES, 2), primary_pval = signif(p$pval, 3),
               primary_FDR_BH6 = signif(p$padj_BH6, 3), label = l, detail = why, reading = reading[[cp]])
  }))
  lab_all[[cp]] <- lab
  
  st <- stats_cp[["primary"]]; gn <- names(st)                                 # specificity control (A11.5): primary only
  obs <- rbind(data.frame(set = names(sets6), NES = reg$NES[reg$model == "primary"]),
               data.frame(set = rname, NES = rea_tab$NES[rea_tab$model == "primary"]))
  spec_sets <- c(sets6, sets_rea)
  spec_all[[cp]] <- do.call(rbind, lapply(names(spec_sets), function(nm) {
    k <- sum(spec_sets[[nm]] %in% gn); o <- obs$NES[obs$set == nm]
    set.seed(1); rnd <- lapply(1:1000, function(i) sample(gn, k)); names(rnd) <- paste0("rand", 1:1000)
    rr <- run_fgsea(rnd, st); nes_r <- rr$NES[match(names(rnd), rr$pathway)]
    data.frame(comparison = cp, set = nm, ranked_in_set = k, observed_NES = round(o, 2),
               random_scored = sum(!is.na(nes_r)),
               p_specificity = if (is.na(o)) NA else (1 + sum(abs(nes_r) >= abs(o), na.rm = TRUE)) / 1001)
  }))
}
write.csv(do.call(rbind, reg_all),  "results/fgsea_A12_C9_registered_long.csv", row.names = FALSE)
write.csv(do.call(rbind, rea_all),  "results/fgsea_A12_C9_exploratory_reactome_all_models.csv", row.names = FALSE)
write.csv(do.call(rbind, log_all),  "results/fgsea_A12_C9_gene_ranking_log.csv", row.names = FALSE)
write.csv(do.call(rbind, lab_all),  "results/fgsea_A12_C9_labels.csv", row.names = FALSE)
write.csv(do.call(rbind, spec_all), "results/fgsea_A12_C9_specificity_primary.csv", row.names = FALSE)

cat("\n\nRANKING LOG (A11.2):\n"); print(do.call(rbind, log_all), row.names = FALSE)
cat("\nKEGG Medicus cGAS-STING set (18 genes): minimum size 15 ->",
    ifelse(sum(set_med %in% names(make_stats(model_files("C9_vs_control")[["primary"]])$stats)) < 15,
           "NOT TESTABLE (as in A11)", "testable"), "\n")
for (cp in comps) {
  reg <- reg_all[[cp]]
  wide_p <- function(col, dig) { m <- sapply(names(variants), function(k) reg[[col]][reg$model == k])
  rownames(m) <- short[names(sets6)]; round(m, dig) }
  cat("\n\n================ PATHWAYS:", cp, "(positive NES = higher in C9 carriers) ================\n")
  cat("\nNES by model:\n");                              print(wide_p("NES", 2))
  cat("\nFDR (BH across the six sets) by model:\n");     print(signif(wide_p("padj_BH6", 3), 3))
  cat("\nA9 LABELS (registered sets):\n");               print(lab_all[[cp]][, -ncol(lab_all[[cp]])], row.names = FALSE)
  cat("\nSPECIFICITY CONTROL (primary; 1000 random size-matched sets per set):\n"); print(spec_all[[cp]], row.names = FALSE)
  cat("\nEXPLORATORY: Reactome cytosolic sensors (all five models; no A9 label):\n")
  print(data.frame(model = rea_all[[cp]]$model, ranked = rea_all[[cp]]$ranked_in_set,
                   NES = round(rea_all[[cp]]$NES, 2), pval = signif(rea_all[[cp]]$pval, 3)), row.names = FALSE)
}
cat("\nDONE: tables saved in results/nodes_A12_C9_*.csv and results/fgsea_A12_C9_*.csv\n")