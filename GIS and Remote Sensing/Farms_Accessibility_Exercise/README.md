[![GIS](https://img.shields.io/badge/Tag-GIS-orange)](https://github.com/topics/gis)
[![Accessibility Analysis](https://img.shields.io/badge/Tag-Accessibility--Analysis-blue)](https://github.com/topics/accessibility-analysis)
[![ArcGIS Pro](https://img.shields.io/badge/Tag-ArcGIS--Pro-green)](https://github.com/topics/arcgis-pro)
[![Spatial Analysis](https://img.shields.io/badge/Tag-Spatial--Analysis-lightgrey)](https://github.com/topics/spatial-analysis)
[![Transportation](https://img.shields.io/badge/Tag-Transportation-yellow)](https://github.com/topics/transportation)

# GIS Road Accessibility Analysis in Rwanda

This project evaluates **Company X’s road network in Rwanda** to ensure that farm plots are **accessible for input delivery**.  
The analysis was conducted using **ArcGIS Pro**, focusing on the distance of farm plots from **primary roads** and quantifying inaccessible areas.  

All source data, intermediate outputs, and the final map are included in this repository.

 
> **Roads and Farms Data:** [Exercise Files](https://github.com/GacheriNturibi/Data-Analysis-Portfolio/tree/main/GIS%20and%20Remote%20Sensing/Farms_Accessibility_Exercise/Exercise%20Files)
>
> **Report:** `GIS Analysis Exercise.docx`
>
> **Software:** ArcGIS Pro, QGIS, Microsoft Word

---

##  Highlights

- **AOI:** Rwanda, near Nyanza (projected to UTM Zone 35S, EPSG:32735)  
- **Road data:** OpenStreetMap (primary + primary_link categories)  
- **Farm data:** Vector dataset of farm plots  
- **Workflow:**
  - Road filtering (primary roads only)  
  - Buffering (2 km catchment around roads)  
  - Dissolving overlapping buffers  
  - Selecting farms beyond the buffer (90 plots identified)  
  - Area calculation for inaccessible plots (~3.55 ha)  
  - Final map with **multi-distance buffers**  

---

##  Method Overview

```mermaid
flowchart LR
  A["OSM Roads Data"] --> B["Select Primary Roads (by attribute)"]
  B --> C["Buffer (2 km)"]
  C --> D["Dissolve Overlaps"]
  D --> E["Select by Location (farms beyond buffer)"]
  E --> F["Calculate Farm Areas (geometry)"]
  F --> G["Summarize Areas (3.55 ha beyond buffer)"]
  G --> H["Final Map with Multiple Buffers"]
```
**Structure**
```bash
/
├─ GIS Analysis Exercise.docx        # Report describing the workflow
├─ data/
│  ├─ farms.shp                      # Farm plots
│  ├─ hotosm_rwa_roads_lines.shp     # OSM roads
│  └─ primary_road_category_only.shp # Filtered primary roads
├─ outputs/
│  ├─ buffer_2km.shp                 # 2 km buffer zone
│  ├─ farms_beyond_buffer.shp        # Farms beyond 2 km
│  ├─ statistics.csv                 # Area calculations
│  └─ final_map.png                  # Map visualization
```
