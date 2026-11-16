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

## AMENDMENT A9 (2026-11-15; written before any candidate-node or pathway result was viewed. When it was written, only summary counts (genes after the count filter, number of genes at FDR < 0.05, genomic inflation) of the A7 primary, the A7.7 and A7b sensitivity runs and the A8 sva run, the descriptive RIN check of the A7 metadata table and the A8 sva diagnostics had been seen, together with published summary counts of differentially expressed genes read in the consortium preprint; no individual gene, node or pathway result had been viewed, and the published supplementary result tables (flagship ST4 to ST16, O'Neill S2 to S7) had not been opened.)
Basis: A7.8 and A8.8, which deferred the robustness rule to a later amendment. No thresholds, gene sets, nodes, gates or scoring weights change.
1. Scope. The rule applies to the six nodes of A2.6 (CGAS, STING1, JAK1, JAK2, IRF3, TBK1) and to the pathway sets of Sec. 5, in the NYGC frontal cortex analyses. IRF3 and TBK1 receive an expression-robustness label only; their status in the screen is unchanged (Sec. 2, G3). The A7 primary is the reference model. Other datasets and tissues (cervical, GSE67196, RiMod-FTD) use the same rule with their own primary and sensitivity models, named in their amendments before any node is viewed there.
2. Models checked. Every frontal model fitted before this amendment: 7a, 7b, 7d (outliers removed), 7d (NovaSeq-only), 7e, 7f (A7.7, A7b), the A8 sva model, and the GEO-only A5 primary and A6 composition models (A7.7c).
3. Significance is assessed in the primary only. Node level: the BH-adjusted p-value of the six-gene family test of A2.6 in the A7 primary is below 0.05 (the genome-wide FDR is reported alongside). Pathway level: fgsea FDR below 0.05 across the tested sets (Sec. 5) on the Wald statistic of the A7 primary. No log2FC threshold enters this rule; G1, the Sec. 4 gene-list threshold and the scoring weights are unchanged.
4. Direction is assessed in every other model. Node level: the sign of the DESeq2 Wald statistic of the node (positive = higher in ALS than control; control is the reference in every model) equals its sign in the A7 primary. Pathway level: the sign of the fgsea normalised enrichment score equals its sign in the A7 primary. Significance is not required in the other models, because 7e and the GEO-only models have little power or weaker adjustment.
5. Labels, applied in this order. "Not testable": the node is removed by the Sec. 4 count filter in the primary. "Not significant": the node does not meet item 3; it is reported and not assessed further. "Model-dependent": significant in the primary, but the direction differs in at least one model in which it was tested (those models are named). "Not testable in a model": significant in the primary with the same direction in every model in which it was tested, but absent from the results table or without a Wald statistic in at least one model (those models are named); the node is not called robust. "Robust": significant in the primary and the same direction in all other models.
6. Reporting. Every node and pathway is reported with its label, the Wald statistic (or NES) and adjusted p-value in all models, and the direction in each model. Results are never dropped for disagreeing with the primary.
7. Fixed in advance. This rule is not changed after any node or pathway result has been viewed. A change is a dated amendment labelled exploratory, and the results under the original rule are reported alongside.
8. No model is promoted because its inflation is lower or because it favours the immune axis (A7.8, A8.8). Composition-adjusted and other variants of the A7 design added later enter the rule only through a dated amendment written before they are run.

