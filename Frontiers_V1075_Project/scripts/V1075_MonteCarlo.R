
# Setup -----------------------

# Load required libraries
library(dplyr)
library(ggplot2)

# Set paths
project_dir <- getwd()
data_dir <- file.path(project_dir, "data")
models_dir <- file.path(project_dir, "models")
results_dir <- file.path(project_dir, "results")

# Set number of Monte Carlo repetitions
n_iterations <- 1000
set.seed(123) # for reproducibility 

# Load sample data and NIST standard
data <- read.csv(file.path(data_dir, "V1075MC_data.csv"))
NIST120c <- read.csv(file.path(data_dir, "V1075_NIST120c.csv"))

# Load regression models
Barrick_lm <- readRDS(file.path(models_dir, "Barrick_reg_lm.rds"))
Amiot_lm <- readRDS(file.path(models_dir, "Amiot_reg_lm.rds"))
PLN_lm <- readRDS(file.path(models_dir, "PLNd18Op_reg_lm.rds"))
TwTa_lm <- readRDS(file.path(models_dir, "TwTa_reg_lm.rds"))

# d18Op Bootstrapping -----------------------

# Define taxa
taxa_list <- list(
  Lepisosteidae      = subset(data, Taxon == "Lepisosteids")$d18O,
  Hybodontiformes    = subset(data, Taxon == "Hybodonts")$d18O,
  `Glyptops sp.`     = subset(data, Taxon == "Glyptops sp.")$d18O,
  `Naomichelys sp.`  = subset(data, Taxon == "Naomichelys sp.")$d18O,
  `Neosuchian G`     = subset(data, Taxon == "Neosuchian G")$d18O,
  `Neosuchian A`     = subset(data, Taxon == "Neosuchian A")$d18O,
  `Neosuchian B`     = subset(data, Taxon == "Neosuchian B")$d18O,
  NIST12Oc_aka_NBS120c = NIST120c$d.18O.16O
)

# Bootstrap function
bootstrap_means <- function(values, n_reps) {
  tibble(
    num = 1:n_reps,
    means = replicate(n_reps, mean(sample(values, replace = TRUE)))
  )
}


# Perform bootstrapping for each taxon
bootstrap_results <- lapply(taxa_list, bootstrap_means, n_reps = n_iterations)

# Combine bootstrap results into one dataframe
combined_data <- bind_rows(
  lapply(names(bootstrap_results), function(taxon) {
    tibble(
      group = taxon,
      values = bootstrap_results[[taxon]]$means
    )
  })
)

# Summarize d18Op
d18Op_summary <- combined_data %>%
  group_by(group) %>%
  summarise(
    Mean_d18Op = mean(values, na.rm = TRUE),
    CI_Lower = quantile(values, 0.025, na.rm = TRUE),
    CI_Upper = quantile(values, 0.975, na.rm = TRUE)
  ) %>%
  relocate(group)

# Export summary
saveRDS(d18Op_summary, file.path(results_dir, "d18Op_summary.rds"))
print(d18Op_summary)

# Correct factor levels for plotting
combined_data$group <- factor(combined_data$group, levels = c(
  "Lepisosteidae",
  "Hybodontiformes",
  "Glyptops sp.",
  "Naomichelys sp.",
  "Neosuchian G",
  "Neosuchian A",
  "Neosuchian B",
  "NIST12Oc_aka_NBS120c"
))

# Plot histogram of resampled means for each taxon
ggplot(combined_data, aes(x = values, fill = group)) +
  geom_histogram(position = "identity", alpha = 0.7, bins = 30, color = "black") +
  labs(title = "Histogram of Means by Taxon",
       x = "Resampled Mean δ18Op",
       y = "Frequency") +
  theme_minimal() +
  facet_wrap(~group, scales = "free")

# d18Ow Simulations -----------------------

