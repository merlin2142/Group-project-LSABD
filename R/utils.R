# =============================================================================
# R/utils.R - shared settings and helper functions for the whole project
#
# Every analysis file starts with:
#     source(here::here("R", "utils.R"))
#
# Owner: Person 1 (ask before changing: every part depends on this file)
# =============================================================================

suppressPackageStartupMessages({
  library(here)        # paths relative to the project root (the .Rproj file)
  library(tidyverse)   # readr, dplyr, tidyr, ggplot2, purrr, stringr, forcats
})

# ---- Paths -------------------------------------------------------------------
# here() finds the folder that contains Group-project-LSABD.Rproj, so these
# paths work on every computer, whether a chunk is run interactively or knitted.
paths <- list(
  raw_data      = here("data", "raw", "NHANES_20212023_merged_filtered_1.csv"),
  raw_codebook  = here("data", "raw", "NHANES_20212023_codebook_filtered_1.csv"),
  clean_data    = here("data", "processed", "nhanes_clean.csv"),
  clean_vars    = here("data", "processed", "variable_info.csv"),
  figures       = here("results", "figures"),
  tables        = here("results", "tables")
)

# ---- Colours and plot theme --------------------------------------------------
# One colourblind-safe palette (Okabe-Ito) for every figure in the report.
# Unnamed on purpose: a named vector in scale_*_manual(values = ...) would be
# matched to the factor levels by name instead of by position.
okabe_ito <- c("#E69F00",  # 1 orange
               "#56B4E9",  # 2 sky blue
               "#009E73",  # 3 green
               "#0072B2",  # 4 blue
               "#D55E00",  # 5 vermillion
               "#CC79A7",  # 6 reddish purple
               "#F0E442",  # 7 yellow
               "#000000",  # 8 black
               "#999999")  # 9 grey

# Fixed colours for recurring groups, so men/women look the same in every figure
sex_colours <- c(Men = okabe_ito[2], Women = okabe_ito[1])

theme_set(theme_classic(base_size = 11))

# ---- Loading data ------------------------------------------------------------

#' Read the raw merged NHANES file.
#' guess_max: readr guesses column types from the first 1000 rows by default;
#' many NHANES columns are empty there, which would silently turn values into NA.
load_raw_data <- function() {
  read_csv(paths$raw_data, guess_max = 20000, show_col_types = FALSE)
}

#' Read the codebook (Windows-1252 encoded, not UTF-8).
load_codebook <- function() {
  read_csv(paths$raw_codebook, locale = locale(encoding = "windows-1252"),
           show_col_types = FALSE)
}

#' Read the cleaned dataset produced by analysis/02_preprocessing.Rmd.
#' Parts 2, 3 and 4 use ONLY this function, so everyone works on the same data.
load_clean_data <- function() {
  if (!file.exists(paths$clean_data)) {
    stop("No clean data found. Knit analysis/02_preprocessing.Rmd first.", call. = FALSE)
  }
  read_csv(paths$clean_data, guess_max = 20000, show_col_types = FALSE)
}

#' Read the variable table written by 02_preprocessing.Rmd: one row per variable
#' in the clean data, with label, role, % missing, % below LOD and transformation.
load_variable_info <- function() {
  if (!file.exists(paths$clean_vars)) {
    stop("No variable info found. Knit analysis/02_preprocessing.Rmd first.", call. = FALSE)
  }
  read_csv(paths$clean_vars, show_col_types = FALSE)
}

#' Apply the transformations decided in 02_preprocessing.Rmd.
#' The clean CSV keeps every variable in its original unit (so tables and plots
#' stay interpretable); call this function in an analysis when you need the
#' log10-transformed version. Variables are only transformed when
#' variable_info$transform == "log10"; `offset` is added first (non-zero only
#' for variables that contain zeros).
#' @param vars optional: restrict to these variables
apply_transformations <- function(data, variable_info = load_variable_info(), vars = NULL) {
  to_log <- variable_info %>%
    filter(transform == "log10", variable %in% names(data))
  if (!is.null(vars)) to_log <- filter(to_log, variable %in% vars)
  for (i in seq_len(nrow(to_log))) {
    v <- to_log$variable[i]
    data[[v]] <- log10(data[[v]] + to_log$offset[i])
  }
  data
}

# ---- Saving output -----------------------------------------------------------

#' Save a ggplot as PNG (for slides/HTML) and PDF (vector, for the report).
#' Name figures after their part, e.g. "fig_03_model_effects".
save_figure <- function(plot, name, width = 8, height = 5) {
  dir.create(paths$figures, recursive = TRUE, showWarnings = FALSE)
  ggsave(file.path(paths$figures, paste0(name, ".png")), plot,
         width = width, height = height, dpi = 300)
  ggsave(file.path(paths$figures, paste0(name, ".pdf")), plot,
         width = width, height = height, device = cairo_pdf)
  invisible(plot)
}

#' Save a results table as CSV, e.g. "tab_04_test_results".
save_table <- function(table, name) {
  dir.create(paths$tables, recursive = TRUE, showWarnings = FALSE)
  write_csv(table, file.path(paths$tables, paste0(name, ".csv")))
  invisible(table)
}

# ---- Small statistics helpers -----------------------------------------------

#' Sample skewness (> 1 = strongly right-skewed).
skewness <- function(x) {
  x <- x[!is.na(x)]
  if (length(x) < 3 || sd(x) == 0) return(NA_real_)
  mean((x - mean(x))^3) / sd(x)^3
}