## AMENDMENT A10 (2026-11-15; written before any candidate-node or pathway result was viewed in any C9-defined comparison. When it was written, the metadata inspected were the C9orf72 columns of flagship ST1, the C9orf72 entries of ST2, their cross-tabulations with group, site, platform, sex, age and RIN in the 204 frontal samples of the A7 table, and the summary counts listed in A9; published summary DEG counts for carriers vs non-carriers had been read in the consortium preprint (1 DEG in frontal cortex, 1,236 in cervical cord); no individual gene, node or pathway result had been viewed, and the published supplementary result tables (flagship ST4 to ST16, O'Neill S2 to S7) had not been opened.)
Basis: A1 and A2 deferred C9-specific comparisons; A7.10 deferred the C9orf72 label definition. No thresholds, gene sets, nodes, gates or scoring weights change.
1. Label rule (all NYGC samples). C9orf72 expansion carrier = ExpansionHunter maximum repeat (ST1 c9orf72_max_call) >= 30 OR repeat-primed PCR (ST1 c9orf72_rp_pcr) = "Yes". All other samples are non-carriers, including samples with missing or unknown RP-PCR and a repeat size < 30. Intermediate alleles (20 to 29 repeats) are non-carriers. Carriers of both the expansion and another ALS-gene variant remain carriers. ST2 is used as a cross-check only.
2. Check on the frontal set (A7 table, 204 samples): the rule gives 27 ALS carriers, 127 ALS non-carriers and 50 controls without carriers. ST2 agrees: all 27 carriers have a C9orf72 entry (25 "ALS single gene", 2 "Oligo"), none of the 127 ALS non-carriers has one, and the one control with a C9orf72 entry is in the ST2 category "RF/Carrier/Intermed", has a repeat size < 30 and is a non-carrier. Three carriers are RP-PCR "Yes" with an ExpansionHunter repeat size < 30, and one carrier is RP-PCR "Unknown" with a repeat size >= 30.
3. Limitation, stated in advance: non-carriers without an RP-PCR result may include a few carriers that ExpansionHunter did not call.
4. Comparisons in NYGC frontal cortex. Primary: C9 carriers vs controls (27 vs 50). Secondary: C9 carriers vs non-C9orf72 ALS (27 vs 127). Both use the A7 design (~ platform + sex + age_at_death + rin + site + carrier status; site coding as in the A7 analysis table; non-carrier or control = reference), Wald test, count filter with n = the smallest group (27), and the full-rank check of A7.6 (stop and write a further amendment if it fails). Results are labelled supportive (small n), as in A2.5.
5. Sensitivities for each comparison: (a) without site; (b) without the pre-registered outliers (flag_prereg); (c) NovaSeq-only (platform term dropped); (d) the A7 design plus SV1 as saved in results/nygc_frontal_A8_svs.csv (not re-estimated). RIN >= 5.5 is not run because it would leave too few carriers; the number of carriers it would leave is reported.
6. Robustness. A9 applies to each comparison, with that comparison's primary model as the reference and the models of item 5 as the sensitivity set (A9.1 and A9.2 applied accordingly for these comparisons only).
7. Cervical cord and the extra A2.3a samples use the label rule of item 1; their models and sensitivities are specified in a separate amendment before any node is viewed there.
8. A null result for the C9 comparisons, including in frontal cortex where the consortium found 1 DEG, is reported as such (Sec. 12).

