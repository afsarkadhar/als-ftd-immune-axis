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
---

# ADDENDUM (append after Section 11 of PROJECT_HANDOFF_ALS-FTD_immune-axis.md)
# Progress log, session 2: 2026-11-15 (covers everything done after the original handoff)

> How to use this addendum: Sections 12.1 to 12.12 are the running record. Sections 1 to 11 above are the state at the end of session 1 (2026-10-20/21). Where they conflict, this addendum is newer. Append every future major step as a new dated block under Section 12.13 onward, in the same style (what we did, what we changed, why, what is next, draft methods wording).

## 12.1 Working preferences added in this session
- One step at a time, with: what to do, "Done when:", and "Common problems:".
- Before pasting code into RStudio: create the file via File -> New File -> R Script, **save it under its final name first**, check the tab name, paste, Ctrl+S, then Source. (An earlier paste into the wrong tab overwrote `00_install_packages.R`; recovered with `git checkout`.)
- **Order rule for amendments:** write the amendment into `PREREG.md`, `git commit` and `git push` it, and only then run the script it governs. (Violated once for A6; see 12.7.)
- Paste printed summaries back to the assistant, not CSV files.
- Never use `git add .`; add named files. Never `--amend` or force-push amendments or history; use dated notes instead.
- Do not look at individual candidate-gene results (CGAS, STING1, JAK1, JAK2, IRF3, TBK1) until all pre-registered models are fitted and the robustness rule is committed.
- The assistant is an AI; before submission a human bioinformatician or the PI should read the pre-registration and results.

## 12.2 Environment (changed from Section 7)
- **Colab is gone** (session lost; no longer usable). Kaggle notebooks no longer offered R. **Everything now runs locally.**
- Laptop: Acer One Z14-55N, Intel Core i3-N305, 8 GB RAM (7.75 usable), 238 GB disk (about 114 GB free at the time). Fine for the transcriptomics (about 210 samples per run, DESeq2 takes 10 to 30 min). Docking with Vina/PyRx is feasible but slow (CPU only; filter libraries first). **Boltz-2 rescoring and molecular dynamics are NOT feasible locally (need a GPU); plan a cloud GPU route before the docking stage.**
- R 4.6.2 (2026-10-29) + RStudio Desktop, Windows. Bioconductor 3.23.
- Project: `D:/als_ftd_project` (RStudio project `als_ftd_project.Rproj`), git remote `afsarkadhar/als-ftd-immune-axis`, branch `main`, Git Bash (UCRT64).
- Packages (recorded in `docs/session_info.txt`): DESeq2 1.52.0, fgsea 1.38.0, sva 3.60.0, limma 3.68.5, msigdbr 26.1.1, ggplot2 4.0.4, data.table 1.18.6.1, plus dplyr, readr, matrixStats, BiocManager. `readxl` still to be installed when needed.
- `.gitignore` ignores `data/raw/*`, `data/processed/*`, `.Rhistory`, `.RData`, `.Rproj.user/`. Raw and processed data are never committed.
- Known R gotcha: Bioconductor packages mask `dplyr::count()`, `filter()` etc. Use `dplyr::` prefixes.

## 12.3 Git/record verification at the start of the session
`git log` confirmed A1, A2, A3 and A4 were committed with timestamps before any DE, plus the NYGC exclusion log, mapped metadata and frontal inferred sex (commit `a169395`). The four QC files produced in Colab (`nygc_frontal_outlier_check.csv`, `nygc_frontal_A23a_extra_inferred_sex.csv`, `nygc_cervical_outlier_check.csv`, `nygc_cervical_inferred_sex.csv`) were confirmed present in the repo (they were already tracked).
Row counts matched A4: frontal 210 (154 ALS + 56 control), extra A2.3a samples 47 (201 - 154), cervical 196 (155 + 41).

## 12.4 Data pipeline built (scripts in `scripts/`, all committed)
| Script | Purpose |
|---|---|
| `00_install_packages.R` | Installs packages, writes `docs/session_info.txt` |
| `01_download_nygc.R` | Downloads NYGC RSEM counts into `data/raw/` |
| `02_check_sample_ids.R` | Confirms the 210 frontal IDs exist in the counts header |
| `03_load_frontal_counts.R` | Loads the 210 frontal columns, rounds to integers, saves `data/processed/nygc_frontal_primary.rds` |
| `04_reproduce_pca.R` | Reproduces the Colab PCA in R |
| `05_qc_outliers.R` | Applies the pre-registered outlier rule in R |
| `06_design_check.R` | Design matrix, balance and rank check (no model fitted) |
| `07_deseq2_frontal_primary.R` | DESeq2 primary model (GEO-only covariates) |
| `08_gene_id_map.R` | Ensembl-to-symbol map, node and marker mapping check |
| `09_deseq2_frontal_composition.R` | DESeq2 composition-adjusted model |

Counts source: `https://ftp.ncbi.nlm.nih.gov/geo/series/GSE153nnn/GSE153960/suppl/GSE153960_Gene_counts_matrix_RSEM_Prudencio_et_al_2020.txt.gz` (71.1 MB; 58,929 genes; 1,659 sample columns).

**Bug found and fixed (before any analysis used the wrong data):** the raw file has an unlabelled row-number column, so the header has 1,660 fields but every data row has 1,661. The first loader shifted all samples by one column (symptoms: gene IDs printed as `1 2 3` and a parsing warning). Fixed by reading with `skip = 1, col_names = c("row_id", header)` and a `stopifnot(nrow(problems(raw)) == 0)` guard. The wrong `.rds` was deleted and rebuilt. After the fix: gene IDs are `ENSG...` with version suffixes, library sizes 10.8 to 76.8 million.

**Verification that the corrected loader is right:** recomputing the PCA in R reproduced the saved Colab PC1 and PC2 with |correlation| = 1.0000. Colab settings were therefore: blind VST, top 500 most variable genes, unscaled `prcomp`, after the Sec. 4 gene filter (>=10 counts in >=56 samples; 19,748 of 58,929 genes pass).

## 12.5 QC and outlier flags
- `zPC1`/`zPC2` in the saved file are within-group z-scores (group = ALS or control).
- **`flag_A` = the pre-registered rule** (|z| > 3 on PC1 or PC2 within group). It flags 3 frontal samples: `CGND-HRA-01908` (control), `CGND-HRA-01913` and `CGND-HRA-01918` (ALS); all NovaSeq. Re-implemented in R (`05_qc_outliers.R`); identical set; output `results/nygc_frontal_outlier_check_R.csv`.
- `flag_B` (4 samples, adds `CGND-HRA-01263`, an ALS HiSeq sample with unremarkable PC1/PC2) could not be identified from several variant definitions. **It is not pre-registered and is not used for any decision.** Cervical (as read from the saved file): `CGND-HRA-00132` flagged by both, `CGND-HRA-01915` by A only.
- Decision: the outlier sensitivity run uses flag_A only (A5.2 records this).

## 12.6 Design check (frontal primary, 154 ALS vs 56 control)
Group x platform: ALS 70 HiSeq (GPL16791) / 84 NovaSeq (GPL24676); control 18 / 38 (Fisher p = 0.113). Group x sex: ALS F69/M85, control F26/M30 (p = 0.876). Design `~ platform + sex + group` is full rank (4 of 4). Control is the reference level, so positive log2FC means higher in ALS. Platform and library prep are perfectly confounded (one batch term).

## 12.7 Amendments (all in `PREREG.md`)
- **A1 to A4**: as in Sections 6 and 12.3 (data limitations, FTD arm, exact group definitions, count inputs and independence checks, sample reconciliation).
- **A5 (2026-11-15, before any DESeq2 result):** implementation details only. (1) DESeq2 Wald test with default size factors, dispersion, Cook's handling and independent filtering after the Sec. 4 count filter; design `~ platform + sex + group` for NYGC frontal; lfcShrink for plots only, never for the Wald statistic given to fgsea. (2) Outlier sensitivity uses the Sec. 3 rule only (flag_A); flag_B not used. (3) Ensembl version suffixes removed; Ensembl IDs mapped to HGNC symbols via msigdbr annotation; the six nodes identified by symbol after a mapping check. (4) Fixed cell-composition marker sets: neuron (RBFOX3, SNAP25, SYT1), astrocyte (GFAP, AQP4, SLC1A2), microglia (CX3CR1, P2RY12, TMEM119), oligodendrocyte (MBP, PLP1, MOG); exploratory vascular set (CLDN5, PECAM1, VWF); marker score = mean blind-VST expression. (5) Order of analyses: frontal primary, then sensitivities (outliers removed, NovaSeq-only, sva, composition), then cervical; A2.3a (201 vs 56) after the primary.
- **A6 (committed `d858bbd`):** composition sensitivity model uses PCs 1 to 3 of the four marker scores (centred, scaled): `~ platform + sex + compPC1 + compPC2 + compPC3 + group`; the vascular set goes only into a labelled exploratory model; caveat fixed in advance that composition adjustment may remove real disease signal (neuron loss and gliosis are part of ALS), so both adjusted and unadjusted results are reported with their inflation.
- **Process incident (A6):** A6 was written into `PREREG.md` before the composition model was run but committed only afterwards (13 seconds before the model commit `25f1b35`), so git cannot show the order. A dated "NOTE ON A6" was drafted to record this (version: "written before the run, committed after"). 
- **Not yet committed / drafted:** a revised sva amendment (SV count rule via `sva::num.sv` method "be", set.seed(1), cap 10; `svaseq` full model `~ platform + sex + group`, null `~ platform + sex`; diagnostics including correlation of SVs with group, platform, sex, composition PCs, log library size and outlier flag; flag if any SV has |r| > 0.5 with group; model hierarchy statement). **Renumbering decided: metadata/covariates amendment = A7, sva = A8, robustness rule = A9.** A separate amendment is needed to fix the C9orf72 label definition before any C9 comparison.

