# A5.3: map Ensembl IDs (version suffix removed) to HGNC symbols using msigdbr's annotation.
# Checks mapping only. No expression values or fold changes are printed.
library(msigdbr)
library(dplyr)

res <- read.csv("results/nygc_frontal_primary_deseq2_all_genes.csv")
ens <- sub("\\.[0-9]+$", "", res$ensembl_id)
cat("Tested genes:", length(ens), " unique after removing versions:", length(unique(ens)), "\n")

# Annotation: gene symbols and Ensembl IDs from Hallmark + GO Biological Process sets
ann <- bind_rows(
  msigdbr(species = "Homo sapiens", collection = "H"),
  msigdbr(species = "Homo sapiens", collection = "C5", subcollection = "GO:BP"))
cat("Annotation columns:", paste(names(ann), collapse = ", "), "\n")

map <- ann %>% filter(!is.na(ensembl_gene), ensembl_gene != "") %>%
  distinct(ensembl_gene, gene_symbol)
cat("Distinct Ensembl-symbol pairs:", nrow(map), "\n")

# Coverage and ambiguity
cat("Tested genes with a symbol:", sum(ens %in% map$ensembl_gene), "of", length(ens), "\n")
amb <- map %>% dplyr::count(ensembl_gene) %>% dplyr::filter(n > 1)
cat("Ensembl IDs with >1 symbol:", nrow(amb), "\n")

# The six pre-registered nodes and the A5 marker genes: each should map to exactly one ID
wanted <- c("CGAS", "STING1", "JAK1", "JAK2", "IRF3", "TBK1",
            "RBFOX3", "SNAP25", "SYT1", "GFAP", "AQP4", "SLC1A2",
            "CX3CR1", "P2RY12", "TMEM119", "MBP", "PLP1", "MOG",
            "CLDN5", "PECAM1", "VWF")
chk <- lapply(wanted, function(s) {
  ids <- unique(map$ensembl_gene[map$gene_symbol == s])
  data.frame(symbol = s, n_ids = length(ids), ensembl = paste(ids, collapse = ";"),
             in_filtered_set = any(ids %in% ens))
})
print(do.call(rbind, chk), row.names = FALSE)

write.csv(map, "results/gene_id_map_msigdbr.csv", row.names = FALSE)
cat("\nSaved results/gene_id_map_msigdbr.csv\n")