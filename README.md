# Group project LSABD

Group project for Large Scale Analysis of Biomedical Data (UGent, 2026–2027): exploration, hypothesis testing, multiple testing and machine learning on NHANES 2021–2023 data.

**Group:** PG 5 - **Members:** Charlotte Decloedt, Lotte De Man, Faye Devriese, Niels De Clercq

## Research question

> PLACEHOLDER

PLACEHOLDER

## Progress
PLACEHOLDER

## Repository structure

```
├── data/
│   ├── raw/              original NHANES files (not in Git, see "Data" below)
│   └── processed/        clean dataset made by 02_preprocessing (not in Git)
├── R/
│   └── utils.R           shared paths, colour palette, plot theme, helper functions
├── analysis/
│   ├── 01_exploration.Rmd        Part 1a  explore the raw data
│   ├── 02_preprocessing.Rmd      Part 1b  clean data → data/processed/nhanes_clean.csv
│   ├── 03_hypothesis_test.Rmd    Part 2   research question + multivariable model
│   ├── 04_multiple_testing.Rmd   Part 3   ≥ 20 features, FDR correction
│   └── 05_machine_learning.ipynb Part 4   prediction model (Python)
├── results/
│   ├── figures/          all figures (PNG + PDF), named fig_<part>_<name>
│   └── tables/           result tables (CSV), named tab_<part>_<name>
├── report/               report (named + anonymised version)
└── presentation/         slides for the defence
```

## Data

The data are public (NHANES 2021–2023, CDC) and are **not** stored in this repository.

1. Download `NHANES_20212023_merged_filtered_1.csv` and `NHANES_20212023_codebook_filtered_1.csv` from Ufora.
2. Put both files in `data/raw/` (keep these exact file names).

Background on the variables: <https://wwwn.cdc.gov/nchs/nhanes/continuousnhanes/default.aspx?Cycle=2021-2023>

## How to run

1. Open `Group-project-LSABD.Rproj` in RStudio (this sets the project root for all paths).
2. Knit the files in `analysis/` **in order**: 01 → 02 → 03 → 04, then run `05_machine_learning.ipynb`
   (Python: `pandas`, `numpy`, `matplotlib`, `scikit-learn`).

`02_preprocessing.Rmd` must be knitted before 03, 04 and 05: they all read the same clean dataset.