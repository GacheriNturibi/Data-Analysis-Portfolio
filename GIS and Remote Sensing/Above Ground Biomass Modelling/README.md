![Remote Sensing](https://img.shields.io/badge/Tag-Remote--Sensing-blue)
![Earth Engine](https://img.shields.io/badge/Tag-Earth--Engine-green)
![Sentinel-2](https://img.shields.io/badge/Tag-Sentinel--2-lightgrey)
![Vegetation Indices](https://img.shields.io/badge/Tag-Vegetation--Indices-brightgreen)
![Above Ground Biomass](https://img.shields.io/badge/Tag-AGB-brown)
![Geemap](https://img.shields.io/badge/Tag-Geemap-teal)
![GIS](https://img.shields.io/badge/Tag-GIS-orange)
![Machine Learning](https://img.shields.io/badge/Tag-Machine--Learning-yellow)
![Scikit-Learn](https://img.shields.io/badge/Tag-Scikit--Learn-red)
![XGBoost](https://img.shields.io/badge/Tag-XGBoost-purple)
![Python](https://img.shields.io/badge/Tag-Python-blueviolet)
# Quantifying Above-Ground Biomass (AGB) from Sentinel-2 Indices with Google Earth Engine & ML

This project estimates **Above-Ground Biomass (AGB)** for the **Griffith University Logan Campus Arboretum** (AOI) using **Sentinel-2** imagery. It:
- computes multiple **vegetation indices** in **Google Earth Engine (GEE)**,
- **exports** rasters per index/year,
- **samples** index values at survey points,
- stacks results into tidy **CSV datasets**,
- visualizes temporal patterns, and
- trains baseline **ML regressors** to predict AGB.

> Notebook: `AGB_Indices_Download_Visualization_and_ML_Updated.ipynb`

---

##  Highlights

- **Indices computed (Sentinel-2):** `NDVI`, `MSAVI`, `EVI`, `LAI`, `RGR`, `RGI`, `OSAVI`
- **AGB proxy band:** `AGB = 14.046 + 272.496 × RGI` *(empirical model; see references)*
- **Years covered:** 2015–2022 (per-year median composites, cloud-masked)
- **AOI:** Shapefile (digitized in GIS; converted to EE FeatureCollection)
- **Sampling:** Point CSV (X/Y, grid_code) → values sampled from index rasters
- **Exports:**
  - GeoTIFFs to Drive (per index × year) via `ee.batch.Export.image.toDrive`
  - Stacked CSV: `df_Logan.csv`
  - Aggregated AGB per year (+ per-ha): `df_AGB.csv`
- **Visualization:** geemap layers, Plotly box plots, Matplotlib raster panels
- **Models:** Linear/Ridge/Lasso, Random Forest, SVR, KNN, XGBoost (+ CV metrics)

---

##  Method Overview

```mermaid
flowchart LR
  A["AOI Shapefile"] --> B["geemap.geopandas_to_ee → AOI"]
  A2["Raster Points CSV (X,Y,grid_code)"] --> C["EE FeatureCollection (points)"]
  B --> D["Sentinel-2 (2015–2022)"]
  D --> E["Cloud mask (QA60 bits 10 & 11)"]
  E --> F["Add bands: B2, B3, B4, B8"]
  F --> G["Compute indices: NDVI, MSAVI, EVI, LAI, RGR, RGI, OSAVI, AGB"]
  G --> H["Per-year median composites"]
  H --> I["Export rasters → Drive"]
  H --> J["Sample values at points"]
  J --> K["DataFrames → df_Logan.csv"]
  K --> L["EDA (Plotly / Matplotlib)"]
  K --> M["ML (scikit-learn / XGBoost) → Metrics"]
  K --> N["AGB aggregation → df_AGB.csv"]
```
---
**Project Structure**
```bash
/
├─ AGB_Indices_Download_Visualization_and_ML_Updated.ipynb   # main workflow
├─ data/
│  ├─ Logan_arb.shp ... (AOI shapefile + sidecars .dbf/.shx/.prj)
│  └─ Logan_raster_points.csv     # X, Y, grid_code for sampling
└─ outputs/   (created in Drive via notebook)
   ├─ VI_Exports/                  # NDVI_2015.tif, …, AGB_2022.tif
   ├─ df_Logan.csv
   └─ df_AGB.csv
```
