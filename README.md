# Vagus nerve-mediated neuroimmune modulation (VNIM) and remyelination - analysis code
This repository contains all custom code used for the analyses reported by Le et al.: ImageJ macros for immunofluorescence and histological quantification, IMARIS batch workflows for volumetric colocalization, and R scripts for single-cell RNA sequencing and the linear mixed-effects analysis of g-ratio data. All experiments used the lysolecithin (LPC) mouse model of focal demyelination.

# Code
**1. ImageJ macros**
* Macros are grouped by analysis, with each subfolder named for the markers it quantifies.
* Within each folder, macros run in sequence; the Roman numeral in the filename gives the run order.


**2. IMARIS workflows**

.imsw files are IMARIS batch workflows. Copy the relevant workflow into the folder containing the images to be analysed and apply it to the whole folder; every stack in an experiment is processed through the same workflow.


**3. R scripts**
* **Single-cell RNA sequencing:** All code required to reproduce the scRNA-seq analyses reported in the paper, beginning from the Cell Ranger output matrices.
* **Linear mixed-effects model:** Tests the effect of treatment on g-ratio with axon diameter as a covariate and the animal as the biological unit.
* **Unblinding:** Restores animal and treatment identity to blinded image filenames.

# Data availability
* **Single-cell RNA sequencing data:** Gene Expression Omnibus, accession [GSE325248](https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE325248).
* **Source Data:** Per-panel values, statistical analyses and a summary table of all experiments (number and sex of animals) are provided with the paper.
