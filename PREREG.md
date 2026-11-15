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

## AMENDMENT A5 (2026-11-15; written before any DESeq2 or fgsea results were viewed)
Basis: the NYGC frontal loader, outlier rule and design check are done (scripts/03 to 06; no gene-level results viewed). This amendment fixes implementation details only. No thresholds, gene sets, nodes, gates or scoring weights change.
1. DESeq2 settings: Wald test, DESeq2 default size-factor estimation, dispersion fitting, Cook's outlier handling and independent filtering, with the Sec. 4 count filter applied first. Reference level = control. Design for NYGC frontal primary: ~ platform + sex + group (control as reference). lfcShrink is used only for plotting, never for the Wald statistic passed to fgsea or for gate decisions. Package versions are recorded in docs/session_info.txt.
2. Outlier sensitivity uses the Sec. 3 rule only (|z| > 3 on PC1 or PC2, z within group; PCA on blind-VST, top 500 variable genes, unscaled). The saved flag_B is not pre-registered and is not used.
3. Gene identifiers: Ensembl version suffixes are removed; Ensembl IDs are mapped to HGNC symbols using the msigdbr annotation table. The six family-test nodes (CGAS, STING1, JAK1, JAK2, IRF3, TBK1) are identified by symbol after mapping, and each mapping is checked before use. Unmapped IDs are dropped from gene-set tests and counted in the log.
4. Cell-composition surrogates (Sec. 4 sensitivity) use these fixed marker sets, defined now: neuron (RBFOX3, SNAP25, SYT1), astrocyte (GFAP, AQP4, SLC1A2), microglia (CX3CR1, P2RY12, TMEM119), oligodendrocyte (MBP, PLP1, MOG). The exploratory vascular set from A3 is (CLDN5, PECAM1, VWF). Marker scores = mean VST expression per set; PCs are taken across the sets; no marker is chosen or changed after seeing results.
5. Order of analyses: frontal primary (154 vs 56) first, then the Sec. 4 and A2 sensitivity analyses (outliers removed, NovaSeq-only, sva, composition surrogates), then cervical secondary. The A2.3a sensitivity (201 vs 56) needs the extra 47 samples loaded and is run after the primary analysis. Every analysis run is reported, including the ones that agree with nothing.

## AMENDMENT A6 (2026-11-15; written before the composition-adjusted model was fitted; the unadjusted primary had been fitted, with no gene-level results viewed)
1. Sec. 4 composition sensitivity: marker scores (A5.4) are computed per sample as the mean blind-VST expression of each set's genes. PCA (centred, scaled) is run on the four scores (neuron, astrocyte, microglia, oligodendrocyte) and PCs 1 to 3 enter the design as covariates: ~ platform + sex + compPC1 + compPC2 + compPC3 + group. The exploratory vascular set (A3.3) is added in a separate, labelled exploratory model.
2. Interpretation caveat, fixed in advance: neuron loss and gliosis are part of ALS pathology, so composition adjustment may remove real disease signal. The unadjusted and the adjusted results are both reported, with the genomic inflation factor of each, and neither is declared the "correct" model.
3. No thresholds, gene sets, nodes, gates or scoring weights change.

## NOTE ON A6 (2026-11-15; written after the composition-adjusted model was run)
A6 was written into PREREG.md before the composition-adjusted DESeq2 model was run, but it was committed (d858bbd) only after the run, 13 seconds before the model script and results were committed (25f1b35). The commit order in git therefore does not show the order in which A6 was written and the model was run; this note records it. The A6 specification (composition PCs 1 to 3) was not changed after the run. At the time of A6 only summary counts from the unadjusted primary model (number of FDR < 0.05 genes, genomic inflation 20.3) had been viewed; no individual gene-level results had been viewed. Process change: from here on, each amendment is committed and pushed before the script it governs is run.