## 12.8 Results so far (NYGC frontal cortex, ALS spectrum vs control; FDR < 0.05 unless stated)
Files in `results/`, all full gene tables (19,748 tested genes), committed.

| Model | FDR<0.05 | up / down | FDR<0.05 and abs(log2FC)>=0.5 | Genomic inflation* |
|---|---|---|---|---|
| Primary (GEO-only): `~ platform + sex + group` | 12,665 | 6,058 / 6,607 | 2,089 | 20.34 |
| + composition PCs 1-3 (A6) | 12,039 | 6,009 / 6,030 | 1,106 | 17.33 |

*median Wald statistic squared / 0.4549.
Other facts: DESeq2 size factors 0.49 to 3.36; 44 genes refit after Cook's outlier handling (primary). Composition PCs explain 38.2%, 26.3%, 22.1%, 13.4% of marker-score variance. Files: `results/nygc_frontal_primary_deseq2_all_genes.csv`, `results/nygc_frontal_composition_deseq2_all_genes.csv`, `results/nygc_frontal_composition_covariates.csv`.
**Interpretation (fixed):** about 60% of expressed genes being "significant" with inflation above 17 is not a believable disease signature; it indicates unmodelled confounding (tissue quality, site, age, composition). **No candidate-gene result has been viewed.** Gene ID map: 18,406 Ensembl-symbol pairs from Hallmark + GO:BP annotation; 13,575 of 19,748 tested genes have a symbol (expected: only genes in gene sets); no Ensembl ID maps to more than one symbol; **all six nodes and all 15 marker genes map one-to-one and pass the count filter** (`results/gene_id_map_msigdbr.csv`).

## 12.9 New information: NYGC flagship preprint and supplementary metadata
- Preprint: "The New York Genome Center ALS Consortium resource integrates postmortem tissue transcriptomics and whole genome sequencing to empower biological discovery" (Humphrey et al.; medRxiv, doi 10.64898/2026.04.29.26350889, posted May 4, 2026; not peer reviewed). RNA-seq is GEO **GSE137810** (2,906 samples; 2,574 analysed; 695 donors), a larger freeze than our GSE153960. Code: GitHub `jackhump/NYGC_ALS_Flagship`. Add to `literature/prior_art_notes.md`: from the text read, they report immune GO terms up in spinal cord and higher microglia/lymphocyte proportions, cite McCauley 2020 (C9orf72, myeloid cells, STING), but did not appear to test cGAS-STING nodes specifically (verify before citing).
- Consortium's own frontal cortex case-control analysis (266 ALS vs 74 controls, covariates: library prep, mean read length, percent chimeras): **10,403 DEGs**. So very large DEG counts are characteristic of this cohort, not a bug in our pipeline.
- Within-ALS C9orf72 carriers vs non-carriers: frontal cortex **1 DEG** (29 vs 224); cervical spinal cord **1,236 DEGs** (35 vs 257). The C9 signal is tissue-specific; a null in frontal cortex is plausible and must be reported as such. Cervical secondary is well placed.
- C9orf72 status in the preprint: consensus of ExpansionHunter (>=30 repeats, PCR-free WGS) and repeat-primed PCR, site reports only for PCR-based samples; 506 donors annotated as pathogenic expansion carriers; consortium excluded RNA samples with RIN below 2.5.
- Supplementary tables: Zenodo community `nygc_als`, record "All metadata and supplementary tables for NYGC ALS Consortium" (v3, May 8, 2026). Files: `NYGC_Flagship_ST_1_3_Metadata.xlsx` (sheets: Dictionary, Member list, ST1 donor-level, ST2 WGS mutation annotations, ALS gene list, ST3 RNA metadata), `..._ST_4_16_expression.xlsx`, `..._ST_17_31_splicing.xlsx`, `..._ST_32_35_genetics.xlsx`.
- **Do not open ST4 or ST11-16 for the six nodes yet** (published DEGs for the same data; a peek, and not independent replication).

## 12.10 Metadata coverage check (metadata only, no expression)
- ST3 key `rna_id` matches our `CGND-HRA-xxxxx` sample IDs. Coverage: frontal **204 of 210** (the 6 missing are all controls, all NovaSeq: `CGND-HRA-01988, 02036, 02041, 02054, 02097, 02105`; reason unknown), extra A2.3a samples 47 of 47, cervical 194 of 196 (missing `01683` ALS, `02114` control). ST3 -> ST1 link via `donor_id` (all donors found; one frontal sample per donor).
- Validation: RNA-inferred sex agrees with ST1 `sex_call` in **204 of 204**; platform matches `rna_prep` (HiSeq 2500 = manual KAPA, NovaSeq = automated KAPA).
- Covariates available (frontal, 204 matched): RIN all present (range 2.0 to 8.9; ALS mean 6.17, control 5.71); age at death present but text with top-coding ("90 or older"); specimen collection site present; **pH missing in about 48% (98/204) and PMI in about 28% (58/204), so both fail the v1 rule (covariate missing in >20% is dropped).** (An earlier message said about 52% for pH; 48% is correct.)
- **Site is strongly confounded with disease in frontal cortex (ALS / control):** Academic Medical Center 36/10, Barrow 16/1, Columbia 28/1, Georgetown 6/6, Johns Hopkins 26/7, MGH/Johns Hopkins 1/0, University College London 21/24, UC San Diego 20/1. A site-adjusted disease effect is therefore identified mainly from UCL, AMC, JHU and Georgetown. Site is not in our two fitted models and is a likely driver of the inflation.
- C9 labels (not yet fixed): ST2 lists 503 C9orf72-annotated donors (474 "ALS single gene", 19 "Oligo", 10 "RF/Carrier/Intermed"), versus 506 in the preprint; among the 154 frontal ALS samples 27 have a C9orf72 annotation (25 single-gene), plus 1 annotated control. ST1 also has `c9orf72_genotype` (ExpansionHunter) and `c9orf72_rp_pcr`. The definition must be fixed in an amendment first.
- Other ST3 fields of note: `used_in_analysis` (consortium QC flag; 2 frontal ALS samples are FALSE), `MEAN_READ_LENGTH`, `PCT_CHIMERAS`, `MEDIAN_5PRIME_BIAS`, expression PCs.

## 12.11 Rationale for the next design (record for the paper's framing)
PREREG v1 Sec. 4 already specified age at death, sex, RIN and batch/site/platform as covariates; A1 reduced this to platform + sex only because GEO lacked them. The supplementary metadata restores the originally pre-registered design. Framing: the GEO-only models (inflation 20.3 and 17.3) become reported sensitivity analyses; the restored design becomes the primary, via a dated amendment committed BEFORE the model is fitted. State openly that this change followed seeing inflation in the GEO-only models.
Proposed A7 content (draft, not yet committed): primary `~ platform + sex + age + RIN + site + group`, complete cases (expected 154 ALS vs 50 controls); pH and PMI dropped (>20% missing); age top-coded values recoded to 90 and any other non-numeric values checked by the script; published-model sensitivity using the consortium's frontal covariates (RNA prep, mean read length, percent chimeras); a reported model without site; the 6 unmatched controls excluded from these models and reported; C9 definition deferred to its own amendment.

## 12.12 Draft methods wording (edit before use)
- *Data.* Bulk RNA-seq gene-level RSEM expected counts for frontal cortex from the NYGC ALS Consortium (GEO GSE153960) were rounded to integers. Analysed samples: 154 ALS-spectrum and 56 non-neurological control donors (one frontal sample per donor) after reconciling the counts matrix to GEO metadata (19 count columns without metadata, 1 thoracic duplicate and 197 metadata rows without counts excluded; logged).
- *Quality control.* Sex was inferred from RNA-seq (XIST and Y-linked genes) and agreed with consortium-reported sex in 204/204 matched samples. Outliers were defined as samples more than 3 SD from the within-group PC1/PC2 mean (blind variance-stabilised data, top 500 variable genes); three samples were flagged and sensitivity analyses run with and without them.
- *Differential expression.* DESeq2 (v1.52.0, Wald test) after filtering genes with at least 10 counts in at least 56 samples (19,748 genes); models and covariates as specified in the pre-registration and amendments A1 to A9; Benjamini-Hochberg FDR < 0.05. Genomic inflation was computed as the median squared Wald statistic divided by 0.4549 and reported for every model.
- *Pre-registration.* Hypotheses, nodes, thresholds and gates were registered in git before any DE result was viewed; all later changes are dated amendments, including one process note (A6 ordering). Models were fitted in the order stated in A5.5 and all models are reported.

