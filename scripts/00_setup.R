# 00_setup.R -- run at the start of every Colab session (R kernel)
# Colab forgets everything between sessions; this rebuilds the environment.

# 1. Pre-built Linux binaries from Posit Package Manager
os <- sub("VERSION_CODENAME=", "", grep("^VERSION_CODENAME=", readLines("/etc/os-release"), value = TRUE))
options(repos = c(CRAN = paste0("https://packagemanager.posit.co/cran/__linux__/", os, "/latest")))
options(HTTPUserAgent = sprintf("R/%s R (%s)", getRversion(),
        paste(getRversion(), R.version["platform"], R.version["arch"], R.version["os"])))

# 2. Remove leftover lock folders (created if an install was interrupted)
unlink(list.files(.libPaths()[1], pattern = "^00LOCK", full.names = TRUE), recursive = TRUE)

# 3. Install (clusterProfiler deliberately excluded: fails to compile; fgsea + msigdbr used instead)
install.packages(c("tidyverse", "BiocManager", "pheatmap", "msigdbr"))
BiocManager::install(c("GEOquery", "DESeq2", "limma", "edgeR", "fgsea",
                       "org.Hs.eg.db", "EnhancedVolcano", "sva"),
                     ask = FALSE, update = FALSE)

# 4. Check: all lines must print TRUE
for (p in c("tidyverse", "GEOquery", "DESeq2", "limma", "edgeR", "fgsea",
            "org.Hs.eg.db", "EnhancedVolcano", "pheatmap", "msigdbr", "sva")) {
  cat(p, ":", requireNamespace(p, quietly = TRUE), "\n")
}
