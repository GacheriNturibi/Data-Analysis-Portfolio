library(sp)
library(gstat)
library(automap)
library(maptools)
library(rgdal)
library(raster)
library(sf)
library(mgcv)

setwd("E:/Research_Program/Scripts_R_Python_store/Shee/Bednets")
data=read.csv("bednets_15.csv", header = T)
head(data)

# convert simple data frame into spatial point data frame
# Set coordinate system to GCS-WGS84
proj4string <- "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"
statPoints <- SpatialPointsDataFrame(coords      = data[,c("LONG","LAT")], 
                                     data        = data,
                                     proj4string = CRS(proj4string))

print(statPoints)

##remove duplicate locations call sp::zerodist within a bracket index.
##statPoints <- statPoints[-zerodist(statPoints)[,1],]

# Compute Experimental variogram as variogram object
ok_param = autofitVariogram(ITN_Covera~1, 
                            statPoints, 
                            model = c("Sph", "Exp", "Gau"),
                            kappa = c(0.05, seq(0.2, 2, 0.1), 5, 10))

summary(ok_param) 
plot(ok_param)

vgm=variogram(ITN_Covera~1, statPoints) 
summary(vgm) 
plot(vgm)


##Create experimental variogram object based on sample points
variog=variogram(ITN_Covera~1, statPoints)

## create variogram model by passing appropriate variogram parameters - Equivalent to model training
est <- vgm(0.0058880972,"Gau",99.10512,0.0003759629)


## fit Variogram model in to the variogram object
fitted <- fit.variogram(variog, est)
plot(variog, model=fitted)


#Importing the predicted grid data-unsampled locations(either csv or shp)
pred_grid=read.csv("Bednet.csv")

# convert simple data frame into spatial point data frame
# Set coordinate system to GCS-WGS84
proj4string <- "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"
predic_stat_grid <- SpatialPointsDataFrame(coords      = pred_grid[,c("LONG","LAT")], 
                                           data        = pred_grid,
                                           proj4string = CRS(proj4string))

# interpolate using ordinary kriging method on unsampled grid points
o.k <- krige(ITN_Covera~1, statPoints, predic_stat_grid, fitted)
summary(o.k)
plot(o.k)

# write the regression results as csv table
write.csv(o.k, file = "Bednet_OK_Kenya.csv")
interpolated_residuals = read.csv("Bednet_OK_Kenya.csv.csv",header = T)