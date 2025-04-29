
# Frontiers_V1075_Project
## Ecohydrology and Paleoclimate of the Cloverly Formation

---

## Project Structure

| Folder | Contents |
|:------|:---------|
| `data/` | Raw and processed datasets |
| `scripts/` | All R scripts for data wrangling, modeling, and analysis |
| `models/` | Saved regression models (.rds files) |
| `results/` | Output files: plots, figures, tables |
| `reports/` | RMarkdown reports and exploratory analyses |

---

## Project Overview

This project reconstructs mid-Cretaceous (Aptian–Albian) terrestrial paleoclimate in the Western Interior Basin based on vertebrate d18O_phosphate values. It includes:

- Data wrangling of isotopic measurements.
- Regression model reproduction from Barrick et al. (1999), Amiot et al. (2007), and Puceat et al. (2010).
- Monte Carlo simulations to estimate d18O_surface_water and paleotemperatures.
- Comparison of proxy reconstructions against model-based climate predictions.

---

## How to Run This Project

1. Open the RStudio project file: `Frontiers_V1075_Project.Rproj`.  
   This ensures the working directory is automatically set to the project root.
2. Run the master script (`run.all.R`) in the `scripts/` folder:
3. Outputs (summaries, figures, tables) will appear in the `results/` folder.

All scripts use **relative paths**, assuming the R session starts from the project root.
---

##️ Requirements

- R (≥ 4.0.0)
- RStudio (recommended)
- Required R packages (install via `install.packages()` if not already present):
  - `ggplot2`
  - `dplyr`
  - `ggpubr`
  - `gridExtra`
  - `knitr`
  - `outliers`
  - `purrr`
  - `RCurl`

---

## Citation

If using this project or derived results, please cite:

- Allen, M.L., Suarez, M., Adams, T., and Suarez, C., 2025, Ecohydrology and paleoenvironment of the Cretaceous (Albian) Cloverly Formation: Insights from multi-taxon oxygen isotope analysis of vertebrate phosphates: Frontiers in Earth Science, v. 13, https://doi.org/10.3389/feart.2025.1497416.

---

## Contact

For questions or collaborations, contact:  
Matthew Allen (mattall@umich.edu OR mlallen13geo@gmail.com)
