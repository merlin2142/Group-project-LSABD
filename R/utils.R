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

# ---- House style: fonts, colours, ggplot theme and scales ---------------------
# Explained with examples in docs/style_guide.pdf. Use these scales for every figure.
#
#   theme_lsabd()                         ggplot theme (font, grid, legend), set as default
#   scale_colour_sex() / scale_fill_sex() men = teal, women = amber (labels Male/Female or Men/Women)
#   scale_fill_hba1c()                    normal / prediabetes / diabetes range
#   scale_*_cat()                         up to 6 unordered groups (12 for clusters)
#   scale_*_ordered()                     ordered categories (quartiles, education)
#   scale_fill_div() / scale_colour_div() correlations, effects around zero
#   scale_*_cont()                        a continuous value (UMAP, t-SNE, heatmap of one sign)
#   scale_fill_counts()                   counts (confusion matrix, density)
#   scale_*_direction()                   higher / lower / not significant
#   lsabd$teal, lsabd$amber, ...          single colours (see docs/style_guide.pdf, section 2)

lsabd <- list(
  # main palette (style 2)
  bg = "#FFFFFF", text = "#22313F", muted = "#5E6B78", grid = "#E3EAEA",
  neutral = "#DDE4E6", panel = "#EDF3F3",
  teal = "#0F7C80", amber = "#D8901A", light_teal = "#86C2C3",
  # grey for context / not significant / missing
  na = "#C9D1D6",
  # categorical: always use in this order; 1-6 main set, 7-12 only for many clusters
  cat = c("#0F7C80", "#D8901A", "#0A5155", "#8B5A2B", "#86C2C3", "#E2C18C",
          "#8C9274", "#7B92B8", "#566B59", "#A77B32", "#644734", "#B9A264"),
  # scales
  classes   = c("#DDE4E6", "#86C2C3", "#0F7C80"),
  seq_teal  = c("#EDF3F3", "#B5DADA", "#86C2C3", "#0F7C80", "#0A5155"),
  seq_brown = c("#F6EDE0", "#E2C18C", "#C08A45", "#8B5A2B", "#5C3D23"),
  div       = c("#0A5155", "#0F7C80", "#86C2C3", "#F4F2EE", "#D6AE73", "#94602B", "#5C3D23"),
  cont      = c("#F1E4C3", "#C7BE8E", "#6FA79A", "#0F7C80", "#0A3D40"),
  font = "IBM Plex Sans"
)

# Fall back to the default sans-serif font (with a message) when IBM Plex Sans is
# not installed, so code keeps running on every laptop.
if (requireNamespace("systemfonts", quietly = TRUE) &&
    !lsabd$font %in% systemfonts::system_fonts()$family) {
  message("IBM Plex Sans is not installed: figures use the default font. ",
          "Install it from https://fonts.google.com/specimen/IBM+Plex+Sans (see docs/style_guide.pdf).")
  lsabd$font <- "sans"
}

# ---- Theme ---------------------------------------------------------------------
theme_lsabd <- function(base_size = 11) {
  ggplot2::theme_minimal(base_size = base_size, base_family = lsabd$font) +
    ggplot2::theme(
      plot.background     = ggplot2::element_rect(fill = lsabd$bg, colour = NA),
      text                = ggplot2::element_text(colour = lsabd$text),
      axis.text           = ggplot2::element_text(colour = lsabd$muted),
      axis.title          = ggplot2::element_text(colour = lsabd$muted, size = ggplot2::rel(0.9)),
      panel.grid.major.x  = ggplot2::element_blank(),
      panel.grid.minor    = ggplot2::element_blank(),
      panel.grid.major.y  = ggplot2::element_line(colour = lsabd$grid, linewidth = 0.4),
      axis.line.x         = ggplot2::element_line(colour = lsabd$muted, linewidth = 0.4),
      plot.title          = ggplot2::element_text(face = "bold", size = ggplot2::rel(1.15), hjust = 0,
                                                  margin = ggplot2::margin(b = 4)),
      plot.title.position = "plot",
      plot.subtitle       = ggplot2::element_text(colour = lsabd$muted, margin = ggplot2::margin(b = 8)),
      legend.position     = "top", legend.justification = "left",
      legend.title        = ggplot2::element_blank(),
      strip.text          = ggplot2::element_text(colour = lsabd$text, face = "bold", hjust = 0),
      plot.margin         = ggplot2::margin(8, 10, 6, 6)
    )
}

# ---- Discrete scales -------------------------------------------------------------
.sex_values <- c(Men = lsabd$teal, Women = lsabd$amber, Male = lsabd$teal, Female = lsabd$amber)
scale_colour_sex <- function(...) ggplot2::scale_colour_manual(values = .sex_values, ...)
scale_fill_sex   <- function(...) ggplot2::scale_fill_manual(values = .sex_values, ...)