# Create d18Osw simulation function
simulate_water <- function(means_vector, model) {
  intercept_sim <- rnorm(n_iterations, mean = coef(model)[1], sd = summary(model)$coefficients[1,2])
  slope_sim <- rnorm(n_iterations, mean = coef(model)[2], sd = summary(model)$coefficients[2,2])
  residuals_sim <- rnorm(n_iterations, mean = 0, sd = summary(model)$sigma)
  
  rep(means_vector, each = n_iterations) * rep(slope_sim, times = length(means_vector)) +
    rep(intercept_sim, times = length(means_vector)) +
    rep(residuals_sim, times = length(means_vector))
}

# List of target taxa and corresponding regression models
water_sim_targets <- list(
  "Glyptops sp." = Barrick_lm,    # turtles -> Barrick regression
  "Naomichelys sp." = Barrick_lm, # turtles -> Barrick regression
  "Neosuchian G" = Amiot_lm,      # crocs -> Amiot regression
  "Neosuchian A" = Amiot_lm,      # crocs -> Amiot regression
  "Neosuchian B" = Amiot_lm       # crocs -> Amiot regression
)

# Initialize a list to store results
water_sim_results <- list()

# Initialize list to store full simulated distributions
water_sim_distributions <- list()

# Loop over each target taxon
for (taxon in names(water_sim_targets)) {
  sim_result <- simulate_water(bootstrap_results[[taxon]]$means, water_sim_targets[[taxon]])
  
  # Save summary results
  water_sim_results[[taxon]] <- list(
    mean = mean(sim_result),
    ci = quantile(sim_result, probs = c(0.025, 0.975))
  )
  
  # Save full distribution
  water_sim_distributions[[taxon]] <- sim_result
  
  # Print summary results
  cat("\n", taxon, "Water Mean:", round(water_sim_results[[taxon]]$mean, 2))
  cat("\n95% CI:", round(water_sim_results[[taxon]]$ci, 2), "\n")
}

# Simulate single d18Ow distribution based on crocG and Glyptops d18Ow

bootstrapped_d18Ow <- replicate(n_iterations, {
  sample_glyp <- sample(water_sim_distributions[["Glyptops sp."]], size = 1, replace = TRUE)
  sample_crocG <- sample(water_sim_distributions[["Neosuchian G"]], size = 1, replace = TRUE)
  mean(c(sample_glyp, sample_crocG))  # Average of the two
})

# Analyze combined distribution
mean_d18Ow <- mean(bootstrapped_d18Ow)
sd_d18Ow <- sd(bootstrapped_d18Ow)
quantiles <- quantile(bootstrapped_d18Ow, probs = c(0.025, 0.975))

mean_alld18Owater_synth <- mean_d18Ow
alld18Owater_lower <- quantiles[1]
alld18Owater_upper <- quantiles[2]

# Print results
cat("Mean δ¹⁸Ow:", mean_d18Ow, "\n")
cat("95% CI for δ¹⁸Ow: [", quantiles[1], ",", quantiles[2], "]\n")


# Water Temperature (Tw) Simulations -----------------------

delta_Op <- combined_data$values[combined_data$group == "Lepisosteidae"]
delta_Ow <- bootstrapped_d18Ow
NIST_sim <- combined_data$values[combined_data$group == "NIST12Oc_aka_NBS120c"]

# Simulate intercepts and slopes separately
intercept_sim <- rnorm(n_iterations, mean = coef(PLN_lm)[1], sd = summary(PLN_lm)$coefficients[1,2])
slope_sim <- rnorm(n_iterations, mean = coef(PLN_lm)[2], sd = summary(PLN_lm)$coefficients[2,2])

# Simulate residuals
residual_sim <- rnorm(n_iterations, mean = 0, sd = summary(PLN_lm)$sigma)

# Now compute Tw_simulations properly
set.seed(123)
Tw_simulations <- intercept_sim + 
  slope_sim * (delta_Op + (22.6 - NIST_sim) - delta_Ow) + 
  residual_sim

mean_Tw <- mean(Tw_simulations)
ci_Tw <- quantile(Tw_simulations, probs = c(0.025, 0.975), na.rm = TRUE)

cat("\nWater Temperature Mean:", mean_Tw)
cat("\n95% CI:", ci_Tw, "\n")

