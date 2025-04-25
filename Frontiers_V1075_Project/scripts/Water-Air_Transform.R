
# Water to Air Temperature Transformation Model
# ---------------------------------------------
# Based on data from Hren & Sheldon (2012)

# Load Data -------------------------------------------------------------------

data <- read.csv("data/Hren&Sheldon2012_data_copy.csv")

# Subset Datasets -------------------------------------------------------------

tropic_data     <- subset(data, MAAT_.C. > 20)   # Tropics: MAAT > 20°C
plus12degC_data <- subset(data, MAAT_.C. > 12)   # Warm climates: MAAT > 12°C

# Regression Analysis --------------------------------------------------------

# Build linear model: Predict air temperature (AMJJAS) from water temperature (AMJJAS)
warmclimate_transform_model <- lm(Ta_AMJJAS ~ Tw_AMJJAS, data = plus12degC_data)
summary(warmclimate_transform_model)

# Save model as RDS -----------------------------------------------------------

saveRDS(warmclimate_transform_model, file = "models/TwTa_reg_lm.rds")

# Extract Model Parameters ----------------------------------------------------

coefficients <- coef(warmclimate_transform_model)
intercept <- coefficients[1]
slope <- coefficients[2]

# Extract Standard Errors
std_errors <- summary(warmclimate_transform_model)$coefficients[, "Std. Error"]
intercept_se <- std_errors[1]
slope_se <- std_errors[2]

# Extract Residual Standard Error
residual_error <- summary(warmclimate_transform_model)$sigma

# Display Model Results ------------------------------------------------------

cat("Regression Equation: Ta_AMJJAS =", intercept, "+", slope, "* Tw_AMJJAS\n")
cat("Intercept SE:", intercept_se, "\n")
cat("Slope SE:", slope_se, "\n")
cat("Residual Standard Error (sigma):", residual_error, "\n")
