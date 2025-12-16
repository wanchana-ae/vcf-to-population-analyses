# Genetic Diversity Analysis Pipeline

## 🧬 Workflow Overview

### 1️⃣ ADMIXTURE Workflow

- Convert VCF → PLINK
- Run ADMIXTURE for K = 2–12
- Extract CV errors
- Plot CV error
- Visualize ancestry barplots using StructuRly

### 2️⃣ PCA Workflow

- Convert VCF → GDS using SNPRelate
- Run PCA
- Export PCA.csv
- Generate scatter plot (PC1–PC2) with ggplot2

### 3️⃣ Phylogenetic Tree Workflow

- Convert VCF → FASTA using VCF-kit
- FASTA is already aligned (SNP-based pseudo-alignment)
- Import into MEGA
- Construct phylogenetic tree (ML, NJ, UPGMA, etc.)

```bash
                          ┌──────────────────────────┐
                          │        Input VCF         │
                          │     (Filtered SNPs)      │
                          └─────────────┬────────────┘
                                        │
                  ┌─────────────────────┼─────────────────────┐
                  │                     │                     │
                  ▼                     ▼                     ▼
        ┌────────────────┐   ┌─────────────────────┐   ┌──────────────────────┐
        │ ADMIXTURE Path │   │      PCA Path       │   │ Phylogenetic Path    │
        └───────┬────────┘   └──────────┬──────────┘   └──────────┬───────────┘
                │                       │                         │
                ▼                       ▼                         ▼
   ┌─────────────────────┐   ┌────────────────────────┐  ┌──────────────────────┐
   │ Convert VCF → PLINK │   │ Convert VCF → GDS      │  │ Convert VCF → FASTA  │
   │ (.bed/.bim/.fam)    │   │ using SNPRelate        │  │ using VCF-kit        │
   └─────────┬───────────┘   └──────────┬─────────────┘  └──────────┬───────────┘
             │                          │                           │
             ▼                          ▼                           ▼
 ┌──────────────────────┐     ┌──────────────────────┐    ┌─────────────────────┐
 │ Run ADMIXTURE        │     │ Run PCA              │    │ FASTA is pre-aligned│
 │ Generate Q files     │     │ Export PCA.csv       │    │ Ready for MEGA      │
 └───────────┬──────────┘     └──────────┬───────────┘    └──────────┬──────────┘
             │                           │                           │
             ▼                           ▼                           ▼
 ┌──────────────────────┐      ┌──────────────────────┐    ┌─────────────────────┐
 │ Extract CV error     │      │ Plot PCA using       │    │ Import FASTA into   │
 │ FILE.cv.error        │      │ ggplot2 + ggrepel    │    │ MEGA                │
 └──────────┬───────────┘      └──────────┬───────────┘    └──────────┬──────────┘
            │                             │                           │
            ▼                             ▼                           ▼
 ┌──────────────────────────┐   ┌──────────────────────────┐ ┌──────────────────────┐
 │ Visualize Structure Plot │   │ PCA Scatter Plot         │ │ Build Phylogenetic   │
 │ with StructuRly          │   │                          │ │ Tree in MEGA         │
 └──────────────────────────┘   └──────────────────────────┘ └──────────────────────┘

```

## Admixture Analysis

This shell script (admix.sh) provides for performing population structure analysis using PLINK and ADMIXTURE. The script converts a VCF file into PLINK binary format, runs ADMIXTURE across multiple K values, and extracts cross-validation (CV) errors to help determine the optimal ancestral population number.

### 📌 Features

- Automatic loading of required modules (PLINK and ADMIXTURE)  
- VCF → PLINK binary conversion (.bed, .bim, .fam)
- ADMIXTURE runs for K = 2 to 12
- Uses 10-fold cross-validation
- Parallel execution using 64 threads
- Automatic extraction of CV errors into a summary file
- Simple, single-command usage

### 📂 Requirements  

Make sure the following tools are available in your HPC/Linux environment:

- PLINK
- ADMIXTURE
- Module system (Lmod) with ml load
These are automatically loaded inside the script.

### 🚀 Usage

Run the script with a VCF file as input:

```bash  
chmod +x admix.sh
./admix.sh your_file.vcf
```

Example:

```bash

./admix.sh samples.vcf.gz

```

### 🧬 What the Script Does

#### 1. Load Modules

```bash
ml load plink
ml load admixture
```

#### 2. Convert VCF → PLINK

