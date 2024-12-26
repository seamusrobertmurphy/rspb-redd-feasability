### PDF format
---
  title: "REDD+ Feasability Assessment"
subtitle: "Review of emissions estimates & activity data used in the RSPB Gola feasibility assessment"
date: "2024-12-23"
output: 
  pdf_document: 
  toc: TRUE
toc_depth: 3
pandoc_args: --listings
includes:
  in_header: preamble.tex

editor_options: 
  markdown: 
  wrap: 120
always_allow_html: TRUE
bibliography: references.bib
df-print: kable
---

### WORD format

output: 
  word_document:
  keep_md: TRUE
  toc: FALSE

editor_options: 
  markdown: 
  wrap: 80
always_allow_html: true




## tmap layout

tmap::tm_shape(RGB_2014) + tmap::tm_raster(title = "RGB, 2014") +
  tmap::tm_shape(country) + tmap::tm_borders(col = "blue", lwd = 2) +
  tmap::tm_shape(aoi) + tmap::tm_borders(col = "red", lwd = 1) +
  tmap::tm_basemap("Esri.WorldImagery") +  
  tmap::tm_compass(position = c("left", "bottom")) +
  tmap::tm_scale_bar() -> tm3

tmap::tm_shape(RGB_2019) + tmap::tm_raster(title = "RGB, 2019") +
  tmap::tm_shape(country) + tmap::tm_borders(col = "blue", lwd = 2) +
  tmap::tm_shape(aoi) + tmap::tm_borders(col = "red", lwd = 1) +
  tmap::tm_basemap("Esri.WorldImagery") +  
  tmap::tm_compass(position = c("left", "bottom")) +
  tmap::tm_scale_bar() -> tm4

tmap::tm_shape(RGB_2024) + tmap::tm_raster(title = "RGB, 2024") +
  tmap::tm_shape(country) + tmap::tm_borders(col = "blue", lwd = 2) +
  tmap::tm_shape(aoi) + tmap::tm_borders(col = "red", lwd = 1) +
  tmap::tm_basemap("Esri.WorldImagery") +  
  tmap::tm_compass(position = c("left", "bottom")) +
  tmap::tm_scale_bar() -> tm5



### fig layout

![Figure 1: Site map showing proposed project extent as defined by `ProjectArea.shp`](data/site_maps/site-map.png)

![Figure 2: Locator map showing position of project area within national borders](data/site_maps/locator-map.png)
