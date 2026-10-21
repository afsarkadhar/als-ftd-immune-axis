# Prior-art notes and novelty statement
Project: ALS-FTD cGAS-STING immune-axis prioritization
Written: 2026-10-20. Based on the literature search in `literature/search_log.md` (PubMed and Google Scholar, queries 1-10).
Status of details: most entries below were read at abstract level only. Verify every detail against the full text before citing.

## Novelty statement (approved draft)
To our knowledge, no published study combines (i) separate, cell-type-aware transcriptomic analysis of ALS and FTD brain tissue to select nodes of the cGAS-STING axis with (ii) a brain-penetrance-filtered, structure-based screen of repurposed and natural-product compounds. Existing work addresses parts of this pipeline: genetic prioritization of TBK1 in ALS (Duan 2024), STING-TBK1 interferon signatures in SOD1 ALS models (Hiew 2025), cGAS inhibition in TDP-43 models (Liu 2026), and virtual screening against STING outside neurodegeneration (Liu 2026). The contribution here is integrative: a spectrum-level rule across ALS and FTD, a genetic support layer, an early CNS filter, and a Vina-Boltz-2 consensus with a decoy-controlled MD check. Results are framed as prioritized candidates for experimental follow-up, not validated targets.

Wording rules:
- Keep "to our knowledge". In the methods, state the search scope: "in the searches performed (PubMed and Google Scholar, October 2026)".
- Do not claim "first STING docking or MD in neurodegeneration" (see the 2026 H-151 paper below).
- Do not claim a new mechanism or a new inhibitor class.

## A. Biology that motivates the axis

### McCauley et al., Nature 2020 (doi 10.1038/s41586-020-2625-x) and Yu et al., Cell 2020 (PMC7599077)
- McCauley: loss of C9orf72 in myeloid cells leads to STING hyperactivation; elevated interferon signature in C9 ALS/FTD compared with sporadic.
- Yu: TDP-43 drives mtDNA release and cGAS/STING activation; the STING inhibitor H-151 was protective.
- Use: introduction. Together they justify cGAS-STING as the pre-specified axis across ALS and FTD.

### Neuronal STING activation in ALS and FTD, Acta Neuropathol 2024 (doi 10.1007/s00401-024-02688-z; PMID 38478117 per handoff)
- Use: introduction; supports a neuronal (not only microglial) STING component, which matters for the cell-type-aware design.

### C9ORF72 suppresses JAK-STAT mediated inflammation, iScience 2023 (doi 10.1016/j.isci.2023.106579)
- Use: justification for JAK1/JAK2 as members of the node family.

### Supporting experimental papers (cite briefly)
- Liu et al., bioRxiv 2026 (doi 10.64898/2026.02.24.707791): cGAS elevated in ALS brains and microglia; a human cGAS inhibitor reduced pTDP-43 and reversed mis-splicing in iPSC co-culture and TDP-43 Q331K mice (abstract). Preprint. Find the inhibitor's name in the full text (possible positive control for the docking benchmark).
- Zhan et al., J Ethnopharmacol 2025 (doi 10.1016/j.jep.2024.118741): Semen Strychni Pulveratum and vomicine lowered cGAS-STING-TBK1 activation in SOD1-G93A mice and NSC-34 cells (abstract). Supports including natural products.
- Edaravone/TDP-43/cGAS/STING in BV2 cells, Chin J Clin Anat 2025 (doi 10.13418/j.issn.1001-165x.2025.5.09): network pharmacology plus cell experiments. Minor support.

## B. Closest overlaps (partial overlap, must be engaged in the discussion)

### Duan et al., BMC Med 2024 (doi 10.1186/s12916-024-03314-1; PMID 38443977; PMC10916235): closest prior art
- Druggable-genome MR (cis-eQTL with ALS GWAS) prioritized TBK1; fostamatinib and amlexanox were tested in THP-1 and NSC-34 models.
- Not done (per handoff and abstract; confirm in full text): FTD, transcriptomic node selection across diseases, structure-based screening.
- Effect on my paper: genetic evidence for the axis already exists for ALS. The genetic layer is therefore a support layer, not a claimed novelty.
- TBK1 tension (flag, do not claim to resolve): rare loss-of-function TBK1 mutations cause ALS/FTD, yet MR links higher TBK1 expression (blood) to ALS risk, and TBK1-phospho inhibitors help in cell models.

