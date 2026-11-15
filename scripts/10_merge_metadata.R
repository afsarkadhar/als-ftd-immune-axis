# scripts/10_merge_metadata.R
# Amendment A7, metadata only: builds the analysis table for the NYGC frontal-cortex primary model.
# Reads:  ST1 + ST3 (spreadsheet), results/nygc_mapped_metadata.csv, results/nygc_frontal_inferred_sex.csv
# Writes: results/nygc_frontal_A7_analysis_table.csv, results/nygc_frontal_A7_exclusions.csv
# Does NOT read counts, fit any model, or open any gene-level result.
library(readxl)
stopifnot(file.exists("PREREG.md"))   # must be run from the project folder

clean <- function(x) { x <- trimws(as.character(x)); x[x %in% c("", "NA", "N/A")] <- NA; x }

# ---- 1. Read the two sheets (row 1 is a title, row 2 is the header) ----
f   <- "data/raw/NYGC_Flagship_ST_1_3_Metadata.xlsx"
st1 <- as.data.frame(read_excel(f, sheet = "ST1", skip = 1, col_types = "text"))
st3 <- as.data.frame(read_excel(f, sheet = "ST3", skip = 1, col_types = "text"))
need1 <- c("donor_id", "subject_group", "sex_call", "site_specimen_collected", "age_at_death")
need3 <- c("rna_id", "donor_id", "tissue_clean", "rin", "rna_prep", "rna_platform",
           "MEAN_READ_LENGTH", "PCT_CHIMERAS", "used_in_analysis")
stopifnot(all(need1 %in% names(st1)), all(need3 %in% names(st3)))
st1 <- st1[!is.na(st1$donor_id), ]
st3 <- st3[!is.na(st3$rna_id), ]
stopifnot(!anyDuplicated(st1$donor_id), !anyDuplicated(st3$rna_id))
cat("ST1 donors:", nrow(st1), "| ST3 RNA samples:", nrow(st3), "\n")

# ---- 2. The 210 frontal primary samples (A2/A4 definitions) ----
meta <- read.csv("results/nygc_mapped_metadata.csv", stringsAsFactors = FALSE)
sx   <- read.csv("results/nygc_frontal_inferred_sex.csv", stringsAsFactors = FALSE)
stopifnot(nrow(sx) == 210, !anyDuplicated(meta$sample))
a <- data.frame(sample = sx$sample, sex = sx$sex, stringsAsFactors = FALSE)
j <- match(a$sample, meta$sample); stopifnot(!anyNA(j))
a$geo_group    <- meta$group[j]
a$geo_platform <- meta$platform[j]
stopifnot(all(a$geo_group %in% c("ALS Spectrum MND", "Non-Neurological Control")))
a$group <- factor(ifelse(a$geo_group == "ALS Spectrum MND", "ALS", "control"),
                  levels = c("control", "ALS"))
cat("\nFrontal primary set (expect ALS 154, control 56):\n"); print(table(a$group))

# ---- 3. Link to ST3 by rna_id, then to ST1 by donor_id ----
i3 <- match(a$sample, st3$rna_id)
a$in_st3           <- !is.na(i3)
a$donor_id         <- st3$donor_id[i3]
a$st3_tissue       <- clean(st3$tissue_clean[i3])
a$rin              <- suppressWarnings(as.numeric(clean(st3$rin[i3])))
a$rna_prep         <- clean(st3$rna_prep[i3])
a$rna_platform     <- clean(st3$rna_platform[i3])
a$MEAN_READ_LENGTH <- suppressWarnings(as.numeric(clean(st3$MEAN_READ_LENGTH[i3])))
a$PCT_CHIMERAS     <- suppressWarnings(as.numeric(clean(st3$PCT_CHIMERAS[i3])))
a$used_in_analysis <- clean(st3$used_in_analysis[i3])
i1 <- match(a$donor_id, st1$donor_id)
a$in_st1       <- !is.na(i1)
a$sex_call     <- clean(st1$sex_call[i1])
a$st1_group    <- clean(st1$subject_group[i1])
a$site_raw     <- clean(st1$site_specimen_collected[i1])
a$age_raw      <- clean(st1$age_at_death[i1])
cat("\nMatched to ST3:", sum(a$in_st3), "of", nrow(a), "| matched to ST1:", sum(a$in_st1), "\n")
cat("ST3 tissue of matched samples (expect only Frontal_Cortex):\n"); print(table(a$st3_tissue, useNA = "ifany"))

