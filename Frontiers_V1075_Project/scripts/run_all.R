# run_all.R
# Frontiers_V1075_Project Master Script
# -------------------------------------

# Purpose:
# Runs the full data wrangling, model setup, and Monte Carlo simulation workflow
# in the correct order, using relative paths within the R project.

# Setup -----------------------------------------------------------------------

# Load necessary libraries
required_packages <- c("ggplot2", "dplyr", "ggpubr", "gridExtra", "knitr", "outliers", "purrr", "RCurl")
new_packages <- setdiff(required_packages, rownames(installed.packages()))
if (length(new_packages) > 0) install.packages(new_packages)

lapply(required_packages, library, character.only = TRUE)

# Define directories
scripts_dir <- "scripts"

# Run Scripts in Order -------------------------------------------------------

# 1. Setup data: Summarize raw V1075 phosphate data
source(file.path(scripts_dir, "V1075_MCsetup.R"))

# 2. Build regression models for δ18O proxies
source(file.path(scripts_dir, "d18Ow_Proxy_Regressions.R"))

# 3. Build water-to-air temperature transform model
source(file.path(scripts_dir, "Water-Air_Transform.R"))

# 4. Run Monte Carlo simulation
source(file.path(scripts_dir, "V1075_MonteCarlo.R"))

# Finished! ------------------------------------------------------------------

cat("\n✅ Full project pipeline completed successfully!\n")