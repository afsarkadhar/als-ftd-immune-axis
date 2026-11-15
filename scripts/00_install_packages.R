# Install packages for the ALS-FTD immune-axis analysis
options(repos = c(CRAN = "https://cloud.r-project.org"))

if (!requireNamespace("BiocManager", quietly = TRUE)) install.packages("BiocManager")

cran_pkgs <- c("data.table", "dplyr", "readr", "ggplot2", "msigdbr")
bioc_pkgs <- c("DESeq2", "fgsea", "sva", "limma")

install.packages(setdiff(cran_pkgs, rownames(installed.packages())))
BiocManager::install(setdiff(bioc_pkgs, rownames(installed.packages())),
                     update = FALSE, ask = FALSE)

# Check everything loads, then record exact versions
for (p in c(cran_pkgs, bioc_pkgs)) {
  library(p, character.only = TRUE)
  cat(p, as.character(packageVersion(p)), "\n")
}
writeLines(capture.output(sessionInfo()), "docs/session_info.txt")