## AMENDMENT A11 (2026-11-15; written before any pathway or gene-set enrichment result was computed. When it was written, the node-level results of script 14 (the six nodes in ten frontal models, with their A9 labels) had been viewed, together with the summary counts listed in A9 and A10, the membership of the six gene sets of Sec. 5 and their overlap with the tested genes, and the names, sizes and overlap with the tested genes of the KEGG Medicus, Reactome and WikiPathways sets that contain both CGAS and STING1; no pathway result had been viewed.)
Basis: Sec. 5 registered the pathway tests and the random-set control; A9 fixed how pathway results are labelled. A11 fixes the implementation settings. The gene sets, thresholds, nodes, gates and scoring weights of the pre-registration do not change; the two runs of item 8 are exploratory and enter no gate and no A9 label.
1. Scope. fgsea is run on the A7 primary (reference) and the nine other frontal models of A9.2, each with its own ALS-vs-control results table. C9-defined comparisons (A10) and other tissues or datasets are run under the same settings in separate amendments or scripts and are not specified here.
2. Ranking and identifiers. Genes are ranked by the DESeq2 Wald statistic of the model (positive = higher in ALS); genes without a Wald statistic are dropped. Ensembl version suffixes are removed and IDs are mapped to HGNC symbols with results/gene_id_map_msigdbr.csv (A5.3); where two IDs share a symbol the one with the higher baseMean in that model's table is kept; unmapped IDs are dropped; the numbers of genes ranked, unmapped and duplicated are logged for every model.
3. Gene sets. Registered (Sec. 5), from msigdbr 26.1.1 (MSigDB 2026.1.Hs): Hallmark INTERFERON_ALPHA_RESPONSE, INTERFERON_GAMMA_RESPONSE, INFLAMMATORY_RESPONSE, TNFA_SIGNALING_VIA_NFKB, IL6_JAK_STAT3_SIGNALING, and KEGG_CYTOSOLIC_DNA_SENSING_PATHWAY from the KEGG Legacy collection (C2, CP:KEGG_LEGACY), the form of hsa04623 available in this release. That KEGG set has 55 genes, 35 of them in the tested universe of the A7 primary (13,611 gene symbols); it does not contain CGAS, and its 20 members outside the tested universe are the interferon, chemokine and related output genes (12 IFNA genes, IFNB1, CCL4, CCL4L2, CCL5, CXCL10, IL6, AIM2, ZBP1). It is labelled "KEGG legacy cytosolic DNA-sensing" and described as the signalling machinery of that pathway, not as the cGAS-STING axis or its interferon output. Tested genes of the other sets in the A7 primary: IFN-alpha 92 of 97, IFN-gamma 180 of 200, inflammatory response 160 of 200, TNFA via NFKB 180 of 200, IL6-JAK-STAT3 66 of 87. Exploratory, outside the six-set family and outside A9: REACTOME_CYTOSOLIC_SENSORS_OF_PATHOGEN_ASSOCIATED_DNA (C2, CP:REACTOME; 64 genes, 61 in the tested universe; contains CGAS and STING1). It was selected by a rule fixed before any pathway result: among the sets of KEGG Medicus, Reactome and WikiPathways that contain both CGAS and STING1, are not named for a specific disease or pathogen and have at least 15 tested genes, the one with the most tested genes. Not selected: WP_CYTOSOLIC_DNASENSING_PATHWAY (73 genes, 53 tested) and two 16-gene sets with 15 tested genes. KEGG_MEDICUS_REFERENCE_CGAS_STING_SIGNALING_PATHWAY has 18 genes, 5 of them tested, below the minimum size of 15, and is reported as not testable.
4. Method. fgsea::fgseaMultilevel (fgsea 1.38.0, R 4.6.2) with minSize 15, maxSize 500, scoreType "std" (two-sided), default gseaParam and eps, and set.seed(1) before every call. The six registered sets are one family: the adjusted p-value is Benjamini-Hochberg across the six sets within each model, and significance is FDR < 0.05 (Sec. 5). The exploratory set is not part of this family; its nominal p-value, and its adjustment within the exploratory sets of item 8, are reported.
5. Specificity control (Sec. 5). In the A7 primary only, for each tested set (the exploratory Reactome set included), 1,000 random gene sets of the same size (its number of ranked genes) are drawn without replacement from the ranked genes and scored with the same settings (set.seed(1)); the specificity p-value is (1 + number of random sets with |NES| >= the observed |NES|) / 1001. It is reported beside the FDR as a calibration and specificity check and does not change an A9 label.
6. A9 labels for pathways apply to the six registered sets only. Significance comes from the A7 primary (FDR < 0.05 across the six sets); direction is the sign of the NES in each of the other nine models; labels and their order are as in A9.5, with "not testable" meaning that a set has fewer than 15 ranked genes in the model. For the exploratory set the NES and its sign in every model are reported without an A9 label.
7. Reporting. For every set and model: NES, FDR (or nominal p for the exploratory set), the number of ranked genes in the set, and the leading-edge genes (saved to file). Nothing is dropped for disagreeing with the primary.
8. Exploratory context (labelled exploratory; enters no gate and no A9 label). (a) The A7 primary is also run on all 50 Hallmark sets (Benjamini-Hochberg across 50) to show whether the six sets stand out from the rest of Hallmark or whether most sets are shifted, since broad changes in cell composition and tissue state are expected in ALS cortex (A6.2). (b) The Reactome set of item 3, run in all ten models.
9. Interpretation limits, fixed in advance. (a) fgsea permutes gene labels and does not account for correlation among the genes of a set, so p-values can be optimistic when a set captures co-varying glial or immune genes; a composition-adjusted variant of the A7 design is not specified here and needs its own amendment before it is run. (b) The limits of the KEGG legacy set in item 3. (c) A set that is significant in the primary does not show that any one node drives it.
10. Software and outputs. R 4.6.2; fgsea 1.38.0; msigdbr 26.1.1 (MSigDB 2026.1.Hs); DESeq2 and sva as in A5 and A8 (versions in docs/session_info.txt). Outputs: a long results table, the A9 pathway labels, the specificity table and the exploratory tables. Per A9.7, none of this changes after any pathway result has been viewed.
11. No thresholds, nodes, gates or scoring weights change.

