test_that("GET data success", {
  datasets <- viewDatasets()
  datasets <- dplyr::filter(datasets,siteName == 'Constantiaberg')
  datasets<- dplyr::filter(datasets,description == 'Air Temperature - Daily Minimum - Degrees Celsius')
  obs <- getDatasets(datasets)
  expect_gt(nrow(obs), 0)
})

test_that("POST data success", {
  datasets <- viewDatasets()
  datasets <- dplyr::filter(datasets,siteName == 'Constantiaberg')
  datasets<- dplyr::filter(datasets,description == 'Air Temperature - Daily Minimum - Degrees Celsius')
  start <- '2019-11-30'
  end <- '2019-12-31'
  obs <- getDatasets(datasets,startDate=start,endDate=end)
  expect_gt(nrow(obs), 0)
})