### Hiew et al., Commun Biol 2025 (doi 10.1038/s42003-025-07790-w)
- Integrated transcriptomics in mouse ALS models, hiPSCs and human ALS spinal cord; conserved interferon-stimulated gene signature (type I predominant in mice, type II in humans); single-cell data point to vascular endothelial cells as an ISG source; STING-TBK1 axis needed for type II ISG induction (abstract).
- Not done (abstract): FTD, C9orf72 focus, frontal cortex, compound screening.
- Effect: my ALS arm will be compared against this. Engage with the type II interferon and endothelial points. Cell-type awareness is partly anticipated here.

### Mol Neurobiol 2024;61(7):3809-3818 (doi 10.1007/s12035-023-03817-7)
- MR and colocalization for 422 actionable proteins in ALS and FTD (FTD GWAS 2,154 cases); hits MARK3, LTBR (ALS), HLA-DRB1, ADH5 (FTD). Abstract names no CGAS, STING1 or TBK1; check the supplement.
- Effect: shows the ALS+FTD MR approach exists; FTD power is limited, which is relevant to my own genetic layer.

### Liu et al., Int J Mol Sci 2026;27(1):338 (doi 10.3390/ijms27010338)
- Virtual screening plus molecular dynamics for pTLR7/pSTING dual-targeting ligands. Not ALS/FTD (per title).
- Effect: method precedent for STING virtual screening; cite as such.

### 2026 computational H-151 paper (not found by my searches; from earlier triage; details unverified)
- Reported as H-151 docking into the STING cyclic dinucleotide pocket with GaMD and MM-GBSA on human STING (PDB 7SII).
- Effect: STING docking plus MD in a neuro context is emerging. Locate the paper, read it, and add it to `search_log.md` as a partial-overlap row. Do not claim novelty for STING docking or MD themselves.

## C. Data and design precedents

### Prudencio et al., Nat Neurosci 2015 (GSE67196)
- C9 vs sporadic ALS in cerebellum and frontal cortex; already reported inflammatory/defense-response enrichment.
- Effect: the immune signal itself is not novel. My contribution is the node-level, cross-disease and cell-type-aware use of it.

### Menden et al., Sci Data 2023 (RiMod-FTD; PMC10692098; ArrayExpress E-MTAB-12647)
- RNA-seq dataset with control, FTD-MAPT, FTD-GRN and FTD-C9orf72 samples from medial frontal gyrus; authors adjusted for sex and pH.
- Effect: FTD arm and replication source. Processed counts are on FigShare, metadata in Supplementary Table 1.

### 2026 BTK-inhibitor/STING-NFkB ALS dataset (GSE299859, GSE299856; experimental)
- iPSC motor neurons and SOD1 mice (from handoff; unverified).
- Effect: possible supportive data; note in prior art.

## D. Background and framing
- Hung lab (Crick/UCL), Cell Rep 2025: nucleic-acid mislocalization in AD and FTD models; framing for shared mechanism.
- Cells 2026 polypharmacology review (doi 10.3390/cells15110962): BBB penetration and patient-heterogeneity hurdles; framing.
- Triazole-based STING inhibitors, Bioorg Med Chem 2025 (doi 10.1016/j.bmc.2025.118484): chemotype reference for library design.
- Reviews in the handoff: existing cGAS/STING inhibitors have poor BBB penetration, PK/off-target problems, and human STING allele diversity.

## E. What the literature check changes
- Framing and title: lead with the integrative, cross-disease and cell-type-aware design; avoid "first" language.
- Analysis rules in PREREG.md: no change required by these findings (literature findings change framing, not analysis rules).
- Open verification items: see "To verify" in `search_log.md`, plus locating the 2026 H-151 paper.