## AMENDMENT A12 (2026-11-16; written before any node, gene-set or pathway result of a C9-defined comparison was viewed. When it was written, the summary counts of the ten A10 runs (genes after the filter, FDR counts, inflation) had been seen; the node and pathway results of the ALS-vs-control frontal analyses (scripts 14 and 15) had been viewed; no individual gene, node or pathway of any A10 run had been viewed, and the published supplementary result tables (flagship ST4 to ST16, O'Neill S2 to S7) remained unopened.)
Basis: A10.6 and A11.1 deferred the node and pathway settings for the C9 comparisons; A9.1 requires them before any node is viewed there. No thresholds, gene sets, nodes, gates or scoring weights change.
1. Scope. The two A10 comparisons: C9 carriers vs controls (27 vs 50) and C9 carriers vs non-C9orf72 ALS (27 vs 127). For each, its primary model is the reference and its sensitivities (a) to (d) of A10.5 are the sensitivity set (A10.6). Positive statistics mean higher in carriers.
2. Nodes. The six-gene family of A2.6 (BH across 6 genes) is computed within each model, with the genome-wide FDR reported alongside. The A9 labels and their order (A9.5) apply as written, with the A10 primary as the reference. Gene identifiers and the mapping check follow A5.3 and script 14.
3. Pathways. The A11 settings (items 2, 3, 4 and 7) are applied unchanged to each comparison's five models: ranking by the Wald statistic, the six registered sets as one family (BH across six within each model, FDR < 0.05), fgseaMultilevel with minSize 15, maxSize 500, scoreType "std" and set.seed(1) before every call. The A9 pathway labels follow A11.6, with each comparison's primary as the reference. The A11.5 specificity control is run in the two C9 primaries only. The exploratory Reactome set (A11.3) is run in all ten models and carries no A9 label. The 50-Hallmark exploratory run (A11.8a) is not repeated. The limits of A11.9 apply.
4. Interpretation, fixed in advance. Only the comparison of C9 carriers with non-C9orf72 ALS can support a C9-specific claim. A node or set that is significant in C9 vs controls only is reported as "not resolved between ALS in general and C9" and is not called C9-specific. A null result in C9 vs non-C9orf72 ALS is reported as such (A10.8, Sec. 12).
5. Multiplicity. The number of comparisons run in the project is reported. No correction across comparisons is applied, and a result seen in a single comparison is labelled as such.
6. No thresholds, gene sets, nodes, gates or scoring weights change.
