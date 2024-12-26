---
title: "Methods Check"
subtitle: "Review of Emissions Estimates & Activity Data applied in the RSPB Gola Feasibility Assessment"
date: "2024-12-23"
output: 
  word_document:
    keep_md: TRUE
    toc: FALSE
    
editor_options: 
  markdown: 
    wrap: 90
always_allow_html: TRUE
bibliography: references.bib
---





## Summary

------------------------------------------------------------------------------------------

## Project files reviewed

| **Filename** | **Filepath** |
|---------------------------------------------|---------------------------------------------|
| community forestry zone REDD objectives.docx | \~/20087 - RSPB Gola Feasibility/Working Files/Gola VER estimate/ |
| ER_Workbook_Gola_Liberia.xlsx | \~/20087 - RSPB Gola Feasibility/Working Files/Gola VER estimate/ |
| ERR_assumptions_meeting_notes_final.docx[^1] | \~/20087 - RSPB Gola Feasibility/Working Files/Gola VER estimate/ |
| Proxy Baseline Allocation Report.docx | \~/20087 - RSPB Gola Feasibility/Working Files/Gola VER estimate/ |
| VER Notes.docx | \~/20087 - RSPB Gola Feasibility/Working Files/Gola VER estimate/ |
| 10b Gola REDD Baseline Workplan VCS.pdf | \~/20087 - RSPB Gola Feasibility/Working Files/Data from RSPB/OneDrive_1_02-05-2024.zip |
| ProjectArea.shp | \~/20087 - RSPB Gola Feasibility/Working Files/Winrock_GIS Analysis Gola/ |

[^1]: "RSPB is concerned that the Verra baselines will be inaccurate because they will
    use: existing freely available global data like ESA (European Space Agency) landcover
    and Hansen Global Forest Change to measure forest cover. These overestimate the amount
    of native forest that exists because these data sources can’t distinguish between
    native forest and some other habitats such as agroforest in the Greater Gola Landscape
    (GGL), despite doing so effectively elsewhere (Brittany has verified this in the GGL).
    This is because the GGL is fine-grained (small patches of rotational swidden
    agriculture) and agroforestry often has dense canopy cover, which means only
    satellites collecting very high-resolution images can detect small habitat patches and
    small gaps in canopy cover. This is important because although the habitats can look
    similar, the above-ground carbon is far less than that of forest."

------------------------------------------------------------------------------------------

*Import aoi*


``` r
aoi = sf::read_sf("~/OneDrive - Winrock International Institute for Agricultural Development/20087 - RSPB Gola Feasibility/Working Files/Winrock_GIS Analysis Gola/ProjectArea.shp") |> sf::st_transform(3857) # supports mosaicking across multiple UTMs
aoi = aoi |>
  sf::st_cast("POLYGON") |>
  sf::st_cast("MULTIPOLYGON")

bbox_expand = terra::vect(terra::ext(vect(aoi)) * 1.3)
bbox_frame  = terra::vect(terra::ext(vect(aoi)) * 1.1)
bbox        = sf::st_as_sf(bbox_frame) 
terra::crs(bbox_expand) = "epsg:3857"
terra::crs(bbox_frame)  = "epsg:3857"
sf::st_crs(bbox) = 3857
```



![Figure 1: Site map showing proposed extent as defined by
`ProjectArea.shp`](data/basemaps/Esri.NatGeoWroldMap.png)

------------------------------------------------------------------------------------------

## Area check

In Liberia, the official definition of forest land is provided by the Forestry Development
Authority [@governmentofliberiaLiberiasForestReference2019], including areas of land that
meet the following criteria:

-   Canopy cover of minimum 30%;
-   Canopy height of minimum 5m or the capacity to reach it;
-   Covering a minimum of 1 hectare of land.