## 12.13 Open items and next steps (in order)
1. **Verify** the "NOTE ON A6" is in `PREREG.md` and committed.
2. Record provenance of the metadata: save `NYGC_Flagship_ST_1_3_Metadata.xlsx` in `data/raw/`, run `sha256sum`, create `docs/nygc_metadata_source.md` (Zenodo record title, version v3 May 8 2026, URL, license, file name, hash) and commit. Check the license before committing any derived donor-level table. Also save the preprint's data-use terms in `docs/`.
3. Draft, **commit and push A7 (metadata covariates)** before any model uses it; then write the R script that merges ST1/ST3 (metadata only first: coverage, age recoding, site table) and fit the A7 primary and its pre-specified sensitivities.
4. Remaining pre-registered frontal sensitivities: outliers removed (flag_A), NovaSeq-only (84 vs 38), sva (A8, committed first), vascular exploratory model; then A2.3a (201 vs 56) and cervical secondary (155 vs 41).
5. **Robustness rule (A9) committed before any node is viewed**: a node or pathway is "robust" only if significant in the primary model and same direction in every sensitivity model; otherwise "model-dependent".
6. Then: six-node family test (BH over 6 genes, alongside genome-wide), fgsea on the Wald statistic (Hallmark sets + KEGG hsa04623, 1,000 size-matched random sets), exported gene lists.
7. Fix the C9orf72 label definition (amendment), then C9 vs sporadic and C9 vs control within NYGC (cervical especially), after reconciling ST2 (503) with the paper (506).
8. Download GSE67196 (pathway-level primary, small n) and RiMod-FTD (Supp Table 1 + FigShare counts); donor-overlap checks (note: any NYGC-derived dataset such as GSE137810 is NOT independent of GSE153960).
9. Update `literature/prior_art_notes.md` with the new preprint; revisit the novelty statement.
10. Later stages unchanged (network layer, genetic layer, target decision, docking, Boltz-2, MD), with a cloud GPU plan needed before Boltz-2/MD.

## 12.14 Risks added or sharpened
Site, age, RIN and tissue-quality confounding explain the large inflation until shown otherwise (site is near-aliased with disease at several sites); frontal C9 effects may be null (consortium found 1 DEG); possible overreliance on one model (mitigated by the robustness rule); not independent of the consortium's own published results (same data); six controls lack metadata (loss of 6 of 56 controls in adjusted models); C9 label inconsistencies between ST2 and the paper; local hardware cannot run Boltz-2 or MD; risk of process slips (committing amendments after running models), mitigated by the order rule in 12.1.

## 12.15 Suggested first message for the next chat
"Continue my ALS-FTD immune-axis project from the attached handoff file and its 2026-11-15 addendum. I run R and RStudio locally on Windows (Colab is gone), use Git Bash, and I'm new to R and transcriptomics. First help me verify git (the NOTE ON A6, provenance file), then guide me one step at a time: commit the metadata amendment (A7) before fitting the metadata-adjusted frontal model. Keep recording each major step as an addendum block I can paste into the handoff file."
---

# ADDENDUM 2 (append after Section 12.15 of the handoff file; same day, 2026-11-15, later part of session 2)
# Covers: extra metadata sources checked, what was moved into data/raw/, exact git state at the end of the chat, the draft of Amendment A7, and the revised next steps. **This supersedes the "Open items and next steps" list in Section 12.13.**

## 12.16 Other metadata sources checked (metadata only; no expression values, no gene-level results)

**Decision on sources**
- **Primary source = NYGC flagship supplementary tables** (Zenodo v3, 2026-05-08): `NYGC_Flagship_ST_1_3_Metadata.xlsx`.
- **Tam et al. 2019 supplement:** could not be found; **not needed**, because O'Neill 2025 Table S1B already lists 176 samples labelled "Tam et al. 2019" with their subtype labels.
- **Eshima et al. 2023** (Nat Commun, PMC9822908): behind a paywall; it was only ever a cross-check; **dropped**.
- **Humphrey et al. 2023** (Nat Neurosci, spinal cord): not checked. Only possibly useful later for the cervical secondary. Not needed for A7.
- Zenodo did not ask for or display a licence at download. The licence is a field on the record page (sidebar); still to be read and recorded.

**O'Neill et al. 2025** (Cell Reports 44:115402, doi 10.1016/j.celrep.2025.115402, PMC12011103; CC BY-NC-ND 4.0 per the paper)
- The publisher-site downloads (`mmc1.pdf`, `mmc2.xlsx` to `mmc9.xlsx`, `mmc10__1_.pdf`) were **Cloudflare "Just a moment..." bot-check pages** (about 6.5 KB each) saved with data file names. Only `mmc10.pdf` (47 pages: the article plus supplementary Figures S1 to S7) was real. All fake files should be deleted.
- Real tables came from the **PMC author-manuscript supplements**: `NIHMS2069122-supplement-1.pdf` (figures), **`-3.xlsx` = Table S1 (sheets S1A to S1J)**, `-4` = Table S2 (published DE per subtype, 56 MB), `-5` = S3, `-6` = S4, `-7` = S5, `-8` = S6, `-9` = S7, `-10` = S8 (consortium member list). `-2` was not downloaded/identified.
- **Table S1B** (776 samples): Sample, Tissue (FCX 344, MCX 136, latMCX 153, medMCX 143), Patient ID, Group, RIN, pH, Sequencing platform, Collection site, ALS Subtype, Cohort ("This study" 600, "Tam et al. 2019" 176). **Table S1C** (433 patients): PatientID, Sex, Group, Detailed description, Site of Motor Onset Detail, Age at Symptom Onset, Age at Death, Disease Duration in Months, Post Mortem Interval in Hours, Cause of Death, Comorbidities, "C9 repeat expanded, >=30", ATXN2 repeat, PatientMutation, PatientSubtype, Cohort.
- **Coverage of our samples:** 147 of the 210 frontal IDs are in S1B (110 ALS spectrum = 109 ALS + 1 ALS+FTD; 37 controls); **0 of 196 cervical** (cortex only).

**Cross-validation of O'Neill S1B/S1C against the flagship ST1/ST2/ST3 (147 matched frontal samples)**
| Check | Result |
|---|---|
| donor ID vs ST3 | agree 143/143 where both exist (4 of the 147 are not in ST3) |
| RIN vs ST3 | identical 143/143 |
| pH where both have a value | identical 70/70 (pH missing in 77/147 in S1B) |
| platform | agree 143/143 |
| collection site | agree 141/143 |
| C9 status (S1C) vs flagship ST2 labels | no disagreement wherever both defined: 14 "Yes" all in ST2, 70 "No" all absent from ST2; 26 blank in S1C, of which ST2 labels 2 as C9 and 24 as not |

**ALS subtype labels in our frontal ALS samples (110 labelled):** ALS-Ox 81, ALS-TE 25, **ALS-Glia only 4** (controls 37, no subtype). Subtype vs C9 (S1C, ALS only): Ox 9 yes/51 no/21 blank; TE 5/16/4; Glia 0/3/1.
**Consequence:** a frontal cortex subtype analysis cannot test an ALS-Glia-specific interferon signal (4 vs 37). The Sec. 12 fallback ("test by published subtype") would need motor cortex samples (not in the current design); to be decided in a separate amendment, not now.

**Age text values** (S1C): "90 or Older", "Unknown", "Not Applicable" (12 non-numeric); flagship also top-codes as "90 or older".

