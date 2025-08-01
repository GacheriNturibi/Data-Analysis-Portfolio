# Parts 1-4 are the same as OK (data loading, spatial object, visualization, grid preparation)
#############################################################################################################################################################################
# --- PART 0: Install and Load Necessary R Packages ---
# If you don't have these packages installed, uncomment and run the 'install.packages()' lines first.
# install.packages("sp") # For handling spatial data (contains 'meuse' dataset)
# install.packages("gstat") # For geostatistical analysis (variograms, kriging)
# install.packages("ggplot2") # For nice visualizations # install.packages("viridis")
# For color scales in plots # install.packages("dplyr") # For data manipulation (e.g., mutate)
#############################################################################################################################################################################

library(sp)
library(gstat)
library(ggplot2)
library(viridis)
library(dplyr)

cat("--- Ordinary Kriging Exercise: Mapping Soil Zinc Concentration (Meuse Dataset) ---\n\n")

#############################################################################################################################################################################
# Step 1: Load sample data
# The data(meuse) command loads the meuse dataset directly into your R environment. This dataset contains x and y coordinates, and zinc concentration, among other variables.
#############################################################################################################################################################################

#--- PART 1: Load Sample Data (Meuse Dataset) ---

data(meuse)
cat("Step 1: Loaded Meuse Dataset (First 6 Rows):\n")
print(head(meuse))
cat("\n")

#############################################################################################################################################################################
# Options
# Step 2: Convert data to a spatial object
# Geostatistical functions in R (especially from gstat) require data to be in a spatial format. We convert the standard data frame into a SpatialPointsDataFrame by 
# specifying which columns are coordinates
#############################################################################################################################################################################

# --- PART 2: Convert Data to a Spatial Object (SpatialPointsDataFrame) --

coordinates(meuse) <- ~x+y # Define coordinates
cat("Step 2: Structure of the SpatialPointsDataFrame (Meuse):\n")
print(str(meuse))

cat("\n")
#############################################################################################################################################################################
# Step 3: Visualize the sampled data
# Before any analysis, it's crucial to visualize your sample locations and the values of the variable 
# you're interested in. This helps identify spatial patterns or potential issues.
#############################################################################################################################################################################

# --- PART 3: Visualize the Sampled Data ---

meuse_plot_df <- as.data.frame(meuse)

p1 <- ggplot(meuse_plot_df, aes(x = x, y = y, color = zinc, size = zinc)) +
  geom_point(alpha = 0.8) +
  scale_color_viridis(option = "C", name = "Zinc (ppm)") +
  labs(
    title = "Spatial Distribution of Soil Zinc Concentration Samples",
    x = "Easting (m)",
    y = "Northing (m)"
  ) +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5, face = "bold"))

print(p1)

cat("Step 3: Displayed scatter plot of sample locations and zinc values.\n\n")

#############################################################################################################################################################################
# Step 4: Calculate the empirical variogram
# The empirical variogram is calculated from your sample data. It shows the observed spatial dissimilarity.

# zinc ~ 1: Specifies that zinc is the variable of interest, and ~ 1 indicates Ordinary Kriging (assuming a constant mean).
# cutoff: The maximum distance for which to calculate semivariance.
# width: The size of the distance bins.
#############################################################################################################################################################################    

# --- PART 4: Calculate the Empirical Variogram ---

vgm_ok_empirical <- variogram(zinc ~ 1, data = meuse,
                              
                              cutoff = 1500, width = 100) # Adjusted cutoff and width for Meuse data scale

cat("Step 4: Empirical Variogram for OK Calculated (First 6 Rows):\n")

print(head(vgm_ok_empirical))

cat("\n")
cat("--- Regression Kriging Exercise: Mapping Soil Zinc Concentration (Meuse Dataset) ---\n\n")


#############################################################################################################################################################################

# elements-15

# Step 5: Build the deterministic model (Linear Regression)
# We fit a linear model to explain zinc concentration using dist and ffreq.
#############################################################################################################################################################################

# --- PART 5: Build the Deterministic Model (Linear Regression) for RK ---

