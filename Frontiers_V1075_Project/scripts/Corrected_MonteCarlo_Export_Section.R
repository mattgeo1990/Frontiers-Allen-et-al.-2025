
# Summarize Monte Carlo Results ------------------------------------------------

# Define which taxa should have d18Osw results
taxa_with_d18Osw <- c("Glyptops sp.", "Naomichelys sp.", "Neosuchian G", "Neosuchian A", "Neosuchian B")

# Build summary table
summary_table <- do.call(rbind, lapply(names(results_list), function(group) {
  res <- results_list[[group]]
  
  # Summary for d18Op (always computed)
  d18Op_mean <- mean(res$d18Op_simulated)
  d18Op_ci   <- quantile(res$d18Op_simulated, probs = c(0.025, 0.975), na.rm = TRUE)
  
  # Summary for d18Osw (only if taxon is aquatic)
  if (group %in% taxa_with_d18Osw) {
    d18Osw_mean <- mean(res$d18Osw_simulated)
    d18Osw_ci   <- quantile(res$d18Osw_simulated, probs = c(0.025, 0.975), na.rm = TRUE)
  } else {
    d18Osw_mean <- NA
    d18Osw_ci   <- c(NA, NA)
  }
  
  data.frame(
    Taxon = group,
    Mean_d18Op = d18Op_mean,
    d18Op_CI_Lower = d18Op_ci[1],
    d18Op_CI_Upper = d18Op_ci[2],
    Mean_d18Osw = d18Osw_mean,
    d18Osw_CI_Lower = d18Osw_ci[1],
    d18Osw_CI_Upper = d18Osw_ci[2]
  )
}))

# Export Summary Table
write.csv(summary_table, file.path(results_dir, "MonteCarlo_Summary.csv"), row.names = FALSE)

# Export Histograms ------------------------------------------------------------

for (group in names(results_list)) {
  res <- results_list[[group]]
  
  # Only plot Tw and Ta if they exist (i.e., for aquatic taxa)
  if (!is.null(res$T_water_simulated) && !is.null(res$T_air_simulated)) {
    
    # Water Temperature Histogram
    water_plot <- ggplot(data.frame(Tw = res$T_water_simulated), aes(x = Tw)) +
      geom_histogram(fill = "skyblue", color = "black", bins = 50) +
      geom_vline(xintercept = mean(res$T_water_simulated), color = "red", linetype = "dashed") +
      geom_vline(xintercept = quantile(res$T_water_simulated, c(0.025, 0.975)), color = "blue", linetype = "dotted") +
      labs(title = paste("Simulated Water Temperature (Tw) -", group),
           x = "Water Temperature (°C)", y = "Count") +
      theme_minimal()
    
    ggsave(filename = file.path(results_dir, paste0("Tw_Histogram_", group, ".png")),
           plot = water_plot, width = 7, height = 5, dpi = 300)
    
    # Air Temperature Histogram
    air_plot <- ggplot(data.frame(Ta = res$T_air_simulated), aes(x = Ta)) +
      geom_histogram(fill = "lightgreen", color = "black", bins = 50) +
      geom_vline(xintercept = mean(res$T_air_simulated), color = "red", linetype = "dashed") +
      geom_vline(xintercept = quantile(res$T_air_simulated, c(0.025, 0.975)), color = "blue", linetype = "dotted") +
      labs(title = paste("Simulated Air Temperature (Ta) -", group),
           x = "Air Temperature (°C)", y = "Count") +
      theme_minimal()
    
    ggsave(filename = file.path(results_dir, paste0("Ta_Histogram_", group, ".png")),
           plot = air_plot, width = 7, height = 5, dpi = 300)
  }
}

# Final Message ---------------------------------------------------------------

cat("\n✅ Monte Carlo summary table and Tw/Ta histograms exported to results/.\n")