``` r
aoi$area_m2 = round(as.numeric(st_area(aoi) * 0.0001, 4))
aoi_select = aoi |>
  dplyr::select(NAME, DESIG, area_m2) |>
  dplyr::filter(
    NAME == "Gola Forest National Park" | 
      NAME == "Tonglay" |
      NAME == "Normon") |>
  sf::st_drop_geometry() |>
  janitor::adorn_totals() |>
  knitr::kable(font_size = 7) |>
  kable_styling("striped", full_width = F)
aoi_select
```

<table class="table table-striped" style="color: black; width: auto !important; margin-left: auto; margin-right: auto;">
 <thead>
  <tr>
   <th style="text-align:left;"> NAME </th>
   <th style="text-align:left;"> DESIG </th>
   <th style="text-align:right;"> area_m2 </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> Gola Forest National Park </td>
   <td style="text-align:left;"> National Park </td>
   <td style="text-align:right;"> 90922 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Tonglay </td>
   <td style="text-align:left;"> Community Forest </td>
   <td style="text-align:right;"> 30247 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Normon </td>
   <td style="text-align:left;"> Community Forest </td>
   <td style="text-align:right;"> 7170 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Total </td>
   <td style="text-align:left;"> - </td>
   <td style="text-align:right;"> 128339 </td>
  </tr>
</tbody>
</table>

``` r
# check for artefacts or "forest slivers"
slivers = aoi |>
  dplyr::filter(as.numeric(area_m2) < 1)
slivers # no slivers found
```

```
Simple feature collection with 0 features and 30 fields
Bounding box:  xmin: NA ymin: NA xmax: NA ymax: NA
Projected CRS: WGS 84 / Pseudo-Mercator
# A tibble: 0 × 31
# ℹ 31 variables: WDPAID <dbl>, WDPA_PID <chr>, NAME <chr>, ORIG_NAME <chr>,
#   DESIG <chr>, DESIG_TYPE <chr>, IUCN_CAT <chr>, INT_CRIT <chr>,
#   MARINE <chr>, REP_M_AREA <dbl>, GIS_M_AREA <dbl>, REP_AREA <dbl>,
#   GIS_AREA <dbl>, STATUS <chr>, STATUS_YR <dbl>, GOV_TYPE <chr>,
#   MANG_AUTH <chr>, MANG_PLAN <chr>, VERIF <chr>, METADATAID <dbl>,
#   SUB_LOC <chr>, PARENT_ISO <chr>, ISO3 <chr>, Comments <chr>,
#   Landscape <chr>, Shape_Leng <dbl>, Shape_Area <dbl>, Areaha <dbl>, …
```

Results confirm the dataset is free from forest patches that are smaller than the approved
area definition.

## LULC check

*Data processing*

-   raster normalization applied cloudless pixel ranking & median back-fill;
-   baseline beyond temporal extent of sentinel (**landsat used instead?**);
-   training sample extracted from GLanCE dataset[^2], which was processed using **class
    migration** algorithm;
    -   Although Verra lacking requirements for class migration (i.e. VT0007, VMD0055,
        VM0048), we may advise client on best practices and showcase improved accuracy in
        following comparisons [@verraVM0048ReducingEmissions2023a;
        @verraVMD0055EstimationEmission2024; @verraVT0007UnplannedDeforestation2021].
    -   Level-1 classes in the GLanCE dataset were recoded to match feature labels
        reported in the "Lookups" sheet of "ER_Workbook_Gola_Liberia.xlsx". For review,
        the following table compares GLanCE's data dictionary and Liberia's methodological
        report to present feature classes in their original format and converted format (
        "\>\>" ) [@woodcockGlobalLandCover;
        @governmentofliberiaLiberiasForestReference2019].

[^2]: For replication, the full unprocessed dataset was stored in personal drive folder
    here:
    <https://drive.google.com/file/d/1FhWTpSGFRTodDCY2gSGhssLuP2Plq4ZE/view?usp=drive_link> -
    To extract from source, java script and google earth engine account needed.

