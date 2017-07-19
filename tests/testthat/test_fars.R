test_that("basic functions", {
  context("My context")
fn <- make_filename(2014)
expect_that(fn, is_a("character"))


dt <- fars_read_years(2014)
expect_that(dt, is_a("list"))
expect_that(dt[[1]], is_a("data.frame"))
})
