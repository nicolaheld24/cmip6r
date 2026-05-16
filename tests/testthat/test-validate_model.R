test_that("multiplication works", {
  expect_equal(2 * 2, 4)
})

test_that("valid model returns TRUE invisibly", {
  expect_invisible(validate_model("AWI-CM-1-1-MR"))
  expect_true(validate_model("AWI-CM-1-1-MR"))
})

test_that("all supported models pass validation", {
  valid_models <- c(
    "ACCESS-CM2", "ACCESS-ESM1-5", "AWI-CM-1-1-MR", "AWI-ESM-1-1-LR",
    "BCC-CSM2-MR", "BCC-ESM1", "CAMS-CSM1-0", "CanESM5", "CanESM5-CanOE",
    "CESM2", "CESM2-FV2", "CESM2-WACCM", "CESM2-WACCM-FV2", "CIESM",
    "CMCC-CM2-HR4", "CMCC-CM2-SR5", "CMCC-ESM2", "CNRM-CM6-1",
    "CNRM-CM6-1-HR", "CNRM-ESM2-1", "E3SM-1-0", "E3SM-1-1",
    "E3SM-1-1-ECA", "EC-Earth3", "EC-Earth3-AerChem", "EC-Earth3-CC",
    "EC-Earth3-Veg", "EC-Earth3-Veg-LR", "FGOALS-f3-L", "FGOALS-g3",
    "FIO-ESM-2-0", "GFDL-ESM4", "GISS-E2-1-G", "GISS-E2-1-H",
    "HadGEM3-GC31-LL", "HadGEM3-GC31-MM", "IITM-ESM", "INM-CM4-8",
    "INM-CM5-0", "IPSL-CM5A2-INCA", "IPSL-CM6A-LR", "KACE-1-0-G",
    "KIOST-ESM", "MCM-UA-1-0", "MIROC6", "MIROC-ES2H", "MIROC-ES2L",
    "MPI-ESM1-2-HAM", "MPI-ESM1-2-HR", "MPI-ESM1-2-LR", "MRI-ESM2-0",
    "NESM3", "NorCPM1", "NorESM2-LM", "NorESM2-MM", "SAM0-UNICON",
    "TaiESM1", "UKESM1-0-LL"
  )
  for (model in valid_models) {
    expect_true(validate_model(model))
  }
})

test_that("invalid model gives warning", {
  expect_warning(validate_model("DOES NOT EXIST"))
  expect_warning(validate_model(""))
  expect_warning(validate_model("awi-cm-1-1-mr"))  # case sensitive
})
