# PROJECT HANDOFF: ALS-FTD immune-axis in silico study
Written 2026-10-20 to continue in a fresh chat. Paste or upload this file at the start of the new chat.

## 0. How to work with me (preferences stated during this project)
- I am **new to R and transcriptomics**. Explain the idea first, then give commands.
- Go **one step at a time**, each with a "done when" check and common problems. Do not do many steps at once.
- Do not run ahead on decisions: show me drafts (especially pre-registration text) and wait for my "go".
- I run R on **Google Colab**, git in **Git Bash on Windows**. Laptop folder: `D:/als_ftd_project`. I paste outputs back for you to interpret.
- Be honest about what is verified vs not. Act as a PI/critic when I ask.
- Goal: publish a fully in silico paper (no wet lab, no budget) to strengthen my CV for **funded PhD applications in Germany**.

## 1. The project in one paragraph
Cell-type-aware, transcriptomics-guided structure-based prioritization of brain-penetrant repurposed and natural-product modulators of the **cGAS-STING innate-immune axis** across the **ALS-FTD spectrum** (C9orf72 as anchor). Pipeline: public brain transcriptomics (ALS arm + FTD arm, analysed separately, then compared) -> network pharmacology -> genetic support (MR, "lite") -> library filtering with CNS-penetrance -> AutoDock Vina screen -> Boltz-2 rescoring -> MD on 1-2 final compounds with decoy control. Output is "prioritized candidates for experimental follow-up", never validated targets.

Working title: *Cross-disease transcriptomic prioritization of cGAS-STING axis targets across the ALS-FTD spectrum, with brain-penetrance-filtered, structure-based repurposing.* (Novelty NOT yet confirmed; literature check pending.)