# Plot Tw histogram
# Calculate max y-value for adjustment (temporary plot to get y)
temp_plot <- ggplot(data.frame(Tw = Tw_simulations), aes(x = Tw)) +
  geom_histogram(bins = 50)
y_max <- ggplot_build(temp_plot)$data[[1]]$count %>% max()

# Add 10% headroom above max y-value for labels
buffer <- y_max * 0.1
label_y <- y_max + buffer

# Final plot with labels and spacing
ggplot(data.frame(Tw = Tw_simulations), aes(x = Tw)) +
  geom_histogram(fill = "skyblue", color = "black", bins = 50) +
  geom_vline(xintercept = mean_Tw, color = "red", linetype = "dashed") +
  geom_vline(xintercept = ci_Tw, color = "blue", linetype = "dotted") +
  annotate("text", x = mean_Tw, y = label_y, label = paste0("Mean = ", round(mean_Tw, 2)),
           vjust = 0, color = "red", size = 3.5) +
  annotate("text", x = ci_Tw[1], y = label_y, label = paste0("Lower 95% CI = ", round(ci_Tw[1], 2)),
           vjust = 0, color = "blue", size = 3.5) +
  annotate("text", x = ci_Tw[2], y = label_y, label = paste0("Upper 95% CI = ", round(ci_Tw[2], 2)),
           vjust = 0, color = "blue", size = 3.5) +
  ylim(0, label_y * 1.1) +
  labs(title = "Simulated Water Temperature (Tw)",
       x = "Water Temp (°C)", y = "Count") +
  theme_minimal()

ggsave(file.path(results_dir, "Tw_Histogram.png"))


# Air Temperature (Ta) Simulations -----------------------

# Simulate intercept and slope
intercept_sim <- rnorm(n_iterations, mean = coef(TwTa_lm)[1], sd = summary(TwTa_lm)$coefficients[1, 2])
slope_sim <- rnorm(n_iterations, mean = coef(TwTa_lm)[2], sd = summary(TwTa_lm)$coefficients[2, 2])
residuals_sim <- rnorm(n_iterations, mean = 0, sd = summary(TwTa_lm)$sigma)

# Now simulate Ta based on Tw_simulations
set.seed(123)
Ta_simulations <- intercept_sim + slope_sim * Tw_simulations + residuals_sim
mean_Ta <- mean(Ta_simulations)
ci_Ta <- quantile(Ta_simulations, probs = c(0.025, 0.975))

cat("\nAir Temperature Mean:", mean_Ta)
cat("\n95% CI:", ci_Ta, "\n")


# Plot Ta histogram
# Calculate max y-value for adjustment (temporary plot to get y)
temp_plot <- ggplot(data.frame(Ta = Ta_simulations), aes(x = Ta)) +
  geom_histogram(bins = 50)
y_max <- ggplot_build(temp_plot)$data[[1]]$count %>% max()

# Add 10% headroom above max y-value for labels
buffer <- y_max * 0.1
label_y <- y_max + buffer

# Final plot with labels and spacing
ggplot(data.frame(Ta = Ta_simulations), aes(x = Ta)) +
  geom_histogram(fill = "skyblue", color = "black", bins = 50) +
  geom_vline(xintercept = mean_Ta, color = "red", linetype = "dashed") +
  geom_vline(xintercept = ci_Ta, color = "blue", linetype = "dotted") +
  annotate("text", x = mean_Ta, y = label_y, label = paste0("Mean = ", round(mean_Ta, 2)),
           vjust = 0, color = "red", size = 3.5) +
  annotate("text", x = ci_Ta[1], y = label_y, label = paste0("Lower 95% CI = ", round(ci_Ta[1], 2)),
           vjust = 0, color = "blue", size = 3.5) +
  annotate("text", x = ci_Ta[2], y = label_y, label = paste0("Upper 95% CI = ", round(ci_Ta[2], 2)),
           vjust = 0, color = "blue", size = 3.5) +
  ylim(0, label_y * 1.1) +
  labs(title = "Simulated Air Temperature (Ta)",
       x = "Air Temp (°C)", y = "Count") +
  theme_minimal()

ggsave(file.path(results_dir, "Ta_Histogram.png"))
