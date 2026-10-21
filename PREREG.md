# PRE-REGISTRATION v1 (written before any differential-expression results were viewed)
Date: 2026-10-20 | Author: afsarkadhar
Project: Cell-type-aware, transcriptomics-guided structure-based prioritization of
brain-penetrant repurposed and natural-product modulators of the cGAS-STING axis
in C9orf72-associated ALS/FTD.
## 1. Question and hypothesis
Q: Is the innate-immune programme (interferon / cGAS-STING / JAK-STAT) up-regulated in
C9orf72 ALS/FTD brain, in which cell type, and which druggable node is best supported?
H1: Interferon-response and cGAS-STING-related genes are up-regulated in C9 vs control
and in C9 vs sporadic ALS brain tissue. H0: no difference.
## 2. Candidate nodes (fixed now)
Screening candidates: CGAS, STING1 (TMEM173), JAK1, JAK2.
Expression-only: IRF3.
TBK1: expression + genetics + safety flag; excluded from the primary screen.
No node may be added after seeing results except via a dated amendment labelled exploratory.
## 3. Data and selection rules
Discovery: GSE153960 (NYGC ALS Consortium bulk RNA-seq).
Groups (C9 / sporadic ALS / control) and region are defined from sample metadata only.
Region rule: primary analysis uses the single cortical region with the largest number of
C9 cases + controls after QC; other regions are secondary replication.
Independent dataset: chosen after the metadata audit and must pass a donor-overlap check.
If none is demonstrably independent, all claims are labelled "single-cohort".
Outliers: samples >3 SD from the within-group PC1/PC2 centroid are flagged; the analysis
is run with and without them and both are reported.
## 4. Differential expression
Tool: DESeq2 on raw counts. Filter: >=10 counts in at least n samples, n = smallest group size.
Design: ~ covariates + group. Covariates: age at death, sex, RIN, batch/site/platform where
present (a covariate missing in >20% of samples is dropped and noted).
Comparisons: primary C9 vs control; secondary C9 vs sporadic ALS; tertiary sporadic vs control.
Significance: BH FDR < 0.05. Gene lists passed downstream: FDR < 0.05 and |log2FC| >= 0.5.
Sensitivity: repeat with surrogate cell-composition covariates (neuron / astrocyte /
microglia marker-score PCs) and report both.
## 5. Pathway tests
fgsea on the DESeq2 Wald statistic. Sets: MSigDB Hallmark INTERFERON_ALPHA_RESPONSE,
INTERFERON_GAMMA_RESPONSE, INFLAMMATORY_RESPONSE, TNFA_SIGNALING_VIA_NFKB,
IL6_JAK_STAT3_SIGNALING, plus KEGG cytosolic DNA-sensing (hsa04623). FDR < 0.05 across
tested sets. Specificity control: 1000 size-matched random gene sets per tested set
(replaces the earlier plan for a separate non-immune module).
## 6. Cell-type layer
Published single-nucleus DE tables (C9-ALS / C9-FTD, motor and frontal cortex) are used as
supportive evidence only, because donor numbers are small.
## 7. Network layer
Input: primary-comparison DEGs. STRING experimental + curated-database channels only
(text-mining excluded), confidence >= 0.7. Proximity tested against 1000 degree-matched
random sets. Signature reversal (L2S2 / iLINCS) is supporting evidence only.
## 8. Genetic layer
MR + colocalization for the candidate nodes only (ALS GWAS; brain and blood cis-eQTL).
FTD is exploratory. Weak or absent instruments and null results are reported, not dropped.
## 9. Gates for node selection
G1: FDR < 0.05 and up in C9 vs control in discovery, and same direction (nominal p < 0.05)
    in an independent dataset (or labelled single-cohort).
G2: Human, ligand-bound experimental structure with a defined pocket.
G3 (flag): haploinsufficiency genes (TBK1) need written justification and are not in the
    primary screen.
G4: Docking validation: redocked RMSD <= 2 A and actives-vs-decoys AUC >= 0.7.
## 10. Scoring (nodes passing gates)
Effect size + replication 25 | Cell-type relevance 15 | Structural tractability 25 |
Reference inhibitors available 10 | Independent genetic/mechanistic support 15 | Safety 10.
## 11. Stability checks
Weight perturbation (+/-10 points per criterion or random Dirichlet weights) and
leave-one-dataset-out on the node decision.
## 12. Nulls, deviations, exploratory work
If the immune axis shows no signal, this is reported as a null result and tested by
published ALS subtype. Any deviation from this document is recorded as a dated amendment
stating what changed and why. Anything not listed above is exploratory and labelled so.
## AMENDMENT A1 (2026-10-20; written before any expression data or DE results were viewed)
Reason: (a) metadata audit of GSE153960 showed no C9orf72 status, age, sex or RIN in GEO;
(b) the project targets the ALS-FTD spectrum, so an FTD arm is required.
Changes:
1. GSE153960 (NYGC) is used for ALS-spectrum vs control, not for C9-specific claims.
   Covariates: platform, library prep, RNA-seq-inferred sex.
