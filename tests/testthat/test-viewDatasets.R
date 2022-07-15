test_that("datasets listed", {
  expect_gt(nrow(viewDatasets()), 0)
})
