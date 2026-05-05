# cmip6r <img src="man/figures/logo.png" align="right" height="139" alt="" />
 
<!-- badges: start -->
[![Lifecycle: experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![R-CMD-check](https://github.com/nicolaheld24/cmip6r/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/nicolaheld24/cmip6r/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->
 
> Download, process, and visualize CMIP6 climate scenario data from the [Copernicus Climate Data Store (CDS)](https://cds.climate.copernicus.eu) and visualize them with publication-ready plots. 
 
## Overview
 
`cmip6r` provides a simple interface to access CMIP6 climate model projections. With a single function call, you can download NetCDF data for any model, scenario, variable, time range, and region — and immediately visualize the results.
 
**Key features:**
 
- **Download** CMIP6 data via the CDS API (`get_cmip6_data()`)
- **Read** NetCDF files into tidy R data frames (`read_cmip6()`)
- **Unit conversion** (e.g. Kelvin -> °C)
- **Visualize** time series plots for one or multiple scenarios with trend lines (`plot_timeseries()`)
- **Flexible regions** — global or custom bounding box
 
## Installation
  
```r
# Install cmip6r from GitHub
# install.packages("remotes")
remotes::install_github("nicolaheld24/cmip6r")
```

## Dependencies
 
- **`ggplot2`** – visualization
- **`dplyr`** – data manipulation
- **`ncdf4`** – NetCDF file handling
- **`reticulate`** – Python integration
- **`ggtext`**, **`showtext`**, **`sysfonts`** – enhanced plotting and fonts

---
## One-time CDS API Setup (required before first use)
 
`cmip6r` downloads data from the **Copernicus Climate Data Store (CDS)** via Python. 
 
### 1. Create a CDS account
 
Register for free at [cds.climate.copernicus.eu](https://cds.climate.copernicus.eu) to get access to your API key.
 
### 2. Find your API key
 
After logging in, go to your **profile page** (top right → your username). The URL and your personal **API key** are displayed there.
 
### 3. Create the `.cdsapirc` file
 
The CDS API looks for a hidden config file in your home directory. Create it like this:
 
**On Windows** — open the file `C:\Users\YOURNAME\.cdsapirc` (create it if it doesn't exist) and paste:
 
```
url: https://cds.climate.copernicus.eu/api
key: YOUR-API-KEY
```
 
**On macOS/Linux** — run in the terminal:
 
```bash
echo "url: https://cds.climate.copernicus.eu/api
key: YOUR-API-KEY" > ~/.cdsapirc
```
 
> Replace `YOUR-API-KEY` with the key from your CDS profile page.
 
### 4. Accept dataset licence
 
Before downloading CMIP6 data for the first time, you need to accept the licence on the CDS website:
 
1. Go to: [CMIP6 dataset page](https://cds.climate.copernicus.eu/datasets/projections-cmip6?tab=download)
2. Scroll down to **"Terms of use"** and click **Accept**

### 5. Verify the setup in R
 
```r
library(cmip6r)

# simple test: should not throw an error
get_cmip6_data(start_year = 2015, end_year = 2015, months = 1)
```
 
---
## Quick Start
 
```r
library(cmip6r)

# 1. Set data directory
set_cmip6_dir("yourpath/data")
 
# 2. Download monthly maximum temperature (tasmax)
result_126 <- get_cmip6_data(
  variable = "tasmax",
  scenario = "ssp126",
  start_year = 2020,
  end_year = 2100,
  months = 1:12,
  region = c(9, 14, 47, 51), # Coordinates of Bavaria 
  temporal_resolution = "monthly"
)
```
### Optional: Temporal resolution
You can choose between daily or monthly data:

- `"daily"` → high-resolution climate data (default)
- `"monthly"` → aggregated monthly values

If not specified, the default is `"daily"`.

```r

# 3. Read the downloaded NetCDF file into R
df_126 <- read_cmip6(result_126$file, scenario = "ssp126")

# Fallback (if automatic file detection fails)
df_126 <- read_cmip6("yourpath/data/tasmax_Amon_AWI-CM-1-1-MR_ssp126_r1i1p1f1_gn_20200116-21001216.nc", scenario = "ssp126" )
 
# 4. Plot the time series
plot_timeseries(df_126, title = "Monthly Near-Surface Air Temperature \n Bavaria (2020-2100)")

```
### Optional: Light theme version 
```r
# 5. Light theme version
plot_timeseries(df_126,
  title = "Monthly Near-Surface Air Temperature \n Bavaria (2020–2100)",
  theme = "light"
)
```

---
## Compare Multiple Scenario 
 
Compare multiple SSP scenarios in a single plot:
 
```r
df_ssp126 <- read_cmip6("tas_ssp126.nc", scenario = "ssp126")
df_ssp245 <- read_cmip6("tas_ssp245.nc", scenario = "ssp245")
df_ssp585 <- read_cmip6("tas_ssp585.nc", scenario = "ssp585")
 
plot_timeseries(
  df_ssp126, df_ssp245, df_ssp585,
  time_aggregation = "annual",
  title = "Temperature Projections – SSP Comparison"
)
```

---
## Supported Scenarios & Variables
 
### SSP Scenarios
 
| Scenario | Description |
|----------|-------------|
| `"historical"` | Historical simulation (1850–2014) |
| `"ssp126"` | Low emissions – sustainable development pathway |
| `"ssp245"` | Intermediate emissions – middle of the road |
| `"ssp370"` | High emissions – regional rivalry |
| `"ssp585"` | Very high emissions – fossil-fuelled development |
 
### Common Variables
 
| Variable | Description |
|----------|-------------|
| `"tas"`    | Near-surface air temperature (2m) |
| `"tasmax"` | Daily maximum temperature |
| `"tasmin"` | Daily minimum temperature |
| `"pr"`     | Precipitation |
| `"huss"`   | Specific humidity |
| `"psl"`    | Sea level pressure |
| `"sfcWind"`| Wind speed |

### Supported Models

`cmip6r` supports 29 CMIP6 models including `AWI-CM-1-1-MR`, `CanESM5`, `CESM2`, `MPI-ESM1-2-LR`, and more. Run `?get_cmip6_data` for the full list.

--- 
## Plot Options
 
`plot_timeseries()` offers several customization options:
 
```r
plot_timeseries(
  df_ssp245, df_ssp585,
  aggregation      = "mean",      # "mean", "max", "min", "median"
  time_aggregation = "annual",    # "auto", "annual", "monthly", "none"
  show_smooth      = TRUE,        # linear trend line
  show_ci          = TRUE,        # 95% confidence band
  theme            = "light"      # "default" (dark) or "light"
)
```
### Time aggregation behavior

When `time_aggregation = "auto"`, the function automatically selects the aggregation level:

- **> 20 years** → annual aggregation  
- **2–20 years** → monthly aggregation  
- **< 2 years** → daily (no aggregation)
---
## Function Reference

| Function | Description |
|---|---|
| `set_cmip6_dir()` | Set the directory for downloaded data |
| `get_cmip6_data()` | Download CMIP6 data from CDS |
| `read_cmip6()` | Read a `.nc` file into a data frame |
| `plot_timeseries()` | Plot a time series for one or more scenarios |
| `theme_cmip6()` | Default ggplot2 theme |
| `theme_cmip6_light()` | Light ggplot2 theme |

---
## Citation
 
If you use `cmip6r` in your research, please cite:
 
```
Held, N. (2026). cmip6r: Download and Visualize CMIP6 Climate Scenario Data.
R package version 0.1.0. https://github.com/nicolaheld24/cmip6r
``` 
---
 
## License
 
MIT © Nicola Held
