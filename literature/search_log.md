# Literature search log
Project: ALS-FTD cGAS-STING immune-axis prioritization
Kill rule: stop if one paper already does ALS+FTD transcriptomic node selection for cGAS-STING followed by structure-based screening.
Classes: kill / partial overlap / background
Exclusion codes: X1 different disease, no cGAS-STING | X2 cGAS-STING but no transcriptomics and no docking/screen | X3 different target pathway or generic method | X4 review/commentary only

## Status
Date: 2026-10-20
Kill rule triggered: NO. All 10 queries run in PubMed and Google Scholar. No paper found that combines ALS+FTD human transcriptomic node selection for cGAS-STING with a structure-based screen.
Closest prior art (partial overlap, abstract-level read): Duan 2024 (BMC Med, TBK1 druggable-genome MR), Hiew 2025 (Commun Biol, STING-TBK1 ISG transcriptomics), Liu 2026 bioRxiv (cGAS inhibition in TDP-43 ALS), Liu 2026 IJMS (pTLR7/pSTING virtual screening + MD, not neuro).
Separate citation-tracking step: not performed (see Limitations).

## Method
- Databases: PubMed and Google Scholar. Preprints are covered only via Google Scholar.
- Query list revised on 2026-10-20: the handoff queries (strict, 3-4 AND groups) returned 0 hits in PubMed, so they were replaced by simplified 2-3 concept queries run in both tools. Kill rule and pre-registered analysis rules unchanged.
- Scan rule: if a query returned about 30 hits or fewer, all titles were scanned and only relevant ones opened. If it returned more than about 50, the titles of the first ~50 were read, about 30 were scanned in detail, and everything not relevant on title was excluded.
- Scholar searches were run with citations included in the results.
- Scholar date filter: <fill in: "Since 2025"? or none>. Sort: <fill in: relevance?>.

## Earlier strict queries (before revision)
- PubMed `STING AND (ALS OR "amyotrophic lateral sclerosis" OR "frontotemporal") AND (docking OR "virtual screening")`: 0 hits
- PubMed `cGAS AND ALS AND docking`: 0 hits
- PubMed `("ALS" AND "FTD") AND (cGAS OR STING) AND (transcriptome OR "RNA-seq")`: 1 hit (Hung lab, Cell Rep 2025, background)

## Search record: final query set (all run 2026-10-20)

| # | Concept | PubMed query | PubMed hits | Scholar query | Scholar hits | Result |
|---|---|---|---|---|---|---|
| 1 | cGAS-STING + ALS + docking | `STING ALS docking` | 0 | `STING "amyotrophic lateral sclerosis" "molecular docking"` | ~208 | Zhan 2025, edaravone/BV2 (partial); triazole STING inhibitors (background) |
| 2 | cGAS-STING + FTD + docking | `STING frontotemporal docking` | 0 | `cGAS STING frontotemporal "virtual screening"` | 23 | none relevant (drug-target affinity DL model: X3) |
| 3 | C9orf72 + STING + drugs | `C9orf72 STING inhibitor` | 4 | `C9orf72 cGAS STING "drug repurposing"` | 33 | PubMed: McCauley 2020, Acta Neuropathol 2024, iScience 2023 (background). Scholar: TYK2/AD-TDP-43, ropinirole (X1/X3) |
| 4 | Transcriptomics + cGAS-STING + ALS | `cGAS STING ALS transcriptome` | 4 | `cGAS STING ALS FTD "RNA-seq" "differential expression"` | 52 | PubMed: none relevant. Scholar: Hiew 2025 (partial), Liu 2026 bioRxiv (partial); Singh tauopathy (X1); Korada 2025 (background) |
| 5 | Repurposing in ALS/FTD | `ALS FTD drug repurposing transcriptome` | 2 | `ALS FTD "network pharmacology" "drug repurposing" interferon` | 4 | PubMed: Mol Neurobiol 2024 MR (partial), Stem Cell Rep 2026 prazosin (background). Scholar: Cells 2026 review (X4) |
| 6 | Single-nucleus C9 immune | `C9orf72 single-nucleus interferon` | 1 | `C9orf72 "single-nucleus" interferon microglia` | ~146 | PubMed: EGLN2/PHD1 (background). Scholar: TDP-43 astrocytic interferon, TIA1/HSP70, microglial mitochondria (background) |
| 7 | MR + cGAS-STING | `Mendelian randomization STING ALS` | 1 | `"Mendelian randomization" TBK1 STING ALS` | ~58 | PubMed: Duan 2024 (partial). Scholar: Duan 2024 again (same paper as the PubMed hit); Frontiers Immunol 2026 peripheral immune landscape of AD (X1) |
| 8 | Druggable-genome MR | `druggable genome ALS Mendelian` | 3 | `"druggable genome" "Mendelian randomization" ALS` | ~141 | PubMed: Duan 2024 (partial), Mol Neurobiol 2024 (partial, already logged), Brain Behav 2026 autophagy MR (X3). Scholar: Yin 2025 mitochondria-related MR (X3) |
| 9 | CNS-penetrant STING screening | `STING inhibitor blood-brain barrier` | 29 | `STING inhibitor "blood-brain barrier" "virtual screening"` | ~453 | PubMed: 29 hits, none listed as relevant. Scholar: Liu 2026 IJMS pTLR7/pSTING virtual screening + MD (partial, method); siSTING DNA-bundle delivery in AD (X1) |
| 10 | Boltz-2 competitors | `Boltz-2 ALS FTD` (and text variants) | 0 | `Boltz-2 ALS FTD` | 0 | none. Plain "Boltz-2" returned irrelevant results and was not screened |

