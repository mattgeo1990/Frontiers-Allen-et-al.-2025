
# Frontiers_V1075_Project
## Ecohydrology and Paleoclimate of the Cloverly Formation

---

## 📂 Project Structure

| Folder | Contents |
|:------|:---------|
| `data/` | Raw and processed datasets |
| `scripts/` | All R scripts for data wrangling, modeling, and analysis |
| `models/` | Saved regression models (.rds files) |
| `results/` | Output files: plots, figures, tables |
| `notebooks/` | RMarkdown reports and exploratory analyses |

---

## 🔍 Project Overview

This project reconstructs mid-Cretaceous (Aptian–Albian) terrestrial paleoclimate in the Western Interior Basin based on vertebrate δ¹⁸O_phosphate values. It includes:

- Data wrangling of isotopic measurements.
- Regression model reproduction from Barrick et al. (1999), Amiot et al. (2007), and Puceat et al. (2010).
- Monte Carlo simulations to estimate δ¹⁸O_surface_water and paleotemperatures.
- Comparison of proxy reconstructions against model-based climate predictions.

---

## 🚀 How to Run This Project

1. Open `Frontiers_V1075_Project.Rproj` in RStudio.
2. Run the scripts inside the `scripts/` folder in the following order:
   - `data_wrangling.R`
   - `regression_models.R`
   - `monte_carlo_simulation.R`
3. Outputs (summaries, figures) will appear in the `results/` folder.

All scripts use **relative paths** assuming you start from the project root.

---

## 🛠️ Requirements

- R (version >= 4.0.0)
- R packages:
  - `ggplot2`
  - `dplyr`
  - `ggpubr`
  - `gridExtra`
  - `knitr`
  - `outliers`
  - `purrr`
  - `RCurl`

---

## 📜 Citation

If using this project or derived results, please cite:

- Allen, M.L., et al. (2025). *Ecohydrology and paleoenvironment of the Cretaceous (Albian) Cloverly Formation*. Frontiers in Earth Science.

---

## 📬 Contact

For questions or collaborations, contact:  
Matthew Allen (email@example.com)
