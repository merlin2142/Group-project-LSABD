# Group project LSABD

Group project for Large Scale Analysis of Biomedical Data (UGent, 2026–2027): exploration, hypothesis testing, multiple testing and machine learning on NHANES 2021–2023 data.

**Group:** PG 5 - **Members:** Charlotte Decloedt, Lotte De Man, Faye Devriese, Niels De Clercq

## Research question

> Is waist circumference associated with HbA1c levels in adults after adjusting for age, BMI, race/ethnicity, serum cotinine levels and educational attainment, and does this association differ between men and women?

| | Variable(s) |
|---|---|
| **Outcome** | HbA1c (`LBXGH`), average blood glucose over the past 2–3 months, log10-transformed |
| **Exposure** | waist circumference (`BMXWAIST`) |
| **Adjusted for** | age (`age`), BMI (`BMXBMI`), race/ethnicity (`ethnicity`), log10 serum cotinine (`LBXCOT`), education (`education`) |
| **Effect modification** | sex (`sex`): waist × sex interaction |
| **Population** | examined, non-pregnant adults ≥ 20 y: 6 023 participants, 5 219 (86.7 %) with complete data |
| **Model** | linear regression: log10(HbA1c) ~ waist × sex + age + BMI + ethnicity + log10(cotinine) + education |

Because waist circumference and BMI are strongly correlated (r = 0.90), the waist effect adjusted for BMI is interpreted as the effect of **fat distribution** (more abdominal fat at the same BMI).


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
