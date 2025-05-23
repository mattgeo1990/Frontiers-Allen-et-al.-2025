# Setup ------------------------------------------------------------------------

# Load libraries
library(ggplot2)
library(dplyr)

# Define directories
data_dir   <- "data"
models_dir <- "models"
results_dir <- "results"

# Load data
Barrick_d18O <- read.csv(file.path(data_dir, "Barrick1999_data copy.csv")) %>%
  dplyr::mutate(Genus = trimws(Genus))

Amiot2007_d18O <- read.csv(file.path(data_dir, "AmiotEtAl2007_d18Odata copy.csv"))
PLN_data       <- read.csv(file.path(data_dir, "Puceat2010_LongNuti1973_compiled_data.csv"))

# Barrick et al. (1999) Turtle Regression --------------------------------------

barrick_filtered <- subset(Barrick_d18O, Genus %in% c("Pseudemys", "Chrysemys", "Trionyx", "Caretta", "Dermochelys"))

# Fit linear model
barrick_lm <- lm(d18Ow_VSMOW ~ d18Op_VSMOW, data = barrick_filtered)
summary(barrick_lm)
saveRDS(barrick_lm, file.path(models_dir, "Barrick_reg_lm.rds"))

# Create and save plot
barrick_plot <- ggplot(barrick_filtered, aes(x = d18Op_VSMOW, y = d18Ow_VSMOW)) +
  geom_point() +
  geom_smooth(method = "lm", se = TRUE, color = "blue") +
  labs(title = "Barrick Turtle Regression", x = "δ18O_p (VSMOW)", y = "δ18O_w (VSMOW)") +
  theme_minimal()

ggsave(filename = file.path(results_dir, "Barrick_Turtle_Regression.png"),
       plot = barrick_plot, width = 7, height = 5, dpi = 300)

# Print equation and RSE
coefficients <- coef(barrick_lm)
cat("Equation: δ18O_w =", coefficients[1], "+", coefficients[2], "* δ18O_p\n")
cat("RSE:", sqrt(sum(residuals(barrick_lm)^2) / barrick_lm$df.residual), "\n")

# Amiot et al. (2007) Crocodile Regression --------------------------------------

amiot_clean <- na.omit(Amiot2007_d18O[, c("d18Op_SMOW", "d18Ow_SMOW")])
amiot_lm <- lm(d18Ow_SMOW ~ d18Op_SMOW, data = amiot_clean)
summary(amiot_lm)
saveRDS(amiot_lm, file.path(models_dir, "Amiot_reg_lm.rds"))

# Create and save plot
amiot_plot <- ggplot(amiot_clean, aes(x = d18Op_SMOW, y = d18Ow_SMOW)) +
  geom_point() +
  geom_smooth(method = "lm", se = TRUE, color = "blue") +
  labs(title = "Amiot Croc Regression", x = "δ18O_p (VSMOW)", y = "δ18O_w (VSMOW)") +
  theme_minimal()

ggsave(filename = file.path(results_dir, "Amiot_Croc_Regression.png"),
       plot = amiot_plot, width = 7, height = 5, dpi = 300)

# Print equation and RSE
coefficients <- coef(amiot_lm)
cat("Equation: δ18O_w =", coefficients[1], "+", coefficients[2], "* δ18O_p\n")
cat("RSE:", sqrt(sum(residuals(amiot_lm)^2) / amiot_lm$df.residual), "\n")

# Puceat et al. (2010) Temperature Regression -----------------------------------

pln_clean <- na.omit(PLN_data[, c("D18O_corrected", "T..C.")])
pln_lm <- lm(T..C. ~ D18O_corrected, data = pln_clean)
summary(pln_lm)
saveRDS(pln_lm, file.path(models_dir, "PLNd18Op_reg_lm.rds"))

# Create and save plot
pln_plot <- ggplot(pln_clean, aes(x = D18O_corrected, y = T..C.)) +
  geom_point() +
  geom_smooth(method = "lm", se = TRUE, color = "blue") +
  labs(title = "Puceat & Longinelli/Nuti", x = "δ18O_p - δ18O_w (VSMOW)", y = "Temperature (°C)") +
  theme_minimal()

ggsave(filename = file.path(results_dir, "PLN_Temperature_Regression.png"),
       plot = pln_plot, width = 7, height = 5, dpi = 300)

# Print regression formula and stats
coefficients <- coef(pln_lm)
se <- summary(pln_lm)$coefficients[, "Std. Error"]

cat("Equation: T (°C) =", coefficients[1], "+", coefficients[2], "* (δ18O_p - δ18O_w)\n")
cat("Intercept SE:", se[1], "\n")
cat("Slope SE:", se[2], "\n")
cat("RSE:", sqrt(sum(residuals(pln_lm)^2) / pln_lm$df.residual), "\n")
  