2. C9-specific ALS comparisons (C9 vs control, C9 vs sporadic) use GSE67196.
3. FTD arm: RiMod-FTD (ArrayExpress E-MTAB-12647; FigShare counts; metadata from
   Sci Data 2023 Supp. Table 1). Primary: C9-FTD vs control. Secondary: C9-FTD vs (GRN+MAPT).
   Covariates: age, sex, RIN, pH.
4. Gate G1 amended: "spectrum-level supported" if up in the ALS arm (FDR < 0.05) AND
   directionally concordant (nominal p < 0.05) in the FTD arm; otherwise "arm-specific".
5. Anchor region: frontal cortex where available. Region rule applies to NYGC.
6. Donor-overlap check between NYGC and RiMod-FTD before calling them independent.
7. Exact group definitions are fixed in Amendment A2 after tabulating group labels, before DE.
8. Thresholds, gene sets, nodes and other gates are unchanged.

## AMENDMENT A2 (2026-10-20; written before any expression data or DE results were viewed)
Basis: metadata tabulation only (sample labels, tissue, platform).
1. NYGC GSE153960, primary: tissue == "Cortex Frontal". Cases = group exactly
   "ALS Spectrum MND" (n=156; 70 HiSeq, 86 NovaSeq). Controls = group exactly
   "Non-Neurological Control" (n=56; 18 HiSeq, 38 NovaSeq). All other labels excluded.
   Each donor has exactly one frontal sample.
2. NYGC secondary tissue (pre-specified): "Spinal Cord Cervical", same group definitions
   (ALS n=161, control n=41), labelled secondary because of neuron loss and gliosis.
3. NYGC sensitivity analyses (frontal cortex): (a) cases = "ALS Spectrum MND" + "ALS Spectrum
   MND, Other Neurological Disorders" (n=203) vs same controls; (b) NovaSeq-only
   (86 vs 38); (c) technical surrogate variables from sva with disease group protected.
4. NYGC covariates: platform (perfectly confounded with library prep, so one batch term)
   and RNA-seq-inferred sex. Age and RNA quality are unavailable in GEO: stated limitation.
   "ALS Spectrum MND" may include ALS-FTD and C9/non-C9 cases; GEO does not separate them.
5. GSE67196, primary: Frontal Cortex; groups c9ALS (n=8), sALS (n=10), Healthy (n=9).
   Comparisons: c9ALS vs Healthy; c9ALS vs sALS; sALS vs Healthy. Cerebellum is secondary.
   Primary test is the pathway-level fgsea (Sec. 5); the six-node family test is secondary.
   Results are labelled supportive (small n).
6. Node-level family test (all datasets): CGAS, STING1, JAK1, JAK2, IRF3, TBK1 tested as one
   pre-specified family with BH correction across 6 genes, reported alongside genome-wide FDR.
7. All thresholds, gene sets, gates and other rules are unchanged.

## AMENDMENT A3 (2026-10-21; written before any expression data or DE results were viewed)
Basis: literature check (literature/search_log.md, literature/prior_art_notes.md) and a read-through of
this document. No thresholds, gene sets, nodes, gates or scoring weights change.
1. Count inputs (clarification). "Raw counts" in Sec. 4 means: NYGC RSEM expected counts, rounded to
   integers; RiMod-FTD Salmon estimated counts, imported and rounded (or via tximport). GSE67196 input
   format is recorded at download; any deviation is logged as a dated amendment.
2. Independence checks. Before any pair of datasets (NYGC, GSE67196, RiMod-FTD) is called independent,
   donor overlap is checked wherever identifiers allow. Where overlap cannot be assessed, the pair is
   labelled "independence unverified" and claims are labelled "single-cohort", as in Sec. 3.
3. Exploratory (does not enter any gate): add a vascular/endothelial marker-score PC to the
   cell-composition surrogate covariates in the Sec. 4 sensitivity analysis.
4. Framing: the project is the ALS-FTD spectrum with C9orf72 as anchor (as in A1); no rule changes.

## AMENDMENT A4 (2026-10-21; written before any expression data or DE results were viewed)
Basis: strict one-to-one reconciliation of NYGC counts columns to GEO metadata on `sample id alt:ch1`, plus a donor-uniqueness check.
1. 1,639 samples map. Excluded and logged (results/nygc_exclusion_log.csv): 19 counts columns (CGND-HRA-00440 to 00459, 00453 absent) with no GEO row; CGND-HRA-01288-2 (two GSMs, thoracic cord, outside A2); 197 GEO rows with no counts column.
2. Analysed n replaces the metadata-only counts in A2. Frontal primary: 154 ALS Spectrum MND (70 HiSeq / 84 NovaSeq) vs 56 controls (18 / 38). NovaSeq-only sensitivity: 84 vs 38. A2.3a sensitivity: 201 vs 56.
3. Cervical secondary: 155 cases (50 / 105) vs 41 controls (12 / 29). Donors are unique within the A2 groups in both tissues, so no de-duplication rule is applied.
4. No thresholds, gene sets, nodes, gates or scoring weights change.
