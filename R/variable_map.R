# Internal variable mapping: CMIP6 short name → CDS API name
# Used by build_request() to translate variable names for the CDS API.

VARIABLE_MAP <- c(
  "tas"     = "near_surface_air_temperature",
  "tasmax"  = "daily_maximum_near_surface_air_temperature",
  "tasmin"  = "daily_minimum_near_surface_air_temperature",
  "pr"      = "precipitation",
  "hurs"    = "near_surface_relative_humidity",
  "huss"    = "near_surface_specific_humidity",
  "sfcWind" = "near_surface_wind_speed",
  "uas"     = "eastward_near_surface_wind",
  "vas"     = "northward_near_surface_wind",
  "psl"     = "sea_level_pressure",
  "rsds"    = "surface_downwelling_shortwave_radiation",
  "rlds"    = "surface_downwelling_longwave_radiation",
  "mrsos"   = "moisture_in_upper_portion_of_soil_column",
  "mrro"    = "total_runoff",
  "clt"     = "total_cloud_cover_percentage",
  "evspsbl" = "evaporation_including_sublimation_and_transpiration"
)
