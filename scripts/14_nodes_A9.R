# Six-node look across the A7 primary and nine other frontal models, labelled by the A9 rule.
# Node IDs come from the msigdbr map (script 08); version suffixes are stripped (A5.3).
stopifnot(file.exists("PREREG.md"))

nodes    <- c("CGAS", "STING1", "JAK1", "JAK2", "IRF3", "TBK1")        # A2.6
expected <- c(CGAS = "ENSG00000164430", STING1 = "ENSG00000184584", JAK1 = "ENSG00000162434",
              JAK2 = "ENSG00000096968", IRF3 = "ENSG00000126456", TBK1 = "ENSG00000183735")
g <- read.csv("results/gene_id_map_msigdbr.csv", stringsAsFactors = FALSE)
stopifnot(all(sapply(nodes, function(s) sum(g$gene_symbol == s) == 1)))
ids <- setNames(g$ensembl_gene[match(nodes, g$gene_symbol)], nodes)
stopifnot(identical(ids, expected[nodes]))                               # mapping check (A5.3)
role <- c(CGAS = "screen", STING1 = "screen", JAK1 = "screen", JAK2 = "screen",
          IRF3 = "expression only", TBK1 = "expression + flag (G3)")

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
  o$family_BH[ok] <- p.adjust(o$pvalue[ok], "BH", n = 6)                 # A2.6: family of 6 genes
  o
}
res <- do.call(rbind, Map(read_nodes, models, names(models)))
write.csv(res, "results/nodes_A9_all_models_long.csv", row.names = FALSE)

# ---- A9 labels (A9.3 to A9.5) ----
lab <- do.call(rbind, lapply(nodes, function(s) {
  p <- res[res$symbol == s & res$model == "A7_primary", ]
  oth <- res[res$symbol == s & res$model != "A7_primary", ]
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
  data.frame(symbol = s, role = role[[s]], primary_stat = round(p$stat, 2), primary_log2FC = round(p$log2FC, 3),
             primary_genomewide_FDR = signif(p$genomewide_FDR, 3), primary_family_BH = signif(p$family_BH, 3),
             label = l, detail = why)
}))
write.csv(lab, "results/nodes_A9_labels.csv", row.names = FALSE)

# ---- Print ----
wide <- function(v, dig) { m <- sapply(names(models), function(k) res[[v]][res$model == k]); rownames(m) <- nodes; round(m, dig) }
cat("MAPPING (checked):\n"); print(ids)
cat("\nWald statistic by model (positive = higher in ALS than control):\n"); print(wide("stat", 2))
cat("\nlog2 fold change by model:\n"); print(wide("log2FC", 3))
cat("\nSix-gene family BH p-value by model (A2.6):\n"); print(signif(wide("family_BH", 3), 3))
cat("\nGenome-wide FDR by model:\n"); print(signif(wide("genomewide_FDR", 3), 3))
cat("\nA9 LABELS:\n"); print(lab, row.names = FALSE)