## AMENDMENT A7 (2026-11-15; written before any model using the new covariates was fitted. The GEO-only primary and composition models had already been fitted (genomic inflation 20.3 and 17.3). The new metadata was inspected only for coverage, balance and agreement between sources; no expression values or gene-level results were viewed using it.)
Basis: NYGC flagship supplementary tables (Zenodo v3, 2026-05-08) and O'Neill et al. 2025 Table S1 (hashes and licences in docs/nygc_metadata_source.md).
1. Sources. Primary: flagship ST3 (RNA metadata, key rna_id = GEO counts column name) linked to ST1 (donor level) by donor_id. O'Neill 2025 Table S1B/S1C is used only to validate (it agreed with ST3 on RIN 143/143, pH 70/70 where both present, platform 143/143, site 141/143, and with ST2 on C9 labels wherever both were defined). It never overrides the flagship tables. Disagreements are reported and analyses are run with and without the affected donors.
2. Rationale. Sec. 4 of v1 specified age at death, sex, RIN and batch/site/platform as covariates; A1 reduced the model to platform and sex only because GEO lacked the rest. A7 restores the originally registered covariates now that they are available. This change was motivated by the large inflation in the GEO-only models and is stated as such.
3. Primary model, NYGC frontal cortex (replaces the A5.1 design as the primary; control is the reference): ~ platform + sex + age_at_death + RIN + site + group. Platform is ST3 rna_platform (identical to library prep; one term). Sex is the RNA-inferred sex (equal to ST1 sex_call in 204/204 matched samples). Site is ST1 site_specimen_collected and is kept in the primary model; sites with fewer than 5 samples in the analysed set are merged into "Other". These choices were fixed before any model using the new covariates was fitted. Complete cases only; expected 154 ALS-spectrum vs 50 controls.
4. Covariate coding. Age at death is numeric; the text "90 or older" is recoded to 90; any other non-numeric value is treated as missing and the sample is excluded from the complete-case models. RIN is used as given, as a covariate; no RIN filter is applied in the primary model. pH and post-mortem interval are not used (missing in about 48% and 28% of the matched samples, above the v1 threshold of 20%).
5. Exclusions. The 6 frontal controls absent from ST3 (CGND-HRA-01988, 02036, 02041, 02054, 02097, 02105) and any sample with a missing covariate are excluded from the A7 models and listed with the reason in results/nygc_frontal_A7_exclusions.csv. They remain in the GEO-only models.
6. Checks before fitting: the design matrix must be full rank; the group-by-site, group-by-platform and group-by-sex tables and the variance inflation of each covariate are reported. If the design is not full rank, the analysis stops and a further amendment is written.
7. Pre-specified sensitivities (all reported): (a) the consortium's published frontal cortex covariates from ST3 (library prep, MEAN_READ_LENGTH, PCT_CHIMERAS) plus group; (b) the A7 primary without site; (c) the GEO-only models already fitted (A5 primary and A6 composition); (d) the A5.5 outlier-removed (flag_A) and NovaSeq-only runs, using the A7 primary design; (e) the A7 primary restricted to samples with RIN >= 5.5. Surrogate-variable (sva) and composition-adjusted variants of the A7 design are specified in separate amendments (A8 and later) before they are run.
8. Model hierarchy. The A7 model is the primary; everything else is a sensitivity analysis. No model is promoted because it has lower inflation or a more favourable result for the immune axis. The robustness rule is fixed in a later amendment before any candidate node's results are viewed.
9. Disclosure. When this amendment was designed, it was already known that collection site is strongly imbalanced between cases and controls in the frontal set (for example 28 ALS vs 1 control at one site and 21 vs 24 at another), so the site-adjusted effect is identified mainly from sites with both groups.
10. Not used here. C9orf72 status and ALS subtype labels are not used in A7. In the frontal set only 4 samples carry the ALS-Glia label (81 ALS-Ox, 25 ALS-TE among the 110 labelled), so the Sec. 12 subtype fallback is limited in this tissue; how to handle it is decided in a separate amendment.
11. No thresholds, gene sets, nodes, gates or scoring weights change. Numbering: sva is A8, the robustness rule A9.

