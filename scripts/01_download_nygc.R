# Download the NYGC RSEM gene counts matrix (GSE153960) into data/raw/
# data/raw/ is gitignored: the file itself is never committed.
url  <- paste0("https://ftp.ncbi.nlm.nih.gov/geo/series/GSE153nnn/GSE153960/suppl/",
               "GSE153960_Gene_counts_matrix_RSEM_Prudencio_et_al_2020.txt.gz")
dest <- "data/raw/GSE153960_Gene_counts_matrix_RSEM_Prudencio_et_al_2020.txt.gz"

options(timeout = 3600)
if (!file.exists(dest)) {
  download.file(url, dest, mode = "wb")
} else {
  cat("Already downloaded, skipping.\n")
}

# Check 1: file size
cat("Size (MB):", round(file.size(dest) / 1e6, 1), "\n")

# Check 2: read the header line only (not the whole file)
con <- gzfile(dest, "rt")
hdr <- readLines(con, n = 1)
close(con)
cols <- strsplit(hdr, "\t")[[1]]
cat("Columns in header:", length(cols), "\n")
cat("First 3 header entries:", head(cols, 3), "\n")