Exclusion counts across Scholar scans: X1 <n>, X2 <n>, X3 <n>, X4 <n>.

## Papers opened and classified

| Paper | What they did | What they did NOT do | How mine differs | Class |
|---|---|---|---|---|
| Duan QQ, Wang H, Su WM, et al. (Chen YP, senior), BMC Med 2024;22:96, doi 10.1186/s12916-024-03314-1, PMID 38443977, PMCID PMC10916235 (TBK1, druggable-genome MR) | Druggable-genome MR prioritizing TBK1 as an ALS repurposing target, with pharmacological verification in vitro | ALS only; no FTD; no transcriptomic node selection across diseases; no structure-based screen (per abstract/handoff; verify in full text) | Mine: ALS+FTD spectrum, transcriptomic node selection, structure-based prioritization; MR is a support layer | partial overlap (closest prior art) |
| Hiew et al., Commun Biol 2025, doi 10.1038/s42003-025-07790-w | Integrated transcriptomics in mouse ALS models, hiPSCs, human ALS spinal cord; conserved ISG signature (type I predominant in mice, type II in humans); single-cell points to vascular endothelial cells as ISG source; STING-TBK1 axis needed for type II ISGs | SOD1-focused; no FTD/C9; no frontal cortex; no compound screening (per abstract) | Mine: ALS+FTD, cell-type aware, structure-based prioritization | partial overlap |
| Liu et al., bioRxiv 2026, doi 10.64898/2026.02.24.707791 (cGAS inhibition, TDP-43 ALS) | cGAS elevated in ALS brains and microglia; a human cGAS inhibitor reduces pTDP-43 and reverses mis-splicing in iPSC co-culture and TDP-43 Q331K mice | Experimental; no computational screen mentioned; inhibitor unnamed in abstract (check full text; possible positive control) | Mine: in silico prioritization; their data support cGAS as a target | partial overlap (preprint) |
| Liu et al., Int J Mol Sci 2026;27(1):338, doi 10.3390/ijms27010338 (pTLR7/pSTING dual-targeting ligands) | Virtual screening plus molecular dynamics for dual-targeting ligands | Not ALS/FTD (per title); no human transcriptomic node selection (verify in full text) | Mine: disease-derived target selection from ALS/FTD transcriptomes, then screening | partial overlap (method only) |
| Mol Neurobiol 2024;61(7):3809-3818, doi 10.1007/s12035-023-03817-7 (MR, ALS+FTD drug targets) | MR + colocalization with cis-eQTL/pQTL instruments for 422 actionable proteins; ALS hits MARK3, LTBR; FTD hits HLA-DRB1, ADH5; FTD GWAS small (2,154 cases) | No CGAS/STING1/TBK1 named in abstract (check supplement); no transcriptomics; no docking | Mine: transcriptomic node selection + screen; MR is a support layer | partial overlap |
| Zhan et al., J Ethnopharmacol 2025, doi 10.1016/j.jep.2024.118741 | Semen Strychni Pulveratum and vomicine reduce cGAS-STING-TBK1 activation in SOD1-G93A mice and NSC-34 cells | No human transcriptomics, no FTD/C9, no docking (verify in full text) | Mine: human data-driven, ALS+FTD, computational screen | partial overlap |
| Edaravone / TDP-43 / cGAS / STING in BV2 cells, Chin J Clin Anat 2025;43(5):555-563, doi 10.13418/j.issn.1001-165x.2025.5.09 | Network pharmacology target prediction plus western/IF in LPS-activated BV2 cells; edaravone lowered TDP-43, cGAS, STING | No human cohort transcriptomics; no docking in abstract | Mine: human brain transcriptomics, ALS+FTD, structure-based screen | partial overlap |
| Hung lab (Crick/UCL), Cell Rep 2025 (nucleic-acid mislocalization in AD and FTD) | iPSC-derived neurons with APP/PSEN1 (AD) and VCP (FTD) mutations; mtDNA mislocalization linked to inflammation | No C9orf72, no ALS arm, no brain transcriptomic cohort, no docking (verify in full text) | Mine: cross-disease human brain transcriptomics + structure-based prioritization | background |
| Cells 2026;15(11):962, doi 10.3390/cells15110962 (polypharmacology review) | Review of multi-node strategies; cGAS-STING, NLRP3, BBB hurdles | No docking pipeline, no new data | Framing only | background (X4) |

