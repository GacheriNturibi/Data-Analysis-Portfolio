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
    
#############################################################################################################################################################################
# Step 5: Fit a theoretical variogram model
# A mathematical model (e.g., Spherical, Exponential, Gaussian) is fitted to the empirical variogram. This model mathematically describes the spatial structure and is used for interpolation.
    
# vgm("Sph"): Specifies a Spherical model. Other options include "Exp" (Exponential), "Gau" (Gaussian).
# psill, range, nugget: Initial guesses for the model parameters. These are refined by fit.variogram().
#############################################################################################################################################################################   
    
# --- PART 5: Fit a Theoretical Variogram Model ---
    
# Plot the empirical variogram
p2 <- ggplot(vgm_ok_empirical, aes(x = dist, y = gamma)) +
  geom_point(color = "darkblue", size = 2) +   
  labs(
    title = "Empirical Variogram of Soil Zinc Concentration",
    x = "Distance (h)",
    y = "Semivariance (gamma)"
    ) +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5, face = "bold"))
  print(p2)
  
  cat("Step 5a: Displayed Empirical Variogram.\n")
    
# Fit a spherical model
vgm_ok_model <- fit.variogram(vgm_ok_empirical, model = vgm("Sph", psill = 100000, range = 800, nugget = 10000))
cat("\nStep 5b: Fitted Theoretical Variogram Model Parameters for OK:\n")
print(vgm_ok_model)
cat("\n")
    
# Plot empirical variogram with the fitted model overlaid
p3 <- p2 +
  geom_line(data = variogramLine(vgm_ok_model, maxdist = 1500), aes(x = dist, y = gamma), color = "red", linetype = "dashed", size = 1) +
  labs(subtitle = paste0("Fitted Model: ", vgm_ok_model$model[2], " (Nugget=",
                         round(vgm_ok_model$psill[1],2), ", Sill=", round(vgm_ok_model$psill[2],2), ", Range=",
                         round(vgm_ok_model$range[2],2), ")"))
print(p3)
cat("Step 5c: Displayed Empirical Variogram with Fitted Model.\n\n")
    
#############################################################################################################################################################################
# Step 6: Define the prediction grid
# This is the set of un-sampled locations where you want to predict values. The meuse.grid dataset provides a pre-defined grid for the Meuse area, which also contains covariates.
#############################################################################################################################################################################    
    
# --- PART 6: Define the Prediction Grid ---
    
data(meuse.grid) # Loads the 'meuse.grid' data frame
coordinates(meuse.grid) <- ~x+y
gridded(meuse.grid) <- TRUE # Tell R that it's a grid
    
cat("Step 6: Loaded and Prepared Prediction Grid (Meuse Grid - First 6 Grid Points):\n")
print(head(as.data.frame(meuse.grid), 6))
cat(paste0(" Total grid points: ", nrow(meuse.grid), "\n\n"))
    
#############################################################################################################################################################################
# Step 7: Perform Ordinary Kriging
# The krige () function performs the interpolation. It takes your sample data, the prediction grid, and the fitted variogram model.
#############################################################################################################################################################################    
    
# --- PART 7: Perform Ordinary Kriging ---
    
ok_output <- krige(zinc ~ 1, locations = meuse,
                   newdata = meuse.grid, model = vgm_ok_model)
meuse.grid$OK_prediction <- ok_output$var1.pred
meuse.grid$OK_variance <- ok_output$var1.var

cat("Step 7: Ordinary Kriging Performed (First 6 OK Predicted Points):\n")
print(head(as.data.frame(meuse.grid), 6))
cat("\n")
    
#############################################################################################################################################################################
# Step 8: Visualize the Kriging results
# Two main maps are produced:
      
# Prediction Map (var1.pred): Shows the interpolated values across the entire grid.
# Prediction Variance Map (var1.var): Shows the uncertainty of the predictions. Areas further from sample points typically have higher variance (less certainty).
#############################################################################################################################################################################    
    
# --- PART 8: Visualize the Kriging Results ---
    
rk_results_df <- as.data.frame(meuse.grid) # Re-using rk_results_df for consistency in plotting
    
# Plot the Ordinary Kriging Prediction Map
    
p_ok_pred <- ggplot(as.data.frame(meuse.grid), aes(x = x, y = y, fill = OK_prediction)) +
  geom_tile() +
  geom_point(data = meuse_plot_df, aes(x = x, y = y),
             color = "black", shape = 4, size = 1.5, stroke = 1, inherit.aes = FALSE) +
  scale_fill_viridis(option = "C", name = "OK Predicted Zinc (ppm)") +
  labs(
    title = "Ordinary Kriging Prediction Map of Soil Zinc Concentration",
    subtitle = "Black crosses indicate sample locations",
    x = "Easting (m)",
    y = "Northing (m)"
    ) +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5, face = "bold"),
        plot.subtitle = element_text(hjust = 0.5)) +
  coord_fixed()
print(p_ok_pred)
cat("Step 8a: Displayed Ordinary Kriging Prediction Map.\n\n")
    
# Plot the Ordinary Kriging Prediction Variance Map
p_ok_var <- ggplot(as.data.frame(meuse.grid), aes(x = x, y = y, fill = OK_variance)) +
  geom_tile() +
  geom_point(data = meuse_plot_df, aes(x = x, y = y),
             color = "red", shape = 4, size = 1.5, stroke = 1, inherit.aes = FALSE) +
  scale_fill_viridis(option = "D", name = "OK Prediction Variance", direction = -1) +
  labs(
    title = "Ordinary Kriging Prediction Variance Map",
    subtitle = "Red crosses indicate sample locations (areas of lower variance)",
    x = "Easting (m)",
    y = "Northing (m)"
    ) +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5, face = "bold"),
        plot.subtitle = element_text(hjust = 0.5)) +
  coord_fixed()
print(p_ok_var)
cat("Step 8b: Displayed Ordinary Kriging Prediction Variance Map.\n\n")