The script extracts a sample ID from the VCF filename and generates PLINK binary files:

```bash
plink --double-id --make-bed \
      --vcf input.vcf --out SampleID \
      --allow-extra-chr
```

#### 3. Run ADMIXTURE (K = 2–12)

Each run includes:

- 10-fold CV (--cv=10)
- 64 CPU threads (-j64)

```bash
admixture --cv=10 SampleID.bed -j64 K | tee logK.out
```

#### 4. Extract CV Errors

All CV error values are summarized into:

```bash
FILE.cv.error
```

### 📑 Output Files

| File | Description |
|---------|--------------|
|SampleID.bed/.bim/.fam |PLINK binary files|
|logK.out |ADMIXTURE log for each K|
|FILE.cv.error | Extracted CV errors for all K (2–12)|

### 📈 Determining the Best K

Use FILE.cv.error to evaluate CV error.Plot using the R script `CV_error.R` to choose the best K

## 🔎 Interpretation

- The best K is typically the one with the lowest CV error.
- The plotted curve helps visually identify the optimal number of ancestral populations

### 🎨 Visualizing ADMIXTURE Results with StructuRly

To generate publication-quality visualizations of ADMIXTURE outputs (Q-matrix), you can use StructuRly, an interactive R-based tool designed for population structure plots.
The repository includes an R script snippet to install and run `StructuRly.R`:

```bash
# install.packages(pkgs = "devtools")
library(devtools)
# install_github(repo = "nicocriscuolo/StructuRly", dependencies = TRUE)
library(StructuRly)
runStructuRly()
```

## Principal Component Analysis (PCA)

Principal Component Analysis (PCA) is a widely used method for visualizing genetic variation and clustering patterns among individuals.  

This repository includes an R script for converting a VCF file into GDS format, running PCA with SNPRelate, and visualizing the results using ggplot2.

- The following section is based on the script: `PCA.R`  

### 📁 PCA Output Table

A PCA coordinate table is generated and exported as:

```bash
PCA.csv
```

### 3D PCA Plotting

Python script is designed to process data derived from a Principal Component Analysis (PCA) stored in a CSV file and visualize it using a 3D scatter plot.

- Library Imports
  - import pandas as pd
  - import matplotlib.pyplot as plt
  - from mpl_toolkits.mplot3d import Axes3D
  
- Data Loading and setup
  - df = pd.read_csv('PCA.csv')

```bash
python plot_PCA_3D.py
```

Displaying the Plot

- plt.show(): Executes the final command to render and display the generated 3D plot

## 🌳 Phylogenetic Tree Construction (VCF → FASTA → MEGA)

This project also includes a workflow for converting VCF files to FASTA format, which can then be imported into MEGA (Molecular Evolutionary Genetics Analysis) software for phylogenetic tree construction.

The conversion is done using VCF-kit, based on the script provided: `vcf2fasta.sh`

### 🔧 Requirements

To run the VCF → FASTA conversion, you need:

- Conda / mamba environment
- VCF-kit installed inside that environment

### 🧬 Script: Convert VCF to FASTA

The provided script `vcf2fasta.sh` converts any VCF file into FASTA format:

```bash
chmod +x vcf2fasta.sh
./vcf2fasta.sh yourfile.vcf
```

This will produce:

```bash
yourfile.fasta
```

### 📤 Output

A multi-sequence FASTA file that contains each sample’s genotype converted into nucleotide sequences.

Example output structure:

```bash
>Sample1
ACTGATCGATCGAT…
>Sample2
ACTGATCGATTGAT…
...
```

### 🧪 Using FASTA with MEGA for Phylogenetic Tree Analysis

Once the FASTA file is generated, you can import it into MEGA for tree construction:

#### 1. Open MEGA

Download from: <https://www.megasoftware.net/>

#### 2. Load FASTA alignment

- Go to File → Open A File/Session
- Select yourfile.fasta
- MEGA will ask whether the sequences are aligned. Select Analyze (sequences aligned).
- Setting Missing data from `-` to `N`

#### 3. Build Phylogenetic Tree

MEGA supports several algorithms:

- Neighbor-Joining (NJ)
- Maximum Likelihood (ML)
- UPGMA
- Minimum Evolution
- Maximum Parsimony

#### 4. Export Tree

You can export your phylogenetic tree as:

- Newick format (*.nwk)
- PNG
- PDF
- SVG
- MEGA session file