## 2. Why this topic (decisions made)
- Disease area: ALS-FTD (not Alzheimer's). Alternatives rejected: TDP-43 cryptic exons (RNA-level, poor for docking), TMEM106B (GRN-lowering not supported), generic SOD1/TDP-43 docking (saturated), Keap1-Nrf2 (partly done).
- Chosen idea: **innate-immune axis** (cGAS, STING1, JAK1/2, IRF3; TBK1 handled as a flagged tension, not primary screen).
- Design: **hypothesis-guided, data-adjudicated** (pathway and rules fixed in advance; data picks the node).
- Novelty is integrative/methodological: cross-disease (ALS+FTD) spectrum-level rule, cell-type awareness, genetic layer, CNS filter early, Vina+Boltz-2 consensus with benchmark, decoy-controlled MD, open workflow. **Not** a new mechanism and not a new inhibitor class.
- Honest expectations: moderate novelty, good feasibility, mid-tier journal (e.g., Sci Rep, Front Pharmacol/Neurosci, Comput Biol Med, JBSD, BMC Bioinformatics). Preprint on bioRxiv early.

## 3. Key biology/prior art found (verify details before citing)
- McCauley et al., Nature 2020: C9orf72 loss -> STING hyperactivation; elevated interferon signature in C9 ALS/FTD vs sporadic. https://ideas.repec.org/a/nat/nature/v585y2020i7823d10.1038_s41586-020-2625-x.html
- Yu et al., Cell 2020: TDP-43 -> mtDNA release -> cGAS/STING; H-151 protective. https://pmc.ncbi.nlm.nih.gov/articles/PMC7599077/
- Neuronal STING activation in ALS/FTD, Acta Neuropathol 2024. https://pubmed.ncbi.nlm.nih.gov/38478117/
- **Duan et al., BMC Med 2024 (closest prior art)**: druggable-genome MR (cis-eQTL + ALS GWAS) prioritized TBK1; fostamatinib and amlexanox in THP-1 and NSC-34 models. ALS-only, no structure-based screen. https://pmc.ncbi.nlm.nih.gov/articles/PMC10916235
- 2026 BTK-inhibitor/STING-NFkB ALS dataset (iPSC motor neurons, SOD1 mice): GSE299859, GSE299856 (experimental; add to prior-art notes).
- Prudencio et al., Nat Neurosci 2015 (GSE67196): C9 vs sporadic ALS cerebellum/frontal cortex; already reported inflammatory/defense-response enrichment. So the immune signal itself is NOT novel.
- 2026 computational H-151 CDN-pocket docking/GaMD/MM-GBSA paper (human STING, PDB 7SII): STING+MD in neuro is emerging.
- "Mechanism-free" large genomic C9 repurposing (acamprosate): differentiate (structure-based, cell-type aware).
- Reviews: existing cGAS/STING inhibitors have poor BBB penetration, PK/off-target issues, human STING allele diversity.
- TBK1 tension: rare LoF mutations cause ALS/FTD, yet MR links higher TBK1 expression (blood) to ALS risk and TBK1-phospho inhibitors help in cell models. Do not claim to resolve it.
- Boltz-2: depends on structure quality, compressed affinity range, limited flexibility handling, possible memorization of known PDB ligands; GPCRs reportedly problematic (not relevant here). ~16-20 s/ligand on GPU: run only on top few hundred Vina hits.

## 4. Datasets (decisions and verified facts)
Rule: **analyse each dataset separately with the same pipeline, then compare direction/size of effect per node. Never merge raw counts across studies.**

### 4.1 NYGC ALS Consortium, GEO **GSE153960** (ALS arm, discovery)
- Two series matrices: GPL16791 (Illumina HiSeq 2500, 714 samples, "Manual KAPA Total" prep) and GPL24676 (NovaSeq 6000, 1,124 samples, "Automated KAPA Total"). **Platform and library prep are perfectly confounded -> one batch term.** Total 1,838 samples from **478 donors** (multiple regions per donor).
- GEO sample metadata fields only: title, group, tissue, library prep, project, subject id, sample id alt. **No C9orf72 status, age, sex, RIN in GEO** (limitation; sex can be inferred from RNA-seq).
- Group labels: ALS Spectrum MND (1012), Non-Neurological Control (288), ALS Spectrum MND + Other Neurological Disorders (278), Other Neurological Disorders (234), "Other Neurological DIsorders" (typo, 8), Pre-fALS + Other (7), Other MND (4), Unknown (4), Pre-fALS (3). **No FTD label**; "Other Neurological Disorders" may contain FTD-type cases but GEO does not say, so not used.
- Tissues: Cerebellum 331, Cortex Frontal 327, Spinal Cord Cervical 258, Spinal Cord Lumbar 239, Cortex Motor Lateral 137, Motor Medial 137, Temporal 102, Occipital 96, Thoracic 82, Motor Unspecified 74, Hippocampus 53, Sensory 2.
- **Frontal cortex**: ALS Spectrum MND 156 (70 HiSeq / 86 NovaSeq) vs Non-Neurological Control 56 (18 / 38); each frontal sample is a distinct donor (327 donors with exactly 1 frontal sample).
- **Cervical spinal cord** (pre-specified secondary): ALS 161 vs control 41.
- Counts file (only supplementary file): `GSE153960_Gene_counts_matrix_RSEM_Prudencio_et_al_2020.txt.gz`, URL `https://ftp.ncbi.nlm.nih.gov/geo/series/GSE153nnn/GSE153960/suppl//GSE153960_Gene_counts_matrix_RSEM_Prudencio_et_al_2020.txt.gz` (RSEM expected counts are non-integer -> round for DESeq2; size not yet checked; not yet downloaded).

### 4.2 **GSE67196** (C9 labels, supportive; small)
- 53 samples, fields `genotype:ch1`, `tissue:ch1`. Frontal Cortex: c9ALS 8, sALS 10, Healthy 9. Cerebellum: c9ALS 8, sALS 10, Healthy 8. Sample names like `1_FCX`, `1_cereb` (same donor in both tissues).

### 4.3 **RiMod-FTD** (FTD arm and replication; NOT in GEO)
- ArrayExpress **E-MTAB-12647** (RNA-seq raw); processed count tables on FigShare DOI 10.6084/m9.figshare.23825595.v1 (my tool could not open it; check file names in browser).
- RNA-seq sample numbers (Sci Data 2023, Table 1): Control 16, FTD-MAPT 11, FTD-GRN 7, **FTD-C9orf72 13**. Medial frontal gyrus. C9 expansion confirmed by repeat-primed PCR. hg38, Salmon quantification.
- Metadata (age, sex, RIN, pH, PMD) in Supplementary Table 1: https://pmc.ncbi.nlm.nih.gov/articles/instance/10692098/bin/41597_2023_2598_MOESM1_ESM.xlsx (may be blocked from Colab; upload manually if so).
- Authors' DE adjusted for sex and pH. Controls older; FTD lower RIN/pH -> adjust age, sex, RIN, pH. No significant cell-composition change in C9 group. Paper: Menden et al., Sci Data 2023, PMC10692098; German consortium (DZNE).
- Code repo: https://github.com/dznetubingen/rimod-ftd-dataset

### 4.4 Supportive/later
- C9-ALS/C9-FTD single-nucleus atlas (Li et al., Nat Commun 2023; ~105k nuclei, 17 donors; PMC10504300): use published per-cell-type DE tables only. Find accession in its data statement.
- GSE124439 (148 ALS cortex samples, 3 molecular subtypes incl. retrotransposon-activation; check overlap with NYGC).
- GSE344875 (C9-FTD synaptosome RNA+proteomics, optional).
- ALS GWAS (Project MinE browser http://databrowser.projectmine.com), FTD GWAS (IFGC, ~2,340 cases/7,252 controls; exploratory), brain/blood cis-eQTL (PsychENCODE, eQTLGen, GTEx) for the MR layer.
- Drug side: L2S2 / iLINCS (`drugfindR`); LINCS lines are mostly non-neuronal (supporting evidence only).

## 5. Research design summary
- **Spectrum-level rule (gate G1 amended):** node is "spectrum-level supported" if up in the ALS arm (FDR < 0.05) AND directionally concordant (nominal p < 0.05) in the FTD arm; otherwise "arm-specific"; neither = null (reported).
- Candidate nodes (fixed): CGAS, STING1 (TMEM173), JAK1, JAK2 (screening candidates); IRF3 (expression only); TBK1 (expression + genetics + safety flag, not in primary screen).
- Annotation/study-bias controls: rank by own data; STRING experimental + curated channels only (no text-mining), degree-matched proximity null; literature-free layers (LINCS reversal, structure-based scoring); PubMed publication-count bias check; never count papers as evidence.
- Gates: G1 above; G2 human ligand-bound experimental structure with pocket; G3 flag for haploinsufficiency genes (TBK1) needing written justification; G4 docking validation (redock RMSD <= 2 A; actives-vs-decoys AUC >= 0.7).
- Scoring (nodes passing gates): effect size + replication 25; cell-type relevance 15; structural tractability 25; reference inhibitors available 10; independent genetic/mechanistic support 15; safety 10. Plus weight-sensitivity analysis and leave-one-dataset-out.
- Docking notes: STING is a dimer with open/closed conformations (candidate PDBs 6NT5, 4KSY, 7SII; verify); screen the non-covalent CDN pocket (Vina cannot model covalent Cys91 inhibitors); cGAS has inhibitor-bound structures (e.g., 6LRI context); dock several conformations; report max similarity of hits to known PDB ligands (memorization check); rank aggregation + bootstrap; interaction fingerprints; MD with reference inhibitor + one docked decoy (+ apo if compute allows), replicates.
- Libraries: COCONUT or LOTUS (natural products) + DrugBank/Drug Repurposing Hub (check license); filter drug-likeness, PAINS, CNS-MPO, BBB/P-gp prediction BEFORE docking.
- Specificity: claim only **C9 vs sporadic** specificity within ALS/FTD (STING signalling is implicated in other neurodegeneration); use degree/size-matched random gene sets as control.

### Pipeline stages
0 pre-register | 1 data audit | 2 DE (DESeq2/limma-voom) | 3 pathway test (fgsea, MSigDB Hallmark: IFN alpha/gamma, inflammatory, TNFA/NFKB, IL6-JAK-STAT3, KEGG cytosolic DNA-sensing hsa04623; 1000 matched random sets) | 4 cell-type layer (published snRNA tables) | 5 network + LINCS | 5b genetic support (TwoSampleMR, coloc; nulls reported; harmonize genome build) | 6 target decision | 7 library + CNS filter | 8 Vina -> Boltz-2 -> consensus + benchmark | 9 MD | 10 write-up (GitHub + Zenodo + bioRxiv).

### Transcriptomics task plan (T1-T7)
T1 metadata audit (done) | T2 download counts, build sample table, apply region rule | T3 QC (library sizes, PCA, outliers; outlier rule >3 SD, run with and without) | T4 DESeq2 (primary + sensitivity runs) | T5 fgsea + node-level table | T6 export gene lists (DEGs FDR<0.05 and |log2FC|>=0.5, ranked list, node table) for network pharmacology | T7 cell-type tables, RiMod-FTD arm, independent validation, leave-one-dataset-out.

## 6. Pre-registration status (in repo file `PREREG.md`)
- **v1 committed and pushed** (commit `50f6393`, "Pre-registration v1 before differential expression"). Covers: question/hypothesis, node panel, data rules, DESeq2 settings (filter >=10 counts in >= smallest group n; BH FDR < 0.05; gene list FDR<0.05 and |log2FC|>=0.5; covariates age, sex, RIN, batch where present, dropped if missing >20%), pathway sets, network, genetic layer, gates, scoring, stability checks, null handling, amendment rule.
- **A1 and A2: drafted; commit status UNKNOWN** (I never confirmed). First thing in the new chat: run `git log --oneline` and `grep -n "AMENDMENT" PREREG.md`. If missing, re-commit with the texts below (rule: amendments are dated additions; never edit v1).
- No expression data or DE results have been viewed so far (only sample metadata), so amendments are still legitimately pre-results.

### AMENDMENT A1 text
```
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
```

### AMENDMENT A2 text (PI-revised version; I had not yet confirmed "go")
```
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
```

## 7. Environment and setup (verified)
- GitHub: private repo `afsarkadhar/als-ftd-immune-axis`; local `D:/als_ftd_project` (Git Bash path `/d/als_ftd_project`); branch `main`; first commit pushed. Folders: literature/, data/raw, data/processed, scripts/, results/, notebooks/. `.gitignore` excludes data/raw/*, data/processed/* (keep raw data OFF GitHub; small CSV results go in results/).
- Colab R kernel: R 4.6.1, Bioconductor 3.23, Ubuntu 24.04. Loaded OK: tidyverse 2.0.0, GEOquery 2.80.0, DESeq2 1.52.0, fgsea 1.38.0; limma, edgeR, org.Hs.eg.db, EnhancedVolcano, pheatmap installed. **clusterProfiler failed to install** (enrichplot compile error; not needed, fgsea + msigdbr used instead). msigdbr install status: check with `requireNamespace("msigdbr")`.
- Colab forgets everything each session: re-run setup cell (Posit Package Manager repo trick) + reinstall packages at start of each session; keep a copy as `scripts/00_setup.R`.
- **Gotchas:** (1) `count`/`select` etc. are masked by Bioconductor packages -> always write `dplyr::count`, `dplyr::select`, `dplyr::rename`, `dplyr::slice`. (2) GEO annotation downloads can return HTTP 502: use `getGEO(..., GSEMatrix = TRUE, getGPL = FALSE)`. (3) `getGEOSuppFiles("GSE...", fetch_files = FALSE)` lists supplementary files without downloading. (4) GEO column names contain `:ch1` and spaces, e.g. `` `group:ch1` ``.
- Metadata-building code used (reproduce in new Colab session):
```r
library(GEOquery); library(tidyverse)
gse <- getGEO("GSE153960", GSEMatrix = TRUE, getGPL = FALSE)
pheno_list <- lapply(gse, function(x) pData(phenoData(x)))
get_col <- function(p, nm) if (nm %in% colnames(p)) p[[nm]] else NA_character_
meta <- bind_rows(lapply(names(pheno_list), function(n) { p <- pheno_list[[n]]
  tibble(gsm = rownames(p), series = n, title = get_col(p,"title"), group = get_col(p,"group:ch1"),
         tissue = get_col(p,"tissue:ch1"), libprep = get_col(p,"library preparation method:ch1"),
         subject = get_col(p,"subject id:ch1"), platform = get_col(p,"platform_id"),
         instrument = get_col(p,"instrument_model")) }))
g2 <- getGEO("GSE67196", GSEMatrix = TRUE, getGPL = FALSE)
p2 <- pData(phenoData(g2[[1]]))   # columns genotype:ch1, tissue:ch1
```

## 8. Not yet saved / to verify at the start of the new chat
1. Git state: `git status`, `git log --oneline`, `grep -n "AMENDMENT" PREREG.md`; confirm on GitHub. Re-commit A1/A2 if missing.
2. Save to repo: this handoff file and the earlier plan draft (`ALS-FTD_immune-axis_insilico_project_draft.md`, v3, still describes the earlier design) into `docs/`; export `meta` and `p2` as CSV from Colab into `results/`; save the Colab notebook via File -> Save a copy in GitHub (`notebooks/`), then `git pull` on laptop.
3. Unverified items: whether "Other Neurological Disorders" contains FTD cases; FigShare file names for RiMod-FTD; accession for the Li 2023 snRNA tables; the ALS brain pQTL MR paper and a 2026 Boltz-2 memorization preprint (cited by another source, unverified); library license terms (DrugBank).

## 9. What is done and what is next
Done: repo set up; Colab R environment tested; pre-registration v1 pushed; metadata audit of GSE153960 and GSE67196; RiMod-FTD identified; amendments A1/A2 drafted; initial literature triage (no direct duplicate found in a handful of searches, NOT exhaustive).

Next, in order:
1. Verify/commit amendments and save artifacts (Section 8).
2. **Literature check** (1.5-2 h): 7 original queries + 3 new (below); title-only triage, max ~15 papers; citation tracking on Yu 2020, McCauley 2020, Duan 2024 using "Search within citing articles"; log in `literature/search_log.md` (date, query, paper, what they did, what they did not do, how mine differs); classify kill / partial overlap / background; write prior-art notes (McCauley+Yu, Acta Neuropathol 2024, Duan 2024, BTK-STING 2026, Prudencio 2015, Menden 2023); write a 3-4 sentence novelty statement afterwards. **Kill rule: stop if one paper already does ALS+FTD transcriptomic node selection for cGAS-STING followed by structure-based screening.**
   - Queries: (1) `STING AND (ALS OR "amyotrophic lateral sclerosis" OR "frontotemporal") AND (docking OR "virtual screening")` (2) `cGAS AND ALS AND docking` (3) `C9orf72 AND "single-nucleus" AND (interferon OR STING)` (4) `"Boltz-2" AND (STING OR neuro*)` (5) `STING inhibitor AND "blood-brain barrier" AND "virtual screening"` (6) `"Mendelian randomization" AND (STING OR cGAS OR TBK1) AND (ALS OR "amyotrophic lateral sclerosis" OR FTD)` (7) `"druggable genome" AND ALS AND "Mendelian randomization"` (8) `(ALS OR "amyotrophic lateral sclerosis") AND (FTD OR "frontotemporal") AND transcriptom* AND ("drug repurposing" OR "network pharmacology")` (9) `("ALS" AND "FTD") AND (cGAS OR STING) AND (transcriptome OR "RNA-seq")` (10) `"RiMod-FTD" AND (drug OR repurposing OR docking)`. Boltz-2 appeared in 2025, so direct competitors must be 2025-2026.
3. Pre-registration review: read whole `PREREG.md` once; do not edit v1; add a dated amendment A3 only if something material no longer matches. Literature findings change framing/title, not analysis rules.
4. Download NYGC counts file; match sample columns to metadata (before any DE); apply A2 definitions; infer sex from RNA-seq (e.g., XIST, RPS4Y1/DDX3Y).
5. QC -> DESeq2 (primary frontal cortex; sensitivity runs) -> fgsea + node table -> export gene lists.
6. Repeat for GSE67196 (pathway-level primary) and RiMod-FTD (download Supp Table 1 + FigShare counts).
7. Compare nodes across arms (spectrum-level rule), then network pharmacology, genetic layer, target decision, docking, Boltz-2, MD.

## 10. Top risks (short)
Immune axis may show weak/no signal (report null; stratify by subtype); NYGC lacks age/RIN/C9 in GEO (limitation; RiMod has covariates); small groups in GSE67196 (n=8-10) and RiMod C9 (n=13); NYGC vs other consortia donor overlap (check); composition confounding (neuron loss/gliosis); weak MR instruments for CGAS/STING1; genome-build mismatch in MR; STING conformational flexibility; Boltz-2 memorization; MD compute for replicates + decoy; scoop risk (post preprint early); overclaiming ("prioritized candidates for experimental follow-up" only).

## 11. Suggested first message in the new chat
"Continue my ALS-FTD immune-axis in silico project from the attached handoff file. I'm new to R, using Colab + Git Bash. Please first help me verify my git state (amendments A1/A2), then guide me one step at a time through the literature check."