# ---- 4. Agreement checks between sources (checks only; none of these changes a label) ----
cat("\nRNA-inferred sex (rows) vs ST1 sex_call (cols):\n"); print(table(a$sex, a$sex_call, useNA = "ifany"))
cat("\nGEO platform (rows) vs ST3 rna_platform (cols):\n"); print(table(a$geo_platform, a$rna_platform, useNA = "ifany"))
cat("\nGEO group (rows) vs ST1 subject_group (cols):\n"); print(table(a$geo_group, a$st1_group, useNA = "ifany"))

# ---- 5. Recode age (A7.4): "90 or older" -> 90; any other non-numeric -> missing ----
a$age_at_death <- ifelse(a$age_raw == "90 or older", 90, suppressWarnings(as.numeric(a$age_raw)))
bad_age <- a$age_raw[is.na(a$age_at_death) & !is.na(a$age_raw)]
cat("\nAge values treated as missing because non-numeric:\n"); print(table(bad_age, useNA = "ifany"))
cat("Age summary (years):\n"); print(summary(a$age_at_death))
cat("RIN summary:\n"); print(summary(a$rin))

# ---- 6. Complete cases and exclusion reasons (A7.5) ----
reason <- rep(NA_character_, nrow(a))
add <- function(cond, txt) { reason[is.na(reason) & cond] <<- txt }
add(!a$in_st3,                "not in ST3")
add(!a$in_st1,                "donor not in ST1")
add(is.na(a$rna_platform),    "missing platform")
add(is.na(a$sex),             "missing sex")
add(is.na(a$age_at_death),    "missing or non-numeric age_at_death")
add(is.na(a$rin),             "missing RIN")
add(is.na(a$site_raw),        "missing site")
a$complete <- is.na(reason)
excl <- data.frame(sample = a$sample[!a$complete], geo_group = a$geo_group[!a$complete],
                   reason = reason[!a$complete])
write.csv(excl, "results/nygc_frontal_A7_exclusions.csv", row.names = FALSE)
cat("\nExcluded from A7 models:", nrow(excl), "\n"); print(table(excl$reason, excl$geo_group))

# ---- 7. Merge sites with fewer than 5 samples into "Other" (A7.3), counted in the complete set ----
d <- a[a$complete, ]
tab   <- table(d$site_raw)
small <- names(tab)[tab < 5]
d$site <- ifelse(d$site_raw %in% small, "Other", d$site_raw)
cat("\nSites merged into Other (n < 5):", if (length(small)) paste(small, collapse = "; ") else "none", "\n")
cat("\nAnalysed set (expect ALS 154, control 50):\n"); print(table(d$group))

# ---- 8. Balance tables and design checks (A7.6) ----
cat("\nGroup x site:\n");     print(table(d$site, d$group))
cat("\nGroup x platform:\n"); print(table(d$rna_platform, d$group))
cat("\nGroup x sex:\n");      print(table(d$sex, d$group))
d$platform_f <- factor(d$rna_platform); d$sex_f <- factor(d$sex); d$site_f <- factor(d$site)
X <- model.matrix(~ platform_f + sex_f + age_at_death + rin + site_f + group, data = d)
cat("\nDesign matrix columns:", ncol(X), "| rank:", qr(X)$rank, "\n")
if (qr(X)$rank < ncol(X)) cat("STOP: design is not full rank. Per A7.6 a further amendment is needed.\n")
Xn  <- X[, colnames(X) != "(Intercept)", drop = FALSE]
vif <- sapply(seq_len(ncol(Xn)), function(k) {
  r2 <- summary(lm(Xn[, k] ~ Xn[, -k, drop = FALSE]))$r.squared; 1 / (1 - r2) })
names(vif) <- colnames(Xn)
cat("\nVariance inflation of each design column (column-wise):\n"); print(round(vif, 2))

# ---- 9. Save the analysis table (metadata only) ----
d$rin_ge_5.5 <- d$rin >= 5.5
out <- d[, c("sample", "donor_id", "group", "geo_group", "rna_platform", "sex", "age_at_death", "rin",
             "site_raw", "site", "rin_ge_5.5", "rna_prep", "MEAN_READ_LENGTH", "PCT_CHIMERAS",
             "used_in_analysis")]
write.csv(out, "results/nygc_frontal_A7_analysis_table.csv", row.names = FALSE)
cat("\nSaved results/nygc_frontal_A7_analysis_table.csv (", nrow(out), "rows ) and the exclusions file.\n")