lm_model <- lm(zinc ~ dist + ffreq, data = meuse)
cat("Step 5a: Linear Model Summary (Zinc ~ Distance to River + Flood Frequency):\n")
print(summary(lm_model))
cat("\n")

# Predict the deterministic component across the entire grid

meuse.grid$zinc_pred_lm <- predict(lm_model, newdata = meuse.grid)
cat("Step 5b: Deterministic Prediction on Grid (First 6 Points):\n")
print(head(as.data.frame(meuse.grid), 6))
cat("\n")

# Visualize the Deterministic Trend Map

p_lm_pred <- ggplot(as.data.frame(meuse.grid), aes(x = x, y = y, fill = zinc_pred_lm)) +
  geom_tile() +
  scale_fill_viridis(option = "B", name = "LM Predicted Zinc (ppm)") +
  labs(
    title = "Deterministic Trend Map (Linear Model Prediction)",
    x = "Easting (m)",
    y = "Northing (m)"
    ) +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5, face = "bold")) +
  coord_fixed()
print(p_lm_pred)
cat("Step 5c: Displayed Deterministic Trend Map.\n\n")

#############################################################################################################################################################################
# Step 6: Calculate and analyse residuals
# The residuals are the part of the zinc variation that the linear model could not explain. These are the values we will krige.
#############################################################################################################################################################################

# --- PART 6: Calculate and Analyze Residuals for RK ---

meuse$residuals <- residuals(lm_model)
cat("Step 6a: Calculated Residuals (First 6 Samples):\n")
print(head(as.data.frame(meuse), 6))
cat("\n")

# Visualize the Residuals at Sampled Locations

p_residuals <- ggplot(as.data.frame(meuse), aes(x = x, y = y, color = residuals, size = abs(residuals))) +
  geom_point(alpha = 0.8) +
  scale_color_gradient2(low = "blue", mid = "grey", high = "red", midpoint = 0, name = "Residuals") +
  labs(
    title = "Spatial Distribution of Residuals",
    x = "Easting (m)",
    y = "Northing (m)"
    ) +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5, face = "bold"))
print(p_residuals)
cat("Step 6b: Displayed Spatial Distribution of Residuals.\n\n")

#############################################################################################################################################################################
# Step 7: Calculate the empirical variogram of residuals
# We now compute the variogram for these residuals. This helps us understand the spatial correlation of the unexplained variability.
#############################################################################################################################################################################


#--- PART 7: Calculate the Empirical Variogram of Residuals for RK ---
  
vgm_residuals_empirical <- variogram(residuals ~ 1, data = meuse,
                                       
                                       cutoff = 1500, width = 100)
cat("Step 7: Empirical Variogram of Residuals Calculated (First 6 Rows):\n")
print(head(vgm_residuals_empirical))
cat("\n")

#############################################################################################################################################################################
# Step 8: Fit a theoretical variogram model to residuals
# A theoretical model is fitted to the residual variogram. This model often shows a clearer spatial structure than the original data's variogram because the trend has been removed.
#############################################################################################################################################################################
 

# --- PART 8: Fit a Theoretical Variogram Model to Residuals for RK ---#
p_res_vgm_emp <- ggplot(vgm_residuals_empirical, aes(x = dist, y = gamma)) +
  geom_point(color = "darkgreen", size = 2) +
  labs(
    title = "Empirical Variogram of Residuals",
    x = "Distance (h)",
    y = "Semivariance (gamma)"
    ) +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5, face = "bold"))
print(p_res_vgm_emp)
cat("Step 8a: Displayed Empirical Variogram of Residuals.\n")

vgm_residuals_model <- fit.variogram(vgm_residuals_empirical, model = vgm("Sph", psill = 10000, range = 500, nugget = 1000))
cat("\nStep 8b: Fitted Theoretical Variogram Model Parameters for Residuals:\n")
print(vgm_residuals_model)
cat("\n")

 p_res_vgm_fitted <- p_res_vgm_emp +
   geom_line(data = variogramLine(vgm_residuals_model, maxdist = 1500), aes(x = dist, y = gamma), color = "purple", linetype = "dashed", size = 1) +
   labs(subtitle = paste0("Fitted Model: ", vgm_residuals_model$model[2], " (Nugget=",
                          round(vgm_residuals_model$psill[1],2), ", Sill=", round(vgm_residuals_model$psill[2],2), ", Range=",
                          round(vgm_residuals_model$range[2],2), ")"))
 print(p_res_vgm_fitted)
 cat("Step 8c: Displayed Empirical Variogram of Residuals with Fitted Model.\n\n")

 #############################################################################################################################################################################
