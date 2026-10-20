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
