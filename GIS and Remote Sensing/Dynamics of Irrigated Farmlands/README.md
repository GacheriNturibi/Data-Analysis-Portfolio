[![Remote Sensing](https://img.shields.io/badge/Tag-Remote--Sensing-blue)](https://github.com/topics/remote-sensing)
[![Earth Engine](https://img.shields.io/badge/Tag-Earth--Engine-green)](https://github.com/topics/earth-engine)
[![Sentinel-2](https://img.shields.io/badge/Tag-Sentinel--2-lightgrey)](https://github.com/topics/sentinel-2)
[![Vegetation Indices](https://img.shields.io/badge/Tag-Vegetation--Indices-brightgreen)](https://github.com/topics/vegetation-indices)
[![GIS](https://img.shields.io/badge/Tag-GIS-red)](https://github.com/topics/gis)
[![Geemap](https://img.shields.io/badge/Tag-Geemap-teal)](https://github.com/topics/geemap)
[![Python](https://img.shields.io/badge/Tag-Python-blueviolet)](https://github.com/topics/python)

# Dynamics of Irrigated Farmlands - Project Mashuru: Vegetation Monitoring using Sentinel-2

This project focuses on monitoring vegetation dynamics in **Mashuru, Kenya** using **Sentinel-2 imagery** and vegetation indices derived in **Google Earth Engine (GEE)**.  

It automates the retrieval of indices, exports data for analysis, and produces visualizations to better understand vegetation health and land surface changes in the area of interest.

> Notebook: `Project_Mashuru.ipynb`

---

##  Highlights

- **AOI:** Mashuru region, Kenya (digitized shapefile uploaded to GEE)  
- **Indices calculated:** NDVI, SAVI, MSAVI, OSAVI, LAI, RGI  
- **Timeframe:** Multi-year Sentinel-2 imagery composites  
- **Workflow:**
  - Cloud masking & Sentinel-2 preprocessing  
  - Vegetation index computation  
  - Sampling at reference points / grids  
  - Export of rasters & tabular data  
  - Visualization (NDVI maps, time-series plots)  

---

##  Method Overview

```mermaid
flowchart LR
  A["AOI Shapefile (Mashuru)"] --> B["geemap.geopandas_to_ee → AOI"]
  B --> C["Sentinel-2 (multi-year imagery)"]
  C --> D["Cloud mask preprocessing"]
  D --> E["Compute Vegetation Indices (NDVI, EVI, etc.)"]
  E --> F["Export rasters → Drive"]
  E --> G["Sample values at points / grid"]
  G --> H["DataFrames → CSV"]
  H --> I["Visualization (NDVI maps, time-series, boxplots)"]
```
---
**Project Structure**
```bash
/
├─ Project_Mashuru.ipynb    # main workflow notebook
├─ data/
│  ├─ Mashuru_AOI.shp ...   # AOI shapefile
│  └─ Sample_points.csv     # points for sampling vegetation indices
└─ outputs/
   ├─ VI_Exports/           # exported rasters (GeoTIFFs)
   ├─ df_Mashuru.csv        # stacked vegetation index values
   └─ figures/              # NDVI maps, time-series plots
```