# Step 9: Perform ordinary kriging of residuals
# The residuals are now kriged across the prediction grid, just like in Ordinary Kriging.
 #############################################################################################################################################################################
 
# --- PART 9: Perform Ordinary Kriging of Residuals for RK ---

kriged_residuals_output <- krige(residuals ~ 1, locations = meuse,
                                 newdata = meuse.grid, model = vgm_residuals_model)
 cat("Step 9: Ordinary Kriging of Residuals Performed (First 6 Predicted Residuals):\n")
 print(head(as.data.frame(kriged_residuals_output), 6))
 cat("\n")

##############################################################################################################################################################################
# Step 10: Combine deterministic and stochastic parts (Regression Kriging)
# The final RK prediction is obtained by adding the predicted deterministic trend (from Step 5) to the kriged residuals (from Step 9).
##############################################################################################################################################################################
 
# --- PART 10: Combine Deterministic and Stochastic Parts (Regression Kriging) ---

meuse.grid$residuals_pred <- kriged_residuals_output$var1.pred
 meuse.grid$residuals_var <- kriged_residuals_output$var1.var
 meuse.grid$RK_prediction <- meuse.grid$zinc_pred_lm + meuse.grid$residuals_pred
 meuse.grid$RK_variance <- meuse.grid$residuals_var # Simplistic, assumes LM variance is zero or constant.
 cat("Step 10: Combined Deterministic and Stochastic Parts (First 6 RK Predictions):\n")
 print(head(as.data.frame(meuse.grid), 6))
 cat("\n")

 #############################################################################################################################################################################
# Step 11: Visualize the regression kriging results
# Similar to OK, we visualize the prediction map and the variance map for RK. # ---
 #############################################################################################################################################################################
 

# --- PART 11: Visualize the Regression Kriging Results ---

rk_results_df <- as.data.frame(meuse.grid)

# Plot the Regression Kriging Prediction Map

p_rk_pred <- ggplot(rk_results_df, aes(x = x, y = y, fill = RK_prediction)) +
  geom_tile() +
  geom_point(data = meuse_plot_df, aes(x = x, y = y),
             color = "black", shape = 4, size = 1.5, stroke = 1, inherit.aes = FALSE) +
  scale_fill_viridis(option = "C", name = "RK Predicted Zinc (ppm)") +
  labs(
    title = "Regression Kriging Prediction Map of Soil Zinc Concentration",
    subtitle = "Black crosses indicate sample locations",
    x = "Easting (m)",
    y = "Northing (m)"
    ) +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5, face = "bold"),
        plot.subtitle = element_text(hjust = 0.5)) +
  coord_fixed()
print(p_rk_pred)

cat("Step 11a: Displayed Regression Kriging Prediction Map.\n\n")

 # Plot the Regression Kriging Prediction Variance Map

p_rk_var <- ggplot(rk_results_df, aes(x = x, y = y, fill = RK_variance)) +
  geom_tile() +
  geom_point(data = meuse_plot_df, aes(x = x, y = y),
             color = "red", shape = 4, size = 1.5, stroke = 1, inherit.aes = FALSE) +
  scale_fill_viridis(option = "D", name = "RK Prediction Variance", direction = -1) +
  labs(
    title = "Regression Kriging Prediction Variance Map",
    subtitle = "Red crosses indicate sample locations (areas of lower variance)",
    x = "Easting (m)",
    y = "Northing (m)"
    ) +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5, face = "bold"),
        plot.subtitle = element_text(hjust = 0.5)) +
  coord_fixed()
print(p_rk_var)

cat("Step 11b: Displayed Regression Kriging Prediction Variance Map.\n\n")