
# V1075 Monte Carlo Setup Script
# -------------------------------------
# Summarizes isotope data and prepares inputs for simulations.

# Load Packages ---------------------------------------------------------------

required_packages <- c("ggpubr", "gridExtra", "ggplot2", "knitr", "outliers", "dplyr")
new_packages <- setdiff(required_packages, rownames(installed.packages()))
if (length(new_packages) > 0) install.packages(new_packages)

library(ggpubr)
library(gridExtra)
library(ggplot2)
library(knitr)
library(outliers)
library(dplyr)

# Set Paths -------------------------------------------------------------------

# Use relative paths within R project
data_dir    <- "data"
results_dir <- "results"

# Read Data -------------------------------------------------------------------

raw <- read.csv(file.path(data_dir, "V1075_PhosphateData_8-18-23_copy.csv"))
NIST120c <- read.csv(file.path(data_dir, "V1075_NIST120c.csv"))

# Summarize Data by Specimen --------------------------------------------------

V1075_BySpec <- raw %>%
  group_by(Specimen.ID)

# Calculate summary statistics
V1075_mean <- V1075_BySpec %>%
  summarize(d18O = mean(d18O..VSMOW.), n = n())

V1075_sd <- V1075_BySpec %>%
  summarize(SD = sd(d18O..VSMOW.))

# Clean and merge
V1075_BySpec <- V1075_BySpec %>%
  distinct(Specimen.ID, .keep_all = TRUE) %>%
  select(-c(1, 4:6, 8, 14:26)) %>%
  left_join(V1075_mean, by = "Specimen.ID") %>%
  left_join(V1075_sd, by = "Specimen.ID") %>%
  mutate(SE = SD / sqrt(n))

# Rename columns
names(V1075_BySpec)[names(V1075_BySpec) == "Eco"] <- "eco_type"
V1075_BySpec <- V1075_BySpec %>% select(-d18O..VSMOW.)

# Inspect Data Distributions --------------------------------------------------

table(V1075_BySpec$Taxon)

gar_raw  <- V1075_BySpec$d18O[V1075_BySpec$Taxon == "Lepisosteids"]
glyp_raw <- V1075_BySpec$d18O[V1075_BySpec$Taxon == "Glyptops sp."]
crocG_raw <- V1075_BySpec$d18O[V1075_BySpec$Taxon == "Neosuchian G"]
NIST_raw <- NIST120c$d.18O.16O

shapiro.test(gar_raw)
shapiro.test(glyp_raw)
shapiro.test(crocG_raw)
shapiro.test(NIST_raw)

# Export Summarized Data ------------------------------------------------------

# Save full dataset
write.csv(V1075_BySpec, file = file.path(data_dir, "V1075_BySpec.csv"), row.names = FALSE)

# Prepare data for Monte Carlo simulations
V1075MC_data <- V1075_BySpec %>%
  select(Specimen.ID, Taxon, d18O)

write.csv(V1075MC_data, file = file.path(data_dir, "V1075MC_data.csv"), row.names = FALSE)