| RSPB classes |   | GLanCE classes |   |
|-----------------------|-----------------------|------------------|-----------------------|
|  |  | Developed (3) | Areas covered with structures, built-up |
| Bareground (0) |  | Barren (4) \>\> Bareground (0) | Areas of soils, sand, or rocks where \<10% is vegetated |
| Regrowth (1) |  | Herbaceous (7) \>\> Regrowth (1) | Areas of \<30% tree, \>10% vegetation, but \<10% shurb |
| Farmbush (2) |  | Shrublands (6) \>\> Farmbush (2) | Areas of \<30% tree, \>10% vegetation, & \>10% shrub |
| Forest (3) |  | Tree Cover (5) \>\> Forest (3) | Areas of tree cover \> 30%. |
| Water (4) |  | Water (1) \>\> Water (4) | Areas covered with water year-round (lakes & streams) |
| Swamp (5) |  | Developed (3) \>\> Developed (99) | Areas covered with structures, built-up |
| Cocoa (6) |  | Ice/Snow (2) \>\> Ice/Snow (88) | Areas of snow cover \> 50% year-round |
| Oil Palm (7) |  |  |  |

Training samples are fitted to a Random Forest model, a Bayesian smoothing, and evaluated
using confusion matrix and probabilistic uncertainty of classification. Subseuqently, new
samples were derived in areas of high uncertainty before classifiers were re-evaluated
with a second confusion matrix.


``` r
# download & filter training dataset
samples       = read.csv("./data/glance_dataset.csv")
train_data    = sits::sits_sample(samples, frac = 0.7)
test_data     = sits::sits_sample(samples, frac = 0.3)

# assemble cube from stac
cube_2023_aws = sits_cube(
  source      = "AWS",
  collection  = "SENTINEL-2-L2A",
  roi         = aoi,
  bands       = c("B04", "B08", "CLOUD"),
  start_date  = "2023-01-01",
  end_date    = "2023-03-01"
  )

# normalize cube
cube_2023_reg = sits_regularize(
  cube        = cube_2023_aws,
  res         = 10,
  period      = "P60D",
  multicores  = 16,
  output_dir  = "./data/cube_2023"
  )

# Derive NDVI
cube_202407_spectral <- sits::sits_apply(
  data = cube_202407_reg,
  NDVI = (B8A - B04) / (B8A + B04), 
  output_dir = './cubes/2024_reg',
  memsize = 6,
  multicores = 4,
  progress = T
  )

ndvi = list.files("./cubes/2024_reg", 
  pattern = 'NDVI', full.names = T, all.files = FALSE)|>
  lapply(terra::rast)|>
  sprc() |>
  mosaic()
terra::mask(ndvi, vect(aoi))
aoi = sf::st_transform(aoi, crs(ndvi))
ndvi = terra::crop(ndvi, vect(aoi), mask=T)
ndvi = ndvi * 0.0001

writeRaster(ndvi, "./cubes/2024_mosaic/NDVI_2024_07.tif", overwrite=T)


# train classifier
rfor_model    = sits_train(train_data, sits_rfor())

# classify cube
cube_2023_prob = sits_classify(
  data        = cube_2023_reg, 
  ml_model    = rfor_model, 
  output_dir  = "./data/cube_2023"
  )

# smooth cube (probability segmentation)
cube_2023_seg = sits_smooth(cube_2023_prob, output_dir = "./data/cube_2023")

# serialize cube
cube_2023_class = sits_label_classification(bayes_cube, output_dir = "./data/cube_2023") 

# mosaic cube
cube_2023_mosaic = sits_mosaic(
  cube         = cube_2023_class,
  roi          = data_multipolygon,
  crs          = "EPSG:3857",
  output_dir   = "./data/mosaics"
  )
```

Accuracy assessments


``` r
cube_2023_uncert = sits_uncertainty(
  cube         = cube_2023_class, # may also input cube_2023_prob & cube_2023_seg
  output_dir   = "./data/uncertainty"
  )

hist(cube_2023_uncert)

cube_2023_acc  = sits_accuracy(cube_2023_mosaic, validation = test_data)
```