## To verify (open the paper, then clear the flag)
- Full-text confirmation of every "did NOT do" statement above before making any strong novelty claim.
- Name of the cGAS inhibitor in Liu 2026 bioRxiv (possible positive control for the docking benchmark).
- Whether CGAS, STING1 or TBK1 were among the 422 proteins in Mol Neurobiol 2024 (supplement).

## Other background papers (cite in introduction; not opened in detail)
- McCauley et al., Nature 2020, doi 10.1038/s41586-020-2625-x (C9orf72 in myeloid cells suppresses STING-induced inflammation)
- Neuronal STING activation in ALS and FTD, Acta Neuropathol 2024, doi 10.1007/s00401-024-02688-z
- C9ORF72 suppresses JAK-STAT mediated inflammation, iScience 2023, doi 10.1016/j.isci.2023.106579 (JAK1/2 are pre-specified nodes)
- Stem Cell Reports 2026, doi 10.1016/j.stemcr.2026.102977 (prazosin as SQSTM1 regulator; different target)
- Targeting EGLN2/PHD1 and astrocytic interferon response, Cell Rep 2024, doi 10.1016/j.celrep.2024.114719
- Triazole-based STING inhibitors, Bioorg Med Chem 2025, doi 10.1016/j.bmc.2025.118484 (chemotype reference for library design)
- Korada et al., PLoS Genet 2025, doi 10.1371/journal.pgen.1012007 (LINE-1 in TDP-43 mouse model)
- Neuronal TDP-43 pathology drives astrocytic interferon response in ALS mice, J Neuroinflammation 2025, doi 10.1186/s12974-025-03658-2
- TIA1 stress granules and HSP70 mRNA in C9orf72 mice, Brain 2025, doi 10.1093/brain/awaf248
- Ma et al., Neurosci Bull 2026, doi 10.1007/s12264-026-01657-8 (microglial mitochondria, cGAS-STING)
- TYK2 in AD brains with TDP-43 pathology, Nat Commun 2026, doi 10.1038/s41467-026-70243-3

## Excluded (by code, not logged individually)
X1: manganese/tau (Environ Health 2026), Singh tauopathy (bioRxiv 2025), ropinirole/TDP-43 hiPSC microglia (bioRxiv 2026), peripheral immune landscape of AD, Front Immunol 2026, doi 10.3389/fimmu.2026.1648591 (AD blood GWAS/MR, genes PTK2B and PLEKHA1; no cGAS-STING, no ALS/FTD, no docking), siSTING DNA-bundle delivery in AD (J Nanobiotechnol 2026)
X3: deep-learning drug-target affinity model (2025), Brain Behav 2026 autophagy-related MR, Yin et al. Mol Neurobiol 2025 mitochondria-related MR

## Limitations
- Keyword searches in two databases with title-based scanning; not exhaustive. Findings are "no relevant paper found", never "no one has done this".
- No separate citation-tracking step (Yu 2020, McCauley 2020, Duan 2024) was performed, by decision. Scholar searches included citations in the results, which is not the same as screening the papers that cite those works.
- Partial-overlap papers were judged from abstracts; "did not do" means "not mentioned in the abstract".
- Boltz-2 was searched only in combination with ALS/FTD (0 hits); plain Boltz-2 results were irrelevant and not screened.
- PubMed query 9 returned 29 hits with none recorded as relevant; titles were not individually logged.
- Preprints are searched only via Google Scholar.