**What O'Neill 2025 says that matters for the project (read from text and figures; unverified against tables)**
- Cohort: 773 frontal and motor cortex samples, 431 donors (GEO GSE137810, same consortium data; not independent of our data). C9 expansion in about 14% of ALS-spectrum cases (repeat-primed PCR for Target ALS samples). Analyses used RIN >= 5.5 samples; Figure S2 reports that subtype calls do not track collection site or platform.
- Subtypes by DANCer (cortex, patient level): ALS-Ox 70%, ALS-TE 20%, ALS-Glia 10%; in matched spinal cord ALS-Glia-cord is about 71% of patients.
- Interferon: in single-nucleus motor cortex, ALS-Glia astrocytes and microglia show interferon alpha/gamma and inflammatory gene sets up, whereas ALS-TE and ALS-Ox sit below controls (Figs 6C, 7C); ALS-Glia L5ET neurons up for IFI6/IFIT1 (text). **Hypothesis only:** an interferon signal may be concentrated in a minority subtype and diluted in a group-level ALS vs control test. They did not appear to test cGAS-STING nodes specifically. Add to `literature/prior_art_notes.md`.
- Rule: published subtype DE tables (O'Neill S2 to S7) and flagship ST4 to ST16 are results on the same data. **Do not open them for the six nodes** until the pipeline and robustness rule are locked.

**Source rules (settled)**
1. Flagship ST1/ST2/ST3 are primary (covers 204/210 frontal, 47/47 extra samples, 194/196 cervical).
2. O'Neill S1B/S1C are used only for validation, subtype labels (110 samples) and the C9 cross-check; they never override the flagship tables; blanks stay missing.
3. Any disagreement is reported, and analyses are run with and without the affected donors.

## 12.17 Files moved into `data/raw/` (gitignored; verified not tracked by git)
`ls -l data/raw/` showed:
- `GSE153960_Gene_counts_matrix_RSEM_Prudencio_et_al_2020.txt.gz` (71,066,165 bytes)
- `NIHMS2069122-supplement-3.xlsx` (197,500 bytes)
- `NYGC_Flagship_ST_1_3_Metadata.xlsx` (4,136,212 bytes)

SHA-256:
- `NYGC_Flagship_ST_1_3_Metadata.xlsx`: `c1bf21493c4a2773e27ff787e60267fc2e1304ce11e84e644c03c700cc68f048`
- `NIHMS2069122-supplement-3.xlsx`: `2a630f02de5a0c98ef983ab9d7e4ea6e707f7b50c0d09557b352d24d33a99796`

Deliberately NOT placed in the project: flagship `ST_4_16_expression.xlsx`, `ST_17_31_splicing.xlsx`, `ST_32_35_genetics.xlsx`, and O'Neill supplements -4 to -9 (published results on the same data).

## 12.18 EXACT GIT STATE AT THE END OF THIS CHAT (verify first in the new chat)
Last pushed commits (from `git log`): `25f1b35` composition model; `d858bbd` A6; `7d26859` gene ID map; `77b4c3b` QC outlier script; `27d6b6d` primary DESeq2; plus earlier ones. `git status` at the end showed:
- `PREREG.md` **modified, not committed**: it contains the **NOTE ON A6** (the "written before the run, committed after" version). The diff output was cut off by the pager at "had been vie:", so **check the last line is complete** (`tail -n 1 PREREG.md | fold -w 120`; it should end with "...before the script it governs is run.").
- `docs/PROJECT_HANDOFF_ALS-FTD_immune-axis.md` **modified, not committed** (+120 lines; this is addendum 1).
- `docs/nygc_metadata_source.md` **not created yet**.
- **A7 is NOT yet in `PREREG.md`** (draft text is in 12.20).
- No model using the new covariates has been fitted. No gene-level result has been viewed.

## 12.19 Draft content for `docs/nygc_metadata_source.md` (create, then commit)
```markdown
# Provenance of NYGC supplementary metadata (downloaded 2026-11-15)

## 1. NYGC ALS Consortium flagship resource (primary metadata source)
- Source: Zenodo community nygc_als, record "All metadata and supplementary tables for NYGC ALS Consortium", version v3 (May 8, 2026)
- Record URL: [paste from browser]
- Paper: Humphrey et al., medRxiv doi 10.64898/2026.04.29.26350889 (preprint, not peer reviewed)
- File used: NYGC_Flagship_ST_1_3_Metadata.xlsx (sheets: ST1 donor-level, ST2 WGS annotations, ST3 RNA metadata)
- SHA-256: c1bf21493c4a2773e27ff787e60267fc2e1304ce11e84e644c03c700cc68f048
- License: [paste the licence line from the Zenodo record page, or "not yet recorded"]
- Stored in data/raw/ (gitignored; not committed)

## 2. O'Neill et al. 2025 supplement (validation, subtype and C9 cross-check only)
- Source: Cell Reports 44:115402 (2025), doi 10.1016/j.celrep.2025.115402, PMC12011103 (author manuscript supplement)
- File used: NIHMS2069122-supplement-3.xlsx (Table S1; sheets S1B sample-level, S1C patient-level)
- SHA-256: 2a630f02de5a0c98ef983ab9d7e4ea6e707f7b50c0d09557b352d24d33a99796
- License: CC BY-NC-ND 4.0 (stated in the paper). Tables analysed, not redistributed; not committed.
- Note: the first download attempt from the publisher site returned bot-check web pages, not data; those files were discarded.

## 3. Not used (published DEG or other results for the same data; deliberately not opened for the candidate nodes)
- NYGC_Flagship_ST_4_16_expression.xlsx, ST_17_31_splicing.xlsx, ST_32_35_genetics.xlsx
- O'Neill supplement tables S2 to S7
```

## 12.20 DRAFT Amendment A7 (NOT yet committed; review, then append to `PREREG.md` and commit BEFORE any model uses it)
```markdown

## AMENDMENT A7 (2026-11-15; written before any model using the new covariates was fitted. The GEO-only primary and composition models had already been fitted (genomic inflation 20.3 and 17.3). The new metadata was inspected only for coverage, balance and agreement between sources; no expression values or gene-level results were viewed using it.)
Basis: NYGC flagship supplementary tables (Zenodo v3, 2026-05-08) and O'Neill et al. 2025 Table S1 (hashes and licences in docs/nygc_metadata_source.md).
1. Sources. Primary: flagship ST3 (RNA metadata, key rna_id = GEO counts column name) linked to ST1 (donor level) by donor_id. O'Neill 2025 Table S1B/S1C is used only to validate (it agreed with ST3 on RIN 143/143, pH 70/70 where both present, platform 143/143, site 141/143, and with ST2 on C9 labels wherever both were defined). It never overrides the flagship tables. Disagreements are reported and analyses are run with and without the affected donors.
2. Rationale. Sec. 4 of v1 specified age at death, sex, RIN and batch/site/platform as covariates; A1 reduced the model to platform and sex only because GEO lacked the rest. A7 restores the originally registered covariates now that they are available. This change was motivated by the large inflation in the GEO-only models and is stated as such.
3. Primary model, NYGC frontal cortex (replaces the A5.1 design as the primary; control is the reference): ~ platform + sex + age_at_death + RIN + site + group. Platform is ST3 rna_platform (identical to library prep; one term). Sex is the RNA-inferred sex (equal to ST1 sex_call in 204/204 matched samples). Site is ST1 site_specimen_collected; sites with fewer than 5 samples in the analysed set are merged into "Other". Complete cases only; expected 154 ALS-spectrum vs 50 controls.
4. Covariate coding. Age at death is numeric; the text "90 or older" is recoded to 90; any other non-numeric value is treated as missing and the sample is excluded from the complete-case models. RIN is used as given. pH and post-mortem interval are not used (missing in about 48% and 28% of the matched samples, above the v1 threshold of 20%).
5. Exclusions. The 6 frontal controls absent from ST3 (CGND-HRA-01988, 02036, 02041, 02054, 02097, 02105) and any sample with a missing covariate are excluded from the A7 models and listed with the reason in results/nygc_frontal_A7_exclusions.csv. They remain in the GEO-only models.
6. Checks before fitting: the design matrix must be full rank; the group-by-site, group-by-platform and group-by-sex tables and the variance inflation of each covariate are reported. If the design is not full rank, the analysis stops and a further amendment is written.
7. Pre-specified sensitivities (all reported): (a) the consortium's published frontal cortex covariates from ST3 (library prep, MEAN_READ_LENGTH, PCT_CHIMERAS) plus group; (b) the A7 primary without site; (c) the GEO-only models already fitted (A5 primary and A6 composition); (d) the A5.5 outlier-removed (flag_A) and NovaSeq-only runs, using the A7 primary design. Surrogate-variable (sva) and composition-adjusted variants of the A7 design are specified in separate amendments (A8 and later) before they are run.
8. Model hierarchy. The A7 model is the primary; everything else is a sensitivity analysis. No model is promoted because it has lower inflation or a more favourable result for the immune axis. The robustness rule is fixed in a later amendment before any candidate node's results are viewed.
9. Disclosure. When this amendment was designed, it was already known that collection site is strongly imbalanced between cases and controls in the frontal set (for example 28 ALS vs 1 control at one site and 21 vs 24 at another), so the site-adjusted effect is identified mainly from sites with both groups.
10. Not used here. C9orf72 status and ALS subtype labels are not used in A7. In the frontal set only 4 samples carry the ALS-Glia label (81 ALS-Ox, 25 ALS-TE among the 110 labelled), so the Sec. 12 subtype fallback is limited in this tissue; how to handle it is decided in a separate amendment.
11. No thresholds, gene sets, nodes, gates or scoring weights change. Numbering: sva is A8, the robustness rule A9.
```
Notes on the draft: the supervisor-style choices to confirm before committing are (i) site in the primary model (near-aliased with disease at several sites), (ii) merging sites with fewer than 5 samples, (iii) no RIN filter (RIN is a covariate; O'Neill used RIN >= 5.5 for alignment), (iv) complete-case rule. Site counts in the matched frontal set (ALS / control): Academic Medical Center 36/10, Barrow 16/1, Columbia 28/1, Georgetown 6/6, Johns Hopkins 26/7, MGH/Johns Hopkins 1/0, University College London 21/24, UC San Diego 20/1. (O'Neill S1B for its 147 samples additionally lists Mount Sinai with 4 controls; the two sources agree on site in 141/143 samples.)

## 12.21 Revised next steps (in order; supersedes 12.13)
1. **Verify and commit the pending record, in three separate commits, then push:**
   `tail -n 1 PREREG.md | fold -w 120` (check the NOTE ON A6 is complete) -> create `docs/nygc_metadata_source.md` (12.19; paste the Zenodo licence line or write "not yet recorded") -> `git add docs/nygc_metadata_source.md` + commit; `git add PREREG.md` + commit "Note on A6..."; `git add docs/PROJECT_HANDOFF_ALS-FTD_immune-axis.md` + commit; `git push`; `git status` must be clean. Never `git add .`; never `--amend` or force-push.
2. **Decide the open choices in A7 (12.20 notes), append A7 to `PREREG.md`, commit and push BEFORE running anything that uses the new covariates.**
3. Write `scripts/10_merge_metadata.R` (R, readxl; **metadata only, no model**): read ST3 + ST1, link by `rna_id` and `donor_id`, recode age ("90 or older" -> 90), merge sites with fewer than 5 samples, build the A7 analysis table, write `results/nygc_frontal_A7_exclusions.csv`, print group-by-site/platform/sex tables, check full rank and variance inflation. Commit script and exclusions file. Install `readxl` first (`install.packages("readxl")`).
4. Fit the A7 primary (frontal, 154 vs 50) and its pre-specified sensitivities (7a to 7d), saving full tables; report genomic inflation for every model.
5. Write and commit **A8 (sva)** before running sva (SV count by `sva::num.sv` method "be", set.seed(1), cap 10; `svaseq` full model `~ platform + sex + group`, null `~ platform + sex`; diagnostics: SV correlation with group, platform, sex, composition PCs, log library size, outlier flag; flag SVs with |r| > 0.5 with group). Script number 11 or later.
6. Write and commit **A9 (robustness rule)** before any node is viewed: a node or pathway is "robust" only if significant in the primary model and in the same direction in every sensitivity model, otherwise "model-dependent".
7. Separate amendments still to write: **C9orf72 label definition** (primary source flagship ST2 plus ST1 EH/RP-PCR columns; reconcile 503 donors in ST2 vs 506 in the preprint; O'Neill S1C as cross-check; rule for disagreements); **subtype analysis** decision (frontal has only 4 ALS-Glia; consider motor cortex only through a dated amendment).
8. Then the six-node family test (BH over 6 genes, alongside genome-wide), fgsea on the Wald statistic (Hallmark sets + KEGG hsa04623, 1,000 size-matched random sets), exported gene lists; cervical secondary (155 vs 41; flagship covers 194/196); A2.3a (201 vs 56; 47/47 covered).
9. Later: GSE67196 (pathway-level primary) and RiMod-FTD (donor-overlap checks; any NYGC-derived dataset such as GSE137810 is not independent of GSE153960); update `literature/prior_art_notes.md` with the flagship preprint and O'Neill 2025; network layer, genetic layer, target decision, docking; cloud GPU plan for Boltz-2/MD.

## 12.22 Draft methods wording added in this part (edit before use)
- *Metadata and covariates.* Sample-level technical and donor-level clinical metadata (RIN, age at death, sex, collection site, library preparation) were taken from the NYGC ALS Consortium supplementary tables (Zenodo, v3) and matched to count columns by RNA sample ID; an independent supplement (O'Neill et al., 2025, Table S1) agreed with these for RIN, platform, pH and site in at least 141 of 143 overlapping samples, and for C9orf72 status wherever both sources assigned a label. pH and post-mortem interval were excluded because more than 20% of values were missing.
- *Limitation to state.* Collection site is strongly imbalanced between cases and controls in frontal cortex, so site-adjusted estimates rely mainly on sites contributing both groups; consortium-wide widespread DE (about 10,000 genes in frontal cortex in the consortium's own analysis) means high DEG counts are expected in this cohort. Subtype-specific analyses in frontal cortex are underpowered (4 ALS-Glia samples).

## 12.23 Additional working notes
- Time/effort rule: ask the assistant to "log this step" after each major step; it returns an addendum block in this format to append.
- When a chat gets long, start a new one with: the handoff file (with all addenda) attached, plus the suggested first message below.
- Corrections to earlier statements in this session: pH missing is about 48% (98/204), not 52%; the "four QC files" were already tracked in git (not missing); two scripts were swapped once (recovered with `git checkout`).

## 12.24 Suggested first message for the next chat
"Continue my ALS-FTD immune-axis project from the attached handoff file and its addenda (sections 12.1 to 12.24). I run R and RStudio locally on Windows (Colab is gone), use Git Bash, and I'm new to R and transcriptomics. First help me verify and commit my pending git state (the NOTE ON A6 in PREREG.md, docs/nygc_metadata_source.md, the handoff file), one step at a time. Then guide me to finalise and commit Amendment A7 (metadata covariates) before any model uses it, then write the metadata-merge script (no model yet). Keep recording each major step as an addendum block I can paste into the handoff file."

---

# ADDENDUM 3 (append after Section 12.24 of the handoff file; same day, 2026-11-15, later part of session 2)
# Covers: git state verified and pushed, provenance file, the four A7 design decisions, A7 and A7b committed, metadata merge (script 10), A7 primary DESeq2 (script 11) and its summary numbers, new working notes, and the revised next steps. **This supersedes the "Revised next steps" list in Section 12.21.**

## 12.25 Git record completed (all pushed; verified)
- NOTE ON A6 checked complete (last line ends "...before the script it governs is run."), then committed.
- `docs/nygc_metadata_source.md` created with the real values: Zenodo record https://zenodo.org/records/20090702 (DOI 10.5281/zenodo.20090702), licence CC BY 4.0, SHA-256 values as in 12.19. Committed.
- Handoff file (addenda 1 and 2) committed.
- Push problem and fix: the first two pushes failed (`curl 52 Empty reply from server`, then `HTTP 408`). Fixed with `git config http.version HTTP/1.1` (set for this repo only); the push then worked. Commits were never lost.
- Commit order in `git log` (oldest to newest): `385c308` provenance file; `b67ca13` Note on A6; `9498219` handoff update; `e1c1eb4` Amendment A7; `395b388` Amendment A7b; `f3acf47` script 10 and exclusions file; `5aa2f2f` script 11 (committed BEFORE it was run, as the A6 process change requires); `64610b5` A7 primary DESeq2 results table.
- At the last check `git status` was clean except `results/nygc_frontal_A7_analysis_table.csv` (untracked on purpose; script 10 regenerates it).

## 12.26 Decisions made for A7 (the four open choices; all fixed before any model used the new covariates)
1. Collection site stays in the primary model (matches v1 Sec. 4; the site-free model is sensitivity 7b).
2. Sites with fewer than 5 samples in the analysed set are merged into "Other" (affects 1 sample: MGH/Johns Hopkins). The near-aliased sites (Barrow, Columbia, UC San Diego; one control each) are NOT merged, to keep the site adjustment intact.
3. RIN is a covariate only, no RIN filter in the primary model; a new sensitivity 7e (RIN >= 5.5 only) was added (O'Neill et al. used 5.5).
4. Complete-case rule kept (no imputation); exclusions are logged in `results/nygc_frontal_A7_exclusions.csv`.
Changes from the draft in 12.20: item 3 states the site and small-site decisions; item 4 states that RIN is a covariate with no filter; item 7 adds sensitivity (e). Everything else is word for word the draft.

## 12.27 Amendments added to `PREREG.md` this part
- **A7** (commit `e1c1eb4`): primary model for NYGC frontal cortex `~ platform + sex + age_at_death + RIN + site + group` (control = reference), restoring the v1 covariates; sources ST3 + ST1 (O'Neill only validates); sensitivities (a) consortium covariates (library prep, MEAN_READ_LENGTH, PCT_CHIMERAS), (b) no site, (c) GEO-only models already fitted, (d) outlier-removed (flag_A) and NovaSeq-only with the A7 design, (e) RIN >= 5.5. Full text is in `PREREG.md`. Note: committing A7b made git show item 11 of A7 as "changed" only because the file had no final newline (`\ No newline at end of file`); the wording was verified identical (check printed IDENTICAL).
- **A7b** (commit `395b388`), as appended:
```markdown
## AMENDMENT A7b (2026-11-15; written before any model using the A7 covariates was fitted. scripts/10_merge_metadata.R had been run, reading metadata only; no expression values or gene-level results were viewed.)
Basis: the A7 metadata merge (scripts/10_merge_metadata.R) showed that 2 of the 154 frontal ALS samples (CGND-HRA-02161 and CGND-HRA-02168, both Barrow Neurological Institute) carry the GEO group label "ALS Spectrum MND" but the flagship ST1 subject_group "ALS Spectrum MND, Other Neurological Disorders", and both are flagged used_in_analysis = FALSE in flagship ST3. The other 152 ALS samples and all 50 controls agree between GEO and ST1.
1. Group definitions are unchanged (A2, A4, A7.3): the A7 primary remains 154 ALS vs 50 controls.
2. New pre-specified sensitivity (f), reported with those in A7.7: the A7 primary design with these 2 samples removed (152 ALS vs 50 controls), with the full-rank check of A7.6 repeated.
3. Record of the A7.6 checks on the primary table: full rank (13 of 13 design columns); largest variance inflation 2.31 (Johns Hopkins site term); RNA-inferred sex agrees with ST1 sex_call in 204 of 204 and platform agrees with ST3 rna_platform in 204 of 204 matched samples; the 6 controls absent from ST3 are excluded as listed in A7.5.
4. No thresholds, gene sets, nodes, gates or scoring weights change.
```

## 12.28 Metadata merge: `scripts/10_merge_metadata.R` (metadata only; no counts, no model; committed in `f3acf47`)
- Spreadsheet quirk: in `NYGC_Flagship_ST_1_3_Metadata.xlsx`, sheets ST1 and ST3 have a title in row 1 and the real header in row 2, so read with `skip = 1` (otherwise columns are named `...2`, `...3`). ST1 has 4,749 donors; ST3 has 2,574 RNA samples. Key columns used: ST3 `rna_id`, `donor_id`, `rin`, `rna_platform`, `rna_prep`, `MEAN_READ_LENGTH`, `PCT_CHIMERAS`, `used_in_analysis`; ST1 `donor_id`, `sex_call`, `site_specimen_collected`, `age_at_death`, `subject_group`.
- Result: of the 210 frontal samples, 204 match ST3 and ST1 (the 6 unmatched are the controls named in A7.5). RNA-inferred sex agrees with ST1 `sex_call` in 204/204; GEO platform agrees with ST3 `rna_platform` (GPL16791 = HiSeq 2500, GPL24676 = NovaSeq V1) in 204/204. No non-numeric age values besides "90 or older" (age 22 to 90); RIN 2.0 to 8.9.
- **Analysed set: 154 ALS vs 50 controls.** Group x platform: HiSeq ALS 70 / control 18; NovaSeq ALS 84 / control 32. Group x sex: ALS F69/M85; control F24/M26. Group x site (ALS / control): Academic Medical Center 36/10; Barrow 16/1; Columbia 28/1; Georgetown 6/6; Johns Hopkins 26/7; Other (the merged MGH/Johns Hopkins sample) 1/0; University College London 21/24; UC San Diego 20/1. About 47 of the 50 controls come from the four sites that have both groups.
- Design check (A7.6): 13 columns, rank 13 (full rank); largest variance inflation 2.31 (Johns Hopkins site term); groupALS 1.26.
- **New finding:** 2 ALS samples (`CGND-HRA-02161`, `CGND-HRA-02168`; both Barrow; RIN 8.0 and 6.5) are labelled "ALS Spectrum MND" in GEO but "ALS Spectrum MND, Other Neurological Disorders" in ST1, and both are the only two frontal ALS samples with `used_in_analysis = FALSE`. Handled by A7b (primary unchanged; sensitivity (f) without them).
- Files: `results/nygc_frontal_A7_exclusions.csv` (committed; 6 controls, reason "not in ST3"); `results/nygc_frontal_A7_analysis_table.csv` (not committed; regenerated by the script).

## 12.29 A7 primary DESeq2: `scripts/11_deseq2_frontal_A7_primary.R` (committed in `5aa2f2f` BEFORE it was run; results committed in `64610b5`)
- Same style as scripts 03 and 07. Guards: exactly 204 samples, 154 ALS / 50 control, design full rank. Count filter (Sec. 4): >= 10 counts in >= 50 samples (smallest group). Wald test, default DESeq2 settings (A5.1), control = reference, contrast ALS vs control (positive log2FC = higher in ALS).
- Summary numbers (the only numbers viewed; **no individual gene and no candidate node has been looked at**): genes after filter 19,902 of 58,929; size factors 0.49 to 3.36; genes refit after Cook's handling 0 (the earlier GEO-only primary had 44); all 19,902 genes have a p-value; **FDR < 0.05: 6,206 genes (3,388 up in ALS, 2,818 down)**; FDR < 0.05 and |log2FC| >= 0.5: 277; **genomic inflation 6.24**.
- Comparison with the GEO-only models: inflation 20.3 (A5 primary) and 17.3 (A6 composition); the A7 covariates removed most of the inflation, but 6.24 is still well above 1. Wide differential expression is expected in this cohort (the consortium reports about 10,000 DEGs in frontal cortex), so a high inflation does not by itself prove residual confounding.
- **Interpretation rule (fixed, per A6 and A7.8):** the A7 model is the primary because it restores the covariates registered in v1 and was specified in advance, NOT because its inflation is lower. All models are reported; none is promoted for a better-looking result.
- DESeq2 messages in the run were harmless (reminders that numeric covariates enter linearly, a note about characters in site names). The fit converged.
- Outputs: `results/nygc_frontal_A7_primary_deseq2_all_genes.csv` (committed; do not open for the six nodes until A9 is committed); `data/processed/nygc_frontal_A7_primary_dds.rds` (gitignored).

## 12.30 Working notes added in this part
- Windows: save new text files from Notepad with "Save as type: All Files" so the name does not end in `.txt`. `readxl` installed fine; the Rtools warning during `install.packages` was harmless (a binary package was used).
- Git habits that worked: add files by name only (never `git add .`); check `git diff --stat` before committing; a "1 deletion" in the diff can be only a missing final newline (`\ No newline at end of file`), verified by comparing the old and new last line.
- Process rule kept: each amendment and each script is committed and pushed before it is run or before the analysis it governs.
- Do NOT open or paste gene-level result files or the flagship ST4 to ST16 / O'Neill S2 to S7 tables for the six nodes until the robustness rule (A9) is committed.
- The "log this step" request works: ask for an addendum block after each major step.

## 12.31 Revised next steps (in order; supersedes 12.21)
1. **Append this addendum to the handoff file, commit and push** (`git add docs/PROJECT_HANDOFF_ALS-FTD_immune-axis.md` only).
2. **Sensitivity script (script 12; commit it before running it):** run the A7 design variants listed in A7.7 and A7b, saving full tables and printing summary numbers only (genes after filter, FDR counts, inflation): (a) consortium covariates (library prep, MEAN_READ_LENGTH, PCT_CHIMERAS + group); (b) A7 without site; (d) A7 with flag_A outliers removed (3 samples: CGND-HRA-01908 control, 01913 and 01918 ALS) and NovaSeq-only (the platform term must be dropped because it has a single level; the A7 balance table gives 84 ALS vs 32 control); (e) RIN >= 5.5 only; (f) without the 2 discordant donors (152 vs 50). Check full rank for each design (stop if not). Sensitivity (c) is already fitted. Planned details such as the count filter n per run are to be confirmed before writing the script.
3. **Write and commit A8 (sva) before running sva:** SV count by `sva::num.sv` (method "be", `set.seed(1)`, cap 10); `svaseq` full model `~ platform + sex + group`, null `~ platform + sex`; diagnostics (SV correlation with group, platform, sex, composition PCs, log library size, outlier flag; flag SVs with |r| > 0.5 with group). Decide in the amendment which covariates the sva variant of the A7 design uses.
4. **Write and commit A9 (robustness rule) before any node is viewed:** a node or pathway is "robust" only if significant in the primary model and in the same direction in every sensitivity model, otherwise "model-dependent".
5. Separate amendments still to write: C9orf72 label definition (primary source flagship ST2 plus ST1 EH/RP-PCR columns; reconcile 503 donors in ST2 vs 506 in the preprint; O'Neill S1C as cross-check; rule for disagreements); subtype analysis decision (frontal has only 4 ALS-Glia; consider motor cortex only through a dated amendment).
6. Then: six-node family test (BH over 6 genes, alongside genome-wide), fgsea on the Wald statistic (Hallmark sets + KEGG hsa04623, 1,000 size-matched random sets), exported gene lists; cervical secondary (155 vs 41; flagship covers 194/196); A2.3a (201 vs 56; 47/47 covered).
7. Later: GSE67196 (pathway-level primary) and RiMod-FTD (donor-overlap checks; any NYGC-derived dataset such as GSE137810 is not independent of GSE153960); update `literature/prior_art_notes.md` with the flagship preprint and O'Neill 2025; network layer, genetic layer, target decision, docking; cloud GPU plan for Boltz-2/MD.

## 12.32 Draft methods wording added in this part (edit before use)
- *Primary model.* Differential expression in NYGC frontal cortex (154 ALS-spectrum cases, 50 controls) used DESeq2 (Wald test) with the design `~ platform + sex + age at death + RIN + collection site + group`; covariates were taken from the consortium's supplementary tables, sites with fewer than 5 samples were merged, and complete cases were analysed. Genes were retained with at least 10 counts in at least 50 samples (19,902 genes). The model was specified in a dated pre-registration amendment (A7) and committed before it was fitted; sensitivity analyses (A7.7, A7b) are reported alongside it.
- *Limitation to state.* Two ALS samples carry discordant disease labels between GEO and the consortium's donor table and are excluded in a pre-specified sensitivity analysis; collection site is imbalanced between groups, so the site-adjusted estimate relies mainly on four sites with both groups; the genomic inflation factor of the primary model was 6.24, consistent with widespread expression differences in this tissue but not proof of the absence of residual confounding.

## 12.33 Suggested first message for the next chat
"Continue my ALS-FTD immune-axis project from the attached handoff file and its addenda (sections 12.1 to 12.33). I run R and RStudio locally on Windows, use Git Bash, and I'm new to R and transcriptomics. First help me verify git (`git log --oneline -9` should end with 64610b5 and `git status` should be clean except for the untracked A7 analysis table), then guide me one step at a time through the sensitivity script (A7.7 and A7b), committing it before I run it. Then A8 (sva) and A9 (robustness rule) before any node is viewed. Do not open gene-level results for the six nodes yet. Keep recording each major step as an addendum block I can paste into the handoff file."

---

# ADDENDUM 4 (append after Section 12.33 of the handoff file; same day, 2026-11-15, later part of session 2)
# Covers: the pre-specified A7 sensitivity analyses (script 12) with their summary numbers, how to read them, what they imply for the robustness rule (A9), and the revised next steps. **This supersedes the "Revised next steps" list in Section 12.31.**

## 12.34 Git record (all pushed)
- Addendum 3 pushed as `5bcdeb4`.
- `scripts/12_deseq2_frontal_A7_sensitivities.R` was committed and pushed BEFORE it was run (the push just before the results commit ended at `9745667`; verify with `git log --oneline -4`).
- Results commit `c9a4dd3`: 13 files (6 full all-genes tables, 6 per-run summaries, the combined summary). Message notes that 7e has only 40 FDR genes and that no gene-level results were viewed.
- At the last check `git status` was clean except `results/nygc_frontal_A7_analysis_table.csv` (untracked on purpose; script 10 regenerates it).

## 12.35 Script 12: pre-specified sensitivities (A7.7 and A7b)
- Six runs on the same frontal samples, all with control as reference, Wald test, contrast ALS vs control, DESeq2 defaults:
  - 7a consortium covariates: `~ prep + MEAN_READ_LENGTH + PCT_CHIMERAS + group` (the two numeric covariates are centred and scaled; same model, better numerical conditioning).
  - 7b A7 primary without site.
  - 7d (i) A7 primary with the 3 pre-registered flag_A outliers removed (`CGND-HRA-01908` control, `01913` and `01918` ALS; flag column in the outlier file is `flag_prereg`).
  - 7d (ii) A7 primary on NovaSeq samples only (platform term dropped; it has one level).
  - 7e A7 primary on samples with RIN >= 5.5 only.
  - 7f A7 primary without the 2 label-discordant donors (A7b).
- Count filter in every run follows Sec. 4: >= 10 counts in >= n samples, n = the smallest group in that run. Genes kept therefore differ slightly between runs.
- Guards: A7.6 full-rank check for every design before fitting; run stops if any is not full rank. A pre-flight mode (`PREFLIGHT_ONLY <- TRUE` before `source()`) builds designs and prints sample counts without fitting.
- Pre-flight (all full rank): 7a 154 vs 50 (5 columns); 7b 154 vs 50 (6); 7d outliers 152 vs 49 (13); 7d NovaSeq 84 vs 32 (12); 7e 110 vs 33 (13); 7f 152 vs 50 (13).
- Resumable: each finished run saves a summary file and is skipped on rerun.
- **Gotcha:** the first full attempt stopped at "Pre-flight only" because `PREFLIGHT_ONLY` was still TRUE in the R session from the pre-flight run (the script only sets it when it does not exist). Fix: set `PREFLIGHT_ONLY <- FALSE` before `source()`, or restart R. No data were affected.
- Outputs: `results/nygc_frontal_A7_sens_<run>_deseq2_all_genes.csv`, `..._summary.csv`, and `results/nygc_frontal_A7_sensitivity_summary.csv`.

## 12.36 Results: summary numbers only (no gene, no candidate node viewed)
| Model | ALS vs control | Genes after filter | FDR < 0.05 (up / down) | FDR < 0.05 and abs(log2FC) >= 0.5 | Inflation |
|---|---|---|---|---|---|
| A7 primary | 154 vs 50 | 19,902 | 6,206 (3,388 / 2,818) | 277 | 6.24 |
| 7a consortium covariates | 154 vs 50 | 19,902 | 10,262 (5,301 / 4,961) | 766 | 11.72 |
| 7b no site | 154 vs 50 | 19,902 | 11,427 (5,703 / 5,724) | 1,383 | 15.11 |
| 7d outliers removed | 152 vs 49 | 19,888 | 6,058 (3,262 / 2,796) | 285 | 6.11 |
| 7d NovaSeq only | 84 vs 32 | 20,200 | 5,007 (2,732 / 2,275) | 694 | 4.90 |
| 7e RIN >= 5.5 | 110 vs 33 | 19,896 | **40** (16 / 24) | 17 | 2.04 |
| 7f without discordant donors | 152 vs 50 | 19,888 | 6,180 (3,369 / 2,811) | 279 | 6.23 |
- Genes refit after Cook's handling: 0 in every run (the earlier GEO-only primary had 44). Earlier GEO-only models: inflation 20.3 (A5 primary) and 17.3 (A6 composition).

## 12.37 Interpretation (fixed for the paper; no model is promoted for a better-looking result)
- Collection site is the dominant technical factor: removing it raises inflation from 6.24 to 15.11 and almost doubles the number of significant genes; the consortium covariates alone (7a) also leave inflation high (11.72). This supports keeping site in the primary model.
- The primary result is not driven by the 3 outlier samples or the 2 label-discordant donors (7d outliers and 7f are nearly identical to the primary) and not by sequencing platform (NovaSeq-only still gives 5,007 genes, inflation 4.90).
- **7e is the important caveat.** With RIN >= 5.5 only 40 genes remain (inflation 2.04). Two explanations, not mutually exclusive: lower power (110 vs 33 samples) and RNA-quality dependence of part of the broad signal (RIN is adjusted only linearly in the primary; ALS RIN is slightly higher than control RIN on average). A rough effective-sample-size calculation suggested power alone would lower inflation to roughly 4, not 2; this calculation was not verified and assumes effects are spread evenly across genes, so treat it as a pointer, not a finding. State in the paper that the primary result is sensitive to RNA quality and that 7e is the lowest-power run.
- Genome-wide DEG counts differ a lot between models, so they should not be a headline result; claims should rest on node-level and pathway-level results judged by the robustness rule.

## 12.38 Implication for A9 (robustness rule; to be written and committed before any node is viewed)
- Draft rule (from 12.21): a node or pathway is "robust" only if significant in the primary model and in the same direction in every sensitivity model, otherwise "model-dependent".
- **Disclosure needed in the A9 header:** the summary counts of all sensitivity runs (including the small 7e result) had been seen when A9 was written; no node-level or gene-level result had been viewed. The rule must be justified on principle and not tuned to how any node behaves.
- Open choices for A9 to settle before writing: which models count as "every sensitivity model" (7a, 7b, 7d x2, 7e, 7f, the A5 and A6 GEO-only models, and sva once A8 is run); how to treat 7e given its low power (direction concordance only, not significance); and whether a direction check uses the sign of the Wald statistic for each node.

## 12.39 Working notes added in this part
- R keeps variables between runs in the same session: reset flags such as `PREFLIGHT_ONLY` explicitly, or use Session -> Restart R.
- `git add results/nygc_frontal_A7_sens_*` (a pattern limited to named files) is acceptable; still never `git add .`.
- The laptop (i3-N305, 8 GB RAM) completed all six fits in one session; the A7 primary and the sensitivities use the same data size.
- Gene-level result files are on disk and committed but have NOT been opened for the six nodes.

## 12.40 Revised next steps (in order; supersedes 12.31)
1. **Append this addendum to the handoff file, commit and push** (`git add docs/PROJECT_HANDOFF_ALS-FTD_immune-axis.md` only).
2. **Optional metadata-only check of RIN (no model, no expression):** compare the RIN distribution between ALS and control in the A7 table (and, for the paper, state the 7e sample loss by group: 44 ALS and 17 control samples removed). Proposed, not yet decided; anything modelled beyond this would need a dated amendment labelled exploratory.
3. **Write and commit A8 (sva) before running sva:** SV count by `sva::num.sv` (method "be", `set.seed(1)`, cap 10); `svaseq` full model `~ platform + sex + group`, null `~ platform + sex`; diagnostics (SV correlation with group, platform, sex, composition PCs, log library size, outlier flag; flag SVs with |r| > 0.5 with group). The amendment must also say which covariates the sva variant of the A7 design includes, and whether it enters the A9 rule.
4. **Write and commit A9 (robustness rule) before any node is viewed**, with the disclosure in 12.38 and the open choices settled.
5. Separate amendments still to write: C9orf72 label definition (primary source flagship ST2 plus ST1 EH/RP-PCR columns; reconcile 503 donors in ST2 vs 506 in the preprint; O'Neill S1C as cross-check; rule for disagreements); subtype analysis decision (frontal has only 4 ALS-Glia; consider motor cortex only through a dated amendment).
6. Then: six-node family test (BH over 6 genes, alongside genome-wide), fgsea on the Wald statistic (Hallmark sets + KEGG hsa04623, 1,000 size-matched random sets), exported gene lists, each across all models under the A9 rule; cervical secondary (155 vs 41; flagship covers 194/196); A2.3a (201 vs 56; 47/47 covered).
7. Later: GSE67196 (pathway-level primary) and RiMod-FTD (donor-overlap checks; any NYGC-derived dataset such as GSE137810 is not independent of GSE153960); update `literature/prior_art_notes.md` with the flagship preprint and O'Neill 2025; network layer, genetic layer, target decision, docking; cloud GPU plan for Boltz-2/MD.

## 12.41 Draft methods and limitations wording added in this part (edit before use)
- *Sensitivity analyses.* The primary model was refitted under six pre-specified variations: consortium technical covariates only, without collection site, without three pre-registered expression outliers, in NovaSeq samples only, in samples with RIN >= 5.5, and without two donors with discordant disease labels between GEO and the consortium donor table. Each was fitted with the same DESeq2 settings and the count filter was applied per run using that run's smallest group.
- *Limitation to state.* The primary result depended on RNA quality: restricting to RIN >= 5.5 (110 cases, 33 controls) left 40 significant genes at FDR < 0.05, compared with 6,206 in the primary model, because of reduced power and possible RIN-dependent signal; removing collection site from the model raised the genomic inflation factor from 6.24 to 15.11.

## 12.42 Suggested first message for the next chat
"Continue my ALS-FTD immune-axis project from the attached handoff file and its addenda (sections 12.1 to 12.42). I run R and RStudio locally on Windows, use Git Bash, and I'm new to R and transcriptomics. First help me verify git (`git log --oneline -6` should include c9a4dd3, the sensitivity results, and `git status` should be clean except for the untracked A7 analysis table). Then guide me one step at a time: the optional RIN metadata check, then A8 (sva) and A9 (robustness rule), each committed before it is used and before any node is viewed. Do not open gene-level results for the six nodes yet. Keep recording each major step as an addendum block I can paste into the handoff file."

---

# ADDENDUM 5 (append after Section 12.42 of the handoff file; same day, 2026-11-15, later part of session 2)
# Covers: RIN metadata check (with a correction to the 7e reading in addendum 4), Amendment A8 (sva), the sva script and its results, and the revised next steps. **This supersedes the "Revised next steps" list in Section 12.40.**

## 12.43 Git record (all pushed)
- Addendum 4 pushed as `2a1eb3c`.
- `aaada90` Amendment A8 (committed before any surrogate variable existed); `cf5bb33` `scripts/13_sva_frontal_A8.R` (committed BEFORE it was run); `10b2289` A8 results (4 files).
- At the last check `git status` was clean except `results/nygc_frontal_A7_analysis_table.csv` (untracked on purpose; script 10 regenerates it).

## 12.44 RIN metadata check (descriptive; A7 table only; no counts, no model, no gene result)
- RIN by group: ALS n = 154, mean 6.17, SD 1.42, median 6.60; control n = 50, mean 5.71, SD 1.23, median 5.70; Wilcoxon W = 4809.5, p = 0.008 (descriptive; this check was not pre-specified). By platform: HiSeq ALS 6.30 (n = 70) vs control 5.58 (n = 18); NovaSeq ALS 6.06 (n = 84) vs control 5.79 (n = 32). So RNA quality is partly tied to disease status, and RIN is adjusted only as a straight line in the primary model.
- The RIN >= 5.5 filter removed a similar share of each group (44 of 154 ALS = 29%; 17 of 50 controls = 34%) but not evenly across sites. Samples kept (ALS / control; before the filter in brackets): University College London 14 / 21 (21 / 24); Academic Medical Center 24 / 4 (36 / 10); Johns Hopkins 15 / 3 (26 / 7); Georgetown 4 / 2 (6 / 6); Barrow 12 / 1 (16 / 1); Columbia 22 / 1 (28 / 1); UC San Diego 18 / 1 (20 / 1); Other 1 / 0.
- **Correction to addendum 4 (12.37 and 12.41), which stays as written in that addendum:** in sensitivity 7e, 21 of the 33 controls (64%) come from one site (UCL), so the ALS vs control contrast is identified almost entirely at that site. Low power and a reshaped site structure explain the small number of significant genes in 7e at least as well as RNA-quality dependence does. The rough effective-sample-size calculation in 12.37 ignored the site structure and is superseded. Paper wording: state that RIN differs between groups and that RIN >= 5.5 leaves a control set dominated by one site; treat 7e as a low-information run, not as evidence that the primary signal is an RNA-quality artefact. For A9, 7e is checked for direction only.
- Decision: no RIN-spline or other extra RIN model is added (another analyst choice; sva estimates hidden quality-related structure). Any such model would need its own dated amendment labelled exploratory before it is run.

## 12.45 Amendment A8 (commit `aaada90`)
- One sva analysis, on the A7 set (NYGC frontal cortex, 154 ALS vs 50 control), disease group protected. **Deviation from A2.3(c):** the GEO-only sva (154 vs 56; platform and sex) is not run, because A7 replaced that design as the primary and the GEO-only set lacks the registered covariates; this is stated in A8.1.
- Input: integer counts after the A7 filter (19,902 genes). svaseq full model `~ platform + sex + age_at_death + rin + site + group`, null `~ platform + sex + age_at_death + rin + site`. SV count by `num.sv` (method "be", seed 1), cap 10, `set.seed(1)` before every sva call. Diagnostics saved before any DESeq2 fit; an SV with |r| > 0.5 with group is flagged, and then a second model without it is also fitted. sva is a sensitivity analysis and is not promoted; its role in A9 is fixed in A9.

## 12.46 sva run: `scripts/13_sva_frontal_A8.R` (summary numbers and diagnostics only; no gene viewed)
- Software: sva 3.60.0 (Bioconductor 3.23, R 4.6.2). Installing printed harmless notes (base R packages not updatable without admin rights).
- `num.sv` estimate: 1; SVs used: 1. SV1 diagnostics: r with group 0.23 (not flagged); r with platform -0.44; r with sex 0.09; r with age 0.02; r with RIN 0.13; r with log library size -0.90; site R-squared 0.42. SV1 is mainly a sequencing-depth factor that also tracks platform and site.
- Because no SV was flagged, no "without flagged SVs" model was fitted.
- DESeq2 with SV1 (design = A7 design + SV1, 14 columns, full rank): FDR < 0.05 6,332 genes (3,375 up in ALS, 2,957 down); FDR < 0.05 and |log2FC| >= 0.5 280; genomic inflation 6.37; Cook's refit 0. A7 primary for comparison: 6,206 (3,388 / 2,818), 277, 6.24.
- Interpretation: the A7 primary is stable under sva. Inflation did not fall (6.37 vs 6.24), so no single hidden technical factor explains the remaining inflation. It may reflect real broad biology (neuron loss, gliosis), which cannot be proven from these numbers; the paper should say "consistent with", not more. The sva model is not promoted.
- Files: `results/nygc_frontal_A8_sva_diagnostics.csv`, `results/nygc_frontal_A8_svs.csv`, `results/nygc_frontal_A8_sva_summary.csv`, `results/nygc_frontal_A8_sva_all_SVs_deseq2_all_genes.csv` (all committed; the all-genes table has NOT been opened for the six nodes).

## 12.47 Model inventory so far (all NYGC frontal cortex; summary numbers only)
GEO-only A5 primary (154 vs 56; inflation 20.3); GEO-only A6 composition (154 vs 56; 17.3); **A7 primary** (154 vs 50; 6,206 FDR genes; 6.24); 7a consortium covariates (11.72); 7b no site (15.11); 7d outliers removed (152 vs 49; 6.11); 7d NovaSeq-only (84 vs 32; 4.90); 7e RIN >= 5.5 (110 vs 33; 40 FDR genes; 2.04); 7f without the 2 discordant donors (152 vs 50; 6.23); A8 sva (154 vs 50; 6,332; 6.37).

## 12.48 Working notes added in this part
- In R, no output after `library(pkg)` means it loaded; check with `"package:pkg" %in% search()` and `packageVersion("pkg")`.
- Console text is cleared with Ctrl+L; the broom icon in the Environment pane removes objects from memory (nothing on disk is deleted). Session -> Restart R before heavy runs.
- To do: record sva 3.60.0 in `docs/session_info.txt` (rerun `sessionInfo()` output into that file or note the version) before the methods section is written.
- Gene-level result files remain unopened for the six nodes.

## 12.49 Revised next steps (in order; supersedes 12.40)
1. **Append this addendum to the handoff file, commit and push** (`git add docs/PROJECT_HANDOFF_ALS-FTD_immune-axis.md` only).
2. **Write and commit A9 (robustness rule) before any node is viewed.** Header must disclose that summary counts of all sensitivity runs, the RIN check and the sva diagnostics had been seen, and that no node-level or gene-level result had. Settle in A9: which models count as "every sensitivity model" (7a, 7b, 7d x2, 7e, 7f, A8 sva, and the GEO-only A5 and A6 models); that 7e and the GEO-only models are checked for direction only; that direction is the sign of the Wald statistic.
3. Separate amendments still to write: C9orf72 label definition (primary source flagship ST2 plus ST1 EH/RP-PCR columns; reconcile 503 donors in ST2 vs 506 in the preprint; O'Neill S1C as cross-check; rule for disagreements); subtype analysis decision (frontal has only 4 ALS-Glia; consider motor cortex only through a dated amendment).
4. Then, for the first time: six-node family test (BH over 6 genes, alongside genome-wide), fgsea on the Wald statistic (Hallmark sets + KEGG hsa04623, 1,000 size-matched random sets), exported gene lists, each across all models under the A9 rule; cervical secondary (155 vs 41; flagship covers 194/196); A2.3a (201 vs 56; 47/47 covered).
5. Later: GSE67196 (pathway-level primary) and RiMod-FTD (donor-overlap checks; any NYGC-derived dataset such as GSE137810 is not independent of GSE153960); update `literature/prior_art_notes.md` with the flagship preprint and O'Neill 2025; network layer, genetic layer, target decision, docking; cloud GPU plan for Boltz-2/MD.

## 12.50 Draft methods and limitations wording added in this part (edit before use)
- *Surrogate variables.* Hidden technical variation was estimated with sva (v3.60.0; svaseq on the filtered integer counts; number of surrogate variables by `num.sv`, method "be", capped at 10; known covariates in both full and null models; disease group protected). One surrogate variable was estimated; it correlated strongly with sequencing depth and weakly with disease group (r = 0.23) and was added to the primary design as a sensitivity analysis, giving a result near-identical to the primary model.
- *Limitation to state.* RNA integrity differed between groups (ALS mean RIN 6.17 vs control 5.71); restricting to RIN >= 5.5 left a control set in which 64% of controls came from one collection site, so that analysis has low power and limited ability to separate disease from site.

## 12.51 Suggested first message for the next chat
"Continue my ALS-FTD immune-axis project from the attached handoff file and its addenda (sections 12.1 to 12.51). I run R and RStudio locally on Windows, use Git Bash, and I'm new to R and transcriptomics. First help me verify git (`git log --oneline -6` should include 10b2289, the A8 results, and `git status` should be clean except for the untracked A7 analysis table). Then guide me one step at a time: write and commit A9 (the robustness rule) before any node is viewed, then the C9orf72 label amendment, then the first look at the six nodes across all models. Do not open gene-level results for the six nodes before A9 is committed. Keep recording each major step as an addendum block I can paste into the handoff file."
