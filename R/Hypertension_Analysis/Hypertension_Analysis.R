# Step 1: Install and load the required package
install.packages("readxl")
library(readxl)

# Step 2: Read the dataset
data <- read_excel("C:/Users/gache/Desktop/Sagar/Excel_files_V2/NPHR82FL.xlsx")
head(data)

# Step 3: Define the important columns to keep
# Use backticks to escape column names with special characters (e.g., $)
important_columns <- c(
  # Tobacco Use
  "`WBP5$1`", "`WBP5$2`", "`WBP5$3`", "`WBP5$4`", "`WBP5$5`", "`WBP5$6`", "`WBP5$7`", "`WBP5$8`", "`WBP5$9`",
  "`MBP5$1`", "`MBP5$2`", "`MBP5$3`", "`MBP5$4`", "`MBP5$5`", "`MBP5$6`",
  
  # Hypertension
  "`WBP24$1`", "`WBP26$1`", "`WBP26$2`", "`WBP26$3`", "`WBP26$4`", "`WBP26$5`", "`WBP26$6`", "`WBP26$7`", "`WBP26$8`", "`WBP26$9`",
  "`MBP26$1`", "`MBP26$2`", "`MBP26$3`", "`MBP26$4`", "`MBP26$5`", "`MBP26$6`",
  "`WBP16$1`", "`WBP16$2`", "`WBP16$3`", "`WBP16$4`", "`WBP16$5`", "`WBP16$6`", "`WBP16$7`", "`WBP16$8`", "`WBP16$9`",
  "`MBP16$1`", "`MBP16$2`", "`MBP16$3`", "`MBP16$4`", "`MBP16$5`", "`MBP16$6`",
  
  # Obesity and BMI
  "`HA40$1`", "`HA40$2`", "`HA40$3`", "`HA40$4`", "`HA40$5`", "`HA40$6`", "`HA40$7`", "`HA40$8`", "`HA40$9`",
  "`HB40$1`", "`HB40$2`", "`HB40$3`", "`HB40$4`", "`HB40$5`", "`HB40$6`",
  
  # Demographic and Socio-Economic Factors
  "`HA1$1`", "`HA1$2`", "`HA1$3`", "`HA1$4`", "`HA1$5`", "`HA1$6`", "`HA1$7`", "`HA1$8`", "`HA1$9`",
  "`HB1$1`", "`HB1$2`", "`HB1$3`", "`HB1$4`", "`HB1$5`", "`HB1$6`",
  "`HA66$1`", "`HA66$2`", "`HA66$3`", "`HA66$4`", "`HA66$5`", "`HA66$6`", "`HA66$7`", "`HA66$8`", "`HA66$9`",
  "`HB66$1`", "`HB66$2`", "`HB66$3`", "`HB66$4`", "`HB66$5`", "`HB66$6`",
  "HV270", "HV025",
  
  # Geographic Data
  "HV024",
  
  # Nutritional Status
  "HFS1", "HFS2", "HFS3", "HFS4", "HFS5", "HFS6", "HFS7", "HFS8"
)

# Step 4: Create a new dataframe with only the important columns
# Use `dplyr` for cleaner column selection
install.packages("dplyr")
library(dplyr)

important_data <- data %>%
  select(all_of(important_columns))

# Step 5: Rename columns for easier analysis
colnames(important_data) <- c(
  # Tobacco Use
  "Smoke_W1", "Smoke_W2", "Smoke_W3", "Smoke_W4", "Smoke_W5", "Smoke_W6", "Smoke_W7", "Smoke_W8", "Smoke_W9",
  "Smoke_M1", "Smoke_M2", "Smoke_M3", "Smoke_M4", "Smoke_M5", "Smoke_M6",
  
  # Hypertension
  "BP_Systolic_W1", "BP_Category_W1", "BP_Category_W2", "BP_Category_W3", "BP_Category_W4", "BP_Category_W5", 
  "BP_Category_W6", "BP_Category_W7", "BP_Category_W8", "BP_Category_W9",
  "BP_Category_M1", "BP_Category_M2", "BP_Category_M3", "BP_Category_M4", "BP_Category_M5", "BP_Category_M6",
  "Hypertension_Dx_W1", "Hypertension_Dx_W2", "Hypertension_Dx_W3", "Hypertension_Dx_W4", "Hypertension_Dx_W5", 
  "Hypertension_Dx_W6", "Hypertension_Dx_W7", "Hypertension_Dx_W8", "Hypertension_Dx_W9",
  "Hypertension_Dx_M1", "Hypertension_Dx_M2", "Hypertension_Dx_M3", "Hypertension_Dx_M4", "Hypertension_Dx_M5", "Hypertension_Dx_M6",
  
  # Obesity and BMI
  "BMI_W1", "BMI_W2", "BMI_W3", "BMI_W4", "BMI_W5", "BMI_W6", "BMI_W7", "BMI_W8", "BMI_W9",
  "BMI_M1", "BMI_M2", "BMI_M3", "BMI_M4", "BMI_M5", "BMI_M6",
  
  # Demographic and Socio-Economic Factors
  "Age_W1", "Age_W2", "Age_W3", "Age_W4", "Age_W5", "Age_W6", "Age_W7", "Age_W8", "Age_W9",
  "Age_M1", "Age_M2", "Age_M3", "Age_M4", "Age_M5", "Age_M6",
  "Edu_W1", "Edu_W2", "Edu_W3", "Edu_W4", "Edu_W5", "Edu_W6", "Edu_W7", "Edu_W8", "Edu_W9",
  "Edu_M1", "Edu_M2", "Edu_M3", "Edu_M4", "Edu_M5", "Edu_M6",
  "Wealth_Index", "Residence_Type",
  
  # Geographic Data
  "Province",
  
  # Nutritional Status
  "Worry_Food", "Unable_Healthy_Food", "Few_Foods", "Skipped_Meal", "Ate_Less", "Ran_Out_Food", "Hungry_No_Eat", "No_Eat_Whole_Day"
)

# Step 6: View the new dataframe
head(important_data)

# Step 7: Save the cleaned dataframe (optional)
write.csv(important_data, "C:/Users/gache/Desktop/Sagar/Excel_files_V2/cleaned_data.csv", row.names = FALSE)