scale_fill_hba1c <- function(...) {
  ggplot2::scale_fill_manual(
    values = c(normal = lsabd$classes[1], prediabetes = lsabd$classes[2], `diabetes range` = lsabd$classes[3]),
    breaks = c("normal", "prediabetes", "diabetes range"), ...)
}

.cat_values <- function(n) {
  if (n > 12) stop("More than 12 groups: do not add colours. Colour by direction or group and label ",
                   "directly (docs/style_guide.pdf, section 4).", call. = FALSE)
  if (n > 6) message("7-12 colours: only for clusters. Label the groups directly on the plot.")
  lsabd$cat[seq_len(n)]
}
# discrete_scale() changed its arguments in ggplot2 3.5.0; this works with both
.discrete <- function(aesthetics, palette, ...) {
  if (utils::packageVersion("ggplot2") >= "3.5.0") {
    ggplot2::discrete_scale(aesthetics, palette = palette, ...)
  } else {
    ggplot2::discrete_scale(aesthetics, scale_name = "lsabd", palette = palette, ...)
  }
}
scale_colour_cat <- function(...) .discrete("colour", .cat_values, na.value = lsabd$na, ...)
scale_fill_cat   <- function(...) .discrete("fill",   .cat_values, na.value = lsabd$na, ...)

.ordered_values <- function(n) grDevices::colorRampPalette(lsabd$seq_teal[2:5])(n)
scale_colour_ordered <- function(...) .discrete("colour", .ordered_values, na.value = lsabd$na, ...)
scale_fill_ordered   <- function(...) .discrete("fill",   .ordered_values, na.value = lsabd$na, ...)

scale_colour_direction <- function(...) {
  ggplot2::scale_colour_manual(values = c(higher = lsabd$amber, lower = lsabd$teal,
                                          `not significant` = lsabd$na), ...)
}
scale_fill_direction <- function(...) {
  ggplot2::scale_fill_manual(values = c(higher = lsabd$amber, lower = lsabd$teal,
                                        `not significant` = lsabd$na), ...)
}

# ---- Continuous scales -----------------------------------------------------------
scale_fill_div   <- function(limits = c(-1, 1), ...) ggplot2::scale_fill_gradientn(colours = lsabd$div, limits = limits, ...)
scale_colour_div <- function(limits = c(-1, 1), ...) ggplot2::scale_colour_gradientn(colours = lsabd$div, limits = limits, ...)
scale_fill_cont   <- function(...) ggplot2::scale_fill_gradientn(colours = lsabd$cont, ...)
scale_colour_cont <- function(...) ggplot2::scale_colour_gradientn(colours = lsabd$cont, ...)
scale_fill_counts <- function(...) ggplot2::scale_fill_gradientn(colours = lsabd$seq_brown, ...)

ggplot2::theme_set(theme_lsabd())   # every ggplot in the project starts from this theme

# Fixed colours for men and women, as in the style guide
sex_colours <- .sex_values

# Legacy: 01_exploration and 02_preprocessing were written with this Okabe-Ito
# palette. New figures use the lsabd palettes and scales above instead.
okabe_ito <- c("#E69F00", "#56B4E9", "#009E73", "#0072B2", "#D55E00",
               "#CC79A7", "#F0E442", "#000000", "#999999")

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
  read_csv(paths$clean_data, guess_max = 20000, show_col_types = FALSE) %>%
    # a CSV does not store factor levels: restore the factors made in 02_preprocessing,
    # otherwise R sorts the categories alphabetically
    mutate(
      RIAGENDR = factor(RIAGENDR, levels = c("Male", "Female")),
      RIDSTATR = factor(RIDSTATR, levels = c("Interview only", "Examined")),
      RIDRETH3 = factor(RIDRETH3, levels = c("Mexican American", "Other Hispanic", "Non-Hispanic White",
                                             "Non-Hispanic Black", "Non-Hispanic Asian", "Other race")),
      DMDEDUC2 = factor(DMDEDUC2, levels = c("Less than 9th grade", "9th-11th grade", "High school graduate",
                                             "Some college", "College graduate or above"), ordered = TRUE),
      DMDMARTZ = factor(DMDMARTZ, levels = c("Married or living with partner",
                                             "Widowed, divorced or separated", "Never married"))
    )
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
  # ragg renders installed fonts (IBM Plex Sans) reliably on Windows, macOS and Linux
  png_device <- if (requireNamespace("ragg", quietly = TRUE)) ragg::agg_png else "png"
  ggsave(file.path(paths$figures, paste0(name, ".png")), plot,
         width = width, height = height, dpi = 300, device = png_device, bg = "white")
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