## AMENDMENT A7b (2026-11-15; written before any model using the A7 covariates was fitted. scripts/10_merge_metadata.R had been run, reading metadata only; no expression values or gene-level results were viewed.)
Basis: the A7 metadata merge (scripts/10_merge_metadata.R) showed that 2 of the 154 frontal ALS samples (CGND-HRA-02161 and CGND-HRA-02168, both Barrow Neurological Institute) carry the GEO group label "ALS Spectrum MND" but the flagship ST1 subject_group "ALS Spectrum MND, Other Neurological Disorders", and both are flagged used_in_analysis = FALSE in flagship ST3. The other 152 ALS samples and all 50 controls agree between GEO and ST1.
1. Group definitions are unchanged (A2, A4, A7.3): the A7 primary remains 154 ALS vs 50 controls.
2. New pre-specified sensitivity (f), reported with those in A7.7: the A7 primary design with these 2 samples removed (152 ALS vs 50 controls), with the full-rank check of A7.6 repeated.
3. Record of the A7.6 checks on the primary table: full rank (13 of 13 design columns); largest variance inflation 2.31 (Johns Hopkins site term); RNA-inferred sex agrees with ST1 sex_call in 204 of 204 and platform agrees with ST3 rna_platform in 204 of 204 matched samples; the 6 controls absent from ST3 are excluded as listed in A7.5.
4. No thresholds, gene sets, nodes, gates or scoring weights change.

## AMENDMENT A8 (2026-11-15; written before any surrogate variable was estimated and before any model containing one was fitted. The A7 primary and its sensitivity runs had been fitted, and only summary counts (genes after the count filter, number of genes at FDR < 0.05, genomic inflation) and a descriptive RIN-by-group check of the A7 metadata table had been viewed; no individual gene, candidate node or pathway result had been viewed.)
Basis: A2.3(c) and A7.7, which promised a surrogate-variable analysis to be specified in a separate amendment before it is run. No thresholds, gene sets, nodes, gates or scoring weights change.
1. One sva analysis, on the A7 set (NYGC frontal cortex, 154 ALS vs 50 control), with disease group protected. Deviation from A2.3(c): the GEO-only sva (154 vs 56, covariates platform and sex) is not run, because A7 replaced that design as the primary and the GEO-only set lacks the registered covariates. It remains a sensitivity analysis; the A7 primary remains the primary model (A7.8).
2. Input: integer counts after the Sec. 4 filter used in the A7 primary (>= 10 counts in >= 50 samples), so the genes match the A7 primary.
3. Models given to svaseq (R package sva): full ~ platform + sex + age_at_death + rin + site + group; null ~ platform + sex + age_at_death + rin + site (coding as in A7.3). Known covariates are in both models, so the surrogate variables capture only variation they do not explain.
4. Number of surrogate variables: n.sv = min(sva::num.sv(dat, full model, method = "be", seed = 1), 10), with set.seed(1) before every sva call. If num.sv returns 0, no sva model is fitted and this is reported.
5. Diagnostics, saved before any DESeq2 run that uses the surrogate variables: correlation of each SV with group, platform, sex, age at death, RIN, site (R-squared from a linear model) and log library size. An SV with |r| > 0.5 with group is flagged.
6. DESeq2 with SVs: design = the A7 design plus SV1 to SVk (numeric, not rescaled); Wald test, control as reference, same filter and DESeq2 settings (A5.1); the full-rank check of A7.6 is repeated and the analysis stops if it fails. If any SV is flagged, a second model without the flagged SVs is also fitted and both are reported (neuron loss and gliosis are part of ALS pathology, so an SV correlated with group may be real signal). Neither is declared correct.
7. Outputs: full results tables, the diagnostics table, and a summary of n.sv, genes after the filter, FDR counts and genomic inflation for each fitted model. No individual gene or node is looked up.
8. Interpretation: the sva model is a sensitivity analysis and is not promoted for lower inflation or a more favourable result. Whether it enters the robustness rule is fixed in A9, before any node is viewed. Composition-adjusted variants of the A7 design are not specified here and would need a separate amendment before they are run.
